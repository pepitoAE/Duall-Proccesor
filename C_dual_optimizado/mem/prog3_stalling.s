# Programa 3 - Stalling (load-use)
# Resultado esperado: mem[100] = 25
        addi x1, x0, 7        # x1 = 7
        addi x2, x0, 96       # x2 = 96
        sw   x1, 0(x2)        # mem[96] = 7
        lw   x3, 0(x2)        # x3 = 7
        add  x4, x3, x3       # load-use en rs1 y rs2 -> 1 stall, luego ForwardAE/BE = 01   x4 = 14
        lw   x5, 0(x2)        # x5 = 7
        addi x6, x5, 3        # load-use en rs1 -> 1 stall   x6 = 10
        lw   x7, 0(x2)        # x7 = 7
        sub  x8, x6, x7       # load-use en rs2 -> 1 stall   x8 = 3
        lw   x9, 0(x2)        # x9 = 7
        addi x10, x0, 1       # instruccion independiente entre el lw y su uso
        add  x11, x9, x10     # SIN stall: x9 llega por ForwardAE = 01 desde W   x11 = 8
        add  x12, x4, x8      # x12 = 17
        add  x13, x12, x11    # x13 = 25
        sw   x13, 4(x2)       # mem[100] = 25
fin:    beq  x0, x0, fin
