/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_spi_reg_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_otp_reload_test                                             
// Designer	: ddang@nanochap.com                                                                 
// Date		: 29-11-2023                                                                     
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_otp_reload_test
`define TESTCFG soc_otp_reload_test_cfg

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
  rand logic [7:0]      rd_data;

  logic [7:0]          init_normal_reg[256];
  logic [7:0]          init_wavegen_reg[256];

  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_otp_reload_test_cfg");
    super.new(name);
  endfunction: new

  // ===============================================
  // Adding constraints of randomization
  // -----------------------------------------------

  // testmode_sel[1:0] : 00-Normal mode, 01: Scanmode, 10: BIST mode, 11 atm0/1/2/3/4
  constraint c_testmode_sel { soft testmode_sel == 2'b00; }

  // spimode_sel[1:0] :  
  constraint c_spimode_sel  { spimode_sel == 2'b00; }

  // No of bytes in a burst
  constraint c_no_of_bytes  { soft no_of_bytes == 2; }

  // pads values
  constraint c_pads         { soft pads == 8'h00; }

  // mask values
  constraint c_mask         { soft mask == 8'hff; }

  // Enable/Disable to program OTP
  constraint c_otp_program_en           { otp_program_en == 1'b1;}

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
    uvm_top.set_timeout(2s);
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

    `DUT_IF.otp_program_en = top_test_cfg.otp_program_en;

    `DUT_IF.otp_vpp_delay = top_test_cfg.otp_vpp_delay;

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
  virtual task main_phase(uvm_phase phase);
    phase.raise_objection(this);

    super.main_phase(phase);

    `nnc_info("SOC_TEST", "soc_spi_reg_test start", UVM_LOW)

    // ===============================================================================================
    // Please add your code of your test here
    // -----------------------------------------------------------------------------------------------

    // --------------------------------------------------------
    // Part I: Checking the W/R values of all of normal registers by using WR_RD_CHK_NORMAL_REG
    // --------------------------------------------------------
    `nnc_info("SOC_TEST - PART II", "STARTING TO CHECK THE R/W OF NORMAL REGISTERS", UVM_LOW)
 
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_TRIM_0_REG; mask == 8'hff; data[0] == 8'h5a;}); // the first trim value is 8'h5a
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);
    repeat(3) @(posedge `DUT_IF.sys_clk);
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    if ((top_test_cfg.data[0] & top_test_cfg.mask) !== (top_test_cfg.rd_data & top_test_cfg.mask)) begin
       `nnc_error("SPIM INFO - WRRDCHK", $sformatf("EXPECTED WRITE DATA:%h IS NOT MATCH WITH CURRENT READ DATA:%h", top_test_cfg.data[0] & top_test_cfg.mask, top_test_cfg.rd_data & top_test_cfg.mask))
    end

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_TRIM_1_REG; mask == 8'hff;});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);
    repeat(3) @(posedge `DUT_IF.sys_clk);
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    if ((top_test_cfg.data[0] & top_test_cfg.mask) !== (top_test_cfg.rd_data & top_test_cfg.mask)) begin
       `nnc_error("SPIM INFO - WRRDCHK", $sformatf("EXPECTED WRITE DATA:%h IS NOT MATCH WITH CURRENT READ DATA:%h", top_test_cfg.data[0] & top_test_cfg.mask, top_test_cfg.rd_data & top_test_cfg.mask))
    end

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_TRIM_2_REG; mask == 8'hff;});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);
    repeat(3) @(posedge `DUT_IF.sys_clk);
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    if ((top_test_cfg.data[0] & top_test_cfg.mask) !== (top_test_cfg.rd_data & top_test_cfg.mask)) begin
       `nnc_error("SPIM INFO - WRRDCHK", $sformatf("EXPECTED WRITE DATA:%h IS NOT MATCH WITH CURRENT READ DATA:%h", top_test_cfg.data[0] & top_test_cfg.mask, top_test_cfg.rd_data & top_test_cfg.mask))
    end

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_TRIM_3_REG; mask == 8'hff;});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);
    repeat(3) @(posedge `DUT_IF.sys_clk);
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    if ((top_test_cfg.data[0] & top_test_cfg.mask) !== (top_test_cfg.rd_data & top_test_cfg.mask)) begin
       `nnc_error("SPIM INFO - WRRDCHK", $sformatf("EXPECTED WRITE DATA:%h IS NOT MATCH WITH CURRENT READ DATA:%h", top_test_cfg.data[0] & top_test_cfg.mask, top_test_cfg.rd_data & top_test_cfg.mask))
    end

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_TRIM_4_REG; mask == 8'hff;});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);
    repeat(3) @(posedge `DUT_IF.sys_clk);
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    if ((top_test_cfg.data[0] & top_test_cfg.mask) !== (top_test_cfg.rd_data & top_test_cfg.mask)) begin
       `nnc_error("SPIM INFO - WRRDCHK", $sformatf("EXPECTED WRITE DATA:%h IS NOT MATCH WITH CURRENT READ DATA:%h", top_test_cfg.data[0] & top_test_cfg.mask, top_test_cfg.rd_data & top_test_cfg.mask))
    end

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_TRIM_5_REG; mask == 8'hff;});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);
    repeat(3) @(posedge `DUT_IF.sys_clk);
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    if ((top_test_cfg.data[0] & top_test_cfg.mask) !== (top_test_cfg.rd_data & top_test_cfg.mask)) begin
       `nnc_error("SPIM INFO - WRRDCHK", $sformatf("EXPECTED WRITE DATA:%h IS NOT MATCH WITH CURRENT READ DATA:%h", top_test_cfg.data[0] & top_test_cfg.mask, top_test_cfg.rd_data & top_test_cfg.mask))
    end

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_TRIM_6_REG; mask == 8'hff;});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);
    repeat(3) @(posedge `DUT_IF.sys_clk);
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    if ((top_test_cfg.data[0] & top_test_cfg.mask) !== (top_test_cfg.rd_data & top_test_cfg.mask)) begin
       `nnc_error("SPIM INFO - WRRDCHK", $sformatf("EXPECTED WRITE DATA:%h IS NOT MATCH WITH CURRENT READ DATA:%h", top_test_cfg.data[0] & top_test_cfg.mask, top_test_cfg.rd_data & top_test_cfg.mask))
    end

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_TRIM_7_REG; mask == 8'hff;foreach(data[i]) data[i]>8'h10;});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);
    repeat(3) @(posedge `DUT_IF.sys_clk);
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    if ((top_test_cfg.data[0] & top_test_cfg.mask) !== (top_test_cfg.rd_data & top_test_cfg.mask)) begin
       `nnc_error("SPIM INFO - WRRDCHK", $sformatf("EXPECTED WRITE DATA:%h IS NOT MATCH WITH CURRENT READ DATA:%h", top_test_cfg.data[0] & top_test_cfg.mask, top_test_cfg.rd_data & top_test_cfg.mask))
    end

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_TRIM_8_REG; mask == 8'hff;foreach(data[i]) data[i]>8'h10;});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);
    repeat(3) @(posedge `DUT_IF.sys_clk);
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    if ((top_test_cfg.data[0] & top_test_cfg.mask) !== (top_test_cfg.rd_data & top_test_cfg.mask)) begin
       `nnc_error("SPIM INFO - WRRDCHK", $sformatf("EXPECTED WRITE DATA:%h IS NOT MATCH WITH CURRENT READ DATA:%h", top_test_cfg.data[0] & top_test_cfg.mask, top_test_cfg.rd_data & top_test_cfg.mask))
    end
    
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_UNLOCK_REG; mask == 8'h1; data[0] == 8'b10101_001;});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);

    //set OTP_VPP_EN to 1(connect to IOPAD[8], boost VPP to 7.5V in 20us
  
    //repeat(3) @(posedge `DUT_IF.sys_clk);
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    if ((top_test_cfg.data[0] & top_test_cfg.mask) !== (top_test_cfg.rd_data & top_test_cfg.mask)) begin
       `nnc_error("SPIM INFO - WRRDCHK", $sformatf("EXPECTED WRITE DATA:%h IS NOT MATCH WITH CURRENT READ DATA:%h", top_test_cfg.data[0] & top_test_cfg.mask, top_test_cfg.rd_data & top_test_cfg.mask))
    end
    
    //set OTP_VPP_EN to 1(connect to IOPAD[8], boost VPP to 7.5V in 20us
    //`DUT_IF.otp_program_en = top_test_cfg.otp_program_en;
    //`DUT_IF.otp_vpp_delay = top_test_cfg.otp_vpp_delay;


    //OR  
    //Wait for Wr_working ==> LOW
    // --------------------------------------------------------
    // Part II: Checking the Wr_working be low
    // --------------------------------------------------------
    //repeat(4) @(posedge `DUT_IF.sys_clk);
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_DEBUG_1_REG; mask == 8'h3;});
    do begin
        `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
        $display($time,"Wait for the Wr_working be low!!!");
    end while(top_test_cfg.rd_data[6] !== 0);

    //wait for OTP_VPP_EN=0 
    wait(`SOC_TB.VPP_EN === 1'b0); //@(negedge `SOC_TB.VPP_EN);

    //wait for sometimeb before power off the chip
    #50us;

    // --------------------------------------------------------
    // Part III: Call POR reset 
    // --------------------------------------------------------
        `nnc_info("SOC_TEST", "POR RESETn 10ms", UVM_LOW);
        force `SOC_TOP.A2D_SW_POWER_POR = 1'b0;
        #1000;
`ifndef BEHAVIORAL
   `ifdef POSTSCAN_PG
          if(/*`RST_CTRL_TOP.presetn ||   `RST_CTRL_TOP.poresetn ||*`RST_CTRL_TOP.poresetn_hf || `RST_CTRL_TOP.otp_por_resetn */ `RST_CTRL_TOP.por_resetn)
    `else
        if(/* `RST_CTRL_TOP.presetn &&  `RST_CTRL_TOP.poresetn &&*/ `RST_CTRL_TOP.presetn/*poresetn_hf*/ || `RST_CTRL_TOP.por_resetn )
    `endif
`else
        if(`RST_CTRL_TOP.presetn || `RST_CTRL_TOP.poresetn || `RST_CTRL_TOP.poresetn_hf || `RST_CTRL_TOP.por_resetn )
`endif
         `nnc_error("SOC_TEST", "RESETn error!!!");  
         
        #10ms;
        release `SOC_TOP.A2D_SW_POWER_POR;
        force `SOC_TOP.A2D_SW_POWER_POR = 1'b1;
        
        #10ns;
        //wait por_cnt
        repeat(800) @(posedge `CLK_CTRL_TOP.pclk);
`ifndef BEHAVIORAL
   `ifdef POSTSCAN_PG
          if(/*`RST_CTRL_TOP.presetn ||  `RST_CTRL_TOP.poresetn ||*`RST_CTRL_TOP.poresetn_hf || `RST_CTRL_TOP.otp_por_resetn */ `RST_CTRL_TOP.por_resetn);
    `else
        if(/* `RST_CTRL_TOP.presetn &&  `RST_CTRL_TOP.poresetn &&*/ `RST_CTRL_TOP.presetn/*poresetn_hf*/ && `RST_CTRL_TOP.por_resetn );
    `endif
`else
        if(`RST_CTRL_TOP.presetn && `RST_CTRL_TOP.poresetn && `RST_CTRL_TOP.poresetn_hf && `RST_CTRL_TOP.por_resetn );
`endif
        else  `nnc_error("SOC_TEST", "RESETn error!!!");              
    // --------------------------------------------------------
    // Part IV: wait for the reload
    // --------------------------------------------------------

    //repeat(4) @(posedge `DUT_IF.sys_clk);
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_DEBUG_1_REG; mask == 8'h3;});
    do begin
        `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
         `nnc_info("SOC_TEST", "Wait for the reload rise!", UVM_LOW)//$display($time,"Wait for the reload rise!!!");
    end while(top_test_cfg.rd_data[5] !== 1);
    
    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    #100000ns;
    `nnc_info("SOC_TEST", "soc_otp_reload_test end now", UVM_LOW)

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
