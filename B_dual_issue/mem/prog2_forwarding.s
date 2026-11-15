# Programa 2 - Forwarding
# Resultado esperado: mem[80] = 15, mem[84] = 34
        addi x1, x0, 10       # x1 = 10
        addi x2, x1, 5        # x2 = 15   ForwardAE = 10 (x1 desde M)
        add  x3, x1, x2       # x3 = 25   ForwardAE = 01 (x1 desde W), ForwardBE = 10 (x2 desde M)
        sub  x4, x3, x1       # x4 = 15   ForwardAE = 10 (x3 desde M)
        and  x5, x4, x3       # x5 = 9    ForwardAE = 10 (x4), ForwardBE = 01 (x3)
        or   x6, x5, x4       # x6 = 15   ForwardAE = 10 (x5), ForwardBE = 01 (x4)
        addi x7, x0, 80       # x7 = 80
        sw   x6, 0(x7)        # mem[80] = 15  ForwardAE = 10 (x7), ForwardBE = 01 (x6 -> dato a guardar)
        add  x8, x6, x6       # x8 = 30   x6 ya esta en el regfile (distancia 3) -> sin forwarding
        slt  x9, x4, x8       # x9 = 1    ForwardBE = 10 (x8)
        add  x10, x9, x8      # x10 = 31  ForwardAE = 10 (x9), ForwardBE = 01 (x8)
        addi x11, x0, 1       # x11 = 1
        addi x11, x11, 1      # x11 = 2   ForwardAE = 10
        addi x11, x11, 1      # x11 = 3   x11 esta en M (2) y en W (1) -> debe ganar M (prioridad)
        add  x12, x10, x11    # x12 = 34  ForwardBE = 10 (x11)
        sw   x12, 4(x7)       # mem[84] = 34  ForwardBE = 10 (x12)
fin:    beq  x0, x0, fin
