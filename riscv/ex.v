
`include "riscv/isa.v"

module riscv_ex

	#(parameter XLEN = 32,
	  parameter REGN = 32)

	(input logic rst, clk,

	input logic [REGA-1:0] rdi,
	input logic [XLEN-1:0] a, b,
	input logic [SHAMTN-1:0] shamt,
	input logic [2:0] funct3,
	input logic invertb,

	output logic [XLEN-1:0] result,
	output logic [REGA-1:0] rd,
	output logic memfetch);

	localparam SHAMTN = $clog2(XLEN);
	localparam REGA = $clog2(REGN);

	// forward rd
	always @(posedge clk or posedge rst)
		if (rst)
			rd <= 0;
		else if (clk)
			rd <= rdi;

	// ALU
	always @(posedge clk or posedge rst)
		if (rst)
			result <= 0;
		else if (clk) case (funct3)
		`FUNCT3_ADD: result <= $signed(a) + $signed(b);
		`FUNCT3_SLL: result <= a << shamt;
		`FUNCT3_SLT: result <= $signed(a) < $signed(b);
		`FUNCT3_SLTU: result <= a < b;
		`FUNCT3_XOR: result <= a ^ b;
		`FUNCT3_SRL_SRA:
			if (invertb) result <= $signed(a) >>> shamt;
			else result <= a >> shamt;
		`FUNCT3_OR: result <= a | b;
		`FUNCT3_AND: result <= a & b;
		endcase

	// Memory fetch
	always @(posedge clk or posedge rst)
		if (rst)
			memfetch <= 0; // XXX: todo memfetch case

endmodule : riscv_ex
