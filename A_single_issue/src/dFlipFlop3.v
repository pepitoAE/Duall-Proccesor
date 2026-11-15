// Registro de pipeline EX/MEM (Execute -> Memory)
module dFlipFlop3 (
                  input clk,
                  input reset,
                  // control
                  input RegWriteE,
                  input [1:0] ResultSrcE,
                  input MemWriteE,
                  // datos
                  input [31:0] ALUResultE,
                  input [31:0] WriteDataE,
                  input [4:0]  RdE,
                  input [31:0] PCPlus4E,
                  input [31:0] InstrE,
                  // control
                  output reg RegWriteM,
                  output reg [1:0] ResultSrcM,
                  output reg MemWriteM,
                  // datos
                  output reg [31:0] ALUResultM,
                  output reg [31:0] WriteDataM,
                  output reg [4:0]  RdM,
                  output reg [31:0] PCPlus4M,
                  output reg [31:0] InstrM
                  );

    always @(posedge clk or posedge reset) 
        begin
          if (reset) 
              begin
                RegWriteM  <= 0;
                ResultSrcM <= 2'b00;
                MemWriteM  <= 0;
                ALUResultM <= 32'b0;
                WriteDataM <= 32'b0;
                RdM        <= 5'b0;
                PCPlus4M   <= 32'b0;
                InstrM     <= 32'b0;
              end 
          else
            begin
                RegWriteM  <= RegWriteE;
                ResultSrcM <= ResultSrcE;
                MemWriteM  <= MemWriteE;
                ALUResultM <= ALUResultE;
                WriteDataM <= WriteDataE;
                RdM        <= RdE;
                PCPlus4M   <= PCPlus4E;
                InstrM     <= InstrE;
            end
        end

endmodule
