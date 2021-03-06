module Main_control (input [3:0] Op,
			output Branch,
			output LLHB,
			output MemRead,
			output MemtoReg,
			output MemWrite,
			output ALUSrc, // when we use LHB LLB need to set high?
			output Regwrite,
			output [2:0] FlagWriteEnable,
			output [1:0] PCs);

// need LLB/LHB signal for imm selection
// no need ALUOp, directly gives from instruction
//no need Regdst, rd / rt always follow Op code, no need to select which will be written
	reg int_MemRead, int_MemtoReg, int_MemWrite, int_ALUSrc, int_Regwrite, int_LLHB; // ALUsrc:0 from regi, 1 from imm
	reg int_Branch; // only need to be 1 bit for enable signal
	reg [1:0] int_PCs;
	always@*
	case (Op)
	default: begin int_Branch = 0; int_LLHB = 0;int_MemRead = 0; int_MemtoReg = 0; int_MemWrite = 0; int_ALUSrc = 0; int_Regwrite = 0; int_PCs = 2'b00;end
//Rformat
	4'b0000: begin int_Branch = 0; int_LLHB = 0;int_MemRead = 0; int_MemtoReg = 0; int_MemWrite = 0; int_ALUSrc = 0; int_Regwrite = 1; int_PCs = 2'b00;end
	4'b0001: begin int_Branch = 0; int_LLHB = 0;int_MemRead = 0; int_MemtoReg = 0; int_MemWrite = 0; int_ALUSrc = 0; int_Regwrite = 1; int_PCs = 2'b00;end
	4'b0010: begin int_Branch = 0; int_LLHB = 0;int_MemRead = 0; int_MemtoReg = 0; int_MemWrite = 0; int_ALUSrc = 0; int_Regwrite = 1; int_PCs = 2'b00;end
	4'b0011: begin int_Branch = 0; int_LLHB = 0;int_MemRead = 0; int_MemtoReg = 0; int_MemWrite = 0; int_ALUSrc = 0; int_Regwrite = 1; int_PCs = 2'b00;end
//Iformat
	4'b0100: begin int_Branch = 0; int_LLHB = 0;int_MemRead = 0; int_MemtoReg = 0; int_MemWrite = 0; int_ALUSrc = 1; int_Regwrite = 1; int_PCs = 2'b00;end
	4'b0101: begin int_Branch = 0; int_LLHB = 0;int_MemRead = 0; int_MemtoReg = 0; int_MemWrite = 0; int_ALUSrc = 1; int_Regwrite = 1; int_PCs = 2'b00;end
	4'b0110: begin int_Branch = 0; int_LLHB = 0;int_MemRead = 0; int_MemtoReg = 0; int_MemWrite = 0; int_ALUSrc = 1; int_Regwrite = 1; int_PCs = 2'b00;end
//Rformat
	4'b0111: begin int_Branch = 0; int_LLHB = 0;int_MemRead = 0; int_MemtoReg = 0; int_MemWrite = 0; int_ALUSrc = 0; int_Regwrite = 1; int_PCs = 2'b00;end
//I format
	4'b1000: begin int_Branch = 0; int_LLHB = 0;int_MemRead = 1; int_MemtoReg = 1; int_MemWrite = 0; int_ALUSrc = 1; int_Regwrite = 1; int_PCs = 2'b00;end
	4'b1001: begin int_Branch = 0; int_LLHB = 0;int_MemRead = 0; int_MemtoReg = 0; int_MemWrite = 1; int_ALUSrc = 1; int_Regwrite = 0; int_PCs = 2'b00;end
//special type
//LLB,LHB
	4'b1010: begin int_Branch = 0; int_LLHB = 1;int_MemRead = 0; int_MemtoReg = 0; int_MemWrite = 0; int_ALUSrc = 0; int_Regwrite = 1; int_PCs = 2'b00;end
	4'b1011: begin int_Branch = 0; int_LLHB = 1;int_MemRead = 0; int_MemtoReg = 0; int_MemWrite = 0; int_ALUSrc = 0; int_Regwrite = 1; int_PCs = 2'b00;end
//branch	need to consider more about B,BR
	4'b1100: begin int_Branch = 1; int_LLHB = 0;int_MemRead = 0; int_MemtoReg = 0; int_MemWrite = 0; int_ALUSrc = 1; int_Regwrite = 0; int_PCs = 2'b00;end
	4'b1101: begin int_Branch = 1; int_LLHB = 0;int_MemRead = 0; int_MemtoReg = 0; int_MemWrite = 0; int_ALUSrc = 0; int_Regwrite = 0; int_PCs = 2'b00;end
//PC,HLT
	4'b1110: begin int_Branch = 0; int_LLHB = 0;int_MemRead = 0; int_MemtoReg = 0; int_MemWrite = 0; int_ALUSrc = 0; int_Regwrite = 1; int_PCs = 2'b01;end
	4'b1111: begin int_Branch = 0; int_LLHB = 0;int_MemRead = 0; int_MemtoReg = 0; int_MemWrite = 0; int_ALUSrc = 0; int_Regwrite = 0; int_PCs = 2'b11;end
	endcase

	assign FlagWriteEnable[2] = ((Op[3] == 0) & (Op[1:0] != 2'b11)) ? 1'b1 : 1'b0; // Z enable
    assign FlagWriteEnable[1:0] = (Op[3:1] == 3'b000) ? 2'b11 : 2'b00; // W enable

	assign Branch = int_Branch;
	assign MemRead = int_MemRead;
	assign MemtoReg = int_MemtoReg;
	assign MemWrite = int_MemWrite;
	assign ALUSrc = int_ALUSrc;
	assign Regwrite = int_Regwrite;
	assign PCs = int_PCs;
	assign LLHB = int_LLHB;

endmodule

