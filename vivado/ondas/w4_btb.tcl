add_wave /tb_prog6_prediccion/clk
add_wave -radix unsigned /tb_prog6_prediccion/dut/rvpipe/dp/PCF /tb_prog6_prediccion/dut/rvpipe/dp/PCNextF
add_wave /tb_prog6_prediccion/dut/rvpipe/dp/PredF1 /tb_prog6_prediccion/dut/rvpipe/dp/PredF2 /tb_prog6_prediccion/dut/rvpipe/dp/SquashF2
add_wave -radix unsigned /tb_prog6_prediccion/dut/rvpipe/dp/TgtF1 /tb_prog6_prediccion/dut/rvpipe/dp/TgtF2
add_wave -radix hex /tb_prog6_prediccion/dut/rvpipe/dp/InstrD /tb_prog6_prediccion/dut/rvpipe/dp/InstrD2
add_wave /tb_prog6_prediccion/dut/rvpipe/dp/PredD /tb_prog6_prediccion/dut/rvpipe/dp/PredD2
add_wave /tb_prog6_prediccion/dut/rvpipe/dp/EsSaltoE
add_wave -radix unsigned /tb_prog6_prediccion/dut/rvpipe/dp/PCBrE
add_wave /tb_prog6_prediccion/dut/rvpipe/dp/PredBrE /tb_prog6_prediccion/dut/rvpipe/dp/PCSrcE /tb_prog6_prediccion/dut/rvpipe/dp/MispE
add_wave -radix unsigned /tb_prog6_prediccion/dut/rvpipe/dp/PCCorrE
add_wave /tb_prog6_prediccion/dut/rvpipe/hu/FlushD /tb_prog6_prediccion/dut/rvpipe/hu/FlushE /tb_prog6_prediccion/dut/rvpipe/hu/FlushM2
add_wave -radix unsigned /tb_prog6_prediccion/x1 /tb_prog6_prediccion/x3 /tb_prog6_prediccion/x4 /tb_prog6_prediccion/x6
add_wave -radix unsigned /tb_prog6_prediccion/fallos /tb_prog6_prediccion/saltos
run all
