module riscvpipeline(input  clk, reset,
                     output [31:0] PCF,
                     input  [31:0] InstrF,
                     input  [31:0] InstrF2,
                     output MemWriteM,
                     output [31:0] ALUResultM, 
                     output [31:0] WriteDataM,
                     input  [31:0] ReadDataM);
  
  // senales de control en D (salen del controller)
  wire [1:0] ResultSrcD, ImmSrcD;
  wire       MemWriteD, BranchD, ALUSrcD, RegWriteD, JumpD;
  wire [2:0] ALUControlD;

  wire [31:0] InstrD;

  // senales de control en D de la via 2 (salen del controller c2)
  wire [1:0] ResultSrcD2, ImmSrcD2;
  wire       MemWriteD2, BranchD2, ALUSrcD2, RegWriteD2, JumpD2;
  wire [2:0] ALUControlD2;

  wire [31:0] InstrD2;

  // senales que van y vienen del hazard unit
  wire [4:0] Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW;
  wire       PCSrcE, ResultSrcE0, RegWriteM, RegWriteW;
  wire [1:0] ForwardAE, ForwardBE;
  wire       StallF, StallD, FlushD, FlushE;

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
    .ALUControl(ALUControlD)
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
    .ALUControl(ALUControlD2)
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
    // F
    .PCF(PCF), 
    .InstrF(InstrF),
    .InstrD(InstrD),
    .InstrF2(InstrF2),
    .InstrD2(InstrD2),
    // M
    .MemWriteM(MemWriteM),
    .ALUResultM(ALUResultM), 
    .WriteDataM(WriteDataM), 
    .ReadDataM(ReadDataM),
    // hazard unit
    .StallF(StallF), .StallD(StallD),
    .FlushD(FlushD), .FlushE(FlushE),
    .ForwardAE(ForwardAE), .ForwardBE(ForwardBE),
    .Rs1D(Rs1D), .Rs2D(Rs2D),
    .Rs1E(Rs1E), .Rs2E(Rs2E), .RdE(RdE),
    .PCSrcE(PCSrcE), .ResultSrcE0(ResultSrcE0),
    .RdM(RdM), .RegWriteM(RegWriteM),
    .RdW(RdW), .RegWriteW(RegWriteW)
  ); 

  hazard_unit hu(
    .Rs1D(Rs1D), .Rs2D(Rs2D),
    .Rs1E(Rs1E), .Rs2E(Rs2E), .RdE(RdE),
    .PCSrcE(PCSrcE), .ResultSrcE0(ResultSrcE0),
    .RdM(RdM), .RegWriteM(RegWriteM),
    .RdW(RdW), .RegWriteW(RegWriteW),
    .ForwardAE(ForwardAE), .ForwardBE(ForwardBE),
    .StallF(StallF), .StallD(StallD),
    .FlushD(FlushD), .FlushE(FlushE)
  );
endmodule
