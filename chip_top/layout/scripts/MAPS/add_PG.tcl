gui_set_pref_value -category {layout} -key {editingEnableSnapping} -value {false}
remove_route_by_type -pg_ring -pg_strap -pg_std_cell_pin_conn -pg_macro_io_pin_conn -signal_detail_route
remove_stdcell_filler  -tap
remove_net_routing VPP
#PG pin connection of macros
gui_start
gui_set_pref_value -category {layout} -key {editingEnableSnapping} -value {false}
#gcreate_rectangular_rings  -nets  {VSS_DIG VDD_DIG}  -left_offset 2.0 -left_segment_layer M6 -left_segment_width 6.0 -skip_right_side -skip_bottom_side -top_offset 2.0 -top_segment_layer M5 -top_segment_width 6.0

source -e -v ./script/MAPS/io_routing.tcl
gui_set_pref_value -category {layout} -key {editingEnableSnapping} -value {true}
#gui_stop

#---------------->
## PG Rail
create_power_straps  -direction vertical    -start_at_offset 238 -nets  {VDD_DIG VSS_DIG}  -layer MET6 -width 10  -configure step_and_stop  -step 74.7 -stop 1900 -pitch_within_group 12.6 -do_not_route_over_macros  -extend_for_multiple_connections -keep_floating_wire_pieces  -extension_gap 20 -mark_as_std_cell_pin_connections -do_not_merge_targets -within_voltage_areas {DEFAULT_VA}

create_power_straps  -direction horizontal  -start_at_offset 79.52 -nets  {VDD_DIG VSS_DIG}  -layer MET5 -width 5.72 -configure step_and_stop  -step 79.52 -stop 3110 -pitch_within_group 7.28 -keep_floating_wire_pieces  -extend_for_multiple_connections  -extension_gap 20 -do_not_route_over_macros -mark_as_std_cell_pin_connections -do_not_merge_targets -within_voltage_areas {DEFAULT_VA}

##add rblkg between pads and core:
create_routing_blockage -layers {metal1Blockage via1Blockage metal2Blockage via2Blockage metal3Blockage via3Blockage metal4Blockage via4Blockage metal5Blockage via5Blockage metal6Blockage} -bbox {{175.005 35.640} {205.805 2998.000}}
#create_routing_blockage -layers {metal1Blockage via1Blockage metal2Blockage via2Blockage metal3Blockage via3Blockage metal4Blockage via4Blockage metal5Blockage via5Blockage metal6Blockage} -bbox {{341.000 1664.560} {906.600 1705.855}}

create_power_straps  -direction vertical  -start_at_offset 228 -nets  {VDD_DIG VSS_DIG}  -layer MET4 -width 5.72 -configure step_and_stop  -step 66.08  -num_groups 24 -stop 1900 -pitch_within_group 7.28 -keep_floating_wire_pieces  -do_not_route_over_macros  -extend_for_multiple_connections  -extension_gap 10 -mark_as_std_cell_pin_connections -do_not_merge_targets -within_voltage_areas {DEFAULT_VA}

set_preroute_drc_strategy -min_layer MET1 -max_layer MET4

#routing_blockage over srams:
preroute_standard_cells -nets  {VDD_DIG VSS_DIG} -extension_gap 0.0 -connect horizontal  -skip_macro_pins  -skip_pad_pins  -avoid_merging_vias  -no_via_to_boundary_pin -do_not_route_over_macros  -fill_empty_rows  -within_voltage_areas [get_voltage_areas {DEFAULT_VA}] -port_filter_mode off -cell_master_filter_mode off -cell_instance_filter_mode off -voltage_area_filter_mode off -route_type {P/G Std. Cell Pin Conn}

set_preroute_drc_strategy -min_layer MET1 -max_layer MET6

#gpreroute_standard_cells -nets  {VDD_AO VSS_DIG}  -connect both  -skip_macro_pins  -skip_pad_pins  -avoid_merging_vias  -no_via_to_boundary_pin -do_not_route_over_macros  -fill_empty_rows  -within_voltage_areas {AO} -exclude_voltage_areas {DEFAULT_VA} -port_filter_mode off -cell_master_filter_mode off -cell_instance_filter_mode off -voltage_area_filter_mode off -route_type {P/G Std. Cell Pin Conn}
#.................
                                 
#g create_power_straps  -direction horizontal  -nets  {VDD_DIG_AO}  -layer M1 -width 0.260 -configure rows  -step 5.74 -pitch_within_group 0 -do_not_route_over_macros
#g create_power_straps  -direction horizontal  -nets  {VSS_DIG_AO}  -layer M1 -width 0.260 -configure rows  -step 2.87 -pitch_within_group 0 -do_not_route_over_macros
#g remove_routing_blockage {RB_3618068 RB_3618069 RB_3618070 RB_3618071 RB_3618072 RB_3618073}
#g # Remove rail
#g foreach_in_col i [get_placement_blockages {ANA* FLASH* SRAM* Boundary*  }] {
#g     set box [get_att $i  bbox]
#g     cut_objects -bbox $box  [get_net_shapes -filter {route_type=="P/G Strap"}]
#g     remove_objects [get_net_shapes -within $box -filter {route_type=="P/G Strap"}]
#g     remove_objects [get_vias -within $box -filter {route_type=="P/G Strap"}]
#g }
#g #<----------------
#g 
#g ## Voltage area Rail
#g #g set box  [get_att [get_voltage_areas AO]  bbox]
#g set box {{187.000 1145.055} {985.170 1145.055} {985.170 1159.480} {750.240 1159.480} {750.240 1146.465} {585.590 1146.465} {585.590 1162.350} {468.920 1162.350} {468.920 1146.490} {187.325 1146.490} {187.325 1581.370} {273.000 1581.370} {273.000 1590.755} {953.600 1590.755} {953.600 2214.495} {977.875 2214.495} {977.875 2432.615} {950.070 2432.615} {950.070 2832.690} {1010.445 2832.690} {1010.445 2872.870} {1853.090 2872.870} {1853.090 2023.275} {1838.945 2023.275} {1838.945 1394.745} {1854.760 1394.745} {1854.760 2872.870} {2259.400 2872.870} {2259.400 2884.350} {187.000 2884.350} {187.000 2218.435} {212.150 2218.435} {212.150 2424.005} {187.120 2424.005} {187.120 2872.870} {948.080 2872.870} {948.080 1874.110} {831.410 1874.110} {831.410 1595.675} {187.000 1595.675} {187.000 1145.055}}
#g set vdd_rail [get_net_shapes -filter {route_type=~"P/G *Strap" && layer_name==M1 && owner_net=~VDD_DIG*}] 
#g set vss_rail [get_net_shapes -filter {route_type=~"P/G *Strap" && layer_name==M1 && owner_net=~VSS_DIG*}] 
#g set_undoable_attribute  $vdd_rail owner_net {VDD_DIG_AO}
#g set_undoable_attribute  $vss_rail owner_net {VSS_DIG_AO}
#g remove_objects [get_net_shapes -within $box -filter {route_type=="P/G*" && layer_name!=M1}]
#g remove_objects [get_vias -within $box -filter {route_type=="P/G*"}]
#g 
#g foreach box  [get_att [get_placement_blockage AO_BUF*]  bbox] {
#g set vdd_rail  [get_net_shapes -intersect  $box -filter {route_type=~"P/G *Conn" && layer_name==M1 && owner_net=~VDD_DIG*}] 
#g set vss_rail  [get_net_shapes -intersect  $box -filter {route_type=~"P/G *Conn" && layer_name==M1 && owner_net=~VSS_DIG*}] 
#g set_undoable_attribute  $vdd_rail owner_net {VDD_DIG_AO}
#g set_undoable_attribute  $vss_rail owner_net {VSS_DIG_AO}
#g remove_objects [get_net_shapes -within $box -filter {route_type=="P/G Std. Cell Pin Conn" && layer_name!=M1}]
#g remove_objects [get_vias -within $box -filter {route_type=="P/G Std. Cell Pin Conn"}]
#g }
#g 
#g set vdd_rail [get_net_shapes -filter {route_type=="P/G Std. Cell Pin Conn" && owner_net==VDD_DIG_AO}]
#g set vss_rail [get_net_shapes -filter {route_type=="P/G Std. Cell Pin Conn" && owner_net==VSS_DIG_AO}]
#g set VDD_M4   [get_net_shapes -filter {route_type=="P/G Macro/IO Pin Conn" && layer_name==M4 && owner_net==VDD_DIG_AO && length > 400}]
#g set VSS_M4   [get_net_shapes -filter {route_type=="P/G Macro/IO Pin Conn" && layer_name==M4 && owner_net==VSS_DIG_AO && length > 400}]
#g create_preroute_vias  -nets {VDD_DIG_AO} -object_shapes [add_to_col $vdd_rail $VDD_M4] -from_layer M1 -from_object_std_pin_connection -from_object_std_pin -to_layer M4 -to_object_std_pin_connection -to_object_std_pin
#g create_preroute_vias  -nets {VSS_DIG_AO} -object_shapes [add_to_col $vss_rail $VSS_M4] -from_layer M1 -from_object_std_pin_connection -from_object_std_pin -to_layer M4 -to_object_std_pin_connection -to_object_std_pin



