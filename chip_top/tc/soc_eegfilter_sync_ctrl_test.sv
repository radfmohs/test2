/*--------------------------------------------------------------------------------------
// Copyright 2021 Nanochap, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_eegfilter_sync_ctrl_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_eegfilter_sync_ctrl_test                                             
// Designer	: shreeyal@nanochap.com                                                                 
// Date		: 04-05-2026                                                                     
// Revision	: 0.1 Initial version created by script                                 
--------------------------------------------------------------------------------------*/
`define TESTNAME soc_eegfilter_sync_ctrl_test
`define TESTCFG soc_eegfilter_sync_ctrl_test_cfg

class `TESTCFG extends soc_eegfilter_rdata_cmd_test_cfg;

  `nnc_object_utils(`TESTCFG)

  // -----------------------------------------------
  // Adding your new varialbles in config test
  // -----------------------------------------------
 
  rand bit [23:0] filter_dly_val;
  rand bit        filter_sync_en; 
  rand logic      sar_adc_bypass_pull_src_from_wg; 

  // -----------------------------------------------
  // End of decalration of new variables 
  // -----------------------------------------------

  function new (string name = "soc_eegfilter_sync_ctrl_test_cfg");
    super.new(name);
  endfunction: new

  // -----------------------------------------------
  // Adding constraints of randomization
  // -----------------------------------------------

  constraint c_filter_dly_val       { filter_dly_val inside {['hF:'h3FFF]}; }

  constraint c_filter_sync_en       { filter_sync_en inside {[0:1]}; }

  constraint c_imeas_status_en     { imeas_status_en inside {1,1}; } 

  // SAR VIP Constraints
  // enable the stimulation from ana model
  constraint c_sar_adc_sine_wave_en     { sar_adc_sine_wave_en == 1'b1; } // Sine is enable

  constraint c_sar_adc_sine_wave_freq   { sar_adc_sine_wave_freq == 10000; } // 10Khz

  constraint c_sar_adc_vin              { sar_adc_vin == 1000; } // 1000mV

  constraint c_sar_adc_data_timing_t1   { sar_adc_data_timing_t1 inside {[5: 250*75/100 -5]};} // 75% of 4Mhz = 250*0.75 (margin 5ns)

  constraint c_sar_adc_data_timing_t2   { sar_adc_data_timing_t2 inside {[5: 250*25/100 -5]};} // 25% of 4Mhz = 250*0.25 (margin 5ns)

  constraint c_sar_adc_bypass_pull_src_from_wg { sar_adc_bypass_pull_src_from_wg == 1'b1;}
  // -----------------------------------------------
  // End of adding constraints of randomization
  // -----------------------------------------------

endclass : `TESTCFG

class `TESTNAME extends soc_eegfilter_rdata_cmd_test;
   
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

    `DUT_IF.filter_dly_val = top_test_cfg.filter_dly_val;
    `DUT_IF.filter_sync_en = top_test_cfg.filter_sync_en;

    `DUT_IF.imeas_status_en= top_test_cfg.imeas_status_en;

    `DUT_IF.sar_adc_sine_wave_en = top_test_cfg.sar_adc_sine_wave_en;

    `DUT_IF.sar_adc_sine_wave_freq = top_test_cfg.sar_adc_sine_wave_freq;

    `DUT_IF.sar_adc_vin = top_test_cfg.sar_adc_vin;

    `DUT_IF.sar_adc_data_timing_t1 = top_test_cfg.sar_adc_data_timing_t1;

    `DUT_IF.sar_adc_data_timing_t2 = top_test_cfg.sar_adc_data_timing_t2;

    `DUT_IF.sar_adc_bypass_pull_src_from_wg = top_test_cfg.sar_adc_bypass_pull_src_from_wg;


    phase.drop_objection(this);
  endtask : pre_reset_phase

  virtual task main_phase(uvm_phase phase);
    phase.raise_objection(this);

    // ----------------------------------------------------------------------------------
    // Please add your code of your test here
    // ----------------------------------------------------------------------------------
    `nnc_info("SOC_TEST", "soc_eegfilter_sync_ctrl_test starts", NNC_LOW)

    // configure filter delay tgt value
    `WR_NORMAL_REG(`SOC_FILTER_DLY_TGT_0_REG, `DUT_IF.filter_dly_val[7:0], top_test_cfg.pads);
    `WR_NORMAL_REG(`SOC_FILTER_DLY_TGT_1_REG, `DUT_IF.filter_dly_val[15:8], top_test_cfg.pads);
    `WR_NORMAL_REG(`SOC_FILTER_DLY_TGT_2_REG, `DUT_IF.filter_dly_val[23:16], top_test_cfg.pads);
    
    // enable filter_sync_en
    `WR_NORMAL_REG(`SOC_FILTER_SYNC_CTRL_REG, {7'b0,`DUT_IF.filter_sync_en}, top_test_cfg.pads);

    // enable wavegen global_drive_en
    `WR_NORMAL_REG(`SOC_WAVEGEN_GLOBAL_REG, {7'b0,1'b1}, top_test_cfg.pads);
  
    // setup and start eeg conversions
    super.main_phase(phase);

    // apply wavegen reset
    `WR_NORMAL_REG(`SOC_PMU_REG, {2'b0,1'b1,5'b0}, top_test_cfg.pads);

     #10ns;

    // remove wavegen reset
    `WR_NORMAL_REG(`SOC_PMU_REG, {2'b0,1'b0,5'b0}, top_test_cfg.pads);

    // again start eeg conversions
    //basic_traffic_with_multi_start_stop();
    super.main_phase(phase);

    `nnc_info("SOC_TEST", "soc_eegfilter_sync_ctrl_test end now", NNC_LOW)
    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ----------------------------------------------------------------------------------

    phase.drop_objection(this);
  endtask: main_phase

endclass : `TESTNAME
