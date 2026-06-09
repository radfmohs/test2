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
`define TESTNAME soc_pinmux_debugmode_atm_trim_otp_test
`define TESTCFG soc_pinmux_debugmode_atm_trim_otp_test_cfg

class `TESTCFG extends soc_base_test_cfg;

  `nnc_object_utils(`TESTCFG)

  // -----------------------------------------------
  // Adding your new varialbles in config test
  // -----------------------------------------------
  rand logic [7:0] data[256];
  rand logic [7:0] reg_addr;
  rand int    no_of_bytes;   
  logic [7:0] rd_data[256];
  logic [14:0] atm;
  static logic [7:0] save_trim_wdata[15];
  rand logic [7:0] otp_addr;  
  rand logic [7:0] otp_data;  
  rand logic [7:0] pads;
  rand bit         trim_tag_prepare_en;
  rand logic [4:0] atm_no;
  // -----------------------------------------------
  // End of decalration of new variables 
  // -----------------------------------------------

  function new (string name = "soc_pinmux_debugmode_atm_trim_otp_test_cfg");
    super.new(name);
    
  endfunction: new

  // -----------------------------------------------
  // Adding constraints of randomization
  // -----------------------------------------------
  // testmode_sel[1:0] : 00-Normal mode, 01: Scanmode, 10: BIST mode, 11 atm0/1/2/3/4
  // constraint c_testmode_sel { soft testmode_sel == 2'b01; } 

  constraint c_atm_no { soft atm_no inside {[5'b00000:5'b01110]};};

  constraint c_trim_tag_prepare_en { soft trim_tag_prepare_en inside {[1:0]};};

  constraint c_no_of_bytes  { soft no_of_bytes == 2; }

  // testmode_sel[1:0] : 00-Normal mode, 01: Scanmode, 10: BIST mode, 11 atm0/1/2/3/4
  constraint c_testmode_sel { soft testmode_sel == 2'b00; }

  constraint c_altf_sel     { soft altf_sel == 2'b00; }

  constraint c_hfosc_variation        { soft hfosc_variation inside {[100:100]}; } // 90% - 110%

  constraint c_io_model_check_off { io_model_check_off == 1'b1; }  
  // spimode_sel[1:0] :  
/*  
  constraint c_high_clk { solve otp_tVPP before high_clk;
                          high_clk inside {[6:(5+otp_tVPP)]}; 
                        } 

  constraint c_low_clk  { solve otp_tVPP before low_clk;
                          solve otp_tPGM before low_clk; 
                          low_clk inside {[(7+otp_tVPP+(otp_tPGM+4)*12):(6+(2*otp_tVPP)+(otp_tPGM+4)*12)]}; 
                        } 
*/
  constraint c_ext_clk_en             { soft ext_clk_en == 1;}     //1: enable 2MHZ external clock, 0: enable 2MHZ internal osc model

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
  
  // VIP and TB config class if have
  `TESTCFG top_test_cfg;
  
  function new(string name, nnc_component parent); 
    super.new(name, parent);
    top_test_cfg = new();
  endfunction

  function void build_phase(nnc_phase phase);
    super.build_phase(phase);
  endfunction : build_phase

  task pre_reset_phase(nnc_phase phase);
    super.pre_reset_phase(phase);

    phase.raise_objection(this);
    //top_test_cfg.high_clk.rand_mode(0);
    //top_test_cfg.low_clk.rand_mode(0);

    assert(top_test_cfg.randomize() with {altf_sel == 0;});

    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;

    `DUT_IF.altf_sel = top_test_cfg.altf_sel;

    // Select internal/external clock sources
    `DUT_IF.ext_clk_en = top_test_cfg.ext_clk_en;             // 1: external EXT_2MHZ will be driven to SOC from OSC model

    // enable to fix 1'b0 to internal clk
    `DUT_IF.hfosc_fixed_gnd_en = top_test_cfg.hfosc_fixed_gnd_en;         // 1: disble pin to 2MHZ internal osc model, 0:enable pin to internal 2MHZ osc model

    // enable to fix 1'b0 to ext clk
    `DUT_IF.ext_hfosc_fixed_gnd_en = top_test_cfg.ext_hfosc_fixed_gnd_en; // 1: disble pin to 2MHZ exeternal osc model, 0:enable pin to exeternal 2MHZ osc model

    // Clock variation of HFOSC
    `DUT_IF.hfosc_variation = top_test_cfg.hfosc_variation;

    // ==================
    // Scoreboard enables
    // ==================
    `SPI_SCB_EN =                   1'b0;
    `ANALOG_SCOREBOARD_EN =         1'b0;
    `WAVEGEN_SCB_DRV_0_EN =         1'b0;
    `WAVEGEN_SHORT_DETECT_SCB_EN =  1'b0; 
    //`PINMUX_SCOREBOARD_EN =         1'b0;
   
    phase.drop_objection(this); 
  endtask

  virtual task main_phase(nnc_phase phase);
    phase.raise_objection(this);

    `nnc_info("SOC_TEST", "soc_pinmux_debugmode_atm_trim_otp_test start", NNC_LOW)
    // ----------------------------------------------------------------------------------
    // Please add your code of your test here
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
    
    // ========================================================================
    // Before entering ATM mode, Disbale internal POR and clock
    // ========================================================================
   `nnc_info("Disable internal POR and clock", "Disable internal POR and clock", UVM_LOW);
   //force `SOC_TB.VDD_DIG = 1'b0;

    assert(top_test_cfg.randomize() with { testmode_sel == 2'b11;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b00000; 
    force `SOC_TOP.IOBUF_PAD[8:1] = $random(0);
    //#100us;
    #1ms;
   
    //`nnc_info("Enable internal POR and clock", "Enable internal POR and clock", UVM_LOW);
    //force `SOC_TB.VDD_DIG = 1'b1;
 
    //force `SOC_TB.ext_resetn = 1'b0;
    //#1000
    //force `SOC_TB.ext_resetn = 1'b1;
    //#1ms
  
    // =======================================
    // ATM0 Operation (Step 1) - Save BG_TRIM
    // =======================================
  
    `uvm_info("ENTER ATM",$sformatf("Enter ATM0 Operation"),NNC_LOW)
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b00000; 
    force `SOC_TOP.IOBUF_PAD[8:1] = $random(0);
    #100us

    top_test_cfg.save_trim_wdata[0] = {`SOC_TOP.IOBUF_PAD[8],`SOC_TOP.IOBUF_PAD[7], `SOC_TOP.IOBUF_PAD[6], `SOC_TOP.IOBUF_PAD[5], `SOC_TOP.IOBUF_PAD[4], `SOC_TOP.IOBUF_PAD[3], `SOC_TOP.IOBUF_PAD[2], `SOC_TOP.IOBUF_PAD[1]}; 
    `nnc_info("ATM0",$sformatf("D2A_BG_TRIM = %8b",top_test_cfg.save_trim_wdata[0]), NNC_LOW) 

    top_test_cfg.atm = {`DIG_TOP.u_pinmux.ATM0,`DIG_TOP.u_pinmux.ATM1,`DIG_TOP.u_pinmux.ATM2,`DIG_TOP.u_pinmux.ATM3,`DIG_TOP.u_pinmux.ATM4,`DIG_TOP.u_pinmux.ATM5,`DIG_TOP.u_pinmux.ATM6,`DIG_TOP.u_pinmux.ATM7,`DIG_TOP.u_pinmux.ATM8,`DIG_TOP.u_pinmux.ATM9,`DIG_TOP.u_pinmux.ATM10,`DIG_TOP.u_pinmux.ATM11,`DIG_TOP.u_pinmux.ATM12,`DIG_TOP.u_pinmux.ATM13,`DIG_TOP.u_pinmux.ATM14};
    
    // Checking ATM
    if (top_test_cfg.atm !== (15'b100_0000_0000_0000 >> `SOC_TOP.IOBUF_PAD[14:10]))
      begin
        `nnc_error("ATM0", $sformatf("ATM[0:14] = %b is not as expectation of ATM = %b", top_test_cfg.atm, (15'b100_0000_0000_0000 >> `SOC_TOP.IOBUF_PAD[14:10])))
      end   
   
    // ===================================
    // ATM1 Operation - BGBUFFER_TRIM
    // ===================================
    `uvm_info("ENTER ATM",$sformatf("Enter ATM1 Operation"),NNC_LOW) 
       
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b00001; 
    force `SOC_TOP.IOBUF_PAD[8:1] = $random;
    #100us

    top_test_cfg.save_trim_wdata[1] = {`SOC_TOP.IOBUF_PAD[8],`SOC_TOP.IOBUF_PAD[7], `SOC_TOP.IOBUF_PAD[6], `SOC_TOP.IOBUF_PAD[5], `SOC_TOP.IOBUF_PAD[4], `SOC_TOP.IOBUF_PAD[3], `SOC_TOP.IOBUF_PAD[2], `SOC_TOP.IOBUF_PAD[1]};  
    `nnc_info("ATM1",$sformatf("D2A_IREF_TRIM = %8b", top_test_cfg.save_trim_wdata[1]), NNC_LOW) 

    top_test_cfg.atm = {`DIG_TOP.u_pinmux.ATM0,`DIG_TOP.u_pinmux.ATM1,`DIG_TOP.u_pinmux.ATM2,`DIG_TOP.u_pinmux.ATM3,`DIG_TOP.u_pinmux.ATM4,`DIG_TOP.u_pinmux.ATM5,`DIG_TOP.u_pinmux.ATM6,`DIG_TOP.u_pinmux.ATM7,`DIG_TOP.u_pinmux.ATM8,`DIG_TOP.u_pinmux.ATM9,`DIG_TOP.u_pinmux.ATM10,`DIG_TOP.u_pinmux.ATM11,`DIG_TOP.u_pinmux.ATM12,`DIG_TOP.u_pinmux.ATM13,`DIG_TOP.u_pinmux.ATM14};
    
    // Checking ATM
    if (top_test_cfg.atm !== (15'b100_0000_0000_0000 >> `SOC_TOP.IOBUF_PAD[14:10]))
      begin
        `nnc_error("ATM1", $sformatf("ATM[0:14] = %b is not as expectation of ATM = %b", top_test_cfg.atm, (15'b100_0000_0000_0000 >> `SOC_TOP.IOBUF_PAD[14:10])))
      end   

    // =====================================================================
    // ATM2 Operation - IREF_TRIM
    // =====================================================================
    `uvm_info("ENTER ATM",$sformatf("Enter ATM2 Operation"),NNC_LOW) 

    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b00010; 
    force `SOC_TOP.IOBUF_PAD[8:1] = $random;
    #100us

    top_test_cfg.save_trim_wdata[2] = {`SOC_TOP.IOBUF_PAD[8],`SOC_TOP.IOBUF_PAD[7], `SOC_TOP.IOBUF_PAD[6], `SOC_TOP.IOBUF_PAD[5], `SOC_TOP.IOBUF_PAD[4], `SOC_TOP.IOBUF_PAD[3], `SOC_TOP.IOBUF_PAD[2], `SOC_TOP.IOBUF_PAD[1]};  
    `nnc_info("ATM2",$sformatf("D2A_IREF_TRIM = %8b", top_test_cfg.save_trim_wdata[2]), NNC_LOW)

    top_test_cfg.atm = {`DIG_TOP.u_pinmux.ATM0,`DIG_TOP.u_pinmux.ATM1,`DIG_TOP.u_pinmux.ATM2,`DIG_TOP.u_pinmux.ATM3,`DIG_TOP.u_pinmux.ATM4,`DIG_TOP.u_pinmux.ATM5,`DIG_TOP.u_pinmux.ATM6,`DIG_TOP.u_pinmux.ATM7,`DIG_TOP.u_pinmux.ATM8,`DIG_TOP.u_pinmux.ATM9,`DIG_TOP.u_pinmux.ATM10,`DIG_TOP.u_pinmux.ATM11,`DIG_TOP.u_pinmux.ATM12,`DIG_TOP.u_pinmux.ATM13,`DIG_TOP.u_pinmux.ATM14};
    
    // Checking ATM
    if (top_test_cfg.atm !== (15'b100_0000_0000_0000 >> `SOC_TOP.IOBUF_PAD[14:10]))
      begin
        `nnc_error("ATM2", $sformatf("ATM[0:14] = %b is not as expectation of ATM = %b", top_test_cfg.atm, (15'b100_0000_0000_0000 >> `SOC_TOP.IOBUF_PAD[14:10])))
      end   

    // ===================================
    // ATM3 Operation - LDO_TRIM 
    // ===================================
    `uvm_info("ENTER ATM",$sformatf("Enter ATM3 Operation"),NNC_LOW) 
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b00011; 
    force `SOC_TOP.IOBUF_PAD[8:1] = $random;
    #100us
    
    top_test_cfg.save_trim_wdata[3] = {`SOC_TOP.IOBUF_PAD[8],`SOC_TOP.IOBUF_PAD[7], `SOC_TOP.IOBUF_PAD[6], `SOC_TOP.IOBUF_PAD[5], `SOC_TOP.IOBUF_PAD[4], `SOC_TOP.IOBUF_PAD[3], `SOC_TOP.IOBUF_PAD[2], `SOC_TOP.IOBUF_PAD[1]};  
    `nnc_info("ATM3",$sformatf("D2A_CLDO1P8_TRIM = %8b", top_test_cfg.save_trim_wdata[3]), NNC_LOW)
    
    top_test_cfg.atm = {`DIG_TOP.u_pinmux.ATM0,`DIG_TOP.u_pinmux.ATM1,`DIG_TOP.u_pinmux.ATM2,`DIG_TOP.u_pinmux.ATM3,`DIG_TOP.u_pinmux.ATM4,`DIG_TOP.u_pinmux.ATM5,`DIG_TOP.u_pinmux.ATM6,`DIG_TOP.u_pinmux.ATM7,`DIG_TOP.u_pinmux.ATM8,`DIG_TOP.u_pinmux.ATM9,`DIG_TOP.u_pinmux.ATM10,`DIG_TOP.u_pinmux.ATM11,`DIG_TOP.u_pinmux.ATM12,`DIG_TOP.u_pinmux.ATM13,`DIG_TOP.u_pinmux.ATM14};
    
    // Checking ATM
    if (top_test_cfg.atm !== (15'b100_0000_0000_0000 >> `SOC_TOP.IOBUF_PAD[14:10]))
      begin
        `nnc_error("ATM3", $sformatf("ATM[0:14] = %b is not as expectation of ATM = %b", top_test_cfg.atm, (15'b100_0000_0000_0000 >> `SOC_TOP.IOBUF_PAD[14:10])))
      end   

    // =====================================================================================================
    // ATM4 Operation - OSC_TRIM
    // =====================================================================================================
    `uvm_info("ENTER ATM",$sformatf("Enter ATM4 Operation"),NNC_LOW)
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b00100; 
    force `SOC_TOP.IOBUF_PAD[8:1] = $random;
    #100us

    top_test_cfg.save_trim_wdata[4] = {`SOC_TOP.IOBUF_PAD[8],`SOC_TOP.IOBUF_PAD[7], `SOC_TOP.IOBUF_PAD[6], `SOC_TOP.IOBUF_PAD[5], `SOC_TOP.IOBUF_PAD[4], `SOC_TOP.IOBUF_PAD[3], `SOC_TOP.IOBUF_PAD[2], `SOC_TOP.IOBUF_PAD[1]};  
    `nnc_info("ATM4",$sformatf("D2A_OSC8MHZ_TRIM = %8b", top_test_cfg.save_trim_wdata[4]), NNC_LOW)

    top_test_cfg.atm = {`DIG_TOP.u_pinmux.ATM0,`DIG_TOP.u_pinmux.ATM1,`DIG_TOP.u_pinmux.ATM2,`DIG_TOP.u_pinmux.ATM3,`DIG_TOP.u_pinmux.ATM4,`DIG_TOP.u_pinmux.ATM5,`DIG_TOP.u_pinmux.ATM6,`DIG_TOP.u_pinmux.ATM7,`DIG_TOP.u_pinmux.ATM8,`DIG_TOP.u_pinmux.ATM9,`DIG_TOP.u_pinmux.ATM10,`DIG_TOP.u_pinmux.ATM11,`DIG_TOP.u_pinmux.ATM12,`DIG_TOP.u_pinmux.ATM13,`DIG_TOP.u_pinmux.ATM14};

    // Checking ATM
    if (top_test_cfg.atm !== (15'b100_0000_0000_0000 >> `SOC_TOP.IOBUF_PAD[14:10]))
      begin
        `nnc_error("ATM4", $sformatf("ATM[0:14] = %b is not as expectation of ATM = %b", top_test_cfg.atm, (15'b100_0000_0000_0000 >> `SOC_TOP.IOBUF_PAD[14:10])))
      end   

    // ===================================
    // ATM5 Operation - TSC_TRIM
    // ===================================
    `uvm_info("ENTER ATM",$sformatf("Enter ATM5 Operation"),NNC_LOW) 
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b00101; 
    force `SOC_TOP.IOBUF_PAD[8:1] = $random;
    #100us

    top_test_cfg.save_trim_wdata[5] = {`SOC_TOP.IOBUF_PAD[8],`SOC_TOP.IOBUF_PAD[7], `SOC_TOP.IOBUF_PAD[6], `SOC_TOP.IOBUF_PAD[5], `SOC_TOP.IOBUF_PAD[4], `SOC_TOP.IOBUF_PAD[3], `SOC_TOP.IOBUF_PAD[2], `SOC_TOP.IOBUF_PAD[1]};  
    `nnc_info("ATM5",$sformatf("D2A_TSC_TRIM = %8b", top_test_cfg.save_trim_wdata[5]), NNC_LOW)

    top_test_cfg.atm = {`DIG_TOP.u_pinmux.ATM0,`DIG_TOP.u_pinmux.ATM1,`DIG_TOP.u_pinmux.ATM2,`DIG_TOP.u_pinmux.ATM3,`DIG_TOP.u_pinmux.ATM4,`DIG_TOP.u_pinmux.ATM5,`DIG_TOP.u_pinmux.ATM6,`DIG_TOP.u_pinmux.ATM7,`DIG_TOP.u_pinmux.ATM8,`DIG_TOP.u_pinmux.ATM9,`DIG_TOP.u_pinmux.ATM10,`DIG_TOP.u_pinmux.ATM11,`DIG_TOP.u_pinmux.ATM12,`DIG_TOP.u_pinmux.ATM13,`DIG_TOP.u_pinmux.ATM14};

    // Checking ATM
    if (top_test_cfg.atm !== (15'b100_0000_0000_0000 >> `SOC_TOP.IOBUF_PAD[14:10]))
      begin
        `nnc_error("ATM5", $sformatf("ATM[0:14] = %b is not as expectation of ATM = %b", top_test_cfg.atm, (15'b100_0000_0000_0000 >> `SOC_TOP.IOBUF_PAD[14:10])))
      end   
    
    // ===================================================
    // ATM6 Operation - IDAC
    // ===================================================
    `uvm_info("ENTER ATM",$sformatf("Enter ATM6 Operation"),NNC_LOW) 
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b00110; 
    force `SOC_TOP.IOBUF_PAD[8:1] = $random;
    #100us

    top_test_cfg.save_trim_wdata[6] = {`SOC_TOP.IOBUF_PAD[8],`SOC_TOP.IOBUF_PAD[7], `SOC_TOP.IOBUF_PAD[6], `SOC_TOP.IOBUF_PAD[5], `SOC_TOP.IOBUF_PAD[4], `SOC_TOP.IOBUF_PAD[3], `SOC_TOP.IOBUF_PAD[2], `SOC_TOP.IOBUF_PAD[1]};  
    `nnc_info("ATM6",$sformatf("D2A_DRIVER_CUR_TRIM = %8b", top_test_cfg.save_trim_wdata[6]), NNC_LOW)

    top_test_cfg.atm = {`DIG_TOP.u_pinmux.ATM0,`DIG_TOP.u_pinmux.ATM1,`DIG_TOP.u_pinmux.ATM2,`DIG_TOP.u_pinmux.ATM3,`DIG_TOP.u_pinmux.ATM4,`DIG_TOP.u_pinmux.ATM5,`DIG_TOP.u_pinmux.ATM6,`DIG_TOP.u_pinmux.ATM7,`DIG_TOP.u_pinmux.ATM8,`DIG_TOP.u_pinmux.ATM9,`DIG_TOP.u_pinmux.ATM10,`DIG_TOP.u_pinmux.ATM11,`DIG_TOP.u_pinmux.ATM12,`DIG_TOP.u_pinmux.ATM13,`DIG_TOP.u_pinmux.ATM14};
    
    // Checking ATM
    if (top_test_cfg.atm !== (15'b100_0000_0000_0000 >> `SOC_TOP.IOBUF_PAD[14:10]))
      begin
        `nnc_error("ATM6", $sformatf("ATM[0:14] = %b is not as expectation of ATM = %b", top_test_cfg.atm, (15'b100_0000_0000_0000 >> `SOC_TOP.IOBUF_PAD[14:10])))
      end   
     
    // ===================================
    // ATM7 Operation - D2A_TRIM0_SIG_SPARE
    // ===================================
    `uvm_info("ENTER ATM",$sformatf("Enter ATM7 Operation"),NNC_LOW)    
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b00111; 
    force `SOC_TOP.IOBUF_PAD[8:1] = $random;
    #100us

    top_test_cfg.save_trim_wdata[7] = {`SOC_TOP.IOBUF_PAD[8],`SOC_TOP.IOBUF_PAD[7], `SOC_TOP.IOBUF_PAD[6], `SOC_TOP.IOBUF_PAD[5], `SOC_TOP.IOBUF_PAD[4], `SOC_TOP.IOBUF_PAD[3], `SOC_TOP.IOBUF_PAD[2], `SOC_TOP.IOBUF_PAD[1]};  
    `nnc_info("ATM7",$sformatf("D2A_TRIM0_SIG_SPARE = %8b", top_test_cfg.save_trim_wdata[7]), NNC_LOW)

    top_test_cfg.atm = {`DIG_TOP.u_pinmux.ATM0,`DIG_TOP.u_pinmux.ATM1,`DIG_TOP.u_pinmux.ATM2,`DIG_TOP.u_pinmux.ATM3,`DIG_TOP.u_pinmux.ATM4,`DIG_TOP.u_pinmux.ATM5,`DIG_TOP.u_pinmux.ATM6,`DIG_TOP.u_pinmux.ATM7,`DIG_TOP.u_pinmux.ATM8,`DIG_TOP.u_pinmux.ATM9,`DIG_TOP.u_pinmux.ATM10,`DIG_TOP.u_pinmux.ATM11,`DIG_TOP.u_pinmux.ATM12,`DIG_TOP.u_pinmux.ATM13,`DIG_TOP.u_pinmux.ATM14};
    
    // Checking ATM
    if (top_test_cfg.atm !== (15'b100_0000_0000_0000 >> `SOC_TOP.IOBUF_PAD[14:10]))
      begin
        `nnc_error("ATM7", $sformatf("ATM[0:14] = %b is not as expectation of ATM = %b", top_test_cfg.atm, (15'b100_0000_0000_0000 >> `SOC_TOP.IOBUF_PAD[14:10])))
      end   
     
    // ===================================
    // ATM8 Operation - D2A_TRIM1_SIG_SPARE
    // ===================================
    `uvm_info("ENTER ATM",$sformatf("Enter ATM8 Operation"),NNC_LOW)    
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b01000; 
    force `SOC_TOP.IOBUF_PAD[8:1] = $random;
    #100us

    top_test_cfg.save_trim_wdata[8] = {`SOC_TOP.IOBUF_PAD[8],`SOC_TOP.IOBUF_PAD[7], `SOC_TOP.IOBUF_PAD[6], `SOC_TOP.IOBUF_PAD[5], `SOC_TOP.IOBUF_PAD[4], `SOC_TOP.IOBUF_PAD[3], `SOC_TOP.IOBUF_PAD[2], `SOC_TOP.IOBUF_PAD[1]};  
    `nnc_info("ATM8",$sformatf("D2A_TRIM1_SIG_SPARE = %8b", top_test_cfg.save_trim_wdata[8]), NNC_LOW)

    top_test_cfg.atm = {`DIG_TOP.u_pinmux.ATM0,`DIG_TOP.u_pinmux.ATM1,`DIG_TOP.u_pinmux.ATM2,`DIG_TOP.u_pinmux.ATM3,`DIG_TOP.u_pinmux.ATM4,`DIG_TOP.u_pinmux.ATM5,`DIG_TOP.u_pinmux.ATM6,`DIG_TOP.u_pinmux.ATM7,`DIG_TOP.u_pinmux.ATM8,`DIG_TOP.u_pinmux.ATM9,`DIG_TOP.u_pinmux.ATM10,`DIG_TOP.u_pinmux.ATM11,`DIG_TOP.u_pinmux.ATM12,`DIG_TOP.u_pinmux.ATM13,`DIG_TOP.u_pinmux.ATM14};
    
    // Checking ATM
    if (top_test_cfg.atm !== (15'b100_0000_0000_0000 >> `SOC_TOP.IOBUF_PAD[14:10]))
      begin
        `nnc_error("ATM8", $sformatf("ATM[0:14] = %b is not as expectation of ATM = %b", top_test_cfg.atm, (15'b100_0000_0000_0000 >> `SOC_TOP.IOBUF_PAD[14:10])))
      end   
     
    // ===================================
    // ATM9 Operation - D2A_TRIM2_SIG_SPARE
    // ===================================
    `uvm_info("ENTER ATM",$sformatf("Enter ATM9 Operation"),NNC_LOW)    
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b01001; 
    force `SOC_TOP.IOBUF_PAD[8:1] = $random;
    #100us

    top_test_cfg.save_trim_wdata[9] = {`SOC_TOP.IOBUF_PAD[8],`SOC_TOP.IOBUF_PAD[7], `SOC_TOP.IOBUF_PAD[6], `SOC_TOP.IOBUF_PAD[5], `SOC_TOP.IOBUF_PAD[4], `SOC_TOP.IOBUF_PAD[3], `SOC_TOP.IOBUF_PAD[2], `SOC_TOP.IOBUF_PAD[1]};  
    `nnc_info("ATM9",$sformatf("D2A_TRIM2_SIG_SPARE = %8b", top_test_cfg.save_trim_wdata[9]), NNC_LOW)

    top_test_cfg.atm = {`DIG_TOP.u_pinmux.ATM0,`DIG_TOP.u_pinmux.ATM1,`DIG_TOP.u_pinmux.ATM2,`DIG_TOP.u_pinmux.ATM3,`DIG_TOP.u_pinmux.ATM4,`DIG_TOP.u_pinmux.ATM5,`DIG_TOP.u_pinmux.ATM6,`DIG_TOP.u_pinmux.ATM7,`DIG_TOP.u_pinmux.ATM8,`DIG_TOP.u_pinmux.ATM9,`DIG_TOP.u_pinmux.ATM10,`DIG_TOP.u_pinmux.ATM11,`DIG_TOP.u_pinmux.ATM12,`DIG_TOP.u_pinmux.ATM13,`DIG_TOP.u_pinmux.ATM14};
    
    // Checking ATM
    if (top_test_cfg.atm !== (15'b100_0000_0000_0000 >> `SOC_TOP.IOBUF_PAD[14:10]))
      begin
        `nnc_error("ATM9", $sformatf("ATM[0:14] = %b is not as expectation of ATM = %b", top_test_cfg.atm, (15'b100_0000_0000_0000 >> `SOC_TOP.IOBUF_PAD[14:10])))
      end   
     
    // ===================================
    // ATM10 Operation - D2A_TRIM3_SIG_SPARE
    // ===================================
    `uvm_info("ENTER ATM",$sformatf("Enter ATM10 Operation"),NNC_LOW)    
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b01010; 
    force `SOC_TOP.IOBUF_PAD[8:1] = $random;
    #100us

    top_test_cfg.save_trim_wdata[10] = {`SOC_TOP.IOBUF_PAD[8],`SOC_TOP.IOBUF_PAD[7], `SOC_TOP.IOBUF_PAD[6], `SOC_TOP.IOBUF_PAD[5], `SOC_TOP.IOBUF_PAD[4], `SOC_TOP.IOBUF_PAD[3], `SOC_TOP.IOBUF_PAD[2], `SOC_TOP.IOBUF_PAD[1]};  
    `nnc_info("ATM10",$sformatf("D2A_TRIM3_SIG_SPARE = %8b", top_test_cfg.save_trim_wdata[10]), NNC_LOW)

    top_test_cfg.atm = {`DIG_TOP.u_pinmux.ATM0,`DIG_TOP.u_pinmux.ATM1,`DIG_TOP.u_pinmux.ATM2,`DIG_TOP.u_pinmux.ATM3,`DIG_TOP.u_pinmux.ATM4,`DIG_TOP.u_pinmux.ATM5,`DIG_TOP.u_pinmux.ATM6,`DIG_TOP.u_pinmux.ATM7,`DIG_TOP.u_pinmux.ATM8,`DIG_TOP.u_pinmux.ATM9,`DIG_TOP.u_pinmux.ATM10,`DIG_TOP.u_pinmux.ATM11,`DIG_TOP.u_pinmux.ATM12,`DIG_TOP.u_pinmux.ATM13,`DIG_TOP.u_pinmux.ATM14};
    
    // Checking ATM
    if (top_test_cfg.atm !== (15'b100_0000_0000_0000 >> `SOC_TOP.IOBUF_PAD[14:10]))
      begin
        `nnc_error("ATM10", $sformatf("ATM[0:14] = %b is not as expectation of ATM = %b", top_test_cfg.atm, (15'b100_0000_0000_0000 >> `SOC_TOP.IOBUF_PAD[14:10])))
      end   
     
    // ===================================
    // ATM11 Operation - D2A_TRIM4_SIG_SPARE
    // ===================================
    `uvm_info("ENTER ATM",$sformatf("Enter ATM11 Operation"),NNC_LOW)    
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b01011; 
    force `SOC_TOP.IOBUF_PAD[8:1] = $random;
    #100us

    top_test_cfg.save_trim_wdata[11] = {`SOC_TOP.IOBUF_PAD[8],`SOC_TOP.IOBUF_PAD[7], `SOC_TOP.IOBUF_PAD[6], `SOC_TOP.IOBUF_PAD[5], `SOC_TOP.IOBUF_PAD[4], `SOC_TOP.IOBUF_PAD[3], `SOC_TOP.IOBUF_PAD[2], `SOC_TOP.IOBUF_PAD[1]};  
    `nnc_info("ATM11",$sformatf("D2A_TRIM4_SIG_SPARE = %8b", top_test_cfg.save_trim_wdata[11]), NNC_LOW)

    top_test_cfg.atm = {`DIG_TOP.u_pinmux.ATM0,`DIG_TOP.u_pinmux.ATM1,`DIG_TOP.u_pinmux.ATM2,`DIG_TOP.u_pinmux.ATM3,`DIG_TOP.u_pinmux.ATM4,`DIG_TOP.u_pinmux.ATM5,`DIG_TOP.u_pinmux.ATM6,`DIG_TOP.u_pinmux.ATM7,`DIG_TOP.u_pinmux.ATM8,`DIG_TOP.u_pinmux.ATM9,`DIG_TOP.u_pinmux.ATM10,`DIG_TOP.u_pinmux.ATM11,`DIG_TOP.u_pinmux.ATM12,`DIG_TOP.u_pinmux.ATM13,`DIG_TOP.u_pinmux.ATM14};
    
    // Checking ATM
    if (top_test_cfg.atm !== (15'b100_0000_0000_0000 >> `SOC_TOP.IOBUF_PAD[14:10]))
      begin
        `nnc_error("ATM11", $sformatf("ATM[0:14] = %b is not as expectation of ATM = %b", top_test_cfg.atm, (15'b100_0000_0000_0000 >> `SOC_TOP.IOBUF_PAD[14:10])))
      end   
     
    // ===================================
    // ATM12 Operation - SDM_BUFFOP
    // ===================================
    `uvm_info("ENTER ATM",$sformatf("Enter ATM12 Operation"),NNC_LOW)    
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b01100; 
    force `SOC_TOP.IOBUF_PAD[8:1] = $random;
    #100us

    top_test_cfg.save_trim_wdata[12] = {`SOC_TOP.IOBUF_PAD[8],`SOC_TOP.IOBUF_PAD[7], `SOC_TOP.IOBUF_PAD[6], `SOC_TOP.IOBUF_PAD[5], `SOC_TOP.IOBUF_PAD[4], `SOC_TOP.IOBUF_PAD[3], `SOC_TOP.IOBUF_PAD[2], `SOC_TOP.IOBUF_PAD[1]};  
    `nnc_info("ATM12",$sformatf("D2A_TRIM5_SIG_SPARE = %8b", top_test_cfg.save_trim_wdata[12]), NNC_LOW)

    top_test_cfg.atm = {`DIG_TOP.u_pinmux.ATM0,`DIG_TOP.u_pinmux.ATM1,`DIG_TOP.u_pinmux.ATM2,`DIG_TOP.u_pinmux.ATM3,`DIG_TOP.u_pinmux.ATM4,`DIG_TOP.u_pinmux.ATM5,`DIG_TOP.u_pinmux.ATM6,`DIG_TOP.u_pinmux.ATM7,`DIG_TOP.u_pinmux.ATM8,`DIG_TOP.u_pinmux.ATM9,`DIG_TOP.u_pinmux.ATM10,`DIG_TOP.u_pinmux.ATM11,`DIG_TOP.u_pinmux.ATM12,`DIG_TOP.u_pinmux.ATM13,`DIG_TOP.u_pinmux.ATM14};
    
    // Checking ATM
    if (top_test_cfg.atm !== (15'b100_0000_0000_0000 >> `SOC_TOP.IOBUF_PAD[14:10]))
      begin
        `nnc_error("ATM12", $sformatf("ATM[0:14] = %b is not as expectation of ATM = %b", top_test_cfg.atm, (15'b100_0000_0000_0000 >> `SOC_TOP.IOBUF_PAD[14:10])))
      end   
     
    // ===================================
    // ATM13 Operation - SDM_BUFFON
    // ===================================
    `uvm_info("ENTER ATM",$sformatf("Enter ATM13 Operation"),NNC_LOW)    
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b01101; 
    force `SOC_TOP.IOBUF_PAD[8:1] = $random;
    #100us

    top_test_cfg.save_trim_wdata[13] = {`SOC_TOP.IOBUF_PAD[8],`SOC_TOP.IOBUF_PAD[7], `SOC_TOP.IOBUF_PAD[6], `SOC_TOP.IOBUF_PAD[5], `SOC_TOP.IOBUF_PAD[4], `SOC_TOP.IOBUF_PAD[3], `SOC_TOP.IOBUF_PAD[2], `SOC_TOP.IOBUF_PAD[1]};  
    `nnc_info("ATM13",$sformatf("D2A_TRIM6_SIG_SPARE = %8b", top_test_cfg.save_trim_wdata[13]), NNC_LOW)

    top_test_cfg.atm = {`DIG_TOP.u_pinmux.ATM0,`DIG_TOP.u_pinmux.ATM1,`DIG_TOP.u_pinmux.ATM2,`DIG_TOP.u_pinmux.ATM3,`DIG_TOP.u_pinmux.ATM4,`DIG_TOP.u_pinmux.ATM5,`DIG_TOP.u_pinmux.ATM6,`DIG_TOP.u_pinmux.ATM7,`DIG_TOP.u_pinmux.ATM8,`DIG_TOP.u_pinmux.ATM9,`DIG_TOP.u_pinmux.ATM10,`DIG_TOP.u_pinmux.ATM11,`DIG_TOP.u_pinmux.ATM12,`DIG_TOP.u_pinmux.ATM13,`DIG_TOP.u_pinmux.ATM14};
    
    // Checking ATM
    if (top_test_cfg.atm !== (15'b100_0000_0000_0000 >> `SOC_TOP.IOBUF_PAD[14:10]))
      begin
        `nnc_error("ATM13", $sformatf("ATM[0:14] = %b is not as expectation of ATM = %b", top_test_cfg.atm, (15'b100_0000_0000_0000 >> `SOC_TOP.IOBUF_PAD[14:10])))
      end   
     
    // ===================================
    // ATM14 Operation - SDM
    // ===================================
    `uvm_info("ENTER ATM",$sformatf("Enter ATM7 Operation"),NNC_LOW)    
    force `SOC_TOP.IOBUF_PAD[14:10] = 5'b01110; 
    force `SOC_TOP.IOBUF_PAD[8:1] = $random;
    #100us

    top_test_cfg.save_trim_wdata[14] = {`SOC_TOP.IOBUF_PAD[8],`SOC_TOP.IOBUF_PAD[7], `SOC_TOP.IOBUF_PAD[6], `SOC_TOP.IOBUF_PAD[5], `SOC_TOP.IOBUF_PAD[4], `SOC_TOP.IOBUF_PAD[3], `SOC_TOP.IOBUF_PAD[2], `SOC_TOP.IOBUF_PAD[1]};  
    `nnc_info("ATM14",$sformatf("D2A_TRIM7_SIG_SPARE = %8b", top_test_cfg.save_trim_wdata[14]), NNC_LOW)

    top_test_cfg.atm = {`DIG_TOP.u_pinmux.ATM0,`DIG_TOP.u_pinmux.ATM1,`DIG_TOP.u_pinmux.ATM2,`DIG_TOP.u_pinmux.ATM3,`DIG_TOP.u_pinmux.ATM4,`DIG_TOP.u_pinmux.ATM5,`DIG_TOP.u_pinmux.ATM6,`DIG_TOP.u_pinmux.ATM7,`DIG_TOP.u_pinmux.ATM8,`DIG_TOP.u_pinmux.ATM9,`DIG_TOP.u_pinmux.ATM10,`DIG_TOP.u_pinmux.ATM11,`DIG_TOP.u_pinmux.ATM12,`DIG_TOP.u_pinmux.ATM13,`DIG_TOP.u_pinmux.ATM14};
    
    // Checking ATM
    if (top_test_cfg.atm !== (15'b100_0000_0000_0000 >> `SOC_TOP.IOBUF_PAD[14:10]))
      begin
        `nnc_error("ATM14", $sformatf("ATM[0:14] = %b is not as expectation of ATM = %b", top_test_cfg.atm, (15'b100_0000_0000_0000 >> `SOC_TOP.IOBUF_PAD[14:10])))
      end   
    
    // =============================================================
    // UNLOCK == 1 to save trim data into OTP
    // =============================================================
    assert(top_test_cfg.randomize() with { otp_program_en == 1; });
    `DUT_IF.otp_program_en = top_test_cfg.otp_program_en;
    `DUT_IF.otp_vpp_delay = top_test_cfg.otp_vpp_delay;

    assert(top_test_cfg.randomize());
    case(top_test_cfg.atm_no)
        5'b00000: 
            begin
                force `SOC_TOP.IOBUF_PAD[14:10] = 5'b00000;
                force `SOC_TOP.IOBUF_PAD[8:1]   = top_test_cfg.save_trim_wdata[0];
            end 
        5'b00001: 
            begin
                force `SOC_TOP.IOBUF_PAD[14:10] = 5'b00001;
                force `SOC_TOP.IOBUF_PAD[8:1]   = top_test_cfg.save_trim_wdata[1];
            end 
        5'b00010: 
            begin
                force `SOC_TOP.IOBUF_PAD[14:10] = 5'b00010;
                force `SOC_TOP.IOBUF_PAD[8:1]   = top_test_cfg.save_trim_wdata[2];
            end 
        5'b00011: 
            begin
                force `SOC_TOP.IOBUF_PAD[14:10] = 5'b00011;
                force `SOC_TOP.IOBUF_PAD[8:1]   = top_test_cfg.save_trim_wdata[3];
            end 
        5'b00100: 
            begin
                force `SOC_TOP.IOBUF_PAD[14:10] = 5'b00100;
                force `SOC_TOP.IOBUF_PAD[8:1]   = top_test_cfg.save_trim_wdata[4];
            end 
        5'b00101: 
            begin
                force `SOC_TOP.IOBUF_PAD[14:10] = 5'b00101;
                force `SOC_TOP.IOBUF_PAD[8:1]   = top_test_cfg.save_trim_wdata[5];
            end 
        5'b00110: 
            begin
                force `SOC_TOP.IOBUF_PAD[14:10] = 5'b00110;
                force `SOC_TOP.IOBUF_PAD[8:1]   = top_test_cfg.save_trim_wdata[6];
            end 
        5'b00111: 
            begin
                force `SOC_TOP.IOBUF_PAD[14:10] = 5'b00111;
                force `SOC_TOP.IOBUF_PAD[8:1]   = top_test_cfg.save_trim_wdata[7];
            end 
        5'b01000: 
            begin
                force `SOC_TOP.IOBUF_PAD[14:10] = 5'b01000;
                force `SOC_TOP.IOBUF_PAD[8:1]   = top_test_cfg.save_trim_wdata[8];
            end 
        5'b01001: 
            begin
                force `SOC_TOP.IOBUF_PAD[14:10] = 5'b01001;
                force `SOC_TOP.IOBUF_PAD[8:1]   = top_test_cfg.save_trim_wdata[9];
            end 
        5'b01010: 
            begin
                force `SOC_TOP.IOBUF_PAD[14:10] = 5'b01010;
                force `SOC_TOP.IOBUF_PAD[8:1]   = top_test_cfg.save_trim_wdata[10];
            end 
        5'b01011: 
            begin
                force `SOC_TOP.IOBUF_PAD[14:10] = 5'b01011;
                force `SOC_TOP.IOBUF_PAD[8:1]   = top_test_cfg.save_trim_wdata[11];
            end 
        5'b01100: 
            begin
                force `SOC_TOP.IOBUF_PAD[14:10] = 5'b01100;
                force `SOC_TOP.IOBUF_PAD[8:1]   = top_test_cfg.save_trim_wdata[12];
            end 
        5'b01101: 
            begin
                force `SOC_TOP.IOBUF_PAD[14:10] = 5'b01101;
                force `SOC_TOP.IOBUF_PAD[8:1]   = top_test_cfg.save_trim_wdata[13];
            end 
        5'b01110: 
            begin
                force `SOC_TOP.IOBUF_PAD[14:10] = 5'b01110;
                force `SOC_TOP.IOBUF_PAD[8:1]   = top_test_cfg.save_trim_wdata[14];
            end
    endcase 
    
    `nnc_info("ATM UNLOCK", $sformatf("Currently Testing UNLOCK on ATM%d with data %b",`SOC_TOP.IOBUF_PAD[14:10], `SOC_TOP.IOBUF_PAD[8:1]), NNC_LOW)
    
    `nnc_info("SOC","Enable OTP Unlock", NNC_LOW)
    force `SOC_TB.UNLOCK = 1;//OTP_UNLOCK

    `nnc_info("SOC","Wait for VPP_EN == 1", NNC_LOW)
    wait(`DIG_TOP.otp_vpp_en == 1);
    
    `nnc_info("SOC","Apply VPP High", NNC_LOW)
    #15ns; //Wait for PPROG Setup time 
    force `DIG_TOP.VPP_OTP = 1;
    
    wait(`DIG_TOP.otp_vpp_en == 0);
    `nnc_info("SOC","Apply VPP High", NNC_LOW)
    force `DIG_TOP.VPP_OTP = 0; 

    release `DIG_TOP.VPP_OTP; 
    
    if(`DUT_IF.pclk_sel == 3'b000) 
        begin
            #25.5us;
        end
    else if(`DUT_IF.pclk_sel == 3'b001)
        begin
            #51us;
        end
    else if(`DUT_IF.pclk_sel == 3'b010)
        begin
            #102us;
        end
    else if(`DUT_IF.pclk_sel == 3'b011)
        begin
            #204us;
        end
    else if(`DUT_IF.pclk_sel == 3'b100)
        begin
            #408us;
        end
    else if(`DUT_IF.pclk_sel == 3'b101)
        begin
            #416us;
        end
    else if(`DUT_IF.pclk_sel == 3'b110)
        begin
            #416us;
        end
    else if(`DUT_IF.pclk_sel == 3'b111)
        begin
            #446us;
        end

    `nnc_info("DATA in GPIO",$sformatf("DATA0 = %h", top_test_cfg.save_trim_wdata[0]), NNC_LOW)
    `nnc_info("DATA in GPIO",$sformatf("DATA1 = %h", top_test_cfg.save_trim_wdata[1]), NNC_LOW)
    `nnc_info("DATA in GPIO",$sformatf("DATA2 = %h", top_test_cfg.save_trim_wdata[2]), NNC_LOW)
    `nnc_info("DATA in GPIO",$sformatf("DATA3 = %h", top_test_cfg.save_trim_wdata[3]), NNC_LOW)
    `nnc_info("DATA in GPIO",$sformatf("DATA4 = %h", top_test_cfg.save_trim_wdata[4]), NNC_LOW)
    `nnc_info("DATA in GPIO",$sformatf("DATA5 = %h", top_test_cfg.save_trim_wdata[5]), NNC_LOW)
    `nnc_info("DATA in GPIO",$sformatf("DATA6 = %h", top_test_cfg.save_trim_wdata[6]), NNC_LOW)
    `nnc_info("DATA in GPIO",$sformatf("DATA7 = %h", top_test_cfg.save_trim_wdata[7]), NNC_LOW)
    `nnc_info("DATA in GPIO",$sformatf("DATA8 = %h", top_test_cfg.save_trim_wdata[8]), NNC_LOW)
    `nnc_info("DATA in GPIO",$sformatf("DATA9 = %h", top_test_cfg.save_trim_wdata[9]), NNC_LOW)
    `nnc_info("DATA in GPIO",$sformatf("DATA10 = %h", top_test_cfg.save_trim_wdata[10]), NNC_LOW)
    `nnc_info("DATA in GPIO",$sformatf("DATA11 = %h", top_test_cfg.save_trim_wdata[11]), NNC_LOW)
    `nnc_info("DATA in GPIO",$sformatf("DATA12 = %h", top_test_cfg.save_trim_wdata[12]), NNC_LOW)
    `nnc_info("DATA in GPIO",$sformatf("DATA13 = %h", top_test_cfg.save_trim_wdata[13]), NNC_LOW)
    `nnc_info("DATA in GPIO",$sformatf("DATA14 = %h", top_test_cfg.save_trim_wdata[14]), NNC_LOW)

    `nnc_info("DATA in OTP",$sformatf("DATA0 = %h at address: 0x04", `EPROM_TOP.u_otp_regs.shadow_regs[4]), NNC_LOW)
    `nnc_info("DATA in OTP",$sformatf("DATA1 = %h at address: 0x05", `EPROM_TOP.u_otp_regs.shadow_regs[5]), NNC_LOW)
    `nnc_info("DATA in OTP",$sformatf("DATA2 = %h at address: 0x06", `EPROM_TOP.u_otp_regs.shadow_regs[6]), NNC_LOW)
    `nnc_info("DATA in OTP",$sformatf("DATA3 = %h at address: 0x07", `EPROM_TOP.u_otp_regs.shadow_regs[7]), NNC_LOW)
    `nnc_info("DATA in OTP",$sformatf("DATA4 = %h at address: 0x08", `EPROM_TOP.u_otp_regs.shadow_regs[8]), NNC_LOW)
    `nnc_info("DATA in OTP",$sformatf("DATA5 = %h at address: 0x09", `EPROM_TOP.u_otp_regs.shadow_regs[9]), NNC_LOW)
    `nnc_info("DATA in OTP",$sformatf("DATA6 = %h at address: 0x0A", `EPROM_TOP.u_otp_regs.shadow_regs[10]), NNC_LOW)
    `nnc_info("DATA in OTP",$sformatf("DATA7 = %h at address: 0x0B", `EPROM_TOP.u_otp_regs.shadow_regs[11]), NNC_LOW)
    `nnc_info("DATA in OTP",$sformatf("DATA8 = %h at address: 0x0C", `EPROM_TOP.u_otp_regs.shadow_regs[12]), NNC_LOW)
    `nnc_info("DATA in OTP",$sformatf("DATA9 = %h at address: 0x0D", `EPROM_TOP.u_otp_regs.shadow_regs[13]), NNC_LOW)
    `nnc_info("DATA in OTP",$sformatf("DATA10 = %h at address: 0x0E", `EPROM_TOP.u_otp_regs.shadow_regs[14]), NNC_LOW)
    `nnc_info("DATA in OTP",$sformatf("DATA11 = %h at address: 0x0F", `EPROM_TOP.u_otp_regs.shadow_regs[15]), NNC_LOW)
    `nnc_info("DATA in OTP",$sformatf("DATA12 = %h at address: 0x10", `EPROM_TOP.u_otp_regs.shadow_regs[16]), NNC_LOW)
    `nnc_info("DATA in OTP",$sformatf("DATA13 = %h at address: 0x11", `EPROM_TOP.u_otp_regs.shadow_regs[17]), NNC_LOW)
    `nnc_info("DATA in OTP",$sformatf("DATA14 = %h at address: 0x12", `EPROM_TOP.u_otp_regs.shadow_regs[18]), NNC_LOW)

    release `SOC_TB.UNLOCK;
    release `SOC_TOP.IOBUF_PAD[8:1];
    // ===================================
    // Changing to use BIST 
    // ===================================
    assert(top_test_cfg.randomize() with { otp_program_en == 0; });
    
    `DUT_IF.otp_program_en = top_test_cfg.otp_program_en;
    `DUT_IF.otp_vpp_delay = top_test_cfg.otp_vpp_delay;
    #20us;
    
    force `ANA_TOP.PMU_SW.DVDD = 1'b0; //in testmode LDO  not connected to DVDD so need provide external supply 1.8v

    assert(top_test_cfg.randomize() with { testmode_sel == 2'b10;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #150us;
    
    force `ANA_TOP.PMU_SW.DVDD = 1'b1; //in testmode LDO  not connected to DVDD so need provide external supply 1.8v
    
    #150us;
    `nnc_info("SOC_TEST", "[EPROM BIST MASTER][0] Sending Reset Command to EPROM", NNC_LOW);
    `BISTM_RESET;
    `nnc_info("SOC_TEST", "[EPROM BIST MASTER] Complete successully this phase", NNC_LOW);
    
    #150us;
    
    for(int i = 4; i<8'h13; i++) begin
        `BISTM_SINGLE_READ(top_test_cfg.OTP_SEL, i, top_test_cfg.rd_data[i-4]);
        `nnc_info("SOC_TEST", $sformatf("Testing the data :%b",top_test_cfg.rd_data[i-4]), NNC_LOW);
        if(top_test_cfg.save_trim_wdata[i-4] !== top_test_cfg.rd_data[i-4])
            begin
                `nnc_error("OTP REG", $sformatf("Wrong data in OTP reg 0x%h, Expected data %8b, Real data %8b", i, top_test_cfg.save_trim_wdata[i-4], top_test_cfg.rd_data[i-4]))                 
            end
        else 
                `nnc_info("OTP REG", $sformatf("Data in OTP reg 0x%h, Expected data %8b, Real data %8b", i, top_test_cfg.save_trim_wdata[i-4], top_test_cfg.rd_data[i-4]), NNC_HIGH)                 
    end

    for(int i=0; i<14 ; i++) begin
        if (top_test_cfg.save_trim_wdata[i] !== `EPROM_BIST_IF.rd_data[i+4][7:0]) 
           `nnc_error("SOC_TEST", $sformatf("save_trim_wdata %8b !== bist_rd_data %8b!!!", top_test_cfg.save_trim_wdata[i], `EPROM_BIST_IF.rd_data[i+4][7:0]))
        else 
           `nnc_info("SOC_TEST", $sformatf("save_trim_wdata %8b === bist_rd_data %8b", top_test_cfg.save_trim_wdata[i], `EPROM_BIST_IF.rd_data[i+4][7:0]), NNC_LOW)
    end

    if (top_test_cfg.trim_tag_prepare_en === 1'b1) begin  
      `nnc_info("SOC_TEST", "[EPROM BIST MASTER] TRIM TAG is written by BIST", NNC_LOW);  
      `BISTM_SINGLE_PROGRAM(top_test_cfg.OTP_SEL, 0, 8'h5a, top_test_cfg.vpp_pos_cnt, top_test_cfg.vpp_width);  
    end
    else
    `nnc_info("SOC_TEST", "[EPROM BIST MASTER] TRIM TAG is used in Shadow Reg Default", NNC_LOW);
    
    `nnc_info("SOC_TEST", "Requesting the RESET", UVM_LOW)
    force soc_top_tb.iopad_resetn = 1'b0;

    assert(top_test_cfg.randomize() with { testmode_sel == 2'b00;}) 
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
        
    #100000ns;
    release soc_top_tb.iopad_resetn;
    #1000us; 
             
    `DUT_IF.altf_gpio_sel = `DUT_IF.altf_sel;

    //top_test_cfg.rd_data =new[15];
    //read trim_reg
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_TRIM_0_REG; no_of_bytes == 16; });
    `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data[0:15]);
    #10ms; 
    
    for(int i=0; i<16; i++) begin

        if(top_test_cfg.save_trim_wdata[i] !== `EPROM_TOP.u_otp_regs.shadow_regs[i+4]) begin
            `nnc_error("SOC_TEST", $sformatf("save_trim_wdata %8b !== rd_data %8b!!!", top_test_cfg.save_trim_wdata[i], `EPROM_TOP.u_otp_regs.shadow_regs[i+4]));     
        end
    end

    if(top_test_cfg.rd_data[14] !== `ANA_TOP.D2A_BG_TRIM)
        `nnc_error("SOC_TEST", $sformatf("WRONG %b %b", top_test_cfg.rd_data[15], `ANA_TOP.D2A_BG_TRIM));     
    if(top_test_cfg.rd_data[13] !== `ANA_TOP.D2A_BGBUFFER_TRIM)
        `nnc_error("SOC_TEST", $sformatf("WRONG %b %b", top_test_cfg.rd_data[14], `ANA_TOP.D2A_BGBUFFER_TRIM));     
    if(top_test_cfg.rd_data[12] !== `ANA_TOP.D2A_IREF_TRIM)
        `nnc_error("SOC_TEST", $sformatf("WRONG %b %b", top_test_cfg.rd_data[13], `ANA_TOP.D2A_IREF_TRIM));     
    if(top_test_cfg.rd_data[11] !== `ANA_TOP.D2A_CLDO1P8_TRIM)
        `nnc_error("SOC_TEST", $sformatf("WRONG %b %b", top_test_cfg.rd_data[12], `ANA_TOP.D2A_CLDO1P8_TRIM));     
    if(top_test_cfg.rd_data[10] !== `ANA_TOP.D2A_OSC8MHZ_TRIM)
        `nnc_error("SOC_TEST", $sformatf("WRONG %b %b", top_test_cfg.rd_data[11], `ANA_TOP.D2A_OSC8MHZ_TRIM));     
    if(top_test_cfg.rd_data[9] !== `ANA_TOP.D2A_TSC_TRIM)
        `nnc_error("SOC_TEST", $sformatf("WRONG %b %b", top_test_cfg.rd_data[10], `ANA_TOP.D2A_TSC_TRIM));     
    if(top_test_cfg.rd_data[8] !== `ANA_TOP.D2A_DRIVER_CUR_TRIM)
        `nnc_error("SOC_TEST", $sformatf("WRONG %b %b", top_test_cfg.rd_data[9], `ANA_TOP.D2A_DRIVER_CUR_TRIM));     
    if(top_test_cfg.rd_data[7] !== `ANA_TOP.D2A_TRIM0_SIG_SPARE)
        `nnc_error("SOC_TEST", $sformatf("WRONG %b %b", top_test_cfg.rd_data[8], `ANA_TOP.D2A_TRIM0_SIG_SPARE));     
    if(top_test_cfg.rd_data[6] !== `ANA_TOP.D2A_TRIM1_SIG_SPARE)
        `nnc_error("SOC_TEST", $sformatf("WRONG %b %b", top_test_cfg.rd_data[7], `ANA_TOP.D2A_TRIM1_SIG_SPARE));     
    if(top_test_cfg.rd_data[5] !== `ANA_TOP.D2A_TRIM2_SIG_SPARE)
        `nnc_error("SOC_TEST", $sformatf("WRONG %b %b", top_test_cfg.rd_data[6], `ANA_TOP.D2A_TRIM2_SIG_SPARE));     
    if(top_test_cfg.rd_data[4] !== `ANA_TOP.D2A_TRIM3_SIG_SPARE)
        `nnc_error("SOC_TEST", $sformatf("WRONG %b %b", top_test_cfg.rd_data[5], `ANA_TOP.D2A_TRIM3_SIG_SPARE));     
    if(top_test_cfg.rd_data[3] !== `ANA_TOP.D2A_TRIM4_SIG_SPARE)
        `nnc_error("SOC_TEST", $sformatf("WRONG %b %b", top_test_cfg.rd_data[4], `ANA_TOP.D2A_TRIM4_SIG_SPARE));     
    if(top_test_cfg.rd_data[2] !== `ANA_TOP.D2A_TRIM5_SIG_SPARE)
        `nnc_error("SOC_TEST", $sformatf("WRONG %b %b", top_test_cfg.rd_data[3], `ANA_TOP.D2A_TRIM5_SIG_SPARE));     
    if(top_test_cfg.rd_data[1] !== `ANA_TOP.D2A_TRIM6_SIG_SPARE)
        `nnc_error("SOC_TEST", $sformatf("WRONG %b %b", top_test_cfg.rd_data[2], `ANA_TOP.D2A_TRIM6_SIG_SPARE));     
    if(top_test_cfg.rd_data[0] !== `ANA_TOP.D2A_TRIM7_SIG_SPARE)
        `nnc_error("SOC_TEST", $sformatf("WRONG %b %b", top_test_cfg.rd_data[1], `ANA_TOP.D2A_TRIM7_SIG_SPARE));     

    end
  endtask 

  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction

endclass : `TESTNAME    
