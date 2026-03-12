/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_sysc_clkdiv_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_sysc_clkdiv_test                                             
// Designer	: pfwang@nanochap.com                                                                 
// Date		: 18-03-2024                                                                     
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_sysc_clkdiv_test
`define TESTCFG soc_sysc_clkdiv_test_cfg

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
  logic [7:0]      rdata;
  logic [7:0]      imeas_reg0_rdata;


  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_sysc_clkdiv_test_cfg");
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

    assert(top_test_cfg.randomize() with {hfosc_jitter == 1'b0; hfosc_variation == 100;});

    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    
    `DUT_IF.hfosc_jitter = top_test_cfg.hfosc_jitter;    

    `DUT_IF.hfosc_variation = top_test_cfg.hfosc_variation;
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

    `nnc_info("SOC_TEST", "soc_sysc_clkdiv_test start", NNC_LOW)

    // ==================================================================================
    // Please add your code of your test here
    // ---------------------------------------------------------------------------------- 
    

    repeat(5) begin:_repeat
        //set clk_cfg_reg
       // assert(top_test_cfg.randomize() with {reg_addr == `SOC_PMU_REG; no_of_bytes == 1;});
       // `nnc_info("SOC_TEST", "Configure clk-ctrl register", NNC_LOW)
       // `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data,  top_test_cfg.pads);
        
        assert(top_test_cfg.randomize() with {reg_addr == `SOC_CLK_CTRL_REG; no_of_bytes == 1;});
        `nnc_info("SOC_TEST", "Configure clk-ctrl register", NNC_LOW)
        `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0],  top_test_cfg.pads);
        
        assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANAC_CTRL_REG; no_of_bytes == 1;});
        `nnc_info("SOC_TEST", "Configure clk_gating register", NNC_LOW)
        `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0],  top_test_cfg.pads);
                        
        assert(top_test_cfg.randomize() with {reg_addr == `SOC_PMU_REG; no_of_bytes == 1; });
        `nnc_info("SOC_TEST", "Configure pmu register", NNC_LOW)
        `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0],  top_test_cfg.pads);

        //assert(top_test_cfg.randomize() with {reg_addr == `SOC_PMU_REG1; no_of_bytes == 1; data[0][1]!=1'b0;});
        //`nnc_info("SOC_TEST", "Configure pmu1 register", NNC_LOW)
        //`WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0],  top_test_cfg.pads);

        assert(top_test_cfg.randomize() with {reg_addr == `SOC_OUT_CLK_SEL_REG; no_of_bytes == 1; });
        `nnc_info("SOC_TEST", "Configure Oclksel register", NNC_LOW)
        `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0],  top_test_cfg.pads);

        assert(top_test_cfg.randomize() with {reg_addr == `SOC_IMEAS_REG_0; no_of_bytes == 1; });
        `nnc_info("SOC_TEST", "Configure Oclksel register", NNC_LOW)
        `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0],  top_test_cfg.pads);

        //`DUT_IF.pclk_sel = top_test_cfg.data[8'h0][2:0];
        force `SOC_TB.IOBUF_PAD[10] = $random;
        force `CLK_CTRL_TOP.u_cmsdk_clock_gate_iadc_clk[0].enable = 1;
        force `CLK_CTRL_TOP.u_cmsdk_clock_gate_analog_adcclk.enable = 1;
        top_test_cfg.rd_data = new[4];
        assert(top_test_cfg.randomize() with {reg_addr == `SOC_PMU_REG; no_of_bytes == 6; });
        `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);

        assert(top_test_cfg.randomize() with {reg_addr == `SOC_IMEAS_REG_0; });
        `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.imeas_reg0_rdata);        

        `nnc_info("SOC_TEST", $sformatf("clk_reg = %h , gpio_10 = %h ,pmu_reg = %h ,anac_reg = %h", top_test_cfg.rd_data[2], `SOC_TB.IOBUF_PAD[10],top_test_cfg.rd_data[3], top_test_cfg.rd_data[0]), NNC_LOW)
        assert(`SYS_CTRL_CFG.randomize() with{clk_cfg_reg == top_test_cfg.rd_data[4]; pmu_reg == top_test_cfg.rd_data[5]; anac_reg == top_test_cfg.rd_data[2]; O_clk_sel_reg == top_test_cfg.rd_data[0]; adc_clk_inv == top_test_cfg.imeas_reg0_rdata[4];});    
        `CLKDIV_CHECK_EN = 1'b1;
        ////START conversion
        //if(top_test_cfg.start_src === PIN) begin
        //	//Set START pin to 1
        //	`nnc_info("SOC_TEST", "Set the START CONVERSION pin", NNC_LOW)
        //	`DUT_IF.start_en = 1;
        //    repeat(2) @(posedge `CLK_CTRL_TOP.pclk);
        //    `DUT_IF.start_en = 0;
        //    repeat(2) @(posedge `CLK_CTRL_TOP.pclk);
        //end
        //else if(top_test_cfg.start_src === CMD) begin
        //	// Start/Restart (Synchronize) Conversion
        //	assert(top_test_cfg.randomize() with { cmd == `SOC_START_CONV_CMD;});
        //	`nnc_info("SOC_TEST", "Requesting the START/RESTART CONVERSION CMD", NNC_LOW)
        //	`WR_OP(top_test_cfg.cmd);
        //end

        //#1;
        //if (!`SOC_TOP.IOBUF_PAD[1]) `nnc_error("", "DRDYn error!!!"); 
        //
        //fork :drdy
        //    @(negedge `SOC_TOP.IOBUF_PAD[1]);
        //    begin #44ms `nnc_fatal("SOC_TOP", "drdy timeout!!!"); end
        //join_any
        //disable drdy;

        //`nnc_info("SOC_TEST", "DATA READY", NNC_LOW)

        ////read data
        //// RDATA Command
        //assert(top_test_cfg.randomize () with {no_of_conversions == 0;});
        //`nnc_info("SOC_TEST", "Requesting the RDATA CMD", NNC_LOW)
        //`RDATA(top_test_cfg.no_of_conversions, top_test_cfg.read_conversion_data);
        
        #2ms;
        `CLKDIV_CHECK_EN = 1'b0;
        release `SOC_TB.IOBUF_PAD[10];
        //if (!`SOC_TOP.DRDYn) `nnc_error("", "DRDYn error!!!");
    end : _repeat







    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    #10000ns;
    `nnc_info("SOC_TEST", "soc_sysc_clkdiv_test end now", NNC_LOW)

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
