/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_anac_tsc_spi_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_anac_tsc_spi_test                                             
// Designer	: pfwang@nanochap.com                                                                 
// Date		: 21-07-2025                                                                     
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_anac_tsc_spi_test
`define TESTCFG soc_anac_tsc_spi_test_cfg

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

  rand logic [7:0] busy_doing;
  rand logic [7:0] tsc_ctrl; 
  rand logic [7:0] tsc_vdac_din;
  logic [7:0]      rdata;

  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_anac_tsc_spi_test_cfg");
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

    `nnc_info("SOC_TEST", "soc_anac_tsc_spi_test start", NNC_LOW)

    // ==================================================================================
    // Please add your code of your test here
    // ---------------------------------------------------------------------------------- 
`ifndef MIX_SIM_EN
    
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_TSC_EN_REG_SEL_REG;});
    `nnc_info("SOC_TEST", "Single Writing to a Register", NNC_LOW)
    `WR_NORMAL_REG(`SOC_TSC_EN_REG_SEL_REG, 8'b0001_1111, top_test_cfg.pads);

    //reset tsc
    `WR_NORMAL_REG(`SOC_ANAC_CTRL_REG, 8'b0000_0100, top_test_cfg.pads);    
    `WR_NORMAL_REG(`SOC_ANAC_CTRL_REG, 8'b0000_0000, top_test_cfg.pads);    

    //do begin
    //    `nnc_info("", "read busy doing....", NNC_LOW);
    //   `RD_NORMAL_REG(`SOC_SMP_STS_REG, top_test_cfg.pads, top_test_cfg.rdata);
    //    `nnc_info("", $sformatf("read busy doing.... %h", top_test_cfg.rdata), NNC_LOW);
    //end while(top_test_cfg.rdata[0] === 1);
    //`nnc_info("", "read busy finish!", NNC_LOW);

    //`RD_NORMAL_REG(`SOC_VDAC_NOR0_REG, top_test_cfg.pads, top_test_cfg.rdata);
    //
    //if(top_test_cfg.rdata === top_test_cfg.sensor_temperature) begin
    //    `nnc_error("", "the room temperature error!!!");  //in spi mode, sar result is unchange
    //end    

    repeat(5) begin
        assert(top_test_cfg.randomize() with {reg_addr == `SOC_TSC_CTRL_REG;});
        `nnc_info("SOC_TEST", "Single Writing to a Register", NNC_LOW)
        `WR_NORMAL_REG(`SOC_TSC_CTRL_REG, top_test_cfg.tsc_ctrl, top_test_cfg.pads);
        `WR_NORMAL_REG(`SOC_TSC_VDAC8B_DIN_CH1_REG, top_test_cfg.tsc_vdac_din, top_test_cfg.pads);
   
        #500ns;
        if(top_test_cfg.tsc_ctrl[2:0] !== {`ANA_TOP.tsc_monitoring_ch1.D2A_VDAC8B_EN_CHx, `ANA_TOP.tsc_monitoring_ch1.D2A_TSC_COMP_EN_CHx, `ANA_TOP.tsc_monitoring_ch1.D2A_TSC_EN_CHx})begin
            `nnc_error("SOC_TEST", "tsc_ctrl error in spi mode");
        end
        if(top_test_cfg.tsc_vdac_din !== `ANA_TOP.tsc_monitoring_ch1.D2A_VDAC8B_DIN_CHx)begin
            `nnc_error("SOC_TEST", "8bit_dac_din error in spi mode");
        end
    end

`endif

    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    #10000ns;
    `nnc_info("SOC_TEST", "soc_anac_tsc_spi_test end now", NNC_LOW)

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
