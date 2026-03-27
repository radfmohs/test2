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

# -----------------------------------------------------------------------------------
# Setup the configuration
# -----------------------------------------------------------------------------------

source -echo -verbose ../scripts/design_config.tcl

# ------------------------------------------------------------------------------
# Set-up Target Technology
# ------------------------------------------------------------------------------
source -echo -verbose ../scripts/Nanochap_imp_tech.tcl

sh rm -rf WORK*
sh rm -rf alib*
sh rm -rf elab

# ------------------------------------------------------------------------------
# Set-up Target/Link Libraries
# ------------------------------------------------------------------------------

set_app_var synthetic_library dw_foundation.sldb

set_app_var search_path [concat . $stdcell_search_path $otp_search_path $io_search_path $ana_search_path $search_path]
set_app_var symbol_library $stdcell_sdb

set_app_var target_library [concat $stdcell_library(db,$slow_corner_pvt) $stdcell_library(db,$fast_corner_pvt)]

set_app_var link_library "* $target_library single_channel.ddc"
set_app_var mw_reference_library [concat . $stdcell_mw_library $pad_mw_library $vpp_mw_library $otp_mw_library $ana_mw_library]
set_app_var mw_reference_library [concat $mw_reference_library filter_wrapper]

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

# Default to read Verilog as standard version 2001 (not 2005)
set_app_var hdlin_vrlg_std 2001

# Don't optimize constants for Formality and ID registers.
set_app_var compile_seqmap_propagate_constants false

# Identify architecturally instantiated clock gates
# Note: This application variable must be set BEFORE the RTL is read in.
set_app_var power_cg_auto_identify true

# Check for latches in RTL
set_app_var hdlin_check_no_latch true

# Setup RTL files and paths
define_design_lib work -path elab
set_app_var compile_no_new_cells_at_top_level true

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

###################################################### LEVEL 2 all filters together compile
set_app_var mw_design_library $rm_project_top
open_mw_lib $mw_design_library

analyze -format sverilog {../../../../logical/imeas/rtl/imeas_wrapper.sv ../../../common/common_bit_sync.v ../../../common/common_pulse_async_clr.v ../../../common/common_rst_sync.v ../../../common/common_sync_bit.v}
elaborate imeas_wrapper
link

current_design filter_wrapper
reset_design
current_design imeas_wrapper

set_dont_touch [get_designs filter_wrapper]
get_attribute [get_designs "*filter_wrapper*"] is_mapped
get_attribute [get_designs "*filter_wrapper*"] dont_touch
#report_reference

# Disable register merging
set_register_merging [all_registers] false
# Control DRC/Fanout for tie cells
# This allows a fanout of 1 on tie cells to be set:
set_auto_disable_drc_nets -constant false
# Prevent assignment statements in the Verilog netlist.
set_fix_multiple_port_nets -all -buffer_constants [get_designs]
# Target 6 routing layers
set_ignored_layers -min_routing_layer METAL1
set_ignored_layers -max_routing_layer METAL5
report_ignored_layers

set target_designs { "*imeas_wrapper*" }
current_design [get_object_name [get_designs "*imeas_wrapper*"]]
set rm_project_top imeas_wrapper

lappend scenarios S111_min S112_min S121_min S122_min S22_min S3_min S111_max S112_max S121_max S122_max S22_max S3_max;#SXYZ => X: 1=Normal Mode, 2=CP test Mode, 3=Bist Mode. Y: 1=Internal Clock, 2=External Clock. Z: 1=CPHA 0, 2=CPHA 1.
foreach i $scenarios { 
    current_scenario $i 
    set_scenario_options -setup true -hold true -cts_mode true -leakage_power true -dynamic_power true -cts_corner min_max
    source -echo -verbose ../scripts/Nanochap_imp_filters_constraints.tcl
    source -echo -verbose ../scripts/Nanochap_imp_scenario_specific.tcl
}

set_active_scenarios [all_scenarios]
current_scenario S111_max

compile_ultra -check
compile_ultra -scan -gate_clock -no_autoungroup -no_boundary_optimization

uniquify -force
write_milkyway -output [get_object_name [current_design]] -overwrite
write -format ddc -hierarchy -output imeas_wrapper.ddc
set_dont_touch [current_design] true

# ------------------------------------------------------------------------------
# Report message summary and quit
# ------------------------------------------------------------------------------

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
