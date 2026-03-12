/*======================================================================================
// Copyright 2021 Nanochap, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_test_pkg.f                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: List of testcases                                          
// Designer	: ddang@nanochap.com                                                                 
// Date		: 18-03-2024                                                                    
// Revision	: 0.1                                 
=======================================================================================*/
// FIFO DATA MONITOR and checking DATA
logic [17:0] imeas_chdata;
logic [19:0] imeas2fifo_data_mem [$];
logic n;// = $random();
integer imeas2fifo_mem_cnt=0;
integer imeas2fifo_lost_item=0;
bit fifo_intr_pin_test_enable = 0;
bit imeas_intr_pin_test_enable = 0;
bit zmeas_intr_pin_test_enable = 0;
bit display_err = 1;
logic checker_en;
`ifdef FPGA
assign checker_en = ({`ENS2_TOP.iopad_testmode1_en_y_always_on, `ENS2_TOP.iopad_testmode0_en_y_always_on} == 2'b01) ? 1'b0 : 1'b1;
`else
assign checker_en = ({`ENS2_TOP.iopad_testmode1, `ENS2_TOP.iopad_testmode0} == 2'b01) ? 1'b0 : 1'b1;
`endif

`ifdef POSTSCAN_FORCE_RAND
initial
  begin
  wait(`RESETN);
  while (1)
    begin
      //@(posedge `FIFO_TOP.clk);
        n = $random();
      //end
    end
  end

initial
  begin
  wait(`RESETN);
  while (1)
    begin
      //@(posedge `FIFO_TOP.clk);
        n = $random();
      //end
    end
  end

`endif
// ------------------------------------------------------------
// This assertion is used for checking TAGS from IMEAS to FIFO
// ------------------------------------------------------------


// ---------------------------------------------------------------
// This assertion is used for checking TAGS from FIFO to SPI Slave
// ---------------------------------------------------------------

// ------------------------------------------------------------
// Please add your block here
// ------------------------------------------------------------

