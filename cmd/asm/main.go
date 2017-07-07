package main

import (
	"encoding/hex"
	"flag"
	"io"
	"os"
)

var (
	outputFileFlag = flag.String("o", "a.bin", "output Parsed object")
	dumpFlag       = flag.Bool("d", false, "output hex dump format instead of binary")
	stdoutFlag     = flag.Bool("stdout", false, "output into stdout")
	txtFlag        = flag.Bool("txt", false, "output txt")
	zeroPadFlag    = flag.Int("pad", -1, "pad .text with n zeros")
)

func main() {
	flag.Parse()
	args := flag.Args()

	var r io.ReadCloser
	switch len(args) {
	case 1:
		f, err := os.Open(args[0])
		if err != nil {
			panic(err)
		}
		r = f
	case 0:
		r = os.Stdin
	default:
		panic("too many files")
	}
	defer r.Close()

	obj, err := Parse(r)
	if err != nil {
		panic(err)
	}

	var w io.WriteCloser
	switch {
	case *stdoutFlag:
		w = os.Stdout
	case *outputFileFlag != "":
		f, err := os.OpenFile(*outputFileFlag, os.O_CREATE|os.O_WRONLY, 0755)
		if err != nil {
			panic(err)
		}
		defer f.Close()
		w = f
	default:
		panic("no output set")
	}

	if *dumpFlag {
		w = hex.Dumper(w)
		defer w.Close()
	}

	if *zeroPadFlag > 0 {
		section, ok := obj.Sections[".text"]
		if !ok {
			panic(section)
		}
		for i := len(section); i < *zeroPadFlag; i++ {
			section = append(section, NOP)
		}
	}

	var enc InstructionEncoder
	if *txtFlag {
		enc = &TextEncoder{w, "%x\n"}
	} else {
		enc = &BinaryEncoder{w}
	}
	if err := Assemble(enc, obj); err != nil {
		panic(err)
	}
}
