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
  constraint c_atm_no { soft atm_no inside {[2:0]};};

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
    `ANALOG_SCOREBOARD_EN = 1'b1;
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
    #10000;

    //0x43 : Bit[0]:D2A_BIST_EN = 0,Bit[4:1]:D2A_BIST_SEL = 4'b1111
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_ENABLE_REG_3; no_of_bytes == 1; data[0] == 8'b0001_1110;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //0x40 : Bit[1]:D2A_OSC2MHZEN = 1, Bit[2]:D2A_PUMP_5V_EN_CH1 = 0, Bit[3]:D2A_PUMP_LDO_EN_CH1 = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_ENABLE_REG_0; no_of_bytes == 1; data[0] == 8'b0000_0010;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //0x41 : Bit[4]:D2A_VDAC_EN_CH1 = 0, Bit[3]:D2A_IDAC_EN_CH1 = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_ENABLE_REG_1; no_of_bytes == 1; data[0] == 8'b0000_0000;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //0x45 : Bit[7:0]:D2A_VDAC_DIN_CH1[7:0] = 8'b0000_0000
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_GEN_2_REG; no_of_bytes == 1; data[0] == 8'b0000_0000;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //0x46 : Bit[1:0]:D2A_VDAC_DIN_CH1[9:8] = 8'b0000_0000
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_GEN_3_REG; no_of_bytes == 1; data[0] == 8'b0000_0000;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //0x42 : Bit[4]:D2A_VDAC_EN_CH2 = 0, Bit[3]:D2A_IDAC_EN_CH2 = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_ENABLE_REG_2; no_of_bytes == 1; data[0] == 8'b0000_0000;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //0x47 : Bit[7:0]:D2A_VDAC_DIN_CH2[7:0] = 8'b0000_0000
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_GEN_4_REG; no_of_bytes == 1; data[0] == 8'b0000_0000;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //0x48 : Bit[1:0]:D2A_VDAC_DIN_CH2[9:8] = 8'b0000_0000
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_GEN_5_REG; no_of_bytes == 1; data[0] == 8'b0000_0000;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //0x4D 0: register control, 1: FSM control
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_TSC_EN_REG_SEL_REG; no_of_bytes == 1; data[0] == 8'b0000_0000;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    //0x4D bit[2]: D2A_VDAC8B_EN_CH1, bit[1]: TSC_COMP_EN_CH1, bit[0]:TSC_EN_CH1
     assert(top_test_cfg.randomize() with { reg_addr == `SOC_TSC_CTRL_REG; no_of_bytes == 1;  data[0] == 8'b0000_0000;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //force `SOC_TB.IOBUF_PAD[10:0] = 11'b0;
    //force `SOC_TB.ext_resetn = 1'b0;        
    // Enter ATM MODE
    // Enter ATM0 mode
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    force `SOC_TB.IOBUF_PAD[10:8] = 3'b000;
    force `SOC_TB.iopad_resetn = 1'b0;
    #100us;
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #100us;
    //force `SOC_TB.ext_resetn = 1'b0;
    //#200us;
    //force `SOC_TB.ext_resetn = 1'b1;
    //release `SOC_TB.IOBUF_PAD[10:0];  
    //#1ms;

    // Use external resetn (set LOW to HIGH )
    force `ANA_TOP.PMU_SW.DVDD = 1'b1; //in testmode LDO will not connected to DVDD so need provide external supply 1.8v
    //force `SOC_TB.iopad_resetn = 1'b0;
    #100000;
    force `SOC_TB.iopad_resetn = 1'b1;
    
    // ========================================================================
    // Before entering ATM mode, Disbale internal POR and clock
    // ========================================================================
    //stuck internal POR=1
    force `ANA_TOP.A2D_POR_DVDD = 1'b1;
    //disable internal clock
    //force `ANA_TOP.A2D_CLK2MHZ = 1'b0; // no need to force because hfosc_fixed_gnd_en =1 this take care stuck 0

    #1ms;

    #100000;
    if(`ANA_TOP.D2A_ATM0!==1'b1) `nnc_error("ATM0",$sformatf("Enter atm0 error!!!"));    
    if(`ANA_TOP.D2A_BIST_SEL!==4'b0000)`nnc_error("ATM0",$sformatf("D2A_BIST_SEL error, Real data:%b not match 4'b0000",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN!==1'b1)`nnc_error("ATM0",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC2MHZEN!==1'b0)`nnc_error("ATM0",$sformatf("D2A_OSC2MHZEN error, Real data:%b not match 1'b0",`ANA_TOP.D2A_OSC2MHZEN)); 
    #100000;    
    // Enter ATM1 mode
    force `SOC_TB.IOBUF_PAD[10:8] = 3'b001;
    #100000;  
    if(`ANA_TOP.D2A_ATM1!==1'b1) `nnc_error("ATM1",$sformatf("Enter atm1 error!!!"));          
    if(`ANA_TOP.D2A_BIST_SEL!==4'b0001)`nnc_error("ATM1",$sformatf("D2A_BIST_SEL error, Real data:%b not match 4'b0001",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN!==1'b1)`nnc_error("ATM1",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC2MHZEN!==1'b0)`nnc_error("ATM1",$sformatf("D2A_OSC2MHZEN error, Real data:%b not match 1'b0",`ANA_TOP.D2A_OSC2MHZEN)); 
    if(`ANA_TOP.D2A_TSC_EN_CH1!==1'b1)`nnc_error("ATM1",$sformatf("D2A_TSC_EN_CH1 error, Real data:%b not match 1'b0",`ANA_TOP.D2A_TSC_EN_CH1));
    #100000;    
    // Enter ATM2 mode
    force `SOC_TB.IOBUF_PAD[10:8] = 3'b010;
    #100000; 
    if(`ANA_TOP.D2A_ATM2!==1'b1) `nnc_error("ATM2",$sformatf("Enter atm2 error!!!"));         
    if(`ANA_TOP.D2A_BIST_SEL!==4'b0010)`nnc_error("ATM2",$sformatf("D2A_BIST_SEL error, Real data:%b not match 4'b0010",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN!==1'b1)`nnc_error("ATM2",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC2MHZEN!==1'b0)`nnc_error("ATM2",$sformatf("D2A_OSC2MHZEN error, Real data:%b not match 1'b0",`ANA_TOP.D2A_OSC2MHZEN)); 
    if(`ANA_TOP.D2A_PUMP_5V_EN_CH1!==1'b1)`nnc_error("ATM2",$sformatf("D2A_PUMP_5V_EN_CH1 error, Real data:%b not match 1'b1",`ANA_TOP.D2A_PUMP_5V_EN_CH1));
    if(`ANA_TOP.D2A_PUMP_LDO_EN_CH1!==1'b1)`nnc_error("ATM2",$sformatf("D2A_PUMP_LDO_EN_CH1 error, Real data:%b not match 1'b1",`ANA_TOP.D2A_PUMP_LDO_EN_CH1));
    #100000;           
    // Enter ATM3 mode
    force `SOC_TB.IOBUF_PAD[10:8] = 3'b011;
    #100000; 
    if(`ANA_TOP.D2A_ATM3!==1'b1) `nnc_error("ATM3",$sformatf("Enter atm3 error!!!"));             
    if(`ANA_TOP.D2A_BIST_SEL!==4'b0011)`nnc_error("ATM3",$sformatf("D2A_BIST_SEL error, Real data:%b not match 4'b0011",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN!==1'b1)`nnc_error("ATM3",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC2MHZEN!==1'b1)`nnc_error("ATM3",$sformatf("D2A_OSC2MHZEN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_OSC2MHZEN)); 
    #100000;         
    // Enter ATM4 mode
    force `SOC_TB.IOBUF_PAD[10:8] = 3'b100;
    #100000; 
    if(`ANA_TOP.D2A_ATM4!==1'b1) `nnc_error("ATM4",$sformatf("Enter atm4 error!!!"));          
    if(`ANA_TOP.D2A_BIST_SEL!==4'b0100)`nnc_error("ATM4",$sformatf("D2A_BIST_SEL error, Real data:%b not match 4'b0100",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN!==1'b1)`nnc_error("ATM4",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC2MHZEN!==1'b0)`nnc_error("ATM4",$sformatf("D2A_OSC2MHZEN error, Real data:%b not match 1'b0",`ANA_TOP.D2A_OSC2MHZEN)); 
    if(`ANA_TOP.D2A_VDAC_EN_CH1!==1'b1)`nnc_error("ATM4",$sformatf("D2A_VDAC_EN_CH1 error, Real data:%b not match 1'b1",`ANA_TOP.D2A_VDAC_EN_CH1)); 
    //if(`ANA_TOP.D2A_VDAC_DIN_CH1[9:0]!==10'b11_1111_1111)`nnc_error("ATM4",$sformatf("D2A_VDAC_DIN_CH1[9:0] error, Real data:%b not match 10'b11_1111_1111",`ANA_TOP.D2A_VDAC_DIN_CH1[9:0]));  
    #100000;     
    // Enter ATM5 mode
    force `SOC_TB.IOBUF_PAD[10:8] = 3'b101;
    #100000;
    if(`ANA_TOP.D2A_ATM5!==1'b1) `nnc_error("ATM5",$sformatf("Enter atm5 error!!!"));        
    if(`ANA_TOP.D2A_BIST_SEL!==4'b0101)`nnc_error("ATM5",$sformatf("D2A_BIST_SEL error, Real data:%b not match 4'b0101",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN!==1'b1)`nnc_error("ATM5",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC2MHZEN!==1'b0)`nnc_error("ATM5",$sformatf("D2A_OSC2MHZEN error, Real data:%b not match 1'b0",`ANA_TOP.D2A_OSC2MHZEN)); 
    if(`ANA_TOP.D2A_VDAC_EN_CH2!==1'b1)`nnc_error("ATM5",$sformatf("D2A_VDAC_EN_CH2 error, Real data:%b not match 1'b1",`ANA_TOP.D2A_VDAC_EN_CH2)); 
    //if(`ANA_TOP.D2A_VDAC_DIN_CH2[9:0]!==10'b11_1111_1111)`nnc_error("ATM5",$sformatf("D2A_VDAC_DIN_CH2[9:0] error, Real data:%b not match 10'b11_1111_1111",`ANA_TOP.D2A_VDAC_DIN_CH2[9:0])); 
    #100000;          
    // Enter ATM6 mode
    force `SOC_TB.IOBUF_PAD[10:8] = 3'b110;
    #100000;
    if(`ANA_TOP.D2A_ATM6!==1'b1) `nnc_error("ATM6",$sformatf("Enter atm6 error!!!"));          
    if(`ANA_TOP.D2A_BIST_SEL!==4'b0110)`nnc_error("ATM6",$sformatf("D2A_BIST_SEL error, Real data:%b not match 4'b0110",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN!==1'b1)`nnc_error("ATM6",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC2MHZEN!==1'b0)`nnc_error("ATM6",$sformatf("D2A_OSC2MHZEN error, Real data:%b not match 1'b0",`ANA_TOP.D2A_OSC2MHZEN)); 
    if(`ANA_TOP.D2A_IDAC_EN_CH1!==1'b1)`nnc_error("ATM6",$sformatf("D2A_IDAC_EN_CH1 error, Real data:%b not match 1'b1",`ANA_TOP.D2A_IDAC_EN_CH1)); 
    if(`ANA_TOP.D2A_TSC_EN_CH1!==1'b1)`nnc_error("ATM6",$sformatf("D2A_TSC_EN_CH1 error, Real data:%b not match 1'b1",`ANA_TOP.D2A_TSC_EN_CH1));
    if(`ANA_TOP.D2A_TSC_COMP_EN_CH1!==1'b1)`nnc_error("ATM6",$sformatf("D2A_TSC_COMP_EN_CH1 error, Real data:%b not match 1'b1",`ANA_TOP.D2A_TSC_COMP_EN_CH1));
    if(`ANA_TOP.D2A_VDAC8B_EN_CH1!==1'b1)`nnc_error("ATM6",$sformatf("D2A_VDAC8B_EN_CH1 error, Real data:%b not match 1'b1",`ANA_TOP.D2A_VDAC8B_EN_CH1));
    #100000;    
    // Enter ATM7 mode
    force `SOC_TB.IOBUF_PAD[10:8] = 3'b111;
    #100000;
    if(`ANA_TOP.D2A_ATM7!==1'b1) `nnc_error("ATM7",$sformatf("Enter atm7 error!!!"));        
    if(`ANA_TOP.D2A_BIST_SEL!==4'b0111)`nnc_error("ATM7",$sformatf("D2A_BIST_SEL error, Real data:%b not match 4'b0111",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN!==1'b1)`nnc_error("ATM7",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC2MHZEN!==1'b0)`nnc_error("ATM7",$sformatf("D2A_OSC2MHZEN error, Real data:%b not match 1'b0",`ANA_TOP.D2A_OSC2MHZEN)); 
    if(`ANA_TOP.D2A_IDAC_EN_CH2!==1'b1)`nnc_error("ATM7",$sformatf("D2A_IDAC_EN_CH2 error, Real data:%b not match 1'b1",`ANA_TOP.D2A_IDAC_EN_CH2)); 
    #100000;    

    // ---------------------------------------------------- 
    // Part I:  Change fixed value when ATM_HC_SEL 1
    // ----------------------------------------------------
`ifndef MIX_SIM_EN
    force `SOC_TB.iopad_resetn = 1'b0; //force `ANA_TOP.PMU_SW.CHIP_EN = 0;
`endif    
    //force `SOC_TB.VDD_DIG = 0;
    
    // Enter NORMAL MODE
    #1000ns;    
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b00;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #150us;

`ifndef MIX_SIM_EN
    force `SOC_TB.iopad_resetn = 1'b1; //force `ANA_TOP.PMU_SW.CHIP_EN = 1;
`endif
    //force `SOC_TB.VDD_DIG = 1;
    #1ms; //#5ms;  
     
    //Enable SOC_ATM_HC_SEL to make fixed signal values control by spi
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ATM_HC_SEL; no_of_bytes == 1; data[0] == 8'b0000_0011;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    #10000;
    //0x43 : Bit[0]:D2A_BIST_EN = 0,Bit[4:1]:D2A_BIST_SEL = 4'b1111
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_ENABLE_REG_3; no_of_bytes == 1; data[0] == 8'b0001_1110;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //0x40 : Bit[1]:D2A_OSC2MHZEN = 1,Bit[2]:D2A_PUMP_5V_EN_CH1 = 0, Bit[3]:D2A_PUMP_LDO_EN_CH1 = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_ENABLE_REG_0; no_of_bytes == 1; data[0] == 8'b0000_0010;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //0x41 : Bit[4]:D2A_VDAC_EN_CH1 = 0, Bit[3]:D2A_IDAC_EN_CH1 = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_ENABLE_REG_1; no_of_bytes == 1; data[0] == 8'b0000_0000;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //0x45 : Bit[7:0]:D2A_VDAC_DIN_CH1[7:0] = 8'b0000_0000
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_GEN_2_REG; no_of_bytes == 1; data[0] == 8'b1010_1010;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //0x46 : Bit[1:0]:D2A_VDAC_DIN_CH1[9:8] = 8'b0000_0000
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_GEN_3_REG; no_of_bytes == 1; data[0] == 8'b0000_0010;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //0x42 : Bit[4]:D2A_VDAC_EN_CH2 = 0, Bit[3]:D2A_IDAC_EN_CH2 = 0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_ENABLE_REG_2; no_of_bytes == 1; data[0] == 8'b0000_0000;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //0x47 : Bit[7:0]:D2A_VDAC_DIN_CH2[7:0] = 8'b0000_0000
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_GEN_4_REG; no_of_bytes == 1; data[0] == 8'b1010_1010;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //0x48 : Bit[1:0]:D2A_VDAC_DIN_CH2[9:8] = 8'b0000_0000
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_ANA_GEN_5_REG; no_of_bytes == 1; data[0] == 8'b0000_0010;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //0x4D 0: register control, 1: FSM control
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_TSC_EN_REG_SEL_REG; no_of_bytes == 1; data[0] == 8'b0000_1000;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    //0x4D bit[2]: D2A_VDAC8B_EN_CH1, bit[1]: TSC_COMP_EN_CH1, bit[0]:TSC_EN_CH1
     assert(top_test_cfg.randomize() with { reg_addr == `SOC_TSC_CTRL_REG; no_of_bytes == 1;  data[0] == 8'b0000_0001;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
 
    `ifdef POSTLAYOUT_PG 
       force `SOC_TB.IOBUF_PAD[10:0] = 16'b0;   //force and release in order to avoid x propogation on D2A_* signals in postscan pg/postlayout pg sim 
    `endif
    #200us;
    // Enter ATM MODE
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #200us;

    `ifdef POSTLAYOUT_PG
      release `SOC_TB.IOBUF_PAD[10:0]; //force and release in order to avoid x propogation on D2A_* signals in postscan pg/postlayout pg sim
    `endif

     
    // Enter ATM0 mode
    force `SOC_TB.IOBUF_PAD[10:8] = 3'b000;
    #100000;
    if(`ANA_TOP.D2A_ATM0!==1'b0) `nnc_error("ATM0",$sformatf("Enter atm0 error!!!"));
    if(`ANA_TOP.D2A_BIST_SEL!==4'b1111)`nnc_error("ATM0",$sformatf("D2A_BIST_SEL error, Real data:%b not match 4'b1111",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN!==1'b0)`nnc_error("ATM0",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b0",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC2MHZEN!==1'b1)`nnc_error("ATM0",$sformatf("D2A_OSC2MHZEN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_OSC2MHZEN)); 
    #100000;    
    // Enter ATM1 mode
    force `SOC_TB.IOBUF_PAD[10:8] = 3'b001;
    #100000;    
    if(`ANA_TOP.D2A_ATM1!==1'b0) `nnc_error("ATM1",$sformatf("Enter atm1 error!!!"));    
    if(`ANA_TOP.D2A_BIST_SEL!==4'b1111)`nnc_error("ATM1",$sformatf("D2A_BIST_SEL error, Real data:%b not match 4'b1111",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN!==1'b0)`nnc_error("ATM1",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b0",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC2MHZEN!==1'b1)`nnc_error("ATM1",$sformatf("D2A_OSC2MHZEN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_OSC2MHZEN)); 
    #100000;    
    // Enter ATM2 mode
    force `SOC_TB.IOBUF_PAD[10:8] = 3'b010;
    #100000;
    if(`ANA_TOP.D2A_ATM2!==1'b0) `nnc_error("ATM2",$sformatf("Enter atm2 error!!!"));     
    if(`ANA_TOP.D2A_BIST_SEL!==4'b1111)`nnc_error("ATM2",$sformatf("D2A_BIST_SEL error, Real data:%b not match 4'b1111",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN!==1'b0)`nnc_error("ATM2",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b0",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC2MHZEN!==1'b1)`nnc_error("ATM2",$sformatf("D2A_OSC2MHZEN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_OSC2MHZEN)); 
    if(`ANA_TOP.D2A_PUMP_5V_EN_CH1!==1'b0)`nnc_error("ATM2",$sformatf("D2A_PUMP_5V_EN_CH1 error, Real data:%b not match 1'b0",`ANA_TOP.D2A_PUMP_5V_EN_CH1));
    if(`ANA_TOP.D2A_PUMP_LDO_EN_CH1!==1'b0)`nnc_error("ATM2",$sformatf("D2A_PUMP_LDO_EN_CH1 error, Real data:%b not match 1'b0",`ANA_TOP.D2A_PUMP_LDO_EN_CH1));
    #100000;           
    // Enter ATM3 mode
    force `SOC_TB.IOBUF_PAD[10:8] = 3'b011;
    #100000;  
    if(`ANA_TOP.D2A_ATM3!==1'b0) `nnc_error("ATM3",$sformatf("Enter atm3 error!!!"));      
    if(`ANA_TOP.D2A_BIST_SEL!==4'b1111)`nnc_error("ATM3",$sformatf("D2A_BIST_SEL error, Real data:%b not match 4'b1111",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN!==1'b0)`nnc_error("ATM3",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b0",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC2MHZEN!==1'b1)`nnc_error("ATM3",$sformatf("D2A_OSC2MHZEN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_OSC2MHZEN));  
    #100000;        
    // Enter ATM4 mode
    force `SOC_TB.IOBUF_PAD[10:8] = 3'b100;
    #100000;   
    if(`ANA_TOP.D2A_ATM4!==1'b0) `nnc_error("ATM4",$sformatf("Enter atm4 error!!!"));    
    if(`ANA_TOP.D2A_BIST_SEL!==4'b1111)`nnc_error("ATM4",$sformatf("D2A_BIST_SEL error, Real data:%b not match 4'b1111",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN!==1'b0)`nnc_error("ATM4",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b0",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC2MHZEN!==1'b1)`nnc_error("ATM4",$sformatf("D2A_OSC2MHZEN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_OSC2MHZEN)); 
    if(`ANA_TOP.D2A_VDAC_EN_CH1!==1'b0)`nnc_error("ATM4",$sformatf("D2A_VDAC_EN_CH1 error, Real data:%b not match 1'b0",`ANA_TOP.D2A_VDAC_EN_CH1)); 
    if(`ANA_TOP.D2A_VDAC_DIN_CH1!==10'b10_1010_1010)`nnc_error("ATM4",$sformatf("D2A_VDAC_DIN_CH1 error, Real data:%b not match 10'b10_1010_1010",`ANA_TOP.D2A_VDAC_DIN_CH1)); 
    #100000;      
    // Enter ATM5 mode
    force `SOC_TB.IOBUF_PAD[10:8] = 3'b101;
    #100000;
    if(`ANA_TOP.D2A_ATM5!==1'b0) `nnc_error("ATM5",$sformatf("Enter atm5 error!!!"));    
    if(`ANA_TOP.D2A_BIST_SEL!==4'b1111)`nnc_error("ATM5",$sformatf("D2A_BIST_SEL error, Real data:%b not match 4'b1111",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN!==1'b0)`nnc_error("ATM5",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b0",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC2MHZEN!==1'b1)`nnc_error("ATM5",$sformatf("D2A_OSC2MHZEN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_OSC2MHZEN)); 
    if(`ANA_TOP.D2A_VDAC_EN_CH2!==1'b0)`nnc_error("ATM5",$sformatf("D2A_VDAC_EN_CH2 error, Real data:%b not match 1'b0",`ANA_TOP.D2A_VDAC_EN_CH2)); 
    if(`ANA_TOP.D2A_VDAC_DIN_CH2!==10'b10_1010_1010)`nnc_error("ATM5",$sformatf("D2A_VDAC_DIN_CH2 error, Real data:%b not match 10'b10_1010_1010",`ANA_TOP.D2A_VDAC_DIN_CH2)); 
    #100000;          
    // Enter ATM6 mode
    force `SOC_TB.IOBUF_PAD[10:8] = 3'b110;
    #100000;
    if(`ANA_TOP.D2A_ATM6!==1'b0) `nnc_error("ATM6",$sformatf("Enter atm6 error!!!"));     
    if(`ANA_TOP.D2A_BIST_SEL!==4'b1111)`nnc_error("ATM6",$sformatf("D2A_BIST_SEL error, Real data:%b not match 4'b1111",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN!==1'b0)`nnc_error("ATM6",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b0",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC2MHZEN!==1'b1)`nnc_error("ATM6",$sformatf("D2A_OSC2MHZEN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_OSC2MHZEN)); 
    if(`ANA_TOP.D2A_IDAC_EN_CH1!==1'b0)`nnc_error("ATM6",$sformatf("D2A_VDAC_EN_CH1 error, Real data:%b not match 1'b",`ANA_TOP.D2A_IDAC_EN_CH1));
    if(`ANA_TOP.D2A_TSC_EN_CH1!==1'b1)`nnc_error("ATM6",$sformatf("D2A_TSC_EN_CH1 error, Real data:%b not match 1'b1",`ANA_TOP.D2A_TSC_EN_CH1));
    if(`ANA_TOP.D2A_TSC_COMP_EN_CH1!==1'b0)`nnc_error("ATM6",$sformatf("D2A_TSC_COMP_EN_CH1 error, Real data:%b not match 1'b1",`ANA_TOP.D2A_TSC_COMP_EN_CH1));
    if(`ANA_TOP.D2A_VDAC8B_EN_CH1!==1'b0)`nnc_error("ATM6",$sformatf("D2A_VDAC8B_EN_CH1 error, Real data:%b not match 1'b1",`ANA_TOP.D2A_VDAC8B_EN_CH1)); 
    #100000;    
    // Enter ATM7 mode
    force `SOC_TB.IOBUF_PAD[10:8] = 3'b111;
    #100000;
    if(`ANA_TOP.D2A_ATM7!==1'b0) `nnc_error("ATM7",$sformatf("Enter atm7 error!!!"));    
    if(`ANA_TOP.D2A_BIST_SEL!==4'b1111)`nnc_error("ATM7",$sformatf("D2A_BIST_SEL error, Real data:%b not match 4'b1111",`ANA_TOP.D2A_BIST_SEL)); 
    if(`ANA_TOP.D2A_BIST_EN!==1'b0)`nnc_error("ATM7",$sformatf("D2A_BIST_EN error, Real data:%b not match 1'b0",`ANA_TOP.D2A_BIST_EN)); 
    if(`ANA_TOP.D2A_OSC2MHZEN!==1'b1)`nnc_error("ATM7",$sformatf("D2A_OSC2MHZEN error, Real data:%b not match 1'b1",`ANA_TOP.D2A_OSC2MHZEN)); 
    if(`ANA_TOP.D2A_IDAC_EN_CH2!==1'b0)`nnc_error("ATM7",$sformatf("D2A_IDAC_EN_CH2 error, Real data:%b not match 1'b0",`ANA_TOP.D2A_IDAC_EN_CH2)); 
             
`endif
    end
  endtask  

  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction
endclass : `TESTNAME

