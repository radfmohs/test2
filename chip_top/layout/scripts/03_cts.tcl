set STAGE "03_cts"
echo "\n####  BEGIN POINT:  $STAGE"
set PREV    "01_place_opt"

source -e -v ./PROJECT.tcl
if {[file exists RPT/${STAGE}] == 0} {sh mkdir RPT/${STAGE}}
if {[file exists output/${STAGE}] == 0} {sh mkdir output/${STAGE}}

close_mw_lib $design_mw_lib
open_mw_lib $design_mw_lib
copy_mw_cel -from $PREV -to $STAGE
open_mw_cel  $STAGE
link

set_app_var psynopt_high_fanout_legality_limit 16

set_max_fanout 16 [get_lib_pins */*D*/* -filter "pin_direction==out"]

## SCENARIO
source ${DIR}/create_scenarios.tcl
#g set_false_path -hold -from vclk -through u_ana_top/A2D_SDM_OUT -to imeas_dig_adc_clk
#g set_false_path -hold -from vclk -through u_ana_top/A2D_Z_* -to zmeas_mclk_div_int
#g set_multicycle_path -hold 2 -from vclk -through iopad_gpio[11] -to */*/*/*/*/*/async_in_d1_reg

set_active_scenarios [all_scenarios]
puts "RM-Info: CTS scenarios are [get_scenarios -cts_mode true]"
#current_scenario [lindex [get_scenarios -cts_mode true] 0]
set_active_scenarios [get_scenarios -cts_mode true]
current_scenario S111


## dont_use
#g set_dont_use    [get_lib_cells  $dont_use]
 set_size_only   [get_flat_cell $size_only]

set_dont_touch [get_flat_cells *DNT*]
#set_dont_use [get_flat_cells {*EDFF* DLY* TBUF* SDFFTR* *XL* TIE* BUFX* INVX*}]
set dont_use    { */*NID20* */*NID24* */*IVD20* */NBL_IVD24* */*DL* */*NITD* */*TIE* */NBL_NID*}
set_dont_use    [get_lib_cells  $dont_use]
#set_attribute [ get_cells -hierarchical {port_buffer_* port_clkbuffer_* iobuffer* ioclkbuffer*}] dont_touch true
#set_att  [get_nets -segment -of [get_flat_cells {*port_buffer_* *port_clkbuffer_* *iobuffer* *ioclkbuffer*}]] dont_touch true

set_attribute [all_macro_cells] is_fixed true

set_app_var cts_instance_name_prefix icc_cts


## Clock Tree References
set_clock_tree_references -references  $CTS_CELLS
#set_clock_tree_references -delay_insertion_only -references $CTS_DELAY_CELLS
#set_clock_tree_references -sizing_only -references $SIZE_ONLY_INSTS


check_physical_design -stage pre_clock_opt -no_display -output RPT/03_check_physical_design.pre_clock_opt 


## EXTRA OPTIONS
#set_optimize_pre_cts_power_options -low_power_placement true
#set_optimize_pre_cts_power_options -merge_clock_gates true
## Gate splitting to avoid timing violations on enable pins of ICGs
#set_optimize_pre_cts_power_options -split_clock_gates true

##  Clock Exception
# set_clock_tree_exceptions -clocks [get_clocks sysclk] -exclude_pins [get_pins {u_dig_top/u_ahb_subsystem/u_apb_subsystem/u_port_pclk_13_/u_icg/CK}]
# set_clock_tree_exceptions -clocks [get_clocks sysclk] -exclude_pins [get_pins {u_dig_top/u_ahb_subsystem/u_apb_subsystem/u_port14_anac/boost_div_clk_reg/CK}]

##  CLOCK NDR
define_routing_rule NDR_2W_2S -spacings "MET3  0.42  MET4  0.42  MET5  0.42" -widths "MET3  0.56 MET4  0.56  MET5  0.56"  
set_clock_tree_options -routing_rule NDR_2W_2S -layer_list "MET3 MET4 MET5"  ;# -use_default_routing_for_sinks 1

## CTS constraints and options: 
set_clock_tree_options -max_fanout 16 
set_clock_tree_options -max_transition 1.2   
#set_clock_tree_options -max_capacitance 1.2 
set_clock_tree_options -target_skew 0.5
#  set_clock_tree_options -advanced_drc_fixing true


#stop_gui
clock_opt -only_cts -no_clock_route
#clock_opt  -no_clock_route -optimize_dft


## SCENARIO 
set cur_active_scenarios [all_active_scenarios]
set_active_scenarios -all
foreach scenario [all_active_scenarios] {
  #ideal network
  current_scenario $scenario
  remove_ideal_network [all_fanout -flat -clock_tree]
  set_propagated_clock [all_clocks]
}
set_active_scenarios -all


## Connect PG
source ./connect_pg.tcl
derive_pg_connection -all

## ENABLE FIX HOLD
#set_prefer -min [get_lib_cells $HOLD_DELAY_CELLS]
#set_fix_hold_options -preferred_buffer
#set_fix_hold [all_clocks]


save_mw_cel -as ${STAGE}

return 
## REPORT
create_qor_snapshot -clock_tree -name $STAGE
redirect -file RPT/$STAGE/$STAGE.constraints {report_constraints}
#redirect -file RPT/$STAGE/$STAGE.congestion.rpt {report_congestion -effort high -grc_based}
redirect -file RPT/$STAGE/$STAGE.placement_utilization.rpt {report_placement_utilization -verbose}
redirect -file RPT/$STAGE/$STAGE.qor {report_qor}
redirect -file RPT/$STAGE/$STAGE.qor -append {report_qor -summary}
redirect -file RPT/$STAGE/$STAGE.qor_snapshot.rpt {report_qor_snapshot -no_display}
return
redirect -file RPT/$STAGE/$STAGE.max.clock_tree    {report_clock_tree -scenarios {func scan} -nosplit -summary }     ;# global skew report
redirect -file RPT/$STAGE/$STAGE.cts_skew          {report_clock_timing -scenarios {func scan} -nosplit -type skew } ;# local skew report
redirect -file RPT/$STAGE/$STAGE.cts_skew -append  {report_clock_timing -scenarios {func scan} -type latency  -launch -nosplit -setup  -verbose }
redirect -file RPT/$STAGE/$STAGE.cts_latency       {report_clock_timing -scenarios {func scan} -type latency -launch -nosplit -setup -nworst 100000 }
redirect -file RPT/$STAGE/$STAGE.cts_structure     {report_clock_tree -scenarios {func scan} -structure -nosplit }
redirect -file RPT/$STAGE/$STAGE.cts_transition    {report_clock_tree -scenarios {func scan} -drc -nosplit }

#redirect -file RPT/$STAGE.max.tim {report_timing -nosplit -unique_pins -sort_by slack -significant_digits 3 -slack_lesser_than 0 -max_path 100000 -crosstalk_delta  -capacitance -transition_time -input_pins -nets -delay max}
#redirect -file RPT/$STAGE.min.tim {report_timing -nosplit -unique_pins -sort_by slack -significant_digits 3 -slack_lesser_than 0 -max_path 100000 -crosstalk_delta  -capacitance -transition_time -input_pins -nets -delay min}

## OUTPUT
#extract_rc 
write_parasitics  -format SPEF -compress  -output output/$STAGE/$STAGE.spef
write_verilog -diode_ports -no_physical_only_cells  output/$STAGE/$STAGE.v


#return
echo "\n####  END POINT:  $STAGE"
