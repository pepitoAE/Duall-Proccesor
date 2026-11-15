# Procesador RISC-V RV32I Dual-Issue In-Order — Arquitectura de Computadoras (UTEC)

Proyecto 2: pipeline de 5 etapas (A), su extensión superescalar Dual-Issue (B) y la versión Dual-Issue optimizada con **BTB + predictor de 2 bits** (C).

## Estructura

```
A_single_issue/      Pipeline Single-Issue (línea base)
B_dual_issue/        Procesador Dual-Issue (E2)
C_dual_optimizado/   Dual-Issue + BTB con contador de 2 bits (EF)
  src/               RTL Verilog (top = top)
  sim/               Testbenches
  mem/               Programas .s y .mem
programas/profesor/  Programa de evaluación del profesor (.s, .mem, PDF)
programas/propio/    Programa propio del grupo (.s, .mem)
tools/
  asm.py             Ensamblador RV32I mínimo:  python3 tools/asm.py prog.s prog.mem
  modelo_isa.py      Modelo ISA de referencia:   python3 tools/modelo_isa.py prog.s
  gen_tb.py          Genera un testbench con checkpoints por etapa a partir del modelo ISA
  fuzz/              Prueba diferencial aleatoria (A, B y C contra el modelo ISA)
vivado/
  crear_proyecto.tcl Crea un proyecto Vivado para una de las versiones
```

Las tres versiones usan las mismas memorias: `imem` de 256 palabras (`a[9:2]`) y `dmem` de 512 palabras (`a[10:2]`). La base de datos del programa del profesor (x1 = 1536) cae en `dmem.RAM[384]`.

## Simular en Vivado

### Opción 1: script Tcl

Desde la consola Tcl de Vivado, en la raíz del repositorio:

```tcl
set argv [list C_dual_optimizado tb_prog_profesor]
source vivado/crear_proyecto.tcl
launch_simulation
```

El primer argumento es la versión (`A_single_issue`, `B_dual_issue` o `C_dual_optimizado`) y el segundo es el testbench top (`tb_prog_profesor`, `tb_prog6_prediccion`, `tb_prog4_saltos`, …).

En modo batch:

```
vivado -mode batch -source vivado/crear_proyecto.tcl -tclargs C_dual_optimizado tb_prog_profesor
```

### Opción 2: a mano

1. Crea un proyecto RTL vacío.
2. *Design Sources*: todos los `.v` de `<version>/src`.
3. *Simulation Sources*: todos los `.v` de `<version>/sim` **y todos los `.mem` de `<version>/mem`**. Vivado copia los `.mem` al directorio de xsim; si no se agregan, `$readmemh` no los encuentra.
4. Marca como top el testbench que quieras correr → *Run Behavioral Simulation* → *Run All*.

## Optimización: BTB + predictor de 2 bits (versión C)

**Limitación que ataca.** En B los saltos se resuelven en EX. Cada salto tomado anula F y D, es decir, hasta 4 slots de emisión. El programa del profesor tiene 67 saltos tomados en 312 instrucciones.

**Hardware agregado (`btb.v`, `flopenrc.v`, cambios en `datapath.v` y `hazard_unit.v`):**

- **BTB de 16 entradas** con mapeo directo, índice `PC[5:2]` y tag `PC[31:6]`. Cada entrada guarda `valid`, `tag`, `target` y un contador saturado de 2 bits. Tiene dos puertos de lectura en Fetch (`PCF` y `PCF+4`) y un puerto de actualización desde EX.
- **Siguiente PC en Fetch:**
  - Si el slot 1 predice tomado, el PC va a su target y el slot 2 entra a D como burbuja (`SquashF2`).
  - Si no, pero el slot 2 entra a D y predice tomado, el PC va al target del slot 2.
  - Si ninguno predice tomado, se usa PC+8 o PC+4, como en B.
- **Reagrupamiento:** cuando un salto predicho tomado se queda en la vía 2 de D, el fetch ya se fue al target. Por eso la instrucción que se reagrupa con él siempre es la del camino predicho.
- **Bits `Pred` y `PredTgt`** viajan por IF/ID e ID/EX en las dos vías (`predregD/D2/E/E2`).
- **Resolución en EX:** `MispE = salto & ((tomado ≠ predicho) | (tomado & target ≠ predicho))`. Si hubo fallo, el PC se corrige al target o a PC+4 del salto. `FlushD`, `FlushE` y `FlushM2` dependen de `MispE` en vez de `PCSrcE`.
- **Actualización de la BTB:** se crea la entrada solo si el salto se tomó (`beq` empieza en 10, `jal` en 11). Si la entrada ya existe, el contador sube o baja con saturación.

**Prueba específica:** `tb_prog6_prediccion` (en B y C) es un lazo de 10 iteraciones con un salto que alterna T/NT. El salto del lazo se predice bien (2 fallos en 10: frío y salida) y el alternante falla las 10 veces. Las señales `PredF1`, `PredF2`, `SquashF2`, `PredBrE`, `TomadoE` y `MispE` se ven en la waveform.

## Testbench del programa del profesor (`tb_prog_profesor.v`)

- **Modelo de commit:** el testbench mantiene una copia sombra del banco de registros. Se actualiza con cada instrucción que llega a WB, en orden de programa (vía 1 y luego vía 2). La verificación no depende de la temporización y es la misma para A, B y C.
- **Checkpoints:** cuando se retira el último `sw` de cada etapa (PC 52, 96, 224 y 352), se comparan los registros y `M[x1+0..52]` con los estados del enunciado. `chk_A`…`chk_D` dan un pulso en ese ciclo y `ok_A`…`ok_D` quedan en 1 si la etapa es correcta.
- **Criterio de medición:** los ciclos se cuentan desde que baja `reset` hasta que se retira la última instrucción útil (`sw x31, 52(x1)`). El bucle `fin` queda excluido. Las instrucciones retiradas son las que llegan válidas a WB con PC ≠ `fin`.
- `` `define DUAL `` activa la vía 2 y `` `define OPT `` las métricas del predictor (ya vienen al inicio del archivo en cada carpeta).

## Resultados — programa del profesor

| Indicador | Pipeline | Dual-Issue | Optimizado |
|---|---|---|---|
| Ciclos totales | 458 | 387 | 292 |
| Instrucciones retiradas | 312 | 312 | 312 |
| CPI | 1.468 | 1.240 | 0.936 |
| IPC | 0.681 | 0.806 | 1.068 |
| Speedup vs. pipeline | 1.00 | 1.18 | 1.57 |
| Speedup vs. dual-issue | — | 1.00 | 1.33 |
| Ciclos con stall load-use | 9 | 11 | 12 |
| Flushes por salto | 68 | 68 | 33 |
| Ciclos con dos retiros | 0 | 74 | 99 |

Los flushes incluyen el `jal x0, fin`, que llega a EX antes de que se retire la última instrucción. En C, de 90 saltos resueltos, 33 fallan (precisión del 63.3 %).

### Fallos de predicción por salto (versión C)

| PC | Salto | Ejecutado | Tomado | Fallos | Causa |
|---|---|---|---|---|---|
| 124 | `beq x25,x2,C1` | 12 | 11 | 2 | Arranque en frío y salida del lazo |
| 148 | `beq x23,x2,C2a` | 12 | 6 | **12** | Patrón alternante T/NT: el contador oscila entre 01 y 10 |
| 156 | `jal x0,C2b` | 6 | 6 | 1 | Arranque en frío |
| 172 | `beq x25,x2,C2` | 12 | 11 | 2 | Arranque en frío y salida |
| 196 | `beq x25,x2,C3a` | 12 | 6 | 3 | 6 T y luego 6 NT: falla en la transición |
| 204 | `jal x0,C3b` | 6 | 6 | 1 | Arranque en frío |
| 220 | `beq x25,x2,C3` | 12 | 11 | 2 | Arranque en frío y salida |
| 264 | `beq x25,x2,D2` | 6 | 2 | 4 | Patrón irregular (depende de los datos) |
| 284 | `beq x25,x2,D1` | 6 | 5 | 2 | Arranque en frío y salida |
| 300–356 | Saltos de D3–D6 y `fin` | 1 c/u | — | 4 | Se ejecutan una sola vez: fallo obligatorio |

## Programa propio (`prog_propio.s`, `tb_prog_propio.v`)

El arreglo `A[16]` vive en 1024, `B` en 1088, `C` en 1152 y los resultados en 1216. Tiene 4 etapas con un checkpoint al final de cada una (`chk[0..3]`, `ok[0..3]`):

1. **Inicialización con software pipelining:** se intercalan `addi` de la siguiente constante con el `sw` de la anterior, así cada par (ALU + store) sale junto.
2. **Recorrido con salto dependiente de datos:** `B[i] = A[i] + i`, suma total y conteo de `A[i] > 7`. El patrón del salto es irregular (N N T T N T N T N T N T T N T N): es el caso difícil para el predictor.
3. **Suma vectorial desenrollada ×2:** `C = A + B` con dos cadenas independientes por iteración (más ILP, salto del lazo predecible).
4. **Lazos anidados 4×4:** suma por filas de `C` y máximo. El salto interno falla una vez por cada salida.

Estado final: suma = 120, conteo = 8, filas de C = 68, 82, 104, 106 y máximo = 106.

| Indicador | Pipeline | Dual-Issue | Optimizado |
|---|---|---|---|
| Ciclos totales | 583 | 437 | 373 |
| Instrucciones retiradas | 490 | 490 | 490 |
| CPI | 1.190 | 0.892 | 0.761 |
| IPC | 0.840 | 1.121 | 1.314 |
| Speedup vs. pipeline | 1.00 | 1.33 | 1.56 |
| Speedup vs. dual-issue | — | 1.00 | 1.17 |
| Ciclos con stall load-use | 0 | 48 | 41 |
| Flushes por salto | 46 | 46 | 25 |
| Ciclos con dos retiros | 0 | 195 | 209 |

Cota con predictor perfecto y las mismas reglas de emisión: unos 324 ciclos (CPI ≈ 0.66).

| PC | Salto | Ejecutado | Tomado | Fallos |
|---|---|---|---|---|
| 208 | `beq x22,x0,L2s` (A[i] > 7) | 16 | 8 | 13 |
| 220 | `beq x23,x15,L2` | 16 | 15 | 2 |
| 304 | `beq x23,x15,L3` | 8 | 7 | 2 |
| 356 | `beq x23,x15,L4i` (interno) | 16 | 12 | 5 |
| 368 | `beq x29,x0,L4n` | 4 | 0 | 0 |
| 388 | `beq x23,x15,L4o` (externo) | 4 | 3 | 2 |
| 400 | `jal x0,fin` | 1 | 1 | 1 |

En el single-issue no hay stalls load-use porque el consumidor del `lw` está a 2 instrucciones. En el dual-issue esas 2 instrucciones caen en ciclos consecutivos, así que el `lw` y su consumidor quedan en paquetes contiguos y aparece la burbuja: la distancia que basta en un pipeline escalar no basta con emisión doble.

## Verificación

- Las tres versiones pasan los checkpoints A–D del programa del profesor (312 instrucciones) y los 4 del programa propio (490 instrucciones).
- Los testbenches de E2 pasan en B y C, y los `tb_single_*` en A.
- `tools/fuzz/correr.sh 400` genera 400 programas aleatorios (lazos anidados, saltos hacia adelante, `jal`, load-use, conflictos de memoria) y compara el estado final de A, B y C con el modelo ISA: 0 fallos. Requiere Icarus Verilog y Python 3.
