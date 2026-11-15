`timescale 1ns / 1ps
module tb_prog_profesor();

  localparam PC_A   = 32'd52;
  localparam PC_B   = 32'd96;
  localparam PC_C   = 32'd224;
  localparam PC_D   = 32'd352;
  localparam PC_FIN = 32'd356;
  localparam BASE   = 384;

  reg clk;
  reg reset;
  wire [31:0] WriteData, DataAdr;
  wire MemWrite;

  reg chk_A, chk_B, chk_C, chk_D;
  reg ok_A, ok_B, ok_C, ok_D;
  reg fin_computo;

  integer ciclos, retiradas, stalls, flushes, dobles, errores;
  integer ciclos_fin, retiradas_fin;
  integer i;

  reg [31:0] sh [0:31];
  reg [31:0] exp_r [0:3][0:31];
  reg [31:0] exp_m [0:3][0:13];
  integer    n_m [0:3];

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
  wire        PCSrcE   = dut.rvpipe.dp.PCSrcE;

  wire [31:0] x25 = dut.rvpipe.dp.rf.rf[25];
  wire [31:0] x28 = dut.rvpipe.dp.rf.rf[28];
  wire [31:0] x29 = dut.rvpipe.dp.rf.rf[29];
  wire [31:0] x30 = dut.rvpipe.dp.rf.rf[30];
  wire [31:0] x31 = dut.rvpipe.dp.rf.rf[31];

  top #(.MEMFILE("prog_profesor.mem")) dut(
    .clk(clk),
    .reset(reset),
    .WriteData(WriteData),
    .DataAdr(DataAdr),
    .MemWrite(MemWrite)
  );

  task cargar_esperados;
    integer s, r;
    begin
      for (s = 0; s < 4; s = s + 1) begin
        for (r = 0; r < 32; r = r + 1) exp_r[s][r] = 0;
        for (r = 0; r < 14; r = r + 1) exp_m[s][r] = 0;
      end
      for (s = 0; s < 4; s = s + 1) begin
        exp_r[s][1] = 1536; exp_r[s][2] = 1;  exp_r[s][3] = 8;  exp_r[s][4] = 3;
        exp_r[s][5] = 11;   exp_r[s][6] = 5;  exp_r[s][7] = 16; exp_r[s][8] = 2;
        exp_r[s][9] = 7;    exp_r[s][10] = 12;
        exp_m[s][0] = 11;   exp_m[s][1] = 5;  exp_m[s][2] = 12;
      end
      for (s = 1; s < 4; s = s + 1) begin
        exp_r[s][11] = 11; exp_r[s][12] = 16; exp_r[s][13] = 5; exp_r[s][14] = 12;
        exp_r[s][15] = 7;  exp_r[s][16] = 7;  exp_r[s][17] = 16; exp_r[s][18] = 23;
        exp_m[s][3] = 7;   exp_m[s][4] = 16;  exp_m[s][5] = 23;
      end
      for (s = 2; s < 4; s = s + 1) begin
        exp_r[s][19] = 12; exp_r[s][20] = 12; exp_r[s][21] = 24;
        exp_r[s][22] = 18; exp_r[s][24] = 24; exp_r[s][26] = 6;
        exp_m[s][6] = 24;  exp_m[s][7] = 18;  exp_m[s][8] = 24;
      end
      exp_r[3][19] = 6;    exp_r[3][20] = 6;    exp_r[3][25] = 4;  exp_r[3][26] = 4;
      exp_r[3][27] = 1560; exp_r[3][28] = 74;   exp_r[3][29] = 4;  exp_r[3][30] = 23;
      exp_r[3][31] = 1;
      exp_m[3][9] = 74;    exp_m[3][10] = 4;    exp_m[3][11] = 0;  exp_m[3][12] = 1;
      exp_m[3][13] = 1;
    end
  endtask

  task comprobar(input integer s);
    integer r, e;
    begin
      e = 0;
      for (r = 1; r < 32; r = r + 1)
        if (sh[r] !== exp_r[s][r]) begin
          $display("  [ETAPA %c] x%0d = %0d, esperado %0d", "A"+s, r, sh[r], exp_r[s][r]);
          e = e + 1;
        end
      for (r = 0; r < 14; r = r + 1)
        if (dut.dmem.RAM[BASE + r] !== exp_m[s][r]) begin
          $display("  [ETAPA %c] M[x1+%0d] = %0d, esperado %0d", "A"+s, 4*r, dut.dmem.RAM[BASE + r], exp_m[s][r]);
          e = e + 1;
        end
      $display("Etapa %c  ciclo %0d  retiradas %0d  -> %s", "A"+s, ciclos, retiradas, (e == 0) ? "OK" : "FALLA");
      errores = errores + e;
      case (s)
        0: begin chk_A = 1; ok_A = (e == 0); end
        1: begin chk_B = 1; ok_B = (e == 0); end
        2: begin chk_C = 1; ok_C = (e == 0); end
        3: begin chk_D = 1; ok_D = (e == 0); end
      endcase
    end
  endtask

  task retirar(input [31:0] instr, input [31:0] pc, input rw, input [4:0] rd, input [31:0] res);
    begin
      if (instr != 0 && pc != PC_FIN && !fin_computo) begin
        retiradas = retiradas + 1;
        if (rw && rd != 0) sh[rd] = res;
        if (pc == PC_A) comprobar(0);
        if (pc == PC_B) comprobar(1);
        if (pc == PC_C) comprobar(2);
        if (pc == PC_D) begin
          comprobar(3);
          fin_computo   = 1;
          ciclos_fin    = ciclos;
          retiradas_fin = retiradas;
        end
      end
    end
  endtask

  initial begin
    $dumpfile("tb_prog_profesor.vcd");
    $dumpvars(0, tb_prog_profesor);
    cargar_esperados;
    for (i = 0; i < 32; i = i + 1) sh[i] = 0;
    ciclos = 0; retiradas = 0; stalls = 0; flushes = 0; dobles = 0; errores = 0;
    chk_A = 0; chk_B = 0; chk_C = 0; chk_D = 0;
    ok_A = 0; ok_B = 0; ok_C = 0; ok_D = 0;
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
    if (PCSrcE)  flushes = flushes + 1;
  end

  always @(negedge clk) if (!reset) begin
    chk_A = 0; chk_B = 0; chk_C = 0; chk_D = 0;
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
      $display("Saltos tomados en E     : %0d", flushes);
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
