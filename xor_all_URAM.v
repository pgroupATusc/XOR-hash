module xor_all_URAM #(parameter NUM_XOR = 16, parameter DATA_WIDTH = 64) (input [NUM_XOR*DATA_WIDTH-1:0] in, output [DATA_WIDTH-1:0] out);
	wire [DATA_WIDTH-1:0] internal [NUM_XOR-1-1:0];	//NUM_XOR-1 internal
	
	genvar i;
	generate 
		for(i = 0; i < NUM_XOR/2; i = i + 1) begin
			assign internal[i] = in[DATA_WIDTH*i*2+:DATA_WIDTH] ^ in[DATA_WIDTH*(2*i+1)+:DATA_WIDTH];
		end
		for(i = NUM_XOR/2; i < NUM_XOR-1; i = i + 1) begin
			assign internal[i] = internal[2*(i-NUM_XOR/2)] ^ internal[2*(i-NUM_XOR/2)+1];
		end
	endgenerate
	assign out = internal[NUM_XOR-1-1];
endmodule
	