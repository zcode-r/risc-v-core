`timescale 1ns/1ps

module reg_file_tb;

  logic        clk;
  logic        reset;
  logic        wen;
  logic [4:0]  waddr;
  logic [31:0] wdata;
  logic [4:0]  raddr1;
  logic [31:0] rdata1;
  logic [4:0]  raddr2;
  logic [31:0] rdata2;

  // Instantiate Register File
  reg_file dut (
    .clk(clk), .reset(reset),
    .wen(wen), .waddr(waddr), .wdata(wdata),
    .raddr1(raddr1), .rdata1(rdata1),
    .raddr2(raddr2), .rdata2(rdata2)
  );

  always #5 clk <= ~clk;

  initial begin
    clk = 0;
    reset = 1;
    wen = 0;
    waddr = 0;
    wdata = 0;
    raddr1 = 0;
    raddr2 = 0;
    #15;
    reset = 0;

    $display("---------------------------------------------------------");
    $display("[TB START] Testing 32-bit RISC-V Register File");
    $display("---------------------------------------------------------");

    // 1. Write 100 into x1 and 200 into x2
    @(posedge clk);
    wen = 1; waddr = 5'd1; wdata = 32'd100;
    @(posedge clk);
    wen = 1; waddr = 5'd2; wdata = 32'd200;
    @(posedge clk);
    wen = 0;

    // 2. Read x1 and x2 asynchronously
    raddr1 = 5'd1;
    raddr2 = 5'd2;
    #2; // Small combinational delay
    $display("[READ TEST] rdata1 (x1): %0d (Expected: 100)", rdata1);
    $display("[READ TEST] rdata2 (x2): %0d (Expected: 200)", rdata2);

    // 3. The Golden Test: Try writing 9999 into x0
    @(posedge clk);
    wen = 1; waddr = 5'd0; wdata = 32'd9999;
    @(posedge clk);
    wen = 0;

    raddr1 = 5'd0;
    #2;
    $display("[x0 TEST]   rdata1 (x0): %0d (Expected: 0 - Writes ignored!)", rdata1);

    $display("---------------------------------------------------------");
    $display("[ALL TESTS COMPLETED]");
    $display("---------------------------------------------------------");
    $finish;
  end

endmodule
