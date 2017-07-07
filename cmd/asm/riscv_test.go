package main

import (
	"io/ioutil"
	"os"
	"path"
	"strings"
	"testing"
)

func TestBitmask(t *testing.T) {
	ones := uint32(0xFFFFFFFF)
	if m := bitmask(ones, 0, 32); m != 0xFFFFFFFF {
		t.Fatal(m, 0xFFFFFFFF)
	}

	if m := bitmask(ones, 0, 16); m != 0xFFFF {
		t.Fatal(m, 0xFFFF)
	}

	if m := bitmask(ones, 16, 32); m != 0xFFFF0000 {
		t.Fatal(m, 0xFFFF0000)
	}
}

func TestEmplace(t *testing.T) {
	v, err := emplace(0, 42, 0, 32)
	if err != nil || v != 42 {
		t.Fatal(err, 42)
	}

	v, err = emplace(0, 42, 0, 16)
	if err != nil || v != 42 {
		t.Fatal(err, 42)
	}

	v, err = emplace(0, 42, 0, 6)
	if err != nil || v != 42 {
		t.Fatal(err, 42)
	}

	v, err = emplace(0, 42, 0, 5)
	if err != ErrValueDontFitImmediate {
		t.Fatal(err, 42)
	}

	v, err = emplace(0, 42, 4, 8)
	if err != ErrValueDontFitImmediate {
		t.Fatal(err, 42)
	}

	v, err = emplace(0, 42, 4, 10)
	if err != nil || v != 672 {
		t.Fatal(err, 672)
	}

	v, err = emplace(42, 42, 5, 11)
	if err != nil || v != 1386 {
		t.Fatal(err, 1386)
	}
}

func TestConcat(t *testing.T) {
	v, err := concat(
		bitslice{0xB, 4},
		bitslice{0xA, 4},
		bitslice{0xD, 4},
		bitslice{0xC, 4},
		bitslice{0x0, 4},
		bitslice{0xD, 4},
		bitslice{0xE, 4},
	)
	if err != nil {
		t.Fatal(err)
	}
	if v != 0xBADC0DE {
		t.Fatal(v)
	}

	opcode := bitslice{uint32(OpImm), 7}
	rd := bitslice{uint32(RegNames["t0"]), 5}
	funct3 := bitslice{uint32(Funct3Add), 3}
	rs := bitslice{uint32(RegNames["zero"]), 5}
	immi := bitslice{42, 12}

	v, err = concat(immi, rs, funct3, rd, opcode)
	if err != nil {
		t.Fatal(err)
	}
	if v != 44040851 { // li t0, 42
		t.Fatal(v)
	}
}

func TestParser(t *testing.T) {
	obj, err := Parse(strings.NewReader(`
.section .text # section text, should be default
load:
	li t0, 42 # load immediate 42
	# or addi t0, zero 42
	`))
	if err != nil {
		t.Fatal(obj, err)
	}

	if len(obj.Sections) != 1 {
		t.Fatal(obj.Sections)
	}

	if len(obj.Symbols) != 1 {
		t.Fatal(obj.Symbols)
	}

	text, ok := obj.Sections[".text"]
	if !ok {
		t.Fatal(obj.Sections)
	}

	if l := len(text); l != 1 {
		t.Fatal(l)
	}

	li, err := text[0].Link()
	if err != nil {
		t.Fatal(err)
	}

	if bitmask(li, 0, 7) != uint32(OpImm) {
		t.Fatal("wrong opcode: ", bitmask(li, 0, 6))
	}

	if reg := bitmask(li, 7, 12) >> 7; reg != uint32(RegNames["t0"]) {
		t.Fatal("wrong register: ", reg)
	}

	if reg := bitmask(li, 12, 20) >> 12; reg != uint32(RegNames["zero"]) {
		t.Fatal("wrong register: ", reg)
	}

	if imm := bitmask(li, 20, 32) >> 20; imm != uint32(42) {
		t.Fatal("wrong immi: ", imm)
	}

	if li != 44040851 {
		t.Fatal(text)
	}
}

func TestSamples(t *testing.T) {
	dir, err := ioutil.ReadDir("samples")
	if err != nil {
		t.Fatal(err)
	}

	for _, fi := range dir {
		func(fn string) {
			f, err := os.Open(fn)
			if err != nil {
				t.Fatal(fn, err)
			}
			defer f.Close()

			obj, err := Parse(f)
			if err != nil {
				t.Fatal(fn, err)
			}
			if err := Assemble(&BinaryEncoder{ioutil.Discard}, obj); err != nil {
				t.Fatal(fn, err)
			}
		}(path.Join("samples", fi.Name()))
	}
}

func TestParse(t *testing.T) {
	tts := []struct {
		pattern string
		regname string
		offset  int
		err     error
	}{
		{"7(t0)", "t0", 7, nil},
		{"-3(t1)", "t1", -3, nil},
		{"-3.9(x0)", "x0", 0, ErrInvalidOffset},
		{"2(0)", "x0", 2, ErrInvalidRegister},
		{"0(zero)", "x0", 0, nil},
	}

	for _, tt := range tts {
		reg, offset, err := parseRegisterOffset(tt.pattern)
		if err != tt.err {
			t.Fatal(reg, offset, err)
		}
		if reg != RegNames[tt.regname] {
			t.Fatal("wrong reg", reg)
		}
		if offset != tt.offset {
			t.Fatal("wrong offset", offset)
		}
	}
}
