#!/usr/bin/env bash
#------------------------------------------------------------------------------
# Compile and run the self-checking SPI slave-controller testbench with Icarus
# Verilog. Verifies single/dual mode register read/write, bursts, command
# decode and all four SPI CPOL/CPHA modes.
#
# Usage:  ./run_spi_selfcheck.sh
#------------------------------------------------------------------------------
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RTL="$HERE/../rtl"
OUT="${OUT:-/tmp/spi_selfcheck}"

iverilog -g2012 -o "$OUT" \
  "$HERE/tb_spi_slave_selfcheck.sv" \
  "$HERE/stdcells_stub.v" \
  "$RTL/spi_cpha_cpol_slct.v" \
  "$RTL/spi_slave_controller.sv"

vvp "$OUT"
