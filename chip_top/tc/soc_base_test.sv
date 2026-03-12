/*--------------------------------------------------------------------------------------
// Copyright 2021 Nanochap, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_base_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_base_test is base test class of SOC                                           
// Designer	: ddang@nanochap.com                                                                 
// Date		: 18-03-2024                                                                    
// Revision	: 0.1                                 
--------------------------------------------------------------------------------------*/
`ifndef SOC_BASE_TEST__SV

`define SOC_BASE_TEST__SV

`define TESTNAME soc_base_test
`define TESTCFG soc_base_test_cfg

`define SET_CFG_REG(REG) \
  top_test_cfg.reg_normal[`REG] = { \
    `REG, \
    `INIT_``REG, \
    `MASK_``REG, \
    `ACCESS_``REG \
  };

`define SET_CFG_WG_REG(REG) \
  top_test_cfg.reg_wavegen[`REG + `WAVEGEN_1_ADDR_BASE * i] = { \
    `REG + `WAVEGEN_1_ADDR_BASE * i, \
    `INIT_``REG, \
    `MASK_``REG, \
    `ACCESS_``REG \
  };

// ===================================================================
// Register Define Declaration
// ===================================================================

`define SOC_PMU_REG                                  8'h01  // Daniel Dang checked on 06-Mar-2026          
`define INIT_SOC_PMU_REG                             8'h01
`define MASK_SOC_PMU_REG                             8'hFF
`define ACCESS_SOC_PMU_REG                           16'h07 // 00: RW1C, 1: Write Only, 2: Read Only, 3: RW, 2'bxx: reserved
`define REG0 SOC_PMU_REG

`define SOC_CLK_CTRL_REG                             8'h02 // Daniel Dang checked on 06-Mar-2026
`define INIT_SOC_CLK_CTRL_REG                        8'h30
`define MASK_SOC_CLK_CTRL_REG                        8'hFF
`define ACCESS_SOC_CLK_CTRL_REG                      16'h07 // RW
`define REG1 SOC_CLK_CTRL_REG

`define SOC_WAVEGEN_GLOBAL_REG                       8'h03 // Daniel Dang checked on 06-Mar-2026
`define INIT_SOC_WAVEGEN_GLOBAL_REG                  8'h00
`define MASK_SOC_WAVEGEN_GLOBAL_REG                  8'h07
`define ACCESS_SOC_WAVEGEN_GLOBAL_REG                16'h07 // RW
`define REG2 SOC_WAVEGEN_GLOBAL_REG

`define SOC_ANAC_CTRL_REG                            8'h04 // Daniel Dang checked on 06-Mar-2026
`define INIT_SOC_ANAC_CTRL_REG                       8'h00 
`define MASK_SOC_ANAC_CTRL_REG                       8'h0F
`define ACCESS_SOC_ANAC_CTRL_REG                     16'h07 // RW
`define REG3 SOC_ANAC_CTRL_REG

`define SOC_PMU_REG1                                 8'h05 // Daniel Dang checked on 06-Mar-2026
`define INIT_SOC_PMU_REG1                            8'h02
`define MASK_SOC_PMU_REG1                            8'h03
`define ACCESS_SOC_PMU_REG1                          16'h03
`define REG4 SOC_PMU_REG1

`define SOC_OUT_CLK_SEL_REG                          8'h06 
`define INIT_SOC_OUT_CLK_SEL_REG                     8'h00
`define MASK_SOC_OUT_CLK_SEL_REG                     8'h01
`define ACCESS_SOC_OUT_CLK_SEL_REG                   16'h07
`define REG5 SOC_OUT_CLK_SEL_REG

`define SOC_OTP_DEBUG_1_REG                          8'h0A
`define INIT_SOC_OTP_DEBUG_1_REG                     8'h00 
`define MASK_SOC_OTP_DEBUG_1_REG                     8'hFF
`define ACCESS_SOC_OTP_DEBUG_1_REG                   16'h02 // Read only
`define REG6 SOC_OTP_DEBUG_1_REG

`define SOC_OTP_DEBUG_2_REG                          8'h0B
`define INIT_SOC_OTP_DEBUG_2_REG                     8'h00 
`define MASK_SOC_OTP_DEBUG_2_REG                     8'h01
`define ACCESS_SOC_OTP_DEBUG_2_REG                   16'h02 // Read only
`define REG7 SOC_OTP_DEBUG_2_REG

`define SOC_OTP_TRIM_0_REG                           8'h0C
`define INIT_SOC_OTP_TRIM_0_REG                      8'h00 
`define INIT_RELOAD_SOC_OTP_TRIM_1_REG               8'h5A
`define MASK_SOC_OTP_TRIM_0_REG                      8'hFF
`define ACCESS_SOC_OTP_TRIM_0_REG                    16'h07 // RW
`define REG8 SOC_OTP_TRIM_0_REG

`define SOC_OTP_TRIM_1_REG                           8'h0D
`define INIT_SOC_OTP_TRIM_1_REG                      8'h00 
`define INIT_RELOAD_SOC_OTP_TRIM_1_REG               8'h00
`define MASK_SOC_OTP_TRIM_1_REG                      8'hFF
`define ACCESS_SOC_OTP_TRIM_1_REG                    16'h07 // RW
`define REG9 SOC_OTP_TRIM_1_REG

`define SOC_OTP_TRIM_2_REG                           8'h0E
`define INIT_SOC_OTP_TRIM_2_REG                      8'h00 
`define INIT_RELOAD_SOC_OTP_TRIM_2_REG               8'h00 // RW
`define MASK_SOC_OTP_TRIM_2_REG                      8'hFF
`define ACCESS_SOC_OTP_TRIM_2_REG                    16'h07
`define REG10 SOC_OTP_TRIM_2_REG

`define SOC_OTP_TRIM_3_REG                           8'h0F
`define INIT_SOC_OTP_TRIM_3_REG                      8'h00 // RW
`define INIT_RELOAD_SOC_OTP_TRIM_3_REG               8'h00 // RW
`define MASK_SOC_OTP_TRIM_3_REG                      8'hFF
`define ACCESS_SOC_OTP_TRIM_3_REG                    16'h07
`define REG11 SOC_OTP_TRIM_3_REG

`define SOC_OTP_TRIM_4_REG                           8'h10
`define INIT_SOC_OTP_TRIM_4_REG                      8'h00 // RW
`define INIT_RELOAD_SOC_OTP_TRIM_4_REG               8'h40 // RW
`define MASK_SOC_OTP_TRIM_4_REG                      8'hFF
`define ACCESS_SOC_OTP_TRIM_4_REG                    16'h07
`define REG12 SOC_OTP_TRIM_4_REG

`define SOC_OTP_TRIM_5_REG                           8'h11
`define INIT_SOC_OTP_TRIM_5_REG                      8'h00 // RW
`define INIT_RELOAD_SOC_OTP_TRIM_5_REG               8'h00 // RW
`define MASK_SOC_OTP_TRIM_5_REG                      8'hFF
`define ACCESS_SOC_OTP_TRIM_5_REG                    16'h07
`define REG13 SOC_OTP_TRIM_5_REG

`define SOC_OTP_TRIM_6_REG                           8'h12
`define INIT_SOC_OTP_TRIM_6_REG                      8'h00 // RW
`define INIT_RELOAD_SOC_OTP_TRIM_6_REG               8'h00 // RW
`define MASK_SOC_OTP_TRIM_6_REG                      8'hFF
`define ACCESS_SOC_OTP_TRIM_6_REG                    16'h07
`define REG14 SOC_OTP_TRIM_6_REG

`define SOC_OTP_TRIM_7_REG                           8'h13
`define INIT_SOC_OTP_TRIM_7_REG                      8'h00 // RW
`define INIT_RELOAD_SOC_OTP_TRIM_7_REG               8'h00 // RW
`define MASK_SOC_OTP_TRIM_7_REG                      8'hFF 
`define ACCESS_SOC_OTP_TRIM_7_REG                    16'h07 
`define REG15 SOC_OTP_TRIM_7_REG

`define SOC_OTP_TRIM_8_REG                           8'h14
`define INIT_SOC_OTP_TRIM_8_REG                      8'h00 // RW
`define INIT_RELOAD_SOC_OTP_TRIM_8_REG               8'h00 // RW
`define MASK_SOC_OTP_TRIM_8_REG                      8'hFF
`define ACCESS_SOC_OTP_TRIM_8_REG                    16'h07
`define REG16 SOC_OTP_TRIM_8_REG

`define SOC_OTP_UNLOCK_REG                           8'h15
`define INIT_SOC_OTP_UNLOCK_REG                      8'h00 // RW
`define MASK_SOC_OTP_UNLOCK_REG                      8'hFF
`define ACCESS_SOC_OTP_UNLOCK_REG                    16'h03
`define REG17 SOC_OTP_UNLOCK_REG

`define SOC_OTP_DATA_REG                             8'h16
`define INIT_SOC_OTP_DATA_REG                        8'h00 // RW
`define MASK_SOC_OTP_DATA_REG                        8'hFF
`define ACCESS_SOC_OTP_DATA_REG                      16'h07
`define REG18 SOC_OTP_DATA_REG

`define SOC_OTP_ADDR_REG                             8'h17
`define INIT_SOC_OTP_ADDR_REG                        8'h00 // RW
`define MASK_SOC_OTP_ADDR_REG                        8'hFF
`define ACCESS_SOC_OTP_ADDR_REG                      16'h07
`define REG19 SOC_OTP_ADDR_REG

`define SOC_OTP_MEM_DATA_REG                         8'h18
`define INIT_SOC_OTP_MEM_DATA_REG                    8'h00 // RW
`define MASK_SOC_OTP_MEM_DATA_REG                    8'hFF 
`define ACCESS_SOC_OTP_MEM_DATA_REG                  16'h02
`define REG20 SOC_OTP_MEM_DATA_REG

`define SOC_OTP_WAVEGEN_NUM_REG                         8'h1A
`define INIT_SOC_OTP_WAVEGEN_NUM_REG                    8'h00 // RW
`define MASK_SOC_OTP_WAVEGEN_NUM_REG                    8'h07 
`define ACCESS_SOC_OTP_WAVEGEN_NUM_REG                  16'h07
`define REG21 SOC_OTP_WAVEGEN_NUM_REG

`define SOC_GPIO_PU_CTRL_REG                       8'h20
`define INIT_SOC_GPIO_PU_CTRL_REG                  8'h00 // RW
`define MASK_SOC_GPIO_PU_CTRL_REG                  8'hFF
`define ACCESS_SOC_GPIO_PU_CTRL_REG                16'h07
`define REG22 SOC_GPIO_PU_CTRL_REG

`define SOC_GPIO_PD_CTRL_REG                         8'h21
`define INIT_SOC_GPIO_PD_CTRL_REG                    8'h1F // RW
`define MASK_SOC_GPIO_PD_CTRL_REG                    8'h1F
`define ACCESS_SOC_GPIO_PD_CTRL_REG                  16'h07
`define REG23 SOC_GPIO_PD_CTRL_REG

`define SOC_GPIO_SR_PDRV0_1_CTRL_REG                 8'h22
`define INIT_SOC_GPIO_SR_PDRV0_1_CTRL_REG            8'h00 // RW
`define MASK_SOC_GPIO_SR_PDRV0_1_CTRL_REG            8'h07
`define ACCESS_SOC_GPIO_SR_PDRV0_1_CTRL_REG          16'h07 
`define REG24 SOC_GPIO_SR_PDRV0_1_CTRL_REG

`define SOC_GPIO_COM_OUT_CTRL_REG                    8'h23
`define INIT_SOC_GPIO_COM_OUT_CTRL_REG               8'h00 // RW
`define MASK_SOC_GPIO_COM_OUT_CTRL_REG               8'h07
`define ACCESS_SOC_GPIO_COM_OUT_CTRL_REG             16'h07
`define REG25 SOC_GPIO_COM_OUT_CTRL_REG

/*
`define SOC_LEAD_OFF_CTRL_REG                        8'h26
`define INIT_SOC_LEAD_OFF_CTRL_REG                   8'h00 // RW
`define MASK_SOC_LEAD_OFF_CTRL_REG                   8'h7F
`define ACCESS_SOC_LEAD_OFF_CTRL_REG                 16'h03   
`define REG26 SOC_LEAD_OFF_CTRL_REG

`define SOC_RESERVED_REG                             8'h27
`define INIT_SOC_RESERVED_REG                        8'h00 // RW
`define MASK_SOC_RESERVED_REG                        8'hFF 
`define ACCESS_SOC_RESERVED_REG                      16'h07
`define REG27 SOC_RESERVED_REG

`define SOC_LEAD_OFF_INT_REG                         8'h28
`define INIT_SOC_LEAD_OFF_INT_REG                    8'h00 // RW
`define MASK_SOC_LEAD_OFF_INT_REG                    8'h7D 
`define ACCESS_SOC_LEAD_OFF_INT_REG                  16'h03
`define REG28 SOC_LEAD_OFF_INT_REG

`define SOC_LEAD_OFF_CH0_COUNTER_TH_TGT_0_REG        8'h29
`define INIT_SOC_LEAD_OFF_CH0_COUNTER_TH_TGT_0_REG   8'h00 // RW
`define MASK_SOC_LEAD_OFF_CH0_COUNTER_TH_TGT_0_REG   8'hFF
`define ACCESS_SOC_LEAD_OFF_CH0_COUNTER_TH_TGT_0_REG 16'h07  
`define REG29 SOC_LEAD_OFF_CH0_COUNTER_TH_TGT_0_REG

`define SOC_LEAD_OFF_CH0_COUNTER_TH_TGT_1_REG        8'h2A
`define INIT_SOC_LEAD_OFF_CH0_COUNTER_TH_TGT_1_REG   8'h00 // RW
`define MASK_SOC_LEAD_OFF_CH0_COUNTER_TH_TGT_1_REG   8'hFF
`define ACCESS_SOC_LEAD_OFF_CH0_COUNTER_TH_TGT_1_REG 16'h07
`define REG30 SOC_LEAD_OFF_CH0_COUNTER_TH_TGT_1_REG

`define SOC_LEAD_OFF_CH0_COUNTER_TH_TGT_2_REG        8'h2B
`define INIT_SOC_LEAD_OFF_CH0_COUNTER_TH_TGT_2_REG   8'h00 // RW
`define MASK_SOC_LEAD_OFF_CH0_COUNTER_TH_TGT_2_REG   8'hFF 
`define ACCESS_SOC_LEAD_OFF_CH0_COUNTER_TH_TGT_2_REG 16'h07
`define REG31 SOC_LEAD_OFF_CH0_COUNTER_TH_TGT_2_REG

`define SOC_LEAD_OFF_CH0_COUNTER_TH_TGT_3_REG        8'h2C
`define INIT_SOC_LEAD_OFF_CH0_COUNTER_TH_TGT_3_REG   8'h00 // RW
`define MASK_SOC_LEAD_OFF_CH0_COUNTER_TH_TGT_3_REG   8'hFF
`define ACCESS_SOC_LEAD_OFF_CH0_COUNTER_TH_TGT_3_REG 16'h07
`define REG32 SOC_LEAD_OFF_CH0_COUNTER_TH_TGT_3_REG

`define SOC_LEAD_OFF_CH0_TIMER_CNT_TGT_0_REG         8'h2D
`define INIT_SOC_LEAD_OFF_CH0_TIMER_CNT_TGT_0_REG    8'h00 // RW
`define MASK_SOC_LEAD_OFF_CH0_TIMER_CNT_TGT_0_REG    8'hFF
`define ACCESS_SOC_LEAD_OFF_CH0_TIMER_CNT_TGT_0_REG  16'h07
`define REG33 SOC_LEAD_OFF_CH0_TIMER_CNT_TGT_0_REG

`define SOC_LEAD_OFF_CH0_TIMER_CNT_TGT_1_REG                   8'h2E
`define INIT_SOC_LEAD_OFF_CH0_TIMER_CNT_TGT_1_REG              8'h00 // RW
`define MASK_SOC_LEAD_OFF_CH0_TIMER_CNT_TGT_1_REG              8'hFF
`define ACCESS_SOC_LEAD_OFF_CH0_TIMER_CNT_TGT_1_REG            16'h07
`define REG34 SOC_LEAD_OFF_CH0_TIMER_CNT_TGT_1_REG

`define SOC_LEAD_OFF_CH0_TIMER_CNT_TGT_2_REG                   8'h2F
`define INIT_SOC_LEAD_OFF_CH0_TIMER_CNT_TGT_2_REG              8'h00 // RW
`define MASK_SOC_LEAD_OFF_CH0_TIMER_CNT_TGT_2_REG              8'hFF
`define ACCESS_SOC_LEAD_OFF_CH0_TIMER_CNT_TGT_2_REG            16'h07 
`define REG35 SOC_LEAD_OFF_CH0_TIMER_CNT_TGT_2_REG

`define SOC_LEAD_OFF_CH0_TIMER_CNT_TGT_3_REG                   8'h30
`define INIT_SOC_LEAD_OFF_CH0_TIMER_CNT_TGT_3_REG              8'h00 // RW
`define MASK_SOC_LEAD_OFF_CH0_TIMER_CNT_TGT_3_REG              8'hFF 
`define ACCESS_SOC_LEAD_OFF_CH0_TIMER_CNT_TGT_3_REG            16'h07  
`define REG36 SOC_LEAD_OFF_CH0_TIMER_CNT_TGT_3_REG

`define SOC_LEAD_OFF_BLK_SLCT_REG                   8'h31
`define INIT_SOC_LEAD_OFF_BLK_SLCT_REG              8'h00 // RW
`define MASK_SOC_LEAD_OFF_BLK_SLCT_REG              8'h0F 
`define ACCESS_SOC_LEAD_OFF_BLK_SLCT_REG            16'h07
`define REG37 SOC_LEAD_OFF_BLK_SLCT_REG

`define SOC_LEAD_OFF_DAC_EN_REG                   8'h32
`define INIT_SOC_LEAD_OFF_DAC_EN_REG              8'h00 // RW
`define MASK_SOC_LEAD_OFF_DAC_EN_REG              8'hFF 
`define ACCESS_SOC_LEAD_OFF_DAC_EN_REG            16'h07
`define REG38 SOC_LEAD_OFF_DAC_EN_REG

`define SOC_LEAD_OFF_STOP_EN_REG                   8'h33
`define INIT_SOC_LEAD_OFF_STOP_EN_REG              8'h00 // RW
`define MASK_SOC_LEAD_OFF_STOP_EN_REG              8'hFF 
`define ACCESS_SOC_LEAD_OFF_STOP_EN_REG            16'h07
`define REG39 SOC_LEAD_OFF_STOP_EN_REG

`define SOC_LEAD_OFF_INT_EN_REG                   8'h34
`define INIT_SOC_LEAD_OFF_INT_EN_REG              8'h00 // RW
`define MASK_SOC_LEAD_OFF_INT_EN_REG              8'hFF 
`define ACCESS_SOC_LEAD_OFF_INT_EN_REG            16'h07
`define REG40 SOC_LEAD_OFF_INT_EN_REG

`define SOC_LEAD_OFF_COMP_LOW_EN_REG                   8'h35
`define INIT_SOC_LEAD_OFF_COMP_LOW_EN_REG              8'h00 // RW
`define MASK_SOC_LEAD_OFF_COMP_LOW_EN_REG              8'hFF 
`define ACCESS_SOC_LEAD_OFF_COMP_LOW_EN_REG            16'h07
`define REG41 SOC_LEAD_OFF_COMP_LOW_EN_REG

`define SOC_LEAD_OFF_STOP_REG                   8'h36
`define INIT_SOC_LEAD_OFF_STOP_REG              8'h00 // RW
`define MASK_SOC_LEAD_OFF_STOP_REG              8'hFF 
`define ACCESS_SOC_LEAD_OFF_STOP_REG            16'h02
`define REG42 SOC_LEAD_OFF_STOP_REG

`define SOC_LEAD_OFF_ANA_REG                         8'h39
`define INIT_SOC_LEAD_OFF_ANA_REG                    8'h00 // RW
`define MASK_SOC_LEAD_OFF_ANA_REG                    8'hFF
`define ACCESS_SOC_LEAD_OFF_ANA_REG                  16'h02
`define REG43 SOC_LEAD_OFF_ANA_REG
*/

`define SOC_ANA_ENABLE_REG_0                         8'h40
`define INIT_SOC_ANA_ENABLE_REG_0                    8'h02 // RW
`define MASK_SOC_ANA_ENABLE_REG_0                    8'hFF  
`define ACCESS_SOC_ANA_ENABLE_REG_0                  16'h07  
`define REG44 SOC_ANA_ENABLE_REG_0

`define SOC_ANA_ENABLE_REG_1                         8'h41
`define INIT_SOC_ANA_ENABLE_REG_1                    8'h00 // RW
`define MASK_SOC_ANA_ENABLE_REG_1                    8'hFF     
`define ACCESS_SOC_ANA_ENABLE_REG_1                  16'h07
`define REG45 SOC_ANA_ENABLE_REG_1

`define SOC_ANA_ENABLE_REG_2                         8'h42
`define INIT_SOC_ANA_ENABLE_REG_2                    8'h00 // RW
`define MASK_SOC_ANA_ENABLE_REG_2                    8'hFF
`define ACCESS_SOC_ANA_ENABLE_REG_2                  16'h07
`define REG46 SOC_ANA_ENABLE_REG_2

`define SOC_ANA_ENABLE_REG_3                         8'h43
`define INIT_SOC_ANA_ENABLE_REG_3                    8'h00 // RW
`define MASK_SOC_ANA_ENABLE_REG_3                    8'hFF
`define ACCESS_SOC_ANA_ENABLE_REG_3                  16'h07
`define REG47 SOC_ANA_ENABLE_REG_3

`define SOC_ANA_GEN_1_REG                            8'h44
`define INIT_SOC_ANA_GEN_1_REG                       8'h04 // RW
`define MASK_SOC_ANA_GEN_1_REG                       8'hFF
`define ACCESS_SOC_ANA_GEN_1_REG                     16'h07
`define REG48 SOC_ANA_GEN_1_REG

`define SOC_ANA_GEN_2_REG                            8'h45
`define INIT_SOC_ANA_GEN_2_REG                       8'h00 // RW
`define MASK_SOC_ANA_GEN_2_REG                       8'hFF
`define ACCESS_SOC_ANA_GEN_2_REG                     16'h07
`define REG49 SOC_ANA_GEN_2_REG

`define SOC_ANA_GEN_3_REG                            8'h46
`define INIT_SOC_ANA_GEN_3_REG                       8'h00 // RW
`define MASK_SOC_ANA_GEN_3_REG                       8'hFF
`define ACCESS_SOC_ANA_GEN_3_REG                     16'h07
`define REG50 SOC_ANA_GEN_3_REG

`define SOC_ANA_GEN_4_REG                            8'h47
`define INIT_SOC_ANA_GEN_4_REG                       8'h00 // RW
`define MASK_SOC_ANA_GEN_4_REG                       8'hFF
`define ACCESS_SOC_ANA_GEN_4_REG                     16'h07
`define REG51 SOC_ANA_GEN_4_REG

`define SOC_ANA_GEN_5_REG                            8'h48
`define INIT_SOC_ANA_GEN_5_REG                       8'h00 // RW
`define MASK_SOC_ANA_GEN_5_REG                       8'hFF
`define ACCESS_SOC_ANA_GEN_5_REG                     16'h07
`define REG52 SOC_ANA_GEN_4_REG

`define SOC_ANA_GEN_6_REG                            8'h49
`define INIT_SOC_ANA_GEN_6_REG                       8'h00 // RW
`define MASK_SOC_ANA_GEN_6_REG                       8'hFF
`define ACCESS_SOC_ANA_GEN_6_REG                     16'h07
`define REG53 SOC_ANA_GEN_6_REG

`define SOC_ANA_GEN_7_REG                            8'h4A
`define INIT_SOC_ANA_GEN_7_REG                       8'h00 // RW
`define MASK_SOC_ANA_GEN_7_REG                       8'hFF
`define ACCESS_SOC_ANA_GEN_7_REG                     16'h07
`define REG54 SOC_ANA_GEN_7_REG

`define SOC_ANA_GEN_8_REG                            8'h4B
`define INIT_SOC_ANA_GEN_8_REG                       8'h00 // RW
`define MASK_SOC_ANA_GEN_8_REG                       8'hFF
`define ACCESS_SOC_ANA_GEN_8_REG                     16'h07
`define REG55 SOC_ANA_GEN_8_REG

`define SOC_ANA_GEN_9_REG                            8'h4C
`define INIT_SOC_ANA_GEN_9_REG                       8'h00 // RW
`define MASK_SOC_ANA_GEN_9_REG                       8'hFF
`define ACCESS_SOC_ANA_GEN_9_REG                     16'h07
`define REG56 SOC_ANA_GEN_9_REG

`define SOC_ANA_GEN_REG_0                            8'h4D
`define INIT_SOC_ANA_GEN_REG_0                       8'h06 // Read only
`define MASK_SOC_ANA_GEN_REG_0                       8'hFF
`define ACCESS_SOC_ANA_GEN_REG_0                     16'h02
`define REG57 SOC_ANA_GEN_REG_0

`define SOC_A2D_SPARE_RO_REG0                        8'h4E
`define INIT_SOC_A2D_SPARE_RO_REG0                   8'h00 // Read only
`define MASK_SOC_A2D_SPARE_RO_REG0                   8'hFF
`define ACCESS_SOC_A2D_SPARE_RO_REG0                 16'h02
`define REG58 SOC_A2D_SPARE_RO_REG0

`define SOC_ANA_LVD_INT_EN_REG                       8'h50 // Daniel Checked 23-12
`define INIT_SOC_ANA_LVD_INT_EN_REG                  8'h01 // RW
`define MASK_SOC_ANA_LVD_INT_EN_REG                  8'h01
`define ACCESS_SOC_ANA_LVD_INT_EN_REG                16'h07
`define REG59 SOC_ANA_LVD_INT_EN_REG

/*
`define SOC_ANA_COMP_INT_EN_REG                      8'h51 // Daniel Checked 23-12
`define INIT_SOC_ANA_COMP_INT_EN_REG                 8'hFF // RW
`define MASK_SOC_ANA_COMP_INT_EN_REG                 8'hFF
`define ACCESS_SOC_ANA_COMP_INT_EN_REG               16'h07
`define REG60 SOC_ANA_COMP_INT_EN_REG

`define SOC_ANA_COMP_INT_TRANS_EN_REG                8'h52 // Daniel Checked 23-12
`define INIT_SOC_ANA_COMP_INT_TRANS_EN_REG           8'h00 // RW
`define MASK_SOC_ANA_COMP_INT_TRANS_EN_REG           8'hFF
`define ACCESS_SOC_ANA_COMP_INT_TRANS_EN_REG         16'h07
`define REG61 SOC_ANA_COMP_INT_TRANS_EN_REG

`define SOC_ANA_INT_STOP_WAVEGEN_REG                 8'h53 // Daniel Checked 23-12
`define INIT_SOC_ANA_INT_STOP_WAVEGEN_REG            8'h00 // RW
`define MASK_SOC_ANA_INT_STOP_WAVEGEN_REG            8'hFF
`define ACCESS_SOC_ANA_INT_STOP_WAVEGEN_REG          16'h07
`define REG62 SOC_ANA_INT_STOP_WAVEGEN_REG

`define SOC_ANA_STIMU_INT_EN_REG                     8'h54 // Daniel Checked 23-12
`define INIT_SOC_ANA_STIMU_INT_EN_REG                8'h00 // RW
`define MASK_SOC_ANA_STIMU_INT_EN_REG                8'hFF
`define ACCESS_SOC_ANA_STIMU_INT_EN_REG              16'h07
`define REG63 SOC_ANA_STIMU_INT_EN_REG

`define SOC_ANA_STIMU_INT_DIG_EN_REG                 8'h55 // Daniel Checked 23-12
`define INIT_SOC_ANA_STIMU_INT_DIG_EN_REG            8'hFF // RW
`define MASK_SOC_ANA_STIMU_INT_DIG_EN_REG            8'hFF
`define ACCESS_SOC_ANA_STIMU_INT_DIG_EN_REG          16'h07
`define REG64 SOC_ANA_STIMU_INT_DIG_EN_REG

`define SOC_ANA_STIMU_INT_POL_EN_REG                 8'h56 // Daniel Checked 23-12
`define INIT_SOC_ANA_STIMU_INT_POL_EN_REG            8'h00 // RW
`define MASK_SOC_ANA_STIMU_INT_POL_EN_REG            8'hFF
`define ACCESS_SOC_ANA_STIMU_INT_POL_EN_REG          16'h07
`define REG65 SOC_ANA_STIMU_INT_POL_EN_REG

`define SOC_ANA_SHORT_BLOCK_SELECT_REG               8'h57 // Daniel Checked 23-12
`define INIT_SOC_ANA_SHORT_BLOCK_SELECT_REG          8'h00 // RW
`define MASK_SOC_ANA_SHORT_BLOCK_SELECT_REG          8'h0F
`define ACCESS_SOC_ANA_SHORT_BLOCK_SELECT_REG        16'h07
`define REG66 SOC_ANA_SHORT_BLOCK_SELECT_REG

`define SOC_ANA_STIM_CH_TIMER_CNT_TH00_REG          8'h58 // Daniel Checked 23-12 
`define INIT_SOC_ANA_STIM_CH_TIMER_CNT_TH00_REG     8'h00 // RW
`define MASK_SOC_ANA_STIM_CH_TIMER_CNT_TH00_REG     8'hFF 
`define ACCESS_SOC_ANA_STIM_CH_TIMER_CNT_TH00_REG   16'h07
`define REG67 SOC_ANA_STIM_CH_TIMER_CNT_TH00_REG

`define SOC_ANA_STIM_CH_TIMER_CNT_TH01_REG          8'h59 // Daniel Checked 23-12
`define INIT_SOC_ANA_STIM_CH_TIMER_CNT_TH01_REG     8'h00 // RW
`define MASK_SOC_ANA_STIM_CH_TIMER_CNT_TH01_REG     8'hFF
`define ACCESS_SOC_ANA_STIM_CH_TIMER_CNT_TH01_REG   16'h07
`define REG68 SOC_ANA_STIM_CH_TIMER_CNT_TH01_REG

`define SOC_ANA_STIM_CH_TIMER_CNT_TH02_REG          8'h5A // Daniel Checked 23-12
`define INIT_SOC_ANA_STIM_CH_TIMER_CNT_TH02_REG     8'h00 // RW
`define MASK_SOC_ANA_STIM_CH_TIMER_CNT_TH02_REG     8'hFF
`define ACCESS_SOC_ANA_STIM_CH_TIMER_CNT_TH02_REG   16'h07
`define REG69 SOC_ANA_STIM_CH_TIMER_CNT_TH02_REG

`define SOC_ANA_STIM_CH_TIMER_CNT_TH03_REG          8'h5B // Daniel Checked 23-12
`define INIT_SOC_ANA_STIM_CH_TIMER_CNT_TH03_REG     8'h00 // RW
`define MASK_SOC_ANA_STIM_CH_TIMER_CNT_TH03_REG     8'hFF
`define ACCESS_SOC_ANA_STIM_CH_TIMER_CNT_TH03_REG   16'h07
`define REG70 SOC_ANA_STIM_CH_TIMER_CNT_TH03_REG

`define SOC_ANA_STIM_CH_COUNTER_CNT_TH00_REG        8'h5C // Daniel Checked 23-12
`define INIT_SOC_ANA_STIM_CH_COUNTER_CNT_TH00_REG   8'h00 // RW
`define MASK_SOC_ANA_STIM_CH_COUNTER_CNT_TH00_REG   8'hFF
`define ACCESS_SOC_ANA_STIM_CH_COUNTER_CNT_TH00_REG 16'h07
`define REG71 SOC_ANA_STIM_CH_COUNTER_CNT_TH00_REG

`define SOC_ANA_STIM_CH_COUNTER_CNT_TH01_REG        8'h5D // Daniel Checked 23-12
`define INIT_SOC_ANA_STIM_CH_COUNTER_CNT_TH01_REG   8'h00 // RW
`define MASK_SOC_ANA_STIM_CH_COUNTER_CNT_TH01_REG   8'hFF
`define ACCESS_SOC_ANA_STIM_CH_COUNTER_CNT_TH01_REG 16'h07
`define REG72 SOC_ANA_STIM_CH_COUNTER_CNT_TH01_REG

`define SOC_ANA_STIM_CH_COUNTER_CNT_TH02_REG        8'h5E // Daniel Checked 23-12
`define INIT_SOC_ANA_STIM_CH_COUNTER_CNT_TH02_REG   8'h00 // RW
`define MASK_SOC_ANA_STIM_CH_COUNTER_CNT_TH02_REG   8'hFF
`define ACCESS_SOC_ANA_STIM_CH_COUNTER_CNT_TH02_REG 16'h07
`define REG73 SOC_ANA_STIM_CH_COUNTER_CNT_TH02_REG

`define SOC_ANA_STIM_CH_COUNTER_CNT_TH03_REG        8'h5F // Daniel Checked 23-12
`define INIT_SOC_ANA_STIM_CH_COUNTER_CNT_TH03_REG   8'h00 // RW
`define MASK_SOC_ANA_STIM_CH_COUNTER_CNT_TH03_REG   8'hFF
`define ACCESS_SOC_ANA_STIM_CH_COUNTER_CNT_TH03_REG 16'h07
`define REG74 SOC_ANA_STIM_CH_COUNTER_CNT_TH03_REG

`define SOC_ANA_INT_STIMU_STS_REG              8'h60  // Daniel Checked 23-12
`define INIT_SOC_ANA_INT_STIMU_STS_REG         8'h00       
`define MASK_SOC_ANA_INT_STIMU_STS_REG         8'hFF
`define ACCESS_SOC_ANA_INT_STIMU_STS_REG       16'h00 // RW1C
`define REG75 SOC_ANA_INT_STIMU_STS_REG

`define SOC_ANA_INT_COMP_STS_REG               8'h61  // Daniel Checked 23-12
`define INIT_SOC_ANA_INT_COMP_STS_REG          8'h00
`define MASK_SOC_ANA_INT_COMP_STS_REG          8'hFF
`define ACCESS_SOC_ANA_INT_COMP_STS_REG        16'h00 // RW1C
`define REG76 SOC_ANA_INT_COMP_STS_REG

`define SOC_ANA_INT_LVD_STS_REG                8'h62  // Daniel Checked 23-12
`define INIT_SOC_ANA_INT_LVD_STS_REG           8'h00
`define MASK_SOC_ANA_INT_LVD_STS_REG           8'h01
`define ACCESS_SOC_ANA_INT_LVD_STS_REG         16'h02 // Readonly
`define REG77 SOC_ANA_INT_LVD_STS_REG
*/

`define SOC_TSC_EN_REG_SEL_REG                 8'h6B  // Daniel Checked 23-12
`define INIT_SOC_TSC_EN_REG_SEL_REG            8'h00  
`define MASK_SOC_TSC_EN_REG_SEL_REG            8'hFF
`define ACCESS_SOC_TSC_EN_REG_SEL_REG          16'h07 // RW
`define REG78 SOC_TSC_EN_REG_SEL_REG

`define SOC_TSC_CTRL_REG                       8'h6C // Daniel Checked 23-12
`define INIT_SOC_TSC_CTRL_REG                  8'h00 
`define MASK_SOC_TSC_CTRL_REG                  8'h0F
`define ACCESS_SOC_TSC_CTRL_REG                16'h07 // RW
`define REG79 SOC_TSC_CTRL_REG

`define SOC_SMP_DURATION_REG                   8'h6D // Daniel Checked 23-12
`define INIT_SOC_SMP_DURATION_REG              8'h10 
`define MASK_SOC_SMP_DURATION_REG              8'hFF
`define ACCESS_SOC_SMP_DURATION_REG            16'h07 // RW
`define REG80 SOC_SMP_DURATION_REG

`define SOC_STABLE_BURATION_0_REG              8'h6E // Daniel Checked 23-12
`define INIT_SOC_STABLE_BURATION_0_REG         8'hFF 
`define MASK_SOC_STABLE_BURATION_0_REG         8'hFF
`define ACCESS_SOC_STABLE_BURATION_0_REG       16'h07 // RW
`define REG81 SOC_STABLE_BURATION_0_REG

`define SOC_STABLE_BURATION_1_REG              8'h6F // Daniel Checked 23-12
`define INIT_SOC_STABLE_BURATION_1_REG         8'h01
`define MASK_SOC_STABLE_BURATION_1_REG         8'h0F
`define ACCESS_SOC_STABLE_BURATION_1_REG       16'h07 // RW
`define REG82 SOC_STABLE_BURATION_1_REG

`define SOC_TSC_VDAC8B_DIN_CH1_REG             8'h70 // Daniel Checked 23-12
`define INIT_SOC_TSC_VDAC8B_DIN_CH1_REG        8'hFF
`define MASK_SOC_TSC_VDAC8B_DIN_CH1_REG        8'hFF
`define ACCESS_SOC_TSC_VDAC8B_DIN_CH1_REG      16'h07 // RW
`define REG83 SOC_TSC_VDAC8B_DIN_CH1_REG

`define SOC_TSC_INT_CTLR_REG                   8'h71 // Daniel Checked 23-12
`define INIT_SOC_TSC_INT_CTLR_REG              8'h00
`define MASK_SOC_TSC_INT_CTLR_REG              8'h03
`define ACCESS_SOC_TSC_INT_CTLR_REG            16'h07 // RW
`define REG84 SOC_TSC_INT_CTLR_REG

`define SOC_TSC_INT_STATUS_REG                 8'h72 // Daniel Checked 23-12
`define INIT_SOC_TSC_INT_STATUS_REG            8'h00 
`define MASK_SOC_TSC_INT_STATUS_REG            8'h01
`define ACCESS_SOC_TSC_INT_STATUS_REG          16'h00 // RW1C
`define REG85 SOC_TSC_INT_STATUS_REG

`define SOC_VDAC_NOR0_REG                      8'h73 // Daniel Checked 23-12
`define INIT_SOC_VDAC_NOR0_REG                 8'h00
`define MASK_SOC_VDAC_NOR0_REG                 8'hFF
`define ACCESS_SOC_VDAC_NOR0_REG               16'h02 // RO
`define REG86 SOC_VDAC_NOR0_REG

`define SOC_SMP_STS_REG                        8'h74 // Daniel Checked 23-12
`define INIT_SOC_SMP_STS_REG                   8'h00 
`define MASK_SOC_SMP_STS_REG                   8'hFF
`define ACCESS_SOC_SMP_STS_REG                 16'h02 // RO
`define REG87 SOC_SMP_STS_REG

`define SOC_GENERAL_INT_CTRL_REG                   8'h78 // Daniel Checked 23-12
`define INIT_SOC_GENERAL_INT_CTRL_REG              8'h04 
`define MASK_SOC_GENERAL_INT_CTRL_REG              8'h07
`define ACCESS_SOC_GENERAL_INT_CTRL_REG            16'h07 // RW
`define REG88 SOC_GENERAL_INT_CTRL_REG

`define SOC_GENERAL_INT_STS_1_REG                  8'h79 // Daniel Checked 23-12
`define INIT_SOC_GENERAL_INT_STS_1_REG             8'h00 
`define MASK_SOC_GENERAL_INT_STS_1_REG             8'h82
`define ACCESS_SOC_GENERAL_INT_STS_1_REG           16'h00 // RW1C
`define REG89 SOC_GENERAL_INT_STS_1_REG

`define SOC_GENERAL_INT_STS_2_REG                  8'h7A // Daniel Checked 23-12
`define INIT_SOC_GENERAL_INT_STS_2_REG             8'h00 
`define MASK_SOC_GENERAL_INT_STS_2_REG             8'hFF
`define ACCESS_SOC_GENERAL_INT_STS_2_REG           16'h00 // RW1C
`define REG90 SOC_GENERAL_INT_STS_2_REG

`define SOC_GENERAL_INT_STS_3_REG                  8'h7B // Daniel Checked 23-12
`define INIT_SOC_GENERAL_INT_STS_3_REG             8'h00 
`define MASK_SOC_GENERAL_INT_STS_3_REG             8'hFF
`define ACCESS_SOC_GENERAL_INT_STS_3_REG           16'h00 // RW1C
`define REG91 SOC_GENERAL_INT_STS_3_REG


`define SOC_GENERAL_INT_STS_4_REG                  8'h7C // Daniel Checked 23-12
`define INIT_SOC_GENERAL_INT_STS_4_REG             8'h00 
`define MASK_SOC_GENERAL_INT_STS_4_REG             8'hFF
`define ACCESS_SOC_GENERAL_INT_STS_4_REG           16'h00 // RW1C
`define REG92 SOC_GENERAL_INT_STS_4_REG

`define SOC_GENERAL_INT_STS_4_REG                  8'h7D // Daniel Checked 23-12
`define INIT_SOC_GENERAL_INT_STS_4_REG             8'h00 
`define MASK_SOC_GENERAL_INT_STS_4_REG             8'hFF
`define ACCESS_SOC_GENERAL_INT_STS_4_REG           16'h00 // RW1C
`define REG93 SOC_GENERAL_INT_STS_4_REG


`define SOC_ATM_HC_SEL                             8'h7E
`define INIT_SOC_ATM_HC_SEL                        8'h00
`define MASK_SOC_ATM_HC_SEL                        8'h03
`define ACCESS_SOC_ATM_HC_SEL                      16'h07 // RW
`define REG94 SOC_ATM_HC_SEL

/*
`define SOC_COUNTER_CNT_DBG_SEL_REG                 8'h80
`define INIT_SOC_COUNTER_CNT_DBG_SEL_REG            8'h00 // RW
`define MASK_SOC_COUNTER_CNT_DBG_SEL_REG            8'h03
`define ACCESS_SOC_COUNTER_CNT_DBG_SEL_REG          16'h07
`define REG94 SOC_COUNTER_CNT_DBG_SEL_REG

`define SOC_COUNTER_CNT_DBG_0_REG                 8'h81
`define INIT_SOC_COUNTER_CNT_DBG_0_REG            8'h00 // RW
`define MASK_SOC_COUNTER_CNT_DBG_0_REG            8'hFF
`define ACCESS_SOC_COUNTER_CNT_DBG_0_REG          16'h02
`define REG95 SOC_COUNTER_CNT_DBG_0_REG

`define SOC_COUNTER_CNT_DBG_1_REG                 8'h82
`define INIT_SOC_COUNTER_CNT_DBG_1_REG            8'h00 // RW
`define MASK_SOC_COUNTER_CNT_DBG_1_REG            8'hFF
`define ACCESS_SOC_COUNTER_CNT_DBG_1_REG          16'h02
`define REG96 SOC_COUNTER_CNT_DBG_1_REG

`define SOC_COUNTER_CNT_DBG_2_REG                 8'h83
`define INIT_SOC_COUNTER_CNT_DBG_2_REG            8'h00 // RW
`define MASK_SOC_COUNTER_CNT_DBG_2_REG            8'hFF
`define ACCESS_SOC_COUNTER_CNT_DBG_2_REG          16'h02
`define REG97 SOC_COUNTER_CNT_DBG_2_REG

`define SOC_COUNTER_CNT_DBG_3_REG                 8'h84
`define INIT_SOC_COUNTER_CNT_DBG_3_REG            8'h00 // RW
`define MASK_SOC_COUNTER_CNT_DBG_3_REG            8'hFF
`define ACCESS_SOC_COUNTER_CNT_DBG_3_REG          16'h02
`define REG98 SOC_COUNTER_CNT_DBG_3_REG

`define SOC_LEAD_OFF_CNT_DAC0_REG                        8'h85
`define INIT_SOC_LEAD_OFF_CNT_DAC0_REG                   8'h00
`define MASK_SOC_LEAD_OFF_CNT_DAC0_REG                   8'hFF
`define ACCESS_SOC_LEAD_OFF_CNT_DAC0_REG                 16'h02
`define REG99 SOC_LEAD_OFF_CNT_DAC0_REG
*/

`define SOC_OTP_TRIMS_DBG_SEL_REG                        8'h87
`define INIT_SOC_OTP_TRIMS_DBG_SEL_REG                   8'h00
`define MASK_SOC_OTP_TRIMS_DBG_SEL_REG                   8'h0F
`define ACCESS_SOC_OTP_TRIMS_DBG_SEL_REG                 16'h07
`define REG100 SOC_OTP_TRIMS_DBG_SEL_REG

`define SOC_OTP_TRIMS_DBG_DATA_REG                       8'h88
`define INIT_SOC_OTP_TRIMS_DBG_DATA_REG                  8'h00
`define MASK_SOC_OTP_TRIMS_DBG_DATA_REG                  8'hFF
`define ACCESS_SOC_OTP_TRIMS_DBG_DATA_REG                16'h02
`define REG101 SOC_OTP_TRIMS_DBG_DATA_REG

`define SOC_IMEAS_REG_0                        		 8'h90
`define INIT_SOC_IMEAS_REG_0                             8'h18
`define MASK_SOC_IMEAS_REG_0                             8'h9F
`define ACCESS_SOC_IMEAS_REG_0                           16'h03
`define REG102 SOC_IMEAS_REG_0

`define SOC_IMEAS_REG_1                        		 8'h91
`define INIT_SOC_IMEAS_REG_1                             8'h47
`define MASK_SOC_IMEAS_REG_1                             8'hFF
`define ACCESS_SOC_IMEAS_REG_1                           16'h03
`define REG103 SOC_IMEAS_REG_1

`define SOC_IMEAS_REG_2                        		 8'h92
`define INIT_SOC_IMEAS_REG_2                             8'h00
`define MASK_SOC_IMEAS_REG_2                             8'hFF
`define ACCESS_SOC_IMEAS_REG_2                           16'h03
`define REG104 SOC_IMEAS_REG_2

`define SOC_IMEAS_STABLE_TIME_0                   	 8'h93
`define INIT_SOC_IMEAS_STABLE_TIME_0                     8'h10
`define MASK_SOC_IMEAS_STABLE_TIME_0                     8'hFF
`define ACCESS_SOC_IMEAS_STABLE_TIME_0                   16'h03
`define REG105 SOC_IMEAS_STABLE_TIME_0

`define SOC_IMEAS_STABLE_TIME_1                        	 8'h94
`define INIT_SOC_IMEAS_STABLE_TIME_1                     8'h00
`define MASK_SOC_IMEAS_STABLE_TIME_1                     8'hFF
`define ACCESS_SOC_IMEAS_STABLE_TIME_1                   16'h03
`define REG106 SOC_IMEAS_STABLE_TIME_1

`define SOC_IMEAS_DATA_0                        	 8'h95
`define INIT_SOC_IMEAS_DATA_0                            8'h00
`define MASK_SOC_IMEAS_DATA_0                            8'hFF
`define ACCESS_SOC_IMEAS_DATA_0                          16'h02
`define REG107 SOC_IMEAS_DATA_0

`define SOC_IMEAS_DATA_1                        	 8'h96
`define INIT_SOC_IMEAS_DATA_1                            8'h00
`define MASK_SOC_IMEAS_DATA_1                            8'hFF
`define ACCESS_SOC_IMEAS_DATA_1                          16'h02
`define REG108 SOC_IMEAS_DATA_1

`define SOC_IMEAS_DATA_2                        	 8'h97
`define INIT_SOC_IMEAS_DATA_2                            8'h00
`define MASK_SOC_IMEAS_DATA_2                            8'hFF
`define ACCESS_SOC_IMEAS_DATA_2                          16'h02
`define REG109 SOC_IMEAS_DATA_2

`define SOC_IMEAS_DATA_3                        	 8'h98
`define INIT_SOC_IMEAS_DATA_3                            8'h00
`define MASK_SOC_IMEAS_DATA_3                            8'hFF
`define ACCESS_SOC_IMEAS_DATA_3                          16'h02
`define REG110 SOC_IMEAS_DATA_3

`define SOC_IMEAS_CTRL_REG                       	 8'h99
`define INIT_SOC_IMEAS_CTRL_REG                          8'h00
`define MASK_SOC_IMEAS_CTRL_REG                          8'hFF
`define ACCESS_SOC_IMEAS_CTRL_REG                        16'h03
`define REG111 SOC_IMEAS_CTRL_REG

`define SOC_IMEAS_EN_DIS_CH_LOW_REG                      8'h9A
`define INIT_SOC_IMEAS_EN_DIS_CH_LOW_REG                 8'h00
`define MASK_SOC_IMEAS_EN_DIS_CH_LOW_REG                 8'hFF
`define ACCESS_SOC_IMEAS_EN_DIS_CH_LOW_REG               16'h03
`define REG112 SOC_IMEAS_EN_DIS_CH_LOW_REG

`define SOC_IMEAS_EN_DIS_CH_HIGH_REG                     8'h9B
`define INIT_SOC_IMEAS_EN_DIS_CH_HIGH_REG                8'h00
`define MASK_SOC_IMEAS_EN_DIS_CH_HIGH_REG                8'hFF
`define ACCESS_SOC_IMEAS_EN_DIS_CH_HIGH_REG              16'h03
`define REG113 SOC_IMEAS_EN_DIS_CH_HIGH_REG       

`define SOC_FILTER_HPF_BP_L_REG                          8'hB1
`define INIT_SOC_FILTER_HPF_BP_L_REG                     8'hFF
`define MASK_SOC_FILTER_HPF_BP_L_REG                     8'hFF
`define ACCESS_SOC_FILTER_HPF_BP_L_REG                   16'h03
`define REG114 SOC_FILTER_HPF_BP_L_REG

`define SOC_FILTER_HPF_BP_H_REG                          8'hB2
`define INIT_SOC_FILTER_HPF_BP_H_REG                     8'hFF
`define MASK_SOC_FILTER_HPF_BP_H_REG                     8'hFF
`define ACCESS_SOC_FILTER_HPF_BP_H_REG                   16'h03
`define REG115 SOC_FILTER_HPF_BP_H_REG

`define SOC_FILTER_LPF_BP_L_REG                          8'hB3
`define INIT_SOC_FILTER_LPF_BP_L_REG                     8'hFF
`define MASK_SOC_FILTER_LPF_BP_L_REG                     8'hFF
`define ACCESS_SOC_FILTER_LPF_BP_L_REG                   16'h03
`define REG116 SOC_FILTER_LPF_BP_L_REG

`define SOC_FILTER_LPF_BP_H_REG                          8'hB4
`define INIT_SOC_FILTER_LPF_BP_H_REG                     8'hFF
`define MASK_SOC_FILTER_LPF_BP_H_REG                     8'hFF
`define ACCESS_SOC_FILTER_LPF_BP_H_REG                   16'h03
`define REG117 SOC_FILTER_LPF_BP_H_REG

`define SOC_FILTER_NOF_BP_L_REG                          8'hB5
`define INIT_SOC_FILTER_NOF_BP_L_REG                     8'hFF
`define MASK_SOC_FILTER_NOF_BP_L_REG                     8'hFF
`define ACCESS_SOC_FILTER_NOF_BP_L_REG                   16'h03
`define REG118 SOC_FILTER_NOF_BP_L_REG

`define SOC_FILTER_NOF_BP_H_REG                          8'hB6
`define INIT_SOC_FILTER_NOF_BP_H_REG                     8'hFF
`define MASK_SOC_FILTER_NOF_BP_H_REG                     8'hFF
`define ACCESS_SOC_FILTER_NOF_BP_H_REG                   16'h03
`define REG119 SOC_FILTER_NOF_BP_H_REG

`define SOC_FILTER_INT_CTRL_REG                          8'hB7
`define INIT_SOC_FILTER_INT_CTRL_REG                     8'h00
`define MASK_SOC_FILTER_INT_CTRL_REG                     8'h03
`define ACCESS_SOC_FILTER_INT_CTRL_REG                   16'h03
`define REG120 SOC_FILTER_INT_CTRL_REG

`define SOC_FILTER_INT_STS_REG                           8'hB8
`define INIT_SOC_FILTER_INT_STS_REG                      8'h00
`define MASK_SOC_FILTER_INT_STS_REG                      8'h01
`define ACCESS_SOC_FILTER_INT_STS_REG                    16'h0
`define REG121 SOC_FILTER_INT_STS_REG

`define SOC_FILTER_NOTCH_DATA_GONE_L_REG             8'hB9
`define INIT_SOC_FILTER_NOTCH_DATA_GONE_L_REG        8'h94
`define MASK_SOC_FILTER_NOTCH_DATA_GONE_L_REG        8'hFF
`define ACCESS_SOC_FILTER_NOTCH_DATA_GONE_L_REG      16'h03
`define REG122 SOC_FILTER_NOTCH_DATA_GONE_L_REG

`define SOC_FILTER_NOTCH_DATA_GONE_H_REG             8'hBA
`define INIT_SOC_FILTER_NOTCH_DATA_GONE_H_REG        8'h3A
`define MASK_SOC_FILTER_NOTCH_DATA_GONE_H_REG        8'hFF
`define ACCESS_SOC_FILTER_NOTCH_DATA_GONE_H_REG      16'h03
`define REG123 SOC_FILTER_NOTCH_DATA_GONE_H_REG

`define SOC_FILTER_LPF_COEFF_ADDR_REG                8'hBB
`define INIT_SOC_FILTER_LPF_COEFF_ADDR_REG           8'h00
`define MASK_SOC_FILTER_LPF_COEFF_ADDR_REG           8'hFF
`define ACCESS_SOC_FILTER_LPF_COEFF_ADDR_REG         16'h03
`define REG124 SOC_FILTER_LPF_COEFF_ADDR_REG

`define SOC_FILTER_LPF_COEFF_DATA1_REG  	     8'hBC
`define INIT_SOC_FILTER_LPF_COEFF_DATA1_REG          8'hF8
`define MASK_SOC_FILTER_LPF_COEFF_DATA1_REG          8'hFF
`define ACCESS_SOC_FILTER_LPF_COEFF_DATA1_REG        16'h03
`define REG125 SOC_FILTER_LPF_COEFF_DATA1_REG

`define SOC_FILTER_LPF_COEFF_DATA2_REG  	     8'hBD
`define INIT_SOC_FILTER_LPF_COEFF_DATA2_REG          8'hFF
`define MASK_SOC_FILTER_LPF_COEFF_DATA2_REG          8'hFF
`define ACCESS_SOC_FILTER_LPF_COEFF_DATA2_REG        16'h03
`define REG126 SOC_FILTER_LPF_COEFF_DATA2_REG

`define SOC_FILTER_LPF_COEFF_DATA3_REG  	     8'hBE
`define INIT_SOC_FILTER_LPF_COEFF_DATA3_REG          8'h03
`define MASK_SOC_FILTER_LPF_COEFF_DATA3_REG          8'h03
`define ACCESS_SOC_FILTER_LPF_COEFF_DATA3_REG        16'h03
`define REG127 SOC_FILTER_LPF_COEFF_DATA3_REG

`define WAVEGEN_0_ADDR_BASE                          8'h00
`define WAVEGEN_1_ADDR_BASE                          `WAVEGEN_0_ADDR_BASE + `WAVEGEN_DRIVER_OFFSET
`define WAVEGEN_2_ADDR_BASE                          `WAVEGEN_1_ADDR_BASE + `WAVEGEN_DRIVER_OFFSET
`define WAVEGEN_3_ADDR_BASE                          `WAVEGEN_2_ADDR_BASE + `WAVEGEN_DRIVER_OFFSET
`define WAVEGEN_4_ADDR_BASE                          `WAVEGEN_0_ADDR_BASE 
`define WAVEGEN_5_ADDR_BASE                          `WAVEGEN_0_ADDR_BASE + `WAVEGEN_DRIVER_OFFSET
`define WAVEGEN_6_ADDR_BASE                          `WAVEGEN_1_ADDR_BASE + `WAVEGEN_DRIVER_OFFSET
`define WAVEGEN_7_ADDR_BASE                          `WAVEGEN_2_ADDR_BASE + `WAVEGEN_DRIVER_OFFSET
`define WAVEGEN_8_ADDR_BASE                          `WAVEGEN_0_ADDR_BASE 
`define WAVEGEN_9_ADDR_BASE                          `WAVEGEN_0_ADDR_BASE + `WAVEGEN_DRIVER_OFFSET
`define WAVEGEN_10_ADDR_BASE                         `WAVEGEN_1_ADDR_BASE + `WAVEGEN_DRIVER_OFFSET
`define WAVEGEN_11_ADDR_BASE                         `WAVEGEN_2_ADDR_BASE + `WAVEGEN_DRIVER_OFFSET
`define WAVEGEN_12_ADDR_BASE                         `WAVEGEN_0_ADDR_BASE 
`define WAVEGEN_13_ADDR_BASE                         `WAVEGEN_0_ADDR_BASE + `WAVEGEN_DRIVER_OFFSET
`define WAVEGEN_14_ADDR_BASE                         `WAVEGEN_1_ADDR_BASE + `WAVEGEN_DRIVER_OFFSET
`define WAVEGEN_15_ADDR_BASE                         `WAVEGEN_2_ADDR_BASE + `WAVEGEN_DRIVER_OFFSET

`define REG_WG0 SOC_ADDR_WG_DRV_CONFIG_REG0
`define SOC_ADDR_WG_DRV_CONFIG_REG0                  8'h00 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_CONFIG_REG0             8'h00
`define MASK_SOC_ADDR_WG_DRV_CONFIG_REG0             8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_CONFIG_REG0           16'h07 

`define REG_WG1 SOC_ADDR_WG_DRV_CTRL_REG0
`define SOC_ADDR_WG_DRV_CTRL_REG0                    8'h01 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_CTRL_REG0               8'h00
`define MASK_SOC_ADDR_WG_DRV_CTRL_REG0               8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_CTRL_REG0             16'h07

`define REG_WG2 SOC_ADDR_WG_DRV_POINT_CONFIG
`define SOC_ADDR_WG_DRV_POINT_CONFIG                 8'h02 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_POINT_CONFIG            8'h40
`define MASK_SOC_ADDR_WG_DRV_POINT_CONFIG            8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_POINT_CONFIG          16'h07

`define REG_WG3 SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0
`define SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0            8'h03 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0       8'h00
`define MASK_SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0       8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_IN_WAVE_ADDR_REG0     16'h07

`define REG_WG4 SOC_ADDR_WG_DRV_IN_WAVE_REG01 
`define SOC_ADDR_WG_DRV_IN_WAVE_REG01                8'h04 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_IN_WAVE_REG01           8'h00
`define MASK_SOC_ADDR_WG_DRV_IN_WAVE_REG01           8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_IN_WAVE_REG01         16'h03

`define REG_WG5 SOC_ADDR_WG_DRV_REST_T_REG01
`define SOC_ADDR_WG_DRV_REST_T_REG01                 8'h05 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_REST_T_REG01            8'h00
`define MASK_SOC_ADDR_WG_DRV_REST_T_REG01            8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_REST_T_REG01          16'h07

`define REG_WG6 SOC_ADDR_WG_DRV_REST_T_REG02
`define SOC_ADDR_WG_DRV_REST_T_REG02                 8'h06 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_REST_T_REG02            8'h00
`define MASK_SOC_ADDR_WG_DRV_REST_T_REG02            8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_REST_T_REG02          16'h07

`define REG_WG7 SOC_ADDR_WG_DRV_SILENT_T_REG01
`define SOC_ADDR_WG_DRV_SILENT_T_REG01               8'h07 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_SILENT_T_REG01          8'h00
`define MASK_SOC_ADDR_WG_DRV_SILENT_T_REG01          8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_SILENT_T_REG01        16'h07

`define REG_WG8 SOC_ADDR_WG_DRV_SILENT_T_REG02
`define SOC_ADDR_WG_DRV_SILENT_T_REG02               8'h08 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_SILENT_T_REG02          8'h00
`define MASK_SOC_ADDR_WG_DRV_SILENT_T_REG02          8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_SILENT_T_REG02        16'h07

`define REG_WG9 SOC_ADDR_WG_DRV_SILENT_T_REG03
`define SOC_ADDR_WG_DRV_SILENT_T_REG03               8'h09 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_SILENT_T_REG03          8'h00
`define MASK_SOC_ADDR_WG_DRV_SILENT_T_REG03          8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_SILENT_T_REG03        16'h07

`define REG_WG10 SOC_ADDR_WG_DRV_SILENT_T_REG04
`define SOC_ADDR_WG_DRV_SILENT_T_REG04               8'h0A + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_SILENT_T_REG04          8'h00
`define MASK_SOC_ADDR_WG_DRV_SILENT_T_REG04          8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_SILENT_T_REG04        16'h07

`define REG_WG11 SOC_ADDR_WG_DRV_HLF_WAVE_PRD_REG01 
`define SOC_ADDR_WG_DRV_HLF_WAVE_PRD_REG01           8'h0B + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_HLF_WAVE_PRD_REG01      8'h00
`define MASK_SOC_ADDR_WG_DRV_HLF_WAVE_PRD_REG01      8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_HLF_WAVE_PRD_REG01    16'h07

`define REG_WG12 SOC_ADDR_WG_DRV_HLF_WAVE_PRD_REG02
`define SOC_ADDR_WG_DRV_HLF_WAVE_PRD_REG02           8'h0C + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_HLF_WAVE_PRD_REG02      8'h00
`define MASK_SOC_ADDR_WG_DRV_HLF_WAVE_PRD_REG02      8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_HLF_WAVE_PRD_REG02    16'h07

`define REG_WG13 SOC_ADDR_WG_DRV_NEG_HLF_WAVE_PRD_REG01
`define SOC_ADDR_WG_DRV_NEG_HLF_WAVE_PRD_REG01       8'h0D + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_NEG_HLF_WAVE_PRD_REG01  8'h00
`define MASK_SOC_ADDR_WG_DRV_NEG_HLF_WAVE_PRD_REG01  8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_NEG_HLF_WAVE_PRD_REG01 16'h07

`define REG_WG14 SOC_ADDR_WG_DRV_NEG_HLF_WAVE_PRD_REG02
`define SOC_ADDR_WG_DRV_NEG_HLF_WAVE_PRD_REG02       8'h0E + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_NEG_HLF_WAVE_PRD_REG02  8'h00
`define MASK_SOC_ADDR_WG_DRV_NEG_HLF_WAVE_PRD_REG02  8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_NEG_HLF_WAVE_PRD_REG02 16'h07

`define REG_WG15 SOC_ADDR_WG_DRV_REST_CLK1_REG01
`define SOC_ADDR_WG_DRV_REST_CLK1_REG01              8'h0F + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_REST_CLK1_REG01         8'h00
`define MASK_SOC_ADDR_WG_DRV_REST_CLK1_REG01         8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_REST_CLK1_REG01       16'h07

`define REG_WG16 SOC_ADDR_WG_DRV_REST_CLK1_REG02
`define SOC_ADDR_WG_DRV_REST_CLK1_REG02              8'h10 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_REST_CLK1_REG02         8'h00
`define MASK_SOC_ADDR_WG_DRV_REST_CLK1_REG02         8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_REST_CLK1_REG02       16'h07

`define REG_WG17 SOC_ADDR_WG_DRV_SILENT_CLK1_REG01
`define SOC_ADDR_WG_DRV_SILENT_CLK1_REG01            8'h11 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_SILENT_CLK1_REG01       8'h00
`define MASK_SOC_ADDR_WG_DRV_SILENT_CLK1_REG01       8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_SILENT_CLK1_REG01     16'h07

`define REG_WG18 SOC_ADDR_WG_DRV_SILENT_CLK1_REG02
`define SOC_ADDR_WG_DRV_SILENT_CLK1_REG02            8'h12 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_SILENT_CLK1_REG02       8'h00
`define MASK_SOC_ADDR_WG_DRV_SILENT_CLK1_REG02       8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_SILENT_CLK1_REG02     16'h07

`define REG_WG19 SOC_ADDR_WG_DRV_SILENT_CLK1_REG03
`define SOC_ADDR_WG_DRV_SILENT_CLK1_REG03            8'h13 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_SILENT_CLK1_REG03       8'h00
`define MASK_SOC_ADDR_WG_DRV_SILENT_CLK1_REG03       8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_SILENT_CLK1_REG03     16'h07

`define REG_WG20 SOC_ADDR_WG_DRV_SILENT_CLK1_REG04
`define SOC_ADDR_WG_DRV_SILENT_CLK1_REG04            8'h14 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_SILENT_CLK1_REG04       8'h00
`define MASK_SOC_ADDR_WG_DRV_SILENT_CLK1_REG04       8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_SILENT_CLK1_REG04     16'h07

`define REG_WG21 SOC_ADDR_WG_DRV_HLF_WAVE_CLK_PNT1_REG01
`define SOC_ADDR_WG_DRV_HLF_WAVE_CLK_PNT1_REG01      8'h15 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_HLF_WAVE_CLK_PNT1_REG01 8'h00
`define MASK_SOC_ADDR_WG_DRV_HLF_WAVE_CLK_PNT1_REG01 8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_HLF_WAVE_CLK_PNT1_REG01 16'h07

`define REG_WG22 SOC_ADDR_WG_DRV_HLF_WAVE_CLK_PNT1_REG02
`define SOC_ADDR_WG_DRV_HLF_WAVE_CLK_PNT1_REG02      8'h16 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_HLF_WAVE_CLK_PNT1_REG02 8'h00
`define MASK_SOC_ADDR_WG_DRV_HLF_WAVE_CLK_PNT1_REG02 8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_HLF_WAVE_CLK_PNT1_REG02 16'h07

`define REG_WG23 SOC_ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT1_REG01
`define SOC_ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT1_REG01      8'h17 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT1_REG01 8'h00
`define MASK_SOC_ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT1_REG01 8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT1_REG01 16'h07

`define REG_WG24 SOC_ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT1_REG02
`define SOC_ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT1_REG02      8'h18 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT1_REG02 8'h00
`define MASK_SOC_ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT1_REG02 8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT1_REG02 16'h07

`define REG_WG25 SOC_ADDR_WG_DRV_REST_CLK2_REG01
`define SOC_ADDR_WG_DRV_REST_CLK2_REG01              8'h19 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_REST_CLK2_REG01         8'h00
`define MASK_SOC_ADDR_WG_DRV_REST_CLK2_REG01         8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_REST_CLK2_REG01       16'h07

`define REG_WG26 SOC_ADDR_WG_DRV_REST_CLK2_REG02
`define SOC_ADDR_WG_DRV_REST_CLK2_REG02              8'h1A + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_REST_CLK2_REG02         8'h00
`define MASK_SOC_ADDR_WG_DRV_REST_CLK2_REG02         8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_REST_CLK2_REG02       16'h07

`define REG_WG27 SOC_ADDR_WG_DRV_SILENT_CLK2_REG01
`define SOC_ADDR_WG_DRV_SILENT_CLK2_REG01            8'h1B + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_SILENT_CLK2_REG01       8'h00
`define MASK_SOC_ADDR_WG_DRV_SILENT_CLK2_REG01       8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_SILENT_CLK2_REG01     16'h07

`define REG_WG28 SOC_ADDR_WG_DRV_SILENT_CLK2_REG02
`define SOC_ADDR_WG_DRV_SILENT_CLK2_REG02            8'h1C + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_SILENT_CLK2_REG02       8'h00
`define MASK_SOC_ADDR_WG_DRV_SILENT_CLK2_REG02       8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_SILENT_CLK2_REG02     16'h07

`define REG_WG29 SOC_ADDR_WG_DRV_SILENT_CLK2_REG03
`define SOC_ADDR_WG_DRV_SILENT_CLK2_REG03            8'h1D + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_SILENT_CLK2_REG03       8'h00
`define MASK_SOC_ADDR_WG_DRV_SILENT_CLK2_REG03       8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_SILENT_CLK2_REG03     16'h07

`define REG_WG30 SOC_ADDR_WG_DRV_SILENT_CLK2_REG04
`define SOC_ADDR_WG_DRV_SILENT_CLK2_REG04            8'h1E + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_SILENT_CLK2_REG04       8'h00
`define MASK_SOC_ADDR_WG_DRV_SILENT_CLK2_REG04       8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_SILENT_CLK2_REG04     16'h07

`define REG_WG31 SOC_ADDR_WG_DRV_HLF_WAVE_CLK_PNT2_REG01
`define SOC_ADDR_WG_DRV_HLF_WAVE_CLK_PNT2_REG01      8'h1F + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_HLF_WAVE_CLK_PNT2_REG01 8'h00
`define MASK_SOC_ADDR_WG_DRV_HLF_WAVE_CLK_PNT2_REG01 8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_HLF_WAVE_CLK_PNT2_REG01 16'h07

`define REG_WG32 SOC_ADDR_WG_DRV_HLF_WAVE_CLK_PNT2_REG02
`define SOC_ADDR_WG_DRV_HLF_WAVE_CLK_PNT2_REG02      8'h20 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_HLF_WAVE_CLK_PNT2_REG02 8'h00
`define MASK_SOC_ADDR_WG_DRV_HLF_WAVE_CLK_PNT2_REG02 8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_HLF_WAVE_CLK_PNT2_REG02 16'h07

`define REG_WG33 SOC_ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT2_REG01
`define SOC_ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT2_REG01      8'h21 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT2_REG01 8'h00
`define MASK_SOC_ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT2_REG01 8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT2_REG01 16'h07

`define REG_WG34 SOC_ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT2_REG02
`define SOC_ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT2_REG02      8'h22 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT2_REG02 8'h00
`define MASK_SOC_ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT2_REG02 8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT2_REG02 16'h07

`define REG_WG35 SOC_ADDR_WG_DRV_DELAY_LIM_REG01
`define SOC_ADDR_WG_DRV_DELAY_LIM_REG01              8'h23 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_DELAY_LIM_REG01         8'h00
`define MASK_SOC_ADDR_WG_DRV_DELAY_LIM_REG01         8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_DELAY_LIM_REG01       16'h07

`define REG_WG36 SOC_ADDR_WG_DRV_DELAY_LIM_REG02
`define SOC_ADDR_WG_DRV_DELAY_LIM_REG02              8'h24 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_DELAY_LIM_REG02         8'h00
`define MASK_SOC_ADDR_WG_DRV_DELAY_LIM_REG02         8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_DELAY_LIM_REG02       16'h07

`define REG_WG37 SOC_ADDR_WG_DRV_NEG_SCALE_REG0
`define SOC_ADDR_WG_DRV_NEG_SCALE_REG0               8'h25 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_NEG_SCALE_REG0          8'h01
`define MASK_SOC_ADDR_WG_DRV_NEG_SCALE_REG0          8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_NEG_SCALE_REG0        16'h07

`define REG_WG38 SOC_ADDR_WG_DRV_NEG_OFFSET_REG0
`define SOC_ADDR_WG_DRV_NEG_OFFSET_REG0              8'h26 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_NEG_OFFSET_REG0         8'h00
`define MASK_SOC_ADDR_WG_DRV_NEG_OFFSET_REG0         8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_NEG_OFFSET_REG0       16'h07

`define REG_WG39 SOC_ADDR_WG_DRV_POS_SCALE_REG0
`define SOC_ADDR_WG_DRV_POS_SCALE_REG0               8'h27 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_POS_SCALE_REG0          8'h01
`define MASK_SOC_ADDR_WG_DRV_POS_SCALE_REG0          8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_POS_SCALE_REG0        16'h07

`define REG_WG40 SOC_ADDR_WG_DRV_POS_OFFSET_REG0
`define SOC_ADDR_WG_DRV_POS_OFFSET_REG0              8'h28 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_POS_OFFSET_REG0         8'h00
`define MASK_SOC_ADDR_WG_DRV_POS_OFFSET_REG0         8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_POS_OFFSET_REG0       16'h07

`define REG_WG41 SOC_ADDR_WG_DRV_PULLBA_REG
`define SOC_ADDR_WG_DRV_PULLBA_REG                   8'h29 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_PULLBA_REG              8'h00
`define MASK_SOC_ADDR_WG_DRV_PULLBA_REG              8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_PULLBA_REG            16'h07

`define REG_WG42 SOC_ADDR_WG_DRV_INT_NUM_REG
`define SOC_ADDR_WG_DRV_INT_NUM_REG                  8'h2A + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_INT_NUM_REG             8'h00
`define MASK_SOC_ADDR_WG_DRV_INT_NUM_REG             8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_INT_NUM_REG           16'h07

`define REG_WG43 SOC_ADDR_WG_DRV_INT_REG01
`define SOC_ADDR_WG_DRV_INT_REG01                    8'h2B + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_INT_REG01               8'h00
`define MASK_SOC_ADDR_WG_DRV_INT_REG01               8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_INT_REG01             16'h02

`define REG_WG44 SOC_ADDR_WG_DRV_INT_REG02
`define SOC_ADDR_WG_DRV_INT_REG02                    8'h2C + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_INT_REG02               8'h00
`define MASK_SOC_ADDR_WG_DRV_INT_REG02               8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_INT_REG02             16'h03

`define REG_WG45 SOC_ADDR_WG_DRV_INT_REG03
`define SOC_ADDR_WG_DRV_INT_REG03                    8'h2D + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_INT_REG03               8'h00
`define MASK_SOC_ADDR_WG_DRV_INT_REG03               8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_INT_REG03             16'h03

`define REG_WG46 SOC_ADDR_WG_DRV_ALT_LIM_REG01
`define SOC_ADDR_WG_DRV_ALT_LIM_REG01                8'h2E + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_ALT_LIM_REG01           8'h00
`define MASK_SOC_ADDR_WG_DRV_ALT_LIM_REG01           8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_ALT_LIM_REG01         16'h07

`define REG_WG47 SOC_ADDR_WG_DRV_ALT_LIM_REG02
`define SOC_ADDR_WG_DRV_ALT_LIM_REG02                8'h2F + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_ALT_LIM_REG02           8'h00
`define MASK_SOC_ADDR_WG_DRV_ALT_LIM_REG02           8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_ALT_LIM_REG02         16'h07

`define REG_WG48 SOC_ADDR_WG_DRV_ALT_SILENT_LIM_REG01
`define SOC_ADDR_WG_DRV_ALT_SILENT_LIM_REG01         8'h30 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_ALT_SILENT_LIM_REG01    8'h00
`define MASK_SOC_ADDR_WG_DRV_ALT_SILENT_LIM_REG01    8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_ALT_SILENT_LIM_REG01  16'h07

`define REG_WG49 SOC_ADDR_WG_DRV_ALT_SILENT_LIM_REG02
`define SOC_ADDR_WG_DRV_ALT_SILENT_LIM_REG02         8'h31 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_ALT_SILENT_LIM_REG02    8'h00
`define MASK_SOC_ADDR_WG_DRV_ALT_SILENT_LIM_REG02    8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_ALT_SILENT_LIM_REG02  16'h07

`define REG_WG50 SOC_ADDR_WG_DRV_ALT_REST_LIM_REG01
`define SOC_ADDR_WG_DRV_ALT_REST_LIM_REG01         8'h32 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_ALT_REST_LIM_REG01    8'h00
`define MASK_SOC_ADDR_WG_DRV_ALT_REST_LIM_REG01    8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_ALT_REST_LIM_REG01  16'h07

`define REG_WG51 SOC_ADDR_WG_DRV_ALT_REST_LIM_REG02
`define SOC_ADDR_WG_DRV_ALT_REST_LIM_REG02         8'h33 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_ALT_REST_LIM_REG02    8'h00
`define MASK_SOC_ADDR_WG_DRV_ALT_REST_LIM_REG02    8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_ALT_REST_LIM_REG02  16'h07

`define REG_WG52 SOC_ADDR_WG_DRV_CTRL0_REG
`define SOC_ADDR_WG_DRV_CTRL0_REG                    8'h34 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_CTRL0_REG               8'h00
`define MASK_SOC_ADDR_WG_DRV_CTRL0_REG               8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_CTRL0_REG             16'h07

`define REG_WG53 SOC_ADDR_WG_DRV_CTRL1_REG
`define SOC_ADDR_WG_DRV_CTRL1_REG                    8'h35 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_CTRL1_REG               8'h00
`define MASK_SOC_ADDR_WG_DRV_CTRL1_REG               8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_CTRL1_REG             16'h07

`define REG_WG54 SOC_ADDR_WG_DRV_CTRL2_REG
`define SOC_ADDR_WG_DRV_CTRL2_REG                    8'h36 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_WG_DRV_CTRL2_REG               8'h00
`define MASK_SOC_ADDR_WG_DRV_CTRL2_REG               8'hFF
`define ACCESS_SOC_ADDR_WG_DRV_CTRL2_REG             16'h07

`define REG_WG55 SOC_NO_OF_NUM_SILENT_CTR0_REG
`define SOC_NO_OF_NUM_SILENT_CTR0_REG                    8'h37 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_NO_OF_NUM_SILENT_CTR0_REG               8'h00
`define MASK_SOC_NO_OF_NUM_SILENT_CTR0_REG               8'h01
`define ACCESS_SOC_NO_OF_NUM_SILENT_CTR0_REG             16'h07

`define REG_WG56 SOC_NO_OF_NUM_SILENT_TAR0_REG
`define SOC_NO_OF_NUM_SILENT_TAR0_REG                    8'h38 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_NO_OF_NUM_SILENT_TAR0_REG               8'h05
`define MASK_SOC_NO_OF_NUM_SILENT_TAR0_REG               8'hFF
`define ACCESS_SOC_NO_OF_NUM_SILENT_TAR0_REG             16'h07

`define REG_WG57 SOC_NO_OF_NUM_SILENT_TAR1_REG
`define SOC_NO_OF_NUM_SILENT_TAR1_REG                    8'h39 + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_NO_OF_NUM_SILENT_TAR1_REG               8'h00
`define MASK_SOC_NO_OF_NUM_SILENT_TAR1_REG               8'hFF
`define ACCESS_SOC_NO_OF_NUM_SILENT_TAR1_REG             16'h07

`define REG_WG58 SOC_ADDR_IS_VALID_FOR_CAL_REG
`define SOC_ADDR_IS_VALID_FOR_CAL_REG                    8'h3A + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_ADDR_IS_VALID_FOR_CAL_REG               8'h00
`define MASK_SOC_ADDR_IS_VALID_FOR_CAL_REG               8'hFF
`define ACCESS_SOC_ADDR_IS_VALID_FOR_CAL_REG             16'h07

`define REG_WG59 SOC_EMS_REG_CTRL_REG
`define SOC_EMS_REG_CTRL_REG                    8'h3B + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_EMS_REG_CTRL_REG               8'h00
`define MASK_SOC_EMS_REG_CTRL_REG               8'h3F
`define ACCESS_SOC_EMS_REG_CTRL_REG             16'h07

`define REG_WG60 SOC_EMS_REG_NUM_REG
`define SOC_EMS_REG_NUM_REG                    8'h3C + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_EMS_REG_NUM_REG               8'h00
`define MASK_SOC_EMS_REG_NUM_REG               8'hFF
`define ACCESS_SOC_EMS_REG_NUM_REG             16'h07

`define REG_WG61 SOC_AWG_DRIVEC_ISEL_REG
`define SOC_AWG_DRIVEC_ISEL_REG                    8'h3D + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_AWG_DRIVEC_ISEL_REG               8'h00
`define MASK_SOC_AWG_DRIVEC_ISEL_REG               8'h01
`define ACCESS_SOC_AWG_DRIVEC_ISEL_REG             16'h07

`define REG_WG62 SOC_AWG_DRIVEC_SW_CFG0_REG
`define SOC_AWG_DRIVEC_SW_CFG0_REG                    8'h3E + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_AWG_DRIVEC_SW_CFG0_REG               8'h00
`define MASK_SOC_AWG_DRIVEC_SW_CFG0_REG               8'hFF
`define ACCESS_SOC_AWG_DRIVEC_SW_CFG0_REG             16'h07

`define REG_WG63 SOC_AWG_DRIVEC_SW_CFG1_REG
`define SOC_AWG_DRIVEC_SW_CFG1_REG                    8'h3F + `WAVEGEN_0_ADDR_BASE// RW
`define INIT_SOC_AWG_DRIVEC_SW_CFG1_REG               8'h00
`define MASK_SOC_AWG_DRIVEC_SW_CFG1_REG               8'hFF
`define ACCESS_SOC_AWG_DRIVEC_SW_CFG1_REG             16'h07

`define SPI_TCH_MAX 20     //(ns) - 20
`define SPI_MAX_FREQ 20000 // 20Mhz
`define SPI_MIN_TCH  20    // 20ns - tch (% of high pulse / period)
`define SPI_MIN_TCL  20    // 20ns - tcl (% of low pulse / period)
`define SPI_MIN_TCSSO 20   // 20ns - tCSSO: clock will be valid after tCS
`define SPI_MIN_TCSH1 20   // 20ns - tCSH1: clock will be invalid after last clock
`define SPI_MIN_TDS 10     // 10ns 
`define SPI_MIN_TDH 10     // 10ns
`define SPI_MIN_TCSPW 50   // 50ns
`define SPI_MAX_TDOT 10    // 10ns

`define WAKEUP_CMD  0
`define STANDBY_CMD 1
`define START_CMD   2
`define STOP_CMD    3
`define RESET_CMD   4
// ===================================================================
// Some declarations for internal use
// ===================================================================
typedef enum { PIN, CMD } start_src_t;

// ===================================================================
// Test Config Object Declaration
// ===================================================================
class `TESTCFG extends nnc_object;

   `nnc_object_utils(`TESTCFG)

   //--------------------------------------------------------
   // Declare randomized variables part
   //--------------------------------------------------------
    rand  integer        rand_num;

    rand logic [7:0]     data[256];
    rand int             no_of_bytes; 

    rand  bit [1:0]      testmode_sel;
    // 00: Normal mode, 01: Scan-mode, 10: BIST mode, 11: ATM Mode
   
    rand  bit [1:0]      spimode_sel;           
    // spimode_sel[1]: CPOL, spimode_sel[0]: CPHA 

    rand  bit [1:0]      altf_sel;
    // Altenatives pins of chip but this project only support 00
 
    rand  bit            wait_reset_en;
    // Enable waiting reset before starting running sim

    rand  logic [2:0]    pclk_sel;
    rand  logic          int_clk_out;//1'b0: int clk out enabled using gpio; 1'b1: int clk out enabled using reg;
    // 2'b00: 2Mhz, 2'b01: 1Mhz, 2'b10: 500Khz, 2'b11: 250Khz
    rand logic [3:0]     iclk_sel;              // f(iclk) = fclk/(2^iclk_sel)
    rand logic [31:0]    imeas_adc_freq;
    rand logic [3:0]     imeas_cic_rate;
    rand logic [15:0]    imeas_osr;
    rand logic [31:0]    imeas_samp_rate;
    rand logic [31:0]    imeas_sin_expected_freq; // Create sine wave with expected freqency
    rand logic [31:0]    imeas_sin_freq_unit;
    rand int             imeas_sin_no_clk_per_period;

    rand  logic [15:0]   high_clk ;  
    rand  logic [15:0]   low_clk ;  

    //rand  logic [2:0]    pclk_div;
    rand  logic [15:0]   otp_tPGM;     
    rand  logic [15:0]   otp_tVPP;
    rand  logic          VPP; 
    
    rand  bit [15:0]     spi_sclk_freq;         // unit is Khz (1Khz to 16.000Khz)
    rand  bit [6:0]      spi_clk_jitter;        // unut is percentage (0-100)
    rand  bit [6:0]      spi_sclk_jitter;       // unut is percentage (0-100)

    rand  bit		 fault_stuck0_clk_en;	// 1: internal 32KHZ and 300KHZ will be LOW (can used when we set ext_clk_en) 	

    logic [7:0]          clk_data[];

    rand  logic  [6:0]   hfosc_jitter;
    rand  logic  [6:0]   hfosc_variation;

    rand  bit            hfosc_fixed_gnd_en; 
    rand  bit            ext_hfosc_fixed_gnd_en;

    rand  bit [15:0]     tcssc;                 // min is 400ns
    rand  bit [15:0]     tsccs;                 // min is 400ns
    rand  bit [15:0]     tcsh;                  // min is 500ns
    rand  bit [6:0]      tdist;                 // min is 10ns - percentage from 0 -> 100
    rand  bit [6:0]      tch;                   // percentage from 0 -> 100

    rand  bit [15:0]     bistm_freq;            // unit is Khz (1Khz to 20.000Khz)
    rand  bit [15:0]     bistm_freq_sel;
    rand  int            bistm_tPGM_RC;
    rand  int            bistm_tPGM;

    rand  bit            config_in_base_test_en;// 0: Enable config clock in base test 1: disable config in base test

    rand  bit [2:0]      wg_drv_sel;		//to select among 8 wavegen drivers
    rand  logic [31:0]   hlf_wave_per;          //half wave period setting of waveform
    rand  bit            dont_check_conf_first_en;

    rand  bit [1:0]      A2D_comp_sel;		//select the A2D_comp for lead_off_detection
    rand  bit [1:0]      A2D_stim_sel;		//select the A2D_stim for short_detection

    rand logic [1:0]     OTP_SEL;
    rand logic [6:0]     ADDR = 0;

    randc logic [1:0]    TCK_SEL;
    rand logic [4:0]     ctrl_bit;
    rand logic           SRL;
    rand logic [7:0]     data_in;
    rand int             vpp_pos_cnt, vpp_neg_cnt;
    rand int             vpp_pos_cnt_mult, vpp_neg_cnt_mult;
    rand int             vpp_width, vpp_width_mult;
    rand bit             bist_vpp_pin_en;       //control vpp by bist_vpp_en or timing
    rand bit             pinmux_mode;           //control vpp by bist_vpp_en or timing
    rand bit             swap_sdf_en;
    rand bit             otp_program_en;
    rand logic [7:0]     otp_vpp_delay;

    rand logic [14:0]    gpio_pu_en;      // 14: RESET, [13:12]: TESTMODE, 11: CLKSEL, [10:0]: GPI0 
    rand logic [14:0]    gpio_pd_en;      // 14: RESET, [13:12]: TESTMODE, 11: CLKSEL, [10:0]: GPI0

    rand logic           python_check_en;
    rand logic [31:0]    python_length;

    rand logic           io_model_check_off;
    rand logic           spi_o_clk_sel;

    rand  bit            ext_clk_en;            // 1: using external clock and 0: using Internal clock
    rand  bit            swap_sdf_en;           // 0: Slave Chip A is enabled, 1: Slave Chip B is enabled
    rand  bit            mult_chip_en;          // 1: 3 chip is connected and 0: 1 chip is connected only
    rand  bit            mult_chip_same_clk_en; // 1: the same clk and 0: different clk
    rand  logic [1:0]    mult_chip_mode;        // 0: Master + Slave Chip A are enabled, 1: Only slave chip A is enabled, 2: Only slave chip B is enabled
    rand  logic [1:0]    mult_chip_typ; 
    // 2'b00: spi_o_clk_sel = 0, ext_clk_en_master_chip: 1, ext_clk_en_slave_chip_A: 1, ext_clk_en_slave_chip_B: 1
    // 2'b01: spi_o_clk_sel = 1, ext_clk_en_master_chip: 0, ext_clk_en_slave_chip_A: 1, ext_clk_en_slave_chip_B: 1
    // 2'b10: spi_o_clk_sel = 1, ext_clk_en_master_chip: 1, ext_clk_en_slave_chip_A: 1, ext_clk_en_slave_chip_B: 1
    // 2'b11: reserved

    rand bit             lead_off_en;
    rand logic           lead_off_ch0_comp_low_active;//anac comp input polarity level to detect lead-off
    rand logic           lead_off_ch1_comp_low_active;//anac comp input polarity level to detect lead-off
    rand bit             short_en;
    rand logic           anac_stim_CH1_pol;//anac stim input polarity level to detect short
    rand logic           anac_stim_CH2_pol;//anac stim input polarity level to detect short
    rand logic [1:0]     register_val_ch1; // 00: Open-circuit (so huge), 01: short-circuit (5 Ohm), 10: normal (1K Ohm)
    rand logic [1:0]     register_val_ch2; // 00: Open-circuit (so huge), 01: short-circuit (5 Ohm), 10: normal (1K Ohm)
    rand logic [31:0]    a2d_comp_delay_ch1;
    rand logic [31:0]    a2d_comp_delay_ch2;

    rand bit   [1:0]     short_leadoff_counter_cnt_debug_sel; //count_TH value selection when timer expires,  

    rand logic [1:0]     pulse_after_source; 
    // 00: No unstable pulse after rising of SourceA, SourceB
    // 01: unstable pulse after rising of SourceA
    // 10: unstable pulse after rising of SourceB
    // 11: unstable pulse after rising of SourceA and SourceB
 
    rand logic [31:0]    pulse_after_source_delay;
    // Width of unstable pulse

    rand logic [2:0]     vbat_level;   
    // 0: 3V, 1: 3.3V, 2: 3.6V, 3: 3.85V, 4: 4.15V, 5: 4.4V, 6: 4.7V, 7: 5V

    rand logic [7:0]    sensor_temperature;
    // 1-unit is 0.5 oC (Range from 0.5 oC to 125 oC) -> randomize from 1 to 250

    rand logic          tsc_comp_low_active_en;
    // 0: HIGH ACTIVE, 1: LOW ACTIVE
    
    rand bit            otp_ignore_check_en;

    rand bit            iclk_pmu_ctrl_en;
    // 0: Change ICLK, no change for PMU and ANA
    // 1: Change ICLK, reconfiguration for PMU and ANA again

    rand bit            imeas_sin_gen_en;
    rand bit            imeas_noise_gen_en;
    rand bit            imeas_overlap_en;
   
    rand bit [31:0] nirs_irefcoarse_length;         // High pulse length of SW2  - Unit: ns
    rand bit [31:0] nirs_irefcoarse_iref_delay;     // Delay between SW2 and SW3 - Unit: ns 
    rand bit [31:0] nirs_ireffine_length;           // High pulse length of SW3  - Unit: ns

    // ======================================================================================
    // reg_normal[i] struture 
    // [39:32]: Register Address
    // [31:24]: Initial value of register
    // [23:16]:  Maskable bits (Write Accessible bits)
    // [15:3]: Reserved bits
    // [2]  : Enable checker : 1: Enable, 0: Disable
    // [1:0]: Type of access: 0: RW1C, 1: Write Only, 2: Read Only, 3: RW, 2'bxx: reserved 
    // ======================================================================================
    logic [39:0]         reg_normal[`NORMAL_REG_NUM]; 

    // The same for reg_wavegen for Wavegen Registers
    logic [39:0]         reg_wavegen[`WAVEGEN_DRIVER_OFFSET*`WAVEGEN_DRIVER_NUM];

    rand  bit [2:0]      no_of_adc_dev1;             // 2/4/6/8/10/12/14/16
    rand  bit [2:0]      no_of_adc_dev2;             // 2/4/6/8/10/12/14/16  
    rand  bit [2:0]      dump_level;

    bit A2D_comp0_in = 0;
    bit A2D_comp1_in = 0;
    bit A2D_comp_stim0_1_in = 0;
    bit A2D_comp_stim2_3_in = 0;

    //--------------------------------------------------------
    // Declare new function to initilize the object
    //--------------------------------------------------------
    function new (string name = "soc_base_test_cfg");
      super.new(name);
    endfunction: new

    //--------------------------------------------------------
    // Declare constraints for each of randomized variables
    //--------------------------------------------------------

    constraint c_dump_level               { dump_level == 3'b000; }

    constraint c_vpp                      { VPP == 1'b0; } // no need in ENS2

    constraint c_python_check_en          { soft python_check_en == 1'b0; }

    constraint c_python_length            { python_length == (200+1024+32*2); }

    constraint c_io_model_check_off       { soft io_model_check_off == 1'b0; }

    // Enable/Disable PU PAD
    constraint c_gpio_pu_en               { soft gpio_pu_en == 15'b1_00_0_000_0000_0000;}

    // Enable/Disable PD PAD
    constraint c_gpio_pd_en               { soft gpio_pd_en == 15'b0_11_1_100_0000_0111;}

    // Delay PAD for program OTP
    constraint c_otp_vpp_delay            { (otp_program_en == 1'b0) -> otp_vpp_delay == 0;
                                            (otp_program_en == 1'b1) -> otp_vpp_delay == 20; }

    // Enable/Disable to program OTP
    constraint c_otp_program_en           { soft otp_program_en == 1'b0;}

    // Select PCLK DIV from HFOSC
    constraint c_pclk_sel                 { soft pclk_sel inside {[0:7]};} 
    // when reading OTP, do not set pclk_sel = 7 (16Khz is not supported)

    constraint c_int_clk_out              { soft int_clk_out == 1'b0; }

    constraint c_iclk_sel                 { (pclk_sel == 3'b000) -> iclk_sel inside {[0:11]};
                                            (pclk_sel == 3'b001) -> iclk_sel inside {[1:11]};
                                            (pclk_sel == 3'b010) -> iclk_sel inside {[2:11]};
                                            (pclk_sel == 3'b011) -> iclk_sel inside {[3:11]};
                                            (pclk_sel == 3'b100) -> iclk_sel inside {[4:11]};
                                            (pclk_sel == 3'b101) -> iclk_sel inside {[5:11]};
                                            (pclk_sel == 3'b110) -> iclk_sel inside {[6:11]};
                                            (pclk_sel == 3'b111) -> iclk_sel inside {[7:11]};}

    constraint c_imeas_cic_rate         { soft imeas_cic_rate == 4'b0110; }

    constraint c_imeas_osr              { solve imeas_cic_rate before imeas_osr ; imeas_osr == (8 * (2**imeas_cic_rate)); }

    constraint c_imeas_adc_freq         { solve iclk_sel before imeas_adc_freq; 
                                          //imeas_adc_freq == (8192/(2**(iclk_sel))); }
                                          imeas_adc_freq == (8389/(2**(iclk_sel))); }

    constraint c_imeas_samp_rate        { solve imeas_adc_freq before imeas_samp_rate; 
                                          solve imeas_osr before imeas_samp_rate; 
                                          imeas_samp_rate == ((imeas_adc_freq * 1000) / imeas_osr); } // Khz

    constraint c_imeas_sin_freq_unit    { soft imeas_sin_freq_unit == 100; }//1: imeas_sin_expected_freq in Hz; 10: imeas_sin_expected_freq in Hz/10; 100: imeas_sin_expected_freq in Hz/100

    constraint c_imeas_sin_expected_freq{ solve imeas_samp_rate before imeas_sin_expected_freq; 
                                          solve imeas_sin_freq_unit before imeas_sin_expected_freq; 
                                          imeas_sin_expected_freq == ((imeas_sin_freq_unit*imeas_samp_rate)/32); //32 samples for a sine, single mode
                                        }
    //this constraint not working currently, Daniel need to analyze
    constraint c_imeas_sin_no_clk_per_period    { solve imeas_adc_freq before imeas_sin_no_clk_per_period; 
                                                  solve imeas_sin_freq_unit before imeas_sin_no_clk_per_period; 
                                                  solve imeas_sin_expected_freq before imeas_sin_no_clk_per_period; 
                                                  //imeas_sin_no_clk_per_period == ((imeas_sin_freq_unit*1000/imeas_sin_expected_freq) * imeas_adc_freq) + (imeas_adc_freq*((100000*((imeas_sin_freq_unit*1000)%imeas_sin_expected_freq))/imeas_sin_expected_freq)/100000); }
                                                  imeas_sin_no_clk_per_period == ((imeas_adc_freq*1000)/(imeas_sin_expected_freq/imeas_sin_freq_unit)); }
    //constraint c_imeas_sin_no_clk_per_period    { solve imeas_osr before imeas_sin_no_clk_per_period; 
    //                                              imeas_sin_no_clk_per_period == (imeas_osr * 32); //32 samples for a sine, single mode
    //                                            }

    constraint c_high_clk { solve otp_tVPP before high_clk;
                          high_clk inside {[6:(5+otp_tVPP)]}; 
                        } 

    constraint c_low_clk  { solve otp_tVPP before low_clk;
                          solve otp_tPGM before low_clk; 
                          low_clk inside {[(7+otp_tVPP+(otp_tPGM+4)*12):(6+(2*otp_tVPP)+(otp_tPGM+4)*12)]}; 
                        } 

    // Enable/Disable to swap SDF file
    constraint c_swap_sdf_en            { (mult_chip_same_clk_en == 1'b1) -> swap_sdf_en inside {[0:1]};
                                          (mult_chip_same_clk_en == 1'b0) -> swap_sdf_en == 1'b0; }

    // Enable/Disable to dual chips
    constraint c_mult_chip_en           { soft mult_chip_en == 1'b0;}

    // Select chip to be enabled 
    constraint c_mult_chip_mode         { soft mult_chip_mode == 2'b0;}

    // Select clk mode for dual chips
    constraint c_mult_chip_same_clk_en  { (mult_chip_en == 1) -> mult_chip_same_clk_en == 1'b1; 
                                          (mult_chip_en == 0) -> mult_chip_same_clk_en == 1'b0;   
                                        }

    // Enable/Disable to pinmux mode
    constraint c_pinmux_mode            { soft pinmux_mode == 1'b0;}

    // ALT FUNC Randomization (fixed 2'b00 in ENS2)
    constraint c_altf_sel               { soft altf_sel inside {[0:0]}; }          // Supported one alternate func now

    // Enable/Disable to wait Randomization
    constraint c_wait_reset_en          { soft wait_reset_en == 1'b1;}

    // Selections for CPOL and CPHA
    constraint c_spimode_sel            { soft spimode_sel inside {[0:3]};}        // ; cpol=0 & cpha = 0; cpol=0 & cpha = 1; cpol=1 & cpha = 2; cpol=1 & cpha = 3

    // Selections for CHIP Modes
    constraint c_testmode_sel           { soft testmode_sel == 2'b00;}

    // Enable/Disable to randomize the config in base test
    constraint c_config_in_base_test_en { soft config_in_base_test_en == 1'b1; }

    // Enable/Disable external clock
`ifndef MIXSIM
    constraint c_ext_clk_en             { (mult_chip_same_clk_en == 1'b1) -> ext_clk_en == 1'b1;
                                          ((mult_chip_same_clk_en == 1'b0) && (mult_chip_en == 1'b1)) -> ext_clk_en == 1'b0;
                                          ((mult_chip_same_clk_en == 1'b0) && (mult_chip_en == 1'b0)) -> ext_clk_en inside {[0:1]}; 
                                        }
`else
    constraint c_ext_clk_en             { soft ext_clk_en == 0;}
`endif

    // Set Jitter for HFOSC (0% - 100%)
    constraint c_hfosc_jitter           { soft hfosc_jitter inside {[0:5]};}        // 1* - 5%

    // Set the variation of HFOSC (duty cycle)
    constraint c_hfosc_variation        { soft hfosc_variation inside {[97:103]}; } // 97% - 103% - Clock limitation for OOT from 1.89Mhz-2,2Mhz 

    // Enable/Disable to fix the output of Internal HFOSC to Ground
    constraint c_hfosc_fixed_gnd_en     { solve ext_clk_en before hfosc_fixed_gnd_en; 
                                          (mult_chip_same_clk_en == 1'b1) -> hfosc_fixed_gnd_en == 1'b0;
                                          (mult_chip_same_clk_en == 1'b0) -> hfosc_fixed_gnd_en == ext_clk_en;   
                                        }

    // Enable/Disable to fix the output of External HFOSC to Ground
    constraint c_ext_hfosc_fixed_gnd_en { 
                                          solve ext_clk_en before ext_hfosc_fixed_gnd_en;
                                          (mult_chip_same_clk_en == 1'b1) -> ext_hfosc_fixed_gnd_en == 1'b1;
                                          (mult_chip_same_clk_en == 1'b0) -> ext_hfosc_fixed_gnd_en == !ext_clk_en; 
                                        }

    // Set frequency for SPI (unit of 1Khz)
    constraint c_spi_sclk_freq          { solve spi_sclk_jitter before spi_sclk_freq; spi_sclk_freq inside {[25:200*(100 - spi_sclk_jitter)]};} // 25Khz to 20Mhz

    // Set Jitter for SPI CLK (0% - 100%)
    constraint c_spi_sclk_jitter        { spi_sclk_jitter inside {[1:5]};}

    constraint c_spi_clk_jitter         { soft spi_clk_jitter inside {[1:5]};}

    // Set SPI timing protocol for tCSSO (Min 20ns)
    constraint c_tcssc                  { soft tcssc    inside {[`SPI_TCH_MAX:4000]};}   // ~tCSSO (Min 20ns)

    // Set SPI timing protocol for tCSH1 (Min 20ns)
    constraint c_tsccs                  { solve tch before tsccs; solve spi_sclk_freq before tsccs; tsccs <= 10000; tsccs >= `SPI_TCH_MAX; 
                                          (tch >= 50) -> tsccs > 100*tch/spi_sclk_freq;
                                          (tch <  50) -> tsccs > 100*(100 - tch)/spi_sclk_freq; 
                                        }   // ~tCSH1 (Min 20ns)

    // Set SPI timing protocol for tCSPW (Min 20ns)
    constraint c_tcsh                   { solve tch before tcsh; solve spi_sclk_freq before tcsh; tcsh <= 10000; tcsh >= `SPI_TCH_MAX;
                                          (tch >= 50) -> tcsh > 100*tch/spi_sclk_freq;
                                          (tch <  50) -> tcsh > 100*(100 - tch)/spi_sclk_freq;
                                        }   // ~tCSPW (Min 20ns)

   
    // Set SPI timing protocol for dist (Data is valid before clock is coming)
    constraint c_tdist                  { soft tdist inside {[0:0]};}        // percent : tdist * (Period_SCK/2 - 10):

    // Set SPI timing protocol for percent : tCH >= 20ns, tCL >= 20ns

    constraint c_tch                    { solve spi_sclk_freq before tch; solve spi_sclk_jitter before tch; 
                                          tch inside {[1:99]}; 
                                          tch < 100 - (spi_sclk_freq * (100 + spi_sclk_jitter) * `SPI_TCH_MAX) / 1000000; 
                                          tch > (spi_sclk_freq * `SPI_TCH_MAX * (100 + spi_sclk_jitter)) / 1000000;}        // percent : tch >= 25ns, tCL >= 25ns

/*
    constraint c_tch                    { solve spi_sclk_freq before tch; 
                                          tch inside {[1:99]};
                                          tch < 100 - (spi_sclk_freq * `SPI_TCH_MAX) / 10000;
                                          tch > (spi_sclk_freq * `SPI_TCH_MAX) / 10000;}        // percent : tch >= 25ns, tCL >= 25ns
*/
    constraint c_otp_tPGM               { pclk_sel == 3'b000 -> otp_tPGM == 665;
                                          pclk_sel == 3'b001 -> otp_tPGM == 333;
                                          pclk_sel == 3'b010 -> otp_tPGM == 165;
                                          pclk_sel == 3'b011 -> otp_tPGM == 82;
                                          pclk_sel == 3'b100 -> otp_tPGM == 41;
                                          pclk_sel == 3'b101 -> otp_tPGM == 20;
                                          pclk_sel == 3'b110 -> otp_tPGM == 9;
                                          pclk_sel == 3'b111 -> otp_tPGM == 4;}

    constraint c_otp_tVPP               { pclk_sel == 3'b000 -> otp_tVPP == 20;
                                          pclk_sel == 3'b001 -> otp_tVPP == 10;
                                          pclk_sel == 3'b010 -> otp_tVPP == 5;
                                          pclk_sel == 3'b011 -> otp_tVPP == 3;
                                          pclk_sel == 3'b100 -> otp_tVPP == 2;
                                          pclk_sel == 3'b101 -> otp_tVPP == 1;
                                          pclk_sel == 3'b110 -> otp_tVPP == 1;
                                          pclk_sel == 3'b111 -> otp_tVPP == 1;}

    // Set frequency for BIST (unit of 1Khz)
    constraint c_bistm_freq             { soft bistm_freq == 1000;} // 1Mhz

    constraint c_bistm_freq_sel         { soft bistm_freq_sel == 2'b00;} // 1Mhz

    constraint c_bistm_tPGM_RC          { 
                                          (bistm_freq == 1000) -> bistm_tPGM_RC == 1200;
                                          (bistm_freq == 10000)-> bistm_tPGM_RC == 120;
                                          (bistm_freq == 20000)-> bistm_tPGM_RC == 240;
                                          (bistm_freq == 32000)-> bistm_tPGM_RC == 384; 
                                        } 

    constraint c_fault_stuck0_clk_en    { soft fault_stuck0_clk_en == 1'b0;} // 1: internal 32KHZ and 300KHZ will be LOW (can used when we set ext_clk_en)

    constraint c_wg_drv_sel             { soft wg_drv_sel == 0;}

    constraint c_hlf_wave_per           { soft hlf_wave_per == 0;}

    constraint c_dont_check_conf_first_en { soft dont_check_conf_first_en == 0; }// Using for Flash BIST

    constraint c_A2D_comp_sel           { soft A2D_comp_sel == 0;}

    constraint c_A2D_stim_sel           { soft A2D_stim_sel == 0;}

    constraint c_ctrl_bit               { ctrl_bit[0] == SRL; }

    // Enable/Disable OTP
    constraint c_OTP_SEL                { OTP_SEL == 0; }

    // Select BIST CLK modes
    constraint c_TCK_SEL                { TCK_SEL inside {[0:0]}; }  //2'b00->1M  ;  2'b01->10M ;  2'b10 -> 20M ;  2'b11 -> 32M

    constraint c_bistm_tPGM             { bistm_freq == 1000  -> bistm_tPGM == 325;
                                          bistm_freq == 10000 -> bistm_tPGM == 3250;
                                          bistm_freq == 20000 -> bistm_tPGM == 6500;
                                          bistm_freq == 32000 -> bistm_tPGM == 10400; }
/*
    constraint c_tPGM_RC                { TCK_SEL == 2'b00 -> tPGM_RC == 12;
                                          TCK_SEL == 2'b01 -> tPGM_RC == 120;
                                          TCK_SEL == 2'b10 -> tPGM_RC == 240;
                                          TCK_SEL == 2'b11 -> tPGM_RC == 384; }  
*/
    constraint c_vpp_pos_cnt            { vpp_pos_cnt inside {[4:24]}; }

    constraint c_vpp_neg_cnt            { vpp_neg_cnt inside {[27+bistm_tPGM:42+bistm_tPGM]}; }

    constraint c_vpp_pos_cnt_mult       { vpp_pos_cnt_mult inside {[4:24]}; }

    constraint c_vpp_neg_cnt_mult       { vpp_neg_cnt_mult inside {[24+(bistm_tPGM+3)*128:24+(bistm_tPGM+3)*128+18]}; }

    constraint c_no_of_bytes            { soft no_of_bytes == 2; }

    constraint c_vpp_width              { vpp_width == (vpp_neg_cnt - vpp_pos_cnt); }

    constraint c_vpp_width_mult         { vpp_width_mult == (vpp_neg_cnt_mult - vpp_pos_cnt_mult); }

    constraint c_spi_o_clk_sel          { mult_chip_typ == 2'b00 -> spi_o_clk_sel == 1'b0; 
                                          mult_chip_typ == 2'b01 -> spi_o_clk_sel == 1'b1;
                                          mult_chip_typ == 2'b10 -> spi_o_clk_sel == 1'b1;
                                        }

    constraint c_mult_chip_typ          { soft mult_chip_typ == 2'b00; } 

    constraint c_short_leadoff_counter_cnt_debug_sel    { soft short_leadoff_counter_cnt_debug_sel == 2'b00; } //0: CH0 short, 1: CH1 short, 2: CH0 leadoff, 3: CH1 leadoff

    constraint c_lead_off_en                  { lead_off_en == 1'b0; }
    constraint c_lead_off_ch0_comp_low_active { lead_off_ch0_comp_low_active == 1'b0; }
    constraint c_lead_off_ch1_comp_low_active { lead_off_ch1_comp_low_active == 1'b0; }
    constraint c_short_en                     { short_en  == 1'b0; }
    constraint c_anac_stim_CH1_pol            { anac_stim_CH1_pol == 1'b0; }
    constraint c_anac_stim_CH2_pol            { anac_stim_CH2_pol == 1'b0; }
    constraint c_register_val_ch1             { register_val_ch1 == 2'b10; } // 00: Open-circuit (so huge), 01: short-circuit (5 Ohm), 10: normal (1K Ohm)
    constraint c_register_val_ch2             { register_val_ch2 == 2'b10; } // 00: Open-circuit (so huge), 01: short-circuit (5 Ohm), 10: normal (1K Ohm)
    constraint c_a2d_comp_delay_ch1           { a2d_comp_delay_ch1 inside {[200 : 400]}; } // real design 217ns for posedge, 370ns for falling edge
    constraint c_a2d_comp_delay_ch2           { a2d_comp_delay_ch2 inside {[200 : 400]}; } // real design 217ns for posedge, 370ns for falling edge

    constraint c_pulse_after_source          { pulse_after_source == 2'b00; }
    constraint c_pulse_after_source_delay    { pulse_after_source_delay inside {[3000 : 10000]}; }

    constraint c_vbat_level                  { vbat_level inside {[0:7]}; } 

    constraint c_sensor_temperature          { sensor_temperature inside {[1:250]}; } 
    
    constraint c_tsc_comp_low_active_en      { tsc_comp_low_active_en == 1'b0; }

    constraint c_otp_ignore_check_en         { otp_ignore_check_en == 1'b0; }

    constraint c_iclk_pmu_ctrl_en           { iclk_pmu_ctrl_en == 1'b0; }

    constraint c_imeas_sin_gen_en           { imeas_sin_gen_en == 1'b0; }

    constraint c_imeas_noise_gen_en         { imeas_noise_gen_en == 1'b0; }

    constraint c_no_of_adc_dev1             { soft no_of_adc_dev1 inside {[0:3]};} // 0:2, 1:4, 2:6, 3:8, 4:10, 5:12, 6:14, 7:16

    constraint c_no_of_adc_dev2             { soft no_of_adc_dev2 inside {[0:3]};} // 0:2, 1:4, 2:6, 3:8, 4:10, 5:12, 6:14, 7:16

    constraint c_nirs_irefcoarse_length     { nirs_irefcoarse_length inside {[100:2000]};}

    constraint c_nirs_irefcoarse_iref_delay { nirs_irefcoarse_iref_delay inside {[0:0]};}

    constraint c_nirs_ireffine_length       { nirs_ireffine_length inside {[100:1000]};}

    constraint c_imeas_overlap_en            { soft imeas_overlap_en == 1'b1; } 

endclass : `TESTCFG

// ===================================================================
// Test Class Declaration
// ===================================================================
class `TESTNAME extends nnc_test;

  `nnc_component_utils(`TESTNAME)

  soc_env                   top_env;
  soc_chip_cfg              top_cfg;
  `TESTCFG                  top_test_cfg;

  nnc_report_server         server;

  //--------------------------------------------------------
  // New funtion to initialise for test
  //--------------------------------------------------------
  function new(string name = "soc_base_test", nnc_component parent=null);

    // Calling parent class to execute firstly
    super.new(name,parent);

  endfunction: new

  //--------------------------------------------------------
  // Declare external function declarations
  //--------------------------------------------------------
  extern virtual function void build_phase(nnc_phase phase);
  extern function void end_of_elaboration_phase(nnc_phase phase);
  extern virtual task pre_reset_phase(nnc_phase phase);
  extern virtual task reset_phase(nnc_phase phase);
  extern virtual task pre_main_phase(nnc_phase phase);
  extern virtual task main_phase(nnc_phase phase);
  extern virtual function void report_phase(nnc_phase phase) ;

endclass : `TESTNAME

//--------------------------------------------------------
// Build function declarations
//--------------------------------------------------------
function void `TESTNAME::build_phase(nnc_phase phase);	
  
  `nnc_info("build_phase", "Entered test...", NNC_HIGH)

  // Calling parent class to execute firstly
  super.build_phase(phase);

  `nnc_top.set_timeout(2s);
  
  top_cfg = soc_chip_cfg::type_id::create("top_cfg", this);

  top_env = soc_env::type_id::create("top_env", this);

  nnc_config_db#(soc_chip_cfg)::set(this, "top_env", "top_cfg", this.top_cfg);

  top_test_cfg = `TESTCFG::type_id::create("top_test_cfg", this);

  nnc_config_db#(nnc_object_wrapper)::set(this, "top_env.top_sqr.main_phase", "default_sequence", null);

  // For Normal Registers 
  `SET_CFG_REG(`REG0);
  `SET_CFG_REG(`REG1);
  `SET_CFG_REG(`REG2);
  `SET_CFG_REG(`REG3);
  `SET_CFG_REG(`REG4);
  `SET_CFG_REG(`REG5);
  `SET_CFG_REG(`REG6);
  `SET_CFG_REG(`REG7);
  `SET_CFG_REG(`REG8);
  `SET_CFG_REG(`REG9);
  `SET_CFG_REG(`REG10);
  `SET_CFG_REG(`REG11);
  `SET_CFG_REG(`REG12);
  `SET_CFG_REG(`REG13);
  `SET_CFG_REG(`REG14);
  `SET_CFG_REG(`REG15);
  `SET_CFG_REG(`REG16);
  `SET_CFG_REG(`REG17);
  `SET_CFG_REG(`REG18);
  `SET_CFG_REG(`REG19);
  `SET_CFG_REG(`REG20);
  `SET_CFG_REG(`REG21);
  `SET_CFG_REG(`REG22);
  `SET_CFG_REG(`REG23);
  `SET_CFG_REG(`REG24);
  `SET_CFG_REG(`REG25);
/*
  `SET_CFG_REG(`REG26);
  `SET_CFG_REG(`REG27);
  `SET_CFG_REG(`REG28);
  `SET_CFG_REG(`REG29);
  `SET_CFG_REG(`REG30);
  `SET_CFG_REG(`REG31);
  `SET_CFG_REG(`REG32);
  `SET_CFG_REG(`REG33);
  `SET_CFG_REG(`REG34);
  `SET_CFG_REG(`REG35);
  `SET_CFG_REG(`REG36);
  `SET_CFG_REG(`REG37);
  `SET_CFG_REG(`REG38);
  `SET_CFG_REG(`REG39);
  `SET_CFG_REG(`REG40);
  `SET_CFG_REG(`REG41);
  `SET_CFG_REG(`REG42);
  `SET_CFG_REG(`REG43);
*/
  `SET_CFG_REG(`REG44);
  `SET_CFG_REG(`REG45);
  `SET_CFG_REG(`REG46);
  `SET_CFG_REG(`REG47);
  `SET_CFG_REG(`REG48);
  `SET_CFG_REG(`REG49);
  `SET_CFG_REG(`REG50);
  `SET_CFG_REG(`REG51);
  `SET_CFG_REG(`REG52);
  `SET_CFG_REG(`REG53);
  `SET_CFG_REG(`REG54);
  `SET_CFG_REG(`REG55);
  `SET_CFG_REG(`REG56);
  `SET_CFG_REG(`REG57);
  `SET_CFG_REG(`REG58);
  `SET_CFG_REG(`REG59);
/*
  `SET_CFG_REG(`REG60);
  `SET_CFG_REG(`REG61);
  `SET_CFG_REG(`REG62);
  `SET_CFG_REG(`REG63);
  `SET_CFG_REG(`REG64);
  `SET_CFG_REG(`REG65);
  `SET_CFG_REG(`REG66);
  `SET_CFG_REG(`REG67);
  `SET_CFG_REG(`REG68);
  `SET_CFG_REG(`REG69);
  `SET_CFG_REG(`REG70);
  `SET_CFG_REG(`REG71);
  `SET_CFG_REG(`REG72);
  `SET_CFG_REG(`REG73);
  `SET_CFG_REG(`REG74);
  `SET_CFG_REG(`REG75);
  `SET_CFG_REG(`REG76);
  `SET_CFG_REG(`REG77);
*/
  `SET_CFG_REG(`REG78);
  `SET_CFG_REG(`REG79);
  `SET_CFG_REG(`REG80);
  `SET_CFG_REG(`REG81);
  `SET_CFG_REG(`REG82);
  `SET_CFG_REG(`REG83);
  `SET_CFG_REG(`REG84);
  `SET_CFG_REG(`REG85);
  `SET_CFG_REG(`REG86);
  `SET_CFG_REG(`REG87);
  `SET_CFG_REG(`REG88);
  `SET_CFG_REG(`REG89);
  `SET_CFG_REG(`REG90);
  `SET_CFG_REG(`REG91);
  `SET_CFG_REG(`REG92);
  `SET_CFG_REG(`REG93);
  `SET_CFG_REG(`REG94);
/*
  `SET_CFG_REG(`REG95);
  `SET_CFG_REG(`REG96);
  `SET_CFG_REG(`REG97);
  `SET_CFG_REG(`REG98);
  `SET_CFG_REG(`REG99);
*/
  `SET_CFG_REG(`REG100);
  `SET_CFG_REG(`REG101);
  `SET_CFG_REG(`REG102);
  `SET_CFG_REG(`REG103);
  `SET_CFG_REG(`REG104);
  `SET_CFG_REG(`REG105);
  `SET_CFG_REG(`REG106);
  `SET_CFG_REG(`REG107);
  `SET_CFG_REG(`REG108);
  `SET_CFG_REG(`REG109);
  `SET_CFG_REG(`REG110);
  `SET_CFG_REG(`REG111);
  `SET_CFG_REG(`REG112);
  `SET_CFG_REG(`REG113);
  `SET_CFG_REG(`REG114);
  `SET_CFG_REG(`REG115);
  `SET_CFG_REG(`REG116);
  `SET_CFG_REG(`REG117);
  `SET_CFG_REG(`REG118);
  `SET_CFG_REG(`REG119);
  `SET_CFG_REG(`REG120);
  `SET_CFG_REG(`REG121);
  `SET_CFG_REG(`REG122);
  `SET_CFG_REG(`REG123);
  `SET_CFG_REG(`REG124);
  `SET_CFG_REG(`REG125);
  `SET_CFG_REG(`REG126);
  `SET_CFG_REG(`REG127);

// For Wavegen registers
  for (int i=0; i < `WAVEGEN_DRIVER_NUM; i++) begin
    `SET_CFG_WG_REG(`REG_WG0);
    `SET_CFG_WG_REG(`REG_WG1);
    `SET_CFG_WG_REG(`REG_WG2);
    `SET_CFG_WG_REG(`REG_WG3);
    `SET_CFG_WG_REG(`REG_WG4);
    `SET_CFG_WG_REG(`REG_WG5);
    `SET_CFG_WG_REG(`REG_WG6);
    `SET_CFG_WG_REG(`REG_WG7);
    `SET_CFG_WG_REG(`REG_WG8);
    `SET_CFG_WG_REG(`REG_WG9);
    `SET_CFG_WG_REG(`REG_WG10);
    `SET_CFG_WG_REG(`REG_WG11);
    `SET_CFG_WG_REG(`REG_WG12);
    `SET_CFG_WG_REG(`REG_WG13);
    `SET_CFG_WG_REG(`REG_WG14);
    `SET_CFG_WG_REG(`REG_WG15);
    `SET_CFG_WG_REG(`REG_WG16);
    `SET_CFG_WG_REG(`REG_WG17);
    `SET_CFG_WG_REG(`REG_WG18);
    `SET_CFG_WG_REG(`REG_WG19);
    `SET_CFG_WG_REG(`REG_WG20);
    `SET_CFG_WG_REG(`REG_WG21);
    `SET_CFG_WG_REG(`REG_WG22);
    `SET_CFG_WG_REG(`REG_WG23);
    `SET_CFG_WG_REG(`REG_WG24);
    `SET_CFG_WG_REG(`REG_WG25);
    `SET_CFG_WG_REG(`REG_WG26);
    `SET_CFG_WG_REG(`REG_WG27);
    `SET_CFG_WG_REG(`REG_WG28);
    `SET_CFG_WG_REG(`REG_WG29);
    `SET_CFG_WG_REG(`REG_WG30);
    `SET_CFG_WG_REG(`REG_WG31);
    `SET_CFG_WG_REG(`REG_WG32);
    `SET_CFG_WG_REG(`REG_WG33);
    `SET_CFG_WG_REG(`REG_WG34);
    `SET_CFG_WG_REG(`REG_WG35);
    `SET_CFG_WG_REG(`REG_WG36);
    `SET_CFG_WG_REG(`REG_WG37);
    `SET_CFG_WG_REG(`REG_WG38);
    `SET_CFG_WG_REG(`REG_WG39);
    `SET_CFG_WG_REG(`REG_WG40);
    `SET_CFG_WG_REG(`REG_WG41);
    `SET_CFG_WG_REG(`REG_WG42);
    `SET_CFG_WG_REG(`REG_WG43);
    `SET_CFG_WG_REG(`REG_WG44);
    `SET_CFG_WG_REG(`REG_WG45);
    `SET_CFG_WG_REG(`REG_WG46);
    `SET_CFG_WG_REG(`REG_WG47);
    `SET_CFG_WG_REG(`REG_WG48);
    `SET_CFG_WG_REG(`REG_WG49);
    `SET_CFG_WG_REG(`REG_WG50);
    `SET_CFG_WG_REG(`REG_WG51);
    `SET_CFG_WG_REG(`REG_WG52);
    `SET_CFG_WG_REG(`REG_WG53);
    `SET_CFG_WG_REG(`REG_WG54);
    `SET_CFG_WG_REG(`REG_WG55);
    `SET_CFG_WG_REG(`REG_WG56);
    `SET_CFG_WG_REG(`REG_WG57);
    `SET_CFG_WG_REG(`REG_WG58);
    `SET_CFG_WG_REG(`REG_WG59);
    `SET_CFG_WG_REG(`REG_WG60);
    `SET_CFG_WG_REG(`REG_WG61);
    `SET_CFG_WG_REG(`REG_WG62);
    `SET_CFG_WG_REG(`REG_WG63);
  end

  `nnc_info("build_phase", "Exiting...", NNC_HIGH)

endfunction : build_phase

//--------------------------------------------------------
// end_of_elaboration function declarations
//--------------------------------------------------------
function void `TESTNAME::end_of_elaboration_phase(nnc_phase phase);
  `nnc_info("end_of_elaboration_phase", "Entered...",NNC_HIGH);

  // Calling parent class to execute firstly
  super.end_of_elaboration_phase(phase);

`ifndef REGRESS_EN
  `nnc_top.print_topology();
`endif

  `nnc_info("end_of_elaboration_phase", "Exiting...",NNC_HIGH)
endfunction

//--------------------------------------------------------
// pre_reset task declarations
//--------------------------------------------------------
task `TESTNAME::pre_reset_phase(nnc_phase phase);
    phase.raise_objection(this);
   
    `SPI_SCB_EN = 1'b1;
    `WAVEGEN_SCB_DRV_0_EN = 1'b0;
    `CHIP_1_WAVEGEN_SCB_DRV_0_EN = 1'b0;
    `WAVEGEN_SCB_DRV_1_EN = 1'b0;
    `CHIP_1_WAVEGEN_SCB_DRV_1_EN = 1'b0;

    //`ifdef BEHAVIORAL
    `ANALOG_SCOREBOARD_EN = 1'b0;
    `PINMUX_SCOREBOARD_EN = 1'b0;
            
    //`endif

    // Inside Wavegen SB,pull source direction check is enabled only for RTL sims as it monitors internal state machine for checking
    `ifndef BEHAVIORAL
      `WAVEGEN_SCB_PULL_SOURCE_CHECK_EN = 1'b0;
      `CHIP_1_WAVEGEN_SCB_PULL_SOURCE_CHECK_EN = 1'b0;
      `WAVEGEN_SCB_PULL_SOURCE_CLK_CHECK_EN = 1'b0;
      `CHIP_1_WAVEGEN_SCB_PULL_SOURCE_CLK_CHECK_EN = 1'b0;
    `endif
    // Inside Wavegen SB, Short detection related interrupt counter compared with DUT internal counter so this check is enabled only for RTL sims
    `ifndef BEHAVIORAL
      `WAVEGEN_SHORT_SHORT_INTR_COUNTER_CHECK_EN = 1'b0;
      `CHIP_1_WAVEGEN_SHORT_SHORT_INTR_COUNTER_CHECK_EN = 1'b0;
      `ANAC_SHORT_LEADOFF_COUNTER_CHECK_EN =1'b0;
    `endif

    /*
    `DUT_IF.print_msg_disable = 0;

    // Disable scoreboard of OTP
    `OTP_SCOREBOARD_EN = 1'b0;

    // Disable scoreboard of analog
    `ANALOG_SCOREBOARD_EN = 1'b0;
    */

    // Start ramdomization
    assert(top_test_cfg.randomize());

    // Enable reset waiting
    `DUT_IF.wait_reset_en = top_test_cfg.wait_reset_en;

    // Set PCLK Clocks
    `DUT_IF.pclk_sel = top_test_cfg.pclk_sel;
    `DUT_IF.otp_tPGM = top_test_cfg.otp_tPGM;
    `DUT_IF.otp_tVPP = top_test_cfg.otp_tVPP;

    // Set ICLK clock
    `DUT_IF.iclk_sel = top_test_cfg.iclk_sel;

    `DUT_IF.imeas_adc_freq = top_test_cfg.imeas_adc_freq;

    `DUT_IF.cic_rate = top_test_cfg.imeas_cic_rate;

    `DUT_IF.imeas_osr = top_test_cfg.imeas_osr;

    `DUT_IF.imeas_samp_rate = top_test_cfg.imeas_samp_rate;

    // Set int_clk_out ctrl
    `DUT_IF.int_clk_out = top_test_cfg.int_clk_out;

    // Set SCLK clock
    `DUT_IF.spi_sclk_freq = top_test_cfg.spi_sclk_freq;

    // Set BIST clock frequency
    `DUT_IF.bistm_freq = top_test_cfg.bistm_freq;

    // Set BIST clock mode
    `DUT_IF.bistm_freq_sel = top_test_cfg.bistm_freq_sel;

    // Set BIST tPGM_RC
    `DUT_IF.bistm_tPGM_RC = top_test_cfg.bistm_tPGM_RC;
    `DUT_IF.bistm_tPGM = top_test_cfg.bistm_tPGM;

    // Select Polarity of CLK 
    `DUT_IF.spimode_sel = top_test_cfg.spimode_sel;

    // Select Operation mode for SOC 
    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;

    // Select ALTF mode for SOC PIN Configuration 
    `DUT_IF.altf_sel = top_test_cfg.altf_sel;

    // Set Jitter for PCLK 
    `DUT_IF.spi_clk_jitter = top_test_cfg.spi_clk_jitter;

    // Set Jitter for SCK
    `DUT_IF.spi_sclk_jitter  = top_test_cfg.spi_sclk_jitter;

    // Select internal/external clock sources
    `DUT_IF.ext_clk_en = top_test_cfg.ext_clk_en;			// 1: external EXT_300KHZ and EXT_32KHZ will be driven to SOC from model

    // 2Mhz jitter clock for both internal/external clock
    `DUT_IF.hfosc_jitter = top_test_cfg.hfosc_jitter; 

    // Clock variation of HFOSC
    `DUT_IF.hfosc_variation = top_test_cfg.hfosc_variation;

    // enable to fix 1'b0 to internal clk
    `DUT_IF.hfosc_fixed_gnd_en = top_test_cfg.hfosc_fixed_gnd_en;

    // enable to fix 1'b0 to ext clk
    `DUT_IF.ext_hfosc_fixed_gnd_en = top_test_cfg.ext_hfosc_fixed_gnd_en;

    `DUT_IF.fault_stuck0_clk_en = top_test_cfg.fault_stuck0_clk_en;     // 1: internal 32KHZ and 300KHZ will be LOW (can used when we set ext_clk_en)

    `DUT_IF.tcssc    = top_test_cfg.tcssc;
    `DUT_IF.tsccs    = top_test_cfg.tsccs;
    `DUT_IF.tcsh     = top_test_cfg.tcsh;
    `DUT_IF.tdist    = top_test_cfg.tdist;  
    `DUT_IF.tch      = top_test_cfg.tch; 

    `DUT_IF.config_in_base_test_en = top_test_cfg.config_in_base_test_en;

    `DUT_IF.wg_drv_sel = top_test_cfg.wg_drv_sel;

    `DUT_IF.hlf_wave_per = top_test_cfg.hlf_wave_per;

    `DUT_IF.dont_check_conf_first_en = top_test_cfg.dont_check_conf_first_en;

    `DUT_IF.A2D_comp_sel = top_test_cfg.A2D_comp_sel;

    `DUT_IF.A2D_stim_sel = top_test_cfg.A2D_stim_sel;

    `DUT_IF.altf_gpio_sel = 2'b00;

    `DUT_IF.TCK_SEL = top_test_cfg.TCK_SEL;

    `DUT_IF.bist_vpp_pin_en = top_test_cfg.bist_vpp_pin_en;

    `DUT_IF.pinmux_mode = top_test_cfg.pinmux_mode;

    `DUT_IF.mult_chip_en = top_test_cfg.mult_chip_en;
    `DUT_IF.mult_chip_mode = top_test_cfg.mult_chip_mode;
    `DUT_IF.mult_chip_same_clk_en = top_test_cfg.mult_chip_same_clk_en;

    `DUT_IF.A2D_comp0_in = top_test_cfg.A2D_comp0_in;
    `DUT_IF.A2D_comp1_in = top_test_cfg.A2D_comp1_in;

    `DUT_IF.A2D_comp_stim0_1_in = top_test_cfg.A2D_comp_stim0_1_in;
    `DUT_IF.A2D_comp_stim2_3_in = top_test_cfg.A2D_comp_stim2_3_in;

    `DUT_IF.swap_sdf_en = top_test_cfg.swap_sdf_en;

    `DUT_IF.high_clk = top_test_cfg.high_clk;
    `DUT_IF.low_clk = top_test_cfg.low_clk;

    `DUT_IF.otp_program_en = top_test_cfg.otp_program_en;
    `DUT_IF.otp_vpp_delay = top_test_cfg.otp_vpp_delay;

    `DUT_IF.gpio_pu_en = top_test_cfg.gpio_pu_en;
    `DUT_IF.gpio_pd_en = top_test_cfg.gpio_pd_en;

    `DUT_IF.python_check_en = top_test_cfg.python_check_en;
    `DUT_IF.python_length = top_test_cfg.python_length;

    `DUT_IF.io_model_check_off = top_test_cfg.io_model_check_off;

    for (int j=0;j < `NORMAL_REG_NUM; j++) 
      `DUT_IF.reg_normal[j] = top_test_cfg.reg_normal[j];

    for (int k=0;k < `WAVEGEN_DRIVER_OFFSET*`WAVEGEN_DRIVER_NUM; k++) 
      `DUT_IF.reg_wavegen[k] = top_test_cfg.reg_wavegen[k];

    `DUT_IF.VPP = top_test_cfg.VPP;
    `DUT_IF.spi_o_clk_sel = top_test_cfg.spi_o_clk_sel;

    `DUT_IF.mult_chip_typ = top_test_cfg.mult_chip_typ;

    `DUT_IF.short_leadoff_counter_cnt_debug_sel = top_test_cfg.short_leadoff_counter_cnt_debug_sel;

    `DUT_IF.lead_off_en = top_test_cfg.lead_off_en;
    `DUT_IF.lead_off_ch0_comp_low_active = top_test_cfg.lead_off_ch0_comp_low_active;
    `DUT_IF.lead_off_ch1_comp_low_active = top_test_cfg.lead_off_ch1_comp_low_active;
    `DUT_IF.short_en    = top_test_cfg.short_en;
    `DUT_IF.anac_stim_CH1_pol = top_test_cfg.anac_stim_CH1_pol;
    `DUT_IF.anac_stim_CH2_pol = top_test_cfg.anac_stim_CH2_pol;
    `DUT_IF.register_val_ch1 = top_test_cfg.register_val_ch1;
    `DUT_IF.register_val_ch2 = top_test_cfg.register_val_ch2;
    `DUT_IF.a2d_comp_delay_ch1 = top_test_cfg.a2d_comp_delay_ch1; 
    `DUT_IF.a2d_comp_delay_ch2 = top_test_cfg.a2d_comp_delay_ch2; 

    `DUT_IF.pulse_after_source = top_test_cfg.pulse_after_source;
    `DUT_IF.pulse_after_source_delay = top_test_cfg.pulse_after_source_delay;

    `DUT_IF.vbat_level = top_test_cfg.vbat_level;

    `DUT_IF.sensor_temperature = top_test_cfg.sensor_temperature;

    `DUT_IF.tsc_comp_low_active_en = top_test_cfg.tsc_comp_low_active_en;

    `DUT_IF.otp_ignore_check_en = top_test_cfg.otp_ignore_check_en;

    `DUT_IF.iclk_pmu_ctrl_en = top_test_cfg.iclk_pmu_ctrl_en;

    `DUT_IF.imeas_sin_gen_en = top_test_cfg.imeas_sin_gen_en;
    `DUT_IF.imeas_sin_expected_freq = top_test_cfg.imeas_sin_expected_freq;
    `DUT_IF.imeas_sin_freq_unit = top_test_cfg.imeas_sin_freq_unit;
    `DUT_IF.imeas_sin_no_clk_per_period = top_test_cfg.imeas_sin_no_clk_per_period;

    `DUT_IF.imeas_noise_gen_en = top_test_cfg.imeas_noise_gen_en;
    `DUT_IF.no_of_adc_dev1 = top_test_cfg.no_of_adc_dev1;
    `DUT_IF.no_of_adc_dev2 = top_test_cfg.no_of_adc_dev2;
    `DUT_IF.imeas_overlap_en = top_test_cfg.imeas_overlap_en;

    `DUT_IF.nirs_irefcoarse_length = top_test_cfg.nirs_irefcoarse_length;
    `DUT_IF.nirs_irefcoarse_iref_delay = top_test_cfg.nirs_irefcoarse_iref_delay;
    `DUT_IF.nirs_ireffine_length = top_test_cfg.nirs_irefcoarse_iref_delay;
   
    `DUT_IF.dump_level = top_test_cfg.dump_level;

    phase.drop_objection(this);
endtask : pre_reset_phase

//--------------------------------------------------------
// reset task declarations
//--------------------------------------------------------
task `TESTNAME::reset_phase(nnc_phase phase);
    phase.raise_objection(this);

    if (`DUT_IF.altf_sel !== 2'b00) begin      
       `DUT_IF.altf_gpio_sel = `DUT_IF.altf_sel;
       assert(top_test_cfg.randomize() with { testmode_sel == 2'b10; ADDR == 8'h00; data_in == 8'h5A; });
       // Change to Bist mode for SOC
       `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;
        #150us;

       `nnc_info("SOC_TEST", "[EPROM BIST MASTER][0] Sending Reset Command to EPROM", NNC_LOW);
       `BISTM_RESET;
       `nnc_info("SOC_TEST", "[EPROM BIST MASTER] Complete successully this phase", NNC_LOW);

       // Program OTP
`ifdef ENS2_PRODUCT
       `BISTM_SINGLE_PROGRAM(top_test_cfg.OTP_SEL, top_test_cfg.ADDR, top_test_cfg.data_in, top_test_cfg.vpp_pos_cnt, top_test_cfg.vpp_width);
`else
       `BISTM_SINGLE_PROGRAM(top_test_cfg.ADDR, top_test_cfg.data_in);
`endif
       assert(top_test_cfg.randomize() with { ADDR == 8'h0D; data_in == {6'h0, `DUT_IF.altf_sel}; });

`ifdef ENS2_PRODUCT
       `BISTM_SINGLE_PROGRAM(top_test_cfg.OTP_SEL, top_test_cfg.ADDR, top_test_cfg.data_in, top_test_cfg.vpp_pos_cnt, top_test_cfg.vpp_width);
`else
       `BISTM_SINGLE_PROGRAM(top_test_cfg.ADDR, top_test_cfg.data_in);
`endif
       `nnc_info("SOC_TEST", "[EPROM BIST MASTER][0] Sending Reset Command to EPROM", NNC_LOW);
       `BISTM_RESET;
       `nnc_info("SOC_TEST", "[EPROM BIST MASTER] Complete successully this phase", NNC_LOW);
       
       assert(top_test_cfg.randomize() with { testmode_sel == 2'b00;} );
       // Change to Normal mode for SOC
       `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;  
     
       `nnc_info("SOC_TEST", "Apply Reset via pin", NNC_LOW)
       `SOC_TB.ext_resetn=1'b0;
       #10us;
       `SOC_TB.ext_resetn=1'b1;
       #1ms;      
       //`RD_NORMAL_REG(`SOC_OTP_DEBUG_1_REG, 0, top_test_cfg.data[0]);
       //while (top_test_cfg.data[0][5] != 0) `RD_NORMAL_REG(`SOC_OTP_DEBUG_1_REG, 0, top_test_cfg.data[0]);
       //`DUT_IF.altf_gpio_sel = `DUT_IF.altf_sel;

    end

    if (`DUT_IF.testmode_sel === 2'b00) begin
     // fork
      if (`DUT_IF.wait_reset_en === 1'b1) begin
        `nnc_info("TOP - Normal", "Waiting for reset operation completely", NNC_LOW)
         wait(`DUT_IF.soc_resetn); // SOC Reset
        `nnc_info(get_type_name(), "Reset is done", NNC_MEDIUM)
        #1ms;
      end

      if (`DUT_IF.spi_o_clk_sel !== 1'b0) begin
        `nnc_info("SOC_TEST", "Single Writing to SOC_OUT_CLK_SEL_REG Register to use MULTI CHIP with Unaligned clock", NNC_LOW)
        `WR_NORMAL_REG(`SOC_OUT_CLK_SEL_REG, `INIT_SOC_OUT_CLK_SEL_REG | 8'b0000_0001, 8'h00);
      end

      if ((`DUT_IF.wait_reset_en === 1'b1) && (`DUT_IF.mult_chip_en === 1'b1)) begin
         `nnc_info("TOP - Normal", "Waiting for slave chip reset operation completely", NNC_LOW)
         if (`DUT_IF.swap_sdf_en === 1'b0)
              wait(`DUT_IF.soc_resetn_chipA); // SOC Reset
         else if (`DUT_IF.swap_sdf_en === 1'b1)
              wait(`DUT_IF.soc_resetn_chipB); // SOC Reset
         `nnc_info(get_type_name(), "Reset is done", NNC_MEDIUM)
         #1ms;
      end
 
      if (`DUT_IF.config_in_base_test_en === 1'b1) begin
        //if (`DUT_IF.mult_chip_en === 1'b1) begin
        //   top_test_cfg.no_of_bytes = 8'h0;
        //   top_test_cfg.data[0] = {4'b0, `DUT_IF.mult_chip_en, 3'b000};
        //   `nnc_info("SOC_TEST", "Single Writing to CLK_CTRL Register", NNC_LOW)
        //   `WR_NORMAL_REG(`SOC_CLK_CTRL_REG, top_test_cfg.data[0], 8'h00);
        //end else 
        if ((`DUT_IF.pclk_sel !== 3'b000) || ((`DUT_IF.iclk_sel !== 4'b0011) && (`DUT_IF.iclk_pmu_ctrl_en === 1'b1))) begin
          top_test_cfg.no_of_bytes = 8'h0;

          `nnc_info("SOC_TEST", "Single Writing to PMU_REG & SOC_ANAC_CTRL_REG Register to disable Wavegen, OTP, LEADOFF, TEMP_SAR & ANAC", NNC_LOW)
          `WR_NORMAL_REG(`SOC_PMU_REG, `INIT_SOC_PMU_REG | 8'b0101_1000, 8'h00);
          `WR_NORMAL_REG(`SOC_ANAC_CTRL_REG, `INIT_SOC_ANAC_CTRL_REG | 8'b0000_1001, 8'h00);

          top_test_cfg.data[0] = {`DUT_IF.iclk_sel, `DUT_IF.int_clk_out, `DUT_IF.pclk_sel};

          `nnc_info("SOC_TEST", "Single Writing to CLK_CTRL Register", NNC_LOW)
          `WR_NORMAL_REG(`SOC_CLK_CTRL_REG, top_test_cfg.data[0], 8'h00);

          `nnc_info("SOC_TEST", "Single Writing to PMU_REG & SOC_ANAC_CTRL_REG Register to default", NNC_LOW)
          `WR_NORMAL_REG(`SOC_PMU_REG, `INIT_SOC_PMU_REG, 8'h00);
          `WR_NORMAL_REG(`SOC_ANAC_CTRL_REG, `INIT_SOC_ANAC_CTRL_REG, 8'h00);
        end
      end
    end
    else
      if (`DUT_IF.wait_reset_en) begin
        `nnc_info("TOP - Not normal", "Waiting for reset operation completely", NNC_LOW)
        wait(`DUT_IF.soc_resetn);// SPIS Reset
        `nnc_info(get_type_name(), "Reset is done", NNC_MEDIUM)
      end
    `DUT_IF.print_msg_disable = 1;

    phase.drop_objection(this);
endtask : reset_phase

//--------------------------------------------------------
// post_reset task declarations
//--------------------------------------------------------
/*
task `TESTNAME::post_reset_phase(nnc_phase phase);
    phase.raise_objection(this);
    phase.drop_objection(this);
endtask : post_reset_phase
*/

//--------------------------------------------------------
// pre_main task declarations
//--------------------------------------------------------
task `TESTNAME::pre_main_phase(nnc_phase phase);
    phase.raise_objection(this);

    // Disable scoreboard of SPIS
   `ifndef BEHAVIORAL 
  //  `SPIS_SCOREBOARD_EN = 1'b0;
   `endif

    `nnc_info ("pre_main_phase", "Exiting...", NNC_HIGH)
    phase.drop_objection(this);
endtask

//--------------------------------------------------------
// main task declarations
//--------------------------------------------------------
task `TESTNAME::main_phase(nnc_phase phase);

  logic [15:0]    randomNumber0;
  logic [15:0]    biasednumber;
  logic [15:0]    randomNumber;

  phase.raise_objection(this);
  `nnc_info("main_phase", "Entered...",NNC_HIGH);
/*  
  if (`DUT_IF.mult_chip_en === 1'b1) begin
     top_test_cfg.no_of_bytes = 8'h0;
     top_test_cfg.data[0] = {4'b0, `DUT_IF.mult_chip_en, `DUT_IF.pclk_sel};
     `nnc_info("SOC_TEST", "Single Writing to CLK_CTRL Register", NNC_LOW)
     `WR_NORMAL_REG(`SOC_CLK_CTRL_REG, top_test_cfg.data[0], 8'h00);
  end  
*/
/*
  fork
    begin
      #300ms;
      `uvm_info ("main_phase", "timeout...", NNC_LOW)
      $finish;
    end
  join_none
*/

  fork
    begin
      forever begin
        repeat(400) @(posedge`DUT_IF.sys_clk);
        randomNumber0 = $urandom_range(10,0);
        //if((randomNumber0 === 1) | (randomNumber0 === 3) | (randomNumber0 === 5) | (randomNumber0 === 8)) begin
        if((randomNumber0 === 5) | (randomNumber0 === 8)) begin
	    //`DUT_IF.A2D_comp0_in = ~`DUT_IF.A2D_comp0_in;
	    //`DUT_IF.A2D_comp1_in = ~`DUT_IF.A2D_comp1_in;
            biasednumber = $urandom_range(10,0);
            if(`DUT_IF.lead_off_ch0_comp_low_active == 0)begin 
	      `DUT_IF.A2D_comp0_in = (biasednumber <=2 ) ? {$random}%2 : 0;
            end
            else begin
	      `DUT_IF.A2D_comp0_in = (biasednumber <=2 ) ? {$random}%2 : 1;
            end

            if(`DUT_IF.lead_off_ch1_comp_low_active == 0)begin 
	      `DUT_IF.A2D_comp1_in = (biasednumber <=2 ) ? {$random}%2 : 0;
            end
            else begin
	      `DUT_IF.A2D_comp1_in = (biasednumber <=2 ) ? {$random}%2 : 1;
            end
        end
        else begin
            if(`DUT_IF.lead_off_ch0_comp_low_active == 0)begin 
	      `DUT_IF.A2D_comp0_in = 0;
            end
            else begin
	      `DUT_IF.A2D_comp0_in = 1;
            end

            if(`DUT_IF.lead_off_ch1_comp_low_active == 0)begin 
	      `DUT_IF.A2D_comp1_in = 0;
            end
            else begin
	      `DUT_IF.A2D_comp1_in = 1;
            end
	    //`DUT_IF.A2D_comp0_in = ~`DUT_IF.A2D_comp0_in;
	    //`DUT_IF.A2D_comp1_in = ~`DUT_IF.A2D_comp1_in;
        end
      end
    end
  join_none

  fork
    begin
      forever begin
        repeat(400) @(posedge`DUT_IF.sys_clk);
        randomNumber = $urandom_range(10,0);
        if((randomNumber === 1) | (randomNumber === 3) | (randomNumber === 5) | (randomNumber === 8)) begin
	    `DUT_IF.A2D_comp_stim0_1_in = {$random}%2;
	    `DUT_IF.A2D_comp_stim2_3_in = {$random}%2;
        end
        else begin
	    `DUT_IF.A2D_comp_stim0_1_in = ~`DUT_IF.A2D_comp_stim0_1_in;
	    `DUT_IF.A2D_comp_stim2_3_in = ~`DUT_IF.A2D_comp_stim2_3_in;
        end
      end
    end
  join_none

  `nnc_info ("main_phase", "Exiting...", NNC_HIGH)
  phase.drop_objection(this);
endtask

//--------------------------------------------------------
// report function declarations
//--------------------------------------------------------
function void `TESTNAME::report_phase(nnc_phase phase) ;

  nnc_report_server report;
  `nnc_info("report_phase", "Entered...", NNC_HIGH)

  super.report_phase(phase);
  report = nnc_report_server::get_server();

  if (top_env.top_sqr.dut_if.err_cnt != 0)
    `nnc_error("TEST", $sformatf("ERROR is happened during the test simulation with no of err_cnt = %d", top_env.top_sqr.dut_if.err_cnt))
    
  if((report.get_severity_count(NNC_ERROR) == 0) && (report.get_severity_count(NNC_FATAL) == 0)) begin
      $display("\n\n");
      $display("\t                    _____________________________________                    ");
      $display("\t                   /                                     \                   ");
      $display("\t ////////////////////.          TEST PASSED            ./////////////////////");
      $display("\t                   \_____________________________________/                   ");
  end
  else begin
      $display("\n");
      $display("\t                          _________________________                          ");
      $display("\t                         X                         X                         ");
      $display("\t///////////////////XXXXXX       TEST FAILED         XXXXXX///////////////////");
      $display("\t                         X_________________________X                         ");
      $display("\n");
  end
      $display("\n");
      $display("                              Summary                                        ");
      $display("-----------------------------------------------------------------------------");
      $display("   NNC_FATAL Count   :  %3d",report.get_severity_count(NNC_FATAL));
      $display("   NNC_ERROR Count   :  %3d",report.get_severity_count(NNC_ERROR));
      $display("   NNC_WARNING Count :  %3d",report.get_severity_count(NNC_WARNING));
      $display("   NNC_INFO  Count   :  %3d",report.get_severity_count(NNC_INFO));

endfunction

// Register class
class nnc_register;
  string name;
  logic [7:0] address;
  logic [7:0] default_value;
  logic [7:0] mask_value;
  logic [7:0] access;
  logic [7:0] pads;
  logic wavegen_reg;

  function new(string name, logic[7:0] address, logic[7:0] default_value, logic[7:0] mask_value, logic[7:0] access, logic wavegen_reg);
    this.name = name;
    this.address = address;
    this.default_value = default_value;
    this.mask_value = mask_value;
    this.access = access;
    this.wavegen_reg = wavegen_reg;
    this.pads = 'h0;
    `nnc_info("SOC_TEST", $sformatf("create nnc_register for addr %0h", address),NNC_MEDIUM);
  endfunction

  // Read method
  task read_init();
    // Read data from address
    if(^address !== 1'bx)begin
      if(wavegen_reg)begin
	`nnc_info("SOC_TEST", $sformatf("read_init :: wavegen reg address %0h", address),NNC_MEDIUM);
        `RD_RESET_CHK_WAVEGEN_REG(address, default_value, pads);
      end
      else begin
	`nnc_info("SOC_TEST", $sformatf("read_init :: normal reg address %0h, default_value %h", address, default_value),NNC_MEDIUM);
        `RD_RESET_CHK_NORMAL_REG(address, default_value, pads);
      end
    end
    else begin
      `nnc_info("SOC_TEST", $sformatf("Register do not exist for read_init:: address %0h", address),UVM_DEBUG);
    end
  endtask

  // Write method
  task write_read(input bit[7:0] wr_data);
    // Perform write access 
    if(^address !== 1'bx)begin
      if (access === 1) begin //WO - write only
        if(wavegen_reg) begin
	  `nnc_info("SOC_TEST", $sformatf("write_read WO :: wavegen reg address %0h", address),NNC_MEDIUM);
          `WR_WAVEGEN_REG(address, wr_data, pads);
        end
        else begin
	  `nnc_info("SOC_TEST", $sformatf("write_read WO :: normal reg address %0h", address),NNC_MEDIUM);
          `WR_NORMAL_REG(address, wr_data, pads);
        end
      end
      if (access === 3) begin //WR - write and read
        if(wavegen_reg)begin
	  `nnc_info("SOC_TEST", $sformatf("write_read WR :: wavegen reg address %0h", address),NNC_MEDIUM);
          `WR_RD_CHK_WAVEGEN_REG(address, wr_data, pads, mask_value);
        end
        else begin
	  `nnc_info("SOC_TEST", $sformatf("write_read WR :: normal reg address %0h", address),NNC_MEDIUM);
          `WR_RD_CHK_NORMAL_REG(address, wr_data, pads, mask_value);
        end
      end
      else begin
      // error for writing in read only register 
      end
    end
    else begin
      `nnc_info("SOC_TEST", $sformatf("Register do not exist for write_read:: address %0h", address),UVM_DEBUG);
    end
  endtask

  task check_reserved_regs(input logic [7:0]reserved_addr,input bit[7:0] wr_data);
    logic [7:0] rd_data;
    if(wavegen_reg)begin
      `nnc_info("SOC_TEST", $sformatf("check_reserved_regs WR :: wavegen reg address %0h", reserved_addr),NNC_MEDIUM);
      `WR_WAVEGEN_REG(reserved_addr, wr_data, pads);
      `RD_WAVEGEN_REG(reserved_addr, pads, rd_data);
      if(rd_data !== 8'h0)`nnc_error("TEST", $sformatf("check_reserved_regs WR :: for wavegen reg reserved addr =%0h , read_data=%0h exp=8'h0",reserved_addr,rd_data))
    end
    else begin
      `nnc_info("SOC_TEST", $sformatf("check_reserved_regs WR :: normal reg address %0h", reserved_addr),NNC_MEDIUM);
      `WR_NORMAL_REG(reserved_addr, wr_data, pads);
      `RD_NORMAL_REG(reserved_addr, pads, rd_data);
      if(rd_data !== 8'h0)`nnc_error("TEST", $sformatf("check_reserved_regs WR :: for normal reg reserved addr =%0h , read_data=%0h exp=8'h0",reserved_addr,rd_data))
    end
  endtask
endclass
`endif

