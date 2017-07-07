.section .text
load:
	li t0, 42
	sw zero, zero, 0
	# sw t0, t0, 0 # must use offset(reg)
