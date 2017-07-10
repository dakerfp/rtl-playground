.section .text
_start: # clocks 128

	# 0 nops
	li t0, 7
	sw t0, 0(zero) # assert mem[0] == 7

	# 1 nop
	li t1, 13
	nop
	sw t1, 4(zero) # assert mem[1] == 13

	# 2 nops
	li t2, 23
	nop
	nop
	sw t2, 8(zero) # assert mem[2] == 23

	# 3 nops
	li t3, 33
	nop
	nop
	nop
	sw t3, 12(zero) # assert mem[3] == 33

	# 4 nops
	li t4, 63
	nop
	nop
	nop
	nop
	sw t4, 16(zero) # assert mem[4] == 63

	# 5 nops
	li t5, 129
	nop
	nop
	nop
	nop
	nop
	sw t5, 20(zero) # assert mem[5] == 129

	# 6 nops
	li t0, 223
	nop
	nop
	nop
	nop
	nop
	nop
	sw t0, 24(zero) # assert mem[6] == 223

	# end
	halt
