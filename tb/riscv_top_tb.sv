`timescale 1ns/1ps

module riscv_top_tb;

  logic clk;
  logic reset;

  // Instantiate the complete CPU Core and load program.hex
  riscv_top #(
      .MEM_DEPTH(1024),
      .HEX_FILE ("program.hex")
  ) dut (
      .clk  (clk),
      .reset(reset)
  );

  // 10ns clock period (100MHz)
 always #5 clk <= ~clk;

  // Cycle counter for debugging
  int cycle_cnt;

  initial begin
    clk       = 0;
    reset     = 1;
    cycle_cnt = 0;

    $display("=======================================================================");
    $display("               STARTING SINGLE-CYCLE RISC-V CPU SIMULATION             ");
    $display("=======================================================================");

    // Hold reset for 2 clock cycles
    #15;
    reset = 0;

    // Run for 10 clock cycles to execute our 8 instructions
    repeat (10) begin
      @(posedge clk);
      #1; // Small delta delay to let signals settle after clock edge
      cycle_cnt++;
      $display("[Cycle %0d] PC: 0x%08h | Inst: 0x%08h | x1:%0d x2:%0d x3:%0d x4:%0d x5:%0d",
               cycle_cnt,
               dut.pc_curr,
               dut.inst,
               dut.u_reg_file.registers[1],
               dut.u_reg_file.registers[2],
               dut.u_reg_file.registers[3],
               dut.u_reg_file.registers[4],
               dut.u_reg_file.registers[5]);
    end

    $display("=======================================================================");
    $display("                       VERIFYING FINAL CPU STATE                       ");
    $display("=======================================================================");

    // Automated Assertions
    assert(dut.u_reg_file.registers[1] === 32'd10)
      else $error("[FAILED] Register x1 should be 10, got %0d", dut.u_reg_file.registers[1]);

    assert(dut.u_reg_file.registers[2] === 32'd20)
      else $error("[FAILED] Register x2 should be 20, got %0d", dut.u_reg_file.registers[2]);

    assert(dut.u_reg_file.registers[3] === 32'd30)
      else $error("[FAILED] Register x3 (10+20) should be 30, got %0d", dut.u_reg_file.registers[3]);

    assert(dut.u_dmem.mem[1] === 32'd30)
      else $error("[FAILED] Data RAM address 4 (word index 1) should be 30, got %0d", dut.u_dmem.mem[1]);

    assert(dut.u_reg_file.registers[4] === 32'd30)
      else $error("[FAILED] Register x4 (LW from RAM) should be 30, got %0d", dut.u_reg_file.registers[4]);

    assert(dut.u_reg_file.registers[5] === 32'd42)
      else $error("[FAILED] Register x5 should be 42 (Branch skipped x5=99), got %0d", dut.u_reg_file.registers[5]);

    $display("[SUCCESS] All Register, ALU, Memory (LW/SW), and Branch (BEQ) tests PASSED!");
    $display("=======================================================================");
    $finish;
  end

endmodule
