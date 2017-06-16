
`include "riscv/isa.v"
`include "riscv/ma.v"

module riscv_id_tb();
`include "test.v"

reg [31:0] memi;
reg [31:0] resi;
reg [4:0] rdi;
reg memfetch;

wire [4:0] rd;
wire [31:0] res;

riscv_ma rv_ma (
	rst,
	clk,

	memi,
	resi,
	rdi,
	memfetch,

	rd,
	res
);

task test_ma_basic;
begin
	reset;
	assert(rd == 0, "reset ok");
	assert(res == 0, "reset ok");

	// li t0, 42
	memi = 'bx; rdi = 5; resi = 42; memfetch = 0;
	tick;
	assert(rd == 5, "rd = 5");
	assert(res == 42, "res == 9");

	// addi t1, zero, 9 == li t1, 9
	// li t0, 42
	memi = 'bx; rdi = 6; resi = 9; memfetch = 0;
	tick;
	assert(rd == 6, "rd = 5");
	assert(res == 9, "res == 9");

	// lui t2, 34 # mem[34] = 777
	// li t0, 42
	memi = 777; rdi = 7; resi = 'bx; memfetch = 1;
	tick;
	assert(rd == 7, "rd = 7");
	assert(res == 777, "res == 9");
end
endtask

initial begin
	test_ma_basic;
	success;
end

endmodule