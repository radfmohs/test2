
###########################################################################################
############################################
## ECO: n ##
############################################

set STAGE   "07_chip_finish"
echo "\n####  BEGIN POINT:  $STAGE"
set PREV    "07_post_route"

source -e -v ./PROJECT.tcl

############################
set ECO_FILE    ""
set ECOCARD     "0"
set ECOPLACE    "1"
set ECOROUTE    "1"
set SWAPVIA     "0"
set STDFILL     "1"
set EXPORT      "1"
############################

close_mw_cel   -all_views
close_mw_lib   $design_mw_lib
open_mw_lib    $design_mw_lib
copy_mw_cel    -from $PREV -to $STAGE
open_mw_cel    $STAGE
link

if {[file exists RPT/${STAGE}] == 0} {sh mkdir RPT/${STAGE}}
if {[file exists output/${STAGE}] == 0} {sh mkdir output/${STAGE}}

## dont_use
set dont_use    { */*NID20* */*NID24* */*IVD20* */NBL_IVD24* */*DL* */*NITD* */*TIE* */NBL_CK*}
set_dont_use    [get_lib_cells  $dont_use]
set_size_only   [get_flat_cell $size_only]
set_dont_touch [get_flat_cells *DNT*]
set_attribute [get_flat_nets -all -filter net_type==Clock] dont_touch 1
## REMOVE FILLER
#g set_primetime_options -exec_dir /eda/digital/pt_vM201612_SP3/bin/ -max_image ./STA_09_ECO/session/func_max.session
#check_primetime_icc_consistency_settings
#remove_placement_blockage -name hard_corner*
############################
if {$ECOCARD} {
foreach CARD $ECO_FILE {   source -echo -verbose  $CARD   >   $CARD.log   }
}

#Pause and check each of the scripts below
source ${central_path}/ens2_run1_1403/script/check_clkbuf_indata.tcl
source ${central_path}/ens2_run1_1403/script/check_norbuf_inclk.tcl 
source ${central_path}/ens2_run1_1403/script/check_clkinv_indata.tcl 
source ${central_path}/ens2_run1_1403/script/check_norinv_inclk.tcl
sh gvim ./script/1.1.inv_filter.tcl

############################
## ECO PLACE
if {$ECOPLACE} {
remove_stdcell_filler -stdcell 
place_eco_cells -eco_changed_cells  -legalize_only
legalize_placement -incremental
}

############################
## ECO route   
#stop_gui
#if {$ECOROUTE} {
##Turn of soft spacing for timing optimization during chip finishing
set_route_zrt_detail_options -eco_route_use_soft_spacing_for_timing_optimization false
set_route_zrt_common_options -concurrent_redundant_via_mode off
set_route_zrt_common_options -post_detail_route_redundant_via_insertion medium
set_route_zrt_global_options -timing_driven false -crosstalk_driven false
set_route_zrt_track_options  -timing_driven false -crosstalk_driven false
set_route_zrt_detail_options -timing_driven false

set_route_zrt_detail_options  -antenna_on_iteration  15
set_route_zrt_detail_options  -antenna_fixing_preference use_diodes
set_route_zrt_detail_options  -diode_libcell_names  $ANTENNA

# set_route_zrt_common_options -reshield_modified_nets reshield
route_zrt_eco -reroute modified_nets_first_then_others -open_net_driven true
#route_zrt_detail -incremental true  -max_number_iterations 15

verify_zrt_route

## Detail Route Short fix
if {0} {
set SHORT [get_drc_errors -type "Short" ]
set NET [get_nets [concat [get_att $SHORT net1_name] [get_att $SHORT net2_name]]]
set NET [get_nets [get_att $SHORT net1_name]]
set SHAPE [get_net_shapes -of $NET]
foreach MX [lsort -unique [get_att $SHORT layer_names]] {
foreach box [get_att [filter_collection  $SHORT layer_names==$MX] bbox] { set SHAPE [remove_from_col $SHAPE [get_net_shapes -intersect $box -filter layer_name==$MX]]}
}
set REMOVE [remove_from_col [get_net_shapes -of $NET] $SHAPE]
remove_objects $REMOVE 
route_zrt_eco -nets [get_object_name $NET]
}

## Check LVS and fix shorts
if {0} {
verify_lvs -max_error 2000  -use_notch_gap_fill_cell -check_single_pin_net_for_floating_port -check_single_pin_net_for_floating_net -check_floating_port_on_null_net -check_open_locator -check_short_locator
#set SHORT [get_drc_errors -type "Short" ]
set SHORT [get_drc_errors -type "Short" -error_view "${STAGE}_lvs.err"]
set NET [get_nets [concat [get_att $SHORT net1_name] [get_att $SHORT net2_name]]]
set NET [get_nets [get_att $SHORT net1_name]]
set SHAPE [get_net_shapes -of $NET]
foreach MX [lsort -unique [get_att $SHORT layer_names]] {
    foreach box [get_att [filter_collection  $SHORT layer_names==$MX] bbox] { 
        set SHAPE [remove_from_col $SHAPE [get_net_shapes -intersect $box -filter layer_name==$MX]]
    }
}
set REMOVE [remove_from_col [get_net_shapes -of $NET] $SHAPE]
set OPEN_NET [get_nets -of $REMOVE]
remove_objects $REMOVE 
route_zrt_eco -nets [get_object_name $OPEN_NET] -max_detail_route_iterations 5
#remove_mw_cel -version_kept 0 ${STAGE}_lvs.err;1
}


#}
############################
## Redundant VIA
if {$SWAPVIA==1} {
set_route_zrt_common_options -post_detail_route_redundant_via_insertion medium
source  $re_via
insert_zrt_redundant_vias 
#route_zrt_eco -reroute modified_nets_first_then_others 
route_zrt_eco  
}

#save_mw_cel -as $STAGE
############################
## FILLER CELL
if {$STDFILL} {
remove_stdcell_filler -stdcell 
if {$CAPCELL  != ""} {insert_stdcell_filler -cell_with_metal    $CAPCELL  -cell_with_metal_prefix    CAPCELL  -connect_to_power VDD -connect_to_ground VSS -dont_respect_soft_placement_blockage}
if {$FILLCELL != ""} {insert_stdcell_filler -cell_without_metal $FILLCELL -cell_without_metal_prefix FILLCELL -connect_to_power VDD -connect_to_ground VSS -dont_respect_soft_placement_blockage}
set FILLED [get_flat_cell -q -filter "ref_name=~FILL*&&ref_name!~FILLTIE*"]
}

## Connect PG
source ${DIR}/connect_pg.tcl
derive_pg_connection

## VERIFY
#verify_zrt_route -report_all_open_nets true
verify_lvs -max_error 2000  -use_notch_gap_fill_cell -check_single_pin_net_for_floating_port -check_single_pin_net_for_floating_net -check_floating_port_on_null_net -check_open_locator -check_short_locator
#verify_pg_nets
#verify_pg_nets  -pad_pin_connection all

## SAVE DESIGN
change_names -rules verilog -hierarchy
save_mw_cel -as ${STAGE}


#######################################
####Outputs Script
#######################################
#gif {$EXPORT} {
extract_rc -coupling_cap
write_parasitics  -format SPEF -compress  -output   ./output/$STAGE/$STAGE.spef
write_verilog -diode_ports -no_physical_only_cells  ./output/$STAGE/$DESIGN_NAME.output.v -macro_definition
write_def -compressed -version 5.8 -output  ./output/$STAGE/$STAGE.def.gz


#if {[sizeof_col [get_nets -q -all POC]] == 0} {
#create_net -power POC
#connect_net POC [get_pins -all -filter name==POC -of [get_cells -all -filter mask_layout_type==io_pad]]
#set cell [get_cells -all  -hierarchical {clockGroup subsystem_cbus_clock_groups fixedClockNode front_bus_clock_groups}]
#set net [get_nets -of [get_pins -filter direction==out -of $cell]]
#remove_net $net
#remove_cell $cell
#}

##Verilog
write_verilog -diode_ports -no_physical_only_cells ./output/$STAGE/$DESIGN_NAME.output.v -macro_definition

## For comparison with a Design Compiler netlist,the option -diode_ports is removed
write_verilog -no_physical_only_cells ./output/$STAGE/$DESIGN_NAME.output.dc.v -macro_definition

## For LVS use,the option -no_physical_only_cells is removed
write_verilog -diode_ports -pg ./output/$STAGE/$DESIGN_NAME.output.pg.lvs.v  -no_tap_cells -no_pad_filler_cells -force_no_output_references [concat $TAPCELL $FILLCELL]

## CELL LIST for LVS hcell
report_reference -nosplit -hierarchy  >  ./output/$STAGE/$DESIGN_NAME.reference

##SDC
set_app_var write_sdc_output_lumped_net_capacitance false
set_app_var write_sdc_output_net_resistance false

set cur_scenario [current_scenario]
foreach scenario [all_active_scenarios] {
  current_scenario $scenario
  write_sdc ./output/$STAGE/$DESIGN_NAME.$scenario.output.sdc
};
current_scenario $cur_scenario

#write lef
Milkyway -nullDisplay -nogui -tcl -f write_lef.tcl

###GDSII
echo "[get_object_name [current_mw_cel]] $DESIGN_NAME" > ./output/$STAGE/cell_map
set_write_stream_options \
    -map_layer $gds_out \
    -rename_cell ./output/$STAGE/cell_map \
    -child_depth 0 \
    -output_filling fill \
    -output_outdated_fill \
    -output_pin text \
    -keep_data_type
write_stream -cells $STAGE -format gds ./output/$STAGE/$DESIGN_NAME.gds

}

exec touch ./output/$STAGE/done_$STAGE

sh mkdir ./STA_$STAGE

echo "\n####  END POINT:  $STAGE"
exit

