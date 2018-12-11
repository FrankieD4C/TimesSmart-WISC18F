module convert5to32 (in, out);
	input [4:0] in;
	output [31:0] out;

	reg [31:0] trans;

	always @(*) begin
		case(in)
		default: trans = 31'b0;
		5'd0: trans = 31'b1;
		5'd1: trans = 31'b1 << 1;
		5'd2: trans = 31'b1 << 2;
		5'd3: trans = 31'b1 << 3;
		5'd4: trans = 31'b1 << 4;
		5'd5: trans = 31'b1 << 5;
		5'd6: trans = 31'b1 << 6;
		5'd7: trans = 31'b1 << 7;
		5'd8: trans = 31'b1 << 8;
		5'd9: trans = 31'b1 << 9;
		5'd10: trans = 31'b1 << 10;
		5'd11: trans = 31'b1 << 11;
		5'd12: trans = 31'b1 << 12;
		5'd13: trans = 31'b1 << 13;
		5'd14: trans = 31'b1 << 14;
		5'd15: trans = 31'b1 << 15;
		5'd16: trans = 31'b1 << 16;
		5'd17: trans = 31'b1 << 17;
		5'd18: trans = 31'b1 << 18;
		5'd19: trans = 31'b1 << 19;
		5'd20: trans = 31'b1 << 20;
		5'd21: trans = 31'b1 << 21;
		5'd22: trans = 31'b1 << 22;
		5'd23: trans = 31'b1 << 23;
		5'd24: trans = 31'b1 << 24;
		5'd25: trans = 31'b1 << 25;
		5'd26: trans = 31'b1 << 26;
		5'd27: trans = 31'b1 << 27;
		5'd28: trans = 31'b1 << 28;
		5'd29: trans = 31'b1 << 29;
		5'd30: trans = 31'b1 << 30;
		5'd31: trans = 31'b1 << 31;
		endcase
	end
	
	assign out = trans;
endmodule
