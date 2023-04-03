`timescale 1ns / 1ps

module Multiplier32 (
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

  assign operand1_abs  = operand1_sign ? (~operand1 + 1) : operand1;
  assign operand2_abs  = operand2_sign ? (~operand2 + 1) : operand2;

  reg [63:0] raw_product;
  wire [63:0] partial_product;

  reg [63:0] multiplicand;
  reg [31:0] multiplier;

  reg mult_valid;

  assign mult_end = mult_valid & ~(|multiplier);

  always @(posedge clk) begin
    if (!mult_begin || mult_end) begin
      mult_valid <= 1'b0;
    end else begin
      mult_valid <= 1'b1;
    end
  end

  always @(posedge clk) begin
    if (mult_valid) begin
      // Left shift multiplicand by two bits
      multiplicand <= {multiplicand[61:0], 2'b0};
    end else if (mult_begin) begin
      multiplicand <= {32'b0, operand1_abs};
    end
  end

  always @(posedge clk) begin
    if (mult_valid) begin
      // Right shift multiplier by two bits
      multiplier <= {2'b0, multiplier[31:2]};
    end else if (mult_begin) begin
      multiplier <= operand2_abs;
    end
  end

  // Partial product
  // Four cases according to the lowest two bits of the multiplier
  // - 11: multiplicand + multiplicand << 1
  // - 10: multiplicand << 1
  // - 01: multiplicand
  // - 00: 0
  assign partial_product = 
    multiplier[1] ? (
      multiplier[0] ? multiplicand + {multiplicand[62:0], 1'b0} 
                       : {multiplicand[62:0], 1'b0}) : (
      multiplier[0] ? multiplicand : 64'b0);

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


endmodule  // Multiplier32
