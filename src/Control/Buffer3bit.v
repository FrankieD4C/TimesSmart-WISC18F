module Buffer3bit(clk, rst_n, flag, Writenable, brc);

	input clk, rst_n;
	input [2:0] flag;
	input Writenable;
	output [2:0] brc;
	wire[2:0] int_Out;
	dff buffer[2:0] (.q(int_Out), .d(flag), .wen(Writeenable), .clk(clk), .rst(rst_n));
	assign brc = int_Out;

endmodule
