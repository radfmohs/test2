/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_mult_chip_wavegen_drva_pulse_clksel_1_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_mult_chip_wavegen_drva_pulse_clksel_1_test                                             
// Designer	: ddang@nanochap.com                                                                 
// Date		: 20-08-2024                                                                   
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

//***************************************************************************************
// NOTE : This test is extended from soc_mult_chip_wavegen_drva_pulse_test. 
//        The test is intented to generate pulse wave for driver1 & driver2 in multiple
//        devices. This test constraints o_clk_sel to 1 specifically to check this option
//        in multichip connection. Below 2 cases are considered with setting o_clk_sel 1:
//        1. Master chip ext_clk_sel = 0, Slave chip ext_clk_sel = 1 : This option drives
//        the GPIO_9 clock output of Master chip from internal oscillator. The GPIO_9  
//        clock output from master is fed as the external clock of Slave chip.
//        2. Master chip ext_clk_sel = 1, Slave chip ext_clk_sel = 1 : This option drives 
//        the GPIO_9 clock output of Master chip from external oscillator. The GPIO_9 
//        clock output from master is fed as the external clock of Slave chip.
//***************************************************************************************

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME_BASE soc_mult_chip_wavegen_drva_pulse_test
`define TESTCFG_BASE soc_mult_chip_wavegen_drva_pulse_test_cfg
`define TESTNAME soc_mult_chip_wavegen_drva_pulse_clksel_1_test
`define TESTCFG soc_mult_chip_wavegen_drva_pulse_clksel_1_test_cfg


class `TESTCFG extends `TESTCFG_BASE;

  `nnc_object_utils(`TESTCFG)

  // ===============================================
  // Adding your new varialbles in config test
  // -----------------------------------------------

  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_mult_chip_wavegen_drva_pulse_clksel_1_test_cfg");
    super.new(name);
    
  endfunction: new

  // ===============================================
  // Adding constraints of randomization
  // -----------------------------------------------

  constraint c_mult_chip_typ          { mult_chip_typ inside {[1:2]}; }

  // -----------------------------------------------
  // End of adding constraints of randomization
  // ===============================================

endclass : `TESTCFG

// ===============================================
// Main Testcase is defined
// -----------------------------------------------
class `TESTNAME extends `TESTNAME_BASE;
   
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
    `DUT_IF.mult_chip_en = top_test_cfg.mult_chip_en;
    `DUT_IF.mult_chip_same_clk_en = top_test_cfg.mult_chip_same_clk_en;
    `DUT_IF.swap_sdf_en = top_test_cfg.swap_sdf_en;
    `DUT_IF.ext_clk_en = top_test_cfg.ext_clk_en;
    `DUT_IF.hfosc_fixed_gnd_en = top_test_cfg.hfosc_fixed_gnd_en;
    `DUT_IF.ext_hfosc_fixed_gnd_en = top_test_cfg.ext_hfosc_fixed_gnd_en;
    `DUT_IF.spi_o_clk_sel = top_test_cfg.spi_o_clk_sel;
    `DUT_IF.mult_chip_typ = top_test_cfg.mult_chip_typ;

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
/*
    assert(top_test_cfg.randomize() with {ext_clk_en == 1'b1; mult_chip_en == 1'b1; hfosc_fixed_gnd_en == 1'b0; ext_hfosc_fixed_gnd_en == 1'b1;});

    `DUT_IF.mult_chip_en = top_test_cfg.mult_chip_en;

    // Select internal/external clock sources
    `DUT_IF.ext_clk_en = top_test_cfg.ext_clk_en;

    // enable to fix 1'b0 to internal clk
    `DUT_IF.hfosc_fixed_gnd_en = top_test_cfg.hfosc_fixed_gnd_en;

    // enable to fix 1'b0 to ext clk
    `DUT_IF.ext_hfosc_fixed_gnd_en = top_test_cfg.ext_hfosc_fixed_gnd_en;
*/
    `nnc_info("SOC_TEST", "soc_mult_chip_wavegen_drva_arbitrary_interrupt_test start", NNC_LOW)

    super.main_phase(phase);

    phase.drop_objection(this);
  endtask: main_phase

  // ------------------------------
  // Declare the report_phase task
  // ------------------------------
  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction

endclass : `TESTNAME
