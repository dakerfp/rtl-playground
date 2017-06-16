fib:
	li t0, 0
	li t1, 1
	add t2, t0, t1
	mv t0, t1
	mv t1, t2
	j fib
haltl:
	j haltl