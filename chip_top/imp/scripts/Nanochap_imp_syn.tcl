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
set_app_var mw_reference_library [concat $stdcell_mw_library $pad_mw_library $vpp_mw_library $otp_mw_library $ana_mw_library]
#set_mw_lib_reference -mw_reference_library [concat $stdcell_mw_library]

# ------------------------------------------------------------------------------
# Create MW design library
# ------------------------------------------------------------------------------

set_app_var mw_design_library $rm_project_top

set stage prescan_dct

set out_rep  ../reports/synthesis_${stage}_${generate_sdf}
set out_data ../data/synthesis_${stage}_${generate_sdf}

sh mkdir -p $out_rep
sh mkdir -p $out_data

set_svf ../data/synthesis_${stage}_${generate_sdf}/${rm_project_top}.${stage}.BUD=${bottom_up}.svf

# ------------------------------------------------------------------------------
# Setup for SAIF name mapping database
# ------------------------------------------------------------------------------

saif_map -start

# ------------------------------------------------------------------------------
# Read in the design verilog RTL
# ------------------------------------------------------------------------------

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

remove_design -all
if {$bottom_up == "yes"} {
  set_app_var link_library [concat * $stdcell_library(db,$slow_corner_pvt) $otp_max_library $io_max_library $ana_max_library $stdcell_library(db,$fast_corner_pvt) $otp_min_library $io_min_library $ana_min_library imeas_wrapper.ddc];# $synthetic_library]
  set_app_var mw_reference_library [concat . $stdcell_mw_library $pad_mw_library $vpp_mw_library $otp_mw_library $ana_mw_library]
  set_app_var mw_reference_library [concat $mw_reference_library imeas_wrapper]
  open_mw_lib $mw_design_library
} else {
  sh rm -rf ./$mw_design_library

  create_mw_lib -technology $tech_file \
  	      -mw_reference_library $mw_reference_library \
  	                            $mw_design_library

  open_mw_lib $mw_design_library

  # Check consistency of logical vs. physical libraries
  # check_library
}

#source -echo -verbose ../scripts/${rm_project_top}_verilog.tcl

sh rm -rf WORK*
sh rm -rf alib*
sh rm -rf elab

if {[file exists elab] == 1 } {puts "directory elab exists"} else {file mkdir elab}

exec /bin/csh -c ../scripts/Nanochap_imp_verilog.csh

set f  [open "./rtl.f" r ] 
set file_list [regsub -all {\s+} [read $f] " "];#read into variable and replace whitespace with ,

if {$bottom_up == "yes"} {
  set file_list [lsearch -all -inline -not $file_list {*logical/imeas/*}]
  set file_list [lsearch -all -inline -not $file_list {*logical/filter/*}]
}

if {[file exists def.f] == 1 } {
    set d  [open "./def.f" r ] 
    set def_list [regsub -all {\s+} [read $d] " "];#read into variable and replace whitespace with ,
    puts $def_list
    puts $file_list
    redirect -tee ../reports/synthesis_${stage}_${generate_sdf}/${rm_project_top}.read_file { \
    	read_file -define $def_list $file_list -auto -top ${rm_project_top}};#read in
    close $d
    close $f
    exec rm rtl.f rtl_tmp.f def.f
} else {
    redirect -tee ../reports/synthesis_${stage}_${generate_sdf}/${rm_project_top}.read_file { \
    analyze  $file_list -auto -top ${rm_project_top}}
    close $f 
    exec rm rtl.f rtl_tmp.f
}

	#read_file $file_list -auto -top ${rm_project_top}}
# Tee elaboration output to separate log file
redirect -tee ../reports/synthesis_${stage}_${generate_sdf}/${rm_project_top}.elaborate { \
  elaborate -architecture verilog ${rm_project_top}}

if {$bottom_up == "yes"} {
  set_dont_touch [get_designs imeas_wrapper]
  get_attribute [get_designs "imeas_wrapper"] is_mapped
  get_attribute [get_designs "imeas_wrapper"] dont_touch
}
# ------------------------------------------------------------------------------
# Link the design
# ------------------------------------------------------------------------------

current_design $rm_project_top

link

if {$bottom_up == "yes"} {
  current_design imeas_wrapper
  reset_design
  current_design $rm_project_top
}
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


set_clock_gating_objects -exclude u_top_dig/u_spi_top/spi_reg_u/*u_spi_reg_wavegen/*_reg*;#no need to clk gate spi as it is not active all the time (reducing area)
set_clock_gating_objects -exclude u_top_dig/u_spi_top/spi_reg_u/*_reg*
set_clock_gating_objects -exclude u_top_dig/u_otp_ctrl_top/u_eprom_bist_top/*/*_reg*;#no need to clk gate bist as it is active at test time
set_clock_gating_objects -exclude u_top_dig/u_otp_ctrl_top/*/*_reg*;#otp has its own clock gate


set_compile_directives -constant_propagation false [get_pins u_top_dig/VPP_OTP]

#set_dont_touch [get_cells {DNT*} -hierarchical]
set_dont_touch [remove_from_collection [get_cells {DNT*} -hierarchical] [get_cells u_top_dig/u_pinmux/*/*/DNT*]]
#set_dont_touch [get_nets IOBUF_CS]
#set_dont_touch [get_nets IOBUF_PU]
set_dont_touch [get_nets IOBUF_PD]
#set_dont_touch [get_nets D2A_*]
set_dont_touch [get_nets scan_*]

set_dont_touch [get_nets D2A_*]
set_dont_touch [get_nets A2D_*]

set_dont_touch_network [get_pins u_top_dig/u_pinmux/scan_out*]
set_dont_touch [get_nets u_top_dig/u_pinmux/*/test0_y] 

# ------------------------------------------------------------------------------
# boundary optimization false 
# ------------------------------------------------------------------------------
#set_boundary_optimization u_top_dig/u_pinmux false
#set_boundary_optimization u_top_dig/u_pinmux/u_gpio*_pinmux false
#set_boundary_optimization u_top_dig/u_pinmux/u_gpio*_pinmux/u_* false
#set_boundary_optimization [get_cells u_top_dig] false ;

#set_clock_gating_objects -exclude [get_cells u_top_dig/u_spi_top/spi_reg_u/reg_rd_data_reg[*]]
#set_clock_gating_objects -exclude [get_cells u_top_dig/u_lead_off_detector/lead_off_result_reg]

#set_boundary_optimization u_top_dig/u_spi_top/spi_reg_u false

##################################################
#set_multibit_options -mode none
#set_app_var spg_enable_zroute_layer_promotion true
set_app_var physopt_enable_via_res_support true
#set_app_var spg_enhanced_timing_model true
#set_app_var physopt_enable_root_via_res_support true
#set_compile_spg_mode ICC;#or ICC2

#set compile_timing_high_effort true
#set compile_timing_high_effort_tns true
#set psynopt_tns_high_effort true
set placer_tns_driven true
set_app_var placer_max_cell_density_threshold 0.65
set_app_var placer_enable_enhanced_router true
set_app_var compile_prefer_mux true
#set_app_var compile_high_pin_density_cell_optimization true
#set_app_var compile_high_pin_density_cell_optimization_utilization_threshold 0.3

#placement based banking with physically aware clock gating
set_app_var power_cg_physically_aware_cg true

#help ICC with its setup violation in specific paths
#set p1 [create_net_search_pattern -setup_slack_upper_limit "-1.0" -connect_to_port]
#set p2 [create_net_search_pattern -setup_slack_upper_limit "-2.0" -net_length_lower_limit 50]

#set_net_search_pattern_delay_estimation_options -pattern $p1 \
#	-min_layer_name M7 -max_layer_name M10
#set_net_search_pattern_delay_estimation_options -pattern $p2 \
#	-min_layer_name M9 -max_layer_name M10

#to reduce via resitance between layers, via ladder can be define
#Example via ladder defined using Tcl command 
#create_via_rule -name VL3 \
#	-cut_layer_names {VIA1 VIA2 VIA3} \
#	-cut_names {Vs Vs Vs} \
#	-cut_rows {2 2 1 } \
#	-cuts_per_row {1 2 2}


# run this in ICC and provide result below: write_def -version 5.7 -rows_tracks_gcells -macro -pins -blockages -specialnets -vias -regions_groups -verbose -output my_physical_data.def
#extract_physical_constraints /projects/libs/ens2/digital_work/GY_ENS2_DIG/pnr/ens2_run2_0606/Nanochap_ENS2_physical_data.def
###############################################

# ------------------------------------------------------------------------------
# Function clock and constraints for TOP level
# ------------------------------------------------------------------------------
lappend scenarios S111_min S112_min S121_min S122_min S22_min S3_min S111_max S112_max S121_max S122_max S22_max S3_max;#SXYZ => X: 1=Normal Mode, 2=CP test Mode, 3=Bist Mode. Y: 1=Internal Clock, 2=External Clock. Z: 1=CPHA 0, 2=CPHA 1.
foreach i $scenarios { 
  if {$bottom_up == "yes"} {
    current_scenario $i 
  } else {
    create_scenario $i 
  }
  set_scenario_options -setup true -hold true -cts_mode true -leakage_power true -dynamic_power true -cts_corner min_max
  source -echo -verbose ../scripts/Nanochap_imp_constraints.tcl
  #source -echo -verbose ../scripts/Nanochap_imp_constraints_exception.tcl;#these are not written in SDC. Need to reaply in STA
  source -echo -verbose ../scripts/Nanochap_imp_scenario_specific.tcl;#common scenario specific command needs to be here
}
set_active_scenarios [all_scenarios]
current_scenario S111_max


#write -f verilog  -hierarchy -output ../data/synthesis_${stage}_${generate_sdf}/${rm_project_top}.link.v
check_design -no_warnings
check_design -multiple_designs > \
  ../reports/synthesis_${stage}_${generate_sdf}/${rm_project_top}_initial.check_design

compile_ultra -check
compile_ultra  -scan -gate_clock -no_autoungroup; # -spg;# -self_gating;#use place_opt -spg in ICC

# ------------------------------------------------------------------------------
# Change names before output
# ------------------------------------------------------------------------------

# If this will be a sub-block in a hierarchical design, uniquify with block
# unique names to avoid name collisions when integrating the design at the top
# level
set_app_var uniquify_naming_style ${rm_project_top}_%s_%d
uniquify -force

define_name_rules verilog -case_insensitive
change_names -rules verilog -hierarchy -verbose > \
  ../reports/synthesis_${stage}_${generate_sdf}/${rm_project_top}.change_names

# ------------------------------------------------------------------------------
# Write out design data
# ------------------------------------------------------------------------------
set_app_var verilogout_higher_designs_first true
set_app_var verilogout_no_tri true
# set_app_var power_cg_auto_identify true

#sh mkdir ../data
write -format ddc -hierarchy -output ../data/synthesis_${stage}_${generate_sdf}/${rm_project_top}.${stage}.BUD=${bottom_up}.ddc
write -f verilog  -hierarchy -output ../data/synthesis_${stage}_${generate_sdf}/${rm_project_top}.${stage}.BUD=${bottom_up}.v

# Write and close SVF file, make it available for immediate use
set_svf -off

# Write parasitics data from DCT placement for static timing analysis
write_parasitics -output ../data/synthesis_${stage}_${generate_sdf}/${rm_project_top}.${stage}.BUD=${bottom_up}.spef

# Write SDF backannotation data from DCT placement for static timing analysis
write_sdf ../data/synthesis_${stage}_${generate_sdf}/${rm_project_top}.${stage}.BUD=${bottom_up}.sdf

# Do not write out net RC info into SDC
set_app_var write_sdc_output_lumped_net_capacitance false
set_app_var write_sdc_output_net_resistance false

# Write out SDC version 2.0 to omit set_voltage for backwards compatibility
write_sdc -version 2.1 -nosplit ../data/synthesis_${stage}_${generate_sdf}/${rm_project_top}.${stage}.BUD=${bottom_up}.sdc

# If SAIF is used, write out SAIF name mapping file for PrimeTime-PX
saif_map -type ptpx -write_map ../reports/synthesis_${stage}_${generate_sdf}/${rm_project_top}_SAIF.namemap

######################################################################################
# ------------------------------------------------------------------------------
# Reports
# ------------------------------------------------------------------------------
#foreach i $scenarios { 
#    current_scenario $i
#    source -echo -verbose ../scripts/Nanochap_imp_reports.tcl
#}
#current_scenario S111_max

report_scenarios

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
