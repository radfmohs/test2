
set_tlu_plus_files -max_tluplus $tluplus_file($slow_corner_extraction) \
             -min_tluplus $tluplus_file($fast_corner_extraction) \
             -tech2itf_map $tf2itf_map_file

check_tlu_plus_files

# ------------------------------------------------------------------------------
# Set design context
# ------------------------------------------------------------------------------

# Set the maximum fanout value on the design
set_max_fanout $max_fanout $rm_project_top

# Set the maximum transition value on the design
set_max_transition $max_transition $rm_project_top

# Set the maximum capacitance
set_max_capacitance  $max_capacitance $rm_project_top

set_max_area 0

# Load all outputs with suitable capacitance
set_load $output_load [all_outputs]

set_input_transition  $input_transition [all_inputs]

set_clock_transition $max_clock_transition [filter_collection [all_clocks] defined(sources)]

# Derive list of clock ports
set clock_ports [filter_collection [get_attribute [filter_collection [all_clocks] defined(sources)] sources] object_class==port]
set clock_pins [get_attribute [filter_collection [all_clocks] defined(sources)] sources] 

# Drive input ports with a standard driving cell and input transition
#set_driving_cell -library $target_library_name($slow_corner_pvt) \
#                 -from_pin ${driving_from_pin} \
#                 -input_transition_rise $max_transition \
#                 -input_transition_fall $max_transition \
#                 -lib_cell ${driving_cell} \
#                 -pin ${driving_pin} \
#                 [remove_from_collection [all_inputs] ${clock_ports} ]
#
#set_driving_cell -library $target_library_name($slow_corner_pvt) \
#                 -from_pin ${clock_driving_from_pin} \
#                 -input_transition_rise $max_clock_transition \
#                 -input_transition_fall $max_clock_transition \
#                 -lib_cell ${clock_driving_cell} \
#                 -pin ${clock_driving_pin} \
#                 ${clock_ports}

# ------------------------------------------------------------------------------
# Set Operating conditions 
# ------------------------------------------------------------------------------
# BC-WC analysis 
if {[string match *_min $i]} {
  set_operating_conditions \
      -max $operating_condition_name($fast_corner_pvt) -max_lib [get_libs $target_library_name($fast_corner_pvt)] \
      -min $operating_condition_name($fast_corner_pvt) -min_lib [get_libs $target_library_name($fast_corner_pvt)] \
      -analysis_type on_chip_variation
  echo "max op cond applied"
}
if {[string match *_max $i]} {
  set_operating_conditions \
      -max $operating_condition_name($slow_corner_pvt) -max_lib [get_libs $target_library_name($slow_corner_pvt)] \
      -min $operating_condition_name($slow_corner_pvt) -min_lib [get_libs $target_library_name($slow_corner_pvt)] \
      -analysis_type on_chip_variation
    echo "min op cond applied"
}

# Timing derate
set_timing_derate -early 0.95
set_timing_derate -late 1.05

# for icg margin
set_clock_gating_check -setup 0.50 [all_clocks]
set_clock_gating_check -hold 0.25 [all_clocks]

# ------------------------------------------------------------------------------
# Create default path groups
# ------------------------------------------------------------------------------

# Separating paths can help improve optimization.

#set ports_clock_root [get_ports [all_fanout -flat -clock_tree -level 0]]
#
#group_path -name In2Reg     -from [remove_from_collection [all_inputs] $ports_clock_root] 
#group_path -name Reg2Out    -to   [all_outputs]
#group_path -name In2Out     -from [remove_from_collection [all_inputs] $ports_clock_root] -to [all_outputs]

group_path -name In2Reg     -from [all_inputs] 
group_path -name Reg2Out    -to   [all_outputs]
group_path -name In2Out     -from [all_inputs]  -to [all_outputs]

# ------------------------------------------------------------------------------
# Additional optimization constraints
# ------------------------------------------------------------------------------

# Critical range for core
if {[string match S4_* $i] == 0} {
  set_critical_range [expr {0.10 * ${hfosc_period}}] ${rm_project_top}
} else {
  set_critical_range [expr {0.10 * ${scan_clock_period}}] ${rm_project_top}
}
# ------------------------------------------------------------------------------
# Compile the design
# ------------------------------------------------------------------------------
if {$generate_sdf == "sdf"} {
	set_propagated_clock [filter_collection [all_clocks] defined(sources)]
}

