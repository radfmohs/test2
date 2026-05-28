set start_time [clock seconds] ; echo [clock format ${start_time} -gmt false]

echo [pwd]

print_suppressed_messages

#set stage postscan_dct
#set bottom_up yes
#set scenario S111_max
#set dmsa yes

sh mkdir -p ../reports/synthesis_postscan_pteco_sdf
sh mkdir -p ../data/synthesis_postscan_pteco_sdf

# -----------------------------------------------------------------------------------
# Setup the Target Technology
# -----------------------------------------------------------------------------------
set dc_sel  DC;#PT doesn't need routing information
source -echo -verbose ../scripts/design_config.tcl

# ------------------------------------------------------------------------------
# Set-up Target Technology
# ------------------------------------------------------------------------------

source -echo -verbose ../scripts/Nanochap_imp_tech.tcl

# ------------------------------------------------------------------------------
# Set-up Target/Link Libraries
# ------------------------------------------------------------------------------

set_app_var search_path [concat . $stdcell_search_path $otp_search_path $io_search_path $ana_search_path $search_path]
if {[string match *_max $scenario]} {
    set_app_var link_path [concat * $stdcell_library(db,$slow_corner_pvt) $otp_max_library $io_max_library $ana_max_library $stdcell_library(db,$fast_corner_pvt) $otp_min_library $io_min_library $ana_min_library]
}
if {[string match *_min $scenario]} {
    set_app_var link_path [concat * $stdcell_library(db,$fast_corner_pvt) $otp_min_library $io_min_library $ana_min_library $stdcell_library(db,$slow_corner_pvt) $otp_max_library $io_max_library $ana_max_library]
}
# -----------------------------------------------------------------------------------
# PT Setting
# -----------------------------------------------------------------------------------
set timing_disable_clock_gating_checks false
set timing_slew_propagation_mode worst_slew
set rc_degrade_min_slew_when_rd_less_than_met true
set si_enable_analysis false
set si_xtalk_double_switching_mode clock_network
set report_default_significant_digits 4
set timing_update_status_level high

# -----------------------------------------------------------------------------------
# PX Setting
# -----------------------------------------------------------------------------------
set_app_var power_enable_analysis true
set power_enable_multi_rail_analysis true 
#set power_enable_concurrent_event_analysis false
set_app_var power_use_c1cn_pin_capacitance true;#Setup C1CN Pin Capacitance support
set_app_var power_enable_clock_cycle_based_glitch true

# -----------------------------------------------------------------------------------
# Read design and sdc
# -----------------------------------------------------------------------------------
read_verilog ../data/synthesis_${stage}.BUD=${bottom_up}_sdf/${rm_project_top}.$stage.v

link_design  $rm_project_top
current_design $rm_project_top

set eco_instance_name_prefix "uECO_${scenario}"
set eco_net_name_prefix "uECO_${scenario}"
source -echo -verbose ../data/synthesis_${stage}.BUD=${bottom_up}_sdf/${rm_project_top}.postscan_dct.scre_${scenario}.sdc

set_operating_conditions     -max $operating_condition_name($slow_corner_pvt) -max_lib [get_libs $target_library_name($slow_corner_pvt)]     -min $operating_condition_name($fast_corner_pvt) -min_lib [get_libs $target_library_name($fast_corner_pvt)]     -analysis_type on_chip_variation
#if {$corner == "max"} {
#	set_operating_conditions -library [get_libs $target_library_name($slow_corner_pvt)] $operating_condition_name($slow_corner_pvt)
#}
#
#if {$corner == "min"} {
#	set_operating_conditions -library [get_libs $target_library_name($fast_corner_pvt)] $operating_condition_name($fast_corner_pvt) 
#}
# Timing derate
set_timing_derate -early 0.95
set_timing_derate -late 1.05

# Power analysis setting
set_app_var power_analysis_mode averaged
set_switching_activity -toggle_rate .25 -glitch_rate .05 -static_probability .015 -type inputs;

# CPPR 
set_app_var timing_remove_clock_reconvergence_pessimism true
set_propagated_clock [filter_collection [all_clocks] defined(sources)]

#reset_timing_derate

# -----------------------------------------------------------------------------------
# Update timing and Check timing
# -----------------------------------------------------------------------------------
update_timing -full
update_power
#set fname_time [clock format [clock seconds] -format {%H%M}]
#report_constraint -all_violators > ../reports/synthesis_postscan_sdf/all_vio_${stage}_${corner}_${mode}_pteco_${fname_time}.rpt
#report_timing -slack_lesser_than 0.0 -delay min_max -nosplit -input -net -cap -path full_clock > ../reports/synthesis_postscan_sdf/${rm_project_top}_${fname_time}.timing_vio_min
if {[info exist scenario]} {
  report_constraint -all_violators > ../reports/synthesis_postscan_pteco_sdf/all_vio_${scenario}_pteco_before_fix.rpt
}

set eco_report_unfixed_reason_max_endpoints 1
#set eco_save_session_data_type "timing drc"
save_session session_${scenario}; #DMSA is enabled. save session, analyse all sessions at once later

print_message_info

set end_time [clock seconds]; echo [clock format ${end_time} -gmt false]

# Total script wall clock run time
echo "Time elapsed: [format %02d [expr ( $end_time - $start_time ) / 86400 ]]d\
[clock format [expr ( $end_time - $start_time ) ] -format %Hh%Mm%Ss -gmt true]"

exit
