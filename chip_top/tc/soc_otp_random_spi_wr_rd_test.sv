/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_otp_random_spi_wr_rd_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_otp_random_spi_wr_rd_test                                             
// Designer	: supriya@nanochap.com                                                                 
// Date		: 05-06-2025                                                                     
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_otp_random_spi_wr_rd_test
`define TESTCFG soc_otp_random_spi_wr_rd_test_cfg

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
  rand logic [8:0] start_otp_addr;
  rand logic [8:0] last_otp_addr;  
  logic            wr_cont =0;
  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_otp_random_spi_wr_rd_test_cfg");
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
  constraint c_pads        { pads == 8'h00; }

  // mask values
  constraint c_mask        { mask == 8'hff; }

  // Enable/Disable to program OTP
  constraint c_otp_program_en           { otp_program_en == 1'b1;}

  ////
  //constraint c_ext_clk_en  { ext_clk_en == 1;}
 
  ////
  //// Select PCLK DIV from HFOSC
  //constraint c_pclk_sel   {pclk_sel inside {[0:0]};} 

  //// Set frequency for SPI (unit of 1Khz)
  //constraint c_spi_sclk_freq          { solve spi_sclk_jitter before spi_sclk_freq; spi_sclk_freq inside {[25:25]};} // 25Khz to 16Mhz

  // address constraints
  //constraint c_otp_addr_range  { start_otp_addr inside {[0:511]};
  //                               start_otp_addr inside {[0:511]}; }


  // address constraints
  //constraint c_last_otp_addr   {last_otp_addr >= start_otp_addr; }
  

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
    `nnc_top.set_timeout(5s);
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

    `nnc_info("SOC_TEST", "soc_otp_random_spi_wr_rd_test start", NNC_LOW)

    // ==================================================================================
    // Please add your code of your test here
    // ---------------------------------------------------------------------------------- 
    disable_otp_clk_gating();
    `nnc_info("SOC_TEST", "Random SPI Write function for OTP", UVM_LOW)

    random_spi_wr_rd_otp(3'd0, 9'd113, 10'd115, 1'b1);    //0x71~0x73(which writes to address location 0x0 ~ 0x03 of OTP), these are the reserved/spare trim locations of OTP memory 
    #1us;     
       
    random_spi_wr_rd_otp(3'd0, 9'd124, 10'd127, 1'b1);    //0x7C~0x7F(which writes to address location 0x0C ~ 0x0F of OTP), these are the reserved/spare trim locations of OTP memory 
    #1us;     

    random_spi_wr_rd_otp(3'd0, 9'd112, 10'd112, 1'b1);    //0x70, 0x74~0x7B(which writes to address location 0x0, 0x04 ~ 0x0B of OTP), these are the reserved for trim locations of OTP memory, writing to these locations is invalid, OTP data will not be changing. 
    #1us; 

    random_spi_wr_rd_otp(3'd0, 9'd116, 10'd123, 1'b1);    //0x70, 0x74~0x7B(which writes to address location 0x0, 0x04 ~ 0x0B of OTP), these are the reserved for trim locations of OTP memory, writing to these locations is invalid, OTP data will not be changing. 
    #1us;         

    //          
    random_spi_wr_rd_otp(3'd0, 9'd0, 10'd1, 1'b1);        //address 0 means 0th+16th=16th(where random otp data area starts, after trim ,locations) address location will be writing
    #1us;                      
 
    `nnc_info("SOC_TEST", "Random SPI Write function for OTP, Reprogram to same location as before", UVM_LOW)
    //`nnc_info("SOC_TEST", $sformatf("start_otp_addr =%h, last_otp_addr = %h ", top_test_cfg.start_otp_addr, top_test_cfg.last_otp_addr), UVM_LOW)
    random_spi_wr_rd_otp(3'd1, 9'd0, 10'd1, 1'b1);       //reprogramming to same location, address 0 means 0th+16th=16th(where random otp data area starts, after trim ,locations) address location will be writing
    #1us;

    `nnc_info("SOC_TEST", "Random SPI Write function for OTP, Reprogram to same location as before", UVM_LOW)
    //`nnc_info("SOC_TEST", $sformatf("start_otp_addr =%h, last_otp_addr = %h ", top_test_cfg.start_otp_addr, top_test_cfg.last_otp_addr), UVM_LOW)
    random_spi_wr_rd_otp(3'd2, 9'd0, 10'd1, 1'b1);       //reprogramming to same location, address 0 means 0th+16th=16th(where random otp data area starts, after trim ,locations) address location will be writing
    #1us;

    `nnc_info("SOC_TEST", "Random SPI Write function for OTP, Reprogram to same location as before", UVM_LOW)
    //`nnc_info("SOC_TEST", $sformatf("start_otp_addr =%h, last_otp_addr = %h ", top_test_cfg.start_otp_addr, top_test_cfg.last_otp_addr), UVM_LOW)
    random_spi_wr_rd_otp(3'd3, 9'd0, 10'd1, 1'b1);       //reprogramming to same location, address 0 means 0th+16th=16th(where random otp data area starts, after trim ,locations) address location will be writing
    #1us;

    `nnc_info("SOC_TEST", "Random SPI Write function for OTP, Reprogram to same location as before", UVM_LOW)
    //`nnc_info("SOC_TEST", $sformatf("start_otp_addr =%h, last_otp_addr = %h ", top_test_cfg.start_otp_addr, top_test_cfg.last_otp_addr), UVM_LOW)
    random_spi_wr_rd_otp(3'd4, 9'd0, 10'd1, 1'b1);       //reprogramming to same location, address 0 means 0th+16th=16th(where random otp data area starts, after trim ,locations) address location will be writing
    #1us;


    `nnc_info("SOC_TEST", "Random SPI Write function for OTP, write last two address location", UVM_LOW)
    //`nnc_info("SOC_TEST", $sformatf("start_otp_addr =%h, last_otp_addr = %h ", top_test_cfg.start_otp_addr, top_test_cfg.last_otp_addr), UVM_LOW)
    random_spi_wr_rd_otp(3'd4, 9'd110, 10'd111, 1'b1);        //Pogramming to boundry location, address 110 means 110th+16th=126th(where random otp data area starts, after trim ,locations) address location will be writing
    #1us;

    `nnc_info("SOC_TEST", "Random SPI Write function for OTP, reprogram to last two address location", UVM_LOW)
    //`nnc_info("SOC_TEST", $sformatf("start_otp_addr =%h, last_otp_addr = %h ", top_test_cfg.start_otp_addr, top_test_cfg.last_otp_addr), UVM_LOW)
    random_spi_wr_rd_otp(3'd0, 9'd110, 10'd111, 1'b1);        //reprogramming to same location, address 110 means 110th+16th=126th(where random otp data area starts, after trim ,locations) address location will be writing
    #1us;

    `ifndef POSTLAYOUT_PG
       `nnc_info("SOC_TEST", "Write and Read to all location of OTP", UVM_LOW)
       //`nnc_info("SOC_TEST", $sformatf("start_otp_addr =%h, last_otp_addr = %h ", top_test_cfg.start_otp_addr, top_test_cfg.last_otp_addr), UVM_LOW)
       random_spi_wr_rd_otp(3'd1, 9'd0, 10'd111, 1'b1); // address 0 to 15 reserved for TRIM REGS
    `else
       `nnc_info("SOC_TEST", "Write and Read to all location of OTP", UVM_LOW)
       //`nnc_info("SOC_TEST", $sformatf("start_otp_addr =%h, last_otp_addr = %h ", top_test_cfg.start_otp_addr, top_test_cfg.last_otp_addr), UVM_LOW)
       random_spi_wr_rd_otp(3'd1, 9'd0, 10'd55, 1'b1); // address 0 to 15 reserved for TRIM REGS
    `endif

    `nnc_info("SOC_TEST", "Write to all location ofOTP", UVM_LOW)
    `nnc_info("SOC_TEST", "use to wait for unlock clear after program", UVM_LOW)
    //`nnc_info("SOC_TEST", $sformatf("start_otp_addr =%h, last_otp_addr = %h ", top_test_cfg.start_otp_addr, top_test_cfg.last_otp_addr), UVM_LOW)
    top_test_cfg.wr_cont = 1'b1;
    random_spi_wr_rd_otp(3'd0,  9'd48, 10'd111, 1'b0);   //just write, once writing is complete then read
    top_test_cfg.wr_cont = 1'b0;


    for(int i=48; i<111; i++)begin
        spi_rd_for_randoimze_otp_wr(i, top_test_cfg.temp_otp_wdata);
        `WR_NORMAL_REG(`SOC_OTP_UNLOCK_REG, 8'b0,top_test_cfg.pads); //as per Zhen,no auto clear for reading, need to clear unlock reg manually before next read
         @(posedge `EPROM_TOP.clk);
         #1ms;  //maximum READ operation delay considered, because when PCLK=16KHZ noticed that it missed smaple spi_rd_data signal
        //end         
    end
    #1us;
     
    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    #10000ns;
    `nnc_info("SOC_TEST", "soc_otp_random_spi_wr_rd_test end now", NNC_LOW)

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

  //=======================================================================================================================
  task random_spi_wr_rd_otp(bit[2:0] wait_for_unlock_clear, logic[8:0] i_start_otp_addr, logic[9:0] i_last_otp_addr, bit read_otp_mem);
    //bit [9:0] addr; 
    //Feature : random spi write for otp
    //trim_tag 5A, unlock_key 010100, spi_wr=0
    //set spi_reg
    // assert(top_test_cfg.randomize() with { reg_addr == `SOC_PMU_REG; no_of_bytes == 8'h2; data[1][3] != 1'b1; data[1][1] != 1'b1;});
    // `DUT_IF.pclk_sel = top_test_cfg.data[8'h0][2:0];
    // `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    `nnc_info("SOC_TEST", $sformatf("i_start_otp_addr =%h, i_last_otp_addr = %h, read_otp_mem =%h ", i_start_otp_addr, i_last_otp_addr,read_otp_mem), UVM_LOW)

    ////1.set valid trim_tag =0x5A
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_TRIM_0_REG; no_of_bytes == 1; data[0] == 8'h5a;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    assert(top_test_cfg.randomize() );
    top_test_cfg.otp_wdata.rand_mode(1);
    //top_test_cfg.otp_data_addr.rand_mode(0);
    top_test_cfg.temp_otp_wdata = top_test_cfg.otp_wdata; 

    for(bit [9:0] addr =i_start_otp_addr; addr <= i_last_otp_addr ; addr++) begin
       //top_test_cfg.otp_data_addr = i ;
      `nnc_info("SOC_TEST", $sformatf("otp addr =%h, otp_wdata[%h] = %h, temp_otp_wdata[%h] =%h", addr, addr, top_test_cfg.otp_wdata[addr], addr, top_test_cfg.temp_otp_wdata[addr]), UVM_LOW) 

      //1.Address ready, configure the address to SPI register
      //`WR_NORMAL_REG(`SOC_OTP_ADDR01_REG, {7'b0, addr[8]}, top_test_cfg.pads);        
      `WR_NORMAL_REG(`SOC_OTP_ADDR_REG, addr[7:0], top_test_cfg.pads);

      //2. Data ready, configure the data to SPI register
      `WR_NORMAL_REG(`SOC_OTP_DATA_REG, top_test_cfg.temp_otp_wdata[addr], top_test_cfg.pads); 

      //3.Configure OTP_UNLOCK register to set KEY Data
      //4.Configure OTP_UNLOCK regsiter bit0 to set UNLOCK bit to HIGH LEVEL
      `WR_NORMAL_REG(`SOC_OTP_UNLOCK_REG, 8'b01010_001,top_test_cfg.pads);
   
      //4.When OTP_VPP_EN to 1(connect to IOPAD[8], boost VPP to 7.5V in 20us
 

      if( addr == 10'd112 || (addr >= 10'd116 && addr <= 123))begin  //for invalid location while keydata set as 5'b01010 of unlock_reg
         `nnc_info("SOC_TEST", $sformatf("For Address Range 10'd112 and 10'd116 to 10''d123, so selected now is otp addr =%h", addr ), UVM_LOW) 
         #2ms;  //as writing to invalid location state machine doesn't work 
      end
      else begin
        `nnc_info("SOC_TEST", $sformatf("otp addr =%h", addr ), UVM_LOW)
        `nnc_info("SOC_TEST", $sformatf("wait for negedge of IOBUF[8] which is otp_vpp_en"), UVM_LOW)
        if(wait_for_unlock_clear === 3'd0) begin
           `nnc_info("SOC_TEST", "wait for IOPAD[8] to go low", UVM_LOW)
   
          //5.a.wait for OTP_VPP_EN=0
          //force soc_top_tb.u_Nanochap_ENS2.VPP =1'b1;
          `nnc_info("SOC_TEST", $sformatf("Wait for otp_vpp_en to go low"), UVM_LOW)  
          @(negedge `SOC_TB.VPP_EN);   
          //5.b.Change back VPP to VDD(1.8V) for read in 20us, in digital VDD(1.8V)== means Zero(0)
          //so VPP = will be 0 for read

          `nnc_info("SOC_TEST", $sformatf("Wait for otp_ip_PPROG as LOW before read"), UVM_LOW)
           do begin
             assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_DEBUG_1_REG; no_of_bytes == 1;});
             `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
             `nnc_info("SOC_TEST", $sformatf("otp_ip_wr %h !!!", top_test_cfg.rd_data[0][1]), UVM_LOW) 
           end while (top_test_cfg.rd_data[0][4] == 1'b1);
           `nnc_info("SOC_TEST", $sformatf("Programming Done!!!"), UVM_LOW)


        end else if(wait_for_unlock_clear === 3'd1) begin
              `nnc_info("SOC_TEST", "wait until unlock bit clears automatically", UVM_LOW)
              do begin
                assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_UNLOCK_REG; no_of_bytes == 1;});
                `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
                `nnc_info("SOC_TEST", $sformatf("READ UNLOCK bit %h !!!", top_test_cfg.rd_data[0][0]), UVM_LOW) 
             end while (top_test_cfg.rd_data[0][0] == 1'b1);
              `nnc_info("SOC_TEST", "unlock bit cleared automatically", UVM_LOW)
             wait(`SOC_TB.VPP_EN === 1'b0);
             //5.b.Change back VPP to VDD(1.8V) for read in 20us, in digital VDD(1.8V)== means Zero(0)
             //so VPP = will be 0 for read

          `nnc_info("SOC_TEST", $sformatf("Wait for otp_ip_PPROG as LOW before read"), UVM_LOW)
           do begin
             assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_DEBUG_1_REG; no_of_bytes == 1;});
             `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
             `nnc_info("SOC_TEST", $sformatf("otp_ip_wr %h !!!", top_test_cfg.rd_data[0][1]), UVM_LOW) 
           end while (top_test_cfg.rd_data[0][4] == 1'b1);
           `nnc_info("SOC_TEST", $sformatf("Programming Done!!!"), UVM_LOW)

        end

        else if(wait_for_unlock_clear === 3'd2)begin
          `nnc_info("SOC_TEST", "poll wr_working_high of debug1_reg", UVM_LOW)  
           wait_wr_working_high();
           wait(`SOC_TB.VPP_EN === 1'b0);
           //5.b.Change back VPP to VDD(1.8V) for read in 20us, in digital VDD(1.8V)== means Zero(0)
           //so VPP = will be 0 for read

          `nnc_info("SOC_TEST", $sformatf("Wait for otp_ip_PPROG as LOW before read"), UVM_LOW)
           do begin
             assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_DEBUG_1_REG; no_of_bytes == 1;});
             `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
             `nnc_info("SOC_TEST", $sformatf("otp_ip_wr %h !!!", top_test_cfg.rd_data[0][1]), UVM_LOW) 
           end while (top_test_cfg.rd_data[0][4] == 1'b1);
           `nnc_info("SOC_TEST", $sformatf("[PPROG] Programming Done!!!"), UVM_LOW)
        end

        else if(wait_for_unlock_clear === 3'd3)begin
          `nnc_info("SOC_TEST", "poll PPROG bit of debug1_reg", UVM_LOW)
          wait_otp_ip_wr(); ////PPROG signal monitor control im OTP IP
          wait(`SOC_TB.VPP_EN === 1'b0);
          //5.b.Change back VPP to VDD(1.8V) for read in 20us, in digital VDD(1.8V)== means Zero(0)
          //so VPP = will be 0 for read
        end

        else if(wait_for_unlock_clear === 3'd4)begin
          `nnc_info("SOC_TEST", "poll otp vpp status of debug2_reg", UVM_LOW)
          do begin
             assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_DEBUG_2_REG; no_of_bytes == 1;});
             `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
             `nnc_info("SOC_TEST", $sformatf("OTP_VPP %h !!!", top_test_cfg.rd_data[0][0]), UVM_LOW) 
          end while (top_test_cfg.rd_data[0][0] == 1'b0);
          `nnc_info("SOC_TEST", "OTP_VPP status is HIGH NOW!!!", UVM_LOW)
          do begin
             assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_DEBUG_2_REG; no_of_bytes == 1;});
             `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
             `nnc_info("SOC_TEST", $sformatf("OTP_VPP %h !!!", top_test_cfg.rd_data[0][0]), UVM_LOW) 
          end while (top_test_cfg.rd_data[0][0] == 1'b1);
          `nnc_info("SOC_TEST", "OTP_VPP status is LOW NOW!!!", UVM_LOW)

          `nnc_info("SOC_TEST", $sformatf("Wait for otp_ip_PPROG as LOW before read"), UVM_LOW)
           do begin
             assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_DEBUG_1_REG; no_of_bytes == 1;});
             `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
             `nnc_info("SOC_TEST", $sformatf("otp_ip_wr %h !!!", top_test_cfg.rd_data[0][1]), UVM_LOW) 
           end while (top_test_cfg.rd_data[0][4] == 1'b1);
           `nnc_info("SOC_TEST", $sformatf("Programming Done!!!"), UVM_LOW)

        end
           
        if(read_otp_mem === 1'b1)begin
            //#50us;
            //ens2_chip_power_off();  						//power off -->power on--> wait for relaod_done, is not required as per latest document
            //`nnc_info("SOC_TEST", "ENS2 chip power off", UVM_LOW)

            //ens2_chip_power_on();
            //`nnc_info("SOC_TEST", "ENS2 chip power on", UVM_LOW)

            //7.wait reload done
            //wait_reload_done();
            //`nnc_info("SOC_TEST", $sformatf("Wait for reload_done"), UVM_LOW)

            //8.read back
            assert(top_test_cfg.randomize() with { reg_addr == `SOC_CLK_CTRL_REG; no_of_bytes == 1;});
            `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
            `nnc_info("SOC_TEST", $sformatf("READ CLK_CTRL_REG of PCLK_DIV value %h !!!", top_test_cfg.rd_data[0][2:0]), UVM_LOW) 
            if(top_test_cfg.rd_data[0][2:0] === 3'b111 || top_test_cfg.rd_data[0][2:0] === 3'b110)begin  //2MHZ/128 == 15.625KHZ, or 2MHZ/64 =31.25KHZ, for pclk_div=7/6 read is not supported

              `nnc_info("SOC_TEST", $sformatf("for pclk_div=7/6 read is not supported so reconfigure pclk_div to read back otp mem"), UVM_LOW)
              assert(top_test_cfg.randomize() with { reg_addr == `SOC_CLK_CTRL_REG; no_of_bytes == 8'h1; data[0][2:0] != 6; data[0][2:0] != 7;});
              `DUT_IF.pclk_sel = top_test_cfg.data[8'h0][2:0];
              `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
               assert(top_test_cfg.randomize() with { reg_addr == `SOC_CLK_CTRL_REG; no_of_bytes == 1;});
              `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
              `nnc_info("SOC_TEST", $sformatf("READ CLK_CTRL_REG, now selected PCLK_DIV value as %h !!!", top_test_cfg.rd_data[0][2:0]), UVM_LOW)
            end 
  
            `nnc_info("SOC_TEST", $sformatf("Initiate Read:: otp addr =%h, temp_otp_wdata[%h] = %h ", addr, addr, top_test_cfg.temp_otp_wdata[addr]), UVM_LOW)
            spi_rd_for_randoimze_otp_wr(addr,top_test_cfg.temp_otp_wdata);

         end  //if
     end //else write to valid location 

       //9. for next program clear unlock register
       `WR_NORMAL_REG(`SOC_OTP_UNLOCK_REG, 8'b0,top_test_cfg.pads);

      //assert(top_test_cfg.randomize() with { reg_addr == `SOC_CLK_CTRL_REG; no_of_bytes == 1;});
      //`RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
      //`nnc_info("SOC_TEST", $sformatf("READ CLK_CTRL_REG of PCLK_DIV value %h !!!", top_test_cfg.rd_data[0][2:0]), UVM_LOW) 
      //if(top_test_cfg.wr_cont === 1'b1 && top_test_cfg.rd_data[0][2:0] === 3'b111)begin  //2MHZ/128 == 15.625KHZ, considered delay because for 16KHZ missed to sample spi_wr_data
      //   #1.2ms;  //maximum program delay considered (still tPDs, tPDH can be added to this) 
      //end               
    end  //for
     

       
  endtask

  //=======================================================================================================================
  task spi_rd_for_randoimze_otp_wr(bit [9:0] i_addr, logic [7:0] exp_otp_wdata[512] );

    //Feature : random spi write for otp
    //trim_tag 5A, unlock_key 010100, unlock_reg[2]=1

    ////set spi_reg
    // assert(top_test_cfg.randomize() with { reg_addr == `SOC_PMU_REG; no_of_bytes == 8'h2; data[1][3] != 1'b1; data[1][1] != 1'b1;});
    // `DUT_IF.pclk_sel = top_test_cfg.data[8'h0][2:0];
    // `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    ////1.set valid trim_tag =0x5A
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_TRIM_0_REG; no_of_bytes == 1; data[0] == 8'h5a;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    

    //1.set address
    //`WR_NORMAL_REG(`SOC_OTP_ADDR01_REG, {7'b0,i_addr[8]}, top_test_cfg.pads);        
    `WR_NORMAL_REG(`SOC_OTP_ADDR_REG,  i_addr[7:0], top_test_cfg.pads);

    //2. set unlock reg
    `WR_NORMAL_REG(`SOC_OTP_UNLOCK_REG, 8'b01010_100,top_test_cfg.pads);
    `nnc_info("SOC_TEST", $sformatf("otp addr =%h, exp_otp_wdata[i] = %h, otp_prev_data =%h ", i_addr, exp_otp_wdata[i_addr], top_test_cfg.otp_prev_data[i_addr]), UVM_LOW) 

    do begin
      assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_UNLOCK_REG; no_of_bytes == 1;});
      `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
      `nnc_info("SOC_TEST", $sformatf("spi_read bit of unlock reg %h !!!", top_test_cfg.rd_data[0][2]), UVM_LOW) 
    end while (top_test_cfg.rd_data[0][2] == 1'b0);
      `nnc_info("SOC_TEST", $sformatf("spi_read bit of unlock reg is HIGH now!!!"), UVM_LOW)

    //3.wait for 5 pclks   
    repeat(8)begin   //as mentioned in dpcument (register section) After sending the READ CMD, in theory, around 5 pclks are needed to wait to read the data.
      @(posedge `EPROM_TOP.clk);   //soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_otp_ctrl_top.clk);
      //#2ms;
    end
    //#1ms;

    //4. read mem_data_reg
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_MEM_DATA_REG; no_of_bytes == 1;});
    `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
    
    //5.compare data
    top_test_cfg.otp_cur_data[i_addr] = (top_test_cfg.otp_prev_data[i_addr] | exp_otp_wdata[i_addr]);
    `nnc_info("SOC_TEST", $sformatf("expected otp_data =%h", top_test_cfg.otp_cur_data[i_addr]), UVM_LOW) 

    //if(i_addr <= 9'd15)begin
    //           if(top_test_cfg.rd_data[0] !== 8'd0) `nnc_error("SOC_TEST", $sformatf(" [TRIM REGS] READ DATA ERROR!!! OTP Read Data %8h!!!", top_test_cfg.rd_data[0]))
    //          else `nnc_info("SOC_TEST", $sformatf(" [TRIM REGS] READ DATA MATCH!!! OTP Read Data %8h!!!", top_test_cfg.rd_data[0]), UVM_LOW)
    //               top_test_cfg.otp_prev_data[i_addr] =  top_test_cfg.rd_data[0];
    //end
    //else begin
               if(top_test_cfg.otp_cur_data[i_addr] /*exp_otp_wdata[i_addr]*/ !== top_test_cfg.rd_data[0]) `nnc_error("SOC_TEST", $sformatf(" READ DATA ERROR!!! OTP Write Data %8h !== OTP Read Data %8h!!!", top_test_cfg.otp_cur_data[i_addr] /*exp_otp_wdata[i_addr]*/, top_test_cfg.rd_data[0]))
              else `nnc_info("SOC_TEST", $sformatf("READ DATA MATCH!!! OTP Write Data %8h == OTP Read Data %8h!!!", top_test_cfg.otp_cur_data[i_addr] /*exp_otp_wdata[i_addr]*/, top_test_cfg.rd_data[0]), UVM_LOW)
                   top_test_cfg.otp_prev_data[i_addr] =  top_test_cfg.rd_data[0];

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
        assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_DEBUG_1_REG; no_of_bytes == 1;});
        `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
        `nnc_info("SOC_TEST", $sformatf("Reload_done %h !!!", top_test_cfg.rd_data[0][0]), UVM_LOW) 
     end while (top_test_cfg.rd_data[0][5] == 1'b0);
  endtask

  task set_valid_tag();
    assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_TRIM_0_REG; no_of_bytes == 1; data[0] == 8'h5a;});
    `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    `nnc_info("SOC_TEST", $sformatf("TRIM_TAG=%8h ", top_test_cfg.data[0]), UVM_LOW) 
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

endclass : `TESTNAME
