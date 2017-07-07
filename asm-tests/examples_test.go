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

func asmMemAsserts(filename string) ([]memAssert, error) {
	r := regexp.MustCompile("#\\ +assert\\ +mem\\[(\\d+)\\]\\ +==\\ +(-?\\d+)")

	f, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer f.Close()

	scanner := bufio.NewScanner(f)
	var asserts []memAssert
	for i := 0; scanner.Scan(); i++ {
		m := r.FindStringSubmatch(scanner.Text())
		if len(m) == 0 {
			continue
		}
		var assert memAssert
		assert.addr, err = strconv.Atoi(m[1])
		if err != nil {
			return nil, err
		}
		assert.value, err = strconv.ParseInt(m[2], 10, 64) // TODO: accept 0x
		if err != nil {
			return nil, err
		}
		assert.lineno = i
		asserts = append(asserts, assert)
	}
	return asserts, nil
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
			"-pad", "512",
			"-o", "/tmp/rom.hex",
			fi.Name(),
		)
		output, err := cmd.CombinedOutput()
		if (err != nil) != parseFail {
			t.Fatal(fi.Name(), string(output))
		} else if parseFail {
			continue
		}

		// run simulator
		// write memdump at ./dump.hex
		cmd = exec.Command("../bin/riscv", "+/tmp/rom.hex")
		output, err = cmd.CombinedOutput()
		fmt.Println(string(output))
		if err != nil {
			t.Fatal(fi.Name())
		}

		// check code assertions
		mem, err := loadMemDump("dump.hex", 256)
		if err != nil {
			t.Fatal(err)
		}
		asserts, err := asmMemAsserts(fi.Name())
		if err != nil {
			t.Fatal(err)
		}
		for _, assert := range asserts {
			if mem[assert.addr] != int64(assert.value) {
				t.Fatalf("assertion error in file %q at line %d. Got %d, expected %d",
					fi.Name(), assert.lineno, mem[assert.addr], assert.value)
			}
		}
	}
}
