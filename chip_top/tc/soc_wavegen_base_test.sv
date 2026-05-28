/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_wavegen_base_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_wavegen_base_test                                             
// Designer	: ddang@nanochap.com                                                                 
// Date		: 18-10-2024                                                                     
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_wavegen_base_test
`define TESTCFG soc_wavegen_base_test_cfg

class `TESTCFG extends soc_base_test_cfg;

  `nnc_object_utils(`TESTCFG)

  // ===============================================
  // Adding your new varialbles in config test
  // -----------------------------------------------

  //rand logic [7:0] expected_data;
  //logic [7:0]      rd_data[];
    logic [7:0]      rd_data[256];

    rand logic [15:0] wavegen_drv_mode; // 0: Source and 1: Pull
    rand logic [7:0]  wg_glb_reg;
    rand logic [7:0]  pads;
    rand logic [15:0] wavegen_drv_en;   // 0: disable, 1: enable


  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_wavegen_base_test_cfg");
    super.new(name);
    
  endfunction: new

  // ===============================================
  // Adding constraints of randomization
  // -----------------------------------------------

  // testmode_sel[1:0] : 00-Normal mode, 01: Scanmode, 10: BIST mode, 11 atm0/1/2/3/4
  // constraint c_testmode_sel { soft testmode_sel == 2'b00; }

  // spimode_sel[1:0] :  
  // constraint c_spimode_sel { spimode_sel == 2'b00; }
  
  // Set GLOBE_DRIVE_EN to 0 as disable both drive 0 and drive 1 can be driven
  // at the time
    constraint c_wg_glb_reg  {wg_glb_reg[0] == 0;}

    constraint c_wavegen_drv_mode  { foreach (wavegen_drv_mode[i]) { if (!wavegen_drv_en[i]) wavegen_drv_mode[i] == 0; } // 0 is Source and 1 is Sink 
                                     $countones(wavegen_drv_mode) == 1;
                                   } 

    constraint c_wavegen_drv_en { $countones(wavegen_drv_en) == 2; } // 0 and 1 is enabled

    constraint c_wg_scoreboard_en { wg_scoreboard_en == 1; } // 0 and 1 is enabled

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

    // Assign your settings to DUT Interface   
    // `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    // `DUT_IF.spimode_sel = top_test_cfg.spimode_sel;

    // 00: Driver0-3, 01: Driver4-7, 10: Driver8-11, 11: Driver12-15
    `DUT_IF.DRIVE_SLCT = top_test_cfg.wg_glb_reg[2:1];
    `DUT_IF.wavegen_drv_mode = top_test_cfg.wavegen_drv_mode;
    `DUT_IF.wavegen_drv_en = top_test_cfg.wavegen_drv_en;
    `DUT_IF.wg_scoreboard_en = top_test_cfg.wg_scoreboard_en;

    // -------------------
    // Scoreboard enables
    // -------------------
    // `SPIM_SCOREBOARD_EN = 1;
    // `ANALOG_SCOREBOARD_EN = 1;
    `NNC_WAVEGEN_REF_SCB_EN = 0;
    phase.drop_objection(this);
  endtask : pre_reset_phase

  // -----------------------------------------
  // Declare the reset_phase task 
  // -----------------------------------------
  virtual task reset_phase(nnc_phase phase);
    phase.raise_objection(this);

    super.reset_phase(phase);

    phase.drop_objection(this);
  endtask : reset_phase

  // -----------------------------------------
  // Declare the main_phase task of your test
  // -----------------------------------------
  virtual task main_phase(nnc_phase phase);
    phase.raise_objection(this);

    super.main_phase(phase);

    `nnc_info("SOC_TEST", "soc_wavegen_base_test start", NNC_LOW)

    // ==================================================================================
    // Please add your code of your test here
    // ---------------------------------------------------------------------------------- 
    // ??? Only CFG0, how is CFG1??? for Wavegen 0 -> how is another
    // wavegens????
    //`WR_WAVEGEN_REG(`SOC_AWG_DRIVEC_SW_CFG0_REG, 8'hFF, 8'h00);

    // Select Driver Group 
    `WR_NORMAL_REG(`SOC_WAVEGEN_GLOBAL_REG, top_test_cfg.wg_glb_reg, 8'h00);

    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    #10000ns;
    `nnc_info("SOC_TEST", "soc_wavegen_base_test end now", NNC_LOW)

    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ==================================================================================

    phase.drop_objection(this);
  endtask: main_phase

  // ---------------------------------------
  // post_main_phase is run after main_phase
  // ---------------------------------------
  virtual task post_main_phase(nnc_phase phase);
    phase.raise_objection(this);

    super.post_main_phase(phase);

    if (`DUT_IF.python_check_en === 1)
      `SOC_TB.py_tb.do_run_python();

    phase.drop_objection(this);
  endtask

  //  task wavegen_drv_enable;
  //  begin
  //    `nnc_info("SOC_TEST", $sformatf("enabling chip_0 wavegen sb now"), NNC_LOW)
  //    `WAVEGEN_SCB_DRV_0_EN = 1'b1;
  //    `WAVEGEN_SCB_DRV_1_EN = 1'b1;
  //    // --------------------------------------------------------
  //    // Write to SOC_WAVEGEN_GLOBAL_REG to sync drivers
  //    // --------------------------------------------------------
  //    assert(top_test_cfg.randomize() with {reg_addr == `SOC_WAVEGEN_GLOBAL_REG; wr_data[0] == 8'h01;});
  //    `nnc_info("SOC_TEST", "Enable drivers using global register", NNC_LOW)
  //    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
  //  end
  //  endtask

  // ------------------------------
  // Declare the report_phase task
  // ------------------------------
  function void report_phase(nnc_phase phase) ;
    super.report_phase(phase);
  endfunction

endclass : `TESTNAME
