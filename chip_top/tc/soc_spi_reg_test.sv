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
  constraint c_burst {burst_size inside {[3:3]};}

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

    nnc_normal_reg = new[`NORMAL_REG_NUM+1] ;
    for(int i=1 ; i< nnc_normal_reg.size();i++)begin
      addr = `DUT_IF.reg_normal[i][39:32];
      mask_val = `DUT_IF.reg_normal[i][23:16];
      access = `DUT_IF.reg_normal[i][1:0];

      default_val = `DUT_IF.reg_normal[i][31:24];
      if(i === `SOC_CLK_CTRL_REG && ((`DUT_IF.pclk_sel !== 3'b000) || ((`DUT_IF.iclk_sel !== 4'b0011) && (`DUT_IF.iclk_pmu_ctrl_en === 1'b1))))begin   //control signal from base test(iclk_pmu_ctrl_en)
        default_val = {`DUT_IF.iclk_sel, `DUT_IF.int_clk_out, `DUT_IF.pclk_sel}; //{5'b0,`DUT_IF.pclk_sel};
        `nnc_info("SOC_TEST", $sformatf("addr = %0h,`DUT_IF.iclk_sel = %0h `DUT_IF.int_clk_out = %0h,`DUT_IF.pclk_sel = %0h ",addr,`DUT_IF.iclk_sel,`DUT_IF.int_clk_out, `DUT_IF.pclk_sel), NNC_LOW)
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
      `nnc_info("SOC_TEST", $sformatf("addr = %0h,default_val = %0d, mask_val = %0d, access = %0d",addr,default_val,mask_val,access), NNC_LOW)
      nnc_normal_reg[i] = nnc_register::new($sformatf("reg_%0d",i), addr, default_val, mask_val, access[1:0],0);
    end
  
    nnc_wavegen_reg = new[`WAVEGEN_DRIVER_OFFSET * (`WAVEGEN_DRIVER_NUM/4)] ;
    `nnc_info("SOC_TEST", $sformatf("nnc_wavegen_reg size = %0d",nnc_wavegen_reg.size()), NNC_LOW)
   
    for(int j=0;j < `WAVEGEN_DRIVER_NUM/4 ; j++)begin
      for(int i=0 ; i<`WAVEGEN_DRIVER_OFFSET;i++)begin
        wg_addr = `DUT_IF.reg_wavegen[i+ (`WAVEGEN_DRIVER_OFFSET * j)][39:32] ;
	access = `DUT_IF.reg_wavegen[i+ (`WAVEGEN_DRIVER_OFFSET * j)][1:0];
        mask_val = `DUT_IF.reg_wavegen[i+ (`WAVEGEN_DRIVER_OFFSET * j)][23:16];

        default_val =  `DUT_IF.reg_wavegen[i][31:24];
        if(i == `SOC_ADDR_WG_DRV_INT_REG01)begin
          default_val =  `INIT_SOC_ADDR_WG_DRV_INT_REG01 + j;
	  mask_val = 'h1; // bit 0 is accessible for this reg
        end

	`nnc_info("SOC_TEST", $sformatf("wg_addr = %0h,default_val = %0d, mask_val = %0d, access = %0d",wg_addr,default_val,mask_val,access), NNC_LOW)
        nnc_wavegen_reg[i + (`WAVEGEN_DRIVER_OFFSET * j)] = nnc_register::new($sformatf("wavegen_reg_%0d",i + (`WAVEGEN_DRIVER_OFFSET * j)), wg_addr, default_val, mask_val,access,1);
      end
    end

    // check init read
    for(int i=1 ; i<nnc_normal_reg.size();i++)begin
      //if(!(i > 155 && i < 176 /* inside{[156:175]}*/))begin  //regs address range from 8'h9C to 8'hAF(not available)
         nnc_normal_reg[i].read_init();
         //`nnc_info("SOC_TEST", $sformatf("REG READ:: addr = %0h",i), NNC_LOW)
      //end
      //else begin
      //`nnc_info("SOC_TEST", $sformatf("NOT EXPECTING REG READ FOR 156 to 176::: addr = %0h",i), NNC_LOW)
      //end
    end

    for(int j=0;j < `WAVEGEN_DRIVER_NUM ; j++)begin
      if (j % 4 == 0) `WR_NORMAL_REG(`SOC_WAVEGEN_GLOBAL_REG, (`INIT_SOC_WAVEGEN_GLOBAL_REG | ((j/4) << 1)), 8'h00); 
      //for(int i=0 ; i<nnc_wavegen_reg.size();i++)begin
      for(int i=0 ; i<`WAVEGEN_DRIVER_OFFSET;i++)begin
        //nnc_wavegen_reg[i].read_init();
        nnc_wavegen_reg[i+ (`WAVEGEN_DRIVER_OFFSET * (j%4))].read_init();
      end
    end

    `nnc_info("SOC_TEST", $sformatf("******************************************************"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("will write 0 to each bit of each register and compare"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("******************************************************\n"), NNC_LOW)
    // check write/read to all bits as 0
    for(int i=1 ; i<nnc_normal_reg.size();i++)begin
      top_test_cfg.wr_data[0] = 'h0;
      if(i== `SOC_GPIO_PD_CTRL_REG) continue;
      //if(i== `SOC_GPIO_DS_CTRL_REG) continue;
      if(i== `SOC_GPIO_SR_PDRV0_1_CTRL_REG) continue;
      if(i== `SOC_PMU_REG1) top_test_cfg.wr_data[0][1] =1'b1;
      //if(i== `SOC_ANA_ENABLE_REG_0 && `DUT_IF.ext_clk_en == 1'b0)  top_test_cfg.wr_data[0][1] =1'b1; // keep OSC2MHZ_EN==1
      nnc_normal_reg[i].write_read(top_test_cfg.wr_data[0]);
    end

    for(int j=0;j < `WAVEGEN_DRIVER_NUM ; j++)begin
      //for(int i=0 ; i<nnc_wavegen_reg.size();i++)begin
      if (j % 4 == 0) `WR_NORMAL_REG(`SOC_WAVEGEN_GLOBAL_REG, (`INIT_SOC_WAVEGEN_GLOBAL_REG | ((j/4) << 1)), 8'h00);
      for(int i=0 ; i<`WAVEGEN_DRIVER_OFFSET;i++)begin
        top_test_cfg.wr_data[0] = 'h0;
        // if(i === `SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0 || i === `SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0 + `WAVEGEN_DRIVER_OFFSET) top_test_cfg.wr_data[0] = 'h0; 
        if(i === `SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0) top_test_cfg.wr_data[0] = 'h0;
        nnc_wavegen_reg[i].write_read(top_test_cfg.wr_data[0]);
        nnc_wavegen_reg[i+ (`WAVEGEN_DRIVER_OFFSET * (j%4))].write_read(top_test_cfg.wr_data[0]);
      end
    end

    `nnc_info("SOC_TEST", $sformatf("******************************************************"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("will write 1 to each bit of each register and compare"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("******************************************************\n"), NNC_LOW)
    // check write/read to all bits as 1
    for(int i=1 ; i<nnc_normal_reg.size();i++)begin
      top_test_cfg.wr_data[0] = 8'hFF;
      if(i== `SOC_GPIO_PD_CTRL_REG) continue;
      //if(i== `SOC_GPIO_DS_CTRL_REG) continue;
      if(i== `SOC_GPIO_SR_PDRV0_1_CTRL_REG) continue;
      if(i== `SOC_PMU_REG1) continue; // do not write bit [0] - otp rst , otherwise otp trim will be resetted
      if(i == `SOC_FILTER_LPF_COEFF_ADDR_REG) top_test_cfg.wr_data[0] = 8'h15; // maximum supported address value has been set
      nnc_normal_reg[i].write_read(top_test_cfg.wr_data[0]);
    end

    for(int j=0;j < `WAVEGEN_DRIVER_NUM ; j++)begin
      // for(int i=0 ; i<nnc_wavegen_reg.size();i++)begin
      if (j % 4 == 0) `WR_NORMAL_REG(`SOC_WAVEGEN_GLOBAL_REG, (`INIT_SOC_WAVEGEN_GLOBAL_REG | ((j/4) << 1)), 8'h00);
      for(int i=0 ; i<`WAVEGEN_DRIVER_OFFSET;i++)begin
        top_test_cfg.wr_data[0] = 8'hFF;
        // if(i === `SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0 || i === `SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0 +`WAVEGEN_DRIVER_OFFSET) top_test_cfg.wr_data[0] = 8'h7F; 
        if(i === `SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0) top_test_cfg.wr_data[0] = 8'h7F;
        //nnc_wavegen_reg[i].write_read(top_test_cfg.wr_data[0]);
        nnc_wavegen_reg[i+ (`WAVEGEN_DRIVER_OFFSET * (j%4))].write_read(top_test_cfg.wr_data[0]);
      end
    end

    `nnc_info("SOC_TEST", $sformatf("******************************************************"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("will write random bit to each bit of each register and compare"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("******************************************************\n"), NNC_LOW)
    // check write/read to all bits for random value
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

    for(int j=0;j < `WAVEGEN_DRIVER_NUM ; j++)begin
      if (j % 4 == 0) `WR_NORMAL_REG(`SOC_WAVEGEN_GLOBAL_REG, (`INIT_SOC_WAVEGEN_GLOBAL_REG | ((j/4) << 1)), 8'h00);
      // for(int i=0 ; i<nnc_wavegen_reg.size();i++)begin
      for(int i=0 ; i<`WAVEGEN_DRIVER_OFFSET;i++)begin
        top_test_cfg.wr_data[0] = $random();
        if(i === `SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0 || i === `SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0 +`WAVEGEN_DRIVER_OFFSET) top_test_cfg.wr_data[0] = $urandom_range(0,8'h7F); //max addr supported is 'd127
        //nnc_wavegen_reg[i].write_read(top_test_cfg.wr_data[0]);
        nnc_wavegen_reg[i+ (`WAVEGEN_DRIVER_OFFSET * (j%4))].write_read(top_test_cfg.wr_data[0]);
      end
   end

   // Check write burst - read burst
   `nnc_info("SOC_TEST", $sformatf("CHECK NORMAL REG WRITE BURST - READ BURST\n"), NNC_LOW)
   `WR_BURST_NORMAL_REG(`SOC_PMU_REG, top_test_cfg.burst_size, 8'h00, top_test_cfg.wr_data_burst);
   `RD_BURST_NORMAL_REG(`SOC_PMU_REG, top_test_cfg.burst_size, top_test_cfg.rd_data_burst);

   `nnc_info("SOC_TEST", $sformatf("CHECK WAVEGEN REG WRITE BURST - READ BURST\n"), NNC_LOW)
   `WR_BURST_WAVEGEN_REG(`SOC_ADDR_WG_DRV_CONFIG_REG0, top_test_cfg.burst_size, 8'h00, top_test_cfg.wr_data_burst);
   `RD_BURST_WAVEGEN_REG(`SOC_ADDR_WG_DRV_CONFIG_REG0, top_test_cfg.burst_size, top_test_cfg.rd_data_burst);

    `nnc_info("SOC_TEST", $sformatf("******************************************************"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("check reserved register"), NNC_LOW)
    `nnc_info("SOC_TEST", $sformatf("******************************************************\n"), NNC_LOW)
    // check reserved reg
    for(int i=1 ; i<nnc_normal_reg.size();i++)begin
      top_test_cfg.wr_data[0] = $random();
      if(^nnc_normal_reg[i].address === 1'bx)begin
        nnc_normal_reg[i].check_reserved_regs(i,top_test_cfg.wr_data[0]);
      end
    end

    for(int j=0;j < `WAVEGEN_DRIVER_NUM ; j++)begin
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
