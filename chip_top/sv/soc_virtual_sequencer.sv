/*--------------------------------------------------------------------------------------
// Copyright 2021 Nanochap, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_virtual_sequencer.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: SOC Top Sequencer                                     
// Designer	: ddang@nanochap.com                                                                 
// Date		: 18-03-2024                                                                    
// Revision	: 0.1                                 
--------------------------------------------------------------------------------------*/
`ifndef SOC_VIRTUAL_SEQUENCER__SV
`define SOC_VIRTUAL_SEQUENCER__SV
class soc_virtual_sequencer extends nnc_sequencer;

  //nnc_i2c_vip_sequencer                         i2c_sqr;

  virtual dut_interface                         dut_if;

  soc_chip_cfg                                 top_cfg;
  //nnc_i2c_vip_config                            i2c_cfg;

  nnc_analysis_port#(logic [7:0])               exp_port_data[4];
  //nnc_analysis_port#(nnc_i2c_vip_packet)        i2c_exp_port;

  `nnc_sequencer_utils(soc_virtual_sequencer)

  function new ( string name, nnc_component parent);
    super.new(name, parent);
    exp_port_data[3] = new("exp_port_data[3]",this);
    exp_port_data[2] = new("exp_port_data[2]",this);
    exp_port_data[1] = new("exp_port_data[1]",this);
    exp_port_data[0] = new("exp_port_data[0]",this);

    `nnc_update_sequence_lib

  endfunction: new
  
  virtual function void build_phase(nnc_phase phase);
    super.build_phase(phase);

    if(!nnc_config_db#(virtual dut_interface)::get(this, "", "dut_if", dut_if))
      `nnc_fatal("TOP_SQR", "Can't get dut_if");

    if (!nnc_config_db#(soc_chip_cfg)::get(this, "", "top_cfg", top_cfg))
      `nnc_fatal("TOP_SQR", "Can't get top_cfg");

  endfunction

endclass: soc_virtual_sequencer
`endif

