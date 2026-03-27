
###########################################################################################
############################################
## ECO: 1 ##
############################################
set STAGE   "09_ECO1"

set PREV    "09_ECO1"
set PREV    "07_chip_finish"
echo "BEGIN POINT:  $STAGE"

source -e -v ./PROJECT.tcl

############################
set eco "./STA_09_ECO1/timing_eco"
set ECO_FILE    "${eco}/S111_max.tcl ${eco}/S111_min.tcl ${eco}/S3_min.tcl ${eco}/scan_min.tcl "

############################
set ECOCARD     "1"
set ECOPLACE    "1"
set ECOROUTE    "1"
set SWAPVIA     "0"
set STDFILL     "1"
set EXPORT      "1"


echo "\n####  BEGIN POINT:  $STAGE"

close_mw_cel  -all_views
close_mw_lib $design_mw_lib
open_mw_lib $design_mw_lib
copy_mw_cel -from $PREV -to $STAGE
open_mw_cel  $STAGE
link

if {[file exists RPT/${STAGE}] == 0} {sh mkdir RPT/${STAGE}}
if {[file exists output/${STAGE}] == 0} {sh mkdir output/${STAGE}}

## dont_use
set dont_use    { */*NID20* */*NID24* */*IVD20* */NBL_IVD24* */*DL* */*NITD* */*TIE* */NBL_CK*}
set_dont_use    [get_lib_cells  $dont_use]
set_size_only   [get_flat_cell $size_only]
set_dont_touch [get_flat_cells *DNT*]
set_attribute [get_flat_nets -all -filter net_type==Clock] dont_touch 1

suppress_message OPT-1022
suppress_message LIBSETUP-751
suppress_message LIBSETUP-754
set_keepout_margin -all_macros -outer {5 5 5 5} 
set_keepout_margin -all_macros -type soft -outer {8 8 8 8}

#source ./shorts_blkg.tcl
##Gaya extra settings only if required:
#g cs [get_flat_cells -filter ref_name=~SDF*]
#g cs -add [get_flat_cells -filter ref_name=~ADD*]
#g cs -add [get_flat_cells -filter ref_name=~X*]
#g cs -add [get_flat_cells *DNT*]
#g set_attribute [gs] is_fixed true
#g cs
############################
stop_gui
if {$ECOCARD} {
foreach CARD $ECO_FILE {source -continue_on_error -echo -verbose $CARD > ${CARD}.log}
}
save_mw_cel -as. $STAGE

#remove_placement_blockage short1
############################
## ECO PLACE
if {$ECOPLACE} {
remove_stdcell_filler -stdcell 
place_eco_cells -eco_changed_cells -legalize_only -displacement_threshold 5
legalize_placement -incremental
}
#size_cell u_dig_top_wrapper/top_dig_always_on_inst/icc_place15 BUFX4M

save_mw_cel -as $STAGE

#insert_buffer [get_pin u_top_dig/u_spi_top/spi_reg_u/genblk1_1__u_spi_reg_wavegen/reg_wg_driver_in_wave_reg_109__0_/SI] BUF_X4_A7TULL -new_cell_names tranfix1511_eco_cell1 -new_net_names tranfix1511_eco_net1
insert_zrt_diodes {{CK u_top_dig/u_spi_top/spi_reg_u/trim2_reg_reg_3_ ANTENNA_A7TULL 1 METAL5 20}}
insert_zrt_diodes {{CK u_top_dig/u_spi_top/spi_reg_u/genblk1_1__u_spi_reg_wavegen/drive_ctrl_reg2_reg_4_ ANTENNA_A7TULL 1 METAL5 20}}
insert_zrt_diodes {{SI u_top_dig/u_spi_top/spi_reg_u/unlock_reg_reg_3_ ANTENNA_A7TULL 1 METAL5 20}}

insert_zrt_diodes {{A u_top_dig/u_spi_top/spi_reg_u/genblk1_0__u_spi_reg_wavegen/icc_pro460 ANTENNA_A7TULL 1 METAL5 20}}
insert_zrt_diodes {{A icc_pco2 ANTENNA_A7TULL 1 METAL5 20}}
insert_zrt_diodes {{A u_top_dig/u_spi_top/spi_reg_u/genblk1_0__u_spi_reg_wavegen/icc_pro330 ANTENNA_A7TULL 1 METAL5 20}}
insert_zrt_diodes {{A u_top_dig/u_lead_off_detector/icc_pro60 ANTENNA_A7TULL 1 METAL5 20}}
insert_zrt_diodes {{D u_top_dig/otp_ctrl_top_inst/u_otp_trim_if/u_spi_wr_sync/async_in_d1_reg ANTENNA_A7TULL 1 METAL5 20}}

#insert_zrt_diodes {{A1 u_top_dig/u_spi_top/spi_reg_u/genblk1_0__u_spi_reg_wavegen/U2905 ANTENNA_A7TULL 1 METAL5 20}}

############################
## ECO route   
stop_gui
##Turn of soft spacing for timing optimization during chip finishing
set_route_zrt_detail_options -eco_route_use_soft_spacing_for_timing_optimization false
set_route_zrt_common_options -concurrent_redundant_via_mode off
#set_route_zrt_common_options -post_detail_route_redundant_via_insertion high
set_route_zrt_global_options -timing_driven false -crosstalk_driven false
set_route_zrt_track_options -timing_driven false -crosstalk_driven false
set_route_zrt_detail_options -timing_driven false
# set_route_zrt_common_options -reshield_modified_nets reshield
route_zrt_eco -reroute modified_nets_first_then_others -open_net_driven true


#read_drc_error_file -error_cell drc -drc_type calibre /barista/scratch/gayathri/ens2/drc/Nanochap_ENS2.drc.results

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
route_zrt_eco -nets [get_object_name $OPEN_NET]
remove_mw_cel -version_kept 0 ${STAGE}_lvs.err;1


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

#source /home/fpt1/ens1/PNR/ICC/script/ANA_routing_guide.tcl
route_zrt_eco -reroute modified_nets_first_then_others -open_net_driven true
save_mw_cel -as $STAGE

#remove_route_guide RG_ANALOG_* 
#route_zrt_eco
#save_mw_cel -as ${STAGE}_func
alias ck {remove_stdcell_filler -stdcell ; route_zrt_eco -reroute modified_nets_first_then_others -open_net_driven true ; verify_lvs -max_error 2000  -use_notch_gap_fill_cell -check_single_pin_net_for_floating_port -check_single_pin_net_for_floating_net -check_floating_port_on_null_net -check_open_locator -check_short_locator }


############################
## Redundant VIA- only if required
if {$SWAPVIA} {
set_route_zrt_common_options -post_detail_route_redundant_via_insertion medium
source  $re_via
insert_zrt_redundant_vias 
#route_zrt_eco -reroute modified_nets_first_then_others 
route_zrt_eco  
}


############################
## FILLER CELL
if {$STDFILL} {
remove_stdcell_filler -stdcell 
if {$CAPCELL  != ""} {insert_stdcell_filler -cell_with_metal    $CAPCELL  -cell_with_metal_prefix    CAPCELL  -connect_to_power VDD_DIG -connect_to_ground VSS_DIG -dont_respect_soft_placement_blockage}
if {$FILLCELL != ""} {insert_stdcell_filler -cell_without_metal $FILLCELL -cell_without_metal_prefix FILLCELL -connect_to_power VDD_DIG -connect_to_ground VSS_DIG -dont_respect_soft_placement_blockage}
set FILLED [get_flat_cell -q -filter "ref_name=~FILL*&&ref_name!~FILLTIE*"]
}


## Connect PG
#source ./001_connect_pg.tcl
derive_pg_connection


## SAVE DESIGN
change_names -rules verilog -hierarchy
#save_mw_cel -as ${STAGE}_emergency
save_mw_cel -as ${STAGE}

#######################################
####Outputs Script
#######################################
extract_rc -coupling_cap
write_parasitics  -format SPEF -compress  -output   ./output/$STAGE/$STAGE.spef
write_verilog -diode_ports -no_physical_only_cells ./output/$STAGE/$DESIGN_NAME.output.v -macro_definition
exec touch ./output/$STAGE/done_$STAGE
write_def -compressed -version 5.8 -output  ./output/$STAGE/$STAGE.def.gz

#if {[sizeof_col [get_nets -q -all POC]] == 0} {
#create_net -power POC
#connect_net POC [get_pins -all -filter name==POC -of [get_cells -all -filter mask_layout_type==io_pad]]
#set cell [get_cells -all  -hierarchical {clockGroup subsystem_cbus_clock_groups fixedClockNode front_bus_clock_groups}]
#set net [get_nets -of [get_pins -filter direction==out -of $cell]]
#remove_net $net
#remove_cell $cell
#}
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


##Verilog
write_verilog -diode_ports -no_physical_only_cells ./output/$STAGE/$DESIGN_NAME.output.v -macro_definition

## For comparison with a Design Compiler netlist,the option -diode_ports is removed
write_verilog -no_physical_only_cells ./output/$STAGE/$DESIGN_NAME.output.dc.v -macro_definition

## For LVS use,the option -no_physical_only_cells is removed
write_verilog -diode_ports -pg ./output/$STAGE/$DESIGN_NAME.output.pg.lvs.v  -no_tap_cells -no_pad_filler_cells -force_no_output_references [concat $TAPCELL $FILLCELL] -macro_definition

##PG netlist for SPO:
write_verilog -diode_ports -no_physical_only_cells ./output/$STAGE/$DESIGN_NAME.output.pg.v -macro_definition -pg
write_verilog -diode_ports ./output/$STAGE/$DESIGN_NAME.output_new.pg.v -macro_definition -pg -no_tap_cells -no_pad_filler_cells -no_core_filler_cells

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


exec touch ./output/$STAGE/done_$STAGE

sh mkdir ./STA_$STAGE
sh mkdir ./STA_$STAGE/reports
sh mkdir ./STA_$STAGE/session

echo "\n####  END POINT:  $STAGE"

