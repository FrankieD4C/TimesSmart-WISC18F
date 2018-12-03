module convert6to128 (in, out);
	input [5:0] in;
	output [63:0] out;

	reg [63:0] trans;

	always @(*) begin
		case(in)
		default: trans = 64'b0;
		6'd0: trans = 64'b1;
		6'd1: trans = 64'b1 << 1;
		6'd2: trans = 64'b1 << 2;
		6'd3: trans = 64'b1 << 3;
		6'd4: trans = 64'b1 << 4;
		6'd5: trans = 64'b1 << 5;
		6'd6: trans = 64'b1 << 6;
		6'd7: trans = 64'b1 << 7;
		6'd8: trans = 64'b1 << 8;
		6'd9: trans = 64'b1 << 9;
		6'd10: trans = 64'b1 << 10;
		6'd11: trans = 64'b1 << 11;
		6'd12: trans = 64'b1 << 12;
		6'd13: trans = 64'b1 << 13;
		6'd14: trans = 64'b1 << 14;
		6'd15: trans = 64'b1 << 15;
		6'd16: trans = 64'b1 << 16;
		6'd17: trans = 64'b1 << 17;
		6'd18: trans = 64'b1 << 18;
		6'd19: trans = 64'b1 << 19;
		6'd20: trans = 64'b1 << 20;
		6'd21: trans = 64'b1 << 21;
		6'd22: trans = 64'b1 << 22;
		6'd23: trans = 64'b1 << 23;
		6'd24: trans = 64'b1 << 24;
		6'd25: trans = 64'b1 << 25;
		6'd26: trans = 64'b1 << 26;
		6'd27: trans = 64'b1 << 27;
		6'd28: trans = 64'b1 << 28;
		6'd29: trans = 64'b1 << 29;
		6'd30: trans = 64'b1 << 30;
		6'd31: trans = 64'b1 << 31;
		6'd32: trans = 64'b1 << 32;
		6'd33: trans = 64'b1 << 33;
		6'd34: trans = 64'b1 << 34;
		6'd35: trans = 64'b1 << 35;
		6'd36: trans = 64'b1 << 36;
		6'd37: trans = 64'b1 << 37;
		6'd38: trans = 64'b1 << 38;
		6'd39: trans = 64'b1 << 39;
		6'd40: trans = 64'b1 << 40;
		6'd41: trans = 64'b1 << 41;
		6'd42: trans = 64'b1 << 42;
		6'd43: trans = 64'b1 << 43;
		6'd44: trans = 64'b1 << 44;
		6'd45: trans = 64'b1 << 45;
		6'd46: trans = 64'b1 << 46;
		6'd47: trans = 64'b1 << 47;
		6'd48: trans = 64'b1 << 48;
		6'd49: trans = 64'b1 << 49;
		6'd50: trans = 64'b1 << 50;
		6'd51: trans = 64'b1 << 51;
		6'd52: trans = 64'b1 << 52;
		6'd53: trans = 64'b1 << 53;
		6'd54: trans = 64'b1 << 54;
		6'd55: trans = 64'b1 << 55;
		6'd56: trans = 64'b1 << 56;
		6'd57: trans = 64'b1 << 57;
		6'd58: trans = 64'b1 << 58;
		6'd59: trans = 64'b1 << 59;
		6'd60: trans = 64'b1 << 60;
		6'd61: trans = 64'b1 << 61;
		6'd62: trans = 64'b1 << 62;
		6'd63: trans = 64'b1 << 63;
		endcase
	end
	
	assign out = trans;
endmodule

