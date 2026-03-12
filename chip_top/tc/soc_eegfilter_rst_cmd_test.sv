/*--------------------------------------------------------------------------------------
// Copyright 2021 Nanochap, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_eegfilter_rst_cmd_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_eegfilter_rst_cmd_test                                             
// Designer	: ophina@nanochap.com                                                                 
// Date		: 18-09-2025                                                                     
// Revision	: 0.1 Initial version created by script                                 
--------------------------------------------------------------------------------------*/
`define TESTNAME soc_eegfilter_rst_cmd_test
`define TESTCFG soc_eegfilter_rst_cmd_test_cfg

class `TESTCFG extends soc_eegfilter_base_test_cfg;

  `nnc_object_utils(`TESTCFG)

  // -----------------------------------------------
  // End of decalration of new variables 
  // -----------------------------------------------
  rand logic [15:0] no_of_samples;

  function new (string name = "soc_eegfilter_rst_cmd_test_cfg");
    super.new(name);
  endfunction: new

  // -----------------------------------------------
  // Adding constraints of randomization
  // -----------------------------------------------
  constraint c_no_of_conversions   {  no_of_samples  inside {[7:15]} ;} 

  constraint c_iclk_sel            { iclk_sel inside {[2:2]};}

  constraint c_stable_time         { stable_time inside {[70:100]};}

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
    `DUT_IF.imeas_en_dis_ch = top_test_cfg.imeas_en_dis_ch;

    `IMEAS_SCB_EN = 1'b1;

    phase.drop_objection(this);
  endtask : pre_reset_phase

  virtual task main_phase(uvm_phase phase);
    int random_delay;
    int prev_no_of_conversions;

    phase.raise_objection(this);

    `nnc_info("SOC_TEST", "soc_eegfilter_rst_cmd_test start", UVM_LOW)

    `nnc_info("SOC_TEST", $sformatf("soc_eegfilter_rst_cmd_test :: imeas_en=%0d ,single_shot_en=%0d ", `DUT_IF.imeas_en,`DUT_IF.single_shot_en), UVM_LOW)

    imeas_config();

    // start basic traffic 
    start_conversion();

    repeat(2) #imeas_clk_period;//wait atleast 2 adc clks before applying reset cmd
    random_delay = $urandom_range(50000,1000000);
    `nnc_info("SOC_TEST", $sformatf("************************* WILL ASSERT IMEAS RESET CMD *********************"), UVM_LOW)
    #random_delay;
    //Apply Imeas filter rst cmd
    `DUT_IF.cmd = `RESET_CMD;
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_IMEAS_REG_2; wr_data[0] == {5'h0,`DUT_IF.cmd};});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    `nnc_info("SOC_TEST", "Send filter reset cmd", UVM_LOW)

    prev_no_of_conversions = `DUT_IF.no_of_samples_rcvd ;
    wait_for_intb_clear ();
    check_int_sts_reg(0); // check reg sts

    // ******* commented temporary as for imeas_en=0 case, conversion starts automatically after rst cmd,
    // by the time imeas data is compared with reset val, data will change  ******** 
    //`DUT_IF.imeas_data_sel = $urandom_range(0,`FILTER_NUM - 1);
    //compare_imeas_chdata (`DUT_IF.imeas_data_sel,1);

    if(`DUT_IF.imeas_en === 0)begin // single-shot or continous conversion
      // Start/Restart (Synchronize) Conversion in single-shot/continous mode
      `DUT_IF.cmd = `START_CMD;
      assert(top_test_cfg.randomize() with { reg_addr == `SOC_IMEAS_REG_2; wr_data[0] == {5'h0,`DUT_IF.cmd};});
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
      `nnc_info("SOC_TEST", "Send start cmd for single shot enable", UVM_LOW)
       top_test_cfg.no_of_samples = 1;
    end

    `nnc_info("SOC_TEST", $sformatf("wait for %0d no of samples done after reset !!!",top_test_cfg.no_of_samples),UVM_LOW)
    wait(`DUT_IF.no_of_samples_rcvd === prev_no_of_conversions + top_test_cfg.no_of_samples);
    `nnc_info("SOC_TEST", "Measurement is done!!!", UVM_LOW)
    
    //clear_int_sts_reg();
    // Stop conversion for single-shot or continuos
    stop_conversion();

    wait_for_one_conversion_to_finish();

    // check imeas_data after conversion stops
    for (int i = 0; i < `FILTER_NUM ; i++)begin
      `DUT_IF.imeas_data_sel = i;
      compare_imeas_chdata (`DUT_IF.imeas_data_sel,0);
    end

    `nnc_info("SOC_TEST", "soc_eegfilter_rst_cmd_test end now", UVM_LOW)
    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ----------------------------------------------------------------------------------

    phase.drop_objection(this);
  endtask: main_phase

  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction
endclass : `TESTNAME
