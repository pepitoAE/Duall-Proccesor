// Issue Unit: decide si el par que esta en Decode sale junto (2 instrucciones)
// o si solo sale la primera (la mas antigua) y la segunda espera al ciclo siguiente.
// La via 1 siempre lleva la instruccion mas antigua del par y la via 2 la mas joven.
module issue_unit(
                  // instruccion 1 del par (via 1, la mas antigua)
                  input  RegWriteD,
                  input  [4:0] RdD,
                  input  MemWriteD,
                  input  [1:0] ResultSrcD,
                  input  BranchD, JumpD,
                  // instruccion 2 del par (via 2, la mas joven)
                  input  [4:0] Rs1D2, Rs2D2,
                  input  UsaRs1D2, UsaRs2D2,
                  input  MemWriteD2,
                  input  [1:0] ResultSrcD2,
                  input  BranchD2, JumpD2,
                  // por que no sale el par (para verlo en el waveform)
                  output RAWpar, DosMem, DosSaltos,
                  // 1 = salen las dos, 0 = solo sale la instruccion de la via 1
                  output EmiteVia2
                  );

  wire MemD, MemD2;     // la instruccion usa el puerto de memoria (lw o sw)
  wire SaltoD, SaltoD2; // la instruccion usa la unidad de saltos (beq o jal)

  assign MemD    = MemWriteD  | ResultSrcD[0];   // sw o lw (ResultSrc = 01 es lw)
  assign MemD2   = MemWriteD2 | ResultSrcD2[0];
  assign SaltoD  = BranchD  | JumpD;
  assign SaltoD2 = BranchD2 | JumpD2;

  // 1) RAW dentro del par: la segunda lee el registro que escribe la primera.
  //    No hay forwarding dentro del mismo ciclo, asi que no pueden salir juntas.
  assign RAWpar = RegWriteD & (RdD != 0) &
                  ((UsaRs1D2 & (Rs1D2 == RdD)) | (UsaRs2D2 & (Rs2D2 == RdD)));

  // 2) solo hay un puerto de memoria de datos
  assign DosMem = MemD & MemD2;

  // 3) solo hay una unidad de resolucion de saltos
  assign DosSaltos = SaltoD & SaltoD2;

  // si no hay ningun problema salen las dos.
  // Un lw/sw o un beq/jal puede ir en cualquiera de las dos posiciones:
  // los muxes del datapath (MemSelM y BrSelE) le dan el recurso a la via que lo pide.
  assign EmiteVia2 = ~(RAWpar | DosMem | DosSaltos);

endmodule
