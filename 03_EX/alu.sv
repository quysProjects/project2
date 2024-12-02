module alu(
  input logic [31:0] operand_a,
  input logic [31:0] operand_b,
  input logic [3:0] ALUControl,

  output logic [31:0] Result,
  output logic Z,
  output logic N,
  output logic V,
  output logic C
);

  wire logic [31:0] a_and_b;
  wire logic [31:0] a_or_b;
  wire logic [31:0] a_xor_b;
  wire logic [31:0] not_b;

  wire logic [31:0] mux_1;

  wire logic [31:0] sum;

  wire logic [31:0] mux_2;

  wire logic [31:0] slt;

  wire logic [31:0] sltu;

  wire logic [31:0] a_shift_left_b;

  wire logic [31:0] a_shift_right_b;

  wire logic [31:0] a_sr_arith_b;

  wire logic cout;

  // logic design

  // AND
  assign a_and_b = operand_a & operand_b;

  // OR
  assign a_or_b = operand_a | operand_b;

  // XOR
  assign a_xor_b = operand_a ^ operand_b;

  // NOT on b
  assign not_b = ~operand_b;

  // Ternary
  assign mux_1 = (ALUControl[0] == 1'b0)? operand_b : not_b; 

  // Addition / Substraction
  assign {cout,sum} = operand_a + mux_1 + ALUControl[0];

  // Set less than
  assign slt = {31'd0,sum[31]};
  assign sltu = {31'd0,~cout};

  // Shift (Left, Right, Right Arithmetic)
  shift_left shift_left(
      .rs1(operand_a),
      .imm(operand_b[4:0]),
      .rd_left(a_shift_left_b)
      );
  
  shift_right shift_right(
      .rs1(operand_a),
      .imm(operand_b[4:0]),
      .rd_right(a_shift_right_b)
      );
  
  shift_right_arith shift_right_arith(
      .rs1(operand_a),
      .imm(operand_b[4:0]),
      .rd_right_arith(a_sr_arith_b)
      );

  // Design 4by1 Mux
  assign mux_2 =  (ALUControl[3:0] == 4'b0000)? sum : // add 
                  (ALUControl[3:0] == 4'b0001)? sum :  // sub
                  (ALUControl[3:0] == 4'b0010)? a_shift_left_b : // sll and srl
                  (ALUControl[3:0] == 4'b0111)? sltu :
                  (ALUControl[3:0] == 4'b0011)? slt :	// slt
                  (ALUControl[3:0] == 4'b0101)? a_xor_b : 
                  (ALUControl[3:0] == 4'b0110)? a_shift_right_b : //srl
                  (ALUControl[3:0] == 4'b0100)? a_sr_arith_b : //sra
                  (ALUControl[3:0] == 4'b1000)? a_or_b : 
                  (ALUControl[3:0] == 4'b1001)? a_and_b : 32'h00000000;

  assign Result = mux_2;

  // Flags
  assign Z = &(~Result); 					// Zero Flag

  assign N = Result[31]; 					// Negative Flag

  assign C = cout & (~ALUControl[1]); // Carry Flag

  assign V = (~ALUControl[1]) & (operand_a[31] ^ sum[31]) & (~(operand_a[31] ^ operand_b[31] ^ ALUControl[0])); // Overflow Flag


endmodule

module shift_left(
  input logic [31:0] rs1,
  input logic [4:0] imm,

  output logic [31:0] rd_left
);

    assign rd_left = 
     (imm==5'b00001)? {rs1[30:0],1'b0}:
     (imm==5'b00010)? {rs1[29:0],2'b0}:
     (imm==5'b00011)? {rs1[28:0],3'b0}:
     (imm==5'b00100)? {rs1[27:0],4'b0}:
     (imm==5'b00101)? {rs1[26:0],5'b0}:
     (imm==5'b00110)? {rs1[25:0],6'b0}:
     (imm==5'b00111)? {rs1[24:0],7'b0}:
     (imm==5'b01000)? {rs1[23:0],8'b0}:
     (imm==5'b01001)? {rs1[22:0],9'b0}:
     (imm==5'b01010)? {rs1[21:0],10'b0}:
     (imm==5'b01011)? {rs1[20:0],11'b0}:
     (imm==5'b01100)? {rs1[19:0],12'b0}:
     (imm==5'b01101)? {rs1[18:0],13'b0}:
     (imm==5'b01110)? {rs1[17:0],14'b0}:
     (imm==5'b01111)? {rs1[16:0],15'b0}:
     (imm==5'b10000)? {rs1[15:0],16'b0}:
     (imm==5'b10001)? {rs1[14:0],17'b0}:
     (imm==5'b10010)? {rs1[13:0],18'b0}:
     (imm==5'b10011)? {rs1[12:0],19'b0}:
     (imm==5'b10100)? {rs1[11:0],20'b0}:
     (imm==5'b10101)? {rs1[10:0],21'b0}:
     (imm==5'b10110)? {rs1[9:0],22'b0}:
     (imm==5'b10111)? {rs1[8:0],23'b0}:
     (imm==5'b11000)? {rs1[7:0],24'b0}:
     (imm==5'b11001)? {rs1[6:0],25'b0}:
     (imm==5'b11010)? {rs1[5:0],26'b0}:
     (imm==5'b11011)? {rs1[4:0],27'b0}:
     (imm==5'b11100)? {rs1[3:0],28'b0}:           
     (imm==5'b11101)? {rs1[2:0],29'b0}:
     (imm==5'b11110)? {rs1[1:0],30'b0}:
     (imm==5'b11111)? {rs1[0],31'b0}  : rs1[31:0];	  

endmodule : shift_left

 module shift_right(
  input logic [31:0] rs1,
  input logic [4:0] imm,

  output logic [31:0] rd_right
);
      assign rd_right = 
        (imm==5'b00001)? {1'b0,rs1[31:1]}:
        (imm==5'b00010)? {2'b0,rs1[31:2]}:
        (imm==5'b00011)? {3'b0,rs1[31:3]}:
        (imm==5'b00100)? {4'b0,rs1[31:4]}:
        (imm==5'b00101)? {5'b0,rs1[31:5]}:
        (imm==5'b00110)? {6'b0,rs1[31:6]}:
        (imm==5'b00111)? {7'b0,rs1[31:7]}:
        (imm==5'b01000)? {8'b0,rs1[31:8]}:
        (imm==5'b01001)? {9'b0,rs1[31:9]}:
        (imm==5'b01010)? {10'b0,rs1[31:10]}:
        (imm==5'b01011)? {11'b0,rs1[31:11]}:
        (imm==5'b01100)? {12'b0,rs1[31:12]}:
        (imm==5'b01101)? {13'b0,rs1[31:13]}:
        (imm==5'b01110)? {14'b0,rs1[31:14]}:
        (imm==5'b01111)? {15'b0,rs1[31:15]}:
        (imm==5'b10000)? {16'b0,rs1[31:16]}:
        (imm==5'b10001)? {17'b0,rs1[31:17]}:
        (imm==5'b10010)? {18'b0,rs1[31:18]}:
        (imm==5'b10011)? {19'b0,rs1[31:19]}:
        (imm==5'b10100)? {20'b0,rs1[31:20]}:
        (imm==5'b10101)? {21'b0,rs1[31:21]}:
        (imm==5'b10110)? {22'b0,rs1[31:22]}:
        (imm==5'b10111)? {23'b0,rs1[31:23]}:
        (imm==5'b11000)? {24'b0,rs1[31:24]}:
        (imm==5'b11001)? {25'b0,rs1[31:25]}:
        (imm==5'b11010)? {26'b0,rs1[31:26]}:
        (imm==5'b11011)? {27'b0,rs1[31:27]}:
        (imm==5'b11100)? {28'b0,rs1[31:28]}:           
        (imm==5'b11101)? {29'b0,rs1[31:29]}:
        (imm==5'b11110)? {30'b0,rs1[31:30]}:
        (imm==5'b11111)? {31'b0,rs1[31]}: rs1[31:0];

endmodule : shift_right

module shift_right_arith(
  input logic [31:0] rs1,
  input logic [4:0] imm,

  output logic [31:0] rd_right_arith
);
      assign rd_right_arith = 
        (imm==5'b00001)? {{rs1[31]},rs1[31:1]}:
        (imm==5'b00010)? {{2{rs1[31]}},rs1[31:2]}:
        (imm==5'b00011)? {{3{rs1[31]}},rs1[31:3]}:
        (imm==5'b00100)? {{4{rs1[31]}},rs1[31:4]}:
        (imm==5'b00101)? {{5{rs1[31]}},rs1[31:5]}:
        (imm==5'b00110)? {{6{rs1[31]}},rs1[31:6]}:
        (imm==5'b00111)? {{7{rs1[31]}},rs1[31:7]}:
        (imm==5'b01000)? {{8{rs1[31]}},rs1[31:8]}:
        (imm==5'b01001)? {{9{rs1[31]}},rs1[31:9]}:
        (imm==5'b01010)? {{10{rs1[31]}},rs1[31:10]}:
        (imm==5'b01011)? {{11{rs1[31]}},rs1[31:11]}:
        (imm==5'b01100)? {{12{rs1[31]}},rs1[31:12]}:
        (imm==5'b01101)? {{13{rs1[31]}},rs1[31:13]}:
        (imm==5'b01110)? {{14{rs1[31]}},rs1[31:14]}:
        (imm==5'b01111)? {{15{rs1[31]}},rs1[31:15]}:
        (imm==5'b10000)? {{16{rs1[31]}},rs1[31:16]}:
        (imm==5'b10001)? {{17{rs1[31]}},rs1[31:17]}:
        (imm==5'b10010)? {{18{rs1[31]}},rs1[31:18]}:
        (imm==5'b10011)? {{19{rs1[31]}},rs1[31:19]}:
        (imm==5'b10100)? {{20{rs1[31]}},rs1[31:20]}:
        (imm==5'b10101)? {{21{rs1[31]}},rs1[31:21]}:
        (imm==5'b10110)? {{22{rs1[31]}},rs1[31:22]}:
        (imm==5'b10111)? {{23{rs1[31]}},rs1[31:23]}:
        (imm==5'b11000)? {{24{rs1[31]}},rs1[31:24]}:
        (imm==5'b11001)? {{25{rs1[31]}},rs1[31:25]}:
        (imm==5'b11010)? {{26{rs1[31]}},rs1[31:26]}:
        (imm==5'b11011)? {{27{rs1[31]}},rs1[31:27]}:
        (imm==5'b11100)? {{28{rs1[31]}},rs1[31:28]}:           
        (imm==5'b11101)? {{29{rs1[31]}},rs1[31:29]}:
        (imm==5'b11110)? {{30{rs1[31]}},rs1[31:30]}:
        (imm==5'b11111)? {32{rs1[31]}} : rs1[31:0];

 endmodule : shift_right_arith
