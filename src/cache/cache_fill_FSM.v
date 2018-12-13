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
	input memory_data_valid;
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
	wire[3:0] addcount_re, addaddr_re;
	ALU_adder_4b CNT(.A(count[3:0]), .B(4'b0001), .CarryIn(1'b0), .Sub(1'b0), .out_4b(addcount_re[3:0]), .P_4b(), .G_4b());
	assign next_count = (add_en) ? addcount_re : count;
	ALU_adder_4b ADDR(.A(addr[3:0]), .B(4'b0010), .CarryIn(1'b0), .Sub(1'b0), .out_4b(addaddr_re[3:0]), .P_4b(), .G_4b());
	assign next_addr = (add_en) ? addaddr_re : addr;
	/*
	adder_4bit CNT(.AA(count[3:0]), .BB(4'b0001), .SS(next_count[3:0]), .CC(), .EN(add_en)); // 4 bit adder to update count
	adder_4bit ADDR(.AA(addr[3:0]), .BB(4'b0010), .SS(next_addr[3:0]), .CC(), .EN(add_en));
	*/
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