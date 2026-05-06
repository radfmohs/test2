/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_nirs_ppg_idac_manual_en_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_nirs_ppg_idac_manual_en_test                                             
// Designer	: supriya@nanochap.com                                                                 
// Date		: 15-01-2026                                                                     
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_nirs_ppg_idac_manual_en_test
`define TESTCFG soc_nirs_ppg_idac_manual_en_test_cfg

class `TESTCFG extends soc_nirs_ppg_base_test_cfg;

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

  function new (string name = "soc_nirs_ppg_idac_manual_en_test_cfg");
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
  
  //
  //constraint c_nirs_ppg_mode_sel { nirs_ppg_mode_sel ==1;}

  //
  //constraint c_nirs_ppg_meas     { nirs_ppg_meas ==1;}

  //
  //constraint c_nirs_ppg_en       { nirs_ppg_en == 1;}

 //NIRS_CTRL_5
 constraint c_idac_manual_en                {idac_manual_en == 1;} 
 // set FF
 //NIRS_CTRL_6
 constraint c_threshold_h_18_11              {threshold_h_18_11  inside {[0:0]};}
 //NIRS_CTRL_7
 constraint c_threshold_h_10_3              {threshold_h_10_3  inside {[24:24]};} //[7:7]
 //NIRS_CTRL_8
 constraint c_threshold_h_2_0                {threshold_h_2_0  inside {[0:0]};} //[31:31]
 //
 constraint c_led_stable_time_beforeipd_sw   {led_stable_time_beforeipd_sw  inside {[0:0]};}
 
  // -----------------------------------------------
  // End of adding constraints of randomization
  // ===============================================

endclass : `TESTCFG

// ===============================================
// Main Testcase is defined
// -----------------------------------------------
class `TESTNAME extends soc_nirs_ppg_base_test;
   
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

    `nnc_info("SOC_TEST", "soc_nirs_ppg_idac_manual_en_test start", NNC_LOW)

    // ==================================================================================
    // Please add your code of your test here
    // ---------------------------------------------------------------------------------- 
    
    // --------------------------------------------------------
    // This is an example RD_RESET_CHK_REG 
    // --------------------------------------------------------
    //assert(top_test_cfg.randomize() with {reg_addr == `SOC_ADDR_WG_DRV_CONFIG_REG0; expected_data == `INIT_SOC_ADDR_WG_DRV_CONFIG_REG0;});
    //`nnc_info("SOC_TEST", "Single Reading to a Register and doing a Check READ DATA with Initial values", NNC_LOW)
    //`RD_RESET_CHK_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.expected_data, top_test_cfg.pads);

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

    //// --------------------------------------------------------
    //// This is an example WR_RD_CHK_REG
    //// --------------------------------------------------------
    //assert(top_test_cfg.randomize() with {reg_addr == `SOC_ADDR_WG_DRV_CONFIG_REG0;});
    //`nnc_info("SOC_TEST", "Single Writing/Reading to a Register and doing a Check of DATAs", NNC_LOW)
    //`WR_RD_CHK_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads, top_test_cfg.mask);

    //// --------------------------------------------------------
    //// This is an example WR_BURST_REG - burst write to registers
    //// --------------------------------------------------------
    //assert(top_test_cfg.randomize() with {reg_addr == `SOC_ADDR_WG_DRV_CONFIG_REG0; no_of_bytes == 4;});
    //`nnc_info("SOC_TEST", "Burst Writing to Registers", NNC_LOW)
    //`WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //// --------------------------------------------------------
    //// This is an example RD_BURST_REG - burst read to registers
    //// --------------------------------------------------------
    //assert(top_test_cfg.randomize() with {reg_addr == `SOC_ADDR_WG_DRV_CONFIG_REG0; no_of_bytes == 4;});
    //`nnc_info("SOC_TEST", "Burst Reading to Registers", NNC_LOW)
    //`RD_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);


    //// ########################################################
    //// ########################################################
    //// --------------------------------------------------------
    //// --------------------------------------------------------
    //// NIRS/PPG Configration begins from here:
    //// --------------------------------------------------------
    //// --------------------------------------------------------
    //// ########################################################
    //// ########################################################
    for(int i=0; i<8; i++)begin
      `nnc_info("SOC_TEST", $sformatf("Configure for NIRS_CH[%0d]", i),NNC_LOW)
      configure_nirs_ctrl_regs(i);  //nirs from base test,nirs_addr_channel_en

      //At OFFSET 0XC4(SOC_NIRS_CTRL_5_REG)
      //bit[2:0] LEAD_STABLE_CTRL bit, Time for LED stable before D2A_NIRS_IPD_SW (0-10us, 1-20us, 2-40us, 3-60us, 4-80us, 5-1ms, 6-1.2ms, 7-1.4ms)
      `nnc_info("SOC_TEST", "Configure SOC_NIRS_CTRL_4_REG", NNC_LOW)
      //top_test_cfg.data[0] = {5'b0,top_test_cfg.led_stable_time_beforeipd_sw};
      assert(top_test_cfg.randomize() with {reg_addr == `SOC_NIRS_CTRL_4_REG; mask == 8'hff; data[0] == {3'b0,top_test_cfg.idac_manual_8, top_test_cfg.idac_manual_en, top_test_cfg.led_stable_time_beforeipd_sw};});
      `nnc_info("SOC_TEST", $sformatf("SOC_NIRS_CTRL_4_REG top_test_cfg.data[0]: %h ",top_test_cfg.data[0]), NNC_LOW)
      //`WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);
      `WR_NIRS_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads/*, top_test_cfg.mask*/);

      //At OFFSET 0XC2(SOC_NIRS_CTRL_2_REG)
      //bit[7:0] RATIO MANUAL
      `nnc_info("SOC_TEST", "Configure SOC_NIRS_CTRL_2_REG", NNC_LOW)
      assert(top_test_cfg.randomize() with {reg_addr == `SOC_NIRS_CTRL_2_REG; mask == 8'hff; data[0] == top_test_cfg.ratio_manual;});
      `nnc_info("SOC_TEST", $sformatf("SOC_NIRS_CTRL_2_REG top_test_cfg.data[0]: %h ",top_test_cfg.data[0]), NNC_LOW)
      `WR_NIRS_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);


//    //At OFFSET 0XC5[5:0], 0XC6[7:0], 0XC7[[7:3]: High Threshold for the IDAC auto cancellation
//    //0XC5[5:0] == [18:13], 0XC6[7:0] == [12:5], 0XC7[[7:3] == [4:0] (Total 19bits)
//    `nnc_info("SOC_TEST", "Configure SOC_NIRS_CTRL_6_REG", NNC_LOW)
//    //top_test_cfg.data[0] = {2'b0,top_test_cfg.threshold_h_18_13};
//    assert(top_test_cfg.randomize() with {reg_addr == `SOC_NIRS_CTRL_6_REG; mask == 8'hff; data[0] == {2'b0,top_test_cfg.threshold_h_18_13};});
//    `nnc_info("SOC_TEST", $sformatf("SOC_NIRS_CTRL_6_REG top_test_cfg.data[0]: %h ",top_test_cfg.data[0]), NNC_LOW)
//    `WR_NIRS_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);        
//
//    `nnc_info("SOC_TEST", "Configure SOC_NIRS_CTRL_7_REG", NNC_LOW)
//    //top_test_cfg.data[0] = top_test_cfg.threshold_h_12_5;
//    assert(top_test_cfg.randomize() with {reg_addr == `SOC_NIRS_CTRL_7_REG; mask == 8'hff; data[0] == top_test_cfg.threshold_h_12_5;});
//    `nnc_info("SOC_TEST", $sformatf("SOC_NIRS_CTRL_7_REG top_test_cfg.data[0]: %h ",top_test_cfg.data[0]), NNC_LOW)
//    `WR_NIRS_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);  
//
//    //0XC7[[7:3] == [4:0] High Threshold for the IDAC auto cancellation
//    //At OFFSET /0XC7[2:0] == [18:16] Low threshold for the IDAC auto cancellation
//    `nnc_info("SOC_TEST", "Configure SOC_NIRS_CTRL_8_REG", NNC_LOW)
//    //top_test_cfg.data[0] = {top_test_cfg.threshold_h_4_0, top_test_cfg.threshold_l_18_16};
//    assert(top_test_cfg.randomize() with {reg_addr == `SOC_NIRS_CTRL_8_REG; mask == 8'hff; data[0] == {top_test_cfg.threshold_h_4_0, top_test_cfg.threshold_l_18_16};});
//    `nnc_info("SOC_TEST", $sformatf("SOC_NIRS_CTRL_8_REG top_test_cfg.data[0]: %h ",top_test_cfg.data[0]), NNC_LOW)
//    `WR_NIRS_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);


      //1) MCU sets MODE_SEL to 2'b01(MCU MASTER SINGLE MODE)
      //At OFSET 0xC0(SOC_NIRS_CTRL_0_REG), bit[5:2]= 4'bxxx1 : MCU MASTER MODE (MODE_SEL)

      //2) MCU enables the NIRS receiver (by a register/command)
      //At OFSET 0xC0(SOC_NIRS_CTRL_0_REG),   bit[1]=1 : Start the measurement operation(only for master mode),

      //3) NIRS_ctrl turns ON analog receiver (D2A_NIRS_EN)
      //At OFSET 0xC1(SOC_NIRS_CTRL_0_REG),   
      `nnc_info("SOC_TEST", "Configure SOC_NIRS_CTRL_0_REG", NNC_LOW)    
      assert(top_test_cfg.randomize() with {reg_addr == `SOC_NIRS_CTRL_0_REG; mask == 8'hff; data[0] == {1'b0, top_test_cfg.ratio_ctrl, top_test_cfg.ratio_mode,top_test_cfg.nirs_ppg_mode_sel};});
      `nnc_info("SOC_TEST", $sformatf("top_test_cfg.data[0]: %h nirs_ppg_mode_sel: %h ratio_mode: %h ration_ctrl: %h",top_test_cfg.data[0], top_test_cfg.nirs_ppg_mode_sel, top_test_cfg.ratio_mode, top_test_cfg.ratio_ctrl), NNC_LOW)
      `WR_NIRS_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);

      //At OFFSET 0XCE[7:0]
      top_test_cfg.ch_en_mask |= (8'b1 << i);
      `nnc_info("SOC_TEST", $sformatf("Configure SOC_NIRS_CTRL_EN_REG top_test_cfg.ch_en_mask =8'b%b",top_test_cfg.ch_en_mask), NNC_LOW)
      `nnc_info("SOC_TEST", "Configure SOC_NIRS_CTRL_EN_REG", NNC_LOW)
      //top_test_cfg.data[0] = top_test_cfg.threshold_l_7_0;
      assert(top_test_cfg.randomize() with {reg_addr == `SOC_NIRS_CTRL_EN_REG; mask == 8'hff; data[0] == (({top_test_cfg.nirs_ppg_en7,top_test_cfg.nirs_ppg_en6,top_test_cfg.nirs_ppg_en5,top_test_cfg.nirs_ppg_en4,top_test_cfg.nirs_ppg_en3,top_test_cfg.nirs_ppg_en2,top_test_cfg.nirs_ppg_en1,top_test_cfg.nirs_ppg_en0}) & top_test_cfg.ch_en_mask);}); 
      `nnc_info("SOC_TEST", $sformatf("SOC_NIRS_CTRL_EN_REG top_test_cfg.data[0]: %h ",top_test_cfg.data[0]), NNC_LOW)                                                         
      `WR_NIRS_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);
        
      //4) Delay a programmable time to wait for analog receiver to be stable 

      //5) Start the state machine (D2A_NIRS_RESET_SW)  

      //6) MCU waits for reset to be low (self-calculation?) then starts the MEAS (by a register/command) 
      //7) NIRS_ctrl starts the sampling process (D2A_NIRS_IPD_SW) 
      //8) NIRS_ctrl waits falling edge of A2D_IREFFINE to latch data then generates interrupt and turns off analog receiver.
   end

    #5ms;
    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    #10000ns;
    `nnc_info("SOC_TEST", "soc_nirs_ppg_idac_manual_en_test end now", NNC_LOW)

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
