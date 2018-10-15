module WriteDecoder_4_16(input [3:0] RegId, 
			 input WriteReg, 
			 output [15:0] Wordline); 

	reg [15:0] int_Word;
	
	always @* case(RegId)
	default: int_Word = 16'b0; // or should define high z?
	4'b0000: int_Word = 16'd1; // if input are no data, can't open any register, 
	4'b0001: int_Word  =16'd2;
	4'b0010: int_Word  =16'd4;
	4'b0011: int_Word  =16'd8;
	4'b0100: int_Word  =16'd16;
	4'b0101: int_Word  =16'd32;
	4'b0110: int_Word  =16'd64;
	4'b0111: int_Word  =16'd128;
	4'b1000: int_Word  =16'd256;
	4'b1001: int_Word  =16'd512;
	4'b1010: int_Word  =16'd1024;
	4'b1011: int_Word  =16'd2048;
	4'b1100: int_Word  =16'd4096;
	4'b1101: int_Word  =16'd8192;
	4'b1110: int_Word  =16'd16384;
	4'b1111: int_Word  =16'd32768;
	endcase

	assign Wordline = (WriteReg == 1) ? int_Word: 16'b0;


endmodule
