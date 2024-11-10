module fetch_cycle(
	input  logic 			clk_i		, 
	input  logic 			rst_ni		,
	input  logic 			stall		,
	input  logic 			is_taken_E	,
	input  logic [31:0] 	pc_bru_E	,

	output logic [31:0] 	instr_D		,
	output logic [31:0] 	pc_D
);

    // Declaring interim wires
    wire logic [31:0] pc_cur		;
    wire logic [31:0] instr_F		;
    wire logic [31:0] instr_F_temp	;
	
    // Declaration of Register
    reg [31:0] instr_F_r;
    reg [31:0] pc_F_r	;


    // Initiation of Modules
    // Declare PC Counter
    pc_count pc_count(
                .clk_i(clk_i),
                .rst_ni(rst_ni),
				.stall(stall),
				.is_taken(is_taken_E),
				.bru_pc(pc_bru_E),
                .pc(pc_cur)
                );

				// Declare Instruction Memory
    instr_memory instr_memory(
                .clk_i(clk_i),
                .rst_ni(rst_ni),
                .addr_i(pc_cur[12:0]),
                .instr_o(instr_F_temp)
                );
				
  assign instr_F = (is_taken_E)? 32'd0 : instr_F_temp;

	wire asynch_rst;

	// Fetch Cycle Register Logic
	assign asynch_rst = (rst_ni) & ~is_taken_E & stall;
	
	always @(posedge clk_i or negedge asynch_rst) begin
		if (~rst_ni) begin
			instr_F_r 	<= 32'd0;
			pc_F_r 		<= 32'd0;
		end else begin 
			if	(stall) begin
		  
			end else begin
				instr_F_r 	<= instr_F;
				pc_F_r		<= pc_cur;
			end
		end
	end

    // Assigning Registers Value to the Output port
  assign  instr_D = instr_F_r;
  assign  pc_D = pc_F_r;


endmodule
