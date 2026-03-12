/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_anac_comp_input_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_anac_comp_input_test                                             
// Designer	: ophina@nanochap.com                                                                 
// Date		: 18-03-2024                                                                   
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_anac_comp_input_test
`define TESTCFG soc_anac_comp_input_test_cfg

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
  logic [7:0]      sine_data[128];
  logic [13:0]     clk_freq;//in Khz
  logic [12:0]     half_period_limit;
  rand logic [12:0] half_period0;
  rand logic [12:0] half_period1;
  rand logic [12:0] half_period2;
  logic [31:0]     hlf_wave_lim; // number of clocks for positive half wave
  logic [31:0]     neg_hlf_wave_lim; // number of clocks for negative half wave
  logic [31:0]     hlf_wave0_lim; // number of clocks per point for positive half wave0
  logic [31:0]     neg_hlf_wave0_lim; // number of clocks per point for negative half wave0
  logic [31:0]     hlf_wave1_lim; // number of clocks per point for positive half wave1
  logic [31:0]     neg_hlf_wave1_lim; // number of clocks per point for negative half wave1
  logic [31:0]     hlf_wave2_lim; // number of clocks per point for positive half wave2
  logic [31:0]     neg_hlf_wave2_lim; // number of clocks per point for negative half wave2
  logic [15:0]     rest_lim; // number of clocks for each rest period
  logic [31:0]     silent_lim; // number of clocks for each silent period
  rand logic [1:0] preload_sel;
  rand logic       neg_ena;
  rand logic       pos_dis;
  rand logic [2:0] points_sel;
  rand logic [2:0] waveform_sel;
  rand logic       load_points_sel;
  rand logic       pos_neg_diff_sel;
  rand logic       dac_bit_len_sel;//1'b0:8-bits; 1'b1:12-bits (only 8 bits supported for sine)
  rand logic       auto_man;//1'b0:auto; 1'b1:manual
  rand logic [7:0] dac0_data_l;
  rand logic [3:0] dac0_data_h;
  rand logic [2:0] dac0_msb_sel;
  rand logic [7:0] dac1_data_l;
  rand logic [3:0] dac1_data_h;
  rand logic [2:0] dac1_msb_sel;
  rand logic       PULLAB_pos_en;
  rand logic       PULLAB_neg_en;
  rand logic [5:0] PULLAB_lim;
  rand logic [7:0] CH1_ADDR1;
  rand logic [7:0] CH1_ADDR2;
  rand logic [7:0] CH2_ADDR1;
  rand logic [7:0] CH2_ADDR2;
  rand logic       comp_CH1_level;//1'b1: level; 1'b0: rise/fall
  rand logic       comp_CH2_level;//1'b1: level; 1'b0: rise/fall
  rand logic       comp_val;//1'b1: high value comparison; 1'b0: low value comparison
  rand logic       comp_CH1_trans_sel;//1'b1: 1 -> 0 transition; 1'b0: 0 -> 1 transition
  rand logic       comp_CH2_trans_sel;//1'b1: 1 -> 0 transition; 1'b0: 0 -> 1 transition
  rand logic [1:0] A2D_comp_sel;
       logic [1:0] PRELOAD;
       logic       LOAD_POINTS;
       logic [7:0] NO_OF_POINTS;
       logic [7:0] NO_OF_LOAD_POINTS;
       logic [2:0] NO_OF_WAVEFORMS;
       logic       NEG_ON;
       logic       POS_OFF;
       logic       POS_NEG_DIFF;
       integer     cnt;
  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_anac_comp_input_test_cfg");
    super.new(name);
    
  endfunction: new

  // ===============================================
  // Adding constraints of randomization
  // -----------------------------------------------

  // testmode_sel[1:0] : 00-Normal mode, 01: Scanmode, 10: BIST mode, 11 atm0/1/2/3/4
  constraint c_testmode_sel    { soft testmode_sel == 2'b00; }

  // spimode_sel[1:0] :  
  //constraint c_spimode_sel     { spimode_sel == 2'b00; }

  // spi_sclk_freq[15:0]
  //constraint c_spi_sclk_freq   { soft spi_sclk_freq inside {[100:20000]};}//min 100Khz - max 20Mhz

  //pclk_div[2:0]
  //constraint c_pclk_sel    { soft pclk_sel inside {[0:1]};}

  //hfosc_jitter
  constraint c_hfosc_jitter    { soft hfosc_jitter == 0; }// 0%

  //hfosc_variation
  constraint c_hfosc_variation { soft hfosc_variation == 100; }// 0%

  // No of bytes in a burst
  constraint c_no_of_bytes     { soft no_of_bytes == 2; }

  // pads values
  constraint c_pads            { soft pads == 8'h00; }

  // mask values
  constraint c_mask            { soft mask == 8'hff; }

  // altf_sel
  //constraint c_altf_sel    { soft altf_sel == 2'b00; }

  //preload_sel
  constraint c_preload_sel     { preload_sel inside {3,3};}

  //neg_ena
  constraint c_neg_ena         { (/*(load_points_sel == 1'b1) || */(pos_neg_diff_sel == 1'b1)) -> neg_ena == 1'b1;}

  //pos_dis
  constraint c_pos_dis         { ((neg_ena == 1'b0)/* || (load_points_sel == 1'b1)*/ || (pos_neg_diff_sel == 1'b1)) -> pos_dis == 1'b0;}

  //points_sel
  constraint c_points_sel      { (load_points_sel == 1'b0) -> points_sel != 6;
                                 ((waveform_sel == 3'b000) && (neg_ena == 1'b1) && (pos_dis == 1'b0) && (pos_neg_diff_sel == 1'b0)) -> points_sel inside {[0:6]};
                                 ((waveform_sel == 3'b000) && (neg_ena == 1'b1) && (pos_dis == 1'b0) && (pos_neg_diff_sel == 1'b1)) -> points_sel inside {[0:7]};
                                 ((waveform_sel == 3'b001) && (neg_ena == 1'b1) && (pos_dis == 1'b0) && (pos_neg_diff_sel == 1'b0)) -> points_sel inside {[1:6]};
                                 ((waveform_sel == 3'b001) && (neg_ena == 1'b1) && (pos_dis == 1'b0) && (pos_neg_diff_sel == 1'b1)) -> points_sel inside {[0:6]};
                                 ((waveform_sel == 3'b010) && (neg_ena == 1'b1) && (pos_dis == 1'b0) && (pos_neg_diff_sel == 1'b0)) -> points_sel inside {[2:6]};
                                 ((waveform_sel == 3'b010) && (neg_ena == 1'b1) && (pos_dis == 1'b0) && (pos_neg_diff_sel == 1'b1)) -> points_sel inside {[1:6]};
                                 ((waveform_sel == 3'b000) && ((neg_ena == 1'b0) || (pos_dis == 1'b1))) -> points_sel inside {[0:7]};
                                 ((waveform_sel == 3'b001) && ((neg_ena == 1'b0) || (pos_dis == 1'b1))) -> points_sel inside {[0:6]};
                                 ((waveform_sel == 3'b010) && ((neg_ena == 1'b0) || (pos_dis == 1'b1))) -> points_sel inside {[1:6]};
                               }

  //waveform_sel
  constraint c_waveform_sel    { waveform_sel inside {[0:0]};}

  //load_points_sel
  constraint c_load_points_sel { load_points_sel == 1'b1;}

  //pos_neg_diff_sel
  constraint c_pos_neg_diff_sel { pos_neg_diff_sel == 1'b0;}

  //auto_man
  constraint c_auto_man        { auto_man == 1'b0;}

  //dac_bit_len_sel
  constraint c_dac_bit_len_sel { dac_bit_len_sel == 1'b0;}

  //dac0_msb_sel
  constraint c_dac0_msb_sel    { dac0_msb_sel inside {[0:4]};}

  //dac1_msb_sel
  constraint c_dac1_msb_sel    { dac1_msb_sel inside {[0:4]};}

  //PULLAB_lim
  constraint c_PULLAB_lim      { PULLAB_lim != 0;}

  //A2D_comp_sel
  constraint c_A2D_comp_sel    { soft A2D_comp_sel == 2'b00; }

  //CH1_ADDR1
  constraint c_CH1_ADDR1       { CH1_ADDR1 inside {[0:127]};}
  //CH1_ADDR2
  constraint c_CH1_ADDR2       { CH1_ADDR2 inside {[0:127]}; CH1_ADDR2 > CH1_ADDR1;}

  //CH2_ADDR1
  constraint c_CH2_ADDR1       { CH2_ADDR1 inside {[0:127]};}
  //CH2_ADDR2
  constraint c_CH2_ADDR2       { CH2_ADDR2 inside {[0:127]}; CH2_ADDR2 > CH2_ADDR1;}

  //comp_CH1_level
  constraint c_comp_CH1_level  { comp_CH1_level == 1'b1;}

  //comp_CH2_level
  constraint c_comp_CH2_level  { comp_CH2_level == 1'b1;}

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
    `nnc_top.set_timeout(7s);
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

    //`DUT_IF.spimode_sel = top_test_cfg.spimode_sel;

    //`DUT_IF.spi_sclk_freq = top_test_cfg.spi_sclk_freq;

    //`DUT_IF.pclk_sel = top_test_cfg.pclk_sel;
    `DUT_IF.hfosc_jitter = top_test_cfg.hfosc_jitter;
    `DUT_IF.hfosc_variation = top_test_cfg.hfosc_variation;
    //`DUT_IF.altf_sel = top_test_cfg.altf_sel;

    //`DUT_IF.A2D_comp_sel = top_test_cfg.A2D_comp_sel;

    `DUT_IF.assertion_on = 1;

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

    `nnc_info("SOC_TEST", "soc_anac_comp_input_test start", NNC_LOW)

    // ==================================================================================
    // Please add your code of your test here
    // ----------------------------------------------------------------------------------
    //wavegen_setup(0);//chip 0

    //wavegen_drv_config(`WAVEGEN_0_ADDR_BASE);
    //wavegen_drv_config(`WAVEGEN_1_ADDR_BASE);

    // ------------------------------------------------------------------------------
    // Write to SOC_ANA_COMP_INT_EN_REG (To enable the analog comp ch1 & ch2 interrupts)
    // ------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_COMP_INT_EN_REG; wr_data[0] == {top_test_cfg.comp_CH2_trans_sel, top_test_cfg.comp_CH1_trans_sel, 1'b1, 1'b1, 1'b0};});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    if(top_test_cfg.comp_CH1_trans_sel === 1)
    	`nnc_info("SOC_TEST", "Enable CH1 interrupt with fall trans enable!", NNC_LOW)
    else
	`nnc_info("SOC_TEST", "Enable CH1 interrupt with rise trans enable!", NNC_LOW)
    if(top_test_cfg.comp_CH2_trans_sel === 1)
    	`nnc_info("SOC_TEST", "Enable CH2 interrupt with fall trans enable!", NNC_LOW)
    else
	`nnc_info("SOC_TEST", "Enable CH2 interrupt with rise trans enable!", NNC_LOW)
/*
    // ------------------------------------------------------------------------------
    // Write to SOC_ANA_INT_CH1_ADDR_A1_REG (CH1 interrupt address 1)
    // ------------------------------------------------------------------------------
    `nnc_info("SOC_TEST", "Setup CH1 Address A1!", NNC_LOW)
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_INT_CH1_ADDR_A1_REG; wr_data[0] == CH1_ADDR1;});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // ------------------------------------------------------------------------------
    // Write to SOC_ANA_INT_CH1_ADDR_A2_REG (CH1 interrupt address 2)
    // ------------------------------------------------------------------------------
    `nnc_info("SOC_TEST", "Setup CH1 Address A2!", NNC_LOW)
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_INT_CH1_ADDR_A2_REG; wr_data[0] == CH1_ADDR2;});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // ------------------------------------------------------------------------------
    // Write to SOC_ANA_INT_CH2_ADDR_A1_REG (CH2 interrupt address 1)
    // ------------------------------------------------------------------------------
    `nnc_info("SOC_TEST", "Setup CH2 Address A1!", NNC_LOW)
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_INT_CH2_ADDR_A1_REG; wr_data[0] == CH2_ADDR1;});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // ------------------------------------------------------------------------------
    // Write to SOC_ANA_INT_CH2_ADDR_A2_REG (CH2 interrupt address 2)
    // ------------------------------------------------------------------------------
    `nnc_info("SOC_TEST", "Setup CH2 Address A2!", NNC_LOW)
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_INT_CH2_ADDR_A2_REG; wr_data[0] == CH2_ADDR2;});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // ------------------------------------------------------------------------------
    // Write to SOC_ANA_INT_COMP_POL_REG
    // ------------------------------------------------------------------------------
    if(top_test_cfg.comp_CH1_level === 1) begin
	if(top_test_cfg.comp_val === 1)
	   `nnc_info("SOC_TEST", "Select CH1 high level detection!", NNC_LOW)
	else
	   `nnc_info("SOC_TEST", "Select CH1 low level detection!", NNC_LOW)
    end
    else begin
	`nnc_info("SOC_TEST", "Select CH1 rise/fall detection!", NNC_LOW)
    end
    if(top_test_cfg.comp_CH2_level === 1) begin
	if(top_test_cfg.comp_val === 1)
	   `nnc_info("SOC_TEST", "Select CH2 high level detection!", NNC_LOW)
	else
	   `nnc_info("SOC_TEST", "Select CH2 low level detection!", NNC_LOW)
    end
    else begin
	`nnc_info("SOC_TEST", "Select CH2 rise/fall detection!", NNC_LOW)
    end
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_INT_COMP_POL_REG; wr_data[0] == {top_test_cfg.comp_CH2_level, top_test_cfg.comp_CH1_level, top_test_cfg.comp_val};});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
*/
    //wavegen_drv_enable;

    //`DUT_IF.A2D_comp_sel = top_test_cfg.A2D_comp_sel;
    ////force `ANA_TOP.A2D_COMP_OUT_CH1 = `SOC_TB.A2D_comp0_random_in;
    ////force `ANA_TOP.A2D_COMP_OUT_CH2 = `SOC_TB.A2D_comp1_random_in;

    top_test_cfg.cnt = 0;
    while(top_test_cfg.cnt < 5) begin
      `nnc_info("SOC_TEST", $sformatf("inside repeat loop = %0d",top_test_cfg.cnt), NNC_LOW)

      wait(`SOC_TB.INTB === 1);
      `nnc_info("SOC_TEST", "A2D_COMP int!", NNC_LOW)
/*
      // ------------------------------------------------------------------------------
      // Read from SOC_ANA_INT_COMP_STS_REG (check interrupt status)
      // ------------------------------------------------------------------------------
      top_test_cfg.rd_data=new[1];
      assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_INT_COMP_STS_REG;});
      `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data[0]);
      if(top_test_cfg.rd_data[0][1] === 1)
	`nnc_info("SOC_TEST", "A2D_COMP CH1 int sts is set!", NNC_LOW)
      else if(top_test_cfg.rd_data[0][2] === 1)
	`nnc_info("SOC_TEST", "A2D_COMP CH2 int sts is set!", NNC_LOW)
*/    
      // ------------------------------------------------------------------------------
      // Write to SOC_ANA_INT_COMP_STS_REG (clear interrupt)
      // ------------------------------------------------------------------------------
      fork
      begin
      	assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_INT_COMP_STS_REG; wr_data[0] == 8'h06/*top_test_cfg.rd_data[0]*/;});
      	`WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
      end
      begin
     	wait(`SOC_TB.INTB === 0);
      end
      join

      top_test_cfg.cnt++;
    end

    release `ANA_TOP.A2D_COMP_OUT_CH1;
    release `ANA_TOP.A2D_COMP_OUT_CH2;
    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    #10000000ns;
    `nnc_info("SOC_TEST", "soc_anac_comp_input_test end now", NNC_LOW)

    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ==================================================================================

    phase.drop_objection(this);
  endtask: main_phase
/*
  task wavegen_calc_clock_num;
  input [11:0] clk_freq;
  input [7:0]  rest_t;
  input [31:0] silent_t;
  input [31:0] hlf_wave_per;
  input [31:0] neg_hlf_wave_per;
  begin
    top_test_cfg.hlf_wave_lim = (hlf_wave_per * {20'b0,clk_freq}) / 1000;
    top_test_cfg.neg_hlf_wave_lim = (neg_hlf_wave_per * {20'b0,clk_freq}) / 1000;
    top_test_cfg.rest_lim = ({8'b0,rest_t} * {4'b0,clk_freq}) / 1000;
    top_test_cfg.silent_lim = (silent_t * {20'b0,clk_freq}) / 1000;
  end
  endtask

  task wavegen_setup(input int chip_num);
  begin
    top_test_cfg.LOAD_POINTS = top_test_cfg.load_points_sel;
    top_test_cfg.NO_OF_WAVEFORMS = top_test_cfg.waveform_sel;
    top_test_cfg.PRELOAD = top_test_cfg.preload_sel;
    top_test_cfg.NEG_ON = top_test_cfg.neg_ena;
    top_test_cfg.POS_OFF = top_test_cfg.pos_dis;
    top_test_cfg.POS_NEG_DIFF = top_test_cfg.pos_neg_diff_sel;
    
    case(top_test_cfg.points_sel)
         3'b000:begin
		    top_test_cfg.NO_OF_POINTS = 64;
		    if(top_test_cfg.LOAD_POINTS === 0)
		    	$readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y64", top_test_cfg.sine_data);
		    else
			$readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y128", top_test_cfg.sine_data);
		end
         3'b001:begin
		    top_test_cfg.NO_OF_POINTS = 32;
		    if(top_test_cfg.LOAD_POINTS === 0)
		    	$readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y32", top_test_cfg.sine_data);
		    else
			$readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y128", top_test_cfg.sine_data);
		end
         3'b010:begin
		    top_test_cfg.NO_OF_POINTS = 16;
		    if(top_test_cfg.LOAD_POINTS === 0)
		    	$readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y16", top_test_cfg.sine_data);
		    else
			$readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y128", top_test_cfg.sine_data);
		end
         3'b011:begin
		    top_test_cfg.NO_OF_POINTS = 8;
		    if(top_test_cfg.LOAD_POINTS === 0)
		    	$readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y8", top_test_cfg.sine_data);
		    else
			$readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y128", top_test_cfg.sine_data);
		end
         3'b100:begin
		    top_test_cfg.NO_OF_POINTS = 4;
		    if(top_test_cfg.LOAD_POINTS === 0)
		    	$readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y4", top_test_cfg.sine_data);
		    else
			$readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y128", top_test_cfg.sine_data);
		end
         3'b101:begin
		    top_test_cfg.NO_OF_POINTS = 2;
		    if(top_test_cfg.LOAD_POINTS === 0)
		    	$readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y2", top_test_cfg.sine_data);
		    else
			$readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y128", top_test_cfg.sine_data);
		end
         3'b110:begin
		    top_test_cfg.NO_OF_POINTS = 1;
		    $readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y128", top_test_cfg.sine_data);
		end
         3'b111:begin
		    top_test_cfg.NO_OF_POINTS = 128;
		    $readmemh("../../../verification/models/wavegen_stimulus/sine/hex_y128", top_test_cfg.sine_data);
		end
    endcase
    
    if(top_test_cfg.LOAD_POINTS === 0)
	top_test_cfg.NO_OF_LOAD_POINTS = top_test_cfg.NO_OF_POINTS;
    else begin
      if(top_test_cfg.NO_OF_WAVEFORMS === 0)
	top_test_cfg.NO_OF_LOAD_POINTS = 128;
      else begin
      	if(top_test_cfg.POS_NEG_DIFF === 1)
	   top_test_cfg.NO_OF_LOAD_POINTS = top_test_cfg.NO_OF_POINTS * (top_test_cfg.NO_OF_WAVEFORMS+1);
      	else begin
	   if((top_test_cfg.NEG_ON === 1) && (top_test_cfg.POS_OFF === 0))
	   	top_test_cfg.NO_OF_LOAD_POINTS = top_test_cfg.NO_OF_POINTS * (top_test_cfg.NO_OF_WAVEFORMS+1) * 2;
	   else
		top_test_cfg.NO_OF_LOAD_POINTS = top_test_cfg.NO_OF_POINTS * (top_test_cfg.NO_OF_WAVEFORMS+1);
	end
      end
    end

    // Interface
    top_env.wavegen_vif[chip_num].no_of_point_a = top_test_cfg.NO_OF_LOAD_POINTS; // expected resolution
    for (int i=0; i < top_env.wavegen_vif[chip_num].no_of_point_a; i++) begin
      top_env.wavegen_vif[chip_num].hex_data_a[i] = top_test_cfg.sine_data[i]; // expected hex values
    end
    top_env.wavegen_vif[chip_num].pos_neg_from_same_addr = top_test_cfg.POS_NEG_DIFF; 
    top_env.wavegen_vif[chip_num].load_wave_data_till_points = top_test_cfg.LOAD_POINTS; 
    top_env.wavegen_vif[chip_num].no_of_waveforms = top_test_cfg.NO_OF_WAVEFORMS; 
    top_env.wavegen_vif[chip_num].preload_sel = top_test_cfg.PRELOAD;

    `nnc_info("SOC_TEST", $sformatf("NO_OF_POINTS: %d, NO_OF_LOAD_POINTS: %d, LOAD_POINTS:%d", top_test_cfg.NO_OF_POINTS, top_test_cfg.NO_OF_LOAD_POINTS, top_test_cfg.LOAD_POINTS), NNC_LOW)

    top_test_cfg.clk_freq = 8192 / (2**`DUT_IF.pclk_sel);
    top_test_cfg.half_period_limit = (top_test_cfg.NO_OF_POINTS * 1000) / top_test_cfg.clk_freq;

    assert(top_test_cfg.randomize() with {half_period0 > top_test_cfg.half_period_limit; half_period1 > top_test_cfg.half_period_limit; half_period2 > top_test_cfg.half_period_limit;});
    //wavegen_calc_clock_num(clk_freq (KHz), rest_t (us), silent_t (us), hlf_wave_per (us), neg_hlf_wave_per (us))
    wavegen_calc_clock_num(top_test_cfg.clk_freq, 0, 0, top_test_cfg.half_period0, top_test_cfg.half_period0);
    top_test_cfg.hlf_wave0_lim = top_test_cfg.hlf_wave_lim / top_test_cfg.NO_OF_POINTS;
    top_test_cfg.neg_hlf_wave0_lim = top_test_cfg.neg_hlf_wave_lim / top_test_cfg.NO_OF_POINTS;
    `nnc_info("SOC_TEST", $sformatf("******** WAVE 0 ******** CLK_FREQ: %dKhz, HALF_PERIOD_LIMIT: %dus, HALF_PERIOD_TARGET: %dus, HALF_PERIOD_CLKS_PER_POINT: %d", top_test_cfg.clk_freq, top_test_cfg.half_period_limit, top_test_cfg.half_period0, top_test_cfg.hlf_wave0_lim), NNC_LOW)

    //wavegen_calc_clock_num(clk_freq (KHz), rest_t (us), silent_t (us), hlf_wave_per (us), neg_hlf_wave_per (us))
    wavegen_calc_clock_num(top_test_cfg.clk_freq, 0, 0, top_test_cfg.half_period1, top_test_cfg.half_period1);
    top_test_cfg.hlf_wave1_lim = top_test_cfg.hlf_wave_lim / top_test_cfg.NO_OF_POINTS;
    top_test_cfg.neg_hlf_wave1_lim = top_test_cfg.neg_hlf_wave_lim / top_test_cfg.NO_OF_POINTS;
    `nnc_info("SOC_TEST", $sformatf("******** WAVE 1 ******** CLK_FREQ: %dKhz, HALF_PERIOD_LIMIT: %dus, HALF_PERIOD_TARGET: %dus, HALF_PERIOD_CLKS_PER_POINT: %d", top_test_cfg.clk_freq, top_test_cfg.half_period_limit, top_test_cfg.half_period1, top_test_cfg.hlf_wave1_lim), NNC_LOW)

    //wavegen_calc_clock_num(clk_freq (KHz), rest_t (us), silent_t (us), hlf_wave_per (us), neg_hlf_wave_per (us))
    wavegen_calc_clock_num(top_test_cfg.clk_freq, 0, 0, top_test_cfg.half_period2, top_test_cfg.half_period2);
    top_test_cfg.hlf_wave2_lim = top_test_cfg.hlf_wave_lim / top_test_cfg.NO_OF_POINTS;
    top_test_cfg.neg_hlf_wave2_lim = top_test_cfg.neg_hlf_wave_lim / top_test_cfg.NO_OF_POINTS;
    `nnc_info("SOC_TEST", $sformatf("******** WAVE 2 ******** CLK_FREQ: %dKhz, HALF_PERIOD_LIMIT: %dus, HALF_PERIOD_TARGET: %dus, HALF_PERIOD_CLKS_PER_POINT: %d", top_test_cfg.clk_freq, top_test_cfg.half_period_limit, top_test_cfg.half_period2, top_test_cfg.hlf_wave2_lim), NNC_LOW)

    // ------------------------------------------------------------------------------
    // Write to SOC_ANA_ENABLE_REG_1 (This driver  enable is for analog purpose only)
    // ------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_ENABLE_REG_1; wr_data[0] == 8'h01;});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // ------------------------------------------------------------------------------
    // Write to SOC_ANA_ENABLE_REG_2 (This driver  enable is for analog purpose only)
    // ------------------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_ANA_ENABLE_REG_2; wr_data[0] == 8'h01;});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

  end
  endtask

  task wavegen_drv_config;
  input [7:0] WG_BASE;
  begin

    // --------------------------------------------------------
    // Write to SOC_ADDR_WG_DRV_CTRL0_REG
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CTRL0_REG + WG_BASE); wr_data[0] == {1'b0, top_test_cfg.dac_bit_len_sel,top_test_cfg.auto_man, 5'b0};});
    `nnc_info("SOC_TEST", "Set drive reg ctrl0", NNC_LOW)
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // --------------------------------------------------------
    // Write burst starting from SOC_ADDR_WG_DRV_CTRL1_REG
    // --------------------------------------------------------
    `nnc_info("SOC_TEST", "Set drive reg ctrl1-2", NNC_LOW)
    if(WG_BASE === `WAVEGEN_0_ADDR_BASE) begin
    	assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CTRL1_REG + WG_BASE); no_of_bytes == 2; wr_data[0] == {1'b0, top_test_cfg.dac0_msb_sel, top_test_cfg.dac0_data_h}; wr_data[1] == top_test_cfg.dac0_data_l;});
    	`WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);
    end
    else if(WG_BASE === `WAVEGEN_1_ADDR_BASE) begin
	assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CTRL1_REG + WG_BASE); no_of_bytes == 2; wr_data[0] == {1'b0, top_test_cfg.dac1_msb_sel, top_test_cfg.dac1_data_h}; wr_data[1] == top_test_cfg.dac1_data_l;});
    	`WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);
    end

    // --------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_REST_T_REG01
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_REST_T_REG01 + WG_BASE); no_of_bytes == 2;  wr_data[0] == top_test_cfg.rest_lim[15:8]; wr_data[1] == top_test_cfg.rest_lim[7:0];});
    `nnc_info("SOC_TEST", "Set 0 rest period", NNC_LOW)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_SILENT_T_REG01
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_SILENT_T_REG01 + WG_BASE); no_of_bytes == 3; wr_data[0] == top_test_cfg.silent_lim[23:16]; wr_data[1] == top_test_cfg.silent_lim[15:8]; wr_data[2] == top_test_cfg.silent_lim[7:0];});
    `nnc_info("SOC_TEST", "Set 0 silent time", NNC_LOW)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write to ADDR_WG_DRV_CLK_FREQ_REG0 (removed)
    // --------------------------------------------------------
    //assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CLK_FREQ_REG0 + WG_BASE); wr_data[0] == 8'h02;});
    //`nnc_info("SOC_TEST", "Set clk frequency", NNC_LOW)
    //`WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // --------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_HLF_WAVE_PRD_REG01
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_HLF_WAVE_PRD_REG01 + WG_BASE); no_of_bytes == 2; wr_data[0] == top_test_cfg.hlf_wave0_lim[15:8]; wr_data[1] == top_test_cfg.hlf_wave0_lim[7:0];});
    `nnc_info("SOC_TEST", "Set positive half wave0 period", NNC_LOW)//0x0000_01F4 (500us)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_NEG_HLF_WAVE_PRD_REG01
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_NEG_HLF_WAVE_PRD_REG01 + WG_BASE); no_of_bytes == 2; wr_data[0] == top_test_cfg.neg_hlf_wave0_lim[15:8]; wr_data[1] == top_test_cfg.neg_hlf_wave0_lim[7:0];});
    `nnc_info("SOC_TEST", "Set negative half wave0 period", NNC_LOW)//0x0000_01F4 (500us)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // -------------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_HLF_WAVE_CLK_PNT1_REG01
    // -------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_HLF_WAVE_CLK_PNT1_REG01 + WG_BASE); no_of_bytes == 2; wr_data[0] == top_test_cfg.hlf_wave1_lim[15:8]; wr_data[1] == top_test_cfg.hlf_wave1_lim[7:0];});
    `nnc_info("SOC_TEST", "Set positive half wave1 period", NNC_LOW)//0x0000_01F4 (500us)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // -----------------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT1_REG01
    // -----------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT1_REG01 + WG_BASE); no_of_bytes == 2; wr_data[0] == top_test_cfg.neg_hlf_wave1_lim[15:8]; wr_data[1] == top_test_cfg.neg_hlf_wave1_lim[7:0];});
    `nnc_info("SOC_TEST", "Set negative half wave1 period", NNC_LOW)//0x0000_01F4 (500us)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // -------------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_HLF_WAVE_CLK_PNT2_REG01
    // -------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_HLF_WAVE_CLK_PNT2_REG01 + WG_BASE); no_of_bytes == 2; wr_data[0] == top_test_cfg.hlf_wave2_lim[15:8]; wr_data[1] == top_test_cfg.hlf_wave2_lim[7:0];});
    `nnc_info("SOC_TEST", "Set positive half wave2 period", NNC_LOW)//0x0000_01F4 (500us)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // -----------------------------------------------------------------
    // Write burst starting from ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT2_REG01
    // -----------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT2_REG01 + WG_BASE); no_of_bytes == 2; wr_data[0] == top_test_cfg.neg_hlf_wave2_lim[15:8]; wr_data[1] == top_test_cfg.neg_hlf_wave2_lim[7:0];});
    `nnc_info("SOC_TEST", "Set negative half wave2 period", NNC_LOW)//0x0000_01F4 (500us)
    `WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    // --------------------------------------------------------
    // Write to ADDR_WG_DRV_CONFIG_REG0(//bit 0:rest enable, 1:negative enable, 2: silent enable, 3: source B enable, 4: alternate, 5: continue mode, 6: multi-electrode, 7: positive disable)
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CONFIG_REG0 + WG_BASE); wr_data[0] == {top_test_cfg.POS_OFF, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0, top_test_cfg.NEG_ON, 1'b0};});
    `nnc_info("SOC_TEST", "Set driver configuration register", NNC_LOW)
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    
    `nnc_info("SOC_TEST", $sformatf("Configure %d points", top_test_cfg.NO_OF_POINTS), NNC_LOW)
    // --------------------------------------------------------
    // Write to ADDR_WG_DRV_POINT_CONFIG
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_POINT_CONFIG + WG_BASE); wr_data[0] == top_test_cfg.NO_OF_POINTS;});
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    `nnc_info("SOC_TEST", $sformatf("Store %d wave points", top_test_cfg.NO_OF_LOAD_POINTS), NNC_LOW)
    for(int i=0; i<top_test_cfg.NO_OF_LOAD_POINTS; i++) begin
       	// --------------------------------------------------------
    	// Write to ADDR_WG_DRV_IN_WAVE_ADDR_REG0
    	// --------------------------------------------------------
    	assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0 + WG_BASE); wr_data[0] == i;});
    	`WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
	// --------------------------------------------------------
    	// Write to ADDR_WG_DRV_IN_WAVE_REG01
    	// --------------------------------------------------------
	assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_IN_WAVE_REG01 + WG_BASE); wr_data[0] == top_test_cfg.sine_data[i][7:0];});
    	`WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
    end

    // --------------------------------------------------------
    // Write to ADDR_WG_DRV_NEG_SCALE_REG0 (By default it is 1)
    // --------------------------------------------------------
    //assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_NEG_SCALE_REG0 + WG_BASE); wr_data[0] == 8'h01;});
    //`nnc_info("SOC_TEST", "Scale negative side", NNC_LOW)
    //`WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // --------------------------------------------------------
    // Write to ADDR_WG_DRV_POS_SCALE_REG0 (By default it is 1)
    // --------------------------------------------------------
    //assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_POS_SCALE_REG0 + WG_BASE); wr_data[0] == 8'h01;});
    //`nnc_info("SOC_TEST", "Scale positive side", NNC_LOW)
    //`WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // --------------------------------------------------------
    // Write to ADDR_WG_DRV_PULLBA_REG
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_PULLBA_REG + WG_BASE); wr_data[0] == {top_test_cfg.PULLAB_pos_en, top_test_cfg.PULLAB_neg_en, top_test_cfg.PULLAB_lim};});
    `nnc_info("SOC_TEST", "Set pullab reg", NNC_LOW)
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // --------------------------------------------------------
    // Write to ADDR_WG_DRV_DELAY_LIM_REG01
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_DELAY_LIM_REG01 + WG_BASE);});
    `nnc_info("SOC_TEST", "Adjust delay using Delay_lim register", NNC_LOW)
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // --------------------------------------------------------
    // Write to ADDR_WG_DRV_CTRL_REG0
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_CTRL_REG0 + WG_BASE); wr_data[0] == {top_test_cfg.POS_NEG_DIFF,top_test_cfg.LOAD_POINTS,top_test_cfg.NO_OF_WAVEFORMS,top_test_cfg.PRELOAD,1'b0};});
    if(top_test_cfg.PRELOAD === 2'b00)
    	`nnc_info("SOC_TEST", "Config driver control register with preloaded sine values", NNC_LOW)
    else if(top_test_cfg.PRELOAD === 2'b11)
    	`nnc_info("SOC_TEST", "Config driver control register with user config values", NNC_LOW)
    `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
  end
  endtask

  task wavegen_drv_enable;
  begin
    `nnc_info("SOC_TEST", $sformatf("enabling chip_0 wavegen sb now"), NNC_LOW)
    `WAVEGEN_SCB_DRV_0_EN = 1'b1;
    // --------------------------------------------------------
    // Write to SOC_WAVEGEN_GLOBAL_REG to sync drivers
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_WAVEGEN_GLOBAL_REG; wr_data[0] == 8'h01;});
    `nnc_info("SOC_TEST", "Enable drivers using global register", NNC_LOW)
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);
  end
  endtask
*/
  // ------------------------------
  // Declare the report_phase task
  // ------------------------------
  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction

endclass : `TESTNAME
