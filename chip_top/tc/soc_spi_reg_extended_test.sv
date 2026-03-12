/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_spi_reg_extended_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_spi_reg_extended_test                                             
// Designer	: ddang@nanochap.com                                                                 
// Date		: 18-03-2024                                                                     
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_spi_reg_extended_test
`define TESTCFG soc_spi_reg_extended_test_cfg

class `TESTCFG extends soc_spi_reg_test_cfg;

  `nnc_object_utils(`TESTCFG)

  // ===============================================
  // Adding your new varialbles in config test
  // -----------------------------------------------

  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_spi_reg_extended_test_cfg");
    super.new(name);
  endfunction: new

  // ===============================================
  // Adding constraints of randomization
  // -----------------------------------------------

  constraint c_ext_clk_en             { soft ext_clk_en == 0;}
  constraint c_pclk_sel               { soft pclk_sel == 1;}
  constraint c_spi_sclk_freq          { soft spi_sclk_freq == 5559;}
  constraint c_spi_sclk_jitter        { soft spi_sclk_jitter == 4;}

  constraint c_tcssc                  { soft tcssc == 1350;}   // ~tCSSO (Min 20ns)
  constraint c_tsccs                  { soft tsccs == 653;}   // ~tCSH1 (Min 20ns)
  constraint c_tcsh                   { soft tcsh  == 3912;}   // ~tCSPW (Min 20ns)
  constraint c_tdist                  { soft tdist inside {[0:0]};}        // percent : tdist * (Period_SCK/2 - 10):
  constraint c_tch                    { soft tch == 87; }      // percent : tch >= 20ns, tCL >= 20ns 

  // -----------------------------------------------
  // End of adding constraints of randomization
  // ===============================================

endclass : `TESTCFG

// ===============================================
// Main Testcase is defined
// -----------------------------------------------
class `TESTNAME extends soc_spi_reg_test;
   
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
  // Declare the end_of_elaboration_phase function 
  // -----------------------------------------
  function void end_of_elaboration_phase(nnc_phase phase);
    `nnc_info("end_of_elaboration_phase", "Entered...",NNC_HIGH);
    super.end_of_elaboration_phase(phase);
    `nnc_info("end_of_elaboration_phase", "Exiting...",NNC_HIGH)
  endfunction

  // -----------------------------------------
  // Declare the pre_reset_phase task 
  // -----------------------------------------
  virtual task pre_reset_phase(nnc_phase phase);
    phase.raise_objection(this);

    super.pre_reset_phase(phase);

    assert(top_test_cfg.randomize());

    // Enable reset waiting
    `DUT_IF.wait_reset_en = top_test_cfg.wait_reset_en;

    // Set PCLK Clocks
    `DUT_IF.pclk_sel = top_test_cfg.pclk_sel;

    // Set SCLK clock
    `DUT_IF.spi_sclk_freq = top_test_cfg.spi_sclk_freq;

    // Set Flash BIST clock
    `DUT_IF.bistm_freq = top_test_cfg.bistm_freq;

    // Select Operation mode for SOC 
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;

    // Select ALTF mode for SOC PIN Configuration 
    `DUT_IF.altf_sel = top_test_cfg.altf_sel;

    // Set Jitter for PCLK 
    `DUT_IF.spi_clk_jitter = top_test_cfg.spi_clk_jitter;

    // Set Jitter for SCK
    `DUT_IF.spi_sclk_jitter  = top_test_cfg.spi_sclk_jitter;

    // Select internal/external clock sources
    `DUT_IF.ext_clk_en = top_test_cfg.ext_clk_en;			// 1: external EXT_300KHZ and EXT_32KHZ will be driven to SOC from model

    // 2Mhz jitter clock for both internal/external clock
    `DUT_IF.hfosc_jitter = top_test_cfg.hfosc_jitter; 

    `DUT_IF.hfosc_variation = top_test_cfg.hfosc_variation;

    // enable to fix 1'b0 to internal clk
    `DUT_IF.hfosc_fixed_gnd_en = top_test_cfg.hfosc_fixed_gnd_en;

    // enable to fix 1'b0 to ext clk
    `DUT_IF.ext_hfosc_fixed_gnd_en = top_test_cfg.ext_hfosc_fixed_gnd_en;

    `DUT_IF.fault_stuck0_clk_en = top_test_cfg.fault_stuck0_clk_en;     // 1: internal 32KHZ and 300KHZ will be LOW (can used when we set ext_clk_en)

    `DUT_IF.tcssc    = top_test_cfg.tcssc;
    `DUT_IF.tsccs    = top_test_cfg.tsccs;
    `DUT_IF.tcsh     = top_test_cfg.tcsh;
    `DUT_IF.tdist    = top_test_cfg.tdist;  
    `DUT_IF.tch      = top_test_cfg.tch; 

    `DUT_IF.config_in_base_test_en = top_test_cfg.config_in_base_test_en;

    `DUT_IF.wg_drv_sel = top_test_cfg.wg_drv_sel;

    `DUT_IF.hlf_wave_per = top_test_cfg.hlf_wave_per;

    `DUT_IF.dont_check_conf_first_en = top_test_cfg.dont_check_conf_first_en;

    `DUT_IF.A2D_comp_sel = top_test_cfg.A2D_comp_sel;

    `DUT_IF.altf_gpio_sel = 2'b00;

    `DUT_IF.TCK_SEL = top_test_cfg.TCK_SEL;

    `DUT_IF.bist_vpp_pin_en = top_test_cfg.bist_vpp_pin_en;

    `DUT_IF.pinmux_mode = top_test_cfg.pinmux_mode;

    `DUT_IF.mult_chip_en = top_test_cfg.mult_chip_en;
    `DUT_IF.A2D_comp0_in = top_test_cfg.A2D_comp0_in;
    `DUT_IF.A2D_comp1_in = top_test_cfg.A2D_comp1_in;

    phase.drop_objection(this);
  endtask : pre_reset_phase

  // -----------------------------------------
  // Declare the main_phase task of your test
  // -----------------------------------------
  virtual task main_phase(nnc_phase phase);
    phase.raise_objection(this);

    super.main_phase(phase);

    `nnc_info("SOC_TEST", "soc_spi_reg_extended_test start", NNC_LOW)

    // ===============================================================================================
    // Please add your code of your test here
    // -----------------------------------------------------------------------------------------------

    // End of test and add any needed delay time 
    // --------------------------------------------------------
    `nnc_info("SOC_TEST", "soc_spi_reg_extended_test end now", NNC_LOW)

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
