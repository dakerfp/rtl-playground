package main

import (
	"bufio"
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
	"regexp"
	"strconv"
	"strings"
	"testing"
)

type memAssert struct {
	lineno int
	addr   int
	value  int64
}

type asmTest struct {
	clocks  int
	asserts []memAssert
}

func asmMemAsserts(filename string) (t asmTest, err error) {
	t.clocks = 100
	r := regexp.MustCompile("#\\ +assert\\ +mem\\[(\\d+)\\]\\ +==\\ +(-?\\d+)")
	clocksR := regexp.MustCompile("#\\ +clocks\\ +(\\d+)")

	var f *os.File
	f, err = os.Open(filename)
	if err != nil {
		return
	}
	defer f.Close()

	scanner := bufio.NewScanner(f)
	for i := 1; scanner.Scan(); i++ {
		m := r.FindStringSubmatch(scanner.Text())
		if len(m) == 0 {
			m = clocksR.FindStringSubmatch(scanner.Text())
			if len(m) != 0 {
				t.clocks, err = strconv.Atoi(m[1])
				if err != nil {
					return
				}
			}
			continue
		}
		var assert memAssert
		assert.addr, err = strconv.Atoi(m[1])
		if err != nil {
			return
		}
		assert.value, err = strconv.ParseInt(m[2], 10, 64) // TODO: accept 0x
		if err != nil {
			return
		}
		assert.lineno = i
		t.asserts = append(t.asserts, assert)
	}
	return
}

func loadMemDump(filename string, length int) ([]int64, error) {
	mem := make([]int64, length)
	f, err := os.Open(filename)
	if err != nil {
		return mem, err
	}
	defer f.Close()

	scanner := bufio.NewScanner(f)
	for i := 0; i < len(mem) && scanner.Scan(); i++ {
		line := scanner.Text()
		if strings.HasPrefix(line, "//") {
			i-- // ignore line
			continue
		}
		if strings.Contains(line, "x") {
			mem[i] = -1 // not defined
			continue
		}
		_, err = fmt.Sscanf(line, "%x", &mem[i])
		if err != nil {
			return mem, err
		}
		// mem[i] = uint32(n)
	}
	return mem, nil
}

func TestPhony(t *testing.T) {
	dir, err := ioutil.ReadDir(".")
	if err != nil {
		t.Fatal(err)
	}

	type exampleFail struct {
		failParse, failExec bool
	}

	for _, fi := range dir {
		if !strings.HasSuffix(fi.Name(), ".asm") {
			continue
		}
		parseFail := strings.HasSuffix(fi.Name(), "_fail.asm")

		// run asm
		cmd := exec.Command(
			"../bin/asm",
			"-txt",
			"-o", "/tmp/rom.hex",
			fi.Name(),
		)
		output, err := cmd.CombinedOutput()
		if (err != nil) != parseFail {
			t.Fatal(fi.Name(), string(output))
		} else if parseFail {
			continue
		}

		asmT, err := asmMemAsserts(fi.Name())
		if err != nil {
			t.Fatal(err)
		}

		// run simulator
		// write memdump at ./dump.hex
		cmd = exec.Command(
			"../bin/riscv",
			fmt.Sprintf("+%d", asmT.clocks),
		)
		output, err = cmd.CombinedOutput()
		if err != nil {
			t.Fatal(fi.Name(), string(output))
		}

		mem, err := loadMemDump("dump.hex", 256)
		if err != nil {
			t.Fatal(err)
		}
		for _, assert := range asmT.asserts {
			if mem[assert.addr] != int64(assert.value) {

				t.Fatalf("assertion error in file %q at line: %d, got %d", fi.Name(), assert.lineno, mem[assert.addr])
			}
		}
	}
}
