`include "riscv/if.v"
`include "riscv/id.v"
`include "riscv/ex.v"
// `include "riscv/ma.v"
`include "riscv/wb.v"

module riscv_hart(
	input rst,
	input clk,

	input [XLEN-1:0] instruction,
	input [XLEN-1:0] memread,

	output [XLEN-1:0] instruction_addr,
	output [XLEN-1:0] mem_addr,
	output memfetch
);

parameter XLEN = 32;
parameter SHAMTN = $clog2(XLEN);
parameter REGN = 32;
parameter REGA = $clog2(REGN);

wire [XLEN-1:0] regs [REGN-1:0];
wire [XLEN-1:0] pc;

riscv_if #(.XLEN(XLEN)) rv_if(
	rst,
	clk,
	1'b0, // XXX: no bubbles!

	pc
);
assign instruction_addr = pc;

wire [REGA-1:0] id_rd;
wire [XLEN-1:0] a;
wire [XLEN-1:0] b;
wire [2:0] funct3;
wire id_exception;
wire [SHAMTN-1:0] shamt; // XXX
wire invertb; // XXX

riscv_id #(.XLEN(XLEN),.REGN(REGN)) rv_id(
	rst,
	clk,

	regs,
	instruction,
	pc,

	id_rd,
	a,
	b,
	funct3,
	id_exception
);

wire [XLEN-1:0] result;
wire [REGA-1:0] ex_rd;
wire ex_memfetch;

riscv_ex #(.XLEN(XLEN),.REGN(REGN)) rv_ex(
	rst,
	clk,

	id_rd,
	a,
	b,
	shamt,
	funct3,
	invertb,

	result,
	ex_rd,
	ex_memfetch
);
assign mem_addr = result;
assign memfetch = ex_memfetch;


wire ma_memfetch;
wire [REGA-1:0] ma_rd;
/*
riscv_ma rv_ma(
	rst,
	clk
);
*/
wire write_on_zero;
riscv_wb rv_wb(
	rst,
	clk,

	result,
	memread,
	memfetch,
	ma_rd,

	regs,
	write_on_zero
);

endmodule