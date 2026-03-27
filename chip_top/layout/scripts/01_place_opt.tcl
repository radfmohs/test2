set STAGE "01_place_opt"
echo "\n####  BEGIN POINT:  $STAGE"
set PREV    "00_init"
################################################################################
# General useful settings
source -e -v ./PROJECT.tcl
#set design_mw_lib Nanochap_ENS1p4_0605

close_mw_cel  -all_views
close_mw_lib $design_mw_lib
open_mw_lib $design_mw_lib
copy_mw_cel -from $PREV -to $STAGE
open_mw_cel  $STAGE
link

if {[file exists RPT/${STAGE}] == 0} {sh mkdir RPT/${STAGE}}
if {[file exists output/${STAGE}] == 0} {sh mkdir output/${STAGE}}

set_attribute [all_macro_cells] is_fixed true
set_att [get_cells -all *FILL*] is_fixed true

##SET PARTIAL CHECKERBOARD

#g set AREA {210.090 41.170 364.000 3136.650  364.000 851.865 946.790 2329.350  946.790 1070.575 1116.975 2109.640  1118.860 1418.640 1413.420 1761.360}
#g remove_placement_blockage PARTIAL_DEN* 
#g set cnt 0
#g set step 50
#g for {set x 210} {$x < 1414} {incr x $step} {
#g     for {set y 41} {$y < 3137} {incr y $step} {
#g         set per 20
#g         create_placement_blockage  -name PARTIAL_DEN_[incr cnt] -type partial -blocked_percentage $per -bbox "{$x $y} {[expr $x+$step] [expr $y+$step]}"
#g     }
#g }

set AREA {210.090 41.170 364.000 3136.650  364.000 851.865 946.790 2329.350  946.790 1070.575 1116.975 2109.640  1118.860 1418.640 1413.420 1761.360}
set cnt 0
set step 50
foreach {x1 y1 x2 y2} $AREA {
    for {set x $x1} {$x < $x2} {set x [expr $x + $step]} {
        for {set y $y1} {$y < $y2} {set y [expr $y + $step]} {
            set per 15
            if {$x1 == 212} {set per 5}
            #if {$y >2727 && $x>1367} {set per 15}
            create_placement_blockage  -name PARTIAL_DEN_[incr cnt] -type partial -blocked_percentage $per -bbox "{$x $y} {[expr $x+$step] [expr $y+$step]}"
        }
    }
}

#######################
## ADD PREBUFFERS for IO and ANA  ## 
#######################
## When adding the -exclude_buffers option, you instruct the tool to pull buffers as well, but do not consider them in the
## logical levels calculation
#magnet_placement -exclude_buffers -logical_level 2 [get_cells "INST_RAM1 INST_RAM2"]
#ANA pin buffers:
set g_num 1
set g_port  [get_pins {u_top_ana_wrapper/u_top_ana/*}]
set ggg_port [remove_from_collection $g_port u_top_ana_wrapper/u_top_ana/A2D_CLK2MHZ ]
#u_top_ana_wrapper/u_top_ana/A2D_SPARE_RO_REG_0[0] u_top_ana_wrapper/u_top_ana/A2D_SPARE_RO_REG_0[1] u_top_ana_wrapper/u_top_ana/A2D_SPARE_RO_REG_0[2] u_top_ana_wrapper/u_top_ana/A2D_SPARE_RO_REG_0[3] u_top_ana_wrapper/u_top_ana/A2D_SPARE_RO_REG_0[4] u_top_ana_wrapper/u_top_ana/A2D_SPARE_RO_REG_0[5] u_top_ana_wrapper/u_top_ana/A2D_SPARE_RO_REG_0[6] u_top_ana_wrapper/u_top_ana/A2D_SPARE_RO_REG_0[7]}]
foreach_in_collection aaa_port $ggg_port {
  set aaa_net_type [get_attribute [get_nets -of_objects [get_pins $aaa_port]] net_type] 
  set aaa_net_name [sizeof_collection [get_nets -q -of_objects [get_pins $aaa_port] -filter "name=~*iopad_gpio*"] ] 
if {$aaa_net_type=="Clock"} {
    if {!$aaa_net_name} {
      insert_buffer -new_net_names n_port_clkbuffer_${g_num} -new_cell_names port_clkbuffer_${g_num} [get_pins $aaa_port] NBL_CKNID4
    }
  }
  if {$aaa_net_type=="Signal"} {
    if {!$aaa_net_name} {
      insert_buffer -new_net_names n_port_buffer_${g_num} -new_cell_names port_buffer_${g_num} [get_pins $aaa_port] NBL_NID4
    }
  }
incr g_num 
}
#For the A2D_CLK2MHZ pin 
insert_buffer -new_net_names n_port_clkbuffer_${g_num} -new_cell_names port_clkbuffer_${g_num} [get_pins u_top_ana_wrapper/u_top_ana/A2D_CLK2MHZ] NBL_CKNID4
#IOPAD buffers:
set g_num 1 
set ggg_port  [get_flat_pins {u_iopad_gpio*}]
set aa_net_name [get_nets -q -of_objects [get_pins $ggg_port] -filter "name=~IOBUF_*"]
set aaa_net_name [remove_from_collection $aa_net_name {IOBUF_PAD[0] IOBUF_PAD[1] IOBUF_PAD[2] IOBUF_PAD[3] IOBUF_PAD[4] IOBUF_PAD[5] IOBUF_PAD[6] IOBUF_PAD[7] IOBUF_PAD[8] IOBUF_PAD[9] IOBUF_PAD[10] IOBUF_Y[0] IOBUF_Y[4]}]
foreach_in_collection aaa_port $aaa_net_name {
  insert_buffer -new_net_names n_iobuffer_${g_num} -new_cell_names iobuffer_${g_num} [get_pins -of [get_nets $aaa_port]] NBL_NID4
  incr g_num 
 }
set_att  [get_nets -segment -of [get_flat_cells iobuffer_*]] dont_touch true
#IOPAD_clk pins:
insert_buffer -new_net_names n_ioclkbuffer_${g_num} -new_cell_names ioclkbuffer_${g_num} [get_pins -of [get_nets IOBUF_Y[0]]] NBL_CKNID4
incr g_num
insert_buffer -new_net_names n_ioclkbuffer_${g_num} -new_cell_names ioclkbuffer_${g_num} [get_pins -of [get_nets IOBUF_Y[4]]] NBL_CKNID4

set_keepout_margin -outer  {0 0 1 0}  -type hard [ get_cells -hierarchical {port_buffer_* port_clkbuffer_* iobuffer* ioclkbuffer*}]

magnet_placement -logical_level 1 [get_cells u_top_ana_wrapper/u_top_ana] -mark_soft_fixed
magnet_placement -logical_level 1 [get_cells u_iopad_gpio*] -mark_soft_fixed
magnet_placement -logical_level 1 [get_cells u_iopad_gpio*] -move_soft_fixed
#gsource -e -v ./buffers.tcl
#source -e -v ./max_cap_fixes.tcl
#g remove_buffer {u_top_ana_wrapper/port_buffer_73 u_top_ana_wrapper/port_buffer_74 u_top_ana_wrapper/port_buffer_75 u_top_ana_wrapper/port_buffer_76 u_top_ana_wrapper/port_buffer_77 u_top_ana_wrapper/port_buffer_78 u_top_ana_wrapper/port_buffer_79 u_top_ana_wrapper/port_buffer_81}

set_attribute [ get_cells -hierarchical {port_buffer_* port_clkbuffer_* iobuffer* ioclkbuffer*}] is_fixed true
set_attribute [ get_cells -hierarchical {port_buffer_* port_clkbuffer_* iobuffer* ioclkbuffer*}] dont_touch true
set_att  [get_nets -segment -of [get_flat_cells  {u_top_ana_wrapper/port_buffer_* iobuffer*}]] dont_touch true
##ANA Routeguide (only if required):
#g set aaa_ana_net [get_nets iopad_gpio[*]]
#g set aaa_layer "METAL3 METAL4 METAL5 METALTOP"
#g 
#g set aaa_num 1
#g foreach aaa_layer_in $aaa_layer {
#g   if {$aaa_layer_in == "METAL3"} {
#g       set aaa_layer_ref METAL2
#g   } elseif {$aaa_layer_in == "METAL4"} {
#g       set aaa_layer_ref METAL3
#g   } elseif {$aaa_layer_in == "METAL5"} {
#g       set aaa_layer_ref METAL4
#g   } elseif {$aaa_layer_in == "METALTOP"} {
#g       set aaa_layer_ref METAL5
#g   }
#g   foreach aaa_layer_bbox [get_attribute [get_net_shapes  -of_objects  [get_nets iopad_gpio[*]] -filter "layer_name==$aaa_layer_in"] bbox] {
#g 
#g   echo "CMD: create_route_guide -no_snap -coordinate {$aaa_layer_bbox} -no_signal_layer $aaa_layer_ref -name RG_ANALOG_$aaa_num "
#g   create_route_guide -no_snap -coordinate $aaa_layer_bbox -no_signal_layer $aaa_layer_ref -name RG_ANALOG_$aaa_num
#g   incr aaa_num
#g   }
#g }
###### ANALOG ROUTE
#source  /home/fpt1/bms3/PNR/icc/pnr_221218/00_flow/ana_net.tcl
# set_net_routing_rule -reroute freeze  [get_nets $ana_net]
 
 
 set pin_sig [get_pins -all -filter "name=~*A2D* && name!~*SEL* && name!~*EN" -of [get_cells u_top_ana_wrapper/u_top_ana]]
 set ndr_net [get_nets -of $pin_sig]
 
 define_routing_rule  NDR_ANA -spacings "MET3  0.42  MET4  0.42  MET5  0.42" -widths "MET3  0.56  MET4  0.56  MET5  0.56"  
 set_net_routing_rule -rule NDR_ANA  [get_object_name [get_nets -of $pin_sig]]
 set_net_routing_layer_constraints  [get_nets -of $pin_sig]  -min_layer_name MET3 -max_layer_name MET5 -min_layer_mode  allow_pin_connection
 
 set cnt 0
 set pin_sig [get_pins -all -filter "name=~*A2D_CLK2MHZ* && direction==out" -of [get_cells u_top_ana_wrapper/u_top_ana]]
 set m4_shape [get_net_shapes -filter {layer_name==MET5 && length > 15} -of [get_nets -of $pin_sig]]
 foreach i [get_att $m4_shape bbox] {create_route_guide -no_signal_layers MET4 -name ANA_SHIELD_[incr cnt] -coordinate $i}


## ANA_TOP PAD dont_touch
set IO_PADNET     [get_nets -of [get_pins -filter "name==PAD" -of [get_flat_cells -filter "mask_layout_type==io_pad"]]]
set_net_routing_rule -reroute freeze  $IO_PADNET
set_att  $IO_PADNET  dont_touch true
#g set_attribute [get_net_shapes -of_objects  [get_nets iopad_gpio[*]]] route_type user_enter
#g set_attribute [get_via -of_objects  [get_nets iopad_gpio[*]]] route_type user_enter
#g set_attribute [get_net_shapes -of_objects  [get_nets vss_dig -all] -filter "route_type=~Shield*"] route_type user_enter
#g set_attribute [get_via -of_objects  [get_nets vss_dig -all] -filter "route_type=~Shield*"] route_type user_enter
#
#######################
## PLACE OPT SETTING ## 
#######################
## dont_use
#g set dont_use    { */BUF*X20* */INV*X20* */*BUF*X24* */*BUF*X32* */INV*X24* */INV*X32* */*DLY* */*DFF*H* */*TBUF* */*SDFFTR* */*XL* */*TIE* */CLK*}
set dont_use    { */*NID20* */*NID24* */*IVD20* */NBL_IVD24* */*DL* */*NITD* */*TIE* */NBL_CK*}

set_dont_use    [get_lib_cells  $dont_use]
set_size_only   [get_flat_cells $size_only]
set_dont_touch [get_flat_cells *DNT*]
#set_dont_use [get_lib_cells {*/CLK* */*EDFF* */*TBUF* */*SDFFTR* */*XL* */*TIE* */DLY*}]
#g set_dont_touch [get_nets -of_objects [get_flat_pins u_top_ana_wrapper/u_top_ana/A2D*SPARE*]]
#g set_dont_touch [get_nets -of_objects [get_pins -leaf -q -filter full_name!~u_top_ana_wrapper/u_top_ana/* -of [get_nets -of [get_flat_pins u_top_ana_wrapper/u_top_ana/A2D*SPARE*]]]]
#g set_dont_touch [get_cells -of_objects [get_pins -leaf -q -filter full_name!~u_top_ana_wrapper/u_top_ana/* -of [get_nets -of [get_flat_pins u_top_ana_wrapper/u_top_ana/A2D*SPARE*]]]]


#LATER ## Tran/Cap
set_max_transition 0.8 [get_lib_pins */*D*/* -filter "pin_direction==in"]
set_max_capacitance 0.8 [get_lib_pins */*D*/* -filter "pin_direction==out"]
set_max_fanout 16 [get_lib_pins */*D*/* -filter "pin_direction==out"]

## SCANDEF
read_def $scandef


## Set Ideal Network so place_opt doesn't buffer clock nets
## Remove before clock_opt cts
## Uncertainty handling pre-cts
#read_sdc $sdc
#read_sdc $sdc_add
#read_sdc $uncer_pro
source -e -v ${DIR}/create_scenarios.tcl

set_active_scenarios -all
foreach scenario [all_active_scenarios] {
   current_scenario $scenario
   set_ideal_network [all_fanout -flat -clock_tree ]
}
current_scenario S111

remove_propagated_clock -all

#LATER set_clock_sense -positive -clocks [get_clocks hfclk_ext] "u_top_mcusys/u_sys0_subsys/u_i2c0/u_i2c_sda_i_deb/U3/Y"
set_operating_conditions -analysis_type bc_wc -max $max_cond -max_library $max_lib  -min $min_cond -min_library $min_lib
set_ideal_network [all_fanout -flat -clock_tree ]
set_app_var enable_recovery_removal_arcs true
set_app_var compile_instance_name_prefix icc_place  
set_max_net_length  1010  $DESIGN_NAME

#g set_attribute [get_placement_blockages AO_BUF_*] type {hard}
save_mw_cel -as ${STAGE}_b4place  



## SANITY CHECK
set_zero_interconnect_delay_mode true
report_constraint -all -max_delay -nosplit > RPT/01_init.constraint
set_zero_interconnect_delay_mode false

report_clock -nosplit  > RPT/$STAGE.report_clock




## Note: CTS only scenarios (get_scenarios -setup false -hold false -cts_mode true) are made inactive by RM during optimizations
#set_active_scenarios [lminus [all_scenarios] [get_scenarios -setup false -hold false -cts_mode true]]


# Default setting for preroute delay calculation is Elmore.
set_delay_calculation_options -preroute elmore
set_delay_calculation_options -postroute arnoldi -arnoldi_effort medium


# Controls the effort level of TNS optimization:	[medium|high]
set_optimization_strategy -tns_effort medium

## This command controls the layer optimization and track RC based optimization during place_opt.
# If "consider_routing" is TRUE make sure the most critical scenario is the current scenario to generate the RC models 
set_place_opt_strategy -default
#set_place_opt_strategy -layer_optimization "true|flase" -layer_optimization_effort "medium|high" -consider_routing "false|true"
#set_place_opt_strategy -layer_optimization "true" -layer_optimization_effort "medium" -consider_routing "true"
report_place_opt_strategy


set_app_var placer_reduce_high_density_regions true
set_app_var placer_channel_detect_mode true
set_app_var placer_max_cell_density_threshold 0.70
set_app_var psynopt_high_fanout_legality_limit 32
get_app_var psynopt_high_fanout_legality_limit

########################################
#           START PLACE OPT            #
########################################
stop_gui
set place_opt_cmd "place_opt -area_recovery  -effort high  -congestion -optimize_dft" 


#g create_placement_blockage -coordinate {{556.020 1139.280} {636.100 1217.680}} -name shorts1 -type partial -blocked_percentage 35
#g create_placement_blockage -coordinate {{579.225 1731.415} {679.485 1763.125}} -name shorts2 -type partial -blocked_percentage 35 
#g create_placement_blockage -coordinate {{480.115 1189.400} {543.890 1266.915}} -name shorts3 -type partial -blocked_percentage 35
#g create_route_guide -name route_guide_otp -no_signal_layers {METAL1 VIA1 METAL2 VIA2 VIA3 METAL4 VIA4 METAL5 VIA5} -coordinate {{457.905 1333.525} {459.625 1802.785}} -no_snap
set_host_options -max_cores 16
#place_opt -area_recovery  -effort high   -optimize_dft  -continue_on_missing_scandef
place_opt -area_recovery -effort high -optimize_dft

save_mw_cel -as ${STAGE}_done 
#redirect -file RPT/$STAGE/$STAGE.congestion.rpt {report_congestion -effort high}


if { [check_error -verbose] != 0} { echo "RM-Error, flagging ..." }


## preroute_focal_opt -size_only_mode
#  Use the command to perform preroute focal optimizations with cell sizing only

## psynopt -refine_critical_paths max_path_count
#  Use the command to perform register optimization. 
#  Register optimization moves registers and combinational logic along timing paths to minimize timing violations.

## SPARE CELL
insert_spare_cells -num_cells $SPARE_LIST -cell_name spare -skip_legal 
cs [get_flat_cells *spare*]
legalize_placement -cells [get_flat_cells [gs]]
set_attribute -quiet [get_flat_cells spare*] is_soft_fixed true
#set_attribute -quiet [get_flat_cells spare*] dont_touch true
#g if {0} {
#g set SPARE_LIST  {ANTENNAM 1000  CLKBUFX20M 1000}
#g insert_spare_cells -num_cells $SPARE_LIST -cell_name spare -skip_legal
#g set_undoable_attribute [get_cells -all spare*] is_soft_fixed {1}
#g }

## TIE CELL
#remove_tie_cells [all_tieoff_cells]
redirect -variable TIE {report_tie_nets}
set TIE_PIN [get_pins -q [lsort -u $TIE]]
connect_tie_cells -max_fanout 5  -max_wirelength 5 -tie_low_lib_cell NBL_TIEL -tie_high_lib_cell NBL_TIEH -obj_type port_inst  -objects $TIE_PIN 


set_attribute -quiet [get_flat_cells  {NBL_TIELO* NBL_TIEHI*}]  is_fixed true

report_tie_nets


########################################
#           CONNECT P/G                #
########################################
## Connect Power & Ground for non-MV and MV-mode


source -e -v ${DIR}/connect_pg.tcl
derive_pg_connection

if { [check_error -verbose] != 0} { echo "RM-Error, flagging ..." }
remove_placement_blockage PARTIAL_DEN*


save_mw_cel -as ${STAGE} 


all_tieoff_cells
report_tie_nets

return

########################################
#           WRITE REPORT               #
########################################
create_qor_snapshot -clock_tree -name $STAGE

redirect -file RPT/$STAGE/$STAGE.constraints {report_constraints}
redirect -file RPT/$STAGE/$STAGE.placement_utilization.rpt {report_placement_utilization -verbose}
redirect -file RPT/$STAGE/$STAGE.qor {report_qor}
redirect -file RPT/$STAGE/$STAGE.qor -append {report_qor -summary}
redirect -file RPT/$STAGE/$STAGE.qor_snapshot.rpt {report_qor_snapshot -no_display}
redirect -file RPT/$STAGE/$STAGE.congestion.rpt {report_congestion -effort high}

redirect -file RPT/$STAGE/$STAGE.sys_max.tim {report_timing -scenarios func -nosplit -unique_pins -sort_by slack -significant_digits 3 -slack_lesser_than 0 -max_path 100000 -crosstalk_delta  -capacitance -transition_time -input_pins -nets -delay max}
redirect -file RPT/$STAGE/$STAGE.sys_min.tim {report_timing -scenarios func -nosplit -unique_pins -sort_by slack -significant_digits 3 -slack_lesser_than 0 -max_path 100000 -crosstalk_delta  -capacitance -transition_time -input_pins -nets -delay min}
redirect -file RPT/$STAGE/$STAGE.dft_max.tim {report_timing -scenarios scan -nosplit -unique_pins -sort_by slack -significant_digits 3 -slack_lesser_than 0 -max_path 100000 -crosstalk_delta  -capacitance -transition_time -input_pins -nets -delay max}
redirect -file RPT/$STAGE/$STAGE.dft_min.tim {report_timing -scenarios scan -nosplit -unique_pins -sort_by slack -significant_digits 3 -slack_lesser_than 0 -max_path 100000 -crosstalk_delta  -capacitance -transition_time -input_pins -nets -delay min}

echo "\n####  END POINT:  $STAGE"
