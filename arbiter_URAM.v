module arbiter_URAM #(parameter NUM_WR = 8, parameter NUM_MUL = 4, parameter DATA_WIDTH = 64, parameter KEY_WIDTH = 32) (input [NUM_MUL*NUM_WR*DATA_WIDTH-1:0] rd_BRAM_out, input [KEY_WIDTH-1:0] key_rd, input [NUM_MUL-1:0] opt_rd, 
output [NUM_MUL-1:0] arbiter_result);
//key_rd, the key of write. opt_rd, the opt of rd_BRAM_out.
// key and opt can be gave by DFU.
// opt_rd only 1 bit, because we only need to care it is write/del.

	wire [DATA_WIDTH-1:0] rd_xor_result [NUM_MUL-1:0];
	
	wire [NUM_MUL-1:0] compare_result;
	wire [NUM_MUL-1:0] rd_valid;
	reg [NUM_MUL-1:0] write_only_arbiter;
	
//--------------------------xor NUM_WR elements, NUL_MUL results--------------------------//	
	genvar i;
	generate 
		for(i = 0; i < NUM_MUL; i = i + 1) begin
			xor_all_URAM #(NUM_WR, DATA_WIDTH) xor_all_u0 (rd_BRAM_out[NUM_WR*DATA_WIDTH*i+:NUM_WR*DATA_WIDTH], rd_xor_result[i]);
		end
	endgenerate
//---------------------------generate the compare results--------------------------//	
	generate
		for(i = 0; i < NUM_MUL; i = i + 1) begin
			assign compare_result[i] = (rd_xor_result[i][KEY_WIDTH-1:0] == key_rd)&&(rd_valid[i] == 1'b1);
		end
	endgenerate
//---------------------------rd valid-------------------------------------------//
	generate
		for(i = 0; i < NUM_MUL; i = i + 1) begin
			assign rd_valid[i] = rd_xor_result[i][DATA_WIDTH-1];
		end
	endgenerate
//---------------------------if opt is write, which place to write----------------------//
	integer j;
	always @(*) begin
		write_only_arbiter = 0;
		for(j = 0; j < NUM_MUL; j = j + 1) begin
			if(rd_valid[j] == 1'b0) begin	// if this place is empty, we could write here.
				write_only_arbiter = 0;
				write_only_arbiter[j] = 1'b1;
			end
		end
	end
//------------------------------arbiter_result--------------------------------------//
	assign arbiter_result = (opt_rd || compare_result) ? compare_result : write_only_arbiter;
	//if opt_rd == 1(del), arbiter_result = compare_result. else, it is write. if compare_result == 0, it means, this is write. else, this is update.
endmodule