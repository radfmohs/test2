/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_spi_reg_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Check otp unlock function                                          
// Designer	: ddang@nanochap.com                                                                 
// Date		: 29-11-2023                                                                     
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_otp_unlock_test
`define TESTCFG soc_otp_unlock_test_cfg

class `TESTCFG extends soc_base_test_cfg;

  `nnc_object_utils(`TESTCFG)

  // ===============================================
  // Adding your new varialbles in config test
  // -----------------------------------------------

  rand int         no_of_bytes; 
  rand logic [7:0] reg_addr;
  rand logic [7:0] pads;
  rand logic [7:0] mask;
  //reg trans otp
  logic [7:0] reg_to_otp_data[128];
  rand logic [7:0]     data[256];  
  //otp trans reg
  logic [7:0] otp_to_reg_data[128];
  logic [7:0] rd_data ;
  logic [7:0] wr_data;
  logic [7:0] save_trim_wdata[11] = '{default : 8'h0};
  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_otp_unlock_test_cfg");
    super.new(name);
  endfunction: new

  // ===============================================
  // Adding constraints of randomization
  // -----------------------------------------------

  // testmode_sel[1:0] : 00-Normal mode, 01: Scanmode, 10: BIST mode, 11 atm0/1/2/3/4
  constraint c_testmode_sel { soft testmode_sel == 2'b00; }

  // spimode_sel[1:0] :  
  constraint c_spimode_sel  { spimode_sel == 2'b00; }

  // No of bytes in a burst
  constraint c_no_of_bytes  { soft no_of_bytes == 2; }

  // pads values
  constraint c_pads         { soft pads == 8'h00; }

  // mask values
  constraint c_mask         { soft mask == 8'hff; }

  // Enable/Disable to program OTP
  constraint c_otp_program_en           { otp_program_en == 1'b1;}

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
    uvm_top.set_timeout(2s);
    top_test_cfg = `TESTCFG::type_id::create("top_test_cfg", this);
  endfunction

  // -----------------------------------------
  // Declare the pre_reset_phase task 
  // -----------------------------------------
  virtual task pre_reset_phase(nnc_phase phase);
    phase.raise_objection(this);

    super.pre_reset_phase(phase);

    assert(top_test_cfg.randomize());

    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;

    `DUT_IF.spimode_sel = top_test_cfg.spimode_sel;

    `DUT_IF.otp_program_en = top_test_cfg.otp_program_en;

    `DUT_IF.otp_vpp_delay = top_test_cfg.otp_vpp_delay;

    // -------------------
    // Scoreboard enables
    // -------------------
    // `EEPROM_SCOREBOARD_EN = 1;
    //`EPROM_BIST_SCOREBOARD_EN = 1;    
    // `ANALOG_SCOREBOARD_EN = 1;
    // `IMEAS_SCOREBOARD_EN = 1;
    // `CLKRST_SCOREBOARD_EN = 1;

    for (int j=8'h0C;j <= 8'h14; j++) 
        `DUT_IF.reg_normal[j][2] = 0;

    phase.drop_objection(this);
  endtask : pre_reset_phase
  // -----------------------------------------
  // Declare the main_phase task of your test
  // -----------------------------------------
  virtual task main_phase(uvm_phase phase);
    phase.raise_objection(this);

    super.main_phase(phase);

    `nnc_info("SOC_TEST", "soc_spi_reg_test start", UVM_LOW)

`ifndef MIX_SIM_EN
    // --------------------------------------------------------
    // Part I: Checking the W/R values of all of normal registers
    // --------------------------------------------------------
    `nnc_info("SOC_TEST - PART II", "STARTING TO CHECK THE R/W OF NORMAL REGISTERS", UVM_LOW)
 
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_TRIM_0_REG; mask == 8'hff; data[0] == 8'h5a;}); // the first trim value is 8'h5a
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);
    repeat(3) @(posedge `DUT_IF.sys_clk);
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_0_REG] = top_test_cfg.rd_data;
    if ((top_test_cfg.data[0] & top_test_cfg.mask) !== (top_test_cfg.rd_data & top_test_cfg.mask)) begin
       `nnc_error("SPIM INFO - WRRDCHK", $sformatf("EXPECTED WRITE DATA:%h IS NOT MATCH WITH CURRENT READ DATA:%h", top_test_cfg.data[0] & top_test_cfg.mask, top_test_cfg.rd_data & top_test_cfg.mask))
    end    

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_TRIM_1_REG; mask == 8'hff;foreach(data[i]) data[i]>8'h10;});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);
    repeat(3) @(posedge `DUT_IF.sys_clk);
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_1_REG] = top_test_cfg.rd_data;    
    if ((top_test_cfg.data[0] & top_test_cfg.mask) !== (top_test_cfg.rd_data & top_test_cfg.mask)) begin
       `nnc_error("SPIM INFO - WRRDCHK", $sformatf("EXPECTED WRITE DATA:%h IS NOT MATCH WITH CURRENT READ DATA:%h", top_test_cfg.data[0] & top_test_cfg.mask, top_test_cfg.rd_data & top_test_cfg.mask))
    end

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_TRIM_2_REG; mask == 8'hff;foreach(data[i]) data[i]>8'h10;});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);
    repeat(3) @(posedge `DUT_IF.sys_clk);
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_2_REG] = top_test_cfg.rd_data;        
    if ((top_test_cfg.data[0] & top_test_cfg.mask) !== (top_test_cfg.rd_data & top_test_cfg.mask)) begin
       `nnc_error("SPIM INFO - WRRDCHK", $sformatf("EXPECTED WRITE DATA:%h IS NOT MATCH WITH CURRENT READ DATA:%h", top_test_cfg.data[0] & top_test_cfg.mask, top_test_cfg.rd_data & top_test_cfg.mask))
    end

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_TRIM_3_REG; mask == 8'hff;foreach(data[i]) data[i]>8'h10;});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);
    repeat(3) @(posedge `DUT_IF.sys_clk);
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_3_REG] = top_test_cfg.rd_data;            
    if ((top_test_cfg.data[0] & top_test_cfg.mask) !== (top_test_cfg.rd_data & top_test_cfg.mask)) begin
       `nnc_error("SPIM INFO - WRRDCHK", $sformatf("EXPECTED WRITE DATA:%h IS NOT MATCH WITH CURRENT READ DATA:%h", top_test_cfg.data[0] & top_test_cfg.mask, top_test_cfg.rd_data & top_test_cfg.mask))
    end

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_TRIM_4_REG; mask == 8'hff;foreach(data[i]) data[i]>8'h10;});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);
    repeat(3) @(posedge `DUT_IF.sys_clk);
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_4_REG] = top_test_cfg.rd_data;                
    if ((top_test_cfg.data[0] & top_test_cfg.mask) !== (top_test_cfg.rd_data & top_test_cfg.mask)) begin
       `nnc_error("SPIM INFO - WRRDCHK", $sformatf("EXPECTED WRITE DATA:%h IS NOT MATCH WITH CURRENT READ DATA:%h", top_test_cfg.data[0] & top_test_cfg.mask, top_test_cfg.rd_data & top_test_cfg.mask))
    end

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_TRIM_5_REG; mask == 8'hff;foreach(data[i]) data[i]>8'h10;});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);
    repeat(3) @(posedge `DUT_IF.sys_clk);
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_5_REG] = top_test_cfg.rd_data;                    
    if ((top_test_cfg.data[0] & top_test_cfg.mask) !== (top_test_cfg.rd_data & top_test_cfg.mask)) begin
       `nnc_error("SPIM INFO - WRRDCHK", $sformatf("EXPECTED WRITE DATA:%h IS NOT MATCH WITH CURRENT READ DATA:%h", top_test_cfg.data[0] & top_test_cfg.mask, top_test_cfg.rd_data & top_test_cfg.mask))
    end

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_TRIM_6_REG; mask == 8'hff;foreach(data[i]) data[i]>8'h10;});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);
    repeat(3) @(posedge `DUT_IF.sys_clk);
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_6_REG] = top_test_cfg.rd_data;                    
    if ((top_test_cfg.data[0] & top_test_cfg.mask) !== (top_test_cfg.rd_data & top_test_cfg.mask)) begin
       `nnc_error("SPIM INFO - WRRDCHK", $sformatf("EXPECTED WRITE DATA:%h IS NOT MATCH WITH CURRENT READ DATA:%h", top_test_cfg.data[0] & top_test_cfg.mask, top_test_cfg.rd_data & top_test_cfg.mask))
    end

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_TRIM_7_REG; mask == 8'hff;foreach(data[i]) data[i]>8'h10;});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);
    repeat(3) @(posedge `DUT_IF.sys_clk);
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_7_REG] = top_test_cfg.rd_data;                    
    if ((top_test_cfg.data[0] & top_test_cfg.mask) !== (top_test_cfg.rd_data & top_test_cfg.mask)) begin
       `nnc_error("SPIM INFO - WRRDCHK", $sformatf("EXPECTED WRITE DATA:%h IS NOT MATCH WITH CURRENT READ DATA:%h", top_test_cfg.data[0] & top_test_cfg.mask, top_test_cfg.rd_data & top_test_cfg.mask))
    end

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_TRIM_8_REG; mask == 8'hff;foreach(data[i]) data[i]>8'h10;});
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);
    repeat(3) @(posedge `DUT_IF.sys_clk);
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_8_REG] = top_test_cfg.rd_data;                    
    if ((top_test_cfg.data[0] & top_test_cfg.mask) !== (top_test_cfg.rd_data & top_test_cfg.mask)) begin
       `nnc_error("SPIM INFO - WRRDCHK", $sformatf("EXPECTED WRITE DATA:%h IS NOT MATCH WITH CURRENT READ DATA:%h", top_test_cfg.data[0] & top_test_cfg.mask, top_test_cfg.rd_data & top_test_cfg.mask))
    end
    
    // --------------------------------------------------------
    // Part II: make unlock bit to 1 
    // --------------------------------------------------------
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_UNLOCK_REG; mask == 8'h1; data[0] == 8'b10101_001;});          
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);

    // ------------------------------------------------------------------------------- 
    // -------------------------------------------------------------------------------
    //set OTP_VPP_EN to 1(connect to IOPAD[8], boost VPP to 7.5V in 20us
     // ------------------------------------------------------------------------------- 
    // -------------------------------------------------------------------------------

     // -------------------------------------------------------------------------------
    // Part III: Waiting for WR_WORKING bit is changed from 1'b1 to 1'b0
    // -------------------------------------------------------------------------------
    //repeat(4) @(posedge `DUT_IF.sys_clk);
    //wait for wr_working to be HIGH
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_DEBUG_1_REG; mask == 8'h3;});
    do begin
        `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
        $display($time,"Wait for the Wr_working be HIGH!!!");
    end while(top_test_cfg.rd_data[6] !== 1);  

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_DEBUG_1_REG; mask == 8'h3;});
    do begin
        `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
        $display($time,"Wait for the Wr_working be low!!!");
    end while(top_test_cfg.rd_data[6] !== 0);  

    // ------------------------------------------------------------------------------- 
    // -------------------------------------------------------------------------------
    //wait for OTP_VPP_EN=0 
    wait(soc_top_tb.IOBUF_PAD[8] === 1'b0);  //@(negedge soc_top_tb.IOBUF_PAD[8]); //minimum 20us require VPP to go LOW level(VDD level 1.8V)

    //wait for sometimeb before power off the chip
    #50us;
    // -------------------------------------------------------------------------------
    // -------------------------------------------------------------------------------

    // --------------------------------------------------------
    // Part IV: Set GENERAL CALL RESET to ENS2    
    // --------------------------------------------------------
    `nnc_info("SOC_TEST", "POR RESETn 10ms", UVM_LOW);
    force `ANA_TOP.PMU_SW.CHIP_EN = 1'b0; //force `SOC_TOP.A2D_SW_POWER_POR = 1'b0;
    #10ms;
`ifndef BEHAVIORAL
       `ifdef POSTSCAN_PG
            if(/*`RST_CTRL_TOP.presetn ||   `RST_CTRL_TOP.poresetn || `RST_CTRL_TOP.poresetn_hf || `RST_CTRL_TOP.otp_por_resetn */`RST_CTRL_TOP.por_resetn)
       `else
          if(/* `RST_CTRL_TOP.presetn ||  `RST_CTRL_TOP.poresetn ||*/ `RST_CTRL_TOP.presetn/*poresetn_hf*/ || `RST_CTRL_TOP.por_resetn )
       `endif
`else
    if(/*`RST_CTRL_TOP.presetn ||  `RST_CTRL_TOP.poresetn || */`RST_CTRL_TOP.poresetn_hf/* || `RST_CTRL_TOP.por_resetn*/ )

`endif
        `nnc_error("SOC_TEST", "RESETn error!!!");

    //#1ms;
     force `ANA_TOP.PMU_SW.CHIP_EN = 1'b1;
     wait(soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_reset_ctrl.otp_rstn ===1'b1);
    //#10ms;
    //release `SOC_TOP.A2D_SW_POWER_POR;
    //force `SOC_TOP.A2D_SW_POWER_POR = 1'b1;
    
    #10ns;
    // Checking the RESET should be happened    
    repeat(800) @(posedge `CLK_CTRL_TOP.pclk); 
`ifndef BEHAVIORAL
       `ifdef POSTSCAN_PG
            if(/*`RST_CTRL_TOP.presetn || `RST_CTRL_TOP.poresetn || `RST_CTRL_TOP.poresetn_hf || `RST_CTRL_TOP.otp_por_resetn */`RST_CTRL_TOP.por_resetn);
       `else
          if(`RST_CTRL_TOP.presetn/*poresetn_hf*/ || `RST_CTRL_TOP.por_resetn);
       `endif
`else 
    if(`RST_CTRL_TOP.presetn && `RST_CTRL_TOP.poresetn && `RST_CTRL_TOP.poresetn_hf && `RST_CTRL_TOP.por_resetn );
`endif
    else  `nnc_error("SOC_TEST", "RESETn error!!!");

    if(top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_0_REG] === 16'h005A) begin
        `nnc_info("I2C_TEST", "Waiting for RELOAD DONE", UVM_LOW)
        assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_DEBUG_1_REG;});
        `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
        while ((top_test_cfg.rd_data[5] === 1'b0) | (top_test_cfg.rd_data[0] === 1'bx)) begin
            assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_DEBUG_1_REG;});
            `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data); 
        end
        `nnc_info("I2C_TEST", "Reload is done now", UVM_LOW)            
    end else begin
        assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_DEBUG_1_REG;});
        `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);                        
        while ((top_test_cfg.rd_data[6] === 1'b1) | (top_test_cfg.rd_data[1] === 1'bx)) begin
            assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_DEBUG_1_REG;});
            `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);                        
        end
        `nnc_info("I2C_TEST", "EEPROM BUSY to be deasserted", UVM_LOW)       
    end 


//    //// Write SOC_OTP_TRIM_0_REG
//    //// Randomize to set register    
//    //assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_TRIM_0_REG; mask == 8'hff; data[0] == 8'h5a;});
//    //top_test_cfg.wr_data[0]=top_test_cfg.data[0];
//    ////  Write DATA to register    
//    //`WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);
//    //`nnc_info("I2C_TEST", $sformatf("SOC_OTP_TRIM_0_REG %h",top_test_cfg.data[0]), UVM_LOW)           
                          
    // --------------------------------------------------------
    // Part V: set unlock bit to 1 
    // --------------------------------------------------------
    //before reprogram set unlockreg ==0
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_UNLOCK_REG; mask == 8'h1; data[0] == 8'b0;});    
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);

    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_UNLOCK_REG; mask == 8'h1; data[0] == 8'b10101_001;});    
    //`WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);

    //// ------------------------------------------------------------------------------- 
    //// -------------------------------------------------------------------------------
    ////set OTP_VPP_EN to 1(connect to IOPAD[8], boost VPP to 7.5V in 20us
    //`DUT_IF.otp_program_en = top_test_cfg.otp_program_en;
    //`DUT_IF.otp_vpp_delay = top_test_cfg.otp_vpp_delay;
    //// ------------------------------------------------------------------------------- 
    //// -------------------------------------------------------------------------------

    //// Waiting for WR_WORKING bit is changed from 1'b1 to 1'b0
    //`nnc_info("I2C_TEST", "Waiting the completion of Writing DATA from OTP to EPROM", UVM_LOW)    
    //assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_DEBUG_1_REG; mask == 8'h3;});
    //`RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);

    //while ((top_test_cfg.rd_data[6] === 1'b1) | (top_test_cfg.rd_data[1] === 1'bx)) begin
    //  assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_DEBUG_1_REG;});
    //  `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    //   `nnc_info("I2C_TEST", "wait for wr_working LOW", UVM_LOW)
    //end
    //`nnc_info("I2C_TEST", "Waiting the completion of Writing DATA from OTP to EPROM", UVM_LOW)

    // ------------------------------------------------------------------------------- 
    // -------------------------------------------------------------------------------
    ////wait for OTP_VPP_EN=0 
    //wait(soc_top_tb.IOBUF_PAD[8] === 1'b0); //@(negedge soc_top_tb.IOBUF_PAD[8]);

    ////wait for sometime before power off the chip
    //#1ms;
    // -------------------------------------------------------------------------------
    // -------------------------------------------------------------------------------


    // --------------------------------------------------------
    // Part VII: wait for the reload
    // --------------------------------------------------------
    //repeat(4) @(posedge `DUT_IF.sys_clk);
    //assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_DEBUG_2_REG; mask == 8'h3;});
    //do begin
    //    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    //    $display($time,"Wait for the reload rise!!!");
    //end while(top_test_cfg.rd_data[0] !== 1);
    // -------------------------------------------------------------------    
    // Part VIII: Checking the Reload values of all of OTP controller registers 
    // -------------------------------------------------------------------
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_TRIM_1_REG; mask == 8'hff;});
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_1_REG] = top_test_cfg.rd_data;                    
    if (top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_1_REG] !== top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_1_REG]) begin
       `nnc_error("UNLOCK ERROR", $sformatf("otp_to_reg_data :%h reg_to_otp_data :%h", top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_1_REG], top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_1_REG]))
    end

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_TRIM_2_REG; mask == 8'hff;});
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_2_REG] = top_test_cfg.rd_data;                        
    if (top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_2_REG] !== top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_2_REG]) begin
       `nnc_error("UNLOCK ERROR", $sformatf("otp_to_reg_data :%h reg_to_otp_data :%h", top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_2_REG], top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_2_REG]))
    end

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_TRIM_3_REG; mask == 8'hff;});
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_3_REG] = top_test_cfg.rd_data;                        
    if (top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_3_REG] !== top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_3_REG]) begin
       `nnc_error("UNLOCK ERROR", $sformatf("otp_to_reg_data :%h reg_to_otp_data :%h", top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_3_REG], top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_3_REG]))
    end

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_TRIM_4_REG; mask == 8'hff;});
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_4_REG] = top_test_cfg.rd_data;                        
    if (top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_4_REG] !== top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_4_REG]) begin
       `nnc_error("UNLOCK ERROR", $sformatf("otp_to_reg_data :%h reg_to_otp_data :%h", top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_4_REG], top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_4_REG]))
    end

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_TRIM_5_REG; mask == 8'hff;});
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_5_REG] = top_test_cfg.rd_data;                        
    if (top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_5_REG] !== top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_5_REG]) begin
       `nnc_error("UNLOCK ERROR", $sformatf("otp_to_reg_data :%h reg_to_otp_data :%h", top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_5_REG], top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_5_REG]))
    end

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_TRIM_5_REG; mask == 8'hff;});
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_5_REG] = top_test_cfg.rd_data;                        
    if (top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_5_REG] !== top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_5_REG]) begin
       `nnc_error("UNLOCK ERROR", $sformatf("otp_to_reg_data :%h reg_to_otp_data :%h", top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_5_REG], top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_5_REG]))
    end

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_TRIM_6_REG; mask == 8'hff;});
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_6_REG] = top_test_cfg.rd_data;                        
    if (top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_6_REG] !== top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_6_REG]) begin
       `nnc_error("UNLOCK ERROR", $sformatf("otp_to_reg_data :%h reg_to_otp_data :%h", top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_6_REG], top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_6_REG]))
    end

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_TRIM_7_REG; mask == 8'hff;});
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_7_REG] = top_test_cfg.rd_data;                        
    if (top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_7_REG] !== top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_7_REG]) begin
       `nnc_error("UNLOCK ERROR", $sformatf("otp_to_reg_data :%h reg_to_otp_data :%h", top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_7_REG], top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_7_REG]))
    end

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_TRIM_8_REG; mask == 8'hff;});
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_8_REG] = top_test_cfg.rd_data;                        
    if (top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_8_REG] !== top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_8_REG]) begin
       `nnc_error("UNLOCK ERROR", $sformatf("otp_to_reg_data :%h reg_to_otp_data :%h", top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_8_REG], top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_8_REG]))
    end



    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_TRIM_1_REG; no_of_bytes == 8;foreach(data[i]) data[i]>8'h0;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);   
    //foreach (top_test_cfg.save_trim_wdata[i]) if(i<8) top_test_cfg.save_trim_wdata[i] = top_test_cfg.data[7-i];
    ////foreach (top_test_cfg.save_trim_wdata[i]) if(i<8) top_test_cfg.save_trim_wdata[i] |= top_test_cfg.data[7-i];

    //for(int i=0; i<8 ; i++) begin
    //    `nnc_info("SOC_TEST", $sformatf("save_trim_wdata %8h ", top_test_cfg.save_trim_wdata[i]), UVM_LOW) 
    //end

    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_UNLOCK_REG; mask == 8'h1; data[0] == 8'b10101_001;});    
    `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads);

    // ------------------------------------------------------------------------------- 
    // -------------------------------------------------------------------------------
    //set OTP_VPP_EN to 1(connect to IOPAD[8], boost VPP to 7.5V in 20us
    //`DUT_IF.otp_program_en = top_test_cfg.otp_program_en;
    //`DUT_IF.otp_vpp_delay = top_test_cfg.otp_vpp_delay;
    // ------------------------------------------------------------------------------- 
    // -------------------------------------------------------------------------------

    // Waiting for WR_WORKING bit is changed from 1'b1 to 1'b0
    `nnc_info("I2C_TEST", "Waiting the completion of Writing DATA from OTP to EPROM", UVM_LOW)    
    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_DEBUG_1_REG; mask == 8'h3;});
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);

    while ((top_test_cfg.rd_data[6] === 1'b1) | (top_test_cfg.rd_data[1] === 1'bx)) begin
      assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_DEBUG_1_REG;});
      `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
       `nnc_info("I2C_TEST", "wait for wr_working LOW", UVM_LOW)
    end
    `nnc_info("I2C_TEST", "Waiting the completion of Writing DATA from OTP to EPROM", UVM_LOW)

    // ------------------------------------------------------------------------------- 
    // -------------------------------------------------------------------------------
    ////wait for OTP_VPP_EN=0 
    //wait(soc_top_tb.IOBUF_PAD[8] === 1'b0); //@(negedge soc_top_tb.IOBUF_PAD[8]);

    ////wait for sometime before power off the chip
    #1ms;

    //// --------------------------------------------------------
    //// Part III: Checking the Wr_working be low
    //// --------------------------------------------------------
    //repeat(4) @(posedge `DUT_IF.sys_clk);
    //assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_DEBUG_2_REG; mask == 8'h3;});
    //do begin
    //    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    //    $display($time,"Wait for the Wr_working be low!!!");
    //end while(top_test_cfg.rd_data[1] !== 0);

    // --------------------------------------------------------
    // Part VI: Checking the Wr_working be low
    // --------------------------------------------------------
        `nnc_info("SOC_TEST", "POR RESETn 10ms", UVM_LOW);
        force `ANA_TOP.PMU_SW.CHIP_EN = 1'b0; //force `SOC_TOP.A2D_SW_POWER_POR = 1'b0;
        #10ms; //1000;
`ifndef BEHAVIORAL
   `ifdef POSTSCAN_PG
            if(/*`RST_CTRL_TOP.presetn ||  `RST_CTRL_TOP.poresetn ||`RST_CTRL_TOP.poresetn_hf || `RST_CTRL_TOP.otp_por_resetn */`RST_CTRL_TOP.por_resetn)
    `else
          if(/* `RST_CTRL_TOP.presetn ||  `RST_CTRL_TOP.poresetn ||*/ `RST_CTRL_TOP.presetn/*poresetn_hf*/ || `RST_CTRL_TOP.por_resetn )
    `endif
`else
        if(`RST_CTRL_TOP.presetn ||  `RST_CTRL_TOP.poresetn || `RST_CTRL_TOP.poresetn_hf || `RST_CTRL_TOP.por_resetn )
`endif
            `nnc_error("SOC_TEST", "RESETn error!!!");

        //fork:_reset
        //#10ms;
        //    begin  wait(!`SOC_TOP.IOBUF_PAD[1]) `nnc_error("SOC_TEST", "RESET error!!!"); end
        ///join_any
        //disable _reset;
        
        force `ANA_TOP.PMU_SW.CHIP_EN = 1'b1;
        wait(soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_reset_ctrl.otp_rstn ===1'b1); 
        //release `SOC_TOP.A2D_SW_POWER_POR;
        //force `SOC_TOP.A2D_SW_POWER_POR = 1'b1;

        #10ns;
        //wait por_cnt
        repeat(800) @(posedge `CLK_CTRL_TOP.pclk);
`ifndef BEHAVIORAL
   `ifdef POSTSCAN_PG
          if(/*`RST_CTRL_TOP.presetn ||  `RST_CTRL_TOP.poresetn ||*`RST_CTRL_TOP.poresetn_hf || `RST_CTRL_TOP.otp_por_resetn */`RST_CTRL_TOP.por_resetn);
    `else
        if(/* `RST_CTRL_TOP.presetn &&  `RST_CTRL_TOP.poresetn &&*/ `RST_CTRL_TOP.presetn/*poresetn_hf*/ && `RST_CTRL_TOP.por_resetn );
    `endif
`else
        if(`RST_CTRL_TOP.presetn && `RST_CTRL_TOP.poresetn && `RST_CTRL_TOP.poresetn_hf && `RST_CTRL_TOP.por_resetn );
`endif
        else  `nnc_error("SOC_TEST", "RESETn error!!!");    

    if(top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_0_REG] === 16'h005A) begin
        `nnc_info("I2C_TEST", "Waiting for RELOAD DONE", UVM_LOW)
        assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_DEBUG_1_REG;});
        `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
        while ((top_test_cfg.rd_data[5] === 1'b0) | (top_test_cfg.rd_data[0] === 1'bx)) begin
            assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_DEBUG_1_REG;});
            `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data); 
        end
        `nnc_info("I2C_TEST", "Reload is done now", UVM_LOW)            
    end else begin
        assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_DEBUG_1_REG;});
        `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);                        
        while ((top_test_cfg.rd_data[6] === 1'b1) | (top_test_cfg.rd_data[1] === 1'bx)) begin
            assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_DEBUG_1_REG;});
            `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);                        
        end
        `nnc_info("I2C_TEST", "EEPROM BUSY to be deasserted", UVM_LOW)       
    end 

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_TRIM_1_REG; mask == 8'hff;});
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_1_REG] = top_test_cfg.rd_data;                    
    if (top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_1_REG] !== top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_1_REG]) begin
       `nnc_error("UNLOCK ERROR", $sformatf("otp_to_reg_data :%h reg_to_otp_data :%h", top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_1_REG], top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_1_REG]))
    end

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_TRIM_2_REG; mask == 8'hff;});
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_2_REG] = top_test_cfg.rd_data;                        
    if (top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_2_REG] !== top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_2_REG]) begin
       `nnc_error("UNLOCK ERROR", $sformatf("otp_to_reg_data :%h reg_to_otp_data :%h", top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_2_REG], top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_2_REG]))
    end

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_TRIM_3_REG; mask == 8'hff;});
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_3_REG] = top_test_cfg.rd_data;                        
    if (top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_3_REG] !== top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_3_REG]) begin
       `nnc_error("UNLOCK ERROR", $sformatf("otp_to_reg_data :%h reg_to_otp_data :%h", top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_3_REG], top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_3_REG]))
    end

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_TRIM_4_REG; mask == 8'hff;});
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_4_REG] = top_test_cfg.rd_data;                        
    if (top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_4_REG] !== top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_4_REG]) begin
       `nnc_error("UNLOCK ERROR", $sformatf("otp_to_reg_data :%h reg_to_otp_data :%h", top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_4_REG], top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_4_REG]))
    end

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_TRIM_5_REG; mask == 8'hff;});
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_5_REG] = top_test_cfg.rd_data;                        
    if (top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_5_REG] !== top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_5_REG]) begin
       `nnc_error("UNLOCK ERROR", $sformatf("otp_to_reg_data :%h reg_to_otp_data :%h", top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_5_REG], top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_5_REG]))
    end

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_TRIM_5_REG; mask == 8'hff;});
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_5_REG] = top_test_cfg.rd_data;                        
    if (top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_5_REG] !== top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_5_REG]) begin
       `nnc_error("UNLOCK ERROR", $sformatf("otp_to_reg_data :%h reg_to_otp_data :%h", top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_5_REG], top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_5_REG]))
    end

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_TRIM_6_REG; mask == 8'hff;});
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_6_REG] = top_test_cfg.rd_data;                        
    if (top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_6_REG] !== top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_6_REG]) begin
       `nnc_error("UNLOCK ERROR", $sformatf("otp_to_reg_data :%h reg_to_otp_data :%h", top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_6_REG], top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_6_REG]))
    end

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_TRIM_7_REG; mask == 8'hff;});
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_7_REG] = top_test_cfg.rd_data;                        
    if (top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_7_REG] !== top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_7_REG]) begin
       `nnc_error("UNLOCK ERROR", $sformatf("otp_to_reg_data :%h reg_to_otp_data :%h", top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_7_REG], top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_7_REG]))
    end

    assert(top_test_cfg.randomize() with {reg_addr == `SOC_OTP_TRIM_8_REG; mask == 8'hff;});
    `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
    top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_8_REG] = top_test_cfg.rd_data;                        
    if (top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_8_REG] !== top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_8_REG]) begin
       `nnc_error("UNLOCK ERROR", $sformatf("otp_to_reg_data :%h reg_to_otp_data :%h", top_test_cfg.otp_to_reg_data[`SOC_OTP_TRIM_8_REG], top_test_cfg.reg_to_otp_data[`SOC_OTP_TRIM_8_REG]))
    end
`endif
    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    #10000ns;
    `nnc_info("SOC_TEST", "soc_otp_read_write_test end now", UVM_LOW)

    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ----------------------------------------------------------------------------------

    phase.drop_objection(this);
  endtask: main_phase
 
endclass : `TESTNAME   
