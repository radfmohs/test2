/*--------------------------------------------------------------------------------------
// Copyright 2021 Nanochap, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_imeas_eegfilter__base_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_imeas_eegfilter__base_test                                             
// Designer	: shreeyal@nanochap.com                                                                 
// Date		: 05-09-2025                                                                     
// Revision	: 0.1 Initial version created by script                                 
--------------------------------------------------------------------------------------*/
`define TESTNAME soc_eegfilter_base_test
`define TESTCFG soc_eegfilter_base_test_cfg

class `TESTCFG extends soc_base_test_cfg;

  `nnc_object_utils(`TESTCFG)

  // -----------------------------------------------
  // Adding your new varialbles in config test
  // -----------------------------------------------
  rand logic [7:0]  wr_data[256];
  rand int          no_of_bytes; 
  rand logic [7:0]  reg_addr;
  rand logic [7:0]  pads;
  rand logic [7:0]  mask;
  rand logic [7:0]  expected_data;
       logic [7:0]  rd_data[];
  rand logic        imeas_en;
  rand logic        imeas_rst;
  rand logic        imeas_adc_inv;
  rand logic [1:0]  input_format;
  rand logic        output_format;
  rand logic [2:0]  cmd;
  rand logic [15:0] stable_time;
  rand logic [3:0]  imeas_data_sel;
  rand logic        single_shot_en;
  rand logic [15:0] no_of_conversions;
  rand logic [15:0] wait_for_conversions;
  rand logic        int_active_level_high_or_low;
  rand logic        clear_intr_manual_or_auto;
  rand logic        intr_length_slct_level_or_pulse;
  rand logic [`FILTER_NUM - 1 :0] imeas_en_dis_ch; // 0: enable, 1 :disbale
       logic [31:0] act_chdata;
       logic [31:0] act_chdata_combined [256];
       logic [31:0] act_chdata_combined_rdatac [3000][`FILTER_NUM];
       logic [31:0] exp_chdata_combined_rdatac [3000][`FILTER_NUM];
       logic        eeg_int_sts;
  rand logic        eeg_int_sts_en;
  rand logic        eeg_int_en;
  rand logic        daisy_en;
  rand logic        imeas_status_en;
  rand logic        imeas_24bitdata_en;
  rand int          no_of_samples;
  rand logic        filter_case;
  rand int          sine_num_of_period;

  // -----------------------------------------------
  // End of decalration of new variables 
  // -----------------------------------------------

  function new (string name = "soc_eegfilter_base_test_cfg");
    super.new(name);
  endfunction: new

  // -----------------------------------------------
  // Adding constraints of randomization
  // -----------------------------------------------
  constraint c_pclk_sel            { pclk_sel inside {[0:0]};} 

  constraint c_imeas_cic_rate      { imeas_cic_rate inside {[3:5]};} // randomize this later

  constraint c_daisy_en            { daisy_en == 0;} 

  constraint c_iclk_sel            { iclk_sel inside {[0:11]}; 
                                     solve imeas_cic_rate before iclk_sel;
                                     (imeas_cic_rate >=3) ->  iclk_sel == 0 ;}
                                     
  //constraint c_spi_sclk_freq       { solve iclk_sel before spi_sclk_freq; spi_sclk_freq > (8192/(2**iclk_sel));} // spi clk always faster than adc_clk
  constraint c_spi_sclk_freq       {spi_sclk_freq == 20000 ;} // spi clk always faster than adc_clk

  // Set Jitter for SPI CLK (0% - 100%)
//  constraint c_spi_sclk_jitter        { spi_sclk_jitter inside {[1:1]};}
//
//  constraint c_spi_clk_jitter         { soft spi_clk_jitter inside {[1:1]};}
//
//  // Set SPI timing protocol for tCSSO (Min 20ns)
//  constraint c_tcssc                  { soft tcssc  == `SPI_MIN_TCSSO;}   // ~tCSSO 
//
//  // Set SPI timing protocol for tCSH1 (Min 20ns)
//  constraint c_tsccs                  { tsccs == `SPI_MIN_TCSH1; }   // ~tCSH1 
//
//  // Set SPI timing protocol for tCSPW (Min 20ns)
//  constraint c_tcsh                   { tcsh == `SPI_MIN_TCSPW; }   // ~tCSPW 
//
//  
//  // Set SPI timing protocol for dist (Data is valid before clock is coming)
//  constraint c_tdist                  { soft tdist inside {[0:0]};}        // percent : tdist * (Period_SCK/2 - 10):
//
//  // Set SPI timing protocol for percent : tCH >= 20ns, tCL >= 20ns
//
//  constraint c_tch                    {tch == `SPI_MIN_TCH;}        // percent : tch >= 25ns, tCL >= 25ns
  //jitter
  constraint c_hfosc_jitter        { hfosc_jitter inside {[0:0]}; }        // 0%
  constraint c_hfosc_variation     { hfosc_variation inside {[100:100]}; } // 100%

  constraint c_no_of_bytes         { soft no_of_bytes == 2; }

  constraint c_imeas_en            { soft imeas_en inside {[0:1]}; }// For single shot conversion, manual imeas_en is disabled

  constraint c_single_shot_en      { single_shot_en inside {[0:1]} ;}

  //constraint c_single_shot_en      { single_shot_en inside {[0:1]} ;
  //                                   imeas_en == 0 ->  single_shot_en == 1; }

  constraint c_imeas_rst           { soft imeas_rst == 0; }

  constraint c_imeas_adc_inv       { imeas_adc_inv inside {[0:1]}; }

  constraint c_input_format        { input_format inside {[0:3]}; }

  constraint c_output_format       { output_format inside {[0:1]}; }

  constraint c_cmd                 { soft cmd == 0; }

  constraint c_stable_time         { soft stable_time inside {[1:10]}; }

  constraint c_channel_sel         { soft imeas_data_sel inside {[0:(`FILTER_NUM - 1)]}; }//currently 16 channels considered in design

  constraint c_no_of_conversions   { no_of_conversions inside {[1:3]}; }

  constraint c_iclk_pmu_ctrl_en     { iclk_pmu_ctrl_en == 1'b1; }

  //constraint c_int_active_level_low_or_high  { int_active_level_high_or_low == 1; } // 1: intr active high, 0 : intr active low 

  //constraint c_clear_intr_manual_or_auto  { clear_intr_manual_or_auto == 0; } // 0: manually clear intr by w1c, 1 : auto clear intr by r1c 

  //constraint c_intr_length_slct_pulse_or_level  { intr_length_slct_level_or_pulse == 0; } // 0: level INT, 1: pulse INT

  constraint c_eeg_int_sts_en  { eeg_int_sts_en == 1; }

  constraint c_eeg_int_en  { eeg_int_en == 1; }

  constraint c_imeas_sin_freq_unit { imeas_sin_freq_unit == 100; }//sine frequency precision 100: imeas_sin_expected_freq in Hz/100

  constraint c_imeas_status_en { imeas_status_en == 0; }// default no Imeas status 
  constraint c_imeas_24bitdata_en { imeas_24bitdata_en == 0; }// default 32 bit data

  constraint c_no_of_samples   {  no_of_samples  inside {[5:5]}; }  

  constraint c_filter_case   {  filter_case == 0; }  

  constraint c_no_of_adc_dev1      {  no_of_adc_dev1 inside {[0:7]};} // 0:16, 1:14, 2:12, 3:10, 4:8, 5:6, 6:4, 7:2

  //constraint c_no_of_adc_dev2             { (no_of_adc_dev1 == 0) -> no_of_adc_dev2 inside {[0:0]};
  //                                          (no_of_adc_dev1 == 1) -> no_of_adc_dev2 inside {[0:1]};
  //                                          (no_of_adc_dev1 == 2) -> no_of_adc_dev2 inside {[0:2]};
  //                                          (no_of_adc_dev1 == 3) -> no_of_adc_dev2 inside {[0:3]};
  //                                          (no_of_adc_dev1 == 4) -> no_of_adc_dev2 inside {[0:4]};
  //                                          (no_of_adc_dev1 == 5) -> no_of_adc_dev2 inside {[0:5]};
  //                                          (no_of_adc_dev1 == 6) -> no_of_adc_dev2 inside {[0:6]};
  //                                          (no_of_adc_dev1 == 7) -> no_of_adc_dev2 inside {[0:7]}; }

  constraint c_no_of_adc_dev2             { (no_of_adc_dev1 == 0) -> no_of_adc_dev2 inside {[0:7]};
                                            (no_of_adc_dev1 == 1) -> no_of_adc_dev2 inside {[1:7]};
                                            (no_of_adc_dev1 == 2) -> no_of_adc_dev2 inside {[2:7]};
                                            (no_of_adc_dev1 == 3) -> no_of_adc_dev2 inside {[3:7]};
                                            (no_of_adc_dev1 == 4) -> no_of_adc_dev2 inside {[4:7]};
                                            (no_of_adc_dev1 == 5) -> no_of_adc_dev2 inside {[5:7]};
                                            (no_of_adc_dev1 == 6) -> no_of_adc_dev2 inside {[6:7]};
                                            (no_of_adc_dev1 == 7) -> no_of_adc_dev2 inside {[7:7]}; }

  // making sure atlist 1 channel keeps enable
  constraint c_imeas_en_dis_ch { (no_of_adc_dev1 == 0) -> imeas_en_dis_ch inside {[0:'hFFFF]}; 
                                 (no_of_adc_dev1 == 1) -> imeas_en_dis_ch inside {[0:'h3FFE]};
                                 (no_of_adc_dev1 == 2) -> imeas_en_dis_ch inside {[0:'hFFE]};
                                 (no_of_adc_dev1 == 3) -> imeas_en_dis_ch inside {[0:'h3FE]};
                                 (no_of_adc_dev1 == 4) -> imeas_en_dis_ch inside {[0:'hFE]};
                                 (no_of_adc_dev1 == 5) -> imeas_en_dis_ch inside {[0:'h3E]};
                                 (no_of_adc_dev1 == 6) -> imeas_en_dis_ch inside {[0:'hE]};
                                 (no_of_adc_dev1 == 7) -> imeas_en_dis_ch inside {[0:'h2]}; }


  constraint c_sine_num_of_period   {  sine_num_of_period == 20; }  
  // -----------------------------------------------
  // End of adding constraints of randomization
  // -----------------------------------------------

endclass : `TESTCFG

class `TESTNAME extends soc_base_test;
   
  `nnc_component_utils(`TESTNAME)

  `TESTCFG top_test_cfg;

  real one_conversion_period ;
  real imeas_clk_period;
  bit  imeas_config_dis = 0;
  bit  use_old_intr_reg_or_general_reg_to_clr;
  bit  rdatac_cmd_en;
  int total_adc_ch_to_read;
  int data_bytes_per_sample;
  bit [39:0] act_status_bits;
  bit [39:0] exp_status_bits;
  logic [31:0] exp_chdata[`FILTER_NUM-1:0] ;

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
    //`DUT_IF.imeas_en_dis_ch = 16'hFFFF;

    `DUT_IF.int_active_level_high_or_low = top_test_cfg.int_active_level_high_or_low;
    `DUT_IF.clear_intr_manual_or_auto = top_test_cfg.clear_intr_manual_or_auto;
    `DUT_IF.intr_length_slct_level_or_pulse = top_test_cfg.intr_length_slct_level_or_pulse;

    `DUT_IF.eeg_int_sts_en = top_test_cfg.eeg_int_sts_en;
    `DUT_IF.eeg_int_en = top_test_cfg.eeg_int_en;
    `DUT_IF.daisy_en = top_test_cfg.daisy_en;

    `DUT_IF.no_of_samples = top_test_cfg.no_of_samples;
    `DUT_IF.filter_case = top_test_cfg.filter_case;

    `DUT_IF.imeas_status_en   = top_test_cfg.imeas_status_en   ;
    `DUT_IF.imeas_24bitdata_en= top_test_cfg.imeas_24bitdata_en;
    `DUT_IF.no_of_adc_dev1 = top_test_cfg.no_of_adc_dev1;
    `DUT_IF.no_of_adc_dev2 = top_test_cfg.no_of_adc_dev2;

    // ==================
    // Scoreboard enables
    // ==================
    // `EEPROM_SCOREBOARD_EN = 1;
    // `I2CS_SCOREBOARD_EN = 1;
    // `ANALOG_SCOREBOARD_EN = 1;
    // `TIMER_SCOREBOARD_EN = 1;
       `IMEAS_SCB_EN = 1'b1;

    phase.drop_objection(this);
  endtask : pre_reset_phase

  virtual task post_reset_phase(nnc_phase phase);
    phase.raise_objection(this);
    super.post_reset_phase(phase);

    if(`DUT_IF.daisy_en === 1) `DUT_IF.total_chip_num = 2;

    phase.drop_objection(this);
  endtask : post_reset_phase

  task imeas_config();
    bit [1:0] imeas_data_format_mode;

    `nnc_info("SOC_TEST", " Inside imeas_config", NNC_LOW)

    // configure GENERAL INT CTRL
    top_test_cfg.wr_data[0] = {5'b0,`DUT_IF.int_active_level_high_or_low,`DUT_IF.clear_intr_manual_or_auto,`DUT_IF.intr_length_slct_level_or_pulse};
    `WR_NORMAL_REG(`SOC_GENERAL_INT_CTRL_REG, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // check INTB RESET value
    if(`DUT_IF.int_active_level_high_or_low === 0) begin
	if(`SOC_TB.INTB !== 1)
	  `nnc_error("SOC_TEST", "Error! RESET VALUE INTB not active low as expected!!")
	else
	  `nnc_info("SOC_TEST", "Active low INTB selected!", NNC_LOW)
    end
    else begin
	if(`SOC_TB.INTB !== 0)
	  `nnc_error("SOC_TEST", "Error! RESET VALUE INTB not active high as expected!!")
	else
	   `nnc_info("SOC_TEST", "Active high INTB selected!", NNC_LOW)
    end
   
    fork
      pulse_INTB_active_high_check;
      pulse_INTB_active_low_check;
      level_INTB_active_high_check;
      level_INTB_active_low_check;
    join_none

    // configure eeg filter int en
    top_test_cfg.wr_data[0] = {6'b0,`DUT_IF.eeg_int_sts_en,`DUT_IF.eeg_int_en};
    `WR_NORMAL_REG(`SOC_FILTER_INT_CTRL_REG, top_test_cfg.wr_data[0], top_test_cfg.pads);
    
    //Write SOC_IMEAS_REG_1 to set configure DR
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_IMEAS_REG_1; wr_data[0] == {4'h0,`DUT_IF.cic_rate};});// OSR:128
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_IMEAS_REG_1; wr_data[0] == {4'h3,`DUT_IF.daisy_en,`DUT_IF.cic_rate};});// OSR:128
    imeas_data_format_mode = {!`DUT_IF.imeas_status_en, `DUT_IF.imeas_24bitdata_en};
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_IMEAS_REG_1; wr_data[0] == {1'b0,imeas_data_format_mode,`DUT_IF.daisy_en,`DUT_IF.cic_rate};});// OSR:128
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    `nnc_info("SOC_TEST", $sformatf("DR:%h", `DUT_IF.cic_rate), NNC_LOW)

    //Write SOC_IMEAS_CTRL_REG
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_IMEAS_CTRL_REG; wr_data[0] == {`DUT_IF.imeas_data_sel,`DUT_IF.single_shot_en,3'h0};});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    `nnc_info("SOC_TEST", "Enable Single-Shot conversion", NNC_LOW)

    //Write SOC_IMEAS_STABLE_TIME_0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_IMEAS_STABLE_TIME_0; wr_data[0] == {`DUT_IF.stable_time[7:0]};});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    //Write SOC_IMEAS_STABLE_TIME_1
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_IMEAS_STABLE_TIME_1; wr_data[0] == {`DUT_IF.stable_time[15:8]};});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    assert(top_test_cfg.randomize() with { reg_addr == `SOC_IMEAS_EN_DIS_CH_LOW_REG; wr_data[0] == {`DUT_IF.imeas_en_dis_ch[7:0]};});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    assert(top_test_cfg.randomize() with { reg_addr == `SOC_IMEAS_EN_DIS_CH_HIGH_REG; wr_data[0] == {`DUT_IF.imeas_en_dis_ch[15:8]};});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

   // // configure imeas format,rst and imeas_en
   // assert(top_test_cfg.randomize() with { reg_addr == `SOC_IMEAS_REG_0; wr_data[0] == {`DUT_IF.output_format,2'b0,`DUT_IF.imeas_adc_inv,`DUT_IF.input_format,`DUT_IF.imeas_rst,`DUT_IF.imeas_en};});
   // `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
   // `nnc_info("SOC_TEST", $sformatf("INPUT FORMAT:%h", `DUT_IF.input_format), NNC_LOW)
   // `nnc_info("SOC_TEST", $sformatf("OUTPUT FORMAT:%h", `DUT_IF.output_format), NNC_LOW)

    `nnc_info("SOC_TEST", " imeas_config is done ", NNC_LOW)
    print_config ();
    overlap_conversion_check();
  endtask : imeas_config

  task print_config();
    one_conversion_period =  1000000.0 / real'(`DUT_IF.imeas_samp_rate);//in us

    `nnc_info("SOC_TEST", "soc_eegfilter_base_test start", NNC_LOW)

    `nnc_info("SOC_TEST", $sformatf("iclk_sel =%0d, imeas_adc_freq: (%0d)Khz",`DUT_IF.iclk_sel,`DUT_IF.imeas_adc_freq),NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("cic_rate = %0d, osr: (%0d)",`DUT_IF.cic_rate,`DUT_IF.imeas_osr),NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("samp_rate: (%0f)hz",`DUT_IF.imeas_samp_rate),NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("one_conversion_period: (%0f)us",one_conversion_period),NNC_LOW)

    imeas_clk_period = 1000000.0 / `DUT_IF.imeas_adc_freq; // ns
    `nnc_info("SOC_TEST", $sformatf("imeas_clk_period: (%0f)ns",imeas_clk_period),NNC_LOW)

    `nnc_info("SOC_TEST", $sformatf("imeas_status_en = %0d , imeas_24bitdata_en=%0d", `DUT_IF.imeas_status_en,`DUT_IF.imeas_24bitdata_en), NNC_LOW)

  endtask : print_config

  task start_conversion();
    // configure imeas format,rst and imeas_en
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_IMEAS_REG_0; wr_data[0] == {`DUT_IF.output_format,2'b0,`DUT_IF.imeas_adc_inv,`DUT_IF.input_format,`DUT_IF.imeas_rst,`DUT_IF.imeas_en};});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    `nnc_info("SOC_TEST", $sformatf("INPUT FORMAT:%h", `DUT_IF.input_format), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("OUTPUT FORMAT:%h", `DUT_IF.output_format), NNC_LOW)

    if(`DUT_IF.imeas_en === 0)begin // single-shot or continous conversion
      // Start/Restart (Synchronize) Conversion in single-shot/continous mode
      `DUT_IF.cmd = `START_CMD;
      assert(top_test_cfg.randomize() with { reg_addr == `SOC_IMEAS_REG_2; wr_data[0] == {5'h0,`DUT_IF.cmd};});
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
      `nnc_info("SOC_TEST", "Send start cmd for single shot enable", NNC_LOW)
    end
  endtask : start_conversion

  task stop_conversion();
    //Disable Imeas_en for continous conversion
    if(`DUT_IF.imeas_en === 1)begin // continous conversion
      assert(top_test_cfg.randomize() with { reg_addr == `SOC_IMEAS_REG_0; wr_data[0] == {`DUT_IF.output_format,2'b0,`DUT_IF.imeas_adc_inv,`DUT_IF.input_format,`DUT_IF.imeas_rst,1'b0};});//Select format
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
      `nnc_info("SOC_TEST", "stop conversion through Imeas_en=0 for continuos mode", NNC_LOW)
    end
    
    // Stop conversion for single-shot or continuos
    if(`DUT_IF.imeas_en === 0)begin // single-shot or continous conversion
      // Start/Restart (Synchronize) Conversion in single-shot mode
      `DUT_IF.cmd = `STOP_CMD;
      assert(top_test_cfg.randomize() with { reg_addr == `SOC_IMEAS_REG_2; wr_data[0] == {5'h0,`DUT_IF.cmd};});
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
      `nnc_info("SOC_TEST", "Send stop cmd for single shot enable", NNC_LOW)
    end
  endtask : stop_conversion

  task automatic check_int_sts_reg(bit exp_int_sts);
    bit [7:0] rd_data;

    `nnc_info("SOC_TEST", $sformatf("check_int_sts_reg for exp_int_sts :%0d ", exp_int_sts), NNC_LOW)
    // check int sts reg
    if(`DUT_IF.clear_intr_manual_or_auto === 0) begin // in case of manual clear w1c
      if(use_old_intr_reg_or_general_reg_to_clr == 0) begin // old intr status register
        `RD_NORMAL_REG(`SOC_FILTER_INT_STS_REG,top_test_cfg.pads,rd_data); // ch0 sts
        top_test_cfg.eeg_int_sts = rd_data[0];
      end
      else begin // new general intr sts reg
        `RD_NORMAL_REG(`SOC_GENERAL_INT_STS_1_REG,top_test_cfg.pads, rd_data); // 
        top_test_cfg.eeg_int_sts = rd_data[1];
      end

      if(top_test_cfg.eeg_int_sts !== exp_int_sts)begin
        `nnc_error("TEST", $sformatf("EEG INT STS MISMATCH ERROR exp_int_sts = %0h, act_int_sts=%0h", exp_int_sts,top_test_cfg.eeg_int_sts))
      end
      else begin
        `nnc_info("SOC_TEST", "EEG INT STS MATCHED", NNC_LOW)
      end
    end
  endtask : check_int_sts_reg

  task clear_int_sts_reg();
    bit [7:0] wr_data[16];

    // clear int sts reg
    if(`DUT_IF.clear_intr_manual_or_auto === 1'b0)begin // manual clear - w1c 
      wr_data[0] = {7'b0,1'b1};
      `WR_NORMAL_REG(`SOC_FILTER_INT_STS_REG, wr_data[0], top_test_cfg.pads);
      `nnc_info("SOC_TEST", "eeg int sts cleared by w1c", NNC_LOW)
    end
    else begin // auto clear - r1c
      if(use_old_intr_reg_or_general_reg_to_clr == 0) begin // old intr status register
        `RD_NORMAL_REG(`SOC_FILTER_INT_STS_REG,top_test_cfg.pads, top_test_cfg.rd_data[0]); // ch0 sts
        top_test_cfg.eeg_int_sts = top_test_cfg.rd_data[0][0];
	`nnc_info("SOC_TEST", "eeg int sts cleared by old int sts reg - r1c", NNC_LOW)
      end
      else begin // new general intr sts reg
        `RD_NORMAL_REG(`SOC_GENERAL_INT_STS_1_REG,top_test_cfg.pads, top_test_cfg.rd_data[0]); // ch0  and ch1 sts
        top_test_cfg.eeg_int_sts = top_test_cfg.rd_data[0][1];
	`nnc_info("SOC_TEST", "eeg int sts cleared by new general int sts reg - r1c", NNC_LOW)
      end
    end

  endtask : clear_int_sts_reg

  task wait_for_intb();
    `nnc_info("SOC_TEST", "wait for EEG filter int and INTB assert", NNC_MEDIUM)
     wait(`IMEAS_WRAPPER_TOP.o_eeg_int === 1);    
     if(`DUT_IF.int_active_level_high_or_low == 1) 
        wait(`SOC_TB.INTB === 1);
      else 
        wait(`SOC_TB.INTB === 0);
    `nnc_info("SOC_TEST", "wait done for EEG filter int and INTB assert", NNC_MEDIUM)
  endtask : wait_for_intb

  task wait_for_intb_clear();
    `nnc_info("SOC_TEST", "wait for INTB clear", NNC_MEDIUM)
    if(`DUT_IF.intr_length_slct_level_or_pulse == 0)begin // level intr
      if(`DUT_IF.int_active_level_high_or_low == 1) 
        wait(`SOC_TB.INTB === 0);
      else 
        wait(`SOC_TB.INTB === 1);
    end 
    else begin
      wait(`IMEAS_WRAPPER_TOP.o_eeg_int === 0);    
    end 
    `nnc_info("SOC_TEST", "wait done for INTB clear", NNC_MEDIUM)
  endtask : wait_for_intb_clear

  task basic_traffic_with_multi_start_stop ();
    `nnc_info("SOC_TEST", $sformatf("no_of_conversions=%0d ", top_test_cfg.no_of_conversions), NNC_LOW)
    repeat(top_test_cfg.no_of_conversions) begin

      `nnc_info("SOC_TEST", $sformatf("imeas_en=%0d ,single_shot_en=%0d ", `DUT_IF.imeas_en,`DUT_IF.single_shot_en), NNC_LOW)
      use_old_intr_reg_or_general_reg_to_clr = $random; // 0: use old sts regs to clear int, 1 : use new general reg to clear int

      // Start/Restart (Synchronize) Conversion in single-shot/continous mode
      fork 
        begin
          start_conversion();
        end
        begin
          // Wait for intr to go high when conversion is completed
          //if(`DUT_IF.single_shot_en === 1) top_test_cfg.wait_for_conversions = 1;
          //`nnc_info("SOC_TEST", $sformatf("will wait for %0d conversions are done!!! ", top_test_cfg.wait_for_conversions), NNC_LOW)

          //repeat(top_test_cfg.wait_for_conversions) begin
            wait_for_intb();
	    //check_int_sts_reg(0); // check reg sts
          //end
          `nnc_info("SOC_TEST", "Measurement is done!!!", NNC_LOW)
        end
      join

      check_int_sts_reg(1); // check reg sts

      fork
        clear_int_sts_reg();
	//compare_imeas_chdata_through_rdata_cmd(0);
        wait_for_intb_clear();
      join

      //if(`DUT_IF.single_shot_en === 1)begin 
      //  `nnc_info("SOC_TEST", "Will wait for 2 adc clks after finishing sampling and before applying stop cmd!!!", NNC_LOW)
      //  repeat(2) #imeas_clk_period; // As per Xin, after meas_done, need 2 ADC_clks to finish the sampling, so after meas_done, 2 ADC clocks, then send stop cmd
      //end

      // Stop conversion for single-shot or continuos
      stop_conversion();

      // wait for current conversion to complete for continuos mode
      if(`DUT_IF.single_shot_en === 0) begin
        wait_for_one_conversion_to_finish();
        //`nnc_info("SOC_TEST", "Will wait for 2 adc clks after stop cmd!!!", NNC_LOW)
	//repeat(2) #imeas_clk_period; // As per Xin, for continuous , atlist 2 clocks should be there between meas_done_posand next imeas_en
      end

      // check imeas_data after conversion stops
      for (int i = 0; i < `FILTER_NUM ; i++)begin
        `DUT_IF.imeas_data_sel = i;
        compare_imeas_chdata (`DUT_IF.imeas_data_sel,0);
      end
    end

  endtask : basic_traffic_with_multi_start_stop

  task wait_for_one_conversion_to_finish();
    `nnc_info("SOC_TEST", "wait for one conversion after stop cmd", NNC_LOW)
 
    if(`IMEAS_WRAPPER_TOP.o_eeg_int === 1)begin
      fork
        clear_int_sts_reg();
	//compare_imeas_chdata_through_rdata_cmd(0);
        wait_for_intb_clear();
      join
    end

    fork : wait_for_conversion
      begin
          //wait(`IMEAS_WRAPPER_TOP.meas_done_pos === 1);
          //wait(`IMEAS_WRAPPER_TOP.meas_done_pos === 0);
          wait_for_intb();
          `nnc_info("SOC_TEST", "wait done for one conversion after stop cmd", NNC_LOW)
      end
      begin
        `nnc_info("TEST", $sformatf("will wait for one_conversion_period =%0f(ns)", (one_conversion_period*1000)),NNC_LOW)
        #(one_conversion_period*1000); // ns
        `nnc_info("SOC_TEST", "wait done for one conversion after stop cmd", NNC_LOW)
      end
    join_any
    disable wait_for_conversion;

    if(`IMEAS_WRAPPER_TOP.eeg_int_sts === 1)begin
      fork
        //clear_int_sts_reg();
	compare_imeas_chdata_through_rdata_cmd(0);
        wait_for_intb_clear();
      join
    end
  endtask : wait_for_one_conversion_to_finish

  virtual task main_phase(uvm_phase phase);
    phase.raise_objection(this);

    // ----------------------------------------------------------------------------------
    // Please add your code of your test here
    // ----------------------------------------------------------------------------------

    // Configure Imeas filter
    if(imeas_config_dis == 0)begin
      imeas_config ();
    end

    if(`DUT_IF.imeas_en_dis_ch != 16'hFFFF)begin // if any one channel is enabled 
      basic_traffic_with_multi_start_stop();
    end
    else begin
      `nnc_info("SOC_TEST", $sformatf("ALL ADC CH DISABLED = %0h", `DUT_IF.imeas_en_dis_ch), NNC_LOW)
      fork
        begin
          start_conversion();
        end
      join_none
      fork: no_intr_expected 
        begin
          wait_for_intb();
	  `nnc_error("TEST", $sformatf("EEG INT asserted for all Imeas ch disabled , imeas_en_dis_ch=%0h", `DUT_IF.imeas_en_dis_ch))
        end
        begin
          #2ms;
        end
      join_any
      disable no_intr_expected;

      //check adc data is 0
      compare_imeas_chdata_through_rdata_cmd(0);
      // Stop conversion for single-shot or continuos
      stop_conversion();
      #1ms;
    end

    `nnc_info("SOC_TEST", "soc_eegfilter_base_test end now", NNC_LOW)
    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ----------------------------------------------------------------------------------

    phase.drop_objection(this);
  endtask: main_phase

  task compare_imeas_chdata(int imeas_data_sel,bit reset_check);
    `nnc_info("SOC_TEST", $sformatf("Inside compare_imeas_chdata for imeas_data_sel = %0d",imeas_data_sel), NNC_LOW)

    top_test_cfg.wr_data[0] = {imeas_data_sel,`DUT_IF.single_shot_en,3'h0};
    `WR_NORMAL_REG(`SOC_IMEAS_CTRL_REG, top_test_cfg.wr_data[0], top_test_cfg.pads);
    `nnc_info("SOC_TEST", $sformatf("Read data from Channel = %0d", imeas_data_sel), NNC_LOW)

    // Read burst starting from SOC_IMEAS_DATA_0
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_IMEAS_DATA_0; no_of_bytes == 4;});
    `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
  
    for (int j = 0;j < 4 ;j++)begin  //32 bits
      top_test_cfg.act_chdata[31 - j*8 -: 8] = top_test_cfg.rd_data[j];
    end
    
    if (reset_check === 1)begin
      if(top_test_cfg.act_chdata !== 'h0 )begin
        `nnc_error("TEST", $sformatf("MISMATCH ERROR for reset_check=1 reading channel %0d, exp_chdata[%0d] = %h, act_chdata=%0h", imeas_data_sel,imeas_data_sel,'h0,top_test_cfg.act_chdata))
      end
      else begin
        `nnc_info("TEST", $sformatf("MATCH reset_check=1 for reading channel %0d, exp_chdata[%0d] = %h, act_chdata=%0h", imeas_data_sel,imeas_data_sel,'h0,top_test_cfg.act_chdata),NNC_LOW)
      end
    end
    else begin
      if(top_test_cfg.act_chdata !== `DUT_IF.exp_chdata[imeas_data_sel])begin
        `nnc_error("TEST", $sformatf("MISMATCH ERROR for reading channel %0d, exp_chdata[%0d] = %h, act_chdata=%0h", imeas_data_sel,imeas_data_sel,`DUT_IF.exp_chdata[imeas_data_sel],top_test_cfg.act_chdata))
      end
      else begin
        `nnc_info("TEST", $sformatf("MATCH for reading channel %0d, exp_chdata[%0d] = %h, act_chdata=%0h", imeas_data_sel,imeas_data_sel,`DUT_IF.exp_chdata[imeas_data_sel],top_test_cfg.act_chdata),NNC_LOW)
      end
    end
  endtask : compare_imeas_chdata

  task compare_imeas_chdata_through_rdata_cmd(bit reset_check);

    if(`DUT_IF.daisy_en == 1)
      if(`DUT_IF.total_chip_num == 3) 
        total_adc_ch_to_read = `DUT_IF.max_ch_dev1 + `DUT_IF.max_ch_dev2 + `DUT_IF.max_ch_dev2;
      else 
        total_adc_ch_to_read = `DUT_IF.max_ch_dev1 + `DUT_IF.max_ch_dev2;
    else
      total_adc_ch_to_read = `DUT_IF.max_ch_dev1;

    // 5 bytes status, data : 4 bytes/3 bytes
    data_bytes_per_sample =  (`DUT_IF.imeas_status_en == 0 && `DUT_IF.imeas_24bitdata_en == 0) ? total_adc_ch_to_read*4
                            :(`DUT_IF.imeas_status_en == 0 && `DUT_IF.imeas_24bitdata_en == 1) ? total_adc_ch_to_read*3
                            :(`DUT_IF.daisy_en == 0 && `DUT_IF.imeas_status_en == 1 && `DUT_IF.imeas_24bitdata_en == 0) ? (total_adc_ch_to_read*4) + 5
                            :(`DUT_IF.daisy_en == 0 && `DUT_IF.imeas_status_en == 1 && `DUT_IF.imeas_24bitdata_en == 1) ? (total_adc_ch_to_read*3) + 5 
                            :(`DUT_IF.daisy_en == 1 && `DUT_IF.imeas_status_en == 1 && `DUT_IF.imeas_24bitdata_en == 0) ? (total_adc_ch_to_read*4) + 5 + 5 // 2 times status 5 status bytes as daisy - 2 device
                            :(`DUT_IF.daisy_en == 1 && `DUT_IF.imeas_status_en == 1 && `DUT_IF.imeas_24bitdata_en == 1) ? (total_adc_ch_to_read*3) + 5 + 5 // 2 times status 5 status bytes as daisy - 2 device
                            : 0;

    if(`DUT_IF.total_chip_num == 3) data_bytes_per_sample = data_bytes_per_sample + 5; // status added for dev3

    if(rdatac_cmd_en == 1)begin
      `nnc_info("SOC_TEST", $sformatf("will send RDATAC cmd for total_adc_ch_to_read = %0d, data_bytes_per_sample=%0d",total_adc_ch_to_read,data_bytes_per_sample), NNC_LOW)
      fork 
        begin
	  for(int j = 0; j < `DUT_IF.no_of_samples;j++)begin
	    wait_for_intb();
            wait_for_intb_clear();
            if(`DUT_IF.filter_case)begin
              exp_chdata = `DUT_IF.filter_data_out;
            end
            else begin
              exp_chdata = `DUT_IF.exp_chdata;
            end
	    for(int k = 0; k < `DUT_IF.max_ch_dev1;k++)begin
              top_test_cfg.exp_chdata_combined_rdatac[j][k] = exp_chdata[k]; 
	      //`nnc_info("SOC_TEST", $sformatf("exp_chdata_combined_rdatac[%0d][%0d] = %0h",j,k,top_test_cfg.exp_chdata_combined_rdatac[j][k]), NNC_LOW)
            end
          end
        end
        begin
          `nnc_info("SOC_TEST", $sformatf("rdatac_cmd_en %0d, no_of_samples = %0d",rdatac_cmd_en,`DUT_IF.no_of_samples), NNC_LOW)
          `RD_CONV_BY_RDATAC(`DUT_IF.no_of_samples,data_bytes_per_sample, {!`DUT_IF.imeas_status_en, `DUT_IF.imeas_24bitdata_en}, top_test_cfg.rd_data);
          `nnc_info("SOC_TEST", $sformatf("rdatac cmd is done "), NNC_LOW)
        end
      join
    end
    else begin
      `nnc_info("SOC_TEST", $sformatf("will send RDATA cmd for total_adc_ch_to_read = %0d, data_bytes_per_sample=%0d",total_adc_ch_to_read,data_bytes_per_sample), NNC_LOW)
      `DUT_IF.rd_data_cmd_in_progress = 1;
      `RD_CONV_BY_RDATA({`DUT_IF.total_chip_num,`DUT_IF.max_ch_dev2[4:0], `DUT_IF.max_ch_dev1[4:0]}, data_bytes_per_sample, {`DUT_IF.daisy_en, !`DUT_IF.imeas_status_en, `DUT_IF.imeas_24bitdata_en}, top_test_cfg.rd_data);
      `DUT_IF.rd_data_cmd_in_progress = 0;
    end
    
    //for(int k = 0; k < top_test_cfg.rd_data.size();k++)begin
    //  `nnc_info("SOC_TEST", $sformatf("top_test_cfg.rd_data = %0h",top_test_cfg.rd_data[k]), NNC_LOW)
    //end

    status_check();
    collect_act_data();
    data_check();

  endtask : compare_imeas_chdata_through_rdata_cmd

  task status_check;
    int status_byte_loc;
    if(`DUT_IF.imeas_status_en == 1)begin 

      exp_status_bits = 40'hAABB_CCDD_EE;

      if(rdatac_cmd_en == 1)begin // RDATAC cmd status check
        // conv-0 : 5 byte status    [25:21]
        //        : 4 byte adc0 data [20:17]
        //        : 4 byte adc1 data [16:13]
        // conv-1 : 5 byte status    [12:8]
        //        : 4 byte adc0 data [7:4]
        //        : 4 byte adc1 data [3:0]

        status_byte_loc = data_bytes_per_sample;
        for(int j = 0; j < `DUT_IF.no_of_samples;j++)begin
          act_status_bits = {top_test_cfg.rd_data[status_byte_loc - 1],top_test_cfg.rd_data[status_byte_loc - 2],top_test_cfg.rd_data[status_byte_loc - 3],
                            top_test_cfg.rd_data[status_byte_loc - 4],top_test_cfg.rd_data[status_byte_loc - 5]}; 
          if(act_status_bits != exp_status_bits)begin
            `nnc_error("TEST", $sformatf("DEV1 MISMATCH ERROR for STATUS status_byte_loc =%0d exp_status_bits= %0h, act_status_bits=%0h", status_byte_loc,exp_status_bits,act_status_bits))
          end
          else begin
            `nnc_info("TEST", $sformatf("DEV1 MATCH for STATUS status_byte_loc = %0d exp_status_bits = %0h, act_status_bits=%0h", status_byte_loc, exp_status_bits,act_status_bits),NNC_LOW)
          end
          status_byte_loc = status_byte_loc + data_bytes_per_sample;
        end
      end
      else begin // RDATA cmd status check
        //`nnc_info("SOC_TEST", $sformatf("data_bytes_per_sample = %0d",data_bytes_per_sample), NNC_LOW)
        // DEV1 status check
        act_status_bits = {top_test_cfg.rd_data[data_bytes_per_sample - 1],top_test_cfg.rd_data[data_bytes_per_sample - 2],top_test_cfg.rd_data[data_bytes_per_sample - 3],
                          top_test_cfg.rd_data[data_bytes_per_sample - 4],top_test_cfg.rd_data[data_bytes_per_sample - 5]}; 
        
        if(act_status_bits != exp_status_bits)begin
          `nnc_error("TEST", $sformatf("DEV1 MISMATCH ERROR for STATUS exp_status_bits= %0h, act_status_bits=%0h", exp_status_bits,act_status_bits))
        end
        else begin
          `nnc_info("TEST", $sformatf("DEV1 MATCH for STATUS exp_status_bits = %0h, act_status_bits=%0h", exp_status_bits,act_status_bits),NNC_LOW)
        end

        // DEV2 status check
	if(`DUT_IF.daisy_en == 1) begin
          if(`DUT_IF.imeas_24bitdata_en == 0) 
            status_byte_loc =  data_bytes_per_sample - 5 - (`DUT_IF.max_ch_dev1*4);
          else
            status_byte_loc =  data_bytes_per_sample - 5 - (`DUT_IF.max_ch_dev1*3);

          act_status_bits = {top_test_cfg.rd_data[status_byte_loc - 1],top_test_cfg.rd_data[status_byte_loc - 2],top_test_cfg.rd_data[status_byte_loc - 3],
                            top_test_cfg.rd_data[status_byte_loc - 4],top_test_cfg.rd_data[status_byte_loc - 5]}; 

          if(act_status_bits != exp_status_bits)begin
            `nnc_error("TEST", $sformatf("DEV2 MISMATCH ERROR for STATUS exp_status_bits= %0h, act_status_bits=%0h", exp_status_bits,act_status_bits))
          end
          else begin
            `nnc_info("TEST", $sformatf("DEV2 MATCH for STATUS exp_status_bits = %0h, act_status_bits=%0h", exp_status_bits,act_status_bits),NNC_LOW)
          end

          // DEV3 status check
          if(`DUT_IF.total_chip_num == 3)begin
	    exp_status_bits = ~exp_status_bits;
            if(`DUT_IF.imeas_24bitdata_en == 0) 
              status_byte_loc =  data_bytes_per_sample - 5 - (`DUT_IF.max_ch_dev1*4) - 5 - (`DUT_IF.max_ch_dev2*4);
            else
              status_byte_loc =  data_bytes_per_sample - 5 - (`DUT_IF.max_ch_dev1*3) - 5 - (`DUT_IF.max_ch_dev2*3);

	      act_status_bits = {top_test_cfg.rd_data[status_byte_loc - 1],top_test_cfg.rd_data[status_byte_loc - 2],top_test_cfg.rd_data[status_byte_loc - 3],
                            top_test_cfg.rd_data[status_byte_loc - 4],top_test_cfg.rd_data[status_byte_loc - 5]};

            if(act_status_bits != exp_status_bits)begin
              `nnc_error("TEST", $sformatf("DEV3 MISMATCH ERROR for STATUS exp_status_bits= %0h, act_status_bits=%0h", exp_status_bits,act_status_bits))
            end
            else begin
              `nnc_info("TEST", $sformatf("DEV3 MATCH for STATUS exp_status_bits = %0h, act_status_bits=%0h", exp_status_bits,act_status_bits),NNC_LOW)
            end

          end
        end
      end
    end

  endtask : status_check

  task collect_act_data();
    int total_adc_data_bytes; 
    int data_bytes_loc; 
    // collect actual data 
    if(rdatac_cmd_en == 1)begin // RDATAC cmd , act data collect

      if(`DUT_IF.imeas_status_en == 1)begin 
        total_adc_data_bytes = (`DUT_IF.no_of_samples * data_bytes_per_sample) - 5;
      end
      else begin
        total_adc_data_bytes = (`DUT_IF.no_of_samples * data_bytes_per_sample) ;
      end
      `nnc_info("SOC_TEST", $sformatf(" total_adc_data_bytes %0d",total_adc_data_bytes), NNC_LOW)

      //data is stored at,
      //conv 0 : adc0 : rd_data byte[20:17]
      //         adc1 : rd_data byte[16:13]
      //conv 1 : adc0 : rd_data byte[7:4]
      //       : adc1 : rd_data byte[3:0]

      // form final act_chdata_combined_rdatac
      // act_chdata_combined_rdatac[conv0][adc0] = rd_data byte[20:17]
      // act_chdata_combined_rdatac[conv0][adc1] = rd_data byte[16:13]
      // act_chdata_combined_rdatac[conv1][adc0] = rd_data byte[7:4]
      // act_chdata_combined_rdatac[conv1][adc1] = rd_data byte[3:0]

      for(int k = 0; k < `DUT_IF.no_of_samples;k++)begin
        if (`DUT_IF.imeas_24bitdata_en == 0) begin
          for(int i = 0;i < total_adc_ch_to_read ;i++)begin
            for (int j = 0;j < 4 ;j++)begin  //32 bits
	    //`nnc_info("SOC_TEST", $sformatf(" data_bytes_per_sample = %0d, total_adc_ch_to_read %0d",data_bytes_per_sample,total_adc_ch_to_read), NNC_LOW)
	    //`nnc_info("SOC_TEST", $sformatf(" top_test_cfg.rd_data[%0d]= %0h",(total_adc_data_bytes - (k*data_bytes_per_sample)) - (i*4) - 1 - j,top_test_cfg.rd_data[(total_adc_data_bytes - (k*data_bytes_per_sample)) - (i*4) - 1 - j]), NNC_LOW)
              top_test_cfg.act_chdata_combined_rdatac[k][i][(3 - j)*8 +: 8] = top_test_cfg.rd_data[(total_adc_data_bytes - (k*data_bytes_per_sample)) - (i*4) - 1 - j];
            end
	    //`nnc_info("SOC_TEST", $sformatf("act_chdata_combined_rdatac[%0d][%0d] = %0h",k,i,top_test_cfg.act_chdata_combined_rdatac[k][i]), NNC_LOW)
          end
        end
        else begin
          for(int i = 0;i < total_adc_ch_to_read ;i++)begin
            for (int j = 0;j < 3 ;j++)begin  //24 bits
              top_test_cfg.act_chdata_combined_rdatac[k][i][(3 - j)*8 +: 8] = top_test_cfg.rd_data[(total_adc_data_bytes - (k*data_bytes_per_sample)) - (i*3) - 1 - j];
	      //`nnc_info("SOC_TEST", $sformatf("act_chdata_combined_rdatac[%0d][%0d] = %0h",k,i,top_test_cfg.act_chdata_combined_rdatac[k][i]), NNC_LOW)
            end
          end
        end
      end
    end
    else begin // RDATA cmd , act data collect
      // daisy = 1, status_en = 1 
      if(`DUT_IF.daisy_en == 1 && `DUT_IF.imeas_status_en == 1) begin
        // DEV1 data 
        data_bytes_loc = data_bytes_per_sample - 5 ;
	`nnc_info("SOC_TEST", $sformatf(" DEV1 data_bytes_loc = [%0d]",data_bytes_loc), NNC_LOW)
	if (`DUT_IF.imeas_24bitdata_en == 0) begin
          for(int i = 0;i < `DUT_IF.max_ch_dev1 ;i++)begin
            for (int j = 0;j < 4 ;j++)begin  //32 bits
              top_test_cfg.act_chdata_combined[i][(3 - j)*8 +: 8] = top_test_cfg.rd_data[((data_bytes_loc - (i*4)) -1) - j];
            end
	      `nnc_info("SOC_TEST", $sformatf(" DEV1 act_chdata_combined[%0d]= %0h",i,top_test_cfg.act_chdata_combined[i]), NNC_LOW)
          end
        end
        else begin
          for(int i = 0;i < `DUT_IF.max_ch_dev1 ;i++)begin
            for (int j = 0;j < 3 ;j++)begin  //24 bits
              top_test_cfg.act_chdata_combined[i][(3 - j)*8 +: 8] = top_test_cfg.rd_data[((data_bytes_loc - (i*3)) -1) - j];
            end
          end
        end

        //DEV2 data
        if (`DUT_IF.imeas_24bitdata_en == 0) begin
          data_bytes_loc =  data_bytes_per_sample - 5 - (`DUT_IF.max_ch_dev1*4) - 5;
	  `nnc_info("SOC_TEST", $sformatf(" DEV2 data_bytes_loc = [%0d]",data_bytes_loc), NNC_LOW)
          for(int i = 0;i < `DUT_IF.max_ch_dev2 ;i++)begin
            for (int j = 0;j < 4 ;j++)begin  //32 bits
              top_test_cfg.act_chdata_combined[i + `DUT_IF.max_ch_dev1][(3 - j)*8 +: 8] = top_test_cfg.rd_data[((data_bytes_loc-(i*4)) -1) - j];
            end
	      `nnc_info("SOC_TEST", $sformatf(" DEV2 act_chdata_combined[%0d]= %0h",i + `DUT_IF.max_ch_dev1,top_test_cfg.act_chdata_combined[i + `DUT_IF.max_ch_dev1]), NNC_LOW)
          end
        end
        else begin
         data_bytes_loc =  data_bytes_per_sample - 5 - (`DUT_IF.max_ch_dev1*3) - 5;
	 `nnc_info("SOC_TEST", $sformatf(" DEV2 data_bytes_loc = [%0d]",data_bytes_loc), NNC_LOW)
          for(int i = 0;i < `DUT_IF.max_ch_dev2 ;i++)begin
            for (int j = 0;j < 3 ;j++)begin  //24 bits
              top_test_cfg.act_chdata_combined[i + `DUT_IF.max_ch_dev1][(3 - j)*8 +: 8] = top_test_cfg.rd_data[((data_bytes_loc-(i*3)) -1) - j];
            end
          end
        end

        // DEV3 data
        if(`DUT_IF.total_chip_num == 3)begin
	  if (`DUT_IF.imeas_24bitdata_en == 0) begin
            data_bytes_loc =  data_bytes_per_sample - 5 - (`DUT_IF.max_ch_dev1*4) - 5 - (`DUT_IF.max_ch_dev2*4) - 5;
	    `nnc_info("SOC_TEST", $sformatf(" DEV3 data_bytes_loc = [%0d]",data_bytes_loc), NNC_LOW)
            for(int i = 0;i < `DUT_IF.max_ch_dev2 ;i++)begin
              for (int j = 0;j < 4 ;j++)begin  //32 bits
                top_test_cfg.act_chdata_combined[i + `DUT_IF.max_ch_dev1 + `DUT_IF.max_ch_dev2][(3 - j)*8 +: 8] = top_test_cfg.rd_data[((data_bytes_loc-(i*4)) -1) - j];
              end
	        `nnc_info("SOC_TEST", $sformatf(" DEV3 act_chdata_combined[%0d]= %0h",i + `DUT_IF.max_ch_dev1 + `DUT_IF.max_ch_dev2,top_test_cfg.act_chdata_combined[i + `DUT_IF.max_ch_dev1 + `DUT_IF.max_ch_dev2]), NNC_LOW)
            end
          end
          else begin
           data_bytes_loc =  data_bytes_per_sample - 5 - (`DUT_IF.max_ch_dev1*3) - 5 - (`DUT_IF.max_ch_dev1*3) - 5; 
	   `nnc_info("SOC_TEST", $sformatf(" DEV3 data_bytes_loc = [%0d]",data_bytes_loc), NNC_LOW)
            for(int i = 0;i < `DUT_IF.max_ch_dev2 ;i++)begin
              for (int j = 0;j < 3 ;j++)begin  //24 bits
                top_test_cfg.act_chdata_combined[i + `DUT_IF.max_ch_dev1 + `DUT_IF.max_ch_dev2][(3 - j)*8 +: 8] = top_test_cfg.rd_data[((data_bytes_loc-(i*3)) -1) - j];
              end
            end
          end
        end
      end
      else begin
        // this logic works for ,
        // daisy = 0, status_en = 0 
        // daisy = 0, status_en = 1 
        // daisy = 1, status_en = 0 

        // DEV1 data 
        data_bytes_loc = total_adc_ch_to_read;
        if (`DUT_IF.imeas_24bitdata_en == 0) begin
          for(int i = 0;i < data_bytes_loc ;i++)begin
            for (int j = 0;j < 4 ;j++)begin  //32 bits
              top_test_cfg.act_chdata_combined[i][(3 - j)*8 +: 8] = top_test_cfg.rd_data[((data_bytes_loc-i) *4 -1) - j];
            end
          end
        end
        else begin
          for(int i = 0;i < data_bytes_loc ;i++)begin
            for (int j = 0;j < 3 ;j++)begin  //24 bits
              top_test_cfg.act_chdata_combined[i][(3 - j)*8 +: 8] = top_test_cfg.rd_data[((data_bytes_loc-i) *3 -1) - j];
            end
          end
        end
      end

    end

  endtask : collect_act_data

  task data_check();
    if(rdatac_cmd_en == 1)begin // RDATAC cmd data check
      for(int j = 0; j < `DUT_IF.no_of_samples;j++)begin
        for(int k = 0; k < `DUT_IF.max_ch_dev1;k++)begin
          if((`DUT_IF.imeas_24bitdata_en == 0 && (top_test_cfg.act_chdata_combined_rdatac[j][k] !== top_test_cfg.exp_chdata_combined_rdatac[j][k]))
             || (`DUT_IF.imeas_24bitdata_en == 1 && (top_test_cfg.act_chdata_combined_rdatac[j][k][31:8] !== top_test_cfg.exp_chdata_combined_rdatac[j][k][31:8])))begin
             `nnc_error("TEST", $sformatf("DEV1 MISMATCH ERROR for exp_chdata[sample_%0d][ch_%0d] = %h, act_chdata_combined[sample_%0d][ch_%0d]=%0h",j,k,top_test_cfg.exp_chdata_combined_rdatac[j][k],j,k,top_test_cfg.act_chdata_combined_rdatac[j][k]))
          end
          else begin
             `nnc_info("TEST", $sformatf("DEV1 MATCH for exp_chdata[sample_%0d][ch_%0d] = %h, act_chdata_combined[sample_%0d][ch_%0d]=%0h",j,k,top_test_cfg.exp_chdata_combined_rdatac[j][k],j,k,top_test_cfg.act_chdata_combined_rdatac[j][k]),NNC_LOW)
          end
        end
      end
    end
    else begin // RDATA cmd data check - with or without status same logic works
      if(`DUT_IF.filter_case)begin
        exp_chdata = `DUT_IF.filter_data_out;
      end
      else begin
        exp_chdata = `DUT_IF.exp_chdata;
      end
      rdata_cmd_data_check("DEV1");

      if(`DUT_IF.daisy_en == 1) begin
        if(`DUT_IF.filter_case)begin
          exp_chdata = `DUT_IF.filter_data_out_dev2;
        end
        else begin
          exp_chdata = `DUT_IF.exp_chdata_dev2;
        end
        rdata_cmd_data_check("DEV2");

        if(`DUT_IF.total_chip_num == 3)begin
          foreach(exp_chdata[i]) begin
            exp_chdata[i] = ~(`DUT_IF.exp_chdata_dev2[i]);
          end
          rdata_cmd_data_check("DEV3");
        end
      end
    end

//    // DEV1 data 
//    for(int k = 0; k < `DUT_IF.max_ch_dev1;k++)begin
//      //`nnc_info("SOC_TEST", $sformatf("top_test_cfg.act_chdata_combined = %0h",top_test_cfg.act_chdata_combined[k]), NNC_LOW)
//      if((`DUT_IF.imeas_24bitdata_en == 0 && (top_test_cfg.act_chdata_combined[k] !== exp_chdata[k])) 
//           || (`DUT_IF.imeas_24bitdata_en == 1 && (top_test_cfg.act_chdata_combined[k][31:8] !== exp_chdata[k][31:8])))begin
//          `nnc_error("TEST", $sformatf("DEV1 MISMATCH ERROR for reading channel %0d, exp_chdata[%0d] = %h, act_chdata_combined=%0h", k,k,exp_chdata[k],top_test_cfg.act_chdata_combined[k]))
//        end
//        else begin
//          `nnc_info("TEST", $sformatf("DEV1 MATCH for reading channel %0d, exp_chdata[%0d] = %h, act_chdata_combined=%0h", k,k,`DUT_IF.exp_chdata[k],top_test_cfg.act_chdata_combined[k]),NNC_LOW)
//        end
//      end
//    end
//
//    if(`DUT_IF.daisy_en == 1) begin
//      // DEV2 data 
//      for(int k = 0; k < `DUT_IF.max_ch_dev2;k++)begin
//        //`nnc_info("SOC_TEST", $sformatf("top_test_cfg.act_chdata_combined = %0h",top_test_cfg.act_chdata_combined[k]), NNC_LOW)
//        if(`DUT_IF.filter_case == 1)begin
//          if(top_test_cfg.act_chdata_combined[k] !== `DUT_IF.filter_data_out[k])begin
//            `nnc_error("TEST", $sformatf("DEV1 MISMATCH ERROR for reading channel %0d, exp_chdata[%0d] = %h, act_chdata_combined=%0h", k,k,`DUT_IF.filter_data_out[k],top_test_cfg.act_chdata_combined[k]))
//          end
//          else begin
//            `nnc_info("TEST", $sformatf("DEV1 MATCH for reading channel %0d, exp_chdata[%0d] = %h, act_chdata_combined=%0h", k,k,`DUT_IF.exp_chdata[k],top_test_cfg.act_chdata_combined[k]),NNC_LOW)
//          end
//        end
//        else begin
//          if((`DUT_IF.imeas_24bitdata_en == 0 && (top_test_cfg.act_chdata_combined[k + `DUT_IF.max_ch_dev1] !== `DUT_IF.exp_chdata_dev2[k]))
//            || (`DUT_IF.imeas_24bitdata_en == 1 && (top_test_cfg.act_chdata_combined[k + `DUT_IF.max_ch_dev1][31:8] !== `DUT_IF.exp_chdata_dev2[k][31:8])))begin
//            `nnc_error("TEST", $sformatf("DEV2 MISMATCH ERROR for reading channel %0d, exp_chdata_dev2[%0d] = %h, act_chdata_combined=%0h", k,k,`DUT_IF.exp_chdata_dev2[k],top_test_cfg.act_chdata_combined[k + `DUT_IF.max_ch_dev1]))
//          end
//          else begin
//            `nnc_info("TEST", $sformatf("DEV2 MATCH for reading channel %0d, exp_chdata_dev2[%0d] = %h, act_chdata_combined=%0h", k,k,`DUT_IF.exp_chdata_dev2[k],top_test_cfg.act_chdata_combined[k + `DUT_IF.max_ch_dev1]),NNC_LOW)
//          end
//        end
//      end
//    end
  endtask : data_check

  task rdata_cmd_data_check(string str);
    if(str == "DEV1") begin
      for(int k = 0; k < `DUT_IF.max_ch_dev1;k++)begin
        //`nnc_info("SOC_TEST", $sformatf("top_test_cfg.act_chdata_combined = %0h",top_test_cfg.act_chdata_combined[k]), NNC_LOW)
        if((`DUT_IF.imeas_24bitdata_en == 0 && (top_test_cfg.act_chdata_combined[k] !== exp_chdata[k])) 
           || (`DUT_IF.imeas_24bitdata_en == 1 && (top_test_cfg.act_chdata_combined[k][31:8] !== exp_chdata[k][31:8])))begin
          `nnc_error("TEST", $sformatf("%s MISMATCH ERROR for reading channel %0d, exp_chdata[%0d] = %h, act_chdata_combined=%0h",str, k,k,exp_chdata[k],top_test_cfg.act_chdata_combined[k]))
        end
        else begin
          `nnc_info("TEST", $sformatf("%s MATCH for reading channel %0d, exp_chdata[%0d] = %h, act_chdata_combined=%0h", str,k,k,`DUT_IF.exp_chdata[k],top_test_cfg.act_chdata_combined[k]),NNC_LOW)
        end
      end
    end
    if(str == "DEV2") begin
      for(int k = 0; k < `DUT_IF.max_ch_dev2;k++)begin
        //`nnc_info("SOC_TEST", $sformatf("top_test_cfg.act_chdata_combined = %0h",top_test_cfg.act_chdata_combined[k]), NNC_LOW)
        if((`DUT_IF.imeas_24bitdata_en == 0 && (top_test_cfg.act_chdata_combined[k + `DUT_IF.max_ch_dev1] !== exp_chdata[k])) 
           || (`DUT_IF.imeas_24bitdata_en == 1 && (top_test_cfg.act_chdata_combined[k + `DUT_IF.max_ch_dev1][31:8] !== exp_chdata[k][31:8])))begin
          `nnc_error("TEST", $sformatf("%s MISMATCH ERROR for reading channel %0d, exp_chdata[%0d] = %h, act_chdata_combined=%0h",str, k,k,exp_chdata[k],top_test_cfg.act_chdata_combined[k + `DUT_IF.max_ch_dev1]))
        end
        else begin
          `nnc_info("TEST", $sformatf("%s MATCH for reading channel %0d, exp_chdata[%0d] = %h, act_chdata_combined=%0h", str,k,k,`DUT_IF.exp_chdata[k],top_test_cfg.act_chdata_combined[k + `DUT_IF.max_ch_dev1]),NNC_LOW)
        end
      end
    end
    if(str == "DEV3") begin
      for(int k = 0; k < `DUT_IF.max_ch_dev2;k++)begin
        //`nnc_info("SOC_TEST", $sformatf("top_test_cfg.act_chdata_combined = %0h",top_test_cfg.act_chdata_combined[k]), NNC_LOW)
        if((`DUT_IF.imeas_24bitdata_en == 0 && (top_test_cfg.act_chdata_combined[k + `DUT_IF.max_ch_dev1 + `DUT_IF.max_ch_dev2] !== exp_chdata[k])) 
           || (`DUT_IF.imeas_24bitdata_en == 1 && (top_test_cfg.act_chdata_combined[k + `DUT_IF.max_ch_dev1 + `DUT_IF.max_ch_dev2][31:8] !== exp_chdata[k][31:8])))begin
          `nnc_error("TEST", $sformatf("%s MISMATCH ERROR for reading channel %0d, exp_chdata[%0d] = %h, act_chdata_combined=%0h",str, k,k,exp_chdata[k],top_test_cfg.act_chdata_combined[k + `DUT_IF.max_ch_dev1 + `DUT_IF.max_ch_dev2]))
        end
        else begin
          `nnc_info("TEST", $sformatf("%s MATCH for reading channel %0d, exp_chdata[%0d] = %h, act_chdata_combined=%0h", str,k,k,`DUT_IF.exp_chdata[k],top_test_cfg.act_chdata_combined[k + `DUT_IF.max_ch_dev1 + `DUT_IF.max_ch_dev2]),NNC_LOW)
        end
      end

    end


  endtask : rdata_cmd_data_check

  task overlap_conversion_check();

  fork
  forever begin
    @(posedge `DUT_IF.rd_data_cmd_in_progress);

    fork :inside_fork
      begin
        wait(`DUT_IF.rd_data_cmd_in_progress == 0);
      end

      begin
        wait(`DUT_IF.imeas_pos_done === 1);    
        if(`DUT_IF.imeas_overlap_en === 1)
          `nnc_error("SOC_TEST", " ERROR : overlap of conversion during read data cmd")
        else
          `nnc_warning("SOC_TEST", " WARNING : overlap of conversion during read data cmd")
      end
    join_any
    disable inside_fork;
  end
  join_none

  endtask : overlap_conversion_check

  task pulse_INTB_active_high_check;
  begin
    forever @(posedge `SOC_TB.INTB) begin
      if((`DUT_IF.intr_length_slct_level_or_pulse === 1) && (`DUT_IF.int_active_level_high_or_low === 1)) begin//if active high pulse INTB is selected
	@(posedge `DUT_IF.sys_clk);
	@(negedge `DUT_IF.sys_clk);
        if(`SOC_TB.INTB !== 0 && (!(`IMEAS_WRAPPER_TOP.o_eeg_int === 1)))
    	  `nnc_error("SOC_TEST", "Error! pulse INTB more than 1 pclk!")
	else
	  `nnc_info("SOC_TEST", "pulse INTB is 1 pclk!", NNC_MEDIUM)
      end 
    end
  end
  endtask

  task pulse_INTB_active_low_check;
  begin
    forever @(negedge `SOC_TB.INTB) begin
      if((`DUT_IF.intr_length_slct_level_or_pulse === 1) && (`DUT_IF.int_active_level_high_or_low === 0)) begin//if active low pulse INTB is selected
	@(posedge `DUT_IF.sys_clk);
	@(negedge `DUT_IF.sys_clk);
        if(`SOC_TB.INTB !== 1 && !((`IMEAS_WRAPPER_TOP.o_eeg_int === 1)))
    	  `nnc_error("SOC_TEST", "Error! pulse INTB more than 1 pclk!")
	else
	  `nnc_info("SOC_TEST", "pulse INTB is 1 pclk!", NNC_MEDIUM)
      end 
    end
  end
  endtask

  task level_INTB_active_high_check;
  begin
    forever @(posedge `SOC_TB.INTB or negedge `SOC_TB.INTB) begin
      if((`DUT_IF.intr_length_slct_level_or_pulse === 0) && (`DUT_IF.int_active_level_high_or_low === 1)) begin//if active high level INTB is selected
        if(`SOC_TB.INTB !== (`IMEAS_WRAPPER_TOP.o_eeg_int))
    	  `nnc_error("SOC_TEST", "Error! level INTB not expected!")
	else
	  `nnc_info("SOC_TEST", "level INTB is expected!", NNC_MEDIUM)
      end 
    end
  end
  endtask

  task level_INTB_active_low_check;
  begin
    forever @(posedge `SOC_TB.INTB or negedge `SOC_TB.INTB) begin
      if((`DUT_IF.intr_length_slct_level_or_pulse === 0) && (`DUT_IF.int_active_level_high_or_low === 0)) begin//if active low level INTB is selected
        if(`SOC_TB.INTB !== ~(`IMEAS_WRAPPER_TOP.o_eeg_int))
    	  `nnc_error("SOC_TEST", "Error! level INTB not expected!")
	else
	  `nnc_info("SOC_TEST", "level INTB is expected!", NNC_MEDIUM)
      end 
    end
  end
  endtask

  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction

  virtual task post_main_phase(nnc_phase phase);
     phase.raise_objection(this);

     super.post_main_phase(phase);

     if(`DUT_IF.imeas_sin_gen_en === 1)
     	`SOC_TB.py_tb.do_run_python();

     phase.drop_objection(this);
  endtask

endclass : `TESTNAME
