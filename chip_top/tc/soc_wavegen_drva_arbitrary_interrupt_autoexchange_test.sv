/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_wavegen_drva_arbitrary_interrupt_autoexchange_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_wavegen_drva_arbitrary_interrupt_autoexchange_test                                             
// Designer	: ophina@nanochap.com                                                                 
// Date		: 18-03-2024                                                                   
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

//*************************************************************************************************
// NOTE : The test is intented to generate arbitrary wave for driver1 & driver2 using interrupt. 
//        So this test enables interrupt and load data on interrupt to generate arbitrary waveform. 
//        Also this test enables auto address exchange feature additionally, so auto address 
//        swapping happens during 1st address interrupt clear.
//*************************************************************************************************

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_wavegen_drva_arbitrary_interrupt_autoexchange_test
`define TESTCFG soc_wavegen_drva_arbitrary_interrupt_autoexchange_test_cfg

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
  logic [11:0]     half_period_limit;
  rand logic [11:0] half_period;
  logic [31:0]     hlf_wave_lim; // number of clocks for positive half wave
  logic [31:0]     neg_hlf_wave_lim; // number of clocks for negative half wave
  logic [15:0]     rest_lim; // number of clocks for each rest period
  logic [31:0]     silent_lim; // number of clocks for each silent period
  rand logic [1:0] preload_sel;
  rand logic [2:0] wg_drv_sel;
  rand logic       neg_ena;
  rand logic       pos_dis;
  rand logic [2:0] points_sel;
  rand logic [2:0] waveform_sel;
  rand logic       load_points_sel;
  rand logic       pos_neg_diff_sel;
       logic       LOAD_POINTS;
       logic [7:0] NO_OF_POINTS;
       logic [7:0] NO_OF_LOAD_POINTS;
  rand logic [31:0] hlf_wave_per;//us
  rand logic        manual_auto_intclr;//1'b0: manual clear int sts by writing to local int sts reg; 1'b1: automatic clear int sts upon reading general int sts reg;
  rand logic        auto_intclr_loc_gen_sel;//1'b0: selects local register to perform automatic int clear; 1'b1: selects general register to perform automatic int clear;
  rand logic        pulse_level_intb;//1'b0: selects level interrupt; 1'b1: selects pulse interrupt;
  rand logic        int_active_level_high_or_low;//1'b0: Active low; 1'b1: Active high;
  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_wavegen_drva_arbitrary_interrupt_autoexchange_test_cfg");
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

  //pclk_div[2:0]
  //constraint c_pclk_sel    { soft pclk_sel inside {[0:6]};}

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

  // only 2 driver A's
  constraint c_wg_drv_sel      { soft wg_drv_sel inside {[0:1]}; }

  //neg_ena
  constraint c_neg_ena         { neg_ena == 1'b1;}

  //pos_dis
  constraint c_pos_dis         { pos_dis == 1'b0;}

  //points_sel
  constraint c_points_sel      { points_sel inside {0,0};}

  //waveform_sel
  constraint c_waveform_sel    { waveform_sel inside {[0:0]};}

  //load_points_sel
  constraint c_load_points_sel { load_points_sel == 1'b1;}

  //pos_neg_diff_sel
  constraint c_pos_neg_diff_sel { pos_neg_diff_sel == 1'b0;}

  //manual_auto_intclr
  //constraint c_manual_auto_intclr { manual_auto_intclr == 1; }

  //auto_intclr_loc_gen_sel
  //constraint c_auto_intclr_loc_gen_sel { auto_intclr_loc_gen_sel == 1; }

  //pulse_level_intb
  constraint c_pulse_level_intb   { pulse_level_intb == 0; }//only level INTB considered

  //int_active_level_high_or_low
  //constraint c_int_active_level_low_or_high  { int_active_level_high_or_low == 1; }

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

    assert(top_test_cfg.randomize() with {
    /*(`DUT_IF.pclk_sel == 0)  -> hlf_wave_per inside {[300:5000]};
    (`DUT_IF.pclk_sel == 1)  -> hlf_wave_per inside {[400:5000]};
    (`DUT_IF.pclk_sel == 2)  -> hlf_wave_per inside {[400:5000]};
    (`DUT_IF.pclk_sel == 3)  -> hlf_wave_per inside {[500:5000]};
    (`DUT_IF.pclk_sel == 4)  -> hlf_wave_per inside {[500:5000]};
    (`DUT_IF.pclk_sel == 5)  -> hlf_wave_per inside {[1000:5000]};
    (`DUT_IF.pclk_sel == 6)  -> hlf_wave_per inside {[2000:5000]};*/
    hlf_wave_per inside {[4000:5000]};
    });

    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;

    // Changed SCLK_jitter, must update 5 constraints
    `DUT_IF.spi_sclk_jitter  = top_test_cfg.spi_sclk_jitter;
    `DUT_IF.spi_sclk_freq = top_test_cfg.spi_sclk_freq;
    `DUT_IF.tch      = top_test_cfg.tch;
    `DUT_IF.tcsh     = top_test_cfg.tcsh;
    `DUT_IF.tsccs    = top_test_cfg.tsccs;

    //`DUT_IF.pclk_sel = top_test_cfg.pclk_sel;
    `DUT_IF.hfosc_jitter = top_test_cfg.hfosc_jitter;
    `DUT_IF.hfosc_variation = top_test_cfg.hfosc_variation;
    `DUT_IF.hlf_wave_per = top_test_cfg.hlf_wave_per;
    //`DUT_IF.wg_drv_sel = top_test_cfg.wg_drv_sel;

    `DUT_IF.clear_intr_manual_or_auto = top_test_cfg.manual_auto_intclr;
    `DUT_IF.intr_length_slct_level_or_pulse = top_test_cfg.pulse_level_intb;
    `DUT_IF.int_active_level_high_or_low = top_test_cfg.int_active_level_high_or_low;

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

    `nnc_info("SOC_TEST", "soc_wavegen_drva_arbitrary_interrupt_autoexchange_test start", NNC_LOW)

    // ==================================================================================
    // Please add your code of your test here
    // ----------------------------------------------------------------------------------
    top_test_cfg.LOAD_POINTS = top_test_cfg.load_points_sel;

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
    else
	top_test_cfg.NO_OF_LOAD_POINTS = 128;

    `nnc_info("SOC_TEST", $sformatf("NO_OF_POINTS: %d, NO_OF_LOAD_POINTS: %d", top_test_cfg.NO_OF_POINTS, top_test_cfg.NO_OF_LOAD_POINTS), NNC_LOW)

    top_test_cfg.clk_freq = 8192 / (2**`DUT_IF.pclk_sel);
    top_test_cfg.half_period_limit = (top_test_cfg.NO_OF_POINTS * 1000) / top_test_cfg.clk_freq;

    //assert(top_test_cfg.randomize() with {half_period > top_test_cfg.half_period_limit;});
    //wavegen_calc_clock_num(clk_freq (KHz), rest_t (us), silent_t (us), hlf_wave_per (us), neg_hlf_wave_per (us))
    wavegen_calc_clock_num(top_test_cfg.clk_freq, 0, 0, `DUT_IF.hlf_wave_per, `DUT_IF.hlf_wave_per);
    for(int i = 0; i < `WAVEGEN_NUM_OF_DRIVERS; i++) begin
    `DUT_IF.wg_hlf_wave0_lim[i] = top_test_cfg.hlf_wave_lim / top_test_cfg.NO_OF_POINTS;
    `DUT_IF.wg_neg_hlf_wave0_lim[i] = top_test_cfg.neg_hlf_wave_lim / top_test_cfg.NO_OF_POINTS;
    `DUT_IF.wg_rest_wave0_lim[i] = top_test_cfg.rest_lim;
    `DUT_IF.wg_silent_wave0_lim[i] = top_test_cfg.silent_lim;
    `nnc_info("SOC_TEST", $sformatf("Driver (%d) ******** WAVE ******** CLK_FREQ: %dKhz, HALF_PERIOD_LIMIT: %dus, HALF_PERIOD_TARGET: %dus, HALF_PERIOD_CLKS_PER_POINT: %d", i, top_test_cfg.clk_freq, top_test_cfg.half_period_limit, `DUT_IF.hlf_wave_per, `DUT_IF.wg_hlf_wave0_lim[i]), NNC_LOW)
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

    // -----------------------------------------------------------------------------------------------
    // Write to SOC_GENERAL_INT_CTRL_REG to select manual/auto interrupt clear & level/pulse interrupt
    // -----------------------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_GENERAL_INT_CTRL_REG; wr_data[0] == {5'b0, `DUT_IF.int_active_level_high_or_low, `DUT_IF.clear_intr_manual_or_auto, `DUT_IF.intr_length_slct_level_or_pulse};});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    if(`DUT_IF.clear_intr_manual_or_auto === 1)
	   `nnc_info("SOC_TEST", "Auto int clear selected!", NNC_LOW)
    else
	   `nnc_info("SOC_TEST", "Manual int clear selected!", NNC_LOW)
    if(`DUT_IF.intr_length_slct_level_or_pulse === 1)
	   `nnc_info("SOC_TEST", "Pulse INTB selected!", NNC_LOW)
    else
	   `nnc_info("SOC_TEST", "Level INTB selected!", NNC_LOW)

    wavegen_drv_config(`WAVEGEN_0_ADDR_BASE);
    wavegen_drv_config(`WAVEGEN_1_ADDR_BASE);

    `DUT_IF.wg_drv_sel = top_test_cfg.wg_drv_sel;// select which driver
    // --------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_INT_REG01
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_INT_REG01 + (`WAVEGEN_1_ADDR_BASE * `DUT_IF.wg_drv_sel)); no_of_bytes == 3; wr_data[0] == 8'h3f; wr_data[1] == 8'h00; wr_data[2] == 8'h09;});//auto_exchange bit[3]=1
    `nnc_info("SOC_TEST", "Configure interrupt register", NNC_LOW)//interrupt register set as first address 64; second address 127
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write to SOC_LEAD_OFF_INT_REG to disable lead off interrupt
    // --------------------------------------------------------
    //assert(top_test_cfg.randomize() with {reg_addr == `SOC_LEAD_OFF_INT_REG; wr_data[0] == 8'h00;});
    //`WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    if(`DUT_IF.int_active_level_high_or_low === 0) begin
	if(`SOC_TB.INTB !== 1)
	  `nnc_error("SOC_TEST", "Error! INTB not active low as expected!!")
	else
	  `nnc_info("SOC_TEST", "Active low INTB selected!", NNC_LOW)
    end
    else begin
	if(`SOC_TB.INTB !== 0)
	  `nnc_error("SOC_TEST", "Error! INTB not active high as expected!!")
	else
	   `nnc_info("SOC_TEST", "Active high INTB selected!", NNC_LOW)
    end

    #100us;//wait 1pclk before enabling driver after configuring int_reg

    fork
      pulse_INTB_active_high_check;
      pulse_INTB_active_low_check;
      level_INTB_active_high_check;
      level_INTB_active_low_check;
    join_none

    // --------------------------------------------------------
    // Write to ADDR_WG_DRV_CTRL_REG0
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CTRL_REG0 + (`WAVEGEN_1_ADDR_BASE * `DUT_IF.wg_drv_sel)); wr_data[0] == {top_test_cfg.pos_neg_diff_sel,top_test_cfg.LOAD_POINTS,top_test_cfg.waveform_sel,top_test_cfg.preload_sel,1'b1};});
    `nnc_info("SOC_TEST", "Enable driver using control register with user config values", NNC_LOW)
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    
    wavegen_drv_int_update;

    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    #1ms;
    `nnc_info("SOC_TEST", "soc_wavegen_drva_arbitrary_interrupt_autoexchange_test end now", NNC_LOW)

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
    // Write burst starting from ADDR_WG_DRV_REST_T_REG01
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_REST_T_REG01 + WG_BASE); no_of_bytes == 2;  wr_data[0] == `DUT_IF.wg_rest_wave0_lim[`DUT_IF.wg_drv_sel][15:8]; wr_data[1] == `DUT_IF.wg_rest_wave0_lim[`DUT_IF.wg_drv_sel][7:0];});
    `nnc_info("SOC_TEST", "Set rest period", NNC_LOW)//0x0000_0064 (100us)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_SILENT_T_REG01
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_SILENT_T_REG01 + WG_BASE); no_of_bytes == 3; wr_data[0] == `DUT_IF.wg_silent_wave0_lim[`DUT_IF.wg_drv_sel][23:16]; wr_data[1] == `DUT_IF.wg_silent_wave0_lim[`DUT_IF.wg_drv_sel][15:8]; wr_data[2] == `DUT_IF.wg_silent_wave0_lim[`DUT_IF.wg_drv_sel][7:0];});
    `nnc_info("SOC_TEST", "Set silent period", NNC_LOW)//0x0000_03E8 (1000us)
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
	assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_IN_WAVE_REG01 + WG_BASE); wr_data[0] == 8'hFF;});
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

  task wavegen_drv_int_update;
    int switch = 0;
    bit [1:0] drv_int_sts[2];
    top_test_cfg.rd_data=new[1];
    top_test_cfg.rd_data[0] = 0;

`ifdef BEHAVIORAL
    for(int n = 0; n < 30; n++) begin
`else
    for(int n = 0; n < 10; n++) begin
`endif
        if (n === 0) begin
	  if(`DUT_IF.int_active_level_high_or_low === 1)//active high
	  	wait(`SOC_TB.INTB === 1);
	  else//active low
		wait(`SOC_TB.INTB === 0);
	end
	else begin
	  if(`DUT_IF.int_active_level_high_or_low === 1)//active high
	  	@(posedge`SOC_TB.INTB);
	  else//active low
		@(negedge`SOC_TB.INTB);
	end

	`nnc_info("SOC_TEST", "WAVEGEN interrupt happenned ...", NNC_LOW)
	//for (int i=0; i<1; i++) begin //only 0th Driver A is working in this test case
	  if(`DUT_IF.clear_intr_manual_or_auto === 0) begin//if manual with local register access
	    `nnc_info("SOC_TEST", "Read interrupt sts from local register", NNC_LOW)
	    // ------------------------------------------------------------------------------
            // Read from ADDR_WG_DRV_INT_REG01 (check interrupt status)
            // ------------------------------------------------------------------------------
      	    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_INT_REG01 + (`WAVEGEN_1_ADDR_BASE * `DUT_IF.wg_drv_sel));});
      	    `RD_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data[0]);

	    if((top_test_cfg.rd_data[0][3:0] === {1'b1,`DUT_IF.wg_drv_sel}) && (top_test_cfg.rd_data[0][6] === 1'b1))//also check if interrupt & auto-swap in this block is enabled
	      drv_int_sts[`DUT_IF.wg_drv_sel] = top_test_cfg.rd_data[0][5:4];
	  end
	  else begin//if automatic; reading sts bit supposed to clear interrupt
	   if(top_test_cfg.auto_intclr_loc_gen_sel === 1) begin//if automatic with general register access
	    `nnc_info("SOC_TEST", "Automatically clear interrupt using general register!", NNC_LOW)
            // ------------------------------------------------------------------------------
            // Read from SOC_GENERAL_INT_STS_2_REG (check interrupt status)
            // ------------------------------------------------------------------------------
	    fork
	    begin
      	    assert(top_test_cfg.randomize() with {reg_addr == `SOC_GENERAL_INT_STS_2_REG;});
      	    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data[0]);
	    end
	    begin
	    //Make sure interrupt is cleared
	    if(`DUT_IF.int_active_level_high_or_low === 1)//active high
	    	wait(`SOC_TB.INTB === 0);
	    else//active low
		wait(`SOC_TB.INTB === 1);
	    `nnc_info("SOC_TEST", "WAVEGEN interrupt cleared!", NNC_LOW)
	    end
	    join

	    if(`DUT_IF.wg_drv_sel === 0)
	      drv_int_sts[`DUT_IF.wg_drv_sel] = top_test_cfg.rd_data[0][1:0];
	    else
	      drv_int_sts[`DUT_IF.wg_drv_sel] = top_test_cfg.rd_data[0][3:2];
	   end
	   else begin//if automatic with local register access
	    `nnc_info("SOC_TEST", "Automatically clear interrupt using local register!", NNC_LOW)
	    // ------------------------------------------------------------------------------
            // Read from ADDR_WG_DRV_INT_REG01 (check interrupt status)
            // ------------------------------------------------------------------------------
	    fork
	    begin
      	    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_INT_REG01 + (`WAVEGEN_1_ADDR_BASE * `DUT_IF.wg_drv_sel));});
      	    `RD_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data[0]);
	    end
	    begin
	    //Make sure interrupt is cleared
	    if(`DUT_IF.int_active_level_high_or_low === 1)//active high
	    	wait(`SOC_TB.INTB === 0);
	    else//active low
		wait(`SOC_TB.INTB === 1);
	    `nnc_info("SOC_TEST", "WAVEGEN interrupt cleared!", NNC_LOW)
	    end
	    join

	    if(top_test_cfg.rd_data[0][3:0] === {1'b1,`DUT_IF.wg_drv_sel})
	      drv_int_sts[`DUT_IF.wg_drv_sel] = top_test_cfg.rd_data[0][5:4];
	   end
          end
	  `nnc_info("SOC_TEST", $sformatf("Interrupt sts: %d", drv_int_sts[`DUT_IF.wg_drv_sel]), NNC_LOW)
	  // ------------------------------------------------------------------------------------------------------------------------------
    	  // Read burst starting from ADDR_WG_DRV_INT_REG02 (/read the interrupt registers to find the 1st & 2nd interrupt addresses)
    	  // ------------------------------------------------------------------------------------------------------------------------------
    	  assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_INT_REG02 + (`WAVEGEN_1_ADDR_BASE * `DUT_IF.wg_drv_sel)); no_of_bytes == 2;});
    	  `nnc_info("SOC_TEST", "Read 1st & 2nd interrupt address", NNC_LOW)
    	  `RD_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);

	  if (drv_int_sts[`DUT_IF.wg_drv_sel] !== 0) begin
		if((drv_int_sts[`DUT_IF.wg_drv_sel][1] === 1) & (drv_int_sts[`DUT_IF.wg_drv_sel][0] === 0)) begin
		    `nnc_info("SOC_TEST", $sformatf("Interrupt is in block no: %d", `DUT_IF.wg_drv_sel), NNC_LOW)
		    `nnc_error("SOC_TEST", $sformatf("Interrupt WARNING: Second address (underflow) interrupt has happenned at address: %h", top_test_cfg.rd_data[0]))
		    if(`DUT_IF.clear_intr_manual_or_auto === 0) begin//if manual with local register access
		      // ------------------------------------------------------------------
    		      // Write to ADDR_WG_DRV_INT_REG01 (clear the second address interrupt)
    		      // ------------------------------------------------------------------
    		      assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_INT_REG01 + (`WAVEGEN_1_ADDR_BASE * `DUT_IF.wg_drv_sel)); wr_data[0] == 8'h0d;});//auto_exchange bit[3]=1
    		      `nnc_info("SOC_TEST", "Clear the second address interrupt", NNC_LOW)
    		      `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);//hopefully this interrupt is never activated otherwise we have missed the chance to load the next half of data on time
		    end
		end
		if(drv_int_sts[`DUT_IF.wg_drv_sel][0] === 1) begin
		    `nnc_info("SOC_TEST", $sformatf("Interrupt is in block no: %d", `DUT_IF.wg_drv_sel), NNC_LOW)
		    `nnc_info("SOC_TEST", $sformatf("First address interrupt has happenned at address: %h", top_test_cfg.rd_data[1]), NNC_LOW)

		    if (top_test_cfg.rd_data[1] === 8'h00) begin //first address is at the second half of the wave; now load the first half
			// --------------------------------------------------------
    			// Write burst starting from ADDR_WG_DRV_INT_REG02 (set next address)
    			// --------------------------------------------------------
    			//assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_INT_REG02 + (`WAVEGEN_1_ADDR_BASE * `DUT_IF.wg_drv_sel)); no_of_bytes == 2; wr_data[0] == 8'h00; wr_data[1] == 8'h3f;});
    			//`nnc_info("SOC_TEST", "Configure interrupt register", NNC_LOW)//interrupt register set as first address 0; second address 63
    			//`WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);
			if(`DUT_IF.clear_intr_manual_or_auto === 0) begin//if manual with local register access
			  // --------------------------------------------------------
    			  // Write to ADDR_WG_DRV_INT_REG01 (clear the interrupt)
    			  // --------------------------------------------------------
			  fork
			  begin
    			  assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_INT_REG01 + (`WAVEGEN_1_ADDR_BASE * `DUT_IF.wg_drv_sel)); wr_data[0] == 8'h0b;});//auto_exchange bit[3]=1
    			  `nnc_info("SOC_TEST", "Clear the first address interrupt", NNC_LOW)
    			  `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
			  end
			  begin
			  //Make sure interrupt is cleared
			  if(`DUT_IF.int_active_level_high_or_low === 1)//active high
			  	wait(`SOC_TB.INTB === 0);
			  else//active low
			  	wait(`SOC_TB.INTB === 1);
			  `nnc_info("SOC_TEST", "WAVEGEN interrupt cleared!", NNC_LOW)
			  end
			  join
			end
			for (int j=64; j<128; j++) begin
			    // --------------------------------------------------------
    			    // Write to ADDR_WG_DRV_IN_WAVE_ADDR_REG0
    			    // --------------------------------------------------------
    			    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0 + (`WAVEGEN_1_ADDR_BASE * `DUT_IF.wg_drv_sel)); wr_data[0] == j;});
    			    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
			    // --------------------------------------------------------
    			    // Write to ADDR_WG_DRV_IN_WAVE_REG01
    			    // --------------------------------------------------------
			    if(switch === 1) begin
			    	assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_IN_WAVE_REG01 + (`WAVEGEN_1_ADDR_BASE * `DUT_IF.wg_drv_sel)); wr_data[0] == (8'hff - j + 8'h40);});
    			    	`WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
			    end
			    else begin
				assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_IN_WAVE_REG01 + (`WAVEGEN_1_ADDR_BASE * `DUT_IF.wg_drv_sel)); wr_data[0] == 8'hff;});
    			    	`WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
			    end
			end
		    end
		    else if (top_test_cfg.rd_data[1] === 8'h3f) begin //first address is at the first half of the wave; now load the second half
			// --------------------------------------------------------
    			// Write burst starting from ADDR_WG_DRV_INT_REG02 (set next address)
    			// --------------------------------------------------------
    			//assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_INT_REG02 + (`WAVEGEN_1_ADDR_BASE * `DUT_IF.wg_drv_sel)); no_of_bytes == 2; wr_data[0] == 8'h40; wr_data[1] == 8'h7f;});
    			//`nnc_info("SOC_TEST", "Configure interrupt register", NNC_LOW)//interrupt register set as first address 64; second address 127
    			//`WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);
			if(`DUT_IF.clear_intr_manual_or_auto === 0) begin//if manual with local register access
			  // --------------------------------------------------------
    			  // Write to ADDR_WG_DRV_INT_REG01 (clear the interrupt)
    			  // --------------------------------------------------------
			  fork
			  begin
    			  assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_INT_REG01 + (`WAVEGEN_1_ADDR_BASE * `DUT_IF.wg_drv_sel)); wr_data[0] == 8'h0b;});//auto_exchange bit[3]=1
    			  `nnc_info("SOC_TEST", "Clear the first address interrupt", NNC_LOW)
    			  `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
			  end
			  begin
			  //Make sure interrupt is cleared
			  if(`DUT_IF.int_active_level_high_or_low === 1)//active high
			  	wait(`SOC_TB.INTB === 0);
			  else//active low
			  	wait(`SOC_TB.INTB === 1);
			  `nnc_info("SOC_TEST", "WAVEGEN interrupt cleared!", NNC_LOW)
			  end
			  join
			end
			for (int j=0; j<64; j++) begin
			    // --------------------------------------------------------
    			    // Write to ADDR_WG_DRV_IN_WAVE_ADDR_REG0
    			    // --------------------------------------------------------
    			    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0 + (`WAVEGEN_1_ADDR_BASE * `DUT_IF.wg_drv_sel)); wr_data[0] == j;});
    			    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
			    // --------------------------------------------------------
    			    // Write to ADDR_WG_DRV_IN_WAVE_REG01
    			    // --------------------------------------------------------
			    if(switch === 0) begin
			    	assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_IN_WAVE_REG01 + (`WAVEGEN_1_ADDR_BASE * `DUT_IF.wg_drv_sel)); wr_data[0] == (8'hff - j);});
    			    	`WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
			    end
			    else begin
				assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_IN_WAVE_REG01 + (`WAVEGEN_1_ADDR_BASE * `DUT_IF.wg_drv_sel)); wr_data[0] == 8'hff;});
    			    	`WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
			    end
			end
			if(switch === 0)
			    switch = 1;
			else
			    switch = 0;
		    end
		end
	  end
    end
  endtask

  task pulse_INTB_active_high_check;
  begin
    forever @(posedge `SOC_TB.INTB) begin
      if((`DUT_IF.intr_length_slct_level_or_pulse === 1) && (`DUT_IF.int_active_level_high_or_low === 1)) begin//if active high pulse INTB is selected
	@(posedge `DUT_IF.sys_clk);
	@(negedge `DUT_IF.sys_clk);
        if(`SOC_TB.INTB !== 0)
    	  `nnc_error("SOC_TEST", "Error! pulse INTB more than 1 pclk!")
	else
	  `nnc_info("SOC_TEST", "pulse INTB is 1 pclk!", NNC_LOW)
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
        if(`SOC_TB.INTB !== 1)
    	  `nnc_error("SOC_TEST", "Error! pulse INTB more than 1 pclk!")
	else
	  `nnc_info("SOC_TEST", "pulse INTB is 1 pclk!", NNC_LOW)
      end 
    end
  end
  endtask

  task level_INTB_active_high_check;
  begin
    forever @(posedge `SOC_TB.INTB or negedge `SOC_TB.INTB) begin
      if((`DUT_IF.intr_length_slct_level_or_pulse === 0) && (`DUT_IF.int_active_level_high_or_low === 1)) begin//if active high level INTB is selected
        if(`SOC_TB.INTB !== `WG_DRIVER_TOP.wg_driver_top_inst.o_wg_driver_interrupt)
    	  `nnc_error("SOC_TEST", "Error! level INTB not expected!")
	else
	  `nnc_info("SOC_TEST", "level INTB is expected!", NNC_LOW)
      end 
    end
  end
  endtask

  task level_INTB_active_low_check;
  begin
    forever @(posedge `SOC_TB.INTB or negedge `SOC_TB.INTB) begin
      if((`DUT_IF.intr_length_slct_level_or_pulse === 0) && (`DUT_IF.int_active_level_high_or_low === 0)) begin//if active low level INTB is selected
        if(`SOC_TB.INTB !== ~(`WG_DRIVER_TOP.wg_driver_top_inst.o_wg_driver_interrupt))
    	  `nnc_error("SOC_TEST", "Error! level INTB not expected!")
	else
	  `nnc_info("SOC_TEST", "level INTB is expected!", NNC_LOW)
      end 
    end
  end
  endtask

  // ------------------------------
  // Declare the report_phase task
  // ------------------------------
  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction

endclass : `TESTNAME
