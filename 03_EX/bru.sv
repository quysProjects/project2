module bru(
  input logic [31:0] 	rs1_data,
  input logic 		bru_en,
  input logic 		stall,
  input logic [31:0] 	imm,
  input logic [31:0] 	pc,
  input logic [2:0] 	bru_op,
  input logic 		bru_unsign,
  input logic 		br_less,
  input logic 		br_less_u,
  input logic 		br_equal,

  output logic 		is_taken,
  output logic [31:0] 	pc_bru
);
  localparam NOPE = 3'b000;
  localparam BNE  = 3'b001;
  localparam BLT  = 3'b010;
  localparam BGE  = 3'b011;
  localparam JAL  = 3'b100;
  localparam JALR = 3'b101;
  localparam BEQ  = 3'b110;
 
  logic [31:0] pc_b;
  logic [31:0] pc_jalr;

  wire is_jump;
  
  assign is_jump = ((bru_op == JAL) | (bru_op == JALR));
  
  assign is_taken = 	  ( is_jump
			| ((bru_op == BEQ )&( br_equal))
			| ((bru_op == BNE )&(~br_equal))
			| ((bru_op == BLT )&( br_less  )&(~bru_unsign))
			| ((bru_op == BLT )&( br_less_u)&( bru_unsign))
			| ((bru_op == BGE )&(~br_less  )&(~bru_unsign))
			| ((bru_op == BGE )&(~br_less_u)&( bru_unsign)))
			& ~stall & bru_en ;

	// is_jump : 1'b0 : branch , 1'b1 : jalr
  assign pc_b = pc + imm;
  assign pc_jalr = rs1_data + imm;
  assign pc_bru = (~(bru_op == JALR))? pc_b : pc_jalr;
	
endmodule

