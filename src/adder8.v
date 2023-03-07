`timescale 1ns / 1ps

module Adder8(input [7:0] operand1,
              input [7:0] operand2,
              input carry_in,
              output [7:0] result,
              output carry_out);
    assign {carry_out, result} = operand1 + operand2 + carry_in;
endmodule
