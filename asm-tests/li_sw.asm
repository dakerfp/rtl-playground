.section .text
load:
	li t0, 42
	# store t0 == 42 in memory addr zero + 0 == 0
	sw t0, 0(zero) # assert mem[0] == 42
