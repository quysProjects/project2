module decoder(
	input logic [31:0] 	instr,

	//--- Control RegFile ---
	output logic [4:0] 	rs1_addr	,
	output logic [4:0] 	rs2_addr	,
	output logic [4:0] 	rd_addr		,
	output logic 		rd_wren		,

	//--- Control Execute ---
	output logic 		is_pc		,
	output logic [1:0] 	op_b_sel	,
	output logic [3:0] 	alu_ctrl	,
  
	//--- Control Branch Unit ---
	output logic		bru_en		,
	output logic [2:0] 	bru_op		,
	output logic 		bru_unsign	,
	
	//--- Control Memory ---
	output logic 		mem_wren	,
	output logic [2:0] 	mem_size	,
	output logic		mem_load	,
	output logic 		mem_unsign	,
	
	output logic [31:0] imm
 );
/* 		Decode Signal Description
_________________________________________________________________
|	is_pc 		= 1'b1 	-> operand A = pc		|
|	is_pc		= 1'b0 	-> operand A = rs1_data		|
|_______________________________________________________________|
|	op_b_sel	= 2'b00 -> operand B = rs2_data		|
|	op_b_sel	= 2'b01 -> operand B = imm		|
|	op_b_sel	= 2'b10 -> operand B = 32'h4		|
|	op_b_sel	= 2'b11 -> operand B = 32'd0		|
|_______________________________________________________________|
|				alu_ctrl			|
|	________________________________________________	|
|	|	Value		|	Operation	|	|	
|	|	4'b0000		|	ADD		|	|
|	|	4'b0001		|	SUB		|	|
|	|	4'b0010		|	SLL, SLLI	|	|
|	|	4'b0011		|	SLT, SLTI	|	|
|	|	4'b0100		|	SRA, SRAI	|	|
|	|	4'b0101		|	XOR, XORI	|	|
|	|	4'b0110		|	SRL, SRLI	|	|
|	|	4'b0111		|	SLTU, SLTUI	|	|
|	|	4'b1000		|	OR, ORI		|	|
|	|	4'b1001		|	AND, ANDI	|	|
|	________________________________________________	|
|_______________________________________________________________|
|	mem_size = 4'b0001 -> BYTE				|
|	mem_size = 4'b0010 -> HALFWORD				|
|	mem_size = 4'b0011 -> WORD				|
|_______________________________________________________________|
|	bru_op		= 3'b000 -> NONE			|
|	bru_op		= 3'b001 -> BNE				|
|	bru_op		= 3'b010 -> BLT, BLTU			|
|	bru_op		= 3'b011 -> BGE, BGEU			|
|	bru_op		= 3'b100 -> JAL				|
|	bru_op		= 3'b101 -> JALR			|
|	bru_op		= 3'b110 -> BEQ				|
________________________________________________________________|
///////////////////////////////////////////////////////////////*/

	// Opcodes - RV32 Instruction Set Listings
	localparam R_TYPE	= 5'b011_0011;
	localparam I_TYPE	= 5'b001_0011;
	localparam LOAD_OP	= 5'b000_0011;
	localparam E_OP		= 5'b111_0011; // ecall, ebreak
	localparam JALR_OP	= 5'b110_0111;
	localparam S_TYPE	= 5'b010_0011;
	localparam B_TYPE	= 5'b110_0011;
	localparam J_TYPE	= 5'b110_1111;
	localparam LUI_OP	= 5'b011_0111; // lui
	localparam AUIPC_OP	= 5'b001_0111;
  
  	// Opcodes - RV32 Instruction Set Listings
	localparam ADD	= 4'b0000;
	localparam SUB	= 4'b0001;
	localparam SLL	= 4'b0010;
	localparam SLT	= 4'b0011; // ecall, ebreak
	localparam SRA	= 4'b0100;
	localparam XOR	= 4'b0101;
	localparam SRL	= 4'b0110;
	localparam SLTU	= 4'b0111;
	localparam OR	= 4'b1000; // lui
	localparam AND	= 4'b1001;
	localparam NONE = 4'b1111;

	localparam NOPE = 3'b000;
	localparam BNE 	= 3'b001;
	localparam BLT	= 3'b010;
	localparam BGE 	= 3'b011;
	localparam JAL 	= 3'b100;
	localparam JALR	= 3'b101;
	localparam BEQ 	= 3'b110;
	
	localparam BYTE 	= 3'b000;
	localparam HALFWORD     = 3'b001;
	localparam WORD		= 3'b010;
	always_comb begin
		rs1_addr 	= 5'd0;
		rs2_addr 	= 5'd0;
		rd_addr		= 5'd0;
		rd_wren		= 1'b0;
		is_pc		= 1'b0;
		op_b_sel	= 2'd0;
		alu_ctrl	= 4'd0;
		bru_en		= 1'b0;
		bru_op		= 3'd0;
		bru_unsign	= 1'b0;
		mem_wren	= 1'b0;
		mem_size	= 3'd0;
		mem_unsign	= 1'b0;
		mem_load	= 1'b0;
		imm			= 32'd0;
		case (instr[6:0])
			R_TYPE	: begin
				rs1_addr 	= instr[19:15];
				rs2_addr 	= instr[24:20];
				rd_addr		= instr[11: 7];
				rd_wren		= 1'b1;
				is_pc		= 1'b0;
				op_b_sel	= 2'd0;
				bru_en		= 1'b0;
				bru_op		= NONE;
				bru_unsign	= 1'b0;
				mem_wren	= 1'b0;
				mem_size	= 3'd0;
				mem_unsign	= 1'b0;
				mem_load	= 1'b0;
				imm			= 32'd0;
				case ({instr[30],instr[14:12]})
					4'b0_000: 	alu_ctrl = ADD	;
					4'b1_000: 	alu_ctrl = SUB	;
					4'b0_001: 	alu_ctrl = SLL	;
					4'b0_010: 	alu_ctrl = SLT	;
					4'b0_011: 	alu_ctrl = SLT	;
					4'b0_100: 	alu_ctrl = XOR	;
					4'b0_101: 	alu_ctrl = SRL	;
					4'b1_101: 	alu_ctrl = SRA	;
					4'b0_110: 	alu_ctrl = OR	;
					4'b0_111: 	alu_ctrl = AND	;
					default: 	alu_ctrl = NONE	;
				endcase
			end		
			I_TYPE	: begin
				rs1_addr 	= instr[19:15];
				rs2_addr 	= 5'd0;
				rd_addr		= instr[11: 7];
				rd_wren		= 1'b1;
				is_pc		= 1'b0;
				op_b_sel	= 2'b01;
				bru_en		= 1'b0;
				bru_op		= NONE;
				bru_unsign	= 1'b0;
				mem_wren	= 1'b0;
				mem_size	= 3'd0;
				mem_unsign	= 1'b0;
				mem_load	= 1'b0;
				imm			= {{20{instr[31]}},instr[31:20]};
				case (instr[14:12])
					3'b000: 	alu_ctrl = ADD	;
					3'b010: 	alu_ctrl = SLT	;
					3'b011: 	alu_ctrl = SLTU	;
					3'b100: 	alu_ctrl = XOR	;
					3'b110: 	alu_ctrl = OR	;
					3'b111: 	alu_ctrl = AND	;
					3'b001: 	alu_ctrl = SLL	;
					3'b101:  	if (instr[30]) 	alu_ctrl = SRL;
								else			alu_ctrl = SRA;
					default: 	alu_ctrl = NONE	;
				endcase			
			end
			LOAD_OP	: begin
				rs1_addr 	= instr[19:15];
				rs2_addr 	= 5'd0;
				rd_addr		= instr[11: 7];
				rd_wren		= 1'b1;
				is_pc		= 1'b0;
				op_b_sel	= 2'b01;
				alu_ctrl	= ADD ;
				bru_en		= 1'b0;
				bru_op		= NONE;
				bru_unsign	= 1'b0;
				mem_wren	= 1'b0;
				mem_load	= 1'b1;
				imm			= {{20{instr[31]}},instr[31:20]};	
				case (instr[14:12])
					3'b000: begin
								mem_size 	= BYTE;
								mem_unsign 	= 1'b0;
					end
					3'b001: begin
								mem_size 	= HALFWORD;
								mem_unsign 	= 1'b0;
					end
					3'b010: begin
								mem_size 	= WORD;
								mem_unsign 	= 1'b0;
					end
					3'b100: begin
								mem_size 	= BYTE;
								mem_unsign 	= 1'b1;
					end
					3'b101: begin
								mem_size 	= HALFWORD;
								mem_unsign = 1'b1;
					end
					default: begin
								mem_size 	= 3'b000;
								mem_unsign 	= 1'b0;
					end			
				endcase						
			end
			JALR_OP	: begin
				rs1_addr 	= instr[19:15];
				rs2_addr 	= 5'd0;
				rd_addr		= instr[11: 7];
				rd_wren		= 1'b1;
				is_pc		= 1'b1;
				op_b_sel	= 2'b10;
				bru_en		= 1'b1;
				bru_op		= JALR;
				bru_unsign	= 1'b0;
				mem_wren	= 1'b0;
				mem_size	= 3'd0;
				mem_unsign	= 1'b0;
				mem_load	= 1'b0;
				imm			= {20'd0,instr[31:20]};
			end
			S_TYPE	: begin
				rs1_addr 	= instr[19:15];
				rs2_addr 	= instr[24:20];
				rd_addr		= 5'd0;
				rd_wren		= 1'b0;
				is_pc		= 1'b0;
				op_b_sel	= 2'b01;
				alu_ctrl	= ADD;
				bru_en		= 1'b0;
				bru_op		= NONE;
				bru_unsign	= 1'b0;
				mem_wren	= 1'b1;
				mem_load	= 1'b0;
				mem_unsign	= 1'b0;
				imm			= {{20{instr[31]}},instr[31:25],instr[11:7]};			
				case (instr[14:12])
					3'b000: begin
								mem_size = BYTE;
					end
					3'b001: begin
								mem_size = HALFWORD;
					end
					3'b010: begin
								mem_size = WORD;
					end
					default: begin
								mem_size = 4'd0;
					end			
				endcase	
			end
			B_TYPE	: begin
				rs1_addr 	= instr[19:15];
				rs2_addr 	= instr[24:20];
				rd_addr		= 5'd0;
				rd_wren		= 1'b0;
				is_pc		= 1'b0;
				op_b_sel	= 2'b00;
				alu_ctrl	= SUB;
				bru_en		= 1'b1;
				mem_wren	= 1'b0;
				mem_size	= 3'd0;
				mem_unsign	= 1'b0;
				mem_load	= 1'b0;
				imm			= {{19{instr[31]}},instr[31],instr[7],instr[30:25],instr[11:8],1'b0};
				case (instr[14:12])
					3'b000: begin
								bru_op 		= BEQ;
								bru_unsign 	= 1'b0;
					end
					3'b001: begin
								bru_op 		= BNE;
								bru_unsign 	= 1'b0;
					end
					3'b100: begin
								bru_op 		= BLT;
								bru_unsign 	= 1'b0;
					end					
					3'b101: begin
								bru_op 		= BGE;
								bru_unsign 	= 1'b0;
					end
					3'b110: begin
								bru_op 		= BLT;
								bru_unsign 	= 1'b1;
					end
					3'b111: begin
								bru_op 		= BGE;
								bru_unsign 	= 1'b1;
					end
					default: begin
								bru_op		= NOPE;
								bru_unsign	= 1'b0;
					end
				endcase
			end
			J_TYPE	: begin
				rs1_addr 	= 5'd0;
				rs2_addr 	= 5'd0;
				rd_addr		= instr[11:7];
				rd_wren		= 1'b1;
				is_pc		= 1'b1;
				op_b_sel	= 2'b10;
				alu_ctrl	= ADD;
				bru_en		= 1'b1;
				bru_op		= JAL;
				bru_unsign	= 1'b0;
				mem_wren	= 1'b0;
				mem_size	= 3'd0;
				mem_unsign	= 1'b0;
				mem_load	= 1'b0;
				imm			= {{12{instr[31]}},instr[19:12],instr[20],instr[30:25],instr[24:21],1'b0};
			end
			LUI_OP	: begin
				rs1_addr 	= 5'd0;
				rs2_addr 	= 5'd0;
				rd_addr		= instr[11:7];
				rd_wren		= 1'b1;
				is_pc		= 1'b0;
				op_b_sel	= 2'b10; // fix me
				alu_ctrl	= ADD;
				bru_en		= 1'b0;
				bru_op		= NONE;
				bru_unsign	= 1'b0;
				mem_wren	= 1'b0;
				mem_size	= 3'd0;
				mem_unsign	= 1'b0;
				mem_load	= 1'b0;
				imm			= {instr[31:12],12'd0};
			end
			AUIPC_OP: begin
				rs1_addr 	= 5'd0;
				rs2_addr 	= 5'd0;
				rd_addr		= instr[11:7];
				rd_wren		= 1'b1;
				is_pc		= 1'b1;
				op_b_sel	= 2'b10; // fix me
				alu_ctrl	= ADD;
				bru_en		= 1'b1;
				mem_wren	= 1'b0;
				mem_size	= 3'd0;
				mem_unsign	= 1'b0;
				mem_load	= 1'b0;
				imm			= {11'd0,instr[31],instr[19:12],instr[20],instr[24:21],1'b0};
			end
		endcase
	end
 
endmodule : decoder 
