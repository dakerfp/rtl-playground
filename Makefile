
VC=iverilog -g2012
TMP_OUTPUT=/tmp/vt.txt

all: bin/asm bin/riscv

bin/riscv: riscv_tb.v
	@$(VC) $^ -o $@

bin/asm: bin
	go build -o $@ ./cmd/asm

bin:
	mkdir -p bin

bin/%.bin: examples/%.asm
	bin/asm -o $@ $^

test: gotest testtb testmisc testsamples

gotest:
	go test ./...

testtb: mem.tb alu.tb riscv/if.tb riscv/id.tb riscv/id_if.tb

testmisc: misc/pwm.tb

%.tb: %_tb.v
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
	rm -rf *.ts
	rm -rf bin
