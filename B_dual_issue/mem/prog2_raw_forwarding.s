# Programa 2 - RAW dentro del par y forwarding entre vias y etapas
# Resultado esperado: mem[80] = 47
        addi x1, x0, 10       # x1 = 10
        addi x2, x1, 5        # RAW con x1 en el mismo par -> no sale (RAWpar), se reagrupa
        addi x3, x0, 3        # par (x2, x3): x2 = 15 (x1 desde M), x3 = 3
        add  x4, x3, x2       # par: x4 = 18 (x3 desde M2 = 100, x2 desde M = 010)
        sub  x5, x1, x3       # par: x5 = 7  (x1 desde W = 001, x3 desde M2 = 100)
        addi x6, x0, 1        # par: x6 = 1
        addi x6, x0, 7        # par: x6 = 7  (WAW, la via 2 es la mas joven)
        add  x7, x6, x4       # par: x7 = 25 (x6 esta en M y en M2 -> gana M2; x4 desde W)
        add  x8, x5, x2       # par: x8 = 22 (x5 desde W2 = 011)
        addi x9, x0, 80       # par: x9 = 80
        add  x10, x7, x8      # par: x10 = 47 (via 2: x7 desde M = 010, x8 desde M2 = 100)
        sw   x10, 0(x9)       # mem[80] = 47 (x9 desde M, x10 desde M2)
fin:    beq  x0, x0, fin      # bucle final
