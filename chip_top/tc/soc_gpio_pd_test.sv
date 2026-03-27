/*--------------------------------------------------------------------------------------
// Copyright 1313 Nanochap, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_gpio_pd_test.sv                                                   
// Project	: Nanochap BPS1                                  		        
// Description	: Testcase soc_gpio_pd_test                                             
// Designer	: ddang@nanochap.com                                                                 
// Date		: 29-11-1323                                                                     
// Revision	: 0.1 Initial version created by script                                 
--------------------------------------------------------------------------------------*/
`define TESTNAME soc_gpio_pd_test
`define TESTCFG soc_gpio_pd_test_cfg

class `TESTCFG extends soc_base_test_cfg;

  `nnc_object_utils(`TESTCFG)

  // -----------------------------------------------
  // Adding your new varialbles in config test
  // -----------------------------------------------
  rand logic [7:0] data[256];
  rand int         no_of_bytes; 
  rand logic [7:0] reg_addr;
  rand logic [7:0] cmd;
  logic [7:0] read_data[];

  rand logic [`GPIO_NUM-1:0] GPIO_PD;

  
  // -----------------------------------------------
  // End of decalration of new variables 
  // -----------------------------------------------

  function new (string name = "soc_gpio_pd_test_cfg");
    super.new(name);
    
  endfunction: new

  // -----------------------------------------------
  // Adding constraints of randomization
  // -----------------------------------------------
  // testmode_sel[1:0] : 00-Normal mode, 01: Scanmode, 10: BIST mode, 11 atm0/1/2/3/4
  constraint c_testmode_sel { soft testmode_sel == 2'b00; }

  constraint c_no_of_bytes { soft no_of_bytes == 2; }
  // -----------------------------------------------
  // End of adding constraints of randomization
  // -----------------------------------------------

endclass : `TESTCFG

class `TESTNAME extends soc_base_test;

  `nnc_component_utils(`TESTNAME)

  `TESTCFG top_test_cfg;

  function new(string name, nnc_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(nnc_phase phase);
    super.build_phase(phase);
    `nnc_top.set_timeout(2s);
    top_test_cfg = `TESTCFG::type_id::create("top_test_cfg", this);    
  endfunction

  virtual task pre_reset_phase(nnc_phase phase);
    phase.raise_objection(this);

    super.pre_reset_phase(phase);

    assert(top_test_cfg.randomize());

    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
    `DUT_IF. gpio_pd_en[11] = 1'b0;
    
    phase.drop_objection(this);
  endtask : pre_reset_phase
    
  virtual task main_phase(nnc_phase phase);
    phase.raise_objection(this);

    `nnc_info("PINMUX","Internal clock test",NNC_LOW)
    #50us;
    do_run;
            
    phase.drop_objection(this);
  endtask: main_phase 

  virtual task do_run;
    logic [`GPIO_NUM-1:0] temp_data;    
    begin
    //`DUT_IF.iopad_gpio[`GPIO_NUM-1:0] = 0;        
    //force `SOC_TB.iopad_resetn = 1'b0;
    //#1000ns;
    //force `SOC_TB.iopad_resetn = 1'b1;
    #1000ns;
    //Check PD [15:0] rw

    `ifdef BEHAVIORAL
    // Check the initial pads
        top_test_cfg.GPIO_PD = {{2{1'b0}},`SPI_TOP.spi_reg_u.gpio_pd_ctrl[4], {9{1'b0}},`SPI_TOP.spi_reg_u.gpio_pd_ctrl[3:1]};  
               
        if(`SPI_TOP.spi_reg_u.gpio_pd_ctrl !== `INIT_SOC_GPIO_PD_CTRL_REG) begin
            `nnc_error("PINMUX", $sformatf("`SPI_TOP.spi_reg_u.gpio_pd_ctrl = %h is not as expectation of INIT_SOC_GPIO_PD_CTRL_REG: %h",`SPI_TOP.spi_reg_u.gpio_pd_ctrl, `INIT_SOC_GPIO_PD_CTRL_REG))
        end

        if(`SOC_TOP.IOBUF_PD !== top_test_cfg.GPIO_PD)begin
            `nnc_error("PINMUX", $sformatf("IOBUF_PD = %h is not as expectation of GPIO_PD = %h",`SOC_TOP.IOBUF_PD, top_test_cfg.GPIO_PD))
        end 

        if(`SOC_TOP.IO_clksel_PD !== `SPI_TOP.spi_reg_u.gpio_pd_ctrl[0])begin
            `nnc_error("PINMUX", $sformatf("CLKSEL = %h is not as expectation of gpio_pd_ctrl[2] = %h",`SOC_TOP.IO_clksel_PD, `SPI_TOP.spi_reg_u.gpio_pd_ctrl[0]))
        end 
    `endif
	

    for (int i=0; i < 100; i++) begin    
	force `SPI_TOP.spi_reg_u.gpio_pd_ctrl = $random;
	#1000ns;    

	//top_test_cfg.GPIO_PD = {8'b0,`DIG_TOP.u_gpio.i_gpio_pd_ctrl};
	top_test_cfg.GPIO_PD = {{2{1'b0}},`SPI_TOP.spi_reg_u.gpio_pd_ctrl[4], {9{1'b0}},`SPI_TOP.spi_reg_u.gpio_pd_ctrl[3:1]};

	#1000ns;
    
`ifndef BEHAVIORAL
            temp_data = {`SOC_TOP.u_iopad_gpio_14_.PD,
                `SOC_TOP.u_iopad_gpio_13_.PD,
                `SOC_TOP.u_iopad_gpio_12_.PD,
                `SOC_TOP.u_iopad_gpio_11_.PD,
                `SOC_TOP.u_iopad_gpio_10_.PD,
                `SOC_TOP.u_iopad_gpio_9_.PD,
                `SOC_TOP.u_iopad_gpio_8_.PD,
                `SOC_TOP.u_iopad_gpio_7_.PD,
                `SOC_TOP.u_iopad_gpio_6_.PD,
                `SOC_TOP.u_iopad_gpio_5_.PD,
                `SOC_TOP.u_iopad_gpio_4_.PD,
                `SOC_TOP.u_iopad_gpio_3_.PD,
                `SOC_TOP.u_iopad_gpio_2_.PD,
                `SOC_TOP.u_iopad_gpio_1_.PD,
                `SOC_TOP.u_iopad_gpio_0_.PD};
`else
            temp_data = {`SOC_TOP.u_iopad_gpio[14].PD,
		`SOC_TOP.u_iopad_gpio[13].PD,
		`SOC_TOP.u_iopad_gpio[12].PD,
		`SOC_TOP.u_iopad_gpio[11].PD,
		`SOC_TOP.u_iopad_gpio[10].PD,
                `SOC_TOP.u_iopad_gpio[9].PD,
                `SOC_TOP.u_iopad_gpio[8].PD,
                `SOC_TOP.u_iopad_gpio[7].PD,
                `SOC_TOP.u_iopad_gpio[6].PD,
                `SOC_TOP.u_iopad_gpio[5].PD,
                `SOC_TOP.u_iopad_gpio[4].PD,
                `SOC_TOP.u_iopad_gpio[3].PD,
                `SOC_TOP.u_iopad_gpio[2].PD,
                `SOC_TOP.u_iopad_gpio[1].PD,
                `SOC_TOP.u_iopad_gpio[0].PD};
`endif 

	if(temp_data !== top_test_cfg.GPIO_PD)begin
	    `nnc_error("PINMUX", $sformatf("IOBUF_PD = %h is not as expectation of GPIO_PD = %h",temp_data, top_test_cfg.GPIO_PD))
	end

	if(`SOC_TOP.IO_clksel_PD !== `SPI_TOP.spi_reg_u.gpio_pd_ctrl[0])begin
	    `nnc_error("PINMUX", $sformatf("IO_clksel_PD = %h is not as expectation of gpio_pd_ctrl[0] = %h",`SOC_TOP.IO_clksel_PD, `SPI_TOP.spi_reg_u.gpio_pd_ctrl[0]))
	end


    end
 
    end

  endtask
endclass : `TESTNAME
  
