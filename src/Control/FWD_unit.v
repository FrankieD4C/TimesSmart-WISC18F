module FWD_unit(input[3:0] IDEX_rs, IDEX_rt, EXMEM_rd, EXMEM_rt, MEMWB_rd,
                input EXMEM_MemWrite, EXMEM_MemRead, EXMEM_MemtoReg, EXMEM_RegWrite,
                input MEMWB_MemtoReg, MEMWB_RegWrite,
                output[1:0] ALUIn1_FWDEnable, ALUIn2_FWDEnable,
                output MEM_FWDEnable);

    // 10:EX2EX FWD 01: MEM2EX FWD
    assign ALUIn1_FWDEnable = (EXMEM_RegWrite & (EXMEM_rd != 4'b0) & (EXMEM_rd == IDEX_rs)) ? 2'b10 :
                                    ((MEMWB_RegWrite & (MEMWB_rd != 4'b0)
                                        & !(EXMEM_RegWrite & (EXMEM_rd != 4'b0) & (EXMEM_rd == IDEX_rs))
                                        & (MEMWB_rd == IDEX_rs))? 2'b01 : 2'b00);

    assign ALUIn2_FWDEnable = (EXMEM_RegWrite & (EXMEM_rd != 4'b0) & (EXMEM_rd == IDEX_rt)) ? 2'b10 :
                                    ((MEMWB_RegWrite & (MEMWB_rd != 4'b0)
                                        & !(EXMEM_RegWrite & (EXMEM_rd != 4'b0) & (EXMEM_rd == IDEX_rt))
                                        & (MEMWB_rd == IDEX_rt))? 2'b01 : 2'b00);

    // MEM2MEM FWD
    assign MEM_FWDEnable = (EXMEM_MemWrite & MEMWB_RegWrite
                                & (MEMWB_rd != 4'b0) & (MEMWB_rd == EXMEM_rt)) ? 1'b1 : 1'b0;


endmodule
