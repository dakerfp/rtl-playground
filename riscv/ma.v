
`include "riscv/isa.v"

module riscv_ma(
	input wire rst,
	input wire clk,

	input wire [XLEN-1:0] memi,
	input wire [XLEN-1:0] resi,
	input wire [REGA-1:0] rdi,
	input wire memfetch,

	output reg [REGA-1:0] rd,
	output reg [XLEN-1:0] res
);

parameter XLEN = 32;
parameter REGA = 5; // REGN == 32

// forward rd
always @(posedge clk or posedge rst) begin
	if (rst)
		rd <= 0;
	else if (clk)
		rd <= rdi;
end

// Memory fetch
always @(posedge clk or posedge rst) begin
	if (rst) begin
		res <= 0;
	end
	else if (clk) begin
		if (memfetch)
			res <= memi;
		else
			res <= resi;
	end
end

endmodule