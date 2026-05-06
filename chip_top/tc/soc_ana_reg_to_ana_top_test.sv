/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_ana_reg_to_ana_top_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_ana_reg_to_ana_top_test                                             
// Designer	: thnguyen@nanochap.com                                                                 
// Date		: 01-05-2026                                                                     
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_ana_reg_to_ana_top_test
`define TESTCFG soc_ana_reg_to_ana_top_test_cfg

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

  function new (string name = "soc_ana_reg_to_ana_top_test_cfg");
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
   
  logic [7:0] rand_val;
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

    `nnc_info("SOC_TEST", "soc_ana_reg_to_ana_top_test start", NNC_LOW)

    // ==================================================================================
    // Please add your code of your test here
    // ---------------------------------------------------------------------------------- 
    
    for(int i=0; i <=5; i++) begin
      assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_EN_REG_0_0; wr_data[0] == 8'h30;});
      check_connect_start(top_test_cfg.reg_addr, `INIT_SOC_ANA_EN_REG_0_0, {2'b00, `ANA_TOP.D2A_BIST_SEL, `ANA_TOP.D2A_BIST_EN}, top_test_cfg.wr_data[0], 8'h00, 8'h3F);
 
/*
      // 0xC1
      `WR_NORMAL_REG(`SOC_ANA_EN_REG_0_0, rand_val, 8'h00);
      check_ana_conn_d2a(`SOC_ANA_EN_REG_0_0, rand_val, 1, 5, {3'h0, `ANA_TOP.D2A_BIST_SEL});
      check_ana_conn_d2a(`SOC_ANA_EN_REG_0_0, rand_val, 0, 1, {7'h0, `ANA_TOP.D2A_BIST_EN});
      // 0xC2
      `WR_NORMAL_REG(`SOC_ANA_EN_REG_0_1, rand_val, 8'h00);
      check_ana_conn_d2a(`SOC_ANA_EN_REG_0_1, rand_val, 4, 1, {7'h0, `ANA_TOP.D2A_DCLOFFEN});
      check_ana_conn_d2a(`SOC_ANA_EN_REG_0_1, rand_val, 3, 1, {7'h0, `ANA_TOP.D2A_STIMU_EN});
      check_ana_conn_d2a(`SOC_ANA_EN_REG_0_1, rand_val, 2, 1, {7'h0, `ANA_TOP.D2A_DRIVER_CUR_EN});
      check_ana_conn_d2a(`SOC_ANA_EN_REG_0_1, rand_val, 1, 1, {7'h0, `ANA_TOP.D2A_OSC8MHZEN});
      check_ana_conn_d2a(`SOC_ANA_EN_REG_0_1, rand_val, 0, 1, {7'h0, `ANA_TOP.D2A_BGBUFFER_CPTEST_EN});
      // 0xC3
      `WR_NORMAL_REG(`SOC_ANA_EN_REG_0_2, rand_val, 8'h00);
      check_ana_conn_d2a(`SOC_ANA_EN_REG_0_2, rand_val, 3, 1, {7'h0, `ANA_TOP.D2A_SDMVREFPBUFF_EN});
      check_ana_conn_d2a(`SOC_ANA_EN_REG_0_2, rand_val, 2, 1, {7'h0, `ANA_TOP.D2A_SDMVCMBUFF_EN});
      check_ana_conn_d2a(`SOC_ANA_EN_REG_0_2, rand_val, 1, 1, {7'h0, `ANA_TOP.D2A_VCMGENBUFF_EN});
      check_ana_conn_d2a(`SOC_ANA_EN_REG_0_2, rand_val, 0, 1, {7'h0, `ANA_TOP.D2A_RLD_ELECTRODE_EN});
*/
    end

    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    #10000ns;
    `nnc_info("SOC_TEST", "soc_ana_reg_to_ana_top_test end now", NNC_LOW)

    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ==================================================================================

    phase.drop_objection(this);
  endtask: main_phase

// =============================================
// Task to check default and check after writing 
// =============================================
task check_connect_start;
  input [7:0]  addr;
  input [7:0]  default_value; 
  input [7:0]  ana_signal;
  input [7:0]  wr_data;
  input [7:0]  section_sel; 
  input [7:0]  mask;
  begin
    // Step 1 - Check default value of connection from register to ANA interface
    `nnc_info("ANA_MON", "Checking default connection", NNC_LOW) 
    compare_start(ana_signal, default_value, mask);  
   
    // Step 2 - Random values and write to register
    // Should input section so that configure section before configure registers
    // if or case (section) ..... to change section
    // `WR_NORMAL_REG(addr, wr_data, 8'h00);

    // Write register
    `WR_NORMAL_REG(addr, wr_data, 8'h00);

    // Step 3 - Check new values of connection from register to ANA interface
    `nnc_info("ANA_MON", "Checking new values of connection after writting", NNC_LOW) 
    compare_start(ana_signal, default_value, mask);
  end
endtask

// =============================================
// Function check for D2A from registers to ANA Top
// =============================================
task compare_start;
  input logic [7:0] real_data;
  input logic [7:0] expected_data;
  input logic [7:0] mask;

  begin

    if ((real_data & mask) !== (expected_data & mask)) begin
      `nnc_error("ANA_CONN", $sformatf("Mismatch comparison: MASK=0x%h, EXPECTED_DATA=0x%0h, ACTUAL_DATA=0x%0h", mask, expected_data & mask, real_data & mask ))
    end

  end
endtask

  // ------------------------------
  // Declare the report_phase task
  // ------------------------------
  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction

endclass : `TESTNAME
