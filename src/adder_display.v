
module adder_display (
    // clock and reset signal
    input clk,
    input resetn, // `n` for negative effective

    // input selection
    // 0: operand1
    // 1: operand2
    input input_sel,
    // switch for carry in
    input sw_cin,

    // led for carry_out
    output led_cout,

    // lcd, leavédefault
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

  reg  [31:0] adder_operand1;
  reg  [31:0] adder_operand2;
  wire        adder_carry_in;
  wire [31:0] adder_result;
  wire        adder_carry_out;
  Adder32 adder_module (
      .operand1(adder_operand1),
      .operand2(adder_operand2),
      .carry_in(adder_carry_in),
      .result(adder_result),
      .carry_out(adder_carry_out)
  );
  assign adder_carry_in = sw_cin;
  assign led_cout = adder_carry_out;

  reg          display_valid;
  reg  [ 39:0] display_name;
  reg  [ 31:0] display_value;
  wire [5 : 0] display_number;
  wire         input_valid;
  wire [ 31:0] input_value;

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


  // get input value from the lcd
  always @(posedge clk) begin
    if (!resetn) begin
      adder_operand1 <= 32'd0;
    end else if (input_valid && !input_sel) begin
      // input selection is 0, operand1
      adder_operand1 <= input_value;
    end
  end

  always @(posedge clk) begin
    if (!resetn) begin
      adder_operand2 <= 32'd0;
    end else if (input_valid && input_sel) begin
      // input selection is 1, operand2
      adder_operand2 <= input_value;
    end
  end

  always @(posedge clk) begin
    case (display_number)
      6'd42: begin
        display_valid <= 1'b1;
        display_name  <= "ADD_1";
        display_value <= adder_operand1;
      end
      6'd43: begin
        display_valid <= 1'b1;
        display_name  <= "ADD_2";
        display_value <= adder_operand2;
      end
      6'd44: begin
        display_valid <= 1'b1;
        display_name  <= "RESUL";
        display_value <= adder_result;
      end
      default: begin
        display_valid <= 1'b0;
        display_name  <= 40'd0;
        display_value <= 32'd0;
      end
    endcase
  end
endmodule
