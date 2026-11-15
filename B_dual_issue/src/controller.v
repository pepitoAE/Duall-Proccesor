module controller(input  [6:0] op,
                  input  [2:0] funct3,
                  input        funct7b5,
                  output [1:0] ResultSrc, 
                  output MemWrite,
                  output Branch, ALUSrc,
                  output RegWrite, Jump,
                  output [1:0] ImmSrc, 
                  output [2:0] ALUControl,
                  output UsaRs1, UsaRs2);
  
  // en el pipeline el controller solo decodifica en la etapa D
  // PCSrc ya no se calcula aqui, se calcula en la etapa E (unidad de saltos compartida)
  wire [1:0] ALUOp; 
  
  maindec md(
    .op(op), 
    .ResultSrc(ResultSrc), 
    .MemWrite(MemWrite), 
    .Branch(Branch),
    .ALUSrc(ALUSrc), 
    .RegWrite(RegWrite), 
    .Jump(Jump), 
    .ImmSrc(ImmSrc), 
    .ALUOp(ALUOp)
  ); 

  aludec  ad(
    .opb5(op[5]), 
    .funct3(funct3), 
    .funct7b5(funct7b5), 
    .ALUOp(ALUOp), 
    .ALUControl(ALUControl)
  ); 

  // que registros fuente usa de verdad la instruccion
  // (en un I-type o en jal los bits de rs1/rs2 pueden ser parte del inmediato)
  // los usan la Issue Unit y la Hazard Unit para no ver dependencias que no existen
  assign UsaRs1 = (op == 7'b0000011) |   // lw
                  (op == 7'b0100011) |   // sw
                  (op == 7'b0110011) |   // R-type
                  (op == 7'b1100011) |   // beq
                  (op == 7'b0010011);    // I-type ALU
  assign UsaRs2 = (op == 7'b0100011) |   // sw
                  (op == 7'b0110011) |   // R-type
                  (op == 7'b1100011);    // beq
endmodule
