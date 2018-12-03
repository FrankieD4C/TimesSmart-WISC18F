//Tag Array of 128  blocks
//Each block will have 1 byte
//BlockEnable is one-hot
//WriteEnable is one on writes and zero on reads

//change data out to 16 bits for parallel read, and 2 bit for write, 2 package of tag, valid , LRU output
module MetaDataArray(input clk, input rst_n, input [7:0] DataIn, input [1:0] Write, input [1:0] hit, input [63:0] BlockEnable, output [15:0] DataOut);
		
	MBlock Mblk[63:0]( .clk(clk), .rst_n(rst_n), .Din(DataIn), .WriteEnable(Write), .blockhit(hit[1:0]), .Enable(BlockEnable), .Dout(DataOut[15:0]));
endmodule

module MBlock( input clk,  input rst_n, input [7:0] Din, input [1:0] WriteEnable, input [1:0] blockhit, input Enable, output [15:0] Dout);
	wire [15:0] pre_Din; // store the previous lru value
	wire [7:0] Din1, Din2; // real value write into the block
	wire [1:0] write;
	reg [1:0] int_write;
	reg[7:0] int_Din1, int_Din2;
	always @* begin
		casex({WriteEnable, blockhit, Enable}) // read & hit, write
		default: begin int_write = 2'b00; int_Din1 = 8'b0; int_Din2 = 8'b0; end
		5'b00_10_1: begin int_write = 2'b11; int_Din1 = {pre_Din[15], 1'b1, pre_Din[13:8]}; int_Din2 = {pre_Din[7], 1'b0, pre_Din[5:0]}; end
		5'b00_01_1: begin int_write = 2'b11; int_Din1 = {pre_Din[15], 1'b0, pre_Din[13:8]}; int_Din2 = {pre_Din[7], 1'b1, pre_Din[5:0]}; end
		5'b10_??_1: begin int_write = 2'b11; int_Din1 = Din[7:0];  int_Din2 = {pre_Din[7], 1'b0, pre_Din[5:0]}; end
		5'b01_??_1: begin int_write = 2'b11; int_Din1 = {pre_Din[15], 1'b0, pre_Din[13:8]};  int_Din2 = Din[7:0]; end
		endcase	
	end
	assign write = int_write;
	assign Din1 = int_Din1;
	assign Din2 = int_Din2;	
	MCell mc1[7:0]( .clk(clk), .rst_n(rst_n), .Din(Din1), .WriteEnable(write[1]), .Enable(Enable), .Dout(Dout[15:8])); // 1st way
	MCell mc2[7:0]( .clk(clk), .rst_n(rst_n), .Din(Din2), .WriteEnable(write[0]), .Enable(Enable), .Dout(Dout[7:0])); // 2nd way
	assign pre_Din = Dout;
	//dff store[15:0] (.q(pre_Din[15:0]), .d(Dout[15:0]), .wen(1'b1), .clk(clk), .rst(rst_n));
endmodule

module MCell( input clk,  input rst_n, input Din, input WriteEnable, input Enable, output Dout);
	wire q;
	assign Dout = (Enable) ? q :'bz; //(Enable & ~WriteEnable) ? q//:'bz;
	dff dffm(.q(q), .d(Din), .wen(Enable & WriteEnable), .clk(clk), .rst(rst_n));
	//the stall signal will reset all the unnecessary data
endmodule

