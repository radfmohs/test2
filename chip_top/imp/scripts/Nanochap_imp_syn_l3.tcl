# ------------------------------------------------------------------------------
# Purpose : Synthesis Script - Synthesis
#
# ------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Job Diagnostics
# ------------------------------------------------------------------------------

set start_time [clock seconds] ; echo [clock format ${start_time} -gmt false]

echo [pwd]

print_suppressed_messages

suppress_message {ELAB-311}

sh rm -rf WORK*
sh rm -rf alib*
sh rm -rf elab

#set generate_sdf no_sdf

# -----------------------------------------------------------------------------------
# Setup the configuration
# -----------------------------------------------------------------------------------

source -echo -verbose ../scripts/design_config.tcl

# ------------------------------------------------------------------------------
# Set-up Target Technology
# ------------------------------------------------------------------------------
source -echo -verbose ../scripts/Nanochap_imp_tech.tcl

# ------------------------------------------------------------------------------
# Set-up Target/Link Libraries
# ------------------------------------------------------------------------------

set_app_var synthetic_library dw_foundation.sldb

set_app_var search_path [concat . $stdcell_search_path $otp_search_path $io_search_path $ana_search_path $search_path]
set_app_var symbol_library $stdcell_sdb

set_app_var target_library [concat $stdcell_library(db,$slow_corner_pvt) $stdcell_library(db,$fast_corner_pvt)]

set_app_var link_library [concat * $stdcell_library(db,$slow_corner_pvt) $otp_max_library $io_max_library $ana_max_library $stdcell_library(db,$fast_corner_pvt) $otp_min_library $io_min_library $ana_min_library];# $synthetic_library]

# ------------------------------------------------------------------------------
# Associate libraries with min libraries
# ------------------------------------------------------------------------------

# Set any dont use lists
foreach libraryname [array names dont_use] {
  foreach dontusecelltype $dont_use($libraryname) {
      echo "set_dont_use -power [get_object_name [get_lib_cells ${libraryname}/${dontusecelltype}]]"
      set_dont_use -power [get_lib_cells ${libraryname}/${dontusecelltype}]
      unset dontusecelltype
  }
  unset libraryname
}

set hdlin_infer_multibit default_all
#set_app_var mw_reference_library [concat $stdcell_mw_library $pad_mw_library $vpp_mw_library $otp_mw_library $ana_mw_library]

# ------------------------------------------------------------------------------
# Create MW design library
# ------------------------------------------------------------------------------

#set_app_var mw_design_library $rm_project_top

#sh rm -rf ./$mw_design_library

#create_mw_lib -technology $tech_file \
#	      -mw_reference_library $mw_reference_library \
	                            $mw_design_library

#open_mw_lib $mw_design_library

# Default to read Verilog as standard version 2001 (not 2005)
set_app_var hdlin_vrlg_std 2001

# Don't optimize constants for Formality and ID registers.
set_app_var compile_seqmap_propagate_constants false

# Identify architecturally instantiated clock gates
# Note: This application variable must be set BEFORE the RTL is read in.
set_app_var power_cg_auto_identify true

# Emit guide_hier_map into this block's SVF so its design-scoped guidance maps
# correctly inside the flattened/instantiated hierarchy at the top. Paired with
# set_verification_top after link.
set_app_var hdlin_enable_hier_map true

# Check for latches in RTL
set_app_var hdlin_check_no_latch true

# Setup RTL files and paths
define_design_lib work -path elab
set_app_var compile_no_new_cells_at_top_level false

#set_host_options -max_cores 8

# CPPR 
set timing_remove_clock_reconvergence_pessimism true

# ------------------------------------------------------------------------------
# Apply synthesis tool options
# ------------------------------------------------------------------------------

set_app_var enable_recovery_removal_arcs true
#set_app_var compile_top_all_paths 	true
#set verilogout_architecture_name 		        "structural"
#set verilogout_write_components 			true

# Case analysis required to support EMA value setting for memories
set_app_var case_analysis_with_logic_constants true

set_app_var write_name_nets_same_as_ports true
set_app_var report_default_significant_digits 3

# Set to enable full range of flops for synthesis consideration
set compile_filter_prune_seq_cells false
set remove_constant_register true
set remove_unloaded_register true

# Set constant not optimization
set_app_var compile_enable_constant_propagation_with_no_boundary_opt false

#Controls the identification of shift registers in compile -scan.
#This feature is only supported in test-ready compile with Design
#Compiler Ultra with a multiplexed scan style.

set_app_var compile_seqmap_identify_shift_registers false
#set_app_var compile_disable_hierarchical_inverter_opt true

# ------------------------------------------------------------------------------
# Clock gating setup 
# ------------------------------------------------------------------------------

set_app_var compile_clock_gating_through_hierarchy true
set_app_var power_cg_balance_stages true

set_clock_gating_style -sequential_cell latch \
                       -positive_edge_logic $icg_name \
                       -control_point before \
                       -control_signal scan_enable \
                       -minimum_bitwidth 8 \
                       -num_stages 2 \
                       -max_fanout 32

###################################################### LEVEL 3 individual channel filter compile

analyze -autoread  {../../../../logical/imeas/rtl/filter_wrapper.sv ../../../../logical/imeas/rtl/filter_ctrl.sv ../../../../logical/imeas/rtl/filter_fir_lpf.sv ../../../../logical/imeas/rtl/filter_iir_hpf.v ../../../../logical/imeas/rtl/notch_filter.sv ../../../../logical/imeas/rtl/imeas.sv ../../../../logical/imeas/rtl/imeas_cdc.sv ../../../../logical/imeas/rtl/imeas_cic.sv ../../../../logical/imeas/rtl/imeas_ctrl.sv ../../../../logical/imeas/rtl/imeas_reg.sv ../../../common/common_pulse_rising.v ../../../common/common_pulse_sync.v ../../../common/common_bit_sync.v}
# Elaborate WITH the parameter it is instantiated with (DATA_WIDTH=24).
# imeas_wrapper instantiates filter_wrapper #(.DATA_WIDTH(24)), so the rest of
# the flow (and Formality elaborating the RTL) names this design
# 'filter_wrapper_DATA_WIDTH24'. Elaborating it bare here would name it
# 'filter_wrapper', and every SVF guidance command (constant/ungroup/merge/
# inv_push...) would be scoped to that non-existent name and get rejected,
# causing the filter datapath to fail LEC. Keeping the name parameter-qualified
# makes the guidance bind.
elaborate filter_wrapper -parameters "DATA_WIDTH=24"
link

# Mark the verification top so DC writes guide_hier_map for this block.
set_verification_top

# Disable register merging
set_register_merging [all_registers] false
# Control DRC/Fanout for tie cells
# This allows a fanout of 1 on tie cells to be set:
set_auto_disable_drc_nets -constant false
# Prevent assignment statements in the Verilog netlist.
set_fix_multiple_port_nets -all -buffer_constants [get_designs]
# Target 6 routing layers
#set_ignored_layers -min_routing_layer METAL1
#set_ignored_layers -max_routing_layer METAL5
#report_ignored_layers

#lappend scenarios S111_min S112_min S121_min S122_min S22_min S3_min S111_max S112_max S121_max S122_max S22_max S3_max;#SXYZ => X: 1=Normal Mode, 2=CP test Mode, 3=Bist Mode. Y: 1=Internal Clock, 2=External Clock. Z: 1=CPHA 0, 2=CPHA 1.
set rm_project_top filter_wrapper
#foreach i $scenarios { 
#    create_scenario $i 
#    set_scenario_options -setup true -hold true -cts_mode true -leakage_power true -dynamic_power true -cts_corner min_max
    set i DC
    source -echo -verbose ../scripts/Nanochap_imp_filters_constraints.tcl
    source -echo -verbose ../scripts/Nanochap_imp_scenario_specific.tcl
#}

#set_active_scenarios [all_scenarios]
#current_scenario S111_max

# ------------------------------------------------------------------------------
# Setup for Formality verification (bottom-up sub-block)
# The clock gating inserted below (-gate) must be captured in an SVF so that
# Formality can match the resulting clock-gating latches when this block is
# read/flattened at the top level. Without it, these latches show up as
# unmatched implementation "Clock-gate LAT" compare points.
# ------------------------------------------------------------------------------
file mkdir ../data/synthesis_l3
set_svf ../data/synthesis_l3/filter_wrapper.svf

#compile_ultra -check
compile_ultra -scan -gate

file mkdir ../data/synthesis_l3
file mkdir ../report/synthesis_l3

# create canonical scan boundary ports
#create_port -direction in  {b_scan_clk b_scan_en b_testmode b_scan_in}
#create_port -direction out {b_scan_out}

#set_dft_signal -view spec         -type ScanClock   -port b_scan_clk
#set_dft_signal -view existing_dft -type ScanClock   -port b_scan_clk -timing {35 65}

#set_dft_signal -view spec -type ScanEnable  -port b_scan_en   -active_state 1
#set_dft_signal -view spec -type ScanDataIn  -port b_scan_in
#set_dft_signal -view spec -type ScanDataOut -port b_scan_out
#set_dft_signal -view spec -type TestMode    -port atpg_en     ;# block test mode

# Resets stay resets only (do NOT use as scan ports)
#foreach r {presetn cic_rst_n} {
#  set_dft_signal -view spec         -type Reset -port $r -active_state 0
#  set_dft_signal -view existing_dft -type Reset -port $r -active_state 0
#}

# Functional test clocks for DRC/control
#set func_clks {clk notch_clk lpf_clk hpf_clk pclk adc_clk}
#foreach c $func_clks {
#  set_dft_signal -view spec         -type TestClock -port $c
#  set_dft_signal -view existing_dft -type TestClock -port $c -timing {45 55}
#}

# Scan config
#set_scan_configuration -style multiplexed_flip_flop \
#                       -clock_mixing mix_clocks \
#                       -add_lockup true -lockup_type latch \
#                       -chain_count 1 -replace true
#set_dft_configuration  -scan_compression disable
#set_dft_insertion_configuration -preserve_design_name true -synthesis_optimization none

# Test timing
#set test_default_period 100.0
#set test_default_delay  5.0
#set test_default_strobe 90.0

#create_test_protocol -capture_procedure multi_clock

#dft_drc -verbose > ../report/synthesis_l3/dft_drc_l3.log
#insert_dft
#compile_ultra -incremental

change_names -rules verilog -hierarchy

write -f verilog -hierarchy -output ../data/synthesis_l3/filter_wrapper.v

#write_milkyway -output [get_object_name [current_design]] -overwrite
write -format ddc -hierarchy -output ../data/synthesis_l3/single_channel.ddc

# Write and close SVF file, make it available for immediate use
set_svf -off

#foreach i $scenarios {
#  current_scenario $i
  set i DC
  write_sdc -version 2.1 -nosplit ../data/synthesis_l3/filter_wrapper.${i}.sdc
#}

print_message_info

set end_time [clock seconds]; echo [string toupper inform:] End time [clock format ${end_time} -gmt false]

# Total script wall clock run time
echo "[string toupper inform:] Time elapsed: [format %02d \
                     [expr {($end_time - $start_time)/86400}]]d \
                     [clock format [expr {$end_time - $start_time}] \
                     -format %Hh%Mm%Ss -gmt true]"

exit

# ------------------------------------------------------------------------------
# End of File
# ------------------------------------------------------------------------------
