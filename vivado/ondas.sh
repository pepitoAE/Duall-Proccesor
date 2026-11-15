#!/bin/bash
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
case "$1" in
  1) ver=C_dual_optimizado; tb=tb_prog_profesor;    w=w1_cierre_etapas.tcl ;;
  2) ver=B_dual_issue;      tb=tb_prog_profesor;    w=w2_waw_x9.tcl ;;
  3) ver=B_dual_issue;      tb=tb_prog_profesor;    w=w3_loaduse_D1.tcl ;;
  4) ver=C_dual_optimizado; tb=tb_prog6_prediccion; w=w4_btb.tcl ;;
  *) echo "uso: $0 {1|2|3|4}"; exit 1 ;;
esac
d="$ROOT/vivado/xsim_runs/onda$1"
rm -rf "$d"; mkdir -p "$d"; cd "$d"
cp "$ROOT/$ver/mem/"*.mem .
xvlog "$ROOT/$ver/src/"*.v "$ROOT/$ver/sim/$tb.v"
xelab -debug typical --timescale 1ns/1ps "$tb" -s sim
xsim sim -gui -tclbatch "$ROOT/vivado/ondas/$w"
