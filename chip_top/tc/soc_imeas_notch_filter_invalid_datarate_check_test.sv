/*--------------------------------------------------------------------------------------
// Copyright 2021 Nanochap, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_imeas_notch_filter_invalid_datarate_check_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_imeas_notch_filter_invalid_datarate_check_test                                             
// Designer	: shreeyal@nanochap.com                                                                 
// Date		: 10-11-2025                                                                     
// Revision	: 0.1 Initial version created by script                                 
--------------------------------------------------------------------------------------*/
`define TESTNAME soc_imeas_notch_filter_invalid_datarate_check_test
`define TESTCFG soc_imeas_notch_filter_invalid_datarate_check_test_cfg

class `TESTCFG extends soc_imeas_notch_filter_base_test_cfg;

  `nnc_object_utils(`TESTCFG)

  // -----------------------------------------------
  // End of decalration of new variables 
  // -----------------------------------------------

  function new (string name = "soc_imeas_notch_filter_invalid_datarate_check_test_cfg");
    super.new(name);
  endfunction: new

  // -----------------------------------------------
  // Adding constraints of randomization
  // -----------------------------------------------
  constraint c_imeas_sin_expected_freq { imeas_sin_expected_freq inside {[40000 : 55000]};} //sine freq * 1000

  constraint c_imeas_cic_rate      { imeas_cic_rate inside {[0:13]};} // upto 512 only considered

  constraint c_iclk_sel            { solve imeas_cic_rate before iclk_sel;
                                     (imeas_cic_rate == 0)  ->  iclk_sel inside {[0:3]};
                                     (imeas_cic_rate == 1)  ->  iclk_sel inside {[0:2]};
                                     (imeas_cic_rate == 2)  ->  iclk_sel inside {[0:1]};
                                     (imeas_cic_rate == 3)  ->  iclk_sel inside {0,11};
                                     (imeas_cic_rate == 4)  ->  iclk_sel inside {[10:11]};
                                     (imeas_cic_rate == 5)  ->  iclk_sel inside {[9:11]};
                                     (imeas_cic_rate == 6)  ->  iclk_sel inside {[8:11]};
                                     (imeas_cic_rate == 7)  ->  iclk_sel inside {[7:11]};
                                     (imeas_cic_rate == 8)  ->  iclk_sel inside {[6:11]};
                                     (imeas_cic_rate == 9)  ->  iclk_sel inside {[5:11]};
                                     (imeas_cic_rate == 10) ->  iclk_sel inside {[4:11]};
                                     (imeas_cic_rate == 11) ->  iclk_sel inside {[3:11]};
                                     (imeas_cic_rate == 12) ->  iclk_sel inside {[2:11]};
                                     (imeas_cic_rate == 13) ->  iclk_sel inside {[1:11]};}

  constraint c_imeas_en_dis_ch   {  imeas_en_dis_ch == 16'h0 ;} // all imeas eeg channel enabled 

  constraint c_notch_filter_en_per_ch   {  notch_filter_en_per_ch == 16'h0 ;} // all notch filter channels enabled

  constraint c_sine_num_of_period   {  sine_num_of_period == 10; }  

  // -----------------------------------------------
  // End of adding constraints of randomization
  // -----------------------------------------------

endclass : `TESTCFG

class `TESTNAME extends soc_imeas_notch_filter_base_test;
   
  `nnc_component_utils(`TESTNAME)

  `TESTCFG top_test_cfg;

  function new(string name, nnc_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(nnc_phase phase);
    super.build_phase(phase);
    uvm_top.set_timeout(2s);
    //uvm_top.set_timeout(400ms);
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
    `DUT_IF.notch_filter_en_per_ch = top_test_cfg.notch_filter_en_per_ch;
    `DUT_IF.notch_filter_data_gone = top_test_cfg.notch_filter_data_gone;
    `DUT_IF.notch_coeff_index_select = top_test_cfg.notch_coeff_index_select;

    rdatac_cmd_en = 1;
    `DUT_IF.filter_case = top_test_cfg.filter_case;
    `DUT_IF.filter_python_check_en = 0;

    phase.drop_objection(this);
  endtask : pre_reset_phase

  virtual task main_phase(uvm_phase phase);
    phase.raise_objection(this);

    `nnc_info("SOC_TEST", "soc_imeas_notch_filter_invalid_datarate_check_test start", UVM_LOW)

    top_test_cfg.sine_input_freq = real'(`DUT_IF.imeas_sin_expected_freq)/real'(`DUT_IF.imeas_sin_freq_unit);
    `nnc_info("SOC_TEST", $sformatf("input sine frequency: (%0f)",top_test_cfg.sine_input_freq),UVM_LOW)
    top_test_cfg.no_of_samples_per_period = (`DUT_IF.imeas_samp_rate * `DUT_IF.imeas_sin_freq_unit) / `DUT_IF.imeas_sin_expected_freq;
    `nnc_info("SOC_TEST", $sformatf("no_of_samples_per_period: (%d)",top_test_cfg.no_of_samples_per_period),UVM_LOW)
    `DUT_IF.imeas_sample_num_per_period = top_test_cfg.no_of_samples_per_period;
    //`DUT_IF.no_of_samples = `DUT_IF.imeas_sample_num_per_period * 30;//2 sine length
    `DUT_IF.no_of_samples = `DUT_IF.imeas_sample_num_per_period * top_test_cfg.sine_num_of_period;//2 sine length
    `DUT_IF.python_imeas_length = `DUT_IF.no_of_samples;//default python_imeas_length is 1024

    imeas_config();

    top_test_cfg.wr_data[0] = `DUT_IF.notch_filter_data_gone[7:0];
    `WR_NORMAL_REG(`SOC_FILTER_NOTCH_DATA_GONE_L_REG, top_test_cfg.wr_data[0], top_test_cfg.pads);

    top_test_cfg.wr_data[0] = `DUT_IF.notch_filter_data_gone[15:8];
    `WR_NORMAL_REG(`SOC_FILTER_NOTCH_DATA_GONE_H_REG, top_test_cfg.wr_data[0], top_test_cfg.pads);

    top_test_cfg.wr_data[0] = `DUT_IF.notch_filter_en_per_ch[7:0];
    `WR_NORMAL_REG(`SOC_FILTER_NOF_BP_L_REG, top_test_cfg.wr_data[0], top_test_cfg.pads);

    top_test_cfg.wr_data[0] = `DUT_IF.notch_filter_en_per_ch[15:8];
    `WR_NORMAL_REG(`SOC_FILTER_NOF_BP_H_REG, top_test_cfg.wr_data[0], top_test_cfg.pads);

    fork
      begin
        //check notch clk each intr, notch clk should not be generated 
        @(`DUT_IF.notch_clk);
	`nnc_error("TEST", $sformatf("ERROR:: NOTCH CLK enabled=%0b for invalid datarate = (%0f)Hz, iclk_div=%0d, cic_rate_sel=%0d", `DUT_IF.notch_clk,`DUT_IF.imeas_samp_rate,`DUT_IF.iclk_sel,`DUT_IF.cic_rate))
      end
    join_none

    fork 
      begin
        // Start/Restart (Synchronize) Conversion in single-shot/continous mode
        start_conversion();
      end
      begin
        // send RDATA cmd
        `nnc_info("SOC_TEST", $sformatf("wait for %0d no of samples done!!!",`DUT_IF.no_of_samples),UVM_LOW)
	wait_for_intb();
	compare_imeas_chdata_through_rdata_cmd(0);
        `nnc_info("SOC_TEST", "Measurement is done!!!", UVM_LOW)
      end
    join

    // Stop conversion for single-shot or continuos
    stop_conversion();


    `nnc_info("SOC_TEST", "soc_imeas_notch_filter_invalid_datarate_check_test end now", UVM_LOW)
    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ----------------------------------------------------------------------------------

    phase.drop_objection(this);
  endtask: main_phase

  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction
endclass : `TESTNAME
