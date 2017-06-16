package main

import (
	"strings"
	"testing"
)

func TestBitmask(t *testing.T) {
	ones := uint32(0xFFFFFFFF)
	if m := bitmask(ones, 0, 31); m != 0xFFFFFFFF {
		t.Fatal(m, 0xFFFFFFFF)
	}

	if m := bitmask(ones, 0, 15); m != 0xFFFF {
		t.Fatal(m, 0xFFFF)
	}

	if m := bitmask(ones, 16, 31); m != 0xFFFF0000 {
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

	v, err = emplace(0, 42, 0, 5)
	if err != nil || v != 42 {
		t.Fatal(err, 42)
	}

	v, err = emplace(0, 42, 0, 4)
	if err != ErrValueDontFitImmediate {
		t.Fatal(err, 42)
	}

	v, err = emplace(0, 42, 4, 8)
	if err != ErrValueDontFitImmediate {
		t.Fatal(err, 42)
	}

	v, err = emplace(0, 42, 4, 9)
	if err != nil || v != 672 {
		t.Fatal(err, 672)
	}

	v, err = emplace(42, 42, 5, 10)
	if err != nil || v != 1386 {
		t.Fatal(err, 1386)
	}
}

func TestParser(t *testing.T) {
	obj, err := Parse(strings.NewReader(`
.section .text # section text, should be default
load:
	li t0, 42 # load immediate 42
	`))
	if err != nil {
		t.Fatal(err)
	}

	if len(obj.Sections) != 1 {
		t.Fatal(obj.Sections)
	}

	if len(obj.Labels) != 1 {
		t.Fatal(obj.Labels)
	}

	text, ok := obj.Sections[".text"]
	if !ok {
		t.Fatal(obj.Sections)
	}

	if l := len(text); l != 1 {
		t.Fatal(l)
	}

	li := text[0]
	if bitmask(li, 0, 6) != uint32(OpCodeNames["li"]) {
		t.Fatal("wrong opcode: ", bitmask(li, 0, 6))
	}

	if reg := bitmask(li, 7, 11) >> 7; reg != uint32(RegNames["t0"]) {
		t.Fatal("wrong register: ", reg)
	}

	if imm := bitmask(li, 20, 31) >> 20; imm != uint32(42) {
		t.Fatal("wrong immm: ", imm)
	}
}
