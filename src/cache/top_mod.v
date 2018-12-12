/*
`include "cache/cache_fill_FSM.v"
`include "cache/D_cache.v"
`include "cache/I_cache.v"
`include "cache/DataArray.v"
`include "cache/MetaDataArray.v"
`include "cache/convert3to8.v"
`include "cache/convert6to128.v"
*/

module top_mod(input [15:0] pc_addr, input [15:0] data_addr, input [15:0] data_in, input MEM_read, input MEM_write,
	       input clk, input rst_n, output MEM_stall, output IF_stall, output[15:0] D_output, output [15:0] I_output);
// if MEM stall, all previous pipe should be stall
// if IF stall, only IF pipe stall
	wire data_va;
	wire array_en, tag_en, busy;
	wire D_tag_en, D_array_en, I_tag_en, I_array_en;
	wire I_cache_miss, D_cache_miss;
	wire [15:0] I_addr_in, D_addr_in, D_data_in, I_data_in;
	wire[15:0] memo_addr, memo_data_out, write_addr;
	wire [1:0] State;
	reg [1:0] NNext_state; // 00:idle; 01: I miss; 10: D miss; 11 Ddone wait state, wait for writting data
	wire [1:0] Next_state;
	wire miss_signal;


	wire D_cache_en;
	assign D_cache_en = (MEM_read | MEM_write) ? 1 : 0;
//******************************************************First Stage*****************************************************//
	wire int_I_cache_miss, int_D_cache_miss;
	always @* begin
		casex({I_cache_miss, D_cache_miss, Next_state, MEM_write, tag_en})
		default: NNext_state = 2'b00;
		6'b0_0_00_?_?: NNext_state = 2'b00;
		6'b1_0_00_?_?: NNext_state = 2'b01;
		6'b1_?_01_?_0: NNext_state = 2'b01; // if not done, remain state
		6'b?_1_10_?_0: NNext_state = 2'b10;
		6'b?_1_00_?_?: NNext_state = 2'b10;//if D miss, always take D first
		6'b0_0_01_?_1: NNext_state = 2'b00; // if only I miss, when done, back to idle, tag_en means done
		6'b0_0_10_?_1: NNext_state = 2'b00;
		6'b1_0_10_1_1: NNext_state = 2'b11; // when MEM_write for D, if I miss, go to state Wait 2'b11
		6'b1_?_11_?_?: NNext_state = 2'b01; // wait one cycle and then I miss state
		6'b0_1_01_?_1: NNext_state = 2'b10;
		endcase
	end

	dff MEMOD[1:0](.q(Next_state[1:0]), .d(NNext_state[1:0]), .wen(1'b1), .clk(clk), .rst(rst_n));
//*************************************************************First Stage*************************************************//

//***************************************************************Second Stage**********************************************//
	dff MEMOF[1:0](.q(State[1:0]), .d(Next_state[1:0]), .wen(1'b1), .clk(clk), .rst(rst_n)); // modified part
	assign miss_signal = (Next_state == 2'b01 | Next_state == 2'b10) ? 1 : 0;
	wire [15:0] miss_addr;
	wire int_memo_en;
	assign miss_addr = (Next_state == 2'b10) ? data_addr : (Next_state == 2'b01) ? pc_addr : 16'b0; // use state will delay oen cycle, use miss signal is better

	cache_fill_FSM FSM(.clk(clk), .rst_n(rst_n), .miss_detected(miss_signal), .miss_address(miss_addr), .fsm_busy(busy), .write_data_array(array_en),
 .write_tag_array(tag_en), .memory_address(memo_addr), .memory_data(), .memory_data_valid(data_va), .memory_enable(int_memo_en), .write_address(write_addr));//write addresswrite_addr
//***************************************************************Second Stage***********************************************//
	dff IDCMIS[1:0] (.q({int_I_cache_miss, int_D_cache_miss}), .d({I_cache_miss, D_cache_miss}), .wen(1'b1), .clk(clk), .rst(rst_n));
	wire [15:0] int_data_addr, int_pc_addr, int_data_in;
	dff IADR[15:0] (.q(int_pc_addr), .d(pc_addr), .wen(1'b1), .clk(clk), .rst(rst_n));
	dff DADR[15:0] (.q(int_data_addr), .d(data_addr), .wen(1'b1), .clk(clk), .rst(rst_n));
	dff DDATA[15:0] (.q(int_data_in), .d(data_in), .wen(1'b1), .clk(clk), .rst(rst_n));
	// delay one cycle for FSM related signal
	//output logic
	assign D_array_en = (State == 2'b10) ? array_en : 0;
	assign D_tag_en = (State == 2'b10) ? tag_en : 0;
	assign I_array_en = (State == 2'b01) ? array_en : 0;
	assign I_tag_en = (State == 2'b01) ? tag_en : 0;


	//miss? 1 miss, 0 hit & Next_state != State
	assign D_addr_in = (int_D_cache_miss) ? ((State == 2'b10 | State == 2'b01)& Next_state != State) ? int_data_addr : write_addr : data_addr; // miss? addr from FSM, else from pipeline
	assign D_data_in = (int_D_cache_miss) ? ((State == 2'b10 | State == 2'b01) & Next_state != State) ? int_data_in : memo_data_out : data_in;

	D_cache DCT(.addr_input(D_addr_in), .data_input(D_data_in), .data_output(D_output),
	.write_inputdata(MEM_write), .write_data_en(D_array_en), .write_tag_en(D_tag_en),
	.clk(clk), .rst_n(rst_n), .MEM_stall(D_cache_miss), .D_en(D_cache_en));

	assign I_addr_in = (int_I_cache_miss) ? ((State == 2'b01 | State == 2'b10 | State == 2'b11) & Next_state != State) ? int_pc_addr : write_addr : pc_addr; // miss? addr from FSM, else from pipeline
	assign I_data_in = (int_I_cache_miss) ? memo_data_out : 16'h0;	// take care for this data_in effect

	I_cache ICT(.addr_input(I_addr_in), .data_input(memo_data_out), .data_output(I_output),
	.write_inputdata(1'b0), .write_data_en(I_array_en), .write_tag_en(I_tag_en),
	.clk(clk), .rst_n(rst_n), .IF_stall(I_cache_miss));

	wire memo_en;
	assign memo_en = ((int_D_cache_miss | int_I_cache_miss | MEM_write)& int_memo_en) ? 1 : 0;
	//concern about read miss & write to memory simutaneously ( memory code)
	memory4c MEMO(.data_out(memo_data_out), .data_in(data_in), .addr(memo_addr), .enable(memo_en), .wr((~D_cache_miss & MEM_write)), .clk(clk), .rst(~rst_n), .data_valid(data_va));

	assign IF_stall = I_cache_miss;
	assign MEM_stall = D_cache_miss;

endmodule

/*
`timescale 1ns / 1ps
module tb_top_mod();
	localparam CHECK_DELAY = 0.1;
	localparam CLK_PERIOD = 5;

	reg [15:0] tb_pc_addr, tb_data_addr, tb_data_in;
	reg tb_MEM_read, tb_MEM_write;
	reg tb_clk,tb_rst_n;
	wire tb_MEM_stall, tb_IF_stall;
	wire [15:0] tb_D_output, tb_I_output;

	top_mod TUT(.pc_addr(tb_pc_addr), .data_addr(tb_data_addr), .data_in(tb_data_in), .MEM_read(tb_MEM_read), .MEM_write(tb_MEM_write),
	        .clk(tb_clk), .rst_n(tb_rst_n), .MEM_stall(tb_MEM_stall), .IF_stall(tb_IF_stall), .D_output(tb_D_output), .I_output(tb_I_output));
	always // set clock signal
	begin
		tb_clk = 1'b0;
		#(CLK_PERIOD / 2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD / 2.0);
	end

	initial
	begin
	tb_pc_addr = 16'b0; tb_data_addr = 16'b0; tb_data_in = 16'b0;
	tb_MEM_read = 0; tb_MEM_write = 0;
	tb_rst_n = 0;

	@(negedge tb_clk);
	tb_rst_n = 1;

	end
endmodule
*/