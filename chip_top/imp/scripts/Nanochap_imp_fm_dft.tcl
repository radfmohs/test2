# ------------------------------------------------------------------------------
# Gate-to-gate DFT LEC: prescan_dct netlist (reference) vs postscan_dct netlist
# (implementation).
#
# Why: at postscan_dct the DFT step ungroup -flatten's u_imeas_wrapper, dissolving
# the filter_wrapper/imeas_wrapper designs in the implementation. So an RTL-vs-
# postscan_dct check can't bind the bottom-up datapath/inv_push guidance and the
# IIR accum_reg fails. Verifying gate-to-gate instead sidesteps this entirely:
#   * both sides are gate-level (no RTL parameterized-name issue, no rename needed),
#   * the DFT SVF's guide_ungroup maps prescan-hierarchical -> postscan-flat,
#   * scan insertion is verified functionally (test pins tied off below).
# Together with the RTL-vs-prescan LEC (lec_synthesis), this completes the
# RTL -> postscan_dct sign-off. This is NOT black-boxing - it verifies the DFT
# transformation directly.
#
# Run from the work dir (see the 'lec_dft_n2n' Makefile target).
# ------------------------------------------------------------------------------

set start_time [clock seconds] ; echo [clock format ${start_time} -gmt false]
echo [pwd]
print_suppressed_messages

source -echo -verbose ../scripts/design_config.tcl
source -echo -verbose ../scripts/Nanochap_imp_tech.tcl

# ------------------------------------------------------------------------------
# Formality variables (same as the top-level fm.tcl)
# ------------------------------------------------------------------------------
set_app_var verification_assume_reg_init none
set_app_var verification_clock_gate_edge_analysis true
set_app_var verification_inversion_push true
set_app_var hdlin_dwroot ""
set_app_var synopsys_auto_setup true
set_app_var verification_set_undriven_signals "0"
set_app_var verification_verify_directly_undriven_output true

# ------------------------------------------------------------------------------
# Path variables - adjust if your data dir naming differs. dft.tcl writes the
# postscan dir with a dot ('synthesis_postscan_dct.BUD=...'); syn.tcl writes the
# prescan dir with an underscore ('synthesis_prescan_dct_BUD=...').
# ------------------------------------------------------------------------------
set ref_netlist  ../data/synthesis_prescan_dct_BUD=${bottom_up}_${generate_sdf}/${rm_project_top}.prescan_dct.v
set impl_netlist ../data/synthesis_postscan_dct.BUD=${bottom_up}_${generate_sdf}/${rm_project_top}.postscan_dct.v
set dft_svf      ../data/synthesis_postscan_dct.BUD=${bottom_up}_${generate_sdf}/${rm_project_top}.postscan_dct.svf

# ------------------------------------------------------------------------------
# DFT-stage guidance only (records the prescan -> postscan transformation:
# ungroup/flatten of imeas_wrapper, scan insertion, incremental compile). The
# reference IS the prescan netlist, so the RTL-stage SVFs are not needed here.
# ------------------------------------------------------------------------------
if {[file exists $dft_svf]} {
  echo "INFO: loading DFT SVF: $dft_svf"
  set_svf $dft_svf
} else {
  echo "ERROR: DFT SVF not found: $dft_svf"
}

# ------------------------------------------------------------------------------
# Libraries (full-chip gate-level netlists)
# ------------------------------------------------------------------------------
set_app_var search_path [concat . $stdcell_search_path $otp_search_path $io_search_path $ana_search_path $search_path]
read_db $stdcell_library(db,$slow_corner_pvt)
read_db $otp_max_library
read_db $io_max_library
read_db $ana_max_library

# ------------------------------------------------------------------------------
# Reference = prescan_dct netlist
# ------------------------------------------------------------------------------
read_verilog -r -work_library WORK -netlist $ref_netlist
set_top r:/WORK/${rm_project_top}

# ------------------------------------------------------------------------------
# Implementation = postscan_dct netlist
# ------------------------------------------------------------------------------
read_verilog -i -work_library WORK -netlist $impl_netlist
set_top i:/WORK/${rm_project_top}

# ------------------------------------------------------------------------------
# Clock-gate handling (same as fm.tcl)
# ------------------------------------------------------------------------------
set_app_var verification_clock_gate_hold_mode low

set_reference_design      r:/WORK/${rm_project_top}
set_implementation_design i:/WORK/${rm_project_top}

# ------------------------------------------------------------------------------
# Functional mode: tie off the DFT test controls so scan logic is bypassed and
# the gate-to-gate comparison is the functional datapath. (Same ports as fm.tcl.)
# ------------------------------------------------------------------------------
set_constant r:/WORK/${rm_project_top}/iopad_testmode0 0 -type port
set_constant i:/WORK/${rm_project_top}/iopad_testmode0 0 -type port
set_constant r:/WORK/${rm_project_top}/iopad_testmode1 0 -type port
set_constant i:/WORK/${rm_project_top}/iopad_testmode1 0 -type port

match

set rpt_dir ../reports/lec_dft_n2n_${generate_sdf}
sh mkdir -p ${rpt_dir}
report_matched_points         > ${rpt_dir}/${rm_project_top}.matched.fm
report_unmatched_points       > ${rpt_dir}/${rm_project_top}.unmatched.fm
report_setup_status

set status [ verify r:/WORK/${rm_project_top} i:/WORK/${rm_project_top} ]

report_passing_points         > ${rpt_dir}/${rm_project_top}.passed.fm
report_failing_points         > ${rpt_dir}/${rm_project_top}.failed.fm
report_svf_operation -status rejected > ${rpt_dir}/${rm_project_top}.svf_rejected.fm
report_guidance -summary      > ${rpt_dir}/${rm_project_top}.svf_guidance.summary

if {$status == 0} {
  analyze_points -all > ${rpt_dir}/${rm_project_top}.analysis_results
} else {
  echo "Verification SUCCEEDED - no points to analyze" > ${rpt_dir}/${rm_project_top}.analysis_results
}

report_status
print_message_info

set end_time [clock seconds]; echo [clock format ${end_time} -gmt false]
echo "Time elapsed: [clock format [expr ${end_time} - ${start_time}] -format %Hh%Mm%Ss -gmt true]"

exit
