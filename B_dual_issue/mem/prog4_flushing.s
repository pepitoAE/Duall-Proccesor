# Programa 4 - Flushing (beq tomado, beq no tomado, jal y un bucle)
# Resultado esperado: mem[104] = 69
        addi x1, x0, 3        # x1 = 3
        addi x2, x0, 3        # x2 = 3
        addi x3, x0, 0        # x3 = 0
        beq  x1, x2, L1       # SE TOMA -> FlushD y FlushE
        addi x3, x3, 100      # camino incorrecto (se anula)
        addi x3, x3, 200      # camino incorrecto (se anula)
L1:     addi x3, x3, 1        # x3 = 1
        jal  x4, L2           # salto incondicional, x4 = 32 -> flush
        addi x3, x3, 100      # camino incorrecto (se anula)
        addi x3, x3, 100      # camino incorrecto (se anula)
L2:     addi x3, x3, 2        # x3 = 3
        beq  x3, x0, mal      # NO se toma (3 != 0) -> no hay flush
        addi x3, x3, 4        # x3 = 7
        addi x5, x0, 3        # x5 = 3 (contador)
loop:   addi x3, x3, 10       # x3 += 10
        addi x5, x5, -1       # x5--
        beq  x5, x0, salir    # se toma solo en la ultima vuelta
        jal  x0, loop         # vuelve al loop (flush cada vuelta)
salir:  add  x6, x3, x4       # x6 = 37 + 32 = 69
        addi x7, x0, 104      # x7 = 104
        sw   x6, 0(x7)        # mem[104] = 69
mal:    beq  x0, x0, mal      # bucle final (si se llega aqui sin el sw, falla)
