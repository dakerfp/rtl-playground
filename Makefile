
VC=iverilog
VFLAGS=-g2012 -Wall
TMPOUTPUT=/tmp/vt.txt

all: bin/asm bin/riscv

bin/riscv: riscv/riscv_sim.v
	$(VC) $(VFLAGS) $^ -o $@

bin/asm: bin
	go build -o $@ ./cmd/asm

bin:
	mkdir -p bin

test: gotest testtb testmisc

gotest:
	go test ./...

testtb: testunittb testinttb

testunittb: mem.tb alu.tb riscv/if.tb riscv/id.tb riscv/ex.tb riscv/ma.tb riscv/wb.tb

testinttb: riscv/id_if.tb riscv/id_if_ex.tb riscv/hart.tb

testmisc: misc/pwm.tb misc/tracker.tb

%.tb: %_tb.v
	@$(VC) $(VFLAGS) $^ -o $@
	@./$@ > $TMPOUTPUT && echo "[" $*_test "]: OK" || echo "[" $*_test "]: FAIL" && cat $TMPOUTPUT
	@rm $@

testsamples: bin/asm li.ts

%.ts: examples/%.asm
	@bin/asm -txt -o ./rom.txt $^
	@$(VC) $(VFLAGS) -o $@ memread_tb.v
	./$@
	@rm -rf ./rom.txt
	@rm -rf $@

clean:
	rm -rf *.tb
	rm -rf *.ts
	rm -rf bin
