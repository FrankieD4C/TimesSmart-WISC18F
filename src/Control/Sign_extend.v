module Sign_extend(Imme_9b, Opcode, Imme_16b);

    input[8:0] Imme_9b;
    input[3:0] Opcode;
    output[15:0] Imme_16b;
    wire[16:0] Imme_4_16_signed;  // Shift LW SW
    wire[16:0] Imme_8_16_unsigned; // LLB LHB
    wire[16:0] Imme_9_16_signed; //  B
    assign Imme_4_16_signed =  {{12{Imme_9b[3]}},Imme_9b[3:0]};
    assign Imme_8_16_unsigned = {{8{1'b0}},Imme_9b[7:0]};
    assign Imme_9_16_signed = {{7{Imme_9b[8]}},Imme_9b[8:0]};
    assign Imme_16b = ((Opcode[3:2] == 2'b01) | (Opcode[3:1] == 3'b100)) ? Imme_4_16_signed :
                        ((Opcode[3:1] == 3'b101) ? Imme_8_16_unsigned : Imme_9_16_signed);
endmodule