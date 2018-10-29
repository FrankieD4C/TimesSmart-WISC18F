module Hazard_detection( input IDEX_Memread, IDEX_Flag_en,
	input [3:0] IFID_opcode, IDEX_opcode, IFID_RegisterRs, IFID_RegisterRt, 
	 IDEX_RegisterRd, EXMEM_Memread, 
	output PC_write_en, IFID_write_en, Control_mux);
	assign S1 =(IDEX_Memread & ((IDEX_RegisterRd==IFID_RegisterRs) | (IDEX_RegisterRd==IFID_RegisterRt)))? 1'b1:0;
	//stall  lw -> add

	assign S2 = ((IFID_opcode ==4'b1100) & IDEX_Flag_en)? 1'b1:0;
	//any instruction change Flag -> B

	assign S3 = ( (IFID_opcode ==4'b1101) & ( IDEX_Flag_en | 
	(IFID_RegisterRs == IDEX_RegisterRd)))? 1'b1:0;
	// add -> Br or any instruction change Flag -> Br 

	assign S4 = ((IFID_opcode ==4'b1101) & (IFID_RegisterRs==EXMEM_RegisterRd))? 1'b1:0;

	assign stall=S1|S2|S3|S4;
	assign PC_write_en = (stall==1)? 0:1'b1;
	assign IFID_write_en = (stall==1)? 0:1'b1;
	assign Control_mux = (stall==1)? 0: 1'b1;
endmodule
