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

  rand logic [7:0] wr_data[256];
  rand int         no_of_bytes; 
  rand logic [7:0] reg_addr;
  rand logic [7:0] pads;
  rand logic [7:0] mask;
  rand logic [7:0] expected_data;
       logic [7:0] rd_data[];
  rand logic        int_active_level_high_or_low;
  rand logic        clear_intr_manual_or_auto;
  rand logic        intr_length_slct_level_or_pulse;
  rand logic [2:0]  lvd_sel;
  rand logic        lvd_en;
       integer      cnt;
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

  //constraint c_int_active_level_low_or_high  { int_active_level_high_or_low == 0; } // 1: intr active high, 0 : intr active low 

  //constraint c_clear_intr_manual_or_auto  { clear_intr_manual_or_auto == 1; } // 0: manually clear intr by w1c, 1 : auto clear intr by r1c 

  //constraint c_intr_length_slct_pulse_or_level  { intr_length_slct_level_or_pulse == 0; } // 0: level INT, 1: pulse INT

  constraint c_lvd_en  { lvd_en == 1; } 

  constraint c_lvd_sel                  { lvd_sel != 0; } 

  constraint c_vbat_level                  { solve lvd_sel before vbat_level; vbat_level >= lvd_sel; } 

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

  typedef enum {LVD_INT=0} selected_intr ;
  selected_intr sel_int;
  bit use_old_intr_reg_or_general_reg_to_clr;

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
    `nnc_top.set_timeout(10s);
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

    check_ana_lvd_connectivity();

    top_test_cfg.wr_data[0] = {5'b0,`DUT_IF.int_active_level_high_or_low,`DUT_IF.clear_intr_manual_or_auto,`DUT_IF.intr_length_slct_level_or_pulse};
    `WR_NORMAL_REG(`SOC_GENERAL_INT_CTRL_REG, top_test_cfg.wr_data[0], top_test_cfg.pads);
    #10000ns;

    // check INTB RESET value
    if(`DUT_IF.int_active_level_high_or_low === 0) begin
	if(`SOC_TB.INTB !== 1)
	  `nnc_error("SOC_TEST", "Error! RESET VALUE INTB not active low as expected!!")
	else
	  `nnc_info("SOC_TEST", "Active low INTB selected!", NNC_LOW)
    end
    else begin
	if(`SOC_TB.INTB !== 0)
	  `nnc_error("SOC_TEST", "Error! RESET VALUE INTB not active high as expected!!")
	else
	   `nnc_info("SOC_TEST", "Active high INTB selected!", NNC_LOW)
    end

    #10000ns;
    top_test_cfg.cnt = 0;
    while(top_test_cfg.cnt < 3) begin
      `nnc_info("SOC_TEST", $sformatf("inside repeat loop for LVD intr check = %0d",top_test_cfg.cnt), NNC_LOW)
      top_test_cfg.cnt++;
      sel_int = LVD_INT;
      a2d_lvd_int_check();
    end
    top_test_cfg.cnt = 0;
    while(top_test_cfg.cnt < 3) begin
      `nnc_info("SOC_TEST", $sformatf("inside repeat loop for back to back diff intr check = %0d",top_test_cfg.cnt), NNC_LOW)
      top_test_cfg.cnt++;
      sel_int = LVD_INT;
      a2d_lvd_int_check();
    end

    phase.drop_objection(this);
  endtask: main_phase

  // ------------------------------
  // Declare the report_phase task
  // ------------------------------
  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction

  task a2d_lvd_int_check();
    logic [7:0] rd_data = 0;
    logic [7:0] wr_data = 0;
    logic [7:0] exp_ana_intr_sts_val = 0;
    logic [7:0] multi; //intr will generate when it detects (0: posedge , 1 :negedge) of ana_comp signal

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

  endtask

  task check_intr(input int sel_int,logic [7:0] multi);
    begin // LVD_INT
      `nnc_info("SOC_TEST", $sformatf("FORCE the A2D signals to 1 , and check status registers"), NNC_LOW)
      fork
        begin
          force_selected_intr(sel_int,1);
        end
        begin
            `nnc_info("SOC_TEST", $sformatf("waiting for INTB assert"), NNC_LOW)
            if(multi == 8'h40)
                begin
                    if(`DUT_IF.int_active_level_high_or_low == 1)
                        begin 
                        wait(`SOC_TB.INT[2] === 1);
                        `nnc_info("INT", $sformatf("Interrupt is on"), NNC_LOW)
                        end
                    else 
                        begin 
                        wait(`SOC_TB.INT[2] === 0);
                        `nnc_info("INT", $sformatf("Interrupt is on"), NNC_LOW)
                        end
                end     
            else         
                begin
                    if(`DUT_IF.int_active_level_high_or_low == 1)
                        begin 
                        wait(`SOC_TB.INT[0] === 1);
                        `nnc_info("INT", $sformatf("Interrupt is on"), NNC_LOW)
                        end
                    else 
                        begin 
                        wait(`SOC_TB.INT[0] === 0);
                        `nnc_info("INT", $sformatf("Interrupt is on"), NNC_LOW)
                        end
                end     
            `nnc_info("SOC_TEST", $sformatf("INTB asserted"), NNC_LOW)
        end
      join
    end
  endtask : check_intr

  task force_selected_intr(input int sel_int,bit force_val);
    bit [7:0] rd_data;
    `nnc_info("SOC_TEST", $sformatf("inside force_selected_intr, sel_int=%d, force_val=%0d",sel_int,force_val), NNC_LOW)

    if(sel_int == LVD_INT)begin
      //if(force_val==1) force `ANA_TOP.A2D_LVD = 1;
      //if(force_val==0) force `ANA_TOP.A2D_LVD = 0;
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

    // turn off SPI VIP specific register checker as manually checking below - this is w1c reg
    //`SPI_STATUS_REG_CHECK_EN = 0;

    if(use_old_intr_reg_or_general_reg_to_clr == 0) begin // old intr status register
      `nnc_info("SOC_TEST", $sformatf("read old intr status register"), NNC_LOW)
      `RD_NORMAL_REG(`SOC_ANA_INT_LVD_STS_REG,top_test_cfg.pads, rd_data);
      if(rd_data !== exp_ana_intr_sts_val) `uvm_error("SOC_TEST",$sformatf("ANA INTR STS register value is='h%0h ,Expected='h%0h", rd_data,exp_ana_intr_sts_val))
      else `nnc_info("SOC_TEST", $sformatf("ANA INTR STS register value is='h%0h ,Expected='h%0h", rd_data,exp_ana_intr_sts_val), NNC_LOW)
      //repeat(3)@(posedge `DUT_IF.sys_clk); // atleast 3 pclk between 2 SPI read cmd required by design as per Zhen
      //while(rd_data != exp_ana_intr_sts_val)begin
      //  repeat(3)@(posedge `DUT_IF.sys_clk); // atleast 3 pclk between 2 SPI read cmd required by design as per Zhen
      //  `RD_NORMAL_REG(`SOC_ANA_INT_COMP_STS_REG,top_test_cfg.pads, rd_data);
      //end
      //`nnc_info("SOC_TEST", $sformatf("ANA INTR STS MATCHED register value is='h%0h ,Expected='h%0h", rd_data,exp_ana_intr_sts_val), NNC_LOW)
    end 
    else begin // new general intr sts reg
      `nnc_info("SOC_TEST", $sformatf("read new general intr status register"), NNC_LOW)
      `RD_NORMAL_REG(`SOC_GENERAL_INT_STS_1_REG,top_test_cfg.pads, rd_data); // ch0  and ch1 sts
      if(rd_data !== exp_ana_intr_sts_val) `uvm_error("SOC_TEST",$sformatf("GENERAL INTR STS register value is='h%0h ,Expected='h%0h", rd_data,exp_ana_intr_sts_val))
      else `nnc_info("SOC_TEST", $sformatf("GENERAL INTR STS register value is='h%h ,Expected='h%h", rd_data,exp_ana_intr_sts_val), NNC_LOW)
      //repeat(3)@(posedge `DUT_IF.sys_clk); // atleast 3 pclk between 2 SPI read cmd required by design as per Zhen
      //while(rd_data != exp_ana_intr_sts_val)begin
      //  repeat(3)@(posedge `DUT_IF.sys_clk);// atleast 3 pclk between 2 SPI read cmd required by design as per Zhen
      //  `RD_NORMAL_REG(`SOC_GENERAL_INT_STS_1_REG,top_test_cfg.pads, rd_data); // ch0  and ch1 sts
      //end
      //`nnc_info("SOC_TEST", $sformatf("GENERAL INTR STS MATCHED register value is='h%0h ,Expected='h%0h", rd_data,exp_ana_intr_sts_val), NNC_LOW)
    end

    // turn on specific reg checker again
    //`SPI_STATUS_REG_CHECK_EN = 1;

  endtask : check_intr_sts_reg

endclass : `TESTNAME
