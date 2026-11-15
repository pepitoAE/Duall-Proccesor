# Programa 4 - Saltos en la primera y en la segunda posicion del par
# Resultado esperado: mem[104] = 141
        addi x1, x0, 3        # par: x1 = 3
        addi x2, x0, 3        # par: x2 = 3
        addi x3, x0, 0        # par: x3 = 0 (es mas antigua que el beq, NO se anula)
        beq  x1, x2, L1       #      beq en la via 2, SE TOMA
        addi x3, x3, 100      # camino incorrecto (se anula)
        addi x3, x3, 200      # camino incorrecto (se anula)
L1:     beq  x1, x2, L2       # par: beq en la via 1, SE TOMA
        addi x3, x3, 300      #      va con el beq pero es mas joven -> se anula (FlushM2)
        addi x3, x3, 400      # camino incorrecto (se anula)
L2:     addi x3, x3, 1        # par: x3 = 1
        beq  x1, x0, fin      #      beq en la via 2, NO se toma
        beq  x2, x0, fin      # par: beq en la via 1, NO se toma
        addi x3, x3, 2        #      x3 = 3 (sigue normal)
        jal  x4, L3           # par: jal en la via 1, x4 = 56
        addi x3, x3, 500      #      se anula (FlushM2)
        addi x3, x3, 600      # camino incorrecto (se anula)
L3:     addi x5, x0, 10       # par: x5 = 10
        jal  x6, L4           #      jal en la via 2, x6 = 72
        addi x3, x3, 700      # camino incorrecto (se anula)
L4:     beq  x1, x2, L5       # par con dos saltos -> DosSaltos, sale solo el beq (SE TOMA)
        jal  x0, fin          # nunca se ejecuta
L5:     add  x7, x3, x4       # x7 = 3 + 56 = 59
        add  x8, x5, x6       # x8 = 10 + 72 = 82
        add  x9, x7, x8       # x9 = 141
        addi x10, x0, 104     # x10 = 104
        sw   x9, 0(x10)       # mem[104] = 141
fin:    beq  x0, x0, fin      # bucle final (si se llega aqui sin el sw, falla)
