
_start:
	li t1, 40 # load 40
	add t3, t1, t2 # add 40 + 2
	sw t3, 0(zero) # write 42 into mem[0]
