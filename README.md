# Procesador RISC-V RV32I Dual-Issue In-Order — Arquitectura de Computadoras (UTEC)

Proyecto 2: pipeline de 5 etapas (A), su extensión superescalar Dual-Issue (B) y, para la entrega final, la versión Dual-Issue optimizada (C).

## Estructura

```
A_single_issue/      Pipeline Single-Issue (línea base)
  src/               RTL Verilog (top = top)
  sim/               Testbenches (tb_single_*.v de E2 + tb_prog_profesor.v)
  mem/               Programas .s y .mem
B_dual_issue/        Procesador Dual-Issue (E2)
  src/               RTL Verilog (incluye issue_unit.v y mux5.v)
  sim/               Testbenches (tb_prog*.v de E2 + tb_prog_profesor.v)
  mem/               Programas .s y .mem
programas/profesor/  Programa de evaluación del profesor (.s, .mem, enunciado PDF)
tools/
  asm.py             Ensamblador RV32I mínimo:  python3 tools/asm.py prog.s prog.mem
  modelo_isa.py      Modelo ISA de referencia:   python3 tools/modelo_isa.py prog.s
vivado/
  crear_proyecto.tcl Crea un proyecto Vivado para una de las versiones
```

Las tres versiones usan las mismas memorias: `imem` de 256 palabras (`a[9:2]`) y `dmem` de 512 palabras (`a[10:2]`). La base de datos del programa del profesor (x1 = 1536) cae en `dmem.RAM[384]`.

## Simular en Vivado

### Opción 1: script Tcl

Desde la consola Tcl de Vivado, en la raíz del repositorio:

```tcl
set argv [list B_dual_issue tb_prog_profesor]
source vivado/crear_proyecto.tcl
launch_simulation
```

Para el Single-Issue: `set argv [list A_single_issue tb_prog_profesor]`. Para otro testbench, cambia el segundo argumento (por ejemplo `tb_prog4_saltos`).

En modo batch:

```
vivado -mode batch -source vivado/crear_proyecto.tcl -tclargs B_dual_issue tb_prog_profesor
```

### Opción 2: a mano

1. Crea un proyecto RTL vacío.
2. *Design Sources*: todos los `.v` de `<version>/src`.
3. *Simulation Sources*: todos los `.v` de `<version>/sim` **y todos los `.mem` de `<version>/mem`**. Vivado copia los `.mem` al directorio de xsim; si no se agregan, `$readmemh` no los encuentra y la imem queda en 0.
4. En *Simulation Sources*, marca como top el testbench que quieras correr y lanza *Run Behavioral Simulation* → *Run All*.

## Testbench del programa del profesor (`tb_prog_profesor.v`)

Es el mismo archivo en las dos versiones; en `B_dual_issue` empieza con `` `define DUAL `` para observar la vía 2.

- **Modelo de commit:** el testbench mantiene una copia sombra del banco de registros. Se actualiza con cada instrucción que llega a WB, en orden de programa (vía 1 y luego vía 2). Así la verificación no depende de la temporización y es la misma para A, B y C.
- **Checkpoints:** cuando se retira el último `sw` de cada etapa (PC 52, 96, 224 y 352), se comparan los registros y `M[x1+0..52]` contra los estados del enunciado. Las señales `chk_A`…`chk_D` dan un pulso en ese ciclo y `ok_A`…`ok_D` quedan en 1 si la etapa es correcta (son las que se marcan en las waveforms).
- **Criterio de medición:** los ciclos se cuentan desde que baja `reset` hasta que se retira la última instrucción útil (`sw x31, 52(x1)`). El bucle `fin` queda excluido. Las instrucciones retiradas son las que llegan válidas a WB (`Instr ≠ 0`) con PC ≠ `fin`.
- Al final se imprimen ciclos, instrucciones retiradas, CPI, IPC, ciclos con load-use, saltos tomados y ciclos con dos retiros.

## Resultados del programa del profesor

| Indicador | Pipeline | Dual-Issue | Optimizado |
|---|---|---|---|
| Ciclos totales | 458 | 387 | — |
| Instrucciones retiradas | 312 | 312 | — |
| CPI | 1.468 | 1.240 | — |
| IPC | 0.681 | 0.806 | — |
| Speedup vs. pipeline | 1.00 | 1.18 | — |
| Ciclos con stall load-use | 9 | 11 | — |
| Saltos tomados resueltos en EX | 68* | 68* | — |
| Ciclos con dos retiros | 0 | 74 | — |

\* 67 saltos tomados del programa más el `jal x0, fin`, que llega a EX antes de que se retire la última instrucción.

Las dos versiones pasan los checkpoints A, B, C y D, y todos los testbenches de E2 siguen pasando con las memorias ampliadas.
