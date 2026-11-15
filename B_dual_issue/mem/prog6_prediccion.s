    addi x1, x0, 0
    addi x2, x0, 10
    addi x3, x0, 0
    addi x4, x0, 0
    addi x5, x0, 1
    addi x6, x0, 0
L:
    add  x3, x3, x1
    sub  x4, x5, x4
    beq  x4, x5, S
    addi x6, x6, 2
S:
    addi x1, x1, 1
    slt  x7, x1, x2
    beq  x7, x5, L
    sw   x3, 0(x0)
    sw   x6, 4(x0)
fin:
    jal  x0, fin
