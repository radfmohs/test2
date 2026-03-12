/*--------------------------------------------------------------------------------------
// Copyright 2021 Nanochap, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_top_pkg.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: SOC Top Package                                        
// Designer	: ddang@nanochap.com                                                                 
// Date		: 18-03-2024                                                                    
// Revision	: 0.1                                 
--------------------------------------------------------------------------------------*/
`ifndef soc_top_pkg__SV
`define soc_top_pkg__SV
`include "soc_dut_interface.sv"
package soc_top_pkg;

 import nnc_uvm_pkg::*;
 //import nnc_spi_pkg::*;
 import nnc_sysc_pkg::*;
 import nnc_spi_pkg::*;
 import nnc_boost_pkg::*;
 import nnc_lead_off_pkg::*;
 import nnc_imeas_pkg::*;
 import nnc_wavegen_pkg::*;
 import nnc_analog_pkg::*;
 import nnc_pinmux_pkg::*;

`ifndef OTP_ENABLE
 import nnc_eeprom_pkg::*;
`else
 import nnc_eprom_pkg::*;
`endif

 `include "nnc_uvm_methodology.svh"
//  import eeprom_pkg::*;
//  import timer_pkg::*;
//  import soc_analog_pkg::*;
 `include "soc_chip_cfg.sv"

 `include "soc_virtual_sequencer.sv"
  //`include "soc_chip_base_sequence.sv"
  `include "soc_scoreboard.sv"
  `include "soc_env.sv"

endpackage: soc_top_pkg
`endif
