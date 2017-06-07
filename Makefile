
VC=iverilog
TMP_OUTPUT=/tmp/verilog_test.txt

cpu_sim: cpu_sim.v
	@$(VC) $^ -o $@

test: mem.tb alu.tb cpu.tb
	@rm -rf *.tb

%.tb: %_test.v
	@$(VC) $^ -o $@
	@./$@ > $TMP_OUTPUT && echo "[" $*_test "]: OK" || echo "[" $*_test "]: FAIL" && cat $TMP_OUTPUT

clean:
	rm -rf *.tb