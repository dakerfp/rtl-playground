.section .text
_start: # clocks 64
	li t0, 666
	li t1, 999
	sw t0, 0(zero) # 20: put 666 into mem[0]
	bne t0, t1, 8 # branch to when_not_equal
	sw t1, 0(zero) # should never: mem[0] == 999
when_not_equal:
	halt # assert mem[0] == 666
