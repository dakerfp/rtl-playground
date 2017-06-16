`include "riscv/if.v"
`include "riscv/id.v"
`include "riscv/ex.v"

module riscv_id_tb();
`include "test.v"

reg [31:0] mem [0:32];

reg bubble;
riscv_if rv_if(
	rst,
	clk,
	bubble,

	pc
);

reg [31:0] instruction;
wire [31:0] pc;
wire [31:0] a;
wire [31:0] b;
wire [4:0] rdi;
wire [2:0] funct3;
wire exception;
riscv_id rv_id (
	rst,
	clk,
	instruction,
	pc,

	rdi,
	a,
	b,
	funct3,
	exception
);

reg [5:0] shamt;
reg invertb;

wire [31:0] result;
wire [4:0] rd;
wire memfetch;

riscv_ex rv_ex (
	rst,
	clk,

	rdi,
	a,
	b,
	shamt,
	funct3,
	invertb,

	result,
	rd,
	memfetch
);

always @(posedge clk) begin
	instruction <= mem[pc[4:0]];
end

task test_if_id;
begin
	mem[0] = {12'd42, 5'd0, `FUNCT3_ADD, 5'd5, `OP_IMM}; // li t0, 42
	mem[4] = {12'd9, 5'd0, `FUNCT3_ADD, 5'd6, `OP_IMM}; // addi t1, zero, 9
	bubble = 0;

	reset; assert(pc == 0, "pc == 0"); // li: IF | add: -
	tick; assert(pc == 4, "pc == 4"); // li: ID | addi: IF
	tick; assert(pc == 8, "pc == 8"); // li: EX | addi: ID
	tick; assert(pc == 12, "pc == 8"); // li: OUT | addi: EX

	assert(rd == 5'd5, "rd = 5");
	assert(result == 42, "res == 42");
	assert(~exception, "noexcept");

	assert(funct3 == `FUNCT3_ADD, "ADD");
	assert(a == 0, "a == 0");
	assert(b == 9, "b == 9");

	tick; assert(pc == 16, "c == 16"); // li: - | addi: OUT

	assert(rd == 5'd6, "rd = 6");
	assert(result == 9, "res == 9");
	assert(~exception, "noexcept");
end
endtask

initial begin
	test_if_id;
	success;
end

endmodule