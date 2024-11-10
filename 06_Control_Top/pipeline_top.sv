import riscv_types::*;
module pipeline_top(
    // Declaration of I/O
    input  logic 		clk_i, 
    input  logic 		rst_ni,
    input  logic [31:0] io_button_i	,
	input  logic [31:0] io_sw_i		,	
	output logic [31:0] io_hex0_o	,
	output logic [31:0] io_hex1_o	,
	output logic [31:0] io_hex2_o	,
	output logic [31:0] io_hex3_o	,
	output logic [31:0] io_hex4_o	,
	output logic [31:0] io_hex5_o	,
	output logic [31:0] io_hex6_o	,
	output logic [31:0] io_hex7_o	,
	output logic [31:0] io_ledr_o	,
	output logic [31:0] io_ledg_o	,
	output logic [31:0] io_lcd_o
  );
    execute_info 	execute_signals		;
    memory_info 	memory_signals		;
    writeback_info 	writeback_signals	;

	wire logic stall		;
    wire logic flush_E_M_reg;
	
	// wire decode
	wire logic [31:0] instr_D	;
	wire logic [ 4:0] rs1_addr_D;
	wire logic [ 4:0] rs2_addr_D;
	wire logic [31:0] pc_D		;  
	
	// wire execute
	wire logic [ 4:0] 	rs1_addr_D_E;
	wire logic [ 4:0] 	rs2_addr_D_E;
	wire logic [31:0] 	rs1_data_D_E;
	wire logic [31:0] 	rs2_data_D_E;
	wire logic [31:0] 	rs1_data_E	;
	wire logic [31:0] 	rs2_data_E	;
	wire logic 			is_taken_E	;
	wire logic [31:0] 	pc_bru_E	;
	wire logic [31:0] 	pc_E		;
	
	// wire memory_cycle
	wire logic [31:0] 	Result_M	;
	wire logic [31:0] 	rs2_data_M	;
	
	// wire write back
	wire logic [ 4:0] 	rd_addr_W	;
	wire logic [31:0]  	rd_data_W	;
	wire logic 			rd_wr_W		;
	wire logic [31:0] 	ld_data_W	;
	wire logic [31:0] 	Result_W	;
	
	// wire hazard unit
	wire logic [ 1:0] 	forward_rs1		;
	wire logic [ 1:0] 	forward_rs2		;
	wire logic [ 1:0]	forward_decode	;
	
    // Module Initiation
    // Fetch Stage
    fetch_cycle Fetch (
            .clk_i(clk_i), 
            .rst_ni(rst_ni),
            .stall(stall),
            .is_taken_E(is_taken_E),
            .pc_bru_E(pc_bru_E),
            .instr_D(instr_D),
            .pc_D(pc_D)
            );
			
    // Decode Stage
    decode_cycle Decode (
            .clk_i(clk_i),
            .rst_ni(rst_ni),
            .stall(stall),
            .forward_decode(forward_decode),
            .instr_D(instr_D),
            .rd_wr_W(rd_wr_W),
            .rd_addr_W(rd_addr_W),
           	.rd_data_W(rd_data_W),
            .pc_D(pc_D), 
            .execute_signals(execute_signals),
            .rs1_addr_D(rs1_addr_D),
            .rs2_addr_D(rs2_addr_D),
            .rs1_data_D_E(rs1_data_D_E),
            .rs2_data_D_E(rs2_data_D_E),
            .pc_E(pc_E)
            );

    // Execute Stage
    execute_cycle Execute (
            .clk_i(clk_i),
            .rst_ni(rst_ni),
            .stall(stall),
            .flush(flush_E_M_reg),
            .execute_signals(execute_signals),
            .forward_rs1(forward_rs1),
            .forward_rs2(forward_rs2),
            .rs1_data_D_E(rs1_data_D_E),
            .rs2_data_D_E(rs2_data_D_E),
            .rs1_addr_D_E(rs1_addr_D_E),
            .rs2_addr_D_E(rs2_addr_D_E),
            .rd_data_W(rd_data_W),
            .pc_E(pc_E),
            .is_taken_E(is_taken_E),
            .pc_bru_E(pc_bru_E),
            .memory_signals(memory_signals),
            .Result_M(Result_M),
            .rs2_data_M(rs2_data_M)
            );

    // Memory Stage
    memory_cycle Memory (
		.clk_i(clk_i), 
		.rst_ni(rst_ni), 
		.memory_signals(memory_signals),
		.Result_M(Result_M),
		.rs2_data_M(rs2_data_M),
		.writeback_signals(writeback_signals),
		.Result_W(Result_W),
		.ld_data_W(ld_data_W),
		.io_button_i(io_button_i),
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

    // Write Back Stage
    writeback_cycle WriteBack (
		.clk_i(clk_i), 
		.rst_ni(rst_ni), 
		.writeback_signals(writeback_signals),
		.Result_W(Result_W), 
		.ld_data_W(ld_data_W),
		.rd_addr_W(rd_addr_W),
		.rd_data_W(rd_data_W),
		.rd_wr_W(rd_wr_W)
	);
	
    // Hazard Unit
    hazard_unit hazard_unit(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.rd_wr_W(rd_wr_W),
		.rd_wr_M(memory_signals.rd_wren),
		.is_load_M(memory_signals.mem_load),
		.rs1_addr_D(rs1_addr_D),
		.rs2_addr_D(rs2_addr_D),
		.rs1_addr_D_E(rs1_addr_D_E),
		.rs2_addr_D_E(rs2_addr_D_E),
		.rd_addr_M(memory_signals.rd_addr),
		.rd_addr_W(rd_addr_W),
		.forward_rs1(forward_rs1),
		.forward_rs2(forward_rs2),
		.forward_decode(forward_decode),
		.stall(stall),
		.flush_E_M_reg(flush_E_M_reg)
    );
endmodule
