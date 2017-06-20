`include "riscv/ex.v"
`include "riscv/isa.v"

module riscv_ex_tb();
`include "test.v"

reg [4:0] rdi;
reg [31:0] a;
reg [31:0] b;
reg [4:0] shamt;
reg [2:0] funct3;
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

task test_alu;
begin
	// XXX: test all operations
	reset;
	assert_if(result == 0, "reset 1");
	assert_if(~memfetch, "~memfetch");

	rdi = 4; a = 40; b = 2; shamt = 0; funct3 = `FUNCT3_ADD; invertb = 0;
	tick;
	assert_if(result == 42, "40 + 2 == 42");
	assert_if(rd == 4, "rd == 4");
	assert_if(~memfetch, "~memfetch");

	rdi = 2; a = 40; b = -5; shamt = 0; funct3 = `FUNCT3_ADD; invertb = 0;
	tick;
	assert_if(result == 35, "40 - 5 == 35");
	assert_if(rd == 2, "rd == 2");
	assert_if(~memfetch, "~memfetch");

	rdi = 7; a = 3; b = 0; shamt = 2; funct3 = `FUNCT3_SLL; invertb = 0;
	tick;
	assert_if(result == 3 << 2, "40 - 5 == 35");
	assert_if(rd == 7, "rd == 7");
	assert_if(~memfetch, "~memfetch");

	reset;
	assert_if(result == 0, "reset 2");
	assert_if(~memfetch, "~memfetch");
end
endtask

initial begin
	test_alu;
	success;
end

endmodule