/*--------------------------------------------------------------------------------------
// Copyright 2021 Nanochap, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name    : soc_top_tb.sv                                                   
// Project      : Nanochap ENS2                                                         
// Description  : SOC TOP Testbench                                        
// Designer     : ddang@nanochap.com                                                                 
// Date         : 18-03-2024                                                                    
// Revision     : 0.1                                 
--------------------------------------------------------------------------------------*/
`define SOC_TB  soc_top_tb
`define SOC_TOP `SOC_TB.u_Nanochap_ENS2
`define DIG_TOP `SOC_TOP.u_top_dig
`define ANA_WRAPPER_TOP `SOC_TOP.u_top_ana_wrapper
`define ANA_TOP `ANA_WRAPPER_TOP.u_top_ana
`define IMEAS_WRAPPER_TOP `DIG_TOP.u_imeas_wrapper
`define FILTER_WRAPPER_TOP `IMEAS_WRAPPER_TOP.genblk1[0].u_filter_wrapper
`define LEADOFF_WRAPPER_TOP `DIG_TOP.u_lead_off_detector_wrapper //u_lead_off_detector
`define LEADOFF_TOP_0 `LEADOFF_WRAPPER_TOP.lead_off_block[0].u_lead_off_detector
`define LEADOFF_TOP_1 `LEADOFF_WRAPPER_TOP.lead_off_block[1].u_lead_off_detector
`define WG_DRIVER_TOP `DIG_TOP.u_wg_driver
`define WG_DRIVER_CORE `WG_DRIVER_TOP.wg_driver_top_inst
`define ZMEAS_TOP `DIG_TOP.u_adc_cap_ctrl
`define SPI_TOP `DIG_TOP.u_spi_top
`define SPI_REG `SPI_TOP.spi_reg_u
`define PINMUX_TOP `DIG_TOP.u_pinmux
`define RESETN `DIG_TOP.u_reset_ctrl.presetn
`define HF_RESETN `DIG_TOP.u_reset_ctrl.poresetn_hf
`define PMU_CTRL_TOP `DIG_TOP.u_pmu
`define CLK_CTRL_TOP `DIG_TOP.u_clk_ctrl
`define RST_CTRL_TOP `DIG_TOP.u_reset_ctrl
`define EPROM_TOP `DIG_TOP.u_otp_ctrl_top
`define EPROM_BIST_TOP `EPROM_TOP.u_eprom_bist_top
`define EPROM_IP `EPROM_TOP.u_EO32X32GCT2Q_H3
`ifdef BEHAVIORAL
  `define EPROM_IP1 `EPROM_TOP.WAVEGEN_COEFFS[0].u_EO32X32GCT2Q_H3_wavgen
`else
  `define EPROM_IP1 `EPROM_TOP.WAVEGEN_COEFFS_0__u_EO32X32GCT2Q_H3_wavgen
`endif
`define ANAC_TOP `DIG_TOP.u_anac
`define TSC_TOP `DIG_TOP.u_temp_sar_ctrl
`define NIRS_PPG_TOP `DIG_TOP.u_nirs_wrapper

`define SOC_TOP_S1 `SOC_TB.u_Nanochap_ENS2_S1
`define DIG_TOP_S1 `SOC_TOP_S1.u_top_dig
`define ANA_WRAPPER_TOP_S1 `SOC_TOP_S1.u_top_ana_wrapper
`define ANA_TOP_S1 `ANA_WRAPPER_TOP_S1.u_top_ana
`define IMEAS_WRAPPER_TOP_S1 `DIG_TOP_S1.u_imeas_wrapper
`define FILTER_WRAPPER_TOP_S1 `IMEAS_WRAPPER_TOP_S1.genblk1[0].u_filter_wrapper
//`define LEADOFF_TOP_1 `DIG_TOP_1.u_lead_off_detector
`define LEADOFF_WRAPPER_TOP_S1 `DIG_TOP_S1.u_lead_off_detector_wrapper //u_lead_off_detector
`define LEADOFF_TOP_0_S1 `LEADOFF_WRAPPER_TOP_S1.lead_off_block[0].u_lead_off_detector
`define LEADOFF_TOP_1_S1 `LEADOFF_WRAPPER_TOP_S1.lead_off_block[1].u_lead_off_detector
`define WG_DRIVER_TOP_S1 `DIG_TOP_S1.u_wg_driver
`define SPI_TOP_S1 `DIG_TOP_S1.u_spi_top
`define RESETN_D1 `DIG_TOP_D1.u_reset_ctrl.presetn
`define HF_RESETN_S1 `DIG_TOP_S1.u_reset_ctrl.poresetn_hf
`define PMU_CTRL_TOP_S1 `DIG_TOP_S1.u_pmu
`define CLK_CTRL_TOP_S1 `DIG_TOP_S1.u_clk_ctrl
`define RST_CTRL_TOP_S1 `DIG_TOP_S1.u_reset_ctrl
`define EPROM_TOP_S1 `DIG_TOP_S1.u_otp_ctrl_top
`define EPROM_BIST_TOP_S1 `EPROM_TOP_S1.u_eprom_bist_top
`define EPROM_IP_S1 `EPROM_TOP_S1.u_EO32X32GCT2Q_H3

`define SOC_TOP_S2 `SOC_TB.u_Nanochap_ENS2_S2
`define DIG_TOP_S2 `SOC_TOP_S2.u_top_dig
`define ANA_WRAPPER_TOP_S2 `SOC_TOP_S2.u_top_ana_wrapper
`define ANA_TOP_S2 `ANA_WRAPPER_TOP_S2.u_top_ana
`define IMEAS_WRAPPER_TOP_S2 `DIG_TOP_S2.u_imeas_wrapper
`define FILTER_WRAPPER_TOP_S2 `IMEAS_WRAPPER_TOP_S2.genblk1[0].u_filter_wrapper
//`define LEADOFF_TOP_2 `DIG_TOP_2.u_lead_off_detector
`define LEADOFF_WRAPPER_TOP_2 `DIG_TOP_S2.u_lead_off_detector_wrapper
`define LEADOFF_TOP_0_S2 `LEADOFF_WRAPPER_TOP_S2.lead_off_block[0].u_lead_off_detector
`define LEADOFF_TOP_1_S2 `LEADOFF_WRAPPER_TOP_S2.lead_off_block[1].u_lead_off_detector
`define WG_DRIVER_TOP_S2 `DIG_TOP_S2.u_wg_driver
`define SPI_TOP_S2 `DIG_TOP_S2.u_spi_top
`define RESETN_S2 `DIG_TOP_S2.u_reset_ctrl.presetn
`define HF_RESETN_S2 `DIG_TOP_2.u_reset_ctrl.poresetn_hf
`define PMU_CTRL_TOP_S2 `DIG_TOP_S2.u_pmu
`define CLK_CTRL_TOP_S2 `DIG_TOP_S2.u_clk_ctrl
`define RST_CTRL_TOP_S2 `DIG_TOP_S2.u_reset_ctrl
`define EPROM_TOP_S2 `DIG_TOP_S2.u_otp_ctrl_top
`define EPROM_BIST_TOP_S2 `EPROM_TOP_S2.u_eprom_bist_top
`define EPROM_IP_S2 `EPROM_TOP_S2.u_EO32X32GCT2Q_H3

`define POWER_ON_TIME 1000ns

`define SPIM_VIP `SOC_TB.spim_vip
`define EPROM_BIST_MASTER_VIP `SOC_TB.u_eprom_bist_master

`ifdef BEHAVIORAL
`define SPI_WG_REG_BLOCK_0 `SPI_REG.wg_reg_block[0].u_spi_reg_wavegen
`define SPI_WG_REG_BLOCK_1 `SPI_REG.wg_reg_block[1].u_spi_reg_wavegen
`define SPI_WG_REG_BLOCK_2 `SPI_REG.wg_reg_block[2].u_spi_reg_wavegen
`define SPI_WG_REG_BLOCK_3 `SPI_REG.wg_reg_block[3].u_spi_reg_wavegen
`define SPI_WG_REG_BLOCK_4 `SPI_REG.wg_reg_block[4].u_spi_reg_wavegen
`define SPI_WG_REG_BLOCK_5 `SPI_REG.wg_reg_block[5].u_spi_reg_wavegen
`define SPI_WG_REG_BLOCK_6 `SPI_REG.wg_reg_block[6].u_spi_reg_wavegen
`define SPI_WG_REG_BLOCK_7 `SPI_REG.wg_reg_block[7].u_spi_reg_wavegen
`define SPI_WG_REG_BLOCK_8 `SPI_REG.wg_reg_block[8].u_spi_reg_wavegen
`define SPI_WG_REG_BLOCK_9 `SPI_REG.wg_reg_block[9].u_spi_reg_wavegen
`define SPI_WG_REG_BLOCK_10 `SPI_REG.wg_reg_block[10].u_spi_reg_wavegen
`define SPI_WG_REG_BLOCK_11 `SPI_REG.wg_reg_block[11].u_spi_reg_wavegen
`define SPI_WG_REG_BLOCK_12 `SPI_REG.wg_reg_block[12].u_spi_reg_wavegen
`define SPI_WG_REG_BLOCK_13 `SPI_REG.wg_reg_block[13].u_spi_reg_wavegen
`define SPI_WG_REG_BLOCK_14 `SPI_REG.wg_reg_block[14].u_spi_reg_wavegen
`define SPI_WG_REG_BLOCK_15 `SPI_REG.wg_reg_block[15].u_spi_reg_wavegen
`else
`define SPI_WG_REG_BLOCK_0 `SPI_REG.wg_reg_block_0__u_spi_reg_wavegen
`define SPI_WG_REG_BLOCK_1 `SPI_REG.wg_reg_block_1__u_spi_reg_wavegen
`define SPI_WG_REG_BLOCK_2 `SPI_REG.wg_reg_block_2__u_spi_reg_wavegen
`define SPI_WG_REG_BLOCK_3 `SPI_REG.wg_reg_block_3__u_spi_reg_wavegen
`define SPI_WG_REG_BLOCK_4 `SPI_REG.wg_reg_block_4__u_spi_reg_wavegen
`define SPI_WG_REG_BLOCK_5 `SPI_REG.wg_reg_block_5__u_spi_reg_wavegen
`define SPI_WG_REG_BLOCK_6 `SPI_REG.wg_reg_block_6__u_spi_reg_wavegen
`define SPI_WG_REG_BLOCK_7 `SPI_REG.wg_reg_block_7__u_spi_reg_wavegen
`define SPI_WG_REG_BLOCK_8 `SPI_REG.wg_reg_block_8__u_spi_reg_wavegen
`define SPI_WG_REG_BLOCK_9 `SPI_REG.wg_reg_block_9__u_spi_reg_wavegen
`define SPI_WG_REG_BLOCK_10 `SPI_REG.wg_reg_block_10__u_spi_reg_wavegen
`define SPI_WG_REG_BLOCK_11 `SPI_REG.wg_reg_block_11__u_spi_reg_wavegen
`define SPI_WG_REG_BLOCK_12 `SPI_REG.wg_reg_block_12__u_spi_reg_wavegen
`define SPI_WG_REG_BLOCK_13 `SPI_REG.wg_reg_block_13__u_spi_reg_wavegen
`define SPI_WG_REG_BLOCK_14 `SPI_REG.wg_reg_block_14__u_spi_reg_wavegen
`define SPI_WG_REG_BLOCK_15 `SPI_REG.wg_reg_block_15__u_spi_reg_wavegen
`endif

`define SPI_SCB_EN top_cfg.spi_cfg.ens2_spi_scoreboard_en
`define SPI_STATUS_REG_CHECK_EN top_cfg.spi_cfg.soc_spi_status_reg_check_en

`define WAVEGEN_SCB_DRV_0_EN top_cfg.wavegen_cfg[0].nnc_wavegen_scoreboard_en[0]
`define WAVEGEN_SCB_DRV_1_EN top_cfg.wavegen_cfg[0].nnc_wavegen_scoreboard_en[1]
`define WAVEGEN_SCB_DRV_2_EN top_cfg.wavegen_cfg[0].nnc_wavegen_scoreboard_en[2]
`define WAVEGEN_SCB_DRV_3_EN top_cfg.wavegen_cfg[0].nnc_wavegen_scoreboard_en[3]
`define WAVEGEN_SCB_DRV_4_EN top_cfg.wavegen_cfg[0].nnc_wavegen_scoreboard_en[4]
`define WAVEGEN_SCB_DRV_5_EN top_cfg.wavegen_cfg[0].nnc_wavegen_scoreboard_en[5]
`define WAVEGEN_SCB_DRV_6_EN top_cfg.wavegen_cfg[0].nnc_wavegen_scoreboard_en[6]
`define WAVEGEN_SCB_DRV_7_EN top_cfg.wavegen_cfg[0].nnc_wavegen_scoreboard_en[7]
`define WAVEGEN_SCB_DRV_8_EN top_cfg.wavegen_cfg[0].nnc_wavegen_scoreboard_en[8]
`define WAVEGEN_SCB_DRV_9_EN top_cfg.wavegen_cfg[0].nnc_wavegen_scoreboard_en[9]
`define WAVEGEN_SCB_DRV_10_EN top_cfg.wavegen_cfg[0].nnc_wavegen_scoreboard_en[10]
`define WAVEGEN_SCB_DRV_11_EN top_cfg.wavegen_cfg[0].nnc_wavegen_scoreboard_en[11]
`define WAVEGEN_SCB_DRV_12_EN top_cfg.wavegen_cfg[0].nnc_wavegen_scoreboard_en[12]
`define WAVEGEN_SCB_DRV_13_EN top_cfg.wavegen_cfg[0].nnc_wavegen_scoreboard_en[13]
`define WAVEGEN_SCB_DRV_14_EN top_cfg.wavegen_cfg[0].nnc_wavegen_scoreboard_en[14]
`define WAVEGEN_SCB_DRV_15_EN top_cfg.wavegen_cfg[0].nnc_wavegen_scoreboard_en[15]

`define CHIP_1_WAVEGEN_SCB_DRV_0_EN top_cfg.wavegen_cfg[1].nnc_wavegen_scoreboard_en[0]
`define CHIP_1_WAVEGEN_SCB_DRV_1_EN top_cfg.wavegen_cfg[1].nnc_wavegen_scoreboard_en[1]
`define CHIP_1_WAVEGEN_SCB_DRV_2_EN top_cfg.wavegen_cfg[1].nnc_wavegen_scoreboard_en[2]
`define CHIP_1_WAVEGEN_SCB_DRV_3_EN top_cfg.wavegen_cfg[1].nnc_wavegen_scoreboard_en[3]
`define CHIP_1_WAVEGEN_SCB_DRV_4_EN top_cfg.wavegen_cfg[1].nnc_wavegen_scoreboard_en[4]
`define CHIP_1_WAVEGEN_SCB_DRV_5_EN top_cfg.wavegen_cfg[1].nnc_wavegen_scoreboard_en[5]
`define CHIP_1_WAVEGEN_SCB_DRV_6_EN top_cfg.wavegen_cfg[1].nnc_wavegen_scoreboard_en[6]
`define CHIP_1_WAVEGEN_SCB_DRV_7_EN top_cfg.wavegen_cfg[1].nnc_wavegen_scoreboard_en[7]
`define CHIP_1_WAVEGEN_SCB_DRV_8_EN top_cfg.wavegen_cfg[1].nnc_wavegen_scoreboard_en[8]
`define CHIP_1_WAVEGEN_SCB_DRV_9_EN top_cfg.wavegen_cfg[1].nnc_wavegen_scoreboard_en[9]
`define CHIP_1_WAVEGEN_SCB_DRV_10_EN top_cfg.wavegen_cfg[1].nnc_wavegen_scoreboard_en[10]
`define CHIP_1_WAVEGEN_SCB_DRV_11_EN top_cfg.wavegen_cfg[1].nnc_wavegen_scoreboard_en[11]
`define CHIP_1_WAVEGEN_SCB_DRV_12_EN top_cfg.wavegen_cfg[1].nnc_wavegen_scoreboard_en[12]
`define CHIP_1_WAVEGEN_SCB_DRV_13_EN top_cfg.wavegen_cfg[1].nnc_wavegen_scoreboard_en[13]
`define CHIP_1_WAVEGEN_SCB_DRV_14_EN top_cfg.wavegen_cfg[1].nnc_wavegen_scoreboard_en[14]
`define CHIP_1_WAVEGEN_SCB_DRV_15_EN top_cfg.wavegen_cfg[1].nnc_wavegen_scoreboard_en[15]

`define WAVEGEN_SCB_SCALE_OFFSET_CHECK_EN top_cfg.wavegen_cfg[0].nnc_wavegen_scale_offset_check_en
`define CHIP_1_WAVEGEN_SCB_SCALE_OFFSET_CHECK_EN top_cfg.wavegen_cfg[1].nnc_wavegen_scale_offset_check_en

`define WAVEGEN_SCB_PULL_SOURCE_CHECK_EN top_cfg.wavegen_cfg[0].nnc_wavegen_pull_source_check_en
`define CHIP_1_WAVEGEN_SCB_PULL_SOURCE_CHECK_EN top_cfg.wavegen_cfg[1].nnc_wavegen_pull_source_check_en

`define WAVEGEN_SCB_PULL_SOURCE_CLK_CHECK_EN top_cfg.wavegen_cfg[0].nnc_wavegen_pull_source_clk_check_en
`define CHIP_1_WAVEGEN_SCB_PULL_SOURCE_CLK_CHECK_EN top_cfg.wavegen_cfg[1].nnc_wavegen_pull_source_clk_check_en

`define WAVEGEN_SHORT_SHORT_INTR_COUNTER_CHECK_EN top_cfg.wavegen_cfg[0].short_comp_intr_counter_check_en
`define CHIP_1_WAVEGEN_SHORT_SHORT_INTR_COUNTER_CHECK_EN top_cfg.wavegen_cfg[1].short_comp_intr_counter_check_en

`define WAVEGEN_MULT_CHIP_CHECK_EN top_cfg.wavegen_cfg[0].nnc_wavegen_mult_chip_check_en
`define CHIP_1_WAVEGEN_MULT_CHIP_CHECK_EN top_cfg.wavegen_cfg[1].nnc_wavegen_mult_chip_check_en

//Inside LEADOFF Scorebaord, anac Short and leadoff detection related, expected timer counter and expected response counter compared with DUT internal counter signals resp. so this check is enabled only for RTL sims,netlist sim disabled through base test
`define ANAC_SHORT_LEADOFF_COUNTER_CHECK_EN top_cfg.lead_off_cfg.anac_short_leadoff_counter_check_en 

`define WAVEGEN_SHORT_DETECT_SCB_EN top_cfg.wavegen_cfg[0].nnc_wavegen_ana_short_intr_check_en
`define CHIP_1_WAVEGEN_SHORT_DETECT_SCB_EN top_cfg.wavegen_cfg[1].nnc_wavegen_ana_short_intr_check_en

`define IMEAS_SCB_EN             top_cfg.imeas_cfg.nnc_imeas_scoreboard_en
`define LEAD_OFF_SCB_EN          top_cfg.lead_off_cfg.nnc_lead_off_scoreboard_en
`define ANAC_SHORT_SCB_EN        top_cfg.lead_off_cfg.nnc_anac_short_scoreboard_en
`define ANALOG_SCOREBOARD_EN     top_cfg.ana_cfg.nnc_analog_scoreboard_en
`define PINMUX_SCOREBOARD_EN     top_cfg.pinmux_cfg.nnc_pinmux_scoreboard_en

`define NNC_WAVEGEN_REF_SCB_EN   top_cfg.wavegen_cfg[0].nnc_wavgen_ref_scb_en
`define NNC_WG_AGENT top_env.wavegen_env.wg_drvs_agt
`define NNC_WAVEGEN_REF_SCB_EN_0 `NNC_WG_AGENT.wg_drv_agt[0].wavegen_ref_drv.wavegen_cfg.nnc_wavgen_ref_scb_en
`define NNC_WAVEGEN_REF_SCB_EN_1 `NNC_WG_AGENT.wg_drv_agt[1].wavegen_ref_drv.wavegen_cfg.nnc_wavgen_ref_scb_en
`define NNC_WAVEGEN_REF_SCB_EN_2 `NNC_WG_AGENT.wg_drv_agt[2].wavegen_ref_drv.wavegen_cfg.nnc_wavgen_ref_scb_en
`define NNC_WAVEGEN_REF_SCB_EN_3 `NNC_WG_AGENT.wg_drv_agt[3].wavegen_ref_drv.wavegen_cfg.nnc_wavgen_ref_scb_en
`define NNC_WAVEGEN_REF_SCB_EN_4 `NNC_WG_AGENT.wg_drv_agt[4].wavegen_ref_drv.wavegen_cfg.nnc_wavgen_ref_scb_en
`define NNC_WAVEGEN_REF_SCB_EN_5 `NNC_WG_AGENT.wg_drv_agt[5].wavegen_ref_drv.wavegen_cfg.nnc_wavgen_ref_scb_en
`define NNC_WAVEGEN_REF_SCB_EN_6 `NNC_WG_AGENT.wg_drv_agt[6].wavegen_ref_drv.wavegen_cfg.nnc_wavgen_ref_scb_en
`define NNC_WAVEGEN_REF_SCB_EN_7 `NNC_WG_AGENT.wg_drv_agt[7].wavegen_ref_drv.wavegen_cfg.nnc_wavgen_ref_scb_en
`define NNC_WAVEGEN_REF_SCB_EN_8 `NNC_WG_AGENT.wg_drv_agt[8].wavegen_ref_drv.wavegen_cfg.nnc_wavgen_ref_scb_en
`define NNC_WAVEGEN_REF_SCB_EN_9 `NNC_WG_AGENT.wg_drv_agt[9].wavegen_ref_drv.wavegen_cfg.nnc_wavgen_ref_scb_en
`define NNC_WAVEGEN_REF_SCB_EN_10 `NNC_WG_AGENT.wg_drv_agt[10].wavegen_ref_drv.wavegen_cfg.nnc_wavgen_ref_scb_en
`define NNC_WAVEGEN_REF_SCB_EN_11 `NNC_WG_AGENT.wg_drv_agt[11].wavegen_ref_drv.wavegen_cfg.nnc_wavgen_ref_scb_en
`define NNC_WAVEGEN_REF_SCB_EN_12 `NNC_WG_AGENT.wg_drv_agt[12].wavegen_ref_drv.wavegen_cfg.nnc_wavgen_ref_scb_en
`define NNC_WAVEGEN_REF_SCB_EN_13 `NNC_WG_AGENT.wg_drv_agt[13].wavegen_ref_drv.wavegen_cfg.nnc_wavgen_ref_scb_en
`define NNC_WAVEGEN_REF_SCB_EN_14 `NNC_WG_AGENT.wg_drv_agt[14].wavegen_ref_drv.wavegen_cfg.nnc_wavgen_ref_scb_en
`define NNC_WAVEGEN_REF_SCB_EN_15 `NNC_WG_AGENT.wg_drv_agt[15].wavegen_ref_drv.wavegen_cfg.nnc_wavgen_ref_scb_en

`define TOP_ENV_ENABLE
`define POSTSCAN_NETLIST_ROOT "../netlist/prelayout"
`define POSTLAYOUT_NETLIST_ROOT "../netlist/postlayout"

`define GPIO_NUM 22
`define SCAN_SIZE 9

`ifdef BEHAVIORAL
  `define ATM_PINMUX_IF {`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[0],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[1],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[2],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[3],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[4],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[5],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[6],`ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[7], `ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[8], `ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[9], `ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[10], `ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[11], `ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[12], `ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[13], `ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[14], `ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[15], `ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[16], `ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[17], `ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[18], `ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[19], `ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[20], `ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[21], `ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[22], `ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[23], `ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[24], `ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[25], `ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[26], `ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[27], `ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[28], `ANA_WRAPPER_TOP.pinmux_if.D2A_ATM[29]}
`else
  `define ATM_PINMUX_IF {`ANA_WRAPPER_TOP.pinmux_if_D2A_ATM[0],`ANA_WRAPPER_TOP.pinmux_if_D2A_ATM[1],`ANA_WRAPPER_TOP.pinmux_if_D2A_ATM[2],`ANA_WRAPPER_TOP.pinmux_if_D2A_ATM[3],`ANA_WRAPPER_TOP.pinmux_if_D2A_ATM[4],`ANA_WRAPPER_TOP.pinmux_if_D2A_ATM[5],`ANA_WRAPPER_TOP.pinmux_if_D2A_ATM[6],`ANA_WRAPPER_TOP.pinmux_if_D2A_ATM[7], `ANA_WRAPPER_TOP.pinmux_if_D2A_ATM[8], `ANA_WRAPPER_TOP.pinmux_if_D2A_ATM[9], `ANA_WRAPPER_TOP.pinmux_if_D2A_ATM[10], `ANA_WRAPPER_TOP.pinmux_if_D2A_ATM[11], `ANA_WRAPPER_TOP.pinmux_if_D2A_ATM[12], `ANA_WRAPPER_TOP.pinmux_if_D2A_ATM[13], `ANA_WRAPPER_TOP.pinmux_if_D2A_ATM[14], `ANA_WRAPPER_TOP.pinmux_if_D2A_ATM[15], `ANA_WRAPPER_TOP.pinmux_if_D2A_ATM[16], `ANA_WRAPPER_TOP.pinmux_if_D2A_ATM[17], `ANA_WRAPPER_TOP.pinmux_if_D2A_ATM[18], `ANA_WRAPPER_TOP.pinmux_if_D2A_ATM[19], `ANA_WRAPPER_TOP.pinmux_if_D2A_ATM[20], `ANA_WRAPPER_TOP.pinmux_if_D2A_ATM[21], `ANA_WRAPPER_TOP.pinmux_if_D2A_ATM[22], `ANA_WRAPPER_TOP.pinmux_if_D2A_ATM[23], `ANA_WRAPPER_TOP.pinmux_if_D2A_ATM[24], `ANA_WRAPPER_TOP.pinmux_if_D2A_ATM[25], `ANA_WRAPPER_TOP.pinmux_if_D2A_ATM[26], `ANA_WRAPPER_TOP.pinmux_if_D2A_ATM[27], `ANA_WRAPPER_TOP.pinmux_if_D2A_ATM[28], `ANA_WRAPPER_TOP.pinmux_if_D2A_ATM[29]}
`endif

`ifdef BEHAVIORAL
`define NIR0 `NIRS_PPG_TOP.u_nirs_ctrl_top[0]
`define NIR1 `NIRS_PPG_TOP.u_nirs_ctrl_top[1]
`define NIR2 `NIRS_PPG_TOP.u_nirs_ctrl_top[2]
`define NIR3 `NIRS_PPG_TOP.u_nirs_ctrl_top[3]
`define NIR4 `NIRS_PPG_TOP.u_nirs_ctrl_top[4]
`define NIR5 `NIRS_PPG_TOP.u_nirs_ctrl_top[5]
`define NIR6 `NIRS_PPG_TOP.u_nirs_ctrl_top[6]
`define NIR7 `NIRS_PPG_TOP.u_nirs_ctrl_top[7]
`else
`define NIR0 `NIRS_PPG_TOP.u_nirs_ctrl_top_0_
`define NIR1 `NIRS_PPG_TOP.u_nirs_ctrl_top_1_
`define NIR2 `NIRS_PPG_TOP.u_nirs_ctrl_top_2_
`define NIR3 `NIRS_PPG_TOP.u_nirs_ctrl_top_3_
`define NIR4 `NIRS_PPG_TOP.u_nirs_ctrl_top_4_
`define NIR5 `NIRS_PPG_TOP.u_nirs_ctrl_top_5_
`define NIR6 `NIRS_PPG_TOP.u_nirs_ctrl_top_6_
`define NIR7 `NIRS_PPG_TOP.u_nirs_ctrl_top_7_
`endif

`ifdef BEHAVIORAL
  `define WG_CORE_0 `WG_DRIVER_CORE.WG_SUB_BLOCK[0].arb_wave_gen_inst
  `define WG_CORE_1 `WG_DRIVER_CORE.WG_SUB_BLOCK[1].arb_wave_gen_inst
  `define WG_CORE_2 `WG_DRIVER_CORE.WG_SUB_BLOCK[2].arb_wave_gen_inst
  `define WG_CORE_3 `WG_DRIVER_CORE.WG_SUB_BLOCK[3].arb_wave_gen_inst
  `define WG_CORE_4 `WG_DRIVER_CORE.WG_SUB_BLOCK[4].arb_wave_gen_inst
  `define WG_CORE_5 `WG_DRIVER_CORE.WG_SUB_BLOCK[5].arb_wave_gen_inst
  `define WG_CORE_6 `WG_DRIVER_CORE.WG_SUB_BLOCK[6].arb_wave_gen_inst
  `define WG_CORE_7 `WG_DRIVER_CORE.WG_SUB_BLOCK[7].arb_wave_gen_inst
  `define WG_CORE_8 `WG_DRIVER_CORE.WG_SUB_BLOCK[8].arb_wave_gen_inst
  `define WG_CORE_9 `WG_DRIVER_CORE.WG_SUB_BLOCK[9].arb_wave_gen_inst
  `define WG_CORE_10 `WG_DRIVER_CORE.WG_SUB_BLOCK[10].arb_wave_gen_inst
  `define WG_CORE_11 `WG_DRIVER_CORE.WG_SUB_BLOCK[11].arb_wave_gen_inst
  `define WG_CORE_12 `WG_DRIVER_CORE.WG_SUB_BLOCK[12].arb_wave_gen_inst
  `define WG_CORE_13 `WG_DRIVER_CORE.WG_SUB_BLOCK[13].arb_wave_gen_inst
  `define WG_CORE_14 `WG_DRIVER_CORE.WG_SUB_BLOCK[14].arb_wave_gen_inst
  `define WG_CORE_15 `WG_DRIVER_CORE.WG_SUB_BLOCK[15].arb_wave_gen_inst
  // THANH add
  `define WG_DRIVER_IDAC_0 `WG_DRIVER_TOP.o_out_wave_driver_idac[0] 
  `define WG_DRIVER_IDAC_1 `WG_DRIVER_TOP.o_out_wave_driver_idac[1] 
  `define WG_DRIVER_IDAC_2 `WG_DRIVER_TOP.o_out_wave_driver_idac[2]
  `define WG_DRIVER_IDAC_3 `WG_DRIVER_TOP.o_out_wave_driver_idac[3] 
  `define WG_DRIVER_IDAC_4 `WG_DRIVER_TOP.o_out_wave_driver_idac[4] 
  `define WG_DRIVER_IDAC_5 `WG_DRIVER_TOP.o_out_wave_driver_idac[5] 
  `define WG_DRIVER_IDAC_6 `WG_DRIVER_TOP.o_out_wave_driver_idac[6] 
  `define WG_DRIVER_IDAC_7 `WG_DRIVER_TOP.o_out_wave_driver_idac[7] 
  `define WG_DRIVER_IDAC_8 `WG_DRIVER_TOP.o_out_wave_driver_idac[8] 
  `define WG_DRIVER_IDAC_9 `WG_DRIVER_TOP.o_out_wave_driver_idac[9]
  `define WG_DRIVER_IDAC_10 `WG_DRIVER_TOP.o_out_wave_driver_idac[10]
  `define WG_DRIVER_IDAC_11 `WG_DRIVER_TOP.o_out_wave_driver_idac[11]
  `define WG_DRIVER_IDAC_12 `WG_DRIVER_TOP.o_out_wave_driver_idac[12]
  `define WG_DRIVER_IDAC_13 `WG_DRIVER_TOP.o_out_wave_driver_idac[13]
  `define WG_DRIVER_IDAC_14 `WG_DRIVER_TOP.o_out_wave_driver_idac[14]
  `define WG_DRIVER_IDAC_15 `WG_DRIVER_TOP.o_out_wave_driver_idac[15]

`else
  `define WG_CORE_0 `WG_DRIVER_CORE.WG_SUB_BLOCK_0__arb_wave_gen_inst
  `define WG_CORE_1 `WG_DRIVER_CORE.WG_SUB_BLOCK_1__arb_wave_gen_inst
  `define WG_CORE_2 `WG_DRIVER_CORE.WG_SUB_BLOCK_2__arb_wave_gen_inst
  `define WG_CORE_3 `WG_DRIVER_CORE.WG_SUB_BLOCK_3__arb_wave_gen_inst
  `define WG_CORE_4 `WG_DRIVER_CORE.WG_SUB_BLOCK_4__arb_wave_gen_inst
  `define WG_CORE_5 `WG_DRIVER_CORE.WG_SUB_BLOCK_5__arb_wave_gen_inst
  `define WG_CORE_6 `WG_DRIVER_CORE.WG_SUB_BLOCK_6__arb_wave_gen_inst
  `define WG_CORE_7 `WG_DRIVER_CORE.WG_SUB_BLOCK_7__arb_wave_gen_inst
  `define WG_CORE_8 `WG_DRIVER_CORE.WG_SUB_BLOCK_8__arb_wave_gen_inst
  `define WG_CORE_9 `WG_DRIVER_CORE.WG_SUB_BLOCK_9__arb_wave_gen_inst
  `define WG_CORE_10 `WG_DRIVER_CORE.WG_SUB_BLOCK_10__arb_wave_gen_inst
  `define WG_CORE_11 `WG_DRIVER_CORE.WG_SUB_BLOCK_11__arb_wave_gen_inst
  `define WG_CORE_12 `WG_DRIVER_CORE.WG_SUB_BLOCK_12__arb_wave_gen_inst
  `define WG_CORE_13 `WG_DRIVER_CORE.WG_SUB_BLOCK_13__arb_wave_gen_inst
  `define WG_CORE_14 `WG_DRIVER_CORE.WG_SUB_BLOCK_14__arb_wave_gen_inst
  `define WG_CORE_15 `WG_DRIVER_CORE.WG_SUB_BLOCK_15__arb_wave_gen_inst

  // THANH add
  `define WG_DRIVER_IDAC_0 `WG_DRIVER_TOP.o_out_wave_driver_idac[11:0]
  `define WG_DRIVER_IDAC_1 `WG_DRIVER_TOP.o_out_wave_driver_idac[23:12]
  `define WG_DRIVER_IDAC_2 `WG_DRIVER_TOP.o_out_wave_driver_idac[35:24]
  `define WG_DRIVER_IDAC_3 `WG_DRIVER_TOP.o_out_wave_driver_idac[47:36]
  `define WG_DRIVER_IDAC_4 `WG_DRIVER_TOP.o_out_wave_driver_idac[59:48]
  `define WG_DRIVER_IDAC_5 `WG_DRIVER_TOP.o_out_wave_driver_idac[71:60]
  `define WG_DRIVER_IDAC_6 `WG_DRIVER_TOP.o_out_wave_driver_idac[83:72]
  `define WG_DRIVER_IDAC_7 `WG_DRIVER_TOP.o_out_wave_driver_idac[95:84]
  `define WG_DRIVER_IDAC_8 `WG_DRIVER_TOP.o_out_wave_driver_idac[107:96]
  `define WG_DRIVER_IDAC_9 `WG_DRIVER_TOP.o_out_wave_driver_idac[119:108]
  `define WG_DRIVER_IDAC_10 `WG_DRIVER_TOP.o_out_wave_driver_idac[131:120]
  `define WG_DRIVER_IDAC_11 `WG_DRIVER_TOP.o_out_wave_driver_idac[143:132]
  `define WG_DRIVER_IDAC_12 `WG_DRIVER_TOP.o_out_wave_driver_idac[155:144]
  `define WG_DRIVER_IDAC_13 `WG_DRIVER_TOP.o_out_wave_driver_idac[167:156]
  `define WG_DRIVER_IDAC_14 `WG_DRIVER_TOP.o_out_wave_driver_idac[179:168]
  `define WG_DRIVER_IDAC_15 `WG_DRIVER_TOP.o_out_wave_driver_idac[191:180]
`endif

// ---------------------------------------------------
// SPI VIP TASKs
// ---------------------------------------------------
// Normal Register
// ---------------------------------------------------
`define WR_NORMAL_REG `SPIM_VIP.spi_wr_single_normal_reg
// `WR_NORMAL_REG(addr, data, pad); 

`define RD_NORMAL_REG `SPIM_VIP.spi_rd_single_normal_reg
// `RD_NORMAL_REG(addr, number_of_data, data[]);  

`define WR_BURST_NORMAL_REG `SPIM_VIP.spi_wr_burst_normal_reg
// `WR_BURST_NORMAL_REG(addr, number_of_data, pads, data[]); // data[0] will be to Address addr

`define RD_BURST_NORMAL_REG `SPIM_VIP.spi_rd_burst_normal_reg
// `RD_BURST_NORMAL_REG(addr, number_of_data, data[]); 

`define WR_RD_CHK_NORMAL_REG `SPIM_VIP.spi_wr_rd_single_normal_reg_chk
// `WR_RD_CHK_NORMAL_REG(addr, data, pad, mask); 

`define RD_RESET_CHK_NORMAL_REG `SPIM_VIP.spi_check_reset_value_normal_reg
// `RD_RESET_CHK_NORMAL_REG(addr, data, pad);

`define SPI_CHANGE_TO_DUAL_MODE `SPIM_VIP.spi_change_to_dual_spi
// ----------------------------------------------------
// RDATA and RDATAC 
// ----------------------------------------------------
`define RD_CONV_BY_RDATA `SPIM_VIP.spi_rd_rdata
// ---------------------------------------------------------------------------------------------------------------------------------------------
// `RD_CONV_BY_RDATA(channel_max[11:0], number_of_data, mode[2:0], data[]);
//  channel_max[11:10]: no of chip
//  channel_max[9:5]: Chip 2 and Chip 3, channel_max[4:0]: Chip 1
//  mode[2]: 1: daisy_en 
//  mode[1:0]: 00: 32-bit of data + 40-bit of status, 01: 24-bit of data + 40-bit of status,  10: 32-bit of data only, 11: 24-bit of data only
// ---------------------------------------------------------------------------------------------------------------------------------------------

`define RD_CONV_BY_RDATAC `SPIM_VIP.spi_rd_rdatac
// ---------------------------------------------------------------------------------------------------------------------------------------------
// `RD_CONV_BY_RDATAC(no_of_conv, number_of_data, mode[1:0], data[]);
// Mode[1:0]: 00: 32-bit of data + 40-bit of status, 01: 24-bit of data + 40-bit of status,  10: 32-bit of data only, 11: 24-bit of data only
// ---------------------------------------------------------------------------------------------------------------------------------------------

// ---------------------------------------
// Wavegen
// ---------------------------------------
`define WR_WAVEGEN_REG `SPIM_VIP.spi_wr_single_wavegen_reg
// `WR_WAVEGEN_REG(addr, data, pad); 

`define RD_WAVEGEN_REG `SPIM_VIP.spi_rd_single_wavegen_reg
// `RD_WAVEGEN_REG(addr, number_of_data, data[]);  

`define WR_BURST_WAVEGEN_REG `SPIM_VIP.spi_wr_burst_wavegen_reg
// `WR_BURST_WAVEGEN_REG(addr, number_of_data, pads, data[]); // data[0] will be to Address addr

`define RD_BURST_WAVEGEN_REG `SPIM_VIP.spi_rd_burst_wavegen_reg
// `RD_BURST_WAVEGEN_REG(addr, number_of_data, data[]); 

`define WR_RD_CHK_WAVEGEN_REG `SPIM_VIP.spi_wr_rd_single_wavegen_reg_chk
// `WR_RD_CHK_WAVEGEN_REG(addr, data, pad, mask); 

`define RD_RESET_CHK_WAVEGEN_REG `SPIM_VIP.spi_check_reset_value_wavegen_reg
// `RD_RESET_CHK_WAVEGEN_REG(addr, data, pad); 

// ---------------------------------------
// NIRS
// ---------------------------------------
`define WR_NIRS_REG `SPIM_VIP.spi_wr_single_nirs_reg
// `WR_NIRS_REG(addr, data, pad); 

`define RD_NIRS_REG `SPIM_VIP.spi_rd_single_nirs_reg
// `RD_NIRS_REG(addr, number_of_data, data[]);  

`define WR_BURST_NIRS_REG `SPIM_VIP.spi_wr_burst_nirs_reg
// `WR_BURST_NIRS_REG(addr, number_of_data, pads, data[]); // data[0] will be store to Addres: addr

`define RD_BURST_NIRS_REG `SPIM_VIP.spi_rd_burst_nirs_reg
// `RD_BURST_NIRS_REG(addr, number_of_data, data[]); 

`define WR_RD_CHK_NIRS_REG `SPIM_VIP.spi_wr_rd_single_nirs_reg_chk
// `WR_RD_CHK_NIRS_REG(addr, data, pad, mask); 

`define RD_RESET_CHK_NIRS_REG `SPIM_VIP.spi_check_reset_value_nirs_reg
// `RD_RESET_CHK_NIRS_REG(addr, data, pad); 

// --------------------------------------------------------
// The list command of OTP are used for performing BISM VIP
// --------------------------------------------------------
`define BISTM_RESET `EPROM_BIST_MASTER_VIP.bistm_reset // No arguments

`define BISTM_SINGLE_READ `EPROM_BIST_MASTER_VIP.bistm_single_rd_otp // input [0:0] OTP,  input [6:0] address, output [7:0] data;

`define BISTM_ENTIRE_READ `EPROM_BIST_MASTER_VIP.bistm_entire_read_otp // input [0:0] OTP, output [7:0] data[];

`define BISTM_SINGLE_PROGRAM `EPROM_BIST_MASTER_VIP.bistm_single_program_otp // input [0:0] OTP, input [6:0] address, input [7:0] data;

`define BISTM_ENTIRE_PROGRAM `EPROM_BIST_MASTER_VIP.bistm_entire_program_otp // input [0:0] OTP, input [7:0] data;

`define BISTM_MARGIN_SINGLE_READ `EPROM_BIST_MASTER_VIP.bistm_mrgn_single_rd_otp // input [0:0] OTP, input [6:0] address, output [7:0] data;

`define BISTM_MARGIN_ENTIRE_READ `EPROM_BIST_MASTER_VIP.bistm_mrgn_rd_entire_otp // input [0:0] OTP, output [7:0] data[];

`define BISTM_BYPASS `EPROM_BIST_MASTER_VIP.bistm_bypass // input [0:0] OTP, input [6:0] address, input [7:0] data[], input integer num, input write, /* 0:read ; 1:write;*/ input [1:0] TM;

`define BISTM_ENTIRE_CHECK `EPROM_BIST_MASTER_VIP.bistm_entire_check // input [0:0] OTP

`define BISTM_STANDBY `EPROM_BIST_MASTER_VIP.bistm_standby // input [0:0] OTP

import nnc_uvm_pkg::*;
`include "nnc_uvm_methodology.svh"

import soc_top_pkg::*;

module soc_top_tb #(parameter REDUNDANT_NO = 4);

wire [`GPIO_NUM-1:0] IOBUF_PAD;
wire [`GPIO_NUM-1:0] IOBUF_PAD_S1;
wire [`GPIO_NUM-1:0] IOBUF_PAD_S2;

wire                            spi_sck;
wire                            spi_miso;
wire                            spi_mosi;
wire                            spi_nss;

wire                            gpio3_conn;
wire                            gpio4_conn;
wire                            spi_miso_conn;
wire                            gpio5_conn;
wire                            gpio6_conn;

wire                            iopad_resetn;
reg                             ext_resetn;
reg				UNLOCK;

integer                         err_cnt=0;
reg  [1:0]                      test_value = 2'b00;
wire                            RESETb;
wire                            TCK;
wire                            TDO;
wire                            TDO_SEROUT;
wire                            TESTEN;
wire                            TDI;
wire                            STROBE;
wire                            WBUSY;
wire                            SDM_CLK;
wire                            SDM_OUT;
wire                            scan_rst_n;
wire                            scan_clk;
wire                            scan_en;
wire  [`SCAN_SIZE-1:0]          scan_in;
wire  [`SCAN_SIZE-1:0]          scan_out;
wire                            scan_compression_in;
wire                            atpg_en;
wire                            INTB;
wire                            VPP_EN;
wire  [3:0]                     INT; 
wire				VDD_DIG;
wire				VDD_DIG_S1;
wire				VDD_DIG_S2;
wire  [31:0]                    master_chip_wave1;
wire  [31:0]                    master_chip_wave2;
wire  [31:0]                    slave_chip_wave1;
wire  [31:0]                    slave_chip_wave2;
wire  [31:0]                    chip_wave1_overlay;
wire  [31:0]                    chip_wave2_overlay;
wire VPP;  
wire CLK0, CLK1, CLK2;
wire ext_hfclk;
wire DAISY_IN;
wire DRDYn;
wire FLASH_REF;
wire VPP_BIST;
wire VPP;
wire VPP_S1;
wire VPP_S2;

assign INT[0] = IOBUF_PAD[8];  // pmu_reg[6]=0: multi intr - pmu_reg[6]=1: ECG?
assign INT[1] = IOBUF_PAD[9];  // wavegen intr
assign INT[2] = IOBUF_PAD[10]; // anac intr - including stim and leadoff/short
assign INT[3] = IOBUF_PAD[11]; // NIRS intr

// ==============================
// UVM TB Including 
// ==============================
`include "soc_uvm_tb.sv"

// ==============================
// DUT Instantiation
// ==============================
`ifdef FPGA
wire clk_in1;
Nanochap_ENS2 u_Nanochap_ENS2
(
	.clk_in1(clk_in1),
        .IOBUF_PAD              (IOBUF_PAD)

);
`else
assign CLK0  = (dut_vif.mult_chip_en === 1'b1) ? ((dut_vif.mult_chip_typ === 2'b00) ? IOBUF_PAD[12] : (dut_vif.mult_chip_typ === 2'b01) ? 1'b0 : (dut_vif.mult_chip_typ === 2'b10) ? ext_hfclk : 1'b0) : (dut_vif.ext_clk_en === 1'b1) ? ext_hfclk : (dut_vif.gpio_pd_en[0] ? 1'bz : 1'b0);
assign CLK1  = (dut_vif.mult_chip_en === 1'b1) ? IOBUF_PAD[12] : (dut_vif.ext_clk_en === 1'b1) ? ext_hfclk : (dut_vif.gpio_pd_en[0] ? 1'bz : 1'b0);
assign CLK2  = (dut_vif.mult_chip_en === 1'b1) ? IOBUF_PAD[12] : (dut_vif.ext_clk_en === 1'b1) ? ext_hfclk : (dut_vif.gpio_pd_en[0] ? 1'bz : 1'b0);

wire clk_sel = (dut_vif.testmode_sel === 2'b11) ? UNLOCK       : (dut_vif.testmode_sel === 2'b00) ? ((dut_vif.ext_clk_en === 1'b0) ?  (dut_vif.gpio_pd_en[11] ? 1'bz : 1'b0) : 1'b1) : 1'bz;

wire [1:0] testmode_conn;
assign testmode_conn[1] = (dut_vif.testmode_sel[1:0] !== 2'b00) ? dut_vif.testmode_sel[1] : (dut_vif.gpio_pd_en[13] === 1'b1) ? 1'bz : dut_vif.testmode_sel[1];
assign testmode_conn[0] = (dut_vif.testmode_sel[1:0] !== 2'b00) ? dut_vif.testmode_sel[0] : (dut_vif.gpio_pd_en[12] === 1'b1) ? 1'bz : dut_vif.testmode_sel[0];

wire [1:0] testmode_conn_1;
assign testmode_conn_1[1] = (dut_vif.testmode_sel[1:0] !== 2'b00) ? dut_vif.testmode_sel[1] : (dut_vif.gpio_pd_en[13] === 1'b1) ? 1'bz : dut_vif.testmode_sel[1];
assign testmode_conn_1[0] = (dut_vif.testmode_sel[1:0] !== 2'b00) ? dut_vif.testmode_sel[0] : (dut_vif.gpio_pd_en[12] === 1'b1) ? 1'bz : dut_vif.testmode_sel[0];

wire [1:0] testmode_conn_2;
assign testmode_conn_2[1] = (dut_vif.testmode_sel[1:0] !== 2'b00) ? dut_vif.testmode_sel[1] : (dut_vif.gpio_pd_en[13] === 1'b1) ? 1'bz : dut_vif.testmode_sel[1];
assign testmode_conn_2[0] = (dut_vif.testmode_sel[1:0] !== 2'b00) ? dut_vif.testmode_sel[0] : (dut_vif.gpio_pd_en[12] === 1'b1) ? 1'bz : dut_vif.testmode_sel[0];

// Connecting power from PMU to PADs
`ifndef MIX_SIM_EN 
  assign VDD_DIG    = `ANA_TOP.PMU_SW.DVDD;
  assign VDD_DIG_S1 = `ANA_TOP_S1.PMU_SW.DVDD;
  assign VDD_DIG_S2 = `ANA_TOP_S2.PMU_SW.DVDD;
`else
//  assign VDD_DIG    = `ANA_TOP.VDD_DIG;
//  assign VDD_DIG_S1 = `ANA_TOP_S1.VDD_DIG;
//  assign VDD_DIG_S2 = `ANA_TOP_S2.VDD_DIG;
`endif

//assign VPP = dut_vif.VPP;
//assign VPP_S1 = (dut_vif.mult_chip_en === 1'b1) ? VPP : 1'b0;
//assign VPP_S2 = (dut_vif.mult_chip_en === 1'b1) ? VPP : 1'b0;

wire [2:0] int_clk_sel;
assign  int_clk_sel[0] = (dut_vif.mult_chip_en === 1'b0) ? clk_sel : (dut_vif.mult_chip_typ === 2'b00) ? 1'b1 : (dut_vif.mult_chip_typ === 2'b01) ? 1'b0 : (dut_vif.mult_chip_typ === 2'b10) ? 1'b1 : 1'bx;
assign  int_clk_sel[1] = (dut_vif.mult_chip_en === 1'b0) ? 1'b0 : 1'b1;
assign  int_clk_sel[2] = (dut_vif.mult_chip_en === 1'b0) ? 1'b0 : 1'b1;

Nanochap_ENS2 u_Nanochap_ENS2
(
        .CLKSEL                 (int_clk_sel[0]),
	.VPP		        (VPP),
	.VDDIO		        (1'b1),
	.VSSIO		        (1'b0),
	.VDD_DIG	        (VDD_DIG),	
	.VSS_DIG	        (1'b0),	
	.IOBUF_PAD		(IOBUF_PAD),
	.iopad_testmode0	(testmode_conn[0]),
	.iopad_testmode1	(testmode_conn[1]),
	.RESETn                 (iopad_resetn)
);

Nanochap_ENS2 u_Nanochap_ENS2_S1
(
        .CLKSEL                 (int_clk_sel[1]),
	.VPP		        (VPP_S1),
	.VDDIO		        (1'b1),	
	.VSSIO		        (1'b0),	
	.VDD_DIG	        (VDD_DIG_S1),		
	.VSS_DIG	        (1'b0),	
	.IOBUF_PAD		(IOBUF_PAD_S1),
	.iopad_testmode0	(testmode_conn_1[0]),
	.iopad_testmode1	(testmode_conn_1[1]),
	.RESETn                 (iopad_resetn & dut_vif.mult_chip_en & !dut_vif.swap_sdf_en) // This chip is not enabled when dut_vif.swap_sdf_en = 1'b1
);

Nanochap_ENS2 u_Nanochap_ENS2_S2
(
        .CLKSEL                 (int_clk_sel[2]),
	.VPP		        (VPP_S2),
	.VDDIO		        (1'b1),	
	.VSSIO		        (1'b0),	
	.VDD_DIG	        (VDD_DIG_S2),		
	.VSS_DIG	        (1'b0),	
	.IOBUF_PAD		(IOBUF_PAD_S2),
	.iopad_testmode0	(testmode_conn_2[0]),
	.iopad_testmode1	(testmode_conn_2[1]),
	.RESETn                 (iopad_resetn & dut_vif.mult_chip_en & dut_vif.swap_sdf_en) // This chip is not enabled when dut_vif.swap_sdf_en = 1'b0
);
`endif

// ==============================
// External HF_CLK Instatiation
// ==============================
`ifdef FPGA
`else
ext_hfosc u_ext_hfosc (
  .ext_hfclk(ext_hfclk),
  .ext_hfclk_sel(dut_vif.ext_clk_en)
);
`endif

// ==============================
// External Reset Generation
// ==============================
  initial
  begin
  ext_resetn = 0;
  #10000;
  ext_resetn = 1;
  end

// ==============================
// External Reset Generation
// ==============================
  initial
  begin
  UNLOCK = 0;
  #10000;
  end

// ==============================
// ALTF Decoder for SOC
// ==============================
assign gpio3_conn    = ((dut_vif.mult_chip_en === 1'b1) && (dut_vif.mult_chip_mode === 2'b10)) ? 1'b1 : spi_nss; // Checked 

assign gpio4_conn    = (dut_vif.altf_gpio_sel === 2'b00) ? spi_sck      : (dut_vif.altf_gpio_sel === 2'b01) ? spi_sck      : (dut_vif.altf_gpio_sel === 2'b10) ? spi_mosi     : (dut_vif.altf_gpio_sel === 2'b11) ? 1'bz         : 1'bx; // Checked
assign gpio5_conn    = (dut_vif.altf_gpio_sel === 2'b00) ? spi_mosi     : (dut_vif.altf_gpio_sel === 2'b01) ? 1'bz         : (dut_vif.altf_gpio_sel === 2'b10) ? 1'bz         : (dut_vif.altf_gpio_sel === 2'b11) ? spi_mosi     : 1'bx; // Checked

assign gpio6_conn    = (dut_vif.altf_gpio_sel === 2'b00) ? ((`SPIM_VIP.dual_en === 1'b0) ? 1'bz : (`SPIM_VIP.read_bus_en  === 1'b0) ? spi_miso : 1'bz)         : (dut_vif.altf_gpio_sel === 2'b01) ? spi_mosi     : (dut_vif.altf_gpio_sel === 2'b10) ? spi_sck      : (dut_vif.altf_gpio_sel === 2'b11) ? spi_sck      : 1'bx; // Checked

assign spi_miso_conn = (dut_vif.altf_gpio_sel === 2'b00) ? (((dut_vif.mult_chip_en === 1'b1) && (dut_vif.mult_chip_mode === 2'b10)) ? IOBUF_PAD_S1[6] : IOBUF_PAD[6]) : (dut_vif.altf_gpio_sel === 2'b01) ? IOBUF_PAD[5] : (dut_vif.altf_gpio_sel === 2'b10) ? IOBUF_PAD[5] : (dut_vif.altf_gpio_sel === 2'b11) ? IOBUF_PAD[4] : 1'bx; // Checked

// ==============================
// Connecting to PADs of SOC
// ==============================
assign scan_rst_n = 1'b1;
assign iopad_resetn = (dut_vif.testmode_sel === 2'b11) ? ext_resetn  : (dut_vif.testmode_sel === 2'b10) ? RESETb : (dut_vif.testmode_sel === 2'b01) ? scan_rst_n : (dut_vif.gpio_pu_en[14] === 1'b1) ? 1'bz : ext_resetn;               // Checked

// INT_OSC_OUT_EN
assign IOBUF_PAD[13]= ((dut_vif.testmode_sel === 2'b00) || (dut_vif.testmode_sel === 2'b10)) ? ((dut_vif.mult_chip_en === 1'b1) ? 1'b1 : 1'bz) : 1'bz;
// HFOSC_OUT
assign IOBUF_PAD[12]= 1'bz;
// INT3
assign IOBUF_PAD[11]= 1'bz;
// INT2
assign IOBUF_PAD[10]= 1'bz;
// INT1
assign IOBUF_PAD[9]= 1'bz;
// INTB
assign IOBUF_PAD[8] =  (dut_vif.testmode_sel === 2'b11) ? 1'bz : (dut_vif.testmode_sel === 2'b10) ? 1'bz   :   (dut_vif.testmode_sel === 2'b01) ? 1'bz                : 1'bz;                // Checked
// DAISY_IN
assign IOBUF_PAD[7] =  (dut_vif.testmode_sel === 2'b11) ? 1'bz : (dut_vif.testmode_sel === 2'b10) ? 1'bz   :   (dut_vif.testmode_sel === 2'b01) ? 1'bz : (dut_vif.daisy_en === 1'b1) ? IOBUF_PAD_S1[6] : 1'bz;                // Checked
// MISO
assign IOBUF_PAD[6] =  (dut_vif.testmode_sel === 2'b11) ? 1'bz : (dut_vif.testmode_sel === 2'b10 && dut_vif.mult_chip_en === 1'b0) ? TDI    :   (dut_vif.testmode_sel === 2'b01) ? scan_in[3]          : gpio6_conn;          // Checked
// MOSI
assign IOBUF_PAD[5] =  (dut_vif.testmode_sel === 2'b11) ? 1'bz : (dut_vif.testmode_sel === 2'b10 && dut_vif.mult_chip_en === 1'b0) ? STROBE :   (dut_vif.testmode_sel === 2'b01) ? scan_in[2]          : ((`SPIM_VIP.dual_en === 1'b0) ? gpio5_conn : (`SPIM_VIP.read_bus_en  === 1'b0) ? gpio5_conn : 1'bz);          // Checked mosi
// SCLK
assign IOBUF_PAD[4] =  (dut_vif.testmode_sel === 2'b11) ? 1'bz : (dut_vif.testmode_sel === 2'b10) ? 1'bz   :   (dut_vif.testmode_sel === 2'b01) ? scan_in[1]          : gpio4_conn;          // Checked
// NSS
assign IOBUF_PAD[3] =  (dut_vif.testmode_sel === 2'b11) ? 1'bz : (dut_vif.testmode_sel === 2'b10) ? 1'bz   :   (dut_vif.testmode_sel === 2'b01) ? scan_in[0]          : gpio3_conn;          // Checked  
// CPHA
assign IOBUF_PAD[2] =  (dut_vif.testmode_sel === 2'b11) ? 1'bz : (dut_vif.testmode_sel === 2'b10) ? 1'bz   :   (dut_vif.testmode_sel === 2'b01) ? scan_compression_in : ((dut_vif.spimode_sel[0] === 1'b1) ? IOBUF_CPHA : (dut_vif.gpio_pd_en[2] ? 1'bz : 1'b0));          // Checked
// CPOLn
assign IOBUF_PAD[1] =  (dut_vif.testmode_sel === 2'b11) ? 1'bz : (dut_vif.testmode_sel === 2'b10) ? 1'bz   :   (dut_vif.testmode_sel === 2'b01) ? scan_en             : ((dut_vif.spimode_sel[1] === 1'b1) ?IOBUF_CPOLn : (dut_vif.gpio_pd_en[1] ? 1'bz : 1'b0));         // Checked
// CLKSEL
assign IOBUF_PAD[0] =  (dut_vif.testmode_sel === 2'b11) ? ext_hfclk : (dut_vif.testmode_sel === 2'b10 && dut_vif.mult_chip_en === 1'b0) ? TCK : (dut_vif.testmode_sel === 2'b01) ? scan_clk            : CLK0;                 // Checked

assign spi_mosi     = (dut_vif.testmode_sel !== 2'b00) ? 1'bz             : (`SPIM_VIP.dual_en === 1'b0) ? 1'bz : (`SPIM_VIP.read_bus_en  === 1'b0) ? 1'bz : IOBUF_PAD[5];
assign spi_miso     = (dut_vif.testmode_sel === 2'b10) ? 1'bz             : (`SPIM_VIP.dual_en === 1'b0) ? spi_miso_conn : (`SPIM_VIP.read_bus_en  === 1'b0) ? 1'bz : spi_miso_conn; // Checked 
assign scan_out     = (dut_vif.testmode_sel === 2'b01) ? IOBUF_PAD[10:7]  : 4'bzzzz;       // Checked  
assign TDO_SEROUT   = (dut_vif.testmode_sel === 2'b10) ? IOBUF_PAD[3]     : 1'bz;          // Checked 
assign TDO          = (dut_vif.testmode_sel === 2'b10) ? IOBUF_PAD[4]     : 1'bz;          // Checked
assign WBUSY        = (dut_vif.testmode_sel === 2'b10) ? IOBUF_PAD[5]     : 1'bz;          // Checked
assign INTB         = (dut_vif.testmode_sel === 2'b00) ? IOBUF_PAD[8]     : 1'bz;          // Checked
assign VPP_EN       = (dut_vif.testmode_sel === 2'b10) ? IOBUF_PAD[7]     : (dut_vif.testmode_sel === 2'b00) ? IOBUF_PAD[8] : (dut_vif.testmode_sel === 2'b11) ? IOBUF_PAD[9] : 1'bz; // Checked
wire A2D_COMP0      = (dut_vif.testmode_sel === 2'b00) ? IOBUF_PAD[12]    : 1'bz;
wire A2D_COMP1      = (dut_vif.testmode_sel === 2'b00) ? IOBUF_PAD[13]    : 1'bz;
assign dut_vif.INTB = INTB;          // Checked

//assign IOBUF_PAD_S1[12:11] =  (dut_vif.mult_chip_en === 1'b1) ? IOBUF_PAD[12:11] : 0;
assign IOBUF_PAD_S1[11]    =  (dut_vif.mult_chip_en === 1'b1) ? IOBUF_PAD[11] : 0;
//assign IOBUF_PAD_S1[9]   =  IOBUF_PAD[9];
//assign IOBUF_PAD_S1[8]     =  (dut_vif.mult_chip_en === 1'b1) ? IOBUF_PAD[8] : 0;
assign IOBUF_PAD_S1[7]     =  (dut_vif.mult_chip_en === 1'b1 && dut_vif.testmode_sel === 2'b10) ? 1'bz : (dut_vif.daisy_en === 1'b1) ? !IOBUF_PAD[6] : 0; // Connected to inverter of MISO from Chip 1 to Chip 2!
assign IOBUF_PAD_S1[6]     =  (dut_vif.mult_chip_en === 1'b1) ? ((dut_vif.testmode_sel === 2'b10) ? TDI : 1'bz) : 0;
assign IOBUF_PAD_S1[5]     =  (dut_vif.mult_chip_en === 1'b1) ? ((dut_vif.testmode_sel === 2'b10) ? STROBE : IOBUF_PAD[5]) : 0;
assign IOBUF_PAD_S1[4]     =  (dut_vif.mult_chip_en === 1'b1) ? IOBUF_PAD[4] : 0;
assign IOBUF_PAD_S1[3]     =  (dut_vif.mult_chip_en === 1'b1) ? ((dut_vif.mult_chip_mode === 2'b10) ? spi_nss : (dut_vif.mult_chip_mode === 2'b01) ? 1'b1 : IOBUF_PAD[3]) : 1'b1;
assign IOBUF_PAD_S1[2]     =  (dut_vif.mult_chip_en === 1'b1) ? IOBUF_PAD[2] : 0;
assign IOBUF_PAD_S1[1]     =  (dut_vif.mult_chip_en === 1'b1) ? IOBUF_PAD[1] : 0;
assign IOBUF_PAD_S1[0]     =  (dut_vif.mult_chip_en === 1'b1) ? ((dut_vif.testmode_sel === 2'b10) ? TCK : CLK1) : 0;

//assign IOBUF_PAD_S2[12:11] =  (dut_vif.mult_chip_en === 1'b1) && (dut_vif.swap_sdf_en === 1'b1) ? IOBUF_PAD[12:11] : 0;
assign IOBUF_PAD_S2[11]    =  (dut_vif.mult_chip_en === 1'b1) && (dut_vif.swap_sdf_en === 1'b1) ? IOBUF_PAD[11] : 0;
//assign IOBUF_PAD_S2[9]   =  IOBUF_PAD[9];
//assign IOBUF_PAD_S2[8]     =  (dut_vif.mult_chip_en === 1'b1) && (dut_vif.swap_sdf_en === 1'b1) ? IOBUF_PAD[8] : 0;
//assign IOBUF_PAD_S2[7]     =  (dut_vif.mult_chip_en === 1'b1) && (dut_vif.swap_sdf_en === 1'b1) ? IOBUF_PAD[7] : 0;
//assign IOBUF_PAD_S2[6]     =  (dut_vif.mult_chip_en === 1'b1) && (dut_vif.swap_sdf_en === 1'b1) ? IOBUF_PAD[6] : 0;
assign IOBUF_PAD_S2[5]     =  (dut_vif.mult_chip_en === 1'b1) && (dut_vif.swap_sdf_en === 1'b1) ? IOBUF_PAD[5] : 0;
assign IOBUF_PAD_S2[4]     =  (dut_vif.mult_chip_en === 1'b1) && (dut_vif.swap_sdf_en === 1'b1) ? IOBUF_PAD[4] : 0;
assign IOBUF_PAD_S2[3]     =  (dut_vif.mult_chip_en === 1'b1) && (dut_vif.swap_sdf_en === 1'b1) ? IOBUF_PAD[3] : 1'b1;
assign IOBUF_PAD_S2[2]     =  (dut_vif.mult_chip_en === 1'b1) && (dut_vif.swap_sdf_en === 1'b1) ? IOBUF_PAD[2] : 0;
assign IOBUF_PAD_S2[1]     =  (dut_vif.mult_chip_en === 1'b1) && (dut_vif.swap_sdf_en === 1'b1) ? IOBUF_PAD[1] : 0;
assign IOBUF_PAD_S2[0]     =  (dut_vif.mult_chip_en === 1'b1) && (dut_vif.swap_sdf_en === 1'b1) ? CLK2 : 0;

// ====================================
// WAVEFORM of master_chip & slave_chip
// ====================================
//assign master_chip_wave1  = (`ANA_TOP.D2A_DRIVERA_SOURCEA_CH1/* & `ANA_TOP.D2A_DRIVERA_AMP_EN_CH1*/)  ? `ANA_TOP.D2A_IDAC_DIN_CH1[11:0]  :
//                           ((`ANA_TOP.D2A_DRIVERA_SOURCEB_CH1/* & `ANA_TOP.D2A_DRIVERA_AMP_EN_CH1*/)  ? -`ANA_TOP.D2A_IDAC_DIN_CH1[11:0] : 0);
//assign master_chip_wave2  = (`ANA_TOP.D2A_DRIVERA_SOURCEA_CH2/* & `ANA_TOP.D2A_DRIVERA_AMP_EN_CH2*/)  ? `ANA_TOP.D2A_IDAC_DIN_CH2[11:0]  :
//                           ((`ANA_TOP.D2A_DRIVERA_SOURCEB_CH2/* & `ANA_TOP.D2A_DRIVERA_AMP_EN_CH2*/)  ? -`ANA_TOP.D2A_IDAC_DIN_CH2[11:0] : 0);
//
//assign slave_chip_wave1   = (dut_vif.swap_sdf_en === 1'b1) ? 
//                           (`ANA_TOP_S2.D2A_DRIVERA_SOURCEA_CH1/* & `ANA_TOP_S2.D2A_DRIVERA_AMP_EN_CH1*/) ? `ANA_TOP_S2.D2A_IDAC_DIN_CH1[11:0]  : ((`ANA_TOP_S2.D2A_DRIVERA_SOURCEB_CH1/* & `ANA_TOP_S2.D2A_DRIVERA_AMP_EN_CH1*/) ? -`ANA_TOP_S2.D2A_IDAC_DIN_CH1[11:0] : 0) : 
//                           (`ANA_TOP_S1.D2A_DRIVERA_SOURCEA_CH1/* & `ANA_TOP_S1.D2A_DRIVERA_AMP_EN_CH1*/) ? `ANA_TOP_S1.D2A_IDAC_DIN_CH1[11:0]  : ((`ANA_TOP_S1.D2A_DRIVERA_SOURCEB_CH1/* & `ANA_TOP_S1.D2A_DRIVERA_AMP_EN_CH1*/) ? -`ANA_TOP_S1.D2A_IDAC_DIN_CH1[11:0] : 0);
//assign slave_chip_wave2   = (dut_vif.swap_sdf_en === 1'b1) ? 
//                           (`ANA_TOP_S2.D2A_DRIVERA_SOURCEA_CH2/* & `ANA_TOP_S2.D2A_DRIVERA_AMP_EN_CH2*/) ? `ANA_TOP_S2.D2A_IDAC_DIN_CH2[11:0]  : ((`ANA_TOP_S2.D2A_DRIVERA_SOURCEB_CH2/* & `ANA_TOP_S2.D2A_DRIVERA_AMP_EN_CH2*/) ? -`ANA_TOP_S2.D2A_IDAC_DIN_CH2[11:0] : 0) :
//                           (`ANA_TOP_S1.D2A_DRIVERA_SOURCEA_CH2/* & `ANA_TOP_S1.D2A_DRIVERA_AMP_EN_CH2*/) ? `ANA_TOP_S1.D2A_IDAC_DIN_CH2[11:0]  : ((`ANA_TOP_S1.D2A_DRIVERA_SOURCEB_CH2/* & `ANA_TOP_S1.D2A_DRIVERA_AMP_EN_CH2*/) ? -`ANA_TOP_S1.D2A_IDAC_DIN_CH2[11:0] : 0);
//
assign chip_wave1_overlay = master_chip_wave1 + slave_chip_wave1;
assign chip_wave2_overlay = master_chip_wave2 + slave_chip_wave2;



// ==============================
// SDF Annotation to GATE SIM
// ==============================
initial begin

    `ifdef SDFANNOTATE_MIN
	//$display ("------Start sdf_annotate (MIN) --------\n");
        `ifdef POSTLAYOUT_PG 
           $sdf_annotate ({`POSTLAYOUT_NETLIST_ROOT,"/data/Nanochap_ENS2_S111_min.sdf"},`SOC_TOP, , "./sdf_annotate_min_postlayout_chip_0.log", "MINIMUM");
           $sdf_annotate ({`POSTLAYOUT_NETLIST_ROOT,"/data/Nanochap_ENS2_S111_min.sdf"},`SOC_TOP_S1, , "./sdf_annotate_min_postlayout_chip_1.log", "MINIMUM");
           $sdf_annotate ({`POSTLAYOUT_NETLIST_ROOT,"/data/Nanochap_ENS2_S111_max.sdf"},`SOC_TOP_S2, , "./sdf_annotate_max_postlayout_chip_2.log", "MAXIMUM");
         `elsif POSTSCAN_PG
           $sdf_annotate ({`POSTSCAN_NETLIST_ROOT,"/data/synthesis_postscan_dct.BUD\=yes_sdf/Nanochap_ENS2.postscan_dct_S111_min.sdfv3"} ,`SOC_TOP, ,"./sdf_annotate_min_postscan_chip_0.log", "MINIMUM");
           $sdf_annotate ({`POSTSCAN_NETLIST_ROOT,"/data/synthesis_postscan_dct.BUD\=yes_sdf/Nanochap_ENS2.postscan_dct_S111_min.sdfv3"} ,`SOC_TOP_S1, ,"./sdf_annotate_min_postscan_chip_1.log", "MINIMUM");
           $sdf_annotate ({`POSTSCAN_NETLIST_ROOT,"/data/synthesis_postscan_dct.BUD\=yes_sdf/Nanochap_ENS2.postscan_dct_S111_max.sdfv3"} ,`SOC_TOP_S2, ,"./sdf_annotate_max_postscan_chip_2.log", "MAXIMUM");
	`endif

    `elsif SDFANNOTATE_MAX
    	//$display ("------Start sdf_annotate (MAX) --------\n");
	`ifdef POSTLAYOUT_PG
          $sdf_annotate ({`POSTLAYOUT_NETLIST_ROOT,"/data/Nanochap_ENS2_S111_max.sdf"},`SOC_TOP, , "./sdf_annotate_max_postlayout_chip_0.log", "MAXIMUM");
          $sdf_annotate ({`POSTLAYOUT_NETLIST_ROOT,"/data/Nanochap_ENS2_S111_max.sdf"},`SOC_TOP_S1, , "./sdf_annotate_max_postlayout_chip_1.log", "MAXIMUM");
          $sdf_annotate ({`POSTLAYOUT_NETLIST_ROOT,"/data/Nanochap_ENS2_S111_min.sdf"},`SOC_TOP_S2, , "./sdf_annotate_min_postlayout_chip_2.log", "MINIMUM");
        `elsif POSTSCAN_PG
          $sdf_annotate ({`POSTSCAN_NETLIST_ROOT,"/data/synthesis_postscan_dct.BUD\=yes_sdf/Nanochap_ENS2.postscan_dct_S111_max.sdfv3"} ,`SOC_TOP, ,"./sdf_annotate_max_postscan_chip_0.log" , "MAXIMUM");
          $sdf_annotate ({`POSTSCAN_NETLIST_ROOT,"/data/synthesis_postscan_dct.BUD\=yes_sdf/Nanochap_ENS2.postscan_dct_S111_max.sdfv3"} ,`SOC_TOP_S1, ,"./sdf_annotate_max_postscan_chip_1.log" , "MAXIMUM");
          $sdf_annotate ({`POSTSCAN_NETLIST_ROOT,"/data/synthesis_postscan_dct.BUD\=yes_sdf/Nanochap_ENS2.postscan_dct_S111_min.sdfv3"} ,`SOC_TOP_S2, ,"./sdf_annotate_min_postscan_chip_2.log" , "MINIMUM");
 	`endif

    `elsif SDFANNOTATE_TYP
 	//$display ("------Start sdf_annotate (TYP) --------\n");
	`ifdef POSTLAYOUT_PG
          $sdf_annotate ({`POSTLAYOUT_NETLIST_ROOT,"/data/Nanochap_ENS2_S111_typ.sdf"},`SOC_TOP, , "./sdf_annotate_typ_postlayout_chip_0.log");
          $sdf_annotate ({`POSTLAYOUT_NETLIST_ROOT,"/data/Nanochap_ENS2_S111_typ.sdf"},`SOC_TOP_S1, , "./sdf_annotate_typ_postlayout_chip_1.log");
          $sdf_annotate ({`POSTLAYOUT_NETLIST_ROOT,"/data/Nanochap_ENS2_S111_typ.sdf"},`SOC_TOP_S2, , "./sdf_annotate_typ_postlayout_chip_2.log");
        `elsif POSTSCAN_PG
          $sdf_annotate ({`POSTSCAN_NETLIST_ROOT,"/data/synthesis_postscan_pteco_sdf/Nanochap_ENS2.postscan_pteco.typ_functional_S111.sdfv3"} ,`SOC_TOP, ,"./sdf_annotate_typ_postscan_chip_0.log");
          $sdf_annotate ({`POSTSCAN_NETLIST_ROOT,"/data/synthesis_postscan_pteco_sdf/Nanochap_ENS2.postscan_pteco.typ_functional_S111.sdfv3"} ,`SOC_TOP_S1, ,"./sdf_annotate_typ_postscan_chip_1.log");
          $sdf_annotate ({`POSTSCAN_NETLIST_ROOT,"/data/synthesis_postscan_pteco_sdf/Nanochap_ENS2.postscan_pteco.typ_functional_S111.sdfv3"} ,`SOC_TOP_S2, ,"./sdf_annotate_typ_postscan_chip_2.log");
	`endif
    `endif
 end

`include "soc_dump_tb.svh"
 
// ==============================
// Power of otp
// ==============================
initial begin
`ifndef OTP_ENABLE
`else
/*
   force VDD_DIG = 1'b0;
   force VDD_DIG_S1 = 1'b0;
   force VDD_DIG_S2 = 1'b0;
   #1000ns;
   force VDD_DIG = 1'b1;
   force VDD_DIG_S1 = (dut_vif.mult_chip_en === 1'b1) ? 1'b1 : 1'b0;
   force VDD_DIG_S2 = (dut_vif.mult_chip_en === 1'b1) ? 1'b1 : 1'b0;
*/
`ifndef MIX_SIM_EN
   force `ANA_TOP.PMU_SW.CHIP_EN = 1'b0;
   force `ANA_TOP_S1.PMU_SW.CHIP_EN = 1'b0;
   force `ANA_TOP_S2.PMU_SW.CHIP_EN = 1'b0;
   #`POWER_ON_TIME;
   force `ANA_TOP.PMU_SW.CHIP_EN = 1'b1;
   force `ANA_TOP_S1.PMU_SW.CHIP_EN = (dut_vif.mult_chip_en === 1'b1) ? 1'b1 : 1'b0;
   force `ANA_TOP_S2.PMU_SW.CHIP_EN = (dut_vif.mult_chip_en === 1'b1) ? 1'b1 : 1'b0;
`endif

`endif
end

`ifndef BAHAVIORAL
initial
  begin
    wait(dut_vif.testmode_sel === 2'b10); 
    force VPP = 1'b0;
    force VPP_S1 = 1'b0;
    force VPP_S2 = 1'b0;
    #20ns;
    release VPP;
    release VPP_S1;
    release VPP_S2; 
  end
`endif

`ifndef OTP_ENABLE
`else
// =======================================
// EMTC Model SPEC - Min PPROG Setup Time
// =======================================
wire  VDD_DIG_01;
assign VDD_DIG_01 = VDD_DIG;
assign #(dut_vif.otp_vpp_delay) VPP = (dut_vif.mult_master_inf_en == 1'b1) && ((VDD_DIG_01 === 1'b1) ? ((dut_vif.testmode_sel === 2'b00) ? ((dut_vif.pinmux_mode === 1'b1) ? 1'b0 : (dut_vif.otp_program_en === 1'b1) ? IOBUF_PAD[8] : 1'b0) :  (dut_vif.testmode_sel === 2'b10) ? (dut_vif.bist_vpp_pin_en === 1'b1 ? ((dut_vif.pinmux_mode === 1'b1) ? 1'b0 : IOBUF_PAD[7]) : VPP_BIST) : (dut_vif.testmode_sel === 2'b11) ? ((IOBUF_PAD[10:8] === 3'b000) ? IOBUF_PAD[9] & `SOC_TOP.CLKSEL : 0) : 0) : 0);

wire  VDD_DIG_S11;
assign VDD_DIG_S11 = VDD_DIG_S1;
assign #(dut_vif.otp_vpp_delay) VPP_S1 = (dut_vif.swap_sdf_en === 1'b1) ? 1'b0 : (dut_vif.mult_master_inf_en == 1'b0) && (((dut_vif.mult_chip_en === 1'b1) && (VDD_DIG_S11 === 1'b1)) ?((dut_vif.testmode_sel === 2'b00) ? ((dut_vif.pinmux_mode === 1'b1) ? 1'b0 : (dut_vif.otp_program_en === 1'b1) ? IOBUF_PAD_S1[8] : 1'b0) :  (dut_vif.testmode_sel === 2'b10) ? (dut_vif.bist_vpp_pin_en === 1'b1 ? ((dut_vif.pinmux_mode === 1'b1) ? 1'b0 : (VDD_DIG_S11 === 1'b1) ? IOBUF_PAD_S1[7] : 1'b0) : VPP_BIST) : (dut_vif.testmode_sel === 2'b11) ? ((IOBUF_PAD_S1[10:8] === 3'b000) ? IOBUF_PAD_S1[9] && `SOC_TOP_S1.CLKSEL : 0) : 0) : 0);

wire  VDD_DIG_S21;
assign VDD_DIG_S21 = VDD_DIG_S2;
assign #(dut_vif.otp_vpp_delay) VPP_S2 = (dut_vif.swap_sdf_en === 1'b0) ? 1'b0 : (dut_vif.mult_master_inf_en == 1'b0) && (((dut_vif.mult_chip_en === 1'b1) && (VDD_DIG_S21 === 1'b1)) ?((dut_vif.testmode_sel === 2'b00) ? ((dut_vif.pinmux_mode === 1'b1) ? 1'b0 : (dut_vif.otp_program_en === 1'b1) ? IOBUF_PAD_S2[8] : 1'b0) :  (dut_vif.testmode_sel === 2'b10) ? (dut_vif.bist_vpp_pin_en === 1'b1 ? ((dut_vif.pinmux_mode === 1'b1) ? 1'b0 : (VDD_DIG_S21 === 1'b1) ? IOBUF_PAD_S2[7] : 1'b0) : VPP_BIST) : (dut_vif.testmode_sel === 2'b11) ? ((IOBUF_PAD_S2[10:8] === 3'b000) ? IOBUF_PAD_S2[9] && `SOC_TOP_S2.CLKSEL : 0) : 0) : 0);

`endif

// ==============================
// PowerPin of SOC
// ==============================
initial begin
`ifdef POWER_PINS
   //force `ALWAYSON_RST_CTRL.test_se = 0;
`endif
end

endmodule

package math_pkg;

  //import dpi task      C Name = SV function name

  import "DPI" pure function real cos (input real rTheta);

  import "DPI" pure function real sin (input real rTheta);

  import "DPI" pure function real log (input real rVal);

  import "DPI" pure function real log10 (input real rVal);

endpackage : math_pkg

/*
module sine_wave(output real sine_out);

  import math_pkg::*;

 

  parameter  sampling_time = 5;

  const real pi = 3.1416;

  real       time_us, time_s ;

  bit        sampling_clock;

  real       freq = 20;

  real       offset = 2.5;

  real       ampl = 2.5;

 
  
  always sampling_clock = #(sampling_time) ~sampling_clock;

 

  always @(sampling_clock) begin

    time_us = $time/1000;

    time_s = time_us/1000000;

  end
  
  assign sine_out = offset + (ampl * sin(2*pi*freq*time_s));

  task sin_wavegen;
   
    input real   freq;
    input [7:0]  sample_point;
    input real   amplitude;   
    output[7:0]  point_data[128];   
 
    real sinewave_out;
    begin
      fork
        begin 
        period = 1/freq * 1000000; // us
        offset = amplitude;        
        sinewave_out = offset + (amplitude * sin(2*pi*freq*time_s));
        end
        begin
          wait(sinewave_out == offset);
          for(int i=0; i < sample_point; i++) begin
            #(period)us; 
            point_data[i] =  sinewave_out-/(2*amplitude)*256
          end 
        end
      join_any
    end

  endtask

endmodule
*/
