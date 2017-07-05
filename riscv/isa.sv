
`ifndef RISCV_ISA_SV
`define RISCV_ISA_SV

`define always_ff always
`define always_comb always @*

// RV32I Base Instruction Set

typedef enum logic [6:0] {
	OP_AUIPC    = 7'b0010111,
	OP_JAL      = 7'b1101111,
	OP_JALR     = 7'b1100111,
	OP_BRANCH   = 7'b1100011,
	OP_LOAD     = 7'b0000011,
	OP_STORE    = 7'b0100011,
	OP_IMM      = 7'b0010011,
	OP          = 7'b0110011,
	OP_MISC_MEM = 7'b0001111,
	OP_SYSTEM   = 7'b1110011,
	OP_LUI      = 7'b0110111
} opcode_t;

typedef enum logic [2:0] {
	FUNCT3_ADD     = 3'b000,
	FUNCT3_SLL     = 3'b001,
	FUNCT3_SLT     = 3'b010,
	FUNCT3_SLTU    = 3'b011,
	FUNCT3_XOR     = 3'b100,
	FUNCT3_SRL_SRA = 3'b101,
	FUNCT3_OR      = 3'b110,
	FUNCT3_AND     = 3'b111
} funct3_t;

typedef enum logic [2:0] {
	FUNCT3_BEQ  = 3'b000,
	FUNCT3_BNEQ = 3'b001,
	FUNCT3_BLT  = 3'b010,
	FUNCT3_BLTU = 3'b011,
	FUNCT3_BGE  = 3'b100,
	FUNCT3_BGEU = 3'b101
} funct3_branch_t;

typedef logic [4:0] reg_t;

typedef logic [6:0] funct7_t;

typedef struct packed {
	funct7_t funct7;
	reg_t rs2;
	reg_t rs1;
	funct3_t funct3;
	reg_t rd;
} instruction_r_t;

typedef struct packed {
	logic [11:0] immi;
	reg_t rs1;
	funct3_t funct3;
	reg_t rd;
} instruction_i_t;

typedef struct packed {
	logic [11:5] imms1;
	reg_t rs2;
	reg_t rs1;
	funct3_t funct3;
	logic [4:0] imms0;
} instruction_s_t;

typedef struct packed {
	logic immb3; // [12]
	logic [5:0] immb1; // [10:5]
	reg_t rs2;
	reg_t rs1;
	funct3_branch_t funct3;
	logic [3:0] immb0; // [4:1]
	logic immb2; // [11]
} instruction_b_t;	

typedef struct packed {
	logic [31:12] immu;
	reg_t rd;
} instruction_u_t;

typedef struct packed {
	logic immj3; // [20]
	logic [9:0] immj0; // [10:1]
	logic immj1; // [11]
	logic [7:0] immj2; // [19:12] 
	reg_t rd;
} instruction_j_t;

typedef union packed {
	instruction_r_t r;
	instruction_i_t i;
	instruction_s_t s;
	instruction_b_t b;
	instruction_u_t u;
	instruction_j_t j;
} instruction_format_t;

typedef struct packed {
	instruction_format_t f;
	opcode_t opcode;
} instruction_t;

`endif // RISCV_ISA_SV
