package main

import (
	"bufio"
	"encoding/binary"
	"errors"
	"flag"
	"io"
	"os"
	"strconv"
	"strings"
)

type OpCode uint32
type Reg uint32
type Funct3 uint32
type Instr func(...string) uint32

const (
	Funct3Add = Funct3(iota)
)

const (
	OpImm    = OpCode(23)
	Op       = OpCode(51)
	OpLui    = OpCode(55)
	OpStore  = OpCode(35)
	OpLoad   = OpCode(3)
	OpJal    = OpCode(111)
	OpJalr   = OpCode(103)
	OpAuipc  = OpCode(23)
	OpBranch = OpCode(99)
	OpFence  = OpCode(15)
	OpSystem = OpCode(115)
)

var (
	ErrNotImplemented          = errors.New("not implemented yet")
	ErrWrongInstrunctionFormat = errors.New("wrong instruction format")
	ErrValueDontFitImmediate   = errors.New("immediate value does not fit instruction")
	ErrUnknownInstruction      = errors.New("unknown instruction")
	ErrInvalidRegister         = errors.New("invalid register")
	ErrInvalidNumeral          = errors.New("invalid number literal")
)

func IImmu(imm uint32) (uint32, error) {
	if imm >= (1 << 12) {
		return 0, ErrValueDontFitImmediate
	}
	v := imm << 20
	return v, nil
}

var RegNames = map[string]Reg{
	"x0": Reg(0), "zero": Reg(0),
	"x1": Reg(1), "ra": Reg(1),
	"x2": Reg(2), "sp": Reg(2),
	"x3": Reg(3), "gp": Reg(3),
	"x4": Reg(4), "tp": Reg(4),
	"x5": Reg(5), "t0": Reg(5),
	"x6": Reg(6), "t1": Reg(6),
	"x7": Reg(7), "t2": Reg(7),
	"x8": Reg(8), "s0": Reg(8), "fp": Reg(8),
	"x9": Reg(9), "s1": Reg(9),
	"x10": Reg(10), "a0": Reg(10),
	"x11": Reg(11), "a1": Reg(11),
	"x12": Reg(12), "a2": Reg(12),
	"x13": Reg(13), "a3": Reg(13),
	"x14": Reg(14), "a4": Reg(14),
	"x15": Reg(15), "a5": Reg(15),
	"x16": Reg(16), "a6": Reg(16),
	"x17": Reg(17), "a7": Reg(17),
	"x18": Reg(18), "s2": Reg(18),
	"x19": Reg(19), "s3": Reg(19),
	"x20": Reg(20), "s4": Reg(20),
	"x21": Reg(21), "s5": Reg(21),
	"x22": Reg(22), "s6": Reg(22),
	"x23": Reg(23), "s7": Reg(23),
	"x24": Reg(24), "s8": Reg(24),
	"x25": Reg(25), "s9": Reg(25),
	"x26": Reg(26), "s10": Reg(26),
	"x27": Reg(27), "s11": Reg(27),
	"x28": Reg(28), "t3": Reg(28),
	"x29": Reg(29), "t4": Reg(29),
	"x30": Reg(30), "t5": Reg(30),
	"x31": Reg(31), "t6": Reg(31),
}

var OpCodeNames = map[string]OpCode{
	"li":   OpImm,
	"addi": OpImm,
}

func islabel(token string) bool {
	return len(token) > 1 && token[len(token)-1] == ':'
}

func bitmask(from, to uint32) uint32 {
	mask := uint32(1 << from)
	for i := from + 1; i <= to; i++ {
		mask |= 1 << i
	}
	return mask
}

func emplace(bits, v, from, to uint32) (uint32, error) {
	shiftv := v << from
	mask := bitmask(from, to)
	v = shiftv & mask
	if v != shiftv {
		return bits, ErrValueDontFitImmediate
	}
	return bits | v, nil
}

func rinstruction(opcode, rd, funct3, rs1, rs2, funct7 uint32) (uint32, error) {
	instr, err := emplace(0, opcode, 0, 6)
	if err != nil {
		return 0, err
	}
	instr, err = emplace(instr, rd, 7, 11)
	if err != nil {
		return 0, err
	}
	instr, err = emplace(instr, funct3, 12, 14)
	if err != nil {
		return 0, err
	}
	instr, err = emplace(instr, rs1, 15, 19)
	if err != nil {
		return 0, err
	}
	instr, err = emplace(instr, rs2, 20, 24)
	if err != nil {
		return 0, err
	}
	instr, err = emplace(instr, funct7, 25, 31)
	if err != nil {
		return 0, err
	}
	return instr, nil
}

func iinstruction(opcode OpCode, rd Reg, funct3 Funct3, rs1 Reg, immu uint32) (uint32, error) {
	instr, err := emplace(0, uint32(opcode), 0, 6)
	if err != nil {
		return 0, err
	}
	instr, err = emplace(instr, uint32(rd), 7, 11)
	if err != nil {
		return 0, err
	}
	instr, err = emplace(instr, uint32(funct3), 12, 14)
	if err != nil {
		return 0, err
	}
	instr, err = emplace(instr, uint32(rs1), 15, 19)
	if err != nil {
		return 0, err
	}
	instr, err = emplace(instr, immu, 20, 31)
	if err != nil {
		return 0, err
	}
	return instr, nil
}

func parseCommand(tokens []string) (uint32, error) {
	switch tokens[0] {
	case "li":
		if len(tokens) != 3 {
			return 0, ErrWrongInstrunctionFormat
		}
		rd, ok := RegNames[tokens[1]]
		if !ok {
			return 0, ErrInvalidRegister
		}
		imm, err := strconv.ParseUint(tokens[2], 10, 12)
		if err != nil {
			return 0, ErrInvalidNumeral
		}
		return iinstruction(OpImm, rd, Funct3Add, 0, uint32(imm))
	default:
		return 0, ErrUnknownInstruction
	}
}

var (
	outputFileFlag = flag.String("o", "a.out", "output assembled object")
)

func assemble(w io.Writer, r io.Reader) error {
	sr := bufio.NewReader(r)
	lineno := 0
	instrno := 0
	labels := make(map[string]int)
	segments := make(map[string][]uint32)
	for {
		line, err := sr.ReadString('\n')
		if err == io.EOF {
			break
		} else if err != nil {
			return err
		}
		lineno++
		line = line[0:strings.IndexAny(line, "#\n")]
		line = strings.TrimSpace(line)
		line = strings.Replace(line, ",", "", -1) // XXX
		tokens := strings.Split(line, " ")

		// read label, if there is any
		if len(tokens) == 0 {
			continue
		}
		if label := tokens[0]; islabel(label) {
			tokens = tokens[1:]
			if _, ok := labels[label]; ok {
				return errors.New("repeated label: " + label)
			}
			labels[label] = instrno
		}

		// read instruction
		if len(tokens) == 0 || tokens[0] == "" {
			continue
		}
		cmd, err := parseCommand(tokens) // does not support large pseudo instructions
		if err != nil {
			return err
		}
		segments[".text"] = append(segments[".text"], cmd) // XXX: ignoring segments
		instrno++
	}

	for _, segment := range segments {
		for _, instr := range segment {
			err := binary.Write(w, binary.LittleEndian, instr)
			if err != nil {
				return err
			}
		}
	}

	return nil
}

func main() {
	flag.Parse()
	args := flag.Args()

	r, err := os.Open(args[0])
	if err != nil {
		panic(err)
	}
	defer r.Close()

	w, err := os.OpenFile(*outputFileFlag, os.O_CREATE|os.O_WRONLY, 0755)
	if err != nil {
		panic(err)
	}
	defer w.Close()

	if err := assemble(w, r); err != nil {
		panic(err)
	}
}
