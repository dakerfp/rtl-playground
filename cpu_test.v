`include "cpu.v"
`include "clock.v"
`include "mem.v"

module cpu_tb();

reg rst;
reg clk;
reg [15:0] inst;
wire [15:0] wr_addr;
wire [15:0] out;

cpu #(.N(16), .REGN(4)) cpu0(rst, clk, inst, wr_addr, out);

initial begin
	#1 rst = 1;
	#1 rst = 0; clk = 1;
	inst = {`INST_LDI, `AX, 8'd42}; #1 clk = 0; #1 clk = 1;
	inst = {`INST_WRO, `AX, 8'd0}; #1 clk = 0; #1 clk = 1;
	inst = 16'd0;
	#10

	if (out == 16'hx) begin
		$display("WRO not working");
		$finish_and_return(1);
	end

	if (out != 8'd42) begin
		$display("LOAD & OUT");
		$display("wrong value on out: %d", out);
		$finish_and_return(1);
	end

	#1 rst = 1;
	#1 rst = 0; clk = 1;
	inst = {`INST_LDI, `AX, 8'd20}; #1 clk = 0; #1 clk = 1;
	inst = {`INST_LDI, `BX, 8'd3}; #1 clk = 0; #1 clk = 1;
	inst = {`INST_ADD, `AX, `BX, `CX}; #1 clk = 0; #1 clk = 1;
	inst = {`INST_WRO, `CX, 8'd0}; #1 clk = 0; #1 clk = 1;
	inst = 16'd0; #1 clk = 0; #1 clk = 1;
	#10

	if (out != 23) begin
		$display("ADD ONCE");
		$display("wrong value on out: %d", out);
		$finish_and_return(1);
	end

	#1 rst = 1;
	#1 rst = 0; clk = 1;
	inst = {`INST_LDI, `AX, 8'd3}; #1 clk = 0; #1 clk = 1;
	inst = {`INST_LDI, `BX, 8'd2}; #1 clk = 0; #1 clk = 1;
	inst = {`INST_ADD, `AX, `BX, `CX}; #1 clk = 0; #1 clk = 1;
	inst = {`INST_ADD, `CX, `BX, `CX}; #1 clk = 0; #1 clk = 1;
	inst = {`INST_ADD, `CX, `BX, `CX}; #1 clk = 0; #1 clk = 1;
	inst = {`INST_WRO, `CX, 8'd0}; #1 clk = 0; #1 clk = 1;
	inst = 16'd0;
	#10

	if (out != 9) begin
		$display("ADD MANY");
		$display("wrong value on out: %d", out);
		$finish_and_return(1);
	end

	#1 rst = 1;
	#1 rst = 0; clk = 1;
	inst = {`INST_LDI, `AX, 8'd19}; #1 clk = 0; #1 clk = 1;
	inst = {`INST_LDI, `BX, 8'd3}; #1 clk = 0; #1 clk = 1;
	inst = {`INST_SUB, `AX, `BX, `CX}; #1 clk = 0; #1 clk = 1;
	inst = {`INST_WRO, `CX, 8'd0}; #1 clk = 0; #1 clk = 1;
	inst = 16'd0; #1 clk = 0; #1 clk = 1;
	#10

	if (out != 16) begin
		$display("SUB");
		$display("wrong value on out: %d", out);
		$finish_and_return(1);
	end


	$finish;
end

endmodule