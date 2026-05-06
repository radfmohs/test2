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
  rand logic [7:0] wr_data_burst[10];
  logic [7:0]      rd_data_burst[];

  rand logic [3:0] burst_size;

  rand logic       default_only_en;
  rand logic       nirs_reg_en; 
  rand logic       wavegen_reg_en;
  rand logic       normal_reg_en;
  rand logic       ana_reg_en;   

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

      if(i== `SOC_VDAC_NOR0_REG)begin      
        default_val = `DUT_IF.sensor_temperature;
      end 
      `nnc_info("SOC_TEST - NORMAL", $sformatf("addr = %0h,default_val = %0d, mask_val = %0d, access = %0d",addr,default_val,mask_val,access), NNC_LOW)
      nnc_normal_reg[i] = nnc_register::new($sformatf("normal_reg_%0d",i), addr, default_val, mask_val, access[1:0], 0, 0);
    end
  
    // --------------------------------------------------------------
    // Created object and initialize NIRS register again if needed
    // --------------------------------------------------------------
    nnc_nirs_reg = new[`NIRS_REG_NUM+1];
    `nnc_info("SOC_TEST - NIRS", $sformatf("nnc_nirs_reg size = %0d",nnc_nirs_reg.size()), NNC_LOW)
  
    for(int i=0 ; i< nnc_nirs_reg.size();i++)begin
      addr = `DUT_IF.reg_nirs[i][39:32];
      mask_val = `DUT_IF.reg_nirs[i][23:16];
      access = `DUT_IF.reg_nirs[i][1:0];
      default_val =  `DUT_IF.reg_nirs[i][31:24];
      //if (i ==`SOC_OTP_DEBUG_2_REG) begin
      //  default_val = `INIT_SOC_OTP_DEBUG_2_REG;
      //end
 
      `nnc_info("SOC_TEST - NIRS", $sformatf("addr = %0h,default_val = %0d, mask_val = %0d, access = %0d", addr, default_val, mask_val, access), NNC_LOW)
      nnc_nirs_reg[i] = nnc_register::new($sformatf("nirs_reg_%0d",i), addr, default_val, mask_val, access[1:0], 0, 1);

    end

    // --------------------------------------------------------------
    // Created object and initialize Wavegen register again if needed
    // --------------------------------------------------------------
    nnc_wavegen_reg = new[`WAVEGEN_DRIVER_OFFSET * (`WAVEGEN_DRIVER_NUM) + 1] ;
    `nnc_info("SOC_TEST - WAVEGEN", $sformatf("nnc_wavegen_reg size = %0d",nnc_wavegen_reg.size()), NNC_LOW)

    for (int j=0; j < `WAVEGEN_DRIVER_NUM/4; j++) begin
      for (int i=0 ; i < `WAVEGEN_DRIVER_OFFSET; i++) begin
        wg_addr  = `DUT_IF.reg_wavegen[i+ (`WAVEGEN_DRIVER_OFFSET * j)][39:32] ;
        access   = `DUT_IF.reg_wavegen[i+ (`WAVEGEN_DRIVER_OFFSET * j)][1:0];
        mask_val = `DUT_IF.reg_wavegen[i+ (`WAVEGEN_DRIVER_OFFSET * j)][23:16];

        default_val =  `DUT_IF.reg_wavegen[i][31:24];
        if (i == `SOC_ADDR_WG_DRV_INT_REG01) begin
          default_val = `INIT_SOC_ADDR_WG_DRV_INT_REG01 + j;
          mask_val = 8'h0F; // bit 0 is accessible for this reg
        end
 
        `nnc_info("SOC_TEST - WAVEGEN", $sformatf("wg_addr = %0h,default_val = %0d, mask_val = %0d, access = %0d",wg_addr,default_val,mask_val,access), NNC_LOW)
        nnc_wavegen_reg[i + (`WAVEGEN_DRIVER_OFFSET * j)] = nnc_register::new($sformatf("wavegen_reg_%0d",i + (`WAVEGEN_DRIVER_OFFSET * (j))), wg_addr, default_val, mask_val, access, 1, 0);

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
    for(int i=1 ; i<nnc_nirs_reg.size(); i++) begin // 2
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
      `nnc_info("SOC_TEST", $sformatf("******************************************************************"), NNC_LOW)
      `nnc_info("SOC_TEST", $sformatf("WAVEGEN REG: CHECK REGS of DRIVER: %2d", j), NNC_LOW)
      `nnc_info("SOC_TEST", $sformatf("*******************************************************************\n"), NNC_LOW)
      if (j % 4 == 0) `WR_NORMAL_REG(`SOC_WAVEGEN_GLOBAL_REG, (`INIT_SOC_WAVEGEN_GLOBAL_REG | ((j/4) << 1)), 8'h00);

      //for(int i=0 ; i<nnc_wavegen_reg.size();i++)begin
      for(int i=0 ; i<`WAVEGEN_DRIVER_OFFSET;i++)begin // 3
/*
        if (i == `SOC_ADDR_WG_DRV_INT_REG01) begin
          wg_addr  = `DUT_IF.reg_wavegen[i+ (`WAVEGEN_DRIVER_OFFSET * j%4)][39:32] ;
          access   = `DUT_IF.reg_wavegen[i+ (`WAVEGEN_DRIVER_OFFSET * j%4)][1:0];
          mask_val = `DUT_IF.reg_wavegen[i+ (`WAVEGEN_DRIVER_OFFSET * j%4)][23:16];
          default_val = `INIT_SOC_ADDR_WG_DRV_INT_REG01 + j;
          mask_val = 8'h0F; // bit 0 is accessible for this reg
          `nnc_info("SOC_TEST", $sformatf("wg_addr = %0h,default_val = %0d, mask_val = %0d, access = %0d",wg_addr,default_val,mask_val,access), NNC_LOW)
          nnc_wavegen_reg[i + (`WAVEGEN_DRIVER_OFFSET * (j%4))] = nnc_register::new($sformatf("wavegen_reg_%0d",i + (`WAVEGEN_DRIVER_OFFSET * (j%4))), i, default_val, mask_val, access, 1);
        end
*/
        //nnc_wavegen_reg[i].read_init();
        nnc_wavegen_reg[i+ (`WAVEGEN_DRIVER_OFFSET * (j% 4))].read_init();
      end // 3
    end // 2
    end // 1

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
    for(int i=1 ; i<nnc_nirs_reg.size(); i++) begin
      top_test_cfg.wr_data[0] = 'h0;
      nnc_nirs_reg[i].write_read(top_test_cfg.wr_data[0]);
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
      `nnc_info("SOC_TEST", $sformatf("******************************************************************"), NNC_LOW)
      `nnc_info("SOC_TEST", $sformatf("WAVEGEN REG: CHECK REGS (write 0x00) of DRIVER: %2d", j), NNC_LOW)
      `nnc_info("SOC_TEST", $sformatf("*******************************************************************\n"), NNC_LOW)
      //for(int i=0 ; i<nnc_wavegen_reg.size();i++)begin
      if (j % 4 == 0) `WR_NORMAL_REG(`SOC_WAVEGEN_GLOBAL_REG, (`INIT_SOC_WAVEGEN_GLOBAL_REG | ((j/4) << 1)), 8'h00);
      for(int i=0 ; i<`WAVEGEN_DRIVER_OFFSET;i++)begin
        top_test_cfg.wr_data[0] = 'h0;
        // if(i === `SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0 || i === `SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0 + `WAVEGEN_DRIVER_OFFSET) top_test_cfg.wr_data[0] = 'h0; 
        if(i === `SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0) top_test_cfg.wr_data[0] = 'h0;
        //nnc_wavegen_reg[i].write_read(top_test_cfg.wr_data[0]);
        nnc_wavegen_reg[i+ (`WAVEGEN_DRIVER_OFFSET * (j%4))].write_read(top_test_cfg.wr_data[0]);
      end
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
      //if(i== `SOC_GPIO_DS_CTRL_REG) continue;
      if(i== `SOC_GPIO_SR_PDRV0_1_CTRL_REG) continue;
      if(i== `SOC_PMU_REG1) continue; // do not write bit [0] - otp rst , otherwise otp trim will be resetted
      if(i == `SOC_FILTER_LPF_COEFF_ADDR_REG) top_test_cfg.wr_data[0] = 8'h15; // maximum supported address value has been set
      nnc_normal_reg[i].write_read(top_test_cfg.wr_data[0]);
    end
    end

    // ******************************************************
    // check write/read to all bits as 1 to nirs registers
    // ******************************************************
    if ((`DUT_IF.nirs_reg_en == 1'b1) && (`DUT_IF.default_only_en !== 1'b1)) begin // 1
    `nnc_info("SOC_TEST", $sformatf("***********************************************************"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("NIRS REG: write 1 to each bit of each register and compare"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("************************************************************\n"), NNC_LOW)
    for(int i=1 ; i<nnc_nirs_reg.size(); i++) begin
      top_test_cfg.wr_data[0] = 'hFF;
      nnc_nirs_reg[i].write_read(top_test_cfg.wr_data[0]);
    end
    end

    // ******************************************************* 
    // check write/read to all bits as 0 to wavegen registers
    // *******************************************************
    if ((`DUT_IF.wavegen_reg_en == 1'b1) && (`DUT_IF.default_only_en !== 1'b1)) begin // 1
    `nnc_info("SOC_TEST", $sformatf("*************************************************************"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("WAVEGEN REG: write 1 to each bit of each register and compare"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("**************************************************************\n"), NNC_LOW)
    for(int j=0;j < `WAVEGEN_DRIVER_NUM ; j++)begin
      // for(int i=0 ; i<nnc_wavegen_reg.size();i++)begin
      `nnc_info("SOC_TEST", $sformatf("******************************************************************"), NNC_LOW)
      `nnc_info("SOC_TEST", $sformatf("WAVEGEN REG: CHECK REGS (write 0xFF) of DRIVER: %2d", j), NNC_LOW)
      `nnc_info("SOC_TEST", $sformatf("*******************************************************************\n"), NNC_LOW)
      if (j % 4 == 0) `WR_NORMAL_REG(`SOC_WAVEGEN_GLOBAL_REG, (`INIT_SOC_WAVEGEN_GLOBAL_REG | ((j/4) << 1)), 8'h00);
      for(int i=0 ; i<`WAVEGEN_DRIVER_OFFSET;i++)begin
        top_test_cfg.wr_data[0] = 8'hFF;
        // if(i === `SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0 || i === `SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0 +`WAVEGEN_DRIVER_OFFSET) top_test_cfg.wr_data[0] = 8'h7F; 
        if(i === `SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0) top_test_cfg.wr_data[0] = 8'h7F;
        //nnc_wavegen_reg[i].write_read(top_test_cfg.wr_data[0]);
        nnc_wavegen_reg[i+ (`WAVEGEN_DRIVER_OFFSET * (j%4))].write_read(top_test_cfg.wr_data[0]);
      end
    end
    end

    // ---------------------------------------------------------------------------
    // Checking Write 0 to registers
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
      if(i== `SOC_PMU_REG1) continue; // do not write bit [0] - otp rst , otherwise otp trim will be resetted
      if(i == `SOC_FILTER_LPF_COEFF_ADDR_REG) top_test_cfg.wr_data[0] = $urandom_range(0,21); // address range suuporte is 8'h0 to 8'h15
      //if(i== `SOC_ANA_ENABLE_REG_0 && `DUT_IF.ext_clk_en == 1'b0)  top_test_cfg.wr_data[0][1] =1'b1; // keep OSC2MHZ_EN==1
      nnc_normal_reg[i].write_read(top_test_cfg.wr_data[0]);
    end
    end

    // ************************************************
    // check write/read to all bits for random value
    // ************************************************
    if ((`DUT_IF.nirs_reg_en == 1'b1) && (`DUT_IF.default_only_en !== 1'b1)) begin // 1
    `nnc_info("SOC_TEST", $sformatf("******************************************************************"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("NIRS REG: write random to each bit of each register and compare"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("*******************************************************************\n"), NNC_LOW)
    for(int i=1 ; i<nnc_nirs_reg.size();i++)begin
      top_test_cfg.wr_data[0] = $random();
      nnc_nirs_reg[i].write_read(top_test_cfg.wr_data[0]);
    end
    end

    if ((`DUT_IF.wavegen_reg_en == 1'b1) && (`DUT_IF.default_only_en !== 1'b1)) begin // 1  
    `nnc_info("SOC_TEST", $sformatf("******************************************************************"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("WAVEGEN REG: write random to each bit of each register and compare"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("*******************************************************************\n"), NNC_LOW)
    for(int j=0;j < `WAVEGEN_DRIVER_NUM ; j++)begin
      `nnc_info("SOC_TEST", $sformatf("******************************************************************"), NNC_LOW)
      `nnc_info("SOC_TEST", $sformatf("WAVEGEN REG: CHECK REGS (write random) of DRIVER: %2d", j), NNC_LOW)
      `nnc_info("SOC_TEST", $sformatf("*******************************************************************\n"), NNC_LOW)
      if (j % 4 == 0) `WR_NORMAL_REG(`SOC_WAVEGEN_GLOBAL_REG, (`INIT_SOC_WAVEGEN_GLOBAL_REG | ((j/4) << 1)), 8'h00);
      // for(int i=0 ; i<nnc_wavegen_reg.size();i++)begin
      for(int i=0 ; i<`WAVEGEN_DRIVER_OFFSET;i++)begin
        top_test_cfg.wr_data[0] = $random();
        if(i === `SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0 || i === `SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0 +`WAVEGEN_DRIVER_OFFSET) top_test_cfg.wr_data[0] = $urandom_range(0,8'h7F); //max addr supported is 'd127
        //nnc_wavegen_reg[i].write_read(top_test_cfg.wr_data[0]);
        nnc_wavegen_reg[i+ (`WAVEGEN_DRIVER_OFFSET * (j%4))].write_read(top_test_cfg.wr_data[0]);
      end
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

    `WR_BURST_NORMAL_REG(`SOC_PMU_REG, top_test_cfg.burst_size, 8'h00, top_test_cfg.wr_data_burst);
    `RD_BURST_NORMAL_REG(`SOC_PMU_REG, top_test_cfg.burst_size, top_test_cfg.rd_data_burst);
   end

   // -------------------------------------------------
   // Checking nirs registers
   // -------------------------------------------------
   if ((`DUT_IF.nirs_reg_en == 1'b1) && (`DUT_IF.default_only_en !== 1'b1)) begin // 1
    `nnc_info("SOC_TEST", $sformatf("******************************************************************"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("NIRS REG: CHECK NORMAL REG WRITE BURST - READ BURST"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("*******************************************************************\n"), NNC_LOW)

   `WR_BURST_NIRS_REG(8'h00, top_test_cfg.burst_size, 8'h00, top_test_cfg.wr_data_burst);
   `RD_BURST_NIRS_REG(8'h00, top_test_cfg.burst_size, top_test_cfg.rd_data_burst);
   end

   // -------------------------------------------------
   // Checking wavegen registers
   // -------------------------------------------------
   if ((`DUT_IF.wavegen_reg_en == 1'b1) && (`DUT_IF.default_only_en !== 1'b1)) begin // 1
    `nnc_info("SOC_TEST", $sformatf("******************************************************************"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("WAVGEN REG: CHECK NORMAL REG WRITE BURST - READ BURST"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("*******************************************************************\n"), NNC_LOW)

   `WR_BURST_WAVEGEN_REG(`SOC_ADDR_WG_DRV_CONFIG_REG0, top_test_cfg.burst_size, 8'h00, top_test_cfg.wr_data_burst);
   `RD_BURST_WAVEGEN_REG(`SOC_ADDR_WG_DRV_CONFIG_REG0, top_test_cfg.burst_size, top_test_cfg.rd_data_burst);
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
    for(int i=1 ; i<nnc_nirs_reg.size(); i++) begin
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
    `nnc_info("SOC_TEST", $sformatf("******************************************************************"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("WAVEGEN REG: CHECK RESERVED REGS of DRIVER: %2d", j), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("*******************************************************************\n"), NNC_LOW)
      if (j % 4 == 0) `WR_NORMAL_REG(`SOC_WAVEGEN_GLOBAL_REG, (`INIT_SOC_WAVEGEN_GLOBAL_REG | ((j/4) << 1)), 8'h00);
      //for(int i=0 ; i<nnc_wavegen_reg.size();i++)begin
      for(int i=0 ; i<`WAVEGEN_DRIVER_OFFSET;i++)begin
        top_test_cfg.wr_data[0] = $random();
        //if(^nnc_wavegen_reg[i].address === 1'bx)begin
        //  nnc_wavegen_reg[i].check_reserved_regs(i,top_test_cfg.wr_data[0]);
        if(^nnc_wavegen_reg[i+ (`WAVEGEN_DRIVER_OFFSET * (j%4))].address === 1'bx)begin
          nnc_wavegen_reg[i+ (`WAVEGEN_DRIVER_OFFSET * (j%4))].check_reserved_regs(i+ (`WAVEGEN_DRIVER_OFFSET * (j%4)),top_test_cfg.wr_data[0]);  
        end
      end
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
