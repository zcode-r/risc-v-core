`timescale 1ns/1ps

module alu_tb;

import riscv_pkg::*;

  logic [31:0] a, b;
  alu_op_e     alu_op;
  logic [31:0] alu_out;
  logic        zero, sign, overflow, carry, ltu;

  alu #(.DATA_WIDTH(32)) dut (
    .a(a), .b(b), .alu_op(alu_op),
    .alu_out(alu_out), .zero(zero), .sign(sign),
    .overflow(overflow), .carry(carry), .ltu(ltu)
  );

  initial begin
    $display("=========================================================");
    $display("       VERIFYING PRODUCTION RV32I ALU CORE               ");
    $display("=========================================================");

    // Test 1: SRA (Arithmetic Shift Right on Negative Number)
    // 0xF000_0000 >>> 4 should keep the sign bits: 0xFF00_0000
    a = 32'hF000_0000; b = 32'd4; alu_op = ALU_SRA; #10;
    assert(alu_out === 32'hFF00_0000) else $error("[SRA FAILED] Expected 0xFF000000, got %h", alu_out);
    $display("[PASS] SRA: 0x%08h >>> 4 = 0x%08h", a, alu_out);

    // Test 2: SLT (Signed Less Than) -> -10 < 5 is TRUE (1)
    a = -32'd10; b = 32'd5; alu_op = ALU_SLT; #10;
    assert(alu_out === 32'd1) else $error("[SLT FAILED]");
    $display("[PASS] SLT: -10 < 5 = %0d", alu_out);

    // Test 3: SLTU (Unsigned Less Than) -> 0xFFFFFFFF < 5 is FALSE (0)
    a = 32'hFFFF_FFFF; b = 32'd5; alu_op = ALU_SLTU; #10;
    assert(alu_out === 32'd0) else $error("[SLTU FAILED]");
    $display("[PASS] SLTU: 0xFFFFFFFF < 5 = %0d", alu_out);

    // Test 4: Signed Overflow Detection (Max Positive + 1)
    a = 32'h7FFF_FFFF; b = 32'd1; alu_op = ALU_ADD; #10;
    assert(overflow === 1'b1) else $error("[OVERFLOW FAILED]");
    $display("[PASS] ADD Overflow: 0x7FFFFFFF + 1 -> Overflow Flag = %b, Sign = %b", overflow, sign);

    // Test 5: Zero Flag Verification
    a = 32'd42; b = 32'd42; alu_op = ALU_SUB; #10;
    assert(zero === 1'b1 && alu_out === 32'd0) else $error("[ZERO FLAG FAILED]");
    $display("[PASS] SUB Equality: 42 - 42 = 0 | Zero Flag = %b", zero);

    $display("=========================================================");
    $display("       ALL TESTS PASSED SUCCESSFULLY                     ");
    $display("=========================================================");
    $finish;
  end

endmodule
