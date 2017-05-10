
VC=iverilog
TMP_OUTPUT=/tmp/verilog_test.txt

test: mem.tb alu.tb
	@:
	@rm -rf *.tb

%.tb: %_test.v
	@$(VC) $^ -o $@
	@./$@ > $TMP_OUTPUT && echo "[" $*_test "]: OK" || echo "[" $*_test "]: FAIL" && cat $TMP_OUTPUT

clean:
	rm -rf *.tb