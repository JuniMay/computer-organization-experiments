`timescale 1ns / 1ps

module TestbenchAdder32 ();
  reg [31:0] operand1;
  reg [31:0] operand2;
  reg carry_in;
  wire [31:0] result;
  wire carry_out;

  Adder32 adder_uut (
      .operand1(operand1),
      .operand2(operand2),
      .carry_in(carry_in),
      .result(result),
      .carry_out(carry_out)
  );

  initial begin
    $dumpfile("tb_adder32.vcd");
    $dumpvars(0, TestbenchAdder32);

    operand1 = 0;
    operand2 = 0;
    carry_in = 1'b0;

    #100;

    $finish;
  end

  always #3 operand1 = $random;
  always #5 operand2 = $random;
  always #7 carry_in = $random % 2'b10;

endmodule
