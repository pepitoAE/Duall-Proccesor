module top #(parameter MEMFILE = "riscvtest.mem")
           (input  clk, reset, 
            output [31:0] WriteData, DataAdr, 
            output MemWrite);
  
  wire [31:0] PCF, InstrF, InstrF2, ReadData; 
  
  // instantiate processor and memories
  riscvpipeline rvpipe(
    .clk(clk), 
    .reset(reset), 
    .PCF(PCF), 
    .InstrF(InstrF), 
    .InstrF2(InstrF2), 
    .MemWriteM(MemWrite), 
    .ALUResultM(DataAdr), 
    .WriteDataM(WriteData), 
    .ReadDataM(ReadData)
  ); 

  imem #(.MEMFILE(MEMFILE)) imem(
    .a(PCF), 
    .rd(InstrF),
    .rd2(InstrF2)
  ); 
  
  dmem dmem(
    .clk(clk), 
    .we(MemWrite), 
    .a(DataAdr), 
    .wd(WriteData), 
    .rd(ReadData)
  ); 
endmodule
