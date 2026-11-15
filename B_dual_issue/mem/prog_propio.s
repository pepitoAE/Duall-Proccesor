etapa_1:
    addi x1, x0, 1024
    addi x2, x0, 1088
    addi x3, x0, 1152
    addi x4, x0, 1216
    addi x5, x0, 7
    addi x6, x0, 3
    sw   x5, 0(x1)
    addi x7, x0, 12
    sw   x6, 4(x1)
    addi x5, x0, 9
    sw   x7, 8(x1)
    addi x6, x0, 1
    sw   x5, 12(x1)
    addi x7, x0, 15
    sw   x6, 16(x1)
    addi x5, x0, 4
    sw   x7, 20(x1)
    addi x6, x0, 10
    sw   x5, 24(x1)
    addi x7, x0, 6
    sw   x6, 28(x1)
    addi x5, x0, 14
    sw   x7, 32(x1)
    addi x6, x0, 2
    sw   x5, 36(x1)
    addi x7, x0, 11
    sw   x6, 40(x1)
    addi x5, x0, 8
    sw   x7, 44(x1)
    addi x6, x0, 5
    sw   x5, 48(x1)
    addi x7, x0, 13
    sw   x6, 52(x1)
    addi x5, x0, 0
    sw   x7, 56(x1)
    sw   x5, 60(x1)
etapa_2:
    addi x16, x0, 0
    addi x24, x0, 16
    addi x12, x0, 0
    addi x13, x0, 0
    addi x14, x0, 7
    addi x15, x0, 1
    add  x17, x1, x0
    add  x18, x2, x0
L2:
    lw   x20, 0(x17)
    addi x17, x17, 4
    add  x21, x20, x16
    add  x12, x12, x20
    sw   x21, 0(x18)
    addi x18, x18, 4
    slt  x22, x14, x20
    addi x16, x16, 1
    beq  x22, x0, L2s
    addi x13, x13, 1
L2s:
    slt  x23, x16, x24
    beq  x23, x15, L2
    sw   x12, 0(x4)
    sw   x13, 4(x4)
etapa_3:
    addi x16, x0, 0
    addi x24, x0, 8
    add  x17, x1, x0
    add  x18, x2, x0
    add  x19, x3, x0
L3:
    lw   x20, 0(x17)
    lw   x21, 0(x18)
    lw   x25, 4(x17)
    add  x22, x20, x21
    lw   x26, 4(x18)
    addi x16, x16, 1
    add  x27, x25, x26
    sw   x22, 0(x19)
    addi x17, x17, 8
    sw   x27, 4(x19)
    addi x18, x18, 8
    addi x19, x19, 8
    slt  x23, x16, x24
    beq  x23, x15, L3
    sw   x22, 8(x4)
etapa_4:
    addi x8, x0, 0
    addi x9, x0, 4
    add  x17, x3, x0
    addi x28, x0, 0
L4o:
    addi x10, x0, 0
    addi x11, x0, 0
L4i:
    lw   x20, 0(x17)
    addi x10, x10, 1
    addi x17, x17, 4
    add  x11, x11, x20
    slt  x23, x10, x9
    beq  x23, x15, L4i
    slt  x29, x28, x11
    addi x8, x8, 1
    beq  x29, x0, L4n
    add  x28, x11, x0
L4n:
    sw   x11, 12(x4)
    addi x4, x4, 4
    slt  x23, x8, x9
    beq  x23, x15, L4o
    addi x4, x4, -16
    sw   x28, 28(x4)
fin:
    jal  x0, fin
