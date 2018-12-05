module cache_fill_FSM(clk, rst_n, miss_detected, miss_address, fsm_busy, write_data_array,
 write_tag_array, memory_address, memory_data, memory_data_valid, memory_enable);

	input clk, rst_n;
	input miss_detected; // active high when tag match logic detects a miss 
	input [15:0] miss_address; // address that missed the cache 
	input [15:0] memory_data; // data returned by memory (after  delay) 
	input memory_data_valid; // active high indicates valid data returning on memory bus 
	output fsm_busy; // asserted while FSM is busy handling the miss (can be used as pipeline stall signal) 
	output write_data_array; // write enable to cache data array to signal when filling with memory_data 
	output write_tag_array; // write enable to cache tag array to signal when all words are filled in to data array 
	output [15:0] memory_address; // address to read from memory 
	output memory_enable;
	
	wire State;
	reg Next_state, add_en;
	wire [3:0] Count, int_count, Next_count;
	wire [3:0] Addr, Update_addr, Next_addr;
	
	adder_4bit CNT(.AA(Count[3:0]), .BB(4'b0001), .SS(Next_count), .CC(), .EN(add_en)); // 4 bit adder to update count
	adder_4bit ADDR(.AA(Addr[3:0]), .BB(4'b0010), .SS(Update_addr), .CC(), .EN(add_en));
	
	always @(rst_n, State, Count, miss_detected, memory_data_valid) begin
	casex ({rst_n, State, Count, miss_detected, memory_data_valid})
	default: begin  Next_state = State; add_en = 0; end
	8'b0_?_????_?_? : begin Next_state = 0; add_en = 0; end
	8'b1_0_????_0_? : begin Next_state = 0; end // remain the idle state
	8'b1_0_????_1_0 : begin Next_state = 1; end // miss detect, state change to wait, wait for data valid
	8'b1_1_0???_?_0 : begin Next_state = 1; add_en = 0; end
	8'b1_1_0???_?_1 : begin add_en = 1; end
	8'b1_1_1000_?_? : begin Next_state = 0; add_en = 0; end // all data filled, write tag and back to idle state
	endcase
	end

//DFF	
	wire pre_add_en;
	dff STAT(.q(State), .d(Next_state), .wen(1'b1), .clk(clk), .rst(rst_n));
	dff CONT[3:0](.q(int_count[3:0]), .d(Next_count[3:0]), .wen(1'b1), .clk(clk), .rst(rst_n));
	dff ADRE[3:0] (.q(Next_addr[3:0]), .d(Update_addr[3:0]), .wen(1'b1), .clk(clk), .rst(rst_n));
	dff ADE(.q(pre_add_en), .d(add_en), .wen(1'b1), .clk(clk), .rst(rst_n));
// output logic	
	
	assign Count = (~rst_n | Next_state == 0) ? 4'b0000 : int_count;
	assign Addr = (~State & Next_state | ~rst_n) ? 4'b0000 : Next_addr;
	assign memory_address = (Next_state == 1) ? {miss_address[15:4], Addr} : miss_address;
	assign memory_enable = (~State & Next_state | pre_add_en) ? 1: 0;
	assign fsm_busy = (Next_state) ? 1 : 0;
	assign write_data_array = (State & memory_data_valid) ? 1 : 0; // when write tag, disable write data_enable
	assign write_tag_array = (State & int_count[3])? 1:0;



endmodule

/*
`timescale 1ns / 1ps
module tb_cache_fill_FSM;
	localparam CHECK_DELAY = 0.1;
	localparam CLK_PERIOD = 5;
	
	reg tb_clk, th_clk;
	reg tb_rst_n, tb_miss_detected,tb_memory_data_valid;
	reg [15:0] tb_miss_address,tb_memory_data;
	wire tb_fsm_busy, tb_write_data_array, tb_write_tag_array;
	wire [15:0] tb_memory_address;

	integer text;
	cache_fill_FSM DUT (.clk(tb_clk), .rst_n(tb_rst_n), .miss_detected(tb_miss_detected), .miss_address(tb_miss_address),
		    	    .fsm_busy(tb_fsm_busy),
			    .write_data_array(tb_write_data_array),
 		            .write_tag_array(tb_write_tag_array), .memory_address(tb_memory_address),
                            .memory_data(tb_memory_data), .memory_data_valid(tb_memory_data_valid));

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
	tb_memory_data_valid = 0;
	tb_miss_address = 0;
	tb_memory_data = 0;
	#CHECK_DELAY;	
	text = text + 1;
	@(negedge tb_clk)
	tb_rst_n = 1;
	tb_miss_detected = 1;
	tb_miss_address = 16'h1234;
	@(negedge tb_clk)
	tb_miss_detected = 0;
	#CLK_PERIOD;
	#CLK_PERIOD;
	#CLK_PERIOD;
	#CLK_PERIOD;
	tb_memory_data_valid = 1;
	#CLK_PERIOD;
	@(negedge tb_clk)
	tb_memory_data_valid = 0;
	#CLK_PERIOD;
	#CLK_PERIOD;
	#CLK_PERIOD;
	#CLK_PERIOD;
	tb_memory_data_valid = 1;
	#CLK_PERIOD;
	@(negedge tb_clk)
	tb_memory_data_valid = 0;
	#CLK_PERIOD;
	#CLK_PERIOD;
	#CLK_PERIOD;
	#CLK_PERIOD;
	tb_memory_data_valid = 1;
	#CLK_PERIOD;
	@(negedge tb_clk)
	tb_memory_data_valid = 0;
	#CLK_PERIOD;
	#CLK_PERIOD;
	#CLK_PERIOD;
	#CLK_PERIOD;
	tb_memory_data_valid = 1;
	#CLK_PERIOD;
	@(negedge tb_clk)
	tb_memory_data_valid = 0;
	#CLK_PERIOD;
	#CLK_PERIOD;
	#CLK_PERIOD;
	#CLK_PERIOD;
	tb_memory_data_valid = 1;
	#CLK_PERIOD;
	@(negedge tb_clk)
	tb_memory_data_valid = 0;
	#CLK_PERIOD;
	#CLK_PERIOD;
	#CLK_PERIOD;
	#CLK_PERIOD;
	tb_memory_data_valid = 1;
	#CLK_PERIOD;
	@(negedge tb_clk)
	tb_memory_data_valid = 0;
	#CLK_PERIOD;
	#CLK_PERIOD;
	#CLK_PERIOD;
	#CLK_PERIOD;
	tb_memory_data_valid = 1;
	#CLK_PERIOD;
	@(negedge tb_clk)
	tb_memory_data_valid = 0;
	#CLK_PERIOD;
	#CLK_PERIOD;
	#CLK_PERIOD;
	#CLK_PERIOD;
	tb_memory_data_valid = 1;
	#CLK_PERIOD;
	end

endmodule
*/