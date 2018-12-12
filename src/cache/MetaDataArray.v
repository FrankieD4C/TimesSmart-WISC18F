//Tag Array of 128  blocks
//Each block will have 1 byte
//BlockEnable is one-hot
//WriteEnable is one on writes and zero on reads

//change data out to 16 bits for parallel read, and 2 bit for write, 2 package of tag, valid , LRU output
//***************************************************************4 way associative cache**********************************************************//
//not good, try to compare the value of LRU!!
// index decrease to 5 bit, tag 7 bit, 2 bit lru 1 bit valid

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

//*************************************************************************************************4WAY**************************//
