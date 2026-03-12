/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_otp_bist_by_pass_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_otp_bist_by_pass_test                                             
// Designer	: ddang@nanochap.com                                                                 
// Date		: 15-04-2024                                                                     
// Revision	: Updated from ENS1p4 and reused for ENS2                               
// ====================================================================================*/

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_otp_bist_by_pass_test
`define TESTCFG soc_otp_bist_by_pass_test_cfg

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
  rand logic [7:0] wdata_in[0:127];
  rand logic [6:0] addr;
  rand logic [6:0] num_of_bytes;
//  rand logic [1:0] TCK_SEL;
  rand logic [1:0] TM;
  rand logic       bist_write;
  logic [6:0]      ADD;
  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_otp_bist_by_pass_test_cfg");
    super.new(name);
    
  endfunction: new

  // ===============================================
  // Adding constraints of randomization
  // -----------------------------------------------

  // testmode_sel[1:0] : 00-Normal mode, 01: Scanmode, 10: BIST mode, 11 atm0/1/2/3/4
  constraint c_testmode_sel { soft testmode_sel == 2'b10; }

  // No of bytes in a burst
  constraint c_no_of_bytes { soft no_of_bytes == 2; }

  // pads values
  constraint c_pads        { soft pads == 8'h00; }

  // mask values
  constraint c_mask        { soft mask == 8'hff; }

  constraint c_TM        { soft TM != 2'b01; }

  constraint c_bist_vpp_pin_en        { bist_vpp_pin_en == 1'b0; }

  constraint c_wait_reset_en          { soft wait_reset_en == 1'b0;}

  constraint c_OTP_SEL    { OTP_SEL inside {[0:1]};}
  // Enable/Disable to program OTP
  //constraint c_otp_program_en           { soft otp_program_en == 1'b1;}
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

    assert(top_test_cfg.randomize()  with {altf_sel == 0; addr == 0;});

    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;

    `DUT_IF.bist_vpp_pin_en = top_test_cfg.bist_vpp_pin_en;

    `DUT_IF.wait_reset_en = top_test_cfg.wait_reset_en;

    //`DUT_IF.otp_program_en = top_test_cfg.otp_program_en;
    //`DUT_IF.otp_vpp_delay = top_test_cfg.otp_vpp_delay;
    // -------------------
    // Scoreboard enables
    // -------------------
    // `FLASH_SCOREBOARD_EN = 1;
    // `SPIM_SCOREBOARD_EN = 1;
    // `ANALOG_SCOREBOARD_EN = 1;
    // `IMEAS_SCOREBOARD_EN = 1;
    // `CLKRST_SCOREBOARD_EN = 1;
    `EPROM_BIST_SCOREBOARD_EN = 1;

    phase.drop_objection(this);
  endtask : pre_reset_phase

  // -----------------------------------------
  // Declare the main_phase task of your test
  // -----------------------------------------
  virtual task main_phase(nnc_phase phase);
    phase.raise_objection(this);

    `nnc_info("SOC_TEST", "soc_otp_bist_by_pass_test start", NNC_LOW)

    // ==================================================================================
    // Please add your code of your test here
    // ----------------------------------------------------------------------------------
    
    do_force();
    #50us;
    do_run();
    
    #100000ns;

    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    #10000ns;
    `nnc_info("SOC_TEST", "soc_otp_bist_by_pass_test end now", NNC_LOW)

    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ==================================================================================

    phase.drop_objection(this);
  endtask: main_phase

task do_force;
begin

force `ANA_TOP.A2D_CLK2MHZ = 1'bx;
force `ANA_TOP.A2D_LVD = 1'bx;
force `ANA_TOP.A2D_POR_DVDD = 1'bx;
force `ANA_TOP.A2D_COMP_OUT_CH1 = 1'bx;
force `ANA_TOP.A2D_COMP_OUT_CH2 = 1'bx;
force `ANA_TOP.A2D_SPARE_RO_REG_0 = 8'bx;
`ifdef POSTLAYOUT
force `SOC_TB.VDD_DIG = 1'b0;
#10ns
`endif
force `SOC_TB.VDD_DIG = 1'b1;
end
endtask

  task do_run;
  begin
  //`DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
  
  `nnc_info("SOC_TEST", "[EPROM BIST MASTER][0] Sending Reset Command to EPROM", NNC_LOW);
  `BISTM_RESET();
  `nnc_info("SOC_TEST", "[EPROM BIST MASTER] Complete successully this phase", NNC_LOW);
  
  #150us;
  
  `BISTM_ENTIRE_READ(top_test_cfg.OTP_SEL, top_test_cfg.rd_data);
  foreach(top_test_cfg.rd_data[i]) begin
    if(top_test_cfg.rd_data[i] !== 0) `nnc_error("SOC_TEST", $sformatf("BIST rd_data[%0d]:%2h !== 0", i, top_test_cfg.rd_data[i]));
  end
  `BISTM_MARGIN_ENTIRE_READ(top_test_cfg.OTP_SEL, 2'b10, top_test_cfg.rd_data);
  foreach(top_test_cfg.rd_data[i]) begin
    if(top_test_cfg.rd_data[i] !== 0) `nnc_error("SOC_TEST", $sformatf("BIST rd_data[%0d]:%2h !== 0", i, top_test_cfg.rd_data[i]));
  end
  `BISTM_MARGIN_ENTIRE_READ(top_test_cfg.OTP_SEL, 2'b11, top_test_cfg.rd_data);
  foreach(top_test_cfg.rd_data[i]) begin
    if(top_test_cfg.rd_data[i] !== 0) `nnc_error("SOC_TEST", $sformatf("BIST rd_data[%0d]:%2h !== 0", i, top_test_cfg.rd_data[i]));
  end
                                    //addr                  wdata                      num           write   TM


  #10us;
  `BISTM_BYPASS(top_test_cfg.OTP_SEL, top_test_cfg.addr, top_test_cfg.wdata_in,           128, 1, 2'b00);  //by_pass prog
  `BISTM_BYPASS(top_test_cfg.OTP_SEL, top_test_cfg.addr, top_test_cfg.wdata_in,           128, 0, 2'b00);  //by_pass read
  `BISTM_STANDBY(top_test_cfg.OTP_SEL);  
  `BISTM_ENTIRE_READ(top_test_cfg.OTP_SEL, top_test_cfg.rd_data);
  foreach(top_test_cfg.rd_data[i]) begin
    if(top_test_cfg.rd_data[i] !== top_test_cfg.wdata_in[i]) `nnc_error("SOC_TEST", $sformatf("BIST rd_data[%0d]:%2h !== wr_data[%0d]:%2h", i, top_test_cfg.rd_data[i], i, top_test_cfg.wdata_in[i]));
  end  

  `BISTM_MARGIN_ENTIRE_READ(top_test_cfg.OTP_SEL, 2'b10, top_test_cfg.rd_data);
  foreach(top_test_cfg.rd_data[i]) begin
    if(top_test_cfg.rd_data[i] !== top_test_cfg.wdata_in[i]) `nnc_error("SOC_TEST", $sformatf("BIST rd_data[%0d]:%2h !== wr_data[%0d]:%2h", i, top_test_cfg.rd_data[i], i, top_test_cfg.wdata_in[i]));
  end

  `BISTM_MARGIN_ENTIRE_READ(top_test_cfg.OTP_SEL, 2'b11, top_test_cfg.rd_data); 
  foreach(top_test_cfg.rd_data[i]) begin
    if(top_test_cfg.rd_data[i] !== top_test_cfg.wdata_in[i]) `nnc_error("SOC_TEST", $sformatf("BIST rd_data[%0d]:%2h !== wr_data[%0d]:%2h", i, top_test_cfg.rd_data[i], i, top_test_cfg.wdata_in[i]));
  end  
  `BISTM_BYPASS(top_test_cfg.OTP_SEL, top_test_cfg.addr, top_test_cfg.wdata_in,           128, 0, 2'b10);  //by_pass mrgn_rd
  `BISTM_BYPASS(top_test_cfg.OTP_SEL, top_test_cfg.addr, top_test_cfg.wdata_in,           128, 0, 2'b11);  //by_pass mrgn_rd1
  
  repeat(10)  begin
    assert(top_test_cfg.randomize());
    `BISTM_BYPASS(top_test_cfg.OTP_SEL, top_test_cfg.addr, top_test_cfg.wdata_in, top_test_cfg.num_of_bytes, top_test_cfg.bist_write, top_test_cfg.TM);  //by_pass read   
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
