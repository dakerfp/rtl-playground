
`include "misc/mem.sv"

module mem_tb;
	`include "test.v"

	logic write;
	logic [7:0] write_addr;
	logic [31:0] write_data;
	logic [7:0] read_addr;
	logic [31:0] read_data;

	mem #(32,256) dut(.*);

	task test_write_no_write;
		reset;
		write = 0;
		write_addr = 4;
		write_data = 42;
		tick;
		read_addr = 4;
		tick;
		if (read_data == 42) $error;
		write_data = 31;
		write = 1;
		tick;
		tick;
		if (read_data != 31) $error;
	endtask : test_write_no_write

	task test_write_read;
		reset;
		write = 1;
		write_addr = 4;
		write_data = 42;
		tick;
		read_addr = 4;
		tick;
		if (read_data != 42) $error;
		write_data = 31;
		tick;
		tick;
		if (read_data != 31) $error;
	endtask : test_write_read

	task test_write_read_simul;
		reset;
		write = 1;
		write_addr = 20;
		write_data = 42;
		read_addr = 20;
		tick;
		if (read_data != 'bx) $error;
		tick;
		if (read_data != 42) $error;
	endtask : test_write_read_simul

	task test_write_read_diff;
		reset;
		write = 1;
		write_addr = 8;
		write_data = 33;
		tick;
		write_addr = 12;
		write_data = 99;
		tick;
		write_addr = 16;
		write_data = 66;
		read_addr = 12;
		tick;
		if (read_data != 99) $error;
		read_addr = 16;
		tick;
		if (read_data != 66) $error;
		read_addr = 8;
		tick;
		if (read_data != 33) $error;
		tick;
	endtask : test_write_read_diff

	initial begin
		test_write_no_write;
		test_write_read;
		test_write_read_simul;
		test_write_read_diff;
		$finish;
	end

endmodule : mem_tb
