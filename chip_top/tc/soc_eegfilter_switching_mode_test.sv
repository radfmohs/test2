/*--------------------------------------------------------------------------------------
// Copyright 2021 Nanochap, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_eegfilter_switching_mode_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_eegfilter_switching_mode_test                                             
// Designer	: shreeyal@nanochap.com                                                                 
// Date		: 05-09-2025                                                                     
// Revision	: 0.1 Initial version created by script                                 
--------------------------------------------------------------------------------------*/
`define TESTNAME soc_eegfilter_switching_mode_test
`define TESTCFG soc_eegfilter_switching_mode_test_cfg

class `TESTCFG extends soc_eegfilter_base_test_cfg;

  `nnc_object_utils(`TESTCFG)

  // -----------------------------------------------
  // End of decalration of new variables 
  // -----------------------------------------------
  rand logic [15:0] no_of_samples;

  function new (string name = "soc_eegfilter_switching_mode_test_cfg");
    super.new(name);
  endfunction: new

  // -----------------------------------------------
  // Adding constraints of randomization
  // -----------------------------------------------
  constraint c_imeas_en            { imeas_en inside {0,1}; } // 1. imeas_en=1 (always continous mode) , 1. imeas_en=0,single_shot_en=0 (also continuos mode)  

  constraint c_single_shot_en      { single_shot_en inside {0,1}; }

  constraint c_no_of_conversions   {  no_of_samples  inside {[3:5]};} // 

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
    //uvm_top.set_timeout(10ms);
    uvm_top.set_timeout(2s);
    top_test_cfg = `TESTCFG::type_id::create("top_test_cfg", this);
  endfunction

  virtual task pre_reset_phase(nnc_phase phase);
    phase.raise_objection(this);

    super.pre_reset_phase(phase);

    assert(top_test_cfg.randomize());

    `DUT_IF.imeas_en         = top_test_cfg.imeas_en;
    `DUT_IF.imeas_rst        = top_test_cfg.imeas_rst;
    `DUT_IF.imeas_adc_inv    = top_test_cfg.imeas_adc_inv;
    `DUT_IF.input_format     = top_test_cfg.input_format;
    `DUT_IF.output_format    = top_test_cfg.output_format;
    `DUT_IF.cmd              = top_test_cfg.cmd;
    `DUT_IF.stable_time      = top_test_cfg.stable_time;
    `DUT_IF.imeas_data_sel   = top_test_cfg.imeas_data_sel;
    `DUT_IF.single_shot_en   = top_test_cfg.single_shot_en;
    `DUT_IF.iclk_pmu_ctrl_en = top_test_cfg.iclk_pmu_ctrl_en;

    // Set PCLK Clocks
    `DUT_IF.pclk_sel = top_test_cfg.pclk_sel;
    `DUT_IF.otp_tPGM = top_test_cfg.otp_tPGM;
    `DUT_IF.otp_tVPP = top_test_cfg.otp_tVPP;

    // Set SCLK clock
    `DUT_IF.spi_sclk_freq = top_test_cfg.spi_sclk_freq;
    // Set Jitter for PCLK 
    `DUT_IF.spi_clk_jitter = top_test_cfg.spi_clk_jitter;
    // Set Jitter for SCK
    `DUT_IF.spi_sclk_jitter  = top_test_cfg.spi_sclk_jitter;
    `DUT_IF.hfosc_jitter = top_test_cfg.hfosc_jitter;
    `DUT_IF.hfosc_variation = top_test_cfg.hfosc_variation;

    `DUT_IF.tcssc    = top_test_cfg.tcssc;
    `DUT_IF.tsccs    = top_test_cfg.tsccs;
    `DUT_IF.tcsh     = top_test_cfg.tcsh;
    `DUT_IF.tdist    = top_test_cfg.tdist;  
    `DUT_IF.tch      = top_test_cfg.tch;

    `DUT_IF.iclk_sel        = top_test_cfg.iclk_sel;
    `DUT_IF.imeas_adc_freq  = top_test_cfg.imeas_adc_freq;
    `DUT_IF.cic_rate        = top_test_cfg.imeas_cic_rate;
    `DUT_IF.imeas_osr       = top_test_cfg.imeas_osr;
    `DUT_IF.imeas_samp_rate = top_test_cfg.imeas_samp_rate;
    `DUT_IF.imeas_en_dis_ch = top_test_cfg.imeas_en_dis_ch;

    phase.drop_objection(this);
  endtask : pre_reset_phase

  virtual task main_phase(uvm_phase phase);
    phase.raise_objection(this);

    `nnc_info("SOC_TEST", "soc_eegfilter_switching_mode_test start", UVM_LOW)
    imeas_config();

    fork 
      begin
	// Start/Restart (Synchronize) Conversion in single-shot/continous mode
        start_conversion();
      end
      begin
        if(`DUT_IF.single_shot_en === 1) top_test_cfg.no_of_samples = 1;
	`nnc_info("SOC_TEST", $sformatf("wait for %0d no of samples done!!!",top_test_cfg.no_of_samples),UVM_LOW)
        //for(int i = 0; i < top_test_cfg.no_of_samples ; i++) begin
        wait(`DUT_IF.no_of_samples_rcvd === top_test_cfg.no_of_samples);
          //wait(`IMEAS_WRAPPER_TOP.meas_done_pos === 1);
          //wait(`IMEAS_WRAPPER_TOP.meas_done_pos === 0);
	  //wait_for_intb();
	  //clear_int_sts_reg();

	  //`nnc_info("SOC_TEST", $sformatf("%0d conversion done ! ", i),UVM_LOW)
        //end
        `nnc_info("SOC_TEST", "Measurement is done!!!", UVM_LOW)
      end
    join

    // Stop conversion for single-shot or continuos
    stop_conversion();

    wait_for_one_conversion_to_finish();

    if(`DUT_IF.single_shot_en == 1 && `DUT_IF.imeas_en == 0)begin
      `DUT_IF.single_shot_en = 0;
      `DUT_IF.imeas_en = 1;
      `nnc_info("SOC_TEST", "switching single shot to continuous mode !!!", UVM_LOW)
    end
    else if(`DUT_IF.single_shot_en == 1 && `DUT_IF.imeas_en == 1) begin 
      `DUT_IF.single_shot_en = 1;
      `DUT_IF.imeas_en = 0;
      `nnc_info("SOC_TEST", "switching continuous to single shot mode !!!", UVM_LOW)
    end
    else if(`DUT_IF.single_shot_en == 0 && `DUT_IF.imeas_en == 0) begin 
      `DUT_IF.single_shot_en = 1;
      `DUT_IF.imeas_en = 0;
      `nnc_info("SOC_TEST", "switching continuous to single shot mode !!!", UVM_LOW)
    end
    else begin //(`DUT_IF.single_shot_en == 0 && `DUT_IF.imeas_en == 1) begin 
      `DUT_IF.single_shot_en = 1;
      `DUT_IF.imeas_en = 0;
      `nnc_info("SOC_TEST", "switching continuous to single shot mode !!!", UVM_LOW)
    end

    //Write SOC_IMEAS_CTRL_REG
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_IMEAS_CTRL_REG; wr_data[0] == {`DUT_IF.imeas_data_sel,`DUT_IF.single_shot_en,3'h0};});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // configure imeas format,rst and imeas_en
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_IMEAS_REG_0; wr_data[0] == {`DUT_IF.output_format,2'b0,`DUT_IF.imeas_adc_inv,`DUT_IF.input_format,`DUT_IF.imeas_rst,`DUT_IF.imeas_en};});//Select format
    //`WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    basic_traffic_with_multi_start_stop();

    `nnc_info("SOC_TEST", "soc_eegfilter_switching_mode_test end now", UVM_LOW)
    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ----------------------------------------------------------------------------------

    phase.drop_objection(this);
  endtask: main_phase

  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction
endclass : `TESTNAME
