
module riscv_simulator;
`include "test.v"

reg [31:0] data [0:3];
initial $readmemh("rom.txt", data);

initial begin
     $finish;
end     
endmodule 