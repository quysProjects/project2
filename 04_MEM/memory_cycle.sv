import riscv_types::*;
module memory_cycle(
	input  logic 		clk_i				,
	input  logic 		rst_ni				,
	input  memory_info	memory_signals		,
	input  logic [31:0] Result_M			,
	input  logic [31:0] rs2_data_M			,

	output writeback_info writeback_signals	,
	output logic [31:0] Result_W			,
	output logic [31:0] ld_data_W			,
	input  logic [31:0] io_button_i			,
	input  logic [31:0] io_sw_i				,	
	output logic [31:0] io_hex0_o			,
	output logic [31:0] io_hex1_o			,
	output logic [31:0] io_hex2_o			,
	output logic [31:0] io_hex3_o			,
	output logic [31:0] io_hex4_o			,
	output logic [31:0] io_hex5_o			,
	output logic [31:0] io_hex6_o			,
	output logic [31:0] io_hex7_o			,
	output logic [31:0] io_ledr_o			,
	output logic [31:0] io_ledg_o			,
	output logic [31:0] io_lcd_o
);
    // Declaration of Interim Wires
    wire [31:0] ld_data_M;

    // Declaration of Interim Registers
    writeback_info memory_writeback_reg;
    reg [31:0] Result_M_r; 
    reg [31:0] ld_data_M_r;

    // Declaration of Module Initiation
	lsu lsu(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.st_en_i(memory_signals.mem_wren),
		.addr_lsu_i(Result_M[11:0]),
		.st_data_i(rs2_data_M),
		.mask_i(memory_signals.mem_size),
		.unsign(memory_signals.mem_unsign),
		.io_button(io_button_i),
		.io_sw(io_sw_i),
		.ld_data_o(ld_data_M),
		.io_lcd(io_lcd_o),
		.io_ledg(io_ledg_o),
		.io_ledr(io_ledr_o),
		.io_hex0(io_hex0_o),
		.io_hex1(io_hex1_o),
		.io_hex2(io_hex2_o),
		.io_hex3(io_hex3_o),
		.io_hex4(io_hex4_o),
		.io_hex5(io_hex5_o),
		.io_hex6(io_hex6_o),
		.io_hex7(io_hex7_o) 
	);

    // Memory Stage Register Logic
	always @(posedge clk_i or negedge rst_ni) begin
		if (~rst_ni) begin
            memory_writeback_reg 	<= '{default:0};
            Result_M_r 				<= 32'd0; 
            ld_data_M_r 			<= 32'd0;
        end else begin
            memory_writeback_reg.rd_wren 	<= memory_signals.rd_wren;
            memory_writeback_reg.rd_addr 	<= memory_signals.rd_addr;            
            memory_writeback_reg.mem_load 	<= memory_signals.mem_load;
            Result_M_r 		<= Result_M; 
            ld_data_M_r 	<= ld_data_M;
        end
    end 

    // Declaration of output assignments
    assign writeback_signals = memory_writeback_reg;
    assign Result_W = Result_M_r;
    assign ld_data_W = ld_data_M_r;
    
endmodule