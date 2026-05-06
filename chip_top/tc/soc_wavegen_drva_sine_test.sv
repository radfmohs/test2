/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_wavegen_drva_sine_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_wavegen_drva_sine_test                                             
// Designer	: ophina@nanochap.com                                                                 
// Date		: 18-03-2024                                                                   
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

//***************************************************************************************
// NOTE : The test is intented  to generate sine wave for driver1 & driver2
//***************************************************************************************

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_wavegen_drva_sine_test
`define TESTCFG soc_wavegen_drva_sine_test_cfg

class `TESTCFG extends soc_wavegen_base_test_cfg;

  `nnc_object_utils(`TESTCFG)

  // ===============================================
  // Adding your new varialbles in config test
  // -----------------------------------------------
    
  rand logic [7:0] wr_data[256];
  rand int         no_of_bytes; 
  rand logic [7:0] reg_addr;
  rand logic [7:0] pads;
  rand logic [7:0] mask;
  rand logic [7:0] expected_data;
  logic [7:0]      rd_data[];
  logic [7:0]      sine_data[16][128];
  logic [13:0]     clk_freq;//in Khz
  logic [12:0]     half_period_limit;
  randc logic      same_pos_neg_period;
  rand logic [12:0] half_period0[2];
  rand logic [12:0] half_period1[2];
  rand logic [12:0] half_period2[2];
  logic [31:0]     hlf_wave_lim; // number of clocks for positive half wave
  logic [31:0]     neg_hlf_wave_lim; // number of clocks for negative half wave
  logic [15:0]     rest_lim; // number of clocks for each rest period
  logic [31:0]     silent_lim; // number of clocks for each silent period
  rand logic [1:0] preload_sel;     // preload selection : 11 or 00
  rand logic       neg_ena;
  rand logic       pos_dis;

  rand logic [2:0] points_sel;      
  // Point Selection - 0/1/2/3/4/5/6/7: 64/32/16/8/4/2/1/128 points (load_points_sel = 1) if it is 0, not used

  rand logic [2:0] waveform_sel;    // Waveform selection: 001, 010, 000 - rest values are reserved 
  rand logic       load_points_sel; // waveform_sel: 001 or 010 and preload_sel: 11 -> load_points_sel = 1 
  rand logic       pos_neg_diff_sel;
  rand logic       dac_bit_len_sel;//1'b0:8-bits; 1'b1:12-bits (only 8 bits supported for sine)
  rand logic       auto_man;//1'b0:auto; 1'b1:manual
  rand logic [7:0] dac0_data_l;
  rand logic [3:0] dac0_data_h;
  rand logic [2:0] dac0_msb_sel;
  rand logic [7:0] dac1_data_l;
  rand logic [3:0] dac1_data_h;
  rand logic [2:0] dac1_msb_sel;
  rand logic [7:0] dac2_data_l;
  rand logic [3:0] dac2_data_h;
  rand logic [2:0] dac2_msb_sel;
  rand logic [7:0] dac3_data_l;
  rand logic [3:0] dac3_data_h;
  rand logic [2:0] dac3_msb_sel;
  rand logic       PULLAB_pos_en;
  rand logic       PULLAB_neg_en;
  rand logic [5:0] PULLAB_lim;

       logic [1:0] PRELOAD; 
       // bit[2:1] - WAVEFORM_SEL of register AWG_CTRL_REG0: 0x01
       // 00: Use the preloaded sine value 
       // 01 : Use the preloaded pulse value 
       // 10 : Use the preloaded triangle value 
       // 11: use the waveform loaded by SPI   

       logic       LOAD_POINTS;

       logic [7:0] NO_OF_POINTS; // bit [7:0] POINTS_NUM_SEL_PER_PHASE: 0x02 (AWG Register) 

       logic [7:0] NO_OF_LOAD_POINTS; // = NO_OF_POINTS * (no of wave + 1)

       logic [2:0] NO_OF_WAVEFORMS; 
       // bit [5:3] WAVEFORM_NUM_SEL of register AWG_CTRL_REG0: 0x01

       logic       NEG_ON;          // bit[1] NEGATIVE_PHASE_ENABLE_BIT of register AWG_CONFIG_REG0: 0x00
       logic       POS_OFF;         // bit[7] POSITIVE_PHASE_DISABLE_BIT of register AWG_CONFIG_REG0: 0x00 
       logic       POS_NEG_DIFF;
       logic [7:0] PULLAB_CTRL;
       integer     NO_OF_WAVES;
  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_wavegen_drva_sine_test_cfg");
    super.new(name);
    
  endfunction: new

  // ===============================================
  // Adding constraints of randomization
  // -----------------------------------------------

  // testmode_sel[1:0] : 00-Normal mode, 01: Scanmode, 10: BIST mode, 11 atm0/1/2/3/4
  constraint c_testmode_sel    { soft testmode_sel == 2'b00; }

  // spimode_sel[1:0] :  
  //constraint c_spimode_sel     { spimode_sel == 2'b00; }

  // spi_sclk_freq[15:0]
  //constraint c_spi_sclk_freq   { soft spi_sclk_freq inside {[100:20000]};}//min 100Khz - max 20Mhz

  //pclk_div[2:0]
  //constraint c_pclk_sel    { soft pclk_sel inside {[0:1]};}

  //hfosc_jitter
  constraint c_hfosc_jitter    { soft hfosc_jitter == 0; }// 0%

  //hfosc_variation
  constraint c_hfosc_variation { soft hfosc_variation == 100; }// 0%

  // No of bytes in a burst
  constraint c_no_of_bytes     { soft no_of_bytes == 2; }

  // pads values
  constraint c_pads            { soft pads == 8'h00; }

  // mask values
  constraint c_mask            { soft mask == 8'hff; }

  // altf_sel
  //constraint c_altf_sel    { soft altf_sel == 2'b00; }

  //python_check_en
  constraint c_python_check_en { python_check_en inside {[1:1]}; }

  //preload_sel
  constraint c_preload_sel     { preload_sel inside {0,3};} // bit[2:1] WAVEFORM_SEL of AWG_CTRL_REG0: 0x01 - 00: Preloaded SINE, 11: Used waveform loaded from SPI 

  //neg_ena
  //constraint c_neg_ena         { (/*(load_points_sel == 1'b1) || */(pos_neg_diff_sel == 1'b1) || (python_check_en == 1'b1)) -> neg_ena == 1'b1;}

  constraint c_neg_ena         { neg_ena == 1'b1; }

  //pos_dis
  // constraint c_pos_dis         { ((neg_ena == 1'b0)/* || (load_points_sel == 1'b1)*/ || (pos_neg_diff_sel == 1'b1) || (python_check_en == 1'b1)) -> pos_dis == 1'b0;}
  constraint c_pos_dis         { pos_dis == 1'b0; }


  /*
  Normal waveform:  
  - If 1 waveform used and either pos or neg enabled, then max value is 128. 
  - If 2 waveforms used and either pos or neg enabled, then max value is 64. 
  - If 3 waveforms used and either pos or neg enabled, then max value is 42. 

  - If 1 waveform used and both pos and neg enabled and load value from different registers, then max value is 64. 
  - If 2 waveforms used and both pos and neg enabled and load value from different registers, then max value is 32. 
  - If 3 waveforms used and both pos and neg enabled and load value from different registers, then max value is 21. 

  - If 1 waveform used and both pos and neg enabled and load value from same registers, then max value is 128. 
  - If 2 waveforms used and both pos and neg enabled and load value from same   registers, then max value is 64. 
  - If 3 waveforms used and both pos and neg enabled and load value from same registers, then max value is 42 

  Preload function: 
  The number of points only can be the power of 2: 1, 2, 4, 8, 16, 32, 64, 128 
  */
  //points_sel
  constraint c_points_sel      { (load_points_sel == 1'b0) -> points_sel != 6;
                                 (python_check_en == 1'b1) -> !(points_sel inside {[5:6]});
                                 ((waveform_sel == 3'b000) && (neg_ena == 1'b1) && (pos_dis == 1'b0) && (pos_neg_diff_sel == 1'b0)) -> points_sel inside {[0:6]};
                                 ((waveform_sel == 3'b000) && (neg_ena == 1'b1) && (pos_dis == 1'b0) && (pos_neg_diff_sel == 1'b1)) -> points_sel inside {[0:7]};
                                 ((waveform_sel == 3'b001) && (neg_ena == 1'b1) && (pos_dis == 1'b0) && (pos_neg_diff_sel == 1'b0)) -> points_sel inside {[1:6]};
                                 ((waveform_sel == 3'b001) && (neg_ena == 1'b1) && (pos_dis == 1'b0) && (pos_neg_diff_sel == 1'b1)) -> points_sel inside {[0:6]};
                                 ((waveform_sel == 3'b010) && (neg_ena == 1'b1) && (pos_dis == 1'b0) && (pos_neg_diff_sel == 1'b0)) -> points_sel inside {[2:6]};
                                 ((waveform_sel == 3'b010) && (neg_ena == 1'b1) && (pos_dis == 1'b0) && (pos_neg_diff_sel == 1'b1)) -> points_sel inside {[1:6]};
                                 ((waveform_sel == 3'b000) && ((neg_ena == 1'b0) || (pos_dis == 1'b1))) -> points_sel inside {[0:7]};
                                 ((waveform_sel == 3'b001) && ((neg_ena == 1'b0) || (pos_dis == 1'b1))) -> points_sel inside {[0:6]};
                                 ((waveform_sel == 3'b010) && ((neg_ena == 1'b0) || (pos_dis == 1'b1))) -> points_sel inside {[1:6]};
                               }

  // waveform_sel - when enable python, just check one wave only (WAVEFORM_NUM_SEL bit[5:3] of AWG_CTRL_REG0: 0x01
  constraint c_waveform_sel    { (python_check_en == 1'b1) -> waveform_sel inside {[0:0]};
                                 (python_check_en == 1'b0) -> waveform_sel inside {[0:2]};}

  //load_points_sel: 1 loaded from SPI, 0: SINE preloaded 
  constraint c_load_points_sel { (((waveform_sel == 3'b001) || (waveform_sel == 3'b010)) && (preload_sel == 2'b11)) -> load_points_sel == 1'b1; 
                                 (preload_sel == 2'b00) -> load_points_sel == 1'b0; 
                               }

  //pos_neg_diff_sel - bit [7] RESOLUTION_CTRL  of register AWG_CTRL_REG0: 0x01
  //constraint c_pos_neg_diff_sel { ((load_points_sel == 1'b1) && (python_check_en == 1'b1)) -> pos_neg_diff_sel == 1'b0; }
  constraint c_pos_neg_diff_sel { pos_neg_diff_sel == 1'b1; }

  //auto_man - countinue_waveform - bit[5] of register AWG_CONFIG_REG0: 0x00
  // - 1: Continue repeating the waveform when getting second interrupt 
  // - 0:  Don't continue repeating the waveform when getting second interrupt 
  constraint c_auto_man        { auto_man == 1'b0; }

  //dac_bit_len_sel - multi_electrode - bit[6] of register AWG_CONFIG_REG0: 0x00
  // Driver0:  No matter this bit is 0/1, Driver0 can output its data to Analog. 
  // Other drivers:  
  // 0:  can't output its data to Analog. 
  // 1:  can output its data to Analog. 
  constraint c_dac_bit_len_sel { dac_bit_len_sel == 1'b0;}

  //dac0_msb_sel
  //constraint c_dac0_msb_sel    { dac0_msb_sel inside {[0:4]};}

  //dac1_msb_sel
  //constraint c_dac1_msb_sel    { dac1_msb_sel inside {[0:4]};}

  //PULLAB_pos_en
  //constraint c_PULLAB_pos_en   { (python_check_en == 1'b1) -> PULLAB_pos_en == 1'b0;}

  //PULLAB_neg_en
  //constraint c_PULLAB_neg_en   { (python_check_en == 1'b1) -> PULLAB_neg_en == 1'b0;}

  //PULLAB_lim - Rest-Time_en - bit[0]
  constraint c_PULLAB_lim      { PULLAB_lim != 0;}

  // -----------------------------------------------
  // End of adding constraints of randomization
  // ===============================================

endclass : `TESTCFG

// ===============================================
// Main Testcase is defined
// -----------------------------------------------
class `TESTNAME extends soc_wavegen_base_test;
   
  `nnc_component_utils(`TESTNAME)

  `TESTCFG top_test_cfg;

  // -----------------------------------------
  // Declare the new function 
  // -----------------------------------------
  function new(string name, nnc_component parent);
    super.new(name, parent);
  endfunction

  // -----------------------------------------
  // Declare the build_phase function 
  // -----------------------------------------
  virtual function void build_phase(nnc_phase phase);
    super.build_phase(phase);
    `nnc_top.set_timeout(5s);
    top_test_cfg = `TESTCFG::type_id::create("top_test_cfg", this);
  endfunction

  // -----------------------------------------
  // Declare the pre_reset_phase task 
  // -----------------------------------------
  virtual task pre_reset_phase(nnc_phase phase);
    phase.raise_objection(this);

    super.pre_reset_phase(phase);

    assert(top_test_cfg.randomize());
    
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;

    //`DUT_IF.pclk_sel = top_test_cfg.pclk_sel;
    `DUT_IF.hfosc_jitter = top_test_cfg.hfosc_jitter;
    `DUT_IF.hfosc_variation = top_test_cfg.hfosc_variation;
    //`DUT_IF.altf_sel = top_test_cfg.altf_sel;

    `DUT_IF.python_check_en = top_test_cfg.python_check_en;
    `DUT_IF.waveshape_sel = 2'b00;//indicates sine wave

    `DUT_IF.assertion_on = 1;

    // -------------------
    // Scoreboard enables
    // -------------------
    `NNC_WAVEGEN_REF_SCB_EN = 0;
    `WAVEGEN_SCB_DRV_0_EN = 1'b0;
    `WAVEGEN_SCB_DRV_1_EN = 1'b0;
    `WAVEGEN_SCB_DRV_2_EN = 1'b0;
    `WAVEGEN_SCB_DRV_3_EN = 1'b0;
    `WAVEGEN_SCB_DRV_4_EN = 1'b0;
    `WAVEGEN_SCB_DRV_5_EN = 1'b0;
    `WAVEGEN_SCB_DRV_6_EN = 1'b0;
    `WAVEGEN_SCB_DRV_7_EN = 1'b0;
    `WAVEGEN_SCB_DRV_8_EN = 1'b0;
    `WAVEGEN_SCB_DRV_9_EN = 1'b0;
    `WAVEGEN_SCB_DRV_10_EN = 1'b0;
    `WAVEGEN_SCB_DRV_11_EN = 1'b0;
    `WAVEGEN_SCB_DRV_12_EN = 1'b0;
    `WAVEGEN_SCB_DRV_13_EN = 1'b0;
    `WAVEGEN_SCB_DRV_14_EN = 1'b0;
    `WAVEGEN_SCB_DRV_15_EN = 1'b0;

    phase.drop_objection(this);
  endtask : pre_reset_phase

  // -----------------------------------------
  // Declare the main_phase task of your test
  // -----------------------------------------
  virtual task main_phase(nnc_phase phase);
    phase.raise_objection(this);

    super.main_phase(phase);

    `nnc_info("SOC_TEST", "soc_wavegen_drva_sine_test start", NNC_LOW)

    // ==================================================================================
    // Please add your code of your test here
    // ----------------------------------------------------------------------------------

    // Step 1: Do the common set up for Wavegen
    wavegen_setup(0);//chip 0

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_WAVEGEN_GLOBAL_REG; wr_data[0] == (8'h00<<1);});
    `nnc_info("SOC_TEST", "Enable drivers using global register", NNC_LOW)
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // Step 2: Do the configuration for Wavegen 0
    wavegen_drv_config(2'b00, `WAVEGEN_0_ADDR_BASE);
   
   `WR_WAVEGEN_REG(`SOC_AWG_DRIVEC_SW_CFG0_REG+`WAVEGEN_0_ADDR_BASE, 8'h02, 8'h00);
   `WR_WAVEGEN_REG(`SOC_AWG_DRIVEC_SW_CFG1_REG+`WAVEGEN_0_ADDR_BASE, 8'h00, 8'h00);

    // Step 3: Do the configuration for Wavegen 1
    wavegen_drv_config(2'b00, `WAVEGEN_1_ADDR_BASE);

   `WR_WAVEGEN_REG(`SOC_AWG_DRIVEC_SW_CFG0_REG+`WAVEGEN_1_ADDR_BASE, 8'h01, 8'h00);
   `WR_WAVEGEN_REG(`SOC_AWG_DRIVEC_SW_CFG1_REG+`WAVEGEN_1_ADDR_BASE, 8'h00, 8'h00);

    // Step 4: Do the configuration for Wavegen 2
    wavegen_drv_config(2'b00, `WAVEGEN_2_ADDR_BASE);
    // Step 5: Do the configuration for Wavegen 3
    wavegen_drv_config(2'b00, `WAVEGEN_3_ADDR_BASE);

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_WAVEGEN_GLOBAL_REG; wr_data[0] == (8'h01<<1);});
    `nnc_info("SOC_TEST", "Enable drivers using global register", NNC_LOW)
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // Step 6: Do the configuration for Wavegen 4
    wavegen_drv_config(2'b01, `WAVEGEN_4_ADDR_BASE);
    // Step 7: Do the configuration for Wavegen 5
    wavegen_drv_config(2'b01, `WAVEGEN_5_ADDR_BASE);
    // Step 8: Do the configuration for Wavegen 6
    wavegen_drv_config(2'b01, `WAVEGEN_6_ADDR_BASE);
    // Step 9: Do the configuration for Wavegen 7
    wavegen_drv_config(2'b01, `WAVEGEN_7_ADDR_BASE);

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_WAVEGEN_GLOBAL_REG; wr_data[0] == (8'h02<<1);});
    `nnc_info("SOC_TEST", "Enable drivers using global register", NNC_LOW)
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // Step 10: Do the configuration for Wavegen 8
    wavegen_drv_config(2'b10, `WAVEGEN_8_ADDR_BASE);
    // Step 11: Do the configuration for Wavegen 9
    wavegen_drv_config(2'b10, `WAVEGEN_9_ADDR_BASE);
    // Step 12: Do the configuration for Wavegen 10
    wavegen_drv_config(2'b10, `WAVEGEN_10_ADDR_BASE);
    // Step 13: Do the configuration for Wavegen 11
    wavegen_drv_config(2'b10, `WAVEGEN_11_ADDR_BASE);

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_WAVEGEN_GLOBAL_REG; wr_data[0] == (8'h03<<1);});
    `nnc_info("SOC_TEST", "Enable drivers using global register", NNC_LOW)
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // Step 14: Do the configuration for Wavegen 12
    wavegen_drv_config(2'b11, `WAVEGEN_12_ADDR_BASE);

    // Step 15: Do the configuration for Wavegen 13
    wavegen_drv_config(2'b11, `WAVEGEN_13_ADDR_BASE);

    // Step 16: Do the configuration for Wavegen 14
    wavegen_drv_config(2'b11, `WAVEGEN_14_ADDR_BASE);

    // Step 17: Do the configuration for Wavegen 15
    wavegen_drv_config(2'b11, `WAVEGEN_15_ADDR_BASE);

    // Step 4: Enable all wavegen at the time
    wavegen_drv_enable;

    // Step 5: Waiting for Wave generated successfully
    $display("## --------------------------------------------------------------------------- ##");
    $display("##         WAITING FOR SIMULATION TO COMPLETE WAVEFORM GENERATION              ##");      
    $display("## --------------------------------------------------------------------------- ##");

    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    if(`DUT_IF.python_check_en === 0)
    	#200ms;
    else begin
        wait((`SOC_TB.py_tb.python_data_num_0 === `DUT_IF.python_length) && (`SOC_TB.py_tb.python_data_num_1 === `DUT_IF.python_length));
	#1ms;
    end
    `nnc_info("SOC_TEST", "soc_wavegen_drva_sine_test end now", NNC_LOW)

    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ==================================================================================

    phase.drop_objection(this);
  endtask: main_phase


  // *************************************************************
  // This task is used for calculating periods beasing on clocks 
  // 1- Positive phase period (positive half of cycle)
  // 2- Negative phase period (negative half of cycle)
  // 3- Rest period
  // 4- Silent period  
  // ************************************************************* 
  task wavegen_calc_clock_num;
  input [13:0] clk_freq;
  input [15:0] rest_t;
  input [31:0] silent_t;
  input [31:0] hlf_wave_per;
  input [31:0] neg_hlf_wave_per;
  begin
    top_test_cfg.hlf_wave_lim = (hlf_wave_per * {20'b0,clk_freq}) / 1000;
    top_test_cfg.neg_hlf_wave_lim = (neg_hlf_wave_per * {20'b0,clk_freq}) / 1000;
    top_test_cfg.rest_lim = (rest_t * {4'b0,clk_freq}) / 1000;
    top_test_cfg.silent_lim = (silent_t * {20'b0,clk_freq}) / 1000;
  end
  endtask

  // **********************************************************************************************************************************
  // This task is used for calculating 
  // 1- all parametters of all Drivers for setting VIPs, and HW in next Configuration Phase for Drivers
  // 2- At the end, we enable drivers for Analog side only
  // -----------------------------------------------------------------------------------------------
  // Inputs: 
  // - preload selection : 11 or 00
  // - waveform_sel - Waveform selection: 001 (2 waves), 010(3 waves), 000 (1 wave) - rest values are reserved
  // - load_points_sel : when waveform_sel is 001 or 010 and preload_sel: 11 -> load_points_sel = 1 else this bit is 0
  // - neg_ena : negative phase enable
  // - pos_dis : positive phase disable
  // - pos_neg_diff_sel: bit[7]: 1 : use different addresses from different register 0: use the same address from 1 register. 
  // - PULLAB_pos_en: Pos_wave_en - bit2  
  // - PULLAB_neg_en: Neg_wave_en - bit1  
  // - PULLAB_lim: Rest_time_en - bit0     
  // - points_sel : Point Selection - 0/1/2/3/4/5/6/7: 64/32/16/8/4/2/1/128 points (load_points_sel = 1) if it is 0, not used (AWG_POINT_CONFIG_REG - 0x02)
  // **********************************************************************************************************************************
  task wavegen_setup(input int chip_num);
  logic [7:0] mem_tmp [128];
  begin
    top_test_cfg.LOAD_POINTS = top_test_cfg.load_points_sel;
    top_test_cfg.NO_OF_WAVEFORMS = top_test_cfg.waveform_sel;
    top_test_cfg.PRELOAD = top_test_cfg.preload_sel;
    top_test_cfg.NEG_ON = top_test_cfg.neg_ena;
    top_test_cfg.POS_OFF = top_test_cfg.pos_dis;
    top_test_cfg.POS_NEG_DIFF = top_test_cfg.pos_neg_diff_sel;
    top_test_cfg.PULLAB_CTRL  = {top_test_cfg.PULLAB_pos_en, top_test_cfg.PULLAB_neg_en, top_test_cfg.PULLAB_lim};
    
    // From constraint of points_sel, decode and save NO_OF_POINTS and load correct hex file of sine wave
    for (int i=0; i<16; i++) begin
      case(top_test_cfg.points_sel)

         3'b000:begin
		    top_test_cfg.NO_OF_POINTS = 64;
		    if(top_test_cfg.LOAD_POINTS === 0)
		    	$readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y64", mem_tmp);
		    else
			$readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y128", mem_tmp);

                    // -----------------------------------------
                    // 2) Copy loaded data into class array
                    // -----------------------------------------
                    for (int j = 0; j < 128; j++)
                       top_test_cfg.sine_data[i][j] = mem_tmp[j];

                    if (`DUT_IF.drive_mode_en === 1'b1) begin
                      for (int j=0; j<top_test_cfg.NO_OF_POINTS; j++) begin  
                        top_test_cfg.sine_data[i][top_test_cfg.NO_OF_POINTS+j] = 0;
                      end
                    end else begin
                      for (int j=0; j<top_test_cfg.NO_OF_POINTS; j++) begin  
                        top_test_cfg.sine_data[i][j] = 0;
                      end
                    end 
		end

         3'b001:begin
		    top_test_cfg.NO_OF_POINTS = 32;
		    if(top_test_cfg.LOAD_POINTS === 0)
		    	$readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y32", mem_tmp);
		    else
			$readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y128", mem_tmp);

                    // -----------------------------------------
                    // 2) Copy loaded data into class array
                    // -----------------------------------------
                    for (int j = 0; j < 128; j++)
                       top_test_cfg.sine_data[i][j] = mem_tmp[j];

                    if (`DUT_IF.drive_mode_en === 1'b1) begin
                      for (int j=0; j<top_test_cfg.NO_OF_POINTS; j++) begin  
                        top_test_cfg.sine_data[i][top_test_cfg.NO_OF_POINTS+j] = 0;
                      end
                    end else begin
                      for (int j=0; j<top_test_cfg.NO_OF_POINTS; j++) begin  
                        top_test_cfg.sine_data[i][j] = 0;
                      end
                    end 
		end

         3'b010:begin
		    top_test_cfg.NO_OF_POINTS = 16;
		    if(top_test_cfg.LOAD_POINTS === 0)
		    	$readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y16", mem_tmp);
		    else
			$readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y128", mem_tmp);

                    // -----------------------------------------
                    // 2) Copy loaded data into class array
                    // -----------------------------------------
                    for (int j = 0; j < 128; j++)
                       top_test_cfg.sine_data[i][j] = mem_tmp[j];

                    if (`DUT_IF.drive_mode_en === 1'b1) begin
                      for (int j=0; j<top_test_cfg.NO_OF_POINTS; j++) begin  
                        top_test_cfg.sine_data[i][top_test_cfg.NO_OF_POINTS+j] = 0;
                      end
                    end else begin
                      for (int j=0; j<top_test_cfg.NO_OF_POINTS; j++) begin  
                        top_test_cfg.sine_data[i][j] = 0;
                      end
                    end 
		end

         3'b011:begin
		    top_test_cfg.NO_OF_POINTS = 8;
		    if(top_test_cfg.LOAD_POINTS === 0)
		    	$readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y8", mem_tmp);
		    else
			$readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y128", mem_tmp);

                    // -----------------------------------------
                    // 2) Copy loaded data into class array
                    // -----------------------------------------
                    for (int j = 0; j < 128; j++)
                       top_test_cfg.sine_data[i][j] = mem_tmp[j];

                    if (`DUT_IF.drive_mode_en === 1'b1) begin
                      for (int j=0; j<top_test_cfg.NO_OF_POINTS; j++) begin  
                        top_test_cfg.sine_data[i][top_test_cfg.NO_OF_POINTS+j] = 0;
                      end
                    end else begin
                      for (int j=0; j<top_test_cfg.NO_OF_POINTS; j++) begin  
                        top_test_cfg.sine_data[i][j] = 0;
                      end
                    end 
		end

         3'b100:begin
		    top_test_cfg.NO_OF_POINTS = 4;
		    if(top_test_cfg.LOAD_POINTS === 0)
		    	$readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y4", mem_tmp);
		    else
			$readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y128", mem_tmp);

                    // -----------------------------------------
                    // 2) Copy loaded data into class array
                    // -----------------------------------------
                    for (int j = 0; j < 128; j++)
                       top_test_cfg.sine_data[i][j] = mem_tmp[j];

                    if (`DUT_IF.drive_mode_en === 1'b1) begin
                      for (int j=0; j<top_test_cfg.NO_OF_POINTS; j++) begin  
                        top_test_cfg.sine_data[i][top_test_cfg.NO_OF_POINTS+j] = 0;
                      end
                    end else begin
                      for (int j=0; j<top_test_cfg.NO_OF_POINTS; j++) begin  
                        top_test_cfg.sine_data[i][j] = 0;
                      end
                    end 

		end

         3'b101:begin
		    top_test_cfg.NO_OF_POINTS = 2;
		    if(top_test_cfg.LOAD_POINTS === 0)
		    	$readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y2", mem_tmp);
		    else
			$readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y128", mem_tmp);

                    // -----------------------------------------
                    // 2) Copy loaded data into class array
                    // -----------------------------------------
                    for (int j = 0; j < 128; j++)
                       top_test_cfg.sine_data[i][j] = mem_tmp[j];

                    if (`DUT_IF.drive_mode_en === 1'b1) begin
                      for (int j=0; j<top_test_cfg.NO_OF_POINTS; j++) begin  
                        top_test_cfg.sine_data[i][top_test_cfg.NO_OF_POINTS+j] = 0;
                      end
                    end else begin
                      for (int j=0; j<top_test_cfg.NO_OF_POINTS; j++) begin  
                        top_test_cfg.sine_data[i][j] = 0;
                      end
                    end 
		end

         3'b110:begin
		    top_test_cfg.NO_OF_POINTS = 1;
		    $readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y1", mem_tmp);
		end

         3'b111:begin
		    top_test_cfg.NO_OF_POINTS = 128;
		    $readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y128", mem_tmp);

                    // -----------------------------------------
                    // 2) Copy loaded data into class array
                    // -----------------------------------------
                    for (int j = 0; j < 128; j++)
                       top_test_cfg.sine_data[i][j] = mem_tmp[j];

                    if (`DUT_IF.drive_mode_en === 1'b1) begin
                      for (int j=0; j<top_test_cfg.NO_OF_POINTS; j++) begin  
                        top_test_cfg.sine_data[i][top_test_cfg.NO_OF_POINTS+j] = 0;
                      end
                    end else begin
                      for (int j=0; j<top_test_cfg.NO_OF_POINTS; j++) begin  
                        top_test_cfg.sine_data[i][j] = 0;
                      end
                    end 
		end
      endcase
    end

    // LOAD_POINTS = 0 (preloaded is enabled)
    if(top_test_cfg.LOAD_POINTS === 0)
	top_test_cfg.NO_OF_LOAD_POINTS = top_test_cfg.NO_OF_POINTS;
    else begin //LOAD_POINTS = 1 (SPI is enabled)
      if(top_test_cfg.NO_OF_WAVEFORMS === 0) // 1 waveform
	top_test_cfg.NO_OF_LOAD_POINTS = 128;
      else begin // Not 1 Waveform
      	if(top_test_cfg.POS_NEG_DIFF === 1) // If using difference address for pos/neg
	   top_test_cfg.NO_OF_LOAD_POINTS = top_test_cfg.NO_OF_POINTS * (top_test_cfg.NO_OF_WAVEFORMS+1);
      	else begin // using the same address
	   if((top_test_cfg.NEG_ON === 1) && (top_test_cfg.POS_OFF === 0)) // Both Negative + Positive Phases 
	   	top_test_cfg.NO_OF_LOAD_POINTS = top_test_cfg.NO_OF_POINTS * (top_test_cfg.NO_OF_WAVEFORMS+1) * 2;
	   else // One Phase only
		top_test_cfg.NO_OF_LOAD_POINTS = top_test_cfg.NO_OF_POINTS * (top_test_cfg.NO_OF_WAVEFORMS+1);
	end
      end
    end

    // SPI Mode
    if(top_test_cfg.LOAD_POINTS === 1)
	top_test_cfg.NO_OF_WAVES = 1;
    else // Non SPI Mode (Preloaded mode)
	top_test_cfg.NO_OF_WAVES = 4;

    // Interface
    if(chip_num === 0) begin // One chip
    	`DUT_IF.wavegen_sample_num_per_period = top_test_cfg.NO_OF_LOAD_POINTS * 2;//no: of samples in 1 sine wave
    	`DUT_IF.python_length = `DUT_IF.wavegen_sample_num_per_period * top_test_cfg.NO_OF_WAVES;//send N sine waves to python
    end
    else begin // multiple chips
    	`DUT_IF.wavegen_sample_num_per_period_chip1 = top_test_cfg.NO_OF_LOAD_POINTS * 2;//no: of samples in 1 sine wave
    	`DUT_IF.python_length_chip1 = `DUT_IF.wavegen_sample_num_per_period_chip1 * top_test_cfg.NO_OF_WAVES;//send N sine waves to python
    end

    // Set no of points for each phase to Wave_vif
    top_env.wavegen_vif[chip_num].no_of_point_a = top_test_cfg.NO_OF_LOAD_POINTS; // expected resolution
    top_env.wavegen_vif[chip_num].no_of_point_b = top_test_cfg.NO_OF_LOAD_POINTS; // expected resolution

    // Saving data for all points of 2 phases to wave_vif
    for (int i; i < 16; i++) begin 
      mem_tmp = top_test_cfg.sine_data[i];
      for (int j = 0; j < 128; j++)
        mem_tmp[j] = top_test_cfg.sine_data[i][j];

      for (int k=0; k < top_env.wavegen_vif[chip_num].no_of_point_a; k++) begin
        top_env.wavegen_vif[chip_num].hex_data_a[i][k] = mem_tmp[k]; // expected hex values
        top_env.wavegen_vif[chip_num].hex_data_b[i][k] = mem_tmp[k]; // expected hex values
      end
    end

    // Saving interfaces
    top_env.wavegen_vif[chip_num].pos_neg_from_same_addr = top_test_cfg.POS_NEG_DIFF; 
    top_env.wavegen_vif[chip_num].load_wave_data_till_points = top_test_cfg.LOAD_POINTS; 
    top_env.wavegen_vif[chip_num].no_of_waveforms = top_test_cfg.NO_OF_WAVEFORMS; 
    top_env.wavegen_vif[chip_num].preload_sel = top_test_cfg.PRELOAD;

    // Saving interfaces
    for (int i=0; i < `WAVEGEN_DRIVER_NUM; i++) begin
      top_env.wavegen_vif[chip_num]. PULLAB_pos_en[i] = top_test_cfg.PULLAB_CTRL[7];
      top_env.wavegen_vif[chip_num].PULLAB_neg_en[i] = top_test_cfg.PULLAB_CTRL[6];
      top_env.wavegen_vif[chip_num].PULLAB_lim[i] = top_test_cfg.PULLAB_CTRL[5:0];
    end

    `nnc_info("SOC_TEST", $sformatf("NO_OF_POINTS: %d, NO_OF_LOAD_POINTS: %d, LOAD_POINTS:%d", top_test_cfg.NO_OF_POINTS, top_test_cfg.NO_OF_LOAD_POINTS, top_test_cfg.LOAD_POINTS), NNC_LOW)

    // Calculate clock
    top_test_cfg.clk_freq = 8192 / (2**`DUT_IF.pclk_sel);

    // Calculate half period of wave: Point_Num * Period
    top_test_cfg.half_period_limit = (top_test_cfg.NO_OF_POINTS * 1000) / top_test_cfg.clk_freq;

    `nnc_info("SOC_TEST", $sformatf("NO_OF_POINTS: %d, clk_freq: %d, half_period_limit:%d", top_test_cfg.NO_OF_POINTS, top_test_cfg.clk_freq, top_test_cfg.half_period_limit), NNC_LOW)
 

    // ==================================
    // Set configurations for VIPs
    // ==================================
    for (int i = 0; i < `WAVEGEN_DRIVER_NUM; i++) begin
      assert(top_test_cfg.randomize() with {half_period0[0] > top_test_cfg.half_period_limit; half_period1[0] > top_test_cfg.half_period_limit; half_period2[0] > top_test_cfg.half_period_limit;
                                            half_period0[1] > top_test_cfg.half_period_limit; half_period1[1] > top_test_cfg.half_period_limit; half_period2[1] > top_test_cfg.half_period_limit;
                                           (`DUT_IF.python_check_en == 1) -> same_pos_neg_period == 1;
                                           (same_pos_neg_period == 1) -> half_period0[0] == half_period0[1];
                                           (same_pos_neg_period == 1) -> half_period1[0] == half_period1[1];
                                           (same_pos_neg_period == 1) -> half_period2[0] == half_period2[1];});

      `nnc_info("SOC_TEST", $sformatf("same_pos_neg_period:%d", top_test_cfg.same_pos_neg_period), NNC_LOW)
      // ======================================================================================================================

      // ----------------------------------
      // Calculating for Wave0
      // ----------------------------------
      wavegen_calc_clock_num(
      .clk_freq(top_test_cfg.clk_freq), 
      .rest_t(0), 
      .silent_t(0), 
      .hlf_wave_per(top_test_cfg.half_period0[0]), 
      .neg_hlf_wave_per(top_test_cfg.half_period0[1])
      );

      // Updating for DUT Interface for Wave0
      `DUT_IF.wg_hlf_wave0_lim[i] = top_test_cfg.hlf_wave_lim / top_test_cfg.NO_OF_POINTS;
      `DUT_IF.wg_neg_hlf_wave0_lim[i] = top_test_cfg.neg_hlf_wave_lim / top_test_cfg.NO_OF_POINTS;
      `DUT_IF.wg_rest_wave0_lim[i] = top_test_cfg.rest_lim;
      `DUT_IF.wg_silent_wave0_lim[i] = top_test_cfg.silent_lim;
      `nnc_info("SOC_TEST", $sformatf("******** Driver (%d) WAVE 0 ******** CLK_FREQ: %dKhz, HALF_PERIOD_LIMIT: %dus, POS_HALF_PERIOD_TARGET: %dus, NEG_HALF_PERIOD_TARGET: %dus, POS_HALF_PERIOD_CLKS_PER_POINT: %d, NEG_HALF_PERIOD_CLKS_PER_POINT: %d", i, top_test_cfg.clk_freq, top_test_cfg.half_period_limit, top_test_cfg.half_period0[0], top_test_cfg.half_period0[1], `DUT_IF.wg_hlf_wave0_lim[i], `DUT_IF.wg_neg_hlf_wave0_lim[i]), NNC_LOW)
      // ======================================================================================================================

      // ----------------------------------
      // Calculating for Wave1
      // ----------------------------------
      // wavegen_calc_clock_num(top_test_cfg.clk_freq, 0, 0, top_test_cfg.half_period1[0], top_test_cfg.half_period1[1]);
      wavegen_calc_clock_num(
      .clk_freq(top_test_cfg.clk_freq), 
      .rest_t(0), 
      .silent_t(0), 
      .hlf_wave_per(top_test_cfg.half_period1[0]), 
      .neg_hlf_wave_per(top_test_cfg.half_period1[1])
      );

      // Updating for DUT Interface for Wave1
      `DUT_IF.wg_hlf_wave1_lim[i] = top_test_cfg.hlf_wave_lim / top_test_cfg.NO_OF_POINTS;
      `DUT_IF.wg_neg_hlf_wave1_lim[i] = top_test_cfg.neg_hlf_wave_lim / top_test_cfg.NO_OF_POINTS;
      `DUT_IF.wg_rest_wave1_lim[i] = top_test_cfg.rest_lim;
      `DUT_IF.wg_silent_wave1_lim[i] = top_test_cfg.silent_lim;
      `nnc_info("SOC_TEST", $sformatf("******** Driver (%d) WAVE 1 ******** CLK_FREQ: %dKhz, HALF_PERIOD_LIMIT: %dus, POS_HALF_PERIOD_TARGET: %dus, NEG_HALF_PERIOD_TARGET: %dus, POS_HALF_PERIOD_CLKS_PER_POINT: %d, NEG_HALF_PERIOD_CLKS_PER_POINT: %d", i, top_test_cfg.clk_freq, top_test_cfg.half_period_limit, top_test_cfg.half_period1[0], top_test_cfg.half_period1[1], `DUT_IF.wg_hlf_wave1_lim[i], `DUT_IF.wg_neg_hlf_wave1_lim[i]), NNC_LOW)
      // ======================================================================================================================

      // wavegen_calc_clock_num(clk_freq (KHz), rest_t (us), silent_t (us), hlf_wave_per (us), neg_hlf_wave_per (us))
      // ----------------------------------
      // Calculating for Wave2
      // ----------------------------------
      // wavegen_calc_clock_num(top_test_cfg.clk_freq, 0, 0, top_test_cfg.half_period2[0], top_test_cfg.half_period2[1]);
      wavegen_calc_clock_num(
      .clk_freq(top_test_cfg.clk_freq), 
      .rest_t(0), 
      .silent_t(0), 
      .hlf_wave_per(top_test_cfg.half_period2[0]), 
      .neg_hlf_wave_per(top_test_cfg.half_period2[1])
      );

      // Updating for DUT Interface for Wave2
      `DUT_IF.wg_hlf_wave2_lim[i] = top_test_cfg.hlf_wave_lim / top_test_cfg.NO_OF_POINTS;
      `DUT_IF.wg_neg_hlf_wave2_lim[i] = top_test_cfg.neg_hlf_wave_lim / top_test_cfg.NO_OF_POINTS;
      `DUT_IF.wg_rest_wave2_lim[i] = top_test_cfg.rest_lim;
      `DUT_IF.wg_silent_wave2_lim[i] = top_test_cfg.silent_lim;
      `nnc_info("SOC_TEST", $sformatf("******** Driver (%d) WAVE 2 ******** CLK_FREQ: %dKhz, HALF_PERIOD_LIMIT: %dus, POS_HALF_PERIOD_TARGET: %dus, NEG_HALF_PERIOD_TARGET: %dus, POS_HALF_PERIOD_CLKS_PER_POINT: %d, NEG_HALF_PERIOD_CLKS_PER_POINT: %d", i, top_test_cfg.clk_freq, top_test_cfg.half_period_limit, top_test_cfg.half_period2[0], top_test_cfg.half_period2[1], `DUT_IF.wg_hlf_wave2_lim[i], `DUT_IF.wg_neg_hlf_wave2_lim[i]), NNC_LOW)
      // ======================================================================================================================

      // ----------------------------------
      // Updating configuration of Wave 0/1/2 from DUT to Wavegen VIP
      // ----------------------------------    
      // Wave 0
      top_env.wavegen_vif[chip_num].wg_hlf_wave0_lim[i] = `DUT_IF.wg_hlf_wave0_lim[i];
      top_env.wavegen_vif[chip_num].wg_neg_hlf_wave0_lim[i] = `DUT_IF.wg_neg_hlf_wave0_lim[i];
      top_env.wavegen_vif[chip_num].wg_rest_wave0_lim[i] = `DUT_IF.wg_rest_wave0_lim[i];
      top_env.wavegen_vif[chip_num].wg_silent_wave0_lim[i] = `DUT_IF.wg_silent_wave0_lim[i];

      // Wave 1
      top_env.wavegen_vif[chip_num].wg_hlf_wave1_lim[i] = `DUT_IF.wg_hlf_wave1_lim[i];
      top_env.wavegen_vif[chip_num].wg_neg_hlf_wave1_lim[i] = `DUT_IF.wg_neg_hlf_wave1_lim[i];
      top_env.wavegen_vif[chip_num].wg_rest_wave1_lim[i] = `DUT_IF.wg_rest_wave1_lim[i];
      top_env.wavegen_vif[chip_num].wg_silent_wave1_lim[i] = `DUT_IF.wg_silent_wave1_lim[i];

      // Wave 2
      top_env.wavegen_vif[chip_num].wg_hlf_wave2_lim[i] = `DUT_IF.wg_hlf_wave2_lim[i];
      top_env.wavegen_vif[chip_num].wg_neg_hlf_wave2_lim[i] = `DUT_IF.wg_neg_hlf_wave2_lim[i];
      top_env.wavegen_vif[chip_num].wg_rest_wave2_lim[i] = `DUT_IF.wg_rest_wave2_lim[i];
      top_env.wavegen_vif[chip_num].wg_silent_wave2_lim[i] = `DUT_IF.wg_silent_wave2_lim[i];

      // -----------------------------------------------
      // set clk_per_point_short
      // -----------------------------------------------
      // For Diver 0
      if(chip_num === 0) begin
        if(`DUT_IF.wg_hlf_wave0_lim[i] === 32'h00000001)
	  `DUT_IF.clk_per_point_short_dac[i] = 1'b1;
        else
	  `DUT_IF.clk_per_point_short_dac[i] = 1'b0;
      end
/*
      // For Diver 1      
      else if((chip_num === 0) && (i === 1)) begin
        if(`DUT_IF.wg_hlf_wave0_lim[i] === 32'h00000001)
	  `DUT_IF.clk_per_point_short_dac1 = 1'b1;
        else
	  `DUT_IF.clk_per_point_short_dac1 = 1'b0;
      end
      // For Diver 2 ?????????? -> Daniel
*/
    end // end of for (int i = 0; i < `WAVEGEN_DRIVER_NUM; i++) begin

    // ------------------------------------------------------------------------------
    // Write to SOC_ANA_ENABLE_REG_1 (This driver enable is for analog purpose only)
    // ------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_ENABLE_REG_1; wr_data[0] == 8'h08;});//IDAC_EN
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // ------------------------------------------------------------------------------
    // Write to SOC_ANA_ENABLE_REG_2 (This driver enable is for analog purpose only)
    // ------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_ENABLE_REG_2; wr_data[0] == 8'h08;});//IDAC_EN
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
  end
  endtask


  // ******************************************************************
  // This task is used for configuring registers of each of Driver
  // ******************************************************************
  task wavegen_drv_config;
  input [1:0] wg_drv_sel;
  input [7:0] WG_BASE;

  begin

    // Decode Base Address to know which selected driver
    if (WG_BASE === `WAVEGEN_0_ADDR_BASE)
	`DUT_IF.wg_drv_sel = 0 + 4*wg_drv_sel;
    else if(WG_BASE === `WAVEGEN_1_ADDR_BASE)
	`DUT_IF.wg_drv_sel = 1 + 4*wg_drv_sel;
    else if(WG_BASE === `WAVEGEN_2_ADDR_BASE)
        `DUT_IF.wg_drv_sel = 2 + 4*wg_drv_sel;
    else if(WG_BASE === `WAVEGEN_3_ADDR_BASE)
        `DUT_IF.wg_drv_sel = 3 + 4*wg_drv_sel;

    // --------------------------------------------------------
    // Write to SOC_ADDR_WG_DRV_CTRL0_REG (Control 0)
    // DRIVE_REG_CTRL0: Offset:0x34
    // bit-5: data_output_mode - 0: 8-bit, 1: 12-bit
    // bit-4: mode_sel 1: Manual, 0: Auto
    // bit-2: driverA_pullDA - DRIVERA_PULLDA (applicable only in manual mode) 
    // bit-0: driverA_sourceA - DRIVERA_SOURCEA (applicable only in manual mode) 
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CTRL0_REG + WG_BASE); wr_data[0] == {2'b0, top_test_cfg.dac_bit_len_sel, top_test_cfg.auto_man, 4'b0};});
    `nnc_info("SOC_TEST", "Set drive reg ctrl0", NNC_LOW)
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // --------------------------------------------------------
    // Write burst starting from SOC_ADDR_WG_DRV_CTRL1_REG (Control 1)
    // DRIVE_REG_CTRL1: Offset:0x35 (IDAC_DIN_LSB)
    // DRIVE_REG_CTRL2: Offset:0x35 
    // - bit7: multi_argo_ctrl - 0: use right shift, 1: use a multiplier
    // - bit[6:4]: - 8-bit_location_sel (0 -> 4) to scale up
    // - bit[3:0] - IDAC_DIN_MSB
    // --------------------------------------------------------
    `nnc_info("SOC_TEST", "Set drive reg ctrl1-2", NNC_LOW)

    if (WG_BASE === `WAVEGEN_0_ADDR_BASE) begin // Driver 0
      assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CTRL1_REG + WG_BASE); no_of_bytes == 2; wr_data[0] == {1'b0, top_test_cfg.dac0_msb_sel, top_test_cfg.dac0_data_h}; wr_data[1] == top_test_cfg.dac0_data_l;});
      // 2 registers
      `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);
    end
    else if(WG_BASE === `WAVEGEN_1_ADDR_BASE) begin  // Driver 1
      assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CTRL1_REG + WG_BASE); no_of_bytes == 2; wr_data[0] == {1'b0, top_test_cfg.dac1_msb_sel, top_test_cfg.dac1_data_h}; wr_data[1] == top_test_cfg.dac1_data_l;});
      // 2 registers
      `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);
    end
    else if(WG_BASE === `WAVEGEN_2_ADDR_BASE) begin  // Driver 1
      assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CTRL1_REG + WG_BASE); no_of_bytes == 2; wr_data[0] == {1'b0, top_test_cfg.dac2_msb_sel, top_test_cfg.dac2_data_h}; wr_data[1] == top_test_cfg.dac2_data_l;});
      `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);
    end
    else if(WG_BASE === `WAVEGEN_3_ADDR_BASE) begin  // Driver 1
      assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CTRL1_REG + WG_BASE); no_of_bytes == 2; wr_data[0] == {1'b0, top_test_cfg.dac3_msb_sel, top_test_cfg.dac3_data_h}; wr_data[1] == top_test_cfg.dac3_data_l;});
      `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);
    end

    // --------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_REST_T_REG01 (Rest Time) (2 registers)
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_REST_T_REG01 + WG_BASE); no_of_bytes == 2;  wr_data[0] == `DUT_IF.wg_rest_wave0_lim[`DUT_IF.wg_drv_sel][15:8]; wr_data[1] == `DUT_IF.wg_rest_wave0_lim[`DUT_IF.wg_drv_sel][7:0];});
    `nnc_info("SOC_TEST", "Set 0 rest period", NNC_LOW)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_SILENT_T_REG01 (Silent Time) (3 registers)
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_SILENT_T_REG01 + WG_BASE); no_of_bytes == 3; wr_data[0] == `DUT_IF.wg_silent_wave0_lim[`DUT_IF.wg_drv_sel][23:16]; wr_data[1] == `DUT_IF.wg_silent_wave0_lim[`DUT_IF.wg_drv_sel][15:8]; wr_data[2] == `DUT_IF.wg_silent_wave0_lim[`DUT_IF.wg_drv_sel][7:0];});
    `nnc_info("SOC_TEST", "Set 0 silent time", NNC_LOW)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write to SOC_ADDR_WG_DRV_SILENT_T_REG04 (1 register)
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_SILENT_T_REG04 + WG_BASE); wr_data[0] == `DUT_IF.wg_silent_wave0_lim[`DUT_IF.wg_drv_sel][31:24];});
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // --------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_HLF_WAVE_PRD_REG01 (2 registers)
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_HLF_WAVE_PRD_REG01 + WG_BASE); no_of_bytes == 2; wr_data[0] == `DUT_IF.wg_hlf_wave0_lim[`DUT_IF.wg_drv_sel][15:8]; wr_data[1] == `DUT_IF.wg_hlf_wave0_lim[`DUT_IF.wg_drv_sel][7:0];});
    `nnc_info("SOC_TEST", "Set positive half wave0 period", NNC_LOW)//0x0000_01F4 (500us)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_NEG_HLF_WAVE_PRD_REG01 (2 registers)
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_NEG_HLF_WAVE_PRD_REG01 + WG_BASE); no_of_bytes == 2; wr_data[0] == `DUT_IF.wg_neg_hlf_wave0_lim[`DUT_IF.wg_drv_sel][15:8]; wr_data[1] == `DUT_IF.wg_neg_hlf_wave0_lim[`DUT_IF.wg_drv_sel][7:0];});
    `nnc_info("SOC_TEST", "Set negative half wave0 period", NNC_LOW)//0x0000_01F4 (500us)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // -------------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_HLF_WAVE_CLK_PNT1_REG01
    // -------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_HLF_WAVE_CLK_PNT1_REG01 + WG_BASE); no_of_bytes == 2; wr_data[0] == `DUT_IF.wg_hlf_wave1_lim[`DUT_IF.wg_drv_sel][15:8]; wr_data[1] == `DUT_IF.wg_hlf_wave1_lim[`DUT_IF.wg_drv_sel][7:0];});
    `nnc_info("SOC_TEST", "Set positive half wave1 period", NNC_LOW)//0x0000_01F4 (500us)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // -----------------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT1_REG01
    // -----------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT1_REG01 + WG_BASE); no_of_bytes == 2; wr_data[0] == `DUT_IF.wg_neg_hlf_wave1_lim[`DUT_IF.wg_drv_sel][15:8]; wr_data[1] == `DUT_IF.wg_neg_hlf_wave1_lim[`DUT_IF.wg_drv_sel][7:0];});
    `nnc_info("SOC_TEST", "Set negative half wave1 period", NNC_LOW)//0x0000_01F4 (500us)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // -------------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_HLF_WAVE_CLK_PNT2_REG01
    // -------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_HLF_WAVE_CLK_PNT2_REG01 + WG_BASE); no_of_bytes == 2; wr_data[0] == `DUT_IF.wg_hlf_wave2_lim[`DUT_IF.wg_drv_sel][15:8]; wr_data[1] == `DUT_IF.wg_hlf_wave2_lim[`DUT_IF.wg_drv_sel][7:0];});
    `nnc_info("SOC_TEST", "Set positive half wave2 period", NNC_LOW)//0x0000_01F4 (500us)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // -----------------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT2_REG01
    // -----------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT2_REG01 + WG_BASE); no_of_bytes == 2; wr_data[0] == `DUT_IF.wg_neg_hlf_wave2_lim[`DUT_IF.wg_drv_sel][15:8]; wr_data[1] == `DUT_IF.wg_neg_hlf_wave2_lim[`DUT_IF.wg_drv_sel][7:0];});
    `nnc_info("SOC_TEST", "Set negative half wave2 period", NNC_LOW)//0x0000_01F4 (500us)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write to ADDR_WG_DRV_CONFIG_REG0(//bit 0:rest enable, 1:negative enable, 2: silent enable, 3: source B enable, 4: alternate, 5: continue mode, 6: multi-electrode, 7: positive disable)
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CONFIG_REG0 + WG_BASE); wr_data[0] == {top_test_cfg.POS_OFF, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0, top_test_cfg.NEG_ON, 1'b0};});
    `nnc_info("SOC_TEST", "Set driver configuration register", NNC_LOW)
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    
    `nnc_info("SOC_TEST", $sformatf("Configure %d points", top_test_cfg.NO_OF_POINTS), NNC_LOW)
    // --------------------------------------------------------
    // Write to ADDR_WG_DRV_POINT_CONFIG
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_POINT_CONFIG + WG_BASE); wr_data[0] == top_test_cfg.NO_OF_POINTS;});
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // Save all points to internal Mem of Wavegen Controller 
    `nnc_info("SOC_TEST", $sformatf("Store %d wave points", top_test_cfg.NO_OF_LOAD_POINTS), NNC_LOW)
    for(int m=0; m<16; m++) begin
      for(int i=0; i<top_test_cfg.NO_OF_LOAD_POINTS; i++) begin
       	// --------------------------------------------------------
    	// Write to ADDR_WG_DRV_IN_WAVE_ADDR_REG0
    	// --------------------------------------------------------
        // Save addresss of Mem to Register
    	assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0 + WG_BASE); wr_data[0] == i;});
    	`WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
	// --------------------------------------------------------
    	// Write to ADDR_WG_DRV_IN_WAVE_REG01
    	// --------------------------------------------------------
        // Save data of Mem to Register
	assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_IN_WAVE_REG01 + WG_BASE); wr_data[0] == top_test_cfg.sine_data[m][i][7:0];});
    	`WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
      end
    end

    // *******************************************************************************
    // Write to ADDR_WG_DRV_NEG_SCALE_REG0 (By default it is 1) - AWG_NEG_SCALE_REG: 0x25
    // -------------------------------------------------------------------------------
    // Bit 7: 
    // 0: Scale up the negative side of the waveform by the value of bit[6:0] (multiply by this value)  
    // 1: Scale down the negative side of the waveform by the value of bit[6:0] (shift right by this value) 
    // For scale-up function of section 9.9.6 DRIVE_REG_CTRL2 is 1
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_NEG_SCALE_REG0 + WG_BASE); wr_data[0] == 8'h01;});
    `nnc_info("SOC_TEST", "Scale negative side", NNC_LOW)
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // *******************************************************************************
    // Write to ADDR_WG_DRV_POS_SCALE_REG0 (By default it is 1) - AWG_POS_SCALE_REG: 0x27
    // -------------------------------------------------------------------------------
    // Bit 7: 
    // 0: Scale up the positive side of the waveform by the value of  bit[6:0] (multiply by this value)  
    // 1: Scale down the positive side of the waveform by the value of  bit[6:0] (shift right by this value) 
    // For scale up function of section 9.9.6 DRIVE_REG_CTRL2 is 1
    // -------------------------------------------------------------------------------
    //assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_POS_SCALE_REG0 + WG_BASE); wr_data[0] == 8'h01;});
    //`nnc_info("SOC_TEST", "Scale positive side", NNC_LOW)
    //`WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // *******************************************************************************
    // Write to ADDR_WG_DRV_PULLBA_REG - AWG_DEBOUNCE_REG: 0x29
    // -------------------------------------------------------------------------------
    // Bit[5:0]: the number of clocks during which PULLB & PULLA is 1 
    // Bit[6]: enable PULLB & PULLA can be 1 at the same time before next neg side 
    // Bit[7]: enable PULLB & PULLA can be 1 at the same time before next pos side
    // {top_test_cfg.PULLAB_pos_en[7], top_test_cfg.PULLAB_neg_en[6], top_test_cfg.PULLAB_lim[5:0]}
    // -------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_PULLBA_REG + WG_BASE); wr_data[0] == top_test_cfg.PULLAB_CTRL;});
    `nnc_info("SOC_TEST", "Set pullab reg", NNC_LOW)
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // *******************************************************************************
    // Write to ADDR_WG_DRV_DELAY_LIM_REG01 - AWG_DELAY_LIM_REG: 0x23~0x24
    // -------------------------------------------------------------------------------
    // Number of clocks for initial delay after the reset is disabled and before the waves are generated
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_DELAY_LIM_REG01 + WG_BASE);});
    `nnc_info("SOC_TEST", "Adjust delay using Delay_lim register", NNC_LOW)
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // *******************************************************************************
    // Write to ADDR_WG_DRV_CTRL_REG0 - AWG_CTRL_REG0: 0x01
    // -------------------------------------------------------------------------------
    // bit[7]: resolution_ctrl - top_test_cfg.POS_NEG_DIFF
    // bit[6]: sym_or_asymmetrical_wave_en - top_test_cfg.LOAD_POINTS
    // bit[5:3]: waveform_num_sel - top_test_cfg.NO_OF_WAVEFORMS
    // bit[2:1]:  waveform_sel - top_test_cfg.PRELOAD
    // Bit[0]: Wavegen_En - 1'b1
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CTRL_REG0 + WG_BASE); wr_data[0] == {top_test_cfg.POS_NEG_DIFF,top_test_cfg.LOAD_POINTS,top_test_cfg.NO_OF_WAVEFORMS,top_test_cfg.PRELOAD,1'b0};});
    if(top_test_cfg.PRELOAD === 2'b00) // because this test is sine wave
    	`nnc_info("SOC_TEST", "Config driver control register with preloaded sine values", NNC_LOW)
    else if(top_test_cfg.PRELOAD === 2'b11)
    	`nnc_info("SOC_TEST", "Config driver control register with user config values", NNC_LOW)
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

  end
  endtask

  task wavegen_drv_enable;
  begin
    `nnc_info("SOC_TEST", $sformatf("enabling chip_0 wavegen sb now"), NNC_LOW)
/*
    `WAVEGEN_SCB_DRV_0_EN = 1'b1;
    `WAVEGEN_SCB_DRV_1_EN = 1'b1;
    `WAVEGEN_SCB_DRV_2_EN = 1'b1;
    `WAVEGEN_SCB_DRV_3_EN = 1'b1;
    `WAVEGEN_SCB_DRV_4_EN = 1'b1;
    `WAVEGEN_SCB_DRV_5_EN = 1'b1;
    `WAVEGEN_SCB_DRV_6_EN = 1'b1;
    `WAVEGEN_SCB_DRV_7_EN = 1'b1;
    `WAVEGEN_SCB_DRV_8_EN = 1'b1;
    `WAVEGEN_SCB_DRV_9_EN = 1'b1;
    `WAVEGEN_SCB_DRV_10_EN = 1'b1;
    `WAVEGEN_SCB_DRV_11_EN = 1'b1;
    `WAVEGEN_SCB_DRV_12_EN = 1'b1;
    `WAVEGEN_SCB_DRV_13_EN = 1'b1;
    `WAVEGEN_SCB_DRV_14_EN = 1'b1;
    `WAVEGEN_SCB_DRV_15_EN = 1'b1;
*/
    // --------------------------------------------------------
    // Write to SOC_WAVEGEN_GLOBAL_REG to sync drivers
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_WAVEGEN_GLOBAL_REG; wr_data[0] == 8'h01;});
    `nnc_info("SOC_TEST", "Enable drivers using global register", NNC_LOW)
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
  end
  endtask

  // ------------------------------
  // Declare the report_phase task
  // ------------------------------
  function void report_phase(nnc_phase phase) ;
    super.report_phase(phase);
  endfunction

endclass : `TESTNAME
