/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_nirs_ppg_base_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_nirs_ppg_base_test                                             
// Designer	: supriya@nanochap.com                                                                 
// Date		: 11-03-2026                                                                     
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_nirs_ppg_base_test
`define TESTCFG soc_nirs_ppg_base_test_cfg

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
 
  ///NIRS_CTRL_ADDRESS
  rand logic [2:0] nirs_channel_en;
  //NIRS_CTRL_0  
  rand logic [3:0] nirs_ppg_mode_sel;
  rand bit         nirs_ppg_meas;
  rand bit         nirs_ppg_en;
  //NIRS_CTRL_1
  rand logic [1:0] ratio_ctrl; 
  rand logic       ratio_mode;
  //NIRS_CTRL_1
  rand logic [7:0] ratio_manual; //ratio for DOUT
  //NIRS_CTRL_2
  rand logic [3:0] on_time_sel;
  rand logic [3:0] period_ctrl;
  //NIRS_CTRL_3
  rand logic [2:0] led_off_time_after_ipd_sw; 
  rand logic [2:0] recv_stable_time_ctrl;
  rand logic [2:0] reset_on_time_ctrl;
  //NIRS_CTRL_4
  rand logic [2:0] led_stable_time_beforeipd_sw;
  rand logic       idac_manual_8;                  
  rand logic       idac_manual_en;
  //NIRS_CTRL_5
  rand logic [7:0] idac_manual_7_0;
  //NIRS_CTRL_6
  rand logic [7:0] threshold_h_18_11;
  //NIRS_CTRL_7
  rand logic [7:0] threshold_h_10_3;
  //NIRS_CTRL_8
  rand logic [2:0] threshold_h_2_0; 
  rand logic [4:0] threshold_l_7_3;
  //NIRS_CTRL_9
  rand logic [2:0] threshold_l_2_0;
  //NIRS_CTRL_10
  rand logic       nirs_int_reg_en;
  rand logic       nirs_int_pin_en;
  //NIRS_CTRL_11: RESERVED
  //rand bit         nirs_idac_manual_autmatic;
  //NIRS_CTRL_12
  //rand logic [1:0] nirs_manual_value_of_idac;
  //NIRS_CLK_CTRL
  rand bit         ana_ppg_rst_reg;
  rand bit         ana_ppg_clk50duty; 
  rand logic [1:0] ana_ppg_clk_div;
  rand logic       ana_ppg_clk_inv;
  rand logic       ppg_dis;
  //NIRS_CTRL_EN
  rand logic       nirs_ppg_en0;
  rand logic       nirs_ppg_en1;
  rand logic       nirs_ppg_en2;
  rand logic       nirs_ppg_en3;
  rand logic       nirs_ppg_en4;
  rand logic       nirs_ppg_en5;
  rand logic       nirs_ppg_en6;
  rand logic       nirs_ppg_en7;
  //NIRS_CTRL_MEAS
  rand logic       nirs_ctrl_meas0; // only for MCU maste mode
  rand logic       nirs_ctrl_meas1; // only for MCU maste mode
  rand logic       nirs_ctrl_meas2; // only for MCU maste mode
  rand logic       nirs_ctrl_meas3; // only for MCU maste mode
  rand logic       nirs_ctrl_meas4; // only for MCU maste mode
  rand logic       nirs_ctrl_meas5; // only for MCU maste mode
  rand logic       nirs_ctrl_meas6; // only for MCU maste mode
  rand logic       nirs_ctrl_meas7; // only for MCU maste mode
  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_nirs_ppg_base_test_cfg");
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

 //********************************************************************************************************
 //************************************NIRS_PPG Related constarints****************************************
 //********************************************************************************************************
  //NIRS_CTRL_0

  constraint c_nirs_ppg_mode_sel   {nirs_ppg_mode_sel inside{0,4,2,6,1,15,8,14};}

  constraint c_nirs_ppg_meas       {nirs_ppg_meas inside {0,1};}

  constraint c_nirs_ppg_en         {nirs_ppg_en inside {0,1};}

  //NIRS_CTRL_1
  constraint c_ratio_mode         {ratio_mode  inside {[0:1]};} //ratio_mode=0: automatic, ration_mode=1: manual

  constraint c_ratio_ctrl          {ratio_ctrl  inside {[0:3]};} //this for automatic ration if ration_mode=0, 0-128, 1-64, 2-32, 3-16

  //NIRS_CTRL_2
  constraint c_ratio_manual        {ratio_manual inside{[0:255]};} //this ratio manual will be used if ratio_mode has been set to 1


  constraint c_ana_ppg_rst_reg    {ana_ppg_rst_reg ==1'b0;}

  constraint c_ana_ppg_clk_div    {ana_ppg_clk_div inside {[0:3]};}

  constraint c_ana_ppg_clk50duty  {solve ana_ppg_clk_div before ana_ppg_clk50duty;
                                  (ana_ppg_clk_div inside {2,3}) -> ana_ppg_clk50duty == 1'b1;
                                  (ana_ppg_clk_div inside {0,1}) -> ana_ppg_clk50duty == 1'b0;} 

  constraint c_ana_ppg_clk_inv    {ana_ppg_clk_inv inside {0,1};}

  constraint c_ppg_dis            {ppg_dis == 1'b0;}

  //
  constraint c_on_time_sel        {on_time_sel inside {[0:15]};}

  constraint c_period_ctrl        {period_ctrl inside {[0:15]};}

  //
  constraint c_led_off_time_after_ipd_sw  {led_off_time_after_ipd_sw inside {[0:3]};} 

  constraint c_recv_stable_time_ctrl      {recv_stable_time_ctrl inside {[0:7]};}

  constraint c_reset_on_time_ctrl         {reset_on_time_ctrl inside {[0:7]}; }

  //NIRS_CTRL_4
  constraint c_led_stable_time_beforeipd_sw   {led_stable_time_beforeipd_sw  inside {[0:7]};}
  constraint c_idac_manual_8                 {idac_manual_8 inside {[0:1]};}
  constraint c_idac_manual_en                {idac_manual_en == 0;}
  //NIRS_CTRL_5
  constraint c_idac_manual_7_0               {idac_manual_7_0 inside {[0:255]};}
  //NIRS_CTRL_6
  constraint c_threshold_h_18_11              {threshold_h_18_11  inside {[0:0/*0:255*/]};}
  //NIRS_CTRL_7
  constraint c_threshold_h_10_3               {threshold_h_10_3  inside {[0:0/*0:255*/]};}
  //NIRS_CTRL_8
  constraint c_threshold_h_2_0                {threshold_h_2_0  inside {[0:0/*0:7*/]};} 
  constraint c_threshold_l_7_3                {threshold_l_7_3 inside {[0:0/*0:31*/]};}   
  //NIRS_CTRL_9                                                                            
  constraint c_threshold_l_2_0                {threshold_l_2_0 inside {[0:0/*0:7*/]};}    

  //NIRS_CTRL_10
  //constraint c_threshold_l_7_0                {threshold_l_7_0 inside {[0:0/*0:255*/]};}
  //NIRS_CTRL_11
  //constraint c_nirs_idac_manual_autmatic      {nirs_idac_manual_autmatic inside {[0:0]};}
  //NIRS_CTRL_12
  //constraint c_nirs_manual_value_of_idac      {nirs_manual_value_of_idac inside {[0:3]};}

  //
  //constraint c_nirs_irefcoarse_iref_delay { nirs_irefcoarse_iref_delay inside {[0:2000]};}
  //NIRS_CTRL_ADDRESS
  constraint c_nirs_channel_en                {nirs_channel_en inside {[0:7]};} 
 //NIRS_CTRL_EN
 constraint c_nirs_ppg_en0                    {nirs_ppg_en0 inside {[0:1]};} 
 constraint c_nirs_ppg_en1                    {nirs_ppg_en1 inside {[0:1]};}
 constraint c_nirs_ppg_en2                    {nirs_ppg_en2 inside {[0:1]};}
 constraint c_nirs_ppg_en3                    {nirs_ppg_en3 inside {[0:1]};}
 constraint c_nirs_ppg_en4                    {nirs_ppg_en4 inside {[0:1]};}
 constraint c_nirs_ppg_en5                    {nirs_ppg_en5 inside {[0:1]};}
 constraint c_nirs_ppg_en6                    {nirs_ppg_en6 inside {[0:1]};}
 constraint c_nirs_ppg_en7                    {nirs_ppg_en7 inside {[0:1]};}
 //NIRS_CTRL_MEAS
 constraint c_nirs_ctrl_meas0                 {nirs_ctrl_meas0 inside {[0:1]};}
 constraint c_nirs_ctrl_meas1                 {nirs_ctrl_meas1 inside {[0:1]};}
 constraint c_nirs_ctrl_meas2                 {nirs_ctrl_meas2 inside {[0:1]};}
 constraint c_nirs_ctrl_meas3                 {nirs_ctrl_meas3 inside {[0:1]};}
 constraint c_nirs_ctrl_meas4                 {nirs_ctrl_meas4 inside {[0:1]};}
 constraint c_nirs_ctrl_meas5                 {nirs_ctrl_meas5 inside {[0:1]};}
 constraint c_nirs_ctrl_meas6                 {nirs_ctrl_meas6 inside {[0:1]};}
 constraint c_nirs_ctrl_meas7                 {nirs_ctrl_meas7 inside {[0:1]};}

 //********************************************************************************************************
 //************************************NIRS_PPG Related constarints****************************************
 //********************************************************************************************************


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

    //`DUT_IF.nirs_irefcoarse_iref_delay = top_test_cfg.nirs_irefcoarse_iref_delay;

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

    `nnc_info("SOC_TEST", "soc_nirs_ppg_base_test start", NNC_LOW)

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
   `nnc_info("SOC_TEST", $sformatf("\n\t\t\t\t\t\t\t\t\t\tHigh pulse length of SW2 nirs_irefcoarse_length: %dns",`DUT_IF.nirs_irefcoarse_length), NNC_LOW)
   `nnc_info("SOC_TEST", $sformatf("\n\t\t\t\t\t\t\t\t\t\tDelay between SW2 and SW3 nirs_irefcoarse_iref_delay: %dns", `DUT_IF.nirs_irefcoarse_iref_delay), NNC_LOW)
   `nnc_info("SOC_TEST", $sformatf("\n\t\t\t\t\t\t\t\t\t\tHigh pulse length of SW3 nirs_ireffine_length: %dns",`DUT_IF.nirs_ireffine_length), NNC_LOW) 

   //At OFFSET 0XC0(SOC_NIRS_CTRL_ADDRESS_REG)
   //bit[2:0]: set channel to control
   `nnc_info("SOC_TEST", "Configure SOC_NIRS_CTRL_ADDRESS_REG", NNC_LOW) 
   assert(top_test_cfg.randomize() with {reg_addr == `SOC_NIRS_CTRL_ADDRESS_REG; mask == 8'hff; data[0] == {5'b0, nirs_channel_en};});
   `nnc_info("SOC_TEST", $sformatf("SOC_NIRS_CTRL_ADDRESS_REG top_test_cfg.data[0]: %h ",top_test_cfg.data[0]), NNC_LOW)
   `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);
 
    //At OFFSET 0XC2(SOC_NIRS_CTRL_1_REG)
    //bit[7:4]: TOTAL PERIOD in ms, 
    //bit[3:0]: ON TIME SEL(OTS CTRL) in us, D2A_NIRS_IPD_SW ON_TIME
    `nnc_info("SOC_TEST", "Configure SOC_NIRS_CTRL_3_REG", NNC_LOW)
      assert(top_test_cfg.randomize() with {reg_addr == `SOC_NIRS_CTRL_3_REG; mask == 8'hff; data[0] == {5'b0, top_test_cfg.ratio_ctrl,top_test_cfg.ratio_mode};});
    `nnc_info("SOC_TEST", $sformatf("SOC_NIRS_CTRL_3_REG top_test_cfg.data[0]: %h ",top_test_cfg.data[0]), NNC_LOW)
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);

    //At OFFSET 0XC2(SOC_NIRS_CTRL_1_REG)
    //bit[7:4]: TOTAL PERIOD in ms, 
    //bit[3:0]: ON TIME SEL(OTS CTRL) in us, D2A_NIRS_IPD_SW ON_TIME
    `nnc_info("SOC_TEST", "Configure SOC_NIRS_CTRL_1_REG", NNC_LOW)
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_NIRS_CTRL_1_REG; mask == 8'hff; data[0] == {top_test_cfg.ratio_manual};});
    `nnc_info("SOC_TEST", $sformatf("SOC_NIRS_CTRL_1_REG top_test_cfg.data[0]: %h ",top_test_cfg.data[0]), NNC_LOW)
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);


    //At OFFSET 0XC3(SOC_NIRS_CTRL_2_REG)
    //bit[7:4]: TOTAL PERIOD in ms, 
    //bit[3:0]: ON TIME SEL(OTS CTRL) in us, D2A_NIRS_IPD_SW ON_TIME
    `nnc_info("SOC_TEST", "Configure SOC_NIRS_CTRL_2_REG", NNC_LOW)
    //top_test_cfg.data[0] = {top_test_cfg.on_time_sel,top_test_cfg.period_ctrl};
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_NIRS_CTRL_2_REG; mask == 8'hff; data[0] == {top_test_cfg.on_time_sel,top_test_cfg.period_ctrl};});
    `nnc_info("SOC_TEST", $sformatf("SOC_NIRS_CTRL_2_REG top_test_cfg.data[0]: %h ",top_test_cfg.data[0]), NNC_LOW)
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);

    //At OFFSET 0XC3(SOC_NIRS_CTRL_3_REG)
    //bit[7:6] LED_OFF after IPD_SW (0-0us, 1-1us, 2-2us, 3-3us)
    //bit[5:3] time for receiver stable after D2A_NIRS_EN (0-10us, 1-20us, 2-40us, 3-60us, 4-80us, 5-1ms, 6-1.2ms, 7-1.4ms)
    //bit[2:0] RESET D2A_NIRS_RESET_SW ON TIMER (0-10us, 1-20us, 2-30us, 3-40us, 4-50us, 5-60us, 6,-70us, 7-80us)
    `nnc_info("SOC_TEST", "Configure SOC_NIRS_CTRL_3_REG", NNC_LOW)
    //top_test_cfg.data[0] = {top_test_cfg.led_off_time_after_ipd_sw, top_test_cfg.recv_stable_time_ctrl,top_test_cfg.reset_on_time_ctrl};
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_NIRS_CTRL_3_REG; mask == 8'hff; data[0] == {top_test_cfg.led_off_time_after_ipd_sw, top_test_cfg.recv_stable_time_ctrl,top_test_cfg.reset_on_time_ctrl};});
    `nnc_info("SOC_TEST", $sformatf("SOC_NIRS_CTRL_3_REG top_test_cfg.data[0]: %h ",top_test_cfg.data[0]), NNC_LOW)
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);

    //At OFFSET 0XC5(SOC_NIRS_CTRL_4_REG)
    //bit[2:0] LEAD_STABLE_CTRL bit, Time for LED stable before D2A_NIRS_IPD_SW (0-10us, 1-20us, 2-40us, 3-60us, 4-80us, 5-1ms, 6-1.2ms, 7-1.4ms)
    //bit[3]: IDAC_MANUAL_EN
    //bit[4]: IDAC_MANUAL[8]
    `nnc_info("SOC_TEST", "Configure SOC_NIRS_CTRL_4_REG", NNC_LOW)
    //top_test_cfg.data[0] = {5'b0,top_test_cfg.led_stable_time_beforeipd_sw};
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_NIRS_CTRL_4_REG; mask == 8'hff; data[0] == {3'b0,top_test_cfg.idac_manual_8,  top_test_cfg.idac_manual_en, top_test_cfg.led_stable_time_beforeipd_sw};});
    `nnc_info("SOC_TEST", $sformatf("SOC_NIRS_CTRL_4_REG top_test_cfg.data[0]: %h ",top_test_cfg.data[0]), NNC_LOW)
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);

    //At OFFSET 0XC6(SOC_NIRS_CTRL_5_REG)
    //bit[7:0]: IDAC_MANUAL[7:0]
    `nnc_info("SOC_TEST", "Configure SOC_NIRS_CTRL_5_REG", NNC_LOW)
    //top_test_cfg.data[0] = {5'b0,top_test_cfg.led_stable_time_beforeipd_sw};
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_NIRS_CTRL_5_REG; mask == 8'hff; data[0] == top_test_cfg.idac_manual_7_0;});
    `nnc_info("SOC_TEST", $sformatf("SOC_NIRS_CTRL_5_REG top_test_cfg.data[0]: %h ",top_test_cfg.data[0]), NNC_LOW)
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);

    //At OFFSET 0XC7[7:0], 0XC7[7:0], 0XC9[[2:0]: High Threshold for the IDAC auto cancellation
    //0XC7[7:0] == [18:11], 0XC8[7:0] == [10:3], 0XC9[[2:0] == [2:0] (Total 19bits)
    `nnc_info("SOC_TEST", "Configure SOC_NIRS_CTRL_6_REG", NNC_LOW)
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_NIRS_CTRL_6_REG; mask == 8'hff; data[0] == top_test_cfg.threshold_h_18_11;});  
    `nnc_info("SOC_TEST", $sformatf("SOC_NIRS_CTRL_6_REG top_test_cfg.data[0]: %h ",top_test_cfg.data[0]), NNC_LOW)                                                
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);                                                              
                                                                                                                                                                   
    `nnc_info("SOC_TEST", "Configure SOC_NIRS_CTRL_7_REG", NNC_LOW)                                                                               
      assert(top_test_cfg.randomize() with {reg_addr == `SOC_NIRS_CTRL_7_REG; mask == 8'hff; data[0] == top_test_cfg.threshold_h_10_3;});
    `nnc_info("SOC_TEST", $sformatf("SOC_NIRS_CTRL_7_REG top_test_cfg.data[0]: %h ",top_test_cfg.data[0]), NNC_LOW)
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);  

    //0XC9[[7:5] == [2:0] High Threshold for the IDAC auto cancellation
    //At OFFSET /0XC9[2:0] == [18:16] Low threshold for the IDAC auto cancellation
    `nnc_info("SOC_TEST", "Configure SOC_NIRS_CTRL_8_REG", NNC_LOW)
    //top_test_cfg.data[0] = {top_test_cfg.threshold_h_2_0, top_test_cfg.threshold_l_7_3};
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_NIRS_CTRL_8_REG; mask == 8'hff; data[0] == {top_test_cfg.threshold_h_2_0, top_test_cfg.threshold_l_7_3};});  
    `nnc_info("SOC_TEST", $sformatf("SOC_NIRS_CTRL_8_REG top_test_cfg.data[0]: %h ",top_test_cfg.data[0]), NNC_LOW)                                                                       
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);                                                                                       


    //At OFFSET 0XCA[2:0], : Low threshold for the IDAC auto cancellation
    //0xC9[4:0] == [7:3],  0XCA[7:5] == [2:0] (Total 8bits)
    `nnc_info("SOC_TEST", "Configure SOC_NIRS_CTRL_9_REG", NNC_LOW)
    //top_test_cfg.data[0] = top_test_cfg.threshold_l_15_18;
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_NIRS_CTRL_9_REG; mask == 8'hff; data[0] == {top_test_cfg.threshold_l_2_0, 5'b0};});
    `nnc_info("SOC_TEST", $sformatf("SOC_NIRS_CTRL_9_REG top_test_cfg.data[0]: %h ",top_test_cfg.data[0]), NNC_LOW)
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads); 

    //`nnc_info("SOC_TEST", "Configure SOC_NIRS_CTRL_10_REG", NNC_LOW)
    ////top_test_cfg.data[0] = top_test_cfg.threshold_l_7_0;
    //assert(top_test_cfg.randomize() with {reg_addr == `SOC_NIRS_CTRL_10_REG; mask == 8'hff; data[0] == top_test_cfg.threshold_l_7_0;});
    //`nnc_info("SOC_TEST", $sformatf("SOC_NIRS_CTRL_10_REG top_test_cfg.data[0]: %h ",top_test_cfg.data[0]), NNC_LOW)
    //`WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads); 

    ////At OFFSET 0XCC[0] = 0 working mode of IDAC is automatic, 1 working mode of IDAC is manual
    //`nnc_info("SOC_TEST", "Configure SOC_NIRS_CTRL_11_REG", NNC_LOW)
    ////top_test_cfg.data[0] = {7'b0, top_test_cfg.nirs_idac_manual_autmatic};
    //assert(top_test_cfg.randomize() with {reg_addr == `SOC_NIRS_CTRL_11_REG; mask == 8'hff; data[0] == {7'b0, top_test_cfg.nirs_idac_manual_autmatic};});
    //`nnc_info("SOC_TEST", $sformatf("SOC_NIRS_CTRL_11_REG top_test_cfg.data[0]: %h ",top_test_cfg.data[0]), NNC_LOW)
    //`WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads); 

    // //At OFFSET 0XCD[1:0] = 0 Manual values of IDAC
    //`nnc_info("SOC_TEST", "Configure SOC_NIRS_CTRL_12_REG", NNC_LOW)
    ////top_test_cfg.data[0] = {7'b0, top_test_cfg.nirs_manual_value_of_idac};
    //assert(top_test_cfg.randomize() with {reg_addr == `SOC_NIRS_CTRL_12_REG; mask == 8'hff; data[0] == {7'b0, top_test_cfg.nirs_manual_value_of_idac};});
    //`nnc_info("SOC_TEST", $sformatf("SOC_NIRS_CTRL_12_REG top_test_cfg.data[0]: %h ",top_test_cfg.data[0]), NNC_LOW)
    //`WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads); 

    //At OFFSET 0XCB[1:0] = 0 nirs_int_reg_en,nirs_int_pin_en
    `nnc_info("SOC_TEST", "Configure SOC_NIRS_CTRL_10_REG", NNC_LOW)
    //top_test_cfg.data[0] = top_test_cfg.threshold_l_7_0;
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_NIRS_CTRL_10_REG; mask == 8'hff; data[0] == {6'b0, top_test_cfg.nirs_int_reg_en,top_test_cfg.nirs_int_pin_en};});
    `nnc_info("SOC_TEST", $sformatf("SOC_NIRS_CTRL_10_REG top_test_cfg.data[0]: %h ",top_test_cfg.data[0]), NNC_LOW)
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);

    //At OFFSET 0XCD(NIRS_CTRL_*)
    //bit[5] Software reset PPG module
    //bit[4] = 0 not 50% duty cycle, =1 PPG CLK50% Duty cycle  (only effective PPG_CLK_DIV =2 or 3)
    //bit[3:2] PPG_CLK_DIV (0-8MHZ, 1-6MHZ, 2-4MHZ, 3-2MHZ)
    //bit[1]  =0 same phase (analog ppg clock same as digital ppg clock), =1 invert phase(analog ppg clock invert with digital ppg clock
    //bit[0]  =0 Enable NIRS module, 1= Disable NIRS module 
    `nnc_info("SOC_TEST", "Configure SOC_NIRS_CTRL_CLK_REG", NNC_LOW)      
    //top_test_cfg.data[0] = {2'b0, top_test_cfg.ana_ppg_rst_reg, top_test_cfg.ana_ppg_clk50duty, top_test_cfg.ana_ppg_clk_div, top_test_cfg.ana_ppg_clk_inv,top_test_cfg.ppg_dis};
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_NIRS_CTRL_CLK_REG; mask == 8'hff; data[0] == {2'b0, top_test_cfg.ana_ppg_rst_reg, top_test_cfg.ana_ppg_clk50duty, top_test_cfg.ana_ppg_clk_div, top_test_cfg.ana_ppg_clk_inv,top_test_cfg.ppg_dis};});
    `nnc_info("SOC_TEST", $sformatf("SOC_NIRS_CTRL_CLK_REG top_test_cfg.data[0]: %h ",top_test_cfg.data[0]), NNC_LOW) 
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);

    //At OFFSET 0XCE[7:0]
    `nnc_info("SOC_TEST", "Configure SOC_NIRS_CTRL_EN_REG", NNC_LOW)
    //top_test_cfg.data[0] = top_test_cfg.threshold_l_7_0;
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_NIRS_CTRL_EN_REG; mask == 8'hff; data[0] == {top_test_cfg.nirs_ppg_en7,top_test_cfg.nirs_ppg_en6,top_test_cfg.nirs_ppg_en5,top_test_cfg.nirs_ppg_en4,top_test_cfg.nirs_ppg_en3,top_test_cfg.nirs_ppg_en2,top_test_cfg.nirs_ppg_en1,top_test_cfg.nirs_ppg_en0};}); 
    `nnc_info("SOC_TEST", $sformatf("SOC_NIRS_CTRL_EN_REG top_test_cfg.data[0]: %h ",top_test_cfg.data[0]), NNC_LOW)                                                         
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);   

    //At OFFSET 0XCF[7:0]
    `nnc_info("SOC_TEST", "Configure SOC_NIRS_CTRL_MEAS_REG", NNC_LOW)
    //top_test_cfg.data[0] = top_test_cfg.threshold_l_7_0;
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_NIRS_CTRL_MEAS_REG; mask == 8'hff; data[0] == {top_test_cfg.nirs_ctrl_meas7,top_test_cfg.nirs_ctrl_meas6,top_test_cfg.nirs_ctrl_meas5,top_test_cfg.nirs_ctrl_meas4,top_test_cfg.nirs_ctrl_meas3,top_test_cfg.nirs_ctrl_meas2,top_test_cfg.nirs_ctrl_meas1,top_test_cfg.nirs_ctrl_meas0};}); 
    `nnc_info("SOC_TEST", $sformatf("SOC_NIRS_CTRL_MEAS_REG top_test_cfg.data[0]: %h ",top_test_cfg.data[0]), NNC_LOW)                                                         
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);                                                                                          
                                                                                                                                                                             
                                                                                                                                                                             
    // --------------------------------------------------------                                                                                                              
    // End of test and add any needed delay time                                                                                                                             
    // --------------------------------------------------------                                                                                                              
    #10000ns;                                                                                                                  
    `nnc_info("SOC_TEST", "soc_nirs_ppg_base_test end now", NNC_LOW)                                                           

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
