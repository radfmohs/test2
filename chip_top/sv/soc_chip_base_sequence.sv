/*--------------------------------------------------------------------------------------
// Copyright 2021 Nanochap, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_chip_base_sequence.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: SOC Base Sequence Class                                    
// Designer	: ddang@nanochap.com                                                                 
// Date		: 18-03-2024                                                                    
// Revision	: 0.1                                 
--------------------------------------------------------------------------------------*/
`ifndef SOC_BASE_SEQUENCE__SV
`define SOC_BASE_SEQUENCE__SV
class soc_chip_base_sequence extends nnc_sequence;

  `nnc_object_utils(soc_chip_base_sequence)
  `nnc_declare_p_sequencer(soc_chip_virtual_sequencer)

  function new(string name = "soc_chip_base_sequence");
    super.new(name);
    `nnc_info("TRACE", $sformatf("%m"), UVM_HIGH);
  endfunction

  virtual task generate_random_value();
    forever begin
      #10ns;
      end
  endtask

  virtual task pre_start();
    if (get_parent_sequence() == null && starting_phase != null)
      starting_phase.raise_objection(get_sequencer());
  endtask

  virtual task post_start();
    if (get_parent_sequence() == null && starting_phase != null)
      starting_phase.drop_objection(get_sequencer());
  endtask

  virtual task drive_reset();
    `nnc_info("body","reset_seq  ...", UVM_LOW)
    //`nnc_do_on(reset_seq, p_sequencer.xxx_sqr.yyy_virt_sequencer.zzz_sequencer)
    `nnc_info("body","reset_seq done  ...", UVM_LOW)
  endtask

  virtual task run_packet_check();
    if (!run_pkt_checker) begin
      run_pkt_checker=1;
      //`nnc_do_on(get_agent_seq, p_sequencer.xxx_sqr.yyy_virt_sequencer.zzz_sequencer)
      //this.l_agent = get_agent_seq.l_agent;
      //pkt_checker = new("pkt_checker");
      //p_sequencer.xxx_sqr.init.pkt_checker = pkt_checker;
      //nnc_callbacks#(`xxx_protocol)::add(l_agent.prot, pkt_checker);
      end
  endtask

endclass: soc_chip_base_sequence
`endif

