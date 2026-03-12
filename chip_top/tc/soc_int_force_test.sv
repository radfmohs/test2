/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_int_force_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_int_force_test                                             
// Designer	: pfwang@nanochap.com                                                                 
// Date		: 14-07-2025                                                                     
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_int_force_test
`define TESTCFG soc_int_force_test_cfg

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

//int en 
  rand logic       wavegen_int_en_ch0;   //h28 bit0
  rand logic       wavegen_int_en_ch1;   //h68 bit0
  rand logic       leadoff_int_en_ch0;   //h3a bit4   
  rand logic       leadoff_int_en_ch1;   //h3a bit5
  rand logic       ana_lvd_int_en;       //h52 bit0
  rand logic       ana_comp_int_en_ch0;  //h52 bit1
  rand logic       ana_comp_int_en_ch1;  //h52 bit2
  rand logic       short_int_en_ch0;  //h54 bit2
  rand logic       short_int_en_ch1;  //h54 bit3
  rand logic       tsc_int_en;  // h88 bit0

  rand logic       int_act_lvl;
  rand logic       int_clr_typ;
  rand logic       int_length_slct;

  rand logic [7:0] wavegen_int_reg0;
  rand logic [7:0] wavegen_int_reg1;
  rand logic [7:0] leadoff_int_reg;
  rand logic [7:0] ana_int_reg;
  rand logic [7:0] short_int_reg;
  rand logic [7:0] int_ctrl_reg;
  rand logic [7:0] tsc_int_ctrl;

  constraint c_wavegen_int_reg0     {wavegen_int_reg0[0] ==  wavegen_int_en_ch0;} 
  constraint c_wavegen_int_reg1     {wavegen_int_reg1[0] ==  wavegen_int_en_ch1;}
  constraint c_leadoff_int_reg      {leadoff_int_reg[5:4]  ==  {leadoff_int_en_ch1, leadoff_int_en_ch0};}
  constraint c_ana_int_reg          {ana_int_reg[2:0]      ==  {ana_comp_int_en_ch1, ana_comp_int_en_ch0, ana_lvd_int_en};}
  constraint c_short_int_reg        {short_int_reg[3:2]    == {short_int_en_ch1, short_int_en_ch0}; }     
  constraint c_int_ctrl_reg         {int_ctrl_reg[2:0] ==  {int_act_lvl, int_clr_typ, int_length_slct};}
  constraint c_tsc_int_ctrl  {tsc_int_ctrl[0] == {/*tsc_int_trans_sel,*/ tsc_int_en};}


  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_int_force_test_cfg");
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

        `DUT_IF.lead_off_comp_reverse = 0;
`DUT_IF.lead_off_ch0_comp_low_active = 0;
`DUT_IF.lead_off_ch1_comp_low_active = 0;
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

    `nnc_info("SOC_TEST", "soc_int_force_test start", NNC_LOW)

    // ==================================================================================
    // Please add your code of your test here
    // ---------------------------------------------------------------------------------- 
 
    repeat(10) begin 
    //enable leadoff int
    //assert(top_test_cfg.randomize() with {reg_addr == `SOC_LEAD_OFF_INT_REG;});
    //`nnc_info("SOC_TEST", "Single Writing to a Register", NNC_LOW)
    //`WR_NORMAL_REG(`SOC_LEAD_OFF_INT_REG, top_test_cfg.leadoff_int_reg, top_test_cfg.pads);    
   
    //assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_COMP_INT_TRANS_EN_REG;});
    //`nnc_info("SOC_TEST", "Single Writing to a Register", NNC_LOW)
    //`WR_NORMAL_REG(`SOC_ANA_COMP_INT_TRANS_EN_REG, top_test_cfg.short_int_reg, top_test_cfg.pads);      
  
    //assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_COMP_INT_EN_REG;});
    //`nnc_info("SOC_TEST", "Single Writing to a Register", NNC_LOW)
    //`WR_NORMAL_REG(`SOC_ANA_COMP_INT_EN_REG, top_test_cfg.ana_int_reg, top_test_cfg.pads);  
   
    //assert(top_test_cfg.randomize() with {reg_addr == `SOC_ADDR_WG_DRV_INT_REG01;});
    `nnc_info("SOC_TEST", "Single Writing to a Register", NNC_LOW)
    `WR_WAVEGEN_REG(`SOC_ADDR_WG_DRV_INT_REG01, top_test_cfg.wavegen_int_reg0, top_test_cfg.pads);   
    
    //assert(top_test_cfg.randomize() with {reg_addr == `SOC_ADDR_WG_DRV_INT_REG01 + `WAVEGEN_DRIVER_OFFSET;});
    `nnc_info("SOC_TEST", "Single Writing to a Register", NNC_LOW)
    `WR_WAVEGEN_REG(`SOC_ADDR_WG_DRV_INT_REG01 + `WAVEGEN_DRIVER_OFFSET, top_test_cfg.wavegen_int_reg1, top_test_cfg.pads);

    `WR_NORMAL_REG(`SOC_TSC_INT_CTLR_REG, top_test_cfg.tsc_int_ctrl, top_test_cfg.pads);

    `nnc_info("SOC_TEST", "Single Writing to a Register", NNC_LOW)
    `WR_NORMAL_REG(`SOC_GENERAL_INT_CTRL_REG, top_test_cfg.int_ctrl_reg, top_test_cfg.pads);
    repeat(2) @(posedge `CLK_CTRL_TOP.pclk); //sync int_en

    `ifdef BEHAVIORAL
    check_int("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_wg_driver.wg_driver_top_inst.genblk1[0].arb_wave_gen_inst.reg_wg_driver_int_sts[0]", top_test_cfg.wavegen_int_en_ch0,);
    check_int("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_wg_driver.wg_driver_top_inst.genblk1[0].arb_wave_gen_inst.reg_wg_driver_int_sts[1]", top_test_cfg.wavegen_int_en_ch0,);    
    check_int("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_wg_driver.wg_driver_top_inst.genblk1[1].arb_wave_gen_inst.reg_wg_driver_int_sts[0]", top_test_cfg.wavegen_int_en_ch1,);
    check_int("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_wg_driver.wg_driver_top_inst.genblk1[1].arb_wave_gen_inst.reg_wg_driver_int_sts[1]", top_test_cfg.wavegen_int_en_ch1,);

    check_int("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_lead_off_detector.lead_off_result", top_test_cfg.leadoff_int_en_ch0,);
    check_int("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_lead_off_detector.lead_off_result1", top_test_cfg.leadoff_int_en_ch1,);

    check_int("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_anac.u_comp1.ana_comp_ch_intr_sts", top_test_cfg.ana_comp_int_en_ch0,);
    check_int("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_anac.u_comp2.ana_comp_ch_intr_sts", top_test_cfg.ana_comp_int_en_ch1,);
    check_int("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_anac.ana_lvd_sts",  top_test_cfg.ana_lvd_int_en,);
    check_int("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_anac.u_anac_short_dtct_ch1.ana_comp_ch_stim_int_re", top_test_cfg.short_int_en_ch0,);
    check_int("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_anac.u_anac_short_dtct_ch2.ana_comp_ch_stim_int_re", top_test_cfg.short_int_en_ch1,);

    check_int("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_temp_sar_ctrl.u_tsc.ana_comp_ch_intr_sts", top_test_cfg.tsc_int_en, ); 

    if(top_test_cfg.int_length_slct === 1) begin
    uvm_hdl_force("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_wg_driver.wg_driver_top_inst.genblk1[0].arb_wave_gen_inst.reg_wg_driver_int_sts[0]", 0); 
    uvm_hdl_force("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_wg_driver.wg_driver_top_inst.genblk1[0].arb_wave_gen_inst.reg_wg_driver_int_sts[1]", 0);
    uvm_hdl_force("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_wg_driver.wg_driver_top_inst.genblk1[1].arb_wave_gen_inst.reg_wg_driver_int_sts[0]", 0);
    uvm_hdl_force("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_wg_driver.wg_driver_top_inst.genblk1[1].arb_wave_gen_inst.reg_wg_driver_int_sts[1]", 0);
    uvm_hdl_force("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_lead_off_detector.lead_off_result", 0);
    uvm_hdl_force("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_lead_off_detector.lead_off_result1", 0);
    uvm_hdl_force("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_anac.u_comp1.ana_comp_ch_intr_sts", 0);
    uvm_hdl_force("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_anac.u_comp2.ana_comp_ch_intr_sts", 0);
    uvm_hdl_force("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_anac.ana_lvd_sts", 0);
    uvm_hdl_force("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_anac.u_anac_short_dtct_ch1.ana_comp_ch_stim_int_re", 0);
    uvm_hdl_force("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_anac.u_anac_short_dtct_ch2.ana_comp_ch_stim_int_re", 0);
    uvm_hdl_force("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_temp_sar_ctrl.u_tsc.ana_comp_ch_intr_sts", 0);
    `else
    //if(top_test_cfg.int_length_slct === 1) 
    check_int("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_wg_driver.wg_driver_top_inst.genblk1_0__arb_wave_gen_inst.reg_wg_driver_int_sts_reg_0_.Q", top_test_cfg.wavegen_int_en_ch0);
    //else 
    //check_int("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_wg_driver.wg_driver_top_inst.genblk1_0__arb_wave_gen_inst.reg_wg_driver_int_sts_reg_0_.QN", top_test_cfg.wavegen_int_en_ch0,1);
    check_int("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_wg_driver.wg_driver_top_inst.genblk1_0__arb_wave_gen_inst.reg_wg_driver_int_sts_reg_1_.Q", top_test_cfg.wavegen_int_en_ch0);    
    //if(top_test_cfg.int_length_slct === 1)
    check_int("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_wg_driver.wg_driver_top_inst.genblk1_1__arb_wave_gen_inst.reg_wg_driver_int_sts_reg_0_.Q", top_test_cfg.wavegen_int_en_ch1);
    //else
    //check_int("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_wg_driver.wg_driver_top_inst.genblk1_1__arb_wave_gen_inst.reg_wg_driver_int_sts_reg_0_.QN", top_test_cfg.wavegen_int_en_ch1,1);
    check_int("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_wg_driver.wg_driver_top_inst.genblk1_1__arb_wave_gen_inst.reg_wg_driver_int_sts_reg_1_.Q", top_test_cfg.wavegen_int_en_ch1);

    check_int("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_lead_off_detector.lead_off_result_reg.Q", top_test_cfg.leadoff_int_en_ch0);
    check_int("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_lead_off_detector.lead_off_result1_reg.Q", top_test_cfg.leadoff_int_en_ch1);

    check_int("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_anac.u_comp1.ana_comp_ch_intr_sts_reg.Q", top_test_cfg.ana_comp_int_en_ch0);
    check_int("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_anac.u_comp2.ana_comp_ch_intr_sts_reg.Q", top_test_cfg.ana_comp_int_en_ch1);
    check_int("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_anac.ana_lvd_sts",  top_test_cfg.ana_lvd_int_en);
    check_int("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_anac.u_anac_short_dtct_ch1.ana_comp_ch_stim_int_re_reg.Q", top_test_cfg.short_int_en_ch0);
    check_int("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_anac.u_anac_short_dtct_ch2.ana_comp_ch_stim_int_re_reg.Q", top_test_cfg.short_int_en_ch1);

    check_int("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_temp_sar_ctrl.u_tsc.ana_comp_ch_intr_sts_reg.Q", top_test_cfg.tsc_int_en); 

    if(top_test_cfg.int_length_slct === 1) begin
    uvm_hdl_force("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_wg_driver.wg_driver_top_inst.genblk1_0__arb_wave_gen_inst.reg_wg_driver_int_sts_reg_0_.Q", 0);
    uvm_hdl_force("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_wg_driver.wg_driver_top_inst.genblk1_0__arb_wave_gen_inst.reg_wg_driver_int_sts_reg_1_.Q", 0);
    uvm_hdl_force("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_wg_driver.wg_driver_top_inst.genblk1_1__arb_wave_gen_inst.reg_wg_driver_int_sts_reg_0_.Q", 0);
    uvm_hdl_force("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_wg_driver.wg_driver_top_inst.genblk1_1__arb_wave_gen_inst.reg_wg_driver_int_sts_reg_1_.Q", 0);
    uvm_hdl_force("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_lead_off_detector.lead_off_result_reg.Q", 0);
    uvm_hdl_force("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_lead_off_detector.lead_off_result1_reg.Q", 0);
    uvm_hdl_force("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_anac.u_comp1.ana_comp_ch_intr_sts_reg.Q", 0);
    uvm_hdl_force("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_anac.u_comp2.ana_comp_ch_intr_sts_reg.Q", 0);
    uvm_hdl_force("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_anac.ana_lvd_sts", 0);
    uvm_hdl_force("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_anac.u_anac_short_dtct_ch1.ana_comp_ch_stim_int_re_reg.Q", 0);
    uvm_hdl_force("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_anac.u_anac_short_dtct_ch2.ana_comp_ch_stim_int_re_reg.Q", 0);
    uvm_hdl_force("soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_temp_sar_ctrl.u_tsc.ana_comp_ch_intr_sts_reg.Q", 0);
    `endif

    end
    end


    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    #10000ns;
    `nnc_info("SOC_TEST", "soc_int_force_test end now", NNC_LOW)

    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ==================================================================================

    phase.drop_objection(this);
  endtask: main_phase

    task check_int(string int_sts_path, logic int_en, bit inv=0);
        if(top_test_cfg.int_length_slct === 0) begin 
            if(`SOC_TOP.IOBUF_PAD[7] === top_test_cfg.int_act_lvl) `nnc_error("SOC_TEST", $sformatf("%s int error", int_sts_path));
            @(posedge `CLK_CTRL_TOP.pclk);
            #10ns;
            if(inv) uvm_hdl_force(int_sts_path, 0); else uvm_hdl_force(int_sts_path, 1);
            #50ns;
            if(`SOC_TOP.IOBUF_PAD[7] !== (int_en ~^ top_test_cfg.int_act_lvl)) `nnc_error("SOC_TEST", $sformatf("%s int error int_en=%h, int_act_lvl=%h", int_sts_path, int_en, top_test_cfg.int_act_lvl));
            #50ns;
            //@(posedge `CLK_CTRL_TOP.pclk);
            if(inv) uvm_hdl_force(int_sts_path, 1); else uvm_hdl_force(int_sts_path, 0);
            #50ns;
            if(`SOC_TOP.IOBUF_PAD[7] === top_test_cfg.int_act_lvl) `nnc_error("SOC_TEST", $sformatf("%s int error", int_sts_path));
            #50ns;
        end
        else if(top_test_cfg.int_length_slct === 1) begin
            if(`SOC_TOP.IOBUF_PAD[7] === top_test_cfg.int_act_lvl) `nnc_error("SOC_TEST", $sformatf("%s int error", int_sts_path));
            @(posedge `CLK_CTRL_TOP.pclk);
            #10ns;
            if(inv) uvm_hdl_force(int_sts_path, 0); else uvm_hdl_force(int_sts_path, 1);
            //@(posedge `CLK_CTRL_TOP.pclk);
            #50ns; //should be extends in pg_sim
            if(`SOC_TOP.IOBUF_PAD[7] !== (int_en ~^ top_test_cfg.int_act_lvl)) `nnc_error("SOC_TEST", $sformatf("%s int error", int_sts_path));
            @(posedge `CLK_CTRL_TOP.pclk);
            #50ns; //should be extends in pg_sim
            if(`SOC_TOP.IOBUF_PAD[7] === top_test_cfg.int_act_lvl) `nnc_error("SOC_TEST", $sformatf("%s int error", int_sts_path));
            #50ns;
        end
    endtask

    //task 


  // ------------------------------
  // Declare the report_phase task
  // ------------------------------
  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction

endclass : `TESTNAME
