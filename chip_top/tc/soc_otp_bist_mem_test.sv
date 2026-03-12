//========================================================================================================  
// -------------------------------------------------------------------------------------------------------  
//  Nanochap Electronics Copyright (C) 2014. ALL RIGHTS RESERVED.  
// -------------------------------------------------------------------------------------------------------  
// Project name    : BMS6
// File name       : soc_otp_bist_mem_test.sv
// Description     : Testcase soc_otp_bist_mem_test     
// -------------------------------------------------------------------------------------------------------  
// Revision History:  
// -------------------------------------------------------------------------------------------------------  
// Revision       Date(dd-mm-yyyy)     Author                       Description  
// -------------------------------------------------------------------------------------------------------  
//   1.0          14-08-2024          pfwang@nanochap.com           Initial version created in BAF4
//   2.0          20-10-2024          ddang@nanochap.com            Cloned to use for BMS6
//   3.0          24-12-2024          zhyu@nanochap.com            Cloned to use for BMS6 
// -------------------------------------------------------------------------------------------------------  
//========================================================================================================

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_otp_bist_mem_test
`define TESTCFG soc_otp_bist_mem_test_cfg

class `TESTCFG extends soc_base_test_cfg;

  `nnc_object_utils(`TESTCFG)

  // ===============================================
  // Adding your new varialbles in config test
  // -----------------------------------------------

  rand logic [7:0] wr_data[256];
  rand int         no_of_bytes; 
  rand logic [7:0] reg_addr;
  rand logic [7:0] pads;
  rand logic [7:0] mask;
  rand logic [7:0] expected_data;
  rand logic [7:0] flash_wdata[512];
    
  logic [7:0]      rd_data[256];
  logic [7:0]      rd_data_2[];

  logic [7:0]      save_data[256]; 
   
  logic [7:0]      flash_rdata[1024];  
  logic [7:0]      bad_addr;  

  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_otp_bist_mem_test_cfg");
    super.new(name);
    
  endfunction: new

  // ===============================================
  // Adding constraints of randomization
  // -----------------------------------------------

  // testmode_sel[1:0] : 00-Normal mode, 01: Scanmode, 10: BIST mode, 11 atm0/1/2/3/4
  constraint c_testmode_sel { soft testmode_sel == 2'b00; }

  // spimode_sel[1:0] :  
  constraint c_spimode_sel { spimode_sel == 2'b00; }

  // No of bytes in a burst
  constraint c_no_of_bytes { soft no_of_bytes == 2; }

  // pads values
  constraint c_pads        { soft pads == 8'h00; }

  // mask values
  constraint c_mask        { soft mask == 8'hff; }

  constraint c_flash_wdata { foreach(flash_wdata[i]) flash_wdata[i] != 8'hff; }
  
  constraint c_io_model_check_off { io_model_check_off == 1'b1; }  

  // -----------------------------------------------
  // End of adding constraints of randomization
  // ===============================================

endclass : `TESTCFG

// ===============================================
// Main Testcase is defined
// -----------------------------------------------
class `TESTNAME extends soc_base_test;
   
  `nnc_component_utils(`TESTNAME)

  `TESTCFG top_test_cfg;

  // -----------------------------------------
  // Declare the new function 
  // -----------------------------------------
  function new(string name, nnc_component parent);
    super.new(name, parent);
  endfunction

  // -----------------------------------------
  // Declare the build_phase function 
  // -----------------------------------------
  virtual function void build_phase(nnc_phase phase);
    super.build_phase(phase);
    `nnc_top.set_timeout(2s/1ns);
    top_test_cfg = `TESTCFG::type_id::create("top_test_cfg", this);
  endfunction

  // -----------------------------------------
  // Declare the pre_reset_phase task 
  // -----------------------------------------
  virtual task pre_reset_phase(nnc_phase phase);
    phase.raise_objection(this);

    super.pre_reset_phase(phase);
    assert(top_test_cfg.randomize() with{otp_program_en ==1;});    
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;

    `DUT_IF.spimode_sel = top_test_cfg.spimode_sel;

    `DUT_IF.otp_program_en = top_test_cfg.otp_program_en;
    `DUT_IF.otp_vpp_delay = top_test_cfg.otp_vpp_delay;
    // -------------------
    // Scoreboard enables
    // -------------------
    //`SPI_SCB_EN = 1'b0;    
    // `FLASH_SCOREBOARD_EN = 1;
    // `SPIM_SCOREBOARD_EN = 1;
    // `ANALOG_SCOREBOARD_EN = 1;
    // `IMEAS_SCOREBOARD_EN = 1;
    // `CLKRST_SCOREBOARD_EN = 1;

    phase.drop_objection(this);
  endtask : pre_reset_phase

  // -----------------------------------------
  // Declare the main_phase task of your test
  // -----------------------------------------
  virtual task main_phase(uvm_phase phase);
    phase.raise_objection(this);

    `nnc_info("SOC_TEST", "soc_otp_bist_mem_test start", UVM_LOW)
    // ==================================================================================
    // Please add your code of your test here
    // ---------------------------------------------------------------------------------- 
    // --------------------------------------------------------
    `nnc_info("SOC_TEST", "soc_otp_bist_mem_test end now", UVM_LOW)

    check_flash_with_rnd_reload(); 

    
    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ==================================================================================
 
    phase.drop_objection(this);
  endtask: main_phase

  task check_flash_with_rnd_reload();
`ifndef MIX_SIM_EN
    `DUT_IF.io_model_check_off = 1;                       

//    // spi wr cmd
//    #2ms;
//    `WR_NORMAL_REG(`SOC_OTP_UNLOCK_REG, 8'b01010_100, top_test_cfg.pads); // flash_wr-bit [2] 
//    #5ms;
//    assert(top_test_cfg.randomize()  with { reg_addr == `SOC_OTP_MEM_DATA_REG; no_of_bytes == 1;});
//    `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
//
//    #2ms;     
//    `WR_NORMAL_REG(`SOC_OTP_UNLOCK_REG, 8'b01010_010, top_test_cfg.pads); // flash_wr-bit [1] 

    assert(top_test_cfg.randomize() );
    top_test_cfg.flash_wdata.rand_mode(0);

    for(int i=0; i<16; i++) begin
      //`WR_NORMAL_REG(`SOC_OTP_ADDR01_REG, 8'b0, top_test_cfg.pads);        
      `WR_NORMAL_REG(`SOC_OTP_ADDR_REG, i, top_test_cfg.pads);
      `WR_NORMAL_REG(`SOC_OTP_DATA_REG, top_test_cfg.flash_wdata[i], top_test_cfg.pads);
      //#5ms;
      `WR_NORMAL_REG(`SOC_OTP_UNLOCK_REG, 8'b01010_011,top_test_cfg.pads);
      do begin
        `RD_NORMAL_REG(`SOC_OTP_UNLOCK_REG,top_test_cfg.pads,top_test_cfg.rd_data[0]);
        `nnc_info("SOC_TEST", $sformatf("rd_data %b!!!", top_test_cfg.rd_data[0]), NNC_LOW)
      end while (top_test_cfg.rd_data[0][0] === 1);
      #100us;  //wait for pgm low
    end

    //`WR_NORMAL_REG(`SOC_OTP_UNLOCK_REG, 8'b01010_000,top_test_cfg.pads);
    
    for(int i=16; i<112; i++) begin
      //`WR_NORMAL_REG(`SOC_OTP_ADDR01_REG, 8'b0, top_test_cfg.pads);        
      `WR_NORMAL_REG(`SOC_OTP_ADDR_REG, i, top_test_cfg.pads);
      `WR_NORMAL_REG(`SOC_OTP_DATA_REG, top_test_cfg.flash_wdata[i], top_test_cfg.pads);
       //#5ms; //09/07/2025 commented by supriya
      `WR_NORMAL_REG(`SOC_OTP_UNLOCK_REG, 8'b01010_011,top_test_cfg.pads);
      do begin
        `RD_NORMAL_REG(`SOC_OTP_UNLOCK_REG,top_test_cfg.pads,top_test_cfg.rd_data[0]);
        `nnc_info("SOC_TEST", $sformatf("rd_data %b!!!", top_test_cfg.rd_data[0]), NNC_LOW)
      end while (top_test_cfg.rd_data[0][0] === 1); //09/07/2025 updated by supriya to wait for unlock clear
      #100us;  //wait for pgm low
      //#2ms;  //09/07/2025 added by supriya
    end

    `nnc_info("SOC_TEST", "Shutting down the chip", NNC_LOW)

    force `ANA_TOP.PMU_SW.CHIP_EN = 0;
    wait(`SOC_TB.VDD_DIG === 0);

    // ------------------------------------------------------------------------------------------------------------
    // Enter bist mode
    // ------------------------------------------------------------------------------------------------------------
    #100000ns;   
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b10;})
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;

    // ------------------------------------------------------------------------------------------------------------
    // Power on the chip again
    // ------------------------------------------------------------------------------------------------------------
    #100000ns
    `nnc_info("SOC_TEST", "Power ON the chip", NNC_LOW)
    force `ANA_TOP.PMU_SW.CHIP_EN = 1;
    wait(`SOC_TB.VDD_DIG === 1);
    #1000us;

    `uvm_info("", "[FLASH BIST MASTER][0] Sending Reset Command to Flash", UVM_LOW);
    `BISTM_RESET;  
    `uvm_info("", "[FLASH BIST MASTER] Complete successully this phase", UVM_LOW);   
             
    `nnc_info("SOC_TEST", "Read trim regs", NNC_LOW)    
    //Read MEM
    //top_test_cfg.rd_data =new[256]; 

    for(int i=16; i<128; i++) begin
        `BISTM_MARGIN_SINGLE_READ(top_test_cfg.OTP_SEL, 2'b10, i, top_test_cfg.rd_data[i-16]); // marge=0 review
        `nnc_info("SOC_TEST", $sformatf("addr[%d] : rd_data %8h!!!",i, top_test_cfg.rd_data[i]), NNC_LOW) 
    end  
    
    `nnc_info("SOC_TEST", "Compare trim regs", NNC_LOW)
    for(int i=0; i<112 ; i++) begin
        if(top_test_cfg.flash_wdata[i][7:0] !== top_test_cfg.rd_data[i][7:0]) `nnc_error("SOC_TEST", $sformatf("addr[%d] : flash_wdata %8h !== rd_data %8h!!!",i, top_test_cfg.flash_wdata[i][7:0], top_test_cfg.rd_data[i][7:0]))
        else `nnc_info("SOC_TEST", $sformatf("addr[%d] : flash_wdata %8h === rd_data %8h!!!",i, top_test_cfg.flash_wdata[i][7:0], top_test_cfg.rd_data[i][7:0]), NNC_LOW) 
    end 

    for(int i=0; i<16; i++) begin
        `BISTM_MARGIN_SINGLE_READ(top_test_cfg.OTP_SEL, 2'b10, i, top_test_cfg.rd_data[i]); // marge=0 review
        `nnc_info("SOC_TEST", $sformatf("addr[%d] : rd_data %8h!!!",i, top_test_cfg.rd_data[i]), NNC_LOW) 
    end  
    
    `nnc_info("SOC_TEST", "Compare trim regs", NNC_LOW)
    for(int i=0; i<16 ; i++) begin
        if(top_test_cfg.rd_data[i][7:0] !== 8'h0) `nnc_error("SOC_TEST", $sformatf("addr[%d] : flash_wdata %8h !== rd_data %8h!!!",i, top_test_cfg.flash_wdata[i][7:0], top_test_cfg.rd_data[i][7:0]))
        else `nnc_info("SOC_TEST", $sformatf("addr[%d] : flash_wdata %8h === rd_data %8h!!!",i, top_test_cfg.flash_wdata[i][7:0], top_test_cfg.rd_data[i][7:0]), NNC_LOW) 
    end 
`endif
                 
  endtask
  // ------------------------------
  // Declare the report_phase task
  // ------------------------------
  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction

endclass : `TESTNAME
