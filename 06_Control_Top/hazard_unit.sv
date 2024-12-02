import riscv_types::*;
module hazard_unit(
	input  logic 		clk_i		,
	input  logic 		rst_ni		,
	input  logic 		rd_wr_W		,
	input  logic 		rd_wr_M		,
	input  logic [4:0] 	rs1_addr_D	,
	input  logic [4:0] 	rs2_addr_D	,
	input  logic [4:0] 	rs1_addr_D_E	,
	input  logic [4:0] 	rs2_addr_D_E	,
	input  logic [4:0] 	rd_addr_M	,
	input  logic [4:0] 	rd_addr_W	,
	input  logic 		is_load_M	,
	
	output logic [1:0] 	forward_rs1	,
	output logic [1:0] 	forward_rs2	,
	output logic [1:0] 	forward_decode	,
	output logic 		stall		,
	output logic 		flush_E_M_reg
);

	always_comb begin
		if ((rd_wr_M) & (rd_addr_M != 5'd0) & is_load_M & ((rd_addr_M == rs1_addr_D_E) | (rd_addr_M == rs2_addr_D_E))) begin
			stall = 1'b1;  
		end else begin
			stall = 1'b0;
		end
	end
  
	always_comb begin
		if ((stall) & (rd_wr_W) & (rd_addr_W != 5'd0) & ((rd_addr_W == rs1_addr_D_E) | (rd_addr_W == rs2_addr_D_E))) begin
			flush_E_M_reg = 1'b1;
		end else begin
			flush_E_M_reg = 1'b0;
		end
	end
  
 
	assign forward_rs1 = 	(!rst_ni)? 									2'b00:
                      		((rd_wr_M)& (rd_addr_M != 5'd0) & (!is_load_M) & (rd_addr_M == rs1_addr_D_E))? 	2'b10:
                      		((rd_wr_W)& (rd_addr_W != 5'd0) & (rd_addr_W == rs1_addr_D_E))? 		2'b01: 2'b00;
	
	assign forward_rs2 = 	(!rst_ni)? 									2'b00:
                      		((rd_wr_M)& (rd_addr_M != 5'd0) & (!is_load_M) & (rd_addr_M == rs2_addr_D_E))? 	2'b10:
                      		((rd_wr_W)& (rd_addr_W != 5'd0) & (rd_addr_W == rs2_addr_D_E))? 		2'b01: 2'b00;    
	
	assign forward_decode = (!rst_ni)? 						      2'b00:
				((rd_wr_W)& (rd_addr_W != 5'd0) & (rd_addr_W == rs1_addr_D))? 2'b01:
                         	((rd_wr_W)& (rd_addr_W != 5'd0) & (rd_addr_W == rs2_addr_D))? 2'b10: 2'b00; 
endmodule

