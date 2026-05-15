/*--------------------------------------------------------------------------------------
// Copyright 2021 Nanochap, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_imeas_lpf_filter_base_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_imeas_lpf_filter_base_test                                             
// Designer	: shreeyal@nanochap.com                                                                 
// Date		: 10-11-2025                                                                     
// Revision	: 0.1 Initial version created by script                                 
--------------------------------------------------------------------------------------*/
`define TESTNAME soc_imeas_lpf_filter_base_test
`define TESTCFG soc_imeas_lpf_filter_base_test_cfg

class `TESTCFG extends soc_eegfilter_base_test_cfg;

  `nnc_object_utils(`TESTCFG)

  // -----------------------------------------------
  // End of decalration of new variables 
  // -----------------------------------------------
  rand bit [`FILTER_NUM-1:0]  lpf_filter_en_per_ch;
       real                   sine_input_freq;
       int                    no_of_samples_per_period;
       int                    no_of_samples;
  rand int                    passband_cut_off;
  rand int                    stopband_cut_off;
  rand int                    passband_cut_off_freq;
  rand int                    stopband_cut_off_freq;
  rand int                    lpf_coeff_index_0_select;
  rand int                    lpf_coeff_index_1_select;
  rand bit [`FILTER_NUM-1:0]  notch_filter_data_gone;


  function new (string name = "soc_imeas_lpf_filter_base_test_cfg");
    super.new(name);
  endfunction: new

  // -----------------------------------------------
  // Adding constraints of randomization
  // -----------------------------------------------
  //constraint c_iclk_sel            { iclk_sel == 2;}

  //constraint c_spi_sclk_freq       { solve iclk_sel before spi_sclk_freq; spi_sclk_freq > (8192/(2**iclk_sel));} // spi clk always faster than adc_clk
  constraint c_spi_sclk_freq       {spi_sclk_freq == 20000 ;} // spi clk always faster than adc_clk

  //constraint c_imeas_cic_rate      { imeas_cic_rate inside {[2:2]};} 

  constraint c_imeas_en            { imeas_en inside {0,1}; } // 1. imeas_en=1 (always continous mode) , 2. imeas_en=0,single_shot_en=0 (also continuos mode)  

  constraint c_single_shot_en      { single_shot_en == 0; }

  //constraint c_imeas_cic_rate      { imeas_cic_rate inside {[2:11]};} // osr 2 to 13 supported
  constraint c_imeas_cic_rate      { imeas_cic_rate inside {[2:2]};} // osr 2 to 13 supported

  //constraint c_iclk_sel             { iclk_sel == 7;}

  constraint c_iclk_sel             { solve imeas_cic_rate before iclk_sel;
                                      //(imeas_cic_rate == 0) ->  iclk_sel inside {[0:11]};
                                      //(imeas_cic_rate == 1) ->  iclk_sel inside {[0:11]};
                                      (imeas_cic_rate == 2) ->  iclk_sel inside {[0:9]};
                                      (imeas_cic_rate == 3) ->  iclk_sel inside {[0:8]};
                                      (imeas_cic_rate == 4) ->  iclk_sel inside {[0:7]};
                                      (imeas_cic_rate == 5) ->  iclk_sel inside {[0:6]};
                                      (imeas_cic_rate == 6) ->  iclk_sel inside {[0:5]};
                                      (imeas_cic_rate == 7) ->  iclk_sel inside {[0:4]};
                                      (imeas_cic_rate == 8) ->  iclk_sel inside {[0:3]};
                                      (imeas_cic_rate == 9) ->  iclk_sel inside {[0:2]};
                                      (imeas_cic_rate == 10) ->  iclk_sel inside {[0:1]};
                                      (imeas_cic_rate == 11) ->  iclk_sel inside {[0:0]};}
                                      //(imeas_cic_rate == 12) ->  iclk_sel inside {[0:3]};
                                      //(imeas_cic_rate == 13) ->  iclk_sel inside {[0:2]};}

  constraint c_imeas_sin_gen_en    { imeas_sin_gen_en == 1'b1; }//generate sdm adc sine

  constraint c_imeas_sin_freq_unit { imeas_sin_freq_unit == 1000; }//sine frequency precision 1000: imeas_sin_expected_freq in Hz/1000

  //constraint c_imeas_sin_expected_freq{ imeas_sin_expected_freq == 512000;} // sine freq * 1000
  constraint c_imeas_sin_expected_freq{ imeas_sin_expected_freq == 250000;} //

  constraint c_imeas_en_dis_ch   {  imeas_en_dis_ch == 16'h0 ;} // atlist 1 channel should be enabled 

  //constraint c_lpf_filter_en_per_ch   {  lpf_filter_en_per_ch != 16'hFFFF ;}  
  //constraint c_lpf_filter_en_per_ch   {  lpf_filter_en_per_ch inside {[16'h0 : 16'hFFFE]};} // randomize atlist one channel to all channels enable  
  constraint c_lpf_filter_en_per_ch   {  lpf_filter_en_per_ch == 16'h0;} // randomize atlist one channel to all channels enable  

  constraint c_filter_case   {  filter_case == 1; }  

  constraint c_passband_cut_off   {  passband_cut_off == 8; }  
  constraint c_stopband_cut_off   {  stopband_cut_off == 4; }  

  //constraint c_passband_cut_off_freq   { solve imeas_samp_rate before passband_cut_off_freq;
  //                                       solve passband_cut_off before passband_cut_off_freq;
  //                                       passband_cut_off_freq == imeas_samp_rate/passband_cut_off; }  

  ////constraint c_stopband_cut_off_freq   { solve imeas_samp_rate before stopband_cut_off_freq;
  //                                       solve stopband_cut_off before stopband_cut_off_freq;
  //                                       stopband_cut_off_freq == imeas_samp_rate/stopband_cut_off; }  

  //constraint c_lpf_coeff_index_1_select   {  solve imeas_samp_rate before lpf_coeff_index_1_select ;
  //                                           (imeas_samp_rate inside {[30:32]})        -> lpf_coeff_index_1_select == 0 ;   // 31.25
  //                                           (imeas_samp_rate inside {[62:64]})        -> lpf_coeff_index_1_select == 1 ;  // 62.5
  //                                           (imeas_samp_rate inside {[125:128]})      -> lpf_coeff_index_1_select == 2 ;  
  //                                           (imeas_samp_rate inside {[250:256]})      -> lpf_coeff_index_1_select == 3 ;  
  //                                           (imeas_samp_rate inside {[500:512]})      -> lpf_coeff_index_1_select == 4 ;  
  //                                           (imeas_samp_rate inside {[1000:1024]})    -> lpf_coeff_index_1_select == 5 ;  
  //                                           (imeas_samp_rate inside {[2000:2048]})    -> lpf_coeff_index_1_select == 6 ;  
  //                                           (imeas_samp_rate inside {[4000:4096]})    -> lpf_coeff_index_1_select == 7 ;  
  //                                           (imeas_samp_rate inside {[8000:8192]})    -> lpf_coeff_index_1_select == 8 ;  
  //                                           (imeas_samp_rate inside {[16000:16384]})  -> lpf_coeff_index_1_select == 9 ;  
  //                                           (imeas_samp_rate inside {[32000:32768]})  -> lpf_coeff_index_1_select == 10;  
  //                                           (imeas_samp_rate inside {[64000:65536]})  -> lpf_coeff_index_1_select == 11; 
  //                                           (imeas_samp_rate inside {[128000:131072]})-> lpf_coeff_index_1_select == 12; 
  //                                           (imeas_samp_rate inside {[256000:262144]})-> lpf_coeff_index_1_select == 13;} 

  //constraint c_lpf_coeff_index_0_select { solve passband_cut_off before lpf_coeff_index_0_select;
  //                                        solve stopband_cut_off before lpf_coeff_index_0_select;
  //                                        (passband_cut_off == 8 && stopband_cut_off == 4) -> lpf_coeff_index_0_select == 4;}

  constraint c_passband_cut_off_freq   { solve imeas_samp_rate before passband_cut_off_freq;
                                         if (imeas_samp_rate inside {[500 : 2000]}) {passband_cut_off_freq == 32;}
                                         else {passband_cut_off_freq == imeas_samp_rate/passband_cut_off;} } 

  constraint c_stopband_cut_off_freq   { solve imeas_samp_rate before stopband_cut_off_freq;
                                         if (imeas_samp_rate inside {[500 : 2000]}) {stopband_cut_off_freq == 180;}
                                         else {stopband_cut_off_freq == imeas_samp_rate/stopband_cut_off;} }  

  constraint c_lpf_coeff_index_1_select   {  solve imeas_samp_rate before lpf_coeff_index_1_select ;
                                             (imeas_samp_rate inside {[500:512]})    -> lpf_coeff_index_1_select == 0 ;  
                                             (imeas_samp_rate inside {[1000:1024]})  -> lpf_coeff_index_1_select == 1 ;  
                                             (imeas_samp_rate inside {[2000:2048]})  -> lpf_coeff_index_1_select == 2 ;  
                                             (imeas_samp_rate inside {[4000:4096]})  -> lpf_coeff_index_1_select == 3 ;  
                                             (imeas_samp_rate inside {[8000:8192]})  -> lpf_coeff_index_1_select == 4 ;  
                                             (imeas_samp_rate inside {[16000:16384]}) -> lpf_coeff_index_1_select == 5 ;  
                                             (imeas_samp_rate inside {[32000:32768]}) -> lpf_coeff_index_1_select == 6;  
                                             (imeas_samp_rate inside {[64000:65536]}) -> lpf_coeff_index_1_select == 7; 
                                             (imeas_samp_rate inside {[128000:131072]})-> lpf_coeff_index_1_select == 8; 
                                             (imeas_samp_rate inside {[256000:262144]})-> lpf_coeff_index_1_select == 9;} 

  constraint c_lpf_coeff_index_0_select { lpf_coeff_index_0_select == 0;}

  //constraint c_sine_num_of_period   {  sine_num_of_period == 996; }  
  constraint c_sine_num_of_period   {  solve imeas_samp_rate before sine_num_of_period;
                                       if (imeas_samp_rate > 2000) {sine_num_of_period == 900;}
                                       else if (imeas_samp_rate == 500) {sine_num_of_period == 200;}
                                       else {sine_num_of_period == 120;} }  

  constraint c_notch_filter_data_gone   {  solve imeas_samp_rate before notch_filter_data_gone ; 
                                           // in ns - converted from ms to ns as per design document 
                                           (imeas_samp_rate inside {[30:32]})        -> notch_filter_data_gone == (811200000/(1000000000/imeas_samp_rate)) ;
                                           (imeas_samp_rate inside {[62:64]})        -> notch_filter_data_gone == (405600000/(1000000000/imeas_samp_rate)) ;
                                           (imeas_samp_rate inside {[125:128]})      -> notch_filter_data_gone == (204800000/(1000000000/imeas_samp_rate)) ;
                                           (imeas_samp_rate inside {[250:256]})      -> notch_filter_data_gone == (102400000/(1000000000/imeas_samp_rate)) ;
                                           (imeas_samp_rate inside {[500:512]})      -> notch_filter_data_gone == (51200000/(1000000000/imeas_samp_rate)) ;
                                           (imeas_samp_rate inside {[1000:1024]})    -> notch_filter_data_gone == (25600000/(1000000000/imeas_samp_rate)) ;
                                           (imeas_samp_rate inside {[2000:2048]})    -> notch_filter_data_gone == (12800000/(1000000000/imeas_samp_rate)) ;
                                           (imeas_samp_rate inside {[4000:4096]})    -> notch_filter_data_gone == (6400000/(1000000000/imeas_samp_rate)) ;
                                           (imeas_samp_rate inside {[8000:8192]})    -> notch_filter_data_gone == (3200000/(1000000000/imeas_samp_rate)) ;
                                           (imeas_samp_rate inside {[16000:16384]})  -> notch_filter_data_gone == (1600000/(1000000000/imeas_samp_rate)) ;
                                           (imeas_samp_rate inside {[32000:32768]})  -> notch_filter_data_gone == (800000/(1000000000/imeas_samp_rate)) ;
                                           (imeas_samp_rate inside {[64000:65536]})  -> notch_filter_data_gone == (400000/(1000000000/imeas_samp_rate)) ;
                                           (imeas_samp_rate inside {[128000:131072]})-> notch_filter_data_gone == (200000/(1000000000/imeas_samp_rate)) ;
                                           (imeas_samp_rate inside {[256000:262144]})-> notch_filter_data_gone == (100000/(1000000000/imeas_samp_rate)) ; }

  constraint c_no_of_adc_dev1      {  no_of_adc_dev1 inside {[5:7]};} // 0:16, 1:14, 2:12, 3:10, 4:8, 5:6, 6:4, 7:2

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
    uvm_top.set_timeout(50ms);
    //uvm_top.set_timeout(150ms);
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
    `DUT_IF.sine_num_of_period = top_test_cfg.sine_num_of_period;
    `DUT_IF.imeas_sin_gen_en = top_test_cfg.imeas_sin_gen_en;
    `DUT_IF.imeas_sin_freq_unit = top_test_cfg.imeas_sin_freq_unit;
    `DUT_IF.imeas_sin_expected_freq = top_test_cfg.imeas_sin_expected_freq;
    `DUT_IF.imeas_sin_no_clk_per_period = top_test_cfg.imeas_sin_no_clk_per_period;
    `DUT_IF.imeas_en_dis_ch = top_test_cfg.imeas_en_dis_ch;
    `DUT_IF.lpf_filter_en_per_ch = top_test_cfg.lpf_filter_en_per_ch;
    `DUT_IF.lpf_coeff_index_0_select = top_test_cfg.lpf_coeff_index_0_select;
    `DUT_IF.lpf_coeff_index_1_select = top_test_cfg.lpf_coeff_index_1_select;
    `DUT_IF.no_of_adc_dev1 = top_test_cfg.no_of_adc_dev1;
    `DUT_IF.no_of_adc_dev2 = top_test_cfg.no_of_adc_dev2;

    `DUT_IF.stopband_cut_off_freq = top_test_cfg.stopband_cut_off_freq;
    `DUT_IF.passband_cut_off_freq = top_test_cfg.passband_cut_off_freq;
    `DUT_IF.notch_filter_data_gone = top_test_cfg.notch_filter_data_gone;
    `DUT_IF.filter_python_check_en = 1;
    `DUT_IF.python_imeas_en = 1;

    rdatac_cmd_en = 1;
    `DUT_IF.filter_case = top_test_cfg.filter_case;

    phase.drop_objection(this);
  endtask : pre_reset_phase

  task write_coeff_regs();
    int j =0;

    `nnc_info("SOC_TEST", $sformatf("sample_rate= %0d lpf_coeff_index_1_select:%0d, lpf_coeff_index_0_select:%0d",`DUT_IF.imeas_samp_rate,`DUT_IF.lpf_coeff_index_1_select,`DUT_IF.lpf_coeff_index_0_select),UVM_LOW)

    if(`DUT_IF.lpf_coeff_index_1_select > 13) 
      `nnc_fatal("SOC_TEST", $sformatf("ERROR:: lpf_coeff_index_1_select:%0d for sample_rate= %0d ",`DUT_IF.lpf_coeff_index_1_select,`DUT_IF.imeas_samp_rate))

    
    if(!(`DUT_IF.iclk_sel == 3 && `DUT_IF.cic_rate == 7))begin // do not update coeff in case of default data rate
      for(int i =0; i<= 13; i++)begin // addr 'h0 to 'hD
        top_test_cfg.wr_data[0] = i;
        `WR_NORMAL_REG(`SOC_FILTER_LPF_COEFF_ADDR_REG, top_test_cfg.wr_data[0], top_test_cfg.pads);
        assert(top_test_cfg.randomize() with {no_of_bytes == 3; });
	`nnc_info("SOC_TEST", $sformatf("lpf_coeffs[%0d][%0d][%0d]:%0h",`DUT_IF.lpf_coeff_index_1_select,`DUT_IF.lpf_coeff_index_0_select,i,`SOC_TB.lpf_coeffs[`DUT_IF.lpf_coeff_index_1_select][`DUT_IF.lpf_coeff_index_0_select][i]),UVM_LOW)
        top_test_cfg.wr_data[0] = `SOC_TB.lpf_coeffs[`DUT_IF.lpf_coeff_index_1_select][`DUT_IF.lpf_coeff_index_0_select][i][17:16]; 
        top_test_cfg.wr_data[1] = `SOC_TB.lpf_coeffs[`DUT_IF.lpf_coeff_index_1_select][`DUT_IF.lpf_coeff_index_0_select][i][15:8];
        top_test_cfg.wr_data[2] = `SOC_TB.lpf_coeffs[`DUT_IF.lpf_coeff_index_1_select][`DUT_IF.lpf_coeff_index_0_select][i][7:0];
        `WR_BURST_NORMAL_REG(`SOC_FILTER_LPF_COEFF_DATA1_REG, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);
      end
      for(int i =13; i>=0; i--)begin
        top_test_cfg.wr_data[0] = i; // addr 'hD to 'h0
        `WR_NORMAL_REG(`SOC_FILTER_LPF_COEFF_ADDR_REG, top_test_cfg.wr_data[0], top_test_cfg.pads);
        assert(top_test_cfg.randomize() with {no_of_bytes == 3; });
	`nnc_info("SOC_TEST", $sformatf("lpf_coeffs[%0d][%0d][%0d]:%0h",`DUT_IF.lpf_coeff_index_1_select,`DUT_IF.lpf_coeff_index_0_select,j+14,`SOC_TB.lpf_coeffs[`DUT_IF.lpf_coeff_index_1_select][`DUT_IF.lpf_coeff_index_0_select][j+14]),UVM_LOW)
        top_test_cfg.wr_data[0] = `SOC_TB.lpf_coeffs[`DUT_IF.lpf_coeff_index_1_select][`DUT_IF.lpf_coeff_index_0_select][j+14][17:16]; 
        top_test_cfg.wr_data[1] = `SOC_TB.lpf_coeffs[`DUT_IF.lpf_coeff_index_1_select][`DUT_IF.lpf_coeff_index_0_select][j+14][15:8];
        top_test_cfg.wr_data[2] = `SOC_TB.lpf_coeffs[`DUT_IF.lpf_coeff_index_1_select][`DUT_IF.lpf_coeff_index_0_select][j+14][7:0];
        j++;
        `WR_BURST_NORMAL_REG(`SOC_FILTER_LPF_COEFF_DATA1_REG, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);
      end
    end
  endtask : write_coeff_regs 

  virtual task main_phase(uvm_phase phase);
    phase.raise_objection(this);

    `nnc_info("SOC_TEST", "soc_imeas_lpf_filter_base_test start", UVM_LOW)

    top_test_cfg.sine_input_freq = real'(`DUT_IF.imeas_sin_expected_freq)/real'(`DUT_IF.imeas_sin_freq_unit);
    `nnc_info("SOC_TEST", $sformatf("input sine frequency: (%0f)",top_test_cfg.sine_input_freq),UVM_LOW)
    top_test_cfg.no_of_samples_per_period =(`DUT_IF.imeas_samp_rate * `DUT_IF.imeas_sin_freq_unit) / `DUT_IF.imeas_sin_expected_freq;
    `nnc_info("SOC_TEST", $sformatf("no_of_samples_per_period: (%d)",top_test_cfg.no_of_samples_per_period),UVM_LOW)
    `DUT_IF.imeas_sample_num_per_period = top_test_cfg.no_of_samples_per_period;
    //top_test_cfg.no_of_samples = `DUT_IF.imeas_sample_num_per_period * 2;//2 sine length
    if(`DUT_IF.imeas_sample_num_per_period == 0) `DUT_IF.imeas_sample_num_per_period = 1;
    //`DUT_IF.no_of_samples = `DUT_IF.imeas_sample_num_per_period * 10;//2 sine length

    `DUT_IF.no_of_samples = `DUT_IF.imeas_sample_num_per_period * `DUT_IF.sine_num_of_period;//2 sine length
    if(`DUT_IF.no_of_samples > 10000) `DUT_IF.no_of_samples = 10000; // to limit the no of samples for python
    `DUT_IF.python_imeas_length = `DUT_IF.no_of_samples;//default python_imeas_length is 1024
    `DUT_IF.python_filter_length = `DUT_IF.no_of_samples;//default python_imeas_length is 1024

    `nnc_info("SOC_TEST", $sformatf("data_rate fs: (%0f) Hz",`DUT_IF.imeas_samp_rate),UVM_LOW)
    `nnc_info("SOC_TEST", $sformatf("passband_cut_off_freq: (%0f) Hz",`DUT_IF.passband_cut_off_freq),UVM_LOW)
    `nnc_info("SOC_TEST", $sformatf("stopband_cut_off_freq: (%0f) Hz",`DUT_IF.stopband_cut_off_freq),UVM_LOW)

    imeas_config();

    write_coeff_regs();

    top_test_cfg.wr_data[0] = `DUT_IF.notch_filter_data_gone[7:0];
    `WR_NORMAL_REG(`SOC_FILTER_NOTCH_DATA_GONE_L_REG, top_test_cfg.wr_data[0], top_test_cfg.pads);

    top_test_cfg.wr_data[0] = `DUT_IF.notch_filter_data_gone[15:8];
    `WR_NORMAL_REG(`SOC_FILTER_NOTCH_DATA_GONE_H_REG, top_test_cfg.wr_data[0], top_test_cfg.pads);

    top_test_cfg.wr_data[0] = `DUT_IF.lpf_filter_en_per_ch[7:0];
    `WR_NORMAL_REG(`SOC_FILTER_LPF_BP_L_REG, top_test_cfg.wr_data[0], top_test_cfg.pads);

    top_test_cfg.wr_data[0] = `DUT_IF.lpf_filter_en_per_ch[15:8];
    `WR_NORMAL_REG(`SOC_FILTER_LPF_BP_H_REG, top_test_cfg.wr_data[0], top_test_cfg.pads);

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
        //for(int i = 0 ; i < `DUT_IF.sine_num_of_period; i++)begin
	//  wait_for_intb();
        //  wait_for_intb_clear();
        //end
	//`DUT_IF.python_imeas_en = 1;
      end
    join

    // Stop conversion for single-shot or continuos
    stop_conversion();

    `nnc_info("SOC_TEST", "soc_imeas_lpf_filter_base_test end now", UVM_LOW)
    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ----------------------------------------------------------------------------------

    phase.drop_objection(this);
  endtask: main_phase

  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction
endclass : `TESTNAME
