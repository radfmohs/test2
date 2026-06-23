#!/usr/bin/env bash
# ============================================================================
# Standalone NIRS/PPG testbench runner (Icarus Verilog)
# ----------------------------------------------------------------------------
# Compiles and runs every standalone testbench in this folder against the RTL
# in ../rtl and the shared cells in ../../common. No dependency on any of the
# UVM / chip-top testbenches already in the repository.
#
# Usage:   ./run_all.sh
# Returns non-zero if any testbench prints "RESULT: FAIL" or fails to build.
# ============================================================================
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
RTL="$HERE/../rtl"
COMMON="$HERE/../../common"
WORK="$(mktemp -d)"

IV="iverilog -g2012 -DFPGA"

COMMON_SRCS="$COMMON/common_sync_bit.v $COMMON/common_pulse_cdc.v \
$COMMON/common_pulse_async_clr.v $COMMON/common_pulse_rising.v \
$COMMON/common_rst_sync.v $COMMON/common_clock_gate.v"

declare -a NAMES SRCS
add() { NAMES+=("$1"); SRCS+=("$2"); }

add tb_nirs_ppg_subtract_dout "$RTL/nirs_ppg_subtract_dout.v"
add tb_nirs_ppg_idac_ctrl     "$RTL/nirs_ppg_idac_ctrl.v"
add tb_nirs_ppg_int           "$RTL/nirs_ppg_int.v $COMMON/common_pulse_async_clr.v $COMMON/common_rst_sync.v $COMMON/common_pulse_rising.v"
add tb_nirs_ppg_pulse_ctrl    "$RTL/nirs_ppg_pulse_ctrl.v"
add tb_nirs_ppg_ctrl          "$RTL/nirs_ppg_ctrl.v"
add tb_nirs_ppg_cmd           "$RTL/nirs_ppg_cmd.v $RTL/nirs_ppg_clk.v $COMMON/common_clock_gate.v"
add tb_nirs_ppg_ctrl_top      "$RTL/nirs_ppg_ctrl_top.v $RTL/nirs_ppg_counter.v $RTL/nirs_ppg_latch.v \
$RTL/nirs_ppg_subtract_dout.v $RTL/nirs_ppg_idac_ctrl.v $RTL/nirs_ppg_ctrl.v \
$RTL/nirs_ppg_pulse_ctrl.v $RTL/nirs_ppg_int.v $COMMON_SRCS"

fails=0
total=0
echo "=================================================================="
for i in "${!NAMES[@]}"; do
  name="${NAMES[$i]}"
  total=$((total+1))
  out="$WORK/$name.out"
  if ! $IV -o "$out" ${SRCS[$i]} "$HERE/$name.v" > "$WORK/$name.log" 2>&1; then
    echo "[BUILD FAIL] $name"
    cat "$WORK/$name.log"
    fails=$((fails+1))
    continue
  fi
  res="$(cd "$WORK" && vvp "$out" 2>&1)"
  verdict="$(echo "$res" | grep -E 'RESULT:' | tail -1)"
  summary="$(echo "$res" | grep -E '==== checks=' | tail -1)"
  if echo "$verdict" | grep -q PASS; then
    echo "[PASS] $name   $summary"
  else
    echo "[FAIL] $name   $summary"
    echo "$res" | grep -E '\[FAIL\]|\[DEVIATION\]|TIMEOUT'
    fails=$((fails+1))
  fi
done
echo "=================================================================="
echo "Ran $total testbench(es), $fails failure(s)."
rm -rf "$WORK"
exit $fails
