module Branch(input Branch_enable, input [2:0] C, input [2:0] F, output J_out);
	reg J;

	always@* case(C)
	default: J=0;
	3'b000: begin J= (F[2]==0)? 1:0; end //neq
	3'b001: begin J= (F[2]==1)? 1:0; end //eq
	3'b010: begin J= ((F[2]==0)? 1:0)&((F[0]==0)? 1:0); end //greater than
	3'b011: begin J= (F[0]==1)? 1:0; end//less than
	3'b100: begin J= ((F[2]==1)? 1:0)|(((F[2]==0)? 1:0)&((F[0]==0)? 1:0)); end //greater than or equal
	3'b101: begin J= ((F[2]==1)? 1:0)|((F[0]==1)? 1:0); end // less than or equal
	3'b110: begin J= (F[1]==1)? 1:0; end //overflow
	3'b111: begin J=1; end //unconditional
	endcase

	assign J_out = (Branch_enable) ? J : 0;
	//assign PC_out= (((J==1)&(Branch_enable==1))? (PC_jump):(PC_in));
endmodule
//module adder_16bit(input [15:0]a, input [15:0] b, output [15:0] sum, output Ovfl);
