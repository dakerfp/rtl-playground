
VC=iverilog
TMP_OUTPUT=/tmp/vt.txt

all: bin/asm bin/riscv

test: mem.tb alu.tb gotest
	@rm -rf *.tb

samples: bin/li.bin # bin/add.bin bin/fib.bin

bin/riscv: riscv_tb.v
	@$(VC) $^ -o $@

bin/asm: bin
	go build -o $@ ./cmd/asm

gotest:
	go test ./...

bin:
	mkdir -p bin

bin/%.bin: examples/%.asm
	bin/asm -o $@ $^

%.tb: %_test.v
	@$(VC) $^ -o $@
	@./$@ > $TMP_OUTPUT && echo "[" $*_test "]: OK" || echo "[" $*_test "]: FAIL" && cat $TMP_OUTPUT

clean:
	rm -rf *.tb
	rm -rf bin