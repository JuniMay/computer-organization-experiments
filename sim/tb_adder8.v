`timescale 1ns / 1ps

module TestbenchAdder8 ();
  reg [7:0] operand1;
  reg [7:0] operand2;
  reg carry_in;
  wire [7:0] result;
  wire carry_out;

  Adder8 adder_uut (
      .operand1(operand1),
      .operand2(operand2),
      .carry_in(carry_in),
      .result(result),
      .carry_out(carry_out)
  );

  initial begin
    $dumpfile("tb_adder8.vcd");
    $dumpvars(0, TestbenchAdder8);

    operand1 = 8'b0;
    operand2 = 8'b0;
    carry_in = 1'b0;

    #100;

    $finish;
  end

  always #3 operand1 = $random;
  always #5 operand2 = $random;
  always #7 carry_in = $random % 2'b10;

endmodule
