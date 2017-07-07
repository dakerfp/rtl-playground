
`include "riscv/isa.sv"

module riscv_hart

	#(parameter XLEN = 32,
	  parameter REGN = 32)

	(input logic rst, clk,

	 input instruction_t instruction,
	 output logic [XLEN-1:0] pc,

	 input logic [XLEN-1:0] mem_read,
	 output logic [XLEN-1:0] mem_addr,
	 output logic [XLEN-1:0] mem_data,
	 output logic mem_write);

	localparam SHAMTN = $clog2(XLEN);
	localparam REGA = $clog2(REGN);
	
	// IF - Instruction Fetch

	always @(posedge clk or posedge rst) // always_ff
		if (rst)
			pc <= 0;
		else if (clk)
			pc <= pc + 4; // TODO: support branch and jump

	// ID - Instruction Decode

	// XXX: should be internal only, exporting only for testing
	logic [XLEN-1:0] regs [0:REGN-1];
	logic [XLEN-1:0] immediate;

	instruction_r_t id_r;
	instruction_i_t id_i;
	instruction_u_t id_u;
	instruction_j_t id_j;
	instruction_s_t id_s;
	instruction_b_t id_b;
	instruction_format_t id_format;
	assign id_format = instruction.f;
	assign id_r = id_format.r;
	assign id_i = id_format.i;
	assign id_u = id_format.u;
	assign id_s = id_format.s;
	assign id_b = id_format.b;

	always @* // always_comb
		case (instruction.opcode)
		OP_LUI, OP_AUIPC:
			immediate = $signed(id_u.immu); // sign extend
		OP_IMM, OP_JALR, OP_LOAD, OP_MISC_MEM:
			immediate = $signed(id_i.immi); // sign extend
		OP_JAL:
			immediate = $signed({id_j.immj3, id_j.immj2,
								 id_j.immj1, id_j.immj0});
		OP_STORE:
			immediate = $signed({id_s.imms1, id_s.imms0});
		OP_BRANCH:
			immediate = $signed({id_b.imms3, id_b.immb2,
								 id_b.immb1, id_b.immb0, 1'b0}); // << 1
		default: // OP
			immediate = 0;
		endcase	

	always @(posedge clk or posedge rst) // always_ff
		if (rst) begin
			EX.left <= 0;
			EX.right <= 0;
			EX.funct3 <= FUNCT3_ADD;
			EX.rd <= 0;
			EX.access <= MEM_IDLE;
			EX.bypass <= 0;
		end
		else case (instruction.opcode)
		OP_LUI: begin
			EX.left <= immediate;
			EX.right <= 0;
			EX.funct3 <= FUNCT3_ADD;
			EX.rd <= id_u.rd;
			EX.access <= MEM_IDLE;
			EX.bypass <= 0;
		end
		OP_JAL: begin
			EX.left <= pc;
			EX.right <= 4;
			EX.funct3 <= FUNCT3_ADD;
			EX.rd <= id_j.rd;
			EX.access <= MEM_IDLE;
			EX.bypass <= 0;
		end
		OP_AUIPC: begin
			EX.left <= pc;
			EX.right <= immediate;
			EX.funct3 <= FUNCT3_ADD;
			EX.rd <= id_u.rd;
			EX.access <= MEM_IDLE;
			EX.bypass <= 0;
		end
		OP_JALR: begin
			EX.left <= pc;
			EX.right <= 4;
			EX.funct3 <= id_i.funct3;
			EX.rd <= id_i.rd;
			EX.access <= MEM_IDLE;
			EX.bypass <= 0;
		end
		OP: begin
			EX.left <= regs[id_r.rs1];
			EX.right <= regs[id_r.rs2];
			EX.funct3 <= id_r.funct3;
			EX.rd <= id_r.rd;
			EX.access <= MEM_IDLE;
			EX.bypass <= 0;
		end
		OP_IMM: begin
			EX.left <= regs[id_i.rs1];
			EX.right <= immediate;
			EX.funct3 <= id_i.funct3;
			EX.rd <= id_i.rd;
			EX.access <= MEM_IDLE;
			EX.bypass <= 0;
		end
		OP_BRANCH: begin
			// OP_BRANCH does not propagate through the pipeline
			EX.left <= 0;
			EX.right <= 0;
			EX.funct3 <= FUNCT3_ADD;
			EX.rd <= 0;
			EX.access <= MEM_IDLE;
			EX.bypass <= 0;
		end
		OP_LOAD: begin
			EX.left <= regs[id_i.rs1];
			EX.right <= immediate;
			EX.funct3 <= id_i.funct3;
			EX.rd <= id_i.rd;
			EX.access <= MEM_READ;
			EX.bypass <= 0;
		end
		OP_STORE: begin
			EX.left <= regs[id_s.rs1];
			EX.right <= immediate;
			EX.funct3 <= FUNCT3_ADD;
			EX.rd <= 0;
			EX.access <= MEM_WRITE;
			EX.bypass <= regs[id_s.rs2];
			// TODO: pass word id_s.funct3;
		end
		OP_MISC_MEM: begin
			EX.funct3 <= id_i.funct3;
			EX.rd <= id_i.rd;
			EX.access <= MEM_IDLE;
			$display("Not implemented"); // XXX
		end
		OP_SYSTEM: begin
			EX.funct3 <= id_i.funct3;
			EX.rd <= id_i.rd;
			EX.access <= MEM_IDLE;
			$display("Not implemented"); // XXX
		end
		default: begin
			EX.invert <= 0;
			EX.left <= 0;
			EX.right <= 0;
			EX.funct3 <= FUNCT3_ADD;
			EX.rd <= 0;
			EX.access <= MEM_IDLE;
		end
		endcase


	// EX - Execution

	struct packed {
		logic invert;
		logic [XLEN-1:0] left;
		logic [XLEN-1:0] right;
		logic [XLEN-1:0] bypass;
		funct3_t funct3;
		reg_t rd;
		mem_access_t access;
	} EX;

	logic [SHAMTN-1:0] ex_shamt;
	assign ex_shamt = EX.right[SHAMTN-1:0];

	// XXX: currently there is no option to correctly bypass left value
	always @(posedge clk or posedge rst)  // always_ff
		if (rst)
			MA.result <= 0;
		else case (EX.funct3) // unique
		FUNCT3_ADD:
			MA.result <= $signed(EX.left) + $signed(EX.right);
	 	FUNCT3_SLL:
	 		MA.result <= EX.left << ex_shamt;
		FUNCT3_SLT:
			MA.result <= $signed(EX.left) < $signed(EX.right);
		FUNCT3_SLTU:
			MA.result <= EX.left < EX.right;
		FUNCT3_XOR:
			MA.result <= EX.left ^ EX.right;
		FUNCT3_SRL_SRA:
			if (EX.invert)
				MA.result <= $signed(EX.left) >>> ex_shamt;
			else
				MA.result <= EX.left >> ex_shamt;
		FUNCT3_OR:
			MA.result <= EX.left | EX.right;
		FUNCT3_AND:
			MA.result <= EX.left & EX.right;
		default:
			MA.result <= 0;
		endcase

	always @(posedge clk or posedge rst)  // always_ff
		if (rst)
			MA.bypass <= 0;
		else
			MA.bypass <= EX.bypass;

	always @(posedge clk or posedge rst)  // always_ff
		if (rst)
			MA.rd <= 0;
		else
			MA.rd <= EX.rd;

	always @(posedge clk or posedge rst)  // always_ff
		if (rst)
			MA.access <= MEM_IDLE;
		else
			MA.access <= EX.access;

	// MA - Memory Access
	struct packed {
		logic [XLEN-1:0] result;
		logic [XLEN-1:0] bypass;
		mem_access_t access;
		reg_t rd;
	} MA;

	always @(posedge clk or posedge rst)  // always_ff
		if (rst) begin
			mem_addr <= 0;
			mem_data <= 0;
			mem_write <= 0;
			WB.result <= 0;
			WB.rd <= 0;
			WB.mem_read <= 0;
		end
		else case (MA.access) // XXX: case unique
		MEM_IDLE: begin
			mem_addr <= 0;
			mem_data <= 0;
			mem_write <= 0;
			WB.result <= MA.result;
			WB.rd <= MA.rd;
			WB.mem_read <= 0;
		end
		MEM_READ: begin
			mem_addr <= MA.result;
			mem_data <= 0;
			mem_write <= 0;
			WB.result <= 0;
			WB.rd <= MA.rd;
			WB.mem_read <= 1;
		end
		MEM_WRITE: begin
			mem_addr <= MA.result;
			mem_data <= MA.bypass;
			mem_write <= 1;
			WB.result <= 0;
			WB.rd <= 0;
			WB.mem_read <= 0;
		end
		endcase

	// WB - Write Back
	struct packed {
		logic [XLEN-1:0] result;
		logic mem_read;
		reg_t rd;
	} WB;

	logic [XLEN-1:0] wb_result;
	assign wb_result = (WB.mem_read) ? mem_read : WB.result;

	always @(posedge clk or posedge rst)  // always_ff
		if (rst) begin
			regs[0] <= 0;
		end
		else if (WB.rd != 0) begin
			regs[WB.rd] <= wb_result;
		end

endmodule : riscv_hart
