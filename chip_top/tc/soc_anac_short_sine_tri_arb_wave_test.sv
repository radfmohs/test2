/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_anac_short_sine_tri_arb_wave_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_anac_short_sine_tri_arb_wave_test                                             
// Designer	: ophina@nanochap.com                                                                 
// Date		: 18-03-2024                                                                   
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

//*******************************************************************************************
// NOTE : This test is used to check short detection using sine/triangle/arbitrary waveforms.
//        This test considers 10 waveform cycles as the period of short checking window.
//        This test constraints the counter threshold value based on the following formula, 
//        counter_TH = 5 * PW, where PW is the pulse width of either positive half or 
//        negative half depending on D2A_STIMU_COMP_SEL_CH1/CH2 selection.
//*******************************************************************************************

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_anac_short_sine_tri_arb_wave_test
`define TESTCFG soc_anac_short_sine_tri_arb_wave_test_cfg

class `TESTCFG extends soc_base_test_cfg;

  `nnc_object_utils(`TESTCFG)

  // ===============================================
  // Adding your new varialbles in config test
  // -----------------------------------------------

  rand logic [7:0] wr_data[256];
  rand int         no_of_bytes; 
  rand logic [7:0] reg_addr;
  rand logic [7:0] pads;
  rand logic [7:0] mask;
  rand logic [7:0] expected_data;
  logic [7:0]      rd_data[];
  logic [7:0]      sine_data[128];
  logic [13:0]     clk_freq;//in Khz
  logic [12:0]     half_period_limit;
  randc logic      same_pos_neg_period;
  rand logic [13:0] half_period0[2];
  rand logic [13:0] half_period1[2];
  rand logic [13:0] half_period2[2];
  logic [31:0]     hlf_wave_lim; // number of clocks for positive half wave
  logic [31:0]     neg_hlf_wave_lim; // number of clocks for negative half wave
  logic [31:0]     hlf_wave0_lim[2]; // number of clocks per point for positive half wave0
  logic [31:0]     neg_hlf_wave0_lim[2]; // number of clocks per point for negative half wave0
  logic [31:0]     hlf_wave1_lim[2]; // number of clocks per point for positive half wave1
  logic [31:0]     neg_hlf_wave1_lim[2]; // number of clocks per point for negative half wave1
  logic [31:0]     hlf_wave2_lim[2]; // number of clocks per point for positive half wave2
  logic [31:0]     neg_hlf_wave2_lim[2]; // number of clocks per point for negative half wave2
  logic [15:0]     rest_lim; // number of clocks for each rest period
  logic [31:0]     silent_lim; // number of clocks for each silent period
  logic [15:0]     rest_wave0_lim[2]; // number of clocks for each rest period wave0
  logic [31:0]     silent_wave0_lim[2]; // number of clocks for each silent period wave0
  logic [15:0]     rest_wave1_lim[2]; // number of clocks for each rest period wave1
  logic [31:0]     silent_wave1_lim[2]; // number of clocks for each silent period wave1
  logic [15:0]     rest_wave2_lim[2]; // number of clocks for each rest period wave2
  logic [31:0]     silent_wave2_lim[2]; // number of clocks for each silent period wave2
  rand logic [1:0] preload_sel;
  rand logic       neg_ena;
  rand logic       pos_dis;
  rand logic       rest_en;
  rand logic       silent_en;
  rand logic [2:0] points_sel;
  rand logic [2:0] waveform_sel;
  rand logic       load_points_sel;
  rand logic       pos_neg_diff_sel;
  rand logic       dac_bit_len_sel;//1'b0:8-bits; 1'b1:12-bits (only 8 bits supported for sine)
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
  rand logic [15:0] DELAY_lim;
       logic [31:0] short_CH1_timer_th;
       logic [31:0] short_CH2_timer_th;
       logic [31:0] short_CH1_counter_th;
       logic [31:0] short_CH2_counter_th;
  rand logic       stim_level_val_CH1;//1'b1: high value comparison; 1'b0: low value comparison
  rand logic       stim_level_val_CH2;//1'b1: high value comparison; 1'b0: low value comparison
  rand logic       stim_CH1_en;//short detect enable
  rand logic       stim_CH2_en;//short detect enable
  rand logic       stim_CH1_intr_en;//short detect interrupt enable
  rand logic       stim_CH2_intr_en;//short detect interrupt enable
  rand logic       stop_wavegen1;
  rand logic       stop_wavegen2;
  rand logic [1:0] A2D_stim_sel;
  rand logic       COMP_sel_CH1;//1'b0: Selects CH1 pos side; 1'b1: Selects CH1 neg side
  rand logic       COMP_sel_CH2;//1'b0: Selects CH2 pos side; 1'b1: Selects CH2 neg side
  rand logic       stimu_COMP_en_CH1;//1'b1: Enables CH1 short comparator; 1'b0: Disables CH1 short comparator
  rand logic       stimu_COMP_en_CH2;//1'b1: Enables CH2 short comparator; 1'b0: Disables CH2 short comparator
  rand logic       leadoff_COMP_en_CH1;//1'b1: Enables CH1 leadoff comparator; 1'b0: Disables CH1 leadoff comparator
  rand logic       leadoff_COMP_en_CH2;//1'b1: Enables CH2 leadoff comparator; 1'b0: Disables CH2 leadoff comparator
  rand bit          short_en;
  rand bit          lead_off_en;
  rand logic        lead_off_detect_by_short_circuit_en;
  //rand logic        comp_reverse;
       logic [7:0] NO_OF_LOAD_POINTS;
       integer     cnt;
       logic [31:0] wave_period_ch1[3];//considering upto 3 waveform_sel
       logic [31:0] wave_period_ch2[3];//considering upto 3 waveform_sel
       logic [31:0] wave_pulsewidth_ch1[3];//considering upto 3 waveform_sel
       logic [31:0] wave_pulsewidth_ch2[3];//considering upto 3 waveform_sel
       logic [31:0] pulsewidth_ch1[3];//considering upto 3 waveform_sel
       logic [31:0] pulsewidth_ch2[3];//considering upto 3 waveform_sel
       logic [31:0] period_ch1;
       logic [31:0] period_ch2;
       logic [31:0] pulse_width_ch1;
       logic [31:0] pulse_width_ch2;
  rand logic [31:0] no_of_cycles_CH1;
  rand logic [31:0] no_of_cycles_CH2;
  rand logic [7:0]  cnt_percent_of_timer_TH1;
  rand logic [7:0]  cnt_percent_of_timer_TH2;
  rand logic        manual_auto_intclr;//1'b0: manual clear int sts by writing to local int sts reg; 1'b1: automatic clear int sts upon reading general int sts reg;
  rand logic        auto_intclr_loc_gen_sel;//1'b0: selects local register to perform automatic int clear; 1'b1: selects general register to perform automatic int clear;
  rand logic        pulse_level_intb;//1'b0: selects level interrupt; 1'b1: selects pulse interrupt;
  rand logic        int_active_level_high_or_low;//1'b0: Active low; 1'b1: Active high;
  rand logic [11:0] VDAC_DIN_CH1;
  rand logic [11:0] VDAC_DIN_CH2;
       bit          disable_wg_scb_drv_0;
       bit          disable_wg_scb_drv_1;
  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_anac_short_sine_tri_arb_wave_test_cfg");
    super.new(name);
    
  endfunction: new

  // ===============================================
  // Adding constraints of randomization
  // -----------------------------------------------

  // testmode_sel[1:0] : 00-Normal mode, 01: Scanmode, 10: BIST mode, 11 atm0/1/2/3/4
  constraint c_testmode_sel    { soft testmode_sel == 2'b00; }

  // spimode_sel[1:0] :  
  //constraint c_spimode_sel     { spimode_sel == 2'b00; }

  // spi_sclk_freq[15:0]
  //constraint c_spi_sclk_freq   { soft spi_sclk_freq inside {[100:20000]};}//min 100Khz - max 20Mhz

  //pclk_div[2:0]
  //constraint c_pclk_sel    { soft pclk_sel inside {[0:1]};}

  //hfosc_jitter
  constraint c_hfosc_jitter    { soft hfosc_jitter == 0; }// 0%

  //hfosc_variation
  constraint c_hfosc_variation { soft hfosc_variation == 100; }// 0%

  // No of bytes in a burst
  constraint c_no_of_bytes     { soft no_of_bytes == 2; }

  // pads values
  constraint c_pads            { soft pads == 8'h00; }

  // mask values
  constraint c_mask            { soft mask == 8'hff; }

  // altf_sel
  //constraint c_altf_sel    { soft altf_sel == 2'b00; }

  //preload_sel
  constraint c_preload_sel     { preload_sel inside {[0:3]};}

  //neg_ena
  constraint c_neg_ena         { neg_ena == 1'b1;}//neg enabled

  //pos_dis
  constraint c_pos_dis         { pos_dis == 1'b0;}//pos enabled

  //points_sel
  constraint c_points_sel      { points_sel != 6;//In order to make sure amplitude > VDAC
                                 ((waveform_sel == 3'b000) && (neg_ena == 1'b1) && (pos_dis == 1'b0) && (pos_neg_diff_sel == 1'b0)) -> points_sel inside {[0:6]};
                                 ((waveform_sel == 3'b000) && (neg_ena == 1'b1) && (pos_dis == 1'b0) && (pos_neg_diff_sel == 1'b1)) -> points_sel inside {[0:7]};
                                 ((waveform_sel == 3'b001) && (neg_ena == 1'b1) && (pos_dis == 1'b0) && (pos_neg_diff_sel == 1'b0)) -> points_sel inside {[1:6]};
                                 ((waveform_sel == 3'b001) && (neg_ena == 1'b1) && (pos_dis == 1'b0) && (pos_neg_diff_sel == 1'b1)) -> points_sel inside {[0:6]};
                                 ((waveform_sel == 3'b010) && (neg_ena == 1'b1) && (pos_dis == 1'b0) && (pos_neg_diff_sel == 1'b0)) -> points_sel inside {[2:6]};
                                 ((waveform_sel == 3'b010) && (neg_ena == 1'b1) && (pos_dis == 1'b0) && (pos_neg_diff_sel == 1'b1)) -> points_sel inside {[1:6]};
                                 ((waveform_sel == 3'b000) && ((neg_ena == 1'b0) || (pos_dis == 1'b1))) -> points_sel inside {[0:7]};
                                 ((waveform_sel == 3'b001) && ((neg_ena == 1'b0) || (pos_dis == 1'b1))) -> points_sel inside {[0:6]};
                                 ((waveform_sel == 3'b010) && ((neg_ena == 1'b0) || (pos_dis == 1'b1))) -> points_sel inside {[1:6]};
                               }

  //waveform_sel
  constraint c_waveform_sel    { (preload_sel == 2'b01) -> waveform_sel inside {[1:2]};//do not generate square wave
                                 (preload_sel != 2'b01) -> waveform_sel inside {[0:2]};}

  //load_points_sel
  //constraint c_load_points_sel { (points_sel != 7) -> load_points_sel == 1'b0;}
  constraint c_load_points_sel { (((waveform_sel == 3'b001) || (waveform_sel == 3'b010)) && (preload_sel == 2'b11)) -> load_points_sel == 1'b1; (preload_sel != 2'b11) -> load_points_sel == 1'b0;}

  //pos_neg_diff_sel
  //constraint c_pos_neg_diff_sel { pos_neg_diff_sel == 1'b1;}

  //auto_man
  constraint c_auto_man        { auto_man == 1'b0;}

  //dac_bit_len_sel
  constraint c_dac_bit_len_sel { dac_bit_len_sel == 1'b0;}

  //dac0_msb_sel
  constraint c_dac0_msb_sel    { dac0_msb_sel inside {[0:0]};}//In order to make sure amplitude > VDAC

  //dac1_msb_sel
  constraint c_dac1_msb_sel    { dac1_msb_sel inside {[0:0]};}//In order to make sure amplitude > VDAC

  //PULLAB_lim
  constraint c_PULLAB_lim      { PULLAB_lim != 0;}

  //DELAY_lim
  constraint c_DELAY_lim       { DELAY_lim inside {[0:100]};}

  //A2D_stim_sel
  constraint c_A2D_stim_sel    { (short_en == 1) -> A2D_stim_sel == 2'b00; (short_en == 0) -> A2D_stim_sel == 2'b11;}

  //stimu_COMP_en_CH1
  constraint c_stimu_COMP_en_CH1 { stimu_COMP_en_CH1 == 1'b1; }//for analog purpose

  //stimu_COMP_en_CH2
  constraint c_stimu_COMP_en_CH2 { stimu_COMP_en_CH2 == 1'b1; }//for analog purpose

  //leadoff_COMP_en_CH1
  constraint c_leadoff_COMP_en_CH1 { leadoff_COMP_en_CH1 == 1'b1; }//for analog purpose

  //leadoff_COMP_en_CH2
  constraint c_leadoff_COMP_en_CH2 { leadoff_COMP_en_CH2 == 1'b1; }//for analog purpose

  //stim_CH1_en
  constraint c_stim_CH1_en      { stim_CH1_en == 1'b1;}

  //stim_CH2_en
  constraint c_stim_CH2_en      { stim_CH2_en == 1'b1;}

  //stim_CH1_intr_en
  constraint c_stim_CH1_intr_en { stim_CH1_intr_en inside {[0:1]}; (stim_CH2_intr_en == 0) -> stim_CH1_intr_en == 1'b1;}

  //stim_CH2_intr_en
  constraint c_stim_CH2_intr_en { stim_CH2_intr_en inside {[0:1]}; (stim_CH1_intr_en == 0) -> stim_CH2_intr_en == 1'b1;}

  //short_CH1_timer_th
  //constraint c_short_CH1_timer_th { short_CH1_timer_th inside {[1:10000]};}//timer_TH cannot be 0

  //short_CH2_timer_th
  //constraint c_short_CH2_timer_th { short_CH2_timer_th inside {[1:10000]};}//timer_TH cannot be 0

  //short_CH1_counter_th
  //constraint c_short_CH1_counter_th { short_CH1_counter_th <= short_CH1_timer_th;}// if counter_TH >= timer_TH, short interrrupt will not happen

  //short_CH2_counter_th
  //constraint c_short_CH2_counter_th { short_CH2_counter_th <= short_CH2_timer_th;}// if counter_TH >= timer_TH, short interrrupt will not happen

  //short_en
  constraint c_short_en         { short_en == 1'b1; }

  //lead_off_en
  constraint c_lead_off_en      { lead_off_en == 1'b1; }

  //register_val
  constraint c_register_val_ch1 { register_val_ch1 == 2'b10; } // 00: Open-circuit (so huge), 01: short-circuit (5 Ohm), 10: normal (1K Ohm)
  constraint c_register_val_ch2 { register_val_ch2 == 2'b10; } // 00: Open-circuit (so huge), 01: short-circuit (5 Ohm), 10: normal (1K Ohm)

  //lead_off_detect_by_short_circuit_en
  constraint c_lead_off_detect_by_short_circuit_en { lead_off_detect_by_short_circuit_en == 1'b0; } // to do leadoff detection using short detection block, 0: use short comparator, 1: use leadoff comparator

  //lead_off_comp_reverse
  //constraint c_lead_off_comp_reverse { comp_reverse == 0; }//comp_reverse not supported if leadoff to be detected using short detection block

  //stop_wavegen1
  //constraint c_stop_wavegen1   { stop_wavegen1 == 1'b0;}

  //stop_wavegen2
  //constraint c_stop_wavegen2   { stop_wavegen2 == 1'b0;}

  //no_of_cycles_CH1
  constraint c_no_of_cycles_CH1  { no_of_cycles_CH1 == 10; }

  //no_of_cycles_CH2
  constraint c_no_of_cycles_CH2  { no_of_cycles_CH2 == 10; }

  //cnt_percent_of_timer_TH1
  constraint c_cnt_percent_of_timer_TH1 { ((neg_ena == 1'b0) || (pos_dis == 1'b1)) -> cnt_percent_of_timer_TH1 == 40;//DC wave
                                          ((neg_ena == 1'b1) && (pos_dis == 1'b0)) -> cnt_percent_of_timer_TH1 inside {[10:20]};//sine/triangle/arbitrary
                                        }

  //cnt_percent_of_timer_TH2
  constraint c_cnt_percent_of_timer_TH2 { ((neg_ena == 1'b0) || (pos_dis == 1'b1)) -> cnt_percent_of_timer_TH2 == 40;//DC wave
                                          ((neg_ena == 1'b1) && (pos_dis == 1'b0)) -> cnt_percent_of_timer_TH2 inside {[10:20]};//sine/triangle/arbitrary
                                        }

  //manual_auto_intclr
  //constraint c_manual_auto_intclr { manual_auto_intclr == 1; }

  //auto_intclr_loc_gen_sel
  //constraint c_auto_intclr_loc_gen_sel { auto_intclr_loc_gen_sel == 1; }

  //pulse_level_intb
  //constraint c_pulse_level_intb   { pulse_level_intb == 1; }

  //int_active_level_high_or_low
  //constraint c_int_active_level_low_or_high  { int_active_level_high_or_low == 1; }

  constraint c_VDAC_DIN_CH1         { VDAC_DIN_CH1 == 200; } //for analog purpose - 200 is expected value in real chip as per Xin
  constraint c_VDAC_DIN_CH2         { VDAC_DIN_CH2 == 200; } //for analog purpose - 200 is expected value in real chip as per Xin

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
    `nnc_top.set_timeout(5s);
    top_test_cfg = `TESTCFG::type_id::create("top_test_cfg", this);
  endfunction

  // -----------------------------------------
  // Declare the pre_reset_phase task 
  // -----------------------------------------
  virtual task pre_reset_phase(nnc_phase phase);
    phase.raise_objection(this);

    super.pre_reset_phase(phase);

    assert(top_test_cfg.randomize());
    
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;

    //`DUT_IF.spimode_sel = top_test_cfg.spimode_sel;

    //`DUT_IF.spi_sclk_freq = top_test_cfg.spi_sclk_freq;

    //`DUT_IF.pclk_sel = top_test_cfg.pclk_sel;
    `DUT_IF.hfosc_jitter = top_test_cfg.hfosc_jitter;
    `DUT_IF.hfosc_variation = top_test_cfg.hfosc_variation;
    //`DUT_IF.altf_sel = top_test_cfg.altf_sel;

    //`DUT_IF.A2D_comp_sel = top_test_cfg.A2D_comp_sel;
    `DUT_IF.stop_wave1 = top_test_cfg.stop_wavegen1;
    `DUT_IF.stop_wave2 = top_test_cfg.stop_wavegen2;
    `DUT_IF.preload_sel = top_test_cfg.preload_sel;
    `DUT_IF.points_sel = top_test_cfg.points_sel;
    `DUT_IF.load_wave_data_till_points = top_test_cfg.load_points_sel;
    `DUT_IF.pos_neg_from_same_addr = top_test_cfg.pos_neg_diff_sel;
    `DUT_IF.no_of_waveforms = top_test_cfg.waveform_sel;
    `DUT_IF.neg_ena = top_test_cfg.neg_ena;
    `DUT_IF.pos_ena = top_test_cfg.pos_dis;
    `DUT_IF.rest_en = top_test_cfg.rest_en;
    `DUT_IF.silent_en = top_test_cfg.silent_en;
    `DUT_IF.PULLAB_pos_en[0] = top_test_cfg.PULLAB_pos_en;
    `DUT_IF.PULLAB_pos_en[1] = top_test_cfg.PULLAB_pos_en;
    `DUT_IF.PULLAB_neg_en[0] = top_test_cfg.PULLAB_neg_en;
    `DUT_IF.PULLAB_neg_en[1] = top_test_cfg.PULLAB_neg_en;
    `DUT_IF.PULLAB_lim[0] = top_test_cfg.PULLAB_lim;
    `DUT_IF.PULLAB_lim[1] = top_test_cfg.PULLAB_lim;
    `DUT_IF.DELAY_lim[0] = top_test_cfg.DELAY_lim;
    `DUT_IF.DELAY_lim[1] = top_test_cfg.DELAY_lim;
    `DUT_IF.D2A_comp_stim0_1_sel = top_test_cfg.COMP_sel_CH1;
    `DUT_IF.D2A_comp_stim2_3_sel = top_test_cfg.COMP_sel_CH2;
    `DUT_IF.leadoff_pos_neg_sel_CH1 = top_test_cfg.COMP_sel_CH1;
    `DUT_IF.leadoff_pos_neg_sel_CH2 = top_test_cfg.COMP_sel_CH2;
    `DUT_IF.anac_short_CH1_en = top_test_cfg.stim_CH1_en;
    `DUT_IF.anac_short_CH2_en = top_test_cfg.stim_CH2_en;
    `DUT_IF.anac_stim_CH1_intr_en = top_test_cfg.stim_CH1_intr_en;
    `DUT_IF.anac_stim_CH2_intr_en = top_test_cfg.stim_CH2_intr_en;
    `DUT_IF.anac_stim_CH1_pol = top_test_cfg.stim_level_val_CH1;
    `DUT_IF.anac_stim_CH2_pol = top_test_cfg.stim_level_val_CH2;
    `DUT_IF.lead_off_ch0_comp_low_active = top_test_cfg.stim_level_val_CH1;
    `DUT_IF.lead_off_ch1_comp_low_active = top_test_cfg.stim_level_val_CH2;
    //`DUT_IF.lead_off_comp_reverse = top_test_cfg.comp_reverse;
    `DUT_IF.counter_percent_of_timer_TH1 = top_test_cfg.cnt_percent_of_timer_TH1;
    `DUT_IF.counter_percent_of_timer_TH2 = top_test_cfg.cnt_percent_of_timer_TH2;
    `DUT_IF.no_of_cycles_CH1 = top_test_cfg.no_of_cycles_CH1;
    `DUT_IF.no_of_cycles_CH2 = top_test_cfg.no_of_cycles_CH2;
    `DUT_IF.lead_off_en = top_test_cfg.lead_off_en;
    `DUT_IF.short_en    = top_test_cfg.short_en;
    `DUT_IF.register_val_ch1 = top_test_cfg.register_val_ch1;
    `DUT_IF.register_val_ch2 = top_test_cfg.register_val_ch2;
    `DUT_IF.lead_off_detect_by_short_circuit_en = top_test_cfg.lead_off_detect_by_short_circuit_en;
    `DUT_IF.clear_intr_manual_or_auto = top_test_cfg.manual_auto_intclr;
    `DUT_IF.intr_length_slct_level_or_pulse = top_test_cfg.pulse_level_intb;
    `DUT_IF.int_active_level_high_or_low = top_test_cfg.int_active_level_high_or_low;
    `DUT_IF.no_of_anac_interrupts = 6;
    `DUT_IF.assertion_on = 1;

    // -------------------
    // Scoreboard enables
    // -------------------
    // `FLASH_SCOREBOARD_EN = 1;
    // `SPIM_SCOREBOARD_EN = 1;
    // `ANALOG_SCOREBOARD_EN = 1;
    // `IMEAS_SCOREBOARD_EN = 1;
    // `CLKRST_SCOREBOARD_EN = 1;

    phase.drop_objection(this);
  endtask : pre_reset_phase

  task generate_stimulus();
    logic [15:0]    randomNumber0;

    `nnc_info("SOC_TEST", "generate_stimulus start", NNC_LOW)
    fork
      // this will generate more number of leadoff condition , i.e. no response in A2D_COMP signals (register_val ==0)
      begin
        if(`DUT_IF.lead_off_detect_by_short_circuit_en === 1)begin
          forever begin
            repeat(400) @(posedge`DUT_IF.sys_clk);
            randomNumber0 = $urandom_range(10,0);
	    `DUT_IF.register_val_ch1 = (randomNumber0 <=3 ) ?  $urandom_range(2'b01,2'b10) : 2'b00;
            randomNumber0 = $urandom_range(10,0);
	    `DUT_IF.register_val_ch2 = (randomNumber0 <=3 ) ?  $urandom_range(2'b01,2'b10) : 2'b00;
          end
        end
      end
      // this will generate more number of shortr condition , i.e. in A2D_COMP_STIMU signals (register_val ==1)
      begin
        if(`DUT_IF.lead_off_detect_by_short_circuit_en === 0)begin
          forever begin
            repeat(400) @(posedge`DUT_IF.sys_clk);
            randomNumber0 = $urandom_range(10,0);
	    `DUT_IF.register_val_ch1 = (randomNumber0 <=3 ) ?  $urandom_range(2'b00,2'b10) : 2'b01;
            randomNumber0 = $urandom_range(10,0);
	    `DUT_IF.register_val_ch2 = (randomNumber0 <=3 ) ?  $urandom_range(2'b00,2'b10) : 2'b01;
          end
        end
      end
    join_none
  endtask : generate_stimulus

  // -----------------------------------------
  // Declare the main_phase task of your test
  // -----------------------------------------
  virtual task main_phase(nnc_phase phase);

    phase.raise_objection(this);

    super.main_phase(phase);

    `nnc_info("SOC_TEST", "soc_anac_short_sine_tri_arb_wave_test start", NNC_LOW)

    // ==================================================================================
    // Please add your code of your test here
    // ----------------------------------------------------------------------------------
    generate_stimulus();

    wavegen_setup(0);//setup wavegen for chip 0

    //Configure wavegen drv0
    wavegen_drv_config(`WAVEGEN_0_ADDR_BASE);
    //Configure wavegen drv1
    wavegen_drv_config(`WAVEGEN_1_ADDR_BASE);

    // ----------------------------------------------------------------------
    // Write to SOC_ANA_INTR_EN to disable ana intruppts(LVD,comp0 and comp1)
    // ----------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_INTR_EN; wr_data[0] == 8'h00;});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // -----------------------------------------------------------
    // Write to SOC_LEAD_OFF_INT_REG to disable lead off interrupt
    // -----------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_LEAD_OFF_INT_REG; wr_data[0] == 8'h00;});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // -----------------------------------------------------------------------------------------------
    // Write to SOC_GENERAL_INT_CTRL_REG to select manual/auto interrupt clear & level/pulse interrupt
    // -----------------------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_GENERAL_INT_CTRL_REG; wr_data[0] == {5'b0, `DUT_IF.int_active_level_high_or_low, `DUT_IF.clear_intr_manual_or_auto, `DUT_IF.intr_length_slct_level_or_pulse};});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    if(`DUT_IF.clear_intr_manual_or_auto === 1)
	   `nnc_info("SOC_TEST", "Auto int clear selected!", NNC_LOW)
    else
	   `nnc_info("SOC_TEST", "Manual int clear selected!", NNC_LOW)
    if(`DUT_IF.intr_length_slct_level_or_pulse === 1)
	   `nnc_info("SOC_TEST", "Pulse INTB selected!", NNC_LOW)
    else
	   `nnc_info("SOC_TEST", "Level INTB selected!", NNC_LOW)
    
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

    // ------------------------------------------------------------------------------
    // Write to SOC_ANA_GEN_2_REG
    // ------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_2_REG; wr_data[0] == {VDAC_DIN_CH1[7:0]};});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // ------------------------------------------------------------------------------
    // Write to SOC_ANA_GEN_3_REG
    // ------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_3_REG; wr_data[0] == {2'b0, `DUT_IF.leadoff_pos_neg_sel_CH1, 1'b0, VDAC_DIN_CH1[11:8]};});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // ------------------------------------------------------------------------------
    // Write to SOC_ANA_GEN_4_REG
    // ------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_4_REG; wr_data[0] == {VDAC_DIN_CH2[7:0]};});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // ------------------------------------------------------------------------------
    // Write to SOC_ANA_GEN_5_REG
    // ------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_5_REG; wr_data[0] == {2'b0, `DUT_IF.leadoff_pos_neg_sel_CH2, 1'b0, VDAC_DIN_CH2[11:8]};});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    //Configure short detection block
    short_config;

    if(`DUT_IF.int_active_level_high_or_low === 0) begin
	if(`SOC_TB.INTB !== 1)
	  `nnc_error("SOC_TEST", "Error! INTB not active low as expected!!")
	else
	  `nnc_info("SOC_TEST", "Active low INTB selected!", NNC_LOW)
    end
    else begin
	if(`SOC_TB.INTB !== 0)
	  `nnc_error("SOC_TEST", "Error! INTB not active high as expected!!")
	else
	   `nnc_info("SOC_TEST", "Active high INTB selected!", NNC_LOW)
    end

    // enable the short scb
    `ANAC_SHORT_SCB_EN = 1;

    //Enable wavegen drivers
    wavegen_drv_enable;

    fork
      wavegen_scb_dis;//disable wavegen SCB whenever short happens & wavegen stops
      wavegen_scb_en;//enable wavegen SCB whenever short happens & wavegen restarts
      pulse_INTB_active_high_check;
      pulse_INTB_active_low_check;
      level_INTB_active_high_check;
      level_INTB_active_low_check;
      interrupt_dis_check;
    join_none

    `DUT_IF.A2D_stim_sel = top_test_cfg.A2D_stim_sel;//only used if analog model is not used

    /*************************************************************************************************************************************************************************************************************/
    /********************************************************************************** Start monitoring SHORT interrupts ****************************************************************************************/
    /*************************************************************************************************************************************************************************************************************/
    top_test_cfg.cnt = 0;
    top_test_cfg.rd_data=new[1];
    top_test_cfg.rd_data[0] = 0;
    while(top_test_cfg.cnt < `DUT_IF.no_of_anac_interrupts) begin
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
      	`RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data[0]);
	if((top_test_cfg.rd_data[0][0] === 1) && (`ANAC_TOP.spi_anac.ana_comp_ch_intr_sts[0] === 1))
	  `nnc_info("SOC_TEST", "A2D_STIM_0/1 CH1 int sts is set!", NNC_LOW)
      	else if((top_test_cfg.rd_data[0][0] === 1) && (`ANAC_TOP.spi_anac.ana_comp_ch_intr_sts[0] === 0))
	  `nnc_error("SOC_TEST", "Error! A2D_STIM_0/1 CH1 unexpected int sts is set!!")
      	if((top_test_cfg.rd_data[0][1] === 1) && (`ANAC_TOP.spi_anac.ana_comp_ch_intr_sts[1] === 1))
	  `nnc_info("SOC_TEST", "A2D_STIM_2/3 CH2 int sts is set!", NNC_LOW)
      	else if((top_test_cfg.rd_data[0][1] === 1) && (`ANAC_TOP.spi_anac.ana_comp_ch_intr_sts[1] === 0))
	  `nnc_error("SOC_TEST", "Error! A2D_STIM_2/3 CH2 unexpected int sts is set!!")
      end
      else begin//if automatic; reading sts bit supposed to clear interrupt
      if(top_test_cfg.auto_intclr_loc_gen_sel === 1) begin//if automatic with general register access
        `nnc_info("SOC_TEST", "Automatically clear interrupt using general register!", NNC_LOW)
        // ------------------------------------------------------------------------------
        // Read from SOC_GENERAL_INT_STS_1_REG (check interrupt status)
        // ------------------------------------------------------------------------------
      	assert(top_test_cfg.randomize() with {reg_addr == `SOC_GENERAL_INT_STS_1_REG;});
      	`RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data[0]);

	if(top_test_cfg.rd_data[0][5] === 1'b1) begin
	  `nnc_info("SOC_TEST", "A2D_STIM_0/1 CH1 int sts is set!", NNC_LOW)
	  wait(`ANAC_TOP.spi_anac.ana_comp_ch_intr_sts[0] === 0);
	  `nnc_info("SOC_TEST", "A2D_STIM_0/1 CH1 int cleared!", NNC_LOW)
	end
	if(top_test_cfg.rd_data[0][6] === 1'b1) begin
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
      	`RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data[0]);

	if(top_test_cfg.rd_data[0][0] === 1'b1) begin
	  `nnc_info("SOC_TEST", "A2D_STIM_0/1 CH1 int sts is set!", NNC_LOW)
	  wait(`ANAC_TOP.spi_anac.ana_comp_ch_intr_sts[0] === 0);
	  `nnc_info("SOC_TEST", "A2D_STIM_0/1 CH1 int cleared!", NNC_LOW)
	end
	if(top_test_cfg.rd_data[0][1] === 1'b1) begin
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
      	assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_INTR_SIM_CL_REG; wr_data[0] == rd_data[0];});
      	`WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

	if(top_test_cfg.rd_data[0][0] === 1'b1) begin
	  wait(`ANAC_TOP.spi_anac.ana_comp_ch_intr_sts[0] === 0);
	  `nnc_info("SOC_TEST", "A2D_STIM_0/1 CH1 int cleared!", NNC_LOW)
	end
	if(top_test_cfg.rd_data[0][1] === 1'b1) begin
	  wait(`ANAC_TOP.spi_anac.ana_comp_ch_intr_sts[1] === 0);
	  `nnc_info("SOC_TEST", "A2D_STIM_2/3 CH2 int cleared!", NNC_LOW)
	end
      end

      top_test_cfg.cnt++;
      top_test_cfg.rd_data[0] = 0;
      #10;
    end
    
    if((`DUT_IF.stop_wave1 === 1) || (`DUT_IF.stop_wave2 === 1)) begin
	`WAVEGEN_SCB_DRV_0_EN = 1'b0;//Disable
	`WAVEGEN_SCB_DRV_1_EN = 1'b0;//Disable
    	`nnc_info("SOC_TEST", "WAVGEN_SCB Disabled!", NNC_LOW)
    end

    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    #10000ns;
    `nnc_info("SOC_TEST", "soc_anac_short_sine_tri_arb_wave_test end now", NNC_LOW)

    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ==================================================================================

    phase.drop_objection(this);
  endtask: main_phase

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

  task wavegen_setup(input int chip_num);
  begin
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
      top_env.wavegen_vif[chip_num].hex_data_a[i] = top_test_cfg.sine_data[i]; // expected hex values
      top_env.wavegen_vif[chip_num].hex_data_b[i] = top_test_cfg.sine_data[i]; // expected hex values
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
    wavegen_calc_clock_num(top_test_cfg.clk_freq, 0, 0, top_test_cfg.half_period0[0], top_test_cfg.half_period0[1]);
    top_test_cfg.hlf_wave0_lim[i] = top_test_cfg.hlf_wave_lim / `DUT_IF.point_cfg_val;
    top_test_cfg.neg_hlf_wave0_lim[i] = top_test_cfg.neg_hlf_wave_lim / `DUT_IF.point_cfg_val;
    top_test_cfg.rest_wave0_lim[i] = top_test_cfg.rest_lim;
    top_test_cfg.silent_wave0_lim[i] = top_test_cfg.silent_lim;
    `nnc_info("SOC_TEST", $sformatf("******** WAVE 0 ******** CLK_FREQ: %dKhz, HALF_PERIOD_LIMIT: %dus, POS_HALF_PERIOD_TARGET: %dus, NEG_HALF_PERIOD_TARGET: %dus, POS_HALF_PERIOD_CLKS_PER_POINT: %d, NEG_HALF_PERIOD_CLKS_PER_POINT: %d", top_test_cfg.clk_freq, top_test_cfg.half_period_limit, top_test_cfg.half_period0[0], top_test_cfg.half_period0[1], top_test_cfg.hlf_wave0_lim[i], top_test_cfg.neg_hlf_wave0_lim[i]), NNC_LOW)

    //wavegen_calc_clock_num(clk_freq (KHz), rest_t (us), silent_t (us), hlf_wave_per (us), neg_hlf_wave_per (us))
    wavegen_calc_clock_num(top_test_cfg.clk_freq, 0, 0, top_test_cfg.half_period1[0], top_test_cfg.half_period1[1]);
    top_test_cfg.hlf_wave1_lim[i] = top_test_cfg.hlf_wave_lim / `DUT_IF.point_cfg_val;
    top_test_cfg.neg_hlf_wave1_lim[i] = top_test_cfg.neg_hlf_wave_lim / `DUT_IF.point_cfg_val;
    top_test_cfg.rest_wave1_lim[i] = top_test_cfg.rest_lim;
    top_test_cfg.silent_wave1_lim[i] = top_test_cfg.silent_lim;
    `nnc_info("SOC_TEST", $sformatf("******** WAVE 1 ******** CLK_FREQ: %dKhz, HALF_PERIOD_LIMIT: %dus, POS_HALF_PERIOD_TARGET: %dus, NEG_HALF_PERIOD_TARGET: %dus, POS_HALF_PERIOD_CLKS_PER_POINT: %d, NEG_HALF_PERIOD_CLKS_PER_POINT: %d", top_test_cfg.clk_freq, top_test_cfg.half_period_limit, top_test_cfg.half_period1[0], top_test_cfg.half_period1[1], top_test_cfg.hlf_wave1_lim[i], top_test_cfg.neg_hlf_wave1_lim[i]), NNC_LOW)

    //wavegen_calc_clock_num(clk_freq (KHz), rest_t (us), silent_t (us), hlf_wave_per (us), neg_hlf_wave_per (us))
    wavegen_calc_clock_num(top_test_cfg.clk_freq, 0, 0, top_test_cfg.half_period2[0], top_test_cfg.half_period2[1]);
    top_test_cfg.hlf_wave2_lim[i] = top_test_cfg.hlf_wave_lim / `DUT_IF.point_cfg_val;
    top_test_cfg.neg_hlf_wave2_lim[i] = top_test_cfg.neg_hlf_wave_lim / `DUT_IF.point_cfg_val;
    top_test_cfg.rest_wave2_lim[i] = top_test_cfg.rest_lim;
    top_test_cfg.silent_wave2_lim[i] = top_test_cfg.silent_lim;
    `nnc_info("SOC_TEST", $sformatf("******** WAVE 2 ******** CLK_FREQ: %dKhz, HALF_PERIOD_LIMIT: %dus, POS_HALF_PERIOD_TARGET: %dus, NEG_HALF_PERIOD_TARGET: %dus, POS_HALF_PERIOD_CLKS_PER_POINT: %d, NEG_HALF_PERIOD_CLKS_PER_POINT: %d", top_test_cfg.clk_freq, top_test_cfg.half_period_limit, top_test_cfg.half_period2[0], top_test_cfg.half_period2[1], top_test_cfg.hlf_wave2_lim[i], top_test_cfg.neg_hlf_wave2_lim[i]), NNC_LOW)
    end
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
    // Write to SOC_ADDR_WG_DRV_CTRL0_REG
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CTRL0_REG + WG_BASE); wr_data[0] == {2'b0, top_test_cfg.dac_bit_len_sel,top_test_cfg.auto_man, 4'b0};});
    `nnc_info("SOC_TEST", "Set drive reg ctrl0", NNC_LOW)
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // --------------------------------------------------------
    // Write burst starting from SOC_ADDR_WG_DRV_CTRL1_REG
    // --------------------------------------------------------
    `nnc_info("SOC_TEST", "Set drive reg ctrl1-2", NNC_LOW)
    if(WG_BASE === `WAVEGEN_0_ADDR_BASE) begin
    	assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CTRL1_REG + WG_BASE); no_of_bytes == 2; wr_data[0] == {1'b0, top_test_cfg.dac0_msb_sel, top_test_cfg.dac0_data_h}; wr_data[1] == top_test_cfg.dac0_data_l;});
    	`WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);
    end
    else if(WG_BASE === `WAVEGEN_1_ADDR_BASE) begin
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

    // --------------------------------------------------------
    // Write to ADDR_WG_DRV_NEG_SCALE_REG0 (By default it is 1)
    // --------------------------------------------------------
    //assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_NEG_SCALE_REG0 + WG_BASE); wr_data[0] == 8'h01;});
    //`nnc_info("SOC_TEST", "Scale negative side", NNC_LOW)
    //`WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // --------------------------------------------------------
    // Write to ADDR_WG_DRV_POS_SCALE_REG0 (By default it is 1)
    // --------------------------------------------------------
    //assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_POS_SCALE_REG0 + WG_BASE); wr_data[0] == 8'h01;});
    //`nnc_info("SOC_TEST", "Scale positive side", NNC_LOW)
    //`WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

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
    	`nnc_info("SOC_TEST", "Config driver control register with preloaded pulse values", NNC_LOW)
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

  task wavegen_scb_dis;
  begin
    forever @(posedge `ANAC_TOP.spi_anac.ana_comp_ch_intr_sts[0] or posedge `ANAC_TOP.spi_anac.ana_comp_ch_intr_sts[1]) begin
      if((`DUT_IF.stop_wave1 === 1) && (`ANAC_TOP.spi_anac.ana_comp_ch_intr_sts[0] === 1) && (top_test_cfg.disable_wg_scb_drv_0 === 0)) begin
	`WAVEGEN_SCB_DRV_0_EN = 1'b0;//Disable
        top_test_cfg.disable_wg_scb_drv_0 = 1;
    	`nnc_info("SOC_TEST", "WAVGEN_SCB Disabled for drv 0 !", NNC_LOW)
      end
      if((`DUT_IF.stop_wave2 === 1) && (`ANAC_TOP.spi_anac.ana_comp_ch_intr_sts[1] === 1) && (top_test_cfg.disable_wg_scb_drv_1 === 0)) begin
	`WAVEGEN_SCB_DRV_1_EN = 1'b0;//Disable
        top_test_cfg.disable_wg_scb_drv_1 = 1;
    	`nnc_info("SOC_TEST", "WAVGEN_SCB Disabled for drv 1 !", NNC_LOW)
      end
    end
  end
  endtask

  task wavegen_scb_en;
  begin
    forever @(negedge `ANAC_TOP.spi_anac.ana_comp_ch_intr_sts[0] or negedge `ANAC_TOP.spi_anac.ana_comp_ch_intr_sts[1]) begin
      if((`DUT_IF.stop_wave1 === 1) && (`ANAC_TOP.spi_anac.ana_comp_ch_intr_sts[0] === 0) && (top_test_cfg.disable_wg_scb_drv_0 === 1)) begin
	`WAVEGEN_SCB_DRV_0_EN = 1'b1;//Enable
        top_test_cfg.disable_wg_scb_drv_0 = 0;
    	`nnc_info("SOC_TEST", "WAVGEN_SCB Enabled for drv 0 !", NNC_LOW)
      end
      if((`DUT_IF.stop_wave2 === 1) && (`ANAC_TOP.spi_anac.ana_comp_ch_intr_sts[1] === 0) && (top_test_cfg.disable_wg_scb_drv_1 === 1)) begin
	`WAVEGEN_SCB_DRV_1_EN = 1'b1;//Enable
        top_test_cfg.disable_wg_scb_drv_1 = 0;
    	`nnc_info("SOC_TEST", "WAVGEN_SCB Enabled for drv 1 !", NNC_LOW)
      end
    end
  end
  endtask

  task interrupt_dis_check;
  begin
    forever @(posedge`DUT_IF.sys_clk) begin
      if(`DUT_IF.anac_stim_CH1_intr_en === 0) begin//if ch1 interrupt disabled
	if(`ANAC_TOP.genblk1[0].u_anac_short_dtct_ch.o_ana_stimu_chx_intr_pin !== 0)
    	  `nnc_error("SOC_TEST", "Error! Unexpected interrupt on CH1!")
      end
      if(`DUT_IF.anac_stim_CH2_intr_en === 0) begin//if ch2 interrupt disabled
	if(`ANAC_TOP.genblk1[1].u_anac_short_dtct_ch.o_ana_stimu_chx_intr_pin !== 0)
    	  `nnc_error("SOC_TEST", "Error! Unexpected interrupt on CH2!")
      end
    end
  end
  endtask

  task pulse_INTB_active_high_check;
  begin
    forever @(posedge `SOC_TB.INTB) begin
      if((`DUT_IF.intr_length_slct_level_or_pulse === 1) && (`DUT_IF.int_active_level_high_or_low === 1)) begin//if active high pulse INTB is selected
	@(posedge `DUT_IF.sys_clk);
	@(negedge `DUT_IF.sys_clk);
        if((`SOC_TB.INTB !== 0) && (!(`ANAC_TOP.genblk1[0].u_anac_short_dtct_ch.o_ana_stimu_chx_intr_pin === 1 && `ANAC_TOP.genblk1[1].u_anac_short_dtct_ch.o_ana_stimu_chx_intr_pin === 1)))
    	  `nnc_error("SOC_TEST", "Error! pulse INTB more than 1 pclk!")
	else
	  `nnc_info("SOC_TEST", "pulse INTB is 1 pclk!", NNC_LOW)
      end 
    end
  end
  endtask

  task pulse_INTB_active_low_check;
  begin
    forever @(negedge `SOC_TB.INTB) begin
      if((`DUT_IF.intr_length_slct_level_or_pulse === 1) && (`DUT_IF.int_active_level_high_or_low === 0)) begin//if active low pulse INTB is selected
	@(posedge `DUT_IF.sys_clk);
	@(negedge `DUT_IF.sys_clk);
        if((`SOC_TB.INTB !== 1) && (!(`ANAC_TOP.genblk1[0].u_anac_short_dtct_ch.o_ana_stimu_chx_intr_pin === 1 && `ANAC_TOP.genblk1[1].u_anac_short_dtct_ch.o_ana_stimu_chx_intr_pin === 1)))
    	  `nnc_error("SOC_TEST", "Error! pulse INTB more than 1 pclk!")
	else
	  `nnc_info("SOC_TEST", "pulse INTB is 1 pclk!", NNC_LOW)
      end 
    end
  end
  endtask

  task level_INTB_active_high_check;
  begin
    forever @(posedge `SOC_TB.INTB or negedge `SOC_TB.INTB) begin
      if((`DUT_IF.intr_length_slct_level_or_pulse === 0) && (`DUT_IF.int_active_level_high_or_low === 1)) begin//if active high level INTB is selected
        if(`SOC_TB.INTB !== (`ANAC_TOP.genblk1[0].u_anac_short_dtct_ch.o_ana_stimu_chx_intr_pin | `ANAC_TOP.genblk1[1].u_anac_short_dtct_ch.o_ana_stimu_chx_intr_pin))
    	  `nnc_error("SOC_TEST", "Error! level INTB not expected!")
	else
	  `nnc_info("SOC_TEST", "level INTB is expected!", NNC_LOW)
      end 
    end
  end
  endtask

  task level_INTB_active_low_check;
  begin
    forever @(posedge `SOC_TB.INTB or negedge `SOC_TB.INTB) begin
      if((`DUT_IF.intr_length_slct_level_or_pulse === 0) && (`DUT_IF.int_active_level_high_or_low === 0)) begin//if active low level INTB is selected
        if(`SOC_TB.INTB !== ~(`ANAC_TOP.genblk1[0].u_anac_short_dtct_ch.o_ana_stimu_chx_intr_pin | `ANAC_TOP.genblk1[1].u_anac_short_dtct_ch.o_ana_stimu_chx_intr_pin))
    	  `nnc_error("SOC_TEST", "Error! level INTB not expected!")
	else
	  `nnc_info("SOC_TEST", "level INTB is expected!", NNC_LOW)
      end 
    end
  end
  endtask

  task short_config;
  begin
    /*************************************************************************************************************************************************************************************************************/
    /********************************************************************************** Configurations for SHORT DETECTION ***************************************************************************************/
    /*************************************************************************************************************************************************************************************************************/
    // -------------------------------------------------------------------------------------------------
    // Write to SOC_ANA_INT_COMP_POL_REG (To enable the analog STIM ch1 & ch2 interrupts & level value)
    // -------------------------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_INT_COMP_POL_REG; wr_data[0] == {1'b0, `DUT_IF.anac_short_CH2_en, `DUT_IF.anac_short_CH1_en, `DUT_IF.lead_off_detect_by_short_circuit_en, `DUT_IF.anac_stim_CH2_intr_en, `DUT_IF.anac_stim_CH1_intr_en, `DUT_IF.anac_stim_CH2_pol, `DUT_IF.anac_stim_CH1_pol};});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
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
    if(`DUT_IF.lead_off_detect_by_short_circuit_en === 0) begin//for SHORT detection
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
    end
    if(`DUT_IF.lead_off_detect_by_short_circuit_en === 1) begin//for LEADOFF detection
      if(`DUT_IF.leadoff_pos_neg_sel_CH1 === 0) begin
	top_test_cfg.pulsewidth_ch1[0] = top_test_cfg.hlf_wave0_lim[0] * `DUT_IF.point_cfg_val;
	top_test_cfg.pulsewidth_ch1[1] = top_test_cfg.hlf_wave1_lim[0] * `DUT_IF.point_cfg_val;
	top_test_cfg.pulsewidth_ch1[2] = top_test_cfg.hlf_wave2_lim[0] * `DUT_IF.point_cfg_val;
      end
      else begin
	top_test_cfg.pulsewidth_ch1[0] = top_test_cfg.neg_hlf_wave0_lim[0] * `DUT_IF.point_cfg_val;
	top_test_cfg.pulsewidth_ch1[1] = top_test_cfg.neg_hlf_wave1_lim[0] * `DUT_IF.point_cfg_val;
	top_test_cfg.pulsewidth_ch1[2] = top_test_cfg.neg_hlf_wave2_lim[0] * `DUT_IF.point_cfg_val;
      end
      if(`DUT_IF.leadoff_pos_neg_sel_CH2 === 0) begin
	top_test_cfg.pulsewidth_ch2[0] = top_test_cfg.hlf_wave0_lim[1] * `DUT_IF.point_cfg_val;
	top_test_cfg.pulsewidth_ch2[1] = top_test_cfg.hlf_wave1_lim[1] * `DUT_IF.point_cfg_val;
	top_test_cfg.pulsewidth_ch2[2] = top_test_cfg.hlf_wave2_lim[1] * `DUT_IF.point_cfg_val;
      end
      else begin
	top_test_cfg.pulsewidth_ch2[0] = top_test_cfg.neg_hlf_wave0_lim[1] * `DUT_IF.point_cfg_val;
	top_test_cfg.pulsewidth_ch2[1] = top_test_cfg.neg_hlf_wave1_lim[1] * `DUT_IF.point_cfg_val;
	top_test_cfg.pulsewidth_ch2[2] = top_test_cfg.neg_hlf_wave2_lim[1] * `DUT_IF.point_cfg_val;
      end
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
	top_test_cfg.pulse_width_ch1 = top_test_cfg.pulsewidth_ch1[0];
	top_test_cfg.pulse_width_ch2 = top_test_cfg.pulsewidth_ch2[0];	
    end
    else if(`DUT_IF.no_of_waveforms === 1) begin
	//period
	top_test_cfg.period_ch1 = top_test_cfg.wave_period_ch1[0] + top_test_cfg.wave_period_ch1[1];
	top_test_cfg.period_ch2 = top_test_cfg.wave_period_ch2[0] + top_test_cfg.wave_period_ch2[1];
	//pulsewidth
	top_test_cfg.pulse_width_ch1 = top_test_cfg.pulsewidth_ch1[0] + top_test_cfg.pulsewidth_ch1[1];
	top_test_cfg.pulse_width_ch2 = top_test_cfg.pulsewidth_ch2[0] + top_test_cfg.pulsewidth_ch2[1];
    end
    else if(`DUT_IF.no_of_waveforms === 2) begin
	//period
    	top_test_cfg.period_ch1 = top_test_cfg.wave_period_ch1[0] + top_test_cfg.wave_period_ch1[1] + top_test_cfg.wave_period_ch1[2];
	top_test_cfg.period_ch2 = top_test_cfg.wave_period_ch2[0] + top_test_cfg.wave_period_ch2[1] + top_test_cfg.wave_period_ch2[2];
	//pulsewidth
    	top_test_cfg.pulse_width_ch1 = top_test_cfg.pulsewidth_ch1[0] + top_test_cfg.pulsewidth_ch1[1] + top_test_cfg.pulsewidth_ch1[2];
	top_test_cfg.pulse_width_ch2 = top_test_cfg.pulsewidth_ch2[0] + top_test_cfg.pulsewidth_ch2[1] + top_test_cfg.pulsewidth_ch2[2];
    end
    
    top_test_cfg.short_CH1_timer_th = (`DUT_IF.no_of_cycles_CH1 + `DUT_IF.no_of_waveforms)/(`DUT_IF.no_of_waveforms+1) * top_test_cfg.period_ch1;
    top_test_cfg.short_CH2_timer_th = (`DUT_IF.no_of_cycles_CH2 + `DUT_IF.no_of_waveforms)/(`DUT_IF.no_of_waveforms+1) * top_test_cfg.period_ch2;
    `DUT_IF.anac_short_CH1_timer_TH = top_test_cfg.short_CH1_timer_th + `DUT_IF.DELAY_lim[0];
    `DUT_IF.anac_short_CH2_timer_TH = top_test_cfg.short_CH2_timer_th + `DUT_IF.DELAY_lim[0];

    `nnc_info("SOC_TEST", $sformatf("Setup CH1 Timer Threhold: %d", `DUT_IF.anac_short_CH1_timer_TH), NNC_LOW)
    // -------------------------------------------------------------------------------------
    // Write to SOC_ANA_STIM_CH1_TIMER_CNT_TH00_REG (CH1 TIMER THRESHOLD)
    // -------------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_STIM_CH1_TIMER_CNT_TH00_REG; wr_data[0] == `DUT_IF.anac_short_CH1_timer_TH[7:0];});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // -------------------------------------------------------------------------------------
    // Write to SOC_ANA_STIM_CH1_TIMER_CNT_TH01_REG (CH1 TIMER THRESHOLD)
    // -------------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_STIM_CH1_TIMER_CNT_TH01_REG; wr_data[0] == `DUT_IF.anac_short_CH1_timer_TH[15:8];});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // -------------------------------------------------------------------------------------
    // Write to SOC_ANA_STIM_CH1_TIMER_CNT_TH02_REG (CH1 TIMER THRESHOLD)
    // -------------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_STIM_CH1_TIMER_CNT_TH02_REG; wr_data[0] == `DUT_IF.anac_short_CH1_timer_TH[23:16];});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // -------------------------------------------------------------------------------------
    // Write to SOC_ANA_STIM_CH1_TIMER_CNT_TH03_REG (CH1 TIMER THRESHOLD)
    // -------------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_STIM_CH1_TIMER_CNT_TH03_REG; wr_data[0] == `DUT_IF.anac_short_CH1_timer_TH[31:24];});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    `nnc_info("SOC_TEST", $sformatf("Setup CH2 Timer Threhold: %d", `DUT_IF.anac_short_CH2_timer_TH), NNC_LOW)
    // -------------------------------------------------------------------------------------
    // Write to SOC_ANA_STIM_CH2_TIMER_CNT_TH00_REG (CH2 TIMER THRESHOLD)
    // -------------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_STIM_CH2_TIMER_CNT_TH00_REG; wr_data[0] == `DUT_IF.anac_short_CH2_timer_TH[7:0];});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // -------------------------------------------------------------------------------------
    // Write to SOC_ANA_STIM_CH2_TIMER_CNT_TH01_REG (CH2 TIMER THRESHOLD)
    // -------------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_STIM_CH2_TIMER_CNT_TH01_REG; wr_data[0] == `DUT_IF.anac_short_CH2_timer_TH[15:8];});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // -------------------------------------------------------------------------------------
    // Write to SOC_ANA_STIM_CH2_TIMER_CNT_TH02_REG (CH2 TIMER THRESHOLD)
    // -------------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_STIM_CH2_TIMER_CNT_TH02_REG; wr_data[0] == `DUT_IF.anac_short_CH2_timer_TH[23:16];});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // -------------------------------------------------------------------------------------
    // Write to SOC_ANA_STIM_CH2_TIMER_CNT_TH03_REG (CH2 TIMER THRESHOLD)
    // -------------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_STIM_CH2_TIMER_CNT_TH03_REG; wr_data[0] == `DUT_IF.anac_short_CH2_timer_TH[31:24];});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    /********************************************************* Calculate the counter_TH to be set for CH1 & CH2 *********************************************/
    if((`DUT_IF.neg_ena == 1'b1) && (`DUT_IF.pos_ena == 1'b0)) begin//both positive & negative enabled
    	top_test_cfg.short_CH1_counter_th = (((`DUT_IF.no_of_cycles_CH1 + `DUT_IF.no_of_waveforms)/(`DUT_IF.no_of_waveforms+1) * top_test_cfg.pulse_width_ch1)/2) - 1;
    	top_test_cfg.short_CH2_counter_th = (((`DUT_IF.no_of_cycles_CH2 + `DUT_IF.no_of_waveforms)/(`DUT_IF.no_of_waveforms+1) * top_test_cfg.pulse_width_ch2)/2) - 1;
    end
    else begin
	top_test_cfg.short_CH1_counter_th = (`DUT_IF.counter_percent_of_timer_TH1 * `DUT_IF.anac_short_CH1_timer_TH) / 100;
    	top_test_cfg.short_CH2_counter_th = (`DUT_IF.counter_percent_of_timer_TH2 * `DUT_IF.anac_short_CH2_timer_TH) / 100;
    end
    `DUT_IF.anac_short_CH1_counter_TH = top_test_cfg.short_CH1_counter_th;
    `DUT_IF.anac_short_CH2_counter_TH = top_test_cfg.short_CH2_counter_th;
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
  // ------------------------------
  // Declare the report_phase task
  // ------------------------------
  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction

endclass : `TESTNAME
