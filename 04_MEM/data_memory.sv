module data_memory #(
	parameter int unsigned DMEM_W = 11
)(
	// APB Protocol
	input  logic              clk_i		,
	input  logic              rst_ni	,
	input  logic [DMEM_W-1:0] addr_i	,
	input  logic              st_en_i	,
	input  logic [31:0]       st_data_i ,
	input  logic [3:0]        mask_i	,

	output logic [31:0]       ld_data_o 
);

	logic [3:0][7:0] dmem [0:2**(DMEM_W-2)-1]; // 2KB

  // Read - Write
	always @(posedge clk_i ) begin : proc_data
    if (st_en_i) begin
    // with 32 bit data, bitmask has 3 bits
    // in order to decide write 1 byte, 2 bytes or 4 bytes
      if (mask_i[0]) begin
        dmem[addr_i[DMEM_W-1:2]][0] <= st_data_i[ 7: 0];
      end
      if (mask_i[1]) begin
        dmem[addr_i[DMEM_W-1:2]][1] <= st_data_i[15: 8];
      end
      if (mask_i[2]) begin
        dmem[addr_i[DMEM_W-1:2]][2] <= st_data_i[23:16];
      end
      if (mask_i[3]) begin
        dmem[addr_i[DMEM_W-1:2]][3] <= st_data_i[31:24];
      end
    end
	end

  assign ld_data_o = dmem[addr_i[DMEM_W-1:2]];

endmodule : data_memory
