/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_mult_chip_wavegen_drva_pulse_diff_config_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_mult_chip_wavegen_drva_pulse_diff_config_test                                             
// Designer	: ddang@nanochap.com                                                                 
// Date		: 20-08-2024                                                                   
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

//***************************************************************************************
// NOTE : This test is extended from soc_wavegen_drva_pulse_test. 
//        The test is intented to generate pulse wave for driver1 & driver2 in multiple
//        devices. In this test multiple devices are configured differently, but wavegen
//        is enabled at same time for these devices to generate 2 different configured
//        waveform.
//***************************************************************************************

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME_BASE soc_wavegen_drva_pulse_test
`define TESTCFG_BASE  soc_wavegen_drva_pulse_test_cfg
`define TESTNAME soc_mult_chip_wavegen_drva_pulse_diff_config_test
`define TESTCFG soc_mult_chip_wavegen_drva_pulse_diff_config_test_cfg


class `TESTCFG extends `TESTCFG_BASE;

  `nnc_object_utils(`TESTCFG)

  // ===============================================
  // Adding your new varialbles in config test
  // -----------------------------------------------

  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_mult_chip_wavegen_drva_pulse_diff_config_test_cfg");
    super.new(name);
    
  endfunction: new

  // ===============================================
  // Adding constraints of randomization
  // -----------------------------------------------
  constraint c_mult_chip_en           { soft mult_chip_en == 1'b1;}
  constraint c_mult_chip_mode         { soft mult_chip_mode == 2'b00;}
  constraint c_mult_chip_same_clk_en  { soft mult_chip_same_clk_en == 1'b0;}
  constraint c_hfosc_fixed_gnd_en     { soft hfosc_fixed_gnd_en == 1'b0; }
  constraint c_ext_hfosc_fixed_gnd_en { soft ext_hfosc_fixed_gnd_en == 1'b1; }

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
    `DUT_IF.mult_chip_mode = top_test_cfg.mult_chip_mode;
    `DUT_IF.mult_chip_same_clk_en = top_test_cfg.mult_chip_same_clk_en;
    `DUT_IF.swap_sdf_en = top_test_cfg.swap_sdf_en;
    `DUT_IF.ext_clk_en = top_test_cfg.ext_clk_en;
    `DUT_IF.hfosc_fixed_gnd_en = top_test_cfg.hfosc_fixed_gnd_en;
    `DUT_IF.ext_hfosc_fixed_gnd_en = top_test_cfg.ext_hfosc_fixed_gnd_en;

    // -------------------
    // Scoreboard enables
    // -------------------
    `SPI_SCB_EN = 1'b0;
    //`CHIP_1_WAVEGEN_SCB_DRV_0_EN = 1'b1;

    phase.drop_objection(this);
  endtask : pre_reset_phase

  // -----------------------------------------
  // Declare the main_phase task of your test
  // -----------------------------------------
  virtual task main_phase(nnc_phase phase);
    phase.raise_objection(this);


    `nnc_info("SOC_TEST", "soc_mult_chip_wavegen_drva_pulse_diff_config_test start", NNC_LOW)

    // ==================================================================================
    // Please add your code of your test here
    // ----------------------------------------------------------------------------------

    // Configure Chip 0 
    assert(top_test_cfg.randomize() with {mult_chip_mode == 2'b01; });
    `DUT_IF.mult_chip_mode = top_test_cfg.mult_chip_mode;

    wavegen_setup(0);//chip 0

    wavegen_drv_config(`WAVEGEN_0_ADDR_BASE);
    wavegen_drv_config(`WAVEGEN_1_ADDR_BASE);

    // Configure Chip 1 
    assert(top_test_cfg.randomize() with {mult_chip_mode == 2'b10; });
    `DUT_IF.mult_chip_mode = top_test_cfg.mult_chip_mode;

    wavegen_setup(1);//chip 1

    wavegen_drv_config(`WAVEGEN_0_ADDR_BASE);
    wavegen_drv_config(`WAVEGEN_1_ADDR_BASE);

    // Enable 2 chips 
    assert(top_test_cfg.randomize() with {mult_chip_mode == 2'b00; });
    `DUT_IF.mult_chip_mode = top_test_cfg.mult_chip_mode;

    `nnc_info("SOC_TEST", "enabling chip_1 wavegen sb now", NNC_LOW)
    `CHIP_1_WAVEGEN_SCB_DRV_0_EN = 1'b1;
    `CHIP_1_WAVEGEN_SCB_DRV_1_EN = 1'b1;
    wavegen_drv_enable;

    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    if(`DUT_IF.python_check_en === 0)
    	#100ms;
    else begin
        wait((`SOC_TB.py_tb.python_data_num_0 === `DUT_IF.python_length) && (`SOC_TB.py_tb.python_data_num_1 === `DUT_IF.python_length));
	#1ms;
    end
    `nnc_info("SOC_TEST", "soc_mult_chip_wavegen_drva_pulse_diff_config_test end now", NNC_LOW)

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
