`include "cpu.v"
`include "mem.v"

module picosystem8()

wire rst;
wire clk;
reg [3:0] addr;
reg [3:0] data_in;
reg wr;
wire [3:0] data_out;

clock clk0(clk);
cpu #(.N(16), .REGN(4)) cpu0(rst, clk, inst, out);
mem #(.ADDR(4), .WORD(4)) mem0 (
	clk,
	addr,
	data_in,
	wr,
	data_out
);

endmodule
