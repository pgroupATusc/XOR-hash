module top_hash_table_URAM (input clk, input reset, input [31:0] key_in, input [7:0] en_in, output [64-1:0] rd_xor_result);
	
	parameter NUM_MUL = 1;
	parameter NUM_RD = 16;
	parameter NUM_WR = 8;
	parameter VALUE_WIDTH = 31;
	parameter KEY_WIDTH = 32;
	parameter INDEX_WIDTH = 15;
	parameter DATA_WIDTH  = 64;
	
	reg [NUM_RD*32-1:0] key;
	reg [NUM_WR*31-1:0] value;
	reg [2*NUM_WR-1:0] opt;
	reg [NUM_WR-1:0] en;
	
	reg [10:0] count;
	wire [NUM_RD*64-1:0] rd_out_all_update_reg;

	hash_table_16_URAM #(NUM_MUL, NUM_RD, NUM_WR, VALUE_WIDTH, KEY_WIDTH, INDEX_WIDTH, DATA_WIDTH) hash_table_16_my (clk, reset, key, value, opt, en, rd_out_all_update_reg);
	
	
	
	 xor_all_URAM #(NUM_RD, DATA_WIDTH) xor_all_u0 (rd_out_all_update_reg, rd_xor_result);
/* 
	genvar j;
	generate 
		for(j = 0; j < NUM_RD; j = j+1) begin
			assign rd_out[j] = rd_out_all_update_reg[j*64+j+32];
		end
	endgenerate */
	
	integer i;
	always @(posedge clk) begin
		if(reset) begin
			count <= 0;
		end
		else begin
			key[count[0]*32+:32] <= key_in;
			value[count[2]*31+:31] <= key_in[30:0];
			en <= en_in;
			for(i = 0; i < NUM_RD; i = i + 1) begin
				key[i*32+19] <= en_in[i];
			end
			for(i = 0; i < NUM_WR; i = i + 1) begin
				opt[i*2+:2] <= key_in[i*2+:2];
			end
		end
	end
endmodule