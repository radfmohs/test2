/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_app_demo_scenario_sinewave_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_app_demo_scenario_sinewave_test                                             
// Designer	: ophina@nanochap.com                                                                 
// Date		: 26-06-2025                                                                     
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

//************************************************************************************
// NOTE : This test checks the leadoff and after that short for sinewave 
//************************************************************************************

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_app_demo_scenario_sinewave_test
`define TESTCFG soc_app_demo_scenario_sinewave_test_cfg

class `TESTCFG extends soc_app_demo_scenario_base_test_cfg;

  `nnc_object_utils(`TESTCFG)

  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_app_demo_scenario_base_test_cfg");
    super.new(name);
    
  endfunction: new

  // ===============================================
  // Adding constraints of randomization
  // -----------------------------------------------

  //preload_sel
  constraint c_preload_sel     { preload_sel inside {0,3};} // 0: sine preloaded, 3: user config sine

  //waveform_sel
  constraint c_waveform_sel    { waveform_sel == 0;} // waveform_sel should be 0 to get continous sine

  //points_sel
  constraint c_points_sel      { points_sel == 0;}//select 64 points per half wave

  //dac_bit_len_sel
  constraint c_dac_bit_len_sel_0 { dac_bit_len_sel_drv0 == 1'b0;}
  constraint c_dac_bit_len_sel_1 { dac_bit_len_sel_drv1 == 1'b0;}

  //constraint c_lead_off_rest_en { rest_en == 1; }
  //constraint c_lead_off_silent_en { silent_en == 1; }

  // -----------------------------------------------
  // End of adding constraints of randomization
  // ===============================================

endclass : `TESTCFG

// ===============================================
// Main Testcase is defined
// -----------------------------------------------
class `TESTNAME extends soc_app_demo_scenario_base_test;
   
  `nnc_component_utils(`TESTNAME)

  `TESTCFG top_test_cfg;

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

    sine_trian_arbi_wave_test = 1;

    phase.drop_objection(this);
  endtask : pre_reset_phase

  // -----------------------------------------
  // Declare the main_phase task of your test
  // -----------------------------------------
  virtual task main_phase(nnc_phase phase);
    phase.raise_objection(this);

    `nnc_info("SOC_TEST", "soc_app_demo_scenario_sinewave_test start", NNC_LOW)
    super.main_phase(phase);
    `nnc_info("SOC_TEST", "soc_app_demo_scenario_sinewave_test end now", NNC_LOW)

    // ----------------------------------------------------------------------------------
    // End of test 
    // ==================================================================================

    phase.drop_objection(this);
  endtask: main_phase

endclass : `TESTNAME

