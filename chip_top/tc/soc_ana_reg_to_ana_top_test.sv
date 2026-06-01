/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_ana_reg_to_ana_top_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_ana_reg_to_ana_top_test                                             
// Designer	: thnguyen@nanochap.com                                                                 
// Date		: 01-05-2026                                                                     
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_ana_reg_to_ana_top_test
`define TESTCFG soc_ana_reg_to_ana_top_test_cfg

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
  rand logic [7:0] n_write;  
  logic [7:0]      rd_data[];

  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_ana_reg_to_ana_top_test_cfg");
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
   
  logic [7:0] rand_val;
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

    `nnc_info("SOC_TEST", "soc_ana_reg_to_ana_top_test start", NNC_LOW)

    // ==================================================================================
    // Please add your code of your test here
    // ---------------------------------------------------------------------------------- 
    // ANA_ENABLE_REG_SECTION_0    
    // KEEP ANA_EN_SECTION_SEL_REG as default to make it SECTION 0
    // ---------------------
    // Register 0xC1
    // ---------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_EN_REG_0_0; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_EN_REG_0_0", `INIT_SOC_ANA_EN_REG_0_0, {2'b00, `ANA_TOP.D2A_BIST_SEL, `ANA_TOP.D2A_BIST_EN}, `MASK_SOC_ANA_EN_REG_0_0);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
      compare_start("SOC_ANA_EN_REG_0_0", top_test_cfg.wr_data[i], {2'b00, `ANA_TOP.D2A_BIST_SEL, `ANA_TOP.D2A_BIST_EN}, `MASK_SOC_ANA_EN_REG_0_0);
    `nnc_info("ANA_CONN_CHECK", "Checking ANA Conn Done\n", UVM_LOW);
    end

    // ---------------------
    // Register 0xC2
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_EN_REG_0_1; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_EN_REG_0_1", `INIT_SOC_ANA_EN_REG_0_1, {6'h0, `ANA_TOP.D2A_OSC8MHZEN, `ANA_TOP.D2A_BGBUFFER_CPTEST_EN}, `MASK_SOC_ANA_EN_REG_0_1);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_EN_REG_0_1", top_test_cfg.wr_data[i], {6'h0, `ANA_TOP.D2A_OSC8MHZEN, `ANA_TOP.D2A_BGBUFFER_CPTEST_EN}, `MASK_SOC_ANA_EN_REG_0_1);
    `nnc_info("ANA_CONN_CHECK", "Checking ANA Conn Done\n", UVM_LOW);
    end

    // ---------------------
    // Register 0xC3
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_EN_REG_0_2; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_EN_REG_0_2", `INIT_SOC_ANA_EN_REG_0_2, {4'h0, `ANA_TOP.D2A_SDMVREFPBUFF_EN, `ANA_TOP.D2A_SDMVCMBUFF_EN, `ANA_TOP.D2A_VCMGENBUFF_EN, `ANA_TOP.D2A_RLD_ELECTRODE_EN},  `MASK_SOC_ANA_EN_REG_0_2);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_EN_REG_0_2", top_test_cfg.wr_data[i], {4'h0, `ANA_TOP.D2A_SDMVREFPBUFF_EN, `ANA_TOP.D2A_SDMVCMBUFF_EN, `ANA_TOP.D2A_VCMGENBUFF_EN, `ANA_TOP.D2A_RLD_ELECTRODE_EN}, `MASK_SOC_ANA_EN_REG_0_2);
    `nnc_info("ANA_CONN_CHECK", "Checking ANA Conn Done\n", UVM_LOW);
    end

    // ---------------------
    // Register 0xC4
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_EN_REG_0_3; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_EN_REG_0_3", `INIT_SOC_ANA_EN_REG_0_3, {3'h0, `ANA_TOP.D2A_DRIVERC_SHORT_DET_EN, `ANA_TOP.D2A_DRIVERC_LEAD_OFF_EN, `ANA_TOP.D2A_RLD_EN, `ANA_TOP.D2A_BIAS_MEAS, `ANA_TOP.D2A_LVD_EN}, `MASK_SOC_ANA_EN_REG_0_3);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_EN_REG_0_3", top_test_cfg.wr_data[i], {3'h0, `ANA_TOP.D2A_DRIVERC_SHORT_DET_EN, `ANA_TOP.D2A_DRIVERC_LEAD_OFF_EN, `ANA_TOP.D2A_RLD_EN, `ANA_TOP.D2A_BIAS_MEAS, `ANA_TOP.D2A_LVD_EN}, `MASK_SOC_ANA_EN_REG_0_3);
    `nnc_info("ANA_CONN_CHECK", "Checking ANA Conn Done\n", UVM_LOW);
    end
    
    // ---------------------
    // Register 0xC5
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_EN_REG_0_4; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_EN_REG_0_4", `INIT_SOC_ANA_EN_REG_0_4, {`ANA_TOP.D2A_EEGLNA_EN}, `MASK_SOC_ANA_EN_REG_0_4);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_EN_REG_0_4", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGLNA_EN}, `MASK_SOC_ANA_EN_REG_0_4);
    `nnc_info("ANA_CONN_CHECK", "Checking ANA Conn Done\n", UVM_LOW);
    end


    // ---------------------
    // Register 0xC6
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_EN_REG_0_5; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_EN_REG_0_5", `INIT_SOC_ANA_EN_REG_0_5, {`ANA_TOP.D2A_EEGLNA_EN[15:8]}, `MASK_SOC_ANA_EN_REG_0_5);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_EN_REG_0_5", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGLNA_EN[15:8]}, `MASK_SOC_ANA_EN_REG_0_5);
    `nnc_info("ANA_CONN_CHECK", "Checking ANA Conn Done\n", UVM_LOW);
    end


    // ---------------------
    // Register 0xC7
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_EN_REG_0_6; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_EN_REG_0_6", `INIT_SOC_ANA_EN_REG_0_6, {`ANA_TOP.D2A_QSTRLNA_EN[7:0]}, `MASK_SOC_ANA_EN_REG_0_6);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_EN_REG_0_6", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_QSTRLNA_EN[7:0]}, `MASK_SOC_ANA_EN_REG_0_6);
    `nnc_info("ANA_CONN_CHECK", "Checking ANA Conn Done\n", UVM_LOW);
    end

    // ---------------------
    // Register 0xC8
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_EN_REG_0_7; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_EN_REG_0_7", `INIT_SOC_ANA_EN_REG_0_7, {`ANA_TOP.D2A_QSTRLNA_EN[15:8]}, `MASK_SOC_ANA_EN_REG_0_7);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_EN_REG_0_7", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_QSTRLNA_EN[15:8]}, `MASK_SOC_ANA_EN_REG_0_7);
    `nnc_info("ANA_CONN_CHECK", "Checking ANA Conn Done\n", UVM_LOW);
    end
    
    // ---------------------
    // Register 0xC9
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_EN_REG_0_8; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_EN_REG_0_8", `INIT_SOC_ANA_EN_REG_0_8, {`ANA_TOP.D2A_EEGPGA_EN[7:0]}, `MASK_SOC_ANA_EN_REG_0_8);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_EN_REG_0_8", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGPGA_EN[7:0]}, `MASK_SOC_ANA_EN_REG_0_8);
    `nnc_info("ANA_CONN_CHECK", "Checking ANA Conn Done\n", UVM_LOW);
    end

    // ---------------------
    // Register 0xCA
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_EN_REG_0_9; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_EN_REG_0_9", `INIT_SOC_ANA_EN_REG_0_9, {1'b0, `ANA_TOP.D2A_EEGPGA_EN[15:8]}, `MASK_SOC_ANA_EN_REG_0_9);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_EN_REG_0_9", top_test_cfg.wr_data[i], {1'b0, `ANA_TOP.D2A_EEGPGA_EN[15:8]}, `MASK_SOC_ANA_EN_REG_0_9);
    `nnc_info("ANA_CONN_CHECK", "Checking ANA Conn Done\n", UVM_LOW);
    end

    // ---------------------
    // Register 0xCB
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_EN_REG_0_10; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_EN_REG_0_10", `INIT_SOC_ANA_EN_REG_0_10, {`ANA_TOP.D2A_QSTRPGA_EN[7:0]}, `MASK_SOC_ANA_EN_REG_0_10);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_EN_REG_0_10", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_QSTRPGA_EN[7:0]}, `MASK_SOC_ANA_EN_REG_0_10);
    `nnc_info("ANA_CONN_CHECK", "Checking ANA Conn Done\n", UVM_LOW);
    end

    // ---------------------
    // Register 0xCC
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_EN_REG_0_11; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_EN_REG_0_11", `INIT_SOC_ANA_EN_REG_0_11, {`ANA_TOP.D2A_QSTRPGA_EN[15:8]}, `MASK_SOC_ANA_EN_REG_0_11);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_EN_REG_0_10", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_QSTRPGA_EN[15:8]}, `MASK_SOC_ANA_EN_REG_0_11);
    `nnc_info("ANA_CONN_CHECK", "Checking ANA Conn Done\n", UVM_LOW);
    end
/* REMOVE DUE TO CHANGES IN MANUAL 
    // ---------------------
    // Register 0xCD
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_EN_REG_0_12; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_EN_REG_0_12", `INIT_SOC_ANA_EN_REG_0_12, {`ANA_TOP.D2A_CBUF_EN[7:0]}, `MASK_SOC_ANA_EN_REG_0_12);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_EN_REG_0_12", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_CBUF_EN[7:0]}, `MASK_SOC_ANA_EN_REG_0_12);
    `nnc_info("ANA_CONN_CHECK", "Checking ANA Conn Done\n", UVM_LOW);
    end

    // ---------------------
    // Register 0xCE
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_EN_REG_0_13; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_EN_REG_0_13", `INIT_SOC_ANA_EN_REG_0_13, {`ANA_TOP.D2A_CBUF_EN[15:8]}, `MASK_SOC_ANA_EN_REG_0_13);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_EN_REG_0_13", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_CBUF_EN[15:8]}, `MASK_SOC_ANA_EN_REG_0_13);
    `nnc_info("ANA_CONN_CHECK", "Checking ANA Conn Done\n", UVM_LOW);
    end
*/
/* REMOVE DUE TO CHANGES IN MANUAL 
    // ---------------------
    // Register 0xCF
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_EN_REG_0_14; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_EN_REG_0_14", `INIT_SOC_ANA_EN_REG_0_14, {`ANA_TOP.D2A_IDAC_EN[7:0]}, `MASK_SOC_ANA_EN_REG_0_14);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_EN_REG_0_14", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_IDAC_EN[7:0]}, `MASK_SOC_ANA_EN_REG_0_14);
    `nnc_info("ANA_CONN_CHECK", "Checking ANA Conn Done\n", UVM_LOW);
    end
*/
    // ANA_ENABLE_REG_SECTION_1
    // WRITE TO ANA_EN_SECTION_SEL_REG to change to SECTION 1
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 1\n", UVM_LOW);
    `WR_NORMAL_REG(`SOC_ANA_EN_SEC_SEL_REG, 8'h1, 8'h00);
/* REMOVE DUE TO CHANGES IN MANUAL 
    // ---------------------
    // Register 0xC1
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_EN_REG_1_0; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_EN_REG_1_0", `INIT_SOC_ANA_EN_REG_1_0, {`ANA_TOP.D2A_IDAC_EN[15:8]}, 8'hFF);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_EN_REG_1_0", `INIT_SOC_ANA_EN_REG_1_0, {`ANA_TOP.D2A_IDAC_EN[15:8]}, 8'hFF);
    end
*/
    // ---------------------
    // Register 0xC2
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_EN_REG_1_1; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_EN_REG_1_1", `INIT_SOC_ANA_EN_REG_1_1, {`ANA_TOP.D2A_SDMEN[7:0]}, 8'hFF);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_EN_REG_1_1", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_SDMEN[7:0]}, 8'hFF);
    end

    // ---------------------
    // Register 0xC3
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_EN_REG_1_2; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_EN_REG_1_2", `INIT_SOC_ANA_EN_REG_1_2, {`ANA_TOP.D2A_SDMEN[15:8]}, 8'hFF);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_EN_REG_1_2", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_SDMEN[15:8]}, 8'hFF);
    end

    // ---------------------
    // Register 0xC4
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_EN_REG_1_3; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_EN_REG_1_3", `INIT_SOC_ANA_EN_REG_1_3, {`ANA_TOP.D2A_SDMBUFF_EN[7:0]}, 8'hFF);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_EN_REG_1_3", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_SDMBUFF_EN[7:0]}, 8'hFF);
    end

    // ---------------------
    // Register 0xC5
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_EN_REG_1_4; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_EN_REG_1_4", `INIT_SOC_ANA_EN_REG_1_4, {`ANA_TOP.D2A_SDMBUFF_EN[15:8]}, 8'hFF);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_EN_REG_1_4", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_SDMBUFF_EN[15:8]}, 8'hFF);
    end
  /*  
    // ---------------------
    // Register 0xC6
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == 8'hC6; n_write == 10;});     
    // Cheking Default
    compare_start("8'hC6", 8'h00, {`ANA_TOP.D2A_DCLOFFEN[7:0]}, 8'hFF);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("8'hC6", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_DCLOFFEN[7:0]}, 8'hFF);
    end
    
    // ---------------------
    // Register 0xC7
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == 8'hC7; n_write == 10;});     
    // Cheking Default
    compare_start("8'hC7", 8'h00, {`ANA_TOP.D2A_DCLOFFEN[15:8]}, 8'hFF);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("8'hC7", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_DCLOFFEN[15:8]}, 8'hFF);
    end
*/
    // ---------------------------------------------------------------------------------- 
    // ANA_GEN_REG_SECTION_0    
    // KEEP ANA_GEN_SECTION_SEL_REG as default to make it SECTION 0
    // ---------------------

    // ---------------------
    // Register 0xD1
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_0_0; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_0_0", `INIT_SOC_ANA_GEN_REG_0_0, {4'h0, `ANA_TOP.D2A_BIASREF_INT, `ANA_TOP.D2A_LVD_SEL}, `MASK_SOC_ANA_GEN_REG_0_0);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_0_0", top_test_cfg.wr_data[i], {4'h0, `ANA_TOP.D2A_BIASREF_INT, `ANA_TOP.D2A_LVD_SEL}, `MASK_SOC_ANA_GEN_REG_0_0);
    end

    // ---------------------
    // Register 0xD2
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_0_1; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_0_1", `INIT_SOC_ANA_GEN_REG_0_1, {2'h0, `ANA_TOP.D2A_EEG_CH1_SET, `ANA_TOP.D2A_EEG_CH0_SET}, `MASK_SOC_ANA_GEN_REG_0_1);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_0_1", top_test_cfg.wr_data[i], {2'h0, `ANA_TOP.D2A_EEG_CH1_SET, `ANA_TOP.D2A_EEG_CH0_SET}, `MASK_SOC_ANA_GEN_REG_0_1);
    end

    // ---------------------
    // Register 0xD3
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_0_2; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_0_2", `INIT_SOC_ANA_GEN_REG_0_2, {2'h0, `ANA_TOP.D2A_EEG_CH3_SET, `ANA_TOP.D2A_EEG_CH2_SET}, `MASK_SOC_ANA_GEN_REG_0_2);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_0_2", top_test_cfg.wr_data[i], {2'h0, `ANA_TOP.D2A_EEG_CH3_SET, `ANA_TOP.D2A_EEG_CH2_SET}, `MASK_SOC_ANA_GEN_REG_0_2);
    end

    // ---------------------
    // Register 0xD4
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_0_3; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_0_3", `INIT_SOC_ANA_GEN_REG_0_3, {2'h0, `ANA_TOP.D2A_EEG_CH5_SET, `ANA_TOP.D2A_EEG_CH4_SET}, `MASK_SOC_ANA_GEN_REG_0_3);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_0_3", top_test_cfg.wr_data[i], {2'h0, `ANA_TOP.D2A_EEG_CH5_SET, `ANA_TOP.D2A_EEG_CH4_SET}, `MASK_SOC_ANA_GEN_REG_0_3);
    end

    // ---------------------
    // Register 0xD5
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_0_4; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_0_4", `INIT_SOC_ANA_GEN_REG_0_4, {2'h0, `ANA_TOP.D2A_EEG_CH7_SET, `ANA_TOP.D2A_EEG_CH6_SET}, `MASK_SOC_ANA_GEN_REG_0_4);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_0_4", top_test_cfg.wr_data[i], {2'h0, `ANA_TOP.D2A_EEG_CH7_SET, `ANA_TOP.D2A_EEG_CH6_SET}, `MASK_SOC_ANA_GEN_REG_0_4);
    end

    // ---------------------
    // Register 0xD6
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_0_5; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_0_5", `INIT_SOC_ANA_GEN_REG_0_5, {2'h0, `ANA_TOP.D2A_EEG_CH9_SET, `ANA_TOP.D2A_EEG_CH8_SET}, `MASK_SOC_ANA_GEN_REG_0_5);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_0_5", top_test_cfg.wr_data[i], {2'h0, `ANA_TOP.D2A_EEG_CH9_SET, `ANA_TOP.D2A_EEG_CH8_SET}, `MASK_SOC_ANA_GEN_REG_0_5);
    end

    // ---------------------
    // Register 0xD7
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_0_6; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_0_6", `INIT_SOC_ANA_GEN_REG_0_6, {2'h0, `ANA_TOP.D2A_EEG_CH11_SET, `ANA_TOP.D2A_EEG_CH10_SET}, `MASK_SOC_ANA_GEN_REG_0_6);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_0_6", top_test_cfg.wr_data[i], {2'h0, `ANA_TOP.D2A_EEG_CH11_SET, `ANA_TOP.D2A_EEG_CH10_SET}, `MASK_SOC_ANA_GEN_REG_0_6);
    end

    // ---------------------
    // Register 0xD8
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_0_7; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_0_7", `INIT_SOC_ANA_GEN_REG_0_7, {2'h0, `ANA_TOP.D2A_EEG_CH13_SET, `ANA_TOP.D2A_EEG_CH12_SET}, `MASK_SOC_ANA_GEN_REG_0_7);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_0_2", top_test_cfg.wr_data[i], {2'h0, `ANA_TOP.D2A_EEG_CH13_SET, `ANA_TOP.D2A_EEG_CH12_SET}, `MASK_SOC_ANA_GEN_REG_0_7);
    end

    // ---------------------
    // Register 0xD9
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_0_8; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_0_8", `INIT_SOC_ANA_GEN_REG_0_8, {2'h0, `ANA_TOP.D2A_EEG_CH15_SET, `ANA_TOP.D2A_EEG_CH14_SET}, `MASK_SOC_ANA_GEN_REG_0_8);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_0_8", top_test_cfg.wr_data[i], {2'h0, `ANA_TOP.D2A_EEG_CH15_SET, `ANA_TOP.D2A_EEG_CH14_SET}, `MASK_SOC_ANA_GEN_REG_0_8);
    end

    // ---------------------
    // Register 0xDA
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_0_9; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_0_9", `INIT_SOC_ANA_GEN_REG_0_9, {`ANA_TOP.D2A_EEGLNA3_IADJ, `ANA_TOP.D2A_EEGLNA2_IADJ, `ANA_TOP.D2A_EEGLNA1_IADJ, `ANA_TOP.D2A_EEGLNA0_IADJ}, `MASK_SOC_ANA_GEN_REG_0_9);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_0_9", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGLNA3_IADJ, `ANA_TOP.D2A_EEGLNA2_IADJ, `ANA_TOP.D2A_EEGLNA1_IADJ, `ANA_TOP.D2A_EEGLNA0_IADJ}, `MASK_SOC_ANA_GEN_REG_0_9);
    end

    // ---------------------
    // Register 0xDB
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_0_10; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_0_10", `INIT_SOC_ANA_GEN_REG_0_10, {`ANA_TOP.D2A_EEGLNA7_IADJ, `ANA_TOP.D2A_EEGLNA6_IADJ, `ANA_TOP.D2A_EEGLNA5_IADJ, `ANA_TOP.D2A_EEGLNA4_IADJ}, `MASK_SOC_ANA_GEN_REG_0_10);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_0_10", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGLNA7_IADJ, `ANA_TOP.D2A_EEGLNA6_IADJ, `ANA_TOP.D2A_EEGLNA5_IADJ, `ANA_TOP.D2A_EEGLNA4_IADJ}, `MASK_SOC_ANA_GEN_REG_0_10);
    end

    // ---------------------
    // Register 0xDC
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_0_11; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_0_11", `INIT_SOC_ANA_GEN_REG_0_11, {`ANA_TOP.D2A_EEGLNA12_IADJ, `ANA_TOP.D2A_EEGLNA11_IADJ, `ANA_TOP.D2A_EEGLNA10_IADJ, `ANA_TOP.D2A_EEGLNA9_IADJ}, `MASK_SOC_ANA_GEN_REG_0_11);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_0_11", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGLNA12_IADJ, `ANA_TOP.D2A_EEGLNA11_IADJ, `ANA_TOP.D2A_EEGLNA10_IADJ, `ANA_TOP.D2A_EEGLNA9_IADJ}, `MASK_SOC_ANA_GEN_REG_0_11);
    end

    // ---------------------
    // Register 0xDD
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_0_12; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_0_12", `INIT_SOC_ANA_GEN_REG_0_12, {2'h0, `ANA_TOP.D2A_EEGLNA15_IADJ, `ANA_TOP.D2A_EEGLNA14_IADJ, `ANA_TOP.D2A_EEGLNA13_IADJ}, `MASK_SOC_ANA_GEN_REG_0_12);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_0_12", top_test_cfg.wr_data[i], {2'h0, `ANA_TOP.D2A_EEGLNA15_IADJ, `ANA_TOP.D2A_EEGLNA14_IADJ, `ANA_TOP.D2A_EEGLNA13_IADJ}, `MASK_SOC_ANA_GEN_REG_0_12);
    end

    // ---------------------
    // Register 0xDE
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_0_13; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_0_13", `INIT_SOC_ANA_GEN_REG_0_13, {`ANA_TOP.D2A_SPI_SPARE0}, 8'hFF);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_0_13", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_SPI_SPARE0}, 8'hFF);
    end
    
    // ---------------------
    // Register 0xDF
    // ---------------------
    // Writting into 0xC1 D2A_BIST_SEL and D2A_BIST_EN
    // ---------------------
      
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);
    `WR_NORMAL_REG(`SOC_ANA_EN_SEC_SEL_REG, 8'h0, 8'h00);

    // Checking ENABLE TSC CTRL   
    `nnc_info("ENABLE TSC CTRL", "Enable TSC CTRL", UVM_LOW);
    `WR_NORMAL_REG(`SOC_TSC_EN_REG_SEL_REG, 8'h10, 8'h00);
    
    // Checking BIST = 01111    
    `nnc_info("Changing BIST_SEL", "Change BIST SEL", UVM_LOW);
    `WR_NORMAL_REG(`SOC_ANA_EN_REG_0_0, {2'h0, 5'b01111, 1'b1}, 8'h00);

    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_0_14; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_0_14", `INIT_SOC_ANA_GEN_REG_0_14, {`ANA_WRAPPER_TOP.D2A_ADJ0_14_IO}, `MASK_SOC_ANA_GEN_REG_0_14);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_0_14", top_test_cfg.wr_data[i], {`ANA_WRAPPER_TOP.D2A_ADJ0_14_IO}, `MASK_SOC_ANA_GEN_REG_0_14);
    end
    
    // Checking BIST = 11101    
    `nnc_info("Changing BIST_SEL", "Change BIST SEL", UVM_LOW);
    `WR_NORMAL_REG(`SOC_ANA_EN_REG_0_0, {2'h0, 5'b11101, 1'b1}, 8'h00);

    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_0_14; n_write == 10;});     
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_0_14", top_test_cfg.wr_data[i], {`ANA_WRAPPER_TOP.D2A_ADJ0_14_IO}, `MASK_SOC_ANA_GEN_REG_0_14);
    end
    
    // ---------------------------------------------------------------------------------- 
    // ANA_GEN_REG_SECTION_1    
    `nnc_info("ANA_GEN_REG", "Changing ANA_GEN Section to 1\n", UVM_LOW);
    `WR_NORMAL_REG(`SOC_ANA_GEN_SECTION_SEL_REG, 8'h1, 8'h00);
    // ---------------------

    // ---------------------
    // Register 0xD1
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_1_0; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_1_0", `INIT_SOC_ANA_GEN_REG_1_0, {`ANA_TOP.D2A_EEGLNA0_GAIN}, `MASK_SOC_ANA_GEN_REG_1_0);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_1_0", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGLNA0_GAIN}, `MASK_SOC_ANA_GEN_REG_1_0);
    end

    // ---------------------
    // Register 0xD2
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_1_1; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_1_1", `INIT_SOC_ANA_GEN_REG_1_1, {2'h0, `ANA_TOP.D2A_EEGLNA1_GAIN}, `MASK_SOC_ANA_GEN_REG_1_1);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_1_1", top_test_cfg.wr_data[i], {2'h0, `ANA_TOP.D2A_EEGLNA1_GAIN}, `MASK_SOC_ANA_GEN_REG_1_1);
    end

    // ---------------------
    // Register 0xD3
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_1_2; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_1_2", `INIT_SOC_ANA_GEN_REG_1_2, {2'h0, `ANA_TOP.D2A_EEGLNA2_GAIN}, `MASK_SOC_ANA_GEN_REG_1_2);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_1_2", top_test_cfg.wr_data[i], {2'h0, `ANA_TOP.D2A_EEGLNA2_GAIN}, `MASK_SOC_ANA_GEN_REG_1_2);
    end

    // ---------------------
    // Register 0xD4
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_1_3; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_1_3", `INIT_SOC_ANA_GEN_REG_1_3, {2'h0, `ANA_TOP.D2A_EEGLNA3_GAIN}, `MASK_SOC_ANA_GEN_REG_1_3);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_1_3", top_test_cfg.wr_data[i], {2'h0, `ANA_TOP.D2A_EEGLNA3_GAIN}, `MASK_SOC_ANA_GEN_REG_1_3);
    end

    // ---------------------
    // Register 0xD5
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_1_4; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_1_4", `INIT_SOC_ANA_GEN_REG_1_4, {2'h0, `ANA_TOP.D2A_EEGLNA4_GAIN}, `MASK_SOC_ANA_GEN_REG_1_4);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_1_4", top_test_cfg.wr_data[i], {2'h0, `ANA_TOP.D2A_EEGLNA4_GAIN}, `MASK_SOC_ANA_GEN_REG_1_4);
    end

    // ---------------------
    // Register 0xD6
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_1_5; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_1_5", `INIT_SOC_ANA_GEN_REG_1_5, {2'h0, `ANA_TOP.D2A_EEGLNA5_GAIN}, `MASK_SOC_ANA_GEN_REG_1_5);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_1_5", top_test_cfg.wr_data[i], {2'h0, `ANA_TOP.D2A_EEGLNA5_GAIN}, `MASK_SOC_ANA_GEN_REG_1_5);
    end

    // ---------------------
    // Register 0xD7
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_1_6; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_1_6", `INIT_SOC_ANA_GEN_REG_1_6, {2'h0, `ANA_TOP.D2A_EEGLNA6_GAIN}, `MASK_SOC_ANA_GEN_REG_1_6);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_1_6", top_test_cfg.wr_data[i], {2'h0, `ANA_TOP.D2A_EEGLNA6_GAIN}, `MASK_SOC_ANA_GEN_REG_1_6);
    end

    // ---------------------
    // Register 0xD8
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_1_7; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_1_7", `INIT_SOC_ANA_GEN_REG_1_7, {2'h0, `ANA_TOP.D2A_EEGLNA7_GAIN}, `MASK_SOC_ANA_GEN_REG_1_7);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_1_2", top_test_cfg.wr_data[i], {2'h0, `ANA_TOP.D2A_EEGLNA7_GAIN}, `MASK_SOC_ANA_GEN_REG_1_7);
    end

    // ---------------------
    // Register 0xD9
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_1_8; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_1_8", `INIT_SOC_ANA_GEN_REG_1_8, {2'h0, `ANA_TOP.D2A_EEGLNA9_GAIN}, `MASK_SOC_ANA_GEN_REG_1_8);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_1_8", top_test_cfg.wr_data[i], {2'h0, `ANA_TOP.D2A_EEGLNA9_GAIN}, `MASK_SOC_ANA_GEN_REG_1_8);
    end

    // ---------------------
    // Register 0xDA
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_1_9; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_1_9", `INIT_SOC_ANA_GEN_REG_1_9, {2'h0, `ANA_TOP.D2A_EEGLNA10_GAIN}, `MASK_SOC_ANA_GEN_REG_1_9);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_1_9", top_test_cfg.wr_data[i], {2'h0, `ANA_TOP.D2A_EEGLNA10_GAIN}, `MASK_SOC_ANA_GEN_REG_1_9);
    end

    // ---------------------
    // Register 0xDB
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_1_10; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_1_10", `INIT_SOC_ANA_GEN_REG_1_10, {2'h0, `ANA_TOP.D2A_EEGLNA11_GAIN}, `MASK_SOC_ANA_GEN_REG_1_10);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_1_10", top_test_cfg.wr_data[i], {2'h0, `ANA_TOP.D2A_EEGLNA11_GAIN}, `MASK_SOC_ANA_GEN_REG_1_10);
    end

    // ---------------------
    // Register 0xDC
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_1_11; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_1_11", `INIT_SOC_ANA_GEN_REG_1_11, {2'h0, `ANA_TOP.D2A_EEGLNA12_GAIN}, `MASK_SOC_ANA_GEN_REG_1_11);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_1_11", top_test_cfg.wr_data[i], {2'h0, `ANA_TOP.D2A_EEGLNA12_GAIN}, `MASK_SOC_ANA_GEN_REG_1_11);
    end

    // ---------------------
    // Register 0xDD
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_1_12; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_1_12", `INIT_SOC_ANA_GEN_REG_1_12, {2'h0, `ANA_TOP.D2A_EEGLNA13_GAIN}, `MASK_SOC_ANA_GEN_REG_1_12);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_1_12", top_test_cfg.wr_data[i], {2'h0, `ANA_TOP.D2A_EEGLNA13_GAIN}, `MASK_SOC_ANA_GEN_REG_1_12);
    end

    // ---------------------
    // Register 0xDE
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_1_13; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_1_13", `INIT_SOC_ANA_GEN_REG_1_13, {`ANA_TOP.D2A_SPI_SPARE1}, `MASK_SOC_ANA_GEN_REG_1_13);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_1_13", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_SPI_SPARE1}, `MASK_SOC_ANA_GEN_REG_1_13);
    end

    // ---------------------
    // Register 0xDF
    // ---------------------
    // Writting into 0xC1 D2A_BIST_SEL and D2A_BIST_EN
    // ---------------------
     
    // Checking BIST = 10000 
    `nnc_info("Changing BIST_SEL", "Change BIST SEL", UVM_LOW);
    `WR_NORMAL_REG(`SOC_ANA_EN_REG_0_0, {2'h0, 5'b10000, 1'b1}, 8'h00);

    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_1_14; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_1_14", `INIT_SOC_ANA_GEN_REG_1_14, {`ANA_TOP.D2A_LOFF_ISEL_ADJ, `ANA_TOP.D2A_LOFF_IPOL, `ANA_TOP.D2A_LOFF_COMP_TH}, `MASK_SOC_ANA_GEN_REG_1_14);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_1_14", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_LOFF_ISEL_ADJ, `ANA_TOP.D2A_LOFF_IPOL, `ANA_TOP.D2A_LOFF_COMP_TH}, `MASK_SOC_ANA_GEN_REG_1_14);
    end
     
    // Checking BIST = 10001 
    `nnc_info("Changing BIST_SEL", "Change BIST SEL", UVM_LOW);
    `WR_NORMAL_REG(`SOC_ANA_EN_REG_0_0, {2'h0, 5'b10001, 1'b1}, 8'h00);

    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_1_14; n_write == 10;});     
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_1_14", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_LOFF_ISEL_ADJ, `ANA_TOP.D2A_LOFF_IPOL, `ANA_TOP.D2A_LOFF_COMP_TH}, `MASK_SOC_ANA_GEN_REG_1_14);
    end



    // ---------------------------------------------------------------------------------- 
    // ANA_GEN_REG_SECTION_2    
    `nnc_info("ANA_GEN_REG", "Changing ANA_GEN Section to 2\n", UVM_LOW);
    `WR_NORMAL_REG(`SOC_ANA_GEN_SECTION_SEL_REG, 8'h2, 8'h00);
    // ---------------------

    // ---------------------
    // Register 0xD1
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_2_0; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_2_0", `INIT_SOC_ANA_GEN_REG_2_0, {2'h0, `ANA_TOP.D2A_EEGLNA14_GAIN}, `MASK_SOC_ANA_GEN_REG_2_0);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_2_0", top_test_cfg.wr_data[i], {2'h0, `ANA_TOP.D2A_EEGLNA14_GAIN}, `MASK_SOC_ANA_GEN_REG_2_0);
    end

    // ---------------------
    // Register 0xD2
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_2_1; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_2_1", `INIT_SOC_ANA_GEN_REG_2_1, {2'h0, `ANA_TOP.D2A_EEGLNA15_GAIN}, `MASK_SOC_ANA_GEN_REG_2_1);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_2_1", top_test_cfg.wr_data[i], {2'h0, `ANA_TOP.D2A_EEGLNA15_GAIN}, `MASK_SOC_ANA_GEN_REG_2_1);
    end

    // ---------------------
    // Register 0xD3
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_2_2; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_2_2", `INIT_SOC_ANA_GEN_REG_2_2, {`ANA_TOP.D2A_EEGPGA0B_GAIN, `ANA_TOP.D2A_EEGPGA0A_GAIN}, `MASK_SOC_ANA_GEN_REG_2_2);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_2_2", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGPGA0B_GAIN, `ANA_TOP.D2A_EEGPGA0A_GAIN}, `MASK_SOC_ANA_GEN_REG_2_2);
    end

    // ---------------------
    // Register 0xD4
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_2_3; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_2_3", `INIT_SOC_ANA_GEN_REG_2_3, {`ANA_TOP.D2A_EEGPGA1B_GAIN, `ANA_TOP.D2A_EEGPGA1A_GAIN}, `MASK_SOC_ANA_GEN_REG_2_3);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_2_3", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGPGA1B_GAIN, `ANA_TOP.D2A_EEGPGA1A_GAIN}, `MASK_SOC_ANA_GEN_REG_2_3);
    end

    // ---------------------
    // Register 0xD5
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_2_4; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_2_4", `INIT_SOC_ANA_GEN_REG_2_4, {`ANA_TOP.D2A_EEGPGA2B_GAIN, `ANA_TOP.D2A_EEGPGA2A_GAIN}, `MASK_SOC_ANA_GEN_REG_2_4);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_2_4", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGPGA2B_GAIN, `ANA_TOP.D2A_EEGPGA2A_GAIN}, `MASK_SOC_ANA_GEN_REG_2_4);
    end

    // ---------------------
    // Register 0xD6
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_2_5; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_2_5", `INIT_SOC_ANA_GEN_REG_2_5, {`ANA_TOP.D2A_EEGPGA3B_GAIN, `ANA_TOP.D2A_EEGPGA3A_GAIN}, `MASK_SOC_ANA_GEN_REG_2_5);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_2_5", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGPGA3B_GAIN, `ANA_TOP.D2A_EEGPGA3A_GAIN}, `MASK_SOC_ANA_GEN_REG_2_5);
    end

    // ---------------------
    // Register 0xD7
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_2_6; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_2_6", `INIT_SOC_ANA_GEN_REG_2_6, {`ANA_TOP.D2A_EEGPGA4B_GAIN, `ANA_TOP.D2A_EEGPGA4A_GAIN}, `MASK_SOC_ANA_GEN_REG_2_6);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_2_6", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGPGA4B_GAIN, `ANA_TOP.D2A_EEGPGA4A_GAIN}, `MASK_SOC_ANA_GEN_REG_2_6);
    end

    // ---------------------
    // Register 0xD8
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_2_7; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_2_7", `INIT_SOC_ANA_GEN_REG_2_7, {`ANA_TOP.D2A_EEGPGA5B_GAIN, `ANA_TOP.D2A_EEGPGA5A_GAIN}, `MASK_SOC_ANA_GEN_REG_2_7);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_2_2", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGPGA5B_GAIN, `ANA_TOP.D2A_EEGPGA5A_GAIN}, `MASK_SOC_ANA_GEN_REG_2_7);
    end

    // ---------------------
    // Register 0xD9
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_2_8; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_2_8", `INIT_SOC_ANA_GEN_REG_2_8, {`ANA_TOP.D2A_EEGPGA6B_GAIN, `ANA_TOP.D2A_EEGPGA6A_GAIN}, `MASK_SOC_ANA_GEN_REG_2_8);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_2_8", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGPGA6B_GAIN, `ANA_TOP.D2A_EEGPGA6A_GAIN}, `MASK_SOC_ANA_GEN_REG_2_8);
    end

    // ---------------------
    // Register 0xDA
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_2_9; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_2_9", `INIT_SOC_ANA_GEN_REG_2_9, {`ANA_TOP.D2A_EEGPGA7B_GAIN, `ANA_TOP.D2A_EEGPGA7A_GAIN}, `MASK_SOC_ANA_GEN_REG_2_9);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_2_9", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGPGA7B_GAIN, `ANA_TOP.D2A_EEGPGA7A_GAIN}, `MASK_SOC_ANA_GEN_REG_2_9);
    end

    // ---------------------
    // Register 0xDB
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_2_10; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_2_10", `INIT_SOC_ANA_GEN_REG_2_10, {`ANA_TOP.D2A_EEGPGA9B_GAIN, `ANA_TOP.D2A_EEGPGA9A_GAIN}, `MASK_SOC_ANA_GEN_REG_2_10);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_2_10", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGPGA9B_GAIN, `ANA_TOP.D2A_EEGPGA9A_GAIN}, `MASK_SOC_ANA_GEN_REG_2_10);
    end

    // ---------------------
    // Register 0xDC
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_2_11; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_2_11", `INIT_SOC_ANA_GEN_REG_2_11, {`ANA_TOP.D2A_EEGPGA10B_GAIN, `ANA_TOP.D2A_EEGPGA10A_GAIN}, `MASK_SOC_ANA_GEN_REG_2_11);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_2_11", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGPGA10B_GAIN, `ANA_TOP.D2A_EEGPGA10A_GAIN}, `MASK_SOC_ANA_GEN_REG_2_11);
    end

    // ---------------------
    // Register 0xDD
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_2_12; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_2_12", `INIT_SOC_ANA_GEN_REG_2_12, {`ANA_TOP.D2A_EEGPGA11B_GAIN, `ANA_TOP.D2A_EEGPGA11A_GAIN}, `MASK_SOC_ANA_GEN_REG_2_12);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_2_12", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGPGA11B_GAIN, `ANA_TOP.D2A_EEGPGA11A_GAIN}, `MASK_SOC_ANA_GEN_REG_2_12);
    end

    // ---------------------
    // Register 0xDE
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_2_13; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_2_13", `INIT_SOC_ANA_GEN_REG_2_13, {`ANA_TOP.D2A_SPI_SPARE2}, `MASK_SOC_ANA_GEN_REG_2_13);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_2_13", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_SPI_SPARE2}, `MASK_SOC_ANA_GEN_REG_2_13);
    end

    // ---------------------
    // Register 0xDF
    // ---------------------
    // Writting into 0xC1 D2A_BIST_SEL and D2A_BIST_EN
    // ---------------------
    
    // Checking BIST = 10101
    `nnc_info("Changing BIST_SEL", "Change BIST SEL", UVM_LOW);
    `WR_NORMAL_REG(`SOC_ANA_EN_REG_0_0, {2'h0, 5'b10101, 1'b1}, 8'h00);

    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_2_14; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_2_14", `INIT_SOC_ANA_GEN_REG_2_14, {`ANA_TOP.D2A_EEGLNA8_IADJ, `ANA_TOP.D2A_EEGLNA8_GAIN}, `MASK_SOC_ANA_GEN_REG_2_14);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_2_14", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGLNA8_IADJ, `ANA_TOP.D2A_EEGLNA8_GAIN}, `MASK_SOC_ANA_GEN_REG_2_14);
    end
    
    // Checking BIST = 10110
    `nnc_info("Changing BIST_SEL", "Change BIST SEL", UVM_LOW);
    `WR_NORMAL_REG(`SOC_ANA_EN_REG_0_0, {2'h0, 5'b10110, 1'b1}, 8'h00);

    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_2_14; n_write == 10;});     
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_2_14", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGLNA8_IADJ, `ANA_TOP.D2A_EEGLNA8_GAIN}, `MASK_SOC_ANA_GEN_REG_2_14);
    end

    // ---------------------------------------------------------------------------------- 
    // ANA_GEN_REG_SECTION_3    
    `nnc_info("ANA_GEN_REG", "Changing ANA_GEN Section to 3\n", UVM_LOW);
    `WR_NORMAL_REG(`SOC_ANA_GEN_SECTION_SEL_REG, 8'h3, 8'h00);
    // ---------------------

    // ---------------------
    // Register 0xD1
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_3_0; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_3_0", `INIT_SOC_ANA_GEN_REG_3_0, {`ANA_TOP.D2A_EEGPGA12B_GAIN, `ANA_TOP.D2A_EEGPGA12A_GAIN}, `MASK_SOC_ANA_GEN_REG_3_0);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_3_0", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGPGA12B_GAIN, `ANA_TOP.D2A_EEGPGA12A_GAIN}, `MASK_SOC_ANA_GEN_REG_3_0);
    end

    // ---------------------
    // Register 0xD2
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_3_1; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_3_1", `INIT_SOC_ANA_GEN_REG_3_1, {`ANA_TOP.D2A_EEGPGA13B_GAIN, `ANA_TOP.D2A_EEGPGA13A_GAIN}, `MASK_SOC_ANA_GEN_REG_3_1);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_3_1", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGPGA13B_GAIN, `ANA_TOP.D2A_EEGPGA13A_GAIN}, `MASK_SOC_ANA_GEN_REG_3_1);
    end

    // ---------------------
    // Register 0xD3
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_3_2; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_3_2", `INIT_SOC_ANA_GEN_REG_3_2, {`ANA_TOP.D2A_EEGPGA14B_GAIN, `ANA_TOP.D2A_EEGPGA14A_GAIN}, `MASK_SOC_ANA_GEN_REG_3_2);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_3_2", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGPGA14B_GAIN, `ANA_TOP.D2A_EEGPGA14A_GAIN}, `MASK_SOC_ANA_GEN_REG_3_2);
    end

    // ---------------------
    // Register 0xD4
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_3_3; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_3_3", `INIT_SOC_ANA_GEN_REG_3_3, {`ANA_TOP.D2A_EEGPGA15B_GAIN, `ANA_TOP.D2A_EEGPGA15A_GAIN}, `MASK_SOC_ANA_GEN_REG_3_3);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_3_3", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGPGA15B_GAIN, `ANA_TOP.D2A_EEGPGA15A_GAIN}, `MASK_SOC_ANA_GEN_REG_3_3);
    end

    // ---------------------
    // Register 0xD5
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_3_4; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_3_4", `INIT_SOC_ANA_GEN_REG_3_4, {`ANA_TOP.D2A_EEGPGA0B_IADJ, `ANA_TOP.D2A_EEGPGA0A_IADJ}, `MASK_SOC_ANA_GEN_REG_3_4);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_3_4", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGPGA0B_IADJ, `ANA_TOP.D2A_EEGPGA0A_IADJ}, `MASK_SOC_ANA_GEN_REG_3_4);
    end

    // ---------------------
    // Register 0xD6
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_3_5; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_3_5", `INIT_SOC_ANA_GEN_REG_3_5, {`ANA_TOP.D2A_EEGPGA1B_IADJ, `ANA_TOP.D2A_EEGPGA1A_IADJ}, `MASK_SOC_ANA_GEN_REG_3_5);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_3_5", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGPGA1B_IADJ, `ANA_TOP.D2A_EEGPGA1A_IADJ}, `MASK_SOC_ANA_GEN_REG_3_5);
    end

    // ---------------------
    // Register 0xD7
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_3_6; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_3_6", `INIT_SOC_ANA_GEN_REG_3_6, {`ANA_TOP.D2A_EEGPGA2B_IADJ, `ANA_TOP.D2A_EEGPGA2A_IADJ}, `MASK_SOC_ANA_GEN_REG_3_6);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_3_6", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGPGA2B_IADJ, `ANA_TOP.D2A_EEGPGA2A_IADJ}, `MASK_SOC_ANA_GEN_REG_3_6);
    end

    // ---------------------
    // Register 0xD8
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_3_7; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_3_7", `INIT_SOC_ANA_GEN_REG_3_7, {`ANA_TOP.D2A_EEGPGA3B_IADJ, `ANA_TOP.D2A_EEGPGA3A_IADJ}, `MASK_SOC_ANA_GEN_REG_3_7);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_3_7", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGPGA3B_IADJ, `ANA_TOP.D2A_EEGPGA3A_IADJ}, `MASK_SOC_ANA_GEN_REG_3_7);
    end

    // ---------------------
    // Register 0xD9
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_3_8; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_3_8", `INIT_SOC_ANA_GEN_REG_3_8, {`ANA_TOP.D2A_EEGPGA4B_IADJ, `ANA_TOP.D2A_EEGPGA4A_IADJ}, `MASK_SOC_ANA_GEN_REG_3_8);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_3_8", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGPGA4B_IADJ, `ANA_TOP.D2A_EEGPGA4A_IADJ}, `MASK_SOC_ANA_GEN_REG_3_8);
    end

    // ---------------------
    // Register 0xDA
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_3_9; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_3_9", `INIT_SOC_ANA_GEN_REG_3_9, {`ANA_TOP.D2A_EEGPGA5B_IADJ, `ANA_TOP.D2A_EEGPGA5A_IADJ}, `MASK_SOC_ANA_GEN_REG_3_9);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_3_9", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGPGA5B_IADJ, `ANA_TOP.D2A_EEGPGA5A_IADJ}, `MASK_SOC_ANA_GEN_REG_3_9);
    end

    // ---------------------
    // Register 0xDB
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_3_10; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_3_10", `INIT_SOC_ANA_GEN_REG_3_10, {`ANA_TOP.D2A_EEGPGA6B_IADJ, `ANA_TOP.D2A_EEGPGA6A_IADJ}, `MASK_SOC_ANA_GEN_REG_3_10);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_3_10", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGPGA6B_IADJ, `ANA_TOP.D2A_EEGPGA6A_IADJ}, `MASK_SOC_ANA_GEN_REG_3_10);
    end

    // ---------------------
    // Register 0xDC
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_3_11; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_3_11", `INIT_SOC_ANA_GEN_REG_3_11, {`ANA_TOP.D2A_EEGPGA7B_IADJ, `ANA_TOP.D2A_EEGPGA7A_IADJ}, `MASK_SOC_ANA_GEN_REG_3_11);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_3_11", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGPGA7B_IADJ, `ANA_TOP.D2A_EEGPGA7A_IADJ}, `MASK_SOC_ANA_GEN_REG_3_11);
    end

    // ---------------------
    // Register 0xDD
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_3_12; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_3_12", `INIT_SOC_ANA_GEN_REG_3_12, {`ANA_TOP.D2A_EEGPGA8B_IADJ, `ANA_TOP.D2A_EEGPGA8A_IADJ}, `MASK_SOC_ANA_GEN_REG_3_12);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_3_12", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGPGA8B_IADJ, `ANA_TOP.D2A_EEGPGA8A_IADJ}, `MASK_SOC_ANA_GEN_REG_3_12);
    end

    // ---------------------
    // Register 0xDE
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_3_13; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_3_13", `INIT_SOC_ANA_GEN_REG_3_13, {`ANA_TOP.D2A_SPI_SPARE3}, `MASK_SOC_ANA_GEN_REG_3_13);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_3_13", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_SPI_SPARE3}, `MASK_SOC_ANA_GEN_REG_3_13);
    end

    // ---------------------
    // Register 0xDF
    // ---------------------
    // Writting into 0xC1 D2A_BIST_SEL and D2A_BIST_EN
    // ---------------------
     
    // Checking BIST = 10111 
    `nnc_info("Changing BIST_SEL", "Change BIST SEL", UVM_LOW);
    `WR_NORMAL_REG(`SOC_ANA_EN_REG_0_0, {2'h0, 5'b10111, 1'b1}, 8'h00);

    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_3_14; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_3_14", `INIT_SOC_ANA_GEN_REG_3_14, {`ANA_TOP.D2A_EEGPGA8B_GAIN, `ANA_TOP.D2A_EEGPGA8A_GAIN}, `MASK_SOC_ANA_GEN_REG_3_14);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_3_14", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGPGA8B_GAIN, `ANA_TOP.D2A_EEGPGA8A_GAIN}, `MASK_SOC_ANA_GEN_REG_3_14);
    end
     
    // Checking BIST = 11000 
    `nnc_info("Changing BIST_SEL", "Change BIST SEL", UVM_LOW);
    `WR_NORMAL_REG(`SOC_ANA_EN_REG_0_0, {2'h0, 5'b11000, 1'b1}, 8'h00);

    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_3_14; n_write == 10;});     
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_3_14", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGPGA8B_GAIN, `ANA_TOP.D2A_EEGPGA8A_GAIN}, `MASK_SOC_ANA_GEN_REG_3_14);
    end

    // ---------------------------------------------------------------------------------- 
    // ANA_GEN_REG_SECTION_4    
    `nnc_info("ANA_GEN_REG", "Changing ANA_GEN Section to 4\n", UVM_LOW);
    `WR_NORMAL_REG(`SOC_ANA_GEN_SECTION_SEL_REG, 8'h4, 8'h00);
    // ---------------------

    // ---------------------
    // Register 0xD1
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_4_0; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_4_0", `INIT_SOC_ANA_GEN_REG_4_0, {`ANA_TOP.D2A_EEGPGA9B_IADJ, `ANA_TOP.D2A_EEGPGA9A_IADJ}, `MASK_SOC_ANA_GEN_REG_4_0);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_4_0", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGPGA9B_IADJ, `ANA_TOP.D2A_EEGPGA9A_IADJ}, `MASK_SOC_ANA_GEN_REG_4_0);
    end

    // ---------------------
    // Register 0xD2
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_4_1; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_4_1", `INIT_SOC_ANA_GEN_REG_4_1, {`ANA_TOP.D2A_EEGPGA10B_IADJ, `ANA_TOP.D2A_EEGPGA10A_IADJ}, `MASK_SOC_ANA_GEN_REG_4_1);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_4_1", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGPGA10B_IADJ, `ANA_TOP.D2A_EEGPGA10A_IADJ}, `MASK_SOC_ANA_GEN_REG_4_1);
    end

    // ---------------------
    // Register 0xD3
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_4_2; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_4_2", `INIT_SOC_ANA_GEN_REG_4_2, {`ANA_TOP.D2A_EEGPGA11B_IADJ, `ANA_TOP.D2A_EEGPGA11A_IADJ}, `MASK_SOC_ANA_GEN_REG_4_2);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_4_2", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGPGA11B_IADJ, `ANA_TOP.D2A_EEGPGA11A_IADJ}, `MASK_SOC_ANA_GEN_REG_4_2);
    end

    // ---------------------
    // Register 0xD4
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_4_3; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_4_3", `INIT_SOC_ANA_GEN_REG_4_3, {`ANA_TOP.D2A_EEGPGA12B_IADJ, `ANA_TOP.D2A_EEGPGA12A_IADJ}, `MASK_SOC_ANA_GEN_REG_4_3);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_4_3", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGPGA12B_IADJ, `ANA_TOP.D2A_EEGPGA12A_IADJ}, `MASK_SOC_ANA_GEN_REG_4_3);
    end

    // ---------------------
    // Register 0xD5
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_4_4; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_4_4", `INIT_SOC_ANA_GEN_REG_4_4, {`ANA_TOP.D2A_EEGPGA13B_IADJ, `ANA_TOP.D2A_EEGPGA13A_IADJ}, `MASK_SOC_ANA_GEN_REG_4_4);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_4_4", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGPGA13B_IADJ, `ANA_TOP.D2A_EEGPGA13A_IADJ}, `MASK_SOC_ANA_GEN_REG_4_4);
    end

    // ---------------------
    // Register 0xD6
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_4_5; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_4_5", `INIT_SOC_ANA_GEN_REG_4_5, {`ANA_TOP.D2A_EEGPGA14B_IADJ, `ANA_TOP.D2A_EEGPGA14A_IADJ}, `MASK_SOC_ANA_GEN_REG_4_5);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_4_5", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGPGA14B_IADJ, `ANA_TOP.D2A_EEGPGA14A_IADJ}, `MASK_SOC_ANA_GEN_REG_4_5);
    end

    // ---------------------
    // Register 0xD7
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_4_6; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_4_6", `INIT_SOC_ANA_GEN_REG_4_6, {`ANA_TOP.D2A_EEGPGA15B_IADJ, `ANA_TOP.D2A_EEGPGA15A_IADJ}, `MASK_SOC_ANA_GEN_REG_4_6);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_4_6", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGPGA15B_IADJ, `ANA_TOP.D2A_EEGPGA15A_IADJ}, `MASK_SOC_ANA_GEN_REG_4_6);
    end

    // ---------------------
    // Register 0xD8
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_4_7; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_4_7", `INIT_SOC_ANA_GEN_REG_4_7, {8'h00}, `MASK_SOC_ANA_GEN_REG_4_7);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_4_7", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_4_7);
    end


    // ---------------------
    // Register 0xD9
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_4_8; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_4_8", `INIT_SOC_ANA_GEN_REG_4_8, {8'h00}, `MASK_SOC_ANA_GEN_REG_4_8);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_4_8", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_4_8);
    end

    // ---------------------
    // Register 0xDA
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_4_9; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_4_9", `INIT_SOC_ANA_GEN_REG_4_9, {8'h00}, `MASK_SOC_ANA_GEN_REG_4_9);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_4_9", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_4_9);
    end

    // ---------------------
    // Register 0xDB
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_4_10; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_4_10", `INIT_SOC_ANA_GEN_REG_4_10, {8'h00}, `MASK_SOC_ANA_GEN_REG_4_10);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_4_10", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_4_10);
    end

    // ---------------------
    // Register 0xDC
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_4_11; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_4_11", `INIT_SOC_ANA_GEN_REG_4_11, {8'h00}, `MASK_SOC_ANA_GEN_REG_4_11);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_4_11", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_4_11);
    end

    // ---------------------
    // Register 0xDD
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_4_12; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_4_12", `INIT_SOC_ANA_GEN_REG_4_12, {8'h00}, `MASK_SOC_ANA_GEN_REG_4_12);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_4_12", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_4_12);
    end

    // ---------------------
    // Register 0xDE
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_4_13; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_4_13", `INIT_SOC_ANA_GEN_REG_4_13, {8'h00}, `MASK_SOC_ANA_GEN_REG_4_13);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_4_13", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_4_13);
    end

    // ---------------------
    // Register 0xDF
    // ---------------------
    // Writting into 0xC1 D2A_BIST_SEL and D2A_BIST_EN
    // ---------------------
      
    `nnc_info("Changing BIST_SEL", "Change BIST SEL", UVM_LOW);
    `WR_NORMAL_REG(`SOC_ANA_EN_REG_0_0, {2'h0, 5'b11001, 1'b1}, 8'h00);

    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_4_14; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_4_14", `INIT_SOC_ANA_GEN_REG_4_14, {`ANA_TOP.D2A_VCMGENBUFF_IADJ}, `MASK_SOC_ANA_GEN_REG_4_14);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_4_14", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_VCMGENBUFF_IADJ}, `MASK_SOC_ANA_GEN_REG_4_14);
    end


    // ---------------------------------------------------------------------------------- 
    // ANA_GEN_REG_SECTION_5   
    `nnc_info("ANA_GEN_REG", "Changing ANA_GEN Section to 5\n", UVM_LOW);
    `WR_NORMAL_REG(`SOC_ANA_GEN_SECTION_SEL_REG, 8'h5, 8'h00);
    // ---------------------
    
    // ---------------------
    // Register 0xD1
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_5_0; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_5_0", `INIT_SOC_ANA_GEN_REG_5_0, {8'h00}, `MASK_SOC_ANA_GEN_REG_5_0);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_5_0", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_5_0);
    end

    // ---------------------
    // Register 0xD2
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_5_1; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_5_1", `INIT_SOC_ANA_GEN_REG_5_1, {8'h00}, `MASK_SOC_ANA_GEN_REG_5_1);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_5_1", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_5_1);
    end

    // ---------------------
    // Register 0xD3
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_5_2; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_5_2", `INIT_SOC_ANA_GEN_REG_5_2, {8'h00}, `MASK_SOC_ANA_GEN_REG_5_2);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_5_2", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_5_2);
    end

    // ---------------------
    // Register 0xD4
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_5_3; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_5_3", `INIT_SOC_ANA_GEN_REG_5_3, {8'h00}, `MASK_SOC_ANA_GEN_REG_5_3);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_5_3", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_5_3);
    end

    // ---------------------
    // Register 0xD5
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_5_4; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_5_4", `INIT_SOC_ANA_GEN_REG_5_4, {8'h00}, `MASK_SOC_ANA_GEN_REG_5_4);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_5_4", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_5_4);
    end

    // ---------------------
    // Register 0xD6
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_5_5; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_5_5", `INIT_SOC_ANA_GEN_REG_5_5, {8'h00}, `MASK_SOC_ANA_GEN_REG_5_5);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_5_5", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_5_5);
    end

    // ---------------------
    // Register 0xD7
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_5_6; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_5_6", `INIT_SOC_ANA_GEN_REG_5_6, {8'h00}, `MASK_SOC_ANA_GEN_REG_5_6);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_5_6", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_5_6);
    end

    // ---------------------
    // Register 0xD8
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_5_7; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_5_7", `INIT_SOC_ANA_GEN_REG_5_7, {8'h00}, `MASK_SOC_ANA_GEN_REG_5_7);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_5_7", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_5_7);
    end
    
    // ---------------------
    // Register 0xD9
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_5_8; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_5_8", `INIT_SOC_ANA_GEN_REG_5_8, {8'h00}, `MASK_SOC_ANA_GEN_REG_5_8);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_5_8", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_5_8);
    end

    // ---------------------
    // Register 0xDA
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_5_9; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_5_9", `INIT_SOC_ANA_GEN_REG_5_9, {8'h00}, `MASK_SOC_ANA_GEN_REG_5_9);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_5_9", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_5_9);
    end

    // ---------------------
    // Register 0xDB
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_5_10; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_5_10", `INIT_SOC_ANA_GEN_REG_5_10, {8'h00}, `MASK_SOC_ANA_GEN_REG_5_10);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_5_10", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_5_10);
    end

    // ---------------------
    // Register 0xDC
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_5_11; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_5_11", `INIT_SOC_ANA_GEN_REG_5_11, {8'h00}, `MASK_SOC_ANA_GEN_REG_5_11);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_5_11", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_5_11);
    end

    // ---------------------
    // Register 0xDD
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_5_12; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_5_12", `INIT_SOC_ANA_GEN_REG_5_12, {8'h00}, `MASK_SOC_ANA_GEN_REG_5_12);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_5_12", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_5_12);
    end

    // ---------------------
    // Register 0xDE
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_5_13; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_5_13", `INIT_SOC_ANA_GEN_REG_5_13, {8'h00}, `MASK_SOC_ANA_GEN_REG_5_13);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_5_13", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_5_13);
    end

    // ---------------------
    // Register 0xDF
    // ---------------------
    // Writting into 0xC1 D2A_BIST_SEL and D2A_BIST_EN
    // ---------------------
      
    `nnc_info("Changing BIST_SEL", "Change BIST SEL", UVM_LOW);
    `WR_NORMAL_REG(`SOC_ANA_EN_REG_0_0, {2'h0, 5'b11010, 1'b1}, 8'h00);

    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_5_14; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_5_14", `INIT_SOC_ANA_GEN_REG_5_14, { `ANA_TOP.D2A_SDMVCMBUFF_SEL, `ANA_TOP.D2A_SDMVCMBUFF_IADJ}, `MASK_SOC_ANA_GEN_REG_5_14);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_5_14", top_test_cfg.wr_data[i], { `ANA_TOP.D2A_SDMVCMBUFF_SEL, `ANA_TOP.D2A_SDMVCMBUFF_IADJ}, `MASK_SOC_ANA_GEN_REG_5_14);
    end

    // ---------------------------------------------------------------------------------- 
    // ANA_GEN_REG_SECTION_6   
    `nnc_info("ANA_GEN_REG", "Changing ANA_GEN Section to 6\n", UVM_LOW);
    `WR_NORMAL_REG(`SOC_ANA_GEN_SECTION_SEL_REG, 8'h6, 8'h00);
    // ---------------------
    // ---------------------

    // Register 0xD1
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_6_0; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_6_0", `INIT_SOC_ANA_GEN_REG_6_0, {8'h00}, `MASK_SOC_ANA_GEN_REG_6_0);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_6_0", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_6_0);
    end

    // ---------------------
    // Register 0xD2
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_6_1; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_6_1", `INIT_SOC_ANA_GEN_REG_6_1, {8'h00}, `MASK_SOC_ANA_GEN_REG_6_1);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_6_1", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_6_1);
    end

    // ---------------------
    // Register 0xD3
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_6_2; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_6_2", `INIT_SOC_ANA_GEN_REG_6_2, {8'h00}, `MASK_SOC_ANA_GEN_REG_6_2);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_6_2", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_6_2);
    end

    // ---------------------
    // Register 0xD4
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_6_3; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_6_3", `INIT_SOC_ANA_GEN_REG_6_3, {8'h00}, `MASK_SOC_ANA_GEN_REG_6_3);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_6_3", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_6_3);
    end

    // ---------------------
    // Register 0xD5
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_6_4; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_6_4", `INIT_SOC_ANA_GEN_REG_6_4, {8'h00}, `MASK_SOC_ANA_GEN_REG_6_4);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_6_4", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_6_4);
    end

    // ---------------------
    // Register 0xD6
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_6_5; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_6_5", `INIT_SOC_ANA_GEN_REG_6_5, {8'h00}, `MASK_SOC_ANA_GEN_REG_6_5);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_6_5", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_6_5);
    end

    // ---------------------
    // Register 0xD7
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_6_6; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_6_6", `INIT_SOC_ANA_GEN_REG_6_6, {8'h00}, `MASK_SOC_ANA_GEN_REG_6_6);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_6_6", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_6_6);
    end

    // ---------------------
    // Register 0xD8
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_6_7; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_6_7", `INIT_SOC_ANA_GEN_REG_6_7, {8'h00}, `MASK_SOC_ANA_GEN_REG_6_7);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_6_2", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_6_7);
    end
    
    // ---------------------
    // Register 0xD9
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_6_8; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_6_8", `INIT_SOC_ANA_GEN_REG_6_8, {8'h00}, `MASK_SOC_ANA_GEN_REG_6_8);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_6_8", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_6_8);
    end

    // ---------------------
    // Register 0xDA
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_6_9; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_6_9", `INIT_SOC_ANA_GEN_REG_6_9, {`ANA_TOP.D2A_DRIVERC_SHORT_DET_VINSEL[3:0], `ANA_TOP.D2A_DRIVERC_LEAD_OFF_INSEL}, `MASK_SOC_ANA_GEN_REG_6_9);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_6_9", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_DRIVERC_SHORT_DET_VINSEL[3:0], `ANA_TOP.D2A_DRIVERC_LEAD_OFF_INSEL}, `MASK_SOC_ANA_GEN_REG_6_9);
    end

    // ---------------------
    // Register 0xDB
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_6_10; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_6_10", `INIT_SOC_ANA_GEN_REG_6_10, {2'h0, `ANA_TOP.D2A_DRIVERC_SHORT_DET_VIPSEL, `ANA_TOP.D2A_DRIVERC_SHORT_DET_VINSEL[4]}, `MASK_SOC_ANA_GEN_REG_6_10);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_6_10", top_test_cfg.wr_data[i], {2'h0, `ANA_TOP.D2A_DRIVERC_SHORT_DET_VIPSEL, `ANA_TOP.D2A_DRIVERC_SHORT_DET_VINSEL[4]}, `MASK_SOC_ANA_GEN_REG_6_10);
    end

    // ---------------------
    // Register 0xDC
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_6_11; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_6_11", `INIT_SOC_ANA_GEN_REG_6_11, {`ANA_TOP.D2A_EEGPGA7B_IADJ, `ANA_TOP.D2A_EEGPGA7A_IADJ}, `MASK_SOC_ANA_GEN_REG_6_11);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_6_11", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGPGA7B_IADJ, `ANA_TOP.D2A_EEGPGA7A_IADJ}, `MASK_SOC_ANA_GEN_REG_6_11);
    end

    // ---------------------
    // Register 0xDD
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_6_12; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_6_12", `INIT_SOC_ANA_GEN_REG_6_12, {`ANA_TOP.D2A_EEGPGA8B_IADJ, `ANA_TOP.D2A_EEGPGA8A_IADJ}, `MASK_SOC_ANA_GEN_REG_6_12);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_6_12", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_EEGPGA8B_IADJ, `ANA_TOP.D2A_EEGPGA8A_IADJ}, `MASK_SOC_ANA_GEN_REG_6_12);
    end

    // ---------------------
    // Register 0xDE
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_6_13; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_6_13", `INIT_SOC_ANA_GEN_REG_6_13, {8'h00}, `MASK_SOC_ANA_GEN_REG_6_13);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_6_13", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_6_13);
    end

    // ---------------------
    // Register 0xDF
    // ---------------------
    // Writting into 0xC1 D2A_BIST_SEL and D2A_BIST_EN
    // ---------------------
    
    `nnc_info("Changing BIST_SEL", "Change BIST SEL", UVM_LOW);
    `WR_NORMAL_REG(`SOC_ANA_EN_REG_0_0, {2'h0, 5'b11011, 1'b1}, 8'h00);

    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_6_14; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_6_14", `INIT_SOC_ANA_GEN_REG_6_14, {`ANA_TOP.D2A_SDMVREFP_SEL, `ANA_TOP.D2A_SDMVREFP_IADJ}, `MASK_SOC_ANA_GEN_REG_6_14);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_6_14", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_SDMVREFP_SEL, `ANA_TOP.D2A_SDMVREFP_IADJ}, `MASK_SOC_ANA_GEN_REG_6_14);
    end

    // ---------------------------------------------------------------------------------- 
    // ANA_GEN_REG_SECTION_7   
    `nnc_info("ANA_GEN_REG", "Changing ANA_GEN Section to 7\n", UVM_LOW);
    `WR_NORMAL_REG(`SOC_ANA_GEN_SECTION_SEL_REG, 8'h7, 8'h00);
    // ---------------------
    
    // ---------------------
    // Register 0xD1
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_7_0; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_7_0", `INIT_SOC_ANA_GEN_REG_7_0, {8'h00}, `MASK_SOC_ANA_GEN_REG_7_0);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_7_0", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_7_0);
    end
    
    // ---------------------
    // Register 0xD2
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_7_1; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_7_1", `INIT_SOC_ANA_GEN_REG_7_1, {8'h00}, `MASK_SOC_ANA_GEN_REG_7_1);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_7_1", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_7_1);
    end
    
    // ---------------------
    // Register 0xD3
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_7_2; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_7_2", `INIT_SOC_ANA_GEN_REG_7_2, {8'h00}, `MASK_SOC_ANA_GEN_REG_7_2);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_7_2", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_7_2);
    end
    
    // ---------------------
    // Register 0xD4
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_7_3; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_7_3", `INIT_SOC_ANA_GEN_REG_7_3, {8'h00}, `MASK_SOC_ANA_GEN_REG_7_3);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_7_3", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_7_3);
    end
    
    // ---------------------
    // Register 0xD5
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_7_4; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_7_4", `INIT_SOC_ANA_GEN_REG_7_4, {8'h00}, `MASK_SOC_ANA_GEN_REG_7_4);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_7_4", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_7_4);
    end
    
    // ---------------------
    // Register 0xD6
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_7_5; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_7_5", `INIT_SOC_ANA_GEN_REG_7_5, {8'h00}, `MASK_SOC_ANA_GEN_REG_7_5);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_7_5", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_7_5);
    end
    
    // ---------------------
    // Register 0x7
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_7_6; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_7_6", `INIT_SOC_ANA_GEN_REG_7_6, {8'h00}, `MASK_SOC_ANA_GEN_REG_7_6);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_7_6", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_7_6);
    end
    
    // ---------------------
    // Register 0xD8
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_7_7; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_7_7", `INIT_SOC_ANA_GEN_REG_7_7, {8'h00}, `MASK_SOC_ANA_GEN_REG_7_7);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_7_7", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_7_7);
    end
    
    // ---------------------
    // Register 0xD9
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_7_8; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_7_8", `INIT_SOC_ANA_GEN_REG_7_8, {8'h00}, `MASK_SOC_ANA_GEN_REG_7_8);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_7_8", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_7_8);
    end
    
    // ---------------------
    // Register 0xDA
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_7_9; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_7_9", `INIT_SOC_ANA_GEN_REG_7_9, {8'h00}, `MASK_SOC_ANA_GEN_REG_7_9);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_7_9", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_7_9);
    end
    
    // ---------------------
    // Register 0xDB
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_7_10; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_7_10", `INIT_SOC_ANA_GEN_REG_7_10, {8'h00}, `MASK_SOC_ANA_GEN_REG_7_10);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_7_10", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_7_10);
    end
    
    // ---------------------
    // Register 0xDC
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_7_11; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_7_11", `INIT_SOC_ANA_GEN_REG_7_11, {8'h00}, `MASK_SOC_ANA_GEN_REG_7_11);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_7_11", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_7_11);
    end
    
    // ---------------------
    // Register 0xDD
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_7_12; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_7_12", `INIT_SOC_ANA_GEN_REG_7_12, {8'h00}, `MASK_SOC_ANA_GEN_REG_7_12);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_7_12", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_7_12);
    end
    
    // ---------------------
    // Register 0xDE
    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_7_13; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_7_13", `INIT_SOC_ANA_GEN_REG_7_13, {8'h00}, `MASK_SOC_ANA_GEN_REG_7_13);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_7_13", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_ANA_GEN_REG_7_13);
    end

    // ---------------------
    // Register 0xDF
    // ---------------------
    // Writting into 0xC1 D2A_BIST_SEL and D2A_BIST_EN
    // ---------------------
      
    `WR_NORMAL_REG(`SOC_ANA_EN_REG_0_0, {2'h0, 5'b11100, 1'b1}, 8'h00);

    // ---------------------
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_GEN_REG_7_14; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_ANA_GEN_REG_7_14", `INIT_SOC_ANA_GEN_REG_7_14, {`ANA_TOP.D2A_RLD_IADJ}, `MASK_SOC_ANA_GEN_REG_7_14);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_ANA_GEN_REG_7_14", top_test_cfg.wr_data[i], {`ANA_TOP.D2A_RLD_IADJ}, `MASK_SOC_ANA_GEN_REG_7_14);
    end
    
    // ---------------------
    // Register 0xA0
    // ---------------------
      
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_A2D_ANA_GEN_REG_0; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_A2D_ANA_GEN_REG_0", `INIT_SOC_A2D_ANA_GEN_REG_0, {4'h0, `ANA_TOP.A2D_DRIVERC_SHORT_DET_OUT, `ANA_TOP.A2D_DRIVERC_LEAD_OFF_OUT, `ANA_TOP.A2D_TSC_COMP_OUT, `ANA_TOP.A2D_LVD}, `MASK_SOC_A2D_ANA_GEN_REG_0);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_A2D_ANA_GEN_REG_0", top_test_cfg.wr_data[i], {4'h0, `ANA_TOP.A2D_DRIVERC_SHORT_DET_OUT, `ANA_TOP.A2D_DRIVERC_LEAD_OFF_OUT, `ANA_TOP.A2D_TSC_COMP_OUT, `ANA_TOP.A2D_LVD}, `MASK_SOC_A2D_ANA_GEN_REG_0);
    end

    // ---------------------
    // Register 0xA1
    // ---------------------
      
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_A2D_ANA_GEN_REG_1; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_A2D_ANA_GEN_REG_1", `INIT_SOC_A2D_ANA_GEN_REG_1, {`ANA_TOP.A2D_LOFF_STATP[7:0]}, `MASK_SOC_A2D_ANA_GEN_REG_1);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_A2D_ANA_GEN_REG_1", top_test_cfg.wr_data[i], {`ANA_TOP.A2D_LOFF_STATP}, `MASK_SOC_A2D_ANA_GEN_REG_1);
    end

    // ---------------------
    // Register 0xA2
    // ---------------------
      
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_A2D_ANA_GEN_REG_2; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_A2D_ANA_GEN_REG_2", `INIT_SOC_A2D_ANA_GEN_REG_2, {`ANA_TOP.A2D_LOFF_STATP[15:8]}, `MASK_SOC_A2D_ANA_GEN_REG_2);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_A2D_ANA_GEN_REG_2", top_test_cfg.wr_data[i], {`ANA_TOP.A2D_LOFF_STATP}, `MASK_SOC_A2D_ANA_GEN_REG_2);
    end

    // ---------------------
    // Register 0xA3
    // ---------------------
      
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_A2D_ANA_GEN_REG_3; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_A2D_ANA_GEN_REG_3", `INIT_SOC_A2D_ANA_GEN_REG_3, {`ANA_TOP.A2D_LOFF_STATN[7:0]}, `MASK_SOC_A2D_ANA_GEN_REG_3);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_A2D_ANA_GEN_REG_3", top_test_cfg.wr_data[i], {`ANA_TOP.A2D_LOFF_STATN[7:0]}, `MASK_SOC_A2D_ANA_GEN_REG_3);
    end
    
    // ---------------------
    // Register 0xA4
    // ---------------------
      
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_A2D_ANA_GEN_REG_4; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_A2D_ANA_GEN_REG_4", `INIT_SOC_A2D_ANA_GEN_REG_4, {`ANA_TOP.A2D_LOFF_STATN[15:8]}, `MASK_SOC_A2D_ANA_GEN_REG_4);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_A2D_ANA_GEN_REG_4", top_test_cfg.wr_data[i], {`ANA_TOP.A2D_LOFF_STATN[15:8]}, `MASK_SOC_A2D_ANA_GEN_REG_4);
    end
    
    // ---------------------
    // Register 0xA5
    // ---------------------
      
     assert(top_test_cfg.randomize() with {reg_addr == `SOC_A2D_ANA_GEN_REG_5; n_write == 10;});     
    // Cheking Default
    compare_start("SOC_A2D_ANA_GEN_REG_5", `INIT_SOC_A2D_ANA_GEN_REG_5, {8'h00}, `MASK_SOC_A2D_ANA_GEN_REG_3);
    `nnc_info("Default", "Checking Default Done", UVM_LOW);
    // Cheking After Write
    for (int i=0; i<top_test_cfg.n_write; i++) begin
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[i], 8'h00);
    compare_start("SOC_A2D_ANA_GEN_REG_3", top_test_cfg.wr_data[i], {8'h00}, `MASK_SOC_A2D_ANA_GEN_REG_3);
    end
    
    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    #10000ns;
    `nnc_info("SOC_TEST", "soc_ana_reg_to_ana_top_test end now", NNC_LOW)

    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ==================================================================================

    phase.drop_objection(this);
  endtask: main_phase

// =============================================
// Function Compare
// =============================================
task compare_start;
  input string      name; 
  input logic [7:0] real_data;
  input logic [7:0] expected_data;
  input logic [7:0] mask;

  begin
    `nnc_info("ANA_CONN", $sformatf("Under Checking ANA Interface and REG: %s", name), NNC_LOW)

    if ((real_data & mask) !== (expected_data & mask)) begin
      `nnc_info("Check", $sformatf("Name: %s, Mismatch comparison: MASK=0x%h, EXPECTED_DATA=0x%0h, ACTUAL_DATA=0x%0h", name, mask, expected_data, real_data), UVM_LOW)
      `nnc_error("ANA_CONN", $sformatf("Name: %s, Mismatch comparison: MASK=0x%h, EXPECTED_DATA=0x%0h, ACTUAL_DATA=0x%0h", name, mask, expected_data & mask, real_data & mask))
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
