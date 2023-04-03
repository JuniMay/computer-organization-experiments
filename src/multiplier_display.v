
module MultiplierDisplay (
    // clock and reset signal
    input clk,
    input resetn, // `n` for negative effective

    // input selection
    // 0: operand1
    // 1: operand2
    input input_sel,
    // switch for carry in
    input sw_begin,

    // led for carry_out
    output led_end,

    // lcd, leave default
    output lcd_rst,
    output lcd_cs,
    output lcd_rs,
    output lcd_wr,
    output lcd_rd,
    inout [15:0] lcd_data_io,
    output lcd_bl_ctr,
    inout ct_int,
    inout ct_sda,
    output ct_scl,
    output ct_rstn
);

  wire mult_begin;

  reg [31:0] mult_operand1;
  reg [31:0] mult_operand2;

  wire [63:0] mult_product;
  wire mult_end;

  assign mult_begin = sw_begin;
  assign led_end = mult_end;

  Multiplier32 multiplier_module (
      .clk(clk),
      .mult_begin(mult_begin),
      .operand1(mult_operand1),
      .operand2(mult_operand2),
      .product(mult_product),
      .mult_end(mult_end)
  );

  reg [63:0] product;

  always @(posedge clk) begin
    if (!resetn) begin
      product <= 64'd0;
    end else if (mult_end) begin
      product <= mult_product;
    end
  end

  reg display_valid;
  reg [39:0] display_name;
  reg [31:0] display_value;

  wire [5:0] display_number;
  wire input_valid;
  wire [31:0] input_value;

  lcd_module lcd_module (
      .clk(clk),  // 10Mhz
      .resetn(resetn),

      // lcd interface
      .display_valid(display_valid),
      .display_name(display_name),
      .display_value(display_value),
      .display_number(display_number),
      .input_valid(input_valid),
      .input_value(input_value),

      // lcd interface
      .lcd_rst(lcd_rst),
      .lcd_cs(lcd_cs),
      .lcd_rs(lcd_rs),
      .lcd_wr(lcd_wr),
      .lcd_rd(lcd_rd),
      .lcd_data_io(lcd_data_io),
      .lcd_bl_ctr(lcd_bl_ctr),
      .ct_int(ct_int),
      .ct_sda(ct_sda),
      .ct_scl(ct_scl),
      .ct_rstn(ct_rstn)
  );

  always @(posedge clk) begin
    if (!resetn) begin
      mult_operand1 <= 32'd0;
    end else if (input_valid && !input_sel) begin
      mult_operand1 <= input_value;
    end
  end

  always @(posedge clk) begin
    if (!resetn) begin
      mult_operand2 <= 32'd0;
    end else if (input_valid && input_sel) begin
      mult_operand2 <= input_value;
    end
  end

  always @(posedge clk) begin
    case (display_number)
      6'd41: begin
        display_valid <= 1'b1;
        display_name  <= "M_OP1";
        display_value <= mult_operand1;
      end
      6'd42: begin
        display_valid <= 1'b1;
        display_name  <= "M_OP2";
        display_value <= mult_operand2;
      end
      6'd43: begin
        display_valid <= 1'b1;
        display_name  <= "PRO_H";
        display_value <= product[63:32];
      end
      6'd44: begin
        display_valid <= 1'b1;
        display_name  <= "PRO_L";
        display_value <= product[31:0];
      end
      default: begin
        display_valid <= 1'b0;
        display_name  <= 40'd0;
        display_value <= 32'd0;
      end
    endcase
  end

endmodule
