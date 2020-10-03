`timescale 1ns/1ps
module tb_hash_table_16_3_stage;

	reg clk;
	reg reset;
	parameter NUM_MUL = 1;
	parameter NUM_RD = 2;
	parameter NUM_WR = 2;
	parameter KEY_WIDTH = 32;
	parameter INDEX_WIDTH = 15;
	parameter DATA_WIDTH = 64;
	parameter VALUE_WIDTH = 31;
	reg [NUM_RD*32-1:0] key;
	reg [NUM_WR*31-1:0] value;
	reg [2*NUM_WR-1:0] opt;
	reg [NUM_WR-1:0] en_in;
	wire  [NUM_RD*64-1:0] rd_out_all_update_reg;
	
hash_table_16_URAM #(NUM_MUL, NUM_RD, NUM_WR, VALUE_WIDTH, KEY_WIDTH, INDEX_WIDTH, DATA_WIDTH) MY_hash_table_16 
 (.clk(clk), .reset(reset),
 .key(key), .value(value), 
 .opt(opt), .en_in(en_in), 
 .rd_out_final(rd_out_all_update_reg)
);

	initial begin
		clk = 1;
		forever begin
			#5;
			clk = ~clk;
		end
	end

	integer i;
	integer count; 
	initial begin
		count = 0;
		reset <= 1;
		repeat (2) @(posedge clk);
		reset <= 0;
		en_in <= {NUM_WR{1'b1}};
		
 		repeat (4) begin
			for(i = 0; i < NUM_RD; i = i + 1) begin
				key[i*32+:32] <= count;
				count = count + 1;
			end
			for(i = 0; i < NUM_WR; i = i + 1) begin
				value[i*31+:31] <= $urandom%(10);
				opt[i*2+:2] <= 2'b01;//write
			end
			@(posedge clk);
		end
		
 		count = 1;
 		repeat (4) begin
			for(i = 0; i < NUM_RD; i = i + 1) begin
			    
				key[i*32+:32] <= count;
				count = count + 1;
			end
			for(i = 0; i < NUM_WR; i = i + 1) begin
				value[i*31+:31] <= $urandom%(10);
				opt[i*2+:2] <= 2'b01;//write
			end
			@(posedge clk);
		end   
 /* 		for(i = 0; i < NUM_RD; i = i + 1) begin
			key[i*32+:32] <= $urandom%(5);
	//		count = count + 1;
		end
		for(i = 0; i < NUM_WR; i = i + 1) begin
			value[i*31+:31] <= $urandom%(10);
			opt[i*2+:2] <= 2'b01;//write
		end
		@(posedge clk);
		 
		 
 */		count = 0; 
		repeat (4) begin
			for(i = 0; i < NUM_RD; i = i + 1) begin	
				
				key[i*32+:32] <= count;
				count = count + 1;
			end
			for(i = 0; i < NUM_WR; i = i + 1) begin
			//	value[i*31+:31] <= $urandom%(10);
				opt[i*2+:2] <= 2'b00;//read
			end
			@(posedge clk);
		end 
		#1000;
		$finish;
	end
endmodule
		
	