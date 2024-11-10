module input_peripheral(
  input logic clk_i,
  input logic rst_ni,
  input logic [11:0] addr_i,
  input logic [31:0] io_button,
  input logic [31:0] io_sw,

  output logic [31:0] ld_data_o
  );

  logic [31:0] reg_sw;
  logic [31:0] reg_button;
  logic stable_o;

  typedef enum logic [1:0] {
    IDLE  = 2'b00,
    HOLD  = 2'b01,
    PRESS = 2'b10
  } state_e;
  state_e state_d;
  state_e state_q;

  always_comb begin
    case (state_q)
      IDLE:    state_d = io_button[0] ? PRESS : IDLE;
      PRESS:   state_d = io_button[0] ? HOLD  : IDLE;
      HOLD:    state_d = io_button[0] ? HOLD  : IDLE;
      default: state_d = IDLE;
    endcase
  end

  always_ff @(posedge clk_i) begin
    state_q <= state_d;
	end


  always@(posedge clk_i or negedge rst_ni) begin
	if (!rst_ni) begin
		reg_sw <= 32'd0;
		end
		else begin
      reg_sw <= io_sw[31:0];
  end
  end

  assign stable_o = (state_q == HOLD) ? 1'b1 : 1'b0;
  assign ld_data_o = (addr_i == 12'h900)? reg_sw:
                     (addr_i == 12'h910)? {31'd0,stable_o}: 32'dz;

endmodule

