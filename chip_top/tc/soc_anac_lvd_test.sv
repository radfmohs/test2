/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_anac_lvd_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_anac_lvd_test                                             
// Designer	: vxmai@nanochap.com                                                                 
// Date		: 22-05-2026                                                                     
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_anac_lvd_test
`define TESTCFG soc_anac_lvd_test_cfg

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

  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_anac_lvd_test_cfg");
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

    `nnc_info("SOC_TEST", "soc_anac_lvd_test start", NNC_LOW)

    // ==================================================================================
    // Please add your code of your test here
    // ---------------------------------------------------------------------------------- 
    // Change Threshold level to max
    `WR_NORMAL_REG(`SOC_ANA_GEN_REG_0_0, 8'h07, top_test_cfg.pads);
    
    // I. Testing INTR disable function
    `nnc_info("LVD Test", "Testing INTR disable", UVM_LOW);
    // Step 1: Disable LVD_EN and LVD_INTR_EN
    `WR_NORMAL_REG(`SOC_ANA_EN_REG_0_3, 8'h00, top_test_cfg.pads);
    `WR_NORMAL_REG(`SOC_ANA_LVD_INT_EN_REG, 8'h00, top_test_cfg.pads);

    // Step 2: Lower vbat_level 
    `DUT_IF.vbat_level = 0;

    //CHECKING
    intr_fall_check();

    // Step 3: Enable LVD_EN (ANA_ENABLE_REG_0_3) and make sure LVD_INTR_EN = 1

    `WR_NORMAL_REG(`SOC_ANA_EN_REG_0_3, 8'h01, top_test_cfg.pads);
    `WR_NORMAL_REG(`SOC_ANA_LVD_INT_EN_REG, 8'h01, top_test_cfg.pads);
    
    //CHECKING
    intr_raise_check();
    
    // Step 4: Disable INTR
   
    `WR_NORMAL_REG(`SOC_ANA_EN_REG_0_3, 8'h00, top_test_cfg.pads);
    `WR_NORMAL_REG(`SOC_ANA_LVD_INT_EN_REG, 8'h00, top_test_cfg.pads);
    
    //CHECKING
    intr_fall_check();
    
    // II. Testing the INTR, LVD_SEL function.
    `nnc_info("LVD Test", "Testing LVD disable", UVM_LOW);
    // Step 3: Enable LVD_EN (ANA_ENABLE_REG_0_3) and make sure LVD_INTR_EN = 1
    
    `WR_NORMAL_REG(`SOC_ANA_EN_REG_0_3, 8'h01, top_test_cfg.pads);
    `WR_NORMAL_REG(`SOC_ANA_LVD_INT_EN_REG, 8'h01, top_test_cfg.pads);
    
    //CHECKING
    intr_raise_check();
    
    // Step 4: Change LVD_SEL
    // Change Threshold level to max
    `WR_NORMAL_REG(`SOC_ANA_GEN_REG_0_0, 8'h07, top_test_cfg.pads);
    // Change vbat_level
    `DUT_IF.vbat_level = $urandom_range(0,6);
    
    //Checking since vbat level always lower than threshold
    //CHECKING
    intr_raise_check();

    if(`DUT_IF.vbat_level == 7)
        begin
            assert(top_test_cfg.randomize with {wr_data[0] inside {[3'b000:3'b110]};});     
            `WR_NORMAL_REG(`SOC_ANA_GEN_REG_0_0, top_test_cfg.wr_data[0], top_test_cfg.pads);
        end
    else if(`DUT_IF.vbat_level == 6) 
        begin
            assert(top_test_cfg.randomize with {wr_data[0] inside {[3'b000:3'b101]};});     
            `WR_NORMAL_REG(`SOC_ANA_GEN_REG_0_0, top_test_cfg.wr_data[0], top_test_cfg.pads);
        end
    else if(`DUT_IF.vbat_level == 5) 
        begin
            assert(top_test_cfg.randomize with {wr_data[0] inside {[3'b000:3'b100]};});     
            `WR_NORMAL_REG(`SOC_ANA_GEN_REG_0_0, top_test_cfg.wr_data[0], top_test_cfg.pads);
        end
    else if(`DUT_IF.vbat_level == 4) 
        begin
            assert(top_test_cfg.randomize with {wr_data[0] inside {[3'b000:3'b011]};});     
            `WR_NORMAL_REG(`SOC_ANA_GEN_REG_0_0, top_test_cfg.wr_data[0], top_test_cfg.pads);
        end
    else if(`DUT_IF.vbat_level == 3) 
        begin
            assert(top_test_cfg.randomize with {wr_data[0] inside {[3'b000:3'b010]};});     
            `WR_NORMAL_REG(`SOC_ANA_GEN_REG_0_0, top_test_cfg.wr_data[0], top_test_cfg.pads);
        end
    else if(`DUT_IF.vbat_level == 2) 
        begin
            assert(top_test_cfg.randomize with {wr_data[0] inside {[3'b000:3'b001]};});     
            `WR_NORMAL_REG(`SOC_ANA_GEN_REG_0_0, top_test_cfg.wr_data[0], top_test_cfg.pads);
        end
    else if(`DUT_IF.vbat_level == 1) 
        begin
            assert(top_test_cfg.randomize with {wr_data[0] inside {[3'b000:3'b001]};});     
            `WR_NORMAL_REG(`SOC_ANA_GEN_REG_0_0, top_test_cfg.wr_data[0], top_test_cfg.pads);
        end
    else if(`DUT_IF.vbat_level == 0) 
        begin
            assert(top_test_cfg.randomize with {wr_data[0] inside {[3'b000:3'b000]};});     
            `WR_NORMAL_REG(`SOC_ANA_GEN_REG_0_0, top_test_cfg.wr_data[0], top_test_cfg.pads);
        end

    //CHECKING
    intr_fall_check();

    // III. Testing the change battery function.
    `nnc_info("LVD Test", "Testing Battery Changing", UVM_LOW);
    // Step 3: Enable LVD_EN (ANA_ENABLE_REG_0_3) and make sure LVD_INTR_EN = 1
    assert(top_test_cfg.randomize with {wr_data[0] inside {[3'b001:3'b111]};});     
    `WR_NORMAL_REG(`SOC_ANA_GEN_REG_0_0, top_test_cfg.wr_data[0], top_test_cfg.pads);
    `DUT_IF.vbat_level = $urandom_range(0,(top_test_cfg.wr_data[0] - 1));
    
    `WR_NORMAL_REG(`SOC_ANA_EN_REG_0_3, 8'h01, 8'h00);
    `WR_NORMAL_REG(`SOC_ANA_LVD_INT_EN_REG, 8'h01, 8'h00);
    
    //CHECKING
    intr_raise_check();
    
    // Step 4: Change LVD_SEL
    `DUT_IF.vbat_level = 7;

    //CHECKING
    intr_fall_check();

    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    #10000ns;
    `nnc_info("SOC_TEST", "soc_anac_lvd_test end now", NNC_LOW)

    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ==================================================================================

    phase.drop_objection(this);
  endtask: main_phase

  task intr_raise_check;
    logic[7:0] rd_data;
    
    //Expected ANA_LVD_STS raise.
    `RD_NORMAL_REG(`SOC_ANA_INT_LVD_STS_REG, top_test_cfg.pads, rd_data);

    //Expected ANA_LVD_STS raise with 2 conditions enable
    if(rd_data[0] !== 1'b1)
       `nnc_error("STS", $sformatf("The INT_LVD_STS don't raise, the value is %b", rd_data[0])) 
    else 
       `nnc_info("STS", "The INT_LVD_STS raise", NNC_LOW) 
    
    `RD_NORMAL_REG(`SOC_GENERAL_INT_STS_1_REG, top_test_cfg.pads, rd_data);

    //Expected ANA_LVD_STS raise with 2 conditions enable
    if(rd_data[0] !== 1'b1)
       `nnc_error("STS", $sformatf("GENERAL_INT_CTRL_LVD don't raise, the value is %b", rd_data[0])) 
    else 
       `nnc_info("STS", "GENERAL_INT_CTRL_LVD raise", NNC_LOW) 
    
    `RD_NORMAL_REG(`SOC_A2D_ANA_GEN_REG_0, top_test_cfg.pads, rd_data);

    //Expected ANA_LVD_STS raise with 2 conditions enable
    if(rd_data[0] !== 1'b1)
       `nnc_error("STS", $sformatf("A2D_ANA_GEN_REG_0 don't raise, the value is %b", rd_data[0])) 
    else 
       `nnc_info("STS", "A2D_ANA_GEN_REG_0 raise", NNC_LOW) 
    
    `nnc_info("PAD_INT", "Checking Pad 8 when Multi_INTB = 0", NNC_LOW)
    
    `WR_NORMAL_REG(`SOC_PMU_REG, 8'h00, 8'h00);

    if(`SOC_TOP.IOBUF_PAD[8] !== 1'b1)
       `nnc_error("STS", "Interrupt in PAD [8] is not raised") 
    else 
       `nnc_info("STS", "Interrupt in PAD [8] is raised", NNC_LOW) 
    
    `nnc_info("PAD_INT", "Checking Pad 8 when Multi_INTB = 0", NNC_LOW)
    
    `WR_NORMAL_REG(`SOC_PMU_REG, 8'h40, 8'h00);

    if(`SOC_TOP.IOBUF_PAD[10] !== 1'b1)
       `nnc_error("STS", "Interrupt in PAD [10] is not raised") 
    else 
       `nnc_info("STS", "Interrupt in PAD [10] is raised", NNC_LOW) 
    
  endtask
  
  task intr_fall_check;
    logic [7:0] rd_data;
    
    //Expected ANA_LVD_STS raise.
    `RD_NORMAL_REG(`SOC_ANA_INT_LVD_STS_REG, top_test_cfg.pads, rd_data);

    //Expected ANA_LVD_STS raise with 2 conditions enable
    if(rd_data[0] !== 1'b0)
       `nnc_error("STS", $sformatf("INT_LVD_STS don't fall, the value is %b",rd_data[0])) 
    else 
       `nnc_info("STS", $sformatf("INT_LVD_STS fall, the value is %b",rd_data[0]), NNC_LOW) 
    
    `RD_NORMAL_REG(`SOC_GENERAL_INT_STS_1_REG, top_test_cfg.pads, rd_data);

    //Expected ANA_LVD_STS raise with 2 conditions enable
    if(rd_data[0] !== 1'b0)
       `nnc_error("STS", $sformatf("GENERAL_INT_CTRL_LVD don't fall, the value is %b",rd_data[0])) 
    else 
       `nnc_info("STS", "GENERAL_INT_CTRL_LVD fall", NNC_LOW) 
    
    `RD_NORMAL_REG(`SOC_A2D_ANA_GEN_REG_0, top_test_cfg.pads, rd_data);

    //Expected ANA_LVD_STS raise with 2 conditions enable
    if(rd_data[0] !== 1'b0)
       `nnc_error("STS", $sformatf("A2D_ANA_GEN_REG_0 don't fall, the value is %b",rd_data[0])) 
    else 
       `nnc_info("STS", "A2D_ANA_GEN_REG_0 fall", NNC_LOW) 
    
    `nnc_info("PAD_INT", "Checking Pad 8 when Multi_INTB = 0", NNC_LOW)
    
    `WR_NORMAL_REG(`SOC_PMU_REG, 8'h00, 8'h00);

    if(`SOC_TOP.IOBUF_PAD[8] !== 1'b0)
       `nnc_error("STS", "Interrupt in PAD [8] is not 0") 
    else 
       `nnc_info("STS", "Interrupt in PAD [8] is 0", NNC_LOW) 
    
    `nnc_info("PAD_INT", "Checking Pad 10 when Multi_INTB = 1", NNC_LOW)
    
    `WR_NORMAL_REG(`SOC_PMU_REG, 8'h40, 8'h00);

    if(`SOC_TOP.IOBUF_PAD[10] !== 1'b0)
       `nnc_error("STS", "Interrupt in PAD [10] is not 0") 
    else 
       `nnc_info("STS", "Interrupt in PAD [10] is 0", NNC_LOW) 
    
  endtask

  // ------------------------------
  // Declare the report_phase task
  // ------------------------------
  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction

endclass : `TESTNAME
