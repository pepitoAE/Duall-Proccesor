# Programa 1 - Dos instrucciones ALU independientes por ciclo
# (dos escrituras al register file en el mismo ciclo y WAW dentro del par)
# Resultado esperado: mem[100] = 133
        addi x1, x0, 5        # par 1 via 1: x1 = 5
        addi x2, x0, 7        # par 1 via 2: x2 = 7  (2 escrituras en el mismo ciclo)
        addi x3, x0, 9        # par 2: x3 = 9
        addi x4, x0, 11       # par 2: x4 = 11
        add  x5, x1, x2       # par 3: x5 = 12 (x1 desde ResultW, x2 desde ResultW2)
        sub  x6, x4, x3       # par 3: x6 = 2
        and  x7, x1, x3       # par 4: x7 = 5 & 9 = 1
        or   x8, x2, x4       # par 4: x8 = 7 | 11 = 15
        slt  x9, x6, x5       # par 5: x9 = (2 < 12) = 1
        addi x10, x0, 100     # par 5: x10 = 100
        addi x11, x0, 1       # par 6 via 1: x11 = 1
        addi x11, x0, 2       # par 6 via 2: x11 = 2 (WAW: se queda la mas joven)
        add  x12, x5, x6      # par 7: x12 = 14
        add  x13, x7, x8      # par 7: x13 = 16
        add  x14, x9, x11     # par 8: x14 = 1 + 2 = 3 (x11 debe ser 2)
        add  x15, x0, x10     # par 8: x15 = 100
        add  x16, x12, x13    # par 9: x16 = 30
        add  x17, x14, x15    # par 9: x17 = 103
        add  x18, x16, x17    # x18 = 133
        sw   x18, 0(x10)      # mem[100] = 133 (RAW con x18 -> sale sola)
fin:    beq  x0, x0, fin      # bucle final
