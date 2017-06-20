`include "riscv/isa.v"

module riscv_wb(
	input rst,
	input clk,

	input [XLEN-1:0] exdata,
	input [XLEN-1:0] memdata,
	input memfetch,
	input [REGA-1:0] rd,

	// output
	output [XLEN-1:0] regs_out [REGN-1:0],
	output reg write_on_zero
);

parameter XLEN = 32;
parameter REGN = 32;
parameter REGA = $clog2(REGN);

reg [XLEN-1:0] regs [REGN-1:0];
assign regs_out = regs;

wire [XLEN-1:0] wb_data;
assign wb_data = (memfetch) ? memdata : exdata;
always @(posedge clk or posedge rst) begin
	if (rst) begin
		regs[0] <= 0; // Must always be zero
	end
	else if (clk) begin
		if (rd != 0) begin
			regs[rd] <= wb_data;
		end
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		write_on_zero <= 0;
	end
	else if (clk) begin
		write_on_zero <= (rd == 0);
	end
end


endmodule
