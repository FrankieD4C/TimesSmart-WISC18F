module Hazard_detection( input IDEX_Memread, IDEX_Flag_en,
						input [3:0] IFID_opcode, IDEX_opcode, IFID_RegisterRs, IFID_RegisterRt, IDEX_RegisterRt, IDEX_RegisterRd, EXMEM_Memread, EXMEM_RegisterRt,
						output PC_write_en, IFID_write_en, Control_mux);

	assign S1 =(IDEX_Memread & ((IDEX_RegisterRt==IFID_RegisterRs) | (IDEX_RegisterRt==IFID_RegisterRt)))? 1'b1 : 1'b0;
	//stall  lw -> add

	assign S2 = ((IFID_opcode == 4'b1100) & IDEX_Flag_en)? 1'b1 : 1'b0;
	//any instruction change Flag -> B

	assign S3 = ( (IFID_opcode == 4'b1101) & ( IDEX_Flag_en |
	((IDEX_opcode!=4'b1110)&(IFID_RegisterRs == IDEX_RegisterRd))|
	(IDEX_Memread & (IFID_RegisterRs == IDEX_RegisterRt))))? 1'b1 : 1'b0;
	// add -> Br or any instruction change Flag -> Br (pcs)

	assign S4 = ((IFID_opcode == 4'b1101) & (EXMEM_Memread & (IFID_RegisterRs==EXMEM_RegisterRt)))? 1'b1 : 1'b0;

	assign stall = S1|S2|S3|S4;
	assign PC_write_en = (stall==1)? 1'b0 : 1'b1;
	assign IFID_write_en = (stall==1)? 1'b0 : 1'b1;
	assign Control_mux = (stall==1)? 1'b0 : 1'b1;
endmodule
