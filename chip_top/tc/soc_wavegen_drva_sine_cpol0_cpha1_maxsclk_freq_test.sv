/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_wavegen_drva_sine_test_cpol1_cpha0_maxsclk_freq.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_wavegen_drva_sine_test_cpol1_cpha0_maxsclk_freq                                             
// Designer	: ophina@nanochap.com                                                                 
// Date		: 18-03-2024                                                                   
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_wavegen_drva_sine_test_cpol1_cpha0_maxsclk_freq
`define TESTCFG soc_wavegen_drva_sine_test_cpol1_cpha0_maxsclk_freq_cfg

class `TESTCFG extends soc_wavegen_drva_sine_test_cfg;

  `nnc_object_utils(`TESTCFG)

  // ===============================================
  // Adding your new varialbles in config test
  // -----------------------------------------------

  //rand logic [7:0] wr_data[256];
  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_wavegen_drva_sine_test_cpol1_cpha0_maxsclk_freq_cfg");
    super.new(name);
    
  endfunction: new

  // ===============================================
  // Adding constraints of randomization
  // -----------------------------------------------
  constraint c_spi_sclk_freq          { spi_sclk_freq == `SPI_MAX_FREQ;} // 14MHZ, interms of clock period 71.4ns
  constraint c_spi_sclk_jitter        { spi_sclk_jitter == 0;} 
  constraint c_tch                    { tch == 40; }   ///minimum TCH=28.56ns, interms of percentage it's calculated as 40ns((28.56/71.4)*100)
 // Selections for CPOL and CPHA
  constraint c_spimode_sel            { soft spimode_sel inside {[1:1]};} //spimode_sel ==0 {cpol=0 , cpha = 0}; spimode_sel ==1 {cpol=0 , cpha = 1}; spimode_sel ==2 {cpol=1 , cpha = 0}; spimode_sel ==3 {cpol=1, cpha = 1}    
 
  // -----------------------------------------------
  // End of adding constraints of randomization
  // ===============================================

endclass : `TESTCFG

// ===============================================
// Main Testcase is defined
// -----------------------------------------------
class `TESTNAME extends soc_wavegen_drva_sine_test;
   
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
    
    `DUT_IF.spi_sclk_freq = top_test_cfg.spi_sclk_freq;

    // Set Jitter for SCK
    `DUT_IF.spi_sclk_jitter  = top_test_cfg.spi_sclk_jitter;

    //Set tch
    `DUT_IF.tch      = top_test_cfg.tch; 
 
  // Select Polarity of CLK 
    `DUT_IF.spimode_sel = top_test_cfg.spimode_sel;
  
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

    `nnc_info("SOC_TEST", "soc_wavegen_drva_sine_test_cpol1_cpha0_maxsclk_freq start", NNC_LOW)

    // ==================================================================================
    // Please add your code of your test here
    // ----------------------------------------------------------------------------------
      `nnc_info("SOC_TEST", "soc_wavegen_drva_sine_test_cpol1_cpha0_maxsclk_freq end now", NNC_LOW)

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
