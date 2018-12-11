//Data Array of 128 cache blocks
//Each block will have 8 words
//BlockEnable and WordEnable are one-hot
//WriteEnable is one on writes and zero on reads
//**************************************************************LRU4 ways version********************************************************************//
module DataArray(input clk, input rst, input [15:0] DataIn, input [3:0] Write, input [31:0] BlockEnable, input [7:0] WordEnable, output [63:0] DataOut);
	Block blk[31:0]( .clk(clk), .rst(rst), .Din(DataIn), .WriteEnable(Write), .Enable(BlockEnable), .WordEnable(WordEnable), .Dout(DataOut));
endmodule

//64 byte (8 word) cache block
module Block( input clk,  input rst, input [15:0] Din, input [3:0] WriteEnable, input Enable, input [7:0] WordEnable, output [63:0] Dout);
	wire [7:0] WordEnable_real;
	assign WordEnable_real = {8{Enable}} & WordEnable; //Only for the enabled cache block, you enable the specific word
	DWord dw1[7:0]( .clk(clk), .rst(rst), .Din(Din), .WriteEnable(WriteEnable[3]), .Enable(WordEnable_real), .Dout(Dout[63:48]));
	DWord dw2[7:0]( .clk(clk), .rst(rst), .Din(Din), .WriteEnable(WriteEnable[2]), .Enable(WordEnable_real), .Dout(Dout[47:32]));
	DWord dw3[7:0]( .clk(clk), .rst(rst), .Din(Din), .WriteEnable(WriteEnable[1]), .Enable(WordEnable_real), .Dout(Dout[31:16]));
	DWord dw4[7:0]( .clk(clk), .rst(rst), .Din(Din), .WriteEnable(WriteEnable[0]), .Enable(WordEnable_real), .Dout(Dout[15:0]));
endmodule


//Each word has 16 bits
module DWord( input clk,  input rst, input [15:0] Din, input WriteEnable, input Enable, output [15:0] Dout);
	DCell dc[15:0]( .clk(clk), .rst(rst), .Din(Din[15:0]), .WriteEnable(WriteEnable), .Enable(Enable), .Dout(Dout[15:0]));
endmodule


module DCell( input clk,  input rst, input Din, input WriteEnable, input Enable, output Dout);
	wire q;
	assign Dout = (Enable & ~WriteEnable) ? q:'bz;
	dff dffd(.q(q), .d(Din), .wen(Enable & WriteEnable), .clk(clk), .rst(rst));
endmodule
//********************************************************************************************4 way **************************************************************//
/*
module DataArray(input clk, input rst, input [15:0] DataIn, input [1:0] Write, input [63:0] BlockEnable, input [7:0] WordEnable, output [31:0] DataOut);
	Block blk[63:0]( .clk(clk), .rst(rst), .Din(DataIn), .WriteEnable(Write), .Enable(BlockEnable), .WordEnable(WordEnable), .Dout(DataOut));
endmodule

//64 byte (8 word) cache block
module Block( input clk,  input rst, input [15:0] Din, input [1:0] WriteEnable, input Enable, input [7:0] WordEnable, output [31:0] Dout);
	wire [7:0] WordEnable_real;
	assign WordEnable_real = {8{Enable}} & WordEnable; //Only for the enabled cache block, you enable the specific word
	DWord dw1[7:0]( .clk(clk), .rst(rst), .Din(Din), .WriteEnable(WriteEnable[1]), .Enable(WordEnable_real), .Dout(Dout[31:16]));
	DWord dw2[7:0]( .clk(clk), .rst(rst), .Din(Din), .WriteEnable(WriteEnable[0]), .Enable(WordEnable_real), .Dout(Dout[15:0]));
endmodule


//Each word has 16 bits
module DWord( input clk,  input rst, input [15:0] Din, input WriteEnable, input Enable, output [15:0] Dout);
	DCell dc[15:0]( .clk(clk), .rst(rst), .Din(Din[15:0]), .WriteEnable(WriteEnable), .Enable(Enable), .Dout(Dout[15:0]));
endmodule


module DCell( input clk,  input rst, input Din, input WriteEnable, input Enable, output Dout);
	wire q;
	assign Dout = (Enable & ~WriteEnable) ? q:'bz;
	dff dffd(.q(q), .d(Din), .wen(Enable & WriteEnable), .clk(clk), .rst(rst));
endmodule
*/