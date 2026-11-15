module imem #(parameter MEMFILE = "riscvtest.mem")
            (input  [31:0] a,
             output [31:0] rd,
             output [31:0] rd2);
  
  reg [31:0] RAM[0:255]; 
  integer i;

  initial begin
      for (i = 0; i < 256; i = i + 1) RAM[i] = 32'b0;
      $readmemh(MEMFILE, RAM, 0, 255); 
  end

  assign rd  = RAM[a[9:2]];
  assign rd2 = RAM[a[9:2] + 8'd1];
endmodule
