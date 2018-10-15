module full_adder_1bit (A, B, CarryIn, Sum, CarryOut);

    input A, B, CarryIn;
    output Sum, CarryOut;
    assign CarryOut = (A & CarryIn) | (B & CarryIn) | (A & B);
    assign Sum = A ^ B ^ CarryIn;

endmodule