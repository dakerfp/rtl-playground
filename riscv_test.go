package main

import (
	"os"
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
