module hazard_unit(
                   input  [4:0] Rs1D, Rs2D,
                   input  [4:0] Rs1E, Rs2E, RdE,
                   input  PCSrcE,
                   input  ResultSrcE0,        // ResultSrcE[0] = 1 -> la instr en E es un lw
                   input  [4:0] RdM,
                   input  RegWriteM,
                   input  [4:0] RdW,
                   input  RegWriteW,
                   output reg [1:0] ForwardAE, ForwardBE,
                   output StallF, StallD,
                   output FlushD, FlushE
                   );

  wire lwStall;

  // ---------------- Forwarding ----------------
  // 10 -> se trae ALUResultM (etapa M), tiene prioridad porque es el dato mas reciente
  // 01 -> se trae ResultW (etapa W)
  // 00 -> se usa lo que se leyo del register file
  always @* begin
    if      ((Rs1E == RdM) & RegWriteM & (Rs1E != 0)) ForwardAE = 2'b10;
    else if ((Rs1E == RdW) & RegWriteW & (Rs1E != 0)) ForwardAE = 2'b01;
    else                                              ForwardAE = 2'b00;
  end

  always @* begin
    if      ((Rs2E == RdM) & RegWriteM & (Rs2E != 0)) ForwardBE = 2'b10;
    else if ((Rs2E == RdW) & RegWriteW & (Rs2E != 0)) ForwardBE = 2'b01;
    else                                              ForwardBE = 2'b00;
  end

  // ---------------- Stalling (load-use) ----------------
  // si en E hay un lw y la instr en D necesita su rd, se congela F y D y se mete una burbuja en E
  assign lwStall = ResultSrcE0 & ((Rs1D == RdE) | (Rs2D == RdE));
  assign StallF  = lwStall;
  assign StallD  = lwStall;

  // ---------------- Flushing ----------------
  // si el branch/jal se toma en E, las instrucciones en D y E son del camino incorrecto
  assign FlushD = PCSrcE;
  assign FlushE = lwStall | PCSrcE;

endmodule
