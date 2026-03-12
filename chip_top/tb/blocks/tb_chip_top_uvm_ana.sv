/*--------------------------------------------------------------------------------------*/
// Copyright 2021 Nanochap, Inc.
// All Rights Reserved Worldwide
// --------------------------------------------------------------------------------------
// Project      : Nanochap ENS2
// File         : tb_chip_top_uvm_ana.sv
// Description  : ANALOG BLOCK TB (included file) 
// Designer     : Daniel Dang
// Date         : 18-03-2024
// Revision     : 0.1
/*--------------------------------------------------------------------------------------*/


////////////////////analog signals connection//////////////////////////

nnc_analog_interface    ana_if();

//Currently using leadoff_short analog model to drive, so random input no longer used
//assign `ANA_TOP.A2D_COMP_OUT_STIMU0_1 = (dut_vif.A2D_stim_sel[0] === 1'b1) ? dut_vif.A2D_comp_stim0_1_in : 1'bz;
//assign `ANA_TOP.A2D_COMP_OUT_STIMU2_3 = (dut_vif.A2D_stim_sel[1] === 1'b1) ? dut_vif.A2D_comp_stim2_3_in : 1'bz;

assign ana_if.testmode                 =     dut_vif.testmode_sel;
//assign ana_if.GPIO               =     `SOC_TB.IOBUF_PAD ;  
always@(IOBUF_PAD[7:1])begin
    ana_if.atm_check_point++;
    //foreach(ana_if.GPIO[i]) ana_if.GPIO[i]       = `SOC_TOP.IOBUF_PAD[i] === 1'bz ? 1'bx :  `SOC_TOP.IOBUF_PAD[i];
    ana_if.GPIO[1]       = `SOC_TOP.IOBUF_PAD[1] === 1'bz ? 1'bx :  `SOC_TOP.IOBUF_PAD[1];
    ana_if.GPIO[2]       = `SOC_TOP.IOBUF_PAD[2] === 1'bz ? 1'bx :  `SOC_TOP.IOBUF_PAD[2];
    ana_if.GPIO[3]       = `SOC_TOP.IOBUF_PAD[3] === 1'bz ? 1'bx :  `SOC_TOP.IOBUF_PAD[3];
    ana_if.GPIO[4]       = `SOC_TOP.IOBUF_PAD[4] === 1'bz ? 1'bx :  `SOC_TOP.IOBUF_PAD[4];
    ana_if.GPIO[5]       = `SOC_TOP.IOBUF_PAD[5] === 1'bz ? 1'bx :  `SOC_TOP.IOBUF_PAD[5];
    ana_if.GPIO[6]       = `SOC_TOP.IOBUF_PAD[6] === 1'bz ? 1'bx :  `SOC_TOP.IOBUF_PAD[6];
    ana_if.GPIO[7]       = `SOC_TOP.IOBUF_PAD[7] === 1'bz ? 1'bx :  `SOC_TOP.IOBUF_PAD[7];
    ana_if.GPIO[8]       = `SOC_TOP.IOBUF_PAD[8] === 1'bz ? 1'bx :  `SOC_TOP.IOBUF_PAD[8];
    ana_if.GPIO[9]       = `SOC_TOP.IOBUF_PAD[9] === 1'bz ? 1'bx :  `SOC_TOP.IOBUF_PAD[9];
    ana_if.GPIO[10]      = `SOC_TOP.IOBUF_PAD[10] === 1'bz ? 1'bx :  `SOC_TOP.IOBUF_PAD[10];
end
assign   ana_if.GPIO[0]      = `SOC_TOP.IOBUF_PAD[0] === 1'bz ? 1'bx :  `SOC_TOP.IOBUF_PAD[0];
assign ana_if.clk                      =     `CLK_CTRL_TOP.ext_clk_sel ?  `CLK_CTRL_TOP.ext_hfclk : `CLK_CTRL_TOP.hfosc;
//assign ana_if.fclk                   =     `CLK_CTRL_TOP.hosc;
assign ana_if.sclk                   =       spi_vif.i_cs_n ? ana_if.clk : spi_vif.i_sclk;
assign ana_if.VDD_DIG                  =     VDD_DIG;
assign ana_if.D2A_ATM            =     /*`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM */  '{`ANA_TOP.D2A_ATM7, `ANA_TOP.D2A_ATM6, `ANA_TOP.D2A_ATM5, `ANA_TOP.D2A_ATM4, `ANA_TOP.D2A_ATM3, `ANA_TOP.D2A_ATM2, `ANA_TOP.D2A_ATM1, `ANA_TOP.D2A_ATM0};


`ifdef BEHAVIORAL
assign ana_if.D2A_TRIM[`OTP_TRIM_SIZE-3:0]           =     `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG[`OTP_TRIM_SIZE-3:0];
//assign ana_if.D2A_TRIM[10:8]          =     `ANA_WRAPPER_TOP.pinmux_if.D2A_TRIM_SIG_SPARE;
assign ana_if.OTP_TRIM               =     `EPROM_TOP.spi_otp.trim_read;
assign ana_if.D2A_ANA_REG[8'hC:4]    =     `ANA_WRAPPER_TOP.spi_ana_if.D2A_ANA_GEN_REG;
assign ana_if.D2A_ANA_REG[3:0]        =     `ANA_WRAPPER_TOP.pinmux_if.D2A_ANA_ENABLE_REG;
assign ana_if.SPI_ANA_REG[8'hC:4]    =     `SPI_TOP.spi_ana_if.D2A_ANA_GEN_REG;
assign ana_if.SPI_ANA_REG[3:0]        =     `SPI_TOP.spi_pinmux_if.ANA_ENABLE_REG;
assign ana_if.A2D_ANA_REG[1:0]        =     `ANA_WRAPPER_TOP.spi_ana_if.A2D_ANA_GEN_REG ;
assign ana_if.SPI_A2D_ANA_REG[1:0]    =     `SPI_TOP.spi_ana_if.A2D_ANA_GEN_REG  ;

`else
`ifndef POSTLAYOUT
assign ana_if.OTP_TRIM                =      `EPROM_TOP.spi_otp_trim_read;
`else
assign ana_if.OTP_TRIM                =      `SPI_TOP.spi_otp_trim_read;      //{`EPROM_TOP.u_otp_trim_if.shadow_regs[95:32], `EPROM_TOP.u_otp_trim_if.shadow_regs[7:0]} ;
`endif
assign ana_if.D2A_TRIM[7:0]           =     `ANA_WRAPPER_TOP.pinmux_if_D2A_TRIM_SIG;
assign ana_if.SPI_ANA_REG[8'hC:4]    =     `SPI_TOP.spi_ana_if_D2A_ANA_GEN_REG;
assign ana_if.SPI_ANA_REG[3:0]        =     `SPI_TOP.spi_pinmux_if_ANA_ENABLE_REG;
assign ana_if.D2A_ANA_REG[8'hC:4]    =     `ANA_WRAPPER_TOP.spi_ana_if_D2A_ANA_GEN_REG;
assign ana_if.D2A_ANA_REG[3:0]        =     `ANA_WRAPPER_TOP.pinmux_if_D2A_ANA_ENABLE_REG;
assign ana_if.A2D_ANA_REG[1:0]        =     `ANA_WRAPPER_TOP.spi_ana_if_A2D_ANA_GEN_REG  ;
assign ana_if.SPI_A2D_ANA_REG[1:0]    =     `SPI_TOP.spi_ana_if_A2D_ANA_GEN_REG  ;
`endif
assign ana_if.SPI_ATM_HC_SEL        =   spi_vif.REG_DATA[0][8'h7E][0];

assign ana_if.OTP_VPP_EN            =  `DIG_TOP.u_pinmux.i_otp_vpp_en;//`EPROM_TOP.otp_vpp_en;
assign ana_if.CLKSEL                = `SOC_TOP.CLKSEL;
assign ana_if.OTP_UNLOCK            = `EPROM_TOP.unlock_gpio;
//////////////////////ana_top connection/////////////////////////////////////////////////////////////////////////////////////////////////////// 
// START list:: this below list copied from generated file using script verification/models/nnc_analog_mon_20240517_1/nnc_ana_atm_monnnc_ana_top_connect.svh
 
//assign  ana_if.clk_in1    =   `ANA_TOP.clk_in1 ;
assign  ana_if.A2D_CLK2MHZ    =   `ANA_TOP.A2D_CLK2MHZ ;
assign  ana_if.A2D_LVD    =   `ANA_TOP.A2D_LVD ;
assign  ana_if.A2D_POR_DVDD    =   `ANA_TOP.A2D_POR_DVDD ;
assign  ana_if.A2D_COMP_OUT_CH1    =   `ANA_TOP.A2D_COMP_OUT_CH1 ;
assign  ana_if.A2D_COMP_OUT_CH2    =   `ANA_TOP.A2D_COMP_OUT_CH2 ;
assign  ana_if.D2A_BG_TRIM    =   `ANA_TOP.D2A_BG_TRIM ;
assign  ana_if.D2A_IREF_TRIM    =   `ANA_TOP.D2A_IREF_TRIM ;
assign  ana_if.D2A_CLDO1P8_TRIM    =   `ANA_TOP.D2A_CLDO1P8_TRIM ;
assign  ana_if.D2A_LVD_EN    =   `ANA_TOP.D2A_LVD_EN ;
assign  ana_if.D2A_LVD_SEL    =   `ANA_TOP.D2A_LVD_SEL ;
assign  ana_if.D2A_IBIAS_IDAC_TRIM    =   `ANA_TOP.D2A_IBIAS_IDAC_TRIM ;
assign  ana_if.D2A_OSC2MHZ_TRIM    =   `ANA_TOP.D2A_OSC2MHZ_TRIM ;
assign  ana_if.D2A_OSC2MHZEN    =   `ANA_TOP.D2A_OSC2MHZEN ;
assign  ana_if.D2A_CS_PGA_CLK_TRIM    =   `ANA_TOP.D2A_CS_PGA_CLK_TRIM ;
assign  ana_if.D2A_BIST_EN    =   `ANA_TOP.D2A_BIST_EN ;
assign  ana_if.D2A_BIST_SEL    =   `ANA_TOP.D2A_BIST_SEL ;
assign  ana_if.D2A_VDAC_VTRIM_CH1    =   `ANA_TOP.D2A_VDAC_VTRIM_CH1 ;
assign  ana_if.D2A_CS_EN_CH_CH1    =   `ANA_TOP.D2A_CS_EN_CH_CH1 ;
assign  ana_if.D2A_DRIVERA_SOURCEA_CH1    =   `ANA_TOP.D2A_DRIVERA_SOURCEA_CH1 ;
assign  ana_if.D2A_DRIVERA_SOURCEB_CH1    =   `ANA_TOP.D2A_DRIVERA_SOURCEB_CH1 ;
assign  ana_if.D2A_DRIVERA_PULLDA_CH1    =   `ANA_TOP.D2A_DRIVERA_PULLDA_CH1 ;
assign  ana_if.D2A_DRIVERA_PULLDB_CH1    =   `ANA_TOP.D2A_DRIVERA_PULLDB_CH1 ;
assign  ana_if.D2A_COMP_EN_CH1    =   `ANA_TOP.D2A_COMP_EN_CH1 ;
assign  ana_if.D2A_IDAC_EN_CH1    =   `ANA_TOP.D2A_IDAC_EN_CH1 ;
assign  ana_if.D2A_IDAC_DIN_CH1    =   `ANA_TOP.D2A_IDAC_DIN_CH1 ;
assign  ana_if.D2A_VDAC_EN_CH1    =   `ANA_TOP.D2A_VDAC_EN_CH1 ;
assign  ana_if.D2A_VDAC_DIN_CH1    =   `ANA_TOP.D2A_VDAC_DIN_CH1 ;
assign  ana_if.D2A_DRIVERA_CSAMP_EN_CH1    =   `ANA_TOP.D2A_DRIVERA_CSAMP_EN_CH1 ;
assign  ana_if.D2A_STIMU_COMP_SEL_CH1    =   `ANA_TOP.D2A_STIMU_COMP_SEL_CH1 ;
assign  ana_if.D2A_STIMU_COMP_EN_CH1    =   `ANA_TOP.D2A_STIMU_COMP_EN_CH1 ;
assign  ana_if.D2A_CS_TRIM_CH1    =   `ANA_TOP.D2A_CS_TRIM_CH1 ;
assign  ana_if.D2A_LEAD_OFF_SEL_SA_SB_CH1    =   `ANA_TOP.D2A_LEAD_OFF_SEL_SA_SB_CH1 ;
assign  ana_if.D2A_PUMP_CLK_TRIM_CH1    =   `ANA_TOP.D2A_PUMP_CLK_TRIM_CH1 ;
assign  ana_if.D2A_PUMP_5V_EN_CH1    =   `ANA_TOP.D2A_PUMP_5V_EN_CH1 ;
assign  ana_if.D2A_PUMP_LDO_EN_CH1    =   `ANA_TOP.D2A_PUMP_LDO_EN_CH1 ;
assign  ana_if.D2A_LDO2P8_PUMP_TRIM_CH1    =   `ANA_TOP.D2A_LDO2P8_PUMP_TRIM_CH1 ;
assign  ana_if.D2A_LDO1P8_LDO2P8_CH1_SEL    =   `ANA_TOP.D2A_LDO1P8_LDO2P8_CH1_SEL ;
assign  ana_if.A2D_COMP_OUT_STIMU0_1    =   `ANA_TOP.A2D_COMP_OUT_STIMU0_1 ;
assign  ana_if.D2A_VDAC_VTRIM_CH2    =   `ANA_TOP.D2A_VDAC_VTRIM_CH2 ;
assign  ana_if.D2A_CS_EN_CH_CH2    =   `ANA_TOP.D2A_CS_EN_CH_CH2 ;
assign  ana_if.D2A_DRIVERA_SOURCEA_CH2    =   `ANA_TOP.D2A_DRIVERA_SOURCEA_CH2 ;
assign  ana_if.D2A_DRIVERA_SOURCEB_CH2    =   `ANA_TOP.D2A_DRIVERA_SOURCEB_CH2 ;
assign  ana_if.D2A_DRIVERA_PULLDA_CH2    =   `ANA_TOP.D2A_DRIVERA_PULLDA_CH2 ;
assign  ana_if.D2A_DRIVERA_PULLDB_CH2    =   `ANA_TOP.D2A_DRIVERA_PULLDB_CH2 ;
assign  ana_if.D2A_COMP_EN_CH2    =   `ANA_TOP.D2A_COMP_EN_CH2 ;
assign  ana_if.D2A_IDAC_EN_CH2    =   `ANA_TOP.D2A_IDAC_EN_CH2 ;
assign  ana_if.D2A_IDAC_DIN_CH2    =   `ANA_TOP.D2A_IDAC_DIN_CH2 ;
assign  ana_if.D2A_VDAC_EN_CH2    =   `ANA_TOP.D2A_VDAC_EN_CH2 ;
assign  ana_if.D2A_VDAC_DIN_CH2    =   `ANA_TOP.D2A_VDAC_DIN_CH2 ;
assign  ana_if.D2A_DRIVERA_CSAMP_EN_CH2    =   `ANA_TOP.D2A_DRIVERA_CSAMP_EN_CH2 ;
assign  ana_if.D2A_STIMU_COMP_SEL_CH2    =   `ANA_TOP.D2A_STIMU_COMP_SEL_CH2 ;
assign  ana_if.D2A_STIMU_COMP_EN_CH2    =   `ANA_TOP.D2A_STIMU_COMP_EN_CH2 ;
assign  ana_if.D2A_CS_TRIM_CH2    =   `ANA_TOP.D2A_CS_TRIM_CH2 ;
assign  ana_if.D2A_LEAD_OFF_SEL_SA_SB_CH2    =   `ANA_TOP.D2A_LEAD_OFF_SEL_SA_SB_CH2 ;
assign  ana_if.D2A_PUMP_CLK_TRIM_CH2    =   `ANA_TOP.D2A_PUMP_CLK_TRIM_CH2 ;
assign  ana_if.D2A_PUMP_5V_EN_CH2    =   `ANA_TOP.D2A_PUMP_5V_EN_CH2 ;
assign  ana_if.D2A_PUMP_LDO_EN_CH2    =   `ANA_TOP.D2A_PUMP_LDO_EN_CH2 ;
assign  ana_if.D2A_LDO2P8_PUMP_TRIM_CH2    =   `ANA_TOP.D2A_LDO2P8_PUMP_TRIM_CH2 ;
assign  ana_if.A2D_COMP_OUT_STIMU2_3    =   `ANA_TOP.A2D_COMP_OUT_STIMU2_3 ;
assign  ana_if.D2A_ATM0    =   `ANA_TOP.D2A_ATM0 ;
assign  ana_if.D2A_ATM1    =   `ANA_TOP.D2A_ATM1 ;
assign  ana_if.D2A_ATM2    =   `ANA_TOP.D2A_ATM2 ;
assign  ana_if.D2A_ATM3    =   `ANA_TOP.D2A_ATM3 ;
assign  ana_if.D2A_ATM4    =   `ANA_TOP.D2A_ATM4 ;
assign  ana_if.D2A_ATM5    =   `ANA_TOP.D2A_ATM5 ;
assign  ana_if.D2A_ATM6    =   `ANA_TOP.D2A_ATM6 ;
assign  ana_if.D2A_ATM7    =   `ANA_TOP.D2A_ATM7 ;
assign  ana_if.D2A_SPI_SPARE0    =   `ANA_TOP.D2A_SPI_SPARE0 ;
assign  ana_if.D2A_SPI_SPARE1    =   `ANA_TOP.D2A_SPI_SPARE1 ;
assign  ana_if.D2A_SPI_SPARE2    =   `ANA_TOP.D2A_SPI_SPARE2 ;
assign  ana_if.D2A_SPI_SPARE3    =   `ANA_TOP.D2A_SPI_SPARE3 ;
assign  ana_if.D2A_BIST_SPARE_3    =   `ANA_TOP.D2A_BIST_SPARE_3 ;
assign  ana_if.D2A_BIST_SPARE_4    =   `ANA_TOP.D2A_BIST_SPARE_4 ;
assign  ana_if.D2A_BIST_SPARE_5    =   `ANA_TOP.D2A_BIST_SPARE_5 ;
assign  ana_if.D2A_BIST_SPARE_7    =   `ANA_TOP.D2A_BIST_SPARE_7 ;
assign  ana_if.D2A_TRIM0_SIG_SPARE    =   `ANA_TOP.D2A_TRIM0_SIG_SPARE ;
assign  ana_if.A2D_SPARE_RO_REG_0    =   `ANA_TOP.A2D_SPARE_RO_REG_0 ;
assign  ana_if.A2D_TSC_COMP_OUT_CH1    =   `ANA_TOP.A2D_TSC_COMP_OUT_CH1 ;
assign  ana_if.D2A_TSC_TRIM_CH1    =   `ANA_TOP.D2A_TSC_TRIM_CH1 ;
assign  ana_if.D2A_IREF_TSC_OUT_SEL    =   `ANA_TOP.D2A_IREF_TSC_OUT_SEL ;
assign  ana_if.D2A_IDAC_TSC_COMP_OUT_SEL    =   `ANA_TOP.D2A_IDAC_TSC_COMP_OUT_SEL ;
assign  ana_if.D2A_TSC_EN_CH1    =   `ANA_TOP.D2A_TSC_EN_CH1 ;
assign  ana_if.D2A_TSC_COMP_EN_CH1    =   `ANA_TOP.D2A_TSC_COMP_EN_CH1 ;
assign  ana_if.D2A_VDAC8B_EN_CH1    =   `ANA_TOP.D2A_VDAC8B_EN_CH1 ;
assign  ana_if.D2A_VDAC8B_DIN_CH1    =   `ANA_TOP.D2A_VDAC8B_DIN_CH1 ;
//END List:: the above block of list copied from generated file using script verification/models/nnc_analog_mon_20240517_1/nnc_ana_atm_monnnc_ana_top_connect.svh
initial begin
    nnc_config_db#(virtual nnc_analog_interface)::set(uvm_root::get(), "uvm_test_top.top_env.ana_env.ana_mon" , "ana_if", ana_if);
end
