/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_anac_tsc_fsm_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_anac_tsc_fsm_test                                             
// Designer	: pfwang@nanochap.com                                                                 
// Date		: 21-07-2025                                                                     
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_anac_tsc_fsm_test
`define TESTCFG soc_anac_tsc_fsm_test_cfg

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
  logic [7:0]      rdata;
 
  rand logic [7:0]  smp_duration;
  rand logic [11:0] stable_duration;
  rand logic [7:0] sensor_temperature;
  rand int         a2d_comp_delay;
//  rand logic [7:0] tsc_trim;
  logic [2:0] factor = 2;
  rand logic       tsc_comp_low_ch1;
  rand logic [7:0] tsc_int_ctrl;

  rand logic       tsc_int_trans_sel;
  rand logic       tsc_int_en;
  rand logic [7:0] tsc_ctrl;

  rand logic [7:0] room_temp;
  rand logic [7:0] over_temp_th;
  rand logic [7:0] Dhigh_tsc;


  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_anac_tsc_fsm_test_cfg");
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

  constraint c_smp_duration { smp_duration inside {0, 255, [85:150]};
                              smp_duration dist {0:/1, 255:/1, [85:152]:/1}; }

  constraint c_stable_duration {stable_duration inside {0, 1023, 511, 512, [400:600]};
                                stable_duration dist {0:/1, 1023:/1, 511:/1, 512:/1, [400:600]:/1};}
  
  constraint c_a2d_comp_delay {a2d_comp_delay inside {[128:256]};}
  constraint c_tsc_ctrl     { tsc_ctrl[3] == tsc_comp_low_ch1;
                              tsc_ctrl[2] == 1'b1;}
  constraint c_tsc_int_trans_sel   {tsc_int_trans_sel == tsc_comp_low_ch1;}
  constraint c_tsc_int_ctrl  {tsc_int_ctrl[1:0] == {tsc_int_trans_sel, tsc_int_en};}

  constraint c_room_temp  {room_temp inside {[1:80]};}  //1oC - 40oC
  constraint c_over_temp_th {over_temp_th inside {[170:250]};} //85oC - 125oC  
  constraint c_Dhigh_tsc   {Dhigh_tsc == ((over_temp_th - room_temp)*64/100 + room_temp);}

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

    `DUT_IF.spimode_sel = top_test_cfg.spimode_sel;
    //`DUT_IF.sensor_temperature = top_test_cfg.sensor_temperature;
    `DUT_IF.a2d_comp_delay_ch1 = top_test_cfg.a2d_comp_delay;
    `DUT_IF.tsc_comp_low_active_en = top_test_cfg.tsc_comp_low_ch1;
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
    
    super.main_phase(phase);

    `nnc_info("SOC_TEST", "soc_anac_tsc_fsm_test start", NNC_LOW)

    // ==================================================================================
    // Please add your code of your test here
    // ---------------------------------------------------------------------------------- 
`ifndef MIX_SIM_EN    
    //assert(top_test_cfg.randomize() with {reg_addr == `SOC_TSC_EN_REG_SEL_REG;});
    `nnc_info("SOC_TEST", "Single Writing to a Register", NNC_LOW)
    `WR_NORMAL_REG(`SOC_TSC_EN_REG_SEL_REG, 8'b0000_0000, top_test_cfg.pads);
    
    `WR_NORMAL_REG(`SOC_TSC_CTRL_REG, top_test_cfg.tsc_ctrl, top_test_cfg.pads);

    `WR_NORMAL_REG(`SOC_TSC_INT_CTLR_REG, top_test_cfg.tsc_int_ctrl, top_test_cfg.pads);

    `WR_NORMAL_REG(`SOC_SMP_DURATION_REG, top_test_cfg.smp_duration, top_test_cfg.pads);    

    `WR_NORMAL_REG(`SOC_STABLE_BURATION_0_REG, top_test_cfg.stable_duration[7:0], top_test_cfg.pads);    
    
    `WR_NORMAL_REG(`SOC_STABLE_BURATION_1_REG, {4'hf,top_test_cfg.stable_duration[11:8]}, top_test_cfg.pads);
    
    //set room_temp to model
    `DUT_IF.sensor_temperature = top_test_cfg.room_temp;
    top_test_cfg.room_temp.rand_mode(0);

    //wait the first sar done;
    do begin
        `nnc_info("", "read busy doing....", NNC_LOW);
       `RD_NORMAL_REG(`SOC_SMP_STS_REG, top_test_cfg.pads, top_test_cfg.rdata);
        `nnc_info("", $sformatf("read busy doing.... %h", top_test_cfg.rdata), NNC_LOW);
    end while(top_test_cfg.rdata[0] === 1);
    `nnc_info("", "read busy finish!", NNC_LOW);
    
    //reset tsc
    `WR_NORMAL_REG(`SOC_ANAC_CTRL_REG, 8'b0000_0100, top_test_cfg.pads);    
    `WR_NORMAL_REG(`SOC_ANAC_CTRL_REG, 8'b0000_0000, top_test_cfg.pads);    

    //restart sar 
    do begin
        `nnc_info("", "read busy doing....", NNC_LOW);
       `RD_NORMAL_REG(`SOC_SMP_STS_REG, top_test_cfg.pads, top_test_cfg.rdata);
        `nnc_info("", $sformatf("read busy doing.... %h", top_test_cfg.rdata), NNC_LOW);
    end while(top_test_cfg.rdata[0] === 1);
    `nnc_info("", "read busy finish!", NNC_LOW);

    //read Dnor_din
    `RD_NORMAL_REG(`SOC_VDAC_NOR0_REG, top_test_cfg.pads, top_test_cfg.rdata);

    //check Dnor, should be room_temp
    if(top_test_cfg.rdata !== top_test_cfg.room_temp) begin
        `nnc_error("", "the room temperature error!!!");
    end

    #3ms;
    //in fsm mode, after sar, the tsc signles are controled by spi.  
   repeat(15) begin
    
        assert(top_test_cfg.randomize() with {tsc_ctrl[2] == 1;}); //vdac_en =1
        //`DUT_IF.tsc_comp_low_active_en = top_test_cfg.tsc_comp_low_ch1; //tsc_comp_low should be match with int_trans_sel
        `nnc_info("", $sformatf("configure the Dhigh_tsc=%h, over_temp_th=%h, room_temp=%h ", top_test_cfg.Dhigh_tsc, top_test_cfg.over_temp_th, top_test_cfg.room_temp), NNC_LOW);
        `WR_NORMAL_REG(`SOC_TSC_VDAC8B_DIN_CH1_REG, top_test_cfg.Dhigh_tsc, top_test_cfg.pads);
        `WR_NORMAL_REG(`SOC_TSC_CTRL_REG, top_test_cfg.tsc_ctrl, top_test_cfg.pads);
        `WR_NORMAL_REG(`SOC_TSC_INT_CTLR_REG, top_test_cfg.tsc_int_ctrl, top_test_cfg.pads);
        `DUT_IF.tsc_comp_low_active_en = top_test_cfg.tsc_comp_low_ch1; //tsc_comp_low should be match with int_trans_sel        
        // check analog_top interface 
        #500ns;

        if(top_test_cfg.tsc_ctrl[2:0] !== {`ANA_TOP.tsc_monitoring_ch1.D2A_VDAC8B_EN_CHx, `ANA_TOP.tsc_monitoring_ch1.D2A_TSC_COMP_EN_CHx, `ANA_TOP.tsc_monitoring_ch1.D2A_TSC_EN_CHx})begin
            `nnc_error("SOC_TEST", "tsc_ctrl error in spi mode");
        end
        if(top_test_cfg.Dhigh_tsc !== `ANA_TOP.tsc_monitoring_ch1.D2A_VDAC8B_DIN_CHx)begin
            `nnc_error("SOC_TEST", "8bit_dac_din error in spi mode");
        end

        if( `SOC_TOP.IOBUF_PAD[7] === 1) `nnc_error("SOC_TEST", "tsc int error");    

        while(`DUT_IF.sensor_temperature < top_test_cfg.Dhigh_tsc)begin
            #200000ns;
            `DUT_IF.sensor_temperature = `DUT_IF.sensor_temperature + 5;
        end

        repeat(6) @(posedge `CLK_CTRL_TOP.pclk); //wait for int
        #10ns;
        if(top_test_cfg.tsc_ctrl[2:0] === 3'h7 && (top_test_cfg.tsc_int_en !== `SOC_TOP.IOBUF_PAD[7])) `nnc_error("SOC_TEST", "tsc int error");
        if(top_test_cfg.tsc_ctrl[2:0] !== 3'h7 && (1'b1 === `SOC_TOP.IOBUF_PAD[7])) `nnc_error("SOC_TEST", "tsc int error");        
        
        #200000ns;
        `DUT_IF.sensor_temperature = top_test_cfg.room_temp; 

        //clr tsc int
        `WR_NORMAL_REG(`SOC_TSC_INT_STATUS_REG, 8'h1, top_test_cfg.pads);
        repeat(6) @(posedge `CLK_CTRL_TOP.pclk); //wait for int clr
        #20ns; //pad delay
        if( `SOC_TOP.IOBUF_PAD[7] === 1) `nnc_error("SOC_TEST", "tsc int not clr");
    end

`endif

    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    #10000ns;
    `nnc_info("SOC_TEST", "soc_anac_tsc_fsm_test end now", NNC_LOW)

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
