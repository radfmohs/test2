/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_spi_ana_reg_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_spi_ana_reg_test                                             
// Designer	: pfwang@nanochap.com                                                                 
// Date		: 23-09-2024                                                                     
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_spi_ana_reg_test
`define TESTCFG soc_spi_ana_reg_test_cfg

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
  rand logic [7:0] A2D_ANA_REG[1:0];
  rand logic [7:0] D2A_ANA_REG[12:0];
  logic     adc;

  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_spi_ana_reg_test_cfg");
    super.new(name);
    
  endfunction: new

  // ===============================================
  // Adding constraints of randomization
  // -----------------------------------------------

  // testmode_sel[1:0] : 00-Normal mode, 01: Scanmode, 10: BIST mode, 11 atm0/1/2/3/4
  constraint c_testmode_sel { soft testmode_sel == 2'b00; }

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
    `nnc_info("SOC_TEST", "soc_spi_ana_reg_test start", NNC_LOW)

    // ==================================================================================
    // Please add your code of your test here
    // ---------------------------------------------------------------------------------- 
    
    //// --------------------------------------------------------
    //// This is an example WR_REG - single write to registers
    //// --------------------------------------------------------
    //assert(top_test_cfg.randomize() with {reg_addr == `SOC_ADDR_WG_DRV_CONFIG_REG0;});
    //`nnc_info("SOC_TEST", "Single Writing to a Register", NNC_LOW)
    //`WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    //// --------------------------------------------------------
    //// This is an example RD_REG - single read to registers
    //// --------------------------------------------------------
    //assert(top_test_cfg.randomize() with {reg_addr == `SOC_ADDR_WG_DRV_CONFIG_REG0;});
    //`nnc_info("SOC_TEST", "Single Reading to a Register", NNC_LOW)
    //`RD_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data[0]);

    repeat (10) begin
    top_test_cfg.A2D_ANA_REG.rand_mode(1);
    assert(top_test_cfg.randomize() with {A2D_ANA_REG[0][7:3] == 5'b0;});
    top_test_cfg.A2D_ANA_REG.rand_mode(0);
    
    uvm_hdl_force("soc_top_tb.u_Nanochap_ENS2.u_top_ana_wrapper.u_top_ana.A2D_LVD", top_test_cfg.A2D_ANA_REG[0][0]);
    uvm_hdl_force("soc_top_tb.u_Nanochap_ENS2.u_top_ana_wrapper.u_top_ana.A2D_COMP_OUT_STIMU0_1", top_test_cfg.A2D_ANA_REG[0][1]);
    //uvm_hdl_force("soc_top_tb.u_Nanochap_ENS2.u_top_ana_wrapper.u_top_ana.A2D_COMP_OUT_STIMU1", top_test_cfg.A2D_ANA_REG[0][2]);
    uvm_hdl_force("soc_top_tb.u_Nanochap_ENS2.u_top_ana_wrapper.u_top_ana.A2D_COMP_OUT_STIMU2_3", top_test_cfg.A2D_ANA_REG[0][2]);
    //uvm_hdl_force("soc_top_tb.u_Nanochap_ENS2.u_top_ana_wrapper.u_top_ana.A2D_COMP_OUT_STIMU3", top_test_cfg.A2D_ANA_REG[0][4]);
    uvm_hdl_force("soc_top_tb.u_Nanochap_ENS2.u_top_ana_wrapper.u_top_ana.A2D_SPARE_RO_REG_0", top_test_cfg.A2D_ANA_REG[1]);

    top_test_cfg.rd_data=new[2];
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_0;});
    `nnc_info("SOC_TEST", "Single Reading to a Register", NNC_LOW)
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data[0]);

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_A2D_SPARE_RO_REG0;});
    `nnc_info("SOC_TEST", "Single Reading to a Register", NNC_LOW)
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data[1]);
    
    //top_test_cfg.A2D_ANA_REG[0][2:1] = 2'b0;
    
    foreach (top_test_cfg.A2D_ANA_REG[i]) begin
        if(top_test_cfg.A2D_ANA_REG[i] !== top_test_cfg.rd_data[i]) 
        `nnc_error("SOC_TEST", $sformatf("A2D_ANA_REG[%0d] ERROR!!! , SPI_REG=%8h , ANA_IF=%8h", i , top_test_cfg.rd_data[i], top_test_cfg.A2D_ANA_REG[i]));
    end
//    if(`ANA_WRAPPER_TOP.A2D_ANA_GEN_REG_0 !== top_test_cfg.rd_data[0])
//	`nnc_error("SOC_TEST", $sformatf("A2D_ANA_REG[%0d] ERROR!!! , SPI_REG=%8h , ANA_IF=%8h", 0 , top_test_cfg.rd_data[0], `ANA_WRAPPER_TOP.A2D_ANA_GEN_REG_0));
 //   if(`ANA_WRAPPER_TOP.A2D_SPARE_RO_REG_0 !== top_test_cfg.rd_data[1])
//	`nnc_error("SOC_TEST", $sformatf("A2D_ANA_REG[%0d] ERROR!!! , SPI_REG=%8h , ANA_IF=%8h", 1 , top_test_cfg.rd_data[1], `ANA_WRAPPER_TOP.A2D_SPARE_RO_REG_0));
    uvm_hdl_release("soc_top_tb.u_Nanochap_ENS2.u_top_ana_wrapper.u_top_ana.A2D_LVD");
    uvm_hdl_release("soc_top_tb.u_Nanochap_ENS2.u_top_ana_wrapper.u_top_ana.A2D_COMP_OUT_STIMU0_1");
    //uvm_hdl_release("soc_top_tb.u_Nanochap_ENS2.u_top_ana_wrapper.u_top_ana.A2D_COMP_OUT_STIMU1");
    uvm_hdl_release("soc_top_tb.u_Nanochap_ENS2.u_top_ana_wrapper.u_top_ana.A2D_COMP_OUT_STIMU2_3");
    //uvm_hdl_release("soc_top_tb.u_Nanochap_ENS2.u_top_ana_wrapper.u_top_ana.A2D_COMP_OUT_STIMU3");
    uvm_hdl_release("soc_top_tb.u_Nanochap_ENS2.u_top_ana_wrapper.u_top_ana.A2D_SPARE_RO_REG_0");
    end

    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    #10000ns;
    `nnc_info("SOC_TEST", "soc_spi_ana_reg_test end now", NNC_LOW)

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
