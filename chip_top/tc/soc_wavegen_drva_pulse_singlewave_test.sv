/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_wavegen_drva_pulse_singlewave_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_wavegen_drva_pulse_singlewave_test                                             
// Designer	: ophina@nanochap.com                                                                 
// Date		: 18-03-2024                                                                   
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

//***************************************************************************************
// NOTE : The test is intented  to generate pulse wave for driver1 & driver2. But 
//        this test considers specific constraints and additional randomizations
//***************************************************************************************

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_wavegen_drva_pulse_singlewave_test
`define TESTCFG soc_wavegen_drva_pulse_singlewave_test_cfg

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

  logic [13:0]     clk_freq;//in Khz
  logic [12:0]     half_period_limit;
  rand logic [12:0] half_period0;
  rand logic [12:0] half_period1;
  rand logic [12:0] half_period2;
  rand logic [13:0] rest_period[3];
  rand logic [13:0] silent_period[3];
  logic [31:0]     hlf_wave_lim; // number of clocks for positive half wave
  logic [31:0]     neg_hlf_wave_lim; // number of clocks for negative half wave
  logic [15:0]     rest_lim; // number of clocks for each rest period
  logic [31:0]     silent_lim; // number of clocks for each silent period
  rand logic [1:0] preload_sel;
  rand logic       multielectrode_en;
  rand logic       sourceB_en;
  rand logic       neg_ena;
  rand logic       pos_dis;
  rand logic       rest_en;
  rand logic       silent_en;
  rand logic [2:0] points_sel;
  rand logic [2:0] waveform_sel;
  rand logic       load_points_sel;
  rand logic       pos_neg_diff_sel;
  rand logic       dac_bit_len_sel;//1'b0:8-bits; 1'b1:12-bits
  rand logic       auto_man;//1'b0:auto; 1'b1:manual
  rand logic [7:0] dac0_data_l;
  rand logic [3:0] dac0_data_h;
  rand logic [2:0] dac0_msb_sel;
  rand logic [7:0] dac1_data_l;
  rand logic [3:0] dac1_data_h;
  rand logic [2:0] dac1_msb_sel;
  rand logic       PULLAB_pos_en;
  rand logic       PULLAB_neg_en;
  rand logic [5:0] PULLAB_lim;
       logic [1:0] PRELOAD;
       logic       LOAD_POINTS;
       logic [7:0] NO_OF_POINTS;
       logic [7:0] NO_OF_LOAD_POINTS;
       logic [2:0] NO_OF_WAVEFORMS;
       logic       NEG_ON;
       logic       POS_OFF;
       logic       POS_NEG_DIFF;
       logic [7:0] PULLAB_CTRL;
       logic       MULTI_ELEC;
  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_wavegen_drva_pulse_singlewave_test_cfg");
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

  //preload_sel
  constraint c_preload_sel     { preload_sel inside {1,3};}

  //points_sel
  constraint c_points_sel      { ((waveform_sel == 3'b000) && (neg_ena == 1'b1) && (pos_dis == 1'b0) && (pos_neg_diff_sel == 1'b0)) -> points_sel inside {[0:6]};
                                 ((waveform_sel == 3'b000) && (neg_ena == 1'b1) && (pos_dis == 1'b0) && (pos_neg_diff_sel == 1'b1)) -> points_sel inside {[0:7]};
                                 ((waveform_sel == 3'b001) && (neg_ena == 1'b1) && (pos_dis == 1'b0) && (pos_neg_diff_sel == 1'b0)) -> points_sel inside {[1:6]};
                                 ((waveform_sel == 3'b001) && (neg_ena == 1'b1) && (pos_dis == 1'b0) && (pos_neg_diff_sel == 1'b1)) -> points_sel inside {[0:6]};
                                 ((waveform_sel == 3'b010) && (neg_ena == 1'b1) && (pos_dis == 1'b0) && (pos_neg_diff_sel == 1'b0)) -> points_sel inside {[2:6]};
                                 ((waveform_sel == 3'b010) && (neg_ena == 1'b1) && (pos_dis == 1'b0) && (pos_neg_diff_sel == 1'b1)) -> points_sel inside {[1:6]};
                                 ((waveform_sel == 3'b000) && ((neg_ena == 1'b0) || (pos_dis == 1'b1))) -> points_sel inside {[0:7]};
                                 ((waveform_sel == 3'b001) && ((neg_ena == 1'b0) || (pos_dis == 1'b1))) -> points_sel inside {[0:6]};
                                 ((waveform_sel == 3'b010) && ((neg_ena == 1'b0) || (pos_dis == 1'b1))) -> points_sel inside {[1:6]};
                               }

  //waveform_sel
  constraint c_waveform_sel    { waveform_sel inside {[0:0]};}

  //load_points_sel
  constraint c_load_points_sel { load_points_sel == 1'b0;}

  //pos_neg_diff_sel
  constraint c_pos_neg_diff_sel { pos_neg_diff_sel == 1'b0;}

  //auto_man
  constraint c_auto_man        { auto_man == 1'b0;}

  //dac0_data_h
  constraint c_dac0_data_h     { dac0_data_h != 0;}

  //dac1_data_h
  constraint c_dac1_data_h     { dac1_data_h != 0;}

  //dac0_msb_sel
  //constraint c_dac0_msb_sel    { dac0_msb_sel inside {[0:4]};}

  //dac1_msb_sel
  //constraint c_dac1_msb_sel    { dac1_msb_sel inside {[0:4]};}

  //PULLAB_neg_en
  constraint c_PULLAB_neg_en   { (sourceB_en == 1'b0) -> PULLAB_neg_en == 1'b0;}

  //PULLAB_lim
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
    `DUT_IF.assertion_on = 1;

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
  // Declare the main_phase task of your test
  // -----------------------------------------
  virtual task main_phase(nnc_phase phase);
    phase.raise_objection(this);

    super.main_phase(phase);

    `nnc_info("SOC_TEST", "soc_wavegen_drva_pulse_singlewave_test start", NNC_LOW)

    // ==================================================================================
    // Please add your code of your test here
    // ----------------------------------------------------------------------------------
    top_test_cfg.LOAD_POINTS = top_test_cfg.load_points_sel;
    top_test_cfg.NO_OF_WAVEFORMS = top_test_cfg.waveform_sel;
    top_test_cfg.PRELOAD = top_test_cfg.preload_sel;
    top_test_cfg.NEG_ON = top_test_cfg.neg_ena;
    top_test_cfg.POS_OFF = top_test_cfg.pos_dis;
    top_test_cfg.POS_NEG_DIFF = top_test_cfg.pos_neg_diff_sel;
    top_test_cfg.PULLAB_CTRL  = {top_test_cfg.PULLAB_pos_en, top_test_cfg.PULLAB_neg_en, top_test_cfg.PULLAB_lim};
    
    case(top_test_cfg.points_sel)
         3'b000:begin
		    top_test_cfg.NO_OF_POINTS = 64;
		end
         3'b001:begin
		    top_test_cfg.NO_OF_POINTS = 32;
		end
         3'b010:begin
		    top_test_cfg.NO_OF_POINTS = 16;
		end
         3'b011:begin
		    top_test_cfg.NO_OF_POINTS = 8;
		end
         3'b100:begin
		    top_test_cfg.NO_OF_POINTS = 4;
		end
         3'b101:begin
		    top_test_cfg.NO_OF_POINTS = 2;
		end
         3'b110:begin
		    top_test_cfg.NO_OF_POINTS = 1;
		end
         3'b111:begin
		    top_test_cfg.NO_OF_POINTS = 128;
		end
    endcase
    
    if(top_test_cfg.LOAD_POINTS === 0)
	top_test_cfg.NO_OF_LOAD_POINTS = top_test_cfg.NO_OF_POINTS;
    else begin
      if(top_test_cfg.NO_OF_WAVEFORMS === 0)
	top_test_cfg.NO_OF_LOAD_POINTS = 128;
      else begin
      	if(top_test_cfg.POS_NEG_DIFF === 1)
	   top_test_cfg.NO_OF_LOAD_POINTS = top_test_cfg.NO_OF_POINTS * (top_test_cfg.NO_OF_WAVEFORMS+1);
      	else
	   top_test_cfg.NO_OF_LOAD_POINTS = top_test_cfg.NO_OF_POINTS * (top_test_cfg.NO_OF_WAVEFORMS+1) * 2;
      end
    end

    // Interface
    `DUT_IF.no_of_point_a = top_test_cfg.NO_OF_LOAD_POINTS; // expected resolution
    `DUT_IF.no_of_point_b = top_test_cfg.NO_OF_LOAD_POINTS; // expected resolution
    for (int i=0; i < `DUT_IF.no_of_point_a; i++) begin
      `DUT_IF.hex_data_a[i] = 8'hFF; // expected hex values
      `DUT_IF.hex_data_b[i] = 8'hFF; // expected hex values
    end
    `DUT_IF.pos_neg_from_same_addr = top_test_cfg.POS_NEG_DIFF; 
    `DUT_IF.load_wave_data_till_points = top_test_cfg.LOAD_POINTS; 
    `DUT_IF.no_of_waveforms = top_test_cfg.NO_OF_WAVEFORMS; 
    `DUT_IF.preload_sel = top_test_cfg.PRELOAD;
    for (int i=0; i < 2; i++) begin
      `DUT_IF.PULLAB_pos_en[i] = top_test_cfg.PULLAB_CTRL[7];
      `DUT_IF.PULLAB_neg_en[i] = top_test_cfg.PULLAB_CTRL[6];
      `DUT_IF.PULLAB_lim[i] = top_test_cfg.PULLAB_CTRL[5:0];
    end

    `nnc_info("SOC_TEST", $sformatf("NO_OF_POINTS: %d, NO_OF_LOAD_POINTS: %d, LOAD_POINTS:%d", top_test_cfg.NO_OF_POINTS, top_test_cfg.NO_OF_LOAD_POINTS, top_test_cfg.LOAD_POINTS), NNC_LOW)

    top_test_cfg.clk_freq = 8192 / (2**`DUT_IF.pclk_sel);
    top_test_cfg.half_period_limit = (top_test_cfg.NO_OF_POINTS * 1000) / top_test_cfg.clk_freq;

    for(int i = 0; i < `WAVEGEN_NUM_OF_DRIVERS; i++) begin
    assert(top_test_cfg.randomize() with {half_period0 == (top_test_cfg.half_period_limit+1); half_period1 > top_test_cfg.half_period_limit; half_period2 > top_test_cfg.half_period_limit;
                                          silent_period[0] > rest_period[0]; silent_period[1] > rest_period[1]; silent_period[2] > rest_period[2];});
    //wavegen_calc_clock_num(clk_freq (KHz), rest_t (us), silent_t (us), hlf_wave_per (us), neg_hlf_wave_per (us))
    wavegen_calc_clock_num(top_test_cfg.clk_freq, top_test_cfg.rest_period[0], top_test_cfg.silent_period[0], top_test_cfg.half_period0, top_test_cfg.half_period0);
    `DUT_IF.wg_hlf_wave0_lim[i] = top_test_cfg.hlf_wave_lim / top_test_cfg.NO_OF_POINTS;
    `DUT_IF.wg_neg_hlf_wave0_lim[i] = top_test_cfg.neg_hlf_wave_lim / top_test_cfg.NO_OF_POINTS;
    `DUT_IF.wg_rest_wave0_lim[i] = top_test_cfg.rest_lim;
    `DUT_IF.wg_silent_wave0_lim[i] = top_test_cfg.silent_lim;
    `nnc_info("SOC_TEST", $sformatf("******** Driver (%d) WAVE 0 ******** CLK_FREQ: %dKhz, HALF_PERIOD_LIMIT: %dus, HALF_PERIOD_TARGET: %dus, HALF_PERIOD_CLKS_PER_POINT: %d, REST_PERIOD: %dus, SILENT_PERIOD: %dus, REST_PERIOD_CLKS: %d, SILENT_PERIOD_CLKS: %d", i, top_test_cfg.clk_freq, top_test_cfg.half_period_limit, top_test_cfg.half_period0, `DUT_IF.wg_hlf_wave0_lim[i], top_test_cfg.rest_period[0], top_test_cfg.silent_period[0], `DUT_IF.wg_rest_wave0_lim[i], `DUT_IF.wg_silent_wave0_lim[i]), NNC_LOW)

    //wavegen_calc_clock_num(clk_freq (KHz), rest_t (us), silent_t (us), hlf_wave_per (us), neg_hlf_wave_per (us))
    wavegen_calc_clock_num(top_test_cfg.clk_freq, top_test_cfg.rest_period[1], top_test_cfg.silent_period[1], top_test_cfg.half_period1, top_test_cfg.half_period1);
    `DUT_IF.wg_hlf_wave1_lim[i] = top_test_cfg.hlf_wave_lim / top_test_cfg.NO_OF_POINTS;
    `DUT_IF.wg_neg_hlf_wave1_lim[i] = top_test_cfg.neg_hlf_wave_lim / top_test_cfg.NO_OF_POINTS;
    `DUT_IF.wg_rest_wave1_lim[i] = top_test_cfg.rest_lim;
    `DUT_IF.wg_silent_wave1_lim[i] = top_test_cfg.silent_lim;
    `nnc_info("SOC_TEST", $sformatf("******** Driver (%d) WAVE 1 ******** CLK_FREQ: %dKhz, HALF_PERIOD_LIMIT: %dus, HALF_PERIOD_TARGET: %dus, HALF_PERIOD_CLKS_PER_POINT: %d, REST_PERIOD: %dus, SILENT_PERIOD: %dus, REST_PERIOD_CLKS: %d, SILENT_PERIOD_CLKS: %d", i, top_test_cfg.clk_freq, top_test_cfg.half_period_limit, top_test_cfg.half_period1, `DUT_IF.wg_hlf_wave1_lim[i], top_test_cfg.rest_period[1], top_test_cfg.silent_period[1], `DUT_IF.wg_rest_wave1_lim[i], `DUT_IF.wg_silent_wave1_lim[i]), NNC_LOW)

    //wavegen_calc_clock_num(clk_freq (KHz), rest_t (us), silent_t (us), hlf_wave_per (us), neg_hlf_wave_per (us))
    wavegen_calc_clock_num(top_test_cfg.clk_freq, top_test_cfg.rest_period[2], top_test_cfg.silent_period[2], top_test_cfg.half_period2, top_test_cfg.half_period2);
    `DUT_IF.wg_hlf_wave2_lim[i] = top_test_cfg.hlf_wave_lim / top_test_cfg.NO_OF_POINTS;
    `DUT_IF.wg_neg_hlf_wave2_lim[i] = top_test_cfg.neg_hlf_wave_lim / top_test_cfg.NO_OF_POINTS;
    `DUT_IF.wg_rest_wave2_lim[i] = top_test_cfg.rest_lim;
    `DUT_IF.wg_silent_wave2_lim[i] = top_test_cfg.silent_lim;
    `nnc_info("SOC_TEST", $sformatf("******** Driver (%d) WAVE 2 ******** CLK_FREQ: %dKhz, HALF_PERIOD_LIMIT: %dus, HALF_PERIOD_TARGET: %dus, HALF_PERIOD_CLKS_PER_POINT: %d, REST_PERIOD: %dus, SILENT_PERIOD: %dus, REST_PERIOD_CLKS: %d, SILENT_PERIOD_CLKS: %d", i, top_test_cfg.clk_freq, top_test_cfg.half_period_limit, top_test_cfg.half_period2, `DUT_IF.wg_hlf_wave2_lim[i], top_test_cfg.rest_period[2], top_test_cfg.silent_period[2], `DUT_IF.wg_rest_wave2_lim[i], `DUT_IF.wg_silent_wave2_lim[i]), NNC_LOW)
    end

    // --------------------------------------------------------
    // Write to SOC_ANA_ENABLE_REG_1
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_ENABLE_REG_1; wr_data[0] == 8'h08;});//IDAC_EN
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // --------------------------------------------------------
    // Write to SOC_ANA_ENABLE_REG_2
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_ENABLE_REG_2; wr_data[0] == 8'h08;});//IDAC_EN
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // --------------------------------------------------------
    // Write to SOC_ADDR_WG_DRV_CTRL0_REG for drv0
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ADDR_WG_DRV_CTRL0_REG; (top_test_cfg.PRELOAD == 2'b01) -> top_test_cfg.dac_bit_len_sel == 1'b0; wr_data[0] == {2'b0, top_test_cfg.dac_bit_len_sel,top_test_cfg.auto_man, 4'b0};});
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // --------------------------------------------------------
    // Write to SOC_ADDR_WG_DRV_CTRL0_REG for drv1
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CTRL0_REG + `WAVEGEN_1_ADDR_BASE); (top_test_cfg.PRELOAD == 2'b01) -> top_test_cfg.dac_bit_len_sel == 1'b0; wr_data[0] == {2'b0, top_test_cfg.dac_bit_len_sel,top_test_cfg.auto_man, 4'b0};});
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // --------------------------------------------------------
    // Write burst starting from SOC_ADDR_WG_DRV_CTRL1_REG for drv0
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ADDR_WG_DRV_CTRL1_REG; no_of_bytes == 2; wr_data[0] == {1'b0, top_test_cfg.dac0_msb_sel, top_test_cfg.dac0_data_h}; wr_data[1] == top_test_cfg.dac0_data_l;});
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write burst starting from SOC_ADDR_WG_DRV_CTRL1_REG for drv1
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CTRL1_REG + `WAVEGEN_1_ADDR_BASE); no_of_bytes == 2; wr_data[0] == {1'b0, top_test_cfg.dac1_msb_sel, top_test_cfg.dac1_data_h}; wr_data[1] == top_test_cfg.dac1_data_l;});
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    wavegen_drv_config(`WAVEGEN_0_ADDR_BASE);
    wavegen_drv_config(`WAVEGEN_1_ADDR_BASE);

    `nnc_info("SOC_TEST", $sformatf("enabling chip_0 wavegen sb now"), NNC_LOW)
    `WAVEGEN_SCB_DRV_0_EN = 1'b1;
    `WAVEGEN_SCB_DRV_1_EN = 1'b1;

    // --------------------------------------------------------
    // Write to ADDR_WG_DRV_CTRL_REG0
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ADDR_WG_DRV_CTRL_REG0; wr_data[0] == {top_test_cfg.POS_NEG_DIFF,top_test_cfg.LOAD_POINTS,top_test_cfg.NO_OF_WAVEFORMS,top_test_cfg.PRELOAD,1'b1};});
    if(top_test_cfg.PRELOAD === 2'b01)
    	`nnc_info("SOC_TEST", "Enable driver0 using control register with preloaded pulse values", NNC_LOW)
    else if(top_test_cfg.PRELOAD === 2'b11)
    	`nnc_info("SOC_TEST", "Enable driver0 using control register with user config values", NNC_LOW)
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CTRL_REG0 + `WAVEGEN_1_ADDR_BASE); wr_data[0] == {top_test_cfg.POS_NEG_DIFF,top_test_cfg.LOAD_POINTS,top_test_cfg.NO_OF_WAVEFORMS,top_test_cfg.PRELOAD,1'b1};});
    if(top_test_cfg.PRELOAD === 2'b01)
    	`nnc_info("SOC_TEST", "Enable driver1 using control register with preloaded pulse values", NNC_LOW)
    else if(top_test_cfg.PRELOAD === 2'b11)
    	`nnc_info("SOC_TEST", "Enable driver1 using control register with user config values", NNC_LOW)
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    $display("## --------------------------------------------------------------------------- ##");
    $display("##         WAITING FOR SIMULATION TO COMPLETE WAVEFORM GENERATION              ##");      
    $display("## --------------------------------------------------------------------------- ##");
    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    #200ms;
    `nnc_info("SOC_TEST", "soc_wavegen_drva_pulse_singlewave_test end now", NNC_LOW)

    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ==================================================================================

    phase.drop_objection(this);
  endtask: main_phase

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

  task wavegen_drv_config;
  input [7:0] WG_BASE;
  begin
    if(WG_BASE === `WAVEGEN_0_ADDR_BASE)
	`DUT_IF.wg_drv_sel = 0;
    else if(WG_BASE === `WAVEGEN_1_ADDR_BASE)
	`DUT_IF.wg_drv_sel = 1;
    // --------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_REST_T_REG01
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_REST_T_REG01 + WG_BASE); no_of_bytes == 2;  wr_data[0] == `DUT_IF.wg_rest_wave0_lim[`DUT_IF.wg_drv_sel][15:8]; wr_data[1] == `DUT_IF.wg_rest_wave0_lim[`DUT_IF.wg_drv_sel][7:0];});
    `nnc_info("SOC_TEST", "Set wave0 rest period", NNC_LOW)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_SILENT_T_REG01
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_SILENT_T_REG01 + WG_BASE); no_of_bytes == 3; wr_data[0] == `DUT_IF.wg_silent_wave0_lim[`DUT_IF.wg_drv_sel][23:16]; wr_data[1] == `DUT_IF.wg_silent_wave0_lim[`DUT_IF.wg_drv_sel][15:8]; wr_data[2] == `DUT_IF.wg_silent_wave0_lim[`DUT_IF.wg_drv_sel][7:0];});
    `nnc_info("SOC_TEST", "Set wave0 silent period", NNC_LOW)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write to SOC_ADDR_WG_DRV_SILENT_T_REG04
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_SILENT_T_REG04 + WG_BASE); wr_data[0] == `DUT_IF.wg_silent_wave0_lim[`DUT_IF.wg_drv_sel][31:24];});
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // --------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_REST_CLK1_REG01
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_REST_CLK1_REG01 + WG_BASE); no_of_bytes == 2;  wr_data[0] == `DUT_IF.wg_rest_wave1_lim[`DUT_IF.wg_drv_sel][15:8]; wr_data[1] == `DUT_IF.wg_rest_wave1_lim[`DUT_IF.wg_drv_sel][7:0];});
    `nnc_info("SOC_TEST", "Set wave1 rest period", NNC_LOW)//0x0000_0064 (100us)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_SILENT_CLK1_REG01
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_SILENT_CLK1_REG01 + WG_BASE); no_of_bytes == 3; wr_data[0] == `DUT_IF.wg_silent_wave1_lim[`DUT_IF.wg_drv_sel][23:16]; wr_data[1] == `DUT_IF.wg_silent_wave1_lim[`DUT_IF.wg_drv_sel][15:8]; wr_data[2] == `DUT_IF.wg_silent_wave1_lim[`DUT_IF.wg_drv_sel][7:0];});
    `nnc_info("SOC_TEST", "Set wave1 silent period", NNC_LOW)//0x0000_03E8 (1000us)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write to SOC_ADDR_WG_DRV_SILENT_CLK1_REG04
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_SILENT_CLK1_REG04 + WG_BASE); wr_data[0] == `DUT_IF.wg_silent_wave1_lim[`DUT_IF.wg_drv_sel][31:24];});
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // --------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_REST_CLK2_REG01
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_REST_CLK2_REG01 + WG_BASE); no_of_bytes == 2;  wr_data[0] == `DUT_IF.wg_rest_wave2_lim[`DUT_IF.wg_drv_sel][15:8]; wr_data[1] == `DUT_IF.wg_rest_wave2_lim[`DUT_IF.wg_drv_sel][7:0];});
    `nnc_info("SOC_TEST", "Set wave2 rest period", NNC_LOW)//0x0000_0064 (100us)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_SILENT_CLK2_REG01
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_SILENT_CLK2_REG01 + WG_BASE); no_of_bytes == 3; wr_data[0] == `DUT_IF.wg_silent_wave2_lim[`DUT_IF.wg_drv_sel][23:16]; wr_data[1] == `DUT_IF.wg_silent_wave2_lim[`DUT_IF.wg_drv_sel][15:8]; wr_data[2] == `DUT_IF.wg_silent_wave2_lim[`DUT_IF.wg_drv_sel][7:0];});
    `nnc_info("SOC_TEST", "Set wave2 silent period", NNC_LOW)//0x0000_03E8 (1000us)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write to SOC_ADDR_WG_DRV_SILENT_CLK2_REG04
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_SILENT_CLK2_REG04 + WG_BASE); wr_data[0] == `DUT_IF.wg_silent_wave2_lim[`DUT_IF.wg_drv_sel][31:24];});
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // --------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_HLF_WAVE_PRD_REG01
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_HLF_WAVE_PRD_REG01 + WG_BASE); no_of_bytes == 2; wr_data[0] == `DUT_IF.wg_hlf_wave0_lim[`DUT_IF.wg_drv_sel][15:8]; wr_data[1] == `DUT_IF.wg_hlf_wave0_lim[`DUT_IF.wg_drv_sel][7:0];});
    `nnc_info("SOC_TEST", "Set positive half wave0 period", NNC_LOW)//0x0000_01F4 (500us)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_NEG_HLF_WAVE_PRD_REG01
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
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CONFIG_REG0 + WG_BASE); (`DUT_IF.wg_drv_sel == 1) -> multielectrode_en == 1; wr_data[0] == {top_test_cfg.POS_OFF, top_test_cfg.multielectrode_en, 1'b0, 1'b0, top_test_cfg.sourceB_en, top_test_cfg.silent_en, top_test_cfg.NEG_ON, top_test_cfg.rest_en};});
    `nnc_info("SOC_TEST", "Set driver configuration register", NNC_LOW)
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    top_test_cfg.MULTI_ELEC = top_test_cfg.multielectrode_en;
    
    `nnc_info("SOC_TEST", $sformatf("Configure %d points", top_test_cfg.NO_OF_POINTS), NNC_LOW)
    // --------------------------------------------------------
    // Write to ADDR_WG_DRV_POINT_CONFIG
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_POINT_CONFIG + WG_BASE); wr_data[0] == top_test_cfg.NO_OF_POINTS;});
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    if(top_test_cfg.MULTI_ELEC === 0 && `DUT_IF.wg_drv_sel === 1)
    `nnc_info("SOC_TEST", "Do not load wavepoints for driver1 if MULTI_ELEC is 0!", NNC_LOW)
    else begin
    `nnc_info("SOC_TEST", $sformatf("Store %d wave points", top_test_cfg.NO_OF_LOAD_POINTS), NNC_LOW)
    for(int i=0; i<top_test_cfg.NO_OF_LOAD_POINTS; i++) begin
       	// --------------------------------------------------------
    	// Write to ADDR_WG_DRV_IN_WAVE_ADDR_REG0
    	// --------------------------------------------------------
    	assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0 + WG_BASE); wr_data[0] == i;});
    	`WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
	// --------------------------------------------------------
    	// Write to ADDR_WG_DRV_IN_WAVE_REG01
    	// --------------------------------------------------------
	assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_IN_WAVE_REG01 + WG_BASE); wr_data[0] == 8'hFF;});
    	`WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    end
    end
    // --------------------------------------------------------
    // Write to ADDR_WG_DRV_NEG_SCALE_REG0 (By default it is 1)
    // --------------------------------------------------------
    //assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_NEG_SCALE_REG0 + WG_BASE); wr_data[0] == 8'h01;});
    //`nnc_info("SOC_TEST", "Scale negative side", NNC_LOW)
    //`WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // --------------------------------------------------------
    // Write to ADDR_WG_DRV_POS_SCALE_REG0 (By default it is 1)
    // --------------------------------------------------------
    //assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_POS_SCALE_REG0 + WG_BASE); wr_data[0] == 8'h01;});
    //`nnc_info("SOC_TEST", "Scale positive side", NNC_LOW)
    //`WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // --------------------------------------------------------
    // Write to ADDR_WG_DRV_PULLBA_REG
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_PULLBA_REG + WG_BASE); wr_data[0] == top_test_cfg.PULLAB_CTRL;});
    `nnc_info("SOC_TEST", "Set pullab reg", NNC_LOW)
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
  end
  endtask
  // ------------------------------
  // Declare the report_phase task
  // ------------------------------
  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction

endclass : `TESTNAME
