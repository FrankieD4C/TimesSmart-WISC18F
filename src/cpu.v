/*
`include "ALU/ALU.v"
`include "Control/Branch.v"
`include "Control/Buffer3bit.v"
`include "Control/Main_control.v"
`include "Control/Sign_extend.v"
`include "Control/PC_generator.v"
`include "Control/FWD_unit.v"
`include "Control/Hazard_detection.v"
`include "multicycle-memory/multicycle_memory.v"
`include "Register/RegisterFile.v"
`include "cache/top_mod.v"
`include "cache/cache_fill_FSM.v"
`include "cache/D_cache.v"
`include "cache/I_cache.v"
`include "cache/DataArray.v"
`include "cache/MetaDataArray.v"
`include "cache/convert3to8.v"
`include "cache/convert6to128.v"
`include "cache/adder4bit+tb.v"
`include "Register/Register.v"
`include "Register/BitCell.v"
`include "Register/ReadDecoder_4_16.v"
`include "Register/ReadDecoder2_4_16.v"
`include "Register/WriteDecoder_4_16.v"
`include "Register/D-Flip-Flop.v"
`include "ALU/ALU_adder.v"
`include "ALU/Shift.v"
`include "ALU/RED.v"
`include "ALU/PADDSB.v"
*/

module cpu (input clk,
	input rst_n, // change Dff ?? what about memory rst?
	output hlt,
	output [15:0] pc);

	wire [1:0] int_PCs;

	wire [15:0] IFID_PC, IFID_Ins;
	// wire connect to ID/EX pipeline
	wire IDEX_MemWrite, IDEX_Branch, IDEX_LLHB, IDEX_MemRead, IDEX_MemtoReg, IDEX_ALUSrc, IDEX_Regwrite; // wire to ID/EX pipeline
	wire [15:0] IDEX_SrcData1, IDEX_SrcData2, IDEX_Immextend;
	wire int_Control_mux;
	wire [2:0] EXM_Flag_en, IDEX_Flag_en;
	wire [2:0] int_brc; // flag condition
	//wire for execution stage
	wire stall;	//change stall signal when jump is high and stall is high, stall all the same
	wire EXM_Regwrite, EXM_MemtoReg, EXM_LLHB, EXM_ALUSrc, EXM_MemRead, EXM_MemWrite;
	wire [15:0] EXM_SrcData1, EXM_SrcData2, EXM_Immextend;
	wire [3:0] EXM_RtdID, EXM_RsID, EXM_WRegID, EXM_Ins; // opcode for ALU


	//wire for men stage
	wire MWB_Regwrite, MWB_MemtoReg, MWB_MemRead, MWB_MemWrite;
	wire [15:0] MWB_ALU_Re, MWB_SrcData2;
	wire [3:0] MWB_WRegID;

	//wire for wb stage
	wire WB_Regwrite, WB_MemtoReg;
	wire [15:0] WB_ALU_Re, WB_memoDst;

	//wire for cahce module
	wire I_cache_miss, D_cache_miss;
	
	wire pipe_write_en, pipe_nop, I_cache_nop, D_cache_write_en, D_cache_nop;
	assign pipe_write_en = (~int_Control_mux) ? 0 : 1;
	assign pipe_nop = (~int_Control_mux) ? 1 : 0;
	assign I_cache_nop = (I_cache_miss) ? 1 : 0;
	assign D_cache_write_en = (D_cache_miss) ? 0 : 1;
	
//*********************************************************************First stage********************************************88//
	// modify pc generator
	wire int_PCwrite;

	wire [15:0] in_PC, out_PC;
	wire [15:0] Ins,int_DstData;
	//assign hlt = (int_PCs == 2'b11) ? 1:0;
	assign pc = out_PC;
	wire Jump; // jump condition
	wire[15:0] J_addr, normal_PC; // normal PC undeal // PCs, HLT
	ALU_adder PCA1 (.Adder_In1(16'h0002), .Adder_In2(out_PC), .sub(1'b0), .sat(1'b0), .Adder_Out(normal_PC), .Ovfl());
	assign in_PC = ((~Jump && Ins[15:12] == 4'b1111) | I_cache_miss | D_cache_miss) ? out_PC: // D miss or I miss should all stall the PC update
			((Jump == 1) ? J_addr: normal_PC); // HLT, branch, normal pc update
	PC_generator PCValue(.clk(clk), .rst_n(rst_n), .PC_in(in_PC), .PC_out(out_PC), .PCwrite(int_PCwrite));

	//memory1c IMEMO(.data_out(Ins), .data_in(), .addr(out_PC), .enable(1'b1), .wr(1'b0), .clk(clk), .rst(rst_n)); //rst for load instructions //enable should always be one?
	//wire [15:0] inv_Ins, iinv_Ins;// inverse instruction to prevent confliction of flash & add flag_en
	//assign inv_Ins = ~Ins;
//***********************************************************************First stage*************************************************8//
	//wire [15:0] IFID_PC, IFID_Ins;
	/*
	wire IFID_write, flash, IF_write_en;
	assign flash = (Jump == 1 & stall == 1 | I_cache_miss) ? 0 : rst_n; // use to control reset and flush
	assign IF_write_en = (D_cache_miss) ? 1'b0 : IFID_write;
	*/
	
	wire IFID_write_en, IFID_nop;
	assign IFID_write_en = (~D_cache_write_en | ~pipe_write_en) ? 0 : 1;
	assign IFID_nop = ((IFID_write_en) & (I_cache_nop | Jump)) ? 0 : rst_n;
	dff IFIDPC[15:0] (.q(IFID_PC), .d(normal_PC), .wen(IFID_write_en), .clk(clk), .rst((rst_n & IFID_nop)));
	dff IFIDIns[15:0] (.q(IFID_Ins), .d(Ins), .wen(IFID_write_en), .clk(clk), .rst((rst_n & IFID_nop)));

// move pc adder Y
// change control unit Y, move branch unit Y, but how to deal with flash
// move shift Y
// add mux
// change register file
//********************************************************************ID stage**********************************************************8//
	//assign IFID_Ins = ~iinv_Ins;
	wire [15:0] Immextend_shift1, Immextend;
	wire [15:0] addr_imm; // immediate addr for Branch
	wire int_MemWrite, int_Branch, int_LLHB, int_MemRead, int_MemtoReg, int_ALUSrc, int_Regwrite; // output from control unit
	wire [15:0] int_SrcData1, int_SrcData2;
	Sign_extend S_extd(.Imme_9b(IFID_Ins[8:0]), .Opcode(IFID_Ins[15:12]), .Imme_16b(Immextend));
	assign Immextend_shift1 = Immextend <<1;
	assign J_addr = ((int_ALUSrc&int_Branch)==1) ? addr_imm : int_SrcData1; // define in line12 pc stage
	ALU_adder PCA2 (.Adder_In1(IFID_PC), .Adder_In2(Immextend_shift1), .sub(1'b0), .sat(1'b0), .Adder_Out(addr_imm), .Ovfl());


	wire [2:0] Flag_en;

	Main_control Control(.Op(IFID_Ins[15:12]),
				.Branch(int_Branch),
				.LLHB(int_LLHB),
				.MemRead(int_MemRead),
				.MemtoReg(int_MemtoReg),
				.MemWrite(int_MemWrite),
				.ALUSrc(int_ALUSrc), // ALU should have a write enable signal to update the flags, so if no calculation, if wont affect the previous stored flags in buffer
				.Regwrite(int_Regwrite),
				.FlagWriteEnable(Flag_en),
				.PCs(int_PCs));

// branch unit
	wire int_Jump;
	wire [2:0] int_condition; // branch condition
	assign int_condition = (int_Branch) ? IFID_Ins[11:9] : 000;
	Branch BUT(.Branch_enable(int_Branch), .C(int_condition), .F(int_brc), .J_out(int_Jump)); // directly pass PC_out to next_PC, because PC already add 2
	assign Jump = (~int_Control_mux) ? 0 : int_Jump; // if stall, not jump;



	wire [3:0] RtdID, int_DstReg; // ins[11:8] for rd, ins[7:4] for rs

	assign RtdID = (int_LLHB | int_MemWrite) ? IFID_Ins[11:8]: IFID_Ins[3:0]; // LLB,LHB,SW,IMM??

	wire [3:0] IFIDID;
	assign IFIDID = (IFID_Ins[15:14] == 0) ? IFID_Ins[3:0] : (IFID_Ins[15:12] == 4'b0111) ? IFID_Ins[3:0] : 0;
	//assign int_DstReg = IFID_Ins[11:8]; // update by wb stage
	RegisterFile Regi(.clk,
			 .rst(rst_n),
			 .SrcReg1(IFID_Ins[7:4]), //rs
			 .SrcReg2(RtdID), //rt/rd
			 .DstReg(int_DstReg), //rd
			 .WriteReg(WB_Regwrite),
			 .DstData(int_DstData), // update by wb stage
			 .SrcData1(int_SrcData1),
			 .SrcData2(int_SrcData2));


//stall MUX

	Hazard_detection HAZ ( .IDEX_Memread(EXM_MemRead), .IDEX_Flag_en(EXM_Flag_en),
	.IFID_opcode(IFID_Ins[15:12]), .IDEX_opcode(EXM_Ins), .IFID_RegisterRs(IFID_Ins[7:4]), .IFID_RegisterRt(IFIDID), .condition(IFID_Ins[11:9]),
	.IDEX_RegisterRd(EXM_WRegID), .EXMEM_RegisterRd(MWB_WRegID), .EXMEM_Memread(MWB_MemRead), .PC_write_en(int_PCwrite), .IFID_write_en(), .Control_mux(int_Control_mux));

//	wire IDEX_MemWrite, IDEX_Branch, IDEX_LLHB, IDEX_MemRead, IDEX_MemtoReg, IDEX_ALUSrc, IDEX_Regwrite; // wire to ID/EX pipeline
	//wire PCstall;
	assign {IDEX_MemWrite, IDEX_Branch, IDEX_LLHB, IDEX_MemRead, IDEX_MemtoReg, IDEX_ALUSrc, IDEX_Regwrite} = (Jump) ? 7'b0000000 : {int_MemWrite, int_Branch, int_LLHB, int_MemRead, int_MemtoReg, int_ALUSrc, int_Regwrite};

	assign IDEX_SrcData1 = (Jump) ? 0 : int_SrcData1;
	assign IDEX_SrcData2 = (Jump) ? 0 : int_SrcData2;
	assign IDEX_Flag_en = (Jump) ? 0 : (IFID_Ins == 16'b0) ? 3'b000 : Flag_en;
	assign IDEX_Immextend = (Jump) ? 0 : Immextend;
//**********************************************************************************ID stage **************************************************//

	//RtdID = rd/rt; rs = Ins[7:4];
	//write data only require one RegID which is Ins[11:8]
	//wire stall;
	wire IDEX_write_en, IDEX_nop;
	assign IDEX_write_en = (~D_cache_write_en) ? 0 : 1;
	assign IDEX_nop = (~D_cache_write_en) ? rst_n : ~pipe_nop;
	
	//assign stall = (~int_Control_mux) ? 0 : rst_n; // always writeenable, reset when stall
	//assign IDEX_write_en = (D_cache_miss) ? 0:1'b1;

	dff IDEXWB[1:0] (.q({EXM_Regwrite, EXM_MemtoReg}), .d({IDEX_Regwrite, IDEX_MemtoReg}), .wen(IDEX_write_en), .clk(clk), .rst((rst_n & IDEX_nop)));
	dff IDEXEX[1:0] (.q({EXM_LLHB, EXM_ALUSrc}), .d({IDEX_LLHB, IDEX_ALUSrc}), .wen(IDEX_write_en), .clk(clk), .rst((rst_n & IDEX_nop)));
	dff IDEXM[1:0] (.q({EXM_MemRead, EXM_MemWrite}), .d({IDEX_MemRead, IDEX_MemWrite}), .wen(IDEX_write_en), .clk(clk), .rst((rst_n & IDEX_nop)));

	dff IDEXSrc1[15:0] (.q(EXM_SrcData1), .d(IDEX_SrcData1), .wen(IDEX_write_en), .clk(clk), .rst((rst_n & IDEX_nop)));
	dff IDEXSrc2[15:0] (.q(EXM_SrcData2), .d(IDEX_SrcData2), .wen(IDEX_write_en), .clk(clk), .rst((rst_n & IDEX_nop)));
	dff IDEXimm[15:0] (.q(EXM_Immextend), .d(IDEX_Immextend), .wen(IDEX_write_en), .clk(clk), .rst((rst_n & IDEX_nop)));

	dff IDEXRsID[3:0] (.q(EXM_RsID), .d(IFID_Ins[7:4]), .wen(IDEX_write_en), .clk(clk), .rst((rst_n & IDEX_nop)));
	dff IDEXRtRdID[3:0] (.q(EXM_RtdID), .d(RtdID), .wen(IDEX_write_en), .clk(clk), .rst((rst_n & IDEX_nop)));
	dff IDEXWReg[3:0] (.q(EXM_WRegID), .d(IFID_Ins[11:8]), .wen(IDEX_write_en), .clk(clk), .rst((rst_n & IDEX_nop))); // write data ID

	dff IDEIns[3:0] (.q(EXM_Ins), .d(IFID_Ins[15:12]), .wen(IDEX_write_en), .clk(clk), .rst((rst_n & IDEX_nop))); // write data ID
	dff IDEFlag[2:0] (.q(EXM_Flag_en), .d(IDEX_Flag_en), .wen(IDEX_write_en), .clk(clk), .rst((rst_n & IDEX_nop))); // write data ID

	wire [15:0] IDEX_PC;
	wire [1:0] IDEX_PCs;
	dff IDEXPC[15:0] (.q(IDEX_PC), .d(IFID_PC), .wen(IDEX_write_en), .clk(clk), .rst((rst_n & IDEX_nop)));
	dff IDEXPCs[1:0] (.q(IDEX_PCs), .d(int_PCs), .wen(IDEX_write_en), .clk(clk), .rst((rst_n & IDEX_nop)));
//change src1, src2 Y
//change control signal, move flag signal to control unit
//change immextend value Y
//*********************************************************************************ALU stage***************************************************8//
	wire [1:0] Control_In1, Control_In2;
	wire [15:0] int_In1, int_In2;
	wire FWD_Mem;

	FWD_unit FWU (.IDEX_rs(EXM_RsID), .IDEX_rt(EXM_RtdID), .EXMEM_rd(MWB_WRegID), .EXMEM_rt(MWB_WRegID), .MEMWB_rd(int_DstReg),
                .EXMEM_MemWrite(MWB_MemWrite), .EXMEM_MemRead(MWB_MemRead), .EXMEM_MemtoReg(MWB_MemtoReg), .EXMEM_RegWrite(MWB_Regwrite),
                .MEMWB_MemtoReg(WB_MemtoReg), .MEMWB_RegWrite(WB_Regwrite),
                .ALUIn1_FWDEnable(Control_In1), .ALUIn2_FWDEnable(Control_In2),
                .MEM_FWDEnable(FWD_Mem));

	assign int_In1 = (Control_In1 == 2'b01) ? (int_DstData) : (Control_In1 == 2'b10) ? (MWB_ALU_Re) : EXM_SrcData1;
	assign int_In2 = (Control_In2 == 2'b01) ? (int_DstData) : (Control_In2 == 2'b10) ? (MWB_ALU_Re) : EXM_SrcData2;

	wire [15:0] In1, In2, ALU_Re; // input for ALU_in2
	wire [2:0] int_ZVN; // flag data
	wire [15:0] Mer_SrcData1; // merge PC_addr & ALU_Re


	assign In1 = (EXM_LLHB) ? EXM_Immextend : int_In1;
	assign In2 = (EXM_ALUSrc) ? EXM_Immextend : int_In2;

	ALU AUT(.ALU_In1(In1), .ALU_In2(In2), .Opcode(EXM_Ins), .ALU_Out(ALU_Re), .ZVN(int_ZVN));

	assign Mer_SrcData1 = (IDEX_PCs == 2'b01) ? IDEX_PC : ALU_Re;
	wire [2:0] BUF_flag;
	assign BUF_flag = (I_cache_miss) ? 0: EXM_Flag_en;// disregard the flag enable signal

	Buffer3bit BUF(.clk(clk), .rst_n(rst_n), .flag(int_ZVN), .Writenable(BUF_flag), .brc(int_brc));

//************************************************************************************ALU stage****************************************************8//
	//wire MWB_Regwrite, MWB_MemtoReg, MWB_MemRead, MWB_MemWrite;
	//wire [15:0] MWB_ALU_Re, MWB_SrcData2, MWB_WRegID
	
	wire MWB_write_en;
	assign MWB_write_en = (D_cache_miss) ? 0 : 1'b1;
	dff MWBWB[1:0] (.q({MWB_Regwrite, MWB_MemtoReg}), .d({EXM_Regwrite, EXM_MemtoReg}), .wen(MWB_write_en), .clk(clk), .rst(rst_n));
	dff MWBM[1:0] (.q({MWB_MemRead, MWB_MemWrite}), .d({EXM_MemRead, EXM_MemWrite}), .wen(MWB_write_en), .clk(clk), .rst(rst_n));

	dff MWBALU[15:0] (.q(MWB_ALU_Re), .d(Mer_SrcData1), .wen(MWB_write_en), .clk(clk), .rst(rst_n));
	dff MWBSrc2[15:0] (.q(MWB_SrcData2), .d(int_In2), .wen(MWB_write_en), .clk(clk), .rst(rst_n));
	dff MWBWReg[3:0] (.q(MWB_WRegID), .d(EXM_WRegID), .wen(MWB_write_en), .clk(clk), .rst(rst_n)); // write data ID

	wire [1:0] MWB_PCs;
	dff MWBPCs[1:0] (.q(MWB_PCs), .d(IDEX_PCs), .wen(MWB_write_en), .clk(clk), .rst(rst_n));
//***************************************************************************************Memo stage**************************************************//
	wire Dmemo;//data memo

	wire [15:0] memoDst, Mem_datain;
	assign Mem_datain = (FWD_Mem == 1)? int_DstData : MWB_SrcData2;
	//assign Mem_addr = (FWD_Mem == 1)? int_DstData : MWB_ALU_Re;

	//assign Dmemo = (MWB_MemRead == 1 || MWB_MemWrite == 1) ? 1:0; // enblae memory part
	//memory1c Datmemo(.data_out(memoDst), .data_in(Mem_datain), .addr(MWB_ALU_Re), .enable(Dmemo), .wr(MWB_MemWrite), .clk(clk), .rst(rst_n)); //rst for load instructions

//****************************************************************************************Memo stage*************************************************//

	//wire WB_Regwrite, WB_MemtoReg;
	//wire [15:0] WB_ALU_Re, WB_memoDst;

	wire WB_write_en;
	assign WB_write_en = (D_cache_miss) ? 0 : 1'b1;

	dff WB[1:0] (.q({WB_Regwrite, WB_MemtoReg}), .d({MWB_Regwrite, MWB_MemtoReg}), .wen(WB_write_en), .clk(clk), .rst(rst_n));

	dff WBALU[15:0] (.q(WB_ALU_Re), .d(MWB_ALU_Re), .wen(WB_write_en), .clk(clk), .rst(rst_n));
	dff WBMDat[15:0] (.q(WB_memoDst), .d(memoDst), .wen(WB_write_en), .clk(clk), .rst(rst_n));

	dff WBWReg[3:0] (.q(int_DstReg), .d(MWB_WRegID), .wen(WB_write_en), .clk(clk), .rst(rst_n)); // write data ID

	wire [1:0] WB_PCs;
	dff WBPC[1:0] (.q(WB_PCs), .d(MWB_PCs), .wen(WB_write_en), .clk(clk), .rst(rst_n));

//***************************************************************Wb stage **************************************************************************//

	assign hlt = (WB_PCs == 2'b11) ? 1:0;
	assign int_DstData = (WB_MemtoReg == 1) ? WB_memoDst: WB_ALU_Re; // chose which data is going to be wrriten into the dst reg

//***************************************************************cache *******************************************************************//
	top_mod CAM(.pc_addr(out_PC), .data_addr(MWB_ALU_Re), .data_in(Mem_datain), .MEM_read(MWB_MemRead), .MEM_write(MWB_MemWrite),
	       	    .clk(clk), .rst_n(rst_n), .MEM_stall(D_cache_miss), .IF_stall(I_cache_miss), .D_output(memoDst), .I_output(Ins));
endmodule
//memory1c IMEMO(.data_out(Ins), .data_in(), .addr(out_PC), .enable(1'b1), .wr(1'b0), .clk(clk), .rst(rst_n));
//memory1c Datmemo(.data_out(memoDst), .data_in(Mem_datain), .addr(MWB_ALU_Re), .enable(Dmemo), .wr(MWB_MemWrite), .clk(clk), .rst(rst_n));
// need to pass int_PCs data
// mem pass,