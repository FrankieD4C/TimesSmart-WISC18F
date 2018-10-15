module BitCell( input clk,  
		input rst, 
		input D, 
		input WriteEnable, 
		input ReadEnable1, 
		input ReadEnable2, 
		inout Bitline1, 
		inout Bitline2); 

	wire int_q; // cant be reg, between different level module connection
	
	dff Bit(.q(int_q), .d(D), .wen(WriteEnable), .clk(clk), .rst(rst));
	assign Bitline1 = (ReadEnable1 == 1)? int_q: 1'bz;
	assign Bitline2 = (ReadEnable2 == 1)? int_q: 1'bz; // not sure
	
endmodule
//module dff (q, d, wen, clk, rst);