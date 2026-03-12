/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_otp_reload_bist_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_otp_reload_bist_test                                             
// Designer	: ddang@nanochap.com                                                                 
// Date		: 19-11-2024                                                                     
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_otp_reload_bist_test
`define TESTCFG soc_otp_reload_bist_test_cfg

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
  rand logic [7:0] trim_wdata[12];
  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_otp_reload_bist_test_cfg");
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

  constraint c_OTP_SEL    { OTP_SEL == 0;}

  constraint c_io_model_check_off { io_model_check_off == 1'b1; }  
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
  rand logic [7:0] ADDR;
  rand logic [2:0] OTP_SEL = 0;
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
    uvm_top.set_timeout(2s);
    top_test_cfg = `TESTCFG::type_id::create("top_test_cfg", this);
  endfunction

  // -----------------------------------------
  // Declare the pre_reset_phase task 
  // -----------------------------------------
  virtual task pre_reset_phase(nnc_phase phase);
    phase.raise_objection(this);

    super.pre_reset_phase(phase);

    assert(top_test_cfg.randomize() /* with {altf_sel == 0;}*/);

    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;

    `DUT_IF.spimode_sel = top_test_cfg.spimode_sel;
    `DUT_IF.altf_sel = top_test_cfg.altf_sel;
    // -------------------
    // Scoreboard enables
    // -------------------
    `SPI_SCB_EN = 1'b0;    
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

    `nnc_info("SOC_TEST", "soc_otp_reload_bist_test start", UVM_LOW)

    // ==================================================================================
    // Please add your code of your test here
    // ---------------------------------------------------------------------------------- 
    
    // --------------------------------------------------------
    // This is an example RD_RESET_CHK_REG 
    // --------------------------------------------------------
    force soc_top_tb.iopad_resetn = 1'b0;    
    //force soc_top_tb.VDD_DIG = 0;
    #1000ns;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b10;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    `DUT_IF.io_model_check_off = 1;                       
    #150us;
    //release soc_top_tb.VDD_DIG;
    release soc_top_tb.iopad_resetn;

    //`EPROM_BIST_MASTER_VIP.set_freq_sel(top_test_cfg.TCK_SEL);   //2'b00->1M  ;  2'b01->10M ;  2'b10 -> 20M ;  2'b11 -> 32M
    //top_test_cfg.TCK_SEL.rand_mode(0);
    
    `nnc_info("SOC_TEST", "[EPROM BIST MASTER][0] Sending Reset Command to EPROM", UVM_LOW);
    `BISTM_RESET;
    `nnc_info("SOC_TEST", "[EPROM BIST MASTER] Complete successully this phase", UVM_LOW);
   
    #150us;

    `BISTM_SINGLE_PROGRAM(top_test_cfg.OTP_SEL, 0, 8'h5a, top_test_cfg.vpp_pos_cnt, top_test_cfg.vpp_width);
    
    `BISTM_SINGLE_PROGRAM(top_test_cfg.OTP_SEL, 4, top_test_cfg.trim_wdata[1], top_test_cfg.vpp_pos_cnt, top_test_cfg.vpp_width);
    `BISTM_SINGLE_PROGRAM(top_test_cfg.OTP_SEL, 5, top_test_cfg.trim_wdata[2], top_test_cfg.vpp_pos_cnt, top_test_cfg.vpp_width);
    `BISTM_SINGLE_PROGRAM(top_test_cfg.OTP_SEL, 6, top_test_cfg.trim_wdata[3], top_test_cfg.vpp_pos_cnt, top_test_cfg.vpp_width);
    `BISTM_SINGLE_PROGRAM(top_test_cfg.OTP_SEL, 7, top_test_cfg.trim_wdata[4], top_test_cfg.vpp_pos_cnt, top_test_cfg.vpp_width);
    `BISTM_SINGLE_PROGRAM(top_test_cfg.OTP_SEL, 8, top_test_cfg.trim_wdata[5], top_test_cfg.vpp_pos_cnt, top_test_cfg.vpp_width);
    `BISTM_SINGLE_PROGRAM(top_test_cfg.OTP_SEL, 9, top_test_cfg.trim_wdata[6], top_test_cfg.vpp_pos_cnt, top_test_cfg.vpp_width);
    `BISTM_SINGLE_PROGRAM(top_test_cfg.OTP_SEL, 10, top_test_cfg.trim_wdata[7], top_test_cfg.vpp_pos_cnt, top_test_cfg.vpp_width);
    `BISTM_SINGLE_PROGRAM(top_test_cfg.OTP_SEL, 11, top_test_cfg.trim_wdata[8], top_test_cfg.vpp_pos_cnt, top_test_cfg.vpp_width);
    top_test_cfg.trim_wdata.rand_mode(0);
   
    #100000ns;    
    `nnc_info("SOC_TEST", "Requesting the RESET", UVM_LOW)
    force soc_top_tb.iopad_resetn = 1'b0;

    assert(top_test_cfg.randomize() with { testmode_sel == 2'b00;}) 
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
        
    #100000ns;
    release soc_top_tb.iopad_resetn;
    #1000us; 
             
    `DUT_IF.altf_gpio_sel = `DUT_IF.altf_sel;

    top_test_cfg.rd_data =new[9];
    //read trim_reg
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_TRIM_0_REG; no_of_bytes == 9; });
    `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data[0:8]);
    #10ms;
    //read alt_reg
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_ALT_FUN_REG; no_of_bytes == 1; });
    //`RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data[2:2]);

    //read space_reg
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_D2A_SPARE_WR_REG0; no_of_bytes == 2; });
    //`RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data[0:1]);

    for(int i=1; i<9 ; i++) begin
        if(top_test_cfg.trim_wdata[i] !== top_test_cfg.rd_data[8-i]) `nnc_error("SOC_TEST", $sformatf("save_trim_wdata %8b !== rd_data %8b!!!", top_test_cfg.trim_wdata[i], top_test_cfg.rd_data[8-i]))
        else `nnc_info("SOC_TEST", $sformatf("save_trim_wdata %8b === rd_data %8b!!!", top_test_cfg.trim_wdata[i], top_test_cfg.rd_data[8-i]), UVM_LOW) 
    end

    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    #10000ns;
    `nnc_info("SOC_TEST", "soc_otp_reload_bist_test end now", UVM_LOW)

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
