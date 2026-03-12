/*--------------------------------------------------------------------------------------
// Copyright 1616 Nanochap, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_pinmux_scanmode_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_pinmux_scanmode_test                                             
// Designer	: ddang@nanochap.com                                                                 
// Date		: 29-11-1623                                                                     
// Revision	: 0.1 Initial version created by script                                 
--------------------------------------------------------------------------------------*/
`define TESTNAME soc_pinmux_scanmode_test
`define TESTCFG soc_pinmux_scanmode_test_cfg

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

  function new (string name = "soc_pinmux_scanmode_test_cfg");
    super.new(name);
    
  endfunction: new

  // -----------------------------------------------
  // Adding constraints of randomization
  // -----------------------------------------------
  // testmode_sel[1:0] : 00-Normal mode, 01: Scanmode, 10: BIST mode, 11 atm0/1/2/3/4
  constraint c_testmode_sel { soft testmode_sel == 2'b00; }
  constraint c_pinmux_mode { soft pinmux_mode == 1'b0; } 
   
  constraint c_io_model_check_off { io_model_check_off == 1'b1; }  

  // No of bytes in a burst
  constraint c_no_of_bytes { soft no_of_bytes == 2; }
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

    `DUT_IF.pinmux_mode = top_test_cfg.pinmux_mode;    
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;

    `SPI_SCB_EN = 1'b0;
    `ANALOG_SCOREBOARD_EN = 1'b0;
    `PINMUX_SCOREBOARD_EN = 1'b0;

    `WAVEGEN_SCB_DRV_0_EN = 1'b0;
    `WAVEGEN_SHORT_DETECT_SCB_EN = 1'b0;
    // ==================
    // Scoreboard enables
    // ==================

    phase.drop_objection(this);
  endtask : pre_reset_phase

  virtual task main_phase(nnc_phase phase);
    phase.raise_objection(this);

    `nnc_info("SOC_TEST", "soc_pinmux_scanmode_test start", NNC_LOW)
    `DUT_IF.pinmux_mode = 1;
    `DUT_IF.io_model_check_off = 1;

    // ----------------------------------------------------------------------------------
    // Please add your code of your test here
    // ---------------------------------------------------------------------------------- 
    // This is sample to write a data to Register
    `nnc_info("scan","Internal clock test",NNC_MEDIUM)    
    fork
      gen_clk;
    join_none

    #1000ns;
    do_run;

    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ----------------------------------------------------------------------------------
    phase.drop_objection(this);
  endtask: main_phase

  task gen_clk;    
    forever #100ns  scan_clk = ~scan_clk;
  endtask : gen_clk

  virtual task do_run;
    begin
`ifndef FPGA
    // select TEST_MODE, PAD: TEST_MODE0=0, TEST_MODE1=1
    // Checking pin testmode
    `DUT_IF.testmode_sel = 2'b01;    
    `DUT_IF.iopad_gpio[`GPIO_NUM-1:0] = 16'b0;
    force `SOC_TB.IOBUF_PAD[2] = 0;        
    force `SOC_TB.scan_rst_n = 1'b0;
    #10000ns;
    force `SOC_TB.scan_rst_n = 1'b1;
    
    #100000ns;
 `ifdef BEHAVIORAL    
    top_test_cfg.atm = {`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[0],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[1],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[2],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[3],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[4],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[5],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[6],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[7]};
`else
    top_test_cfg.atm = {`ANA_WRAPPER_TOP.D2A_ATM0,`ANA_WRAPPER_TOP.D2A_ATM1,`ANA_WRAPPER_TOP.D2A_ATM2,`ANA_WRAPPER_TOP.D2A_ATM3,`ANA_WRAPPER_TOP.D2A_ATM4,`ANA_WRAPPER_TOP.D2A_ATM5,`ANA_WRAPPER_TOP.D2A_ATM6,`ANA_WRAPPER_TOP.D2A_ATM7};
`endif  
    // Checking ATM
 `ifndef POSTSCAN_PG    
    if (top_test_cfg.atm !== 8'b0)
`else
    if (top_test_cfg.atm !== 8'bxxxx_xxxx)
`endif
      begin
        `nnc_error("SCAN_MODE", $sformatf("ATM[0:7] = %b is not as expectation of ATM = %b", top_test_cfg.atm, (8'b1000_0000 >> `SOC_TOP.IOBUF_PAD[10:8]-1)))
      end
//`endif   
 
    // Checking pin scan clock
    for (int i=0; i < 100; i++) begin
      rand_bit = $random;
      force `SOC_TB.IOBUF_PAD[0] = rand_bit;
      #10000;
      if (`DIG_TOP.u_pinmux.scan_clk !== rand_bit) begin
        `nnc_error("SCANMODE",$sformatf("`DIG_TOP.u_pinmux.scan_clk = %b is not as expectation of scan_clk = %b", `DIG_TOP.u_pinmux.scan_clk, rand_bit))
      end
      release `SOC_TB.IOBUF_PAD[0];
    end
    force `SOC_TB.IOBUF_PAD[0] = scan_clk;
    
    // Checking pin scan rst - `SOC_TOP.scan_rst_n
    for (int i=0; i < 100; i++) begin
      force `SOC_TB.scan_rst_n = $random;
      #10000ns;
      rand_bit = `SOC_TB.scan_rst_n;
      `ifdef POSTLAYOUT_PG
         if (`DIG_TOP.scan_rst_n !== rand_bit) begin
           `nnc_error("scan", $sformatf("`DIG_TOP.u_pinmux.scan_rst_n = %b is not as expectation of scan_rst_n = %b",`DIG_TOP.scan_rst_n, `SOC_TB.scan_rst_n))
         end
      `else 
         if (`DIG_TOP.u_pinmux.scan_rst_n !== rand_bit) begin
           `nnc_error("scan", $sformatf("`DIG_TOP.u_pinmux.scan_rst_n = %b is not as expectation of scan_rst_n = %b",`DIG_TOP.u_pinmux.scan_rst_n, `SOC_TB.scan_rst_n))
         end
      `endif
      release `SOC_TB.scan_rst_n;
    end 

    // Checking pin scan en
    for (int i=0; i < 100; i++) begin
      rand_bit = $random;
      force `SOC_TOP.IOBUF_PAD[1] = rand_bit;
      #10000;
      if (`DIG_TOP.u_pinmux.scan_en !== rand_bit) begin
        `nnc_error("SCANMODE",$sformatf("`DIG_TOP.u_pinmux.scan_en = %b is not as expectation of scan_en = %b", `DIG_TOP.u_pinmux.scan_en, rand_bit))
      end
      release `SOC_TOP.IOBUF_PAD[1];
    end
    force `SOC_TOP.IOBUF_PAD[1] = 1;

    // Checking pin compression
    for (int i=0; i < 100; i++) begin
      rand_bit = $random;
      force `SOC_TB.IOBUF_PAD[2] = rand_bit;
      #10000;
      if (`DIG_TOP.u_pinmux.scan_compression_in !== rand_bit) begin
        `nnc_error("SCANMODE",$sformatf("`DIG_TOP.u_pinmux.scan_compression_in = %b is not as expectation of rand_bit = %b",`DIG_TOP.u_pinmux.scan_compression_in,rand_bit))
      end
      release `SOC_TB.IOBUF_PAD[2];
    end
    force `SOC_TB.IOBUF_PAD[2] = 1'b0;

    // Checking pin scan out
    for (int i=0; i < 100; i++) begin
      rand_num[3:0] = $random;
      force `DIG_TOP.u_pinmux.scan_out = rand_num[3:0];
      #10000;
      if ({`SOC_TB.IOBUF_PAD[10:7]} !== rand_num[3:0]) begin
        `nnc_error("SCANMODE",$sformatf("{`SOC_TB.IOBUF_PAD[10:7]} = scan_out = %b is not as expectation of `DIG_TOP.u_pinmux.scan_out = %b",{`SOC_TB.IOBUF_PAD[10:7]}, `DIG_TOP.u_pinmux.scan_out))
      end
    end
`ifndef POSTLAYOUT_PG    
    // Checking pin scan in
    for (int i=0; i < 100; i++) begin
      rand_num[3:0] = $random;
      force {`SOC_TB.IOBUF_PAD[6:3]} = rand_num[3:0];
      #10000;
      if (`DIG_TOP.u_pinmux.scan_in[3:0] !== rand_num[3:0]) begin
        `nnc_error("SCANMODE",$sformatf("`DIG_TOP.u_pinmux.scan_in = %b is not as expectation of scan_in = %b", `DIG_TOP.u_pinmux.scan_in[3:0], {`SOC_TB.IOBUF_PAD[6:3]}));
        if (`DIG_TOP.u_pinmux.scan_in[3:0] !== `DIG_TOP.u_pinmux.scan_out[3:0]) begin
          `nnc_error("SCANMODE",$sformatf("scan_in = %b is not as expectation of scan_out = %b", `DIG_TOP.u_pinmux.scan_in[3:0], `DIG_TOP.u_pinmux.scan_out[3:0]))
        end
      end
      release {`SOC_TB.IOBUF_PAD[6:3]};
    end
`else
    // Checking pin scan in
    for (int i=0; i < 100; i++) begin
      rand_num[3:0] = $random;
      force {`SOC_TB.IOBUF_PAD[6:3]} = rand_num[3:0];
      #10000;
      if (`SOC_TB.IOBUF_PAD[6:3] !== `DIG_TOP.u_pinmux.scan_out[3:0]) begin
          `nnc_error("SCANMODE",$sformatf("scan_in = %b is not as expectation of scan_out = %b", `SOC_TB.IOBUF_PAD[6:3], `DIG_TOP.u_pinmux.scan_out[3:0]))
      end
      release {`SOC_TB.IOBUF_PAD[6:3]};
    end
`endif

`ifdef ENABLE_WAKEUP
// Checking wake up = 0
   `nnc_info("scan","Wake up mode is coming to 1'b0", NNC_LOW)
   
   force `ANA_TOP.A2D_Wake_UP_i = 1'b0;
   #10000ns;

    if(({`SOC_TOP.IOBUF_IE[15:0]}) !== 0)
      begin 
        `nnc_error("scan", $sformatf("The value of {`ANA_TOP.A2D_Wake_UP_i = 1'b0 - `SOC_TOP.IOBUF_IE[15:0]} = %b is not equal to expected value = %b", {`SOC_TOP.IOBUF_IE[15:0]}, 16'h0))
      end

`ifdef POSTSCAN
 rand_num = {
           `SOC_TOP.u_iopad_gpio[15].PU,
           `SOC_TOP.u_iopad_gpio[14].PU,
           `SOC_TOP.u_iopad_gpio[13].PU,
           `SOC_TOP.u_iopad_gpio[12].PU,
           `SOC_TOP.u_iopad_gpio[11].PU,
           `SOC_TOP.u_iopad_gpio[10].PU,
           `SOC_TOP.u_iopad_gpio[9].PU,
           `SOC_TOP.u_iopad_gpio[8].PU,  
           `SOC_TOP.u_iopad_gpio[7].PU,
           `SOC_TOP.u_iopad_gpio[6].PU,
           `SOC_TOP.u_iopad_gpio[5].PU,
           `SOC_TOP.u_iopad_gpio[4].PU,
           `SOC_TOP.u_iopad_gpio[3].PU,
           `SOC_TOP.u_iopad_gpio[2].PU,
           `SOC_TOP.u_iopad_gpio[1].PU,
           `SOC_TOP.u_iopad_gpio[0].PU};
    if(rand_num !== 16'h0)
      begin 
        `nnc_error("scan", $sformatf("The value of `SOC_TOP.IOBUF_PU[15:0] = %b is not equal to expected value = %b", rand_num, 16'h0))
      end
 rand_num = {
           `SOC_TOP.u_iopad_gpio[15].A;
           `SOC_TOP.u_iopad_gpio[14].A;
           `SOC_TOP.u_iopad_gpio[13].A;
           `SOC_TOP.u_iopad_gpio[12].A;
           `SOC_TOP.u_iopad_gpio[11].A;
           `SOC_TOP.u_iopad_gpio[10].A;
           `SOC_TOP.u_iopad_gpio[9].A;
           `SOC_TOP.u_iopad_gpio[8].A;
           `SOC_TOP.u_iopad_gpio[7].A,
           `SOC_TOP.u_iopad_gpio[6].A,
           `SOC_TOP.u_iopad_gpio[5].A,
           `SOC_TOP.u_iopad_gpio[4].A,
           `SOC_TOP.u_iopad_gpio[3].A,
           `SOC_TOP.u_iopad_gpio[2].A,
           `SOC_TOP.u_iopad_gpio[1].A,
           `SOC_TOP.u_iopad_gpio[0].A};

    if(rand_num !== 0)
      begin 
        `nnc_error("scan", $sformatf("The value of {`ANA_TOP.A2D_Wake_UP_i = 1'b0 - `SOC_TOP.IOBUF_A_always_on[15:0]} = %b is not equal to expected value = %b", rand_num, 16'h0))
      end

 rand_num = {
           `SOC_TOP.u_iopad_gpio[15].OE,
           `SOC_TOP.u_iopad_gpio[14].OE,
           `SOC_TOP.u_iopad_gpio[13].OE,
           `SOC_TOP.u_iopad_gpio[12].OE,
           `SOC_TOP.u_iopad_gpio[11].OE,
           `SOC_TOP.u_iopad_gpio[10].OE,
           `SOC_TOP.u_iopad_gpio[9].OE,
           `SOC_TOP.u_iopad_gpio[8].OE,
           `SOC_TOP.u_iopad_gpio[7].OE,
           `SOC_TOP.u_iopad_gpio[6].OE,
           `SOC_TOP.u_iopad_gpio[5].OE,
           `SOC_TOP.u_iopad_gpio[4].OE,
           `SOC_TOP.u_iopad_gpio[3].OE,
           `SOC_TOP.u_iopad_gpio[2].OE,
           `SOC_TOP.u_iopad_gpio[1].OE,
           `SOC_TOP.u_iopad_gpio[0].OE};

    if(rand_num !== 0)
      begin 
        `nnc_error("scan", $sformatf("The value of {`ANA_TOP.A2D_Wake_UP_i = 1'b0 - `SOC_TOP.IOBUF_OE[15:0]} = %b is not equal to expected value = %b", rand_num, 16'h0))
      end
`else
    if(({`SOC_TOP.IOBUF_PU[15:0]}) !== 16'h0)
      begin 
        `nnc_error("scan", $sformatf("The value of {`ANA_TOP.A2D_Wake_UP_i = 1'b0 - `SOC_TOP.IOBUF_PU[15:0]} = %b is not equal to expected value = %b", {`SOC_TOP.IOBUF_PU[15:0]}, 16'h0))
      end

    if(({`SOC_TOP.IOBUF_A[15:0]}) !== 16'h0)
      begin 
        `nnc_error("scan", $sformatf("The value of {`ANA_TOP.A2D_Wake_UP_i = 1'b0 - `SOC_TOP.IOBUF_A[15:0]} = %b is not equal to expected value = %b", {`SOC_TOP.IOBUF_A[15:0]}, 16'h0))
      end

    if(({`SOC_TOP.IOBUF_OE[15:0]}) !== 16'h0)
      begin 
        `nnc_error("scan", $sformatf("The value of {`ANA_TOP.A2D_Wake_UP_i = 1'b0 - `SOC_TOP.IOBUF_OE[15:0]} = %b is not equal to expected value = %b", {`SOC_TOP.IOBUF_OE[15:0]}, 16'h0))
      end
`endif

`ifndef POSTSCAN
    if(({`SOC_TOP.IOBUF_PD_[15:0]}) !== 16'h0)
      begin 
        `nnc_error("scan", $sformatf("The value of {`ANA_TOP.A2D_Wake_UP_i = 1'b0 - `SOC_TOP.IOBUF_PD[15:0]} = %b is not equal to expected value = %b", {`SOC_TOP.IOBUF_PD[15:0]}, 16'h0))
      end

    if(({`SOC_TOP.IOBUF_IE[15:0]}) !== 16'h0)
      begin 
        `nnc_error("scan", $sformatf("The value of {`ANA_TOP.A2D_Wake_UP_i = 1'b0 - `SOC_TOP.IOBUF_IE[15:0]} = %b is not equal to expected value = %b", {`SOC_TOP.IOBUF_IE[15:0]}, 16'h0))
      end

    if(({`SOC_TOP.IOBUF_Y[15:0]}) !== 16'h0)
      begin 
        `nnc_error("scan", $sformatf("The value of {`ANA_TOP.A2D_Wake_UP_i = 1'b0 - `SOC_TOP.IOBUF_Y[15:0]} = %b is not equal to expected value = %b", {`SOC_TOP.IOBUF_Y[15:0]}, 16'h0))
      end

    if(({`SOC_TOP.IOBUF_CS[15:0]}) !== 16'h0)
      begin 
        `nnc_error("scan", $sformatf("The value of {`ANA_TOP.A2D_Wake_UP_i = 1'b0 - `SOC_TOP.IOBUF_CS[15:0]} = %b is not equal to expected value = %b", {`SOC_TOP.IOBUF_CS[15:0]}, 16'h0))
      end

    if(({`SOC_TOP.IOBUF_SR[15:0]}) !== 16'h0)
      begin 
        `nnc_error("scan", $sformatf("The value of {`ANA_TOP.A2D_Wake_UP_i = 1'b0 - `SOC_TOP.IOBUF_SR[15:0]} = %b is not equal to expected value = %b", {`SOC_TOP.IOBUF_SR[15:0]}, 16'h0))

      end

    if(({`SOC_TOP.IOBUF_PDRV0[15:0]}) !== 16'h0)
      begin 
        `nnc_error("scan", $sformatf("The value of {`ANA_TOP.A2D_Wake_UP_i = 1'b0 - `SOC_TOP.IOBUF_PDRV0[15:0]} = %b is not equal to expected value = %b", {`SOC_TOP.IOBUF_PDRV0[15:0]}, 16'h0))
      end

    if(({`SOC_TOP.IOBUF_PDRV1[15:0]}) !== 0)
      begin 
        `nnc_error("scan", $sformatf("The value of {`ANA_TOP.A2D_Wake_UP_i = 1'b0 - `SOC_TOP.IOBUF_PDRV1[15:0]} = %b is not equal to expected value = %b", {`SOC_TOP.IOBUF_PDRV1[15:0]}, 16'h0))
      end
`endif

    release `ANA_TOP.A2D_Wake_UP_i;

`endif          	    
`endif
    end
  endtask  

  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction
endclass : `TESTNAME        
