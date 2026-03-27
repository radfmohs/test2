set STAGE "06_route"
echo "\n####  BEGIN POINT:  $STAGE"
set PREV    "04_post_cts"

source -e -v ./PROJECT.tcl

if {[file exists RPT/${STAGE}] == 0} {sh mkdir RPT/${STAGE}}
if {[file exists output/${STAGE}] == 0} {sh mkdir output/${STAGE}}


close_mw_cel  -all_views
close_mw_lib $design_mw_lib
open_mw_lib $design_mw_lib
copy_mw_cel -from $PREV -to $STAGE
open_mw_cel  $STAGE
link

set_dont_touch [get_flat_nets * -filter net_type==Clock] true

## ROUTING LAYER
set_ignored_layers -max_routing_layer MET5
set_app_var psynopt_high_fanout_legality_limit 32
set_max_fanout 16 [get_lib_pins */*D*/* -filter "pin_direction==out"]

#create rblk between iopads and core
create_routing_blockage -layers {metal1Blockage via1Blockage} -bbox {{175.075 41.000} {204.940 2998.220}}
#remove otp routing blkg
#g remove_routing_blockage [get_routing_blockages -touching {{349.700 1333.520} {458.700 1807.520}}]
#add viablkage near PG ring to prevent drcs:
#g create_route_guide -name ANA_PIN_1 -no_signal_layers {M1 M2 M4 M5} -coordinate {{768.210 1327.910} {771.625 1450.640}} -no_snap
#g create_route_guide -name ANA_PIN_2 -no_signal_layers {M1 M2 M4 M5} -coordinate {{871.020 1190.965} {872.450 1198.450}} -no_snap
#g create_route_guide -name ANA_PIN_3 -no_signal_layers {M1 M2 M4 M5} -coordinate  {{769.330 950.845} {771.095 1067.625}} -no_snap
## dont_use
set dont_use    { */*NID20* */*NID24* */*IVD20* */NBL_IVD24* */*DL* */*NITD* */*TIE* */NBL_CK* }
set_dont_use    [get_lib_cells  $dont_use]
set_size_only   [get_flat_cell $size_only]
set_dont_touch [get_flat_cells *DNT*]
set_attribute [get_flat_nets -all -filter net_type==Clock] dont_touch 1
#g create_route_guide -name route_guide_0 -no_signal_layers {M2 M3 M4} -coordinate {{933.970 1697.890} {1217.685 1699.470}} -no_snap
#g create_route_guide -name route_guide_1 -no_signal_layers {M2 M3 M4} -coordinate {{1340.775 2147.730} {2097.020 2149.555}} -no_snap
#g create_route_guide -name route_guide_2 -no_signal_layers {M2 M3 M4} -coordinate {{293.455 1007.905} {761.990 1009.405}} -no_snap
#g set_attribute [ get_cells -hierarchical {port_buffer_* port_clkbuffer_* iobuffer* ioclkbuffer*}] dont_touch true
#g set_att  [get_nets -segment -of [get_flat_cells {*port_buffer_* *port_clkbuffer_* *iobuffer* *ioclkbuffer*}]] dont_touch true

## SCENARIO
source ${DIR}/create_scenarios.tcl
set_active_scenarios -all
foreach scenario [all_active_scenarios] {
  current_scenario $scenario
  remove_ideal_network [all_fanout -flat -clock_tree]
  set_propagated_clock [all_clocks]
}
current_scenario S111


## SKIP ROUTE
set SKIP_ROUTE [get_nets -all VPP] 
set_att $SKIP_ROUTE    dont_touch true
set_net_routing_rule -reroute freeze $SKIP_ROUTE

set IO_PADNET     [get_nets -of [get_pins -filter "name==PAD" -of [get_flat_cells -filter "mask_layout_type==io_pad"]]]
set_net_routing_rule -reroute freeze  $IO_PADNET

#set pin_sig [get_pins -all -filter "name=~*A2D_CLK2MHZ*" -of [get_cells u_top_ana_wrapper/u_top_ana]]
#set_net_routing_layer_constraints  [get_nets -of [get_pins $pin_sig]]  -min_layer_name METAL3 -max_layer_name METAL5 -min_layer_mode  allow_pin_connection
#set m4_shape [get_net_shapes -filter {layer_name==METAL5 && length > 5} -of [get_nets -of $pin_sig]]
#foreach i [get_att $m4_shape bbox] {create_route_guide -no_signal_layers METAL4 -name ANA_SHIELD_[incr cnt] -coordinate $i}


#g define_routing_rule  ANA_SHIELD  -widths "METAL4 0.56 METAL5 0.56"  -shield ; # -shield_widths "M5 0.64 MTOP 0.64" shield_spacings "M5 0.4 MTOP 0.4"
#g set ANA_NET  [get_nets -of [get_flat_pins */A2D_CLK2MHZ]]
#g set_net_routing_layer_constraints  $ANA_NET  -min_layer_name METAL4 -max_layer_name METAL5 -min_layer_mode  allow_pin_connection
#g set_net_routing_rule -rule ANA_SHIELD [get_object_name $ANA_NET]
#g route_zrt_group -nets $ANA_NET  -max_detail_route_iterations 20
#g create_zrt_shield -nets $ANA_NET -mode new  -with_ground VSS_DIG  -ignore_shielding_net_pins true
#g set_att $ANA_NET dont_touch true


#g  set IO_PADNET     [get_nets -of [get_pins -filter "name==P" -of [get_flat_cells -filter "mask_layout_type==io_pad"]]]
#g  set_net_routing_rule -reroute freeze  $IO_PADNET
#LATER set_net_routing_rule -reroute freeze [get_nets -of [get_pins -filter "layer==M5" u_EPC001_ANA_TOP_wrapper/u_EPC001_ANA_TOP/*]]
#LATER set_net_routing_rule -reroute freeze  [get_nets FLASH_VPP]
#LATER set_net_routing_rule -reroute freeze  [get_flat_nets -of [get_pins u_EPC001_ANA_TOP_wrapper/u_EPC001_ANA_TOP/Analog_ch_io*]]


## ANTENNA SET
set_route_zrt_detail_options  -antenna true  
set_route_zrt_detail_options  -insert_diodes_during_routing true
set_route_zrt_detail_options  -diode_libcell_names $ANTENNA
set_route_zrt_detail_options  -antenna_on_iteration  15
source -echo $antenna

## COMMONT ROUTE OPTIONS
set_si_options -delta_delay true  \
               -route_xtalk_prevention true \
               -route_xtalk_prevention_threshold 0.25 \
               -analysis_effort medium 

set_si_options -min_delta_delay true 

set_route_opt_strategy -search_repair_loop 40
set_route_opt_strategy -route_drc_threshold -1
set_route_zrt_detail_options -timing_driven false
set_route_zrt_common_options -post_detail_route_fix_soft_violations true
set_route_zrt_common_options -read_user_metal_blockage_layer true


## 180um lib guideline
set_route_options -same_net_notch check_and_fix
set_parameter -module droute -name cornerSpacingMode -value 1

## Connect PG
#source ./001_connect_pg.tcl
derive_pg_connection

## ROUTE DESIGN
route_opt -initial_route_only

set_route_opt_strategy -search_repair_loop 10

set_route_zrt_detail_options  -antenna_on_iteration  15
set_route_zrt_detail_options  -antenna_fixing_preference hop_layers
#set_route_zrt_detail_options  -antenna_fixing_preference use_diodes
set_route_zrt_detail_options  -insert_diodes_during_routing  false
set_route_zrt_detail_options  -diode_libcell_names  $ANTENNA
route_opt -initial_route_only -stage detail

verify_zrt_route -antenna true -drc true -voltage_area false 



#route_zrt_detail -incremental true  -max_number_iterations 5


## Connect PG
source ${DIR}/connect_pg.tcl

derive_pg_connection
save_mw_cel -as ${STAGE}

return
########################################
#           REPORT DESIGN              #
########################################
create_qor_snapshot -clock_tree -name $STAGE
redirect -file RPT/$STAGE/$STAGE.qor_snapshot.rpt {report_qor_snapshot -no_display}

if {1} {
redirect -file RPT/$STAGE/$STAGE.qor {report_qor}
redirect -file RPT/$STAGE/$STAGE.qor -append {report_qor -summary}
redirect -file RPT/$STAGE/$STAGE.constraints {report_constraints}
}

#redirect -file RPT/$STAGE.max.tim {report_timing -nosplit -unique_pins -sort_by slack -significant_digits 3 -slack_lesser_than 0 -max_path 100000 -crosstalk_delta  -capacitance -transition_time -input_pins -nets -delay max}
#redirect -file RPT/$STAGE.min.tim {report_timing -nosplit -unique_pins -sort_by slack -significant_digits 3 -slack_lesser_than 0 -max_path 100000 -crosstalk_delta  -capacitance -transition_time -input_pins -nets -delay min}


echo "\n####  END POINT:  $STAGE"
