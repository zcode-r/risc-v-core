`timescale 1ns/1ps

import riscv_pkg::*;

//CONTROL UNIT

module control_unit(
  input logic [6:0] opcode,
  
  //ALU helper
  output logic [1:0] alu_op_type,// 00: Load/Store, 01: Branch, 10: R/I-Type
  output logic is_i_type, //1 for I
  
  //MUX 
  output logic alu_src,// 0: second ALU operand from rs2, 1: from imm_gen
  output logic mem_to_reg,// 0: write ALU result to rd, 1: write Data RAM data to rd
  output logic reg_write,// 1: write to destination register rd
  output logic mem_read,// 1:read from DATA RAM (LW)
  output logic mem_write,// 1:write to Data RAM (SW)
  output logic branch,// 1: branch instruction (BEQ,BNE)
  output logic jump// 1:unconditional jump (JAL,JALR)
);
  
  always_comb begin
    alu_op_type=2'b00;
    is_i_type=0;
    alu_src=0;
    mem_to_reg=0;
    reg_write=0;
    mem_read=0;
    mem_write=0;
    branch=0;
    jump=0;
    
    case(opcode) 
      
      //1: R-type (ADD SUB AND OR SLT...)
      OPC_R_TYPE: begin
        reg_write=1;
        alu_src=0;
        alu_op_type=2'b10;// Look at funct3 & funct7
      end
      
      //2: I-type (ADDI ANDI ORI SLTI...)
      OPC_I_ARITH: begin
        reg_write=1;
        alu_src=1;
        is_i_type=1;// Force ADD, ignore bit 30
        alu_op_type=2'b10;
      end
      
      //3 Load Word (LW)
      OPC_I_LOAD: begin
        reg_write=1;
        alu_src=1;
        mem_to_reg=1;
        mem_read=1;
        alu_op_type=2'b00;// Address calculation (ADD)
      end
      
      //4 Store Word (SW)
      OPC_S_TYPE: begin
        alu_src=1;
        mem_write=1;// Write RAM
        alu_op_type=2'b00;
      end
      
      //5 Branch (BEQ BNE..)
      OPC_B_TYPE: begin
        branch=1;
        alu_src=0;
        alu_op_type=2'b01;// Subtract to compare
      end
      
      //6 Jump (JAL)
      OPC_J_JAL: begin
        jump=1;
        reg_write=1;// Write PC+4 into rd
      end
      
      //7 Load Upper Immediate (LUI)
      OPC_U_LUI: begin
        reg_write=1;
        alu_src=1;
      end
      
      default:begin
      end
      
    endcase
  end
  
endmodule
