.section .text
_start: # clocks 32
	li t0, 666
	li t1, 999
	nop
	nop
	nop
	sw t0, 0(zero) # put 666 into mem[0]
	bne t0, t1, 20 # branch to when_not_equal
	nop
	nop
	sw t1, 0(zero) # should never: mem[0] == 999
when_not_equal:
	nop
	halt # assert mem[0] == 666
