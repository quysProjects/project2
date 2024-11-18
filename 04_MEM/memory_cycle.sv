import riscv_types::*;
module memory_cycle#(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
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


    // Control Signals
    logic [1:0]             HTRANS ;   // Transfer type
    logic                   HWRITE ;   // Write enable
    logic [2:0]             HSIZE ;    // Transfer size
    logic [2:0]             HBURST ;   // Burst type
    logic [3:0]             HPROT ;    // Protection contro
    // Address and Data
    logic [ADDR_WIDTH-1:0]  HADDR;     // Address bus
    logic [DATA_WIDTH-1:0]  HWDATA;    // Write data bus
    logic [DATA_WIDTH-1:0]  HRDATA;    // Read data bus
    // Transfer Response
    logic                    HREADY;    // Transfer done
    logic                    HRESP  ;  // Transfer response
    //Additional Signals to LSU
	logic     				o_mngr_sub_unsign;
    // Master Interface Signals
    logic                    req_ready ; // Ready to accept request
    logic                    resp_valid; // Response valid,having data for CPU reading
    logic [DATA_WIDTH-1:0]   resp_rdata ; // Read data (ld_data_o)
    // Declaration of Interim Wires
    wire [31:0] ld_data_M;

    // Declaration of Interim Registers
    writeback_info memory_writeback_reg;
    reg [31:0] Result_M_r; 
    reg [31:0] ld_data_M_r;

    // Declaration of Module Initiation
	// Connect to Manager_AHB
	 // Clock and Reset
Manager_AHB Master(
    .HCLK(clk_i),
    .HRESETn(rst_ni),
    .HTRANS(HTRANS), 
    .HWRITE(HWRITE),
    .HSIZE(HSIZE),     // Transfer size**
    .HBURST(BURST),    // Burst type***
    .HPROT(HPROT),  
    .HADDR(HADDR),    
    .HWDATA(HWDATA),
    .HRDATA(HRDATA),
    .HREADY(1'b1), 
    .HRESP(1'b0),     // Transfer response***
    .i_core_mngr_unsign(memory_signals.mem_unsign),
     .o_mngr_sub_unsign(unsign),//****
    .req_read(memory_signals.mem_load), 
    .req_write(memory_signals.mem_wren),  
    .req_addr(Result_M),
    .req_wdata(rs2_data_M),  
    .req_size(memory_signals.mem_size),   
    .req_burst(3'd0),  // Burst type***		
    .req_ready(req_ready),  // Ready to accept request***
    .resp_valid(resp_valid), 
    .resp_rdata(ld_data_M)  
); 	


	/*Subordinate_LSU Slave(
	.HCLK(clk_i),
	.HRESETn(rst_ni),
	.HSEL_MEM(HSEL_MEM),//****
	.HADDR(HADDR),
	.HWRITE(HWRITE),
	.HSIZE(HSIZE) ,
	.HBURST(BURST),
	.HPROT(HPROT),
	.HTRANS(HTRANS),
	.HMASTLOCK(1'b0),
	.HREADY(HREADY)	,
	.HWDATA(HWDATA),
	.HRDATA(HRDATA)	,
	.HREADYOUT(HREADYOUT),//***
	.HRESP(HRESP), //***
	.unsign_i(unsign),
	.io_button(),
    .io_sw(io_sw_i),
	.ld_data_o(HRDATA_MEM),
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
	
	
/*
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
*/
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
