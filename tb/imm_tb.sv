`timescale 1ns/1ps

module imm_gen_tb;

  logic [31:0] inst;
  logic [31:0] imm_out;

  // Instantiate DUT
  imm_gen dut (
    .inst(inst),
    .imm_out(imm_out)
  );

  initial begin
    $display("---------------------------------------------------------");
    $display("[TB START] Testing RISC-V 32-bit Immediate Generator");
    $display("---------------------------------------------------------");

    // Test 1: ADDI x5, x1, 10 (I-type positive constant: +10)
    // Inst: imm=10 (12'h00A), rs1=1, funct3=0, rd=5, op=7'h13
    inst = 32'b000000001010_00001_000_00101_0010011; #10;
    $display("[I-TYPE +10] Result: %0d (Expected: 10) | Hex: 0x%08h", $signed(imm_out), imm_out);

    // Test 2: ADDI x5, x1, -4 (I-type negative constant: -4 = 12'hFFC)
    // Inst: imm=-4 (12'b111111111100), rs1=1, funct3=0, rd=5, op=7'h13
    inst = 32'b111111111100_00001_000_00101_0010011; #10;
    $display("[I-TYPE  -4] Result: %0d (Expected: -4) | Hex: 0x%08h", $signed(imm_out), imm_out);

    // Test 3: SW x5, 4(x2) (S-type store offset: +4)
    // Inst: imm[11:5]=0, rs2=5, rs1=2, funct3=2, imm[4:0]=4, op=7'h23
    inst = 32'b0000000_00101_00010_010_00100_0100011; #10;
    $display("[S-TYPE  +4] Result: %0d (Expected: 4)  | Hex: 0x%08h", $signed(imm_out), imm_out);

    // Test 4: LUI x1, 0x12345 (U-type upper immediate)
    // Inst: imm=20'h12345, rd=1, op=7'h37
    inst = {20'h12345, 5'd1, 7'b0110111}; #10;
    $display("[U-TYPE LUI] Result Hex: 0x%08h (Expected: 0x12345000)", imm_out);

    $display("---------------------------------------------------------");
    $display("[ALL TESTS COMPLETED]");
    $display("---------------------------------------------------------");
    $finish;
  end

endmodule
