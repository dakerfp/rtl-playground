package main

import (
	"io/ioutil"
	"os/exec"
	"strings"
	"testing"
)

func TestPhony(t *testing.T) {
	dir, err := ioutil.ReadDir(".")
	if err != nil {
		t.Fatal(err)
	}

	type exampleFail struct {
		failParse, failExec bool
	}

	expectedFail := map[string]exampleFail{
		"add.asm":      {true, true},
		"fib.asm":      {true, true},
		"all.asm":      {false, false},
		"overflow.asm": {false, false},
	}

	for _, fi := range dir {
		if !strings.HasSuffix(fi.Name(), ".asm") {
			continue
		}
		ef, ok := expectedFail[fi.Name()]
		if !ok {
			ef = exampleFail{false, false}
		}

		// run asm
		cmd := exec.Command(
			"../bin/asm",
			"-txt",
			"-o", "rom.txt",
			fi.Name(),
		)
		output, err := cmd.CombinedOutput()
		if bool(err != nil) != ef.failParse {
			t.Fatal(fi.Name(), string(output))
		}
		if ef.failParse {
			continue
		}

		// run simulator
		cmd = exec.Command("../bin/riscv")
		output, err = cmd.CombinedOutput()
		if bool(err != nil) != ef.failExec {
			t.Fatal(err, fi.Name(), string(output))
		}
	}
}
