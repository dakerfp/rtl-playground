`include "riscv-isa.v"

module RISCV32I(
	input wire rst,
	input wire clk,
	input wire [XLEN-1:0] instruction,
	input wire [XLEN-1:0] read_data,

	output reg [XLEN-1:0] instr_fetch_addr,
	output reg [XLEN-1:0] read_addr,
	output reg [XLEN-1:0] write_addr,
	output reg [XLEN-1:0] write_data,
	output reg exception
);

parameter XLEN=32;

reg [XLEN-1:0] regs [31:0]; // regs[0] == 0
reg [XLEN-1:0] pc;

// system registers
reg [64-1:0] rdcycle;

// INSTRUCTIONS DECODING
wire [6:0] opcode;
wire [4:0] rd;
wire [4:0] rs1;
wire [4:0] rs2;
wire [2:0] funct3;
wire [6:0] funct7;
wire [4:0] shamt;
wire [4:0] csr;
wire [XLEN-1:0] immi;
wire [XLEN-1:0] imms;
wire [XLEN-1:0] immb;
wire [XLEN-1:0] immu;
wire [XLEN-1:0] immj;
wire [XLEN-1:0] uimm;
wire sign;

assign op_code = instruction[6:0];
assign rd = instruction[11:7];
assign rs1 = instruction[19:15];
assign rs2 = instruction[24:20];
assign funct7 = instruction[31:25];
assign shamt = instruction[24:20];
assign sign = instruction[31];
assign immi = {{22{sign}}, instruction[30:20]};
assign imms = {{22{sign}}, instruction[30:25], instruction[11:8], instruction[7]};
assign immb = {{20{sign}}, instruction[7], instruction[30:25], instruction[11:8], 1'd0};
assign immu = {instruction[31:12], 12'd0};
assign immj = {{11{sign}},instruction[19:12],instruction[20],instruction[32:21], 1'd0};
assign uimm = {instruction[19:15]};


function conditional_branch;
input a, b, funct;
begin
	case (funct)
	`FUNCT3_BEQ: conditional_branch = a == b;
	`FUNCT3_BNEQ: conditional_branch = a != b;
	`FUNCT3_BLT: conditional_branch = $signed(a) < $signed(b);
	`FUNCT3_BLTU: conditional_branch = a < b;
	`FUNCT3_BGE: conditional_branch = $signed(a) >= $signed(b);
	`FUNCT3_BGEU: conditional_branch = a >= b;
	default: conditional_branch = 0;
	endcase
end
endfunction

function alu;
input a, b, shamt, funct3, funct7;
begin
	case (funct3)
	`FUNCT3_SLT: alu = $signed(a) < $signed(b);
	`FUNCT3_SLTU: alu = a < b;
	`FUNCT3_ADD, `FUNCT3_SUB: case (funct7)
		7'b0100000: alu = $signed(a) - $signed(b);
		7'b0000000: alu = $signed(a) + $signed(b);
		default: alu = 'bx;
	endcase
	`FUNCT3_AND: alu = a & b;
	`FUNCT3_OR: alu = a | b;
	`FUNCT3_XOR: alu = a ^ b;
	`FUNCT3_SLL: case(funct7)
		7'b0000000: alu = a << shamt;
		default: alu = 'bx;
	endcase
	`FUNCT3_SRL_SRA: case(funct7)
		7'b0000000: alu = a >> shamt;
		7'b0100000: alu = $signed(a) >>> shamt;
		default: alu = 'bx;
	endcase
	default: alu = 'bx;
	endcase
end
endfunction

function add_alu; // TODO: ensure they synthetize to the same module
input a, b;
begin
	add_alu = alu(a, b, 32'dx, `FUNCT3_ADD, 3'd0);
end
endfunction

// Update code for pc
always @(posedge clk or posedge rst) begin
	if (rst) begin
		pc = 0;
	end else if (clk) begin
		case (opcode)
		`OP_JAL: pc = add_alu(pc, immj);
		`OP_JALR: pc = add_alu(regs[rs1], immi);
		`OP_BRANCH: begin
			if (conditional_branch(regs[rs1], regs[rs2], funct3))
				pc = add_alu(pc, immb); // TODO: use alu
			else
				pc = pc + 4;
		end
		default: pc = pc + 4;
		endcase
	end
end

// Update code for regs[rd]
always @(posedge clk or posedge rst) begin
	if (rst) begin
		// TODO: registers[REGN-1:0] = 0;
		write_data = 32'd0;
		regs[2] = 32'd0;
		// regs[0] = 32'd0;
	end else if (clk) begin
		case (opcode)
		`OP_LUI: regs[rd] = immu;
		`OP_AUIPC: regs[rd] = add_alu(pc, immu); // TODO: use alu
		`OP_JAL: regs[rd] = pc + 4;
		`OP_JALR: regs[rd] = pc + 4;
		`OP: regs[rd] = alu(regs[rs1], regs[rs2], regs[rs2], funct3, funct7);
		`OP_IMM: regs[rd] = alu(regs[rs1], immi, shamt, funct3, funct7);
		`OP_LOAD: begin
			read_addr <= add_alu(regs[rs1], immi);
			regs[rd] = read_data;
		end
		`OP_STORE: begin
			write_addr = add_alu(regs[rs1], imms);
			write_data = regs[rs2];
		end
		endcase
	end
end

// rdcycle
always @(posedge clk or posedge rst) begin
	if (rst) begin
		rdcycle = 0;
	end else if (clk) begin
		rdcycle = rdcycle + 1;
	end
end

endmodule