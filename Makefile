
VC=iverilog
TMP_OUTPUT=/tmp/vt.txt

all: bin/asm bin/riscv

test: mem.tb alu.tb gotest testsamples
	@rm -rf *.tb

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
	@rm $@

testsamples: li.ts

%.ts: examples/%.asm
	@bin/asm -txt -o ./rom.txt $^
	@iverilog -o $@ memread_tb.v
	./$@
	@rm -rf ./rom.txt
	@rm -rf $@

clean:
	rm -rf *.tb
	rm -rf bin