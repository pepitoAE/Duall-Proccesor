# Programa 1 - ISA sin dependencias
# Cada instruccion lee registros escritos al menos 3 instrucciones antes,
# asi el dato ya esta en el register file (escritura en flanco de bajada) y NO se necesita forwarding ni stall.
# Resultado esperado: mem[72] = 30
        addi x1, x0, 5        # x1 = 5
        addi x2, x0, 12       # x2 = 12
        addi x3, x0, -3       # x3 = -3
        addi x4, x0, 64       # x4 = 64 (direccion base)
        add  x5, x1, x2       # x5 = 17
        sub  x6, x2, x1       # x6 = 7
        and  x7, x1, x2       # x7 = 4
        or   x8, x1, x2       # x8 = 13
        slt  x9, x3, x1       # x9 = 1  (-3 < 5)
        andi x10, x2, 6       # x10 = 4
        ori  x11, x1, 8       # x11 = 13
        slti x12, x1, 7       # x12 = 1
        sw   x5, 0(x4)        # mem[64] = 17
        sw   x6, 4(x4)        # mem[68] = 7
        beq  x1, x2, fin      # no se toma (5 != 12)
        lw   x13, 0(x4)       # x13 = 17
        addi x14, x0, 1       # relleno independiente
        addi x15, x0, 2
        addi x16, x0, 3
        add  x17, x13, x8     # x17 = 17 + 13 = 30
        addi x18, x0, 4
        addi x19, x0, 5
        addi x20, x0, 6
        sw   x17, 8(x4)       # mem[72] = 30
fin:    beq  x0, x0, fin      # bucle final
