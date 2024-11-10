module output_peripheral(
    input logic clk_i,
    input logic rst_ni,
    input logic st_en_i,
    input logic [11:0] addr_i,
    input logic [31:0] st_data_i,

    output logic [31:0] io_lcd,
    output logic [31:0] io_ledg,
    output logic [31:0] io_ledr,
    output logic [31:0] io_hex0,
    output logic [31:0] io_hex1,
    output logic [31:0] io_hex2,
    output logic [31:0] io_hex3,
    output logic [31:0] io_hex4,
    output logic [31:0] io_hex5,
    output logic [31:0] io_hex6,
    output logic [31:0] io_hex7,
    output logic [31:0] ld_data_o
    );

    logic [31:0] reg_lcd;
    logic [31:0] reg_ledg;
    logic [31:0] reg_ledr;
    logic [31:0] reg_hex0;
    logic [31:0] reg_hex1;
    logic [31:0] reg_hex2;
    logic [31:0] reg_hex3;
    logic [31:0] reg_hex4;
    logic [31:0] reg_hex5;
    logic [31:0] reg_hex6;
    logic [31:0] reg_hex7;

    logic en_reg_lcd;
    logic en_reg_ledg;
    logic en_reg_ledr;
    logic en_reg_hex0;
    logic en_reg_hex1;
    logic en_reg_hex2;
    logic en_reg_hex3;
    logic en_reg_hex4;
    logic en_reg_hex5;
    logic en_reg_hex6;
    logic en_reg_hex7;		

    assign en_reg_hex0 = (addr_i == 12'h800)? 1'b1 : 1'b0;
    assign en_reg_hex1 = (addr_i == 12'h810)? 1'b1 : 1'b0;
    assign en_reg_hex2 = (addr_i == 12'h820)? 1'b1 : 1'b0;
    assign en_reg_hex3 = (addr_i == 12'h830)? 1'b1 : 1'b0;
    assign en_reg_hex4 = (addr_i == 12'h840)? 1'b1 : 1'b0;
    assign en_reg_hex5 = (addr_i == 12'h850)? 1'b1 : 1'b0;
    assign en_reg_hex6 = (addr_i == 12'h860)? 1'b1 : 1'b0;
    assign en_reg_hex7 = (addr_i == 12'h870)? 1'b1 : 1'b0;
    assign en_reg_ledr = (addr_i == 12'h880)? 1'b1 : 1'b0;
    assign en_reg_ledg = (addr_i == 12'h890)? 1'b1 : 1'b0;
    assign en_reg_lcd  = (addr_i == 12'h8A0)? 1'b1 : 1'b0;

    always @(posedge clk_i or negedge rst_ni) begin : proc_hex0
     if (!rst_ni) begin
     reg_hex0 <= 32'd0;
     end
     else if (en_reg_hex0 & st_en_i) begin
        reg_hex0 <= st_data_i;
      end
    end
    always @(posedge clk_i or negedge rst_ni) begin : proc_hex1
     if (!rst_ni) begin
     reg_hex1 <= 32'd0;
     end
     else if (en_reg_hex1 & st_en_i) begin
        reg_hex1 <= st_data_i;
      end
    end
    always @(posedge clk_i or negedge rst_ni) begin : proc_hex2
     if (!rst_ni) begin
     reg_hex2 <= 32'd0;
     end
     else if (en_reg_hex2 & st_en_i) begin
        reg_hex2 <= st_data_i;
      end
    end
    always @(posedge clk_i or negedge rst_ni) begin : proc_hex3
     if (!rst_ni) begin
     reg_hex3 <= 32'd0;
     end
     else if (en_reg_hex3 & st_en_i) begin
        reg_hex3 <= st_data_i;
      end
    end
    always @(posedge clk_i or negedge rst_ni) begin : proc_hex4
     if (!rst_ni) begin
     reg_hex4 <= 32'd0;
     end
     else if (en_reg_hex4 & st_en_i) begin
        reg_hex4 <= st_data_i;
      end
    end
    always @(posedge clk_i or negedge rst_ni) begin : proc_hex5
     if (!rst_ni) begin
     reg_hex5 <= 32'd0;
     end
     else if (en_reg_hex5 & st_en_i) begin
        reg_hex5 <= st_data_i;
      end
    end
    always @(posedge clk_i or negedge rst_ni) begin : proc_hex6
     if (!rst_ni) begin
     reg_hex6 <= 32'd0;
     end
     else if (en_reg_hex6 & st_en_i) begin
        reg_hex6 <= st_data_i;
      end
    end
    always @(posedge clk_i or negedge rst_ni) begin : proc_hex7
     if (!rst_ni) begin
     reg_hex7 <= 32'd0;
     end
     else if (en_reg_hex7 & st_en_i) begin
        reg_hex7 <= st_data_i;
      end
    end


    always @(posedge clk_i) begin : proc_ledr
     if (en_reg_ledr & st_en_i) begin
        reg_ledr <= st_data_i;
      end
    end

    always @(posedge clk_i) begin : proc_ledg
     if (en_reg_ledg & st_en_i) begin
        reg_ledg <= st_data_i;
      end
    end		

    always @(posedge clk_i) begin : proc_lcd
     if (en_reg_lcd & st_en_i) begin
        reg_lcd <= st_data_i;
      end
    end		
    assign io_hex0 = {25'd0,reg_hex0[6:0]};
    assign io_hex1 = {25'd0,reg_hex1[6:0]};
    assign io_hex2 = {25'd0,reg_hex2[6:0]};
    assign io_hex3 = {25'd0,reg_hex3[6:0]};
    assign io_hex4 = {25'd0,reg_hex4[6:0]};
    assign io_hex5 = {25'd0,reg_hex5[6:0]};
    assign io_hex6 = {25'd0,reg_hex6[6:0]};
    assign io_hex7 = {25'd0,reg_hex7[6:0]};
    assign io_ledr = {15'd0,reg_ledr[16:0]};
    assign io_ledg = {24'd0,reg_ledg[7:0]};
    assign io_lcd  = {reg_lcd[31],20'd0,reg_lcd[10:0]};


    assign ld_data_o = (en_reg_hex0)? reg_hex0 :
                 (en_reg_hex1)? reg_hex1 :
                 (en_reg_hex2)? reg_hex2 :
                 (en_reg_hex3)? reg_hex3 :
                 (en_reg_hex4)? reg_hex4 :
                 (en_reg_hex5)? reg_hex5 :
                 (en_reg_hex6)? reg_hex6 :
                 (en_reg_hex7)? reg_hex7 : 
                 (en_reg_ledr)? reg_ledr :
                 (en_reg_ledg)? reg_ledg :
                 (en_reg_lcd)?  reg_lcd  : 32'd0;
 
endmodule	