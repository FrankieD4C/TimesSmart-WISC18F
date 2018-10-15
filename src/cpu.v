`include "ALU/ALU.v"
`include "Branch.v"
`include "Control/Buffer3bit.v"
`include "Control/Main_control.v"
`include "Control/Sign_extend.v"
`include "Control/PC_generator.v"
`include "singlecycle-memory/memory.v"
`include "Register/RegisterFile.v"

module cpu (input clk,
	input rst_n, // change Dff ?? what about memory rst?
	output hlt,
	output [15:0] pc);

	wire int_MemWrite, int_Branch, int_LLHB, int_MemRead, int_MemtoReg, int_ALUSrc, int_Regwrite;
	wire [1:0] int_PCs;

//*********************************************************************First stage********************************************88//
	wire [15:0] in_PC, out_PC;
	wire [15:0] Ins,int_DstData ;

	wire Jump; // jump condition
	wire[15:0] J_addr, normal_PC; // normal PC undeal // PCs, HLT
	ALU_adder PCA1 (.Adder_In1(16'h0002), .Adder_In2(out_PC), .sub(1'b0), .sat(1'b0), .Adder_Out(normal_PC), .Ovfl());
	assign in_PC = (int_PCs == 11) ? out_PC: //can we directly connect port like this??!!!!!!!!!!!!!!!!!!!!!!!!!!1
			((Jump == 1) ? J_addr: normal_PC); // HLT, branch, normal pc update
	PC_generator PCValue(.clk(clk), .rst_n(rst_n), .PC_in(in_PC), .PC_out(out_PC));

	memory1c IMEMO(.data_out(Ins), .data_in(), .addr(out_PC), .enable(1'b1), .wr(1'b0), .clk(clk), .rst(rst_n)); //rst for load instructions //enable should always be one?
//***********************************************************************First stage*************************************************8//


//********************************************************************ID stage**********************************************************8//
	Main_control Control(.Op(Ins[15:12]),
				.Branch(int_Branch),
				.LLHB(int_LLHB),
				.MemRead(int_MemRead),
				.MemtoReg(int_MemtoReg),
				.MemWrite(int_MemRrite),
				.ALUSrc(int_ALUSrc), // ALU should have a write enable signal to update the flags, so if no calculation, if wont affect the previous stored flags in buffer
				.Regwrite(int_Regwrite),
				.PCs(int_PCs));

	wire [3:0] RsID; // ins[11:8] for rd, ins[7:4] for rs
	wire [15:0] int_SrcData1, int_SrcData2, Immextend;

	assign RsID = (int_LLHB | int_MemWrite) ? Ins[11:8]: Ins[3:0]; // LLB,LHB,SW,IMM??

	RegisterFile Regi(.clk,
			 .rst(rst_n),
			 .SrcReg1(Ins[7:4]), //rs
			 .SrcReg2(RsID), //rt/rd
			 .DstReg(Ins[11:8]), //rd
			 .WriteReg(int_Regwrite),
			 .DstData(int_DstData),
			 .SrcData1(int_SrcData1),
			 .SrcData2(int_SrcData2));
	Sign_extend S_extd(.Imme_9b(Ins[8:0]), .Opcode(Ins[15:12]), .Imme_16b(Immextend));
//**********************************************************************************ID stage **************************************************//


//*********************************************************************************ALU stage***************************************************8//

	wire [15:0] In1, In2, ALU_Re, Immextend_shift1; // input for ALU_in2
	wire [2:0] int_ZVN; // flag data
	wire Flag_en;
	wire [15:0] addr_imm; // immediate addr for Branch
	assign Immextend_shift1 = Immextend <<1;
	ALU_adder PCA2 (.Adder_In1(normal_PC), .Adder_In2(Immextend_shift1), .sub(1'b0), .sat(1'b0), .Adder_Out(addr_imm), .Ovfl());
	assign J_addr = ((int_ALUSrc&int_Branch)==1) ? addr_imm : int_SrcData1; // define in line12 pc stage

	assign In1 = (int_LLHB) ? Immextend : int_SrcData1;
	assign In2 = (int_ALUSrc) ? int_SrcData2 : Immextend;
	ALU AUT(.ALU_In1(In1), .ALU_In2(In2), .Opcode(Ins[15:12]), .ALU_Out(ALU_Re), .ZVN(int_ZVN), .FlagWriteEnable(Flag_en));
	wire [2:0] int_brc; // flag condition
	Buffer3bit BUF(.clk(clk), .rst_n(rst_n), .flag(int_ZVN), .Writenable(Flag_en), .brc(int_brc));


//************************************************************************************ALU stage****************************************************8//



//***************************************************************************************Memo stage**************************************************//
	wire Dmemo;//data memo
	wire [15:0] memoDst;
	assign Dmemo = (int_MemRead == 1 || int_MemWrite == 1) ? 1:0; // enblae memory part
	memory1c Datmemo(.data_out( memoDst), .data_in(int_SrcData2), .addr(ALU_Re), .enable(Dmemo), .wr(int_MemWrite), .clk(clk), .rst(rst_n)); //rst for load instructions
	wire [2:0] int_condition; // branch condition
	assign int_condition = (int_Branch) ? Ins[11:9] : 000;
	Branch BUT(.Branch_enable(int_Branch), .C(int_condition), .F(int_brc), .J_out(Jump)); // directly pass PC_out to next_PC, because PC already add 2

// ***************************************************************Wb stage **************************************************************************//
	assign int_DstData = (int_PCs == 01) ? normal_PC :
				(int_MemtoReg == 1) ? memoDst: ALU_Re; // chose which data is going to be wrriten into the dst reg
endmodule
