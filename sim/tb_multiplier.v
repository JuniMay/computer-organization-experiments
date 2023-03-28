module TestbenchMultiplier32Bit ();

  reg clk;
  reg mult_begin;
  reg [31:0] operand1;
  reg [31:0] operand2;

  wire [63:0] product;
  wire mult_end;


  Multiplier32Bit multiplier_uut (
      .clk(clk),
      .mult_begin(mult_begin),
      .operand1(operand1),
      .operand2(operand2),
      .product(product),
      .mult_end(mult_end)
  );

  initial begin
    $dumpfile("sim/wave_multiplier.vcd");
    $dumpvars(0, TestbenchMultiplier32Bit);

    clk = 0;
    mult_begin = 0;
    operand1 = 0;
    operand2 = 0;

    #100;
    mult_begin = 1;
    operand1   = 32'h00001111;
    operand2   = 32'h00001111;
    #400;
    mult_begin = 0;

    #500;
    mult_begin = 1;
    operand1   = 32'h00001111;
    operand2   = 32'h00002222;
    #400;
    mult_begin = 0;

    #500;
    mult_begin = 1;
    operand1   = 32'h00000002;
    operand2   = 32'hFFFFFFFF;
    #400;
    mult_begin = 0;

    #500;
    mult_begin = 1;
    operand1   = 32'h00000002;
    operand2   = 32'h80000000;
    #400;
    mult_begin = 0;

    #500;
    mult_begin = 1;
    operand1   = 32'h00114514;
    operand2   = 32'h01919810;
    #400;
    mult_begin = 0;

    #100;
    $finish;
  end

  always #5 clk = ~clk;

endmodule  //TOP
