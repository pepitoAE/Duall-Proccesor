// Registro de pipeline MEM/WB (Memory -> Writeback)
module dFlipFlop4 (
                  input clk,
                  input reset,
                  // control
                  input RegWriteM,
                  input [1:0] ResultSrcM,
                  // datos
                  input [31:0] ALUResultM,
                  input [31:0] ReadDataM,
                  input [4:0]  RdM,
                  input [31:0] PCPlus4M,
                  input [31:0] InstrM,
                  // control
                  output reg RegWriteW,
                  output reg [1:0] ResultSrcW,
                  // datos
                  output reg [31:0] ALUResultW,
                  output reg [31:0] ReadDataW,
                  output reg [4:0]  RdW,
                  output reg [31:0] PCPlus4W,
                  output reg [31:0] InstrW
                  );

    always @(posedge clk or posedge reset) 
        begin
          if (reset) 
              begin
                RegWriteW  <= 0;
                ResultSrcW <= 2'b00;
                ALUResultW <= 32'b0;
                ReadDataW  <= 32'b0;
                RdW        <= 5'b0;
                PCPlus4W   <= 32'b0;
                InstrW     <= 32'b0;
              end 
          else
            begin
                RegWriteW  <= RegWriteM;
                ResultSrcW <= ResultSrcM;
                ALUResultW <= ALUResultM;
                ReadDataW  <= ReadDataM;
                RdW        <= RdM;
                PCPlus4W   <= PCPlus4M;
                InstrW     <= InstrM;
            end
        end

endmodule
