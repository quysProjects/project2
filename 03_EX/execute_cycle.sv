import riscv_types::*;
module execute_cycle(
	input  logic 		clk_i		,
	input  logic 		rst_ni		,
	input  execute_info execute_signals	,

	input  logic 		stall		,
	input  logic 		flush		,
	input  logic [ 1:0] 	forward_rs1	,
	input  logic [ 1:0] 	forward_rs2	,
 
	input  logic [31:0] 	rs1_data_D_E	,
	input  logic [31:0] 	rs2_data_D_E	,
	input  logic [31:0] 	rd_data_W	,

	input  logic [31:0] 	pc_E		,

	output logic [ 4:0] 	rs1_addr_D_E	,
	output logic [ 4:0] 	rs2_addr_D_E	,
	output logic 		is_taken_E	,
	output logic [31:0] 	pc_bru_E	,

	output memory_info 	memory_signals	,
	output logic [31:0] 	Result_M	,
	output logic [31:0] 	rs2_data_M
);

	wire logic [31:0] rs1_data_E;
    	wire logic [31:0] rs2_data_E;
    	wire logic [31:0] operand_a_E;
   	wire logic [31:0] operand_b_E;
	wire logic [31:0] Result_E;
    	wire logic br_equal_E;
	wire logic br_less_E;
	wire logic br_less_u_E;
    
    	// Declaration of Register
    	memory_info execute_memory_reg;
    	reg [31:0] rs2_data_E_r;
    	reg [31:0] Result_E_r;

	wire async_signal;

    	assign rs1_addr_D_E = execute_signals.rs1_addr;
    	assign rs2_addr_D_E = execute_signals.rs2_addr;

	// Mux forward
	assign rs1_data_E = 	(forward_rs1 == 2'b00)? rs1_data_D_E :
				(forward_rs1 == 2'b10)? Result_M     :
				(forward_rs1 == 2'b01)? rd_data_W    : rs1_data_D_E;	
	
	
	assign rs2_data_E = 	(forward_rs2 == 2'b00)? rs2_data_D_E :
				(forward_rs2 == 2'b10)? Result_M     :
				(forward_rs2 == 2'b01)? rd_data_W    : rs2_data_D_E; 	
						
    	// Mux for Operand A, B
	assign operand_a_E = (execute_signals.is_pc)? pc_E : rs1_data_E;

	assign operand_b_E = 	(execute_signals.op_b_sel == 2'b00)? rs2_data_E 	:
				(execute_signals.op_b_sel == 2'b01)? execute_signals.imm: 
				(execute_signals.op_b_sel == 2'b10)? 32'h4 		: 32'd0;
				
	bru bru(  
		.rs1_data(rs1_data_E),
		.pc(pc_E),
		.bru_en(execute_signals.bru_en),
		.stall(stall),
		.imm(execute_signals.imm),
		.bru_op(execute_signals.bru_op),
		.bru_unsign(execute_signals.bru_unsign),
		.br_less(br_less_E),
		.br_less_u(br_less_u_E),
		.br_equal(br_equal_E),
		.is_taken(is_taken_E),
		.pc_bru(pc_bru_E)
	);

    	alu alu(
		.operand_a(operand_a_E),
		.operand_b(operand_b_E),
		.ALUControl(execute_signals.alu_ctrl),
		.Result(Result_E),
		.Z(br_equal_E),
		.N(br_less_E),
		.V(),
		.C(br_less_u_E)
   	);

	assign async_signal = rst_ni & ~flush & ~stall;
	
    	// Register Logic
	always @(posedge clk_i or negedge async_signal) begin
		if(~rst_ni | flush) begin
            		execute_memory_reg 	<= '{default:0};
            		Result_E_r 		<= 32'h00000000;
            		rs2_data_E_r 		<= 32'd0;
     		end else begin
			if (~stall) begin
		            execute_memory_reg.rd_wren 		<= execute_signals.rd_wren;
		            execute_memory_reg.rd_addr 		<= execute_signals.rd_addr;
		            execute_memory_reg.mem_wren 	<= execute_signals.mem_wren;
		            execute_memory_reg.mem_size 	<= execute_signals.mem_size;  
		            execute_memory_reg.mem_unsign 	<= execute_signals.mem_unsign;   
		            execute_memory_reg.mem_load 	<= execute_signals.mem_load;                            
		            rs2_data_E_r 			<= rs2_data_E; 
		            Result_E_r 				<= Result_E;
       			end
		end
	end

    	// Output Assignments
	assign memory_signals = execute_memory_reg;
	assign rs2_data_M = rs2_data_E_r;
    	assign Result_M = Result_E_r;

endmodule
