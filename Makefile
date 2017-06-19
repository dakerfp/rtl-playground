
VC=iverilog -g2012
TMPOUTPUT=/tmp/vt.txt

all: bin/asm bin/riscv

bin/riscv: riscv/riscv_sim.v
	$(VC) $^ -o $@

bin/asm: bin
	go build -o $@ ./cmd/asm

bin:
	mkdir -p bin

test: gotest testtb testmisc

gotest:
	go test ./...

testtb: mem.tb alu.tb riscv/if.tb riscv/id.tb riscv/id_if.tb riscv/hart.tb

testmisc: misc/pwm.tb misc/tracker.tb

%.tb: %_tb.v
	@$(VC) $^ -o $@
	@./$@ > $TMPOUTPUT && echo "[" $*_test "]: OK" || echo "[" $*_test "]: FAIL" && cat $TMPOUTPUT
	@rm $@

testsamples: bin/asm li.ts

%.ts: examples/%.asm
	@bin/asm -txt -o ./rom.txt $^
	@$(VC) -o $@ memread_tb.v
	./$@
	@rm -rf ./rom.txt
	@rm -rf $@

clean:
	rm -rf *.tb
	rm -rf *.ts
	rm -rf bin
