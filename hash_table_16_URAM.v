module hash_table_16_URAM #(parameter NUM_MUL=1, parameter NUM_RD=8, parameter NUM_WR=4, parameter VALUE_WIDTH = 31, parameter KEY_WIDTH = 32, parameter INDEX_WIDTH = 12, parameter DATA_WIDTH = 64)
 (input clk, input reset,
 input [NUM_RD*KEY_WIDTH-1:0] key, input [NUM_WR*VALUE_WIDTH-1:0] value, input [2*NUM_WR-1:0] opt, input [NUM_WR-1:0] en_in, 
 output reg [NUM_RD*DATA_WIDTH-1:0] rd_out_final);
	//--------------------------for hash function----------------------//
	wire [NUM_RD*VALUE_WIDTH-1:0] value_all;
	wire [NUM_RD*2-1:0] opt_all;
	wire [NUM_RD-1:0] en_in_all;
	
	wire [NUM_RD-1:0] en_out;
	wire [NUM_RD*INDEX_WIDTH-1:0] index;
	wire [NUM_RD*VALUE_WIDTH-1:0] value_out;
	wire [NUM_RD*2-1:0] opt_out;
	wire [NUM_RD*KEY_WIDTH-1:0] key_out;
	
	wire [NUM_RD-1:0] write_reg_0_valid;
	wire [NUM_RD-1:0] write_reg_1_valid;
	wire [NUM_RD*INDEX_WIDTH-1:0] write_reg_0_index;
	wire [NUM_RD*NUM_MUL*DATA_WIDTH-1:0] write_reg_11_xor;
	
	wire [NUM_MUL*NUM_WR-1:0] arbiter_result;
	
	wire [NUM_MUL*NUM_WR*DATA_WIDTH-1:0] rd_out_all_update[NUM_RD-1:0];
	wire [KEY_WIDTH-1:0] rd_key_out[NUM_RD-1:0];
	wire [1:0] rd_opt_out[NUM_RD-1:0];
	reg [KEY_WIDTH-1:0] rd_key_out_next_reg [NUM_RD-1:0];
	reg [1:0] rd_opt_out_next_reg [NUM_RD-1:0];
	reg [NUM_MUL*NUM_WR*DATA_WIDTH-1:0] rd_out_all_update_next_reg [NUM_RD-1:0];
	wire [NUM_MUL*DATA_WIDTH-1:0] rd_out_after_xor [NUM_RD-1:0];
	wire [NUM_MUL*NUM_WR*DATA_WIDTH-1:0] rd_out_all_update_reorder[NUM_RD-1:0];
	wire [NUM_MUL*(NUM_WR-1)*DATA_WIDTH-1:0] rd_BRAM_out_other [NUM_RD-1:0];
	wire [NUM_MUL*(NUM_WR-1)*DATA_WIDTH-1:0] rd_BRAM_out_other_reorder [NUM_RD-1:0];
	
	assign value_all = {{(NUM_RD-NUM_WR)*VALUE_WIDTH{1'b0}}, value};
	assign opt_all = {{(NUM_RD-NUM_WR)*2{1'b0}}, opt};
	assign en_in_all = {{(NUM_RD-NUM_WR){1'b0}}, en_in};
	genvar i;
	genvar j;
	genvar k;
	//-----------------------------reorder BRAM_out------------------------//
	generate 
		for(i = 0; i < NUM_RD; i = i + 1) begin
			for(j = 0; j < NUM_MUL; j = j + 1) begin
				for(k = 0; k < NUM_WR; k = k + 1) begin
					assign rd_out_all_update_reorder[i][(j*NUM_WR+k)*DATA_WIDTH+:DATA_WIDTH] = rd_out_all_update[i][(j+k*NUM_MUL)*DATA_WIDTH+:DATA_WIDTH];
				end
				for(k = 0; k < NUM_WR-1; k = k + 1) begin
					assign rd_BRAM_out_other_reorder[i][(j*(NUM_WR-1)+k)*DATA_WIDTH+:DATA_WIDTH] = rd_BRAM_out_other[i][(j+k*NUM_MUL)*DATA_WIDTH+:DATA_WIDTH];
				end
			end
		end
	endgenerate	
	
	
	//-----------------------------rd_BRAM_out_other--------------------------//
	generate 
		for(i = 1; i < NUM_WR-1; i = i + 1) begin
			assign rd_BRAM_out_other[i] = {rd_out_all_update[i][0+:NUM_MUL*i*DATA_WIDTH], rd_out_all_update[i][NUM_MUL*(i+1)*DATA_WIDTH+:NUM_MUL*(NUM_WR-1-i)*DATA_WIDTH]};
		end
		for(i = NUM_WR; i < NUM_RD; i = i + 1) begin
			assign rd_BRAM_out_other[i] = 0;
		end
	endgenerate
	assign rd_BRAM_out_other[NUM_WR-1] = rd_out_all_update[NUM_WR-1][NUM_MUL*(NUM_WR-1)*DATA_WIDTH-1:0];
	assign rd_BRAM_out_other[0] = rd_out_all_update[0][NUM_MUL*NUM_WR*DATA_WIDTH-1:DATA_WIDTH*NUM_MUL];
	
	
	//-------------------------------output xor---------------------------//
	
	generate
		for(i = 0; i < NUM_RD; i = i + 1) begin
			for(j = 0; j < NUM_MUL; j = j + 1) begin
				xor_all_URAM #(NUM_WR, DATA_WIDTH) xor_all_u0 (rd_out_all_update_next_reg[i][NUM_WR*DATA_WIDTH*j+:NUM_WR*DATA_WIDTH], rd_out_after_xor[i][DATA_WIDTH*j+:DATA_WIDTH]);
			end
		end
	endgenerate
	
	integer p;
	integer q;
	always @(*) begin
		for(p = 0; p < NUM_RD; p = p + 1) begin
			rd_out_final[DATA_WIDTH*p+:DATA_WIDTH] = 0;
			for(q = 0; q < NUM_MUL; q = q + 1) begin
				if(rd_key_out_next_reg[p] == rd_out_after_xor[p][DATA_WIDTH*q+:KEY_WIDTH] && (rd_out_after_xor[p][q*DATA_WIDTH + DATA_WIDTH-1] == 1'b1)) begin
					rd_out_final[DATA_WIDTH*p+:DATA_WIDTH] = rd_out_after_xor[p][DATA_WIDTH*q+:DATA_WIDTH];
				end
			end
		end
	end
	//--------------------------------hash function-----------------------//
	generate
		for(i = 0; i < NUM_RD; i = i + 1) begin
			hash_function_URAM #(KEY_WIDTH, INDEX_WIDTH, VALUE_WIDTH) hash_function_u0 (.clk(clk), .reset(reset), .key(key[KEY_WIDTH*i+:KEY_WIDTH]), .value_in(value_all[VALUE_WIDTH*i+:VALUE_WIDTH]), .en_in(en_in_all[i]), .opt_in(opt_all[2*i+:2]),
			.en_out(en_out[i]), .index(index[INDEX_WIDTH*i+:INDEX_WIDTH]), .value_out(value_out[VALUE_WIDTH*i+:VALUE_WIDTH]), .opt_out(opt_out[2*i+:2]), .key_out(key_out[KEY_WIDTH*i+:KEY_WIDTH]));
		end
	endgenerate
	
	//-------------------------between hash function and table---------------//
	generate 
		for(i = 0; i < NUM_RD; i = i + 1) begin
			between_function_and_table_URAM #(NUM_MUL, NUM_WR, INDEX_WIDTH, VALUE_WIDTH, KEY_WIDTH, DATA_WIDTH) between_function_and_table_u0 (.index_in(index[INDEX_WIDTH*i+:INDEX_WIDTH]), .value_in(value_out[VALUE_WIDTH*i+:VALUE_WIDTH]), .en_in(en_out[i]), 
			.opt_in(opt_out[2*i+:2]), .key_in(key_out[KEY_WIDTH*i+:KEY_WIDTH]), 
			.rd_BRAM_out_other(rd_BRAM_out_other_reorder[i]),//FOR WRITE
			.clk(clk), .reset(reset),
			.write_reg_11_xor(write_reg_11_xor[NUM_MUL*DATA_WIDTH*i+:NUM_MUL*DATA_WIDTH]), .write_reg_0_index(write_reg_0_index[i*INDEX_WIDTH+:INDEX_WIDTH]), .write_reg_0_valid(write_reg_0_valid[i]),
			.write_reg_1_valid(write_reg_1_valid[i]),
			.write_reg_1_index() //use as write address
			);
			
			
		end
	endgenerate
	
	//---------------------------arbiter-----------------------------------//
/*	generate 
		for(i = 0; i < NUM_WR; i = i + 1) begin
			arbiter_URAM #(NUM_WR, NUM_MUL, DATA_WIDTH, KEY_WIDTH) arbiter_u0 (.rd_BRAM_out(rd_out_all_update_reorder[i]), .key_rd(rd_key_out[i]), .opt_rd({NUM_MUL{rd_opt_out[i][1]}}), 
			.arbiter_result(arbiter_result[i*NUM_MUL+:NUM_MUL]));
		end
	endgenerate*/
	
	//--------------------------------row------------------------------------//
	generate
		for(i = 0; i < NUM_RD; i = i + 1) begin
			row_3_stage_BRAM #(NUM_MUL, NUM_WR, INDEX_WIDTH, DATA_WIDTH, KEY_WIDTH)  row_u0 (.clk(clk), .reset(reset), 
			.arbiter_result(arbiter_result), .write_reg_0_valid(write_reg_0_valid[NUM_WR-1:0]), .rd_index(index[INDEX_WIDTH*i+:INDEX_WIDTH]),
			.write_reg_0_index(write_reg_0_index[NUM_WR*INDEX_WIDTH-1:0]), .write_reg_11_xor(write_reg_11_xor[NUM_MUL*NUM_WR*DATA_WIDTH-1:0]),
			//FOR BRAM&DFU.
			.rd_key(key_out[KEY_WIDTH*i+:KEY_WIDTH]), .rd_opt(opt_out[2*i+:2]),
//			output reg [KEY_WIDTH-1:0] rd_key_out, output reg [1:0] rd_opt_out, // to determine whether rd_out is valid or not
			.rd_key_out_next_stage(rd_key_out[i]), .rd_opt_out_next_stage(rd_opt_out[i]),
			.rd_out_all_update_next_stage(rd_out_all_update[i]));
		end
	endgenerate
	
	integer m;
	always @(posedge clk) begin
		for(m = 0; m < NUM_RD; m = m + 1) begin
			rd_out_all_update_next_reg[m] <= rd_out_all_update_reorder[m];
			rd_opt_out_next_reg[m] <= rd_opt_out[m];
			rd_key_out_next_reg[m] <= rd_key_out[m];
			
		end
	end
	
	
endmodule