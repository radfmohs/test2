/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_wavegen_drva_ems_alt_base_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_wavegen_drva_ems_alt_base_test                                             
// Designer	: pfwang@nanochap.com                                                                 
// Date		: 25-12-2025                                                                     
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_wavegen_drva_ems_alt_base_test
`define TESTCFG soc_wavegen_drva_ems_alt_base_test_cfg

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

  
  //logic [7:0]      wavegen_data[127:0];
  logic [7:0]      wavegen_data[];
  //logic [7:0]      wavegen_data[]

  rand logic [7:0] point_num;
  rand logic [15:0] pos_prd_num;
  rand logic [15:0] neg_prd_num;
  rand logic [15:0] alt_lim, alt_silent, alt_rest;
  rand logic [7:0] prd_rest[1:0];
  rand logic [7:0] prd_silent[3:0];
  rand logic [7:0] delay_lim[1:0];  
  rand logic [7:0] neg_scale, neg_offset, pos_scale, pos_offset, cfg_ctrl, ctrl_reg2, config_reg0, ctrl_reg0, ems_num; 
  rand logic [7:0] ems_ctrl;

  rand bit   [3:0] which_waveform;  //carrier:[1:0], envelope:[3:2];  0:sin, 1:triangle 2:pulse
  rand int         enve_freq, carr_freq;
  rand logic [2:0] clk_div;

  rand int         ems_max_value;  

  rand int         enve_num;

  rand bit [1:0]   wave_by_int;   //0: int -> scale, 1: int -> data, 2/3: delay; 

  rand int         env_period_num;
  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_wavegen_drva_ems_alt_new_test_cfg");
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

  constraint c_alt_lim     {(alt_lim+alt_silent+alt_rest) == 2*point_num*pos_prd_num;
                            solve alt_lim before point_num;
                            solve alt_lim before pos_prd_num;
                            solve alt_lim before alt_silent;
                            solve alt_lim before alt_rest;
                            //alt_lim in;
                            }

  constraint c_alt_silent   {alt_silent inside{[3:5]};}  
  constraint c_alt_rest     {alt_rest inside{[3:5]};}  

  constraint c_point_num   {point_num inside{[60:120]}; }

  constraint c_pos_prd_num {pos_prd_num inside {[1:10]};}

  constraint c_neg_prd_num {if(ems_ctrl[3] == 1) {neg_prd_num inside {[0:0]};}
                            else {neg_prd_num inside {[1:2]};}
                            }

  constraint c_prd_rest    {if(wave_by_int[1] == 1) {{prd_rest[1], prd_rest[0]} inside {[0: 50]};}
                            else {{prd_rest[1], prd_rest[0]} inside {[0: 0]};} 
                            }

  constraint c_wave_by_int {wave_by_int inside {0, 1};}

  constraint c_prd_silent    {if(wave_by_int != 1) {{prd_silent[3], prd_silent[2], prd_silent[1], prd_silent[0]} inside {[0: 100]};}
                              else {{prd_silent[3], prd_silent[2], prd_silent[1], prd_silent[0]} inside {[0: 0]};}
                              }

  constraint c_delay_lim    {{delay_lim[1], delay_lim[0]} inside {[0: 50]};}

  constraint c_pos_offset    {soft pos_offset inside {[0: 127]};
                              wave_by_int == 1 -> pos_offset inside {[0: 0]};}
  constraint c_neg_offset    {neg_offset == pos_offset;}// inside {[0: 127]};}
  constraint c_pos_scale     {soft pos_scale inside {[1: 3]};
                              wave_by_int == 1 -> pos_scale inside {[1: 1]};}
  constraint c_neg_scale     {neg_scale == pos_scale;}// inside {[1: 3]};}    
  
  constraint c_config_reg0     {config_reg0  == 8'h5F;}

  constraint c_ctrl_reg0     {ctrl_reg0 == 1;}

  constraint c_ctrl_reg2     {ctrl_reg2[7] == 1;}

  constraint c_ems_ctrl      {ems_ctrl[3] == 1;
                              if((2**18) < ems_max_value) {ems_ctrl[2:0] == 3'b111;}
                              else if((2**17) < ems_max_value)  {ems_ctrl[2:0] == 3'b110;} 
                              else if((2**16) < ems_max_value)  {ems_ctrl[2:0] == 3'b101;}
                              else if((2**15) < ems_max_value)  {ems_ctrl[2:0] == 3'b100;}
                              else if((2**14) < ems_max_value)  {ems_ctrl[2:0] == 3'b011;}
                              else if((2**13) < ems_max_value)  {ems_ctrl[2:0] == 3'b010;}
                              else if((2**12) < ems_max_value)  {ems_ctrl[2:0] == 3'b001;}
                              else if((2**11) < ems_max_value)  {ems_ctrl[2:0] == 3'b000;} 
                              else {ems_ctrl[2:0] == 3'b000;}}


  constraint c_ems_num       {ems_num inside {[1:8]};}



  constraint c_which_waveform {which_waveform[1:0] inside {0, 1, 2};
                               which_waveform[3:2] inside {0, 1, 2, 3};
                               } //carrier:[1:0]  0:sin, 1:Gaussian 2:triangle ,         envelope:[3:2];  0:sin, 1:triangle 2:pulse 3:trapezoid


  constraint c_enve_num     {if(wave_by_int == 1)  {enve_num inside{[1:4]};}
                             else {enve_num inside{[1:1]};}}
  constraint c_enve_freq    {enve_freq == 1000*(2048000/2**clk_div)/(ems_num * enve_num * point_num * 2 * pos_prd_num * (128 - point_num));
                             soft enve_freq > 1000;}
  constraint c_carr_freq    {carr_freq == 1000*(2048000/2**clk_div)/(point_num * 2 * pos_prd_num);}

  constraint c_max_value     {ems_max_value == ((2**6 * neg_scale) + pos_offset) * 2**4;
                              solve ems_max_value before ems_ctrl;}

  //constraint c_wave_by_int   {wave_by_int == 1;}
  constraint c_pclk_sel                 { soft pclk_sel inside {[0:0]};}

  constraint c_spi_sclk_freq   { solve spi_sclk_jitter before spi_sclk_freq; spi_sclk_freq inside {[300:(`SPI_MAX_FREQ/100)*(100 - spi_sclk_jitter)]};}//min 300Khz - max 14Mhz

  constraint c_tsccs           { solve tch before tsccs; solve spi_sclk_freq before tsccs; tsccs <= 4000; tsccs >= `SPI_TCH_MAX;
                                      (tch >= 50) -> tsccs > 100*tch/spi_sclk_freq;
                                      (tch <  50) -> tsccs > 100*(100 - tch)/spi_sclk_freq;
                               }
  constraint c_tcsh            { solve tch before tcsh; solve spi_sclk_freq before tcsh; tcsh <= 4000; tcsh >= `SPI_TCH_MAX;
                                      (tch >= 50) -> tcsh > 100*tch/spi_sclk_freq;
                                      (tch <  50) -> tcsh > 100*(100 - tch)/spi_sclk_freq;}

  constraint c_env_period_num  {wave_by_int == 0 -> env_period_num inside {[1:4]};   //
                                wave_by_int == 1 -> env_period_num inside {[1:3]};
                                solve wave_by_int before env_period_num;
                                enve_freq < 2000 -> env_period_num == 1;}
  
  function void post_randomize();
   //

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

    assert(top_test_cfg.randomize() with {hfosc_jitter == 1'b0; hfosc_variation == 100; enve_freq inside {[1000_000:2000_000]}; env_period_num == 1; /*carr_freq inside {[10000:20000]};*/});

    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;

    `DUT_IF.spimode_sel = top_test_cfg.spimode_sel;

    `DUT_IF.hfosc_jitter = top_test_cfg.hfosc_jitter;    

    `DUT_IF.hfosc_variation = top_test_cfg.hfosc_variation;
    `DUT_IF.spi_sclk_freq = top_test_cfg.spi_sclk_freq;
    `DUT_IF.tch      = top_test_cfg.tch;
    `DUT_IF.tcsh     = top_test_cfg.tcsh;
    `DUT_IF.tsccs    = top_test_cfg.tsccs;
    // -------------------
    // Scoreboard enables
    // -------------------
    // `FLASH_SCOREBOARD_EN = 1;
    // `SPIM_SCOREBOARD_EN = 1;
    // `ANALOG_SCOREBOARD_EN = 1;
    // `IMEAS_SCOREBOARD_EN = 1;
    // `CLKRST_SCOREBOARD_EN = 1;
    `NNC_WAVEGEN_REF_SCB_EN = 1;

    phase.drop_objection(this);
  endtask : pre_reset_phase

  // -----------------------------------------
  // Declare the main_phase task of your test
  // -----------------------------------------
  virtual task main_phase(nnc_phase phase);
    phase.raise_objection(this);
    
    super.main_phase(phase);

    `nnc_info("SOC_TEST", "soc_wavegen_drva_ems_alt_base_test start", NNC_LOW)

    // ==================================================================================
    // Please add your code of your test here
    // ---------------------------------------------------------------------------------- 
    
    wavegen_cfg(top_test_cfg);

    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    #10000ns;
    `nnc_info("SOC_TEST", "soc_wavegen_drva_ems_alt_base_test end now", NNC_LOW)

    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ==================================================================================

    phase.drop_objection(this);
  endtask: main_phase


  task wavegen_cfg (`TESTCFG cfg);
    
    `nnc_info("SOC_TEST", "Set clk ctrl", NNC_LOW)
    `WR_NORMAL_REG(`SOC_CLK_CTRL_REG, {4'b0, 1'b0, cfg.clk_div}, cfg.pads);


    `nnc_info("SOC_TEST", $sformatf("point_num = %d, pos_prd_num = %d, alt_lim = %d", cfg.point_num, cfg.pos_prd_num, cfg.alt_lim), NNC_LOW);
    `nnc_info("SOC_TEST", $sformatf("prd_rest = 0x%h, prd_silent = 0x%h", {cfg.prd_rest[1], cfg.prd_rest[0]}, {cfg.prd_silent[3], cfg.prd_silent[2], cfg.prd_silent[1], cfg.prd_silent[0]}), NNC_LOW);
    `nnc_info("SOC_TEST", $sformatf("scale = %h, offset = %h, max_value = %h, ems_ctrl = %h  ", cfg.pos_scale, cfg.pos_offset, cfg.ems_max_value, cfg.ems_ctrl), NNC_LOW);
    `nnc_info("SOC_TEST", $sformatf("enve_freq = %0.2fhz, carr_freq = %0.2fhz, clk_div = %0d, enve_num = %0d, ems_num = %0d, wave_by_int = %0d, env_period_num = %0d", real'(cfg.enve_freq)/1000, real'(cfg.carr_freq)/1000, cfg.clk_div, cfg.enve_num, cfg.ems_num, cfg.wave_by_int, cfg.env_period_num), NNC_LOW);

    $system($sformatf("../../../verification/models/wavegen_stimulus/ems_alt.py  %d  %d  %d  %d", cfg.point_num, cfg.which_waveform, cfg.enve_num, cfg.ems_ctrl[3]));

    cfg.wavegen_data = new[cfg.point_num + (128-cfg.point_num)*cfg.enve_num];
    $readmemh("ems_alt.txt", cfg.wavegen_data);

    for(int i=0; i<128; i++) begin
        `WR_WAVEGEN_REG(`SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0, i, cfg.pads);

        if(i < 128-cfg.point_num) `WR_WAVEGEN_REG(`SOC_ADDR_WG_DRV_IN_WAVE_REG01, cfg.wavegen_data[i], cfg.pads);
        else `WR_WAVEGEN_REG(`SOC_ADDR_WG_DRV_IN_WAVE_REG01, cfg.wavegen_data[i+ (128-cfg.point_num)*(cfg.enve_num-1)], cfg.pads);
    end


    `nnc_info("SOC_TEST", "Set alternating mode", NNC_LOW)
    `WR_WAVEGEN_REG(`SOC_ADDR_WG_DRV_CONFIG_REG0, cfg.config_reg0, cfg.pads);


    `nnc_info("SOC_TEST", "Set period of rest/silent", NNC_LOW)
    `WR_BURST_WAVEGEN_REG(`SOC_ADDR_WG_DRV_REST_T_REG01, 6, cfg.pads, {cfg.prd_silent[3], cfg.prd_silent[2], cfg.prd_silent[1], cfg.prd_silent[0], cfg.prd_rest[1], cfg.prd_rest[0]});

    //assert(cfg.randomize() with {reg_addr == `SOC_ADDR_WG_DRV_HLF_WAVE_PRD_REG01; no_of_bytes == 2;  wr_data[1] == cfg.pos_prd_num[7:0]; wr_data[0] == cfg.pos_prd_num[15:8];});  //p1
    `nnc_info("SOC_TEST", "Set period of the positive", NNC_LOW)
    `WR_BURST_WAVEGEN_REG(`SOC_ADDR_WG_DRV_HLF_WAVE_PRD_REG01, 2, cfg.pads, {cfg.pos_prd_num[15:8], cfg.pos_prd_num[7:0]});

    `nnc_info("SOC_TEST", "Set period of the negative", NNC_LOW)
    `WR_BURST_WAVEGEN_REG(`SOC_ADDR_WG_DRV_NEG_HLF_WAVE_PRD_REG01, 2, cfg.pads, {cfg.neg_prd_num[15:8], cfg.neg_prd_num[7:0]});


    `nnc_info("SOC_TEST", "Set point register", NNC_LOW)
    `WR_WAVEGEN_REG(`SOC_ADDR_WG_DRV_POINT_CONFIG, cfg.point_num, cfg.pads);


    `nnc_info("SOC_TEST", "Set delay_lim/scale/offset", NNC_LOW)
    `WR_BURST_WAVEGEN_REG(`SOC_ADDR_WG_DRV_DELAY_LIM_REG01, 6, cfg.pads, {cfg.pos_offset, cfg.pos_scale, cfg.neg_offset, cfg.neg_scale, cfg.delay_lim});


    `nnc_info("SOC_TEST", "Set alter_lim", NNC_LOW)
    `WR_BURST_WAVEGEN_REG(`SOC_ADDR_WG_DRV_ALT_LIM_REG01, 2, cfg.pads, {cfg.alt_lim[15:8], cfg.alt_lim[7:0]});    

    `nnc_info("SOC_TEST", "Set alter_silent", NNC_LOW)
    `WR_BURST_WAVEGEN_REG(`SOC_ADDR_WG_DRV_ALT_SILENT_LIM_REG01, 2, cfg.pads, {cfg.alt_silent[15:8], cfg.alt_silent[7:0]});

    `nnc_info("SOC_TEST", "Set alter_rest", NNC_LOW)
    `WR_BURST_WAVEGEN_REG(`SOC_ADDR_WG_DRV_ALT_REST_LIM_REG01, 2, cfg.pads, {cfg.alt_rest[15:8], cfg.alt_rest[7:0]});    

    `nnc_info("SOC_TEST", "Set ctrl_reg2", NNC_LOW)
    `WR_WAVEGEN_REG(`SOC_ADDR_WG_DRV_CTRL2_REG, cfg.ctrl_reg2, cfg.pads);

    `nnc_info("SOC_TEST", "Set ems ctrl register", NNC_LOW)
    `WR_WAVEGEN_REG(`SOC_EMS_REG_CTRL_REG, cfg.ems_ctrl, cfg.pads);


    `nnc_info("SOC_TEST", "Set ems number register", NNC_LOW)
    `WR_WAVEGEN_REG(`SOC_EMS_REG_NUM_REG, cfg.ems_num, cfg.pads);


    `nnc_info("SOC_TEST", "Set valid for scale/offset register", NNC_LOW)
    `WR_WAVEGEN_REG(`SOC_ADDR_IS_VALID_FOR_CAL_REG, 3, cfg.pads);
    

    `nnc_info("SOC_TEST", "Set int addr1", NNC_LOW)
    `WR_WAVEGEN_REG(`SOC_ADDR_WG_DRV_INT_REG02, 2, cfg.pads); //auto exchange

    `nnc_info("SOC_TEST", "Set int addr2", NNC_LOW)
    `WR_WAVEGEN_REG(`SOC_ADDR_WG_DRV_INT_REG03, (128-cfg.point_num)/2, cfg.pads);

    `nnc_info("SOC_TEST", "Set enable interrupt", NNC_LOW)  //enable int after setting int addr
    `WR_WAVEGEN_REG(`SOC_ADDR_WG_DRV_INT_REG01, cfg.wave_by_int[1] ? 0 : 8'h9, cfg.pads);


    `nnc_info("SOC_TEST", "Set wavegen enable register", NNC_LOW)
    cfg.ctrl_reg0[0] = 1'b1;
    `WR_WAVEGEN_REG(`SOC_AWG_DRIVEC_SW_CFG0_REG, 8'h1, cfg.pads);
    `WR_WAVEGEN_REG(`SOC_ADDR_WG_DRV_CTRL_REG0, cfg.ctrl_reg0, cfg.pads);

    //wavegen_drv_enable;

    //`nnc_info("SOC_TEST", "Set wavegen enable register", NNC_LOW)
    
    
    
    if(cfg.wave_by_int === 1) int_data_cfg(cfg);
    else if(cfg.wave_by_int === 0) int_scale_cfg(cfg);
    else #10ms;
  endtask


  task int_scale_cfg(`TESTCFG cfg);




    for(int i=0; i<cfg.env_period_num; i++)begin

        `nnc_info("SOC_TEST", "Wait for int add1", NNC_LOW)
        @(posedge `SOC_TB.INTB);
        
        `nnc_info("SOC_TEST", "Set clear int register", NNC_LOW)
        `WR_WAVEGEN_REG(`SOC_ADDR_WG_DRV_INT_REG01, 8'hb, cfg.pads);  //clr addr1 and exchange   


        cfg.randomize() with{pos_scale == i+2;}; 
        `nnc_info("SOC_TEST", "Set delay_lim/scale/offset", NNC_LOW)
        `WR_BURST_WAVEGEN_REG(`SOC_ADDR_WG_DRV_NEG_SCALE_REG0, 4, cfg.pads, {cfg.pos_offset, cfg.pos_scale, cfg.neg_offset, cfg.neg_scale});        

        //`nnc_info("SOC_TEST", $sformatf("scale = %h, offset = %h, max_value = %h, ems_ctrl = %h  ", cfg.pos_scale, cfg.pos_offset, cfg.ems_max_value, cfg.ems_ctrl), NNC_LOW);
        //`nnc_info("SOC_TEST", "Set ems ctrl register", NNC_LOW)
        //`WR_WAVEGEN_REG(`SOC_EMS_REG_CTRL_REG, cfg.ems_ctrl, cfg.pads);        

        `nnc_info("SOC_TEST", "Wait for int add1", NNC_LOW)
        @(posedge `SOC_TB.INTB);
        `nnc_info("SOC_TEST", "Set clear int register", NNC_LOW)
        `WR_WAVEGEN_REG(`SOC_ADDR_WG_DRV_INT_REG01, 8'hb, cfg.pads);  //clr addr1 and exchange
    end

    `nnc_info("SOC_TEST", "Wait for int add1", NNC_LOW)
     @(posedge `SOC_TB.INTB);
    `nnc_info("SOC_TEST", "Set clear int register", NNC_LOW)
    `WR_WAVEGEN_REG(`SOC_ADDR_WG_DRV_INT_REG01, 8'hb, cfg.pads);  //clr addr1 and exchange
  endtask


  task int_data_cfg(`TESTCFG cfg);

    `nnc_info("SOC_TEST", "Wait for int add1", NNC_LOW)
    @(posedge `SOC_TB.INTB);
    `nnc_info("SOC_TEST", "Set clear int register", NNC_LOW)
    `WR_WAVEGEN_REG(`SOC_ADDR_WG_DRV_INT_REG01, 8'hb, cfg.pads);  //clr addr1 and exchange

    for(int i=0; i<cfg.env_period_num; i++)begin

        for(int k=0; k<cfg.enve_num; k++) begin
            `nnc_info("SOC_TEST", "Wait for int add1", NNC_LOW)
            @(posedge `SOC_TB.INTB);
            `nnc_info("SOC_TEST", "int assert then cfg addr_data", NNC_LOW)

            for(int j=0; j<(128-cfg.point_num)/2; j++) begin
                `WR_WAVEGEN_REG(`SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0, j, cfg.pads);

                if(k!==cfg.enve_num-1) `WR_WAVEGEN_REG(`SOC_ADDR_WG_DRV_IN_WAVE_REG01, cfg.wavegen_data[j+ (128-cfg.point_num)*(k+1)], cfg.pads);
                else `WR_WAVEGEN_REG(`SOC_ADDR_WG_DRV_IN_WAVE_REG01, cfg.wavegen_data[j], cfg.pads);
            end
        
            `nnc_info("SOC_TEST", "cfg done, then read int register", NNC_LOW)
            `RD_WAVEGEN_REG(`SOC_ADDR_WG_DRV_INT_REG01, cfg.pads, cfg.rd_data[0]);
            if(cfg.rd_data[0][5] === 1'b1) `nnc_error("SOC_TEST", "second addr int!!!") 
            `nnc_info("SOC_TEST", "Set clear int register", NNC_LOW)
            `WR_WAVEGEN_REG(`SOC_ADDR_WG_DRV_INT_REG01, 8'hb, cfg.pads);  //clr addr1 and exchange

            `nnc_info("SOC_TEST", "Wait for int add1", NNC_LOW)
            @(posedge `SOC_TB.INTB);
            //`nnc_info("SOC_TEST", "Set clear int register", NNC_LOW)
            //`WR_WAVEGEN_REG(`SOC_ADDR_WG_DRV_INT_REG01, 8'hb, cfg.pads);  //clr addr1 and exchange

            for(int j=(128-cfg.point_num)/2; j<(128-cfg.point_num); j++) begin
                `WR_WAVEGEN_REG(`SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0, j, cfg.pads);

                if(k!==cfg.enve_num-1) `WR_WAVEGEN_REG(`SOC_ADDR_WG_DRV_IN_WAVE_REG01, cfg.wavegen_data[j+ (128-cfg.point_num)*(k+1)], cfg.pads);
                else `WR_WAVEGEN_REG(`SOC_ADDR_WG_DRV_IN_WAVE_REG01, cfg.wavegen_data[j], cfg.pads);
            end    
            `nnc_info("SOC_TEST", "cfg done, then read int register", NNC_LOW)
            `RD_WAVEGEN_REG(`SOC_ADDR_WG_DRV_INT_REG01, cfg.pads, cfg.rd_data[0]);
            if(cfg.rd_data[0][5] === 1'b1) `nnc_error("SOC_TEST", "second addr int!!!") 
            `nnc_info("SOC_TEST", "Set clear int register", NNC_LOW)
            `WR_WAVEGEN_REG(`SOC_ADDR_WG_DRV_INT_REG01, 8'hb, cfg.pads);  //clr addr1 and exchange            
        end
    end

    `nnc_info("SOC_TEST", "Wait for int add1", NNC_LOW)
     @(posedge `SOC_TB.INTB);
    `nnc_info("SOC_TEST", "Set clear int register", NNC_LOW)
    `WR_WAVEGEN_REG(`SOC_ADDR_WG_DRV_INT_REG01, 8'hb, cfg.pads);  //clr addr1 and exchange
  endtask


  task wavegen_drv_enable;
  begin
    `nnc_info("SOC_TEST", $sformatf("enabling chip_0 wavegen sb now"), NNC_LOW)
    `WAVEGEN_SCB_DRV_0_EN = 1'b1;
    //`WAVEGEN_SCB_DRV_1_EN = 1'b1;
    // --------------------------------------------------------
    // Write to SOC_WAVEGEN_GLOBAL_REG to sync drivers
    // --------------------------------------------------------
    `nnc_info("SOC_TEST", "Enable drivers using wg_ctrl_reg1 register", NNC_LOW)
    //`WR_WAVEGEN_REG(`SOC_AWG_CTRL_REG1_REG, 8'h01, 8'h00);
  end
  endtask

  task wavegen_drv_disable;
  begin
    `nnc_info("SOC_TEST", $sformatf("disabling chip_0 wavegen sb now"), NNC_LOW)
    `WAVEGEN_SCB_DRV_0_EN = 1'b1;
    //`WAVEGEN_SCB_DRV_1_EN = 1'b1;
    // --------------------------------------------------------
    // Write to SOC_WAVEGEN_GLOBAL_REG to sync drivers
    // --------------------------------------------------------
    `nnc_info("SOC_TEST", "Disable drivers using wg_ctrl_reg1 register", NNC_LOW)
    //`WR_WAVEGEN_REG(`SOC_AWG_CTRL_REG1_REG, 8'h00, 8'h00);
  end
  endtask


  // ------------------------------
  // Declare the report_phase task
  // ------------------------------
  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction

endclass : `TESTNAME
