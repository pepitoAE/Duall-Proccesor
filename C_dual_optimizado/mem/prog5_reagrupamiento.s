# Programa 5 - Reagrupamiento despues de emitir solo una instruccion
# Las operaciones de x1 dependen del orden: si una instruccion se pierde,
# se repite o se cambia de orden, el resultado final sale distinto
# Resultado esperado: mem[96] = 38
        addi x1, x0, 1        # x1 = 1
        add  x1, x1, x1       # x1 = 2
        addi x1, x1, 3        # x1 = 5
        addi x2, x0, 10       # x2 = 10
        add  x1, x1, x1       # x1 = 10
        addi x1, x1, 1        # x1 = 11
        addi x3, x0, 20       # x3 = 20
        sub  x1, x1, x2       # x1 = 1
        add  x1, x1, x3       # x1 = 21
        addi x4, x0, 4        # x4 = 4
        add  x1, x1, x1       # x1 = 42
        sub  x1, x1, x4       # x1 = 38
        addi x5, x0, 96       # x5 = 96
        sw   x1, 0(x5)        # mem[96] = 38
fin:    beq  x0, x0, fin      # bucle final
