/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_pmu_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_pmu_test                                             
// Designer	: ophina@nanochap.com                                                                 
// Date		: 18-03-2024                                                                  
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_pmu_test
`define TESTCFG soc_pmu_test_cfg

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

  function new (string name = "soc_pmu_test_cfg");
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

    assert(top_test_cfg.randomize());

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

    `nnc_info("SOC_TEST", "soc_pmu_test start", NNC_LOW)

    // ==================================================================================
    // Please add your code of your test here
    // ----------------------------------------------------------------------------------
        //fast osr is considered to fast up sim
        assert(top_test_cfg.randomize() with { reg_addr == `SOC_IMEAS_REG_1; wr_data[0] == 8'h00;});// OSR:8
        `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

        assert(top_test_cfg.randomize() with {reg_addr == `SOC_IMEAS_REG_0; wr_data[0] == (`INIT_SOC_IMEAS_REG_0 | 8'b0000_0001);});
        `nnc_info("SOC_TEST", "Enable imeas block as it will be disabled by default!", NNC_LOW)
        `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

	wait(`CLK_CTRL_TOP.enable_cic === 1'b1);
        #1ms;

        assert(top_test_cfg.randomize() with {reg_addr == `SOC_PMU_REG; wr_data[0] == (`INIT_SOC_PMU_REG | 8'b0000_0010);});
        `nnc_info("SOC_TEST", "Enter Deepsleep state!", NNC_LOW)
        `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

	wait(`CLK_CTRL_TOP.pmu_fclk_en === 1'b0);
	#1ms;

	repeat(1000) begin
	  #10ns;
	`ifdef POSTLAYOUT
	  if(!`CLK_CTRL_TOP.fclk_inv_bak !== 0)
        `else
          if(`CLK_CTRL_TOP.fclk !== 0)
        `endif   
		`nnc_error("SOC_TEST", "Error! Unexpected fclk running!!!");
	end
        #5ms;
	
        assert(top_test_cfg.randomize() with {reg_addr == `SOC_PMU_REG; wr_data[0] == (`INIT_SOC_PMU_REG | 8'b0000_0100);});
        `nnc_info("SOC_TEST", "Enter idle state by wakeup using hresetreq!", NNC_LOW)
        `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

	wait(`CLK_CTRL_TOP.pmu_fclk_en === 1'b1);
        #1ms;

	assert(top_test_cfg.randomize() with {reg_addr == `SOC_PMU_REG; wr_data[0] == (`INIT_SOC_PMU_REG | 8'b0101_1000);});
        `nnc_info("SOC_TEST", "Disable OTP/Wavegen/lead-off clk, fclk running!", NNC_LOW)
        `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

	assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANAC_CTRL_REG; wr_data[0] == (`INIT_SOC_ANAC_CTRL_REG | 8'b0000_1001);});
        `nnc_info("SOC_TEST", "Disable ANAC/TEMP_SAR clk, fclk running!", NNC_LOW)
        `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

	fork
	begin
	  assert(top_test_cfg.randomize() with {reg_addr == `SOC_IMEAS_REG_0; wr_data[0] == `INIT_SOC_IMEAS_REG_0;});
          `nnc_info("SOC_TEST", "Disable imeas block!", NNC_LOW)
          `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
	end
	begin
	   wait(`IMEAS_WRAPPER_TOP.meas_done_pos === 1);
           wait(`IMEAS_WRAPPER_TOP.meas_done_pos === 0);
	end
	join

	#1ms;
	repeat(1000) begin
	  #10ns;
	  if(`CLK_CTRL_TOP.otp_pclk !== 0)
		`nnc_error("SOC_TEST", "Error! Unexpected otp_pclk running!!!");
	  if(`CLK_CTRL_TOP.wave_gen_pclk !== 0)
		`nnc_error("SOC_TEST", "Error! Unexpected wave_gen_pclk running!!!");
	  if(`CLK_CTRL_TOP.lead_off_pclk !== 0)
		`nnc_error("SOC_TEST", "Error! Unexpected lead_off_pclk running!!!");
	  if(`CLK_CTRL_TOP.anac_pclk !== 0)
		`nnc_error("SOC_TEST", "Error! Unexpected anac_pclk running!!!");
	  if(`CLK_CTRL_TOP.temp_sar_pclk !== 0)
		`nnc_error("SOC_TEST", "Error! Unexpected temp_sar_pclk running!!!");
	  if(`CLK_CTRL_TOP.imeas_pclk !== 0)
		`nnc_error("SOC_TEST", "Error! Unexpected imeas_pclk running!!!");
	end
        #5ms;

	assert(top_test_cfg.randomize() with {reg_addr == `SOC_PMU_REG; wr_data[0] == `INIT_SOC_PMU_REG;});
        `nnc_info("SOC_TEST", "Enable OTP/Wavegen/lead-off clk, fclk running!", NNC_LOW)
        `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

	assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANAC_CTRL_REG; wr_data[0] == `INIT_SOC_ANAC_CTRL_REG;});
        `nnc_info("SOC_TEST", "Enable ANAC/TEMP_SAR clk, fclk running!", NNC_LOW)
        `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

        assert(top_test_cfg.randomize() with {reg_addr == `SOC_IMEAS_REG_0; wr_data[0] == (`INIT_SOC_IMEAS_REG_0 | 8'b0000_0001);});
        `nnc_info("SOC_TEST", "Enable imeas block!", NNC_LOW)
        `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

	#100us;
	assert(top_test_cfg.randomize() with {reg_addr == `SOC_PMU_REG; wr_data[0] == (`INIT_SOC_PMU_REG | 8'b0010_0000);});
        `nnc_info("SOC_TEST", "Apply wavegen reset 0!", NNC_LOW)
        `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

	wait(`RST_CTRL_TOP.wave_gen_presetn === 1'b0);
	#1us;

	assert(top_test_cfg.randomize() with {reg_addr == `SOC_PMU_REG; wr_data[0] == `INIT_SOC_PMU_REG;});
        `nnc_info("SOC_TEST", "Apply wavegen reset 1!", NNC_LOW)
        `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

	wait(`RST_CTRL_TOP.wave_gen_presetn === 1'b1);

	#100us;
	assert(top_test_cfg.randomize() with {reg_addr == `SOC_PMU_REG; wr_data[0] == (`INIT_SOC_PMU_REG | 8'b1000_0000);});
        `nnc_info("SOC_TEST", "Apply leadoff reset 0!", NNC_LOW)
        `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

	wait(`RST_CTRL_TOP.lead_off_presetn === 1'b0);
	#1us;

	assert(top_test_cfg.randomize() with {reg_addr == `SOC_PMU_REG; wr_data[0] == `INIT_SOC_PMU_REG;});
        `nnc_info("SOC_TEST", "Apply leadoff reset 1!", NNC_LOW)
        `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

	#100us;
	assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANAC_CTRL_REG; wr_data[0] == (`INIT_SOC_ANAC_CTRL_REG | 8'b0000_0010);});
        `nnc_info("SOC_TEST", "Apply ANAC reset 0!", NNC_LOW)
        `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

	wait(`RST_CTRL_TOP.anac_presetn === 1'b0);
	#1us;

	assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANAC_CTRL_REG; wr_data[0] == `INIT_SOC_ANAC_CTRL_REG;});
        `nnc_info("SOC_TEST", "Apply ANAC reset 1!", NNC_LOW)
        `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

	wait(`RST_CTRL_TOP.anac_presetn === 1'b1);

	#100us;
	assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANAC_CTRL_REG; wr_data[0] == (`INIT_SOC_ANAC_CTRL_REG | 8'b0000_0100);});
        `nnc_info("SOC_TEST", "Apply TEMP_SAR reset 0!", NNC_LOW)
        `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

	wait(`RST_CTRL_TOP.temp_sar_presetn === 1'b0);
	#1us;

	assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANAC_CTRL_REG; wr_data[0] == `INIT_SOC_ANAC_CTRL_REG;});
        `nnc_info("SOC_TEST", "Apply TEMP_SAR reset 1!", NNC_LOW)
        `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

	wait(`RST_CTRL_TOP.temp_sar_presetn === 1'b1);

	#100us;
	assert(top_test_cfg.randomize() with {reg_addr == `SOC_PMU_REG1; wr_data[0] == (`INIT_SOC_PMU_REG1 | 8'b0000_0001);});
        `nnc_info("SOC_TEST", "Apply OTP reset 0!", NNC_LOW)
        `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

	wait(`RST_CTRL_TOP.otp_rstn === 1'b0);
	#1us;

	assert(top_test_cfg.randomize() with {reg_addr == `SOC_PMU_REG1; wr_data[0] == `INIT_SOC_PMU_REG1;});
        `nnc_info("SOC_TEST", "Apply OTP reset 1!", NNC_LOW)
        `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

	wait(`RST_CTRL_TOP.otp_rstn === 1'b1);
	
    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    #1ms;
    `nnc_info("SOC_TEST", "soc_pmu_test end now", NNC_LOW)

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
