  import uvm_pkg::*;
  import soc_top_pkg::*;

class soc_base_sequence extends uvm_sequence;

  `uvm_object_utils(soc_base_sequence)
  `uvm_declare_p_sequencer(soc_virtual_sequencer)

  function new(string name = "soc_base_sequence");
    super.new(name);
    `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
  endfunction

  virtual task generate_random_value();
    forever begin
      #10ns;
      end
  endtask

  virtual task pre_start();
  endtask

  virtual task post_start();
    if (get_parent_sequence() == null && starting_phase != null)
      starting_phase.drop_objection(get_sequencer());
  endtask

  virtual task drive_reset();
    `uvm_info("body","reset_seq  ...", UVM_LOW)
    `uvm_info("body","reset_seq done  ...", UVM_LOW)
  endtask

  virtual task run_packet_check();
  endtask

endclass: soc_base_sequence
