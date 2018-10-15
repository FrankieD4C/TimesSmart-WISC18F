//`include "full_adder_1bit.v"

module PADDSB_4b(A_4b, B_4b, Sum_4b);
    input [3:0] A_4b, B_4b;
    output [3:0] Sum_4b;
    wire [3:0] out_4b, CarryOut, p, g;
    wire ovfl;

    assign p = A_4b | B_4b;
    assign g = A_4b & B_4b;
    assign CarryOut[0] = g[0];
    assign CarryOut[1] = g[1]|(p[1]&g[0]);
    assign CarryOut[2] = g[2]|(p[2]&g[1])|(p[2]&p[1]&g[0]);

    full_adder_1bit FA0(.A(A_4b[0]), .B(B_4b[0]), .CarryIn(1'b0), .Sum(out_4b[0]), .CarryOut());
    full_adder_1bit FA1(.A(A_4b[1]), .B(B_4b[1]), .CarryIn(CarryOut[0]), .Sum(out_4b[1]), .CarryOut());
    full_adder_1bit FA2(.A(A_4b[2]), .B(B_4b[2]), .CarryIn(CarryOut[1]), .Sum(out_4b[2]), .CarryOut());
    full_adder_1bit FA3(.A(A_4b[3]), .B(B_4b[3]), .CarryIn(CarryOut[2]), .Sum(out_4b[3]), .CarryOut());
    assign ovfl = out_4b[3] & ~A_4b[3] & ~B_4b[3] | ~out_4b[3] & A_4b[3] & B_4b[3];
    assign Sum_4b = (ovfl) ? ((out_4b[3]) ? 4'b0111 : 4'b1000) : out_4b;

endmodule

module PADDSB(A, B, Sum);
    input[15:0] A, B;
    output[15:0] Sum;

    PADDSB_4b PD40(.A_4b(A[3:0]), .B_4b(B[3:0]), .Sum_4b(Sum[3:0]));
    PADDSB_4b PD41(.A_4b(A[7:4]), .B_4b(B[7:4]), .Sum_4b(Sum[7:4]));
    PADDSB_4b PD42(.A_4b(A[11:8]), .B_4b(B[11:8]), .Sum_4b(Sum[11:8]));
    PADDSB_4b PD43(.A_4b(A[15:12]), .B_4b(B[15:12]), .Sum_4b(Sum[15:12]));

endmodule