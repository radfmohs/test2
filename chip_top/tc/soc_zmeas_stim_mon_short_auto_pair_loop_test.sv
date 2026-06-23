/*--------------------------------------------------------------------------------------
// Copyright 2021 Nanochap, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_imeas_eegfilter__base_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_zmeas_stim_mon_short_auto_pair_loop_test                                             
// Designer	: shreeyal@nanochap.com                                                                 
// Date		: 27-05-2025                                                                     
// Revision	: 0.1 Initial version created by script                                 
--------------------------------------------------------------------------------------*/
`define TESTNAME soc_zmeas_stim_mon_short_auto_pair_loop_test
`define TESTCFG soc_zmeas_stim_mon_short_auto_pair_loop_test_cfg

class `TESTCFG extends soc_zmeas_stim_mon_auto_pair_loop_test_cfg;

  `nnc_object_utils(`TESTCFG)

  // -----------------------------------------------
  // Adding your new varialbles in config test
  // -----------------------------------------------

  // -----------------------------------------------
  // End of decalration of new variables 
  // -----------------------------------------------

  function new (string name = "soc_zmeas_stim_mon_short_auto_pair_loop_test_cfg");
    super.new(name);
  endfunction: new

  // -----------------------------------------------
  // Adding constraints of randomization
  // -----------------------------------------------

  constraint c_short_int_en              { short_int_en inside {[1:1]};}  

  constraint c_short_int_to_pin_en       { short_int_to_pin_en inside {[1:1]};}  

  //constraint c_short_th                  { short_th inside {[1:511]};}  // whole range is 1023 , short happens in half of whole range - from 512 to 1023 - so short_th max is 511
  //constraint c_short_th                  { short_th inside {[1:200]};}  // whole range is 1023 , short happens in half of whole range - from 512 to 1023 - so short_th max is 511
  constraint c_short_th                  { short_th inside {[100:100]};} 

  constraint c_leadoff_short_th_tgt         { leadoff_short_th_tgt inside {[1:10]};}  


  // -----------------------------------------------
  // End of adding constraints of randomization
  // -----------------------------------------------

endclass : `TESTCFG

class `TESTNAME extends soc_zmeas_stim_mon_auto_pair_loop_test;
   
  `nnc_component_utils(`TESTNAME)

  `TESTCFG top_test_cfg;

  function new(string name, nnc_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(nnc_phase phase);
    super.build_phase(phase);
    uvm_top.set_timeout(2s);
    //uvm_top.set_timeout(15ms);
    top_test_cfg = `TESTCFG::type_id::create("top_test_cfg", this);
  endfunction

  virtual task pre_reset_phase(nnc_phase phase);
    phase.raise_objection(this);

    super.pre_reset_phase(phase);
    assert(top_test_cfg.randomize());

    `DUT_IF.short_int_en        = top_test_cfg.short_int_en;
    `DUT_IF.short_int_to_pin_en = top_test_cfg.short_int_to_pin_en;
    `DUT_IF.short_th            = top_test_cfg.short_th;
    `DUT_IF.leadoff_short_th_tgt  = top_test_cfg.leadoff_short_th_tgt;
    `DUT_IF.leadoff_int_en        = 0;
    `DUT_IF.leadoff_int_to_pin_en = 0;
    stim_intr_checks_en = 0;

    phase.drop_objection(this);
  endtask : pre_reset_phase

  virtual task post_reset_phase(nnc_phase phase);
    phase.raise_objection(this);
    super.post_reset_phase(phase);
    phase.drop_objection(this);
  endtask : post_reset_phase

  virtual task main_phase(uvm_phase phase);
    bit reset_en; 
    phase.raise_objection(this);

    // ----------------------------------------------------------------------------------
    // Please add your code of your test here
    // ----------------------------------------------------------------------------------

    short_config_reg();
    super.main_phase(phase);

    //for(int i =0; i< 20; i++)begin
    for(int i =0; i< 5; i++)begin
      wait_for_intb();
      check_int_sts_reg("SHORT", 1); 
      clear_int_sts_reg("SHORT");
      wait_for_intb_clear();
    end
    
    // 1. apply reset 
    reset_en = 1;
    top_test_cfg.wr_data[0] = {1'b0,`DUT_IF.check_every_n, reset_en, `DUT_IF.mon_adc_clk_inv, `DUT_IF.mon_clk_div}; 
    `WR_NORMAL_REG(`SOC_STIM_MON_CLK_RST_CTRL, top_test_cfg.wr_data[0], top_test_cfg.pads);

    `nnc_info("SOC_TEST", $sformatf("ZMEAS RESET ASSERTED =%0d ",`ZMEAS_TOP.presetn), NNC_LOW)

    // 2.change the stim parameters
    assert(top_test_cfg.randomize());
    `DUT_IF.pair_num                    = top_test_cfg.pair_num;
    `DUT_IF.stim_mon_period             = top_test_cfg.stim_mon_period;

    top_test_cfg.wr_data[0] = {`DUT_IF.adc_cycle_int_sts_en,`DUT_IF.adc_sample_int_sts_en,`DUT_IF.adc_delta_int_sts_en,`DUT_IF.adc_mode,`DUT_IF.pair_num};
    `WR_NORMAL_REG(`SOC_STIM_PAD_CTRL, top_test_cfg.wr_data[0], top_test_cfg.pads);

    top_test_cfg.wr_data[0] = {`DUT_IF.stim_mon_period[7:0]};
    `WR_NORMAL_REG(`SOC_STIM_MON_PERIOD_L, top_test_cfg.wr_data[0], top_test_cfg.pads);

    top_test_cfg.wr_data[0] = {`DUT_IF.stim_mon_period[15:8]};
    `WR_NORMAL_REG(`SOC_STIM_MON_PERIOD_H, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // 2.change the short parameters
    `DUT_IF.short_th            = top_test_cfg.short_th;
    `DUT_IF.leadoff_short_th_tgt  = top_test_cfg.leadoff_short_th_tgt;
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_STIM_MON_LOFF_TH_L; no_of_bytes == 2;  wr_data[0] == {6'b0,`DUT_IF.short_th[9:8]}; wr_data[1] == `DUT_IF.short_th[7:0];});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);

    top_test_cfg.wr_data[0] = `DUT_IF.leadoff_short_th_tgt;
    `WR_NORMAL_REG(`SOC_STIM_MON_TH_TGT, top_test_cfg.wr_data[0], top_test_cfg.pads);

    // 3. remove reset
    reset_en = 0;
    top_test_cfg.wr_data[0] = {1'b0,`DUT_IF.check_every_n, reset_en, `DUT_IF.mon_adc_clk_inv, `DUT_IF.mon_clk_div}; 
    `WR_NORMAL_REG(`SOC_STIM_MON_CLK_RST_CTRL, top_test_cfg.wr_data[0], top_test_cfg.pads);
    `nnc_info("SOC_TEST", $sformatf("ZMEAS RESET REMOVED =%0d ",`ZMEAS_TOP.presetn), NNC_LOW)

    //#5ms;
    for(int i =0; i< 3; i++)begin
      wait_for_intb();
      check_int_sts_reg("SHORT", 1); 
      clear_int_sts_reg("SHORT");
      wait_for_intb_clear();
    end

    short_intr_checks();

    `nnc_info("SOC_TEST", "soc_zmeas_stim_mon_short_auto_pair_loop_test end now", NNC_LOW)
    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ----------------------------------------------------------------------------------

    phase.drop_objection(this);
  endtask: main_phase

  task short_intr_checks();
    // intr status and intr pin both are enable at this stage 
    wait_for_intb();
    check_int_sts_reg("SHORT", 1); 

    // intr status disable
    `nnc_info("SOC_TEST", "--------------intr status disable --------------------- ", NNC_LOW)
    `DUT_IF.short_int_en = 0;       
    top_test_cfg.wr_data[0] = {4'b0,`DUT_IF.short_int_to_pin_en,`DUT_IF.leadoff_int_to_pin_en,`DUT_IF.short_int_en,`DUT_IF.leadoff_int_en};
    `WR_NORMAL_REG(`SOC_STIM_MON_LOFF_SHORT_INT_CTRL, top_test_cfg.wr_data[0], top_test_cfg.pads);

    repeat(1) @(posedge `CLK_CTRL_TOP.stim_monitor_dig_clk); // so sts can update
    check_int_sts_reg("SHORT", 0); 
    wait_for_intb_clear();
    `nnc_info("SOC_TEST", "--------------intr status disable check done---------------------\n ", NNC_LOW)
 

    // intr status disable, intr to pin enable
    `nnc_info("SOC_TEST", "--------------intr status disable, intr to pin enable --------------------- ", NNC_LOW)
    `DUT_IF.short_int_en = 0;
    `DUT_IF.short_int_to_pin_en = 1;
    top_test_cfg.wr_data[0] = {4'b0,`DUT_IF.short_int_to_pin_en,`DUT_IF.leadoff_int_to_pin_en,`DUT_IF.short_int_en,`DUT_IF.leadoff_int_en};
    `WR_NORMAL_REG(`SOC_STIM_MON_LOFF_SHORT_INT_CTRL, top_test_cfg.wr_data[0], top_test_cfg.pads);

    repeat(1) @(posedge `CLK_CTRL_TOP.stim_monitor_dig_clk); // so sts can update
    check_int_sts_reg("SHORT", 0); 
    wait_for_intb_clear();
    `nnc_info("SOC_TEST", "--------------intr status disable, intr to pin enable check done---------------------\n ", NNC_LOW)


    //intr status enable, intr to pin disable
    `nnc_info("SOC_TEST", "--------------intr status enable, intr to pin disable --------------------- ", NNC_LOW)
    `DUT_IF.short_int_en = 1;
    `DUT_IF.short_int_to_pin_en = 0;
    top_test_cfg.wr_data[0] = {4'b0,`DUT_IF.short_int_to_pin_en,`DUT_IF.leadoff_int_to_pin_en,`DUT_IF.short_int_en,`DUT_IF.leadoff_int_en};
    `WR_NORMAL_REG(`SOC_STIM_MON_LOFF_SHORT_INT_CTRL, top_test_cfg.wr_data[0], top_test_cfg.pads);

    @(posedge`DUT_IF.pair_change);  // new intr comes at pair change
    repeat(2) @(posedge `CLK_CTRL_TOP.stim_monitor_dig_clk); // so sts can update
    check_int_sts_reg("SHORT", 1); 
    wait_for_intb_clear();
    `nnc_info("SOC_TEST", "--------------intr status enable, intr to pin disable check done---------------------\n", NNC_LOW)


    //intr status disable, intr to pin disable
    `nnc_info("SOC_TEST", "--------------intr status disable, intr to pin enable --------------------- ", NNC_LOW)
    `DUT_IF.short_int_en = 0;
    `DUT_IF.short_int_to_pin_en = 0;

    top_test_cfg.wr_data[0] = {4'b0,`DUT_IF.short_int_to_pin_en,`DUT_IF.leadoff_int_to_pin_en,`DUT_IF.short_int_en,`DUT_IF.leadoff_int_en};
    `WR_NORMAL_REG(`SOC_STIM_MON_LOFF_SHORT_INT_CTRL, top_test_cfg.wr_data[0], top_test_cfg.pads);

    repeat(1) @(posedge `CLK_CTRL_TOP.stim_monitor_dig_clk); // so sts can update
    check_int_sts_reg("SHORT", 0); 
    wait_for_intb_clear();
    `nnc_info("SOC_TEST", "--------------intr status disable, intr to pin enable check done---------------------\n ", NNC_LOW)

  endtask 
endclass : `TESTNAME
