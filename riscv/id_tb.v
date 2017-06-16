`include "riscv/isa.v"
`include "riscv/id.v"

module riscv_id_tb();
`include "test.v"

reg [31:0] instruction;
reg [31:0] pc;
wire [31:0] a;
wire [31:0] b;
wire [4:0] rd;
wire [2:0] funct3;
wire exception;
riscv_id rv_id (
	rst,
	clk,
	instruction,
	pc,

	rd,
	a,
	b,
	funct3,
	exception
);

task test_decode_immi;
begin
	reset;
	// li t0, 42
	instruction = 32'd44040851; tick;
	assert(rd == 5'd5, "rd = 5");
	assert(a == 32'd0, "a == 0");
	assert(b == 32'd42, "b == 42");
	assert(funct3 == 3'b000, "funct3 == add");
	assert(~exception, "noexcept");
end
endtask

initial begin
	test_decode_immi;
	success;
end

endmodule