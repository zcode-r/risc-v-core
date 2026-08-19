`timescale 1ns/1ps

import riscv_pkg::*;

module riscv_top #(
    parameter int MEM_DEPTH=1024,
    parameter string HEX_FILE=""
) (
    input logic clk,
    input logic reset
);


//INTERNAL WIRES AND BUSES


//PROGRAM COUNTER
logic [31:0] pc_curr;
logic [31:0] pc_next;
logic [31:0] pc_plus4;
logic [31:0] branch_target;

//INSTRUCTION AND SLICES
logic [31:0] inst;
logic [6:0] opcode;
logic [4:0] rs1,rs2,rd;
logic [2:0] funct3;
logic funct7_b5;

// Control Signals
logic [1:0] alu_op_type;
logic is_i_type;
logic alu_src;
logic mem_to_reg;
logic reg_write;
logic mem_read;
logic mem_write;
logic branch;
logic jump;
alu_op_e alu_ctrl;

//Datapath Buses
logic [31:0] imm_out;
logic [31:0] rdata1,rdata2;
logic [31:0] alu_operand_b;
logic [31:0] alu_result;
logic alu_zero,alu_sign,alu_overflow,alu_carry,alu_ltu;
logic [31:0] mem_rdata;
logic [31:0] writeback_data;
logic pc_src;



//1 INSTRUCTION SLICING
assign opcode=inst[6:0];
assign rd=inst[11:7];
assign funct3=inst[14:12];
assign rs1=inst[19:15];
assign rs2=inst[24:20];
assign funct7_b5=inst[30];

//2 PROGRAM COUNTER
assign pc_plus4=pc_curr+4;
assign branch_target=pc_curr+imm_out;

//Branch decision : Taken if (branch instruction AND zero flag is high) OR unconditional jump
assign pc_src=(branch & alu_zero) | jump;
assign pc_next=(pc_src)?branch_target:pc_plus4;

always_ff @(posedge clk or posedge reset) begin
    if(reset) pc_curr<=32'h00000000;
    else pc_curr<=pc_next;
end

  //3 INSTRUCTION MEMORY
  instruction_mem #(
      .MEM_DEPTH(MEM_DEPTH),
      .HEX_FILE (HEX_FILE)
  ) u_imem (
      .addr(pc_curr),
      .inst(inst)
  );

    //4 MAIN CONTROL UNIT AND ALU UNIT
  control_unit u_ctrl (
      .opcode     (opcode),
      .alu_op_type(alu_op_type),
      .is_i_type  (is_i_type),
      .alu_src    (alu_src),
      .mem_to_reg (mem_to_reg),
      .reg_write  (reg_write),
      .mem_read   (mem_read),
      .mem_write  (mem_write),
      .branch     (branch),
      .jump       (jump)
  );

  alu_control u_alu_ctrl (
      .alu_op_type(alu_op_type),
      .funct3     (funct3),
      .funct7_b5  (funct7_b5),
      .is_i_type  (is_i_type),
      .alu_ctrl   (alu_ctrl)
  );

    //5 IMMEDIATE GENERATOR
  imm_gen u_imm_gen (
      .inst   (inst),
      .imm_out(imm_out)
  );

    //6 REGISTER FILE
  reg_file #(
      .DATA_WIDTH(32),
      .REG_COUNT (32)
  ) u_reg_file (
      .clk   (clk),
      .reset (reset),
      .wen   (reg_write),
      .waddr (rd),
      .wdata (writeback_data),
      .raddr1(rs1),
      .rdata1(rdata1),
      .raddr2(rs2),
      .rdata2(rdata2)
  );

    //7 ALU EXECUTION
  // MUX: Select Register value or Immediate for ALU Port B
  assign alu_operand_b=(alu_src)?imm_out:rdata2;

  alu #(
      .DATA_WIDTH(32)
  ) u_alu (
      .a       (rdata1),
      .b       (alu_operand_b),
      .alu_op  (alu_ctrl),
      .alu_out (alu_result),
      .zero    (alu_zero),
      .sign    (alu_sign),
      .overflow(alu_overflow),
      .carry   (alu_carry),
      .ltu     (alu_ltu)
  );

    //8 DATA MEMORY (RAM)
  data_mem #(
      .MEM_DEPTH(MEM_DEPTH)
  ) u_dmem (
      .clk      (clk),
      .reset    (reset),
      .mem_read (mem_read),
      .mem_write(mem_write),
      .addr     (alu_result), // ALU output is the memory address
      .wdata    (rdata2),     // Data to store comes from rs2
      .rdata    (mem_rdata)
  );

    //9 WRITEBACK MUX
  // Select between Memory read data (LW), ALU result, or PC+4 (JAL)
    assign writeback_data=(jump)?pc_plus4:(mem_to_reg)?mem_rdata:alu_result;

endmodule
