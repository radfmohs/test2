/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_spi_reg_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_spi_reg_test                                             
// Designer	: ddang@nanochap.com                                                                 
// Date		: 18-03-2024                                                                     
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_spi_reg_test
`define TESTCFG soc_spi_reg_test_cfg

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
  logic [7:0]      rd_data;

  logic [7:0]      local_data;
  logic [15:0]     local_data_1;
  rand logic [7:0] wr_data_burst[64];
  rand logic [7:0] nirs_wr_data_burst[65];
  rand logic [7:0] nirs_burst_size;       
  rand logic [7:0] nirs_burst_addr_start; 
  logic [7:0]      rd_data_burst[];

  rand logic [7:0] burst_size;

  rand logic       default_only_en;
  rand logic       nirs_reg_en; 
  rand logic       wavegen_reg_en;
  rand logic       normal_reg_en;
  rand logic       ana_reg_en;   

  rand logic       wavegen_reg_all;
  rand logic [3:0] wavegen_reg_num;

  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_spi_reg_test_cfg");
    super.new(name);
  endfunction: new

  // ===============================================
  // Adding constraints of randomization
  // -----------------------------------------------

  // testmode_sel[1:0] : 00-Normal mode, 01: Scanmode, 10: BIST mode, 11 atm0/1/2/3/4
  constraint c_testmode_sel { soft testmode_sel == 2'b00; }

  // No of bytes in a burst
  constraint c_no_of_bytes  { soft no_of_bytes == 2; }

  // pads values
  constraint c_pads         { soft pads == 8'h00; }

  // mask values
  constraint c_mask         { soft mask == 8'hff; }

  // constraint for burst size
  constraint c_burst            { burst_size inside {[4:4]}; }

  constraint c_default_only_en  { default_only_en == 1'b0;}

  constraint c_nirs_reg_en      { nirs_reg_en == 1'b1;}

  constraint c_wavegen_reg_en   { wavegen_reg_en == 1'b1;}

  constraint c_normal_reg_en    { normal_reg_en == 1'b1;}

  constraint c_ana_reg_en       { ana_reg_en == 1'b1;}

  constraint c_wavegen_reg_all  { wavegen_reg_all == 1'b1;} 
  
  constraint c_wavegen_reg_num  { wavegen_reg_num inside {[0:15]};}

  constraint c_spi_dual_mode_en { spi_dual_mode_en == 1'b0; } 

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

   nnc_register nnc_normal_reg[];
   nnc_register nnc_wavegen_reg[];
   nnc_register nnc_nirs_reg[];
   logic [7:0]  nirs_reg_index;
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
`ifdef MIX_SIM_EN
    `nnc_top.set_timeout(50s);
`else
    `nnc_top.set_timeout(2s);
`endif
    top_test_cfg = `TESTCFG::type_id::create("top_test_cfg", this);

  endfunction

  // -----------------------------------------
  // Declare the end_of_elaboration_phase function 
  // -----------------------------------------
  function void end_of_elaboration_phase(nnc_phase phase);
    `nnc_info("end_of_elaboration_phase", "Entered...",NNC_HIGH);
    super.end_of_elaboration_phase(phase);

    `nnc_info("end_of_elaboration_phase", "Exiting...",NNC_HIGH)
  endfunction

  // -----------------------------------------
  // Declare the pre_reset_phase task 
  // -----------------------------------------
  virtual task pre_reset_phase(nnc_phase phase);
    phase.raise_objection(this);

    super.pre_reset_phase(phase);

    assert(top_test_cfg.randomize());

    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    `WAVEGEN_SHORT_SHORT_INTR_COUNTER_CHECK_EN = 1'b0;
    `DUT_IF.lead_off_comp_reverse = 0;
    `DUT_IF.lead_off_ch0_comp_low_active = 0;
    `DUT_IF.lead_off_ch1_comp_low_active = 0;    
    // -------------------
    // Scoreboard enables
    // -------------------
    // `OTP_SCOREBOARD_EN = 1;
    // `SPIM_SCOREBOARD_EN = 1;
    `ANALOG_SCOREBOARD_EN = 1;
    // `IMEAS_SCOREBOARD_EN = 1;
    // `CLKRST_SCOREBOARD_EN = 1;

    `DUT_IF.default_only_en = top_test_cfg.default_only_en;
    `DUT_IF.nirs_reg_en = top_test_cfg.nirs_reg_en;
    `DUT_IF.wavegen_reg_en = top_test_cfg.wavegen_reg_en;
    `DUT_IF.normal_reg_en = top_test_cfg.normal_reg_en;
    `DUT_IF.ana_reg_en = top_test_cfg.ana_reg_en;

    `DUT_IF.wavegen_reg_all = top_test_cfg.wavegen_reg_all;
    `DUT_IF.wavegen_reg_num = top_test_cfg.wavegen_reg_num;

    `DUT_IF.spi_dual_mode_en = top_test_cfg.spi_dual_mode_en;

    phase.drop_objection(this);
  endtask : pre_reset_phase

  // -----------------------------------------
  // Declare the main_phase task of your test
  // -----------------------------------------
  virtual task main_phase(nnc_phase phase);
    logic [7:0] default_val;
    logic [7:0] mask_val;
    logic [7:0] wg_addr;
    logic [7:0] addr;
    logic [1:0] access;

    phase.raise_objection(this);

    super.main_phase(phase);

    `nnc_info("SOC_TEST", "soc_spi_reg_test start", NNC_LOW)

    // ===============================================================================================
    // Please add your code of your test here
    // -----------------------------------------------------------------------------------------------

    // -----------------------------------------------------------------------------------------------
    // Part I: Checking the Reset values of all of normal registers by using RD_RESET_CHK_NORMAL_REG 
    // -----------------------------------------------------------------------------------------------
    `nnc_info("SOC_TEST - PART I", "STARTING TO CHECK THE RESET VALUE OF NORMAL REGISTERS", NNC_LOW)

    // check init read
    //for(int i=1 ; i<nnc_normal_reg.size();i++)begin
    //  nnc_normal_reg[i].read_init();
    //end

    //for(int i=0 ; i<nnc_wavegen_reg.size();i++)begin
    //  nnc_wavegen_reg[i].read_init();
    //end

    // wait for otp reload done
    //`RD_NORMAL_REG(`SOC_OTP_DEBUG_2_REG, top_test_cfg.pads, top_test_cfg.rd_data);
    //while ( top_test_cfg.rd_data[0] !== 1'b1) begin
    //  `RD_NORMAL_REG(`SOC_OTP_DEBUG_2_REG, top_test_cfg.pads, top_test_cfg.rd_data);
    //end

    // --------------------------------------------------------------
    // Created object and initialize Normal register again if needed
    // --------------------------------------------------------------
    nnc_normal_reg = new[`NORMAL_REG_NUM+1] ;
    for(int i=1 ; i< nnc_normal_reg.size();i++)begin
      addr = `DUT_IF.reg_normal[i][39:32];
      mask_val = `DUT_IF.reg_normal[i][23:16];
      access = `DUT_IF.reg_normal[i][1:0];

      default_val = `DUT_IF.reg_normal[i][31:24];
      if(i === `SOC_CLK_CTRL_REG && ((`DUT_IF.pclk_sel !== 3'b000) || ((`DUT_IF.iclk_sel !== 4'b0011) && (`DUT_IF.iclk_pmu_ctrl_en === 1'b1))))begin   //control signal from base test(iclk_pmu_ctrl_en)
        default_val = {`DUT_IF.iclk_sel, `DUT_IF.int_clk_out, `DUT_IF.pclk_sel}; //{5'b0,`DUT_IF.pclk_sel};
        `nnc_info("SOC_TEST - NORMAL", $sformatf("addr = %0h,`DUT_IF.iclk_sel = %0h `DUT_IF.int_clk_out = %0h,`DUT_IF.pclk_sel = %0h ",addr,`DUT_IF.iclk_sel,`DUT_IF.int_clk_out, `DUT_IF.pclk_sel), NNC_LOW)
      end 
      if (i ==`SOC_OTP_DEBUG_1_REG) begin
        if(`DUT_IF.altf_sel != 2'b00) default_val = `DUT_IF.reg_normal[i][31:24] || 8'h20;
      end

      if (i ==`SOC_OTP_DEBUG_2_REG) begin
        default_val = `INIT_SOC_OTP_DEBUG_2_REG;
      end
      else if(i >=`SOC_OTP_TRIM_0_REG && i <=`SOC_OTP_TRIM_8_REG)begin
        default_val = `DUT_IF.reg_normal[i][31:24] & {8{(`DUT_IF.altf_sel != 2'b00)}};
      end 

      `nnc_info("SOC_TEST - NORMAL", $sformatf("addr = %0h,default_val = %0d, mask_val = %0d, access = %0d",addr,default_val,mask_val,access), NNC_LOW)
      nnc_normal_reg[i] = nnc_register::new($sformatf("normal_reg_%0d",i), addr, default_val, mask_val, access[1:0], 0, 0);
    end
  
    // --------------------------------------------------------------
    // Created object and initialize NIRS register again if needed
    // --------------------------------------------------------------
    nnc_nirs_reg = new[`NIRS_REG_NUM];
    `nnc_info("SOC_TEST - NIRS", $sformatf("nnc_nirs_reg size = %0d",nnc_nirs_reg.size()), NNC_LOW)
    nirs_reg_index = nnc_nirs_reg.size(); 
    for(int i=0 ; i< nirs_reg_index ;i++)begin
      addr = `DUT_IF.reg_nirs[i][39:32];
      mask_val = `DUT_IF.reg_nirs[i][23:16];
      access = `DUT_IF.reg_nirs[i][1:0];
      default_val =  `DUT_IF.reg_nirs[i][31:24];
      //if (i ==`SOC_OTP_DEBUG_2_REG) begin
      //  default_val = `INIT_SOC_OTP_DEBUG_2_REG;
      //end
 
      `nnc_info("SOC_TEST - NIRS", $sformatf("loop=%0h, addr = %0h,default_val = %0d, mask_val = %0d, access = %0d", i,addr, default_val, mask_val, access), NNC_LOW)
      nnc_nirs_reg[i] = nnc_register::new($sformatf("nirs_reg_%0d",i), addr, default_val, mask_val, access[1:0], 0, 1);

    end

    // --------------------------------------------------------------
    // Created object and initialize Wavegen register again if needed
    // --------------------------------------------------------------
    nnc_wavegen_reg = new[`WAVEGEN_DRIVER_OFFSET * (`WAVEGEN_DRIVER_NUM) + 1] ;
    `nnc_info("SOC_TEST - WAVEGEN", $sformatf("nnc_wavegen_reg size = %0d",nnc_wavegen_reg.size()), NNC_LOW)

    for (int j=0; j < `WAVEGEN_DRIVER_NUM/4; j++) begin
      for (int i=0 ; i < `WAVEGEN_DRIVER_OFFSET; i++) begin
        wg_addr  = `DUT_IF.reg_wavegen[i+ (`WAVEGEN_DRIVER_OFFSET * (j%4))][39:32] ;
        access   = `DUT_IF.reg_wavegen[i+ (`WAVEGEN_DRIVER_OFFSET * (j%4))][1:0];
        mask_val = `DUT_IF.reg_wavegen[i+ (`WAVEGEN_DRIVER_OFFSET * (j%4))][23:16];

        default_val =  `DUT_IF.reg_wavegen[i][31:24];
        if (i == `SOC_ADDR_WG_DRV_INT_REG01) begin
          default_val = `INIT_SOC_ADDR_WG_DRV_INT_REG01 + j%4;
          mask_val = 8'h0F; // bit 0 is accessible for this reg
        end
 
        `nnc_info("SOC_TEST - WAVEGEN", $sformatf("wg_addr = %0h,default_val = %0d, mask_val = %0d, access = %0d",wg_addr,default_val,mask_val,access), NNC_LOW)
        nnc_wavegen_reg[i + (`WAVEGEN_DRIVER_OFFSET * (j%4))] = nnc_register::new($sformatf("wavegen_reg_%0d",i + (`WAVEGEN_DRIVER_OFFSET * (j%4))), wg_addr, default_val, mask_val, access, 1, 0);

      end
    end

    // --------------------------------------------------
    // check init read
    // --------------------------------------------------
    // Cheking Initial values of normal registers
    // --------------------------------------------------
    if (`DUT_IF.normal_reg_en == 1'b1) begin
    `nnc_info("SOC_TEST", $sformatf("***********************************************************"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("MORMAL REG: Checking intial values and compare with Spec"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("************************************************************\n"), NNC_LOW)
    for(int i=1 ; i<nnc_normal_reg.size();i++)begin
      //if(!(i > 155 && i < 176 /* inside{[156:175]}*/))begin  //regs address range from 8'h9C to 8'hAF(not available)
       if(i == 105) continue; // address 8'h69 TSC_VDAC_NOR
       nnc_normal_reg[i].read_init();
         //`nnc_info("SOC_TEST", $sformatf("REG READ:: addr = %0h",i), NNC_LOW)
      //end
      //else begin
      //`nnc_info("SOC_TEST", $sformatf("NOT EXPECTING REG READ FOR 156 to 176::: addr = %0h",i), NNC_LOW)
      //end
    end
    end

    // --------------------------------------------------
    // Cheking Initial values of NIRS registers
    // --------------------------------------------------
    if (`DUT_IF.nirs_reg_en == 1'b1) begin // 1
    `nnc_info("SOC_TEST", $sformatf("***********************************************************"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("NIRS REG: Checking intial values and compare with Spec"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("************************************************************\n"), NNC_LOW)
    for(int i=0 ; i<nnc_nirs_reg.size(); i++) begin // 2
       nnc_nirs_reg[i].read_init();
    end // 2
    end // 1

    // --------------------------------------------------
    // Cheking Initial values of Wavegen registers
    // --------------------------------------------------
    if (`DUT_IF.wavegen_reg_en == 1'b1) begin // 1
    `nnc_info("SOC_TEST", $sformatf("***********************************************************"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("WAVGEN REG: Checking intial values and compare with Spec"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("************************************************************\n"), NNC_LOW)
    for(int j=0;j < `WAVEGEN_DRIVER_NUM ; j++)begin // 2
      if (`DUT_IF.wavegen_reg_all == 1'b0) j = `DUT_IF.wavegen_reg_num;
      `nnc_info("SOC_TEST", $sformatf("******************************************************************"), NNC_LOW)
      `nnc_info("SOC_TEST", $sformatf("WAVEGEN REG: CHECK REGS of DRIVER: %2d", j), NNC_LOW)
      `nnc_info("SOC_TEST", $sformatf("*******************************************************************\n"), NNC_LOW)
//Vuong modify
      //if(j%4 == 0)
      if(((j%4 == 0)&&(`DUT_IF.wavegen_reg_all == 1'b1)) || (`DUT_IF.wavegen_reg_all == 1'b0 ))
      `WR_NORMAL_REG(`SOC_WAVEGEN_GLOBAL_REG, (`INIT_SOC_WAVEGEN_GLOBAL_REG | ((j/4) << 1)), 8'h00);
      `nnc_info("SOC_TEST", $sformatf("INIT VALUE 0: j=%2d", j), NNC_LOW)
      for(int i=0 ; i<`WAVEGEN_DRIVER_OFFSET;i++)begin // 3
       	`nnc_info("SOC_TEST", $sformatf("INIT VALUE 1: j=%2d, i=%2d", j,i), NNC_LOW)
//Vuong add to avoid check address 0x2c    
       if(i != 8'h2c) nnc_wavegen_reg[i+ (`WAVEGEN_DRIVER_OFFSET * (j%4))].read_init();
      end // 3
      if (`DUT_IF.wavegen_reg_all == 1'b0) break;
    end // 2
    end // 1 

//Vuong add check initial value for address 0x2c
   if (`DUT_IF.wavegen_reg_en == 1'b1) begin // 1
     `nnc_info("SOC_TEST", $sformatf("WAVGEN REG: Checking intial values at 0x2c and compare with Spec"), NNC_LOW) 
     for(int j=0 ;j < `WAVEGEN_DRIVER_NUM ; j++) begin // 2 
      if (`DUT_IF.wavegen_reg_all == 1'b0) j = `DUT_IF.wavegen_reg_num;
      if(((j%4 == 0)&&(`DUT_IF.wavegen_reg_all == 1'b1)) || (`DUT_IF.wavegen_reg_all == 1'b0 ))
      `WR_NORMAL_REG(`SOC_WAVEGEN_GLOBAL_REG, (`INIT_SOC_WAVEGEN_GLOBAL_REG | ((j/4) << 1)), 8'h00);
      for(int i = 0; i < `WAVEGEN_DRIVER_OFFSET; i++) begin //3
        if(i == 8'h2c) begin //4 
         logic [7:0] data;
	    `RD_WAVEGEN_REG(i+ (`WAVEGEN_DRIVER_OFFSET * (j%4)), 8'h00, data);  
         if(data !== j)`nnc_error("TEST", $sformatf(" INIT: addr =%0h , read_data=%0h exp=%0h",i+(`WAVEGEN_DRIVER_OFFSET * (j%4)),data,j))
         `nnc_info("SOC_TEST", $sformatf("WAVGEN REG: Checking intial values at 0x2c = %0h",data), NNC_LOW)
       end //4
      end //3 
        if (`DUT_IF.wavegen_reg_all == 1'b0) break; 
     end //2
   end //1

    // ---------------------------------------------------------------------------
    // Checking Write 0 to registers
    // --------------------------------------------------------------------------- 

    // ******************************************************* 
    // check write/read to all bits as 0 to normal registers
    // *******************************************************
    if ((`DUT_IF.normal_reg_en == 1'b1) && (`DUT_IF.default_only_en !== 1'b1)) begin // 1
    `nnc_info("SOC_TEST", $sformatf("***********************************************************"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("NORMAL REG: write 0 to each bit of each register and compare"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("************************************************************\n"), NNC_LOW)
    for(int i=1 ; i<nnc_normal_reg.size();i++)begin
      top_test_cfg.wr_data[0] = 'h0;
      if(i== `SOC_GPIO_PD_CTRL_REG) continue;
      //if(i== `SOC_GPIO_DS_CTRL_REG) continue;
      if(i== `SOC_GPIO_SR_PDRV0_1_CTRL_REG) continue;
      if(i== `SOC_PMU_REG1) top_test_cfg.wr_data[0][1] =1'b1;
      //if(i== `SOC_ANA_ENABLE_REG_0 && `DUT_IF.ext_clk_en == 1'b0)  top_test_cfg.wr_data[0][1] =1'b1; // keep OSC2MHZ_EN==1
      nnc_normal_reg[i].write_read(top_test_cfg.wr_data[0]);
    end
    end

    // *******************************************************
    // check write/read to all bits as 0 to nirs registers
    // *******************************************************
    if ((`DUT_IF.nirs_reg_en == 1'b1) && (`DUT_IF.default_only_en !== 1'b1)) begin // 1
    `nnc_info("SOC_TEST", $sformatf("***********************************************************"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("NIRS REG: write 0 to each bit of each register and compare"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("************************************************************\n"), NNC_LOW) 
    // trying to achieve reading debug_sel register for all channels(CH0~CH7) and each has LED0,LED1 
    // At first LED0 enabled --> all CH0 to CH7 configured , along with debug_sel reg set to achieve reading the same reg
    // then LED1 enabled -->     all CH0 to CH7 configured , along with debug_sel reg set to achieve reading the same reg
    for(int k=0; k<2; k++)begin   //for reading led0 and led1 data for all 8 channels
       `nnc_info("SOC_TEST", $sformatf("write:0_read  :: nirs reg DEBUG_SEL_REG[4] LED num %0d", k),NNC_LOW);
       for(int j=0; j<8; j++)begin //all channel configuration, configuring each channel one by on
          `nnc_info("SOC_TEST", $sformatf("write:0_read  :: nirs reg  LED num %0d, CH %0d", k, j),NNC_LOW);
          `WR_RD_CHK_NIRS_REG(`SOC_NIRS_DEBUG_SEL_REG, {3'h0, k[0], j[3:0]}, top_test_cfg.pads, `ACCESS_SOC_NIRS_DEBUG_SEL_REG);  
          for(int i=0 ; i<nnc_nirs_reg.size(); i++) begin
            if(i== `SOC_NIRS_CTRL_CHANNEL_REG)begin
              nnc_nirs_reg[i].write_read(2**j);   //nirs_ctrl_channel_en_reg(all channels enabled one by one)
              continue;
            end
            if(i== `SOC_NIRS_CTRL_LED_REG)begin
              nnc_nirs_reg[i].write_read(2**k);   //nirs_led_enable_reg(2 led's enabled one by one), LED0 and LED1 different configuration
              continue;
            end  
            if(i == `SOC_NIRS_DEBUG_SEL_REG) continue;         
            top_test_cfg.wr_data[0] = 'h0;
            nnc_nirs_reg[i].write_read(top_test_cfg.wr_data[0]);
          end
       end
    end
    end // 1

    // *******************************************************
    // check write/read to all bits as 0 to wavegen registers
    // *******************************************************
    if ((`DUT_IF.wavegen_reg_en == 1'b1) && (`DUT_IF.default_only_en !== 1'b1)) begin // 1
    `nnc_info("SOC_TEST", $sformatf("*************************************************************"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("WAVEGEN REG: write 0 to each bit of each register and compare"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("**************************************************************\n"), NNC_LOW)
    for(int j=0;j < `WAVEGEN_DRIVER_NUM ; j++)begin
      if (`DUT_IF.wavegen_reg_all == 1'b0) j = `DUT_IF.wavegen_reg_num;
      `nnc_info("SOC_TEST", $sformatf("******************************************************************"), NNC_LOW)
      `nnc_info("SOC_TEST", $sformatf("WAVEGEN REG: CHECK REGS (write 0x00) of DRIVER: %2d", j), NNC_LOW)
      `nnc_info("SOC_TEST", $sformatf("*******************************************************************\n"), NNC_LOW)
      //for(int i=0 ; i<nnc_wavegen_reg.size();i++)begin
//Vuong modify
      //if(j%4 == 0)
      if(((j%4 == 0)&&(`DUT_IF.wavegen_reg_all == 1'b1)) || (`DUT_IF.wavegen_reg_all == 1'b0 ))
      `WR_NORMAL_REG(`SOC_WAVEGEN_GLOBAL_REG, (`INIT_SOC_WAVEGEN_GLOBAL_REG | ((j/4) << 1)), 8'h00);
      for(int i=0 ; i<`WAVEGEN_DRIVER_OFFSET;i++)begin
        top_test_cfg.wr_data[0] = 'h0;
        // if(i === `SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0 || i === `SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0 + `WAVEGEN_DRIVER_OFFSET) top_test_cfg.wr_data[0] = 'h0; 
        if(i === `SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0) top_test_cfg.wr_data[0] = 'h0;
        //nnc_wavegen_reg[i].write_read(top_test_cfg.wr_data[0]);
        nnc_wavegen_reg[i+ (`WAVEGEN_DRIVER_OFFSET * (j%4))].write_read(top_test_cfg.wr_data[0]);
      end
      if (`DUT_IF.wavegen_reg_all == 1'b0) break;
    end
    end

    // ---------------------------------------------------------------------------
    // Checking Write 1 to registers
    // ---------------------------------------------------------------------------

    // **************************************
    // check write/read to all bits as 1
    // **************************************
    if ((`DUT_IF.normal_reg_en == 1'b1) && (`DUT_IF.default_only_en !== 1'b1)) begin // 1
    `nnc_info("SOC_TEST", $sformatf("***********************************************************"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("NORMAL REG: write 1 to each bit of each register and compare"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("************************************************************\n"), NNC_LOW)
    for(int i=1 ; i<nnc_normal_reg.size();i++)begin
      top_test_cfg.wr_data[0] = 8'hFF;
      if(i== `SOC_GPIO_PD_CTRL_REG) continue;
      if(i== `SOC_STIM_PAD_CTRL1) continue;
      if(i== `SOC_GENERAL_INT_STS_7_REG) continue;
      if(i== `SOC_GENERAL_INT_STS_8_REG) continue;
      if(i== `SOC_GENERAL_INT_STS_9_REG) continue;
      if(i== `SOC_GENERAL_INT_STS_A_REG) continue;
      if(i== `SOC_GENERAL_INT_STS_B_REG) continue; 
      if(i== `SOC_GPIO_SR_PDRV0_1_CTRL_REG) continue;
      if(i== `SOC_PMU_REG1) continue; // do not write bit [0] - otp rst , otherwise otp trim will be resetted
      if(i == `SOC_FILTER_LPF_COEFF_ADDR_REG) top_test_cfg.wr_data[0] = 8'h15; // maximum supported address value has been set
 
      if (i == `SOC_STIM_MON_INT) begin 
	      `WR_NORMAL_REG(`SOC_STIM_MON_INT, 8'hff, top_test_cfg.pads);
	      `RD_NORMAL_REG(`SOC_STIM_MON_INT, top_test_cfg.pads, top_test_cfg.rd_data);
	       if(top_test_cfg.rd_data !== 8'hf8)
           `nnc_error("SOC_STIM_MON_INT TEST", $sformatf("read value of register %0h is read_data=%0h not the same as exp=8'hf8",`SOC_STIM_MON_INT, top_test_cfg.rd_data))   
      end
      else if (i == `SOC_STIM_MON_LOFF_INT_STS0_L) begin 
	      `WR_NORMAL_REG(`SOC_STIM_MON_LOFF_INT_STS0_L, 8'hff, top_test_cfg.pads);
	      `RD_NORMAL_REG(`SOC_STIM_MON_LOFF_INT_STS0_L, top_test_cfg.pads, top_test_cfg.rd_data);
	       if(top_test_cfg.rd_data !== 8'h00)
           `nnc_error("SOC_STIM_MON_LOFF_INT_STS0_L TEST", $sformatf("read value of register %0h is read_data=%0h not the same as exp=8'h00",`SOC_STIM_MON_LOFF_INT_STS0_L, top_test_cfg.rd_data))   
      end
      else if (i == `SOC_STIM_MON_LOFF_INT_STS0_H) begin 
	      `WR_NORMAL_REG(`SOC_STIM_MON_LOFF_INT_STS0_H, 8'hff, top_test_cfg.pads);
	      `RD_NORMAL_REG(`SOC_STIM_MON_LOFF_INT_STS0_H, top_test_cfg.pads, top_test_cfg.rd_data);
	       if(top_test_cfg.rd_data !== 8'h00)
           `nnc_error("SOC_STIM_MON_LOFF_INT_STS0_H TEST", $sformatf("read value of register %0h is read_data=%0h not the same as exp=8'h00",`SOC_STIM_MON_LOFF_INT_STS0_H, top_test_cfg.rd_data))   
      end
      else if (i == `SOC_STIM_MON_SHORT_INT_STS0_L) begin 
	      `WR_NORMAL_REG(`SOC_STIM_MON_SHORT_INT_STS0_L, 8'hff, top_test_cfg.pads);
	      `RD_NORMAL_REG(`SOC_STIM_MON_SHORT_INT_STS0_L, top_test_cfg.pads, top_test_cfg.rd_data);
	       if(top_test_cfg.rd_data !== 8'h00)
           `nnc_error("SOC_STIM_MON_SHORT_INT_STS0_L TEST", $sformatf("read value of register %0h is read_data=%0h not the same as exp=8'h00",`SOC_STIM_MON_SHORT_INT_STS0_L, top_test_cfg.rd_data))   
      end 
      else if (i == `SOC_STIM_MON_SHORT_INT_STS0_H) begin 
	      `WR_NORMAL_REG(`SOC_STIM_MON_SHORT_INT_STS0_H, 8'hff, top_test_cfg.pads);
	      `RD_NORMAL_REG(`SOC_STIM_MON_SHORT_INT_STS0_H, top_test_cfg.pads, top_test_cfg.rd_data);
	       if(top_test_cfg.rd_data !== 8'h00)
           `nnc_error("SOC_STIM_MON_SHORT_INT_STS0_H TEST", $sformatf("read value of register %0h is read_data=%0h not the same as exp=8'h00",`SOC_STIM_MON_SHORT_INT_STS0_H, top_test_cfg.rd_data))   
      end
      else begin
        nnc_normal_reg[i].write_read(top_test_cfg.wr_data[0]);
      end
    end
    end

    // ******************************************************
    // check write/read to all bits as 1 to nirs registers
    // ******************************************************
    if ((`DUT_IF.nirs_reg_en == 1'b1) && (`DUT_IF.default_only_en !== 1'b1)) begin // 1
    `nnc_info("SOC_TEST", $sformatf("***********************************************************"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("NIRS REG: write 1 to each bit of each register and compare"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("************************************************************\n"), NNC_LOW)
    // trying to achieve reading debug_sel register for all channels(CH0~CH7) and each has LED0,LED1 
    // At first LED0 enabled --> all CH0 to CH7 configured , along with debug_sel reg set to achieve reading the same reg
    // then LED1 enabled -->     all CH0 to CH7 configured , along with debug_sel reg set to achieve reading the same reg
    for(int k=0; k<2; k++)begin   //for reading led0 and led1 data for all 8 channels
       `nnc_info("SOC_TEST", $sformatf("write:1_read  :: nirs reg DEBUG_SEL_REG[4] LED num %0d", k),NNC_LOW);
       for(int j=0; j<8; j++)begin //all channel configuration, configuring each channel one by one
          `nnc_info("SOC_TEST", $sformatf("write:1_read  :: LED num %0d CH %0d", k, j),NNC_LOW);
          `WR_RD_CHK_NIRS_REG(`SOC_NIRS_DEBUG_SEL_REG, {3'h0, k[0], j[3:0]}, top_test_cfg.pads, `ACCESS_SOC_NIRS_DEBUG_SEL_REG);   
          for(int i=0 ; i<nnc_nirs_reg.size(); i++) begin
            if(i== `SOC_NIRS_CTRL_CHANNEL_REG)begin
              nnc_nirs_reg[i].write_read(2**j);   //nirs_ctrl_channel_en_reg(all channels enabled one by one)
              continue;
            end
            if(i== `SOC_NIRS_CTRL_LED_REG)begin
              nnc_nirs_reg[i].write_read(2**k);   //nirs_led_enable_reg(2 led's enabled one by one), LED0 and LED1 different configuration
              continue;
            end

            if(i == `SOC_NIRS_DEBUG_SEL_REG) continue;      
            top_test_cfg.wr_data[0] = 'hFF;
            nnc_nirs_reg[i].write_read(top_test_cfg.wr_data[0]);
          end
       end
    end
    end

    // ******************************************************* 
    // check write/read to all bits as 1 to wavegen registers
    // *******************************************************
    if ((`DUT_IF.wavegen_reg_en == 1'b1) && (`DUT_IF.default_only_en !== 1'b1)) begin // 1
    `nnc_info("SOC_TEST", $sformatf("*************************************************************"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("WAVEGEN REG: write 1 to each bit of each register and compare"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("**************************************************************\n"), NNC_LOW)
    for(int j=0;j < `WAVEGEN_DRIVER_NUM ; j++)begin
      if (`DUT_IF.wavegen_reg_all == 1'b0) j = `DUT_IF.wavegen_reg_num;
      // for(int i=0 ; i<nnc_wavegen_reg.size();i++)begin
      `nnc_info("SOC_TEST", $sformatf("******************************************************************"), NNC_LOW)
      `nnc_info("SOC_TEST", $sformatf("WAVEGEN REG: CHECK REGS (write 0xFF) of DRIVER: %2d", j), NNC_LOW)
      `nnc_info("SOC_TEST", $sformatf("*******************************************************************\n"), NNC_LOW)
//Vuong modify
      //if(j%4 == 0)
      if(((j%4 == 0)&&(`DUT_IF.wavegen_reg_all == 1'b1)) || (`DUT_IF.wavegen_reg_all == 1'b0 ))
      `WR_NORMAL_REG(`SOC_WAVEGEN_GLOBAL_REG, (`INIT_SOC_WAVEGEN_GLOBAL_REG | ((j/4) << 1)), 8'h00);
      for(int i=0 ; i<`WAVEGEN_DRIVER_OFFSET;i++)begin
        top_test_cfg.wr_data[0] = 8'hFF;
        // if(i === `SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0 || i === `SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0 +`WAVEGEN_DRIVER_OFFSET) top_test_cfg.wr_data[0] = 8'h7F; 
        if(i === `SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0) begin
           top_test_cfg.wr_data[0] = 8'h3F;
        end
	//nnc_wavegen_reg[i].write_read(top_test_cfg.wr_data[0]);
	//`nnc_info("SOC_TEST", $sformatf("NOT (0x3c): j= %2d, wr_data=%2d, OFFSET=%2d, i=%2d", j, wr_data[0],`WAVEGEN_DRIVER_OFFSET,i), NNC_LOW)
        nnc_wavegen_reg[i+ (`WAVEGEN_DRIVER_OFFSET * (j%4))].write_read(top_test_cfg.wr_data[0]);
      end
      if (`DUT_IF.wavegen_reg_all == 1'b0) break;
    end
    end

    // ---------------------------------------------------------------------------
    // Checking Write random to registers
    // ---------------------------------------------------------------------------

    // ************************************************
    // check write/read to all bits for random value
    // ************************************************
    if ((`DUT_IF.normal_reg_en == 1'b1) && (`DUT_IF.default_only_en !== 1'b1)) begin // 1
    `nnc_info("SOC_TEST", $sformatf("******************************************************************"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("NORMAL REG: write random to each bit of each register and compare"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("*******************************************************************\n"), NNC_LOW)
    for(int i=1 ; i<nnc_normal_reg.size();i++)begin
      top_test_cfg.wr_data[0] = $random();
      if(i== `SOC_GPIO_PD_CTRL_REG) continue;
      // if(i== `SOC_GPIO_DS_CTRL_REG) continue;
      if(i== `SOC_GPIO_SR_PDRV0_1_CTRL_REG) continue;
      if(i== `SOC_STIM_PAD_CTRL1) continue;
      if(i== `SOC_GENERAL_INT_STS_7_REG) continue;
      if(i== `SOC_GENERAL_INT_STS_8_REG) continue;
      if(i== `SOC_GENERAL_INT_STS_9_REG) continue;
      if(i== `SOC_GENERAL_INT_STS_A_REG) continue;
      if(i== `SOC_GENERAL_INT_STS_B_REG) continue; 
      if(i== `SOC_PMU_REG1) continue; // do not write bit [0] - otp rst , otherwise otp trim will be resetted
      if(i == `SOC_FILTER_LPF_COEFF_ADDR_REG) top_test_cfg.wr_data[0] = $urandom_range(0,21); // address range suuporte is 8'h0 to 8'h15
      //if(i== `SOC_ANA_ENABLE_REG_0 && `DUT_IF.ext_clk_en == 1'b0)  top_test_cfg.wr_data[0][1] =1'b1; // keep OSC2MHZ_EN==1
      if (i == `SOC_STIM_MON_INT) begin 
	      `WR_NORMAL_REG(`SOC_STIM_MON_INT, top_test_cfg.wr_data[0], top_test_cfg.pads);
	      `RD_NORMAL_REG(`SOC_STIM_MON_INT, top_test_cfg.pads, top_test_cfg.rd_data);
	       if(top_test_cfg.rd_data !== top_test_cfg.wr_data[0] & 8'hf8)
           `nnc_error("SOC_STIM_MON_INT TEST", $sformatf("read value of register %0h is read_data=%0h not the same as exp=%0h",`SOC_STIM_MON_INT, top_test_cfg.rd_data, top_test_cfg.wr_data[0] & 8'hf8))   
      end
      else if (i == `SOC_STIM_MON_LOFF_INT_STS0_L) begin 
	      `WR_NORMAL_REG(`SOC_STIM_MON_LOFF_INT_STS0_L, top_test_cfg.wr_data[0], top_test_cfg.pads);
	      `RD_NORMAL_REG(`SOC_STIM_MON_LOFF_INT_STS0_L, top_test_cfg.pads, top_test_cfg.rd_data);
	       if(top_test_cfg.rd_data !== 8'h00)
           `nnc_error("SOC_STIM_MON_LOFF_INT_STS0_L TEST", $sformatf("read value of register %0h is read_data=%0h not the same as exp=8'h00",`SOC_STIM_MON_LOFF_INT_STS0_L, top_test_cfg.rd_data))   
      end
      else if (i == `SOC_STIM_MON_LOFF_INT_STS0_H) begin 
	      `WR_NORMAL_REG(`SOC_STIM_MON_LOFF_INT_STS0_H, top_test_cfg.wr_data[0], top_test_cfg.pads);
	      `RD_NORMAL_REG(`SOC_STIM_MON_LOFF_INT_STS0_H, top_test_cfg.pads, top_test_cfg.rd_data);
	       if(top_test_cfg.rd_data !== 8'h00)
           `nnc_error("SOC_STIM_MON_LOFF_INT_STS0_H TEST", $sformatf("read value of register %0h is read_data=%0h not the same as exp=8'h00",`SOC_STIM_MON_LOFF_INT_STS0_H, top_test_cfg.rd_data))   
      end
      else if (i == `SOC_STIM_MON_SHORT_INT_STS0_L) begin 
	      `WR_NORMAL_REG(`SOC_STIM_MON_SHORT_INT_STS0_L, top_test_cfg.wr_data[0], top_test_cfg.pads);
	      `RD_NORMAL_REG(`SOC_STIM_MON_SHORT_INT_STS0_L, top_test_cfg.pads, top_test_cfg.rd_data);
	       if(top_test_cfg.rd_data !== 8'h00)
           `nnc_error("SOC_STIM_MON_SHORT_INT_STS0_L TEST", $sformatf("read value of register %0h is read_data=%0h not the same as exp=8'h00",`SOC_STIM_MON_SHORT_INT_STS0_L, top_test_cfg.rd_data))   
      end 
      else if (i == `SOC_STIM_MON_SHORT_INT_STS0_H) begin 
	      `WR_NORMAL_REG(`SOC_STIM_MON_SHORT_INT_STS0_H, top_test_cfg.wr_data[0], top_test_cfg.pads);
	      `RD_NORMAL_REG(`SOC_STIM_MON_SHORT_INT_STS0_H, top_test_cfg.pads, top_test_cfg.rd_data);
	       if(top_test_cfg.rd_data !== 8'h00)
           `nnc_error("SOC_STIM_MON_SHORT_INT_STS0_H TEST", $sformatf("read value of register %0h is read_data=%0h not the same as exp=8'h00",`SOC_STIM_MON_SHORT_INT_STS0_H, top_test_cfg.rd_data))   
      end
      else begin
        nnc_normal_reg[i].write_read(top_test_cfg.wr_data[0]);
      end
      // avoid set burst for shape register.
      `WR_NORMAL_REG(`SOC_WAVEGEN_GLOBAL_REG, 8'h00, top_test_cfg.pads);
    end
    end

    // ************************************************
    // check write/read to all bits for random value
    // ************************************************
    if ((`DUT_IF.nirs_reg_en == 1'b1) && (`DUT_IF.default_only_en !== 1'b1)) begin // 1
    `nnc_info("SOC_TEST", $sformatf("******************************************************************"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("NIRS REG: write random to each bit of each register and compare"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("*******************************************************************\n"), NNC_LOW)
    // trying to achieve reading debug_sel register for all channels(CH0~CH7) and each has LED0,LED1 so LED0 and LED1 of each channels again got different configuration.
    // At first LED0 enabled --> all CH0 to CH7 configured with different value, along with debug_sel reg set to achieve reading the same reg
    // then LED1 enabled -->     all CH0 to CH7 configured with different value, along with debug_sel reg set to achieve reading the same reg
    for(int k=0; k<2; k++)begin   //for reading led0 and led1 data for all 8 channels
         `nnc_info("SOC_TEST", $sformatf("write_read  :: nirs reg DEBUG_SEL_REG[4] LED num %0d", k),NNC_LOW);
        for(int j=0; j<8; j++)begin //all channel configuration, configuring each channel one by one
          `nnc_info("SOC_TEST", $sformatf("write_read  :: LED num %0d CH %0d", k, j),NNC_LOW);
          `WR_RD_CHK_NIRS_REG(`SOC_NIRS_DEBUG_SEL_REG, {3'h0, k[0], j[3:0]}, top_test_cfg.pads, `ACCESS_SOC_NIRS_DEBUG_SEL_REG); 
          for(int i=0 ; i<nnc_nirs_reg.size();i++)begin
             if(i== `SOC_NIRS_CTRL_CHANNEL_REG)begin
              nnc_nirs_reg[i].write_read(2**j);   //nirs_ctrl_channel_en_reg(all channels enabled one by one)
              continue;
            end
            if(i== `SOC_NIRS_CTRL_LED_REG)begin
              nnc_nirs_reg[i].write_read(2**k);   //nirs_led_enable_reg(2 led's enabled one by one), LED0 and LED1 different configuration
              continue;
            end
            if(i == `SOC_NIRS_DEBUG_SEL_REG) continue;      
            top_test_cfg.wr_data[0] = $random();
            nnc_nirs_reg[i].write_read(top_test_cfg.wr_data[0]);
          end
        end
    end
    end


    if ((`DUT_IF.wavegen_reg_en == 1'b1) && (`DUT_IF.default_only_en !== 1'b1)) begin // 1
    `nnc_info("SOC_TEST", $sformatf("******************************************************************"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("WAVEGEN REG: write random to each bit of each register and compare"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("*******************************************************************\n"), NNC_LOW)
    for(int j=0;j < `WAVEGEN_DRIVER_NUM ; j++)begin
      if (`DUT_IF.wavegen_reg_all == 1'b0) j = `DUT_IF.wavegen_reg_num;
      `nnc_info("SOC_TEST", $sformatf("******************************************************************"), NNC_LOW)
      `nnc_info("SOC_TEST", $sformatf("WAVEGEN REG: CHECK REGS (write random) of DRIVER: %2d", j), NNC_LOW)
      `nnc_info("SOC_TEST", $sformatf("*******************************************************************\n"), NNC_LOW)
//Vuong modify
      //if(j%4 == 0)
      if(((j%4 == 0)&&(`DUT_IF.wavegen_reg_all == 1'b1)) || (`DUT_IF.wavegen_reg_all == 1'b0 ))
      `WR_NORMAL_REG(`SOC_WAVEGEN_GLOBAL_REG, (`INIT_SOC_WAVEGEN_GLOBAL_REG | ((j/4) << 1)), 8'h00);
      // for(int i=0 ; i<nnc_wavegen_reg.size();i++)begin
      for(int i=0 ; i<`WAVEGEN_DRIVER_OFFSET;i++)begin
        top_test_cfg.wr_data[0] = $random();
        //if(i === `SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0 || i === `SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0 +`WAVEGEN_DRIVER_OFFSET) top_test_cfg.wr_data[0] = $urandom_range(0,8'h7F); //max addr supported is 'd127
        if(i === `SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0) begin
          top_test_cfg.wr_data[0] = $urandom_range(0, 8'h3F);
        end
	//`nnc_info("SOC_TEST", $sformatf("NOT (0x3c): j= %2d, wr_data=%2d, OFFSET=%2d, i=%2d", j, wr_data[0],`WAVEGEN_DRIVER_OFFSET,i), NNC_LOW)
        //nnc_wavegen_reg[i].write_read(top_test_cfg.wr_data[0]);
        nnc_wavegen_reg[i+ (`WAVEGEN_DRIVER_OFFSET * (j%4))].write_read(top_test_cfg.wr_data[0]);
      end
     if (`DUT_IF.wavegen_reg_all == 1'b0) break;
   end
   end

   // ************************************************* 
   // Check write burst - read burst
   // *************************************************
   // -------------------------------------------------
   // Checking normal registers
   // -------------------------------------------------
   if ((`DUT_IF.normal_reg_en == 1'b1)  && (`DUT_IF.default_only_en !== 1'b1)) begin // 1
    `nnc_info("SOC_TEST", $sformatf("******************************************************************"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("NORMAL REG: CHECK NORMAL REG WRITE BURST - READ BURST"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("*******************************************************************\n"), NNC_LOW)
    top_test_cfg.burst_size = 15;
    `WR_BURST_NORMAL_REG(`SOC_OTP_TRIM_1_REG, top_test_cfg.burst_size, 8'h00, top_test_cfg.wr_data_burst);
    `RD_BURST_NORMAL_REG(`SOC_OTP_TRIM_1_REG, top_test_cfg.burst_size, top_test_cfg.rd_data_burst);
    for (int k=0; k < top_test_cfg.burst_size; k++) begin
      if (top_test_cfg.wr_data_burst[k] !==  top_test_cfg.rd_data_burst[k])
        `nnc_error("BUSRT NORMAL", $sformatf("Index: %2d, write value: %0h is not equal to read_data: %0h", k, top_test_cfg.wr_data_burst[k], top_test_cfg.rd_data_burst[k]))
    end
   end

   // -------------------------------------------------
   // Checking nirs registers
   // -------------------------------------------------
   if ((`DUT_IF.nirs_reg_en == 1'b1) && (`DUT_IF.default_only_en !== 1'b1)) begin // 1
    `nnc_info("SOC_TEST", $sformatf("******************************************************************"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("NIRS REG: CHECK NORMAL REG WRITE BURST - READ BURST"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("*******************************************************************\n"), NNC_LOW)
    // trying to achieve reading debug_sel register for all channels(CH0~CH7) and each has LED0,LED1 so LED0 and LED1 of each channels again got different configuration.
    // At first LED0 enabled --> all CH0 to CH7 configured with different value, along with debug_sel reg set to achieve reading the same reg
    // then LED1 enabled -->     all CH0 to CH7 configured with different value, along with debug_sel reg set to achieve reading the same reg
    for(int k=0; k<2; k++)begin   //for reading led0 and led1 data for all 8 channels
         `nnc_info("SOC_TEST", $sformatf("burst write_read  :: nirs reg DEBUG_SEL_REG[4] LED num %0d", k),NNC_LOW);  
      for(int j=0; j<8; j++)begin //all channel configuration, configuring each channel one by one
         `nnc_info("SOC_TEST", $sformatf("burst write_read  :: LED num %0d CH %0d", k, j),NNC_LOW);
         //writing to nirs_address location 0x0 to 0x40(total 65 registers cont.)
         foreach(top_test_cfg.nirs_wr_data_burst[i])begin
           case(i)
             63: top_test_cfg.nirs_wr_data_burst[i] = (2**k); //8'h3;   //nirs_led_enable_reg(2 led's enabled), LED0 and LED1 different configuration
             64: top_test_cfg.nirs_wr_data_burst[i] = (2**j);           //nirs_ctrl_channel_en_reg(all channels enabled one by one)
             48: top_test_cfg.nirs_wr_data_burst[i] = {3'h0, k[0], j[3:0]};                //debug select register w.r.t channel en reg
             default:   top_test_cfg.nirs_wr_data_burst[i] = $urandom_range(255,0);
           endcase
         end 
         top_test_cfg.nirs_burst_size       = 8'h41;
         top_test_cfg.nirs_burst_addr_start = 8'h00;
         //`WR_BURST_NIRS_REG(8'h00, top_test_cfg.burst_size, 8'h00, top_test_cfg.wr_data_burst);
         `WR_BURST_NIRS_REG(8'h00, top_test_cfg.nirs_burst_size, top_test_cfg.nirs_burst_addr_start, top_test_cfg.nirs_wr_data_burst);
         //based on debug_sel register( at 0x10) value , particluar channel will be read, as all 8 channel and each channel got led0,led1 so configuration value is different for all channel w.r.t led0,led1. channeles are enabled one by one along with led0 and led1 also enabled one by one 
         //`RD_BURST_NIRS_REG(8'h00, top_test_cfg.burst_size, top_test_cfg.rd_data_burst);
         `RD_BURST_NIRS_REG(top_test_cfg.nirs_burst_addr_start, top_test_cfg.nirs_burst_size, top_test_cfg.rd_data_burst);
         //#1ms;
      end
   end
   end

   // -------------------------------------------------
   // Checking wavegen registers
   // -------------------------------------------------
   if ((`DUT_IF.wavegen_reg_en == 1'b1) && (`DUT_IF.default_only_en !== 1'b1)) begin // 1
    `nnc_info("SOC_TEST", $sformatf("******************************************************************"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("WAVGEN REG: CHECK NORMAL REG WRITE BURST - READ BURST"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("*******************************************************************\n"), NNC_LOW)
    for(int j=0;j < `WAVEGEN_DRIVER_NUM ; j++)begin
      if (`DUT_IF.wavegen_reg_all == 1'b0) j = `DUT_IF.wavegen_reg_num;
      `nnc_info("SOC_TEST", $sformatf("******************************************************************"), NNC_LOW)
      `nnc_info("SOC_TEST", $sformatf("WAVEGEN REG: CHECK BURST REGS (write random) of DRIVER: %2d", j), NNC_LOW)
      `nnc_info("SOC_TEST", $sformatf("*******************************************************************\n"), NNC_LOW)

      // Set to select DRV
//Vuong modify
      if(j%4 == 0)
      if(((j%4 == 0)&&(`DUT_IF.wavegen_reg_all == 1'b1)) || (`DUT_IF.wavegen_reg_all == 1'b0 ))
      `WR_NORMAL_REG(`SOC_WAVEGEN_GLOBAL_REG, (`INIT_SOC_WAVEGEN_GLOBAL_REG | ((j/4) << 1)), 8'h00);
      `WR_BURST_WAVEGEN_REG(`SOC_ADDR_WG_DRV_CONFIG_REG0+(`WAVEGEN_DRIVER_OFFSET * (j%4)), top_test_cfg.burst_size, 8'h00, top_test_cfg.wr_data_burst);
      `RD_BURST_WAVEGEN_REG(`SOC_ADDR_WG_DRV_CONFIG_REG0+(`WAVEGEN_DRIVER_OFFSET * (j%4)), top_test_cfg.burst_size, top_test_cfg.rd_data_burst);

      `nnc_info("SOC_TEST", $sformatf("******************************************************************"), NNC_LOW)
      `nnc_info("SOC_TEST", $sformatf("WAVEGEN REG: CHECK BURST SHAPE REGS (write random) of DRIVER: %2d", j), NNC_LOW)
      `nnc_info("SOC_TEST", $sformatf("*******************************************************************\n"), NNC_LOW)

      // Set address for access to SHAPE REG to 0x00
      assert(top_test_cfg.randomize() with {reg_addr == (`SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0 + (`WAVEGEN_DRIVER_OFFSET * (j%4))); wr_data[0] == 8'h00;});
      `WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads); 

      // Set burst mode for Wavegen Shape register (set bit-4 to 1)
      assert(top_test_cfg.randomize() with {reg_addr == `SOC_WAVEGEN_GLOBAL_REG;}); 
      `RD_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data);
      top_test_cfg.wr_data[0] = top_test_cfg.rd_data | 8'h10;
      top_test_cfg.burst_size = 64;
      `WR_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

      // Write burst to shape array
      `WR_BURST_WAVEGEN_REG(`SOC_ADDR_WG_DRV_IN_WAVE_REG01+(`WAVEGEN_DRIVER_OFFSET * (j%4)), top_test_cfg.burst_size, 8'h00, top_test_cfg.wr_data_burst);
      for (int k=0; k < top_test_cfg.burst_size; k++) begin
        case(j)
           0: begin 
              if (`SPI_REG.wg_reg_block[0].u_spi_reg_wavegen.reg_wg_driver_in_wave[k][7:0] !== top_test_cfg.wr_data_burst[63-k])
                `nnc_error("SPI TEST", $sformatf("check burst to shape for WG[%2d] addr =%02h , mem_data=%02h, exp=8'h0", j, k, `SPI_REG.wg_reg_block[0].u_spi_reg_wavegen.reg_wg_driver_in_wave[k][7:0], top_test_cfg.wr_data_burst[63-k]))
           end
           1: begin 
              if (`SPI_REG.wg_reg_block[1].u_spi_reg_wavegen.reg_wg_driver_in_wave[k][7:0] !== top_test_cfg.wr_data_burst[63-k])
                `nnc_error("SPI TEST", $sformatf("check burst to shape for WG[%2d] addr =%02h , mem_data=%02h, exp=8'h0", j, k, `SPI_REG.wg_reg_block[1].u_spi_reg_wavegen.reg_wg_driver_in_wave[k][7:0], top_test_cfg.wr_data_burst[63-k]))
           end
           2: begin 
              if (`SPI_REG.wg_reg_block[2].u_spi_reg_wavegen.reg_wg_driver_in_wave[k][7:0] !== top_test_cfg.wr_data_burst[63-k])
                `nnc_error("SPI TEST", $sformatf("check burst to shape for WG[%2d] addr =%02h , mem_data=%02h, exp=8'h0", j, k, `SPI_REG.wg_reg_block[2].u_spi_reg_wavegen.reg_wg_driver_in_wave[k][7:0], top_test_cfg.wr_data_burst[63-k]))
           end
           3: begin 
              if (`SPI_REG.wg_reg_block[3].u_spi_reg_wavegen.reg_wg_driver_in_wave[k][7:0] !== top_test_cfg.wr_data_burst[63-k])
                `nnc_error("SPI TEST", $sformatf("check burst to shape for WG[%2d] addr =%02h , mem_data=%02h, exp=8'h0", j, k, `SPI_REG.wg_reg_block[3].u_spi_reg_wavegen.reg_wg_driver_in_wave[k][7:0], top_test_cfg.wr_data_burst[63-k]))
           end
           4: begin 
              if (`SPI_REG.wg_reg_block[4].u_spi_reg_wavegen.reg_wg_driver_in_wave[k][7:0] !== top_test_cfg.wr_data_burst[63-k])
                `nnc_error("SPI TEST", $sformatf("check burst to shape for WG[%2d] addr =%02h , mem_data=%02h, exp=8'h0", j, k, `SPI_REG.wg_reg_block[4].u_spi_reg_wavegen.reg_wg_driver_in_wave[k][7:0], top_test_cfg.wr_data_burst[63-k]))
           end
           5: begin 
              if (`SPI_REG.wg_reg_block[5].u_spi_reg_wavegen.reg_wg_driver_in_wave[k][7:0] !== top_test_cfg.wr_data_burst[63-k])
                `nnc_error("SPI TEST", $sformatf("check burst to shape for WG[%2d] addr =%02h , mem_data=%02h, exp=8'h0", j, k, `SPI_REG.wg_reg_block[5].u_spi_reg_wavegen.reg_wg_driver_in_wave[k][7:0], top_test_cfg.wr_data_burst[63-k]))
           end
           6: begin 
              if (`SPI_REG.wg_reg_block[6].u_spi_reg_wavegen.reg_wg_driver_in_wave[k][7:0] !== top_test_cfg.wr_data_burst[63-k])
                `nnc_error("SPI TEST", $sformatf("check burst to shape for WG[%2d] addr =%02h , mem_data=%02h, exp=8'h0", j, k, `SPI_REG.wg_reg_block[6].u_spi_reg_wavegen.reg_wg_driver_in_wave[k][7:0], top_test_cfg.wr_data_burst[63-k]))
           end
           7: begin 
              if (`SPI_REG.wg_reg_block[7].u_spi_reg_wavegen.reg_wg_driver_in_wave[k][7:0] !== top_test_cfg.wr_data_burst[63-k])
                `nnc_error("SPI TEST", $sformatf("check burst to shape for WG[%2d] addr =%02h , mem_data=%02h, exp=8'h0", j, k, `SPI_REG.wg_reg_block[7].u_spi_reg_wavegen.reg_wg_driver_in_wave[k][7:0], top_test_cfg.wr_data_burst[63-k]))
           end
           8: begin 
              if (`SPI_REG.wg_reg_block[8].u_spi_reg_wavegen.reg_wg_driver_in_wave[k][7:0] !== top_test_cfg.wr_data_burst[63-k])
                `nnc_error("SPI TEST", $sformatf("check burst to shape for WG[%2d] addr =%02h , mem_data=%02h, exp=8'h0", j, k, `SPI_REG.wg_reg_block[8].u_spi_reg_wavegen.reg_wg_driver_in_wave[k][7:0], top_test_cfg.wr_data_burst[63-k]))
           end
           9: begin 
              if (`SPI_REG.wg_reg_block[9].u_spi_reg_wavegen.reg_wg_driver_in_wave[k][7:0] !== top_test_cfg.wr_data_burst[63-k])
                `nnc_error("SPI TEST", $sformatf("check burst to shape for WG[%2d] addr =%02h , mem_data=%02h, exp=8'h0", j, k, `SPI_REG.wg_reg_block[9].u_spi_reg_wavegen.reg_wg_driver_in_wave[k][7:0], top_test_cfg.wr_data_burst[63-k]))
           end
           10: begin 
              if (`SPI_REG.wg_reg_block[10].u_spi_reg_wavegen.reg_wg_driver_in_wave[k][7:0] !== top_test_cfg.wr_data_burst[63-k])
                `nnc_error("SPI TEST", $sformatf("check burst to shape for WG[%2d] addr =%02h , mem_data=%02h, exp=8'h0", j, k, `SPI_REG.wg_reg_block[10].u_spi_reg_wavegen.reg_wg_driver_in_wave[k][7:0], top_test_cfg.wr_data_burst[63-k]))
           end
           11: begin 
              if (`SPI_REG.wg_reg_block[11].u_spi_reg_wavegen.reg_wg_driver_in_wave[k][7:0] !== top_test_cfg.wr_data_burst[63-k])
                `nnc_error("SPI TEST", $sformatf("check burst to shape for WG[%2d] addr =%02h , mem_data=%02h, exp=8'h0", j, k, `SPI_REG.wg_reg_block[11].u_spi_reg_wavegen.reg_wg_driver_in_wave[k][7:0], top_test_cfg.wr_data_burst[63-k]))
           end
           12: begin 
              if (`SPI_REG.wg_reg_block[12].u_spi_reg_wavegen.reg_wg_driver_in_wave[k][7:0] !== top_test_cfg.wr_data_burst[63-k])
                `nnc_error("SPI TEST", $sformatf("check burst to shape for WG[%2d] addr =%02h , mem_data=%02h, exp=8'h0", j, k, `SPI_REG.wg_reg_block[12].u_spi_reg_wavegen.reg_wg_driver_in_wave[k][7:0], top_test_cfg.wr_data_burst[63-k]))
           end
           13: begin 
              if (`SPI_REG.wg_reg_block[13].u_spi_reg_wavegen.reg_wg_driver_in_wave[k][7:0] !== top_test_cfg.wr_data_burst[63-k])
                `nnc_error("SPI TEST", $sformatf("check burst to shape for WG[%2d] addr =%02h , mem_data=%02h, exp=8'h0", j, k, `SPI_REG.wg_reg_block[13].u_spi_reg_wavegen.reg_wg_driver_in_wave[k][7:0], top_test_cfg.wr_data_burst[63-k]))
           end
           14: begin 
              if (`SPI_REG.wg_reg_block[14].u_spi_reg_wavegen.reg_wg_driver_in_wave[k][7:0] !== top_test_cfg.wr_data_burst[63-k])
                `nnc_error("SPI TEST", $sformatf("check burst to shape for WG[%2d] addr =%02h , mem_data=%02h, exp=8'h0", j, k, `SPI_REG.wg_reg_block[14].u_spi_reg_wavegen.reg_wg_driver_in_wave[k][7:0], top_test_cfg.wr_data_burst[63-k]))
           end
           15: begin 
              if (`SPI_REG.wg_reg_block[15].u_spi_reg_wavegen.reg_wg_driver_in_wave[k][7:0] !== top_test_cfg.wr_data_burst[63-k])
                `nnc_error("SPI TEST", $sformatf("check burst to shape for WG[%2d] addr =%02h , mem_data=%02h, exp=8'h0", j, k, `SPI_REG.wg_reg_block[15].u_spi_reg_wavegen.reg_wg_driver_in_wave[k][7:0], top_test_cfg.wr_data_burst[63-k]))
           end
        endcase 
      end
      // Clear back
      top_test_cfg.wr_data[0] = top_test_cfg.rd_data & 8'h00;
      `WR_NORMAL_REG(`SOC_WAVEGEN_GLOBAL_REG, top_test_cfg.wr_data[0], top_test_cfg.pads);      
      if (`DUT_IF.wavegen_reg_all == 1'b0) break; 
     end
   end

    // **************************************************
    // check reserved reg
    // **************************************************
    // --------------------------------------------------
    // Checking normal register
    // --------------------------------------------------
    if ((`DUT_IF.normal_reg_en == 1'b1) && (`DUT_IF.default_only_en !== 1'b1)) begin // 1
    `nnc_info("SOC_TEST", $sformatf("******************************************************************"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("NORMAL REG: CHECK RESERVED REGS"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("*******************************************************************\n"), NNC_LOW)

    for(int i=1 ; i<nnc_normal_reg.size();i++)begin
      top_test_cfg.wr_data[0] = $random();
      if(^nnc_normal_reg[i].address === 1'bx)begin
        nnc_normal_reg[i].check_reserved_regs(i,top_test_cfg.wr_data[0]);
      end
    end
    end

    // --------------------------------------------------
    // Checking nirs register
    // --------------------------------------------------
    if ((`DUT_IF.nirs_reg_en == 1'b1) && (`DUT_IF.default_only_en !== 1'b1)) begin // 1
    `nnc_info("SOC_TEST", $sformatf("******************************************************************"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("NIRS REG: CHECK RESERVED REGS"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("*******************************************************************\n"), NNC_LOW)
    for(int i=0 ; i<nnc_nirs_reg.size(); i++) begin
      top_test_cfg.wr_data[0] = $random();
      if (^nnc_nirs_reg[i].address === 1'bx) begin
        nnc_nirs_reg[i].check_reserved_regs(i, top_test_cfg.wr_data[0]);
      end
    end
    end

    // --------------------------------------------------
    // Checking wavegen register
    // --------------------------------------------------
    if ((`DUT_IF.wavegen_reg_en == 1'b1) && (`DUT_IF.default_only_en !== 1'b1)) begin // 1
    `nnc_info("SOC_TEST", $sformatf("******************************************************************"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("WAVGEN REG: CHECK RESERVED REGS"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("*******************************************************************\n"), NNC_LOW)
    for(int j=0;j < `WAVEGEN_DRIVER_NUM ; j++)begin
      if (`DUT_IF.wavegen_reg_all == 1'b0) j = `DUT_IF.wavegen_reg_num;  
      `nnc_info("SOC_TEST", $sformatf("******************************************************************"), NNC_LOW)
      `nnc_info("SOC_TEST", $sformatf("WAVEGEN REG: CHECK RESERVED REGS of DRIVER: %2d", j), NNC_LOW)
      `nnc_info("SOC_TEST", $sformatf("*******************************************************************\n"), NNC_LOW)
//Vuong modify
      //if(j%4 == 0)
      if(((j%4 == 0)&&(`DUT_IF.wavegen_reg_all == 1'b1)) || (`DUT_IF.wavegen_reg_all == 1'b0 ))
      `WR_NORMAL_REG(`SOC_WAVEGEN_GLOBAL_REG, (`INIT_SOC_WAVEGEN_GLOBAL_REG | ((j/4) << 1)), 8'h00);
      //for(int i=0 ; i<nnc_wavegen_reg.size();i++)begin
      for(int i=0 ; i<`WAVEGEN_DRIVER_OFFSET;i++)begin
        top_test_cfg.wr_data[0] = $random();
        //if(^nnc_wavegen_reg[i].address === 1'bx)begin
        //  nnc_wavegen_reg[i].check_reserved_regs(i,top_test_cfg.wr_data[0]);
        if(^nnc_wavegen_reg[i+ (`WAVEGEN_DRIVER_OFFSET * (j%4))].address === 1'bx)begin
          nnc_wavegen_reg[i+ (`WAVEGEN_DRIVER_OFFSET * (j%4))].check_reserved_regs(i+ (`WAVEGEN_DRIVER_OFFSET * (j%4)),top_test_cfg.wr_data[0]);  
        end
      end
      if (`DUT_IF.wavegen_reg_all == 1'b0) break;
    end
    end

    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    #10000ns;
    `nnc_info("SOC_TEST", "soc_spi_reg_test end now", NNC_LOW)

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

endclass : `TESTNAME
