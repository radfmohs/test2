set STAGE "07_post_route"
echo "\n####  BEGIN POINT:  $STAGE"
set PREV    "06_route"

source -e -v ./PROJECT.tcl

if {[file exists RPT/${STAGE}] == 0} {sh mkdir RPT/${STAGE}}
if {[file exists output/${STAGE}] == 0} {sh mkdir output/${STAGE}}

close_mw_cel  -all_views
close_mw_lib $design_mw_lib
open_mw_lib $design_mw_lib
copy_mw_cel -from $PREV -to $STAGE
open_mw_cel  $STAGE

## ROUTING LAYER
set_ignored_layers -max_routing_layer MET5
set_app_var psynopt_high_fanout_legality_limit 32


## dont_use
set dont_use    { */*NID20* */*NID24* */*IVD20* */NBL_IVD24* */*DL* */*NITD* */*TIE* */NBL_CK* }
set_dont_use    [get_lib_cells  $dont_use]
set_size_only   [get_flat_cell $size_only]

set_dont_touch [get_flat_cells *DNT*]
set_attribute [get_flat_nets -all -filter net_type==Clock] dont_touch 1
#set_attribute [ get_cells -hierarchical {port_buffer_* port_clkbuffer_* iobuffer* ioclkbuffer*}] dont_touch true
#set_att  [get_nets -segment -of [get_flat_cells {*port_buffer_* *port_clkbuffer_* *iobuffer* *ioclkbuffer*}]] dont_touch true

set_delay_calculation_options -postroute arnoldi -arnoldi_effort medium


## SKIP ROUTE
set IO_PADNET     [get_nets -of [get_pins -filter "name==PAD" -of [get_flat_cells -filter "mask_layout_type==io_pad"]]]
set_net_routing_rule -reroute freeze  $IO_PADNET

#g set IO_PADNET     [get_nets -of [get_pins -filter "name==P" -of [get_flat_cells -filter "mask_layout_type==io_pad"]]]
#g set_net_routing_rule -reroute freeze  $IO_PADNET
#g #LATER set_net_routing_rule -reroute freeze [get_nets -of [get_pins -filter "layer==M5" u_EPC001_ANA_TOP_wrapper/u_EPC001_ANA_TOP/*]]
#g #LATER set_net_routing_rule -reroute freeze  [get_nets FLASH_VPP]
#g #LATER set_net_routing_rule -reroute freeze  [get_flat_nets -of [get_pins u_EPC001_ANA_TOP_wrapper/u_EPC001_ANA_TOP/Analog_ch_io*]]

#set pin_sig [get_pins -all -filter "name=~A2D_*" -of [get_cells u_top_ana_wrapper/u_top_ana]]
#set_net_routing_rule -reroute freeze  [get_nets -of $pin_sig ]


## Remove Route guide util
#g remove_route_guide ROUTE_UTIL*
#g remove_cell [get_cells -all FILLCAP*]

## UPDATE UNCERTAINTY
#read_sdc $uncer_pro
## SCENARIO
source ${DIR}/create_scenarios.tcl
set_active_scenarios -all
foreach scenario [all_active_scenarios] {
  current_scenario $scenario
  remove_ideal_network [all_fanout -flat -clock_tree]
  set_propagated_clock [all_clocks]
}
current_scenario S111



set_app_var compile_instance_name_prefix icc_pro

# set_app_var routeopt_xtalk_reduction_cell_sizing TRUE

# Controls the effort level of TNS optimization
#set_optimization_strategy -tns_effort $ICC_TNS_EFFORT_POSTROUTE

## 180um library guide_line
set_route_options -same_net_notch check_and_fix
set_parameter -module droute -name cornerSpacingMode -value 1

set_route_zrt_detail_options  -antenna_on_iteration  15
#set_route_zrt_detail_options  -antenna_fixing_preference use_diodes
#set_route_zrt_detail_options  -insert_diodes_during_routing  true
set_route_zrt_detail_options  -antenna_fixing_preference hop_layers
set_route_zrt_detail_options  -diode_libcell_names  $ANTENNA

#gaya added options:
set_max_fanout 16 [get_lib_pins */*D*/* -filter "pin_direction==out"]

## DRC fixing
set_app_var routeopt_drc_over_timing true
route_opt -incremental -only_design_rule


route_opt -incremental -effort high -area_recovery -power


########################################
#   Additional route_opt practices
########################################
# Using the following flow can help further improvme QoR in postroute. 
# These steps come after the initial "route_opt -incremental":
if {1} {
set_app_var routeopt_enable_aggressive_optimization true
route_opt -incremental -xtalk_reduction
set_app_var routeopt_restrict_tns_to_size_only true
route_opt -incremental
}

## To limit route_opt to specific optimizations :
#  route_opt -incremental -only_xtalk_reduction : only xtalk reduction 
#  route_opt -incremental -only_hold_time : only hold fixing 
#  route_opt -incremental -(only_)wire_size : runs wire sizing which fixes timing by applying NDR's from define_routing_rule

## To prioritize max tran fixing :
#  By default, route_opt prioritizes max delay cost over max design rule costs (e.g. max tran). 
#  To set higher priority for DRC fixing, set the following variable.
#  Note that this variable only works with the -only_design_rule option.
#  set_app_var routeopt_drc_over_timing true
#    route_opt -incremental -only_design_rule

## To run size only but still allowing buffers to be inserted for hold fixing :
#  set_app_var routeopt_allow_min_buffer_with_size_only true


## REDUNDANT VIA
#set_route_zrt_common_options -post_detail_route_redundant_via_insertion medium
#source  $re_via
#insert_zrt_redundant_vias 


## Connect PG
source ${DIR}/connect_pg.tcl

derive_pg_connection
save_mw_cel -as $STAGE
return

## VERIFY
#verify_zrt_route -report_all_open_nets true
verify_lvs -use_notch_gap_fill_cell -check_single_pin_net_for_floating_port -check_single_pin_net_for_floating_net -check_floating_port_on_null_net -check_open_locator -check_short_locator

verify_pg_nets
verify_pg_nets  -pad_pin_connection all

########################################
#           REPORT DESIGN              #
########################################
create_qor_snapshot -clock_tree -name $STAGE
redirect -file RPT/$STAGE.qor_snapshot.rpt {report_qor_snapshot -no_display}

if {1} {
redirect -file RPT/$STAGE/$STAGE.placement_utilization.rpt {report_placement_utilization -verbose}
redirect -file RPT/$STAGE/$STAGE.power            {report_power -nosplit -scenario {S111}}
redirect -file RPT/$STAGE/$STAGE.qor              {report_qor}
redirect -file RPT/$STAGE/$STAGE.qor -append      {report_qor -summary}
redirect -file RPT/$STAGE/$STAGE.constraints      {report_constraints -nosplit -scenario "system scan"}
redirect -file RPT/$STAGE/$STAGE.max_fanout       {report_constraints -nosplit -all_violators -max_fanout      -verbose -scenario "system scan"}
redirect -file RPT/$STAGE/$STAGE.max_capacitannce {report_constraints -nosplit -all_violators -max_capacitance -verbose -scenario "system scan"}
redirect -file RPT/$STAGE/$STAGE.max_transition   {report_constraints -nosplit -all_violators -max_transition  -verbose -scenario "system scan" }
}
redirect -file RPT/$STAGE/$STAGE.clock_timing {report_clock_timing -nosplit -type skew -scenarios [get_scenarios -active true -setup true]} ;# local skew report
redirect -tee -file RPT/$STAGE/$STAGE.max.clock_tree {report_clock_tree -nosplit -summary -scenarios [get_scenarios -active true -setup true]}     ;# global skew report
redirect -tee -file RPT/$STAGE/$STAGE.min.clock_tree {report_clock_tree -nosplit -operating_condition min -summary -scenarios [get_scenarios -active true -hold true]}     ;# min global skew report

## OUTPUT
if {1} {
extract_rc -coupling_cap
write_parasitics  -format SPEF -compress  -output output/$STAGE/$STAGE.spef
write_verilog -diode_ports -no_physical_only_cells output/$STAGE/$DESIGN_NAME.output.v
}

return
if {0} {
#redirect -file RPT/$STAGE.max.tim {report_timing -nosplit -unique_pins -crosstalk_delta -scenario [all_active_scenarios] -capacitance -transition_time -input_pins -nets -delay max}
#redirect -file RPT/$STAGE.min.tim {report_timing -nosplit -unique_pins -crosstalk_delta -scenario [all_active_scenarios] -capacitance -transition_time -input_pins -nets -delay min}
redirect -file RPT/$STAGE/$STAGE.sys_max.tim {report_timing -scenarios S111 -nosplit -unique_pins -sort_by slack -significant_digits 3 -slack_lesser_than 0 -max_path 100000 -crosstalk_delta  -capacitance -transition_time -input_pins -nets -delay max}
redirect -file RPT/$STAGE/$STAGE.sys_min.tim {report_timing -scenarios system -nosplit -unique_pins -sort_by slack -significant_digits 3 -slack_lesser_than 0 -max_path 100000 -crosstalk_delta  -capacitance -transition_time -input_pins -nets -delay min}
redirect -file RPT/$STAGE/$STAGE.dft_max.tim {report_timing -scenarios scan -nosplit -unique_pins -sort_by slack -significant_digits 3 -slack_lesser_than 0 -max_path 100000 -crosstalk_delta  -capacitance -transition_time -input_pins -nets -delay max}
redirect -file RPT/$STAGE/$STAGE.dft_min.tim {report_timing -scenarios scan -nosplit -unique_pins -sort_by slack -significant_digits 3 -slack_lesser_than 0 -max_path 100000 -crosstalk_delta  -capacitance -transition_time -input_pins -nets -delay min}
redirect -file RPT/$STAGE/${STAGE}_full_clock.sys_max.tim {report_timing -path_type full_clock_expanded -scenarios system -nosplit -unique_pins -sort_by slack -significant_digits 3 -slack_lesser_than 0 -max_path 100000 -crosstalk_delta  -capacitance -transition_time -input_pins -nets -delay max}
redirect -file RPT/$STAGE/${STAGE}_full_clock.sys_min.tim {report_timing -path_type full_clock_expanded -scenarios system -nosplit -unique_pins -sort_by slack -significant_digits 3 -slack_lesser_than 0 -max_path 100000 -crosstalk_delta  -capacitance -transition_time -input_pins -nets -delay min}
redirect -file RPT/$STAGE/${STAGE}_full_clock.dft_max.tim {report_timing -path_type full_clock_expanded -scenarios scan -nosplit -unique_pins -sort_by slack -significant_digits 3 -slack_lesser_than 0 -max_path 100000 -crosstalk_delta  -capacitance -transition_time -input_pins -nets -delay max}
redirect -file RPT/$STAGE/${STAGE}_full_clock.dft_min.tim {report_timing -path_type full_clock_expanded -scenarios scan -nosplit -unique_pins -sort_by slack -significant_digits 3 -slack_lesser_than 0 -max_path 100000 -crosstalk_delta  -capacitance -transition_time -input_pins -nets -delay min}
}


echo "\n####  END POINT:  $STAGE"
