
`include "riscv/hart.sv"

module hartsim();

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
			instruction <= instr_memory[pc >> 2];
			if (mem_write)
				data_memory[mem_addr >> 2] <= mem_data;
			else
				mem_read <= data_memory[mem_addr >> 2];
		end

	integer i;
	integer nclocks;
	initial begin
		if (!$value$plusargs("%d", nclocks)) $error;
		$readmemh("/tmp/rom.hex", instr_memory);
		reset;
		tickn(nclocks);
		$writememh("dump.hex", data_memory);
	end

endmodule : hartsim
