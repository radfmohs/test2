/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_spi_trim_wr_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_spi_trim_wr_test                                             
// Designer	: pfwang@nanochap.com                                                                 
// Date		: 09-05-2024                                                                     
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_spi_trim_wr_test
`define TESTCFG soc_spi_trim_wr_test_cfg

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
  logic [7:0]      def_trim[9];
  logic [7:0] save_trim_wdata[8] = '{default : 8'h0};
  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_spi_trim_wr_test_cfg");
    super.new(name);
    
  endfunction: new

  // ===============================================
  // Adding constraints of randomization
  // -----------------------------------------------

  // testmode_sel[1:0] : 00-Normal mode, 01: Scanmode, 10: BIST mode, 11 atm0/1/2/3/4
  constraint c_testmode_sel { soft testmode_sel == 2'b00; }


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
  logic [7:0] trim_default_value[7:0] = '{`INIT_RELOAD_SOC_OTP_TRIM_8_REG, `INIT_RELOAD_SOC_OTP_TRIM_7_REG, `INIT_RELOAD_SOC_OTP_TRIM_6_REG, `INIT_RELOAD_SOC_OTP_TRIM_5_REG, `INIT_RELOAD_SOC_OTP_TRIM_4_REG, `INIT_RELOAD_SOC_OTP_TRIM_3_REG, `INIT_RELOAD_SOC_OTP_TRIM_2_REG, `INIT_RELOAD_SOC_OTP_TRIM_1_REG};

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


    assert(top_test_cfg.randomize() with {altf_sel == 0;});

    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;

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

    `nnc_info("SOC_TEST", "soc_spi_trim_wr_test start", NNC_LOW)

    // ==================================================================================
    // Please add your code of your test here
    // ---------------------------------------------------------------------------------- 
    
    // --------------------------------------------------------
    // This is an example RD_RESET_CHK_REG 
    // --------------------------------------------------------
    /*assert(top_test_cfg.randomize() with {reg_addr == `SOC_ADDR_WG_DRV_CONFIG_REG0; expected_data == `INIT_SOC_ADDR_WG_DRV_CONFIG_REG0;});
    `nnc_info("SOC_TEST", "Single Reading to a Register and doing a Check READ DATA with Initial values", NNC_LOW)
    `RD_RESET_CHK_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.expected_data, top_test_cfg.pads);

    // --------------------------------------------------------
    // This is an example WR_REG - single write to registers
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ADDR_WG_DRV_CONFIG_REG0;});
    `nnc_info("SOC_TEST", "Single Writing to a Register", NNC_LOW)
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // --------------------------------------------------------
    // This is an example RD_REG - single read to registers
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ADDR_WG_DRV_CONFIG_REG0;});
    `nnc_info("SOC_TEST", "Single Reading to a Register", NNC_LOW)
    `RD_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data[0]);

    // --------------------------------------------------------
    // This is an example WR_RD_CHK_REG
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ADDR_WG_DRV_CONFIG_REG0;});
    `nnc_info("SOC_TEST", "Single Writing/Reading to a Register and doing a Check of DATAs", NNC_LOW)
    `WR_RD_CHK_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads, top_test_cfg.mask);

    // --------------------------------------------------------
    // This is an example WR_BURST_REG - burst write to registers
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ADDR_WG_DRV_CONFIG_REG0; no_of_bytes == 4;});
    `nnc_info("SOC_TEST", "Burst Writing to Registers", NNC_LOW)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    // --------------------------------------------------------
    // This is an example RD_BURST_REG - burst read to registers
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ADDR_WG_DRV_CONFIG_REG0; no_of_bytes == 4;});
    `nnc_info("SOC_TEST", "Burst Reading to Registers", NNC_LOW)
    `RD_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);*/

//    assert(top_test_cfg.randomize() with { reg_addr == `SOC_PMU_REG; no_of_bytes == 8'h2; data[1][3] != 1'b1; data[1][1] != 1'b1;});
//    `DUT_IF.pclk_sel = top_test_cfg.data[8'h0][2:0];
//    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    //set trim_reg
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_TRIM_1_REG; no_of_bytes == 8; });
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);           
    foreach (top_test_cfg.save_trim_wdata[i]) if(i<8) top_test_cfg.save_trim_wdata[i] = top_test_cfg.data[i];
    ////set alt_reg
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_ALT_FUN_REG; no_of_bytes == 1; });
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);           
    //top_test_cfg.save_trim_wdata[9] = {6'h0, top_test_cfg.data[0][1:0]};
    //set alt_reg    //set spare_reg
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_D2A_SPARE_WR_REG0; no_of_bytes == 3; });
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    //top_test_cfg.save_trim_wdata[8] = top_test_cfg.data[2];
    //top_test_cfg.save_trim_wdata[9] = top_test_cfg.data[1];
    //top_test_cfg.save_trim_wdata[10] = top_test_cfg.data[0];


    #1000us;
    check_trimreg(trim_default_value);

    //set spi_wr  bit1:spi_wr  bit0:unlock
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_UNLOCK_REG; no_of_bytes == 1; data[0] == 8'b10101_010;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    #2000us;

    //`DUT_IF.altf_gpio_sel = top_test_cfg.save_trim_wdata[9];
    //set spi_wr  bit1:spi_wr  bit0:unlock
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_UNLOCK_REG; no_of_bytes == 1; data[0] == 8'b10101_000;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    #1000us;
    check_trimreg(top_test_cfg.save_trim_wdata);
 

/*
    top_test_cfg.rd_data = new[12];
    //read trim_reg
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_TRIM_1_REG; no_of_bytes == 9; });
    `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data[3:11]);

    //read altf_reg
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_ALT_FUN_REG; no_of_bytes == 1; });
    `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data[2:2]);

    //read spare_reg
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_D2A_SPARE_WR_REG0; no_of_bytes == 2; });
    `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data[0:1]);

    //check_reg();


    //set unlock  bit1:spi_wr  bit0:unlock
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_UNLOCK_REG; no_of_bytes == 1; data[0] == 8'b10;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //#10000ns;
    //`nnc_info("SOC_TEST", "Requesting the RESET", NNC_LOW)
    //force soc_top_tb.iopad_resetn = 1'b0;

    //#100000ns
    //release soc_top_tb.iopad_resetn;
    //#1000us; 
   
     
    // wait reload done - It will not work by when ALTF is change while SPI is
    // communicating to CHIP
    //do begin
    //    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_DEBUG_1_REG; no_of_bytes == 1;});
    //    `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
    //end while (top_test_cfg.rd_data[0][7] == 1'b1);
    `DUT_IF.altf_gpio_sel = top_test_cfg.save_trim_wdata[6][1:0];
    //read trim_reg
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_TRIM_0_REG; no_of_bytes == 6; });
    `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data[3:8]);

    //read altf_reg
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_ALT_FUN_REG; no_of_bytes == 1; });
    `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data[2:2]);

    //read spare_reg
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_D2A_SPARE_WR_REG0; no_of_bytes == 2; });
    `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data[0:1]);



    for(int i=0; i<9 ; i++) begin
        if(top_test_cfg.save_trim_wdata[i] !== top_test_cfg.rd_data[8-i]) `nnc_error("SOC_TEST", $sformatf("save_trim_wdata %8b !== rd_data %8b!!!", top_test_cfg.save_trim_wdata[i], top_test_cfg.rd_data[8-i]))
        else `nnc_info("SOC_TEST", $sformatf("save_trim_wdata %8b === rd_data %8b!!!", top_test_cfg.save_trim_wdata[i], top_test_cfg.rd_data[8-i]), NNC_LOW) 
    end

*/

    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    #10000ns;
    `nnc_info("SOC_TEST", "soc_spi_trim_wr_test end now", NNC_LOW)

    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ==================================================================================

    phase.drop_objection(this);
  endtask: main_phase

    task check_trimreg(logic [7:0] exp_value[7:0]);
        if(`ANA_TOP.D2A_BG_TRIM         !==   (exp_value[0] & 8'b1111_1111 ))	    `nnc_error("ana_check", $sformatf("D2A_BG_TRIM        : %8h != exp_value:%8h", `ANA_TOP.D2A_BG_TRIM        ,  exp_value[0]));
        if(`ANA_TOP.D2A_IREF_TRIM       !==   ({exp_value[1][7], exp_value[1][5:0]}))	    `nnc_error("ana_check", $sformatf("D2A_IREF_TRIM      : %8h != exp_value:%8h", `ANA_TOP.D2A_IREF_TRIM      ,  exp_value[1]));
        if(`ANA_TOP.D2A_CLDO1P8_TRIM    !==   (exp_value[2] & 8'b1111_1111 ))	    `nnc_error("ana_check", $sformatf("D2A_CLDO1P8_TRIM   : %8h != exp_value:%8h", `ANA_TOP.D2A_CLDO1P8_TRIM   ,  exp_value[2]));
        if(`ANA_TOP.D2A_OSC2MHZ_TRIM    !==   (exp_value[3] & 8'b1111_1111 ))	    `nnc_error("ana_check", $sformatf("D2A_OSC2MHZ_TRIM   : %8h != exp_value:%8h", `ANA_TOP.D2A_OSC2MHZ_TRIM   ,  exp_value[3]));  
        if(`ANA_TOP.D2A_VDAC_VTRIM_CH1  !==   (exp_value[4] & 8'b0000_0111 ))	    `nnc_error("ana_check", $sformatf("D2A_VDAC_RTRIM_CH1 : %8h != exp_value:%8h", `ANA_TOP.D2A_VDAC_VTRIM_CH1 ,  exp_value[4]));
        if(`ANA_TOP.D2A_CS_TRIM_CH1     !==   ((exp_value[4] & 8'b1111_1000 ) >> 3))	    `nnc_error("ana_check", $sformatf("D2A_VDAC_RTRIM_CH1 : %8h != exp_value:%8h", `ANA_TOP.D2A_CS_TRIM_CH1 ,  exp_value[4]));        
        if(`ANA_TOP.D2A_VDAC_VTRIM_CH2  !==   (exp_value[5] & 8'b0000_0111 ))	    `nnc_error("ana_check", $sformatf("D2A_VDAC_RTRIM_CH2 : %8h != exp_value:%8h", `ANA_TOP.D2A_VDAC_VTRIM_CH2 ,  exp_value[5]));
        if(`ANA_TOP.D2A_CS_TRIM_CH2     !==   ((exp_value[5] & 8'b1111_1000 ) >> 3))	    `nnc_error("ana_check", $sformatf("D2A_VDAC_RTRIM_CH1 : %8h != exp_value:%8h", `ANA_TOP.D2A_CS_TRIM_CH2 ,  exp_value[4]));
        if(`ANA_TOP.D2A_IBIAS_IDAC_TRIM !==   ({exp_value[6][7], exp_value[6][2:0]}))	    `nnc_error("ana_check", $sformatf("D2A_IBIAS_IDAC_TRIM: %8h != exp_value:%8h", `ANA_TOP.D2A_IBIAS_IDAC_TRIM,  exp_value[6]));  
        if(`ANA_TOP.D2A_TRIM0_SIG_SPARE !==   (exp_value[7] & 8'b1111_1111 ))	    `nnc_error("ana_check", $sformatf("D2A_TRIM0_SIG_SPARE: %8h != exp_value:%8h", `ANA_TOP.D2A_TRIM0_SIG_SPARE,  exp_value[7]));
    endtask

  
  // ------------------------------
  // Declare the report_phase task
  // ------------------------------
  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction

endclass : `TESTNAME
