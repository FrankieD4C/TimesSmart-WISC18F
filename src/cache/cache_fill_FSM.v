
module cache_fill_FSM(clk, rst_n, miss_detected, miss_address, fsm_busy, write_data_array,
 write_tag_array, memory_address, memory_data, memory_enable, memory_data_valid, write_address); // memory_data_valid
	
	input clk, rst_n, miss_detected;
	input [15:0] miss_address;
	input [15:0] memory_data;
	output fsm_busy; // asserted while FSM is busy handling the miss (can be used as pipeline stall signal) 
	output write_data_array; // write enable to cache data array to signal when filling with memory_data 
	output write_tag_array; // write enable to cache tag array to signal when all words are filled in to data array 
	output [15:0] memory_address; // address to read from memory
	output [15:0] write_address; // address write to cache 
	output memory_enable;
	output memory_data_valid;
	output [15:0] write_address;
	//wire memory_data_valid;
	
	wire state;
	reg next_state;
	wire [3:0] count, next_count, int_count;
	reg [3:0] update_count;
	wire [3:0] addr, next_addr, int_addr;
	reg [3:0] update_addr;
	wire add_en;
	
	assign add_en = (state & memory_data_valid) ? 1 : 0;
	always @*
	begin
		casex({state, count, miss_detected, memory_data_valid})
		default: begin next_state = state; update_count = count; update_addr = addr; end
		7'b0_????_0_? : begin next_state = 0; update_count = 4'b0; update_addr = 4'b0; end
		7'b0_????_1_? : begin next_state = 1; update_count = 4'b0; update_addr = 4'b0; end
		7'b1_0???_?_0 : begin next_state = 1; update_count = int_count; update_addr = int_addr; end
		7'b1_0???_?_1 : begin next_state = 1; update_count = int_count; update_addr = int_addr; end
		7'b1_1000_?_? : begin next_state = 0; update_count = int_count; update_addr = int_addr; end
	
		endcase
	end

	adder_4bit CNT(.AA(count[3:0]), .BB(4'b0001), .SS(next_count[3:0]), .CC(), .EN(add_en)); // 4 bit adder to update count
	adder_4bit ADDR(.AA(addr[3:0]), .BB(4'b0010), .SS(next_addr[3:0]), .CC(), .EN(add_en));

	dff DFFT(.q(state), .d(next_state), .wen(1'b1), .clk(clk), .rst(rst_n));
	dff CONT[3:0](.q(int_count[3:0]), .d(next_count[3:0]), .wen(1'b1), .clk(clk), .rst(rst_n));
	dff ADR[3:0](.q(int_addr[3:0]), .d(next_addr[3:0]), .wen(1'b1), .clk(clk), .rst(rst_n));
	
	assign memory_enable = (miss_detected & ~state | memory_data_valid & ~next_count[3]) ? 1 : 0;
	assign write_address = (next_state == 0) ? miss_address: {miss_address[15:4], addr[3:0]};
	assign memory_address = (next_state == 0) ? miss_address: {miss_address[15:4], next_addr[3:0]}; // ?count? 
	assign fsm_busy = miss_detected;
	assign count = update_count;
	assign addr = update_addr;
	assign write_data_array = (state) ? memory_data_valid : 0;
	assign write_tag_array = (count[3] == 1 & ~next_state) ? 1 : 0;
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
*/
`timescale 1ns / 1ps
module tb_cache_fill_FSM;
	localparam CHECK_DELAY = 0.1;
	localparam CLK_PERIOD = 5;
	
	reg tb_clk, th_clk;
	reg tb_rst_n, tb_miss_detected;
	wire tb_memory_data_valid;
	reg [15:0] tb_miss_address,tb_memory_data;
	wire tb_fsm_busy, tb_write_data_array, tb_write_tag_array;
	wire [15:0] tb_memory_address, tb_write_address;
	
	wire tb_memory_enable;
	integer text;
	cache_fill_FSM DUT (.clk(tb_clk), .rst_n(tb_rst_n), .miss_detected(tb_miss_detected), .miss_address(tb_miss_address),
		    	    .fsm_busy(tb_fsm_busy),
			    .write_data_array(tb_write_data_array),
 		            .write_tag_array(tb_write_tag_array), .memory_address(tb_memory_address), .memory_enable(tb_memory_enable), 
                            .memory_data(tb_memory_data), .memory_data_valid(tb_memory_data_valid), .write_address(tb_write_address));//.memory_data_valid(tb_memory_data_valid)

	always // set clock signal
	begin
		tb_clk = 1'b0;
		th_clk = 1'b0;
		#(CLK_PERIOD / 2.0);
		tb_clk = 1'b1;
		th_clk = 1'b1;
		#(CLK_PERIOD / 2.0);
	end

	initial 
	begin
	text = 0;
	//tb_clk = 1'b0;
	tb_rst_n = 0;
	tb_miss_detected = 0;
	//tb_memory_data_valid = 0;
	tb_miss_address = 0;
	tb_memory_data = 0;
	#CHECK_DELAY;	
	text = text + 1;
	@(negedge tb_clk)
	tb_rst_n = 1;
	tb_miss_detected = 1;
	tb_miss_address = 16'h2;
	@(negedge tb_clk)
	//tb_miss_detected = 0;
	#CLK_PERIOD;
	#CLK_PERIOD;
	#CLK_PERIOD;
	#CLK_PERIOD;
	//tb_memory_data_valid = 1;
	#CLK_PERIOD;
	@(negedge tb_clk)
	//tb_memory_data_valid = 0;
	#CLK_PERIOD;
	#CLK_PERIOD;
	#CLK_PERIOD;
	#CLK_PERIOD;
	//tb_memory_data_valid = 1;
	#CLK_PERIOD;
	@(negedge tb_clk)
	//tb_memory_data_valid = 0;
	#CLK_PERIOD;
	#CLK_PERIOD;
	#CLK_PERIOD;
	#CLK_PERIOD;
	//tb_memory_data_valid = 1;
	#CLK_PERIOD;
	@(negedge tb_clk)
	//tb_memory_data_valid = 0;
	#CLK_PERIOD;
	#CLK_PERIOD;
	#CLK_PERIOD;
	#CLK_PERIOD;
	//tb_memory_data_valid = 1;
	#CLK_PERIOD;
	@(negedge tb_clk)
	//tb_memory_data_valid = 0;
	#CLK_PERIOD;
	#CLK_PERIOD;
	#CLK_PERIOD;
	#CLK_PERIOD;
	//tb_memory_data_valid = 1;
	#CLK_PERIOD;
	@(negedge tb_clk)
	//tb_memory_data_valid = 0;
	#CLK_PERIOD;
	#CLK_PERIOD;
	#CLK_PERIOD;
	#CLK_PERIOD;
	//tb_memory_data_valid = 1;
	#CLK_PERIOD;
	@(negedge tb_clk)
	//tb_memory_data_valid = 0;
	#CLK_PERIOD;
	#CLK_PERIOD;
	#CLK_PERIOD;
	#CLK_PERIOD;
	//tb_memory_data_valid = 1;
	#CLK_PERIOD;
	@(negedge tb_clk)
	//tb_memory_data_valid = 0;
	#CLK_PERIOD;
	#CLK_PERIOD;
	#CLK_PERIOD;
	#CLK_PERIOD;
	//tb_memory_data_valid = 1;
	#CLK_PERIOD;
	end

endmodule