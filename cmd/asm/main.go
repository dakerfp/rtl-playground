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
	zeroPadFlag    = flag.Int("pad", -1, "zero padding size")
)

func main() {
	flag.Parse()
	args := flag.Args()

	if len(args) == 0 {
		panic("no input file given")
	}

	r, err := os.Open(args[0])
	if err != nil {
		panic(err)
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

	if *zeroPadFlag > 0 {
		w = &ZeroPad{w, *zeroPadFlag}
	}

	if *dumpFlag {
		w = hex.Dumper(w)
		defer w.Close()
	}

	var enc InstructionEncoder
	if *txtFlag {
		enc = &TextEncoder{w}
	} else {
		enc = &BinaryEncoder{w}
	}
	if err := Assemble(enc, obj); err != nil {
		panic(err)
	}
}
