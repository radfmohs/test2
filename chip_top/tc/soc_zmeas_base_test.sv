/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_zmeas_base_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_zmeas_base_test                                             
// Designer	: ddang@nanochap.com                                                                 
// Date		: 20-05-2026                                                                     
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_zmeas_base_test
`define TESTCFG soc_zmeas_base_test_cfg

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
  rand logic       sar_adc_bypass_pull_src_from_wg; 

  // stim mon related
  rand int          mon_clk;
  rand logic        adc_cycle_int_sts_en;
  rand logic        adc_sample_int_sts_en;
  rand logic        adc_delta_int_sts_en; 
  rand logic        adc_en;
  rand logic        adc_mode;
  rand logic [3:0]  pair_num;
  rand logic [7:0]  expected_data;
  rand logic [31:0] stim_mon_period;
  rand logic        mon_adc_clk_inv;
  rand logic [3:0]  mon_clk_div;
  rand logic [2:0]  stim_mon_int_to_pin_en;
  rand logic [1:0]  stim_delta_data_sel;
  rand logic        bypass_adc_data_en;
  rand logic        read_adc_data_en;
  rand logic        bypass_ignore_first;
  rand logic [3:0]  stim_dly_tgt;
  rand logic [15:0] stim_pad0_tgt0;
  rand logic [15:0] stim_pad0_tgt1;
  rand logic [15:0] stim_pad0_tgt2;
  rand logic [15:0] stim_pad0_tgt3;
       logic [15:0] a2d_delta_adc_tag_data;
  rand logic [15:0] stim_pad1_tgt0;
  rand logic [15:0] stim_pad1_tgt1;
  rand logic [15:0] stim_pad1_tgt2;
  rand logic [15:0] stim_pad1_tgt3;
       logic [3:0]  pair_select [$];
  rand logic        adc_delta_data_in_manual_en;
       logic        stim_int_sts;
       logic [15:0] leadoff_int_sts;
       logic [15:0] short_int_sts;
  rand logic        int_active_level_high_or_low;
  rand logic        clear_intr_manual_or_auto;
  rand logic        intr_length_slct_level_or_pulse;
  rand logic        select_2nd_max_min;
  rand logic        check_every_n;
  rand int          period_ns;
  rand int          t25;

  // leadoff and short
  rand logic        leadoff_int_en;
  rand logic        leadoff_int_to_pin_en;
  rand logic [9:0]  leadoff_th;

  rand logic        short_int_en;
  rand logic        short_int_to_pin_en;
  rand logic [9:0]  short_th;

  rand logic [7:0]  leadoff_short_th_tgt;
  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_zmeas_base_test_cfg");
    super.new(name);
    
  endfunction: new

  // ===============================================
  // Adding constraints of randomization
  // -----------------------------------------------

  constraint c_spi_sclk_freq       {spi_sclk_freq == 20000 ;} // spi clk always faster than adc_clk

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

  // SAR VIP Constraints
  constraint c_sar_adc_sine_wave_en     { sar_adc_sine_wave_en == 1'b1; } // Sine is enable

  //constraint c_sar_adc_sine_wave_freq   { sar_adc_sine_wave_freq == 10000; } // 10Khz
  //constraint c_sar_adc_sine_wave_freq   { sar_adc_sine_wave_freq == 250000; } // 250Khz

  constraint c_sar_adc_sine_wave_freq   { solve mon_clk_div before sar_adc_sine_wave_freq;
                                          solve stim_mon_period before sar_adc_sine_wave_freq;
                                          sar_adc_sine_wave_freq == (2*mon_clk)/stim_mon_period; } // 250Khz

  constraint c_sar_adc_vin              { sar_adc_vin == 1000; } // 1000mV

  constraint c_sar_adc_data_timing_t1   { sar_adc_data_timing_t1 inside {[5: 250*75/100 -5]};} // 75% of 4Mhz = 250*0.75 (margin 5ns)

  //constraint c_sar_adc_data_timing_t2   { sar_adc_data_timing_t2 inside {[5: 250*25/100 -5]};} // 25% of 4Mhz = 250*0.25 (margin 5ns)

  constraint c_sar_adc_data_timing_t2 { solve mon_adc_clk_inv before sar_adc_data_timing_t2;
                                        solve mon_clk before sar_adc_data_timing_t2;
                                    
                                        // Compute period in ns
                                        period_ns == (1000000000 / mon_clk);
                                    
                                        // 25% point
                                        t25 == (period_ns * 25) / 100;
                                    
                                        // Apply timing windows
                                        mon_adc_clk_inv == 0 -> sar_adc_data_timing_t2 inside { [5 : t25 - 5] };
                                        mon_adc_clk_inv == 1 -> sar_adc_data_timing_t2 inside { [t25 + 1 : t25 + 10] };}

  constraint c_sar_adc_bypass_pull_src_from_wg { sar_adc_bypass_pull_src_from_wg == 1'b1;}

  //Stim module related constraints

  //constraint c_int_active_level_low_or_high  { int_active_level_high_or_low == 1; } // 1: intr active high, 0 : intr active low 

  //constraint c_clear_intr_manual_or_auto  { clear_intr_manual_or_auto == 0; } // 0: manually clear intr by w1c, 1 : auto clear intr by r1c 

  //constraint c_intr_length_slct_pulse_or_level  { intr_length_slct_level_or_pulse == 0; } // 0: level INT, 1: pulse INT

  constraint c_adc_cycle_value_int_sts_en       { adc_cycle_int_sts_en inside {[0:0]};} 

  constraint c_adc_sample_int_sts_en            { adc_sample_int_sts_en inside {[0:0]};} 

  constraint c_adc_sample_delta_int_sts_en      { adc_delta_int_sts_en inside {[0:0]};} 

  constraint c_adc_mode                         { adc_mode inside {[0:1]};} // 0: manual , 1: automatic

  constraint c_pair_num                         { pair_num inside {[0:'hF]};} // 0:1 pair, 1:2 pair,.. 'hF:16 pair

  constraint c_read_adc_data_en                 { read_adc_data_en inside {[0:0]};}  

  constraint c_bypass_adc_data_en               { bypass_adc_data_en inside {[0:1]};}  

  constraint c_bypass_ignore_first              { bypass_ignore_first inside {[0:1]};}  

  constraint c_adc_en                           { adc_en inside {[1:1]};} // 0: disable, 1: enable

  constraint c_stim_dly_tgt                     { stim_dly_tgt inside {[0:0]};}  

  constraint c_stim_mon_period                  { stim_mon_period inside {[10:40]};} // change later 

  constraint c_mon_adc_clk_inv                  { mon_adc_clk_inv inside {[0:0]};} // 0: same phase, 1: invert of dig adc

  constraint c_stim_mon_int_to_pin_en           { stim_mon_int_to_pin_en inside {[7:7]};} // bit0: sample valut int to pin , bit1: delta value int to pin, bit2: cycle value int to pin 

  constraint c_stim_delta_data_sel              { stim_delta_data_sel inside {[0:3]};} // 0: delta data(max-min), 1:min, 2: max, 3:last sample data during this pair 

  constraint c_select_2nd_max_min               { select_2nd_max_min inside {[0:0]};}  

  constraint c_mon_clk_div                      { mon_clk_div inside {[8:8]};} // 0:4M, 1:2M, 2:1M, 3=512k, 4:256K, 5:128k, 6:64k, 7:32k, 8:16k, 9:8k, 10:4k, 11:8M, other: 4M 

  constraint c_mon_clk                          { solve mon_clk_div before mon_clk; // in Hz
                                                  mon_clk_div == 0 -> mon_clk == 4000000;
                                                  mon_clk_div == 1 -> mon_clk == 2000000;
                                                  mon_clk_div == 2 -> mon_clk == 1000000;
                                                  mon_clk_div == 3 -> mon_clk == 512000;
                                                  mon_clk_div == 4 -> mon_clk == 256000;
                                                  mon_clk_div == 5 -> mon_clk == 128000;
                                                  mon_clk_div == 6 -> mon_clk == 64000;
                                                  mon_clk_div == 7 -> mon_clk == 32000;
                                                  mon_clk_div == 8 -> mon_clk == 16000;
                                                  mon_clk_div == 9 -> mon_clk == 8000;
                                                  mon_clk_div == 10 -> mon_clk == 4000;
                                                  mon_clk_div == 11 -> mon_clk == 8000000; 
                                                  mon_clk_div inside {[12:15]} -> mon_clk == 4000000;}  

  // -----------------------------------------------
  // End of adding constraints of randomization
  // ===============================================

  function void post_random();
    if(adc_mode == 0) begin //manual mode
      for(int i=0; i< `WAVEGEN_DRIVER_NUM ; i++)begin
        pair_select.push_back(i);
      end
      pair_select.shuffle();
      $display("pair_select array = %0p",pair_select); 

      // stim pad0
      stim_pad0_tgt0  = {pair_select[3], pair_select[2], pair_select[1], pair_select[0]};
      stim_pad0_tgt1  = {pair_select[7], pair_select[6], pair_select[5], pair_select[4]};
      stim_pad0_tgt2  = {pair_select[11], pair_select[10], pair_select[9], pair_select[8]};
      stim_pad0_tgt3  = {pair_select[15], pair_select[14], pair_select[13], pair_select[12]};
        
      // stim pad1
      stim_pad1_tgt0  = {pair_select[15], pair_select[14], pair_select[13], pair_select[12]};
      stim_pad1_tgt1  = {pair_select[11], pair_select[10], pair_select[9], pair_select[8]}; 
      stim_pad1_tgt2  = {pair_select[7], pair_select[6], pair_select[5], pair_select[4]};
      stim_pad1_tgt3  = {pair_select[3], pair_select[2], pair_select[1], pair_select[0]};
    end
  endfunction

endclass : `TESTCFG

// ===============================================
// Main Testcase is defined
// -----------------------------------------------
class `TESTNAME extends soc_base_test;
   
  `nnc_component_utils(`TESTNAME)

  `TESTCFG top_test_cfg;
  bit  use_old_intr_reg_or_general_reg_to_clr;
  int  delta_intr_num;
  bit  stim_intr_checks_en = 0;

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
    top_test_cfg.post_random();
    $display("randomize here = %0p",top_test_cfg.pair_select); 

    `DUT_IF.spi_sclk_freq = top_test_cfg.spi_sclk_freq;
    `DUT_IF.tsccs    = top_test_cfg.tsccs;
    `DUT_IF.tcsh     = top_test_cfg.tcsh;
    `DUT_IF.tch      = top_test_cfg.tch; 

    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;

    `DUT_IF.spimode_sel = top_test_cfg.spimode_sel;

    `DUT_IF.sar_adc_sine_wave_en = top_test_cfg.sar_adc_sine_wave_en;

    `DUT_IF.sar_adc_sine_wave_freq = top_test_cfg.sar_adc_sine_wave_freq;

    `DUT_IF.sar_adc_vin = top_test_cfg.sar_adc_vin;

    `DUT_IF.sar_adc_data_timing_t1 = top_test_cfg.sar_adc_data_timing_t1;

    `DUT_IF.sar_adc_data_timing_t2 = top_test_cfg.sar_adc_data_timing_t2;

    `DUT_IF.sar_adc_bypass_pull_src_from_wg = top_test_cfg.sar_adc_bypass_pull_src_from_wg;

    `DUT_IF.adc_cycle_int_sts_en  = top_test_cfg.adc_cycle_int_sts_en;
    `DUT_IF.adc_sample_int_sts_en       = top_test_cfg.adc_sample_int_sts_en;
    `DUT_IF.adc_delta_int_sts_en        = top_test_cfg.adc_delta_int_sts_en;
    `DUT_IF.adc_en                      = top_test_cfg.adc_en;
    `DUT_IF.adc_mode                    = top_test_cfg.adc_mode;
    `DUT_IF.pair_num                    = top_test_cfg.pair_num;
    `DUT_IF.expected_data               = top_test_cfg.expected_data;
    `DUT_IF.stim_mon_period             = top_test_cfg.stim_mon_period;
    `DUT_IF.mon_adc_clk_inv             = top_test_cfg.mon_adc_clk_inv;
    `DUT_IF.mon_clk_div                 = top_test_cfg.mon_clk_div;
    `DUT_IF.stim_mon_int_to_pin_en      = top_test_cfg.stim_mon_int_to_pin_en;
    `DUT_IF.stim_delta_data_sel         = top_test_cfg.stim_delta_data_sel;
    `DUT_IF.bypass_adc_data_en          = top_test_cfg.bypass_adc_data_en;
    `DUT_IF.read_adc_data_en            = top_test_cfg.read_adc_data_en;
    `DUT_IF.bypass_ignore_first         = top_test_cfg.bypass_ignore_first;
    `DUT_IF.stim_dly_tgt                = top_test_cfg.stim_dly_tgt;
    `DUT_IF.stim_pad0_tgt0              = top_test_cfg.stim_pad0_tgt0;
    `DUT_IF.stim_pad0_tgt1              = top_test_cfg.stim_pad0_tgt1;
    `DUT_IF.stim_pad0_tgt2              = top_test_cfg.stim_pad0_tgt2;
    `DUT_IF.stim_pad0_tgt3              = top_test_cfg.stim_pad0_tgt3;
    `DUT_IF.a2d_delta_adc_tag_data      = top_test_cfg.a2d_delta_adc_tag_data;
    `DUT_IF.stim_pad1_tgt0              = top_test_cfg.stim_pad1_tgt0;
    `DUT_IF.stim_pad1_tgt1              = top_test_cfg.stim_pad1_tgt1;
    `DUT_IF.stim_pad1_tgt2              = top_test_cfg.stim_pad1_tgt2;
    `DUT_IF.stim_pad1_tgt3              = top_test_cfg.stim_pad1_tgt3;
    `DUT_IF.adc_delta_data_in_manual_en  = top_test_cfg.adc_delta_data_in_manual_en;
    `DUT_IF.select_2nd_max_min           = top_test_cfg.select_2nd_max_min;
    `DUT_IF.check_every_n                = top_test_cfg.check_every_n;

    `DUT_IF.int_active_level_high_or_low    = top_test_cfg.int_active_level_high_or_low;
    `DUT_IF.clear_intr_manual_or_auto       = top_test_cfg.clear_intr_manual_or_auto;
    `DUT_IF.intr_length_slct_level_or_pulse = top_test_cfg.intr_length_slct_level_or_pulse;

    `DUT_IF.leadoff_int_en        = top_test_cfg.leadoff_int_en;
    `DUT_IF.leadoff_int_to_pin_en = top_test_cfg.leadoff_int_to_pin_en;
    `DUT_IF.leadoff_th            = top_test_cfg.leadoff_th;
    `DUT_IF.short_int_en          = top_test_cfg.short_int_en;
    `DUT_IF.short_int_to_pin_en   = top_test_cfg.short_int_to_pin_en;
    `DUT_IF.short_th              = top_test_cfg.short_th;
    `DUT_IF.leadoff_short_th_tgt  = top_test_cfg.leadoff_short_th_tgt;

    if(`DUT_IF.pair_num > 2)delta_intr_num = `DUT_IF.pair_num - 1;
    else delta_intr_num = 1;

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

    config_regs();

    `nnc_info("SOC_TEST", "soc_zmeas_base_test start", NNC_LOW)

    // ==================================================================================
    // Please add your code of your test here
    // ---------------------------------------------------------------------------------- 

    if(`DUT_IF.adc_mode == 0) begin // manual mode - change the pair0
      #200us;
      manual_mode_traffic();
    end

    if(`DUT_IF.adc_mode == 1 && stim_intr_checks_en == 1) begin // auto mode 
      stim_intr_checks();
    end

    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    #1ms;
    `nnc_info("SOC_TEST", "soc_zmeas_base_test end now", NNC_LOW)

    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ==================================================================================

    phase.drop_objection(this);
  endtask: main_phase

  task manual_mode_traffic();
    int j=16;
    bit [9:0] spi_adc_data_delta;

    // enable delta int sts
    `DUT_IF.adc_sample_int_sts_en = 0;
    `DUT_IF.adc_delta_int_sts_en = 1;
    top_test_cfg.wr_data[0] = {`DUT_IF.adc_cycle_int_sts_en,`DUT_IF.adc_sample_int_sts_en,`DUT_IF.adc_delta_int_sts_en,`DUT_IF.adc_mode,`DUT_IF.pair_num};
    `WR_NORMAL_REG(`SOC_STIM_PAD_CTRL, top_test_cfg.wr_data[0], top_test_cfg.pads);

    for(int i = 0; i < delta_intr_num; i++)begin
    //for(int i = 0; i < 2; i++)begin

      `nnc_info("SOC_TEST", $sformatf("inside for loop :%0d ", i), NNC_LOW)

      // 1. clear adc_Delta_data_in_manual bit to reset the capture logic
      if(i != 0)begin
        `DUT_IF.adc_delta_data_in_manual_en = 0;
        top_test_cfg.wr_data[0] = {4'b0,`DUT_IF.select_2nd_max_min,`DUT_IF.adc_delta_data_in_manual_en,2'b00};
        `WR_NORMAL_REG(`SOC_ADC_DELTA_DATA_TAG_H, top_test_cfg.wr_data[0], top_test_cfg.pads);
      end
      
      // 2. set bit to 1 to capture current delta data
      `DUT_IF.adc_delta_data_in_manual_en = 1;
      top_test_cfg.wr_data[0] = {4'b0,`DUT_IF.select_2nd_max_min,`DUT_IF.adc_delta_data_in_manual_en,2'b00};
      `WR_NORMAL_REG(`SOC_ADC_DELTA_DATA_TAG_H, top_test_cfg.wr_data[0], top_test_cfg.pads);

      // keep bit 1 for min 3 adc clks
      repeat(3) @(posedge `CLK_CTRL_TOP.stim_monitor_dig_clk);

      // 3. check and clear the intr
      wait_for_intb();
      check_int_sts_reg("DELTA", 1); 
      clear_int_sts_reg("DELTA");
      wait_for_intb_clear();

      // 4. read the delta data and tag 
      assert(top_test_cfg.randomize() with {reg_addr == `SOC_ADC_DELTA_DATA_TAG_L; no_of_bytes == 2;});
      `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);

      `nnc_info("SOC_TEST", $sformatf("delta data :%0d ", {top_test_cfg.rd_data[0][1:0],top_test_cfg.rd_data[1][7:0]}), NNC_LOW)
      `nnc_info("SOC_TEST", $sformatf("delta tag :%0d ", top_test_cfg.rd_data[0][7:5]), NNC_LOW)

      spi_adc_data_delta = {top_test_cfg.rd_data[0][1:0],top_test_cfg.rd_data[1][7:0]};

      if(top_test_cfg.rd_data[0][7:4] != 'h0)
        `nnc_error("TEST", $sformatf("DELTA TAG is non zero for manual pair mode =%0h",top_test_cfg.rd_data[0][7:5] ))

      if(spi_adc_data_delta !== `DUT_IF.delta_a2d_data)
        `nnc_error("TEST", $sformatf("MISMATCH : spi delta data = %0d , exp delta data from tb = %0d ",spi_adc_data_delta,`DUT_IF.delta_a2d_data))
      else
        `nnc_info("TEST", $sformatf("MATCH : spi delta data = %0d , exp delta data from tb = %0d ",spi_adc_data_delta,`DUT_IF.delta_a2d_data),UVM_LOW)

      // changing amplitude of pair before changing the pair
      `DUT_IF.sar_adc_vin = `DUT_IF.sar_adc_vin - 100;

      // 5. switch target channel pair 
      //stim pad0 tgt1
      assert(top_test_cfg.randomize() with {reg_addr == `SOC_STIM_PAD0_TGT0_L; no_of_bytes == 2;  wr_data[0] == 'h0; wr_data[1] == i+2;});
      `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);
      
      //stim pad1 tgt1
      assert(top_test_cfg.randomize() with {reg_addr == `SOC_STIM_PAD1_TGT0_L; no_of_bytes == 2;  wr_data[0] == 'h0; wr_data[1] == j-1;});
      `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);
      j--;

    end
  endtask 

  task stim_intr_checks();
    bit [9:0] spi_adc_data;
    bit [3:0] spi_adc_tag;
    bit [9:0] spi_adc_data_delta;
    bit [3:0] spi_adc_tag_delta;

    // ************************* SAMPLE INTR CHECKS ****************************
    if(`DUT_IF.pair_num > 11 && `DUT_IF.mon_clk_div >7 && `DUT_IF.mon_clk_div < 11)begin
      `nnc_info("SOC_TEST", $sformatf(" ---- SAMPLE INTR CHECKS ----"), NNC_LOW)
      // sample ints sts = 1
      // sample sts to int pin = 1

      `DUT_IF.check_every_n = 1;
      top_test_cfg.wr_data[0] = {1'b0,`DUT_IF.check_every_n, 1'b0, `DUT_IF.mon_adc_clk_inv, `DUT_IF.mon_clk_div}; // 4Mhz
      `WR_NORMAL_REG(`SOC_STIM_MON_CLK_RST_CTRL, top_test_cfg.wr_data[0], top_test_cfg.pads);
      
      `DUT_IF.adc_sample_int_sts_en = 1;
      top_test_cfg.wr_data[0] = {`DUT_IF.adc_cycle_int_sts_en,`DUT_IF.adc_sample_int_sts_en,`DUT_IF.adc_delta_int_sts_en,`DUT_IF.adc_mode,`DUT_IF.pair_num};
      `WR_NORMAL_REG(`SOC_STIM_PAD_CTRL, top_test_cfg.wr_data[0], top_test_cfg.pads);

      //for(int i =0; i< `DUT_IF.pair_num * 3; i++)begin
      for(int i =0; i< 5; i++)begin
        wait_for_intb();
        check_int_sts_reg("SAMPLE", 1); 
        clear_int_sts_reg("SAMPLE");
        wait_for_intb_clear();

        // read the data and tag 
        assert(top_test_cfg.randomize() with {reg_addr == `SOC_STIM_ADC_DATA_TAG_L; no_of_bytes == 2;});
        `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);

        spi_adc_data = {top_test_cfg.rd_data[0][1:0],top_test_cfg.rd_data[1][7:0]};
        spi_adc_tag = top_test_cfg.rd_data[0][7:4];
        `nnc_info("SOC_TEST", $sformatf("data :%0d ",spi_adc_data), NNC_LOW)
        `nnc_info("SOC_TEST", $sformatf("tag :%0d ", spi_adc_tag), NNC_LOW)

        if((spi_adc_data !== `ANA_TOP.sar_adc_vip.A2D_DATA) || (spi_adc_tag !== `DUT_IF.exp_stim_tag))
          `nnc_error("TEST", $sformatf("MISMATCH : spi data = %0d , analog model data = %0d , spi tag=%0d, exp tag from TB=%0d ",spi_adc_data,`ANA_TOP.sar_adc_vip.A2D_DATA,spi_adc_tag,`DUT_IF.exp_stim_tag))
        else
          `nnc_info("TEST", $sformatf("MATCH : spi data = %0d , analog model data = %0d , spi tag=%0d, exp tag from TB=%0d ",spi_adc_data,`ANA_TOP.sar_adc_vip.A2D_DATA,spi_adc_tag,`DUT_IF.exp_stim_tag),UVM_LOW)
       end
       `nnc_info("SOC_TEST", $sformatf(" ---- SAMPLE INTR CHECKS DONE ----"), NNC_LOW)

       stim_intr_en_dis_check("SAMPLE");
    end
    // ************************************************************************


    // ************************* DELTA INTR CHECKS ****************************
    `nnc_info("SOC_TEST", $sformatf(" ---- DELTA INTR CHECKS ----"), NNC_LOW)
    // delta ints sts = 1
    // delta sts to int pin = 1

    `DUT_IF.adc_sample_int_sts_en = 0;
    `DUT_IF.adc_delta_int_sts_en = 1;
    top_test_cfg.wr_data[0] = {`DUT_IF.adc_cycle_int_sts_en,`DUT_IF.adc_sample_int_sts_en,`DUT_IF.adc_delta_int_sts_en,`DUT_IF.adc_mode,`DUT_IF.pair_num};
    `WR_NORMAL_REG(`SOC_STIM_PAD_CTRL, top_test_cfg.wr_data[0], top_test_cfg.pads);

    //for(int i =0; i< delta_intr_num; i++)begin
    for(int i =0; i< 3; i++)begin
      wait_for_intb();
      check_int_sts_reg("DELTA", 1); 
      clear_int_sts_reg("DELTA");
      wait_for_intb_clear();
      // read the delta data and tag 
      assert(top_test_cfg.randomize() with {reg_addr == `SOC_ADC_DELTA_DATA_TAG_L; no_of_bytes == 2;});
      `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);

      spi_adc_data_delta = {top_test_cfg.rd_data[0][1:0],top_test_cfg.rd_data[1][7:0]};
      spi_adc_tag_delta = top_test_cfg.rd_data[0][7:4];

      `nnc_info("SOC_TEST", $sformatf("delta data :%0d ", spi_adc_data_delta), NNC_LOW)
      `nnc_info("SOC_TEST", $sformatf("delta tag :%0d ", spi_adc_tag_delta), NNC_LOW)

      if((spi_adc_data_delta !== `DUT_IF.delta_a2d_data) || (spi_adc_tag_delta !== `DUT_IF.exp_stim_delta_tag))
        `nnc_error("TEST", $sformatf("MISMATCH : spi delta data = %0d , exp delta data from tb = %0d , delta tag=%0d, exp delta tag from TB=%0d ",spi_adc_data_delta,`DUT_IF.delta_a2d_data,spi_adc_tag_delta,`DUT_IF.exp_stim_delta_tag))
      else
        `nnc_info("TEST", $sformatf("MATCH : spi delta data = %0d , exp delta data from tb = %0d , delta tag=%0d, exp delta tag from TB=%0d ",spi_adc_data_delta,`DUT_IF.delta_a2d_data,spi_adc_tag_delta,`DUT_IF.exp_stim_delta_tag),UVM_LOW)
    end

    // delta ints sts = 1
    // delta sts to int pin = 0
    `DUT_IF.stim_mon_int_to_pin_en[0] = 0;
    top_test_cfg.wr_data[0] = {`DUT_IF.stim_mon_int_to_pin_en,`DUT_IF.stim_delta_data_sel,3'b0};
    `WR_NORMAL_REG(`SOC_STIM_MON_INT, top_test_cfg.wr_data[0], top_test_cfg.pads);

    //for(int i =0; i< delta_intr_num; i++)begin
    for(int i =0; i< 3; i++)begin
      fork 
        begin
          repeat(2) begin  // between 2 pair change int pin should not assert
            @(posedge `DUT_IF.pair_change);
            `nnc_info("SOC_TEST", $sformatf("pair_change =%d", `DUT_IF.pair_change), NNC_LOW)
	    repeat(1) @(posedge `CLK_CTRL_TOP.stim_monitor_dig_clk); // so sts can update
            check_int_sts_reg("DELTA", 1); 
            clear_int_sts_reg("DELTA");
          end
        end

        begin
          wait_for_intb();
          `nnc_error("TEST", $sformatf("ERROR : delta int to pin= 0, but INT[2]= %0d",`SOC_TB.INT[2]))
        end
      join_any
      disable fork;
    end

    `nnc_info("SOC_TEST", $sformatf(" ---- DELTA INTR CHECKS DONE ----"), NNC_LOW)
    // ************************************************************************


    // ************************* CYCLE INTR CHECKS ****************************
    `nnc_info("SOC_TEST", $sformatf(" ---- CYCLE INTR CHECKS ----"), NNC_LOW)

    // cycle ints sts = 1
    // cycle sts to int pin = 1
    `DUT_IF.adc_delta_int_sts_en = 0;
    `DUT_IF.adc_cycle_int_sts_en = 1;
    top_test_cfg.wr_data[0] = {`DUT_IF.adc_cycle_int_sts_en,`DUT_IF.adc_sample_int_sts_en,`DUT_IF.adc_delta_int_sts_en,`DUT_IF.adc_mode,`DUT_IF.pair_num};
    `WR_NORMAL_REG(`SOC_STIM_PAD_CTRL, top_test_cfg.wr_data[0], top_test_cfg.pads);

    for(int i =0; i< 3; i++)begin
      wait_for_intb();
      check_int_sts_reg("CYCLE", 1); 
      clear_int_sts_reg("CYCLE");
      wait_for_intb_clear();
    end

    // cycle ints sts = 1
    // cycle sts to int pin = 0
    // between 2 cycles int pin should assert, exp tag becomes 0 when each cycle completes
    `DUT_IF.stim_mon_int_to_pin_en[2] = 0;
    top_test_cfg.wr_data[0] = {`DUT_IF.stim_mon_int_to_pin_en,`DUT_IF.stim_delta_data_sel,3'b0};
    `WR_NORMAL_REG(`SOC_STIM_MON_INT, top_test_cfg.wr_data[0], top_test_cfg.pads);

    for(int i =0; i< 1; i++)begin
      fork 
        begin
          repeat(2) begin 
            wait(`DUT_IF.exp_stim_tag == 0); 
	    repeat(1) @(posedge `CLK_CTRL_TOP.stim_monitor_dig_clk); // so sts can update
            `nnc_info("SOC_TEST", $sformatf("exp_stim_tag =%d", `DUT_IF.exp_stim_tag), NNC_LOW)
	    //wait(`ZMEAS_TOP.o_stim_mon_int === 1);    
            check_int_sts_reg("CYCLE", 1); 
            clear_int_sts_reg("CYCLE");
          end
        end

        begin
          wait_for_intb();
          `nnc_error("TEST", $sformatf("ERROR : cycle int to pin= 0, but INT[2]= %0d",`SOC_TB.INT[2]))
        end
      join_any
      disable fork;
    end
    `nnc_info("SOC_TEST", $sformatf(" ---- CYCLE INTR CHECKS DONE ----"), NNC_LOW)
    // ************************************************************************

    // disable all int sts and all intr to pin
    `DUT_IF.adc_sample_int_sts_en = 0;
    `DUT_IF.adc_delta_int_sts_en = 0;
    `DUT_IF.adc_cycle_int_sts_en = 0;
    `DUT_IF.stim_mon_int_to_pin_en = 0;

    top_test_cfg.wr_data[0] = {`DUT_IF.adc_cycle_int_sts_en,`DUT_IF.adc_sample_int_sts_en,`DUT_IF.adc_delta_int_sts_en,`DUT_IF.adc_mode,`DUT_IF.pair_num};
    `WR_NORMAL_REG(`SOC_STIM_PAD_CTRL, top_test_cfg.wr_data[0], top_test_cfg.pads);

    top_test_cfg.wr_data[0] = {`DUT_IF.stim_mon_int_to_pin_en,`DUT_IF.stim_delta_data_sel,3'b0};
    `WR_NORMAL_REG(`SOC_STIM_MON_INT, top_test_cfg.wr_data[0], top_test_cfg.pads);

    fork
      begin
        wait_for_intb();
        `nnc_fatal("TEST", $sformatf("ERROR: all stim int sts and int to pin are disabled , why INT[2] asserted ?? "))
      end

      begin
        #10ms;
      end
    join_any
    disable fork;

  endtask 

  task stim_intr_en_dis_check(string intr);

    // intr status and intr pin both are enable at this stage 
    wait_for_intb();
    check_int_sts_reg(intr, 1); 

    // intr status disable
    `nnc_info("SOC_TEST", "--------------intr status disable --------------------- ", NNC_LOW)
    if(intr == "SAMPLE")`DUT_IF.adc_sample_int_sts_en = 0;       
    top_test_cfg.wr_data[0] = {`DUT_IF.adc_cycle_int_sts_en,`DUT_IF.adc_sample_int_sts_en,`DUT_IF.adc_delta_int_sts_en,`DUT_IF.adc_mode,`DUT_IF.pair_num};
    `WR_NORMAL_REG(`SOC_STIM_PAD_CTRL, top_test_cfg.wr_data[0], top_test_cfg.pads);

    repeat(1) @(posedge `CLK_CTRL_TOP.stim_monitor_dig_clk); // so sts can update
    check_int_sts_reg(intr, 0); 
    wait_for_intb_clear();
    `nnc_info("SOC_TEST", "--------------intr status disable check done---------------------\n ", NNC_LOW)
 

    // intr status disable, intr to pin enable
    `nnc_info("SOC_TEST", "--------------intr status disable, intr to pin enable --------------------- ", NNC_LOW)
    if(intr == "SAMPLE")begin
      `DUT_IF.adc_sample_int_sts_en = 0;       
      `DUT_IF.stim_mon_int_to_pin_en[1] = 1;
    end
    top_test_cfg.wr_data[0] = {`DUT_IF.adc_cycle_int_sts_en,`DUT_IF.adc_sample_int_sts_en,`DUT_IF.adc_delta_int_sts_en,`DUT_IF.adc_mode,`DUT_IF.pair_num};
    `WR_NORMAL_REG(`SOC_STIM_PAD_CTRL, top_test_cfg.wr_data[0], top_test_cfg.pads);
    top_test_cfg.wr_data[0] = {`DUT_IF.stim_mon_int_to_pin_en,`DUT_IF.stim_delta_data_sel,3'b0};
    `WR_NORMAL_REG(`SOC_STIM_MON_INT, top_test_cfg.wr_data[0], top_test_cfg.pads);

    repeat(1) @(posedge `CLK_CTRL_TOP.stim_monitor_dig_clk); // so sts can update
    check_int_sts_reg(intr, 0); 
    wait_for_intb_clear();
    `nnc_info("SOC_TEST", "--------------intr status disable, intr to pin enable check done---------------------\n ", NNC_LOW)


    //intr status enable, intr to pin disable
    `nnc_info("SOC_TEST", "--------------intr status enable, intr to pin disable --------------------- ", NNC_LOW)
    if(intr == "SAMPLE")begin
      `DUT_IF.adc_sample_int_sts_en = 1;       
      `DUT_IF.stim_mon_int_to_pin_en[1] = 0;
    end

    top_test_cfg.wr_data[0] = {`DUT_IF.adc_cycle_int_sts_en,`DUT_IF.adc_sample_int_sts_en,`DUT_IF.adc_delta_int_sts_en,`DUT_IF.adc_mode,`DUT_IF.pair_num};
    `WR_NORMAL_REG(`SOC_STIM_PAD_CTRL, top_test_cfg.wr_data[0], top_test_cfg.pads);
    top_test_cfg.wr_data[0] = {`DUT_IF.stim_mon_int_to_pin_en,`DUT_IF.stim_delta_data_sel,3'b0};
    `WR_NORMAL_REG(`SOC_STIM_MON_INT, top_test_cfg.wr_data[0], top_test_cfg.pads);

    if(intr == "SAMPLE") wait(`DUT_IF.exp_sample_cnt_for_sample_intr == `DUT_IF.pair_num);  // new intr comes at pair change
    //if(intr == "DELTA") @(posedge`DUT_IF.pair_change);  // new intr comes at pair change
    repeat(4) @(posedge `CLK_CTRL_TOP.stim_monitor_dig_clk); // so sts can update
    check_int_sts_reg(intr, 1); 
    wait_for_intb_clear();
    `nnc_info("SOC_TEST", "--------------intr status enable, intr to pin disable check done---------------------\n", NNC_LOW)

   //intr status disable, intr to pin disable
    `nnc_info("SOC_TEST", "--------------intr status disable, intr to pin disable --------------------- ", NNC_LOW)
    if(intr == "SAMPLE")begin
      `DUT_IF.adc_sample_int_sts_en = 0;       
      `DUT_IF.stim_mon_int_to_pin_en[1] = 0;
    end

    top_test_cfg.wr_data[0] = {`DUT_IF.adc_cycle_int_sts_en,`DUT_IF.adc_sample_int_sts_en,`DUT_IF.adc_delta_int_sts_en,`DUT_IF.adc_mode,`DUT_IF.pair_num};
    `WR_NORMAL_REG(`SOC_STIM_PAD_CTRL, top_test_cfg.wr_data[0], top_test_cfg.pads);
    top_test_cfg.wr_data[0] = {`DUT_IF.stim_mon_int_to_pin_en,`DUT_IF.stim_delta_data_sel,3'b0};
    `WR_NORMAL_REG(`SOC_STIM_MON_INT, top_test_cfg.wr_data[0], top_test_cfg.pads);

    //if(intr == "DELTA") @(posedge`DUT_IF.pair_change);  // new intr comes at pair change
    repeat(1) @(posedge `CLK_CTRL_TOP.stim_monitor_dig_clk); // so sts can update
    check_int_sts_reg(intr, 0); 
    wait_for_intb_clear();
    `nnc_info("SOC_TEST", "--------------intr status disable, intr to pin disable check done---------------------\n", NNC_LOW)
  endtask 
 

  task wait_for_intb();
    `nnc_info("SOC_TEST", "wait for STIM int and INTB assert", NNC_LOW)

    //fork : wait_for_intr
    //  begin
        wait(`ZMEAS_TOP.o_stim_mon_int === 1);    

        if(`SOC_TB.INT[2] === 1'bx)
          `nnc_fatal("TEST", $sformatf("STIM INT asserted but INT[2] = %0d", `SOC_TB.INT[2]))

        if(`DUT_IF.int_active_level_high_or_low == 1) 
           wait(`SOC_TB.INT[2] === 1);
        else 
          wait(`SOC_TB.INT[2]=== 0);
    //  end 

    //  begin
    //    #30ms;
    //    `nnc_fatal("TEST", $sformatf("TIMEOUT: new INT[2] not received , older not cleared properly ?? "))
    //  end 
    //join_any
    //disable wait_for_intr;

    `nnc_info("SOC_TEST", "wait done for STIM int and INT[2] assert", NNC_LOW)
  endtask : wait_for_intb

  task wait_for_intb_clear();
    //fork : wait_for_intr_clr
    //  begin
        `nnc_info("SOC_TEST", "wait for INT[2] clear", NNC_LOW)
        if(`DUT_IF.intr_length_slct_level_or_pulse == 0)begin // level intr
          if(`DUT_IF.int_active_level_high_or_low == 1)// active high 
            wait(`SOC_TB.INT[2] === 0);
          else 
            wait(`SOC_TB.INT[2] === 1);
        end 
        else begin // pulse intr
          wait(`ZMEAS_TOP.o_stim_mon_int === 0);    
        end 
        `nnc_info("SOC_TEST", "wait done for INT[2] clear", NNC_LOW)
    //  end 

    //  begin
    //    #20ms;
    //    `nnc_fatal("TEST", $sformatf("TIMEOUT: INT[2] not cleared = %0d", `SOC_TB.INT[2]))
    //  end 
    //join_any

    //disable wait_for_intr_clr;

  endtask : wait_for_intb_clear

  task automatic check_int_sts_reg(string intr, bit exp_int_sts);
    bit [7:0] rd_data;

    `nnc_info("SOC_TEST", $sformatf("check_int_sts_reg for exp_int_sts :%0d ", exp_int_sts), NNC_LOW)
    // check int sts reg
    if(`DUT_IF.clear_intr_manual_or_auto === 0) begin // in case of manual clear w1c
      if(use_old_intr_reg_or_general_reg_to_clr == 0) begin // old intr status register

        if(intr == "LEADOFF")begin
	  assert(top_test_cfg.randomize() with {reg_addr == `SOC_STIM_MON_LOFF_INT_STS0_L; no_of_bytes == 2;});
	  `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
          top_test_cfg.leadoff_int_sts = {top_test_cfg.rd_data[0],top_test_cfg.rd_data[1]};
          if(top_test_cfg.leadoff_int_sts !== `DUT_IF.final_leadoff_intr)begin 
            `nnc_error("TEST", $sformatf(" LEADOFF STATUS mismatch act_int_sts = %0b, tb int_sts=%0b", top_test_cfg.leadoff_int_sts,`DUT_IF.final_leadoff_intr))
          end
          `DUT_IF.final_leadoff_intr = 0;
          top_test_cfg.stim_int_sts = |top_test_cfg.leadoff_int_sts;
        end
        else if(intr == "SHORT")begin
	  assert(top_test_cfg.randomize() with {reg_addr == `SOC_STIM_MON_SHORT_INT_STS0_L; no_of_bytes == 2;});
	  `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
          top_test_cfg.short_int_sts = {top_test_cfg.rd_data[0],top_test_cfg.rd_data[1]};
          if(top_test_cfg.short_int_sts !== `DUT_IF.final_short_intr)begin 
            `nnc_error("TEST", $sformatf(" SHORT STATUS mismatch act_int_sts = %0b, tb int_sts=%0b", top_test_cfg.short_int_sts,`DUT_IF.final_short_intr))
          end
          `DUT_IF.final_short_intr = 0;
          top_test_cfg.stim_int_sts = |top_test_cfg.short_int_sts;
        end
        else begin
          `RD_NORMAL_REG(`SOC_STIM_MON_INT,top_test_cfg.pads,rd_data); // ch0 sts
          if(intr == "CYCLE") top_test_cfg.stim_int_sts = rd_data[2];
          if(intr == "SAMPLE") top_test_cfg.stim_int_sts = rd_data[1];
          if(intr == "DELTA") top_test_cfg.stim_int_sts = rd_data[0];
        end
      end

      else begin // new general intr sts reg
        if(intr == "LEADOFF")begin
	  assert(top_test_cfg.randomize() with {reg_addr == `SOC_GENERAL_INT_STS_7_REG; no_of_bytes == 2;});
	  `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
          top_test_cfg.leadoff_int_sts = {top_test_cfg.rd_data[0],top_test_cfg.rd_data[1]};
          if(top_test_cfg.leadoff_int_sts !== `DUT_IF.final_leadoff_intr)begin 
            `nnc_error("TEST", $sformatf(" GENERAL LEADOFF STATUS mismatch act_int_sts = %0b, tb int_sts=%0b", top_test_cfg.leadoff_int_sts,`DUT_IF.final_leadoff_intr))
          end
          `DUT_IF.final_leadoff_intr = 0;
          top_test_cfg.stim_int_sts = top_test_cfg.leadoff_int_sts;
        end
        else if(intr == "SHORT")begin
	  assert(top_test_cfg.randomize() with {reg_addr == `SOC_GENERAL_INT_STS_9_REG; no_of_bytes == 2;});
	  `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
          top_test_cfg.short_int_sts = {top_test_cfg.rd_data[0],top_test_cfg.rd_data[1]};
          if(top_test_cfg.short_int_sts !== `DUT_IF.final_short_intr)begin 
            `nnc_error("TEST", $sformatf(" GENERAL SHORT STATUS mismatch act_int_sts = %0b, tb int_sts=%0b", top_test_cfg.short_int_sts,`DUT_IF.final_short_intr))
          end
          `DUT_IF.final_short_intr = 0;
          top_test_cfg.stim_int_sts = top_test_cfg.short_int_sts;
        end
        else begin
          `RD_NORMAL_REG(`SOC_GENERAL_INT_STS_B_REG,top_test_cfg.pads, rd_data); // 
          if(intr == "CYCLE") top_test_cfg.stim_int_sts = rd_data[2];
          if(intr == "SAMPLE") top_test_cfg.stim_int_sts = rd_data[1];
          if(intr == "DELTA") top_test_cfg.stim_int_sts = rd_data[0];
        end
      end

      if(top_test_cfg.stim_int_sts !== exp_int_sts)begin
        `nnc_error("TEST", $sformatf("STIM INT STS MISMATCH ERROR for %s intr, exp_int_sts = %0h, act_int_sts=%0h", intr, exp_int_sts,top_test_cfg.stim_int_sts))
      end
      else begin
        `nnc_info("SOC_TEST", "STIM INT STS MATCHED", NNC_LOW)
      end
    end
  endtask : check_int_sts_reg

  task clear_int_sts_reg(string intr);
    bit [7:0] wr_data[16];

    // clear int sts reg
    if(`DUT_IF.clear_intr_manual_or_auto === 1'b0)begin // manual clear - w1c 
      if(intr == "LEADOFF")begin
	assert(top_test_cfg.randomize() with {reg_addr == `SOC_STIM_MON_LOFF_INT_STS0_L; no_of_bytes == 2;  wr_data[0] == top_test_cfg.leadoff_int_sts[15:8]; wr_data[1] == top_test_cfg.leadoff_int_sts[7:0];});
	`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);
	`nnc_info("SOC_TEST", "leadoff int sts cleared by w1c", NNC_LOW)
      end
      if(intr == "SHORT")begin
	assert(top_test_cfg.randomize() with {reg_addr == `SOC_STIM_MON_SHORT_INT_STS0_L; no_of_bytes == 2;  wr_data[0] == top_test_cfg.short_int_sts[15:8]; wr_data[1] == top_test_cfg.short_int_sts[7:0];});
	`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);
	`nnc_info("SOC_TEST", "short int sts cleared by w1c", NNC_LOW)
      end
      else begin
        if(intr == "CYCLE")  wr_data[0] = {`DUT_IF.stim_mon_int_to_pin_en,`DUT_IF.stim_delta_data_sel,3'b100};
        if(intr == "SAMPLE") wr_data[0] = {`DUT_IF.stim_mon_int_to_pin_en,`DUT_IF.stim_delta_data_sel,3'b010};
        if(intr == "DELTA")  wr_data[0] = {`DUT_IF.stim_mon_int_to_pin_en,`DUT_IF.stim_delta_data_sel,3'b001};
        `WR_NORMAL_REG(`SOC_STIM_MON_INT, wr_data[0], top_test_cfg.pads);
        `nnc_info("SOC_TEST", "stim int sts cleared by w1c", NNC_LOW)
      end
    end
    else begin // auto clear - r1c
      if(use_old_intr_reg_or_general_reg_to_clr == 0) begin // old intr status register
        if(intr == "LEADOFF")begin
	  assert(top_test_cfg.randomize() with {reg_addr == `SOC_STIM_MON_LOFF_INT_STS0_L; no_of_bytes == 2;});
	  `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
          `nnc_info("SOC_TEST", "leadoff int sts cleared by old int sts reg - r1c", NNC_LOW)
        end
        if(intr == "SHORT")begin
	  assert(top_test_cfg.randomize() with {reg_addr == `SOC_STIM_MON_SHORT_INT_STS0_L; no_of_bytes == 2;});
	  `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
          `nnc_info("SOC_TEST", "short int sts cleared by old int sts reg - r1c", NNC_LOW)
        end
        else begin
          `RD_NORMAL_REG(`SOC_STIM_MON_INT,top_test_cfg.pads, top_test_cfg.rd_data[0]); 
          if(intr == "CYCLE") top_test_cfg.stim_int_sts = top_test_cfg.rd_data[0][2];
          if(intr == "SAMPLE")top_test_cfg.stim_int_sts = top_test_cfg.rd_data[0][1];
          if(intr == "DELTA") top_test_cfg.stim_int_sts = top_test_cfg.rd_data[0][0];
          `nnc_info("SOC_TEST", "stim int sts cleared by old int sts reg - r1c", NNC_LOW)
        end
      end
      else begin // new general intr sts reg
        if(intr == "LEADOFF")begin
	  assert(top_test_cfg.randomize() with {reg_addr == `SOC_GENERAL_INT_STS_7_REG; no_of_bytes == 2;});
	  `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
          `nnc_info("SOC_TEST", "leadoff int sts cleared by new general int sts reg - r1c", NNC_LOW)
        end
        else if(intr == "SHORT")begin
	  assert(top_test_cfg.randomize() with {reg_addr == `SOC_GENERAL_INT_STS_9_REG; no_of_bytes == 2;});
	  `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
          `nnc_info("SOC_TEST", "short int sts cleared by new general int sts reg - r1c", NNC_LOW)
        end
        else begin
        `RD_NORMAL_REG(`SOC_GENERAL_INT_STS_B_REG,top_test_cfg.pads, top_test_cfg.rd_data[0]); 
        if(intr == "CYCLE") top_test_cfg.stim_int_sts = top_test_cfg.rd_data[0][2];
        if(intr == "SAMPLE") top_test_cfg.stim_int_sts = top_test_cfg.rd_data[0][1];
        if(intr == "DELTA") top_test_cfg.stim_int_sts = top_test_cfg.rd_data[0][0];
	`nnc_info("SOC_TEST", "stim int sts cleared by new general int sts reg - r1c", NNC_LOW)
        end
      end
    end

  endtask : clear_int_sts_reg

  virtual task config_regs;
    //use_old_intr_reg_or_general_reg_to_clr = $random; // 0: use old sts regs to clear int, 1 : use new general reg to clear int
    use_old_intr_reg_or_general_reg_to_clr = 0; // 0: use old sts regs to clear int, 1 : use new general reg to clear int

    // configure GENERAL INT CTRL
    top_test_cfg.wr_data[0] = {5'b0,`DUT_IF.int_active_level_high_or_low,`DUT_IF.clear_intr_manual_or_auto,`DUT_IF.intr_length_slct_level_or_pulse};
    `WR_NORMAL_REG(`SOC_GENERAL_INT_CTRL_REG, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // check INT RESET value
    if(`DUT_IF.int_active_level_high_or_low === 0) begin
	if(`SOC_TB.INT[2] !== 1)
	  `nnc_error("SOC_TEST", "Error! RESET VALUE INT[2] not active low as expected!!")
	else
	  `nnc_info("SOC_TEST", "Active low INT[2] selected!", NNC_LOW)
    end
    else begin
	if(`SOC_TB.INT[2] !== 0)
	  `nnc_error("SOC_TEST", "Error! RESET VALUE INT[2] not active high as expected!!")
	else
	   `nnc_info("SOC_TEST", "Active high INT[2] selected!", NNC_LOW)
    end

    fork
      pulse_INT_active_high_check;
      pulse_INT_active_low_check;
      level_INT_active_high_check;
      level_INT_active_low_check;
    join_none

    top_test_cfg.wr_data[0] = {4'b0,`DUT_IF.select_2nd_max_min,`DUT_IF.adc_delta_data_in_manual_en,2'b00};
    `WR_NORMAL_REG(`SOC_ADC_DELTA_DATA_TAG_H, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // configure 
    top_test_cfg.wr_data[0] = {3'b0, `DUT_IF.mon_adc_clk_inv, `DUT_IF.mon_clk_div}; // 4Mhz
    `WR_NORMAL_REG(`SOC_STIM_MON_CLK_RST_CTRL, top_test_cfg.wr_data[0], top_test_cfg.pads);

    top_test_cfg.wr_data[0] = {`DUT_IF.adc_cycle_int_sts_en,`DUT_IF.adc_sample_int_sts_en,`DUT_IF.adc_delta_int_sts_en,`DUT_IF.adc_mode,`DUT_IF.pair_num};
    `WR_NORMAL_REG(`SOC_STIM_PAD_CTRL, top_test_cfg.wr_data[0], top_test_cfg.pads);

    top_test_cfg.wr_data[0] = {`DUT_IF.stim_mon_period[7:0]};
    `WR_NORMAL_REG(`SOC_STIM_MON_PERIOD_L, top_test_cfg.wr_data[0], top_test_cfg.pads);

    top_test_cfg.wr_data[0] = {`DUT_IF.stim_mon_period[15:8]};
    `WR_NORMAL_REG(`SOC_STIM_MON_PERIOD_H, top_test_cfg.wr_data[0], top_test_cfg.pads);

    top_test_cfg.wr_data[0] = {`DUT_IF.stim_mon_period[23:16]};
    `WR_NORMAL_REG(`SOC_STIM_MON_PERIOD_H_L, top_test_cfg.wr_data[0], top_test_cfg.pads);

    top_test_cfg.wr_data[0] = {`DUT_IF.stim_mon_period[31:24]};
    `WR_NORMAL_REG(`SOC_STIM_MON_PERIOD_H_H, top_test_cfg.wr_data[0], top_test_cfg.pads);

    top_test_cfg.wr_data[0] = {`DUT_IF.stim_mon_int_to_pin_en,`DUT_IF.stim_delta_data_sel,3'b0};
    `WR_NORMAL_REG(`SOC_STIM_MON_INT, top_test_cfg.wr_data[0], top_test_cfg.pads);

    if(`DUT_IF.adc_mode == 1) begin //manual mode
      // -------------- STIM0 --------------------
      //stim pad0 tgt1
      assert(top_test_cfg.randomize() with {reg_addr == `SOC_STIM_PAD0_TGT0_L; no_of_bytes == 2;  wr_data[0] == `DUT_IF.stim_pad0_tgt0[15:8]; wr_data[1] == `DUT_IF.stim_pad0_tgt0[7:0];});
      `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);
      
      //stim pad0 tgt2
      assert(top_test_cfg.randomize() with {reg_addr == `SOC_STIM_PAD0_TGT1_L; no_of_bytes == 2;  wr_data[0] == `DUT_IF.stim_pad0_tgt1[15:8]; wr_data[1] == `DUT_IF.stim_pad0_tgt1[7:0];});
      `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

      //stim pad0 tgt3
      assert(top_test_cfg.randomize() with {reg_addr == `SOC_STIM_PAD0_TGT2_L; no_of_bytes == 2;  wr_data[0] == `DUT_IF.stim_pad0_tgt2[15:8]; wr_data[1] == `DUT_IF.stim_pad0_tgt2[7:0];});
      `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

      //stim pad0 tgt4
      assert(top_test_cfg.randomize() with {reg_addr == `SOC_STIM_PAD0_TGT3_L; no_of_bytes == 2;  wr_data[0] == `DUT_IF.stim_pad0_tgt3[15:8]; wr_data[1] == `DUT_IF.stim_pad0_tgt3[7:0];});
      `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

      // -------------- STIM1 --------------------
      //stim pad1 tgt1
      assert(top_test_cfg.randomize() with {reg_addr == `SOC_STIM_PAD1_TGT0_L; no_of_bytes == 2;  wr_data[0] == `DUT_IF.stim_pad1_tgt0[15:8]; wr_data[1] == `DUT_IF.stim_pad1_tgt0[7:0];});
      `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);
      
      //stim pad1 tgt2
      assert(top_test_cfg.randomize() with {reg_addr == `SOC_STIM_PAD1_TGT1_L; no_of_bytes == 2;  wr_data[0] == `DUT_IF.stim_pad1_tgt1[15:8]; wr_data[1] == `DUT_IF.stim_pad1_tgt1[7:0];});
      `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

      //stim pad1 tgt3
      assert(top_test_cfg.randomize() with {reg_addr == `SOC_STIM_PAD1_TGT2_L; no_of_bytes == 2;  wr_data[0] == `DUT_IF.stim_pad1_tgt2[15:8]; wr_data[1] == `DUT_IF.stim_pad1_tgt2[7:0];});
      `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

      //stim pad1 tgt4
      assert(top_test_cfg.randomize() with {reg_addr == `SOC_STIM_PAD1_TGT3_L; no_of_bytes == 2;  wr_data[0] == `DUT_IF.stim_pad1_tgt3[15:8]; wr_data[1] == `DUT_IF.stim_pad1_tgt3[7:0];});
      `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);
    end

    // enable ADC
    top_test_cfg.wr_data[0] = {`DUT_IF.bypass_adc_data_en,`DUT_IF.read_adc_data_en,`DUT_IF.bypass_ignore_first,`DUT_IF.adc_en,`DUT_IF.stim_dly_tgt};
    `WR_NORMAL_REG(`SOC_STIM_PAD_CTRL1, top_test_cfg.wr_data[0], top_test_cfg.pads);

  endtask: config_regs

  task leadoff_config_reg();
    top_test_cfg.wr_data[0] = {4'b0,`DUT_IF.short_int_to_pin_en,`DUT_IF.leadoff_int_to_pin_en,`DUT_IF.short_int_en,`DUT_IF.leadoff_int_en};
    `WR_NORMAL_REG(`SOC_STIM_MON_LOFF_SHORT_INT_CTRL, top_test_cfg.wr_data[0], top_test_cfg.pads);

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_STIM_MON_LOFF_TH_L; no_of_bytes == 2;  wr_data[0] == {6'b0,`DUT_IF.leadoff_th[9:8]}; wr_data[1] == `DUT_IF.leadoff_th[7:0];});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    top_test_cfg.wr_data[0] = `DUT_IF.leadoff_short_th_tgt;
    `WR_NORMAL_REG(`SOC_STIM_MON_TH_TGT, top_test_cfg.wr_data[0], top_test_cfg.pads);
  endtask

  task short_config_reg();

    top_test_cfg.wr_data[0] = {4'b0,`DUT_IF.short_int_to_pin_en,`DUT_IF.leadoff_int_to_pin_en,`DUT_IF.short_int_en,`DUT_IF.leadoff_int_en};
    `WR_NORMAL_REG(`SOC_STIM_MON_LOFF_SHORT_INT_CTRL, top_test_cfg.wr_data[0], top_test_cfg.pads);

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_STIM_MON_SHORT_TH_L; no_of_bytes == 2;  wr_data[0] == {6'b0,`DUT_IF.short_th[9:8]}; wr_data[1] == `DUT_IF.short_th[7:0];});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    top_test_cfg.wr_data[0] = `DUT_IF.leadoff_short_th_tgt;
    `WR_NORMAL_REG(`SOC_STIM_MON_TH_TGT, top_test_cfg.wr_data[0], top_test_cfg.pads);

  endtask

  task pulse_INT_active_high_check;
  begin
    forever @(posedge `SOC_TB.INT[2]) begin
      if((`DUT_IF.intr_length_slct_level_or_pulse === 1) && (`DUT_IF.int_active_level_high_or_low === 1)) begin//if active high pulse INT[2] is selected
	@(posedge `DUT_IF.sys_clk);
	@(negedge `DUT_IF.sys_clk);
        if(`SOC_TB.INT[2] !== 0 && (!(`ZMEAS_TOP.o_stim_mon_int === 1)))
    	  `nnc_error("SOC_TEST", "Error! pulse INT[2] more than 1 pclk!")
	else
	  `nnc_info("SOC_TEST", "pulse INT[2] is 1 pclk!", NNC_MEDIUM)
      end 
    end
  end
  endtask

  task pulse_INT_active_low_check;
  begin
    forever @(negedge `SOC_TB.INT[2]) begin
      if((`DUT_IF.intr_length_slct_level_or_pulse === 1) && (`DUT_IF.int_active_level_high_or_low === 0)) begin//if active low pulse INT[2] is selected
	@(posedge `DUT_IF.sys_clk);
	@(negedge `DUT_IF.sys_clk);
        if(`SOC_TB.INT[2] !== 1 && !((`ZMEAS_TOP.o_stim_mon_int === 1)))
    	  `nnc_error("SOC_TEST", "Error! pulse INT[2] more than 1 pclk!")
	else
	  `nnc_info("SOC_TEST", "pulse INT[2] is 1 pclk!", NNC_MEDIUM)
      end 
    end
  end
  endtask

  task level_INT_active_high_check;
  begin
    forever @(posedge `SOC_TB.INT[2] or negedge `SOC_TB.INT[2]) begin
      if((`DUT_IF.intr_length_slct_level_or_pulse === 0) && (`DUT_IF.int_active_level_high_or_low === 1)) begin//if active high level INT[2] is selected
        if(`SOC_TB.INT[2] !== (`ZMEAS_TOP.o_stim_mon_int))
    	  `nnc_error("SOC_TEST", "Error! level INT[2] not expected!")
	else
	  `nnc_info("SOC_TEST", "level INT[2] is expected!", NNC_MEDIUM)
      end 
    end
  end
  endtask

  task level_INT_active_low_check;
  begin
    forever @(posedge `SOC_TB.INT[2] or negedge `SOC_TB.INT[2]) begin
      if((`DUT_IF.intr_length_slct_level_or_pulse === 0) && (`DUT_IF.int_active_level_high_or_low === 0)) begin//if active low level INT[2] is selected
        if(`SOC_TB.INT[2] !== ~(`ZMEAS_TOP.o_stim_mon_int))
    	  `nnc_error("SOC_TEST", "Error! level INT[2] not expected!")
	else
	  `nnc_info("SOC_TEST", "level INT[2] is expected!", NNC_MEDIUM)
      end 
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
