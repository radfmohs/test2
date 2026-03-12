/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_wavegen_drva_iftsine_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_wavegen_drva_iftsine_test                                             
// Designer	: ophina@nanochap.com                                                                 
// Date		: 18-03-2024                                                                   
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

//***************************************************************************************
// NOTE : The test is intented  to generate ift sine wave for driver1 & driver2. 
//        The period of each driver sine wave is set only slighly different, such that 
//        those waves when added together create the ift sine due to interferential effect
//***************************************************************************************

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_wavegen_drva_iftsine_test
`define TESTCFG soc_wavegen_drva_iftsine_test_cfg

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
  logic [7:0]      sine_data[64] = {8'h0c, 8'h18, 8'h25, 8'h31, 8'h3d, 8'h4a, 8'h55, 8'h61, 8'h6d, 8'h78, 8'h83, 8'h8d, 8'h97, 8'ha1, 8'hab, 8'hb4, 8'hbc, 8'hc5, 8'hcc, 8'hd4, 8'hda, 8'he0, 8'he6, 8'heb, 8'hf0, 8'hf4, 8'hf7, 8'hfa, 8'hfc, 8'hfd, 8'hfe, 8'hff, 8'hfe, 8'hfd, 8'hfc, 8'hfa, 8'hf7, 8'hf4, 8'hf0, 8'heb, 8'he6, 8'he0, 8'hda, 8'hd4, 8'hcc, 8'hc5, 8'hbc, 8'hb4, 8'hab, 8'ha1, 8'h97, 8'h8d, 8'h83, 8'h78, 8'h6d, 8'h61, 8'h55, 8'h4a, 8'h3d, 8'h31, 8'h25, 8'h18, 8'h0c, 8'h00};
  logic [13:0]     clk_freq;//in Khz
  logic [31:0]     hlf_wave_lim; // number of clocks for positive half wave
  logic [31:0]     neg_hlf_wave_lim; // number of clocks for negative half wave
  logic [15:0]     rest_lim; // number of clocks for each rest period
  logic [31:0]     silent_lim; // number of clocks for each silent period
  rand logic [1:0] preload_sel;
  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_wavegen_drva_iftsine_test_cfg");
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
  constraint c_pclk_sel        { soft pclk_sel inside {[0:1]};}

  // No of bytes in a burst
  constraint c_no_of_bytes     { soft no_of_bytes == 2; }

  // pads values
  constraint c_pads            { soft pads == 8'h00; }

  // mask values
  constraint c_mask            { soft mask == 8'hff; }

  // altf_sel
  //constraint c_altf_sel    { soft altf_sel == 2'b00; }

  //preload_sel
  constraint c_preload_sel     { preload_sel inside {0,3};}

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
    `nnc_top.set_timeout(4s);
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

    `DUT_IF.pclk_sel = top_test_cfg.pclk_sel;

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

    `nnc_info("SOC_TEST", "soc_wavegen_drva_iftsine_test start", NNC_LOW)

    // ==================================================================================
    // Please add your code of your test here
    // ----------------------------------------------------------------------------------

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

    // Interface
    `DUT_IF.no_of_point_a = 64; // expected resolution
    `DUT_IF.no_of_point_b = 64; // expected resolution
    for (int i=0; i < `DUT_IF.no_of_point_a; i++) begin
      `DUT_IF.hex_data_a[i] = top_test_cfg.sine_data[i]; // expected hex values
      `DUT_IF.hex_data_b[i] = top_test_cfg.sine_data[i]; // expected hex values
    end
    `DUT_IF.pos_neg_from_same_addr = 1'b0; 
    `DUT_IF.load_wave_data_till_points = 1'b0; 
    `DUT_IF.no_of_waveforms = 3'b0; 
    `DUT_IF.preload_sel = top_test_cfg.preload_sel;
    for (int i=0; i < 2; i++) begin
      `DUT_IF.PULLAB_pos_en[i] = 1'b0;
      `DUT_IF.PULLAB_neg_en[i] = 1'b0;
      `DUT_IF.PULLAB_lim[i] = 6'b0;
    end

    top_test_cfg.clk_freq = 8192 / (2**`DUT_IF.pclk_sel);
    `nnc_info("SOC_TEST", $sformatf("CLK_FREQ: %dKhz", top_test_cfg.clk_freq), NNC_LOW)
    //wavegen_calc_clock_num(clk_freq (KHz), rest_t (us), silent_t (us), hlf_wave_per (us), neg_hlf_wave_per (us))
    wavegen_calc_clock_num(top_test_cfg.clk_freq, 0, 0, 300, 300);
    `DUT_IF.wg_hlf_wave0_lim[0] = top_test_cfg.hlf_wave_lim / 64;
    `DUT_IF.wg_neg_hlf_wave0_lim[0] = top_test_cfg.neg_hlf_wave_lim / 64;
    `DUT_IF.wg_rest_wave0_lim[0] = top_test_cfg.rest_lim;
    `DUT_IF.wg_silent_wave0_lim[0] = top_test_cfg.silent_lim;
    wavegen_drv_config(`WAVEGEN_0_ADDR_BASE);

    //wavegen_calc_clock_num(clk_freq (KHz), rest_t (us), silent_t (us), hlf_wave_per (us), neg_hlf_wave_per (us))
    wavegen_calc_clock_num(top_test_cfg.clk_freq, 0, 0, 320, 320);
    `DUT_IF.wg_hlf_wave0_lim[1] = top_test_cfg.hlf_wave_lim / 64;
    `DUT_IF.wg_neg_hlf_wave0_lim[1] = top_test_cfg.neg_hlf_wave_lim / 64;
    `DUT_IF.wg_rest_wave0_lim[1] = top_test_cfg.rest_lim;
    `DUT_IF.wg_silent_wave0_lim[1] = top_test_cfg.silent_lim;
    wavegen_drv_config(`WAVEGEN_1_ADDR_BASE);

    // --------------------------------------------------------
    // Write to ADDR_WG_DRV_DELAY_LIM_REG01
    // --------------------------------------------------------
    //`nnc_info("SOC_TEST", "Adjust delay using Delay_lim register", NNC_LOW)
    //assert(top_test_cfg.randomize() with {reg_addr == `SOC_ADDR_WG_DRV_DELAY_LIM_REG01; wr_data[0] == 8'h3A;});
    //`WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    `nnc_info("SOC_TEST", $sformatf("enabling chip_0 wavegen sb now"), NNC_LOW)
    `WAVEGEN_SCB_DRV_0_EN = 1'b1;
    `WAVEGEN_SCB_DRV_1_EN = 1'b1;

    // --------------------------------------------------------
    // Write to ADDR_WG_DRV_CTRL_REG0
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ADDR_WG_DRV_CTRL_REG0; wr_data[0] == {5'b0,`DUT_IF.preload_sel,1'b1};});
    if(`DUT_IF.preload_sel === 2'b00)
    	`nnc_info("SOC_TEST", "Enable driver0 using control register with preloaded sine values", NNC_LOW)
    else if(`DUT_IF.preload_sel === 2'b11)
    	`nnc_info("SOC_TEST", "Enable driver0 using control register with user config values", NNC_LOW)
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CTRL_REG0 + `WAVEGEN_1_ADDR_BASE); wr_data[0] == {5'b0,`DUT_IF.preload_sel,1'b1};});
    if(`DUT_IF.preload_sel === 2'b00)
    	`nnc_info("SOC_TEST", "Enable driver1 using control register with preloaded sine values", NNC_LOW)
    else if(`DUT_IF.preload_sel === 2'b11)
    	`nnc_info("SOC_TEST", "Enable driver1 using control register with user config values", NNC_LOW)
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    $display("## --------------------------------------------------------------------------- ##");
    $display("##         WAITING FOR SIMULATION TO COMPLETE WAVEFORM GENERATION              ##");      
    $display("## --------------------------------------------------------------------------- ##");
    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    #50ms;
    `nnc_info("SOC_TEST", "soc_wavegen_drva_iftsine_test end now", NNC_LOW)

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
    `nnc_info("SOC_TEST", "Set 0 silent period", NNC_LOW)
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
    `nnc_info("SOC_TEST", "Set positive half wave period", NNC_LOW)//0x0000_01F4 (500us)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_NEG_HLF_WAVE_PRD_REG01
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_NEG_HLF_WAVE_PRD_REG01 + WG_BASE); no_of_bytes == 2; wr_data[0] == `DUT_IF.wg_neg_hlf_wave0_lim[`DUT_IF.wg_drv_sel][15:8]; wr_data[1] == `DUT_IF.wg_neg_hlf_wave0_lim[`DUT_IF.wg_drv_sel][7:0];});
    `nnc_info("SOC_TEST", "Set negative half wave period", NNC_LOW)//0x0000_01F4 (500us)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write to ADDR_WG_DRV_CONFIG_REG0(//bit 0:rest enable, 1:negative enable, 2: silent enable, 3: source B enable, 4: alternate, 5: continue mode, 6: multi-electrode)
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CONFIG_REG0 + WG_BASE); wr_data[0] == 8'h4A;});
    `nnc_info("SOC_TEST", "Set driver configuration register", NNC_LOW)
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    
    // --------------------------------------------------------
    // Write to ADDR_WG_DRV_POINT_CONFIG
    // --------------------------------------------------------
    //assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_POINT_CONFIG + WG_BASE); wr_data[0] == 8'h40;});//64 points by default
    //`WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    `nnc_info("SOC_TEST", "Store 64 wave points", NNC_LOW)
    for(int i=0; i<64; i++) begin
       	// --------------------------------------------------------
    	// Write to ADDR_WG_DRV_IN_WAVE_ADDR_REG0
    	// --------------------------------------------------------
    	assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0 + WG_BASE); wr_data[0] == i;});
    	`WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
	// --------------------------------------------------------
    	// Write to ADDR_WG_DRV_IN_WAVE_REG01
    	// --------------------------------------------------------
	assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_IN_WAVE_REG01 + WG_BASE); wr_data[0] == top_test_cfg.sine_data[i][7:0];});
    	`WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
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
  end
  endtask
  // ------------------------------
  // Declare the report_phase task
  // ------------------------------
  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction

endclass : `TESTNAME
