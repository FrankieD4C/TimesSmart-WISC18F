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
	assign Shift_Out = (Mode == 2'b00)? Sll_Out:
			(Mode == 2'b01)? Sra_Out:
			(Mode == 2'b10)? Ror_Out: Shift_In;//int_In;
endmodule

module Sll_Shift(input [15:0] In,
		input [3:0] Value,
		output [15:0] Out);

	wire [15:0] data1, data2, data3, temp_data;

	assign data1 = (Value[1:0] == 2'b01) ? (In << 1) :
			(Value[1:0] == 2'b10) ? (In << 2) : (In << 3);
	assign data2 = (Value[3:2] == 2'b01) ? (data1 << 4) :
			(Value[3:2] == 2'b10) ? (data1 << 8) : (data1 << 12);
	assign data3 = (Value[3:2] == 2'b01) ? (In << 4) :
			(Value[3:2] == 2'b10) ? (In << 8) : (In << 12);

	assign temp_data = (Value[1:0] != 0 && Value[3:2] != 0)?data2:
				(Value[1:0] != 0 && Value[3:2] == 0) ? data1: In;
	assign Out = (Value[1:0] == 0 && Value[3:2] != 0) ? data3:
			(Value[1:0] != 0 && Value[3:2] != 0) ? data2: temp_data;

endmodule

module Sra_Shift(input [15:0] In,
		input [3:0] Value,
		output [15:0] Out);
	wire [15:0] data1, data2, data3, data4, MSB1, MSB2, MSB3, MSB4, temp_data;
	assign data1 = (Value[1:0] == 2'b01) ? (In >> 1) :
			(Value[1:0] == 2'b10) ? (In >> 2) : (In >> 3);
	assign MSB1 = (Value[1:0] == 2'b01) ? {In[15], data1[14:0]} :
			(Value[1:0] == 2'b10) ? {{2{In[15]}}, data1[13:0]} : {{3{In[15]}}, data1[12:0]};
	assign data2 = (Value[3:2] == 2'b01) ? (MSB1 >> 4) :
			(Value[3:2] == 2'b10) ? (MSB1 >> 8) : (MSB1 >> 12);
	assign MSB2 = (Value[3:2] == 2'b01) ? {{4{MSB1[15]}}, data2[11:0]} :
			(Value[3:2] == 2'b10) ? {{8{MSB1[15]}}, data2[7:0]} : {{12{MSB1[15]}}, data2[3:0]};
	assign data3 = (Value[3:2] == 2'b01) ? (In >> 4) :
			(Value[3:2] == 2'b10) ? (In >> 8) : (In >> 12);
	assign MSB3 = (Value[3:2] == 2'b01) ? {{4{In[15]}}, data3[11:0]} :
			(Value[3:2] == 2'b10) ? {{8{In[15]}}, data3[7:0]} : {{12{In[15]}}, data3[3:0]};

	assign temp_data = (Value[1:0] != 0 && Value[3:2] != 0)?MSB2:
				(Value[1:0] != 0 && Value[3:2] == 0) ? MSB1: In;
	assign Out = (Value[1:0] == 0 && Value[3:2] != 0) ? MSB3:
			(Value[1:0] != 0 && Value[3:2] != 0) ? MSB2: temp_data;
endmodule

module Ror_Shift(input [15:0] In,
		input [3:0] Value,
		output [15:0] Out);
	wire [15:0] data1, data2, data3, data4, temp1, temp2, temp3, temp_data;

	assign data1 = (Value[1:0] == 2'b01) ? (In >> 1) :
			(Value[1:0] == 2'b10) ? (In >> 2) : (In >> 3);
	assign temp1 = (Value[1:0] == 2'b01) ? {In[0], data1[14:0]} :
			(Value[1:0] == 2'b10) ? {In[1:0], data1[13:0]} : {In[2:0], data1[12:0]};
	assign data2 = (Value[3:2] == 2'b01) ? (temp1 >> 4) :
			(Value[3:2] == 2'b10) ? (temp1 >> 8) : (temp1 >> 12);
	assign temp2 = (Value[3:2] == 2'b01) ? {temp1[3:0], data2[11:0]} :
			(Value[3:2] == 2'b10) ? {temp1[7:0], data2[7:0]} : {temp1[11:0], data2[3:0]};
	assign data3 = (Value[3:2] == 2'b01) ? (In >> 4) :
			(Value[3:2] == 2'b10) ? (In >> 8) : (In >> 12);
	assign temp3 = (Value[3:2] == 2'b01) ? {In[3:0], data3[11:0]} :
			(Value[3:2] == 2'b10) ? {In[7:0], data3[7:0]} : {In[11:0], data3[3:0]};

	assign temp_data = (Value[1:0] != 0 && Value[3:2] != 0)? temp2:
				(Value[1:0] != 0 && Value[3:2] == 0) ? temp1: In;
	assign Out = (Value[1:0] == 0 && Value[3:2] != 0) ? temp3:
			(Value[1:0] != 0 && Value[3:2] != 0) ? temp2: temp_data;

endmodule
