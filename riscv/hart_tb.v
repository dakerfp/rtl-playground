
`include "riscv/hart.v"

module riscv_hart_tb();

`include "test.v"

wire [31:0] instr_addr;
wire [31:0] mem_addr;
logic memfetch;
logic memwrite;

reg [31:0] instr_fetch;
reg [31:0] mem_fetch;

riscv_hart rv_hart(
	rst,
	clk,

	instr_fetch,
	mem_addr,

	instr_addr,
	instr_fetch,
	memwrite, memfetch
);



endmodule