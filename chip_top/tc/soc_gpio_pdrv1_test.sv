/*--------------------------------------------------------------------------------------
// Copyright 1616 Nanochap, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_gpio_pdrv1_test.sv                                                   
// Project	: Nanochap BPS1                                  		        
// Description	: Testcase soc_gpio_pdrv1_test                                             
// Designer	: ddang@nanochap.com                                                                 
// Date		: 29-11-1623                                                                     
// Revision	: 0.1 Initial version created by script                                 
--------------------------------------------------------------------------------------*/
`define TESTNAME soc_gpio_pdrv1_test
`define TESTCFG soc_gpio_pdrv1_test_cfg

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

  rand logic [`GPIO_NUM-1:0] GPIO_PDRV1;

  
  // -----------------------------------------------
  // End of decalration of new variables 
  // -----------------------------------------------

  function new (string name = "soc_gpio_pdrv1_test_cfg");
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

    `nnc_info("PINMUX","Internal clock test",NNC_LOW)
    #50us;
    do_run;
            
    phase.drop_objection(this);
  endtask: main_phase 

  virtual task do_run;
    logic [`GPIO_NUM:0] temp_data;        
    begin
    `DUT_IF.iopad_gpio[`GPIO_NUM-1:0] = 0;        
    force `SOC_TB.iopad_resetn = 1'b0;
    #1000ns;
    force `SOC_TB.iopad_resetn = 1'b1;
    #1000ns;
    //Check GPIO_PDRV1 [15:0] rw

    for (int i=0; i < 100; i++) begin    

        //force `DIG_TOP.u_gpio.i_gpio_pu_ctrl[7:0] = $random;
        //force `DIG_TOP.u_gpio.i_gpio_pd_ctrl[7:0] = $random;
        force `SPI_TOP.spi_reg_u.gpio_sr_pdrv0_1_ctrl[2:0] = $random;
        top_test_cfg.GPIO_PDRV1 = {`GPIO_NUM{`SPI_TOP.spi_reg_u.gpio_sr_pdrv0_1_ctrl[2]}};

        #1000ns;
`ifndef BEHAVIORAL
            temp_data = {`SOC_TOP.u_iopad_gpio_14_.PDRV1,
		`SOC_TOP.u_iopad_gpio_13_.PDRV1,
	        `SOC_TOP.u_iopad_gpio_12_.PDRV1,
	        `SOC_TOP.u_iopad_gpio_11_.PDRV1,
	        `SOC_TOP.u_iopad_gpio_10_.PDRV1,	
                `SOC_TOP.u_iopad_gpio_9_.PDRV1,
                `SOC_TOP.u_iopad_gpio_8_.PDRV1,
                `SOC_TOP.u_iopad_gpio_7_.PDRV1,
                `SOC_TOP.u_iopad_gpio_6_.PDRV1,
                `SOC_TOP.u_iopad_gpio_5_.PDRV1,
                `SOC_TOP.u_iopad_gpio_4_.PDRV1,
                `SOC_TOP.u_iopad_gpio_3_.PDRV1,
                `SOC_TOP.u_iopad_gpio_2_.PDRV1,
                `SOC_TOP.u_iopad_gpio_1_.PDRV1,
                `SOC_TOP.u_iopad_gpio_0_.PDRV1};
`else
            temp_data = {`SOC_TOP.u_iopad_gpio[14].PDRV1,
		`SOC_TOP.u_iopad_gpio[13].PDRV1,
		`SOC_TOP.u_iopad_gpio[12].PDRV1,
		`SOC_TOP.u_iopad_gpio[11].PDRV1,
		`SOC_TOP.u_iopad_gpio[10].PDRV1,
                `SOC_TOP.u_iopad_gpio[9].PDRV1,
                `SOC_TOP.u_iopad_gpio[8].PDRV1,
                `SOC_TOP.u_iopad_gpio[7].PDRV1,
                `SOC_TOP.u_iopad_gpio[6].PDRV1,
                `SOC_TOP.u_iopad_gpio[5].PDRV1,
                `SOC_TOP.u_iopad_gpio[4].PDRV1,
                `SOC_TOP.u_iopad_gpio[3].PDRV1,
                `SOC_TOP.u_iopad_gpio[2].PDRV1,
                `SOC_TOP.u_iopad_gpio[1].PDRV1,
                `SOC_TOP.u_iopad_gpio[0].PDRV1};
`endif 
         
        if(temp_data !== top_test_cfg.GPIO_PDRV1)begin
            `nnc_error("PINMUX", $sformatf("IOBUF_PDRV1 = %h is not as expectation of GPIO_PDRV1 = %h",temp_data, top_test_cfg.GPIO_PDRV1))
        end 
    end
    end
  endtask
endclass : `TESTNAME
  
