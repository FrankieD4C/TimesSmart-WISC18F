//Tag Array of 128  blocks
//Each block will have 1 byte
//BlockEnable is one-hot
//WriteEnable is one on writes and zero on reads

//change data out to 16 bits for parallel read, and 2 bit for write, 2 package of tag, valid , LRU output
//***************************************************************4 way associative cache**********************************************************//
//not good, try to compare the value of LRU!!
// index decrease to 5 bit, tag 7 bit, 2 bit lru 1 bit valid
/*
module MetaDataArray(input clk, input rst_n, input [9:0] DataIn, input [3:0] Write, input [3:0] hit, input [31:0] BlockEnable, output [39:0] DataOut);
		
	MBlock Mblk[31:0]( .clk(clk), .rst_n(rst_n), .Din(DataIn), .WriteEnable(Write), .blockhit(hit[3:0]), .Enable(BlockEnable), .Dout(DataOut[39:0]));
endmodule
 // partial working version
module MBlock( input clk,  input rst_n, input [9:0] Din, input [3:0] WriteEnable, input [3:0] blockhit, input Enable, output [39:0] Dout);
	wire [39:0] pre_Din; // store the previous lru value
	wire [9:0] Din1, Din2, Din3, Din4; // real value write into the block
//	reg[8:0] int_Din1, int_Din2, int_Din3, int_Din4;
	reg [1:0] LRU1, LRU2, LRU3, LRU4;
	always @(posedge clk) begin
	if(~rst_n)
	begin
		LRU1 = 0; LRU2 = 0; LRU3 = 0; LRU4 = 0;
	end
	else
	begin	
		if(WriteEnable && Enable)
		begin
			if(WriteEnable[3]) // 1st hit
			begin
				LRU1 = Din[8:7]; LRU2 = (LRU2==0)? 2'b00:(LRU2-1); LRU3 = (LRU3 == 0)? 2'b00:(LRU3-1); LRU4 = (LRU4 == 0)? 2'b00:(LRU4-1);
			end
			else if(WriteEnable[2])
			begin
				LRU2 = Din[8:7]; LRU1 = (LRU1==0)? 2'b00:(LRU1-1); LRU3 = (LRU3 == 0)? 2'b00:(LRU3-1); LRU4 = (LRU4 == 0)? 2'b00:(LRU4-1);				
			end
			else if(WriteEnable[1])
			begin
				LRU3 = Din[8:7]; LRU1 = (LRU1==0)? 2'b00:(LRU1-1); LRU2 = (LRU2 == 0)? 2'b00:(LRU2-1); LRU4 = (LRU4 == 0)? 2'b00:(LRU4-1);
			end
			else
			begin
				LRU4 = Din[8:7]; LRU1 = (LRU1==0)? 2'b00:(LRU1-1); LRU2 = (LRU2 == 0)? 2'b00:(LRU2-1); LRU3 = (LRU3 == 0)? 2'b00:(LRU3-1);
			end

		end
		else if(blockhit && Enable)// read
		begin
			if(blockhit[3]) // 1st hit
			begin
				LRU1 = 2'b11; LRU2 = (LRU2==0)? 2'b00:(LRU2-1); LRU3 = (LRU3==0)? 2'b00:(LRU3-1); LRU4 = (LRU4==0)? 2'b00:(LRU4-1);
			end
			else if(blockhit[2])
			begin
				LRU2 = 2'b11; LRU1 = (LRU1==0)? 2'b00:(LRU1-1); LRU3 = (LRU3==0)? 2'b00:(LRU3-1); LRU4 = (LRU4==0)? 2'b00:(LRU4-1);
			end
			else if(blockhit[1])
			begin
				LRU3 = 2'b11; LRU1 = (LRU1==0)? 2'b00:(LRU1-1); LRU2 = (LRU2==0)? 2'b00:(LRU2-1); LRU4 = (LRU4==0)? 2'b00:(LRU4-1);
			end
			else
			begin
				LRU4 = 2'b11; LRU1 = (LRU1==0)? 2'b00:(LRU1-1); LRU2 = (LRU2==0)? 2'b00:(LRU2-1); LRU3 = (LRU3==0)? 2'b00:(LRU3-1);
			end
		end
		else
		begin
			LRU1 = LRU1; LRU2 = LRU2; LRU3 = LRU3; LRU4 = LRU4;	 // if no write & no hit			
		end
	end
	end
//	assign write = int_write;
	assign Din1 = (WriteEnable[3]) ? Din : {pre_Din[39], LRU1[1:0], pre_Din[36:30]};
	assign Din2 = (WriteEnable[2]) ? Din : {pre_Din[29], LRU2[1:0], pre_Din[26:20]};
	assign Din3 = (WriteEnable[1]) ? Din : {pre_Din[19], LRU3[1:0], pre_Din[16:10]};
	assign Din4 = (WriteEnable[0]) ? Din : {pre_Din[9], LRU4[1:0], pre_Din[6:0]};
	MCell mc1[9:0]( .clk(clk), .rst_n(rst_n), .Din(Din1), .WriteEnable(1'b1), .Enable(Enable), .Dout(Dout[39:30])); // 1st way
	MCell mc2[9:0]( .clk(clk), .rst_n(rst_n), .Din(Din2), .WriteEnable(1'b1), .Enable(Enable), .Dout(Dout[29:20])); // 2nd way
	MCell mc3[9:0]( .clk(clk), .rst_n(rst_n), .Din(Din3), .WriteEnable(1'b1), .Enable(Enable), .Dout(Dout[19:10])); // 1st way
	MCell mc4[9:0]( .clk(clk), .rst_n(rst_n), .Din(Din4), .WriteEnable(1'b1), .Enable(Enable), .Dout(Dout[9:0])); // 2nd way
	assign pre_Din = Dout;
	//dff store[15:0] (.q(pre_Din[15:0]), .d(Dout[15:0]), .wen(1'b1), .clk(clk), .rst(rst_n));
endmodule
*/
//*************************************************************************************************4WAY**************************//

/*
module MBlock( input clk,  input rst_n, input [8:0] Din, input [3:0] WriteEnable, input [3:0] blockhit, input Enable, output [35:0] Dout);
	wire [35:0] pre_Din; // store the previous lru value
	wire [8:0] Din1, Din2, Din3, Din4; // real value write into the block
//	reg[8:0] int_Din1, int_Din2, int_Din3, int_Din4;
	reg [1:0] LRU1, LRU2, LRU3, LRU4;
	always @(posedge clk) begin
	if(~rst_n)
	begin
		LRU1 = 0; LRU2 = 0; LRU3 = 0; LRU4 = 0;
	end
	else
	begin	
		if(WriteEnable && Enable)
		begin
			if(WriteEnable[3]) // 1st hit
			begin
				LRU1 = Din[7:6]; LRU2 = (LRU2==0)? 2'b00:(LRU3&&LRU4)? (LRU2-1):LRU2; LRU3 = (LRU3 == 0)? 2'b00:(LRU2&&LRU4)? (LRU3-1):LRU3; LRU4 = (LRU4 == 0)? 2'b00:(LRU2&&LRU3)? (LRU4-1):LRU4;
			end
			else if(WriteEnable[2])
			begin
				LRU2 = Din[7:6]; LRU1 = (LRU1==0)? 2'b00:(LRU3&&LRU4)? (LRU1-1):LRU1; LRU3 = (LRU3 == 0)? 2'b00:(LRU1&&LRU4)? (LRU3-1):LRU3; LRU4 = (LRU4 == 0)? 2'b00:(LRU1&&LRU3)? (LRU4-1):LRU4;				
			end
			else if(WriteEnable[1])
			begin
				LRU3 = Din[7:6]; LRU1 = (LRU1==0)? 2'b00:(LRU2&&LRU4)? (LRU1-1):LRU1; LRU2 = (LRU2 == 0)? 2'b00:(LRU1&&LRU4)? (LRU2-1):LRU2; LRU4 = (LRU4 == 0)? 2'b00:(LRU1&&LRU2)? (LRU4-1):LRU4;
			end
			else
			begin
				LRU4 = Din[7:6]; LRU1 = (LRU1==0)? 2'b00:(LRU2&&LRU3)? (LRU1-1):LRU1; LRU2 = (LRU2 == 0)? 2'b00:(LRU1&&LRU3)? (LRU2-1):LRU2; LRU3 = (LRU3 == 0)? 2'b00:(LRU1&&LRU2)? (LRU3-1):LRU3;
			end

		end
		else if(blockhit && Enable)// read
		begin
			if(blockhit[3]) // 1st hit
			begin
				LRU1 = 2'b11; LRU2 = (LRU2==0)? 2'b00:((LRU3&&LRU4)|(LRU2 == 2'b11))? (LRU2-1):LRU2; LRU3 = (LRU3==0)? 2'b00:((LRU2&&LRU4)|(LRU3 == 2'b11))? (LRU3-1):LRU3; LRU4 = (LRU4==0)? 2'b00:((LRU2&&LRU3)|(LRU4 == 2'b11))? (LRU4-1):LRU4;
			end
			else if(blockhit[2])
			begin
				LRU2 = 2'b11; LRU1 = (LRU1==0)? 2'b00:((LRU3&&LRU4)|(LRU1 == 2'b11))? (LRU1-1):LRU1; LRU3 = (LRU3==0)? 2'b00:((LRU1&&LRU4)|(LRU3 == 2'b11))? (LRU3-1):LRU3; LRU4 = (LRU4==0)? 2'b00:((LRU1&&LRU3)|(LRU4 == 2'b11))? (LRU4-1):LRU4;
			end
			else if(blockhit[1])
			begin
				LRU3 = 2'b11; LRU1 = (LRU1==0)? 2'b00:((LRU2&&LRU4)|(LRU1 == 2'b11))? (LRU1-1):LRU1; LRU2 = (LRU2==0)? 2'b00:((LRU1&&LRU4)|(LRU2 == 2'b11))? (LRU2-1):LRU2; LRU4 = (LRU4==0)? 2'b00:((LRU1&&LRU2)|(LRU4 == 2'b11))? (LRU4-1):LRU4;
			end
			else
			begin
				LRU4 = 2'b11; LRU1 = (LRU1==0)? 2'b00:((LRU2&&LRU3)|(LRU1 == 2'b11))? (LRU1-1):LRU1; LRU2 = (LRU2==0)? 2'b00:((LRU1&&LRU3)|(LRU2 == 2'b11))? (LRU2-1):LRU2; LRU3 = (LRU3==0)? 2'b00:((LRU1&&LRU2)|(LRU3 == 2'b11))? (LRU3-1):LRU3;
			end
		end
		else
		begin
			LRU1 = LRU1; LRU2 = LRU2; LRU3 = LRU3; LRU4 = LRU4;	 // if no write & no hit			
		end
	end
		/*
		casex({WriteEnable, blockhit, Enable}) // read & hit, write
		default: begin int_write = 2'b00; int_Din1 = 8'b0; int_Din2 = 8'b0; end
		5'b00_10_1: begin int_write = 2'b11; int_Din1 = {pre_Din[15], 1'b1, pre_Din[13:8]}; int_Din2 = {pre_Din[7], 1'b0, pre_Din[5:0]}; end
		5'b00_01_1: begin int_write = 2'b11; int_Din1 = {pre_Din[15], 1'b0, pre_Din[13:8]}; int_Din2 = {pre_Din[7], 1'b1, pre_Din[5:0]}; end
		5'b10_??_1: begin int_write = 2'b11; int_Din1 = Din[7:0];  int_Din2 = {pre_Din[7], 1'b0, pre_Din[5:0]}; end
		5'b01_??_1: begin int_write = 2'b11; int_Din1 = {pre_Din[15], 1'b0, pre_Din[13:8]};  int_Din2 = Din[7:0]; end
		endcase	*/
/*
	end
//	assign write = int_write;
	assign Din1 = (WriteEnable[3]) ? Din : {pre_Din[35], LRU1[1:0], pre_Din[32:27]};
	assign Din2 = (WriteEnable[2]) ? Din : {pre_Din[26], LRU2[1:0], pre_Din[23:18]};
	assign Din3 = (WriteEnable[1]) ? Din : {pre_Din[17], LRU3[1:0], pre_Din[14:9]};
	assign Din4 = (WriteEnable[0]) ? Din : {pre_Din[8], LRU4[1:0], pre_Din[5:0]};
	MCell mc1[8:0]( .clk(clk), .rst_n(rst_n), .Din(Din1), .WriteEnable(1'b1), .Enable(Enable), .Dout(Dout[35:27])); // 1st way
	MCell mc2[8:0]( .clk(clk), .rst_n(rst_n), .Din(Din2), .WriteEnable(1'b1), .Enable(Enable), .Dout(Dout[26:18])); // 2nd way
	MCell mc3[8:0]( .clk(clk), .rst_n(rst_n), .Din(Din3), .WriteEnable(1'b1), .Enable(Enable), .Dout(Dout[17:9])); // 1st way
	MCell mc4[8:0]( .clk(clk), .rst_n(rst_n), .Din(Din4), .WriteEnable(1'b1), .Enable(Enable), .Dout(Dout[8:0])); // 2nd way
	assign pre_Din = Dout;
	//dff store[15:0] (.q(pre_Din[15:0]), .d(Dout[15:0]), .wen(1'b1), .clk(clk), .rst(rst_n));
endmodule
*/


module MetaDataArray_old(input clk, input rst_n, input [7:0] DataIn, input [1:0] Write, input [1:0] hit, input [63:0] BlockEnable, output [15:0] DataOut);
		
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

`timescale 1ns/ 1ps
module tb_MetaDataArray();
	localparam CHECK_DELAY = 0.1;
	localparam CLK_PERIOD = 5;
	
	reg tb_clk, tb_rst_n;
	reg [8:0] tb_DataIn;
	reg [3:0] tb_Write, tb_hit;
	reg [31:0] tb_Block_Enable;
	wire [35:0]tb_DataOut;
	integer test_num;
	always // set clock signal
	begin
		tb_clk = 1'b0;
		#(CLK_PERIOD / 2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD / 2.0);
	end
	MetaDataArray MUT(.clk(tb_clk), .rst_n(tb_rst_n), .DataIn(tb_DataIn), .Write(tb_Write), .hit(tb_hit), .BlockEnable(tb_Block_Enable), .DataOut(tb_DataOut));

	initial 
	begin
	@(negedge tb_clk);
	tb_rst_n = 0;
	test_num = 0;
	tb_DataIn = 0;
	tb_Write = 0;
	tb_Block_Enable = 0;
	tb_hit = 0;
	@(negedge tb_clk);
	tb_rst_n = 1;
	test_num = 1;
	@(negedge tb_clk);
	@(negedge tb_clk);
	@(negedge tb_clk); // 3 cycles do nothing
	test_num = 2; // read only
	@(negedge tb_clk);
	tb_Block_Enable = 32'b1;
	tb_hit = 4'b1000;
	@(negedge tb_clk);
	tb_hit = 4'b0100;
	@(negedge tb_clk);
	tb_hit = 4'b0010;
	@(negedge tb_clk);
	tb_hit = 4'b0001;
	@(negedge tb_clk);
	tb_hit = 4'b0100;
	@(negedge tb_clk);
	tb_DataIn = 9'b111000001;
	tb_Write = 4'b1000;
	@(negedge tb_clk);
	tb_DataIn = 9'b111000010;
	tb_Write = 4'b0100;
	@(negedge tb_clk);
	tb_DataIn = 9'b111000011;
	tb_Write = 4'b0010;
	@(negedge tb_clk);
	tb_DataIn = 9'b111000100;
	tb_Write = 4'b0001;
	@(negedge tb_clk);
	tb_DataIn = 9'b111010000;
	tb_Write = 4'b0100;
		
	
	
	
	end

endmodule