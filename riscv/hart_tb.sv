
`include "riscv/hart.sv"

module riscv_hart_tb();

	`include "test.v"

	instruction_t instruction;
	logic [XLEN-1:0] pc;

	logic [XLEN-1:0] mem_read;
	logic [XLEN-1:0] mem_addr, mem_data;
	logic mem_write;

	riscv_hart #(32,32) dut (.*);

	initial begin
		reset;
		$display("DONE");
	end

endmodule : riscv_hart_tb
