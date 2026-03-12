/*--------------------------------------------------------------------------------------
// Copyright 2021 Nanochap, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_scoreboard.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: ENS2 Top Scoreboard                                       
// Designer	: ddang@nanochap.com                                                                 
// Date		: 18-03-2024                                                                    
// Revision	: 0.1                                 
--------------------------------------------------------------------------------------*/
`ifndef SOC_SCOREBOARD__SV
`define SOC_SCOREBOARD__SV
class soc_scoreboard extends nnc_scoreboard;

  //soc_config                                          soc_cfg;
  //nnc_in_order_class_comparator #(nnc_soc_vip_packet) wr_cmpr;
  //nnc_in_order_class_comparator #(nnc_soc_vip_packet) rd_cmpr;
  //nnc_in_order_class_comparator #(nnc_soc_vip_packet) cmpr;
  //nnc_analysis_export #(nnc_soc_vip_packet)           exp_export;
  //nnc_analysis_export #(nnc_soc_vip_packet)           mon_export;

  `nnc_component_utils(soc_scoreboard)

  function new(string name, nnc_component parent);
    super.new(name, parent);
  endfunction: new

  virtual function void build_phase(nnc_phase phase);
    super.build_phase(phase);
    //exp_export = new("exp_export", this);
    //mon_export = new("mon_export", this);
    //cmpr = nnc_in_order_class_comparator #(nnc_soc_vip_packet)::type_id::create("comparator", this);
    //if (!nnc_config_db#(soc_config)::get(this, "", "soc_cfg", soc_cfg))
    //  `nnc_fatal(get_full_name(), "Can't get soc_cfg");
  endfunction: build_phase

  virtual function void connect_phase(nnc_phase phase);
    super.connect_phase(phase);
   // exp_export.connect(cmpr.before_export);
   // mon_export.connect(cmpr.after_export);
  endfunction: connect_phase

  function void report_phase(nnc_phase phase);
    super.report_phase(phase);
  /*
    if (soc_cfg.scoreboard_en)
      begin
        if (cmpr.m_mismatches !== 0) 
          `nnc_error("soc_SCOREBOARD_REPORT", $sformatf("Mismatches = %0d", cmpr.m_mismatches))
          //if (cmpr.m_matches == 0)
          //  `nnc_error("soc_SCOREBOARD_REPORT", "I2C_SBC didn't receive any packet to compare")
        `nnc_info("soc_SCOREBOARD_REPORT", $sformatf("Matches = %0d, Mismatches = %0d", cmpr.m_matches, cmpr.m_mismatches), UVM_LOW)
      end
   */
  endfunction: report_phase

endclass: soc_scoreboard
`endif
