/*--------------------------------------------------------------------------------------
// Copyright 2021 Nanochap, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_eegfilter_reg_rst_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_eegfilter_reg_rst_test                                             
// Designer	: ophina@nanochap.com                                                                 
// Date		: 05-09-2025                                                                     
// Revision	: 0.1 Initial version created by script                                 
--------------------------------------------------------------------------------------*/
`define TESTNAME soc_eegfilter_reg_rst_test
`define TESTCFG soc_eegfilter_reg_rst_test_cfg

class `TESTCFG extends soc_eegfilter_base_test_cfg;

  `nnc_object_utils(`TESTCFG)

  // -----------------------------------------------
  // End of decalration of new variables 
  // -----------------------------------------------
  rand logic [15:0] no_of_samples;

  function new (string name = "soc_eegfilter_reg_rst_test_cfg");
    super.new(name);
  endfunction: new

  // -----------------------------------------------
  // Adding constraints of randomization
  // -----------------------------------------------
  constraint c_no_of_conversions   {  no_of_samples  inside {[7:15]} ;} 

  constraint c_imeas_en_dis_ch   {  imeas_en_dis_ch == 16'h0 ;} // atlist 1 channel should be enabled 

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
    //uvm_top.set_timeout(20ms);
    top_test_cfg = `TESTCFG::type_id::create("top_test_cfg", this);
  endfunction

  virtual task pre_reset_phase(nnc_phase phase);
    phase.raise_objection(this);

    super.pre_reset_phase(phase);

    assert(top_test_cfg.randomize());
    //`DUT_IF.imeas_en         = 1;
    //`DUT_IF.single_shot_en   = 0;
    `DUT_IF.imeas_en_dis_ch = top_test_cfg.imeas_en_dis_ch;

    `IMEAS_SCB_EN = 1'b1;

    phase.drop_objection(this);
  endtask : pre_reset_phase

  virtual task main_phase(uvm_phase phase);
    int random_delay;
    int prev_no_of_conversions;

    phase.raise_objection(this);

    `nnc_info("SOC_TEST", "soc_eegfilter_reg_rst_test start", UVM_LOW)

    `nnc_info("SOC_TEST", $sformatf("soc_eegfilter_reg_rst_test :: imeas_en=%0d ,single_shot_en=%0d ", `DUT_IF.imeas_en,`DUT_IF.single_shot_en), UVM_LOW)

    imeas_config();

    fork
      begin
        // start basic traffic 
        start_conversion();
      end

      begin
        wait(`IMEAS_WRAPPER_TOP.meas_done_pos === 1);
        wait(`IMEAS_WRAPPER_TOP.meas_done_pos === 0);
	`nnc_info("SOC_TEST", $sformatf("conversion wait done"), UVM_LOW)
      end
    join

   // if(`DUT_IF.imeas_en === 0)begin // single-shot or continous conversion
   //   // Start/Restart (Synchronize) Conversion in single-shot mode
   //   `DUT_IF.cmd = `STOP_CMD;
   //   assert(top_test_cfg.randomize() with { reg_addr == `SOC_IMEAS_REG_2; wr_data[0] == {5'h0,`DUT_IF.cmd};});
   //   `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
   //   `nnc_info("SOC_TEST", "Send stop cmd for single shot enable", UVM_LOW)
   // end

    `nnc_info("SOC_TEST", $sformatf("************************* WILL ASSERT IMEAS REG RESET *********************"), UVM_LOW)
    //Apply Imeas filter reg reset
    `DUT_IF.imeas_rst = 1'b1;
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_IMEAS_REG_0; wr_data[0] == {`DUT_IF.output_format,2'b0,`DUT_IF.imeas_adc_inv,`DUT_IF.input_format,`DUT_IF.imeas_rst,`DUT_IF.imeas_en};});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    `nnc_info("SOC_TEST", $sformatf("************************* IMEAS REG RESET APPLIED *********************"), UVM_LOW)

    wait_for_intb_clear ();
    check_int_sts_reg(0); // check reg sts

    // check imeas_data after reset
    for (int i = 0; i < `FILTER_NUM ; i++)begin
      `DUT_IF.imeas_data_sel = i;
      compare_imeas_chdata (`DUT_IF.imeas_data_sel,0);
    end

    compare_imeas_chdata_through_rdata_cmd(0);

    random_delay = $urandom_range(100000,1000000);
    #random_delay;

    //remove Imeas filter reg reset
    `DUT_IF.imeas_rst = 1'b0;
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_IMEAS_REG_0; wr_data[0] == {`DUT_IF.output_format,2'b0,`DUT_IF.imeas_adc_inv,`DUT_IF.input_format,`DUT_IF.imeas_rst,`DUT_IF.imeas_en};});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    `nnc_info("SOC_TEST", $sformatf("************************* IMEAS REG RESET REMOVED ***********************"), UVM_LOW)

    //if(`DUT_IF.imeas_en === 0)begin // single-shot or continous conversion
    //  // Start/Restart (Synchronize) Conversion in single-shot/continous mode
    //  `DUT_IF.cmd = `START_CMD;
    //  assert(top_test_cfg.randomize() with { reg_addr == `SOC_IMEAS_REG_2; wr_data[0] == {5'h0,`DUT_IF.cmd};});
    //  `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    //  `nnc_info("SOC_TEST", "Send start cmd for single shot enable", UVM_LOW)
    //end

    if(`DUT_IF.imeas_en === 0)top_test_cfg.no_of_samples = 1;
    `nnc_info("SOC_TEST", $sformatf("wait for %0d no of samples done after reset !!!",top_test_cfg.no_of_samples),UVM_LOW)

    prev_no_of_conversions = `DUT_IF.no_of_samples_rcvd ;
    wait(`DUT_IF.no_of_samples_rcvd === prev_no_of_conversions + top_test_cfg.no_of_samples);
    `nnc_info("SOC_TEST", "Measurement is done!!!", UVM_LOW)
    
    // Stop conversion for single-shot or continuos
    stop_conversion();

    wait_for_one_conversion_to_finish();

    //clear_int_sts_reg();

    // check imeas_data after conversion stops
    for (int i = 0; i < `FILTER_NUM ; i++)begin
      `DUT_IF.imeas_data_sel = i;
      compare_imeas_chdata (`DUT_IF.imeas_data_sel,0);
    end

    //compare_imeas_chdata_through_rdata_cmd(0);

    #1ms;

    `nnc_info("SOC_TEST", "soc_eegfilter_reg_rst_test end now", UVM_LOW)
    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ----------------------------------------------------------------------------------

    phase.drop_objection(this);
  endtask: main_phase

  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction
endclass : `TESTNAME
