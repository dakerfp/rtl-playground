
`include "riscv/isa.v"

module riscv_ma

	#(parameter XLEN = 32,
	  parameter REGN = 32)

	(input logic rst, clk,

	 input logic [XLEN-1:0] memi,
	 input logic [XLEN-1:0] resi,
	 input logic [REGA-1:0] rdi,
	 input logic memfetch,

	 output logic [REGA-1:0] rd,
	 output logic [XLEN-1:0] res);


	localparam REGA = $clog2(REGN);

	// forward rd
	always @(posedge clk or posedge rst)
		if (rst)
			rd <= 0;
		else if (clk)
			rd <= rdi;

	// Memory fetch
	always @(posedge clk or posedge rst)
		if (rst)
			res <= 0;
		else if (clk)
			res <= (memfetch) ? memi : resi;

endmodule : riscv_ma
