/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_gpio_testmode_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_gpio_testmode_test                                             
// Designer	: thnguyen@nanochap.com                                                                 
// Date		: 01-08-2025                                                                     
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_gpio_testmode_test
`define TESTCFG soc_gpio_testmode_test_cfg

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
  rand logic [1:0] testmode_rand;

  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_gpio_testmode_test_cfg");
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

    `WAVEGEN_MULT_CHIP_CHECK_EN = 0;
    `CHIP_1_WAVEGEN_MULT_CHIP_CHECK_EN = 0;

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

    `nnc_info("SOC_TEST", "soc_gpio_testmode_test start", NNC_LOW)
    `DUT_IF.otp_ignore_check_en = 1;

    /*for(int i=0;i<=10; i++) begin
      #500us;
      force `SOC_TB.iopad_resetn = 1'b0;
      #100000;
      force `SOC_TB.iopad_resetn = 1'b1;
      #100000;

      top_test_cfg.testmode_rand = $random;
      `DUT_IF.testmode_sel = top_test_cfg.testmode_rand;
    end*/
    

    #500us;
    check_testmode();
    force `SOC_TB.iopad_resetn = 1'b0;
    #100000;
    force `SOC_TB.iopad_resetn = 1'b1;
    #100000;

    `DUT_IF.testmode_sel = 2'b01;
     #500us;
    check_testmode();

    force `SOC_TB.iopad_resetn = 1'b0;
    #100000;
    force `SOC_TB.iopad_resetn = 1'b1;
    #100000;

    `DUT_IF.testmode_sel = 2'b10;
    #500us;
    check_testmode();

    force `SOC_TB.iopad_resetn = 1'b0;
    #100000;
    force `SOC_TB.iopad_resetn = 1'b1;
    #100000;

    `DUT_IF.testmode_sel = 2'b11;
    #500us;
    check_testmode();
     

    #10000ns;
    `nnc_info("SOC_TEST", "soc_gpio_testmode_test end now", NNC_LOW)

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


   task check_testmode;
      if({`SOC_TOP.iopad_testmode1, `SOC_TOP.iopad_testmode0} === 2'b00) begin
        if({`SOC_TOP.u_iopad_testmode1.Y, `SOC_TOP.u_iopad_testmode0.Y} !== 2'b00)begin
          `nnc_error("SOC_GPIO", $sformatf("u_iopad_testmode1.Y, u_iopad_testmode0.Y = %h is not as expectation of `SOC_TOP.iopad_testmode1, `SOC_TOP.iopad_testmode0 = %h",{`SOC_TOP.u_iopad_testmode1.Y, `SOC_TOP.u_iopad_testmode0.Y}, {`SOC_TOP.iopad_testmode1, `SOC_TOP.iopad_testmode0}));
         end
      end
      
      if(`SOC_TOP.iopad_testmode1 === 1) begin
        if(`SOC_TOP.u_iopad_testmode1.Y !== 1)
            `nnc_error("SOC_GPIO", $sformatf("u_iopad_testmode1.Y = %h is not as expectation of `SOC_TOP.iopad_testmode1 = %h",`SOC_TOP.u_iopad_testmode1.Y, `SOC_TOP.iopad_testmode1));
      end

      if(`SOC_TOP.iopad_testmode0 === 1) begin
        if(`SOC_TOP.u_iopad_testmode0.Y !== 1)
            `nnc_error("SOC_GPIO", $sformatf("u_iopad_testmode0.Y = %h is not as expectation of `SOC_TOP.iopad_testmode0 = %h",`SOC_TOP.u_iopad_testmode0.Y, `SOC_TOP.iopad_testmode0));
      end

  endtask


endclass : `TESTNAME
