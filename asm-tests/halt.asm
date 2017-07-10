.section .text
_start: # clocks 64
	li t0, 876
	li t1, 321
	nop
	nop
	nop
	sw zero, 0(t0)
	halt
	sw zero, 0(t1)
	nop
	nop
	sw zero, 0(t0) # assert mem[0] == 876