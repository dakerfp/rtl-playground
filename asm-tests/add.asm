
.section .text
_start:
	li t0, 2 # load 2
	li t1, 40 # load 40
	# nop
	add t2, t0, t1 # 40 + 2
	nop
	nop
	sw t0, 0(zero) # assert mem[0] == 2
	sw t1, 4(zero) # assert mem[1] == 40
	sw t2, 8(zero) # assert mem[2] == 42
