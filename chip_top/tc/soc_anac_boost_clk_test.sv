/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_anac_boost_clk_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_anac_boost_clk_test                                             
// Designer	: zhenhong.yu@nanochap.com                                                                 
// Date		: 18-03-2024                                                                   
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_anac_boost_clk_test
`define TESTCFG soc_anac_boost_clk_test_cfg

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
  rand logic       boost_clk_fixed;
  rand logic       boost_duty_sel;
  rand logic [2:0] boost_duty;
  rand logic [1:0] boost_pres;


  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_anac_boost_clk_test_cfg");
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

  // resp_phase[2:0] :  
  constraint c_boost_duty { boost_duty inside {[0:6]}; }

  // resp_freq[1:0] :  
  constraint c_boost_pres { boost_pres inside {[0:3]}; }
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

    // -------------------
    // Scoreboard enables
    // -------------------
    // `FLASH_SCOREBOARD_EN = 1;
    // `SPIM_SCOREBOARD_EN = 1;
    // `ANALOG_SCOREBOARD_EN = 1;
    // `IMEAS_SCOREBOARD_EN = 1;
    // `CLKRST_SCOREBOARD_EN = 1;
    //`BOOST_CHECK_EN = 1;

    phase.drop_objection(this);
  endtask : pre_reset_phase

  // -----------------------------------------
  // Declare the main_phase task of your test
  // -----------------------------------------
  virtual task main_phase(nnc_phase phase);
    phase.raise_objection(this);

    `nnc_info("SOC_TEST", "soc_sysc_pin_reset_test start", NNC_LOW)

    //set boost_cfg0
    assert(top_test_cfg.randomize() with {reg_addr == 8'h6a; no_of_bytes == 8'h00; wr_data[0] == 8'h77;});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0],top_test_cfg.pads);  

    //set boost_cfg2                 
    `nnc_info("SOC_TEST", "Set up Respiration phase and enable in internal mode", NNC_LOW)
    for (int i=0; i < 5; i++) begin    
        assert(top_test_cfg.randomize() with {reg_addr == 8'h6c; no_of_bytes == 8'h00; wr_data[0] == {1'b0,boost_duty_sel,boost_duty,boost_pres};});
        `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0],top_test_cfg.pads);          
        `BOOST_CHECK_EN = 1'b1; 
        #50000000ns;
        `BOOST_CHECK_EN = 1'b0; 
    end  

    //set boost_cfg2                 
    `nnc_info("SOC_TEST", "Set up Respiration phase and enable in internal mode", NNC_LOW)
    for (int i=0; i < 5; i++) begin    
        assert(top_test_cfg.randomize() with {reg_addr == 8'h6c; no_of_bytes == 8'h00; wr_data[0] == {1'b1,boost_duty_sel,boost_duty,boost_pres};});
        `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0],top_test_cfg.pads);                  
        `BOOST_CHECK_EN = 1'b1; 
        #50000000ns;
        `BOOST_CHECK_EN = 1'b0; 
    end  
        
    phase.drop_objection(this);
  endtask: main_phase

  // Declare the report_phase task
  // ------------------------------
  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction

endclass : `TESTNAME
