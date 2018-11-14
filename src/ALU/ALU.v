
`include "ALU/ALU_adder.v"
`include "ALU/Shift.v"
`include "ALU/RED.v"
`include "ALU/PADDSB.v"



module ALU(ALU_In1, ALU_In2, Opcode, ALU_Out, ZVN);

    input [15:0] ALU_In1, ALU_In2;
    input [3:0] Opcode;
    output [15:0] ALU_Out;
    output [2:0] ZVN; // 3bit flag signal
    wire[15:0] ADDSUB_Out, PADDSB_Out, RED_Out, Shift_Out, LWSW_Out;
    wire V;

    // ADD SUB
    ALU_adder ALU_ADDSUB(.Adder_In1(ALU_In1), .Adder_In2(ALU_In2),
                         .sub(Opcode[0]), .sat(1'b1),
                         .Adder_Out(ADDSUB_Out), .Ovfl(V));
    // PADDSB
    PADDSB ALU_PADDSB(.A(ALU_In1), .B(ALU_In2), .Sum(PADDSB_Out));

    // RED
    RED ALU_RED(.A(ALU_In1), .B(ALU_In2), .Sum(RED_Out));

    // SLL SRA ROR
    Shift ALU_Shift(.Shift_Out(Shift_Out),
                    .Shift_In(ALU_In1), .Shift_Val(ALU_In2[3:0]), .Mode(Opcode[1:0]));

    // LW SW
    ALU_adder ALU_LWSW(.Adder_In1(ALU_In1 & 16'hfffe), .Adder_In2(ALU_In2 << 1),
                       .sub(1'b0), .sat(1'b0),
                       .Adder_Out(LWSW_Out), .Ovfl());

    reg [15:0] Out_reg;
    always @*
        case (Opcode)
            4'b0000: Out_reg = ADDSUB_Out;
            4'b0001: Out_reg = ADDSUB_Out;
            4'b0010: Out_reg = ALU_In1 ^ ALU_In2;  // XOR
            4'b0011: Out_reg = RED_Out;
            4'b0100: Out_reg = Shift_Out;
            4'b0101: Out_reg = Shift_Out;
            4'b0110: Out_reg = Shift_Out;
            4'b0111: Out_reg = PADDSB_Out;
            4'b1000: Out_reg = LWSW_Out;
            4'b1001: Out_reg = LWSW_Out;
            4'b1010: Out_reg = (ALU_In2 & 16'hff00) | ALU_In1;   //LLB
            4'b1011: Out_reg = (ALU_In2 & 16'h00ff) | (ALU_In1 << 8);   //LHB
            default: Out_reg = 16'h0000;   // IF default set output 0
        endcase
    assign ALU_Out = Out_reg;

    // Flag control
    assign ZVN[2] = ((ALU_Out == 16'h0000) & (Opcode[3] == 0) & (Opcode[1:0] != 2'b11)) ?  1'b1 : 1'b0; //Z
    assign ZVN[1] = (Opcode[3:1] == 3'b000) ? V :1'b0;  //V
    assign ZVN[0] = (Opcode[3:1] == 3'b000) ? ALU_Out[15] : 1'b0;  //N
    //assign FlagWriteEnable[2] = ((Opcode[3] == 0) & (Opcode[1:0] != 2'b11)) ? 1'b1 : 1'b0; // Z enable
    //assign FlagWriteEnable[1:0] = (Opcode[3:1] == 3'b000) ? 2'b11 : 2'b00; // W enable

endmodule