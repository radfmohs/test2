/*--------------------------------------------------------------------------------------
// Copyright 2021 Nanochap, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_eegfilter_continuos_sine_wave_16adc_en_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_eegfilter_continuos_sine_wave_16adc_en_test                                             
// Designer	: shreeyal@nanochap.com                                                                 
// Date		: 06-10-2025                                                                     
// Revision	: 0.1 Initial version created by script                                 
--------------------------------------------------------------------------------------*/
`define TESTNAME soc_eegfilter_continuos_sine_wave_16adc_en_test
`define TESTCFG soc_eegfilter_continuos_sine_wave_16adc_en_test_cfg

class `TESTCFG extends soc_eegfilter_continuos_sine_wave_test_cfg;

  `nnc_object_utils(`TESTCFG)

  // -----------------------------------------------
  // End of decalration of new variables 
  // -----------------------------------------------

  function new (string name = "soc_eegfilter_continuos_sine_wave_16adc_en_test_cfg");
    super.new(name);
  endfunction: new

  // -----------------------------------------------
  // Adding constraints of randomization
  // -----------------------------------------------
  constraint c_imeas_sin_gen_en    { imeas_sin_gen_en inside {[0:1]}; }//generate sdm adc sine

  constraint c_imeas_en_dis_ch { imeas_en_dis_ch == 'h0; }//Enable all 16 adc ch
  // -----------------------------------------------
  // End of adding constraints of randomization
  // -----------------------------------------------

endclass : `TESTCFG

class `TESTNAME extends soc_eegfilter_continuos_sine_wave_test;
   
  `nnc_component_utils(`TESTNAME)

  `TESTCFG top_test_cfg;

  function new(string name, nnc_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(nnc_phase phase);
    super.build_phase(phase);
    uvm_top.set_timeout(2s);
    top_test_cfg = `TESTCFG::type_id::create("top_test_cfg", this);
  endfunction

  virtual task pre_reset_phase(nnc_phase phase);
    phase.raise_objection(this);

    super.pre_reset_phase(phase);

    assert(top_test_cfg.randomize());

    `DUT_IF.imeas_en_dis_ch   = top_test_cfg.imeas_en_dis_ch;
    `DUT_IF.imeas_sin_gen_en = top_test_cfg.imeas_sin_gen_en;

    phase.drop_objection(this);
  endtask : pre_reset_phase

  virtual task main_phase(uvm_phase phase);
    phase.raise_objection(this);

    super.main_phase(phase);
    `nnc_info("SOC_TEST", "soc_eegfilter_continuos_sine_wave_16adc_en_test end now", UVM_LOW)
    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ----------------------------------------------------------------------------------

    phase.drop_objection(this);
  endtask: main_phase

  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction
endclass : `TESTNAME
