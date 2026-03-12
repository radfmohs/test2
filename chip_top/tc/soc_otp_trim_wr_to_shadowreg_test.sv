/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_otp_trim_wr_to_shadowreg_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_otp_trim_wr_to_shadowreg_test                                             
// Designer	: supriya@nanochap.com                                                                 
// Date		: 05-06-2025                                                                     
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_otp_trim_wr_to_shadowreg_test
`define TESTCFG soc_otp_trim_wr_to_shadowreg_test_cfg

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
  logic [7:0]      normal_rd_data;
  logic [7:0] save_trim_wdata[11] = '{default : 8'h0};
  logic [7:0] prev_wdata[11];
  logic [7:0] cur_wdata[11];   
  logic [7:0] trim_wdata[11] = '{default : 8'h0};
  rand logic [7:0] otp_wdata[512];
  rand logic [8:0] otp_data_addr;
  logic [8:0] otp_addr[512];
  logic [7:0] otp_prev_data[512] = '{default : 8'h0};
  logic [7:0] otp_cur_data[512]= '{default : 8'h0};


  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_otp_trim_wr_to_shadowreg_test_cfg");
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
  //constraint c_otp_program_en           { otp_program_en == 1'b1;} // not required for shadow_register_test as not accessing OPT memory

  ////
  //constraint c_ext_clk_en  { ext_clk_en == 1;}
 
  ////
  //// Select PCLK DIV from HFOSC
  //constraint c_pclk_sel   {pclk_sel inside {[0:0]};} 

  //// Set frequency for SPI (unit of 1Khz)
  //constraint c_spi_sclk_freq          { solve spi_sclk_jitter before spi_sclk_freq; spi_sclk_freq inside {[25:25]};} // 25Khz to 16Mhz
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
    `nnc_top.set_timeout(2s);
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

    //`DUT_IF.otp_program_en = top_test_cfg.otp_program_en;

    //`DUT_IF.otp_vpp_delay = top_test_cfg.otp_vpp_delay;

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
    
    super.main_phase(phase);

    `nnc_info("SOC_TEST", "soc_otp_trim_wr_to_shadowreg_test start", NNC_LOW)

    // ==================================================================================
    // Please add your code of your test here
    // ---------------------------------------------------------------------------------- 

    `nnc_info("SOC_TEST", "Trim Write function for shadow register", UVM_LOW)
    //disable_otp_clk_gating();  // not necessary, by default otp_clk has been ungated
    write_trimregs_to_shadow_regs();
    //enable_otp_clk_gating();
    read_and_compare_trim_shadowreg_data(top_test_cfg.save_trim_wdata);
    read_trims_dbg_reg(top_test_cfg.save_trim_wdata);
    check_trimreg(top_test_cfg.save_trim_wdata);
    #1us;  
   
  
    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    #10000ns;
    `nnc_info("SOC_TEST", "soc_otp_trim_wr_to_shadowreg_test end now", NNC_LOW)

    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ==================================================================================

    phase.drop_objection(this);
  endtask: main_phase

  // ------------------------------
  // Declare the report_phase task
  // ------------------------------
  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction

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

     repeat(15) @(posedge `EPROM_TOP.clk); // #100us;
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
        assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_DEBUG_2_REG; no_of_bytes == 1;});
        `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
        `nnc_info("SOC_TEST", $sformatf("Reload_done %h !!!", top_test_cfg.rd_data[0][0]), UVM_LOW) 
     end while (top_test_cfg.rd_data[0][0] == 1'b0);

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

  task read_trims_dbg_reg(logic [7:0] cur_wdata_1[11]);
    top_test_cfg.rd_data = new[8];
    for(int i=0; i<9 ; i++) begin

       `nnc_info("SOC_TEST", $sformatf("READ SPI DBG TRIM REG which loads shadow register values"), UVM_LOW)
       assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_TRIMS_DBG_SEL_REG; no_of_bytes == 1; data[0] == i /*8'hF*/;});
       `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
       assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_TRIMS_DBG_DATA_REG; no_of_bytes == 1; });
       `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr,top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
       if(i>0 && i<9)begin
         if(cur_wdata_1[i-1] !== top_test_cfg.rd_data[0]) `nnc_error("SOC_TEST", $sformatf("READ DBG_TRIM_DATA_REG for SHADOW REG, addr_loc =%h, DATA READ ERROR!!! expected_data %8h !== rd_data %8h!!!", i, cur_wdata_1[i-1], top_test_cfg.rd_data[0]))
         else begin
            `nnc_info("SOC_TEST", $sformatf("READ DBG_TRIM_DATA_REG for SHADOW REG, READ DATA MATCH!! addr_loc =%h, expected_wdata %8h === rd_data %8h!!!", i, cur_wdata_1[i-1], top_test_cfg.rd_data[0]), UVM_LOW) 
         end
       end else begin
          if(top_test_cfg.rd_data[0] !== 8'h5A) `nnc_error("SOC_TEST", $sformatf("READ DBG_TRIM_DATA_REG for SHADOW REG, DATA READ ERROR!!! addr_loc =%h, expected_data 01011010 !== rd_data %8b!!!", i,top_test_cfg.rd_data[0]))
         else begin
          `nnc_info("SOC_TEST", $sformatf("READ DBG_TRIM_DATA_REG for SHADOW REG, READ DATA MATCH!! addr_loc =%h, expected_wdata 01011010 === rd_data %8b!!!", i,top_test_cfg.rd_data[0]), UVM_LOW) 
         end
       end

       assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_TRIMS_DBG_SEL_REG; no_of_bytes == 1; });
       `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
       if(top_test_cfg.rd_data[0] !== i)begin
         `nnc_error("SOC_TEST", $sformatf("SOC_OTP_TRIMS_DBG_SEL_REG %8h !== expected otp_trims_dbg_sel_reg %h!!!", top_test_cfg.rd_data[0], i))
       end
       else begin
         `nnc_info("SOC_TEST", $sformatf("SOC_OTP_TRIMS_DBG_SEL_REG %8h === expected otp_trims_dbg_sel_reg %h", top_test_cfg.rd_data[0], i), UVM_LOW)
       end

    end //for
    
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
        assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_DEBUG_2_REG; no_of_bytes == 1;});
        `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
        `nnc_info("SOC_TEST", $sformatf("wr_working %h !!!", top_test_cfg.rd_data[0][1]), UVM_LOW) 
     end while (top_test_cfg.rd_data[0][1] == 1'b0);

     `nnc_info("SOC_TEST", $sformatf("Wait for wr_wroking as LOW"), UVM_LOW)
     do begin
        assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_DEBUG_2_REG; no_of_bytes == 1;});
        `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
        `nnc_info("SOC_TEST", $sformatf("wr_working %h !!!", top_test_cfg.rd_data[0][1]), UVM_LOW) 
     end while (top_test_cfg.rd_data[0][1] == 1'b1);
     `nnc_info("SOC_TEST", $sformatf("Programming Done!!!"), UVM_LOW)

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

 task check_trimreg(logic [7:0] exp_value[11]);
    //for(int i=0; i<8 ; i++) begin
    //    `nnc_info("SOC_TEST", $sformatf("exp_val %8h ", exp_value[i]), UVM_LOW) 
    //end

        if(`ANA_TOP.D2A_BG_TRIM         !==   (exp_value[0] & 8'b1111_1111 ))	    `nnc_error("ana_check", $sformatf("D2A_BG_TRIM        : %8h != exp_value:%8h", `ANA_TOP.D2A_BG_TRIM,  exp_value[0]));
        if(`ANA_TOP.D2A_IREF_TRIM[7:0]  !==   (exp_value[1] & 8'b1111_1111 ))       `nnc_error("ana_check", $sformatf("D2A_IREF_TRIM : %8h != exp_value:%8h", `ANA_TOP.D2A_IREF_TRIM[7:0],  exp_value[1]));
        //if(`ANA_TOP.D2A_IREF_TRIM[6]    !==   (exp_value[1][6] & 1'b1 ))            `nnc_error("ana_check", $sformatf("D2A_IREF_TRIM[6]   : %8h != exp_value:%8h", `ANA_TOP.D2A_IREF_TRIM[6]   ,  exp_value[1][6]));

        if(({`ANA_TOP.D2A_CLDO1P8_TRIM[4],`ANA_TOP.D2A_CS_PGA_CLK_TRIM, `ANA_TOP.D2A_LDO2P8_PUMP_TRIM_CH1[1:0],`ANA_TOP.D2A_CLDO1P8_TRIM[3:0]})    !==   (exp_value[2] & 8'b1111_1111 )) `nnc_error("ana_check", $sformatf("{D2A_CLDO1P8_TRIM[4],D2A_CS_PGA_CLK_TRIM,D2A_LDO2P8_PUMP_TRIM_CH1[1:0],D2A_CLDO1P8_TRIM[3:0]}   : %8h != exp_value:%8h", {`ANA_TOP.D2A_CLDO1P8_TRIM[4],`ANA_TOP.D2A_CS_PGA_CLK_TRIM,`ANA_TOP.D2A_LDO2P8_PUMP_TRIM_CH1[1:0],`ANA_TOP.D2A_CLDO1P8_TRIM[3:0]},  exp_value[2]));


        if(`ANA_TOP.D2A_OSC2MHZ_TRIM    !==   (exp_value[3] & 8'b1111_1111 ))	    `nnc_error("ana_check", $sformatf("D2A_OSC2MHZ_TRIM   : %8h != exp_value:%8h", `ANA_TOP.D2A_OSC2MHZ_TRIM   ,  exp_value[3]));  
        if(({`ANA_TOP.D2A_CS_TRIM_CH1[2],`ANA_TOP.D2A_PUMP_CLK_TRIM_CH2, `ANA_TOP.D2A_PUMP_CLK_TRIM_CH1, `ANA_TOP.D2A_CS_TRIM_CH1[1:0],`ANA_TOP.D2A_VDAC_VTRIM_CH1[2:0]})  !==   (exp_value[4] & 8'b1111_1111 ))	    `nnc_error("ana_check", $sformatf("{D2A_CS_TRIM_CH1[2],D2A_PUMP_CLK_TRIM_CH2,D2A_PUMP_CLK_TRIM_CH1,D2A_CS_TRIM_CH1,D2A_VDAC_VTRIM_CH1[2:0]) : %8h != exp_value:%8h", {`ANA_TOP.D2A_CS_TRIM_CH1[7],`ANA_TOP.D2A_PUMP_CLK_TRIM_CH2, `ANA_TOP.D2A_PUMP_CLK_TRIM_CH1, `ANA_TOP.D2A_CS_TRIM_CH1[1:0],`ANA_TOP.D2A_VDAC_VTRIM_CH1[2:0]} ,  exp_value[4]));
        //if(`ANA_TOP.D2A_CS_TRIM_CH1     !==   ((exp_value[4] & 8'b1111_1000 ) >> 3))`nnc_error("ana_check", $sformatf("D2A_VDAC_RTRIM_CH1 : %8h != exp_value:%8h", `ANA_TOP.D2A_CS_TRIM_CH1 ,  exp_value[4]));        
        if(({`ANA_TOP.D2A_CS_TRIM_CH2[2],`ANA_TOP.D2A_LDO2P8_PUMP_TRIM_CH2[1:0],`ANA_TOP.D2A_CS_TRIM_CH2[1:0],`ANA_TOP.D2A_VDAC_VTRIM_CH2[2:0]})  !==   (exp_value[5] & 8'b1111_1111 ))	    `nnc_error("ana_check", $sformatf("{D2A_CS_TRIM_CH2[2],D2A_LDO2P8_PUMP_TRIM_CH2[1:0],D2A_CS_TRIM_CH2[1:0],D2A_VDAC_VTRIM_CH2[2:0]} : %8h != exp_value:%8h", `ANA_TOP.D2A_VDAC_VTRIM_CH2 ,  exp_value[5]));
        //if(`ANA_TOP.D2A_CS_TRIM_CH2     !==   ((exp_value[5] & 8'b1111_1000 ) >> 3))`nnc_error("ana_check", $sformatf("D2A_VDAC_RTRIM_CH1 : %8h != exp_value:%8h", `ANA_TOP.D2A_CS_TRIM_CH2 ,  exp_value[4]));
        if(({`ANA_TOP.D2A_IBIAS_IDAC_TRIM[3],`ANA_TOP.D2A_TSC_TRIM_CH1[3:0],`ANA_TOP.D2A_IBIAS_IDAC_TRIM[2:0]}) !==   (exp_value[6] & 8'b1111_1111 )) begin
           `nnc_error("ana_check", $sformatf("{D2A_IBIAS_IDAC_TRIM[3].D2A_TSC_TRIM_CH1[3:0],D2A_IBIAS_IDAC_TRIM[2:0]}: %8h != exp_value:%8h", {`ANA_TOP.D2A_IBIAS_IDAC_TRIM[3],`ANA_TOP.D2A_TSC_TRIM_CH1[3:0],`ANA_TOP.D2A_IBIAS_IDAC_TRIM[2:0]},  exp_value[6]));  
        end
        //else `nnc_info("ana_check", $sformatf("{D2A_IBIAS_IDAC_TRIM[4:3].D2A_TSC_TRIM_CH1[2:0],D2A_IBIAS_IDAC_TRIM[2:0]}: %8h != exp_value:%8h", {`ANA_TOP.D2A_IBIAS_IDAC_TRIM[4:3],`ANA_TOP.D2A_TSC_TRIM_CH1[2:0],`ANA_TOP.D2A_IBIAS_IDAC_TRIM[2:0]},  exp_value[6]), UVM_LOW)

        if(`ANA_TOP.D2A_TRIM0_SIG_SPARE !==   (exp_value[7] & 8'b1111_1111 ))begin
 	    `nnc_error("ana_check", $sformatf("D2A_TRIM0_SIG_SPARE: %8h != exp_value:%8h", `ANA_TOP.D2A_TRIM0_SIG_SPARE,  exp_value[7]));
        end
        //else  `nnc_info("ana_check", $sformatf("D2A_TRIM0_SIG_SPARE: %8h == exp_value:%8h", `ANA_TOP.D2A_TRIM0_SIG_SPARE,  exp_value[7]), UVM_LOW)
      
 endtask



endclass : `TESTNAME
