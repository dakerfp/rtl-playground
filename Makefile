
VC=iverilog
TMP_OUTPUT=/tmp/verilog_test.txt

test: mem.tb
	@:
	@rm -rf *.tb

%.tb: %.v %_test.v
	@$(VC) $^ -o $@
	@./$@ > $TMP_OUTPUT && echo "[" $*_test "]: OK" || echo "[" $*_test "]: FAIL" && cat $TMP_OUTPUT

clean:
	rm -rf *.tb