`include "riscv/wb.v"

module riscv_wb_tb();
`include "test.v"

reg [31:0] exdata;
reg [31:0] memdata;
reg memfeth;
reg [4:0] rd;

wire [XLEN-1:0] regs [0:REGN-1];
wire wr_on_zero;

riscv_wb rv_wb (
	rst,
	clk,

	exdata,
	memdata,
	memfeth,
	rd,

	regs,
	wr_on_zero
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
