set start_time [clock seconds] ; echo [clock format ${start_time} -gmt false]

echo [pwd]

print_suppressed_messages

#set stage prescan
#set corner max
set mode functional
#set scenario s1
set generate_sdf sdf
set dc_sel  DC;#PT doesn't need routing information

sh mkdir -p ../reports/pt_${stage}_${corner}

# -----------------------------------------------------------------------------------
# Setup the configuration
# -----------------------------------------------------------------------------------

source -echo -verbose ../scripts/design_config.tcl

# -----------------------------------------------------------------------------------
# Setup the Target Technology
# -----------------------------------------------------------------------------------

source -echo -verbose ../scripts/Nanochap_imp_tech.tcl

# -----------------------------------------------------------------------------------
# Search path and link path
# -----------------------------------------------------------------------------------


set_app_var search_path [concat . $stdcell_search_path $otp_search_path $io_search_path $ana_search_path $search_path]

if {$corner == "max"} {
    lappend link_path * $stdcell_library(db,$slow_corner_pvt) $otp_max_library $io_max_library $ana_max_library $stdcell_library(db,$fast_corner_pvt) $otp_min_library $io_min_library $ana_min_library
}
if {$corner == "typ"} {
    lappend link_path * $stdcell_library(db,$typ_corner_pvt)  $otp_typ_library $io_typ_library $ana_typ_library $stdcell_library(db,$slow_corner_pvt) $otp_max_library $io_max_library $ana_max_library
}
if {$corner == "min"} {
    lappend link_path * $stdcell_library(db,$fast_corner_pvt) $otp_min_library $io_min_library $ana_min_library $stdcell_library(db,$slow_corner_pvt) $otp_max_library $io_max_library $ana_max_library
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

# -----------------------------------------------------------------------------------
# Read design and sdc
# -----------------------------------------------------------------------------------

if {$generate_sdf == "no_sdf"} {
	read_verilog ../data/synthesis_${stage}/${rm_project_top}.${stage}.v
} else {
	read_verilog ../data/synthesis_${stage}_${generate_sdf}/${rm_project_top}.${stage}.v
}

link_design  $rm_project_top
current_design $rm_project_top

if {$mode == "scan"} {
	source -verbose -echo ../scripts/Nanochap_imp_scan_constraints.tcl
} else {
    if {$generate_sdf == "no_sdf"} {
	    if {[info exist scenario]} {
	      source -echo -verbose ../data/synthesis_postscan_dct_no_sdf/${rm_project_top}.postscan_dct.${scenario}.sdc
	    } else {
	      source -echo -verbose ../data/synthesis_postscan_no_sdf/${rm_project_top}.postscan_dct.${scenario}.sdc
	    }
    } else {
      if {[info exist scenario]} {
	      source -echo -verbose ../data/synthesis_postscan_dct_sdf/${rm_project_top}.postscan_dct.${scenario}.sdc
	    } else {
	      source -echo -verbose ../data/synthesis_postscan_sdf/${rm_project_top}.postscan.sdc
	    }
    }
}

# -----------------------------------------------------------------------------------
# Back Annotation Section
# -----------------------------------------------------------------------------------

#if {$generate_sdf != "no_sdf"} {
#	read_parasitics -format SPEF ../data/synthesis_${stage}_${generate_sdf}/${rm_project_top}.${stage}.spef
#}

# -----------------------------------------------------------------------------------
# Clock Tree Synthesis Section
# -----------------------------------------------------------------------------------

set_propagated_clock [filter_collection [all_clocks] defined(sources)]

# -----------------------------------------------------------------------------------
# Operation Condition Setting
# -----------------------------------------------------------------------------------

if {$corner == "max"} {
	set_operating_conditions -library [get_libs $target_library_name($slow_corner_pvt)] $operating_condition_name($slow_corner_pvt)
}

if {$corner == "typ"} {
	set_operating_conditions -library [get_libs $target_library_name($typ_corner_pvt)] $operating_condition_name($typ_corner_pvt) 
}

if {$corner == "min"} {
	set_operating_conditions -library [get_libs $target_library_name($fast_corner_pvt)] $operating_condition_name($fast_corner_pvt) 
}

# Timing derate
set_timing_derate -early 0.95
set_timing_derate -late 1.05

# CPPR 
set timing_remove_clock_reconvergence_pessimism true

# -----------------------------------------------------------------------------------
# Update timing and Check timing
# -----------------------------------------------------------------------------------
update_timing -full

check_timing -verbose > ../reports/pt_${stage}_${corner}/check_timing_${mode}.rpt
check_constraints -verbose > ../reports/pt_${stage}_${corner}/check_constraints_${mode}.rpt
#report_constraint -all_violators > ../reports/pt_${stage}_${corner}/all_vio_${stage}_${corner}_${mode}_before.rpt

# -----------------------------------------------------------------------------------
# Report timing 
# -----------------------------------------------------------------------------------

report_timing -slack_lesser_than 0.0 -delay min_max -nosplit -input -net -cap -path full_clock > ../reports/pt_${stage}_${corner}/report_timing_${mode}.rpt

report_clock -skew -attribute > ../reports/pt_${stage}_${corner}/clock_skew_${mode}.rpt
report_analysis_coverage > ../reports/pt_${stage}_${corner}/analysis_coverage_${mode}.rpt

report_analysis_coverage -status_details untested -check_type setup > ../reports/pt_${stage}_${corner}/untested_setup_${mode}.rpt
report_analysis_coverage -status_details untested -check_type hold > ../reports/pt_${stage}_${corner}/untested_hold_${mode}.rpt
report_analysis_coverage -status_details untested -check_type recovery > ../reports/pt_${stage}_${corner}/untested_recovery_${mode}.rpt
report_analysis_coverage -status_details untested -check_type removal > ../reports/pt_${stage}_${corner}/untested_removal_${mode}.rpt
report_analysis_coverage -status_details untested -check_type min_period > ../reports/pt_${stage}_${corner}/untested_min_period_${mode}.rpt
report_analysis_coverage -status_details untested -check_type min_pulse_width > ../reports/pt_${stage}_${corner}/untested_min_pulse_width_${mode}.rpt
report_analysis_coverage -status_details untested -check_type clock_gating_setup > ../reports/pt_${stage}_${corner}/untested_clock_gating_setup_${mode}.rpt
report_analysis_coverage -status_details untested -check_type clock_gating_hold > ../reports/pt_${stage}_${corner}/untested_clock_gating_hold_${mode}.rpt
report_analysis_coverage -status_details untested -check_type out_setup > ../reports/pt_${stage}_${corner}/untested_out_setup_${mode}.rpt
report_analysis_coverage -status_details untested -check_type out_hold > ../reports/pt_${stage}_${corner}/untested_out_hold_${mode}.rpt

if {[info exist scenario]} {
    report_constraint -all_violators > ../reports/pt_${stage}_${corner}/all_vio_${stage}_${corner}_${mode}_${scenario}.rpt
} else {
    report_constraint -all_violators > ../reports/pt_${stage}_${corner}/all_vio_${stage}_${corner}_${mode}.rpt
}

report_annotated_parasitics -max_nets 100 -list_not_annotated > ../reports/pt_${stage}_${corner}/not_annotated_${mode}.rpt

report_global_timing > ../reports/pt_${stage}_${corner}/global_timing_${mode}.rpt

if {$stage == "postscan_pteco"} {
	#write_sdf -version 3.0 ../data/synthesis_${stage}_sdf/${rm_project_top}.${stage}.${corner}_${mode}.sdfv3 -context verilog -exclude_cells {u_top_dig/u_otp_ctrl_top/u_512x8_otp}
	write_sdf -version 3.0 ../data/synthesis_${stage}_sdf/${rm_project_top}.${stage}.${corner}_${mode}_${scenario}.sdfv3 -context verilog 
}
if {($stage == "postscan_pteco") && ($mode == "scan")} {
    write_sdc -version 2.0 -nosplit ../data/synthesis_${stage}_sdf/${rm_project_top}.${stage}_${mode}.sdc
}

if {([info exist scenario] && ${scenario} != "S4") || ([info exist scenario==0] && $mode != "scan")} {
    if {([info exist scenario] && [string match S11? ${scenario}]) || ([info exist scenario==0] && $mode != "scan")} {
	remove_clock_groups -asynchronous -name async_grp1;#remove async clocks to generate potential recrem violations
    }
    if {([info exist scenario] && [string match S12? ${scenario}]) || ([info exist scenario==0] && $mode != "scan")} {
	remove_clock_groups -asynchronous -name async_grp2;#remove async clocks to generate potential recrem violations
    }
    update_timing
    report_constraint -all_violators -recovery -removal -verbose -include_hierarchical_pins > ../reports/pt_${stage}_${corner}/recrem_${mode}.rpt
    report_timing -slack_lesser_than 0 -delay_type min_max -max_paths 50  > ../reports/pt_${stage}_${corner}/report_timing_no_async_${mode}.rpt
}

# -----------------------------------------------------------------------------------
# Save session 
# -----------------------------------------------------------------------------------
#save_session ../data/pt_$stage

print_message_info

set end_time [clock seconds]; echo [clock format ${end_time} -gmt false]

# Total script wall clock run time
echo "Time elapsed: [format %02d [expr ( $end_time - $start_time ) / 86400 ]]d\
[clock format [expr ( $end_time - $start_time ) ] -format %Hh%Mm%Ss -gmt true]"

exit
