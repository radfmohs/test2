/*--------------------------------------------------------------------------------------
// Copyright 2021 Nanochap, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_eegfilter_singleshot_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_eegfilter_singleshot_test                                             
// Designer	: shreeyal@nanochap.com                                                                 
// Date		: 05-09-2025                                                                     
// Revision	: 0.1 Initial version created by script                                 
--------------------------------------------------------------------------------------*/
`define TESTNAME soc_eegfilter_singleshot_test
`define TESTCFG soc_eegfilter_singleshot_test_cfg

class `TESTCFG extends soc_eegfilter_base_test_cfg;

  `nnc_object_utils(`TESTCFG)

  // -----------------------------------------------
  // End of decalration of new variables 
  // -----------------------------------------------

  function new (string name = "soc_eegfilter_singleshot_test_cfg");
    super.new(name);
  endfunction: new

  // -----------------------------------------------
  // Adding constraints of randomization
  // -----------------------------------------------
  constraint c_single_shot_en      { single_shot_en == 1'b1; }

  constraint c_imeas_en            { imeas_en == 0; }// For single shot conversion, manual imeas_en is disabled

  //constraint c_imeas_cic_rate            { imeas_cic_rate == 2; }

  // -----------------------------------------------
  // End of adding constraints of randomization
  // -----------------------------------------------

endclass : `TESTCFG

class `TESTNAME extends soc_eegfilter_base_test;
   
  `nnc_component_utils(`TESTNAME)

  `TESTCFG top_test_cfg;

  function new(string name, nnc_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(nnc_phase phase);
    super.build_phase(phase);
    uvm_top.set_timeout(2s);
    //uvm_top.set_timeout(6ms);
    top_test_cfg = `TESTCFG::type_id::create("top_test_cfg", this);
  endfunction

  virtual task pre_reset_phase(nnc_phase phase);
    phase.raise_objection(this);

    super.pre_reset_phase(phase);

    assert(top_test_cfg.randomize());

    //`DUT_IF.cic_rate         = top_test_cfg.imeas_cic_rate; 
    `DUT_IF.imeas_en         = top_test_cfg.imeas_en;
    `DUT_IF.single_shot_en   = top_test_cfg.single_shot_en;

    phase.drop_objection(this);
  endtask : pre_reset_phase

  virtual task main_phase(uvm_phase phase);
    phase.raise_objection(this);

    `nnc_info("SOC_TEST", "soc_eegfilter_singleshot_test start", UVM_LOW)

    `nnc_info("SOC_TEST", $sformatf("soc_eegfilter_singleshot_test :: imeas_en=%0d ,single_shot_en=%0d ", `DUT_IF.imeas_en,`DUT_IF.single_shot_en), UVM_LOW)
    super.main_phase(phase);
    // ----------------------------------------------------------------------------------
    // Please add your code of your test here
    // ----------------------------------------------------------------------------------

    `nnc_info("SOC_TEST", "soc_eegfilter_singleshot_test end now", UVM_LOW)
    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ----------------------------------------------------------------------------------

    phase.drop_objection(this);
  endtask: main_phase

  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction
endclass : `TESTNAME
