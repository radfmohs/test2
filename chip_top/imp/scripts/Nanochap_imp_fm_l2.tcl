# ------------------------------------------------------------------------------
# Block-level Formality LEC for the bottom-up imeas_wrapper sub-block.
#
#   Reference      : imeas_wrapper RTL (imeas/rtl) + filter RTL + common cells
#   Implementation : ../data/synthesis_l2/imeas_wrapper.prescan.v  (syn_l2 netlist)
#   Guidance       : filter_wrapper.svf (L3) + imeas_wrapper.svf (L2)
#
# Purpose: verify the sub-block where it STILL exists as a hierarchical design.
# At this level filter_wrapper / imeas_wrapper are real designs, so their
# design-scoped SVF guidance (notably guide_inv_push on
#   u_filter_fir_lpf/acc_final_reg[18]  and  cnt_stable_time_reg[1])
# can bind - which it cannot in the flattened + uniquified top-level run.
#
# Run from the work directory (see the 'lec_l2' Makefile target):
#   cd work; fm_shell -64bit -f ../scripts/Nanochap_imp_fm_l2.tcl | tee ../logs/lec_l2.log
# ------------------------------------------------------------------------------

set start_time [clock seconds] ; echo [clock format ${start_time} -gmt false]
echo [pwd]
print_suppressed_messages

set blk imeas_wrapper

# ------------------------------------------------------------------------------
# Configuration + technology
# ------------------------------------------------------------------------------
source -echo -verbose ../scripts/design_config.tcl
source -echo -verbose ../scripts/Nanochap_imp_tech.tcl

# ------------------------------------------------------------------------------
# Formality variables (kept identical to the top-level fm.tcl)
# ------------------------------------------------------------------------------
set_app_var verification_assume_reg_init none
set_app_var verification_clock_gate_edge_analysis true
set_app_var verification_inversion_push true
set_app_var hdlin_dwroot ""
set_app_var synopsys_auto_setup true
set_app_var verification_set_undriven_signals "0"
set_app_var verification_verify_directly_undriven_output true
set_app_var verification_clock_gate_hold_mode low

# ------------------------------------------------------------------------------
# SVF guidance (bottom-up order: L3 channel first, then L2 wrapper)
# ------------------------------------------------------------------------------
proc load_svf {mode file} {
  if {[file exists $file]} {
    echo "INFO: loading SVF ($mode): $file"
    if {$mode == "append"} { set_svf -append $file } else { set_svf $file }
  } else {
    echo "ERROR: expected SVF NOT FOUND, guidance will be MISSING: $file"
  }
}
load_svf set    ../data/synthesis_l3/filter_wrapper.svf
load_svf append ../data/synthesis_l2/imeas_wrapper.svf

# ------------------------------------------------------------------------------
# Libraries (imeas_wrapper is pure digital: standard cells + ICG only)
# Add otp/io/ana reads here only if 'match' reports unresolved cells.
# ------------------------------------------------------------------------------
set_app_var search_path [concat . $stdcell_search_path $search_path]
read_db $stdcell_library(db,$slow_corner_pvt)

# ------------------------------------------------------------------------------
# Reference: imeas_wrapper RTL.
# NOTE: read with NO -define, matching how syn_l2/syn_l3 analyzed these files,
# so a pass/fail here also isolates whether the top-level mismatch is caused by
# the -define list that the top fm.tcl applies.
# ------------------------------------------------------------------------------
# filter_wrapper instantiates the full imeas core (u_imeas) and several common
# sync cells, so unlike DC's "analyze -autoread", every module must be listed
# explicitly here. This is the complete imeas/rtl set + the common cells the
# imeas/filter RTL instantiates (common_sync_bit, common_pulse_rising,
# common_pulse_async_clr, common_bit_sync, common_rst_sync, common_pulse_sync).
set ref_rtl [list \
  ../../../../logical/imeas/rtl/filter_iir_hpf.v \
  ../../../../logical/imeas/rtl/filter_fir_lpf.sv \
  ../../../../logical/imeas/rtl/notch_filter.sv \
  ../../../../logical/imeas/rtl/filter_ctrl.sv \
  ../../../../logical/imeas/rtl/filter_wrapper.sv \
  ../../../../logical/imeas/rtl/imeas.sv \
  ../../../../logical/imeas/rtl/imeas_cdc.sv \
  ../../../../logical/imeas/rtl/imeas_cic.sv \
  ../../../../logical/imeas/rtl/imeas_ctrl.sv \
  ../../../../logical/imeas/rtl/imeas_reg.sv \
  ../../../../logical/imeas/rtl/imeas_wrapper.sv \
  ../../../common/common_sync_bit.v \
  ../../../common/common_bit_sync.v \
  ../../../common/common_pulse_rising.v \
  ../../../common/common_pulse_sync.v \
  ../../../common/common_pulse_async_clr.v \
  ../../../common/common_rst_sync.v \
]
read_sverilog -r -work_library WORK $ref_rtl
set_top r:/WORK/${blk}

# ------------------------------------------------------------------------------
# Implementation: L2 gate-level netlist (written by syn_l2, no uniquify/flatten)
# ------------------------------------------------------------------------------
read_verilog -i -work_library WORK -netlist ../data/synthesis_l2/imeas_wrapper.prescan.v
set_top i:/WORK/${blk}

# ------------------------------------------------------------------------------
# Match + verify
# ------------------------------------------------------------------------------
set_reference_design      r:/WORK/${blk}
set_implementation_design i:/WORK/${blk}

match

set rpt_dir ../reports/lec_l2
sh mkdir -p ${rpt_dir}
report_matched_points         > ${rpt_dir}/${blk}.matched.fm
report_unmatched_points       > ${rpt_dir}/${blk}.unmatched.fm
report_setup_status

set status [ verify r:/WORK/${blk} i:/WORK/${blk} ]

report_passing_points         > ${rpt_dir}/${blk}.passed.fm
report_failing_points         > ${rpt_dir}/${blk}.failed.fm
report_svf_operation -status rejected > ${rpt_dir}/${blk}.svf_rejected.fm
report_guidance -summary      > ${rpt_dir}/${blk}.svf_guidance.summary

# verify returns 1 on success, 0 on failure
if {$status == 0} {
  analyze_points -all > ${rpt_dir}/${blk}.analysis_results
} else {
  echo "Verification SUCCEEDED - no points to analyze" > ${rpt_dir}/${blk}.analysis_results
}

report_status
print_message_info

set end_time [clock seconds]; echo [clock format ${end_time} -gmt false]
echo "Time elapsed: [clock format [expr ${end_time} - ${start_time}] -format %Hh%Mm%Ss -gmt true]"

exit
