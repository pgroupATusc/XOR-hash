module hash_function_URAM #(parameter KEY_WIDTH = 32, parameter INDEX_WIDTH = 12, parameter VALUE_WIDTH = 31)(input clk, input reset, input [KEY_WIDTH-1:0] key, input [VALUE_WIDTH-1:0] value_in, input en_in, input [1:0] opt_in,
 output en_out, output [INDEX_WIDTH-1:0] index, output [VALUE_WIDTH-1:0] value_out, output [1:0] opt_out, output [KEY_WIDTH-1:0] key_out);

//-----------signal---------------//
	reg [INDEX_WIDTH-1:0] hash_index;
	reg [VALUE_WIDTH-1:0] value_reg;
	reg en_reg;
	reg [1:0] opt_reg;
	reg [KEY_WIDTH-1:0] key_reg;
//-----------assign output----------------//	
	assign value_out = value_reg;
	assign en_out = en_reg;
	assign index = hash_index;
	assign opt_out = opt_reg;
	assign key_out = key_reg;
	
//--------------internal module signal-----------//	
	wire [INDEX_WIDTH*KEY_WIDTH - 1:0] hash_q_out;
	wire [INDEX_WIDTH-1:0] stage_out [KEY_WIDTH:0];

	
//---------------u_module-------------///
	hash_q_URAM #(KEY_WIDTH, INDEX_WIDTH)  u_hash_q (hash_q_out);
	assign stage_out[0] = 0;
	genvar i;
	generate 
		for(i = 0; i < KEY_WIDTH; i = i + 1) begin
			stage_URAM #(INDEX_WIDTH) u_stage_0 (key[i], hash_q_out[INDEX_WIDTH*i+:INDEX_WIDTH], stage_out[i], stage_out[i+1]);
		end
	endgenerate 
	
//----------------always block----------//
	always @(posedge clk) begin
		if(reset) begin
			en_reg <= 0;
			opt_reg <= 0;
			value_reg <= 0;
			hash_index <= 0;
			key_reg <= 0;
		end
		else begin
			en_reg <= en_in;
			opt_reg <= opt_in;
			value_reg <= value_in;
			hash_index <= stage_out[KEY_WIDTH];
			key_reg <= key;
			
		end
	end
endmodule
			