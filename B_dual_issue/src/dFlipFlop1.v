// Registro de pipeline IF/ID (Fetch -> Decode)
module dFlipFlop1 (
                    input clk,
                    input reset,
                    input en,          // ~StallD
                    input clr,         // FlushD
                    input [31:0] InstrF,
                    input [31:0] PCPlus4F,
                    input [31:0] PCF,
                    output reg [31:0] InstrD,
                    output reg [31:0] PCPlus4D,
                    output reg [31:0] PCD);


    always @(posedge clk or posedge reset) 
        begin
          if (reset) 
              begin
                InstrD   <= 32'b0;
                PCPlus4D <= 32'b0;
                PCD      <= 32'b0;
              end 
          else if (clr)
              begin
                InstrD   <= 32'b0;
                PCPlus4D <= 32'b0;
                PCD      <= 32'b0;
              end
          else if (en)
            begin
                 InstrD    <= InstrF;
                 PCPlus4D  <= PCPlus4F;
                 PCD       <= PCF;
            end
        end

endmodule
