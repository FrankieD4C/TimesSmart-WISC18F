`include "Register/Register.v"
`include "Register/BitCell.v"
`include "Register/ReadDecoder_4_16.v"
`include "Register/ReadDecoder2_4_16.v"
`include "Register/WriteDecoder_4_16.v"
`include "Register/D-Flip-Flop.v"

 module RegisterFile(	input clk,
		input rst,
		input [3:0] SrcReg1,
		input [3:0] SrcReg2,
		input [3:0] DstReg,
		input WriteReg,
		input [15:0] DstData,
		inout [15:0] SrcData1,
		inout [15:0] SrcData2); // as output, receive from regi, regi no reg, only define reg which module the inout signal from, in this case, its from DFF


		wire [15:0] Write_ID, Read_ID, Read_ID2, temp_data;
		wire [15:0] int_Src1, int_Src2;

		WriteDecoder_4_16 WUT(.RegId (DstReg),
			 	  .WriteReg(WriteReg),
			 	  .Wordline(Write_ID));

		ReadDecoder_4_16 RUT(.RegId (SrcReg1),
			 	     .Wordline(Read_ID));

		ReadDecoder2_4_16 RUT2(.RegId (SrcReg2),
			 	   .Wordline (Read_ID2));

		assign SrcData1 = (WriteReg == 1 && DstReg == SrcReg1)? DstData: int_Src1;
		assign SrcData2 = (WriteReg == 1 && DstReg == SrcReg2)? DstData: int_Src2;

		Register REUT[15:0] (.clk(clk),
					.rst(rst),
					.D(DstData),
					.WriteReg(Write_ID[15:0]),
					.ReadEnable1(Read_ID[15:0]),
					.ReadEnable2(Read_ID2[15:0]),
					.Bitline1(int_Src1[15:0]),
					.Bitline2(int_Src2[15:0]));

/*
		wire [3:0] int_Reg;
		wire [15:0] Write_ID, Read_ID, int_Enable; // enable the particular register
		wire [15:0] int_Src1, int_Src2; // must be wire between module connection



		WriteDecoder_4_16 WUT(.RegId (int_Reg),
			 	  .WriteReg(WriteReg),
			 	  .Wordline(Write_ID));

		ReadDecoder_4_16 RUT(.RegId (SrcReg1),
			 	     .Wordline(Read_ID));


		assign int_Reg = (WriteReg == 0)? SrcReg2:DstReg;
		assign int_Enable = (WriteReg == 1)? Write_ID:0;
		assign SrcData1 = (WriteReg == 1 && DstReg == SrcReg1)? DstData: int_Src1;
		assign SrcData2 = (WriteReg == 1 && DstReg == SrcReg2)? DstData: int_Src2;



		Register REUT15 (.clk(clk),
					.rst(rst),
					.D(DstData),
					.WriteReg(Write_ID[15]),
					.ReadEnable1(Read_ID[15]),
					.ReadEnable2(Write_ID[15]),
					.Bitline1(int_Src1[15:0]),
					.Bitline2(int_Src2[15:0]));
		Register REUT14 (.clk(clk),
					.rst(rst),
					.D(DstData),
					.WriteReg(Write_ID[14]),
					.ReadEnable1(Read_ID[14]),
					.ReadEnable2(Write_ID[14]),
					.Bitline1(int_Src1[15:0]),
					.Bitline2(int_Src2[15:0]));
		Register REUT13 (.clk(clk),
					.rst(rst),
					.D(DstData),
					.WriteReg(Write_ID[13]),
					.ReadEnable1(Read_ID[13]),
					.ReadEnable2(Write_ID[13]),
					.Bitline1(int_Src1[15:0]),
					.Bitline2(int_Src2[15:0]));
		Register REUT12 (.clk(clk),
					.rst(rst),
					.D(DstData),
					.WriteReg(Write_ID[12]),
					.ReadEnable1(Read_ID[12]),
					.ReadEnable2(Write_ID[12]),
					.Bitline1(int_Src1[15:0]),
					.Bitline2(int_Src2[15:0]));
		Register REUT11 (.clk(clk),
					.rst(rst),
					.D(DstData),
					.WriteReg(Write_ID[11]),
					.ReadEnable1(Read_ID[11]),
					.ReadEnable2(Write_ID[11]),
					.Bitline1(int_Src1[15:0]),
					.Bitline2(int_Src2[15:0]));
		Register REUT10 (.clk(clk),
					.rst(rst),
					.D(DstData),
					.WriteReg(Write_ID[10]),
					.ReadEnable1(Read_ID[10]),
					.ReadEnable2(Write_ID[10]),
					.Bitline1(int_Src1[15:0]),
					.Bitline2(int_Src2[15:0]));
		Register REUT9 (.clk(clk),
					.rst(rst),
					.D(DstData),
					.WriteReg(Write_ID[9]),
					.ReadEnable1(Read_ID[9]),
					.ReadEnable2(Write_ID[9]),
					.Bitline1(int_Src1[15:0]),
					.Bitline2(int_Src2[15:0]));
		Register REUT8 (.clk(clk),
					.rst(rst),
					.D(DstData),
					.WriteReg(Write_ID[8]),
					.ReadEnable1(Read_ID[8]),
					.ReadEnable2(Write_ID[8]),
					.Bitline1(int_Src1[15:0]),
					.Bitline2(int_Src2[15:0]));
		Register REUT7 (.clk(clk),
					.rst(rst),
					.D(DstData),
					.WriteReg(Write_ID[7]),
					.ReadEnable1(Read_ID[7]),
					.ReadEnable2(Write_ID[7]),
					.Bitline1(int_Src1[15:0]),
					.Bitline2(int_Src2[15:0]));
		Register REUT6 (.clk(clk),
					.rst(rst),
					.D(DstData),
					.WriteReg(Write_ID[6]),
					.ReadEnable1(Read_ID[6]),
					.ReadEnable2(Write_ID[6]),
					.Bitline1(int_Src1[15:0]),
					.Bitline2(int_Src2[15:0]));
		Register REUT5 (.clk(clk),
					.rst(rst),
					.D(DstData),
					.WriteReg(Write_ID[5]),
					.ReadEnable1(Read_ID[5]),
					.ReadEnable2(Write_ID[5]),
					.Bitline1(int_Src1[15:0]),
					.Bitline2(int_Src2[15:0]));
		Register REUT4 (.clk(clk),
					.rst(rst),
					.D(DstData),
					.WriteReg(Write_ID[4]),
					.ReadEnable1(Read_ID[4]),
					.ReadEnable2(Write_ID[4]),
					.Bitline1(int_Src1[15:0]),
					.Bitline2(int_Src2[15:0]));
		Register REUT3 (.clk(clk),
					.rst(rst),
					.D(DstData),
					.WriteReg(Write_ID[3]),
					.ReadEnable1(Read_ID[3]),
					.ReadEnable2(Write_ID[3]),
					.Bitline1(int_Src1[15:0]),
					.Bitline2(int_Src2[15:0]));
		Register REUT2 (.clk(clk),
					.rst(rst),
					.D(DstData),
					.WriteReg(Write_ID[2]),
					.ReadEnable1(Read_ID[2]),
					.ReadEnable2(Write_ID[2]),
					.Bitline1(int_Src1[15:0]),
					.Bitline2(int_Src2[15:0]));
		Register REUT1 (.clk(clk),
					.rst(rst),
					.D(DstData),
					.WriteReg(Write_ID[1]),
					.ReadEnable1(Read_ID[1]),
					.ReadEnable2(Write_ID[1]),
					.Bitline1(int_Src1[15:0]),
					.Bitline2(int_Src2[15:0]));
		Register REUT0 (.clk(clk),
					.rst(rst),
					.D(DstData),
					.WriteReg(Write_ID[0]),
					.ReadEnable1(Read_ID[0]),
					.ReadEnable2(Write_ID[0]),
					.Bitline1(int_Src1[15:0]),
					.Bitline2(int_Src2[15:0]));


*/

endmodule
/*
module WriteDecoder_4_16(input [3:0] RegId,
			 input WriteReg,
			 output [15:0] Wordline);*/
/*module ReadDecoder_4_16 (input [3:0] RegId,
			 output [15:0] Wordline);*/
/*module Register(input clk,
		input rst,
		input [15:0] D,
		input WriteReg,
		input ReadEnable1,
		input ReadEnable2,
		inout [15:0] Bitline1,
		inout [15:0] Bitline2); // as output, inout of bitcell as input need, reg */