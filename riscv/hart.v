`include "riscv/if.v"
`include "riscv/id.v"
`include "riscv/ex.v"
`include "riscv/ma.v"
`include "riscv/wb.v"

module riscv_hart

	#(parameter XLEN = 32,
	  parameter REGN = 32)

	(input logic rst, clk,

	 input logic [XLEN-1:0] instruction,
	 input logic [XLEN-1:0] memread,

	 output logic [XLEN-1:0] instruction_addr,
	 output logic [XLEN-1:0] mem_addr,
	 output logic memfetch);

	localparam SHAMTN = $clog2(XLEN);
	localparam REGA = $clog2(REGN);

	logic [XLEN-1:0] regs [REGN-1:0];
	logic [XLEN-1:0] pc;

	riscv_if #(.XLEN(XLEN)) rv_if(
		rst, clk,

		1'b0, // XXX: no bubbles!

		pc
	);

	assign instruction_addr = pc;

	logic [REGA-1:0] id_rd;
	logic [XLEN-1:0] a;
	logic [XLEN-1:0] b;
	logic [2:0] funct3;
	logic id_exception;
	logic [SHAMTN-1:0] shamt; // XXX
	logic invertb; // XXX

	riscv_id #(.XLEN(XLEN),.REGN(REGN)) rv_id(
		rst, clk,

		regs, instruction, pc,

		id_rd, a, b, funct3, id_exception
	);

	logic [XLEN-1:0] result;
	logic [REGA-1:0] ex_rd;
	logic ex_memfetch;

	riscv_ex #(.XLEN(XLEN),.REGN(REGN)) rv_ex(
		rst, clk,

		id_rd, a, b, shamt, funct3, invertb,

		result, ex_rd, ex_memfetch
	);
	assign mem_addr = result;
	assign memfetch = ex_memfetch;


	logic ma_memfetch;
	logic [REGA-1:0] ma_rd;
	logic [XLEN-1:0] ma_result;

	riscv_ma rv_ma(
		rst, clk,

		0, // XXX
		result, ex_rd, ex_memfetch,

		ma_rd, ma_result
	);

	logic write_on_zero;
	riscv_wb rv_wb(
		rst,
		clk,

		result, memread, memfetch, ma_rd,

		regs, write_on_zero
	);

endmodule : riscv_hart