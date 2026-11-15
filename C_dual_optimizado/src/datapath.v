module datapath(input  clk, reset,
                // control que sale del controller c en la etapa D (via 1)
                input  [1:0]  ResultSrcD, 
                input  MemWriteD, BranchD, ALUSrcD,
                input  RegWriteD, JumpD,
                input  [1:0]  ImmSrcD, 
                input  [2:0]  ALUControlD,
                // control de la via 2 (sale del controller c2)
                input  [1:0]  ResultSrcD2, 
                input  MemWriteD2, BranchD2, ALUSrcD2,
                input  RegWriteD2, JumpD2,
                input  [1:0]  ImmSrcD2, 
                input  [2:0]  ALUControlD2,
                // Issue Unit: 1 = sale el par completo, 0 = solo sale la via 1
                input  EmiteVia2,
                // Fetch
                output [31:0] PCF,
                input  [31:0] InstrF,
                output [31:0] InstrD,
                input  [31:0] InstrF2,
                output [31:0] InstrD2,
                // Memory (un solo puerto de memoria de datos, compartido)
                output MemWE,
                output [31:0] MemAdr, MemWD, 
                input  [31:0] MemRD,
                // hazard unit
                input  StallF, StallD, FlushD, FlushE, FlushM2,
                input  [2:0] ForwardAE, ForwardBE,
                input  [2:0] ForwardAE2, ForwardBE2,
                output [4:0] Rs1D, Rs2D, RdD, Rs1E, Rs2E, RdE,
                output [4:0] Rs1D2, Rs2D2, Rs1E2, Rs2E2, RdE2,
                output PCSrcE, BrSelE, ResultSrcE0, ResultSrcE20,
                output MispE,
                output [4:0] RdM, RdM2,
                output RegWriteM, RegWriteM2,
                output [4:0] RdW, RdW2,
                output RegWriteW, RegWriteW2);
  
  localparam WIDTH = 32;

  // ---- senales F ----
  wire [31:0] PCNextF, PCSigF, PCPlus4F, PCPlus8F;
  // entradas de los registros IF/ID (salen de los muxes de reagrupamiento)
  wire [31:0] InstrInD, PCInD, PCPlus4InD;
  wire [31:0] InstrInD2, PCInD2, PCPlus4InD2;
  // ---- senales D ----
  wire [31:0] PCD, PCPlus4D;
  wire [31:0] RD1D, RD2D, ImmExtD;
  // ---- senales E ----
  wire        RegWriteE, MemWriteE, JumpE, BranchE, ALUSrcE, ZeroE;
  wire [1:0]  ResultSrcE;
  wire [2:0]  ALUControlE;
  wire [31:0] RD1E, RD2E, PCE, ImmExtE, PCPlus4E, InstrE;
  wire [31:0] SrcAE, SrcBE, WriteDataE, ALUResultE, PCTargetE;
  // ---- senales M ----
  wire        MemWriteM;
  wire [1:0]  ResultSrcM;
  wire [31:0] ALUResultM, WriteDataM, PCPlus4M, InstrM;
  // ---- senales W ----
  wire [1:0]  ResultSrcW;
  wire [31:0] ALUResultW, ReadDataW, PCPlus4W, InstrW, ResultW;

  // ---- senales de la via 2 ----
  wire [31:0] PCD2, PCPlus4D2;
  wire [31:0] RD1D2, RD2D2, ImmExtD2;
  wire [4:0]  RdD2;
  wire        RegWriteE2, MemWriteE2, JumpE2, BranchE2, ALUSrcE2, ZeroE2;
  wire [1:0]  ResultSrcE2;
  wire [2:0]  ALUControlE2;
  wire [31:0] RD1E2, RD2E2, PCE2, ImmExtE2, PCPlus4E2, InstrE2;
  wire [31:0] SrcAE2, SrcBE2, WriteDataE2, ALUResultE2;
  wire        MemWriteM2;
  wire [1:0]  ResultSrcM2;
  wire [31:0] ALUResultM2, WriteDataM2, PCPlus4M2, InstrM2;
  wire [1:0]  ResultSrcW2;
  wire [31:0] ALUResultW2, ReadDataW2, PCPlus4W2, InstrW2, ResultW2;

  // ---- unidad de saltos y puerto de memoria compartidos ----
  wire [31:0] PCBrE, ImmBrE;
  wire        BranchBrE, JumpBrE, ZeroBrE;
  wire        MemSelM;
  // ---- prediccion de saltos (BTB + contador de 2 bits) ----
  wire        HitF1, PredF1, HitF2, PredF2, PredSlot2F, SquashF2;
  wire [31:0] TgtF1, TgtF2, PCSeqF, PCPred2F, PCPredF, PCCorrE;
  wire [31:0] InstrSelD2;
  wire        PredInD, PredInD2, PredD, PredD2, PredE, PredE2;
  wire [31:0] TgtInD, TgtInD2, PredTgtD, PredTgtD2, PredTgtE, PredTgtE2;
  wire        PredBrE, EsSaltoE;
  wire [31:0] PredTgtBrE, PCPlus4BrE;

  // =========================== FETCH ===========================
  // si salen las dos el PC avanza 8, si solo sale una avanza 4
  btb bp(
    .clk(clk),
    .reset(reset),
    .pc1(PCF),
    .hit1(HitF1),
    .pred1(PredF1),
    .tgt1(TgtF1),
    .pc2(PCPlus4F),
    .hit2(HitF2),
    .pred2(PredF2),
    .tgt2(TgtF2),
    .we(EsSaltoE),
    .pcE(PCBrE),
    .tomadoE(PCSrcE),
    .jumpE(JumpBrE),
    .tgtE(PCTargetE)
  );

  assign SquashF2   = EmiteVia2 & PredF1;
  assign PredSlot2F = EmiteVia2 & ~PredF1 & PredF2;

  mux2 #(WIDTH)  pcseqmux(
    .d0(PCPlus4F), 
    .d1(PCPlus8F), 
    .s(EmiteVia2), 
    .y(PCSeqF)
  ); 

  mux2 #(WIDTH)  pcpred2mux(
    .d0(PCSeqF), 
    .d1(TgtF2), 
    .s(PredSlot2F), 
    .y(PCPred2F)
  ); 

  mux2 #(WIDTH)  pcpredmux(
    .d0(PCPred2F), 
    .d1(TgtF1), 
    .s(PredF1), 
    .y(PCSigF)
  ); 

  // salto tomado (de cualquiera de las dos vias)
  mux2 #(WIDTH)  pcmux(
    .d0(PCSigF), 
    .d1(PCCorrE), 
    .s(MispE), 
    .y(PCNextF)
  ); 

  flopenr #(WIDTH) pcreg(
    .clk(clk), 
    .reset(reset), 
    .en(~StallF),
    .d(PCNextF), 
    .q(PCF)
  ); 

  adder       pcadd4(
    .a(PCF), 
    .b(32'd4),
    .y(PCPlus4F)
  ); 

  adder       pcadd8(
    .a(PCF), 
    .b(32'd8),
    .y(PCPlus8F)
  ); 

  // ================= reagrupamiento (antes de IF/ID) =================
  // EmiteVia2 = 1: el par nuevo es lo que se acaba de traer (PCF y PCF + 4)
  // EmiteVia2 = 0: la instruccion de la via 2 que no salio pasa a la via 1
  //                y la de PCF pasa a la via 2 (asi no se pierde ni se repite nada)
  mux2 #(WIDTH)  instrmuxD(
    .d0(InstrD2), 
    .d1(InstrF), 
    .s(EmiteVia2), 
    .y(InstrInD)
  ); 

  mux2 #(WIDTH)  pcmuxD(
    .d0(PCD2), 
    .d1(PCF), 
    .s(EmiteVia2), 
    .y(PCInD)
  ); 

  mux2 #(WIDTH)  pc4muxD(
    .d0(PCPlus4D2), 
    .d1(PCPlus4F), 
    .s(EmiteVia2), 
    .y(PCPlus4InD)
  ); 

  mux2 #(WIDTH)  instrmuxD2(
    .d0(InstrF), 
    .d1(InstrF2), 
    .s(EmiteVia2), 
    .y(InstrSelD2)
  ); 

  mux2 #(WIDTH)  squashmuxD2(
    .d0(InstrSelD2), 
    .d1(32'b0), 
    .s(SquashF2), 
    .y(InstrInD2)
  ); 

  assign PredInD  = EmiteVia2 ? PredF1 : PredD2;
  assign TgtInD   = EmiteVia2 ? TgtF1  : PredTgtD2;
  assign PredInD2 = EmiteVia2 ? PredSlot2F : PredF1;
  assign TgtInD2  = EmiteVia2 ? TgtF2      : TgtF1;

  mux2 #(WIDTH)  pcmuxD2(
    .d0(PCF), 
    .d1(PCPlus4F), 
    .s(EmiteVia2), 
    .y(PCInD2)
  ); 

  mux2 #(WIDTH)  pc4muxD2(
    .d0(PCPlus4F), 
    .d1(PCPlus8F), 
    .s(EmiteVia2), 
    .y(PCPlus4InD2)
  ); 

  // ======================= registro IF/ID ======================
  dFlipFlop1 regD(
    .clk(clk),
    .reset(reset),
    .en(~StallD),
    .clr(FlushD),
    .InstrF(InstrInD),
    .PCPlus4F(PCPlus4InD),
    .PCF(PCInD),
    .InstrD(InstrD),
    .PCPlus4D(PCPlus4D),
    .PCD(PCD)
  );

  dFlipFlop1 regD2(
    .clk(clk),
    .reset(reset),
    .en(~StallD),
    .clr(FlushD),
    .InstrF(InstrInD2),
    .PCPlus4F(PCPlus4InD2),
    .PCF(PCInD2),
    .InstrD(InstrD2),
    .PCPlus4D(PCPlus4D2),
    .PCD(PCD2)
  );

  flopenrc #(33) predregD(
    .clk(clk),
    .reset(reset),
    .en(~StallD),
    .clr(FlushD),
    .d({PredInD, TgtInD}),
    .q({PredD, PredTgtD})
  );

  flopenrc #(33) predregD2(
    .clk(clk),
    .reset(reset),
    .en(~StallD),
    .clr(FlushD),
    .d({PredInD2, TgtInD2}),
    .q({PredD2, PredTgtD2})
  );

  // =========================== DECODE ==========================
  assign Rs1D = InstrD[19:15];
  assign Rs2D = InstrD[24:20];
  assign RdD  = InstrD[11:7];

  assign Rs1D2 = InstrD2[19:15];
  assign Rs2D2 = InstrD2[24:20];
  assign RdD2  = InstrD2[11:7];

  // 4 lecturas (2 por via) y 2 escrituras (1 por via)
  regfile     rf(
    .clk(clk), 
    .we3(RegWriteW), 
    .a1(Rs1D), 
    .a2(Rs2D), 
    .a3(RdW), 
    .wd3(ResultW), 
    .rd1(RD1D), 
    .rd2(RD2D),
    .a4(Rs1D2), 
    .a5(Rs2D2), 
    .rd4(RD1D2), 
    .rd5(RD2D2),
    .we6(RegWriteW2), 
    .a6(RdW2), 
    .wd6(ResultW2)
  ); 

  extend      ext(
    .instr(InstrD[31:7]), 
    .immsrc(ImmSrcD), 
    .immext(ImmExtD)
  ); 

  extend      ext2(
    .instr(InstrD2[31:7]), 
    .immsrc(ImmSrcD2), 
    .immext(ImmExtD2)
  ); 

  // ======================= registro ID/EX ======================
  dFlipFlop2 regE(
    .clk(clk),
    .reset(reset),
    .clr(FlushE),
    .RegWriteD(RegWriteD),
    .ResultSrcD(ResultSrcD),
    .MemWriteD(MemWriteD),
    .JumpD(JumpD),
    .BranchD(BranchD),
    .ALUControlD(ALUControlD),
    .ALUSrcD(ALUSrcD),
    .RD1D(RD1D),
    .RD2D(RD2D),
    .PCD(PCD),
    .Rs1D(Rs1D),
    .Rs2D(Rs2D),
    .RdD(RdD),
    .ImmExtD(ImmExtD),
    .PCPlus4D(PCPlus4D),
    .InstrD(InstrD),
    .RegWriteE(RegWriteE),
    .ResultSrcE(ResultSrcE),
    .MemWriteE(MemWriteE),
    .JumpE(JumpE),
    .BranchE(BranchE),
    .ALUControlE(ALUControlE),
    .ALUSrcE(ALUSrcE),
    .RD1E(RD1E),
    .RD2E(RD2E),
    .PCE(PCE),
    .Rs1E(Rs1E),
    .Rs2E(Rs2E),
    .RdE(RdE),
    .ImmExtE(ImmExtE),
    .PCPlus4E(PCPlus4E),
    .InstrE(InstrE)
  );

  // si la Issue Unit no deja salir la via 2, aqui entra una burbuja
  // (la instruccion no se pierde: se queda en D como via 1 del par siguiente)
  dFlipFlop2 regE2(
    .clk(clk),
    .reset(reset),
    .clr(FlushE | ~EmiteVia2),
    .RegWriteD(RegWriteD2),
    .ResultSrcD(ResultSrcD2),
    .MemWriteD(MemWriteD2),
    .JumpD(JumpD2),
    .BranchD(BranchD2),
    .ALUControlD(ALUControlD2),
    .ALUSrcD(ALUSrcD2),
    .RD1D(RD1D2),
    .RD2D(RD2D2),
    .PCD(PCD2),
    .Rs1D(Rs1D2),
    .Rs2D(Rs2D2),
    .RdD(RdD2),
    .ImmExtD(ImmExtD2),
    .PCPlus4D(PCPlus4D2),
    .InstrD(InstrD2),
    .RegWriteE(RegWriteE2),
    .ResultSrcE(ResultSrcE2),
    .MemWriteE(MemWriteE2),
    .JumpE(JumpE2),
    .BranchE(BranchE2),
    .ALUControlE(ALUControlE2),
    .ALUSrcE(ALUSrcE2),
    .RD1E(RD1E2),
    .RD2E(RD2E2),
    .PCE(PCE2),
    .Rs1E(Rs1E2),
    .Rs2E(Rs2E2),
    .RdE(RdE2),
    .ImmExtE(ImmExtE2),
    .PCPlus4E(PCPlus4E2),
    .InstrE(InstrE2)
  );

  flopenrc #(33) predregE(
    .clk(clk),
    .reset(reset),
    .en(1'b1),
    .clr(FlushE),
    .d({PredD, PredTgtD}),
    .q({PredE, PredTgtE})
  );

  flopenrc #(33) predregE2(
    .clk(clk),
    .reset(reset),
    .en(1'b1),
    .clr(FlushE | ~EmiteVia2),
    .d({PredD2, PredTgtD2}),
    .q({PredE2, PredTgtE2})
  );

  // =========================== EXECUTE =========================
  // muxes de forwarding (5 entradas):
  // 000 = regfile, 001 = ResultW, 010 = ALUResultM, 011 = ResultW2, 100 = ALUResultM2
  mux5 #(WIDTH)  faemux(
    .d0(RD1E), 
    .d1(ResultW), 
    .d2(ALUResultM), 
    .d3(ResultW2), 
    .d4(ALUResultM2), 
    .s(ForwardAE), 
    .y(SrcAE)
  ); 

  mux5 #(WIDTH)  fbemux(
    .d0(RD2E), 
    .d1(ResultW), 
    .d2(ALUResultM), 
    .d3(ResultW2), 
    .d4(ALUResultM2), 
    .s(ForwardBE), 
    .y(WriteDataE)
  ); 

  mux2 #(WIDTH)  srcbmux(
    .d0(WriteDataE), 
    .d1(ImmExtE), 
    .s(ALUSrcE), 
    .y(SrcBE)
  ); 

  alu         alu(
    .a(SrcAE), 
    .b(SrcBE), 
    .alucontrol(ALUControlE), 
    .result(ALUResultE), 
    .zero(ZeroE)
  ); 

  // via 2: mismos muxes de forwarding
  mux5 #(WIDTH)  faemux2(
    .d0(RD1E2), 
    .d1(ResultW), 
    .d2(ALUResultM), 
    .d3(ResultW2), 
    .d4(ALUResultM2), 
    .s(ForwardAE2), 
    .y(SrcAE2)
  ); 

  mux5 #(WIDTH)  fbemux2(
    .d0(RD2E2), 
    .d1(ResultW), 
    .d2(ALUResultM), 
    .d3(ResultW2), 
    .d4(ALUResultM2), 
    .s(ForwardBE2), 
    .y(WriteDataE2)
  ); 

  mux2 #(WIDTH)  srcbmux2(
    .d0(WriteDataE2), 
    .d1(ImmExtE2), 
    .s(ALUSrcE2), 
    .y(SrcBE2)
  ); 

  alu         alu2(
    .a(SrcAE2), 
    .b(SrcBE2), 
    .alucontrol(ALUControlE2), 
    .result(ALUResultE2), 
    .zero(ZeroE2)
  ); 

  // ---- unidad de saltos compartida ----
  // la Issue Unit asegura que en E hay como maximo un beq/jal.
  // BrSelE = 1 -> el salto esta en la via 2
  assign BrSelE = BranchE2 | JumpE2;

  mux2 #(WIDTH)  pcbrmux(
    .d0(PCE), 
    .d1(PCE2), 
    .s(BrSelE), 
    .y(PCBrE)
  ); 

  mux2 #(WIDTH)  immbrmux(
    .d0(ImmExtE), 
    .d1(ImmExtE2), 
    .s(BrSelE), 
    .y(ImmBrE)
  ); 

  adder       pcaddbranch(
    .a(PCBrE), 
    .b(ImmBrE), 
    .y(PCTargetE)
  ); 

  assign BranchBrE = BrSelE ? BranchE2 : BranchE;
  assign JumpBrE   = BrSelE ? JumpE2   : JumpE;
  assign ZeroBrE   = BrSelE ? ZeroE2   : ZeroE;

  assign PCSrcE       = (BranchBrE & ZeroBrE) | JumpBrE;
  assign EsSaltoE   = BranchBrE | JumpBrE;
  assign PredBrE    = BrSelE ? PredE2    : PredE;
  assign PredTgtBrE = BrSelE ? PredTgtE2 : PredTgtE;
  assign PCPlus4BrE = BrSelE ? PCPlus4E2 : PCPlus4E;
  assign MispE      = EsSaltoE & ((PCSrcE != PredBrE) | (PCSrcE & (PCTargetE != PredTgtBrE)));

  mux2 #(WIDTH)  pccorrmux(
    .d0(PCPlus4BrE), 
    .d1(PCTargetE), 
    .s(PCSrcE), 
    .y(PCCorrE)
  ); 

  assign ResultSrcE0  = ResultSrcE[0];
  assign ResultSrcE20 = ResultSrcE2[0];

  // ======================= registro EX/MEM =====================
  dFlipFlop3 regM(
    .clk(clk),
    .reset(reset),
    .clr(1'b0),
    .RegWriteE(RegWriteE),
    .ResultSrcE(ResultSrcE),
    .MemWriteE(MemWriteE),
    .ALUResultE(ALUResultE),
    .WriteDataE(WriteDataE),
    .RdE(RdE),
    .PCPlus4E(PCPlus4E),
    .InstrE(InstrE),
    .RegWriteM(RegWriteM),
    .ResultSrcM(ResultSrcM),
    .MemWriteM(MemWriteM),
    .ALUResultM(ALUResultM),
    .WriteDataM(WriteDataM),
    .RdM(RdM),
    .PCPlus4M(PCPlus4M),
    .InstrM(InstrM)
  );

  // FlushM2: salto tomado en la via 1 -> la de la via 2 es mas joven y se anula
  dFlipFlop3 regM2(
    .clk(clk),
    .reset(reset),
    .clr(FlushM2),
    .RegWriteE(RegWriteE2),
    .ResultSrcE(ResultSrcE2),
    .MemWriteE(MemWriteE2),
    .ALUResultE(ALUResultE2),
    .WriteDataE(WriteDataE2),
    .RdE(RdE2),
    .PCPlus4E(PCPlus4E2),
    .InstrE(InstrE2),
    .RegWriteM(RegWriteM2),
    .ResultSrcM(ResultSrcM2),
    .MemWriteM(MemWriteM2),
    .ALUResultM(ALUResultM2),
    .WriteDataM(WriteDataM2),
    .RdM(RdM2),
    .PCPlus4M(PCPlus4M2),
    .InstrM(InstrM2)
  );

  // =========================== MEMORY ==========================
  // un solo puerto: la Issue Unit asegura que en M hay como maximo un lw/sw.
  // MemSelM = 1 -> el acceso a memoria es de la via 2
  assign MemSelM = MemWriteM2 | ResultSrcM2[0];
  assign MemWE   = MemWriteM | MemWriteM2;

  mux2 #(WIDTH)  memadrmux(
    .d0(ALUResultM), 
    .d1(ALUResultM2), 
    .s(MemSelM), 
    .y(MemAdr)
  ); 

  mux2 #(WIDTH)  memwdmux(
    .d0(WriteDataM), 
    .d1(WriteDataM2), 
    .s(MemSelM), 
    .y(MemWD)
  ); 

  // ======================= registro MEM/WB =====================
  // el dato leido (MemRD) llega a las dos vias; solo lo usa la que hizo el lw
  dFlipFlop4 regW(
    .clk(clk),
    .reset(reset),
    .RegWriteM(RegWriteM),
    .ResultSrcM(ResultSrcM),
    .ALUResultM(ALUResultM),
    .ReadDataM(MemRD),
    .RdM(RdM),
    .PCPlus4M(PCPlus4M),
    .InstrM(InstrM),
    .RegWriteW(RegWriteW),
    .ResultSrcW(ResultSrcW),
    .ALUResultW(ALUResultW),
    .ReadDataW(ReadDataW),
    .RdW(RdW),
    .PCPlus4W(PCPlus4W),
    .InstrW(InstrW)
  );

  dFlipFlop4 regW2(
    .clk(clk),
    .reset(reset),
    .RegWriteM(RegWriteM2),
    .ResultSrcM(ResultSrcM2),
    .ALUResultM(ALUResultM2),
    .ReadDataM(MemRD),
    .RdM(RdM2),
    .PCPlus4M(PCPlus4M2),
    .InstrM(InstrM2),
    .RegWriteW(RegWriteW2),
    .ResultSrcW(ResultSrcW2),
    .ALUResultW(ALUResultW2),
    .ReadDataW(ReadDataW2),
    .RdW(RdW2),
    .PCPlus4W(PCPlus4W2),
    .InstrW(InstrW2)
  );

  // ========================= WRITEBACK =========================
  mux3 #(WIDTH)  resultmux(
    .d0(ALUResultW), 
    .d1(ReadDataW), 
    .d2(PCPlus4W), 
    .s(ResultSrcW), 
    .y(ResultW)
  ); 

  mux3 #(WIDTH)  resultmux2(
    .d0(ALUResultW2), 
    .d1(ReadDataW2), 
    .d2(PCPlus4W2), 
    .s(ResultSrcW2), 
    .y(ResultW2)
  ); 
endmodule
