/*--------------------------------------------------------------------------------------
// Copyright 1616 Nanochap, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_gpio_cs_test.sv                                                   
// Project	: Nanochap BPS1                                  		        
// Description	: Testcase soc_gpio_cs_test                                             
// Designer	: ddang@nanochap.com                                                                 
// Date		: 29-11-1623                                                                     
// Revision	: 0.1 Initial version created by script                                 
--------------------------------------------------------------------------------------*/
`define TESTNAME soc_gpio_cs_test
`define TESTCFG soc_gpio_cs_test_cfg

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

  rand logic [`GPIO_NUM-1:0] GPIO_CS;

  
  // -----------------------------------------------
  // End of decalration of new variables 
  // -----------------------------------------------

  function new (string name = "soc_gpio_cs_test_cfg");
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
    `ANALOG_SCOREBOARD_EN = 1'b0;

    
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
    logic [10:0] temp_data;  
    begin
    `DUT_IF.iopad_gpio[`GPIO_NUM-1:0] = 0;        
    force `SOC_TB.iopad_resetn = 1'b0;
    #1000ns;
    force `SOC_TB.iopad_resetn = 1'b1;
    #1000ns;
    //Check CS [15:0] rw

    for (int i=0; i < 100; i++) begin    

        //force `DIG_TOP.u_gpio.i_gpio_pu_ctrl[7:0] = $random;
        //force `DIG_TOP.u_gpio.i_gpio_pd_ctrl[7:0] = $random;
        //force `DIG_TOP.u_gpio.i_gpio_sr_pdrv0_1_ctrl[2:0] = $random;

        top_test_cfg.GPIO_CS = 11'h000;//CS IS 0

        #1000ns;

`ifndef BEHAVIORAL 
            temp_data = {`SOC_TOP.u_iopad_gpio_10_.CS,
                `SOC_TOP.u_iopad_gpio_9_.CS,
                `SOC_TOP.u_iopad_gpio_8_.CS,
                `SOC_TOP.u_iopad_gpio_7_.CS,
                `SOC_TOP.u_iopad_gpio_6_.CS,
                `SOC_TOP.u_iopad_gpio_5_.CS,
                `SOC_TOP.u_iopad_gpio_4_.CS,
                `SOC_TOP.u_iopad_gpio_3_.CS,
                `SOC_TOP.u_iopad_gpio_2_.CS,
                `SOC_TOP.u_iopad_gpio_1_.CS,
                `SOC_TOP.u_iopad_gpio_0_.CS};
`else
            temp_data = {`SOC_TOP.u_iopad_gpio[10].CS,
                `SOC_TOP.u_iopad_gpio[9].CS,
                `SOC_TOP.u_iopad_gpio[8].CS,
                `SOC_TOP.u_iopad_gpio[7].CS,
                `SOC_TOP.u_iopad_gpio[6].CS,
                `SOC_TOP.u_iopad_gpio[5].CS,
                `SOC_TOP.u_iopad_gpio[4].CS,
                `SOC_TOP.u_iopad_gpio[3].CS,
                `SOC_TOP.u_iopad_gpio[2].CS,
                `SOC_TOP.u_iopad_gpio[1].CS,
                `SOC_TOP.u_iopad_gpio[0].CS};
`endif 
         
//`ifdef BEHAVIORAL               
        if(temp_data !== top_test_cfg.GPIO_CS)begin
            `nnc_error("PINMUX", $sformatf("IOBUF_CS = %h is not as expectation of gpio_cs = %h",temp_data, top_test_cfg.GPIO_CS))
        end
//`endif
    end
    end
  endtask
endclass : `TESTNAME
  
