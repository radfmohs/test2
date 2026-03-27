set start_time [clock seconds] ; echo [clock format ${start_time} -gmt false]

echo [pwd]

print_suppressed_messages

#set stage prescan
#set corner max
#set mode functional
set power_test averaged;#zmeas | imeas | hello | all_tests | time_based
set load_wave no;#fsdb
set load_sdf no_sdf;
set dc_sel DC;#PT doesn't need routing information

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


set_app_var search_path [concat . $stdcell_search_path $otp_search_path $io_search_path $ana_search_path $eprom_ls_search_path $search_path]

if {$corner == "max"} {
    lappend link_path * $stdcell_library(db,$slow_corner_pvt) $otp_max_library $io_max_library $eprom_ls_max_library $ana_max_library
}
if {$corner == "typ"} {
    lappend link_path * $stdcell_library(db,$typ_corner_pvt)  $otp_typ_library $io_typ_library $eprom_ls_typ_library $ana_typ_library
}
if {$corner == "min"} {
    lappend link_path * $stdcell_library(db,$fast_corner_pvt) $otp_min_library $io_min_library $eprom_ls_min_library $ana_min_library
}


# -----------------------------------------------------------------------------------
# PT Setting
# -----------------------------------------------------------------------------------
set timing_disable_clock_gating_checks false
set timing_slew_propagation_mode worst_slew
set rc_degrade_min_slew_when_rd_less_than_met true

# -----------------------------------------------------------------------------------
# PX Setting
# -----------------------------------------------------------------------------------
set_app_var power_enable_analysis true
set power_enable_multi_rail_analysis true 
set power_enable_concurrent_event_analysis false
set_app_var power_use_c1cn_pin_capacitance true;#Setup C1CN Pin Capacitance support
set_app_var power_enable_clock_cycle_based_glitch true
# -----------------------------------------------------------------------------------
# Read design and sdc
# -----------------------------------------------------------------------------------

read_verilog ../data/synthesis_${stage}_no_sdf/${rm_project_top}.${stage}.v

link_design  $rm_project_top
current_design $rm_project_top

if {$mode == "scan"} {
	set eco_instance_name_prefix "uScan_"
	set eco_net_name_prefix "nScan_"
	source -verbose -echo ../scripts/Nanochap_imp_scan_constraints.tcl
} else {
	source -echo -verbose ../data/synthesis_postscan_no_sdf/${rm_project_top}.postscan.sdc
}

if {$power_test == "time_based"} {
	set_app_var power_analysis_mode time_based
	set_power_analysis_options -waveform_output bms5_ptpx -waveform_format fsdb
	#read_vcd -strip_path tb_chip_top ../../sim/bms5.vpd
	#read_fsdb -strip_path tb_chip_top ../../sim/bms5.fsdb
	read_fsdb -strip_path tb_chip_top  [ls -t /scratch/mohsen/bms5/simulation/sim/${corner}*_${power_test}_*.fsdb  | head -n 1];#this doesn't work properly!
} elseif {$power_test == "zmeas" || $power_test == "imeas" || $power_test == "hello" || $power_test == "all_tests"} {
	set_app_var power_analysis_mode averaged
	if {$power_test == "all_tests"} {
		merge_saif -input_list [list \
			-input [ls -t /scratch/mohsen/bms5/simulation/sim/$corner*_zmeas_*.saif  | head -n 1] -weight 60 \
		 	-input [ls -t /scratch/mohsen/bms5/simulation/sim/*_hello_*.saif  | head -n 1] -weight 40 \
		] -strip_path tb_chip_top 
	} else {
		read_saif -strip_path tb_chip_top [ls -t /scratch/mohsen/bms5/simulation/sim/${corner}*_${power_test}_*.saif  | head -n 1]
		if {$load_wave == "fsdb"} {
			read_fsdb -strip_path tb_chip_top  [ls -t /scratch/mohsen/bms5/simulation/sim/${corner}*_${power_test}_*.fsdb  | head -n 1];#this will take around 10-20 mins
		}
	}
} else {
	set_app_var power_analysis_mode averaged
	set_switching_activity -toggle_rate .25 -glitch_rate .05 -static_probability .015 -type inputs;
}

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
# Update Power
# -----------------------------------------------------------------------------------
update_power

#fix_eco_power -power_mode total
#write_changes -verbose -format dctcl -output ../data/synthesis_postscan_sdf/${rm_project_top}.postscan.pteco_fix.tcl

check_power -verbose > ../reports/pt_${stage}_${corner}/check_power_${mode}_${power_test}.rpt

report_power -verbose > ../reports/pt_${stage}_${corner}/report_power_${mode}_${power_test}_summary.rpt

report_power -hierarchy -sort_by dynamic_power -levels 10 -nworst 50 -cell_power > \
	../reports/pt_${stage}_${corner}/report_power_hier_${mode}_${power_test}_worst_cell.rpt
report_power -hierarchy -verbose > ../reports/pt_${stage}_${corner}/report_power_hier_${mode}_${power_test}.rpt
report_power -hierarchy -verbose -nworst 100 -net_power -relative_toggle_rate > \
	../reports/pt_${stage}_${corner}/report_power_hier_${mode}_${power_test}_worst_net.rpt
report_switching_activity > ../reports/pt_${stage}_${corner}/switching_activity_${mode}_${power_test}_summary.rpt
report_switching_activity -hierarchy -coverage -sort_by toggle > ../reports/pt_${stage}_${corner}/switching_activity_${mode}_${power_test}_hier.rpt
report_clock_gate_savings -by_clock_gate -sort_by toggle_savings > ../reports/pt_${stage}_${corner}/clock_gate_savings_${mode}_${power_test}.rpt 
report_switching_activity -list_not_annotated > ../reports/pt_${stage}_${corner}/switching_activity_${mode}_${power_test}_not_annotated.rpt
report_annotated_delay > ../reports/pt_${stage}_${corner}/report_annotated_delay_${mode}_${power_test}.rpt

set_case_analysis 0 [get_ports IOBUF_PAD[4]];#disable spi clk and measure power again
set_case_analysis 0 [get_ports IOBUF_PAD[6]];#disable spi clk and measure power again

report_power -verbose > ../reports/pt_${stage}_${corner}/report_power_${mode}_${power_test}_summary_spi_disabled.rpt

report_power -hierarchy -sort_by dynamic_power -levels 10 -nworst 50 -cell_power > \
	../reports/pt_${stage}_${corner}/report_power_hier_${mode}_${power_test}_worst_cell_spi_disabled.rpt
report_power -hierarchy -verbose > ../reports/pt_${stage}_${corner}/report_power_hier_${mode}_${power_test}_spi_disabled.rpt
report_power -hierarchy -verbose -nworst 100 -net_power -relative_toggle_rate > \
	../reports/pt_${stage}_${corner}/report_power_hier_${mode}_${power_test}_worst_net_spi_disabled.rpt
report_switching_activity > ../reports/pt_${stage}_${corner}/switching_activity_${mode}_${power_test}_summary_spi_disabled.rpt
report_switching_activity -hierarchy -coverage -sort_by toggle > ../reports/pt_${stage}_${corner}/switching_activity_${mode}_${power_test}_hier_spi_disabled.rpt
report_clock_gate_savings -by_clock_gate -sort_by toggle_savings > ../reports/pt_${stage}_${corner}/clock_gate_savings_${mode}_${power_test}_spi_disabled.rpt 
report_switching_activity -list_not_annotated > ../reports/pt_${stage}_${corner}/switching_activity_${mode}_${power_test}_not_annotated_spi_disabled.rpt
report_annotated_delay > ../reports/pt_${stage}_${corner}/report_annotated_delay_${mode}_${power_test}_spi_disabled.rpt


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
