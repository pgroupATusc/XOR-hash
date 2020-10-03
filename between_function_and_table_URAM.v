module between_function_and_table_URAM #(parameter NUM_MUL = 4, parameter NUM_WR = 8, parameter INDEX_WIDTH = 12, parameter VALUE_WIDTH = 31, parameter KEY_WIDTH = 32, parameter DATA_WIDTH = 64)
 (input [INDEX_WIDTH-1:0] index_in, input [VALUE_WIDTH-1:0] value_in, input en_in, input [1:0] opt_in, input [KEY_WIDTH-1:0] key_in, 
input [NUM_MUL*(NUM_WR-1)*DATA_WIDTH-1:0] rd_BRAM_out_other,
input clk, input reset,
output [NUM_MUL*DATA_WIDTH-1:0] write_reg_11_xor, output reg [INDEX_WIDTH-1:0] write_reg_0_index, output write_reg_0_valid, output write_reg_1_valid,
output reg [INDEX_WIDTH-1:0] write_reg_1_index //use as write address
);
//opt: 11 del, 01 write, 00, read,


	reg [DATA_WIDTH-1:0] write_reg_0;
	reg write_en_reg_0;
	reg [DATA_WIDTH-1:0] write_reg_1;
	reg write_en_reg_1;
	reg [DATA_WIDTH-1:0] write_reg_11;
	
	wire [(NUM_WR)*DATA_WIDTH-1:0] in_xor_all [NUM_MUL-1:0];
	wire [DATA_WIDTH-1:0] write_0;
	
	assign write_0[KEY_WIDTH+VALUE_WIDTH] = ~opt_in[1];// if it is del, valid = 0, if it is write, valid - 1. if it is read, write_en will be 0.
	assign write_0[KEY_WIDTH+VALUE_WIDTH-1:KEY_WIDTH] = value_in;
	assign write_0[KEY_WIDTH-1:0] = key_in;
	assign write_reg_0_valid = write_en_reg_0;
	assign write_reg_1_valid = write_en_reg_1;
	genvar i;
	generate 
		for(i = 0; i < NUM_MUL; i = i + 1) begin
			assign in_xor_all[i][NUM_WR*DATA_WIDTH-1:DATA_WIDTH] = rd_BRAM_out_other[i*(NUM_WR-1)*DATA_WIDTH+:(NUM_WR-1)*DATA_WIDTH];
			assign in_xor_all[i][DATA_WIDTH-1:0] = write_reg_11;
		end
	endgenerate
//-----------------------xor to get write input-------------------------------//	
	generate 
		for(i = 0; i < NUM_MUL; i = i + 1) begin
			xor_all_URAM #(NUM_WR, DATA_WIDTH) xor_all_u0 (in_xor_all[i], write_reg_11_xor[DATA_WIDTH*i+:DATA_WIDTH]);
		end
	endgenerate
	
	always @(posedge clk) begin
		if(reset) begin
			write_en_reg_0 <= 0;
			write_en_reg_1 <= 0;
		end
		else begin
		//-------------------------stage 1----------------------------------------//
			write_en_reg_0 <= (opt_in && en_in);// opt_in != 00, && en_in != 0; 
			write_reg_0 <= write_0;
			write_reg_0_index <= index_in;
			
		//--------------------------stage 2-----------------------------------------//
			write_en_reg_1 <= write_en_reg_0;
			write_reg_1 <= write_reg_0;
			write_reg_1_index <= write_reg_0_index;
		//--------------------------stage 3-----------------------------------------//
			write_reg_11 <= write_reg_1;
		end
	
	end
	
endmodule