`include "ALU/ALU_adder.v"
`include "ALU/Shift.v"
`include "ALU/RED.v"
`include "ALU/PADDSB.v"

module ALU(ALU_In1, ALU_In2, Opcode, ALU_Out, ZVN, FlagWriteEnable);

    input [15:0] ALU_In1, ALU_In2;
    input [3:0] Opcode;
    output [15:0] ALU_Out;
    output [2:0] ZVN; // 3bit flag signal
    output FlagWriteEnable;
    wire[15:0] ADDSUB_Out, PADDSB_Out, RED_Out, Shift_Out, LWSW_Out, LLB_Out, LHB_Out;
    wire V;

    ALU_adder ALU_ADDSUB(.Adder_In1(ALU_In1), .Adder_In2(ALU_In2),
                         .sub(Opcode[0]), .sat(1'b1),
                         .Adder_Out(ADDSUB_Out), .Ovfl(V));
    PADDSB ALU_PADDSB(.A(ALU_In1), .B(ALU_In2), .Sum(PADDSB_Out));
    RED ALU_RED(.A(ALU_In1), .B(ALU_In2), .Sum(RED_Out));
    Shift ALU_Shift(.Shift_Out(Shift_Out),
                    .Shift_In(ALU_In1), .Shift_Val(ALU_In2[3:0]), .Mode(Opcode[1:0]));
    ALU_adder ALU_LWSW(.Adder_In1(ALU_In1 & 16'hfffe), .Adder_In2(ALU_In2 << 1),
                       .sub(1'b0), .sat(1'b0),
                       .Adder_Out(LWSW_Out), .Ovfl());
    ALU_adder ALU_LLB(.Adder_In1(ALU_In1 & 16'hff00), .Adder_In2(ALU_In2),
                       .sub(1'b0), .sat(1'b0),
                       .Adder_Out(LLB_Out), .Ovfl());
    ALU_adder ALU_LHB(.Adder_In1(ALU_In1 & 16'h00ff), .Adder_In2(ALU_In2 << 8),
                       .sub(1'b0), .sat(1'b0),
                       .Adder_Out(LHB_Out), .Ovfl());

    reg [15:0] Out_reg;
    always @*
        case (Opcode)
            4'b0000: Out_reg = ADDSUB_Out;
            4'b0001: Out_reg = ADDSUB_Out;
            4'b0010: Out_reg = ALU_In1 ^ ALU_In2;
            4'b0011: Out_reg = RED_Out;
            4'b0100: Out_reg = Shift_Out;
            4'b0101: Out_reg = Shift_Out;
            4'b0110: Out_reg = Shift_Out;
            4'b0111: Out_reg = PADDSB_Out;
            4'b1000: Out_reg = LWSW_Out;
            4'b1001: Out_reg = LWSW_Out;
            4'b1010: Out_reg = LLB_Out;
            4'b1011: Out_reg = LHB_Out;
            default: Out_reg = 16'h0000;   // how to deal with default?
        endcase
    assign ALU_Out = Out_reg;

    // Flag control
    assign ZVN[2] = ((ALU_Out == 16'h0000) & (Opcode[3] == 0) & (Opcode[1:0] != 2'b11)) ?  1'b1 : 1'b0; //Z
    assign ZVN[1] = (Opcode[3:1] == 3'b000) ? V :1'b0;  //V
    assign ZVN[0] = (Opcode[3:1] == 3'b000) ? ALU_Out[15] : 1'b0;  //N
    assign FlagWriteEnable = ((Opcode[3] == 0) & (Opcode[1:0] != 2'b11)) ? 1'b1 : 1'b0;
  //  assign FlagWriteEnable[2] = ((Opcode[3] == 0) & (Opcode[1:0] != 2'b11)) ? 1'b1 : 1'b0;
  //  assign FlagWriteEnable[1:0] = (Opcode[3:1] == 3'b000) ? 2'b11 : 2'b00;

endmodule