module Subordinate_LSU #(
	parameter int unsigned ADDR_WIDTH = 12,
	parameter int unsigned DATA_WIDTH = 32
)(
	// Global signals
	input  logic 					HCLK		,
	input  logic 					HRESETn		,
	
	// Select
	input  logic					HSEL_MEM	,

	// Address and control
	input  logic [ADDR_WIDTH-1:0] 	HADDR		,
	input  logic					HWRITE		,
	input  logic 			[2:0]	HSIZE		,
	input  logic 			[2:0]	HBURST		,
	input  logic 			[3:0]	HPROT		,
	input  logic 			[1:0]	HTRANS		,
	input  logic					HMASTLOCK	,
	input  logic					HREADY		,
	// Data
	input  logic [DATA_WIDTH-1:0]	HWDATA		,
	input  logic 					resp_read	,
	output logic [DATA_WIDTH-1:0]	HRDATA		,
	
	// Transfer response
	output logic					HREADYOUT	,
	output logic					HRESP		,
	//Input, output peripherals
	input  logic [31:0]   			io_button	,
    input  logic [31:0] 			io_sw		,
    output logic [31:0] 			io_lcd		,
    output logic [31:0] 			io_ledg		,
    output logic [31:0] 			io_ledr		,
    output logic [31:0] 			io_hex0		,
    output logic [31:0] 			io_hex1		,
    output logic [31:0] 			io_hex2		,
    output logic [31:0] 			io_hex3		,
    output logic [31:0] 			io_hex4		,
    output logic [31:0] 			io_hex5		,
    output logic [31:0] 			io_hex6		,
    output logic [31:0] 			io_hex7 
);
	localparam IDLE   = 2'b00					; 
	localparam BUSY   = 2'b01					; 
	localparam NONSEQ = 2'b10					;		 
	localparam SEQ    = 2'b11					; 
	
	localparam BYTE     = 3'b000				; 
	localparam HALFWORD = 3'b001				; 
	localparam WORD     = 3'b010				; 
	
	//Internal signals
	logic [3:0][7:0]dmem [0:2**(ADDR_WIDTH-2)-1]; 
	logic [ADDR_WIDTH-1:0]	mem_addr			;	
	logic 					mem_wren			;	
	logic [3:0]  			mem_mask    		;
	logic [DATA_WIDTH-1:0]  mem_wdata			;
	logic [DATA_WIDTH-1:0]  mem_rdata			;
	logic [2:0] 			mem_hsize			;
	//----LSU Signals---//
	logic [1:0]  			addr_sel			;
    logic [11:0] 			addr_periph_o		;
	logic [11:0]			addr_periph_o_delay ; 
    logic [10:0] 			addr_memory_o		;
    logic [31:0] 			input_periph_i		;
    logic [31:0] 			output_periph_i		;
    logic [31:0] 			data_memory_i		;
	
	demux_lsu demux_lsu(
      .addr_i(HADDR),
      .addr_sel_i(addr_sel),
      .addr_periph_o(addr_periph_o),
      .addr_memory_o(addr_memory_o)
    );
    input_peripheral input_peripheral(
      .clk_i(HCLK),
      .rst_ni(HRESETn),
      .addr_i(addr_periph_o),
      .io_button(io_button),
      .io_sw(io_sw),
      .ld_data_o(input_periph_i)
    );
    output_peripheral output_peripheral(
      .clk_i(HCLK),
      .rst_ni(HRESETn),
      .st_en_i(mem_wren),
      .addr_i(addr_periph_o_delay),
      .st_data_i(HWDATA),
      .io_hex0(io_hex0),
      .io_hex1(io_hex1),
      .io_hex2(io_hex2),
      .io_hex3(io_hex3),
      .io_hex4(io_hex4),
      .io_hex5(io_hex5),
      .io_hex6(io_hex6),
      .io_hex7(io_hex7),
      .io_ledr(io_ledr),
      .io_ledg(io_ledg),
      .io_lcd(io_lcd),
      .ld_data_o(output_periph_i)
    );
    mux_lsu mux_lsu(
      .addr_sel_i(addr_sel),
      .input_periph_i(input_periph_i),
      .output_periph_i(output_periph_i),
      .data_memory_i(mem_rdata),
      .ld_data_o(HRDATA)
    );		


/*--------------------------------------------------------------------------*/
/*---------------------------Path Pre-Processing----------------------------*/


	
	
	always_ff@(posedge HCLK or negedge HRESETn) begin 
		if(!HRESETn) begin 
			mem_addr   <= '0; 
			mem_wren   <= 1'b0; 
			mem_hsize  <= 3'b000; 
		end else if (HSEL_MEM&&HTRANS[1]) begin
			mem_addr   <= addr_memory_o;  
			mem_wren   <= HWRITE; 
			mem_hsize  <= HSIZE; 
			addr_periph_o_delay <= addr_periph_o; 
			end
			end
			
	//Mask Generator
	always_comb begin 
		case(mem_hsize)
			3'b000: mem_mask = 4'b0001;  
			3'b001: mem_mask = 4'b0011; 
			3'b010: mem_mask = 4'b1111; 
		  default : mem_mask = 4'b0000; 
		endcase
	end

	// State definition for memory operations
typedef enum logic [1:0] {
    ST_IDLE,
    ST_READ,
    ST_WRITE
} state_t;

// State register
state_t current_state;

// Sequential state logic
always_ff @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
        current_state <= ST_IDLE;
        HREADYOUT <= 1'b1;
    end else begin
        case (current_state)
            ST_IDLE: begin
                if (HSEL_MEM&&HTRANS[1]) begin  // Valid transfer
                    if (HWRITE) begin
                        current_state <= ST_WRITE;
                        HREADYOUT <= 1'b0;  // Stall for write
                    end else if (resp_read) begin
                        current_state <= ST_READ;
                        HREADYOUT <= 1'b0;  // Stall for read
                    end
                end else begin
                    HREADYOUT <= 1'b1;  // Ready in idle
                end
            end

            ST_READ: begin
                if (mem_rdata != '0) begin  // Data ready
                    current_state <= ST_IDLE;
                    HREADYOUT <= 1'b1;  // Complete read
                end else begin
                    HREADYOUT <= 1'b0;  // Keep stalled
                end
            end

            ST_WRITE: begin
                current_state <= ST_IDLE;
                HREADYOUT <= 1'b1;  // Complete write after one cycle
            end

            default: begin
                current_state <= ST_IDLE;
                HREADYOUT <= 1'b1;
            end
        endcase
    end
end

// Memory write operations (keep your existing logic)
always_ff@(posedge HCLK)begin 
    if ((current_state == ST_WRITE) && HSEL_MEM) begin
        if (mem_mask[0]) dmem[mem_addr[ADDR_WIDTH-1:2]][0] <= HWDATA[7:0];
        if (mem_mask[1]) dmem[mem_addr[ADDR_WIDTH-1:2]][1] <= HWDATA[15:8];
        if (mem_mask[2]) dmem[mem_addr[ADDR_WIDTH-1:2]][2] <= HWDATA[23:16];
        if (mem_mask[3]) dmem[mem_addr[ADDR_WIDTH-1:2]][3] <= HWDATA[31:24];    
    end
end

always_comb begin
	if ((current_state == ST_READ) && HSEL_MEM) begin
		mem_rdata = dmem[mem_addr[ADDR_WIDTH-1:2]];
	end
end

	//next_state logic with handshaking

/*---------------------------End Pre-Processing-----------------------------*/	
/*--------------------------------------------------------------------------*/
/*--------------------------------------------------------------------------------------------*/
/*-----------------------Datapath Post-Processing------------------------*/
	
/*-------------------------End Post-Processing ---------------------------*/	
/*--------------------------------------------------------------------------------------------*/
endmodule