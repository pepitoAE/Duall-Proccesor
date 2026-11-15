module mux5 #(parameter WIDTH = 8)
             (input  [WIDTH-1:0] d0, d1, d2, d3, d4,
              input  [2:0]       s, 
              output [WIDTH-1:0] y);

  // mismo estilo que mux3, pero con 5 entradas (forwarding de las dos vias)
  assign y = (s == 3'b100) ? d4 :
             (s == 3'b011) ? d3 :
             (s == 3'b010) ? d2 :
             (s == 3'b001) ? d1 : d0; 
endmodule
