set STAGE "00_init"
echo "\n####  BEGIN POINT:  $STAGE"

################################################################################
# General useful settings
source -e -v ./PROJECT.tcl
if {[file exists RPT/] == 0} {sh mkdir RPT}
if {[file exists output/] == 0} {sh mkdir output}
if {[file exists RPT/${STAGE}] == 0} {sh mkdir RPT/${STAGE}}
if {[file exists output/${STAGE}] == 0} {sh mkdir output/${STAGE}}
#set design_mw_lib Nanochap_ENS1p4
#close_mw_lib Nanochap_ENS1p4/
sh rm -rf Nanochap_ENS2
################################################################################
##### Init Design
create_mw_lib $design_mw_lib -open -technology $tech_file -mw_reference_library $mw_ref_libs -bus_naming_style {[%d]}
#set_app_var spg_enable_ascii_flow true

#import_designs $netlist -format verilog -top $DESIGN_NAME
read_verilog -top $DESIGN_NAME  $netlist
uniquify_fp_mw_cel 
current_design  $DESIGN_NAME

set_tlu_plus_files -max_tluplus $tlup_max -min_tluplus $tlup_min -tech2itf_map $tlup_map

#save_mw_cel -as 00_import_design

#set_app_var spg_enable_ascii_flow true

if {[get_cells -all -q IOFILL*] != ""} {remove_cell IOFILL*}
gui_set_pref_value -category {layout} -key {editingEnableSnapping} -value {false}

#set io physical constraints and create floorplan
set io_ref [lsort -u [get_att [get_cells -all -filter "mask_layout_type==io_pad||mask_layout_type==pad_filler"] ref_name]]
foreach i $io_ref {set_pad_physical_constraints  -pad_name  $i  -lib_cell  -lib_cell_orientation  {FN  FS  FN  FS}}
#remove_cell u_corner*
source ${DIR}/io_fplan/io_pads.tdf
# source ./test.tdf
## 660x1450 = #ana w 2406, height 2300
#2600x3050
 create_floorplan -control_type width_and_height -start_first_row -keep_macro_place \
                         -core_width     1215 \
                         -core_height    3109 \
                         -left_io2core   55.940 \
                         -bottom_io2core 37.68 \
                         -right_io2core  1180.42 \
                         -top_io2core    37.68

source -e -v ${DIR}/io_fplan/fp.tcl

#set_die_area -coordinate {{0 0} {2100 2100}}
#g ##UPF if present
reset_upf

set_app_var upf_create_implicit_supply_sets false
load_upf ${DIR}/${DESIGN_NAME}.upf
report_power_domain -hierarchy

#create terminals and place all pads
source -e -v ${DIR}/io_fplan/io_placement.tcl
#place hard macros
source -e -v ${DIR}/srams.tcl
source -e -v ${DIR}/ana.tcl
#save_mw_cel -as ${STAGE}_ramsplaced
## RCMCU_PLCORNER
#g if {[get_cells -q -all cornerbl] == ""} {create_cell {cornerbl cornerul} GF_CI_COR}
#g set obj [get_cells {"cornerul"} -all]
#g set_attribute -quiet $obj origin {0.000 2000.000}
#g set_attribute -quiet $obj orientation E
#g set_attribute -quiet $obj is_fixed true
#g 
#g set obj [get_cells {"cornerbl"} -all]
#g set_attribute -quiet $obj origin {0.000 0.000}
#g set_attribute -quiet $obj orientation FW
#g set_attribute -quiet $obj is_fixed true
save_mw_cel -as ${STAGE}_b4io


### PAD FILLER
if {[get_cells -all -q IOFILLER*] != ""} {remove_cell IOFILLER*}
insert_pad_filler -prefix "IOFILLER" -cell "IOFILL10 IOFILL1"

set pad [get_cells -all -filter "mask_layout_type==pad_filler&&orientation==W&&origin=~149.000*"]
flip_objects -x 0 -anchor center -flip_transform $pad -ignore_fixed

#save_mw_cel -as 01_init_iofillers
gui_set_pref_value -category {layout} -key {editingEnableSnapping} -value {false}

change_selection [get_cells -all -filter "(mask_layout_type==pad_filler||mask_layout_type==io_pad||mask_layout_type==corner_pad)&&origin=~0*"]
move_objects -delta "26 0" -ignore_fixed [get_selection]
cs
 move_objects -delta "26 0" -ignore_fixed [get_terminals -filter "bbox_llx<131"]
# move_objects -delta "26 0" -ignore_fixed [get_terminals -filter "name=~*VDD*||name=~*VSS*"]
#g move_objects -delta "0 26" -ignore_fixed [get_terminals -filter "bbox_ury<150"]
gui_set_pref_value -category {layout} -key {editingEnableSnapping} -value {true}

## Create ALWAYS ON bound
#g create_voltage_area   -coordinate {   187.000 2928.050   2094.275 2947.490   187.000 2304.880   211.215 2529.390   943.650 2328.430   970.575 2480.960   1032.365 1142.580   1211.775 1178.575   731.190 1142.560   836.360 1177.960   828.020 1660.500   944.905 1940.040  2067.850 1682.810 2095.520 1937.140 } -power_domain u_dig_top_wrapper/PD_AO -color 3

#save_mw_cel -as ${STAGE}_vaplaced
#create_route_guide -name CORNER -no_signal_layers {M1 MV1 M2 MV2 M3 MV3 M4 MV4 M5} -coordinate {{20.000 2718.000} {187.000 2879.620}} -no_snap

set_keepout_margin -all_macros -outer {10 10 10 10} 
set_keepout_margin -all_macros -type soft -outer {20 20 20 20}


## Connect PG
#g source /home/fpt1/bms3/PNR/icc/pnr_221218/00_flow/001_connect_pg.tcl
source -e -v ${DIR}/connect_pg.tcl
 derive_pg_connection -all 
#return
#Insert Blockages:
source ${DIR}/hardblockages.tcl
source ${DIR}/routing_blockages.tcl
#save_mw_cel -as ${STAGE}_b4pg
#MAPS:

source ${DIR}/script/MAPS/pg_1605.tcl
save_mw_cel -as ${STAGE}_aft_MAPS

check_route -drc
verify_pg_nets
remove_routing_blockage *
#create rblk above ANA:
source -e -v ${DIR}/routing_blockages.tcl

#g #add ENDCAPs
#g ##add corner blockages for fixing DF.18 violations
#g #source -e -v ${DIR}/endcap_blkgs.tcl
#g add_end_cap -lib_cell ENDCAPTIE19_A7TULL -ignore_soft_blockage -respect_blockage
#g #read_def ./end_tap.def
#g 
#g ## INSERT TAP
#g remove_stdcell_filler  -tap
#g add_tap_cell_array -master_cell_name FILLTIE_A7TULL  -distance 38 -pattern stagger_every_other_row -no_tap_cell_under_layers M1 -ignore_soft_blockage true -right_boundary_extra_tap must_insert  -left_boundary_extra_tap must_insert
#g 
#g #for  violation:
#g ##add corner blockages to block tap cells in the area 
#g source -e -v ${DIR}/corner_blkgs.tcl

#logical connections
source -e -v ${DIR}/connect_pg.tcl
 derive_pg_connection -all 

save_mw_cel -as ${STAGE}
report_placement_utilization
#exit
#milkyway -nullDisplay -nogui -tcl -f write_lef.tcl
