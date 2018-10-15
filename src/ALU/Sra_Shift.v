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
