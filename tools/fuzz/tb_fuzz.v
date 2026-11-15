`timescale 1ns / 1ps
module tb_fuzz();
  reg clk, reset;
  wire [31:0] WriteData, DataAdr;
  wire MemWrite;
  integer i, f;
  top #(.MEMFILE("rand.mem")) dut(.clk(clk), .reset(reset), .WriteData(WriteData), .DataAdr(DataAdr), .MemWrite(MemWrite));
  always begin clk = 1; #5; clk = 0; #5; end
  initial begin
    reset = 1; #22; reset = 0;
    #40000;
    f = $fopen("out.txt", "w");
    for (i = 1; i < 32; i = i + 1) $fdisplay(f, "%0d", dut.rvpipe.dp.rf.rf[i]);
    for (i = 0; i < 16; i = i + 1) $fdisplay(f, "%0d", dut.dmem.RAM[i]);
    $fclose(f);
    $finish;
  end
endmodule
