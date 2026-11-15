`timescale 1ns / 1ps
// Testbench de comparacion (procesador de la E1, una instruccion por ciclo) - Programa de la E1: ISA sin dependencias
// Resultado esperado: mem[72] = 30
module tb_single_prog1_isa();

  reg clk;
  reg reset;
  wire [31:0] WriteData, DataAdr;
  wire MemWrite;
  integer ciclos;      // ciclo actual (el ciclo 1 es el de 20 a 30 ns, con PCF = 0)
  integer retiradas;   // instrucciones que terminan (llegan a W, o el sw final en M)

  // registros y memoria como wires, para verlos en el waveform
  // (algunos simuladores no muestran los arreglos rf y RAM en el waveform)
  wire [31:0] x1 = dut.rvpipe.dp.rf.rf[1];
  wire [31:0] x2 = dut.rvpipe.dp.rf.rf[2];
  wire [31:0] x3 = dut.rvpipe.dp.rf.rf[3];
  wire [31:0] x4 = dut.rvpipe.dp.rf.rf[4];
  wire [31:0] x5 = dut.rvpipe.dp.rf.rf[5];
  wire [31:0] x6 = dut.rvpipe.dp.rf.rf[6];
  wire [31:0] x7 = dut.rvpipe.dp.rf.rf[7];
  wire [31:0] x8 = dut.rvpipe.dp.rf.rf[8];
  wire [31:0] x9 = dut.rvpipe.dp.rf.rf[9];
  wire [31:0] x10 = dut.rvpipe.dp.rf.rf[10];
  wire [31:0] x11 = dut.rvpipe.dp.rf.rf[11];
  wire [31:0] x12 = dut.rvpipe.dp.rf.rf[12];
  wire [31:0] x13 = dut.rvpipe.dp.rf.rf[13];
  wire [31:0] x14 = dut.rvpipe.dp.rf.rf[14];
  wire [31:0] x15 = dut.rvpipe.dp.rf.rf[15];
  wire [31:0] x16 = dut.rvpipe.dp.rf.rf[16];
  wire [31:0] x17 = dut.rvpipe.dp.rf.rf[17];
  wire [31:0] x18 = dut.rvpipe.dp.rf.rf[18];
  wire [31:0] x19 = dut.rvpipe.dp.rf.rf[19];
  wire [31:0] x20 = dut.rvpipe.dp.rf.rf[20];
  wire [31:0] mem64 = dut.dmem.RAM[16];
  wire [31:0] mem68 = dut.dmem.RAM[17];
  wire [31:0] mem72 = dut.dmem.RAM[18];
  wire [31:0] mem80 = dut.dmem.RAM[20];
  wire [31:0] mem84 = dut.dmem.RAM[21];
  wire [31:0] mem96 = dut.dmem.RAM[24];
  wire [31:0] mem100 = dut.dmem.RAM[25];
  wire [31:0] mem104 = dut.dmem.RAM[26];

  top #(.MEMFILE("prog1_isa.mem")) dut(
    .clk(clk),
    .reset(reset),
    .WriteData(WriteData),
    .DataAdr(DataAdr),
    .MemWrite(MemWrite)
  );

  // reset los primeros 2 ciclos
  initial begin
    ciclos = 1;
    retiradas = 0;
    reset = 1; #22;
    reset = 0;
  end

  // reloj de 10 ns
  always begin
    clk = 1; #5;
    clk = 0; #5;
  end

  always @(posedge clk) if (!reset) ciclos = ciclos + 1;

  always @(negedge clk) begin
    // en cada ciclo se cuentan las instrucciones que estan en W (las burbujas valen 0)
    if (!reset) begin
      if (dut.rvpipe.dp.InstrW  != 0) retiradas = retiradas + 1;
    end
    // se revisa la ultima escritura a memoria del programa
    if (MemWrite) begin
      if (DataAdr === 72 && WriteData === 30) begin
        // el sw final todavia esta en M: se cuenta aqui
        retiradas = retiradas + 1;
        $display("OK: mem[72] = %0d en el ciclo %0d", WriteData, ciclos);
        $display("instrucciones = %0d, IPC = %0d.%02d", retiradas, ((retiradas*100 + ciclos/2)/ciclos)/100, ((retiradas*100 + ciclos/2)/ciclos)%100);
        #20 $stop;
      end
    end
    if (ciclos > 200) begin
      $display("FALLO: no se llego a escribir mem[72] = 30");
      $stop;
    end
  end

endmodule
