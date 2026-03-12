/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_otp_bist_test.sv                                                   
// Project	: Nanochap ENS1p4                                  		        
// Description	: Testcase soc_otp_bist_test                                             
// Designer	: pfwang@nanochap.com                                                                 
// Date		: 18-03-2024                                                                     
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_otp_bist_test
`define TESTCFG soc_otp_bist_test_cfg

class `TESTCFG extends soc_base_test_cfg;

  `nnc_object_utils(`TESTCFG)

  // ===============================================
  // Adding your new varialbles in config test
  // -----------------------------------------------
    rand logic [7:0] data[256];
    rand int         no_of_bytes; 
    rand logic [7:0] reg_addr;
    rand logic [7:0] cmd;
    logic [7:0]      rd_data[];
    logic [7:0]      wr_data[127:0];
  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_otp_bist_test_cfg");
    super.new(name);
    
  endfunction: new

  // ===============================================
  // Adding constraints of randomization
  // -----------------------------------------------

  // testmode_sel[1:0] : 00-Normal mode, 01: Scanmode, 10: BIST mode, 11 atm0/1/2/3/4
  constraint c_testmode_sel  { soft testmode_sel == 2'b10; }
  constraint c_wait_reset_en { soft wait_reset_en == 1'b0;}

  constraint c_OTP_SEL    { OTP_SEL inside {[0:1]};}

  // Enable/Disable to program OTP
  //constraint c_otp_program_en           { soft otp_program_en == 1'b1;}
/*
  constraint c_ctrl_bit   { ctrl_bit[0] == SRL;}
  constraint c_OTP_SEL    { OTP_SEL == 0;}
  // spimode_sel[1:0] :  
  constraint c_tPGM       {TCK_SEL == 2'b00 -> tPGM == 325;
                           TCK_SEL == 2'b01 -> tPGM == 3250;
                           TCK_SEL == 2'b10 -> tPGM == 6500;
                           TCK_SEL == 2'b11 -> tPGM == 10400;}
  constraint c_tPGM_RC     {TCK_SEL == 2'b00 -> tPGM_RC == 12;
                           TCK_SEL == 2'b01 -> tPGM_RC == 120;
                           TCK_SEL == 2'b10 -> tPGM_RC == 240;
                           TCK_SEL == 2'b11 -> tPGM_RC == 384;}  
  constraint c_vpp_pos_cnt {vpp_pos_cnt inside {[4:24]};}
  constraint c_vpp_neg_cnt {vpp_neg_cnt inside {[27+tPGM:42+tPGM]};}
  constraint c_vpp_pos_cnt_mult {vpp_pos_cnt_mult inside {[4:24]};}
  constraint c_vpp_neg_cnt_mult {vpp_neg_cnt_mult inside {[24+(tPGM+3)*128:24+(tPGM+3)*128+18]};}
  constraint c_no_of_bytes { soft no_of_bytes == 2; }
  constraint c_vpp_width  {vpp_width == (vpp_neg_cnt - vpp_pos_cnt);}
  constraint c_vpp_width_mult  {vpp_width_mult == (vpp_neg_cnt_mult - vpp_pos_cnt_mult);}
*/
  //constraint c_order {solve TCK_SEL before tPGM;}
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

  //rand logic [2:0] OTP_SEL;
  rand logic [7:0] ADDR;

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

    assert(top_test_cfg.randomize()  with {altf_sel == 0;});
    `DUT_IF.altf_sel = top_test_cfg.altf_sel;
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    `DUT_IF.wait_reset_en = top_test_cfg.wait_reset_en;
    `DUT_IF.OTP_SEL = top_test_cfg.OTP_SEL;  

    //`DUT_IF.otp_program_en = top_test_cfg.otp_program_en;
    //`DUT_IF.otp_vpp_delay = top_test_cfg.otp_vpp_delay;

    //`DUT_IF.dont_check_conf_first_en = top_test_cfg.dont_check_conf_first_en;

    // ==================
    // Scoreboard enables
    // ==================
    `EPROM_BIST_SCOREBOARD_EN = 1;

    phase.drop_objection(this);
  endtask : pre_reset_phase

  // -----------------------------------------
  // Declare the main_phase task of your test
  // -----------------------------------------
  virtual task main_phase(nnc_phase phase);
    phase.raise_objection(this);

    `nnc_info("SOC_TEST", "soc_otp_bist_test start", NNC_LOW)

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
    `nnc_info("SOC_TEST", "soc_otp_bist_test end now", NNC_LOW)
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

  `nnc_info("SOC_TEST", "[EPROM BIST MASTER][0] Sending Reset Command to EPROM", NNC_LOW);
  `BISTM_RESET;
  `nnc_info("SOC_TEST", "[EPROM BIST MASTER] Complete successully this phase", NNC_LOW);

  #150us;

  `BISTM_ENTIRE_READ(`DUT_IF.OTP_SEL, top_test_cfg.rd_data);
  foreach(top_test_cfg.rd_data[i]) begin
    if(top_test_cfg.rd_data[i] !== 0) `nnc_error("SOC_TEST", $sformatf("BIST rd_data[%0d]:%2h !== 0", i, top_test_cfg.rd_data[i]));
  end
  `BISTM_MARGIN_ENTIRE_READ(`DUT_IF.OTP_SEL, 2'b10, top_test_cfg.rd_data);
  foreach(top_test_cfg.rd_data[i]) begin
    if(top_test_cfg.rd_data[i] !== 0) `nnc_error("SOC_TEST", $sformatf("BIST rd_data[%0d]:%2h !== 0", i, top_test_cfg.rd_data[i]));
  end
  `BISTM_MARGIN_ENTIRE_READ(`DUT_IF.OTP_SEL, 2'b11, top_test_cfg.rd_data);
  foreach(top_test_cfg.rd_data[i]) begin
    if(top_test_cfg.rd_data[i] !== 0) `nnc_error("SOC_TEST", $sformatf("BIST rd_data[%0d]:%2h !== 0", i, top_test_cfg.rd_data[i]));
  end

  //`BISTM_BYPASS(1, 0, 55, 0, 0, 0);  //by_pass read


  for(ADDR=0; ADDR<128; ADDR++) begin
    assert(top_test_cfg.randomize())
    `BISTM_SINGLE_PROGRAM(`DUT_IF.OTP_SEL, ADDR, top_test_cfg.data_in, top_test_cfg.vpp_pos_cnt, top_test_cfg.vpp_width);
    top_test_cfg.wr_data[ADDR] = top_test_cfg.data_in;
  end
  //for(OTP_SEL=0; OTP_SEL<2; OTP_SEL++) begin
    for(ADDR=0; ADDR<128; ADDR++) begin
        `BISTM_SINGLE_READ(`DUT_IF.OTP_SEL, ADDR, top_test_cfg.rd_data[ADDR]);
    end
  //end
  foreach(top_test_cfg.rd_data[i]) begin
    if(top_test_cfg.rd_data[i] !== top_test_cfg.wr_data[i]) `nnc_error("SOC_TEST", $sformatf("BIST rd_data[%0d]:%2h !== wr_data[%0d]:%2h", i, top_test_cfg.rd_data[i], i, top_test_cfg.wr_data[i]));
  end

  //for(OTP_SEL=0; OTP_SEL<2; OTP_SEL++) begin
    for(ADDR=0; ADDR<128; ADDR++) begin
        `BISTM_MARGIN_SINGLE_READ(`DUT_IF.OTP_SEL, 2'b10, ADDR, top_test_cfg.rd_data[ADDR]);
    end
  //end
  foreach(top_test_cfg.rd_data[i]) begin
    if(top_test_cfg.rd_data[i] !== top_test_cfg.wr_data[i]) `nnc_error("SOC_TEST", $sformatf("BIST rd_data[%0d]:%2h !== wr_data[%0d]:%2h", i, top_test_cfg.rd_data[i], i, top_test_cfg.wr_data[i]));
  end
    for(ADDR=0; ADDR<128; ADDR++) begin
        `BISTM_MARGIN_SINGLE_READ(`DUT_IF.OTP_SEL, 2'b11, ADDR, top_test_cfg.rd_data[ADDR]);
    end
  foreach(top_test_cfg.rd_data[i]) begin
    if(top_test_cfg.rd_data[i] !== top_test_cfg.wr_data[i]) `nnc_error("SOC_TEST", $sformatf("BIST rd_data[%0d]:%2h !== wr_data[%0d]:%2h", i, top_test_cfg.rd_data[i], i, top_test_cfg.wr_data[i]));
  end
  `BISTM_ENTIRE_READ(`DUT_IF.OTP_SEL, top_test_cfg.rd_data);

  foreach(top_test_cfg.rd_data[i]) begin
    if(top_test_cfg.rd_data[i] !== top_test_cfg.wr_data[i]) `nnc_error("SOC_TEST", $sformatf("BIST rd_data[%0d]:%2h !== wr_data[%0d]:%2h", i, top_test_cfg.rd_data[i], i, top_test_cfg.wr_data[i]));
  end

  `BISTM_MARGIN_ENTIRE_READ(`DUT_IF.OTP_SEL, 2'b10, top_test_cfg.rd_data);
  foreach(top_test_cfg.rd_data[i]) begin
    if(top_test_cfg.rd_data[i] !== top_test_cfg.wr_data[i]) `nnc_error("SOC_TEST", $sformatf("BIST rd_data[%0d]:%2h !== wr_data[%0d]:%2h", i, top_test_cfg.rd_data[i], i, top_test_cfg.wr_data[i]));
  end
    
  `BISTM_MARGIN_ENTIRE_READ(`DUT_IF.OTP_SEL, 2'b11, top_test_cfg.rd_data);
  foreach(top_test_cfg.rd_data[i]) begin
    if(top_test_cfg.rd_data[i] !== top_test_cfg.wr_data[i]) `nnc_error("SOC_TEST", $sformatf("BIST rd_data[%0d]:%2h !== wr_data[%0d]:%2h", i, top_test_cfg.rd_data[i], i, top_test_cfg.wr_data[i]));
  end

  assert(top_test_cfg.randomize());
  `BISTM_ENTIRE_PROGRAM(`DUT_IF.OTP_SEL, top_test_cfg.data_in, top_test_cfg.vpp_pos_cnt_mult, top_test_cfg.vpp_width_mult);
  foreach(top_test_cfg.wr_data[i]) top_test_cfg.wr_data[i] = top_test_cfg.wr_data[i] | top_test_cfg.data_in;
 
  //for(OTP_SEL=0; OTP_SEL<2; OTP_SEL++) begin
    for(ADDR=0; ADDR<128; ADDR++) begin
        `BISTM_SINGLE_READ(`DUT_IF.OTP_SEL, ADDR, top_test_cfg.rd_data[ADDR]);
    end
  //end
  foreach(top_test_cfg.rd_data[i]) begin
    if(top_test_cfg.rd_data[i] !== top_test_cfg.wr_data[i]) `nnc_error("SOC_TEST", $sformatf("BIST rd_data[%0d]:%2h !== wr_data[%0d]:%2h", i, top_test_cfg.rd_data[i], i, top_test_cfg.wr_data[i]));
  end

  //for(OTP_SEL=0; OTP_SEL<2; OTP_SEL++) begin
    for(ADDR=0; ADDR<128; ADDR++) begin
        `BISTM_MARGIN_SINGLE_READ(`DUT_IF.OTP_SEL, 2'b10, ADDR, top_test_cfg.rd_data[ADDR]);
    end
  //end
  foreach(top_test_cfg.rd_data[i]) begin
    if(top_test_cfg.rd_data[i] !== top_test_cfg.wr_data[i]) `nnc_error("SOC_TEST", $sformatf("BIST rd_data[%0d]:%2h !== wr_data[%0d]:%2h", i, top_test_cfg.rd_data[i], i, top_test_cfg.wr_data[i]));
  end

    for(ADDR=0; ADDR<128; ADDR++) begin
        `BISTM_MARGIN_SINGLE_READ(`DUT_IF.OTP_SEL, 2'b11, ADDR, top_test_cfg.rd_data[ADDR]);
    end
  foreach(top_test_cfg.rd_data[i]) begin
    if(top_test_cfg.rd_data[i] !== top_test_cfg.wr_data[i]) `nnc_error("SOC_TEST", $sformatf("BIST rd_data[%0d]:%2h !== wr_data[%0d]:%2h", i, top_test_cfg.rd_data[i], i, top_test_cfg.wr_data[i]));
  end

  `BISTM_ENTIRE_READ(`DUT_IF.OTP_SEL, top_test_cfg.rd_data);
  foreach(top_test_cfg.rd_data[i]) begin
    if(top_test_cfg.rd_data[i] !== top_test_cfg.wr_data[i]) `nnc_error("SOC_TEST", $sformatf("BIST rd_data[%0d]:%2h !== wr_data[%0d]:%2h", i, top_test_cfg.rd_data[i], i, top_test_cfg.wr_data[i]));
  end

  `BISTM_MARGIN_ENTIRE_READ(`DUT_IF.OTP_SEL, 2'b10, top_test_cfg.rd_data);
  foreach(top_test_cfg.rd_data[i]) begin
    if(top_test_cfg.rd_data[i] !== top_test_cfg.wr_data[i]) `nnc_error("SOC_TEST", $sformatf("BIST rd_data[%0d]:%2h !== wr_data[%0d]:%2h", i, top_test_cfg.rd_data[i], i, top_test_cfg.wr_data[i]));
  end

  `BISTM_MARGIN_ENTIRE_READ(`DUT_IF.OTP_SEL, 2'b11, top_test_cfg.rd_data);
  foreach(top_test_cfg.rd_data[i]) begin
    if(top_test_cfg.rd_data[i] !== top_test_cfg.wr_data[i]) `nnc_error("SOC_TEST", $sformatf("BIST rd_data[%0d]:%2h !== wr_data[%0d]:%2h", i, top_test_cfg.rd_data[i], i, top_test_cfg.wr_data[i]));
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
