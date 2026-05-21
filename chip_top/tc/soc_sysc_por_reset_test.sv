/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_sysc_por_reset_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_sysc_por_reset_test                                             
// Designer	: pfwang@nanochap.com                                                                 
// Date		: 18-03-2024                                                                    
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_sysc_por_reset_test
`define TESTCFG soc_sysc_por_reset_test_cfg

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
  logic [7:0]      reg_rd_data0;
  logic [7:0]      reg_rd_data1;
  logic [7:0]      reg_rd_data2;

  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_sysc_por_reset_test_cfg");
    super.new(name);
    
  endfunction: new

  // ===============================================
  // Adding constraints of randomization
  // -----------------------------------------------

  // testmode_sel[1:0] : 00-Normal mode, 01: Scanmode, 10: BIST mode, 11 atm0/1/2/3/4
  constraint c_testmode_sel { soft testmode_sel == 2'b00; }


  // No of bytes in a burst
  constraint c_no_of_bytes { soft no_of_bytes == 2; }

  // pads values
  constraint c_pads        { soft pads == 8'h00; }

  // mask values
  constraint c_mask        { soft mask == 8'hff; }

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

    assert(top_test_cfg.randomize());

    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;


    // -------------------
    // Scoreboard enables
    // -------------------
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

    `nnc_info("SOC_TEST", "soc_sysc_por_reset_test start", NNC_LOW)

    // ==================================================================================
    // Please add your code of your test here
    // ---------------------------------------------------------------------------------- 
    
    // --------------------------------------------------------
    // This is an example RD_RESET_CHK_REG 
    // --------------------------------------------------------
    //assert(top_test_cfg.randomize() with {reg_addr == `SOC_ADDR_WG_DRV_CONFIG_REG0; expected_data == `INIT_SOC_ADDR_WG_DRV_CONFIG_REG0;});
    //`nnc_info("SOC_TEST", "Single Reading to a Register and doing a Check READ DATA with Initial values", NNC_LOW)
    //`RD_RESET_CHK_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.expected_data, top_test_cfg.pads);



        //STEP1:
        `RD_NORMAL_REG(`SOC_PMU_REG, top_test_cfg.pads, top_test_cfg.reg_rd_data0);
        `RD_NORMAL_REG(`SOC_ANAC_CTRL_REG, top_test_cfg.pads, top_test_cfg.reg_rd_data1);
        `RD_NORMAL_REG(`SOC_PMU_REG1, top_test_cfg.pads, top_test_cfg.reg_rd_data2); 
         `nnc_info("SOC_TEST", "READ DEFAULT REGS value before A2D_SW_POWER_POR", NNC_LOW);    
         check_reg(); 
         `nnc_info("SOC_TEST", "Check RESET Signals ENABLED before A2D_SW_POWER_POR", NNC_LOW);   
         check_rst_signals(8'h0);    //default check      
         `nnc_info("SOC_TEST", "Apply  A2D_SW_POWER_POR 10ms", NNC_LOW);
         #50ns; 
         force `SOC_TOP.A2D_SW_POWER_POR = 1'b0;
         #50ns;
         `nnc_info("SOC_TEST", "Check RESET Signals Disabled after A2D_SW_POWER_POR", NNC_LOW);
         check_rst_signals(8'h1);


        //STEP2:
         #10ms;
         release `SOC_TOP.A2D_SW_POWER_POR;
         force `SOC_TOP.A2D_SW_POWER_POR = 1'b1;
         //wait for por timeout counter value
         repeat(1000) @(posedge `RST_CTRL_TOP.hfosc_atpg); 
         `nnc_info("SOC_TEST", "Check RESET Signals back when A2D_SW_POWER_POR==1", NNC_LOW); 
         check_rst_signals(8'h0);    //reset back
         `RD_NORMAL_REG(`SOC_PMU_REG, top_test_cfg.pads, top_test_cfg.reg_rd_data0);
         `RD_NORMAL_REG(`SOC_ANAC_CTRL_REG, top_test_cfg.pads, top_test_cfg.reg_rd_data1);
         `RD_NORMAL_REG(`SOC_PMU_REG1, top_test_cfg.pads, top_test_cfg.reg_rd_data2); 
         `nnc_info("SOC_TEST", "READ REGS when A2D_SW_POWER_POR==1", NNC_LOW);    
         check_reg();    

         #20ms;


        //------------------------------------------------------------------------------------------------------------------------------------//
        //------------------------------------------------------OLD CODE BEGIN----------------------------------------------------------------//
        //------------------------------------------------------------------------------------------------------------------------------------//
        //------------------------------------------------------------------------------------------------------------------------------------//
//        //set cfg1_reg
//        assert(top_test_cfg.randomize() with {reg_addr == `SOC_PMU_REG; no_of_bytes == 8'h05; wr_data[0][0] == 0;});//disable otp rst
//        `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);           
//        //cfg1_reg_i = top_test_cfg.data[0];
//        //`DUT_IF.pclk_sel = top_test_cfg.data[8'h0][2:0];
//
//        `nnc_info("SOC_TEST", "POR RESETn 10ms", NNC_LOW);
//        force `SOC_TOP.A2D_SW_POWER_POR = 1'b0;
//        `ifdef BEHAVIORAL
//        #1ns;
//        `else
//        #50ns;
//        `endif
//        `ifdef POSTLAYOUT
//        if(`WG_DRIVER_TOP.i_presetn /*||  `SPI_TOP.i_rst_n*/ || `PMU_CTRL_TOP.poresetn_hf  || /*`LEADOFF_WRAPPER_TOP.i_presetn*/ /*|| `CLK_CTRL_TOP.presetn*/ || `CLK_CTRL_TOP.poresetn  /*|| `ANAC_TOP.presetn*/ || `EPROM_TOP.rst_n || `RST_CTRL_TOP.presetn)
//        `else
//        if(`WG_DRIVER_TOP.i_presetn ||  `SPI_TOP.i_rst_n || `PMU_CTRL_TOP.poresetn_hf  || /*`LEADOFF_WRAPPER_TOP.i_presetn ||*/ `CLK_CTRL_TOP.presetn || `CLK_CTRL_TOP.poresetn  || `ANAC_TOP.presetn || `EPROM_TOP.rst_n)
//        `endif
//            `nnc_error("SOC_TEST", "RESETn error!!!");
//
//        //fork:_reset
//            #10ms;
//        //    begin  wait(!`SOC_TOP.IOBUF_PAD[1]) `nnc_error("SOC_TEST", "RESET error!!!"); end
//        ///join_any
//        //disable _reset;
//        
//        release `SOC_TOP.A2D_SW_POWER_POR;
//        force `SOC_TOP.A2D_SW_POWER_POR = 1'b1;
//
//        #10ns;
//        //wait por_cnt
//        repeat(800) @(posedge `CLK_CTRL_TOP.pclk);
//        
//        `ifdef POSTLAYOUT 
//        if(`WG_DRIVER_TOP.i_presetn /*&&  `SPI_TOP.i_rst_n*/ && `PMU_CTRL_TOP.poresetn_hf  && /*`LEADOFF_WRAPPER_TOP.i_presetn*/ /*&& `CLK_CTRL_TOP.presetn*/ && `CLK_CTRL_TOP.poresetn  /*&& `ANAC_TOP.presetn*/ && `EPROM_TOP.rst_n && `RST_CTRL_TOP.presetn);
//        `else
//        if(`WG_DRIVER_TOP.i_presetn &&  `SPI_TOP.i_rst_n && `PMU_CTRL_TOP.poresetn_hf  && /*`LEADOFF_WRAPPER_TOP.i_presetn &&*/ `CLK_CTRL_TOP.presetn && `CLK_CTRL_TOP.poresetn  && `ANAC_TOP.presetn && `EPROM_TOP.rst_n);
//        `endif
//        else  `nnc_error("SOC_TEST", "RESETn error!!!");        
//        
//        
//
//        //check default reg
//        assert(top_test_cfg.randomize() with { reg_addr == `SOC_PMU_REG; no_of_bytes == 8'h2; });
//        `RD_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
//        check_reg();
        //------------------------------------------------------------------------------------------------------------------------------------//
        //------------------------------------------------------OLD CODE END------------------------------------------------------------------//
        //------------------------------------------------------------------------------------------------------------------------------------//
        //------------------------------------------------------------------------------------------------------------------------------------//


    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    #10000ns;
    `nnc_info("SOC_TEST", "soc_sysc_por_reset_test end now", NNC_LOW)

    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ==================================================================================

    phase.drop_objection(this);
  endtask: main_phase

    task check_reg();
        if(top_test_cfg.reg_rd_data0 !==      `INIT_SOC_PMU_REG          )	`nnc_error("reg_check", $sformatf(" SOC_PMU_REG =%0h, INIT_SOC_PMU_REG =%0h",top_test_cfg.rd_data[0],`INIT_SOC_PMU_REG));
        if(top_test_cfg.reg_rd_data1 !==      `INIT_SOC_ANAC_CTRL_REG    )	`nnc_error("reg_check", $sformatf(" SOC_ANAC_CTRL_REG =%0h, INIT_SOC_ANAC_CTRL_REG =%0h   ",top_test_cfg.rd_data[1],`INIT_SOC_ANAC_CTRL_REG));
        if(top_test_cfg.reg_rd_data2 !==      `INIT_SOC_PMU_REG1         )	`nnc_error("reg_check", $sformatf(" SOC_PMU_REG1_REG =%0h, INIT_SOC_PMU_REG1 =%0h    ",top_test_cfg.rd_data[2],`INIT_SOC_PMU_REG1));
        //if(top_test_cfg.rd_data[1] !==      `INIT_SOC_PMU_REG          )	`nnc_error("reg_check", " INIT_SOC_PMU_REG         ");
        //if(top_test_cfg.rd_data[0] !==      `INIT_SOC_CLK_CTRL_REG     )	`nnc_error("reg_check", " INIT_SOC_CLK_CTRL_REG    ");
        //if(top_test_cfg.rd_data[7] !==      `INIT_SOC_ANA_PMU_REG      )	`nnc_error("reg_check", " INIT_SOC_ANA_PMU_REG     ");
        //if(top_test_cfg.rd_data[6] !==      `INIT_SOC_ANA_TSC_0_REG    )	`nnc_error("reg_check", " INIT_SOC_ANA_TSC_0_REG   ");  
        //if(top_test_cfg.rd_data[5] !==      `INIT_SOC_ANA_TSC_1_REG    )	`nnc_error("reg_check", " INIT_SOC_ANA_TSC_1_REG   ");
        //if(top_test_cfg.rd_data[4] !==      `INIT_SOC_ANA_BIST_REG     )	`nnc_error("reg_check", " INIT_SOC_ANA_BIST_REG    ");
        //if(top_test_cfg.rd_data[3] !==      `INIT_SOC_ANA_DDA_REG      )	`nnc_error("reg_check", " INIT_SOC_ANA_DDA_REG     ");
        //if(top_test_cfg.rd_data[2] !==      `INIT_SOC_ANA_PGA_REG      )	`nnc_error("reg_check", " INIT_SOC_ANA_PGA_REG     ");
        //if(top_test_cfg.rd_data[1] !==      `INIT_SOC_ANA_ELE_REG      )	`nnc_error("reg_check", " INIT_SOC_ANA_ELE_REG     ");
        //if(top_test_cfg.rd_data[0] !==      `INIT_SOC_ANA_SDM_REG      )	`nnc_error("reg_check", " INIT_SOC_ANA_SDM_REG     ");

    endtask

    task check_rst_signals(logic [7:0] mode);
         if(mode === 8'h0)begin
           if(`RST_CTRL_TOP.cic_rst_n             !== 1'b1  )	`nnc_error("reset_check", " cic_rst_n            "); 
           if(`RST_CTRL_TOP.adc_resetn            !== 1'b1  )	`nnc_error("reset_check", " adc_resetn           "); 
           if(`RST_CTRL_TOP.filter_rstn           !== 1'b1  )	`nnc_error("reset_check", " filter_rstn          "); 
           //if(`RST_CTRL_TOP.lead_off_presetn      !== 1'b1  )	`nnc_error("reset_check", " lead_off_presetn     "); 
           if(`RST_CTRL_TOP.anac_presetn          !== 1'b1  ) 	`nnc_error("reset_check", " anac_presetn         ");
           if(`RST_CTRL_TOP.temp_sar_presetn      !== 1'b1  )	`nnc_error("reset_check", " temp_sar_presetn     ");
           if(`RST_CTRL_TOP.wave_gen_presetn      !== 1'b1  )	`nnc_error("reset_check", " wave_gen_presetn     ");
           if(`RST_CTRL_TOP.poresetn              !== 1'b1  ) 	`nnc_error("reset_check", " poresetn             ");
           if(`RST_CTRL_TOP.poresetn_hf           !== 1'b1  )	`nnc_error("reset_check", " poresetn_hf          ");
           if(`RST_CTRL_TOP.presetn               !== 1'b1  )	`nnc_error("reset_check", " presetn              ");
           if(`RST_CTRL_TOP.otp_rstn              !== 1'b1  )	`nnc_error("reset_check", " otp_rstn             ");
           if(`RST_CTRL_TOP.stim_monitor_rstn     !== 1'b1  )	`nnc_error("reset_check", " stim_monitor_rstn    ");
           if(`RST_CTRL_TOP.ppg_resetn            !== 1'b1  )	`nnc_error("reset_check", " ppg_resetn           ");
           if(`RST_CTRL_TOP.adc_ctrl_resetn       !== 1'b1  )	`nnc_error("reset_check", " adc_ctrl_resetn      ");
           if(`RST_CTRL_TOP.otp_bist_resetn_atpg  !== 1'b1  )	`nnc_error("reset_check", " otp_bist_resetn_atpg ");
           //individual block
           if(`WG_DRIVER_TOP.i_presetn                                               !== 1'b1 )   	`nnc_error("reset_check", "  i_presetn              ");
           if(`TSC_TOP.presetn                                                       !== 1'b1 )   	`nnc_error("reset_check", "  u_temp_sar_ctrl.presetn ");                                
           if(`EPROM_TOP.por_resetn                                                  !== 1'b1 )   	`nnc_error("reset_check", "  por_resetn           ");
           if(`EPROM_TOP.rst_n                                                       !== 1'b1 )   	`nnc_error("reset_check", "  rst_n                    ");
           if(`EPROM_TOP.RESETb                                                      !== 1'b1 )   	`nnc_error("reset_check", "  RESETb                ");
           if(`NIRS_PPG_TOP.rst_n                                                    !== 1'b1 )   	`nnc_error("reset_check", "  rst_n                ");
           if(`IMEAS_WRAPPER_TOP.filter_rstn                                         !== 1'b1 )   	`nnc_error("reset_check", "  filter_rstn          ");
           if(`IMEAS_WRAPPER_TOP.cic_rst_n                                           !== 1'b1 )   	`nnc_error("reset_check", "  cic_rst_n            ");
           if(`IMEAS_WRAPPER_TOP.adc_resetn                                          !== 1'b1 )   	`nnc_error("reset_check", "  adc_resetn           ");
           if(`IMEAS_WRAPPER_TOP.adc_ctrl_resetn                                     !== 1'b1 )   	`nnc_error("reset_check", "  adc_ctrl_resetn      ");
           if(`ANAC_TOP.presetn                                                      !== 1'b1 )   	`nnc_error("reset_check", "  presetn              ");
           if(soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_adc_cap_ctrl.presetn            !== 1'b1 )   	`nnc_error("reset_check", "  adc_cap_ctrl.presetn ");
           if(`CLK_CTRL_TOP.presetn                                                  !== 1'b1 )    	`nnc_error("reset_check", "  presetn              ");
           if(`CLK_CTRL_TOP.poresetn                                                 !== 1'b1 )   	`nnc_error("reset_check", "  poresetn             ");
           if(`CLK_CTRL_TOP.adc_resetn                                               !== 1'b1 )   	`nnc_error("reset_check", "  adc_resetn           ");
           if(`CLK_CTRL_TOP.adc_ctrl_resetn                                          !== 1'b1 )   	`nnc_error("reset_check", "  adc_ctrl_resetn      ");
           if(`SPI_TOP.i_rst_n                                                       !== 1'b1 )   	`nnc_error("reset_check", "  i_rst_n              ");
           if(`PMU_CTRL_TOP.poresetn_hf                                              !== 1'b1 )   	`nnc_error("reset_check", "  poresetn_hf          ");
           if(`PMU_CTRL_TOP.hresetreq                                                !== 1'b0 )   	`nnc_error("reset_check", "  hresetreq            ");
         end
         if(mode === 8'h1)begin
           if(`RST_CTRL_TOP.cic_rst_n             !== 1'b0  )	`nnc_error("reset_check", " cic_rst_n            "); 
           if(`RST_CTRL_TOP.adc_resetn            !== 1'b0  )	`nnc_error("reset_check", " adc_resetn           "); 
           if(`RST_CTRL_TOP.filter_rstn           !== 1'b0  )	`nnc_error("reset_check", " filter_rstn          "); 
           //if(`RST_CTRL_TOP.lead_off_presetn      !== 1'b0  )	`nnc_error("reset_check", " lead_off_presetn     "); 
           if(`RST_CTRL_TOP.anac_presetn          !== 1'b0  ) 	`nnc_error("reset_check", " anac_presetn         ");
           if(`RST_CTRL_TOP.temp_sar_presetn      !== 1'b0  )	`nnc_error("reset_check", " temp_sar_presetn     ");
           if(`RST_CTRL_TOP.wave_gen_presetn      !== 1'b0  )	`nnc_error("reset_check", " wave_gen_presetn     ");
           if(`RST_CTRL_TOP.poresetn              !== 1'b0  ) 	`nnc_error("reset_check", " poresetn             ");
           if(`RST_CTRL_TOP.poresetn_hf           !== 1'b0  )	`nnc_error("reset_check", " poresetn_hf          ");
           if(`RST_CTRL_TOP.presetn               !== 1'b0  )	`nnc_error("reset_check", " presetn              ");
           if(`RST_CTRL_TOP.otp_rstn              !== 1'b0  )	`nnc_error("reset_check", " otp_rstn             ");
           if(`RST_CTRL_TOP.stim_monitor_rstn     !== 1'b0  )	`nnc_error("reset_check", " stim_monitor_rstn    ");
           if(`RST_CTRL_TOP.ppg_resetn            !== 1'b0  )	`nnc_error("reset_check", " ppg_resetn           ");
           if(`RST_CTRL_TOP.adc_ctrl_resetn       !== 1'b0  )	`nnc_error("reset_check", " adc_ctrl_resetn      ");
           if(`RST_CTRL_TOP.otp_bist_resetn_atpg  !== 1'b1  )	`nnc_error("reset_check", " otp_bist_resetn_atpg "); //connected to pin resetn
           //individual block
           if(`WG_DRIVER_TOP.i_presetn                                               !== 1'b0 )   	`nnc_error("reset_check", "  i_presetn              ");
           if(`TSC_TOP.presetn                                                       !== 1'b0 )   	`nnc_error("reset_check", "  u_temp_sar_ctrl.presetn ");                                
           if(`EPROM_TOP.por_resetn                                                  !== 1'b0 )   	`nnc_error("reset_check", "  por_resetn               ");
           if(`EPROM_TOP.rst_n                                                       !== 1'b0 )   	`nnc_error("reset_check", "  rst_n                    ");
           if(`EPROM_TOP.RESETb                                                      !== 1'b1 )   	`nnc_error("reset_check", "  RESETb                "); //connected to pin resetn
           if(`NIRS_PPG_TOP.rst_n                                                    !== 1'b0 )   	`nnc_error("reset_check", "  rst_n                ");
           if(`IMEAS_WRAPPER_TOP.filter_rstn                                         !== 1'b0 )   	`nnc_error("reset_check", "  filter_rstn          ");
           if(`IMEAS_WRAPPER_TOP.cic_rst_n                                           !== 1'b0 )   	`nnc_error("reset_check", "  cic_rst_n            ");
           if(`IMEAS_WRAPPER_TOP.adc_resetn                                          !== 1'b0 )   	`nnc_error("reset_check", "  adc_resetn           ");
           if(`IMEAS_WRAPPER_TOP.adc_ctrl_resetn                                     !== 1'b0 )   	`nnc_error("reset_check", "  adc_ctrl_resetn      ");
           if(`ANAC_TOP.presetn                                                      !== 1'b0 )   	`nnc_error("reset_check", "  presetn              ");
           if(soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_adc_cap_ctrl.presetn            !== 1'b0 )   	`nnc_error("reset_check", "  adc_cap_ctrl.presetn ");
           if(`CLK_CTRL_TOP.presetn                                                  !== 1'b0 )    	`nnc_error("reset_check", "  presetn              ");
           if(`CLK_CTRL_TOP.poresetn                                                 !== 1'b0 )   	`nnc_error("reset_check", "  poresetn             ");
           if(`CLK_CTRL_TOP.adc_resetn                                               !== 1'b0 )   	`nnc_error("reset_check", "  adc_resetn           ");
           if(`CLK_CTRL_TOP.adc_ctrl_resetn                                          !== 1'b0 )   	`nnc_error("reset_check", "  adc_ctrl_resetn      ");
           if(`SPI_TOP.i_rst_n                                                       !== 1'b0 )   	`nnc_error("reset_check", "  i_rst_n              ");
           if(`PMU_CTRL_TOP.poresetn_hf                                              !== 1'b0 )   	`nnc_error("reset_check", "  poresetn_hf          ");
           if(`PMU_CTRL_TOP.hresetreq                                                !== 1'b0 )   	`nnc_error("reset_check", "  hresetreq            ");
         end
    endtask 


  // ------------------------------
  // Declare the report_phase task
  // ------------------------------
  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction



endclass : `TESTNAME
