/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_short_detect_by_lead_off_pulsewave_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_short_detect_by_lead_off_pulsewave_test                                             
// Designer	: shreeyal@nanochap.com                                                                 
// Date		: 26-06-2025                                                                           
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/


//************************************************************************************
// NOTE : This test checks the leadoff for pulse cases with rest and silent periods
//************************************************************************************

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_short_detect_by_lead_off_pulsewave_test
`define TESTCFG soc_short_detect_by_lead_off_pulsewave_test_cfg

class `TESTCFG extends soc_lead_off_detect_pulsewave_test_cfg;

  `nnc_object_utils(`TESTCFG)

  // ===============================================
  // Adding your new varialbles in config test
  // -----------------------------------------------

  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_short_detect_by_lead_off_pulsewave_test_cfg");
    super.new(name);
  endfunction: new

  // ===============================================
  // Adding constraints of randomization
  // -----------------------------------------------

  constraint c_short_detect_by_lead_off_en     { short_detect_by_lead_off_en == 1'b1; } // to do the short, 0: use leadoff comparator , 1: use short comparator

  // -----------------------------------------------
  // End of adding constraints of randomization
  // ===============================================

endclass : `TESTCFG

// ===============================================
// Main Testcase is defined
// -----------------------------------------------
class `TESTNAME extends soc_lead_off_detect_pulsewave_test;
   
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
    
    `DUT_IF.short_detect_by_lead_off_en = top_test_cfg.short_detect_by_lead_off_en;

    phase.drop_objection(this);
  endtask : pre_reset_phase

  // -----------------------------------------
  // Declare the main_phase task of your test
  // -----------------------------------------
  virtual task main_phase(nnc_phase phase);
    phase.raise_objection(this);

    `nnc_info("SOC_TEST", "soc_short_detect_by_lead_off_pulsewave_test start", NNC_LOW)
    super.main_phase(phase);
    `nnc_info("SOC_TEST", "soc_short_detect_by_lead_off_pulsewave_test end now", NNC_LOW)

    // ----------------------------------------------------------------------------------
    // End of test 
    // ==================================================================================

    phase.drop_objection(this);
  endtask: main_phase

endclass : `TESTNAME

