/*--------------------------------------------------------------------------------------
// Copyright 2021 Nanochap, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_eegfilter_continuos_sine_wave_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_eegfilter_continuos_sine_wave_test                                             
// Designer	: shreeyal@nanochap.com                                                                 
// Date		: 05-09-2025                                                                     
// Revision	: 0.1 Initial version created by script                                 
--------------------------------------------------------------------------------------*/
`define TESTNAME soc_eegfilter_continuos_sine_wave_test
`define TESTCFG soc_eegfilter_continuos_sine_wave_test_cfg

class `TESTCFG extends soc_eegfilter_base_test_cfg;

  `nnc_object_utils(`TESTCFG)

  // -----------------------------------------------
  // End of decalration of new variables 
  // -----------------------------------------------
  real              sine_input_freq;
  int               no_of_samples_per_period;
  int               no_of_samples;

  function new (string name = "soc_eegfilter_continuos_sine_wave_test_cfg");
    super.new(name);
  endfunction: new

  // -----------------------------------------------
  // Adding constraints of randomization
  // -----------------------------------------------
 constraint c_iclk_sel            { iclk_sel inside {[2:5]}; // fast adc_clk  256Khz to 2Mhz. (real sdm analog supports upto 2Mhz adc clk only)
                                     solve imeas_cic_rate before iclk_sel;
                                     (imeas_cic_rate >=3) ->  iclk_sel == 2;}

  constraint c_spi_sclk_freq       { solve iclk_sel before spi_sclk_freq; spi_sclk_freq > (8192/(2**iclk_sel));} // spi clk always faster than adc_clk

  constraint c_imeas_en            { imeas_en inside {0,1}; } // 1. imeas_en=1 (always continous mode) , 1. imeas_en=0,single_shot_en=0 (also continuos mode)  

  constraint c_single_shot_en      { single_shot_en == 0; }

  constraint c_imeas_cic_rate      { imeas_cic_rate inside {[0:6]};} // upto 512 only considered

  //constraint c_no_of_conversions   {  no_of_samples  == 64; } // 2*32; atleast 2 sine wave

  constraint c_imeas_sin_gen_en    { imeas_sin_gen_en == 1'b1; }//generate sdm adc sine

  constraint c_imeas_sin_freq_unit { imeas_sin_freq_unit == 1000; }//sine frequency precision 1000: imeas_sin_expected_freq in Hz/1000

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
    `DUT_IF.imeas_sin_gen_en = top_test_cfg.imeas_sin_gen_en;
    `DUT_IF.imeas_sin_freq_unit = top_test_cfg.imeas_sin_freq_unit;
    `DUT_IF.imeas_sin_expected_freq = top_test_cfg.imeas_sin_expected_freq;
    `DUT_IF.imeas_sin_no_clk_per_period = top_test_cfg.imeas_sin_no_clk_per_period;
    `DUT_IF.imeas_en_dis_ch = top_test_cfg.imeas_en_dis_ch;

    top_test_cfg.sine_input_freq = real'(`DUT_IF.imeas_sin_expected_freq)/real'(`DUT_IF.imeas_sin_freq_unit);
    `nnc_info("SOC_TEST", $sformatf("input sine frequency: (%0f)",top_test_cfg.sine_input_freq),UVM_LOW)
    top_test_cfg.no_of_samples_per_period = (`DUT_IF.imeas_samp_rate * `DUT_IF.imeas_sin_freq_unit) / `DUT_IF.imeas_sin_expected_freq;
    `nnc_info("SOC_TEST", $sformatf("no_of_samples_per_period: (%d)",top_test_cfg.no_of_samples_per_period),UVM_LOW)
    `DUT_IF.imeas_sample_num_per_period = top_test_cfg.no_of_samples_per_period;
    top_test_cfg.no_of_samples = `DUT_IF.imeas_sample_num_per_period * 2;//2 sine length
    `DUT_IF.python_imeas_length = top_test_cfg.no_of_samples;//default python_imeas_length is 1024

    phase.drop_objection(this);
  endtask : pre_reset_phase

  virtual task main_phase(uvm_phase phase);
    phase.raise_objection(this);

    `nnc_info("SOC_TEST", "soc_eegfilter_continuos_sine_wave_test start", UVM_LOW)
    imeas_config();

    `DUT_IF.python_imeas_en = 1'b1;
    fork 
      begin
        // Start/Restart (Synchronize) Conversion in single-shot/continous mode
        start_conversion();
      end
      begin
        `nnc_info("SOC_TEST", $sformatf("wait for %0d no of samples done!!!",top_test_cfg.no_of_samples),UVM_LOW)
        //for(int i = 0; i < top_test_cfg.no_of_samples ; i++) begin
          //wait(`IMEAS_WRAPPER_TOP.meas_done_pos === 1);
          //wait(`IMEAS_WRAPPER_TOP.meas_done_pos === 0);
	//  wait_for_intb();
	//  clear_int_sts_reg();

        //  `nnc_info("SOC_TEST", $sformatf("%0d conversion done ! ", i),UVM_LOW)
        //end
        wait(`DUT_IF.no_of_samples_rcvd === top_test_cfg.no_of_samples);
        `nnc_info("SOC_TEST", "Measurement is done!!!", UVM_LOW)
      end
    join

    // Stop conversion for single-shot or continuos
    stop_conversion();

    // to wait for ongoing conversion to finish before reading imeas data
    `nnc_info("TEST", $sformatf("will wait for one_conversion_period =%0f(ns)", (one_conversion_period*1000)),NNC_LOW)
    #(one_conversion_period*1000); // ns
    `nnc_info("SOC_TEST", "wait done for one conversion after stop cmd", UVM_LOW)

    for (int i = 0; i < `FILTER_NUM ; i++)begin
      `DUT_IF.imeas_data_sel = i;
      compare_imeas_chdata (`DUT_IF.imeas_data_sel,0);
    end

    //wait_for_intb();

    `DUT_IF.eeg_int_en = 0;
    top_test_cfg.wr_data[0] = {6'b0,`DUT_IF.eeg_int_sts_en,`DUT_IF.eeg_int_en};
    `WR_NORMAL_REG(`SOC_FILTER_INT_CTRL_REG, top_test_cfg.wr_data[0], top_test_cfg.pads);

    wait_for_intb_clear ();
    check_int_sts_reg(1); // still sts should stay enabled

    `DUT_IF.eeg_int_sts_en = 0;
    top_test_cfg.wr_data[0] = {6'b0,`DUT_IF.eeg_int_sts_en,`DUT_IF.eeg_int_en};
    `WR_NORMAL_REG(`SOC_FILTER_INT_CTRL_REG, top_test_cfg.wr_data[0], top_test_cfg.pads);
    wait(`FILTER_WRAPPER_TOP.eeg_int_sts === 0);
    check_int_sts_reg(0); //  sts should disabled

    `nnc_info("SOC_TEST", "soc_eegfilter_continuos_sine_wave_test end now", UVM_LOW)
    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ----------------------------------------------------------------------------------

    phase.drop_objection(this);
  endtask: main_phase

  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction
endclass : `TESTNAME
