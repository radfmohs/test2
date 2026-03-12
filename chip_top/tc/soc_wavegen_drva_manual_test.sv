/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_wavegen_drva_manual_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_wavegen_drva_manual_test                                             
// Designer	: ophina@nanochap.com                                                                 
// Date		: 18-03-2024                                                                   
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

//***************************************************************************************
// NOTE : This test intention is to verify the manual mode feature. In this mode, 
//        user need to control the waveform generation using SPI registers directly
//***************************************************************************************

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_wavegen_drva_manual_test
`define TESTCFG soc_wavegen_drva_manual_test_cfg

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
 
  rand logic       dac_bit_len_sel;//1'b0:8-bits; 1'b1:12-bits (only 12 bits supported for manual)
  rand logic       auto_man;//1'b0:auto; 1'b1:manual
  rand logic [7:0] dac0_data_l;
  rand logic [3:0] dac0_data_h;
  rand logic [2:0] dac0_msb_sel;
  rand logic [7:0] dac1_data_l;
  rand logic [3:0] dac1_data_h;
  rand logic [2:0] dac1_msb_sel;
  rand logic       drv0_pull_a;
  rand logic       drv0_pull_b;
  rand logic       drv1_pull_a;
  rand logic       drv1_pull_b;
  rand logic       drv0_source_a;
  rand logic       drv0_source_b;
  rand logic       drv1_source_a;
  rand logic       drv1_source_b;
  rand logic       drv0_en;
  rand logic       drv1_en;

  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_wavegen_drva_manual_test_cfg");
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

  // No of bytes in a burst
  constraint c_no_of_bytes     { soft no_of_bytes == 2; }

  // pads values
  constraint c_pads            { soft pads == 8'h00; }

  // mask values
  constraint c_mask            { soft mask == 8'hff; }

  // altf_sel
  //constraint c_altf_sel    { soft altf_sel == 2'b00; }

  //auto_man
  constraint c_auto_man        { auto_man == 1'b1;}

  //dac_bit_len_sel
  //constraint c_dac_bit_len_sel { dac_bit_len_sel == 1'b1;}//already manual mode consider 12-bit only

  //dac0_data_h
  constraint c_dac0_data_h     { dac0_data_h != 0;}

  //dac1_data_h
  constraint c_dac1_data_h     { dac1_data_h != 0;}

  //dac0_msb_sel
  constraint c_dac0_msb_sel    { dac0_msb_sel inside {[0:4]};}

  //dac1_msb_sel
  constraint c_dac1_msb_sel    { dac1_msb_sel inside {[0:4]};}

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

    `nnc_info("SOC_TEST", "soc_wavegen_drva_manual_test start", NNC_LOW)

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

    // ------------------------------------------------------------
    // Write burst starting from SOC_ADDR_WG_DRV_CTRL1_REG for drv0
    // ------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ADDR_WG_DRV_CTRL1_REG; no_of_bytes == 2; wr_data[0] == {1'b0, top_test_cfg.dac0_msb_sel, top_test_cfg.dac0_data_h}; wr_data[1] == top_test_cfg.dac0_data_l;});
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // ------------------------------------------------------------
    // Write burst starting from SOC_ADDR_WG_DRV_CTRL1_REG for drv1
    // ------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CTRL1_REG + `WAVEGEN_1_ADDR_BASE); no_of_bytes == 2; wr_data[0] == {1'b0, top_test_cfg.dac1_msb_sel, top_test_cfg.dac1_data_h}; wr_data[1] == top_test_cfg.dac1_data_l;});
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

`ifdef BEHAVIORAL 
    for(int i = 0; i < 40; i++) begin
`else
    for(int i = 0; i < 10; i++) begin
`endif
    // --------------------------------------------------------
    // Write to SOC_ADDR_WG_DRV_CTRL0_REG for drv0
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ADDR_WG_DRV_CTRL0_REG; drv0_pull_b == 1'b1; drv0_source_a == 1'b1; drv0_pull_a == 1'b0; drv0_source_b == 1'b0;
    wr_data[0] == {2'b0, top_test_cfg.dac_bit_len_sel,top_test_cfg.auto_man, top_test_cfg.drv0_pull_b, top_test_cfg.drv0_pull_a, top_test_cfg.drv0_source_b, top_test_cfg.drv0_source_a};});
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // --------------------------------------------------------
    // Write to SOC_ADDR_WG_DRV_CTRL0_REG for drv1
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CTRL0_REG + `WAVEGEN_1_ADDR_BASE); drv1_pull_b == 1'b1; drv1_source_a == 1'b1; drv1_pull_a == 1'b0; drv1_source_b == 1'b0;
    wr_data[0] == {2'b0, top_test_cfg.dac_bit_len_sel,top_test_cfg.auto_man, top_test_cfg.drv1_pull_b, top_test_cfg.drv1_pull_a, top_test_cfg.drv1_source_b, top_test_cfg.drv1_source_a};});
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    if(i === 0) begin
    	`nnc_info("SOC_TEST", $sformatf("enabling chip_0 wavegen sb now"), NNC_LOW)
    	`WAVEGEN_SCB_DRV_0_EN = 1'b1;
    	`WAVEGEN_SCB_DRV_1_EN = 1'b1;
    end
    #5ms;

    // --------------------------------------------------------
    // Write to SOC_ADDR_WG_DRV_CTRL0_REG for drv0
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ADDR_WG_DRV_CTRL0_REG; drv0_pull_b == 1'b0; drv0_source_a == 1'b0; drv0_pull_a == 1'b1; drv0_source_b == 1'b1;
    wr_data[0] == {2'b0, top_test_cfg.dac_bit_len_sel,top_test_cfg.auto_man, top_test_cfg.drv0_pull_b, top_test_cfg.drv0_pull_a, top_test_cfg.drv0_source_b, top_test_cfg.drv0_source_a};});
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // --------------------------------------------------------
    // Write to SOC_ADDR_WG_DRV_CTRL0_REG for drv1
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CTRL0_REG + `WAVEGEN_1_ADDR_BASE); drv1_pull_b == 1'b0; drv1_source_a == 1'b0; drv1_pull_a == 1'b1; drv1_source_b == 1'b1;
    wr_data[0] == {2'b0, top_test_cfg.dac_bit_len_sel,top_test_cfg.auto_man, top_test_cfg.drv1_pull_b, top_test_cfg.drv1_pull_a, top_test_cfg.drv1_source_b, top_test_cfg.drv1_source_a};});
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    #4ms;

    // --------------------------------------------------------
    // Write to SOC_ADDR_WG_DRV_CTRL0_REG for drv0
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ADDR_WG_DRV_CTRL0_REG; drv0_pull_b == 1'b0; drv0_source_a == 1'b0; drv0_pull_a == 1'b0; drv0_source_b == 1'b0;
    wr_data[0] == {2'b0, top_test_cfg.dac_bit_len_sel,top_test_cfg.auto_man, top_test_cfg.drv0_pull_b, top_test_cfg.drv0_pull_a, top_test_cfg.drv0_source_b, top_test_cfg.drv0_source_a};});
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // --------------------------------------------------------
    // Write to SOC_ADDR_WG_DRV_CTRL0_REG for drv1
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CTRL0_REG + `WAVEGEN_1_ADDR_BASE); drv1_pull_b == 1'b0; drv1_source_a == 1'b0; drv1_pull_a == 1'b0; drv1_source_b == 1'b0;
    wr_data[0] == {2'b0, top_test_cfg.dac_bit_len_sel,top_test_cfg.auto_man, top_test_cfg.drv1_pull_b, top_test_cfg.drv1_pull_a, top_test_cfg.drv1_source_b, top_test_cfg.drv1_source_a};});
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // ------------------------------------------------------------
    // Write burst starting from SOC_ADDR_WG_DRV_CTRL1_REG for drv0
    // ------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ADDR_WG_DRV_CTRL1_REG; no_of_bytes == 2; wr_data[0] == {1'b0, top_test_cfg.dac0_msb_sel, top_test_cfg.dac0_data_h}; wr_data[1] == top_test_cfg.dac0_data_l;});
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // ------------------------------------------------------------
    // Write burst starting from SOC_ADDR_WG_DRV_CTRL1_REG for drv1
    // ------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CTRL1_REG + `WAVEGEN_1_ADDR_BASE); no_of_bytes == 2; wr_data[0] == {1'b0, top_test_cfg.dac1_msb_sel, top_test_cfg.dac1_data_h}; wr_data[1] == top_test_cfg.dac1_data_l;});
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    end
    // --------------------------------------------------------
    // End of test and add any needed delay time
    // --------------------------------------------------------
    #10ms;
    `nnc_info("SOC_TEST", "soc_wavegen_drva_manual_test end now", NNC_LOW)

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
