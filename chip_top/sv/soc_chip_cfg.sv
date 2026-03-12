/*--------------------------------------------------------------------------------------
// Copyright 2021 Nanochap, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_chip_cfg.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: SOC Top Config                                    
// Designer	: ddang@nanochap.com                                                                 
// Date		: 18-03-2024                                                                    
// Revision	: 0.1                                 
--------------------------------------------------------------------------------------*/
`ifndef SOC_CONFIGURATION__SV
`define SOC_CONFIGURATION__SV
class soc_chip_cfg extends nnc_object;
  `ifndef OTP_ENABLE
  nnc_eeprom_config                    eeprom_cfg;
`else
  nnc_eprom_config                     eprom_cfg;
`endif
  //reset_config;
  //timer_config                    timer_cfg;  
  //soc_analog_config              analog_cfg;
  nnc_spi_monitor_config          spi_cfg;
  nnc_sysc_config                 sysc_cfg;
  nnc_boost_config                boost_cfg;
  nnc_imeas_cfg                   imeas_cfg;
  nnc_lead_off_config             lead_off_cfg;
  nnc_wavegen_config              wavegen_cfg[`WAVEGEN_NUM_OF_MULT_CHIPS];
  nnc_pinmux_config               pinmux_cfg;
  nnc_analog_config               ana_cfg;
  virtual dut_interface           dut_if;

  `nnc_object_utils_begin(soc_chip_cfg)
    //`nnc_field_object (timer_cfg, UVM_ALL_ON | UVM_DEEP)
  `nnc_object_utils_end

  extern function new (string name = "soc_chip_cfg");

endclass

function soc_chip_cfg::new( string name = "soc_chip_cfg");
  super.new(name);
  `ifndef OTP_ENABLE
  eeprom_cfg = new();
`else
  eprom_cfg = new();
`endif
  //analog_cfg = new("analog_cfg");
  spi_cfg = new("spi_cfg");
  sysc_cfg = new("sysc_cfg");
  ana_cfg = new("ana_cfg");
  boost_cfg = new("boost_cfg");
  pinmux_cfg = new("pinmux_cfg");
  imeas_cfg = new("imeas_cfg");
  lead_off_cfg = new("lead_off_cfg");
  for (int i=0; i<`WAVEGEN_NUM_OF_MULT_CHIPS;i++) begin
    wavegen_cfg[i] = new($sformatf("wavegen_cfg[%0d]",i));
    `nnc_info("WAVE MON",$sformatf("creating wavegen_cfg[%0d] = %0p",i,wavegen_cfg[i]),NNC_MEDIUM)
  end

  if (!nnc_config_db#(virtual dut_interface)::get(null, "", "dut_if", dut_if))
    `nnc_fatal(get_full_name(), "Please set interface")
endfunction: new
`endif

