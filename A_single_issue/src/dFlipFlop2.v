// Registro de pipeline ID/EX (Decode -> Execute)
module dFlipFlop2 (
                  input clk,
                  input reset,
                  input clr,                 // FlushE
                  // control
                  input RegWriteD,
                  input [1:0] ResultSrcD, 
                  input MemWriteD,
                  input JumpD, BranchD,
                  input [2:0] ALUControlD,
                  input ALUSrcD,
                  // datos
                  input [31:0] RD1D, RD2D,
                  input [31:0] PCD,
                  input [4:0]  Rs1D, Rs2D, RdD,
                  input [31:0] ImmExtD,
                  input [31:0] PCPlus4D,
                  input [31:0] InstrD,
                  // control
                  output reg RegWriteE,
                  output reg [1:0] ResultSrcE, 
                  output reg MemWriteE,
                  output reg JumpE, BranchE,
                  output reg [2:0] ALUControlE,
                  output reg ALUSrcE,
                  // datos
                  output reg [31:0] RD1E, RD2E,
                  output reg [31:0] PCE,
                  output reg [4:0]  Rs1E, Rs2E, RdE,
                  output reg [31:0] ImmExtE,
                  output reg [31:0] PCPlus4E,
                  output reg [31:0] InstrE
                  );

    always @(posedge clk or posedge reset) 
        begin
          if (reset) 
              begin
                RegWriteE   <= 0;
                ResultSrcE  <= 2'b00;
                MemWriteE   <= 0;
                JumpE       <= 0;
                BranchE     <= 0;
                ALUControlE <= 3'b000;
                ALUSrcE     <= 0;
                RD1E        <= 32'b0;
                RD2E        <= 32'b0;
                PCE         <= 32'b0;
                Rs1E        <= 5'b0;
                Rs2E        <= 5'b0;
                RdE         <= 5'b0;
                ImmExtE     <= 32'b0;
                PCPlus4E    <= 32'b0;
                InstrE      <= 32'b0;
              end 
          else if (clr)
              begin
                RegWriteE   <= 0;
                ResultSrcE  <= 2'b00;
                MemWriteE   <= 0;
                JumpE       <= 0;
                BranchE     <= 0;
                ALUControlE <= 3'b000;
                ALUSrcE     <= 0;
                RD1E        <= 32'b0;
                RD2E        <= 32'b0;
                PCE         <= 32'b0;
                Rs1E        <= 5'b0;
                Rs2E        <= 5'b0;
                RdE         <= 5'b0;
                ImmExtE     <= 32'b0;
                PCPlus4E    <= 32'b0;
                InstrE      <= 32'b0;
              end 
          else
            begin
                RegWriteE   <= RegWriteD;
                ResultSrcE  <= ResultSrcD;
                MemWriteE   <= MemWriteD;
                JumpE       <= JumpD;
                BranchE     <= BranchD;
                ALUControlE <= ALUControlD;
                ALUSrcE     <= ALUSrcD;
                RD1E        <= RD1D;
                RD2E        <= RD2D;
                PCE         <= PCD;
                Rs1E        <= Rs1D;
                Rs2E        <= Rs2D;
                RdE         <= RdD;
                ImmExtE     <= ImmExtD;
                PCPlus4E    <= PCPlus4D;
                InstrE      <= InstrD;
            end
        end
        
endmodule
