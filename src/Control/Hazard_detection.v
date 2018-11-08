module Hazard_detection( input IDEX_Memread, EXMEM_Memread,
	input [2:0] IDEX_Flag_en,
	input [3:0] IFID_opcode, IDEX_opcode, IFID_RegisterRs, IFID_RegisterRt, 
	 IDEX_RegisterRd, EXMEM_RegisterRd,
	input [2:0] condition,
	output PC_write_en, IFID_write_en, Control_mux);
	reg int_stall;
	wire S;
	wire S1, S2, S3, S4, S5;
	assign S1 =(IDEX_Memread & ((IDEX_RegisterRd==IFID_RegisterRs) | (IDEX_RegisterRd==IFID_RegisterRt)))? 1'b1:0;
	//stall  lw -> add

	assign S2 = ((IFID_opcode ==4'b1100) & (IDEX_Flag_en!=3'b000))? 1'b1:0;
	//any instruction change Flag -> B

	assign S3 = ( (IFID_opcode ==4'b1101) & ( (IDEX_Flag_en!=3'b000) | 
	(IFID_RegisterRs == IDEX_RegisterRd)))? 1'b1:0;
	// add -> Br or any instruction change Flag -> Br 
	assign S4 = ((IFID_opcode ==4'b1101) & (IFID_RegisterRs==EXMEM_RegisterRd))? 1'b1:0;
	
	assign S5 = (IFID_opcode == 4'b1100 | IFID_opcode == 4'b1101 & condition == 3'b111) ? 0 : 1'b1;
	
	assign S = (S1|S2|S3|S4)&S5;
	
//	assign state = next_state;
	assign PC_write_en = (S)? 0:1'b1;
	assign IFID_write_en = (S)? 0:1'b1;
	assign Control_mux = (S)? 0: 1'b1;
endmodule
