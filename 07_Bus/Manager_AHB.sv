module Manager_AHB #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    // Clock and Reset
    input  logic                    HCLK,
    input  logic                    HRESETn,
    
    // Control Signals
    output logic [1:0]             HTRANS,     // Transfer type
    output logic                   HWRITE,     // Write enable
    output logic [2:0]             HSIZE,      // Transfer size
    output logic [2:0]             HBURST,     // Burst type
    output logic [3:0]             HPROT,      // Protection control
    
    // Address and Data
    output logic [ADDR_WIDTH-1:0]  HADDR,      // Address bus
    output logic [DATA_WIDTH-1:0]  HWDATA,     // Write data bus
    input  logic [DATA_WIDTH-1:0]  HRDATA,     // Read data bus
    
    // Transfer Response
    input  logic                    HREADY,     // Transfer done
    input  logic                    HRESP,      // Transfer response

    // Additional Signals to LSU
    input  logic                    i_core_mngr_unsign,
    output logic                    o_mngr_sub_unsign,

    // Master Interface Signals
    input  logic                    req_read,   // Read request
    input  logic                    req_write,  // Write request
    input  logic [ADDR_WIDTH-1:0]   req_addr,   // Request address
    input  logic [DATA_WIDTH-1:0]   req_wdata,  // Write data
    input  logic [2:0]              req_size,   // Request size
    input  logic [2:0]              req_burst,  // Burst type
    output logic                    req_ready,  // Ready to accept request
    output logic                    resp_valid, // Response valid
    output logic [DATA_WIDTH-1:0]   resp_rdata  // Read data
);

    // AHB Transfer Types
    localparam [1:0] IDLE   = 2'b00;
    localparam [1:0] BUSY   = 2'b01;
    localparam [1:0] NONSEQ = 2'b10;
    localparam [1:0] SEQ    = 2'b11;

    // FSM States
    typedef enum logic [2:0] {
        ST_IDLE,
        ST_ADDR,
        ST_DATA,
        ST_WAIT,
        ST_ERROR
    } state_t;

    // Internal registers
    state_t current_state, next_state;
    logic [ADDR_WIDTH-1:0] addr_reg;
    logic [DATA_WIDTH-1:0] wdata_reg;
    logic [2:0]            size_reg;
    logic [2:0]            burst_reg;
    logic                  write_reg;
    logic [7:0]            burst_count;
    logic                  burst_active;
    logic                  req_valid;
    logic                  req_valid_1;
    logic                  unsign_reg;
    
    // Request valid detection
    assign req_valid = req_write || req_read;

    // Sequential logic
    always_ff @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            current_state <= ST_IDLE;
            addr_reg     <= '0;
            size_reg     <= '0;
            burst_reg    <= '0;
            write_reg    <= '0;
            burst_count  <= '0;
            burst_active <= 1'b0;
            req_valid_1  <= 1'b0;
            wdata_reg    <= '0;
            unsign_reg   <= 1'b0;
        end
        else begin
            current_state <= next_state;
            
            if (req_valid) begin
                req_valid_1  <= 1'b1;
                addr_reg     <= req_addr;
                size_reg     <= req_size;
				wdata_reg    <= req_wdata;
                burst_reg    <= req_burst;
                write_reg    <= req_write;
                unsign_reg   <= i_core_mngr_unsign;
                
                // Calculate burst count
                case (req_burst)
                    3'b000:  burst_count <= 8'd0;  // Single
                    3'b001:  burst_count <= 8'd3;  // INCR4
                    3'b010:  burst_count <= 8'd7;  // INCR8
                    3'b011:  burst_count <= 8'd15; // INCR16
                    default: burst_count <= 8'd0;
                endcase
                
                burst_active <= (req_burst != 3'b000);
            end
            else if (current_state == ST_DATA && HREADY && burst_active) begin
                // Update address for burst transfers
                case (size_reg)
                    3'b000:  addr_reg <= addr_reg + 1;  // Byte
                    3'b001:  addr_reg <= addr_reg + 2;  // Halfword
                    3'b010:  addr_reg <= addr_reg + 4;  // Word
                    default: addr_reg <= addr_reg + 4;
                endcase
                burst_count <= burst_count - 1;
            end
            else begin
                req_valid_1 <= 1'b0;
            end
        end
		
		//delay for HWDATA
		if (req_valid_1) begin 
		HWDATA <= wdata_reg;
		end
		
    end

    // Next state logic
    always_comb begin
        next_state = current_state;
        
        case (current_state)
            ST_IDLE: begin
                if (req_valid)
                    next_state = ST_ADDR;
            end
            
            ST_ADDR: begin
                if (HREADY)
                    next_state = ST_DATA;
                else
                    next_state = ST_WAIT;
            end
            
            ST_DATA: begin
                if (HREADY) begin
                    if (HRESP)
                        next_state = ST_ERROR;
                    else if (burst_active && burst_count > 0)
                        next_state = ST_WAIT;
                    else if (req_valid_1)
                        next_state = ST_DATA;
                    else
                        next_state = ST_IDLE;
                end
                else
                    next_state = ST_WAIT;
            end
            
            ST_WAIT: begin
                if (HREADY) begin
                    if (burst_active && burst_count > 0)
                        next_state = ST_ADDR;
                    else
                        next_state = ST_IDLE;
                end
            end
            
            ST_ERROR: begin
                if (HREADY)
                    next_state = ST_IDLE;
            end
            
            default: next_state = ST_IDLE;
        endcase
    end

    // Output logic
    always_comb begin
        // Default assignments
        HTRANS     = IDLE;
        HWRITE     = write_reg;
        HSIZE      = size_reg;
        HBURST     = burst_reg;
        HPROT      = 4'b0011;
        HADDR      = addr_reg;
        req_ready  = 1'b0;
        resp_valid = 1'b0;
        resp_rdata = HRDATA;
        o_mngr_sub_unsign = unsign_reg;

        case (current_state)
            ST_IDLE: begin
                req_ready = 1'b1;
                if (req_valid) begin
                    HTRANS = NONSEQ;
                end
            end
            
            ST_ADDR: begin
                if (HREADY) begin
                    HTRANS = burst_active ? SEQ : NONSEQ;
                end
            end
            
            ST_DATA: begin
                if (HREADY) begin
                    resp_valid = ~write_reg;  // Valid only for reads
                    if (!burst_active || burst_count == 0) begin
                        req_ready = 1'b1;
                        HTRANS = IDLE;
                    end
                    else begin
                        HTRANS = SEQ;
                    end
                end
            end
            
            ST_WAIT: begin
                if (burst_active && burst_count > 0) begin
                    HTRANS = SEQ;
                end
            end
            
            ST_ERROR: begin
                req_ready = 1'b1;
            end
        endcase
    end

endmodule