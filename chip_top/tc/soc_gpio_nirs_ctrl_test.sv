/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_gpio_nirs_ctrl_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_gpio_nirs_ctrl_test                                             
// Designer	: thnguyen@nanochap.com                                                                 
// Date		: 29-04-2026                                                                     
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_gpio_nirs_ctrl_test
`define TESTCFG soc_gpio_nirs_ctrl_test_cfg

class `TESTCFG extends soc_base_test_cfg;

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

  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_gpio_nirs_ctrl_test_cfg");
    super.new(name);
    
  endfunction: new

  // ===============================================
  // Adding constraints of randomization
  // -----------------------------------------------

  // testmode_sel[1:0] : 00-Normal mode, 01: Scanmode, 10: BIST mode, 11 atm0/1/2/3/4
  constraint c_testmode_sel { soft testmode_sel == 2'b00; }

  // spimode_sel[1:0] :  
  constraint c_spimode_sel { spimode_sel == 2'b00; }

  // No of bytes in a burst
  constraint c_no_of_bytes { soft no_of_bytes == 2; }

  // pads values
  constraint c_pads        { soft pads == 8'h00; }

  // mask values
  constraint c_mask        { soft mask == 8'hff; }

  // -----------------------------------------------
  // End of adding constraints of randomization
  // ===============================================

endclass : `TESTCFG

// ===============================================
// Main Testcase is defined
// -----------------------------------------------
class `TESTNAME extends soc_base_test;
  logic [4:0] rand_bit;
   
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
  // Declare the pre_reset_phase task 
  // -----------------------------------------
  virtual task pre_reset_phase(nnc_phase phase);
    phase.raise_objection(this);

    super.pre_reset_phase(phase);

    assert(top_test_cfg.randomize());

    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;

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

    `nnc_info("SOC_TEST", "soc_gpio_nirs_ctrl_test start", NNC_LOW)

    // ==================================================================================
    // Please add your code of your test here
    // ---------------------------------------------------------------------------------- 
    
    `WR_NORMAL_REG(`SOC_GPIO_NIRS_OUT_CTRL_REG, `INIT_SOC_GPIO_NIRS_OUT_CTRL_REG, 8'h00);
    force `DIG_TOP.u_nirs_wrapper.LED_ON_IO[5:1] = $random;
    #1000ns
    rand_bit[0] = `DIG_TOP.u_nirs_wrapper.LED_ON_IO[1];
    if(`SOC_TOP.u_iopad_gpio[15].PAD != rand_bit[0])
      `nnc_error("GPIO", $sformatf("NIRS_LED_ON1 = %b is not as expectation of IOBUF_PAD[15] = %b while GPIO_NIRS_CTRL is 1'b0",rand_bit[0], `SOC_TOP.u_iopad_gpio[15].PAD));
    if(`SOC_TOP.u_iopad_gpio[16].PAD != rand_bit[1])
      `nnc_error("GPIO", $sformatf("NIRS_LED_ON2 = %b is not as expectation of IOBUF_PAD[16] = %b while GPIO_NIRS_CTRL is 1'b0",rand_bit[1], `SOC_TOP.u_iopad_gpio[16].PAD));
    if(`SOC_TOP.u_iopad_gpio[17].PAD != rand_bit[2])
      `nnc_error("GPIO", $sformatf("NIRS_LED_ON3 = %b is not as expectation of IOBUF_PAD[17] = %b while GPIO_NIRS_CTRL is 1'b0",rand_bit[2], `SOC_TOP.u_iopad_gpio[17].PAD));
    if(`SOC_TOP.u_iopad_gpio[18].PAD != rand_bit[3])
      `nnc_error("GPIO", $sformatf("NIRS_LED_ON4 = %b is not as expectation of IOBUF_PAD[18] = %b while GPIO_NIRS_CTRL is 1'b0",rand_bit[3], `SOC_TOP.u_iopad_gpio[18].PAD));
    if(`SOC_TOP.u_iopad_gpio[19].PAD != rand_bit[4])
      `nnc_error("GPIO", $sformatf("NIRS_LED_ON5 = %b is not as expectation of IOBUF_PAD[19] = %b while GPIO_NIRS_CTRL is 1'b0",rand_bit[4], `SOC_TOP.u_iopad_gpio[19].PAD));
    
    release `DIG_TOP.u_nirs_wrapper.LED_ON_IO[5:1];
    
    `WR_NORMAL_REG(`SOC_GPIO_NIRS_OUT_CTRL_REG, 8'h01, 8'h00);
    force `DIG_TOP.u_pinmux.NIRS_RESET_SW0 = $random;
    force `DIG_TOP.u_pinmux.NIRS_IPD_SW0 = $random;
    force `DIG_TOP.u_pinmux.NIRS_IIN_SW0 = $random;
    force `DIG_TOP.u_pinmux.A2D_IREFCOARSE0 = $random;
    force `DIG_TOP.u_pinmux.A2D_IREFFINE0 = $random;

    rand_bit[0] = `DIG_TOP.u_pinmux.NIRS_RESET_SW0;
    rand_bit[1] = `DIG_TOP.u_pinmux.NIRS_IPD_SW0;
    rand_bit[2] = `DIG_TOP.u_pinmux.NIRS_IIN_SW0;
    rand_bit[3] = `DIG_TOP.u_pinmux.A2D_IREFCOARSE0;
    rand_bit[4] = `DIG_TOP.u_pinmux.A2D_IREFFINE0;

    #1000ns

    if(`SOC_TOP.u_iopad_gpio[15].PAD != rand_bit[0])
      `nnc_error("GPIO", $sformatf("NIRS_RESET_SW0 = %b is not as expectation of IOBUF_PAD[15] = %b while GPIO_NIRS_CTRL is 1'b1",rand_bit[0], `SOC_TOP.u_iopad_gpio[15].PAD));
    if(`SOC_TOP.u_iopad_gpio[16].PAD != rand_bit[1])
      `nnc_error("GPIO", $sformatf("NIRS_IPD_SW0 = %b is not as expectation of IOBUF_PAD[16] = %b while GPIO_NIRS_CTRL is 1'b1",rand_bit[1], `SOC_TOP.u_iopad_gpio[16].PAD));
    if(`SOC_TOP.u_iopad_gpio[17].PAD != rand_bit[2])
      `nnc_error("GPIO", $sformatf("NIRS_IIN_SW0 = %b is not as expectation of IOBUF_PAD[17] = %b while GPIO_NIRS_CTRL is 1'b1",rand_bit[2], `SOC_TOP.u_iopad_gpio[17].PAD));
    if(`SOC_TOP.u_iopad_gpio[18].PAD != rand_bit[3])
      `nnc_error("GPIO", $sformatf("A2D_IREFCOARSE0 = %b is not as expectation of IOBUF_PAD[18] = %b while GPIO_NIRS_CTRL is 1'b1",rand_bit[3], `SOC_TOP.u_iopad_gpio[18].PAD));
    if(`SOC_TOP.u_iopad_gpio[19].PAD != rand_bit[4])
      `nnc_error("GPIO", $sformatf("A2D_IREFFINE0 = %b is not as expectation of IOBUF_PAD[19] = %b while GPIO_NIRS_CTRL is 1'b1",rand_bit[4], `SOC_TOP.u_iopad_gpio[19].PAD));




    #10000ns;
    `nnc_info("SOC_TEST", "soc_gpio_nirs_ctrl_test end now", NNC_LOW)

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
