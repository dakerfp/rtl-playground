
module riscv_if

	#(parameter XLEN = 32)

	(input logic rst, clk,

	 input logic bubble,

	 output logic [XLEN-1:0] pc);

	always @(posedge clk or posedge rst)
		if (rst)
			pc <= 0;
		else if (clk)
			if (~bubble)
				pc <= pc + 4;

endmodule : riscv_if