`define DUAL
`timescale 1ns / 1ps
module tb_prog_propio();

  localparam PC_0 = 32'd140;
  localparam PC_1 = 32'd228;
  localparam PC_2 = 32'd308;
  localparam PC_3 = 32'd396;
  localparam PC_FIN = 32'd400;
  localparam BASE   = 256;
  localparam NW     = 64;
  localparam NS     = 4;

  reg clk;
  reg reset;
  wire [31:0] WriteData, DataAdr;
  wire MemWrite;

  reg [NS-1:0] chk;
  reg [NS-1:0] ok;
  reg fin_computo;

  integer ciclos, retiradas, stalls, flushes, dobles, errores, saltos;
  integer ciclos_fin, retiradas_fin;
  integer i;

  reg [31:0] sh [0:31];
  reg [31:0] exp_r [0:NS-1][0:31];
  reg [31:0] exp_m [0:NS-1][0:NW-1];

  wire [31:0] InstrW1  = dut.rvpipe.dp.InstrW;
  wire [31:0] PCW1     = dut.rvpipe.dp.PCPlus4W - 32'd4;
  wire        RegWrW1  = dut.rvpipe.dp.RegWriteW;
  wire [4:0]  RdW1     = dut.rvpipe.dp.RdW;
  wire [31:0] ResW1    = dut.rvpipe.dp.ResultW;
`ifdef DUAL
  wire [31:0] InstrW2  = dut.rvpipe.dp.InstrW2;
  wire [31:0] PCW2     = dut.rvpipe.dp.PCPlus4W2 - 32'd4;
  wire        RegWrW2  = dut.rvpipe.dp.RegWriteW2;
  wire [4:0]  RdW2     = dut.rvpipe.dp.RdW2;
  wire [31:0] ResW2    = dut.rvpipe.dp.ResultW2;
`else
  wire [31:0] InstrW2  = 32'd0;
  wire [31:0] PCW2     = 32'd0;
  wire        RegWrW2  = 1'b0;
  wire [4:0]  RdW2     = 5'd0;
  wire [31:0] ResW2    = 32'd0;
`endif
  wire        lwStall  = dut.rvpipe.hu.lwStall;
`ifdef OPT
  wire        FlushSalto = dut.rvpipe.dp.MispE;
  wire        EsSaltoE   = dut.rvpipe.dp.EsSaltoE;
`else
  wire        FlushSalto = dut.rvpipe.dp.PCSrcE;
  wire        EsSaltoE   = 1'b0;
`endif


  top #(.MEMFILE("prog_propio.mem")) dut(
    .clk(clk),
    .reset(reset),
    .WriteData(WriteData),
    .DataAdr(DataAdr),
    .MemWrite(MemWrite)
  );

  task cargar_esperados;
    integer s, r;
    begin
      for (s = 0; s < NS; s = s + 1) begin
        for (r = 0; r < 32; r = r + 1) exp_r[s][r] = 0;
        for (r = 0; r < NW; r = r + 1) exp_m[s][r] = 0;
      end
      exp_r[0][1] = 1024;
      exp_r[0][2] = 1088;
      exp_r[0][3] = 1152;
      exp_r[0][4] = 1216;
      exp_r[0][6] = 5;
      exp_r[0][7] = 13;
      exp_m[0][0] = 7;
      exp_m[0][1] = 3;
      exp_m[0][2] = 12;
      exp_m[0][3] = 9;
      exp_m[0][4] = 1;
      exp_m[0][5] = 15;
      exp_m[0][6] = 4;
      exp_m[0][7] = 10;
      exp_m[0][8] = 6;
      exp_m[0][9] = 14;
      exp_m[0][10] = 2;
      exp_m[0][11] = 11;
      exp_m[0][12] = 8;
      exp_m[0][13] = 5;
      exp_m[0][14] = 13;
      exp_r[1][1] = 1024;
      exp_r[1][2] = 1088;
      exp_r[1][3] = 1152;
      exp_r[1][4] = 1216;
      exp_r[1][6] = 5;
      exp_r[1][7] = 13;
      exp_r[1][12] = 120;
      exp_r[1][13] = 8;
      exp_r[1][14] = 7;
      exp_r[1][15] = 1;
      exp_r[1][16] = 16;
      exp_r[1][17] = 1088;
      exp_r[1][18] = 1152;
      exp_r[1][21] = 15;
      exp_r[1][24] = 16;
      exp_m[1][0] = 7;
      exp_m[1][1] = 3;
      exp_m[1][2] = 12;
      exp_m[1][3] = 9;
      exp_m[1][4] = 1;
      exp_m[1][5] = 15;
      exp_m[1][6] = 4;
      exp_m[1][7] = 10;
      exp_m[1][8] = 6;
      exp_m[1][9] = 14;
      exp_m[1][10] = 2;
      exp_m[1][11] = 11;
      exp_m[1][12] = 8;
      exp_m[1][13] = 5;
      exp_m[1][14] = 13;
      exp_m[1][16] = 7;
      exp_m[1][17] = 4;
      exp_m[1][18] = 14;
      exp_m[1][19] = 12;
      exp_m[1][20] = 5;
      exp_m[1][21] = 20;
      exp_m[1][22] = 10;
      exp_m[1][23] = 17;
      exp_m[1][24] = 14;
      exp_m[1][25] = 23;
      exp_m[1][26] = 12;
      exp_m[1][27] = 22;
      exp_m[1][28] = 20;
      exp_m[1][29] = 18;
      exp_m[1][30] = 27;
      exp_m[1][31] = 15;
      exp_m[1][48] = 120;
      exp_m[1][49] = 8;
      exp_r[2][1] = 1024;
      exp_r[2][2] = 1088;
      exp_r[2][3] = 1152;
      exp_r[2][4] = 1216;
      exp_r[2][6] = 5;
      exp_r[2][7] = 13;
      exp_r[2][12] = 120;
      exp_r[2][13] = 8;
      exp_r[2][14] = 7;
      exp_r[2][15] = 1;
      exp_r[2][16] = 8;
      exp_r[2][17] = 1088;
      exp_r[2][18] = 1152;
      exp_r[2][19] = 1216;
      exp_r[2][20] = 13;
      exp_r[2][21] = 27;
      exp_r[2][22] = 40;
      exp_r[2][24] = 8;
      exp_r[2][26] = 15;
      exp_r[2][27] = 15;
      exp_m[2][0] = 7;
      exp_m[2][1] = 3;
      exp_m[2][2] = 12;
      exp_m[2][3] = 9;
      exp_m[2][4] = 1;
      exp_m[2][5] = 15;
      exp_m[2][6] = 4;
      exp_m[2][7] = 10;
      exp_m[2][8] = 6;
      exp_m[2][9] = 14;
      exp_m[2][10] = 2;
      exp_m[2][11] = 11;
      exp_m[2][12] = 8;
      exp_m[2][13] = 5;
      exp_m[2][14] = 13;
      exp_m[2][16] = 7;
      exp_m[2][17] = 4;
      exp_m[2][18] = 14;
      exp_m[2][19] = 12;
      exp_m[2][20] = 5;
      exp_m[2][21] = 20;
      exp_m[2][22] = 10;
      exp_m[2][23] = 17;
      exp_m[2][24] = 14;
      exp_m[2][25] = 23;
      exp_m[2][26] = 12;
      exp_m[2][27] = 22;
      exp_m[2][28] = 20;
      exp_m[2][29] = 18;
      exp_m[2][30] = 27;
      exp_m[2][31] = 15;
      exp_m[2][32] = 14;
      exp_m[2][33] = 7;
      exp_m[2][34] = 26;
      exp_m[2][35] = 21;
      exp_m[2][36] = 6;
      exp_m[2][37] = 35;
      exp_m[2][38] = 14;
      exp_m[2][39] = 27;
      exp_m[2][40] = 20;
      exp_m[2][41] = 37;
      exp_m[2][42] = 14;
      exp_m[2][43] = 33;
      exp_m[2][44] = 28;
      exp_m[2][45] = 23;
      exp_m[2][46] = 40;
      exp_m[2][47] = 15;
      exp_m[2][48] = 120;
      exp_m[2][49] = 8;
      exp_m[2][50] = 40;
      exp_r[3][1] = 1024;
      exp_r[3][2] = 1088;
      exp_r[3][3] = 1152;
      exp_r[3][4] = 1216;
      exp_r[3][6] = 5;
      exp_r[3][7] = 13;
      exp_r[3][8] = 4;
      exp_r[3][9] = 4;
      exp_r[3][10] = 4;
      exp_r[3][11] = 106;
      exp_r[3][12] = 120;
      exp_r[3][13] = 8;
      exp_r[3][14] = 7;
      exp_r[3][15] = 1;
      exp_r[3][16] = 8;
      exp_r[3][17] = 1216;
      exp_r[3][18] = 1152;
      exp_r[3][19] = 1216;
      exp_r[3][20] = 15;
      exp_r[3][21] = 27;
      exp_r[3][22] = 40;
      exp_r[3][24] = 8;
      exp_r[3][26] = 15;
      exp_r[3][27] = 15;
      exp_r[3][28] = 106;
      exp_r[3][29] = 1;
      exp_m[3][0] = 7;
      exp_m[3][1] = 3;
      exp_m[3][2] = 12;
      exp_m[3][3] = 9;
      exp_m[3][4] = 1;
      exp_m[3][5] = 15;
      exp_m[3][6] = 4;
      exp_m[3][7] = 10;
      exp_m[3][8] = 6;
      exp_m[3][9] = 14;
      exp_m[3][10] = 2;
      exp_m[3][11] = 11;
      exp_m[3][12] = 8;
      exp_m[3][13] = 5;
      exp_m[3][14] = 13;
      exp_m[3][16] = 7;
      exp_m[3][17] = 4;
      exp_m[3][18] = 14;
      exp_m[3][19] = 12;
      exp_m[3][20] = 5;
      exp_m[3][21] = 20;
      exp_m[3][22] = 10;
      exp_m[3][23] = 17;
      exp_m[3][24] = 14;
      exp_m[3][25] = 23;
      exp_m[3][26] = 12;
      exp_m[3][27] = 22;
      exp_m[3][28] = 20;
      exp_m[3][29] = 18;
      exp_m[3][30] = 27;
      exp_m[3][31] = 15;
      exp_m[3][32] = 14;
      exp_m[3][33] = 7;
      exp_m[3][34] = 26;
      exp_m[3][35] = 21;
      exp_m[3][36] = 6;
      exp_m[3][37] = 35;
      exp_m[3][38] = 14;
      exp_m[3][39] = 27;
      exp_m[3][40] = 20;
      exp_m[3][41] = 37;
      exp_m[3][42] = 14;
      exp_m[3][43] = 33;
      exp_m[3][44] = 28;
      exp_m[3][45] = 23;
      exp_m[3][46] = 40;
      exp_m[3][47] = 15;
      exp_m[3][48] = 120;
      exp_m[3][49] = 8;
      exp_m[3][50] = 40;
      exp_m[3][51] = 68;
      exp_m[3][52] = 82;
      exp_m[3][53] = 104;
      exp_m[3][54] = 106;
      exp_m[3][55] = 106;
    end
  endtask

  task comprobar(input integer s);
    integer r, e;
    begin
      e = 0;
      for (r = 1; r < 32; r = r + 1)
        if (sh[r] !== exp_r[s][r]) begin
          $display("  [ETAPA %0d] x%0d = %0d, esperado %0d", s+1, r, sh[r], exp_r[s][r]);
          e = e + 1;
        end
      for (r = 0; r < NW; r = r + 1)
        if (dut.dmem.RAM[BASE + r] !== exp_m[s][r]) begin
          $display("  [ETAPA %0d] M[%0d] = %0d, esperado %0d", s+1, 4*(BASE+r), dut.dmem.RAM[BASE + r], exp_m[s][r]);
          e = e + 1;
        end
      $display("Etapa %0d  ciclo %0d  retiradas %0d  -> %s", s+1, ciclos, retiradas, (e == 0) ? "OK" : "FALLA");
      errores = errores + e;
      chk[s] = 1;
      ok[s]  = (e == 0);
    end
  endtask

  task retirar(input [31:0] instr, input [31:0] pc, input rw, input [4:0] rd, input [31:0] res);
    begin
      if (instr != 0 && pc != PC_FIN && !fin_computo) begin
        retiradas = retiradas + 1;
        if (rw && rd != 0) sh[rd] = res;
        if (pc == PC_0) comprobar(0);
        if (pc == PC_1) comprobar(1);
        if (pc == PC_2) comprobar(2);
        if (pc == PC_3) begin
          comprobar(3);
          fin_computo   = 1;
          ciclos_fin    = ciclos;
          retiradas_fin = retiradas;
        end
      end
    end
  endtask

  initial begin
    $dumpfile("tb_prog_propio.vcd");
    $dumpvars(0, tb_prog_propio);
    cargar_esperados;
    for (i = 0; i < 32; i = i + 1) sh[i] = 0;
    ciclos = 0; retiradas = 0; stalls = 0; flushes = 0; saltos = 0; dobles = 0; errores = 0;
    chk = 0;
    ok  = 0;
    fin_computo = 0;
    reset = 1; #22;
    reset = 0;
  end

  always begin
    clk = 1; #5;
    clk = 0; #5;
  end

  always @(posedge clk) if (!reset && !fin_computo) begin
    ciclos = ciclos + 1;
    if (lwStall) stalls = stalls + 1;
    if (FlushSalto) flushes = flushes + 1;
    if (EsSaltoE)   saltos = saltos + 1;
  end

  always @(negedge clk) if (!reset) begin
    chk = 0;
    if (InstrW1 != 0 && InstrW2 != 0 && !fin_computo) dobles = dobles + 1;
    retirar(InstrW1, PCW1, RegWrW1, RdW1, ResW1);
    retirar(InstrW2, PCW2, RegWrW2, RdW2, ResW2);
    if (fin_computo) begin
      #20;
      $display("--------------------------------------------");
      $display("Ciclos totales          : %0d", ciclos_fin);
      $display("Instrucciones retiradas : %0d", retiradas_fin);
      $display("CPI                     : %0.3f", ciclos_fin * 1.0 / retiradas_fin);
      $display("IPC                     : %0.3f", retiradas_fin * 1.0 / ciclos_fin);
      $display("Ciclos con load-use     : %0d", stalls);
`ifdef OPT
      $display("Saltos resueltos en E   : %0d", saltos);
      $display("Predicciones fallidas   : %0d", flushes);
      $display("Precision del predictor : %0.2f %%", 100.0 * (saltos - flushes) / saltos);
`else
      $display("Saltos tomados en E     : %0d", flushes);
`endif
      $display("Ciclos con 2 retiros    : %0d", dobles);
      $display("Errores                 : %0d", errores);
      $display("METRICS %0d %0d %0d %0d %0d %0d", ciclos_fin, retiradas_fin, stalls, flushes, dobles, errores);
      $finish;
    end
  end

  initial begin
    #100000;
    $display("TIMEOUT: no se llego a fin. ciclos=%0d retiradas=%0d", ciclos, retiradas);
    $finish;
  end

endmodule
