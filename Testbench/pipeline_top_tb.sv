module pipeline_top_tb(
  );
  logic clk_i;
  logic rst_ni;
	logic [31:0] io_sw_i;
	logic [31:0] io_button_i;
	logic [31:0] io_hex0_o;
	logic [31:0] io_hex1_o;
	logic [31:0] io_hex2_o;
	logic [31:0] io_hex3_o;
	logic [31:0] io_hex4_o;
	logic [31:0] io_hex5_o;
	logic [31:0] io_hex6_o;
	logic [31:0] io_hex7_o;
	logic [31:0] io_ledr_o;
	logic [31:0] io_ledg_o;
	logic [31:0] io_lcd_o;
  
pipeline_top DUT(
  .clk_i(clk_i),
  .rst_ni(rst_ni),
  .io_button_i,
	.io_sw_i(io_sw_i),	
	 .io_hex0_o(io_hex0_o),
	 .io_hex1_o(io_hex1_o),
	 .io_hex2_o(io_hex2_o),
	 .io_hex3_o(io_hex3_o),
	 .io_hex4_o(io_hex4_o),
	 .io_hex5_o(io_hex5_o),
	 .io_hex6_o(io_hex6_o),
	 .io_hex7_o(io_hex7_o),
	 .io_ledr_o(io_ledr_o),
	 .io_ledg_o(io_ledg_o),
	 .io_lcd_o(io_lcd_o)
);

initial begin
		clk_i = 1'b1;
  end
  always #50 clk_i=~clk_i;
  
  initial begin  
  rst_ni = 1'b0;
  #20
  rst_ni = 1'b1; 
  #10
  io_sw_i= 32'h00000021;
  #400000
  io_sw_i=32'h01111000;
  #600000
  io_sw_i=32'h18334891;
  #60000000
  io_sw_i=32'h01111000;
   end
   
     
endmodule	