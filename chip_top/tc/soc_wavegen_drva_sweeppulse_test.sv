/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_wavegen_drva_sweeppulse_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_wavegen_drva_sweeppulse_test                                             
// Designer	: ophina@nanochap.com                                                                 
// Date		: 18-03-2024                                                                    
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

//*****************************************************************************************
// NOTE : This test follows the same configuration sequence as pulse test, but additionally 
//        use wavegen interrupt feature to update silent time such that a sweep of pulse 
//        output wave will be generated.
//*****************************************************************************************

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_wavegen_drva_sweeppulse_test
`define TESTCFG soc_wavegen_drva_sweeppulse_test_cfg
//32 different periods for this test case to sweep
`define NUM_PERIODS 32
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
  //logic [15:0]     period_data[32] = {16'h1511, 16'h0fda, 16'h08dc, 16'h06cd, 16'h0584, 16'h04fb, 16'h048a, 16'h0416, 16'h03ad, 16'h0344, 16'h02fd, 16'h0293, 16'h025e, 16'h0232, 16'h020a, 16'h01e9, 16'h01cc, 16'h01b4, 16'h01a3, 16'h019f, 16'h019d, 16'h019a, 16'h0196, 16'h0195, 16'h0194, 16'h0193, 16'h0193, 16'h0192, 16'h0191, 16'h0191, 16'h0190, 16'h0190};
  logic [15:0]     period_data[32] = {16'h61A8, 16'h3A98, 16'h2710, 16'h1511, 16'h0fda, 16'h08dc, 16'h06cd, 16'h0584, 16'h048a, 16'h0416, 16'h03ad, 16'h0344, 16'h02fd, 16'h0293, 16'h025e, 16'h0232, 16'h020a, 16'h01e9, 16'h01cc, 16'h01b4, 16'h01a3, 16'h019f, 16'h019a, 16'h0196, 16'h0195, 16'h0194, 16'h0193, 16'h0192, 16'h0191, 16'h0191, 16'h0190, 16'h0190};

  logic [13:0]     clk_freq;//in Khz
  logic [11:0]     half_period_limit;
  rand logic [11:0] half_period;
  logic [31:0]     hlf_wave_lim; // number of clocks for positive half wave
  logic [31:0]     neg_hlf_wave_lim; // number of clocks for negative half wave
  logic [15:0]     rest_lim; // number of clocks for each rest period
  logic [31:0]     silent_lim; // number of clocks for each silent period
  rand logic [1:0] preload_sel;
  rand logic [2:0] wg_drv_sel;
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
       logic [1:0] preload_sel_drv0;
       logic [1:0] preload_sel_drv1;
  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_wavegen_drva_sweeppulse_test_cfg");
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
  constraint c_spi_sclk_freq   { solve spi_sclk_jitter before spi_sclk_freq; spi_sclk_freq inside {[(`SPI_MAX_FREQ/100)*(100 - spi_sclk_jitter):(`SPI_MAX_FREQ/100)*(100 - spi_sclk_jitter)]};}//14Mhz

  constraint c_tsccs           { solve tch before tsccs; solve spi_sclk_freq before tsccs; tsccs <= 4000; tsccs >= `SPI_TCH_MAX;
                                      (tch >= 50) -> tsccs > 100*tch/spi_sclk_freq;
                                      (tch <  50) -> tsccs > 100*(100 - tch)/spi_sclk_freq;
                               }
  constraint c_tcsh            { solve tch before tcsh; solve spi_sclk_freq before tcsh; tcsh <= 4000; tcsh >= `SPI_TCH_MAX;
                                      (tch >= 50) -> tcsh > 100*tch/spi_sclk_freq;
                                      (tch <  50) -> tcsh > 100*(100 - tch)/spi_sclk_freq;
                               }
/*  constraint c_tch             { solve spi_sclk_freq before tch;
                                       tch inside {[1:99]};
                                       tch < (100 - spi_sclk_freq/400);
                                       tch > spi_sclk_freq/400;
                               }
*/

  //pclk_div[2:0]
  constraint c_pclk_sel        { soft pclk_sel inside {[3:7]};}

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

  // only 2 driver A's
  constraint c_wg_drv_sel      { soft wg_drv_sel inside {[0:1]}; }

  //dac_bit_len_sel
  constraint c_dac_bit_len_sel { (preload_sel == 2'b01) -> dac_bit_len_sel == 1'b0;}

  //auto_man
  constraint c_auto_man        { auto_man == 1'b0;}

  //dac0_data_h
  constraint c_dac0_data_h     { dac0_data_h != 0;}

  //dac1_data_h
  constraint c_dac1_data_h     { dac1_data_h != 0;}

  //dac0_msb_sel
  constraint c_dac0_msb_sel    { dac0_msb_sel inside {[0:4]};}

  //dac1_msb_sel
  constraint c_dac1_msb_sel    { dac1_msb_sel inside {[0:4]};}

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
    `nnc_top.set_timeout(1s);
    top_test_cfg = `TESTCFG::type_id::create("top_test_cfg", this);
  endfunction

  // -----------------------------------------
  // Declare the pre_reset_phase task 
  // -----------------------------------------
  virtual task pre_reset_phase(nnc_phase phase);
    phase.raise_objection(this);

    super.pre_reset_phase(phase);

    assert(top_test_cfg.randomize()/* with {
    (pclk_sel == 0)  -> spi_sclk_freq inside {[1000:20000]};
    (pclk_sel == 1)  -> spi_sclk_freq inside {[1000:20000]};
    (pclk_sel == 2)  -> spi_sclk_freq inside {[1000:20000]};
    (pclk_sel == 3)  -> spi_sclk_freq inside {[1000:20000]};
    (pclk_sel == 4)  -> spi_sclk_freq inside {[1000:20000]};
    (pclk_sel == 5)  -> spi_sclk_freq inside {[1000:20000]};
    (pclk_sel == 6)  -> spi_sclk_freq inside {[1000:20000]};
    }*/);

    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;

    // Changed SCLK_jitter, must update 5 constraints
    `DUT_IF.spi_sclk_jitter  = top_test_cfg.spi_sclk_jitter;
    `DUT_IF.spi_sclk_freq = top_test_cfg.spi_sclk_freq;
    `DUT_IF.tch      = top_test_cfg.tch;
    `DUT_IF.tcsh     = top_test_cfg.tcsh;
    `DUT_IF.tsccs    = top_test_cfg.tsccs;

    `DUT_IF.pclk_sel = top_test_cfg.pclk_sel;
    `DUT_IF.hfosc_jitter = top_test_cfg.hfosc_jitter;
    `DUT_IF.hfosc_variation = top_test_cfg.hfosc_variation;
    //`DUT_IF.altf_sel = top_test_cfg.altf_sel;
    //`DUT_IF.wg_drv_sel = top_test_cfg.wg_drv_sel;

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

    `nnc_info("SOC_TEST", "soc_wavegen_drva_sweeppulse_test start", NNC_LOW)

    // ==================================================================================
    // Please add your code of your test here
    // ----------------------------------------------------------------------------------

    top_test_cfg.clk_freq = 8192 / (2**`DUT_IF.pclk_sel);
    top_test_cfg.half_period_limit = 64000 / top_test_cfg.clk_freq; 

    for(int i = 0; i < `WAVEGEN_DRIVER_NUM; i++) begin
    assert(top_test_cfg.randomize() with {half_period > top_test_cfg.half_period_limit;});
    //wavegen_calc_clock_num(clk_freq (KHz), rest_t (us), silent_t (us), hlf_wave_per (us), neg_hlf_wave_per (us))
    wavegen_calc_clock_num(top_test_cfg.clk_freq, 100, 25000, top_test_cfg.half_period, top_test_cfg.half_period);
    `DUT_IF.wg_hlf_wave0_lim[i] = top_test_cfg.hlf_wave_lim / 64;
    `DUT_IF.wg_neg_hlf_wave0_lim[i] = top_test_cfg.neg_hlf_wave_lim / 64;
    `DUT_IF.wg_rest_wave0_lim[i] = top_test_cfg.rest_lim;
    `DUT_IF.wg_silent_wave0_lim[i] = top_test_cfg.silent_lim;
    `nnc_info("SOC_TEST", $sformatf("Driver (%d) ******** WAVE ******** CLK_FREQ: %dKhz, HALF_PERIOD_LIMIT: %dus, HALF_PERIOD_TARGET: %dus, HALF_PERIOD_CLKS_PER_POINT: %d", i, top_test_cfg.clk_freq, top_test_cfg.half_period_limit, top_test_cfg.half_period, `DUT_IF.wg_hlf_wave0_lim[i]), NNC_LOW)
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
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ADDR_WG_DRV_CTRL0_REG; wr_data[0] == {2'b0, top_test_cfg.dac_bit_len_sel,top_test_cfg.auto_man, 4'b0};});
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    top_test_cfg.preload_sel_drv0 = top_test_cfg.preload_sel;

    // --------------------------------------------------------
    // Write to SOC_ADDR_WG_DRV_CTRL0_REG for drv1
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CTRL0_REG + `WAVEGEN_1_ADDR_BASE); wr_data[0] == {2'b0, top_test_cfg.dac_bit_len_sel,top_test_cfg.auto_man, 4'b0};});
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    top_test_cfg.preload_sel_drv1 = top_test_cfg.preload_sel;

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

    `DUT_IF.wg_drv_sel = top_test_cfg.wg_drv_sel;// select which driver
    // --------------------------------------------------------
    // Write to SOC_LEAD_OFF_INT_REG to disable lead off interrupt
    // --------------------------------------------------------
    //assert(top_test_cfg.randomize() with {reg_addr == `SOC_LEAD_OFF_INT_REG; wr_data[0] == 8'h00;});
    //`WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    #100us;//wait 1pclk before enabling driver after configuring int_reg
    // --------------------------------------------------------
    // Write to ADDR_WG_DRV_CTRL_REG0
    // --------------------------------------------------------
   fork
   begin
    if(`DUT_IF.wg_drv_sel === 0) begin
    	assert(top_test_cfg.randomize() with {reg_addr == `SOC_ADDR_WG_DRV_CTRL_REG0; wr_data[0] == {5'b0,top_test_cfg.preload_sel_drv0,1'b1};});
    	if(top_test_cfg.preload_sel_drv0 === 2'b01)
    	  `nnc_info("SOC_TEST", "Enable driver0 using control register with preloaded pulse values", NNC_LOW)
   	else if(top_test_cfg.preload_sel_drv0 === 2'b11)
    	  `nnc_info("SOC_TEST", "Enable driver0 using control register with user config values", NNC_LOW)
    	`WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    end
    else if(`DUT_IF.wg_drv_sel === 1) begin
    	assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CTRL_REG0 + `WAVEGEN_1_ADDR_BASE); wr_data[0] == {5'b0,top_test_cfg.preload_sel_drv1,1'b1};});
    	if(top_test_cfg.preload_sel_drv1 === 2'b01)
    	  `nnc_info("SOC_TEST", "Enable driver1 using control register with preloaded pulse values", NNC_LOW)
    	else if(top_test_cfg.preload_sel_drv1 === 2'b11)
    	  `nnc_info("SOC_TEST", "Enable driver1 using control register with user config values", NNC_LOW)
    	`WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    end
   end
   begin
    wavegen_drv_int_update;
   end
   join

    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    #10ms;
    `nnc_info("SOC_TEST", "soc_wavegen_drva_sweeppulse_test end now", NNC_LOW)

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
    top_test_cfg.hlf_wave_lim = (hlf_wave_per * {18'b0,clk_freq}) / 1000;
    top_test_cfg.neg_hlf_wave_lim = (neg_hlf_wave_per * {18'b0,clk_freq}) / 1000;
    top_test_cfg.rest_lim = ({8'b0,rest_t} * {2'b0,clk_freq}) / 1000;
    top_test_cfg.silent_lim = (silent_t * {18'b0,clk_freq}) / 1000;
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
    // Write to ADDR_WG_DRV_CLK_FREQ_REG0 (removed)
    // --------------------------------------------------------
    //assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CLK_FREQ_REG0 + WG_BASE); wr_data[0] == 8'h02;});
    //`nnc_info("SOC_TEST", "Set clk frequency", NNC_LOW)
    //`WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // --------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_HLF_WAVE_PRD_REG01
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_HLF_WAVE_PRD_REG01 + WG_BASE); no_of_bytes == 2; wr_data[0] == `DUT_IF.wg_hlf_wave0_lim[`DUT_IF.wg_drv_sel][15:8]; wr_data[1] == `DUT_IF.wg_hlf_wave0_lim[`DUT_IF.wg_drv_sel][7:0];});
    `nnc_info("SOC_TEST", "Set positive half wave period", NNC_LOW)//0x0000_0190 (400us)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_NEG_HLF_WAVE_PRD_REG01
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_NEG_HLF_WAVE_PRD_REG01 + WG_BASE); no_of_bytes == 2; wr_data[0] == `DUT_IF.wg_neg_hlf_wave0_lim[`DUT_IF.wg_drv_sel][15:8]; wr_data[1] == `DUT_IF.wg_neg_hlf_wave0_lim[`DUT_IF.wg_drv_sel][7:0];});
    `nnc_info("SOC_TEST", "Set negative half wave period", NNC_LOW)//0x0000_0190 (400us)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_REST_T_REG01
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_REST_T_REG01 + WG_BASE); no_of_bytes == 2;  wr_data[0] == `DUT_IF.wg_rest_wave0_lim[`DUT_IF.wg_drv_sel][15:8]; wr_data[1] == `DUT_IF.wg_rest_wave0_lim[`DUT_IF.wg_drv_sel][7:0];});
    `nnc_info("SOC_TEST", "Set rest period", NNC_LOW)//0x0000_00C8 (200us)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_SILENT_T_REG01
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_SILENT_T_REG01 + WG_BASE); no_of_bytes == 3; wr_data[0] == `DUT_IF.wg_silent_wave0_lim[`DUT_IF.wg_drv_sel][23:16]; wr_data[1] == `DUT_IF.wg_silent_wave0_lim[`DUT_IF.wg_drv_sel][15:8]; wr_data[2] == `DUT_IF.wg_silent_wave0_lim[`DUT_IF.wg_drv_sel][7:0];});
    `nnc_info("SOC_TEST", "Set silent period", NNC_LOW)//0x0000_03E8 (1000us)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write to ADDR_WG_DRV_CONFIG_REG0(//bit 0:rest enable, 1:negative enable, 2: silent enable, 3: source B enable, 4: alternate, 5: continue mode, 6: multi-electrode)
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CONFIG_REG0 + WG_BASE); wr_data[0] == 8'h4F;});
    `nnc_info("SOC_TEST", "Set driver configuration register", NNC_LOW)
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

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
	assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_IN_WAVE_REG01 + WG_BASE); wr_data[0] == 8'hFF;});
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

    // --------------------------------------------------------
    // Write to ADDR_WG_DRV_PULLBA_REG
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_PULLBA_REG + WG_BASE); wr_data[0] == {top_test_cfg.PULLAB_pos_en, top_test_cfg.PULLAB_neg_en, top_test_cfg.PULLAB_lim};});
    `nnc_info("SOC_TEST", "Set pullab reg", NNC_LOW)
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // --------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_INT_REG01
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_INT_REG01 + WG_BASE); no_of_bytes == 3; wr_data[0] == 8'h21; wr_data[1] == 8'h01; wr_data[2] == 8'h01;});
    `nnc_info("SOC_TEST", "Configure interrupt register", NNC_LOW)//interrupt register set as first address 1; second address 33
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);
  end
  endtask

  task wavegen_drv_int_update;
    int s = 0;
    int j = 0;
    int r = 0;

`ifdef BEHAVIORAL
    repeat(100) begin
`else
    repeat(50) begin
`endif
	@(posedge `SOC_TB.INTB);
	`nnc_info("SOC_TEST", "An interrupt happenned ...", NNC_LOW)
	//for (int i=0; i<2; i++) begin //only 0/1 Driver A working in this test case
	  // ------------------------------------------------------------------------------------------------------------------------------
    	  // Read burst starting from ADDR_WG_DRV_INT_REG01 (/read the interrupt registers to find the block which generated the interrupt)
    	  // ------------------------------------------------------------------------------------------------------------------------------
    	  assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_INT_REG01 + (`WAVEGEN_1_ADDR_BASE * `DUT_IF.wg_drv_sel)); no_of_bytes == 3;});
    	  `nnc_info("SOC_TEST", "Read interrupt register", NNC_LOW)
    	  `RD_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);	
	  if ((top_test_cfg.rd_data[2][3]===1'b1) & (top_test_cfg.rd_data[2][2:0]===`DUT_IF.wg_drv_sel)) begin //also check if interrupt in this block is enabled (bit 8 is active)
		if((top_test_cfg.rd_data[2][5]===1) & (top_test_cfg.rd_data[2][4]===0)) begin
		    `nnc_info("SOC_TEST", $sformatf("Interrupt is in block no: %d", `DUT_IF.wg_drv_sel), NNC_LOW)
		    `nnc_error("SOC_TEST", $sformatf("Interrupt WARNING: Second address (underflow) interrupt has happenned at address: %h", top_test_cfg.rd_data[0]))
		    // ------------------------------------------------------------------
    		    // Write to ADDR_WG_DRV_INT_REG01 (clear the second address interrupt)
    		    // ------------------------------------------------------------------
    		    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_INT_REG01 + (`WAVEGEN_1_ADDR_BASE * `DUT_IF.wg_drv_sel)); wr_data[0] == 8'h05;});
    		    `nnc_info("SOC_TEST", "Clear the second address interrupt", NNC_LOW)
    		    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);//hopefully this interrupt is never activated otherwise we have missed the chance to load the next half of data on time
		end
		if(top_test_cfg.rd_data[2][4]===1) begin
		    `nnc_info("SOC_TEST", $sformatf("Interrupt is in block no: %d", `DUT_IF.wg_drv_sel), NNC_LOW)
		    `nnc_info("SOC_TEST", $sformatf("First address interrupt has happenned at address: %h", top_test_cfg.rd_data[1]), NNC_LOW)
					
		    if (top_test_cfg.rd_data[1] === 8'h01) begin //first address is at the first half of the wave; now load the second half
			if (s==0) begin
				//load the new period
				`nnc_info("SOC_TEST", "Updating the period ...", NNC_LOW)
				//wavegen_calc_clock_num(clk_freq (MHz), rest_t (us), silent_t (us), hlf_wave_per (us), neg_hlf_wave_per (us))
				wavegen_calc_clock_num(top_test_cfg.clk_freq, 100, top_test_cfg.period_data[j] - 300, 100, 100);
				`DUT_IF.wg_hlf_wave0_lim[`DUT_IF.wg_drv_sel] = top_test_cfg.hlf_wave_lim / 64;
    				`DUT_IF.wg_neg_hlf_wave0_lim[`DUT_IF.wg_drv_sel] = top_test_cfg.neg_hlf_wave_lim / 64;
    				`DUT_IF.wg_rest_wave0_lim[`DUT_IF.wg_drv_sel] = top_test_cfg.rest_lim;
    				`DUT_IF.wg_silent_wave0_lim[`DUT_IF.wg_drv_sel] = top_test_cfg.silent_lim;
				// --------------------------------------------------------
    				// Write burst starting from ADDR_WG_DRV_SILENT_T_REG01
    				// --------------------------------------------------------
    				assert(top_test_cfg.randomize() with 
				{reg_addr == (`SOC_ADDR_WG_DRV_SILENT_T_REG01 + (`WAVEGEN_1_ADDR_BASE * `DUT_IF.wg_drv_sel)); no_of_bytes == 3;
				wr_data[0] == `DUT_IF.wg_silent_wave0_lim[`DUT_IF.wg_drv_sel][23:16]; wr_data[1] == `DUT_IF.wg_silent_wave0_lim[`DUT_IF.wg_drv_sel][15:8]; wr_data[2] == `DUT_IF.wg_silent_wave0_lim[`DUT_IF.wg_drv_sel][7:0];});
    				`nnc_info("SOC_TEST", "Set silent period", NNC_LOW)// deduct 300 us from the period because pulse half periods plus the rest time in between us already 300 us
    				`WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

				// --------------------------------------------------------
    				// Write burst starting from ADDR_WG_DRV_INT_REG02
    				// --------------------------------------------------------
    				assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_INT_REG02 + (`WAVEGEN_1_ADDR_BASE * `DUT_IF.wg_drv_sel)); no_of_bytes == 2; wr_data[0] == 8'h00; wr_data[1] == 8'h21;});
    				`nnc_info("SOC_TEST", "Configure interrupt register", NNC_LOW)//interrupt register set as first address 33; second address 0
    				`WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);
				s = 1;
			end
			else begin
				s = 0;
				// --------------------------------------------------------
    				// Write burst starting from ADDR_WG_DRV_INT_REG02
    				// --------------------------------------------------------
    				assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_INT_REG02 + (`WAVEGEN_1_ADDR_BASE * `DUT_IF.wg_drv_sel)); no_of_bytes == 2; wr_data[0] == 8'h00; wr_data[1] == 8'h21;});
    				`nnc_info("SOC_TEST", "Configure interrupt register", NNC_LOW)//interrupt register set as first address 33; second address 0
    				`WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

				if (j>0 && r==0) // if s is 1, then we are in the negative half of the wave, no need to update the period. it has already been updated
				    j = j - 1;
				else if(j<`NUM_PERIODS-1 && r==1)
				    j = j + 1;
			end

			// ------------------------------------------------------------------
    			// Write to ADDR_WG_DRV_INT_REG01 (clear the first address interrupt)
    			// ------------------------------------------------------------------
    			assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_INT_REG01 + (`WAVEGEN_1_ADDR_BASE * `DUT_IF.wg_drv_sel)); wr_data[0] == 8'h03;});
    			`nnc_info("SOC_TEST", "Clear the first address interrupt", NNC_LOW)
    			`WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
		end
		else if (top_test_cfg.rd_data[1] === 8'h21) begin //first address is at the second half of the wave; now load the first half

			if (j>0 && r==0)
			    j = j - 1; //the second interrupt is just for updating the interrupt addresses and not for updating periods; hence j needs to go back
			else if(j<`NUM_PERIODS-1 && r==1)
			    j = j + 1;

			// --------------------------------------------------------
    			// Write burst starting from ADDR_WG_DRV_INT_REG02
    			// --------------------------------------------------------
    			assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_INT_REG02 + (`WAVEGEN_1_ADDR_BASE * `DUT_IF.wg_drv_sel)); no_of_bytes == 2; wr_data[0] == 8'h20; wr_data[1] == 8'h01;});
    			`nnc_info("SOC_TEST", "Configure interrupt register", NNC_LOW)//interrupt register set as first address 1; second address 32
    			`WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

			// --------------------------------------------------------
    			// Write to ADDR_WG_DRV_INT_REG01 (clear the interrupt)
    			// --------------------------------------------------------
    			assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_INT_REG01 + (`WAVEGEN_1_ADDR_BASE * `DUT_IF.wg_drv_sel)); wr_data[0] == 8'h03;});
    			`nnc_info("SOC_TEST", "Clear the first address interrupt", NNC_LOW)
    			`WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
		end

		if (j<`NUM_PERIODS-1 && r==0) // we are increasing frequency 
		    j = j + 1;
		else if (j>=`NUM_PERIODS-1 && r==0) begin
		    j = j - 1;
		    r = 1;
		end
		else begin
		    if (j>0) begin // now we are decreasing frequency
			j = j - 1;
		    end
		    else if (j==0) begin
			j = j + 1;
			r = 0;
		    end
		end

	    end
	  end
	//end
    end

  endtask

  // ------------------------------
  // Declare the report_phase task
  // ------------------------------
  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction

endclass : `TESTNAME
