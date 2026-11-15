# Programa 3 - Accesos a memoria (un solo puerto), ALU + LS en cualquier orden, load-use
# Resultado esperado: mem[72] = 30  (y mem[64] = 7, mem[68] = 9)
        addi x1, x0, 64       # par: x1 = 64 (base)
        addi x2, x0, 7        # par: x2 = 7
        sw   x2, 0(x1)        # par LS + ALU: mem[64] = 7 (el sw va en la via 1)
        addi x3, x0, 9        #               x3 = 9
        addi x4, x0, 5        # par ALU + LS: x4 = 5
        sw   x3, 4(x1)        #               mem[68] = 9 (el sw va en la via 2)
        lw   x5, 0(x1)        # dos lw en el mismo par -> DosMem, sale solo este
        lw   x6, 4(x1)        # se reagrupa con la siguiente
        add  x7, x5, x4       # usa x5 del lw que esta en E -> stall (load-use); x7 = 12
        addi x8, x0, 2        # par ALU + LS: x8 = 2
        lw   x9, 4(x1)        #               x9 = 9 (lw en la via 2)
        add  x10, x9, x6      # usa x9 del lw de la via 2 -> stall; x10 = 18
        add  x11, x10, x7     # RAW con x10 -> sale sola; x11 = 30
        sw   x11, 8(x1)       # mem[72] = 30
fin:    beq  x0, x0, fin      # bucle final
