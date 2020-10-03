module URAM_pack #(parameter INDEX_WIDTH =12, parameter DATA_WIDTH  = 64)
(input reset, input clock, input ena, input enb, input wr_en, input [INDEX_WIDTH-1:0] wr_addr, input [DATA_WIDTH-1:0] wr_data, input [INDEX_WIDTH-1:0] rd_addr, output [DATA_WIDTH-1:0] rd_data);

/* input [INDEX_WIDTH-1:0]BRAM_PORTA_0_addr, input BRAM_PORTA_0_clk,  input [DATA_WIDTH-1:0]BRAM_PORTA_0_din, input BRAM_PORTA_0_en,  input [0:0]BRAM_PORTA_0_we,
input [INDEX_WIDTH-1:0]BRAM_PORTB_0_addr,   input BRAM_PORTB_0_clk, output reg [DATA_WIDTH-1:0]BRAM_PORTB_0_dout_reg, input BRAM_PORTB_0_en);


  wire [DATA_WIDTH-1:0]BRAM_PORTB_0_dout; */
/*   reg wr_en_reg;
  reg [INDEX_WIDTH-1:0] wr_addr_reg;
  reg [DATA_WIDTH-1:0] wr_data_reg;
  reg ena_reg;
 */
 xpm_memory_sdpram #(
         .ADDR_WIDTH_A(INDEX_WIDTH),// DECIMAL
         .ADDR_WIDTH_B(INDEX_WIDTH),// DECIMAL
     //    .BYTE_WRITE_WIDTH_A(8),         // DECIMAL
         .CLOCKING_MODE("common_clock"), // String
         .ECC_MODE("no_ecc"),            // String
         .MEMORY_PRIMITIVE("ultra"),      // String
         .MEMORY_SIZE((2**INDEX_WIDTH)*DATA_WIDTH),  // DECIMAL
         .READ_DATA_WIDTH_B(DATA_WIDTH), // DECIMAL
         .READ_LATENCY_B(5),// DECIMAL
         .WRITE_DATA_WIDTH_A(DATA_WIDTH),// DECIMAL
         .WRITE_MODE_B("read_first"))    // String
      hash_table_block (
         .rstb(reset),
         .clka(clock),
         .ena(ena),
         .wea(wr_en),
         .addra(wr_addr),
         .dina(wr_data),
         .enb(enb),
         .addrb(rd_addr),
         .doutb(rd_data),
         .regceb(1'b1),
		 .clkb(clock),
		 .sleep(1'b0) 
		 );
	
  

     
      /* .sleep(sleep),                   // 1-bit input: sleep signal to enable the dynamic power saving feature. */
/* 	  always @(posedge clock) begin
		wr_en_reg <= wr_en;
		wr_addr_reg <= wr_addr;
		wr_data_reg <= wr_data;
		ena_reg <= ena;
	end
	   */
	  
    
  endmodule