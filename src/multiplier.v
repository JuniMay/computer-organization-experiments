`timescale 1ns / 1ps

module Multiplier32Bit (
    input clk,
    input mult_begin,
    input [31:0] operand1,
    input [31:0] operand2,
    output [63:0] product,
    output mult_end
);

  wire operand1_sign;
  wire operand2_sign;
  wire [31:0] operand1_abs;
  wire [31:0] operand2_abs;

  assign operand1_sign = operand1[31];
  assign operand2_sign = operand2[31];

  assign operand1_abs  = operand1_sign ? ~operand1 + 1 : operand1;
  assign operand2_abs  = operand2_sign ? ~operand2 + 1 : operand2;

  reg [63:0] raw_product;
  wire [63:0] partial_product;

  reg [63:0] mult_operand1;
  reg [31:0] mult_operand2;

  reg mult_valid;

  assign mult_end = mult_valid & ~(|mult_operand2);

  always @(posedge clk) begin
    if (!mult_begin || mult_end) begin
      mult_valid <= 1'b0;
    end else begin
      mult_valid <= 1'b1;
    end
  end

  always @(posedge clk) begin
    if (mult_valid) begin
      mult_operand1 <= {mult_operand1[62:0], 1'b0};
    end else if (mult_begin) begin
      mult_operand1 <= {32'b0, operand1_abs};
    end
  end

  always @(posedge clk) begin
    if (mult_valid) begin
      mult_operand2 <= {1'b0, mult_operand2[31:1]};
    end else if (mult_begin) begin
      mult_operand2 <= operand2_abs;
    end
  end

  assign partial_product = mult_operand2[0] ? mult_operand1 : 64'b0;

  always @(posedge clk) begin
    if (mult_valid) begin
      raw_product <= raw_product + partial_product;
    end else if (mult_begin) begin
      raw_product <= 64'b0;
    end
  end

  reg product_sign;

  always @(posedge clk) begin
    if (mult_valid) begin
      product_sign <= operand1_sign ^ operand2_sign;
    end
  end

  assign product = product_sign ? (~raw_product + 1) : raw_product;


endmodule  // Multiplier
