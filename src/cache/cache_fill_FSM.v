module cache_fill_FSM(clk, rst_n,
                      miss_detected, miss_address,
                      fsm_busy,
                      write_data_array, write_tag_array,
                      memory_address,
                      memory_data,
                      memory_data_valid,
                      memory_enable);
    input clk, rst_n;
    input miss_detected; // active high when tag match logic detects a miss
    input [15:0] miss_address; // address that missed the cache
    output fsm_busy; // asserted while FSM is busy handling the miss (can be used as pipeline stall signal)
    output write_data_array; // write enable to cache data array to signal when filling with memory_data
    output write_tag_array; // write enable to cache tag array to signal when all words are filled in to data array
    output [15:0] memory_address; // address to read from memory
    output memory_enable;
    input [15:0] memory_data; // data returned by memory (after delay)
    input memory_data_valid; // active high indicates valid data returning on memory bus

    wire [15:0] current_wdnum, next_wdnum, addr_adder_out, wdnum_adder_out;
    wire current_missstate, current_validstate;

    dff MISSSTATE(.q(current_missstate), .d(miss_detected), .wen(1'b1), .clk(clk), .rst(rst_n));
    dff VALIDSTATE(.q(current_validstate), .d(memory_data_valid), .wen(1'b1), .clk(clk), .rst(rst_n));
    dff WDNUM[15:0](.q(current_wdnum[15:0]), .d(next_wdnum[15:0]), .wen(1'b1), .clk(clk), .rst(rst_n));

    ALU_adder WDNUM_ADDER(.Adder_In1(16'h0002), .Adder_In2(current_wdnum), .sub(1'b0), .sat(1'b0),
                            .Adder_Out(wdnum_adder_out), .Ovfl());
    ALU_adder ADDR_ADDER(.Adder_In1(current_wdnum), .Adder_In2(miss_address), .sub(1'b0), .sat(1'b0),
                            .Adder_Out(addr_adder_out), .Ovfl());

    assign next_wdnum = (~rst_n | ~miss_detected | current_wdnum[4]) ? 16'h0000 :
                                (memory_data_valid ? wdnum_adder_out : current_wdnum);

    assign fsm_busy = miss_detected;
    assign write_data_array = miss_detected & memory_data_valid;
    assign write_tag_array = miss_detected & memory_data_valid & wdnum_adder_out[4];
    assign memory_address = (miss_detected) ? addr_adder_out : 16'h0000;
    assign memory_enable = (~current_missstate & miss_detected | current_validstate) ? 1: 0;

endmodule