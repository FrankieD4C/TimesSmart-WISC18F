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
