module riscvpipeline(input  clk, reset,
                     output [31:0] PCF,
                     input  [31:0] InstrF,
                     input  [31:0] InstrF2,
                     // puerto unico de memoria de datos
                     output MemWE,
                     output [31:0] MemAdr, 
                     output [31:0] MemWD,
                     input  [31:0] MemRD);
  
  // senales de control en D de la via 1 (salen del controller c)
  wire [1:0] ResultSrcD, ImmSrcD;
  wire       MemWriteD, BranchD, ALUSrcD, RegWriteD, JumpD;
  wire [2:0] ALUControlD;
  wire       UsaRs1D, UsaRs2D;

  wire [31:0] InstrD;

  // senales de control en D de la via 2 (salen del controller c2)
  wire [1:0] ResultSrcD2, ImmSrcD2;
  wire       MemWriteD2, BranchD2, ALUSrcD2, RegWriteD2, JumpD2;
  wire [2:0] ALUControlD2;
  wire       UsaRs1D2, UsaRs2D2;

  wire [31:0] InstrD2;

  // Issue Unit
  wire       RAWpar, DosMem, DosSaltos, EmiteVia2;

  // senales que van y vienen del hazard unit
  wire [4:0] Rs1D, Rs2D, RdD, Rs1E, Rs2E, RdE, RdM, RdW;
  wire [4:0] Rs1D2, Rs2D2, Rs1E2, Rs2E2, RdE2, RdM2, RdW2;
  wire       PCSrcE, BrSelE, ResultSrcE0, ResultSrcE20;
  wire       RegWriteM, RegWriteW, RegWriteM2, RegWriteW2;
  wire [2:0] ForwardAE, ForwardBE, ForwardAE2, ForwardBE2;
  wire       lwStall, StallF, StallD, FlushD, FlushE, FlushM2;

  controller c(
    .op(InstrD[6:0]), 
    .funct3(InstrD[14:12]), 
    .funct7b5(InstrD[30]), 
    .ResultSrc(ResultSrcD), 
    .MemWrite(MemWriteD), 
    .Branch(BranchD),
    .ALUSrc(ALUSrcD), 
    .RegWrite(RegWriteD), 
    .Jump(JumpD),
    .ImmSrc(ImmSrcD), 
    .ALUControl(ALUControlD),
    .UsaRs1(UsaRs1D),
    .UsaRs2(UsaRs2D)
  ); 
  
  // decoder de la via 2: es el mismo controller pero con InstrD2
  controller c2(
    .op(InstrD2[6:0]), 
    .funct3(InstrD2[14:12]), 
    .funct7b5(InstrD2[30]), 
    .ResultSrc(ResultSrcD2), 
    .MemWrite(MemWriteD2), 
    .Branch(BranchD2),
    .ALUSrc(ALUSrcD2), 
    .RegWrite(RegWriteD2), 
    .Jump(JumpD2),
    .ImmSrc(ImmSrcD2), 
    .ALUControl(ALUControlD2),
    .UsaRs1(UsaRs1D2),
    .UsaRs2(UsaRs2D2)
  ); 

  // decide si el par de D sale completo o solo la via 1
  issue_unit iu(
    .RegWriteD(RegWriteD),
    .RdD(RdD),
    .MemWriteD(MemWriteD),
    .ResultSrcD(ResultSrcD),
    .BranchD(BranchD),
    .JumpD(JumpD),
    .Rs1D2(Rs1D2),
    .Rs2D2(Rs2D2),
    .UsaRs1D2(UsaRs1D2),
    .UsaRs2D2(UsaRs2D2),
    .MemWriteD2(MemWriteD2),
    .ResultSrcD2(ResultSrcD2),
    .BranchD2(BranchD2),
    .JumpD2(JumpD2),
    .RAWpar(RAWpar),
    .DosMem(DosMem),
    .DosSaltos(DosSaltos),
    .EmiteVia2(EmiteVia2)
  );
  
  datapath dp(
    .clk(clk), 
    .reset(reset), 
    // control D
    .ResultSrcD(ResultSrcD), 
    .MemWriteD(MemWriteD),
    .BranchD(BranchD),
    .ALUSrcD(ALUSrcD), 
    .RegWriteD(RegWriteD),
    .JumpD(JumpD),
    .ImmSrcD(ImmSrcD), 
    .ALUControlD(ALUControlD),
    // control D via 2
    .ResultSrcD2(ResultSrcD2), 
    .MemWriteD2(MemWriteD2),
    .BranchD2(BranchD2),
    .ALUSrcD2(ALUSrcD2), 
    .RegWriteD2(RegWriteD2),
    .JumpD2(JumpD2),
    .ImmSrcD2(ImmSrcD2), 
    .ALUControlD2(ALUControlD2),
    // Issue Unit
    .EmiteVia2(EmiteVia2),
    // F
    .PCF(PCF), 
    .InstrF(InstrF),
    .InstrD(InstrD),
    .InstrF2(InstrF2),
    .InstrD2(InstrD2),
    // M (puerto unico)
    .MemWE(MemWE),
    .MemAdr(MemAdr), 
    .MemWD(MemWD), 
    .MemRD(MemRD),
    // hazard unit
    .StallF(StallF), .StallD(StallD),
    .FlushD(FlushD), .FlushE(FlushE), .FlushM2(FlushM2),
    .ForwardAE(ForwardAE), .ForwardBE(ForwardBE),
    .ForwardAE2(ForwardAE2), .ForwardBE2(ForwardBE2),
    .Rs1D(Rs1D), .Rs2D(Rs2D), .RdD(RdD),
    .Rs1E(Rs1E), .Rs2E(Rs2E), .RdE(RdE),
    .Rs1D2(Rs1D2), .Rs2D2(Rs2D2),
    .Rs1E2(Rs1E2), .Rs2E2(Rs2E2), .RdE2(RdE2),
    .PCSrcE(PCSrcE), .BrSelE(BrSelE),
    .ResultSrcE0(ResultSrcE0), .ResultSrcE20(ResultSrcE20),
    .RdM(RdM), .RdM2(RdM2),
    .RegWriteM(RegWriteM), .RegWriteM2(RegWriteM2),
    .RdW(RdW), .RdW2(RdW2),
    .RegWriteW(RegWriteW), .RegWriteW2(RegWriteW2)
  ); 

  hazard_unit hu(
    .Rs1D(Rs1D), .Rs2D(Rs2D), .Rs1D2(Rs1D2), .Rs2D2(Rs2D2),
    .UsaRs1D(UsaRs1D), .UsaRs2D(UsaRs2D),
    .UsaRs1D2(UsaRs1D2), .UsaRs2D2(UsaRs2D2),
    .Rs1E(Rs1E), .Rs2E(Rs2E), .RdE(RdE),
    .Rs1E2(Rs1E2), .Rs2E2(Rs2E2), .RdE2(RdE2),
    .ResultSrcE0(ResultSrcE0), .ResultSrcE20(ResultSrcE20),
    .PCSrcE(PCSrcE), .BrSelE(BrSelE),
    .RdM(RdM), .RdM2(RdM2),
    .RegWriteM(RegWriteM), .RegWriteM2(RegWriteM2),
    .RdW(RdW), .RdW2(RdW2),
    .RegWriteW(RegWriteW), .RegWriteW2(RegWriteW2),
    .ForwardAE(ForwardAE), .ForwardBE(ForwardBE),
    .ForwardAE2(ForwardAE2), .ForwardBE2(ForwardBE2),
    .lwStall(lwStall),
    .StallF(StallF), .StallD(StallD),
    .FlushD(FlushD), .FlushE(FlushE), .FlushM2(FlushM2)
  );
endmodule
