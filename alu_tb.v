`include "alu.v"
`include "clock.v"

module alu_tb();
  
	wire clk;
	clock clk0(clk);

	reg [2:0] opcode;
	reg [15:0] a;
	reg [15:0] b;
	wire [15:0] r;
	alu #(.N(16)) alu0 (opcode, a, b, r);

initial begin
	#0
	opcode = `ALU_ADD;
	a = 40;
	b = 2;
	#1
	if (r != 42) begin
   		$display("wrong value on add");
   		$finish_and_return(1);
   	end
   	#1
	opcode = `ALU_SUB;
	a = 40;
	b = 2;
	#1
	if (r != 38) begin
   		$display("wrong value on sub");
   		$finish_and_return(1);
   	end
   	#1
	opcode = `ALU_OR;
	a = 40;
	b = 31;
	#1
	if (r != (41 | 31)) begin
   		$display("wrong value on or");
   		$finish_and_return(1);
   	end
   	#1
	opcode = `ALU_AND;
	a = 40;
	b = 31;
	#1
	if (r != (40 & 31)) begin
   		$display("wrong value on and");
   		$finish_and_return(1);
   	end
   	$finish;
end
   
endmodule