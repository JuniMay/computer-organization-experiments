`timescale 1ns / 1ps

module Alu(
    input [3:0] control,
    input [31:0] src1,
    input [31:0] src2,
    output [31:0] result
  );

  wire alu_add;
  wire alu_sub;
  wire alu_slt;
  wire alu_sltu;
  wire alu_and;
  wire alu_nor;
  wire alu_or;
  wire alu_xor;
  wire alu_sll;
  wire alu_srl;
  wire alu_sra;
  wire alu_lui;

  assign alu_add = (control == 4'b0001) ? 1'b1 : 1'b0;
  assign alu_sub = (control == 4'b0010) ? 1'b1 : 1'b0;
  assign alu_slt = (control == 4'b0011) ? 1'b1 : 1'b0;
  assign alu_sltu = (control == 4'b0100) ? 1'b1 : 1'b0;
  assign alu_and = (control == 4'b0101) ? 1'b1 : 1'b0;
  assign alu_nor = (control == 4'b0110) ? 1'b1 : 1'b0;
  assign alu_or = (control == 4'b0111) ? 1'b1 : 1'b0;
  assign alu_xor = (control == 4'b1000) ? 1'b1 : 1'b0;
  assign alu_sll = (control == 4'b1001) ? 1'b1 : 1'b0;
  assign alu_srl = (control == 4'b1010) ? 1'b1 : 1'b0;
  assign alu_sra = (control == 4'b1011) ? 1'b1 : 1'b0;
  assign alu_lui = (control == 4'b1100) ? 1'b1 : 1'b0;

  assign alu_xnor = (control == 4'b1101) ? 1'b1 : 1'b0;
  assign alu_inc = (control == 4'b1110) ? 1'b1 : 1'b0;
  assign alu_lh = (control == 4'b1111) ? 1'b1 : 1'b0;

  wire [31:0] add_sub_result;
  wire [31:0] slt_result;
  wire [31:0] sltu_result;
  wire [31:0] and_result;
  wire [31:0] nor_result;
  wire [31:0] or_result;
  wire [31:0] xor_result;
  wire [31:0] sll_result;
  wire [31:0] srl_result;
  wire [31:0] sra_result;
  wire [31:0] lui_result;

  wire [31:0] xnor_result;
  wire [31:0] inc_result;
  wire [31:0] lh_result;

  assign and_result = src1 & src2;
  assign or_result = src1 | src2;
  assign nor_result = ~or_result;
  assign xor_result = src1 ^ src2;
  assign lui_result = {src2[15:0], 16'd0};

  assign xnor_result = ~xor_result;
  assign lh_result = {16'd0, src2[15:0]};

  wire [31:0] adder_operand1;
  wire [31:0] adder_operand2;
  wire adder_carry_in;
  wire [31:0] adder_result;
  wire adder_carry_out;

  assign adder_operand1 = src1;
  assign adder_operand2 = alu_inc ? 32'd1 : (alu_add ? src2 : ~src2);
  assign adder_carry_in = alu_inc ? 1'b0 : ~alu_add; // for substraction.

  Adder32 adder(
            .operand1(adder_operand1),
            .operand2(adder_operand2),
            .carry_in(adder_carry_in),
            .result(adder_result),
            .carry_out(adder_carry_out)
          );

  assign add_sub_result = adder_result;
  assign inc_result = adder_result;

  assign slt_result[31:1] = 31'd0;
  assign slt_result[0] = (src1[31] & ~src2[31]) | (~(src1[31] ^ src2[31]) & adder_result[31]);

  assign sltu_result = {31'd0, ~adder_carry_out};

  wire [4:0] shamt;
  assign shamt = src1[4:0];
  wire [1:0] shamt_1_0;
  wire [1:0] shamt_3_2;
  assign shamt_1_0 = shamt[1:0];
  assign shamt_3_2 = shamt[3:2];

  wire [31:0] sll_step1;
  wire [31:0] sll_step2;

  assign sll_step1 = {32{shamt_1_0 == 2'b00}} & src2
         | {32{shamt_1_0 == 2'b01}} & {src2[30:0], 1'd0}
         | {32{shamt_1_0 == 2'b10}} & {src2[29:0], 2'd0}
         | {32{shamt_1_0 == 2'b11}} & {src2[28:0], 3'd0};

  assign sll_step2 = {32{shamt_3_2 == 2'b00}} & sll_step1
         | {32{shamt_3_2 == 2'b01}} & {sll_step1[27:0], 4'd0}
         | {32{shamt_3_2 == 2'b10}} & {sll_step1[23:0], 8'd0}
         | {32{shamt_3_2 == 2'b11}} & {sll_step1[19:0], 12'd0};

  assign sll_result = shamt[4] ? {sll_step2[15:0], 16'd0} : sll_step2;

  wire [31:0] srl_step1;
  wire [31:0] srl_step2;

  assign srl_step1 = {32{shamt_1_0 == 2'b00}} & src2
         | {32{shamt_1_0 == 2'b01}} & {1'd0, src2[31:1]}
         | {32{shamt_1_0 == 2'b10}} & {2'd0, src2[31:2]}
         | {32{shamt_1_0 == 2'b11}} & {3'd0, src2[31:3]};

  assign srl_step2 = {32{shamt_3_2 == 2'b00}} & srl_step1
         | {32{shamt_3_2 == 2'b01}} & {4'd0, srl_step1[31:4]}
         | {32{shamt_3_2 == 2'b10}} & {8'd0, srl_step1[31:8]}
         | {32{shamt_3_2 == 2'b11}} & {12'd0, srl_step1[31:12]};

  assign srl_result = shamt[4] ? {16'd0, srl_step2[31:16]} : srl_step2;

  wire [31:0] sra_step1;
  wire [31:0] sra_step2;

  assign sra_step1 = {32{shamt_1_0 == 2'b00}} & src2
         | {32{shamt_1_0 == 2'b01}} & {src2[31], src2[31:1]}
         | {32{shamt_1_0 == 2'b10}} & {{2{src2[31]}}, src2[31:2]}
         | {32{shamt_1_0 == 2'b11}} & {{3{src2[31]}}, src2[31:3]};

  assign sra_step2 = {32{shamt_3_2 == 2'b00}} & sra_step1
         | {32{shamt_3_2 == 2'b01}} & {{4{sra_step1[31]}}, sra_step1[31:4]}
         | {32{shamt_3_2 == 2'b10}} & {{8{sra_step1[31]}}, sra_step1[31:8]}
         | {32{shamt_3_2 == 2'b11}} & {{12{sra_step1[31]}}, sra_step1[31:12]};

  assign sra_result = shamt[4] ? {{16{sra_step2[31]}}, sra_step2[31:16]} : sra_step2;

  assign result = (alu_add | alu_sub) ? add_sub_result :
         alu_slt ? slt_result :
         alu_sltu ? sltu_result :
         alu_and ? and_result :
         alu_nor ? nor_result :
         alu_or ? or_result :
         alu_xor ? xor_result :
         alu_sll ? sll_result :
         alu_srl ? srl_result :
         alu_sra ? sra_result :
         alu_lui ? lui_result :
         alu_xnor ? xnor_result :
         alu_inc ? inc_result :
         alu_lh ? lh_result :
         32'd0;

endmodule
