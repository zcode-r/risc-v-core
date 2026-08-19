`timescale 1ps/1ps

module instruction_mem #(
    parameter int MEM_DEPTH= 1024;
    parameter string HEX_FILE="";
) (
    
    input logic [31:0] addr,
    output logic [31:0] inst
);

logic [31:0] mem [0:MEM_DEPTH-1];

initial begin
    if(HEX_FILE!="") begin
        $readmemh(HEX_FILE,mem);
    end
end

assign inst=mem[(addr[31:2])%MEM_DEPTH];

endmodule
