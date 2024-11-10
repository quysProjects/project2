module ahb_manager #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    // Clock and Reset
    input  logic                    HCLK	,
    input  logic                    HRESETn	,
    
    // Control Signals
    output logic [1:0]             	HTRANS	,	// Transfer type
    output logic                   	HWRITE	,	// Write enable
    output logic [2:0]             	HSIZE	,	// Transfer size
    output logic [2:0]             	HBURST	,	// Burst type
    output logic [3:0]             	HPROT	,	// Protection control
    
    // Address and Data
    output logic [ADDR_WIDTH-1:0]	HADDR	,	// Address bus
    output logic [DATA_WIDTH-1:0]	HWDATA	,	// Write data bus
    input  logic [DATA_WIDTH-1:0]	HRDATA	,	// Read data bus
    
    // Transfer Response
    input  logic                    HREADY	,	// Transfer done
    input  logic                    HRESP	,	// Transfer response
    
    // Core Interface Signals
    input  logic                    req_read	,	// Read request		(~st_en_i) 
    input  logic                    req_write	,	// Write request 	(st_en_i)
    input  logic [ADDR_WIDTH-1:0]   req_addr	,	// Request address	(st_addr_i)
    input  logic [DATA_WIDTH-1:0]   req_wdata	,	// Write data 		(st_data_i)
    input  logic [2:0]              req_size	,   // Request size     (similar to a mask)
    input  logic [2:0]              req_burst	,	// Burst type	
    output logic                    req_ready	,	// Ready to accept request
    output logic                    resp_valid	,	// Response valid, having data for CPU reading
    output logic [DATA_WIDTH-1:0]   resp_rdata  	// Read data 		(ld_data_o)
);

    // AHB Transfer Types
    localparam IDLE   = 2'b00;
    localparam BUSY   = 2'b01;
    localparam NONSEQ = 2'b10;
    localparam SEQ    = 2'b11;

    // FSM States
    typedef enum logic [2:0] {
        ST_IDLE,
        ST_ADDR,
        ST_DATA,
        ST_WAIT,
        ST_ERROR
    } state_t;

    state_t current_state, next_state;
    
    // Internal registers
    logic [ADDR_WIDTH-1:0]	addr_reg	;
    logic [DATA_WIDTH-1:0]	wdata_reg	;
    logic [2:0]           	size_reg	;
    logic [2:0]				burst_reg	;
    logic					write_reg	;
    logic [7:0]           	burst_count	;
    logic                 	burst_active;
    logic                 	req_valid	;
    
    // Detect request valid
    assign req_valid = req_write || req_read;

	//Next state logic
    always_ff@(posedge HCLK or negedge HRESETn )begin
        if (!HRESETn) begin
            current_state <= ST_IDLE;
        end else begin
            current_state <= next_state;
        end
	end
	
	always_ff@(posedge HCLK or negedge HRESETn) begin 
		if (!HRESETn) begin
			addr_reg     <= '0;
            wdata_reg    <= '0;
            size_reg     <= '0;
            burst_reg    <= '0;
            write_reg    <= '0;
            burst_count  <= '0;
            burst_active <= 1'b0;
		end else begin
			if (req_valid) begin
                addr_reg   <= req_addr;
                wdata_reg  <= req_wdata;
                size_reg   <= req_size;
                burst_reg  <= req_burst;
                write_reg  <= req_write;
                
                // Calculate burst count
                case (req_burst)
                    3'b000:  burst_count <= 8'd0;	// Single
                    3'b001:  burst_count <= 8'd3;	// INCR4
                    3'b010:  burst_count <= 8'd7;	// INCR8
                    3'b011:  burst_count <= 8'd15;	// INCR16
                    default: burst_count <= 8'd0;
                endcase
                
                burst_active <= (req_burst != 3'b000);
            end else if (current_state == ST_DATA && HREADY && burst_active) begin
			    // Update address for burst transfers
                case (size_reg)
                    3'b000:  addr_reg <= addr_reg + 1;  // Byte
                    3'b001:  addr_reg <= addr_reg + 2;  // Halfword
                    3'b010:  addr_reg <= addr_reg + 4;  // Word
                    default: addr_reg <= addr_reg + 4;
                endcase
                burst_count <= burst_count - 1;
            end else if (current_state == ST_WAIT) begin
				// Update wait counter
            end
        end
	end
	
    // Next state logic
    always_comb begin
        next_state = current_state;
        case (current_state)
            ST_IDLE: begin
                if (req_valid) next_state = ST_ADDR;
            end
            
            ST_ADDR: begin
                if (HREADY) next_state = ST_DATA;
            end
            
            ST_DATA: begin
                if (HREADY) begin
                    if (HRESP)
                        next_state = ST_ERROR;
                    else if (burst_active && burst_count > 0)
                        next_state = ST_WAIT;
                    else if (req_write)
                        next_state = ST_ADDR;
                    else
                        next_state = ST_IDLE;
                end
            end
            
            ST_WAIT: begin
            end
            
            ST_ERROR: begin
                if (HREADY)
                    next_state = ST_IDLE;
            end
            
            default: next_state = ST_IDLE;
        endcase
    end

    // Output logic - sequential part
    always_comb begin
        if (~HRESETn) begin
            HTRANS		= IDLE	;
            HWRITE		= 1'b0	;
            HSIZE		= 3'b000;
            HBURST		= 3'b000;
            HPROT		= 4'b0011;
            HADDR		= '0	;
            HWDATA		= '0	;
            req_ready	= 1'b1	;
            resp_valid	= 1'b0	;
            resp_rdata	= '0	;
        end else begin
            // Default assignments
            HTRANS		= IDLE;
            req_ready	= 1'b1;
            resp_valid	= 1'b0;
            
            case (current_state)
                ST_IDLE: begin
                    if (req_valid) begin
                        req_ready	= 1'b0;
                        HTRANS		= NONSEQ;
                        HWRITE		= write_reg;
                        HSIZE		= size_reg;
                        HBURST		= burst_reg;
                        HADDR		= addr_reg;
                    end
                end
                
                ST_ADDR: begin
                    if (HREADY) begin
                        HTRANS	= burst_active ? SEQ : NONSEQ;
                        HWRITE	= write_reg;
                        HSIZE	= size_reg;
                        HBURST	= burst_reg;
                        HADDR	= addr_reg;
                    end
                end
                
                ST_DATA: begin
                    if (write_reg) begin
                        HWDATA	= wdata_reg;
                    end
                    
                    if (HREADY) begin
                        if (!write_reg) begin
                            resp_valid	= 1'b1;
                            resp_rdata	= HRDATA;
                        end
                        
                        if (!burst_active || burst_count == 0) begin
                            req_ready	= 1'b1;
							HTRANS		= IDLE; 
                        end
                        else begin
                            HTRANS = SEQ;
                        end
                    end
                end
                
                ST_WAIT: begin
                    HTRANS		= BUSY;  // Signal busy during wait state
                    req_ready	= 1'b0;
                end
                
                ST_ERROR: begin
                    HTRANS		= IDLE;
                    req_ready	= 1'b1;
                end
            endcase
        end
    end

endmodule