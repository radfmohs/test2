/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_otp_unlock_reload_test.sv                                                   
// Project	: Nanochap ENS1p4                                  		        
// Description	: Write trim registers using unlock and reload function                                             
// Designer	: pfwang@nanochap.com                                                                 
// Date		: 18-04-2024                                                                     
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_otp_unlock_reload_test
`define TESTCFG soc_otp_unlock_reload_test_cfg

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
  logic [7:0]      rd_data[];
  logic [7:0] save_trim_wdata[11] = '{default : 8'h0};
  logic [7:0] prev_wdata[11];
  logic [7:0] cur_wdata[11];   
  logic [7:0] trim_wdata[11] = '{default : 8'h0};
  rand logic [7:0] otp_wdata[512];
  logic [7:0]      temp_otp_wdata[512];
  rand logic [8:0] otp_data_addr;
  logic [8:0] otp_addr[512];
  logic [7:0] otp_prev_data[512] = '{default : 8'h0};
  logic [7:0] otp_cur_data[512]= '{default : 8'h0};
  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_otp_unlock_reload_test_cfg");
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


 // Enable/Disable to program OTP
  constraint c_otp_program_en           { otp_program_en == 1'b1;}

  ////
  //constraint c_ext_clk_en  { ext_clk_en == 1;}
 
  ////
  //// Select PCLK DIV from HFOSC
  //constraint c_pclk_sel   {pclk_sel inside {[0:0]};} 

  //// Set frequency for SPI (unit of 1Khz)
  //constraint c_spi_sclk_freq          { solve spi_sclk_jitter before spi_sclk_freq; spi_sclk_freq inside {[25:25]};} // 25Khz to 16Mhz

  //constraint c_save_trim_wdata  { save_trim_wdata[0] == (data[0]/*[4:0]*/ /*[4:0]*/);
  //                                save_trim_wdata[1] == (data[1]/*[6:0]*/ /*[6:0]*/);
  //                                save_trim_wdata[2] == (data[2]/*[4:0]*/ /*[4:0]*/);
  //                                save_trim_wdata[3] == (data[3]/*[6:0]*/ /*[6:0]*/);
  //                                save_trim_wdata[4] == (data[4]/*[1:0]*/ /*[1:0]*/);
  //                                save_trim_wdata[5] == (data[5]/*[1:0]*/ /*[1:0]*/);
  //                                /*save_trim_wdata[6] == (trim_wdata[6]);
  //                                save_trim_wdata[7] == (trim_wdata[7]);
  //                                save_trim_wdata[8] == (trim_wdata[8]);*/}

  //constraint c_trim_wdata {foreach (trim_wdata[i]) trim_wdata[i] == save_trim_wdata[i];};

  //constraint c_trim_wdata1 {solve trim_wdata before save_trim_wdata;}

  //constraint c_data1      {solve data before save_trim_wdata;}
                                  


  //constraint c_pmu_reg  { reg_addr == `SOC_CONFIG1_REG -> data[8'h1b][3:0] != 4'hb;}  //disable otp_dpslp 

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
   //real wr_prgm_delay;
   //bit wait_for_unlock_clear;
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
    uvm_top.set_timeout(2s);
    top_test_cfg = `TESTCFG::type_id::create("top_test_cfg", this);
  endfunction

  // -----------------------------------------
  // Declare the pre_reset_phase task 
  // -----------------------------------------
  virtual task pre_reset_phase(nnc_phase phase);
    phase.raise_objection(this);

    super.pre_reset_phase(phase);

    assert(top_test_cfg.randomize() with {altf_sel == 0;});

    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;

    `DUT_IF.spimode_sel = top_test_cfg.spimode_sel;

    `DUT_IF.altf_sel = top_test_cfg.altf_sel;

    `DUT_IF.otp_program_en = top_test_cfg.otp_program_en;

    `DUT_IF.otp_vpp_delay = top_test_cfg.otp_vpp_delay;

    //// Select internal/external clock sources
    //`DUT_IF.ext_clk_en = top_test_cfg.ext_clk_en;			// 1: external EXT_300KHZ and EXT_32KHZ will be driven to SOC from model

    //// Set PCLK Clocks
    //`DUT_IF.pclk_sel = top_test_cfg.pclk_sel;

    //// Set SCLK clock
    //`DUT_IF.spi_sclk_freq = top_test_cfg.spi_sclk_freq;

    for (int j=8'h0C;j <= 8'h14; j++) 
        `DUT_IF.reg_normal[j][2] = 0;  //to disable SPI Monitor checking for these TRIM regsiters because test use unlock & reload function. And SPI monitor only compares the data read and written through SPI,

    // -------------------
    // Scoreboard enables
    // -------------------
    `SPI_SCB_EN = 1'b1;    
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
  virtual task main_phase(nnc_phase phase);
    phase.raise_objection(this);

    `nnc_info("SOC_TEST", "soc_otp_unlock_reload_test start", UVM_LOW)

    // ==================================================================================
    // Please add your code of your test here
    // ---------------------------------------------------------------------------------- 
`ifndef MIX_SIM_EN   
    top_test_cfg.rd_data = new[8];
    $display("===============================================");
    $display("Step 1: Reload invaild with failed trim_tag");
    $display("===============================================");
//Step 1: Reload invaild with failed trim_tag
    ////set spi_reg
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_PMU_REG; no_of_bytes == 8'h2; data[1][3] != 1'b1; data[1][1] != 1'b1;});
    //`DUT_IF.pclk_sel = top_test_cfg.data[8'h0][2:0];
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);           
                
    //set mismatch trim_tag 7A
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_TRIM_0_REG; no_of_bytes == 1; data[0] == 8'h1a;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
            
    //set trim_reg
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_TRIM_1_REG; no_of_bytes == 8; foreach(data[i]) data[i]>8'h0;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
           
    foreach (top_test_cfg.save_trim_wdata[i]) if(i<8) top_test_cfg.save_trim_wdata[i] = top_test_cfg.data[7-i];

    for (int i=0; i<8 ; i++) begin
      `nnc_info("SOC_TEST", $sformatf("save_trim_wdata %8h ", top_test_cfg.save_trim_wdata[i]), UVM_LOW) 
    end

    //set unlock bit0:unlock
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_UNLOCK_REG; no_of_bytes == 1; data[0] == 8'b10101_001;});

    `nnc_info("SOC_TEST", $sformatf("Set UNLOCK bit ADDR: %8h, DATA: %8h", top_test_cfg.reg_addr, top_test_cfg.data[0]), UVM_LOW)
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
 
    // ------------------------------------------------------------------------------- 
    // -------------------------------------------------------------------------------
    //set OTP_VPP_EN to 1(connect to IOPAD[8], boost VPP to 7.5V in 20us
    //`DUT_IF.otp_program_en = top_test_cfg.otp_program_en;
    //`DUT_IF.otp_vpp_delay = top_test_cfg.otp_vpp_delay;
    // ------------------------------------------------------------------------------- 
    // -------------------------------------------------------------------------------

    // ------------------------------------------------------------------------------- 
    // -------------------------------------------------------------------------------
    //wait for OTP_VPP_EN=0 
    @(negedge soc_top_tb.VPP_EN); //minimum 20us require VPP to go LOW level(VDD level 1.8V)

   
    //#20ms;
    //set unlock bit0:unlock
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_UNLOCK_REG; no_of_bytes == 1; data[0] == 8'b10101_000;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    // -------------------------------------------------------------------------------
    // -------------------------------------------------------------------------------
    //wait for sometimeb before power off the chip
    #50us;
    // -------------------------------------------------------------------------------
    // -------------------------------------------------------------------------------
    `nnc_info("SOC_TEST", "Requesting the RESET", UVM_LOW)
    force `ANA_TOP.PMU_SW.CHIP_EN = 1'b0; //`SOC_TOP.A2D_SW_POWER_POR = 1'b0;            
    #10ms;
    force `ANA_TOP.PMU_SW.CHIP_EN = 1'b1;
     wait(soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_reset_ctrl.otp_rstn ===1'b1); //release `SOC_TOP.A2D_SW_POWER_POR;
    //force `SOC_TOP.A2D_SW_POWER_POR = 1'b1;       
    #1000us; 
      
    
    //read trim_reg
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_TRIM_1_REG; no_of_bytes == 8; });
    `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data[0:7]);


    if(top_test_cfg.save_trim_wdata[0:7] === top_test_cfg.rd_data[0:7]) `nnc_error("SOC_TEST", "save_trim_wdata == rd_data !!!")

//Step 2 : Unlock invaild with no operate for unlock reg           
    $display("===============================================");
    $display("Step 2: Unlock invaild with no operate for unlock reg");
    $display("===============================================");
    //set trim_reg
    //top_test_cfg.save_trim_wdata.rand_mode(1);
    //top_test_cfg.c_save_trim_wdata.constraint_mode(1);
    //set mismatch trim_flag
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_TRIM_0_REG; no_of_bytes == 1; data[0] == 8'h5a;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_TRIM_1_REG; no_of_bytes == 8; foreach(data[i]) data[i]>8'h0;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);    
        
    //set unlock bit0:unlock
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_UNLOCK_REG; no_of_bytes == 1; data[0] == 8'b0;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
   
    #20ms;
    //reset
    `nnc_info("SOC_TEST", "Requesting the RESET", UVM_LOW)
     force `ANA_TOP.PMU_SW.CHIP_EN = 1'b0; //force `SOC_TOP.A2D_SW_POWER_POR = 1'b0;                 
    #10ms;
    force `ANA_TOP.PMU_SW.CHIP_EN = 1'b1;
     wait(soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_reset_ctrl.otp_rstn ===1'b1); //release `SOC_TOP.A2D_SW_POWER_POR; //release `SOC_TOP.A2D_SW_POWER_POR;
    //force `SOC_TOP.A2D_SW_POWER_POR = 1'b1;
    #1000us; 

    //if(top_test_cfg.rd_data[0][7] !== 1'b1) `nnc_error("SOC_TEST", "trim tag is vaild!!!");
    top_test_cfg.rd_data = new[8];
    //read trim_reg
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_TRIM_1_REG; no_of_bytes == 8; });
    `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data[0:7]);

    if(top_test_cfg.save_trim_wdata[0:7] === top_test_cfg.rd_data[0:7]) `nnc_error("SOC_TEST", "save_trim_wdata == rd_data !!!")
        
    //Step 3 : Unlock vaild with trim_tag 5A and unlock_key 10101
    $display("===========================================================");
    $display("Step 3: Unlock vaild with trim_tag 5A and unlock_key 10101");
    $display("===========================================================");
    //set PMU_REG0, set otp_dpstb_en=0, PMU_REG0[3]=0, to disable otp_clk gatin, by default it's disabled 
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_PMU_REG; no_of_bytes == 8'h1; data[0] == 8'h0000_0001;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //set mismatch trim_flag
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_TRIM_0_REG; no_of_bytes == 1; data[0] == 8'h5a;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
   `nnc_info("SOC_TEST", $sformatf("TRIM_TAG=%8h ", top_test_cfg.data[0]), UVM_LOW) 

    //set trim_reg
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_TRIM_1_REG; no_of_bytes == 8;foreach(data[i]) data[i]>8'h0;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);   
     foreach (top_test_cfg.save_trim_wdata[i]) if(i<8) top_test_cfg.save_trim_wdata[i] |= top_test_cfg.data[7-i];

    for(int i=0; i<8 ; i++) begin
        `nnc_info("SOC_TEST", $sformatf("save_trim_wdata %8h ", top_test_cfg.save_trim_wdata[i]), UVM_LOW) 
    end
    
    //set unlock   bit0:unlock
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_UNLOCK_REG; no_of_bytes == 1; data[0] == 8'b10101_001;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    // ------------------------------------------------------------------------------- 
    // -------------------------------------------------------------------------------
    //set OTP_VPP_EN to 1(connect to IOPAD[8], boost VPP to 7.5V in 20us
    //`DUT_IF.otp_program_en = top_test_cfg.otp_program_en;
   // `DUT_IF.otp_vpp_delay = top_test_cfg.otp_vpp_delay;
    // ------------------------------------------------------------------------------- 
    // -------------------------------------------------------------------------------

    // ------------------------------------------------------------------------------- 
    // -------------------------------------------------------------------------------
    //wait for OTP_VPP_EN=0 
    //wait(`SOC_TB.VPP_EN === 1'b0);  
    @(negedge soc_top_tb.VPP_EN); //minimum 20us require VPP to go LOW level(VDD level 1.8V)
   
    // To program each location require (1.31*9 +0.1)ms (minimum time require to program one location) 
    // #25ms;    
         
    //set unlock  bit0:unlock
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_UNLOCK_REG; no_of_bytes == 1; data[0] == 8'b10101_000;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

     #100000ns;    
    force `ANA_TOP.PMU_SW.CHIP_EN = 1'b0; //force `SOC_TOP.A2D_SW_POWER_POR = 1'b0; 
    assert(top_test_cfg.randomize() with { testmode_sel == 2'b00;}) 
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;           
    #10ms;
    force `ANA_TOP.PMU_SW.CHIP_EN = 1'b1;
     wait(soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_reset_ctrl.otp_rstn ===1'b1); //release `SOC_TOP.A2D_SW_POWER_POR; 

    do begin
       assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_DEBUG_1_REG; no_of_bytes == 1;});
       `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
       `nnc_info("SOC_TEST", $sformatf("reload_done =%h",top_test_cfg.rd_data[0][5]), UVM_LOW)
       #1000ns;  
    end while (top_test_cfg.rd_data[0][5] == 1'b0);

    //set PMU_REG0, set otp_dpstb_en=1, PMU_REG0[3]=0, to disable otp_clk gating    
   `nnc_info("SOC_TEST", $sformatf("WRITE to PMU_REG0 to disable otp clk gating "), UVM_LOW) 
   `WR_NORMAL_REG(`SOC_PMU_REG, 8'b0000_1001, 8'h00);
   `RD_BURST_NORMAL_REG(`SOC_PMU_REG, 1, top_test_cfg.rd_data);
    if(top_test_cfg.rd_data[0] !== 8'b0000_1001) `nnc_error("SOC_TEST", $sformatf("READ PMU_REG0 =%h, Expected Data=%h!!!", top_test_cfg.rd_data[0],  8'b0000_1001))
    else `nnc_info("SOC_TEST", $sformatf("READ PMU_REG0 =%h ", top_test_cfg.rd_data[0]), UVM_LOW) 

    top_test_cfg.rd_data = new[8];
    //read trim_reg
    `nnc_info("SOC_TEST", $sformatf("READ SPI TRIM DATA"), UVM_LOW)
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_TRIM_1_REG; no_of_bytes == 8; });
    `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data[0:7]);
     #10ms;    
    //if(top_test_cfg.save_trim_wdata[0:7] !== top_test_cfg.rd_data[0:7]) `nnc_error("SOC_TEST", "save_trim_wdata !== rd_data !!!")
    for(int i=0; i<8 ; i++) begin
        if(top_test_cfg.save_trim_wdata[i] !== top_test_cfg.rd_data[7-i]) `nnc_error("SOC_TEST", $sformatf("save_trim_wdata %8h !== rd_data %8h!!!", top_test_cfg.save_trim_wdata[i], top_test_cfg.rd_data[7-i]))
        else `nnc_info("SOC_TEST", $sformatf("save_trim_wdata %8h === rd_data %8h!!!", top_test_cfg.save_trim_wdata[i], top_test_cfg.rd_data[7-i]), UVM_LOW) 
    end

//Step 4 : Only unlock check reload trim
    $display("===========================================================");
    $display("Step 4: Only unlock check reload trim");
    $display("===========================================================");
    ////set spi_reg
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_PMU_REG; no_of_bytes == 8'h2; data[1][3] != 1'b1; data[1][1] != 1'b1;});
    //`DUT_IF.pclk_sel = top_test_cfg.data[8'h0][2:0];
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    `nnc_info("SOC_TEST", $sformatf("STEP 4"), UVM_LOW) 

    disable_otp_clk_gating();

    //set trim_flag
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_TRIM_0_REG; no_of_bytes == 1; data[0] == 8'h5a;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //set unlock bit0:unlock
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_UNLOCK_REG; no_of_bytes == 1; data[0] == 8'b10101_001;}); 
   `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    #25ms;

    //set unlock bit0:unlock
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_UNLOCK_REG; no_of_bytes == 1; data[0] == 8'b10101_000;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //reset
    `nnc_info("SOC_TEST", "Requesting the RESET", UVM_LOW)
    //force soc_top_tb.iopad_resetn = 1'b0;
    //
`ifndef MIX_SIM_EN
    force `ANA_TOP.PMU_SW.CHIP_EN = 1'b0;    
    #1ms; //#100000ns
    force `ANA_TOP.PMU_SW.CHIP_EN = 1'b1;    
`endif

   // #1000us;
    wait(soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_reset_ctrl.otp_rstn ===1'b1); //#1000us;    // instead of delay wait for otp rstn
         
  //wait reload done
   `nnc_info("SOC_TEST", "wait for reload_done", UVM_LOW)
   do begin
       assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_DEBUG_1_REG; no_of_bytes == 1;});
       `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
       #1000ns;
   end while (top_test_cfg.rd_data[0][5] == 1'b0);
   `nnc_info("SOC_TEST", "relaod_done ==1!!!", UVM_LOW)

    enable_otp_clk_gating();

    top_test_cfg.rd_data = new[8];
    //read trim_reg
    `nnc_info("SOC_TEST", $sformatf("READ SPI TRIM DATA"), UVM_LOW)    
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_TRIM_1_REG; no_of_bytes == 8; });
    `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data[0:7]);

    //if(top_test_cfg.save_trim_wdata[0:7] !== top_test_cfg.rd_data[0:7]) `nnc_error("SOC_TEST", "save_trim_wdata !== rd_data !!!")
    for(int i=0; i<8 ; i++) begin
        if(top_test_cfg.save_trim_wdata[i] !== top_test_cfg.rd_data[7-i]) `nnc_error("SOC_TEST", $sformatf("save_trim_wdata %8b !== rd_data %8b!!!", top_test_cfg.save_trim_wdata[i], top_test_cfg.rd_data[7-i]))
        else `nnc_info("SOC_TEST", $sformatf("save_trim_wdata %8b === rd_data %8b!!!", top_test_cfg.save_trim_wdata[i], top_test_cfg.rd_data[7-i]), UVM_LOW) 
    end

// Step 5 : 2 times unlock because this test copy from ENS1P4 , in ENs1p4 unlock repeat will case error
    $display("===========================================================");
    $display("Step 5:  2 times unlock because this test copy from ENS1P4, unlock repeat will case error");
    $display("===========================================================");    

    disable_otp_clk_gating();

    //set unlock bit0:unlock
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_UNLOCK_REG; no_of_bytes == 1; data[0] == 8'b10101_001;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    #25ms;

    //set unlock bit0:unlock
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_UNLOCK_REG; no_of_bytes == 1; data[0] == 8'b10101_001;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //wait program done
    //wait_wr_working_high();
    //do begin
    //    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_DEBUG_2_REG; no_of_bytes == 1;});
    //    `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
    //    `nnc_info("SOC_TEST", $sformatf("wr_working= %h", top_test_cfg.rd_data[0][1]), UVM_LOW) //wait for wr_working=0 , till programs completes
    //end while (top_test_cfg.rd_data[0][1] !== 1'b0);
    #25ms;
    //reset
    `nnc_info("SOC_TEST", "Requesting the RESET", UVM_LOW)
`ifndef MIX_SIM_EN
    force `ANA_TOP.PMU_SW.CHIP_EN = 1'b0;    
    #1ms; //#100000ns
    force `ANA_TOP.PMU_SW.CHIP_EN = 1'b1;    
`endif

    //#1000us;
    wait(soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_reset_ctrl.otp_rstn ===1'b1); //#1000us;    // instead of delay wait for otp rstn
 
    //wait reload done
    do begin
        assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_DEBUG_1_REG; no_of_bytes == 1;});
        `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
        #1000ns;
    end while (top_test_cfg.rd_data[0][5] == 1'b0);

    enable_otp_clk_gating();

    top_test_cfg.rd_data = new[8];
    //read trim_reg
    `nnc_info("SOC_TEST", $sformatf("READ SPI TRIM DATA"), UVM_LOW)    
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_TRIM_1_REG; no_of_bytes == 8; });
    `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data[0:7]);

    for(int i=0; i<8 ; i++) begin
        if(top_test_cfg.save_trim_wdata[i] !== top_test_cfg.rd_data[7-i]) `nnc_error("SOC_TEST", $sformatf("save_trim_wdata %8b !== rd_data %8b!!!", top_test_cfg.save_trim_wdata[i], top_test_cfg.rd_data[7-i]))
        else `nnc_info("SOC_TEST", $sformatf("save_trim_wdata %8b === rd_data %8b!!!", top_test_cfg.save_trim_wdata[i], top_test_cfg.rd_data[7-i]), UVM_LOW) 
    end

    #100000ns;

    // --------------------------------------------------------
    // 20/05/2025 added by supriya 
    // --------------------------------------------------------
     `nnc_info("SOC_TEST", "Trim Write function for otp", UVM_LOW)
      disable_otp_clk_gating();
      write_rd_trimregs_to_otp(2'd1); //write_rd_trimregs_to_otp(bit wait_for_unlock_clear);
      read_and_compare_trim_reg_data(top_test_cfg.prev_wdata, top_test_cfg.save_trim_wdata);  
      #1us;
           
      `nnc_info("SOC_TEST", "Trim Write function for otp", UVM_LOW) 
      // To program each location require (1.31*9 +0.1)ms (minimum time require to program one location)
      disable_otp_clk_gating(); 
      write_rd_trimregs_to_otp(2'd0);  //write_rd_trimregs_to_otp(real wr_prgm_delay, bit wait_for_unlock_clear);
      read_and_compare_trim_reg_data(top_test_cfg.cur_wdata, top_test_cfg.save_trim_wdata); 
      #1us;

      `nnc_info("SOC_TEST", "Trim Write function for otp", UVM_LOW)
      `nnc_info("SOC_TEST", "wait for wr_working HIGH to complete wr programming", UVM_LOW)
      // To program each location require (1.31*9 +0.1)ms (minimum time require to program one location) 
      disable_otp_clk_gating();
      write_rd_trimregs_to_otp(2'd2);  //write_rd_trimregs_to_otp(real wr_prgm_delay, bit wait_for_unlock_clear);
      read_and_compare_trim_reg_data(top_test_cfg.cur_wdata, top_test_cfg.save_trim_wdata); 
      #1us;
  
      `nnc_info("SOC_TEST", "Trim Write function for shadow register", UVM_LOW)
      disable_otp_clk_gating();
      write_trimregs_to_shadow_regs();
      enable_otp_clk_gating();
      read_and_compare_trim_shadowreg_data(top_test_cfg.save_trim_wdata);
      #1us;  
 
      `nnc_info("SOC_TEST", "Random SPI Write function for OTP", UVM_LOW)
      disable_otp_clk_gating();
      random_spi_wr_rd_otp(2'd0);    //fixed delay used to complete OTP programming
      #1us;
 
      `nnc_info("SOC_TEST", "Random SPI Write function for OTP", UVM_LOW)
      random_spi_wr_rd_otp(2'd1);  
      #1us;

      `nnc_info("SOC_TEST", "Random SPI Write function for OTP", UVM_LOW)
      random_spi_wr_rd_otp(2'd2);  
      #1us; 
  
  
    // --------------------------------------------------------
    // 20/05/2025 ends by supriya 
    // --------------------------------------------------------
`endif

    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    #10000ns;
    `nnc_info("SOC_TEST", "soc_otp_unlock_reload_test end now", UVM_LOW)

    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ==================================================================================

    phase.drop_objection(this);
  endtask: main_phase

  // ==================================================================================
  // user defined tasks
  // ==================================================================================
  task write_trimregs_to_shadow_regs;
    //Feature : Trim Write function for shadow register
    //trim_tag 5A, unlock_key 10101, spi_wr=1 

   ////set spi_reg
   // assert(top_test_cfg.randomize() with { reg_addr == `SOC_PMU_REG; no_of_bytes == 8'h2; data[1][3] != 1'b1; data[1][1] != 1'b1;});
   // `DUT_IF.pclk_sel = top_test_cfg.data[8'h0][2:0];
   // `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //1.set valid trim_tag =0x5A
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_TRIM_0_REG; no_of_bytes == 1; data[0] == 8'h5a;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //2. Data ready: write the data to spi trim reg
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_TRIM_1_REG; no_of_bytes == 8;foreach(data[i]) data[i]>8'h0;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);   
    //foreach (top_test_cfg.save_trim_wdata[i]) if(i<8) top_test_cfg.save_trim_wdata[i] &= top_test_cfg.data[7-i];
    foreach (top_test_cfg.save_trim_wdata[i]) if(i<8) top_test_cfg.save_trim_wdata[i] = top_test_cfg.data[7-i];

    for(int i=0; i<8 ; i++) begin
        `nnc_info("SOC_TEST", $sformatf("save_trim_wdata %8h ", top_test_cfg.save_trim_wdata[i]), UVM_LOW) 
    end
    
    //3.Write unlock register to set KEY-WORD(5'h10101), (keyword is valid) 
    //4. Write spi_wr(bit[1] high. 
     assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_UNLOCK_REG; no_of_bytes == 1; data[0] == 8'b10101_010;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

     //#100us;

    
    //4. Check whether the written data and read data are consistent.
    // top_test_cfg.rd_data = new[8];
    ////read trim_reg
    //`nnc_info("SOC_TEST", $sformatf("READ SPI TRIM DATA"), UVM_LOW)
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_TRIM_1_REG; no_of_bytes == 8; });
    //`RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data[0:7]);

    //for(int i=0; i<8 ; i++) begin
    //    if(top_test_cfg.save_trim_wdata[i] !== top_test_cfg.rd_data[7-i]) `nnc_error("SOC_TEST", $sformatf("save_trim_wdata %8h !== rd_data %8h!!!", top_test_cfg.save_trim_wdata[i], top_test_cfg.rd_data[7-i]))
    //    else `nnc_info("SOC_TEST", $sformatf("save_trim_wdata %8h === rd_data %8h!!!", top_test_cfg.save_trim_wdata[i], top_test_cfg.rd_data[7-i]), UVM_LOW) 
    //end

  endtask 

  //=======================================================================================================================
  task random_spi_wr_rd_otp(bit[1:0] wait_for_unlock_clear);
       bit [8:0] addr; 
    //Feature : random spi write for otp
    //trim_tag 5A, unlock_key 010100, spi_wr=0
    //set spi_reg
   // assert(top_test_cfg.randomize() with { reg_addr == `SOC_PMU_REG; no_of_bytes == 8'h2; data[1][3] != 1'b1; data[1][1] != 1'b1;});
   // `DUT_IF.pclk_sel = top_test_cfg.data[8'h0][2:0];
   // `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //1.set valid trim_tag =0x5A
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_TRIM_0_REG; no_of_bytes == 1; data[0] == 8'h5a;});
   `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);


    assert(top_test_cfg.randomize() );
    top_test_cfg.otp_wdata.rand_mode(1);
    //top_test_cfg.otp_data_addr.rand_mode(0);
    top_test_cfg.temp_otp_wdata = top_test_cfg.otp_wdata;
   
    for(addr =16; addr < 17/*256*/ ; addr++) begin
       //top_test_cfg.otp_data_addr = i ;
      `nnc_info("SOC_TEST", $sformatf("otp addr =%h, otp_wdata[%h] = %h, temp_otp_wdata[%h] =%h ", addr, addr, top_test_cfg.otp_wdata[addr], addr, top_test_cfg.temp_otp_wdata[addr]), UVM_LOW) 

      //`WR_NORMAL_REG(`SOC_OTP_ADDR01_REG, {7'b0, addr[8]}, top_test_cfg.pads);        
      `WR_NORMAL_REG(`SOC_OTP_ADDR_REG, addr[7:0], top_test_cfg.pads);

      `WR_NORMAL_REG(`SOC_OTP_DATA_REG, top_test_cfg.temp_otp_wdata[addr], top_test_cfg.pads);


      `WR_NORMAL_REG(`SOC_OTP_UNLOCK_REG, 8'b01010_001,top_test_cfg.pads);

//      if(wait_for_unlock_clear === 2'd0) begin 
//       #1.2ms;
//
//      #100us; //#2ms;  //just extra time window to complete OTP programming before ens2 chip power off
//      end else if(wait_for_unlock_clear === 2'd1) begin
//          `nnc_info("SOC_TEST", "wait until unlock bit clears automatically", UVM_LOW)
//          do begin
//          `RD_NORMAL_REG(`SOC_OTP_UNLOCK_REG,top_test_cfg.pads,top_test_cfg.rd_data[0]);
//          `nnc_info("SOC_TEST", $sformatf("READ UNLOCK bit %h !!!", top_test_cfg.rd_data[0][0]), UVM_LOW) 
//          end while (top_test_cfg.rd_data[0][0] === 1);
//          `nnc_info("SOC_TEST", "unlock bit cleared automatically", UVM_LOW)
//      end
//      else if(wait_for_unlock_clear === 2'd2)begin
//          wait_wr_working_high();
//      end
//
      if(wait_for_unlock_clear === 2'd0) begin 
         //set OTP_VPP_EN to 1(connect to IOPAD[8], boost VPP to 7.5V in 20us
         //`DUT_IF.otp_program_en = top_test_cfg.otp_program_en;
         //`DUT_IF.otp_vpp_delay = top_test_cfg.otp_vpp_delay;  
  
         //wait for OTP_VPP_EN=0 
         @(negedge `SOC_TB.VPP_EN); //wait(`SOC_TB.VPP_EN === 1'b0);   //minimum 20us require VPP to go LOW level(VDD level 1.8V)
    
      end else if(wait_for_unlock_clear === 2'd1) begin
         wait_otp_ip_wr(); //PPROG signal monitor control im OTP IP
      end
      else if(wait_for_unlock_clear === 2'd2)begin
          wait_wr_working_high();
      end

      //wait for sometime before power off the chip
      #50us;
 
      ens2_chip_power_off();
      `nnc_info("SOC_TEST", "ENS2 chip power off", UVM_LOW)

      ens2_chip_power_on();
      `nnc_info("SOC_TEST", "ENS2 chip power on", UVM_LOW)

      //7.wait reload done
      wait_reload_done();
      `nnc_info("SOC_TEST", $sformatf("Wait for reload_done"), UVM_LOW)

      ////8.read back
      //`WR_NORMAL_REG(`SOC_OTP_ADDR01_REG, {7'b0, addr[8]}, top_test_cfg.pads);        
      //`WR_NORMAL_REG(`SOC_OTP_ADDR_REG, addr[7:0], top_test_cfg.pads);

      //`WR_NORMAL_REG(`SOC_OTP_UNLOCK_REG, 8'b01010_100,top_test_cfg.pads);
      ////`nnc_info("SOC_TEST", $sformatf("otp addr =%h, otp_wdata[i] = %h ", i, top_test_cfg.otp_wdata[i]), UVM_LOW)
      //`RD_NORMAL_REG(`SOC_OTP_MEM_DATA_REG,top_test_cfg.pads,top_test_cfg.rd_data[0]); 
      // if(top_test_cfg.otp_wdata[addr] !== top_test_cfg.rd_data[0]) `nnc_error("SOC_TEST", $sformatf("OTP Write Data %8h !== OTP Read Data %8h!!!", top_test_cfg.otp_wdata[addr], top_test_cfg.rd_data[0]))
      // else `nnc_info("SOC_TEST", $sformatf("MATCH!!! OTP Write Data %8h == OTP Read Data %8h!!!", top_test_cfg.otp_wdata[addr], top_test_cfg.rd_data[0]), UVM_LOW)
      `nnc_info("SOC_TEST", $sformatf("otp addr =%h, temp_otp_wdata[%h] = %h ", addr, addr, top_test_cfg.temp_otp_wdata[addr]), UVM_LOW)
       spi_rd_for_randoimze_otp_wr(addr,top_test_cfg.temp_otp_wdata);
                  
    end
     

       
  endtask

  //=======================================================================================================================
  task spi_rd_for_randoimze_otp_wr(bit [8:0] i_addr, logic [7:0] exp_otp_wdata[512] );

    //Feature : random spi write for otp
    //trim_tag 5A, unlock_key 010100, unlock_reg[2]=1

   ////set spi_reg
   // assert(top_test_cfg.randomize() with { reg_addr == `SOC_PMU_REG; no_of_bytes == 8'h2; data[1][3] != 1'b1; data[1][1] != 1'b1;});
   // `DUT_IF.pclk_sel = top_test_cfg.data[8'h0][2:0];
   // `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //1.set valid trim_tag =0x5A
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_TRIM_0_REG; no_of_bytes == 1; data[0] == 8'h5a;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //for(int i=16; i< 17 /*127*/ ; i++) begin

     // `WR_NORMAL_REG(`SOC_OTP_ADDR01_REG, {7'b0,i_addr[8]}, top_test_cfg.pads);        
      `WR_NORMAL_REG(`SOC_OTP_ADDR_REG,  i_addr[7:0], top_test_cfg.pads);


      `WR_NORMAL_REG(`SOC_OTP_UNLOCK_REG, 8'b01010_100,top_test_cfg.pads);
      `nnc_info("SOC_TEST", $sformatf("otp addr =%h, otp_wdata[i] = %h, otp_prev_data =%h ", i_addr, exp_otp_wdata[i_addr], top_test_cfg.otp_prev_data[i_addr]), UVM_LOW) 

      //3.wait for 10 pclk
      repeat(10)begin
      @(posedge `EPROM_TOP.clk);   //soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_otp_ctrl_top.clk);
      end

      `RD_NORMAL_REG(`SOC_OTP_MEM_DATA_REG,top_test_cfg.pads,top_test_cfg.rd_data[0]);

       top_test_cfg.otp_cur_data[i_addr] = (top_test_cfg.otp_prev_data[i_addr] | exp_otp_wdata[i_addr]);
       `nnc_info("SOC_TEST", $sformatf("otp_cur_data =%h", top_test_cfg.otp_cur_data[i_addr]), UVM_LOW) 
 
       if(top_test_cfg.otp_cur_data[i_addr] /*exp_otp_wdata[i_addr]*/ !== top_test_cfg.rd_data[0]) `nnc_error("SOC_TEST", $sformatf(" READ DATA ERROR!!! OTP Write Data %8h !== OTP Read Data %8h!!!", top_test_cfg.otp_cur_data[i_addr] /*exp_otp_wdata[i_addr]*/, top_test_cfg.rd_data[0]))
       else `nnc_info("SOC_TEST", $sformatf("READ DATA MATCH!!! OTP Write Data %8h == OTP Read Data %8h!!!", top_test_cfg.otp_cur_data[i_addr] /*exp_otp_wdata[i_addr]*/, top_test_cfg.rd_data[0]), UVM_LOW)
       top_test_cfg.otp_prev_data[i_addr] =  top_test_cfg.rd_data[0];
    //end
   
  endtask

task write_rd_trimregs_to_otp(bit[1:0] wait_for_unlock_clear);

     `nnc_info("SOC_TEST", $sformatf("wait_for_unlock_clear=%h!!!", wait_for_unlock_clear ), UVM_LOW) 
    ////set spi_reg
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_PMU_REG; no_of_bytes == 8'h2; data[1][3] != 1'b1; data[1][1] != 1'b1;});
    //`DUT_IF.pclk_sel = top_test_cfg.data[8'h0][2:0];
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    //1.set valid tag
    set_valid_tag(); 
    //2.set trim_reg
    spi_wr_to_trim_reg();    
    //3.set unlock bit0:unlock
    set_unlock_bit();
  
    //4.
//    if(wait_for_unlock_clear === 2'b01) begin
//      `nnc_info("SOC_TEST", "wait until unlock bit clears automatically", UVM_LOW)
//      do begin
//         assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_UNLOCK_REG; no_of_bytes == 1;});
//         `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
//         `nnc_info("SOC_TEST", $sformatf("READ UNLOCK bit %h !!!", top_test_cfg.rd_data[0][0]), UVM_LOW) 
//      end while (top_test_cfg.rd_data[0][0] == 1'b1);
//      `nnc_info("SOC_TEST", "unlock bit cleared automatically", UVM_LOW)
//
//    end
//    else if (wait_for_unlock_clear === 2'b00)begin 
//     // To program each location require (1.31*9 +0.1)ms (minimum time require to program one location) 
//     #11.89ms; //#(wr_prgm_delay); //11.89ms; 
//     #2ms;     // provide little more time window to finsh otp woking(avoid warning message from ctrl model)
//
//    end
//    else if(wait_for_unlock_clear === 2'b10)begin 
//      wait_wr_working_high();
//
//    end
    if(wait_for_unlock_clear === 2'b01)begin
     `nnc_info("SOC_TEST", "wait for OTP_VPP_EN to go low", UVM_LOW)
     //4.set OTP_VPP_EN to 1(connect to IOPAD[8], boost VPP to 7.5V in 20us
     //`DUT_IF.otp_program_en = top_test_cfg.otp_program_en;
     //`DUT_IF.otp_vpp_delay = top_test_cfg.otp_vpp_delay;

      //5.a.wait for OTP_VPP_EN=0 
      @(negedge `SOC_TB.VPP_EN);
    end
    else if (wait_for_unlock_clear === 2'b00)begin 
      // USE PPROGM to complete write operation
     `nnc_info("SOC_TEST", "poll PPROG bit of debug1 register", UVM_LOW)
      wait_otp_ip_wr();
      wait(`SOC_TB.VPP_EN === 1'b0);
    end
    else if(wait_for_unlock_clear === 2'b10)begin 
     `nnc_info("SOC_TEST", "poll Wr_working bit of debug1 register", UVM_LOW)
      wait_wr_working_high();
      wait(`SOC_TB.VPP_EN ===1'b0);
    end



    //5.b.Change back VPP to VDD(1.8V) for read in 20us, in digital VDD(1.8V)== means Zero(0)
    //so VPP = will be 0 for read

     //wait for sometime before power off the chip
    #50us;
 
    //6.reset 
    ens2_chip_power_off();
    `nnc_info("SOC_TEST", "ENS2 chip power off", UVM_LOW)
    //7. 
    ens2_chip_power_on();
    `nnc_info("SOC_TEST", "ENS2 chip power on", UVM_LOW) 
    //8.wait reload done
    wait_reload_done();
   `nnc_info("SOC_TEST", $sformatf("Wait for reload_done"), UVM_LOW)

    //just to corss check by disabling otp_clk
    enable_otp_clk_gating(); 

    //8.read trim_reg and compare write data with read data
    //read_and_compare_trim_reg_data();

endtask

task ens2_chip_power_off();
   `ifndef MIX_SIM_EN
      #0.1ms;
      force `ANA_TOP.PMU_SW.CHIP_EN = 1'b0;
      //force `SOC_TOP.A2D_SW_POWER_POR = 1'b0;    
      //`DUT_IF.altf_gpio_sel = 0;
      //`DUT_IF.altf_gpio_sel = top_test_cfg.save_trim_wdata[8][1:0];    
    `endif
    //#10ms;

endtask

task ens2_chip_power_on();
   `ifndef MIX_SIM_EN

     //release `SOC_TOP.A2D_SW_POWER_POR;
     //force `SOC_TOP.A2D_SW_POWER_POR = 1'b1;
     #1ms;
     force `ANA_TOP.PMU_SW.CHIP_EN = 1'b1;
     wait(soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_reset_ctrl.otp_rstn ===1'b1); //#1000us;    // instead of delay wait for otp rstn
   `endif
 
endtask

task wait_reload_done();
   `nnc_info("SOC_TEST", $sformatf("Wait for reload_done"), UVM_LOW)
    do begin
        assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_DEBUG_1_REG; no_of_bytes == 1;});
        `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
        `nnc_info("SOC_TEST", $sformatf("Reload_done %h !!!", top_test_cfg.rd_data[0][5]), UVM_LOW)
        #1000ns; 
    end while (top_test_cfg.rd_data[0][5] == 1'b0);
endtask

task read_and_compare_trim_reg_data(logic [7:0] prev_wdata_1[11], logic [7:0] cur_wdata_1[11]);
    top_test_cfg.rd_data = new[8];
    //read trim_reg
    `nnc_info("SOC_TEST", $sformatf("READ SPI TRIM DATA"), UVM_LOW)
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_TRIM_1_REG; no_of_bytes == 8; });
    `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data[0:7]); 
    
    for (int i =0; i<8; i++)begin
        `nnc_info("SOC_TEST", $sformatf("for-loop i=%h prev_wdata=%h curr_wdata=%h", i, prev_wdata_1[i], cur_wdata_1[i]), UVM_LOW)
        //if((top_test_cfg.prev_wdata[i] ===  1'b0) && (top_test_cfg.save_trim_wdata[i] === 1'b1))begin     // 0==>1
        //     top_test_cfg.cur_wdata[i] = 1'b1; //top_test_cfg.save_trim_wdata[i]; //1; 
        //     `nnc_info("SOC_TEST", $sformatf("0==>1 detection, for-loop i=%h expected_wdata=%8h ", i, top_test_cfg.cur_wdata[i]), UVM_LOW) 
 
        //end else if ((top_test_cfg.prev_wdata[i] === 1'b1) && (top_test_cfg.save_trim_wdata[i] === 1'b0))begin   // 1==> 0
        //     top_test_cfg.cur_wdata[i] = top_test_cfg.prev_wdata[i]; //1'b1;
        //     `nnc_info("SOC_TEST", $sformatf("1==>0 dectection, for-loop i=%h expected_wdata=%8h ", i, top_test_cfg.cur_wdata[i]), UVM_LOW) 

        //end else begin
        //    top_test_cfg.cur_wdata[i] = top_test_cfg.save_trim_wdata[i]; // 0==>0, 1==>1
        //end
        top_test_cfg.cur_wdata[i] = (prev_wdata_1[i] | cur_wdata_1[i]);
        `nnc_info("SOC_TEST", $sformatf("expected data=%8h ", top_test_cfg.cur_wdata[i]), UVM_LOW)                
    end 

    //if(top_test_cfg.save_trim_wdata[0:7] !== top_test_cfg.rd_data[0:7]) `nnc_error("SOC_TEST", "save_trim_wdata !== rd_data !!!")
    for(int i=0; i<8 ; i++) begin
        if(top_test_cfg.cur_wdata[i] !== top_test_cfg.rd_data[7-i]) `nnc_error("SOC_TEST", $sformatf("READ DATA ERROR!!! expected_data %8h !== rd_data %8h!!!", top_test_cfg.cur_wdata[i], top_test_cfg.rd_data[7-i]))
        else `nnc_info("SOC_TEST", $sformatf("READ DATA MATCH!! expected_wdata %8h === rd_data %8h!!!", top_test_cfg.cur_wdata[i], top_test_cfg.rd_data[7-i]), UVM_LOW) 
    end

endtask 

task read_and_compare_trim_shadowreg_data(logic [7:0] cur_wdata_1[11]);
    top_test_cfg.rd_data = new[8];
    `nnc_info("SOC_TEST", $sformatf("READ SPI TRIM SHADOW REG DATA"), UVM_LOW)
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_TRIM_1_REG; no_of_bytes == 8; });
    `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data[0:7]); 
    for(int i=0; i<8 ; i++) begin
        if(cur_wdata_1[i] !== top_test_cfg.rd_data[7-i]) `nnc_error("SOC_TEST", $sformatf("READ SHADOW REG DATA ERROR!!! expected_data %8h !== rd_data %8h!!!", cur_wdata_1[i], top_test_cfg.rd_data[7-i]))
        else `nnc_info("SOC_TEST", $sformatf("READ SHADOW REG DATA MATCH!! expected_wdata %8h === rd_data %8h!!!", cur_wdata_1[i], top_test_cfg.rd_data[7-i]), UVM_LOW) 
    end


endtask

task set_valid_tag();
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_TRIM_0_REG; no_of_bytes == 1; data[0] == 8'h5a;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
   `nnc_info("SOC_TEST", $sformatf("TRIM_TAG=%8h ", top_test_cfg.data[0]), UVM_LOW) 
endtask 

task spi_wr_to_trim_reg();
    for(int i=0; i<8 ; i++) begin
      top_test_cfg.prev_wdata[i] = top_test_cfg.save_trim_wdata[i];
      `nnc_info("SOC_TEST", $sformatf("save_trim_wdata=%8h, prev_trim_wdata %8h ",  top_test_cfg.save_trim_wdata[i], top_test_cfg.prev_wdata[i]), UVM_LOW)
    end 
  
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_TRIM_1_REG; no_of_bytes == 8;foreach(data[i]) data[i]>8'h0;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);   
    foreach (top_test_cfg.save_trim_wdata[i]) if(i<8) top_test_cfg.save_trim_wdata[i] = top_test_cfg.data[7-i];
    //foreach (top_test_cfg.save_trim_wdata[i]) if(i<8) top_test_cfg.save_trim_wdata[i] |= top_test_cfg.data[7-i];

    for(int i=0; i<8 ; i++) begin
        `nnc_info("SOC_TEST", $sformatf("save_trim_wdata %8h ", top_test_cfg.save_trim_wdata[i]), UVM_LOW) 
    end
endtask

task set_unlock_bit();
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_UNLOCK_REG; no_of_bytes == 1; data[0] == 8'b10101_001;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

     //Read unlock bit0
    `nnc_info("SOC_TEST", $sformatf("Wait for unlock bit untill become 1"), UVM_LOW)
     do begin
        assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_UNLOCK_REG; no_of_bytes == 1;});
        `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
        `nnc_info("SOC_TEST", $sformatf("unlock %h !!!", top_test_cfg.rd_data[0][0]), UVM_LOW) 
     end while (top_test_cfg.rd_data[0][0] == 1'b0);

 endtask

 task wait_wr_working_high();
    `nnc_info("SOC_TEST", $sformatf("Wait for wr_wroking as HIGH"), UVM_LOW)
     do begin
        assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_DEBUG_1_REG; no_of_bytes == 1;});
        `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
        `nnc_info("SOC_TEST", $sformatf("wr_working %h !!!", top_test_cfg.rd_data[0][1]), UVM_LOW) 
     end while (top_test_cfg.rd_data[0][6] == 1'b0);

     `nnc_info("SOC_TEST", $sformatf("Wait for wr_wroking as LOW"), UVM_LOW)
     do begin
        assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_DEBUG_1_REG; no_of_bytes == 1;});
        `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
        `nnc_info("SOC_TEST", $sformatf("wr_working %h !!!", top_test_cfg.rd_data[0][1]), UVM_LOW) 
     end while (top_test_cfg.rd_data[0][6] == 1'b1);
     `nnc_info("SOC_TEST", $sformatf("Programming Done!!!"), UVM_LOW)

endtask

task wait_otp_ip_wr(); //PPROG signal monitor control im OTP IP
     `nnc_info("SOC_TEST", $sformatf("Wait for otp_ip_PPROG as HIGH"), UVM_LOW)
      do begin
        assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_DEBUG_1_REG; no_of_bytes == 1;});
        `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
        `nnc_info("SOC_TEST", $sformatf("otp_ip_wr %h !!!", top_test_cfg.rd_data[0][1]), UVM_LOW) 
      end while (top_test_cfg.rd_data[0][4] == 1'b0);

      `nnc_info("SOC_TEST", $sformatf("Wait for otp_ip_PPROG as LOW"), UVM_LOW)
      do begin
        assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_DEBUG_1_REG; no_of_bytes == 1;});
        `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
        `nnc_info("SOC_TEST", $sformatf("otp_ip_wr %h !!!", top_test_cfg.rd_data[0][1]), UVM_LOW) 
      end while (top_test_cfg.rd_data[0][4] == 1'b1);
      `nnc_info("SOC_TEST", $sformatf("Programming Done!!!"), UVM_LOW)

endtask

task wait_for_loading_shadows();
   `nnc_info("SOC_TEST", $sformatf("Wait for loading_shadows"), UVM_LOW)
    do begin
        assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_DEBUG_1_REG; no_of_bytes == 1;});
        `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
        `nnc_info("SOC_TEST", $sformatf("loading_shadows %h !!!", top_test_cfg.rd_data[0][5]), UVM_LOW) 
    end while (top_test_cfg.rd_data[0][7] == 1'b0);
    do begin
        assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_DEBUG_1_REG; no_of_bytes == 1;});
        `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
        `nnc_info("SOC_TEST", $sformatf("loading_shadows %h !!!", top_test_cfg.rd_data[0][5]), UVM_LOW) 
    end while (top_test_cfg.rd_data[0][7] == 1'b1);
     `nnc_info("SOC_TEST", $sformatf("shadow values loading is done!!!"), UVM_LOW)
endtask

task disable_otp_clk_gating;
      //set PMU_REG0, set otp_dpstb_en=0, PMU_REG0[3]=0, to disable otp_clk gating
     `nnc_info("SOC_TEST", $sformatf("Write to PMU_REG0[3] as 0 to disable otp clock gating"), UVM_LOW)
      `WR_NORMAL_REG(`SOC_PMU_REG, 8'b0000_0001, 8'h00);

endtask

task enable_otp_clk_gating;
      //set PMU_REG0, set otp_dpstb_en=1, PMU_REG0[3]=1, to enable otp_clk gating
     `nnc_info("SOC_TEST", $sformatf("Write to PMU_REG0[3] as 1 to enable otp clock gating"), UVM_LOW)
     `WR_NORMAL_REG(`SOC_PMU_REG, 8'b0000_1001, 8'h00);

endtask

  // ------------------------------
  // Declare the report_phase task
  // ------------------------------
  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction

endclass : `TESTNAME
