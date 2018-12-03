module cache_fill_FSM(clk, rst_n, miss_detected, miss_address, fsm_busy, write_data_array,
 write_tag_array, memory_address, memory_data, memory_data_valid);

	input clk, rst_n;
	input miss_detected; // active high when tag match logic detects a miss 
	input [15:0] miss_address; // address that missed the cache 
	input [15:0] memory_data; // data returned by memory (after  delay) 
	input memory_data_valid; // active high indicates valid data returning on memory bus 
	output fsm_busy; // asserted while FSM is busy handling the miss (can be used as pipeline stall signal) 
	output write_data_array; // write enable to cache data array to signal when filling with memory_data 
	output write_tag_array; // write enable to cache tag array to signal when all words are filled in to data array 
	output [15:0] memory_address; // address to read from memory 

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
	8'b1_1_0???_?_1 : begin add_en = 1; end
	8'b1_1_1000_?_? : begin Next_state = 0; add_en = 0; end // all data filled, write tag and back to idle state
	endcase
	end

//DFF
	dff STAT(.q(State), .d(Next_state), .wen(1'b1), .clk(clk), .rst(rst_n));
	dff CONT[3:0](.q(int_count[3:0]), .d(Next_count[3:0]), .wen(1'b1), .clk(clk), .rst(rst_n));
	dff ADRE[3:0] (.q(Next_addr[3:0]), .d(Update_addr[3:0]), .wen(1'b1), .clk(clk), .rst(rst_n));

// output logic	
	
	assign Count = (rst_n) ? int_count : 4'b0000;
	assign Addr = (~State & Next_state | ~rst_n) ? 4'b0000 : Next_addr;
	assign memory_address = (Next_state == 1) ? {miss_address[15:4], Addr} : miss_address;
	
	assign fsm_busy = (Next_state) ? 1 : 0;
	assign write_data_array = (State & memory_data_valid & Next_state) ? 1 : 0; // when write tag, disable write data_enable
	assign write_tag_array = (State & Count[3])? 1:0;



endmodule
