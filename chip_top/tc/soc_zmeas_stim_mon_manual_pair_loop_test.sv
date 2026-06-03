/*--------------------------------------------------------------------------------------
// Copyright 2021 Nanochap, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_imeas_eegfilter__base_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_stim_vol_measure_resistor_monitor_base_test                                             
// Designer	: shreeyal@nanochap.com                                                                 
// Date		: 21-05-2025                                                                     
// Revision	: 0.1 Initial version created by script                                 
--------------------------------------------------------------------------------------*/
`define TESTNAME soc_zmeas_stim_mon_manual_pair_loop_test
`define TESTCFG soc_zmeas_stim_mon_manual_pair_loop_test_cfg

class `TESTCFG extends soc_zmeas_base_test_cfg;

  `nnc_object_utils(`TESTCFG)

  // -----------------------------------------------
  // Adding your new varialbles in config test
  // -----------------------------------------------

  // -----------------------------------------------
  // End of decalration of new variables 
  // -----------------------------------------------

  function new (string name = "soc_zmeas_stim_mon_manual_pair_loop_test");
    super.new(name);
  endfunction: new

  // -----------------------------------------------
  // Adding constraints of randomization
  // -----------------------------------------------

  constraint c_adc_mode                         { adc_mode inside {[0:0]};} // 0: manual , 1: automatic

  constraint c_pair_num                         { pair_num inside {['h4:'hF]};} // 0:1 pair, 1:2 pair,.. 'hF:16 pair

  constraint c_read_adc_data_en                 { read_adc_data_en inside {[0:0]};}  

  constraint c_stim_dly_tgt                     { stim_dly_tgt inside {[0:0]};}  

  constraint c_stim_mon_period                  { stim_mon_period inside {[10:30]};} // change later 

  //constraint c_mon_adc_clk_inv                  { mon_adc_clk_inv inside {[1:1]};} // 0: same phase, 1: invert of dig adc
  constraint c_mon_adc_clk_inv                  { mon_adc_clk_inv inside {[0:0]};} // 0: same phase, 1: invert of dig adc

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
    //uvm_top.set_timeout(2s);
    uvm_top.set_timeout(30ms);
    top_test_cfg = `TESTCFG::type_id::create("top_test_cfg", this);
  endfunction

  virtual task pre_reset_phase(nnc_phase phase);
    phase.raise_objection(this);

    super.pre_reset_phase(phase);
    assert(top_test_cfg.randomize());

    `DUT_IF.adc_mode                    = top_test_cfg.adc_mode;
    `DUT_IF.pair_num                    = top_test_cfg.pair_num;
    `DUT_IF.stim_mon_period             = top_test_cfg.stim_mon_period;
    `DUT_IF.mon_adc_clk_inv             = top_test_cfg.mon_adc_clk_inv;
    `DUT_IF.read_adc_data_en            = top_test_cfg.read_adc_data_en;
    `DUT_IF.stim_dly_tgt                = top_test_cfg.stim_dly_tgt;

    `DUT_IF.sar_adc_data_timing_t1 = top_test_cfg.sar_adc_data_timing_t1;
    `DUT_IF.sar_adc_data_timing_t2 = top_test_cfg.sar_adc_data_timing_t2;
    `DUT_IF.adc_delta_data_in_manual_en = 1;

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

    super.main_phase(phase);

    `nnc_info("SOC_TEST", "soc_zmeas_stim_mon_manual_pair_loop_test end now", NNC_LOW)
    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ----------------------------------------------------------------------------------

    phase.drop_objection(this);
  endtask: main_phase

endclass : `TESTNAME
