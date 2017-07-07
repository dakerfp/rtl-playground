package main

import (
	"encoding/binary"
	"fmt"
	"io"
)

type InstructionEncoder interface {
	EncodeInstruction(instr uint32) error
}

type TextEncoder struct {
	w      io.Writer
	format string
}

func (te *TextEncoder) EncodeInstruction(instr uint32) (err error) {
	_, err = fmt.Fprintf(te.w, te.format, uint32(instr))
	return
}

type BinaryEncoder struct {
	w io.Writer
}

func (be *BinaryEncoder) EncodeInstruction(instr uint32) error {
	return binary.Write(be.w, binary.LittleEndian, instr)
}
