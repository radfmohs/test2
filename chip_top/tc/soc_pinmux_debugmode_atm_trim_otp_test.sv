/*--------------------------------------------------------------------------------------
// Copyright 2021 Nanochap, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name    : soc_pinmux_debugmode_atm_trim_otp_test.sv                                                   
// Project      : Nanochap ENS2                                                         
// Description  : Testcase soc_pinmux_debugmode_atm_trim_otp_test                                          
// Designer     : ddang@nanochap.com                                                            
// Date         : 07-08-2025                                                                     
// Revision     : 0.1 Initial version created by script                                 
// --------------------------------------------------------------------------------------*/
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

  function new (string name = "soc_pinmux_debugmode_atm_trim_otp_test_cfg");
    super.new(name);
    
  endfunction: new

  // -----------------------------------------------
  // Adding constraints of randomization
  // -----------------------------------------------
  // testmode_sel[1:0] : 00-Normal mode, 01: Scanmode, 10: BIST mode, 11 atm0/1/2/3/4
  // constraint c_testmode_sel { soft testmode_sel == 2'b01; } 

  constraint c_atm_no { soft atm_no inside {[2:0]};};

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
    `DUT_IF.ext_clk_en = top_test_cfg.ext_clk_en;			  // 1: external EXT_2MHZ will be driven to SOC from OSC model

    // enable to fix 1'b0 to internal clk
    `DUT_IF.hfosc_fixed_gnd_en = top_test_cfg.hfosc_fixed_gnd_en;         // 1: disble pin to 2MHZ internal osc model, 0:enable pin to internal 2MHZ osc model

    // enable to fix 1'b0 to ext clk
    `DUT_IF.ext_hfosc_fixed_gnd_en = top_test_cfg.ext_hfosc_fixed_gnd_en; // 1: disble pin to 2MHZ exeternal osc model, 0:enable pin to exeternal 2MHZ osc model

    // Clock variation of HFOSC
    `DUT_IF.hfosc_variation = top_test_cfg.hfosc_variation;

    // ========================================================================
    // Before entering ATM mode, Disbale internal POR and clock
    // ========================================================================
    //stuck internal POR=1
    //force `ANA_TOP.A2D_POR_DVDD = 1'b1;
    //disable internal clock
    //force `ANA_TOP.A2D_CLK2MHZ = 1'b0; // no need to force because hfosc_fixed_gnd_en =1 this take care stuck 0

    // ==================
    // Scoreboard enables
    // ==================
    `SPI_SCB_EN = 1'b0;
    `ANALOG_SCOREBOARD_EN = 1'b1;
    `WAVEGEN_SCB_DRV_0_EN = 1'b0;
    `WAVEGEN_SHORT_DETECT_SCB_EN = 1'b0; 
   
    phase.drop_objection(this); 
  endtask

  virtual task main_phase(nnc_phase phase);
    phase.raise_objection(this);

    `nnc_info("SOC_TEST", "soc_pinmux_debugmode_atm_trim_otp_test start", NNC_LOW)
    // ----------------------------------------------------------------------------------
    // Please add your code of your test here
    // ---------------------------------------------------------------------------------- 
    // This is sample to write a data to Register

    `DUT_IF.pinmux_mode = 1;
    `DUT_IF.io_model_check_off = 1;  
    `DUT_IF.otp_ignore_check_en = 1;        

    //// Use external resetn (set LOW to HIGH )
    //force `SOC_TB.ext_resetn = 1'b0;
    //#100000;
    //force `SOC_TB.ext_resetn = 1'b1;
    //#1ms;
       
    do_run;
    #1000000;            
    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ----------------------------------------------------------------------------------
    phase.drop_objection(this);
  endtask: main_phase
  
  virtual task do_run;
    begin
  
    // =======================================
    // ATM0 Operation (Step 1) - Save BG_TRIM
    // =======================================
  
    `uvm_info("",$sformatf("Enter ATM0 Operation"),NNC_LOW)
    force `SOC_TOP.IOBUF_PAD[10:8] = 3'b000; 

    force `SOC_TB.ext_resetn = 1'b0;

    force `SOC_TB.UNLOCK = 1'b0;//OTP_UNLOCK 

    //#10ms;
`ifndef MIX_SIM_EN 
    //force `ANA_TOP.PMU_SW.CHIP_EN = 0;
`endif
    //wait(`SOC_TB.VDD_DIG === 0); 
    //force `SOC_TB.VDD_DIG = 0;
    `DUT_IF.testmode_sel = 2'b11;  
    #1000ns;

    force `ANA_TOP.A2D_POR_DVDD = 1'b1;
    // Use external resetn (set LOW to HIGH )
    force `ANA_TOP.PMU_SW.DVDD = 1'b1; //in testmode LDO will not connected to DVDD so need provide external supply 1.8v
    //force `SOC_TB.ext_resetn = 1'b0;
    #100000;
    force `SOC_TB.ext_resetn = 1'b1;
    #1ms;
  

`ifndef MIX_SIM_EN
    //force `ANA_TOP.PMU_SW.CHIP_EN = 1;
`endif
    //wait(`SOC_TB.VDD_DIG === 1); 
    //force `SOC_TB.VDD_DIG = 1;
      
     
    force `SOC_TOP.IOBUF_PAD[7:1] = $random(0);
    #10us;

    top_test_cfg.save_trim_wdata[0] = {2'b0, `SOC_TOP.IOBUF_PAD[6], `SOC_TOP.IOBUF_PAD[5], `SOC_TOP.IOBUF_PAD[4], `SOC_TOP.IOBUF_PAD[3], `SOC_TOP.IOBUF_PAD[2], `SOC_TOP.IOBUF_PAD[1]}; 
    `nnc_info("ATM0",$sformatf("D2A_BG_TRIM = %8b",top_test_cfg.save_trim_wdata[0]), NNC_LOW) 

    #1ms;

  `ifdef BEHAVIORAL    
    top_test_cfg.atm = {`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[0],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[1],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[2],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[3],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[4],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[5],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[6],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[7]};
`else
    top_test_cfg.atm = {`ANA_WRAPPER_TOP.D2A_ATM0,`ANA_WRAPPER_TOP.D2A_ATM1,`ANA_WRAPPER_TOP.D2A_ATM2,`ANA_WRAPPER_TOP.D2A_ATM3,`ANA_WRAPPER_TOP.D2A_ATM4,`ANA_WRAPPER_TOP.D2A_ATM5,`ANA_WRAPPER_TOP.D2A_ATM6,`ANA_WRAPPER_TOP.D2A_ATM7};
`endif    
    // Checking ATM
    if (top_test_cfg.atm !== (8'b1000_0000 >> `SOC_TOP.IOBUF_PAD[10:8]))
      begin
        `nnc_error("ATM0", $sformatf("ATM[0:7] = %b is not as expectation of ATM = %b", top_test_cfg.atm, (8'b1000_0000 >> `SOC_TOP.IOBUF_PAD[10:8])))
      end   

    top_test_cfg.atm = {`ANA_TOP.D2A_ATM0,`ANA_TOP.D2A_ATM1,`ANA_TOP.D2A_ATM2,`ANA_TOP.D2A_ATM3,`ANA_TOP.D2A_ATM4,`ANA_TOP.D2A_ATM5,`ANA_TOP.D2A_ATM6,`ANA_TOP.D2A_ATM7};
    if (top_test_cfg.atm !== (8'b1000_0000 >> `SOC_TOP.IOBUF_PAD[10:8]))
      begin
        `nnc_error("ATM0", $sformatf("ATM[0:7] = %b is not as expectation of ATM = %b", top_test_cfg.atm, (8'b1000_0000 >> `SOC_TOP.IOBUF_PAD[10:8])))
      end   

    //release  `SOC_TOP.IOBUF_PAD[7:1];      

    // ===================================
    // ATM1 Operation - IREF_TRIM, IREF_TSC_OUT_SEL
    // ===================================
    `uvm_info("",$sformatf("Enter ATM1 Operation"),NNC_LOW) 
    `DUT_IF.testmode_sel = 2'b11;  
       
    force `SOC_TOP.IOBUF_PAD[10:8] = 3'b001; 
    #1000ns; //change atm_mode -> set trim data
    force `SOC_TOP.IOBUF_PAD[7:1] = $random;
    
    #10000;

    top_test_cfg.save_trim_wdata[1] = {1'b0,`SOC_TOP.IOBUF_PAD[7], `SOC_TOP.IOBUF_PAD[6], `SOC_TOP.IOBUF_PAD[5], `SOC_TOP.IOBUF_PAD[4], `SOC_TOP.IOBUF_PAD[3], `SOC_TOP.IOBUF_PAD[2], `SOC_TOP.IOBUF_PAD[1]};  
    `nnc_info("ATM1",$sformatf("D2A_IREF_TRIM = %8b", top_test_cfg.save_trim_wdata[1]), NNC_LOW) 

    #1000us;
  `ifdef BEHAVIORAL    
    top_test_cfg.atm = {`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[0],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[1],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[2],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[3],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[4],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[5],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[6],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[7]};
`else
    top_test_cfg.atm = {`ANA_WRAPPER_TOP.D2A_ATM0,`ANA_WRAPPER_TOP.D2A_ATM1,`ANA_WRAPPER_TOP.D2A_ATM2,`ANA_WRAPPER_TOP.D2A_ATM3,`ANA_WRAPPER_TOP.D2A_ATM4,`ANA_WRAPPER_TOP.D2A_ATM5,`ANA_WRAPPER_TOP.D2A_ATM6,`ANA_WRAPPER_TOP.D2A_ATM7};
`endif   
    // Checking ATM
    if (top_test_cfg.atm !== (8'b1000_0000 >> `SOC_TOP.IOBUF_PAD[10:8]))
      begin
        `nnc_error("ATM1", $sformatf("ATM[0:7] = %b is not as expectation of ATM = %b", top_test_cfg.atm, (8'b1000_0000 >> `SOC_TOP.IOBUF_PAD[10:8])))
      end   

    top_test_cfg.atm = {`ANA_TOP.D2A_ATM0,`ANA_TOP.D2A_ATM1,`ANA_TOP.D2A_ATM2,`ANA_TOP.D2A_ATM3,`ANA_TOP.D2A_ATM4,`ANA_TOP.D2A_ATM5,`ANA_TOP.D2A_ATM6,`ANA_TOP.D2A_ATM7};
    if (top_test_cfg.atm !== (8'b1000_0000 >> `SOC_TOP.IOBUF_PAD[10:8]))
      begin
        `nnc_error("ATM1", $sformatf("ATM[0:7] = %b is not as expectation of ATM = %b", top_test_cfg.atm, (8'b1000_0000 >> `SOC_TOP.IOBUF_PAD[10:8])))
      end   

    //release  `SOC_TOP.IOBUF_PAD[7:1];      

    // =====================================================================
    // ATM2 Operation - CLDO1P8_TRIM and LDO_2P8_PUMP_TRIM, CS_PGA_CLK_TRIM
    // =====================================================================
    `uvm_info("",$sformatf("Enter ATM2 Operation"),NNC_LOW) 
    `DUT_IF.testmode_sel = 2'b11;  
           
    force `SOC_TOP.IOBUF_PAD[10:8] = 3'b010; 
    #1000ns; //change atm_mode -> set trim data

    force `SOC_TOP.IOBUF_PAD[7:1] = $random;
    #10000;

    top_test_cfg.save_trim_wdata[2] = {1'b0,`SOC_TOP.IOBUF_PAD[7], `SOC_TOP.IOBUF_PAD[6], `SOC_TOP.IOBUF_PAD[5], `SOC_TOP.IOBUF_PAD[4], `SOC_TOP.IOBUF_PAD[3], `SOC_TOP.IOBUF_PAD[2], `SOC_TOP.IOBUF_PAD[1]};  
    `nnc_info("ATM2",$sformatf("D2A_CLDO1P8_TRIM = %5b", {1'b0, top_test_cfg.save_trim_wdata[2][3:0]}), NNC_LOW)
    `nnc_info("ATM2",$sformatf("D2A_LDO_2P8_PUMP_TRIM = %2b", top_test_cfg.save_trim_wdata[2][5:4]), NNC_LOW)
    `nnc_info("ATM2",$sformatf("D2A_CS_PGA_CLK_TRIM = %1b", top_test_cfg.save_trim_wdata[2][6]), NNC_LOW)

    #1000us;
  `ifdef BEHAVIORAL    
    top_test_cfg.atm = {`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[0],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[1],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[2],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[3],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[4],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[5],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[6],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[7]};
`else
    top_test_cfg.atm = {`ANA_WRAPPER_TOP.D2A_ATM0,`ANA_WRAPPER_TOP.D2A_ATM1,`ANA_WRAPPER_TOP.D2A_ATM2,`ANA_WRAPPER_TOP.D2A_ATM3,`ANA_WRAPPER_TOP.D2A_ATM4,`ANA_WRAPPER_TOP.D2A_ATM5,`ANA_WRAPPER_TOP.D2A_ATM6,`ANA_WRAPPER_TOP.D2A_ATM7};
`endif    
    // Checking ATM
    if (top_test_cfg.atm !== (8'b1000_0000 >> `SOC_TOP.IOBUF_PAD[10:8]))
      begin
        `nnc_error("ATM2", $sformatf("ATM[0:7] = %b is not as expectation of ATM = %b", top_test_cfg.atm, (8'b1000_0000 >> `SOC_TOP.IOBUF_PAD[10:8])))
      end   

    top_test_cfg.atm = {`ANA_TOP.D2A_ATM0,`ANA_TOP.D2A_ATM1,`ANA_TOP.D2A_ATM2,`ANA_TOP.D2A_ATM3,`ANA_TOP.D2A_ATM4,`ANA_TOP.D2A_ATM5,`ANA_TOP.D2A_ATM6,`ANA_TOP.D2A_ATM7};
    if (top_test_cfg.atm !== (8'b1000_0000 >> `SOC_TOP.IOBUF_PAD[10:8]))
      begin
        `nnc_error("ATM2", $sformatf("ATM[0:7] = %b is not as expectation of ATM = %b", top_test_cfg.atm, (8'b1000_0000 >> `SOC_TOP.IOBUF_PAD[10:8])))
      end   

    //release  `SOC_TOP.IOBUF_PAD[7:1];   

    // ===================================
    // ATM3 Operation - OSC2MHZ_TRIM 
    // ===================================
    `uvm_info("",$sformatf("Enter ATM3 Operation"),NNC_LOW) 
    `DUT_IF.testmode_sel = 2'b11;  
           
    force `SOC_TOP.IOBUF_PAD[10:8] = 3'b011; 
    #1000ns; //change atm_mode -> set trim data

    force `SOC_TOP.IOBUF_PAD[7:1] = $random;
    #10000;

    top_test_cfg.save_trim_wdata[3] = {1'b0,`SOC_TOP.IOBUF_PAD[7], `SOC_TOP.IOBUF_PAD[6], `SOC_TOP.IOBUF_PAD[5], `SOC_TOP.IOBUF_PAD[4], `SOC_TOP.IOBUF_PAD[3], `SOC_TOP.IOBUF_PAD[2], `SOC_TOP.IOBUF_PAD[1]};  
    `nnc_info("ATM3",$sformatf("D2A_OSC2MHZ_TRIM = %8b", top_test_cfg.save_trim_wdata[3]), NNC_LOW)

    #1000us;
  `ifdef BEHAVIORAL    
    top_test_cfg.atm = {`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[0],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[1],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[2],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[3],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[4],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[5],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[6],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[7]};
`else
    top_test_cfg.atm = {`ANA_WRAPPER_TOP.D2A_ATM0,`ANA_WRAPPER_TOP.D2A_ATM1,`ANA_WRAPPER_TOP.D2A_ATM2,`ANA_WRAPPER_TOP.D2A_ATM3,`ANA_WRAPPER_TOP.D2A_ATM4,`ANA_WRAPPER_TOP.D2A_ATM5,`ANA_WRAPPER_TOP.D2A_ATM6,`ANA_WRAPPER_TOP.D2A_ATM7};
`endif    
    // Checking ATM
    if (top_test_cfg.atm !== (8'b1000_0000 >> `SOC_TOP.IOBUF_PAD[10:8]))
      begin
        `nnc_error("ATM3", $sformatf("ATM[0:7] = %b is not as expectation of ATM = %b", top_test_cfg.atm, (8'b1000_0000 >> `SOC_TOP.IOBUF_PAD[10:8])))
      end   

    top_test_cfg.atm = {`ANA_TOP.D2A_ATM0,`ANA_TOP.D2A_ATM1,`ANA_TOP.D2A_ATM2,`ANA_TOP.D2A_ATM3,`ANA_TOP.D2A_ATM4,`ANA_TOP.D2A_ATM5,`ANA_TOP.D2A_ATM6,`ANA_TOP.D2A_ATM7};
    if (top_test_cfg.atm !== (8'b1000_0000 >> `SOC_TOP.IOBUF_PAD[10:8]))
      begin
        `nnc_error("ATM3", $sformatf("ATM[0:7] = %b is not as expectation of ATM = %b", top_test_cfg.atm, (8'b1000_0000 >> `SOC_TOP.IOBUF_PAD[10:8])))
      end   

    //release  `SOC_TOP.IOBUF_PAD[7:1];   

    // =====================================================================================================
    // ATM4 Operation - D2A_VDAC_TRIM_CH1 - D2A_CS_TRIM_CH1 - D2A_PUMP_CLK_TRIM_CH1 - D2A_PUMP_CLK_TRIM_CH2
    // =====================================================================================================
    `uvm_info("",$sformatf("Enter ATM4 Operation"),NNC_LOW)
    `DUT_IF.testmode_sel = 2'b11;  
            
    force `SOC_TOP.IOBUF_PAD[10:8] = 3'b100; 
    #1000ns; //change atm_mode -> set trim data

    force `SOC_TOP.IOBUF_PAD[7:1] = $random;
    #10000;

    top_test_cfg.save_trim_wdata[4] = {1'b0,`SOC_TOP.IOBUF_PAD[7], `SOC_TOP.IOBUF_PAD[6], `SOC_TOP.IOBUF_PAD[5], `SOC_TOP.IOBUF_PAD[4], `SOC_TOP.IOBUF_PAD[3], `SOC_TOP.IOBUF_PAD[2], `SOC_TOP.IOBUF_PAD[1]};  
    `nnc_info("ATM4",$sformatf("D2A_VDAC_TRIM_CH1 = %3b", top_test_cfg.save_trim_wdata[4][2:0]), NNC_LOW)
    `nnc_info("ATM4",$sformatf("D2A_CS_TRIM_CH1 = %3b", {1'b0, top_test_cfg.save_trim_wdata[4][4:3]}), NNC_LOW)
    `nnc_info("ATM4",$sformatf("D2A_PUMP_CLK_TRIM_CH1 = %1b", top_test_cfg.save_trim_wdata[4][5]), NNC_LOW)
    `nnc_info("ATM4",$sformatf("D2A_PUMP_CLK_TRIM_CH2 = %1b", top_test_cfg.save_trim_wdata[4][6]), NNC_LOW)

    #1000us;
  `ifdef BEHAVIORAL    
    top_test_cfg.atm = {`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[0],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[1],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[2],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[3],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[4],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[5],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[6],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[7]};
`else
    top_test_cfg.atm = {`ANA_WRAPPER_TOP.D2A_ATM0,`ANA_WRAPPER_TOP.D2A_ATM1,`ANA_WRAPPER_TOP.D2A_ATM2,`ANA_WRAPPER_TOP.D2A_ATM3,`ANA_WRAPPER_TOP.D2A_ATM4,`ANA_WRAPPER_TOP.D2A_ATM5,`ANA_WRAPPER_TOP.D2A_ATM6,`ANA_WRAPPER_TOP.D2A_ATM7};
`endif    
    // Checking ATM
    if (top_test_cfg.atm !== (8'b1000_0000 >> `SOC_TOP.IOBUF_PAD[10:8]))
      begin
        `nnc_error("ATM4", $sformatf("ATM[0:7] = %b is not as expectation of ATM = %b", top_test_cfg.atm, (8'b1000_0000 >> `SOC_TOP.IOBUF_PAD[10:8])))
      end   

    top_test_cfg.atm = {`ANA_TOP.D2A_ATM0,`ANA_TOP.D2A_ATM1,`ANA_TOP.D2A_ATM2,`ANA_TOP.D2A_ATM3,`ANA_TOP.D2A_ATM4,`ANA_TOP.D2A_ATM5,`ANA_TOP.D2A_ATM6,`ANA_TOP.D2A_ATM7};
    if (top_test_cfg.atm !== (8'b1000_0000 >> `SOC_TOP.IOBUF_PAD[10:8]))
      begin
        `nnc_error("ATM4", $sformatf("ATM[0:7] = %b is not as expectation of ATM = %b", top_test_cfg.atm, (8'b1000_0000 >> `SOC_TOP.IOBUF_PAD[10:8])))
      end   

    //release  `SOC_TOP.IOBUF_PAD[7:1];   

    // ===================================
    // ATM5 Operation - D2A_VDAC_TRIM_CH2 - D2A_CS_TRIM_CH2 - D2A_LDO2P8_PUMP_TRIM_CH2
    // ===================================
    `uvm_info("",$sformatf("Enter ATM5 Operation"),NNC_LOW) 
    `DUT_IF.testmode_sel = 2'b11;  
           
    force `SOC_TOP.IOBUF_PAD[10:8] = 3'b101; 
    #1000ns; //change atm_mode -> set trim data

    force `SOC_TOP.IOBUF_PAD[7:1] = $random;
    #10000;

    top_test_cfg.save_trim_wdata[5] = {1'b0,`SOC_TOP.IOBUF_PAD[7], `SOC_TOP.IOBUF_PAD[6], `SOC_TOP.IOBUF_PAD[5], `SOC_TOP.IOBUF_PAD[4], `SOC_TOP.IOBUF_PAD[3], `SOC_TOP.IOBUF_PAD[2], `SOC_TOP.IOBUF_PAD[1]};  
    `nnc_info("ATM5",$sformatf("D2A_VDAC_TRIM_CH2 = %3b", top_test_cfg.save_trim_wdata[5][2:0]), NNC_LOW)
    `nnc_info("ATM5",$sformatf("D2A_CS_TRIM_CH2 = %3b", {1'b0, top_test_cfg.save_trim_wdata[5][4:3]}), NNC_LOW)
    `nnc_info("ATM5",$sformatf("D2A_LDO2P8_PUMP_TRIM_CH2 = %2b", top_test_cfg.save_trim_wdata[5][6:5]), NNC_LOW)

    #1000us;
  `ifdef BEHAVIORAL    
    top_test_cfg.atm = {`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[0],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[1],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[2],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[3],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[4],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[5],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[6],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[7]};
`else
    top_test_cfg.atm = {`ANA_WRAPPER_TOP.D2A_ATM0,`ANA_WRAPPER_TOP.D2A_ATM1,`ANA_WRAPPER_TOP.D2A_ATM2,`ANA_WRAPPER_TOP.D2A_ATM3,`ANA_WRAPPER_TOP.D2A_ATM4,`ANA_WRAPPER_TOP.D2A_ATM5,`ANA_WRAPPER_TOP.D2A_ATM6,`ANA_WRAPPER_TOP.D2A_ATM7};
`endif    

    // Checking ATM
    if (top_test_cfg.atm !== (8'b1000_0000 >> `SOC_TOP.IOBUF_PAD[10:8]))
      begin
        `nnc_error("ATM5", $sformatf("ATM[0:7] = %b is not as expectation of ATM = %b", top_test_cfg.atm, (8'b1000_0000 >> `SOC_TOP.IOBUF_PAD[10:8])))
      end   

    top_test_cfg.atm = {`ANA_TOP.D2A_ATM0,`ANA_TOP.D2A_ATM1,`ANA_TOP.D2A_ATM2,`ANA_TOP.D2A_ATM3,`ANA_TOP.D2A_ATM4,`ANA_TOP.D2A_ATM5,`ANA_TOP.D2A_ATM6,`ANA_TOP.D2A_ATM7};
    if (top_test_cfg.atm !== (8'b1000_0000 >> `SOC_TOP.IOBUF_PAD[10:8]))
      begin
        `nnc_error("ATM5", $sformatf("ATM[0:7] = %b is not as expectation of ATM = %b", top_test_cfg.atm, (8'b1000_0000 >> `SOC_TOP.IOBUF_PAD[10:8])))
      end   

    //release  `SOC_TOP.IOBUF_PAD[7:1]; 
    
    // ===================================================
    // ATM6 Operation -D2A_IBAS_IDAC_TRIM - D2A_TSC_TRIM
    // ===================================================
    `uvm_info("",$sformatf("Enter ATM6 Operation"),NNC_LOW) 
    `DUT_IF.testmode_sel = 2'b11;  
           
    force `SOC_TOP.IOBUF_PAD[10:8] = 3'b110; 
    #1000ns; //change atm_mode -> set trim data

    force `SOC_TOP.IOBUF_PAD[7:1] = $random;

    #10000;

    top_test_cfg.save_trim_wdata[6] = {1'b0,`SOC_TOP.IOBUF_PAD[7], `SOC_TOP.IOBUF_PAD[6], `SOC_TOP.IOBUF_PAD[5], `SOC_TOP.IOBUF_PAD[4], `SOC_TOP.IOBUF_PAD[3], `SOC_TOP.IOBUF_PAD[2], `SOC_TOP.IOBUF_PAD[1]};  
    `nnc_info("ATM6",$sformatf("D2A_IBAS_IDAC_TRIM = %4b", {1'b0, top_test_cfg.save_trim_wdata[6][2:0]}), NNC_LOW)
    `nnc_info("ATM6",$sformatf("D2A_TSC_TRIM = %6b", top_test_cfg.save_trim_wdata[6][6:3]), NNC_LOW)

    #1000us;
  `ifdef BEHAVIORAL    
    top_test_cfg.atm = {`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[0],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[1],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[2],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[3],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[4],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[5],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[6],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[7]};
`else
    top_test_cfg.atm = {`ANA_WRAPPER_TOP.D2A_ATM0,`ANA_WRAPPER_TOP.D2A_ATM1,`ANA_WRAPPER_TOP.D2A_ATM2,`ANA_WRAPPER_TOP.D2A_ATM3,`ANA_WRAPPER_TOP.D2A_ATM4,`ANA_WRAPPER_TOP.D2A_ATM5,`ANA_WRAPPER_TOP.D2A_ATM6,`ANA_WRAPPER_TOP.D2A_ATM7};
`endif   
    // Checking ATM
    if (top_test_cfg.atm !== (8'b1000_0000 >> `SOC_TOP.IOBUF_PAD[10:8]))
      begin
        `nnc_error("ATM6", $sformatf("ATM[0:7] = %b is not as expectation of ATM = %b", top_test_cfg.atm, (8'b1000_0000 >> `SOC_TOP.IOBUF_PAD[10:8])))
      end   

    top_test_cfg.atm = {`ANA_TOP.D2A_ATM0,`ANA_TOP.D2A_ATM1,`ANA_TOP.D2A_ATM2,`ANA_TOP.D2A_ATM3,`ANA_TOP.D2A_ATM4,`ANA_TOP.D2A_ATM5,`ANA_TOP.D2A_ATM6,`ANA_TOP.D2A_ATM7};
    if (top_test_cfg.atm !== (8'b1000_0000 >> `SOC_TOP.IOBUF_PAD[10:8]))
      begin
        `nnc_error("ATM6", $sformatf("ATM[0:7] = %b is not as expectation of ATM = %b", top_test_cfg.atm, (8'b1000_0000 >> `SOC_TOP.IOBUF_PAD[10:8])))
      end   

    //release  `SOC_TOP.IOBUF_PAD[7:1]; 
     
    // ===================================
    // ATM7 Operation
    // ===================================
    `uvm_info("",$sformatf("Enter ATM7 Operation"),NNC_LOW)    
    `DUT_IF.testmode_sel = 2'b11;  

    force `SOC_TOP.IOBUF_PAD[10:8] = 3'b111; 
    #1000ns; //change atm_mode -> set trim data

    force `SOC_TOP.IOBUF_PAD[7:1] = $random;
    #10us; //#10000;

    top_test_cfg.save_trim_wdata[7] = {1'b0,`SOC_TOP.IOBUF_PAD[7], `SOC_TOP.IOBUF_PAD[6], `SOC_TOP.IOBUF_PAD[5], `SOC_TOP.IOBUF_PAD[4], `SOC_TOP.IOBUF_PAD[3], `SOC_TOP.IOBUF_PAD[2], `SOC_TOP.IOBUF_PAD[1]};  
    `nnc_info("ATM6",$sformatf("D2A_TRIM0_SPARE = %8b", top_test_cfg.save_trim_wdata[7]), NNC_LOW)

    #1ms; //#1000us;
  `ifdef BEHAVIORAL    
    top_test_cfg.atm = {`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[0],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[1],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[2],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[3],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[4],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[5],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[6],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[7]};
`else
    top_test_cfg.atm = {`ANA_WRAPPER_TOP.D2A_ATM0,`ANA_WRAPPER_TOP.D2A_ATM1,`ANA_WRAPPER_TOP.D2A_ATM2,`ANA_WRAPPER_TOP.D2A_ATM3,`ANA_WRAPPER_TOP.D2A_ATM4,`ANA_WRAPPER_TOP.D2A_ATM5,`ANA_WRAPPER_TOP.D2A_ATM6,`ANA_WRAPPER_TOP.D2A_ATM7};
`endif     
    // Checking ATM
    if (top_test_cfg.atm !== (8'b1000_0000 >> `SOC_TOP.IOBUF_PAD[10:8]))
      begin
        `nnc_error("ATM7", $sformatf("ATM[0:7] = %b is not as expectation of ATM = %b", top_test_cfg.atm, (8'b1000_0000 >> `SOC_TOP.IOBUF_PAD[10:8])))
      end    

    top_test_cfg.atm = {`ANA_TOP.D2A_ATM0,`ANA_TOP.D2A_ATM1,`ANA_TOP.D2A_ATM2,`ANA_TOP.D2A_ATM3,`ANA_TOP.D2A_ATM4,`ANA_TOP.D2A_ATM5,`ANA_TOP.D2A_ATM6,`ANA_TOP.D2A_ATM7};
    if (top_test_cfg.atm !== (8'b1000_0000 >> `SOC_TOP.IOBUF_PAD[10:8]))
      begin
        `nnc_error("ATM7", $sformatf("ATM[0:7] = %b is not as expectation of ATM = %b", top_test_cfg.atm, (8'b1000_0000 >> `SOC_TOP.IOBUF_PAD[10:8])))
      end   

    //release  `SOC_TOP.IOBUF_PAD[7:1];
    // =============================================================
    // ATM0 Operation (Step 8) - Save BG_TRIM at step 1 to this step
    // =============================================================
    `uvm_info("",$sformatf("Enter ATM0 Operation"),NNC_LOW)

    assert(top_test_cfg.randomize() with { otp_program_en == 1; });
    `DUT_IF.otp_program_en = top_test_cfg.otp_program_en;
    `DUT_IF.otp_vpp_delay = top_test_cfg.otp_vpp_delay;

      
    force `SOC_TOP.IOBUF_PAD[10:8] = 3'b000; 
    #1000ns;
 
    force `SOC_TOP.IOBUF_PAD[7:1] = $random(0);
    #10us;

    top_test_cfg.save_trim_wdata[0] = {2'b0, `SOC_TOP.IOBUF_PAD[6], `SOC_TOP.IOBUF_PAD[5], `SOC_TOP.IOBUF_PAD[4], `SOC_TOP.IOBUF_PAD[3], `SOC_TOP.IOBUF_PAD[2], `SOC_TOP.IOBUF_PAD[1]}; 
    `nnc_info("ATM0",$sformatf("D2A_BG_TRIM = %8b",top_test_cfg.save_trim_wdata[0]), NNC_LOW) 

    #1ms;

  `ifdef BEHAVIORAL    
    top_test_cfg.atm = {`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[0],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[1],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[2],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[3],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[4],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[5],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[6],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[7]};
`else
    top_test_cfg.atm = {`ANA_WRAPPER_TOP.D2A_ATM0,`ANA_WRAPPER_TOP.D2A_ATM1,`ANA_WRAPPER_TOP.D2A_ATM2,`ANA_WRAPPER_TOP.D2A_ATM3,`ANA_WRAPPER_TOP.D2A_ATM4,`ANA_WRAPPER_TOP.D2A_ATM5,`ANA_WRAPPER_TOP.D2A_ATM6,`ANA_WRAPPER_TOP.D2A_ATM7};
`endif    
    // Checking ATM
    if (top_test_cfg.atm !== (8'b1000_0000 >> `SOC_TOP.IOBUF_PAD[10:8]))
      begin
        `nnc_error("ATM0", $sformatf("ATM[0:7] = %b is not as expectation of ATM = %b", top_test_cfg.atm, (8'b1000_0000 >> `SOC_TOP.IOBUF_PAD[10:8])))
      end   

    top_test_cfg.atm = {`ANA_TOP.D2A_ATM0,`ANA_TOP.D2A_ATM1,`ANA_TOP.D2A_ATM2,`ANA_TOP.D2A_ATM3,`ANA_TOP.D2A_ATM4,`ANA_TOP.D2A_ATM5,`ANA_TOP.D2A_ATM6,`ANA_TOP.D2A_ATM7};
    if (top_test_cfg.atm !== (8'b1000_0000 >> `SOC_TOP.IOBUF_PAD[10:8]))
      begin
        `nnc_error("ATM0", $sformatf("ATM[0:7] = %b is not as expectation of ATM = %b", top_test_cfg.atm, (8'b1000_0000 >> `SOC_TOP.IOBUF_PAD[10:8])))
      end       

    #100us;

    `nnc_info("SOC","Enable OTP Unlock", NNC_LOW)
    release  `SOC_TOP.IOBUF_PAD[7];
    force `SOC_TB.UNLOCK = 1'b1;//OTP_UNLOCK 
       
    wait(`SOC_TB.IOBUF_PAD[7] === 0);

    #10ms; 
    `nnc_info("DATA in GPIO",$sformatf("DATA0 = %h", top_test_cfg.save_trim_wdata[0]), NNC_LOW)
    `nnc_info("DATA in GPIO",$sformatf("DATA1 = %h", top_test_cfg.save_trim_wdata[1]), NNC_LOW)
    `nnc_info("DATA in GPIO",$sformatf("DATA2 = %h", top_test_cfg.save_trim_wdata[2]), NNC_LOW)
    `nnc_info("DATA in GPIO",$sformatf("DATA3 = %h", top_test_cfg.save_trim_wdata[3]), NNC_LOW)
    `nnc_info("DATA in GPIO",$sformatf("DATA4 = %h", top_test_cfg.save_trim_wdata[4]), NNC_LOW)
    `nnc_info("DATA in GPIO",$sformatf("DATA5 = %h", top_test_cfg.save_trim_wdata[5]), NNC_LOW)
    `nnc_info("DATA in GPIO",$sformatf("DATA6 = %h", top_test_cfg.save_trim_wdata[6]), NNC_LOW)
    `nnc_info("DATA in GPIO",$sformatf("DATA7 = %h", top_test_cfg.save_trim_wdata[7]), NNC_LOW)

    `nnc_info("DATA in OTP",$sformatf("DATA0 = %h at address: 0x04", ~top_test_cfg.save_trim_wdata[0]), NNC_LOW)
    `nnc_info("DATA in OTP",$sformatf("DATA1 = %h at address: 0x05", ~top_test_cfg.save_trim_wdata[1]), NNC_LOW)
    `nnc_info("DATA in OTP",$sformatf("DATA2 = %h at address: 0x06", ~top_test_cfg.save_trim_wdata[2]), NNC_LOW)
    `nnc_info("DATA in OTP",$sformatf("DATA3 = %h at address: 0x07", ~top_test_cfg.save_trim_wdata[3]), NNC_LOW)
    `nnc_info("DATA in OTP",$sformatf("DATA4 = %h at address: 0x08", ~top_test_cfg.save_trim_wdata[4]), NNC_LOW)
    `nnc_info("DATA in OTP",$sformatf("DATA5 = %h at address: 0x09", ~top_test_cfg.save_trim_wdata[5]), NNC_LOW)
    `nnc_info("DATA in OTP",$sformatf("DATA6 = %h at address: 0x0A", ~top_test_cfg.save_trim_wdata[6]), NNC_LOW)
    `nnc_info("DATA in OTP",$sformatf("DATA7 = %h at address: 0x0B", ~top_test_cfg.save_trim_wdata[7]), NNC_LOW)

    force `SOC_TB.UNLOCK = 1'b0;//OTP_UNLOCK

    release  `SOC_TOP.IOBUF_PAD[7:1]; 
    release `SOC_TB.UNLOCK;
    // ===================================
    // Changing to use BIST 
    // ===================================
    assert(top_test_cfg.randomize() with { otp_program_en == 0; });
    `DUT_IF.otp_program_en = top_test_cfg.otp_program_en;
    `DUT_IF.otp_vpp_delay = top_test_cfg.otp_vpp_delay;

`ifndef MIX_SIM_EN
    //force `SOC_TB.iopad_resetn =1'b0;  //force `ANA_TOP.PMU_SW.CHIP_EN = 0;
    force `ANA_TOP.PMU_SW.DVDD = 1'b0; //in testmode LDO  not connected to DVDD so need provide external supply 1.8v
`endif
    //wait(`SOC_TB.VDD_DIG === 0);

    #1000ns;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b10;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #150us;
    
`ifndef MIX_SIM_EN
    //force `SOC_TB.iopad_resetn =1'b1; //force `ANA_TOP.PMU_SW.CHIP_EN = 1;
    force `ANA_TOP.PMU_SW.DVDD = 1'b1; //in testmode LDO  not connected to DVDD so need provide external supply 1.8v
`endif
    //wait(`SOC_TB.VDD_DIG === 1);
    
    #150us;
    `nnc_info("SOC_TEST", "[EPROM BIST MASTER][0] Sending Reset Command to EPROM", NNC_LOW);
    `BISTM_RESET;
    `nnc_info("SOC_TEST", "[EPROM BIST MASTER] Complete successully this phase", NNC_LOW);
    
    #150us;
    
    for(int i=0; i<8'h0C; i++) begin
        `BISTM_SINGLE_READ(top_test_cfg.OTP_SEL, i, top_test_cfg.rd_data[i]);
        #10000;        
        // Daniel -> must add comparison
    end

    for(int i=0; i<8 ; i++) begin
        if (top_test_cfg.save_trim_wdata[i] !== `EPROM_BIST_IF.rd_data[i+4][7:0]) 
           `nnc_error("SOC_TEST", $sformatf("save_trim_wdata %8b !== bist_rd_data %8b!!!", top_test_cfg.save_trim_wdata[i], `EPROM_BIST_IF.rd_data[i+4][7:0]))
        else 
           `nnc_info("SOC_TEST", $sformatf("save_trim_wdata %8b === bist_rd_data %8b!!!", top_test_cfg.save_trim_wdata[i], `EPROM_BIST_IF.rd_data[i+4][7:0]), NNC_LOW)
    end

    if (top_test_cfg.trim_tag_prepare_en === 1'b1) begin  
      `nnc_info("SOC_TEST", "[EPROM BIST MASTER] TRIM TAG is written by BIST", NNC_LOW);  
      `BISTM_SINGLE_PROGRAM(top_test_cfg.OTP_SEL, 0, 8'h5a, top_test_cfg.vpp_pos_cnt, top_test_cfg.vpp_width);  
    end
    else
      `nnc_info("SOC_TEST", "[EPROM BIST MASTER] TRIM TAG is used in Shadow Reg Default", NNC_LOW);
/*    
    #10ms;  
    // ===================================
    // Changing to use NORMAL Mode 
    // ===================================
    force `ANA_TOP.PMU_SW.CHIP_EN = 0;
    //wait(`SOC_TB.VDD_DIG === 0);
    force `SOC_TB.VDD_DIG = 0;

    #1000ns;
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b00; pinmux_mode == 1;})
    `DUT_IF.pinmux_mode = top_test_cfg.pinmux_mode; 
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    #150us;
    force `ANA_TOP.PMU_SW.CHIP_EN = 1;
    //wait(`SOC_TB.VDD_DIG === 1);
    force `SOC_TB.VDD_DIG = 1;       

    // Wait the chip reset successfully
    //wait(`DUT_IF.soc_resetn); 
    
    top_test_cfg.rd_data=new[8];  
    
    // wait reload done
    //do begin
    //   assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_DEBUG_1_REG; no_of_bytes == 1;});
    //   `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
    //end while (top_test_cfg.rd_data[0][5] !== 1'b1);
 
    // read trim_reg
    `nnc_info("",$sformatf("read trim_reg"),NNC_LOW)
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_TRIM_1_REG; no_of_bytes == 8; });
    `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
  
    for(int i=0; i<8 ; i++) begin
        if(top_test_cfg.save_trim_wdata[i] !== top_test_cfg.rd_data[7-i][6:0]) 
          `nnc_error("SOC_TEST", $sformatf("save_trim_wdata %7b !== rd_data %7b!!!", top_test_cfg.save_trim_wdata[i], top_test_cfg.rd_data[7-i][6:0]))
        else 
          `nnc_info("SOC_TEST", $sformatf("save_trim_wdata %7b === rd_data %7b!!!", top_test_cfg.save_trim_wdata[i], top_test_cfg.rd_data[7-i][6:0]), NNC_LOW) 
    end
*/                 
    end
  endtask 

  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction

endclass : `TESTNAME    
