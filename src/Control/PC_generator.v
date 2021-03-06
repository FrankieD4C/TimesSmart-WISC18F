module PC_generator(clk, rst_n, PC_in, PC_out, PCwrite);

	input clk;
	input rst_n, PCwrite;
	input [15:0] PC_in;
	output [15:0] PC_out;

	dff PCmode[15:0] (.q(PC_out[15:0]), .d(PC_in[15:0]), .wen(PCwrite), .clk(clk), .rst(rst_n));

endmodule
