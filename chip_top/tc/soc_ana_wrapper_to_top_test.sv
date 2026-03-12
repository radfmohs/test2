/*--------------------------------------------------------------------------------------
// Copyright 1616 Nanochap, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_ana_wrapper_to_top_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_ana_wrapper_to_top_test                                             
// Designer	: ddang@nanochap.com                                                                 
// Date		: 29-11-1623                                                                     
// Revision	: 0.1 Initial version created by script                                 
--------------------------------------------------------------------------------------*/
`define TESTNAME soc_ana_wrapper_to_top_test
`define TESTCFG soc_ana_wrapper_to_top_test_cfg

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

  function new (string name = "soc_ana_wrapper_to_top_test_cfg");
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
    `nnc_top.set_timeout(2s);
    top_test_cfg = `TESTCFG::type_id::create("top_test_cfg", this);
  endfunction

  virtual task pre_reset_phase(nnc_phase phase);
    phase.raise_objection(this);

    super.pre_reset_phase(phase);

    assert(top_test_cfg.randomize());

    `DUT_IF.pinmux_mode = top_test_cfg.pinmux_mode;    
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    `DUT_IF.otp_ignore_check_en = 1;

    `SPI_SCB_EN = 1'b0;
    `ANALOG_SCOREBOARD_EN = 1'b0;
    // ==================
    // Scoreboard enables
    // ==================

    phase.drop_objection(this);
  endtask : pre_reset_phase

  virtual task main_phase(nnc_phase phase);
    phase.raise_objection(this);

    `nnc_info("SOC_TEST", "soc_ana_wrapper_to_top_test start", NNC_LOW)

    // ----------------------------------------------------------------------------------
    // Please add your code of your test here
    // ---------------------------------------------------------------------------------- 
    // This is sample to write a data to Register
    `nnc_info("scan","Internal clock test",NNC_MEDIUM)    
    `DUT_IF.pinmux_mode = 1;    

    do_run;
            
    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ----------------------------------------------------------------------------------
    phase.drop_objection(this);
  endtask: main_phase

  virtual task do_run;
    begin
    /*-----------------------------PMU-------------------------------*/       
    //Module : PMU , Direction : D2A , Connection : OTP THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL            
        force `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[0] = $random;
        #10000ns;
        rand_num[7:0] = `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[0];
        if (`ANA_TOP.D2A_BG_TRIM[6:0] !== rand_num[6:0]) begin // Only use 6-bit
        `nnc_error("ANA", $sformatf("D2A_BG_TRIM :%b is not as expectation of `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[0][6:0]: %b",`ANA_TOP.D2A_BG_TRIM[6:0], rand_num[6:0]))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[0]; 
`else
        force `ANA_WRAPPER_TOP.pinmux_if_D2A_TRIM_SIG[6:0] = $random;
        #10000ns;
        rand_num[7:0] = `ANA_WRAPPER_TOP.pinmux_if_D2A_TRIM_SIG[6:0]; 
                if (`ANA_TOP.D2A_BG_TRIM[6:0] !== rand_num[6:0]) begin // Only use 6-bit
        `nnc_error("ANA", $sformatf("D2A_BG_TRIM :%b is not as expectation of `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[0][6:0]: %b",`ANA_TOP.D2A_BG_TRIM[6:0], rand_num[6:0]))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if_D2A_TRIM_SIG[6:0];  
`endif                  
    end

    //Module : PMU , Direction : D2A , Connection : OTP THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL                    
        force `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[1] = $random;
        #10000ns;
        rand_num[7:0] = `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[1];
        if (`ANA_TOP.D2A_IREF_TRIM[5:0] !== rand_num[5:0]) begin // Only use 6-bit
        `nnc_error("ANA", $sformatf("D2A_IREF_TRIM :%b is not as expectation of `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[1][6:0]: %b",`ANA_TOP.D2A_IREF_TRIM[5:0], rand_num[5:0]))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[1];  
`else
        force `ANA_WRAPPER_TOP.pinmux_if_D2A_TRIM_SIG[15:8] = $random;
        #10000ns;
        rand_num[7:0] = `ANA_WRAPPER_TOP.pinmux_if_D2A_TRIM_SIG[15:8];
        if (`ANA_TOP.D2A_IREF_TRIM[5:0] !== rand_num[5:0]) begin // Only use 6-bit
        `nnc_error("ANA", $sformatf("D2A_IREF_TRIM :%b is not as expectation of `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[1][6:0]: %b",`ANA_TOP.D2A_IREF_TRIM[5:0], rand_num[5:0]))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if_D2A_TRIM_SIG[15:8];  
`endif                                    
    end

    //Module : PMU , Direction : D2A , Connection : OTP THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL                            
        force `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[2] = $random;
        #10000ns;
        rand_num[7:0] = `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[2];
        if (`ANA_TOP.D2A_CLDO1P8_TRIM[4:0] !== {rand_num[7], rand_num[3:0]}) begin // Only use 5-bit
        `nnc_error("ANA", $sformatf("D2A_CLDO1P8_TRIM :%b is not as expectation of `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[2][3:0]: %b",`ANA_TOP.D2A_CLDO1P8_TRIM[4:0], {rand_num[7], rand_num[3:0]}))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[2]; 
`else
        force `ANA_WRAPPER_TOP.pinmux_if_D2A_TRIM_SIG[23:16] = $random;
        #10000ns;
        rand_num[7:0] = `ANA_WRAPPER_TOP.pinmux_if_D2A_TRIM_SIG[23:16];
        if (`ANA_TOP.D2A_CLDO1P8_TRIM[4:0] !== {rand_num[7], rand_num[3:0]}) begin // Only use 5-bit
        `nnc_error("ANA", $sformatf("D2A_CLDO1P8_TRIM :%b is not as expectation of `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[2][3:0]: %b",`ANA_TOP.D2A_CLDO1P8_TRIM[4:0], {rand_num[7], rand_num[3:0]}))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if_D2A_TRIM_SIG[23:16]; 
`endif                      
    end

    //Module : PMU , Direction : D2A , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL                                    
        force `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[0][0] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[0][0];
        if (`ANA_TOP.D2A_LVD_EN !== rand_bit) begin
          `nnc_error("ANA", $sformatf("ANA_ENABLE_REG_0[0] :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_LVD_EN, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[0][0];
`else 
        force `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[0] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[0];
        if (`ANA_TOP.D2A_LVD_EN !== rand_bit) begin
          `nnc_error("ANA", $sformatf("ANA_ENABLE_REG_0[0] :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_LVD_EN, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[0];
`endif                   
    end

    //Module : PMU , Direction : D2A , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL        
        force `ANA_WRAPPER_TOP.spi_ana_if.D2A_ANA_GEN_REG[0][2:0] = $random;
        #10000ns;
        rand_num[2:0] = `ANA_WRAPPER_TOP.spi_ana_if.D2A_ANA_GEN_REG[0][2:0];
        if (`ANA_TOP.D2A_LVD_SEL !== rand_num[2:0]) begin
          `nnc_error("ANA", $sformatf("D2A_LVD_SEL :%b is not as expectation of rand_num[2:0] : %b",`ANA_TOP.D2A_LVD_SEL, rand_num[2:0]))
        end
      release  `ANA_WRAPPER_TOP.spi_ana_if.D2A_ANA_GEN_REG[0][2:0]; 
`else
        force `ANA_WRAPPER_TOP.spi_ana_if_D2A_ANA_GEN_REG[2:0] = $random;
        #10000ns;
        rand_num[2:0] = `ANA_WRAPPER_TOP.spi_ana_if_D2A_ANA_GEN_REG[2:0];
        if (`ANA_TOP.D2A_LVD_SEL !== rand_num[2:0]) begin
          `nnc_error("ANA", $sformatf("D2A_LVD_SEL :%b is not as expectation of rand_num[2:0] : %b",`ANA_TOP.D2A_LVD_SEL, rand_num[2:0]))
        end
      release  `ANA_WRAPPER_TOP.spi_ana_if_D2A_ANA_GEN_REG[2:0]; 
`endif                            
    end
    
    //Module : PMU , Direction : D2A , Connection : OTP THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL                
        force `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[6] = $random;
        #10000ns;
        rand_num[7:0] = `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[6];
        if (`ANA_TOP.D2A_IBIAS_IDAC_TRIM[2:0] !== rand_num[2:0]) begin
        `nnc_error("ANA", $sformatf("D2A_IBIAS_IDAC_TRIM[2:0] :%b is not as expectation of rand_num[6:0]: %b",`ANA_TOP.D2A_IBIAS_IDAC_TRIM[2:0], rand_num[2:0]))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[6]; 
`else
        force `ANA_WRAPPER_TOP.pinmux_if_D2A_TRIM_SIG[55:48] = $random;
        #10000ns;
        rand_num[7:0] = `ANA_WRAPPER_TOP.pinmux_if_D2A_TRIM_SIG[55:48];
        if (`ANA_TOP.D2A_IBIAS_IDAC_TRIM[2:0] !== rand_num[2:0]) begin
        `nnc_error("ANA", $sformatf("D2A_IBIAS_IDAC_TRIM[2:0] :%b is not as expectation of rand_num[6:0]: %b",`ANA_TOP.D2A_IBIAS_IDAC_TRIM[2:0], rand_num[2:0]))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if_D2A_TRIM_SIG[55:48]; 
`endif                     
    end  
     
    //Module : PMU , Direction : A2D , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL                        
        force `ANA_TOP.A2D_LVD = $random;
        #10000ns;
        rand_bit = `ANA_TOP.A2D_LVD;
        if (`ANA_WRAPPER_TOP.spi_ana_if.A2D_ANA_GEN_REG[0][0] !== rand_bit) begin
          `nnc_error("ANA", $sformatf("A2D_ANA_GEN_REG_0[0] :%b is not as expectation of rand_bit : %b",`ANA_WRAPPER_TOP.spi_ana_if.A2D_ANA_GEN_REG[0][0], rand_bit))
        end
      release  `ANA_TOP.A2D_LVD; 
`else
        force `ANA_TOP.A2D_LVD = $random;
        #10000ns;
        rand_bit = `ANA_TOP.A2D_LVD;
        if (`ANA_WRAPPER_TOP.spi_ana_if_A2D_ANA_GEN_REG[0] !== rand_bit) begin
          `nnc_error("ANA", $sformatf("A2D_ANA_GEN_REG_0[0] :%b is not as expectation of rand_bit : %b",`ANA_WRAPPER_TOP.spi_ana_if_A2D_ANA_GEN_REG[0], rand_bit))
        end
      release  `ANA_TOP.A2D_LVD; 
`endif                     
    end

    //Module : PMU , Direction : A2D , Connection : A2D_SW_POWER_POR at top level.
    for (int i=0; i < 100; i++) begin
        force `ANA_TOP.A2D_POR_DVDD = $random;
        #10000ns;
        rand_bit = `ANA_TOP.A2D_POR_DVDD;          
        if (`ANA_WRAPPER_TOP.A2D_POR_DVDD !== rand_bit) begin
          `nnc_error("ANA", $sformatf("A2D_POR_DVDD :%b is not as expectation of rand_bit : %b",`ANA_WRAPPER_TOP.A2D_POR_DVDD, rand_bit))
        end
      release  `ANA_TOP.A2D_POR_DVDD;              
    end
    
    /*-----------------------------OSC-------------------------------*/       
    //Module : OSC , Direction : D2A , Connection : OTP THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL                                
        force `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[3] = $random;
        #10000ns;
        rand_num[7:0] = `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[3];
        if (`ANA_TOP.D2A_OSC2MHZ_TRIM[6:0] !== rand_num[6:0]) begin
        `nnc_error("ANA", $sformatf("D2A_OSC2MHZ_TRIM :%b is not as expectation of rand_num[6:0] : %b",`ANA_TOP.D2A_OSC2MHZ_TRIM[6:0], rand_num[6:0]))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[3];  
`else
        force `ANA_WRAPPER_TOP.pinmux_if_D2A_TRIM_SIG[31:24] = $random;
        #10000ns;
        rand_num[7:0] = `ANA_WRAPPER_TOP.pinmux_if_D2A_TRIM_SIG[31:24];
        if (`ANA_TOP.D2A_OSC2MHZ_TRIM[6:0] !== rand_num[6:0]) begin
        `nnc_error("ANA", $sformatf("D2A_OSC2MHZ_TRIM :%b is not as expectation of rand_num[6:0] : %b",`ANA_TOP.D2A_OSC2MHZ_TRIM[6:0], rand_num[6:0]))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if_D2A_TRIM_SIG[31:24];  
`endif                   
    end

    //Module : OSC , Direction : D2A , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL           
        force `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[0][1] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[0][1];
        if (`ANA_TOP.D2A_OSC2MHZEN !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_OSC2MHZ_TRIM :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_OSC2MHZEN, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[0][1];  
`else
        force `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[1] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[1];
        if (`ANA_TOP.D2A_OSC2MHZEN !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_OSC2MHZ_TRIM :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_OSC2MHZEN, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[1];  
`endif                      
    end

    //Module : OSC , Direction : A2D , Connection : A2D_OSC_OUT at top level.
    for (int i=0; i < 100; i++) begin
        force `ANA_TOP.A2D_CLK2MHZ = $random;
        #10000ns;
        rand_bit = `ANA_TOP.A2D_CLK2MHZ;
        if (`ANA_WRAPPER_TOP.A2D_CLK2MHZ !== rand_bit) begin
          `nnc_error("ANA", $sformatf("A2D_CLK2MHZ :%b is not as expectation of rand_bit : %b",`ANA_WRAPPER_TOP.A2D_CLK2MHZ, rand_bit))
        end
      release  `ANA_TOP.A2D_CLK2MHZ;              
    end

    /*-----------------------------BIST-------------------------------*/       
    //Module : BIST , Direction : D2A , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL                   
        force `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[3][0] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[3][0];
        if (`ANA_TOP.D2A_BIST_EN !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_OSC2MHZ_TRIM :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_BIST_EN, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[3][0];  
`else
        force `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[24] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[24];
        if (`ANA_TOP.D2A_BIST_EN !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_OSC2MHZ_TRIM :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_BIST_EN, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[24];  
`endif                     
    end

    //Module : BIST , Direction : D2A , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL                           
        force `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[3][4:1] = $random;
        #10000ns;
        rand_num[3:0] = `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[3][4:1];
        if (`ANA_TOP.D2A_BIST_SEL !== rand_num[3:0]) begin
        `nnc_error("ANA", $sformatf("D2A_BIST_SEL :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_BIST_SEL, rand_num[3:0]))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[3][4:1];
`else
        force `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[28:25] = $random;
        #10000ns;
        rand_num[3:0] = `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[28:25];
        if (`ANA_TOP.D2A_BIST_SEL !== rand_num[3:0]) begin
        `nnc_error("ANA", $sformatf("D2A_BIST_SEL :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_BIST_SEL, rand_num[3:0]))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[28:25];
`endif                                         
    end  

    /*-----------------------------CH1-------------------------------*/    
    //Module : CH1 , Direction : D2A , Connection : OTP THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL                                   
        force `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[4] = $random;
        #10000ns;
        rand_num[7:0] = `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[4];
        if (`ANA_TOP.D2A_VDAC_VTRIM_CH1[2:0] !== rand_num[2:0]) begin
        `nnc_error("ANA", $sformatf("D2A_VDAC_VTRIM_CH1[2:0] :%b is not as expectation of rand_num[2:0]: %b",`ANA_TOP.D2A_VDAC_VTRIM_CH1[2:0], rand_num[2:0]))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[4]; 
`else
        force `ANA_WRAPPER_TOP.pinmux_if_D2A_TRIM_SIG[39:32] = $random;
        #10000ns;
        rand_num[7:0] = `ANA_WRAPPER_TOP.pinmux_if_D2A_TRIM_SIG[39:32];
        if (`ANA_TOP.D2A_VDAC_VTRIM_CH1[2:0] !== rand_num[2:0]) begin
        `nnc_error("ANA", $sformatf("D2A_VDAC_VTRIM_CH1[2:0] :%b is not as expectation of rand_num[2:0]: %b",`ANA_TOP.D2A_VDAC_VTRIM_CH1[2:0], rand_num[2:0]))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if_D2A_TRIM_SIG[39:32];
`endif                                   
    end

    //Module : CH1 , Direction : D2A , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL                                           
        force `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[1][0] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[1][0];
        if (`ANA_TOP.D2A_CS_EN_CH_CH1 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_CS_EN_CH_CH1 :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_CS_EN_CH_CH1, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[1][0];  
`else
        force `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[8] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[8];
        if (`ANA_TOP.D2A_CS_EN_CH_CH1 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_CS_EN_CH_CH1 :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_CS_EN_CH_CH1, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[8];  
`endif      
    end

    //Module : CH1 , Direction : D2A , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL                                                   
        force `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[1][1] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[1][1];
        if (`ANA_TOP.D2A_DRIVERA_CSAMP_EN_CH1 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_OSC2MHZ_TRIM :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_DRIVERA_CSAMP_EN_CH1, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[1][1];
`else
        force `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[9] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[9];
        if (`ANA_TOP.D2A_DRIVERA_CSAMP_EN_CH1 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_OSC2MHZ_TRIM :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_DRIVERA_CSAMP_EN_CH1, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[9];
`endif                      
    end

    //Module : CH1 , Direction : D2A , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL                                                           
        force `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[1][2] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[1][2];
        if (`ANA_TOP.D2A_COMP_EN_CH1 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_OSC2MHZ_TRIM :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_COMP_EN_CH1, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[1][2]; 
`else
        force `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[10] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[10];
        if (`ANA_TOP.D2A_COMP_EN_CH1 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_OSC2MHZ_TRIM :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_COMP_EN_CH1, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[10]; 
`endif                         
    end

    //Module : CH1 , Direction : D2A , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL        
        force `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[1][3] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[1][3];
        if (`ANA_TOP.D2A_IDAC_EN_CH1 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_OSC2MHZ_TRIM :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_IDAC_EN_CH1, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[1][3]; 
`else
        force `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[11] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[11];
        if (`ANA_TOP.D2A_IDAC_EN_CH1 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_OSC2MHZ_TRIM :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_IDAC_EN_CH1, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[11]; 
`endif                             
    end

    //Module : CH1 , Direction : D2A , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL                
        force `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[1][4] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[1][4];
        if (`ANA_TOP.D2A_VDAC_EN_CH1 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_OSC2MHZ_TRIM :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_VDAC_EN_CH1, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[1][4]; 
`else
        force `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[12] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[12];
        if (`ANA_TOP.D2A_VDAC_EN_CH1 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_OSC2MHZ_TRIM :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_VDAC_EN_CH1, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[12]; 
`endif                   
    end

    //Module : CH1 , Direction : D2A , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL                        
        force `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[1][5] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[1][5];
        if (`ANA_TOP.D2A_STIMU_COMP_EN_CH1 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_STIMU_COMP_EN_CH1 :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_STIMU_COMP_EN_CH1, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[1][5]; 
`else
        force `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[13] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[13];
        if (`ANA_TOP.D2A_STIMU_COMP_EN_CH1 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_STIMU_COMP_EN_CH1 :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_STIMU_COMP_EN_CH1, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[13]; 
`endif                   
    end

    //Module : CH1 , Direction : D2A , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL            
        force `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[1][6] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[1][6];
        if (`ANA_TOP.D2A_STIMU_COMP_SEL_CH1 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_STIMU_COMP_SEL_CH1 :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_STIMU_COMP_SEL_CH1, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[1][6]; 
`else
        force `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[14] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[14];
        if (`ANA_TOP.D2A_STIMU_COMP_SEL_CH1 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_STIMU_COMP_SEL_CH1 :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_STIMU_COMP_SEL_CH1, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[14]; 
`endif                    
    end

    //Module : CH1 , Direction : D2A , Connection : OTP THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL        
        force `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[4] = $random;
        #10000ns;
        rand_num[7:0] = `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[4];
        if (`ANA_TOP.D2A_CS_TRIM_CH1[2:0] !== {rand_num[7], rand_num[4:3]}) begin
        `nnc_error("ANA", $sformatf("D2A_CS_TRIM_CH1[3:0] :%b is not as expectation of rand_num[6:3]: %b",`ANA_TOP.D2A_CS_TRIM_CH1[2:0], {rand_num[7], rand_num[4:3]}))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[4]; 
`else
        force `ANA_WRAPPER_TOP.pinmux_if_D2A_TRIM_SIG[39:32] = $random;
        #10000ns;
        rand_num[7:0] = `ANA_WRAPPER_TOP.pinmux_if_D2A_TRIM_SIG[39:32];
        if (`ANA_TOP.D2A_CS_TRIM_CH1[2:0] !== {rand_num[7], rand_num[4:3]}) begin
        `nnc_error("ANA", $sformatf("D2A_CS_TRIM_CH1[3:0] :%b is not as expectation of rand_num[6:3]: %b",`ANA_TOP.D2A_CS_TRIM_CH1[2:0], {rand_num[7], rand_num[4:3]}))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if_D2A_TRIM_SIG[39:32]; 
`endif                   
    end  
     
    //Module : CH1 , Direction : WG , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL                
        force `ANA_WRAPPER_TOP.spi_ana_if.D2A_ANA_GEN_REG[2][4] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.spi_ana_if.D2A_ANA_GEN_REG[2][4];
        //if (`ANA_TOP.D2A_COMP_ISEL_CH1 !== rand_bit) begin
        //`nnc_error("ANA", $sformatf("D2A_COMP_ISEL_CH1 :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_COMP_ISEL_CH1, rand_bit))
        //end
      release  `ANA_WRAPPER_TOP.spi_ana_if.D2A_ANA_GEN_REG[2][4]; 
`endif                                      
    end

    //Module : CH1 , Direction : WG , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL                
        force {`ANA_WRAPPER_TOP.spi_ana_if.D2A_ANA_GEN_REG[2][3:0],`ANA_WRAPPER_TOP.spi_ana_if.D2A_ANA_GEN_REG[1]} = $random;
        #10000ns;
        rand_num[11:0] = {`ANA_WRAPPER_TOP.spi_ana_if.D2A_ANA_GEN_REG[2][3:0],`ANA_WRAPPER_TOP.spi_ana_if.D2A_ANA_GEN_REG[1]};
        if (`ANA_TOP.D2A_VDAC_DIN_CH1[11:0] !== rand_num[11:0]) begin
        `nnc_error("ANA", $sformatf("D2A_VDAC_DIN_CH1 :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_VDAC_DIN_CH1[11:0], rand_num[11:0]))
        end
      release  {`ANA_WRAPPER_TOP.spi_ana_if.D2A_ANA_GEN_REG[2][3:0],`ANA_WRAPPER_TOP.spi_ana_if.D2A_ANA_GEN_REG[1]}; 
`else
        force `ANA_WRAPPER_TOP.spi_ana_if_D2A_ANA_GEN_REG[19:8] = $random;
        #10000ns;
        rand_num[11:0] = `ANA_WRAPPER_TOP.spi_ana_if_D2A_ANA_GEN_REG[19:8];
        if (`ANA_TOP.D2A_VDAC_DIN_CH1[11:0] !== rand_num[11:0]) begin
        `nnc_error("ANA", $sformatf("D2A_VDAC_DIN_CH1 :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_VDAC_DIN_CH1[11:0], rand_num[11:0]))
        end
      release  `ANA_WRAPPER_TOP.spi_ana_if_D2A_ANA_GEN_REG[19:8]; 
`endif                                      
    end

    //Module : CH1 , Direction : WG , Connection : WG.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.i_sourcea_driver_a[0]  = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.i_sourcea_driver_a[0];
        if (`ANA_TOP.D2A_DRIVERA_SOURCEA_CH1 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_DRIVERA_SOURCEA :%b is not as expectation of `ANA_WRAPPER_TOP.i_sourcea_driver_a: %b",`ANA_TOP.D2A_DRIVERA_SOURCEA_CH1, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.i_sourcea_driver_a[0];              
    end  

    //Module : CH1 , Direction : WG , Connection : WG.    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.i_sourceb_driver_a[0]  = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.i_sourceb_driver_a[0];
        if (`ANA_TOP.D2A_DRIVERA_SOURCEB_CH1 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_DRIVERA_SOURCEB :%b is not as expectation of `ANA_WRAPPER_TOP.i_sourceb_driver_a: %b",`ANA_TOP.D2A_DRIVERA_SOURCEB_CH1, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.i_sourceb_driver_a[0];              
    end

    //Module : CH1 , Direction : WG , Connection : WG.    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.i_pullda_driver_a[0]  = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.i_pullda_driver_a[0];
        if (`ANA_TOP.D2A_DRIVERA_PULLDA_CH1 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_DRIVERA_PULLDA_CH1 :%b is not as expectation of `ANA_WRAPPER_TOP.i_pullda_driver_a: %b",`ANA_TOP.D2A_DRIVERA_PULLDA_CH1, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.i_pullda_driver_a[0];              
    end

    //Module : CH1 , Direction : WG , Connection : WG.    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.i_pulldb_driver_a[0]  = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.i_pulldb_driver_a[0];
        if (`ANA_TOP.D2A_DRIVERA_PULLDB_CH1 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_DRIVERA_PULLDB_CH1 :%b is not as expectation of `ANA_WRAPPER_TOP.i_pulldb_driver_a: %b",`ANA_TOP.D2A_DRIVERA_PULLDB_CH1, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.i_pulldb_driver_a[0];              
    end

    //Module : CH1 , Direction : WG , Connection : WG.    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.i_out_wave_drivera_dac0[11:0] = $random;
        #10000ns;
        rand_num[11:0] = `ANA_WRAPPER_TOP.i_out_wave_drivera_dac0[11:0];
        if (`ANA_TOP.D2A_IDAC_DIN_CH1 !== rand_num[11:0]) begin
        `nnc_error("ANA", $sformatf("D2A_IDAC_DIN_CH1 :%b is not as expectation of rand_num[11:0]: %b",`ANA_TOP.D2A_IDAC_DIN_CH1, rand_num[11:0]))
        end
      release  `ANA_WRAPPER_TOP.i_out_wave_drivera_dac0[11:0];              
    end

    //Module : PMU , Direction : A2D , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL                        
        force `ANA_TOP.A2D_COMP_OUT_STIMU0_1 = $random;
        #10000ns;
        rand_bit = `ANA_TOP.A2D_COMP_OUT_STIMU0_1;
        if (`ANA_WRAPPER_TOP.spi_ana_if.A2D_ANA_GEN_REG[0][1] !== rand_bit) begin
          `nnc_error("ANA", $sformatf("A2D_ANA_GEN_REG_0[1] :%b is not as expectation of rand_bit : %b",`ANA_WRAPPER_TOP.spi_ana_if.A2D_ANA_GEN_REG[0][1], rand_bit))
        end
      release  `ANA_TOP.A2D_COMP_OUT_STIMU0_1;  
`else
        force `ANA_TOP.A2D_COMP_OUT_STIMU0_1 = $random;
        #10000ns;
        rand_bit = `ANA_TOP.A2D_COMP_OUT_STIMU0_1;
        if (`ANA_WRAPPER_TOP.spi_ana_if_A2D_ANA_GEN_REG[1] !== rand_bit) begin
          `nnc_error("ANA", $sformatf("A2D_ANA_GEN_REG_0[1] :%b is not as expectation of rand_bit : %b",`ANA_WRAPPER_TOP.spi_ana_if_A2D_ANA_GEN_REG[1], rand_bit))
        end
      release  `ANA_TOP.A2D_COMP_OUT_STIMU0_1;  
`endif                   
    end

    //Module : CH1 , Direction : A2D , Connection : A2D_COMP0 at top level.    
    for (int i=0; i < 100; i++) begin
        force `ANA_TOP.A2D_COMP_OUT_CH1 = $random;
        #10000ns;
        rand_bit = `ANA_TOP.A2D_COMP_OUT_CH1;
        if (`ANA_WRAPPER_TOP.A2D_COMP_OUT_CH1 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("A2D_COMP0 :%b is not as expectation of rand_bit: %b",`ANA_WRAPPER_TOP.A2D_COMP_OUT_CH1, rand_bit))
        end
      release  `ANA_TOP.A2D_COMP_OUT_CH1;              
    end

    //Module : CH2 , Direction : D2A , Connection : OTP THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL                                
        force `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[5] = $random;
        #10000ns;
        rand_num[7:0] = `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[5];
        if (`ANA_TOP.D2A_VDAC_VTRIM_CH2[2:0] !== rand_num[2:0]) begin
        `nnc_error("ANA", $sformatf("D2A_VDAC_VTRIM_CH1[2:0] :%b is not as expectation of rand_num[2:0]: %b",`ANA_TOP.D2A_VDAC_VTRIM_CH2[2:0], rand_num[2:0]))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[5];   
`else
        force `ANA_WRAPPER_TOP.pinmux_if_D2A_TRIM_SIG[47:40] = $random;
        #10000ns;
        rand_num[7:0] = `ANA_WRAPPER_TOP.pinmux_if_D2A_TRIM_SIG[47:40];
        if (`ANA_TOP.D2A_VDAC_VTRIM_CH2[2:0] !== rand_num[2:0]) begin
        `nnc_error("ANA", $sformatf("D2A_VDAC_VTRIM_CH1[2:0] :%b is not as expectation of rand_num[2:0]: %b",`ANA_TOP.D2A_VDAC_VTRIM_CH2[2:0], rand_num[2:0]))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if_D2A_TRIM_SIG[47:40];
`endif                                    
    end
    
    //Module : CH2 , Direction : D2A , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL        
        force `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[2][0] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[2][0];
        if (`ANA_TOP.D2A_CS_EN_CH_CH2 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_CS_EN_CH_CH2 :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_CS_EN_CH_CH2, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[2][0]; 
`else
        force `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[16] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[16];
        if (`ANA_TOP.D2A_CS_EN_CH_CH2 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_CS_EN_CH_CH2 :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_CS_EN_CH_CH2, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[16]; 
`endif                   
    end

    //Module : CH2 , Direction : D2A , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL                
        force `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[2][1] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[2][1];
        if (`ANA_TOP.D2A_DRIVERA_CSAMP_EN_CH2 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_DRIVERA_CSAMP_EN_CH2 :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_DRIVERA_CSAMP_EN_CH2, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[2][1]; 
`else 
        force `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[17] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[17];
        if (`ANA_TOP.D2A_DRIVERA_CSAMP_EN_CH2 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_DRIVERA_CSAMP_EN_CH2 :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_DRIVERA_CSAMP_EN_CH2, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[17]; 
`endif                                     
    end

    //Module : CH2 , Direction : D2A , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL                        
        force `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[2][2] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[2][2];
        if (`ANA_TOP.D2A_COMP_EN_CH2 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_COMP_EN_CH2 :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_COMP_EN_CH2, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[2][2]; 
`else 
        force `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[18] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[18];
        if (`ANA_TOP.D2A_COMP_EN_CH2 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_COMP_EN_CH2 :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_COMP_EN_CH2, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[18]; 
`endif                      
    end

    //Module : CH2 , Direction : D2A , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL                                
        force `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[2][3] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[2][3];
        if (`ANA_TOP.D2A_IDAC_EN_CH2 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_IDAC_EN_CH2 :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_IDAC_EN_CH2, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[2][3]; 
`else
        force `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[19] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[19];
        if (`ANA_TOP.D2A_IDAC_EN_CH2 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_IDAC_EN_CH2 :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_IDAC_EN_CH2, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[19];  
`endif                    
    end

    //Module : CH2 , Direction : D2A , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL                                        
        force `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[2][4] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[2][4];
        if (`ANA_TOP.D2A_VDAC_EN_CH2 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_VDAC_EN_CH2 :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_VDAC_EN_CH2, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[2][4]; 
`else
        force `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[20] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[20];
        if (`ANA_TOP.D2A_VDAC_EN_CH2 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_VDAC_EN_CH2 :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_VDAC_EN_CH2, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[20];
`endif                                       
    end

    //Module : CH2 , Direction : D2A , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL         
        force `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[2][5] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[2][5];
        if (`ANA_TOP.D2A_STIMU_COMP_EN_CH2 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_STIMU_COMP_EN_CH2 :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_STIMU_COMP_EN_CH2, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[2][5]; 
`else
        force `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[21] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[21];
        if (`ANA_TOP.D2A_STIMU_COMP_EN_CH2 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_STIMU_COMP_EN_CH2 :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_STIMU_COMP_EN_CH2, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[21];
`endif                                
    end

    //Module : CH2 , Direction : D2A , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL                 
        force `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[2][6] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[2][6];
        if (`ANA_TOP.D2A_STIMU_COMP_SEL_CH2 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_STIMU_COMP_SEL_CH2 :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_STIMU_COMP_SEL_CH2, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[2][6];
`else
        force `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[22] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[22];
        if (`ANA_TOP.D2A_STIMU_COMP_SEL_CH2 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_STIMU_COMP_SEL_CH2 :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_STIMU_COMP_SEL_CH2, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG[22];
`endif                                                    
    end

    //Module : CH1 , Direction : D2A , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL                         
        force {`ANA_WRAPPER_TOP.spi_ana_if.D2A_ANA_GEN_REG[4][3:0],`ANA_WRAPPER_TOP.spi_ana_if.D2A_ANA_GEN_REG[3]} = $random;
        #10000ns;
        rand_num[11:0] = {`ANA_WRAPPER_TOP.spi_ana_if.D2A_ANA_GEN_REG[4][3:0],`ANA_WRAPPER_TOP.spi_ana_if.D2A_ANA_GEN_REG[3]};
        if (`ANA_TOP.D2A_VDAC_DIN_CH2[11:0] !== rand_num[11:0]) begin
        `nnc_error("ANA", $sformatf("D2A_VDAC_DIN_CH2 :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_VDAC_DIN_CH2[11:0], rand_num[9:0]))
        end
      release  {`ANA_WRAPPER_TOP.spi_ana_if.D2A_ANA_GEN_REG[4][3:0],`ANA_WRAPPER_TOP.spi_ana_if.D2A_ANA_GEN_REG[3]}; 
`else
        force `ANA_WRAPPER_TOP.spi_ana_if_D2A_ANA_GEN_REG[35:24] = $random;
        #10000ns;
        rand_num[11:0] = `ANA_WRAPPER_TOP.spi_ana_if_D2A_ANA_GEN_REG[35:24];
        if (`ANA_TOP.D2A_VDAC_DIN_CH2[11:0] !== rand_num[11:0]) begin
        `nnc_error("ANA", $sformatf("D2A_VDAC_DIN_CH2 :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_VDAC_DIN_CH2[11:0], rand_num[9:0]))
        end
      release  `ANA_WRAPPER_TOP.spi_ana_if_D2A_ANA_GEN_REG[35:24]; 
`endif                               
    end

    //Module : CH1 , Direction : WG , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL                
        force `ANA_WRAPPER_TOP.spi_ana_if.D2A_ANA_GEN_REG[4][4] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.spi_ana_if.D2A_ANA_GEN_REG[4][4];
        //if (`ANA_TOP.D2A_COMP_ISEL_CH2 !== rand_bit) begin
        //`nnc_error("ANA", $sformatf("D2A_COMP_ISEL_CH2 :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_COMP_ISEL_CH2, rand_bit))
        //end
      release  `ANA_WRAPPER_TOP.spi_ana_if.D2A_ANA_GEN_REG[4][4]; 
`endif                                      
    end
   
    //Module : CH2 , Direction : D2A , Connection : OTP THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL                                 
        force `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[5] = $random;
        #10000ns;
        rand_num[7:0] = `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[5];
        if (`ANA_TOP.D2A_CS_TRIM_CH2[2:0] !== {rand_num[7], rand_num[4:3]}) begin
        `nnc_error("ANA", $sformatf("D2A_CS_TRIM_CH2[3:0] :%b is not as expectation of rand_num[6:3]: %b",`ANA_TOP.D2A_CS_TRIM_CH2[2:0], {rand_num[7], rand_num[4:3]}))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[5]; 
`else 
        force `ANA_WRAPPER_TOP.pinmux_if_D2A_TRIM_SIG[47:40] = $random;
        #10000ns;
        rand_num[7:0] = `ANA_WRAPPER_TOP.pinmux_if_D2A_TRIM_SIG[47:40];
        if (`ANA_TOP.D2A_CS_TRIM_CH2[2:0] !== {rand_num[7], rand_num[4:3]}) begin
        `nnc_error("ANA", $sformatf("D2A_CS_TRIM_CH2[3:0] :%b is not as expectation of rand_num[6:3]: %b",`ANA_TOP.D2A_CS_TRIM_CH2[2:0], {rand_num[7], rand_num[4:3]}))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if_D2A_TRIM_SIG[46:43]; 
`endif                          
    end

    //Module : CH2 , Direction : WG , Connection : WG.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.i_sourcea_driver_a[1]  = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.i_sourcea_driver_a[1];
        if (`ANA_TOP.D2A_DRIVERA_SOURCEA_CH2 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_DRIVERA_SOURCEA :%b is not as expectation of `ANA_WRAPPER_TOP.i_sourcea_driver_a: %b",`ANA_TOP.D2A_DRIVERA_SOURCEA_CH2, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.i_sourcea_driver_a[1];              
    end  

    //Module : CH2 , Direction : WG , Connection : WG.    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.i_sourceb_driver_a[1]  = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.i_sourceb_driver_a[1];
        if (`ANA_TOP.D2A_DRIVERA_SOURCEB_CH2 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_DRIVERA_SOURCEB :%b is not as expectation of `ANA_WRAPPER_TOP.i_sourceb_driver_a: %b",`ANA_TOP.D2A_DRIVERA_SOURCEB_CH2, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.i_sourceb_driver_a[1];              
    end

    //Module : CH2 , Direction : WG , Connection : WG.    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.i_pullda_driver_a[1]  = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.i_pullda_driver_a[1];
        if (`ANA_TOP.D2A_DRIVERA_PULLDA_CH2 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_DRIVERA_PULLDA_CH2 :%b is not as expectation of `ANA_WRAPPER_TOP.i_pullda_driver_a: %b",`ANA_TOP.D2A_DRIVERA_PULLDA_CH2, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.i_pullda_driver_a[1];              
    end

    //Module : CH2 , Direction : WG , Connection : WG.    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.i_pulldb_driver_a[1]  = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.i_pulldb_driver_a[1];
        if (`ANA_TOP.D2A_DRIVERA_PULLDB_CH2 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_DRIVERA_PULLDB_CH2 :%b is not as expectation of `ANA_WRAPPER_TOP.i_pulldb_driver_a: %b",`ANA_TOP.D2A_DRIVERA_PULLDB_CH2, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.i_pulldb_driver_a[1];              
    end

    //Module : CH2 , Direction : WG , Connection : WG.    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.i_out_wave_drivera_dac1[11:0] = $random;
        #10000ns;
        rand_num[11:0] = `ANA_WRAPPER_TOP.i_out_wave_drivera_dac1[11:0];
        if (`ANA_TOP.D2A_IDAC_DIN_CH2 !== rand_num[11:0]) begin
        `nnc_error("ANA", $sformatf("D2A_IDAC_DIN_CH2 :%b is not as expectation of rand_num[11:0]: %b",`ANA_TOP.D2A_IDAC_DIN_CH2, rand_num[11:0]))
        end
      release  `ANA_WRAPPER_TOP.i_out_wave_drivera_dac1[11:0];              
    end

    //Module : CH2 , Direction : A2D , Connection : A2D.    
    for (int i=0; i < 100; i++) begin
        force `ANA_TOP.A2D_COMP_OUT_CH2 = $random;
        #10000ns;
        rand_bit = `ANA_TOP.A2D_COMP_OUT_CH2;
        if (`ANA_WRAPPER_TOP.A2D_COMP_OUT_CH2 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("A2D_COMP1 :%b is not as expectation of rand_bit: %b",`ANA_WRAPPER_TOP.A2D_COMP_OUT_CH2, rand_bit))
        end
      release  `ANA_TOP.A2D_COMP_OUT_CH2;              
    end

    //Module : CH2 , Direction : A2D , Connection : A2D.    
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL                                         
        force `ANA_TOP.A2D_COMP_OUT_STIMU2_3 = $random;
        #10000ns;
        rand_bit = `ANA_TOP.A2D_COMP_OUT_STIMU2_3;
        if (`ANA_WRAPPER_TOP.A2D_ANA_GEN_REG_0[2] !== rand_bit) begin
        `nnc_error("ANA", $sformatf("A2D_ANA_GEN_REG_0[2] :%b is not as expectation of rand_bit: %b",`ANA_WRAPPER_TOP.A2D_ANA_GEN_REG_0[2], rand_bit))
        end
      release  `ANA_TOP.A2D_COMP_OUT_STIMU2_3; 
`else
        force `ANA_TOP.A2D_COMP_OUT_STIMU2_3 = $random;
        #10000ns;
        rand_bit = `ANA_TOP.A2D_COMP_OUT_STIMU2_3;
        if (`ANA_WRAPPER_TOP.A2D_COMP_OUT_STIMU2_3 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("A2D_ANA_GEN_REG[2] :%b is not as expectation of rand_bit: %b",`ANA_WRAPPER_TOP.A2D_COMP_OUT_STIMU2_3, rand_bit))
        end
      release  `ANA_TOP.A2D_COMP_OUT_STIMU2_3; 
`endif                      
    end
      
    //Module : ATM , Direction : D2A , Connection : PINMUX.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_ATM0 = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.D2A_ATM0;
        if (`ANA_TOP.D2A_ATM0 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_ATM0 :%b is not as expectation of `ANA_WRAPPER_TOP.pinmux_if.D2A_ATM: %b",`ANA_TOP.D2A_ATM0, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.D2A_ATM0;              
    end

    //Module : ATM , Direction : D2A , Connection : PINMUX.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_ATM1 = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.D2A_ATM1;
        if (`ANA_TOP.D2A_ATM1 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_ATM1 :%b is not as expectation of `ANA_WRAPPER_TOP.pinmux_if.D2A_ATM: %b",`ANA_TOP.D2A_ATM1, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.D2A_ATM1;              
    end

    //Module : ATM , Direction : D2A , Connection : PINMUX.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_ATM2 = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.D2A_ATM2;
        if (`ANA_TOP.D2A_ATM2 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_ATM2 :%b is not as expectation of `ANA_WRAPPER_TOP.pinmux_if.D2A_ATM: %b",`ANA_TOP.D2A_ATM2, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.D2A_ATM2;              
    end

    //Module : ATM , Direction : D2A , Connection : PINMUX.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_ATM3 = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.D2A_ATM3;
        if (`ANA_TOP.D2A_ATM3 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_ATM3 :%b is not as expectation of `ANA_WRAPPER_TOP.pinmux_if.D2A_ATM: %b",`ANA_TOP.D2A_ATM3, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.D2A_ATM3;              
    end

    //Module : ATM , Direction : D2A , Connection : PINMUX.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_ATM4 = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.D2A_ATM4;
        if (`ANA_TOP.D2A_ATM4 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_ATM4 :%b is not as expectation of `ANA_WRAPPER_TOP.pinmux_if.D2A_ATM: %b",`ANA_TOP.D2A_ATM4, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.D2A_ATM4;              
    end

    //Module : ATM , Direction : D2A , Connection : PINMUX.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_ATM5 = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.D2A_ATM5;
        if (`ANA_TOP.D2A_ATM5 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_ATM5 :%b is not as expectation of `ANA_WRAPPER_TOP.pinmux_if.D2A_ATM: %b",`ANA_TOP.D2A_ATM5, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.D2A_ATM5;              
    end

    //Module : ATM , Direction : D2A , Connection : PINMUX.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_ATM6 = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.D2A_ATM6;
        if (`ANA_TOP.D2A_ATM6 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_ATM6 :%b is not as expectation of `ANA_WRAPPER_TOP.pinmux_if.D2A_ATM: %b",`ANA_TOP.D2A_ATM6, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.D2A_ATM6;              
    end

    //Module : ATM , Direction : D2A , Connection : PINMUX.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_ATM7 = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.D2A_ATM7;
        if (`ANA_TOP.D2A_ATM7 !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_ATM7 :%b is not as expectation of `ANA_WRAPPER_TOP.pinmux_if.D2A_ATM: %b",`ANA_TOP.D2A_ATM7, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.D2A_ATM7;              
    end
    
    //Module : SPARE , Direction : D2A , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL       
        force `ANA_WRAPPER_TOP.spi_ana_if.D2A_ANA_GEN_REG[5][7:0] = $random;
        #10000ns;
        rand_num[7:0] = `ANA_WRAPPER_TOP.spi_ana_if.D2A_ANA_GEN_REG[5][7:0];
        if (`ANA_TOP.D2A_SPI_SPARE0 !== rand_num[7:0]) begin
        `nnc_error("ANA", $sformatf("D2A_SPI_SPARE0 :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_SPI_SPARE0, rand_num[7:0]))
        end
      release  `ANA_WRAPPER_TOP.spi_ana_if.D2A_ANA_GEN_REG[5][7:0]; 
`else
        force `ANA_WRAPPER_TOP.spi_ana_if_D2A_ANA_GEN_REG[47:40] = $random;
        #10000ns;
        rand_num[7:0] = `ANA_WRAPPER_TOP.spi_ana_if_D2A_ANA_GEN_REG[47:40];
        if (`ANA_TOP.D2A_SPI_SPARE0 !== rand_num[7:0]) begin
        `nnc_error("ANA", $sformatf("D2A_SPI_SPARE0 :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_SPI_SPARE0, rand_num[7:0]))
        end
      release  `ANA_WRAPPER_TOP.spi_ana_if_D2A_ANA_GEN_REG[47:40]; 
`endif                       
    end

    //Module : SPARE , Direction : D2A , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL               
        force `ANA_WRAPPER_TOP.spi_ana_if.D2A_ANA_GEN_REG[6][7:0] = $random;
        #10000ns;
        rand_num[7:0] = `ANA_WRAPPER_TOP.spi_ana_if.D2A_ANA_GEN_REG[6][7:0];
        if (`ANA_TOP.D2A_SPI_SPARE1 !== rand_num[7:0]) begin
        `nnc_error("ANA", $sformatf("D2A_SPI_SPARE1 :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_SPI_SPARE1, rand_num[7:0]))
        end
      release  `ANA_WRAPPER_TOP.spi_ana_if.D2A_ANA_GEN_REG[6][7:0];
`else
        force `ANA_WRAPPER_TOP.spi_ana_if_D2A_ANA_GEN_REG[55:48] = $random;
        #10000ns;
        rand_num[7:0] = `ANA_WRAPPER_TOP.spi_ana_if_D2A_ANA_GEN_REG[55:48];
        if (`ANA_TOP.D2A_SPI_SPARE1 !== rand_num[7:0]) begin
        `nnc_error("ANA", $sformatf("D2A_SPI_SPARE1 :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_SPI_SPARE1, rand_num[7:0]))
        end
      release  `ANA_WRAPPER_TOP.spi_ana_if_D2A_ANA_GEN_REG[55:48];
`endif                                           
    end

    //Module : SPARE , Direction : D2A , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL                       
        force `ANA_WRAPPER_TOP.spi_ana_if.D2A_ANA_GEN_REG[7][7:0] = $random;
        #10000ns;
        rand_num[7:0] = `ANA_WRAPPER_TOP.spi_ana_if.D2A_ANA_GEN_REG[7][7:0];
        if (`ANA_TOP.D2A_SPI_SPARE2 !== rand_num[7:0]) begin
        `nnc_error("ANA", $sformatf("D2A_SPI_SPARE2 :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_SPI_SPARE2, rand_num[7:0]))
        end
      release  `ANA_WRAPPER_TOP.spi_ana_if.D2A_ANA_GEN_REG[7][7:0];
`else
        force `ANA_WRAPPER_TOP.spi_ana_if_D2A_ANA_GEN_REG[63:56] = $random;
        #10000ns;
        rand_num[7:0] = `ANA_WRAPPER_TOP.spi_ana_if_D2A_ANA_GEN_REG[63:56];
        if (`ANA_TOP.D2A_SPI_SPARE2 !== rand_num[7:0]) begin
        `nnc_error("ANA", $sformatf("D2A_SPI_SPARE2 :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_SPI_SPARE2, rand_num[7:0]))
        end
      release  `ANA_WRAPPER_TOP.spi_ana_if_D2A_ANA_GEN_REG[63:56];
`endif                         
    end

    //Module : SPARE , Direction : D2A , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL                               
        force `ANA_WRAPPER_TOP.spi_ana_if.D2A_ANA_GEN_REG[8][7:0] = $random;
        #10000ns;
        rand_num[7:0] = `ANA_WRAPPER_TOP.spi_ana_if.D2A_ANA_GEN_REG[8][7:0];
        if (`ANA_TOP.D2A_SPI_SPARE3 !== rand_num[7:0]) begin
        `nnc_error("ANA", $sformatf("D2A_SPI_SPARE3 :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_SPI_SPARE3, rand_num[7:0]))
        end
      release  `ANA_WRAPPER_TOP.spi_ana_if.D2A_ANA_GEN_REG[8][7:0];  
`else 
        force `ANA_WRAPPER_TOP.spi_ana_if_D2A_ANA_GEN_REG[71:64] = $random;
        #10000ns;
        rand_num[7:0] = `ANA_WRAPPER_TOP.spi_ana_if_D2A_ANA_GEN_REG[71:64];
        if (`ANA_TOP.D2A_SPI_SPARE3 !== rand_num[7:0]) begin
        `nnc_error("ANA", $sformatf("D2A_SPI_SPARE3 :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_SPI_SPARE3, rand_num[7:0]))
        end
      release  `ANA_WRAPPER_TOP.spi_ana_if_D2A_ANA_GEN_REG[71:64];  
`endif                                          
    end

    //Module : SPARE , Direction : D2A , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL                                       
        force `ANA_WRAPPER_TOP.D2A_TRIM0_SIG_SPARE[7:0] = $random;
        #10000ns;
        rand_num[7:0] = `ANA_WRAPPER_TOP.D2A_TRIM0_SIG_SPARE[7:0];
        if (`ANA_TOP.D2A_TRIM0_SIG_SPARE !== rand_num[7:0]) begin
        `nnc_error("ANA", $sformatf("D2A_TRIM0_SIG_SPARE :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_TRIM0_SIG_SPARE, rand_num[7:0]))
        end
      release  `ANA_WRAPPER_TOP.D2A_TRIM0_SIG_SPARE[7:0];
`else
        force `ANA_WRAPPER_TOP.pinmux_if_D2A_TRIM_SIG[63:56] = $random;
        #10000ns;
        rand_num[7:0] = `ANA_WRAPPER_TOP.pinmux_if_D2A_TRIM_SIG[63:56];
        if (`ANA_TOP.D2A_TRIM0_SIG_SPARE !== rand_num[7:0]) begin
        `nnc_error("ANA", $sformatf("D2A_TRIM0_SIG_SPARE :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_TRIM0_SIG_SPARE, rand_num[7:0]))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if_D2A_TRIM_SIG[63:56];
`endif                                                               
    end
    
    //Module : SPARE , Direction : A2D , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
`ifdef BEHAVIORAL                                               
        force `ANA_TOP.A2D_SPARE_RO_REG_0 = $random;
        #10000ns;
        rand_num[7:0] = `ANA_TOP.A2D_SPARE_RO_REG_0;
        if (`ANA_WRAPPER_TOP.A2D_SPARE_RO_REG_0 !== rand_num[7:0]) begin
        `nnc_error("ANA", $sformatf("A2D_SPARE_RO_REG_0 :%b is not as expectation of rand_bit : %b",`ANA_WRAPPER_TOP.A2D_SPARE_RO_REG_0, rand_num[7:0]))
        end
      release  `ANA_TOP.A2D_SPARE_RO_REG_0; 
`else
        force `ANA_TOP.A2D_SPARE_RO_REG_0 = $random;
        #10000ns;
        rand_num[7:0] = `ANA_TOP.A2D_SPARE_RO_REG_0;
        if (`ANA_WRAPPER_TOP.A2D_SPARE_RO_REG_0_tmp !== rand_num[7:0]) begin
        `nnc_error("ANA", $sformatf("A2D_SPARE_RO_REG_0 :%b is not as expectation of rand_bit : %b",`ANA_WRAPPER_TOP.A2D_SPARE_RO_REG_0_tmp, rand_num[7:0]))
        end
      release  `ANA_TOP.A2D_SPARE_RO_REG_0; 
`endif                                                                                  
    end

    //for (int i=0; i < 100; i++) begin
    //    force `ANA_TOP.VDD_DIG = $random;
    //    #10000ns;
    //    rand_bit = `ANA_TOP.VDD_DIG;
    //    if (`ANA_WRAPPER_TOP.VDD_DIG !== rand_bit) begin
    //    `nnc_error("ANA", $sformatf("VDD_DIG :%b is not as expectation of rand_bit : %b",`ANA_WRAPPER_TOP.VDD_DIG, rand_bit))
    //    end
    //  release  `ANA_TOP.VDD_DIG;              
    //end

    //for (int i=0; i < 100; i++) begin
    //    force `ANA_TOP.VSS_DIG = $random;
    //    #10000ns;
    //    rand_bit = `ANA_TOP.VSS_DIG;
    //    if (`ANA_WRAPPER_TOP.VSS_DIG !== rand_bit) begin
    //    `nnc_error("ANA", $sformatf("VSS_DIG :%b is not as expectation of rand_bit : %b",`ANA_WRAPPER_TOP.VSS_DIG, rand_bit))
    //    end
    //  release  `ANA_TOP.VSS_DIG;              
    //end


    end
  endtask  

  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction
endclass : `TESTNAME        
