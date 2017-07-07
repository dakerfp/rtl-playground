package main

import (
	"regexp"
	"strconv"
)

func parseCommand(tokens []string) (Instruction, error) {
	switch tokens[0] {
	// Inconditional branches
	case "jal":
		return parseInstructionJ(OpJal, tokens[1:]...)
	case "jalr":
		return parseInstructionI(OpJalr, Funct3Add, tokens[1:]...)
	// Conditional branches
	case "beq":
		return parseInstructionB(OpBranch, Funct3Beq, tokens[1:]...)
	case "bne":
		return parseInstructionB(OpBranch, Funct3Bne, tokens[1:]...)
	case "blt":
		return parseInstructionB(OpBranch, Funct3Blt, tokens[1:]...)
	case "bge":
		return parseInstructionB(OpBranch, Funct3Bge, tokens[1:]...)
	case "bltu":
		return parseInstructionB(OpBranch, Funct3Bltu, tokens[1:]...)
	case "bgeu":
		return parseInstructionB(OpBranch, Funct3Bgeu, tokens[1:]...)
	// Register operations
	case "add":
		return parseInstructionR(Op, Funct3Add, Funct7Add, tokens[1:]...)
	case "slt":
		return parseInstructionR(Op, Funct3Slt, Funct7None, tokens[1:]...)
	case "sltu":
		return parseInstructionR(Op, Funct3Sltu, Funct7None, tokens[1:]...)
	case "and":
		return parseInstructionR(Op, Funct3And, Funct7None, tokens[1:]...)
	case "or":
		return parseInstructionR(Op, Funct3Or, Funct7None, tokens[1:]...)
	case "xor":
		return parseInstructionR(Op, Funct3Xor, Funct7None, tokens[1:]...)
	// Register shift operation
	case "sll":
		return parseInstructionR(Op, Funct3Sll, Funct7Sll, tokens[1:]...)
	case "srl":
		return parseInstructionR(Op, Funct3Srl, Funct7Srl, tokens[1:]...)
	case "sra":
		return parseInstructionR(Op, Funct3Sra, Funct7Sra, tokens[1:]...)
	// Register sub operation
	case "sub":
		return parseInstructionR(Op, Funct3Add, Funct7Sub, tokens[1:]...)
	// Immediate operations
	case "addi":
		return parseInstructionI(OpImm, Funct3Add, tokens[1:]...)
	case "slti":
		return parseInstructionI(OpImm, Funct3Slt, tokens[1:]...)
	case "sltiu":
		return parseInstructionI(OpImm, Funct3Sltu, tokens[1:]...)
	case "xori":
		return parseInstructionI(OpImm, Funct3Xor, tokens[1:]...)
	case "ori":
		return parseInstructionI(OpImm, Funct3Or, tokens[1:]...)
	case "andi":
		return parseInstructionI(OpImm, Funct3Or, tokens[1:]...)
	case "lui":
		return parseInstructionU(OpLui, tokens[1:]...)
	case "auipc":
		return parseInstructionU(OpAuipc, tokens[1:]...)
	// Immediate shifts
	case "srli":
		return parseInstructionIS(OpImm, Funct3Srl, Funct7Srl, tokens[1:]...)
	case "srai":
		return parseInstructionIS(OpImm, Funct3Sra, Funct7Sra, tokens[1:]...)
	case "slli":
		return parseInstructionIS(OpImm, Funct3Sll, Funct7Sll, tokens[1:]...)
	// Load
	case "lb":
		return parseInstructionIOffset(OpLoad, Funct3LoadB, tokens[1:]...)
	case "lbu":
		return parseInstructionIOffset(OpLoad, Funct3LoadBU, tokens[1:]...)
	case "lh":
		return parseInstructionIOffset(OpLoad, Funct3LoadH, tokens[1:]...)
	case "lhu":
		return parseInstructionIOffset(OpLoad, Funct3LoadHU, tokens[1:]...)
	case "lw":
		return parseInstructionIOffset(OpLoad, Funct3LoadW, tokens[1:]...)
	// Store
	case "sb":
		return parseInstructionS(OpStore, Funct3StoreB, tokens[1:]...)
	case "sh":
		return parseInstructionS(OpStore, Funct3StoreH, tokens[1:]...)
	case "sw":
		return parseInstructionS(OpStore, Funct3StoreW, tokens[1:]...)
	// Pseudo instructions
	case "nop":
		if len(tokens) != 1 {
			return nil, ErrWrongInstrunctionFormat
		}
		return parseInstructionI(OpImm, Funct3Add, "zero", "zero", "0")
	case "mv":
		if len(tokens) != 3 {
			return nil, ErrWrongInstrunctionFormat
		}
		return parseInstructionI(OpImm, Funct3Add, tokens[1], tokens[2], "0")
	case "li":
		if len(tokens) != 3 {
			return nil, ErrWrongInstrunctionFormat
		}
		return parseInstructionI(OpImm, Funct3Add, tokens[1], "zero", tokens[2])
	case "j":
		if len(tokens) != 2 {
			return nil, ErrWrongInstrunctionFormat
		}
		return parseInstructionJ(OpJal, "zero", tokens[1])
	case "fence", "fence.i", "ecall", "ebreak", "csrrw", "csrrs", "csrrc",
		"csrrwi", "csrrsi", "csrrci":
		return nil, ErrNotImplemented
	default:
		return nil, ErrUnknownInstruction
	}
}

func parseSymbol(token string) (string, bool) {
	if len(token) <= 1 || token[len(token)-1] != ':' {
		return "", false
	}
	return token[:len(token)-1], true
}

func parseRegisterOffset(s string) (reg Reg, offset int, err error) {
	r := regexp.MustCompile("^(-?\\d+)\\(([a-z0-9]+)\\)$")
	matches := r.FindStringSubmatch(s)

	if len(matches) != 3 {
		err = ErrInvalidOffset
		return
	}

	// get offset
	offset, err = strconv.Atoi(matches[1])
	if err != nil {
		err = ErrInvalidNumeral
		return
	}

	// get register
	var ok bool
	reg, ok = RegNames[matches[2]]
	if !ok {
		err = ErrInvalidRegister
	}
	return
}

func parseInstructionU(opcode OpCode, args ...string) (*InstructionU, error) {
	if len(args) != 2 {
		return nil, ErrWrongInstrunctionFormat
	}
	rd, ok := RegNames[args[0]]
	if !ok {
		return nil, ErrInvalidRegister
	}
	immu, err := strconv.ParseInt(args[1], 10, 12)
	if err != nil {
		return nil, ErrInvalidNumeral
	}
	return &InstructionU{opcode, rd, Uint32(immu)}, nil
}

func parseInstructionR(opcode OpCode, funct3 Funct3, funct7 Funct7, args ...string) (*InstructionR, error) {
	if len(args) != 3 {
		return nil, ErrWrongInstrunctionFormat
	}
	rd, ok := RegNames[args[0]]
	if !ok {
		return nil, ErrInvalidRegister
	}
	rs1, ok := RegNames[args[1]]
	if !ok {
		return nil, ErrInvalidRegister
	}
	rs2, ok := RegNames[args[2]]
	if !ok {
		return nil, ErrInvalidRegister
	}
	return &InstructionR{opcode, rd, rs1, rs2, funct3, funct7}, nil
}

func parseInstructionB(opcode OpCode, funct3 Funct3, args ...string) (*InstructionB, error) {
	if len(args) != 3 {
		return nil, ErrWrongInstrunctionFormat
	}
	rs1, ok := RegNames[args[0]]
	if !ok {
		return nil, ErrInvalidRegister
	}
	rs2, ok := RegNames[args[1]]
	if !ok {
		return nil, ErrInvalidRegister
	}
	immb, err := strconv.ParseInt(args[2], 10, 12)
	if err != nil {
		return nil, ErrInvalidNumeral
	}
	return &InstructionB{opcode, funct3, rs1, rs2, Uint32(immb)}, nil
}

func parseInstructionI(opcode OpCode, funct3 Funct3, args ...string) (*InstructionI, error) {
	if len(args) != 3 {
		return nil, ErrWrongInstrunctionFormat
	}
	rd, ok := RegNames[args[0]]
	if !ok {
		return nil, ErrInvalidRegister
	}
	rs1, ok := RegNames[args[1]]
	if !ok {
		return nil, ErrInvalidRegister
	}
	immi, err := strconv.ParseInt(args[2], 10, 12)
	if err != nil {
		return nil, ErrInvalidNumeral
	}
	return &InstructionI{opcode, rd, rs1, Funct3Add, Uint32(immi)}, nil
}

func parseInstructionIOffset(opcode OpCode, funct3 Funct3, args ...string) (*InstructionI, error) {
	if len(args) != 2 {
		return nil, ErrWrongInstrunctionFormat
	}
	rd, ok := RegNames[args[0]]
	if !ok {
		return nil, ErrInvalidRegister
	}
	rs1, immi, err := parseRegisterOffset(args[1])
	if err != nil {
		return nil, err
	}
	return &InstructionI{opcode, rd, rs1, Funct3Add, Uint32(immi)}, nil
}

func parseInstructionIS(opcode OpCode, funct3 Funct3, funct7 Funct7, args ...string) (*InstructionIS, error) {
	if len(args) != 3 {
		return nil, ErrWrongInstrunctionFormat
	}
	rd, ok := RegNames[args[0]]
	if !ok {
		return nil, ErrInvalidRegister
	}
	rs1, ok := RegNames[args[1]]
	if !ok {
		return nil, ErrInvalidRegister
	}
	shamt, err := strconv.ParseInt(args[2], 10, 12)
	if err != nil {
		return nil, ErrInvalidNumeral
	}
	return &InstructionIS{opcode, rd, rs1, Uint32(shamt), funct3, funct7}, nil
}

func parseInstructionS(opcode OpCode, funct3 Funct3, args ...string) (*InstructionS, error) {
	if len(args) != 2 {
		return nil, ErrWrongInstrunctionFormat
	}
	rs1, ok := RegNames[args[0]]
	if !ok {
		return nil, ErrInvalidRegister
	}
	rs2, imms, err := parseRegisterOffset(args[1])
	if err != nil {
		return nil, err
	}
	return &InstructionS{opcode, Funct3Add, rs1, rs2, Uint32(imms)}, nil
}

func parseInstructionJ(opcode OpCode, args ...string) (*InstructionJ, error) {
	if len(args) != 2 {
		return nil, ErrWrongInstrunctionFormat
	}
	rd, ok := RegNames[args[0]]
	if !ok {
		return nil, ErrInvalidRegister
	}
	immj, err := strconv.ParseInt(args[1], 10, 12)
	if err != nil {
		return nil, ErrInvalidNumeral
	}
	return &InstructionJ{opcode, rd, Uint32(immj)}, nil
}
