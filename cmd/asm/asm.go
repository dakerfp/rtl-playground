package main

import (
	"bufio"
	"errors"
	"fmt"
	"io"
	"strings"
)

var (
	ErrNotImplemented          = errors.New("not implemented yet")
	ErrWrongInstrunctionFormat = errors.New("wrong instruction format")
	ErrValueDontFitImmediate   = errors.New("immediate value does not fit instruction")
	ErrUnknownInstruction      = errors.New("unknown instruction")
	ErrInvalidRegister         = errors.New("invalid register")
	ErrInvalidNumeral          = errors.New("invalid number literal")
)

type Section []uint32

type Symbol struct {
	Name        string
	SectionName string
	Lineno      int
	Instrno     int
}

type Object struct {
	Symbols  map[string]Symbol
	Sections map[string]Section
}

func Parse(r io.Reader) (*Object, error) {
	sr := bufio.NewReader(r)
	lineno := 0
	instrno := 0
	obj := &Object{
		make(map[string]Symbol),
		make(map[string]Section),
	}
	currsection := ".text"
	for {
		line, err := sr.ReadString('\n')
		if err == io.EOF {
			break
		} else if err != nil {
			return nil, err
		}
		lineno++
		line = line[0:strings.IndexAny(line, "#\n")]
		line = strings.TrimSpace(line)
		line = strings.Replace(line, ",", "", -1) // XXX
		tokens := strings.Split(line, " ")

		// check if it is a section
		if len(tokens) == 2 && tokens[0] == ".section" {
			currsection = tokens[1]
			continue
		}

		// read symbol, if there is any
		if len(tokens) == 0 {
			continue
		}
		if symbol := tokens[0]; issymbol(symbol) {
			tokens = tokens[1:]
			if _, ok := obj.Symbols[symbol]; ok {
				return nil, fmt.Errorf("symbol %q redefined at line %d", symbol, lineno)
			}
			obj.Symbols[symbol] = Symbol{
				Name:        symbol,
				SectionName: currsection,
				Lineno:      lineno,
				Instrno:     instrno,
			}
		}

		// read instruction
		if len(tokens) == 0 || tokens[0] == "" {
			continue
		}
		cmd, err := parseCommand(tokens) // does not support large pseudo instructions
		if err != nil {
			return nil, fmt.Errorf("error on line %d: %q", lineno, err)
		}
		obj.Sections[currsection] = append(obj.Sections[currsection], cmd)
		instrno++
	}

	return obj, nil
}

func Assemble(ie InstructionEncoder, o *Object) error {
	for _, section := range o.Sections {
		for _, instr := range section {
			if err := ie.EncodeInstruction(instr); err != nil {
				return err
			}
		}
	}
	return nil
}

func parseCommand(tokens []string) (uint32, error) {
	switch tokens[0] {
	// Inconditional branches
	case "jal":
		return assemblej(OpJal, tokens[1:]...)
	case "jalr":
		return assemblei(OpJalr, Funct3Add, tokens[1:]...)
	// Conditional branches
	case "beq":
		return assembleb(OpBranch, Funct3Beq, tokens[1:]...)
	case "bne":
		return assembleb(OpBranch, Funct3Bne, tokens[1:]...)
	case "blt":
		return assembleb(OpBranch, Funct3Blt, tokens[1:]...)
	case "bge":
		return assembleb(OpBranch, Funct3Bge, tokens[1:]...)
	case "bltu":
		return assembleb(OpBranch, Funct3Bltu, tokens[1:]...)
	case "bgeu":
		return assembleb(OpBranch, Funct3Bgeu, tokens[1:]...)
	// Register operations
	case "add":
		return assembler(Op, Funct3Add, Funct7Add, tokens[1:]...)
	case "slt":
		return assembler(Op, Funct3Slt, Funct7None, tokens[1:]...)
	case "sltu":
		return assembler(Op, Funct3Sltu, Funct7None, tokens[1:]...)
	case "and":
		return assembler(Op, Funct3And, Funct7None, tokens[1:]...)
	case "or":
		return assembler(Op, Funct3Or, Funct7None, tokens[1:]...)
	case "xor":
		return assembler(Op, Funct3Xor, Funct7None, tokens[1:]...)
	// Register shift operation
	case "sll":
		return assembler(Op, Funct3Sll, Funct7Sll, tokens[1:]...)
	case "srl":
		return assembler(Op, Funct3Srl, Funct7Srl, tokens[1:]...)
	case "sra":
		return assembler(Op, Funct3Sra, Funct7Sra, tokens[1:]...)
	// Register sub operation
	case "sub":
		return assembler(Op, Funct3Add, Funct7Sub, tokens[1:]...)
	// Immediate operations
	case "addi":
		return assemblei(OpImm, Funct3Add, tokens[1:]...)
	case "slti":
		return assemblei(OpImm, Funct3Slt, tokens[1:]...)
	case "sltiu":
		return assemblei(OpImm, Funct3Sltu, tokens[1:]...)
	case "xori":
		return assemblei(OpImm, Funct3Xor, tokens[1:]...)
	case "ori":
		return assemblei(OpImm, Funct3Or, tokens[1:]...)
	case "andi":
		return assemblei(OpImm, Funct3Or, tokens[1:]...)
	case "lui":
		return assembleu(OpLui, tokens[1:]...)
	case "auipc":
		return assembleu(OpAuipc, tokens[1:]...)
	// Immediate shifts
	case "srli":
		return assembleis(OpImm, Funct3Srl, Funct7Srl, tokens[1:]...)
	case "srai":
		return assembleis(OpImm, Funct3Sra, Funct7Sra, tokens[1:]...)
	case "slli":
		return assembleis(OpImm, Funct3Sll, Funct7Sll, tokens[1:]...)
	// Pseudo instructions
	case "nop":
		if len(tokens) != 1 {
			return 0, ErrWrongInstrunctionFormat
		}
		return assemblei(OpImm, Funct3Add, "zero", "zero", "0")
	case "mv":
		if len(tokens) != 3 {
			return 0, ErrWrongInstrunctionFormat
		}
		return assemblei(OpImm, Funct3Add, tokens[1], tokens[2], "0")
	case "li":
		if len(tokens) != 3 {
			return 0, ErrWrongInstrunctionFormat
		}
		return assemblei(OpImm, Funct3Add, tokens[1], "zero", tokens[2])
	case "j":
		if len(tokens) != 2 {
			return 0, ErrWrongInstrunctionFormat
		}
		return assemblej(OpJal, "zero", tokens[1])
	default:
		return 0, ErrUnknownInstruction
	}
}

func issymbol(token string) bool {
	return len(token) > 1 && token[len(token)-1] == ':'
}
