module btb #(parameter ENTRADAS = 16, parameter IDX = 4)
           (input  clk, reset,
            input  [31:0] pc1,
            output        hit1, pred1,
            output [31:0] tgt1,
            input  [31:0] pc2,
            output        hit2, pred2,
            output [31:0] tgt2,
            input         we,
            input  [31:0] pcE,
            input         tomadoE,
            input         jumpE,
            input  [31:0] tgtE);

  localparam TAG = 30 - IDX;

  reg            valid [0:ENTRADAS-1];
  reg [TAG-1:0]  tag   [0:ENTRADAS-1];
  reg [31:0]     dest  [0:ENTRADAS-1];
  reg [1:0]      cnt   [0:ENTRADAS-1];
  integer i;

  wire [IDX-1:0] i1 = pc1[IDX+1:2];
  wire [IDX-1:0] i2 = pc2[IDX+1:2];
  wire [IDX-1:0] iE = pcE[IDX+1:2];

  assign hit1  = valid[i1] & (tag[i1] == pc1[31:IDX+2]);
  assign pred1 = hit1 & cnt[i1][1];
  assign tgt1  = dest[i1];

  assign hit2  = valid[i2] & (tag[i2] == pc2[31:IDX+2]);
  assign pred2 = hit2 & cnt[i2][1];
  assign tgt2  = dest[i2];

  wire hitE = valid[iE] & (tag[iE] == pcE[31:IDX+2]);

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      for (i = 0; i < ENTRADAS; i = i + 1) begin
        valid[i] <= 1'b0;
        tag[i]   <= 0;
        dest[i]  <= 32'b0;
        cnt[i]   <= 2'b00;
      end
    end
    else if (we) begin
      if (hitE) begin
        dest[iE] <= tgtE;
        if (tomadoE & (cnt[iE] != 2'b11))       cnt[iE] <= cnt[iE] + 2'b01;
        else if (~tomadoE & (cnt[iE] != 2'b00)) cnt[iE] <= cnt[iE] - 2'b01;
      end
      else if (tomadoE) begin
        valid[iE] <= 1'b1;
        tag[iE]   <= pcE[31:IDX+2];
        dest[iE]  <= tgtE;
        cnt[iE]   <= jumpE ? 2'b11 : 2'b10;
      end
    end
  end
endmodule
