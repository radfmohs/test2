/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_gpio_sr_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_gpio_sr_test                                             
// Designer	: thnguyen@nanochap.com                                                                 
// Date		: 31-07-2025                                                                     
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_gpio_sr_test
`define TESTCFG soc_gpio_sr_test_cfg

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

  logic [`GPIO_NUM-1:0] GPIO_SR;

  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_gpio_sr_test_cfg");
    super.new(name);
    
  endfunction: new

  // ===============================================
  // Adding constraints of randomization
  // -----------------------------------------------

  // testmode_sel[1:0] : 00-Normal mode, 01: Scanmode, 10: BIST mode, 11 atm0/1/2/3/4
  constraint c_testmode_sel { soft testmode_sel == 2'b00; }

  // spimode_sel[1:0] :  
  //constraint c_spimode_sel { spimode_sel == 2'b00; }

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

    //`DUT_IF.spimode_sel = top_test_cfg.spimode_sel;

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

    `nnc_info("SOC_TEST", "soc_gpio_sr_test start", NNC_LOW)
    #50us;
    do_run;
    // --------------------------------------------------------
    #10000ns;
    `nnc_info("SOC_TEST", "soc_gpio_sr_test end now", NNC_LOW)

    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ==================================================================================

    phase.drop_objection(this);
  endtask: main_phase

  task do_run;
    logic [10:0] temp_data;          
    begin
    #1000ns;

    `ifdef BEHAVIORAL
    // Check the initial pads
	top_test_cfg.GPIO_SR = {11{`SPI_TOP.spi_reg_u.gpio_sr_pdrv0_1_ctrl[0]}};  
       if(`SPI_TOP.spi_reg_u.gpio_sr_pdrv0_1_ctrl !== `INIT_SOC_GPIO_SR_PDRV0_1_CTRL_REG) begin
            `nnc_error("PINMUX", $sformatf("`SPI_TOP.spi_reg_u.gpio_sr_pdrv0_1_ctrl = %h is not as expectation of INIT_SOC_GPIO_SR_PDRV0_1_CTRL_REG: %h",`SPI_TOP.spi_reg_u.gpio_sr_pdrv0_1_ctrl, `INIT_SOC_GPIO_SR_PDRV0_1_CTRL_REG))
        end

      	if(`SOC_TOP.IOBUF_SR !== top_test_cfg.GPIO_SR)begin
	    `nnc_error("PINMUX", $sformatf("IOBUF_SR = %h is not as expectation of GPIO_SR = %h",`SOC_TOP.IOBUF_SR, top_test_cfg.GPIO_SR))
	      end  

      	if(`SOC_TOP.IOBUF_PDRV0 !== {11{`SPI_TOP.spi_reg_u.gpio_sr_pdrv0_1_ctrl[1]}})begin
	    `nnc_error("PINMUX", $sformatf("IOBUF_PDRV0 = %h is not as expectation of GPIO_PDRV0 = %h",`SOC_TOP.IOBUF_PDRV0, `SPI_TOP.spi_reg_u.gpio_sr_pdrv0_1_ctrl[1]))
	      end   

      	if(`SOC_TOP.IOBUF_PDRV1 !== {11{`SPI_TOP.spi_reg_u.gpio_sr_pdrv0_1_ctrl[2]}})begin
	    `nnc_error("PINMUX", $sformatf("IOBUF_PDRV1 = %h is not as expectation of GPIO_PDRV1 = %h",`SOC_TOP.IOBUF_PDRV1, `SPI_TOP.spi_reg_u.gpio_sr_pdrv0_1_ctrl[2]))
	      end           
    `endif

   for (int i=0; i < 100; i++) begin    
	force `SPI_TOP.spi_reg_u.gpio_sr_pdrv0_1_ctrl = $random;
	#1000ns;    

	top_test_cfg.GPIO_SR = {11{`SPI_TOP.spi_reg_u.gpio_sr_pdrv0_1_ctrl[0]}};

	#1000ns;

`ifndef BEHAVIORAL
            temp_data = {`SOC_TOP.u_iopad_gpio_10_.SL,
                `SOC_TOP.u_iopad_gpio_9_.SL,
                `SOC_TOP.u_iopad_gpio_8_.SL,
                `SOC_TOP.u_iopad_gpio_7_.SL,
                `SOC_TOP.u_iopad_gpio_6_.SL,
                `SOC_TOP.u_iopad_gpio_5_.SL,
                `SOC_TOP.u_iopad_gpio_4_.SL,
                `SOC_TOP.u_iopad_gpio_3_.SL,
                `SOC_TOP.u_iopad_gpio_2_.SL,
                `SOC_TOP.u_iopad_gpio_1_.SL,
                `SOC_TOP.u_iopad_gpio_0_.SL};
`else
            temp_data = {`SOC_TOP.u_iopad_gpio[10].SL,
                `SOC_TOP.u_iopad_gpio[9].SL,
                `SOC_TOP.u_iopad_gpio[8].SL,
                `SOC_TOP.u_iopad_gpio[7].SL,
                `SOC_TOP.u_iopad_gpio[6].SL,
                `SOC_TOP.u_iopad_gpio[5].SL,
                `SOC_TOP.u_iopad_gpio[4].SL,
                `SOC_TOP.u_iopad_gpio[3].SL,
                `SOC_TOP.u_iopad_gpio[2].SL,
                `SOC_TOP.u_iopad_gpio[1].SL,
                `SOC_TOP.u_iopad_gpio[0].SL};

`endif 

	if(temp_data !== top_test_cfg.GPIO_SR)begin
	    `nnc_error("PINMUX", $sformatf("IOBUF_SR = %h is not as expectation of GPIO_SR = %h",temp_data, top_test_cfg.GPIO_SR))
	end

        end
        end     

  endtask

  

endclass : `TESTNAME
