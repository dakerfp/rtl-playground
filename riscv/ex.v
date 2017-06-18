
`include "riscv/isa.v"

module riscv_ex(
	input wire rst,
	input wire clk,

	input wire [REGA-1:0] rdi,
	input wire [XLEN-1:0] a,
	input wire [XLEN-1:0] b,
	input wire [SHAMTN-1:0] shamt,
	input wire [2:0] funct3,
	input wire invertb,

	output reg [XLEN-1:0] result,
	output reg [REGA-1:0] rd,
	output reg memfetch
);

parameter XLEN = 32;
parameter REGN = 32;
parameter SHAMTN = $clog2(XLEN);
parameter REGA = $clog2(REGN);

// forward rd
always @(posedge clk or posedge rst) begin
	if (rst)
		rd <= 0;
	else if (clk)
		rd <= rdi;
end

// ALU
always @(posedge clk or posedge rst) begin
	if (rst)
		result <= 0;
	else if (clk) begin
		case (funct3)
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
	end
end

// Memory fetch
always @(posedge clk or posedge rst) begin
	if (rst) begin
		memfetch <= 0;
	end
end

endmodule