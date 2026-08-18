`timescale 1ns/1ps
import riscv_pkg::*;

module control_unit_tb;

  logic [6:0] opcode;
  logic [1:0] alu_op_type;
  logic       is_i_type, alu_src, mem_to_reg, reg_write, mem_read, mem_write, branch, jump;

  control_unit dut (
    .opcode(opcode),
    .alu_op_type(alu_op_type),
    .is_i_type(is_i_type),
    .alu_src(alu_src),
    .mem_to_reg(mem_to_reg),
    .reg_write(reg_write),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .branch(branch),
    .jump(jump)
  );

  initial begin
    $display("=========================================================");
    $display("       VERIFYING RV32I MAIN CONTROL UNIT                 ");
    $display("=========================================================");

    // Test 1: R-Type (ADD/SUB)
    opcode = OPC_R_TYPE; #10;
    assert(reg_write == 1 && alu_src == 0 && alu_op_type == 2'b10)
      else $error("[R-TYPE FAILED]");
    $display("[PASS] R-Type: reg_write=%b, alu_src=%b, alu_op_type=%b", reg_write, alu_src, alu_op_type);

    // Test 2: I-Type Arithmetic (ADDI)
    opcode = OPC_I_ARITH; #10;
    assert(reg_write == 1 && alu_src == 1 && is_i_type == 1 && alu_op_type == 2'b10)
      else $error("[I-ARITH FAILED]");
    $display("[PASS] I-Type Arith: reg_write=%b, alu_src=%b, is_i_type=%b", reg_write, alu_src, is_i_type);

    // Test 3: Load Word (LW)
    opcode = OPC_I_LOAD; #10;
    assert(reg_write == 1 && mem_read == 1 && mem_to_reg == 1 && alu_src == 1)
      else $error("[LOAD FAILED]");
    $display("[PASS] LW: reg_write=%b, mem_read=%b, mem_to_reg=%b", reg_write, mem_read, mem_to_reg);

    // Test 4: Store Word (SW)
    opcode = OPC_S_TYPE; #10;
    assert(reg_write == 0 && mem_write == 1 && alu_src == 1)
      else $error("[STORE FAILED]");
    $display("[PASS] SW: reg_write=%b, mem_write=%b, alu_src=%b", reg_write, mem_write, alu_src);

    // Test 5: Branch (BEQ)
    opcode = OPC_B_TYPE; #10;
    assert(branch == 1 && alu_src == 0 && alu_op_type == 2'b01)
      else $error("[BRANCH FAILED]");
    $display("[PASS] Branch: branch=%b, alu_op_type=%b", branch, alu_op_type);

    $display("=========================================================");
    $display("       ALL CONTROL SIGNALS VERIFIED!                     ");
    $display("=========================================================");
    $finish;
  end

endmodule
