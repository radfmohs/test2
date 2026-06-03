/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_wavegen_pair_drv_sine_rest_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_wavegen_pair_drv_sine_rest_test                                             
// Designer	: ddang@nanochap.com                                                                 
// Date		: 26-05-2026                                                                     
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_wavegen_pair_drv_sine_rest_test
`define TESTCFG soc_wavegen_pair_drv_sine_rest_test_cfg

class `TESTCFG extends soc_wavegen_pair_drv_base_test_cfg;

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

  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_wavegen_pair_drv_sine_rest_test_cfg");
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
  constraint c_python_check_en { python_check_en == ($countones(wavegen_drv_en[15:0]) == 2); }

  //preload_sel
  constraint c_preload_sel     { wg_sine_en == 1'b1 -> preload_sel inside {0,3}; 
                                 wg_triangle_en == 1'b1 -> preload_sel inside {1,3};
                                 wg_pulse_en == 1'b1 -> preload_sel inside {2,3};
                               } // bit[2:1] WAVEFORM_SEL of AWG_CTRL_REG0: 0x01 - 00: Preloaded SINE, 11: Used waveform loaded from SPI 

  //neg_ena
  //constraint c_neg_ena         { (/*(load_points_sel == 1'b1) || */(pos_neg_diff_sel == 1'b1) || (python_check_en == 1'b1)) -> neg_ena == 1'b1;}

  constraint c_neg_ena         { neg_ena == 1'b0; }

  //pos_dis
  // constraint c_pos_dis         { ((neg_ena == 1'b0)/* || (load_points_sel == 1'b1)*/ || (pos_neg_diff_sel == 1'b1) || (python_check_en == 1'b1)) -> pos_dis == 1'b0;}
  constraint c_pos_dis         { pos_dis == 1'b0; }

  constraint c_wg_sine_en      { wg_sine_en == 1'b1; }

  constraint c_wg_triangle_en  { wg_triangle_en == 1'b0; }

  constraint c_wg_pulse_en     { wg_pulse_en == 1'b0; }

  constraint c_wg_dc_en        { wg_dc_en == 1'b0; }

  /*
  Normal waveform:  
  - If 1 waveform used and either pos or neg enabled, then max value is 64. 
  - If 2 waveforms used and either pos or neg enabled, then max value is 32. 
  - If 3 waveforms used and either pos or neg enabled, then max value is 21. 

  - If 1 waveform used and both pos and neg enabled and load value from different registers, then max value is 32. 
  - If 2 waveforms used and both pos and neg enabled and load value from different registers, then max value is 26. 
  - If 3 waveforms used and both pos and neg enabled and load value from different registers, then max value is 10. 

  - If 1 waveform used and both pos and neg enabled and load value from same registers, then max value is 64. 
  - If 2 waveforms used and both pos and neg enabled and load value from same   registers, then max value is 32. 
  - If 3 waveforms used and both pos and neg enabled and load value from same registers, then max value is 21 

  Preload function: 
  The number of points only can be the power of 2: 1, 2, 4, 8, 16, 32, 64 (Default is 64)
  */
  //points_sel
  constraint c_points_sel      { (load_points_sel == 1'b0) -> points_sel != 6;
                                 (python_check_en == 1'b1) -> !(points_sel inside {[5:6]});
                                 //((waveform_sel == 3'b000) && (neg_ena == 1'b1) && (pos_dis == 1'b0) && (pos_neg_diff_sel == 1'b0)) -> points_sel inside {[0:6]};
                                 //((waveform_sel == 3'b000) && (neg_ena == 1'b1) && (pos_dis == 1'b0) && (pos_neg_diff_sel == 1'b1)) -> points_sel inside {[0:7]};
                                 //((waveform_sel == 3'b001) && (neg_ena == 1'b1) && (pos_dis == 1'b0) && (pos_neg_diff_sel == 1'b0)) -> points_sel inside {[1:6]};
                                 //((waveform_sel == 3'b001) && (neg_ena == 1'b1) && (pos_dis == 1'b0) && (pos_neg_diff_sel == 1'b1)) -> points_sel inside {[0:6]};
                                 //((waveform_sel == 3'b010) && (neg_ena == 1'b1) && (pos_dis == 1'b0) && (pos_neg_diff_sel == 1'b0)) -> points_sel inside {[2:6]};
                                 //((waveform_sel == 3'b010) && (neg_ena == 1'b1) && (pos_dis == 1'b0) && (pos_neg_diff_sel == 1'b1)) -> points_sel inside {[1:6]};
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
  constraint c_PULLAB_lim         { PULLAB_lim != 0;}

  constraint c_wavegen_drv_mode   { foreach (wavegen_drv_mode[i]) { if (!wavegen_drv_en[i]) wavegen_drv_mode[i] == 0; } // 0 is Source and 1 is Sink 
                                     $countones(wavegen_drv_mode) == 1;
                                  } 

  constraint c_wavegen_drv_en     { $countones(wavegen_drv_en) == 2; } // 0 and 1 is enabled

  constraint c_wg_scoreboard_en   { wg_scoreboard_en == 1; } // 0 and 1 is enabled

  constraint c_wg_wave0_pos_clk_num { wave0_pos_clk_num inside {[10:1000]} ;} 
  constraint c_wg_wave1_pos_clk_num { wave1_pos_clk_num inside {[10:1000]} ;} 
  constraint c_wg_wave2_pos_clk_num { wave2_pos_clk_num inside {[10:1000]} ;} 

  constraint c_wg_wave0_rest_clk_num { wg_rest_en == 1 -> wave0_rest_clk_num inside {[10:1000]} ; wg_rest_en == 0 -> wave0_rest_clk_num == 0; } 
  constraint c_wg_wave1_rest_clk_num { wg_rest_en == 1 -> wave1_rest_clk_num inside {[10:1000]} ; wg_rest_en == 0 -> wave1_rest_clk_num == 0; } 
  constraint c_wg_wave2_rest_clk_num { wg_rest_en == 1 -> wave2_rest_clk_num inside {[10:1000]} ; wg_rest_en == 0 -> wave2_rest_clk_num == 0; } 

  constraint c_wg_rest_en            { wg_rest_en inside {[1:1]};} // 0 and 1 is enabled

  // -----------------------------------------------
  // End of adding constraints of randomization
  // ===============================================

endclass : `TESTCFG

// ===============================================
// Main Testcase is defined
// -----------------------------------------------
class `TESTNAME extends soc_wavegen_pair_drv_base_test;
   
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
    `nnc_top.set_timeout(0.5s);
    top_test_cfg = `TESTCFG::type_id::create("top_test_cfg", this);
  endfunction

  // -----------------------------------------
  // Declare the pre_reset_phase task 
  // -----------------------------------------
  virtual task pre_reset_phase(nnc_phase phase);
    phase.raise_objection(this);

    super.pre_reset_phase(phase);

    assert(top_test_cfg.randomize());

    `DUT_IF.python_check_en = top_test_cfg.python_check_en;
    //`DUT_IF.waveshape_sel = 2'b00;//indicates sine wave

    `DUT_IF.assertion_on = 1;

    `DUT_IF.wavegen_drv_mode = top_test_cfg.wavegen_drv_mode;
    `DUT_IF.wavegen_drv_en = top_test_cfg.wavegen_drv_en;

    `DUT_IF.wg_sine_en = top_test_cfg.wg_sine_en;   
    `DUT_IF.wg_triangle_en = top_test_cfg.wg_triangle_en;  
    `DUT_IF.wg_pulse_en = top_test_cfg.wg_pulse_en;  
    `DUT_IF.wg_dc_en = top_test_cfg.wg_dc_en;

    `DUT_IF.wg_same_pos_neg_period = top_test_cfg.same_pos_neg_period;
    `DUT_IF.wg_half_period0 = top_test_cfg.half_period0;
    `DUT_IF.wg_half_period1 = top_test_cfg.half_period1;
    `DUT_IF.wg_half_period2 = top_test_cfg.half_period2;
    `DUT_IF.wg_preload_sel = top_test_cfg.preload_sel;     // preload selection : 11 or 00
    `DUT_IF.wg_neg_ena = top_test_cfg.neg_ena;
    `DUT_IF.wg_pos_dis = top_test_cfg.pos_dis;
    `DUT_IF.wg_points_sel = top_test_cfg.points_sel; 
    `DUT_IF.wg_waveform_sel = top_test_cfg.waveform_sel;    // Waveform selection: 001, 010, 000 - rest values are reserved 
    `DUT_IF.wg_load_points_sel = top_test_cfg.load_points_sel; // waveform_sel: 001 or 010 and preload_sel: 11 -> load_points_sel = 1 
    `DUT_IF.wg_pos_neg_diff_sel = top_test_cfg.pos_neg_diff_sel;
    `DUT_IF.wg_dac_bit_len_sel = top_test_cfg.dac_bit_len_sel;//1'b0:8-bits; 1'b1:12-bits (only 8 bits supported for sine)
    `DUT_IF.wg_auto_man = top_test_cfg.auto_man;//1'b0:auto; 1'b1:manual
    `DUT_IF.wg_dac0_data_l = top_test_cfg.dac0_data_l;
    `DUT_IF.wg_dac0_data_h = top_test_cfg.dac0_data_h;
    `DUT_IF.wg_dac0_msb_sel = top_test_cfg.dac0_msb_sel;
    `DUT_IF.wg_dac1_data_l = top_test_cfg.dac1_data_l;
    `DUT_IF.wg_dac1_data_h = top_test_cfg.dac1_data_h;
    `DUT_IF.wg_dac1_msb_sel = top_test_cfg.dac1_msb_sel;
    `DUT_IF.wg_dac2_data_l = top_test_cfg.dac2_data_l;
    `DUT_IF.wg_dac2_data_h = top_test_cfg.dac2_data_h;
    `DUT_IF.wg_dac2_msb_sel = top_test_cfg.dac2_msb_sel;
    `DUT_IF.wg_dac3_data_l = top_test_cfg.dac3_data_l;
    `DUT_IF.wg_dac3_data_h = top_test_cfg.dac3_data_h;
    `DUT_IF.wg_dac3_msb_sel = top_test_cfg.dac3_msb_sel;
    `DUT_IF.wg_PULLAB_pos_en = top_test_cfg.PULLAB_pos_en;
    `DUT_IF.wg_PULLAB_neg_en = top_test_cfg.PULLAB_neg_en;
    `DUT_IF.wg_PULLAB_lim = top_test_cfg.PULLAB_lim;
    `DUT_IF.wg_scoreboard_en = top_test_cfg.wg_scoreboard_en;

    for (int k=0; k< `WAVEGEN_DRIVER_NUM; k++) begin
    `DUT_IF.wg_wave0_pos_clk_num[k] = top_test_cfg.wave0_pos_clk_num;
    `DUT_IF.wg_wave1_pos_clk_num[k] = top_test_cfg.wave1_pos_clk_num;
    `DUT_IF.wg_wave2_pos_clk_num[k] = top_test_cfg.wave2_pos_clk_num;
    `DUT_IF.wg_wave0_rest_clk_num[k] = top_test_cfg.wave0_rest_clk_num;
    `DUT_IF.wg_wave1_rest_clk_num[k] = top_test_cfg.wave1_rest_clk_num;
    `DUT_IF.wg_wave2_rest_clk_num[k] = top_test_cfg.wave2_rest_clk_num;
    end

    `DUT_IF.wg_rest_en = top_test_cfg.wg_rest_en;
    // -------------------
    // Scoreboard enables
    // -------------------
    // `FLASH_SCOREBOARD_EN = 1;
    // `SPIM_SCOREBOARD_EN = 1;
    // `ANALOG_SCOREBOARD_EN = 1;
    // `IMEAS_SCOREBOARD_EN = 1;
    // `CLKRST_SCOREBOARD_EN = 1;

    phase.drop_objection(this);
  endtask : pre_reset_phase

  // -----------------------------------------
  // Declare the reset_phase task 
  // -----------------------------------------
  virtual task reset_phase(nnc_phase phase);
    phase.raise_objection(this);

    super.reset_phase(phase);

    phase.drop_objection(this);
  endtask : reset_phase

  // -----------------------------------------
  // Declare the main_phase task of your test
  // -----------------------------------------
  virtual task main_phase(nnc_phase phase);
    phase.raise_objection(this);

    super.main_phase(phase);

    `nnc_info("SOC_TEST", "soc_wavegen_pair_drv_sine_rest_test start", NNC_LOW)

    // ==================================================================================
    // Please add your code of your test here
    // ---------------------------------------------------------------------------------- 
    


    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    #10000ns;
    `nnc_info("SOC_TEST", "soc_wavegen_pair_drv_sine_rest_test end now", NNC_LOW)

    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ==================================================================================

    phase.drop_objection(this);
  endtask: main_phase

  // ------------------------------
  // Declare the report_phase task
  // ------------------------------
  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction

endclass : `TESTNAME
