`define ALU_ADD  3'd0
`define ALU_SUB  3'd1
`define ALU_LESS 3'd2
`define ALU_EQ   3'd3
`define ALU_OR   3'd4
`define ALU_AND  3'd5
`define ALU_NOT  3'd6

module alu(
	input  [2:0]   opcode,
	input  [N-1:0] op_a, op_b,
	output wire [N-1:0] out
);

parameter N = 32;

// result used in LHS of always block-> must be reg
reg [N-1:0] result;
assign out = result;

always @* begin
	case (opcode)
		`ALU_ADD:  result = op_a + op_b;
		`ALU_SUB:  result = op_a - op_b;
		`ALU_LESS: result = op_a < op_b;
		`ALU_EQ:   result = op_a == op_b;
		`ALU_OR:   result = op_a | op_b;
		`ALU_AND:  result = op_a & op_b;
		`ALU_NOT:  result = ~op_a;
		default: result = 0;
	endcase
end

endmodule
