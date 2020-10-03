module BRAM_DFU_and_update_URAM #(parameter NUM_MUL = 4, parameter INDEX_WIDTH = 12, parameter DATA_WIDTH = 64)
 (input clk, input reset, input [NUM_MUL-1:0] arbiter_result, input write_reg_0_valid, input [INDEX_WIDTH-1:0] rd_index, 
input [INDEX_WIDTH-1:0] write_reg_0_index, input [NUM_MUL*DATA_WIDTH-1:0] write_reg_11_xor, 
output [NUM_MUL*DATA_WIDTH-1:0] rd_out_update
);


	wire [DATA_WIDTH-1:0] rd_out [NUM_MUL-1:0];
	reg [INDEX_WIDTH-1:0] write_reg_1_index;
	reg [INDEX_WIDTH-1:0] write_reg_11_index;
	reg write_reg_1_valid;
	reg write_reg_11_valid;
	wire [NUM_MUL-1:0] update_result_senior_2;
	wire [NUM_MUL-1:0] update_result_senior_1;
	wire [NUM_MUL*DATA_WIDTH-1:0] write_reg_help_xor;
	
	wire [NUM_MUL-1:0] update_result_senior_3;
	wire [NUM_MUL*DATA_WIDTH-1:0] write_help_xor_senior_3_out;
	
	//------------------extra input stage ----------------------------------//
	reg [NUM_MUL*DATA_WIDTH-1:0] write_reg_11_xor_0_stage;
	reg [NUM_MUL-1:0] arbiter_result_0_stage;
	
	reg [INDEX_WIDTH-1:0] write_reg_11_index_0_stage;
	reg write_reg_11_valid_0_stage;
	
	
	//--------------------DFU_16--------------------------------------------//
/* 	DFU_URAM #(NUM_MUL, INDEX_WIDTH, DATA_WIDTH) DFU_16_0 (.clk(clk), .reset(reset), .write_reg_11_xor(write_reg_11_xor), .write_reg_0_index(write_reg_0_index), 
	.write_reg_1_index(write_reg_1_index), .write_reg_0_valid(write_reg_0_valid),
	.write_reg_1_valid(write_reg_1_valid),
		.rd_index(rd_index), .arbiter_result(arbiter_result), 
	.update_result_senior_1(update_result_senior_1), .update_result_senior_2(update_result_senior_2), .write_reg_help_xor(write_reg_help_xor),
	 .update_result_senior_3(update_result_senior_3), .write_help_xor_senior_3_out(write_help_xor_senior_3_out));
 */

	//--------------------------------BRAM---------------------------------//
	genvar i;
	generate 
		for( i = 0; i < NUM_MUL; i = i + 1) begin
			URAM_pack #(INDEX_WIDTH, DATA_WIDTH)	my_URAM_0// port A write, port B read
				(.reset(reset),
				.clock(clk),
				.ena(write_reg_11_valid_0_stage),
				.enb(1'b1),
				.wr_en(arbiter_result_0_stage[i]),
				.wr_addr(write_reg_11_index_0_stage),
				.wr_data(write_reg_11_xor_0_stage[DATA_WIDTH*i+:DATA_WIDTH]),
				.rd_addr(rd_index),
				.rd_data(rd_out[i])
				);
/* 				(.BRAM_PORTA_0_addr(write_reg_11_index),
				.BRAM_PORTA_0_clk(clk),
				.BRAM_PORTA_0_din(write_reg_11_xor[DATA_WIDTH*i+:DATA_WIDTH]),
				.BRAM_PORTA_0_en(write_reg_11_valid),
				.BRAM_PORTA_0_we(arbiter_result[i]),
				.BRAM_PORTB_0_addr(rd_index),
				.BRAM_PORTB_0_clk(clk),
				.BRAM_PORTB_0_dout_reg(rd_out[i]),
				.BRAM_PORTB_0_en(1'b1)); */
		end
	endgenerate	
/* 	(input [11:0]BRAM_PORTA_0_addr, input BRAM_PORTA_0_clk,  input [63:0]BRAM_PORTA_0_din, input BRAM_PORTA_0_en,  input [0:0]BRAM_PORTA_0_we,
input [11:0]BRAM_PORTB_0_addr,   input BRAM_PORTB_0_clk, output [63:0]BRAM_PORTB_0_dout_reg, input BRAM_PORTB_0_en); */

  //--------------------------update result---------------------------------//
	generate
		for(i = 0; i < NUM_MUL; i = i + 1) begin
/* 			assign rd_out_update[i*DATA_WIDTH+:DATA_WIDTH] = update_result_senior_1[i] ? write_reg_11_xor: (update_result_senior_2[i] ? write_reg_help_xor[DATA_WIDTH*i+:DATA_WIDTH] : 
			( update_result_senior_3[i] ? write_help_xor_senior_3_out[DATA_WIDTH*i+:DATA_WIDTH] :rd_out[i])); */
			
			assign rd_out_update[i*DATA_WIDTH+:DATA_WIDTH] = rd_out[i];
		end
	endgenerate
	
	
	always @(posedge clk) begin
		write_reg_1_index <= write_reg_0_index;
		write_reg_1_valid <= write_reg_0_valid;
		
		write_reg_11_index <= write_reg_1_index;
		write_reg_11_valid <= write_reg_1_valid;
		
		//--------------extra stage-----------------------//
		write_reg_11_xor_0_stage <= write_reg_11_xor;
		arbiter_result_0_stage <= arbiter_result;
		write_reg_11_index_0_stage <= write_reg_11_index;
		write_reg_11_valid_0_stage <= write_reg_11_valid;
	
	end
	
	
endmodule