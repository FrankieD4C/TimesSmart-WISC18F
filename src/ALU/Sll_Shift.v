module Sll_Shift(input [15:0] In,
		input [3:0] Value,
		output [15:0] Out);
/*	
	wire [15:0] data1, data2, data3, data4;

	assign data1 = (Value[0] == 1)? (In << 1) : In;
	assign data2 = (Value[1] == 1)? (data1 << 2) : data1;
	assign data3 = (Value[2] == 1)? (data2 << 4) : data2;
	assign data4 = (Value[3] == 1)? (data3 << 8) : data3;
	
	assign Out = data4;
*/
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
