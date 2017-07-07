package main

type OpCode uint32
type Reg uint32
type Funct3 uint32
type Funct7 uint32

const (
	Funct3Add  Funct3 = 0
	Funct3Sll         = 1
	Funct3Slt         = 2
	Funct3Sltu        = 3
	Funct3Xor         = 4
	Funct3Srl         = 5
	Funct3Sra         = 5
	Funct3Or          = 6
	Funct3And         = 7

	Funct3Beq  Funct3 = 0
	Funct3Bne         = 1
	Funct3Blt         = 4
	Funct3Bge         = 5
	Funct3Bltu        = 6
	Funct3Bgeu        = 7

	Funct3LoadB  Funct3 = 0
	Funct3LoadH         = 1
	Funct3LoadW         = 2
	Funct3LoadBU        = 4
	Funct3LoadHU        = 5

	Funct3StoreB Funct3 = 0
	Funct3StoreH        = 1
	Funct3StoreW        = 2

	Funct3Fence  Funct3 = 0
	Funct3FenceI Funct3 = 1

	Funct3None Funct3 = 0
)

const (
	OpImm     OpCode = 19
	Op               = 51
	OpLui            = 55
	OpStore          = 35
	OpLoad           = 3
	OpJal            = 111
	OpJalr           = 103
	OpAuipc          = 23
	OpBranch         = 99
	OpMiscMem        = 15
	OpSystem         = 115
)

const (
	Funct7None Funct7 = 0
	Funct7Add         = 0
	Funct7Sll         = 0
	Funct7Srl         = 0
	Funct7Sub         = 32
	Funct7Sra         = 32
)

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

type Immediate interface {
	Eval() (uint32, error)
}

type Uint32 uint32

func (u Uint32) Eval() (uint32, error) {
	return uint32(u), nil
}

type RegisterOffset struct {
	Reg Reg
	Imm Immediate
}

type Instruction interface {
	Eval() (uint32, error) // TODO: add params
}

type InstructionU struct {
	OpCode
	Rd Reg
	Immediate
}

func (i InstructionU) Eval() (uint32, error) {
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

type InstructionR struct {
	OpCode
	Rd, Rs1, Rs2 Reg
	Funct3
	Funct7
}

func (i InstructionR) Eval() (uint32, error) {
	return concat(
		bitslice{uint32(i.Funct7), 7},
		bitslice{uint32(i.Rs2), 5},
		bitslice{uint32(i.Rs1), 5},
		bitslice{uint32(i.Funct3), 3},
		bitslice{uint32(i.Rd), 5},
		bitslice{uint32(i.OpCode), 7},
	)
}

type InstructionB struct {
	OpCode
	Funct3
	Rs1, Rs2 Reg
	Immediate
}

func (i InstructionB) Eval() (uint32, error) {
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

type InstructionI struct {
	OpCode
	Rd, Rs1 Reg
	Funct3
	Immediate
}

func (i InstructionI) Eval() (uint32, error) {
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

type InstructionIS struct {
	OpCode
	Rd, Rs1 Reg
	Shamt   Immediate
	Funct3
	Funct7
}

func (i InstructionIS) Eval() (uint32, error) {
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

type InstructionS struct {
	OpCode
	Funct3
	Rs1, Rs2 Reg
	Immediate
}

func (i InstructionS) Eval() (uint32, error) {
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

func (i InstructionJ) Eval() (uint32, error) {
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
