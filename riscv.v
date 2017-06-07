
`define OP 7'b0010010
`define OP_IMM 7'b0010011
`define OP_LUI 7'd1
`define OP_AUIPC 7'd2
`define OP_JAL 7'd3
`define OP_JALR 7'd4
`define OP_BRANCH 7'd5
`define OP_LOAD 7'd6
`define OP_STORE 7'd7
`define FUNCT_ADD_SUB 3'b000
`define FUNCT_SLT 3'b010
`define FUNCT_SLTU 3'b011
`define FUNCT_XOR 3'b100
`define FUNCT_OR  3'b110
`define FUNCT_AND 3'b111
`define FUNCT_SLL 3'b001
`define FUNCT_SRL_SRA 3'b101
`define FUNCT_BEQ 3'b000
`define FUNCT_BNEQ 3'b001
`define FUNCT_BLT 3'b010
`define FUNCT_BLTU 3'b011
`define FUNCT_BGE 3'b100
`define FUNCT_BGEU 3'b101

module riscv32i(
	input rst,
	input clk,
	input [XLEN-1:0] instruction,
	output reg [XLEN-1:0] read_addr,
	input wire [XLEN-1:0] read_data,
	output reg [XLEN-1:0] write_addr,
	output reg [XLEN-1:0] write_data
);

parameter XLEN=32;

reg [XLEN-1:0] regs [31:0]; // regs[0] == 0
reg [XLEN-1:0] pc;

wire [6:0] opcode;
wire [4:0] rd;
wire [4:0] rs1;
wire [4:0] rs2;
wire [2:0] funct3;
wire [6:0] funct7;
wire [4:0] shamt;
assign op_code = instruction[6:0];
assign rd = instruction[11:7];
assign rs1 = instruction[19:15];
assign rs2 = instruction[24:20];
assign funct7 = instruction[31:25];
assign shamt = instruction[24:20];

wire [XLEN-1:0] immi;
wire [XLEN-1:0] imms;
wire [XLEN-1:0] immb;
wire [XLEN-1:0] immu;
wire [XLEN-1:0] immj;
wire sign;
assign sign = instruction[31];
assign immi = {{22{sign}}, instruction[30:20]};
assign imms = {{22{sign}}, instruction[30:25], instruction[11:8], instruction[7]};
assign immb = {{20{sign}}, instruction[7], instruction[30:25], instruction[11:8], 1'd0};
assign immu = {instruction[31:12], 12'd0};
assign immj = {{11{sign}},instruction[19:12],instruction[20],instruction[32:21], 1'd0};

function conditional_branch;
input rs1, rs2, funct;
begin
	case (funct)
	`FUNCT_BEQ:
		conditional_branch = rs1 == rs2;
	`FUNCT_BNEQ:
		conditional_branch = rs1 != rs2;
	`FUNCT_BLT:
		conditional_branch = $signed(rs1) < $signed(rs2);
	`FUNCT_BLTU:
		conditional_branch = rs1 < rs2;
	`FUNCT_BGE:
		conditional_branch = $signed(rs1) >= $signed(rs2);
	`FUNCT_BGEU:
		conditional_branch = rs1 >= rs2;
	endcase
end
endfunction

function alu;
input a, b, shamt, funct3, funct7;
begin
	case (funct3)
	`FUNCT_SLT:
		if ($signed(a) < $signed(b)) alu = 1;
		else alu = 0;
	`FUNCT_SLTU:
		if (a < b) alu = 1;
		else alu = 0;
	`FUNCT_ADD_SUB: case (funct7)
		7'b0100000: alu = $signed(a) - $signed(b);
		default: alu = $signed(a) + $signed(b);
	endcase
	`FUNCT_AND: alu = a & b;
	`FUNCT_OR: alu = a | b;
	`FUNCT_XOR: alu = a ^ b;
	`FUNCT_SLL: case(funct7)
		7'b0000000: alu = a << shamt;
		default: alu = 0;
	endcase
	`FUNCT_SRL_SRA: case(funct7)
		7'b0000000: alu = a >> shamt;
		7'b0100000: alu = $signed(a) >>> shamt;
		default: alu = 0;
	endcase
	default: alu = 0;
	endcase
end
endfunction

function add_alu; // TODO: ensure they synthetize to the same module
input a, b;
begin
	add_alu = alu(a, b, 32'dx, `FUNCT_ADD_SUB, 3'd0);
end
endfunction


always @(posedge clk or posedge rst) begin
	if (rst) begin
		// TODO: registers[REGN-1:0] = 0;
		pc = 0;
		write_data = 32'd0;
	end else if (clk) begin
		case (opcode)
		`OP_LUI: begin
			regs[rd] = immu;
			pc = pc + 4;
		end
		`OP_AUIPC: begin
			regs[rd] = add_alu(pc, immu); // TODO: use alu
			pc = pc + 4;
		end
		`OP_BRANCH: begin
			if (conditional_branch(regs[rs1], regs[rs2], funct3))
				pc = add_alu(pc, immb); // TODO: use alu
			else
				pc = pc + 4;
		end
		`OP_JAL: begin
			pc = add_alu(pc, immj);
			regs[rd] = pc + 4;
		end
		`OP_JALR: begin
			pc = add_alu(regs[rs1], immi);
			regs[rd] = pc + 4;
		end
		`OP: begin
			regs[rd] = alu(regs[rs1], regs[rs2], regs[rs2], funct3, funct7);
			pc = pc + 4;
		end
		`OP_IMM: begin
			regs[rd] = alu(regs[rs1], immi, shamt, funct3, funct7);
			pc = pc + 4;
		end
		`OP_LOAD: begin
			read_addr <= add_alu(regs[rs1], immi);
			regs[rd] = read_data;
			pc = pc + 4;
		end
		`OP_STORE: begin
			write_addr = add_alu(regs[rs1], imms);
			write_data = regs[rs2];
			pc = pc + 4;
		end
		endcase
	end
end

endmodule