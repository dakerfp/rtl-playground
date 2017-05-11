`include "alu.v"

`define INST_NOP 4'd00
`define INST_ADD 4'd01
`define INST_LDI 4'd02
`define INST_WRO 4'd03
`define INST_HLT 4'd04
`define INST_SUB 4'd05

`define AX 4'd0
`define BX 4'd1
`define CX 4'd2
`define DX 4'd3

module cpu(
	input rst,
	input clk,
	input [N-1:0] instruction,
	output reg [N-1:0] outport
);

parameter N = 16;
parameter REGN = 4;
parameter OPSIZE = 4;

reg [N-1:0] pc;
reg [N-1:0] registers [REGN-1:0];


wire [OPSIZE-1:0] op_code;
wire [REGN-1:0] reg_a;
wire [REGN-1:0] reg_b;
wire [REGN-1:0] reg_c;
wire [2*REGN-1:0] immediate_value;
assign op_code = instruction[N-1:N-OPSIZE];
assign reg_a = instruction[N-OPSIZE-1:N-OPSIZE-REGN];
assign reg_b = instruction[N-OPSIZE-REGN-1:N-OPSIZE-2*REGN];
assign reg_c = instruction[N-OPSIZE-2*REGN-1:0];
assign immediate_value = {reg_b, reg_c};

wire [2:0] alu_op;
wire [N-1:0] lhs;
wire [N-1:0] rhs;
wire [N-1:0] result;
alu #(N) alu0(alu_op, lhs, rhs, result);
assign alu_op = (op_code == `INST_SUB) ? `ALU_SUB : `ALU_ADD; // XXX
assign lhs = registers[reg_a];
assign rhs = registers[reg_b];

always @(posedge clk or posedge rst) begin
	if (rst) begin
		// TODO: registers[REGN-1:0] = 0;
		pc = 0;
		outport = 0;
	end else if (clk) begin
		case (op_code)
			`INST_HLT: begin
				pc = pc;
			end
			`INST_ADD: begin
				registers[reg_c] = result;
				pc = pc + 1;
			end
			`INST_SUB: begin
				registers[reg_c] = result;
				pc = pc + 1;
			end
			`INST_WRO: begin
				outport = registers[reg_a];
				pc = pc + 1;
			end
			`INST_LDI: begin
				registers[reg_a] = immediate_value;
				pc = pc + 1;
			end
			default: pc = pc + 1; // NOP
		endcase	
	end
	// $monitor($time, " rst: %b op: %b reg_a: %b immv: %b inst: %b out: %d", rst, op_code, reg_a, immediate_value, instruction, outport);
	// $monitor($time, " AX: %d BX: %d CX: %d DX: %d", registers[`AX], registers[`BX], registers[`CX], registers[`DX]);
end

endmodule