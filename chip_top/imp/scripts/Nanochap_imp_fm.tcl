set start_time [clock seconds] ; echo [clock format ${start_time} -gmt false]

echo [pwd]

print_suppressed_messages

set rm_create_test_wrapper 0

# Stage
# ------------------------------------------------------------------------------
#sh mkdir -p ../data/lec_${stage}
# -----------------------------------------------------------------------------------
# Setup the configuration
# -----------------------------------------------------------------------------------

source -echo -verbose ../scripts/design_config.tcl

# -----------------------------------------------------------------------------------
# Setup the Target Technology
# -----------------------------------------------------------------------------------

source -echo -verbose ../scripts/Nanochap_imp_tech.tcl

# -----------------------------------------------------------------------------------
# Set Formality Variables
# -----------------------------------------------------------------------------------

# Pessimistic analysis mode on constant registers
set verification_assume_reg_init none

# Enable identification of clock gating in the design
set_app_var verification_clock_gate_edge_analysis true

# Account for inversions across register boundaries
set_app_var verification_inversion_push true

# This variable should be set to the top of the Synopsys installation tree
# containing Designware
# If left blank, DesignWare instances are treated as black boxes
set_app_var hdlin_dwroot ""

# -----------------------------------------------------------------------------
# Example variables for investigating equivalence fails
# -----------------------------------------------------------------------------

# Enable auto setup mode using:
set_app_var synopsys_auto_setup true

# Synopsys auto setup mode changes basic settings and includes more SVF info:
# * hdlin_error_on_mismatch_message = false
# * hdlin_ignore_embedded_configuration = true (VHDL only)
# * hdlin_ignore_full_case = false
# * hdlin_ignore_parallel_case = false
# * signature_analysis_allow_subset_match = false
# * svf_ignore_unqualified_fsm_information = false (dependent on SVF)
# * verification_set_undriven_signals = synthesis
# * verification_verify_directly_undriven_output = false

# Restore these values to defaults if using synopsys_auto_setup mode
#set_app_var verification_set_undriven_signals "BINARY:X"
set_app_var verification_set_undriven_signals "0"
set_app_var verification_verify_directly_undriven_output true
#set_app_var hdlin_unresolved_modules black_box

# Switch off the signature analysis
#set_app_var signature_analysis_match_compare_points false
#set_app_var signature_analysis_match_datapath false
#set_app_var signature_analysis_match_hierarchy false

# Increase number of failing points before halting verification (0 = unlimited)
#set_app_var verification_failing_point_limit 0

if {${dc_sel} == "DCT"} {
	set stage ${stage}_dct
}

# -----------------------------------------------------------------------------------
# Read the SVF file created during implementation
# -----------------------------------------------------------------------------------

if {$stage != "postlayout"} {
  set_svf ../data/synthesis_prescan_dct_${generate_sdf}/${rm_project_top}.prescan_dct.svf
}
if {$stage == "postscan" || $stage == "postscan_dct"} {
  set_svf -append ../data/synthesis_${stage}_${generate_sdf}/${rm_project_top}.${stage}.svf
}


#if {$stage == "postscan_pteco"} {
#    set_svf -append ../data/synthesis_postscan_pteco/${rm_project_top}.dft_pteco.svf
#}

#if { ![regexp {synthesis} $netlist] } {
#  set_svf -append ../data/${rm_project_top}.dft.svf
#}

# -----------------------------------------------------------------------------
# Read in the libraries to determine cell functionality
# -----------------------------------------------------------------------------
set_app_var search_path [concat . $stdcell_search_path $otp_search_path $io_search_path $ana_search_path $search_path]

#read_db $stdcell_sdb
read_db $stdcell_library(db,$slow_corner_pvt)
read_db $otp_max_library
read_db $io_max_library
read_db $ana_max_library


# -----------------------------------------------------------------------------------
# Read in the Reference Design ( -> r )
# -----------------------------------------------------------------------------------
if {$stage == "postlayout"} {
read_verilog -r -work_library WORK -netlist ../data/synthesis_postscan/${rm_project_top}.dft.v
} else {
#source -echo -verbose ../scripts/${rm_project_top}_verilog.tcl
exec /bin/csh -c ../scripts/Nanochap_imp_verilog.csh
set f  [open "./rtl.f" r ] 
set file_list [regsub -all {\s+} [read $f] " "];#read into variable and replace whitespace with ,

if {[file exists def.f] == 1 } {
    set d  [open "./def.f" r ] 
    set def_list [regsub -all {\s+} [read $d] " "];#read into variable and replace whitespace with ,
    puts $def_list
    puts $file_list
    read_sverilog -r -work_library WORK  ${file_list} -define $def_list
    close $d
    close $f
    exec rm rtl.f rtl_tmp.f def.f
} else {
    read_sverilog -r -work_library WORK  ${file_list}
    close $f 
    exec rm rtl.f rtl_tmp.f
}


#read_sverilog -r -work_library WORK  $rtl_image
}

set_top r:/WORK/${rm_project_top}

# -----------------------------------------------------------------------------------
# Read in the Implementation Design ( -> i )
# -----------------------------------------------------------------------------------

# Netlist file name ${netlist}.v - is passed through from fm_shell invocation

read_verilog -i -work_library WORK -netlist ../data/synthesis_${stage}_${generate_sdf}/${rm_project_top}.${stage}.v
	
#if {$stage == "postlayout"} {
#read_verilog -i -work_library WORK -netlist 
#}

puts "Verifying netlist of ENS2"

set_top i:/WORK/${rm_project_top}

# -----------------------------------------------------------------------------
# Compare rules to avoid naming concordance differences around generate blocks
# -----------------------------------------------------------------------------

# Mismatching compare points by signature analysis may occur around generate
# blocks. These rules may help the generic and HANDINST_ cells to match

set_compare_rule r:/WORK/${rm_project_top} -from {gen_rar.} -to {}
set_compare_rule i:/WORK/${rm_project_top} -from {gen_rar.} -to {}

set_compare_rule r:/WORK/${rm_project_top} -from {gen_non_rar.} -to {}
set_compare_rule i:/WORK/${rm_project_top} -from {gen_non_rar.} -to {}

# -----------------------------------------------------------------------------------
# Identify the mode of clock gating if used in the design
# -----------------------------------------------------------------------------------
#"collapse_all_cg_cells" - same as "low", but also considers all pri-
#mary output ports and black-box input pins to be candidate  rising-  or
#falling-edge-triggered  clock pins, and ignores clock-gating latches in
#their fan-in as well as those in the fan-in of the clock pins of  known
#flip-flops.
set_app_var verification_clock_gate_hold_mode collapse_all_cg_cells
set_app_var verification_clock_gate_hold_mode low

# -----------------------------------------------------------------------------------
# Set reference and implementation designs
# -----------------------------------------------------------------------------------

set_reference_design  r:/WORK/${rm_project_top}
set_implementation_design  i:/WORK/${rm_project_top}


# -----------------------------------------------------------------------------------
# Configure constant ports (disable scan shift, including test wrapper if applicable)
# -----------------------------------------------------------------------------------
#set_dont_verify_point r:/WORK/Nanochap_ENS2/u_top_ana_wrapper/*
#set_dont_verify_point i:/WORK/Nanochap_ENS2/u_top_ana_wrapper/*


if {$stage == "prescan"} {
# set normal mode
#set_constant  r:/WORK/${rm_project_top}/iopad_testmode0 0 -type port
#set_constant  i:/WORK/${rm_project_top}/iopad_testmode0 0 -type port
#
#set_constant  r:/WORK/${rm_project_top}/iopad_testmode1 0 -type port
#set_constant  i:/WORK/${rm_project_top}/iopad_testmode1 0 -type port
#
#set_dont_verify_point r:/WORK/${rm_project_top}/u_dvdd/pwrBB/VDD
#set_dont_verify_point i:/WORK/${rm_project_top}/u_dvdd/pwrBB/VDD
#set_dont_verify_point r:/WORK/${rm_project_top}/u_iopad_plvpp/pwrBB/VDD
#set_dont_verify_point i:/WORK/${rm_project_top}/u_iopad_plvpp/pwrBB/VDD
#set_dont_verify_point r:/WORK/${rm_project_top}/CLK
#set_dont_verify_point i:/WORK/${rm_project_top}/CLK

}

if {$stage == "postscan" || $stage == "postscan_dct"} {
# set normal mode
set_constant  r:/WORK/${rm_project_top}/iopad_testmode0 0 -type port
set_constant  i:/WORK/${rm_project_top}/iopad_testmode0 0 -type port

set_constant  r:/WORK/${rm_project_top}/iopad_testmode1 0 -type port
set_constant  i:/WORK/${rm_project_top}/iopad_testmode1 0 -type port

#set_dont_verify_point r:/WORK/${rm_project_top}/u_dvdd/pwrBB/VDD
#set_dont_verify_point i:/WORK/${rm_project_top}/u_dvdd/pwrBB/VDD
#set_dont_verify_point r:/WORK/${rm_project_top}/u_iopad_plvpp/pwrBB/VDD
#set_dont_verify_point i:/WORK/${rm_project_top}/u_iopad_plvpp/pwrBB/VDD
#set_dont_verify_point r:/WORK/${rm_project_top}/CLK
#set_dont_verify_point i:/WORK/${rm_project_top}/CLK

}

if {$stage == "postlayout"} {
# scan enable set to 0
set_constant  r:/WORK/${rm_project_top}/iopad_testmode0 0 -type port
set_constant  i:/WORK/${rm_project_top}/iopad_testmode0 0 -type port

set_constant  r:/WORK/${rm_project_top}/iopad_testmode1 0 -type port
set_constant  i:/WORK/${rm_project_top}/iopad_testmode1 0 -type port

#set_constant  r:/WORK/${rm_project_top}/IOBUF_PAD[3] 0 -type port
#set_constant  i:/WORK/${rm_project_top}/IOBUF_PAD[3] 0 -type port

#scan in dont verify
#scan out dont verify

}

#for { set x 0 } {$x <=  ${num_scan_chains} -1  } {incr x} {
#  set_dont_verify_point i:/WORK/${rm_project_top}/${scan_data_out}$x -type port
#  set_dont_verify_point i:/WORK/${rm_project_top}/${scan_data_in}$x -type port
#}

if { $rm_create_test_wrapper } {
  set_constant i:/WORK/${rm_project_top}/${rm_wrp_mode1}  0 -type port
  set_constant i:/WORK/${rm_project_top}/${rm_wrp_mode2}  0 -type port
  set_constant i:/WORK/${rm_project_top}/${rm_wrp_ishift} 0 -type port
  set_constant i:/WORK/${rm_project_top}/${rm_wrp_oshift} 0 -type port
}

# -----------------------------------------------------------------------------------
# Perform matching of compare points
# -----------------------------------------------------------------------------------

## User match for wrapper cells
if { $rm_create_test_wrapper } {
  set_compare_rule -from {/temp_cto_reg} -to {} $impl
}

match

set rpt_dir "../reports/lec_${stage}_${generate_sdf}"
sh mkdir -p ${rpt_dir}
report_matched_points         > ${rpt_dir}/${rm_project_top}.matched.fm
report_unmatched_points -status unread > ${rpt_dir}/${rm_project_top}.unread.fm
report_unmatched_points       > ${rpt_dir}/${rm_project_top}.unmatched.fm

# Report setup status after matching
report_setup_status

# -----------------------------------------------------------------------------------
# Verify the design
# -----------------------------------------------------------------------------------

set status [ verify r:/WORK/${rm_project_top} i:/WORK/${rm_project_top} ]

report_passing_points         > ${rpt_dir}/${rm_project_top}.passed.fm
report_failing_points         > ${rpt_dir}/${rm_project_top}.failed.fm
report_aborted_points         > ${rpt_dir}/${rm_project_top}.aborted.fm
report_constants              > ${rpt_dir}/${rm_project_top}.constants.fm
report_loops                  > ${rpt_dir}/${rm_project_top}.loops.fm
report_undriven_nets          > ${rpt_dir}/${rm_project_top}.undriven_nets.fm
report_multidriven_nets       > ${rpt_dir}/${rm_project_top}.multidriven_nets.fm
report_guidance -summary      > ${rpt_dir}/${rm_project_top}.svf_guidance.summary
report_guidance -to             ${rpt_dir}/${rm_project_top}.svf_guidance.txt
report_libraries -defects all > ${rpt_dir}/${rm_project_top}.defects.fm

# Analyze points and save session if verification unsuccessful
if {$status == 0} {
  analyze_points -all > ${rpt_dir}/${rm_project_top}.analysis_results
  #save_session -replace ../data/lec_${stage}/${rm_project_top}.lec ;# Save session as a .fss file
} else {
  echo "No points analyzed" > ${rpt_dir}/${rm_project_top}.analysis_results
}

# -----------------------------------------------------------------------------
# Report logical equivalence status
# -----------------------------------------------------------------------------

report_status

# -----------------------------------------------------------------------------
# Report message summary and quit
# -----------------------------------------------------------------------------

print_message_info

set end_time [clock seconds]; echo [clock format ${end_time} -gmt false]

# Total script wall clock run time
echo "Time elapsed: [format %02d [expr ( $end_time - $start_time ) / 86400 ]]d\
[clock format [expr ( $end_time - $start_time ) ] -format %Hh%Mm%Ss -gmt true]"

exit
