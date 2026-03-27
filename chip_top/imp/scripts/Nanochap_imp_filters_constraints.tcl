#if not scan mode
if {[string match "filter_wrapper*" [get_object_name [current_design]]]} {
  if {[string match S4_m?? $i]==0} {
    set hfosc_period  [expr {250}]; # 4 MHz
    create_clock -name clk {clk} -period $hfosc_period
    create_clock -name notch_clk {notch_clk} -period $hfosc_period
    create_clock -name lpf_clk {lpf_clk} -period $hfosc_period
    create_clock -name hpf_clk {hpf_clk} -period $hfosc_period
    create_clock -name pclk {pclk} -period $hfosc_period
    create_clock -name adc_clk {adc_clk} -period $hfosc_period
    
    set_clock_uncertainty 0.2 -setup [get_clocks]
    set_clock_uncertainty 0.05 -hold [get_clocks]
    puts "filter_wrapper clocks created"
  }
} else {
  if {[string match S4_m?? $i]==0} {
      set hfosc_period 250; # 4 MHz
      create_clock -name pclk [get_ports {pclk}] -period $hfosc_period

      # 1. Start the group list with the main pclk name
      set async_groups "-group pclk"

      set pclk_collection [get_ports {imeas_pclk[*]}]
      set array_length [sizeof_collection $pclk_collection]

      for {set j 0} {$j < $array_length} {incr j} {
          # Define the 6 clocks per instance
          create_clock -name "pclk_$j"             -period $hfosc_period [get_ports "imeas_pclk\[$j\]"]
          create_clock -name "imeas_dig_adc_clk_$j" -period $hfosc_period [get_ports "imeas_dig_adc_clk\[$j\]"]
          create_clock -name "clk_$j"               -period $hfosc_period [get_ports "clk\[$j\]"]
          create_clock -name "notch_clk_$j"         -period $hfosc_period [get_ports "notch_clk\[$j\]"]
          create_clock -name "lpf_clk_$j"           -period $hfosc_period [get_ports "lpf_clk\[$j\]"]
          create_clock -name "hpf_clk_$j"           -period $hfosc_period [get_ports "hpf_clk\[$j\]"]
          
          # 2. Get the NAMES of the clocks as a string, not a collection object
          set inst_clk_names [get_object_name [get_clocks "*_$j"]]
          
          if {$inst_clk_names != ""} {
              lappend async_groups "-group"
              lappend async_groups $inst_clk_names
          }
      }

      # 3. Apply the groups using the list of strings
      eval set_clock_groups -asynchronous $async_groups

      set_clock_uncertainty 0.2 -setup [get_clocks]
      set_clock_uncertainty 0.05 -hold [get_clocks]
      set_ideal_network [get_ports {"*rst*" "*reset*"}]
  }
}

set clock_ports [get_attribute [all_clocks] sources]

#if memory bist mode, disable the clocks
if {[string match S3_m?? $i]} {
  # Apply case analysis to the physical ports, not the clock objects
  set_case_analysis 0 $clock_ports
  set_false_path -from [all_inputs]
  set_false_path -to [all_outputs]
} else {
  # Subtract PORTS from PORTS
  set safe_inputs [remove_from_collection [all_inputs] $clock_ports]
  set safe_outputs [remove_from_collection [all_outputs] $clock_ports]

  foreach_in_collection c [all_clocks] {
    set clk_name [get_object_name $c]
    set_input_delay  2.0 -clock $clk_name $safe_inputs  -add_delay
    set_output_delay 2.0 -clock $clk_name $safe_outputs -add_delay
  }

}
