//========================================================================================================  
// -------------------------------------------------------------------------------------------------------  
//  Nanochap Electronics Copyright (C) 2014. ALL RIGHTS RESERVED.  
// -------------------------------------------------------------------------------------------------------  
// Project name    : ENS2
// File name       : soc_uvm_tb.sv
// Description     : UVM TB and Configurations
// -------------------------------------------------------------------------------------------------------  
// Revision History:  
// -------------------------------------------------------------------------------------------------------  
// Revision       Date(dd-mm-yyyy)     Author                       Description  
// -------------------------------------------------------------------------------------------------------  
//   1.0          24-03-2025          ddang@nanochap.com            Initial version
// -------------------------------------------------------------------------------------------------------  
//========================================================================================================

import nnc_uvm_pkg::*;
`include "nnc_uvm_methodology.svh"

// TB Defines
`define SPI_BLOCK_ENABLE
`define SYS_BLOCK_ENABLE
`define EPROM_BLOCK_ENABLE
`define LEADOFF_BLOCK_ENABLE
`define WAVEGEN_BLOCK_ENABLE
`define FILTER_BLOCK_ENABLE
`define ECG_BLOCK_ENABLE
`define MONITOR_BLOCK_ENABLE
`define ANA_BLOCK_ENABLE
`define PINMUX_BLOCK_ENABLE
`define PYTHON_BLOCK_ENABLE
`define NIRS_PPG_BLOCK_ENABLE

`ifdef SYS_BLOCK_ENABLE
`include "blocks/tb_chip_top_uvm_sys.sv"
`endif

`ifdef SPI_BLOCK_ENABLE
`include "blocks/tb_chip_top_uvm_spi.sv"
`endif

`ifdef EPROM_BLOCK_ENABLE
`include "blocks/tb_chip_top_uvm_eprom.sv"
`endif

`ifdef LEADOFF_BLOCK_ENABLE
`include "blocks/tb_chip_top_uvm_lead_off.sv"
`endif

`ifdef ANA_BLOCK_ENABLE
`include "blocks/tb_chip_top_uvm_ana.sv"
`endif

`ifdef PINMUX_BLOCK_ENABLE
`include "blocks/tb_chip_top_uvm_pinmux.sv"
`endif

`ifdef ECG_BLOCK_ENABLE
`include "blocks/tb_chip_top_uvm_eeg_filter.sv"
`endif

`ifdef WAVEGEN_BLOCK_ENABLE
`include "blocks/tb_chip_top_uvm_wavegen_dev0.sv"
//`include "blocks/tb_chip_top_uvm_wavegen_dev1.sv"
`endif

`ifdef FILTER_BLOCK_ENABLE
`include "blocks/tb_chip_top_uvm_filter.sv"
`endif

`ifdef MONITOR_BLOCK_ENABLE
`include "blocks/tb_chip_top_uvm_monitor.sv"
`endif

`ifdef PYTHON_BLOCK_ENABLE
  //`include "soc_py_tb.sv"
  soc_py_tb py_tb();
`endif

`ifdef NIRS_PPG_BLOCK_ENABLE
`include "blocks/tb_chip_top_uvm_nirs_ppg.sv"
`endif

// ============================
// Define for ENS2 project
// ============================
`define DUT_IF top_env.top_sqr.dut_if

// =================================
// DUT virtual interface declaration
// =================================
dut_interface      dut_vif();

assign dut_vif.sys_clk = `CLK_CTRL_TOP.pclk;

`ifdef POSTSCAN_PG
  assign dut_vif.soc_resetn = `RST_CTRL_TOP.wave_gen_presetn;
  assign dut_vif.soc_resetn_chipA = `RST_CTRL_TOP_S1.wave_gen_presetn;
  assign dut_vif.soc_resetn_chipB = `RST_CTRL_TOP_S2.wave_gen_presetn;
`elsif POSTSCAN
  assign dut_vif.soc_resetn = `RST_CTRL_TOP.wave_gen_presetn;
  assign dut_vif.soc_resetn_chipA = `RST_CTRL_TOP_S1.wave_gen_presetn;
  assign dut_vif.soc_resetn_chipB = `RST_CTRL_TOP_S2.wave_gen_presetn;
`elsif PRESCAN
  assign dut_vif.soc_resetn = `RST_CTRL_TOP.wave_gen_presetn;//por_resetn;
  assign dut_vif.soc_resetn_chipA = `RST_CTRL_TOP_S1.wave_gen_presetn;
  assign dut_vif.soc_resetn_chipB = `RST_CTRL_TOP_S2.wave_gen_presetn;
`else
  assign dut_vif.soc_resetn = `RST_CTRL_TOP.presetn;
  assign dut_vif.soc_resetn_chipA = `RST_CTRL_TOP_S1.presetn;
  assign dut_vif.soc_resetn_chipB = `RST_CTRL_TOP_S2.presetn;
`endif

assign spi_vif.assertion_on = dut_vif.assertion_on;
assign dut_vif.iopad_gpio = `SOC_TB.IOBUF_PAD;

// Connecting from DUT Interface to internal OSC and external OSC
`ifndef FPGA
  `ifndef VERILOG_OSC_MODEL

`ifndef MIX_SIM_EN
    // Internal clock connection
    assign `ANA_TOP.OSC.hfosc_fixed_gnd_en = dut_vif.hfosc_fixed_gnd_en;
    assign `ANA_TOP.OSC.hfosc_jitter = dut_vif.hfosc_jitter;
    assign `ANA_TOP.OSC.hfosc_variation = dut_vif.hfosc_variation;

    assign `ANA_TOP_S1.OSC.hfosc_fixed_gnd_en = dut_vif.hfosc_fixed_gnd_en;
    assign `ANA_TOP_S1.OSC.hfosc_jitter = dut_vif.hfosc_jitter;
    assign `ANA_TOP_S1.OSC.hfosc_variation = dut_vif.hfosc_variation;

    assign `ANA_TOP_S2.OSC.hfosc_fixed_gnd_en = dut_vif.hfosc_fixed_gnd_en;
    assign `ANA_TOP_S2.OSC.hfosc_jitter = dut_vif.hfosc_jitter;
    assign `ANA_TOP_S2.OSC.hfosc_variation = dut_vif.hfosc_variation;
`endif

    // External clock connections
    assign `SOC_TB.u_ext_hfosc.ext_hfosc_fixed_gnd_en = dut_vif.ext_hfosc_fixed_gnd_en;
    assign `SOC_TB.u_ext_hfosc.ext_hfosc_jitter = dut_vif.hfosc_jitter;
    assign `SOC_TB.u_ext_hfosc.ext_hfosc_variation = dut_vif.hfosc_variation;
    assign `SOC_TB.u_ext_hfosc.ext_hfosc_sel = 2'b00; // fixed it to 32Mhz only;
  `endif
`endif

assign `EPROM_BIST_MASTER_VIP.tPGM_RC = dut_vif.bistm_tPGM_RC;
assign `EPROM_BIST_MASTER_VIP.tPGM = dut_vif.bistm_tPGM;

`ifndef MIX_SIM_EN
assign `ANA_TOP.loff_short_ch1.lead_off_en = dut_vif.lead_off_en;
assign `ANA_TOP.loff_short_ch1.short_en = dut_vif.short_en;
assign `ANA_TOP.loff_short_ch1.register_val = dut_vif.register_val_ch1;
assign `ANA_TOP.loff_short_ch1.a2d_comp_delay = dut_vif.a2d_comp_delay_ch1;
assign `ANA_TOP.loff_short_ch1.comp_stimu_pol_high = dut_vif.anac_stim_CH1_pol;
assign `ANA_TOP.loff_short_ch1.comp_pol_high = dut_vif.lead_off_ch0_comp_low_active;
assign `ANA_TOP.loff_short_ch1.pulse_after_source_delay = dut_vif.pulse_after_source_delay;
assign `ANA_TOP.loff_short_ch1.pulse_after_source = dut_vif.pulse_after_source;

assign `ANA_TOP.loff_short_ch2.lead_off_en = dut_vif.lead_off_en;
assign `ANA_TOP.loff_short_ch2.short_en = dut_vif.short_en;
assign `ANA_TOP.loff_short_ch2.register_val = dut_vif.register_val_ch2;
assign `ANA_TOP.loff_short_ch2.a2d_comp_delay = dut_vif.a2d_comp_delay_ch2;
assign `ANA_TOP.loff_short_ch2.comp_stimu_pol_high = dut_vif.anac_stim_CH2_pol;
assign `ANA_TOP.loff_short_ch2.comp_pol_high = dut_vif.lead_off_ch1_comp_low_active;
assign `ANA_TOP.loff_short_ch2.pulse_after_source_delay = dut_vif.pulse_after_source_delay;
assign `ANA_TOP.loff_short_ch2.pulse_after_source = dut_vif.pulse_after_source;

// LVD Model
assign `ANA_TOP.lvd_circuit.vbat_level = dut_vif.vbat_level;

// TSC Monitoring Model
assign `ANA_TOP.tsc_monitoring_ch1.sensor_temperature = dut_vif.sensor_temperature;
assign `ANA_TOP.tsc_monitoring_ch1.a2d_comp_delay = dut_vif.a2d_comp_delay_ch1;
assign `ANA_TOP.tsc_monitoring_ch1.comp_low_active_en = dut_vif.tsc_comp_low_active_en;

// NIRS Model
assign `ANA_TOP.nirs_model.nirs_irefcoarse_length      = dut_vif.nirs_irefcoarse_length;      // 32-bit (unit - ns)
assign `ANA_TOP.nirs_model.nirs_irefcoarse_iref_delay  = dut_vif.nirs_irefcoarse_iref_delay;  // 32-bit (unit - ns)
assign `ANA_TOP.nirs_model.nirs_ireffine_length        = dut_vif.nirs_ireffine_length;        // 32-bit (unit - ns)

`endif

// ***************************************** short/leadoff debug response counter register checker ******************************************
assign dut_vif.dut_short_leadoff_counter_cnt_debug = {spi_vif.REG_BACKDOOR[0][8'h84],spi_vif.REG_BACKDOOR[0][8'h83],spi_vif.REG_BACKDOOR[0][8'h82],spi_vif.REG_BACKDOOR[0][8'h81]};

always_ff @(posedge dut_vif.sys_clk or negedge dut_vif.anac_presetn)begin 
  if(!dut_vif.anac_presetn)begin 
    dut_vif.short_ch0_counter_cnt_debug = 'h0;
    dut_vif.short_ch1_counter_cnt_debug = 'h0;
    dut_vif.leadoff_ch0_counter_cnt_debug = 'h0;
    dut_vif.leadoff_ch1_counter_cnt_debug = 'h0;
  end 
  else begin 
    if(dut_vif.expected_anac_short_ch1_timer_th_cnt_flag === 1) dut_vif.short_ch0_counter_cnt_debug = dut_vif.expected_short_ch1_resp_th_cnt;
    if(dut_vif.expected_anac_short_ch2_timer_th_cnt_flag === 1) dut_vif.short_ch1_counter_cnt_debug = dut_vif.expected_short_ch2_resp_th_cnt;
    if(dut_vif.expected_leadoff_ch0_timer_th_cnt_flag === 1) dut_vif.leadoff_ch0_counter_cnt_debug = dut_vif.expected_leadoff_ch0_resp_th_cnt;
    if(dut_vif.expected_leadoff_ch1_timer_th_cnt_flag === 1) dut_vif.leadoff_ch1_counter_cnt_debug = dut_vif.expected_leadoff_ch1_resp_th_cnt;
  end
end

assign dut_vif.exp_short_leadoff_counter_cnt_debug =   (dut_vif.short_leadoff_counter_cnt_debug_sel == 2'b00) ? dut_vif.short_ch0_counter_cnt_debug
                                                     : (dut_vif.short_leadoff_counter_cnt_debug_sel == 2'b01) ? dut_vif.short_ch1_counter_cnt_debug
                                                     : (dut_vif.short_leadoff_counter_cnt_debug_sel == 2'b10) ? dut_vif.leadoff_ch0_counter_cnt_debug
                                                     : (dut_vif.short_leadoff_counter_cnt_debug_sel == 2'b11) ? dut_vif.leadoff_ch1_counter_cnt_debug
                                                     : 'hz;

always_ff @(dut_vif.dut_short_leadoff_counter_cnt_debug)begin
  if(dut_vif.short_leadoff_debug_counter_check_en === 1)begin
    if(dut_vif.dut_short_leadoff_counter_cnt_debug !== dut_vif.exp_short_leadoff_counter_cnt_debug)begin
      `nnc_error("SOC_TEST",$sformatf("MISMATCH in short/leadoff DEBUG response counter register, dut_val = %0d, exp_val=%00d",dut_vif.dut_short_leadoff_counter_cnt_debug,dut_vif.exp_short_leadoff_counter_cnt_debug));
    end
    else begin
      `nnc_info("SOC_TEST",$sformatf("MATCH in short/leadoff DEBUG response counter register, dut_val = %0d, exp_val=%00d",dut_vif.dut_short_leadoff_counter_cnt_debug,dut_vif.exp_short_leadoff_counter_cnt_debug),NNC_LOW);
    end
  end
end

// ***************************************** short/leadoff debug response counter register checker ******************************************


/*
flash_interface         flash_vif();
flash_bist_interface    flash_bist_if();
analog_interface        ana_vif();
register_interface      reg_vif();
*/
// ============================
// Power Pins define
// ============================
/*
`define VBAT `ANA_TOP.VBAT3P3
//`define VSWLDO `ANA_TOP.PMU_SW.ext_sw_power
//`define VPLDO `ANA_TOP.PMU_ALW_ON.ext_ao_power
`define VSWLDO `ANA_TOP.VSWLDO1P8
`define VPLDO `ANA_TOP.VLPLDO1P8
`define VPLDO_EN5V `ANA_TOP.LPLDO_EN5V
*/

// added by supriya
//drv 0
assign dut_vif.pulla[0] = `ANA_WRAPPER_TOP.i_pullda_driver_a[0]; //positive side dac0
assign dut_vif.pullb[0] = `ANA_WRAPPER_TOP.i_pulldb_driver_a[0]; //negative side dac0
assign dut_vif.sourcea[0] = `ANA_WRAPPER_TOP.i_sourcea_driver_a[0];//positive side dac0
assign dut_vif.sourceb[0] = `ANA_WRAPPER_TOP.i_sourceb_driver_a[0];//negative side dac0
//drv 1
assign dut_vif.pulla[1] = `ANA_WRAPPER_TOP.i_pullda_driver_a[1];//positive side dac1
assign dut_vif.pullb[1] = `ANA_WRAPPER_TOP.i_pulldb_driver_a[1];//negative side dac1
assign dut_vif.sourcea[1] = `ANA_WRAPPER_TOP.i_sourcea_driver_a[1];//positive side dac1
assign dut_vif.sourceb[1] = `ANA_WRAPPER_TOP.i_sourceb_driver_a[1];//negative side dac1

// leadoff removed //assign dut_vif.dut_leadoff_ch0_intr_sts = `LEADOFF_TOP_0.lead_off_result;  
// leadoff removed //assign dut_vif.dut_leadoff_ch1_intr_sts = `LEADOFF_TOP_1.lead_off_result;
// leadoff removed //
// leadoff removed //assign dut_vif.dut_ana_stimu_ch1_intr_sts = `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.o_ana_stimu_chx_intr_sts;  
// leadoff removed //assign dut_vif.dut_ana_stimu_ch2_intr_sts = `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.o_ana_stimu_chx_intr_sts;
// leadoff removed //
// leadoff removed //assign dut_vif.ana_stimu_ch1_intr_sts_clr      = `ANAC_TOP.spi_anac.ana_comp_ch_intr_sts[0];  //14/07/2025 added by supriya
// leadoff removed //assign dut_vif.ana_stimu_ch2_intr_sts_clr      = `ANAC_TOP.spi_anac.ana_comp_ch_intr_sts[1];  //14/07/2025 added by supriya

//`ifdef BEHAVIORAL
  assign dut_vif.wg_enable[0]      = `WG_DRIVER_TOP.drive_en[0]; //`WG_DRIVER_TOP.wg_driver_top_inst.comp_short_detection[0].arb_wave_gen_inst.enable;  //through register configuration passed to sync modules so considered from this path instead from spi reg configuration
  assign dut_vif.wg_enable[1]      = `WG_DRIVER_TOP.drive_en[1]; //`WG_DRIVER_TOP.wg_driver_top_inst.comp_short_detection[1].arb_wave_gen_inst.enable;
//`else 
//  assign dut_vif.wg_enable[0]      = `WG_DRIVER_TOP.wg_driver_top_inst.comp_short_detection_0__arb_wave_gen_inst.enable;
//  assign dut_vif.wg_enable[1]      = `WG_DRIVER_TOP.wg_driver_top_inst.comp_short_detection_1__arb_wave_gen_inst.enable;
//`endif

//assign dut_vif.wavegen_en[1:0]                 = `DIG_TOP.drive_en[1:0]; //14/07/2025 added by supriya , Pending to get from testcase
always_ff @(posedge dut_vif.anac_pclk or negedge dut_vif.anac_presetn)begin
  if(!dut_vif.anac_presetn)begin
     //dut_vif.anac_short_ch1_wg_enable = 1'b0;
     dut_vif.anac_short_ch1_wg_enable_d1 <= 1'b0;
     dut_vif.anac_short_ch1_wg_enable_d2 <= 1'b0;
  end
  else /*if(dut_vif.wg_enable[0])*/ begin
    dut_vif.anac_short_ch1_wg_enable_d1 <= dut_vif.wg_enable[0];
    dut_vif.anac_short_ch1_wg_enable_d2 <= dut_vif.anac_short_ch1_wg_enable_d1;

  end   
end
assign dut_vif.anac_short_ch1_wg_enable = (dut_vif.anac_short_ch1_wg_enable_d2 && dut_vif.anac_short_ch1_wg_enable_d1 && dut_vif.wg_enable[0]);

always_ff @(posedge dut_vif.anac_pclk or negedge dut_vif.anac_presetn)begin
  if(!dut_vif.anac_presetn)begin
     //dut_vif.anac_short_ch1_wg_enable = 1'b0;
     dut_vif.anac_short_ch2_wg_enable_d1 <= 1'b0;
     dut_vif.anac_short_ch2_wg_enable_d2 <= 1'b0;
  end
  else /*if*(dut_vif.wg_enable[1])*/ begin
    dut_vif.anac_short_ch2_wg_enable_d1 <= dut_vif.wg_enable[1];
    dut_vif.anac_short_ch2_wg_enable_d2 <= dut_vif.anac_short_ch2_wg_enable_d1;

  end   
end
assign dut_vif.anac_short_ch2_wg_enable = (dut_vif.anac_short_ch2_wg_enable_d2 && dut_vif.anac_short_ch2_wg_enable_d1 && dut_vif.wg_enable[1]);

//assign dut_vif.lead_off_wg_enable[0] = {soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_wg_driver.drive_en[0]}; //check with shreeyal, pending to remove
//assign dut_vif.lead_off_wg_enable[1] = {soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_wg_driver.drive_en[1]};

always_ff @(posedge dut_vif.leadoff_pclk or negedge dut_vif.leadoff_presetn)begin
  if(!dut_vif.leadoff_presetn)begin
     dut_vif.lead_off_ch0_wg_enable_d1 <= 1'b0;
     dut_vif.lead_off_ch0_wg_enable_d2 <= 1'b0;
  end
  else /*if(dut_vif.wg_enable[0])*/ begin
    dut_vif.lead_off_ch0_wg_enable_d1 <= dut_vif.wg_enable[0];
    dut_vif.lead_off_ch0_wg_enable_d2 <= dut_vif.lead_off_ch0_wg_enable_d1;

  end   
end
assign dut_vif.lead_off_ch0_wg_enable = dut_vif.lead_off_ch0_wg_enable_d2;  //&& dut_vif.lead_off_ch0_wg_enable_d1 && dut_vif.wg_enable[0]);

always_ff @(posedge dut_vif.leadoff_pclk or negedge dut_vif.leadoff_presetn)begin
  if(!dut_vif.leadoff_presetn)begin
     dut_vif.lead_off_ch1_wg_enable_d1 <= 1'b0;
     dut_vif.lead_off_ch1_wg_enable_d2 <= 1'b0;
  end
  else begin
    dut_vif.lead_off_ch1_wg_enable_d1 <= dut_vif.wg_enable[1];
    dut_vif.lead_off_ch1_wg_enable_d2 <= dut_vif.lead_off_ch1_wg_enable_d1;

  end   
end
assign dut_vif.lead_off_ch1_wg_enable = dut_vif.lead_off_ch1_wg_enable_d2; //&& dut_vif.lead_off_ch1_wg_enable_d1 && dut_vif.wg_enable[1]);


// leadoff removed //assign dut_vif.expected_short_ch1_resp_cnt_en   = dut_vif.lead_off_detect_by_short_circuit_en ? dut_vif.anac_stim_CH1_pol ? ~`ANA_TOP.A2D_COMP_OUT_CH1 : `ANA_TOP.A2D_COMP_OUT_CH1 : dut_vif.anac_stim_CH1_pol ? ~`ANA_TOP.A2D_COMP_OUT_STIMU0_1 : `ANA_TOP.A2D_COMP_OUT_STIMU0_1 ; //`DUT_IF.anac_stim_CH2_intr_en, `DUT_IF.anac_stim_CH1_intr_en, `DUT_IF.anac_stim_CH2_pol, `DUT_IF.anac_stim_CH1_pol
// leadoff removed //assign dut_vif.expected_short_ch2_resp_cnt_en   = dut_vif.lead_off_detect_by_short_circuit_en ? dut_vif.anac_stim_CH2_pol ? ~`ANA_TOP.A2D_COMP_OUT_CH2 : `ANA_TOP.A2D_COMP_OUT_CH2 : dut_vif.anac_stim_CH2_pol ? ~`ANA_TOP.A2D_COMP_OUT_STIMU2_3 : `ANA_TOP.A2D_COMP_OUT_STIMU2_3;

always_ff @(posedge dut_vif.anac_pclk or negedge dut_vif.anac_presetn)begin
  if(!dut_vif.anac_presetn)begin
     dut_vif.expected_short_ch1_resp_cnt_en_d1 <=1'b0;
     dut_vif.expected_short_ch1_resp_cnt_en_d2 <=1'b0;
  end
  else begin
     dut_vif.expected_short_ch1_resp_cnt_en_d1 <= dut_vif.expected_short_ch1_resp_cnt_en;
     dut_vif.expected_short_ch1_resp_cnt_en_d2 <= dut_vif.expected_short_ch1_resp_cnt_en_d1;     
  end
end
assign dut_vif.expected_anac_ch1_a2d_comp = dut_vif.expected_short_ch1_resp_cnt_en_d2; 

always_ff @(posedge dut_vif.anac_pclk or negedge dut_vif.anac_presetn)begin
  if(!dut_vif.anac_presetn)begin
     dut_vif.expected_short_ch2_resp_cnt_en_d1 <=1'b0;
     dut_vif.expected_short_ch2_resp_cnt_en_d2 <=1'b0;
  end
  else begin
     dut_vif.expected_short_ch2_resp_cnt_en_d1 <= dut_vif.expected_short_ch2_resp_cnt_en;
     dut_vif.expected_short_ch2_resp_cnt_en_d2 <= dut_vif.expected_short_ch2_resp_cnt_en_d1;     
  end
end
assign dut_vif.expected_anac_ch2_a2d_comp = dut_vif.expected_short_ch2_resp_cnt_en_d2;

always_ff@(posedge dut_vif.leadoff_pclk or negedge dut_vif.leadoff_presetn)begin
  if(!dut_vif.leadoff_presetn)begin
    dut_vif.A2D_COMP_OUT_CH1_d1 <= 1'b0;
    dut_vif.A2D_COMP_OUT_STIMU0_1_d1 <= 1'b0;
    dut_vif.A2D_COMP_OUT_CH1_d2 <= 1'b0;
    dut_vif.A2D_COMP_OUT_STIMU0_1_d2 <= 1'b0;

  end
  else begin
    dut_vif.A2D_COMP_OUT_CH1_d1 <= `ANA_TOP.A2D_COMP_OUT_CH1; //soc_top_tb.u_Nanochap_ENS2.u_top_ana_wrapper.A2D_COMP_OUT_CH1_tmp
    dut_vif.A2D_COMP_OUT_STIMU0_1_d1 <= `ANA_TOP.A2D_COMP_OUT_STIMU0_1;
    dut_vif.A2D_COMP_OUT_CH1_d2 <= dut_vif.A2D_COMP_OUT_CH1_d1;
    dut_vif.A2D_COMP_OUT_STIMU0_1_d2 <= dut_vif.A2D_COMP_OUT_STIMU0_1_d1; 
  end 
end

always_ff@(posedge dut_vif.leadoff_pclk or negedge dut_vif.leadoff_presetn)begin
  if(!dut_vif.leadoff_presetn)begin
    dut_vif.A2D_COMP_OUT_CH2_d1 <= 1'b0;
    dut_vif.A2D_COMP_OUT_STIMU2_3_d1 <= 1'b0;
    dut_vif.A2D_COMP_OUT_CH2_d2 <= 1'b0;
    dut_vif.A2D_COMP_OUT_STIMU2_3_d2 <= 1'b0;
  end
  else begin
    dut_vif.A2D_COMP_OUT_CH2_d1 <= `ANA_TOP.A2D_COMP_OUT_CH2;
    dut_vif.A2D_COMP_OUT_STIMU2_3_d1 <= `ANA_TOP.A2D_COMP_OUT_STIMU2_3;
   dut_vif.A2D_COMP_OUT_CH2_d2 <= dut_vif.A2D_COMP_OUT_CH2_d1;
    dut_vif.A2D_COMP_OUT_STIMU2_3_d2 <= dut_vif.A2D_COMP_OUT_STIMU2_3_d1; 
  end 
end  
           
assign dut_vif.A2D_COMP_OUT_CH1                         = dut_vif.short_detect_by_lead_off_en ? dut_vif.A2D_COMP_OUT_STIMU0_1_d2 : dut_vif.A2D_COMP_OUT_CH1_d2; //dut_vif.A2D_COMP_OUT_CH1_d1: dut_vif.A2D_COMP_OUT_STIMU0_1_d1 ;
assign dut_vif.A2D_COMP_OUT_CH2                         = dut_vif.short_detect_by_lead_off_en ? dut_vif.A2D_COMP_OUT_STIMU2_3_d2 : dut_vif.A2D_COMP_OUT_CH2_d2;//dut_vif.A2D_COMP_OUT_CH2_d1 : dut_vif.A2D_COMP_OUT_STIMU2_3_d1;
assign dut_vif.A2D_COMP_OUT_CH1_tmp                     = dut_vif.lead_off_ch0_comp_low_active ? ~dut_vif.A2D_COMP_OUT_CH1 : dut_vif.A2D_COMP_OUT_CH1;
assign dut_vif.A2D_COMP_OUT_CH2_tmp                     = dut_vif.lead_off_ch1_comp_low_active ? ~dut_vif.A2D_COMP_OUT_CH2 : dut_vif.A2D_COMP_OUT_CH2;
assign dut_vif.expected_ch0_leadoff_en                  = dut_vif.lead_off_comp_reverse ? dut_vif.A2D_COMP_OUT_CH2_tmp : dut_vif.A2D_COMP_OUT_CH1_tmp; //comp_reverse no more user configuration set to 0 in dut interface
assign dut_vif.expected_ch1_leadoff_en                  = dut_vif.lead_off_comp_reverse ? dut_vif.A2D_COMP_OUT_CH1_tmp : dut_vif.A2D_COMP_OUT_CH2_tmp; //comp_reverse no more user configuration set to 0 in dut interface
// leadoff removed //assign dut_vif.dut_short_ch1_timer_th_cnt	        =
// leadoff removed //`ifndef BEHAVIORAL
// leadoff removed //32'h0;
// leadoff removed ////{`ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.timer_th_cnt_reg_0_.timer_th_cnt_0_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.timer_th_cnt_reg_1_.timer_th_cnt_1_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.timer_th_cnt_reg_2_.timer_th_cnt_2_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.timer_th_cnt_reg_3_.timer_th_cnt_3_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.timer_th_cnt_reg_4_.test_so8,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.timer_th_cnt_reg_5_.timer_th_cnt_5_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.timer_th_cnt_reg_6_.timer_th_cnt_6_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.timer_th_cnt_reg_7_.timer_th_cnt_7_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.timer_th_cnt_reg_8_.timer_th_cnt_8_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.timer_th_cnt_reg_9_.timer_th_cnt_9_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.timer_th_cnt_reg_10_.timer_th_cnt_10_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.timer_th_cnt_reg_11_.timer_th_cnt_11_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.timer_th_cnt_reg_12_.timer_th_cnt_12_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.timer_th_cnt_reg_13_.timer_th_cnt_13_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.timer_th_cnt_reg_14_.timer_th_cnt_14_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.timer_th_cnt_reg_15_.timer_th_cnt_15_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.timer_th_cnt_reg_16_.test_so9,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.timer_th_cnt_reg_17_.test_so3,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.timer_th_cnt_reg_18_.timer_th_cnt_18_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.timer_th_cnt_reg_19_.timer_th_cnt_19_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.timer_th_cnt_reg_20_.timer_th_cnt_20_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.timer_th_cnt_reg_21_.timer_th_cnt_21_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.timer_th_cnt_reg_22_.timer_th_cnt_22_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.timer_th_cnt_reg_23_.timer_th_cnt_23_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.timer_th_cnt_reg_24_.timer_th_cnt_24_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.timer_th_cnt_reg_25_.timer_th_cnt_25_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.timer_th_cnt_reg_26_.timer_th_cnt_26_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.timer_th_cnt_reg_27_.timer_th_cnt_27_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.timer_th_cnt_reg_28_.timer_th_cnt_28_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.timer_th_cnt_reg_29_.timer_th_cnt_29_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.timer_th_cnt_reg_30_.timer_th_cnt_30_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.timer_th_cnt_reg_31_.timer_th_cnt_31_
// leadoff removed ////}
// leadoff removed //`else
// leadoff removed // `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.timer_th_cnt;
// leadoff removed //`endif
// leadoff removed //
// leadoff removed //assign dut_vif.dut_short_ch2_timer_th_cnt	        = 
// leadoff removed //`ifndef BEHAVIORAL
// leadoff removed //32'h0;
// leadoff removed ////{`ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.timer_th_cnt_reg_0_.timer_th_cnt_0_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.timer_th_cnt_reg_1_.timer_th_cnt_1_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.timer_th_cnt_reg_2_.timer_th_cnt_2_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.timer_th_cnt_reg_3_.timer_th_cnt_3_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.timer_th_cnt_reg_4_.timer_th_cnt_4_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.timer_th_cnt_reg_5_.timer_th_cnt_5_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.timer_th_cnt_reg_6_.timer_th_cnt_6_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.timer_th_cnt_reg_7_.timer_th_cnt_7_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.timer_th_cnt_reg_8_.timer_th_cnt_8_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.timer_th_cnt_reg_9_.timer_th_cnt_9_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.timer_th_cnt_reg_10_.test_so6,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.timer_th_cnt_reg_11_.timer_th_cnt_11_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.timer_th_cnt_reg_12_.timer_th_cnt_12_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.timer_th_cnt_reg_13_.timer_th_cnt_13_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.timer_th_cnt_reg_14_.timer_th_cnt_14_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.timer_th_cnt_reg_15_.timer_th_cnt_15_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.timer_th_cnt_reg_16_.timer_th_cnt_16_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.timer_th_cnt_reg_17_.timer_th_cnt_17_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.timer_th_cnt_reg_18_.timer_th_cnt_18_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.timer_th_cnt_reg_19_.timer_th_cnt_19_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.timer_th_cnt_reg_20_.timer_th_cnt_20_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.timer_th_cnt_reg_21_.test_so1,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.timer_th_cnt_reg_22_.timer_th_cnt_22_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.timer_th_cnt_reg_23_.timer_th_cnt_23_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.timer_th_cnt_reg_24_.timer_th_cnt_24_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.timer_th_cnt_reg_25_.timer_th_cnt_25_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.timer_th_cnt_reg_26_.timer_th_cnt_26_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.timer_th_cnt_reg_27_.timer_th_cnt_27_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.timer_th_cnt_reg_28_.test_so5,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.timer_th_cnt_reg_29_.timer_th_cnt_29_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.timer_th_cnt_reg_30_.timer_th_cnt_30_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.timer_th_cnt_reg_31_.timer_th_cnt_31_
// leadoff removed ////}
// leadoff removed //`else
// leadoff removed //`ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.timer_th_cnt;
// leadoff removed //`endif
// leadoff removed //
// leadoff removed //assign dut_vif.dut_short_ch1_counter_th_cnt             = 
// leadoff removed //`ifndef BEHAVIORAL
// leadoff removed //32'h0;
// leadoff removed ////{`ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.counter_th_cnt_reg_0_.counter_th_cnt_0_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.counter_th_cnt_reg_1_.counter_th_cnt_1_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.counter_th_cnt_reg_2_.counter_th_cnt_2_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.counter_th_cnt_reg_3_.counter_th_cnt_3_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.counter_th_cnt_reg_4_.counter_th_cnt_4_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.counter_th_cnt_reg_5_.counter_th_cnt_5_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.counter_th_cnt_reg_6_.counter_th_cnt_6_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.counter_th_cnt_reg_7_.counter_th_cnt_7_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.counter_th_cnt_reg_8_.counter_th_cnt_8_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.counter_th_cnt_reg_9_.counter_th_cnt_9_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.counter_th_cnt_reg_10_.counter_th_cnt_10_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.counter_th_cnt_reg_11_.counter_th_cnt_11_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.counter_th_cnt_reg_12_.test_so2,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.counter_th_cnt_reg_13_.counter_th_cnt_13_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.counter_th_cnt_reg_14_.counter_th_cnt_14_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.counter_th_cnt_reg_15_.counter_th_cnt_15_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.counter_th_cnt_reg_16_.test_so4,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.counter_th_cnt_reg_17_.counter_th_cnt_17_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.counter_th_cnt_reg_18_.counter_th_cnt_18_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.counter_th_cnt_reg_19_.counter_th_cnt_19_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.counter_th_cnt_reg_20_.counter_th_cnt_20_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.counter_th_cnt_reg_21_.counter_th_cnt_21_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.counter_th_cnt_reg_22_.test_so10,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.counter_th_cnt_reg_23_.counter_th_cnt_23_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.counter_th_cnt_reg_24_.counter_th_cnt_24_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.counter_th_cnt_reg_25_.counter_th_cnt_25_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.counter_th_cnt_reg_26_.counter_th_cnt_26_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.counter_th_cnt_reg_27_.counter_th_cnt_27_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.counter_th_cnt_reg_28_.counter_th_cnt_28_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.counter_th_cnt_reg_29_.counter_th_cnt_29_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.counter_th_cnt_reg_30_.counter_th_cnt_30_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.counter_th_cnt_reg_31_.counter_th_cnt_31_
// leadoff removed ////}
// leadoff removed //`else
// leadoff removed //`ANAC_TOP.comp_short_detection[0].u_anac_short_dtct_ch.counter_th_cnt;
// leadoff removed //`endif
// leadoff removed //
// leadoff removed //assign dut_vif.dut_short_ch2_counter_th_cnt             = 
// leadoff removed //`ifndef BEHAVIORAL
// leadoff removed // 32'h0;
// leadoff removed ////{`ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.counter_th_cnt_reg_0_.counter_th_cnt_0_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.counter_th_cnt_reg_1_.counter_th_cnt_1_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.counter_th_cnt_reg_2_.counter_th_cnt_2_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.counter_th_cnt_reg_3_.counter_th_cnt_3_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.counter_th_cnt_reg_4_.counter_th_cnt_4_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.counter_th_cnt_reg_5_.test_so4,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.counter_th_cnt_reg_6_.counter_th_cnt_6_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.counter_th_cnt_reg_7_.counter_th_cnt_7_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.counter_th_cnt_reg_8_.counter_th_cnt_8_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.counter_th_cnt_reg_9_.counter_th_cnt_9_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.counter_th_cnt_reg_10_.counter_th_cnt_10_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.counter_th_cnt_reg_11_.counter_th_cnt_11_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.counter_th_cnt_reg_12_.counter_th_cnt_12_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.counter_th_cnt_reg_13_.counter_th_cnt_13_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.counter_th_cnt_reg_14_.test_so7,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.counter_th_cnt_reg_15_.counter_th_cnt_15_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.counter_th_cnt_reg_16_.counter_th_cnt_16_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.counter_th_cnt_reg_17_.counter_th_cnt_17_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.counter_th_cnt_reg_18_.counter_th_cnt_18_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.counter_th_cnt_reg_19_.counter_th_cnt_19_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.counter_th_cnt_reg_20_.counter_th_cnt_20_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.counter_th_cnt_reg_21_.counter_th_cnt_21_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.counter_th_cnt_reg_22_.counter_th_cnt_22_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.counter_th_cnt_reg_23_.counter_th_cnt_23_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.counter_th_cnt_reg_24_.counter_th_cnt_24_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.counter_th_cnt_reg_25_.counter_th_cnt_25_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.counter_th_cnt_reg_26_.counter_th_cnt_26_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.counter_th_cnt_reg_27_.counter_th_cnt_27_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.counter_th_cnt_reg_28_.counter_th_cnt_28_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.counter_th_cnt_reg_29_.counter_th_cnt_29_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.counter_th_cnt_reg_30_.counter_th_cnt_30_,
// leadoff removed //// `ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.counter_th_cnt_reg_31_.counter_th_cnt_31_
// leadoff removed ////}
// leadoff removed //`else
// leadoff removed //`ANAC_TOP.comp_short_detection[1].u_anac_short_dtct_ch.counter_th_cnt;
// leadoff removed //`endif
// leadoff removed //
// leadoff removed //assign dut_vif.dut_timer_cnt_cnt_dac0			= 
// leadoff removed //`ifndef BEHAVIORAL
// leadoff removed //32'h0;
// leadoff removed ////{`LEADOFF_TOP.timer_cnt_cnt_dac0_reg_0_.timer_cnt_cnt_dac0_0_,
// leadoff removed ////`LEADOFF_TOP.timer_cnt_cnt_dac0_reg_1_.timer_cnt_cnt_dac0_1_,
// leadoff removed ////`LEADOFF_TOP.timer_cnt_cnt_dac0_reg_2_.timer_cnt_cnt_dac0_2_,
// leadoff removed ////`LEADOFF_TOP.timer_cnt_cnt_dac0_reg_3_.test_so5,
// leadoff removed ////`LEADOFF_TOP.timer_cnt_cnt_dac0_reg_4_.test_so6,
// leadoff removed ////`LEADOFF_TOP.timer_cnt_cnt_dac0_reg_5_.timer_cnt_cnt_dac0_5_,
// leadoff removed ////`LEADOFF_TOP.timer_cnt_cnt_dac0_reg_6_.timer_cnt_cnt_dac0_6_,
// leadoff removed ////`LEADOFF_TOP.timer_cnt_cnt_dac0_reg_7_.timer_cnt_cnt_dac0_7_,
// leadoff removed ////`LEADOFF_TOP.timer_cnt_cnt_dac0_reg_8_.timer_cnt_cnt_dac0_8_,
// leadoff removed ////`LEADOFF_TOP.timer_cnt_cnt_dac0_reg_9_.timer_cnt_cnt_dac0_9_,
// leadoff removed ////`LEADOFF_TOP.timer_cnt_cnt_dac0_reg_10_.test_so22,
// leadoff removed ////`LEADOFF_TOP.timer_cnt_cnt_dac0_reg_11_.timer_cnt_cnt_dac0_11_,
// leadoff removed ////`LEADOFF_TOP.timer_cnt_cnt_dac0_reg_12_.timer_cnt_cnt_dac0_12_,
// leadoff removed ////`LEADOFF_TOP.timer_cnt_cnt_dac0_reg_13_.test_so21,
// leadoff removed ////`LEADOFF_TOP.timer_cnt_cnt_dac0_reg_14_.timer_cnt_cnt_dac0_14_,
// leadoff removed ////`LEADOFF_TOP.timer_cnt_cnt_dac0_reg_15_.timer_cnt_cnt_dac0_15_,
// leadoff removed ////`LEADOFF_TOP.timer_cnt_cnt_dac0_reg_16_.test_so30,
// leadoff removed ////`LEADOFF_TOP.timer_cnt_cnt_dac0_reg_17_.test_so18,
// leadoff removed ////`LEADOFF_TOP.timer_cnt_cnt_dac0_reg_18_.timer_cnt_cnt_dac0_18_,
// leadoff removed ////`LEADOFF_TOP.timer_cnt_cnt_dac0_reg_19_.timer_cnt_cnt_dac0_19_,
// leadoff removed ////`LEADOFF_TOP.timer_cnt_cnt_dac0_reg_20_.test_so19,
// leadoff removed ////`LEADOFF_TOP.timer_cnt_cnt_dac0_reg_21_.timer_cnt_cnt_dac0_21_,
// leadoff removed ////`LEADOFF_TOP.timer_cnt_cnt_dac0_reg_22_.timer_cnt_cnt_dac0_22_,
// leadoff removed ////`LEADOFF_TOP.timer_cnt_cnt_dac0_reg_23_.timer_cnt_cnt_dac0_23_,
// leadoff removed ////`LEADOFF_TOP.timer_cnt_cnt_dac0_reg_24_.timer_cnt_cnt_dac0_24_,
// leadoff removed ////`LEADOFF_TOP.timer_cnt_cnt_dac0_reg_25_.timer_cnt_cnt_dac0_25_,
// leadoff removed ////`LEADOFF_TOP.timer_cnt_cnt_dac0_reg_26_.timer_cnt_cnt_dac0_26_,
// leadoff removed ////`LEADOFF_TOP.timer_cnt_cnt_dac0_reg_27_.timer_cnt_cnt_dac0_27_,
// leadoff removed ////`LEADOFF_TOP.timer_cnt_cnt_dac0_reg_28_.timer_cnt_cnt_dac0_28_,
// leadoff removed ////`LEADOFF_TOP.timer_cnt_cnt_dac0_reg_29_.test_so11,
// leadoff removed ////`LEADOFF_TOP.timer_cnt_cnt_dac0_reg_30_.test_so4,
// leadoff removed ////`LEADOFF_TOP.timer_cnt_cnt_dac0_reg_31_.timer_cnt_cnt_dac0_31_
// leadoff removed ////}
// leadoff removed //`else
// leadoff removed //`LEADOFF_TOP_0.timer_cnt_cnt_dac0;
// leadoff removed //`endif
// leadoff removed //
// leadoff removed //assign dut_vif.dut_timer_cnt_cnt_dac1                   = 
// leadoff removed //`ifndef BEHAVIORAL
// leadoff removed //32'h0;
// leadoff removed ////{`LEADOFF_TOP.timer_cnt_cnt_dac1_reg_0_.timer_cnt_cnt_dac1_0_,
// leadoff removed //// `LEADOFF_TOP.timer_cnt_cnt_dac1_reg_1_.timer_cnt_cnt_dac1_1_,
// leadoff removed //// `LEADOFF_TOP.timer_cnt_cnt_dac1_reg_2_.timer_cnt_cnt_dac1_2_,
// leadoff removed //// `LEADOFF_TOP.timer_cnt_cnt_dac1_reg_3_.timer_cnt_cnt_dac1_3_,
// leadoff removed //// `LEADOFF_TOP.timer_cnt_cnt_dac1_reg_4_.timer_cnt_cnt_dac1_4_,
// leadoff removed //// `LEADOFF_TOP.timer_cnt_cnt_dac1_reg_5_.timer_cnt_cnt_dac1_5_,
// leadoff removed //// `LEADOFF_TOP.timer_cnt_cnt_dac1_reg_6_.timer_cnt_cnt_dac1_6_,
// leadoff removed //// `LEADOFF_TOP.timer_cnt_cnt_dac1_reg_7_.timer_cnt_cnt_dac1_7_,
// leadoff removed //// `LEADOFF_TOP.timer_cnt_cnt_dac1_reg_8_.test_so3,
// leadoff removed //// `LEADOFF_TOP.timer_cnt_cnt_dac1_reg_9_.timer_cnt_cnt_dac1_9_,
// leadoff removed //// `LEADOFF_TOP.timer_cnt_cnt_dac1_reg_10_.timer_cnt_cnt_dac1_10_,
// leadoff removed //// `LEADOFF_TOP.timer_cnt_cnt_dac1_reg_11_.timer_cnt_cnt_dac1_11_,
// leadoff removed //// `LEADOFF_TOP.timer_cnt_cnt_dac1_reg_12_.test_so2,
// leadoff removed //// `LEADOFF_TOP.timer_cnt_cnt_dac1_reg_13_.test_so1,
// leadoff removed //// `LEADOFF_TOP.timer_cnt_cnt_dac1_reg_14_.timer_cnt_cnt_dac1_14_,
// leadoff removed //// `LEADOFF_TOP.timer_cnt_cnt_dac1_reg_15_.timer_cnt_cnt_dac1_15_,
// leadoff removed //// `LEADOFF_TOP.timer_cnt_cnt_dac1_reg_16_.timer_cnt_cnt_dac1_16_,
// leadoff removed //// `LEADOFF_TOP.timer_cnt_cnt_dac1_reg_17_.timer_cnt_cnt_dac1_17_,
// leadoff removed //// `LEADOFF_TOP.timer_cnt_cnt_dac1_reg_18_.timer_cnt_cnt_dac1_18_,
// leadoff removed //// `LEADOFF_TOP.timer_cnt_cnt_dac1_reg_19_.timer_cnt_cnt_dac1_19_,
// leadoff removed //// `LEADOFF_TOP.timer_cnt_cnt_dac1_reg_20_.timer_cnt_cnt_dac1_20_,
// leadoff removed //// `LEADOFF_TOP.timer_cnt_cnt_dac1_reg_21_.timer_cnt_cnt_dac1_21_,
// leadoff removed //// `LEADOFF_TOP.timer_cnt_cnt_dac1_reg_22_.timer_cnt_cnt_dac1_22_,
// leadoff removed //// `LEADOFF_TOP.timer_cnt_cnt_dac1_reg_23_.timer_cnt_cnt_dac1_23_,
// leadoff removed //// `LEADOFF_TOP.timer_cnt_cnt_dac1_reg_24_.timer_cnt_cnt_dac1_24_,
// leadoff removed //// `LEADOFF_TOP.timer_cnt_cnt_dac1_reg_25_.timer_cnt_cnt_dac1_25_,
// leadoff removed //// `LEADOFF_TOP.timer_cnt_cnt_dac1_reg_26_.timer_cnt_cnt_dac1_26_,
// leadoff removed //// `LEADOFF_TOP.timer_cnt_cnt_dac1_reg_27_.timer_cnt_cnt_dac1_27_,
// leadoff removed //// `LEADOFF_TOP.timer_cnt_cnt_dac1_reg_28_.timer_cnt_cnt_dac1_28_,
// leadoff removed //// `LEADOFF_TOP.timer_cnt_cnt_dac1_reg_29_.timer_cnt_cnt_dac1_29_,
// leadoff removed //// `LEADOFF_TOP.timer_cnt_cnt_dac1_reg_30_.timer_cnt_cnt_dac1_30_,
// leadoff removed //// `LEADOFF_TOP.timer_cnt_cnt_dac1_reg_31_.timer_cnt_cnt_dac1_31_
// leadoff removed ////}
// leadoff removed //`else
// leadoff removed //`LEADOFF_TOP_1.timer_cnt_cnt_dac0;
// leadoff removed //`endif
// leadoff removed //
// leadoff removed //assign dut_vif.dut_lead_off_Counter_cnt_dac0            = 
// leadoff removed //`ifndef BEHAVIORAL
// leadoff removed //32'h0;
// leadoff removed ////{`LEADOFF_TOP.lead_off_Counter_cnt_dac0_reg_0_.lead_off_Counter_cnt_dac0_0_,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac0_reg_1_.lead_off_Counter_cnt_dac0__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac0_reg_2_.lead_off_Counter_cnt_dac0__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac0_reg_3_.lead_off_Counter_cnt_dac0__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac0_reg_4_.lead_off_Counter_cnt_dac0__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac0_reg_5_.lead_off_Counter_cnt_dac0__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac0_reg_6_.lead_off_Counter_cnt_dac0__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac0_reg_7_.lead_off_Counter_cnt_dac0__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac0_reg_8_.lead_off_Counter_cnt_dac0__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac0_reg_9_.lead_off_Counter_cnt_dac0__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac0_reg_10_.lead_off_Counter_cnt_dac0__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac0_reg_11_.lead_off_Counter_cnt_dac0__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac0_reg_12_.lead_off_Counter_cnt_dac0__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac0_reg_13_.lead_off_Counter_cnt_dac0__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac0_reg_14_.lead_off_Counter_cnt_dac0__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac0_reg_15_.lead_off_Counter_cnt_dac0__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac0_reg_16_.lead_off_Counter_cnt_dac0__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac0_reg_17_.lead_off_Counter_cnt_dac0__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac0_reg_18_.lead_off_Counter_cnt_dac0__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac0_reg_19_.lead_off_Counter_cnt_dac0__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac0_reg_20_.lead_off_Counter_cnt_dac0__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac0_reg_21_.lead_off_Counter_cnt_dac0__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac0_reg_22_.lead_off_Counter_cnt_dac0__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac0_reg_23_.lead_off_Counter_cnt_dac0__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac0_reg_24_.lead_off_Counter_cnt_dac0__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac0_reg_25_.lead_off_Counter_cnt_dac0__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac0_reg_26_.lead_off_Counter_cnt_dac0__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac0_reg_27_.lead_off_Counter_cnt_dac0__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac0_reg_28_.lead_off_Counter_cnt_dac0__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac0_reg_29_.lead_off_Counter_cnt_dac0__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac0_reg_30_.lead_off_Counter_cnt_dac0__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac0_reg_31_.lead_off_Counter_cnt_dac0__
// leadoff removed ////}
// leadoff removed //`else
// leadoff removed //`LEADOFF_TOP_0.lead_off_Counter_cnt_dac0;
// leadoff removed //`endif
// leadoff removed //
// leadoff removed //assign dut_vif.dut_lead_off_Counter_cnt_dac1            = 
// leadoff removed //`ifndef BEHAVIORAL
// leadoff removed //32'h0;
// leadoff removed ////{`LEADOFF_TOP.lead_off_Counter_cnt_dac1_reg_0_.lead_off_Counter_cnt_dac1_0_,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac1_reg_1_.lead_off_Counter_cnt_dac1__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac1_reg_2_.lead_off_Counter_cnt_dac1__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac1_reg_3_.lead_off_Counter_cnt_dac1__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac1_reg_4_.lead_off_Counter_cnt_dac1__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac1_reg_5_.lead_off_Counter_cnt_dac1__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac1_reg_6_.lead_off_Counter_cnt_dac1__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac1_reg_7_.lead_off_Counter_cnt_dac1__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac1_reg_8_.lead_off_Counter_cnt_dac1__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac1_reg_9_.lead_off_Counter_cnt_dac1__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac1_reg_10_.lead_off_Counter_cnt_dac1__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac1_reg_11_.lead_off_Counter_cnt_dac1__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac1_reg_12_.lead_off_Counter_cnt_dac1__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac1_reg_13_.lead_off_Counter_cnt_dac1__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac1_reg_14_.lead_off_Counter_cnt_dac1__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac1_reg_15_.lead_off_Counter_cnt_dac1__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac1_reg_16_.lead_off_Counter_cnt_dac1__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac1_reg_17_.lead_off_Counter_cnt_dac1__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac1_reg_18_.lead_off_Counter_cnt_dac1__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac1_reg_19_.lead_off_Counter_cnt_dac1__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac1_reg_20_.lead_off_Counter_cnt_dac1__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac1_reg_21_.lead_off_Counter_cnt_dac1__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac1_reg_22_.lead_off_Counter_cnt_dac1__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac1_reg_23_.lead_off_Counter_cnt_dac1__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac1_reg_24_.lead_off_Counter_cnt_dac1__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac1_reg_25_.lead_off_Counter_cnt_dac1__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac1_reg_26_.lead_off_Counter_cnt_dac1__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac1_reg_27_.lead_off_Counter_cnt_dac1__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac1_reg_28_.lead_off_Counter_cnt_dac1__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac1_reg_29_.lead_off_Counter_cnt_dac1__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac1_reg_30_.lead_off_Counter_cnt_dac1__,
// leadoff removed //// `LEADOFF_TOP.lead_off_Counter_cnt_dac1_reg_31_.lead_off_Counter_cnt_dac1__
// leadoff removed ////}
// leadoff removed //`else
// leadoff removed //`LEADOFF_TOP_1.lead_off_Counter_cnt_dac0;
// leadoff removed //`endif
// leadoff removed //   
// leadoff removed //assign dut_vif.leadoff_pclk                             = `LEADOFF_WRAPPER_TOP.i_pclk;
// leadoff removed //assign dut_vif.leadoff_presetn                          = `LEADOFF_WRAPPER_TOP.i_presetn;
assign dut_vif.anac_pclk                                = `ANAC_TOP.sysclk;
assign dut_vif.anac_presetn                             = `ANAC_TOP.presetn;
// end by supriya


initial begin
  //nnc_config_db#(virtual spi_master_if)::set(`nnc_root::get(), "`nnc_test_top.top_env", "m_spiif", m_spiif);
  //nnc_config_db#(virtual spi_slave_if)::set(`nnc_root::get(), "`nnc_test_top.top_env", "s_spiif", s_spiif);
  //nnc_config_db#(virtual spi_AO_if)::set(`nnc_root::get(), "`nnc_test_top.top_env", "a_spiif", a_spiif); 
  //nnc_config_db#(virtual nnc_spi_vip_if)::set(`nnc_root::get(), "`nnc_test_top.top_env", "top_spi_if", top_spi_if);
  //nnc_config_db#(virtual timer_if)::set(`nnc_root::get(), "`nnc_test_top.top_env", "vif", vif);
  nnc_config_db#(virtual dut_interface)::set(`nnc_root::get(), "*", "dut_if" ,dut_vif);
  //nnc_config_db#(virtual tsc1_eeprom_interface)::set(`nnc_root::get(),"`nnc_test_top.top_env.eeprom_env.*", "eeprom_if", eeprom_vif);
`ifndef OTP_ENABLE
  nnc_config_db#(virtual nnc_eeprom_bist_interface)::set(`nnc_root::get(), "`nnc_test_top.top_env.eeprom_env.*", "eeprom_bist_if", eeprom_bist_if);
`else

`endif
  //nnc_config_db#(virtual tsc1_analog_interface)::set(`nnc_root::get(),"`nnc_test_top.top_env.*",   "ana_vif", ana_vif);
  //nnc_config_db#(virtual tsc1_register_interface)::set(`nnc_root::get(),"`nnc_test_top.top_env.analog_env_i.*", "reg_vif", reg_vif);  
  //nnc_config_db#(virtual ao_sys_ctrl_interface)::set(`nnc_root::get(), "*", "AO_sys_ctrl_if", AO_sys_ctrl_if);
  //nnc_config_db#(virtual tsc1_register_interface)::set(`nnc_root::get(), "*", "tsc1_reg_if", reg_vif);
  //nnc_config_db#(virtual tsc1_ao_top_interface)::set(`nnc_root::get(), "*", "ao_top_if", ao_top_if);
  //nnc_config_db#(virtual tsc1_i2d_a2d_sw_interface)::set(`nnc_root::get(), "*", "sw_vif", sw_vif);
end

initial
  begin
    run_test();
  end
