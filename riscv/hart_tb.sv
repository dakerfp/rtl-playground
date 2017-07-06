
`include "riscv/hart.sv"

module riscv_hart_tb();

	`include "test.v"

	instruction_t instruction;
	logic [31:0] pc;

	logic [31:0] mem_read;
	logic [31:0] mem_addr;
	logic [31:0] mem_data;
	logic mem_write;

	riscv_hart #(32,32) dut (.*);

	instruction_t instr_memory [0:255];
	logic [31:0] data_memory [0:255];

	always @(posedge clk or posedge rst)
		if (rst) begin
			mem_read <= 0;
			instruction <= 0;
		end
		else begin
			instruction <= instr_memory[pc];
			if (mem_write)
				data_memory[mem_addr] <= mem_data;
			else
				mem_read <= data_memory[mem_addr];
		end

	task test_li;
		instr_memory[8'd0] = { // li t0, 42
			12'd42, 5'd0, FUNCT3_ADD, 5'd5, OP_IMM
		};
		instr_memory[8'd4] = { // li x1, 77
			12'd77, 5'd0, FUNCT3_ADD, 5'd1, OP_IMM
		};
		instr_memory[8'd8] = { // nop
			32'd0
		};
		instr_memory[8'd12] = { // nop
			32'd0
		};
		instr_memory[8'd16] = { // nop
			32'd0
		};
		instr_memory[8'd20] = { // sw
			7'd0, 5'd5, 5'd0, 3'b010, 5'd12, OP_STORE
		};
		instr_memory[8'd24] = { // sw
			7'd0, 5'd1, 5'd0, 3'b010, 5'd8, OP_STORE
		};
		reset;
		tick;
		tick;
		tick;
		tick;
		tick;
		tick;
		tick;
		tick;
		tick;
		tick;
		if (!(data_memory[12] == 42)) $error;
		tick;
		if (!(data_memory[8] == 77)) $error;
	endtask : test_li

	initial begin
		$dumpfile("/tmp/hart.vcd");
		$dumpvars(0, dut);
		test_li;
	end

endmodule : riscv_hart_tb
