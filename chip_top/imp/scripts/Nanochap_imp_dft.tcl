# ------------------------------------------------------------------------------
# Purpose : Synthesis Script - Design Compiler DFT insertion script
#
# ------------------------------------------------------------------------------
#set generate_sdf no_sdf;set bottom_up yes;
# ------------------------------------------------------------------------------
# Job Diagnostics
# ------------------------------------------------------------------------------

# Log the time that this script starts executing
set start_time [clock seconds] ; echo [clock format ${start_time} -gmt false]

echo [pwd]

print_suppressed_messages

# ------------------------------------------------------------------------------
# Set-up Design Configuration Options
# ------------------------------------------------------------------------------

source -echo -verbose ../scripts/design_config.tcl

# ------------------------------------------------------------------------------
# Set-up Target Technology
# ------------------------------------------------------------------------------

source -echo -verbose ../scripts/Nanochap_imp_tech.tcl

# -----------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Set-up Target/Link Libraries
# ------------------------------------------------------------------------------

set_app_var synthetic_library dw_foundation.sldb

set_app_var search_path [concat . $stdcell_search_path $otp_search_path $io_search_path $ana_search_path $search_path]
set_app_var symbol_library $stdcell_sdb

set_app_var target_library [concat $stdcell_library(db,$slow_corner_pvt) $stdcell_library(db,$fast_corner_pvt)]

set_app_var link_library [concat * $stdcell_library(db,$slow_corner_pvt) $otp_max_library $io_max_library $ana_max_library $stdcell_library(db,$fast_corner_pvt) $otp_min_library $io_min_library $ana_min_library];# $synthetic_library]


# Set any dont use lists
foreach libraryname [array names dont_use] {
  foreach dontusecelltype $dont_use($libraryname) {
      echo "set_dont_use -power [get_object_name [get_lib_cells ${libraryname}/${dontusecelltype}]]"
      set_dont_use -power [get_lib_cells ${libraryname}/${dontusecelltype}]
      unset dontusecelltype
  }
  unset libraryname
}

# ------------------------------------------------------------------------------
# Create MW design library
# ------------------------------------------------------------------------------

set_app_var mw_design_library $rm_project_top

#sh rm -rf ./$mw_design_library

#create_mw_lib -technology $tech_file \
#	      -mw_reference_library $mw_reference_library \
#	                            $mw_design_library

open_mw_lib $mw_design_library

# Check consistency of logical vs. physical libraries
#check_library

set_tlu_plus_files -max_tluplus $tluplus_file($slow_corner_extraction) \
	           -min_tluplus $tluplus_file($fast_corner_extraction) \
	           -tech2itf_map $tf2itf_map_file

check_tlu_plus_files

set stage postscan_dct

sh mkdir -p ../reports/synthesis_${stage}.BUD=${bottom_up}_${generate_sdf}
sh mkdir -p ../data/synthesis_${stage}.BUD=${bottom_up}_${generate_sdf}

set out_rep  ../reports/synthesis_${stage}.BUD=${bottom_up}_${generate_sdf}
set out_data ../data/synthesis_${stage}.BUD=${bottom_up}_${generate_sdf}

# ------------------------------------------------------------------------------
# Setup for Formality verification
# ------------------------------------------------------------------------------
set_svf $out_data/${rm_project_top}.${stage}.svf


# -----------------------------------------------------------------------------
# Re-apply synthesis tool options
# -----------------------------------------------------------------------------
set_app_var enable_recovery_removal_arcs true
# Case analysis required to support EMA value setting for memories
set_app_var case_analysis_with_logic_constants true

# Allow identification of inserted logic
set_app_var compile_instance_name_prefix DFT_

set_app_var write_name_nets_same_as_ports true
set_app_var report_default_significant_digits 3

# -----------------------------------------------------------------------------
# Read pre-scan insertion synthesis DDC
# -----------------------------------------------------------------------------

read_ddc ../data/synthesis_prescan_dct_BUD=${bottom_up}_${generate_sdf}/${rm_project_top}.prescan_dct.ddc

if {$bottom_up == "yes"} {
  remove_attribute [get_cells u_top_dig/u_imeas_wrapper] dont_touch
  remove_attribute [get_designs -hierarchical *Nanochap_ENS2_imeas_wrapper*] dont_touch
  remove_attribute [get_designs -hierarchical *Nanochap_ENS2_filter_wrapper*] dont_touch

  ungroup [get_cells u_top_dig/u_imeas_wrapper/genblk*] -flatten

  ungroup [get_cells u_top_dig/u_imeas_wrapper] -flatten

  remove_attribute [get_nets -hierarchical *scan*]   dont_touch
  remove_attribute [get_nets -hierarchical *test_se*] dont_touch
  remove_attribute [get_nets -hierarchical *atpg*]   dont_touch
}

# ------------------------------------------------------------------------------
# Function clock and constraints AND Power Intent
# ------------------	
# => A: 1=Normal Mode, 2=CP test Mode, 3=Bist Mode, 4=Scan 
# => B: 1=Internal Clock, 2=External Clock. 
# => C: 1=CPHA 0, 2=CPHA 1.

lappend scenarios S4_min S4_max;#SABC => A: 1=Normal Mode, 2=CP test Mode, 3=Bist Mode, 4=Scan Mode. B: 1=Internal Clock, 2=External Clock. C: 1=OSC, 2=XTAL

foreach i $scenarios { 
  create_scenario $i 
  set_scenario_options -setup true -hold true -cts_mode true -leakage_power true -dynamic_power true -cts_corner min_max
  source -echo -verbose ../scripts/Nanochap_imp_scan_constraints.tcl
  source -echo -verbose ../scripts/Nanochap_imp_scenario_specific.tcl;#common scenario specific command needs to be here
}
set_active_scenarios [all_scenarios]
current_scenario S4_max
# -----------------------------------------------------------------------------
# Link the design
# -----------------------------------------------------------------------------

current_design $rm_project_top

link

check_design -no_warnings
check_design -multiple_designs > \
  $out_rep/${rm_project_top}_initial.check_design

# Disable register merging
set_register_merging [all_registers] false

# ------------------------------------------------------------------------------
# Set design context
# ------------------------------------------------------------------------------
#if {${dc_sel} == "DC"} {set_wire_load_model -name Zero};#no wire load info in lib
#set_dont_touch [get_cells {DNT*} -hierarchical]
#set_dont_touch [remove_from_collection [get_cells {DNT*} -hierarchical] [get_cells u_top_dig/u_pinmux/*/*/DNT*]]
#set_dont_touch [get_nets IOBUF_CS]
#set_dont_touch [get_nets IOBUF_PU]
#set_dont_touch [get_nets IOBUF_PD]
#set_dont_touch [get_nets D2A_*]

#Global ATE Tester Timing Configuration
set test_default_period 100.0   ;# 100 ns cycle
set test_default_delay  5.0     ;# Force all inputs at 5 ns
set test_default_strobe 90.0    ;# Measure all outputs at 90 ns

# ------------------------------------------------------------------------------
# DFT: Add test ports
# ------------------------------------------------------------------------------

set_dft_drc_configuration -internal_pins enable
set num_scan_chains           9        ;# Number of scan chains to be inserted

if {$bottom_up == "yes"} {
  #set_ideal_network [get_pins u_top_dig/u_pinmux/U202/Y]
  set_ideal_network [get_ports IOBUF_PAD[1]]
  set_ideal_network [get_ports iopad_testmode0]
  set_ideal_network [get_ports iopad_testmode1]
  set_ideal_network [get_ports IOBUF_PAD[0]]
}

# ==============================================================================
# 0. Bottom-Up Sub-Block: Protect imeas_wrapper FIRST (before any DFT setup)
# ==============================================================================

#if {$bottom_up == "yes"} {

#  set imeas_inst "u_top_dig/u_imeas_wrapper"

  # Freeze the sub-block prevent any optimization inside it
#  set_dont_touch [get_cells ${imeas_inst}]
#  set_boundary_optimization [get_cells ${imeas_inst}] false
#  set_ungroup [get_cells ${imeas_inst}] false

  # Exclude ALL registers inside imeas_wrapper from top-level scan stitching
#  set_scan_element false [get_cells ${imeas_inst}/* -hierarchical \
#    -filter "is_sequential == true"]
#}
# ------------------------------------------------------------------------------
# 1. Scan In/Out Define
# ------------------------------------------------------------------------------
set_dft_signal -view spec -test_mode all -type ScanDataIn -port [get_ports IOBUF_PAD[3]] -hookup_pin [get_pins u_top_dig/u_pinmux/u_gpio3_pinmux/test0_y]
set_dft_signal -view spec -test_mode all -type ScanDataIn -port [get_ports IOBUF_PAD[4]] -hookup_pin [get_pins u_top_dig/u_pinmux/u_gpio4_pinmux/test0_y]
set_dft_signal -view spec -test_mode all -type ScanDataIn -port [get_ports IOBUF_PAD[5]] -hookup_pin [get_pins u_top_dig/u_pinmux/u_gpio5_pinmux/test0_y]
set_dft_signal -view spec -test_mode all -type ScanDataIn -port [get_ports IOBUF_PAD[6]] -hookup_pin [get_pins u_top_dig/u_pinmux/u_gpio6_pinmux/test0_y]
set_dft_signal -view spec -test_mode all -type ScanDataIn -port [get_ports IOBUF_PAD[7]] -hookup_pin [get_pins u_top_dig/u_pinmux/u_gpio7_pinmux/test0_y]
set_dft_signal -view spec -test_mode all -type ScanDataIn -port [get_ports IOBUF_PAD[8]] -hookup_pin [get_pins u_top_dig/u_pinmux/u_gpio8_pinmux/test0_y]
set_dft_signal -view spec -test_mode all -type ScanDataIn -port [get_ports IOBUF_PAD[9]] -hookup_pin [get_pins u_top_dig/u_pinmux/u_gpio9_pinmux/test0_y]
set_dft_signal -view spec -test_mode all -type ScanDataIn -port [get_ports IOBUF_PAD[10]] -hookup_pin [get_pins u_top_dig/u_pinmux/u_gpio10_pinmux/test0_y]
set_dft_signal -view spec -test_mode all -type ScanDataIn -port [get_ports IOBUF_PAD[11]] -hookup_pin [get_pins u_top_dig/u_pinmux/u_gpio11_pinmux/test0_y]

set_dft_signal -view spec -test_mode all -type ScanDataOut -port [get_ports IOBUF_PAD[12]]  -hookup_pin [get_pins u_top_dig/u_pinmux/scan_out[0]]
set_dft_signal -view spec -test_mode all -type ScanDataOut -port [get_ports IOBUF_PAD[13]]  -hookup_pin [get_pins u_top_dig/u_pinmux/scan_out[1]]
set_dft_signal -view spec -test_mode all -type ScanDataOut -port [get_ports IOBUF_PAD[14]]  -hookup_pin [get_pins u_top_dig/u_pinmux/scan_out[2]]
set_dft_signal -view spec -test_mode all -type ScanDataOut -port [get_ports IOBUF_PAD[15]]  -hookup_pin [get_pins u_top_dig/u_pinmux/scan_out[3]]
set_dft_signal -view spec -test_mode all -type ScanDataOut -port [get_ports IOBUF_PAD[16]]  -hookup_pin [get_pins u_top_dig/u_pinmux/scan_out[4]]
set_dft_signal -view spec -test_mode all -type ScanDataOut -port [get_ports IOBUF_PAD[17]]  -hookup_pin [get_pins u_top_dig/u_pinmux/scan_out[5]]
set_dft_signal -view spec -test_mode all -type ScanDataOut -port [get_ports IOBUF_PAD[18]]  -hookup_pin [get_pins u_top_dig/u_pinmux/scan_out[6]]
set_dft_signal -view spec -test_mode all -type ScanDataOut -port [get_ports IOBUF_PAD[19]]  -hookup_pin [get_pins u_top_dig/u_pinmux/scan_out[7]]
set_dft_signal -view spec -test_mode all -type ScanDataOut -port [get_ports IOBUF_PAD[20]]  -hookup_pin [get_pins u_top_dig/u_pinmux/scan_out[8]]

# ------------------------------------------------------------------------------
# 2. Control Signals
# ------------------------------------------------------------------------------
# Pure Constants (Never change)
set_dft_signal -view existing_dft -type Constant -port [get_ports iopad_testmode1] -active_state 0
set_dft_signal -view spec         -type Constant -port [get_ports iopad_testmode1] -active_state 0
set_dft_signal -view existing_dft -type Constant -port [get_ports CLKSEL] -active_state 0
set_dft_signal -view spec         -type Constant -port [get_ports CLKSEL] -active_state 0

# Test Modes (Drive the define_test_mode encodings)
set_dft_signal -view spec         -type TestMode -port [get_ports iopad_testmode0] -hookup_pin [get_pins u_top_dig/u_pinmux/atpg_en]
set_dft_signal -view existing_dft -type TestMode -port [get_ports iopad_testmode0] -hookup_pin [get_pins u_top_dig/u_pinmux/atpg_en]
set_dft_signal -view spec         -type TestMode -port [get_ports IOBUF_PAD[2]] -hookup_pin [get_pins u_top_dig/u_pinmux/u_gpio2_pinmux/test0_y]
set_dft_signal -view existing_dft -type TestMode -port [get_ports IOBUF_PAD[2]] -hookup_pin [get_pins u_top_dig/u_pinmux/u_gpio2_pinmux/test0_y]

# Reset
set_dft_signal -view existing_dft -type Reset -port [get_ports RESETn] -hookup_pin [get_pins u_iopad_exresetn/Y] -active_state 0

# Scan Clock & Scan Enable
set_dft_signal -view existing_dft -type ScanClock -timing {35 65} -port [get_ports IOBUF_PAD[0]] -hookup_pin [get_pins u_top_dig/u_pinmux/u_gpio0_pinmux/test0_y]
set_dft_signal -view spec         -type ScanClock                 -port [get_ports IOBUF_PAD[0]] -hookup_pin [get_pins u_top_dig/u_pinmux/u_gpio0_pinmux/test0_y]

set_dft_signal -view spec         -type ScanEnable -port [get_ports IOBUF_PAD[1]] -hookup_pin [get_pins u_top_dig/u_pinmux/scan_en] -active_state 1
set_dft_signal -view existing_dft -type ScanEnable -port [get_ports IOBUF_PAD[1]] -hookup_pin [get_pins u_top_dig/u_pinmux/scan_en] -active_state 1

# ------------------------------------------------------------------------------
# 3. Test Mode Definitions & Compression Config
# ------------------------------------------------------------------------------
define_test_mode internal_scan -usage scan \
    -encoding {iopad_testmode0 1 u_top_dig/u_pinmux/atpg_en 1 \
               IOBUF_PAD[2] 0 u_top_dig/u_pinmux/u_gpio2_pinmux/test0_y 0}
define_test_mode compress_scan -usage scan_compression \
    -encoding {iopad_testmode0 1 u_top_dig/u_pinmux/atpg_en 1 \
               IOBUF_PAD[2] 1 u_top_dig/u_pinmux/u_gpio2_pinmux/test0_y 1}

set_dft_configuration -scan_compression enable

set_scan_compression_configuration \
    -base_mode internal_scan \
    -test_mode compress_scan \
    -chain_count 18 \
    -inputs 9 \
    -outputs 9

set_scan_configuration -style multiplexed_flip_flop  \
                       -clock_mixing mix_clocks \
                       -create_dedicated_scan_out_ports true \
                       -chain_count ${num_scan_chains} \
                       -add_lockup true \
                       -lockup_type latch \
                       -test_mode internal_scan \
                       -replace false

# ------------------------------------------------------------------------------
# 4. Scan Path Define (top-level chains)
# ------------------------------------------------------------------------------
set_scan_path chain0 -view spec -test_mode internal_scan \
    -scan_data_in IOBUF_PAD[3]  -scan_data_out IOBUF_PAD[12]
set_scan_path chain1 -view spec -test_mode internal_scan \
    -scan_data_in IOBUF_PAD[4]  -scan_data_out IOBUF_PAD[13]
set_scan_path chain2 -view spec -test_mode internal_scan \
    -scan_data_in IOBUF_PAD[5]  -scan_data_out IOBUF_PAD[14]
set_scan_path chain3 -view spec -test_mode internal_scan \
    -scan_data_in IOBUF_PAD[6]  -scan_data_out IOBUF_PAD[15]
set_scan_path chain4 -view spec -test_mode internal_scan \
    -scan_data_in IOBUF_PAD[7]  -scan_data_out IOBUF_PAD[16]
set_scan_path chain5 -view spec -test_mode internal_scan \
    -scan_data_in IOBUF_PAD[8]  -scan_data_out IOBUF_PAD[17]
set_scan_path chain6 -view spec -test_mode internal_scan \
    -scan_data_in IOBUF_PAD[9]  -scan_data_out IOBUF_PAD[18]
set_scan_path chain7 -view spec -test_mode internal_scan \
    -scan_data_in IOBUF_PAD[10]  -scan_data_out IOBUF_PAD[19]
set_scan_path chain8 -view spec -test_mode internal_scan \
    -scan_data_in IOBUF_PAD[11]  -scan_data_out IOBUF_PAD[20]

# ==============================================================================
# 5. Bottom-Up Sub-Block: Declare existing scan chains in imeas_wrapper
# ==============================================================================
#if {$bottom_up == "yes"} {

  # --- Pre-connect b_scan_clk ---
#  set scan_clk_net [get_nets -of_objects \
#      [get_pins u_top_dig/u_pinmux/scan_clk] -quiet]
#  if {[sizeof_collection $scan_clk_net] > 0} {
#    set cur [get_nets -of_objects [get_pins ${imeas_inst}/b_scan_clk] -quiet]
#    if {[sizeof_collection $cur] > 0 && \
#        [get_object_name $cur] != [get_object_name $scan_clk_net]} {
#      disconnect_net $cur [get_pins ${imeas_inst}/b_scan_clk]
#    }
#    connect_net $scan_clk_net [get_pins ${imeas_inst}/b_scan_clk]
#    echo "INFO: b_scan_clk -> [get_object_name $scan_clk_net]"
#  }

  # --- Pre-connect b_scan_en ---
#  set scan_en_net [get_nets -of_objects \
#      [get_pins u_top_dig/u_pinmux/scan_en] -quiet]
#  if {[sizeof_collection $scan_en_net] > 0} {
#    set cur [get_nets -of_objects [get_pins ${imeas_inst}/b_scan_en] -quiet]
#    if {[sizeof_collection $cur] > 0 && \
#        [get_object_name $cur] != [get_object_name $scan_en_net]} {
#      disconnect_net $cur [get_pins ${imeas_inst}/b_scan_en]
#    }
#    connect_net $scan_en_net [get_pins ${imeas_inst}/b_scan_en]
#    echo "INFO: b_scan_en  -> [get_object_name $scan_en_net]"
#  }


#  set_dft_signal -view existing_dft -type ScanClock \
#    -port [get_ports IOBUF_PAD[0]] -timing {35 65}

#  set_dft_signal -view existing_dft -type ScanEnable \
#    -port [get_ports IOBUF_PAD[1]] \
#    -hookup_pin [get_pins ${imeas_inst}/b_scan_en] \
#    -active_state 1 -test_mode all

#  set_dft_signal -view existing_dft -type ScanDataIn \
#    -hookup_pin [get_pins ${imeas_inst}/b_scan_in0] -test_mode all
#  set_dft_signal -view existing_dft -type ScanDataIn \
#    -hookup_pin [get_pins ${imeas_inst}/b_scan_in1] -test_mode all
#  set_dft_signal -view existing_dft -type ScanDataIn \
#    -hookup_pin [get_pins ${imeas_inst}/b_scan_in2] -test_mode all

  # --- internal_scan: hookup_pin only (DC routes to dedicated scan_out port) ---
#  set_dft_signal -view existing_dft -type ScanDataOut \
#    -hookup_pin [get_pins ${imeas_inst}/b_scan_out0] -test_mode internal_scan
#  set_dft_signal -view existing_dft -type ScanDataOut \
#    -hookup_pin [get_pins ${imeas_inst}/b_scan_out1] -test_mode internal_scan
#  set_dft_signal -view existing_dft -type ScanDataOut \
#    -hookup_pin [get_pins ${imeas_inst}/b_scan_out2] -test_mode internal_scan

  # --- compress_scan: add -port so DC knows the output pad AND inserts
  #     XOR compressor between b_scan_out* and scan_out[1/2/3] automatically.
  #     DC already knows IOBUF_PAD[8] <-> scan_out[1] from section 1 declaration.
  #     This gives DC a complete path: b_scan_out* -> [XOR] -> scan_out[*] -> pad
  #     WITHOUT consuming the port before the compressor is built. ---
#  set_dft_signal -view existing_dft -type ScanDataOut \
#    -port [get_ports IOBUF_PAD[8]] \
#    -hookup_pin [get_pins ${imeas_inst}/b_scan_out0] -test_mode compress_scan
#  set_dft_signal -view existing_dft -type ScanDataOut \
#    -port [get_ports IOBUF_PAD[9]] \
#    -hookup_pin [get_pins ${imeas_inst}/b_scan_out1] -test_mode compress_scan
#  set_dft_signal -view existing_dft -type ScanDataOut \
#    -port [get_ports IOBUF_PAD[10]] \
#    -hookup_pin [get_pins ${imeas_inst}/b_scan_out2] -test_mode compress_scan

  # --- internal_scan chains ---
#  set_scan_path imeas_chain0 -view existing_dft \
#    -scan_data_in  ${imeas_inst}/b_scan_in0 \
#    -scan_data_out ${imeas_inst}/b_scan_out0 \
#    -test_mode internal_scan -complete true

#  set_scan_path imeas_chain1 -view existing_dft \
#    -scan_data_in  ${imeas_inst}/b_scan_in1 \
#    -scan_data_out ${imeas_inst}/b_scan_out1 \
#    -test_mode internal_scan -complete true

#  set_scan_path imeas_chain2 -view existing_dft \
#    -scan_data_in  ${imeas_inst}/b_scan_in2 \
#    -scan_data_out ${imeas_inst}/b_scan_out2 \
#    -test_mode internal_scan -complete true

  # --- compress_scan chains ---
#  set_scan_path imeas_chain0_comp -view existing_dft \
#    -scan_data_in  ${imeas_inst}/b_scan_in0 \
#    -scan_data_out ${imeas_inst}/b_scan_out0 \
#    -test_mode compress_scan -complete true

#  set_scan_path imeas_chain1_comp -view existing_dft \
#    -scan_data_in  ${imeas_inst}/b_scan_in1 \
#    -scan_data_out ${imeas_inst}/b_scan_out1 \
#    -test_mode compress_scan -complete true

#  set_scan_path imeas_chain2_comp -view existing_dft \
#    -scan_data_in  ${imeas_inst}/b_scan_in2 \
#    -scan_data_out ${imeas_inst}/b_scan_out2 \
#    -test_mode compress_scan -complete true
#}
# -----------------------------------------------------------------------------
# 6. DFT Final Configuration
# -----------------------------------------------------------------------------
#set_scan_state test_ready

set_dft_insertion_configuration -preserve_design_name true
set_dft_insertion_configuration -synthesis_optimization all

set_app_var power_cg_auto_identify true

set_fix_multiple_port_nets -all -buffer_constants [get_designs]

set_dft_drc_rules -ignore {TEST-504}
set_dft_drc_rules -ignore {TEST-505}

# -----------------------------------------------------------------------------
# Close the SVF before the test-protocol / scan-insertion section.
# Everything Formality needs from this stage to bridge the bottom-up flow has
# already been recorded above: the read_ddc of the pre-synthesized blocks and
# the "ungroup -flatten" of u_imeas_wrapper (guide_ungroup). That guidance is
# what lets the L2/L3 sub-block guidance (filter/imeas datapath and inv_push for
# U_filter_iir_hpf/accum_reg[*]) re-map onto the flattened top-level netlist.
# Keeping the SVF open past this point would additionally record the test-mode
# setup (define_test_mode / create_test_protocol), which Formality replays as
# set_constant on iopad_testmode0, scan-enable IOBUF_PAD[1], IOBUF_PAD[2],
# u_pinmux/atpg_en and u_gpio*_pinmux/test0_y - the constant churn we want to
# avoid. Scan logic is verified functionally via the scan-enable constant in
# fm.tcl, so the insert_dft guidance is not required for the functional LEC.
# -----------------------------------------------------------------------------
set_svf -off

create_test_protocol
# -----------------------------------------------------------------------------
# DFT: Scan chain insertion
# -----------------------------------------------------------------------------
# Use the -verbose option of dft_drc to assist in debugging if necessary
dft_drc -verbose > $out_rep/${rm_project_top}.initial_dft_drc

report_scan_configuration > $out_rep/${rm_project_top}.scan_configuration
report_dft_insertion_configuration > $out_rep/${rm_project_top}.dft_insertion_configuration

# Use the '-show all -test_points all' options to preview_dft for more detail
preview_dft > $out_rep/${rm_project_top}.preview_dft

insert_dft
current_test_mode compress_scan
dft_drc -v > $out_rep/${rm_project_top}.insert_dft_drc

# -----------------------------------------------------------------------------
# Additional optimization constraints
# -----------------------------------------------------------------------------
# Control DRC/Fanout for tie cells
# This allows a fanout of 1 on tie cells to be set:
set_auto_disable_drc_nets -constant false

# new cells at top level 
set_app_var compile_no_new_cells_at_top_level false

remove_attribute [get_cells {DNT*} -hierarchical] dont_touch
remove_attribute [get_nets IOBUF_PD] dont_touch
remove_attribute [get_nets scan_*] dont_touch
remove_attribute [get_nets -hierarchical *test_se*] dont_touch
remove_attribute [get_nets -hierarchical *scan_en*] dont_touch

if {$bottom_up == "yes"} {
  #remove_ideal_network [get_pins u_top_dig/u_pinmux/U202/Y]
  remove_ideal_network [get_ports IOBUF_PAD[1]]
  remove_ideal_network [get_ports IOBUF_PAD[0]]
  remove_ideal_network [get_ports iopad_testmode0]
  remove_ideal_network [get_ports iopad_testmode1]
}

# -----------------------------------------------------------------------------
# DFT: Post DFT incremental optimization
# -----------------------------------------------------------------------------

# Incremental compile required after scan chain insertion
set spg_congestion_placement_in_incremental_compile true 
compile_ultra -check_only
compile_ultra -incremental

# -----------------------------------------------------------------------------
# DFT: Write out test protocols and reports
# -----------------------------------------------------------------------------

# write_scan_def adds SCANDEF info to the design database in memory so this
# must be performed prior to writing out the design
write_scan_def -output $out_data/${rm_project_top}.dft_scandef

check_scan_def > $out_rep/${rm_project_top}.check_scan_def

write_test_model -format ctl -output $out_data/${rm_project_top}.dft_ctl

current_test_mode internal_scan
report_dft_signal > $out_rep/${rm_project_top}.dft_signals_internal
dft_drc -verbose > $out_rep/${rm_project_top}.dft_drc_internal
report_scan_path > $out_rep/${rm_project_top}.scanpath_internal
report_scan_path -chain all > $out_rep/${rm_project_top}.scanpath_chain_internal
report_scan_path -cell  all > $out_rep/${rm_project_top}.scanpath_cell_internal
write_test_protocol -names verilog -test_mode internal_scan -output $out_data/${rm_project_top}.dft_scan_spf_internal

current_test_mode compress_scan
report_dft_signal > $out_rep/${rm_project_top}.dft_signals
dft_drc -verbose > $out_rep/${rm_project_top}.dft_drc
report_scan_path > $out_rep/${rm_project_top}.scanpath
report_scan_path -chain all > $out_rep/${rm_project_top}.scanpath_chain
report_scan_path -cell  all > $out_rep/${rm_project_top}.scanpath_cell
write_test_protocol -names verilog -test_mode compress_scan -output $out_data/${rm_project_top}.dft_scan_spf

# -----------------------------------------------------------------------------
# Change names before output
# -----------------------------------------------------------------------------

# If this will be a sub-block in a hierarchical design, uniquify with block
# unique names to avoid name collisions when integrating the design at the top
# level
set_app_var uniquify_naming_style ${rm_project_top}_%s_%d
#if {$bottom_up != "yes"} {
  uniquify -force
#}

define_name_rules verilog -case_insensitive
change_names -rules verilog -hierarchy -verbose > $out_rep/${rm_project_top}.change_names

# ------------------------------------------------------------------------------
# Write out design data
# ------------------------------------------------------------------------------

#remove modules whose all outputs are floating
source ../scripts/Nanochap_imp_rm_float.tcl
# Execute the procedure
find_and_remove_fully_floating_modules

set_app_var verilogout_higher_designs_first true
set_app_var verilogout_no_tri true

write -f verilog  -hierarchy -output $out_data/${rm_project_top}.${stage}.v

#write -format ddc -hierarchy -output $out_data/${rm_project_top}.${stage}.max.ddc

# ------------------------------------------------------------------------------
# Write out design data
# ------------------------------------------------------------------------------

# Write and close SVF file, make it available for immediate use
set_svf -off

# Write parasitics data from DCT placement for static timing analysis
write_parasitics -output $out_data/${rm_project_top}.${stage}.spef

# Write SDF backannotation data from DCT placement for static timing analysis
write_sdf $out_data/${rm_project_top}.${stage}.max.sdfv2 -context verilog

# Do not write out net RC info into SDC
set_app_var write_sdc_output_lumped_net_capacitance false
set_app_var write_sdc_output_net_resistance false

lappend scenarios S111_min S112_min S121_min S122_min S22_min S3_min S111_max S112_max S121_max S122_max S22_max S3_max; 
foreach i $scenarios { 

    current_scenario $i
    
    #use following sdc files for sta and post cts
    if {$generate_sdf == "sdf"} {
      set_clock_uncertainty -hold  0.05 [all_clocks]
      remove_clock_transition [all_clocks]
    }

    write_sdc -version 2.0 -nosplit ${out_data}/${rm_project_top}.${stage}.scre_[current_scenario].sdc
}
foreach i $scenarios { 

    current_scenario $i
    
    report_clock -skew
    source -echo -verbose ../scripts/Nanochap_imp_reports.tcl
}
current_scenario S111_max
# If SAIF is used, write out SAIF name mapping file for PrimeTime-PX
saif_map -type ptpx -write_map $out_rep/${rm_project_top}_SAIF.namemap

#write_icc2_files -output $out_data/${rm_project_top}.${stage}.icc2 -force
write_def -components -output $out_data/${rm_project_top}.${stage}.def
write_environment -consistency -output $out_data/${rm_project_top}.${stage}.env
#analyze_rtl_congestion > $out_rep/${rm_project_top}.congestion

# ------------------------------------------------------------------------------
# Insert scan chains and report estimated scan coverage
# ------------------------------------------------------------------------------

current_scenario S4_max

dft_drc -verbose -coverage_estimate > \
  $out_rep/${rm_project_top}.scan_estimate


# ------------------------------------------------------------------------------
# Report message summary and quit
# ------------------------------------------------------------------------------

print_message_info

set end_time [clock seconds]; echo [string toupper inform:] End time [clock format ${end_time} -gmt false]

# Total script wall clock run time
echo "[string toupper inform:] Time elapsed: [format %02d \
                     [expr ($end_time - $start_time)/86400]]d \
                    [clock format [expr ($end_time - $start_time)] \
                    -format %Hh%Mm%Ss -gmt true]"
exit

# ------------------------------------------------------------------------------
# End of File
# ------------------------------------------------------------------------------
