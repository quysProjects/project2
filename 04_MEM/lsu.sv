module lsu(
    input  logic 			clk_i		,
    input  logic 			rst_ni		,
    input  logic     		st_en_i 	,
    input  logic [11:0] 	addr_lsu_i	,
    input  logic [31:0]     st_data_i	,
    input  logic [ 3:0]     mask_i		,
    input  logic			unsign		,

    input  logic [31:0]		io_button	,
    input  logic [31:0] 	io_sw		,

    output logic [31:0]     ld_data_o	,
    output logic [31:0] 	io_lcd		,
    output logic [31:0] 	io_ledg		,
    output logic [31:0] 	io_ledr		,
    output logic [31:0] 	io_hex0		,
    output logic [31:0] 	io_hex1		,
    output logic [31:0] 	io_hex2		,
    output logic [31:0] 	io_hex3		,
    output logic [31:0] 	io_hex4		,
    output logic [31:0] 	io_hex5		,
    output logic [31:0] 	io_hex6		,
    output logic [31:0] 	io_hex7 
    );

	logic [1:0] addr_sel;

    wire logic [11:0] addr_periph_o;
    wire logic [10:0] addr_memory_o;

    // For MUX select for ld_data_o
    wire logic [31:0] input_periph_i	;
    wire logic [31:0] output_periph_i	;
    wire logic [31:0] data_memory_i		;

    wire logic [31:0] ld_data		;
	wire logic [31:0] ld_data_byte	;
	wire logic [31:0] ld_data_half	;
	wire logic [31:0] ld_data_word	;
	wire logic [31:0] ld_data_byte_u;
	wire logic [31:0] ld_data_half_u;
	
    // addr_sel: 2'b0x: data_memory, 2'b10: output_peripheral, 2'b11: input_peripheral
    assign addr_sel = {addr_lsu_i[11],addr_lsu_i[8]};

	assign addr_periph_o = ((addr_sel == 2'b10)|(addr_sel == 2'b11))? addr_lsu_i : 12'd0;

	assign addr_memory_o = ((addr_sel == 2'b00)|(addr_sel == 2'b01))? addr_lsu_i[10:0] : 11'd0;
    
	input_peripheral input_peripheral(
      .clk_i(clk_i),
      .rst_ni(rst_ni),
      .addr_i(addr_periph_o),
      .io_button(io_button),
      .io_sw(io_sw),
      .ld_data_o(input_periph_i)
    );
    output_peripheral output_peripheral(
      .clk_i(clk_i),
      .rst_ni(rst_ni),
      .st_en_i(st_en_i),
      .addr_i(addr_periph_o),
      .st_data_i(st_data_i),
      .io_hex0(io_hex0),
      .io_hex1(io_hex1),
      .io_hex2(io_hex2),
      .io_hex3(io_hex3),
      .io_hex4(io_hex4),
      .io_hex5(io_hex5),
      .io_hex6(io_hex6),
      .io_hex7(io_hex7),
      .io_ledr(io_ledr),
      .io_ledg(io_ledg),
      .io_lcd(io_lcd),
      .ld_data_o(output_periph_i)
    );
    data_memory data_memory(
      .clk_i(clk_i),
      .rst_ni(rst_ni),
      .addr_i(addr_memory_o[10:0]),
      .st_en_i(st_en_i),
      .st_data_i(st_data_i),
      .mask_i(mask_i),
      .ld_data_o(data_memory_i)
    );
	
	assign ld_data = (addr_sel == 2'b11) ? input_periph_i:
			(addr_sel == 2'b10) ? output_periph_i :
			((addr_sel == 2'b00)|(addr_sel == 2'b01)) ? data_memory_i : data_memory_i ;


	assign ld_data_byte = {{24{ld_data[7]}},ld_data[7:0]};

	assign ld_data_half = {{16{ld_data[15]}},ld_data[15:0]};

	assign ld_data_word = ld_data;

	assign ld_data_byte_u = {24'd0,ld_data[7:0]};

	assign ld_data_half_u = {16'd0,ld_data[15:0]};

	assign ld_data_o = ({unsign,mask_i}==5'b00001)? ld_data_byte	:
               ({unsign,mask_i}==5'b10001)? ld_data_byte_u			:
               ({unsign,mask_i}==5'b00011)? ld_data_half 			:
               ({unsign,mask_i}==5'b10011)? ld_data_half_u			:
               ({unsign,mask_i}==5'b01111)? ld_data_word 			: 32'd0;
			   
endmodule