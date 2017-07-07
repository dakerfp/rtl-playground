add t0, t1, t2
slti t3, t2, 0
slt t4, t0, t1
bne t3, t4, -7 # bne t3, t4, overflow
