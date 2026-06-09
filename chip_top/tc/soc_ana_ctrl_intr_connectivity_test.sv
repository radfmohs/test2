/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_ana_ctrl_intr_connectivity_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_ana_ctrl_intr_connectivity_test                                             
// Designer	: ophina@nanochap.com                                                                 
// Date		: 18-03-2024                                                                   
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_ana_ctrl_intr_connectivity_test
`define TESTCFG soc_ana_ctrl_intr_connectivity_test_cfg

class `TESTCFG extends soc_base_test_cfg;

  `nnc_object_utils(`TESTCFG)

  // ===============================================
  // Adding your new varialbles in config test
  // -----------------------------------------------

  rand logic [7:0]  wr_data[256];
  rand int          no_of_bytes; 
  rand logic [7:0]  reg_addr;
  rand logic [7:0]  pads;
  rand logic [7:0]  mask;
  rand logic [7:0]  expected_data;
       logic [7:0]  rd_data[];
  rand logic        int_active_level_high_or_low;
  rand logic        clear_intr_manual_or_auto;
  rand logic        intr_length_slct_level_or_pulse;
  rand logic        multi_pins;
  rand logic [2:0]  lvd_sel;
  rand logic        lvd_en;
       integer      cnt;
  rand bit          stim_int_int_ctrl;
  rand bit          stim_cycle_int_ctrl;
  rand bit          stim_delta_int_ctrl;
  rand bit          stim_loff_int_ctrl;
  rand bit          stim_short_int_ctrl;

  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_ana_ctrl_intr_connectivity_test_cfg");
    super.new(name);
    
  endfunction: new

  // ===============================================
  // Adding constraints of randomization
  // -----------------------------------------------

  // testmode_sel[1:0] : 00-Normal mode, 01: Scanmode, 10: BIST mode, 11 atm0/1/2/3/4
  constraint c_testmode_sel    { soft testmode_sel == 2'b00; }

  // No of bytes in a burst
  constraint c_no_of_bytes     { soft no_of_bytes == 2; }

  // pads values
  constraint c_pads            { soft pads == 8'h00; }

  // mask values
  constraint c_mask            { soft mask == 8'hff; }

//  constraint c_int_active_level_low_or_high  { int_active_level_high_or_low == 1; } // 1: intr active high, 0 : intr active low 

//  constraint c_clear_intr_manual_or_auto  { clear_intr_manual_or_auto == 0; } // 0: manually clear intr by w1c, 1 : auto clear intr by r1c 

//  constraint c_intr_length_slct_pulse_or_level  { intr_length_slct_level_or_pulse == 0; } // 0: level INT, 1: pulse INT

  constraint c_lvd_en                   { lvd_en == 1; } 

  constraint c_lvd_sel                  { lvd_sel != 0; } 

  constraint c_vbat_level               { solve lvd_sel before vbat_level; vbat_level >= lvd_sel; } 

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

  typedef enum {INT_LVD = 0, INT_TSC = 7, INT_STIM = 1} selected_intr ;
  selected_intr sel_int;

  typedef enum {INT_CYCLE = 7, INT_INT = 6, INT_DELTA = 5, INT_LOFF = 0, INT_SHORT = 1} stimulation_intr;
  stimulation_intr stim_intr;

  bit use_old_intr_reg_or_general_reg_to_clr;
  logic [7:0] multi; //
  rand bit          stim_int_int_ctrl;
  rand bit          stim_cycle_int_ctrl;
  rand bit          stim_delta_int_ctrl;
  rand bit          stim_loff_int_ctrl;
  rand bit          stim_short_int_ctrl;

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
    `nnc_top.set_timeout(500ms);
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
    `DUT_IF.int_active_level_high_or_low = top_test_cfg.int_active_level_high_or_low;
    `DUT_IF.clear_intr_manual_or_auto = top_test_cfg.clear_intr_manual_or_auto;
    `DUT_IF.intr_length_slct_level_or_pulse = top_test_cfg.intr_length_slct_level_or_pulse;
    `DUT_IF.lvd_sel = top_test_cfg.lvd_sel;
    `DUT_IF.lvd_en = top_test_cfg.lvd_en;
    `DUT_IF.vbat_level = top_test_cfg.vbat_level;

    phase.drop_objection(this);
  endtask : pre_reset_phase

  task check_ana_lvd_connectivity();
    // configure LVD_SEL  
    top_test_cfg.wr_data[0] = `INIT_SOC_ANA_EN_REG_0_3;
    top_test_cfg.wr_data[0][0] = `DUT_IF.lvd_en;
    `WR_NORMAL_REG(`SOC_ANA_EN_REG_0_3, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // configure LVD_EN  
    top_test_cfg.wr_data[0] = {5'b0,`DUT_IF.lvd_sel};
    `WR_NORMAL_REG(`SOC_ANA_GEN_REG_0_0, top_test_cfg.wr_data[0], top_test_cfg.pads);

    fork
      forever begin
        @(posedge`DUT_IF.sys_clk);
        if(`ANA_TOP.D2A_LVD_SEL != `DUT_IF.lvd_sel)begin
	  `uvm_error("SOC_TEST",$sformatf("ANA_TOP.D2A_LVD_SEL[2:0] =%0b ,Expected lvd_sel[2:0]=%0b",`ANA_TOP.D2A_LVD_SEL,`DUT_IF.lvd_sel))
        end
        else begin
          `nnc_info("SOC_TEST", $sformatf("LVD_SEL matched"), NNC_MEDIUM)
        end
      end
      forever begin
        @(posedge`DUT_IF.sys_clk);
        if(`ANA_TOP.D2A_LVD_EN != `DUT_IF.lvd_en)begin
	  `uvm_error("SOC_TEST",$sformatf("ANA_TOP.D2A_LVD_EN =%0b ,Expected lvd_en=%0b",`ANA_TOP.D2A_LVD_EN,`DUT_IF.lvd_en))
        end
        else begin
          `nnc_info("SOC_TEST", $sformatf("LVD_EN matched"), NNC_MEDIUM)
        end
      end
    join_none
  endtask : check_ana_lvd_connectivity

  // -----------------------------------------
  // Declare the main_phase task of your test
  // -----------------------------------------
  virtual task main_phase(nnc_phase phase);
    logic [7:0] rd_data;
    super.main_phase(phase);
    phase.raise_objection(this);

    //check_connectivity();

    check_ana_lvd_connectivity();
    
    top_test_cfg.wr_data[0] = {1'b0, top_test_cfg.multi_pins, 5'b0, `DUT_IF.intr_length_slct_level_or_pulse};
    `WR_NORMAL_REG(`SOC_PMU_REG, top_test_cfg.wr_data[0], top_test_cfg.pads);
    #10000ns;

    top_test_cfg.wr_data[0] = {5'b0,`DUT_IF.int_active_level_high_or_low,`DUT_IF.clear_intr_manual_or_auto,`DUT_IF.intr_length_slct_level_or_pulse};
    `WR_NORMAL_REG(`SOC_GENERAL_INT_CTRL_REG, top_test_cfg.wr_data[0], top_test_cfg.pads);
    #10000ns;

	`nnc_info("MULTI_PINS", $sformatf("Multi_pins is %b", top_test_cfg.multi_pins), NNC_LOW)

    // check INTB RESET value
    if(`DUT_IF.int_active_level_high_or_low === 0) begin
	if(`SOC_TB.INTB !== 1 || `SOC_TB.INT[0] !== 1|| `SOC_TB.INT[1] !== 1|| `SOC_TB.INT[2] !== 1|| `SOC_TB.INT[3] !== 1)
	  `nnc_error("INTB Reset", "Error! RESET VALUE INTB not active low as expected!!")
	else
	  `nnc_info("INTB Reset", "Active low INTB selected!", NNC_LOW)
    end
    else begin
	if(`SOC_TB.INTB !== 0 || `SOC_TB.INT[0] !== 0|| `SOC_TB.INT[1] !== 0|| `SOC_TB.INT[2] !== 0|| `SOC_TB.INT[3] !== 0)
	  `nnc_error("INTB Reset", "Error! RESET VALUE INTB not active high as expected!!")
	else
	   `nnc_info("INTB Reset", "Active high INTB selected!", NNC_LOW)
    end

    #10000ns;
    top_test_cfg.cnt = 0;
    while(top_test_cfg.cnt < 3) begin
      `nnc_info("TSC INTR CHECK", $sformatf("inside repeat loop for TSC intr check = %0d",top_test_cfg.cnt), NNC_LOW)
      top_test_cfg.cnt++;
      sel_int = INT_TSC;
      intr_tsc_check();
    end
    top_test_cfg.cnt = 0;
    while(top_test_cfg.cnt < 3) begin
      `nnc_info("STIM INTR CHECK", $sformatf("inside repeat loop for STIM intr check = %0d",top_test_cfg.cnt), NNC_LOW)
      top_test_cfg.cnt++;
      sel_int = INT_STIM;
      intr_stim_check();
    end
    top_test_cfg.cnt = 0;
    while(top_test_cfg.cnt < 3) begin
      `nnc_info("LVD INTR CHECK", $sformatf("inside repeat loop for LVD intr check = %0d",top_test_cfg.cnt), NNC_LOW)
      top_test_cfg.cnt++;
      sel_int = INT_LVD;
      intr_lvd_check();
    end
/*
    top_test_cfg.cnt = 0;
    while(top_test_cfg.cnt < 3) begin
      `nnc_info("SOC_TEST", $sformatf("inside repeat loop for back to back diff intr check = %0d",top_test_cfg.cnt), NNC_LOW)
      top_test_cfg.cnt++;
      sel_int = INT3;
      int3_check();
    end
*/
    phase.drop_objection(this);
  endtask: main_phase

  // ------------------------------
  // Declare the report_phase task
  // ------------------------------
  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction
  
  task intr_stim_check();
    logic [7:0] rd_data = 0;
    logic [7:0] wr_data = 0;
    logic [7:0] exp_ana_intr_sts_val = 0;

    use_old_intr_reg_or_general_reg_to_clr =$random;
    
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_PMU_REG; wr_data[0] == 8'h40;});//enable interrupt
    `nnc_info("MULTI_PIN", ("MULTIL_INTB_PIN == 1"), NNC_LOW)
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    multi = top_test_cfg.wr_data[0];
    
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_STIM_PAD_CTRL1; wr_data[0] == 8'h18;});//enable interrupt
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    while((top_test_cfg.stim_cycle_int_ctrl  | top_test_cfg.stim_int_int_ctrl | top_test_cfg.stim_delta_int_ctrl | top_test_cfg.stim_loff_int_ctrl | top_test_cfg.stim_short_int_ctrl) == 0) begin
        assert(top_test_cfg.randomize() with {wr_data[0] == {top_test_cfg.stim_cycle_int_ctrl, top_test_cfg.stim_int_int_ctrl, top_test_cfg.stim_delta_int_ctrl, 5'b0};});//enable interrupt
    end
    `nnc_info("SOC_TEST", $sformatf("will be writing intr en register with wr_data =%0h",top_test_cfg.wr_data[0]), NNC_LOW)
    stim_cycle_int_ctrl = top_test_cfg.stim_cycle_int_ctrl;
    stim_int_int_ctrl   = top_test_cfg.stim_int_int_ctrl;
    stim_delta_int_ctrl = top_test_cfg.stim_delta_int_ctrl;
    stim_loff_int_ctrl  = top_test_cfg.stim_loff_int_ctrl;
    stim_short_int_ctrl = top_test_cfg.stim_short_int_ctrl;

    `nnc_info("CYCLE INT DELTA INT CTRL", $sformatf("CYCLE INT DELTA CTRL value %b", {stim_cycle_int_ctrl, stim_int_int_ctrl, stim_delta_int_ctrl}), NNC_LOW)
    `WR_NORMAL_REG(`SOC_STIM_PAD_CTRL,{stim_cycle_int_ctrl, stim_int_int_ctrl, stim_delta_int_ctrl, 1'b1,4'hF} , top_test_cfg.pads);
    `nnc_info("CYCLE INT DELTA INT CTRL", $sformatf("CYCLE INT DELTA TO PIN CTRL value %b", {stim_cycle_int_ctrl, stim_int_int_ctrl, stim_delta_int_ctrl}), NNC_LOW)
    `WR_NORMAL_REG(`SOC_STIM_MON_INT,{stim_cycle_int_ctrl, stim_int_int_ctrl, stim_delta_int_ctrl, 1'b0, 4'hF}, top_test_cfg.pads);
    `nnc_info("LOFF SHORT INT CTRL", $sformatf("LOFF SHORT INT CTRL value %b", {stim_loff_int_ctrl, stim_short_int_ctrl}), NNC_LOW)
    `WR_NORMAL_REG(`SOC_STIM_MON_LOFF_SHORT_INT_CTRL,{4'h0, stim_short_int_ctrl, stim_loff_int_ctrl, stim_short_int_ctrl, stim_loff_int_ctrl}, top_test_cfg.pads);
    `nnc_info("SOC_TEST", $sformatf("%s intr enable",sel_int.name), NNC_LOW)

    check_intr(sel_int,multi);

    exp_ana_intr_sts_val[sel_int] = 1;
    check_intr_sts_reg(exp_ana_intr_sts_val,sel_int);
  
    clear_intr();
 
    `nnc_info("SOC_TEST", $sformatf("waiting for INTB to deassert"), NNC_LOW)
    if(`DUT_IF.int_active_level_high_or_low == 1) 
      wait(`SOC_TB.INT[2] === 0);
    else 
      wait(`SOC_TB.INT[2] === 1);
    `nnc_info("INT", $sformatf("Finish deassert"), NNC_LOW)
    
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_STIM_MON_LOFF_SHORT_INT_CTRL; wr_data[0] == 8'h00;});//disable interrupt
    `WR_NORMAL_REG(`SOC_STIM_PAD_CTRL,{3'h0,1'b1,4'hF} , top_test_cfg.pads);
    `WR_NORMAL_REG(`SOC_STIM_MON_INT,{8'h0}, top_test_cfg.pads);
    `WR_NORMAL_REG(`SOC_STIM_MON_LOFF_SHORT_INT_CTRL,{8'h00}, top_test_cfg.pads);
    
    //check interrupt status reg
    exp_ana_intr_sts_val[sel_int] = 0;
    check_intr_sts_reg(exp_ana_intr_sts_val,sel_int);
    force `ZMEAS_TOP.one_cycle_data_vld = 0;
    force `ZMEAS_TOP.A2D_ADC_DATA_VLD = 0;
    force `ZMEAS_TOP.A2D_ADC_DELTA_DATA_VLD = 0;
    force `ZMEAS_TOP.leadoff_pulse_pair = 0;
    force `ZMEAS_TOP.short_pulse_pair = 0;

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_PMU_REG; wr_data[0] == 8'h00;});//enable interrupt
    `nnc_info("MULTI_PIN", ("MULTIL_INTB_PIN == 0"), NNC_LOW)
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    multi = top_test_cfg.wr_data[0];

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_STIM_MON_LOFF_SHORT_INT_CTRL; wr_data[0] == 8'h01;});//enable interrupt
    `nnc_info("SOC_TEST", $sformatf("will be writing intr en register with wr_data =%0h",top_test_cfg.wr_data[0]), NNC_LOW)
    `WR_NORMAL_REG(`SOC_STIM_PAD_CTRL,{stim_cycle_int_ctrl, stim_int_int_ctrl, stim_delta_int_ctrl, 1'b1,4'hF} , top_test_cfg.pads);
    `nnc_info("CYCLE INT DELTA INT CTRL", $sformatf("CYCLE INT DELTA TO PIN CTRL value %b", {stim_cycle_int_ctrl, stim_int_int_ctrl, stim_delta_int_ctrl}), NNC_LOW)
    `WR_NORMAL_REG(`SOC_STIM_MON_INT,{stim_cycle_int_ctrl, stim_int_int_ctrl, stim_delta_int_ctrl, 1'b0, 4'hF}, top_test_cfg.pads);
    `nnc_info("LOFF SHORT INT CTRL", $sformatf("LOFF SHORT INT CTRL value %b", {stim_loff_int_ctrl, stim_short_int_ctrl}), NNC_LOW)
    `WR_NORMAL_REG(`SOC_STIM_MON_LOFF_SHORT_INT_CTRL,{4'h0, stim_short_int_ctrl, stim_loff_int_ctrl, stim_short_int_ctrl, stim_loff_int_ctrl}, top_test_cfg.pads);
    `nnc_info("SOC_TEST", $sformatf("%s intr enable",sel_int.name), NNC_LOW)

    check_intr(sel_int,multi);

    exp_ana_intr_sts_val[sel_int] = 1;
    check_intr_sts_reg(exp_ana_intr_sts_val,sel_int);
    
    clear_intr();
    
    `nnc_info("SOC_TEST", $sformatf("waiting for INTB to deassert"), NNC_LOW)
    if(`DUT_IF.int_active_level_high_or_low == 1) 
      wait(`SOC_TB.INT[0] === 0);
    else 
      wait(`SOC_TB.INT[0] === 1);
    `nnc_info("INT", $sformatf("Finish deassert"), NNC_LOW)
    
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_STIM_MON_LOFF_SHORT_INT_CTRL; wr_data[0] == 8'h00;});//disable interrupt
    `nnc_info("SOC_TEST", $sformatf("will be writing intr en register with wr_data =%0h",top_test_cfg.wr_data[0]), NNC_LOW)
    `WR_NORMAL_REG(`SOC_STIM_PAD_CTRL,{3'h0,1'b1,4'hF} , top_test_cfg.pads);
    `WR_NORMAL_REG(`SOC_STIM_MON_INT,{8'h0}, top_test_cfg.pads);
    `WR_NORMAL_REG(`SOC_STIM_MON_LOFF_SHORT_INT_CTRL,{8'h00}, top_test_cfg.pads);
    
    //check interrupt status reg
    exp_ana_intr_sts_val[sel_int] = 0;
    check_intr_sts_reg(exp_ana_intr_sts_val,sel_int);
    force `ZMEAS_TOP.one_cycle_data_vld = 0;
    force `ZMEAS_TOP.A2D_ADC_DATA_VLD = 0;
    force `ZMEAS_TOP.A2D_ADC_DELTA_DATA_VLD = 0;
    force `ZMEAS_TOP.leadoff_pulse_pair = 0;
    force `ZMEAS_TOP.short_pulse_pair = 0;

  endtask: intr_stim_check
  
  task intr_tsc_check();
    logic [7:0] rd_data = 0;
    logic [7:0] wr_data = 0;
    logic [7:0] exp_ana_intr_sts_val = 0;

    use_old_intr_reg_or_general_reg_to_clr =$random;
    
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_PMU_REG; wr_data[0] == 8'h40;});//enable interrupt
    `nnc_info("MULTI_PIN", ("MULTIL_INTB_PIN == 1"), NNC_LOW)
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    multi = top_test_cfg.wr_data[0];

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_TSC_INT_CTLR_REG; wr_data[0] == 8'h01;});//enable interrupt
    `nnc_info("SOC_TEST", $sformatf("will be writing intr en register with wr_data =%0h",top_test_cfg.wr_data[0]), NNC_LOW)
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    `nnc_info("SOC_TEST", $sformatf("%s intr enable",sel_int.name), NNC_LOW)

    check_intr(sel_int,multi);

    exp_ana_intr_sts_val[sel_int] = 1;
    check_intr_sts_reg(exp_ana_intr_sts_val,sel_int);
  
    clear_intr();
 
    `nnc_info("SOC_TEST", $sformatf("waiting for INTB to deassert"), NNC_LOW)
    if(`DUT_IF.int_active_level_high_or_low == 1) 
      wait(`SOC_TB.INT[2] === 0);
    else 
      wait(`SOC_TB.INT[2] === 1);
    `nnc_info("INT", $sformatf("Finish deassert"), NNC_LOW)
    
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_TSC_INT_CTLR_REG; wr_data[0] == 8'h00;});//disable interrupt
    `nnc_info("SOC_TEST", $sformatf("will be writing intr en register with wr_data =%0h",top_test_cfg.wr_data[0]), NNC_LOW)
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    
    //check interrupt status reg
    exp_ana_intr_sts_val[sel_int] = 0;
    check_intr_sts_reg(exp_ana_intr_sts_val,sel_int);
    force `ANA_WRAPPER_TOP.A2D_TSC_COMP_OUT_CH1_tmp = 0;

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_PMU_REG; wr_data[0] == 8'h00;});//enable interrupt
    `nnc_info("MULTI_PIN", ("MULTIL_INTB_PIN == 0"), NNC_LOW)
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    multi = top_test_cfg.wr_data[0];

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_TSC_INT_CTLR_REG; wr_data[0] == 8'h01;});//enable interrupt
    `nnc_info("SOC_TEST", $sformatf("will be writing intr en register with wr_data =%0h",top_test_cfg.wr_data[0]), NNC_LOW)
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    `nnc_info("SOC_TEST", $sformatf("%s intr enable",sel_int.name), NNC_LOW)

    check_intr(sel_int,multi);

    exp_ana_intr_sts_val[sel_int] = 1;
    check_intr_sts_reg(exp_ana_intr_sts_val,sel_int);
    
    clear_intr();
    
    `nnc_info("SOC_TEST", $sformatf("waiting for INTB to deassert"), NNC_LOW)
    if(`DUT_IF.int_active_level_high_or_low == 1) 
      wait(`SOC_TB.INT[0] === 0);
    else 
      wait(`SOC_TB.INT[0] === 1);
    `nnc_info("INT", $sformatf("Finish deassert"), NNC_LOW)
    
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_TSC_INT_CTLR_REG; wr_data[0] == 8'h00;});//disable interrupt
    `nnc_info("SOC_TEST", $sformatf("will be writing intr en register with wr_data =%0h",top_test_cfg.wr_data[0]), NNC_LOW)
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    
    //check interrupt status reg
    exp_ana_intr_sts_val[sel_int] = 0;
    check_intr_sts_reg(exp_ana_intr_sts_val,sel_int);
    force   `ANA_WRAPPER_TOP.A2D_TSC_COMP_OUT_CH1_tmp = 0;
    release `ANA_WRAPPER_TOP.A2D_TSC_COMP_OUT_CH1_tmp;

  endtask: intr_tsc_check

  task intr_lvd_check();
    logic [7:0] rd_data = 0;
    logic [7:0] wr_data = 0;
    logic [7:0] exp_ana_intr_sts_val = 0;

    use_old_intr_reg_or_general_reg_to_clr =$random;
    
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_PMU_REG; wr_data[0] == 8'h40;});//enable interrupt
    `nnc_info("MULTI_PIN", ("MULTIL_INTB_PIN == 1"), NNC_LOW)
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    multi = top_test_cfg.wr_data[0];

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_LVD_INT_EN_REG; wr_data[0] == 8'h01;});//enable interrupt
    `nnc_info("SOC_TEST", $sformatf("will be writing intr en register with wr_data =%0h",top_test_cfg.wr_data[0]), NNC_LOW)
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    `nnc_info("SOC_TEST", $sformatf("%s intr enable",sel_int.name), NNC_LOW)

    check_intr(sel_int,multi);

    exp_ana_intr_sts_val[sel_int] = 1;
    check_intr_sts_reg(exp_ana_intr_sts_val,sel_int);
  
    clear_intr();
 
    `nnc_info("SOC_TEST", $sformatf("waiting for INTB to deassert"), NNC_LOW)
    if(`DUT_IF.int_active_level_high_or_low == 1) 
      wait(`SOC_TB.INT[2] === 0);
    else 
      wait(`SOC_TB.INT[2] === 1);
    `nnc_info("INT", $sformatf("Finish deassert"), NNC_LOW)
    
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_LVD_INT_EN_REG; wr_data[0] == 8'h00;});//disable interrupt
    `nnc_info("SOC_TEST", $sformatf("will be writing intr en register with wr_data =%0h",top_test_cfg.wr_data[0]), NNC_LOW)
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    
    //check interrupt status reg
    exp_ana_intr_sts_val[sel_int] = 0;
    check_intr_sts_reg(exp_ana_intr_sts_val,sel_int);
    `DUT_IF.vbat_level = 7;

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_PMU_REG; wr_data[0] == 8'h00;});//enable interrupt
    `nnc_info("MULTI_PIN", ("MULTIL_INTB_PIN == 0"), NNC_LOW)
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    multi = top_test_cfg.wr_data[0];

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_LVD_INT_EN_REG; wr_data[0] == 8'h01;});//enable interrupt
    `nnc_info("SOC_TEST", $sformatf("will be writing intr en register with wr_data =%0h",top_test_cfg.wr_data[0]), NNC_LOW)
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    `nnc_info("SOC_TEST", $sformatf("%s intr enable",sel_int.name), NNC_LOW)

    check_intr(sel_int,multi);

    exp_ana_intr_sts_val[sel_int] = 1;
    check_intr_sts_reg(exp_ana_intr_sts_val,sel_int);
    
    clear_intr();
    
    `nnc_info("SOC_TEST", $sformatf("waiting for INTB to deassert"), NNC_LOW)
    if(`DUT_IF.int_active_level_high_or_low == 1) 
      wait(`SOC_TB.INT[0] === 0);
    else 
      wait(`SOC_TB.INT[0] === 1);
    `nnc_info("INT", $sformatf("Finish deassert"), NNC_LOW)
    
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_LVD_INT_EN_REG; wr_data[0] == 8'h00;});//disable interrupt
    `nnc_info("SOC_TEST", $sformatf("will be writing intr en register with wr_data =%0h",top_test_cfg.wr_data[0]), NNC_LOW)
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    
    //check interrupt status reg
    exp_ana_intr_sts_val[sel_int] = 0;
    check_intr_sts_reg(exp_ana_intr_sts_val,sel_int);
    `DUT_IF.vbat_level = 7;

  endtask: intr_lvd_check

  task check_intr(input int sel_int,logic [7:0] multi);
    logic[7:0] rd_data;
    
    begin // LVD_INT
      `nnc_info("SOC_TEST", $sformatf("FORCE the A2D signals to 1 , and check status registers"), NNC_LOW)
      fork
        begin
          force_selected_intr(sel_int,1);
        end
        begin 
            if(sel_int == INT_LVD)
                begin
                `nnc_info("CHECK INTR 0", $sformatf("Waiting for INTB to assert, Multi = %h", multi), NNC_LOW)
                if(multi == 8'h40)
                    begin
                        if(`DUT_IF.int_active_level_high_or_low == 1)
                            begin 
                            wait(`SOC_TB.INT[2] === 1);
                            `nnc_info("INT", $sformatf("Interrupt is high"), NNC_LOW)
                            end
                        else 
                            begin 
                            wait(`SOC_TB.INT[2] === 0);
                            `nnc_info("INT", $sformatf("Interrupt is low"), NNC_LOW)
                            end
                    end     
                else         
                    begin
                        if(`DUT_IF.int_active_level_high_or_low == 1)
                            begin 
                            wait(`SOC_TB.INT[0] === 1 || `SOC_TB.INTB === 1);
                            `nnc_info("INT", $sformatf("Interrupt is high"), NNC_LOW)
                            end
                        else 
                            begin 
                            wait(`SOC_TB.INT[0] === 0 || `SOC_TB.INTB === 0);
                            `nnc_info("INT", $sformatf("Interrupt is low"), NNC_LOW)
                            end
                    end     
                `nnc_info("CHECK INTR 0", $sformatf("INTB asserted"), NNC_LOW)
                end
            else if(sel_int == INT_TSC)
                begin
                `nnc_info("CHECK INTR 1", $sformatf("Waiting for INTB to assert, Multi = %h", multi), NNC_LOW)
                if(multi == 8'h40)
                    begin
                        if(`DUT_IF.int_active_level_high_or_low == 1)
                            begin 
                            wait(`SOC_TB.INT[2] === 1);
                            `nnc_info("INT", $sformatf("Interrupt is high"), NNC_LOW)
                            end
                        else 
                            begin 
                            wait(`SOC_TB.INT[2] === 0);
                            `nnc_info("INT", $sformatf("Interrupt is low"), NNC_LOW)
                            end
                    end     
                else         
                    begin
                        if(`DUT_IF.int_active_level_high_or_low == 1)
                            begin 
                            wait(`SOC_TB.INT[0] === 1 || `SOC_TB.INTB === 1);
                            `nnc_info("INT", $sformatf("Interrupt is high"), NNC_LOW)
                            end
                        else 
                            begin 
                            wait(`SOC_TB.INT[0] === 0 || `SOC_TB.INTB === 0);
                            `nnc_info("INT", $sformatf("Interrupt is low"), NNC_LOW)
                            end
                    end     
                `nnc_info("CHECK INTR 1", $sformatf("INTB asserted"), NNC_LOW)
                end
            else if(sel_int == INT_STIM)
                begin
                `nnc_info("CHECK INTR 2", $sformatf("waiting for INTB assert"), NNC_LOW)
                if(multi == 8'h40)
                    begin
                        if(`DUT_IF.int_active_level_high_or_low == 1)
                            begin 
                            wait(`SOC_TB.INT[2] === 1);
                            `nnc_info("INT", $sformatf("Interrupt is high"), NNC_LOW)
                            end
                        else 
                            begin 
                            wait(`SOC_TB.INT[2] === 0);
                            `nnc_info("INT", $sformatf("Interrupt is low"), NNC_LOW)
                            end
                    end     
                else         
                    begin
                        if(`DUT_IF.int_active_level_high_or_low == 1)
                            begin 
                            wait(`SOC_TB.INT[0] === 1 || `SOC_TB.INTB === 1);
                            `nnc_info("INT", $sformatf("Interrupt is high"), NNC_LOW)
                            end
                        else 
                            begin 
                            wait(`SOC_TB.INT[0] === 0 || `SOC_TB.INTB === 0);
                            `nnc_info("INT", $sformatf("Interrupt is low"), NNC_LOW)
                            end
                    end     
                `nnc_info("CHECK INTR 2", $sformatf("INTB asserted"), NNC_LOW)
                end
        end
      join
    end
  endtask : check_intr

  task force_selected_intr(input int sel_int,bit force_val);
    bit [7:0] rd_data;
    `nnc_info("SOC_TEST", $sformatf("inside force_selected_intr, sel_int=%d, force_val=%0d",sel_int,force_val), NNC_LOW)

    if(sel_int == INT_TSC) 
        begin
           force `ANA_WRAPPER_TOP.A2D_TSC_COMP_OUT_CH1_tmp = 1;
        end
    else if(sel_int == INT_STIM) 
        begin
            force `ZMEAS_TOP.one_cycle_data_vld = 1;
            force `ZMEAS_TOP.A2D_ADC_DATA_VLD = 1;
            force `ZMEAS_TOP.A2D_ADC_DELTA_DATA_VLD = 1;
            force `ZMEAS_TOP.leadoff_pulse_pair = 1;
            force `ZMEAS_TOP.short_pulse_pair = 1;
        end
    else if(sel_int == INT_LVD)
        begin
            if(force_val==1) `DUT_IF.vbat_level = $urandom_range(0,`DUT_IF.lvd_sel-1); // when vbat < threshold(lvd_sel),  A2D_LVD =1
            if(force_val==0) `DUT_IF.vbat_level = $urandom_range(`DUT_IF.lvd_sel,7); // when vbat >= threshold(lvd_sel), A2D_LVD = 0

            // check A2D_LVD status
            `RD_NORMAL_REG(`SOC_A2D_ANA_GEN_REG_0,top_test_cfg.pads, rd_data);
            if(rd_data[0] !== force_val) `uvm_error("SOC_TEST",$sformatf("A2D_LVD STS reg value is=%b ,Expected=%b", rd_data[0],force_val))
            else `nnc_info("SOC_TEST", $sformatf("A2D_LVD STS reg value is=%b ,Expected=%b", rd_data[0],force_val), NNC_LOW) 
        end
  endtask : force_selected_intr

  task check_intr_sts_reg(input bit[7:0] exp_ana_intr_sts_val,int sel_int);
    bit [7:0] rd_data;

    if(sel_int == INT_LVD)
        begin
            if(use_old_intr_reg_or_general_reg_to_clr == 0) begin // old intr status register
              `nnc_info("SOC_TEST", $sformatf("read old intr status register"), NNC_LOW)
              `RD_NORMAL_REG(`SOC_ANA_INT_LVD_STS_REG,top_test_cfg.pads, rd_data);
              if(rd_data[0] !== exp_ana_intr_sts_val[sel_int]) `uvm_error("SOC_TEST",$sformatf("ANA INTR STS register value is='h%0h ,Expected='h%0h", rd_data,exp_ana_intr_sts_val[sel_int]))
              else `nnc_info("SOC_TEST", $sformatf("ANA INTR STS register value is='h%0h ,Expected='h%0h", rd_data,exp_ana_intr_sts_val[sel_int]), NNC_LOW)
            end 
            else begin // new general intr sts reg
              `nnc_info("SOC_TEST", $sformatf("read new general intr status register"), NNC_LOW)
              `RD_NORMAL_REG(`SOC_GENERAL_INT_STS_1_REG,top_test_cfg.pads, rd_data); // ch0  and ch1 sts
              if(rd_data[0] !== exp_ana_intr_sts_val[sel_int]) `uvm_error("SOC_TEST",$sformatf("GENERAL INTR STS register value is='h%0h ,Expected='h%0h", rd_data,exp_ana_intr_sts_val[sel_int]))
              else `nnc_info("SOC_TEST", $sformatf("GENERAL INTR STS register value is='h%h ,Expected='h%h", rd_data,exp_ana_intr_sts_val[sel_int]), NNC_LOW)
            end
        end
    else if(sel_int == INT_TSC) 
        begin
            if(use_old_intr_reg_or_general_reg_to_clr == 0) begin // old intr status register
              `nnc_info("SOC_TEST", $sformatf("read old intr status register"), NNC_LOW)
              `RD_NORMAL_REG(`SOC_TSC_INT_STATUS_REG,top_test_cfg.pads, rd_data);
              if(rd_data[0] !== exp_ana_intr_sts_val[sel_int]) `uvm_error("SOC_TEST",$sformatf("TSC INTR STS register value is='h%0h ,Expected='h%0h", rd_data,exp_ana_intr_sts_val[sel_int]))
              else `nnc_info("SOC_TEST", $sformatf("TSC INTR STS register value is='h%0h ,Expected='h%0h", rd_data[0],exp_ana_intr_sts_val[sel_int]), NNC_LOW)
            end 
            else begin // new general intr sts reg
              `nnc_info("SOC_TEST", $sformatf("read new general intr status register"), NNC_LOW)
              `RD_NORMAL_REG(`SOC_GENERAL_INT_STS_1_REG,top_test_cfg.pads, rd_data); // ch0  and ch1 sts
              if(rd_data[7] !== exp_ana_intr_sts_val[sel_int]) `uvm_error("SOC_TEST",$sformatf("GENERAL INTR STS register value is='h%0h ,Expected='h%0h", rd_data,exp_ana_intr_sts_val[sel_int]))
              else `nnc_info("SOC_TEST", $sformatf("GENERAL INTR STS register value is='h%h ,Expected='h%h", rd_data[7],exp_ana_intr_sts_val[sel_int]), NNC_LOW)
            end
        end
    else if(sel_int == INT_STIM) 
        begin /*
          `nnc_info("SOC_TEST", $sformatf("read old intr status register"), NNC_LOW)
          `RD_NORMAL_REG(`SOC_TSC_INT_STATUS_REG,top_test_cfg.pads, rd_data);
          if(rd_data[0] !== exp_ana_intr_sts_val[sel_int]) `uvm_error("SOC_TEST",$sformatf("TSC INTR STS register value is='h%0h ,Expected='h%0h", rd_data,exp_ana_intr_sts_val[sel_int]))
          else `nnc_info("SOC_TEST", $sformatf("TSC INTR STS register value is='h%0h ,Expected='h%0h", rd_data[0],exp_ana_intr_sts_val[sel_int]), NNC_LOW)
        */
        end
  endtask : check_intr_sts_reg
 
  task clear_intr();
    logic [7:0] rd_data;

    if(sel_int == INT_STIM)
        begin
            if(!`DUT_IF.clear_intr_manual_or_auto)
                begin
                    `nnc_info("CLR", $sformatf("RW1C: %b",`DUT_IF.clear_intr_manual_or_auto), NNC_LOW) 
                    force `ZMEAS_TOP.one_cycle_data_vld = 0;
                    force `ZMEAS_TOP.A2D_ADC_DATA_VLD = 0;
                    force `ZMEAS_TOP.A2D_ADC_DELTA_DATA_VLD = 0;
                    force `ZMEAS_TOP.leadoff_pulse_pair = 0;
                    force `ZMEAS_TOP.short_pulse_pair = 0;
                    //Expected ANA_LVD_STS raise.
                    `RD_NORMAL_REG(`SOC_STIM_MON_INT, top_test_cfg.pads, rd_data);
                    
                    assert(top_test_cfg.randomize with {wr_data[0] == {stim_cycle_int_ctrl, stim_int_int_ctrl, stim_delta_int_ctrl, 2'b0, 3'b111};});     
                    `WR_NORMAL_REG(`SOC_STIM_MON_INT, top_test_cfg.wr_data[0], top_test_cfg.pads);
                    `RD_NORMAL_REG(`SOC_STIM_MON_LOFF_INT_STS0_L, top_test_cfg.pads, rd_data);
                    
                    assert(top_test_cfg.randomize with {wr_data[0] == 8'h01;});     
                    `WR_NORMAL_REG(`SOC_STIM_MON_LOFF_INT_STS0_L, top_test_cfg.wr_data[0], top_test_cfg.pads);
                    
                    `RD_NORMAL_REG(`SOC_STIM_MON_LOFF_INT_STS0_L, top_test_cfg.pads, rd_data);
                    
                    assert(top_test_cfg.randomize with {wr_data[0] == 8'h01;});     
                    `WR_NORMAL_REG(`SOC_STIM_MON_LOFF_INT_STS0_L, top_test_cfg.wr_data[0], top_test_cfg.pads);
                    
                    `RD_NORMAL_REG(`SOC_STIM_MON_LOFF_INT_STS0_H, top_test_cfg.pads, rd_data);
                    
                    assert(top_test_cfg.randomize with {wr_data[0] == 8'h01;});     
                    `WR_NORMAL_REG(`SOC_STIM_MON_LOFF_INT_STS0_H, top_test_cfg.wr_data[0], top_test_cfg.pads);
                    `RD_NORMAL_REG(`SOC_STIM_MON_SHORT_INT_STS0_L, top_test_cfg.pads, rd_data);
                    
                    assert(top_test_cfg.randomize with {wr_data[0] == 8'h01;});     
                    `WR_NORMAL_REG(`SOC_STIM_MON_SHORT_INT_STS0_L, top_test_cfg.wr_data[0], top_test_cfg.pads);
                    
                    `RD_NORMAL_REG(`SOC_STIM_MON_SHORT_INT_STS0_H, top_test_cfg.pads, rd_data);
                    
                    assert(top_test_cfg.randomize with {wr_data[0] == 8'h01;});     
                    `WR_NORMAL_REG(`SOC_STIM_MON_SHORT_INT_STS0_H, top_test_cfg.wr_data[0], top_test_cfg.pads);
                    
                    @(posedge `ZMEAS_TOP.sysclk);
                    @(posedge `ZMEAS_TOP.sysclk);
                    @(posedge `ZMEAS_TOP.sysclk);
                    @(posedge `ZMEAS_TOP.sysclk);
                    @(posedge `ZMEAS_TOP.sysclk);
                    @(posedge `ZMEAS_TOP.sysclk);
                    
                    `RD_NORMAL_REG(`SOC_STIM_MON_INT, top_test_cfg.pads, rd_data);
                    if(rd_data[0] !== 1'b0)
                        `nnc_error("STS", $sformatf("INT_STIM_STS don't fall, the value is %b",rd_data[0])) 
                    else 
                        `nnc_info("STS", $sformatf("INT_STIM_STS fall, the value is %b",rd_data[0]), NNC_LOW) 
                    
                    `RD_NORMAL_REG(`SOC_STIM_MON_LOFF_INT_STS0_L, top_test_cfg.pads, rd_data);
                    if(rd_data[0] !== 1'b0)
                        `nnc_error("STS", $sformatf("INT_STIM_STS don't fall, the value is %b",rd_data[0])) 
                    else 
                        `nnc_info("STS", $sformatf("INT_STIM_STS fall, the value is %b",rd_data[0]), NNC_LOW) 
                    
                    `RD_NORMAL_REG(`SOC_STIM_MON_LOFF_INT_STS0_H, top_test_cfg.pads, rd_data);
                    if(rd_data[0] !== 1'b0)
                        `nnc_error("STS", $sformatf("INT_STIM_STS don't fall, the value is %b",rd_data[0])) 
                    else 
                        `nnc_info("STS", $sformatf("INT_STIM_STS fall, the value is %b",rd_data[0]), NNC_LOW) 
                    
                    `RD_NORMAL_REG(`SOC_STIM_MON_SHORT_INT_STS0_L, top_test_cfg.pads, rd_data);
                    if(rd_data[0] !== 1'b0)
                        `nnc_error("STS", $sformatf("INT_STIM_STS don't fall, the value is %b",rd_data[0])) 
                    else 
                        `nnc_info("STS", $sformatf("INT_STIM_STS fall, the value is %b",rd_data[0]), NNC_LOW) 
                    
                    `RD_NORMAL_REG(`SOC_STIM_MON_SHORT_INT_STS0_H, top_test_cfg.pads, rd_data);

                    if(rd_data[0] !== 1'b0)
                        `nnc_error("STS", $sformatf("INT_STIM_STS don't fall, the value is %b",rd_data[0])) 
                    else 
                        `nnc_info("STS", $sformatf("INT_STIM_STS fall, the value is %b",rd_data[0]), NNC_LOW) 
                end
            else
                begin
                    `nnc_info("CLR", $sformatf("R1C: %b",`DUT_IF.clear_intr_manual_or_auto), NNC_LOW) 
                    force `ZMEAS_TOP.one_cycle_data_vld = 0;
                    force `ZMEAS_TOP.A2D_ADC_DATA_VLD = 0;
                    force `ZMEAS_TOP.A2D_ADC_DELTA_DATA_VLD = 0;
                    force `ZMEAS_TOP.leadoff_pulse_pair = 0;
                    force `ZMEAS_TOP.short_pulse_pair = 0;
                    //Expected ANA_LVD_STS raise.
                    `RD_NORMAL_REG(`SOC_STIM_MON_INT, top_test_cfg.pads, rd_data);
                    `RD_NORMAL_REG(`SOC_STIM_MON_SHORT_INT_STS0_L, top_test_cfg.pads, rd_data);
                    `RD_NORMAL_REG(`SOC_STIM_MON_SHORT_INT_STS0_H, top_test_cfg.pads, rd_data);
                    `RD_NORMAL_REG(`SOC_STIM_MON_LOFF_INT_STS0_L, top_test_cfg.pads, rd_data);
                    `RD_NORMAL_REG(`SOC_STIM_MON_LOFF_INT_STS0_H, top_test_cfg.pads, rd_data);
                    
                    @(posedge `ZMEAS_TOP.sysclk);
                    @(posedge `ZMEAS_TOP.sysclk);
                    @(posedge `ZMEAS_TOP.sysclk);
                    @(posedge `ZMEAS_TOP.sysclk);
                    @(posedge `ZMEAS_TOP.sysclk);
                    @(posedge `ZMEAS_TOP.sysclk);
                    
                    `RD_NORMAL_REG(`SOC_STIM_MON_INT, top_test_cfg.pads, rd_data);

                    if(rd_data[0] !== 1'b0)
                        `nnc_error("STS", $sformatf("INT_STIM_STS don't fall, the value is %b",rd_data[0])) 
                    else 
                        `nnc_info("STS", $sformatf("INT_STIM_STS fall, the value is %b",rd_data[0]), NNC_LOW) 
                    
                    `RD_NORMAL_REG(`SOC_STIM_MON_LOFF_INT_STS0_L, top_test_cfg.pads, rd_data);

                    if(rd_data[0] !== 1'b0)
                        `nnc_error("STS", $sformatf("INT_STIM_STS don't fall, the value is %b",rd_data[0])) 
                    else 
                        `nnc_info("STS", $sformatf("INT_STIM_STS fall, the value is %b",rd_data[0]), NNC_LOW) 
                    
                    `RD_NORMAL_REG(`SOC_STIM_MON_LOFF_INT_STS0_H, top_test_cfg.pads, rd_data);
                    if(rd_data[0] !== 1'b0)
                        `nnc_error("STS", $sformatf("INT_STIM_STS don't fall, the value is %b",rd_data[0])) 
                    else 
                        `nnc_info("STS", $sformatf("INT_STIM_STS fall, the value is %b",rd_data[0]), NNC_LOW) 
                    
                    `RD_NORMAL_REG(`SOC_STIM_MON_SHORT_INT_STS0_L, top_test_cfg.pads, rd_data);
                    if(rd_data[0] !== 1'b0)
                        `nnc_error("STS", $sformatf("INT_STIM_STS don't fall, the value is %b",rd_data[0])) 
                    else 
                        `nnc_info("STS", $sformatf("INT_STIM_STS fall, the value is %b",rd_data[0]), NNC_LOW) 
                    
                    `RD_NORMAL_REG(`SOC_STIM_MON_SHORT_INT_STS0_H, top_test_cfg.pads, rd_data);
                    if(rd_data[0] !== 1'b0)
                        `nnc_error("STS", $sformatf("INT_STIM_STS don't fall, the value is %b",rd_data[0])) 
                    else 
                        `nnc_info("STS", $sformatf("INT_STIM_STS fall, the value is %b",rd_data[0]), NNC_LOW) 
                end
        end
    else if(sel_int == INT_TSC)
        begin
            if(!`DUT_IF.clear_intr_manual_or_auto)
                begin
                    `nnc_info("CLR", $sformatf("RW1C: %b",`DUT_IF.clear_intr_manual_or_auto), NNC_LOW) 
                    //Expected ANA_LVD_STS raise.
                    `RD_NORMAL_REG(`SOC_TSC_INT_STATUS_REG, top_test_cfg.pads, rd_data);
                    
                    assert(top_test_cfg.randomize with {wr_data[0] == 8'h01;});     
                    `WR_NORMAL_REG(`SOC_TSC_INT_STATUS_REG, top_test_cfg.wr_data[0], top_test_cfg.pads);
                    
                    @(posedge `TSC_TOP.sysclk);
                    @(posedge `TSC_TOP.sysclk);
                    @(posedge `TSC_TOP.sysclk);
                    @(posedge `TSC_TOP.sysclk);
                    @(posedge `TSC_TOP.sysclk);
                    @(posedge `TSC_TOP.sysclk);

                    `RD_NORMAL_REG(`SOC_TSC_INT_STATUS_REG, top_test_cfg.pads, rd_data);
                    //Expected ANA_LVD_STS raise with 2 conditions enable
                    if(multi == 8'h40)
                        begin
                            if(`DUT_IF.int_active_level_high_or_low == 1)
                                begin 
                                wait(`SOC_TB.INT[2] === 0);
                                `nnc_info("INT", $sformatf("Interrupt is high"), NNC_LOW)
                                end
                            else 
                                begin 
                                wait(`SOC_TB.INT[2] === 1);
                                `nnc_info("INT", $sformatf("Interrupt is low"), NNC_LOW)
                                end
                        end     
                    else         
                        begin
                            if(`DUT_IF.int_active_level_high_or_low == 1)
                                begin 
                                wait(`SOC_TB.INT[0] === 0 || `SOC_TB.INTB === 0);
                                `nnc_info("INT", $sformatf("Interrupt is high"), NNC_LOW)
                                end
                            else 
                                begin 
                                wait(`SOC_TB.INT[0] === 1 || `SOC_TB.INTB === 1);
                                `nnc_info("INT", $sformatf("Interrupt is low"), NNC_LOW)
                                end
                        end     
                    
                    assert(top_test_cfg.randomize with {wr_data[0] == 8'h80;});     
                    `WR_NORMAL_REG(`SOC_GENERAL_INT_STS_1_REG, top_test_cfg.wr_data[0], top_test_cfg.pads);
   
                    @(posedge `TSC_TOP.sysclk);
                    @(posedge `TSC_TOP.sysclk);
                    @(posedge `TSC_TOP.sysclk);
                    @(posedge `TSC_TOP.sysclk);
                    @(posedge `TSC_TOP.sysclk);
                    @(posedge `TSC_TOP.sysclk);
 
                    `RD_NORMAL_REG(`SOC_GENERAL_INT_STS_1_REG, top_test_cfg.pads, rd_data);

                    //Expected ANA_LVD_STS raise with 2 conditions enable
                    if(rd_data[0] !== 1'b0)
                        `nnc_error("STS", $sformatf("GENERAL_INT_CTRL_TSC don't fall, the value is %b",rd_data[0])) 
                    else 
                        `nnc_info("STS", "GENERAL_INT_CTRL_TSC fall", NNC_LOW) 
                end
            else
                begin
                    `nnc_info("CLR", $sformatf("R1C: %b",`DUT_IF.clear_intr_manual_or_auto), NNC_LOW) 
                     
                    //Expected ANA_LVD_STS raise.
                    `RD_NORMAL_REG(`SOC_TSC_INT_STATUS_REG, top_test_cfg.pads, rd_data);
                    `nnc_info("Testing", $sformatf("Should have hang"), NNC_LOW)
                    
                    @(posedge `TSC_TOP.sysclk);
                    @(posedge `TSC_TOP.sysclk);
                    @(posedge `TSC_TOP.sysclk);
                    @(posedge `TSC_TOP.sysclk);
                    @(posedge `TSC_TOP.sysclk);
                    @(posedge `TSC_TOP.sysclk);
                    if(`DUT_IF.int_active_level_high_or_low == 1) 
                      wait(`SOC_TB.INT[0] === 0);
                    else 
                      wait(`SOC_TB.INT[0] === 1);
                    
                    `RD_NORMAL_REG(`SOC_TSC_INT_STATUS_REG, top_test_cfg.pads, rd_data);

                    //Expected ANA_LVD_STS raise with 2 conditions enable
                    if(rd_data[0] !== 1'b0)
                        `nnc_error("STS", $sformatf("INT_LVD_TSC don't fall, the value is %b",rd_data[0])) 
                    else 
                        `nnc_info("STS", $sformatf("INT_LVD_TSC fall, the value is %b",rd_data[0]), NNC_LOW) 
    
                    `RD_NORMAL_REG(`SOC_GENERAL_INT_STS_1_REG, top_test_cfg.pads, rd_data);
                    
                    @(posedge `TSC_TOP.sysclk);
                    @(posedge `TSC_TOP.sysclk);
                    @(posedge `TSC_TOP.sysclk);
                    @(posedge `TSC_TOP.sysclk);
                    @(posedge `TSC_TOP.sysclk);
                    @(posedge `TSC_TOP.sysclk);
                    
                    `RD_NORMAL_REG(`SOC_GENERAL_INT_STS_1_REG, top_test_cfg.pads, rd_data);

                    //Expected ANA_LVD_STS raise with 2 conditions enable
                    if(rd_data[0] !== 1'b0)
                        `nnc_error("STS", $sformatf("GENERAL_INT_CTRL_LVD don't fall, the value is %b",rd_data[0])) 
                    else 
                        `nnc_info("STS", "GENERAL_INT_CTRL_LVD fall", NNC_LOW) 
                end
        end
    else if(sel_int == INT_LVD)
        `DUT_IF.vbat_level = 7;
  endtask

  task check_connectivity();
    top_test_cfg.wr_data[0] = {5'b0,`DUT_IF.int_active_level_high_or_low,`DUT_IF.clear_intr_manual_or_auto,`DUT_IF.intr_length_slct_level_or_pulse};
    `WR_NORMAL_REG(`SOC_GENERAL_INT_CTRL_REG, top_test_cfg.wr_data[0], top_test_cfg.pads);
    
    //CHECKING WAVEGEN
    force `WG_DRIVER_CORE.w_interrupt = 16'b0000_0000_0000_0001;
    #100
    wait(`SOC_TB.INT[1] === 1);
    
    release `WG_DRIVER_CORE.w_interrupt; 
    #100
    wait(`SOC_TB.INT[1] === 0);
    
    force `WG_DRIVER_CORE.w_interrupt = 16'b0000_0000_0000_0010;
    #100
    wait(`SOC_TB.INT[1] === 1);
    
    release `WG_DRIVER_CORE.w_interrupt; 
    #100
    wait(`SOC_TB.INT[1] === 0);
    
    force `WG_DRIVER_CORE.w_interrupt = 16'b0000_0000_0000_0100;
    #100
    wait(`SOC_TB.INT[1] === 1);
    
    release `WG_DRIVER_CORE.w_interrupt; 
    #100
    wait(`SOC_TB.INT[1] === 0);
    
    force `WG_DRIVER_CORE.w_interrupt = 16'b0000_0000_0000_1000;
    #100
    wait(`SOC_TB.INT[1] === 1);
    
    release `WG_DRIVER_CORE.w_interrupt; 
    #100
    wait(`SOC_TB.INT[1] === 0);
    
    force `WG_DRIVER_CORE.w_interrupt = 16'b0000_0000_0001_0000;
    #100
    wait(`SOC_TB.INT[1] === 1);
    
    release `WG_DRIVER_CORE.w_interrupt; 
    #100
    wait(`SOC_TB.INT[1] === 0);
    
    force `WG_DRIVER_CORE.w_interrupt = 16'b0000_0000_0010_0000;
    #100
    wait(`SOC_TB.INT[1] === 1);
    
    release `WG_DRIVER_CORE.w_interrupt; 
    #100
    wait(`SOC_TB.INT[1] === 0);
    
    force `WG_DRIVER_CORE.w_interrupt = 16'b0000_0000_0100_0000;
    #100
    wait(`SOC_TB.INT[1] === 1);
    
    release `WG_DRIVER_CORE.w_interrupt; 
    #100
    wait(`SOC_TB.INT[1] === 0);
    
    force `WG_DRIVER_CORE.w_interrupt = 16'b0000_0000_1000_0000;
    #100
    wait(`SOC_TB.INT[1] === 1);
    
    release `WG_DRIVER_CORE.w_interrupt; 
    #100
    wait(`SOC_TB.INT[1] === 0);
    
    force `WG_DRIVER_CORE.w_interrupt = 16'b0000_0001_0000_0000;
    #100
    wait(`SOC_TB.INT[1] === 1);
    
    release `WG_DRIVER_CORE.w_interrupt; 
    #100
    wait(`SOC_TB.INT[1] === 0);
    
    force `WG_DRIVER_CORE.w_interrupt = 16'b0000_0010_0000_0000;
    #100
    wait(`SOC_TB.INT[1] === 1);
    
    release `WG_DRIVER_CORE.w_interrupt; 
    #100
    wait(`SOC_TB.INT[1] === 0);
    
    force `WG_DRIVER_CORE.w_interrupt = 16'b0000_0100_0000_0000;
    #100
    wait(`SOC_TB.INT[1] === 1);
    
    release `WG_DRIVER_CORE.w_interrupt; 
    #100
    wait(`SOC_TB.INT[1] === 0);
    
    force `WG_DRIVER_CORE.w_interrupt = 16'b0000_1000_0000_0000;
    #100
    wait(`SOC_TB.INT[1] === 1);
    
    release `WG_DRIVER_CORE.w_interrupt; 
    #100
    wait(`SOC_TB.INT[1] === 0);
    
    force `WG_DRIVER_CORE.w_interrupt = 16'b0001_0000_0000_0000;
    #100
    wait(`SOC_TB.INT[1] === 1);
    
    release `WG_DRIVER_CORE.w_interrupt; 
    #100
    wait(`SOC_TB.INT[1] === 0);
    
    force `WG_DRIVER_CORE.w_interrupt = 16'b0010_0000_0000_0000;
    #100
    wait(`SOC_TB.INT[1] === 1);
    
    release `WG_DRIVER_CORE.w_interrupt; 
    #100
    wait(`SOC_TB.INT[1] === 0);
    
    force `WG_DRIVER_CORE.w_interrupt = 16'b0100_0000_0000_0000;
    #100
    wait(`SOC_TB.INT[1] === 1);
    
    release `WG_DRIVER_CORE.w_interrupt; 
    #100
    wait(`SOC_TB.INT[1] === 0);
    
    force `WG_DRIVER_CORE.w_interrupt = 16'b1000_0000_0000_0000;
    #100
    wait(`SOC_TB.INT[1] === 1);
    
    release `WG_DRIVER_CORE.w_interrupt; 
    #100    
    wait(`SOC_TB.INT[1] === 0);
    
    force `NIRS_PPG_TOP.INT_IO_tmp = 8'b0000_0000_0000_0001;
    #100
    wait(`SOC_TB.INT[3] === 1);
    
    release `NIRS_PPG_TOP.INT_IO_tmp; 
    #100
    wait(`SOC_TB.INT[3] === 0);
    
    force `NIRS_PPG_TOP.INT_IO_tmp = 8'b0000_0000_0000_0010;
    #100
    wait(`SOC_TB.INT[3] === 1);
    
    release `NIRS_PPG_TOP.INT_IO_tmp; 
    #100
    wait(`SOC_TB.INT[3] === 0);
    
    force `NIRS_PPG_TOP.INT_IO_tmp = 8'b0000_0000_0000_0100;
    #100
    wait(`SOC_TB.INT[3] === 1);
    
    release `NIRS_PPG_TOP.INT_IO_tmp; 
    #100
    wait(`SOC_TB.INT[3] === 0);
    
    force `NIRS_PPG_TOP.INT_IO_tmp = 8'b0000_0000_0000_1000;
    #100
    wait(`SOC_TB.INT[3] === 1);
    
    release `NIRS_PPG_TOP.INT_IO_tmp; 
    #100
    wait(`SOC_TB.INT[3] === 0);
    
    force `NIRS_PPG_TOP.INT_IO_tmp = 8'b0000_0000_0001_0000;
    #100
    wait(`SOC_TB.INT[3] === 1);
    
    release `NIRS_PPG_TOP.INT_IO_tmp; 
    #100
    wait(`SOC_TB.INT[3] === 0);
    
    force `NIRS_PPG_TOP.INT_IO_tmp = 8'b0000_0000_0010_0000;
    #100
    wait(`SOC_TB.INT[3] === 1);
    
    release `NIRS_PPG_TOP.INT_IO_tmp; 
    #100
    wait(`SOC_TB.INT[3] === 0);
    
    force `NIRS_PPG_TOP.INT_IO_tmp = 8'b0000_0000_0100_0000;
    #100
    wait(`SOC_TB.INT[3] === 1);
    
    release `NIRS_PPG_TOP.INT_IO_tmp; 
    #100
    wait(`SOC_TB.INT[3] === 0);
    
    force `NIRS_PPG_TOP.INT_IO_tmp = 8'b0000_0000_1000_0000;
    #100
    wait(`SOC_TB.INT[3] === 1);

    force `NIRS_PPG_TOP.INT_IO_tmp = 8'b0000_0000_0000_0000;
    release `NIRS_PPG_TOP.INT_IO_tmp; 
    #100
    wait(`SOC_TB.INT[3] === 0);

    force `SPI_REG.adc_en = 1; 
    force `IMEAS_WRAPPER_TOP.o_eeg_int = 1; 
    #100
    wait(`SOC_TB.INT[0] === 1);

    force `IMEAS_WRAPPER_TOP.o_eeg_int = 0; 
    release `IMEAS_WRAPPER_TOP.o_eeg_int; 
    #100
    wait(`SOC_TB.INT[0] === 0);

    force `ZMEAS_TOP.stim_mon_int_sts = 1;
    force `ZMEAS_TOP.stim_mon_int_topin_en[1] = 1;
    #100
    wait(`SOC_TB.INT[2] === 1);

    force `ZMEAS_TOP.stim_mon_int_sts = 0;
    release `ZMEAS_TOP.stim_mon_int_sts; 
    release `ZMEAS_TOP.stim_mon_int_topin_en[1];
    #100
    wait(`SOC_TB.INT[2] === 0);

    force `ZMEAS_TOP.stim_mon_delta_int_sts = 1;
    force `ZMEAS_TOP.stim_mon_int_topin_en[0] = 1;
    #100
    wait(`SOC_TB.INT[2] === 1);

    force `ZMEAS_TOP.stim_mon_delta_int_sts = 0;
    release `ZMEAS_TOP.stim_mon_delta_int_sts; 
    release `ZMEAS_TOP.stim_mon_int_topin_en[0];
    #100
    wait(`SOC_TB.INT[2] === 0);

    force `ZMEAS_TOP.stim_mon_cycle_int_sts = 1;
    force `ZMEAS_TOP.stim_mon_int_topin_en[2] = 1;
    #100
    wait(`SOC_TB.INT[2] === 1);

    force `ZMEAS_TOP.stim_mon_cycle_int_sts = 0;
    release `ZMEAS_TOP.stim_mon_cycle_int_sts; 
    release `ZMEAS_TOP.stim_mon_int_topin_en[2];
    #100
    wait(`SOC_TB.INT[2] === 0);

    force `ZMEAS_TOP.stim_mon_leadoff_all_int_sts = 1;
    force `ZMEAS_TOP.stim_mon_int_topin_en[3] = 1;
    #100
    wait(`SOC_TB.INT[2] === 1);

    force `ZMEAS_TOP.stim_mon_leadoff_all_int_sts = 0;
    release `ZMEAS_TOP.stim_mon_leadoff_all_int_sts; 
    release `ZMEAS_TOP.stim_mon_int_topin_en[3];
    #100
    wait(`SOC_TB.INT[2] === 0);
        
    force `ZMEAS_TOP.stim_mon_short_all_int_sts = 1;
    force `ZMEAS_TOP.stim_mon_int_topin_en[4] = 1;
    #100
    wait(`SOC_TB.INT[2] === 1);

    force `ZMEAS_TOP.stim_mon_short_all_int_sts = 0;
    release `ZMEAS_TOP.stim_mon_short_all_int_sts; 
    release `ZMEAS_TOP.stim_mon_int_topin_en[4];
    #100
    wait(`SOC_TB.INT[2] === 0);
  endtask:check_connectivity

endclass : `TESTNAME
