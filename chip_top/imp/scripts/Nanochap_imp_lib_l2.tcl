# ------------------------------------------------------------------------------
# Purpose : PrimeTime Script - Extract .lib for imeas_wrapper (Level 2)
# ------------------------------------------------------------------------------

set start_time [clock seconds] ; echo [clock format ${start_time} -gmt false]

echo [pwd]

source -echo -verbose ../scripts/design_config.tcl
source -echo -verbose ../scripts/Nanochap_imp_tech.tcl

set_app_var search_path [concat . $stdcell_search_path $otp_search_path $io_search_path $ana_search_path $search_path]

if {$corner == "max"} {
    lappend link_path * $stdcell_library(db,$slow_corner_pvt) $otp_max_library $io_max_library $ana_max_library $stdcell_library(db,$fast_corner_pvt) $otp_min_library $io_min_library $ana_min_library
}
if {$corner == "min"} {
    lappend link_path * $stdcell_library(db,$fast_corner_pvt) $otp_min_library $io_min_library $ana_min_library $stdcell_library(db,$slow_corner_pvt) $otp_max_library $io_max_library $ana_max_library
}

# ------------------------------------------------------------------------------
# Read design
# ------------------------------------------------------------------------------

read_verilog ../data/synthesis_l2/imeas_wrapper.scan.v
current_design imeas_wrapper
link

# ------------------------------------------------------------------------------
# Apply constraints
# ------------------------------------------------------------------------------

set rm_project_top imeas_wrapper
source ../data/synthesis_l2/imeas_wrapper.DC.sdc

# ------------------------------------------------------------------------------
# PrimeTime settings
# ------------------------------------------------------------------------------

set timing_remove_clock_reconvergence_pessimism true
set_app_var timing_enable_preset_clear_arcs true
set_app_var report_default_significant_digits 3

suppress_message {MEXT-97}

if {$corner == "max"} {
	set_operating_conditions -library [get_libs $target_library_name($slow_corner_pvt)] $operating_condition_name($slow_corner_pvt)
}

if {$corner == "min"} {
	set_operating_conditions -library [get_libs $target_library_name($fast_corner_pvt)] $operating_condition_name($fast_corner_pvt)
}

# ------------------------------------------------------------------------------
# Timing analysis
# ------------------------------------------------------------------------------

update_timing -full

file mkdir ../data/synthesis_l2
file mkdir ../report/synthesis_l2

report_timing -max_paths 10 > ../report/synthesis_l2/imeas_wrapper.pt_timing_${corner}.rpt
report_constraint -all_violators > ../report/synthesis_l2/imeas_wrapper.pt_violations_${corner}.rpt
report_clock > ../report/synthesis_l2/imeas_wrapper.pt_clocks_${corner}.rpt

# ------------------------------------------------------------------------------
# Extract .lib
# ------------------------------------------------------------------------------

set extract_model_num_capacitance_points 3
set extract_model_num_clock_transition_points 3
set extract_model_num_data_transition_points 3

#extract_model -output ../data/synthesis_l2/imeas_wrapper_${corner} -format lib

# ------------------------------------------------------------------------------
# Exit
# ------------------------------------------------------------------------------

print_message_info

set end_time [clock seconds]; echo [string toupper inform:] End time [clock format ${end_time} -gmt false]

echo "[string toupper inform:] Time elapsed: [format %02d \
                     [expr {($end_time - $start_time)/86400}]]d \
                     [clock format [expr {$end_time - $start_time}] \
                     -format %Hh%Mm%Ss -gmt true]"

exit
