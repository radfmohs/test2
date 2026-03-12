/*--------------------------------------------------------------------------------------
// Copyright 2021 Nanochap, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_imeas_lpf_notch_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_imeas_lpf_notch_test                                             
// Designer	: shreeyal@nanochap.com                                                                 
// Date		: 10-11-2025                                                                     
// Revision	: 0.1 Initial version created by script                                 
--------------------------------------------------------------------------------------*/
`define TESTNAME soc_imeas_lpf_notch_test
`define TESTCFG soc_imeas_lpf_notch_test_cfg

class `TESTCFG extends soc_imeas_lpf_notch_hpf_test_cfg;

  `nnc_object_utils(`TESTCFG)

  // -----------------------------------------------
  // End of decalration of new variables 
  // -----------------------------------------------

  function new (string name = "soc_imeas_lpf_notch_test_cfg");
    super.new(name);
  endfunction: new

  // -----------------------------------------------
  // Adding constraints of randomization
  // -----------------------------------------------

  constraint c_lpf_enable     {  lpf_enable == 1 ;} // lpf enable case

  constraint c_notch_enable   {  notch_enable == 1 ;} // notch enable case

  constraint c_hpf_enable     {  hpf_enable == 0 ;} // hpf disable case

  // -----------------------------------------------
  // End of adding constraints of randomization
  // -----------------------------------------------

endclass : `TESTCFG

class `TESTNAME extends soc_imeas_lpf_notch_hpf_test;
   
  `nnc_component_utils(`TESTNAME)

  `TESTCFG top_test_cfg;

  function new(string name, nnc_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(nnc_phase phase);
    super.build_phase(phase);
    uvm_top.set_timeout(2s);
    //uvm_top.set_timeout(400ms);
    top_test_cfg = `TESTCFG::type_id::create("top_test_cfg", this);
  endfunction

  virtual task pre_reset_phase(nnc_phase phase);
    phase.raise_objection(this);

    super.pre_reset_phase(phase);

    assert(top_test_cfg.randomize());

    `DUT_IF.notch_enable = top_test_cfg.notch_enable;
    `DUT_IF.lpf_enable = top_test_cfg.lpf_enable;
    `DUT_IF.hpf_enable = top_test_cfg.hpf_enable;

    `DUT_IF.notch_filter_en_per_ch = top_test_cfg.notch_filter_en_per_ch;

    `DUT_IF.lpf_filter_en_per_ch = top_test_cfg.lpf_filter_en_per_ch;

    `DUT_IF.hpf_filter_en_per_ch = top_test_cfg.hpf_filter_en_per_ch;

    phase.drop_objection(this);
  endtask : pre_reset_phase

  virtual task main_phase(uvm_phase phase);
    phase.raise_objection(this);

    super.main_phase(phase);

    `nnc_info("SOC_TEST", "soc_imeas_lpf_notch_test end now", UVM_LOW)
    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ----------------------------------------------------------------------------------

    phase.drop_objection(this);
  endtask: main_phase

endclass : `TESTNAME
