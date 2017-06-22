package main

import (
	"strconv"
)

type Immediate interface {
	Eval() (uint32, error)
}

type Uint32 uint32

func (u Uint32) Eval() (uint32, error) {
	return uint32(u), nil
}

type Instruction interface {
	Link() (uint32, error) // TODO: add params
}

type InstructionU struct {
	OpCode
	Rd Reg
	Immediate
}

func (i InstructionU) Link() (uint32, error) {
	immu, err := i.Immediate.Eval()
	if err != nil {
		return 0, err
	}
	return concat(
		getbits(immu, 12, 20),
		bitslice{uint32(i.Rd), 5},
		bitslice{uint32(i.OpCode), 7},
	)
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

type InstructionR struct {
	OpCode
	Rd, Rs1, Rs2 Reg
	Funct3
	Funct7
}

func (i InstructionR) Link() (uint32, error) {
	return concat(
		bitslice{uint32(i.Funct7), 7},
		bitslice{uint32(i.Rs2), 5},
		bitslice{uint32(i.Rs1), 5},
		bitslice{uint32(i.Funct3), 3},
		bitslice{uint32(i.Rd), 5},
		bitslice{uint32(i.OpCode), 7},
	)
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

type InstructionB struct {
	OpCode
	Funct3
	Rs1, Rs2 Reg
	Immediate
}

func (i InstructionB) Link() (uint32, error) {
	immb, err := i.Immediate.Eval()
	if err != nil {
		return 0, err
	}
	return concat(
		getbits(immb, 12, 13),
		getbits(immb, 5, 11),
		bitslice{uint32(i.Rs2), 5},
		bitslice{uint32(i.Rs1), 5},
		bitslice{uint32(i.Funct3), 3},
		getbits(immb, 1, 5),
		getbits(immb, 11, 12),
		bitslice{uint32(i.OpCode), 7},
	)
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

type InstructionI struct {
	OpCode
	Rd, Rs1 Reg
	Funct3
	Immediate
}

func (i InstructionI) Link() (uint32, error) {
	immi, err := i.Immediate.Eval()
	if err != nil {
		return 0, err
	}
	return concat(
		bitslice{immi, 12},
		bitslice{uint32(i.Rs1), 5},
		bitslice{uint32(i.Funct3), 3},
		bitslice{uint32(i.Rd), 5},
		bitslice{uint32(i.OpCode), 7},
	)
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

type InstructionIS struct {
	OpCode
	Rd, Rs1 Reg
	Shamt   Immediate
	Funct3
	Funct7
}

func (i InstructionIS) Link() (uint32, error) {
	shamt, err := i.Shamt.Eval()
	if err != nil {
		return 0, err
	}
	return concat(
		bitslice{uint32(i.Funct7), 7},
		bitslice{shamt, 5},
		bitslice{uint32(i.Rs1), 5},
		bitslice{uint32(i.Funct3), 3},
		bitslice{uint32(i.Rd), 5},
		bitslice{uint32(i.OpCode), 7},
	)
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

type InstructionS struct {
	OpCode
	Funct3
	Rs1, Rs2 Reg
	Immediate
}

func parseInstructionS(opcode OpCode, funct3 Funct3, args ...string) (*InstructionS, error) {
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
	imms, err := strconv.ParseInt(args[2], 10, 12)
	if err != nil {
		return nil, ErrInvalidNumeral
	}
	return &InstructionS{opcode, Funct3Add, rs1, rs2, Uint32(imms)}, nil
}

func (i InstructionS) Link() (uint32, error) {
	imms, err := i.Immediate.Eval()
	if err != nil {
		return 0, err
	}
	return concat(
		getbits(imms, 5, 12), // TODO: check overflow
		bitslice{uint32(i.Rs2), 5},
		bitslice{uint32(i.Rs1), 5},
		bitslice{uint32(i.Funct3), 3},
		getbits(imms, 0, 5),
		bitslice{uint32(i.OpCode), 7},
	)
}

type InstructionJ struct {
	OpCode
	Rd Reg
	Immediate
}

func (i InstructionJ) Link() (uint32, error) {
	immj, err := i.Immediate.Eval()
	if err != nil {
		return 0, err
	}
	return concat(
		getbits(immj, 20, 21),
		getbits(immj, 1, 11),
		getbits(immj, 11, 12),
		getbits(immj, 12, 20),
		bitslice{uint32(i.Rd), 5},
		bitslice{uint32(i.OpCode), 7},
	)
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
