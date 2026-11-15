#!/bin/bash
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/vivado/xsim_runs"
RES="$OUT/resumen.txt"
mkdir -p "$OUT"
: > "$RES"
correr() {
  ver=$1; tb=$2
  d="$OUT/$ver/$tb"
  rm -rf "$d"; mkdir -p "$d"; cd "$d"
  cp "$ROOT/$ver/mem/"*.mem .
  xvlog "$ROOT/$ver/src/"*.v "$ROOT/$ver/sim/$tb.v" > xvlog.out 2>&1 || { echo "ERROR xvlog $ver $tb (ver $d/xvlog.out)" | tee -a "$RES"; return; }
  xelab -debug typical --timescale 1ns/1ps "$tb" -s sim > xelab.out 2>&1 || { echo "ERROR xelab $ver $tb (ver $d/xelab.out)" | tee -a "$RES"; return; }
  xsim sim -R > sim.out 2>&1 || true
  grep -E "Etapa|METRICS|^OK|ERROR|TIMEOUT|instrucciones|saltos" sim.out | sed "s|^|$ver $tb: |" | tee -a "$RES"
}
for ver in A_single_issue B_dual_issue C_dual_optimizado; do
  correr $ver tb_prog_profesor
  correr $ver tb_prog_propio
done
correr B_dual_issue tb_prog6_prediccion
correr C_dual_optimizado tb_prog6_prediccion
echo
echo "Resumen guardado en $RES"
