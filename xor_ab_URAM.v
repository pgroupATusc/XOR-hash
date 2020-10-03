module xor_ab_URAM #(parameter INDEX_WIDTH = 12) (input [INDEX_WIDTH-1:0] a, input [INDEX_WIDTH-1:0] b, output [INDEX_WIDTH-1:0] out_or);
	assign out_or = a^b;
endmodule