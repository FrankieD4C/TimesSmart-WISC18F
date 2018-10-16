//`include "ALU/Sll_Shift.v"
//`include "ALU/Ror_Shift.v"
//`include "ALU/Sra_Shift.v"

module Shift(Shift_Out, Shift_In, Shift_Val, Mode);
	input wire [15:0] Shift_In;
	input wire [3:0] Shift_Val;
	input wire [1:0] Mode;
	output wire [15:0] Shift_Out;

	wire [15:0] Sll_Out, Sra_Out, Ror_Out;


//00:sll, 01:sra, 10:ror;
	Sll_Shift SLUT(.In(Shift_In),
		 .Value(Shift_Val),
		 .Out(Sll_Out));
	Sra_Shift SRUT(.In(Shift_In),
		.Value(Shift_Val),
		.Out(Sra_Out));
	Ror_Shift ROUT(.In(Shift_In),
		.Value(Shift_Val),
		.Out(Ror_Out));
	//assign int_In = Shift_In;
	assign Shift_Out = (Mode == 2'b00)? Sll_Out:
			(Mode == 2'b01)? Sra_Out:
			(Mode == 2'b10)? Ror_Out: Shift_In;//int_In;


endmodule
