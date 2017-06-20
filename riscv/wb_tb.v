`include "riscv/wb.v"

module riscv_wb_tb();
`include "test.v"

reg [31:0] exdata;
reg [31:0] memdata;
reg memfeth;
reg [4:0] rd;

wire [31:0] regs [31:0];
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

task test_wb;
begin
	reset;
end
endtask

initial begin
	success;
end

endmodule
