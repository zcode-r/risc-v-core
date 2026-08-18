`timescale 1ns/1ps

module imm_gen(
  input logic [31:0] inst,
  output logic [31:0] imm_out
);
  
  logic [6:0] opcode;
  assign opcode=inst[6:0];
  
  always_comb begin
    case(opcode)
      
      //I-TYPE
      7'b0010011,
      7'b0000011,
      7'b1100111: begin
        imm_out={{20{inst[31]}},inst[31:20]};
      end
      
      //S-TYPE
     7'b0100011: begin
       imm_out={{20{inst[31]}},inst[31:25],inst[11:7]};
     end
      
      //B-TYPE
      7'b1100011: begin
        imm_out = {{19{inst[31]}},inst[31],inst[7],inst[30:25],inst[11:8],1'b0};
      end
      
      //U-TYPE
      7'b0110111,
      7'b0010111: begin
        imm_out={inst[31:12],12'h000};
      end
      
      //J-TYPE
      7'b1101111: begin
        imm_out={{11{inst[31]}},inst[31],inst[19:12],inst[20],inst[30:21],1'b0};
      end
      
      //R-TYPE IS DEFAULT
      default: begin
        imm_out=32'h0000_0000;
      end
      
    endcase
    
  end
  
endmodule                           
