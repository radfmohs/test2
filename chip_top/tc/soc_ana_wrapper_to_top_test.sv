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
        if (`ANA_WRAPPER_TOP.A2D_ANA_GEN_REG[0][1] !== rand_bit) begin
          `nnc_error("ANA", $sformatf("A2D_ANA_GEN_REG_0 :%b is not as expectation of rand_bit : %b",`ANA_WRAPPER_TOP.A2D_ANA_GEN_REG[0][1], rand_bit))
        end
      release  `ANA_TOP.A2D_TSC_COMP_OUT; 
    end
    
    //Module : PMU , Direction : D2A , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[0][14][2:0] = $random;
        #10000ns;
        //rand_bit = `ANA_WRAPPER_TOP.D2A_ADJ0_14_IO;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[0][14][2:0];
        if (`ANA_TOP.D2A_VDAC8B_DIN !== rand_bit) begin
          `nnc_error("ANA", $sformatf("D2A_VDAC8B_DIN :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_VDAC8B_DIN, rand_num[2:0]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[0][14][2:0];
        
        force `ANA_WRAPPER_TOP.D2A_ADJ0_IO = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.D2A_ADJ0_IO;
        if (`ANA_TOP.D2A_VDAC8B_DIN !== rand_bit) begin
          `nnc_error("ANA", $sformatf("D2A_VDAC8B_DIN :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_VDAC8B_DIN, rand_bit))
        end
        release `ANA_WRAPPER_TOP.D2A_ADJ0_IO;
        
        force `ANA_WRAPPER_TOP.D2A_ADJ14_IO = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.D2A_ADJ14_IO;
        if (`ANA_TOP.D2A_VDAC8B_DIN !== rand_bit) begin
          `nnc_error("ANA", $sformatf("D2A_VDAC8B_DIN :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_VDAC8B_DIN, rand_bit))
        end
        release `ANA_WRAPPER_TOP.D2A_ADJ14_IO;
    end

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
    //Module : DC LEAD OFF , Direction : D2A , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin // DONEEEEEEEEEEEEEEEEEEEEEE
        force `ANA_WRAPPER_TOP.ANA_ENABLE_REG[1][6] = $random;
        force `ANA_WRAPPER_TOP.ANA_ENABLE_REG[1][5] = $random;
        #10000ns;
        rand_num[15:0] = {`ANA_WRAPPER_TOP.ANA_ENABLE_REG[1][6],`ANA_WRAPPER_TOP.ANA_ENABLE_REG[1][5]};
        if (`ANA_TOP.D2A_DCLOFFEN !== rand_num[15:0]) begin
        `nnc_error("ANA", $sformatf("DCLOFFEN[15:0] :%b is not as expectation of rand_num: %b",`ANA_TOP.D2A_DCLOFFEN[15:0], rand_num[15:0]))
        end
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[1][6];
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[1][5];
    end

    //Module : DC LEAD OFF , Direction : D2A , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_ENABLE_REG[1][14] = $random;
        #10000ns;
        rand_num[7:0] = `ANA_WRAPPER_TOP.ANA_ENABLE_REG[1][14];
        if (`ANA_TOP.D2A_LOFF_COMP_TH !== rand_num[2:0]) begin
        `nnc_error("ANA", $sformatf("LOFF_COMP_TH :%b is not as expectation of rand_num[2:0] : %3b",`ANA_TOP.D2A_LOFF_ISEL_ADJ, rand_num[2:0]))
        end
        if (`ANA_TOP.D2A_LOFF_ISEL_ADJ !== rand_num[7:4]) begin
        `nnc_error("ANA", $sformatf("LOFF_ISEL_ADJ :%b is not as expectation of rand_num[7:4] : %4b",`ANA_TOP.D2A_LOFF_ISEL_ADJ, rand_num[7:4]))
        end
        if (`ANA_TOP.D2A_LOFF_IPOL !== rand_num[3]) begin
        `nnc_error("ANA", $sformatf("LOFF_IPOL :%b is not as expectation of rand_num[3] : %1b",`ANA_TOP.D2A_LOFF_IPOL, rand_num[3]))
        end
        release  `ANA_WRAPPER_TOP.ANA_ENABLE_REG[1][14];  
        
        force `ANA_WRAPPER_TOP.D2A_ADJ1_IO = $random;
        #10000ns;
        rand_num[7:0] = `ANA_WRAPPER_TOP.D2A_ADJ1_IO;
        if (`ANA_TOP.D2A_LOFF_COMP_TH !== rand_num[2:0]) begin
        `nnc_error("ANA", $sformatf("LOFF_COMP_TH :%b is not as expectation of rand_num[2:0] : %3b",`ANA_TOP.D2A_LOFF_ISEL_ADJ, rand_num[2:0]))
        end
        if (`ANA_TOP.D2A_LOFF_ISEL_ADJ !== rand_num[7:4]) begin
        `nnc_error("ANA", $sformatf("LOFF_ISEL_ADJ :%b is not as expectation of rand_num[7:4] : %4b",`ANA_TOP.D2A_LOFF_ISEL_ADJ, rand_num[7:4]))
        end
        if (`ANA_TOP.D2A_LOFF_IPOL !== rand_num[3]) begin
        `nnc_error("ANA", $sformatf("LOFF_IPOL :%b is not as expectation of rand_num[3] : %1b",`ANA_TOP.D2A_LOFF_IPOL, rand_num[3]))
        end
        release  `ANA_WRAPPER_TOP.D2A_ADJ1_IO;  
        
        force `ANA_WRAPPER_TOP.D2A_ADJ2_IO = $random;
        #10000ns;
        rand_num[7:0] = `ANA_WRAPPER_TOP.D2A_ADJ2_IO;
        if (`ANA_TOP.D2A_LOFF_COMP_TH !== rand_num[2:0]) begin
        `nnc_error("ANA", $sformatf("LOFF_COMP_TH :%b is not as expectation of rand_num[2:0] : %3b",`ANA_TOP.D2A_LOFF_ISEL_ADJ, rand_num[2:0]))
        end
        if (`ANA_TOP.D2A_LOFF_ISEL_ADJ !== rand_num[7:4]) begin
        `nnc_error("ANA", $sformatf("LOFF_ISEL_ADJ :%b is not as expectation of rand_num[7:4] : %4b",`ANA_TOP.D2A_LOFF_ISEL_ADJ, rand_num[7:4]))
        end
        if (`ANA_TOP.D2A_LOFF_IPOL !== rand_num[3]) begin
        `nnc_error("ANA", $sformatf("LOFF_IPOL :%b is not as expectation of rand_num[3] : %1b",`ANA_TOP.D2A_LOFF_IPOL, rand_num[3]))
        end
      release  `ANA_WRAPPER_TOP.D2A_ADJ2_IO;  
    end

    //Module : DC LEAD OFF , Direction : A2D , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_TOP.A2D_LOFF_STATP = $random;                                      
        #10000ns;
        rand_num = `ANA_TOP.A2D_LOFF_STATP;
        if ({`ANA_WRAPPER_TOP.A2D_ANA_GEN_REG[2],`ANA_WRAPPER_TOP.A2D_ANA_GEN_REG[1]} !== rand_num[15:0]) begin
        `nnc_error("ANA", $sformatf("{`ANA_WRAPPER_TOP.pinmux_if.A2D_ANA_GEN_REG[2],`ANA_WRAPPER_TOP.pinmux_if.A2D_ANA_GEN_REG[1]} :%b is not as expectation of rand_bit : %b",{`ANA_WRAPPER_TOP.A2D_ANA_GEN_REG[2],`ANA_WRAPPER_TOP.A2D_ANA_GEN_REG[1]}, rand_num[15:0]))
        end
        force `ANA_TOP.A2D_LOFF_STATP = $random;                                      
    end
    
    //Module : DC LEAD OFF , Direction : A2D , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_TOP.A2D_LOFF_STATN = $random;                                      
        #10000ns;
        rand_num = `ANA_TOP.A2D_LOFF_STATN;
        if ({`ANA_WRAPPER_TOP.A2D_ANA_GEN_REG[4],`ANA_WRAPPER_TOP.A2D_ANA_GEN_REG[3]} !== rand_num[15:0]) begin
        `nnc_error("ANA", $sformatf("{`ANA_WRAPPER_TOP.pinmux_if.A2D_ANA_GEN_REG[4],`ANA_WRAPPER_TOP.pinmux_if.A2D_ANA_GEN_REG[3]} :%b is not as expectation of rand_bit : %b",{`ANA_WRAPPER_TOP.A2D_ANA_GEN_REG[4],`ANA_WRAPPER_TOP.A2D_ANA_GEN_REG[3]}, rand_num[15:0]))
        end
        force `ANA_TOP.A2D_LOFF_STATN = $random;                                      
    end

    //-----------------------------RECODING-------------------------------//    
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
        force `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][0][3] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][0][3];
        if (`ANA_TOP.D2A_BIASREF_INT !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_BIASREF_INT :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_BIASREF_INT, rand_bit))
        end
      release  `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][0][3]; 
    end

    //Module : RECODING , Direction : D2A , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][4] = $random;
        force `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][5] = $random;
        #10000ns;
        rand_num = {`ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][5],`ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][4]};
        if (`ANA_TOP.D2A_EEGLNA_EN !== rand_num[15:0]) begin
        `nnc_error("ANA", $sformatf("D2A_EEGLNA_EN :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEGLNA_EN, rand_num[15:0]))
        end
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][4];
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][5];
    end
    
    //Module : RECODING , Direction : D2A , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][6] = $random;
        force `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][7] = $random;
        #10000ns;
        rand_num = {`ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][7],`ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][6]};
        if (`ANA_TOP.D2A_QSTRLNA_EN !== rand_num[15:0]) begin
        `nnc_error("ANA", $sformatf("D2A_QSTRLNA :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_QSTRLNA_EN, rand_num[15:0]))
        end
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][6];
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][7];
    end
    
    //Module : RECODING , Direction : D2A , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][8] = $random;
        force `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][9] = $random;
        #10000ns;
        rand_num = {`ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][9],`ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][8]};
        if (`ANA_TOP.D2A_EEGPGA_EN !== rand_num[15:0]) begin
        `nnc_error("ANA", $sformatf("D2A_EEGPGA_EN :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEGPGA_EN, rand_num[15:0]))
        end
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][8];
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][9];
    end
    
    //Module : RECODING , Direction : D2A , Connection : SPI THROUGH PINMUX.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][10] = $random;
        force `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][11] = $random;
        #10000ns;
        rand_num = {`ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][11],`ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][10]};
        if (`ANA_TOP.D2A_QSTRPGA_EN !== rand_num[15:0]) begin
        `nnc_error("ANA", $sformatf("D2A_QSTRPGA_EN :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_QSTRPGA_EN, rand_num[15:0]))
        end
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][10];
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][11];
    end
    
    //Module : RECODING , Direction : D2A , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[4][14] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[4][14];
        if (`ANA_TOP.D2A_VCMGENBUFF_IADJ !== rand_num[7:0]) begin
        `nnc_error("ANA", $sformatf("D2A_VCMGENBUFF_IADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_VCMGENBUFF_IADJ, rand_num[7:0]))
        end
        release `ANA_WRAPPER_TOP.ANA_GEN_REG[4][14];
        
        force `ANA_WRAPPER_TOP.D2A_ADJ10_IO = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_ADJ10_IO;
        if (`ANA_TOP.D2A_VCMGENBUFF_IADJ !== rand_num[7:0]) begin
        `nnc_error("ANA", $sformatf("D2A_VCMGENBUFF_IADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_VCMGENBUFF_IADJ, rand_num[7:0]))
        end
        release `ANA_WRAPPER_TOP.D2A_ADJ10_IO;
    end
    
    //Module : RECODING , Direction : D2A , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][2][1] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][2][1];
        if (`ANA_TOP.D2A_VCMGENBUFF_EN !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_VCMGENBUFF_EN :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_VCMGENBUFF_EN, rand_bit))
        end
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[4][14];
    end
    
    //Module : RECODING , Direction : D2A , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][2][1] = $random;
        #10000ns;
        rand_bit = `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][2][1];
        if (`ANA_TOP.D2A_SDMVCMBUFF_EN !== rand_bit) begin
        `nnc_error("ANA", $sformatf("D2A_SDMVCMBUFF_EN :%b is not as expectation of rand_bit : %b",`ANA_TOP.D2A_VCMGENBUFF_EN, rand_bit))
        end
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[4][14];
    end
    
    //Module : RECODING , Direction : D2A , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[5][14] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_GEN_REG[5][14];
        if (`ANA_TOP.D2A_SDMVCMBUFF_IADJ !== rand_num[1:0]) begin
        `nnc_error("ANA", $sformatf("D2A_SDMVCMBUFF_IADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_SDMVCMBUFF_IADJ, rand_num[1:0]))
        end
        if (`ANA_TOP.D2A_SDMVCMBUFF_SEL !== rand_num[7:2]) begin
        `nnc_error("ANA", $sformatf("D2A_SDMVCMBUFF_SEL :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_SDMVCMBUFF_SEL, rand_num[7:2]))
        end
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[5][14];
            
        force `ANA_WRAPPER_TOP.D2A_ADJ11_IO = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_ADJ11_IO;
        if (`ANA_TOP.D2A_SDMVCMBUFF_IADJ !== rand_num[1:0]) begin
        `nnc_error("ANA", $sformatf("D2A_SDMVCMBUFF_IADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_SDMVCMBUFF_IADJ, rand_num[1:0]))
        end
        if (`ANA_TOP.D2A_SDMVCMBUFF_SEL !== rand_num[7:2]) begin
        `nnc_error("ANA", $sformatf("D2A_SDMVCMBUFF_SEL :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_SDMVCMBUFF_SEL, rand_num[7:2]))
        end
        release `ANA_WRAPPER_TOP.D2A_ADJ11_IO;
    end
    
    //Module : RECODING , Direction : D2A , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][2][3] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][2][3];
        if (`ANA_TOP.D2A_SDMVREFPBUFF_EN !== rand_num[0]) begin
        `nnc_error("ANA", $sformatf("D2A_SDMVREFPBUFF_EN :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_SDMVREFPBUFF_EN, rand_num[0]))
        end
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[6][14];
    end 
    
    //Module : RECODING , Direction : D2A , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_ENABLE_REG[6][14][1:0] = $random;
        force `ANA_WRAPPER_TOP.ANA_ENABLE_REG[6][14][7:2] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_ENABLE_REG[6][14];
        if (`ANA_TOP.D2A_SDMVREFP_IADJ !== rand_num[1:0]) begin
        `nnc_error("ANA", $sformatf("D2A_SDMVREFP_IADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_SDMVREFP_IADJ, rand_num[1:0]))
        end
        if (`ANA_TOP.D2A_SDMVREFP_SEL !== rand_num[7:2]) begin
        `nnc_error("ANA", $sformatf("D2A_SDMVREFP_SEL :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_SDMVREFP_SEL, rand_num[7:2]))
        end
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[6][14];
        
        force `ANA_WRAPPER_TOP.D2A_ADJ12_IO[1:0] = $random;
        force `ANA_WRAPPER_TOP.D2A_ADJ12_IO[7:2] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_ADJ12_IO;
        if (`ANA_TOP.D2A_SDMVREFP_IADJ !== rand_num[1:0]) begin
        `nnc_error("ANA", $sformatf("D2A_SDMVREFP_IADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_SDMVREFP_IADJ, rand_num[1:0]))
        end
        if (`ANA_TOP.D2A_SDMVREFP_SEL !== rand_num[7:2]) begin
        `nnc_error("ANA", $sformatf("D2A_SDMVREFP_SEL :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_SDMVREFP_SEL, rand_num[7:2]))
        end
        release `ANA_WRAPPER_TOP.D2A_ADJ12_IO;
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
        force `ANA_WRAPPER_TOP.ANA_ENABLE_REG[7][14] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_ENABLE_REG[7][14];
        if (`ANA_TOP.D2A_RLD_IADJ !== rand_num[7:0]) begin
        `nnc_error("ANA", $sformatf("D2A_RLD_IADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_RLD_IADJ, rand_num[7:0]))
        end
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[6][14];
        
        force `ANA_WRAPPER_TOP.D2A_ADJ13_IO = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.D2A_ADJ13_IO;
        if (`ANA_TOP.D2A_RLD_IADJ !== rand_num[7:0]) begin
        `nnc_error("ANA", $sformatf("D2A_RLD_IADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_RLD_IADJ, rand_num[7:0]))
        end
        release `ANA_WRAPPER_TOP.D2A_ADJ13_IO;
    end
    
    //Module : RECODING , Direction : D2A , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[0][1] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][1];
        if (`ANA_TOP.D2A_EEG_CH0_SET !== rand_num[2:0]) begin
        `nnc_error("ANA", $sformatf("D2A_EEG_CH0_SET :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEG_CH0_SET, rand_num[2:0]))
        end
        if (`ANA_TOP.D2A_EEG_CH1_SET !== rand_num[5:3]) begin
        `nnc_error("ANA", $sformatf("D2A_EEG_CH1_SET :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEG_CH1_SET, rand_num[5:3]))
        end
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][1];
    end
    
    //Module : RECODING , Direction : D2A , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[0][2] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][2];
        if (`ANA_TOP.D2A_EEG_CH2_SET !== rand_num[2:0]) begin
        `nnc_error("ANA", $sformatf("D2A_EEG_CH2_SET :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEG_CH2_SET, rand_num[2:0]))
        end
        if (`ANA_TOP.D2A_EEG_CH3_SET !== rand_num[5:3]) begin
        `nnc_error("ANA", $sformatf("D2A_EEG_CH3_SET :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEG_CH3_SET, rand_num[5:3]))
        end
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][2];
    end
    
    //Module : RECODING , Direction : D2A , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[0][3] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][3];
        if (`ANA_TOP.D2A_EEG_CH4_SET !== rand_num[2:0]) begin
        `nnc_error("ANA", $sformatf("D2A_EEG_CH4_SET :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEG_CH4_SET, rand_num[2:0]))
        end
        if (`ANA_TOP.D2A_EEG_CH5_SET !== rand_num[5:3]) begin
        `nnc_error("ANA", $sformatf("D2A_EEG_CH5_SET :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEG_CH5_SET, rand_num[5:3]))
        end
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][3];
    end
    
    //Module : RECODING , Direction : D2A , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[0][4] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][4];
        if (`ANA_TOP.D2A_EEG_CH6_SET !== rand_num[2:0]) begin
        `nnc_error("ANA", $sformatf("D2A_EEG_CH6_SET :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEG_CH6_SET, rand_num[2:0]))
        end
        if (`ANA_TOP.D2A_EEG_CH7_SET !== rand_num[5:3]) begin
        `nnc_error("ANA", $sformatf("D2A_EEG_CH7_SET :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEG_CH7_SET, rand_num[5:3]))
        end
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][4];
    end
    
    //Module : RECODING , Direction : D2A , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[0][5] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][5];
        if (`ANA_TOP.D2A_EEG_CH8_SET !== rand_num[2:0]) begin
        `nnc_error("ANA", $sformatf("D2A_EEG_CH8_SET :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEG_CH8_SET, rand_num[2:0]))
        end
        if (`ANA_TOP.D2A_EEG_CH9_SET !== rand_num[5:3]) begin
        `nnc_error("ANA", $sformatf("D2A_EEG_CH9_SET :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEG_CH9_SET, rand_num[5:3]))
        end
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][5];
    end
    
    //Module : RECODING , Direction : D2A , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[0][6] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][6];
        if (`ANA_TOP.D2A_EEG_CH10_SET !== rand_num[2:0]) begin
        `nnc_error("ANA", $sformatf("D2A_EEG_CH10_SET :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEG_CH11_SET, rand_num[2:0]))
        end
        if (`ANA_TOP.D2A_EEG_CH11_SET !== rand_num[5:3]) begin
        `nnc_error("ANA", $sformatf("D2A_EEG_CH11_SET :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEG_CH11_SET, rand_num[5:3]))
        end
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][6];
    end
    
    //Module : RECODING , Direction : D2A , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[0][7] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][7];
        if (`ANA_TOP.D2A_EEG_CH12_SET !== rand_num[2:0]) begin
        `nnc_error("ANA", $sformatf("D2A_EEG_CH12_SET :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEG_CH12_SET, rand_num[2:0]))
        end
        if (`ANA_TOP.D2A_EEG_CH13_SET !== rand_num[5:3]) begin
        `nnc_error("ANA", $sformatf("D2A_EEG_CH13_SET :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEG_CH13_SET, rand_num[5:3]))
        end
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][7];
    end
    
    //Module : RECODING , Direction : D2A , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[0][8] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][8];
        if (`ANA_TOP.D2A_EEG_CH14_SET !== rand_num[2:0]) begin
        `nnc_error("ANA", $sformatf("D2A_EEG_CH14_SET :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEG_CH14_SET, rand_num[2:0]))
        end
        if (`ANA_TOP.D2A_EEG_CH15_SET !== rand_num[5:3]) begin
        `nnc_error("ANA", $sformatf("D2A_EEG_CH15_SET :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEG_CH15_SET, rand_num[5:3]))
        end
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][8];
    end
    
    //Module : RECODING , Direction : D2A , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[0][9] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][9];
        if (`ANA_TOP.D2A_EEGLNA0_IADJ !== rand_num[1:0]) begin
        `nnc_error("ANA", $sformatf("D2A_EEGLNA0 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEGLNA0_IADJ, rand_num[1:0]))
        end
        if (`ANA_TOP.D2A_EEGLNA1_IADJ !== rand_num[3:2]) begin
        `nnc_error("ANA", $sformatf("D2A_EEGLNA1 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEGLNA1_IADJ, rand_num[3:2]))
        end
        if (`ANA_TOP.D2A_EEGLNA2_IADJ !== rand_num[5:4]) begin
        `nnc_error("ANA", $sformatf("D2A_EEGLNA2 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEGLNA2_IADJ, rand_num[5:4]))
        end
        if (`ANA_TOP.D2A_EEGLNA3_IADJ !== rand_num[7:6]) begin
        `nnc_error("ANA", $sformatf("D2A_EEGLNA3 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEGLNA3_IADJ, rand_num[7:6]))
        end
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][9];
    end
    
    //Module : RECODING , Direction : D2A , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[0][10] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][10];
        if (`ANA_TOP.D2A_EEGLNA4_IADJ !== rand_num[1:0]) begin
        `nnc_error("ANA", $sformatf("D2A_EEGLNA4 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEGLNA4_IADJ, rand_num[1:0]))
        end
        if (`ANA_TOP.D2A_EEGLNA5_IADJ !== rand_num[3:2]) begin
        `nnc_error("ANA", $sformatf("D2A_EEGLNA5 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEGLNA5_IADJ, rand_num[3:2]))
        end
        if (`ANA_TOP.D2A_EEGLNA6_IADJ !== rand_num[5:4]) begin
        `nnc_error("ANA", $sformatf("D2A_EEGLNA6 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEGLNA6_IADJ, rand_num[5:4]))
        end
        if (`ANA_TOP.D2A_EEGLNA7_IADJ !== rand_num[7:6]) begin
        `nnc_error("ANA", $sformatf("D2A_EEGLNA7 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEGLNA7_IADJ, rand_num[7:6]))
        end
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][10];
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_ENABLE_REG[2][14][7:6] = $random;
        #10000ns;
        rand_num[1:0] = `ANA_WRAPPER_TOP.ANA_ENABLE_REG[2][14][7:6];
        if (`ANA_TOP.D2A_EEGLNA8_IADJ !== rand_num[1:0]) begin
        `nnc_error("ANA", $sformatf("D2A_EEGLNA8_IADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEGLNA8_IADJ, rand_num[1:0]))
        end
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[2][14][7:6];
        
        force `ANA_WRAPPER_TOP.D2A_ADJ6_IO[7:6] = $random;
        #10000ns;
        rand_num[1:0] = `ANA_WRAPPER_TOP.D2A_ADJ12_IO;
        if (`ANA_TOP.D2A_EEGLNA8_IADJ !== rand_num[1:0]) begin
        `nnc_error("ANA", $sformatf("D2A_EEGLNA8_IADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEGLNA8_IADJ, rand_num[1:0]))
        end
        release `ANA_WRAPPER_TOP.D2A_ADJ6_IO;
        
        force `ANA_WRAPPER_TOP.D2A_ADJ7_IO[7:6] = $random;
        #10000ns;
        rand_num[1:0] = `ANA_WRAPPER_TOP.D2A_ADJ7_IO;
        if (`ANA_TOP.D2A_EEGLNA8_IADJ !== rand_num[1:0]) begin
        `nnc_error("ANA", $sformatf("D2A_EEGLNA8_IADJ :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEGLNA8_IADJ, rand_num[1:0]))
        end
        release `ANA_WRAPPER_TOP.D2A_ADJ7_IO;
    end
    
    //Module : RECODING , Direction : D2A , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[0][11] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][11];
        if (`ANA_TOP.D2A_EEGLNA9_IADJ !== rand_num[1:0]) begin
        `nnc_error("ANA", $sformatf("D2A_EEGLNA9 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEGLNA9_IADJ, rand_num[1:0]))
        end
        if (`ANA_TOP.D2A_EEGLNA10_IADJ !== rand_num[3:2]) begin
        `nnc_error("ANA", $sformatf("D2A_EEGLNA10 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEGLNA10_IADJ, rand_num[3:2]))
        end
        if (`ANA_TOP.D2A_EEGLNA11_IADJ !== rand_num[5:4]) begin
        `nnc_error("ANA", $sformatf("D2A_EEGLNA11 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEGLNA11_IADJ, rand_num[5:4]))
        end
        if (`ANA_TOP.D2A_EEGLNA12_IADJ !== rand_num[7:6]) begin
        `nnc_error("ANA", $sformatf("D2A_EEGLNA12 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEGLNA12_IADJ, rand_num[7:6]))
        end
        release `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][11];
    end
    
    //Module : RECODING , Direction : D2A , Connection : SPI.
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[0][12] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_ENABLE_REG[0][12];
        if (`ANA_TOP.D2A_EEGLNA13_IADJ !== rand_num[1:0]) begin
        `nnc_error("ANA", $sformatf("D2A_EEGLNA13 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEGLNA13_IADJ, rand_num[1:0]))
        end
        if (`ANA_TOP.D2A_EEGLNA14_IADJ !== rand_num[3:2]) begin
        `nnc_error("ANA", $sformatf("D2A_EEGLNA14 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEGLNA14_IADJ, rand_num[3:2]))
        end
        if (`ANA_TOP.D2A_EEGLNA15_IADJ !== rand_num[5:4]) begin
        `nnc_error("ANA", $sformatf("D2A_EEGLNA15 :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEGLNA15_IADJ, rand_num[5:4]))
        end
    end
    
    for (int i=0; i < 100; i++) begin
        force `ANA_WRAPPER_TOP.ANA_GEN_REG[1][0] = $random;
        #10000ns;
        rand_num = `ANA_WRAPPER_TOP.ANA_ENABLE_REG[1][0];
        if (`ANA_TOP.D2A_EEGLNA0_GAIN !== rand_num[5:0]) begin
        `nnc_error("ANA", $sformatf("D2A_EEGLNA0_GAIN :%b is not as expectation of rand_num : %b",`ANA_TOP.D2A_EEGLNA0_GAIN, rand_num[5:0]))
        end
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
