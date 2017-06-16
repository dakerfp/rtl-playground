package main

import (
	"bufio"
	"encoding/binary"
	"errors"
	"fmt"
	"io"
	"strconv"
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

func islabel(token string) bool {
	return len(token) > 1 && token[len(token)-1] == ':'
}

type Section []uint32
type Object struct {
	Labels   map[string]int
	Sections map[string]Section
}

func Parse(r io.Reader) (*Object, error) {
	sr := bufio.NewReader(r)
	lineno := 0
	instrno := 0
	obj := &Object{
		make(map[string]int),
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

		// read label, if there is any
		if len(tokens) == 0 {
			continue
		}
		if label := tokens[0]; islabel(label) {
			tokens = tokens[1:]
			if _, ok := obj.Labels[label]; ok {
				return nil, errors.New("repeated label: " + label)
			}
			obj.Labels[label] = instrno
		}

		// read instruction
		if len(tokens) == 0 || tokens[0] == "" {
			continue
		}
		cmd, err := parseCommand(tokens) // does not support large pseudo instructions
		if err != nil {
			return nil, err
		}
		obj.Sections[currsection] = append(obj.Sections[currsection], cmd)
		instrno++
	}

	return obj, nil
}

type Assembler func(w io.Writer, o *Object) error

func AssembleBinary(w io.Writer, o *Object) error {
	for _, section := range o.Sections {
		for _, instr := range section {
			err := binary.Write(w, binary.LittleEndian, instr)
			if err != nil {
				return err
			}
		}
	}
	return nil
}

func AssembleText(w io.Writer, o *Object) error {
	for _, section := range o.Sections {
		for _, instr := range section {
			_, err := fmt.Fprintln(w, uint32(instr))
			if err != nil {
				return err
			}
		}
	}
	return nil
}

func parseCommand(tokens []string) (uint32, error) {
	switch tokens[0] {
	case "addi":
		return assemblei(OpImm, Funct3Add, tokens[1:]...)
	case "nop":
		if len(tokens) != 1 {
			return 0, ErrWrongInstrunctionFormat
		}
		return assemblei(OpImm, Funct3Add, "zero", "zero", "0")
	case "mov":
		if len(tokens) != 3 {
			return 0, ErrWrongInstrunctionFormat
		}
		return assemblei(OpImm, Funct3Add, tokens[1], tokens[2], "0")
	case "li":
		if len(tokens) != 3 {
			return 0, ErrWrongInstrunctionFormat
		}
		return assemblei(OpImm, Funct3Add, tokens[1], "zero", tokens[2])
	default:
		return 0, ErrUnknownInstruction
	}
}

func assemblei(opcode OpCode, funct3 Funct3, args ...string) (uint32, error) {
	if len(args) != 3 {
		return 0, ErrWrongInstrunctionFormat
	}
	rd, ok := RegNames[args[0]]
	if !ok {
		return 0, ErrInvalidRegister
	}
	rs, ok := RegNames[args[1]]
	if !ok {
		return 0, ErrInvalidRegister
	}
	immi, err := strconv.ParseUint(args[2], 10, 12)
	if err != nil {
		return 0, ErrInvalidNumeral
	}
	return iinstruction(OpImm, rd, Funct3Add, rs, uint32(immi))
}

func iinstruction(opcode OpCode, rd Reg, funct3 Funct3, rs1 Reg, immi uint32) (uint32, error) {
	return concat(
		bitslice{42, 12},
		bitslice{uint32(rs1), 5},
		bitslice{uint32(funct3), 3},
		bitslice{uint32(rd), 5},
		bitslice{uint32(opcode), 7},
	)
}
