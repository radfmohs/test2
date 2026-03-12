/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_sysc_dig_reset_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_sysc_dig_reset_test                                             
// Designer	: pfwang@nanochap.com                                                                 
// Date		: 23-05-2025                                                                     
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_sysc_dig_reset_test
`define TESTCFG soc_sysc_dig_reset_test_cfg

class `TESTCFG extends soc_sysc_reg_reset_test_cfg;

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

  function new (string name = "soc_sysc_dig_reset_test_cfg");
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
class `TESTNAME extends soc_sysc_reg_reset_test;
   
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

    //assert(top_test_cfg.randomize());

    //`DUT_IF.testmode_sel = top_test_cfg.testmode_sel;

    //`DUT_IF.spimode_sel = top_test_cfg.spimode_sel;

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
    
    //super.main_phase(phase);

    `nnc_info("SOC_TEST", "soc_sysc_dig_reset_test start", NNC_LOW)

    // ==================================================================================
    // Please add your code of your test here
    // ---------------------------------------------------------------------------------- 
    
       // repeat(5) begin
        assert(top_test_cfg.randomize() with {reg_addr == `SOC_CLK_CTRL_REG; no_of_bytes == 8'h01; dig_rst_reg == 0;});
        `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);
        
        `WR_NORMAL_REG(`SOC_PMU_REG, top_test_cfg.pmu_reg0, top_test_cfg.pads);

        foreach(`DUT_IF.reg_normal[i]) begin
            if(i!==`SOC_PMU_REG && i!==`SOC_CLK_CTRL_REG && i!==`SOC_PMU_REG1)`WR_NORMAL_REG(i, 8'hFF, top_test_cfg.pads);
        end

        foreach(`DUT_IF.reg_wavegen[i]) begin
            `WR_WAVEGEN_REG(i, 8'hFF, top_test_cfg.pads);
        end

        fork:dig_rst
        `WR_NORMAL_REG(`SOC_PMU_REG1, top_test_cfg.pmu_reg1, top_test_cfg.pads);
        join_none
        `nnc_info("SOC_TEST", "dig rst done", NNC_LOW)
        
        @(negedge `CLK_CTRL_TOP.poresetn); 
        #10;
        `ifdef POSTLAYOUT
        if(`WG_DRIVER_TOP.i_presetn /*|| `LEADOFF_WRAPPER_TOP.i_presetn*/ /*||  `SPI_TOP.i_rst_n || `PMU_CTRL_TOP.poresetn_hf  || `CLK_CTRL_TOP.presetn*/ /*|| `CLK_CTRL_TOP.poresetn*/  /*|| `ANAC_TOP.presetn*/ || `EPROM_TOP.rst_n)
        `else
        if(`WG_DRIVER_TOP.i_presetn /*|| `LEADOFF_WRAPPER_TOP.i_presetn*/ /*||  `SPI_TOP.i_rst_n || `PMU_CTRL_TOP.poresetn_hf  || `CLK_CTRL_TOP.presetn || `CLK_CTRL_TOP.poresetn  || `ANAC_TOP.presetn */|| `EPROM_TOP.rst_n)
        `endif
            `nnc_error("SOC_TEST", "RESETn error!!!");        
       
        wait fork;
        
        top_test_cfg.rd_data=new[1];
        foreach(`DUT_IF.reg_normal[i]) begin
            `RD_NORMAL_REG(i, top_test_cfg.pads, top_test_cfg.rd_data[0]);
            if(i===8'h0b) continue;  //debug_reg1[0] reload_done
            if(i===8'h73) continue;  //debug_reg1[0] reload_done
            if(`DUT_IF.reg_normal[i][31:24] !==8'bxx && top_test_cfg.rd_data[0] !== `DUT_IF.reg_normal[i][31:24]) `nnc_error("SOC_TEST", $sformatf("normal_reg[%8h] initial value error!!! r_data=%8h  exp_data=%8h", i, top_test_cfg.rd_data[0], `DUT_IF.reg_normal[i][31:24]));
        end
        
        foreach(`DUT_IF.reg_wavegen[i]) begin
            `RD_WAVEGEN_REG(i, top_test_cfg.pads, top_test_cfg.rd_data[0]);
            if(i===8'h6b) continue; 
            if(`DUT_IF.reg_wavegen[i][31:24] !==8'bxx && top_test_cfg.rd_data[0] !== `DUT_IF.reg_wavegen[i][31:24]) `nnc_error("SOC_TEST", $sformatf("wavegen_reg[%8h] initial value error!!! r_data=%8h  exp_data=%8h", i, top_test_cfg.rd_data[0], `DUT_IF.reg_wavegen[i][31:24]));
        end

        `ifdef POSTLAYOUT
        if(`WG_DRIVER_TOP.i_presetn &&  `SPI_TOP.i_rst_n && `PMU_CTRL_TOP.poresetn_hf  && /*`LEADOFF_WRAPPER_TOP.i_presetn*/ /*&& `CLK_CTRL_TOP.presetn*/ && `CLK_CTRL_TOP.poresetn  /*&& `ANAC_TOP.presetn*/ && `EPROM_TOP.rst_n && `EPROM_TOP.RESETb);
        `else
        if(`WG_DRIVER_TOP.i_presetn &&  `SPI_TOP.i_rst_n && `PMU_CTRL_TOP.poresetn_hf  && /*`LEADOFF_WRAPPER_TOP.i_presetn &&*/ `CLK_CTRL_TOP.presetn && `CLK_CTRL_TOP.poresetn  && `ANAC_TOP.presetn && `EPROM_TOP.rst_n && `EPROM_TOP.RESETb);
        `endif
        else  `nnc_error("SOC_TEST", "RESETn error!!!");

        #200us;
    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    #10000ns;
    `nnc_info("SOC_TEST", "soc_sysc_dig_reset_test end now", NNC_LOW)

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
