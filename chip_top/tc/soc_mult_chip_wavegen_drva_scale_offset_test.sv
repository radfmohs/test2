/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_mult_chip_wavegen_drva_scale_offset_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_mult_chip_wavegen_drva_scale_offset_test                                             
// Designer	: ddang@nanochap.com                                                                 
// Date		: 20-08-2024                                                                   
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

//***********************************************************************************************
// NOTE : This test is extended from soc_wavegen_drva_scale_offset_test. 
//        The test is intented to generate scaled up/down & offset added waves for 
//        driver1 & driver2 in multiple devices.
//        Three clock output options are used in this test during multichip connection:
//        1. o_CLK_SEL : 0, Master chip ext_clk_sel = 1, Slave chip ext_clk_sel = 1 : 
//        This option drives the GPIO_9 clock output of Master chip from internal oscillator. 
//        The GPIO_9 clock output from master is fed as the external clock of Master & Slave chips. 
//        2. o_CLK_SEL : 1, Master chip ext_clk_sel = 0, Slave chip ext_clk_sel = 1 : 
//        This option drives the GPIO_9 clock output of Master chip from internal oscillator.   
//        The GPIO_9 clock output from master is fed as the external clock of Slave chip.
//        3. o_CLK_SEL : 1, Master chip ext_clk_sel = 1, Slave chip ext_clk_sel = 1 :  
//        This option drives the GPIO_9 clock output of Master chip from external oscillator.  
//        The GPIO_9 clock output from master is fed as the external clock of Slave chip.
//***********************************************************************************************

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME_BASE soc_wavegen_drva_scale_offset_test
`define TESTCFG_BASE soc_wavegen_drva_scale_offset_test_cfg
`define TESTNAME soc_mult_chip_wavegen_drva_scale_offset_test
`define TESTCFG soc_mult_chip_wavegen_drva_scale_offset_test_cfg


class `TESTCFG extends `TESTCFG_BASE;

  `nnc_object_utils(`TESTCFG)

  // ===============================================
  // Adding your new varialbles in config test
  // -----------------------------------------------

  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_mult_chip_wavegen_drva_scale_offset_test_cfg");
    super.new(name);
    
  endfunction: new

  // ===============================================
  // Adding constraints of randomization
  // -----------------------------------------------
  constraint c_mult_chip_en           { mult_chip_en == 1'b1;}
  constraint c_mult_chip_typ          { mult_chip_typ inside {[0:2]}; }
  constraint c_ext_clk_en             { ext_clk_en == 1;}
  constraint c_hfosc_fixed_gnd_en     { (mult_chip_typ == 2'b00) -> hfosc_fixed_gnd_en == 1'b0;
                                        (mult_chip_typ == 2'b01) -> hfosc_fixed_gnd_en == 1'b0;
                                        (mult_chip_typ == 2'b10) -> hfosc_fixed_gnd_en == 1'b1; }
  constraint c_ext_hfosc_fixed_gnd_en { (mult_chip_typ == 2'b00) -> ext_hfosc_fixed_gnd_en == 1'b1;
                                        (mult_chip_typ == 2'b01) -> ext_hfosc_fixed_gnd_en == 1'b1;
                                        (mult_chip_typ == 2'b10) -> ext_hfosc_fixed_gnd_en == 1'b0; }
  constraint c_pclk_sel               { pclk_sel == 0;}//multi_chip tests with same clk enable limited to run with pclk=fclk
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
    `DUT_IF.pclk_sel = top_test_cfg.pclk_sel;
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

`ifdef DIG_RST
    if((`DUT_IF.spi_o_clk_sel !== 1'b0) || ((`DUT_IF.spi_o_clk_sel === 1'b0) && (`DUT_IF.swap_sdf_en === 1'b1))) begin
	`nnc_info("SOC_TEST", "Single Writing to PMU_REG1 to apply digital soft reset", NNC_LOW)
        `WR_NORMAL_REG(`SOC_PMU_REG1, 8'h00, 8'h00);
	#1ms;
	`WR_NORMAL_REG(`SOC_PMU_REG1, `INIT_SOC_PMU_REG1, 8'h00);
	if (`DUT_IF.spi_o_clk_sel !== 1'b0) begin
            `nnc_info("SOC_TEST", "Single Writing to SOC_OUT_CLK_SEL_REG Register to use MULTI CHIP with Unaligned clock", NNC_LOW)
            `WR_NORMAL_REG(`SOC_OUT_CLK_SEL_REG, `INIT_SOC_OUT_CLK_SEL_REG | 8'b0000_0001, 8'h00);
        end
    end
`endif

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
