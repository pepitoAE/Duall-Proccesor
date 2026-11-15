module hazard_unit(
                   // Decode (las dos instrucciones del par)
                   input  [4:0] Rs1D, Rs2D, Rs1D2, Rs2D2,
                   input  UsaRs1D, UsaRs2D, UsaRs1D2, UsaRs2D2,
                   // Execute
                   input  [4:0] Rs1E, Rs2E, RdE,
                   input  [4:0] Rs1E2, Rs2E2, RdE2,
                   input  ResultSrcE0,        // 1 -> en la via 1 de E hay un lw
                   input  ResultSrcE20,       // 1 -> en la via 2 de E hay un lw
                   input  MispE,              // la prediccion del salto en E fallo
                   input  BrSelE,             // 1 -> el salto esta en la via 2
                   // Memory
                   input  [4:0] RdM, RdM2,
                   input  RegWriteM, RegWriteM2,
                   // Writeback
                   input  [4:0] RdW, RdW2,
                   input  RegWriteW, RegWriteW2,
                   // salidas
                   output reg [2:0] ForwardAE, ForwardBE,
                   output reg [2:0] ForwardAE2, ForwardBE2,
                   output lwStall,
                   output StallF, StallD,
                   output FlushD, FlushE, FlushM2
                   );

  // ---------------- Forwarding ----------------
  // 4 productores posibles, del mas nuevo al mas viejo:
  //   100 -> ALUResultM2 (via 2 en M)   el mas nuevo: la via 2 es la mas joven del par
  //   010 -> ALUResultM  (via 1 en M)
  //   011 -> ResultW2    (via 2 en W)
  //   001 -> ResultW     (via 1 en W)
  //   000 -> lo que se leyo del register file
  // los codigos 000, 001 y 010 son los mismos de la E1
  always @* begin
    if      ((Rs1E == RdM2) & RegWriteM2 & (Rs1E != 0)) ForwardAE = 3'b100;
    else if ((Rs1E == RdM)  & RegWriteM  & (Rs1E != 0)) ForwardAE = 3'b010;
    else if ((Rs1E == RdW2) & RegWriteW2 & (Rs1E != 0)) ForwardAE = 3'b011;
    else if ((Rs1E == RdW)  & RegWriteW  & (Rs1E != 0)) ForwardAE = 3'b001;
    else                                                ForwardAE = 3'b000;
  end

  always @* begin
    if      ((Rs2E == RdM2) & RegWriteM2 & (Rs2E != 0)) ForwardBE = 3'b100;
    else if ((Rs2E == RdM)  & RegWriteM  & (Rs2E != 0)) ForwardBE = 3'b010;
    else if ((Rs2E == RdW2) & RegWriteW2 & (Rs2E != 0)) ForwardBE = 3'b011;
    else if ((Rs2E == RdW)  & RegWriteW  & (Rs2E != 0)) ForwardBE = 3'b001;
    else                                                ForwardBE = 3'b000;
  end

  always @* begin
    if      ((Rs1E2 == RdM2) & RegWriteM2 & (Rs1E2 != 0)) ForwardAE2 = 3'b100;
    else if ((Rs1E2 == RdM)  & RegWriteM  & (Rs1E2 != 0)) ForwardAE2 = 3'b010;
    else if ((Rs1E2 == RdW2) & RegWriteW2 & (Rs1E2 != 0)) ForwardAE2 = 3'b011;
    else if ((Rs1E2 == RdW)  & RegWriteW  & (Rs1E2 != 0)) ForwardAE2 = 3'b001;
    else                                                  ForwardAE2 = 3'b000;
  end

  always @* begin
    if      ((Rs2E2 == RdM2) & RegWriteM2 & (Rs2E2 != 0)) ForwardBE2 = 3'b100;
    else if ((Rs2E2 == RdM)  & RegWriteM  & (Rs2E2 != 0)) ForwardBE2 = 3'b010;
    else if ((Rs2E2 == RdW2) & RegWriteW2 & (Rs2E2 != 0)) ForwardBE2 = 3'b011;
    else if ((Rs2E2 == RdW)  & RegWriteW  & (Rs2E2 != 0)) ForwardBE2 = 3'b001;
    else                                                  ForwardBE2 = 3'b000;
  end

  // ---------------- Stalling (load-use) ----------------
  // si hay un lw en E (en cualquier via) y alguna de las dos instrucciones de D
  // usa su registro destino, se congela F y D y se mete una burbuja en las dos vias de E
  wire usaRdE, usaRdE2;

  assign usaRdE  = (UsaRs1D  & (Rs1D  == RdE)) | (UsaRs2D  & (Rs2D  == RdE)) |
                   (UsaRs1D2 & (Rs1D2 == RdE)) | (UsaRs2D2 & (Rs2D2 == RdE));
  assign usaRdE2 = (UsaRs1D  & (Rs1D  == RdE2)) | (UsaRs2D  & (Rs2D  == RdE2)) |
                   (UsaRs1D2 & (Rs1D2 == RdE2)) | (UsaRs2D2 & (Rs2D2 == RdE2));

  assign lwStall = (ResultSrcE0  & (RdE  != 0) & usaRdE) |
                   (ResultSrcE20 & (RdE2 != 0) & usaRdE2);

  // si en el mismo ciclo falla la prediccion, lo de D es camino equivocado:
  // no se congela, porque el PC tiene que ir al destino del salto
  assign StallF = lwStall & ~MispE;
  assign StallD = lwStall & ~MispE;

  // ---------------- Flushing ----------------
  // prediccion fallida en E: lo que esta en F y D es camino equivocado
  assign FlushD  = MispE;
  assign FlushE  = lwStall | MispE;
  // si el salto mal predicho esta en la via 1, la instruccion de la via 2 que va con el
  // es mas joven y tambien se anula (no llega a M).
  // si el salto esta en la via 2, la de la via 1 es mas antigua y sigue normal
  assign FlushM2 = MispE & ~BrSelE;

endmodule
