/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_anac_short_leadoff_detection_counterdbg_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_anac_short_leadoff_detection_counterdbg_test                                             
// Designer	: ddang@nanochap.com                                                                 
// Date		: 20-08-2024                                                                   
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

//*******************************************************************************************
// NOTE : This test is extended from soc_anac_short_leadoff_detection_test, but specifically 
//        intented to test short & lead-off by setting counter threshold value based on 
//        counter debug (COUNTER_CNT_DBG) register. As this register is shared among 
//        short_CH1/short_CH2/leadoff_CH1/leadoff_CH2, user should select which counter 
//        to read by using COUNTER_CNT_DBG_SEL register. This test initially considers 
//        normal mode(no short/no leadoff) to estimate the actual no: of A2D responses 
//        at the end of timer check window by reading the counter debug register. Then 
//        user can apply the read value of counter debug register as the counter threshold
//        value & then restart the wavegen to start monitoring short/leadoff detection.
//*******************************************************************************************

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME_BASE soc_anac_short_leadoff_detection_test
`define TESTCFG_BASE soc_anac_short_leadoff_detection_test_cfg
`define TESTNAME soc_anac_short_leadoff_detection_counterdbg_test
`define TESTCFG soc_anac_short_leadoff_detection_counterdbg_test_cfg


class `TESTCFG extends `TESTCFG_BASE;

  `nnc_object_utils(`TESTCFG)

  // ===============================================
  // Adding your new varialbles in config test
  // -----------------------------------------------
  rand logic       short_COMP_sel_CH1;//1'b0: Selects CH1 pos side; 1'b1: Selects CH1 neg side
  rand logic       short_COMP_sel_CH2;//1'b0: Selects CH2 pos side; 1'b1: Selects CH2 neg side
  rand logic       leadoff_COMP_sel_CH1;//1'b0: Selects CH1 pos side; 1'b1: Selects CH1 neg side
  rand logic       leadoff_COMP_sel_CH2;//1'b0: Selects CH2 pos side; 1'b1: Selects CH2 neg side
  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_anac_short_leadoff_detection_counterdbg_test_cfg");
    super.new(name);
    
  endfunction: new

  // ===============================================
  // Adding constraints of randomization
  // -----------------------------------------------
  //DELAY_lim
  constraint c_DELAY_lim       { DELAY_lim == 0;}
  //load_points_sel
  constraint c_load_points_sel { load_points_sel == 1'b0;}
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

    `DUT_IF.D2A_comp_stim0_1_sel = top_test_cfg.short_COMP_sel_CH1;
    `DUT_IF.D2A_comp_stim2_3_sel = top_test_cfg.short_COMP_sel_CH2;
    `DUT_IF.leadoff_pos_neg_sel_CH1 = top_test_cfg.leadoff_COMP_sel_CH1;
    `DUT_IF.leadoff_pos_neg_sel_CH2 = top_test_cfg.leadoff_COMP_sel_CH2;
    `DUT_IF.preload_sel = top_test_cfg.preload_sel;
    `DUT_IF.points_sel = top_test_cfg.points_sel;
    `DUT_IF.load_wave_data_till_points = top_test_cfg.load_points_sel;
    `DUT_IF.pos_neg_from_same_addr = top_test_cfg.pos_neg_diff_sel;
    `DUT_IF.no_of_waveforms = top_test_cfg.waveform_sel;
    `DUT_IF.neg_ena = top_test_cfg.neg_ena;
    `DUT_IF.pos_ena = top_test_cfg.pos_dis;
    `DUT_IF.DELAY_lim[0] = top_test_cfg.DELAY_lim;
    `DUT_IF.DELAY_lim[1] = top_test_cfg.DELAY_lim;
    `DUT_IF.no_of_anac_interrupts = 10;

    counter_dbg_read_en = 1;
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

    `nnc_info("SOC_TEST", "soc_anac_short_leadoff_detection_counterdbg_test start", NNC_LOW)

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
