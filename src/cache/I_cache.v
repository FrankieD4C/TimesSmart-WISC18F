module I_cache(addr_input, data_input, data_output, write_inputdata, write_data_en, write_tag_en, clk, rst_n, IF_stall);
	
	input write_inputdata, write_data_en, write_tag_en, clk, rst_n;
	input [15:0] data_input, addr_input;
	output IF_stall;
	output [15:0] data_output;
	// 6 bit tag, 6 bit index, 4 bit block offset
	wire [5:0] index; // corresponding to 10:5 of addr
	wire [7:0] meta_data_in;
	//wire [127:0] valid, LRU, 

	assign index = addr_input[9:4]; // index for datain will be extended with two bit of 0
	assign meta_data_in = {1'b1, 1'b1, addr_input[15:10]}; // 1b valid, 1b LRU, corresponding tag2
	// meta block, enable for read, otherwise for write
	wire [15:0] meta_data_out; // contain two packages data
	// write signal comes from handler / write enable
	wire [1:0] write_en, write_tag, write_data; // determined based on LRU
	//assign write_tag, check write hit? if miss, block empty? if not check LRU;
	wire hit, hit1, hit2; //check valid, then check tag of two block at same time;
	wire valid1, valid2;
	assign valid1 = (meta_data_out[15]) ? 1:0;
	assign valid2 = (meta_data_out[7]) ? 1:0;
	
	assign write_en = (hit1) ? 2'b10 : (hit2) ? 2'b01: (~valid1) ? 2'b10 : (~valid2) ? 2'b01 : (meta_data_out[6]) ? 2'b01 :2'b10;
	assign write_tag = (write_tag_en)? write_en : 2'b00;
	wire [63:0] block_en;  // specify cache block position
	convert6to128 CVTind(.in(index), .out(block_en));
	MetaDataArray MDA(.clk(clk), .rst_n(rst_n), .DataIn(meta_data_in), .Write(write_tag), .hit({hit1,hit2}), .BlockEnable(block_en), .DataOut(meta_data_out));
	//miss_detect valid, lru, tag
	// initially, one of the two block may be empty, so need to chekc the tag value for both block instead of only check one time
	assign hit1 = (meta_data_out[13:8] == addr_input[15:10]) ? 1 : 0;
	assign hit2 = (meta_data_out[5:0] == addr_input[15:10]) ? 1 : 0;
	assign hit = (hit1 & valid1) ? 1 : (hit2 & valid2) ? 1 : 0;  
	assign IF_stall = ~hit;	
	
	
	wire [7:0] wd_en;	// miss or hit wordenable
	wire [31:0] int_data_output;
	assign write_data = (write_data_en) ? write_en : (hit & write_inputdata) ? write_en : 2'b00;
	convert3to8 MISADDR(.in(addr_input[3:1]),.out(wd_en[7:0])); // check offset, get correspoding data
	DataArray DA(.clk(clk), .rst(rst_n), .DataIn(data_input), .Write(write_data), .BlockEnable(block_en), .WordEnable(wd_en), .DataOut(int_data_output));

	assign data_output = (hit1) ? int_data_output[31:16] : (hit2) ? int_data_output[15:0] : 16'bz;

endmodule
