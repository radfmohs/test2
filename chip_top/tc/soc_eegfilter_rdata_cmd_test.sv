/*--------------------------------------------------------------------------------------
// Copyright 2021 Nanochap, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_eegfilter_rdata_cmd_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_eegfilter_rdata_cmd_test                                             
// Designer	: shreeyal@nanochap.com                                                                 
// Date		: 05-09-2025                                                                     
// Revision	: 0.1 Initial version created by script                                 
--------------------------------------------------------------------------------------*/
`define TESTNAME soc_eegfilter_rdata_cmd_test
`define TESTCFG soc_eegfilter_rdata_cmd_test_cfg

class `TESTCFG extends soc_eegfilter_base_test_cfg;

  `nnc_object_utils(`TESTCFG)

  // -----------------------------------------------
  // End of decalration of new variables 
  // -----------------------------------------------

  function new (string name = "soc_eegfilter_rdata_cmd_test_cfg");
    super.new(name);
  endfunction: new

  // -----------------------------------------------
  // Adding constraints of randomization
  // -----------------------------------------------

  constraint c_imeas_en            { imeas_en inside {0,1}; } // 1. imeas_en=1 (always continous mode) , 1. imeas_en=0,single_shot_en=0 (also continuos mode)  

  constraint c_single_shot_en      { single_shot_en == 0; }

  constraint c_imeas_en_dis_ch     {  imeas_en_dis_ch == 'h0 ;} // all channels enabled 

  constraint c_iclk_sel            { iclk_sel inside {[3:3]};} 

  constraint c_spi_sclk_freq       { spi_sclk_freq == 20000;} 

  constraint c_imeas_cic_rate      { imeas_cic_rate == 5; }

  constraint c_no_of_samples       {  no_of_samples  inside {[10:20]}; }  

  constraint c_no_of_adc_dev1      {  no_of_adc_dev1 inside {[0:7]};} // 0:2, 1:4, 2:6, 3:8, 4:10, 5:12, 6:14, 7:16

  constraint c_imeas_status_en     { imeas_status_en inside {0,1}; } // default no Imeas status
 
  constraint c_imeas_24bitdata_en  { imeas_24bitdata_en inside {0,1}; }// default 32 bit data

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
    //uvm_top.set_timeout(2s);
    uvm_top.set_timeout(10ms);
    top_test_cfg = `TESTCFG::type_id::create("top_test_cfg", this);
  endfunction

  virtual task pre_reset_phase(nnc_phase phase);
    phase.raise_objection(this);

    super.pre_reset_phase(phase);

    assert(top_test_cfg.randomize());

    `DUT_IF.imeas_en         = top_test_cfg.imeas_en;
    `DUT_IF.single_shot_en   = top_test_cfg.single_shot_en;

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

    `DUT_IF.imeas_sin_freq_unit = top_test_cfg.imeas_sin_freq_unit;
    `DUT_IF.imeas_sin_expected_freq = top_test_cfg.imeas_sin_expected_freq;
    `DUT_IF.imeas_sin_no_clk_per_period = top_test_cfg.imeas_sin_no_clk_per_period;

    `DUT_IF.imeas_en_dis_ch = top_test_cfg.imeas_en_dis_ch;
    `DUT_IF.daisy_en = top_test_cfg.daisy_en;

    `DUT_IF.mult_chip_en = top_test_cfg.mult_chip_en;
    `DUT_IF.mult_chip_same_clk_en = top_test_cfg.mult_chip_same_clk_en;
    `DUT_IF.no_of_samples = top_test_cfg.no_of_samples;
    `DUT_IF.no_of_adc_dev1 = top_test_cfg.no_of_adc_dev1;
    `DUT_IF.no_of_adc_dev2 = top_test_cfg.no_of_adc_dev2;

    `DUT_IF.imeas_status_en   = top_test_cfg.imeas_status_en   ;
    `DUT_IF.imeas_24bitdata_en= top_test_cfg.imeas_24bitdata_en;

    phase.drop_objection(this);
  endtask : pre_reset_phase

  virtual task main_phase(uvm_phase phase);
    phase.raise_objection(this);

    `nnc_info("SOC_TEST", "soc_eegfilter_rdata_cmd_test start", UVM_LOW)
     imeas_config();

    fork 
      begin
        // Start/Restart (Synchronize) Conversion in single-shot/continous mode
        start_conversion();
      end
      begin
        `nnc_info("SOC_TEST", $sformatf("wait for %0d no of samples done!!!",`DUT_IF.no_of_samples),UVM_LOW)
        repeat(`DUT_IF.no_of_samples)begin
	  wait_for_intb();
	  compare_imeas_chdata_through_rdata_cmd(0);
	  wait_for_intb_clear();
        end
        `nnc_info("SOC_TEST", "Measurement is done!!!", UVM_LOW)
      end
    join

    // Stop conversion for single-shot or continuos
    stop_conversion();

    `nnc_info("SOC_TEST", "soc_eegfilter_rdata_cmd_test end now", UVM_LOW)
    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ----------------------------------------------------------------------------------

    phase.drop_objection(this);
  endtask: main_phase

  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction
endclass : `TESTNAME
