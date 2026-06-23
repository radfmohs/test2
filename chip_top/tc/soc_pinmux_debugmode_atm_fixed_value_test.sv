//========================================================================================================  
// -------------------------------------------------------------------------------------------------------  
//  Nanochap Electronics Copyright (C) 2014. ALL RIGHTS RESERVED.  
// -------------------------------------------------------------------------------------------------------  
// Project name    : ENS2
// File name       : soc_pinmux_debugmode_atm_fixed_value_test.sv
// Description     : Testcase soc_pinmux_debugmode_atm_fixed_value_test     
// -------------------------------------------------------------------------------------------------------  
// Revision History:  
// -------------------------------------------------------------------------------------------------------  
// Revision       Date(dd-mm-yyyy)     Author                       Description  
// -------------------------------------------------------------------------------------------------------  
//   1.0          14-08-2024          zhenghong.yu@nanochap.com     Initial version created in BAF4
//   2.0          20-10-2024          ddang@nanochap.com            Cloned to use for BMS6 
// -------------------------------------------------------------------------------------------------------  
//========================================================================================================
`define TESTNAME soc_pinmux_debugmode_atm_fixed_value_test
`define TESTCFG soc_pinmux_debugmode_atm_fixed_value_test_cfg

class `TESTCFG extends soc_base_test_cfg;

  `nnc_object_utils(`TESTCFG)

  // -----------------------------------------------
  // Adding your new varialbles in config test
  // -----------------------------------------------
  rand logic [7:0] data[256];
  rand logic [7:0] reg_addr;
  rand int    no_of_bytes;   
  logic [7:0] rd_data[];
  logic [7:0] atm;
  logic [7:0] save_trim_wdata[9];
  rand logic [7:0] otp_addr;  
  rand logic [7:0] otp_data;  
  rand logic [7:0] pads;
  rand bit         trim_tag_prepare_en;
  rand logic [2:0] atm_no;   
  // -----------------------------------------------
  // End of decalration of new variables 
  // -----------------------------------------------

  function new (string name = "soc_pinmux_debugmode_atm_fixed_value_test_cfg");
    super.new(name);
    
  endfunction: new

  // -----------------------------------------------
  // Adding constraints of randomization
  // -----------------------------------------------
  constraint c_atm_no { soft atm_no inside {[7:0]};};

  constraint c_trim_tag_prepare_en { soft trim_tag_prepare_en inside {[1:0]};};

  constraint c_no_of_bytes  { soft no_of_bytes == 2; }

  // testmode_sel[1:0] : 00-Normal mode, 01: Scanmode, 10: BIST mode, 11 atm0/1/2/3/4
  constraint c_testmode_sel { soft testmode_sel == 2'b00; }

  constraint c_altf_sel     { soft altf_sel == 2'b00; }

  constraint c_hfosc_variation        { soft hfosc_variation inside {[100:100]}; } // 90% - 110%

  constraint c_io_model_check_off { io_model_check_off == 1'b1; } 

  constraint c_ext_clk_en             { ext_clk_en == 1;}     //1: enable 2MHZ external clock, 0: enable 2MHZ internal osc model

  // Enable/Disable to fix the output of Internal HFOSC to Ground                 // 1: disble pin to 2MHZ internal osc model, 0:enable pin to internal 2MHZ osc model
  constraint c_hfosc_fixed_gnd_en     { hfosc_fixed_gnd_en == ext_clk_en;}          
                                      
  // Enable/Disable to fix the output of External HFOSC to Ground                 // 1: disble pin to 2MHZ exeternal osc model, 0:enable pin to exeternal 2MHZ osc model
  constraint c_ext_hfosc_fixed_gnd_en { ext_hfosc_fixed_gnd_en == !ext_clk_en;}
 

  // -----------------------------------------------
  // End of adding constraints of randomization
  // -----------------------------------------------

endclass : `TESTCFG

class `TESTNAME extends soc_base_test;
  static bit rand_bit;   
  static logic [20:0] rand_num;   
  static logic [7:0] reg_ana_en_0_0;
  static logic [7:0] reg_ana_en_0_1;
  static logic [7:0] reg_ana_en_0_2;
  static logic [7:0] reg_ana_en_0_3;
  static logic [7:0] reg_ana_en_0_4;
  static logic [7:0] reg_ana_en_0_5;
  static logic [7:0] reg_ana_en_0_6;
  static logic [7:0] reg_ana_en_0_7;
  static logic [7:0] reg_ana_en_0_8;
  static logic [7:0] reg_ana_en_0_9;
  static logic [7:0] reg_ana_en_0_13;
  static logic [7:0] reg_ana_en_0_14;
  static logic [7:0] reg_ana_en_1_0;
  static logic [7:0] reg_ana_en_1_1;
  static logic [7:0] reg_ana_en_1_2;
  static logic [7:0] reg_ana_en_1_3;
  static logic [7:0] reg_ana_en_1_4;
  static logic [7:0] reg_ana_en_1_5;
  static logic [7:0] reg_ana_en_1_6;
  static logic [7:0] reg_tsc_ctrl;

  `nnc_component_utils(`TESTNAME)

  `TESTCFG top_test_cfg;

  function new(string name, nnc_component parent);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(nnc_phase phase);
    super.build_phase(phase);
    `nnc_top.set_timeout(2s/1ns);
    top_test_cfg = `TESTCFG::type_id::create("top_test_cfg", this);
  endfunction

  virtual task pre_reset_phase(nnc_phase phase);
    phase.raise_objection(this);

    super.pre_reset_phase(phase);

    assert(top_test_cfg.randomize() with {altf_sel == 0;});

    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;

    `DUT_IF.altf_sel = top_test_cfg.altf_sel;

  // Select internal/external clock sources
    `DUT_IF.ext_clk_en = top_test_cfg.ext_clk_en;			  // 1: external EXT_2MHZ will be driven to SOC from OSC model

    // enable to fix 1'b0 to internal clk
    `DUT_IF.hfosc_fixed_gnd_en = top_test_cfg.hfosc_fixed_gnd_en;         // 1: disble pin to 2MHZ internal osc model, 0:enable pin to internal 2MHZ osc model

    // enable to fix 1'b0 to ext clk
    `DUT_IF.ext_hfosc_fixed_gnd_en = top_test_cfg.ext_hfosc_fixed_gnd_en; // 1: disble pin to 2MHZ exeternal osc model, 0:enable pin to exeternal 2MHZ osc model

    // Clock variation of HFOSC
    `DUT_IF.hfosc_variation = top_test_cfg.hfosc_variation;

    // ==================
    // Scoreboard enables
    // ==================
    `SPI_SCB_EN = 1'b0;
    `ANALOG_SCOREBOARD_EN = 1'b0;
    `WAVEGEN_SCB_DRV_0_EN = 1'b0;
    `WAVEGEN_SHORT_DETECT_SCB_EN = 1'b0; 
 
    phase.drop_objection(this);
  endtask : pre_reset_phase

  virtual task main_phase(uvm_phase phase);
    phase.raise_objection(this);

    `nnc_info("SOC_TEST", "soc_pinmux_debugmode_atm_fixed_value_test start", UVM_LOW)

    // ----------------------------------------------------------------------------------
    // Please add your code of your test here
    // ---------------------------------------------------------------------------------- 
    // This is sample to write a data to Register
    `DUT_IF.pinmux_mode = 1;
    `DUT_IF.io_model_check_off = 1;  
    `DUT_IF.otp_ignore_check_en = 1;

    do_run;       
            
    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ----------------------------------------------------------------------------------
    phase.drop_objection(this);
  endtask: main_phase

  virtual task do_run;

    begin
`ifndef FPGA
    #2ms;
    // ---------------------------------------------------- 
    // Part I:  Change fixed value when ATM_HC_SEL default 
    // ----------------------------------------------------
    //Enable SOC_ATM_HC_SEL to make fixed signal values control by spi
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ATM_HC_SEL; no_of_bytes == 1; data[0] == 8'b0000_0000;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    #100;
    
    //Section 0: 0xC2 : Bit[0]:D2A_OSC8MHZEN = 0, Bit[1]:D2A_BGBUFFER_CPTEST_EN = 1'b1
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_1; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC3 : Bit[0]:D2A_SDMVREFPBUFF_EN = 0, Bit[1]:D2A_SDMVCMBUFF_EN = 1'b1, Bit[2]:D2A_VCMGENBUFF_EN = 1'b1, Bit[3]:D2A_RLD_ELECTRODE_EN = 1'b1
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_2; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC5 : Bit[7:0]:D2A_EEFLNA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_4; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC6 : Bit[15:8]:D2A_EEFLNA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_5; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC9 : Bit[7:0]:D2A_EEFPGA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_8; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xCA : Bit[7:0]:D2A_EEFPGA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_9; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 1\n", UVM_LOW);
    
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {8'h01} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC2 : Bit[7:0]:D2A_SDMEN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_1; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC3 : Bit[15:8]:D2A_SDMEN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_2; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC4 : Bit[7:0]:D2A_SDMBUFF_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_3; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC5 : Bit[15:8]:D2A_SDMBUFF_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_4; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //0x6C : Bit[0]:D2A_EN_TSC = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_TSC_CTRL_REG; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);
    
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    // ========================================================================
    // Before entering ATM mode, Disbale internal POR and clock
    // ========================================================================
   `nnc_info("Disable internal POR and clock", "Disable internal POR and clock", UVM_LOW);
    //force `SOC_TOP.A2D_POR = 1'b0;
    //stuck internal POR=1
    //force `SOC_TB.UNLOCK = 1'b0;
    //force `SOC_TOP.A2D_POR = 1'b0;
    force `SOC_TB.VDD_DIG = 1'b0;

    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
   
    `nnc_info("Enable internal POR and clock", "Enable internal POR and clock", UVM_LOW);
    //stuck internal POR=1
    //force `SOC_TB.A2D_SW_POWER_POR = 1'b1;
    //force `SOC_TB.UNLOCK = 1'b1;
    force `SOC_TB.VDD_DIG = 1'b1;
    //release `SOC_TOP.A2D_SW_POWER_POR;
    //release `SOC_TOP.CLKSEL;   
 
    force `SOC_TB.ext_resetn = 1'b0;
    //force `SOC_TOP.A2D_SW_POWER_POR = 1'b0;
    #1000
    force `SOC_TB.ext_resetn = 1'b1;
    //force `SOC_TOP.A2D_SW_POWER_POR = 1'b1;
    //release `SOC_TOP.RESETn;
    #1ms

    // ATM0 FIXED VALUE SESSION
    // Before ATM0 Mode
    // Chaging the fixed value
    
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);

    //Section 0: 0xC1 : Bit[0]:D2A_BIST_EN = 0, Bit[5:1]:D2A_BIST_SEL = 5'b11111
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {2'h0, 5'b11111, 1'b0} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //Section 0: 0xC2 : Bit[0]:D2A_OSC8MHZEN = 0, Bit[1]:D2A_BGBUFFER_CPTEST_EN = 1'b0
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_1; no_of_bytes == 1; data[0] == {8'h00} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    // Enter ATM MODE
    // Enter ATM0 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b00000;
    #100;
   
    `nnc_info("Checking ATM - Start", "Checking ATM 0 Done", UVM_LOW);
    // Enter ATM0 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[0] !== 1'b1) `nnc_error("ATM0",$sformatf("Enter atm1 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b00000) `nnc_error("ATM0",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b00000",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM0",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== 1'b1) `nnc_error("ATM0",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_OSC8MHZEN)); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== 1'b1) `nnc_error("ATM0",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN));
   `nnc_info("Checking ATM - Done", "Checking ATM 0 Done", UVM_LOW);
    
    // ATM1 FIXED VALUE SESSION
    // Before ATM1 Mode

    // Chaging the fixed value
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);

    //Section 0: 0xC1 : Bit[0]:D2A_BIST_EN = 0, Bit[5:1]:D2A_BIST_SEL = 5'b11111
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {2'h0, 5'b11111, 1'b0} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //Section 0: 0xC2 : Bit[0]:D2A_OSC8MHZEN = 0, Bit[1]:D2A_BGBUFFER_CPTEST_EN = 1'b1
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_1; no_of_bytes == 1; data[0] == {8'h00} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
   
    // Enter ATM MODE
    // Enter ATM1 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b00001;
    #100;
   
    `nnc_info("Checking ATM - Start", "Checking ATM1 Done", UVM_LOW);
    
    // Enter ATM1 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[1] !== 1'b1) `nnc_error("ATM1",$sformatf("Enter ATM1 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b00001) `nnc_error("ATM1",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b00001",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM1",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== 1'b1) `nnc_error("ATM1",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_OSC8MHZEN)); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== 1'b1) `nnc_error("ATM1",$sformatf("D2A_BGBUFFER_CPTEST_EN, Real data:%b not match 1'b1",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN));
   `nnc_info("Checking ATM - Done", "Checking ATM1 Done", UVM_LOW);
    
    // ATM2 FIXED VALUE SESSION
    // Before ATM2 Mode
    // Chaging the fixed value
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);

    //Section 0: 0xC1 : Bit[0]:D2A_BIST_EN = 0, Bit[5:1]:D2A_BIST_SEL = 5'b11111
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {2'h0, 5'b11111, 1'b0} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //Section 0: 0xC2 : Bit[0]:D2A_OSC8MHZEN = 0, Bit[1]:D2A_BGBUFFER_CPTEST_EN = 1'b1
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_1; no_of_bytes == 1; data[0] == {8'h00} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    // Enter ATM MODE
    // Enter ATM2 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b00010;
    #100;
   `nnc_info("Checking ATM - Start", "Checking ATM2 Done", UVM_LOW);
    
    // Enter ATM2 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[2] !== 1'b1) `nnc_error("ATM2",$sformatf("Enter ATM2 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b00010) `nnc_error("ATM2",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b00010",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM2",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== 1'b1) `nnc_error("ATM2",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_OSC8MHZEN)); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== 1'b1) `nnc_error("ATM2",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN));
   `nnc_info("Checking ATM - Done", "Checking ATM2 Done", UVM_LOW);
    
    // ATM3 FIXED VALUE SESSION
    // Before ATM3 Mode
    // Chaging the fixed value
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);

    //Section 0: 0xC1 : Bit[0]:D2A_BIST_EN = 0, Bit[5:1]:D2A_BIST_SEL = 5'b11111
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {2'h0, 5'b11111, 1'b0} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //Section 0: 0xC2 : Bit[0]:D2A_OSC8MHZEN = 0, Bit[1]:D2A_BGBUFFER_CPTEST_EN = 1'b1
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_1; no_of_bytes == 1; data[0] == {8'h00} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    // Enter ATM MODE
    // Enter ATM3 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b00011;
    #100;
   `nnc_info("Checking ATM - Start", "Checking ATM3 Done", UVM_LOW);
    
    // Enter ATM3 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[3] !== 1'b1) `nnc_error("ATM3",$sformatf("Enter ATM3 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b00011) `nnc_error("ATM3",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b00011",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM3",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== 1'b1) `nnc_error("ATM3",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_OSC8MHZEN)); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== 1'b1) `nnc_error("ATM3",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN));
   `nnc_info("Checking ATM - Done", "Checking ATM3 Done", UVM_LOW);
    
    // ATM4 FIXED VALUE SESSION
    // Before ATM4 Mode
    // Chaging the fixed value
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);

    //Section 0: 0xC1 : Bit[0]:D2A_BIST_EN = 0, Bit[5:1]:D2A_BIST_SEL = 5'b11111
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {2'h0, 5'b11111, 1'b0} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //Section 0: 0xC2 : Bit[0]:D2A_OSC8MHZEN = 0, Bit[1]:D2A_BGBUFFER_CPTEST_EN = 1'b1
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_1; no_of_bytes == 1; data[0] == {8'h00} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    // Enter ATM MODE
    // Enter ATM4 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b00100;
    #100;
   `nnc_info("Checking ATM - Start", "Checking ATM4 Done", UVM_LOW);
    
    // Enter ATM4 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[4] !== 1'b1) `nnc_error("ATM4",$sformatf("Enter ATM4 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b00100) `nnc_error("ATM4",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b00100",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM4",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== 1'b1) `nnc_error("ATM4",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_OSC8MHZEN)); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== 1'b1) `nnc_error("ATM4",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN));
   `nnc_info("Checking ATM - Done", "Checking ATM4 Done", UVM_LOW);
    
    // ATM5 FIXED VALUE SESSION
    // Before ATM5 Mode
    // Chaging the fixed value
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);

    //Section 0: 0xC1 : Bit[0]:D2A_BIST_EN = 0, Bit[5:1]:D2A_BIST_SEL = 5'b11111
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {2'h0, 5'b11111, 1'b0} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //Section 0: 0xC2 : Bit[0]:D2A_OSC8MHZEN = 0, Bit[1]:D2A_BGBUFFER_CPTEST_EN = 1'b1
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_1; no_of_bytes == 1; data[0] == {8'h00} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    // Enter ATM MODE
    // Enter ATM5 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b00101;
    #100;
   `nnc_info("Checking ATM - Start", "Checking ATM5 Done", UVM_LOW);
    
    // Enter ATM5 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[5] !== 1'b1) `nnc_error("ATM5",$sformatf("Enter ATM5 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b00101) `nnc_error("ATM5",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b00101",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM5",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== 1'b1) `nnc_error("ATM5",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_OSC8MHZEN)); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== 1'b1) `nnc_error("ATM5",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN));
    if(`ANA_TOP.D2A_EN_TSC !== 1'b1) `nnc_error("ATM5",$sformatf("D2A_EN_TSC error, Real data:%b not match 1'b1",`ANA_TOP.D2A_EN_TSC));
   `nnc_info("Checking ATM - Done", "Checking ATM5 Done", UVM_LOW);
    
    // ATM6 FIXED VALUE SESSION
    // Before ATM6 Mode
    // Chaging the fixed value
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);

    //Section 0: 0xC1 : Bit[0]:D2A_BIST_EN = 0, Bit[5:1]:D2A_BIST_SEL = 5'b11111
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {2'h0, 5'b11111, 1'b0} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //Section 0: 0xC2 : Bit[0]:D2A_OSC8MHZEN = 0, Bit[1]:D2A_BGBUFFER_CPTEST_EN = 1'b1
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_1; no_of_bytes == 1; data[0] == {8'h00} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    // Enter ATM MODE
    // Enter ATM6 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b00110;
    #100;
   `nnc_info("Checking ATM - Start", "Checking ATM6 Done", UVM_LOW);
    
    // Enter ATM6 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[6] !== 1'b1) `nnc_error("ATM6",$sformatf("Enter ATM6 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b00110) `nnc_error("ATM6",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b00110",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM6",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== 1'b1) `nnc_error("ATM6",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_OSC8MHZEN)); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== 1'b1) `nnc_error("ATM6",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN));
    if(`ANA_TOP.D2A_DRIVER_CUR_EN !== 1'b1) `nnc_error("ATM6",$sformatf("D2A_DRIVER_CUR_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_DRIVER_CUR_EN)); 
    if(`ANA_TOP.D2A_STIMU_EN !== 1'b1) `nnc_error("ATM6",$sformatf("D2A_STIMU_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_STIMU_EN));
   `nnc_info("Checking ATM - Done", "Checking ATM6 Done", UVM_LOW);
    
    // ATM7 FIXED VALUE SESSION
    // Before ATM7 Mode
    // Chaging the fixed value
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);

    //Section 0: 0xC1 : Bit[0]:D2A_BIST_EN = 0, Bit[5:1]:D2A_BIST_SEL = 5'b11111
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {2'h0, 5'b11111, 1'b0} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //Section 0: 0xC2 : Bit[0]:D2A_OSC8MHZEN = 0, Bit[1]:D2A_BGBUFFER_CPTEST_EN = 1'b1
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_1; no_of_bytes == 1; data[0] == {8'h00} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    // Enter ATM MODE
    // Enter ATM7 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b00111;
    #100;
   `nnc_info("Checking ATM - Start", "Checking ATM7 Done", UVM_LOW);
    
    // Enter ATM7 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[7] !== 1'b1) `nnc_error("ATM7",$sformatf("Enter ATM7 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b00111) `nnc_error("ATM7",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b00111",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM7",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== 1'b1) `nnc_error("ATM7",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_OSC8MHZEN)); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== 1'b1) `nnc_error("ATM7",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN));
   `nnc_info("Checking ATM - Done", "Checking ATM7 Done", UVM_LOW);
    
    // ATM8 FIXED VALUE SESSION
    // Before ATM8 Mode
    // Chaging the fixed value
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);

    //Section 0: 0xC1 : Bit[0]:D2A_BIST_EN = 0, Bit[5:1]:D2A_BIST_SEL = 5'b11111
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {2'h0, 5'b11111, 1'b0} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //Section 0: 0xC2 : Bit[0]:D2A_OSC8MHZEN = 0, Bit[1]:D2A_BGBUFFER_CPTEST_EN = 1'b1
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_1; no_of_bytes == 1; data[0] == {8'h00} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    // Enter ATM MODE
    // Enter ATM8 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b01000;
    #100;
   `nnc_info("Checking ATM - Start", "Checking ATM8 Done", UVM_LOW);
    
    // Enter ATM8 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[8] !== 1'b1) `nnc_error("ATM8",$sformatf("Enter ATM8 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b01000) `nnc_error("ATM8",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b01000",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM8",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== 1'b1) `nnc_error("ATM8",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_OSC8MHZEN)); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== 1'b1) `nnc_error("ATM8",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN));
   `nnc_info("Checking ATM - Done", "Checking ATM8 Done", UVM_LOW);
    
    // ATM9 FIXED VALUE SESSION
    // Before ATM9 Mode
    // Chaging the fixed value
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);

    //Section 0: 0xC1 : Bit[0]:D2A_BIST_EN = 0, Bit[5:1]:D2A_BIST_SEL = 5'b11111
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {2'h0, 5'b11111, 1'b0} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //Section 0: 0xC2 : Bit[0]:D2A_OSC8MHZEN = 0, Bit[1]:D2A_BGBUFFER_CPTEST_EN = 1'b1
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_1; no_of_bytes == 1; data[0] == {8'h00} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    // Enter ATM MODE
    // Enter ATM9 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b01001;
    #100;
   `nnc_info("Checking ATM - Start", "Checking ATM9 Done", UVM_LOW);
    
    // Enter ATM9 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[9] !== 1'b1) `nnc_error("ATM9",$sformatf("Enter ATM9 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b01001) `nnc_error("ATM9",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b01001",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM9",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== 1'b1) `nnc_error("ATM9",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_OSC8MHZEN)); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== 1'b1) `nnc_error("ATM9",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN));
   `nnc_info("Checking ATM - Done", "Checking ATM9 Done", UVM_LOW);
    
    // ATM10 FIXED VALUE SESSION
    // Before ATM10 Mode
    // Chaging the fixed value
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);

    //Section 0: 0xC1 : Bit[0]:D2A_BIST_EN = 0, Bit[5:1]:D2A_BIST_SEL = 5'b11111
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {2'h0, 5'b11111, 1'b0} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //Section 0: 0xC2 : Bit[0]:D2A_OSC8MHZEN = 0, Bit[1]:D2A_BGBUFFER_CPTEST_EN = 1'b1
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_1; no_of_bytes == 1; data[0] == {8'h00} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    // Enter ATM MODE
    // Enter ATM10 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b01010;
    #100;
   `nnc_info("Checking ATM - Start", "Checking ATM10 Done", UVM_LOW);
    
    // Enter ATM10 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[10] !== 1'b1) `nnc_error("ATM10",$sformatf("Enter ATM10 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b01010) `nnc_error("ATM10",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b01010",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM10",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== 1'b1) `nnc_error("ATM10",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_OSC8MHZEN)); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== 1'b1) `nnc_error("ATM10",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN));
   `nnc_info("Checking ATM - Done", "Checking ATM10 Done", UVM_LOW);
    
    // ATM11 FIXED VALUE SESSION
    // Before ATM11 Mode
    // Chaging the fixed value
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);

    //Section 0: 0xC1 : Bit[0]:D2A_BIST_EN = 0, Bit[5:1]:D2A_BIST_SEL = 5'b11111
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {2'h0, 5'b11111, 1'b0} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //Section 0: 0xC2 : Bit[0]:D2A_OSC8MHZEN = 0, Bit[1]:D2A_BGBUFFER_CPTEST_EN = 1'b1
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_1; no_of_bytes == 1; data[0] == {8'h00} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    // Enter ATM MODE
    // Enter ATM11 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b01011;
    #100;
   `nnc_info("Checking ATM - Start", "Checking ATM11 Done", UVM_LOW);
    
    // Enter ATM11 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[11] !== 1'b1) `nnc_error("ATM11",$sformatf("Enter ATM11 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b01011) `nnc_error("ATM11",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b01011",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM11",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== 1'b1) `nnc_error("ATM11",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_OSC8MHZEN)); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== 1'b1) `nnc_error("ATM11",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN));
   `nnc_info("Checking ATM - Done", "Checking ATM11 Done", UVM_LOW);
    
    // ATM12 FIXED VALUE SESSION
    // Before ATM12 Mode
    // Chaging the fixed value
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);

    //Section 0: 0xC1 : Bit[0]:D2A_BIST_EN = 0, Bit[5:1]:D2A_BIST_SEL = 5'b11111
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {2'h0, 5'b11111, 1'b0} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //Section 0: 0xC2 : Bit[0]:D2A_OSC8MHZEN = 0, Bit[1]:D2A_BGBUFFER_CPTEST_EN = 1'b1
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_1; no_of_bytes == 1; data[0] == {8'h00} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC3 : Bit[0]:D2A_SDMVREFPBUFF_EN = 0, Bit[1]:D2A_SDMVCMBUFF_EN = 1'b1, Bit[2]:D2A_VCMGENBUFF_EN = 1'b1, Bit[3]:D2A_RLD_ELECTRODE_EN = 1'b1
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_2; no_of_bytes == 1; data[0] == {8'h00} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC5 : Bit[7:0]:D2A_EEFLNA_EN = 0
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_4; no_of_bytes == 1; data[0] == {8'h00} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC6 : Bit[15:8]:D2A_EEFLNA_EN = 0
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_5; no_of_bytes == 1; data[0] == {8'h00} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC9 : Bit[7:0]:D2A_EEFPGA_EN = 0
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_8; no_of_bytes == 1; data[0] == {8'h00} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xCA : Bit[7:0]:D2A_EEFPGA_EN = 0
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_9; no_of_bytes == 1; data[0] == {8'h00} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 1\n", UVM_LOW);
    
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {8'h01} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC2 : Bit[7:0]:D2A_SDMEN_EN = 0
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_1; no_of_bytes == 1; data[0] == {8'h00} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC3 : Bit[15:8]:D2A_SDMEN_EN = 0
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_2; no_of_bytes == 1; data[0] == {8'h00} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC4 : Bit[7:0]:D2A_SDBUFF_EN = 0
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_3; no_of_bytes == 1; data[0] == {8'h00} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC5 : Bit[15:8]:D2A_SDBUFF_EN = 0
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_4; no_of_bytes == 1; data[0] == {8'h00} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);
    
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {8'h00} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    // Enter ATM MODE
    // Enter ATM12 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b01100;
    #100;
   `nnc_info("Checking ATM - Start", "Checking ATM12 Done", UVM_LOW);
    
    // Enter ATM12 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[12] !== 1'b1) `nnc_error("ATM12",$sformatf("Enter ATM12 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b01100) `nnc_error("ATM12",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b01100",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM12",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== 1'b1) `nnc_error("ATM12",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_OSC8MHZEN)); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== 1'b1) `nnc_error("ATM12",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN));
    if(`ANA_TOP.D2A_RLD_ELECTRODE_EN !== 1'b1) `nnc_error("ATM12",$sformatf("D2A_RLD_ELECTRODE_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_RLD_ELECTRODE_EN));
    if(`ANA_TOP.D2A_SDMVCMBUFF_EN !== 1'b1) `nnc_error("ATM12",$sformatf("D2A_SDMVCMBUFF_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_SDMVCMBUFF_EN));
    if(`ANA_TOP.D2A_SDMVREFPBUFF_EN !== 1'b1) `nnc_error("ATM12",$sformatf("D2A_SDMVREFPBUFF_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_SDMVREFPBUFF_EN));
    if(`ANA_TOP.D2A_SDMEN !== 16'h0100) `nnc_error("ATM12",$sformatf("D2A_SDMEN error, Real data:%4h not match 16'h0100",`ANA_TOP.D2A_SDMEN));

   `nnc_info("Checking ATM - Done", "Checking ATM12 Done", UVM_LOW);
    
    // ATM13 FIXED VALUE SESSION
    // Before ATM13 Mode
    // Chaging the fixed value
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);
 
    //Section 0: 0xC3 : Bit[0]:D2A_SDMVREFPBUFF_EN = 0, Bit[1]:D2A_SDMVCMBUFF_EN = 1'b1, Bit[2]:D2A_VCMGENBUFF_EN = 1'b1, Bit[3]:D2A_RLD_ELECTRODE_EN = 1'b1
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_2; no_of_bytes == 1; data[0] == {8'h00} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC1 : Bit[0]:D2A_BIST_EN = 0, Bit[5:1]:D2A_BIST_SEL = 5'b11111
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {2'h0, 5'b11111, 1'b0} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //Section 0: 0xC2 : Bit[0]:D2A_OSC8MHZEN = 0, Bit[1]:D2A_BGBUFFER_CPTEST_EN = 1'b1
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_1; no_of_bytes == 1; data[0] == {8'h01} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC3 : Bit[0]:D2A_SDMVREFPBUFF_EN = 0, Bit[1]:D2A_SDMVCMBUFF_EN = 1'b1, Bit[2]:D2A_VCMGENBUFF_EN = 1'b1, Bit[3]:D2A_RLD_ELECTRODE_EN = 1'b1
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_2; no_of_bytes == 1; data[0] == {8'h00} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC5 : Bit[7:0]:D2A_EEFLNA_EN = 0
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_4; no_of_bytes == 1; data[0] == {8'h00} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC6 : Bit[15:8]:D2A_EEFLNA_EN = 0
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_5; no_of_bytes == 1; data[0] == {8'h00} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC9 : Bit[7:0]:D2A_EEFPGA_EN = 0
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_8; no_of_bytes == 1; data[0] == {8'h00} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xCA : Bit[7:0]:D2A_EEFPGA_EN = 0
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_9; no_of_bytes == 1; data[0] == {8'h00} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 1\n", UVM_LOW);
    
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {8'h01} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC2 : Bit[7:0]:D2A_SDMEN_EN = 0
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_1; no_of_bytes == 1; data[0] == {8'h00} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC3 : Bit[15:8]:D2A_SDMEN_EN = 0
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_2; no_of_bytes == 1; data[0] == {8'h00} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC4 : Bit[7:0]:D2A_SDBUFF_EN = 0
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_3; no_of_bytes == 1; data[0] == {8'h00} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC5 : Bit[15:8]:D2A_SDBUFF_EN = 0
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_4; no_of_bytes == 1; data[0] == {8'h00} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);
    
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {8'h00} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    // Enter ATM MODE
    // Enter ATM13 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b01101;
    #100;
   `nnc_info("Checking ATM - Start", "Checking ATM13 Done", UVM_LOW);
    
    // Enter ATM13 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[13] !== 1'b1) `nnc_error("ATM13",$sformatf("Enter ATM13 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b01101) `nnc_error("ATM13",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b01101",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM13",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== 1'b1) `nnc_error("ATM13",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_OSC8MHZEN)); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== 1'b1) `nnc_error("ATM13",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN));
    if(`ANA_TOP.D2A_RLD_ELECTRODE_EN !== 1'b1) `nnc_error("ATM13",$sformatf("D2A_RLD_ELECTRODE_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_RLD_ELECTRODE_EN));
    if(`ANA_TOP.D2A_SDMVCMBUFF_EN !== 1'b1) `nnc_error("ATM13",$sformatf("D2A_SDMVCMBUFF_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_SDMVCMBUFF_EN));
    if(`ANA_TOP.D2A_SDMVREFPBUFF_EN !== 1'b1) `nnc_error("ATM13",$sformatf("D2A_SDMVREFPBUFF_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_SDMVREFPBUFF_EN));
    if(`ANA_TOP.D2A_SDMEN !== 16'h0100) `nnc_error("ATM13",$sformatf("D2A_SDMEN error, Real data:%4h not match 16'h0100",`ANA_TOP.D2A_SDMEN));
   `nnc_info("Checking ATM - Done", "Checking ATM13 Done", UVM_LOW);
    
    // ATM14 FIXED VALUE SESSION
    // Before ATM14 Mode
    // Chaging the fixed value
/*    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);

    //Section 0: 0xC1 : Bit[0]:D2A_BIST_EN = 0, Bit[5:1]:D2A_BIST_SEL = 5'b11111
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {2'h0, 5'b11111, 1'b0} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //Section 0: 0xC2 : Bit[0]:D2A_OSC8MHZEN = 0, Bit[1]:D2A_BGBUFFER_CPTEST_EN = 1'b1
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_1; no_of_bytes == 1; data[0] == {8'h01} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC3 : Bit[0]:D2A_SDMVREFPBUFF_EN = 0, Bit[1]:D2A_SDMVCMBUFF_EN = 1'b1, Bit[2]:D2A_VCMGENBUFF_EN = 1'b1, Bit[3]:D2A_RLD_ELECTRODE_EN = 1'b1
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_2; no_of_bytes == 1; data[0] == {8'h00} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC5 : Bit[7:0]:D2A_EEFLNA_EN = 0
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_4; no_of_bytes == 1; data[0] == {8'h00} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC6 : Bit[15:8]:D2A_EEFLNA_EN = 0
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_5; no_of_bytes == 1; data[0] == {8'h00} ;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC9 : Bit[7:0]:D2A_EEFPGA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_8; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xCA : Bit[7:0]:D2A_EEFPGA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_9; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 1\n", UVM_LOW);
    
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {8'h01} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC2 : Bit[7:0]:D2A_SDMEN_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_1; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC3 : Bit[15:8]:D2A_SDMEN_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_2; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC4 : Bit[7:0]:D2A_SDBUFF_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_3; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC5 : Bit[15:8]:D2A_SDBUFF_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_4; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);
    
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
*/    
    // Enter ATM MODE
    // Enter ATM14 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b01110;
    #100;
   `nnc_info("Checking ATM - Start", "Checking ATM14 Done", UVM_LOW);
    
    // Enter ATM14 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[14] !== 1'b1) `nnc_error("ATM14",$sformatf("Enter ATM14 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b01110) `nnc_error("ATM14",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b01110",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM14",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== 1'b1) `nnc_error("ATM14",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_OSC8MHZEN)); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== 1'b1) `nnc_error("ATM14",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN));
    if(`ANA_TOP.D2A_RLD_ELECTRODE_EN !== 1'b1) `nnc_error("ATM14",$sformatf("D2A_RLD_ELECTRODE_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_RLD_ELECTRODE_EN));
    if(`ANA_TOP.D2A_SDMVCMBUFF_EN !== 1'b1) `nnc_error("ATM14",$sformatf("D2A_SDMVCMBUFF_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_SDMVCMBUFF_EN));
    if(`ANA_TOP.D2A_SDMVREFPBUFF_EN !== 1'b1) `nnc_error("ATM14",$sformatf("D2A_SDMVREFPBUFF_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_SDMVREFPBUFF_EN));
    if(`ANA_TOP.D2A_SDMEN !== 16'h0100) `nnc_error("ATM14",$sformatf("D2A_SDMEN error, Real data:%4h not match 16'h0100",`ANA_TOP.D2A_SDMEN));
   `nnc_info("Checking ATM - Done", "Checking ATM14 Done", UVM_LOW);
    
    // ATM15 FIXED VALUE SESSION
    // Before ATM15 Mode
    // Chaging the fixed value
/*    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);

    //Section 0: 0xC1 : Bit[0]:D2A_BIST_EN = 0, Bit[5:1]:D2A_BIST_SEL = 5'b11111
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {2'h0, 5'b11111, 1'b0} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //Section 0: 0xC2 : Bit[0]:D2A_OSC8MHZEN = 0, Bit[1]:D2A_BGBUFFER_CPTEST_EN = 1'b1
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_1; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //0x6C : Bit[0]:TSC_EN_CH1 = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_TSC_CTRL_REG; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
*/    
    // Enter ATM MODE
    // Enter ATM15 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b01111;
    #100;
   `nnc_info("Checking ATM - Start", "Checking ATM15 Done", UVM_LOW);
    
    // Enter ATM15 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[0] !== 1'b1) `nnc_error("ATM15",$sformatf("Enter ATM15 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b01111) `nnc_error("ATM15",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b01111",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM15",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== 1'b1) `nnc_error("ATM15",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_OSC8MHZEN)); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== 1'b1) `nnc_error("ATM15",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN));
    if(`ANA_TOP.D2A_EN_TSC !== 1'b1) `nnc_error("ATM15",$sformatf("D2A_EN_TSC error, Real data:%b not match 1'b1",`ANA_TOP.D2A_EN_TSC));
   `nnc_info("Checking ATM - Done", "Checking ATM15 Done", UVM_LOW);
    
    // ATM16 FIXED VALUE SESSION
    // Before ATM16 Mode
    // Chaging the fixed value
/*    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);

    //Section 0: 0xC1 : Bit[0]:D2A_BIST_EN = 0, Bit[5:1]:D2A_BIST_SEL = 5'b11111
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {2'h0, 5'b11111, 1'b0} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //Section 0: 0xC2 : Bit[0]:D2A_OSC8MHZEN = 0, Bit[1]:D2A_BGBUFFER_CPTEST_EN = 1'b1
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_1; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //0x6C : Bit[0]:TSC_EN_CH1 = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_TSC_CTRL_REG; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
*/    
    // Enter ATM MODE
    // Enter ATM16 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b10000;
    #100;
   `nnc_info("Checking ATM - Start", "Checking ATM16 Done", UVM_LOW);
    
    // Enter ATM16 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[1] !== 1'b1) `nnc_error("ATM16",$sformatf("Enter ATM16 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b10000) `nnc_error("ATM16",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b10000",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM16",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== 1'b1) `nnc_error("ATM16",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_OSC8MHZEN)); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== 1'b1) `nnc_error("ATM16",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN));
    if(`ANA_TOP.D2A_DCLOFFEN !== 16'h0100) `nnc_error("ATM16",$sformatf("D2A_DCLOFFEN error, Real data:%b not match 16'h0100",`ANA_TOP.D2A_DCLOFFEN));
   `nnc_info("Checking ATM - Done", "Checking ATM16 Done", UVM_LOW);
    
    // ATM17 FIXED VALUE SESSION
    // Before ATM17 Mode
    // Chaging the fixed value
/*    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);

    //Section 0: 0xC1 : Bit[0]:D2A_BIST_EN = 0, Bit[5:1]:D2A_BIST_SEL = 5'b11111
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {2'h0, 5'b11111, 1'b0} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //Section 0: 0xC2 : Bit[0]:D2A_OSC8MHZEN = 0, Bit[1]:D2A_BGBUFFER_CPTEST_EN = 1'b1
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_1; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //0x6C : Bit[0]:TSC_EN_CH1 = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_TSC_CTRL_REG; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
*/    
    // Enter ATM MODE
    // Enter ATM17 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b10001;
    #100;
   `nnc_info("Checking ATM - Start", "Checking ATM17 Done", UVM_LOW);
    
    // Enter ATM17 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[2] !== 1'b1) `nnc_error("ATM17",$sformatf("Enter ATM17 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b10001) `nnc_error("ATM17",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b10001",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM17",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== 1'b1) `nnc_error("ATM17",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_OSC8MHZEN)); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== 1'b1) `nnc_error("ATM17",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN));
    if(`ANA_TOP.D2A_DCLOFFEN !== 16'h0100) `nnc_error("ATM17",$sformatf("D2A_DCLOFFEN error, Real data:%b not match 16'h0100",`ANA_TOP.D2A_DCLOFFEN));
   `nnc_info("Checking ATM - Done", "Checking ATM17 Done", UVM_LOW);
    
    // ATM18 FIXED VALUE SESSION
    // Before ATM18 Mode
    // Chaging the fixed value
/*    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);

    //Section 0: 0xC1 : Bit[0]:D2A_BIST_EN = 0, Bit[5:1]:D2A_BIST_SEL = 5'b11111
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {2'h0, 5'b11111, 1'b0} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //Section 0: 0xC2 : Bit[0]:D2A_OSC8MHZEN = 0, Bit[1]:D2A_BGBUFFER_CPTEST_EN = 1'b1
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_1; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //0x6C : Bit[0]:TSC_EN_CH1 = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_TSC_CTRL_REG; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
*/    
    // Enter ATM MODE
    // Enter ATM18 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b10010;
    #100;
   `nnc_info("Checking ATM - Start", "Checking ATM18 Done", UVM_LOW);
    
    // Enter ATM18 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[3] !== 1'b1) `nnc_error("ATM18",$sformatf("Enter ATM18 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b10010) `nnc_error("ATM18",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b10010",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM18",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== 1'b1) `nnc_error("ATM18",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_OSC8MHZEN)); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== 1'b1) `nnc_error("ATM18",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN));
    if(`ANA_TOP.D2A_NIRS4_EN !== 1'b1) `nnc_error("ATM18",$sformatf("D2A_NIRS4_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_NIRS4_EN));
    if(`ANA_TOP.D2A_NIRS_TEST_EN !== 1'b1) `nnc_error("ATM18",$sformatf("D2A_NIRS_TEST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_NIRS_TEST_EN));
   `nnc_info("Checking ATM - Done", "Checking ATM18 Done", UVM_LOW);
    
    // ATM19 FIXED VALUE SESSION
    // Before ATM19 Mode
    // Chaging the fixed value
/*    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);

    //Section 0: 0xC1 : Bit[0]:D2A_BIST_EN = 0, Bit[5:1]:D2A_BIST_SEL = 5'b11111
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {2'h0, 5'b11111, 1'b0} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //Section 0: 0xC2 : Bit[0]:D2A_OSC8MHZEN = 0, Bit[1]:D2A_BGBUFFER_CPTEST_EN = 1'b1
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_1; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //0x6C : Bit[0]:TSC_EN_CH1 = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_TSC_CTRL_REG; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
*/    
    // Enter ATM MODE
    // Enter ATM19 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b10011;
    #100;
   `nnc_info("Checking ATM - Start", "Checking ATM19 Done", UVM_LOW);
    
    // Enter ATM19 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[4] !== 1'b1) `nnc_error("ATM19",$sformatf("Enter ATM19 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b10011) `nnc_error("ATM19",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b10011",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM19",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== 1'b1) `nnc_error("ATM19",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_OSC8MHZEN)); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== 1'b1) `nnc_error("ATM19",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN));
    if(`ANA_TOP.D2A_NIRS4_EN !== 1'b1) `nnc_error("ATM19",$sformatf("D2A_NIRS4_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_NIRS4_EN));
    if(`ANA_TOP.D2A_NIRS_TEST_EN !== 1'b1) `nnc_error("ATM19",$sformatf("D2A_NIRS_TEST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_NIRS_TEST_EN));
   `nnc_info("Checking ATM - Done", "Checking ATM19 Done", UVM_LOW);
    
    // ATM20 FIXED VALUE SESSION
    // Before ATM20 Mode
    // Chaging the fixed value
/*    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);

    //Section 0: 0xC1 : Bit[0]:D2A_BIST_EN = 0, Bit[5:1]:D2A_BIST_SEL = 5'b11111
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {2'h0, 5'b11111, 1'b0} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //Section 0: 0xC2 : Bit[0]:D2A_OSC8MHZEN = 0, Bit[1]:D2A_BGBUFFER_CPTEST_EN = 1'b1
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_1; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //0x6C : Bit[0]:TSC_EN_CH1 = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_TSC_CTRL_REG; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
*/    
    // Enter ATM MODE
    // Enter ATM20 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b10100;
    #100;
   `nnc_info("Checking ATM - Start", "Checking ATM20 Done", UVM_LOW);
    
    // Enter ATM20 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[5] !== 1'b1) `nnc_error("ATM20",$sformatf("Enter ATM20 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b10100) `nnc_error("ATM20",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b10100",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM20",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== 1'b1) `nnc_error("ATM20",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_OSC8MHZEN)); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== 1'b1) `nnc_error("ATM20",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN));
    if(`ANA_TOP.D2A_NIRS4_EN !== 1'b1) `nnc_error("ATM20",$sformatf("D2A_NIRS4_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_NIRS4_EN));
    if(`ANA_TOP.D2A_NIRS4_IDAC_EN !== 1'b1) `nnc_error("ATM20",$sformatf("D2A_NIRS4_IDAC_EN error, Real data:%b not match 1'b0",`ANA_TOP.D2A_NIRS4_IDAC_EN));
    if(`ANA_TOP.D2A_NIRS_TEST_EN !== 1'b1) `nnc_error("ATM20",$sformatf("D2A_NIRS_TEST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_NIRS_TEST_EN));
   `nnc_info("Checking ATM - Done", "Checking ATM20 Done", UVM_LOW);
    
    // ATM21 FIXED VALUE SESSION
    // Before ATM21 Mode
    // Chaging the fixed value
/*    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);

    //Section 0: 0xC1 : Bit[0]:D2A_BIST_EN = 0, Bit[5:1]:D2A_BIST_SEL = 5'b11111
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {2'h0, 5'b11111, 1'b0} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //Section 0: 0xC2 : Bit[0]:D2A_OSC8MHZEN = 0, Bit[1]:D2A_BGBUFFER_CPTEST_EN = 1'b1
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_1; no_of_bytes == 1; data[0] == {8'h01} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC3 : Bit[0]:D2A_SDMVREFPBUFF_EN = 0, Bit[1]:D2A_SDMVCMBUFF_EN = 1'b1, Bit[2]:D2A_VCMGENBUFF_EN = 1'b1, Bit[3]:D2A_RLD_ELECTRODE_EN = 1'b1
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_2; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC5 : Bit[7:0]:D2A_EEFLNA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_4; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC6 : Bit[15:8]:D2A_EEFLNA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_5; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC9 : Bit[7:0]:D2A_EEFPGA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_8; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xCA : Bit[7:0]:D2A_EEFPGA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_9; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 1\n", UVM_LOW);
    
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {8'h01} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC2 : Bit[7:0]:D2A_SDMEN_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_1; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC3 : Bit[15:8]:D2A_SDMEN_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_2; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC4 : Bit[7:0]:D2A_SDBUFF_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_3; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC5 : Bit[15:8]:D2A_SDBUFF_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_4; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);
    
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
*/    
    // Enter ATM MODE
    // Enter ATM21 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b10101;
    #100;
   `nnc_info("Checking ATM - Start", "Checking ATM21 Done", UVM_LOW);
    
    // Enter ATM21 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[6] !== 1'b1) `nnc_error("ATM21",$sformatf("Enter ATM21 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b10101) `nnc_error("ATM21",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b10101",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM21",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== 1'b1) `nnc_error("ATM21",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_OSC8MHZEN)); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== 1'b1) `nnc_error("ATM21",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN));
    if(`ANA_TOP.D2A_RLD_ELECTRODE_EN !== 1'b1) `nnc_error("ATM21",$sformatf("D2A_RLD_ELECTRODE_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_RLD_ELECTRODE_EN));
    if(`ANA_TOP.D2A_SDMVCMBUFF_EN !== 1'b1) `nnc_error("ATM21",$sformatf("D2A_SDMVCMBUFF_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_SDMVCMBUFF_EN));
    if(`ANA_TOP.D2A_SDMVREFPBUFF_EN !== 1'b1) `nnc_error("ATM21",$sformatf("D2A_SDMVREFPBUFF_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_SDMVREFPBUFF_EN));
    if(`ANA_TOP.D2A_SDMEN !== 16'h0100) `nnc_error("ATM21",$sformatf("D2A_SDMEN error, Real data:%4h not match 16'h0100",`ANA_TOP.D2A_SDMEN));
   `nnc_info("Checking ATM - Done", "Checking ATM21 Done", UVM_LOW);
    
    // ATM22 FIXED VALUE SESSION
    // Before ATM22 Mode
    // Chaging the fixed value
/*    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);

    //Section 0: 0xC1 : Bit[0]:D2A_BIST_EN = 0, Bit[5:1]:D2A_BIST_SEL = 5'b11111
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {2'h0, 5'b11111, 1'b0} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //Section 0: 0xC2 : Bit[0]:D2A_OSC8MHZEN = 0, Bit[1]:D2A_BGBUFFER_CPTEST_EN = 1'b1
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_1; no_of_bytes == 1; data[0] == {8'h01} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC3 : Bit[0]:D2A_SDMVREFPBUFF_EN = 0, Bit[1]:D2A_SDMVCMBUFF_EN = 1'b1, Bit[2]:D2A_VCMGENBUFF_EN = 1'b1, Bit[3]:D2A_RLD_ELECTRODE_EN = 1'b1
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_2; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC5 : Bit[7:0]:D2A_EEFLNA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_4; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC6 : Bit[15:8]:D2A_EEFLNA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_5; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC9 : Bit[7:0]:D2A_EEFPGA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_8; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xCA : Bit[7:0]:D2A_EEFPGA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_9; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 1\n", UVM_LOW);
    
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {8'h01} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC2 : Bit[7:0]:D2A_SDMEN_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_1; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC3 : Bit[15:8]:D2A_SDMEN_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_2; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC4 : Bit[7:0]:D2A_SDBUFF_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_3; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC5 : Bit[15:8]:D2A_SDBUFF_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_4; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);
    
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
*/    
    // Enter ATM MODE
    // Enter ATM22 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b10110;
    #100;
   `nnc_info("Checking ATM - Start", "Checking ATM22 Done", UVM_LOW);
    
    // Enter ATM22 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[7] !== 1'b1) `nnc_error("ATM22",$sformatf("Enter ATM22 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b10110) `nnc_error("ATM22",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b10110",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM22",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== 1'b1) `nnc_error("ATM22",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_OSC8MHZEN)); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== 1'b1) `nnc_error("ATM22",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN));
    if(`ANA_TOP.D2A_RLD_ELECTRODE_EN !== 1'b1) `nnc_error("ATM22",$sformatf("D2A_RLD_ELECTRODE_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_RLD_ELECTRODE_EN));
    if(`ANA_TOP.D2A_SDMVCMBUFF_EN !== 1'b1) `nnc_error("ATM22",$sformatf("D2A_SDMVCMBUFF_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_SDMVCMBUFF_EN));
    if(`ANA_TOP.D2A_SDMVREFPBUFF_EN !== 1'b1) `nnc_error("ATM22",$sformatf("D2A_SDMVREFPBUFF_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_SDMVREFPBUFF_EN));
    if(`ANA_TOP.D2A_SDMEN !== 16'h0100) `nnc_error("ATM22",$sformatf("D2A_SDMEN error, Real data:%4h not match 16'h0100",`ANA_TOP.D2A_SDMEN));
   `nnc_info("Checking ATM - Done", "Checking ATM22 Done", UVM_LOW);
    
    // ATM23 FIXED VALUE SESSION
    // Before ATM23 Mode
    // Chaging the fixed value
/*    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);

    //Section 0: 0xC1 : Bit[0]:D2A_BIST_EN = 0, Bit[5:1]:D2A_BIST_SEL = 5'b11111
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {2'h0, 5'b11111, 1'b0} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //Section 0: 0xC2 : Bit[0]:D2A_OSC8MHZEN = 0, Bit[1]:D2A_BGBUFFER_CPTEST_EN = 1'b1
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_1; no_of_bytes == 1; data[0] == {8'h01} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC3 : Bit[0]:D2A_SDMVREFPBUFF_EN = 0, Bit[1]:D2A_SDMVCMBUFF_EN = 1'b1, Bit[2]:D2A_VCMGENBUFF_EN = 1'b1, Bit[3]:D2A_RLD_ELECTRODE_EN = 1'b1
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_2; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC5 : Bit[7:0]:D2A_EEFLNA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_4; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC6 : Bit[15:8]:D2A_EEFLNA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_5; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC9 : Bit[7:0]:D2A_EEFPGA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_8; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xCA : Bit[7:0]:D2A_EEFPGA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_9; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 1\n", UVM_LOW);
    
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {8'h01} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC2 : Bit[7:0]:D2A_SDMEN_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_1; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC3 : Bit[15:8]:D2A_SDMEN_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_2; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC4 : Bit[7:0]:D2A_SDBUFF_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_3; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC5 : Bit[15:8]:D2A_SDBUFF_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_4; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);
    
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
*/    
    // Enter ATM MODE
    // Enter ATM23 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b10111;
    #100;
   `nnc_info("Checking ATM - Start", "Checking ATM23 Done", UVM_LOW);
    
    // Enter ATM23 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[8] !== 1'b1) `nnc_error("ATM23",$sformatf("Enter ATM23 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b10111) `nnc_error("ATM23",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b10111",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM23",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== 1'b1) `nnc_error("ATM23",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_OSC8MHZEN)); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== 1'b1) `nnc_error("ATM23",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN));
    if(`ANA_TOP.D2A_RLD_ELECTRODE_EN !== 1'b1) `nnc_error("ATM23",$sformatf("D2A_RLD_ELECTRODE_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_RLD_ELECTRODE_EN));
    if(`ANA_TOP.D2A_SDMVCMBUFF_EN !== 1'b1) `nnc_error("ATM23",$sformatf("D2A_SDMVCMBUFF_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_SDMVCMBUFF_EN));
    if(`ANA_TOP.D2A_SDMVREFPBUFF_EN !== 1'b1) `nnc_error("ATM23",$sformatf("D2A_SDMVREFPBUFF_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_SDMVREFPBUFF_EN));
    if(`ANA_TOP.D2A_SDMEN !== 16'h0100) `nnc_error("ATM23",$sformatf("D2A_SDMEN error, Real data:%4h not match 16'h0100",`ANA_TOP.D2A_SDMEN));
   `nnc_info("Checking ATM - Done", "Checking ATM23 Done", UVM_LOW);
    
    // ATM24 FIXED VALUE SESSION
    // Before ATM24 Mode
    // Chaging the fixed value
/*    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);

    //Section 0: 0xC1 : Bit[0]:D2A_BIST_EN = 0, Bit[5:1]:D2A_BIST_SEL = 5'b11111
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {2'h0, 5'b11111, 1'b0} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //Section 0: 0xC2 : Bit[0]:D2A_OSC8MHZEN = 0, Bit[1]:D2A_BGBUFFER_CPTEST_EN = 1'b1
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_1; no_of_bytes == 1; data[0] == {8'h01} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC3 : Bit[0]:D2A_SDMVREFPBUFF_EN = 0, Bit[1]:D2A_SDMVCMBUFF_EN = 1'b1, Bit[2]:D2A_VCMGENBUFF_EN = 1'b1, Bit[3]:D2A_RLD_ELECTRODE_EN = 1'b1
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_2; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC5 : Bit[7:0]:D2A_EEFLNA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_4; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC6 : Bit[15:8]:D2A_EEFLNA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_5; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC9 : Bit[7:0]:D2A_EEFPGA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_8; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xCA : Bit[7:0]:D2A_EEFPGA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_9; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 1\n", UVM_LOW);
    
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {8'h01} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC2 : Bit[7:0]:D2A_SDMEN_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_1; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC3 : Bit[15:8]:D2A_SDMEN_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_2; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC4 : Bit[7:0]:D2A_SDBUFF_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_3; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC5 : Bit[15:8]:D2A_SDBUFF_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_4; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);
    
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
*/    
    // Enter ATM MODE
    // Enter ATM24 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b11000;
    #100;
   `nnc_info("Checking ATM - Start", "Checking ATM24 Done", UVM_LOW);
    
    // Enter ATM24 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[9] !== 1'b1) `nnc_error("ATM24",$sformatf("Enter ATM24 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b11000) `nnc_error("ATM24",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b11000",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM24",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== 1'b1) `nnc_error("ATM24",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_OSC8MHZEN)); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== 1'b1) `nnc_error("ATM24",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN));
    if(`ANA_TOP.D2A_RLD_ELECTRODE_EN !== 1'b1) `nnc_error("ATM24",$sformatf("D2A_RLD_ELECTRODE_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_RLD_ELECTRODE_EN));
    if(`ANA_TOP.D2A_SDMVREFPBUFF_EN !== 1'b1) `nnc_error("ATM24",$sformatf("D2A_SDMVREFPBUFF_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_SDMVREFPBUFF_EN));
    if(`ANA_TOP.D2A_SDMEN !== 16'h0100) `nnc_error("ATM24",$sformatf("D2A_SDMEN error, Real data:%4h not match 16'h0100",`ANA_TOP.D2A_SDMEN));
   `nnc_info("Checking ATM - Done", "Checking ATM24 Done", UVM_LOW);
    
    // ATM25 FIXED VALUE SESSION
    // Before ATM25 Mode
    // Chaging the fixed value
/*    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);

    //Section 0: 0xC1 : Bit[0]:D2A_BIST_EN = 0, Bit[5:1]:D2A_BIST_SEL = 5'b11111
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {2'h0, 5'b11111, 1'b0} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //Section 0: 0xC2 : Bit[0]:D2A_OSC8MHZEN = 0, Bit[1]:D2A_BGBUFFER_CPTEST_EN = 1'b1
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_1; no_of_bytes == 1; data[0] == {8'h01} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC3 : Bit[0]:D2A_SDMVREFPBUFF_EN = 0, Bit[1]:D2A_SDMVCMBUFF_EN = 1'b1, Bit[2]:D2A_VCMGENBUFF_EN = 1'b1, Bit[3]:D2A_RLD_ELECTRODE_EN = 1'b1
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_2; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC5 : Bit[7:0]:D2A_EEFLNA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_4; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC6 : Bit[15:8]:D2A_EEFLNA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_5; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC9 : Bit[7:0]:D2A_EEFPGA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_8; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xCA : Bit[7:0]:D2A_EEFPGA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_9; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 1\n", UVM_LOW);
    
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {8'h01} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC2 : Bit[7:0]:D2A_SDMEN_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_1; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC3 : Bit[15:8]:D2A_SDMEN_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_2; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC4 : Bit[7:0]:D2A_SDBUFF_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_3; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC5 : Bit[15:8]:D2A_SDBUFF_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_4; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);
    
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
*/    
    // Enter ATM MODE
    // Enter ATM25 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b11001;
    #100;
   `nnc_info("Checking ATM - Start", "Checking ATM25 Done", UVM_LOW);
    
    // Enter ATM25 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[10] !== 1'b1) `nnc_error("ATM25",$sformatf("Enter ATM25 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b11001) `nnc_error("ATM25",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b11001",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM25",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== 1'b1) `nnc_error("ATM25",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_OSC8MHZEN)); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== 1'b1) `nnc_error("ATM25",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN));
    if(`ANA_TOP.D2A_RLD_ELECTRODE_EN !== 1'b1) `nnc_error("ATM25",$sformatf("D2A_RLD_ELECTRODE_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_RLD_ELECTRODE_EN));
    if(`ANA_TOP.D2A_SDMVCMBUFF_EN !== 1'b1) `nnc_error("ATM25",$sformatf("D2A_SDMVCMBUFF_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_SDMVCMBUFF_EN));
    if(`ANA_TOP.D2A_SDMVREFPBUFF_EN !== 1'b1) `nnc_error("ATM25",$sformatf("D2A_SDMVREFPBUFF_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_SDMVREFPBUFF_EN));
    if(`ANA_TOP.D2A_SDMEN !== 16'h0100) `nnc_error("ATM25",$sformatf("D2A_SDMEN error, Real data:%4h not match 16'h0100",`ANA_TOP.D2A_SDMEN));
   `nnc_info("Checking ATM - Done", "Checking ATM25 Done", UVM_LOW);
    
    // ATM26 FIXED VALUE SESSION
    // Before ATM26 Mode
    // Chaging the fixed value
/*    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);

    //Section 0: 0xC1 : Bit[0]:D2A_BIST_EN = 0, Bit[5:1]:D2A_BIST_SEL = 5'b11111
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {2'h0, 5'b11111, 1'b0} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //Section 0: 0xC2 : Bit[0]:D2A_OSC8MHZEN = 0, Bit[1]:D2A_BGBUFFER_CPTEST_EN = 1'b1
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_1; no_of_bytes == 1; data[0] == {8'h01} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC3 : Bit[0]:D2A_SDMVREFPBUFF_EN = 0, Bit[1]:D2A_SDMVCMBUFF_EN = 1'b1, Bit[2]:D2A_VCMGENBUFF_EN = 1'b1, Bit[3]:D2A_RLD_ELECTRODE_EN = 1'b1
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_2; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC5 : Bit[7:0]:D2A_EEFLNA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_4; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC6 : Bit[15:8]:D2A_EEFLNA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_5; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC9 : Bit[7:0]:D2A_EEFPGA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_8; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xCA : Bit[7:0]:D2A_EEFPGA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_9; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 1\n", UVM_LOW);
    
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {8'h01} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC2 : Bit[7:0]:D2A_SDMEN_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_1; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC3 : Bit[15:8]:D2A_SDMEN_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_2; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC4 : Bit[7:0]:D2A_SDBUFF_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_3; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC5 : Bit[15:8]:D2A_SDBUFF_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_4; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);
    
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
*/    
    // Enter ATM MODE
    // Enter ATM26 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b11010;
    #100;
   `nnc_info("Checking ATM - Start", "Checking ATM26 Done", UVM_LOW);
    
    // Enter ATM26 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[11] !== 1'b1) `nnc_error("ATM26",$sformatf("Enter ATM26 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b11010) `nnc_error("ATM26",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b11010",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM26",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== 1'b1) `nnc_error("ATM26",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_OSC8MHZEN)); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== 1'b1) `nnc_error("ATM26",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN));
    if(`ANA_TOP.D2A_RLD_ELECTRODE_EN !== 1'b1) `nnc_error("ATM26",$sformatf("D2A_RLD_ELECTRODE_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_RLD_ELECTRODE_EN));
    if(`ANA_TOP.D2A_SDMVCMBUFF_EN !== 1'b1) `nnc_error("ATM26",$sformatf("D2A_SDMVCMBUFF_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_SDMVCMBUFF_EN));
    if(`ANA_TOP.D2A_SDMVREFPBUFF_EN !== 1'b1) `nnc_error("ATM26",$sformatf("D2A_SDMVREFPBUFF_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_SDMVREFPBUFF_EN));
    if(`ANA_TOP.D2A_SDMEN !== 16'h0100) `nnc_error("ATM26",$sformatf("D2A_SDMEN error, Real data:%4h not match 16'h0100",`ANA_TOP.D2A_SDMEN));
   `nnc_info("Checking ATM - Done", "Checking ATM26 Done", UVM_LOW);
    
    // ATM27 FIXED VALUE SESSION
    // Before ATM27 Mode
    // Chaging the fixed value
/*    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);

    //Section 0: 0xC1 : Bit[0]:D2A_BIST_EN = 0, Bit[5:1]:D2A_BIST_SEL = 5'b11111
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {2'h0, 5'b11111, 1'b0} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //Section 0: 0xC2 : Bit[0]:D2A_OSC8MHZEN = 0, Bit[1]:D2A_BGBUFFER_CPTEST_EN = 1'b1
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_1; no_of_bytes == 1; data[0] == {8'h01} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC3 : Bit[0]:D2A_SDMVREFPBUFF_EN = 0, Bit[1]:D2A_SDMVCMBUFF_EN = 1'b1, Bit[2]:D2A_VCMGENBUFF_EN = 1'b1, Bit[3]:D2A_RLD_ELECTRODE_EN = 1'b1
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_2; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC5 : Bit[7:0]:D2A_EEFLNA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_4; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC6 : Bit[15:8]:D2A_EEFLNA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_5; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC9 : Bit[7:0]:D2A_EEFPGA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_8; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xCA : Bit[7:0]:D2A_EEFPGA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_9; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 1\n", UVM_LOW);
    
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {8'h01} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC2 : Bit[7:0]:D2A_SDMEN_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_1; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC3 : Bit[15:8]:D2A_SDMEN_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_2; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC4 : Bit[7:0]:D2A_SDBUFF_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_3; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC5 : Bit[15:8]:D2A_SDBUFF_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_4; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);
    
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
*/    
    // Enter ATM MODE
    // Enter ATM27 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b11011;
    #100;
   `nnc_info("Checking ATM - Start", "Checking ATM27 Done", UVM_LOW);
    
    // Enter ATM27 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[12] !== 1'b1) `nnc_error("ATM27",$sformatf("Enter ATM27 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b11011) `nnc_error("ATM27",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b11011",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM27",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== 1'b1) `nnc_error("ATM27",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_OSC8MHZEN)); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== 1'b1) `nnc_error("ATM27",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN));
    if(`ANA_TOP.D2A_RLD_ELECTRODE_EN !== 1'b1) `nnc_error("ATM27",$sformatf("D2A_RLD_ELECTRODE_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_RLD_ELECTRODE_EN));
    if(`ANA_TOP.D2A_SDMVCMBUFF_EN !== 1'b1) `nnc_error("ATM27",$sformatf("D2A_SDMVCMBUFF_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_SDMVCMBUFF_EN));
    if(`ANA_TOP.D2A_SDMVREFPBUFF_EN !== 1'b1) `nnc_error("ATM27",$sformatf("D2A_SDMVREFPBUFF_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_SDMVREFPBUFF_EN));
    if(`ANA_TOP.D2A_SDMEN !== 16'h0100) `nnc_error("ATM27",$sformatf("D2A_SDMEN error, Real data:%4h not match 16'h0100",`ANA_TOP.D2A_SDMEN));
   `nnc_info("Checking ATM - Done", "Checking ATM27 Done", UVM_LOW);
    
    // ATM28 FIXED VALUE SESSION
    // Before ATM28 Mode
    // Chaging the fixed value
/*    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);

    //Section 0: 0xC1 : Bit[0]:D2A_BIST_EN = 0, Bit[5:1]:D2A_BIST_SEL = 5'b11111
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {2'h0, 5'b11111, 1'b0} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //Section 0: 0xC2 : Bit[0]:D2A_OSC8MHZEN = 0, Bit[1]:D2A_BGBUFFER_CPTEST_EN = 1'b1
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_1; no_of_bytes == 1; data[0] == {8'h01} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC3 : Bit[0]:D2A_SDMVREFPBUFF_EN = 0, Bit[1]:D2A_SDMVCMBUFF_EN = 1'b1, Bit[2]:D2A_VCMGENBUFF_EN = 1'b1, Bit[3]:D2A_RLD_ELECTRODE_EN = 1'b1
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_2; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC5 : Bit[7:0]:D2A_EEFLNA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_4; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC6 : Bit[15:8]:D2A_EEFLNA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_5; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC9 : Bit[7:0]:D2A_EEFPGA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_8; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xCA : Bit[7:0]:D2A_EEFPGA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_9; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 1\n", UVM_LOW);
    
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {8'h01} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC2 : Bit[7:0]:D2A_SDMEN_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_1; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC3 : Bit[15:8]:D2A_SDMEN_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_2; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC4 : Bit[7:0]:D2A_SDBUFF_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_3; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 1: 0xC5 : Bit[15:8]:D2A_SDBUFF_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_4; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);
    
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
*/    
    // Enter ATM MODE
    // Enter ATM28 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b11100;
    #100;
   `nnc_info("Checking ATM - Start", "Checking ATM28 Done", UVM_LOW);
    
    // Enter ATM28 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[13] !== 1'b1) `nnc_error("ATM28",$sformatf("Enter ATM28 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b11100) `nnc_error("ATM28",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b11100",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM28",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== 1'b1) `nnc_error("ATM28",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_OSC8MHZEN)); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== 1'b1) `nnc_error("ATM28",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN));
    if(`ANA_TOP.D2A_RLD_ELECTRODE_EN !== 1'b1) `nnc_error("ATM28",$sformatf("D2A_RLD_ELECTRODE_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_RLD_ELECTRODE_EN));
    if(`ANA_TOP.D2A_SDMVCMBUFF_EN !== 1'b1) `nnc_error("ATM28",$sformatf("D2A_SDMVCMBUFF_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_SDMVCMBUFF_EN));
    if(`ANA_TOP.D2A_SDMVREFPBUFF_EN !== 1'b1) `nnc_error("ATM28",$sformatf("D2A_SDMVREFPBUFF_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_SDMVREFPBUFF_EN));
    if(`ANA_TOP.D2A_SDMEN !== 16'h0100) `nnc_error("ATM28",$sformatf("D2A_SDMEN error, Real data:%4h not match 16'h0100",`ANA_TOP.D2A_SDMEN));
    if(`ANA_TOP.D2A_RLD_EN !== 1'b1) `nnc_error("ATM28",$sformatf("D2A_RLD_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_RLD_EN));
   `nnc_info("Checking ATM - Done", "Checking ATM28 Done", UVM_LOW);
    
    // ATM29 FIXED VALUE SESSION
    // Before ATM29 Modr
    // Chaging the fixed value
/*    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);

    //Section 0: 0xC1 : Bit[0]:D2A_BIST_EN = 0, Bit[5:1]:D2A_BIST_SEL = 5'b11111
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1; data[0] == {2'h0, 5'b11111, 1'b0} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //Section 0: 0xC2 : Bit[0]:D2A_OSC8MHZEN = 0, Bit[1]:D2A_BGBUFFER_CPTEST_EN = 1'b1
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_1; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //0x6C : Bit[0]:TSC_EN_CH1 = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_TSC_CTRL_REG; no_of_bytes == 1; data[0] == {8'h00} ;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
*/    
    // Enter ATM MODE
    // Enter ATM29 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b11101;
    #100;
   `nnc_info("Checking ATM - Start", "Checking ATM29 Done", UVM_LOW);
    
    // Enter ATM29 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[14] !== 1'b1) `nnc_error("ATM29",$sformatf("Enter ATM29 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b11101) `nnc_error("ATM29",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b11101",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM29",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== 1'b1) `nnc_error("ATM29",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_OSC8MHZEN)); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== 1'b1) `nnc_error("ATM29",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN));
    if(`ANA_TOP.D2A_EN_TSC !== 1'b1) `nnc_error("ATM29",$sformatf("D2A_EN_TSC error, Real data:%b not match 1'b1",`ANA_TOP.D2A_EN_TSC));
   `nnc_info("Checking ATM - Done", "Checking ATM29 Done", UVM_LOW);
    
    // ---------------------------------------------------- 
    // Part II:  Change fixed value when ATM_HC_SEL 1
    // ----------------------------------------------------
    // ATM0 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM0 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b00000;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
   
    `nnc_info("Checking ATM - Start", "Checking ATM 0 Done", UVM_LOW);
    // Enter ATM0 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[0] !== 1'b1) `nnc_error("ATM0",$sformatf("Enter atm1 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b00000) `nnc_error("ATM0",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b00000",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM0",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM0",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1)); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM0",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1));
   `nnc_info("Checking ATM - Done", "Checking ATM 0 Done", UVM_LOW);
    
    // ATM1 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM1 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b00001;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
   
    `nnc_info("Checking ATM - Start", "Checking ATM1 Done", UVM_LOW);
    
    // Enter ATM1 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[1] !== 1'b1) `nnc_error("ATM1",$sformatf("Enter ATM1 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b00001) `nnc_error("ATM1",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b00001",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM1",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM1",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM1",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
   `nnc_info("Checking ATM - Done", "Checking ATM1 Done", UVM_LOW);
    
    // ATM2 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM2 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b00010;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM2 Done", UVM_LOW);
    
    // Enter ATM2 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[2] !== 1'b1) `nnc_error("ATM2",$sformatf("Enter ATM2 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b00010) `nnc_error("ATM2",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b00010",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM2",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM2",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM2",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
   `nnc_info("Checking ATM - Done", "Checking ATM2 Done", UVM_LOW);
    
    // ATM3 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM3 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b00011;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM3 Done", UVM_LOW);
    
    // Enter ATM3 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[3] !== 1'b1) `nnc_error("ATM3",$sformatf("Enter ATM3 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b00011) `nnc_error("ATM3",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b00011",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM3",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM3",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM3",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
   `nnc_info("Checking ATM - Done", "Checking ATM3 Done", UVM_LOW);
    
    // ATM4 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM4 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b00100;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM4 Done", UVM_LOW);
    
    // Enter ATM4 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[4] !== 1'b1) `nnc_error("ATM4",$sformatf("Enter ATM4 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b00100) `nnc_error("ATM4",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b00100",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM4",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM4",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM4",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
   `nnc_info("Checking ATM - Done", "Checking ATM4 Done", UVM_LOW);
    
    // ATM5 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM5 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b00101;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM5 Done", UVM_LOW);
    
    // Enter ATM5 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[5] !== 1'b1) `nnc_error("ATM5",$sformatf("Enter ATM5 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b00101) `nnc_error("ATM5",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b00101",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM5",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM5",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM5",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_EN_TSC !== reg_tsc_ctrl[0]) `nnc_error("ATM5",$sformatf("D2A_EN_TSC error, Real data:%b not match %b",`ANA_TOP.D2A_EN_TSC, reg_tsc_ctrl[0]));
   `nnc_info("Checking ATM - Done", "Checking ATM5 Done", UVM_LOW);
    
    // ATM6 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM6 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b00110;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM6 Done", UVM_LOW);
    
    // Enter ATM6 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[6] !== 1'b1) `nnc_error("ATM6",$sformatf("Enter ATM6 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b00110) `nnc_error("ATM6",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b00110",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM6",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM6",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM6",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_DRIVER_CUR_EN !== 1'b0) `nnc_error("ATM6",$sformatf("D2A_DRIVER_CUR_EN error, Real data:%b not match 1'b0",`ANA_TOP.D2A_DRIVER_CUR_EN)); 
    if(`ANA_TOP.D2A_STIMU_EN !== 1'b0) `nnc_error("ATM6",$sformatf("D2A_STIMU_EN error, Real data:%b not match 1'b0",`ANA_TOP.D2A_STIMU_EN));
   `nnc_info("Checking ATM - Done", "Checking ATM6 Done", UVM_LOW);
    
    // ATM7 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM7 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b00111;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM7 Done", UVM_LOW);
    
    // Enter ATM7 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[7] !== 1'b1) `nnc_error("ATM7",$sformatf("Enter ATM7 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b00111) `nnc_error("ATM7",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b00111",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM7",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM6",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM6",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
   `nnc_info("Checking ATM - Done", "Checking ATM7 Done", UVM_LOW);
    
    // ATM8 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM8 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b01000;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM8 Done", UVM_LOW);
    
    // Enter ATM8 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[8] !== 1'b1) `nnc_error("ATM8",$sformatf("Enter ATM8 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b01000) `nnc_error("ATM8",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b01000",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM8",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM8",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM8",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
   `nnc_info("Checking ATM - Done", "Checking ATM8 Done", UVM_LOW);
    
    // ATM9 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM9 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b01001;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM9 Done", UVM_LOW);
    
    // Enter ATM9 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[9] !== 1'b1) `nnc_error("ATM9",$sformatf("Enter ATM9 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b01001) `nnc_error("ATM9",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b01001",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM9",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM9",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM9",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
   `nnc_info("Checking ATM - Done", "Checking ATM9 Done", UVM_LOW);
    
    // ATM10 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM10 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b01010;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM10 Done", UVM_LOW);
    
    // Enter ATM10 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[10] !== 1'b1) `nnc_error("ATM10",$sformatf("Enter ATM10 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b01010) `nnc_error("ATM10",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b01010",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM10",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM10",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM10",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
   `nnc_info("Checking ATM - Done", "Checking ATM10 Done", UVM_LOW);
    
    // ATM11 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM11 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b01011;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM11 Done", UVM_LOW);
    
    // Enter ATM11 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[11] !== 1'b1) `nnc_error("ATM11",$sformatf("Enter ATM11 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b01011) `nnc_error("ATM11",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b01011",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM11",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM11",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM11",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
   `nnc_info("Checking ATM - Done", "Checking ATM11 Done", UVM_LOW);
    
    // ATM12 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM12 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b01100;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM12 Done", UVM_LOW);
    
    // Enter ATM12 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[12] !== 1'b1) `nnc_error("ATM12",$sformatf("Enter ATM12 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b01100) `nnc_error("ATM12",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b01100",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM12",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM12",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM12",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_RLD_ELECTRODE_EN !== reg_ana_en_0_2[0]) `nnc_error("ATM12",$sformatf("D2A_RLD_ELECTRODE_EN error, Real data:%b not match %b",`ANA_TOP.D2A_RLD_ELECTRODE_EN,reg_ana_en_0_2[0]));
    if(`ANA_TOP.D2A_SDMVCMBUFF_EN !== reg_ana_en_0_2[2]) `nnc_error("ATM12",$sformatf("D2A_SDMVCMBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVCMBUFF_EN,reg_ana_en_0_2[2]));
    if(`ANA_TOP.D2A_SDMVREFPBUFF_EN !== reg_ana_en_0_2[3]) `nnc_error("ATM12",$sformatf("D2A_SDMVREFPBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVREFPBUFF_EN,reg_ana_en_0_2[3]));
    if(`ANA_TOP.D2A_SDMEN !== {reg_ana_en_0_14, reg_ana_en_0_13}) `nnc_error("ATM12",$sformatf("D2A_SDMEN error, Real data:%4h not match %b",`ANA_TOP.D2A_SDMEN,{reg_ana_en_0_14, reg_ana_en_0_13}));

   `nnc_info("Checking ATM - Done", "Checking ATM12 Done", UVM_LOW);
    
    // ATM13 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM13 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b01101;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM13 Done", UVM_LOW);
    
    // Enter ATM13 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[13] !== 1'b1) `nnc_error("ATM13",$sformatf("Enter ATM13 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b01101) `nnc_error("ATM13",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b01101",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM13",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM13",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM13",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_RLD_ELECTRODE_EN !== reg_ana_en_0_2[0]) `nnc_error("ATM13",$sformatf("D2A_RLD_ELECTRODE_EN error, Real data:%b not match %b",`ANA_TOP.D2A_RLD_ELECTRODE_EN,reg_ana_en_0_2[0]));
    if(`ANA_TOP.D2A_SDMVCMBUFF_EN !== reg_ana_en_0_2[2]) `nnc_error("ATM13",$sformatf("D2A_SDMVCMBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVCMBUFF_EN,reg_ana_en_0_2[2]));
    if(`ANA_TOP.D2A_SDMVREFPBUFF_EN !== reg_ana_en_0_2[3]) `nnc_error("ATM13",$sformatf("D2A_SDMVREFPBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVREFPBUFF_EN,reg_ana_en_0_2[3]));
    if(`ANA_TOP.D2A_SDMEN !== {reg_ana_en_0_14, reg_ana_en_0_13}) `nnc_error("ATM12",$sformatf("D2A_SDMEN error, Real data:%4h not match %b",`ANA_TOP.D2A_SDMEN,{reg_ana_en_0_14, reg_ana_en_0_13}));
   `nnc_info("Checking ATM - Done", "Checking ATM13 Done", UVM_LOW);
    
    // ATM14 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM14 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b01110;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM14 Done", UVM_LOW);
    
    // Enter ATM14 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[14] !== 1'b1) `nnc_error("ATM14",$sformatf("Enter ATM14 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b01110) `nnc_error("ATM14",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b01110",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM14",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM14",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM14",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_RLD_ELECTRODE_EN !== reg_ana_en_0_2[0]) `nnc_error("ATM14",$sformatf("D2A_RLD_ELECTRODE_EN error, Real data:%b not match %b",`ANA_TOP.D2A_RLD_ELECTRODE_EN,reg_ana_en_0_2[0]));
    if(`ANA_TOP.D2A_SDMVCMBUFF_EN !== reg_ana_en_0_2[2]) `nnc_error("ATM14",$sformatf("D2A_SDMVCMBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVCMBUFF_EN,reg_ana_en_0_2[2]));
    if(`ANA_TOP.D2A_SDMVREFPBUFF_EN !== reg_ana_en_0_2[3]) `nnc_error("ATM14",$sformatf("D2A_SDMVREFPBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVREFPBUFF_EN,reg_ana_en_0_2[3]));
    if(`ANA_TOP.D2A_SDMEN !== {reg_ana_en_0_14, reg_ana_en_0_13}) `nnc_error("ATM12",$sformatf("D2A_SDMEN error, Real data:%4h not match %b",`ANA_TOP.D2A_SDMEN,{reg_ana_en_0_14, reg_ana_en_0_13}));
   `nnc_info("Checking ATM - Done", "Checking ATM14 Done", UVM_LOW);
    
    // ATM15 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM15 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b01111;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM15 Done", UVM_LOW);
    
    // Enter ATM15 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[0] !== 1'b1) `nnc_error("ATM15",$sformatf("Enter ATM15 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b01111) `nnc_error("ATM15",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b01111",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM15",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM15",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM15",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_EN_TSC !== reg_tsc_ctrl[0]) `nnc_error("ATM15",$sformatf("D2A_EN_TSC error, Real data:%b not match %b",`ANA_TOP.D2A_EN_TSC, reg_tsc_ctrl[0]));
   `nnc_info("Checking ATM - Done", "Checking ATM15 Done", UVM_LOW);
    
    // ATM16 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM16 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b10000;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM16 Done", UVM_LOW);
    
    // Enter ATM16 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[1] !== 1'b1) `nnc_error("ATM16",$sformatf("Enter ATM16 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b10000) `nnc_error("ATM16",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b10000",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM16",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM16",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM16",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_DCLOFFEN !== {reg_ana_en_1_1, reg_ana_en_1_0}) `nnc_error("ATM16",$sformatf("D2A_DCLOFFEN error, Real data:%b not match %b",`ANA_TOP.D2A_DCLOFFEN,{reg_ana_en_1_1, reg_ana_en_1_0}));
   `nnc_info("Checking ATM - Done", "Checking ATM16 Done", UVM_LOW);
    
    // ATM17 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM17 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b10001;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM17 Done", UVM_LOW);
    
    // Enter ATM17 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[2] !== 1'b1) `nnc_error("ATM17",$sformatf("Enter ATM17 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b10001) `nnc_error("ATM17",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b10001",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM17",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM17",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM17",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_DCLOFFEN !== {reg_ana_en_1_1, reg_ana_en_1_0}) `nnc_error("ATM16",$sformatf("D2A_DCLOFFEN error, Real data:%b not match %b",`ANA_TOP.D2A_DCLOFFEN,{reg_ana_en_1_1, reg_ana_en_1_0}));
   `nnc_info("Checking ATM - Done", "Checking ATM17 Done", UVM_LOW);
    
    // ATM18 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM18 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b10010;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM18 Done", UVM_LOW);
    
    // Enter ATM18 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[3] !== 1'b1) `nnc_error("ATM18",$sformatf("Enter ATM18 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b10010) `nnc_error("ATM18",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b10010",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM18",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM18",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM18",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_NIRS4_EN !== 1'b0) `nnc_error("ATM18",$sformatf("D2A_NIRS4_EN error, Real data:%b not match 1'b0",`ANA_TOP.D2A_NIRS4_EN));
    if(`ANA_TOP.D2A_NIRS_TEST_EN !== 1'b0) `nnc_error("ATM18",$sformatf("D2A_NIRS_TEST_EN error, Real data:%b not match 1'b0",`ANA_TOP.D2A_NIRS_TEST_EN));
   `nnc_info("Checking ATM - Done", "Checking ATM18 Done", UVM_LOW);
    
    // ATM19 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM19 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b10011;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM19 Done", UVM_LOW);
    
    // Enter ATM19 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[4] !== 1'b1) `nnc_error("ATM19",$sformatf("Enter ATM19 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b10011) `nnc_error("ATM19",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b10011",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM19",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM19",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM19",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_NIRS4_EN !== 1'b0) `nnc_error("ATM19",$sformatf("D2A_NIRS4_EN error, Real data:%b not match 1'b0",`ANA_TOP.D2A_NIRS4_EN));
    if(`ANA_TOP.D2A_NIRS_TEST_EN !== 1'b0) `nnc_error("ATM19",$sformatf("D2A_NIRS_TEST_EN error, Real data:%b not match 1'b0",`ANA_TOP.D2A_NIRS_TEST_EN));
   `nnc_info("Checking ATM - Done", "Checking ATM19 Done", UVM_LOW);
    
    // ATM20 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM20 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b10100;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM20 Done", UVM_LOW);
    
    // Enter ATM20 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[5] !== 1'b1) `nnc_error("ATM20",$sformatf("Enter ATM20 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b10100) `nnc_error("ATM20",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b10100",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM20",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM20",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM20",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_NIRS4_EN !== 1'b0) `nnc_error("ATM20",$sformatf("D2A_NIRS4_EN error, Real data:%b not match 1'b0",`ANA_TOP.D2A_NIRS4_EN));
    if(`ANA_TOP.D2A_NIRS4_IDAC_EN !== 1'b0) `nnc_error("ATM20",$sformatf("D2A_NIRS4_IDAC_EN error, Real data:%b not match 1'b0",`ANA_TOP.D2A_NIRS4_IDAC_EN));
    if(`ANA_TOP.D2A_NIRS_TEST_EN !== 1'b0) `nnc_error("ATM20",$sformatf("D2A_NIRS_TEST_EN error, Real data:%b not match 1'b0",`ANA_TOP.D2A_NIRS_TEST_EN));
   `nnc_info("Checking ATM - Done", "Checking ATM20 Done", UVM_LOW);
    
    // ATM21 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM21 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b10101;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM21 Done", UVM_LOW);
    
    // Enter ATM21 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[6] !== 1'b1) `nnc_error("ATM21",$sformatf("Enter ATM21 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b10101) `nnc_error("ATM21",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b10101",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM21",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM21",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM21",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_RLD_ELECTRODE_EN !== reg_ana_en_0_2[0]) `nnc_error("ATM21",$sformatf("D2A_RLD_ELECTRODE_EN error, Real data:%b not match %b",`ANA_TOP.D2A_RLD_ELECTRODE_EN,reg_ana_en_0_2[0]));
    if(`ANA_TOP.D2A_SDMVCMBUFF_EN !== reg_ana_en_0_2[2]) `nnc_error("ATM21",$sformatf("D2A_SDMVCMBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVCMBUFF_EN,reg_ana_en_0_2[2]));
    if(`ANA_TOP.D2A_SDMVREFPBUFF_EN !== reg_ana_en_0_2[3]) `nnc_error("ATM21",$sformatf("D2A_SDMVREFPBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVREFPBUFF_EN,reg_ana_en_0_2[3]));
    if(`ANA_TOP.D2A_SDMEN !== {reg_ana_en_0_14, reg_ana_en_0_13}) `nnc_error("ATM12",$sformatf("D2A_SDMEN error, Real data:%4h not match %b",`ANA_TOP.D2A_SDMEN,{reg_ana_en_0_14, reg_ana_en_0_13}));
   `nnc_info("Checking ATM - Done", "Checking ATM21 Done", UVM_LOW);
    
    // ATM22 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM22 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b10110;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM22 Done", UVM_LOW);
    
    // Enter ATM22 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[7] !== 1'b1) `nnc_error("ATM22",$sformatf("Enter ATM22 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b10110) `nnc_error("ATM22",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b10110",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM22",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM22",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM22",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_RLD_ELECTRODE_EN !== reg_ana_en_0_2[0]) `nnc_error("ATM22",$sformatf("D2A_RLD_ELECTRODE_EN error, Real data:%b not match %b",`ANA_TOP.D2A_RLD_ELECTRODE_EN,reg_ana_en_0_2[0]));
    if(`ANA_TOP.D2A_SDMVCMBUFF_EN !== reg_ana_en_0_2[2]) `nnc_error("ATM22",$sformatf("D2A_SDMVCMBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVCMBUFF_EN,reg_ana_en_0_2[2]));
    if(`ANA_TOP.D2A_SDMVREFPBUFF_EN !== reg_ana_en_0_2[3]) `nnc_error("ATM22",$sformatf("D2A_SDMVREFPBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVREFPBUFF_EN,reg_ana_en_0_2[3]));
    if(`ANA_TOP.D2A_SDMEN !== {reg_ana_en_0_14, reg_ana_en_0_13}) `nnc_error("ATM22",$sformatf("D2A_SDMEN error, Real data:%4h not match %4h",`ANA_TOP.D2A_SDMEN,{reg_ana_en_0_14, reg_ana_en_0_13}));
   `nnc_info("Checking ATM - Done", "Checking ATM22 Done", UVM_LOW);
    
    // ATM23 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM23 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b10111;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM23 Done", UVM_LOW);
    
    // Enter ATM23 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[8] !== 1'b1) `nnc_error("ATM23",$sformatf("Enter ATM23 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b10111) `nnc_error("ATM23",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b10111",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM23",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM23",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM23",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_RLD_ELECTRODE_EN !== reg_ana_en_0_2[0]) `nnc_error("ATM23",$sformatf("D2A_RLD_ELECTRODE_EN error, Real data:%b not match %b",`ANA_TOP.D2A_RLD_ELECTRODE_EN,reg_ana_en_0_2[0]));
    if(`ANA_TOP.D2A_SDMVCMBUFF_EN !== reg_ana_en_0_2[2]) `nnc_error("ATM23",$sformatf("D2A_SDMVCMBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVCMBUFF_EN,reg_ana_en_0_2[2]));
    if(`ANA_TOP.D2A_SDMVREFPBUFF_EN !== reg_ana_en_0_2[3]) `nnc_error("ATM23",$sformatf("D2A_SDMVREFPBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVREFPBUFF_EN,reg_ana_en_0_2[3]));
    if(`ANA_TOP.D2A_SDMEN !== {reg_ana_en_0_14, reg_ana_en_0_13}) `nnc_error("ATM23",$sformatf("D2A_SDMEN error, Real data:%4h not match %4h",`ANA_TOP.D2A_SDMEN,{reg_ana_en_0_14, reg_ana_en_0_13}));
   `nnc_info("Checking ATM - Done", "Checking ATM23 Done", UVM_LOW);
    
    // ATM24 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM24 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b11000;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM24 Done", UVM_LOW);
    
    // Enter ATM24 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[9] !== 1'b1) `nnc_error("ATM24",$sformatf("Enter ATM24 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b11000) `nnc_error("ATM24",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b11000",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM24",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM24",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM24",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_RLD_ELECTRODE_EN !== reg_ana_en_0_2[0]) `nnc_error("ATM24",$sformatf("D2A_RLD_ELECTRODE_EN error, Real data:%b not match %b",`ANA_TOP.D2A_RLD_ELECTRODE_EN,reg_ana_en_0_2[0]));
    if(`ANA_TOP.D2A_SDMVCMBUFF_EN !== reg_ana_en_0_2[2]) `nnc_error("ATM24",$sformatf("D2A_SDMVCMBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVCMBUFF_EN,reg_ana_en_0_2[2]));
    if(`ANA_TOP.D2A_SDMVREFPBUFF_EN !== reg_ana_en_0_2[3]) `nnc_error("ATM24",$sformatf("D2A_SDMVREFPBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVREFPBUFF_EN,reg_ana_en_0_2[3]));
    if(`ANA_TOP.D2A_SDMEN !== {reg_ana_en_0_14, reg_ana_en_0_13}) `nnc_error("ATM23",$sformatf("D2A_SDMEN error, Real data:%4h not match %4h",`ANA_TOP.D2A_SDMEN,{reg_ana_en_0_14, reg_ana_en_0_13}));
   `nnc_info("Checking ATM - Done", "Checking ATM24 Done", UVM_LOW);
    
    // ATM25 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM25 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b11001;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM25 Done", UVM_LOW);
    
    // Enter ATM25 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[10] !== 1'b1) `nnc_error("ATM25",$sformatf("Enter ATM25 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b11001) `nnc_error("ATM25",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b11001",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM25",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM25",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM25",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_RLD_ELECTRODE_EN !== reg_ana_en_0_2[0]) `nnc_error("ATM25",$sformatf("D2A_RLD_ELECTRODE_EN error, Real data:%b not match %b",`ANA_TOP.D2A_RLD_ELECTRODE_EN,reg_ana_en_0_2[0]));
    if(`ANA_TOP.D2A_SDMVCMBUFF_EN !== reg_ana_en_0_2[2]) `nnc_error("ATM25",$sformatf("D2A_SDMVCMBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVCMBUFF_EN,reg_ana_en_0_2[2]));
    if(`ANA_TOP.D2A_SDMVREFPBUFF_EN !== reg_ana_en_0_2[3]) `nnc_error("ATM25",$sformatf("D2A_SDMVREFPBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVREFPBUFF_EN,reg_ana_en_0_2[3]));
    if(`ANA_TOP.D2A_SDMEN !== {reg_ana_en_0_14, reg_ana_en_0_13}) `nnc_error("ATM23",$sformatf("D2A_SDMEN error, Real data:%4h not match %4h",`ANA_TOP.D2A_SDMEN,{reg_ana_en_0_14, reg_ana_en_0_13}));
   `nnc_info("Checking ATM - Done", "Checking ATM25 Done", UVM_LOW);
    
    // ATM26 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM26 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b11010;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM26 Done", UVM_LOW);
    
    // Enter ATM26 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[11] !== 1'b1) `nnc_error("ATM26",$sformatf("Enter ATM26 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b11010) `nnc_error("ATM26",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b11010",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM26",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM26",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM26",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_RLD_ELECTRODE_EN !== reg_ana_en_0_2[0]) `nnc_error("ATM26",$sformatf("D2A_RLD_ELECTRODE_EN error, Real data:%b not match %b",`ANA_TOP.D2A_RLD_ELECTRODE_EN,reg_ana_en_0_2[0]));
    if(`ANA_TOP.D2A_SDMVCMBUFF_EN !== reg_ana_en_0_2[2]) `nnc_error("ATM26",$sformatf("D2A_SDMVCMBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVCMBUFF_EN,reg_ana_en_0_2[2]));
    if(`ANA_TOP.D2A_SDMVREFPBUFF_EN !== reg_ana_en_0_2[3]) `nnc_error("ATM26",$sformatf("D2A_SDMVREFPBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVREFPBUFF_EN,reg_ana_en_0_2[3]));
    if(`ANA_TOP.D2A_SDMEN !== {reg_ana_en_0_14, reg_ana_en_0_13}) `nnc_error("ATM23",$sformatf("D2A_SDMEN error, Real data:%4h not match %4h",`ANA_TOP.D2A_SDMEN,{reg_ana_en_0_14, reg_ana_en_0_13}));
   `nnc_info("Checking ATM - Done", "Checking ATM26 Done", UVM_LOW);
    
    // ATM27 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM27 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b11011;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM27 Done", UVM_LOW);
    
    // Enter ATM27 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[12] !== 1'b1) `nnc_error("ATM27",$sformatf("Enter ATM27 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b11011) `nnc_error("ATM27",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b11011",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM27",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM27",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM27",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_RLD_ELECTRODE_EN !== reg_ana_en_0_2[0]) `nnc_error("ATM27",$sformatf("D2A_RLD_ELECTRODE_EN error, Real data:%b not match %b",`ANA_TOP.D2A_RLD_ELECTRODE_EN,reg_ana_en_0_2[0]));
    if(`ANA_TOP.D2A_SDMVCMBUFF_EN !== reg_ana_en_0_2[2]) `nnc_error("ATM27",$sformatf("D2A_SDMVCMBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVCMBUFF_EN,reg_ana_en_0_2[2]));
    if(`ANA_TOP.D2A_SDMVREFPBUFF_EN !== reg_ana_en_0_2[3]) `nnc_error("ATM27",$sformatf("D2A_SDMVREFPBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVREFPBUFF_EN,reg_ana_en_0_2[3]));
    if(`ANA_TOP.D2A_SDMEN !== {reg_ana_en_0_14, reg_ana_en_0_13}) `nnc_error("ATM23",$sformatf("D2A_SDMEN error, Real data:%4h not match %4h",`ANA_TOP.D2A_SDMEN,{reg_ana_en_0_14, reg_ana_en_0_13}));
   `nnc_info("Checking ATM - Done", "Checking ATM27 Done", UVM_LOW);
    
    // ATM28 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM28 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b11100;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM28 Done", UVM_LOW);
    
    // Enter ATM28 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[13] !== 1'b1) `nnc_error("ATM28",$sformatf("Enter ATM28 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b11100) `nnc_error("ATM28",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b11100",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM28",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM28",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM28",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_RLD_ELECTRODE_EN !== reg_ana_en_0_2[0]) `nnc_error("ATM28",$sformatf("D2A_RLD_ELECTRODE_EN error, Real data:%b not match %b",`ANA_TOP.D2A_RLD_ELECTRODE_EN,reg_ana_en_0_2[0]));
    if(`ANA_TOP.D2A_SDMVCMBUFF_EN !== reg_ana_en_0_2[2]) `nnc_error("ATM28",$sformatf("D2A_SDMVCMBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVCMBUFF_EN,reg_ana_en_0_2[2]));
    if(`ANA_TOP.D2A_SDMVREFPBUFF_EN !== reg_ana_en_0_2[3]) `nnc_error("ATM28",$sformatf("D2A_SDMVREFPBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVREFPBUFF_EN,reg_ana_en_0_2[3]));
    if(`ANA_TOP.D2A_SDMEN !== {reg_ana_en_0_14, reg_ana_en_0_13}) `nnc_error("ATM23",$sformatf("D2A_SDMEN error, Real data:%4h not match %4h",`ANA_TOP.D2A_SDMEN,{reg_ana_en_0_14, reg_ana_en_0_13}));
    if(`ANA_TOP.D2A_RLD_EN !== reg_ana_en_0_3[2]) `nnc_error("ATM28",$sformatf("D2A_RLD_EN error, Real data:%b not match %b",`ANA_TOP.D2A_RLD_EN,reg_ana_en_0_3[2]));
   `nnc_info("Checking ATM - Done", "Checking ATM28 Done", UVM_LOW);
    
    // ATM29 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM29 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b11101;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
   
   `nnc_info("Checking ATM - Start", "Checking ATM29 Done", UVM_LOW);
    
    // Enter ATM29 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[14] !== 1'b1) `nnc_error("ATM29",$sformatf("Enter ATM29 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== 5'b11101) `nnc_error("ATM29",$sformatf("D2A_BIST_SEL error, Real data:%b not match 5'b11101",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN !== 1'b1) `nnc_error("ATM29",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM29",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM29",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_EN_TSC !== reg_tsc_ctrl[0]) `nnc_error("ATM29",$sformatf("D2A_EN_TSC error, Real data:%b not match %b",`ANA_TOP.D2A_EN_TSC, reg_tsc_ctrl[0]));
   `nnc_info("Checking ATM - Done", "Checking ATM29 Done", UVM_LOW);
    
    // ---------------------------------------------------- 
    // Part III:  Change fixed value when ATM_HC_SEL 3
    // ----------------------------------------------------
    // ATM0 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_bist_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM0 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b00000;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
   
    `nnc_info("Checking ATM - Start", "Checking ATM 0 Done", UVM_LOW);
    // Enter ATM0 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[0] !== 1'b1) `nnc_error("ATM0",$sformatf("Enter atm1 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== reg_ana_en_0_0[5:1]) `nnc_error("ATM0",$sformatf("D2A_BIST_SEL error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_SEL, reg_ana_en_0_0[5:1])); 
    if(`ANA_TOP.D2A_BIST_EN !== reg_ana_en_0_0[0]) `nnc_error("ATM0",$sformatf("D2A_BIST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_EN,reg_ana_en_0_0[0])); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM0",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1)); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM0",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1));
   `nnc_info("Checking ATM - Done", "Checking ATM 0 Done", UVM_LOW);
    
    // ATM1 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_bist_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM1 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b00001;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
   
    `nnc_info("Checking ATM - Start", "Checking ATM1 Done", UVM_LOW);
    
    // Enter ATM1 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[1] !== 1'b1) `nnc_error("ATM1",$sformatf("Enter ATM1 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== reg_ana_en_0_0[5:1]) `nnc_error("ATM0",$sformatf("D2A_BIST_SEL error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_SEL, reg_ana_en_0_0[5:1])); 
    if(`ANA_TOP.D2A_BIST_EN !== reg_ana_en_0_0[0]) `nnc_error("ATM0",$sformatf("D2A_BIST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_EN,reg_ana_en_0_0[0])); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM1",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM1",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
   `nnc_info("Checking ATM - Done", "Checking ATM1 Done", UVM_LOW);
    
    // ATM2 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_bist_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM2 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b00010;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM2 Done", UVM_LOW);
    
    // Enter ATM2 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[2] !== 1'b1) `nnc_error("ATM2",$sformatf("Enter ATM2 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== reg_ana_en_0_0[5:1]) `nnc_error("ATM0",$sformatf("D2A_BIST_SEL error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_SEL, reg_ana_en_0_0[5:1])); 
    if(`ANA_TOP.D2A_BIST_EN !== reg_ana_en_0_0[0]) `nnc_error("ATM0",$sformatf("D2A_BIST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_EN,reg_ana_en_0_0[0])); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM2",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM2",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
   `nnc_info("Checking ATM - Done", "Checking ATM2 Done", UVM_LOW);
    
    // ATM3 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_bist_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM3 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b00011;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM3 Done", UVM_LOW);
    
    // Enter ATM3 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[3] !== 1'b1) `nnc_error("ATM3",$sformatf("Enter ATM3 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== reg_ana_en_0_0[5:1]) `nnc_error("ATM0",$sformatf("D2A_BIST_SEL error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_SEL, reg_ana_en_0_0[5:1])); 
    if(`ANA_TOP.D2A_BIST_EN !== reg_ana_en_0_0[0]) `nnc_error("ATM0",$sformatf("D2A_BIST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_EN,reg_ana_en_0_0[0])); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM3",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM3",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
   `nnc_info("Checking ATM - Done", "Checking ATM3 Done", UVM_LOW);
    
    // ATM4 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_bist_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM4 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b00100;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM4 Done", UVM_LOW);
    
    // Enter ATM4 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[4] !== 1'b1) `nnc_error("ATM4",$sformatf("Enter ATM4 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== reg_ana_en_0_0[5:1]) `nnc_error("ATM0",$sformatf("D2A_BIST_SEL error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_SEL, reg_ana_en_0_0[5:1])); 
    if(`ANA_TOP.D2A_BIST_EN !== reg_ana_en_0_0[0]) `nnc_error("ATM0",$sformatf("D2A_BIST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_EN,reg_ana_en_0_0[0])); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM4",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM4",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
   `nnc_info("Checking ATM - Done", "Checking ATM4 Done", UVM_LOW);
    
    // ATM5 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_bist_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM5 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b00101;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM5 Done", UVM_LOW);
    
    // Enter ATM5 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[5] !== 1'b1) `nnc_error("ATM5",$sformatf("Enter ATM5 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== reg_ana_en_0_0[5:1]) `nnc_error("ATM0",$sformatf("D2A_BIST_SEL error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_SEL, reg_ana_en_0_0[5:1])); 
    if(`ANA_TOP.D2A_BIST_EN !== reg_ana_en_0_0[0]) `nnc_error("ATM0",$sformatf("D2A_BIST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_EN,reg_ana_en_0_0[0])); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM5",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM5",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_EN_TSC !== reg_tsc_ctrl[0]) `nnc_error("ATM5",$sformatf("D2A_EN_TSC error, Real data:%b not match %b",`ANA_TOP.D2A_EN_TSC, reg_tsc_ctrl[0]));
   `nnc_info("Checking ATM - Done", "Checking ATM5 Done", UVM_LOW);
    
    // ATM6 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_bist_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM6 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b00110;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM6 Done", UVM_LOW);
    
    // Enter ATM6 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[6] !== 1'b1) `nnc_error("ATM6",$sformatf("Enter ATM6 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== reg_ana_en_0_0[5:1]) `nnc_error("ATM0",$sformatf("D2A_BIST_SEL error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_SEL, reg_ana_en_0_0[5:1])); 
    if(`ANA_TOP.D2A_BIST_EN !== reg_ana_en_0_0[0]) `nnc_error("ATM0",$sformatf("D2A_BIST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_EN,reg_ana_en_0_0[0])); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM6",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM6",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_DRIVER_CUR_EN !== 1'b0) `nnc_error("ATM6",$sformatf("D2A_DRIVER_CUR_EN error, Real data:%b not match 1'b0",`ANA_TOP.D2A_DRIVER_CUR_EN)); 
    if(`ANA_TOP.D2A_STIMU_EN !== 1'b0) `nnc_error("ATM6",$sformatf("D2A_STIMU_EN error, Real data:%b not match 1'b0",`ANA_TOP.D2A_STIMU_EN));
   `nnc_info("Checking ATM - Done", "Checking ATM6 Done", UVM_LOW);
    
    // ATM7 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_bist_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM7 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b00111;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM7 Done", UVM_LOW);
    
    // Enter ATM7 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[7] !== 1'b1) `nnc_error("ATM7",$sformatf("Enter ATM7 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== reg_ana_en_0_0[5:1]) `nnc_error("ATM0",$sformatf("D2A_BIST_SEL error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_SEL, reg_ana_en_0_0[5:1])); 
    if(`ANA_TOP.D2A_BIST_EN !== reg_ana_en_0_0[0]) `nnc_error("ATM0",$sformatf("D2A_BIST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_EN,reg_ana_en_0_0[0])); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM6",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM6",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
   `nnc_info("Checking ATM - Done", "Checking ATM7 Done", UVM_LOW);
    
    // ATM8 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_bist_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM8 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b01000;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM8 Done", UVM_LOW);
    
    // Enter ATM8 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[8] !== 1'b1) `nnc_error("ATM8",$sformatf("Enter ATM8 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== reg_ana_en_0_0[5:1]) `nnc_error("ATM0",$sformatf("D2A_BIST_SEL error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_SEL, reg_ana_en_0_0[5:1])); 
    if(`ANA_TOP.D2A_BIST_EN !== reg_ana_en_0_0[0]) `nnc_error("ATM0",$sformatf("D2A_BIST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_EN,reg_ana_en_0_0[0])); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM8",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM8",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
   `nnc_info("Checking ATM - Done", "Checking ATM8 Done", UVM_LOW);
    
    // ATM9 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_bist_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM9 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b01001;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM9 Done", UVM_LOW);
    
    // Enter ATM9 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[9] !== 1'b1) `nnc_error("ATM9",$sformatf("Enter ATM9 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== reg_ana_en_0_0[5:1]) `nnc_error("ATM0",$sformatf("D2A_BIST_SEL error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_SEL, reg_ana_en_0_0[5:1])); 
    if(`ANA_TOP.D2A_BIST_EN !== reg_ana_en_0_0[0]) `nnc_error("ATM0",$sformatf("D2A_BIST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_EN,reg_ana_en_0_0[0])); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM9",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM9",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
   `nnc_info("Checking ATM - Done", "Checking ATM9 Done", UVM_LOW);
    
    // ATM10 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_bist_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM10 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b01010;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM10 Done", UVM_LOW);
    
    // Enter ATM10 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[10] !== 1'b1) `nnc_error("ATM10",$sformatf("Enter ATM10 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== reg_ana_en_0_0[5:1]) `nnc_error("ATM0",$sformatf("D2A_BIST_SEL error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_SEL, reg_ana_en_0_0[5:1])); 
    if(`ANA_TOP.D2A_BIST_EN !== reg_ana_en_0_0[0]) `nnc_error("ATM0",$sformatf("D2A_BIST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_EN,reg_ana_en_0_0[0])); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM10",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM10",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
   `nnc_info("Checking ATM - Done", "Checking ATM10 Done", UVM_LOW);
    
    // ATM11 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_bist_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM11 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b01011;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM11 Done", UVM_LOW);
    
    // Enter ATM11 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[11] !== 1'b1) `nnc_error("ATM11",$sformatf("Enter ATM11 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== reg_ana_en_0_0[5:1]) `nnc_error("ATM0",$sformatf("D2A_BIST_SEL error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_SEL, reg_ana_en_0_0[5:1])); 
    if(`ANA_TOP.D2A_BIST_EN !== reg_ana_en_0_0[0]) `nnc_error("ATM0",$sformatf("D2A_BIST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_EN,reg_ana_en_0_0[0])); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM11",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM11",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
   `nnc_info("Checking ATM - Done", "Checking ATM11 Done", UVM_LOW);
    
    // ATM12 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_bist_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM12 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b01100;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM12 Done", UVM_LOW);
    
    // Enter ATM12 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[12] !== 1'b1) `nnc_error("ATM12",$sformatf("Enter ATM12 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== reg_ana_en_0_0[5:1]) `nnc_error("ATM0",$sformatf("D2A_BIST_SEL error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_SEL, reg_ana_en_0_0[5:1])); 
    if(`ANA_TOP.D2A_BIST_EN !== reg_ana_en_0_0[0]) `nnc_error("ATM0",$sformatf("D2A_BIST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_EN,reg_ana_en_0_0[0])); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM12",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM12",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_RLD_ELECTRODE_EN !== reg_ana_en_0_2[0]) `nnc_error("ATM12",$sformatf("D2A_RLD_ELECTRODE_EN error, Real data:%b not match %b",`ANA_TOP.D2A_RLD_ELECTRODE_EN,reg_ana_en_0_2[0]));
    if(`ANA_TOP.D2A_SDMVCMBUFF_EN !== reg_ana_en_0_2[2]) `nnc_error("ATM12",$sformatf("D2A_SDMVCMBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVCMBUFF_EN,reg_ana_en_0_2[2]));
    if(`ANA_TOP.D2A_SDMVREFPBUFF_EN !== reg_ana_en_0_2[3]) `nnc_error("ATM12",$sformatf("D2A_SDMVREFPBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVREFPBUFF_EN,reg_ana_en_0_2[3]));
    if(`ANA_TOP.D2A_SDMEN !== {reg_ana_en_0_14, reg_ana_en_0_13}) `nnc_error("ATM23",$sformatf("D2A_SDMEN error, Real data:%4h not match %4h",`ANA_TOP.D2A_SDMEN,{reg_ana_en_0_14, reg_ana_en_0_13}));

   `nnc_info("Checking ATM - Done", "Checking ATM12 Done", UVM_LOW);
    
    // ATM13 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_bist_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM13 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b01101;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM13 Done", UVM_LOW);
    
    // Enter ATM13 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[13] !== 1'b1) `nnc_error("ATM13",$sformatf("Enter ATM13 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== reg_ana_en_0_0[5:1]) `nnc_error("ATM0",$sformatf("D2A_BIST_SEL error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_SEL, reg_ana_en_0_0[5:1])); 
    if(`ANA_TOP.D2A_BIST_EN !== reg_ana_en_0_0[0]) `nnc_error("ATM0",$sformatf("D2A_BIST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_EN,reg_ana_en_0_0[0])); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM13",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM13",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_RLD_ELECTRODE_EN !== reg_ana_en_0_2[0]) `nnc_error("ATM13",$sformatf("D2A_RLD_ELECTRODE_EN error, Real data:%b not match %b",`ANA_TOP.D2A_RLD_ELECTRODE_EN,reg_ana_en_0_2[0]));
    if(`ANA_TOP.D2A_SDMVCMBUFF_EN !== reg_ana_en_0_2[2]) `nnc_error("ATM13",$sformatf("D2A_SDMVCMBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVCMBUFF_EN,reg_ana_en_0_2[2]));
    if(`ANA_TOP.D2A_SDMVREFPBUFF_EN !== reg_ana_en_0_2[3]) `nnc_error("ATM13",$sformatf("D2A_SDMVREFPBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVREFPBUFF_EN,reg_ana_en_0_2[3]));
    if(`ANA_TOP.D2A_SDMEN !== {reg_ana_en_0_14, reg_ana_en_0_13}) `nnc_error("ATM23",$sformatf("D2A_SDMEN error, Real data:%4h not match %4h",`ANA_TOP.D2A_SDMEN,{reg_ana_en_0_14, reg_ana_en_0_13}));
   `nnc_info("Checking ATM - Done", "Checking ATM13 Done", UVM_LOW);
    
    // ATM14 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_bist_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM14 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b01110;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM14 Done", UVM_LOW);
    
    // Enter ATM14 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_OTP_ATM_MODE_SEL[14] !== 1'b1) `nnc_error("ATM14",$sformatf("Enter ATM14 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== reg_ana_en_0_0[5:1]) `nnc_error("ATM0",$sformatf("D2A_BIST_SEL error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_SEL, reg_ana_en_0_0[5:1])); 
    if(`ANA_TOP.D2A_BIST_EN !== reg_ana_en_0_0[0]) `nnc_error("ATM0",$sformatf("D2A_BIST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_EN,reg_ana_en_0_0[0])); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM14",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM14",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_RLD_ELECTRODE_EN !== reg_ana_en_0_2[0]) `nnc_error("ATM14",$sformatf("D2A_RLD_ELECTRODE_EN error, Real data:%b not match %b",`ANA_TOP.D2A_RLD_ELECTRODE_EN,reg_ana_en_0_2[0]));
    if(`ANA_TOP.D2A_SDMVCMBUFF_EN !== reg_ana_en_0_2[2]) `nnc_error("ATM14",$sformatf("D2A_SDMVCMBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVCMBUFF_EN,reg_ana_en_0_2[2]));
    if(`ANA_TOP.D2A_SDMVREFPBUFF_EN !== reg_ana_en_0_2[3]) `nnc_error("ATM14",$sformatf("D2A_SDMVREFPBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVREFPBUFF_EN,reg_ana_en_0_2[3]));
    if(`ANA_TOP.D2A_SDMEN !== {reg_ana_en_0_14, reg_ana_en_0_13}) `nnc_error("ATM23",$sformatf("D2A_SDMEN error, Real data:%4h not match %4h",`ANA_TOP.D2A_SDMEN,{reg_ana_en_0_14, reg_ana_en_0_13}));
   `nnc_info("Checking ATM - Done", "Checking ATM14 Done", UVM_LOW);
    
    // ATM15 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_bist_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM15 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b01111;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM15 Done", UVM_LOW);
    
    // Enter ATM15 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[0] !== 1'b1) `nnc_error("ATM15",$sformatf("Enter ATM15 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== reg_ana_en_0_0[5:1]) `nnc_error("ATM0",$sformatf("D2A_BIST_SEL error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_SEL, reg_ana_en_0_0[5:1])); 
    if(`ANA_TOP.D2A_BIST_EN !== reg_ana_en_0_0[0]) `nnc_error("ATM0",$sformatf("D2A_BIST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_EN,reg_ana_en_0_0[0])); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM15",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM15",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_EN_TSC !== reg_tsc_ctrl[0]) `nnc_error("ATM15",$sformatf("D2A_EN_TSC error, Real data:%b not match %b",`ANA_TOP.D2A_EN_TSC, reg_tsc_ctrl[0]));
   `nnc_info("Checking ATM - Done", "Checking ATM15 Done", UVM_LOW);
    
    // ATM16 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_bist_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM16 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b10000;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM16 Done", UVM_LOW);
    
    // Enter ATM16 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[1] !== 1'b1) `nnc_error("ATM16",$sformatf("Enter ATM16 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== reg_ana_en_0_0[5:1]) `nnc_error("ATM0",$sformatf("D2A_BIST_SEL error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_SEL, reg_ana_en_0_0[5:1])); 
    if(`ANA_TOP.D2A_BIST_EN !== reg_ana_en_0_0[0]) `nnc_error("ATM0",$sformatf("D2A_BIST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_EN,reg_ana_en_0_0[0])); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM16",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM16",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_DCLOFFEN !== {reg_ana_en_1_1, reg_ana_en_1_0}) `nnc_error("ATM16",$sformatf("D2A_DCLOFFEN error, Real data:%b not match %b",`ANA_TOP.D2A_DCLOFFEN,{reg_ana_en_1_1, reg_ana_en_1_0}));
   `nnc_info("Checking ATM - Done", "Checking ATM16 Done", UVM_LOW);
    
    // ATM17 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_bist_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM17 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b10001;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM17 Done", UVM_LOW);
    
    // Enter ATM17 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[2] !== 1'b1) `nnc_error("ATM17",$sformatf("Enter ATM17 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== reg_ana_en_0_0[5:1]) `nnc_error("ATM0",$sformatf("D2A_BIST_SEL error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_SEL, reg_ana_en_0_0[5:1])); 
    if(`ANA_TOP.D2A_BIST_EN !== reg_ana_en_0_0[0]) `nnc_error("ATM0",$sformatf("D2A_BIST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_EN,reg_ana_en_0_0[0])); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM17",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM17",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_DCLOFFEN !== {reg_ana_en_1_1, reg_ana_en_1_0}) `nnc_error("ATM16",$sformatf("D2A_DCLOFFEN error, Real data:%b not match %b",`ANA_TOP.D2A_DCLOFFEN,{reg_ana_en_1_1, reg_ana_en_1_0}));
   `nnc_info("Checking ATM - Done", "Checking ATM17 Done", UVM_LOW);
    
    // ATM18 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_bist_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM18 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b10010;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM18 Done", UVM_LOW);
    
    // Enter ATM18 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[3] !== 1'b1) `nnc_error("ATM18",$sformatf("Enter ATM18 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== reg_ana_en_0_0[5:1]) `nnc_error("ATM0",$sformatf("D2A_BIST_SEL error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_SEL, reg_ana_en_0_0[5:1])); 
    if(`ANA_TOP.D2A_BIST_EN !== reg_ana_en_0_0[0]) `nnc_error("ATM0",$sformatf("D2A_BIST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_EN,reg_ana_en_0_0[0])); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM18",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM18",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_NIRS4_EN !== 1'b0) `nnc_error("ATM18",$sformatf("D2A_NIRS4_EN error, Real data:%b not match 1'b0",`ANA_TOP.D2A_NIRS4_EN));
    if(`ANA_TOP.D2A_NIRS_TEST_EN !== 1'b0) `nnc_error("ATM18",$sformatf("D2A_NIRS_TEST_EN error, Real data:%b not match 1'b0",`ANA_TOP.D2A_NIRS_TEST_EN));
   `nnc_info("Checking ATM - Done", "Checking ATM18 Done", UVM_LOW);
    
    // ATM19 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_bist_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM19 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b10011;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM19 Done", UVM_LOW);
    
    // Enter ATM19 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[4] !== 1'b1) `nnc_error("ATM19",$sformatf("Enter ATM19 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== reg_ana_en_0_0[5:1]) `nnc_error("ATM0",$sformatf("D2A_BIST_SEL error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_SEL, reg_ana_en_0_0[5:1])); 
    if(`ANA_TOP.D2A_BIST_EN !== reg_ana_en_0_0[0]) `nnc_error("ATM0",$sformatf("D2A_BIST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_EN,reg_ana_en_0_0[0])); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM19",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM19",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_NIRS4_EN !== 1'b0) `nnc_error("ATM19",$sformatf("D2A_NIRS4_EN error, Real data:%b not match 1'b0",`ANA_TOP.D2A_NIRS4_EN));
    if(`ANA_TOP.D2A_NIRS_TEST_EN !== 1'b0) `nnc_error("ATM19",$sformatf("D2A_NIRS_TEST_EN error, Real data:%b not match 1'b0",`ANA_TOP.D2A_NIRS_TEST_EN));
   `nnc_info("Checking ATM - Done", "Checking ATM19 Done", UVM_LOW);
    
    // ATM20 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_bist_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM20 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b10100;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM20 Done", UVM_LOW);
    
    // Enter ATM20 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[5] !== 1'b1) `nnc_error("ATM20",$sformatf("Enter ATM20 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== reg_ana_en_0_0[5:1]) `nnc_error("ATM0",$sformatf("D2A_BIST_SEL error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_SEL, reg_ana_en_0_0[5:1])); 
    if(`ANA_TOP.D2A_BIST_EN !== reg_ana_en_0_0[0]) `nnc_error("ATM0",$sformatf("D2A_BIST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_EN,reg_ana_en_0_0[0])); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM20",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM20",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_NIRS4_EN !== 1'b0) `nnc_error("ATM20",$sformatf("D2A_NIRS4_EN error, Real data:%b not match 1'b0",`ANA_TOP.D2A_NIRS4_EN));
    if(`ANA_TOP.D2A_NIRS4_IDAC_EN !== 1'b0) `nnc_error("ATM20",$sformatf("D2A_NIRS4_IDAC_EN error, Real data:%b not match 1'b0",`ANA_TOP.D2A_NIRS4_IDAC_EN));
    if(`ANA_TOP.D2A_NIRS_TEST_EN !== 1'b0) `nnc_error("ATM20",$sformatf("D2A_NIRS_TEST_EN error, Real data:%b not match 1'b0",`ANA_TOP.D2A_NIRS_TEST_EN));
   `nnc_info("Checking ATM - Done", "Checking ATM20 Done", UVM_LOW);
    
    // ATM21 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_bist_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM21 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b10101;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM21 Done", UVM_LOW);
    
    // Enter ATM21 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[6] !== 1'b1) `nnc_error("ATM21",$sformatf("Enter ATM21 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== reg_ana_en_0_0[5:1]) `nnc_error("ATM0",$sformatf("D2A_BIST_SEL error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_SEL, reg_ana_en_0_0[5:1])); 
    if(`ANA_TOP.D2A_BIST_EN !== reg_ana_en_0_0[0]) `nnc_error("ATM0",$sformatf("D2A_BIST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_EN,reg_ana_en_0_0[0])); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM21",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM21",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_RLD_ELECTRODE_EN !== reg_ana_en_0_2[0]) `nnc_error("ATM21",$sformatf("D2A_RLD_ELECTRODE_EN error, Real data:%b not match %b",`ANA_TOP.D2A_RLD_ELECTRODE_EN,reg_ana_en_0_2[0]));
    if(`ANA_TOP.D2A_SDMVCMBUFF_EN !== reg_ana_en_0_2[2]) `nnc_error("ATM21",$sformatf("D2A_SDMVCMBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVCMBUFF_EN,reg_ana_en_0_2[2]));
    if(`ANA_TOP.D2A_SDMVREFPBUFF_EN !== reg_ana_en_0_2[3]) `nnc_error("ATM21",$sformatf("D2A_SDMVREFPBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVREFPBUFF_EN,reg_ana_en_0_2[3]));
    if(`ANA_TOP.D2A_SDMEN !== {reg_ana_en_0_14, reg_ana_en_0_13}) `nnc_error("ATM23",$sformatf("D2A_SDMEN error, Real data:%4h not match %4h",`ANA_TOP.D2A_SDMEN,{reg_ana_en_0_14, reg_ana_en_0_13}));
   `nnc_info("Checking ATM - Done", "Checking ATM21 Done", UVM_LOW);
    
    // ATM22 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_bist_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM22 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b10110;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM22 Done", UVM_LOW);
    
    // Enter ATM22 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[7] !== 1'b1) `nnc_error("ATM22",$sformatf("Enter ATM22 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== reg_ana_en_0_0[5:1]) `nnc_error("ATM0",$sformatf("D2A_BIST_SEL error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_SEL, reg_ana_en_0_0[5:1])); 
    if(`ANA_TOP.D2A_BIST_EN !== reg_ana_en_0_0[0]) `nnc_error("ATM0",$sformatf("D2A_BIST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_EN,reg_ana_en_0_0[0])); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM22",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM22",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_RLD_ELECTRODE_EN !== reg_ana_en_0_2[0]) `nnc_error("ATM22",$sformatf("D2A_RLD_ELECTRODE_EN error, Real data:%b not match %b",`ANA_TOP.D2A_RLD_ELECTRODE_EN,reg_ana_en_0_2[0]));
    if(`ANA_TOP.D2A_SDMVCMBUFF_EN !== reg_ana_en_0_2[2]) `nnc_error("ATM22",$sformatf("D2A_SDMVCMBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVCMBUFF_EN,reg_ana_en_0_2[2]));
    if(`ANA_TOP.D2A_SDMVREFPBUFF_EN !== reg_ana_en_0_2[3]) `nnc_error("ATM22",$sformatf("D2A_SDMVREFPBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVREFPBUFF_EN,reg_ana_en_0_2[3]));
    if(`ANA_TOP.D2A_SDMEN !== {reg_ana_en_0_14, reg_ana_en_0_13}) `nnc_error("ATM23",$sformatf("D2A_SDMEN error, Real data:%4h not match %4h",`ANA_TOP.D2A_SDMEN,{reg_ana_en_0_14, reg_ana_en_0_13}));
   `nnc_info("Checking ATM - Done", "Checking ATM22 Done", UVM_LOW);
    
    // ATM23 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_bist_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM23 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b10111;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM23 Done", UVM_LOW);
    
    // Enter ATM23 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[8] !== 1'b1) `nnc_error("ATM23",$sformatf("Enter ATM23 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== reg_ana_en_0_0[5:1]) `nnc_error("ATM0",$sformatf("D2A_BIST_SEL error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_SEL, reg_ana_en_0_0[5:1])); 
    if(`ANA_TOP.D2A_BIST_EN !== reg_ana_en_0_0[0]) `nnc_error("ATM0",$sformatf("D2A_BIST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_EN,reg_ana_en_0_0[0])); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM23",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM23",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_RLD_ELECTRODE_EN !== reg_ana_en_0_2[0]) `nnc_error("ATM23",$sformatf("D2A_RLD_ELECTRODE_EN error, Real data:%b not match %b",`ANA_TOP.D2A_RLD_ELECTRODE_EN,reg_ana_en_0_2[0]));
    if(`ANA_TOP.D2A_SDMVCMBUFF_EN !== reg_ana_en_0_2[2]) `nnc_error("ATM23",$sformatf("D2A_SDMVCMBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVCMBUFF_EN,reg_ana_en_0_2[2]));
    if(`ANA_TOP.D2A_SDMVREFPBUFF_EN !== reg_ana_en_0_2[3]) `nnc_error("ATM23",$sformatf("D2A_SDMVREFPBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVREFPBUFF_EN,reg_ana_en_0_2[3]));
    if(`ANA_TOP.D2A_SDMEN !== {reg_ana_en_0_14, reg_ana_en_0_13}) `nnc_error("ATM23",$sformatf("D2A_SDMEN error, Real data:%4h not match %4h",`ANA_TOP.D2A_SDMEN,{reg_ana_en_0_14, reg_ana_en_0_13}));
   `nnc_info("Checking ATM - Done", "Checking ATM23 Done", UVM_LOW);
    
    // ATM24 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_bist_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM24 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b11000;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM24 Done", UVM_LOW);
    
    // Enter ATM24 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[9] !== 1'b1) `nnc_error("ATM24",$sformatf("Enter ATM24 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== reg_ana_en_0_0[5:1]) `nnc_error("ATM0",$sformatf("D2A_BIST_SEL error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_SEL, reg_ana_en_0_0[5:1])); 
    if(`ANA_TOP.D2A_BIST_EN !== reg_ana_en_0_0[0]) `nnc_error("ATM0",$sformatf("D2A_BIST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_EN,reg_ana_en_0_0[0])); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM24",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM24",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_RLD_ELECTRODE_EN !== reg_ana_en_0_2[0]) `nnc_error("ATM24",$sformatf("D2A_RLD_ELECTRODE_EN error, Real data:%b not match %b",`ANA_TOP.D2A_RLD_ELECTRODE_EN,reg_ana_en_0_2[0]));
    if(`ANA_TOP.D2A_SDMVCMBUFF_EN !== reg_ana_en_0_2[2]) `nnc_error("ATM24",$sformatf("D2A_SDMVCMBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVCMBUFF_EN,reg_ana_en_0_2[2]));
    if(`ANA_TOP.D2A_SDMVREFPBUFF_EN !== reg_ana_en_0_2[3]) `nnc_error("ATM24",$sformatf("D2A_SDMVREFPBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVREFPBUFF_EN,reg_ana_en_0_2[3]));
    if(`ANA_TOP.D2A_SDMEN !== {reg_ana_en_0_14, reg_ana_en_0_13}) `nnc_error("ATM23",$sformatf("D2A_SDMEN error, Real data:%4h not match %4h",`ANA_TOP.D2A_SDMEN,{reg_ana_en_0_14, reg_ana_en_0_13}));
   `nnc_info("Checking ATM - Done", "Checking ATM24 Done", UVM_LOW);
    
    // ATM25 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_bist_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM25 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b11001;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM25 Done", UVM_LOW);
    
    // Enter ATM25 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[10] !== 1'b1) `nnc_error("ATM25",$sformatf("Enter ATM25 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== reg_ana_en_0_0[5:1]) `nnc_error("ATM0",$sformatf("D2A_BIST_SEL error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_SEL, reg_ana_en_0_0[5:1])); 
    if(`ANA_TOP.D2A_BIST_EN !== reg_ana_en_0_0[0]) `nnc_error("ATM0",$sformatf("D2A_BIST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_EN,reg_ana_en_0_0[0])); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM25",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM25",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_RLD_ELECTRODE_EN !== reg_ana_en_0_2[0]) `nnc_error("ATM25",$sformatf("D2A_RLD_ELECTRODE_EN error, Real data:%b not match %b",`ANA_TOP.D2A_RLD_ELECTRODE_EN,reg_ana_en_0_2[0]));
    if(`ANA_TOP.D2A_SDMVCMBUFF_EN !== reg_ana_en_0_2[2]) `nnc_error("ATM25",$sformatf("D2A_SDMVCMBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVCMBUFF_EN,reg_ana_en_0_2[2]));
    if(`ANA_TOP.D2A_SDMVREFPBUFF_EN !== reg_ana_en_0_2[3]) `nnc_error("ATM25",$sformatf("D2A_SDMVREFPBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVREFPBUFF_EN,reg_ana_en_0_2[3]));
    if(`ANA_TOP.D2A_SDMEN !== {reg_ana_en_0_14, reg_ana_en_0_13}) `nnc_error("ATM23",$sformatf("D2A_SDMEN error, Real data:%4h not match %4h",`ANA_TOP.D2A_SDMEN,{reg_ana_en_0_14, reg_ana_en_0_13}));
   `nnc_info("Checking ATM - Done", "Checking ATM25 Done", UVM_LOW);
    
    // ATM26 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_bist_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM26 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b11010;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM26 Done", UVM_LOW);
    
    // Enter ATM26 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[11] !== 1'b1) `nnc_error("ATM26",$sformatf("Enter ATM26 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== reg_ana_en_0_0[5:1]) `nnc_error("ATM0",$sformatf("D2A_BIST_SEL error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_SEL, reg_ana_en_0_0[5:1])); 
    if(`ANA_TOP.D2A_BIST_EN !== reg_ana_en_0_0[0]) `nnc_error("ATM0",$sformatf("D2A_BIST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_EN,reg_ana_en_0_0[0])); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM26",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM26",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_RLD_ELECTRODE_EN !== reg_ana_en_0_2[0]) `nnc_error("ATM26",$sformatf("D2A_RLD_ELECTRODE_EN error, Real data:%b not match %b",`ANA_TOP.D2A_RLD_ELECTRODE_EN,reg_ana_en_0_2[0]));
    if(`ANA_TOP.D2A_SDMVCMBUFF_EN !== reg_ana_en_0_2[2]) `nnc_error("ATM26",$sformatf("D2A_SDMVCMBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVCMBUFF_EN,reg_ana_en_0_2[2]));
    if(`ANA_TOP.D2A_SDMVREFPBUFF_EN !== reg_ana_en_0_2[3]) `nnc_error("ATM26",$sformatf("D2A_SDMVREFPBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVREFPBUFF_EN,reg_ana_en_0_2[3]));
    if(`ANA_TOP.D2A_SDMEN !== {reg_ana_en_0_14, reg_ana_en_0_13}) `nnc_error("ATM23",$sformatf("D2A_SDMEN error, Real data:%4h not match %4h",`ANA_TOP.D2A_SDMEN,{reg_ana_en_0_14, reg_ana_en_0_13}));
   `nnc_info("Checking ATM - Done", "Checking ATM26 Done", UVM_LOW);
    
    // ATM27 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_bist_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM27 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b11011;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM27 Done", UVM_LOW);
    
    // Enter ATM27 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[12] !== 1'b1) `nnc_error("ATM27",$sformatf("Enter ATM27 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== reg_ana_en_0_0[5:1]) `nnc_error("ATM0",$sformatf("D2A_BIST_SEL error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_SEL, reg_ana_en_0_0[5:1])); 
    if(`ANA_TOP.D2A_BIST_EN !== reg_ana_en_0_0[0]) `nnc_error("ATM0",$sformatf("D2A_BIST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_EN,reg_ana_en_0_0[0])); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM27",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM27",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_RLD_ELECTRODE_EN !== reg_ana_en_0_2[0]) `nnc_error("ATM27",$sformatf("D2A_RLD_ELECTRODE_EN error, Real data:%b not match %b",`ANA_TOP.D2A_RLD_ELECTRODE_EN,reg_ana_en_0_2[0]));
    if(`ANA_TOP.D2A_SDMVCMBUFF_EN !== reg_ana_en_0_2[2]) `nnc_error("ATM27",$sformatf("D2A_SDMVCMBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVCMBUFF_EN,reg_ana_en_0_2[2]));
    if(`ANA_TOP.D2A_SDMVREFPBUFF_EN !== reg_ana_en_0_2[3]) `nnc_error("ATM27",$sformatf("D2A_SDMVREFPBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVREFPBUFF_EN,reg_ana_en_0_2[3]));
    if(`ANA_TOP.D2A_SDMEN !== {reg_ana_en_0_14, reg_ana_en_0_13}) `nnc_error("ATM23",$sformatf("D2A_SDMEN error, Real data:%4h not match %4h",`ANA_TOP.D2A_SDMEN,{reg_ana_en_0_14, reg_ana_en_0_13}));
   `nnc_info("Checking ATM - Done", "Checking ATM27 Done", UVM_LOW);
    
    // ATM28 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_bist_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM28 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b11100;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
    
   `nnc_info("Checking ATM - Start", "Checking ATM28 Done", UVM_LOW);
    
    // Enter ATM28 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[13] !== 1'b1) `nnc_error("ATM28",$sformatf("Enter ATM28 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== reg_ana_en_0_0[5:1]) `nnc_error("ATM0",$sformatf("D2A_BIST_SEL error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_SEL, reg_ana_en_0_0[5:1])); 
    if(`ANA_TOP.D2A_BIST_EN !== reg_ana_en_0_0[0]) `nnc_error("ATM0",$sformatf("D2A_BIST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_EN,reg_ana_en_0_0[0])); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM28",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM28",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_RLD_ELECTRODE_EN !== reg_ana_en_0_2[0]) `nnc_error("ATM28",$sformatf("D2A_RLD_ELECTRODE_EN error, Real data:%b not match %b",`ANA_TOP.D2A_RLD_ELECTRODE_EN,reg_ana_en_0_2[0]));
    if(`ANA_TOP.D2A_SDMVCMBUFF_EN !== reg_ana_en_0_2[2]) `nnc_error("ATM28",$sformatf("D2A_SDMVCMBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVCMBUFF_EN,reg_ana_en_0_2[2]));
    if(`ANA_TOP.D2A_SDMVREFPBUFF_EN !== reg_ana_en_0_2[3]) `nnc_error("ATM28",$sformatf("D2A_SDMVREFPBUFF_EN error, Real data:%b not match %b",`ANA_TOP.D2A_SDMVREFPBUFF_EN,reg_ana_en_0_2[3]));
    if(`ANA_TOP.D2A_SDMEN !== {reg_ana_en_0_14, reg_ana_en_0_13}) `nnc_error("ATM23",$sformatf("D2A_SDMEN error, Real data:%4h not match %4h",`ANA_TOP.D2A_SDMEN,{reg_ana_en_0_14, reg_ana_en_0_13}));
    if(`ANA_TOP.D2A_RLD_EN !== reg_ana_en_0_3[2]) `nnc_error("ATM28",$sformatf("D2A_RLD_EN error, Real data:%b not match %b",`ANA_TOP.D2A_RLD_EN,reg_ana_en_0_3[2]));
   `nnc_info("Checking ATM - Done", "Checking ATM28 Done", UVM_LOW);
    
    // ATM29 FIXED VALUE SESSION
    
    change_mode_normal();
    randomize_hardcoded_bist_value();
    
    //Change to testmode
    // Enter ATM MODE
    // Enter ATM29 mode
    force `SOC_TB.IOBUF_PAD[14:10] = 5'b11101;
    #100;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    #1ms;
   
   `nnc_info("Checking ATM - Start", "Checking ATM29 Done", UVM_LOW);
    
    // Enter ATM29 mode
    //Checking Enter ATM
    if(`DIG_TOP.u_pinmux.o_SPI_ATM_MODE_SEL[14] !== 1'b1) `nnc_error("ATM29",$sformatf("Enter ATM29 error!!!"));          
    
    //Checking ATM fixed value
    if(`ANA_TOP.D2A_BIST_SEL !== reg_ana_en_0_0[5:1]) `nnc_error("ATM0",$sformatf("D2A_BIST_SEL error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_SEL, reg_ana_en_0_0[5:1])); 
    if(`ANA_TOP.D2A_BIST_EN !== reg_ana_en_0_0[0]) `nnc_error("ATM0",$sformatf("D2A_BIST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BIST_EN,reg_ana_en_0_0[0])); 
    if(`ANA_TOP.D2A_OSC8MHZEN !== reg_ana_en_0_1[1]) `nnc_error("ATM29",$sformatf("D2A_OSC8MHZEN error, Real data:%b not match %b",`ANA_TOP.D2A_OSC8MHZEN, reg_ana_en_0_1[1])); 
    if(`ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== reg_ana_en_0_1[0]) `nnc_error("ATM29",$sformatf("D2A_BGBUFFER_CPTEST_EN error, Real data:%b not match %b",`ANA_TOP.D2A_BGBUFFER_CPTEST_EN, reg_ana_en_0_1[0]));
    if(`ANA_TOP.D2A_EN_TSC !== reg_tsc_ctrl[0]) `nnc_error("ATM29",$sformatf("D2A_EN_TSC error, Real data:%b not match %b",`ANA_TOP.D2A_EN_TSC, reg_tsc_ctrl[0]));
   `nnc_info("Checking ATM - Done", "Checking ATM29 Done", UVM_LOW);
    
`endif
    end
  endtask 

task change_mode_normal;
    begin
        // ========================================================================
        // Enable NORMAL mode
        // ========================================================================
        `nnc_info("ENABLE NORMAL MODE", "Change from test mode to normal mode", UVM_LOW);
        `nnc_info("Disconnect power supply", "Disconnect the power supply to the system", UVM_LOW);
        //stuck internal POR=1
        force `SOC_TOP.VDD_DIG = 1'b0;
        `nnc_info("Change mode", "Change from the testmode to normal mode", UVM_LOW);
        assert(top_test_cfg.randomize() with { testmode_sel == 2'b00;})
        `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
        #100;
        #1ms;
   
        `nnc_info("Connect power supply", "Connect the power supply to the system", UVM_LOW);
        //stuck internal POR=1
        force `SOC_TOP.VDD_DIG = 1'b1;
        //release `SOC_TOP.A2D_SW_POWER_POR;
        //release `SOC_TOP.CLKSEL;   
 
        `nnc_info("System Reset", "Reset the system", UVM_LOW);
        force `SOC_TOP.RESETn = 1'b0;
        #100;
        force `SOC_TOP.RESETn = 1'b1;
        //release `SOC_TOP.RESETn;
        #1ms;
    end
endtask   

task randomize_hardcoded_bist_value;
    begin
 
    // ========================================================================
    // Change hardcoded value 
    // ========================================================================
    //Enable SOC_ATM_HC_SEL to make fixed signal values control by spi
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ATM_HC_SEL; no_of_bytes == 1; data[0] == 8'b0000_0011;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    #100;
    
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);
    
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_SEC_SEL_REG; no_of_bytes == 1; data[0] == 0;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC1 : Bit[0]:D2A_BIST_EN = 0, Bit[1]:D2A_BIST_SEL
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data); 
    reg_ana_en_0_0 = top_test_cfg.data[0];    
    
    //Section 0: 0xC2 : Bit[0]:D2A_OSC8MHZEN = 0, Bit[1]:D2A_BGBUFFER_CPTEST_EN = 1'b1
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_1; no_of_bytes == 1;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data); 
    reg_ana_en_0_1 = top_test_cfg.data[0];    
    
    //Section 0: 0xC3 : Bit[0]:D2A_SDMVREFPBUFF_EN = 0, Bit[1]:D2A_SDMVCMBUFF_EN = 1'b1, Bit[2]:D2A_VCMGENBUFF_EN = 1'b1, Bit[3]:D2A_RLD_ELECTRODE_EN = 1'b1
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_2; no_of_bytes == 1;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    reg_ana_en_0_2 = top_test_cfg.data[0];    
    
    //Section 0: 0xC4 : Bit[2]:D2A_RLD_EN = 1'b1
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_3; no_of_bytes == 1;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    reg_ana_en_0_3 = top_test_cfg.data[0];    

    //Section 0: 0xC5 : Bit[7:0]:D2A_EEFLNA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_4; no_of_bytes == 1;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    reg_ana_en_0_4 = top_test_cfg.data[0];    
    
    //Section 0: 0xC6 : Bit[15:8]:D2A_EEFLNA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_5; no_of_bytes == 1;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    reg_ana_en_0_5 = top_test_cfg.data[0];    
    
    //Section 0: 0xC9 : Bit[7:0]:D2A_EEFPGA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_8; no_of_bytes == 1;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    reg_ana_en_0_8 = top_test_cfg.data[0];    
    
    //Section 0: 0xCA : Bit[7:0]:D2A_EEFPGA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_9; no_of_bytes == 1;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    reg_ana_en_0_9 = top_test_cfg.data[0];    
    
    //Section 0: 0xCA : Bit[7:0]:D2A_EEFPGA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_13; no_of_bytes == 1;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    reg_ana_en_0_13 = top_test_cfg.data[0];    
    
    //Section 0: 0xCA : Bit[7:0]:D2A_EEFPGA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_14; no_of_bytes == 1;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    reg_ana_en_0_14 = top_test_cfg.data[0];    
    
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 1\n", UVM_LOW);
    
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_SEC_SEL_REG; no_of_bytes == 1; data[0] == 1;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_SEC_SEL_REG; no_of_bytes == 1; data[0] == 1;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    //Section 1: 0xC2 : Bit[7:0]:D2A_SDMEN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_0; no_of_bytes == 1;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    reg_ana_en_1_0 = top_test_cfg.data[0];    
    
    //Section 1: 0xC2 : Bit[7:0]:D2A_SDMEN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_1; no_of_bytes == 1;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    reg_ana_en_1_1 = top_test_cfg.data[0];    
    
    //Section 1: 0xC3 : Bit[15:8]:D2A_SDMEN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_2; no_of_bytes == 1;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    reg_ana_en_1_2 = top_test_cfg.data[0];    
    
    //Section 1: 0xC4 : Bit[7:0]:D2A_SDMBUFF_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_3; no_of_bytes == 1;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    reg_ana_en_1_3 = top_test_cfg.data[0];    
    
    //Section 1: 0xC5 : Bit[15:8]:D2A_SDMBUFF_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_4; no_of_bytes == 1;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    reg_ana_en_1_4 = top_test_cfg.data[0];    
    
    //Section 1: 0xC6 : Bit[7:0]:D2A_DCLOFFEN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_5; no_of_bytes == 1;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    reg_ana_en_1_5 = top_test_cfg.data[0];    
    
    //Section 1: 0xC7 : Bit[15:8]:D2A_DCLOFFEN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_6; no_of_bytes == 1;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    reg_ana_en_1_6 = top_test_cfg.data[0];    
    
    //0x6C : Bit[0]:D2A_EN_TSC = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_TSC_CTRL_REG; no_of_bytes == 1;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    reg_tsc_ctrl = top_test_cfg.data[0];    
   
    end
endtask 

task randomize_hardcoded_value;
    begin
 
    // ========================================================================
    // Change hardcoded value 
    // ========================================================================
    //Enable SOC_ATM_HC_SEL to make fixed signal values control by spi
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ATM_HC_SEL; no_of_bytes == 1; data[0] == 8'b0000_0001;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    #100;
    
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 0\n", UVM_LOW);
    
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_SEC_SEL_REG; no_of_bytes == 1; data[0] == 0;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //Section 0: 0xC1 : Bit[0]:D2A_BIST_EN = 0, Bit[1]:D2A_BIST_SEL
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_0; no_of_bytes == 1;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data); 
    reg_ana_en_0_0 = top_test_cfg.data[0];    
    
    //Section 0: 0xC2 : Bit[0]:D2A_OSC8MHZEN = 0, Bit[1]:D2A_BGBUFFER_CPTEST_EN = 1'b1
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_1; no_of_bytes == 1;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data); 
    reg_ana_en_0_1 = top_test_cfg.data[0];    
    
    //Section 0: 0xC3 : Bit[0]:D2A_SDMVREFPBUFF_EN = 0, Bit[1]:D2A_SDMVCMBUFF_EN = 1'b1, Bit[2]:D2A_VCMGENBUFF_EN = 1'b1, Bit[3]:D2A_RLD_ELECTRODE_EN = 1'b1
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_2; no_of_bytes == 1;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    reg_ana_en_0_2 = top_test_cfg.data[0];    
    
    //Section 0: 0xC4 : Bit[2]:D2A_RLD_EN = 1'b1
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_3; no_of_bytes == 1;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    reg_ana_en_0_3 = top_test_cfg.data[0];    

    //Section 0: 0xC5 : Bit[7:0]:D2A_EEFLNA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_4; no_of_bytes == 1;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    reg_ana_en_0_4 = top_test_cfg.data[0];    
    
    //Section 0: 0xC6 : Bit[15:8]:D2A_EEFLNA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_5; no_of_bytes == 1;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    reg_ana_en_0_5 = top_test_cfg.data[0];    
    
    //Section 0: 0xC9 : Bit[7:0]:D2A_EEFPGA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_8; no_of_bytes == 1;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    reg_ana_en_0_8 = top_test_cfg.data[0];    
    
    //Section 0: 0xCA : Bit[7:0]:D2A_EEFPGA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_9; no_of_bytes == 1;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    reg_ana_en_0_9 = top_test_cfg.data[0];    
    
    //Section 0: 0xCA : Bit[7:0]:D2A_EEFPGA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_13; no_of_bytes == 1;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    reg_ana_en_0_13 = top_test_cfg.data[0];    
    
    //Section 0: 0xCA : Bit[7:0]:D2A_EEFPGA_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_0_14; no_of_bytes == 1;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    reg_ana_en_0_14 = top_test_cfg.data[0];    
    
    `nnc_info("ANA_EN_SEC", "Changing ANA_EN Section to 1\n", UVM_LOW);
    
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_SEC_SEL_REG; no_of_bytes == 1; data[0] == 1;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    //Section 1: 0xC2 : Bit[7:0]:D2A_SDMEN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_0; no_of_bytes == 1;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    reg_ana_en_1_0 = top_test_cfg.data[0];    
    
    //Section 1: 0xC2 : Bit[7:0]:D2A_SDMEN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_1; no_of_bytes == 1;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    reg_ana_en_1_1 = top_test_cfg.data[0];    
    
    //Section 1: 0xC3 : Bit[15:8]:D2A_SDMEN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_2; no_of_bytes == 1;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    reg_ana_en_1_2 = top_test_cfg.data[0];    
    
    //Section 1: 0xC4 : Bit[7:0]:D2A_SDMBUFF_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_3; no_of_bytes == 1;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    reg_ana_en_1_3 = top_test_cfg.data[0];    
    
    //Section 1: 0xC5 : Bit[15:8]:D2A_SDMBUFF_EN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_4; no_of_bytes == 1;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    reg_ana_en_1_4 = top_test_cfg.data[0];    
    
    //Section 1: 0xC6 : Bit[7:0]:D2A_DCLOFFEN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_5; no_of_bytes == 1;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    reg_ana_en_1_5 = top_test_cfg.data[0];    
    
    //Section 1: 0xC7 : Bit[15:8]:D2A_DCLOFFEN = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_EN_REG_1_6; no_of_bytes == 1;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    reg_ana_en_1_6 = top_test_cfg.data[0];    
    
    //0x6C : Bit[0]:D2A_EN_TSC = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_TSC_CTRL_REG; no_of_bytes == 1;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    reg_tsc_ctrl = top_test_cfg.data[0];    
   
    end
endtask 

  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction
endclass : `TESTNAME

