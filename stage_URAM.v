module stage_URAM #(parameter INDEX_WIDTH = 12) (input k, input [INDEX_WIDTH-1:0] q, input [INDEX_WIDTH-1:0] pre, output [INDEX_WIDTH-1:0] out);
	
	
//------------------output of and ------------------------------------//
	wire [INDEX_WIDTH-1:0] out_and;



//------------------u_module---------------------------------------------//
	and_q_k_URAM #(INDEX_WIDTH)  u_and (k, q, out_and);
	xor_ab_URAM #(INDEX_WIDTH) u_xor (pre, out_and, out);
	
endmodule 
