`include "riscv/isa.v"

module riscv_wb

	#(parameter XLEN = 32,
	  parameter REGN = 32)

	(input logic rst, clk,

	 input logic [XLEN-1:0] exdata,
	 input logic [XLEN-1:0] memdata,
	 input logic memfetch,
	 input logic [REGA-1:0] rd,

	// output
	 output logic [XLEN-1:0] regs_out [REGN-1:0],
	 output logic write_on_zero);

	localparam REGA = $clog2(REGN);

	logic [XLEN-1:0] regs [REGN-1:0];
	assign regs_out = regs;

	logic [XLEN-1:0] wb_data;
	assign wb_data = (memfetch) ? memdata : exdata;
	always @(posedge clk or posedge rst)
		if (rst)
			regs[0] <= 0; // Must always be zero
		else if (clk)
			if (rd != 0)
				regs[rd] <= wb_data;

	always @(posedge clk or posedge rst)
		if (rst)
			write_on_zero <= 0;
		else if (clk)
			write_on_zero <= (rd == 0);

endmodule : riscv_wb
