`define OPT
`timescale 1ns / 1ps
module tb_prog6_prediccion();

  localparam PC_FIN = 32'd60;

  reg clk;
  reg reset;
  wire [31:0] WriteData, DataAdr;
  wire MemWrite;
  integer ciclos, retiradas, fallos, saltos;
  reg terminado;

  wire [31:0] x1 = dut.rvpipe.dp.rf.rf[1];
  wire [31:0] x3 = dut.rvpipe.dp.rf.rf[3];
  wire [31:0] x4 = dut.rvpipe.dp.rf.rf[4];
  wire [31:0] x6 = dut.rvpipe.dp.rf.rf[6];
  wire [31:0] mem0 = dut.dmem.RAM[0];
  wire [31:0] mem4 = dut.dmem.RAM[1];
  wire [31:0] PCF  = dut.rvpipe.dp.PCF;
  wire [31:0] PCW1 = dut.rvpipe.dp.PCPlus4W - 32'd4;
  wire [31:0] PCW2 = dut.rvpipe.dp.PCPlus4W2 - 32'd4;
  wire        valW1 = dut.rvpipe.dp.InstrW != 0;
  wire        valW2 = dut.rvpipe.dp.InstrW2 != 0;
`ifdef OPT
  wire        PredF1   = dut.rvpipe.dp.PredF1;
  wire        PredF2   = dut.rvpipe.dp.PredF2;
  wire        SquashF2 = dut.rvpipe.dp.SquashF2;
  wire        EsSaltoE = dut.rvpipe.dp.EsSaltoE;
  wire        PredBrE  = dut.rvpipe.dp.PredBrE;
  wire        TomadoE  = dut.rvpipe.dp.PCSrcE;
  wire        MispE    = dut.rvpipe.dp.MispE;
`else
  wire        EsSaltoE = dut.rvpipe.dp.BranchBrE | dut.rvpipe.dp.JumpBrE;
  wire        MispE    = dut.rvpipe.dp.PCSrcE;
`endif

  top #(.MEMFILE("prog6_prediccion.mem")) dut(
    .clk(clk),
    .reset(reset),
    .WriteData(WriteData),
    .DataAdr(DataAdr),
    .MemWrite(MemWrite)
  );

  initial begin
    $dumpfile("tb_prog6_prediccion.vcd");
    $dumpvars(0, tb_prog6_prediccion);
    ciclos = 0; retiradas = 0; fallos = 0; saltos = 0; terminado = 0;
    reset = 1; #22;
    reset = 0;
  end

  always begin
    clk = 1; #5;
    clk = 0; #5;
  end

  always @(posedge clk) if (!reset && !terminado) begin
    ciclos = ciclos + 1;
    if (EsSaltoE) saltos = saltos + 1;
    if (MispE)    fallos = fallos + 1;
  end

  always @(negedge clk) if (!reset && !terminado) begin
    if (valW1 && PCW1 != PC_FIN) retiradas = retiradas + 1;
    if (valW2 && PCW2 != PC_FIN) retiradas = retiradas + 1;
    if ((valW1 && PCW1 == 32'd56) || (valW2 && PCW2 == 32'd56)) begin
      terminado = 1;
      if (mem0 === 45 && mem4 === 10 && x3 === 45 && x6 === 10)
        $display("OK: mem[0] = %0d, mem[4] = %0d en el ciclo %0d", mem0, mem4, ciclos);
      else
        $display("ERROR: mem[0] = %0d, mem[4] = %0d, x3 = %0d, x6 = %0d", mem0, mem4, x3, x6);
      $display("instrucciones = %0d, IPC = %0.2f", retiradas, retiradas * 1.0 / ciclos);
`ifdef OPT
      $display("saltos resueltos = %0d, predicciones fallidas = %0d", saltos, fallos);
`else
      $display("saltos resueltos = %0d, saltos tomados (flush) = %0d", saltos, fallos);
`endif
      #20 $stop;
    end
  end

endmodule
