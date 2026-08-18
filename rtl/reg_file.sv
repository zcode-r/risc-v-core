`timescale 1ns/1ps

module reg_file #(
  parameter int DATA_WIDTH=32,
  parameter int REG_COUNT=32
)(
  
  input logic clk,
  input logic reset,
  
  //write
  input logic wen,
  input logic [$clog2(REG_COUNT)-1:0] waddr,
  input logic [DATA_WIDTH-1:0] wdata,
  
  //read-1
  input logic [$clog2(REG_COUNT)-1:0] raddr1,
  output logic [DATA_WIDTH-1:0] rdata1,
  
  //read-2
  input logic [$clog2(REG_COUNT)-1:0] raddr2,
  output logic [DATA_WIDTH-1:0] rdata2
  
);
  
  logic [DATA_WIDTH-1:0] registers [0:REG_COUNT-1];
  
  //ASYNC READ
  assign rdata1=(raddr1=='0)?'0:registers[raddr1];
  assign rdata2=(raddr2=='0)?'0:registers[raddr2];
  
  //SYNC WRITE
  integer i;
  always_ff @(posedge clk or posedge reset) begin
    if(reset) begin
      for(i=0; i<REG_COUNT; ++i) begin
        registers[i]<={DATA_WIDTH{1'b0}};
      end
    end
    else if(wen && (waddr!=5'd0)) begin
      registers[waddr]<=wdata;
    end
  end
  
endmodule
