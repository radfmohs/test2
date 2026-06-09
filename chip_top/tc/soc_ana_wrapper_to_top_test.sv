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
    `nnc_info("PMU", "Start  testing PMU", NNC_LOW)
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[0] = $random;
        #10000ns;
        rand_num[7:0] = `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[0];
        if (`ANA_TOP.D2A_BG_TRIM[7:0] !== rand_num[7:0]) begin // Only use 6-bit
        `nnc_error("ANA", $sformatf("D2A_BG_TRIM :%b is not as expectation of `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[0][7:0]: %b",`ANA_TOP.D2A_BG_TRIM[7:0], rand_num[7:0]))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[0]; 
    end

    //Module : PMU , Direction : D2A , Connection : OTP THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[1] = $random;
        #10000ns;
        rand_num[7:0] = `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[1];
        if (`ANA_TOP.D2A_BGBUFFER_TRIM[7:0] !== rand_num[7:0]) begin // Only use 6-bit
        `nnc_error("ANA", $sformatf("D2A_BGBUFFER_TRIM :%b is not as expectation of `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[1][7:0]: %b",`ANA_TOP.D2A_BGBUFFER_TRIM[7:0], rand_num[7:0]))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[1];  
    end

    //Module : PMU , Direction : D2A , Connection : OTP THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[2] = $random;
        #10000ns;
        rand_num[7:0] = `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[2];
        if (`ANA_TOP.D2A_IREF_TRIM[7:0] !== rand_num[7:0]) begin // Only use 5-bit
        `nnc_error("ANA", $sformatf("D2A_IREF_TRIM :%b is not as expectation of `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[2][7:0]: %b",`ANA_TOP.D2A_IREF_TRIM[7:0],  rand_num[7:0]))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[2]; 
    end

   for (int i=0; i < 100; i++) begin   
        force `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[3] = $random;
        #10000ns;
        rand_num[7:0] = `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[3];
        if (`ANA_TOP.D2A_CLDO1P8_TRIM[7:0] !== rand_num[7:0]) begin
        `nnc_error("ANA", $sformatf("D2A_CLDO1P8_TRIM :%b is not as expectation of rand_num[7:0] : %b",`ANA_TOP.D2A_CLDO1P8_TRIM[7:0], rand_num[7:0]))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[3];  
    end

    for (int i=0; i < 100; i++) begin 
        force `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[4] = $random;
        #10000ns;
        rand_num[7:0] = `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[4];
        if (`ANA_TOP.D2A_OSC8MHZ_TRIM[7:0] !== rand_num[7:0]) begin
        `nnc_error("ANA", $sformatf("D2A_OSC8MHZ_TRIM[7:0] :%b is not as expectation of rand_num[7:0]: %b",`ANA_TOP.D2A_OSC8MHZ_TRIM[7:0], rand_num[7:0]))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[4]; 
    end

    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[5] = $random;
        #10000ns;
        rand_num[7:0] = `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[5];
        if (`ANA_TOP.D2A_TSC_TRIM[7:0] !== rand_num[7:0]) begin
        `nnc_error("ANA", $sformatf("D2A_TSC_TRIM[7:0] :%b is not as expectation of rand_num[7:0]: %b",`ANA_TOP.D2A_TSC_TRIM[7:0], rand_num[7:0]))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[5];   
    end
 
    //Module : PMU , Direction : D2A , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[0][1] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[0][1];
        if (`ANA_TOP.D2A_OSC8MHZEN !== rand_num[1] || `ANA_TOP.D2A_BGBUFFER_CPTEST_EN !== rand_num[0]) begin
          `nnc_error("ANA", $sformatf("ANA_ENABLE_REG_0_1 %b is not as expectation of rand_num : %8b", {6'b000000, `ANA_TOP.D2A_OSC8MHZEN, `ANA_TOP.D2A_BGBUFFER_CPTEST_EN}, rand_num))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[0][1];
    end
    
    //Module : PMU , Direction : D2A , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[0][3] = $random;
        #10000ns;
        rand_num[0] = `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[0][3];
        if (`ANA_TOP.D2A_LVD_EN !== rand_num[0]) begin
          `nnc_error("ANA", $sformatf("ANA_ENABLE_REG_0_0 %b is not as expectation of rand_num : %1b", `ANA_TOP.D2A_LVD_EN, rand_num[0]))
        end
      release  `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG[0][3];
    end

    //Module : PMU , Direction : D2A , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.spi_ana_if.D2A_ANA_GEN_REG[0][0] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.spi_ana_if.D2A_ANA_GEN_REG[0][0];
        if (`ANA_TOP.D2A_LVD_SEL !== rand_num[2:0]) begin
          `nnc_error("ANA", $sformatf("D2A_LVD_SEL :%b is not as expectation of rand_num[2:0] : %3b",`ANA_TOP.D2A_LVD_SEL, rand_num[2:0]))
        end
      release  `ANA_WRAPPER_TOP.spi_ana_if.D2A_ANA_GEN_REG[0][2:0]; 
    end
    
    //Module : PMU , Direction : D2A , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_EN_TSC = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_EN_TSC;
        if (`ANA_TOP.D2A_EN_TSC !== rand_num[0]) begin
          `nnc_error("ANA", $sformatf("D2A_LVD_SEL :%b is not as expectation of rand_num : %1b",`ANA_TOP.D2A_EN_TSC, rand_num[0]))
        end
      release  `ANA_WRAPPER_TOP.D2A_EN_TSC; 
    end
     
    //Module : PMU , Direction : D2A , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_TOP.A2D_LVD = $random;
        #10000ns;
        rand_bit = `ANA_TOP.A2D_LVD;
        if (`ANA_WRAPPER_TOP.spi_ana_if.A2D_ANA_GEN_REG[0][0] !== rand_bit) begin
          `nnc_error("ANA", $sformatf("A2D_ANA_GEN_REG_0[0] :%b is not as expectation of rand_bit : %b",`ANA_WRAPPER_TOP.spi_ana_if.A2D_ANA_GEN_REG[0][0], rand_bit))
        end
      release  `ANA_TOP.A2D_LVD; 
    end
    
    //Module : PMU , Direction : D2A , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_TOP.A2D_TSC_COMP_OUT = $random;
        #10000ns;
        rand_bit = `ANA_TOP.A2D_TSC_COMP_OUT;
        if (`ANA_WRAPPER_TOP.A2D_ANA_GEN_REG_0[1] !== rand_bit) begin
          `nnc_error("ANA", $sformatf("A2D_ANA_GEN_REG_0 :%b is not as expectation of rand_bit : %b",`ANA_WRAPPER_TOP.A2D_ANA_GEN_REG_0[1], rand_bit))
        end
      release  `ANA_TOP.A2D_TSC_COMP_OUT; 
    end
/*    
    //Module : PMU , Direction : D2A , Connection : SPI THROUGH PINMUX.
      `WR_NORMAL_REG(`SOC_TSC_EN_REG_SEL_REG, 8'h10, 8'h00);
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[0][14][2:0] = $random;
        #10000ns;
        //rand_bit = `ANA_WRAPPER_TOP.D2A_ADJ0_14_IO;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[0][14][2:0];
        if (`ANA_TOP.D2A_VDAC8B_DIN !== rand_num[2:0]) begin
          `nnc_error("ANA", $sformatf("D2A_VDAC8B_DIN :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_VDAC8B_DIN, rand_num[2:0]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[0][14][2:0];
        
        force `ANA_WRAPPER_TOP.D2A_ADJ0_IO = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_ADJ0_IO;
        if (`ANA_TOP.D2A_VDAC8B_DIN !== rand_num[7:0]) begin
          `nnc_error("ANA", $sformatf("D2A_VDAC8B_DIN :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_VDAC8B_DIN, rand_num[7:0]))
        end
        release `ANA_WRAPPER_TOP.D2A_ADJ0_IO;
        
        force `ANA_WRAPPER_TOP.D2A_ADJ14_IO = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_ADJ14_IO;
        if (`ANA_TOP.D2A_VDAC8B_DIN !== rand_num[7:0]) begin
          `nnc_error("ANA", $sformatf("D2A_VDAC8B_DIN :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_VDAC8B_DIN, rand_num[7:0]))
        end
        release `ANA_WRAPPER_TOP.D2A_ADJ14_IO;
    end
*/
    //Module : PMU , Direction : A2D , Connection : A2D_SW_POWER_POR at top level.
    for (int i=0; i < 100; i++) begin
        force `ANA_TOP.A2D_POR = $random;
        #10000ns;
        rand_bit = `ANA_TOP.A2D_POR;          
        if (`ANA_WRAPPER_TOP.A2D_POR !== rand_bit) begin
          `nnc_error("ANA", $sformatf("A2D_POR :%b is not as expectation of rand_bit : %b",`ANA_WRAPPER_TOP.A2D_POR, rand_bit))
        end
      release  `ANA_TOP.A2D_POR;              
    end
    
    //Module : PMU , Direction : A2D , Connection : A2D_OSC_OUT at top level.
    for (int i=0; i < 100; i++) begin
        force `ANA_TOP.A2D_CLK8MHZ = $random;
        #10000ns;
        rand_bit = `ANA_TOP.A2D_CLK8MHZ;          
        if (`ANA_WRAPPER_TOP.A2D_CLK8MHZ !== rand_bit) begin
          `nnc_error("ANA", $sformatf("A2D_CLK8MHZ :%b is not as expectation of rand_bit : %b",`ANA_WRAPPER_TOP.A2D_CLK8MHZ, rand_bit))
        end
      release  `ANA_TOP.A2D_CLK8MHZ;              
    end
    
    //-----------------------------BIST-------------------------------//       
    `nnc_info("BIST", "Start  testing BIST", NNC_LOW)
    //Module : BIST , Direction : D2A , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][0] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][0];
        if (`ANA_TOP.D2A_BIST_SEL !== rand_num[5:1] || `ANA_TOP.D2A_BIST_EN !== rand_num[0]) begin
          `nnc_error("ANA", $sformatf("ANA_ENABLE_REG_0_0 %b is not as expectation of rand_num : %8b",{2'b00, `ANA_TOP.D2A_BIST_SEL, `ANA_TOP.D2A_BIST_EN}, rand_num))
        end
      release  `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][0];
    end

    //-----------------------------DC LEAD OFF-------------------------------//    
    `nnc_info("DC LEAD OFF", "Start  testing DC LEAD OFF", NNC_LOW)
    //Module : DC LEAD OFF , Direction : D2A , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin // DONEEEEEEEEEEEEEEEEEEEEEE
        force `ANA_WRAPPER_TOP.ANA_ENABLE_REG[1][0] = $random;
        force `ANA_WRAPPER_TOP.ANA_ENABLE_REG[1][1] = $random;
        #10000ns;
        rand_num[15:0] = {`ANA_WRAPPER_TOP.ANA_ENABLE_REG[1][1],`ANA_WRAPPER_TOP.ANA_ENABLE_REG[1][0]};
        if (`ANA_TOP.D2A_DCLOFFEN !== rand_num[15:0]) begin
        `nnc_error("ANA", $sformatf("DCLOFFEN[15:0] :%b is not as expectation of rand_num: %b",`ANA_TOP.D2A_DCLOFFEN[15:0], rand_num[15:0]))
        end
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[1][0];
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[1][1];
    end

    //Module : DC LEAD OFF , Direction : D2A , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[1][14] = $random;
        #10000ns;
        rand_num[7:0] = `ANA_WRAPPER_TOP.ANA_GEN_REG[1][14];
        if (`ANA_TOP.D2A_LOFF_COMP_TH !== rand_num[2:0]) begin
        `nnc_error("ANA", $sformatf("LOFF_COMP_TH :%b is not as expectation of rand_num[2:0] : %3b",`ANA_TOP.D2A_LOFF_COMP_TH, rand_num[2:0]))
        end
        if (`ANA_TOP.D2A_LOFF_ISEL_ADJ !== rand_num[7:4]) begin
        `nnc_error("ANA", $sformatf("LOFF_ISEL_ADJ :%b is not as expectation of rand_num[7:4] : %4b",`ANA_TOP.D2A_LOFF_ISEL_ADJ, rand_num[7:4]))
        end
        if (`ANA_TOP.D2A_LOFF_IPOL !== rand_num[3]) begin
        `nnc_error("ANA", $sformatf("LOFF_IPOL :%b is not as expectation of rand_num[3] : %1b",`ANA_TOP.D2A_LOFF_IPOL, rand_num[3]))
        end
        release  `ANA_WRAPPER_TOP.ANA_ENABLE_REG[1][14];  
    end   
 
    //Module : DC LEAD OFF , Direction : A2D , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_TOP.A2D_LOFF_STATP = $random;                                      
        #10000ns;
        rand_num = `ANA_TOP.A2D_LOFF_STATP;
        if ({`ANA_WRAPPER_TOP.A2D_ANA_GEN_REG_2,`ANA_WRAPPER_TOP.A2D_ANA_GEN_REG_1} !== rand_num[15:0]) begin
        `nnc_error("ANA", $sformatf("{`ANA_WRAPPER_TOP.pinmux_if.A2D_ANA_GEN_REG[2],`ANA_WRAPPER_TOP.pinmux_if.A2D_ANA_GEN_REG[1]} :%b is not as expectation of rand_bit : %b",{`ANA_WRAPPER_TOP.A2D_ANA_GEN_REG_2,`ANA_WRAPPER_TOP.A2D_ANA_GEN_REG_1}, rand_num[15:0]))
        end
        release `ANA_TOP.A2D_LOFF_STATP;                                      
    end
    
    //Module : DC LEAD OFF , Direction : A2D , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_TOP.A2D_LOFF_STATN = $random;                                      
        #10000ns;
        rand_num = `ANA_TOP.A2D_LOFF_STATN;
        if ({`ANA_WRAPPER_TOP.A2D_ANA_GEN_REG_4,`ANA_WRAPPER_TOP.A2D_ANA_GEN_REG_3} !== rand_num[15:0]) begin
        `nnc_error("ANA", $sformatf("{`ANA_WRAPPER_TOP.pinmux_if.A2D_ANA_GEN_REG[4],`ANA_WRAPPER_TOP.pinmux_if.A2D_ANA_GEN_REG[3]} :%b is not as expectation of rand_bit : %b",{`ANA_WRAPPER_TOP.A2D_ANA_GEN_REG_4,`ANA_WRAPPER_TOP.A2D_ANA_GEN_REG_3}, rand_num[15:0]))
        end
        release `ANA_TOP.A2D_LOFF_STATN;                                      
    end

    //-----------------------------RECODING-------------------------------//    
    `nnc_info("RECORDING", "Start  testing Recording", NNC_LOW)
    //Module : RECODING , Direction : D2A , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][3][1] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][3][1];
        if (`ANA_TOP.D2A_BIAS_MEAS !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_BIAS_MEAS :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_BIAS_MEAS, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][3][1]; 
    end

    //Module : RECODING , Direction : D2A , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[0][0][3] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.ANA_GEN_REG[0][0][3];
        if (`ANA_TOP.D2A_BIASREF_INT !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_BIASREF_INT :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_BIASREF_INT, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.ANA_GEN_REG[0][0][3]; 
    end

    //Module : RECODING , Direction : D2A , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][2][2] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][2][2];
        if (`ANA_TOP.D2A_SDMVCMBUFF_EN !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_SDMVCMBUFF_EN :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_SDMVCMBUFF_EN, rand_bit))
        end
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][2][2];
    end
    
    //Module : RECODING , Direction : D2A , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[5][14] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[5][14];
        if (`ANA_TOP.D2A_SDMVCMBUFF_IADJ !== rand_num[1:0]) begin
        `nnc_error("ANA", $sformatf("D2A_SDMVCMBUFF_IADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_SDMVCMBUFF_IADJ, rand_num[1:0]))
        end
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[5][14];
    end
    
    //Module : RECODING , Direction : D2A , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][2][3] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][2][3];
        if (`ANA_TOP.D2A_SDMVREFPBUFF_EN !== rand_num[0]) begin
        `nnc_error("ANA", $sformatf("D2A_SDMVREFPBUFF_EN :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_SDMVREFPBUFF_EN, rand_num[0]))
        end
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][2][3];
    end 
    
    //Module : RECODING , Direction : D2A , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[6][14][1:0] = $random;
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[6][14][7:2] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[6][14];
        if (`ANA_TOP.D2A_SDMVREFP_IADJ !== rand_num[1:0]) begin
        `nnc_error("ANA", $sformatf("D2A_SDMVREFP_IADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_SDMVREFP_IADJ, rand_num[1:0]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[6][14];
    end
    
    //Module : RECODING , Direction : D2A , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][3][2] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][3][2];
        if (`ANA_TOP.D2A_RLD_EN !== rand_num[0]) begin
        `nnc_error("ANA", $sformatf("D2A_RLD_EN :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_RLD_EN, rand_num[0]))
        end
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][3][2];
    end
    
    //Module : RECODING , Direction : D2A , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][2][0] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][2][0];
        if (`ANA_TOP.D2A_RLD_ELECTRODE_EN !== rand_num[0]) begin
        `nnc_error("ANA", $sformatf("D2A_RLD_ELECTRODE_EN :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_RLD_ELECTRODE_EN, rand_num[0]))
        end
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][2][0];
    end
    
    //Module : RECODING , Direction : D2A , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[7][14] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[7][14];
        if (`ANA_TOP.D2A_RLD_IADJ !== rand_num[7:0]) begin
        `nnc_error("ANA", $sformatf("D2A_RLD_IADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_RLD_IADJ, rand_num[7:0]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[6][14];
    end
    
    //Module : RECODING , Direction : D2A , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[0][1] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[0][1];
        if (`ANA_TOP.D2A_EEG_CH0_SET !== rand_num[2:0]) begin
        `nnc_error("ANA", $sformatf("D2A_EEG_CH0_SET :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEG_CH0_SET, rand_num[2:0]))
        end
        if (`ANA_TOP.D2A_EEG_CH1_SET !== rand_num[5:3]) begin
        `nnc_error("ANA", $sformatf("D2A_EEG_CH1_SET :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEG_CH1_SET, rand_num[5:3]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[0][1];
    end
    
    //Module : RECODING , Direction : D2A , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[0][2] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[0][2];
        if (`ANA_TOP.D2A_EEG_CH2_SET !== rand_num[2:0]) begin
        `nnc_error("ANA", $sformatf("D2A_EEG_CH2_SET :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEG_CH2_SET, rand_num[2:0]))
        end
        if (`ANA_TOP.D2A_EEG_CH3_SET !== rand_num[5:3]) begin
        `nnc_error("ANA", $sformatf("D2A_EEG_CH3_SET :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEG_CH3_SET, rand_num[5:3]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[0][2];
    end
    
    //Module : RECODING , Direction : D2A , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[0][3] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[0][3];
        if (`ANA_TOP.D2A_EEG_CH4_SET !== rand_num[2:0]) begin
        `nnc_error("ANA", $sformatf("D2A_EEG_CH4_SET :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEG_CH4_SET, rand_num[2:0]))
        end
        if (`ANA_TOP.D2A_EEG_CH5_SET !== rand_num[5:3]) begin
        `nnc_error("ANA", $sformatf("D2A_EEG_CH5_SET :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEG_CH5_SET, rand_num[5:3]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[0][3];
    end
    
    //Module : RECODING , Direction : D2A , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[0][4] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[0][4];
        if (`ANA_TOP.D2A_EEG_CH6_SET !== rand_num[2:0]) begin
        `nnc_error("ANA", $sformatf("D2A_EEG_CH6_SET :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEG_CH6_SET, rand_num[2:0]))
        end
        if (`ANA_TOP.D2A_EEG_CH7_SET !== rand_num[5:3]) begin
        `nnc_error("ANA", $sformatf("D2A_EEG_CH7_SET :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEG_CH7_SET, rand_num[5:3]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[0][4];
    end
    
    //Module : RECODING , Direction : D2A , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[0][5] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[0][5];
        if (`ANA_TOP.D2A_EEG_CH8_SET !== rand_num[2:0]) begin
        `nnc_error("ANA", $sformatf("D2A_EEG_CH8_SET :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEG_CH8_SET, rand_num[2:0]))
        end
        if (`ANA_TOP.D2A_EEG_CH9_SET !== rand_num[5:3]) begin
        `nnc_error("ANA", $sformatf("D2A_EEG_CH9_SET :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEG_CH9_SET, rand_num[5:3]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[0][5];
    end
    
    //Module : RECODING , Direction : D2A , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[0][6] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[0][6];
        if (`ANA_TOP.D2A_EEG_CH10_SET !== rand_num[2:0]) begin
        `nnc_error("ANA", $sformatf("D2A_EEG_CH10_SET :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEG_CH11_SET, rand_num[2:0]))
        end
        if (`ANA_TOP.D2A_EEG_CH11_SET !== rand_num[5:3]) begin
        `nnc_error("ANA", $sformatf("D2A_EEG_CH11_SET :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEG_CH11_SET, rand_num[5:3]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[0][6];
    end
    
    //Module : RECODING , Direction : D2A , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[0][7] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[0][7];
        if (`ANA_TOP.D2A_EEG_CH12_SET !== rand_num[2:0]) begin
        `nnc_error("ANA", $sformatf("D2A_EEG_CH12_SET :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEG_CH12_SET, rand_num[2:0]))
        end
        if (`ANA_TOP.D2A_EEG_CH13_SET !== rand_num[5:3]) begin
        `nnc_error("ANA", $sformatf("D2A_EEG_CH13_SET :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEG_CH13_SET, rand_num[5:3]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[0][7];
    end
    
    //Module : RECODING , Direction : D2A , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[0][8] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[0][8];
        if (`ANA_TOP.D2A_EEG_CH14_SET !== rand_num[2:0]) begin
        `nnc_error("ANA", $sformatf("D2A_EEG_CH14_SET :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEG_CH14_SET, rand_num[2:0]))
        end
        if (`ANA_TOP.D2A_EEG_CH15_SET !== rand_num[5:3]) begin
        `nnc_error("ANA", $sformatf("D2A_EEG_CH15_SET :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEG_CH15_SET, rand_num[5:3]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[0][8];
    end
/*
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_INA_CLK = $random;
        #1;
        rand_num = `ANA_WRAPPER_TOP.D2A_INA_CLK;
        if (`ANA_TOP.D2A_INA_CLK !== rand_num[0]) begin
        `nnc_error("ANA", $sformatf("D2A_INA_CLK :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_INA_CLK, rand_num[0]))
        end
        release `ANA_WRAPPER_TOP.D2A_INA_CLK;
    end
*/
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[0][9] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[0][9];
        if (`ANA_TOP.D2A_GAIN_PGA_CH0_ADJ !== rand_num[3:0]) begin
        `nnc_error("ANA", $sformatf("D2A_GAIN_PGA_CH0_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_GAIN_PGA_CH0_ADJ, rand_num[3:0]))
        end
        if (`ANA_TOP.D2A_GAIN_PGA_CH1_ADJ !== rand_num[7:4]) begin
        `nnc_error("ANA", $sformatf("D2A_GAIN_PGA_CH1_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_GAIN_PGA_CH1_ADJ, rand_num[7:4]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[0][9];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[0][10] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[0][10];
        if (`ANA_TOP.D2A_GAIN_PGA_CH2_ADJ !== rand_num[3:0]) begin
        `nnc_error("ANA", $sformatf("D2A_GAIN_PGA_CH2_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_GAIN_PGA_CH2_ADJ, rand_num[3:0]))
        end
        if (`ANA_TOP.D2A_GAIN_PGA_CH3_ADJ !== rand_num[7:4]) begin
        `nnc_error("ANA", $sformatf("D2A_GAIN_PGA_CH3_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_GAIN_PGA_CH3_ADJ, rand_num[7:4]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[0][10];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[0][11] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[0][11];
        if (`ANA_TOP.D2A_GAIN_PGA_CH4_ADJ !== rand_num[3:0]) begin
        `nnc_error("ANA", $sformatf("D2A_GAIN_PGA_CH4_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_GAIN_PGA_CH4_ADJ, rand_num[3:0]))
        end
        if (`ANA_TOP.D2A_GAIN_PGA_CH5_ADJ !== rand_num[7:4]) begin
        `nnc_error("ANA", $sformatf("D2A_GAIN_PGA_CH5_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_GAIN_PGA_CH5_ADJ, rand_num[7:4]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[0][11];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[0][12] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[0][12];
        if (`ANA_TOP.D2A_GAIN_PGA_CH6_ADJ !== rand_num[3:0]) begin
        `nnc_error("ANA", $sformatf("D2A_GAIN_PGA_CH6_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_GAIN_PGA_CH6_ADJ, rand_num[3:0]))
        end
        if (`ANA_TOP.D2A_GAIN_PGA_CH7_ADJ !== rand_num[7:4]) begin
        `nnc_error("ANA", $sformatf("D2A_GAIN_PGA_CH7_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_GAIN_PGA_CH7_ADJ, rand_num[7:4]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[0][12];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[1][0] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[1][0];
        if (`ANA_TOP.D2A_GAIN_PGA_CH8_ADJ !== rand_num[3:0]) begin
        `nnc_error("ANA", $sformatf("D2A_GAIN_PGA_CH8_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_GAIN_PGA_CH8_ADJ, rand_num[3:0]))
        end
        if (`ANA_TOP.D2A_GAIN_PGA_CH9_ADJ !== rand_num[7:4]) begin
        `nnc_error("ANA", $sformatf("D2A_GAIN_PGA_CH9_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_GAIN_PGA_CH9_ADJ, rand_num[7:4]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[1][0];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[1][1] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[1][1];
        if (`ANA_TOP.D2A_GAIN_PGA_CH10_ADJ !== rand_num[3:0]) begin
        `nnc_error("ANA", $sformatf("D2A_GAIN_PGA_CH10_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_GAIN_PGA_CH10_ADJ, rand_num[3:0]))
        end
        if (`ANA_TOP.D2A_GAIN_PGA_CH11_ADJ !== rand_num[7:4]) begin
        `nnc_error("ANA", $sformatf("D2A_GAIN_PGA_CH11_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_GAIN_PGA_CH11_ADJ, rand_num[7:4]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[1][1];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[1][2] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[1][2];
        if (`ANA_TOP.D2A_GAIN_PGA_CH12_ADJ !== rand_num[3:0]) begin
        `nnc_error("ANA", $sformatf("D2A_GAIN_PGA_CH12_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_GAIN_PGA_CH12_ADJ, rand_num[3:0]))
        end
        if (`ANA_TOP.D2A_GAIN_PGA_CH13_ADJ !== rand_num[7:4]) begin
        `nnc_error("ANA", $sformatf("D2A_GAIN_PGA_CH13_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_GAIN_PGA_CH13_ADJ, rand_num[7:4]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[1][2];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[1][3] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[1][3];
        if (`ANA_TOP.D2A_GAIN_PGA_CH14_ADJ !== rand_num[3:0]) begin
        `nnc_error("ANA", $sformatf("D2A_GAIN_PGA_CH14_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_GAIN_PGA_CH14_ADJ, rand_num[3:0]))
        end
        if (`ANA_TOP.D2A_GAIN_PGA_CH15_ADJ !== rand_num[7:4]) begin
        `nnc_error("ANA", $sformatf("D2A_GAIN_PGA_CH15_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_GAIN_PGA_CH15_ADJ, rand_num[7:4]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[1][3];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[1][4] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[1][4];
        if (`ANA_TOP.D2A_GAIN_DDA_CH0_ADJ !== rand_num[2:0]) begin
        `nnc_error("ANA", $sformatf("D2A_GAIN_DDA_CH0_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_GAIN_DDA_CH0_ADJ, rand_num[2:0]))
        end
        if (`ANA_TOP.D2A_GAIN_DDA_CH1_ADJ !== rand_num[5:3]) begin
        `nnc_error("ANA", $sformatf("D2A_GAIN_DDA_CH1_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_GAIN_DDA_CH1_ADJ, rand_num[5:3]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[1][4];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[1][5] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[1][5];
        if (`ANA_TOP.D2A_GAIN_DDA_CH2_ADJ !== rand_num[2:0]) begin
        `nnc_error("ANA", $sformatf("D2A_GAIN_DDA_CH2_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_GAIN_DDA_CH2_ADJ, rand_num[2:0]))
        end
        if (`ANA_TOP.D2A_GAIN_DDA_CH3_ADJ !== rand_num[5:3]) begin
        `nnc_error("ANA", $sformatf("D2A_GAIN_DDA_CH3_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_GAIN_DDA_CH3_ADJ, rand_num[5:3]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[1][5];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[1][6] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[1][6];
        if (`ANA_TOP.D2A_GAIN_DDA_CH4_ADJ !== rand_num[2:0]) begin
        `nnc_error("ANA", $sformatf("D2A_GAIN_DDA_CH4_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_GAIN_DDA_CH4_ADJ, rand_num[2:0]))
        end
        if (`ANA_TOP.D2A_GAIN_DDA_CH5_ADJ !== rand_num[5:3]) begin
        `nnc_error("ANA", $sformatf("D2A_GAIN_DDA_CH5_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_GAIN_DDA_CH5_ADJ, rand_num[5:3]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[1][6];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[1][7] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[1][7];
        if (`ANA_TOP.D2A_GAIN_DDA_CH6_ADJ !== rand_num[2:0]) begin
        `nnc_error("ANA", $sformatf("D2A_GAIN_DDA_CH6_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_GAIN_DDA_CH6_ADJ, rand_num[2:0]))
        end
        if (`ANA_TOP.D2A_GAIN_DDA_CH7_ADJ !== rand_num[5:3]) begin
        `nnc_error("ANA", $sformatf("D2A_GAIN_DDA_CH7_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_GAIN_DDA_CH7_ADJ, rand_num[5:3]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[1][7];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[1][8] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[1][8];
        if (`ANA_TOP.D2A_GAIN_DDA_CH8_ADJ !== rand_num[2:0]) begin
        `nnc_error("ANA", $sformatf("D2A_GAIN_DDA_CH8_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_GAIN_DDA_CH8_ADJ, rand_num[2:0]))
        end
        if (`ANA_TOP.D2A_GAIN_DDA_CH9_ADJ !== rand_num[5:3]) begin
        `nnc_error("ANA", $sformatf("D2A_GAIN_DDA_CH9_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_GAIN_DDA_CH9_ADJ, rand_num[5:3]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[1][8];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[1][9] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[1][9];
        if (`ANA_TOP.D2A_GAIN_DDA_CH10_ADJ !== rand_num[2:0]) begin
        `nnc_error("ANA", $sformatf("D2A_GAIN_DDA_CH10_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_GAIN_DDA_CH10_ADJ, rand_num[2:0]))
        end
        if (`ANA_TOP.D2A_GAIN_DDA_CH11_ADJ !== rand_num[5:3]) begin
        `nnc_error("ANA", $sformatf("D2A_GAIN_DDA_CH11_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_GAIN_DDA_CH11_ADJ, rand_num[5:3]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[1][9];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[1][10] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[1][10];
        if (`ANA_TOP.D2A_GAIN_DDA_CH12_ADJ !== rand_num[2:0]) begin
        `nnc_error("ANA", $sformatf("D2A_GAIN_DDA_CH12_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_GAIN_DDA_CH12_ADJ, rand_num[2:0]))
        end
        if (`ANA_TOP.D2A_GAIN_DDA_CH13_ADJ !== rand_num[5:3]) begin
        `nnc_error("ANA", $sformatf("D2A_GAIN_DDA_CH13_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_GAIN_DDA_CH13_ADJ, rand_num[5:3]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[1][10];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[1][11] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[1][11];
        if (`ANA_TOP.D2A_GAIN_DDA_CH14_ADJ !== rand_num[2:0]) begin
        `nnc_error("ANA", $sformatf("D2A_GAIN_DDA_CH14_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_GAIN_DDA_CH14_ADJ, rand_num[2:0]))
        end
        if (`ANA_TOP.D2A_GAIN_DDA_CH15_ADJ !== rand_num[5:3]) begin
        `nnc_error("ANA", $sformatf("D2A_GAIN_DDA_CH15_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_GAIN_DDA_CH15_ADJ, rand_num[5:3]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[1][11];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[1][11][6] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[1][11][6];
        if (`ANA_TOP.D2A_INADC_ADJ !== rand_num[0]) begin
        `nnc_error("ANA", $sformatf("D2A_INADC_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_INADC_ADJ, rand_num[0]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[1][11][6];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][4] = $random;                                      
        force `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][5] = $random;                                      
        #10000ns;
        rand_num = {`ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][5], `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][4]};
        if (`ANA_TOP.D2A_PGAEN !== rand_num[15:0]) begin
        `nnc_error("ANA", $sformatf("D2A_PGAEN :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_PGAEN, rand_num[15:0]))
        end
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][4];                                      
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][5];                                      
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][6] = $random;                                      
        force `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][7] = $random;                                      
        #10000ns;
        rand_num = {`ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][7], `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][6]};
        if (`ANA_TOP.D2A_PGA_ENCH !== rand_num[15:0]) begin
        `nnc_error("ANA", $sformatf("D2A_PGA_ENCH :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_PGA_ENCH, rand_num[15:0]))
        end
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][6];                                      
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][7];                                      
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][8] = $random;                                      
        force `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][9] = $random;                                      
        #10000ns;
        rand_num = {`ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][9], `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][8]};
        if (`ANA_TOP.D2A_RLDEN_INA !== rand_num[15:0]) begin
        `nnc_error("ANA", $sformatf("D2A_RLDEN_INA :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_RLDEN_INA, rand_num[15:0]))
        end
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][8];                                      
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][9];                                      
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][10] = $random;                                      
        force `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][11] = $random;                                      
        #10000ns;
        rand_num = {`ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][11], `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][10]};
        if (`ANA_TOP.D2A_DDAEN !== rand_num[15:0]) begin
        `nnc_error("ANA", $sformatf("D2A_DDAEN :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_DDAEN, rand_num[15:0]))
        end
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][10];                                      
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][11];                                      
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][12] = $random;                                      
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][12];
        if (`ANA_TOP.D2A_EEG_EN !== rand_num[0]) begin
        `nnc_error("ANA", $sformatf("D2A_EEG_EN :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_EEG_EN, rand_num[0]))
        end
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][12];                                      
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[1][12] = $random;                                      
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[1][12];
        if (`ANA_TOP.D2A_PGA_IADJ !== rand_num[2:0]) begin
        `nnc_error("ANA", $sformatf("D2A_PGA_IADJ :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_PGA_IADJ, rand_num[2:0]))
        end
        if (`ANA_TOP.D2A_DDA_IADJ !== rand_num[5:3]) begin
        `nnc_error("ANA", $sformatf("D2A_DDA_IADJ :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_PGA_IADJ, rand_num[5:3]))
        end
        if (`ANA_TOP.D2A_VCM_INA_ADJ !== rand_num[6]) begin
        `nnc_error("ANA", $sformatf("D2A_VCM_INA_ADJ :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_PGA_IADJ, rand_num[6]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[1][12];                                      
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[2][0] = $random;                                      
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[2][0];
        if (`ANA_TOP.D2A_SDMVCMBUFF_ADJ !== rand_num[1:0]) begin
        `nnc_error("ANA", $sformatf("D2A_SDMVCMBUFF_ADJ :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_SDMVCMBUFF_ADJ, rand_num[1:0]))
        end
        if (`ANA_TOP.D2A_SDMVREFP_ADJ !== rand_num[3:2]) begin
        `nnc_error("ANA", $sformatf("D2A_SDMVREFP_ADJ :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_SDMVREFP_ADJ, rand_num[3:2]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[2][0];                                      
    end
    
    //-----------------------------STIMULATOR-------------------------------//    
    
    `nnc_info("SIMULATOR", "Start  testing Simulator", NNC_LOW)
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.i_out_wave_driver_idac[0] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.i_out_wave_driver_idac[0];
        if (`ANA_TOP.D2A_DATA_0 !== rand_num[12:0]) begin
        `nnc_error("ANA", $sformatf("D2A_DATA_0 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_DATA_0, rand_num[12:0]))
        end
        release `ANA_WRAPPER_TOP.i_out_wave_driver_idac[0];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.i_out_wave_driver_idac[1] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.i_out_wave_driver_idac[1];
        if (`ANA_TOP.D2A_DATA_1 !== rand_num[12:0]) begin
        `nnc_error("ANA", $sformatf("D2A_DATA_1 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_DATA_1, rand_num[12:0]))
        end
        release `ANA_WRAPPER_TOP.i_out_wave_driver_idac[1];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.i_out_wave_driver_idac[2] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.i_out_wave_driver_idac[2];
        if (`ANA_TOP.D2A_DATA_2 !== rand_num[12:0]) begin
        `nnc_error("ANA", $sformatf("D2A_DATA_2 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_DATA_2, rand_num[12:0]))
        end
        release `ANA_WRAPPER_TOP.i_out_wave_driver_idac[2];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.i_out_wave_driver_idac[3] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.i_out_wave_driver_idac[3];
        if (`ANA_TOP.D2A_DATA_3 !== rand_num[12:0]) begin
        `nnc_error("ANA", $sformatf("D2A_DATA_3 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_DATA_3, rand_num[12:0]))
        end
        release `ANA_WRAPPER_TOP.i_out_wave_driver_idac[3];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.i_out_wave_driver_idac[4] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.i_out_wave_driver_idac[4];
        if (`ANA_TOP.D2A_DATA_4 !== rand_num[12:0]) begin
        `nnc_error("ANA", $sformatf("D2A_DATA_4 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_DATA_4, rand_num[12:0]))
        end
        release `ANA_WRAPPER_TOP.i_out_wave_driver_idac[4];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.i_out_wave_driver_idac[5] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.i_out_wave_driver_idac[5];
        if (`ANA_TOP.D2A_DATA_5 !== rand_num[12:0]) begin
        `nnc_error("ANA", $sformatf("D2A_DATA_5 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_DATA_5, rand_num[12:0]))
        end
        release `ANA_WRAPPER_TOP.i_out_wave_driver_idac[5];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.i_out_wave_driver_idac[6] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.i_out_wave_driver_idac[6];
        if (`ANA_TOP.D2A_DATA_6 !== rand_num[12:0]) begin
        `nnc_error("ANA", $sformatf("D2A_DATA_6 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_DATA_6, rand_num[12:0]))
        end
        release `ANA_WRAPPER_TOP.i_out_wave_driver_idac[6];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.i_out_wave_driver_idac[7] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.i_out_wave_driver_idac[7];
        if (`ANA_TOP.D2A_DATA_7 !== rand_num[12:0]) begin
        `nnc_error("ANA", $sformatf("D2A_DATA_7 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_DATA_7, rand_num[12:0]))
        end
        release `ANA_WRAPPER_TOP.i_out_wave_driver_idac[7];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.i_out_wave_driver_idac[8] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.i_out_wave_driver_idac[8];
        if (`ANA_TOP.D2A_DATA_8 !== rand_num[12:0]) begin
        `nnc_error("ANA", $sformatf("D2A_DATA_8 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_DATA_8, rand_num[12:0]))
        end
        release `ANA_WRAPPER_TOP.i_out_wave_driver_idac[8];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.i_out_wave_driver_idac[9] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.i_out_wave_driver_idac[9];
        if (`ANA_TOP.D2A_DATA_9 !== rand_num[12:0]) begin
        `nnc_error("ANA", $sformatf("D2A_DATA_9 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_DATA_9, rand_num[12:0]))
        end
        release `ANA_WRAPPER_TOP.i_out_wave_driver_idac[9];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.i_out_wave_driver_idac[10] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.i_out_wave_driver_idac[10];
        if (`ANA_TOP.D2A_DATA_10 !== rand_num[12:0]) begin
        `nnc_error("ANA", $sformatf("D2A_DATA_10 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_DATA_10, rand_num[12:0]))
        end
        release `ANA_WRAPPER_TOP.i_out_wave_driver_idac[10];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.i_out_wave_driver_idac[11] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.i_out_wave_driver_idac[11];
        if (`ANA_TOP.D2A_DATA_11 !== rand_num[12:0]) begin
        `nnc_error("ANA", $sformatf("D2A_DATA_11 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_DATA_11, rand_num[12:0]))
        end
        release `ANA_WRAPPER_TOP.i_out_wave_driver_idac[11];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.i_out_wave_driver_idac[12] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.i_out_wave_driver_idac[12];
        if (`ANA_TOP.D2A_DATA_12 !== rand_num[12:0]) begin
        `nnc_error("ANA", $sformatf("D2A_DATA_12 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_DATA_12, rand_num[12:0]))
        end
        release `ANA_WRAPPER_TOP.i_out_wave_driver_idac[12];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.i_out_wave_driver_idac[13] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.i_out_wave_driver_idac[13];
        if (`ANA_TOP.D2A_DATA_13 !== rand_num[12:0]) begin
        `nnc_error("ANA", $sformatf("D2A_DATA_13 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_DATA_13, rand_num[12:0]))
        end
        release `ANA_WRAPPER_TOP.i_out_wave_driver_idac[13];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.i_out_wave_driver_idac[14] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.i_out_wave_driver_idac[14];
        if (`ANA_TOP.D2A_DATA_14 !== rand_num[12:0]) begin
        `nnc_error("ANA", $sformatf("D2A_DATA_14 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_DATA_14, rand_num[12:0]))
        end
        release `ANA_WRAPPER_TOP.i_out_wave_driver_idac[14];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.i_out_wave_driver_idac[15] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.i_out_wave_driver_idac[15];
        if (`ANA_TOP.D2A_DATA_15 !== rand_num[12:0]) begin
        `nnc_error("ANA", $sformatf("D2A_DATA_15 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_DATA_15, rand_num[12:0]))
        end
        release `ANA_WRAPPER_TOP.i_out_wave_driver_idac[15];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.i_driver_en_sw = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.i_driver_en_sw;
        if (`ANA_TOP.D2A_CBUF_EN !== rand_num[15:0]) begin
        `nnc_error("ANA", $sformatf("D2A_CBUF_EN :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_CBUF_EN, rand_num[15:0]))
        end
        release `ANA_WRAPPER_TOP.i_driver_en_sw;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.i_ds_driver_en_driver = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.i_ds_driver_en_driver;
        if (`ANA_TOP.D2A_IDAC_EN !== rand_num[15:0]) begin
        `nnc_error("ANA", $sformatf("D2A_IDAC_EN :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_IDAC_EN, rand_num[15:0]))
        end
        release `ANA_WRAPPER_TOP.i_ds_driver_en_driver;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.pinmux_if.i_ds_driver_en_current = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.pinmux_if.i_ds_driver_en_current;
        if (`ANA_TOP.D2A_DRIVER_CUR_EN !== rand_num) begin
        `nnc_error("ANA", $sformatf("D2A_DRIVER_CUR_EN :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_DRIVER_CUR_EN, rand_num))
        end
        release `ANA_WRAPPER_TOP.pinmux_if.i_ds_driver_en_current;
    end
   
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_TRIM6_SIG = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_TRIM6_SIG;
        if (`ANA_TOP.D2A_DRIVER_CUR_TRIM !== rand_num[7:0]) begin
        `nnc_error("ANA", $sformatf("D2A_DRIVER_CUR_TRIM :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_DRIVER_CUR_TRIM, rand_num[7:0]))
        end
        release `ANA_WRAPPER_TOP.D2A_TRIM6_SIG;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.i_pulldn_driver = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.i_pulldn_driver;
        if (`ANA_TOP.D2A_PULLD !== rand_num[15:0]) begin
        `nnc_error("ANA", $sformatf("D2A_PULLD :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_PULLD, rand_num[15:0]))
        end
        release `ANA_WRAPPER_TOP.i_pulldn_driver;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.i_source_driver = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.i_source_driver;
        if (`ANA_TOP.D2A_SOURCE !== rand_num[15:0]) begin
        `nnc_error("ANA", $sformatf("D2A_SOURCE :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_SOURCE, rand_num[15:0]))
        end
        release `ANA_WRAPPER_TOP.i_source_driver;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.pinmux_if.i_stimu_en = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.pinmux_if.i_stimu_en;
        if (`ANA_TOP.D2A_STIMU_EN !== rand_num[15:0]) begin
        `nnc_error("ANA", $sformatf("D2A_STIMU_EN :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_STIMU_EN, rand_num[15:0]))
        end
        release `ANA_WRAPPER_TOP.pinmux_if.i_stimu_en;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_ADBUF_GSEL = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_ADBUF_GSEL;
        if (`ANA_TOP.D2A_ADBUF_GSEL !== rand_num[1:0]) begin
        `nnc_error("ANA", $sformatf("D2A_ADBUF_GSEL :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_ADBUF_GSEL, rand_num[1:0]))
        end
        release `ANA_WRAPPER_TOP.D2A_ADBUF_GSEL;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_ADC_CLK = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_ADC_CLK;
        if (`ANA_TOP.D2A_ADC_CLK !== rand_num[0]) begin
        `nnc_error("ANA", $sformatf("D2A_ADC_CLK :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_ADC_CLK, rand_num[0]))
        end
        release `ANA_WRAPPER_TOP.D2A_ADC_CLK;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_ADC_DELAY = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_ADC_DELAY;
        if (`ANA_TOP.D2A_ADC_DELAY !== rand_num[3:0]) begin
        `nnc_error("ANA", $sformatf("D2A_ADC_DELAY :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_ADC_DELAY, rand_num[3:0]))
        end
        release `ANA_WRAPPER_TOP.D2A_ADC_DELAY;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_ADC_EN = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_ADC_EN;
        if (`ANA_TOP.D2A_ADC_EN !== rand_num[0]) begin
        `nnc_error("ANA", $sformatf("D2A_ADC_EN :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_ADC_EN, rand_num[0]))
        end
        release `ANA_WRAPPER_TOP.D2A_ADC_EN;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_STIM_PAD0 = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_STIM_PAD0;
        if (`ANA_TOP.D2A_STIM_PAD0 !== rand_num[3:0]) begin
        `nnc_error("ANA", $sformatf("D2A_STIM_PAD0 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_STIM_PAD0, rand_num[3:0]))
        end
        release `ANA_WRAPPER_TOP.D2A_STIM_PAD0;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_STIM_PAD1 = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_STIM_PAD1;
        if (`ANA_TOP.D2A_STIM_PAD1 !== rand_num[3:0]) begin
        `nnc_error("ANA", $sformatf("D2A_STIM_PAD1 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_STIM_PAD1, rand_num[3:0]))
        end
        release `ANA_WRAPPER_TOP.D2A_STIM_PAD1;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_TOP.A2D_ADC_DATA = $random;
        #10000ns;
        rand_num = `ANA_TOP.A2D_ADC_DATA;
        if (`ANA_WRAPPER_TOP.A2D_ADC_DATA !== rand_num[9:0]) begin
        `nnc_error("ANA", $sformatf("D2A_ADBUF_GSEL :%b is not as expectation of rand_num : %b",`ANA_WRAPPER_TOP.A2D_ADC_DATA, rand_num[9:0]))
        end
        release `ANA_TOP.A2D_ADC_DATA;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.A2D_ADC_DATA_EN = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.A2D_ADC_DATA_EN;
        if (`ANA_TOP.A2D_ADC_DATA_EN !== rand_num[0]) begin
        `nnc_error("ANA", $sformatf("A2D_ADC_DATA_EN :%b is not as expectation of rand_num : %b",`ANA_TOP.A2D_ADC_DATA_EN, rand_num[0]))
        end
        release `ANA_WRAPPER_TOP.A2D_ADC_DATA_EN;
    end
    
    //-----------------------------NIRS-------------------------------//    
    `nnc_info("NIRS", "Start  testing Nirs", NNC_LOW)
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_PDBIAS_EN = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_PDBIAS_EN;
        if (`ANA_TOP.D2A_PDBIAS_EN !== rand_num[0]) begin
        `nnc_error("ANA", $sformatf("D2A_PDBIAS_EN :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_PDBIAS_EN, rand_num[0]))
        end
        release `ANA_WRAPPER_TOP.D2A_PDBIAS_EN;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_PDBIAS_ADJ = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_PDBIAS_ADJ;
        if (`ANA_TOP.D2A_PDBIAS_ADJ !== rand_num[1:0]) begin
        `nnc_error("ANA", $sformatf("D2A_PDBIAS_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_PDBIAS_ADJ, rand_num[1:0]))
        end
        release `ANA_WRAPPER_TOP.D2A_PDBIAS_ADJ;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_CLK_NIRS = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_CLK_NIRS;
        if (`ANA_TOP.D2A_CLK_NIRS !== rand_num[0]) begin
        `nnc_error("ANA", $sformatf("D2A_CLK_NIRS :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_CLK_NIRS, rand_num[0]))
        end
        release `ANA_WRAPPER_TOP.D2A_CLK_NIRS;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_NIRS_CHOPPER_EN = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_NIRS_CHOPPER_EN;
        if (`ANA_TOP.D2A_NIRS_CHOPPER_EN !== rand_num[0]) begin
        `nnc_error("ANA", $sformatf("D2A_NIRS_CHOPPER_EN :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS_CHOPPER_EN, rand_num[0]))
        end
        release `ANA_WRAPPER_TOP.D2A_NIRS_CHOPPER_EN;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_NIRS_FCHOP_ADJ = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_NIRS_FCHOP_ADJ;
        if (`ANA_TOP.D2A_NIRS_FCHOP_ADJ !== rand_num[1:0]) begin
        `nnc_error("ANA", $sformatf("D2A_NIRS_FCHOP_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS_FCHOP_ADJ, rand_num[1:0]))
        end
        release `ANA_WRAPPER_TOP.D2A_NIRS_FCHOP_ADJ;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_NIRS_TEST_EN = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_NIRS_TEST_EN;
        if (`ANA_TOP.D2A_NIRS_TEST_EN !== rand_num[0]) begin
        `nnc_error("ANA", $sformatf("D2A_NIRS_TEST_EN :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS_TEST_EN, rand_num[0]))
        end
        release `ANA_WRAPPER_TOP.D2A_NIRS_TEST_EN;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_NIRS_POWER_EN = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_NIRS_POWER_EN;
        if (`ANA_TOP.D2A_NIRS_POWER_EN !== rand_num[0]) begin
        `nnc_error("ANA", $sformatf("D2A_NIRS_POWER_EN :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS_POWER_EN, rand_num[0]))
        end
        release `ANA_WRAPPER_TOP.D2A_NIRS_POWER_EN;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_NIRS_EN[0] = $random;
        force `ANA_WRAPPER_TOP.D2A_NIRS_EN[1] = $random;
        force `ANA_WRAPPER_TOP.D2A_NIRS_EN[2] = $random;
        force `ANA_WRAPPER_TOP.D2A_NIRS_EN[3] = $random;
        force `ANA_WRAPPER_TOP.D2A_NIRS_EN[4] = $random;
        force `ANA_WRAPPER_TOP.D2A_NIRS_EN[5] = $random;
        force `ANA_WRAPPER_TOP.D2A_NIRS_EN[6] = $random;
        force `ANA_WRAPPER_TOP.D2A_NIRS_EN[7] = $random;
        #10000ns;
        rand_num = {`ANA_WRAPPER_TOP.D2A_NIRS_EN[7],`ANA_WRAPPER_TOP.D2A_NIRS_EN[6],`ANA_WRAPPER_TOP.D2A_NIRS_EN[5],`ANA_WRAPPER_TOP.D2A_NIRS_EN[4],`ANA_WRAPPER_TOP.D2A_NIRS_EN[3],`ANA_WRAPPER_TOP.D2A_NIRS_EN[2],`ANA_WRAPPER_TOP.D2A_NIRS_EN[1],`ANA_WRAPPER_TOP.D2A_NIRS_EN[0]};
        
        if (`ANA_TOP.D2A_NIRS0_EN !== rand_num[0]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS0_EN :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS0_EN, rand_num[0]))
        end
        if (`ANA_TOP.D2A_NIRS1_EN !== rand_num[1]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS1_EN :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS1_EN, rand_num[1]))
        end
        if (`ANA_TOP.D2A_NIRS2_EN !== rand_num[2]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS2_EN :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS2_EN, rand_num[2]))
        end
        if (`ANA_TOP.D2A_NIRS3_EN !== rand_num[3]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS3_EN :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS3_EN, rand_num[3]))
        end
        if (`ANA_TOP.D2A_NIRS4_EN !== rand_num[4]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS4_EN :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS4_EN, rand_num[4]))
        end
        if (`ANA_TOP.D2A_NIRS5_EN !== rand_num[5]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS5_EN :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS5_EN, rand_num[5]))
        end
        if (`ANA_TOP.D2A_NIRS6_EN !== rand_num[6]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS6_EN :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS6_EN, rand_num[6]))
        end
        if (`ANA_TOP.D2A_NIRS7_EN !== rand_num[7]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS7_EN :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS7_EN, rand_num[7]))
        end
    
        release `ANA_WRAPPER_TOP.D2A_NIRS_EN;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_NIRS_IDAC_EN[0] = $random;
        force `ANA_WRAPPER_TOP.D2A_NIRS_IDAC_EN[1] = $random;
        force `ANA_WRAPPER_TOP.D2A_NIRS_IDAC_EN[2] = $random;
        force `ANA_WRAPPER_TOP.D2A_NIRS_IDAC_EN[3] = $random;
        force `ANA_WRAPPER_TOP.D2A_NIRS_IDAC_EN[4] = $random;
        force `ANA_WRAPPER_TOP.D2A_NIRS_IDAC_EN[5] = $random;
        force `ANA_WRAPPER_TOP.D2A_NIRS_IDAC_EN[6] = $random;
        force `ANA_WRAPPER_TOP.D2A_NIRS_IDAC_EN[7] = $random;
        #10000ns;
        rand_num = {`ANA_WRAPPER_TOP.D2A_NIRS_IDAC_EN[7],`ANA_WRAPPER_TOP.D2A_NIRS_IDAC_EN[6],`ANA_WRAPPER_TOP.D2A_NIRS_IDAC_EN[5],`ANA_WRAPPER_TOP.D2A_NIRS_IDAC_EN[4],`ANA_WRAPPER_TOP.D2A_NIRS_IDAC_EN[3],`ANA_WRAPPER_TOP.D2A_NIRS_IDAC_EN[2],`ANA_WRAPPER_TOP.D2A_NIRS_IDAC_EN[1],`ANA_WRAPPER_TOP.D2A_NIRS_IDAC_EN[0]};
        
        if (`ANA_TOP.D2A_NIRS0_IDAC_EN !== rand_num[0]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS0_IDAC_EN :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS0_IDAC_EN, rand_num[0]))
        end
        if (`ANA_TOP.D2A_NIRS1_IDAC_EN !== rand_num[1]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS1_IDAC_EN :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS1_IDAC_EN, rand_num[1]))
        end
        if (`ANA_TOP.D2A_NIRS2_IDAC_EN !== rand_num[2]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS2_IDAC_EN :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS2_IDAC_EN, rand_num[2]))
        end
        if (`ANA_TOP.D2A_NIRS3_IDAC_EN !== rand_num[3]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS3_IDAC_EN :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS3_IDAC_EN, rand_num[3]))
        end
        if (`ANA_TOP.D2A_NIRS4_IDAC_EN !== rand_num[4]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS4_IDAC_EN :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS4_IDAC_EN, rand_num[4]))
        end
        if (`ANA_TOP.D2A_NIRS5_IDAC_EN !== rand_num[5]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS5_IDAC_EN :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS5_IDAC_EN, rand_num[5]))
        end
        if (`ANA_TOP.D2A_NIRS6_IDAC_EN !== rand_num[6]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS6_IDAC_EN :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS6_IDAC_EN, rand_num[6]))
        end
        if (`ANA_TOP.D2A_NIRS7_IDAC_EN !== rand_num[7]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS7_IDAC_EN :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS7_IDAC_EN, rand_num[7]))
        end
    
        release `ANA_WRAPPER_TOP.D2A_NIRS_IDAC_EN;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_NIRS_RESET_SW[0] = $random;
        force `ANA_WRAPPER_TOP.D2A_NIRS_RESET_SW[1] = $random;
        force `ANA_WRAPPER_TOP.D2A_NIRS_RESET_SW[2] = $random;
        force `ANA_WRAPPER_TOP.D2A_NIRS_RESET_SW[3] = $random;
        force `ANA_WRAPPER_TOP.D2A_NIRS_RESET_SW[4] = $random;
        force `ANA_WRAPPER_TOP.D2A_NIRS_RESET_SW[5] = $random;
        force `ANA_WRAPPER_TOP.D2A_NIRS_RESET_SW[6] = $random;
        force `ANA_WRAPPER_TOP.D2A_NIRS_RESET_SW[7] = $random;
        #10000ns;
        rand_num = {`ANA_WRAPPER_TOP.D2A_NIRS_RESET_SW[7],`ANA_WRAPPER_TOP.D2A_NIRS_RESET_SW[6],`ANA_WRAPPER_TOP.D2A_NIRS_RESET_SW[5],`ANA_WRAPPER_TOP.D2A_NIRS_RESET_SW[4],`ANA_WRAPPER_TOP.D2A_NIRS_RESET_SW[3],`ANA_WRAPPER_TOP.D2A_NIRS_RESET_SW[2],`ANA_WRAPPER_TOP.D2A_NIRS_RESET_SW[1],`ANA_WRAPPER_TOP.D2A_NIRS_RESET_SW[0]};
        
        if (`ANA_TOP.D2A_NIRS0_RESET_SW !== rand_num[0]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS0_RESET_SW :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS0_RESET_SW, rand_num[0]))
        end
        if (`ANA_TOP.D2A_NIRS1_RESET_SW !== rand_num[1]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS1_RESET_SW :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS1_RESET_SW, rand_num[1]))
        end
        if (`ANA_TOP.D2A_NIRS2_RESET_SW !== rand_num[2]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS2_RESET_SW :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS2_RESET_SW, rand_num[2]))
        end
        if (`ANA_TOP.D2A_NIRS3_RESET_SW !== rand_num[3]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS3_RESET_SW :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS3_RESET_SW, rand_num[3]))
        end
        if (`ANA_TOP.D2A_NIRS4_RESET_SW !== rand_num[4]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS4_RESET_SW :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS4_RESET_SW, rand_num[4]))
        end
        if (`ANA_TOP.D2A_NIRS5_RESET_SW !== rand_num[5]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS5_RESET_SW :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS5_RESET_SW, rand_num[5]))
        end
        if (`ANA_TOP.D2A_NIRS6_RESET_SW !== rand_num[6]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS6_RESET_SW :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS6_RESET_SW, rand_num[6]))
        end
        if (`ANA_TOP.D2A_NIRS7_RESET_SW !== rand_num[7]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS7_RESET_SW :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS7_RESET_SW, rand_num[7]))
        end
    
        release `ANA_WRAPPER_TOP.D2A_NIRS_RESET_SW[7:0];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_NIRS_IPD_SW[0] = $random;
        force `ANA_WRAPPER_TOP.D2A_NIRS_IPD_SW[1] = $random;
        force `ANA_WRAPPER_TOP.D2A_NIRS_IPD_SW[2] = $random;
        force `ANA_WRAPPER_TOP.D2A_NIRS_IPD_SW[3] = $random;
        force `ANA_WRAPPER_TOP.D2A_NIRS_IPD_SW[4] = $random;
        force `ANA_WRAPPER_TOP.D2A_NIRS_IPD_SW[5] = $random;
        force `ANA_WRAPPER_TOP.D2A_NIRS_IPD_SW[6] = $random;
        force `ANA_WRAPPER_TOP.D2A_NIRS_IPD_SW[7] = $random;
        #10000ns;
        rand_num = {`ANA_WRAPPER_TOP.D2A_NIRS_IPD_SW[7],`ANA_WRAPPER_TOP.D2A_NIRS_IPD_SW[6],`ANA_WRAPPER_TOP.D2A_NIRS_IPD_SW[5],`ANA_WRAPPER_TOP.D2A_NIRS_IPD_SW[4],`ANA_WRAPPER_TOP.D2A_NIRS_IPD_SW[3],`ANA_WRAPPER_TOP.D2A_NIRS_IPD_SW[2],`ANA_WRAPPER_TOP.D2A_NIRS_IPD_SW[1],`ANA_WRAPPER_TOP.D2A_NIRS_IPD_SW[0]};
        
        if (`ANA_TOP.D2A_NIRS0_IPD_SW !== rand_num[0]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS0_IPD_SW :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS0_IPD_SW, rand_num[0]))
        end
        if (`ANA_TOP.D2A_NIRS1_IPD_SW !== rand_num[1]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS1_IPD_SW :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS1_IPD_SW, rand_num[1]))
        end
        if (`ANA_TOP.D2A_NIRS2_IPD_SW !== rand_num[2]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS2_IPD_SW :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS2_IPD_SW, rand_num[2]))
        end
        if (`ANA_TOP.D2A_NIRS3_IPD_SW !== rand_num[3]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS3_IPD_SW :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS3_IPD_SW, rand_num[3]))
        end
        if (`ANA_TOP.D2A_NIRS4_IPD_SW !== rand_num[4]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS4_IPD_SW :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS4_IPD_SW, rand_num[4]))
        end
        if (`ANA_TOP.D2A_NIRS5_IPD_SW !== rand_num[5]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS5_IPD_SW :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS5_IPD_SW, rand_num[5]))
        end
        if (`ANA_TOP.D2A_NIRS6_IPD_SW !== rand_num[6]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS6_IPD_SW :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS6_IPD_SW, rand_num[6]))
        end
        if (`ANA_TOP.D2A_NIRS7_IPD_SW !== rand_num[7]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS7_IPD_SW :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS7_IPD_SW, rand_num[7]))
        end
    
        release `ANA_WRAPPER_TOP.D2A_NIRS_IPD_SW[7:0];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_NIRS_IIN_SW[0] = $random;
        force `ANA_WRAPPER_TOP.D2A_NIRS_IIN_SW[1] = $random;
        force `ANA_WRAPPER_TOP.D2A_NIRS_IIN_SW[2] = $random;
        force `ANA_WRAPPER_TOP.D2A_NIRS_IIN_SW[3] = $random;
        force `ANA_WRAPPER_TOP.D2A_NIRS_IIN_SW[4] = $random;
        force `ANA_WRAPPER_TOP.D2A_NIRS_IIN_SW[5] = $random;
        force `ANA_WRAPPER_TOP.D2A_NIRS_IIN_SW[6] = $random;
        force `ANA_WRAPPER_TOP.D2A_NIRS_IIN_SW[7] = $random;
        #10000ns;
        rand_num = {`ANA_WRAPPER_TOP.D2A_NIRS_IIN_SW[7],`ANA_WRAPPER_TOP.D2A_NIRS_IIN_SW[6],`ANA_WRAPPER_TOP.D2A_NIRS_IIN_SW[5],`ANA_WRAPPER_TOP.D2A_NIRS_IIN_SW[4],`ANA_WRAPPER_TOP.D2A_NIRS_IIN_SW[3],`ANA_WRAPPER_TOP.D2A_NIRS_IIN_SW[2],`ANA_WRAPPER_TOP.D2A_NIRS_IIN_SW[1],`ANA_WRAPPER_TOP.D2A_NIRS_IIN_SW[0]};
        
        if (`ANA_TOP.D2A_NIRS0_IIN_SW !== rand_num[0]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS0_IIN_SW :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS0_IIN_SW, rand_num[0]))
        end
        if (`ANA_TOP.D2A_NIRS1_IIN_SW !== rand_num[1]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS1_IIN_SW :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS1_IIN_SW, rand_num[1]))
        end
        if (`ANA_TOP.D2A_NIRS2_IIN_SW !== rand_num[2]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS2_IIN_SW :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS2_IIN_SW, rand_num[2]))
        end
        if (`ANA_TOP.D2A_NIRS3_IIN_SW !== rand_num[3]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS3_IIN_SW :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS3_IIN_SW, rand_num[3]))
        end
        if (`ANA_TOP.D2A_NIRS4_IIN_SW !== rand_num[4]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS4_IIN_SW :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS4_IIN_SW, rand_num[4]))
        end
        if (`ANA_TOP.D2A_NIRS5_IIN_SW !== rand_num[5]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS5_IIN_SW :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS5_IIN_SW, rand_num[5]))
        end
        if (`ANA_TOP.D2A_NIRS6_IIN_SW !== rand_num[6]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS6_IIN_SW :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS6_IIN_SW, rand_num[6]))
        end
        if (`ANA_TOP.D2A_NIRS7_IIN_SW !== rand_num[7]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS7_IIN_SW :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS7_IIN_SW, rand_num[7]))
        end
    
        release `ANA_WRAPPER_TOP.D2A_NIRS_IIN_SW[7:0];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_NIRS_IPDMIRROR_ADJ[0][1:0] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_NIRS_IPDMIRROR_ADJ[0][1:0];
        if (`ANA_TOP.D2A_NIRS0_IPDMIRROR_ADJ !== rand_num[1:0]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS0_IPDMIRROR_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS0_IPDMIRROR_ADJ, rand_num[0]))
        end
        
        force `ANA_WRAPPER_TOP.D2A_NIRS_IPDMIRROR_ADJ[1][1:0] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_NIRS_IPDMIRROR_ADJ[1][1:0];
        if (`ANA_TOP.D2A_NIRS1_IPDMIRROR_ADJ !== rand_num[1:0]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS1_IPDMIRROR_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS1_IPDMIRROR_ADJ, rand_num[1]))
        end
        
        force `ANA_WRAPPER_TOP.D2A_NIRS_IPDMIRROR_ADJ[2][1:0] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_NIRS_IPDMIRROR_ADJ[2][1:0];
        if (`ANA_TOP.D2A_NIRS2_IPDMIRROR_ADJ !== rand_num[1:0]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS2_IPDMIRROR_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS2_IPDMIRROR_ADJ, rand_num[2]))
        end
        
        force `ANA_WRAPPER_TOP.D2A_NIRS_IPDMIRROR_ADJ[3][1:0] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_NIRS_IPDMIRROR_ADJ[3][1:0];
        if (`ANA_TOP.D2A_NIRS3_IPDMIRROR_ADJ !== rand_num[1:0]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS3_IPDMIRROR_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS3_IPDMIRROR_ADJ, rand_num[3]))
        end
        
        force `ANA_WRAPPER_TOP.D2A_NIRS_IPDMIRROR_ADJ[4][1:0] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_NIRS_IPDMIRROR_ADJ[4][1:0];
        if (`ANA_TOP.D2A_NIRS4_IPDMIRROR_ADJ !== rand_num[1:0]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS4_IPDMIRROR_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS4_IPDMIRROR_ADJ, rand_num[4]))
        end
        
        force `ANA_WRAPPER_TOP.D2A_NIRS_IPDMIRROR_ADJ[5][1:0] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_NIRS_IPDMIRROR_ADJ[5][1:0];
        if (`ANA_TOP.D2A_NIRS5_IPDMIRROR_ADJ !== rand_num[1:0]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS5_IPDMIRROR_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS5_IPDMIRROR_ADJ, rand_num[5]))
        end
        
        force `ANA_WRAPPER_TOP.D2A_NIRS_IPDMIRROR_ADJ[6][1:0] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_NIRS_IPDMIRROR_ADJ[6][1:0];
        if (`ANA_TOP.D2A_NIRS6_IPDMIRROR_ADJ !== rand_num[1:0]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS6_IPDMIRROR_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS6_IPDMIRROR_ADJ, rand_num[6]))
        end
        
        force `ANA_WRAPPER_TOP.D2A_NIRS_IPDMIRROR_ADJ[7][1:0] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_NIRS_IPDMIRROR_ADJ[7][1:0];
        if (`ANA_TOP.D2A_NIRS7_IPDMIRROR_ADJ !== rand_num[1:0]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS7_IPDMIRROR_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS7_IPDMIRROR_ADJ, rand_num[7]))
        end
    
        release `ANA_WRAPPER_TOP.D2A_NIRS_IPDMIRROR_ADJ[0][1:0];
        release `ANA_WRAPPER_TOP.D2A_NIRS_IPDMIRROR_ADJ[1][1:0];
        release `ANA_WRAPPER_TOP.D2A_NIRS_IPDMIRROR_ADJ[2][1:0];
        release `ANA_WRAPPER_TOP.D2A_NIRS_IPDMIRROR_ADJ[3][1:0];
        release `ANA_WRAPPER_TOP.D2A_NIRS_IPDMIRROR_ADJ[4][1:0];
        release `ANA_WRAPPER_TOP.D2A_NIRS_IPDMIRROR_ADJ[5][1:0];
        release `ANA_WRAPPER_TOP.D2A_NIRS_IPDMIRROR_ADJ[6][1:0];
        release `ANA_WRAPPER_TOP.D2A_NIRS_IPDMIRROR_ADJ[7][1:0];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_NIRS_IREFC_ADJ[0][1:0] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_NIRS_IREFC_ADJ[0][1:0];
        
        if (`ANA_TOP.D2A_NIRS0_IREFC_ADJ !== rand_num[1:0]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS0_IREFC_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS0_IREFC_ADJ, rand_num[0]))
        end
        
        force `ANA_WRAPPER_TOP.D2A_NIRS_IREFC_ADJ[1][1:0] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_NIRS_IREFC_ADJ[1][1:0];
        if (`ANA_TOP.D2A_NIRS1_IREFC_ADJ !== rand_num[1:0]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS1_IREFC_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS1_IREFC_ADJ, rand_num[1]))
        end
        
        force `ANA_WRAPPER_TOP.D2A_NIRS_IREFC_ADJ[2][1:0] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_NIRS_IREFC_ADJ[2][1:0];
        if (`ANA_TOP.D2A_NIRS2_IREFC_ADJ !== rand_num[1:0]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS2_IREFC_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS2_IREFC_ADJ, rand_num[2]))
        end
        
        force `ANA_WRAPPER_TOP.D2A_NIRS_IREFC_ADJ[3][1:0] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_NIRS_IREFC_ADJ[3][1:0];
        if (`ANA_TOP.D2A_NIRS3_IREFC_ADJ !== rand_num[1:0]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS3_IREFC_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS3_IREFC_ADJ, rand_num[3]))
        end
        
        force `ANA_WRAPPER_TOP.D2A_NIRS_IREFC_ADJ[4][1:0] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_NIRS_IREFC_ADJ[4][1:0];
        if (`ANA_TOP.D2A_NIRS4_IREFC_ADJ !== rand_num[1:0]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS4_IREFC_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS4_IREFC_ADJ, rand_num[4]))
        end
        
        force `ANA_WRAPPER_TOP.D2A_NIRS_IREFC_ADJ[5][1:0] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_NIRS_IREFC_ADJ[5][1:0];
        if (`ANA_TOP.D2A_NIRS5_IREFC_ADJ !== rand_num[1:0]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS5_IREFC_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS5_IREFC_ADJ, rand_num[5]))
        end
        
        force `ANA_WRAPPER_TOP.D2A_NIRS_IREFC_ADJ[6][1:0] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_NIRS_IREFC_ADJ[6][1:0];
        if (`ANA_TOP.D2A_NIRS6_IREFC_ADJ !== rand_num[1:0]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS6_IREFC_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS6_IREFC_ADJ, rand_num[6]))
        end
        
        force `ANA_WRAPPER_TOP.D2A_NIRS_IREFC_ADJ[7][1:0] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_NIRS_IREFC_ADJ[7][1:0];
        if (`ANA_TOP.D2A_NIRS7_IREFC_ADJ !== rand_num[1:0]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS7_IREFC_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS7_IREFC_ADJ, rand_num[7]))
        end
    
        release `ANA_WRAPPER_TOP.D2A_NIRS_IREFC_ADJ[0][1:0];
        release `ANA_WRAPPER_TOP.D2A_NIRS_IREFC_ADJ[1][1:0];
        release `ANA_WRAPPER_TOP.D2A_NIRS_IREFC_ADJ[2][1:0];
        release `ANA_WRAPPER_TOP.D2A_NIRS_IREFC_ADJ[3][1:0];
        release `ANA_WRAPPER_TOP.D2A_NIRS_IREFC_ADJ[4][1:0];
        release `ANA_WRAPPER_TOP.D2A_NIRS_IREFC_ADJ[5][1:0];
        release `ANA_WRAPPER_TOP.D2A_NIRS_IREFC_ADJ[6][1:0];
        release `ANA_WRAPPER_TOP.D2A_NIRS_IREFC_ADJ[7][1:0];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_NIRS_CFRATE_ADJ0[1:0] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_NIRS_CFRATE_ADJ0[1:0];
        if (`ANA_TOP.D2A_NIRS0_CFRATE_ADJ !== rand_num[1:0]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS0_CFRATE_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS0_CFRATE_ADJ, rand_num[0]))
        end
        force `ANA_WRAPPER_TOP.D2A_NIRS_CFRATE_ADJ1[1:0] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_NIRS_CFRATE_ADJ1[1:0];
        if (`ANA_TOP.D2A_NIRS1_CFRATE_ADJ !== rand_num[1:0]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS1_CFRATE_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS1_CFRATE_ADJ, rand_num[1]))
        end
        force `ANA_WRAPPER_TOP.D2A_NIRS_CFRATE_ADJ2[1:0] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_NIRS_CFRATE_ADJ2[1:0];
        if (`ANA_TOP.D2A_NIRS2_CFRATE_ADJ !== rand_num[1:0]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS2_CFRATE_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS2_CFRATE_ADJ, rand_num[2]))
        end
        force `ANA_WRAPPER_TOP.D2A_NIRS_CFRATE_ADJ3[1:0] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_NIRS_CFRATE_ADJ3[1:0];
        if (`ANA_TOP.D2A_NIRS3_CFRATE_ADJ !== rand_num[1:0]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS3_CFRATE_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS3_CFRATE_ADJ, rand_num[3]))
        end
        force `ANA_WRAPPER_TOP.D2A_NIRS_CFRATE_ADJ4[1:0] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_NIRS_CFRATE_ADJ4[1:0];
        if (`ANA_TOP.D2A_NIRS4_CFRATE_ADJ !== rand_num[1:0]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS4_CFRATE_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS4_CFRATE_ADJ, rand_num[4]))
        end
        force `ANA_WRAPPER_TOP.D2A_NIRS_CFRATE_ADJ5[1:0] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_NIRS_CFRATE_ADJ5[1:0];
        if (`ANA_TOP.D2A_NIRS5_CFRATE_ADJ !== rand_num[1:0]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS5_CFRATE_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS5_CFRATE_ADJ, rand_num[5]))
        end
        force `ANA_WRAPPER_TOP.D2A_NIRS_CFRATE_ADJ6[1:0] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_NIRS_CFRATE_ADJ6[1:0];
        if (`ANA_TOP.D2A_NIRS6_CFRATE_ADJ !== rand_num[1:0]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS6_CFRATE_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS6_CFRATE_ADJ, rand_num[6]))
        end
        force `ANA_WRAPPER_TOP.D2A_NIRS_CFRATE_ADJ7[1:0] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_NIRS_CFRATE_ADJ7[1:0];
        if (`ANA_TOP.D2A_NIRS7_CFRATE_ADJ !== rand_num[1:0]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS7_CFRATE_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS7_CFRATE_ADJ, rand_num[7]))
        end
    
        release `ANA_WRAPPER_TOP.D2A_NIRS_CFRATE_ADJ0[1:0];
        release `ANA_WRAPPER_TOP.D2A_NIRS_CFRATE_ADJ1[1:0];
        release `ANA_WRAPPER_TOP.D2A_NIRS_CFRATE_ADJ2[1:0];
        release `ANA_WRAPPER_TOP.D2A_NIRS_CFRATE_ADJ3[1:0];
        release `ANA_WRAPPER_TOP.D2A_NIRS_CFRATE_ADJ4[1:0];
        release `ANA_WRAPPER_TOP.D2A_NIRS_CFRATE_ADJ5[1:0];
        release `ANA_WRAPPER_TOP.D2A_NIRS_CFRATE_ADJ6[1:0];
        release `ANA_WRAPPER_TOP.D2A_NIRS_CFRATE_ADJ7[1:0];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_NIRS_IDAC_ADJ[0][8:0] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_NIRS_IDAC_ADJ[0][8:0];        
        if (`ANA_TOP.D2A_NIRS0_IDAC_ADJ !== rand_num[8:0]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS0_IDAC_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS0_IDAC_ADJ, rand_num[0]))
        end
        
        force `ANA_WRAPPER_TOP.D2A_NIRS_IDAC_ADJ[1][8:0] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_NIRS_IDAC_ADJ[1][8:0];
        if (`ANA_TOP.D2A_NIRS1_IDAC_ADJ !== rand_num[8:0]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS1_IDAC_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS1_IDAC_ADJ, rand_num[1]))
        end
        
        force `ANA_WRAPPER_TOP.D2A_NIRS_IDAC_ADJ[2][8:0] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_NIRS_IDAC_ADJ[2][8:0];
        if (`ANA_TOP.D2A_NIRS2_IDAC_ADJ !== rand_num[8:0]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS2_IDAC_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS2_IDAC_ADJ, rand_num[2]))
        end
        
        force `ANA_WRAPPER_TOP.D2A_NIRS_IDAC_ADJ[3][8:0] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_NIRS_IDAC_ADJ[3][8:0];
        if (`ANA_TOP.D2A_NIRS3_IDAC_ADJ !== rand_num[8:0]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS3_IDAC_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS3_IDAC_ADJ, rand_num[3]))
        end
        
        force `ANA_WRAPPER_TOP.D2A_NIRS_IDAC_ADJ[4][8:0] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_NIRS_IDAC_ADJ[4][8:0];
        if (`ANA_TOP.D2A_NIRS4_IDAC_ADJ !== rand_num[8:0]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS4_IDAC_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS4_IDAC_ADJ, rand_num[4]))
        end
        
        force `ANA_WRAPPER_TOP.D2A_NIRS_IDAC_ADJ[5][8:0] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_NIRS_IDAC_ADJ[5][8:0];
        if (`ANA_TOP.D2A_NIRS5_IDAC_ADJ !== rand_num[8:0]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS5_IDAC_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS5_IDAC_ADJ, rand_num[5]))
        end
        
        force `ANA_WRAPPER_TOP.D2A_NIRS_IDAC_ADJ[6][8:0] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_NIRS_IDAC_ADJ[6][8:0];
        if (`ANA_TOP.D2A_NIRS6_IDAC_ADJ !== rand_num[8:0]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS6_IDAC_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS6_IDAC_ADJ, rand_num[6]))
        end
        
        force `ANA_WRAPPER_TOP.D2A_NIRS_IDAC_ADJ[7][8:0] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_NIRS_IDAC_ADJ[7][8:0];
        if (`ANA_TOP.D2A_NIRS7_IDAC_ADJ !== rand_num[8:0]) begin
            `nnc_error("ANA", $sformatf("D2A_NIRS7_IDAC_ADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_NIRS7_IDAC_ADJ, rand_num[7]))
        end
    
        release `ANA_WRAPPER_TOP.D2A_NIRS_IDAC_ADJ[0][8:0];
        release `ANA_WRAPPER_TOP.D2A_NIRS_IDAC_ADJ[1][8:0];
        release `ANA_WRAPPER_TOP.D2A_NIRS_IDAC_ADJ[2][8:0];
        release `ANA_WRAPPER_TOP.D2A_NIRS_IDAC_ADJ[3][8:0];
        release `ANA_WRAPPER_TOP.D2A_NIRS_IDAC_ADJ[4][8:0];
        release `ANA_WRAPPER_TOP.D2A_NIRS_IDAC_ADJ[5][8:0];
        release `ANA_WRAPPER_TOP.D2A_NIRS_IDAC_ADJ[6][8:0];
        release `ANA_WRAPPER_TOP.D2A_NIRS_IDAC_ADJ[7][8:0];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.A2D_NIRS_IREFCOARSE[0] = $random;
        force `ANA_WRAPPER_TOP.A2D_NIRS_IREFCOARSE[1] = $random;
        force `ANA_WRAPPER_TOP.A2D_NIRS_IREFCOARSE[2] = $random;
        force `ANA_WRAPPER_TOP.A2D_NIRS_IREFCOARSE[3] = $random;
        force `ANA_WRAPPER_TOP.A2D_NIRS_IREFCOARSE[4] = $random;
        force `ANA_WRAPPER_TOP.A2D_NIRS_IREFCOARSE[5] = $random;
        force `ANA_WRAPPER_TOP.A2D_NIRS_IREFCOARSE[6] = $random;
        force `ANA_WRAPPER_TOP.A2D_NIRS_IREFCOARSE[7] = $random;
        #10000ns;
        rand_num = {`ANA_WRAPPER_TOP.A2D_NIRS_IREFCOARSE[7],`ANA_WRAPPER_TOP.A2D_NIRS_IREFCOARSE[6],`ANA_WRAPPER_TOP.A2D_NIRS_IREFCOARSE[5],`ANA_WRAPPER_TOP.A2D_NIRS_IREFCOARSE[4],`ANA_WRAPPER_TOP.A2D_NIRS_IREFCOARSE[3],`ANA_WRAPPER_TOP.A2D_NIRS_IREFCOARSE[2],`ANA_WRAPPER_TOP.A2D_NIRS_IREFCOARSE[1],`ANA_WRAPPER_TOP.A2D_NIRS_IREFCOARSE[0]};
        
        if (`ANA_TOP.A2D_NIRS0_IREFCOARSE !== rand_num[0]) begin
            `nnc_error("ANA", $sformatf("A2D_NIRS0_IREFCOARSE :%b is not as expectation of rand_num : %b",`ANA_TOP.A2D_NIRS0_IREFCOARSE, rand_num[0]))
        end
        if (`ANA_TOP.A2D_NIRS1_IREFCOARSE !== rand_num[1]) begin
            `nnc_error("ANA", $sformatf("A2D_NIRS1_IREFCOARSE :%b is not as expectation of rand_num : %b",`ANA_TOP.A2D_NIRS1_IREFCOARSE, rand_num[1]))
        end
        if (`ANA_TOP.A2D_NIRS2_IREFCOARSE !== rand_num[2]) begin
            `nnc_error("ANA", $sformatf("A2D_NIRS2_IREFCOARSE :%b is not as expectation of rand_num : %b",`ANA_TOP.A2D_NIRS2_IREFCOARSE, rand_num[2]))
        end
        if (`ANA_TOP.A2D_NIRS3_IREFCOARSE !== rand_num[3]) begin
            `nnc_error("ANA", $sformatf("A2D_NIRS3_IREFCOARSE :%b is not as expectation of rand_num : %b",`ANA_TOP.A2D_NIRS3_IREFCOARSE, rand_num[3]))
        end
        if (`ANA_TOP.A2D_NIRS4_IREFCOARSE !== rand_num[4]) begin
            `nnc_error("ANA", $sformatf("A2D_NIRS4_IREFCOARSE :%b is not as expectation of rand_num : %b",`ANA_TOP.A2D_NIRS4_IREFCOARSE, rand_num[4]))
        end
        if (`ANA_TOP.A2D_NIRS5_IREFCOARSE !== rand_num[5]) begin
            `nnc_error("ANA", $sformatf("A2D_NIRS5_IREFCOARSE :%b is not as expectation of rand_num : %b",`ANA_TOP.A2D_NIRS5_IREFCOARSE, rand_num[5]))
        end
        if (`ANA_TOP.A2D_NIRS6_IREFCOARSE !== rand_num[6]) begin
            `nnc_error("ANA", $sformatf("A2D_NIRS6_IREFCOARSE :%b is not as expectation of rand_num : %b",`ANA_TOP.A2D_NIRS6_IREFCOARSE, rand_num[6]))
        end
        if (`ANA_TOP.A2D_NIRS7_IREFCOARSE !== rand_num[7]) begin
            `nnc_error("ANA", $sformatf("A2D_NIRS7_IREFCOARSE :%b is not as expectation of rand_num : %b",`ANA_TOP.A2D_NIRS7_IREFCOARSE, rand_num[7]))
        end
    
        release `ANA_WRAPPER_TOP.A2D_NIRS_IREFCOARSE[7:0];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.A2D_NIRS_IREFFINE[0] = $random;
        force `ANA_WRAPPER_TOP.A2D_NIRS_IREFFINE[1] = $random;
        force `ANA_WRAPPER_TOP.A2D_NIRS_IREFFINE[2] = $random;
        force `ANA_WRAPPER_TOP.A2D_NIRS_IREFFINE[3] = $random;
        force `ANA_WRAPPER_TOP.A2D_NIRS_IREFFINE[4] = $random;
        force `ANA_WRAPPER_TOP.A2D_NIRS_IREFFINE[5] = $random;
        force `ANA_WRAPPER_TOP.A2D_NIRS_IREFFINE[6] = $random;
        force `ANA_WRAPPER_TOP.A2D_NIRS_IREFFINE[7 ] = $random;
        #10000ns;
        rand_num = {`ANA_WRAPPER_TOP.A2D_NIRS_IREFFINE[7],`ANA_WRAPPER_TOP.A2D_NIRS_IREFFINE[6],`ANA_WRAPPER_TOP.A2D_NIRS_IREFFINE[5],`ANA_WRAPPER_TOP.A2D_NIRS_IREFFINE[4],`ANA_WRAPPER_TOP.A2D_NIRS_IREFFINE[3],`ANA_WRAPPER_TOP.A2D_NIRS_IREFFINE[2],`ANA_WRAPPER_TOP.A2D_NIRS_IREFFINE[1],`ANA_WRAPPER_TOP.A2D_NIRS_IREFFINE[0]};
        
        if (`ANA_TOP.A2D_NIRS0_IREFFINE !== rand_num[0]) begin
            `nnc_error("ANA", $sformatf("A2D_NIRS0_IREFFINE :%b is not as expectation of rand_num : %b",`ANA_TOP.A2D_NIRS0_IREFFINE, rand_num[0]))
        end
        if (`ANA_TOP.A2D_NIRS1_IREFFINE !== rand_num[1]) begin
            `nnc_error("ANA", $sformatf("A2D_NIRS1_IREFFINE :%b is not as expectation of rand_num : %b",`ANA_TOP.A2D_NIRS1_IREFFINE, rand_num[1]))
        end
        if (`ANA_TOP.A2D_NIRS2_IREFFINE !== rand_num[2]) begin
            `nnc_error("ANA", $sformatf("A2D_NIRS2_IREFFINE :%b is not as expectation of rand_num : %b",`ANA_TOP.A2D_NIRS2_IREFFINE, rand_num[2]))
        end
        if (`ANA_TOP.A2D_NIRS3_IREFFINE !== rand_num[3]) begin
            `nnc_error("ANA", $sformatf("A2D_NIRS3_IREFFINE :%b is not as expectation of rand_num : %b",`ANA_TOP.A2D_NIRS3_IREFFINE, rand_num[3]))
        end
        if (`ANA_TOP.A2D_NIRS4_IREFFINE !== rand_num[4]) begin
            `nnc_error("ANA", $sformatf("A2D_NIRS4_IREFFINE :%b is not as expectation of rand_num : %b",`ANA_TOP.A2D_NIRS4_IREFFINE, rand_num[4]))
        end
        if (`ANA_TOP.A2D_NIRS5_IREFFINE !== rand_num[5]) begin
            `nnc_error("ANA", $sformatf("A2D_NIRS5_IREFFINE :%b is not as expectation of rand_num : %b",`ANA_TOP.A2D_NIRS5_IREFFINE, rand_num[5]))
        end
        if (`ANA_TOP.A2D_NIRS6_IREFFINE !== rand_num[6]) begin
            `nnc_error("ANA", $sformatf("A2D_NIRS6_IREFFINE :%b is not as expectation of rand_num : %b",`ANA_TOP.A2D_NIRS6_IREFFINE, rand_num[6]))
        end
        if (`ANA_TOP.A2D_NIRS7_IREFFINE !== rand_num[7]) begin
            `nnc_error("ANA", $sformatf("A2D_NIRS7_IREFFINE :%b is not as expectation of rand_num : %b",`ANA_TOP.A2D_NIRS7_IREFFINE, rand_num[7]))
        end
    
        release `ANA_WRAPPER_TOP.A2D_NIRS_IREFFINE;
    end

    //----------------------------SDM-------------------------------//       
    `nnc_info("SDM", "Start  testing SDM", NNC_LOW)
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][13]     = $random;
        force `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][14]     = $random;
        #10000ns;
        rand_num = {`ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][14],`ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][13]};
        if (`ANA_TOP.D2A_SDMEN !== rand_num[15:0]) begin
        `nnc_error("ANA", $sformatf("D2A_SDMEN :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_SDMEN, rand_num[15:0]))
        end
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][13];
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][14];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_SDM_CLK     = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_SDM_CLK;
        if (`ANA_TOP.D2A_SDMCLK !== rand_num[0]) begin
        `nnc_error("ANA", $sformatf("D2A_SDMCLK :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_SDMCLK, rand_num[0]))
        end
        release `ANA_WRAPPER_TOP.D2A_SDM_CLK;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][1]     = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][1];
        if (`ANA_TOP.D2A_SDM_TEST !== rand_num[2]) begin
        `nnc_error("ANA", $sformatf("D2A_SDM_TEST :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_SDM_TEST, rand_num[2]))
        end
        release `ANA_WRAPPER_TOP.D2A_SDM_CLK;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_TOP.A2D_SDM0     = $random;
        #10000ns;
        rand_num = `ANA_TOP.A2D_SDM0;
        if (`ANA_WRAPPER_TOP.A2D_SDM_OUT0 !== rand_num[0]) begin
        `nnc_error("ANA", $sformatf("A2D_SDM_OUT0 :%b is not as expectation of rand_num : %b",`ANA_WRAPPER_TOP.A2D_SDM_OUT0, rand_num[0]))
        end
        release `ANA_TOP.A2D_SDM0;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_TOP.A2D_SDM1     = $random;
        #10000ns;
        rand_num = `ANA_TOP.A2D_SDM1;
        if (`ANA_WRAPPER_TOP.A2D_SDM_OUT1 !== rand_num[0]) begin
        `nnc_error("ANA", $sformatf("A2D_SDM_OUT1 :%b is not as expectation of rand_num : %b",`ANA_WRAPPER_TOP.A2D_SDM_OUT1, rand_num[0]))
        end
        release `ANA_TOP.A2D_SDM1;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_TOP.A2D_SDM2     = $random;
        #10000ns;
        rand_num = `ANA_TOP.A2D_SDM2;
        if (`ANA_WRAPPER_TOP.A2D_SDM_OUT2 !== rand_num[0]) begin
        `nnc_error("ANA", $sformatf("A2D_SDM_OUT2 :%b is not as expectation of rand_num : %b",`ANA_WRAPPER_TOP.A2D_SDM_OUT2, rand_num[0]))
        end
        release `ANA_TOP.A2D_SDM2;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_TOP.A2D_SDM3     = $random;
        #10000ns;
        rand_num = `ANA_TOP.A2D_SDM3;
        if (`ANA_WRAPPER_TOP.A2D_SDM_OUT3 !== rand_num[0]) begin
        `nnc_error("ANA", $sformatf("A2D_SDM_OUT3 :%b is not as expectation of rand_num : %b",`ANA_WRAPPER_TOP.A2D_SDM_OUT3, rand_num[0]))
        end
        release `ANA_TOP.A2D_SDM3;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_TOP.A2D_SDM4     = $random;
        #10000ns;
        rand_num = `ANA_TOP.A2D_SDM4;
        if (`ANA_WRAPPER_TOP.A2D_SDM_OUT4 !== rand_num[0]) begin
        `nnc_error("ANA", $sformatf("A2D_SDM_OUT4 :%b is not as expectation of rand_num : %b",`ANA_WRAPPER_TOP.A2D_SDM_OUT4, rand_num[0]))
        end
        release `ANA_TOP.A2D_SDM4;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_TOP.A2D_SDM5     = $random;
        #10000ns;
        rand_num = `ANA_TOP.A2D_SDM5;
        if (`ANA_WRAPPER_TOP.A2D_SDM_OUT5 !== rand_num[0]) begin
        `nnc_error("ANA", $sformatf("A2D_SDM_OUT5 :%b is not as expectation of rand_num : %b",`ANA_WRAPPER_TOP.A2D_SDM_OUT5, rand_num[0]))
        end
        release `ANA_TOP.A2D_SDM5;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_TOP.A2D_SDM6     = $random;
        #10000ns;
        rand_num = `ANA_TOP.A2D_SDM6;
        if (`ANA_WRAPPER_TOP.A2D_SDM_OUT6 !== rand_num[0]) begin
        `nnc_error("ANA", $sformatf("A2D_SDM_OUT6 :%b is not as expectation of rand_num : %b",`ANA_WRAPPER_TOP.A2D_SDM_OUT6, rand_num[0]))
        end
        release `ANA_TOP.A2D_SDM6;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_TOP.A2D_SDM7     = $random;
        #10000ns;
        rand_num = `ANA_TOP.A2D_SDM7;
        if (`ANA_WRAPPER_TOP.A2D_SDM_OUT7 !== rand_num[0]) begin
        `nnc_error("ANA", $sformatf("A2D_SDM_OUT7 :%b is not as expectation of rand_num : %b",`ANA_WRAPPER_TOP.A2D_SDM_OUT7, rand_num[0]))
        end
        release `ANA_TOP.A2D_SDM7;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_TOP.A2D_SDM8     = $random;
        #10000ns;
        rand_num = `ANA_TOP.A2D_SDM8;
        if (`ANA_WRAPPER_TOP.A2D_SDM_OUT8 !== rand_num[0]) begin
        `nnc_error("ANA", $sformatf("A2D_SDM_OUT8 :%b is not as expectation of rand_num : %b",`ANA_WRAPPER_TOP.A2D_SDM_OUT8, rand_num[0]))
        end
        release `ANA_TOP.A2D_SDM8;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_TOP.A2D_SDM9     = $random;
        #10000ns;
        rand_num = `ANA_TOP.A2D_SDM9;
        if (`ANA_WRAPPER_TOP.A2D_SDM_OUT9 !== rand_num[0]) begin
        `nnc_error("ANA", $sformatf("A2D_SDM_OUT9 :%b is not as expectation of rand_num : %b",`ANA_WRAPPER_TOP.A2D_SDM_OUT9, rand_num[0]))
        end
        release `ANA_TOP.A2D_SDM9;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_TOP.A2D_SDM10     = $random;
        #10000ns;
        rand_num = `ANA_TOP.A2D_SDM10;
        if (`ANA_WRAPPER_TOP.A2D_SDM_OUT10 !== rand_num[0]) begin
        `nnc_error("ANA", $sformatf("A2D_SDM_OUT10 :%b is not as expectation of rand_num : %b",`ANA_WRAPPER_TOP.A2D_SDM_OUT10, rand_num[0]))
        end
        release `ANA_TOP.A2D_SDM10;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_TOP.A2D_SDM11     = $random;
        #10000ns;
        rand_num = `ANA_TOP.A2D_SDM11;
        if (`ANA_WRAPPER_TOP.A2D_SDM_OUT11 !== rand_num[0]) begin
        `nnc_error("ANA", $sformatf("A2D_SDM_OUT11 :%b is not as expectation of rand_num : %b",`ANA_WRAPPER_TOP.A2D_SDM_OUT11, rand_num[0]))
        end
        release `ANA_TOP.A2D_SDM11;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_TOP.A2D_SDM12     = $random;
        #10000ns;
        rand_num = `ANA_TOP.A2D_SDM12;
        if (`ANA_WRAPPER_TOP.A2D_SDM_OUT12 !== rand_num[0]) begin
        `nnc_error("ANA", $sformatf("A2D_SDM_OUT12 :%b is not as expectation of rand_num : %b",`ANA_WRAPPER_TOP.A2D_SDM_OUT12, rand_num[0]))
        end
        release `ANA_TOP.A2D_SDM12;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_TOP.A2D_SDM13     = $random;
        #10000ns;
        rand_num = `ANA_TOP.A2D_SDM13;
        if (`ANA_WRAPPER_TOP.A2D_SDM_OUT13 !== rand_num[0]) begin
        `nnc_error("ANA", $sformatf("A2D_SDM_OUT13 :%b is not as expectation of rand_num : %b",`ANA_WRAPPER_TOP.A2D_SDM_OUT13, rand_num[0]))
        end
        release `ANA_TOP.A2D_SDM13;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_TOP.A2D_SDM14     = $random;
        #10000ns;
        rand_num = `ANA_TOP.A2D_SDM14;
        if (`ANA_WRAPPER_TOP.A2D_SDM_OUT14 !== rand_num[0]) begin
        `nnc_error("ANA", $sformatf("A2D_SDM_OUT14 :%b is not as expectation of rand_num : %b",`ANA_WRAPPER_TOP.A2D_SDM_OUT14, rand_num[0]))
        end
        release `ANA_TOP.A2D_SDM14;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_TOP.A2D_SDM15     = $random;
        #10000ns;
        rand_num = `ANA_TOP.A2D_SDM15;
        if (`ANA_WRAPPER_TOP.A2D_SDM_OUT15 !== rand_num[0]) begin
        `nnc_error("ANA", $sformatf("A2D_SDM_OUT15 :%b is not as expectation of rand_num : %b",`ANA_WRAPPER_TOP.A2D_SDM_OUT15, rand_num[0]))
        end
        release `ANA_TOP.A2D_SDM15;
    end
    //----------------------------SPARE-------------------------------//       
    `nnc_info("SPARE", "Start  testing SPARE", NNC_LOW)
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[0][13][7:0]     = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[0][13][7:0];
        if (`ANA_TOP.D2A_SPI_SPARE0 !== rand_num[7:0]) begin
        `nnc_error("ANA", $sformatf("D2A_SPI_SPARE0 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_SPI_SPARE0, rand_num[7:0]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[0][13][7:0];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[1][13][7:0]     = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[1][13][7:0];
        if (`ANA_TOP.D2A_SPI_SPARE1 !== rand_num[7:0]) begin
        `nnc_error("ANA", $sformatf("D2A_SPI_SPARE1 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_SPI_SPARE1, rand_num[7:0]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[1][13][7:0];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[2][13][7:0]     = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[2][13][7:0];
        if (`ANA_TOP.D2A_SPI_SPARE2 !== rand_num[7:0]) begin
        `nnc_error("ANA", $sformatf("D2A_SPI_SPARE2 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_SPI_SPARE2, rand_num[7:0]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[2][13][7:0];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[3][13][7:0]     = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[3][13][7:0];
        if (`ANA_TOP.D2A_SPI_SPARE3 !== rand_num[7:0]) begin
        `nnc_error("ANA", $sformatf("D2A_SPI_SPARE3 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_SPI_SPARE3, rand_num[7:0]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[3][13][7:0];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[4][13][7:0]     = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[4][13][7:0];
        if (`ANA_TOP.D2A_SPI_SPARE4 !== rand_num[7:0]) begin
        `nnc_error("ANA", $sformatf("D2A_SPI_SPARE4 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_SPI_SPARE4, rand_num[7:0]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[4][13][7:0];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[5][13][7:0]     = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[5][13][7:0];
        if (`ANA_TOP.D2A_SPI_SPARE5 !== rand_num[7:0]) begin
        `nnc_error("ANA", $sformatf("D2A_SPI_SPARE5 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_SPI_SPARE5, rand_num[7:0]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[5][13][7:0];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[6][13][7:0]     = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[6][13][7:0];
        if (`ANA_TOP.D2A_SPI_SPARE6 !== rand_num[7:0]) begin
        `nnc_error("ANA", $sformatf("D2A_SPI_SPARE6 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_SPI_SPARE6, rand_num[7:0]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[6][13][7:0];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[7][13][7:0]     = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[7][13][7:0];
        if (`ANA_TOP.D2A_SPI_SPARE7 !== rand_num[7:0]) begin
        `nnc_error("ANA", $sformatf("D2A_SPI_SPARE7 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_SPI_SPARE7, rand_num[7:0]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[7][13][7:0];
    end
   
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_TRIM0_SIG_SPARE     = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_TRIM0_SIG_SPARE;
        if (`ANA_TOP.D2A_TRIM0_SIG_SPARE !== rand_num[7:0]) begin
        `nnc_error("ANA", $sformatf("D2A_TRIM0_SIG_SPARE :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_TRIM0_SIG_SPARE, rand_num[7:0]))
        end
        release `ANA_WRAPPER_TOP.D2A_TRIM0_SIG_SPARE;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_TRIM1_SIG_SPARE     = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_TRIM1_SIG_SPARE;
        if (`ANA_TOP.D2A_TRIM1_SIG_SPARE !== rand_num[7:0]) begin
        `nnc_error("ANA", $sformatf("D2A_TRIM1_SIG_SPARE :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_TRIM1_SIG_SPARE, rand_num[7:0]))
        end
        release `ANA_WRAPPER_TOP.D2A_TRIM1_SIG_SPARE;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_TRIM2_SIG_SPARE     = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_TRIM2_SIG_SPARE;
        if (`ANA_TOP.D2A_TRIM2_SIG_SPARE !== rand_num[7:0]) begin
        `nnc_error("ANA", $sformatf("D2A_TRIM2_SIG_SPARE :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_TRIM2_SIG_SPARE, rand_num[7:0]))
        end
        release `ANA_WRAPPER_TOP.D2A_TRIM2_SIG_SPARE;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_TRIM3_SIG_SPARE     = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_TRIM3_SIG_SPARE;
        if (`ANA_TOP.D2A_TRIM3_SIG_SPARE !== rand_num[7:0]) begin
        `nnc_error("ANA", $sformatf("D2A_TRIM3_SIG_SPARE :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_TRIM3_SIG_SPARE, rand_num[7:0]))
        end
        release `ANA_WRAPPER_TOP.D2A_TRIM3_SIG_SPARE;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_TRIM4_SIG_SPARE     = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_TRIM4_SIG_SPARE;
        if (`ANA_TOP.D2A_TRIM4_SIG_SPARE !== rand_num[7:0]) begin
        `nnc_error("ANA", $sformatf("D2A_TRIM4_SIG_SPARE :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_TRIM4_SIG_SPARE, rand_num[7:0]))
        end
        release `ANA_WRAPPER_TOP.D2A_TRIM4_SIG_SPARE;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_TRIM5_SIG_SPARE     = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_TRIM5_SIG_SPARE;
        if (`ANA_TOP.D2A_TRIM5_SIG_SPARE !== rand_num[7:0]) begin
        `nnc_error("ANA", $sformatf("D2A_TRIM5_SIG_SPARE :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_TRIM5_SIG_SPARE, rand_num[7:0]))
        end
        release `ANA_WRAPPER_TOP.D2A_TRIM5_SIG_SPARE;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_TRIM6_SIG_SPARE     = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_TRIM6_SIG_SPARE;
        if (`ANA_TOP.D2A_TRIM6_SIG_SPARE !== rand_num[7:0]) begin
        `nnc_error("ANA", $sformatf("D2A_TRIM6_SIG_SPARE :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_TRIM6_SIG_SPARE, rand_num[7:0]))
        end
        release `ANA_WRAPPER_TOP.D2A_TRIM6_SIG_SPARE;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.D2A_TRIM7_SIG_SPARE     = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_TRIM7_SIG_SPARE;
        if (`ANA_TOP.D2A_TRIM7_SIG_SPARE !== rand_num[7:0]) begin
        `nnc_error("ANA", $sformatf("D2A_TRIM7_SIG_SPARE :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_TRIM7_SIG_SPARE, rand_num[7:0]))
        end
        release `ANA_WRAPPER_TOP.D2A_TRIM7_SIG_SPARE;
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_TOP.A2D_SPARE_RO_REG_0     = $random;
        #10000ns;
        rand_num = `ANA_TOP.A2D_SPARE_RO_REG_0;
        if (`ANA_WRAPPER_TOP.A2D_SPARE_RO_REG_0 !== rand_num[7:0]) begin
        `nnc_error("ANA", $sformatf("A2D_SPARE_RO_REG_0 :%b is not as expectation of rand_num : %b",`ANA_WRAPPER_TOP.A2D_SPARE_RO_REG_0, rand_num[7:0]))
        end
        release `ANA_TOP.A2D_SPARE_RO_REG_0;
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
