/*--------------------------------------------------------------------------------------
// Copyright 2021 Nanochap, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_eegfilter_sw_int_clear_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_eegfilter_sw_int_clear_test                                             
// Designer	: ophina@nanochap.com                                                                 
// Date		: 05-09-2025                                                                     
// Revision	: 0.1 Initial version created by script                                 
--------------------------------------------------------------------------------------*/
`define TESTNAME soc_eegfilter_sw_int_clear_test
`define TESTCFG soc_eegfilter_sw_int_clear_test_cfg

class `TESTCFG extends soc_eegfilter_base_test_cfg;

  `nnc_object_utils(`TESTCFG)

  // -----------------------------------------------
  // End of decalration of new variables 
  // -----------------------------------------------
  rand logic [15:0] no_of_samples;

  function new (string name = "soc_eegfilter_sw_int_clear_test_cfg");
    super.new(name);
  endfunction: new

  // -----------------------------------------------
  // Adding constraints of randomization
  // -----------------------------------------------
  constraint c_imeas_en_dis_ch   {  imeas_en_dis_ch != 16'hFFFF ;} // atlist 1 channel should be enabled 

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
    //uvm_top.set_timeout(5ms);
    top_test_cfg = `TESTCFG::type_id::create("top_test_cfg", this);
  endfunction

  virtual task pre_reset_phase(nnc_phase phase);
    phase.raise_objection(this);

    super.pre_reset_phase(phase);

    assert(top_test_cfg.randomize());
    `DUT_IF.imeas_en_dis_ch = top_test_cfg.imeas_en_dis_ch;

    `IMEAS_SCB_EN = 1'b1;

    phase.drop_objection(this);
  endtask : pre_reset_phase

  virtual task main_phase(uvm_phase phase);
    int random_delay;
    int prev_no_of_conversions;

    phase.raise_objection(this);

    `nnc_info("SOC_TEST", "soc_eegfilter_sw_int_clear_test start", UVM_LOW)

    `nnc_info("SOC_TEST", $sformatf("soc_eegfilter_sw_int_clear_test :: imeas_en=%0d ,single_shot_en=%0d ", `DUT_IF.imeas_en,`DUT_IF.single_shot_en), UVM_LOW)

    imeas_config();
    basic_traffic_with_multi_start_stop();

    `nnc_info("SOC_TEST", "soc_eegfilter_sw_int_clear_test end now", UVM_LOW)
    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ----------------------------------------------------------------------------------

    phase.drop_objection(this);
  endtask: main_phase

  task basic_traffic_with_multi_start_stop ();
    `nnc_info("SOC_TEST", $sformatf("no_of_conversions=%0d ", top_test_cfg.no_of_conversions), UVM_LOW)
    repeat(top_test_cfg.no_of_conversions) begin

      `nnc_info("SOC_TEST", $sformatf("imeas_en=%0d ,single_shot_en=%0d ", `DUT_IF.imeas_en,`DUT_IF.single_shot_en), UVM_LOW)
      use_old_intr_reg_or_general_reg_to_clr = $random; // 0: use old sts regs to clear int, 1 : use new general reg to clear int

      // Start/Restart (Synchronize) Conversion in single-shot/continous mode
      fork 
        begin
          start_conversion();
        end
        begin
          wait_for_intb();
          `nnc_info("SOC_TEST", "Measurement is done!!!", UVM_LOW)
        end
      join

      check_int_sts_reg(1); // check reg sts

      fork
        clear_int_sts_reg();
	//compare_imeas_chdata_through_rdata_cmd(0);
        wait_for_intb_clear();
      join

      // Stop conversion for single-shot or continuos
      stop_conversion();

      // wait for current conversion to complete for continuos mode
      if(`DUT_IF.single_shot_en === 0) begin
        wait_for_one_conversion_to_finish();
      end

      // check imeas_data after conversion stops
      for (int i = 0; i < `FILTER_NUM ; i++)begin
        `DUT_IF.imeas_data_sel = i;
        compare_imeas_chdata (`DUT_IF.imeas_data_sel,0);
      end

      compare_imeas_chdata_through_rdata_cmd(0);
    end

  endtask : basic_traffic_with_multi_start_stop

  task wait_for_one_conversion_to_finish();
    `nnc_info("SOC_TEST", "wait for one conversion after stop cmd", UVM_LOW)
 
    if(`FILTER_WRAPPER_TOP.o_eeg_int === 1)begin
      fork
        clear_int_sts_reg();
	//compare_imeas_chdata_through_rdata_cmd(0);
        wait_for_intb_clear();
      join
    end

    fork : wait_for_conversion
      begin
          wait_for_intb();
          `nnc_info("SOC_TEST", "wait done for one conversion after stop cmd", UVM_LOW)
      end
      begin
        `nnc_info("TEST", $sformatf("will wait for one_conversion_period =%0f(ns)", (one_conversion_period*1000)),NNC_LOW)
        #(one_conversion_period*1000); // ns
        `nnc_info("SOC_TEST", "wait done for one conversion after stop cmd", UVM_LOW)
      end
    join_any
    disable wait_for_conversion;

    if(`FILTER_WRAPPER_TOP.eeg_int_sts === 1)begin
      fork
        clear_int_sts_reg();
	//compare_imeas_chdata_through_rdata_cmd(0);
        wait_for_intb_clear();
      join
    end
  endtask : wait_for_one_conversion_to_finish

  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction

endclass : `TESTNAME
