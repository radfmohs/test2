/*--------------------------------------------------------------------------------------
// Copyright 1616 Nanochap, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_gpio_pu_test.sv                                                   
// Project	: Nanochap BPS1                                  		        
// Description	: Testcase soc_gpio_pu_test                                             
// Designer	: ddang@nanochap.com                                                                 
// Date		: 29-11-1623                                                                     
// Revision	: 0.1 Initial version created by script                                 
--------------------------------------------------------------------------------------*/
`define TESTNAME soc_gpio_pu_test
`define TESTCFG soc_gpio_pu_test_cfg

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

  rand logic [`GPIO_NUM-1:0] GPIO_PU;

  
  // -----------------------------------------------
  // End of decalration of new variables 
  // -----------------------------------------------

  function new (string name = "soc_gpio_pu_test_cfg");
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

    
    phase.drop_objection(this);
  endtask : pre_reset_phase
    
  virtual task main_phase(nnc_phase phase);
    phase.raise_objection(this);

    `nnc_info("SOC_TEST", "soc_gpio_pu_test start", NNC_LOW)
    #50us;
    do_run;
            
    phase.drop_objection(this);
  endtask: main_phase 

  virtual task do_run;
    logic [10:0] temp_data;          
    begin
  
    #1000ns;

    `ifdef BEHAVIORAL
    // Check the initial pads
	top_test_cfg.GPIO_PU = {{5{1'b0}}, `SPI_TOP.spi_reg_u.gpio_pu_ctrl[2:0], {3{1'b0}}};  
       if(`SPI_TOP.spi_reg_u.gpio_pu_ctrl !== `INIT_SOC_GPIO_PU_CTRL_REG) begin
            `nnc_error("PINMUX", $sformatf("`SPI_TOP.spi_reg_u.gpio_pu_ctrl = %h is not as expectation of INIT_SOC_GPIO_PU_CTRL_REG: %h",`SPI_TOP.spi_reg_u.gpio_pu_ctrl, `INIT_SOC_GPIO_PU_CTRL_REG))
        end
     
      	if(`SOC_TOP.IOBUF_PU !== top_test_cfg.GPIO_PU)begin
	    `nnc_error("PINMUX", $sformatf("IOBUF_PU = %h is not as expectation of GPIO_PU = %h",`SOC_TOP.IOBUF_PU, top_test_cfg.GPIO_PU))
	end           
    `endif
    for (int i=0; i < 100; i++) begin    

	//force `DIG_TOP.u_gpio.i_gpio_pu_ctrl[7:0] = $random;
	//force `DIG_TOP.u_gpio.i_gpio_pd_ctrl[7:0] = $random;
	//force `DIG_TOP.u_gpio.i_gpio_sr_pdrv0_1_ctrl[2:0] = $random;
	force `SPI_TOP.spi_reg_u.gpio_pu_ctrl = $random;
	
	#1000ns;   

	//top_test_cfg.GPIO_PU = {8'b0,`DIG_TOP.u_gpio.i_gpio_pu_ctrl};
	top_test_cfg.GPIO_PU = {{5{1'b0}}, `SPI_TOP.spi_reg_u.gpio_pu_ctrl[2:0], {3{1'b0}}};

	#1000ns; 

`ifndef BEHAVIORAL
            temp_data = {`SOC_TOP.u_iopad_gpio_10_.PU,
                `SOC_TOP.u_iopad_gpio_9_.PU,
                `SOC_TOP.u_iopad_gpio_8_.PU,
                `SOC_TOP.u_iopad_gpio_7_.PU,
                `SOC_TOP.u_iopad_gpio_6_.PU,
                `SOC_TOP.u_iopad_gpio_5_.PU,
                `SOC_TOP.u_iopad_gpio_4_.PU,
                `SOC_TOP.u_iopad_gpio_3_.PU,
                `SOC_TOP.u_iopad_gpio_2_.PU,
                `SOC_TOP.u_iopad_gpio_1_.PU,
                `SOC_TOP.u_iopad_gpio_0_.PU};
`else
            temp_data = {`SOC_TOP.u_iopad_gpio[10].PU,
                `SOC_TOP.u_iopad_gpio[9].PU,
                `SOC_TOP.u_iopad_gpio[8].PU,
                `SOC_TOP.u_iopad_gpio[7].PU,
                `SOC_TOP.u_iopad_gpio[6].PU,
                `SOC_TOP.u_iopad_gpio[5].PU,
                `SOC_TOP.u_iopad_gpio[4].PU,
                `SOC_TOP.u_iopad_gpio[3].PU,
                `SOC_TOP.u_iopad_gpio[2].PU,
                `SOC_TOP.u_iopad_gpio[1].PU,
                `SOC_TOP.u_iopad_gpio[0].PU};

`endif 

    if(temp_data !== top_test_cfg.GPIO_PU)begin
	    `nnc_error("PINMUX", $sformatf("IOBUF_PU = %h is not as expectation of GPIO_PU = %h",temp_data, top_test_cfg.GPIO_PU))
	end           

   

    end
    end
  endtask
endclass : `TESTNAME
  
