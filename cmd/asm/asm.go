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
	ErrInvalidOffset           = errors.New("invalid offset value")
	ErrSymbolRedefined         = errors.New("symbol redefined")
)

type ParseError struct {
	Err     error
	lineno  int
	message string
}

func (pe *ParseError) Error() string {
	return fmt.Sprintf("%s at line %d: %s", pe.Err.Error(), pe.lineno, pe.message)
}

func IsParseError(err error) bool {
	return err.(*ParseError) != nil
}

type Section []Instruction

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
	lineno := 1
	instrno := 0
	obj := &Object{
		make(map[string]Symbol),
		make(map[string]Section),
	}
	currsection := ".text" // default section is .text
	for {
		line, err := sr.ReadString('\n')
		if err == io.EOF {
			break
		} else if err != nil {
			return obj, err
		}

		lineno++
		tokens := tokenize(line)

		// check if it is a section
		if len(tokens) == 2 && tokens[0] == ".section" {
			currsection = tokens[1]
			continue // ignore the rest of the line
		}

		// goto next line if line is empty
		if len(tokens) == 0 {
			continue
		}

		// try parsing label
		if symbol, ok := parseSymbol(tokens[0]); ok {
			if _, ok := obj.Symbols[symbol]; ok {
				return obj, &ParseError{ErrSymbolRedefined, lineno, line}
			}
			obj.Symbols[symbol] = Symbol{
				Name:        symbol,
				SectionName: currsection,
				Lineno:      lineno,
				Instrno:     instrno,
			}
			tokens = tokens[1:] // removing symbol from list of tokens
		}

		// read instruction
		if len(tokens) == 0 || tokens[0] == "" {
			continue
		}
		cmd, err := parseCommand(tokens) // does not support large pseudo instructions
		if err != nil {
			return obj, &ParseError{err, lineno, line}
		}
		obj.Sections[currsection] = append(obj.Sections[currsection], cmd)
		instrno++
	}

	return obj, nil
}

func Assemble(ie InstructionEncoder, o *Object) error {
	for _, section := range o.Sections {
		for _, instr := range section {
			ui, err := instr.Link()
			if err != nil {
				return err
			}
			if err := ie.EncodeInstruction(ui); err != nil {
				return err
			}
		}
	}
	return nil
}

func tokenize(line string) []string {
	line = line[0:strings.IndexAny(line, "#\n")] // remove comments #
	line = strings.TrimSpace(line)               // cleanup spaces
	line = strings.Replace(line, ",", "", -1)    // XXX: ignoring "," order
	return strings.Split(line, " ")              // tokenize
}

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
		return parseInstructionI(OpLoad, Funct3LoadB, tokens[1:]...)
	case "lbu":
		return parseInstructionI(OpLoad, Funct3LoadBU, tokens[1:]...)
	case "lh":
		return parseInstructionI(OpLoad, Funct3LoadH, tokens[1:]...)
	case "lhu":
		return parseInstructionI(OpLoad, Funct3LoadHU, tokens[1:]...)
	case "lw":
		return parseInstructionI(OpLoad, Funct3LoadW, tokens[1:]...)
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
