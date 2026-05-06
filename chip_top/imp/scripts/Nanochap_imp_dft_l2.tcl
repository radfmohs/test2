set start_time [clock seconds] ; echo [clock format ${start_time} -gmt false]

echo [pwd]

print_suppressed_messages

suppress_message {ELAB-311}

sh rm -rf WORK*
sh rm -rf alib*
sh rm -rf elab

set bus_naming_style {%s[%d]}

source -echo -verbose ../scripts/design_config.tcl
source -echo -verbose ../scripts/Nanochap_imp_tech.tcl

set_app_var synthetic_library dw_foundation.sldb

set_app_var search_path [concat . $stdcell_search_path $otp_search_path $io_search_path $ana_search_path $search_path]
set_app_var symbol_library $stdcell_sdb

set_app_var target_library [concat $stdcell_library(db,$slow_corner_pvt) $stdcell_library(db,$fast_corner_pvt)]

set_app_var link_library "* $target_library ../data/synthesis_l2/imeas_wrapper.prescan.ddc"

foreach libraryname [array names dont_use] {
  foreach dontusecelltype $dont_use($libraryname) {
      echo "set_dont_use -power [get_object_name [get_lib_cells ${libraryname}/${dontusecelltype}]]"
      set_dont_use -power [get_lib_cells ${libraryname}/${dontusecelltype}]
      unset dontusecelltype
  }
  unset libraryname
}

set hdlin_infer_multibit default_all
set_app_var hdlin_vrlg_std 2001
set_app_var compile_seqmap_propagate_constants false
set_app_var power_cg_auto_identify true
set_app_var hdlin_check_no_latch true
define_design_lib work -path elab
set_app_var compile_no_new_cells_at_top_level true
set timing_remove_clock_reconvergence_pessimism true
set_app_var enable_recovery_removal_arcs true
set_app_var case_analysis_with_logic_constants true
set_app_var write_name_nets_same_as_ports true
set_app_var report_default_significant_digits 3
set compile_filter_prune_seq_cells false
set remove_constant_register true
set remove_unloaded_register true
set_app_var compile_enable_constant_propagation_with_no_boundary_opt false
set_app_var compile_seqmap_identify_shift_registers false
set_app_var compile_clock_gating_through_hierarchy true
set_app_var power_cg_balance_stages true

set_clock_gating_style -sequential_cell latch \
                       -positive_edge_logic $icg_name \
                       -control_point before \
                       -control_signal scan_enable \
                       -minimum_bitwidth 8 \
                       -num_stages 2 \
                       -max_fanout 32

###################################################### LEVEL 2 DFT

read_ddc ../data/synthesis_l2/imeas_wrapper.prescan.ddc

link

set target_designs { "imeas_wrapper" }
current_design imeas_wrapper
set rm_project_top imeas_wrapper

# ==========================================================================
# Protect filter_wrapper
# ==========================================================================
set_dont_touch [get_designs filter_wrapper]
set_dont_touch [get_cells -h "*filter_wrapper*"]
set_ungroup [get_cells -h "*filter_wrapper*"] false
set_boundary_optimization [get_cells -h "*filter_wrapper*"] false

# ==========================================================================
# Create imeas_wrapper scan ports FIRST (so nets can be created)
# ==========================================================================
create_port b_scan_clk  -direction in
create_port b_scan_en   -direction in
create_port b_scan_in0  -direction in
create_port b_scan_in1  -direction in
create_port b_scan_in2  -direction in
create_port b_scan_out0 -direction out
create_port b_scan_out1 -direction out
create_port b_scan_out2 -direction out

# ==========================================================================
# Disconnect constants tied to filter_wrapper scan pins (tied to 1'b0 by
# Level 2 synthesis because the RTL doesn't know about these DFT ports)
# ==========================================================================
foreach inst [get_object_name [get_cells -h "genblk1_*__u_filter_wrapper"]] {
  foreach pin {b_scan_clk b_scan_en b_scan_in b_testmode} {
    set net [get_nets -of_objects [get_pins ${inst}/${pin}] -quiet]
    if {[sizeof_collection $net] > 0} {
      disconnect_net $net [get_pins ${inst}/${pin}]
    }
  }
}

# ==========================================================================
# Wire scan clock, scan enable, and test mode to all 16 instances
# ==========================================================================
create_net b_scan_clk_net
connect_net b_scan_clk_net [get_ports b_scan_clk]
foreach inst [get_object_name [get_cells -h "genblk1_*__u_filter_wrapper"]] {
  connect_net b_scan_clk_net [get_pins ${inst}/b_scan_clk]
}

create_net b_scan_en_net
connect_net b_scan_en_net [get_ports b_scan_en]
foreach inst [get_object_name [get_cells -h "genblk1_*__u_filter_wrapper"]] {
  connect_net b_scan_en_net [get_pins ${inst}/b_scan_en]
}

foreach inst [get_object_name [get_cells -h "genblk1_*__u_filter_wrapper"]] {
  connect_net [get_nets atpg_en] [get_pins ${inst}/b_testmode]
}

# Do NOT manually chain b_scan_in/b_scan_out between instances.
# Leave them unconnected insert_dft will route them into the 3 chains.

# ==========================================================================
# Declare filter_wrapper's existing scan chain from Level 3
# ==========================================================================
current_design filter_wrapper
set_scan_state test_ready

set_dft_signal -view existing_dft -type ScanClock  -port b_scan_clk -timing {35 65}
set_dft_signal -view existing_dft -type ScanEnable -port b_scan_en  -active_state 1
set_dft_signal -view existing_dft -type ScanDataIn  -port b_scan_in
set_dft_signal -view existing_dft -type ScanDataOut -port b_scan_out
set_dft_signal -view existing_dft -type TestMode    -port atpg_en

set_scan_path filter_existing_chain -view existing_dft \
  -scan_data_in  b_scan_in \
  -scan_data_out b_scan_out

set_scan_element false [get_cells -hierarchical -filter "is_sequential == true"]

current_design imeas_wrapper

# ==========================================================================
# DFT signal declarations for imeas_wrapper
# ==========================================================================
set_dft_signal -view spec         -type ScanClock   -port b_scan_clk
set_dft_signal -view existing_dft -type ScanClock   -port b_scan_clk -timing {35 65}

set_dft_signal -view spec -type ScanEnable -port b_scan_en -active_state 1
set_dft_signal -view spec -type TestMode   -port atpg_en

set_dft_signal -view spec -type ScanDataIn  -port {b_scan_in0 b_scan_in1 b_scan_in2}
set_dft_signal -view spec -type ScanDataOut -port {b_scan_out0 b_scan_out1 b_scan_out2}

foreach r {adc_resetn adc_ctrl_resetn cic_rst_n filter_rstn} {
  set_dft_signal -view spec         -type Reset -port $r -active_state 0
  set_dft_signal -view existing_dft -type Reset -port $r -active_state 0
}

set_dft_signal -view spec         -type TestClock -port [get_ports {adc_clk_running pclk clk[*] notch_clk[*] lpf_clk[*] hpf_clk[*] imeas_pclk[*] imeas_dig_adc_clk[*]}]
set_dft_signal -view existing_dft -type TestClock -port [get_ports {adc_clk_running pclk clk[*] notch_clk[*] lpf_clk[*] hpf_clk[*] imeas_pclk[*] imeas_dig_adc_clk[*]}] -timing {45 55}

set_scan_configuration -style multiplexed_flip_flop \
                       -clock_mixing mix_clocks \
                       -add_lockup true -lockup_type latch \
                       -chain_count 3

set_dft_configuration  -scan_compression disable
set_dft_insertion_configuration -preserve_design_name true -synthesis_optimization none

set test_default_period 100.0
set test_default_delay  5.0
set test_default_strobe 90.0

set_case_analysis 1 [get_ports atpg_en]

create_test_protocol -capture_procedure single_clock
dft_drc -verbose > ../report/synthesis_l2/dft_drc_l2.log

insert_dft

# ==========================================================================
# Verify filter_wrapper was NOT uniquified
# ==========================================================================
list_designs *filter_wrapper*

compile_ultra -incremental -no_autoungroup

change_names -rules verilog -hierarchy

write -f verilog -hierarchy -output ../data/synthesis_l2/imeas_wrapper.scan.v

#write_milkyway -output [get_object_name [current_design]] -overwrite
write -format ddc -hierarchy -output ../data/synthesis_l2/imeas_wrapper.ddc

#foreach i $scenarios {
#  current_scenario $i
  set i DC
  write_sdc -version 2.0 -nosplit ../data/synthesis_l2/imeas_wrapper.${i}.sdc
#}

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
