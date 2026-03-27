/*--------------------------------------------------------------------------------------
// Copyright 2021 Nanochap, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_imeas_hpf_filter_base_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_imeas_hpf_filter_base_test                                             
// Designer	: shreeyal@nanochap.com                                                                 
// Date		: 10-11-2025                                                                     
// Revision	: 0.1 Initial version created by script                                 
--------------------------------------------------------------------------------------*/
`define TESTNAME soc_imeas_hpf_filter_base_test
`define TESTCFG soc_imeas_hpf_filter_base_test_cfg

`define DUMP_OPTIMIZE

class `TESTCFG extends soc_eegfilter_base_test_cfg;

  `nnc_object_utils(`TESTCFG)

  // -----------------------------------------------
  // End of decalration of new variables 
  // -----------------------------------------------
  rand bit [`FILTER_NUM-1:0]  hpf_filter_en_per_ch;
       real                   sine_input_freq;
       int                    no_of_samples_per_period;
       int                    no_of_samples;
       real                   hpf_cutoff_freq_fc;
  rand int                    hpf_coeff_index_0_select;
  rand int                    hpf_coeff_index_1_select;

  function new (string name = "soc_imeas_hpf_filter_base_test_cfg");
    super.new(name);
  endfunction: new

  // -----------------------------------------------
  // Adding constraints of randomization
  // -----------------------------------------------
 //constraint c_iclk_sel            { iclk_sel inside {[2:5]}; // fast adc_clk  256Khz to 2Mhz. (real sdm analog supports upto 2Mhz adc clk only)
 //                                    solve imeas_cic_rate before iclk_sel;
 //                                    (imeas_cic_rate >=3) ->  iclk_sel == 2;}
 //constraint c_iclk_sel            { iclk_sel == 3;}

  //constraint c_spi_sclk_freq       { solve iclk_sel before spi_sclk_freq; spi_sclk_freq > (8192/(2**iclk_sel));} // spi clk always faster than adc_clk
  constraint c_spi_sclk_freq       {spi_sclk_freq == 20000 ;} // spi clk always faster than adc_clk

  //constraint c_imeas_cic_rate      { imeas_cic_rate inside {[7:7]};} 

  constraint c_imeas_en            { imeas_en inside {0,1}; } // 1. imeas_en=1 (always continous mode) , 1. imeas_en=0,single_shot_en=0 (also continuos mode)  

  constraint c_single_shot_en      { single_shot_en == 0; }

  constraint c_imeas_cic_rate      { imeas_cic_rate inside {[0:13]};} // upto 512 only considered

  constraint c_iclk_sel             { solve imeas_cic_rate before iclk_sel;
                                     (imeas_cic_rate == 0) ->  iclk_sel inside {[4:11]};
                                     (imeas_cic_rate == 1) ->  iclk_sel inside {[3:11]};
                                     (imeas_cic_rate == 2) ->  iclk_sel inside {[2:11]};
                                     (imeas_cic_rate == 3) ->  iclk_sel inside {[1:10]};
                                     (imeas_cic_rate == 4) ->  iclk_sel inside {[0:9]};
                                     (imeas_cic_rate == 5) ->  iclk_sel inside {[0:8]};
                                     (imeas_cic_rate == 6) ->  iclk_sel inside {[0:7]};
                                     (imeas_cic_rate == 7) ->  iclk_sel inside {[0:6]};
                                     (imeas_cic_rate == 8) ->  iclk_sel inside {[0:5]};
                                     (imeas_cic_rate == 9) ->  iclk_sel inside {[0:4]};
                                     (imeas_cic_rate == 10) ->  iclk_sel inside {[0:3]};
                                     (imeas_cic_rate == 11) ->  iclk_sel inside {[0:2]};
                                     (imeas_cic_rate == 12) ->  iclk_sel inside {[0:1]};
                                     (imeas_cic_rate == 13) ->  iclk_sel inside {[0:0]};}

  constraint c_imeas_sin_gen_en    { imeas_sin_gen_en == 1'b1; }//generate sdm adc sine

  constraint c_imeas_sin_freq_unit { imeas_sin_freq_unit == 1000; }//sine frequency precision 1000: imeas_sin_expected_freq in Hz/1000

  //constraint c_imeas_sin_expected_freq{ imeas_sin_expected_freq == 1000;} // sine freq * 1000

  constraint c_imeas_en_dis_ch   {  imeas_en_dis_ch == 16'h0 ;} // atlist 1 channel should be enabled 

  constraint c_hpf_filter_en_per_ch   {  hpf_filter_en_per_ch inside {[16'h0 : 16'hFFFE]};} // randomize atlist one channel to all channels enable  

  constraint c_filter_case   {  filter_case == 1; }  

  //constraint c_hpf_cutoff_freq_fc   {  hpf_cutoff_freq_fc inside {0.2, 0.5, 1, 2, 5, 10}; }  

  constraint c_hpd_coeff_index_0_select {hpf_coeff_index_0_select inside {0, 1, 2, 3, 4, 5};}

  constraint c_hpf_coeff_index_1_select    {  solve imeas_samp_rate before hpf_coeff_index_1_select ;
                                             (imeas_samp_rate inside {[30:32]})      -> hpf_coeff_index_1_select == 0 ;   // 31.25
                                             (imeas_samp_rate inside {[62:64]})      -> hpf_coeff_index_1_select == 1 ;  // 62.5
                                             (imeas_samp_rate inside {[125:128]})    -> hpf_coeff_index_1_select == 2 ;  
                                             (imeas_samp_rate inside {[250:256]})    -> hpf_coeff_index_1_select == 3 ;  
                                             (imeas_samp_rate inside {[500:512]})    -> hpf_coeff_index_1_select == 4 ;  
                                             (imeas_samp_rate inside {[1000:1024]})  -> hpf_coeff_index_1_select == 5 ;  
                                             (imeas_samp_rate inside {[2000:2048]})  -> hpf_coeff_index_1_select == 6 ;  
                                             (imeas_samp_rate inside {[4000:4096]})  -> hpf_coeff_index_1_select == 7 ;  
                                             (imeas_samp_rate inside {[8125:8192]})  -> hpf_coeff_index_1_select == 8 ;  
                                             (imeas_samp_rate inside {[16350:16384]}) -> hpf_coeff_index_1_select == 9 ;  
                                             (imeas_samp_rate inside {[32750:32768]}) -> hpf_coeff_index_1_select == 10;  
                                             (imeas_samp_rate inside {[65500:65536]}) -> hpf_coeff_index_1_select == 11; 
                                             (imeas_samp_rate inside {[131062:131072]})-> hpf_coeff_index_1_select == 12; 
                                             (imeas_samp_rate inside {[262125:262144]})-> hpf_coeff_index_1_select == 13;} 

  constraint c_sine_num_of_period   {  sine_num_of_period == 50; }  

  function void post_randomize();
      case (hpf_coeff_index_0_select)
          0: hpf_cutoff_freq_fc = 0.2;
          1: hpf_cutoff_freq_fc = 0.5;
          2: hpf_cutoff_freq_fc = 1.0;
          3: hpf_cutoff_freq_fc = 2.0;
          4: hpf_cutoff_freq_fc = 5.0;
          5: hpf_cutoff_freq_fc = 10.0;
      endcase
      imeas_sin_expected_freq = hpf_cutoff_freq_fc * 1000 ;
  endfunction

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
    uvm_top.set_timeout(4s);
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
    `DUT_IF.hpf_filter_en_per_ch = top_test_cfg.hpf_filter_en_per_ch;
    `DUT_IF.hpf_coeff_index_0_select = top_test_cfg.hpf_coeff_index_0_select;
    `DUT_IF.hpf_coeff_index_1_select = top_test_cfg.hpf_coeff_index_1_select;
    `DUT_IF.filter_python_check_en = 1;

    `DUT_IF.filter_case = top_test_cfg.filter_case;
    top_test_cfg.post_randomize();

    phase.drop_objection(this);
  endtask : pre_reset_phase

  task write_coeff_regs();
    int j =0;

    `nnc_info("SOC_TEST", $sformatf("sample_rate= %0d hpf_coeff_index_1_select:%0d, hpf_coeff_index_0_select:%0d",`DUT_IF.imeas_samp_rate,`DUT_IF.hpf_coeff_index_1_select,`DUT_IF.hpf_coeff_index_0_select),UVM_LOW)
    `nnc_info("SOC_TEST", $sformatf("hpf_cutoff_freq_fc:%0f Hz",top_test_cfg.hpf_cutoff_freq_fc),UVM_LOW)
    
    if(`DUT_IF.hpf_coeff_index_1_select > 13) 
      `nnc_fatal("SOC_TEST", $sformatf("ERROR:: hpf_coeff_index_1_select:%0d for sample_rate= %0d ",`DUT_IF.hpf_coeff_index_1_select,`DUT_IF.imeas_samp_rate))

    if(!(`DUT_IF.iclk_sel == 3 && `DUT_IF.cic_rate == 7))begin // do not update coeff in case of default data rate
        top_test_cfg.wr_data[0] = 'h23;
        `WR_NORMAL_REG(`SOC_FILTER_LPF_COEFF_ADDR_REG, top_test_cfg.wr_data[0], top_test_cfg.pads);
        assert(top_test_cfg.randomize() with {no_of_bytes == 3; });
	`nnc_info("SOC_TEST", $sformatf("hpf_coeffs[%0d][%0d]:%0h",`DUT_IF.hpf_coeff_index_1_select,`DUT_IF.hpf_coeff_index_0_select,`SOC_TB.hpf_coeffs[`DUT_IF.hpf_coeff_index_1_select][`DUT_IF.hpf_coeff_index_0_select]),UVM_LOW)
        top_test_cfg.wr_data[0] = `SOC_TB.hpf_coeffs[`DUT_IF.hpf_coeff_index_1_select][`DUT_IF.hpf_coeff_index_0_select][23:16]; 
        top_test_cfg.wr_data[1] = `SOC_TB.hpf_coeffs[`DUT_IF.hpf_coeff_index_1_select][`DUT_IF.hpf_coeff_index_0_select][15:8];
        top_test_cfg.wr_data[2] = `SOC_TB.hpf_coeffs[`DUT_IF.hpf_coeff_index_1_select][`DUT_IF.hpf_coeff_index_0_select][7:0];
        `WR_BURST_NORMAL_REG(`SOC_FILTER_LPF_COEFF_DATA1_REG, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);
    end
  endtask : write_coeff_regs  

  virtual task main_phase(uvm_phase phase);
    phase.raise_objection(this);

    `nnc_info("SOC_TEST", "soc_imeas_hpf_filter_base_test start", UVM_LOW)

    top_test_cfg.sine_input_freq = real'(`DUT_IF.imeas_sin_expected_freq)/real'(`DUT_IF.imeas_sin_freq_unit);
    `nnc_info("SOC_TEST", $sformatf("input sine frequency: (%0f)",top_test_cfg.sine_input_freq),UVM_LOW)
    top_test_cfg.no_of_samples_per_period = (`DUT_IF.imeas_samp_rate * `DUT_IF.imeas_sin_freq_unit) / `DUT_IF.imeas_sin_expected_freq;
    `nnc_info("SOC_TEST", $sformatf("no_of_samples_per_period: (%d)",top_test_cfg.no_of_samples_per_period),UVM_LOW)
    `DUT_IF.imeas_sample_num_per_period = top_test_cfg.no_of_samples_per_period;
    //top_test_cfg.no_of_samples = `DUT_IF.imeas_sample_num_per_period * 2;//2 sine length
    `DUT_IF.no_of_samples = `DUT_IF.imeas_sample_num_per_period * 2;//2 sine length
    `DUT_IF.python_imeas_length = `DUT_IF.no_of_samples;//default python_imeas_length is 1024

    rdatac_cmd_en = 1;

    imeas_config();

    write_coeff_regs();

    top_test_cfg.wr_data[0] = `DUT_IF.hpf_filter_en_per_ch[7:0];
    `WR_NORMAL_REG(`SOC_FILTER_HPF_BP_L_REG, top_test_cfg.wr_data[0], top_test_cfg.pads);

    top_test_cfg.wr_data[0] = `DUT_IF.hpf_filter_en_per_ch[15:8];
    `WR_NORMAL_REG(`SOC_FILTER_HPF_BP_H_REG, top_test_cfg.wr_data[0], top_test_cfg.pads);

    fork 
      begin
        // Start/Restart (Synchronize) Conversion in single-shot/continous mode
        start_conversion();
      end
      begin
        `nnc_info("SOC_TEST", $sformatf("wait for %0d no of samples done!!!",`DUT_IF.no_of_samples),UVM_LOW)
	wait_for_intb();
	compare_imeas_chdata_through_rdata_cmd(0);
        `nnc_info("SOC_TEST", "Measurement is done!!!", UVM_LOW)
      end
      begin
        // Enable python check at the end of sim, so filter is stable
        for(int i = 0 ; i < top_test_cfg.sine_num_of_period; i++)begin
	  wait_for_intb();
          wait_for_intb_clear();
        end
	`DUT_IF.python_imeas_en = 1;
      end
    join

    // Stop conversion for single-shot or continuos
    stop_conversion();

    `nnc_info("SOC_TEST", "soc_imeas_hpf_filter_base_test end now", UVM_LOW)
    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ----------------------------------------------------------------------------------

    phase.drop_objection(this);
  endtask: main_phase

  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction
endclass : `TESTNAME
