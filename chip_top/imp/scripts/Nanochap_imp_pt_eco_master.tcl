set start_time [clock seconds] ; echo [clock format ${start_time} -gmt false]

echo [pwd]

print_suppressed_messages


source -echo -verbose ../scripts/design_config.tcl

set eco_report_unfixed_reason_max_endpoints 1
set scenarios []
set corners []
lappend scenarios S111 S112 S121 S122 S22 S3 S4;
lappend corners min max;

foreach i $scenarios { 
  foreach j $corners { 
      create_scenario -name ${i}_${j} -image session_${j}_${i}
      lappend all_scenarios ${i}_${j}      
    }
}

#set_host_options -num_processes 2

#start_hosts
#current_session -all
#current_scenario -all
#write_eco_design
#stop_hosts
#remove_host_options

    set_host_options -max_cores 1 -num_processes [expr {[llength $scenarios] * [llength $corners]}]

#set_host_options  -max_cores 8 -num_processes 8
#report_host_usage
start_hosts
current_session -all
current_scenario -all
#read_eco_design

report_constraints
report_qor
remote_execute {report_power} -v

fix_eco_timing -verbose -type setup -slack_lesser_than 0 -slack_greater_than -10 -cell_type {combinational} -power_mode total -dynamic_scenario S111_min -leakage_scenario S111_max

remote_execute {update_power}

fix_eco_timing -verbose -type hold -method {insert_buffer size_cell} -power_mode total -dynamic_scenario S111_min -leakage_scenario S111_max -slack_greater_than -10  -buffer_list {DLY1_X1_A7TULL DLY1_X4_A7TULL DLY2_X1_A7TULL DLY2_X4_A7TULL DLY3_X1_A7TULL DLY3_X4_A7TULL DLY4_X1_A7TULL DLY4_X4_A7TULL BUF_X2_A7TULL BUF_X4_A7TULL BUF_X6_A7TULL BUF_X8_A7TULL BUF_X10_A7TULL BUF_X12_A7TULL BUF_X14_A7TULL BUF_X16_A7TULL BUF_X18_A7TULL BUF_X20_A7TULL } -cell_type {combinational}

remote_execute {update_power}
fix_eco_power -power_mode total -dynamic_scenario S111_min -leakage_scenario S111_max
remote_execute {update_power}

fix_eco_timing -verbose -type hold -method {insert_buffer size_cell} -power_mode total -dynamic_scenario S111_min -leakage_scenario S111_max -slack_greater_than -10  -buffer_list {DLY1_X1_A7TULL DLY1_X4_A7TULL DLY2_X1_A7TULL DLY2_X4_A7TULL DLY3_X1_A7TULL DLY3_X4_A7TULL DLY4_X1_A7TULL DLY4_X4_A7TULL BUF_X2_A7TULL BUF_X4_A7TULL BUF_X6_A7TULL BUF_X8_A7TULL BUF_X10_A7TULL BUF_X12_A7TULL BUF_X14_A7TULL BUF_X16_A7TULL BUF_X18_A7TULL BUF_X20_A7TULL } -cell_type {combinational}
remote_execute {update_timing -full}

set vio 1
set count 5;#to avoid the loop
while {($vio) && ($count)} {
  set vio 0
  set count [expr {$count - 1}] 
  foreach i $all_scenarios { 
    current_scenario $i
    report_constraints -min_delay > tmp_report
    set f [open tmp_report r]
    set file_contents [read $f]
    close $f
    if {[string match "*VIOLATED*" $file_contents]} {
      set vio 1
      puts "Running hold eco again for scenario $i"
      fix_eco_timing -verbose -type hold -method {insert_buffer size_cell} -buffer_list {DLY1_X1_A7TULL DLY1_X4_A7TULL DLY2_X1_A7TULL DLY2_X4_A7TULL DLY3_X1_A7TULL DLY3_X4_A7TULL DLY4_X1_A7TULL DLY4_X4_A7TULL BUF_X2_A7TULL BUF_X4_A7TULL BUF_X6_A7TULL BUF_X8_A7TULL BUF_X10_A7TULL BUF_X12_A7TULL BUF_X14_A7TULL BUF_X16_A7TULL BUF_X18_A7TULL BUF_X20_A7TULL } -cell_type {combinational}
    }
  }
}
if {$count != 4} {
  current_scenario -all
  exec find . -iname "*.tcl" -delete;#remove previous fixes
  remote_execute {update_power}
  fix_eco_power -power_mode total -dynamic_scenario S111_min -leakage_scenario S111_max
  fix_eco_timing -verbose -type hold -method {insert_buffer size_cell} -buffer_list {DLY1_X1_A7TULL DLY1_X4_A7TULL DLY2_X1_A7TULL DLY2_X4_A7TULL DLY3_X1_A7TULL DLY3_X4_A7TULL DLY4_X1_A7TULL DLY4_X4_A7TULL BUF_X2_A7TULL BUF_X4_A7TULL BUF_X6_A7TULL BUF_X8_A7TULL BUF_X10_A7TULL BUF_X12_A7TULL BUF_X14_A7TULL BUF_X16_A7TULL BUF_X18_A7TULL BUF_X20_A7TULL } -cell_type {combinational}
  remote_execute {write_changes -verbose -format dctcl -output ../pteco_fix_${scenario}_${corner}.tcl} -v
  #choosing the largest tcl file as the final changes file
  set find_output [exec find . -name "pteco_fix_*_m*.tcl" -type f -printf "%s\t%p\n"]
  set sorted_output [exec echo "$find_output" | sort -n -r]
  set largest_line [exec echo "$sorted_output" | head -n 1]
  set largest_path [exec echo "$largest_line" | awk "{print \$2}"]
  eval exec mv "$largest_path" ../data/synthesis_postscan_pteco_sdf/${rm_project_top}.postscan.pteco_fix.tcl
} else {
  write_changes -verbose -format dctcl -output ../data/synthesis_postscan_pteco_sdf/${rm_project_top}.postscan.pteco_fix.tcl
}

if {$count} {
  puts "All corner timing violations fixed"
} else {
  puts "Error: some corner timing violations NOT fixed"
}

report_constraints
report_qor
report_analysis_coverage 
remote_execute {report_timing -slack_lesser_than 0.0 -delay_type min_max} -v
remote_execute {report_power} -v


stop_hosts
remove_host_options

print_message_info

set end_time [clock seconds]; echo [clock format ${end_time} -gmt false]

# Total script wall clock run time
echo "Time elapsed: [format %02d [expr ( $end_time - $start_time ) / 86400 ]]d\
[clock format [expr ( $end_time - $start_time ) ] -format %Hh%Mm%Ss -gmt true]"

exit
