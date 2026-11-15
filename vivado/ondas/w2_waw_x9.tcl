add_wave /tb_prog_profesor/clk
add_wave -radix unsigned /tb_prog_profesor/dut/rvpipe/dp/PCF /tb_prog_profesor/dut/rvpipe/dp/PCD /tb_prog_profesor/dut/rvpipe/dp/PCD2
add_wave -radix hex /tb_prog_profesor/dut/rvpipe/dp/InstrD /tb_prog_profesor/dut/rvpipe/dp/InstrD2
add_wave /tb_prog_profesor/dut/rvpipe/EmiteVia2 /tb_prog_profesor/dut/rvpipe/iu/RAWpar /tb_prog_profesor/dut/rvpipe/iu/DosMem /tb_prog_profesor/dut/rvpipe/iu/DosSaltos
add_wave -radix hex /tb_prog_profesor/dut/rvpipe/dp/InstrE /tb_prog_profesor/dut/rvpipe/dp/InstrE2
add_wave -radix bin /tb_prog_profesor/dut/rvpipe/hu/ForwardAE /tb_prog_profesor/dut/rvpipe/hu/ForwardBE /tb_prog_profesor/dut/rvpipe/hu/ForwardAE2 /tb_prog_profesor/dut/rvpipe/hu/ForwardBE2
add_wave -radix unsigned /tb_prog_profesor/dut/rvpipe/dp/SrcAE /tb_prog_profesor/dut/rvpipe/dp/SrcBE /tb_prog_profesor/dut/rvpipe/dp/SrcAE2 /tb_prog_profesor/dut/rvpipe/dp/SrcBE2
add_wave -radix hex /tb_prog_profesor/dut/rvpipe/dp/InstrM /tb_prog_profesor/dut/rvpipe/dp/InstrM2
add_wave -radix unsigned /tb_prog_profesor/dut/rvpipe/dp/RdM /tb_prog_profesor/dut/rvpipe/dp/ALUResultM /tb_prog_profesor/dut/rvpipe/dp/RdM2 /tb_prog_profesor/dut/rvpipe/dp/ALUResultM2
add_wave -radix hex /tb_prog_profesor/dut/rvpipe/dp/InstrW /tb_prog_profesor/dut/rvpipe/dp/InstrW2
add_wave /tb_prog_profesor/dut/rvpipe/dp/RegWriteW /tb_prog_profesor/dut/rvpipe/dp/RegWriteW2
add_wave -radix unsigned /tb_prog_profesor/dut/rvpipe/dp/RdW /tb_prog_profesor/dut/rvpipe/dp/ResultW /tb_prog_profesor/dut/rvpipe/dp/RdW2 /tb_prog_profesor/dut/rvpipe/dp/ResultW2
add_wave -radix unsigned /tb_prog_profesor/x9 /tb_prog_profesor/x10
run all
