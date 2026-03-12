/*--------------------------------------------------------------------------------------
// Copyright 1616 Nanochap, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_pinmux_bistmode_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_pinmux_bistmode_test                                             
// Designer	: ddang@nanochap.com                                                                 
// Date		: 29-11-1623                                                                     
// Revision	: 0.1 Initial version created by script                                 
--------------------------------------------------------------------------------------*/
`define TESTNAME soc_pinmux_bistmode_test
`define TESTCFG soc_pinmux_bistmode_test_cfg

class `TESTCFG extends soc_base_test_cfg;

  `nnc_object_utils(`TESTCFG)

  // -----------------------------------------------
  // Adding your new varialbles in config test
  // -----------------------------------------------
  rand logic [7:0] data[256];
  rand int         no_of_bytes; 
  rand logic [7:0] reg_addr;
  rand logic [7:0] cmd;  
  logic [7:0] read_data[];
  logic [8:0] atm;
  
  // -----------------------------------------------
  // End of decalration of new variables 
  // -----------------------------------------------

  function new (string name = "soc_pinmux_bistmode_test_cfg");
    super.new(name);
    
  endfunction: new

  // -----------------------------------------------
  // Adding constraints of randomization
  // -----------------------------------------------
  // testmode_sel[1:0] : 00-Normal mode, 01: Scanmode, 10: BIST mode, 11 atm0/1/2/3/4
  constraint c_testmode_sel { soft testmode_sel == 2'b00; }
  
  constraint c_pinmux_mode { soft pinmux_mode == 1'b0; }

  // No of bytes in a burst
  constraint c_no_of_bytes { soft no_of_bytes == 2; }

  constraint c_io_model_check_off { io_model_check_off == 1'b1; }  

  constraint c_otp_ignore_check_en { otp_ignore_check_en == 1'b1; }

  // -----------------------------------------------
  // End of adding constraints of randomization
  // -----------------------------------------------

endclass : `TESTCFG

class `TESTNAME extends soc_base_test;
    static bit rand_bit;   
    static logic [20:0] rand_num;
    static bit scan_clk = 0;
    logic [7:0] data [0:255];   

  `nnc_component_utils(`TESTNAME)

  `TESTCFG top_test_cfg;
  
  function new(string name, nnc_component parent);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(nnc_phase phase);
    super.build_phase(phase);
    `nnc_top.set_timeout(2s);
    top_test_cfg = `TESTCFG::type_id::create("top_test_cfg", this);
  endfunction

  virtual task pre_reset_phase(nnc_phase phase);
    phase.raise_objection(this);

    super.pre_reset_phase(phase);

    assert(top_test_cfg.randomize());

    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    `DUT_IF.pinmux_mode = top_test_cfg.pinmux_mode;
    `DUT_IF.otp_ignore_check_en = top_test_cfg.otp_ignore_check_en;    

    `SPI_SCB_EN = 1'b0;
    `ANALOG_SCOREBOARD_EN = 1'b0;
    `WAVEGEN_SCB_DRV_0_EN = 1'b0;
    `WAVEGEN_SHORT_DETECT_SCB_EN = 1'b0;

    // ==================
    // Scoreboard enables
    // ==================

    phase.drop_objection(this);
  endtask : pre_reset_phase

  virtual task main_phase(nnc_phase phase);
    phase.raise_objection(this);

    `nnc_info("SOC_TEST", "soc_pinmux_bistmode_test start", NNC_LOW)

    // ----------------------------------------------------------------------------------
    // Please add your code of your test here
    // ---------------------------------------------------------------------------------- 

    // This is sample to write a data to Register
    `nnc_info("BIST_MODE","Internal clock test",NNC_MEDIUM) 
    `DUT_IF.pinmux_mode = 1; 
    `DUT_IF.io_model_check_off = 1;       
    //fork
    //  gen_clk;
    //join_none

    #1000ns;
    //force `SOC_TOP.IOBUF_PU[1] = 1'b1; 
    force `DIG_TOP.u_pinmux.o_ens2_IOBUF_OE[4] = 1;
    
    do_run;
            
    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ----------------------------------------------------------------------------------
    phase.drop_objection(this);
  endtask: main_phase

  //task gen_clk;    
  //  forever #100ns  scan_clk = ~scan_clk;
  //endtask : gen_clk

  virtual task do_run;
    begin
`ifndef FPGA
    // select TEST_MODE, PAD: TEST_MODE0=0, TEST_MODE1=1
    // Checking pin testmode
    `DUT_IF.testmode_sel = 2'b10;    
    `DUT_IF.iopad_gpio[`GPIO_NUM-1:0] = 16'b0;   

    `PINMUX_SCOREBOARD_EN = 1'b1;

    #100000ns;
 `ifdef BEHAVIORAL    
    top_test_cfg.atm = {`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[0],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[1],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[2],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[3],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[4],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[5],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[6],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[7]};
`else
    top_test_cfg.atm = {`ANA_WRAPPER_TOP.D2A_ATM0,`ANA_WRAPPER_TOP.D2A_ATM1,`ANA_WRAPPER_TOP.D2A_ATM2,`ANA_WRAPPER_TOP.D2A_ATM3,`ANA_WRAPPER_TOP.D2A_ATM4,`ANA_WRAPPER_TOP.D2A_ATM5,`ANA_WRAPPER_TOP.D2A_ATM6,`ANA_WRAPPER_TOP.D2A_ATM7};
`endif  
  
    // ------------------------------------------------------- 
    // Checking ATM
    // -------------------------------------------------------
    if (top_test_cfg.atm !== 8'b0)
      begin
        `nnc_error("BIST_MODE", $sformatf("ATM[0:7] = %b is not as expectation of ATM = %b", top_test_cfg.atm, (8'b1000_0000 >> `SOC_TOP.IOBUF_PAD[10:8]-1)))
      end      

    // -------------------------------------------------------
    // Checking pin TCK
    // -------------------------------------------------------
    for (int i=0; i < 100; i++) begin
      force `SOC_TOP.IOBUF_PAD[0] = $random;
      #10000ns;
      rand_bit = `SOC_TOP.IOBUF_PAD[0];
      if (`DIG_TOP.u_pinmux.otp_bist_tck!== rand_bit) begin
        `nnc_error("BIST_MODE", $sformatf("`DIG_TOP.u_pinmux.otp_bist_tck = %b is not as expectation of = %b", `DIG_TOP.u_pinmux.otp_bist_tck, rand_bit));
      end
      release  `SOC_TOP.IOBUF_PAD[0];
    end
    force `SOC_TOP.IOBUF_PAD[0] = scan_clk;
 
    // -------------------------------------------------------
    // Checking pin RESETb
    // -------------------------------------------------------
    for (int i=0; i < 100; i++) begin
      force `SOC_TB.iopad_resetn = $random;
      #10000ns;
      rand_bit = `SOC_TB.iopad_resetn;
      `ifdef POSTLAYOUT_PG
         if (`RST_CTRL_TOP.otp_bist_resetn!== rand_bit) begin
           `nnc_error("BISTMODE", $sformatf("`DIG_TOP.u_pinmux.otp_bist_resetn = %b is not as expectation of = %b", `RST_CTRL_TOP.otp_bist_resetn, rand_bit));
         end
      `else
         if (`DIG_TOP.u_pinmux.otp_bist_resetn!== rand_bit) begin
           `nnc_error("BIST_MODE", $sformatf("`DIG_TOP.u_pinmux.otp_bist_resetn = %b is not as expectation of = %b", `DIG_TOP.u_pinmux.otp_bist_resetn, rand_bit));
         end
      `endif 
      release  `SOC_TB.iopad_resetn;
    end

    // -------------------------------------------------------
    // Checking pin TDI
    // -------------------------------------------------------

    // Set STROBE to be 0 (low active to transfer TDI)
    force `SOC_TOP.IOBUF_PAD[5] = 1'b0;

`ifndef POSTLAYOUT_PG        
    for (int i=0; i < 100; i++) begin
      force `SOC_TOP.IOBUF_PAD[6] = $random;
      #10000ns;
      rand_bit = `SOC_TOP.IOBUF_PAD[6];
      if (`DIG_TOP.u_pinmux.otp_bist_tdi!== rand_bit) begin
        `nnc_error("BIST_MODE", $sformatf("`DIG_TOP.u_pinmux.otp_bist_tdi = %b is not as expectation of = %b", `DIG_TOP.u_pinmux.otp_bist_tdi, rand_bit));
      end

      if (`EPROM_BIST_TOP.TDI!== rand_bit) begin
        `nnc_error("BIST_MODE", $sformatf("`EPROM_BIST_TOP.TDI = %b is not as expectation of = %b", `EPROM_BIST_TOP.TDI, rand_bit));
      end

      release  `SOC_TOP.IOBUF_PAD[6];
    end
`else
    for (int i=0; i < 100; i++) begin
      force `SOC_TOP.IOBUF_PAD[6] = $random;
      #10000ns;
      rand_bit = `SOC_TOP.IOBUF_PAD[6];
      if (`EPROM_BIST_TOP.TDI!== rand_bit) begin
        `nnc_error("BIST_MODE", $sformatf("`EPROM_BIST_TOP.TDI = %b is not as expectation of = %b", `EPROM_BIST_TOP.TDI, rand_bit));
      end
      release  `SOC_TOP.IOBUF_PAD[6];
    end
`endif    
    release  `SOC_TOP.IOBUF_PAD[5];


    // -------------------------------------------------------
    // Checking pin STROBE
    // -------------------------------------------------------
`ifndef POSTLAYOUT_PG            
    for (int i=0; i < 100; i++) begin
      force `SOC_TOP.IOBUF_PAD[5] = $random;
      #10000ns;
      rand_bit = `SOC_TOP.IOBUF_PAD[5];

      if (`DIG_TOP.u_pinmux.otp_bist_strobe!== rand_bit) begin
        `nnc_error("BIST_MODE", $sformatf("`DIG_TOP.u_pinmux.otp_bist_strobe = %b is not as expectation of = %b", `DIG_TOP.u_pinmux.otp_bist_strobe, rand_bit));
      end

      if (`EPROM_BIST_TOP.STROBE!== rand_bit) begin
        `nnc_error("BIST_MODE", $sformatf("`EPROM_BIST_TOP.STROBE = %b is not as expectation of = %b", `EPROM_BIST_TOP.STROBE, rand_bit));
      end

      release  `SOC_TOP.IOBUF_PAD[5];
    end
`else
    for (int i=0; i < 100; i++) begin
      force `SOC_TOP.IOBUF_PAD[5] = $random;
      #10000ns;
      rand_bit = `SOC_TOP.IOBUF_PAD[5];
      if (`EPROM_BIST_TOP.STROBE!== rand_bit) begin
        `nnc_error("BIST_MODE", $sformatf("`EPROM_BIST_TOP.STROBE = %b is not as expectation of = %b", `EPROM_BIST_TOP.STROBE, rand_bit));
      end
      release  `SOC_TOP.IOBUF_PAD[5];
    end

`endif    

    // -------------------------------------------------------
    // Checking pin TDO
    // -------------------------------------------------------
    for (int i=0; i < 100; i++) begin
      force `DIG_TOP.u_pinmux.otp_bist_tdo = $random;
      #10000ns;
      rand_bit = `DIG_TOP.u_pinmux.otp_bist_tdo;
      if (`SOC_TOP.IOBUF_PAD[4]!== rand_bit) begin
        `nnc_error("BIST_MODE", $sformatf("`SOC_TOP.IOBUF_PAD[4] = %b is not as expectation of = %b", `SOC_TOP.IOBUF_PAD[4], rand_bit));
      end
      release  `DIG_TOP.u_pinmux.otp_bist_tdo;
    end

    // -------------------------------------------------------
    // Checking pin TDO_SEROUT
    // -------------------------------------------------------
    for (int i=0; i < 100; i++) begin
      force `DIG_TOP.u_pinmux.otp_bist_tdo_serout = $random;
      #10000ns;
      rand_bit = `DIG_TOP.u_pinmux.otp_bist_tdo_serout;
      if (`SOC_TOP.IOBUF_PAD[3]!== rand_bit) begin
        `nnc_error("BIST_MODE", $sformatf("`SOC_TOP.IOBUF_PAD[3] = %b is not as expectation of = %b", `SOC_TOP.IOBUF_PAD[3], rand_bit));
      end
      release  `DIG_TOP.u_pinmux.otp_bist_tdo_serout;
    end

    // -------------------------------------------------------
    // Checking pin BIST_OTP_VPP_EN
    // -------------------------------------------------------
    for (int i=0; i < 100; i++) begin
      force `DIG_TOP.u_pinmux.i_bist_vpp_en = $random;
      #10000ns;
      rand_bit = `DIG_TOP.u_pinmux.i_bist_vpp_en;
      if (`SOC_TOP.IOBUF_PAD[7]!== rand_bit) begin
        `nnc_error("BIST_MODE", $sformatf("`SOC_TOP.IOBUF_PAD[7] = %b is not as expectation of = %b", `SOC_TOP.IOBUF_PAD[7], rand_bit));
      end
      release  `DIG_TOP.u_pinmux.i_bist_vpp_en;
    end
    
`endif

    end
  endtask  

  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction

endclass : `TESTNAME

