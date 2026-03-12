/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_app_demo_scenario_base_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_app_demo_scenario_base_test                                             
// Designer	: shreeyal@nanochap.com                                                                 
// Date		: 26-06-2025                                                                     
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

//************************************************************************************
// NOTE : This test checks the leadoff and after that short for base 
//************************************************************************************

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_app_demo_scenario_base_test
`define TESTCFG soc_app_demo_scenario_base_test_cfg

class `TESTCFG extends soc_base_test_cfg;

  `nnc_object_utils(`TESTCFG)

  // ===============================================
  // Adding your new varialbles in config test
  // -----------------------------------------------

  rand logic [7:0] wr_data[256];
  rand logic [7:0] wr_data1[256];
  rand int         no_of_bytes; 
  rand logic [7:0] reg_addr;
  rand logic [7:0] pads;
  rand logic [7:0] mask;
  rand logic [7:0] expected_data;
       logic [7:0] rd_data;
       logic [7:0]  sine_data[128];
       logic [13:0] clk_freq;//in Khz
       logic [12:0] half_period_limit;
  rand logic [13:0] half_period0[2];
  rand logic [13:0] half_period1[2];
  rand logic [13:0] half_period2[2];
       logic [31:0] hlf_wave_lim; // number of clocks for positive half wave
       logic [31:0] neg_hlf_wave_lim; // number of clocks for negative half wave
       logic [31:0] hlf_wave0_lim[2]; // number of clocks per point for positive half wave0
       logic [31:0] neg_hlf_wave0_lim[2]; // number of clocks per point for negative half wave0
       logic [31:0] hlf_wave1_lim[2]; // number of clocks per point for positive half wave1
       logic [31:0] neg_hlf_wave1_lim[2]; // number of clocks per point for negative half wave1
       logic [31:0] hlf_wave2_lim[2]; // number of clocks per point for positive half wave2
       logic [31:0] neg_hlf_wave2_lim[2]; // number of clocks per point for negative half wave2
       logic [15:0] rest_lim; // number of clocks for each rest period
       logic [31:0] silent_lim; // number of clocks for each silent period
       logic [15:0] rest_wave0_lim[2]; // number of clocks for each rest period wave0
       logic [31:0] silent_wave0_lim[2]; // number of clocks for each silent period wave0
       logic [15:0] rest_wave1_lim[2]; // number of clocks for each rest period wave1
       logic [31:0] silent_wave1_lim[2]; // number of clocks for each silent period wave1
       logic [15:0] rest_wave2_lim[2]; // number of clocks for each rest period wave2
       logic [31:0] silent_wave2_lim[2]; // number of clocks for each silent period wave2
  rand logic [1:0]  preload_sel;
  rand logic [1:0]  dac_sel;
  rand logic        dly_dis;
  rand logic        short_detect_by_lead_off_en;
  rand logic        lead_off_detect_by_short_circuit_en;
  rand logic [1:0]  A2D_comp_sel;
  rand logic [31:0] lead_off_tgt_dly_dac0;
  rand logic [31:0] lead_off_tgt_dly_dac1;
        logic [31:0] lead_off_timer_cnt_dac0;
        logic [31:0] lead_off_timer_cnt_dac1;
        logic [31:0] lead_off_counter_th_dac0;
        logic [31:0] lead_off_counter_th_dac1;
  rand logic        lead_off_ch0_int_en;
  rand logic        lead_off_ch1_int_en;
  rand logic        lead_off_stop_en_ch0;
  rand logic        lead_off_stop_en_ch1;
  rand logic        lead_off_ch0_comp_low_active;
  rand logic        lead_off_ch1_comp_low_active;
  rand logic        rest_en;
  rand logic        silent_en;
  rand logic        neg_ena;
  rand logic        pos_dis;
  rand logic        int_active_level_high_or_low;
  randc logic       clear_intr_manual_or_auto;
  randc logic       intr_length_slct_level_or_pulse;

  rand logic [2:0] points_sel;
  rand logic [2:0] waveform_sel;
  rand logic       load_points_sel;
  rand logic       pos_neg_diff_sel;
  rand logic       dac_bit_len_sel_drv0;//1'b0:8-bits; 1'b1:12-bits (only 8 bits supported for sine)
  rand logic       dac_bit_len_sel_drv1;//1'b0:8-bits; 1'b1:12-bits (only 8 bits supported for sine)
  rand logic       auto_man;//1'b0:auto; 1'b1:manual
  rand logic [7:0] dac0_data_l;
  rand logic [3:0] dac0_data_h;
  rand logic [2:0] dac0_msb_sel;
  rand logic [7:0] dac1_data_l;
  rand logic [3:0] dac1_data_h;
  rand logic [2:0] dac1_msb_sel;
  rand logic       PULLAB_pos_en;
  rand logic       PULLAB_neg_en;
  rand logic [5:0] PULLAB_lim;
       logic [7:0] NO_OF_LOAD_POINTS;
  randc logic      same_pos_neg_period;

  rand logic [15:0] DELAY_lim;
       logic [23:0] delay_limit_CH1;
       logic [23:0] delay_limit_CH2;
       logic [23:0] level_tgt_range_CH1;
       logic [23:0] level_tgt_range_CH2;
       logic [23:0] level_tgt_range;
       logic [23:0] level_tgt_limit;
       logic [1:0]  lead_off_sts;

       integer      cnt;
       logic [31:0] wave_period_ch1[3];//considering upto 3 waveform_sel
       logic [31:0] wave_period_ch2[3];//considering upto 3 waveform_sel
       logic [31:0] leadoff_pulsewidth_ch1[3];//considering upto 3 waveform_sel
       logic [31:0] leadoff_pulsewidth_ch2[3];//considering upto 3 waveform_sel
       logic [31:0] period_ch1;
       logic [31:0] period_ch2;
       logic [31:0] short_pulse_width_ch1;
       logic [31:0] short_pulse_width_ch2;
       logic [31:0] leadoff_pulse_width_ch1;
       logic [31:0] leadoff_pulse_width_ch2;
       logic [31:0] wave_pulsewidth_ch1[3];//considering upto 3 waveform_sel
       logic [31:0] wave_pulsewidth_ch2[3];//considering upto 3 waveform_sel
       logic [31:0] pulsewidth_ch1[3];//considering upto 3 waveform_sel
       logic [31:0] pulsewidth_ch2[3];//considering upto 3 waveform_sel
  rand logic [31:0] no_of_cycles_CH1;
  rand logic [31:0] no_of_cycles_CH2;
  rand logic [7:0]  cnt_percent_of_timer_TH1;
  rand logic [7:0]  cnt_percent_of_timer_TH2;
  rand logic       stimu_COMP_sel_CH1;//1'b0: Selects CH1 STIMU0; 1'b1: Selects CH1 STIMU1
  rand logic       stimu_COMP_sel_CH2;//1'b0: Selects CH2 STIMU2; 1'b1: Selects CH2 STIMU3
  rand logic       stimu_COMP_en_CH1;//1'b1: Enables CH1 comparator; 1'b0: Disables CH1 comparator
  rand logic       stimu_COMP_en_CH2;//1'b1: Enables CH2 comparator; 1'b0: Disables CH2 comparator
  rand logic       leadoff_COMP_en_CH1;//1'b1: Enables CH1 leadoff comparator; 1'b0: Disables CH1 leadoff comparator
  rand logic       leadoff_COMP_en_CH2;//1'b1: Enables CH2 leadoff comparator; 1'b0: Disables CH2 leadoff comparator
       bit         disable_wg_scb_drv_0;
       bit         disable_wg_scb_drv_1;
       bit         generate_stimulus_leadoff;
       bit         generate_stimulus_short;
  rand logic [2:0]  lvd_sel;
  rand logic        lvd_en;
  rand logic       leadoff_pos_neg_sel_CH1;//0: pos; 1: neg
  rand logic       leadoff_pos_neg_sel_CH2;//0: pos; 1: neg
  rand logic       anac_short_CH1_en ;
  rand logic       anac_short_CH2_en ;
  rand logic        anac_stim_CH1_intr_en;
  rand logic        anac_stim_CH2_intr_en;
  rand logic [11:0] VDAC_DIN_CH1;
  rand logic [11:0] VDAC_DIN_CH2;
      
  rand logic [7:0] tsc_ctrl;
  rand logic [7:0] tsc_int_ctrl;  
  rand logic [7:0] room_temp;
  rand logic [7:0] over_temp_th;
  rand logic [7:0] Dhigh_tsc;      
  rand logic [7:0]  smp_duration;
  rand logic [11:0] stable_duration;
  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_base_test_cfg");
    super.new(name);
    
  endfunction: new

  // ===============================================
  // Adding constraints of randomization
  // -----------------------------------------------

  // No of bytes in a burst
  constraint c_no_of_bytes     { soft no_of_bytes == 2; }

  // dac_sel
  constraint c_dac_sel     { dac_sel == 2'b11; } // dac0 and dac1 both enabled

  // A2D_comp_sel
  constraint c_A2D_comp_sel { solve dac_sel before A2D_comp_sel; A2D_comp_sel == {dac_sel[1],dac_sel[0]}; }

  constraint c_short_detect_by_lead_off_en     { short_detect_by_lead_off_en == 1'b0; } // to do the short, 0: use leadoff comparator , 1: use short comparator

  constraint c_lead_off_detect_by_short_circuit_en     { lead_off_detect_by_short_circuit_en == 1'b0; } // to do leadoff ,0: use short comparator , 1: use leadoff comparator

  constraint c_lead_off_stop_en_ch0 { lead_off_stop_en_ch0 == 1; } // wavegen drv 0 will stop when short/leadoff intr happens
  constraint c_lead_off_stop_en_ch1 { lead_off_stop_en_ch1 == 1; } // wavegen drv 1 will stop when short/leadoff intr happens

  constraint c_lead_off_int_en {lead_off_ch0_int_en == 1; lead_off_ch1_int_en == 1;} // leadoff both channel intr enable 

  constraint c_short_int_en {anac_stim_CH1_intr_en == 1; anac_stim_CH2_intr_en == 1;} // short both channel intr enable 

  constraint c_short_int_sts_en {anac_short_CH1_en == 0; anac_short_CH2_en == 0;} // short both channel sts disable 

  constraint c_lead_off_neg_en { soft neg_ena == 1; } // negative enable
  constraint c_lead_off_pos_dis { soft pos_dis == 0; } // postive enable

  constraint c_lead_off_ch0_comp_low_active { soft lead_off_ch0_comp_low_active == 0; } // A2D_COMP0 high active
  constraint c_lead_off_ch1_comp_low_active { soft lead_off_ch1_comp_low_active == 0; } // A2D_COMP1 high active

  //points_sel
  constraint c_points_sel      { (load_points_sel == 1'b0) -> points_sel != 6;
                                 ((waveform_sel == 3'b000) && (neg_ena == 1'b1) && (pos_dis == 1'b0) && (pos_neg_diff_sel == 1'b0)) -> points_sel inside {[0:6]};
                                 ((waveform_sel == 3'b000) && (neg_ena == 1'b1) && (pos_dis == 1'b0) && (pos_neg_diff_sel == 1'b1)) -> points_sel inside {[0:7]};
                                 ((waveform_sel == 3'b001) && (neg_ena == 1'b1) && (pos_dis == 1'b0) && (pos_neg_diff_sel == 1'b0)) -> points_sel inside {[1:6]};
                                 ((waveform_sel == 3'b001) && (neg_ena == 1'b1) && (pos_dis == 1'b0) && (pos_neg_diff_sel == 1'b1)) -> points_sel inside {[0:6]};
                                 ((waveform_sel == 3'b010) && (neg_ena == 1'b1) && (pos_dis == 1'b0) && (pos_neg_diff_sel == 1'b0)) -> points_sel inside {[2:6]};
                                 ((waveform_sel == 3'b010) && (neg_ena == 1'b1) && (pos_dis == 1'b0) && (pos_neg_diff_sel == 1'b1)) -> points_sel inside {[1:6]};
                                 ((waveform_sel == 3'b000) && ((neg_ena == 1'b0) || (pos_dis == 1'b1))) -> points_sel inside {[0:7]};
                                 ((waveform_sel == 3'b001) && ((neg_ena == 1'b0) || (pos_dis == 1'b1))) -> points_sel inside {[0:6]};
                                 ((waveform_sel == 3'b010) && ((neg_ena == 1'b0) || (pos_dis == 1'b1))) -> points_sel inside {[1:6]};}

  //load_points_sel
  constraint c_load_points_sel { (((waveform_sel == 3'b001) || (waveform_sel == 3'b010)) && (preload_sel == 2'b11)) -> load_points_sel == 1'b1; (preload_sel != 2'b11) -> load_points_sel == 1'b0;}

  //pos_neg_diff_sel
  constraint c_pos_neg_diff_sel { pos_neg_diff_sel == 1'b0;}//This cannot be set for neg-only/pos-only case

  //auto_man
  constraint c_auto_man        { auto_man == 1'b0;}

  //preload_sel
  constraint c_preload_sel     { preload_sel inside {1,3};} // 1: pulse preloaded, 3: user config pulse

  //constraint c_waveform_sel    { (preload_sel == 2'b01) -> waveform_sel == 0; 
  //                               (preload_sel == 2'b11) -> waveform_sel inside {[0:2]};} // 

  constraint c_waveform_sel    { waveform_sel inside {[0:2]};} // 0 = 1 waveform , 1= 2 waveform, 2= 3 waveform 

  //dac_bit_len_sel
  constraint c_dac_bit_len_sel_0 { (preload_sel != 2'b11) -> dac_bit_len_sel_drv0 == 1'b0;}
  constraint c_dac_bit_len_sel_1 { (preload_sel != 2'b11) -> dac_bit_len_sel_drv1 == 1'b0;}

  //dac0_msb_sel
  constraint c_dac0_msb_sel    { dac0_msb_sel inside {[0:0]};} //scale up to bit[11:4] to get bigger dac value

  //dac1_msb_sel
  constraint c_dac1_msb_sel    { dac1_msb_sel inside {[0:0]};} //scale up to bit[11:4] to get bigger dac value

  //PULLAB_lim
  constraint c_PULLAB_lim      { PULLAB_lim != 0;}

  //DELAY_lim
  constraint c_DELAY_lim       { DELAY_lim inside {[0:100]};}

  // pads values
  constraint c_pads            { soft pads == 8'h00; }

  // mask values
  constraint c_mask            { soft mask == 8'hff; }

  //no_of_cycles_CH1
  constraint c_no_of_cycles_CH1  { no_of_cycles_CH1 inside {[10:10]}; } // keeping it fix number of cycles

  //no_of_cycles_CH2
  constraint c_no_of_cycles_CH2  { no_of_cycles_CH2 inside {[10:10]}; } // keeping it fix number of cycles

  constraint c_dac0_data_h  { dac0_data_h == 4'hF; }
  constraint c_dac1_data_h  { dac1_data_h == 4'hF; }

  //constraint c_lead_off_rest_en { rest_en == 1; }
  //constraint c_lead_off_silent_en { silent_en == 1; }

  //cnt_percent_of_timer_TH1
  constraint c_cnt_percent_of_timer_TH1 {cnt_percent_of_timer_TH1 == 40;}//for DC wave only

  //cnt_percent_of_timer_TH2
  constraint c_cnt_percent_of_timer_TH2 {cnt_percent_of_timer_TH2 == 40;}//for DC wave only

  constraint c_int_active_level_low_or_high  { int_active_level_high_or_low == 1; } // 1: intr active high, 0 : intr active low 

  constraint c_clear_intr_manual_or_auto  { clear_intr_manual_or_auto == 1; } // 0: manually clear intr by w1c, 1 : auto clear intr by r1c 

 constraint c_intr_length_slct_pulse_or_level  { intr_length_slct_level_or_pulse == 0; } // 0: level INT, 1: pulse INT

 //stimu_COMP_en_CH1
  constraint c_stimu_COMP_en_CH1 { stimu_COMP_en_CH1 == 1'b1; }//for analog purpose

  //stimu_COMP_en_CH2
  constraint c_stimu_COMP_en_CH2 { stimu_COMP_en_CH2 == 1'b1; }//for analog purpose

  //leadoff_COMP_en_CH1
  constraint c_leadoff_COMP_en_CH1 { leadoff_COMP_en_CH1 == 1'b1; }//for analog purpose

  //leadoff_COMP_en_CH2
  constraint c_leadoff_COMP_en_CH2 { leadoff_COMP_en_CH2 == 1'b1; }//for analog purpose

  constraint c_lead_off_en                { lead_off_en == 1'b1; } //for analog purpose
  constraint c_short_en                   { short_en  == 1'b1; }   //for analog purpose
  constraint c_register_val_ch1           { register_val_ch1 == 2'b10; } // 00: Open-circuit (so huge), 01: short-circuit (5 Ohm), 10: normal (1K Ohm)
  constraint c_register_val_ch2           { register_val_ch2 == 2'b10; } // 00: Open-circuit (so huge), 01: short-circuit (5 Ohm), 10: normal (1K Ohm)
  constraint c_pulse_after_source         { pulse_after_source inside {[0:3]}; } //for analog purpose

  constraint c_lvd_en                   { lvd_en == 1; } //for analog purpose 
  constraint c_lvd_sel                  { lvd_sel != 0; } //for analog purpose
  constraint c_vbat_level               { solve lvd_sel before vbat_level; vbat_level >= lvd_sel; } //for analog purpose

  constraint c_VDAC_DIN_CH1         { VDAC_DIN_CH1 == 200; } //for analog purpose
  constraint c_VDAC_DIN_CH2         { VDAC_DIN_CH2 == 200; } //for analog purpose

  constraint c_room_temp  {room_temp inside {[1:80]};}  //1oC - 40oC
  constraint c_over_temp_th {over_temp_th inside {[170:250]};} //85oC - 125oC  
  constraint c_Dhigh_tsc   {Dhigh_tsc == ((over_temp_th - room_temp)*64/100 + room_temp);}
  constraint c_smp_duration { smp_duration inside {0, 255, [85:150]};
                              smp_duration dist {0:/1, 255:/1, [85:152]:/1}; 
                              if(pclk_sel == 0) smp_duration != 0;}

  constraint c_stable_duration {stable_duration inside {0, 1023, 511, 512, [400:600]};
                                stable_duration dist {0:/1, 1023:/1, 511:/1, 512:/1, [400:600]:/1};}
  // -----------------------------------------------
  // End of adding constraints of randomization
  // ===============================================

endclass : `TESTCFG

// ===============================================
// Main Testcase is defined
// -----------------------------------------------
class `TESTNAME extends soc_base_test;
   
  `nnc_component_utils(`TESTNAME)

  `TESTCFG top_test_cfg;
  bit pulse_user_config_case = 0;
  bit use_old_intr_reg_or_general_reg_to_clr = 1; // use general INT register
  bit[7:0] lvd_sts;
  bit pulse_wave_test ;
  bit sine_trian_arbi_wave_test;

  // -----------------------------------------
  // Declare the new function 
  // -----------------------------------------
  function new(string name, nnc_component parent);
    super.new(name, parent);
  endfunction

  // -----------------------------------------
  // Declare the build_phase function 
  // -----------------------------------------
  virtual function void build_phase(nnc_phase phase);
    super.build_phase(phase);
    `nnc_top.set_timeout(10s);
    top_test_cfg = `TESTCFG::type_id::create("top_test_cfg", this);
  endfunction

  // -----------------------------------------
  // Declare the pre_reset_phase task 
  // -----------------------------------------
  virtual task pre_reset_phase(nnc_phase phase);
    phase.raise_objection(this);

    super.pre_reset_phase(phase);

    assert(top_test_cfg.randomize());
    
    //`DUT_IF.pclk_sel = top_test_cfg.pclk_sel;
    //`DUT_IF.spi_clk_jitter = top_test_cfg.spi_clk_jitter;
    //`DUT_IF.spi_sclk_jitter  = top_test_cfg.spi_sclk_jitter;    
    //`DUT_IF.spi_sclk_freq = top_test_cfg.spi_sclk_freq;
    //`DUT_IF.hfosc_jitter = top_test_cfg.hfosc_jitter;
    //`DUT_IF.hfosc_variation = top_test_cfg.hfosc_variation;

    `DUT_IF.A2D_comp_sel = top_test_cfg.A2D_comp_sel;
    `DUT_IF.assertion_on = 1;
    `DUT_IF.lead_off_stop_en_ch0 = top_test_cfg.lead_off_stop_en_ch0;
    `DUT_IF.lead_off_stop_en_ch1 = top_test_cfg.lead_off_stop_en_ch1;
    `DUT_IF.lead_off_ch0_comp_low_active = top_test_cfg.lead_off_ch0_comp_low_active;
    `DUT_IF.lead_off_ch1_comp_low_active = top_test_cfg.lead_off_ch1_comp_low_active;
    `DUT_IF.lead_off_ch0_int_en = top_test_cfg.lead_off_ch0_int_en;
    `DUT_IF.lead_off_ch1_int_en = top_test_cfg.lead_off_ch1_int_en;
    `DUT_IF.lead_off_dac_sel      = top_test_cfg.dac_sel;
    `DUT_IF.short_detect_by_lead_off_en              = top_test_cfg.short_detect_by_lead_off_en;
    `DUT_IF.lead_off_detect_by_short_circuit_en      = top_test_cfg.lead_off_detect_by_short_circuit_en;
    `DUT_IF.dac_bit_len_sel_drv0  = top_test_cfg.dac_bit_len_sel_drv0;
    `DUT_IF.dac_bit_len_sel_drv1  = top_test_cfg.dac_bit_len_sel_drv1;

    `DUT_IF.points_sel = top_test_cfg.points_sel;
    `DUT_IF.load_wave_data_till_points = top_test_cfg.load_points_sel;
    `DUT_IF.pos_neg_from_same_addr = top_test_cfg.pos_neg_diff_sel;
    `DUT_IF.no_of_waveforms = top_test_cfg.waveform_sel;
    `DUT_IF.PULLAB_pos_en[0] = top_test_cfg.PULLAB_pos_en;
    `DUT_IF.PULLAB_pos_en[1] = top_test_cfg.PULLAB_pos_en;
    `DUT_IF.PULLAB_neg_en[0] = top_test_cfg.PULLAB_neg_en;
    `DUT_IF.PULLAB_neg_en[1] = top_test_cfg.PULLAB_neg_en;
    `DUT_IF.PULLAB_lim[0] = top_test_cfg.PULLAB_lim;
    `DUT_IF.PULLAB_lim[1] = top_test_cfg.PULLAB_lim;
    `DUT_IF.DELAY_lim[0] = top_test_cfg.DELAY_lim;
    `DUT_IF.DELAY_lim[1] = top_test_cfg.DELAY_lim;

    `DUT_IF.counter_percent_of_timer_TH1 = top_test_cfg.cnt_percent_of_timer_TH1;
    `DUT_IF.counter_percent_of_timer_TH2 = top_test_cfg.cnt_percent_of_timer_TH2;
    `DUT_IF.no_of_cycles_CH1 = top_test_cfg.no_of_cycles_CH1;
    `DUT_IF.no_of_cycles_CH2 = top_test_cfg.no_of_cycles_CH2;

    `DUT_IF.preload_sel           = top_test_cfg.preload_sel;
    `DUT_IF.neg_ena = top_test_cfg.neg_ena;
    `DUT_IF.pos_ena = top_test_cfg.pos_dis;
    `DUT_IF.rest_en = top_test_cfg.rest_en;
    `DUT_IF.silent_en = top_test_cfg.silent_en;

    `DUT_IF.lead_off_en = top_test_cfg.lead_off_en;
    `DUT_IF.short_en    = top_test_cfg.short_en;
    `DUT_IF.register_val_ch1 = top_test_cfg.register_val_ch1;
    `DUT_IF.register_val_ch2 = top_test_cfg.register_val_ch2;
    `DUT_IF.D2A_comp_stim0_1_sel = top_test_cfg.stimu_COMP_sel_CH1;
    `DUT_IF.D2A_comp_stim2_3_sel = top_test_cfg.stimu_COMP_sel_CH2;
    `DUT_IF.anac_stim_CH1_pol = top_test_cfg.lead_off_ch0_comp_low_active;
    `DUT_IF.anac_stim_CH2_pol = top_test_cfg.lead_off_ch1_comp_low_active;
    `DUT_IF.leadoff_pos_neg_sel_CH1 = top_test_cfg.leadoff_pos_neg_sel_CH1;
    `DUT_IF.leadoff_pos_neg_sel_CH2 = top_test_cfg.leadoff_pos_neg_sel_CH2;

    `DUT_IF.int_active_level_high_or_low = top_test_cfg.int_active_level_high_or_low;
    `DUT_IF.clear_intr_manual_or_auto = top_test_cfg.clear_intr_manual_or_auto;
    `DUT_IF.intr_length_slct_level_or_pulse = top_test_cfg.intr_length_slct_level_or_pulse;

    // short configs
    `DUT_IF.stop_wave1 = top_test_cfg.lead_off_stop_en_ch0;
    `DUT_IF.stop_wave2 = top_test_cfg.lead_off_stop_en_ch1;
    `DUT_IF.anac_stim_CH1_intr_en = top_test_cfg.anac_stim_CH1_intr_en;
    `DUT_IF.anac_stim_CH2_intr_en = top_test_cfg.anac_stim_CH2_intr_en;
    `DUT_IF.anac_short_CH1_en = top_test_cfg.anac_short_CH1_en;
    `DUT_IF.anac_short_CH2_en = top_test_cfg.anac_short_CH2_en;
    `DUT_IF.lvd_sel = top_test_cfg.lvd_sel;
    `DUT_IF.lvd_en = top_test_cfg.lvd_en;
    `DUT_IF.vbat_level = top_test_cfg.vbat_level;

    `DUT_IF.short_leadoff_debug_counter_check_en = 0;
    phase.drop_objection(this);
  endtask : pre_reset_phase

  // -----------------------------------------
  // Declare the main_phase task of your test
  // -----------------------------------------
  virtual task main_phase(nnc_phase phase);
    bit [7:0] wr_data1;
    bit [7:0] rd_data;
    bit [7:0] rd_data1;

    phase.raise_objection(this);
    super.main_phase(phase);
    `nnc_info("SOC_TEST", "soc_app_demo_scenario_base_test start", NNC_LOW)

    generate_stimulus();

    // setup the analog model
    common_setup();

    // setup the wavegen
    wavegen_setup(0);//chip 0

    // reset lead off design 
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_PMU_REG; wr_data[0] == 8'h81;});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // configuration of wavegen drv 0 and 1
    wavegen_drv_config(`WAVEGEN_0_ADDR_BASE);
    wavegen_drv_config(`WAVEGEN_1_ADDR_BASE);

    // configure GENERAL INT CTRL
    top_test_cfg.wr_data[0] = {5'b0,`DUT_IF.int_active_level_high_or_low,`DUT_IF.clear_intr_manual_or_auto,`DUT_IF.intr_length_slct_level_or_pulse};
    `WR_NORMAL_REG(`SOC_GENERAL_INT_CTRL_REG, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // check INTB RESET value
    if(`DUT_IF.int_active_level_high_or_low === 0) begin
	if(`SOC_TB.INTB !== 1)
	  `nnc_error("SOC_TEST", "Error! RESET VALUE INTB not active low as expected!!")
	else
	  `nnc_info("SOC_TEST", "Active low INTB selected!", NNC_LOW)
    end
    else begin
	if(`SOC_TB.INTB !== 0)
	  `nnc_error("SOC_TEST", "Error! RESET VALUE INTB not active high as expected!!")
	else
	   `nnc_info("SOC_TEST", "Active high INTB selected!", NNC_LOW)
    end

    fork
      wavegen_scb_dis;//disable wavegen SCB whenever leadoff/short happens & wavegen stops
      wavegen_scb_en;//enable wavegen SCB whenever leadoff/short happens & wavegen restarts
    join_none

    //calculate and set timer/response counter threshold
    set_counter_threshold();

    // configuration of leadoff
    leadoff_config();

    // enable leadoff intr
    top_test_cfg.wr_data[0] = {1'b0,`DUT_IF.lead_off_ch1_comp_low_active,`DUT_IF.lead_off_ch1_int_en,`DUT_IF.lead_off_ch0_int_en,`DUT_IF.lead_off_stop_en_ch1,`DUT_IF.lead_off_ch0_comp_low_active,1'b0,`DUT_IF.lead_off_stop_en_ch0};
    `WR_NORMAL_REG(`SOC_LEAD_OFF_INT_REG, top_test_cfg.wr_data[0], top_test_cfg.pads);

    //Configure short detection block
    short_config;

    // enable short intr
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_INT_COMP_POL_REG; wr_data[0] == {1'b0,`DUT_IF.anac_short_CH2_en,`DUT_IF.anac_short_CH1_en, `DUT_IF.lead_off_detect_by_short_circuit_en, `DUT_IF.anac_stim_CH2_intr_en, `DUT_IF.anac_stim_CH1_intr_en, `DUT_IF.anac_stim_CH2_pol, `DUT_IF.anac_stim_CH1_pol};});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    `DUT_IF.A2D_stim_sel = top_test_cfg.A2D_stim_sel;//only used if analog model is not used

    $display("\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/");
    $display("\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/ LEADOFF DETECTION TESTING /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/");
    $display("\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/");

    // generate leadoff stimulus
    top_test_cfg.generate_stimulus_leadoff = 1;

    // enable the leadoff scb
    `LEAD_OFF_SCB_EN = 1;

    // enable the wavegen driver
    wavegen_drv_enable;

    // release reset of lead off  
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_PMU_REG; wr_data[0] == 8'h01;});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    check_leadoff_intr();

    // stop leadoff stimulus
    top_test_cfg.generate_stimulus_leadoff = 0;

    // disable the leadoff scb
    `LEAD_OFF_SCB_EN = 0;

    // Disable the leadoff dac_sel to disable the leadoff detection
    `DUT_IF.lead_off_dac_sel = 2'b00;
    top_test_cfg.wr_data[0] = {2'b0, `DUT_IF.lead_off_dac_sel, 3'b0, `DUT_IF.short_detect_by_lead_off_en};
    `WR_NORMAL_REG(`SOC_LEAD_OFF_CTRL_REG, top_test_cfg.wr_data[0], top_test_cfg.pads);

    $display("\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/");
    $display("\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/ SHORT DETECTION TESTING /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/");
    $display("\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/");

    // generate short stimulus
    top_test_cfg.generate_stimulus_short = 1;

    // enable the short scb
    //`ANAC_SHORT_SCB_EN = 1; // Keeping short scb disabled , as SCB counters are not compatible to count same as design when enabled in between of simulation 

    // enable short detection
    `DUT_IF.anac_short_CH1_en = 1;
    `DUT_IF.anac_short_CH2_en = 1;
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_INT_COMP_POL_REG; wr_data[0] == {1'b0,`DUT_IF.anac_short_CH2_en,`DUT_IF.anac_short_CH1_en, `DUT_IF.lead_off_detect_by_short_circuit_en, `DUT_IF.anac_stim_CH2_intr_en, `DUT_IF.anac_stim_CH1_intr_en, `DUT_IF.anac_stim_CH2_pol, `DUT_IF.anac_stim_CH1_pol};});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // monitor and check short detection intr
    check_short_intr();
    
    // stop short stimulus
    //top_test_cfg.generate_stimulus_short = 0;

    // disable the short scb
    //`ANAC_SHORT_SCB_EN = 0;

    // disable short detection
    `DUT_IF.anac_short_CH1_en = 0;
    `DUT_IF.anac_short_CH2_en = 0;
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_INT_COMP_POL_REG; wr_data[0] == {1'b0,`DUT_IF.anac_short_CH2_en,`DUT_IF.anac_short_CH1_en, `DUT_IF.lead_off_detect_by_short_circuit_en, `DUT_IF.anac_stim_CH2_intr_en, `DUT_IF.anac_stim_CH1_intr_en, `DUT_IF.anac_stim_CH2_pol, `DUT_IF.anac_stim_CH1_pol};});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    $display("\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/");
    $display("\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/ TEMPARATURE OVERHEAT (TSC) TESTING /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/");
    $display("\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/");

    check_tsc();

    $display("\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/");
    $display("\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/ LOW VOLTAGE DETECTION (LVD) TESTING /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/");
    $display("\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/");

    check_lvd();

    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    #10000000ns;

    `nnc_info("SOC_TEST", "soc_app_demo_scenario_base_test end now", NNC_LOW)

    // ----------------------------------------------------------------------------------
    // End of test 
    // ==================================================================================

    phase.drop_objection(this);
  endtask: main_phase

  task set_counter_threshold();

   /********************************************************* Calculate the timer_TH to be set for CH1 & CH2 *********************************************/
   if(`DUT_IF.D2A_comp_stim0_1_sel === 0) begin
     top_test_cfg.pulsewidth_ch1[0] = top_test_cfg.hlf_wave0_lim[0] * `DUT_IF.point_cfg_val;
     top_test_cfg.pulsewidth_ch1[1] = top_test_cfg.hlf_wave1_lim[0] * `DUT_IF.point_cfg_val;
     top_test_cfg.pulsewidth_ch1[2] = top_test_cfg.hlf_wave2_lim[0] * `DUT_IF.point_cfg_val;
   end
   else begin
     top_test_cfg.pulsewidth_ch1[0] = top_test_cfg.neg_hlf_wave0_lim[0] * `DUT_IF.point_cfg_val;
     top_test_cfg.pulsewidth_ch1[1] = top_test_cfg.neg_hlf_wave1_lim[0] * `DUT_IF.point_cfg_val;
     top_test_cfg.pulsewidth_ch1[2] = top_test_cfg.neg_hlf_wave2_lim[0] * `DUT_IF.point_cfg_val;
   end
   if(`DUT_IF.D2A_comp_stim2_3_sel === 0) begin
     top_test_cfg.pulsewidth_ch2[0] = top_test_cfg.hlf_wave0_lim[1] * `DUT_IF.point_cfg_val;
     top_test_cfg.pulsewidth_ch2[1] = top_test_cfg.hlf_wave1_lim[1] * `DUT_IF.point_cfg_val;
     top_test_cfg.pulsewidth_ch2[2] = top_test_cfg.hlf_wave2_lim[1] * `DUT_IF.point_cfg_val;
   end
   else begin
     top_test_cfg.pulsewidth_ch2[0] = top_test_cfg.neg_hlf_wave0_lim[1] * `DUT_IF.point_cfg_val;
     top_test_cfg.pulsewidth_ch2[1] = top_test_cfg.neg_hlf_wave1_lim[1] * `DUT_IF.point_cfg_val;
     top_test_cfg.pulsewidth_ch2[2] = top_test_cfg.neg_hlf_wave2_lim[1] * `DUT_IF.point_cfg_val;
   end

    if(`DUT_IF.leadoff_pos_neg_sel_CH1 === 0) begin
      top_test_cfg.leadoff_pulsewidth_ch1[0] = (top_test_cfg.hlf_wave0_lim[0] ) * `DUT_IF.point_cfg_val;
      top_test_cfg.leadoff_pulsewidth_ch1[1] = (top_test_cfg.hlf_wave1_lim[0] ) * `DUT_IF.point_cfg_val;
      top_test_cfg.leadoff_pulsewidth_ch1[2] = (top_test_cfg.hlf_wave2_lim[0] ) * `DUT_IF.point_cfg_val;
    end
    else begin
      top_test_cfg.leadoff_pulsewidth_ch1[0] = (top_test_cfg.neg_hlf_wave0_lim[0] ) * `DUT_IF.point_cfg_val;
      top_test_cfg.leadoff_pulsewidth_ch1[1] = (top_test_cfg.neg_hlf_wave1_lim[0] ) * `DUT_IF.point_cfg_val;
      top_test_cfg.leadoff_pulsewidth_ch1[2] = (top_test_cfg.neg_hlf_wave2_lim[0] ) * `DUT_IF.point_cfg_val;
    end
    if(`DUT_IF.leadoff_pos_neg_sel_CH2 === 0) begin
      top_test_cfg.leadoff_pulsewidth_ch2[0] = (top_test_cfg.hlf_wave0_lim[1] ) * `DUT_IF.point_cfg_val;
      top_test_cfg.leadoff_pulsewidth_ch2[1] = (top_test_cfg.hlf_wave1_lim[1] ) * `DUT_IF.point_cfg_val;
      top_test_cfg.leadoff_pulsewidth_ch2[2] = (top_test_cfg.hlf_wave2_lim[1] ) * `DUT_IF.point_cfg_val;
    end
    else begin
      top_test_cfg.leadoff_pulsewidth_ch2[0] = (top_test_cfg.neg_hlf_wave0_lim[1] ) * `DUT_IF.point_cfg_val;
      top_test_cfg.leadoff_pulsewidth_ch2[1] = (top_test_cfg.neg_hlf_wave1_lim[1] ) * `DUT_IF.point_cfg_val;
      top_test_cfg.leadoff_pulsewidth_ch2[2] = (top_test_cfg.neg_hlf_wave2_lim[1] ) * `DUT_IF.point_cfg_val;
    end

    top_test_cfg.wave_pulsewidth_ch1[0] = (top_test_cfg.hlf_wave0_lim[0] + top_test_cfg.neg_hlf_wave0_lim[0]) * `DUT_IF.point_cfg_val;
    top_test_cfg.wave_pulsewidth_ch1[1] = (top_test_cfg.hlf_wave1_lim[0] + top_test_cfg.neg_hlf_wave1_lim[0]) * `DUT_IF.point_cfg_val;
    top_test_cfg.wave_pulsewidth_ch1[2] = (top_test_cfg.hlf_wave2_lim[0] + top_test_cfg.neg_hlf_wave2_lim[0]) * `DUT_IF.point_cfg_val;
    top_test_cfg.wave_pulsewidth_ch2[0] = (top_test_cfg.hlf_wave0_lim[1] + top_test_cfg.neg_hlf_wave0_lim[1]) * `DUT_IF.point_cfg_val;
    top_test_cfg.wave_pulsewidth_ch2[1] = (top_test_cfg.hlf_wave1_lim[1] + top_test_cfg.neg_hlf_wave1_lim[1]) * `DUT_IF.point_cfg_val;
    top_test_cfg.wave_pulsewidth_ch2[2] = (top_test_cfg.hlf_wave2_lim[1] + top_test_cfg.neg_hlf_wave2_lim[1]) * `DUT_IF.point_cfg_val;
    top_test_cfg.wave_period_ch1[0] = top_test_cfg.wave_pulsewidth_ch1[0] + (`DUT_IF.rest_en * top_test_cfg.rest_wave0_lim[0]) + (`DUT_IF.silent_en * top_test_cfg.silent_wave0_lim[0]) +
                                  (`DUT_IF.PULLAB_pos_en[0] * `DUT_IF.PULLAB_lim[0]) + (`DUT_IF.PULLAB_neg_en[0] * `DUT_IF.PULLAB_lim[0]);
    top_test_cfg.wave_period_ch1[1] = top_test_cfg.wave_pulsewidth_ch1[1] + (`DUT_IF.rest_en * top_test_cfg.rest_wave1_lim[0]) + (`DUT_IF.silent_en * top_test_cfg.silent_wave1_lim[0]) +
                                  (`DUT_IF.PULLAB_pos_en[0] * `DUT_IF.PULLAB_lim[0]) + (`DUT_IF.PULLAB_neg_en[0] * `DUT_IF.PULLAB_lim[0]);
    top_test_cfg.wave_period_ch1[2] = top_test_cfg.wave_pulsewidth_ch1[2] + (`DUT_IF.rest_en * top_test_cfg.rest_wave2_lim[0]) + (`DUT_IF.silent_en * top_test_cfg.silent_wave2_lim[0]) +
                                  (`DUT_IF.PULLAB_pos_en[0] * `DUT_IF.PULLAB_lim[0]) + (`DUT_IF.PULLAB_neg_en[0] * `DUT_IF.PULLAB_lim[0]);
    top_test_cfg.wave_period_ch2[0] = top_test_cfg.wave_pulsewidth_ch2[0] + (`DUT_IF.rest_en * top_test_cfg.rest_wave0_lim[1]) + (`DUT_IF.silent_en * top_test_cfg.silent_wave0_lim[1]) +
                                  (`DUT_IF.PULLAB_pos_en[0] * `DUT_IF.PULLAB_lim[0]) + (`DUT_IF.PULLAB_neg_en[0] * `DUT_IF.PULLAB_lim[0]);
    top_test_cfg.wave_period_ch2[1] = top_test_cfg.wave_pulsewidth_ch2[1] + (`DUT_IF.rest_en * top_test_cfg.rest_wave1_lim[1]) + (`DUT_IF.silent_en * top_test_cfg.silent_wave1_lim[1]) +
                                  (`DUT_IF.PULLAB_pos_en[0] * `DUT_IF.PULLAB_lim[0]) + (`DUT_IF.PULLAB_neg_en[0] * `DUT_IF.PULLAB_lim[0]);
    top_test_cfg.wave_period_ch2[2] = top_test_cfg.wave_pulsewidth_ch2[2] + (`DUT_IF.rest_en * top_test_cfg.rest_wave2_lim[1]) + (`DUT_IF.silent_en * top_test_cfg.silent_wave2_lim[1]) +
                                  (`DUT_IF.PULLAB_pos_en[0] * `DUT_IF.PULLAB_lim[0]) + (`DUT_IF.PULLAB_neg_en[0] * `DUT_IF.PULLAB_lim[0]);

    if(`DUT_IF.no_of_waveforms === 0) begin
	//period
	top_test_cfg.period_ch1 = top_test_cfg.wave_period_ch1[0];
	top_test_cfg.period_ch2 = top_test_cfg.wave_period_ch2[0];
	//pulsewidth
	//for SHORT detection
	top_test_cfg.short_pulse_width_ch1 = top_test_cfg.pulsewidth_ch1[0];
	top_test_cfg.short_pulse_width_ch2 = top_test_cfg.pulsewidth_ch2[0];
	//for LEAD-OFF detection
	top_test_cfg.leadoff_pulse_width_ch1 = top_test_cfg.leadoff_pulsewidth_ch1[0];
	top_test_cfg.leadoff_pulse_width_ch2 = top_test_cfg.leadoff_pulsewidth_ch2[0];
    end
    else if(`DUT_IF.no_of_waveforms === 1) begin
	//period
	top_test_cfg.period_ch1 = top_test_cfg.wave_period_ch1[0] + top_test_cfg.wave_period_ch1[1];
	top_test_cfg.period_ch2 = top_test_cfg.wave_period_ch2[0] + top_test_cfg.wave_period_ch2[1];
	//pulsewidth
	//for SHORT detection
	top_test_cfg.short_pulse_width_ch1 = top_test_cfg.pulsewidth_ch1[0] + top_test_cfg.pulsewidth_ch1[1];
	top_test_cfg.short_pulse_width_ch2 = top_test_cfg.pulsewidth_ch2[0] + top_test_cfg.pulsewidth_ch2[1];
	//for LEAD-OFF detection
	top_test_cfg.leadoff_pulse_width_ch1 = top_test_cfg.leadoff_pulsewidth_ch1[0] + top_test_cfg.leadoff_pulsewidth_ch1[1];
	top_test_cfg.leadoff_pulse_width_ch2 = top_test_cfg.leadoff_pulsewidth_ch2[0] + top_test_cfg.leadoff_pulsewidth_ch2[1];
    end
    else if(`DUT_IF.no_of_waveforms === 2) begin
	//period
    	top_test_cfg.period_ch1 = top_test_cfg.wave_period_ch1[0] + top_test_cfg.wave_period_ch1[1] + top_test_cfg.wave_period_ch1[2];
	top_test_cfg.period_ch2 = top_test_cfg.wave_period_ch2[0] + top_test_cfg.wave_period_ch2[1] + top_test_cfg.wave_period_ch2[2];
	//pulsewidth
    	//for SHORT detection
    	top_test_cfg.short_pulse_width_ch1 = top_test_cfg.pulsewidth_ch1[0] + top_test_cfg.pulsewidth_ch1[1] + top_test_cfg.pulsewidth_ch1[2];
	top_test_cfg.short_pulse_width_ch2 = top_test_cfg.pulsewidth_ch2[0] + top_test_cfg.pulsewidth_ch2[1] + top_test_cfg.pulsewidth_ch2[2];
	//for LEAD-OFF detection
	top_test_cfg.leadoff_pulse_width_ch1 = top_test_cfg.leadoff_pulsewidth_ch1[0] + top_test_cfg.leadoff_pulsewidth_ch1[1] + top_test_cfg.leadoff_pulsewidth_ch1[2];
	top_test_cfg.leadoff_pulse_width_ch2 = top_test_cfg.leadoff_pulsewidth_ch2[0] + top_test_cfg.leadoff_pulsewidth_ch2[1] + top_test_cfg.leadoff_pulsewidth_ch2[2];
    end    

    top_test_cfg.lead_off_timer_cnt_dac0 = (`DUT_IF.no_of_cycles_CH1 + `DUT_IF.no_of_waveforms)/(`DUT_IF.no_of_waveforms+1) * top_test_cfg.period_ch1;
    top_test_cfg.lead_off_timer_cnt_dac1 = (`DUT_IF.no_of_cycles_CH2 + `DUT_IF.no_of_waveforms)/(`DUT_IF.no_of_waveforms+1) * top_test_cfg.period_ch2;
    `DUT_IF.lead_off_timer_cnt_dac0 = top_test_cfg.lead_off_timer_cnt_dac0 + `DUT_IF.DELAY_lim[0];
    `DUT_IF.lead_off_timer_cnt_dac1 = top_test_cfg.lead_off_timer_cnt_dac1 + `DUT_IF.DELAY_lim[0];
    `DUT_IF.anac_short_CH1_timer_TH = top_test_cfg.lead_off_timer_cnt_dac0 + `DUT_IF.DELAY_lim[0];
    `DUT_IF.anac_short_CH2_timer_TH = top_test_cfg.lead_off_timer_cnt_dac1 + `DUT_IF.DELAY_lim[0];

    /********************************************************* Calculate the response counter_TH to be set for CH1 & CH2 *********************************************/
    if(sine_trian_arbi_wave_test === 1)begin // continous sine,triangle,arbitary case
      `DUT_IF.anac_short_CH1_counter_TH = ((`DUT_IF.no_of_cycles_CH1 + `DUT_IF.no_of_waveforms)/(`DUT_IF.no_of_waveforms+1) * (top_test_cfg.short_pulse_width_ch1)) / 2;    
      `DUT_IF.anac_short_CH2_counter_TH = ((`DUT_IF.no_of_cycles_CH2 + `DUT_IF.no_of_waveforms)/(`DUT_IF.no_of_waveforms+1) * (top_test_cfg.short_pulse_width_ch2)) / 2;
      `DUT_IF.lead_off_counter_th_dac0  = ((`DUT_IF.no_of_cycles_CH1 + `DUT_IF.no_of_waveforms)/(`DUT_IF.no_of_waveforms+1) * (top_test_cfg.leadoff_pulse_width_ch1)) / 2;    
      `DUT_IF.lead_off_counter_th_dac1  = ((`DUT_IF.no_of_cycles_CH2 + `DUT_IF.no_of_waveforms)/(`DUT_IF.no_of_waveforms+1) * (top_test_cfg.leadoff_pulse_width_ch2)) / 2;
      `nnc_info("SOC_TEST", $sformatf("sine_trian_arbi_wave_test = 1 "), NNC_LOW)
    end
    else if(pulse_wave_test === 1)begin //pulse case, continous pulse case
      //`DUT_IF.anac_short_CH1_counter_TH = ((`DUT_IF.no_of_cycles_CH1 + `DUT_IF.no_of_waveforms)/(`DUT_IF.no_of_waveforms+1) * (top_test_cfg.short_pulse_width_ch1)) - 1;    
      //`DUT_IF.anac_short_CH2_counter_TH = ((`DUT_IF.no_of_cycles_CH2 + `DUT_IF.no_of_waveforms)/(`DUT_IF.no_of_waveforms+1) * (top_test_cfg.short_pulse_width_ch2)) - 1;
      //`DUT_IF.lead_off_counter_th_dac0  = ((`DUT_IF.no_of_cycles_CH1 + `DUT_IF.no_of_waveforms)/(`DUT_IF.no_of_waveforms+1) * (top_test_cfg.leadoff_pulse_width_ch1)) - 1;    
      //`DUT_IF.lead_off_counter_th_dac1  = ((`DUT_IF.no_of_cycles_CH2 + `DUT_IF.no_of_waveforms)/(`DUT_IF.no_of_waveforms+1) * (top_test_cfg.leadoff_pulse_width_ch2)) - 1;
      // 2 extra clks considered , as counter resp starts 2 clk later than source signal
      `DUT_IF.anac_short_CH1_counter_TH = ((`DUT_IF.no_of_cycles_CH1 + `DUT_IF.no_of_waveforms)/(`DUT_IF.no_of_waveforms+1) * (top_test_cfg.short_pulse_width_ch1)) - 3;    
      `DUT_IF.anac_short_CH2_counter_TH = ((`DUT_IF.no_of_cycles_CH2 + `DUT_IF.no_of_waveforms)/(`DUT_IF.no_of_waveforms+1) * (top_test_cfg.short_pulse_width_ch2)) - 3;
      `DUT_IF.lead_off_counter_th_dac0  = ((`DUT_IF.no_of_cycles_CH1 + `DUT_IF.no_of_waveforms)/(`DUT_IF.no_of_waveforms+1) * (top_test_cfg.leadoff_pulse_width_ch1)) - 3;    
      `DUT_IF.lead_off_counter_th_dac1  = ((`DUT_IF.no_of_cycles_CH2 + `DUT_IF.no_of_waveforms)/(`DUT_IF.no_of_waveforms+1) * (top_test_cfg.leadoff_pulse_width_ch2)) - 3;
      `nnc_info("SOC_TEST", $sformatf("pulse_wave_test = 1"), NNC_LOW)
    end
    else begin // DC case
      `DUT_IF.anac_short_CH1_counter_TH = (`DUT_IF.counter_percent_of_timer_TH1 * `DUT_IF.anac_short_CH1_timer_TH) / 100;
      `DUT_IF.anac_short_CH2_counter_TH = (`DUT_IF.counter_percent_of_timer_TH2 * `DUT_IF.anac_short_CH2_timer_TH) / 100;
      `DUT_IF.lead_off_counter_th_dac0 = (`DUT_IF.counter_percent_of_timer_TH1 * `DUT_IF.lead_off_timer_cnt_dac0) / 100;
      `DUT_IF.lead_off_counter_th_dac1 = (`DUT_IF.counter_percent_of_timer_TH2 * `DUT_IF.lead_off_timer_cnt_dac1) / 100;
      `nnc_info("SOC_TEST", $sformatf("DC case test = 1"), NNC_LOW)
    end

  endtask : set_counter_threshold

  task check_tsc();
`ifndef MIX_SIM_EN
        assert(top_test_cfg.randomize() with {tsc_ctrl[3:0] == {tsc_comp_low_active_en, 3'b111}; tsc_int_ctrl[1:0] == {tsc_comp_low_active_en, 1'b1};}); 
        `nnc_info("", $sformatf("configure the Dhigh_tsc=%h, over_temp_th=%h, room_temp=%h ", top_test_cfg.Dhigh_tsc, top_test_cfg.over_temp_th, top_test_cfg.room_temp), NNC_LOW);
        //set sample duration
        `WR_NORMAL_REG(`SOC_SMP_DURATION_REG, top_test_cfg.smp_duration, top_test_cfg.pads);    
        //set stable duration
        `WR_NORMAL_REG(`SOC_STABLE_BURATION_0_REG, top_test_cfg.stable_duration[7:0], top_test_cfg.pads);    
        `WR_NORMAL_REG(`SOC_STABLE_BURATION_1_REG, {4'hf,top_test_cfg.stable_duration[11:8]}, top_test_cfg.pads);

        `DUT_IF.sensor_temperature = top_test_cfg.room_temp;
        top_test_cfg.room_temp.rand_mode(0);        
        
        //reset tsc
        `WR_NORMAL_REG(`SOC_ANAC_CTRL_REG, 8'b0000_0100, top_test_cfg.pads);    
        `WR_NORMAL_REG(`SOC_ANAC_CTRL_REG, 8'b0000_0000, top_test_cfg.pads);    

        //restart sar 
        do begin
            `nnc_info("", "read busy doing....", NNC_LOW);
           `RD_NORMAL_REG(`SOC_SMP_STS_REG, top_test_cfg.pads, top_test_cfg.rd_data);
            `nnc_info("", $sformatf("read busy doing.... %h", top_test_cfg.rd_data), NNC_LOW);
        end while(top_test_cfg.rd_data[0] === 1);
        `nnc_info("", "read busy finish!", NNC_LOW);

        //read Dnor_din
        `RD_NORMAL_REG(`SOC_VDAC_NOR0_REG, top_test_cfg.pads, top_test_cfg.rd_data);
        
        //calculating Dhigh_tsc  Dhigh_tsc = (Tover - Troom)*0.64 + Dnom_tsc
        top_test_cfg.Dhigh_tsc = ((top_test_cfg.over_temp_th - top_test_cfg.room_temp)*64/100 + top_test_cfg.rd_data);

        //set Dhigh_tsc
        `WR_NORMAL_REG(`SOC_TSC_VDAC8B_DIN_CH1_REG, top_test_cfg.Dhigh_tsc, top_test_cfg.pads);
        //enable tsc_en, tsc_comp_en, tsc_vdac_en
        `WR_NORMAL_REG(`SOC_TSC_CTRL_REG, top_test_cfg.tsc_ctrl, top_test_cfg.pads);
        //enable tsc_int
        `WR_NORMAL_REG(`SOC_TSC_INT_CTLR_REG, top_test_cfg.tsc_int_ctrl, top_test_cfg.pads);
        
        `DUT_IF.tsc_comp_low_active_en = top_test_cfg.tsc_comp_low_active_en; //tsc_comp_low should be match with int_trans_sel        

        // check analog_top interface 
        #500ns;

        if(top_test_cfg.tsc_ctrl[2:0] !== {`ANA_TOP.tsc_monitoring_ch1.D2A_VDAC8B_EN_CHx, `ANA_TOP.tsc_monitoring_ch1.D2A_TSC_COMP_EN_CHx, `ANA_TOP.tsc_monitoring_ch1.D2A_TSC_EN_CHx})begin
            `nnc_error("SOC_TEST", "tsc_ctrl error in spi mode");
        end
        if(top_test_cfg.Dhigh_tsc !== `ANA_TOP.tsc_monitoring_ch1.D2A_VDAC8B_DIN_CHx)begin
            `nnc_error("SOC_TEST", "8bit_dac_din error in spi mode");
        end

        if( `SOC_TOP.IOBUF_PAD[7] === 1) `nnc_error("SOC_TEST", "tsc int error");    
        //over temp
        while(`DUT_IF.sensor_temperature < top_test_cfg.Dhigh_tsc)begin
            #200000ns;
            `DUT_IF.sensor_temperature = `DUT_IF.sensor_temperature + 5;
        end
        
        #(`DUT_IF.a2d_comp_delay_ch1);
        repeat(6) @(posedge `CLK_CTRL_TOP.pclk); //wait for int
        #10ns;
        if((`SOC_TOP.IOBUF_PAD[7] !== 1'b1)) `nnc_error("SOC_TEST", "tsc int error");
        #200000ns;
        `DUT_IF.sensor_temperature = top_test_cfg.room_temp; 

        //clr tsc int
        if(`DUT_IF.clear_intr_manual_or_auto ===1 ) begin
            `RD_NORMAL_REG(`SOC_GENERAL_INT_STS_1_REG, top_test_cfg.pads, top_test_cfg.rd_data);
            if(top_test_cfg.rd_data[7] !== 1) `nnc_error("SOC_TEST", "tsc int error");
        end
        else `WR_NORMAL_REG(`SOC_TSC_INT_STATUS_REG, 8'h1, top_test_cfg.pads);
        
        repeat(6) @(posedge `CLK_CTRL_TOP.pclk); //wait for int clr
        `ifdef BEHAVIORAL
        #10ns;
        `else 
        #50ns;
        `endif
        if( `SOC_TOP.IOBUF_PAD[7] === 1) `nnc_error("SOC_TEST", "tsc int not clr");
`endif
  endtask : check_tsc

  task check_lvd();
    // configure LVD_SEL  
    top_test_cfg.wr_data[0] = `INIT_SOC_ANA_ENABLE_REG_0;
    top_test_cfg.wr_data[0][0] = `DUT_IF.lvd_en;
    `WR_NORMAL_REG(`SOC_ANA_ENABLE_REG_0, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // configure LVD_EN  
    top_test_cfg.wr_data[0] = {5'b0,`DUT_IF.lvd_sel};
    `WR_NORMAL_REG(`SOC_ANA_GEN_1_REG, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // enable LVD intrupts
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_INTR_EN; wr_data[0] == 8'h1;});//enable LVD interrupt
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // low voltage 
    `DUT_IF.vbat_level = $urandom_range(0,`DUT_IF.lvd_sel-1); // when vbat < threshold(lvd_sel),  A2D_LVD =1

    // check INT pin
    `nnc_info("SOC_TEST", $sformatf("waiting for INTB pin to become high"), NNC_LOW)
    if(`DUT_IF.int_active_level_high_or_low == 1) 
      wait(`SOC_TB.INTB === 1);
    else 
      wait(`SOC_TB.INTB === 0);
    `nnc_info("SOC_TEST", "An interrupt happenned ...", NNC_LOW)
    
    lvd_sts = 8'h1;
    // check LVD sts register
    `nnc_info("SOC_TEST", $sformatf("read new general intr status register"), NNC_LOW)
    `RD_NORMAL_REG(`SOC_GENERAL_INT_STS_1_REG,top_test_cfg.pads, top_test_cfg.rd_data); // ch0  and ch1 sts
    if(top_test_cfg.rd_data[0] !== lvd_sts[0]) `uvm_error("SOC_TEST",$sformatf("GENERAL INTR STS : LVD STS register value is='h%0h ,Expected='h%0h", top_test_cfg.rd_data[0],lvd_sts[0]))
    else `nnc_info("SOC_TEST", $sformatf("GENERAL INTR STS register value is='h%0h ,Expected='h%0h", top_test_cfg.rd_data[0],lvd_sts[0]), NNC_LOW)

    // disable LVD INT by fixing the low volatge
    `DUT_IF.vbat_level = $urandom_range(`DUT_IF.lvd_sel,7); // when vbat >= threshold(lvd_sel), A2D_LVD = 0

    // check INT pin
    `nnc_info("SOC_TEST", $sformatf("waiting for INTB to deassert"), NNC_LOW)
    if(`DUT_IF.int_active_level_high_or_low == 1) 
      wait(`SOC_TB.INTB === 0);
    else 
      wait(`SOC_TB.INTB === 1);

    repeat(6)@(posedge `DUT_IF.sys_clk); // atleast 6 pclk between 2 SPI read cmd required by design as per Zhen

    lvd_sts = 8'h0;
    `RD_NORMAL_REG(`SOC_GENERAL_INT_STS_1_REG,top_test_cfg.pads, top_test_cfg.rd_data); // ch0  and ch1 sts
    if(top_test_cfg.rd_data[0] !== lvd_sts[0]) `uvm_error("SOC_TEST",$sformatf("GENERAL INTR STS register value is='h%0h ,Expected='h%0h", top_test_cfg.rd_data[0],lvd_sts[0]))
    else `nnc_info("SOC_TEST", $sformatf("GENERAL INTR STS register value is='h%0h ,Expected='h%0h", top_test_cfg.rd_data[0],lvd_sts[0]), NNC_LOW)
  endtask : check_lvd

  task check_leadoff_intr();
    top_test_cfg.cnt = 0;
    fork : wait_fork 
      if(`DUT_IF.lead_off_dac_sel != 2'b00 && (`DUT_IF.lead_off_ch1_int_en===1 || `DUT_IF.lead_off_ch0_int_en===1))begin // atlist one of the dac selected to generate the interrupt
        while(top_test_cfg.cnt < 1) begin
          
          `nnc_info("SOC_TEST", $sformatf("inside repeat loop = %0d",top_test_cfg.cnt), NNC_LOW)

	  `nnc_info("SOC_TEST", $sformatf("waiting for INTB pin to become high"), NNC_LOW)
          if(`DUT_IF.int_active_level_high_or_low == 1) 
            wait(`SOC_TB.INTB === 1);
          else 
            wait(`SOC_TB.INTB === 0);
	  `nnc_info("SOC_TEST", "An interrupt happenned ...", NNC_LOW)
           leadoff_int_sts_check(); 

          // --------------------------------------------------------
          // Write to SOC_LEAD_OFF_INT_REG to clear the INT
          // --------------------------------------------------------
          fork
            begin
              clear_leadoff_sts();
	      repeat(6)@(posedge `DUT_IF.sys_clk); // atleast 6 pclk between 2 SPI read cmd required by design as per Zhen

              while({`LEADOFF_TOP_1.lead_off_result,`LEADOFF_TOP_0.lead_off_result} != 2'b00) begin // if lead off result is not cleared due to next interrupt, clear it again 
                clear_leadoff_sts();
		repeat(6)@(posedge `DUT_IF.sys_clk); // atleast 6 pclk between 2 SPI read cmd required by design as per Zhen
              end
            end

            begin
              `nnc_info("SOC_TEST", $sformatf("waiting for INTB pin to clear"), NNC_LOW)
              if(`DUT_IF.intr_length_slct_level_or_pulse == 0) // level intr
                if(`DUT_IF.int_active_level_high_or_low == 1) 
		  wait(`SOC_TB.INTB === 0);
                else 
                  wait(`SOC_TB.INTB === 1);
              else
                wait({`LEADOFF_TOP_1.lead_off_result,`LEADOFF_TOP_0.lead_off_result} == 2'b00);

              `nnc_info("SOC_TEST", $sformatf("INTB cleared"), NNC_LOW)
	      end
          join
          //disable fork_dac_int;
          top_test_cfg.cnt++;
        end
      end
      begin
        //#100000000ns;
        #6s;
        `nnc_fatal("SOC_TEST",$sformatf("PULSE PRELOADED CASE : INT not generated for dac_sel= %0b",`DUT_IF.lead_off_dac_sel));
      end
    join_any
    disable wait_fork;

  endtask: check_leadoff_intr

  task check_short_intr();

    top_test_cfg.cnt = 0;
    while(top_test_cfg.cnt < 1) begin
      `nnc_info("SOC_TEST", $sformatf("inside repeat loop = %0d",top_test_cfg.cnt), NNC_LOW)

      if(`DUT_IF.int_active_level_high_or_low === 1)//active high
	wait(`SOC_TB.INTB === 1);
      else//active low
	wait(`SOC_TB.INTB === 0);

      `nnc_info("SOC_TEST", "A2D_STIM SHORT INT!", NNC_LOW)

      if(`DUT_IF.clear_intr_manual_or_auto === 0) begin//if manual with local register access
      // ------------------------------------------------------------------------------
      // Read from SOC_ANA_INTR_SIM_CL_REG (check interrupt status)
      // ------------------------------------------------------------------------------
      	assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_INTR_SIM_CL_REG;});
      	`RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
	if((top_test_cfg.rd_data[0] === 1) && (`ANAC_TOP.spi_anac.ana_comp_ch_intr_sts[0] === 1))
	  `nnc_info("SOC_TEST", "A2D_STIM_0/1 CH1 int sts is set!", NNC_LOW)
      	else if((top_test_cfg.rd_data[0] === 1) && (`ANAC_TOP.spi_anac.ana_comp_ch_intr_sts[0] === 0))
	  `nnc_error("SOC_TEST", "Error! A2D_STIM_0/1 CH1 unexpected int sts is set!!")
      	if((top_test_cfg.rd_data[1] === 1) && (`ANAC_TOP.spi_anac.ana_comp_ch_intr_sts[1] === 1))
	  `nnc_info("SOC_TEST", "A2D_STIM_2/3 CH2 int sts is set!", NNC_LOW)
      	else if((top_test_cfg.rd_data[1] === 1) && (`ANAC_TOP.spi_anac.ana_comp_ch_intr_sts[1] === 0))
	  `nnc_error("SOC_TEST", "Error! A2D_STIM_2/3 CH2 unexpected int sts is set!!")
      end
      else begin//if automatic; reading sts bit supposed to clear interrupt
      if(use_old_intr_reg_or_general_reg_to_clr === 1) begin//if automatic with general register access
        `nnc_info("SOC_TEST", "Automatically clear interrupt using general register!", NNC_LOW)
        // ------------------------------------------------------------------------------
        // Read from SOC_GENERAL_INT_STS_1_REG (check interrupt status)
        // ------------------------------------------------------------------------------
      	assert(top_test_cfg.randomize() with {reg_addr == `SOC_GENERAL_INT_STS_1_REG;});
      	`RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);

	if(top_test_cfg.rd_data[5] === 1'b1) begin
	  `nnc_info("SOC_TEST", "A2D_STIM_0/1 CH1 int sts is set!", NNC_LOW)
	  wait(`ANAC_TOP.spi_anac.ana_comp_ch_intr_sts[0] === 0);
	  `nnc_info("SOC_TEST", "A2D_STIM_0/1 CH1 int cleared!", NNC_LOW)
	end
	if(top_test_cfg.rd_data[6] === 1'b1) begin
	  `nnc_info("SOC_TEST", "A2D_STIM_2/3 CH2 int sts is set!", NNC_LOW)
	  wait(`ANAC_TOP.spi_anac.ana_comp_ch_intr_sts[1] === 0);
	  `nnc_info("SOC_TEST", "A2D_STIM_2/3 CH2 int cleared!", NNC_LOW)
	end
      end
      else begin//if automatic with local register access
        `nnc_info("SOC_TEST", "Automatically clear interrupt using local register!", NNC_LOW)
        // ------------------------------------------------------------------------------
        // Read from SOC_ANA_INTR_SIM_CL_REG (check interrupt status)
        // ------------------------------------------------------------------------------
      	assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_INTR_SIM_CL_REG;});
      	`RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);

	if(top_test_cfg.rd_data[0] === 1'b1) begin
	  `nnc_info("SOC_TEST", "A2D_STIM_0/1 CH1 int sts is set!", NNC_LOW)
	  wait(`ANAC_TOP.spi_anac.ana_comp_ch_intr_sts[0] === 0);
	  `nnc_info("SOC_TEST", "A2D_STIM_0/1 CH1 int cleared!", NNC_LOW)
	end
	if(top_test_cfg.rd_data[1] === 1'b1) begin
	  `nnc_info("SOC_TEST", "A2D_STIM_2/3 CH2 int sts is set!", NNC_LOW)
	  wait(`ANAC_TOP.spi_anac.ana_comp_ch_intr_sts[1] === 0);
	  `nnc_info("SOC_TEST", "A2D_STIM_2/3 CH2 int cleared!", NNC_LOW)
	end
      end
      end
      
      if(`DUT_IF.clear_intr_manual_or_auto === 0) begin//if manual with local register access
        `nnc_info("SOC_TEST", "Manually clear interrupt using local register!", NNC_LOW)
        // ------------------------------------------------------------------------------
        // Write to SOC_ANA_INTR_SIM_CL_REG (clear interrupt)
        // ------------------------------------------------------------------------------
      	assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_INTR_SIM_CL_REG; wr_data[0] == rd_data;});
      	`WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

	if(top_test_cfg.rd_data[0] === 1'b1) begin
	  wait(`ANAC_TOP.spi_anac.ana_comp_ch_intr_sts[0] === 0);
	  `nnc_info("SOC_TEST", "A2D_STIM_0/1 CH1 int cleared!", NNC_LOW)
	end
	if(top_test_cfg.rd_data[1] === 1'b1) begin
	  wait(`ANAC_TOP.spi_anac.ana_comp_ch_intr_sts[1] === 0);
	  `nnc_info("SOC_TEST", "A2D_STIM_2/3 CH2 int cleared!", NNC_LOW)
	end
      end

      top_test_cfg.cnt++;
      top_test_cfg.rd_data = 0;
      #10;
    end
  endtask : check_short_intr

  task generate_stimulus();
    logic [15:0]    randomNumber0;

    `nnc_info("SOC_TEST", "generate_stimulus start", NNC_LOW)
    fork
      // this will generate more number of leadoff condition , i.e. no response in A2D_COMP signals (register_val ==0)
      begin
        wait(top_test_cfg.generate_stimulus_leadoff === 1);
        while(top_test_cfg.generate_stimulus_leadoff === 1) begin
          repeat(400) @(posedge`DUT_IF.sys_clk);
          randomNumber0 = $urandom_range(10,0);
	  `DUT_IF.register_val_ch1 = (randomNumber0 <=3 ) ?  $urandom_range(2'b01,2'b10) : 2'b00;
          randomNumber0 = $urandom_range(10,0);
	  `DUT_IF.register_val_ch2 = (randomNumber0 <=3 ) ?  $urandom_range(2'b01,2'b10) : 2'b00;
        end
      end
      // this will generate more number of short condition , i.e. in A2D_COMP_STIMU signals (register_val ==1)
      begin
        wait(top_test_cfg.generate_stimulus_short === 1);
        while(top_test_cfg.generate_stimulus_short === 1) begin
          repeat(400) @(posedge`DUT_IF.sys_clk);
          randomNumber0 = $urandom_range(10,0);
	  `DUT_IF.register_val_ch1 = (randomNumber0 <=3 ) ?  $urandom_range(2'b00,2'b10) : 2'b01;
          randomNumber0 = $urandom_range(10,0);
	  `DUT_IF.register_val_ch2 = (randomNumber0 <=3 ) ?  $urandom_range(2'b00,2'b10) : 2'b01;
        end
      end
    join_none
  endtask : generate_stimulus

  task common_setup();

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_2_REG; wr_data[0] == {VDAC_DIN_CH1[7:0]};});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_3_REG; wr_data[0] == {2'b0, `DUT_IF.leadoff_pos_neg_sel_CH1, 1'b0, VDAC_DIN_CH1[11:8]};});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_4_REG; wr_data[0] == {VDAC_DIN_CH2[7:0]};});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_5_REG; wr_data[0] == {2'b0, `DUT_IF.leadoff_pos_neg_sel_CH2, 1'b0, VDAC_DIN_CH2[11:8]};});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // ------------------------------------------------------------------------------
    // Write to SOC_ANA_ENABLE_REG_1
    // ------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_ENABLE_REG_1; wr_data[0] == {1'b0, `DUT_IF.D2A_comp_stim0_1_sel, stimu_COMP_en_CH1, 2'b11, leadoff_COMP_en_CH1, 2'b00};});//bit[4] VDAC_EN; bit[3] IDAC_EN
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // ------------------------------------------------------------------------------
    // Write to SOC_ANA_ENABLE_REG_2
    // ------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_ENABLE_REG_2; wr_data[0] == {1'b0, `DUT_IF.D2A_comp_stim2_3_sel, stimu_COMP_en_CH2, 2'b11, leadoff_COMP_en_CH2, 2'b00};});//bit[4] VDAC_EN; bit[3] IDAC_EN
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

     // disable ana intruppts(LVD,comp0 and comp1)
    `nnc_info("SOC_TEST", $sformatf("will be writing intr en register with wr_data %0d",top_test_cfg.wr_data[0]), NNC_LOW)
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_INTR_EN; wr_data[0] == 8'h0;});//disable interrupt
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
  endtask

  task wavegen_scb_dis;
  begin
    forever @(posedge `LEADOFF_TOP_0.lead_off_result or posedge `LEADOFF_TOP_1.lead_off_result or posedge `ANAC_TOP.spi_anac.ana_comp_ch_intr_sts[0] or posedge `ANAC_TOP.spi_anac.ana_comp_ch_intr_sts[1]) begin
      if((`DUT_IF.lead_off_stop_en_ch0 === 1) && (`LEADOFF_TOP_0.lead_off_result === 1) && (top_test_cfg.disable_wg_scb_drv_0 === 0)) begin
	`WAVEGEN_SCB_DRV_0_EN = 1'b0;//Disable
        top_test_cfg.disable_wg_scb_drv_0 = 1;
    	`nnc_info("SOC_TEST", "WAVGEN_SCB Disabled for drv 0 due to leadoff !", NNC_LOW)
      end
      if((`DUT_IF.lead_off_stop_en_ch1 === 1) && (`LEADOFF_TOP_1.lead_off_result === 1) && (top_test_cfg.disable_wg_scb_drv_1 === 0)) begin
	`WAVEGEN_SCB_DRV_1_EN = 1'b0;//Disable
        top_test_cfg.disable_wg_scb_drv_1 = 1;
    	`nnc_info("SOC_TEST", "WAVGEN_SCB Disabled for drv 1 due to leadoff !", NNC_LOW)
      end
      if((`DUT_IF.stop_wave1 === 1) && (`ANAC_TOP.spi_anac.ana_comp_ch_intr_sts[0] === 1) && (top_test_cfg.disable_wg_scb_drv_0 === 0)) begin
	`WAVEGEN_SCB_DRV_0_EN = 1'b0;//Disable
        top_test_cfg.disable_wg_scb_drv_0 = 1;
    	`nnc_info("SOC_TEST", "WAVGEN_SCB Disabled for drv 0 due to short !", NNC_LOW)
      end
      if((`DUT_IF.stop_wave2 === 1) && (`ANAC_TOP.spi_anac.ana_comp_ch_intr_sts[1] === 1) && (top_test_cfg.disable_wg_scb_drv_1 === 0)) begin
	`WAVEGEN_SCB_DRV_1_EN = 1'b0;//Disable
        top_test_cfg.disable_wg_scb_drv_1 = 1;
    	`nnc_info("SOC_TEST", "WAVGEN_SCB Disabled for drv 1 due to short !", NNC_LOW)
      end
    end
  end
  endtask

  task wavegen_scb_en;
  begin
    forever @(negedge `LEADOFF_TOP_0.lead_off_result or negedge `LEADOFF_TOP_1.lead_off_result or negedge `ANAC_TOP.spi_anac.ana_comp_ch_intr_sts[0] or negedge `ANAC_TOP.spi_anac.ana_comp_ch_intr_sts[1]) begin
      if((`DUT_IF.lead_off_stop_en_ch0 === 1) && (`LEADOFF_TOP_0.lead_off_result === 0) && (top_test_cfg.disable_wg_scb_drv_0 === 1)) begin
	`WAVEGEN_SCB_DRV_0_EN = 1'b1;//Enable
        top_test_cfg.disable_wg_scb_drv_0 = 0;
    	`nnc_info("SOC_TEST", "WAVGEN_SCB Enabled for drv 0 due to leadoff !", NNC_LOW)
      end
      if((`DUT_IF.lead_off_stop_en_ch1 === 1) && (`LEADOFF_TOP_1.lead_off_result === 0) && (top_test_cfg.disable_wg_scb_drv_1 === 1)) begin
	`WAVEGEN_SCB_DRV_1_EN = 1'b1;//Enable
        top_test_cfg.disable_wg_scb_drv_1 = 0;
    	`nnc_info("SOC_TEST", "WAVGEN_SCB Enabled for drv 1  due to leadoff !", NNC_LOW)
      end
      if((`DUT_IF.stop_wave1 === 1) && (`ANAC_TOP.spi_anac.ana_comp_ch_intr_sts[0] === 0) && (top_test_cfg.disable_wg_scb_drv_0 === 1)) begin
	`WAVEGEN_SCB_DRV_0_EN = 1'b1;//Enable
        top_test_cfg.disable_wg_scb_drv_0 = 0;
    	`nnc_info("SOC_TEST", "WAVGEN_SCB Enabled for drv 0 due to short !", NNC_LOW)
      end
      if((`DUT_IF.stop_wave2 === 1) && (`ANAC_TOP.spi_anac.ana_comp_ch_intr_sts[1] === 0) && (top_test_cfg.disable_wg_scb_drv_1 === 1)) begin
	`WAVEGEN_SCB_DRV_1_EN = 1'b1;//Enable
        top_test_cfg.disable_wg_scb_drv_1 = 0;
    	`nnc_info("SOC_TEST", "WAVGEN_SCB Enabled for drv 1 due to short !", NNC_LOW)
      end
    end
  end
  endtask

  task leadoff_int_sts_check();

    // ------------------------------------------------------------------------------
    // Read from SOC_LEAD_OFF_INT_REG & SOC_LEAD_OFF_CTRL_REG (check interrupt status)
    // ------------------------------------------------------------------------------
    if(`DUT_IF.clear_intr_manual_or_auto === 0) begin
      if(use_old_intr_reg_or_general_reg_to_clr == 0) begin // old intr status register
        `RD_NORMAL_REG(`SOC_LEAD_OFF_INT_REG,top_test_cfg.pads, top_test_cfg.rd_data); // ch0 sts
        top_test_cfg.lead_off_sts[0] = top_test_cfg.rd_data[1];

        `RD_NORMAL_REG(`SOC_LEAD_OFF_CTRL_REG,top_test_cfg.pads, top_test_cfg.rd_data); // ch1 sts
        top_test_cfg.lead_off_sts[1] = top_test_cfg.rd_data[7];
      end
      else begin // new general intr sts reg
        `RD_NORMAL_REG(`SOC_GENERAL_INT_STS_1_REG,top_test_cfg.pads, top_test_cfg.rd_data); // ch0  and ch1 sts
        top_test_cfg.lead_off_sts[1:0] = top_test_cfg.rd_data[4:3];
      end

      if(`DUT_IF.lead_off_ch0_int_en === 1 && top_test_cfg.lead_off_sts[0] === 1) begin // ch0 
        `nnc_info("SOC_TEST", "CH0 INTR STATUS CHECK DONE !", NNC_LOW)
      end
      else if(`DUT_IF.lead_off_ch1_int_en === 1 && top_test_cfg.lead_off_sts[1] === 1) begin // ch1
        `nnc_info("SOC_TEST", "CH1 INTR STATUS CHECK DONE !", NNC_LOW)
      end
      else begin
        `nnc_error("SOC_TEST",$sformatf("lead_off_ch0_int_en=%0d,lead_off_ch1_int_en=%0d, ch0_sts=%0d,ch1_sts=%0d",`DUT_IF.lead_off_ch0_int_en,`DUT_IF.lead_off_ch1_int_en,top_test_cfg.lead_off_sts[0],top_test_cfg.lead_off_sts[1]));
      end
    end
   
  endtask : leadoff_int_sts_check

  task clear_leadoff_sts();
    bit [7:0] wr_data;
    bit [7:0] wr_data1;

    if(`LEADOFF_TOP_0.lead_off_result === 1) begin
      `nnc_info("SOC_TEST", "will clear the lead off INT for DAC0", NNC_LOW)
      if(`DUT_IF.clear_intr_manual_or_auto == 0)begin
      `nnc_info("SOC_TEST", "DAC0 clear: manual mode so w1c", NNC_LOW)
        wr_data = {1'b0, `DUT_IF.lead_off_ch1_comp_low_active, `DUT_IF.lead_off_ch1_int_en, `DUT_IF.lead_off_ch0_int_en, `DUT_IF.lead_off_stop_en_ch1, `DUT_IF.lead_off_ch0_comp_low_active, top_test_cfg.lead_off_sts[0], `DUT_IF.lead_off_stop_en_ch0};
        `WR_NORMAL_REG(`SOC_LEAD_OFF_INT_REG, wr_data, top_test_cfg.pads);
      end
      else begin
        `nnc_info("SOC_TEST", "DAC0 clear : auto mode so r1c", NNC_LOW)
        if(use_old_intr_reg_or_general_reg_to_clr == 0 )begin
          `nnc_info("SOC_TEST", "DAC0 clear: r1c by old intr reg", NNC_LOW)
          `RD_NORMAL_REG(`SOC_LEAD_OFF_INT_REG,top_test_cfg.pads, top_test_cfg.rd_data);
          top_test_cfg.lead_off_sts[0] = top_test_cfg.rd_data[1];
        end
        else begin
          `nnc_info("SOC_TEST", "DAC0 clear: r1c by new general intr reg", NNC_LOW)
          `RD_NORMAL_REG(`SOC_GENERAL_INT_STS_1_REG,top_test_cfg.pads, top_test_cfg.rd_data); // ch0  and ch1 sts
          top_test_cfg.lead_off_sts[0] = top_test_cfg.rd_data[3];
        end
      end
    end

    if(`LEADOFF_TOP_1.lead_off_result === 1) begin
      `nnc_info("SOC_TEST", "will clear the lead off INT for DAC1", NNC_LOW)
      if(`DUT_IF.clear_intr_manual_or_auto == 0)begin
      `nnc_info("SOC_TEST", "DAC1 clear: manual mode so w1c", NNC_LOW)
        wr_data1 ={top_test_cfg.lead_off_sts[1], 1'b0, `DUT_IF.lead_off_dac_sel, 3'b0, `DUT_IF.short_detect_by_lead_off_en};
        `WR_NORMAL_REG(`SOC_LEAD_OFF_CTRL_REG, wr_data1, top_test_cfg.pads);
      end
      else begin
        `nnc_info("SOC_TEST", "DAC1 clear: auto mode so r1c", NNC_LOW)
        if(use_old_intr_reg_or_general_reg_to_clr == 0 )begin
          `nnc_info("SOC_TEST", "DAC1 clear: r1c by old intr reg", NNC_LOW)
          `RD_NORMAL_REG(`SOC_LEAD_OFF_CTRL_REG,top_test_cfg.pads, top_test_cfg.rd_data);
          top_test_cfg.lead_off_sts[1] = top_test_cfg.rd_data[7];
        end
        else begin
          `nnc_info("SOC_TEST", "DAC1 clear: r1c by new general intr reg", NNC_LOW)
          `RD_NORMAL_REG(`SOC_GENERAL_INT_STS_1_REG,top_test_cfg.pads, top_test_cfg.rd_data); // ch0  and ch1 sts
          top_test_cfg.lead_off_sts[1] = top_test_cfg.rd_data[4];
        end
      end
    end
  endtask : clear_leadoff_sts

  task leadoff_config();
    // --------------------------------------------------------
    // Write to SOC_LEAD_OFF_CTRL_REG
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_LEAD_OFF_CTRL_REG; wr_data[0] == {2'b0, `DUT_IF.lead_off_dac_sel, 3'b0, `DUT_IF.short_detect_by_lead_off_en};});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // --------------------------------------------------------
    // Write burst starting from SOC_LEAD_OFF_CH0_TIMER_CNT_TGT_0_REG for channel 0 
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_LEAD_OFF_CH0_TIMER_CNT_TGT_0_REG; no_of_bytes == 4;  wr_data[0] == `DUT_IF.lead_off_timer_cnt_dac0[31:24]; wr_data[1] == `DUT_IF.lead_off_timer_cnt_dac0[23:16]; wr_data[2] == `DUT_IF.lead_off_timer_cnt_dac0[15:8]; wr_data[3] == `DUT_IF.lead_off_timer_cnt_dac0[7:0];});
    `nnc_info("SOC_TEST", "Set lead off ch0 timer target register ", NNC_LOW)
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    `nnc_info("SOC_TEST", $sformatf("Setup CH0 Timer Threhold: %d", `DUT_IF.lead_off_timer_cnt_dac0), NNC_LOW)

    // --------------------------------------------------------
    // Write burst starting from SOC_LEAD_OFF_CH1_TIMER_CNT_TGT_0_REG for channel 1 
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_LEAD_OFF_CH1_TIMER_CNT_TGT_0_REG; no_of_bytes == 4;  wr_data[0] == `DUT_IF.lead_off_timer_cnt_dac1[31:24]; wr_data[1] == `DUT_IF.lead_off_timer_cnt_dac1[23:16]; wr_data[2] == `DUT_IF.lead_off_timer_cnt_dac1[15:8]; wr_data[3] == `DUT_IF.lead_off_timer_cnt_dac1[7:0];});
    `nnc_info("SOC_TEST", "Set lead off ch1 timer target register", NNC_LOW)
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    `nnc_info("SOC_TEST", $sformatf("Setup CH1 Timer Threhold: %d", `DUT_IF.lead_off_timer_cnt_dac1), NNC_LOW)

    // --------------------------------------------------------
    // Write burst starting from SOC_LEAD_OFF_CH0_COUNTER_TH_TGT_0_REG for channel 0 
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_LEAD_OFF_CH0_COUNTER_TH_TGT_0_REG; no_of_bytes == 4;  wr_data[0] == `DUT_IF.lead_off_counter_th_dac0[31:24]; wr_data[1] == `DUT_IF.lead_off_counter_th_dac0[23:16]; wr_data[2] == `DUT_IF.lead_off_counter_th_dac0[15:8]; wr_data[3] == `DUT_IF.lead_off_counter_th_dac0[7:0];});
    `nnc_info("SOC_TEST", "Set lead off ch0 counter threshold target register ", NNC_LOW)
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    `nnc_info("SOC_TEST", $sformatf("Setup CH1 Counter Threhold: %d", `DUT_IF.lead_off_counter_th_dac0), NNC_LOW)

    // --------------------------------------------------------
    // Write burst starting from SOC_LEAD_OFF_CH1_COUNTER_TH_TGT_0_REG for channel 1 
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_LEAD_OFF_CH1_COUNTER_TH_TGT_0_REG; no_of_bytes == 4;  wr_data[0] == `DUT_IF.lead_off_counter_th_dac1[31:24]; wr_data[1] == `DUT_IF.lead_off_counter_th_dac1[23:16]; wr_data[2] == `DUT_IF.lead_off_counter_th_dac1[15:8]; wr_data[3] == `DUT_IF.lead_off_counter_th_dac1[7:0];});
    `nnc_info("SOC_TEST", "Set lead off ch1 counter threshold target register", NNC_LOW)
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);
    `nnc_info("SOC_TEST", $sformatf("Setup CH1 Counter Threhold: %d", `DUT_IF.lead_off_counter_th_dac1), NNC_LOW)

  endtask : leadoff_config

  task short_config;
  begin
    /*************************************************************************************************************************************************************************************************************/
    /********************************************************************************** Configurations for SHORT DETECTION ***************************************************************************************/
    /*************************************************************************************************************************************************************************************************************/
    if(`DUT_IF.lead_off_detect_by_short_circuit_en === 0)
	   `nnc_info("SOC_TEST", "SHORT DETECTION BLOCK PERFORMS SHORT!", NNC_LOW)
    else
	   `nnc_info("SOC_TEST", "SHORT DETECTION BLOCK PERFORMS LEAD_OFF!", NNC_LOW)
    if(`DUT_IF.anac_stim_CH1_pol === 1)
	   `nnc_info("SOC_TEST", "CH1 selects high level detection!", NNC_LOW)
    else
	   `nnc_info("SOC_TEST", "CH1 selects low level detection!", NNC_LOW)
    if(`DUT_IF.anac_stim_CH2_pol === 1)
	   `nnc_info("SOC_TEST", "CH2 selects high level detection!", NNC_LOW)
    else
	   `nnc_info("SOC_TEST", "CH2 selects low level detection!", NNC_LOW)

    // ------------------------------------------------------------------------------
    // Write to SOC_ANA_INT_STOP_WAVEGEN_REG (to stop wavegen upon short detection)
    // ------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_INT_STOP_WAVEGEN_REG; wr_data[0] == {6'b0, `DUT_IF.stop_wave2, `DUT_IF.stop_wave1};});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    if(`DUT_IF.stop_wave1 === 1)
	   `nnc_info("SOC_TEST", "Stop wavegen1 upon interrupt!", NNC_LOW)
    else
	   `nnc_info("SOC_TEST", "Continue wavegen1 upon interrupt!", NNC_LOW)
    if(`DUT_IF.stop_wave2 === 1)
	   `nnc_info("SOC_TEST", "Stop wavegen2 upon interrupt!", NNC_LOW)
    else
	   `nnc_info("SOC_TEST", "Continue wavegen2 upon interrupt!", NNC_LOW)

    /********************************************************* Calculate the timer_TH to be set for CH1 & CH2 *********************************************/

    `nnc_info("SOC_TEST", $sformatf("Setup CH1 Timer Threhold: %d", `DUT_IF.lead_off_timer_cnt_dac0), NNC_LOW)
    // -------------------------------------------------------------------------------------
    // Write to SOC_ANA_STIM_CH1_TIMER_CNT_TH00_REG (CH1 TIMER THRESHOLD)
    // -------------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_STIM_CH1_TIMER_CNT_TH00_REG; wr_data[0] == `DUT_IF.lead_off_timer_cnt_dac0[7:0];});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // -------------------------------------------------------------------------------------
    // Write to SOC_ANA_STIM_CH1_TIMER_CNT_TH01_REG (CH1 TIMER THRESHOLD)
    // -------------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_STIM_CH1_TIMER_CNT_TH01_REG; wr_data[0] == `DUT_IF.lead_off_timer_cnt_dac0[15:8];});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // -------------------------------------------------------------------------------------
    // Write to SOC_ANA_STIM_CH1_TIMER_CNT_TH02_REG (CH1 TIMER THRESHOLD)
    // -------------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_STIM_CH1_TIMER_CNT_TH02_REG; wr_data[0] == `DUT_IF.lead_off_timer_cnt_dac0[23:16];});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // -------------------------------------------------------------------------------------
    // Write to SOC_ANA_STIM_CH1_TIMER_CNT_TH03_REG (CH1 TIMER THRESHOLD)
    // -------------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_STIM_CH1_TIMER_CNT_TH03_REG; wr_data[0] == `DUT_IF.lead_off_timer_cnt_dac0[31:24];});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    `nnc_info("SOC_TEST", $sformatf("Setup CH2 Timer Threhold: %d", `DUT_IF.lead_off_timer_cnt_dac1), NNC_LOW)
    // -------------------------------------------------------------------------------------
    // Write to SOC_ANA_STIM_CH2_TIMER_CNT_TH00_REG (CH2 TIMER THRESHOLD)
    // -------------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_STIM_CH2_TIMER_CNT_TH00_REG; wr_data[0] == `DUT_IF.lead_off_timer_cnt_dac1[7:0];});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // -------------------------------------------------------------------------------------
    // Write to SOC_ANA_STIM_CH2_TIMER_CNT_TH01_REG (CH2 TIMER THRESHOLD)
    // -------------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_STIM_CH2_TIMER_CNT_TH01_REG; wr_data[0] == `DUT_IF.lead_off_timer_cnt_dac1[15:8];});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // -------------------------------------------------------------------------------------
    // Write to SOC_ANA_STIM_CH2_TIMER_CNT_TH02_REG (CH2 TIMER THRESHOLD)
    // -------------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_STIM_CH2_TIMER_CNT_TH02_REG; wr_data[0] == `DUT_IF.lead_off_timer_cnt_dac1[23:16];});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // -------------------------------------------------------------------------------------
    // Write to SOC_ANA_STIM_CH2_TIMER_CNT_TH03_REG (CH2 TIMER THRESHOLD)
    // -------------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_STIM_CH2_TIMER_CNT_TH03_REG; wr_data[0] == `DUT_IF.lead_off_timer_cnt_dac1[31:24];});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    /********************************************************* Calculate the counter_TH to be set for CH1 & CH2 *********************************************/
    `nnc_info("SOC_TEST", $sformatf("Setup CH1 Counter Threhold: %d", `DUT_IF.anac_short_CH1_counter_TH), NNC_LOW)
    // -------------------------------------------------------------------------------------
    // Write to SOC_ANA_STIM_CH1_COUNTER_CNT_TH00_REG (CH1 COUNTER THRESHOLD)
    // -------------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_STIM_CH1_COUNTER_CNT_TH00_REG; wr_data[0] == `DUT_IF.anac_short_CH1_counter_TH[7:0];});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // -------------------------------------------------------------------------------------
    // Write to SOC_ANA_STIM_CH1_COUNTER_CNT_TH01_REG (CH1 COUNTER THRESHOLD)
    // -------------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_STIM_CH1_COUNTER_CNT_TH01_REG; wr_data[0] == `DUT_IF.anac_short_CH1_counter_TH[15:8];});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // -------------------------------------------------------------------------------------
    // Write to SOC_ANA_STIM_CH1_COUNTER_CNT_TH02_REG (CH1 COUNTER THRESHOLD)
    // -------------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_STIM_CH1_COUNTER_CNT_TH02_REG; wr_data[0] == `DUT_IF.anac_short_CH1_counter_TH[23:16];});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // -------------------------------------------------------------------------------------
    // Write to SOC_ANA_STIM_CH1_COUNTER_CNT_TH03_REG (CH1 COUNTER THRESHOLD)
    // -------------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_STIM_CH1_COUNTER_CNT_TH03_REG; wr_data[0] == `DUT_IF.anac_short_CH1_counter_TH[31:24];});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    `nnc_info("SOC_TEST", $sformatf("Setup CH2 Counter Threhold: %d", `DUT_IF.anac_short_CH2_counter_TH), NNC_LOW)
    // -------------------------------------------------------------------------------------
    // Write to SOC_ANA_STIM_CH2_COUNTER_CNT_TH00_REG (CH2 COUNTER THRESHOLD)
    // -------------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_STIM_CH2_COUNTER_CNT_TH00_REG; wr_data[0] == `DUT_IF.anac_short_CH2_counter_TH[7:0];});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // -------------------------------------------------------------------------------------
    // Write to SOC_ANA_STIM_CH2_COUNTER_CNT_TH01_REG (CH2 COUNTER THRESHOLD)
    // -------------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_STIM_CH2_COUNTER_CNT_TH01_REG; wr_data[0] == `DUT_IF.anac_short_CH2_counter_TH[15:8];});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // -------------------------------------------------------------------------------------
    // Write to SOC_ANA_STIM_CH2_COUNTER_CNT_TH02_REG (CH2 COUNTER THRESHOLD)
    // -------------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_STIM_CH2_COUNTER_CNT_TH02_REG; wr_data[0] == `DUT_IF.anac_short_CH2_counter_TH[23:16];});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // -------------------------------------------------------------------------------------
    // Write to SOC_ANA_STIM_CH2_COUNTER_CNT_TH03_REG (CH2 COUNTER THRESHOLD)
    // -------------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_STIM_CH2_COUNTER_CNT_TH03_REG; wr_data[0] == `DUT_IF.anac_short_CH2_counter_TH[31:24];});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
  end
  endtask

  task wavegen_setup(input int chip_num);
  begin
    //top_test_cfg.LOAD_POINTS = top_test_cfg.load_points_sel;
    //top_test_cfg.NO_OF_WAVEFORMS = top_test_cfg.waveform_sel;
    //top_test_cfg.PRELOAD = top_test_cfg.preload_sel;
    //top_test_cfg.NEG_ON = top_test_cfg.neg_ena;
    //top_test_cfg.POS_OFF = top_test_cfg.pos_dis;
    //top_test_cfg.POS_NEG_DIFF = top_test_cfg.pos_neg_diff_sel;
    
    case(`DUT_IF.points_sel)
         3'b000:begin
		    `DUT_IF.point_cfg_val = 64;
		    if(`DUT_IF.load_wave_data_till_points === 0)
		    	$readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y64", top_test_cfg.sine_data);
		    else
			$readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y128", top_test_cfg.sine_data);
		end
         3'b001:begin
		    `DUT_IF.point_cfg_val = 32;
		    if(`DUT_IF.load_wave_data_till_points === 0)
		    	$readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y32", top_test_cfg.sine_data);
		    else
			$readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y128", top_test_cfg.sine_data);
		end
         3'b010:begin
		    `DUT_IF.point_cfg_val = 16;
		    if(`DUT_IF.load_wave_data_till_points === 0)
		    	$readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y16", top_test_cfg.sine_data);
		    else
			$readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y128", top_test_cfg.sine_data);
		end
         3'b011:begin
		    `DUT_IF.point_cfg_val = 8;
		    if(`DUT_IF.load_wave_data_till_points === 0)
		    	$readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y8", top_test_cfg.sine_data);
		    else
			$readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y128", top_test_cfg.sine_data);
		end
         3'b100:begin
		    `DUT_IF.point_cfg_val = 4;
		    if(`DUT_IF.load_wave_data_till_points === 0)
		    	$readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y4", top_test_cfg.sine_data);
		    else
			$readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y128", top_test_cfg.sine_data);
		end
         3'b101:begin
		    `DUT_IF.point_cfg_val = 2;
		    if(`DUT_IF.load_wave_data_till_points === 0)
		    	$readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y2", top_test_cfg.sine_data);
		    else
			$readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y128", top_test_cfg.sine_data);
		end
         3'b110:begin
		    `DUT_IF.point_cfg_val = 1;
		    $readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y128", top_test_cfg.sine_data);
		end
         3'b111:begin
		    `DUT_IF.point_cfg_val = 128;
		    $readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y128", top_test_cfg.sine_data);
		end
    endcase
    
    if(`DUT_IF.load_wave_data_till_points === 0)
	top_test_cfg.NO_OF_LOAD_POINTS = `DUT_IF.point_cfg_val;
    else begin
      if(`DUT_IF.no_of_waveforms === 0)
	top_test_cfg.NO_OF_LOAD_POINTS = 128;
      else begin
      	if(`DUT_IF.pos_neg_from_same_addr === 1)
	   top_test_cfg.NO_OF_LOAD_POINTS = `DUT_IF.point_cfg_val * (`DUT_IF.no_of_waveforms+1);
      	else begin
	   if((`DUT_IF.neg_ena === 1) && (`DUT_IF.pos_ena === 0))
	   	top_test_cfg.NO_OF_LOAD_POINTS = `DUT_IF.point_cfg_val * (`DUT_IF.no_of_waveforms+1) * 2;
	   else
		top_test_cfg.NO_OF_LOAD_POINTS = `DUT_IF.point_cfg_val * (`DUT_IF.no_of_waveforms+1);
	end
      end
    end

    // Interface
    top_env.wavegen_vif[chip_num].no_of_point_a = top_test_cfg.NO_OF_LOAD_POINTS; // expected resolution
    top_env.wavegen_vif[chip_num].no_of_point_b = top_test_cfg.NO_OF_LOAD_POINTS; // expected resolution
    for (int i=0; i < top_env.wavegen_vif[chip_num].no_of_point_a; i++) begin
      if(pulse_user_config_case === 1)begin
        top_env.wavegen_vif[chip_num].hex_data_a[i] = 'hFF; // expected hex values
        top_env.wavegen_vif[chip_num].hex_data_b[i] = 'hFF; // expected hex values
      end
      else begin
        top_env.wavegen_vif[chip_num].hex_data_a[i] = top_test_cfg.sine_data[i]; // expected hex values
        top_env.wavegen_vif[chip_num].hex_data_b[i] = top_test_cfg.sine_data[i]; // expected hex values
      end
    end
    top_env.wavegen_vif[chip_num].pos_neg_from_same_addr = `DUT_IF.pos_neg_from_same_addr; 
    top_env.wavegen_vif[chip_num].load_wave_data_till_points = `DUT_IF.load_wave_data_till_points; 
    top_env.wavegen_vif[chip_num].no_of_waveforms = `DUT_IF.no_of_waveforms; 
    top_env.wavegen_vif[chip_num].preload_sel = `DUT_IF.preload_sel;
    for (int i=0; i < `WAVEGEN_NUM_OF_DRIVERS; i++) begin
      top_env.wavegen_vif[chip_num].PULLAB_pos_en[i] = `DUT_IF.PULLAB_pos_en[i];
      top_env.wavegen_vif[chip_num].PULLAB_neg_en[i] = `DUT_IF.PULLAB_neg_en[i];
      top_env.wavegen_vif[chip_num].PULLAB_lim[i] = `DUT_IF.PULLAB_lim[i];
    end

    `nnc_info("SOC_TEST", $sformatf("NO_OF_POINTS: %d, NO_OF_LOAD_POINTS: %d, LOAD_POINTS:%d", `DUT_IF.point_cfg_val, top_test_cfg.NO_OF_LOAD_POINTS, `DUT_IF.load_wave_data_till_points), NNC_LOW)

    top_test_cfg.clk_freq = 8192 / (2**`DUT_IF.pclk_sel);
    top_test_cfg.half_period_limit = (`DUT_IF.point_cfg_val * 1000) / top_test_cfg.clk_freq;

    for(int i = 0; i < `WAVEGEN_NUM_OF_DRIVERS; i++) begin
      assert(top_test_cfg.randomize() with {half_period0[0] inside {[top_test_cfg.half_period_limit+1:top_test_cfg.half_period_limit+1000]};
                                            half_period1[0] inside {[top_test_cfg.half_period_limit+1:top_test_cfg.half_period_limit+1000]};
                                            half_period2[0] inside {[top_test_cfg.half_period_limit+1:top_test_cfg.half_period_limit+1000]};
                                            half_period0[1] inside {[top_test_cfg.half_period_limit+1:top_test_cfg.half_period_limit+1000]};
                                            half_period1[1] inside {[top_test_cfg.half_period_limit+1:top_test_cfg.half_period_limit+1000]};
                                            half_period2[1] inside {[top_test_cfg.half_period_limit+1:top_test_cfg.half_period_limit+1000]};
                                            (same_pos_neg_period == 1) -> half_period0[0] == half_period0[1];
                                            (same_pos_neg_period == 1) -> half_period1[0] == half_period1[1];
                                            (same_pos_neg_period == 1) -> half_period2[0] == half_period2[1];});
      //wavegen_calc_clock_num(clk_freq (KHz), rest_t (us), silent_t (us), hlf_wave_per (us), neg_hlf_wave_per (us))
      wavegen_calc_clock_num(top_test_cfg.clk_freq, 100, 1000, top_test_cfg.half_period0[0], top_test_cfg.half_period0[1]);
      top_test_cfg.hlf_wave0_lim[i] = top_test_cfg.hlf_wave_lim / `DUT_IF.point_cfg_val;
      top_test_cfg.neg_hlf_wave0_lim[i] = top_test_cfg.neg_hlf_wave_lim / `DUT_IF.point_cfg_val;
      top_test_cfg.rest_wave0_lim[i] = top_test_cfg.rest_lim;
      top_test_cfg.silent_wave0_lim[i] = top_test_cfg.silent_lim;
      `nnc_info("SOC_TEST", $sformatf("******** WAVE 0 ******** CLK_FREQ: %dKhz, HALF_PERIOD_LIMIT: %dus, POS_HALF_PERIOD_TARGET: %dus, NEG_HALF_PERIOD_TARGET: %dus, POS_HALF_PERIOD_CLKS_PER_POINT: %d, NEG_HALF_PERIOD_CLKS_PER_POINT: %d", top_test_cfg.clk_freq, top_test_cfg.half_period_limit, top_test_cfg.half_period0[0], top_test_cfg.half_period0[1], top_test_cfg.hlf_wave0_lim[i], top_test_cfg.neg_hlf_wave0_lim[i]), NNC_LOW)

      //wavegen_calc_clock_num(clk_freq (KHz), rest_t (us), silent_t (us), hlf_wave_per (us), neg_hlf_wave_per (us))
      wavegen_calc_clock_num(top_test_cfg.clk_freq, 150, 2000, top_test_cfg.half_period1[0], top_test_cfg.half_period1[1]);
      top_test_cfg.hlf_wave1_lim[i] = top_test_cfg.hlf_wave_lim / `DUT_IF.point_cfg_val;
      top_test_cfg.neg_hlf_wave1_lim[i] = top_test_cfg.neg_hlf_wave_lim / `DUT_IF.point_cfg_val;
      top_test_cfg.rest_wave1_lim[i] = top_test_cfg.rest_lim;
      top_test_cfg.silent_wave1_lim[i] = top_test_cfg.silent_lim;
      `nnc_info("SOC_TEST", $sformatf("******** WAVE 1 ******** CLK_FREQ: %dKhz, HALF_PERIOD_LIMIT: %dus, POS_HALF_PERIOD_TARGET: %dus, NEG_HALF_PERIOD_TARGET: %dus, POS_HALF_PERIOD_CLKS_PER_POINT: %d, NEG_HALF_PERIOD_CLKS_PER_POINT: %d", top_test_cfg.clk_freq, top_test_cfg.half_period_limit, top_test_cfg.half_period1[0], top_test_cfg.half_period1[1], top_test_cfg.hlf_wave1_lim[i], top_test_cfg.neg_hlf_wave1_lim[i]), NNC_LOW)

      //wavegen_calc_clock_num(clk_freq (KHz), rest_t (us), silent_t (us), hlf_wave_per (us), neg_hlf_wave_per (us))
      wavegen_calc_clock_num(top_test_cfg.clk_freq, 250, 4000, top_test_cfg.half_period2[0], top_test_cfg.half_period2[1]);
      top_test_cfg.hlf_wave2_lim[i] = top_test_cfg.hlf_wave_lim / `DUT_IF.point_cfg_val;
      top_test_cfg.neg_hlf_wave2_lim[i] = top_test_cfg.neg_hlf_wave_lim / `DUT_IF.point_cfg_val;
      top_test_cfg.rest_wave2_lim[i] = top_test_cfg.rest_lim;
      top_test_cfg.silent_wave2_lim[i] = top_test_cfg.silent_lim;
      `nnc_info("SOC_TEST", $sformatf("******** WAVE 2 ******** CLK_FREQ: %dKhz, HALF_PERIOD_LIMIT: %dus, POS_HALF_PERIOD_TARGET: %dus, NEG_HALF_PERIOD_TARGET: %dus, POS_HALF_PERIOD_CLKS_PER_POINT: %d, NEG_HALF_PERIOD_CLKS_PER_POINT: %d", top_test_cfg.clk_freq, top_test_cfg.half_period_limit, top_test_cfg.half_period2[0], top_test_cfg.half_period2[1], top_test_cfg.hlf_wave2_lim[i], top_test_cfg.neg_hlf_wave2_lim[i]), NNC_LOW)
    end
  end
  endtask

  task wavegen_calc_clock_num;
  input [13:0] clk_freq;
  input [7:0]  rest_t;
  input [31:0] silent_t;
  input [31:0] hlf_wave_per;
  input [31:0] neg_hlf_wave_per;
  begin
    top_test_cfg.hlf_wave_lim = (hlf_wave_per * {20'b0,clk_freq}) / 1000;
    top_test_cfg.neg_hlf_wave_lim = (neg_hlf_wave_per * {20'b0,clk_freq}) / 1000;
    top_test_cfg.rest_lim = ({8'b0,rest_t} * {4'b0,clk_freq}) / 1000;
    top_test_cfg.silent_lim = (silent_t * {20'b0,clk_freq}) / 1000;
  end
  endtask

  task wavegen_drv_config;
  input [7:0] WG_BASE;
  begin
    if(WG_BASE === `WAVEGEN_0_ADDR_BASE)
	`DUT_IF.wg_drv_sel = 0;
    else if(WG_BASE === `WAVEGEN_1_ADDR_BASE)
	`DUT_IF.wg_drv_sel = 1;

    // --------------------------------------------------------
    // Write burst starting from SOC_ADDR_WG_DRV_CTRL1_REG
    // --------------------------------------------------------
    `nnc_info("SOC_TEST", "Set drive reg ctrl1-2", NNC_LOW)
    if(WG_BASE === `WAVEGEN_0_ADDR_BASE) begin
      // --------------------------------------------------------
      // Write to SOC_ADDR_WG_DRV_CTRL0_REG
      // --------------------------------------------------------
      assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CTRL0_REG + WG_BASE); wr_data[0] == {2'b0, `DUT_IF.dac_bit_len_sel_drv0,top_test_cfg.auto_man, 4'b0};});
      `nnc_info("SOC_TEST", "Set drive reg ctrl0", NNC_LOW)
      `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

      assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CTRL1_REG + WG_BASE); no_of_bytes == 2; wr_data[0] == {1'b0, top_test_cfg.dac0_msb_sel, top_test_cfg.dac0_data_h}; wr_data[1] == top_test_cfg.dac0_data_l;});
      `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);
    end
    else if(WG_BASE === `WAVEGEN_1_ADDR_BASE) begin
      // --------------------------------------------------------
      // Write to SOC_ADDR_WG_DRV_CTRL0_REG
      // --------------------------------------------------------
      assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CTRL0_REG + WG_BASE); wr_data[0] == {2'b0, `DUT_IF.dac_bit_len_sel_drv1,top_test_cfg.auto_man, 4'b0};});
      `nnc_info("SOC_TEST", "Set drive reg ctrl0", NNC_LOW)
      `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

      assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CTRL1_REG + WG_BASE); no_of_bytes == 2; wr_data[0] == {1'b0, top_test_cfg.dac1_msb_sel, top_test_cfg.dac1_data_h}; wr_data[1] == top_test_cfg.dac1_data_l;});
      `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);
    end

    // --------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_REST_T_REG01
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_REST_T_REG01 + WG_BASE); no_of_bytes == 2;  wr_data[0] == top_test_cfg.rest_wave0_lim[`DUT_IF.wg_drv_sel][15:8]; wr_data[1] == top_test_cfg.rest_wave0_lim[`DUT_IF.wg_drv_sel][7:0];});
    `nnc_info("SOC_TEST", "Set wave0 rest period", NNC_LOW)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_SILENT_T_REG01
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_SILENT_T_REG01 + WG_BASE); no_of_bytes == 3; wr_data[0] == top_test_cfg.silent_wave0_lim[`DUT_IF.wg_drv_sel][23:16]; wr_data[1] == top_test_cfg.silent_wave0_lim[`DUT_IF.wg_drv_sel][15:8]; wr_data[2] == top_test_cfg.silent_wave0_lim[`DUT_IF.wg_drv_sel][7:0];});
    `nnc_info("SOC_TEST", "Set wave0 silent period", NNC_LOW)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_REST_CLK1_REG01
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_REST_CLK1_REG01 + WG_BASE); no_of_bytes == 2;  wr_data[0] == top_test_cfg.rest_wave1_lim[`DUT_IF.wg_drv_sel][15:8]; wr_data[1] == top_test_cfg.rest_wave1_lim[`DUT_IF.wg_drv_sel][7:0];});
    `nnc_info("SOC_TEST", "Set wave1 rest period", NNC_LOW)//0x0000_0064 (100us)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_SILENT_CLK1_REG01
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_SILENT_CLK1_REG01 + WG_BASE); no_of_bytes == 3; wr_data[0] == top_test_cfg.silent_wave1_lim[`DUT_IF.wg_drv_sel][23:16]; wr_data[1] == top_test_cfg.silent_wave1_lim[`DUT_IF.wg_drv_sel][15:8]; wr_data[2] == top_test_cfg.silent_wave1_lim[`DUT_IF.wg_drv_sel][7:0];});
    `nnc_info("SOC_TEST", "Set wave1 silent period", NNC_LOW)//0x0000_03E8 (1000us)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_REST_CLK2_REG01
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_REST_CLK2_REG01 + WG_BASE); no_of_bytes == 2;  wr_data[0] == top_test_cfg.rest_wave2_lim[`DUT_IF.wg_drv_sel][15:8]; wr_data[1] == top_test_cfg.rest_wave2_lim[`DUT_IF.wg_drv_sel][7:0];});
    `nnc_info("SOC_TEST", "Set wave2 rest period", NNC_LOW)//0x0000_0064 (100us)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_SILENT_CLK2_REG01
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_SILENT_CLK2_REG01 + WG_BASE); no_of_bytes == 3; wr_data[0] == top_test_cfg.silent_wave2_lim[`DUT_IF.wg_drv_sel][23:16]; wr_data[1] == top_test_cfg.silent_wave2_lim[`DUT_IF.wg_drv_sel][15:8]; wr_data[2] == top_test_cfg.silent_wave2_lim[`DUT_IF.wg_drv_sel][7:0];});
    `nnc_info("SOC_TEST", "Set wave2 silent period", NNC_LOW)//0x0000_03E8 (1000us)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_HLF_WAVE_PRD_REG01
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_HLF_WAVE_PRD_REG01 + WG_BASE); no_of_bytes == 2; wr_data[0] == top_test_cfg.hlf_wave0_lim[`DUT_IF.wg_drv_sel][15:8]; wr_data[1] == top_test_cfg.hlf_wave0_lim[`DUT_IF.wg_drv_sel][7:0];});
    `nnc_info("SOC_TEST", "Set positive half wave0 period", NNC_LOW)//0x0000_01F4 (500us)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_NEG_HLF_WAVE_PRD_REG01
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_NEG_HLF_WAVE_PRD_REG01 + WG_BASE); no_of_bytes == 2; wr_data[0] == top_test_cfg.neg_hlf_wave0_lim[`DUT_IF.wg_drv_sel][15:8]; wr_data[1] == top_test_cfg.neg_hlf_wave0_lim[`DUT_IF.wg_drv_sel][7:0];});
    `nnc_info("SOC_TEST", "Set negative half wave0 period", NNC_LOW)//0x0000_01F4 (500us)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // -------------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_HLF_WAVE_CLK_PNT1_REG01
    // -------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_HLF_WAVE_CLK_PNT1_REG01 + WG_BASE); no_of_bytes == 2; wr_data[0] == top_test_cfg.hlf_wave1_lim[`DUT_IF.wg_drv_sel][15:8]; wr_data[1] == top_test_cfg.hlf_wave1_lim[`DUT_IF.wg_drv_sel][7:0];});
    `nnc_info("SOC_TEST", "Set positive half wave1 period", NNC_LOW)//0x0000_01F4 (500us)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // -----------------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT1_REG01
    // -----------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT1_REG01 + WG_BASE); no_of_bytes == 2; wr_data[0] == top_test_cfg.neg_hlf_wave1_lim[`DUT_IF.wg_drv_sel][15:8]; wr_data[1] == top_test_cfg.neg_hlf_wave1_lim[`DUT_IF.wg_drv_sel][7:0];});
    `nnc_info("SOC_TEST", "Set negative half wave1 period", NNC_LOW)//0x0000_01F4 (500us)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // -------------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_HLF_WAVE_CLK_PNT2_REG01
    // -------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_HLF_WAVE_CLK_PNT2_REG01 + WG_BASE); no_of_bytes == 2; wr_data[0] == top_test_cfg.hlf_wave2_lim[`DUT_IF.wg_drv_sel][15:8]; wr_data[1] == top_test_cfg.hlf_wave2_lim[`DUT_IF.wg_drv_sel][7:0];});
    `nnc_info("SOC_TEST", "Set positive half wave2 period", NNC_LOW)//0x0000_01F4 (500us)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // -----------------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT2_REG01
    // -----------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT2_REG01 + WG_BASE); no_of_bytes == 2; wr_data[0] == top_test_cfg.neg_hlf_wave2_lim[`DUT_IF.wg_drv_sel][15:8]; wr_data[1] == top_test_cfg.neg_hlf_wave2_lim[`DUT_IF.wg_drv_sel][7:0];});
    `nnc_info("SOC_TEST", "Set negative half wave2 period", NNC_LOW)//0x0000_01F4 (500us)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write to ADDR_WG_DRV_CONFIG_REG0(//bit 0:rest enable, 1:negative enable, 2: silent enable, 3: source B enable, 4: alternate, 5: continue mode, 6: multi-electrode, 7: positive disable)
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CONFIG_REG0 + WG_BASE); wr_data[0] == {`DUT_IF.pos_ena, 1'b1, 1'b0, 1'b0, 1'b1, `DUT_IF.silent_en, `DUT_IF.neg_ena, `DUT_IF.rest_en};});
    `nnc_info("SOC_TEST", "Set driver configuration register", NNC_LOW)
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    
    `nnc_info("SOC_TEST", $sformatf("Configure %d points", `DUT_IF.point_cfg_val), NNC_LOW)
    // --------------------------------------------------------
    // Write to ADDR_WG_DRV_POINT_CONFIG
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_POINT_CONFIG + WG_BASE); wr_data[0] == `DUT_IF.point_cfg_val;});
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    `nnc_info("SOC_TEST", $sformatf("Store %d wave points", top_test_cfg.NO_OF_LOAD_POINTS), NNC_LOW)

    if(pulse_user_config_case === 1)begin
      for(int i=0; i<top_test_cfg.NO_OF_LOAD_POINTS; i++) begin
        // --------------------------------------------------------
        // Write to ADDR_WG_DRV_IN_WAVE_ADDR_REG0
        // --------------------------------------------------------
        assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0 + WG_BASE); wr_data[0] == i;});
        `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
        // --------------------------------------------------------
        // Write to ADDR_WG_DRV_IN_WAVE_REG01
        // --------------------------------------------------------
        assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_IN_WAVE_REG01 + WG_BASE); wr_data[0] == 8'hFF;});
        `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
      end
    end else begin
      for(int i=0; i<top_test_cfg.NO_OF_LOAD_POINTS; i++) begin
        // --------------------------------------------------------
        // Write to ADDR_WG_DRV_IN_WAVE_ADDR_REG0
        // --------------------------------------------------------
        assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0 + WG_BASE); wr_data[0] == i;});
        `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
        // --------------------------------------------------------
        // Write to ADDR_WG_DRV_IN_WAVE_REG01
        // --------------------------------------------------------
        assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_IN_WAVE_REG01 + WG_BASE); wr_data[0] == top_test_cfg.sine_data[i][7:0];});
        `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
      end
    end

    // --------------------------------------------------------
    // Write to ADDR_WG_DRV_PULLBA_REG
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_PULLBA_REG + WG_BASE); wr_data[0] == {`DUT_IF.PULLAB_pos_en[0], `DUT_IF.PULLAB_neg_en[0], `DUT_IF.PULLAB_lim[0]};});//currently they are same for both drivers
    `nnc_info("SOC_TEST", "Set pullab reg", NNC_LOW)
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // --------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_DELAY_LIM_REG01
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_DELAY_LIM_REG01 + WG_BASE); no_of_bytes == 2;  wr_data[0] == `DUT_IF.DELAY_lim[0][15:8]; wr_data[1] == `DUT_IF.DELAY_lim[0][7:0];});//currently they are same for both drivers
    `nnc_info("SOC_TEST", "Adjust delay using Delay_lim register", NNC_LOW)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write to ADDR_WG_DRV_CTRL_REG0
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CTRL_REG0 + WG_BASE); wr_data[0] == {`DUT_IF.pos_neg_from_same_addr,`DUT_IF.load_wave_data_till_points,`DUT_IF.no_of_waveforms,`DUT_IF.preload_sel,1'b0};});
    if(`DUT_IF.preload_sel === 2'b00)
    	`nnc_info("SOC_TEST", "Config driver control register with preloaded sine values", NNC_LOW)
    else if(`DUT_IF.preload_sel === 2'b01)
    	`nnc_info("SOC_TEST", "Enable driver using control register with preloaded pulse values", NNC_LOW)
    else if(`DUT_IF.preload_sel === 2'b10)
    	`nnc_info("SOC_TEST", "Config driver control register with preloaded triangle values", NNC_LOW)
    else if(`DUT_IF.preload_sel === 2'b11)
    	`nnc_info("SOC_TEST", "Config driver control register with user config values", NNC_LOW)
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

  end
  endtask

  task wavegen_drv_enable;
  begin
    `nnc_info("SOC_TEST", $sformatf("enabling chip_0 wavegen sb now"), NNC_LOW)
    `WAVEGEN_SCB_DRV_0_EN = 1'b1;
    `WAVEGEN_SCB_DRV_1_EN = 1'b1;
    // --------------------------------------------------------
    // Write to SOC_WAVEGEN_GLOBAL_REG to sync drivers
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_WAVEGEN_GLOBAL_REG; wr_data[0] == 8'h01;});
    `nnc_info("SOC_TEST", "Enable drivers using global register", NNC_LOW)
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
  end
  endtask

endclass : `TESTNAME

