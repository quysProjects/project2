module pc_count #(
  parameter unsigned DATA_WIDTH = 32
 ) (
	input  logic clk_i,
	input  logic rst_ni,
 
	input  logic stall,
	input  logic is_taken,
	input  logic [DATA_WIDTH-1:0] bru_pc,
	
	output logic [DATA_WIDTH-1:0] pc
);

	wire [31:0] nxt_pc;
	wire [31:0] des_pc;
	
	assign nxt_pc = (stall)? pc : pc + 32'h4;
	
	assign des_pc = (is_taken)? bru_pc : nxt_pc;

  always_ff@(posedge clk_i or negedge rst_ni) begin
	if (~rst_ni) begin
		  pc <= 32'd0;
	end else begin
		  pc <= des_pc;
	end  
   end
  
endmodule : pc_count