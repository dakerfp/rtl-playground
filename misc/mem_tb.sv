
`include "misc/mem.sv"

module mem_tb;
	`include "test.v"

	logic [7:0] write_addr;
	logic [31:0] write_data;
	logic [7:0] read_addr;
	logic [31:0] read_data;

	mem #(32,256) dut(.*);

	task test_write_read;
		reset;
		write_addr = 4;
		write_data = 42;
		tick;
		read_addr = 4;
		tick;
		if (read_data != 42) $error;
	endtask : test_write_read

	task test_write_read_simul;
		reset;
		write_addr = 4;
		write_data = 42;
		read_addr = 4;
		tick;
		if (read_data != 42) $error;
	endtask : test_write_read_simul

	initial begin
		test_write_read;
		test_write_read_simul;
		$finish;
	end

endmodule : mem_tb
