#!/bin/sh
cd "$(dirname "$0")"
iverilog -g2012 -o A_pipeline.vvp tb_fuzz.v ../../A_single_issue/src/*.v
iverilog -g2012 -o B_dual.vvp      tb_fuzz.v ../../B_dual_issue/src/*.v
iverilog -g2012 -o C_opt.vvp       tb_fuzz.v ../../C_dual_optimizado/src/*.v
python3 fuzz.py ${1:-400} A_pipeline B_dual C_opt
