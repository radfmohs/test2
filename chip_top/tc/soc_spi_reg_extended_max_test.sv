/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_spi_reg_extended_max_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_spi_reg_extended_max_test                                             
// Designer	: ddang@nanochap.com                                                                 
// Date		: 18-03-2024                                                                     
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_spi_reg_extended_max_test
`define TESTCFG soc_spi_reg_extended_max_test_cfg

class `TESTCFG extends soc_spi_reg_test_cfg;

  `nnc_object_utils(`TESTCFG)

  // ===============================================
  // Adding your new varialbles in config test
  // -----------------------------------------------

  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_spi_reg_extended_max_test_cfg");
    super.new(name);
  endfunction: new

  // ===============================================
  // Adding constraints of randomization
  // -----------------------------------------------


  constraint c_ext_clk_en             {  ext_clk_en == 0;} 

  constraint c_spi_sclk_freq          {  spi_sclk_freq == `SPI_MAX_FREQ;} //14MHZ max SPI Clk
  constraint c_spi_sclk_jitter        {  spi_sclk_jitter == 1;} // min 1

  constraint c_tcssc                  {  tcssc == `SPI_MIN_TCSSO;}   // ~tCSSO 
  constraint c_tsccs                  {  tsccs == `SPI_MIN_TCSH1;}   // ~tCSH1 
  constraint c_tcsh                   {  tcsh  == `SPI_MIN_TCSPW;}   //  ~tCSPW 
  constraint c_tch                    {  tch inside {60, 40}; }      // percent 

  constraint c_hfosc_fixed_gnd_en     { solve ext_clk_en before hfosc_fixed_gnd_en; 
                                        (mult_chip_same_clk_en == 1'b1) -> hfosc_fixed_gnd_en == 1'b0; 
                                        (mult_chip_same_clk_en == 1'b0) -> hfosc_fixed_gnd_en == ext_clk_en;
                                      }

  constraint c_ext_hfosc_fixed_gnd_en { 
                                        solve ext_clk_en before ext_hfosc_fixed_gnd_en;
                                        (mult_chip_same_clk_en == 1'b1) -> ext_hfosc_fixed_gnd_en == 1'b1;
                                        (mult_chip_same_clk_en == 1'b0) -> ext_hfosc_fixed_gnd_en == !ext_clk_en; 
                                      }



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
    `nnc_top.set_timeout(5s);
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

    `DUT_IF.spi_sclk_jitter  = top_test_cfg.spi_sclk_jitter;    
    `DUT_IF.spi_sclk_freq = top_test_cfg.spi_sclk_freq;
    `DUT_IF.tch      = top_test_cfg.tch;
    `DUT_IF.tcsh     = top_test_cfg.tcsh;
    `DUT_IF.tsccs    = top_test_cfg.tsccs;
    `DUT_IF.tcssc    = top_test_cfg.tcssc;
    `DUT_IF.tch      = top_test_cfg.tch; 

    `DUT_IF.hfosc_fixed_gnd_en = top_test_cfg.hfosc_fixed_gnd_en;
    `DUT_IF.hfosc_fixed_gnd_en = top_test_cfg.hfosc_fixed_gnd_en;

    phase.drop_objection(this);
  endtask : pre_reset_phase

  // -----------------------------------------
  // Declare the main_phase task of your test
  // -----------------------------------------
  virtual task main_phase(nnc_phase phase);
    phase.raise_objection(this);

    super.main_phase(phase);

    `nnc_info("SOC_TEST", "soc_spi_reg_extended_max_test start", NNC_LOW)

    // ===============================================================================================
    // Please add your code of your test here
    // -----------------------------------------------------------------------------------------------

    // End of test and add any needed delay time 
    // --------------------------------------------------------
    `nnc_info("SOC_TEST", "soc_spi_reg_extended_max_test end now", NNC_LOW)

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
