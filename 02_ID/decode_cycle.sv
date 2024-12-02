import riscv_types::*;
module decode_cycle(
  input  logic 		clk_i		,
  input  logic 		rst_ni		,

  input  logic 		stall		,
  input  logic [ 1:0] forward_decode	,
  input  logic 		rd_wr_W		,
  input  logic [ 4:0] rd_addr_W		,
  input  logic [31:0] rd_data_W		,
  input  logic [31:0] instr_D		,
  input  logic [31:0] pc_D		, 

  output execute_info execute_signals	,
  output logic [31:0] rs1_data_D_E	,
  output logic [31:0] rs2_data_D_E	,
  output logic [ 4:0] rs1_addr_D	,
  output logic [ 4:0] rs2_addr_D	,
  output logic [31:0] pc_E
);
  wire logic [31:0] rs1_data_D	;
  wire logic [31:0] rs2_data_D	;
  wire logic [31:0] rs1_data_D_regfile;
  wire logic [31:0] rs2_data_D_regfile;
    
	 // Declaration of Interim Register
  decode_info 	decode_signals;
  execute_info 	decode_execute_reg;
	 
  reg [31:0] rs1_data_D_r; 
  reg [31:0] rs2_data_D_r; 
  reg [31:0] pc_D_r;

  wire async_signal;

  // Initiate the modules
  decoder decoder( 
	.instr		(instr_D),
        .rs1_addr	(decode_signals.rs1_addr	),
        .rs2_addr	(decode_signals.rs2_addr	),
        .rd_addr	(decode_signals.rd_addr		),
        .rd_wren	(decode_signals.rd_wren		),  
        .is_pc		(decode_signals.is_pc		),
        .op_b_sel	(decode_signals.op_b_sel	),
        .mem_wren	(decode_signals.mem_wren	),
        .mem_size	(decode_signals.mem_size	),
        .mem_unsign	(decode_signals.mem_unsign	),
        .mem_load	(decode_signals.mem_load	),
        .bru_en		(decode_signals.bru_en		),
        .bru_op		(decode_signals.bru_op		),
        .bru_unsign	(decode_signals.bru_unsign	),
        .imm		(decode_signals.imm		),
        .alu_ctrl	(decode_signals.alu_ctrl	)
  );

    // Register File
  reg_file rf (
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .rd_wren_i(rd_wr_W),
        .rd_data_i(rd_data_W),
        .rd_addr_i(rd_addr_W),
        .rs1_addr_i(decode_signals.rs1_addr),
        .rs2_addr_i(decode_signals.rs2_addr),
        .rs1_data_o(rs1_data_D_regfile),
        .rs2_data_o(rs2_data_D_regfile)
  );

    // Register Logic
  assign rs1_data_D = (forward_decode == 2'b01)? rd_data_W : rs1_data_D_regfile;
  assign rs2_data_D = (forward_decode == 2'b10)? rd_data_W : rs2_data_D_regfile;

  assign async_signal = rst_ni & ~stall;
	
  always @(posedge clk_i or negedge async_signal) begin
	if (~rst_ni) begin
		decode_execute_reg	<= '{default:0};
            	rs1_data_D_r		<= 32'd0;
            	rs2_data_D_r		<= 32'd0;
            	pc_D_r			<= 32'd0;
    	end else begin
	    	if (~stall) begin
			decode_execute_reg.rd_wren	<= decode_signals.rd_wren;
	            	decode_execute_reg.rd_addr	<= decode_signals.rd_addr;   
	            	decode_execute_reg.rs1_addr	<= decode_signals.rs1_addr;  
	            	decode_execute_reg.rs2_addr	<= decode_signals.rs2_addr;                      
	            	decode_execute_reg.imm		<= decode_signals.imm;
	           	decode_execute_reg.is_pc	<= decode_signals.is_pc;
	           	decode_execute_reg.op_b_sel	<= decode_signals.op_b_sel;
	           	decode_execute_reg.alu_ctrl	<= decode_signals.alu_ctrl;
		        decode_execute_reg.bru_en	<= decode_signals.bru_en;
		        decode_execute_reg.bru_op	<= decode_signals.bru_op;
		        decode_execute_reg.bru_unsign	<= decode_signals.bru_unsign;
		        decode_execute_reg.mem_wren	<= decode_signals.mem_wren;
		        decode_execute_reg.mem_size	<= decode_signals.mem_size;
		        decode_execute_reg.mem_unsign	<= decode_signals.mem_unsign;
		        decode_execute_reg.mem_load	<= decode_signals.mem_load; 
		        rs1_data_D_r			<= rs1_data_D;
		        rs2_data_D_r			<= rs2_data_D;
		        pc_D_r				<= pc_D;
		end
    	end
  end

    // Output assign statement
    assign execute_signals	= decode_execute_reg;
    assign rs1_addr_D 		= decode_signals.rs1_addr;
    assign rs2_addr_D		= decode_signals.rs2_addr;
    assign rs1_data_D_E		= rs1_data_D_r;
    assign rs2_data_D_E		= rs2_data_D_r;
    assign pc_E			= pc_D_r;

endmodule

