`include "riscv/if.v"

module riscv_if_tb();
`include "test.v"

reg bubble;
wire [31:0] pc;
riscv_if rv_if (
	rst,
	clk,
	bubble,

	pc
);

task test_bubble;
begin
	bubble = 0;
	reset; assert(pc == 0, "reset 1");
	tick; assert(pc == 4, "clk 1");
	tick; assert(pc == 8, "clk 2");
	tick; assert(pc == 12, "clk 3");
	bubble = 1; tick; assert(pc == 12, "bubble 1");
	bubble = 1; tick; assert(pc == 12, "bubble 2");
	bubble = 0; tick; assert(pc == 16, "clk 5");
	reset; assert(pc == 0, "reset 2");
end
endtask

initial begin
	test_bubble;
	success;
end

endmodule