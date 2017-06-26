
`include "riscv/if.v"
`include "riscv/id.v"
`include "riscv/ex.v"

module riscv_if_id_ex_tb;

	`include "test.v"

	logic [31:0] mem [0:32];
	logic bubble;
	logic [31:0] pc;
	riscv_if rv_if(
		rst,
		clk,
		bubble,

		pc
	);

	logic [31:0] regs [31:0];
	logic [31:0] instruction;
	logic [31:0] a;
	logic [31:0] b;
	logic [4:0] rdi;
	logic [2:0] funct3;
	logic exception;
	riscv_id rv_id (
		rst,
		clk,

		regs,
		instruction,
		pc,

		rdi,
		a,
		b,
		funct3,
		exception
	);

	logic [4:0] shamt;
	logic invertb;

	logic [31:0] result;
	logic [4:0] rd;
	logic memfetch;

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

	task test_if_id_ex;
	begin
		reset;
		$dumpfile("/tmp/hart.vcd");
		$dumpvars(0, riscv_if_id_ex_tb);
		mem[0] = {12'd42, 5'd0, `FUNCT3_ADD, 5'd5, `OP_IMM}; // li t0, 42
		mem[4] = {12'd9, 5'd0, `FUNCT3_ADD, 5'd6, `OP_IMM}; // addi t1, zero, 9
		bubble = 0;
		invertb = 0;
		regs[0] = 0;


		reset; assert_if(pc == 0, "pc == 0"); // li: IF | add: -
		tick; assert_if(pc == 4, "pc == 4"); // li: ID | addi: IF
		tick; assert_if(pc == 8, "pc == 8"); // li: EX | addi: ID
		tick; assert_if(pc == 12, "pc == 8"); // li: OUT | addi: EX

		assert_if(rd == 5'd5, "rd = 5");
		assert_if(result == 42, "res == 42");
		assert_if(~exception, "noexcept");

		assert_if(funct3 == `FUNCT3_ADD, "ADD");
		assert_if(a == 0, "a == 0");
		assert_if(b == 9, "b == 9");

		tick; assert_if(pc == 16, "c == 16"); // li: - | addi: OUT

		assert_if(rd == 5'd6, "rd = 6");
		assert_if(result == 9, "res == 9");
		assert_if(~exception, "noexcept");
	end
	endtask

	initial begin
		test_if_id_ex;
		success;
	end

endmodule : riscv_if_id_ex_tb
