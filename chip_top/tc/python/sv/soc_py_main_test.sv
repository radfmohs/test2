//========================================================================================================  
// -------------------------------------------------------------------------------------------------------  
//  Nanochap Electronics Copyright (C) 2014. ALL RIGHTS RESERVED.  
// -------------------------------------------------------------------------------------------------------  
// Project name    : ENS2
// File name       : soc_py_main_test.sv
// Description     : Testcase soc_py_main_test for system verilog    
// -------------------------------------------------------------------------------------------------------  
// Revision History:  
// -------------------------------------------------------------------------------------------------------  
// Revision       Date(dd-mm-yyyy)     Author                       Description  
// -------------------------------------------------------------------------------------------------------  
//   1.0          24-03-2025           ddang@nanochap.com           Initial version
// -------------------------------------------------------------------------------------------------------  
//========================================================================================================
`define WORD_OFFSET_PYTHON 32+32+`ALL_IMEAS_SIZE*2/32 
// Geting data from 
task do_run_python;
  //input integer element;
begin

  // =====================================
  // Init for C and Python
  // =====================================
  c_py_init();

  // =====================================
  // Sending SV to Python
  // =====================================
  //wait(python_data_num == element);  
  // --------------------------------------------------------
  // Sending configuration code to identify the data is IMEAS 
  local_mode[63:0] = {21'h0, dut_vif.waveshape_sel , dut_vif.wavegen_sample_num_per_period, 32'hFAFAFAFA};
  // --------------------------------------------------------
  // Sending randomized SEED from TB to Python 
  local_mode[95:64] = seed;
  // --------------------------------------------------------
  // Sending reserved code from TB to Python for any purpose  
  local_mode[127:96] = 32'h0; // reserved

  // --------------------------------------------------------
  // Set Data Length and send to Python
  
  if (python_data_num < dut_vif.python_length + `WORD_OFFSET_PYTHON) 
    local_len = (python_data_num_0 + `WORD_OFFSET_PYTHON ) | ((python_data_num_1 + `WORD_OFFSET_PYTHON) << 16);
  else begin 
    if (python_data_num_0 > python_data_num_1)
       local_len = ((python_data_num_1 + `WORD_OFFSET_PYTHON) << 16) | (dut_vif.python_length + `WORD_OFFSET_PYTHON); 
    else
       local_len = (python_data_num_0 + `WORD_OFFSET_PYTHON) | ((dut_vif.python_length + `WORD_OFFSET_PYTHON) << 16); 
  end

  // --------------------------------------------------------
  // Start sending to Python
  SV2PY(local_mode[127:0], local_data, local_len);

  // =====================================
  // Sending Python to SV
  // =====================================
  local_mode[63:0] = 64'hBABEBABEBABEBABE;
  PY2SV(local_mode[63:0], rd_data, local_len);
  while (rd_data[63:32] != 32'hE0FDE0FD) begin  
    #10000ns; 
    PY2SV(local_mode[63:0], rd_data, local_len);
  end 

  // =====================================
  // Enable Python to run main to process data
  // =====================================
  #10000;
 
  // Call main_test to collect DATA
  main_test();

  // =====================================
  // Release objects for C and Python
  // =====================================
  #10000;
  c_py_final();

  // =====================================
  // Result Report
  // =====================================
  if (rd_data[31:0] == 32'hDEADBABE)
    `nnc_error("PYTHON ENV", $sformatf("Python is reported the ERROR: %h", rd_data[31:0]))
  else if (rd_data[31:0] == 32'hCAFEBABE) begin
    #1000ns;
    `nnc_info("PYTHON ENV", "Python is reported the PASSED", UVM_LOW)
  end
  else begin
    #1000ns;
    `nnc_info("PYTHON ENV", "Python isn't reporting the RESULT as UNKNOWN", UVM_LOW)
  end

end
endtask
