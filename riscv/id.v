
`include "riscv/isa.v"

module riscv_id(
	input wire rst,
	input wire clk,
	input wire [XLEN-1:0] instruction,
	input wire [XLEN-1:0] pc,

	output reg [REGA-1:0] rd,
	output reg [XLEN-1:0] a,
	output reg [XLEN-1:0] b,
	output reg [2:0] funct3,
	output reg exception
);

parameter XLEN = 32;
parameter REGA = 5; // REGN == 32

reg [XLEN-1:0] regs [31:0]; // regs[0] == 0

// Renaming
wire [6:0] opcode;
wire [4:0] rs1;
wire [4:0] rs2;
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
assign opcode = instruction[6:0];
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

initial begin
	regs[0] <= 0; // Must always be zero
end

always @(posedge clk or posedge rst) begin
	if (rst)
		rd <= 0;
	else
		rd <= instruction[11:7];
end

always @(posedge clk or posedge rst) begin
	if (rst)
		a <= 32'dx;
	else case (opcode)
	`OP_LUI:
		a <= immu;
	`OP_JAL,
	`OP_AUIPC,
	`OP_JALR:
		a <= pc;
	`OP,
	`OP_IMM,
	`OP_LOAD,
	`OP_STORE:
		a <= regs[rs1];
	default:
		a <= 32'dx;
	endcase
end

always @(posedge clk or posedge rst) begin
	if (rst)
		b <= 32'dx;
	else case (opcode)
	`OP_LUI:
		b <= 0;
	`OP_AUIPC:
		b <= immu;
	`OP_JAL,
	`OP_JALR:
		b <= 4;
	`OP:
		b <= regs[rs2];
	`OP_IMM,
	`OP_LOAD:
		b <= immi;
	`OP_STORE:
		b <= imms;
	default:
		b <= 32'dx;
	endcase
end

always @(posedge clk or posedge rst) begin
	if (rst)
		exception <= 0;
	else case (opcode)
	`OP_LUI,
	`OP_AUIPC,
	`OP_JAL,
	`OP_JALR,
	`OP,
	`OP_IMM,
	`OP_LOAD,
	`OP_STORE:
		exception <= 0;
	default:
		b <= 1;
	endcase
end

always @(posedge clk or posedge rst) begin
	if (rst)
		funct3 <= 0;
	else
		funct3 <= instruction[14:12];
end

endmodule