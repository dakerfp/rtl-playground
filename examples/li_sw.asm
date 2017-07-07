.section .text
load:
	li t0, 42
	nop
	nop
	nop
	nop
	# store t0 == 42 in memory addr zero + 0 == 0
	sw zero, 0(t0)

# assert mem[0] == 42
