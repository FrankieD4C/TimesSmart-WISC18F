module RED(A, B, Sum);

    input[15:0] A, B;
    output[15:0] Sum;
    wire [8:0] Sum1, Sum2;
    wire P1_0, P1_1, G1_0, G1_1, P2_0, P2_1, G2_0, G2_1, P3_0, P3_1, P3_2, G3_0, G3_1, G3_2, C3_2, sign;

    // a+c
    ALU_adder_4b ALU1_1(.A(A[11:8]), .B(B[11:8]), .CarryIn(1'b0), .Sub(1'b0),
                        .out_4b(Sum1[3:0]), .P_4b(P1_0), .G_4b(G1_0));
    ALU_adder_4b ALU1_2(.A(A[15:12]), .B(B[15:12]), .CarryIn(G1_0), .Sub(1'b0),
                        .out_4b(Sum1[7:4]), .P_4b(P1_1), .G_4b(G1_1));
    assign Sum1[8] = A[15] ^ B[15] ^ (G1_1|(P1_1&G1_0)); // signbit

    // b+d
    ALU_adder_4b ALU2_1(.A(A[3:0]), .B(B[3:0]), .CarryIn(1'b0), .Sub(1'b0),
                        .out_4b(Sum2[3:0]), .P_4b(P2_0), .G_4b(G2_0));
    ALU_adder_4b ALU2_2(.A(A[7:4]), .B(B[7:4]), .CarryIn(G2_0), .Sub(1'b0),
                        .out_4b(Sum2[7:4]), .P_4b(P2_1), .G_4b(G2_1));
    assign Sum2[8] = A[7] ^ B[7] ^ (G2_1|(P2_1&G2_0));  // signbit

    // (a+c) + (b+d)
    ALU_adder_4b ALU3_1(.A(Sum1[3:0]), .B(Sum2[3:0]), .CarryIn(1'b0), .Sub(1'b0),
                        .out_4b(Sum[3:0]), .P_4b(P3_0), .G_4b(G3_0));
    ALU_adder_4b ALU3_2(.A(Sum1[7:4]), .B(Sum2[7:4]), .CarryIn(G3_0), .Sub(1'b0),
                        .out_4b(Sum[7:4]), .P_4b(P3_1), .G_4b(G3_1));
    ALU_adder_4b ALU3_3(.A({4{Sum1[8]}}), .B({4{Sum2[8]}}), .CarryIn(C3_2), .Sub(1'b0),
                        .out_4b(Sum[11:8]), .P_4b(P3_2), .G_4b(G3_2));

    assign C3_2 = G3_1|(P3_1&G3_0);
    assign sign = Sum1[8] ^ Sum2[8] ^ (G3_2|(P3_2&G3_1)|(P3_2&P3_1&G3_0)); // signbit
    assign Sum[15:12] = {4{sign}};

endmodule



