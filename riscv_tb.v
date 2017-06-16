
`include "riscv.v"

module riscv_tb();

reg clk;
reg rst;
reg [31:0] cachel1 [0:255];

wire [31:0] instruction;
wire [31:0] instr_fetch_addr;
assign instruction = cachel1[instr_fetch_addr[4:0]];
wire [31:0] read_addr;
wire [31:0] read_data;
assign read_data = cachel1[read_data];
wire [31:0] write_addr;
wire [31:0] write_data;
wire exception;

RISCV32I riscv(
	rst,
	clk,
	instruction,
	read_data,
	instr_fetch_addr,
	read_addr,
	write_addr,
	write_data,
	exception
);

always @(posedge clk) begin
	if (write_addr[7:0] != 0)
		if (write_addr[7:0] != 32'bz)
			cachel1[write_addr[7:0]] <= write_data;
end

initial $readmemb("a.bin", cachel1);
initial begin
	rst = 1;
	clk = 0;
	#1
	rst = 0;
	clk = 1;
end

endmodule