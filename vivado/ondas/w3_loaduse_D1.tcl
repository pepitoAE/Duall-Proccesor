add_wave /tb_prog_profesor/clk
add_wave -radix unsigned /tb_prog_profesor/dut/rvpipe/dp/PCF /tb_prog_profesor/dut/rvpipe/dp/PCD /tb_prog_profesor/dut/rvpipe/dp/PCD2
add_wave -radix hex /tb_prog_profesor/dut/rvpipe/dp/InstrD /tb_prog_profesor/dut/rvpipe/dp/InstrD2
add_wave /tb_prog_profesor/dut/rvpipe/EmiteVia2 /tb_prog_profesor/dut/rvpipe/hu/lwStall /tb_prog_profesor/dut/rvpipe/hu/StallF /tb_prog_profesor/dut/rvpipe/hu/StallD /tb_prog_profesor/dut/rvpipe/hu/FlushE
add_wave -radix hex /tb_prog_profesor/dut/rvpipe/dp/InstrE /tb_prog_profesor/dut/rvpipe/dp/InstrE2
add_wave /tb_prog_profesor/dut/rvpipe/dp/ResultSrcE0 /tb_prog_profesor/dut/rvpipe/dp/ResultSrcE20
add_wave -radix unsigned /tb_prog_profesor/dut/rvpipe/hu/RdE /tb_prog_profesor/dut/rvpipe/hu/RdE2
add_wave -radix bin /tb_prog_profesor/dut/rvpipe/hu/ForwardAE /tb_prog_profesor/dut/rvpipe/hu/ForwardBE /tb_prog_profesor/dut/rvpipe/hu/ForwardAE2 /tb_prog_profesor/dut/rvpipe/hu/ForwardBE2
add_wave -radix hex /tb_prog_profesor/dut/rvpipe/dp/InstrM /tb_prog_profesor/dut/rvpipe/dp/InstrM2 /tb_prog_profesor/dut/rvpipe/dp/InstrW /tb_prog_profesor/dut/rvpipe/dp/InstrW2
add_wave -radix unsigned /tb_prog_profesor/dut/rvpipe/dp/ResultW /tb_prog_profesor/dut/rvpipe/dp/ResultW2
add_wave -radix unsigned /tb_prog_profesor/x27 /tb_prog_profesor/x28 /tb_prog_profesor/x30
run all
