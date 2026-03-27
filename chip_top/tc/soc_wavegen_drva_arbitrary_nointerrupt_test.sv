/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_wavegen_drva_arbitrary_nointerrupt_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_wavegen_drva_arbitrary_nointerrupt_test                                             
// Designer	: ophina@nanochap.com                                                                 
// Date		: 18-03-2024                                                                   
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

//******************************************************************************************************
// NOTE : The test is intented to generate arbitrary wave for driver1 & driver2 without using interrupt. 
// The user wavedata points will be of any arbitrary shape. The load_points & waveform_select feature 
// is used to generate arbitrary wave in this case.
//******************************************************************************************************

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_wavegen_drva_arbitrary_nointerrupt_test
`define TESTCFG soc_wavegen_drva_arbitrary_nointerrupt_test_cfg

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
  logic [7:0]      arbi_data[128];
  logic [13:0]     clk_freq;//in Khz
  logic [12:0]     half_period_limit;
  rand logic [12:0] half_period0;
  rand logic [12:0] half_period1;
  rand logic [12:0] half_period2;
  logic [31:0]     hlf_wave_lim; // number of clocks for positive half wave
  logic [31:0]     neg_hlf_wave_lim; // number of clocks for negative half wave
  logic [15:0]     rest_lim; // number of clocks for each rest period
  logic [31:0]     silent_lim; // number of clocks for each silent period
  rand logic [1:0] preload_sel;
  rand logic       neg_ena;
  rand logic       pos_dis;
  rand logic [2:0] points_sel;
  rand logic [2:0] waveform_sel;
  rand logic       load_points_sel;
  rand logic       pos_neg_diff_sel;
       logic       LOAD_POINTS;
       logic [7:0] NO_OF_POINTS;
       logic [7:0] NO_OF_LOAD_POINTS;
       logic [2:0] NO_OF_WAVEFORMS;
       logic       POS_NEG_DIFF;
  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_wavegen_drva_arbitrary_nointerrupt_test_cfg");
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
  constraint c_preload_sel     { preload_sel inside {3,3};}//user config arbitrary waveform

  //neg_ena
  constraint c_neg_ena         { neg_ena == 1'b1;}

  //pos_dis
  constraint c_pos_dis         { pos_dis == 1'b0;}

  //points_sel
  constraint c_points_sel      {
                                 ((waveform_sel == 3'b000) && (pos_neg_diff_sel == 1'b0)) -> points_sel inside {[0:4]};
                                 ((waveform_sel == 3'b000) && (pos_neg_diff_sel == 1'b1)) -> points_sel inside {[0:4]};
                                 ((waveform_sel == 3'b001) && (pos_neg_diff_sel == 1'b0)) -> points_sel inside {[1:4]};
                                 ((waveform_sel == 3'b001) && (pos_neg_diff_sel == 1'b1)) -> points_sel inside {[0:4]};
                                 ((waveform_sel == 3'b010) && (pos_neg_diff_sel == 1'b0)) -> points_sel inside {[2:4]};
                                 ((waveform_sel == 3'b010) && (pos_neg_diff_sel == 1'b1)) -> points_sel inside {[1:4]};
                               }//8/16/32/64 points

  //waveform_sel
  constraint c_waveform_sel    { waveform_sel inside {[0:2]};}

  //load_points_sel
  constraint c_load_points_sel { load_points_sel == 1'b1;}

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

    `nnc_info("SOC_TEST", "soc_wavegen_drva_arbitrary_nointerrupt_test start", NNC_LOW)

    // ==================================================================================
    // Please add your code of your test here
    // ----------------------------------------------------------------------------------
    top_test_cfg.LOAD_POINTS = top_test_cfg.load_points_sel;
    top_test_cfg.NO_OF_WAVEFORMS = top_test_cfg.waveform_sel;
    top_test_cfg.POS_NEG_DIFF = top_test_cfg.pos_neg_diff_sel;
    
    case(top_test_cfg.points_sel)
         3'b000:begin
		    top_test_cfg.NO_OF_POINTS = 64;
		    $readmemh("../../../verification/models/wavegen_stimulus/arbitrary/hex_res64_y128", top_test_cfg.arbi_data);
		end
         3'b001:begin
		    top_test_cfg.NO_OF_POINTS = 32;
		    $readmemh("../../../verification/models/wavegen_stimulus/arbitrary/hex_res32_y128", top_test_cfg.arbi_data);
		end
         3'b010:begin
		    top_test_cfg.NO_OF_POINTS = 16;
		    $readmemh("../../../verification/models/wavegen_stimulus/arbitrary/hex_res16_y128", top_test_cfg.arbi_data);
		end
         3'b011:begin
		    top_test_cfg.NO_OF_POINTS = 8;
		    $readmemh("../../../verification/models/wavegen_stimulus/arbitrary/hex_res8_y128", top_test_cfg.arbi_data);
		end
         3'b100:begin
		    top_test_cfg.NO_OF_POINTS = 20;
		    $readmemh("../../../verification/models/wavegen_stimulus/arbitrary/hex_res20_y128", top_test_cfg.arbi_data);
		end
         3'b101:begin
		    top_test_cfg.NO_OF_POINTS = 2;
		    $readmemh("../../../verification/models/wavegen_stimulus/arbitrary/hex_y128", top_test_cfg.arbi_data);
		end
         3'b110:begin
		    top_test_cfg.NO_OF_POINTS = 1;
		    $readmemh("../../../verification/models/wavegen_stimulus/arbitrary/hex_y128", top_test_cfg.arbi_data);
		end
         3'b111:begin
		    top_test_cfg.NO_OF_POINTS = 128;
		    $readmemh("../../../verification/models/wavegen_stimulus/arbitrary/hex_y128", top_test_cfg.arbi_data);
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

    `nnc_info("SOC_TEST", $sformatf("NO_OF_POINTS: %d, NO_OF_LOAD_POINTS: %d", top_test_cfg.NO_OF_POINTS, top_test_cfg.NO_OF_LOAD_POINTS), NNC_LOW)

    top_test_cfg.clk_freq = 8192 / (2**`DUT_IF.pclk_sel);
    top_test_cfg.half_period_limit = (top_test_cfg.NO_OF_POINTS * 1000) / top_test_cfg.clk_freq;

    for(int i = 0; i < `WAVEGEN_DRIVER_NUM; i++) begin
    assert(top_test_cfg.randomize() with {half_period0 > top_test_cfg.half_period_limit; half_period1 > top_test_cfg.half_period_limit; half_period2 > top_test_cfg.half_period_limit;});
    //wavegen_calc_clock_num(clk_freq (KHz), rest_t (us), silent_t (us), hlf_wave_per (us), neg_hlf_wave_per (us))
    wavegen_calc_clock_num(top_test_cfg.clk_freq, 0, 0, top_test_cfg.half_period0, top_test_cfg.half_period0);
    `DUT_IF.wg_hlf_wave0_lim[i] = top_test_cfg.hlf_wave_lim / top_test_cfg.NO_OF_POINTS;
    `DUT_IF.wg_neg_hlf_wave0_lim[i] = top_test_cfg.neg_hlf_wave_lim / top_test_cfg.NO_OF_POINTS;
    `DUT_IF.wg_rest_wave0_lim[i] = top_test_cfg.rest_lim;
    `DUT_IF.wg_silent_wave0_lim[i] = top_test_cfg.silent_lim;
    `nnc_info("SOC_TEST", $sformatf("******** Driver (%d) WAVE 0 ******** CLK_FREQ: %dKhz, HALF_PERIOD_LIMIT: %dus, HALF_PERIOD_TARGET: %dus, HALF_PERIOD_CLKS_PER_POINT: %d", i, top_test_cfg.clk_freq, top_test_cfg.half_period_limit, top_test_cfg.half_period0, `DUT_IF.wg_hlf_wave0_lim[i]), NNC_LOW)

    //wavegen_calc_clock_num(clk_freq (KHz), rest_t (us), silent_t (us), hlf_wave_per (us), neg_hlf_wave_per (us))
    wavegen_calc_clock_num(top_test_cfg.clk_freq, 0, 0, top_test_cfg.half_period1, top_test_cfg.half_period1);
    `DUT_IF.wg_hlf_wave1_lim[i] = top_test_cfg.hlf_wave_lim / top_test_cfg.NO_OF_POINTS;
    `DUT_IF.wg_neg_hlf_wave1_lim[i] = top_test_cfg.neg_hlf_wave_lim / top_test_cfg.NO_OF_POINTS;
    `DUT_IF.wg_rest_wave1_lim[i] = top_test_cfg.rest_lim;
    `DUT_IF.wg_silent_wave1_lim[i] = top_test_cfg.silent_lim;
    `nnc_info("SOC_TEST", $sformatf("******** Driver (%d) WAVE 1 ******** CLK_FREQ: %dKhz, HALF_PERIOD_LIMIT: %dus, HALF_PERIOD_TARGET: %dus, HALF_PERIOD_CLKS_PER_POINT: %d", i, top_test_cfg.clk_freq, top_test_cfg.half_period_limit, top_test_cfg.half_period1, `DUT_IF.wg_hlf_wave1_lim[i]), NNC_LOW)

    //wavegen_calc_clock_num(clk_freq (KHz), rest_t (us), silent_t (us), hlf_wave_per (us), neg_hlf_wave_per (us))
    wavegen_calc_clock_num(top_test_cfg.clk_freq, 0, 0, top_test_cfg.half_period2, top_test_cfg.half_period2);
    `DUT_IF.wg_hlf_wave2_lim[i] = top_test_cfg.hlf_wave_lim / top_test_cfg.NO_OF_POINTS;
    `DUT_IF.wg_neg_hlf_wave2_lim[i] = top_test_cfg.neg_hlf_wave_lim / top_test_cfg.NO_OF_POINTS;
    `DUT_IF.wg_rest_wave2_lim[i] = top_test_cfg.rest_lim;
    `DUT_IF.wg_silent_wave2_lim[i] = top_test_cfg.silent_lim;
    `nnc_info("SOC_TEST", $sformatf("******** Driver (%d) WAVE 2 ******** CLK_FREQ: %dKhz, HALF_PERIOD_LIMIT: %dus, HALF_PERIOD_TARGET: %dus, HALF_PERIOD_CLKS_PER_POINT: %d", i, top_test_cfg.clk_freq, top_test_cfg.half_period_limit, top_test_cfg.half_period2, `DUT_IF.wg_hlf_wave2_lim[i]), NNC_LOW)
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

    wavegen_drv_config(`WAVEGEN_0_ADDR_BASE);
    wavegen_drv_config(`WAVEGEN_1_ADDR_BASE);

    // --------------------------------------------------------
    // Write to ADDR_WG_DRV_DELAY_LIM_REG01
    // --------------------------------------------------------
    `nnc_info("SOC_TEST", "Adjust delay using Delay_lim register", NNC_LOW)
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ADDR_WG_DRV_DELAY_LIM_REG01;});
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_DELAY_LIM_REG01 + `WAVEGEN_1_ADDR_BASE);});
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // --------------------------------------------------------
    // Write to ADDR_WG_DRV_CTRL_REG0
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ADDR_WG_DRV_CTRL_REG0; wr_data[0] == {top_test_cfg.POS_NEG_DIFF,top_test_cfg.LOAD_POINTS,top_test_cfg.NO_OF_WAVEFORMS,top_test_cfg.preload_sel,1'b1};});
    `nnc_info("SOC_TEST", "Enable driver0 using control register with user config values", NNC_LOW)
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CTRL_REG0 + `WAVEGEN_1_ADDR_BASE); wr_data[0] == {top_test_cfg.POS_NEG_DIFF,top_test_cfg.LOAD_POINTS,top_test_cfg.NO_OF_WAVEFORMS,top_test_cfg.preload_sel,1'b1};});
    `nnc_info("SOC_TEST", "Enable driver1 using control register with user config values", NNC_LOW)
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    $display("## --------------------------------------------------------------------------- ##");
    $display("##         WAITING FOR SIMULATION TO COMPLETE WAVEFORM GENERATION              ##");      
    $display("## --------------------------------------------------------------------------- ##");
    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    #100ms;
    `nnc_info("SOC_TEST", "soc_wavegen_drva_arbitrary_nointerrupt_test end now", NNC_LOW)

    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ==================================================================================

    phase.drop_objection(this);
  endtask: main_phase

  task wavegen_calc_clock_num;
  input [13:0] clk_freq;
  input [7:0]  rest_t;
  input [31:0] silent_t;
  input [31:0] hlf_wave_per;
  input [31:0] neg_hlf_wave_per;
  begin
    top_test_cfg.hlf_wave_lim = (hlf_wave_per * {20'b0,clk_freq}) / 1000;
    top_test_cfg.neg_hlf_wave_lim = (neg_hlf_wave_per * {20'b0,clk_freq}) / 1000;
    top_test_cfg.rest_lim = ({8'b0,rest_t} * {4'b0,clk_freq}) / 1000;
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
    `nnc_info("SOC_TEST", "Set 0 rest period", NNC_LOW)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_SILENT_T_REG01
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_SILENT_T_REG01 + WG_BASE); no_of_bytes == 3; wr_data[0] == `DUT_IF.wg_silent_wave0_lim[`DUT_IF.wg_drv_sel][23:16]; wr_data[1] == `DUT_IF.wg_silent_wave0_lim[`DUT_IF.wg_drv_sel][15:8]; wr_data[2] == `DUT_IF.wg_silent_wave0_lim[`DUT_IF.wg_drv_sel][7:0];});
    `nnc_info("SOC_TEST", "Set 0 silent time", NNC_LOW)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write to ADDR_WG_DRV_CLK_FREQ_REG0 (removed)
    // --------------------------------------------------------
    //assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CLK_FREQ_REG0 + WG_BASE); wr_data[0] == 8'h02;});
    //`nnc_info("SOC_TEST", "Set clk frequency", NNC_LOW)
    //`WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

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
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CONFIG_REG0 + WG_BASE); wr_data[0] == {top_test_cfg.pos_dis, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0, top_test_cfg.neg_ena, 1'b0};});
    `nnc_info("SOC_TEST", "Set driver configuration register", NNC_LOW)
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    
    `nnc_info("SOC_TEST", $sformatf("Configure %d points", top_test_cfg.NO_OF_POINTS), NNC_LOW)
    // --------------------------------------------------------
    // Write to ADDR_WG_DRV_POINT_CONFIG
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_POINT_CONFIG + WG_BASE); wr_data[0] == top_test_cfg.NO_OF_POINTS;});
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

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
	assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_IN_WAVE_REG01 + WG_BASE); wr_data[0] == top_test_cfg.arbi_data[i][7:0];});
    	`WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    end

    // --------------------------------------------------------
    // Write to ADDR_WG_DRV_NEG_SCALE_REG0 (By default it is 1)
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_NEG_SCALE_REG0 + WG_BASE); wr_data[0] == 8'h01;});
    `nnc_info("SOC_TEST", "Scale negative side", NNC_LOW)
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // --------------------------------------------------------
    // Write to ADDR_WG_DRV_POS_SCALE_REG0 (By default it is 1)
    // --------------------------------------------------------
    //assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_POS_SCALE_REG0 + WG_BASE); wr_data[0] == 8'h01;});
    //`nnc_info("SOC_TEST", "Scale positive side", NNC_LOW)
    //`WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
  end
  endtask
  // ------------------------------
  // Declare the report_phase task
  // ------------------------------
  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction

endclass : `TESTNAME
