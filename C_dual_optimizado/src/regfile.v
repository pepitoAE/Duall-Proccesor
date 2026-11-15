module regfile(input  clk, 
               input  we3, 
               input  [ 4:0] a1, a2, a3, 
               input  [31:0] wd3, 
               output [31:0] rd1, rd2,
               input  [ 4:0] a4, a5,      // lecturas de la via 2
               output [31:0] rd4, rd5,
               input  we6,                // escritura de la via 2
               input  [ 4:0] a6,
               input  [31:0] wd6); 

  reg [31:0] rf[31:0]; 
  integer i;

  // se inicializan en 0 para que no aparezcan x en el waveform
  initial begin
    for (i = 0; i < 32; i = i + 1) rf[i] = 32'b0;
  end

  // en el pipeline se escribe en el flanco de BAJADA
  // asi la instruccion en Decode lee el valor que Writeback escribe en el mismo ciclo
  // dos escrituras por ciclo: primero la via 1 y despues la via 2.
  // si las dos escriben el mismo registro se queda el valor de la via 2,
  // porque la via 2 siempre lleva la instruccion mas joven del par
  always @(negedge clk) begin 
    if (we3) rf[a3] <= wd3; 
    if (we6) rf[a6] <= wd6; 
  end
  
  // register 0 hardwired to 0
  assign rd1 = (a1 != 0) ? rf[a1] : 0; 
  assign rd2 = (a2 != 0) ? rf[a2] : 0; 
  assign rd4 = (a4 != 0) ? rf[a4] : 0; 
  assign rd5 = (a5 != 0) ? rf[a5] : 0; 
endmodule
