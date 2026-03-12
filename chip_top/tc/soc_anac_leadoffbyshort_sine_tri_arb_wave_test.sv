/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_anac_leadoffbyshort_sine_tri_arb_wave_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_anac_leadoffbyshort_sine_tri_arb_wave_test                                             
// Designer	: ddang@nanochap.com                                                                 
// Date		: 20-08-2024                                                                   
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

//*******************************************************************************************
// NOTE : This test is extended from soc_anac_short_sine_tri_arb_wave_test.
//        This test is used to check leadoff detection using short circuit block for
//        sine/triangle/arbitrary waveforms, using lead_off_detect_by_short_circuit_en feature.
//        This test considers 10 waveform cycles as the period of short checking window.
//        This test constraints the counter threshold value based on the following formula, 
//        counter_TH = 5 * PW, where PW is the pulse width of either positive half or 
//        negative half depending on D2A_LEAD_OFF_SEL_SA_SB_CH1/CH2 selection.
//*******************************************************************************************

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME_BASE soc_anac_short_sine_tri_arb_wave_test
`define TESTCFG_BASE soc_anac_short_sine_tri_arb_wave_test_cfg
`define TESTNAME soc_anac_leadoffbyshort_sine_tri_arb_wave_test
`define TESTCFG soc_anac_leadoffbyshort_sine_tri_arb_wave_test_cfg


class `TESTCFG extends `TESTCFG_BASE;

  `nnc_object_utils(`TESTCFG)

  // ===============================================
  // Adding your new varialbles in config test
  // -----------------------------------------------

  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_anac_leadoffbyshort_sine_tri_arb_wave_test_cfg");
    super.new(name);
    
  endfunction: new

  // ===============================================
  // Adding constraints of randomization
  // -----------------------------------------------

  //lead_off_detect_by_short_circuit_en
  constraint c_lead_off_detect_by_short_circuit_en { lead_off_detect_by_short_circuit_en == 1'b1; } // to do leadoff using short detection block, 0: use short comparator, 1: use leadoff comparator
 
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
    
    `DUT_IF.lead_off_detect_by_short_circuit_en = top_test_cfg.lead_off_detect_by_short_circuit_en;
    `DUT_IF.no_of_anac_interrupts = 6;
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

    `nnc_info("SOC_TEST", "soc_anac_leadoffbyshort_sine_tri_arb_wave_test start", NNC_LOW)

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
