
_start:
	lui t1, -7
	auipc ra, 55
	beq t0, t1, 64
	bne t0, t1, 64
	blt t0, t1, 64
	bge t0, t1, 64
	bltu t0, t1, 64
	bgeu t0, t1, 64
	jal ra, 42
	jalr t2, t1, -44