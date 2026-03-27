###################################################################

# Created by write_script -format dctcl for scenario [S111_max] on Tue Mar 17  \
13:34:54 2026

###################################################################

# Set the current_design #
current_design imeas_wrapper_DATA_WIDTH32_CHN_NUM16

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current mA
set_local_link_library                                                         \
{sc7_ch018ull_base_rvt_ss_typ_max_1p62v_125c.db,sc7_ch018ull_base_rvt_ff_typ_min_1p98v_m40c.db}
set_fix_multiple_port_nets -all -buffer_constants
set_register_merging [current_design] 17
set_register_merging [get_cells {cnt_stable_time_reg[0]}] 0
set_register_merging [get_cells {cnt_stable_time_reg[2]}] 0
set_register_merging [get_cells {cnt_stable_time_reg[3]}] 0
set_register_merging [get_cells {cnt_stable_time_reg[6]}] 0
set_register_merging [get_cells {cnt_stable_time_reg[8]}] 0
set_register_merging [get_cells {cnt_stable_time_reg[10]}] 0
set_register_merging [get_cells enable_cic_reg] 0
set_register_merging [get_cells {cnt_stable_time_reg[12]}] 0
set_register_merging [get_cells imeas_working_sync_d3_reg] 0
set_register_merging [get_cells start_sample_d3_reg] 0
set_register_merging [get_cells imeas_working_sync_d1_reg] 0
set_register_merging [get_cells start_sample_d1_reg] 0
set_register_merging [get_cells imeas_working_sync_d2_reg] 0
set_register_merging [get_cells start_sample_d2_reg] 0
set_register_merging [get_cells eeg_int_sts_reg] 0
set_register_merging [get_cells {cic_data_counter_reg[1]}] 0
set_register_merging [get_cells {cic_data_counter_reg[3]}] 0
set_register_merging [get_cells {cic_data_counter_reg[5]}] 0
set_register_merging [get_cells {cic_data_counter_reg[9]}] 0
set_register_merging [get_cells {cic_data_counter_reg[14]}] 0
set_register_merging [get_cells {cic_data_counter_reg[11]}] 0
set_register_merging [get_cells {cic_data_counter_reg[7]}] 0
set_register_merging [get_cells {cic_data_counter_reg[2]}] 0
set_register_merging [get_cells {cic_data_counter_reg[13]}] 0
set_register_merging [get_cells {cic_data_counter_reg[10]}] 0
set_register_merging [get_cells {cic_data_counter_reg[6]}] 0
set_register_merging [get_cells {cic_data_counter_reg[12]}] 0
set_register_merging [get_cells {cic_data_counter_reg[4]}] 0
set_register_merging [get_cells {cic_data_counter_reg[8]}] 0
set_register_merging [get_cells {cic_data_counter_reg[15]}] 0
set_register_merging [get_cells flg_measure_reg] 0
set_register_merging [get_cells meas_done_d1_reg] 0
set_register_merging [get_cells flg_start_reg] 0
set_register_merging [get_cells imeas_working_sync_d1_pclk_reg] 0
set_register_merging [get_cells final_start_d1_reg] 0
set_register_merging [get_cells start_y_d4_reg] 0
set_register_merging [get_cells start_cmd_d1_reg] 0
set_register_merging [get_cells flg_start_d1_reg] 0
set_register_merging [get_cells flg_stop_sent_reg] 0
set_register_merging [get_cells start_meas_d2_reg] 0
set_register_merging [get_cells imeas_en_sync_d1_reg] 0
set_register_merging [get_cells flg_start_cmd_reg] 0
set_register_merging [get_cells stop_cmd_d1_reg] 0
set_register_merging [get_cells flg_start_cmd_d1_reg] 0
set_register_merging [get_cells single_shot_true_reg] 0
set_register_merging [get_cells start_meas_d1_reg] 0
set_register_merging [get_cells start_y_d3_reg] 0
set_register_merging [get_cells {cnt_stable_time_reg[15]}] 0
set_register_merging [get_cells {cnt_stable_time_reg[14]}] 0
set_register_merging [get_cells {cnt_stable_time_reg[13]}] 0
set_register_merging [get_cells {cnt_stable_time_reg[11]}] 0
set_register_merging [get_cells {cnt_stable_time_reg[9]}] 0
set_register_merging [get_cells {cnt_stable_time_reg[7]}] 0
set_register_merging [get_cells {cnt_stable_time_reg[5]}] 0
set_register_merging [get_cells {cnt_stable_time_reg[4]}] 0
set_register_merging [get_cells {cnt_stable_time_reg[1]}] 0
set_register_merging [get_cells {cic_data_counter_reg[0]}] 0
set compile_inbound_cell_optimization false
set compile_inbound_max_cell_percentage 10.0
