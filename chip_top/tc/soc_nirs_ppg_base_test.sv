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


 logic [7:0]     NO_OF_BYTES; 

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
  rand logic [7:0]     ch_en_mask;
  bit        [7:0]     temp_ch_n = 8'h0;
  int                  temp_num_ch_en =0;
  logic [7:0]          nirs_rd_data_burst[];
  rand logic      [1:0]num_of_leds_loop;
  rand logic      [1:0]temp_en_config_leds;
  logic [7:0]          nirs_read_intr_status;
  //general interrupt register  
  rand bit            gen_reg_int_clr_typ;      //applied to both INT PIN aswell as don't use INT PIN 
  rand bit            gen_reg_int_length_sel;   //applies ti INT PIN (IOPAD)
  rand bit            gen_reg_int_active_level; //applies to INT PIN(IOPAD)     
  rand bit            clear_int_via_gen_int_sts_reg_or_nirs_int_sts_reg;
  //rand logic [2:0] nirs_addr_channel_en;
  //nirs_ctrl_channel
//  rand bit         en_config_ch0;
//  rand bit         en_config_ch1;
//  rand bit         en_config_ch2;
//  rand bit         en_config_ch3;  
//  rand bit         en_config_ch4;
//  rand bit         en_config_ch5;
//  rand bit         en_config_ch6;
//  rand bit         en_config_ch7;
//  //nirs_ctrl_led
//  rand bit         en_config_led0;
//  rand bit         en_config_led1;
//
//  //NIRS_CTRL_0
//  rand logic [3:0] on_time_sel;
//  rand logic [3:0] period_ctrl;
//
//  //NIRS_CTRL_1
//  rand logic [1:0] led_off_time_after_ipd_sw; 
//  //rand logic [2:0] recv_stable_time_ctrl;
//  rand logic [2:0] led_stable_time_beforeipd_sw;
//  rand logic [2:0] reset_on_time_ctrl;            
//  
//  //NIRS_CTRL_2
//  rand logic [8:0] idac_manual_8_0;
//
//  //NIRS_CTRL_3
//  //
//  rand bit         idac_manual_en;
//  rand bit         idac_en;
//  rand logic [2:0] threshold_h_18_16;
//  //NIRS_CTRL_4
//  //NIRS_CTRL_4
//  rand logic [7:0] threshold_h_15_8; 
//
//  //NIRS_CTRL_5
//  rand logic [7:0] threshold_h_7_0; 
//
//  //NIRS_CTRL_6
//  rand logic [7:0] threshold_l_7_0;
//
//  //NIRS_CTRL_7
//  rand bit         idac_min_int_en;
//  rand bit         idac_max_int_en;
//  rand bit         iref_fine_on_not_off_en;
//  rand bit         iref_fine_not_on_en;
//  rand bit         iref_coarse_en;
//  rand bit         data_ready_en;
//  rand bit         nirs_int_pin_en;                      
//
//  //nirs_ctrl_mode
//  rand logic [3:0] nirs_ppg_mode_sel;
//  rand bit         nirs_ppg_led_signle_en;
//
//  //nirs_ctrl_adj0
//  rand bit         pdbias_en;
//  rand logic [1:0] pdbias_adj;
//  rand logic [1:0] fchop_adj;
//  rand bit         chopper_en;
//  rand bit         test_en;
//  //nirs_ctrl_adj1
//  rand logic [1:0] ipdmirror_ratio_adj;
//  rand logic [1:0] iref_ratio_adj;  
//  rand logic [1:0] ratio_ctrl; 
//  rand bit         ratio_mode;        
//  //nirs_ctrl_adj2
//  rand logic [7:0] ratio_manual;
//
//  //NIRS_CLK_CTRL
//  rand bit         ana_ppg_rst_reg;
//  rand bit         ana_ppg_clk50duty; 
//  rand logic [1:0] ana_ppg_clk_div;
//  rand logic       ana_ppg_clk_inv;
//  rand logic       ppg_dis;
//
//  //nirs_ctrl_cmd
//  rand logic [1:0] nirs_ppg_cmd;
// 
//  //nirs_debug_sel
//  rand bit         debug_led;
//  rand logic [3:0] debug_channel;

  //nirs_debug_0
  logic [7:0]      read_nirs_debug_0;
  //nirs_debug_1
  logic [7:0]      read_nirs_debug_1;
  //nirs_debug_2
  logic [7:0]      read_nirs_debug_2;
  //nirs_debug_3
  logic [7:0]      read_nirs_debug_3;
  //nirs_debug_3
  logic [7:0]      read_nirs_debug_4;

  //nirs_int_status
  logic [7:0]      read_nirs_status;

  //nirs_dout0_0 
  logic [7:0]      read_nirs_dout0_0;
  //nirs_dout0_1
  logic [7:0]      read_nirs_dout0_1;
  //nirs_dout0_2
  logic [7:0]      read_nirs_dout0_2;
  //nirs_dout0_3
  logic [7:0]      read_nirs_dout0_3;

  //nirs_dout1_0 
  logic [7:0]      read_nirs_dout1_0;
  //nirs_dout1_1
  logic [7:0]      read_nirs_dout1_1;
  //nirs_dout1_2
  logic [7:0]      read_nirs_dout1_2;
  //nirs_dout1_3
  logic [7:0]      read_nirs_dout1_3;

  //nirs_dout2_0
  logic [7:0]      read_nirs_dout2_0; 
  //nirs_dout2_1
  logic [7:0]      read_nirs_dout2_1;
  //nirs_dout2_2
  logic [7:0]      read_nirs_dout2_2;
  //nirs_dout2_3
  logic [7:0]      read_nirs_dout2_3;

  //nirs_dout3_0
  logic [7:0]      read_nirs_dout3_0; 
  //nirs_dout3_1
  logic [7:0]      read_nirs_dout3_1;
  //nirs_dout3_2
  logic [7:0]      read_nirs_dout3_2;
  //nirs_dout3_3
  logic [7:0]      read_nirs_dout3_3;

  //nirs_dout4_0 
  logic [7:0]      read_nirs_dout4_0;
  //nirs_dout4_1
  logic [7:0]      read_nirs_dout4_1;
  //nirs_dout4_2
  logic [7:0]      read_nirs_dout4_2;
  //nirs_dout4_3
  logic [7:0]      read_nirs_dout4_3;

  //nirs_dout5_0
  logic [7:0]      read_nirs_dout5_0; 
  //nirs_dout5_1
  logic [7:0]      read_nirs_dout5_1;
  //nirs_dout5_2
  logic [7:0]      read_nirs_dout5_2;
  //nirs_dout5_3
  logic [7:0]      read_nirs_dout5_3;

  //nirs_dout6_0
  logic [7:0]      read_nirs_dout6_0; 
  //nirs_dout6_1
  logic [7:0]      read_nirs_dout6_1;
  //nirs_dout6_2
  logic [7:0]      read_nirs_dout6_2;
  //nirs_dout6_3
  logic [7:0]      read_nirs_dout6_3;

  //nirs_dout7_0
  logic [7:0]      read_nirs_dout7_0; 
  //nirs_dout7_1
  logic [7:0]      read_nirs_dout7_1;
  //nirs_dout7_2
  logic [7:0]      read_nirs_dout7_2;
  //nirs_dout7_3
  logic [7:0]      read_nirs_dout7_3;

  ////NIRS_CTRL_0  
  //rand logic [3:0] nirs_ppg_mode_sel;
  ////rand bit         nirs_ppg_meas;
  ////rand bit         nirs_ppg_en;
  //rand logic [1:0] ratio_ctrl; 
  //rand logic       ratio_mode;
  ////NIRS_CTRL_1
  //rand logic [7:0] ratio_manual; //ratio for DOUT
  //NIRS_CTRL_4
  //rand logic [2:0] led_stable_time_beforeipd_sw;
  //rand logic       idac_manual_8;                  
  //rand logic       idac_manual_en;
  //NIRS_CTRL_5
  //rand logic [7:0] idac_manual_7_0;
  //NIRS_CTRL_6
  //rand logic [7:0] threshold_h_18_11;
  //NIRS_CTRL_7
  //rand logic [7:0] threshold_h_10_3;
  //NIRS_CTRL_8
  //rand logic [2:0] threshold_h_2_0; 
  //rand logic [4:0] threshold_l_7_3;
  //NIRS_CTRL_9
  //rand logic [2:0] threshold_l_2_0;
  //NIRS_CTRL_10
  //rand logic       nirs_int_reg_en;
  //rand logic       nirs_int_pin_en;
  //NIRS_CTRL_11: RESERVED
  //rand bit         nirs_idac_manual_autmatic;
  //NIRS_CTRL_12
  //rand logic [1:0] nirs_manual_value_of_idac;
  //NIRS_CTRL_EN
//  rand logic       nirs_ppg_en0;
//  rand logic       nirs_ppg_en1;
//  rand logic       nirs_ppg_en2;
//  rand logic       nirs_ppg_en3;
//  rand logic       nirs_ppg_en4;
//  rand logic       nirs_ppg_en5;
//  rand logic       nirs_ppg_en6;
//  rand logic       nirs_ppg_en7;
//  //NIRS_CTRL_MEAS
//  rand logic       nirs_ctrl_meas0; // only for MCU maste mode
//  rand logic       nirs_ctrl_meas1; // only for MCU maste mode
//  rand logic       nirs_ctrl_meas2; // only for MCU maste mode
//  rand logic       nirs_ctrl_meas3; // only for MCU maste mode
//  rand logic       nirs_ctrl_meas4; // only for MCU maste mode
//  rand logic       nirs_ctrl_meas5; // only for MCU maste mode
//  rand logic       nirs_ctrl_meas6; // only for MCU maste mode
//  rand logic       nirs_ctrl_meas7; // only for MCU maste mode
//  
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
 //************************************NIRS_PPG Related constarints starts****************************************
 //********************************************************************************************************
 constraint c_num_of_leds_loop {num_of_leds_loop ==2;}
 constraint c_ch_en_mask {ch_en_mask inside {[1:255]};}
  //nirs_ctrl_channel


//  constraint c_en_config_ch0  {en_config_ch0 inside {0,1};}
//  constraint c_en_config_ch1  {en_config_ch1 inside {0,1};}
//  constraint c_en_config_ch2  {en_config_ch2 inside {0,1};}
//  constraint c_en_config_ch3  {en_config_ch3 inside {0,1};}
//  constraint c_en_config_ch4  {en_config_ch4 inside {0,1};}
//  constraint c_en_config_ch5  {en_config_ch5 inside {0,1};}
//  constraint c_en_config_ch6  {en_config_ch6 inside {0,1};}
//  constraint c_en_config_ch7  {en_config_ch7 inside {0,1};}
//
//  //nirs_ctrl_led
//  constraint c_en_config_led0 {en_config_led0 inside {0,1};}
//  //make sure atleast one led enabled, if led0 ==0 then enable led1==1 otheriwse led1 can be 0/1
//  constraint c_en_config_led1 {(en_config_led0 == 0) -> (en_config_led1 == 1);}
//
//  //nirs_ctrl_0
//  constraint c_on_time_sel        {on_time_sel inside {[0:15]};}
//  constraint c_period_ctrl        {period_ctrl inside {[0:15]};}
//
//  //NIRS_CTRL_1
//  constraint c_led_off_time_after_ipd_sw      {led_off_time_after_ipd_sw inside {[0:3]};} 
//  constraint c_led_stable_time_beforeipd_sw   {led_stable_time_beforeipd_sw  inside {[0:7]};}
//  constraint c_reset_on_time_ctrl             {reset_on_time_ctrl inside {[0:7]}; }
//
//  //NIRS_CTRL_2, NIRS_CTRL_3
//  constraint c_idac_manual_8_0               {idac_manual_8_0 inside {[0:511]};}
// 
//  constraint c_idac_manual_en                {idac_manual_en == 0;}
//  constraint c_idac_en                       {idac_en inside {0,1};}  //for analog
//  constraint c_threshold_h_18_16             {threshold_h_18_16  inside {[0:7]};}
//
//  //NIRS_CTRL_4
//  constraint c_threshold_h_15_8              {threshold_h_15_8  inside {[0:127]};}
//
//  //NIRS_CTRL_5
//  constraint c_threshold_h_7_0               {threshold_h_7_0  inside {[0:127]};}
//
//  //NIRS_CTRL_6
//  constraint c_threshold_l_7_0               {threshold_l_7_0  inside {[0:127]};}
// 
//  //NIRS_CTRL_7
//  constraint c_idac_min_int_en              {idac_min_int_en inside {0,1};}            
//  constraint c_idac_max_int_en              {idac_max_int_en inside {0,1};}
//  constraint c_iref_fine_on_not_off_en      {iref_fine_on_not_off_en inside {0,1};}
//  constraint c_iref_fine_not_on_en          {iref_fine_not_on_en inside {0,1};}
//  constraint c_iref_coarse_en               {iref_coarse_en inside {0,1};}
//  constraint c_data_ready_en                {data_ready_en inside {0,1};}
//  constraint c_nirs_int_pin_en              {nirs_int_pin_en inside {0,1}; }           
//  
//  //NIRS_CTRL_MODE  
//  constraint c_nirs_ppg_mode_sel            {nirs_ppg_mode_sel inside {0,4,2,6,1,9,11,13,15,8,10,12,14};}
//  constraint c_nirs_ppg_led_signle_en       {nirs_ppg_led_signle_en inside {0, 1};}
//
//  //NIRS-CTRL-ADJ0
//
//  //NIRS_CTRL_ADJ1
//  constraint c_ratio_mode         {ratio_mode  inside {[0:1]};}      //ratio_mode=0: automatic, ration_mode=1: manual
//  constraint c_ratio_ctrl          {ratio_ctrl  inside {[0:3]};}     //this for automatic ration if ration_mode=0, 0-128, 1-64, 2-32, 3-16
//
//  //NIRS_CTRL_ADJ2
//  constraint c_ratio_manual        {ratio_manual inside{[0:255]};}   //this ratio manual will be used if ratio_mode has been set to 1
//
//  constraint c_ana_ppg_rst_reg    {ana_ppg_rst_reg ==1'b0;}
//  constraint c_ana_ppg_clk_div    {ana_ppg_clk_div inside {[0:3]};}
//  constraint c_ana_ppg_clk50duty  {solve ana_ppg_clk_div before ana_ppg_clk50duty;
//                                  (ana_ppg_clk_div inside {2,3}) -> ana_ppg_clk50duty == 1'b1;   
//                                  (ana_ppg_clk_div inside {0,1}) -> ana_ppg_clk50duty == 1'b0; 
//                                  (ana_ppg_clk_div inside {0,1}) -> ana_ppg_clk50duty == 1'b0;} 
//  constraint c_ana_ppg_clk_inv    {ana_ppg_clk_inv inside {0,1};}
//  constraint c_ppg_dis            {ppg_dis == 1'b0;}
//
//  //NIRS_CTRL_CMD
//  constraint c_nirs_ppg_cmd       {nirs_ppg_cmd == 0;}  //0,1,2,3
//               
// 
//  //NIRS_DEBUG_SEL                
//  constraint  c_debug_led         {debug_led inside {0,1};}
//  constraint  c_debug_channel     {debug_channel inside {[0:7]};} 
//
//  //NIRS_CTRL_0
//  //0: Receiver master continuous typical mode (EN follows period counter)
//  //4: Receiver master continuous typical mode (EN always on The measurig cycles follows tje period counter)
//  //2,6: Receiver master continuous fast mode  (EN always on, counter reset at the falling edge of IREFFINE)
//  //1,3,5,7,9,11,13,15: MCU master mode
//  //8,10,12,14: Receiver single mdoe 
//  //constraint c_nirs_ppg_mode_sel   {nirs_ppg_mode_sel inside{0,4,2,6,1,15,8,14};}
//
//  //constraint c_nirs_ppg_meas       {nirs_ppg_meas inside {0,1};}
//
//  //constraint c_nirs_ppg_en         {nirs_ppg_en inside {0,1};}
//
//  //NIRS_CTRL_1
//  //constraint c_ratio_mode         {ratio_mode  inside {[0:1]};} //ratio_mode=0: automatic, ration_mode=1: manual
//
//  //constraint c_ratio_ctrl          {ratio_ctrl  inside {[0:3]};} //this for automatic ration if ration_mode=0, 0-128, 1-64, 2-32, 3-16
//
//  //NIRS_CTRL_2
//  //constraint c_ratio_manual        {ratio_manual inside{[0:255]};} //this ratio manual will be used if ratio_mode has been set to 1
//
//  //constraint c_recv_stable_time_ctrl      {recv_stable_time_ctrl inside {[0:7]};}
//
//  //constraint c_reset_on_time_ctrl         {reset_on_time_ctrl inside {[0:7]}; }
//
//  //NIRS_CTRL_4
//  //constraint c_led_stable_time_beforeipd_sw   {led_stable_time_beforeipd_sw  inside {[0:7]};}
//  //constraint c_idac_manual_8                 {idac_manual_8 inside {[0:1]};}
//  //constraint c_idac_manual_en                {idac_manual_en == 0;}
//  //NIRS_CTRL_5
//  //constraint c_idac_manual_7_0               {idac_manual_7_0 inside {[0:255]};}
//  //NIRS_CTRL_6
//  //constraint c_threshold_h_18_11              {threshold_h_18_11  inside {[0:0/*0:255*/]};}
//  //NIRS_CTRL_7
//  //constraint c_threshold_h_10_3               {threshold_h_10_3  inside {[0:0/*0:255*/]};}
//  //NIRS_CTRL_8
//  //constraint c_threshold_h_2_0                {threshold_h_2_0  inside {[0:0/*0:7*/]};} 
//  //constraint c_threshold_l_7_3                {threshold_l_7_3 inside {[0:0/*0:31*/]};}   
//  //NIRS_CTRL_9                                                                            
//  //constraint c_threshold_l_2_0                {threshold_l_2_0 inside {[0:0/*0:7*/]};}    
//
//  //NIRS_CTRL_10
//  //constraint c_threshold_l_7_0                {threshold_l_7_0 inside {[0:0/*0:255*/]};}
//  //NIRS_CTRL_11
//  //constraint c_nirs_idac_manual_autmatic      {nirs_idac_manual_autmatic inside {[0:0]};}
//  //NIRS_CTRL_12
//  //constraint c_nirs_manual_value_of_idac      {nirs_manual_value_of_idac inside {[0:3]};}
//
//  //
//  //constraint c_nirs_irefcoarse_iref_delay { nirs_irefcoarse_iref_delay inside {[0:2000]};}
//  //NIRS_CTRL_ADDRESS
//  //constraint c_nirs_addr_channel_en           {nirs_addr_channel_en inside {[0:7]};} 
//  //NIRS_CTRL_EN
//  //constraint c_nirs_ppg_en0                    {nirs_ppg_en0 inside {[1:1/*0:1*/]};} 
//  //constraint c_nirs_ppg_en1                    {nirs_ppg_en1 inside {[1:1/*0:1*/]};}
//  //constraint c_nirs_ppg_en2                    {nirs_ppg_en2 inside {[1:1/*0:1*/]};}
//  //constraint c_nirs_ppg_en3                    {nirs_ppg_en3 inside {[1:1/*0:1*/]};}
//  //constraint c_nirs_ppg_en4                    {nirs_ppg_en4 inside {[1:1/*0:1*/]};}
//  //constraint c_nirs_ppg_en5                    {nirs_ppg_en5 inside {[1:1/*0:1*/]};}
//  //constraint c_nirs_ppg_en6                    {nirs_ppg_en6 inside {[1:1/*0:1*/]};}
//  //constraint c_nirs_ppg_en7                    {nirs_ppg_en7 inside {[1:1/*0:1*/]};}
//  //NIRS_CTRL_MEAS
//  //constraint c_nirs_ctrl_meas0                 {nirs_ctrl_meas0 inside {[1:1/*0:1*/]};}
//  //constraint c_nirs_ctrl_meas1                 {nirs_ctrl_meas1 inside {[1:1/*0:1*/]};}
//  //constraint c_nirs_ctrl_meas2                 {nirs_ctrl_meas2 inside {[1:1/*0:1*/]};}
//  //constraint c_nirs_ctrl_meas3                 {nirs_ctrl_meas3 inside {[1:1/*0:1*/]};}
//  //constraint c_nirs_ctrl_meas4                 {nirs_ctrl_meas4 inside {[1:1/*0:1*/]};}
//  //constraint c_nirs_ctrl_meas5                 {nirs_ctrl_meas5 inside {[1:1/*0:1*/]};}
//  //constraint c_nirs_ctrl_meas6                 {nirs_ctrl_meas6 inside {[1:1/*0:1*/]};}
//  //constraint c_nirs_ctrl_meas7                 {nirs_ctrl_meas7 inside {[1:1/*0:1*/]};}

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

    //enable nirs_ppg assertion
    `NIRS_PPG_IF.nirs_sva_enable = 1'b0;
    `NIRS_PPG_IF.gen_reg_int_clr_typ = top_test_cfg.gen_reg_int_clr_typ;     
    `NIRS_PPG_IF.gen_reg_int_length_sel = top_test_cfg.gen_reg_int_length_sel;  
    `NIRS_PPG_IF.gen_reg_int_active_level = top_test_cfg.gen_reg_int_active_level;
    `NIRS_PPG_IF.ch_en_mask               =  top_test_cfg.ch_en_mask;
    `NIRS_PPG_IF.clear_int_via_gen_int_sts_reg_or_nirs_int_sts_reg = top_test_cfg.clear_int_via_gen_int_sts_reg_or_nirs_int_sts_reg;
    //`DUT_IF.nirs_irefcoarse_iref_delay = top_test_cfg.nirs_irefcoarse_iref_delay;
    //`DUT_IF.en_config_ch0                 =                top_test_cfg.en_config_ch0;
    //`DUT_IF.en_config_ch1                 =                top_test_cfg.en_config_ch1;
    //`DUT_IF.en_config_ch2                 =                top_test_cfg.en_config_ch2;
    //`DUT_IF.en_config_ch3                 =                top_test_cfg.en_config_ch3;  
    //`DUT_IF.en_config_ch4                 =                top_test_cfg.en_config_ch4;
    //`DUT_IF.en_config_ch5                 =                top_test_cfg.en_config_ch5;
    //`DUT_IF.en_config_ch6                 =                top_test_cfg.en_config_ch6;
    //`DUT_IF.en_config_ch7                 =                top_test_cfg.en_config_ch7;
    //`DUT_IF.en_config_led0                =                top_test_cfg.en_config_led0;
    //`DUT_IF.en_config_led1                =                top_test_cfg.en_config_led1;                             
    //`DUT_IF.on_time_sel                   =                top_test_cfg.on_time_sel;
    //`DUT_IF.period_ctrl                  =                 top_test_cfg.period_ctrl;                          
    //`DUT_IF.led_off_time_after_ipd_sw     =                top_test_cfg.led_off_time_after_ipd_sw; 
    ////`DUT_IF.recv_stable_time_ctrl         =                top_test_cfg.recv_stable_time_ctrl;
    //`DUT_IF.led_stable_time_beforeipd_sw  =                top_test_cfg.led_stable_time_beforeipd_sw;
    //`DUT_IF.reset_on_time_ctrl            =                top_test_cfg.reset_on_time_ctrl;                                       
    //`DUT_IF.idac_manual_8_0               =                top_test_cfg.idac_manual_8_0;                         
    //`DUT_IF.idac_manual_en                =                top_test_cfg.idac_manual_en;
    //`DUT_IF.idac_en                       =                top_test_cfg.idac_en;
    //`DUT_IF.threshold_h_18_16             =                top_test_cfg.threshold_h_18_16;                          
    //`DUT_IF.threshold_h_15_8              =                top_test_cfg.threshold_h_15_8;                         
    //`DUT_IF.threshold_h_7_0               =                top_test_cfg.threshold_h_7_0;             
    //`DUT_IF.threshold_l_7_0               =                top_test_cfg.threshold_l_7_0;
    //`DUT_IF.idac_min_int_en               =                top_test_cfg.idac_min_int_en;
    //`DUT_IF.idac_max_int_en               =                top_test_cfg.idac_max_int_en;
    //`DUT_IF.iref_fine_on_not_off_en       =                top_test_cfg.iref_fine_on_not_off_en;
    //`DUT_IF.iref_fine_not_on_en           =                top_test_cfg.iref_fine_not_on_en;
    //`DUT_IF.iref_coarse_en                =                top_test_cfg.iref_coarse_en;
    //`DUT_IF.data_ready_en                 =                top_test_cfg.data_ready_en;
    //`DUT_IF.nirs_int_pin_en               =                top_test_cfg.nirs_int_pin_en;              
    //`DUT_IF.nirs_ppg_mode_sel             =                top_test_cfg.nirs_ppg_mode_sel;
    //`DUT_IF.nirs_ppg_led_signle_en        =                top_test_cfg.nirs_ppg_led_signle_en;
    //`DUT_IF.pdbias_en                     =                top_test_cfg.pdbias_en;
    //`DUT_IF.pdbias_adj                    =                top_test_cfg.pdbias_adj;
    //`DUT_IF.fchop_adj                     =                top_test_cfg.fchop_adj;
    //`DUT_IF.chopper_en                    =                top_test_cfg.chopper_en;
    //`DUT_IF.test_en                       =                top_test_cfg.test_en;
    //`DUT_IF.ipdmirror_ratio_adj           =                top_test_cfg.ipdmirror_ratio_adj;
    //`DUT_IF.iref_ratio_adj                =                top_test_cfg.iref_ratio_adj;  
    //`DUT_IF.ratio_ctrl                    =                top_test_cfg.ratio_ctrl; 
    //`DUT_IF.ratio_mode                    =                top_test_cfg.ratio_mode;        
    //`DUT_IF.ratio_manual                  =                top_test_cfg.ratio_manual;
    //`DUT_IF.ana_ppg_rst_reg               =                top_test_cfg.ana_ppg_rst_reg;
    //`DUT_IF.ana_ppg_clk50duty             =                top_test_cfg.ana_ppg_clk50duty; 
    //`DUT_IF.ana_ppg_clk_div               =                top_test_cfg.ana_ppg_clk_div;
    //`DUT_IF.ana_ppg_clk_inv               =                top_test_cfg.ana_ppg_clk_inv;
    //`DUT_IF.ppg_dis                       =                top_test_cfg.ppg_dis;      
    //`DUT_IF.nirs_ppg_cmd                  =                top_test_cfg.nirs_ppg_cmd;                            
    //`DUT_IF.debug_led                     =                top_test_cfg.debug_led;             
    //`DUT_IF.debug_channel                 =                top_test_cfg.debug_channel;
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
    foreach(`DUT_IF.nirs_irefcoarse_length[i])begin
      `nnc_info("SOC_TEST", $sformatf("\n\t\t\t\t\t\t\t\t\t\tHigh pulse length of SW2 nirs_irefcoarse_length[%0d]: %dns",i, `DUT_IF.nirs_irefcoarse_length[i]), NNC_LOW)
      `nnc_info("SOC_TEST", $sformatf("\n\t\t\t\t\t\t\t\t\t\tDelay between SW2 and SW3 nirs_irefcoarse_iref_delay[%0d]: %dns", i, `DUT_IF.nirs_irefcoarse_iref_delay[i]), NNC_LOW)
      `nnc_info("SOC_TEST", $sformatf("\n\t\t\t\t\t\t\t\t\t\tHigh pulse length of SW3 nirs_ireffine_length[%0d]: %dns",i, `DUT_IF.nirs_ireffine_length[i]), NNC_LOW) 
    end                                                                                        
   
    //clock control should be same for all channels
    //At OFFSET 0XCD(NIRS_CTRL_*)
    //bit[5] Software reset PPG module
    //bit[4] = 0 not 50% duty cycle, =1 PPG CLK50% Duty cycle  (only effective PPG_CLK_DIV =2 or 3)
    //bit[3:2] PPG_CLK_DIV (0-8MHZ, 1-6MHZ, 2-4MHZ, 3-2MHZ)
    //bit[1]  =0 same phase (analog ppg clock same as digital ppg clock), =1 invert phase(analog ppg clock invert with digital ppg clock
    //bit[0]  =0 Enable NIRS module, 1= Disable NIRS module 
    //`nnc_info("SOC_TEST", "Configure SOC_NIRS_CTRL_CLK_REG", NNC_LOW)      
    ////top_test_cfg.data[0] = {2'b0, top_test_cfg.ana_ppg_rst_reg, top_test_cfg.ana_ppg_clk50duty, top_test_cfg.ana_ppg_clk_div, top_test_cfg.ana_ppg_clk_inv,top_test_cfg.ppg_dis};
    //assert(top_test_cfg.randomize() with {reg_addr == `SOC_NIRS_CTRL_CLK_REG; mask == 8'hff; data[0] == {2'b0, `DUT_IF.ana_ppg_rst_reg, `DUT_IF.ana_ppg_clk50duty, `DUT_IF.ana_ppg_clk_div, `DUT_IF.ana_ppg_clk_inv,`DUT_IF.ppg_dis};});
    //`nnc_info("SOC_TEST", $sformatf("SOC_NIRS_CTRL_CLK_REG top_test_cfg.data[0]: %h ",top_test_cfg.data[0]), NNC_LOW) 
    ////`WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);
    //`WR_NIRS_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads/*, top_test_cfg.mask*/);  

 
    // --------------------------------------------------------                                                                                                              
    // End of test and add any needed delay time                                                                                                                             
    // --------------------------------------------------------                                                                                                              
    #10000ns;                                                                                                                  
    //`nnc_info("SOC_TEST", "soc_nirs_ppg_base_test end now", NNC_LOW)                                                           

    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ==================================================================================

    phase.drop_objection(this);
  endtask: main_phase

   // ------------------------------
   // Declare the ser defined task
   // ------------------------------
   task configure_nirs_ctrl_regs(logic [7:0] ch, bit [1:0]num_leds);


      //OFFSET 0x02 to 0x0D (NIRS_CTRL_CHANNEL to NIRS_CTRL_ADJ2
      NO_OF_BYTES = 8'h09;
      //top_test_cfg.wr_data[NO_OF_BYTES -1 -0] =  {`NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].en_config_ch7, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].en_config_ch6, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].en_config_ch5, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].en_config_ch4, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].en_config_ch3, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].en_config_ch2, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].en_config_ch1, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].en_config_ch0};
      //`nnc_info("PPG_TEST",$sformatf("nirs pgg base test nirs_ch_en_reg=%0h", top_test_cfg.wr_data[13]),NNC_LOW);

      //top_test_cfg.wr_data[NO_OF_BYTES -1 -1] =  {6'b0, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].en_config_led1, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].en_config_led0};
      top_test_cfg.wr_data[NO_OF_BYTES -1 -0] =  {`NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].period_ctrl, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].on_time_sel };     
      top_test_cfg.wr_data[NO_OF_BYTES -1 -1] =  {`NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].led_off_time_after_ipd_sw, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].reset_on_time_ctrl,  `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].led_stable_time_beforeipd_sw};
      top_test_cfg.wr_data[NO_OF_BYTES -1 -2] =  {2'b0, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].idac_manual_8_0[8:3]};
      top_test_cfg.wr_data[NO_OF_BYTES -1 -3] =  {`NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].idac_manual_8_0[2:0], `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].idac_manual_en, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].idac_en,  `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].threshold_h_18_16 };  
      top_test_cfg.wr_data[NO_OF_BYTES -1 -4] =  {`NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].threshold_h_15_8[7:0]};         
      top_test_cfg.wr_data[NO_OF_BYTES -1 -5] =  {`NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].threshold_h_7_0[7:0] };
      top_test_cfg.wr_data[NO_OF_BYTES -1 -6] =  {`NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].threshold_l_7_0[7:0] };
      top_test_cfg.wr_data[NO_OF_BYTES -1 -7] = {1'b0,  `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].ipdmirror_ratio_adj,  `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].iref_ratio_adj,  `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].ratio_ctrl,  `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].ratio_mode};
      
      //top_test_cfg.wr_data[NO_OF_BYTES -1 -9] = {1'b0, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch].idac_min_int_en, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch].idac_max_int_en, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch].iref_fine_on_not_off_en, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch].iref_fine_not_on_en, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch].iref_coarse_en, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch].data_ready_en, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch].nirs_int_pin_en};

       top_test_cfg.wr_data[NO_OF_BYTES -1 -8] = {`NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].ratio_manual};
      //top_test_cfg.wr_data[NO_OF_BYTES -1 -10] = {3'b0, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch].nirs_ppg_led_signle_en, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch].nirs_ppg_mode_sel};

      //`nnc_info("PPG_TEST",$sformatf("nirs pgg base test nirs_ppg_led_signle_en =%0h, nirs_ppg_mode_sel=%0h", `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].nirs_ppg_mode_sel, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].nirs_ppg_led_signle_en),NNC_LOW); 
      //top_test_cfg.wr_data[NO_OF_BYTES -1 -9] = {3'b0, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].nirs_ppg_led_signle_en, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].nirs_ppg_mode_sel};
      //`nnc_info("PPG_TEST",$sformatf("nirs pgg base test nirs_ctrl_cmd=%0h", top_test_cfg.wr_data[2]),NNC_LOW);

      //top_test_cfg.wr_data[NO_OF_BYTES -1 -10] = {1'b0, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].idac_min_int_en, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].idac_max_int_en, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].iref_fine_on_not_off_en, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].iref_fine_not_on_en, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].iref_coarse_en, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].data_ready_en, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].nirs_int_pin_en};
 
      ////top_test_cfg.wr_data[NO_OF_BYTES -1 -11] = {1'b0,  `NIRS_PPG_IF.nirs_ppg_cfg_array[ch].pdbias_en,  `NIRS_PPG_IF.nirs_ppg_cfg_array[ch].pdbias_adj,  `NIRS_PPG_IF.nirs_ppg_cfg_array[ch].fchop_adj,  `NIRS_PPG_IF.nirs_ppg_cfg_array[ch].chopper_en,  `NIRS_PPG_IF.nirs_ppg_cfg_array[ch].test_en}; 
      // top_test_cfg.wr_data[NO_OF_BYTES -1 -11] = {1'b0,  `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].pdbias_en,  `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].pdbias_adj,  `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].fchop_adj,  `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].chopper_en,  `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].test_en}; 

      //top_test_cfg.wr_data[NO_OF_BYTES -1 -12] = {1'b0,  `NIRS_PPG_IF.nirs_ppg_cfg_array[ch].ipdmirror_ratio_adj,  `NIRS_PPG_IF.nirs_ppg_cfg_array[ch].iref_ratio_adj,  `NIRS_PPG_IF.nirs_ppg_cfg_array[ch].ratio_ctrl,  `NIRS_PPG_IF.nirs_ppg_cfg_array[ch].ratio_mode};                                    
      //top_test_cfg.wr_data[NO_OF_BYTES -1 -13] = {`NIRS_PPG_IF.nirs_ppg_cfg_array[ch].ratio_manual};                               
      for(int i=0; i<9; i++)begin
        `nnc_info("SOC_TEST", $sformatf("SOC_NIRS_REGS NIRS_REG_ADDR :%0h burst_write_data[%0d] :%0h ",i, (NO_OF_BYTES -1 -i), top_test_cfg.wr_data[NO_OF_BYTES -1 -i]), NNC_LOW)
      end    

      //                          
      `WR_BURST_NIRS_REG(`SOC_NIRS_CTRL_0_REG, NO_OF_BYTES, 8'h00, top_test_cfg.wr_data);  
      //`WR_NIRS_REG(i, top_test_cfg.wr_data[i], top_test_cfg.pads); 

   
      ////At OFFSET 0X0A
      ////0X0A[3:0] == nirs_ppg_mode_sel
      ////0x0A[4]== 0: dual led mode, 1:single led mode
      //`nnc_info("SOC_TEST", "Configure SOC_NIRS_CTRL_MODE REG", NNC_LOW)
      ////top_test_cfg.data[0] = {2'b0,top_test_cfg.threshold_h_18_13};
      //assert(top_test_cfg.randomize() with {reg_addr == `SOC_NIRS_CTRL_MODE_REG; mask == 8'hff; data[0] == {3'b0,`NIRS_PPG_IF.nirs_ppg_cfg_array[ch].nirs_ppg_led_signle_en,`NIRS_PPG_IF.nirs_ppg_cfg_array[ch].nirs_ppg_mode_sel};});
      //`nnc_info("SOC_TEST", $sformatf("SOC_NIRS_CTRL_MODE REG top_test_cfg.data[0]: %h ",top_test_cfg.data[0]), NNC_LOW)
      //`WR_NIRS_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads); 

      ////At OFFSET 0X10
      ////0X10[3:0] == debug_channel
      ////0x10[4]== debug led
      //`nnc_info("SOC_TEST", "Configure SOC_NIRS_DEBUG_SEL REG", NNC_LOW)
      ////top_test_cfg.data[0] = {2'b0,top_test_cfg.threshold_h_18_13};
      //assert(top_test_cfg.randomize() with {reg_addr == `SOC_NIRS_DEBUG_SEL_REG; mask == 8'hff; data[0] == {3'b0,`NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].debug_led,`NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].debug_channel};});
      //`nnc_info("SOC_TEST", $sformatf("SOC_NIRS_DEBUG_SEL REG top_test_cfg.data[0]: %h ",top_test_cfg.data[0]), NNC_LOW)
      //`WR_NIRS_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);
        

                                     
   endtask

   task drive_nirs_if_from_cfg_leds(logic[7:0] ch,bit[1:0]num_leds);
    `nnc_info("PPG_BASE_TEST",$sformatf("drive_nirs_if_from_cfg_led0: channel number=%0d ",ch),NNC_LOW); 
          //`nnc_info("PPG_BASE_TEST",$sformatf("nirs pgg base test en_config_ch0=%0h, en_config_ch1=%0h, en_config_ch2=%0h, en_config_ch3=%0h, en_config_ch4=%0h, en_config_ch5=%0h, en_config_ch6=%0h, en_config_ch7=%0h ",
          // `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].en_config_ch[0],
          // `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].en_config_ch[1],
          // `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].en_config_ch[2],
          // `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].en_config_ch[3],
          // `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].en_config_ch[4],
          // `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].en_config_ch[5],
          // `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].en_config_ch[6],
          // `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].en_config_ch[7]),NNC_LOW);

    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].en_config_ch0     =`NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].en_config_ch[0];
    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].en_config_ch1     =`NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].en_config_ch[1];
    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].en_config_ch2     =`NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].en_config_ch[2];
    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].en_config_ch3     =`NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].en_config_ch[3]; 
    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].en_config_ch4     =`NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].en_config_ch[4];
    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].en_config_ch5     =`NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].en_config_ch[5];
    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].en_config_ch6     =`NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].en_config_ch[6];
    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].en_config_ch7     =`NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].en_config_ch[7];
 
    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].en_config_led0 = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].en_config_led[0];
    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].en_config_led1 = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].en_config_led[1];

    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].on_time_sel    = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].on_time_cycles;
    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].period_ctrl    = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].period_cycles;

    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].led_off_time_after_ipd_sw     = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].ledoff_cycles;
    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].led_stable_time_beforeipd_sw  = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].stable_cycles;
    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].reset_on_time_ctrl            = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].reset_cycles;

    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].idac_manual_8_0 = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].idac_manual;
    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].idac_manual_en  = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].idac_manual_en;
    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].idac_en         = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].idac_en;

    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].threshold_h_18_16 = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].threshold_h_18_16;
    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].threshold_h_15_8  = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].threshold_h_15_8;
    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].threshold_h_7_0   = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].threshold_h_7_0;
    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].threshold_l_7_0   = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].threshold_l_7_0;

    //`nnc_info("PPG_TEST",$sformatf("drive_dut_if_from_cfg: h18_16=%0d h15_8=%0d h7_0=%0d l7_0=%0d",
    //     `NIRS_PPG_IF.threshold_h_18_16,
    //     `NIRS_PPG_IF.threshold_h_15_8,
    //     `NIRS_PPG_IF.threshold_h_7_0,
    //     `NIRS_PPG_IF.threshold_l_7_0),NNC_LOW);

    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].idac_min_int_en = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].idac_min_int_en;
    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].idac_max_int_en = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].idac_max_int_en;
    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].iref_fine_on_not_off_en = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].iref_fine_on_not_off_en;
    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].iref_fine_not_on_en     = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].iref_fine_not_on_en;
    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].iref_coarse_en          = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].iref_coarse_en;
    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].data_ready_en           = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].data_ready_en;
    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].nirs_int_pin_en         = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].nirs_int_pin_en;

    //`NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].nirs_ppg_mode_sel      = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].nirs_ppg_mode_sel;
    //`NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].nirs_ppg_led_signle_en = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].nirs_ppg_led_signle_en;

    //`nnc_info("PPG_TEST",$sformatf("nirs_ppg_led_signle_en=%0d ", `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].nirs_ppg_led_signle_en),NNC_LOW);

    //`NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].pdbias_en   = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].pdbias_en;
    //`NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].pdbias_adj  = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].pdbias_adj;
    //`NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].fchop_adj   = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].fchop_adj;
    //`NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].chopper_en  = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].chopper_en;
    //`NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].test_en     = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].test_en;
    //`NIRS_PPG_IF.pdbias_en   = `NIRS_PPG_CTRL_CFG.pdbias_en;  //one time configuration at the beginning
    //`NIRS_PPG_IF.pdbias_adj  = `NIRS_PPG_CTRL_CFG.pdbias_adj; //one time configuration at the beginning
    //`NIRS_PPG_IF.fchop_adj   = `NIRS_PPG_CTRL_CFG.fchop_adj;  //one time configuration at the beginning
    //`NIRS_PPG_IF.chopper_en  = `NIRS_PPG_CTRL_CFG.chopper_en; //one time configuration at the beginning
    //`NIRS_PPG_IF.test_en     = `NIRS_PPG_CTRL_CFG.test_en;    //one time configuration at the beginning

    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].ipdmirror_ratio_adj = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].ipdmirror_ratio_adj;
    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].iref_ratio_adj      = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].iref_ratio_adj;
    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].ratio_ctrl          = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].ratio_ctrl;
    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].ratio_mode          = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].ratio_mode;
    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].ratio_manual        = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].ratio_manual;

    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].ana_ppg_rst_reg   = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].ana_ppg_rst_reg;
    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].ana_ppg_clk50duty = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].ana_ppg_clk50duty;
    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].ana_ppg_clk_div   = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].ana_ppg_clk_div;
    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].ana_ppg_clk_inv   = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].ana_ppg_clk_inv;
    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].ppg_dis           = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].ppg_dis;

    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].nirs_ppg_cmd = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].nirs_ppg_cmd;

    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].debug_led     = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].debug_led;
    `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].debug_channel = `NIRS_PPG_CTRL_CFG.expected_cfg[ch][num_leds].debug_channel;   
   endtask           


  //set debug sel register to select any channel and led for read/debug purpose
  task config_debug_sel_reg(logic[7:0] ch, bit [1:0], num_leds, logic[7:0] debug_sel_reg_config_val);

      //At OFFSET 0X10
      //0X10[3:0] == debug_channel
      //0x10[4]== debug led
      `nnc_info("SOC_TEST", "Configure SOC_NIRS_DEBUG_SEL REG", NNC_LOW)
      //top_test_cfg.data[0] = {2'b0,top_test_cfg.threshold_h_18_13};
      assert(top_test_cfg.randomize() with {reg_addr == `SOC_NIRS_DEBUG_SEL_REG; mask == 8'hff; data[0] == {3'b0,`NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].debug_led,`NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].debug_channel};});
      `nnc_info("SOC_TEST", $sformatf("SOC_NIRS_DEBUG_SEL REG top_test_cfg.data[0]: %h ",top_test_cfg.data[0]), NNC_LOW)
      `WR_NIRS_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);
  endtask

  //clear if any interrupt which is pending before start 
  task read_nirs_int_status;
    
  endtask

   // 
   task nirs_start_cmd_mcu_master_single_mode(/*logic[7:0] ch, bit [1:0]num_leds*/);
     //At OFFSET 0X0F
      //0X0F[1:0] == NIRS_PPG_CMD
      `nnc_info("SOC_TEST", "Configure SOC_NIRS_CTRL_CMD_REG", NNC_LOW)
      //top_test_cfg.data[0] = {2'b0,top_test_cfg.threshold_h_18_13};
      for(bit [7:0] i =1; i<3; i++)begin
         `NIRS_PPG_CTRL_CFG.nirs_ppg_cmd = i; // needs to be updated
         if(i==2)begin
           #200us;  
         end
         //`NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].nirs_ppg_cmd = i;
         assert(top_test_cfg.randomize() with {reg_addr == `SOC_NIRS_CTRL_CMD_REG; mask == 8'hff; data[0] == i;}); 
         `nnc_info("SOC_TEST", $sformatf("SOC_NIRS_CTRL_CMD_REG top_test_cfg.data[0]: %h ",top_test_cfg.data[0]), NNC_LOW)
         `WR_NIRS_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads); 
      end
   endtask

   task nirs_start_cmd_receiver_single_cont_mode;
        top_test_cfg.data[0] = 8'h01;
        `WR_NIRS_REG(`SOC_NIRS_CTRL_CMD_REG, top_test_cfg.data[0], top_test_cfg.pads);
        `nnc_info("SOC_TEST", $sformatf("START CMD: top_test_cfg.data[0]: %h ",top_test_cfg.data[0]), NNC_LOW) 
   endtask

  //Config nirs channel enable reg
  task config_nirs_channel_en_reg(logic [7:0] ch_en_mask); 
    // no need to use for different led's, it's common regs'for all 8 channels
    //top_test_cfg.data[0] = {`NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].en_config_ch7, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].en_config_ch6, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].en_config_ch5, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].en_config_ch4, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].en_config_ch3, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].en_config_ch2, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].en_config_ch1, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].en_config_ch0};
    `nnc_info("SOC_TEST", $sformatf("ch_en_mask: %h ",ch_en_mask[7:0]), NNC_LOW)
    `NIRS_PPG_CTRL_CFG.en_config_ch0 = ch_en_mask[0]; 
    `NIRS_PPG_CTRL_CFG.en_config_ch1 = ch_en_mask[1];  
    `NIRS_PPG_CTRL_CFG.en_config_ch2 = ch_en_mask[2];  
    `NIRS_PPG_CTRL_CFG.en_config_ch3 = ch_en_mask[3];  
    `NIRS_PPG_CTRL_CFG.en_config_ch4 = ch_en_mask[4];  
    `NIRS_PPG_CTRL_CFG.en_config_ch5 = ch_en_mask[5];  
    `NIRS_PPG_CTRL_CFG.en_config_ch6 = ch_en_mask[6];  
    `NIRS_PPG_CTRL_CFG.en_config_ch7 = ch_en_mask[7];  
  
    `nnc_info("PPG_TEST",$sformatf("nirs pgg base test en_config_ch0=%0h, en_config_ch1=%0h, en_config_ch2=%0h, en_config_ch3=%0h, en_config_ch4=%0h, en_config_ch5=%0h, en_config_ch6=%0h, en_config_ch7=%0h ",
    `NIRS_PPG_CTRL_CFG.en_config_ch0,
    `NIRS_PPG_CTRL_CFG.en_config_ch1,
    `NIRS_PPG_CTRL_CFG.en_config_ch2,
    `NIRS_PPG_CTRL_CFG.en_config_ch3,
    `NIRS_PPG_CTRL_CFG.en_config_ch4,
    `NIRS_PPG_CTRL_CFG.en_config_ch5,
    `NIRS_PPG_CTRL_CFG.en_config_ch6,
    `NIRS_PPG_CTRL_CFG.en_config_ch7),NNC_LOW);

    top_test_cfg.data[0] = {`NIRS_PPG_CTRL_CFG.en_config_ch7, `NIRS_PPG_CTRL_CFG.en_config_ch6, `NIRS_PPG_CTRL_CFG.en_config_ch5, `NIRS_PPG_CTRL_CFG.en_config_ch4, `NIRS_PPG_CTRL_CFG.en_config_ch3, `NIRS_PPG_CTRL_CFG.en_config_ch2, `NIRS_PPG_CTRL_CFG.en_config_ch1, `NIRS_PPG_CTRL_CFG.en_config_ch0}; 
    `WR_NIRS_REG(`SOC_NIRS_CTRL_CHANNEL_REG, top_test_cfg.data[0], top_test_cfg.pads);
     `nnc_info("PPG_TEST",$sformatf("SOC_NIRS_CTRL_CHANNEL_REG=%0h", top_test_cfg.data[0]),NNC_LOW);
 
  endtask 

  //config_nirs_ctrl_led_reg; 
  task config_nirs_ctrl_led_reg;
    //no need to use for different led's, it's common regs'for all 8 channels
    //top_test_cfg.data[0] = {6'b0, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].en_config_led1, `NIRS_PPG_IF.nirs_ppg_cfg_array[ch][num_leds].en_config_led0}; 
    top_test_cfg.data[0] = {6'b0, `NIRS_PPG_CTRL_CFG.en_config_led1, `NIRS_PPG_CTRL_CFG.en_config_led0};
    `WR_NIRS_REG(`SOC_NIRS_CTRL_LED_REG, top_test_cfg.data[0], top_test_cfg.pads);
    `nnc_info("PPG_TEST",$sformatf("SOC_NIRS_CTRL_LED_REG=%0h", top_test_cfg.data[0]),NNC_LOW);
  endtask

  //Config nirs control command reg 
  task config_nirs_ctrl_mode_reg;
      `nnc_info("PPG_TEST",$sformatf("nirs pgg base test nirs_ppg_led_signle_en =%0h, nirs_ppg_mode_sel=%0h", `NIRS_PPG_CTRL_CFG.nirs_ppg_led_signle_en, `NIRS_PPG_CTRL_CFG.nirs_ppg_mode_sel),NNC_LOW); 
      top_test_cfg.data[0] = {2'b0, `NIRS_PPG_IF.nirs_ppg_led_ambient_en, `NIRS_PPG_IF.nirs_ppg_led_signle_en, `NIRS_PPG_IF.nirs_ppg_mode_sel};
      `WR_NIRS_REG(`SOC_NIRS_CTRL_MODE_REG, top_test_cfg.data[0], top_test_cfg.pads);
      `nnc_info("PPG_TEST",$sformatf("nirs pgg base test nirs_ctrl_mode=%0h", top_test_cfg.data[0]),NNC_LOW);
    
  endtask

  //Config nirs interuupt enable reg 
  task config_nirs_intr_en_reg;
      top_test_cfg.data[0] = {`NIRS_PPG_IF.idac_min_int_en, `NIRS_PPG_IF.idac_max_int_en, `NIRS_PPG_IF.iref_fine_on_not_off_en, `NIRS_PPG_IF.iref_fine_not_on_en, `NIRS_PPG_IF.iref_coarse_on_not_off_en,`NIRS_PPG_IF.iref_coarse_not_on_en, `NIRS_PPG_IF.data_ready_en, `NIRS_PPG_IF.nirs_int_pin_en};
      `WR_NIRS_REG(`SOC_NIRS_CTRL_INT_REG, top_test_cfg.data[0], top_test_cfg.pads);
      `nnc_info("SOC_TEST", $sformatf("SOC_NIRS_CTRL_INT_REG top_test_cfg.data[0]: %h ",top_test_cfg.data[0]), NNC_LOW)    
  endtask


  //Config nirs ADJ0 reg 
  task config_nirs_adj0_reg; 
      top_test_cfg.data[0] = {1'b0,  `NIRS_PPG_CTRL_CFG.pdbias_en,  `NIRS_PPG_CTRL_CFG.pdbias_adj,  `NIRS_PPG_CTRL_CFG.fchop_adj,  `NIRS_PPG_CTRL_CFG.chopper_en,  `NIRS_PPG_CTRL_CFG.test_en}; 
      `WR_NIRS_REG(`SOC_NIRS_CTRL_ADJ0_REG, top_test_cfg.data[0], top_test_cfg.pads);
      `nnc_info("SOC_TEST", $sformatf("SOC_NIRS_CTRL_ADJ0_REG top_test_cfg.data[0]: %h ",top_test_cfg.data[0]), NNC_LOW)         
  endtask

  //Config nirs ADJ0 reg 
  task config_nirs_clk_ctrl_reg;
      //assert(`NIRS_PPG_CTRL_CFG.randomize()); // with {reg_addr == `SOC_NIRS_CTRL_CLK_REG; mask == 8'hff; data[0] == {2'b0, `DUT_IF.ana_ppg_rst_reg, `DUT_IF.ana_ppg_clk50duty, `DUT_IF.ana_ppg_clk_div, `DUT_IF.ana_ppg_clk_inv,`DUT_IF.ppg_dis};});
      top_test_cfg.data[0] = {1'b0, `NIRS_PPG_CTRL_CFG.bypass_or_gateclk, `NIRS_PPG_CTRL_CFG.ana_ppg_rst_reg, `NIRS_PPG_CTRL_CFG.ana_ppg_clk50duty, `NIRS_PPG_CTRL_CFG.ana_ppg_clk_div, `NIRS_PPG_CTRL_CFG.ana_ppg_clk_inv,`NIRS_PPG_CTRL_CFG.ppg_dis};
     
      `WR_NIRS_REG(`SOC_NIRS_CTRL_CLK_REG, top_test_cfg.data[0], top_test_cfg.pads);;
      `nnc_info("SOC_TEST", $sformatf("SOC_NIRS_CTRL_CLK_REG top_test_cfg.data[0]: %h ",top_test_cfg.data[0]), NNC_LOW)   
  endtask

  //
  task automatic monitor_nirs_interrupt(int expected_interrupts, logic[7:0] intr_ch_check, int ch_num);

     bit [7:0] intr_status;
     int interrupt_count = 0; 
     bit [7:0] prev_status = 8'h00;
     automatic int channel_num;
     automatic int channel_enabled; //doesn;t matter using this
     
    channel_num = ch_num;
    channel_enabled = intr_ch_check;
    `uvm_info("NIRS_INT", $sformatf("wait for INTERRUPT!!!! for ENABLED CHANNELS =%0h\n",channel_enabled),UVM_MEDIUM)
     //while(interrupt_count < expected_interrupts)  begin 
     //forever begin
       
       //`uvm_info("NIRS_INT", $sformatf("IN while loop wait for INTERRUPT!!!! interrupt_count =%0d",interrupt_count),UVM_LOW)  
       //-----------------------------------------
       // Interrupt output enabled to external pin
       //-----------------------------------------
//       if (`NIRS_PPG_IF.nirs_int_pin_en === 1'b1) begin
//          //1. ACTIVE HIGH, LEVEL ACTIVE (0 to 1 trnsition, level signal until clear teh status)
//          if((`NIRS_PPG_IF.gen_reg_int_active_level === 1'b1) && (`NIRS_PPG_IF.gen_reg_int_length_sel === 1'b0))begin
//            pin_int_active_high_level_active(channel_num);
//            interrupt_count++;
//          end
//          //2. ACTIVE HIGH, PULSE ACTIVE (0 to 1 transition, 1PCLK)
//          if((`NIRS_PPG_IF.gen_reg_int_active_level === 1'b1) && (`NIRS_PPG_IF.gen_reg_int_length_sel === 1'b1))begin
//          pin_int_active_high_pulse_active(channel_num);
//          //interrupt_count++;
//          end
//          //3. ACTIVE LOW,  LEVEL ACTIVE (1 to 0 tarnsition, level signal until clear teh status)
//          if((`NIRS_PPG_IF.gen_reg_int_active_level === 1'b0) && (`NIRS_PPG_IF.gen_reg_int_length_sel === 1'b0))begin            
//            pin_int_active_low_level_active(channel_num);
//            interrupt_count++;
//          end
//          //4. ACTIVE LOW,  PULSE ACTIVE (1 to 0 transition, 1PCLK))
//          if((`NIRS_PPG_IF.gen_reg_int_active_level === 1'b0) && (`NIRS_PPG_IF.gen_reg_int_length_sel === 1'b1))begin            
//            pin_int_active_low_pulse_active(channel_num); 
//            interrupt_count++;  
//          end     
//       end

       //-----------------------------------------
       // Interrupt not routed to pin
       //-----------------------------------------
//       else begin       
         //-----------------------------------------
         // Capture interrupt status
         //-----------------------------------------
         //intr_status = `DIG_TOP.spi_nirs_if.NIRS_INT[7:0];
         do begin
            if(`NIRS_PPG_IF.clear_int_via_gen_int_sts_reg_or_nirs_int_sts_reg === 1'b0)begin     //poll nirs sts reg
              `RD_NIRS_REG(`SOC_NIRS_INT_STATUS_REG,8'h00, intr_status); 
              `uvm_info("NIRS_INT",$sformatf("Poll NIRS INT STATUS for CH_NUM = %0h intr_status =%0h ", channel_num, (intr_status & channel_enabled)),UVM_LOW)
            end
            else begin
              `RD_NORMAL_REG(`SOC_GENERAL_INT_STS_6_REG, 8'h00, intr_status); //poll gen int sts reg
               `uvm_info("NIRS_INT",$sformatf("Poll NIRS GEN_INT STATUS for CH_NUM = %0h intr_status =%0h ", channel_num, (intr_status & channel_enabled)),UVM_LOW)
            end
         end while((intr_status & channel_enabled) == 0);

         `uvm_info("NIRS_INT",$sformatf("Interrupt generated from channel %0h", channel_num),UVM_LOW)
         interrupt_count++;

//       end //else

    //end //while
  
    `uvm_info("INT_MON",$sformatf("Completed interrupt monitoring for Channel_num =%0h\n",channel_num),UVM_LOW)
    if(intr_status !== intr_ch_check)begin
      `nnc_error("NIRS_INT_STS",$sformatf("R1C READ STATUS ERROR!!!! read_status =%0h, expected_status =%0h\n", intr_status, intr_ch_check))
    end
    else begin
      `uvm_info("NIRS_INT_STS","R1C INTERRUPT STS MATCH!!!!",UVM_LOW )
    end
 
   endtask  

   task read_nirs_idac_data;
        //`RD_BURST_NIRS_REG(top_test_cfg.nirs_burst_addr_start, top_test_cfg.nirs_burst_size, top_test_cfg.nirs_rd_data_burst);
        `RD_BURST_NIRS_REG(`SOC_NIRS_DOUT0_0_REG, 8'h20,top_test_cfg.nirs_rd_data_burst); 
   endtask   

   task clear_interrupt_status(bit gen_reg_int_clr_typ, bit poll_pin_or_stsreg);
       if(`NIRS_PPG_IF.clear_int_via_gen_int_sts_reg_or_nirs_int_sts_reg ===1'b1)begin  //general nirs sts reg
         if(gen_reg_int_clr_typ === 1'b1)begin
           `uvm_info("NIRS_INT",$sformatf("SOC_GENERAL_INT_STS_6_REG: gen_reg_int_clr_typ %0d", gen_reg_int_clr_typ),UVM_LOW)     
            `RD_NORMAL_REG(`SOC_GENERAL_INT_STS_6_REG, 8'h00, top_test_cfg.nirs_read_intr_status); //R1C
            //cross  check status
            check_status_reg_r1c(top_test_cfg.nirs_read_intr_status, `NIRS_PPG_IF.ch_en_mask,poll_pin_or_stsreg);
         end
         else begin
           `uvm_info("NIRS_INT",$sformatf("SOC_GENERAL_INT_STS_6_REG: gen_reg_int_clr_typ %0d", gen_reg_int_clr_typ),UVM_LOW) 
            //`WR_NORMAL_REG(`SOC_GENERAL_INT_STS_6_REG, `NIRS_PPG_IF.ch_en_mask, top_test_cfg.pads); //RW1C, clear interrupt status of enabled channels, Xin cofirm W1C not supported for GENERTAL_INT_STS
            `WR_NIRS_REG(`SOC_NIRS_INT_STATUS_REG, `NIRS_PPG_IF.ch_en_mask, top_test_cfg.pads); //RW1C, clear interrupt status of enabled channels
           //cross check status
           check_status_reg_w1c();
         end
       end
       else begin
         if(gen_reg_int_clr_typ === 1'b1)begin // nirs sts reg
           `uvm_info("NIRS_INT",$sformatf("SOC_NIRS_INT_STATUS_REG: gen_reg_int_clr_typ %0d", gen_reg_int_clr_typ),UVM_LOW)     
            `RD_NIRS_REG(`SOC_NIRS_INT_STATUS_REG, 8'h00, top_test_cfg.nirs_read_intr_status); //R1C
            //cross check sattus
            check_status_reg_r1c(top_test_cfg.nirs_read_intr_status, `NIRS_PPG_IF.ch_en_mask,poll_pin_or_stsreg);
         end
         else begin
           `uvm_info("NIRS_INT",$sformatf("SOC_NIRS_INT_STATUS_REG: gen_reg_int_clr_typ %0d", gen_reg_int_clr_typ),UVM_LOW) 
            `WR_NIRS_REG(`SOC_NIRS_INT_STATUS_REG, `NIRS_PPG_IF.ch_en_mask, top_test_cfg.pads); //RW1C, clear interrupt status of enabled channels
            //cross check status
            check_status_reg_w1c();
         end
       end

   endtask

   task pin_int_active_high_level_active(int channel_num);  
        `uvm_info("NIRS_INT",$sformatf("WAIT FOR int_active_high_level_active INTERRUPT!!!! For CH =%0h\n", channel_num),UVM_LOW )       
        @(posedge `SOC_TOP.IOBUF_PAD[11]);     // 0-->1 throughout
        `uvm_info("NIRS_INT",$sformatf("int_active_high_level_active INTERRUPT OCCURRED!!!! For CH =%0h\n", channel_num),UVM_LOW )
   endtask

   task automatic pin_int_active_high_pulse_active(int channel_num);
        `uvm_info("NIRS_INT",$sformatf("WAIT FOR pin_int_active_high_pulse_active INTERRUPT!!!! For CH =%0h\n", channel_num),UVM_LOW )
         //@(posedge `NIRS_PPG_IF.nirs_int_io[channel_num]); 
         //RD STS
         //if STS == expected --> check PIN
         //  
         @(posedge `SOC_TOP.IOBUF_PAD[11])//wait(`SOC_TOP.IOBUF_PAD[11]);   // 0 -->1 ( 1 PPG CLK)
         `uvm_info("NIRS_INT",$sformatf("pin_int_active_high_pulse_active INTERRUPT OCCURRED!!!! For CH =%0h, INT_IO[%0d] =%0h\n", channel_num, channel_num, `NIRS_PPG_IF.nirs_int_io[channel_num]),UVM_LOW )
         
        @( posedge `CLK_CTRL_TOP.clk_ppg); 
        @( negedge `CLK_CTRL_TOP.clk_ppg);
        @( posedge `CLK_CTRL_TOP.clk_ppg);
//        //for(int i=0; i<8; i++)begin   //if each channel interrupt comes one after the other then IOPAD PIN won;t be one ppg clock
//           //if(`NIRS_PPG_IF.ch_en_mask[i])begin
//             if(`NIRS_PPG_IF.nirs_int_io[channel_num] !== 1'b0) begin
//                
//                `nnc_error("NIRS_INT",$sformatf("PIN INTERRUPT ERROR!!!! INT_IO[%0d] =%0h, For CH =%0h\n", channel_num, `NIRS_PPG_IF.nirs_int_io[channel_num], channel_num)) 
//             end
//           //end
//        //end
        if(`SOC_TOP.IOBUF_PAD[11] !== 1'b0) begin
          `nnc_error("NIRS_INT",$sformatf("PIN INTERRUPT ERROR!!!! SOC_TOP.IOBUF_PAD[11] %0d, For CH =%0h\n", `SOC_TOP.IOBUF_PAD[11], channel_num)) 
        end
   endtask

   task pin_int_active_low_level_active(int channel_num);
       `uvm_info("NIRS_INT",$sformatf("WAIT FOR pin_int_active_low_level_active INTERRUPT!!!! For CH =%0h\n", channel_num),UVM_LOW )
        @(negedge `SOC_TOP.IOBUF_PAD[11]);     // 0-->1 throughout
        `uvm_info("NIRS_INT",$sformatf("pin_int_active_low_level_active INTERRUPT OCCURRED!!!! For CH =%0h\n", channel_num),UVM_LOW )

   endtask

   task pin_int_active_low_pulse_active(int channel_num); 
       `uvm_info("NIRS_INT",$sformatf("WAIT FOR pin_int_active_low_pulse_active INTERRUPT!!!! For CH =%0h\n", channel_num),UVM_LOW )      
       @(negedge `SOC_TOP.IOBUF_PAD[11]);     // 0-->1 (1 PPG CLK)
      `uvm_info("NIRS_INT",$sformatf("pin_int_active_low_pulse_active INTERRUPT OCCURRED!!!! For CH =%0h\n", channel_num),UVM_LOW )
        @( posedge `CLK_CTRL_TOP.clk_ppg); 
        @( negedge `CLK_CTRL_TOP.clk_ppg);
        @( posedge `CLK_CTRL_TOP.clk_ppg);
        if( `SOC_TOP.IOBUF_PAD[11] !== 1'b1) begin
          `nnc_error("NIRS_INT",$sformatf("PIN INTERRUPT ERROR!!!! SOC_TOP.IOBUF_PAD[11] %0d, For CH =%0h\n", `SOC_TOP.IOBUF_PAD[11], channel_num)) 
        end
   endtask

   task drive_nirs_adj0_to_nirs_if();
       `NIRS_PPG_IF.pdbias_en   = `NIRS_PPG_CTRL_CFG.pdbias_en;  //one time configuration at the beginning
       `NIRS_PPG_IF.pdbias_adj  = `NIRS_PPG_CTRL_CFG.pdbias_adj; //one time configuration at the beginning
       `NIRS_PPG_IF.fchop_adj   = `NIRS_PPG_CTRL_CFG.fchop_adj;  //one time configuration at the beginning
       `NIRS_PPG_IF.chopper_en  = `NIRS_PPG_CTRL_CFG.chopper_en; //one time configuration at the beginning
       `NIRS_PPG_IF.test_en     = `NIRS_PPG_CTRL_CFG.test_en;    //one time configuration at the beginning

   endtask 


  task config_general_interrupt_ctrl_reg;
    top_test_cfg.wr_data[0] = {5'b0,`NIRS_PPG_IF.gen_reg_int_active_level, `NIRS_PPG_IF.gen_reg_int_clr_typ, `NIRS_PPG_IF.gen_reg_int_length_sel};
    `WR_NORMAL_REG(`SOC_GENERAL_INT_CTRL_REG, top_test_cfg.wr_data[0], top_test_cfg.pads);  
  endtask

  //
  task check_status_reg_r1c(logic [7:0] read_status, logic[7:0] expected_status, bit in_poll_pin_or_stsreg);
       logic [7:0] gen_nirs_rd_intr_status, nirs_rd_intr_status;

       //if(in_poll_pin_or_stsreg === 1'b1)begin // for int pin or don;t output to pin polling status register
       //  if(read_status !== expected_status)begin
       //    `nnc_error("NIRS_INT_STS",$sformatf("R1C READ STATUS ERROR!!!! read_status =%0h, expected_status =%0h\n", read_status, expected_status))
       //  end
       //  else begin
       //    `uvm_info("NIRS_INT_STS","R1C INTERRUPT STS MATCH!!!!",UVM_LOW )
       //  end
       //end
       //check interrupt line
       check_interrupt_after_clear_sts();
       `RD_NORMAL_REG(`SOC_GENERAL_INT_STS_6_REG, 8'h00, gen_nirs_rd_intr_status);
       `RD_NIRS_REG(`SOC_NIRS_INT_STATUS_REG, 8'h00, nirs_rd_intr_status); 
        if((gen_nirs_rd_intr_status !==0) || (nirs_rd_intr_status !==0))begin 
           `nnc_error("NIRS_INT_STS",$sformatf("R1C READ STATUS GEN AND NIRS REG ERROR!!!! GEN_NIRS_STS_REG =%0h, NIRS_STS_REG =%0h\n", gen_nirs_rd_intr_status, nirs_rd_intr_status))
       end
       else begin
         `uvm_info("NIRS_INT_STS",$sformatf("R1C READ STATUS GEN AND NIRS REG STS MATCH!!!!  GEN_NIRS_STS_REG =%0h, NIRS_STS_REG =%0h", gen_nirs_rd_intr_status, nirs_rd_intr_status),UVM_LOW )
       end

  endtask
  
  //
  task check_status_reg_w1c();
    logic [7:0] read_gen_sts_reg;
    logic [7:0] read_nirs_sts_reg;
    `RD_NORMAL_REG(`SOC_GENERAL_INT_STS_6_REG, 8'h00, read_gen_sts_reg); 
    `RD_NIRS_REG(`SOC_NIRS_INT_STATUS_REG, 8'h00, read_nirs_sts_reg);
    //wait for few clocks if ppg clock is gated (if bypass_or_gateclk=0)
    if((read_gen_sts_reg !== 8'h0) || (read_nirs_sts_reg !== 8'h0))begin
      `nnc_error("NIRS_INT_STS",$sformatf("RW1C READ STATUS ERROR!!!! read_gen_sts_reg =%0h, read_nirs_sts_reg =%0h, expected read_sts_value =0\n", read_gen_sts_reg, read_nirs_sts_reg))
    end
    else begin
      `uvm_info("NIRS_INT_STS","WR1C INTERRUPT STS MATCH!!!!",UVM_LOW )
    end
    //check interruot line
    check_interrupt_after_clear_sts();
  endtask

  //
  task check_interrupt_after_clear_sts();                                                        
     if(`NIRS_PPG_IF.nirs_int_pin_en === 1'b1)begin                     
       if(`NIRS_PPG_IF.gen_reg_int_active_level === 1'b0)begin       //active low                                                     
         if(`SOC_TOP.IOBUF_PAD[11] !== 1'b1)
           `nnc_error("NIRS_INT_STS",$sformatf("INT PIN NOT CLEARED (IOBUF_PAD[11] =%0h)\n", `SOC_TOP.IOBUF_PAD[11]))  
         else   `uvm_info("NIRS_INT","INT PIN CLEARED!!!!",UVM_LOW )
       end
       else begin //active HIGH
         if(`SOC_TOP.IOBUF_PAD[11] !== 1'b0)
           `nnc_error("NIRS_INT_STS",$sformatf("INT PIN NOT CLEARED (IOBUF_PAD[11] =%0h)\n", `SOC_TOP.IOBUF_PAD[11])) 
         else   `uvm_info("NIRS_INT","INT PIN CLEARED!!!!",UVM_LOW )            
       end   
     end
//     else begin // don't output to pin
//       
//     end
  endtask

  task first_time_config_drive_to_nirs_if();
    `NIRS_PPG_IF.nirs_ppg_mode_sel      = `NIRS_PPG_CTRL_CFG.nirs_ppg_mode_sel;
    `NIRS_PPG_IF.nirs_ppg_led_signle_en = `NIRS_PPG_CTRL_CFG.nirs_ppg_led_signle_en;
    `NIRS_PPG_IF.nirs_ppg_led_ambient_en =  `NIRS_PPG_CTRL_CFG.nirs_ppg_led_ambient_en;
    `NIRS_PPG_IF.idac_min_int_en = `NIRS_PPG_CTRL_CFG.idac_min_int_en; 
    `NIRS_PPG_IF.idac_max_int_en = `NIRS_PPG_CTRL_CFG.idac_max_int_en; 
    `NIRS_PPG_IF.iref_fine_on_not_off_en = `NIRS_PPG_CTRL_CFG.iref_fine_on_not_off_en;
    `NIRS_PPG_IF.iref_fine_not_on_en = `NIRS_PPG_CTRL_CFG.iref_fine_not_on_en;
    `NIRS_PPG_IF.iref_coarse_on_not_off_en = `NIRS_PPG_CTRL_CFG.iref_coarse_on_not_off_en;
    `NIRS_PPG_IF.iref_coarse_not_on_en    = `NIRS_PPG_CTRL_CFG.iref_coarse_not_on_en;
    `NIRS_PPG_IF.data_ready_en = `NIRS_PPG_CTRL_CFG.data_ready_en;
    `NIRS_PPG_IF.nirs_int_pin_en = `NIRS_PPG_CTRL_CFG.nirs_int_pin_en;
  endtask

  //irrespective of nirs_int_pin_en =1 or 0, poll status, when output ot pin also we need to poll the status becuase 
  //sometimes each channel interrupt come very close then waiting on posedge of IOPAD[11] may no tbe correct, we donlt know when all channels interrupt generated and which channel interrupt generated
  // to simplify using below function

  task automatic monitor_chx_nirs_interrupt(int expected_interrupts, logic[7:0] intr_ch_check, int ch_num);

     bit [7:0] intr_status;
     int interrupt_count = 0; 
     bit [7:0] prev_status = 8'h00;
     automatic int channel_num;
     automatic int channel_enabled; //doesn;t matter using this
     
    channel_num = ch_num;
    channel_enabled = intr_ch_check;
    `uvm_info("NIRS_INT", $sformatf("wait for INTERRUPT!!!! for ENABLED CHANNELS =%0h\n",channel_enabled),UVM_MEDIUM)
     //while(interrupt_count < expected_interrupts)  begin 
     //forever begin
       
       //`uvm_info("NIRS_INT", $sformatf("IN while loop wait for INTERRUPT!!!! interrupt_count =%0d",interrupt_count),UVM_LOW) 
 
       //-----------------------------------------
       // Interrupt output enabled to external pin
       //-----------------------------------------
       //if (`NIRS_PPG_IF.nirs_int_pin_en === 1'b1) begin
       //-----------------------------------------
       // Interrupt not routed to pin
       //-----------------------------------------
       //else begin   
    
        do begin
           if(`NIRS_PPG_IF.clear_int_via_gen_int_sts_reg_or_nirs_int_sts_reg === 1'b0)begin     //poll nirs sts reg
             `RD_NIRS_REG(`SOC_NIRS_INT_STATUS_REG,8'h00, intr_status); 
             `uvm_info("NIRS_INT",$sformatf("Poll NIRS INT STATUS for CH_NUM = %0h intr_status =%0h ", channel_num, (intr_status & channel_enabled)),UVM_LOW)
           end
           else begin
             `RD_NORMAL_REG(`SOC_GENERAL_INT_STS_6_REG, 8'h00, intr_status); //poll gen int sts reg
              `uvm_info("NIRS_INT",$sformatf("Poll NIRS GEN_INT STATUS for CH_NUM = %0h intr_status =%0h ", channel_num, (intr_status & channel_enabled)),UVM_LOW)
           end
        end while((intr_status & channel_enabled) == 0);

         `uvm_info("NIRS_INT",$sformatf("Interrupt generated from channel %0h, channel_enabled =%0d", channel_num,channel_enabled),UVM_LOW)
         interrupt_count++;
       //end //else

    //end //while
  
    `uvm_info("INT_MON",$sformatf("Completed interrupt monitoring for Channel_num =%0h\n",channel_num),UVM_LOW)
   endtask  

   
  // ------------------------------
  // Declare the report_phase task
  // ------------------------------
  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction

endclass : `TESTNAME
