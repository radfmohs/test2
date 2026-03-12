/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_anac_short_leadoff_detection_alternating_wave_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_anac_short_leadoff_detection_alternating_wave_test                                             
// Designer	: ddang@nanochap.com                                                                 
// Date		: 20-08-2024                                                                   
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

//*******************************************************************************************
// NOTE : This test is extended from soc_anac_short_leadoff_detection_test, but specifically
//        intented to test short & lead-off using alternating sine/triangle waveform.
//*******************************************************************************************

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME_BASE soc_anac_short_leadoff_detection_test
`define TESTCFG_BASE soc_anac_short_leadoff_detection_test_cfg
`define TESTNAME soc_anac_short_leadoff_detection_alternating_wave_test
`define TESTCFG soc_anac_short_leadoff_detection_alternating_wave_test_cfg


class `TESTCFG extends `TESTCFG_BASE;

  `nnc_object_utils(`TESTCFG)

  // ===============================================
  // Adding your new varialbles in config test
  // -----------------------------------------------

  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_anac_short_leadoff_detection_alternating_wave_test_cfg");
    super.new(name);
    
  endfunction: new

  // ===============================================
  // Adding constraints of randomization
  // -----------------------------------------------

  //preload_sel
  constraint c_preload_sel      { preload_sel inside {0,2,3};}//sine/triangle alternating case considered

  //waveform_sel
  constraint c_waveform_sel     { waveform_sel inside {[0:0]};}

  //neg_ena
  constraint c_neg_ena         { neg_ena == 1'b0;}//only S1(pos) state in alternating mode

  //pos_dis
  constraint c_pos_dis         { pos_dis == 1'b0;}//only S1(pos) state in alternating mode

  //alt_en
  constraint c_alt_en          { alt_en == 1'b1;}//alternating mode enabled

  //points_sel
  constraint c_points_sel      { points_sel inside {0,7};}//only 64/128 points considered

  //pos_neg_diff_sel
  constraint c_pos_neg_diff_sel { pos_neg_diff_sel == 1'b0;}//This cannot be set for neg-only/pos-only case

  //PULLAB_pos_en,PULLAB_neg_en
  constraint c_PULLAB_pos_en    { PULLAB_pos_en == 0; }
  constraint c_PULLAB_neg_en    { PULLAB_neg_en == 0; }

  //no_of_cycles_CH1
  constraint c_no_of_cycles_CH1  { no_of_cycles_CH1 == 6; }

  //no_of_cycles_CH2
  constraint c_no_of_cycles_CH2  { no_of_cycles_CH2 == 6; }
  // -----------------------------------------------
  // End of adding constraints of randomization
  // ===============================================

endclass : `TESTCFG

// ===============================================
// Main Testcase is defined
// -----------------------------------------------
class `TESTNAME extends `TESTNAME_BASE;
   
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
     
    `DUT_IF.preload_sel = top_test_cfg.preload_sel;
    `DUT_IF.points_sel = top_test_cfg.points_sel;
    `DUT_IF.load_wave_data_till_points = top_test_cfg.load_points_sel;
    `DUT_IF.pos_neg_from_same_addr = top_test_cfg.pos_neg_diff_sel;
    `DUT_IF.no_of_waveforms = top_test_cfg.waveform_sel;
    `DUT_IF.neg_ena = top_test_cfg.neg_ena;
    `DUT_IF.pos_ena = top_test_cfg.pos_dis;
    `DUT_IF.alt_en = top_test_cfg.alt_en;
    `DUT_IF.PULLAB_pos_en[0] = top_test_cfg.PULLAB_pos_en;
    `DUT_IF.PULLAB_pos_en[1] = top_test_cfg.PULLAB_pos_en;
    `DUT_IF.PULLAB_neg_en[0] = top_test_cfg.PULLAB_neg_en;
    `DUT_IF.PULLAB_neg_en[1] = top_test_cfg.PULLAB_neg_en;
    `DUT_IF.no_of_cycles_CH1 = top_test_cfg.no_of_cycles_CH1;
    `DUT_IF.no_of_cycles_CH2 = top_test_cfg.no_of_cycles_CH2;
    `DUT_IF.no_of_anac_interrupts = 10;
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

  // -----------------------------------------
  // Declare the main_phase task of your test
  // -----------------------------------------
  virtual task main_phase(nnc_phase phase);
    phase.raise_objection(this);

    `nnc_info("SOC_TEST", "soc_anac_short_leadoff_detection_alternating_wave_test start", NNC_LOW)

    super.main_phase(phase);

    phase.drop_objection(this);
  endtask: main_phase

  // ------------------------------
  // Declare the report_phase task
  // ------------------------------
  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction

endclass : `TESTNAME
