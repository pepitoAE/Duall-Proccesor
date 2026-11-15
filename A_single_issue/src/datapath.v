module datapath(input  clk, reset,
                // control que sale del controller en la etapa D
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
                // Fetch
                output [31:0] PCF,
                input  [31:0] InstrF,
                output [31:0] InstrD,
                input  [31:0] InstrF2,
                output [31:0] InstrD2,
                // Memory
                output MemWriteM,
                output [31:0] ALUResultM, WriteDataM, 
                input  [31:0] ReadDataM,
                // hazard unit
                input  StallF, StallD, FlushD, FlushE,
                input  [1:0] ForwardAE, ForwardBE,
                output [4:0] Rs1D, Rs2D, Rs1E, Rs2E, RdE,
                output PCSrcE, ResultSrcE0,
                output [4:0] RdM,
                output RegWriteM,
                output [4:0] RdW,
                output RegWriteW);
  
  localparam WIDTH = 32;

  // ---- senales F ----
  wire [31:0] PCNextF, PCPlus4F;
  // ---- senales D ----
  wire [31:0] PCD, PCPlus4D;
  wire [31:0] RD1D, RD2D, ImmExtD;
  wire [4:0]  RdD;
  // ---- senales E ----
  wire        RegWriteE, MemWriteE, JumpE, BranchE, ALUSrcE, ZeroE;
  wire [1:0]  ResultSrcE;
  wire [2:0]  ALUControlE;
  wire [31:0] RD1E, RD2E, PCE, ImmExtE, PCPlus4E, InstrE;
  wire [31:0] SrcAE, SrcBE, WriteDataE, ALUResultE, PCTargetE;
  // ---- senales M ----
  wire [1:0]  ResultSrcM;
  wire [31:0] PCPlus4M, InstrM;
  // ---- senales W ----
  wire [1:0]  ResultSrcW;
  wire [31:0] ALUResultW, ReadDataW, PCPlus4W, InstrW, ResultW;

  // ---- senales de la via 2 ----
  wire [31:0] PCPlus8F;
  wire [31:0] PCD2, PCPlus4D2;
  wire [31:0] RD1D2, RD2D2, ImmExtD2;
  wire [4:0]  Rs1D2, Rs2D2, RdD2;
  wire        RegWriteE2, MemWriteE2, JumpE2, BranchE2, ALUSrcE2, ZeroE2;
  wire [1:0]  ResultSrcE2;
  wire [2:0]  ALUControlE2;
  wire [31:0] RD1E2, RD2E2, PCE2, ImmExtE2, PCPlus4E2, InstrE2;
  wire [4:0]  Rs1E2, Rs2E2, RdE2;
  wire [31:0] SrcBE2, ALUResultE2;

  // la via 2 todavia NO emite: falta la Issue Unit (segunda entrega).
  // por ahora su registro ID/EX se limpia siempre y solo avanza la via 1
  wire EmiteVia2;
  assign EmiteVia2 = 1'b0;

  // =========================== FETCH ===========================
  mux2 #(WIDTH)  pcmux(
    .d0(PCPlus4F), 
    .d1(PCTargetE), 
    .s(PCSrcE), 
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

  // via 2: la instruccion de PC + 4
  adder       pcadd8(
    .a(PCF), 
    .b(32'd8),
    .y(PCPlus8F)
  ); 

  // ======================= registro IF/ID ======================
  dFlipFlop1 regD(
    .clk(clk),
    .reset(reset),
    .en(~StallD),
    .clr(FlushD),
    .InstrF(InstrF),
    .PCPlus4F(PCPlus4F),
    .PCF(PCF),
    .InstrD(InstrD),
    .PCPlus4D(PCPlus4D),
    .PCD(PCD)
  );

  // registro IF/ID de la via 2 (mismo modulo, su PC es PCF + 4)
  dFlipFlop1 regD2(
    .clk(clk),
    .reset(reset),
    .en(~StallD),
    .clr(FlushD),
    .InstrF(InstrF2),
    .PCPlus4F(PCPlus8F),
    .PCF(PCPlus4F),
    .InstrD(InstrD2),
    .PCPlus4D(PCPlus4D2),
    .PCD(PCD2)
  );

  // =========================== DECODE ==========================
  assign Rs1D = InstrD[19:15];
  assign Rs2D = InstrD[24:20];
  assign RdD  = InstrD[11:7];

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
    .rd5(RD2D2)
  ); 

  extend      ext(
    .instr(InstrD[31:7]), 
    .immsrc(ImmSrcD), 
    .immext(ImmExtD)
  ); 

  // decode de la via 2
  assign Rs1D2 = InstrD2[19:15];
  assign Rs2D2 = InstrD2[24:20];
  assign RdD2  = InstrD2[11:7];

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

  // registro ID/EX de la via 2 (mismo modulo); se limpia mientras EmiteVia2 = 0
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

  // =========================== EXECUTE =========================
  // muxes de forwarding: 00 = regfile, 01 = ResultW, 10 = ALUResultM
  mux3 #(WIDTH)  faemux(
    .d0(RD1E), 
    .d1(ResultW), 
    .d2(ALUResultM), 
    .s(ForwardAE), 
    .y(SrcAE)
  ); 

  mux3 #(WIDTH)  fbemux(
    .d0(RD2E), 
    .d1(ResultW), 
    .d2(ALUResultM), 
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

  adder       pcaddbranch(
    .a(PCE), 
    .b(ImmExtE), 
    .y(PCTargetE)
  ); 

  // segunda ALU (via 2). Todavia sin forwarding: eso entra con la Issue Unit
  mux2 #(WIDTH)  srcbmux2(
    .d0(RD2E2), 
    .d1(ImmExtE2), 
    .s(ALUSrcE2), 
    .y(SrcBE2)
  ); 

  alu         alu2(
    .a(RD1E2), 
    .b(SrcBE2), 
    .alucontrol(ALUControlE2), 
    .result(ALUResultE2), 
    .zero(ZeroE2)
  ); 

  assign PCSrcE      = (BranchE & ZeroE) | JumpE;
  assign ResultSrcE0 = ResultSrcE[0];

  // ======================= registro EX/MEM =====================
  dFlipFlop3 regM(
    .clk(clk),
    .reset(reset),
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

  // =========================== MEMORY ==========================
  // la dmem esta en el top, aqui solo pasan ALUResultM, WriteDataM y ReadDataM

  // ======================= registro MEM/WB =====================
  dFlipFlop4 regW(
    .clk(clk),
    .reset(reset),
    .RegWriteM(RegWriteM),
    .ResultSrcM(ResultSrcM),
    .ALUResultM(ALUResultM),
    .ReadDataM(ReadDataM),
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

  // ========================= WRITEBACK =========================
  mux3 #(WIDTH)  resultmux(
    .d0(ALUResultW), 
    .d1(ReadDataW), 
    .d2(PCPlus4W), 
    .s(ResultSrcW), 
    .y(ResultW)
  ); 
endmodule
