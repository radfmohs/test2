/*--------------------------------------------------------------------------------------
// Copyright 2021 Nanochap, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_eegfilter_rdata_daisy_3_device_with_status_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_eegfilter_rdata_daisy_3_device_with_status_test                                             
// Designer	: shreeyal@nanochap.com                                                                 
// Date		: 05-09-2025                                                                     
// Revision	: 0.1 Initial version created by script                                 
--------------------------------------------------------------------------------------*/
`define TESTNAME soc_eegfilter_rdata_daisy_3_device_with_status_test
`define TESTCFG soc_eegfilter_rdata_daisy_3_device_with_status_test_cfg

class `TESTCFG extends soc_eegfilter_rdata_daisy_test_cfg;

  `nnc_object_utils(`TESTCFG)

  // -----------------------------------------------
  // End of decalration of new variables 
  // -----------------------------------------------

  function new (string name = "soc_eegfilter_rdata_daisy_3_device_with_status_test_cfg");
    super.new(name);
  endfunction: new

  // -----------------------------------------------
  // Adding constraints of randomization
  // -----------------------------------------------

  constraint c_imeas_status_en { imeas_status_en == 1; }// Imeas data with status 

  // -----------------------------------------------
  // End of adding constraints of randomization
  // -----------------------------------------------

endclass : `TESTCFG

class `TESTNAME extends soc_eegfilter_rdata_daisy_test;
   
  `nnc_component_utils(`TESTNAME)

  `TESTCFG top_test_cfg;

  function new(string name, nnc_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(nnc_phase phase);
    super.build_phase(phase);
    uvm_top.set_timeout(2s);
    //uvm_top.set_timeout(10ms);
    top_test_cfg = `TESTCFG::type_id::create("top_test_cfg", this);
  endfunction

  virtual task pre_reset_phase(nnc_phase phase);
    phase.raise_objection(this);

    super.pre_reset_phase(phase);

    assert(top_test_cfg.randomize());

    `DUT_IF.imeas_status_en   = top_test_cfg.imeas_status_en   ;

    `nnc_info("SOC_TEST", $sformatf("imeas_status_en = %0d , imeas_24bitdata_en=%0d", `DUT_IF.imeas_status_en,`DUT_IF.imeas_24bitdata_en), UVM_LOW)
 
    phase.drop_objection(this);
  endtask : pre_reset_phase

  virtual task post_reset_phase(nnc_phase phase);
    phase.raise_objection(this);
    super.post_reset_phase(phase);

    `DUT_IF.total_chip_num = 3;

    phase.drop_objection(this);
  endtask : post_reset_phase

  virtual task main_phase(uvm_phase phase);
    phase.raise_objection(this);

    `nnc_info("SOC_TEST", "soc_eegfilter_rdata_daisy_3_device_with_status_test start now", UVM_LOW)
    super.main_phase(phase);
    `nnc_info("SOC_TEST", "soc_eegfilter_rdata_daisy_3_device_with_status_test end now", UVM_LOW)
    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ----------------------------------------------------------------------------------

    phase.drop_objection(this);
  endtask: main_phase

  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction
endclass : `TESTNAME
