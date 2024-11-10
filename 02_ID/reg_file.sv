module reg_file(
  input logic         	clk_i,
  input logic         	rst_ni,
  
  input logic			rd_wren_i,	// write enable
  input logic [4:0]   	rs1_addr_i,
  input logic [4:0]   	rs2_addr_i,
  input logic [4:0]   	rd_addr_i,	// rsW,rsR1,rsR2
  input logic [31:0]	rd_data_i,	// data to write 
  
  output logic [31:0]  	rs1_data_o,
  output logic [31:0]  	rs2_data_o	// data R1, data R2
);

  logic [31:0]	 registers[0:31];

  // write read functionality
  always_ff@(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        for (int i=0; i < 32; i++)
          registers[i] <= 32'd0;
    end else begin
		if ((rd_wren_i) & (rd_addr_i != 5'd0)) begin
			registers[rd_addr_i] <= rd_data_i;
		end
	end
  end
  
  // output
   assign  rs1_data_o =  registers[rs1_addr_i];
   assign  rs2_data_o =  registers[rs2_addr_i];
 
endmodule : reg_file
