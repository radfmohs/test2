/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_sysc_reg_reset_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_sysc_reg_reset_test                                             
// Designer	: pfwang@nanochap.com                                                                 
// Date		: 18-03-2024                                                                  
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_sysc_reg_reset_test
`define TESTCFG soc_sysc_reg_reset_test_cfg

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

  logic [7:0]  clk_freq;
  rand logic       lead_off_rst=0;
  rand logic       wave_gen_rst=0;
  rand logic       otp_rst_reg=0;
  rand logic       anac_rst_reg=0;
  rand logic       tsc_rst_reg=0;
   logic       lead_off_rst_l=0;
   logic       wave_gen_rst_l=0;
   logic       otp_rst_reg_l =0;
   logic       anac_rst_reg_l =0;
   logic       tsc_rst_reg_l=0;
  rand  logic       dig_rst_reg=0;
  
  rand logic [7:0] pmu_reg0;
  rand logic [7:0] pmu_reg1;    
  rand logic [7:0] anac_ctrl;
   rand logic         slp_en = 0;   
  logic         slp_en_1 = 0;  
  
  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_sysc_reg_reset_test_cfg");
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

  constraint c_pmu_reg0     { pmu_reg0[7] == lead_off_rst;
                              pmu_reg0[5] == wave_gen_rst;}; 
  constraint c_pmu_reg1     { pmu_reg1[0] == otp_rst_reg;
                              pmu_reg1[1] == dig_rst_reg;}
  constraint c_anac_ctrl    { anac_ctrl[1] == anac_rst_reg;
                              anac_ctrl[2] == tsc_rst_reg;  }
  
    constraint  c_slp_en                {if(pmu_reg0[2]) {slp_en == 1'b0;}
                                         else if((!pmu_reg0[2] && pmu_reg0[1] && pmu_reg0[0])==1) {slp_en == 1'b1;}
                                        else {slp_en == slp_en_1;}
    }
    
    function void pre_randomize();
        slp_en_1.rand_mode(0);
        slp_en_1 = slp_en;
       lead_off_rst_l.rand_mode(0);
       wave_gen_rst_l.rand_mode(0);
       otp_rst_reg_l.rand_mode(0);
       anac_rst_reg_l.rand_mode(0);
       tsc_rst_reg_l.rand_mode(0);
       lead_off_rst_l = slp_en ? (lead_off_rst ? lead_off_rst : lead_off_rst_l):lead_off_rst;
       wave_gen_rst_l = slp_en ? (wave_gen_rst ? wave_gen_rst : wave_gen_rst_l):wave_gen_rst;
       otp_rst_reg_l  = slp_en ? (otp_rst_reg ? otp_rst_reg : otp_rst_reg_l):otp_rst_reg ;
       anac_rst_reg_l  = slp_en ? (anac_rst_reg ? anac_rst_reg : anac_rst_reg_l):anac_rst_reg ;
       tsc_rst_reg_l  = slp_en ? (tsc_rst_reg ? tsc_rst_reg : tsc_rst_reg_l):tsc_rst_reg ;         
    endfunction
               



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

    //assert(top_test_cfg.randomize());

    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;

    `DUT_IF.otp_ignore_check_en = 1;
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

    `nnc_info("SOC_TEST", "soc_sysc_reg_reset_test start", NNC_LOW)

    // ==================================================================================
    // Please add your code of your test here
    // ---------------------------------------------------------------------------------- 
    
    // --------------------------------------------------------
    // This is an example RD_RESET_CHK_REG 
    // --------------------------------------------------------

        //set reg


        repeat(15) begin
        assert(top_test_cfg.randomize() with {reg_addr == `SOC_CLK_CTRL_REG; no_of_bytes == 8'h01; dig_rst_reg == 1'b1; wr_data[0][2:0] != 3'h7;} );
        `WR_BURST_NORMAL_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.wr_data);
        
        `WR_NORMAL_REG(`SOC_PMU_REG, top_test_cfg.pmu_reg0, top_test_cfg.pads);

        `WR_NORMAL_REG(`SOC_PMU_REG1, top_test_cfg.pmu_reg1, top_test_cfg.pads);
        `WR_NORMAL_REG(`SOC_ANAC_CTRL_REG, top_test_cfg.anac_ctrl, top_test_cfg.pads);

        #200us;
        `ifdef POSTLAYOUT
        if(/*`SPI_TOP.i_rst_n &&*/ `PMU_CTRL_TOP.poresetn_hf  /*&& `CLK_CTRL_TOP.presetn*/ && `CLK_CTRL_TOP.poresetn  /*&& `ANAC_TOP.presetn*/ && `EPROM_TOP.RESETb && `RST_CTRL_TOP.presetn);
        `else
        if(`SPI_TOP.i_rst_n && `PMU_CTRL_TOP.poresetn_hf  && `CLK_CTRL_TOP.presetn && `CLK_CTRL_TOP.poresetn && `EPROM_TOP.RESETb);
        `endif
        else  `nnc_error("SOC_TEST", "RESETn error!!!");

        `nnc_info("",$sformatf("slp_en %h %h, wave %h %h, lead %h %h , otp %h  %h, anac %h %h",top_test_cfg.slp_en_1, top_test_cfg.slp_en, top_test_cfg.wave_gen_rst_l, top_test_cfg.wave_gen_rst, top_test_cfg.lead_off_rst_l, top_test_cfg.lead_off_rst, top_test_cfg.otp_rst_reg_l,  top_test_cfg.otp_rst_reg, top_test_cfg.anac_rst_reg_l,  top_test_cfg.anac_rst_reg), NNC_LOW);


        // when slp_en =1, ignore reg reset;
        if(/*(top_test_cfg.slp_en_1 &&*/ top_test_cfg.slp_en  !== 1) begin
            if(`WG_DRIVER_TOP.i_presetn === top_test_cfg.wave_gen_rst )
                `nnc_error("SOC_TEST", "WAVEGEN RESETn error!!!");        
            //if(`LEADOFF_WRAPPER_TOP.i_presetn === top_test_cfg.lead_off_rst)
            //    `nnc_error("SOC_TEST", "LEADOFF RESETn error!!!");        
            if(`EPROM_TOP.rst_n === top_test_cfg.otp_rst_reg)
                `nnc_error("SOC_TEST", "OTP RESETn error!!!");
            if(`ANAC_TOP.presetn === top_test_cfg.anac_rst_reg)
                `nnc_error("SOC_TEST", "ANAC RESETn error!!!");
            if(`TSC_TOP.presetn === top_test_cfg.tsc_rst_reg)
                `nnc_error("SOC_TEST", "TSC RESETn error!!!");
        end
        else begin
        //    if(`WG_DRIVER_TOP.i_presetn === (top_test_cfg.wave_gen_rst_l || top_test_cfg.wave_gen_rst))
        //        `nnc_error("SOC_TEST", "WAVEGEN RESETn error!!!");        
        //    if(`LEADOFF_WRAPPER_TOP.i_presetn === (top_test_cfg.lead_off_rst_l || top_test_cfg.lead_off_rst))
        //        `nnc_error("SOC_TEST", "LEADOFF RESETn error!!!");        
        //    if(`EPROM_TOP.rst_n === (top_test_cfg.otp_rst_reg_l || top_test_cfg.otp_rst_reg))
        //        `nnc_error("SOC_TEST", "OTP RESETn error!!!");
        end


        end

  

    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    #10000ns;
    `nnc_info("SOC_TEST", "soc_sysc_reg_reset_test end now", NNC_LOW)

    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ==================================================================================

    phase.drop_objection(this);
  endtask: main_phase

    //task check_reg();
    //    if(top_test_cfg.rd_data[9] !==      `INIT_SOC_PMU_REG          )	`nnc_error("reg_check", " INIT_SOC_PMU_REG         ");
    //    if(top_test_cfg.rd_data[8] !==      `INIT_SOC_CLK_CTRL_REG     )	`nnc_error("reg_check", " INIT_SOC_CLK_CTRL_REG    ");
    //    if(top_test_cfg.rd_data[7] !==      `INIT_SOC_ANA_PMU_REG      )	`nnc_error("reg_check", " INIT_SOC_ANA_PMU_REG     ");
    //    if(top_test_cfg.rd_data[6] !==      `INIT_SOC_ANA_TSC_0_REG    )	`nnc_error("reg_check", " INIT_SOC_ANA_TSC_0_REG   ");  
    //    if(top_test_cfg.rd_data[5] !==      `INIT_SOC_ANA_TSC_1_REG    )	`nnc_error("reg_check", " INIT_SOC_ANA_TSC_1_REG   ");
    //    if(top_test_cfg.rd_data[4] !==      `INIT_SOC_ANA_BIST_REG     )	`nnc_error("reg_check", " INIT_SOC_ANA_BIST_REG    ");
    //    if(top_test_cfg.rd_data[3] !==      `INIT_SOC_ANA_DDA_REG      )	`nnc_error("reg_check", " INIT_SOC_ANA_DDA_REG     ");
    //    if(top_test_cfg.rd_data[2] !==      `INIT_SOC_ANA_PGA_REG      )	`nnc_error("reg_check", " INIT_SOC_ANA_PGA_REG     ");
    //    if(top_test_cfg.rd_data[1] !==      `INIT_SOC_ANA_ELE_REG      )	`nnc_error("reg_check", " INIT_SOC_ANA_ELE_REG     ");
    //    if(top_test_cfg.rd_data[0] !==      `INIT_SOC_ANA_SDM_REG      )	`nnc_error("reg_check", " INIT_SOC_ANA_SDM_REG     ");

    //endtask

  // ------------------------------
  // Declare the report_phase task
  // ------------------------------
  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction

endclass : `TESTNAME
