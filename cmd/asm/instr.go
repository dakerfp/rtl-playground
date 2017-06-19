package main

import (
	"strconv"
)

func assembleu(opcode OpCode, args ...string) (uint32, error) {
	if len(args) != 2 {
		return 0, ErrWrongInstrunctionFormat
	}
	rd, ok := RegNames[args[0]]
	if !ok {
		return 0, ErrInvalidRegister
	}
	immu, err := strconv.ParseInt(args[1], 10, 12)
	if err != nil {
		return 0, ErrInvalidNumeral
	}
	return uinstruction(opcode, rd, uint32(immu))
}

func assembler(opcode OpCode, funct3 Funct3, funct7 Funct7, args ...string) (uint32, error) {
	if len(args) != 3 {
		return 0, ErrWrongInstrunctionFormat
	}
	rd, ok := RegNames[args[0]]
	if !ok {
		return 0, ErrInvalidRegister
	}
	rs1, ok := RegNames[args[1]]
	if !ok {
		return 0, ErrInvalidRegister
	}
	rs2, ok := RegNames[args[2]]
	if !ok {
		return 0, ErrInvalidRegister
	}
	return rinstruction(opcode, rd, Funct3Add, rs1, rs2, funct7)
}

func assembleb(opcode OpCode, funct3 Funct3, args ...string) (uint32, error) {
	if len(args) != 3 {
		return 0, ErrWrongInstrunctionFormat
	}
	rs1, ok := RegNames[args[0]]
	if !ok {
		return 0, ErrInvalidRegister
	}
	rs2, ok := RegNames[args[1]]
	if !ok {
		return 0, ErrInvalidRegister
	}
	immb, err := strconv.ParseInt(args[2], 10, 12)
	if err != nil {
		return 0, ErrInvalidNumeral
	}
	return binstruction(opcode, rs1, rs2, funct3, uint32(immb))
}

func assemblei(opcode OpCode, funct3 Funct3, args ...string) (uint32, error) {
	if len(args) != 3 {
		return 0, ErrWrongInstrunctionFormat
	}
	rd, ok := RegNames[args[0]]
	if !ok {
		return 0, ErrInvalidRegister
	}
	rs1, ok := RegNames[args[1]]
	if !ok {
		return 0, ErrInvalidRegister
	}
	immi, err := strconv.ParseInt(args[2], 10, 12)
	if err != nil {
		return 0, ErrInvalidNumeral
	}
	return iinstruction(opcode, rd, Funct3Add, rs1, uint32(immi))
}

func assemblej(opcode OpCode, args ...string) (uint32, error) {
	if len(args) != 2 {
		return 0, ErrWrongInstrunctionFormat
	}
	rd, ok := RegNames[args[0]]
	if !ok {
		return 0, ErrInvalidRegister
	}
	immj, err := strconv.ParseInt(args[1], 10, 12)
	if err != nil {
		return 0, ErrInvalidNumeral
	}
	return jinstruction(opcode, rd, uint32(immj))
}

func rinstruction(opcode OpCode, rd Reg, funct3 Funct3, rs1 Reg, rs2 Reg, funct7 Funct7) (uint32, error) {
	return concat(
		bitslice{uint32(funct7), 7},
		bitslice{uint32(rs2), 5},
		bitslice{uint32(rs1), 5},
		bitslice{uint32(funct3), 3},
		bitslice{uint32(rd), 5},
		bitslice{uint32(opcode), 7},
	)
}

func iinstruction(opcode OpCode, rd Reg, funct3 Funct3, rs1 Reg, immi uint32) (uint32, error) {
	return concat(
		bitslice{immi, 12},
		bitslice{uint32(rs1), 5},
		bitslice{uint32(funct3), 3},
		bitslice{uint32(rd), 5},
		bitslice{uint32(opcode), 7},
	)
}

func sinstruction(opcode OpCode, rs1 Reg, rs2 Reg, funct3 Funct3, imms uint32) (uint32, error) {
	return concat(
		getbits(imms, 5, 12), // TODO: check overflow
		bitslice{uint32(rs2), 5},
		bitslice{uint32(rs1), 5},
		bitslice{uint32(funct3), 3},
		getbits(imms, 0, 5),
		bitslice{uint32(opcode), 7},
	)
}

func binstruction(opcode OpCode, rs1 Reg, rs2 Reg, funct3 Funct3, immb uint32) (uint32, error) {
	// TODO: check overflow in immb
	return concat(
		getbits(immb, 12, 13),
		getbits(immb, 5, 11),
		bitslice{uint32(rs2), 5},
		bitslice{uint32(rs1), 5},
		bitslice{uint32(funct3), 3},
		getbits(immb, 1, 5),
		getbits(immb, 11, 12),
		bitslice{uint32(opcode), 7},
	)
}

func uinstruction(opcode OpCode, rd Reg, uimm uint32) (uint32, error) {
	return concat(
		getbits(uimm, 12, 20),
		bitslice{uint32(rd), 5},
		bitslice{uint32(opcode), 7},
	)
}

func jinstruction(opcode OpCode, rd Reg, jimm uint32) (uint32, error) {
	return concat(
		getbits(jimm, 20, 21),
		getbits(jimm, 1, 11),
		getbits(jimm, 11, 12),
		getbits(jimm, 12, 20),
		bitslice{uint32(rd), 5},
		bitslice{uint32(opcode), 7},
	)
}
