module cache_fill_FSM(clk, rst_n, miss_detected, miss_address, fsm_busy, write_data_array,
 write_tag_array, memory_address, memory_data, memory_enable, memory_data_valid); // memory_data_valid
	
	input clk, rst_n, miss_detected;
	input [15:0] miss_address;
	input [15:0] memory_data;
	output fsm_busy; // asserted while FSM is busy handling the miss (can be used as pipeline stall signal) 
	output write_data_array; // write enable to cache data array to signal when filling with memory_data 
	output write_tag_array; // write enable to cache tag array to signal when all words are filled in to data array 
	output [15:0] memory_address; // address to read from memory 
	output memory_enable;
	output memory_data_valid;
	//wire memory_data_valid;
	
	wire state;
	reg next_state;
	wire [3:0] count, int_count, next_count;
	reg [3:0] update_count;
	wire [3:0] addr, int_addr, next_addr;
	reg [3:0] update_addr;
	wire add_en;
	
	adder_4bit CNT(.AA(count[3:0]), .BB(4'b0001), .SS(next_count[3:0]), .CC(), .EN(add_en)); // 4 bit adder to update count
	adder_4bit ADDR(.AA(addr[3:0]), .BB(4'b0010), .SS(next_addr[3:0]), .CC(), .EN(add_en));
	
	assign add_en = (state & memory_data_valid) ? 1 : 0;
	always @*
	begin
		casex({state, count, miss_detected, memory_data_valid})
		default: begin next_state = state; update_count = count; update_addr = addr; end
		7'b0_????_0_? : next_state = 0;
		7'b0_????_1_? : begin next_state = 1; update_count = 4'b0; update_addr = 4'b0; end
		7'b1_0???_?_0 : begin next_state = 1; update_count = int_count; update_addr = int_addr; end
		7'b1_0???_?_1 : begin next_state = 1; end
		7'b1_1000_?_? : begin next_state = 0; end
	
		endcase
	end

	dff DFFT(.q(state), .d(next_state), .wen(1'b1), .clk(clk), .rst(rst_n));
	dff CONT[3:0](.q(int_count[3:0]), .d(next_count[3:0]), .wen(1'b1), .clk(clk), .rst(rst_n));
	dff ADR[3:0](.q(int_addr[3:0]), .d(next_addr[3:0]), .wen(1'b1), .clk(clk), .rst(rst_n));
	
	assign memory_enable = (miss_detected & ~state | memory_data_valid) ? 1 : 0;
	assign addr = int_addr;
	assign count = int_count;
	assign memory_address = (next_state == 0) ? miss_address: {miss_address[15:4], next_addr[3:0]}; // ?count? 
	assign fsm_busy = miss_detected;
	assign write_data_array = memory_data_valid;
	assign write_tag_array = (next_count[3] == 1) ? 1 : 0;
	/*
	wire [15:0] memo_out;
	memory4c TMEMO(.data_out(memo_out), .data_in(), .addr(memory_address), .enable(memory_enable), .wr(1'b0), .clk(clk), .rst(~rst_n), .data_valid(memory_data_valid));
*/
endmodule
/*
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
    output [15:0] memory_addre
ss; // address to read from memory
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
*/
