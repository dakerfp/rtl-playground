`include "riscv/if.v"
`include "riscv/id.v"

module riscv_id_tb();
`include "test.v"

reg [31:0] mem [0:32];

reg bubble;
riscv_if rv_if(
	rst,
	clk,
	bubble,

	pc
);

reg [31:0] instruction;
wire [31:0] pc;
wire [31:0] a;
wire [31:0] b;
wire [4:0] rd;
wire [2:0] funct3;
wire exception;
riscv_id rv_id (
	rst,
	clk,
	instruction,
	pc,

	rd,
	a,
	b,
	funct3,
	exception
);

always @(posedge clk) begin
	instruction <= mem[pc[4:0]];
end

task test_if_id;
begin
	mem[0] = 32'd44040851;
	bubble = 0;
	reset;
	// li t0, 42
	tick; // needs 2 clocks to reach ID
	tick; 
	assert(rd == 5'd5, "rd = 5");
	assert(a == 32'd0, "a == 0");
	assert(b == 32'd42, "b == 42");
	assert(funct3 == 3'b000, "funct3 == add");
	assert(~exception, "noexcept");
end
endtask

initial begin
	test_if_id;
	success;
end

endmodule