.section .text
_start: # clocks 64
	li t0, 876
	li t1, 321
	sw t0, 0(zero)
	halt
	sw t1, 0(zero)
	nop
	nop
	sw t0, 0(zero) # assert mem[0] == 876