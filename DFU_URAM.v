module DFU_URAM #(parameter NUM_MUL = 4, parameter INDEX_WIDTH = 12, parameter DATA_WIDTH = 64) (input clk, input reset, input [NUM_MUL*DATA_WIDTH-1:0] write_reg_11_xor, 
input [INDEX_WIDTH-1:0] write_reg_0_index, input [INDEX_WIDTH-1:0] write_reg_1_index, input write_reg_0_valid, 
input write_reg_1_valid, input [INDEX_WIDTH-1:0] rd_index, 
input [NUM_MUL-1:0] arbiter_result,
output [NUM_MUL-1:0] update_result_senior_1, output reg [NUM_MUL-1:0] update_result_senior_2,  output reg [NUM_MUL*DATA_WIDTH-1:0] write_reg_help_xor, 
output reg [NUM_MUL-1:0] update_result_senior_3, output reg [NUM_MUL*DATA_WIDTH-1:0] write_help_xor_senior_3_out);
// write_reg_0_index, the index of write_reg_0, rd_index, the index of current read.

	reg [NUM_MUL-1:0] valid_and_same[2:0]; 
	// it only have two value: 000000, or , 111111(all 0 or all 1);
	 reg [NUM_MUL-1:0] valid_and_same_0;
	 reg [INDEX_WIDTH-1:0] write_reg_11_index;
	 reg write_reg_11_valid;
	 
	 reg [NUM_MUL*DATA_WIDTH-1:0] write_help_xor_senior_3;
	
	assign update_result_senior_1 = valid_and_same_0 & arbiter_result;
	
	always @(posedge clk) begin
		if(reset) begin
			valid_and_same[1] <= 0;
			valid_and_same[0] <= 0;
			valid_and_same[2] <= 0;
			write_reg_help_xor <= 0;
			update_result_senior_2 <= 0;
		end
		else begin
		//----------------------before---------------------------------//
			write_reg_11_index <= write_reg_1_index;
			write_reg_11_valid <= write_reg_1_valid;
		// -----------------first stage------------------------------//
			write_help_xor_senior_3 <= write_reg_11_xor;
		
			if((rd_index == write_reg_0_index) && write_reg_0_valid) begin
				valid_and_same[0] <= {NUM_MUL{1'b1}};
			end
			else begin
				valid_and_same[0] <= 0;
			end
			if((rd_index == write_reg_1_index) && write_reg_1_valid) begin
				valid_and_same[1] <= {NUM_MUL{1'b1}};
			end
			else begin
				valid_and_same[1] <= 0;
			end
			
			if((rd_index == write_reg_11_index) && write_reg_11_valid) begin
				valid_and_same[2] <= {NUM_MUL{1'b1}} & arbiter_result;
			end
			else begin
				valid_and_same[2] <= 0;
			end
			
		//---------------------second stage -------------------------//
			write_help_xor_senior_3_out <= write_help_xor_senior_3;
			write_reg_help_xor <= write_reg_11_xor;
			update_result_senior_2 <= arbiter_result & valid_and_same[1];
			update_result_senior_3 <= valid_and_same[2];
			valid_and_same_0 <= valid_and_same[0];
		end
	end
endmodule

	