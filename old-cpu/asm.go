package main

import (
	"bufio"
	"errors"
	"flag"
	"fmt"
	"io"
	"os"
	"strconv"
	"strings"
)

var (
	inputFile  = flag.String("input", "", "input asm file")
	outputFile = flag.String("o", "./a.out", "output compiled binary")
)

var (
	ErrNoIntruction            = errors.New("no instruction")
	ErrTooManyLabels           = errors.New("too many labels")
	ErrWrongInstrunctionFormat = errors.New("wrong instruction format")
	ErrInvalidNumeral          = errors.New("invalid numeric value")
	ErrInvalidInstruction      = errors.New("invalid instruction")
)

type OpCode byte

const (
	NOP = OpCode(iota)
	ADD
	LDI
	WRO
	HLT
	SUB
)

type RegisterId byte

const (
	AX = RegisterId(iota)
	BX
	CX
	DX
)

type Instruction struct {
	OpCode
	Data [3]byte
}

func (inst Instruction) Encode(bytes []byte) {
	if len(bytes) < 4 {
		panic(bytes)
	}
	bytes[0] = byte(inst.OpCode)
	bytes[1] = inst.Data[0]
	bytes[2] = inst.Data[1]
	bytes[3] = inst.Data[2]
}

func decodeRegister(label string) (byte, bool) {
	var reg RegisterId
	ok := true
	switch label {
	case "AX", "ax":
		reg = AX
	case "BX", "bx":
		reg = BX
	case "CX", "cx":
		reg = CX
	case "DX", "dx":
		reg = DX
	default:
		ok = false
	}
	return byte(reg), ok
}

func tokenize(s string) []string {
	var tokens []string
	line := strings.Replace(strings.TrimSpace(s), ",", " ", -1)
	for _, token := range strings.Split(line, " ") {
		if token == "" {
			continue
		}
		if token[0] == '#' { // is a comment
			break
		}
		tokens = append(tokens, token)
	}
	return tokens
}

func compileLine(line string) (*Instruction, string, error) {
	tokens := tokenize(line)
	if len(tokens) == 0 {
		return nil, "", nil
	}

	var label string
	if strings.HasSuffix(tokens[0], ":") {
		label = strings.Replace(tokens[0], ":", "", 1)
		tokens = tokens[1:]
		if len(tokens) == 0 {
			return nil, label, nil
		}
	}

	var ok bool
	var inst *Instruction
	switch tokens[0] {
	case "NOP", "nop":
		inst = &Instruction{OpCode: NOP}
	case "HLT", "hlt":
		inst = &Instruction{OpCode: HLT}
	case "LDI", "ldi":
		inst = &Instruction{OpCode: LDI}
		if inst.Data[0], ok = decodeRegister(tokens[1]); !ok {
			return nil, label, ErrWrongInstrunctionFormat
		}
		i, err := strconv.ParseInt(tokens[2], 10, 16)
		if err != nil {
			return nil, label, ErrInvalidNumeral
		}
		inst.Data[1] = byte(i >> 8)
		inst.Data[2] = byte(i & 0xFF)
	case "WRO", "wro":
		inst = &Instruction{OpCode: WRO}
		if inst.Data[0], ok = decodeRegister(tokens[1]); !ok {
			return nil, label, ErrWrongInstrunctionFormat
		}
	case "ADD", "add":
		inst = &Instruction{OpCode: ADD}
		if inst.Data[0], ok = decodeRegister(tokens[1]); !ok {
			return nil, label, ErrWrongInstrunctionFormat
		}
		if inst.Data[1], ok = decodeRegister(tokens[2]); !ok {
			return nil, label, ErrWrongInstrunctionFormat
		}
		if inst.Data[2], ok = decodeRegister(tokens[3]); !ok {
			return nil, label, ErrWrongInstrunctionFormat
		}
	default:
		return nil, "", ErrInvalidInstruction
	}
	return inst, label, nil
}

func assemble(w io.Writer, r io.Reader) error {
	lineno := 1
	instrno := 0
	buffer := []byte{0, 0, 0, 0}
	var instructions []Instruction
	labels := make(map[string]int)
	for scan := bufio.NewScanner(r); scan.Scan(); lineno++ {
		line := scan.Text()
		inst, label, err := compileLine(line)
		if err != nil {
			return fmt.Errorf("error at line %d: %q", lineno, err)
		}
		if label != "" {
			if _, ok := labels[label]; ok {
				return fmt.Errorf("error at line %d: %q", lineno, err)
			}
			labels[label] = instrno
		}
		if inst == nil {
			continue
		}
		instructions = append(instructions, *inst)
		inst.Encode(buffer)
		if _, err := w.Write(buffer); err != nil {
			return err
		}
		instrno++
	}
	return nil
}

func main() {
	flag.Parse()

	inf, err := os.Open(*inputFile)
	if err != nil {
		panic(err)
	}
	defer inf.Close()

	of, err := os.OpenFile(*outputFile, os.O_CREATE|os.O_WRONLY, 0755)
	if err != nil {
		panic(err)
	}
	defer of.Close()

	err = assemble(of, inf)
	if err != nil {
		fmt.Println(err)
	}
}
