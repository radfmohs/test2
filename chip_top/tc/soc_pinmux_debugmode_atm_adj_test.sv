/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_pinmux_debugmode_atm_adj_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_pinmux_debugmode_atm_adj_test                                             
// Designer	: thnguyen@nanochap.com                                                                 
// Date		: 18-05-2026                                                                     
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/
 
// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_pinmux_debugmode_atm_adj_test
`define TESTCFG soc_pinmux_debugmode_atm_adj_test_cfg
 
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
  logic [29:0] atm;
  logic [7:0]  save_adj_val[14:0];
 
  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================
 
  function new (string name = "soc_pinmux_debugmode_atm_adj_test_cfg");
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
 
  constraint c_ext_clk_en             { ext_clk_en == 1;}
 
  constraint c_hfosc_fixed_gnd_en     { hfosc_fixed_gnd_en == ext_clk_en;}          
 
  constraint c_ext_hfosc_fixed_gnd_en { ext_hfosc_fixed_gnd_en == !ext_clk_en;}
 
/*  constraint c_pinmux_mode { soft pinmux_mode == 1'b0; }
 
  constraint c_io_model_check_off { io_model_check_off == 1'b1; }  
 
  constraint c_ext_clk_en             { ext_clk_en == 1;}
 
*/
 
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
 
    `DUT_IF.ext_clk_en = top_test_cfg.ext_clk_en;	
 
    `DUT_IF.hfosc_fixed_gnd_en = top_test_cfg.hfosc_fixed_gnd_en;       
 
    `DUT_IF.ext_hfosc_fixed_gnd_en = top_test_cfg.ext_hfosc_fixed_gnd_en;
 
/*
    `DUT_IF.pinmux_mode = top_test_cfg.pinmux_mode;
 
    `DUT_IF.ext_clk_en = top_test_cfg.ext_clk_en;			  
*/
 
    // -------------------
    // Scoreboard enables
    // -------------------
    // `FLASH_SCOREBOARD_EN = 1;
    // `SPIM_SCOREBOARD_EN = 1;
    // `ANALOG_SCOREBOARD_EN = 1;
    // `IMEAS_SCOREBOARD_EN = 1;
    // `CLKRST_SCOREBOARD_EN = 1;
/*
    `SPI_SCB_EN = 1'b0;
    `ANALOG_SCOREBOARD_EN = 1'b1;
    `PINMUX_SCOREBOARD_EN = 1'b0; */
 
    phase.drop_objection(this);
  endtask : pre_reset_phase
 
  // -----------------------------------------
  // Declare the main_phase task of your test
  // -----------------------------------------
  virtual task main_phase(nnc_phase phase);
    phase.raise_objection(this);
    super.main_phase(phase);
 
    `nnc_info("SOC_TEST", "soc_pinmux_debugmode_atm_adj_test start", NNC_LOW)
 
    // ==================================================================================
    // Please add your code of your test here
    // ---------------------------------------------------------------------------------- 
/*
    `DUT_IF.pinmux_mode = 1;
    `DUT_IF.io_model_check_off = 1;     
    `DUT_IF.otp_ignore_check_en = 1; */
    // ATM15
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b01111;
    force `SOC_TB.ext_resetn = 1'b0;
    `DUT_IF.testmode_sel = 2'b11;     
    #10000;
    force `ANA_TOP.A2D_POR = 1'b1;
    force `ANA_TOP.A2D_CLK8MHZ = 1'b0;
    #100000;
    force `SOC_TB.ext_resetn = 1'b1;
 
   `PINMUX_SCOREBOARD_EN = 1'b1;
 
    #1ms;
    if(`DIG_TOP.u_pinmux.ATM15 !== 1'b1)
      `nnc_error("ATM15", $sformatf("ATM[15] = %b is not as expectation of 1'b1", `DIG_TOP.u_pinmux.ATM15));
 
   force {`SOC_TOP.IOBUF_PAD[8:1]} = $random;
   #10000ns;
   top_test_cfg.save_adj_val[0] = `SOC_TOP.IOBUF_PAD[8:1]; 
    // ATM16
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b10000;
    //force `SOC_TB.ext_resetn = 1'b0;
    #10000;
    //force `SOC_TB.ext_resetn = 1'b1;
    #1ms
    if(`DIG_TOP.u_pinmux.ATM16 !== 1'b1)
      `nnc_error("ATM16", $sformatf("ATM[16] = %b is not as expectation of 1'b1", `DIG_TOP.u_pinmux.ATM16));
   force {`SOC_TOP.IOBUF_PAD[8:1]} = $random;
   #10000ns;
   checkers("atm16", `SPI_REG.ana_gen_reg[0][14], top_test_cfg.save_adj_val[0]);
   top_test_cfg.save_adj_val[1] = `SOC_TOP.IOBUF_PAD[8:1];
 
    // ATM17
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b10001;
    //force `SOC_TB.ext_resetn = 1'b0;
    #10000;
    //force `SOC_TB.ext_resetn = 1'b1;
    #1ms
    if(`DIG_TOP.u_pinmux.ATM17 !== 1'b1)
      `nnc_error("ATM17", $sformatf("ATM[17] = %b is not as expectation of 1'b1", `DIG_TOP.u_pinmux.ATM17));
   force {`SOC_TOP.IOBUF_PAD[8:1]} = $random;
   #10000ns;
   checkers("atm17", `SPI_REG.ana_gen_reg[0][14], top_test_cfg.save_adj_val[0]);
   top_test_cfg.save_adj_val[2] = `SOC_TOP.IOBUF_PAD[8:1];
 
    // ATM18
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b10010;
    //force `SOC_TB.ext_resetn = 1'b0;
    #10000;
    //force `SOC_TB.ext_resetn = 1'b1;
    #1ms
    if(`DIG_TOP.u_pinmux.ATM18 !== 1'b1)
      `nnc_error("ATM18", $sformatf("ATM[18] = %b is not as expectation of 1'b1", `DIG_TOP.u_pinmux.ATM18));
   force {`SOC_TOP.IOBUF_PAD[8:1]} = $random;
   #10000ns;
   checkers("atm18", `SPI_REG.ana_gen_reg[0][14], top_test_cfg.save_adj_val[0]);
   checkers("atm18", `SPI_REG.ana_gen_reg[1][14], top_test_cfg.save_adj_val[2]);
   top_test_cfg.save_adj_val[3] = `SOC_TOP.IOBUF_PAD[8:1];
 
    // ATM19
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b10011;
    //force `SOC_TB.ext_resetn = 1'b0;
    #10000;
    //force `SOC_TB.ext_resetn = 1'b1;
    #1ms
    if(`DIG_TOP.u_pinmux.ATM19 !== 1'b1)
      `nnc_error("ATM19", $sformatf("ATM[19] = %b is not as expectation of 1'b1", `DIG_TOP.u_pinmux.ATM19));
   force {`SOC_TOP.IOBUF_PAD[8:1]} = $random;
   #10000ns;
   checkers("atm19", `SPI_REG.ana_gen_reg[0][14], top_test_cfg.save_adj_val[0]);
   checkers("atm19", `SPI_REG.ana_gen_reg[1][14], top_test_cfg.save_adj_val[2]);
   top_test_cfg.save_adj_val[4] = `SOC_TOP.IOBUF_PAD[8:1];
 
    // ATM20
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b10100;
    //force `SOC_TB.ext_resetn = 1'b0;
    #10000;
    //force `SOC_TB.ext_resetn = 1'b1;
    #1ms
    if(`DIG_TOP.u_pinmux.ATM20 !== 1'b1)
      `nnc_error("ATM20", $sformatf("ATM[20] = %b is not as expectation of 1'b1", `DIG_TOP.u_pinmux.ATM20));
   force {`SOC_TOP.IOBUF_PAD[8:1]} = $random;
   #10000ns;
   checkers("atm20", `SPI_REG.ana_gen_reg[0][14], top_test_cfg.save_adj_val[0]);
   checkers("atm20", `SPI_REG.ana_gen_reg[1][14], top_test_cfg.save_adj_val[2]);
   checkers("atm20", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][3]}, top_test_cfg.save_adj_val[4][3:0]);
   top_test_cfg.save_adj_val[5] = `SOC_TOP.IOBUF_PAD[8:1];
 
    // ATM21
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b10101;
    //force `SOC_TB.ext_resetn = 1'b0;
    #10000;
    //force `SOC_TB.ext_resetn = 1'b1;
    #1ms
    if(`DIG_TOP.u_pinmux.ATM21 !== 1'b1)
      `nnc_error("ATM121", $sformatf("ATM[21] = %b is not as expectation of 1'b1", `DIG_TOP.u_pinmux.ATM21));
   force {`SOC_TOP.IOBUF_PAD[8:1]} = $random;
   #10000ns;
   checkers("atm21", `SPI_REG.ana_gen_reg[0][14], top_test_cfg.save_adj_val[0]);
   checkers("atm21", `SPI_REG.ana_gen_reg[1][14], top_test_cfg.save_adj_val[2]);
  checkers("atm21", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][3]}, top_test_cfg.save_adj_val[4][3:0]);
  checkers("atm21", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][3], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][0], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][7], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][6], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][5]}, top_test_cfg.save_adj_val[5]);
   top_test_cfg.save_adj_val[6] = `SOC_TOP.IOBUF_PAD[8:1];
 
    // ATM22
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b10110;
    //force `SOC_TB.ext_resetn = 1'b0;
    #10000;
    //force `SOC_TB.ext_resetn = 1'b1;
    #1ms
    if(`DIG_TOP.u_pinmux.ATM22 !== 1'b1)
      `nnc_error("ATM22", $sformatf("ATM[22] = %b is not as expectation of 1'b1", `DIG_TOP.u_pinmux.ATM22));
   force {`SOC_TOP.IOBUF_PAD[8:1]} = $random;
   #10000ns;
   checkers("atm22", `SPI_REG.ana_gen_reg[0][14], top_test_cfg.save_adj_val[0]);
   checkers("atm22", `SPI_REG.ana_gen_reg[1][14], top_test_cfg.save_adj_val[2]);
  checkers("atm22", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][3]}, top_test_cfg.save_adj_val[4][3:0]);
  checkers("atm22", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][3], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][0], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][7], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][6], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][5]}, top_test_cfg.save_adj_val[5]);
 
   top_test_cfg.save_adj_val[7] = `SOC_TOP.IOBUF_PAD[8:1];
 
    // ATM23
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b10111;
    //force `SOC_TB.ext_resetn = 1'b0;
    #10000;
    //force `SOC_TB.ext_resetn = 1'b1;
    #1ms
    if(`DIG_TOP.u_pinmux.ATM23 !== 1'b1)
      `nnc_error("ATM23", $sformatf("ATM[23] = %b is not as expectation of 1'b1", `DIG_TOP.u_pinmux.ATM23));
   force {`SOC_TOP.IOBUF_PAD[8:1]} = $random;
   #10000ns;
   checkers("atm23", `SPI_REG.ana_gen_reg[0][14], top_test_cfg.save_adj_val[0]);
   checkers("atm23", `SPI_REG.ana_gen_reg[1][14], top_test_cfg.save_adj_val[2]);
   checkers("atm23", `SPI_REG.ana_gen_reg[2][14], top_test_cfg.save_adj_val[7]);
  checkers("atm23", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][3]}, top_test_cfg.save_adj_val[4][3:0]);
  checkers("atm23", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][3], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][0], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][7], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][6], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][5]}, top_test_cfg.save_adj_val[5]);
 
   top_test_cfg.save_adj_val[8] = `SOC_TOP.IOBUF_PAD[8:1];
 
    // ATM24
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b11000;
    //force `SOC_TB.ext_resetn = 1'b0;
    #10000;
    //force `SOC_TB.ext_resetn = 1'b1;
    #1ms
    if(`DIG_TOP.u_pinmux.ATM24 !== 1'b1)
      `nnc_error("ATM24", $sformatf("ATM[24] = %b is not as expectation of 1'b1", `DIG_TOP.u_pinmux.ATM24));
   force {`SOC_TOP.IOBUF_PAD[8:1]} = $random;
   #10000ns;
   checkers("atm24", `SPI_REG.ana_gen_reg[0][14], top_test_cfg.save_adj_val[0]);
   checkers("atm24", `SPI_REG.ana_gen_reg[1][14], top_test_cfg.save_adj_val[2]);
   checkers("atm24", `SPI_REG.ana_gen_reg[2][14], top_test_cfg.save_adj_val[7]);
  checkers("atm24", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][3]}, top_test_cfg.save_adj_val[4][3:0]);
  checkers("atm24", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][3], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][0], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][7], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][6], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][5]}, top_test_cfg.save_adj_val[5]);
   top_test_cfg.save_adj_val[9] = `SOC_TOP.IOBUF_PAD[8:1];
 
    // ATM25
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b11001;
    //force `SOC_TB.ext_resetn = 1'b0;
    #10000;
    //force `SOC_TB.ext_resetn = 1'b1;
    #1ms
    if(`DIG_TOP.u_pinmux.ATM25 !== 1'b1)
      `nnc_error("ATM25", $sformatf("ATM[25] = %b is not as expectation of 1'b1", `DIG_TOP.u_pinmux.ATM25));
   force {`SOC_TOP.IOBUF_PAD[8:1]} = $random;
   #10000ns;
   checkers("atm25", `SPI_REG.ana_gen_reg[0][14], top_test_cfg.save_adj_val[0]);
   checkers("atm25", `SPI_REG.ana_gen_reg[1][14], top_test_cfg.save_adj_val[2]);
   checkers("atm25", `SPI_REG.ana_gen_reg[2][14], top_test_cfg.save_adj_val[7]);
   checkers("atm25", `SPI_REG.ana_gen_reg[3][14], top_test_cfg.save_adj_val[9]);
  checkers("atm25", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][3]}, top_test_cfg.save_adj_val[4][3:0]);
  checkers("atm25", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][3], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][0], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][7], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][6], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][5]}, top_test_cfg.save_adj_val[5]);
   top_test_cfg.save_adj_val[10] = `SOC_TOP.IOBUF_PAD[8:1];
 
    // ATM26
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b11010;
    //force `SOC_TB.ext_resetn = 1'b0;
    #10000;
    //force `SOC_TB.ext_resetn = 1'b1;
    #1ms
    if(`DIG_TOP.u_pinmux.ATM26 !== 1'b1)
      `nnc_error("ATM26", $sformatf("ATM[26] = %b is not as expectation of 1'b1", `DIG_TOP.u_pinmux.ATM26));
   force {`SOC_TOP.IOBUF_PAD[8:1]} = $random;
   #10000ns;
   checkers("atm26", `SPI_REG.ana_gen_reg[0][14], top_test_cfg.save_adj_val[0]);
   checkers("atm26", `SPI_REG.ana_gen_reg[1][14], top_test_cfg.save_adj_val[2]);
   checkers("atm26", `SPI_REG.ana_gen_reg[2][14], top_test_cfg.save_adj_val[7]);
   checkers("atm26", `SPI_REG.ana_gen_reg[3][14], top_test_cfg.save_adj_val[9]);
   checkers("atm26", `SPI_REG.ana_gen_reg[4][14], top_test_cfg.save_adj_val[10]);
  checkers("atm26", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][3]}, top_test_cfg.save_adj_val[4][3:0]);
  checkers("atm26", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][3], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][0], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][7], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][6], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][5]}, top_test_cfg.save_adj_val[5]);
   top_test_cfg.save_adj_val[11] = `SOC_TOP.IOBUF_PAD[8:1];
 
    // ATM27
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b11011;
    //force `SOC_TB.ext_resetn = 1'b0;
    #10000;
    //force `SOC_TB.ext_resetn = 1'b1;
    #1ms
    if(`DIG_TOP.u_pinmux.ATM27 !== 1'b1)
      `nnc_error("ATM27", $sformatf("ATM[27] = %b is not as expectation of 1'b1", `DIG_TOP.u_pinmux.ATM27));
   force {`SOC_TOP.IOBUF_PAD[8:1]} = $random;
   #10000ns;
   checkers("atm27", `SPI_REG.ana_gen_reg[0][14], top_test_cfg.save_adj_val[0]);
   checkers("atm27", `SPI_REG.ana_gen_reg[1][14], top_test_cfg.save_adj_val[2]);
   checkers("atm27", `SPI_REG.ana_gen_reg[2][14], top_test_cfg.save_adj_val[7]);
   checkers("atm27", `SPI_REG.ana_gen_reg[3][14], top_test_cfg.save_adj_val[9]);
   checkers("atm27", `SPI_REG.ana_gen_reg[4][14], top_test_cfg.save_adj_val[10]);
   checkers("atm27", `SPI_REG.ana_gen_reg[5][14], top_test_cfg.save_adj_val[11]);
  checkers("atm27", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][3]}, top_test_cfg.save_adj_val[4][3:0]);
  checkers("atm27", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][3], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][0], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][7], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][6], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][5]}, top_test_cfg.save_adj_val[5]);
   top_test_cfg.save_adj_val[12] = `SOC_TOP.IOBUF_PAD[8:1];
 
    // ATM28
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b11100;
    //force `SOC_TB.ext_resetn = 1'b0;
    #10000;
    //force `SOC_TB.ext_resetn = 1'b1;
    #1ms
    if(`DIG_TOP.u_pinmux.ATM28 !== 1'b1)
      `nnc_error("ATM28", $sformatf("ATM[28] = %b is not as expectation of 1'b1", `DIG_TOP.u_pinmux.ATM28));
   force {`SOC_TOP.IOBUF_PAD[8:1]} = $random;
   #10000ns;
   checkers("atm28", `SPI_REG.ana_gen_reg[0][14], top_test_cfg.save_adj_val[0]);
   checkers("atm28", `SPI_REG.ana_gen_reg[1][14], top_test_cfg.save_adj_val[2]);
   checkers("atm28", `SPI_REG.ana_gen_reg[2][14], top_test_cfg.save_adj_val[7]);
   checkers("atm28", `SPI_REG.ana_gen_reg[3][14], top_test_cfg.save_adj_val[9]);
   checkers("atm28", `SPI_REG.ana_gen_reg[4][14], top_test_cfg.save_adj_val[10]);
   checkers("atm28", `SPI_REG.ana_gen_reg[5][14], top_test_cfg.save_adj_val[11]);
   checkers("atm28", `SPI_REG.ana_gen_reg[6][14], top_test_cfg.save_adj_val[12]);
  checkers("atm28", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][3]}, top_test_cfg.save_adj_val[4][3:0]);
  checkers("atm28", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][3], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][0], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][7], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][6], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][5]}, top_test_cfg.save_adj_val[5]);
   top_test_cfg.save_adj_val[13] = `SOC_TOP.IOBUF_PAD[8:1];
 
    // ATM29
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b11101;
    //force `SOC_TB.ext_resetn = 1'b0;
    #10000;
    //force `SOC_TB.ext_resetn = 1'b1;
    #1ms
    if(`DIG_TOP.u_pinmux.ATM29 !== 1'b1)
      `nnc_error("ATM29", $sformatf("ATM[29] = %b is not as expectation of 1'b1", `DIG_TOP.u_pinmux.ATM29));
   force {`SOC_TOP.IOBUF_PAD[8:1]} = $random;
   #10000ns;
   //checkers("atm29", `SPI_REG.ana_gen_reg[0][14], top_test_cfg.save_adj_val[0]);
   checkers("atm29", `SPI_REG.ana_gen_reg[1][14], top_test_cfg.save_adj_val[2]);
   checkers("atm29", `SPI_REG.ana_gen_reg[2][14], top_test_cfg.save_adj_val[7]);
   checkers("atm29", `SPI_REG.ana_gen_reg[3][14], top_test_cfg.save_adj_val[9]);
   checkers("atm29", `SPI_REG.ana_gen_reg[4][14], top_test_cfg.save_adj_val[10]);
   checkers("atm29", `SPI_REG.ana_gen_reg[5][14], top_test_cfg.save_adj_val[11]);
   checkers("atm29", `SPI_REG.ana_gen_reg[6][14], top_test_cfg.save_adj_val[12]);
   checkers("atm29", `SPI_REG.ana_gen_reg[7][14], top_test_cfg.save_adj_val[13]);
  checkers("atm29", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][3]}, top_test_cfg.save_adj_val[4][3:0]);
  checkers("atm29", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][3], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][0], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][7], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][6], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][5]}, top_test_cfg.save_adj_val[5]);
   top_test_cfg.save_adj_val[14] = `SOC_TOP.IOBUF_PAD[8:1];



//////////////////////////////////// LOOP BACK TO ATM 15 ////////////////////////////////////////

    // ATM28
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b11100;
    //force `SOC_TB.ext_resetn = 1'b0;
    #10000;
    //force `SOC_TB.ext_resetn = 1'b1;
    #1ms
    if(`DIG_TOP.u_pinmux.ATM28 !== 1'b1)
      `nnc_error("ATM28", $sformatf("ATM[28] = %b is not as expectation of 1'b1", `DIG_TOP.u_pinmux.ATM28));
   force {`SOC_TOP.IOBUF_PAD[8:1]} = $random;
   #10000ns;
   checkers("atm28", `SPI_REG.ana_gen_reg[0][14], top_test_cfg.save_adj_val[14]);
   checkers("atm28", `SPI_REG.ana_gen_reg[1][14], top_test_cfg.save_adj_val[2]);
   checkers("atm28", `SPI_REG.ana_gen_reg[2][14], top_test_cfg.save_adj_val[7]);
   checkers("atm28", `SPI_REG.ana_gen_reg[3][14], top_test_cfg.save_adj_val[9]);
   checkers("atm28", `SPI_REG.ana_gen_reg[4][14], top_test_cfg.save_adj_val[10]);
   checkers("atm28", `SPI_REG.ana_gen_reg[5][14], top_test_cfg.save_adj_val[11]);
   checkers("atm28", `SPI_REG.ana_gen_reg[6][14], top_test_cfg.save_adj_val[12]);
  checkers("atm28", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][3]}, top_test_cfg.save_adj_val[4][3:0]);
  checkers("atm28", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][3], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][0], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][7], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][6], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][5]}, top_test_cfg.save_adj_val[5]);
   top_test_cfg.save_adj_val[13] = `SOC_TOP.IOBUF_PAD[8:1];


    // ATM27
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b11011;
    //force `SOC_TB.ext_resetn = 1'b0;
    #10000;
    //force `SOC_TB.ext_resetn = 1'b1;
    #1ms
    if(`DIG_TOP.u_pinmux.ATM27 !== 1'b1)
      `nnc_error("ATM27", $sformatf("ATM[27] = %b is not as expectation of 1'b1", `DIG_TOP.u_pinmux.ATM27));
   force {`SOC_TOP.IOBUF_PAD[8:1]} = $random;
   #10000ns;
   checkers("atm27", `SPI_REG.ana_gen_reg[0][14], top_test_cfg.save_adj_val[14]);
   checkers("atm27", `SPI_REG.ana_gen_reg[1][14], top_test_cfg.save_adj_val[2]);
   checkers("atm27", `SPI_REG.ana_gen_reg[2][14], top_test_cfg.save_adj_val[7]);
   checkers("atm27", `SPI_REG.ana_gen_reg[3][14], top_test_cfg.save_adj_val[9]);
   checkers("atm27", `SPI_REG.ana_gen_reg[4][14], top_test_cfg.save_adj_val[10]);
   checkers("atm27", `SPI_REG.ana_gen_reg[5][14], top_test_cfg.save_adj_val[11]);
   checkers("atm27", `SPI_REG.ana_gen_reg[7][14], top_test_cfg.save_adj_val[13]);
  checkers("atm27", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][3]}, top_test_cfg.save_adj_val[4][3:0]);
  checkers("atm27", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][3], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][0], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][7], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][6], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][5]}, top_test_cfg.save_adj_val[5]);
   top_test_cfg.save_adj_val[12] = `SOC_TOP.IOBUF_PAD[8:1];

    // ATM26
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b11010;
    //force `SOC_TB.ext_resetn = 1'b0;
    #10000;
    //force `SOC_TB.ext_resetn = 1'b1;
    #1ms
    if(`DIG_TOP.u_pinmux.ATM26 !== 1'b1)
      `nnc_error("ATM26", $sformatf("ATM[26] = %b is not as expectation of 1'b1", `DIG_TOP.u_pinmux.ATM26));
   force {`SOC_TOP.IOBUF_PAD[8:1]} = $random;
   #10000ns;
   checkers("atm26", `SPI_REG.ana_gen_reg[0][14], top_test_cfg.save_adj_val[14]);
   checkers("atm26", `SPI_REG.ana_gen_reg[1][14], top_test_cfg.save_adj_val[2]);
   checkers("atm26", `SPI_REG.ana_gen_reg[2][14], top_test_cfg.save_adj_val[7]);
   checkers("atm26", `SPI_REG.ana_gen_reg[3][14], top_test_cfg.save_adj_val[9]);
   checkers("atm26", `SPI_REG.ana_gen_reg[4][14], top_test_cfg.save_adj_val[10]);
   checkers("atm26", `SPI_REG.ana_gen_reg[6][14], top_test_cfg.save_adj_val[12]);
   checkers("atm26", `SPI_REG.ana_gen_reg[7][14], top_test_cfg.save_adj_val[13]);
  checkers("atm26", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][3]}, top_test_cfg.save_adj_val[4][3:0]);
  checkers("atm26", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][3], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][0], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][7], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][6], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][5]}, top_test_cfg.save_adj_val[5]);
   top_test_cfg.save_adj_val[11] = `SOC_TOP.IOBUF_PAD[8:1];


    // ATM25
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b11001;
    //force `SOC_TB.ext_resetn = 1'b0;
    #10000;
    //force `SOC_TB.ext_resetn = 1'b1;
    #1ms
    if(`DIG_TOP.u_pinmux.ATM25 !== 1'b1)
      `nnc_error("ATM25", $sformatf("ATM[25] = %b is not as expectation of 1'b1", `DIG_TOP.u_pinmux.ATM25));
   force {`SOC_TOP.IOBUF_PAD[8:1]} = $random;
   #10000ns;
   checkers("atm25", `SPI_REG.ana_gen_reg[0][14], top_test_cfg.save_adj_val[14]);
   checkers("atm25", `SPI_REG.ana_gen_reg[1][14], top_test_cfg.save_adj_val[2]);
   checkers("atm25", `SPI_REG.ana_gen_reg[2][14], top_test_cfg.save_adj_val[7]);
   checkers("atm25", `SPI_REG.ana_gen_reg[3][14], top_test_cfg.save_adj_val[9]);
   checkers("atm25", `SPI_REG.ana_gen_reg[5][14], top_test_cfg.save_adj_val[11]);
   checkers("atm25", `SPI_REG.ana_gen_reg[6][14], top_test_cfg.save_adj_val[12]);
   checkers("atm25", `SPI_REG.ana_gen_reg[7][14], top_test_cfg.save_adj_val[13]);
  checkers("atm25", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][3]}, top_test_cfg.save_adj_val[4][3:0]);
  checkers("atm25", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][3], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][0], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][7], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][6], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][5]}, top_test_cfg.save_adj_val[5]);
   top_test_cfg.save_adj_val[10] = `SOC_TOP.IOBUF_PAD[8:1];


    // ATM24
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b11000;
    //force `SOC_TB.ext_resetn = 1'b0;
    #10000;
    //force `SOC_TB.ext_resetn = 1'b1;
    #1ms
    if(`DIG_TOP.u_pinmux.ATM24 !== 1'b1)
      `nnc_error("ATM24", $sformatf("ATM[24] = %b is not as expectation of 1'b1", `DIG_TOP.u_pinmux.ATM24));
   force {`SOC_TOP.IOBUF_PAD[8:1]} = $random;
   #10000ns;
   checkers("atm24", `SPI_REG.ana_gen_reg[0][14], top_test_cfg.save_adj_val[14]);
   checkers("atm24", `SPI_REG.ana_gen_reg[1][14], top_test_cfg.save_adj_val[2]);
   checkers("atm24", `SPI_REG.ana_gen_reg[2][14], top_test_cfg.save_adj_val[7]);
   checkers("atm24", `SPI_REG.ana_gen_reg[4][14], top_test_cfg.save_adj_val[10]);
   checkers("atm24", `SPI_REG.ana_gen_reg[5][14], top_test_cfg.save_adj_val[11]);
   checkers("atm24", `SPI_REG.ana_gen_reg[6][14], top_test_cfg.save_adj_val[12]);
   checkers("atm24", `SPI_REG.ana_gen_reg[7][14], top_test_cfg.save_adj_val[13]);
  checkers("atm24", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][3]}, top_test_cfg.save_adj_val[4][3:0]);
  checkers("atm24", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][3], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][0], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][7], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][6], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][5]}, top_test_cfg.save_adj_val[5]);
   top_test_cfg.save_adj_val[9] = `SOC_TOP.IOBUF_PAD[8:1];


    // ATM23
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b10111;
    //force `SOC_TB.ext_resetn = 1'b0;
    #10000;
    //force `SOC_TB.ext_resetn = 1'b1;
    #1ms
    if(`DIG_TOP.u_pinmux.ATM23 !== 1'b1)
      `nnc_error("ATM23", $sformatf("ATM[23] = %b is not as expectation of 1'b1", `DIG_TOP.u_pinmux.ATM23));
   force {`SOC_TOP.IOBUF_PAD[8:1]} = $random;
   #10000ns;
   checkers("atm23", `SPI_REG.ana_gen_reg[0][14], top_test_cfg.save_adj_val[14]);
   checkers("atm23", `SPI_REG.ana_gen_reg[1][14], top_test_cfg.save_adj_val[2]);
   checkers("atm23", `SPI_REG.ana_gen_reg[2][14], top_test_cfg.save_adj_val[7]);
   checkers("atm23", `SPI_REG.ana_gen_reg[4][14], top_test_cfg.save_adj_val[10]);
   checkers("atm23", `SPI_REG.ana_gen_reg[5][14], top_test_cfg.save_adj_val[11]);
   checkers("atm23", `SPI_REG.ana_gen_reg[6][14], top_test_cfg.save_adj_val[12]);
   checkers("atm23", `SPI_REG.ana_gen_reg[7][14], top_test_cfg.save_adj_val[13]);
  checkers("atm23", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][3]}, top_test_cfg.save_adj_val[4][3:0]);
  checkers("atm23", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][3], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][0], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][7], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][6], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][5]}, top_test_cfg.save_adj_val[5]);
 
   top_test_cfg.save_adj_val[8] = `SOC_TOP.IOBUF_PAD[8:1];


    // ATM22
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b10110;
    //force `SOC_TB.ext_resetn = 1'b0;
    #10000;
    //force `SOC_TB.ext_resetn = 1'b1;
    #1ms
    if(`DIG_TOP.u_pinmux.ATM22 !== 1'b1)
      `nnc_error("ATM22", $sformatf("ATM[22] = %b is not as expectation of 1'b1", `DIG_TOP.u_pinmux.ATM22));
   force {`SOC_TOP.IOBUF_PAD[8:1]} = $random;
   #10000ns;
   checkers("atm22", `SPI_REG.ana_gen_reg[0][14], top_test_cfg.save_adj_val[14]);
   checkers("atm22", `SPI_REG.ana_gen_reg[1][14], top_test_cfg.save_adj_val[2]);
   checkers("atm22", `SPI_REG.ana_gen_reg[3][14], top_test_cfg.save_adj_val[8]);
   checkers("atm22", `SPI_REG.ana_gen_reg[4][14], top_test_cfg.save_adj_val[10]);
   checkers("atm22", `SPI_REG.ana_gen_reg[5][14], top_test_cfg.save_adj_val[11]);
   checkers("atm22", `SPI_REG.ana_gen_reg[6][14], top_test_cfg.save_adj_val[12]);
   checkers("atm22", `SPI_REG.ana_gen_reg[7][14], top_test_cfg.save_adj_val[13]);
  checkers("atm22", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][3]}, top_test_cfg.save_adj_val[4][3:0]);
  checkers("atm22", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][3], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][0], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][7], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][6], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][5]}, top_test_cfg.save_adj_val[5]);
 
   top_test_cfg.save_adj_val[7] = `SOC_TOP.IOBUF_PAD[8:1];


    // ATM21
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b10101;
    //force `SOC_TB.ext_resetn = 1'b0;
    #10000;
    //force `SOC_TB.ext_resetn = 1'b1;
    #1ms
    if(`DIG_TOP.u_pinmux.ATM21 !== 1'b1)
      `nnc_error("ATM121", $sformatf("ATM[21] = %b is not as expectation of 1'b1", `DIG_TOP.u_pinmux.ATM21));
   force {`SOC_TOP.IOBUF_PAD[8:1]} = $random;
   #10000ns;
   checkers("atm21", `SPI_REG.ana_gen_reg[0][14], top_test_cfg.save_adj_val[14]);
   checkers("atm21", `SPI_REG.ana_gen_reg[1][14], top_test_cfg.save_adj_val[2]);
   checkers("atm21", `SPI_REG.ana_gen_reg[3][14], top_test_cfg.save_adj_val[8]);
   checkers("atm21", `SPI_REG.ana_gen_reg[4][14], top_test_cfg.save_adj_val[10]);
   checkers("atm21", `SPI_REG.ana_gen_reg[5][14], top_test_cfg.save_adj_val[11]);
   checkers("atm21", `SPI_REG.ana_gen_reg[6][14], top_test_cfg.save_adj_val[12]);
   checkers("atm21", `SPI_REG.ana_gen_reg[7][14], top_test_cfg.save_adj_val[13]);
  checkers("atm21", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][3]}, top_test_cfg.save_adj_val[4][3:0]);
  checkers("atm21", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][3], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][0], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][7], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][6], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][5]}, top_test_cfg.save_adj_val[5]);

   top_test_cfg.save_adj_val[6] = `SOC_TOP.IOBUF_PAD[8:1];


    // ATM20
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b10100;
    //force `SOC_TB.ext_resetn = 1'b0;
    #10000;
    //force `SOC_TB.ext_resetn = 1'b1;
    #1ms
    if(`DIG_TOP.u_pinmux.ATM20 !== 1'b1)
      `nnc_error("ATM20", $sformatf("ATM[20] = %b is not as expectation of 1'b1", `DIG_TOP.u_pinmux.ATM20));
   force {`SOC_TOP.IOBUF_PAD[8:1]} = $random;
   #10000ns;
   checkers("atm20", `SPI_REG.ana_gen_reg[0][14], top_test_cfg.save_adj_val[14]);
   checkers("atm20", `SPI_REG.ana_gen_reg[1][14], top_test_cfg.save_adj_val[2]);
   checkers("atm20", `SPI_REG.ana_gen_reg[2][14], top_test_cfg.save_adj_val[6]);
   checkers("atm20", `SPI_REG.ana_gen_reg[3][14], top_test_cfg.save_adj_val[8]);
   checkers("atm20", `SPI_REG.ana_gen_reg[4][14], top_test_cfg.save_adj_val[10]);
   checkers("atm20", `SPI_REG.ana_gen_reg[5][14], top_test_cfg.save_adj_val[11]);
   checkers("atm20", `SPI_REG.ana_gen_reg[6][14], top_test_cfg.save_adj_val[12]);
   checkers("atm20", `SPI_REG.ana_gen_reg[7][14], top_test_cfg.save_adj_val[13]);
  checkers("atm20", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][3]}, top_test_cfg.save_adj_val[4][3:0]);
   top_test_cfg.save_adj_val[5] = `SOC_TOP.IOBUF_PAD[8:1];


    // ATM19
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b10011;
    //force `SOC_TB.ext_resetn = 1'b0;
    #10000;
    //force `SOC_TB.ext_resetn = 1'b1;
    #1ms
    if(`DIG_TOP.u_pinmux.ATM19 !== 1'b1)
      `nnc_error("ATM19", $sformatf("ATM[19] = %b is not as expectation of 1'b1", `DIG_TOP.u_pinmux.ATM19));
   force {`SOC_TOP.IOBUF_PAD[8:1]} = $random;
   #10000ns;
   checkers("atm19", `SPI_REG.ana_gen_reg[0][14], top_test_cfg.save_adj_val[14]);
   checkers("atm19", `SPI_REG.ana_gen_reg[1][14], top_test_cfg.save_adj_val[2]);
   checkers("atm19", `SPI_REG.ana_gen_reg[2][14], top_test_cfg.save_adj_val[6]);
   checkers("atm19", `SPI_REG.ana_gen_reg[3][14], top_test_cfg.save_adj_val[8]);
   checkers("atm19", `SPI_REG.ana_gen_reg[4][14], top_test_cfg.save_adj_val[10]);
   checkers("atm19", `SPI_REG.ana_gen_reg[5][14], top_test_cfg.save_adj_val[11]);
   checkers("atm19", `SPI_REG.ana_gen_reg[6][14], top_test_cfg.save_adj_val[12]);
   checkers("atm19", `SPI_REG.ana_gen_reg[7][14], top_test_cfg.save_adj_val[13]);
  checkers("atm19", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][3], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][0], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][7], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][6], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][5]}, top_test_cfg.save_adj_val[5]);

   top_test_cfg.save_adj_val[4] = `SOC_TOP.IOBUF_PAD[8:1];


    // ATM18
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b10010;
    //force `SOC_TB.ext_resetn = 1'b0;
    #10000;
    //force `SOC_TB.ext_resetn = 1'b1;
    #1ms
    if(`DIG_TOP.u_pinmux.ATM18 !== 1'b1)
      `nnc_error("ATM18", $sformatf("ATM[18] = %b is not as expectation of 1'b1", `DIG_TOP.u_pinmux.ATM18));
   force {`SOC_TOP.IOBUF_PAD[8:1]} = $random;
   #10000ns;
   checkers("atm18", `SPI_REG.ana_gen_reg[0][14], top_test_cfg.save_adj_val[14]);
   checkers("atm18", `SPI_REG.ana_gen_reg[1][14], top_test_cfg.save_adj_val[2]);
   checkers("atm18", `SPI_REG.ana_gen_reg[2][14], top_test_cfg.save_adj_val[6]);
   checkers("atm18", `SPI_REG.ana_gen_reg[3][14], top_test_cfg.save_adj_val[8]);
   checkers("atm18", `SPI_REG.ana_gen_reg[4][14], top_test_cfg.save_adj_val[10]);
   checkers("atm18", `SPI_REG.ana_gen_reg[5][14], top_test_cfg.save_adj_val[11]);
   checkers("atm18", `SPI_REG.ana_gen_reg[6][14], top_test_cfg.save_adj_val[12]);
   checkers("atm18", `SPI_REG.ana_gen_reg[7][14], top_test_cfg.save_adj_val[13]);
  checkers("atm18", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][3], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][0], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][7], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][6], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][5]}, top_test_cfg.save_adj_val[5]);
   top_test_cfg.save_adj_val[3] = `SOC_TOP.IOBUF_PAD[8:1];

 
    // ATM17
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b10001;
    //force `SOC_TB.ext_resetn = 1'b0;
    #10000;
    //force `SOC_TB.ext_resetn = 1'b1;
    #1ms
    if(`DIG_TOP.u_pinmux.ATM17 !== 1'b1)
      `nnc_error("ATM17", $sformatf("ATM[17] = %b is not as expectation of 1'b1", `DIG_TOP.u_pinmux.ATM17));
   force {`SOC_TOP.IOBUF_PAD[8:1]} = $random;
   #10000ns;
   checkers("atm17", `SPI_REG.ana_gen_reg[0][14], top_test_cfg.save_adj_val[14]);
   checkers("atm17", `SPI_REG.ana_gen_reg[2][14], top_test_cfg.save_adj_val[6]);
   checkers("atm17", `SPI_REG.ana_gen_reg[3][14], top_test_cfg.save_adj_val[8]);
   checkers("atm17", `SPI_REG.ana_gen_reg[4][14], top_test_cfg.save_adj_val[10]);
   checkers("atm17", `SPI_REG.ana_gen_reg[5][14], top_test_cfg.save_adj_val[11]);
   checkers("atm17", `SPI_REG.ana_gen_reg[6][14], top_test_cfg.save_adj_val[12]);
   checkers("atm17", `SPI_REG.ana_gen_reg[7][14], top_test_cfg.save_adj_val[13]);
  checkers("atm17", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][3], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][0], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][7], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][6], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][5]}, top_test_cfg.save_adj_val[5]);
  checkers("atm17", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][3]}, top_test_cfg.save_adj_val[3][3:0]);
   top_test_cfg.save_adj_val[2] = `SOC_TOP.IOBUF_PAD[8:1];


    // ATM16
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b10000;
    //force `SOC_TB.ext_resetn = 1'b0;
    #10000;
    //force `SOC_TB.ext_resetn = 1'b1;
    #1ms
    if(`DIG_TOP.u_pinmux.ATM16 !== 1'b1)
      `nnc_error("ATM16", $sformatf("ATM[16] = %b is not as expectation of 1'b1", `DIG_TOP.u_pinmux.ATM16));
   force {`SOC_TOP.IOBUF_PAD[8:1]} = $random;
   #10000ns;
   checkers("atm16", `SPI_REG.ana_gen_reg[0][14], top_test_cfg.save_adj_val[14]);
   checkers("atm16", `SPI_REG.ana_gen_reg[2][14], top_test_cfg.save_adj_val[6]);
   checkers("atm16", `SPI_REG.ana_gen_reg[3][14], top_test_cfg.save_adj_val[8]);
   checkers("atm16", `SPI_REG.ana_gen_reg[4][14], top_test_cfg.save_adj_val[10]);
   checkers("atm16", `SPI_REG.ana_gen_reg[5][14], top_test_cfg.save_adj_val[11]);
   checkers("atm16", `SPI_REG.ana_gen_reg[6][14], top_test_cfg.save_adj_val[12]);
   checkers("atm16", `SPI_REG.ana_gen_reg[7][14], top_test_cfg.save_adj_val[13]);
  checkers("atm16", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][3], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][0], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][7], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][6], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][5]}, top_test_cfg.save_adj_val[5]);
  checkers("atm17", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][3]}, top_test_cfg.save_adj_val[3][3:0]);
   top_test_cfg.save_adj_val[1] = `SOC_TOP.IOBUF_PAD[8:1];


    // ATM15
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b01111;
    //force `SOC_TB.ext_resetn = 1'b0;
    #10000;
    //force `SOC_TB.ext_resetn = 1'b1;   
    #1ms;
    if(`DIG_TOP.u_pinmux.ATM15 !== 1'b1)
      `nnc_error("ATM15", $sformatf("ATM[15] = %b is not as expectation of 1'b1", `DIG_TOP.u_pinmux.ATM15));
 
   force {`SOC_TOP.IOBUF_PAD[8:1]} = $random;
   #10000ns;
   checkers("atm15", `SPI_REG.ana_gen_reg[1][14], top_test_cfg.save_adj_val[1]);
   checkers("atm15", `SPI_REG.ana_gen_reg[2][14], top_test_cfg.save_adj_val[6]);
   checkers("atm15", `SPI_REG.ana_gen_reg[3][14], top_test_cfg.save_adj_val[8]);
   checkers("atm15", `SPI_REG.ana_gen_reg[4][14], top_test_cfg.save_adj_val[10]);
   checkers("atm15", `SPI_REG.ana_gen_reg[5][14], top_test_cfg.save_adj_val[11]);
   checkers("atm15", `SPI_REG.ana_gen_reg[6][14], top_test_cfg.save_adj_val[12]);
   checkers("atm15", `SPI_REG.ana_gen_reg[7][14], top_test_cfg.save_adj_val[13]);
  checkers("atm15", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][3], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][2][0], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][7], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][6], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][3][5]}, top_test_cfg.save_adj_val[5]);
  checkers("atm15", {`SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][2], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][1], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][4], `SPI_REG.u_spi_reg_nirs.nirs_ctrl_reg[4][1][7][3]}, top_test_cfg.save_adj_val[3][3:0]);
   top_test_cfg.save_adj_val[0] = `SOC_TOP.IOBUF_PAD[8:1]; 
    // ATM16
 
    // CHECKERS
 
/*
    if (`ANA_WRAPPER_TOP.pinmux_if.D2A_ADJ_IO[0][7:0] !== top_test_cfg.save_adj_val[0]) 
      `nnc_error("ATM16", $sformatf("`SOC_TOP.pinmux_if.D2A_ADJ_IO[0][7:0] = %b is not as expectation of = %b", `ANA_WRAPPER_TOP.pinmux_if.D2A_ADJ_IO[0][7:0], top_test_cfg.save_adj_val[0]));
 
    if (`ANA_TOP.D2A_VDAC8B_DIN!== top_test_cfg.save_adj_val[0]) 
       `nnc_error("ATM15", $sformatf("`ANA_TOP.D2A_VDAC8B_DIN = %b is not as expectation of = %b", `ANA_TOP.D2A_VDAC8B_DIN, top_test_cfg.save_adj_val[0]));
 
    if ({`ANA_TOP.D2A_LOFF_ISEL_ADJ[3:0], `ANA_TOP.D2A_LOFF_IPOL, `ANA_TOP.D2A_LOFF_COMP_TH[2:0]}!== top_test_cfg.save_adj_val[1]) 
       `nnc_error("ATM16", $sformatf("{`ANA_TOP.D2A_LOFF_ISEL_ADJ[3:0], `ANA_TOP.D2A_LOFF_IPOL, `ANA_TOP.D2A_LOFF_COMP_TH[2:0]} = %b is not as expectation of = %b", {`ANA_TOP.D2A_LOFF_ISEL_ADJ[3:0], `ANA_TOP.D2A_LOFF_IPOL, `ANA_TOP.D2A_LOFF_COMP_TH[2:0]}, top_test_cfg.save_adj_val[1]));
 
    if ({`ANA_TOP.D2A_LOFF_ISEL_ADJ[3:0], `ANA_TOP.D2A_LOFF_IPOL, `ANA_TOP.D2A_LOFF_COMP_TH[2:0]}!== top_test_cfg.save_adj_val[2]) 
       `nnc_error("ATM17", $sformatf("{`ANA_TOP.D2A_LOFF_ISEL_ADJ[3:0], `ANA_TOP.D2A_LOFF_IPOL, `ANA_TOP.D2A_LOFF_COMP_TH[2:0]} = %b is not as expectation of = %b", {`ANA_TOP.D2A_LOFF_ISEL_ADJ[3:0], `ANA_TOP.D2A_LOFF_IPOL, `ANA_TOP.D2A_LOFF_COMP_TH[2:0]}, top_test_cfg.save_adj_val[2]));
 
    if ({`ANA_TOP.D2A_NIRS4_CFRATE_ADJ[5:0], `ANA_TOP.D2A_NIRS4_IREFC_ADJ[1:0]}!== top_test_cfg.save_adj_val[3]) 
       `nnc_error("ATM18", $sformatf("{`ANA_TOP.D2A_NIRS4_CFRATE_ADJ[5:0], `ANA_TOP.D2A_NIRS4_IREFC_ADJ[1:0]} = %b is not as expectation of = %b", {`ANA_TOP.D2A_NIRS4_CFRATE_ADJ[5:0], `ANA_TOP.D2A_NIRS4_IREFC_ADJ[1:0]}, top_test_cfg.save_adj_val[3]));
 
    if ({`ANA_TOP.D2A_NIRS4_CFRATE_ADJ[5:0], `ANA_TOP.D2A_NIRS4_IREFC_ADJ[1:0]}!== top_test_cfg.save_adj_val[4]) 
       `nnc_error("ATM19", $sformatf("{`ANA_TOP.D2A_NIRS4_CFRATE_ADJ[5:0], `ANA_TOP.D2A_NIRS4_IREFC_ADJ[1:0]} = %b is not as expectation of = %b", {`ANA_TOP.D2A_NIRS4_CFRATE_ADJ[5:0], `ANA_TOP.D2A_NIRS4_IREFC_ADJ[1:0]}, top_test_cfg.save_adj_val[4]));
 
    if ({`ANA_TOP.D2A_NIRS4_IDAC_ADJ[7:0]}!== top_test_cfg.save_adj_val[5]) 
       `nnc_error("ATM20", $sformatf("{`ANA_TOP.D2A_NIRS4_IDAC_ADJ[7:0]} = %b is not as expectation of = %b", {`ANA_TOP.D2A_NIRS4_IDAC_ADJ[7:0]}, top_test_cfg.save_adj_val[5]));
 
    if ({`ANA_TOP.D2A_EEGLNA8_IADJ[1:0],`ANA_TOP.D2A_EEGLNA8_GAIN[5:0]}!== top_test_cfg.save_adj_val[6]) 
       `nnc_error("ATM21", $sformatf("{`ANA_TOP.D2A_EEGLNA8_IADJ[1:0],`ANA_TOP.D2A_EEGLNA8_GAIN[5:0]} = %b is not as expectation of = %b", {`ANA_TOP.D2A_EEGLNA8_IADJ[1:0],`ANA_TOP.D2A_EEGLNA8_GAIN[5:0]}, top_test_cfg.save_adj_val[6]));
 
    if ({`ANA_TOP.D2A_EEGLNA8_IADJ[1:0],`ANA_TOP.D2A_EEGLNA8_GAIN[5:0]}!== top_test_cfg.save_adj_val[7]) 
       `nnc_error("ATM22", $sformatf("{`ANA_TOP.D2A_EEGLNA8_IADJ[1:0],`ANA_TOP.D2A_EEGLNA8_GAIN[5:0]} = %b is not as expectation of = %b", {`ANA_TOP.D2A_EEGLNA8_IADJ[1:0],`ANA_TOP.D2A_EEGLNA8_GAIN[5:0]}, top_test_cfg.save_adj_val[7]));
 
    if ({`ANA_TOP.D2A_EEGPGA8B_GAIN[4:0],`ANA_TOP.D2A_EEGPGA8A_GAIN[2:0]}!== top_test_cfg.save_adj_val[8]) 
       `nnc_error("ATM23", $sformatf("{`ANA_TOP.D2A_EEGPGA8B_GAIN[4:0],`ANA_TOP.D2A_EEGPGA8A_GAIN[2:0]} = %b is not as expectation of = %b", {`ANA_TOP.D2A_EEGPGA8B_GAIN[4:0],`ANA_TOP.D2A_EEGPGA8A_GAIN[2:0]}, top_test_cfg.save_adj_val[8]));
 
    if ({`ANA_TOP.D2A_EEGPGA8B_GAIN[4:0],`ANA_TOP.D2A_EEGPGA8A_GAIN[2:0]}!== top_test_cfg.save_adj_val[9]) 
       `nnc_error("ATM24", $sformatf("{`ANA_TOP.D2A_EEGPGA8B_GAIN[4:0],`ANA_TOP.D2A_EEGPGA8A_GAIN[2:0]} = %b is not as expectation of = %b", {`ANA_TOP.D2A_EEGPGA8B_GAIN[4:0],`ANA_TOP.D2A_EEGPGA8A_GAIN[2:0]}, top_test_cfg.save_adj_val[9]));
 
    if ({`ANA_TOP.D2A_VCMGENBUFF_IADJ[7:0]}!== top_test_cfg.save_adj_val[10]) 
       `nnc_error("ATM25", $sformatf("{`ANA_TOP.D2A_VCMGENBUFF_IADJ[7:0]} = %b is not as expectation of = %b", {`ANA_TOP.D2A_VCMGENBUFF_IADJ[7:0]}, top_test_cfg.save_adj_val[10]));
 
    if ({`ANA_TOP.D2A_SDMVCMBUFF_SEL[5:0], `ANA_TOP.D2A_SDMVCMBUFF_IADJ[1:0]}!== top_test_cfg.save_adj_val[11]) 
       `nnc_error("ATM26", $sformatf("{`ANA_TOP.D2A_SDMVCMBUFF_SEL[5:0], `ANA_TOP.D2A_SDMVCMBUFF_IADJ[1:0]} = %b is not as expectation of = %b", {`ANA_TOP.D2A_SDMVCMBUFF_SEL[5:0], `ANA_TOP.D2A_SDMVCMBUFF_IADJ[1:0]}, top_test_cfg.save_adj_val[11]));
 
    if ({`ANA_TOP.D2A_SDMVREFP_SEL[5:0], `ANA_TOP.D2A_SDMVREFP_IADJ[1:0]}!== top_test_cfg.save_adj_val[12]) 
       `nnc_error("ATM27", $sformatf("{`ANA_TOP.D2A_SDMVREFP_SEL[5:0], `ANA_TOP.D2A_SDMVREFP_IADJ[1:0]} = %b is not as expectation of = %b", {`ANA_TOP.D2A_SDMVREFP_SEL[5:0], `ANA_TOP.D2A_SDMVREFP_IADJ[1:0]}, top_test_cfg.save_adj_val[12]));
 
    if ({`ANA_TOP.D2A_RLD_IADJ[7:0]}!== top_test_cfg.save_adj_val[13]) 
       `nnc_error("ATM28", $sformatf("{`ANA_TOP.D2A_RLD_IADJ[7:0]} = %b is not as expectation of = %b", {`ANA_TOP.D2A_RLD_IADJ[7:0]}, top_test_cfg.save_adj_val[13]));
 
    if (`ANA_TOP.D2A_VDAC8B_DIN!== top_test_cfg.save_adj_val[14]) 
       `nnc_error("ATM29", $sformatf("`ANA_TOP.D2A_VDAC8B_DIN = %b is not as expectation of = %b", `ANA_TOP.D2A_VDAC8B_DIN, top_test_cfg.save_adj_val[14]));
      */  
 
    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    #10000ns;
    `nnc_info("SOC_TEST", "soc_pinmux_debugmode_atm_adj_test end now", NNC_LOW)
 
    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ==================================================================================
 
    phase.drop_objection(this);
  endtask: main_phase
 
 
   task checkers(string atm_num, input logic [7:0] actual_val, input logic [7:0] expected_val); begin
      if(actual_val !== expected_val) begin
          `nnc_error(atm_num, $sformatf("Actual data = %b is not as expected = %b", actual_val, expected_val));
      end else begin
          `nnc_info(atm_num, $sformatf("Actual data = %b matches expectation of = %b", actual_val, expected_val), NNC_LOW);
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
