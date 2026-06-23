/*--------------------------------------------------------------------------------------*/
// Copyright 2021 Nanochap, Inc.
// All Rights Reserved Worldwide
// --------------------------------------------------------------------------------------
// Project      : Nanochap ENS2
// File         : tb_chip_top_uvm_sys.sv
// Description  : SYSTEM CLOCK TB (included file) 
// Designer     : Daniel Dang
// Date         : 18-03-2024
// Revision     : 0.1
/*--------------------------------------------------------------------------------------*/

parameter SYS_CLK_PERIOD_2MHZ=500;   //2 MHZ

reg sys_clk;
reg sys_rst_n;

initial
 begin
  sys_clk=1'b0;
  forever 
    #(SYS_CLK_PERIOD_2MHZ/2*(2**dut_vif.pclk_sel))  sys_clk = ~sys_clk;
    /*
    begin 
    case(dut_vif.pclk_sel)
      2'b00: #(SYS_CLK_PERIOD_2MHZ/2)  sys_clk = ~sys_clk;
      2'b01: #(SYS_CLK_PERIOD_2MHZ/4)  sys_clk = ~sys_clk; 
      2'b10: #(SYS_CLK_PERIOD_2MHZ/8)  sys_clk = ~sys_clk; 
      2'b11: #(SYS_CLK_PERIOD_2MHZ/16) sys_clk = ~sys_clk;
    endcase
    end//2mhz
    */
 end

initial
 begin
    sys_rst_n = 1'b0;
    #10000;
    sys_rst_n = 1'b1;
    `ifdef BEHAVIORAL
    forever #1 begin
      if (dut_vif.soc_resetn === 0) sys_rst_n = 1'b0;
      else if (dut_vif.soc_resetn === 1) #10 sys_rst_n = 1'b1;
      else if (dut_vif.testmode_sel === 2'b00 && `ANA_TOP.A2D_POR && VDD_DIG)
        `nnc_error("SOC", $sformatf("dut_vif.soc_resetn reset is: %h as unexpected", dut_vif.soc_resetn));
    end
    `endif
 end


nnc_clk_interface           clk_if();

assign clk_if.ext_clk_en      =    dut_vif.ext_clk_en ;
assign clk_if.pclk            =    `CLK_CTRL_TOP.pclk     ;
assign clk_if.A2D_OSC_OUT     =    `DIG_TOP.A2D_OSC_OUT  ;
assign clk_if.EXT_CLK         =    IOBUF_PAD[0]  ;
assign clk_if.gpio9           =    IOBUF_PAD[12] ; //IOBUF_PAD[9] ;
assign clk_if.gpio10          =    IOBUF_PAD[13] ; //IOBUF_PAD[10] ;
assign clk_if.wavegen_clk     =    `WG_DRIVER_TOP.i_pclk;       
// leadoff removed // assign clk_if.leadoff_clk     =    `LEADOFF_WRAPPER_TOP.i_pclk;       
assign clk_if.anac_clk        =    `ANAC_TOP.sysclk;       
assign clk_if.otp_clk         =    `EPROM_TOP.clk;       
assign clk_if.adc_dig_clk     =    `CLK_CTRL_TOP.imeas_dig_adc_clk[0];
assign clk_if.adc_ana_clk     =    `ANA_TOP.D2A_SDMCLK;

`ifdef BEHAVIORAL
assign clk_if.adc_dig_clk_en  =    `CLK_CTRL_TOP.u_cmsdk_clock_gate_iadc_clk[0].enable;
`else
assign clk_if.adc_dig_clk_en  =    `CLK_CTRL_TOP.u_cmsdk_clock_gate_iadc_clk_0_.enable;
`endif

assign clk_if.adc_ana_clk_en  =    `CLK_CTRL_TOP.u_cmsdk_clock_gate_analog_adcclk.enable;

initial begin
    nnc_config_db#(virtual nnc_clk_interface)::set(uvm_root::get(), "uvm_test_top.top_env.sysc_env.*", "clk_if", clk_if);
end

`define  SYS_CTRL_CFG           top_cfg.sysc_cfg
`define  CLKDIV_CHECK_EN        `SYS_CTRL_CFG.clkdiv_check_en 
`define  BOOST_CFG              top_cfg.boost_cfg
`define  BOOST_CHECK_EN         `BOOST_CFG.boost_checker_en 

//add quick checker for interface D2A_INA_CLK(INA_PGA_CLK)
always @(posedge `CLK_CTRL_TOP.fclk)begin
      if(dut_vif.d2a_ina_pga_clk_checker_en === 1'b1)begin
        if(dut_vif.pga_clk_enable === 1'b0)begin
            if(`CLK_CTRL_TOP.ina_pga_ana_clk !== `ANA_TOP.D2A_INA_CLK)
              `nnc_error("TB_SYS",$sformatf("Mismatch of ina_pga_ana_clk =%0h and ANA_TOP.D2A_INA_CLK =%0h!!!!\n", `CLK_CTRL_TOP.ina_pga_ana_clk, `ANA_TOP.D2A_INA_CLK))
            else
               `uvm_info("TB_SYS",$sformatf("Match of ina_pga_ana_clk =%0h and ANA_TOP.D2A_INA_CLK =%0h \n",`CLK_CTRL_TOP.ina_pga_ana_clk, `ANA_TOP.D2A_INA_CLK),UVM_MEDIUM) 
        end
        else begin
            if(`CLK_CTRL_TOP.ina_pga_ana_clk !== 1'b0 && `ANA_TOP.D2A_INA_CLK !== 1'b0)
              `nnc_error("TB_SYS",$sformatf("INA_PGA_CLK NOT DISABLED!!!!!, ina_pga_ana_clk =%0h and ANA_TOP.D2A_INA_CLK =%0h\n", `CLK_CTRL_TOP.ina_pga_ana_clk, `ANA_TOP.D2A_INA_CLK))
            else
               `uvm_info("TB_SYS",$sformatf("INA_PGA_CLK DISABLED!!!!!Match of ina_pga_ana_clk =%0h and ANA_TOP.D2A_INA_CLK =%0h \n",`CLK_CTRL_TOP.ina_pga_ana_clk, `ANA_TOP.D2A_INA_CLK),UVM_MEDIUM) 
        end
      end
end

//add quick checker for interface D2A_ADC_CLK(STIM_MON)
always @(posedge `CLK_CTRL_TOP.fclk)begin
      if(dut_vif.d2a_stim_mon_adc_clk_checker_en === 1'b1)begin
        if(dut_vif.sim_mon_adc_clk_enable === 1'b1)begin
            if(dut_vif.stim_mon_adc_clk_inv === 1'b0)begin
              if(`CLK_CTRL_TOP.stim_monitor_dig_clk !== `ANA_TOP.D2A_ADC_CLK)
                `nnc_error("TB_SYS",$sformatf("Mismatch(same phase) of stim_monitor_dig_clk =%0h and ANA_TOP.D2A_ADC_CLK =%0h!!!!\n", `CLK_CTRL_TOP.stim_monitor_dig_clk, `ANA_TOP.D2A_ADC_CLK))
              else
                 `uvm_info("TB_SYS",$sformatf("Match(same phase) of stim_monitor_dig_clk =%0h and ANA_TOP.D2A_ADC_CLK =%0h \n",`CLK_CTRL_TOP.stim_monitor_dig_clk, `ANA_TOP.D2A_ADC_CLK),UVM_MEDIUM)
              end
            else begin
              if(`CLK_CTRL_TOP.stim_monitor_dig_clk !== ~`ANA_TOP.D2A_ADC_CLK)
                `nnc_error("TB_SYS",$sformatf("Mismatch(invert) of stim_monitor_dig_clk =%0h and ANA_TOP.D2A_ADC_CLK =%0h!!!!\n", `CLK_CTRL_TOP.stim_monitor_dig_clk, `ANA_TOP.D2A_ADC_CLK))
              else
                 `uvm_info("TB_SYS",$sformatf("Match(invert) of stim_monitor_dig_clk =%0h and ANA_TOP.D2A_ADC_CLK =%0h \n",`CLK_CTRL_TOP.stim_monitor_dig_clk, `ANA_TOP.D2A_ADC_CLK),UVM_MEDIUM)
            end  
        end
        else begin
            if(`CLK_CTRL_TOP.stim_monitor_dig_clk !== 1'b0 && `ANA_TOP.D2A_ADC_CLK !== 1'b0)
              `nnc_error("TB_SYS",$sformatf("SIM_MON CLK NOT DISABLED!!!!!, stim_monitor_dig_clk =%0h and ANA_TOP.D2A_ADC_CLK =%0h\n", `CLK_CTRL_TOP.stim_monitor_dig_clk, `ANA_TOP.D2A_ADC_CLK))
            else
               `uvm_info("TB_SYS",$sformatf("STIM MON CLK DISABLED!!!!!Match of stim_monitor_dig_clk =%0h and ANA_TOP.D2A_ADC_CLK =%0h \n",`CLK_CTRL_TOP.stim_monitor_dig_clk, `ANA_TOP.D2A_ADC_CLK),UVM_MEDIUM) 
        end
      end
end

//add quick checker for interface D2A_CLK_NIRS(NIRS_PPG_CLK)
always @(posedge `CLK_CTRL_TOP.fclk)begin
      if(dut_vif.d2a_clk_nirs_ppg_checker_en === 1'b1)begin
        if(dut_vif.nirs_ppg_clk_enable === 1'b0)begin
            if(dut_vif.ana_nirs_ppg_clk_inv === 1'b0)begin
              if(`CLK_CTRL_TOP.clk_ppg !== `ANA_TOP.D2A_CLK_NIRS)
                `nnc_error("TB_SYS",$sformatf("Mismatch(same phase) of clk_ppg =%0h and ANA_TOP.D2A_CLK_NIRS =%0h!!!!\n", `CLK_CTRL_TOP.clk_ppg, `ANA_TOP.D2A_CLK_NIRS))
              else
                 `uvm_info("TB_SYS",$sformatf("Match(same phase) of clk_ppg =%0h and ANA_TOP.D2A_CLK_NIRS =%0h \n",`CLK_CTRL_TOP.clk_ppg, `ANA_TOP.D2A_CLK_NIRS),UVM_MEDIUM)
              end
            else begin
              if(`CLK_CTRL_TOP.clk_ppg !== ~`ANA_TOP.D2A_CLK_NIRS)
                `nnc_error("TB_SYS",$sformatf("Mismatch(invert) of clk_ppg =%0h and ANA_TOP.D2A_CLK_NIRS =%0h!!!!\n", `CLK_CTRL_TOP.clk_ppg, `ANA_TOP.D2A_CLK_NIRS))
              else
                 `uvm_info("TB_SYS",$sformatf("Match(invert) of clk_ppg =%0h and ANA_TOP.D2A_CLK_NIRS =%0h \n",`CLK_CTRL_TOP.clk_ppg, `ANA_TOP.D2A_CLK_NIRS),UVM_MEDIUM)
            end  
        end
        else begin
            if(`CLK_CTRL_TOP.clk_ppg !== 1'b0 && `ANA_TOP.D2A_CLK_NIRS !== 1'b0)
              `nnc_error("TB_SYS",$sformatf("SIM_MON CLK NOT DISABLED!!!!!, clk_ppg =%0h and ANA_TOP.D2A_CLK_NIRS =%0h\n", `CLK_CTRL_TOP.clk_ppg, `ANA_TOP.D2A_CLK_NIRS))
            else
               `uvm_info("TB_SYS",$sformatf("STIM MON CLK DISABLED!!!!!Match of clk_ppg =%0h and ANA_TOP.D2A_CLK_NIRS =%0h \n",`CLK_CTRL_TOP.clk_ppg, `ANA_TOP.D2A_CLK_NIRS),UVM_MEDIUM) 
        end
      end
end

nnc_boost_interface     boost_vif();

assign   boost_vif.pclk          =  0;// `DIG_TOP.u_anac.sysclk;
assign   boost_vif.boost_clk     =  0;// `DIG_TOP.u_anac.boost_clk;
assign   boost_vif.clk_fix       =  0;// `DIG_TOP.u_anac.boost_ctrl2_reg[7];
assign   boost_vif.duty_sel      =  0;// `DIG_TOP.u_anac.boost_ctrl2_reg[6];
assign   boost_vif.duty          =  0;// `DIG_TOP.u_anac.boost_ctrl2_reg[5:3];
assign   boost_vif.pres          =  0;// `DIG_TOP.u_anac.boost_ctrl2_reg[2:0];
assign   boost_vif.boost_en      =  0;// `DIG_TOP.u_anac.boost_ctrl0_reg[0];

initial begin
    nnc_config_db#(virtual nnc_boost_interface)::set(uvm_root::get(), "uvm_test_top.*", "boost_vif", boost_vif);
end

