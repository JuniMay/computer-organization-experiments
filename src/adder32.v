`timescale 1ns / 1ps
`include "adder8.v"

module Adder32(input [31:0] operand1,
               input [31:0] operand2,
               input carry_in,
               output [31:0] result,
               output carry_out);
    
    wire carry_0;
    wire carry_1;
    wire carry_2;
    
    Adder8 adder_0(
    .operand1(operand1[7:0]),
    .operand2(operand2[7:0]),
    .carry_in(carry_in),
    .result(result[7:0]),
    .carry_out(carry_0)
    );
    
    Adder8 adder_1(
    .operand1(operand1[15:8]),
    .operand2(operand2[15:8]),
    .carry_in(carry_0),
    .result(result[15:8]),
    .carry_out(carry_1)
    );
    
    Adder8 adder_2(
    .operand1(operand1[23:16]),
    .operand2(operand2[23:16]),
    .carry_in(carry_1),
    .result(result[23:16]),
    .carry_out(carry_2)
    );
    
    Adder8 adder_3(
    .operand1(operand1[31:24]),
    .operand2(operand2[31:24]),
    .carry_in(carry_2),
    .result(result[31:24]),
    .carry_out(carry_out)
    );
    
endmodule
