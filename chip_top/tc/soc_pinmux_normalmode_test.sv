/*--------------------------------------------------------------------------------------
// Copyright 1616 Nanochap, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_pinmux_normalmode_test.sv                                                   
// Project	: Nanochap ens2                                  		        
// Description	: Testcase soc_pinmux_normalmode_test                                             
// Designer	: zhenghong.yu@nanochap.com                                                                 
// Date		: 14-04-2024                                                                     
// Revision	: 0.1 Initial version created by script                                 
--------------------------------------------------------------------------------------*/
`define TESTNAME soc_pinmux_normalmode_test
`define TESTCFG soc_pinmux_normalmode_test_cfg

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
  logic [8:0]   atm;
  logic [7:0] int_ctrl;
  
  // -----------------------------------------------
  // End of decalration of new variables 
  // -----------------------------------------------

  function new (string name = "soc_pinmux_normalmode_test_cfg");
    super.new(name);
    
  endfunction: new

  // -----------------------------------------------
  // Adding constraints of randomization
  // -----------------------------------------------
  // testmode_sel[1:0] : 00-Normal mode, 01: Scanmode, 10: BIST mode, 11 atm0/1/2/3/4
  constraint c_testmode_sel { soft testmode_sel == 2'b00; }

  constraint c_no_of_bytes  { soft no_of_bytes == 2; }

  constraint c_pinmux_mode  { soft pinmux_mode == 1'b0;}

  //constraint c_altf_sel {altf_sel inside{[0:3]}; }

  // -----------------------------------------------
  // End of adding constraints of randomization
  // -----------------------------------------------

endclass : `TESTCFG

class `TESTNAME extends soc_base_test;
    static bit rand_bit;   
    static bit int_act_lvl;
    static logic [20:0] rand_num;
    static bit SCLK = 0;
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
    //`DUT_IF.altf_sel = top_test_cfg.altf_sel;

    // ==================
    // Scoreboard enables
    // ==================
    `SPI_SCB_EN = 1'b0;
    `ANALOG_SCOREBOARD_EN = 1'b0;

    phase.drop_objection(this);
  endtask : pre_reset_phase

  virtual task main_phase(nnc_phase phase);
    phase.raise_objection(this);

    `nnc_info("SOC_TEST", "soc_pinmux_normalmode_test start", NNC_LOW)
    `DUT_IF.pinmux_mode = 1;

    // ----------------------------------------------------------------------------------
    // Please add your code of your test here
    // ---------------------------------------------------------------------------------- 
    // This is sample to write a data to Register
    fork
      gen_SCLK;
    join_none
    #1000ns;
    
    `nnc_info("PINMUX","Internal clock test",NNC_LOW)
    do_run;
    
    //`nnc_info("ATM8","External clock test", NNC_MEDIUM)    
    //force `ANA_TOP.A2D_external_en_I=1;
    //do_run;
            
    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ----------------------------------------------------------------------------------
    phase.drop_objection(this);
  endtask: main_phase

  task gen_SCLK;    
    forever #100ns  SCLK = ~SCLK;
  endtask : gen_SCLK

  virtual task do_run;
    begin
`ifndef FPGA
    // select TEST_MODE, PAD: TEST_MODE0=0, TEST_MODE1=0
    // Checking pin testmode
    `DUT_IF.testmode_sel = 2'b00;
    `DUT_IF.iopad_gpio[`GPIO_NUM-1:0] = 16'b0; 
    //force `DIG_TOP.u_pinmux.altf_sel = 2'b00;//$random; 
            
    force `SOC_TB.iopad_resetn = 1'b0;
    #10000ns;
    force `SOC_TB.iopad_resetn = 1'b1;

    `PINMUX_SCOREBOARD_EN = 1'b1;

    #100000ns;

 `ifdef BEHAVIORAL    
    top_test_cfg.atm = {`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[0],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[1],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[2],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[3],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[4],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[5],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[6],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[7]};
`else
    top_test_cfg.atm = {`ANA_WRAPPER_TOP.D2A_ATM0,`ANA_WRAPPER_TOP.D2A_ATM1,`ANA_WRAPPER_TOP.D2A_ATM2,`ANA_WRAPPER_TOP.D2A_ATM3,`ANA_WRAPPER_TOP.D2A_ATM4,`ANA_WRAPPER_TOP.D2A_ATM5,`ANA_WRAPPER_TOP.D2A_ATM6,`ANA_WRAPPER_TOP.D2A_ATM7};
`endif  
                // Checking ATM
                if (top_test_cfg.atm !== 8'b0)
                    begin
                        `nnc_error("SCAN_MODE", $sformatf("ATM[0:7] = %b is not as expectation of ATM = %b", top_test_cfg.atm, (8'b1000_0000 >> `SOC_TOP.IOBUF_PAD[10:8]-1)))
                    end                  

                // ------------------------------------------------------------                  
                // Checking pin CSn - `SOC_TOP.CSn
                // ------------------------------------------------------------
`ifndef POSTLAYOUT_PG                    
                for (int i=0; i < 100; i++) begin
                  force `SOC_TOP.IOBUF_PAD[3] = $random;
                  #10000ns;
                  rand_bit = `SOC_TOP.IOBUF_PAD[3];
                  if (`DIG_TOP.u_pinmux.cs_n !== rand_bit) begin
                    `nnc_error("PINMUX", $sformatf("`DIG_TOP.u_pinmux.cs_n = %b is not as expectation of IOBUF_PAD[3] = %b",`DIG_TOP.u_pinmux.cs_n, rand_bit))
                  end
                  release `SOC_TOP.IOBUF_PAD[3];
                end
`else
                for (int i=0; i < 100; i++) begin
                  force `SOC_TOP.IOBUF_PAD[3] = $random;
                  #10000ns;
                  rand_bit = `SOC_TOP.IOBUF_PAD[3];
                  if (`DIG_TOP.u_pinmux.pad_cs_n !== rand_bit) begin
                    `nnc_error("PINMUX", $sformatf("`DIG_TOP.u_pinmux.cs_n = %b is not as expectation of IOBUF_PAD[3] = %b",`DIG_TOP.u_pinmux.pad_cs_n, rand_bit))
                  end
                  release `SOC_TOP.IOBUF_PAD[3];
                end
`endif

                // ------------------------------------------------------------        
                // Checking pin SCLK - `SOC_TOP.IOBUF_PAD[4]
                // ------------------------------------------------------------
                for (int i=0; i < 100; i++) begin
                  force `SOC_TOP.IOBUF_PAD[4] = $random;
                  #10000ns;
                  rand_bit = `SOC_TOP.IOBUF_PAD[4];
                  if (`DIG_TOP.u_pinmux.sclk !== rand_bit) begin
                    `nnc_error("PINMUX", $sformatf("`DIG_TOP.u_pinmux.sclk = %b is not as expectation of SCLK = %b",`DIG_TOP.u_pinmux.sclk, rand_bit))
                  end
                  release `SOC_TOP.IOBUF_PAD[4] ;
                end

                // ------------------------------------------------------------        
                // Checking pin ext_clk - `SOC_TOP.IOBUF_PAD[0]
                // ------------------------------------------------------------
                if(`DUT_IF.ext_clk_en)begin
                  for (int i=0; i < 100; i++) begin
                    force `SOC_TOP.IOBUF_PAD[0] = $random;
                    #10000ns;
                    rand_bit = `SOC_TOP.IOBUF_PAD[0];
                    if (`DIG_TOP.u_pinmux.ext_clk !== rand_bit) begin
                        `nnc_error("PINMUX", $sformatf("`DIG_TOP.u_pinmux.ext_clk = %b is not as expectation of IOBUF_PAD[0] = %b",`DIG_TOP.u_pinmux.ext_clk, rand_bit))
                    end
                    release `SOC_TOP.IOBUF_PAD[0];
                  end
                end
 
                // --------------------------------------------------------
                // Checking pin MISO - `DIG_TOP.u_pinmux.miso
                // --------------------------------------------------------
                // Set CSn to 0  
                force `SOC_TOP.IOBUF_PAD[3] = 1'b0;

                // Force inside PInmux and check at PADs
                for (int i=0; i < 100; i++) begin
                  force `DIG_TOP.u_pinmux.miso = $random;
                  #10000ns;
                  rand_bit = `DIG_TOP.u_pinmux.miso;
                  if (`SOC_TOP.IOBUF_PAD[6] !== rand_bit) begin
                    `nnc_error("PINMUX", $sformatf("`SOC_TOP.IOBUF_PAD[6] = %b is not as expectation of miso = %b",`SOC_TOP.IOBUF_PAD[6], rand_bit))
                  end
                  release `DIG_TOP.u_pinmux.miso;
                end
                release `SOC_TOP.IOBUF_PAD[3];
                   
                // --------------------------------------------------------
                // Checking pin MOSI - `SOC_TOP.mosi
                // --------------------------------------------------------
                for (int i=0; i < 100; i++) begin
                  force `SOC_TOP.IOBUF_PAD[5] = $random;
                  #10000ns;
                  rand_bit = `SOC_TOP.IOBUF_PAD[5];
                  if (`DIG_TOP.u_pinmux.mosi !== rand_bit) begin
                    `nnc_error("PINMUX", $sformatf("`DIG_TOP.u_pinmux.mosi = %b is not as expectation of IOBUF_PAD[5] = %b",`DIG_TOP.u_pinmux.mosi, rand_bit))
                  end
                  release `SOC_TOP.IOBUF_PAD[5];
                end
        
                // --------------------------------------------------------
                // Checking pin CPOLn - `SOC_TOP.CPOLn
                // --------------------------------------------------------
                for (int i=0; i < 100; i++) begin
                  force `SOC_TOP.IOBUF_PAD[1] = $random;
                  #10000ns;
                  rand_bit = `SOC_TOP.IOBUF_PAD[1];
                  if (`DIG_TOP.u_pinmux.o_cpoln !== rand_bit) begin
                    `nnc_error("PINMUX", $sformatf("`DIG_TOP.u_pinmux.o_cpoln = %b is not as expectation of IOBUF_PAD[1] = %b",`DIG_TOP.u_pinmux.o_cpoln, rand_bit))
                  end
                  release `SOC_TOP.IOBUF_PAD[1];
                end
         
                // -------------------------------------------------  
                // Checking pin CPHA - `SOC_TOP.CPHA
                // -------------------------------------------------
                for (int i=0; i < 100; i++) begin
                  force `SOC_TOP.IOBUF_PAD[2] = $random;
                  #10000ns;
                  rand_bit = `SOC_TOP.IOBUF_PAD[2];
                  if (`DIG_TOP.u_pinmux.o_cpha !== rand_bit) begin
                    `nnc_error("PINMUX", $sformatf("`DIG_TOP.u_pinmux.o_cpha = %b is not as expectation of IOBUF_PAD[2] = %b",`DIG_TOP.u_pinmux.o_cpha, rand_bit))
                  end
                  release `SOC_TOP.IOBUF_PAD[2];
                end
                
                // ---------------------------------------------------------        
                // Checking INTB input pin - `SOC_TOP.IOBUF_PAD[7]
                // ---------------------------------------------------------
                force `DIG_TOP.u_pinmux.i_lead_off_int = 0;
                `ifndef BEHAVIORAL
                   force `SPI_TOP.spi_reg_u.spi_pinmux_if_INT_LEVEL_SEL = $random;
                   int_act_lvl =  `SPI_TOP.spi_reg_u.spi_pinmux_if_INT_LEVEL_SEL;
                `else 
                   force `SPI_TOP.spi_reg_u.int_ctrl_reg[2] = $random;
                   int_act_lvl =  `SPI_TOP.spi_reg_u.int_ctrl_reg[2];
                `endif 
                for (int i=0; i < 100; i++) begin
                  force `DIG_TOP.u_pinmux.i_wg_drviver_int = $random;
                  #10000ns;
                  rand_bit = `DIG_TOP.u_pinmux.i_wg_drviver_int;
                  if (`SOC_TOP.IOBUF_PAD[7] !== rand_bit ~^ int_act_lvl) begin
                    `nnc_error("PINMUX", $sformatf("`SOC_TOP.IOBUF_PAD[7] = %b is not as expectation of i_wg_drviver_int = %b",`SOC_TOP.IOBUF_PAD[7], rand_bit))
                  end
                  release `DIG_TOP.u_pinmux.i_wg_drviver_int;
                end
                release `DIG_TOP.u_pinmux.i_lead_off_int;                
        
                // --------------------------------------------------- 
                // 
                // ---------------------------------------------------
                force `DIG_TOP.u_pinmux.i_wg_drviver_int = 0; 

                `ifndef BEHAVIORAL
                   release `SPI_TOP.spi_reg_u.spi_pinmux_if_INT_LEVEL_SEL; 
                   force `SPI_TOP.spi_reg_u.spi_pinmux_if_INT_LEVEL_SEL = $random;
                   int_act_lvl =  `SPI_TOP.spi_reg_u.spi_pinmux_if_INT_LEVEL_SEL;
                `else  
                   release `SPI_TOP.spi_reg_u.int_ctrl_reg[2];              
                   force `SPI_TOP.spi_reg_u.int_ctrl_reg[2] = $random;
                   int_act_lvl =  `SPI_TOP.spi_reg_u.int_ctrl_reg[2];
                `endif
                for (int i=0; i < 100; i++) begin
                  force `DIG_TOP.u_pinmux.i_lead_off_int = $random;
                  #10000ns;
                  rand_bit = `DIG_TOP.u_pinmux.i_lead_off_int;
                  if (`SOC_TOP.IOBUF_PAD[7] !== rand_bit ~^ int_act_lvl) begin
                    `nnc_error("PINMUX", $sformatf("`SOC_TOP.IOBUF_PAD[7] = %b is not as expectation of i_lead_off_int = %b",`SOC_TOP.IOBUF_PAD[7], rand_bit))
                  end
                  release `DIG_TOP.u_pinmux.i_lead_off_int;
                end
                release `DIG_TOP.u_pinmux.i_wg_drviver_int;                

                // ---------------------------------------------------
                `ifndef BEHAVIORAL
                   release `SPI_TOP.spi_reg_u.spi_pinmux_if_INT_LEVEL_SEL;
                   force `SPI_TOP.spi_reg_u.spi_pinmux_if_INT_LEVEL_SEL = $random;
                   int_act_lvl =  `SPI_TOP.spi_reg_u.spi_pinmux_if_INT_LEVEL_SEL;
                `else 
                   release `SPI_TOP.spi_reg_u.int_ctrl_reg[2];
                   force `SPI_TOP.spi_reg_u.int_ctrl_reg[2] = $random;
                   int_act_lvl =  `SPI_TOP.spi_reg_u.int_ctrl_reg[2];
                `endif
                force `DIG_TOP.u_pinmux.i_lead_off_int = 0;                
                for (int i=0; i < 100; i++) begin
                  force `DIG_TOP.u_pinmux.i_wg_drviver_int = $random;
                  #10000ns;
                  rand_bit = `DIG_TOP.u_pinmux.i_wg_drviver_int;
                  if (`SOC_TOP.IOBUF_PAD[7] !== rand_bit ~^ int_act_lvl) begin
                    `nnc_error("PINMUX", $sformatf("`SOC_TOP.IOBUF_PAD[7] = %b is not as expectation of i_lead_off_int = %b",`SOC_TOP.IOBUF_PAD[7], rand_bit))
                  end
                  release `DIG_TOP.u_pinmux.i_wg_drviver_int;
                end
                release `DIG_TOP.u_pinmux.i_lead_off_int;

                // ----------------------------------------------- 
                // Checking pin OTP_VPP_EN - `SOC_TOP.IOBUF_PAD[8]
                // -----------------------------------------------
                for (int i=0; i < 100; i++) begin
                  force `DIG_TOP.u_pinmux.i_otp_vpp_en = $random;
                  #10000ns;
                  rand_bit = `DIG_TOP.u_pinmux.i_otp_vpp_en;
                  if (`SOC_TOP.IOBUF_PAD[8] !== rand_bit) begin
                    `nnc_error("PINMUX", $sformatf("`SOC_TOP.IOBUF_PAD[8] = %b is not as expectation of `DIG_TOP.u_pinmux.i_otp_vpp_en = %b", `SOC_TOP.IOBUF_PAD[8], rand_bit))
                  end
                  release `DIG_TOP.u_pinmux.i_otp_vpp_en;
                end
                release `SOC_TOP.IOBUF_PAD[3];
 
                // -----------------------------------------------------
                // Checking output pin HFOSC_OUT - `SOC_TOP.IOBUF_PAD[9]
                // -----------------------------------------------------
                for (int i=0; i < 100; i++) begin
                  force `DIG_TOP.u_pinmux.hfosc_out = $random;
                  #10000ns;
                  rand_bit = `DIG_TOP.u_pinmux.hfosc_out;
                  if (`SOC_TOP.IOBUF_PAD[9] !== rand_bit) begin
                    `nnc_error("PINMUX", $sformatf("`SOC_TOP.IOBUF_PAD[9] = %b is not as expectation of `DIG_TOP.u_pinmux.hfosc_out = %b", `SOC_TOP.IOBUF_PAD[9], rand_bit))
                  end
                  release `DIG_TOP.u_pinmux.hfosc_out;
                end

                // ----------------------------------------------------------
                // Checking INT_OSC_OUT_EN input pin- `SOC_TOP.IOBUF_PAD[10]
                // ----------------------------------------------------------
                for (int i=0; i < 100; i++) begin
                  force `SOC_TOP.IOBUF_PAD[10] = $random;
                  #10000ns;
                  rand_bit = `SOC_TOP.IOBUF_PAD[10];
                  if (`DIG_TOP.u_pinmux.o_int_clk_out_gpio !== rand_bit) begin
                    `nnc_error("PINMUX", $sformatf("`DIG_TOP.u_pinmux.o_int_clk_out_gpio = %b is not as expectation of IOBUF_PAD[10] = %b", `DIG_TOP.u_pinmux.o_int_clk_out_gpio, rand_bit))
                  end
                  release `SOC_TOP.IOBUF_PAD[10];
                end

`ifdef BEHAVIORAL                             
 // Checking EXT_CLK pin
    force `SOC_TOP.IOBUF_IE[0] = 1'b1; 
    for (int i=0; i < 100; i++) begin
        force `SOC_TOP.IOBUF_PAD[0] = $random;
        #10000ns;
        rand_bit = `SOC_TOP.IOBUF_PAD[0];
        if (`DIG_TOP.u_pinmux.ext_clk !== rand_bit) begin
        `nnc_error("ATM0", $sformatf("`DIG_TOP.u_pinmux.ext_clk : %b is not as expectation of EXT_CLK: %b",`DIG_TOP.u_pinmux.ext_clk, rand_bit))
        end
      release `SOC_TOP.IOBUF_PAD[0];                      
    end  
    release `SOC_TOP.IOBUF_IE[0];                          
`endif
`endif
    end
  endtask  

  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction
endclass : `TESTNAME
