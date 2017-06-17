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
	instruction = {12'd42, 5'd0, `FUNCT3_ADD, 5'd5, `OP_IMM};
	tick;
	assert_if(rd == 5'd5, "rd = 5");
	assert_if(a == 32'd0, "a == 0");
	assert_if(b == 32'd42, "b == 42");
	assert_if(funct3 == 3'b000, "funct3 == add");
	assert_if(~exception, "noexcept");

	// addi t1, zero, 9 == li t1, 9
	instruction = {12'd9, 5'd0, `FUNCT3_ADD, 5'd6, `OP_IMM};
	tick;
	assert_if(rd == 5'd6, "rd = 6");
	assert_if(a == 32'd0, "a == 0");
	assert_if(b == 32'd9, "b == 9");
	assert_if(funct3 == 3'b000, "funct3 == add");
	assert_if(~exception, "noexcept");
end
endtask

initial begin
	test_decode_immi;
	success;
end

endmodule