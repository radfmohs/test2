/*--------------------------------------------------------------------------------------*/
// Copyright 2021 Nanochap, Inc.
// All Rights Reserved Worldwide
// --------------------------------------------------------------------------------------
// Project      : Nanochap ENS2
// File         : tb_chip_top_uvm_monitor.sv
// Description  : USEFUL DISPLAY for TOP TB (included file) 
// Designer     : Daniel Dang
// Date         : 18-03-2024
// Revision     : 0.1
/*--------------------------------------------------------------------------------------*/

real tDR_period;
real tCLK_period;

initial begin
#1;
      $display("#################################################################################");
      $display("## --------------------------------------------------------------------------- ##"); 
      $display("##           WELCOME TO ENS2 PROJECT - NANOCHAP ELECTRONICS CORP               ##");
      $display("## --------------------------------------------------------------------------- ##");
      $display("##         THIS IS CONFIGURATION OF CURRENT HARWARE IN SIMULATION              ##");      
      $display("## --------------------------------------------------------------------------- ##");    
      $display("## PLEASE DON'T FORGET TO DELETE OLD & UNUSED FILES IN THE SCRATCH DIRECTORY   ##");      
      $display("## --------------------------------------------------------------------------- ##");  
`ifdef POSTLAYOUT_PG
   `ifdef SDFANNOTATE_MAX
      `ifdef MIX_SIM_EN
      $display("##          WE ARE RUNNING POSTLAYOUT_PG SDF_MAX MIX SIGNAL SIMULATION MODE    ##");
      `else
      $display("##          WE ARE RUNNING POSTLAYOUT_PG SDF_MAX SIMULATION MODE               ##");
      `endif
   `elsif SDFANNOTATE_MIN
      `ifdef MIX_SIM_EN
      $display("##          WE ARE RUNNING POSTLAYOUT_PG SDF_MIN MIX SIGNAL SIMULATION MODE    ##");
      `else
      $display("##          WE ARE RUNNING POSTLAYOUT_PG SDF_MIN SIMULATION MODE               ##");
      `endif
   `elsif SDFANNOTATE_TYP
      `ifdef MIX_SIM_EN
      $display("##          WE ARE RUNNING POSTLAYOUT_PG SDF_TYP MIX SIGNAL SIMULATION MODE    ##");
      `else
      $display("##          WE ARE RUNNING POSTLAYOUT_PG SDF_TYP SIMULATION MODE               ##");
      `endif
   `else
      $display("##          WE ARE RUNNING POSTLAYOUT_PG NO SDF SIMULATION MODE                ##"); 
   `endif
`elsif POSTLAYOUT
      $display("##                WE ARE RUNNING POSTLAYOUT SIMULATION MODE                    ##");
`elsif POSTSCAN_PG
   `ifdef SDFANNOTATE_MAX
      `ifdef MIX_SIM_EN
      $display("##          WE ARE RUNNING POSTSCAN_PG SDF_MAX MIX SIGNAL SIMULATION MODE      ##");
      `else
      $display("##           WE ARE RUNNING POSTSCAN_PG SDF_MAX SIMULATION MODE                ##");
      `endif
   `elsif SDFANNOTATE_MIN
      `ifdef MIX_SIM_EN
      $display("##          WE ARE RUNNING POSTSCAN_PG SDF_MIN MIX SIGNAL SIMULATION MODE      ##");
      `else
      $display("##           WE ARE RUNNING POSTSCAN_PG SDF_MIN SIMULATION MODE                ##");
      `endif
   `elsif SDFANNOTATE_TYP
      `ifdef MIX_SIM_EN
      $display("##          WE ARE RUNNING POSTSCAN_PG SDF_TYP MIX SIGNAL SIMULATION MODE      ##");
      `else
      $display("##           WE ARE RUNNING POSTSCAN_PG SDF_TYP SIMULATION MODE                ##");
      `endif
   `else 
      $display("##           WE ARE RUNNING POSTSCAN_PG NO SDF SIMULATION MODE                 ##"); 
   `endif     
`elsif POSTSCAN
      $display("##                 WE ARE RUNNING POSTSCAN SIMULATION MODE                     ##");
`elsif PRESCAN
      $display("##                WE ARE RUNNING PRESCAN SIMULATION MODE                       ##");
`else
      $display("##                 WE ARE RUNNING RTL SIMULATION MODE                          ##");
`endif  
      $display("## --------------------------------------------------------------------------- ##");
      $display("##             ENJOY YOUR WORK AND HAVE A NICE WORKRING DAY                    ##");      
      $display("## --------------------------------------------------------------------------- ##");             
      $display("#################################################################################");
      $display("");
end

// ================================
// This part is for Clock display
// Print at the initial of setting
always @(dut_vif.ext_clk_en or dut_vif.pclk_sel or dut_vif.spi_sclk_freq or dut_vif.spimode_sel or dut_vif.spi_clk_jitter or dut_vif.spi_sclk_jitter or dut_vif.spi_sclk_freq or dut_vif.tdist or dut_vif.tcssc or dut_vif.tsccs or dut_vif.tcsh or dut_vif.pclk_sel or dut_vif.altf_gpio_sel)
  begin
   #2;
        $display("=============================================================================");
      if(dut_vif.ext_clk_en === 1'b1)
        $display("== SOC EXT_CLK_EN: %d CONFIGURED to RUN ON EXTERNAL SYSTEM CLOCK", dut_vif.ext_clk_en);
      else
        $display("== SOC EXT_CLK_EN: %d CONFIGURED to RUN ON INTERNAL SYSTEM CLOCK", dut_vif.ext_clk_en);

      if (dut_vif.pclk_sel === 3'h0) 
         $display("== PCLK Clock Configuration: 8Mhz - Jitter: %d percent", dut_vif.spi_clk_jitter);
      else if (dut_vif.pclk_sel === 3'h1)
         $display("== PCLK Clock Configuration: 4Mhz - Jitter: %d percent", dut_vif.spi_clk_jitter);
      else if (dut_vif.pclk_sel === 3'h2)
         $display("== PCLK Clock Configuration: 2Mhz - Jitter: %d percent", dut_vif.spi_clk_jitter);
      else if (dut_vif.pclk_sel === 3'h3)
         $display("== PCLK Clock Configuration: 1Mhz - Jitter: %d percent", dut_vif.spi_clk_jitter);
      else if (dut_vif.pclk_sel === 3'h4)
         $display("== PCLK Clock Configuration: 512Khz - Jitter: %d percent", dut_vif.spi_clk_jitter);
      else if (dut_vif.pclk_sel === 3'h5)
         $display("== PCLK Clock Configuration: 256Khz - Jitter: %d percent", dut_vif.spi_clk_jitter);
      else if (dut_vif.pclk_sel === 3'h6)
         $display("== PCLK Clock Configuration: 128Khz - Jitter: %d percent", dut_vif.spi_clk_jitter);
      else if (dut_vif.pclk_sel === 3'h7)
         $display("== PCLK Clock Configuration: 64Khz - Jitter: %d percent", dut_vif.spi_clk_jitter);
      else
        `nnc_error("PCLK Monitor", $sformatf("Configuration from TESTCASE for PCLK=%h", dut_vif.pclk_sel))

      if (dut_vif.iclk_sel === 4'h0) 
         $display("== ADC CLK Clock Configuration: 8Mhz");
      else if (dut_vif.iclk_sel === 4'h1)
         $display("== ADC CLK Clock Configuration: 4Mhz");
      else if (dut_vif.iclk_sel === 4'h2)
         $display("== ADC CLK Clock Configuration: 2Mhz");
      else if (dut_vif.iclk_sel === 4'h3)
         $display("== ADC_CLK Clock Configuration: 1Mhz");
      else if (dut_vif.iclk_sel === 4'h4)
         $display("== ADC_CLK Clock Configuration: 512Khz");
      else if (dut_vif.iclk_sel === 4'h5)
         $display("== ADC_CLK Clock Configuration: 256Khz");
      else if (dut_vif.iclk_sel === 4'h6)
         $display("== ADC_CLK Clock Configuration: 128Khz");
      else if (dut_vif.iclk_sel === 4'h7)
         $display("== ADC_CLK Clock Configuration: 64Khz");
      else if (dut_vif.iclk_sel === 4'h8)
         $display("== ADC_CLK Clock Configuration: 32Khz");
      else if (dut_vif.iclk_sel === 4'h9)
         $display("== ADC_CLK Clock Configuration: 16Khz");
      else if (dut_vif.iclk_sel === 4'hA)
         $display("== ADC_CLK Clock Configuration: 8Khz");
      else if (dut_vif.iclk_sel === 4'hB)
         $display("== ADC_CLK Clock Configuration: 4Khz");
      else
        `nnc_error("ADC_CLK Monitor", $sformatf("Configuration from TESTCASE for ADC_CLK=%h", dut_vif.iclk_sel))

      $display("------------------------------------------------------------------------------");
      $display("== SPI SCLK Clock Configuration CPOL: %d CPHA: %d", dut_vif.spimode_sel[1], dut_vif.spimode_sel[0]);
      $display("== SPI SCLK Clock Configuration: %dKhz - Jitter: %d percent", dut_vif.spi_sclk_freq, dut_vif.spi_sclk_jitter);
      $display("== SPI Timming Configuration: Period(tCP): %d ns", 1000000 / dut_vif.spi_sclk_freq);
      $display("== SPI Timming Configuration: tcssc(tCCSO): %d ns", dut_vif.tcssc);
      $display("== SPI Timming Configuration: tsccs(tCSH1): %d ns", dut_vif.tsccs);
      $display("== SPI Timming Configuration: tcsh(tCSPW): %d ns", dut_vif.tcsh);
      $display("== SPI Timming Configuration: tch: %d percent -> (tCH): %d ns", dut_vif.tch, dut_vif.tch * 10000 / dut_vif.spi_sclk_freq);
      $display("== SPI Timming Configuration: tch: %d percent -> (tCL): %d ns", dut_vif.tch, (1 - dut_vif.tch * 0.01) * 1000000 / dut_vif.spi_sclk_freq);
      $display("== SPI Timming Configuration: tdist: %d ns and percent: %d", (10**6)/(2*dut_vif.spi_sclk_freq) - (((10**6)/(2*dut_vif.spi_sclk_freq) - 10)*(dut_vif.tdist)/100), dut_vif.tdist);
      $display("------------------------------------------------------------------------------");
      $display("== SPI ALTF Configuration: %d", dut_vif.altf_gpio_sel);
      if (dut_vif.TCK_SEL == 2'b00) 
        $display("== OTP BIST TCK Clock Configuration: 1Mhz");
      else if (dut_vif.TCK_SEL == 2'b01) 
        $display("== OTP BIST TCK Clock Configuration: 10Mhz");
      else if (dut_vif.TCK_SEL == 2'b10) 
        $display("== OTP BIST TCK Clock Configuration: 20Mhz");
      else if (dut_vif.TCK_SEL == 2'b11) 
        $display("== OTP BIST TCK Clock Configuration: 32Mhz");
      $display("------------------------------------------------------------------------------");
      if (dut_vif.mult_chip_en === 1'b0) begin
        $display("== SINGLE CHIP is running");
      end else begin
         if (dut_vif.swap_sdf_en === 1'b1)
            $display("== DUAL CHIP is running, and CHIP0 and CHIP2 are enabled. SDF files are swapped for corners");
         else
            $display("== DUAL CHIP is running, and CHIP0 and CHIP1 are enabled. SDF files are the same corner");
      end
      $display("=============================================================================");
  end

// ================================
// This part is for ENS2 Mode
// Print when it is changed during the tests
//iopad_gpio[9] is hfosc_out which is used in multichip
always @(dut_vif.testmode_sel or (dut_vif.iopad_gpio[8] && (dut_vif.testmode_sel === 2'b11)) or (dut_vif.iopad_gpio[9] && (dut_vif.testmode_sel === 2'b11)) or (dut_vif.iopad_gpio[10] && (dut_vif.testmode_sel === 2'b11)) /* or posedge dut_vif.soc_resetn */)
  begin
    case (dut_vif.testmode_sel)
      2'b00: begin
        $display("=============================================================================");
        $display("===== SOC IS RUNNING IN NORMAL MODE");
        $display("=============================================================================");
      end
      2'b10: begin
        $display("=============================================================================");
        $display("===== SOC IS RUNNING IN EEPROM BIST MODE");
        $display("=============================================================================");
      end
      2'b01: begin
        $display("=============================================================================");
        $display("===== SOC IS RUNNING IN SCAN MODE");
        $display("=============================================================================");
      end
      2'b11: begin
        case(dut_vif.iopad_gpio[10:8])
          3'b000: begin
             $display("=============================================================================");
             $display("===== SOC IS RUNNING IN ATM0 MODE");
             $display("=============================================================================");
          end
          3'b001: begin
             $display("=============================================================================");
             $display("===== SOC IS RUNNING IN ATM1 MODE");
             $display("=============================================================================");
          end
          3'b010: begin
             $display("=============================================================================");
             $display("===== SOC IS RUNNING IN ATM2 MODE");
             $display("=============================================================================");
          end
          3'b011: begin
             $display("=============================================================================");
             $display("===== SOC IS RUNNING IN ATM3 MODE");
             $display("=============================================================================");
          end
          3'b100: begin
             $display("=============================================================================");
             $display("===== SOC IS RUNNING IN ATM4 MODE");
             $display("=============================================================================");
          end
          3'b101: begin
             $display("=============================================================================");
             $display("===== SOC IS RUNNING IN ATM5 MODE");
             $display("=============================================================================");
          end
          3'b110: begin
             $display("=============================================================================");
             $display("===== SOC IS RUNNING IN ATM6 MODE");
             $display("=============================================================================");
          end
          3'b111: begin
             $display("=============================================================================");
             $display("===== SOC IS RUNNING IN ATM7 MODE");
             $display("=============================================================================");
          end
          default: begin
            `nnc_error("SOC Configuration", $sformatf("Error in configuration of dut_vif.iopad_gpio[10:8]: %h", dut_vif.iopad_gpio[10:8]))
          end
        endcase 
      end
    endcase
  end

`ifdef POSTSCAN_PG
  wire sdf_sim_en = 1; 
`elsif POSTLAYOUT_PG
  wire sdf_sim_en = 1;
`else
  wire sdf_sim_en = 0;
`endif

`ifndef MIX_SIM_EN
// Disable timing check
always @(`ANA_TOP.PMU_SW.CHIP_EN or `ANA_TOP_S1.PMU_SW.CHIP_EN or `ANA_TOP_S2.PMU_SW.CHIP_EN) 
begin
  #5; 
  if (`ANA_TOP.PMU_SW.CHIP_EN === 1'b0) begin
    $display("=============================================================================");
    $display("===== CHIP 0 is POWERED OFF"); 
    if (sdf_sim_en === 1'b1) begin
      $display("===== CHIP 0 is DISABLED for Timing Check at time: %t", $time);
      $disable_warnings(`SOC_TOP);
    end
    $display("=============================================================================");
  end else if (`ANA_TOP.PMU_SW.CHIP_EN === 1'b1) begin 
    $display("=============================================================================");
    $display("===== CHIP 0 is POWERED ON");
    if (sdf_sim_en === 1'b1) begin
      $display("===== CHIP 0 is ENABLED for Timing Check at time: %t", $time);
      $enable_warnings(`SOC_TOP);
    end
    $display("=============================================================================");
  end

  if (dut_vif.mult_chip_en === 1'b1) begin
    if (`ANA_TOP_S1.PMU_SW.CHIP_EN === 1'b0)  begin
      $display("=============================================================================");
      $display("===== CHIP 1 is POWERED OFF");
      if (sdf_sim_en === 1'b1) begin                                   
        $display("===== CHIP 1 is DISABLED for Timing Check at time: %t", $time);
        $disable_warnings(`SOC_TOP_S1);
      end
      $display("=============================================================================");
    end else if (`ANA_TOP_S1.PMU_SW.CHIP_EN === 1'b1) begin
      $display("=============================================================================");
      $display("===== CHIP 1 is POWERED ON");
      if (sdf_sim_en === 1'b1) begin  
        $display("===== CHIP 1 is ENABLED for Timing Check at time: %t", $time);
        $enable_warnings(`SOC_TOP_S1);
      end 
      $display("=============================================================================");
    end

    if (`ANA_TOP_S2.PMU_SW.CHIP_EN === 1'b0) begin
      $display("=============================================================================");
      $display("===== CHIP 2 is POWERED OFF");    
      if (sdf_sim_en === 1'b1) begin                              
        $display("===== CHIP 2 is DISABLED for Timing Check at time: %t", $time);
        $disable_warnings(`SOC_TOP_S2);
      end 
      $display("=============================================================================");
    end else if (`ANA_TOP_S2.PMU_SW.CHIP_EN === 1'b1) begin
      $display("=============================================================================");
      $display("===== CHIP 2 is POWERED ON");
      if (sdf_sim_en === 1'b1) begin
        $display("===== CHIP 2 is ENABLED for Timing Check at time: %t", $time);
        $enable_warnings(`SOC_TOP);
      end 
      $display("=============================================================================");
    end
  end
end
`endif

// Disable timing check
always @(dut_vif.mult_chip_en or dut_vif.swap_sdf_en) 
begin
  #5; 
  if (dut_vif.mult_chip_en === 1'b0) begin
     $display("=============================================================================");
     $display("===== Multiple chips is disabled");
     if (sdf_sim_en === 1'b1) begin
       $disable_warnings(`SOC_TOP_S1);
       $disable_warnings(`SOC_TOP_S2);
       $display("===== CHIP 0 is ENABLED for Timing Check");
       $display("===== CHIP 1/2 are DISABLED for Timing Check at time: %t", $time);
     end   
     $display("=============================================================================");
  end
  else begin
    if (dut_vif.swap_sdf_en === 1'b1) begin 
      $display("=============================================================================");
      $display("===== Multiple chips is disabled");
      if (sdf_sim_en === 1'b1) begin
        $disable_warnings(`SOC_TOP_S1);
        $enable_warnings(`SOC_TOP_S2); 
        $display("===== CHIP 0/1 are ENABLED for Timing Check");
        $display("===== CHIP 2 is DISABLED for Timing Check  at time: %t", $time);
      end 
      $display("=============================================================================");
    end else begin
      $display("=============================================================================");
      $display("===== Multiple chips is disabled");
      if (sdf_sim_en === 1'b1) begin
        $enable_warnings(`SOC_TOP_S1);
        $disable_warnings(`SOC_TOP_S2);
        $display("===== CHIP 1 is DISABLED for Timing Check");
        $display("===== CHIP 0/2 are ENABLED for Timing Check  at time: %t", $time);
      end
      $display("=============================================================================");
    end
  end
end
