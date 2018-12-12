module convert3to8(in,out);

	input [2:0] in;
	output [7:0] out;
	
	reg [7:0] trans;
	always @*
	begin
		case(in)
		default: trans = 8'd0;
		3'b000: trans = 8'd1;
		3'b001: trans = 8'd2;
		3'b010: trans = 8'd4;
		3'b011: trans = 8'd8;
		3'b100: trans = 8'd16;
		3'b101: trans = 8'd32;
		3'b110: trans = 8'd64;
		3'b111: trans = 8'd128;
		endcase
	end
	
	assign out = trans;
endmodule
