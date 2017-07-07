package main

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

type InstructionS struct {
	OpCode
	Funct3
	Rs1, Rs2 Reg
	Immediate
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
