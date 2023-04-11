
module RegisterFile (
    // clock
    input clk,
    // write enable
    input [4:0] wen,

    // read enable
    input [1:0] ren,

    // read address 1
    input [4:0] raddr1,
    // read address 2
    input [4:0] raddr2,
    // write address
    input [4:0] waddr,
    // write data
    input [31:0] wdata,
    // read data 1
    output reg [31:0] rdata1,
    // read data 2
    output reg [31:0] rdata2,
    // test address
    input [4:0] test_addr,
    // test data
    output reg [31:0] test_data
);

  reg [31:0] rf[31:0];

  always @(posedge clk) begin
    rf[waddr][7:0]   <= (wen[0]) ? wdata[7:0] : rf[waddr][7:0];
    rf[waddr][15:8]  <= (wen[1]) ? wdata[15:8] : rf[waddr][15:8];
    rf[waddr][23:16] <= (wen[2]) ? wdata[23:16] : rf[waddr][23:16];
    rf[waddr][31:24] <= (wen[3]) ? wdata[31:24] : rf[waddr][31:24];
  end

  // Read port 1
  always @(*) begin
    rdata1[15:0]  <= ren[0] && (|raddr1) ? rf[raddr1][15:0] : 16'd0;
    rdata1[31:16] <= ren[1] && (|raddr1) ? rf[raddr1][31:16] : 16'd0;
  end

  // Read port 2
  always @(*) begin
    rdata2[15:0]  <= ren[0] && (|raddr2) ? rf[raddr2][15:0] : 16'd0;
    rdata2[31:16] <= ren[1] && (|raddr2) ? rf[raddr2][31:16] : 16'd0;
  end

  // Debug
  always @(*) begin
    test_data <= (|test_addr) ? rf[test_addr] : 32'd0;
  end

endmodule
