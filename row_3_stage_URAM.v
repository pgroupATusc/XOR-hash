module row_3_stage_BRAM #(parameter NUM_MUL = 4, parameter NUM_WR = 8, parameter INDEX_WIDTH = 12, parameter DATA_WIDTH = 64, parameter KEY_WIDTH = 32) 
(input clk, input reset, 
input [NUM_WR*NUM_MUL-1:0] arbiter_result, input [NUM_WR-1:0] write_reg_0_valid, input [INDEX_WIDTH-1:0] rd_index, input [NUM_WR*INDEX_WIDTH-1:0] write_reg_0_index, input [NUM_MUL*NUM_WR*DATA_WIDTH-1:0] write_reg_11_xor,
//FOR BRAM&DFU.
input [KEY_WIDTH-1:0] rd_key, input [1:0] rd_opt,
output reg [KEY_WIDTH-1:0] rd_key_out_next_stage, output reg [1:0] rd_opt_out_next_stage, // to determine whether rd_out is valid or not
output reg [NUM_MUL*NUM_WR*DATA_WIDTH-1:0] rd_out_all_update_next_stage );

	reg [KEY_WIDTH-1:0] rd_key_reg_2;
	reg [1:0] rd_opt_reg_2;
	wire [NUM_MUL*NUM_WR*DATA_WIDTH-1:0] rd_out_all_update;
	
	reg [1:0] rd_opt_out;
	reg [KEY_WIDTH-1:0] rd_key_out;
	
	genvar i;
	generate 
		for(i = 0; i < NUM_WR; i = i + 1) begin
			BRAM_DFU_and_update_URAM #(NUM_MUL, INDEX_WIDTH, DATA_WIDTH) MY_BRAM_DFU_u0 (.clk(clk), .reset(reset), .arbiter_result(arbiter_result[NUM_MUL*i+:NUM_MUL]), .write_reg_0_valid(write_reg_0_valid[i]),
			.rd_index(rd_index), 
	.write_reg_0_index(write_reg_0_index[INDEX_WIDTH*i+:INDEX_WIDTH]), .write_reg_11_xor(write_reg_11_xor[NUM_MUL*DATA_WIDTH*i+:NUM_MUL*DATA_WIDTH]), 
	.rd_out_update(rd_out_all_update[NUM_MUL*DATA_WIDTH*i+:NUM_MUL*DATA_WIDTH]));
		end

	endgenerate
	
	always @(posedge clk) begin
		if(reset) begin
			rd_opt_reg_2 <= 0;
			rd_opt_out <= 0;
		end
		else begin
		//-----------------first stage--------------------------//
			rd_opt_reg_2 <= rd_opt;
			rd_key_reg_2 <= rd_key;
		//-----------------second stage--------------------------//
			rd_opt_out <= rd_opt_reg_2;
			rd_key_out <= rd_key_reg_2;
		//----------------after_BRAM_first update--------------------//
			rd_out_all_update_next_stage <= rd_out_all_update;
			rd_opt_out_next_stage <= rd_opt_out;
			rd_key_out_next_stage <= rd_key_out;
		end
	
	end
endmodule
	