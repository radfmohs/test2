/*--------------------------------------------------------------------------------------
// Copyright 2021 Nanochap, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_imeas_eegfilter__base_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_zmeas_stim_mon_auto_pair_loop_test                                             
// Designer	: shreeyal@nanochap.com                                                                 
// Date		: 21-05-2025                                                                     
// Revision	: 0.1 Initial version created by script                                 
--------------------------------------------------------------------------------------*/
`define TESTNAME soc_zmeas_stim_mon_auto_pair_loop_test
`define TESTCFG soc_zmeas_stim_mon_auto_pair_loop_test_cfg

class `TESTCFG extends soc_zmeas_base_test_cfg;

  `nnc_object_utils(`TESTCFG)

  // -----------------------------------------------
  // Adding your new varialbles in config test
  // -----------------------------------------------

  // -----------------------------------------------
  // End of decalration of new variables 
  // -----------------------------------------------

  function new (string name = "soc_zmeas_stim_mon_auto_pair_loop_test_cfg");
    super.new(name);
  endfunction: new

  // -----------------------------------------------
  // Adding constraints of randomization
  // -----------------------------------------------

  constraint c_adc_mode                         { adc_mode inside {[1:1]};} // 0: manual , 1: automatic

  // -----------------------------------------------
  // End of adding constraints of randomization
  // -----------------------------------------------

endclass : `TESTCFG

class `TESTNAME extends soc_zmeas_base_test;
   
  `nnc_component_utils(`TESTNAME)

  `TESTCFG top_test_cfg;

  function new(string name, nnc_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(nnc_phase phase);
    super.build_phase(phase);
    uvm_top.set_timeout(2s);
    //uvm_top.set_timeout(5ms);
    top_test_cfg = `TESTCFG::type_id::create("top_test_cfg", this);
  endfunction

  virtual task pre_reset_phase(nnc_phase phase);
    phase.raise_objection(this);

    super.pre_reset_phase(phase);
    assert(top_test_cfg.randomize());

    `DUT_IF.adc_mode                    = top_test_cfg.adc_mode;
    stim_intr_checks_en = 1;

    phase.drop_objection(this);
  endtask : pre_reset_phase

  virtual task post_reset_phase(nnc_phase phase);
    phase.raise_objection(this);
    super.post_reset_phase(phase);
    phase.drop_objection(this);
  endtask : post_reset_phase

  virtual task main_phase(uvm_phase phase);
    phase.raise_objection(this);

    // ----------------------------------------------------------------------------------
    // Please add your code of your test here
    // ----------------------------------------------------------------------------------

    fork
      begin
        super.main_phase(phase);
      end
      begin
        `ifndef MIX_SIM_EN
        force `ANA_TOP.sar_adc_vip.A2D_ADC_DATA_EN = 0;
        repeat(4) @(negedge `CLK_CTRL_TOP.stim_monitor_dig_clk);
        release `ANA_TOP.sar_adc_vip.A2D_ADC_DATA_EN;
        `endif
      end
    join

    `nnc_info("SOC_TEST", "soc_zmeas_stim_mon_auto_pair_loop_test end now", NNC_LOW)
    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ----------------------------------------------------------------------------------

    phase.drop_objection(this);
  endtask: main_phase

endclass : `TESTNAME
