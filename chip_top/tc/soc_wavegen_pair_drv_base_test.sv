/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_wavegen_pair_drv_base_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_wavegen_pair_drv_base_test                                             
// Designer	: ddang@nanochap.com                                                                 
// Date		: 19-05-2026                                                                   
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

//***************************************************************************************
// NOTE : The test is intented  to generate sine wave for driver1 & driver2
//***************************************************************************************

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_wavegen_pair_drv_base_test
`define TESTCFG soc_wavegen_pair_drv_base_test_cfg

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
  logic [7:0]      rd_data[256];
  logic [7:0]      sine_data[16][128];
  logic [13:0]     clk_freq;//in Khz
  logic [12:0]     half_period_limit;
  randc logic      same_pos_neg_period;
  rand logic [12:0] half_period0[2];
  rand logic [12:0] half_period1[2];
  rand logic [12:0] half_period2[2];
  logic [12:0]     src_half_period0[2];
  logic [12:0]     src_half_period1[2];
  logic [12:0]     src_half_period2[2];
  logic [12:0]     snk_half_period0[2];
  logic [12:0]     snk_half_period1[2];
  logic [12:0]     snk_half_period2[2];
  logic [31:0]     hlf_wave_lim; // number of clocks for positive half wave
  logic [31:0]     neg_hlf_wave_lim; // number of clocks for negative half wave
  logic [31:0]     rest_lim; // number of clocks for each rest period
  logic [31:0]     silent_lim; // number of clocks for each silent period
  rand logic [1:0] preload_sel;     // preload selection : 11 or 00
  rand logic       neg_ena;
  rand logic       pos_dis;

  rand logic [2:0] points_sel;      
  // Point Selection - 0/1/2/3/4/5/6: 64/32/16/8/4/2/1 points (load_points_sel = 1) if it is 0, not used

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

  rand logic       wg_sine_en;
  rand logic       wg_triangle_en;
  rand logic       wg_pulse_en;
  rand logic       wg_dc_en;

  rand logic [15:0] wave0_pos_clk_num;
  rand logic [15:0] wave1_pos_clk_num;
  rand logic [15:0] wave2_pos_clk_num;

  rand logic [15:0] wave0_rest_clk_num;
  rand logic [15:0] wave1_rest_clk_num;
  rand logic [15:0] wave2_rest_clk_num;

  rand logic [5:0]  discharge_num;

  rand logic       wg_rest_en;
  rand logic       wg_ems_en;
  rand logic       wg_alt_en;
  rand logic       wg_dds_en;
  rand logic       wg_discharge_en;
  rand logic       wg_interrupt_en;

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

  function new (string name = "soc_wavegen_pair_drv_base_test_cfg");
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
                                 wg_triangle_en == 1'b1 -> preload_sel inside {2,3};
                                 wg_pulse_en == 1'b1 -> preload_sel inside {1,3};
                               } // bit[2:1] WAVEFORM_SEL of AWG_CTRL_REG0: 0x01 - 00: Preloaded SINE, 11: Used waveform loaded from SPI 

  //neg_ena
  //constraint c_neg_ena         { (/*(load_points_sel == 1'b1) || */(pos_neg_diff_sel == 1'b1) || (python_check_en == 1'b1)) -> neg_ena == 1'b1;}

  constraint c_neg_ena         { neg_ena == 1'b0; }

  //pos_dis
  // constraint c_pos_dis         { ((neg_ena == 1'b0)/* || (load_points_sel == 1'b1)*/ || (pos_neg_diff_sel == 1'b1) || (python_check_en == 1'b1)) -> pos_dis == 1'b0;}
  constraint c_pos_dis         { pos_dis == 1'b0; }

  constraint c_wg_sine_en      { wg_sine_en == 1'b0; }

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
                                 (python_check_en == 1'b0) -> waveform_sel inside {[0:2]};
                                 (wg_sine_en || wg_triangle_en || wg_pulse_en || wg_dc_en) == 1 -> waveform_sel inside {[0:0]};
                               }

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

  constraint c_wavegen_drv_mode  { foreach (wavegen_drv_mode[i]) { if (!wavegen_drv_en[i]) wavegen_drv_mode[i] == 0; } // 0 is Source and 1 is Sink 
                                     $countones(wavegen_drv_mode) == 1;
                                   } 

  constraint c_wavegen_drv_en { $countones(wavegen_drv_en) == 2; } // 0 and 1 is enabled

  constraint c_wg_scoreboard_en         { wg_scoreboard_en == 1; } // 0 and 1 is enabled

  constraint c_wg_wave0_pos_clk_num { wave0_pos_clk_num inside {[10:1000]} ;} 
  constraint c_wg_wave1_pos_clk_num { wave1_pos_clk_num inside {[10:1000]} ;} 
  constraint c_wg_wave2_pos_clk_num { wave2_pos_clk_num inside {[10:1000]} ;} 

  constraint c_wg_wave0_rest_clk_num { wg_rest_en == 1 -> wave0_rest_clk_num inside {[10:1000]} ; wg_rest_en == 0 -> wave0_rest_clk_num == 0; } 
  constraint c_wg_wave1_rest_clk_num { wg_rest_en == 1 -> wave1_rest_clk_num inside {[10:1000]} ; wg_rest_en == 0 -> wave1_rest_clk_num == 0; } 
  constraint c_wg_wave2_rest_clk_num { wg_rest_en == 1 -> wave2_rest_clk_num inside {[10:1000]} ; wg_rest_en == 0 -> wave2_rest_clk_num == 0; } 

  constraint c_wg_discharge_num { wg_discharge_en == 1 -> discharge_num inside {[1:63]} ; wg_discharge_en == 0 -> discharge_num == 0; } 

  constraint c_wg_rest_en            { wg_rest_en inside {[0:1]};} // 0 and 1 is enabled

  constraint c_wg_ems_en             { wg_ems_en inside {[0:0]};} // 0 and 1 is enabled

  constraint c_wg_alt_en             { wg_alt_en inside {[0:0]};} // 0 and 1 is enabled

  constraint c_wg_dds_en             { wg_dds_en inside {[0:0]};} // 0 and 1 is enabled

  constraint c_wg_discharge_en       { wg_discharge_en inside {[0:0]};} // 0 and 1 is enabled 

  constraint c_wg_interrupt_en       { wg_interrupt_en inside {[0:0]};} // 0 and 1 is enabled 

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
    `nnc_top.set_timeout(2s);
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
    `DUT_IF.wg_discharge_num[k] = top_test_cfg.discharge_num;
    end

    `DUT_IF.wg_rest_en = top_test_cfg.wg_rest_en;
    `DUT_IF.wg_ems_en  = top_test_cfg.wg_ems_en;
    `DUT_IF.wg_alt_en  = top_test_cfg.wg_alt_en;
    `DUT_IF.wg_dds_en  = top_test_cfg.wg_dds_en;
    `DUT_IF.wg_discharge_en  = top_test_cfg.wg_discharge_en;
    `DUT_IF.wg_interrupt_en   = top_test_cfg.wg_interrupt_en;

    phase.drop_objection(this);
  endtask : pre_reset_phase

  // -----------------------------------------
  // Declare the reset_phase task 
  // -----------------------------------------
  virtual task reset_phase(nnc_phase phase);
    phase.raise_objection(this);

    super.reset_phase(phase);

    // -------------------
    // Scoreboard enables
    // -------------------

    phase.drop_objection(this);
  endtask : reset_phase

  // -----------------------------------------
  // Declare the main_phase task of your test
  // -----------------------------------------
  virtual task main_phase(nnc_phase phase);
    phase.raise_objection(this);

    super.main_phase(phase);

    `nnc_info("SOC_TEST", "soc_wavegen_pair_drv_base_test start", NNC_LOW)

    // ==================================================================================
    // Please add your code of your test here
    // ----------------------------------------------------------------------------------

    // Step 1: Do the common set up for Wavegen
    wavegen_setup(0);//chip 0

    // --------------------------------------------------------------------------------------------------------- 
    // Step 2. Configure the connection relationship, that is, how these two   drives are physically connected.
    // --------------------------------------------------------------------------------------------------------- 
    //    d0 : wavegen register 0x3e&0x3f,set the value of 0x3e to 0x02, it
    //         means when d0 is working, it will be connected to the switch(PULLDOWN end) of d1
    //    d1 : wavegen register 0x7e&0x7f,set the value of 0x7e to 0x01, it
    //         means when d1 is working, it will be connected to the 
    //         switch(PULLDOWN end) of d0
    // --------------------------------------------------------------------------------------------------------- 

    if (|`DUT_IF.wavegen_drv_en[3:0] === 1'b1) begin 
      $display("## ============================================================================ ##");
      $display("##         PROGRAM FOR GLOBAL to change DRV Select                              ##");   
      $display("## ============================================================================ ##");
      assert(top_test_cfg.randomize() with {reg_addr == `SOC_WAVEGEN_GLOBAL_REG; wr_data[0] == (8'h00<<1);});
      `nnc_info("SOC_TEST", "Enable drivers using global register", NNC_LOW)
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

      if (|`DUT_IF.wavegen_drv_en[0] === 1'b1) begin 
        // Step 2: Do the configuration for Wavegen 0
        wavegen_drv_config(2'b00, `WAVEGEN_0_ADDR_BASE, 0);
   
        $display("## ============================================================================ ##");
        $display("##         PROGRAM FOR SOC_AWG_DRIVEC_SW_CFG0_REG (set SRC and SINK)            ##");   
        $display("## ============================================================================ ##");
        `WR_WAVEGEN_REG(`SOC_AWG_DRIVEC_SW_CFG0_REG+`WAVEGEN_0_ADDR_BASE, {`DUT_IF.wavegen_drv_en[7:1], 1'b0}, 8'h00);
        `WR_WAVEGEN_REG(`SOC_AWG_DRIVEC_SW_CFG1_REG+`WAVEGEN_0_ADDR_BASE, `DUT_IF.wavegen_drv_en[15:8], 8'h00);
      end

      if (|`DUT_IF.wavegen_drv_en[1] === 1'b1) begin 
        // Step 3: Do the configuration for Wavegen 1
        wavegen_drv_config(2'b00, `WAVEGEN_1_ADDR_BASE, 1);

        $display("## ============================================================================ ##");
        $display("##         PROGRAM FOR SOC_AWG_DRIVEC_SW_CFG0_REG (set SRC and SINK)            ##");   
        $display("## ============================================================================ ##");
        `WR_WAVEGEN_REG(`SOC_AWG_DRIVEC_SW_CFG0_REG+`WAVEGEN_1_ADDR_BASE, {`DUT_IF.wavegen_drv_en[7:2], 1'b0, `DUT_IF.wavegen_drv_en[0]}, 8'h00);
        `WR_WAVEGEN_REG(`SOC_AWG_DRIVEC_SW_CFG1_REG+`WAVEGEN_1_ADDR_BASE, `DUT_IF.wavegen_drv_en[15:8], 8'h00);
      end

      if (|`DUT_IF.wavegen_drv_en[2] === 1'b1) begin 
        // Step 4: Do the configuration for Wavegen 2
        wavegen_drv_config(2'b00, `WAVEGEN_2_ADDR_BASE, 2);

        $display("## ============================================================================ ##");
        $display("##         PROGRAM FOR SOC_AWG_DRIVEC_SW_CFG0_REG (set SRC and SINK)            ##");   
        $display("## ============================================================================ ##");
        `WR_WAVEGEN_REG(`SOC_AWG_DRIVEC_SW_CFG0_REG+`WAVEGEN_2_ADDR_BASE, {`DUT_IF.wavegen_drv_en[7:3], 1'b0, `DUT_IF.wavegen_drv_en[1:0]}, 8'h00);
        `WR_WAVEGEN_REG(`SOC_AWG_DRIVEC_SW_CFG1_REG+`WAVEGEN_2_ADDR_BASE, `DUT_IF.wavegen_drv_en[15:8], 8'h00);
      end

      if (|`DUT_IF.wavegen_drv_en[3] === 1'b1) begin 
        // Step 5: Do the configuration for Wavegen 3
        wavegen_drv_config(2'b00, `WAVEGEN_3_ADDR_BASE, 3);

        $display("## ============================================================================ ##");
        $display("##         PROGRAM FOR SOC_AWG_DRIVEC_SW_CFG0_REG (set SRC and SINK)            ##");   
        $display("## ============================================================================ ##");
        `WR_WAVEGEN_REG(`SOC_AWG_DRIVEC_SW_CFG0_REG+`WAVEGEN_3_ADDR_BASE, {`DUT_IF.wavegen_drv_en[7:4], 1'b0, `DUT_IF.wavegen_drv_en[2:0]}, 8'h00);
        `WR_WAVEGEN_REG(`SOC_AWG_DRIVEC_SW_CFG1_REG+`WAVEGEN_3_ADDR_BASE, `DUT_IF.wavegen_drv_en[15:8], 8'h00);
      end
    end

    if (|`DUT_IF.wavegen_drv_en[7:4] === 1'b1) begin 
      $display("## ============================================================================ ##");
      $display("##         PROGRAM FOR GLOBAL to change DRV Select                              ##");   
      $display("## ============================================================================ ##");
      assert(top_test_cfg.randomize() with {reg_addr == `SOC_WAVEGEN_GLOBAL_REG; wr_data[0] == (8'h01<<1);});
      `nnc_info("SOC_TEST", "Enable drivers using global register", NNC_LOW)
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

      if (|`DUT_IF.wavegen_drv_en[4] === 1'b1) begin 
        // Step 6: Do the configuration for Wavegen 4
        wavegen_drv_config(2'b01, `WAVEGEN_4_ADDR_BASE, 4);

        $display("## ============================================================================ ##");
        $display("##         PROGRAM FOR SOC_AWG_DRIVEC_SW_CFG0_REG (set SRC and SINK)            ##");   
        $display("## ============================================================================ ##");
        `WR_WAVEGEN_REG(`SOC_AWG_DRIVEC_SW_CFG0_REG+`WAVEGEN_4_ADDR_BASE, {`DUT_IF.wavegen_drv_en[7:5], 1'b0, `DUT_IF.wavegen_drv_en[3:0]}, 8'h00);
        `WR_WAVEGEN_REG(`SOC_AWG_DRIVEC_SW_CFG1_REG+`WAVEGEN_4_ADDR_BASE, `DUT_IF.wavegen_drv_en[15:8], 8'h00);
      end

      if (|`DUT_IF.wavegen_drv_en[5] === 1'b1) begin 
        // Step 7: Do the configuration for Wavegen 5
        wavegen_drv_config(2'b01, `WAVEGEN_5_ADDR_BASE, 5);

        $display("## ============================================================================ ##");
        $display("##         PROGRAM FOR SOC_AWG_DRIVEC_SW_CFG0_REG (set SRC and SINK)            ##");   
        $display("## ============================================================================ ##");
        `WR_WAVEGEN_REG(`SOC_AWG_DRIVEC_SW_CFG0_REG+`WAVEGEN_5_ADDR_BASE, {`DUT_IF.wavegen_drv_en[7:6], 1'b0, `DUT_IF.wavegen_drv_en[4:0]}, 8'h00);
        `WR_WAVEGEN_REG(`SOC_AWG_DRIVEC_SW_CFG1_REG+`WAVEGEN_5_ADDR_BASE, `DUT_IF.wavegen_drv_en[15:8], 8'h00);
      end

      if (|`DUT_IF.wavegen_drv_en[6] === 1'b1) begin 
        // Step 8: Do the configuration for Wavegen 6
        wavegen_drv_config(2'b01, `WAVEGEN_6_ADDR_BASE, 6);

        $display("## ============================================================================ ##");
        $display("##         PROGRAM FOR SOC_AWG_DRIVEC_SW_CFG0_REG (set SRC and SINK)            ##");   
        $display("## ============================================================================ ##");
        `WR_WAVEGEN_REG(`SOC_AWG_DRIVEC_SW_CFG0_REG+`WAVEGEN_6_ADDR_BASE, {`DUT_IF.wavegen_drv_en[7], 1'b0, `DUT_IF.wavegen_drv_en[5:0]}, 8'h00);
        `WR_WAVEGEN_REG(`SOC_AWG_DRIVEC_SW_CFG1_REG+`WAVEGEN_6_ADDR_BASE, `DUT_IF.wavegen_drv_en[15:8], 8'h00);
      end

      if (|`DUT_IF.wavegen_drv_en[7] === 1'b1) begin 
        // Step 9: Do the configuration for Wavegen 7
        wavegen_drv_config(2'b01, `WAVEGEN_7_ADDR_BASE, 7);

        $display("## ============================================================================ ##");
        $display("##         PROGRAM FOR SOC_AWG_DRIVEC_SW_CFG0_REG (set SRC and SINK)            ##");   
        $display("## ============================================================================ ##");
        `WR_WAVEGEN_REG(`SOC_AWG_DRIVEC_SW_CFG0_REG+`WAVEGEN_7_ADDR_BASE, {1'b0, `DUT_IF.wavegen_drv_en[6:0]}, 8'h00);
        `WR_WAVEGEN_REG(`SOC_AWG_DRIVEC_SW_CFG1_REG+`WAVEGEN_7_ADDR_BASE, `DUT_IF.wavegen_drv_en[15:8], 8'h00);
      end
    end

    if (|`DUT_IF.wavegen_drv_en[11:8] === 1'b1) begin 
      assert(top_test_cfg.randomize() with {reg_addr == `SOC_WAVEGEN_GLOBAL_REG; wr_data[0] == (8'h02<<1);});
      `nnc_info("SOC_TEST", "Enable drivers using global register", NNC_LOW)
      $display("## ============================================================================ ##");
      $display("##         PROGRAM FOR GLOBAL to change DRV Select                              ##");   
      $display("## ============================================================================ ##");
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

      if (|`DUT_IF.wavegen_drv_en[8] === 1'b1) begin 
        // Step 10: Do the configuration for Wavegen 8
        wavegen_drv_config(2'b10, `WAVEGEN_8_ADDR_BASE, 8);

        $display("## ============================================================================ ##");
        $display("##         PROGRAM FOR SOC_AWG_DRIVEC_SW_CFG0_REG (set SRC and SINK)            ##");   
        $display("## ============================================================================ ##");
        `WR_WAVEGEN_REG(`SOC_AWG_DRIVEC_SW_CFG0_REG+`WAVEGEN_8_ADDR_BASE, `DUT_IF.wavegen_drv_en[7:0], 8'h00);
        `WR_WAVEGEN_REG(`SOC_AWG_DRIVEC_SW_CFG1_REG+`WAVEGEN_8_ADDR_BASE, {`DUT_IF.wavegen_drv_en[15:9], 1'b0}, 8'h00);
      end

      if (|`DUT_IF.wavegen_drv_en[9] === 1'b1) begin 
        // Step 11: Do the configuration for Wavegen 9
        wavegen_drv_config(2'b10, `WAVEGEN_9_ADDR_BASE, 9);

        $display("## ============================================================================ ##");
        $display("##         PROGRAM FOR SOC_AWG_DRIVEC_SW_CFG0_REG (set SRC and SINK)            ##");   
        $display("## ============================================================================ ##");
        `WR_WAVEGEN_REG(`SOC_AWG_DRIVEC_SW_CFG0_REG+`WAVEGEN_9_ADDR_BASE, `DUT_IF.wavegen_drv_en[7:0], 8'h00);
        `WR_WAVEGEN_REG(`SOC_AWG_DRIVEC_SW_CFG1_REG+`WAVEGEN_9_ADDR_BASE, {`DUT_IF.wavegen_drv_en[15:10], 1'b0, `DUT_IF.wavegen_drv_en[8]}, 8'h00);
      end

      if (|`DUT_IF.wavegen_drv_en[10] === 1'b1) begin 
        // Step 12: Do the configuration for Wavegen 10
        wavegen_drv_config(2'b10, `WAVEGEN_10_ADDR_BASE, 10);

        $display("## ============================================================================ ##");
        $display("##         PROGRAM FOR SOC_AWG_DRIVEC_SW_CFG0_REG (set SRC and SINK)            ##");   
        $display("## ============================================================================ ##");
        `WR_WAVEGEN_REG(`SOC_AWG_DRIVEC_SW_CFG0_REG+`WAVEGEN_10_ADDR_BASE, `DUT_IF.wavegen_drv_en[7:0], 8'h00);
        `WR_WAVEGEN_REG(`SOC_AWG_DRIVEC_SW_CFG1_REG+`WAVEGEN_10_ADDR_BASE, {`DUT_IF.wavegen_drv_en[15:11], 1'b0, `DUT_IF.wavegen_drv_en[9:8]}, 8'h00);
      end

      if (|`DUT_IF.wavegen_drv_en[11] === 1'b1) begin 
        // Step 13: Do the configuration for Wavegen 11
        wavegen_drv_config(2'b10, `WAVEGEN_11_ADDR_BASE, 11);

        $display("## ============================================================================ ##");
        $display("##         PROGRAM FOR SOC_AWG_DRIVEC_SW_CFG0_REG (set SRC and SINK)            ##");   
        $display("## ============================================================================ ##");
        `WR_WAVEGEN_REG(`SOC_AWG_DRIVEC_SW_CFG0_REG+`WAVEGEN_11_ADDR_BASE, `DUT_IF.wavegen_drv_en[7:0], 8'h00);
        `WR_WAVEGEN_REG(`SOC_AWG_DRIVEC_SW_CFG1_REG+`WAVEGEN_11_ADDR_BASE, {`DUT_IF.wavegen_drv_en[15:12], 1'b0, `DUT_IF.wavegen_drv_en[10:8]}, 8'h00);
      end

    end

    if (|`DUT_IF.wavegen_drv_en[15:12] === 1'b1) begin 
      assert(top_test_cfg.randomize() with {reg_addr == `SOC_WAVEGEN_GLOBAL_REG; wr_data[0] == (8'h03<<1);});
      `nnc_info("SOC_TEST", "Enable drivers using global register", NNC_LOW)
      $display("## ============================================================================ ##");
      $display("##         PROGRAM FOR GLOBAL to change DRV Select                              ##");   
      $display("## ============================================================================ ##");
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

      if (|`DUT_IF.wavegen_drv_en[12] === 1'b1) begin 
        // Step 14: Do the configuration for Wavegen 12
        wavegen_drv_config(2'b11, `WAVEGEN_12_ADDR_BASE, 12);

        $display("## ============================================================================ ##");
        $display("##         PROGRAM FOR SOC_AWG_DRIVEC_SW_CFG0_REG (set SRC and SINK)            ##");   
        $display("## ============================================================================ ##");
        `WR_WAVEGEN_REG(`SOC_AWG_DRIVEC_SW_CFG0_REG+`WAVEGEN_12_ADDR_BASE, `DUT_IF.wavegen_drv_en[7:0], 8'h00);
        `WR_WAVEGEN_REG(`SOC_AWG_DRIVEC_SW_CFG1_REG+`WAVEGEN_12_ADDR_BASE, {`DUT_IF.wavegen_drv_en[15:13], 1'b0, `DUT_IF.wavegen_drv_en[11:8]}, 8'h00);
      end

      if (|`DUT_IF.wavegen_drv_en[13] === 1'b1) begin 
        // Step 15: Do the configuration for Wavegen 13
        wavegen_drv_config(2'b11, `WAVEGEN_13_ADDR_BASE, 13);

        $display("## ============================================================================ ##");
        $display("##         PROGRAM FOR SOC_AWG_DRIVEC_SW_CFG0_REG (set SRC and SINK)            ##");   
        $display("## ============================================================================ ##");
        `WR_WAVEGEN_REG(`SOC_AWG_DRIVEC_SW_CFG0_REG+`WAVEGEN_13_ADDR_BASE, `DUT_IF.wavegen_drv_en[7:0], 8'h00);
        `WR_WAVEGEN_REG(`SOC_AWG_DRIVEC_SW_CFG1_REG+`WAVEGEN_13_ADDR_BASE, {`DUT_IF.wavegen_drv_en[15:14], 1'b0, `DUT_IF.wavegen_drv_en[12:8]}, 8'h00);
      end

      if (|`DUT_IF.wavegen_drv_en[14] === 1'b1) begin 
        // Step 16: Do the configuration for Wavegen 14
        wavegen_drv_config(2'b11, `WAVEGEN_14_ADDR_BASE, 14);

        $display("## ============================================================================ ##");
        $display("##         PROGRAM FOR SOC_AWG_DRIVEC_SW_CFG0_REG (set SRC and SINK)            ##");   
        $display("## ============================================================================ ##");
        `WR_WAVEGEN_REG(`SOC_AWG_DRIVEC_SW_CFG0_REG+`WAVEGEN_14_ADDR_BASE, `DUT_IF.wavegen_drv_en[7:0], 8'h00);
        `WR_WAVEGEN_REG(`SOC_AWG_DRIVEC_SW_CFG1_REG+`WAVEGEN_14_ADDR_BASE, {`DUT_IF.wavegen_drv_en[15], 1'b0, `DUT_IF.wavegen_drv_en[13:8]}, 8'h00);
      end

      if (|`DUT_IF.wavegen_drv_en[15] === 1'b1) begin 
        // Step 17: Do the configuration for Wavegen 15
        wavegen_drv_config(2'b11, `WAVEGEN_15_ADDR_BASE, 15);

        $display("## ============================================================================ ##");
        $display("##         PROGRAM FOR SOC_AWG_DRIVEC_SW_CFG0_REG (set SRC and SINK)            ##");   
        $display("## ============================================================================ ##");
        `WR_WAVEGEN_REG(`SOC_AWG_DRIVEC_SW_CFG0_REG+`WAVEGEN_15_ADDR_BASE, `DUT_IF.wavegen_drv_en[7:0], 8'h00);
        `WR_WAVEGEN_REG(`SOC_AWG_DRIVEC_SW_CFG1_REG+`WAVEGEN_15_ADDR_BASE, {1'b0, `DUT_IF.wavegen_drv_en[14:8]}, 8'h00);
      end
    end

    // Step 4: Enable all wavegen at the time
    wavegen_drv_enable;
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
    // Step 5: Waiting for Wave generated successfully
    $display("## ============================================================================ ##");
    $display("##         WAITING FOR SIMULATION TO COMPLETE WAVEFORM GENERATION               ##");
    $display("## ---------------------------------------------------------------------------- ##"); 
    $display("##         NUMBER OF WAVEFORM: %d                                               ", `DUT_IF.wg_waveform_sel == 3'b000 ? 1 :  `DUT_IF.wg_waveform_sel == 3'b001 ? 2 : `DUT_IF.wg_waveform_sel == 3'b010 ? 3 : 0);
    $display("## ---------------------------------------------------------------------------- ##");
if (`DUT_IF.wg_waveform_sel === 3'b000) begin 
    if (`DUT_IF.wg_sine_en == 1)
    $display("##         SINE WAVE WILL BE GENERATED                                          ##");      
    if (`DUT_IF.wg_triangle_en == 1)
    $display("##         TRIANGLE WAVE WILL BE GENERATED                                      ##"); 
    if (`DUT_IF.wg_pulse_en == 1)
    $display("##         PULSE WAVE WILL BE GENERATED                                         ##"); 
    if (`DUT_IF.wg_dc_en == 1)
    $display("##         DC WAVE WILL BE GENERATED                                            ##");  
end else if (`DUT_IF.wg_waveform_sel === 3'b001) begin
    if (`DUT_IF.wg_preload_sel == 2'b00)
    $display("##         Waveform 1: SINE, Waveform 2: PULSE WILL BE GENERATED                ##");
    else if (`DUT_IF.wg_preload_sel == 2'b01)
    $display("##         Waveform 1: SINE, Waveform2: TRIANGLE WILL BE GENERATED              ##");
    else if (`DUT_IF.wg_preload_sel == 2'b10)
    $display("##         Waveform 1: PULSE, Waveform2: TRIANGLE WILL BE GENERATED             ##");
    else
    $display("##         Waveform 1: and Waveform2: by SPI and WILL BE GENERATED              ##");
end else if (`DUT_IF.wg_waveform_sel === 3'b010) begin
    if (`DUT_IF.wg_preload_sel == 2'b00)
    $display("##  Waveform 1: SINE, Waveform 2: PULSE, Waveform 3: TRIANGLE WILL BE GENERATED ##");
    else if (`DUT_IF.wg_preload_sel == 2'b01)
    $display("##  Waveform 1: SINE, Waveform 2: TRIANGLE, Waveform 3: PULSE WILL BE GENERATED ##");
    else
    $display("##  Waveform 1/2/3 by SPI and WILL BE GENERATED                                 ##");
end
    $display("## ---------------------------------------------------------------------------- ##");
    $display("##         NUMBER OF POINTS PER HALFWAVE: %2d                                    ", `DUT_IF.wg_drv_pnt_cfg);
    $display("## ---------------------------------------------------------------------------- ##");
    $display("##         NUMBER OF CLK PER POINT: %4d                                         ", `DUT_IF.wg_wave0_pos_clk_num[0]);
    $display("## ---------------------------------------------------------------------------- ##");
    if (`DUT_IF.wg_preload_sel == 2'b11)
    $display("##         Waveform Points are programmed from SPI                              ##");
    else
    $display("##         Waveform Points are loaded from ON CHIP mem                          ##");
    $display("## ============================================================================ ##");

    for (int i = 0; i < `WAVEGEN_DRIVER_NUM; i++) begin
      if (`DUT_IF.wavegen_drv_mode[i] & `DUT_IF.wavegen_drv_en[i]) begin
        $display("## ---------------------------------------------------------------------------- ##");
       if (`DUT_IF.wg_dc_en == 1)
        $display("##         Driver No: %2d, is not enable and configured as SINK mode             ##", i); 
       else
        $display("##         Driver No: %2d, is enabled and configured as SINK mode                ##", i);      
        $display("## ---------------------------------------------------------------------------- ##");
      end else if (!`DUT_IF.wavegen_drv_mode[i] & `DUT_IF.wavegen_drv_en[i]) begin
        $display("## ---------------------------------------------------------------------------- ##");
        $display("##         Driver No: %2d, is enabled and configured as SOURCE mode              ##", i);      
        $display("## ---------------------------------------------------------------------------- ##");
      end else begin 
        $display("## ---------------------------------------------------------------------------- ##");
        $display("##         Driver No: %2d, is disabled                                           ##", i);      
        $display("## ---------------------------------------------------------------------------- ##");
      end 
    end

    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    `DUT_IF.python_length = `DUT_IF.wg_drv_pnt_cfg * 2 * 4;
/*
    if(`DUT_IF.python_check_en === 0)
    	#200ms;
    else begin
        wait(`SOC_TB.py_tb.python_data_num_0 + `SOC_TB.py_tb.python_data_num_1 === `DUT_IF.python_length);
	#1ms;
    end
*/ // if (`DUT_IF.wg_sine_en === 1'b1) begin
   // wait(`SOC_TB.py_tb.src_cnt_no + `SOC_TB.py_tb.python_data_num_1 === `DUT_IF.python_length);
   // #1ms;
   // end else 
   // #200ms;
     if (`DUT_IF.wg_dc_en == 1) begin
       #10ms;
        if (`SOC_TB.no_wave == 1'b0) begin
          `nnc_error("DC ERROR", $sformatf("No PULL on SNK is happened"))
        end
     end
     else begin
       wait(`DUT_IF.src_cnt_no == 6);
     end
    `nnc_info("SOC_TEST", "soc_wavegen_pair_drv_base_test end now", NNC_LOW)

    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ==================================================================================

    phase.drop_objection(this);
  endtask: main_phase

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
    top_test_cfg.LOAD_POINTS = `DUT_IF.wg_load_points_sel;
    top_test_cfg.NO_OF_WAVEFORMS = `DUT_IF.wg_waveform_sel;
    top_test_cfg.PRELOAD = `DUT_IF.wg_preload_sel;
    top_test_cfg.NEG_ON = `DUT_IF.wg_neg_ena;
    top_test_cfg.POS_OFF = `DUT_IF.wg_pos_dis;
    top_test_cfg.POS_NEG_DIFF = `DUT_IF.wg_pos_neg_diff_sel;
    top_test_cfg.PULLAB_CTRL  = {`DUT_IF.wg_PULLAB_pos_en, `DUT_IF.wg_PULLAB_neg_en, `DUT_IF.wg_PULLAB_lim};
    
    // From constraint of points_sel, decode and save NO_OF_POINTS and load correct hex file of sine wave
    for (int i=0; i<16; i++) begin
      case(top_test_cfg.points_sel)

         3'b000:begin // 64
		    top_test_cfg.NO_OF_POINTS = `WAVEGEN_MAX_POINT;
                       if(`DUT_IF.wg_sine_en == 1'b1) 
		    	 $readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y64", mem_tmp);
                       else if (`DUT_IF.wg_triangle_en == 1'b1)   
                         $readmemh("../../../verification/models/wavegen_stimulus/triangle/hex_y64", mem_tmp); 
		end

         3'b001:begin // 32
		    top_test_cfg.NO_OF_POINTS = `WAVEGEN_MAX_POINT/2;
                       if(`DUT_IF.wg_sine_en == 1'b1) 
		    	 $readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y32", mem_tmp);
                       else if (`DUT_IF.wg_triangle_en == 1'b1)   
                         $readmemh("../../../verification/models/wavegen_stimulus/triangle/hex_y32", mem_tmp); 
		end
 
         3'b010:begin // 16
		    top_test_cfg.NO_OF_POINTS = `WAVEGEN_MAX_POINT/4;
                       if(`DUT_IF.wg_sine_en == 1'b1) 
		    	 $readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y16", mem_tmp);
                       else if (`DUT_IF.wg_triangle_en == 1'b1)   
                         $readmemh("../../../verification/models/wavegen_stimulus/triangle/hex_y16", mem_tmp); 
		end

         3'b011:begin // 8
		    top_test_cfg.NO_OF_POINTS = `WAVEGEN_MAX_POINT/8;
                       if(`DUT_IF.wg_sine_en == 1'b1) 
		    	 $readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y8", mem_tmp);
                       else if (`DUT_IF.wg_triangle_en == 1'b1)   
                         $readmemh("../../../verification/models/wavegen_stimulus/triangle/hex_y8", mem_tmp); 
		end

         3'b100:begin // 4
		    top_test_cfg.NO_OF_POINTS = `WAVEGEN_MAX_POINT/16;
                       if(`DUT_IF.wg_sine_en == 1'b1) 
		    	 $readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y4", mem_tmp);
                       else if (`DUT_IF.wg_triangle_en == 1'b1)   
                         $readmemh("../../../verification/models/wavegen_stimulus/triangle/hex_y4", mem_tmp); 
		end

         3'b101:begin // 2
		    top_test_cfg.NO_OF_POINTS = `WAVEGEN_MAX_POINT/32;
                       if(`DUT_IF.wg_sine_en == 1'b1) 
		    	 $readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y2", mem_tmp);
                       else if (`DUT_IF.wg_triangle_en == 1'b1)   
                         $readmemh("../../../verification/models/wavegen_stimulus/triangle/hex_y2", mem_tmp); 
		end

         3'b110:begin // 1
		    top_test_cfg.NO_OF_POINTS = `WAVEGEN_MAX_POINT/64;
                    if(`DUT_IF.wg_sine_en == 1'b1) 
		      $readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y1", mem_tmp);
                    else if (`DUT_IF.wg_triangle_en == 1'b1)  
                      $readmemh("../../../verification/models/wavegen_stimulus/triangle/hex_y1", mem_tmp); 
		end

         3'b111:begin // 64
		    top_test_cfg.NO_OF_POINTS = `WAVEGEN_MAX_POINT;
                    if(`DUT_IF.wg_sine_en == 1'b1) 
		      $readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y64", mem_tmp);
                    else if (`DUT_IF.wg_triangle_en == 1'b1)  
                      $readmemh("../../../verification/models/wavegen_stimulus/triangle/hex_y64", mem_tmp); 
		end
      endcase

      for (int j = 0; j < `WAVEGEN_MAX_POINT; j++)
        top_test_cfg.sine_data[i][j] = (`DUT_IF.wg_pulse_en == 1'b1) ? 8'hAB : mem_tmp[j];

    end 

    // Save no points per halfwave to DUT
    `DUT_IF.wg_drv_pnt_cfg = top_test_cfg.NO_OF_POINTS;

    // LOAD_POINTS = 0 (preloaded is enabled)
    if(top_test_cfg.LOAD_POINTS === 0)
	top_test_cfg.NO_OF_LOAD_POINTS = `DUT_IF.wg_drv_pnt_cfg;
    else begin //LOAD_POINTS = 1 (SPI is enabled)
      if(top_test_cfg.NO_OF_WAVEFORMS === 0) // 1 waveform
	//top_test_cfg.NO_OF_LOAD_POINTS = `WAVEGEN_MAX_POINT;
        top_test_cfg.NO_OF_LOAD_POINTS = `DUT_IF.wg_drv_pnt_cfg;
      else begin // Not 1 Waveform
      	if(top_test_cfg.POS_NEG_DIFF === 1) // If using difference address for pos/neg
	   top_test_cfg.NO_OF_LOAD_POINTS = `DUT_IF.wg_drv_pnt_cfg * (top_test_cfg.NO_OF_WAVEFORMS+1);
      	else begin // using the same address
	   if((top_test_cfg.NEG_ON === 1) && (top_test_cfg.POS_OFF === 0)) // Both Negative + Positive Phases 
	   	top_test_cfg.NO_OF_LOAD_POINTS = `DUT_IF.wg_drv_pnt_cfg * (top_test_cfg.NO_OF_WAVEFORMS+1) * 2;
	   else // One Phase only
		top_test_cfg.NO_OF_LOAD_POINTS = `DUT_IF.wg_drv_pnt_cfg * (top_test_cfg.NO_OF_WAVEFORMS+1); // ENS2 is only using this!
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
    for (int i=0; i < 16; i++) begin 
      mem_tmp = top_test_cfg.sine_data[i];
      for (int j = 0; j < `WAVEGEN_MAX_POINT; j++)
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
      top_env.wavegen_vif[chip_num].PULLAB_pos_en[i] = top_test_cfg.PULLAB_CTRL[7];
      top_env.wavegen_vif[chip_num].PULLAB_neg_en[i] = top_test_cfg.PULLAB_CTRL[6];
      top_env.wavegen_vif[chip_num].PULLAB_lim[i] = top_test_cfg.PULLAB_CTRL[5:0];
    end

    `nnc_info("SOC_TEST", $sformatf("NO_OF_POINTS: %d, NO_OF_LOAD_POINTS: %d, LOAD_POINTS:%d", top_test_cfg.NO_OF_POINTS, top_test_cfg.NO_OF_LOAD_POINTS, top_test_cfg.LOAD_POINTS), NNC_LOW)

    // Calculate clock
    top_test_cfg.clk_freq = 8192 / (2**`DUT_IF.pclk_sel);

    // Calculate half period of wave: Point_Num * Period
    top_test_cfg.half_period_limit = (`DUT_IF.wg_drv_pnt_cfg * 1000) / top_test_cfg.clk_freq;

    `nnc_info("SOC_TEST", $sformatf("NO_OF_POINTS: %d, clk_freq: %d, half_period_limit:%d", `DUT_IF.wg_drv_pnt_cfg, top_test_cfg.clk_freq, top_test_cfg.half_period_limit), NNC_LOW)
 

    // ==================================
    // Set configurations for VIPs
    // ==================================
    `DUT_IF.wg_same_pos_neg_period = top_test_cfg.same_pos_neg_period;
    `DUT_IF.wg_half_period0[0] = top_test_cfg.half_period0[0];
    `DUT_IF.wg_half_period1[0] = top_test_cfg.half_period1[0];
    `DUT_IF.wg_half_period2[0] = top_test_cfg.half_period2[0];

    for (int i = 0; i < `WAVEGEN_DRIVER_NUM; i++) begin

      `nnc_info("SOC_TEST", $sformatf("same_pos_neg_period:%d", `DUT_IF.wg_same_pos_neg_period), NNC_LOW)
      // ======================================================================================================================

      // ----------------------------------
      // Calculating for Wave0
      // ----------------------------------
      top_test_cfg.rest_lim = 0;
      // Updating for DUT Interface for Wave0
      if ((`DUT_IF.wg_dc_en == 1) && (`DUT_IF.wavegen_drv_mode[i] == 1'b1)) begin // DC Wavegen and Source (No Rest, No Silent, No Neg)
        `DUT_IF.wg_hlf_wave0_lim[i] =  `DUT_IF.wg_wave0_pos_clk_num[i]; 
        `DUT_IF.wg_neg_hlf_wave0_lim[i] = 0;
        `DUT_IF.wg_rest_wave0_lim[i] = 0;
        `DUT_IF.wg_silent_wave0_lim[i] = 0;
      end else if ((`DUT_IF.wg_dc_en == 1) && (!`DUT_IF.wavegen_drv_mode[i] == 1'b1)) begin // DC Wavegen and Source (No Rest, No Silent, No Neg)
        `DUT_IF.wg_hlf_wave0_lim[i] = `DUT_IF.wg_wave0_pos_clk_num[i]; 
        `DUT_IF.wg_neg_hlf_wave0_lim[i] = 0;
        `DUT_IF.wg_rest_wave0_lim[i] = 0;
        `DUT_IF.wg_silent_wave0_lim[i] = 0;
      end else begin
        `DUT_IF.wg_hlf_wave0_lim[i] = `DUT_IF.wg_wave0_pos_clk_num[i]; 
        `DUT_IF.wg_neg_hlf_wave0_lim[i] = 0;
        `DUT_IF.wg_rest_wave0_lim[i] = `DUT_IF.wg_wave0_rest_clk_num[i];
        `DUT_IF.wg_silent_wave0_lim[i] = `DUT_IF.wg_wave0_pos_clk_num[i] * `DUT_IF.wg_drv_pnt_cfg + `DUT_IF.wg_wave0_rest_clk_num[i];
      end

      // ----------------------------------
      // Calculating for Wave1
      // ----------------------------------
      top_test_cfg.rest_lim = 0; 
      // Updating for DUT Interface for Wave1
      `DUT_IF.wg_hlf_wave1_lim[i] = `DUT_IF.wg_wave1_pos_clk_num[i];
      `DUT_IF.wg_neg_hlf_wave1_lim[i] = 0;
      `DUT_IF.wg_rest_wave1_lim[i] = `DUT_IF.wg_wave1_rest_clk_num[i];
      `DUT_IF.wg_silent_wave1_lim[i] = `DUT_IF.wg_wave1_pos_clk_num[i] * `DUT_IF.wg_drv_pnt_cfg + `DUT_IF.wg_wave1_rest_clk_num[i];

      // ----------------------------------
      // Calculating for Wave2
      // ----------------------------------
      top_test_cfg.rest_lim = 0;
      // Updating for DUT Interface for Wave2
      `DUT_IF.wg_hlf_wave2_lim[i] = `DUT_IF.wg_wave2_pos_clk_num[i];
      `DUT_IF.wg_neg_hlf_wave2_lim[i] = 0;
      `DUT_IF.wg_rest_wave2_lim[i] = `DUT_IF.wg_wave2_rest_clk_num[i];
      `DUT_IF.wg_silent_wave2_lim[i] = `DUT_IF.wg_wave2_pos_clk_num[i] * `DUT_IF.wg_drv_pnt_cfg + `DUT_IF.wg_wave2_rest_clk_num[i];

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

  end
  endtask


  // ******************************************************************
  // This task is used for configuring registers of each of Driver
  // ******************************************************************
  task wavegen_drv_config;
  input [1:0] wg_drv_sel;
  input [7:0] WG_BASE;
  input [4:0] drv_num; 

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

    $display("## ============================================================================ ##");
    $display("##         PROGRAM FOR DRIVER: %2d -  ADDR BASE: %h                              ##", drv_num, WG_BASE);   
    $display("## ============================================================================ ##");

    $display("## ============================================================================ ##");
    $display("##         PROGRAM FOR SOC_ADDR_WG_DRV_CTRL1_REG ( DRV Control)                 ##"); 
    $display("## ============================================================================ ##");
    $display("##    DRIVE_REG_CTRL0: Offset:0x35                                              ##");
    $display("##    - bit-5: data_output_mode - 0: 8-bit, 1: 12-bit                           ##");
    $display("##    - bit-4: mode_sel 1: Manual, 0: Auto                                      ##");
    $display("##    - bit-2: driver_pullD - DRIVER_PULLD (applicable only in manual mode)     ##");
    $display("##    - bit-0: driver_source - DRIVER_SOURCE applicable only in manual mode)    ##");
    $display("## ============================================================================ ##");
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CTRL0_REG + WG_BASE); wr_data[0] == {2'b0, `DUT_IF.wg_dac_bit_len_sel, `DUT_IF.wg_auto_man, 4'b0};});
    //`nnc_info("SOC_TEST", "Set drive reg ctrl0", NNC_LOW)
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    //`nnc_info("SOC_TEST", "Set drive reg ctrl1-2", NNC_LOW)  
    $display("## ============================================================================ ##");
    $display("##    DRIVE_REG_CTRL1: Offset:0x36 - - bit[7:0] - IDAC_DIN_LSB                  ##"); 
    $display("## ============================================================================ ##");
    $display("##    DRIVE_REG_CTRL2: Offset:0x37                                              ##");
    $display("##    - bit7: multi_argo_ctrl - 0: use right shift, 1: use a multiplier         ##");
    $display("##    - bit[6:4]: - 8-bit_location_sel (0 -> 4) to scale up                     ##");
    $display("##    - bit[3:0] - IDAC_DIN_MSB                                                 ##");
    $display("## ============================================================================ ##");
    if (WG_BASE === `WAVEGEN_0_ADDR_BASE) begin // Driver 0
      assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CTRL1_REG + WG_BASE); no_of_bytes == 2; wr_data[0] == {1'b0, `DUT_IF.wg_dac0_msb_sel, `DUT_IF.wg_dac0_data_h}; wr_data[1] == `DUT_IF.wg_dac0_data_l;});
      // 2 registers
      `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);
    end
    else if(WG_BASE === `WAVEGEN_1_ADDR_BASE) begin  // Driver 1
      assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CTRL1_REG + WG_BASE); no_of_bytes == 2; wr_data[0] == {1'b0, `DUT_IF.wg_dac1_msb_sel, `DUT_IF.wg_dac1_data_h}; wr_data[1] == `DUT_IF.wg_dac1_data_l;});
      // 2 registers
      `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);
    end
    else if(WG_BASE === `WAVEGEN_2_ADDR_BASE) begin  // Driver 2
      assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CTRL1_REG + WG_BASE); no_of_bytes == 2; wr_data[0] == {1'b0, `DUT_IF.wg_dac2_msb_sel, `DUT_IF.wg_dac2_data_h}; wr_data[1] == `DUT_IF.wg_dac2_data_l;});
      `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);
    end
    else if(WG_BASE === `WAVEGEN_3_ADDR_BASE) begin  // Driver 3
      assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CTRL1_REG + WG_BASE); no_of_bytes == 2; wr_data[0] == {1'b0, `DUT_IF.wg_dac3_msb_sel, `DUT_IF.wg_dac3_data_h}; wr_data[1] == `DUT_IF.wg_dac3_data_l;});
      `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);
    end

// ===============================================================
// Wave 0: Setting for Rest, Silent, clk per point for pos/Neg
// ===============================================================

    // --------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_REST_T_REG01 (Rest Time) (3 registers)
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_REST_T_REG01 + WG_BASE); no_of_bytes == 3;  wr_data[0] == `DUT_IF.wg_rest_wave0_lim[drv_num][23:15]; wr_data[1] == `DUT_IF.wg_rest_wave0_lim[drv_num][15:8]; wr_data[2] == `DUT_IF.wg_rest_wave0_lim[drv_num][7:0];});
    `nnc_info("SOC_TEST", "Set 0 rest period", NNC_LOW)
    $display("## ============================================================================ ##");
    $display("##         PROGRAM FOR ADDR_WG_DRV_REST_T_REG01 (Rest Time) = %h                ##", `DUT_IF.wg_rest_wave0_lim[drv_num][23:0]);      
    $display("## ============================================================================ ##");
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_SILENT_T_REG01 (Silent Time) (4 registers)
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_SILENT_T_REG01 + WG_BASE); no_of_bytes == 4; wr_data[0] == `DUT_IF.wg_silent_wave0_lim[drv_num][31:24]; wr_data[1] == `DUT_IF.wg_silent_wave0_lim[drv_num][23:16]; wr_data[2] == `DUT_IF.wg_silent_wave0_lim[drv_num][15:8]; wr_data[3] == `DUT_IF.wg_silent_wave0_lim[drv_num][7:0];});
    `nnc_info("SOC_TEST", "Set 0 silent time", NNC_LOW)
    $display("## ============================================================================ ##");
    $display("##    PROGRAM FOR SOC_ADDR_WG_DRV_SILENT_T_REG01 (Silent Time): %h              ##", `DUT_IF.wg_silent_wave0_lim[drv_num][31:0]);      
    $display("## ============================================================================ ##");
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_HLF_WAVE_PRD_REG01 (2 registers)
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_HLF_WAVE_PRD_REG01 + WG_BASE); no_of_bytes == 2; wr_data[0] == `DUT_IF.wg_hlf_wave0_lim[drv_num][15:8]; wr_data[1] == `DUT_IF.wg_hlf_wave0_lim[drv_num][7:0];});
    `nnc_info("SOC_TEST", "Set positive half wave0 period", NNC_LOW)//0x0000_01F4 (500us)
    $display("## ============================================================================ ##");
    $display("##   PROGRAM FOR SOC_ADDR_WG_DRV_HLF_WAVE_PRD_REG01 (1stWave Pos Clk): %h       ##",  `DUT_IF.wg_hlf_wave0_lim[drv_num][15:0]);      
    $display("## ============================================================================ ##");
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_NEG_HLF_WAVE_PRD_REG01 (2 registers)
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_NEG_HLF_WAVE_PRD_REG01 + WG_BASE); no_of_bytes == 2; wr_data[0] == `DUT_IF.wg_neg_hlf_wave0_lim[drv_num][15:8]; wr_data[1] == `DUT_IF.wg_neg_hlf_wave0_lim[drv_num][7:0];});
    `nnc_info("SOC_TEST", "Set negative half wave0 period", NNC_LOW)//0x0000_01F4 (500us)
    $display("## ============================================================================ ##");
    $display("##    PROGRAM FOR SOC_ADDR_WG_DRV_NEG_HLF_WAVE_PRD_REG01 (1stWave Neg Clk): %h", `DUT_IF.wg_neg_hlf_wave0_lim[drv_num][15:8]);      
    $display("## ============================================================================ ##");
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);


// ===============================================================
// Wave 1: Setting for Rest, Silent, clk per point for pos/Neg
// ===============================================================
    // --------------------------------------------------------
    // Write burst starting from SOC_ADDR_WG_DRV_REST_CLK1_REG01 (Rest Time) (2 registers)
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_REST_CLK1_REG01 + WG_BASE); no_of_bytes == 2;  wr_data[0] == `DUT_IF.wg_rest_wave1_lim[drv_num][15:8]; wr_data[1] == `DUT_IF.wg_rest_wave1_lim[drv_num][7:0];});
    `nnc_info("SOC_TEST", "Set 0 rest period", NNC_LOW)
    $display("## ============================================================================ ##");
    $display("##         PROGRAM FOR SOC_ADDR_WG_DRV_REST_CLK1_REG01 (Rest Time) = %h                ##", `DUT_IF.wg_rest_wave1_lim[drv_num][15:0]);      
    $display("## ============================================================================ ##");
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write burst starting from SOC_ADDR_WG_DRV_SILENT_CLK1_REG01 (Silent Time) (4 registers)
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_SILENT_CLK1_REG01 + WG_BASE); no_of_bytes == 4; wr_data[0] == `DUT_IF.wg_silent_wave1_lim[drv_num][31:24]; wr_data[1] == `DUT_IF.wg_silent_wave1_lim[drv_num][23:16]; wr_data[2] == `DUT_IF.wg_silent_wave1_lim[drv_num][15:8]; wr_data[3] == `DUT_IF.wg_silent_wave1_lim[drv_num][7:0];});
    `nnc_info("SOC_TEST", "Set 0 silent time", NNC_LOW)
    $display("## ============================================================================ ##");
    $display("##    PROGRAM FOR SOC_ADDR_WG_DRV_SILENT_CLK1_REG01 (Silent Time): %h              ##", `DUT_IF.wg_silent_wave1_lim[drv_num][31:0]);      
    $display("## ============================================================================ ##");
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // -------------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_HLF_WAVE_CLK_PNT1_REG01
    // -------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_HLF_WAVE_CLK_PNT1_REG01 + WG_BASE); no_of_bytes == 2; wr_data[0] == `DUT_IF.wg_hlf_wave1_lim[drv_num][15:8]; wr_data[1] == `DUT_IF.wg_hlf_wave1_lim[drv_num][7:0];});
    `nnc_info("SOC_TEST", "Set positive half wave1 period", NNC_LOW)//0x0000_01F4 (500us)
    $display("## ============================================================================ ##");
    $display("##    PROGRAM FOR SOC_ADDR_WG_DRV_HLF_WAVE_CLK_PNT1_REG01 (2ndWave Pos Clk)     ##");      
    $display("## ============================================================================ ##");
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // -----------------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT1_REG01
    // -----------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT1_REG01 + WG_BASE); no_of_bytes == 2; wr_data[0] == `DUT_IF.wg_neg_hlf_wave1_lim[drv_num][15:8]; wr_data[1] == `DUT_IF.wg_neg_hlf_wave1_lim[drv_num][7:0];});
    `nnc_info("SOC_TEST", "Set negative half wave1 period", NNC_LOW)//0x0000_01F4 (500us)
    $display("## ============================================================================ ##");
    $display("##    PROGRAM FOR SOC_ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT1_REG01 (2ndWave Neg Clk) ##");      
    $display("## ============================================================================ ##");
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

// ===============================================================
// Wave 2: Setting for Rest, Silent, clk per point for pos/Neg
// ===============================================================

    // --------------------------------------------------------
    // Write burst starting from SOC_ADDR_WG_DRV_REST_CLK2_REG01 (Rest Time) (2 registers)
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_REST_CLK2_REG01 + WG_BASE); no_of_bytes == 2;  wr_data[0] == `DUT_IF.wg_rest_wave2_lim[drv_num][15:8]; wr_data[1] == `DUT_IF.wg_rest_wave2_lim[drv_num][7:0];});
    `nnc_info("SOC_TEST", "Set 0 rest period", NNC_LOW)
    $display("## ============================================================================ ##");
    $display("##         PROGRAM FOR SOC_ADDR_WG_DRV_REST_CLK2_REG01 (Rest Time) = %h                ##", `DUT_IF.wg_rest_wave2_lim[drv_num][15:0]);      
    $display("## ============================================================================ ##");
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write burst starting from SOC_ADDR_WG_DRV_SILENT_CLK2_REG01 (Silent Time) (4 registers)
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_SILENT_CLK2_REG01 + WG_BASE); no_of_bytes == 4; wr_data[0] == `DUT_IF.wg_silent_wave2_lim[drv_num][31:24]; wr_data[1] == `DUT_IF.wg_silent_wave2_lim[drv_num][23:16]; wr_data[2] == `DUT_IF.wg_silent_wave2_lim[drv_num][15:8]; wr_data[3] == `DUT_IF.wg_silent_wave2_lim[drv_num][7:0];});
    `nnc_info("SOC_TEST", "Set 0 silent time", NNC_LOW)
    $display("## ============================================================================ ##");
    $display("##    PROGRAM FOR SOC_ADDR_WG_DRV_SILENT_CLK2_REG01 (Silent Time): %h              ##", `DUT_IF.wg_silent_wave2_lim[drv_num][31:0]);      
    $display("## ============================================================================ ##");
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // -------------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_HLF_WAVE_CLK_PNT2_REG01
    // -------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_HLF_WAVE_CLK_PNT2_REG01 + WG_BASE); no_of_bytes == 2; wr_data[0] == `DUT_IF.wg_hlf_wave2_lim[drv_num][15:8]; wr_data[1] == `DUT_IF.wg_hlf_wave2_lim[drv_num][7:0];});
    `nnc_info("SOC_TEST", "Set positive half wave2 period", NNC_LOW)//0x0000_01F4 (500us)
    $display("## ============================================================================ ##");
    $display("##    PROGRAM FOR ADDR_WG_DRV_HLF_WAVE_CLK_PNT2_REG01 (3rdWave Pos Clk)         ##");      
    $display("## ============================================================================ ##");
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // -----------------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT2_REG01
    // -----------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT2_REG01 + WG_BASE); no_of_bytes == 2; wr_data[0] == `DUT_IF.wg_neg_hlf_wave2_lim[drv_num][15:8]; wr_data[1] == `DUT_IF.wg_neg_hlf_wave2_lim[drv_num][7:0];});
    `nnc_info("SOC_TEST", "Set negative half wave2 period", NNC_LOW)//0x0000_01F4 (500us)
    $display("## ============================================================================ ##");
    $display("##    PROGRAM FOR ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT2_REG01 (3rdWave Neg clk)     ##");      
    $display("## ============================================================================ ##");
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write to ADDR_WG_DRV_CONFIG_REG0(//bit 0:rest enable, 1:negative enable, 2: silent enable, 3: source B enable, 4: alternate, 5: continue mode, 6: multi-electrode, 7: positive disable)
    // --------------------------------------------------------
    if ((`DUT_IF.wg_dc_en == 1) && (`DUT_IF.wavegen_drv_mode[drv_num] == 1'b1)) // SINK
      assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CONFIG_REG0 + WG_BASE); wr_data[0] == {top_test_cfg.POS_OFF, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, top_test_cfg.NEG_ON, 1'b0};});
    else if ((`DUT_IF.wg_dc_en == 1) && (!`DUT_IF.wavegen_drv_mode[drv_num] == 1'b1)) // SOURCE
      assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CONFIG_REG0 + WG_BASE); wr_data[0] == {top_test_cfg.POS_OFF, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, top_test_cfg.NEG_ON, 1'b0};});
    else begin
      if (`DUT_IF.wg_interrupt_en == 1'b1) // set Continue Wave for Source DRV
        assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CONFIG_REG0 + WG_BASE); wr_data[0] == {top_test_cfg.POS_OFF, `DUT_IF.wavegen_drv_mode[drv_num], !`DUT_IF.wavegen_drv_mode[drv_num], 1'b0, 1'b0, 1'b1, top_test_cfg.NEG_ON, 1'b1};}); 
      else
        assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CONFIG_REG0 + WG_BASE); wr_data[0] == {top_test_cfg.POS_OFF, `DUT_IF.wavegen_drv_mode[drv_num], 1'b0, 1'b0, 1'b0, 1'b1, top_test_cfg.NEG_ON, 1'b1};});
    end
    `nnc_info("SOC_TEST", "Set driver configuration register", NNC_LOW)
    $display("## ============================================================================ ##");
    $display("##     PROGRAM FOR ADDR_WG_DRV_CONFIG_REG0 (Config for Driver)                  ##"); 
    $display("## ---------------------------------------------------------------------------- ##");  
    $display("##       bit 0: rest enable                                                     ##");
    $display("##       bit 1: negative enable                                                 ##");
    $display("##       bit 2: silent enable                                                   ##");
    $display("##       bit 3: source B enable                                                 ##");
    $display("##       bit 4: alternate                                                       ##");
    $display("##       bit 5: continue mode                                                   ##");
    $display("##       bit 6: multi-electrode 0: SOURCE. 1: SINK                              ##");
    $display("##       bit 7: positive disable                                                ##");
    $display("## ============================================================================ ##");
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    
    `nnc_info("SOC_TEST", $sformatf("Configure %d points", top_test_cfg.NO_OF_POINTS), NNC_LOW)
    // --------------------------------------------------------
    // Write to ADDR_WG_DRV_POINT_CONFIG
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_POINT_CONFIG + WG_BASE); wr_data[0] == top_test_cfg.NO_OF_POINTS;});
    $display("## ============================================================================ ##");
    $display("##      PROGRAM FOR ADDR_WG_DRV_POINT_CONFIG (No of Point per Phase)            ##");      
    $display("## ============================================================================ ##");
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // Save all points to internal Mem of Wavegen Controller 
    `nnc_info("SOC_TEST", $sformatf("Store %d wave points", top_test_cfg.NO_OF_LOAD_POINTS), NNC_LOW)
    
    if (`DUT_IF.wg_preload_sel == 2'b11) begin
      // Set burst mode for Wavegen Shape register (set bit-4 to 1)
      $display("## ============================================================================ ##");
      $display("##         Read FOR GLOBAL WAVEGEN register                                     ##");   
      $display("## ============================================================================ ##");
      assert(top_test_cfg.randomize() with {reg_addr == `SOC_WAVEGEN_GLOBAL_REG;}); 
      `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data[0]);
      top_test_cfg.wr_data[0] = top_test_cfg.rd_data[0] | 8'h10;
      $display("## ============================================================================ ##");
      $display("##         PROGRAM FOR GLOBAL to set BURST bit (bit-4) for Shape Buffer         ##");   
      $display("## ============================================================================ ##");
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

      // Save data of Mem to Register
      top_test_cfg.reg_addr = (`SOC_ADDR_WG_DRV_IN_WAVE_REG01 + WG_BASE);
      top_test_cfg.no_of_bytes = top_test_cfg.NO_OF_LOAD_POINTS;
      for(int i=0; i<top_test_cfg.NO_OF_LOAD_POINTS; i++) begin
        top_test_cfg.wr_data[i] = top_test_cfg.sine_data[drv_num][i][7:0];
      end
      $display("## ============================================================================ ##");
      $display("##      PROGRAM FOR AWG_IN_WAVE_REG (Indirect register to Shape Buffer)         ##");      
      $display("## ============================================================================ ##");
      `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

      // Clear burst mode for Wavegen Shape register (set bit-4 to 1)
      $display("## ============================================================================ ##");
      $display("##         PROGRAM FOR GLOBAL to clear BURST bit (bit-4) for Shape Buffer         ##");   
      $display("## ============================================================================ ##");
      assert(top_test_cfg.randomize() with {reg_addr == `SOC_WAVEGEN_GLOBAL_REG;}); 
      `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data[0]);
      top_test_cfg.wr_data[0] = top_test_cfg.rd_data[0] & 8'hEF;
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    end

    // *******************************************************************************
    // Write to ADDR_WG_DRV_NEG_SCALE_REG0 (By default it is 1) - AWG_NEG_SCALE_REG: 0x25
    // -------------------------------------------------------------------------------
    // Bit 7: 
    // 0: Scale up the negative side of the waveform by the value of bit[6:0] (multiply by this value)  
    // 1: Scale down the negative side of the waveform by the value of bit[6:0] (shift right by this value) 
    // For scale-up function of section 9.9.6 DRIVE_REG_CTRL2 is 1
    // --------------------------------------------------------
    $display("## ============================================================================ ##");
    $display("##      PROGRAM FOR AWG_NEG_SCALE_REG                                           ##");  
    $display("## ---------------------------------------------------------------------------- ##");
    $display("## Bit 7:                                                                       ##");  
    $display("## 0: Scale up the negative side of the waveform by the value of bit[6:0] (multiply by this value) ##");  
    $display("## 1: Scale down the negative side of the waveform by the value of bit[6:0] (shift right by this value) ##");
    $display("## For scale-up function of section 9.9.6 DRIVE_REG_CTRL2 is 1                  ##");   
    $display("## ============================================================================ ##");
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
    if (`DUT_IF.wg_discharge_en == 1) begin
    $display("## ============================================================================ ##");
    $display("##     PROGRAM FOR AWG_DEBOUNCE_REG                                             ##");  
    $display("## ---------------------------------------------------------------------------- ##");
    $display("## Bit[5:0]: the number of clocks during which PULLB & PULLA is 1               ##");
    $display("## Bit[6]: enable PULLB & PULLA can be 1 at the same time before next neg side  ##");
    $display("## Bit[7]: enable PULLB & PULLA can be 1 at the same time before next pos side  ##");
    $display("## ============================================================================ ##");
    
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_PULLBA_REG + WG_BASE); wr_data[0] == {1'b1, 1'b0, `DUT_IF.wg_discharge_num[drv_num]};});
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    end

    // *******************************************************************************
    // Write to ADDR_WG_DRV_DELAY_LIM_REG01 - AWG_DELAY_LIM_REG: 0x23~0x24 (No need for this
    // -------------------------------------------------------------------------------
    // Number of clocks for initial delay after the reset is disabled and before the waves are generated
    // assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_DELAY_LIM_REG01 + WG_BASE);});
    // `nnc_info("SOC_TEST", "Adjust delay using Delay_lim register", NNC_LOW)
    // `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // *******************************************************************************
    // Write to ADDR_WG_DRV_CTRL_REG0 - AWG_CTRL_REG0: 0x01
    // -------------------------------------------------------------------------------
    // bit[7]: resolution_ctrl - top_test_cfg.POS_NEG_DIFF
    // bit[6]: sym_or_asymmetrical_wave_en - top_test_cfg.LOAD_POINTS
    // bit[5:3]: waveform_num_sel - top_test_cfg.NO_OF_WAVEFORMS
    // bit[2:1]:  waveform_sel - top_test_cfg.PRELOAD
    // Bit[0]: Wavegen_En - 1'b1
    $display("## ============================================================================ ##");
    $display("##         PROGRAM FOR AWG_CTRL_REG0                                            ##");   
    $display("## ---------------------------------------------------------------------------- ##");
    $display("## bit[7]: resolution_ctrl - top_test_cfg.POS_NEG_DIFF                          ##");
    $display("## bit[6]: sym_or_asymmetrical_wave_en - top_test_cfg.LOAD_POINTS               ##");
    $display("## bit[5:3]: waveform_sel - 001 (2 waves), 010(3 waves), 000 (1 wave)           ##");
    $display("## bit[2:1]: preload_sel - 00: Preload SINE, 01: Pulse , 10: Triangle , 11: SPI ##");
    $display("## Bit[0]: Wavegen_En                                                           ##");
    $display("## ============================================================================ ##");
    if (`DUT_IF.wg_dc_en == 1) // Set SNK to not enable
      assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CTRL_REG0 + WG_BASE); wr_data[0] == {top_test_cfg.POS_NEG_DIFF, top_test_cfg.LOAD_POINTS, top_test_cfg.NO_OF_WAVEFORMS, top_test_cfg.PRELOAD, !`DUT_IF.wavegen_drv_mode[drv_num]};});
    else
      assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CTRL_REG0 + WG_BASE); wr_data[0] == {top_test_cfg.POS_NEG_DIFF, top_test_cfg.LOAD_POINTS, top_test_cfg.NO_OF_WAVEFORMS, top_test_cfg.PRELOAD, `DUT_IF.wavegen_drv_en[drv_num]};});
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

    // --------------------------------------------------------
    // Write to SOC_WAVEGEN_GLOBAL_REG to sync drivers
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_WAVEGEN_GLOBAL_REG; wr_data[0] == 8'h01;});
    `nnc_info("SOC_TEST", "Enable drivers using global register", NNC_LOW)
    $display("## ============================================================================ ##");
    $display("##         PROGRAM FOR GLOBAL ENABLE                                            ##");   
    $display("## ============================================================================ ##");
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

/*
----------------------------------------------------------------------------------------------
Item: This test is used to evaluate the electrode discharge function.	
----------------------------------------------------------------------------------------------
"driver: 
drive0 :d0
drive1 :d1"
----------------------------------------------------------------------------------------------	
"steps:
==============
1. First, we need to clear the SPI address ranges for d0 and d1.
   d0 : 0x00~0x3F; d1:0x40~0x7f
2. Configure the connection relationship, that is, how these two   drives are physically connected.
   d0 : wavegen register 0x3e&0x3f,set the value of 0x3e to 0x02, it
        means when d0 is working, it will be connected to the 
        switch(PULLDOWN end) of d1
   d1 : wavegen register 0x7e&0x7f,set the value of 0x7e to 0x01, it
        means when d1 is working, it will be connected to the 
        switch(PULLDOWN end) of d0
3. Configure waveform properties(0x02 for d0;0x42 for d1)
   d0 : enable pos edge; marked d0 as sink; enable rest,enable silent
   d1 : enable pos edge; marked d1 as source; enable rest,enable silent
4. Configure waveform period(0x05~0x0d for d0;0x45 ~0x4d for d1)
   d0 : POS time :P0; REST time R0;SILENT time : S0(S0=P1+R1)
   d1 : POS time :P1; REST time R1;SILENT time : S1(S1=P0+R0)
5. Configure the shape register and write waveform data
   d0 : address   : 0x00~0x01
   d1 : address   : 0x40~0x41
6. Configure the points register
   d0 :0x04(The register supports variable points, and the points should correspond to the data stored in the shape register.)
   d1 :0x44(The register supports variable points, and the points should correspond to the data stored in the shape register.)

7. Configure the control register(0x03/0x43) to enable the waveform(It is recommended to enable wavegen only after completing registers.)
   d0 : set the value 0x07
   d1 : set the value 0x07
   d0&d1 : enable global_en(bit[0] of normal register 0x03])"	"Check Points

Notes:
==============
1.For the shape register, this test only checks the triangle wave; the verification should validate arbitrary waveforms (such as DC and sine waves).
2. POINTS register is variable,should check the full range(1 point ~ 64 points)
3. For the period register, when the register is set to a period of 0, it indicates that the corresponding edge is disabled.
4. must enable POS and SILENT, REST is optional, not use neg edge
5.Switching behavior for source/pulldown
6.analog interface signal behavior"

----------------------------------------------------------------------------------------------
Item: Generate 12-bit square wave data in automatic mode (applicable only to square waves)
----------------------------------------------------------------------------------------------
"driver: 
drive0 :d0
drive1 :d1"
----------------------------------------------------------------------------------------------
"steps:
==============
1. First, we need to clear the SPI address ranges for d0 and d1.
   d0 : 0x00~0x3F; d1:0x40~0x7f
2. Configure the connection relationship, that is, how these two   drives are physically connected.
   d0 : wavegen register 0x3e&0x3f,set the value of 0x3e to 0x02, it
        means when d0 is working, it will be connected to the 
        switch(PULLDOWN end) of d1
   d1 : wavegen register 0x7e&0x7f,set the value of 0x7e to 0x01, it
        means when d1 is working, it will be connected to the 
        switch(PULLDOWN end) of d0
3. Configure waveform properties(0x02 for d0;0x42 for d1)
   d0 : enable pos edge; marked d0 as sink; enable rest,enable silent
   d1 : enable pos edge; marked d1 as source; enable rest,enable silent
4. Configure waveform period(0x05~0x0d for d0;0x45 ~0x4d for d1)
   d0 : POS time :P0; REST time R0;SILENT time : S0(S0=P1+R1)
   d1 : POS time :P1; REST time R1;SILENT time : S1(S1=P0+R0)
5. Configure the manual-pulse data register and write waveform data
   d0 : 0x36 bit[7:0] : data(LSB)
        0x37 bit[3:0] : data(MSB) 
        0x35 bit[5]   : select 8-bit data(0x00~0x01)/12-bit data(0x36~0x37)
   d1 : 0x76 bit[7:0] : data(LSB)
        0x77 bit[3:0] : data(MSB) 
        0x75 bit[5]   : select 8-bit data(0x40~0x1)/12-bit data(0x77~0x77)
6. Configure the points register
   d0 :0x04(The register supports variable points, and the points should correspond to the data stored in the shape register.)
   d1 :0x44(The register supports variable points, and the points should correspond to the data stored in the shape register.)

7. Configure the control register(0x03/0x43) to enable the waveform(It is recommended to enable wavegen only after completing registers.)
   d0 : set the value 0x07
   d1 : set the value 0x07
   d0&d1 : enable global_en(bit[0] of normal register 0x03])"

Notes;
"Check Points
==============
1.12 bits data in auto mode"

----------------------------------------------------------------------------------------------
Item: This test uses pre-stored data inside the chip.	
----------------------------------------------------------------------------------------------
"driver: 
drive0 :d0
drive1 :d1"	
----------------------------------------------------------------------------------------------
"steps:
==============
1. First, we need to clear the SPI address ranges for d0 and d1.
   d0 : 0x00~0x3F; d1:0x40~0x7f
2. Configure the connection relationship, that is, how these two   drives are physically connected.
   d0 : wavegen register 0x3e&0x3f,set the value of 0x3e to 0x02, it
        means when d0 is working, it will be connected to the 
        switch(PULLDOWN end) of d1
   d1 : wavegen register 0x7e&0x7f,set the value of 0x7e to 0x01, it
        means when d1 is working, it will be connected to the 
        switch(PULLDOWN end) of d0
3. Configure waveform properties(0x02 for d0;0x42 for d1)
   d0 : enable pos edge; marked d0 as sink; enable rest,enable silent
   d1 : enable pos edge; marked d1 as source; enable rest,enable silent
4. Configure waveform period(0x05~0x0d for d0;0x45 ~0x4d for d1)   
   d0 : WAVE0 : POS time :P00; REST time R00;SILENT time : S00(S00=P10+R10)
         WAVE1 : POS time :P01; REST time R01;SILENT time : S01(S00=P11+R11)
         WAVE2 : POS time :P02; REST time R02;SILENT time : S02(S00=P12+R12)
   d1 : WAVE0 : POS time :P10; REST time R10;SILENT time : S10(S10=P00+R00)
         WAVE1 : POS time :P11; REST time R11;SILENT time : S11(S11=P01+R01)
         WAVE2 : POS time :P12; REST time R12;SILENT time : S12(S12=P0+R012)
5. Configure the shape register and write waveform data
   d0 : address   : 0x00~0x01
   d1 : address   : 0x40~0x41
6. Configure the points register
   d0 :0x04(The register supports variable points, and the points should correspond to the data stored in the shape register.)
   d1 :0x44(The register supports variable points, and the points should correspond to the data stored in the shape register.)

7. Configure the control register(0x03/0x43) to enable the waveform(It is recommended to enable wavegen only after completing registers.)
   d0 : set the value Vd
   d1 : set the value Vd
   d0&d1 : enable global_en(bit[0] of normal register 0x03])"	

Notes and Check Points
======================
1.Three built-in waveforms : sine;pulse;triangle
2.Form different waveform combinations when used together with multi-waveform functions"

----------------------------------------------------------------------------------------------
Item: The waveform is directly controlled by the SPI register.	
----------------------------------------------------------------------------------------------
"driver: 
drive0 :d0
drive1 :d1"	
----------------------------------------------------------------------------------------------
"steps:
==============
1. First, we need to clear the SPI address ranges for d0 and d1.
   d0 : 0x00~0x3F; d1:0x40~0x7f
2. configure manual  register
   d0 : wavegen register :
        0x35 bit[4] : set it 1 to enable ,manual mode
        0x35 bit[0]/bit[2] : source and pulldown switchs        
        0x36 bit[7:0] : data(LSB)
        0x37 bit[3:0] : data(MSB) 
        0x38 bit[1]   :d2a_cbuf_en

   d1 : wavegen register :
        0x75 bit[4] : set it 1 to enable ,manual mode
        0x75 bit[0]/bit[2] : source and pulldown switchs        
        0x76 bit[7:0] : data(LSB)
        0x77 bit[3:0] : data(MSB) 
        0x78 bit[1]   :d2a_cbuf_en
    d0&d1
        normal register
        0x03 bit[0] : DRIVER_EN
        0x03 bit[3] : D2A_STIMU_EN"	

Check Points
==============
1.Directly control waveform generation using SPI registers
2.check analog interface"

----------------------------------------------------------------------------------------------
Item: After enabling the waveform, use delay_lim to delay the start time of the waveform.	
----------------------------------------------------------------------------------------------
"driver: 
drive0 :d0
drive1 :d1"	
----------------------------------------------------------------------------------------------
"steps:
==============
1. First, we need to clear the SPI address ranges for d0 and d1.
   d0 : 0x00~0x3F; d1:0x40~0x7f
2. Configure the connection relationship, that is, how these two   drives are physically connected.
   d0 : wavegen register 0x3e&0x3f,set the value of 0x3e to 0x02, it
        means when d0 is working, it will be connected to the 
        switch(PULLDOWN end) of d1
   d1 : wavegen register 0x7e&0x7f,set the value of 0x7e to 0x01, it
        means when d1 is working, it will be connected to the 
        switch(PULLDOWN end) of d0
3. Configure waveform properties(0x02 for d0;0x42 for d1)
   d0 : enable pos edge; marked d0 as sink; enable rest,enable silent
   d1 : enable pos edge; marked d1 as source; enable rest,enable silent
4. Configure waveform period(0x05~0x0d for d0;0x45 ~0x4d for d1)
   d0 : POS time :P0; REST time R0;SILENT time : S0(S0=P1+R1)
   d1 : POS time :P1; REST time R1;SILENT time : S1(S1=P0+R0)
5. Configure the shape register and write waveform data
   d0 : address   : 0x00~0x01
   d1 : address   : 0x40~0x41
6. Configure the points register
   d0 :0x04(The register supports variable points, and the points should correspond to the data stored in the shape register.)
   d1 :0x44(The register supports variable points, and the points should correspond to the data stored in the shape register.)
7. Configure delay_lim register
   d0 : 0x24~0x25
   d1 :0x64~0x65

8. Configure the control register(0x03/0x43) to enable the waveform(It is recommended to enable wavegen only after completing registers.)
   d0 : set the value 0x07
   d1 : set the value 0x07
   d0&d1 : enable global_en(bit[0] of normal register 0x03])"	

"Check Points
==============
1.Waveform delay time"

----------------------------------------------------------------------------------------------
Item: This test is used to evaluate the electrode discharge function.	
----------------------------------------------------------------------------------------------
"driver: 
drive0 :d0
drive1 :d1"	
----------------------------------------------------------------------------------------------
"steps:
==============
1. First, we need to clear the SPI address ranges for d0 and d1.
   d0 : 0x00~0x3F; d1:0x40~0x7f
2. Configure the connection relationship, that is, how these two   drives are physically connected.
   d0 : wavegen register 0x3e&0x3f,set the value of 0x3e to 0x02, it
        means when d0 is working, it will be connected to the 
        switch(PULLDOWN end) of d1
   d1 : wavegen register 0x7e&0x7f,set the value of 0x7e to 0x01, it
        means when d1 is working, it will be connected to the 
        switch(PULLDOWN end) of d0
3. Configure waveform properties(0x02 for d0;0x42 for d1)
   d0 : enable pos edge; marked d0 as sink; enable rest,enable silent
   d1 : enable pos edge; marked d1 as source; enable rest,enable silent
4. Configure waveform period(0x05~0x0d for d0;0x45 ~0x4d for d1)
   d0 : POS time :P0; REST time R0;SILENT time : S0(S0=P1+R1)
   d1 : POS time :P1; REST time R1;SILENT time : S1(S1=P0+R0)
5. Configure the shape register and write waveform data
   d0 : address   : 0x00~0x01
   d1 : address   : 0x40~0x41
6. Configure the points register
   d0 :0x04(The register supports variable points, and the points should correspond to the data stored in the shape register.)
   d1 :0x44(The register supports variable points, and the points should correspond to the data stored in the shape register.)
7. Configure PULLBA reg :
   d0: 0x1A : discharge at pos edge
   d1: 0x6A : discharge at pos edge
8. Configure the control register(0x03/0x43) to enable the waveform(It is recommended to enable wavegen only after completing registers.)
   d0 : set the value 0x07
   d1 : set the value 0x07
   d0&d1 : enable global_en(bit[0] of normal register 0x03])"	

"Check Points
==============
1.when discharge,All electrode PULLDOWN terminals are closed to ground.
2.  when discharge,All electrode SOURCE terminals are opened"

----------------------------------------------------------------------------------------------
Item: This test modifies the wavegen function using interrupt functionality.
----------------------------------------------------------------------------------------------
"driver: 
drive0 :d0
drive1 :d1"
==============
"steps:
==============
1. First, we need to clear the SPI address ranges for d0 and d1.
---------------------------------------------------------------------------------------------------
   d0 : 0x00~0x3F; d1:0x40~0x7f
2. Configure the connection relationship, that is, how these two   drives are physically connected.
   d0 : wavegen register 0x3e&0x3f,set the value of 0x3e to 0x02, it
        means when d0 is working, it will be connected to the 
        switch(PULLDOWN end) of d1
   d1 : wavegen register 0x7e&0x7f,set the value of 0x7e to 0x01, it
        means when d1 is working, it will be connected to the 
        switch(PULLDOWN end) of d0
3. Configure waveform properties(0x02 for d0;0x42 for d1)
   d0 : enable pos edge; marked d0 as sink; enable rest,enable silent;CONTIMUE_WAVEFORM : 0
   d1 : enable pos edge; marked d1 as source; enable rest,enable silent;CONTIMUE_WAVEFORM : 1
4. Configure waveform period(0x05~0x0d for d0;0x45~0x4d for d1)
   d0 : POS time :P0; REST time R0;SILENT time : S0(S0=P1+R1)
   d1 : POS time :P1; REST time R1;SILENT time : S1(S1=P0+R0)
5. Configure the shape register and write waveform data
   d0 : address   : 0x00~0x01
   d1 : address   : 0x40~0x41
6. Configure the points register
   d0 :0x04(The register supports variable points, and the points should correspond to the data stored in the shape register.)
   d1 :0x44(The register supports variable points, and the points should correspond to the data stored in the shape register.)
7. Configure INT register
   d0 : 0x2B : Set the number of waveform cycles to ignore;0x2C:enable INT function;0x2d:1st int address;0x2e:2nd int address;
   d1 : 0x6B : Set the number of waveform cycles to ignore;0x6C:enable INT function;0x6d:1st int address;0x6e:2nd int address;

8. Configure the control register(0x03/0x43) to enable the waveform(It is recommended to enable wavegen only after completing registers.)
   d0 : set the value 0x07
   d1 : set the value 0x07
   d0&d1 : enable global_en(bit[0] of normal register 0x03])

9.Once the first address interrupt is triggered, the user can operate on the wavegen register (e.g., modify waveform data). The interrupt from the first address must be cleared immediately after modification; otherwise, the second address interrupt will be generated. The occurrence of the second address interrupt indicates that the user's operation was not completed within the time between the two addresses."

"Check Points
==============
1.the first interrupt can be generated if the preset number of waveforms is reached
2. the second interrupt can be generated if The first interrupt was not cleared in time.
3. After the second interrupt is generated, a register can control whether subsequent waveforms continue to be generated.
4. After clearing the first address, the interrupt address can be automatically swapped to reduce SPI operations.
5.support R1C/R1C
6.support level INT and pulse INT"

----------------------------------------------------------------------------------------------
Item: Test the normal arbitrary waveform generation function	
----------------------------------------------------------------------------------------------
"driver: 
drive0 :d0
drive1 :d1"	
----------------------------------------------------------------------------------------------
"steps:
==============
1. First, we need to clear the SPI address ranges for d0 and d1.
   d0 : 0x00~0x3F; d1:0x40~0x7f
2. Configure the connection relationship, that is, how these two   drives are physically connected.
   d0 : wavegen register 0x3e&0x3f,set the value of 0x3e to 0x02, it
        means when d0 is working, it will be connected to the 
        switch(PULLDOWN end) of d1
   d1 : wavegen register 0x7e&0x7f,set the value of 0x7e to 0x01, it
        means when d1 is working, it will be connected to the 
        switch(PULLDOWN end) of d0
3. Configure waveform properties(0x02 for d0;0x42 for d1)
   d0 : enable pos edge; marked d0 as sink; enable rest,enable silent
   d1 : enable pos edge; marked d1 as source; enable rest,enable silent
4. Configure waveform period(0x05~0x0d for d0;0x45 ~0x4d for d1)
   d0 : POS time :P0; REST time R0;SILENT time : S0(S0=P1+R1)
   d1 : POS time :P1; REST time R1;SILENT time : S1(S1=P0+R0)
5. Configure the shape register and write waveform data
   d0 : address   : 0x00~0x01
   d1 : address   : 0x40~0x41
6. Configure the points register
   d0 :0x04(The register supports variable points, and the points should correspond to the data stored in the shape register.)
   d1 :0x44(The register supports variable points, and the points should correspond to the data stored in the shape register.)

8. Configure the registers that cause data distortion
   d0 : 0x26/0x27/0x28/0x29/
   d1 : 0x66/0x67/0x68/0x69/

9. Configure the address where calibration data takes effect(use the default value 0x00)
   d0 : 0x3b
   d1 : 0x7b

10. Configure the control register(0x03/0x43) to enable the waveform(It is recommended to enable wavegen only after completing registers.)
   d0 : set the value 0x07
   d1 : set the value 0x07
   d0&d1 : enable global_en(bit[0] of normal register 0x03])"	

"Check Points
==============
1.Two multiplicative structures(A*B/A>>B), one divisive structure(A>>B), and one additive structure(A+B)
2.overflow handing
3.Scale/offset effectiveness check"

----------------------------------------------------------------------------------------------
"Item: This test is used to write shape register data using burst mode, eliminating the need to repeat ""address-data"" pairs.
Moreover, if the wavegen data is identical, it supports writing simultaneously to multiple shape registers."	
----------------------------------------------------------------------------------------------
"driver: 
drive0 :d0
drive1 :d1"	
----------------------------------------------------------------------------------------------
"steps:
1. First, we need to clear the SPI address ranges for d0 and d1.
   d0 : 0x00~0x3F; d1:0x40~0x7f

2. Configure the shape register and write waveform data
   d0 : address   : 0x00~0x01
   d1 : address   : 0x40~0x41

3. Enable burst_en by normal register 0x03 bit[4], 
   to write data to the shape registers of multiple wavegens simultaneously, enable the corresponding switches by normal register 0x07/0x08

4.  Use SPI burst command to write shape data(64 points)
"	

"Check Points
==============
1.burst function
2.Write to the shape registers of multiple channels simultaneously
3.If multiple drivers have identical configurations, you can use the multi-wavegen acccess feature to configure these drivers simultaneously."
	
----------------------------------------------------------------------------------------------
Item: This test is used to correct distortion caused by data asynchronization when the register data is modified via SPI.	
----------------------------------------------------------------------------------------------
"driver: 
drive0 :d0
drive1 :d1"	
----------------------------------------------------------------------------------------------
"steps:
==============
1. First, we need to clear the SPI address ranges for d0 and d1.
   d0 : 0x00~0x3F; d1:0x40~0x7f
2. Configure the connection relationship, that is, how these two   drives are physically connected.
   d0 : wavegen register 0x3e&0x3f,set the value of 0x3e to 0x02, it
        means when d0 is working, it will be connected to the 
        switch(PULLDOWN end) of d1
   d1 : wavegen register 0x7e&0x7f,set the value of 0x7e to 0x01, it
        means when d1 is working, it will be connected to the 
        switch(PULLDOWN end) of d0
3. Configure waveform properties(0x02 for d0;0x42 for d1)
   d0 : enable pos edge; marked d0 as sink; enable rest,enable silent
   d1 : enable pos edge; marked d1 as source; enable rest,enable silent
4. Configure waveform period(0x05~0x0d for d0;0x45 ~0x4d for d1)
   d0 : POS time :P0; REST time R0;SILENT time : S0(S0=P1+R1)
   d1 : POS time :P1; REST time R1;SILENT time : S1(S1=P0+R0)
5. Configure the shape register and write waveform data
   d0 : address   : 0x00~0x01
   d1 : address   : 0x40~0x41
6. Configure the points register
   d0 :0x04(The register supports variable points, and the points should correspond to the data stored in the shape register.)
   d1 :0x44(The register supports variable points, and the points should correspond to the data stored in the shape register.)
8. Configure the registers that cause data distortion
   d0 : 0x26/0x27/0x28/0x29/0x37 bit[6:4]/0x3c bit[3:0]
   d1 : 0x66/0x67/0x68/0x69/0x77 bit[6:4]/0x7c bit[3:0]

9. Configure the address where calibration data takes effect
   d0 : 0x3b
   d1 : 0x7b

10. Configure the control register(0x03/0x43) to enable the waveform(It is recommended to enable wavegen only after completing registers.)
   d0 : set the value 0x07
   d1 : set the value 0x07
   d0&d1 : enable global_en(bit[0] of normal register 0x03])"	

"Check Points
==============
1.Address activation is configurable, with a default setting of 0x00, meaning it takes effect at the beginning of the next cycle by default.
2. Calibration data takes effect immediately upon reaching the target address."
	
----------------------------------------------------------------------------------------------	
Item: This test is used to generate EMS waveforms without using interrupts.	
----------------------------------------------------------------------------------------------
"driver: 
drive0 :d0
drive1 :d1"	
----------------------------------------------------------------------------------------------
"steps:
==============
1. First, we need to clear the SPI address ranges for d0 and d1.
   d0 : 0x00~0x3F; d1:0x40~0x7f

2. Configure the connection relationship, that is, how these two   drives are physically connected.
   d0 : wavegen register 0x3e&0x3f,set the value of 0x3e to 0x02, it
        means when d0 is working, it will be connected to the 
        switch(PULLDOWN end) of d1
   d1 : wavegen register 0x7e&0x7f,set the value of 0x7e to 0x01, it
        means when d1 is working, it will be connected to the 
        switch(PULLDOWN end) of d0

3. Configure waveform properties(0x02 for d0;0x42 for d1)
   d0 : enable pos edge; marked d0 as sink; enable alt fucntion,disable rest/silent
   d1 : enable pos edge; marked d1 as source; enable alt fucntion,disable rest/silent

4. Configure waveform period(0x05~0x0d for d0;0x45 ~0x4d for d1)
   d0 : POS time :P0; REST time R0;SILENT time : S0(S0=ALT_P1/2+ALT_P1)
   d1 : POS time :P1; REST time R1;SILENT time : S1(S0=ALT_P0/2+ALT_P0)

5. Configure the shape register and write waveform data
   d0 : address   : 0x00~0x01
   d1 : address   : 0x40~0x41

6. Configure the points register(Carrier points and envelope points are 64-point)
   d0 :0x04(The register supports variable points, and the points should correspond to the data stored in the shape register.)
   d1 :0x44(The register supports variable points, and the points should correspond to the data stored in the shape register.)

7. Configure ALT register(0x2f~0x34 for d0; 0x6f~0x74 for d0)
   d0 : 0x2f~0x30 : ALT_PO=P0*2; 0x31~032: ALT_S0;0x33~0x34:ALT_R0
   d1 : 0x26~0x70 : ALT_P1=P1*2; 0x71~072: ALT_S1;0x3~0x347:ALT_R1

8. Configure EMS register(0x3c~0x3d for d0; 0x7c~0x7d for d1)
   d0 : enable EMS mode(0x3c bit[3]); set DECIMAL_SEL(0x3c bit[2:0]); set Number of repetitions for each envelope point(0x3d)
   d0 : enable EMS mode(0x7c bit[3]); set DECIMAL_SEL(0x7c bit[2:0]); set Number of repetitions for each envelope point(0x7d)

9. Configure the control register(0x03/0x43) to enable the waveform(It is recommended to enable wavegen only after completing registers.)
   d0 : set the value 0x07
   d1 : set the value 0x07
   d0&d1 : enable global_en(bit[0] of normal register 0x03])"	

"Check Points
==============
1.The ALT cycle must equal the entire cycle to ensure correct timing.
2.use DECIMAL_SEL
3.Number of repetitions for each envelope point"

----------------------------------------------------------------------------------------------	
Item: This test is used to generate EMS waveforms without using interrupts. (ALT Mode)
----------------------------------------------------------------------------------------------
"driver: 
drive0 :d0
drive1 :d1"	
==============
"steps:
==============
1. First, we need to clear the SPI address ranges for d0 and d1.
   d0 : 0x00~0x3F; d1:0x40~0x7f

2. Configure the connection relationship, that is, how these two   drives are physically connected.
   d0 : wavegen register 0x3e&0x3f,set the value of 0x3e to 0x02, it
        means when d0 is working, it will be connected to the 
        switch(PULLDOWN end) of d1
   d1 : wavegen register 0x7e&0x7f,set the value of 0x7e to 0x01, it
        means when d1 is working, it will be connected to the 
        switch(PULLDOWN end) of d0

3. Configure waveform properties(0x02 for d0;0x42 for d1)
   d0 : enable pos edge; marked d0 as sink; enable alt fucntion,enable rest disable silent
   d1 : enable pos edge; marked d1 as source; enable alt fucntion,enable rest disable silent

4. Configure waveform period(0x05~0x0d for d0;0x45 ~0x4d for d1)
   d0 : POS time :P0; REST time R0;SILENT time : S0(S0=ALT_P1/2+ALT_P1)
   d1 : POS time :P1; REST time R1;SILENT time : S1(S0=ALT_P0/2+ALT_P0)

5. Configure the shape register and write waveform data
   d0 : address   : 0x00~0x01
   d1 : address   : 0x40~0x41

6. Configure the points register(Carrier points and envelope points are 64-point)
   d0 :0x04(The register supports variable points, and the points should correspond to the data stored in the shape register.)
   d1 :0x44(The register supports variable points, and the points should correspond to the data stored in the shape register.)

7. Configure ALT register(0x2f~0x34 for d0; 0x6f~0x74 for d0)
   d0 : 0x2f~0x30 : ALT_PO=P0*2; 0x31~032: ALT_S0;0x33~0x34:ALT_R0
   d1 : 0x26~0x70 : ALT_P1=P1*2; 0x71~072: ALT_S1;0x3~0x347:ALT_R1


8. Configure the control register(0x03/0x43) to enable the waveform(It is recommended to enable wavegen only after completing registers.)
   d0 : set the value 0x07
   d1 : set the value 0x07
   d0&d1 : enable global_en(bit[0] of normal register 0x03])"	

"Check Points
==============
1.the timing of alt waveform
2. rest time is optional"

----------------------------------------------------------------------------------------------		
Item: The test involves two waveforms interfering with each other, forming a low-frequency envelope signal at the interference point.	
----------------------------------------------------------------------------------------------	
"driver: (in this case use to generate 5000hz)
drive0 :d0
drive1 :d1"	
----------------------------------------------------------------------------------------------	
"steps:
==============
1. First, we need to clear the SPI address ranges for d0 and d1.
   d0 : 0x00~0x3F; d1:0x40~0x7f
2. Configure the connection relationship, that is, how these two   drives are physically connected.
   d0 : wavegen register 0x3e&0x3f,set the value of 0x3e to 0x02, it
        means when d0 is working, it will be connected to the 
        switch(PULLDOWN end) of d1
   d1 : wavegen register 0x7e&0x7f,set the value of 0x7e to 0x01, it
        means when d1 is working, it will be connected to the 
        switch(PULLDOWN end) of d0
3. Configure waveform properties(0x02 for d0;0x42 for d1)
   d0 : enable pos edge; marked d0 as sink; enable rest,enable silent
   d1 : enable pos edge; marked d1 as source; enable rest,enable silent
4. Configure waveform period(0x05~0x0d for d0;0x45 ~0x4d for d1)
   d0 : POS time :P0; REST time R0;SILENT time : S0(S0=P1+R1)
   d1 : POS time :P1; REST time R1;SILENT time : S1(S1=P0+R0)
5. Configure the shape register and write waveform data
   d0 : address   : 0x00~0x01
   d1 : address   : 0x40~0x41
6. Configure the points register(recommend to use 64 points)
   d0 :0x04(The register supports variable points, and the points should correspond to the data stored in the shape register.)
   d1 :0x44(The register supports variable points, and the points should correspond to the data stored in the shape register.)
7. Configure the register to enable DDS_mode and set dds fractional frequency parameter(same for both deivers)
   d0 : set bit[3] of 0x38 to enable dds mode; config 0x12~0x15 to set dds fractional frequency parameter
   d1 : set bit[3] of 0x78 to enable dds mode; config 0x52~0x55 to set dds fractional frequency parameter
8. Configure the control register(0x03/0x43) to enable the waveform(It is recommended to enable wavegen only after completing registers.)
   d0 : set the value 0x07
   d1 : set the value 0x07
   d0&d1 : enable global_en(bit[0] of normal register 0x03])"	

----------------------------------------------------------------------------------------------
"driver: (in this case use to generate 5010hz)
drive0 :d2
drive1 :d3"
----------------------------------------------------------------------------------------------
"steps:
==============
1. First, we need to clear the SPI address ranges for d0 and d1.
   d2 : 0x80~0xbF; d3:0xc0~0xff
2. Configure the connection relationship, that is, how these two   drives are physically connected.
   d2 : wavegen register 0xbe&0xbf,set the value of 0xbe to 0x02, it
        means when d0 is working, it will be connected to the 
        switch(PULLDOWN end) of d1
   d3 : wavegen register 0xfe&0xff,set the value of 0xfe to 0x01, it
        means when d1 is working, it will be connected to the 
        switch(PULLDOWN end) of d0
3. Configure waveform properties(0x82 for d0;0xc2 for d1)
   d1 : enable pos edge; marked d2 as sink; enable rest,enable silent
   d3 : enable pos edge; marked d3 as source; enable rest,enable silent
4. Configure waveform period(0x85~0x8d for d0;0xc5 ~0xcd for d1)
   d2 : POS time :P2; REST time R2;SILENT time : S2(S0=P3+R3)
   d3 : POS time :P3; REST time R3;SILENT time : S3(S1=P2+R2)
5. Configure the shape register and write waveform data
   d2 : address   : 0x80~0x81
   d3 : address   : 0xc0~0xc1
6. Configure the points register(recommend to use 64 points)
   d2 :0x84(The register supports variable points, and the points should correspond to the data stored in the shape register.)
   d3 :0xc4(The register supports variable points, and the points should correspond to the data stored in the shape register.)
7. Configure the register to enable DDS_mode and set dds fractional frequency parameter(same for both deivers)
   d2 : set bit[3] of 0xb8 to enable dds mode; config 0x92~0x95 to set dds fractional frequency parameter
   d3 : set bit[3] of 0xf8 to enable dds mode; config 0xd2~0xd5 to set dds fractional frequency parameter
8. Configure the control register(0x83/0xc3) to enable the waveform(It is recommended to enable wavegen only after completing registers.)
   d2 : set the value 0x07
   d3 : set the value 0x07"	

----------------------------------------------------------------------------------------------			
"Item: Supports up to three different waveforms (with independent periods and data), allowing testing of the number of repeatable cycles for each waveform individually."	
----------------------------------------------------------------------------------------------	
"driver: 
drive0 :d0
drive1 :d1"	
----------------------------------------------------------------------------------------------	
"steps:
==============
1. First, we need to clear the SPI address ranges for d0 and d1.
   d0 : 0x00~0x3F; d1:0x40~0x7f
2. Configure the connection relationship, that is, how these two   drives are physically connected.
   d0 : wavegen register 0x3e&0x3f,set the value of 0x3e to 0x02, it
        means when d0 is working, it will be connected to the 
        switch(PULLDOWN end) of d1
   d1 : wavegen register 0x7e&0x7f,set the value of 0x7e to 0x01, it
        means when d1 is working, it will be connected to the 
        switch(PULLDOWN end) of d0
3. Configure waveform properties(0x02 for d0;0x42 for d1)
   d0 : enable pos edge; marked d0 as sink; enable rest,enable silent
   d1 : enable pos edge; marked d1 as source; enable rest,enable silent
4. Configure waveform period(0x05~0x23 for d0;0x45 ~0x63 for d1)
   d0 : WAVE0 : POS time :P00; REST time R00;SILENT time : S00(S00=P10+R10)
         WAVE1 : POS time :P01; REST time R01;SILENT time : S01(S00=P11+R11)
         WAVE2 : POS time :P02; REST time R02;SILENT time : S02(S00=P12+R12)
   d1 : WAVE0 : POS time :P10; REST time R10;SILENT time : S10(S10=P00+R00)
         WAVE1 : POS time :P11; REST time R11;SILENT time : S11(S11=P01+R01)
         WAVE2 : POS time :P12; REST time R12;SILENT time : S12(S12=P0+R012)
5. Configure the shape register and write waveform data
   d0 : address   : 0x00~0x01
   d1 : address   : 0x40~0x41
6. Configure the points register
   d0 :0x04(The register supports variable points, and the points should correspond to the data stored in the shape register.)
   d1 :0x44(The register supports variable points, and the points should correspond to the data stored in the shape register.)
7. Configure the silent repeat control register and set the number of repetitions required.(should be same in between drivers)
   d0 : set 0x38 bit[2],enable this function, set 0x39,0x3A for the number of repetitions required for WAVE0;
        set 0x31 for the number ofrepetitions required for WAVE1;set 0x32 for the number of repetitions required for WAVE2
   d1 : set 0x78 bit[2],enable this function, set 0x79,0x7A for the number of repetitions required;
        set 0x71 for the number ofrepetitions required for WAVE1;set 0x72 for the number of repetitions required for WAVE2

8. Configure the control register(0x03/0x43) to enable the waveform(It is recommended to enable wavegen only after completing registers.)
   d0 : set the value 0x57
   d1 : set the value 0x57
   d0&d1 : enable global_en(bit[0] of normal register 0x03])"	

"Check Points
==============
1.For wave0, the register controlling the repetition count is 16 bits, allowing a maximum of 65,535 repetitions.for wave1/wave2, they are 8 bits so allowing a maximum of 255 repetitions. those registers can't be set 0

2. this feature should be used with bit[7:6] of 0x04/0x44

3. support 2 waves

4. if not enable bit[2] of 0x38/0x78This is a standard multi-waveform function, where the waveform does not repeat within a single cycle., "

----------------------------------------------------------------------------------------------		
"Item: This function is used to generate a sequence where, after alternating between positive and negative cycles for a certain number of 
periods, it enters a prolonged silent period."	
----------------------------------------------------------------------------------------------	
"driver: 
drive0 :d0
drive1 :d1"	
----------------------------------------------------------------------------------------------	
"steps:
==============
1. First, we need to clear the SPI address ranges for d0 and d1.
   d0 : 0x00~0x3F; d1:0x40~0x7f
2. Configure the connection relationship, that is, how these two   drives are physically connected.
   d0 : wavegen register 0x3e&0x3f,set the value of 0x3e to 0x02, it
        means when d0 is working, it will be connected to the 
        switch(PULLDOWN end) of d1
   d1 : wavegen register 0x7e&0x7f,set the value of 0x7e to 0x01, it
        means when d1 is working, it will be connected to the 
        switch(PULLDOWN end) of d0
3. Configure waveform properties(0x02 for d0;0x42 for d1)
   d0 : enable pos edge; marked d0 as sink; enable rest,enable silent, enable neg edge
   d1 : enable pos edge; marked d1 as source; enable rest,enable silent, enable eng edge
4. Configure waveform period(0x05~0x0d for d0;0x45 ~0x4d for d1)
   d0 : POS time :P0; REST time R0;SILENT time : S0(S0=P1+R1),NEG time N0
   d1 : POS time :P1; REST time R1;SILENT time : S1(S1=P0+R0),NEG time N1
5. Configure the shape register and write waveform data
   d0 : address   : 0x00~0x01
   d1 : address   : 0x40~0x41
6. Configure the points register
   d0 :0x04(The register supports variable points, and the points should correspond to the data stored in the shape register.)
   d1 :0x44(The register supports variable points, and the points should correspond to the data stored in the shape register.)
7. Configure the silent repeat control register and set the number of repetitions required.(should be same in between drivers)
   d0 : set 0x38 bit[0],enable this function, set 0x39,0x3A for the number of repetitions required
   d1 : set 0x78 bit[0],enable this function, set 0x79,0x7A for the number of repetitions required

8. Configure the control register(0x03/0x43) to enable the waveform(It is recommended to enable wavegen only after completing registers.)
   d0 : set the value 0x07
   d1 : set the value 0x07
   d0&d1 : enable global_en(bit[0] of normal register 0x03])"	

"Check Points
==============
1.After the waveform reaches the number configured in the register, it enters silent time.
2.Enable the NEG edge; the silent time is actually the NEG edge time."	

*/
