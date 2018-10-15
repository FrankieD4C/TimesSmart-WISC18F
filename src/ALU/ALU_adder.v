`include "ALU/full_adder_1bit.v"

module ALU_adder_4b(A, B, CarryIn, Sub, out_4b, P_4b, G_4b);
    input [3:0] A, B;
    input CarryIn, Sub;
    output [3:0] out_4b;
    output P_4b, G_4b;
    wire [3:0] p, g, Binvert, CarryOut;

    assign Binvert = (Sub) ? ~B : B;
    assign p = A | Binvert;
    assign g = A & Binvert;
    assign CarryOut[0] = g[0]|(p[0]&CarryIn);
    assign CarryOut[1] = g[1]|(p[1]&g[0])|(p[1]&p[0]&CarryIn);
    assign CarryOut[2] = g[2]|(p[2]&g[1])|(p[2]&p[1]&g[0])|(p[2]&p[1]&p[0]&CarryIn);
    assign P_4b = p[3]&p[2]&p[1]&p[0];
    assign G_4b = g[3]|(p[3]&g[2])|(p[3]&p[2]&g[1])|(p[3]&p[2]&p[1]&g[0]);

    full_adder_1bit FA0(.A(A[0]), .B(Binvert[0]), .CarryIn(CarryIn), .Sum(out_4b[0]), .CarryOut());
    full_adder_1bit FA1(.A(A[1]), .B(Binvert[1]), .CarryIn(CarryOut[0]), .Sum(out_4b[1]), .CarryOut());
    full_adder_1bit FA2(.A(A[2]), .B(Binvert[2]), .CarryIn(CarryOut[1]), .Sum(out_4b[2]), .CarryOut());
    full_adder_1bit FA3(.A(A[3]), .B(Binvert[3]), .CarryIn(CarryOut[2]), .Sum(out_4b[3]), .CarryOut());

endmodule

module ALU_adder(Adder_In1, Adder_In2, sub, sat, Adder_Out, Ovfl);

    input [15:0] Adder_In1, Adder_In2;
    input sub, sat;   // '+' : sub = 0;   '-' sub = 1; sat = 1 only when ADD&SUB
    output [15:0] Adder_Out;
    output Ovfl;
    wire [15:0] Sum;
    wire [3:0] P, G, C;

    assign C[0] = G[0]|(P[0]&sub);
    assign C[1] = G[1]|(P[1]&G[0])|(P[1]&P[0]&sub);
    assign C[2] = G[2]|(P[2]&G[1])|(P[2]&P[1]&G[0])|(P[2]&P[1]&P[0]&sub);
    assign C[3] = G[3]|(P[3]&G[2])|(P[3]&P[2]&G[1])|(P[3]&P[2]&P[1]&G[0])|(P[3]&P[2]&P[1]&P[0]&sub);
    ALU_adder_4b ALU0_4b(.A(Adder_In1[3:0]), .B(Adder_In2[3:0]), .CarryIn(sub), .Sub(sub),
                        .out_4b(Sum[3:0]), .P_4b(P[0]), .G_4b(G[0]));
    ALU_adder_4b ALU1_4b(.A(Adder_In1[7:4]), .B(Adder_In2[7:4]), .CarryIn(C[0]), .Sub(sub),
                        .out_4b(Sum[7:4]), .P_4b(P[1]), .G_4b(G[1]));
    ALU_adder_4b ALU2_4b(.A(Adder_In1[11:8]), .B(Adder_In2[11:8]), .CarryIn(C[1]), .Sub(sub),
                        .out_4b(Sum[11:8]), .P_4b(P[2]), .G_4b(G[2]));
    ALU_adder_4b ALU3_4b(.A(Adder_In1[15:12]), .B(Adder_In2[15:12]), .CarryIn(C[2]), .Sub(sub),
                        .out_4b(Sum[15:12]), .P_4b(P[3]), .G_4b(G[3]));

    assign Ovfl = (sub) ? Sum[15] & ~Adder_In1[15] & Adder_In2[15] | ~Sum[15] & Adder_In1[15] & ~Adder_In2[15]:
                          Sum[15] & ~Adder_In1[15] & ~Adder_In2[15] | ~Sum[15] & Adder_In1[15] & Adder_In2[15];
    assign Adder_Out = (Ovfl & sat) ? ((Sum[15]) ? 16'h7fff : 16'h8000) : Sum;

endmodule