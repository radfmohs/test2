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

  typedef enum {LVD_INT=0,COMP_CH1=1,COMP_CH2=2} selected_intr ;
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
    top_test_cfg.wr_data[0] = `INIT_SOC_ANA_ENABLE_REG_0;
    top_test_cfg.wr_data[0][0] = `DUT_IF.lvd_en;
    `WR_NORMAL_REG(`SOC_ANA_ENABLE_REG_0, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // configure LVD_EN  
    top_test_cfg.wr_data[0] = {5'b0,`DUT_IF.lvd_sel};
    `WR_NORMAL_REG(`SOC_ANA_GEN_1_REG, top_test_cfg.wr_data[0], top_test_cfg.pads);

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
      `nnc_info("SOC_TEST", $sformatf("inside repeat loop for COMP_CH1 intr check = %0d",top_test_cfg.cnt), NNC_LOW)
      top_test_cfg.cnt++;
      sel_int = COMP_CH1;
      a2d_lvd_int_check();
    end
    top_test_cfg.cnt = 0;
    while(top_test_cfg.cnt < 3) begin
      `nnc_info("SOC_TEST", $sformatf("inside repeat loop for COMP_CH2 intr check = %0d",top_test_cfg.cnt), NNC_LOW)
      top_test_cfg.cnt++;
      sel_int = COMP_CH2;
      a2d_lvd_int_check();
    end
    top_test_cfg.cnt = 0;
    while(top_test_cfg.cnt < 3) begin
      `nnc_info("SOC_TEST", $sformatf("inside repeat loop for back to back diff intr check = %0d",top_test_cfg.cnt), NNC_LOW)
      top_test_cfg.cnt++;
      sel_int = LVD_INT;
      a2d_lvd_int_check();
      sel_int = COMP_CH1;
      a2d_lvd_int_check();
      sel_int = COMP_CH2;
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
    bit rand_edge_detection; //intr will generate when it detects (0: posedge , 1 :negedge) of ana_comp signal

    /*randcase
      1 : sel_int = LVD_INT;
      1 : begin 
            sel_int = COMP_CH1;
            rand_edge_detection = $random;
          end
      1 : begin 
            sel_int = COMP_CH2;
            rand_edge_detection = $random;
          end 
    endcase */

    use_old_intr_reg_or_general_reg_to_clr =$random;
    rand_edge_detection = $random;
    `nnc_info("SOC_TEST", $sformatf(" will be testing sel_int = %d , %s",sel_int,sel_int.name), NNC_LOW)

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_LVD_INT_EN_REG;});//enable interrupt
     wr_data[sel_int] = 1;
     if(sel_int == COMP_CH1)begin
       wr_data[3] = rand_edge_detection;
     end
     if(sel_int == COMP_CH2)begin
       wr_data[4] = rand_edge_detection;
     end
    `nnc_info("SOC_TEST", $sformatf("will be writing intr en register with wr_data =%0h",wr_data), NNC_LOW)
    `WR_NORMAL_REG(top_test_cfg.reg_addr, wr_data, top_test_cfg.pads);
    `nnc_info("SOC_TEST", $sformatf("%s intr enable",sel_int.name), NNC_LOW)

    `nnc_info("SOC_TEST", $sformatf("will check the interrupt for %s and (edge selection=%0d in case of COMP_CH1 and COMP_CH2)",sel_int.name,rand_edge_detection), NNC_LOW)
    check_intr(sel_int,rand_edge_detection);

    exp_ana_intr_sts_val[sel_int] = 1;
    check_intr_sts_reg(exp_ana_intr_sts_val,sel_int);

    // disable it by SOC_ANA_LVD_INT_EN_REG reg in case of A2D_LVD
    if(sel_int == LVD_INT)begin
      `nnc_info("SOC_TEST", $sformatf(" Clear intr via disable %s intr en",sel_int.name), NNC_LOW)
       wr_data[sel_int] = 0;
      `nnc_info("SOC_TEST", $sformatf("will be writing intr en register with wr_data %0d",wr_data), NNC_LOW)
      assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_LVD_INT_EN_REG;});//disable interrupt
      `WR_NORMAL_REG(top_test_cfg.reg_addr, wr_data, top_test_cfg.pads);
    end
    else begin // disable it by w1c in status reg for COMP0 and COMP1 intr
      if(`DUT_IF.clear_intr_manual_or_auto == 0)begin // w1c in case of manual clear, in case of auto clear, r1c will ahppen from above status read
        rd_data = 0;
        `RD_NORMAL_REG(`SOC_ANA_INT_COMP_STS_REG,top_test_cfg.pads, rd_data);
        // check ANA_LVD interrupt status
        if(sel_int == COMP_CH1)begin // if intr asserted for ana_comp 1 
          assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_INT_COMP_STS_REG; wr_data[0] == 8'h2;});// w1c to ANA_comp 1 intr status
          `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
          `nnc_info("SOC_TEST", $sformatf("Cleared INTR STS for ana comp 1"), NNC_LOW) 
        end
        if(sel_int == COMP_CH2)begin // if intr asserted for ana_comp 2 
          assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_INT_COMP_STS_REG; wr_data[0] == 8'h4;});// w1c to ANA_comp 2 intr status
          `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
          `nnc_info("SOC_TEST", $sformatf("Cleared INTR STS for ana comp 2"), NNC_LOW) 
        end
      end
    end

    `nnc_info("SOC_TEST", $sformatf("waiting for INTB to deassert"), NNC_LOW)
    if(`DUT_IF.int_active_level_high_or_low == 1) 
      wait(`SOC_TB.INTB === 0);
    else 
      wait(`SOC_TB.INTB === 1);

    exp_ana_intr_sts_val = 0;

    //if(`DUT_IF.clear_intr_manual_or_auto == 1)begin // r1c in case of auto clear, 
      repeat(6)@(posedge `DUT_IF.sys_clk); // atleast 6 pclk between 2 SPI read cmd required by design as per Zhen
    //end
    //check interrupt status reg
    exp_ana_intr_sts_val[sel_int] = 0;
    check_intr_sts_reg(exp_ana_intr_sts_val,sel_int);

    // release A2D_LVD and check reg status
    //release `ANA_TOP.A2D_LVD;
    `DUT_IF.vbat_level = $urandom_range(`DUT_IF.lvd_sel,7);
    release `ANA_TOP.A2D_COMP_OUT_CH1;
    release `ANA_TOP.A2D_COMP_OUT_CH2;
    `nnc_info("SOC_TEST", $sformatf("RELEASE the A2D signal, and check status registers"), NNC_LOW)

    //if(`DUT_IF.clear_intr_manual_or_auto == 1)begin // r1c in case of auto clear, 
      repeat(6)@(posedge `DUT_IF.sys_clk); // atleast 6 pclk between 2 SPI read cmd required by design as per Zhen
    //end
    exp_ana_intr_sts_val = 0;
    check_intr_sts_reg(exp_ana_intr_sts_val,sel_int);

  endtask

  task check_gpio_pin_for_comp_sel(input int sel_int, int exp_val);
    if(sel_int == COMP_CH1) begin
      assert(top_test_cfg.randomize() with {reg_addr == `SOC_GPIO_COM_OUT_CTRL_REG;wr_data[0] == 'h1;});// comp_out1 to output
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
      `nnc_info("SOC_TEST", $sformatf("Select comparator to output for COMP_CH1"), NNC_LOW) 
    end
    else
    if(sel_int == COMP_CH2) begin
      assert(top_test_cfg.randomize() with {reg_addr == `SOC_GPIO_COM_OUT_CTRL_REG;wr_data[0] == 'h3;});// comp_out2 to output
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
      `nnc_info("SOC_TEST", $sformatf("Selct comparator to output for COMP_CH2"), NNC_LOW) 
    end
    if(`DIG_TOP.u_pinmux.o_ens2_IOBUF_A[8] !== exp_val)begin
      `uvm_error("SOC_TEST",$sformatf("GPIO IOBUF_PD[8] =%0d ,Expected=%0d", `DIG_TOP.u_pinmux.o_ens2_IOBUF_A[8],exp_val))
    end
  endtask : check_gpio_pin_for_comp_sel

  task check_intr(input int sel_int,bit edge_detection);

    if(sel_int == COMP_CH1 || sel_int == COMP_CH2)begin
      if(edge_detection == 0)begin // intr will generate on posedge of ana comp signal
        `nnc_info("SOC_TEST", $sformatf("FORCE the A2D signals to 0, no intr should generate at negedge"), NNC_LOW)
        force_selected_intr(sel_int,0);
        if(`DUT_IF.int_active_level_high_or_low == 1) 
	  wait(`SOC_TB.INTB === 0);
        else 
          wait(`SOC_TB.INTB === 1);

        #100000ns;

        `nnc_info("SOC_TEST", $sformatf("FORCE the A2D signals to 1 , and check status registers, intr should generate at posedge"), NNC_LOW)
        fork
          begin
            force_selected_intr(sel_int,1);
          end
          begin
	    `nnc_info("SOC_TEST", $sformatf("waiting for INTB assert"), NNC_LOW)
            if(`DUT_IF.int_active_level_high_or_low == 1) 
              wait(`SOC_TB.INTB === 1);
            else 
              wait(`SOC_TB.INTB === 0);
	    `nnc_info("SOC_TEST", $sformatf("INTB asserted"), NNC_LOW)
          end
        join
      end
      else begin // intr will generate on negedge of ana comp signal
        //`nnc_info("SOC_TEST", $sformatf("FORCE the A2D signals to 1, no intr should generate "), NNC_LOW)
        //force_selected_intr(sel_int,1);
        //if(`DUT_IF.int_active_level_high_or_low == 1) 
	//  wait(`SOC_TB.INTB === 0);
        //else 
        //  wait(`SOC_TB.INTB === 1);

        //#100000ns;

        `nnc_info("SOC_TEST", $sformatf("FORCE the A2D signals to 0, now intr should generate at negedge"), NNC_LOW)
        fork
          begin
            force_selected_intr(sel_int,0);
          end
          begin
	    `nnc_info("SOC_TEST", $sformatf("waiting for INTB assert"), NNC_LOW)
            if(`DUT_IF.int_active_level_high_or_low == 1) 
              wait(`SOC_TB.INTB === 1);
            else 
              wait(`SOC_TB.INTB === 0);
	    `nnc_info("SOC_TEST", $sformatf("INTB asserted"), NNC_LOW)
          end
        join
        
        #100000ns;
      end
    end
    else begin // LVD_INT
      `nnc_info("SOC_TEST", $sformatf("FORCE the A2D signals to 1 , and check status registers"), NNC_LOW)
      fork
        begin
          force_selected_intr(sel_int,1);
        end
        begin
          `nnc_info("SOC_TEST", $sformatf("waiting for INTB assert"), NNC_LOW)
          if(`DUT_IF.int_active_level_high_or_low == 1) 
            wait(`SOC_TB.INTB === 1);
          else 
            wait(`SOC_TB.INTB === 0);
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
      `RD_NORMAL_REG(`SOC_ANA_GEN_REG_0,top_test_cfg.pads, rd_data);
      if(rd_data[0] !== force_val) `uvm_error("SOC_TEST",$sformatf("A2D_LVD STS reg value is=%0d ,Expected=%0d", rd_data[0],force_val))
      else `nnc_info("SOC_TEST", $sformatf("A2D_LVD STS reg value is=%0d ,Expected=%0d", rd_data[0],force_val), NNC_LOW) 
    end

    if(sel_int == COMP_CH1)begin
      if(force_val==1) begin
        force `ANA_TOP.A2D_COMP_OUT_CH1 = 1;
        check_gpio_pin_for_comp_sel(sel_int,`ANA_TOP.A2D_COMP_OUT_CH1);
      end
      if(force_val==0) force `ANA_TOP.A2D_COMP_OUT_CH1 = 0;
    end

    if(sel_int == COMP_CH2)begin
      if(force_val==1) begin 
        force `ANA_TOP.A2D_COMP_OUT_CH2 = 1;
	check_gpio_pin_for_comp_sel(sel_int,`ANA_TOP.A2D_COMP_OUT_CH2);
      end
      if(force_val==0) force `ANA_TOP.A2D_COMP_OUT_CH2 = 0;
    end
  endtask : force_selected_intr

  task check_intr_sts_reg(input bit[7:0] exp_ana_intr_sts_val,int sel_int);
    bit [7:0] rd_data;

    // turn off SPI VIP specific register checker as manually checking below - this is w1c reg
    //`SPI_STATUS_REG_CHECK_EN = 0;

    if(use_old_intr_reg_or_general_reg_to_clr == 0) begin // old intr status register
      `nnc_info("SOC_TEST", $sformatf("read old intr status register"), NNC_LOW)
      `RD_NORMAL_REG(`SOC_ANA_INT_COMP_STS_REG,top_test_cfg.pads, rd_data);
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
      else `nnc_info("SOC_TEST", $sformatf("GENERAL INTR STS register value is='h%0h ,Expected='h%0h", rd_data,exp_ana_intr_sts_val), NNC_LOW)
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

/*
  task check_intr_pin(input int sel_int, bit exp_val);
    if(exp_val == 1)begin
      if(sel_int == LVD_INT)begin
        wait(`SPI_TOP.o_comp_ch1_intr_pin === 0);
        wait(`SPI_TOP.o_comp_ch2_intr_pin === 0);
        wait(`SPI_TOP.o_lvd_intr_pin === 1);
      end
      if(sel_int == COMP_CH1)begin
        wait(`SPI_TOP.o_lvd_intr_pin === 0);
        wait(`SPI_TOP.o_comp_ch2_intr_pin === 0);
        wait(`SPI_TOP.o_comp_ch1_intr_pin === 1);
      end
      if(sel_int == COMP_CH2)begin
        wait(`SPI_TOP.o_lvd_intr_pin === 0);
        wait(`SPI_TOP.o_comp_ch1_intr_pin === 0);
        wait(`SPI_TOP.o_comp_ch2_intr_pin === 1);
      end
    end
    else begin
      if(sel_int == LVD_INT) wait(`SPI_TOP.o_lvd_intr_pin === 0);
      if(sel_int == COMP_CH1) wait(`SPI_TOP.o_comp_ch1_intr_pin === 0);
      if(sel_int == COMP_CH2) wait(`SPI_TOP.o_comp_ch2_intr_pin === 0);
    end
  endtask : check_intr_pin
*/

endclass : `TESTNAME
