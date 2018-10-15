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
