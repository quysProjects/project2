import riscv_types::*;
module writeback_cycle(
	input  logic 		clk_i			,
	input  logic 		rst_ni			,
	
	input  writeback_info 	writeback_signals	,
	input  logic [31:0] 	Result_W		,
	input  logic [31:0] 	ld_data_W		,

	output logic [ 4:0] 	rd_addr_W		,
	output logic [31:0] 	rd_data_W		,
	output logic 		rd_wr_W
);

	assign rd_data_W = (writeback_signals.mem_load)? ld_data_W : Result_W;

	assign rd_addr_W = writeback_signals.rd_addr;
  
	assign rd_wr_W = writeback_signals.rd_wren;
  
endmodule
