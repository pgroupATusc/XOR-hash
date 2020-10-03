module and_q_k_URAM #(parameter INDEX_WIDTH = 12) (input k, input [INDEX_WIDTH-1:0] q, output [INDEX_WIDTH-1:0] out_and);
	wire [INDEX_WIDTH-1:0] k_12;
	assign k_12 = {INDEX_WIDTH{k}};
	assign out_and = q & k_12;
endmodule