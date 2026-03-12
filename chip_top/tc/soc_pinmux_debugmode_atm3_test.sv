/*--------------------------------------------------------------------------------------
// Copyright 1616 Nanochap, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_pinmux_debugmode_atm3_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_pinmux_debugmode_atm3_test                                             
// Designer	: ddang@nanochap.com                                                                 
// Date		: 29-11-1623                                                                     
// Revision	: 0.1 Initial version created by script                                 
--------------------------------------------------------------------------------------*/
`define TESTNAME soc_pinmux_debugmode_atm3_test
`define TESTCFG soc_pinmux_debugmode_atm3_test_cfg

class `TESTCFG extends soc_base_test_cfg;

  `nnc_object_utils(`TESTCFG)

  // -----------------------------------------------
  // Adding your new varialbles in config test
  // -----------------------------------------------
  rand logic [5:0] data[256];
  rand int         no_of_bytes; 
  rand logic [5:0] reg_addr;
  rand logic [5:0] cmd;  
  logic [5:0] read_data[];
  logic [8:0] atm;
  
  // -----------------------------------------------
  // End of decalration of new variables 
  // -----------------------------------------------

  function new (string name = "soc_pinmux_debugmode_atm3_test_cfg");
    super.new(name);
    
  endfunction: new

  // -----------------------------------------------
  // Adding constraints of randomization
  // -----------------------------------------------
  // testmode_sel[1:0] : 00-Normal mode, 01: Scanmode, 10: BIST mode, 11 ATM3/1/2/3/4
  constraint c_testmode_sel { soft testmode_sel == 2'b00; }

  // No of bytes in a burst
  constraint c_no_of_bytes { soft no_of_bytes == 2; }

  constraint c_pinmux_mode { soft pinmux_mode == 1'b0; }

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
    static bit scan_clk = 0;
    logic [5:0] data [0:255];   

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

  // Select internal/external clock sources
    `DUT_IF.ext_clk_en = top_test_cfg.ext_clk_en;			  // 1: external EXT_2MHZ will be driven to SOC from OSC model

    // enable to fix 1'b0 to internal clk
    `DUT_IF.hfosc_fixed_gnd_en = top_test_cfg.hfosc_fixed_gnd_en;         // 1: disble pin to 2MHZ internal osc model, 0:enable pin to internal 2MHZ osc model

    // enable to fix 1'b0 to ext clk
    `DUT_IF.ext_hfosc_fixed_gnd_en = top_test_cfg.ext_hfosc_fixed_gnd_en; // 1: disble pin to 2MHZ exeternal osc model, 0:enable pin to exeternal 2MHZ osc model

    // Clock variation of HFOSC
    //`DUT_IF.hfosc_variation = top_test_cfg.hfosc_variation;

    // ==================
    // Scoreboard enables
    // ==================
    `SPI_SCB_EN = 1'b0;
    `ANALOG_SCOREBOARD_EN = 1'b1;
    

    phase.drop_objection(this);
  endtask : pre_reset_phase

  virtual task main_phase(nnc_phase phase);
    phase.raise_objection(this);

    `nnc_info("SOC_TEST", "soc_pinmux_debugmode_atm3_test start", NNC_LOW)
    `DUT_IF.pinmux_mode = 1;
    `DUT_IF.io_model_check_off = 1;     
    `DUT_IF.otp_ignore_check_en = 1;
              
    // ----------------------------------------------------------------------------------
    // Please add your code of your test here
    // ---------------------------------------------------------------------------------- 
    // This is sample to write a data to Register
       
    do_run;
            
    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ----------------------------------------------------------------------------------
    phase.drop_objection(this);
  endtask: main_phase

  virtual task do_run;
    begin
`ifndef FPGA

    //force `SOC_TB.iopad_resetn = 1'b0;
    //#100000;
    //force `SOC_TB.iopad_resetn = 1'b1;
    //#100000;

    // ---------------------------------------------------- 
    // Part I: Configure chip to ATM3
    // ----------------------------------------------------
    force `SOC_TOP.IOBUF_PAD[10:8] = 3'b011;

   // select TEST_MODE, PAD: TEST_MODE0=0, TEST_MODE1=1
    // Checking pin testmode
    force `SOC_TB.ext_resetn = 1'b0;
    `DUT_IF.testmode_sel = 2'b11; 
 
    //force `SOC_TOP.CLKSEL = 1'b1;

    /*force `EPROM_IP.power_ready = 1'b0;
    force `EPROM_IP_1.power_ready = 1'b0;
    force `EPROM_IP_2.power_ready = 1'b0;

    force `EPROM_IP.PWE = 0;
    force `EPROM_IP.PPROG = 0;
    force `EPROM_IP.POR = 0;
    force `EPROM_IP.VPP = 0;

    force `EPROM_IP_1.PWE = 0;
    force `EPROM_IP_1.PPROG = 0;
    force `EPROM_IP_1.POR = 0;
    force `EPROM_IP_1.VPP = 0;

    force `EPROM_IP_2.PWE = 0;
    force `EPROM_IP_2.PPROG = 0;
    force `EPROM_IP_2.POR = 0;
    force `EPROM_IP_2.VPP = 0;*/

    // ========================================================================
    // Before entering ATM mode, Disbale internal POR and clock
    // ========================================================================
    //stuck internal POR=1
    force `ANA_TOP.A2D_POR_DVDD = 1'b1;
    //disable internal clock
    //force `ANA_TOP.A2D_CLK2MHZ = 1'b0; // no need to force because hfosc_fixed_gnd_en =1 this take care stuck 0

    // Use external resetn (set LOW to HIGH )
    force `ANA_TOP.PMU_SW.DVDD = 1'b1; //in testmode LDO will not connected to DVDD so need provide external supply 1.8v
    //force `SOC_TB.ext_resetn = 1'b0;
    #100000;
    force `SOC_TB.ext_resetn = 1'b1;
    #1ms;

    `PINMUX_SCOREBOARD_EN = 1'b1;      

   // ------------------------------------------------------ 
   // Part II: Checking ATM3 will be asserted in interface
   // ------------------------------------------------------
    #100000ns;

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
      
    #10000ns;

    // --------------------------------------------------------- 
    // Part III: Checking fixed signals in CHIP on ANA Interface
    // ---------------------------------------------------------
    //Check default signal           
    if (`ANA_TOP.D2A_BIST_SEL !== 4'b0011)
      begin
        `nnc_error("ATM3", $sformatf("D2A_BIST_SEL = %b is not as expectation of 4'b0011", `ANA_TOP.D2A_BIST_SEL))
      end  
    if (`ANA_TOP.D2A_BIST_EN !== 1'b1)
      begin
        `nnc_error("ATM3", $sformatf("D2A_BIST_EN = %b is not as expectation of 1'b1", `ANA_TOP.D2A_BIST_EN))
      end  
    if (`ANA_TOP.D2A_OSC2MHZEN !== 1'b1)
      begin
        `nnc_error("ATM3", $sformatf("D2A_OSC2MHZEN = %b is not as expectation of 1'b1", `ANA_TOP.D2A_OSC2MHZEN))
      end  

    // ------------------------------------------------------------ 
    // Part IV: Checking the connections from PADs to ANA Interface
    // ------------------------------------------------------------  

    // Checking D2A_BIST_SPARE_3 pin
    for (int i=0; i < 100; i++) begin
        force `SOC_TOP.CLKSEL = $random;
        #10000ns;
        rand_bit = `SOC_TOP.CLKSEL;
`ifdef BEHAVIORAL
        if (`DIG_TOP.u_pinmux.pinmux_if.D2A_ANA_OUT_SEL3 !== rand_bit) begin
        `nnc_error("ATM3", $sformatf("`DIG_TOP.u_pinmux.D2A_ANA_OUT_SEL3: %b is not as expectation of CLKSEL: %b",`DIG_TOP.u_pinmux.pinmux_if.D2A_ANA_OUT_SEL3, rand_bit))
        end
`endif
        if (`ANA_TOP.D2A_BIST_SPARE_3 !== rand_bit) begin
        `nnc_error("ATM3", $sformatf("`ANA_TOP.D2A_BIST_SPARE_3: %b is not as expectation of CLKSEL: %b",`ANA_TOP.D2A_BIST_SPARE_3, rand_bit))
        end
        release  `SOC_TOP.CLKSEL;              
    end 
    
`ifdef BEHAVIORAL                             
 // Checking EXT_CLK pin
    for (int i=0; i < 100; i++) begin
        force `SOC_TOP.IOBUF_PAD[0] = $random;
        #10000ns;
        rand_bit = `SOC_TOP.IOBUF_PAD[0];
        if (`DIG_TOP.u_pinmux.ext_clk !== rand_bit) begin
        `nnc_error("ATM3", $sformatf("`DIG_TOP.u_pinmux.ext_clk : %b is not as expectation of EXT_CLK: %b",`DIG_TOP.u_pinmux.ext_clk, rand_bit))
        end
      release `SOC_TOP.IOBUF_PAD[0];                      
    end  
`endif 

    // Checking Resetn pin (input)
    for (int i=0; i < 100; i++) begin
        force `SOC_TOP.RESETn = $random;	
        #10000ns;
        rand_bit = `SOC_TOP.RESETn;
        `ifndef POSTLAYOUT_PG
           if (`DIG_TOP.u_pinmux.pin_rstn !== rand_bit) begin
           `nnc_error("ATM3", $sformatf("`DIG_TOP.u_pinmux.pin_rstn:%b is not as expectation of RESETn: %b",`DIG_TOP.u_pinmux.pin_rstn, rand_bit))
           end
           if (`DIG_TOP.u_pinmux.scan_rst_n !== rand_bit) begin
           `nnc_error("ATM3", $sformatf("`DIG_TOP.u_pinmux.scan_rst_n:%b is not as expectation of RESETn: %b",`DIG_TOP.u_pinmux.scan_rst_n, rand_bit))
           end
           if (`DIG_TOP.u_pinmux.otp_bist_resetn !== rand_bit) begin
           `nnc_error("ATM3", $sformatf("`DIG_TOP.u_pinmux.otp_bist_resetn:%b is not as expectation of RESETn: %b",`DIG_TOP.u_pinmux.otp_bist_resetn, rand_bit))
           end
        `else //in postlayout above all reset signals of pinmux has been optimized so consider only below one
           if (`DIG_TOP.u_pinmux.iopad_resetn_y !== rand_bit) begin
           `nnc_error("ATM0", $sformatf("`DIG_TOP.u_pinmux.iopad_resetn_y:%b is not as expectation of RESETn: %b",`DIG_TOP.u_pinmux.iopad_resetn_y, rand_bit))
           end
           if (`RST_CTRL_TOP.otp_bist_resetn!== rand_bit) begin
             `nnc_error("ATM0", $sformatf("`DIG_TOP.u_pinmux.otp_bist_resetn = %b is not as expectation of = %b", `RST_CTRL_TOP.otp_bist_resetn, rand_bit));
           end
           if (`DIG_TOP.scan_rst_n !== rand_bit) begin
            `nnc_error("ATM0", $sformatf("`DIG_TOP.u_pinmux.scan_rst_n = %b is not as expectation of scan_rst_n = %b",`DIG_TOP.scan_rst_n, `SOC_TB.scan_rst_n))
          end
        `endif

      release  `SOC_TOP.RESETn;              
    end 

    // Checking D2A_TRIM_SIG[3]
    for (int i=0; i < 100; i++) begin
        force `SOC_TOP.IOBUF_PAD[7:1] = $random;
        #10000ns;
        rand_num[6:0] = `SOC_TOP.IOBUF_PAD[7:1]; 
`ifdef BEHAVIORAL             
        if (`ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[3][7:0]!== {1'b0,rand_num[6:0]}) begin
          `nnc_error("ATM3", $sformatf("`SOC_TOP.pinmux_if.D2A_TRIM_SIG[3][7:0] = %b is not as expectation of = %b", `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[3][7:0],{1'b0, rand_num[6:0]}));
        end         
`else
        if (`ANA_WRAPPER_TOP.pinmux_if_D2A_TRIM_SIG[31:24]!== {1'b0,rand_num[6:0]}) begin
        `nnc_error("ATM3", $sformatf("`SOC_TOP.pinmux_if.D2A_TRIM_SIG[30:24] = %b is not as expectation of = %b", `ANA_WRAPPER_TOP.pinmux_if_D2A_TRIM_SIG[31:24], {1'b0,rand_num[6:0]}));
        end
`endif
        if (`ANA_TOP.D2A_OSC2MHZ_TRIM!== {1'b0,rand_num[6:0]}) begin
          `nnc_error("ATM3", $sformatf("`ANA_TOP.D2A_OSC2MHZ_TRIM = %b is not as expectation of = %b", `ANA_TOP.D2A_OSC2MHZ_TRIM, {1'b0,rand_num[6:0]}));
        end  

        release  `SOC_TOP.IOBUF_PAD[7:1];      
    end     
    
`endif
                   	    
    end
  endtask  

  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction
endclass : `TESTNAME

