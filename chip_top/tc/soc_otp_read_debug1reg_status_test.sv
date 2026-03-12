/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_otp_read_debug1reg_status_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_otp_read_debug1reg_status_test                                             
// Designer	: supriya@nanochap.com                                                                 
// Date		: 10-06-2025                                                                     
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_otp_read_debug1reg_status_test
`define TESTCFG soc_otp_read_debug1reg_status_test_cfg

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

  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_otp_read_debug1reg_status_test_cfg");
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

   //VPP for OTP access
  constraint c_vpp         { VPP == 1'b1; }

  // Enable/Disable to program OTP
  constraint c_otp_program_en           { otp_program_en == 1'b1;}

  // Select PCLK DIV from HFOSC
  constraint c_pclk_sel                 { pclk_sel == 5 ;}  // read pulse width Tpor is 2 pclk cycles, so spi frequency set maximum and spi timing parameters to minimum in order to capture the read pulse to poll DEBUG1_REG[3]

  ////
  //constraint c_ext_clk_en  { ext_clk_en == 1;}
 
  ////
  //// Select PCLK DIV from HFOSC
  //constraint c_pclk_sel   {pclk_sel inside {[0:0]};} 

  //// Set frequency for SPI (unit of 1Khz)
  constraint c_spi_sclk_freq          { spi_sclk_freq == `SPI_MAX_FREQ;} // 14Mhz(maximum spi clock)

  constraint c_tcssc                  {  tcssc == `SPI_MIN_TCSSO;}   // ~tCSSO 
  constraint c_tsccs                  {  tsccs == `SPI_MIN_TCSH1;}   // ~tCSH1 
  constraint c_tcsh                   {  tcsh  == `SPI_MIN_TCSPW;}   //  ~tCSPW 
  constraint c_tch                    {  tch inside {60, 40}; }      // percent 


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
    `nnc_top.set_timeout(1s);
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

    `DUT_IF.spi_sclk_freq = top_test_cfg.spi_sclk_freq;

    `DUT_IF.tch      = top_test_cfg.tch;

    `DUT_IF.tcsh     = top_test_cfg.tcsh;

    `DUT_IF.tsccs    = top_test_cfg.tsccs;

    `DUT_IF.tcssc    = top_test_cfg.tcssc;

    `DUT_IF.tch      = top_test_cfg.tch; 

    //// Set PCLK Clocks
    `DUT_IF.pclk_sel = top_test_cfg.pclk_sel;

    //`DUT_IF.altf_sel = top_test_cfg.altf_sel;

    //Enable VPP
    //`DUT_IF.VPP = top_test_cfg.VPP; //force soc_top_tb.u_Nanochap_ENS2.VPP =1'b1;

    `DUT_IF.otp_program_en = top_test_cfg.otp_program_en;

    `DUT_IF.otp_vpp_delay = top_test_cfg.otp_vpp_delay;

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

    `nnc_info("SOC_TEST", "soc_otp_read_debug1reg_status_test start", NNC_LOW)

    // ==================================================================================
    // Please add your code of your test here
    // ---------------------------------------------------------------------------------- 
    
    // --------------------------------------------------------
    // This is an example RD_RESET_CHK_REG 
    // --------------------------------------------------------
    `nnc_info("SOC_TEST", "Random SPI Write function for OTP", UVM_LOW) 
    random_spi_wr_rd_otp(3'd2, 9'd0, 9'd1, 1'b1, 1'b1);    //bit[2:0] progam_status, logic[8:0] i_start_otp_addr, logic[9:0] i_last_otp_addr, bit read_otp_mem, bit i_poll_otp_ip_read   
    #1us;

   //`nnc_info("SOC_TEST", "Random SPI Write function for OTP", UVM_LOW)
   random_spi_wr_rd_otp(3'd3, 9'd0, 9'd1, 1'b1, 1'b1); //bit[2:0] progam_status, logic[8:0] i_start_otp_addr, logic[9:0] i_last_otp_addr, bit read_otp_mem, bit i_poll_otp_ip_read     
    #1us;


    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    #10000ns;
    `nnc_info("SOC_TEST", "soc_otp_read_debug1reg_status_test end now", NNC_LOW)

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
  task random_spi_wr_rd_otp(bit[2:0] progam_status, logic[8:0] i_start_otp_addr, logic[9:0] i_last_otp_addr, bit read_otp_mem, bit i_poll_otp_ip_read);
    //bit [9:0] addr; 
    //Feature : random spi write for otp
    //trim_tag 5A, unlock_key 010100, spi_wr=0
    //set spi_reg
    // assert(top_test_cfg.randomize() with { reg_addr == `SOC_PMU_REG; no_of_bytes == 8'h2; data[1][3] != 1'b1; data[1][1] != 1'b1;});
    // `DUT_IF.pclk_sel = top_test_cfg.data[8'h0][2:0];
    // `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    `nnc_info("SOC_TEST", $sformatf("i_start_otp_addr =%h, i_last_otp_addr = %h,read_otp_mem =%h, i_poll_otp_ip_read =%h ", i_start_otp_addr, i_last_otp_addr,read_otp_mem, i_poll_otp_ip_read), UVM_LOW)

    //1.set valid trim_tag =0x5A
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

//      if(progam_status === 3'd0) begin   //fixed delay used to finish program
//         #1.2ms;
//
//        #100us; //#2ms;  //just extra time window to complete OTP programming before ens2 chip power off
//      end else if(progam_status === 3'd1) begin //wait for unlock bit to clear automatically after program complete
//            `nnc_info("SOC_TEST", "wait until unlock bit clears automatically", UVM_LOW)
//            do begin
//              assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_UNLOCK_REG; no_of_bytes == 1;});
//              `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
//              `nnc_info("SOC_TEST", $sformatf("READ UNLOCK bit %h !!!", top_test_cfg.rd_data[0][0]), UVM_LOW) 
//           end while (top_test_cfg.rd_data[0][0] == 1'b1);
//            //do begin
//            //`RD_NORMAL_REG(`SOC_OTP_UNLOCK_REG,top_test_cfg.pads,top_test_cfg.rd_data[0]);
//            //`nnc_info("SOC_TEST", $sformatf("READ UNLOCK bit %h !!!", top_test_cfg.rd_data[0][0]), UVM_LOW) 
//            //end while (top_test_cfg.rd_data[0][0] === 1);
//            `nnc_info("SOC_TEST", "unlock bit cleared automatically", UVM_LOW)
//      end

      //4.When OTP_VPP_EN to 1(connect to IOPAD[8], boost VPP to 7.5V in 20us

      if(progam_status === 3'd2)begin  //wait for wr_working to complete program, poll debug1_reg[6]
          wait_wr_working_high();
      end

      else if(progam_status === 3'd3)begin  // Poll DEBUG1_REG[4] to complete program
          wait_otp_ip_wr(); ////PPROG signal monitor control im OTP IP
      end
      
      //else if(progam_status === 3'd4)begin  //Poll DEBUG1_REG OTP_CS to complete program
      //    wait_otp_ip_cs();
      //end

      //5.a.wait for OTP_VPP_EN=0
      //force soc_top_tb.u_Nanochap_ENS2.VPP =1'b1;  
      wait(soc_top_tb.IOBUF_PAD[8] === 1'b0); //(@(negedge soc_top_tb.IOBUF_PAD[8])

      //5.b.Change back VPP to VDD(1.8V) for read in 20us, in digital VDD(1.8V)== means Zero(0)
      //so VPP = will be 0 for read

      if(read_otp_mem === 1'b1)begin
          //#50us; // wait for sometime before chip power off
          ////7.
          //ens2_chip_power_off();                                   //power off -->power on--> wait for relaod_done, is not required as per latest document
          //`nnc_info("SOC_TEST", "ENS2 chip power off", UVM_LOW)  

          ////8.
          //ens2_chip_power_on();
          //`nnc_info("SOC_TEST", "ENS2 chip power on", UVM_LOW)

          //////.wait reload done
          ////wait_reload_done();
          ////`nnc_info("SOC_TEST", $sformatf("reload_done now!!!"), UVM_LOW)

          //9. read back
          //assert(top_test_cfg.randomize() with { reg_addr == `SOC_CLK_CTRL_REG; no_of_bytes == 1;});
          //`RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
          //`nnc_info("SOC_TEST", $sformatf("READ CLK_CTRL_REG of PCLK_DIV value %h !!!", top_test_cfg.rd_data[0][2:0]), UVM_LOW) 
          //if(top_test_cfg.rd_data[0][2:0] === 3'b111 || top_test_cfg.rd_data[0][2:0] === 3'b110)begin  //2MHZ/128 == 15.625KHZ, or 2MHZ/64 =31.25KHZ, for pclk_div=7/6 read is not supported

          //  `nnc_info("SOC_TEST", $sformatf("for pclk_div=7/6 read is not supported so reconfigure pclk_div to read back otp mem"), UVM_LOW)
          //  assert(top_test_cfg.randomize() with { reg_addr == `SOC_CLK_CTRL_REG; no_of_bytes == 8'h1; data[0][2:0] != 6; data[0][2:0] != 7;});
          //  `DUT_IF.pclk_sel = top_test_cfg.data[8'h0][2:0];
          //  `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
          //   assert(top_test_cfg.randomize() with { reg_addr == `SOC_CLK_CTRL_REG; no_of_bytes == 1;});
          //  `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
          //  `nnc_info("SOC_TEST", $sformatf("READ CLK_CTRL_REG, now selected PCLK_DIV value as %h !!!", top_test_cfg.rd_data[0][2:0]), UVM_LOW)
          //end 
 
          `nnc_info("SOC_TEST", $sformatf("otp addr =%h, temp_otp_wdata[%h] = %h  i_poll_otp_ip_read=%h", addr, addr, top_test_cfg.temp_otp_wdata[addr],  i_poll_otp_ip_read), UVM_LOW)
           spi_rd_for_randoimze_otp_wr(addr,top_test_cfg.temp_otp_wdata, i_poll_otp_ip_read );
           
      end  //if

      //10. for next program clear unlock register
      `WR_NORMAL_REG(`SOC_OTP_UNLOCK_REG, 8'b0,top_test_cfg.pads);    
             
    end  //for
     

       
  endtask

  //=======================================================================================================================
  task spi_rd_for_randoimze_otp_wr(bit [9:0] i_addr, logic [7:0] exp_otp_wdata[512], bit poll_otp_ip_read );

    //Feature : random spi write for otp
    //trim_tag 5A, unlock_key 010100, unlock_reg[2]=1

    ////set spi_reg
    // assert(top_test_cfg.randomize() with { reg_addr == `SOC_PMU_REG; no_of_bytes == 8'h2; data[1][3] != 1'b1; data[1][1] != 1'b1;});
    // `DUT_IF.pclk_sel = top_test_cfg.data[8'h0][2:0];
    // `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //1.set valid trim_tag =0x5A
    //assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_TRIM_0_REG; no_of_bytes == 1; data[0] == 8'h5a;});
    //`WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);
    
    //for(int i=16; i< 17 /*127*/ ; i++) begin

    //`WR_NORMAL_REG(`SOC_OTP_ADDR01_REG, {7'b0,i_addr[8]}, top_test_cfg.pads);        
    `WR_NORMAL_REG(`SOC_OTP_ADDR_REG,  i_addr[7:0], top_test_cfg.pads);


    `WR_NORMAL_REG(`SOC_OTP_UNLOCK_REG, 8'b01010_100,top_test_cfg.pads);
    `nnc_info("SOC_TEST", $sformatf("otp addr =%h, exp_otp_wdata[i] = %h, otp_prev_data =%h ", i_addr, exp_otp_wdata[i_addr], top_test_cfg.otp_prev_data[i_addr]), UVM_LOW) 

    if(poll_otp_ip_read === 1'b1) begin                       //READ HIGH TIME WINDOW is MINIMUM than SPI required WR/READ transcation need more than that time so might miss capture debug1_reg[2](ip_read bit)==1, so all spi timing parameters set to minimum
      wait_otp_ip_read();
    end
    //else if(poll_cs_or_read === 1'b0) begin
    //  wait_otp_ip_cs();
    //end
    

    `RD_NORMAL_REG(`SOC_OTP_MEM_DATA_REG,top_test_cfg.pads,top_test_cfg.rd_data[0]);

     top_test_cfg.otp_cur_data[i_addr] = (top_test_cfg.otp_prev_data[i_addr] | exp_otp_wdata[i_addr]);
     `nnc_info("SOC_TEST", $sformatf("otp_cur_data =%h", top_test_cfg.otp_cur_data[i_addr]), UVM_LOW) 

     //if(i_addr <= 9'd15)begin
     //          if(top_test_cfg.rd_data[0] !== 8'd0) `nnc_error("SOC_TEST", $sformatf(" [TRIM REGS] READ DATA ERROR!!! OTP Read Data %8h!!!", top_test_cfg.rd_data[0]))
     //         else `nnc_info("SOC_TEST", $sformatf(" [TRIM REGS] READ DATA MATCH!!! OTP Read Data %8h!!!", top_test_cfg.rd_data[0]), UVM_LOW)
     //              top_test_cfg.otp_prev_data[i_addr] =  top_test_cfg.rd_data[0];
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

     `nnc_info("SOC_TEST", $sformatf("Wait for otp_ip_PPROG as LOW before read"), UVM_LOW)
      do begin
        assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_DEBUG_1_REG; no_of_bytes == 1;});
        `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
        `nnc_info("SOC_TEST", $sformatf("otp_ip_wr %h !!!", top_test_cfg.rd_data[0][1]), UVM_LOW) 
      end while (top_test_cfg.rd_data[0][4] == 1'b1);
      `nnc_info("SOC_TEST", $sformatf("[PPROG] Programming Done!!!"), UVM_LOW)


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

  task wait_otp_ip_cs();
     `nnc_info("SOC_TEST", $sformatf("Wait for otp_ip_cs as HIGH"), UVM_LOW)
      do begin
        assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_DEBUG_1_REG; no_of_bytes == 1;});
        `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
        `nnc_info("SOC_TEST", $sformatf("otp_ip_cs %h !!!", top_test_cfg.rd_data[0][3]), UVM_LOW) 
      end while (top_test_cfg.rd_data[0][3] == 1'b0);

      `nnc_info("SOC_TEST", $sformatf("Wait for otp_ip_cs as LOW"), UVM_LOW)
      do begin
        assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_DEBUG_1_REG; no_of_bytes == 1;});
        `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
        `nnc_info("SOC_TEST", $sformatf("otp_ip_cs %h !!!", top_test_cfg.rd_data[0][3]), UVM_LOW) 
      end while (top_test_cfg.rd_data[0][3] == 1'b1);
      `nnc_info("SOC_TEST", $sformatf("Programming Done!!!"), UVM_LOW)

  endtask

  task wait_otp_ip_read();
     `nnc_info("SOC_TEST", $sformatf("Wait for otp_ip_read(POR signal monitor in otp ip) as HIGH"), UVM_LOW)
      //wait (soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_spi_top.spi_reg_u.i_DEBUG_otp[2] ===1'b1);
      //wait(soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_spi_top.spi_reg_u.i_DEBUG_otp[2] ===1'b1);
      do begin
        assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_DEBUG_1_REG; no_of_bytes == 1;});
        `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
        `nnc_info("SOC_TEST", $sformatf("otp_ip_read %h !!!", top_test_cfg.rd_data[0][2]), UVM_LOW) 
      end while (top_test_cfg.rd_data[0][3] == 1'b0);

      `nnc_info("SOC_TEST", $sformatf("Wait for otp_ip_read(POR signal monitor in otp ip) as LOW"), UVM_LOW)
      //wait(soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_spi_top.spi_reg_u.i_DEBUG_otp[2] ===1'b0);
     //wait (soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_spi_top.spi_reg_u.i_DEBUG_otp[2] ===1'b0);
      do begin
        assert(top_test_cfg.randomize() with { reg_addr == `SOC_OTP_DEBUG_1_REG; no_of_bytes == 1;});
        `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
        `nnc_info("SOC_TEST", $sformatf("otp_ip_read %h !!!", top_test_cfg.rd_data[0][2]), UVM_LOW) 
      end while (top_test_cfg.rd_data[0][3] == 1'b1);
      `nnc_info("SOC_TEST", $sformatf("Read operation Done!!!"), UVM_LOW)

  endtask


endclass : `TESTNAME
