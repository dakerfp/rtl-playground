
VC=iverilog
TMP_OUTPUT=/tmp/vt.txt

all: test bin/riscv bin/asm

test: mem.tb alu.tb gotest
	@rm -rf *.tb

bin/riscv: riscv_tb.v
	@$(VC) $^ -o $@

bin/asm: bin
	go build -o $@ ./cmd/asm

gotest:
	go test ./...

bin:
	mkdir -p bin

%.tb: %_test.v
	@$(VC) $^ -o $@
	@./$@ > $TMP_OUTPUT && echo "[" $*_test "]: OK" || echo "[" $*_test "]: FAIL" && cat $TMP_OUTPUT

clean:
	rm -rf *.tb
	rm bin/asm