# clocks 64
.section .text
_start:
	li t1, 1 # 0
	addi t1, t1, 1 # 24
	sw t1, 4(zero) # assert mem[1] == 19
	jal zero, -8 # 48
	halt