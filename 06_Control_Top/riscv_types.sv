// riscv_types.sv
package riscv_types;
    typedef struct {
		logic 			rd_wren;
 		logic [4:0] 	rd_addr;
		logic [4:0] 	rs1_addr;
		logic [4:0] 	rs2_addr;
		logic [31: 0] 	imm;
			
		logic 			is_pc;
		logic [1:0] 	op_b_sel;
		logic [3:0] 	alu_ctrl;
		logic			bru_en;
		logic [2:0] 	bru_op;
		logic 			bru_unsign;
			
		logic 			mem_wren;
		logic [3:0] 	mem_size;
		logic			mem_load;
		logic 			mem_unsign;
    } decode_info;
    
    typedef struct {
		logic 			rd_wren;
 		logic [4:0] 	rd_addr;
		logic [4:0] 	rs1_addr;
		logic [4:0] 	rs2_addr;
		logic [31: 0] 	imm;
			
		logic 			is_pc;
		logic [1:0] 	op_b_sel;
		logic [3:0] 	alu_ctrl;
		logic			bru_en;
		logic [2:0] 	bru_op;
		logic 			bru_unsign;

		logic 			mem_wren;
		logic [3:0] 	mem_size;
		logic			mem_load;
		logic 			mem_unsign;
    } execute_info;
    
    typedef struct {
      logic 		rd_wren;
      logic [4:0] 	rd_addr;
      logic 		mem_wren;
      logic [3:0] 	mem_size;
      logic 		mem_unsign;
      logic 		mem_load;
    } memory_info;
    
      typedef struct {
      logic 		rd_wren;
      logic [4:0] 	rd_addr;
      logic 		mem_load;
    } writeback_info;
    
endpackage