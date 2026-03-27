set STAGE   "04_post_cts"
echo "\n####  BEGIN POINT:  $STAGE"
set PREV    "03_cts"

source -e -v ./PROJECT.tcl

if {[file exists RPT/${STAGE}] == 0} {sh mkdir RPT/${STAGE}}
if {[file exists output/${STAGE}] == 0} {sh mkdir output/${STAGE}}

close_mw_cel  -all_views
close_mw_lib $design_mw_lib
open_mw_lib $design_mw_lib
copy_mw_cel -from $PREV -to $STAGE
open_mw_cel  $STAGE

#gremove_keepout_margin *
#gset_keepout_margin -all_macros -type hard -outer {5 5 5 5} 
#gset_keepout_margin -all_macros -type soft -outer {8 8 8 8}

## UPDATE SDC
#read_sdc $uncer_pro
#read_sdc $sdc_add
#source  /home/fpt1/bms3/PNR/icc/pnr_221218/00_flow/012_create_route_guide.tcl

set_app_var psynopt_high_fanout_legality_limit 16
set_max_fanout 16 [get_lib_pins */*D*/* -filter "pin_direction==out"]

## SET ROUTING LAYER
set_clock_tree_options -routing_rule NDR_2W_2S -layer_list "MET3 MET4 MET5"  ;# -use_default_routing_for_sinks 1
define_routing_rule NDR_2W_2S -spacings "MET3  0.42  MET4  0.42  MET5  0.42" -widths "MET3  0.56  MET4  0.56  MET5  0.56"  
set_ignored_layers -max_routing_layer MET5


## SCENARIO
source ${DIR}/create_scenarios.tcl
set_active_scenarios -all
foreach scenario [all_active_scenarios] {
  current_scenario $scenario
  remove_ideal_network [all_fanout -flat -clock_tree]
  set_propagated_clock [all_clocks]
}
current_scenario S111

#g create_route_guide -name route_guide_0 -no_signal_layers {METAL1 METAL2 VIA2 METAL3 VIA3 METAL4 VIA4 METAL5 VIA5 METALTOP} -no_preroute_layers {METAL1 METAL2 METAL3 METAL4 METAL5 METALTOP} -coordinate {{439.280 1707.400} {906.320 1999.720}} -no_snap
#g create_route_guide -name route_guide_1 -no_signal_layers {METAL1 METAL2 VIA2 METAL3 VIA3 METAL4 VIA4 METAL5 VIA5 METALTOP} -no_preroute_layers {METAL1 METAL2 METAL3 METAL4 METAL5 METALTOP} -coordinate {{439.015 0.000} {906.880 292.740}} -no_snap
#g 
## dont_use
set dont_use    { */*NID20* */*NID24* */*IVD20* */NBL_IVD24* */*DL* */*NITD* */*TIE* }

 set_dont_use    [get_lib_cells  $dont_use]
 set_size_only   [get_flat_cell $size_only]
set_dont_touch [get_flat_cells *DNT*]
#gset_attribute [ get_cells -hierarchical {port_buffer_* port_clkbuffer_* iobuffer* ioclkbuffer*}] dont_touch true
#gset_att  [get_nets -segment -of [get_flat_cells {*port_buffer_* *port_clkbuffer_* *iobuffer* *ioclkbuffer*}]] dont_touch true

#set_fix_hold [all_clocks]
#g enable_primetime_icc_consistency_settings -all

#stop_gui

set_app_var compile_instance_name_prefix icc_pco 
extract_rc


#-optimize_dft# CLOCK TOP
clock_opt -no_clock_route  -optimize_dft 

route_zrt_group -all_clock_nets -reuse_existing_global_route true -stop_after_global_route true

set_si_options -delta_delay false -min_delta_delay false -route_xtalk_prevention false

route_zrt_group -all_clock_nets -reuse_existing_global_route true
save_mw_cel -as ${STAGE}_opt1_done

clock_opt  -only_psyn -area_recovery -power 



##  POST_CLOCK_ROUTE_CTO
if {0} {
    extract_rc -force
    update_timing
    optimize_clock_tree -routed_clock_stage detail
}


if {0} {
psynopt -only_hold_time
psynopt -only_design_rule 
psynopt 
}


## Connect PG
source ./connect_pg.tcl
derive_pg_connection


save_mw_cel -as ${STAGE}
return

## REPORT
create_qor_snapshot -clock_tree -name $STAGE

redirect -file RPT/$STAGE/$STAGE.power            {report_power -nosplit -scenario {func}}
redirect -file RPT/$STAGE/$STAGE.qor              {report_qor}
redirect -file RPT/$STAGE/$STAGE.qor -append      {report_qor -summary}
redirect -file RPT/$STAGE/$STAGE.qor_snapshot.rpt {report_qor_snapshot -no_display}
redirect -file RPT/$STAGE/$STAGE.constraints      {report_constraints -nosplit -scenario "func scan"}
redirect -file RPT/$STAGE/$STAGE.max_fanout       {report_constraints -nosplit -all_violators -max_fanout      -verbose -scenario "func scan"}
redirect -file RPT/$STAGE/$STAGE.max_capacitance {report_constraints -nosplit -all_violators -max_capacitance -verbose -scenario "func scan"}
redirect -file RPT/$STAGE/$STAGE.max_transition   {report_constraints -nosplit -all_violators -max_transition  -verbose -scenario "func scan" }

redirect -file RPT/$STAGE/$STAGE.placement_utilization.rpt {report_placement_utilization -verbose}
return
redirect -file RPT/$STAGE/$STAGE.max.clock_tree    {report_clock_tree -scenarios {func scan} -nosplit -summary }     ;# global skew report
redirect -file RPT/$STAGE/$STAGE.cts_skew          {report_clock_timing -scenarios {func scan} -nosplit -type skew } ;# local skew report
redirect -file RPT/$STAGE/$STAGE.cts_skew -append  {report_clock_timing -scenarios {func scan} -type latency -nosplit -verbose }
redirect -file RPT/$STAGE/$STAGE.cts_latency       {report_clock_timing -scenarios {func scan} -type latency -launch -nosplit -setup -nworst 100000 }
redirect -file RPT/$STAGE/$STAGE.cts_structure     {report_clock_tree -scenarios {func scan} -structure -nosplit }
redirect -file RPT/$STAGE/$STAGE.cts_transition    {report_clock_tree -scenarios {func scan} -drc -nosplit }

return
## OUTPUT
#extract_rc 
if {0} {
write_parasitics  -format SPEF -compress  -output ./output/$STAGE/$STAGE.spef
write_verilog -diode_ports -no_physical_only_cells  ./output/$STAGE/$DESIGN_NAME.output.v -macro_definition


#redirect -file RPT/$STAGE.max.tim {report_timing -nosplit -unique_pins -sort_by slack -significant_digits 3 -slack_lesser_than 0 -max_path 100000 -crosstalk_delta  -capacitance -transition_time -input_pins -nets -delay max}
#redirect -file RPT/$STAGE.min.tim {report_timing -nosplit -unique_pins -sort_by slack -significant_digits 3 -slack_lesser_than 0 -max_path 100000 -crosstalk_delta  -capacitance -transition_time -input_pins -nets -delay min}
redirect -file RPT/$STAGE/$STAGE.sys_max.tim {report_timing -scenarios func -nosplit -unique_pins -sort_by slack -significant_digits 3 -slack_lesser_than 0 -max_path 100000 -crosstalk_delta  -capacitance -transition_time -input_pins -nets -delay max}
redirect -file RPT/$STAGE/$STAGE.sys_min.tim {report_timing -scenarios func -nosplit -unique_pins -sort_by slack -significant_digits 3 -slack_lesser_than 0 -max_path 100000 -crosstalk_delta  -capacitance -transition_time -input_pins -nets -delay min}
redirect -file RPT/$STAGE/$STAGE.dft_max.tim {report_timing -scenarios scan -nosplit -unique_pins -sort_by slack -significant_digits 3 -slack_lesser_than 0 -max_path 100000 -crosstalk_delta  -capacitance -transition_time -input_pins -nets -delay max}
redirect -file RPT/$STAGE/$STAGE.dft_min.tim {report_timing -scenarios scan -nosplit -unique_pins -sort_by slack -significant_digits 3 -slack_lesser_than 0 -max_path 100000 -crosstalk_delta  -capacitance -transition_time -input_pins -nets -delay min}
redirect -file RPT/$STAGE/${STAGE}_full_clock.sys_max.tim {report_timing -path_type full_clock_expanded -scenarios func -nosplit -unique_pins -sort_by slack -significant_digits 3 -slack_lesser_than 0 -max_path 100000 -crosstalk_delta  -capacitance -transition_time -input_pins -nets -delay max}
redirect -file RPT/$STAGE/${STAGE}_full_clock.sys_min.tim {report_timing -path_type full_clock_expanded -scenarios func -nosplit -unique_pins -sort_by slack -significant_digits 3 -slack_lesser_than 0 -max_path 100000 -crosstalk_delta  -capacitance -transition_time -input_pins -nets -delay min}
redirect -file RPT/$STAGE/${STAGE}_full_clock.dft_max.tim {report_timing -path_type full_clock_expanded -scenarios scan -nosplit -unique_pins -sort_by slack -significant_digits 3 -slack_lesser_than 0 -max_path 100000 -crosstalk_delta  -capacitance -transition_time -input_pins -nets -delay max}
redirect -file RPT/$STAGE/${STAGE}_full_clock.dft_min.tim {report_timing -path_type full_clock_expanded -scenarios scan -nosplit -unique_pins -sort_by slack -significant_digits 3 -slack_lesser_than 0 -max_path 100000 -crosstalk_delta  -capacitance -transition_time -input_pins -nets -delay min}
}

echo "\n####  END POINT:  $STAGE"
