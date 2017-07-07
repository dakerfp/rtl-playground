package main

import (
	"bufio"
	"errors"
	"fmt"
	"io"
	"strings"
)

var (
	ErrNotImplemented          = errors.New("not implemented yet")
	ErrWrongInstrunctionFormat = errors.New("wrong instruction format")
	ErrValueDontFitImmediate   = errors.New("immediate value does not fit instruction")
	ErrUnknownInstruction      = errors.New("unknown instruction")
	ErrInvalidRegister         = errors.New("invalid register")
	ErrInvalidNumeral          = errors.New("invalid number literal")
	ErrInvalidOffset           = errors.New("invalid offset value")
	ErrSymbolRedefined         = errors.New("symbol redefined")
)

type ParseError struct {
	Err     error
	lineno  int
	message string
}

func (pe *ParseError) Error() string {
	return fmt.Sprintf("%s at line %d: %s", pe.Err.Error(), pe.lineno, pe.message)
}

func IsParseError(err error) bool {
	return err.(*ParseError) != nil
}

type Section []Instruction

type Symbol struct {
	Name        string
	SectionName string
	Lineno      int
	Instrno     int
}

type Object struct {
	Symbols  map[string]Symbol
	Sections map[string]Section
}

func Parse(r io.Reader) (*Object, error) {
	sr := bufio.NewReader(r)
	lineno := 1
	instrno := 0
	obj := &Object{
		make(map[string]Symbol),
		make(map[string]Section),
	}
	currsection := ".text" // default section is .text
	for {
		line, err := sr.ReadString('\n')
		if err == io.EOF {
			break
		} else if err != nil {
			return obj, err
		}

		lineno++
		tokens := tokenize(line)

		// check if it is a section
		if len(tokens) == 2 && tokens[0] == ".section" {
			currsection = tokens[1]
			continue // ignore the rest of the line
		}

		// goto next line if line is empty
		if len(tokens) == 0 {
			continue
		}

		// try parsing label
		if symbol, ok := parseSymbol(tokens[0]); ok {
			if _, ok := obj.Symbols[symbol]; ok {
				return obj, &ParseError{ErrSymbolRedefined, lineno, line}
			}
			obj.Symbols[symbol] = Symbol{
				Name:        symbol,
				SectionName: currsection,
				Lineno:      lineno,
				Instrno:     instrno,
			}
			tokens = tokens[1:] // removing symbol from list of tokens
		}

		// read instruction
		if len(tokens) == 0 || tokens[0] == "" {
			continue
		}
		cmd, err := parseCommand(tokens) // does not support large pseudo instructions
		if err != nil {
			return obj, &ParseError{err, lineno, line}
		}
		obj.Sections[currsection] = append(obj.Sections[currsection], cmd)
		instrno++
	}

	return obj, nil
}

func Assemble(ie InstructionEncoder, o *Object) error {
	for _, section := range o.Sections {
		for _, instr := range section {
			ui, err := instr.Link()
			if err != nil {
				return err
			}
			if err := ie.EncodeInstruction(ui); err != nil {
				return err
			}
		}
	}
	return nil
}

func tokenize(line string) []string {
	line = line[0:strings.IndexAny(line, "#\n")] // remove comments #
	line = strings.TrimSpace(line)               // cleanup spaces
	line = strings.Replace(line, ",", "", -1)    // XXX: ignoring "," order
	return strings.Split(line, " ")              // tokenize
}
