//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project     : ENS2
// Module Name : spi_reg
// Description : register block contains config and status registers 
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author
//------------------------------------------------------------------------------
// 0.1          8/09/2022  Jayanthi 
// 0.2          2026       Daniel Dang (revise code)
// Initial Rev
//------------------------------------------------------------------------------

//`include "spi_defines_default_ana_trim.v"

// analog register define
`define DEFINE_DEFAULT_ANA_ENABLE_REG_0		8'h00
`define DEFINE_DEFAULT_ANA_ENABLE_REG_1		8'h02
`define DEFINE_DEFAULT_ANA_ENABLE_REG_2         8'h00
`define DEFINE_DEFAULT_ANA_ENABLE_REG_3         8'h00
//`define DEFINE_DEFAULT_ANA_ENABLE_REG_4         8'h00	 
//`define DEFINE_DEFAULT_ANA_ENABLE_REG_5         8'h00
`define DEFINE_DEFAULT_ANA_GEN_REG_1	        8'h04	
`define DEFINE_DEFAULT_ANA_GEN_REG_2		8'h00
`define DEFINE_DEFAULT_ANA_GEN_REG_3		8'h00
`define DEFINE_DEFAULT_ANA_GEN_REG_4		8'h00	 
`define DEFINE_DEFAULT_ANA_GEN_REG_5		8'h00
`define DEFINE_DEFAULT_ANA_GEN_REG_6		8'h00
`define DEFINE_DEFAULT_ANA_GEN_REG_7		8'h00
`define DEFINE_DEFAULT_ANA_GEN_REG_8		8'h00
`define DEFINE_DEFAULT_ANA_GEN_REG_9		8'h00

// system ctrl
`define  SYSTEM_CTRL_BASE_ADDR          8'h01
`define  PMU_REG0		        `SYSTEM_CTRL_BASE_ADDR+8'h00//01
`define  CLK_CTRL_REG                   `SYSTEM_CTRL_BASE_ADDR+8'h01//02
`define  WAVEGEN_GLOBAL_REG             `SYSTEM_CTRL_BASE_ADDR+8'h02//03
`define  ANAC_CTRL                      `SYSTEM_CTRL_BASE_ADDR+8'h03//04
`define  PMU_REG1		        `SYSTEM_CTRL_BASE_ADDR+8'h04//05
`define  O_CLK_SEL		        `SYSTEM_CTRL_BASE_ADDR+8'h05//06
`define  WAVEGEN_GLOBAL_REG01           `SYSTEM_CTRL_BASE_ADDR+8'h06//07
`define  WAVEGEN_GLOBAL_REG02           `SYSTEM_CTRL_BASE_ADDR+8'h07//08

 //spare reg `SYSTEM_CTRL_BASE_ADDR + 8'h06~`SYSTEM_CTRL_BASE_ADDR + 8'h08//07~09

// OTP Registers
`define  OTP_BASE_ADDR                  8'h0A
`define  OTP_DEBUG1                     `OTP_BASE_ADDR+8'h00//0a
`define  OTP_DEBUG2                     `OTP_BASE_ADDR+8'h01//0b
`define  OTP_TRIMDATA0                  `OTP_BASE_ADDR+8'h02//0c
`define  OTP_TRIMDATA1                  `OTP_BASE_ADDR+8'h03//0d
`define  OTP_TRIMDATA2                  `OTP_BASE_ADDR+8'h04//0e
`define  OTP_TRIMDATA3                  `OTP_BASE_ADDR+8'h05//0f
`define  OTP_TRIMDATA4                  `OTP_BASE_ADDR+8'h06//10
`define  OTP_TRIMDATA5                  `OTP_BASE_ADDR+8'h07//11
`define  OTP_TRIMDATA6                  `OTP_BASE_ADDR+8'h08//12
`define  OTP_TRIMDATA7	                `OTP_BASE_ADDR+8'h09//13
`define  OTP_TRIMDATA8	                `OTP_BASE_ADDR+8'h0A//14

`define  OTP_TRIMDATA9	                `OTP_BASE_ADDR+8'h0B//15
`define  OTP_TRIMDATA10	                `OTP_BASE_ADDR+8'h0C//16
`define  OTP_TRIMDATA11	                `OTP_BASE_ADDR+8'h0D//17
`define  OTP_TRIMDATA12	                `OTP_BASE_ADDR+8'h0E//18
`define  OTP_TRIMDATA13	                `OTP_BASE_ADDR+8'h0F//19
`define  OTP_TRIMDATA14	                `OTP_BASE_ADDR+8'h10//1a
`define  OTP_TRIMDATA15	                `OTP_BASE_ADDR+8'h11//1b
`define  OTP_TRIMDATA16	                `OTP_BASE_ADDR+8'h12//1c


`define  OTP_UNLOCK                     `OTP_BASE_ADDR+8'h13//1d
`define  OTP_DATA                       `OTP_BASE_ADDR+8'h14//1e  
`define  OTP_ADDR                       `OTP_BASE_ADDR+8'h15//1f   
`define  OTP_MEM_DATA                   `OTP_BASE_ADDR+8'h16//20 
`define  OTP_WAVEGEN_NUMBER             `OTP_BASE_ADDR+8'h17//21 

//spare reg `OTP_BASE_ADDR + 8'h10~`OTP_BASE_ADDR + 8'h15//1a~1F

// gpio
`define  GPIO_BASE_ADDR                 8'h30
`define  GPIO_PU_CTRL                   `GPIO_BASE_ADDR+8'h00//30
`define  GPIO_PD_CTRL                   `GPIO_BASE_ADDR+8'h01//31
`define  GPIO_SR_PDRV0_1_CTRL           `GPIO_BASE_ADDR+8'h02//32
`define  GPIO_NIRS_OUT_CTRL             `GPIO_BASE_ADDR+8'h03//33
`define  GPIO_NORMAL_OUT_CTRL           `GPIO_BASE_ADDR+8'h04//34
 //spare reg `GPIO_BASE_ADDR + 8'h03~`GPIO_BASE_ADDR + 8'h05//23~25

// lead_off
//`define  LEAD_OFF_BASE_ADDR               8'h26
//`define  LEAD_OFF_CTRL                    `LEAD_OFF_BASE_ADDR+8'h00//26
//`define  LEAD_OFF_TGT                     `LEAD_OFF_BASE_ADDR+8'h01//27
//`define  LEAD_OFF_INT                     `LEAD_OFF_BASE_ADDR+8'h02//28
//`define  COUNTER_TH_TGT_0                 `LEAD_OFF_BASE_ADDR+8'h03//29
//`define  COUNTER_TH_TGT_1                 `LEAD_OFF_BASE_ADDR+8'h04//2A
//`define  COUNTER_TH_TGT_2                 `LEAD_OFF_BASE_ADDR+8'h05//2B
//`define  COUNTER_TH_TGT_3                 `LEAD_OFF_BASE_ADDR+8'h06//2C
//`define  TIMER_CNT_TGT_0                  `LEAD_OFF_BASE_ADDR+8'h07//2D
//`define  TIMER_CNT_TGT_1                  `LEAD_OFF_BASE_ADDR+8'h08//2E
//`define  TIMER_CNT_TGT_2                  `LEAD_OFF_BASE_ADDR+8'h09//2F
//`define  TIMER_CNT_TGT_3                  `LEAD_OFF_BASE_ADDR+8'h0A//30
//`define  LEAD_OFF_BLK_SLCT 		  `LEAD_OFF_BASE_ADDR+8'h0B//31
//`define  LEAD_OFF_DAC_EN 		  `LEAD_OFF_BASE_ADDR+8'h0C//32
//`define  LEAD_OFF_STOP_EN 		  `LEAD_OFF_BASE_ADDR+8'h0D//33
//`define  LEAD_OFF_INT_EN 		  `LEAD_OFF_BASE_ADDR+8'h0E//34
//`define  LEAD_OFF_COMP_LOW_EN 		  `LEAD_OFF_BASE_ADDR+8'h0F//35
//`define  LEAD_OFF_STOP 		  	  `LEAD_OFF_BASE_ADDR+8'h10//36
//
//`define  LEAD_OFF_ANA                     `LEAD_OFF_BASE_ADDR+8'h13//39


//`define  COUNTER_TH_TGT1_0                `LEAD_OFF_BASE_ADDR+8'h0B//31
//`define  COUNTER_TH_TGT1_1                `LEAD_OFF_BASE_ADDR+8'h0C//32
//`define  COUNTER_TH_TGT1_2                `LEAD_OFF_BASE_ADDR+8'h0D//33
//`define  COUNTER_TH_TGT1_3                `LEAD_OFF_BASE_ADDR+8'h0E//34
//`define  TIMER_CNT_TGT1_0                 `LEAD_OFF_BASE_ADDR+8'h0F//35
//`define  TIMER_CNT_TGT1_1                 `LEAD_OFF_BASE_ADDR+8'h10//36
//`define  TIMER_CNT_TGT1_2                 `LEAD_OFF_BASE_ADDR+8'h11//37
//`define  TIMER_CNT_TGT1_3                 `LEAD_OFF_BASE_ADDR+8'h12//38

 //spare reg `LEAD_OFF_BASE_ADDR + 8'h14~`LEAD_OFF_BASE_ADDR + 8'h19//3A~3F

`define  STIM_PAD_CTRL               8'h40 // 
`define  STIM_MON_PERIOD_L           8'h41 // 
`define  STIM_MON_PERIOD_H           8'h42 // 
`define  STIM_MON_CTRL2            8'h43 // 
`define  STIM_ADC_DATA_TAG_L         8'h44 // 
`define  STIM_ADC_DATA_TAG_H         8'h45 // 
`define  STIM_MON_INT_STS            8'h46 // 

`define  STIM_PAD_CTRL1         8'h47 // 

`define  STIM_PAD0_TGT0_L         8'h48 // 
`define  STIM_PAD0_TGT0_H         8'h49 // 
`define  STIM_PAD0_TGT1_L         8'h4A // 
`define  STIM_PAD0_TGT1_H         8'h4B // 
`define  STIM_PAD0_TGT2_L         8'h4C // 
`define  STIM_PAD0_TGT2_H         8'h4D // 
`define  STIM_PAD0_TGT3_L         8'h4E // 
`define  STIM_PAD0_TGT3_H         8'h4F // 

// analog register define
//My add

`define  ANA_EN_BASE_ADDR           8'hC0 // 2 Enable sections
`define  ANA_EN_SECTION_SEL         `ANA_EN_BASE_ADDR+8'h00//C0
`define  ANA_ENABLE_REG_0           `ANA_EN_BASE_ADDR+8'h01//C1
`define  ANA_ENABLE_REG_1           `ANA_EN_BASE_ADDR+8'h02//C2
`define  ANA_ENABLE_REG_2           `ANA_EN_BASE_ADDR+8'h03//C3
`define  ANA_ENABLE_REG_3           `ANA_EN_BASE_ADDR+8'h04//C4
`define  ANA_ENABLE_REG_4           `ANA_EN_BASE_ADDR+8'h05//C5
`define  ANA_ENABLE_REG_5           `ANA_EN_BASE_ADDR+8'h06//C6
`define  ANA_ENABLE_REG_6           `ANA_EN_BASE_ADDR+8'h07//C7
`define  ANA_ENABLE_REG_7           `ANA_EN_BASE_ADDR+8'h08//C8
`define  ANA_ENABLE_REG_8           `ANA_EN_BASE_ADDR+8'h09//C9
`define  ANA_ENABLE_REG_9           `ANA_EN_BASE_ADDR+8'h0A//CA
`define  ANA_ENABLE_REG_10          `ANA_EN_BASE_ADDR+8'h0B//CB
`define  ANA_ENABLE_REG_11          `ANA_EN_BASE_ADDR+8'h0C//CC
`define  ANA_ENABLE_REG_12          `ANA_EN_BASE_ADDR+8'h0D//CD
`define  ANA_ENABLE_REG_13          `ANA_EN_BASE_ADDR+8'h0E//CE
`define  ANA_ENABLE_REG_14          `ANA_EN_BASE_ADDR+8'h0F//CF
 
`define  ANA_REG_BASE_ADDR          8'hD0 // 8 GEN sections
`define  ANA_GEN_SECTION_SEL        `ANA_REG_BASE_ADDR+8'h00//D0
`define  ANA_GEN_REG_1              `ANA_REG_BASE_ADDR+8'h01//D1
`define  ANA_GEN_REG_2              `ANA_REG_BASE_ADDR+8'h02//D2
`define  ANA_GEN_REG_3              `ANA_REG_BASE_ADDR+8'h03//D3
`define  ANA_GEN_REG_4              `ANA_REG_BASE_ADDR+8'h04//D4
`define  ANA_GEN_REG_5              `ANA_REG_BASE_ADDR+8'h05//D5
`define  ANA_GEN_REG_6              `ANA_REG_BASE_ADDR+8'h06//D6
`define  ANA_GEN_REG_7              `ANA_REG_BASE_ADDR+8'h07//D7
`define  ANA_GEN_REG_8              `ANA_REG_BASE_ADDR+8'h08//D8
`define  ANA_GEN_REG_9              `ANA_REG_BASE_ADDR+8'h09//D9
`define  ANA_GEN_REG_10             `ANA_REG_BASE_ADDR+8'h0A//DA
`define  ANA_GEN_REG_11             `ANA_REG_BASE_ADDR+8'h0B//DB
`define  ANA_GEN_REG_12             `ANA_REG_BASE_ADDR+8'h0C//DC
`define  ANA_GEN_REG_13             `ANA_REG_BASE_ADDR+8'h0D//DD
`define  ANA_GEN_REG_14             `ANA_REG_BASE_ADDR+8'h0E//DE -SPARE
`define  ANA_GEN_REG_15             `ANA_REG_BASE_ADDR+8'h0F//DF - AJD

`define  A2D_ANA_REG_BASE_ADDR          8'hA0 
`define  A2D_ANA_GEN_REG_0          `A2D_ANA_REG_BASE_ADDR+8'h00//E0
`define  A2D_ANA_GEN_REG_1          `A2D_ANA_REG_BASE_ADDR+8'h01//E1
`define  A2D_ANA_GEN_REG_2          `A2D_ANA_REG_BASE_ADDR+8'h02//E2
`define  A2D_ANA_GEN_REG_3          `A2D_ANA_REG_BASE_ADDR+8'h03//E3
`define  A2D_ANA_GEN_REG_4          `A2D_ANA_REG_BASE_ADDR+8'h04//E4
`define  A2D_ANA_GEN_REG_5          `A2D_ANA_REG_BASE_ADDR+8'h05//E4


 //spare reg `ANA_REG_BASE_ADDR + 8'h0F//4F

// anac
`define  ANA_SHORT_BASE_ADDR             8'h50
`define  ANAC_LVD_INT_EN                 `ANA_SHORT_BASE_ADDR+8'h00//50

`define  STIM_MON_LOFF_INT_STS0               `ANA_SHORT_BASE_ADDR+8'h01//51
`define  STIM_MON_LOFF_INT_STS1               `ANA_SHORT_BASE_ADDR+8'h02//52
`define  STIM_MON_SHORT_INT_STS0               `ANA_SHORT_BASE_ADDR+8'h03//53
`define  STIM_MON_SHORT_INT_STS1               `ANA_SHORT_BASE_ADDR+8'h04//54
`define  STIM_MON_LOFF_SHORT_INT_CTRL           `ANA_SHORT_BASE_ADDR+8'h05//55
`define  STIM_MON_LOFF_TH0           		`ANA_SHORT_BASE_ADDR+8'h06//56
`define  STIM_MON_LOFF_TH1           		`ANA_SHORT_BASE_ADDR+8'h07//57
`define  STIM_MON_SHORT_TH0           		`ANA_SHORT_BASE_ADDR+8'h08//58
`define  STIM_MON_SHORT_TH1           		`ANA_SHORT_BASE_ADDR+8'h09//59
`define  STIM_MON_TH_TGT           		`ANA_SHORT_BASE_ADDR+8'h0A//5A


//`define  ANAC_COMP_INT_EN                `ANA_SHORT_BASE_ADDR+8'h01//51
//`define  ANAC_COMP_INT_TRANS_SEL         `ANA_SHORT_BASE_ADDR+8'h02//52
//`define  ANA_INT_SOTP_WAVEGEN            `ANA_SHORT_BASE_ADDR+8'h03//53
//`define  ANAC_STIMU_INT_EN               `ANA_SHORT_BASE_ADDR+8'h04//54
//`define  ANAC_STIMU_INT_DIG_EN           `ANA_SHORT_BASE_ADDR+8'h05//55
//`define  ANAC_STIMU_INT_POL_EN           `ANA_SHORT_BASE_ADDR+8'h06//56
//`define  ANAC_SHORT_BLK_SLCT             `ANA_SHORT_BASE_ADDR+8'h07//57
//`define  ANA_STIM_CH_TIMER_CNT_TH00      `ANA_SHORT_BASE_ADDR+8'h08//58           
//`define  ANA_STIM_CH_TIMER_CNT_TH01      `ANA_SHORT_BASE_ADDR+8'h09//59            
//`define  ANA_STIM_CH_TIMER_CNT_TH02      `ANA_SHORT_BASE_ADDR+8'h0A//5A            
//`define  ANA_STIM_CH_TIMER_CNT_TH03      `ANA_SHORT_BASE_ADDR+8'h0B//5B            
//`define  ANA_STIM_CH_COUNTER_CNT_TH00    `ANA_SHORT_BASE_ADDR+8'h0C//5C
//`define  ANA_STIM_CH_COUNTER_CNT_TH01    `ANA_SHORT_BASE_ADDR+8'h0D//5D
//`define  ANA_STIM_CH_COUNTER_CNT_TH02    `ANA_SHORT_BASE_ADDR+8'h0E//5E
//`define  ANA_STIM_CH_COUNTER_CNT_TH03    `ANA_SHORT_BASE_ADDR+8'h0F//5F
//`define  ANA_INT_STIMU_STS               `ANA_SHORT_BASE_ADDR+8'h10//60  
//`define  ANA_INT_COMP_STS                `ANA_SHORT_BASE_ADDR+8'h11//61
`define  ANA_INT_LVD_STS                 `ANA_SHORT_BASE_ADDR+8'h12//62

 //spare reg `ANA_SHORT_BASE_ADDR + 8'h13~`ANA_SHORT_BASE_ADDR+8'h0A//62~6A

// tsc
`define VDAC_NOR_L			8'h69  //change from 73h to 69h   //xin
`define SMP_STS			 	8'h6A   //change from 74h to 6Ah    //xin	
`define TSC_BASE_ADDR                   8'h6B
`define TSC_EN_REG_SEL		        `TSC_BASE_ADDR+8'h00//6b
`define TSC_CTRL			`TSC_BASE_ADDR+8'h01//6c
`define SMP_DURATION			`TSC_BASE_ADDR+8'h02//6d
`define STABLE_DURATION_L		`TSC_BASE_ADDR+8'h03//6e
`define STABLE_DURATION_H		`TSC_BASE_ADDR+8'h04//6f
`define TSC_VDAC8B_DIN_CH1              `TSC_BASE_ADDR+8'h05//70
`define TSC_INT_CRTL      		`TSC_BASE_ADDR+8'h06//71
`define TSC_INT_STATUS   		`TSC_BASE_ADDR+8'h07//72
//`define VDAC_NOR_L			`TSC_BASE_ADDR+8'h08//73   //change
//`define SMP_STS		 	`TSC_BASE_ADDR+8'h09//74   //change
 //spare reg `TSC_BASE_ADDR + 8'h0a~`TSC_BASE_ADDR+8'h0c//75~77

// int read
//`define  INT_REG_BASE_ADDR               8'h78
`define  GENERAL_INTERUPT_STATUS_REG07   8'h73  //new add for stim
`define  GENERAL_INTERUPT_STATUS_REG08   8'h74  //new add for stim
`define  GENERAL_INTERUPT_STATUS_REG09   8'h75  //new add for stim
`define  GENERAL_INTERUPT_STATUS_REG0A   8'h76  //new add for stim
`define  GENERAL_INTERUPT_STATUS_REG0B   8'h77  //new add for stim

`define  INT_REG_BASE_ADDR               8'h78     
`define  GENERAL_INTERUPT_CTRL_REG       `INT_REG_BASE_ADDR+8'h00  //78  
`define  GENERAL_INTERUPT_STATUS_REG01   `INT_REG_BASE_ADDR+8'h01  //79  
`define  GENERAL_INTERUPT_STATUS_REG02   `INT_REG_BASE_ADDR+8'h02  //7A  
`define  GENERAL_INTERUPT_STATUS_REG03   `INT_REG_BASE_ADDR+8'h03  //7B  
`define  GENERAL_INTERUPT_STATUS_REG04   `INT_REG_BASE_ADDR+8'h04  //7C  
`define  GENERAL_INTERUPT_STATUS_REG05   `INT_REG_BASE_ADDR+8'h05  //7D  
 //spare reg `TSC_REG_BASE_ADDR + 8'h04~`TSC_REG_BASE_ADDR+8'h05//7C~7D
`define  GENERAL_INTERUPT_STATUS_REG06   `INT_REG_BASE_ADDR+8'h06  //7E  


//pinmux
`define  PINMUX_REG_BASE_ADDR            8'h7F
`define  ATM_HC_SEL                      `PINMUX_REG_BASE_ADDR+8'h00
//spare reg `PINMUX_REG_BASE_ADDR + 8'h01//7F

// debug
`define  DEBUG_REG_BASE_ADDR             8'h80
//`define  COUNTER_CNT_DBG_SEL             `DEBUG_REG_BASE_ADDR+8'h00//80
//`define  COUNTER_CNT_DBG_0               `DEBUG_REG_BASE_ADDR+8'h01//81
//`define  COUNTER_CNT_DBG_1               `DEBUG_REG_BASE_ADDR+8'h02//82
//`define  COUNTER_CNT_DBG_2               `DEBUG_REG_BASE_ADDR+8'h03//83
//`define  COUNTER_CNT_DBG_3               `DEBUG_REG_BASE_ADDR+8'h04//84
//`define  LEAD_OFF_COUNTER_CNT       `DEBUG_REG_BASE_ADDR+8'h05//85
//`define  LEAD_OFF_COUNTER_CNT       `DEBUG_REG_BASE_ADDR+8'h06//86

`define  OTP_TRIMS_DBG_SEL               `DEBUG_REG_BASE_ADDR+8'h07//87
`define  OTP_TRIMS_DBG_DATA              `DEBUG_REG_BASE_ADDR+8'h08//88

`define IMEAS_REG_BASE_ADDR             8'h90
`define IMEAS_REG_0                     `IMEAS_REG_BASE_ADDR+8'h00
`define IMEAS_REG_1                     `IMEAS_REG_BASE_ADDR+8'h01 
`define IMEAS_REG_2                     `IMEAS_REG_BASE_ADDR+8'h02 
`define STABLE_TIME_0                   `IMEAS_REG_BASE_ADDR+8'h03 
`define STABLE_TIME_1                   `IMEAS_REG_BASE_ADDR+8'h04 
`define IMEAS_D0                        `IMEAS_REG_BASE_ADDR+8'h05 
`define IMEAS_D1                        `IMEAS_REG_BASE_ADDR+8'h06 
`define IMEAS_D2                        `IMEAS_REG_BASE_ADDR+8'h07 
`define IMEAS_D3                        `IMEAS_REG_BASE_ADDR+8'h08 
`define IMEAS_CTRL                      `IMEAS_REG_BASE_ADDR+8'h09 
`define IMEAS_EN_DIS_CHN_L              `IMEAS_REG_BASE_ADDR+8'h0A 
`define IMEAS_EN_DIS_CHN_H              `IMEAS_REG_BASE_ADDR+8'h0B 

`define FILTER_REG_BASE_ADDR             8'hB0
//`define FILTER_SEQ_CTRL                  `FILTER_REG_BASE_ADDR +8'h00
`define FILTER_HPF_BP_L                  `FILTER_REG_BASE_ADDR +8'h01
`define FILTER_HPF_BP_H                  `FILTER_REG_BASE_ADDR +8'h02
`define FILTER_LPF_BP_L                  `FILTER_REG_BASE_ADDR +8'h03
`define FILTER_LPF_BP_H                  `FILTER_REG_BASE_ADDR +8'h04
`define FILTER_NOF_BP_L                  `FILTER_REG_BASE_ADDR +8'h05
`define FILTER_NOF_BP_H                  `FILTER_REG_BASE_ADDR +8'h06
`define FILTER_INT_CTRL                  `FILTER_REG_BASE_ADDR +8'h07
`define FILTER_INT_STS                   `FILTER_REG_BASE_ADDR +8'h08
`define FILTER_NOTCH_DATA_GONE_L         `FILTER_REG_BASE_ADDR +8'h09
`define FILTER_NOTCH_DATA_GONE_H         `FILTER_REG_BASE_ADDR +8'h0A
`define FILTER_COEFF_ADDR                `FILTER_REG_BASE_ADDR +8'h0B
`define FILTER_COEFF_DATA1               `FILTER_REG_BASE_ADDR +8'h0C
`define FILTER_COEFF_DATA2               `FILTER_REG_BASE_ADDR +8'h0D
`define FILTER_COEFF_DATA3               `FILTER_REG_BASE_ADDR +8'h0E


`define FILTER_DLY_TGT_0                   8'hF0 
`define FILTER_DLY_TGT_1                   8'hF1 
`define FILTER_DLY_TGT_2                   8'hF2 
`define FILTER_SYNC_CTRL                   8'hF3 

`define  STIM_ADC_DELTA_DATA_TAG_L      8'hF6 // 
`define  STIM_ADC_DELTA_DATA_TAG_H      8'hF7 // 
`define  STIM_PAD1_TGT0_L         8'hF8 // 
`define  STIM_PAD1_TGT0_H         8'hF9 // 
`define  STIM_PAD1_TGT1_L         8'hFA // 
`define  STIM_PAD1_TGT1_H         8'hFB // 
`define  STIM_PAD1_TGT2_L         8'hFC // 
`define  STIM_PAD1_TGT2_H         8'hFD // 
`define  STIM_PAD1_TGT3_L         8'hFE // 
`define  STIM_PAD1_TGT3_H         8'hFF // 

`timescale 1ns/1ps
module spi_reg #(
  parameter ADDR_WIDTH =8,
  parameter DATA_WIDTH =8,
  parameter HLF_WV_NO_PTS = 6, 
  parameter OUT_NO_BITS = 12,
  parameter EEG_CHN_NUM = 16,
  parameter NO_OF_WAVEGEN=8,
  parameter NO_OF_NIRS = 8)
(
  // inputs
  spi_otp.master         spi_otp,
  spi_wg.master          spi_wg,
  spi_anac.master        spi_anac,
//spi_leadoff.master        spi_leadoff,

  input                  i_clk,
  input                  i_rst_n,
  input		               atpg_en,
  input [ADDR_WIDTH-1:0] i_addr,
  input                  i_wr,
  input                  i_rd,
  input                  wavegen_cmd_reg,
  input                  i_wavegen_wr,
  input                  i_wavegen_rd,
  
  input                  nirs_cmd_reg,
  input                  i_nirs_wr,
  input                  i_nirs_rd,

  input [DATA_WIDTH-1:0] i_wr_data  ,
//input                  i_addr_vld_for_int_clr,
//input                  i_burst_cmd,
//input [ADDR_WIDTH-1:0] i_pre_addr,
        
  // outputs
  spi_ana_if.spi          spi_ana_if,
  spi_pinmux_if.spi       spi_pinmux_if,
  spi_nirs_if.spi         spi_nirs_if,

  output [DATA_WIDTH-1:0] o_rd_data, 

  output reg              stim_eeg_sync_en,
  output reg[23:0]        filter_dly_tgt,
        
  // system outputs
  // inputs from other blocks
       
  output  reg  	          o_clk_sel,

  output wire        bypass_adc_data_en,   //from spi
  output wire        bypass_ignore_first,   //from spi
  output wire [3:0]       stim_dly_tgt,   //from spi
  output wire [4:0]       stim_mon_int_en,   //from spi
  output wire [4:0]       stim_mon_int_topin_en,   //from spi
  output reg  [1:0]       stim_mon_delta_data_sel,   //from spi
  output reg              stim_mon_int_clr,   //from spi
  input  wire             stim_mon_int_sts,   //to spi

  output reg  adc_delta_data_cap_in_manual,
  output reg  select_2nd_max_min,

  output wire multi_intb_pin,

  input  wire [255:0] one_cycle_data,

  output reg              stim_mon_delta_int_clr,   //from spi
  input  wire             stim_mon_delta_int_sts,   //to spi
  output reg              stim_mon_cycle_int_clr,   //from spi
  input  wire             stim_mon_cycle_int_sts,   //to spi

output reg[15:0]  stim_mon_leadoff_int_clr,   //from spi
input wire[15:0] stim_mon_leadoff_int_sts,   //to spi
output reg [15:0] stim_mon_short_int_clr,   //from spi
input wire[15:0] stim_mon_short_int_sts,   //to spi

output reg [9:0] threshold_leadoff,  	
output reg [9:0] threshold_short,  	
output reg [7:0] threshold_tgt,

output wire  check_everyN,

  output wire             adc_en,
  output wire             adc_mode,
  output wire [15:0]      adc_cap_period,
  output wire [3:0]       pair_num,
  output wire [15:0] [3:0] stim_pad0_tgt,
  output wire [15:0] [3:0] stim_pad1_tgt,
  output wire [3:0]       iclk_div_stim_monitor ,
  output wire             iclk_stim_monitor_inv, 
  output wire             stim_monitor_rst_reg, 
  input  wire [15:0]      A2D_ADC_DATA_TAG,
  input  wire [15:0]      A2D_ADC_DELTA_DATA_TAG,

  //imeas       
  input   wire [23:0]     imeas_chdata[EEG_CHN_NUM-1:0],

  output  wire 	          reset_cmd,
  output  wire 	          start_cmd,
  output  wire 	          stop_cmd,
//output  wire 	          wakeup_cmd,
//output  wire 	          standby_cmd,
  output  wire 	          single_shot,

  output                  imeas_en,
  output  reg  [7:0]      imeas_reg_0,
  output  wire [15:0]     imeas_en_chn,
  output  wire [3:0]      DR,
  output  wire            daisy_en,
  output  wire [1:0]      mode,
  output  wire [3:0]      iclk_div,
  output  wire [2:0]      iclk_div_ina_pga,
  output  wire            iclk_ina_pga_disable,
  output                  imeas_adc_inv,
  output                  cic_rst,
  output  wire [15:0]     stable_time,

  output  wire            ppg_dis,           //ppg disble 
  output  wire  [1:0]     ppg_clk_div,       // ppg clock divider
  output  wire            ana_ppgclk_inv,   // ana ppg clock 
  output  wire            ppg_clk50duty,            
  output  wire 	          ppg_rst_reg,

  // ========================
  output  wire  	  otp_rst_reg,
  output  wire  	  dig_rst_reg,
  //output  wire  	  lead_off_rst,
  //output  wire  	  lead_off_en,

//input  wire [NO_OF_WAVEGEN-1:0]  	A2D_COMP0_7,   
 
  output reg   [7:0]  	  en_reg_sel,
  output reg   [7:0]      tsc_vdac8b_din_ch1,
  output wire             tsc_comp_low_ch1,
  output wire             tsc_vdac8b_en_ch1,
  output wire  		  tsc_comp_en_ch1,
  output wire  	          tsc_en_ch1,
  input  wire  [7:0]      VDAC_NOR,
 
  output wire 	          ana_lvd_sts,

  // clk_ctrl
//output  wire            o_fclk_dynen,
//output  wire  [1:0]     o_pclk_div,
  output  wire  [2:0]     o_pclk_div,
  output  wire            o_int_clk_out,
  output  wire            int_length_slct, 
  output  wire  [2:0]     PROD_ID,

  // gpio
  output wire [7:0]       gpio_pu_ctrl,
  output wire [7:0]       gpio_pd_ctrl,
  output wire [2:0]       gpio_sr_pdrv0_1_ctrl,
  output wire             gpio_nirs_out_ctrl,
  output wire             gpio_normal_out_ctrl,
         
  output  wire            tsc_intr_en, 
  output  wire            tsc_intr_trans_sel,
  output  reg             tsc_intr_sts_clr,
  input   wire 	          tsc_intr_sts,
       
  // PMU
  output  wire            o_pmuenable,            // pmu enable
  output  wire            o_hresetreq,            // system reset request
  output  wire            o_sleepdeep,            // system enters deep-sleep state
  output  wire            o_otp_dpstb_en,        // otp deep power down standby mode enable 
  output  wire            anac_clock_en,
  output  wire            temp_sar_clock_dis,
  output  wire            anac_reset,
  output  reg [7:0]       sample_duration,
  output  reg [11:0]      stable_duration,
  input   wire            busy_doing,
  output  wire            temp_sar_reset,
//output  wire            o_fclk_sleep_en,

  output wire  [EEG_CHN_NUM-1:0]      o_notch_filter_bypass,
  output wire  [EEG_CHN_NUM-1:0]      o_lpf_filter_bypass,
  output wire  [EEG_CHN_NUM-1:0]      o_hpf_filter_bypass,
//  output reg  [2:0]     filter_seq,
  output reg  [1:0]       eeg_int_en,
  output reg              eeg_int_clr,
  input  wire             eeg_int_sts,
  output reg  [15:0]      cic_data_ignore_tar,

  output wire [17:0]      lpf_coeff_data_o[27:0],
  output wire [19:0]      notch_coeff_data_o[23:0],
  output wire [23:0]      hpf_coeff_data_o,
  input  reg  [14:0]      atm_adj_mode,
  input  reg              atm_adj,
  input  reg  [7:0]       atm_adj_data,
 //wave gen
  output  wire 	          o_wave_gen_dis,
  output  wire 	          o_wave_gen_rst
);

//reg [3:0] counter_cnt_dbg_sel;
//wire [31:0]  counter_cnt_dbg;

//assign   counter_cnt_dbg = (counter_cnt_dbg_sel == 2'b00) ? counter1_th_cnt_dbg :
//                           (counter_cnt_dbg_sel == 2'b01) ? counter2_th_cnt_dbg :
//                           (counter_cnt_dbg_sel == 2'b10) ? lead_off_Counter_cnt_dac0_final_dbg :
//                           (counter_cnt_dbg_sel == 2'b11) ? lead_off_Counter_cnt_dac1_final_dbg : counter1_th_cnt_dbg;

////////////////previous analog registers///////////
/// Analog Registers
 reg  [1:0] ana_pmu;     
 // ana_tsc
 reg  [7:0] ana_tsc_0;
 reg        ana_tsc_1;
 // Peripheral
 reg [3:0]  ana_bist;
 reg [3:0]  ana_dda; 
 reg [5:0]  ana_pga;
 reg [3:0]  ana_ele;
 reg  [1:0] ana_sdm;
 
 reg [7:0]  comp0_ctrl_reg;     
 reg [6:0]  comp1_ctrl_reg;     
 reg [6:0]  pga_ctrl0_reg;      
 reg [5:0]  pga_ctrl1_reg;      
 reg [4:0]  charge_ctrl0_reg;   
 reg [2:0]  charge_ctrl1_reg;   
 reg [5:0]  pmu_ctrl_reg;       
 reg [6:0]  boost_ctrl0_reg;   
 reg [6:0]  boost_ctrl1_reg;    
 reg [7:0]  boost_ctrl2_reg;    
 reg [6:0]  ana_bist0_reg;      
 reg [7:0]  ana_bist1_reg;
 
 wire       comp0_out;
 wire       comp1_out;
 wire       charger_ok;
 wire       charger_end;
 wire       lvd_out;
 wire       temp_150c_trig;
 wire       boost_oc;
 wire       boost_ot;
 wire       boost_ov;   
 wire [7:0] ATM_MODE;
 wire       int_clear_type;
 wire       int_active_level;

////////////////////////////////////////


 // internal reg and signals declaration
 reg [7:0]	reg_rd_data;
 
 // clk_ctr_reg
 reg [7:0]	clk_ctrl_reg;
 // pmu
 reg [7:0] 	pmu_reg0;
 reg [1:0] 	pmu_reg1;
 //reg  		o_clk_sel;
 wire  		lead_off_dis;

//bps imeas
 reg [7:0]      imeas_reg_1;
 reg [7:0]      imeas_reg_2;
 reg [7:0]      imeas_ctrl;
 reg [7:0]      stable_time_0;
 reg [7:0]      stable_time_1;
//=============

 //analog reg
 wire [7:0]     A2D_ANA_GEN_REG_0;
 wire [7:0]     A2D_ANA_GEN_REG_1;
 wire [7:0]     A2D_ANA_GEN_REG_2;
 wire [7:0]     A2D_ANA_GEN_REG_3;
 wire [7:0]     A2D_ANA_GEN_REG_4;
 wire [7:0]     A2D_ANA_GEN_REG_5;

 wire [7:0]     A2D_SPARE_RO_REG_0;

 reg            ana_en_sec_reg;//My add
 reg [2:0]      ana_gen_sec_reg;
 
 reg [7:0]      ana_gen_reg [7:0][14:0];
 reg [7:0]      ana_enable_reg [1:0][14:0];
 reg [7:0]      a2d_ana_gen_reg  [7:0];

 reg            drivea_global_en;
 reg            wavegen_burst_slct;
 reg            stimu_en;
 reg [1:0]      drive_slct_03_47;
 
 reg [1:0]      atm_hc_sel_reg;

 reg [7:0]      wavegen_reg_acc_0_7;
 reg [7:0]      wavegen_reg_acc_8_15;


 //bps function
 wire [3:0]     imeas_data_sel;

 wire 	        wakeup_cmd;
 wire 	        standby_cmd;

assign wakeup_cmd  = imeas_reg_2[2:0] == 3'h0;
assign standby_cmd = imeas_reg_2[2:0] == 3'h1;
assign start_cmd   = imeas_reg_2[2:0] == 3'h2;
assign stop_cmd    = imeas_reg_2[2:0] == 3'h3;
assign reset_cmd   = imeas_reg_2[2:0] == 3'h4;

//bps function
//wire [3:0]    imeas_data_sel;
//assign          wakeup_cmd =    imeas_reg_2[2:0] == 3'h0;
//assign          standby_cmd =   imeas_reg_2[2:0] == 3'h1;
//assign          start_cmd =     imeas_reg_2[2:0] == 3'h2;
//assign          stop_cmd =      imeas_reg_2[2:0] == 3'h3;
//assign          reset_cmd =     imeas_reg_2[2:0] == 3'h4;
//wire dummy_cmd;
//assign          dummy_cmd =     imeas_reg_2[2:0] == 3'h7;

assign single_shot    = imeas_ctrl[3];
assign imeas_data_sel = imeas_ctrl[7:4];

reg[23:0] imeas_chdata_wire;

assign imeas_chdata_wire = (imeas_data_sel < EEG_CHN_NUM)?imeas_chdata[imeas_data_sel] : imeas_chdata[4'd0];

//always @(*) begin
//  case(imeas_data_sel)
//    4'h0 : imeas_chdata_wire = imeas_chdata[4'd0];
//    4'h1 : imeas_chdata_wire = imeas_chdata[4'd1];
//    4'h2 : imeas_chdata_wire = imeas_chdata[4'd2];
//    4'h3 : imeas_chdata_wire = imeas_chdata[4'd3];
//    4'h4 : imeas_chdata_wire = imeas_chdata[4'd4];
//    4'h5 : imeas_chdata_wire = imeas_chdata[4'd5];
//    4'h6 : imeas_chdata_wire = imeas_chdata[4'd6];
//    4'h7 : imeas_chdata_wire = imeas_chdata[4'd7];
//    4'h8 : imeas_chdata_wire = imeas_chdata[4'd8];
//    4'h9 : imeas_chdata_wire = imeas_chdata[4'd9];
//    4'hA : imeas_chdata_wire = imeas_chdata[4'd10];
//    4'hB : imeas_chdata_wire = imeas_chdata[4'd11];
//    4'hC : imeas_chdata_wire = imeas_chdata[4'd12];
//    4'hD : imeas_chdata_wire = imeas_chdata[4'd13];
//    4'hE : imeas_chdata_wire = imeas_chdata[4'd14];
//    4'hF : imeas_chdata_wire = imeas_chdata[4'd15];
//    default: imeas_chdata_wire = imeas_chdata[4'd0];
//  endcase
//end

//assign iclk_div = imeas_reg_1[7:4];
assign DR            = imeas_reg_1[3:0];
assign daisy_en      = imeas_reg_1[4];
assign mode          = imeas_reg_1[6:5];

assign imeas_en      = imeas_reg_0[0];
assign cic_rst       = imeas_reg_0[1];
assign imeas_adc_inv = imeas_reg_0[4];

assign stable_time   = {stable_time_1,stable_time_0};
 
//-----------------------------------------------------------------------------------
//------------------------------------config register write---------------------------
//------------------------------------------------------------------------------------
reg[7:0]  anac_ctrl;
assign anac_clock_en      = anac_ctrl[0];
assign anac_reset         = anac_ctrl[1];
assign temp_sar_reset     = anac_ctrl[2];
assign temp_sar_clock_dis = anac_ctrl[3];

assign iclk_ina_pga_disable = anac_ctrl[7];
assign iclk_div_ina_pga = anac_ctrl[6:4];

reg [3:0]  tsc_ctrl;
reg [1:0]  tsc_int_crtl_reg;

assign  tsc_comp_low_ch1  = tsc_ctrl[3];
assign  tsc_vdac8b_en_ch1 = tsc_ctrl[2];
assign  tsc_comp_en_ch1   = tsc_ctrl[1];
assign  tsc_en_ch1        = tsc_ctrl[0];

assign  tsc_intr_en       = tsc_int_crtl_reg[0];
assign  tsc_intr_trans_sel= tsc_int_crtl_reg[1];

reg [7:0] 	imeas_en_dis_chn_l;
reg [7:0] 	imeas_en_dis_chn_h;

assign 	imeas_en_chn = {~imeas_en_dis_chn_h, ~imeas_en_dis_chn_l};

always @(posedge i_clk or negedge i_rst_n) begin
  if (!i_rst_n)begin
    // pmu ctrl
    pmu_reg0             <= 8'h41;  
    pmu_reg1             <= 2'b10;  
    o_clk_sel            <= 1'h0;  
    //bps imeas
    imeas_en_dis_chn_l   <= 8'b0;
    imeas_en_dis_chn_h   <= 8'b0;
    imeas_reg_0          <= 8'h18;
    imeas_reg_1          <= 8'h27;
    imeas_reg_2          <= 8'h0;
    imeas_ctrl           <= 8'h0;
    stable_time_0        <= 8'h10;
    stable_time_1        <= 8'h0;
    // clk_ctrl
    clk_ctrl_reg         <= 8'h30; 
    anac_ctrl            <= 8'h30;
    tsc_ctrl             <= 4'b0;
    sample_duration      <= 8'h10;
    stable_duration      <= 12'h1ff;
    en_reg_sel           <= 8'b0;
    tsc_vdac8b_din_ch1   <= 8'hFF;    
    drivea_global_en     <= 1'b0;
    wavegen_burst_slct   <= 1'b0;
    wavegen_reg_acc_0_7  <= 8'h00;
    wavegen_reg_acc_8_15 <= 8'h00;

    stimu_en             <= 1'b0;
    drive_slct_03_47     <= 2'b0;
 // counter_cnt_dbg_sel  <= 4'b0;
    atm_hc_sel_reg       <= 2'b0;
    tsc_int_crtl_reg     <= 2'b0;
    tsc_intr_sts_clr     <= 1'b0;
  end
  else begin
    case(i_addr[ADDR_WIDTH-1:0])   	
      //imeas
      `IMEAS_EN_DIS_CHN_L        : imeas_en_dis_chn_l 	<= i_wr  ?  i_wr_data[7:0] : imeas_en_dis_chn_l[7:0];
      `IMEAS_EN_DIS_CHN_H        : imeas_en_dis_chn_h 	<= i_wr  ?  i_wr_data[7:0] : imeas_en_dis_chn_h[7:0];
      `IMEAS_REG_0               : imeas_reg_0          <= i_wr  ?  i_wr_data[7:0] : imeas_reg_0[7:0];
      `IMEAS_REG_1               : imeas_reg_1          <= i_wr  ?  i_wr_data[7:0] : imeas_reg_1[7:0];
      `IMEAS_REG_2               : imeas_reg_2          <= i_wr  ?  i_wr_data[7:0] : imeas_reg_2[7:0];
      `IMEAS_CTRL                : imeas_ctrl           <= i_wr  ?  i_wr_data[7:0] : imeas_ctrl [7:0];
      `STABLE_TIME_0             : stable_time_0        <= i_wr  ?  i_wr_data[7:0] : stable_time_0[7:0];
      `STABLE_TIME_1             : stable_time_1        <= i_wr  ?  i_wr_data[7:0] : stable_time_1[7:0];
      // pmu 
      `PMU_REG0         	 : pmu_reg0              <= i_wr  ?  i_wr_data[7:0] : pmu_reg0[7:0];
      `PMU_REG1         	 : pmu_reg1              <= i_wr  ?  i_wr_data[1:0] : pmu_reg1[1:0];
      `O_CLK_SEL         	 : o_clk_sel             <= i_wr  ?  i_wr_data[0]   : o_clk_sel;
      // clk_ctrl  
      `CLK_CTRL_REG      	 : clk_ctrl_reg          <=  i_wr ?  i_wr_data[7:0]: clk_ctrl_reg;
      `ANAC_CTRL                 : anac_ctrl             <=  i_wr ?  i_wr_data[7:0]: anac_ctrl;
      `TSC_EN_REG_SEL            : en_reg_sel            <=  i_wr ?  i_wr_data[7:0]: en_reg_sel;
      `TSC_CTRL                  : tsc_ctrl              <=  i_wr ?  i_wr_data[3:0]: tsc_ctrl;
      `TSC_VDAC8B_DIN_CH1        : tsc_vdac8b_din_ch1    <=  i_wr ?  i_wr_data[7:0]: tsc_vdac8b_din_ch1;
      `TSC_INT_CRTL              : tsc_int_crtl_reg      <=  i_wr ?  i_wr_data[1:0]: tsc_int_crtl_reg;
      `TSC_INT_STATUS            : tsc_intr_sts_clr      <= (i_wr & !int_clear_type)? i_wr_data[0]: (i_rd & int_clear_type)? {tsc_intr_sts & i_rd} : 1'b0;
      `SMP_DURATION	         : sample_duration       <=  i_wr ?  i_wr_data[7:0]: sample_duration;		
      `STABLE_DURATION_L	 : stable_duration[7:0]  <=  i_wr ?  i_wr_data[7:0]: stable_duration[7:0];		
      `STABLE_DURATION_H	 : stable_duration[11:8] <=  i_wr ?  i_wr_data[3:0]: stable_duration[11:8];		

      `WAVEGEN_GLOBAL_REG        :  {wavegen_burst_slct,stimu_en,drive_slct_03_47,drivea_global_en}         <= i_wr ? i_wr_data[4:0]   : {wavegen_burst_slct,stimu_en,drive_slct_03_47,drivea_global_en};
      `WAVEGEN_GLOBAL_REG01      :  wavegen_reg_acc_0_7  <= i_wr ? i_wr_data[7:0]   : wavegen_reg_acc_0_7;
      `WAVEGEN_GLOBAL_REG02      :  wavegen_reg_acc_8_15 <= i_wr ? i_wr_data[7:0]   : wavegen_reg_acc_8_15;

      `ATM_HC_SEL                :  atm_hc_sel_reg            <= i_wr ? i_wr_data[1:0] : atm_hc_sel_reg;
      //  default :  begin  
      //            end
    endcase  
  end
end

//for stim_mon_adc
reg [7:0] stim_pad_ctrl;
reg [7:0] stim_pad_ctrl1;
reg [7:0] stim_mon_period_l;
reg [7:0] stim_mon_period_h;
reg [6:0] stim_mon_ctrl2;
reg [7:0] stim_pad0_tgt0_l;
reg [7:0] stim_pad0_tgt0_h;
reg [7:0] stim_pad0_tgt1_l;
reg [7:0] stim_pad0_tgt1_h;
reg [7:0] stim_pad0_tgt2_l;
reg [7:0] stim_pad0_tgt2_h;
reg [7:0] stim_pad0_tgt3_l;
reg [7:0] stim_pad0_tgt3_h;
reg [7:0] stim_pad1_tgt0_l;
reg [7:0] stim_pad1_tgt0_h;
reg [7:0] stim_pad1_tgt1_l;
reg [7:0] stim_pad1_tgt1_h;
reg [7:0] stim_pad1_tgt2_l;
reg [7:0] stim_pad1_tgt2_h;
reg [7:0] stim_pad1_tgt3_l;
reg [7:0] stim_pad1_tgt3_h;

reg[7:0] stim_mon_loff_short_int_ctrl; //3:0 is for int en
					//5:4 
wire read_adc_data_en;
assign bypass_adc_data_en = stim_pad_ctrl1[7];
assign read_adc_data_en = stim_pad_ctrl1[6];
assign bypass_ignore_first = stim_pad_ctrl1[5];
assign adc_en = stim_pad_ctrl1[4];
assign stim_dly_tgt = stim_pad_ctrl1[3:0];

reg[2:0] stim_mon_int_topin_en_reg;
assign stim_mon_int_topin_en = {stim_mon_loff_short_int_ctrl[3:2],stim_mon_int_topin_en_reg} ;   //from spi
assign stim_mon_int_en = {stim_mon_loff_short_int_ctrl[1:0],stim_pad_ctrl[7:5]};   //from spi
assign adc_mode = stim_pad_ctrl[4];
assign pair_num = stim_pad_ctrl[3:0];
assign adc_cap_period = {stim_mon_period_h,stim_mon_period_l};
assign iclk_div_stim_monitor = stim_mon_ctrl2[3:0];
assign iclk_stim_monitor_inv = stim_mon_ctrl2[4];
assign stim_monitor_rst_reg = stim_mon_ctrl2[5];
assign check_everyN = stim_mon_ctrl2[6];

assign stim_pad0_tgt[0]  = stim_pad0_tgt0_l[3:0];
assign stim_pad0_tgt[1]  = stim_pad0_tgt0_l[7:4];
assign stim_pad0_tgt[2]  = stim_pad0_tgt0_h[3:0];
assign stim_pad0_tgt[3]  = stim_pad0_tgt0_h[7:4];
assign stim_pad0_tgt[4]  = stim_pad0_tgt1_l[3:0];
assign stim_pad0_tgt[5]  = stim_pad0_tgt1_l[7:4];
assign stim_pad0_tgt[6]  = stim_pad0_tgt1_h[3:0];
assign stim_pad0_tgt[7]  = stim_pad0_tgt1_h[7:4];
assign stim_pad0_tgt[8]  = stim_pad0_tgt2_l[3:0];
assign stim_pad0_tgt[9]  = stim_pad0_tgt2_l[7:4];
assign stim_pad0_tgt[10] = stim_pad0_tgt2_h[3:0];
assign stim_pad0_tgt[11] = stim_pad0_tgt2_h[7:4];
assign stim_pad0_tgt[12] = stim_pad0_tgt3_l[3:0];
assign stim_pad0_tgt[13] = stim_pad0_tgt3_l[7:4];
assign stim_pad0_tgt[14] = stim_pad0_tgt3_h[3:0];
assign stim_pad0_tgt[15] = stim_pad0_tgt3_h[7:4];

assign stim_pad1_tgt[0]  = stim_pad1_tgt0_l[3:0];
assign stim_pad1_tgt[1]  = stim_pad1_tgt0_l[7:4];
assign stim_pad1_tgt[2]  = stim_pad1_tgt0_h[3:0];
assign stim_pad1_tgt[3]  = stim_pad1_tgt0_h[7:4];
assign stim_pad1_tgt[4]  = stim_pad1_tgt1_l[3:0];
assign stim_pad1_tgt[5]  = stim_pad1_tgt1_l[7:4];
assign stim_pad1_tgt[6]  = stim_pad1_tgt1_h[3:0];
assign stim_pad1_tgt[7]  = stim_pad1_tgt1_h[7:4];
assign stim_pad1_tgt[8]  = stim_pad1_tgt2_l[3:0];
assign stim_pad1_tgt[9]  = stim_pad1_tgt2_l[7:4];
assign stim_pad1_tgt[10] = stim_pad1_tgt2_h[3:0];
assign stim_pad1_tgt[11] = stim_pad1_tgt2_h[7:4];
assign stim_pad1_tgt[12] = stim_pad1_tgt3_l[3:0];
assign stim_pad1_tgt[13] = stim_pad1_tgt3_l[7:4];
assign stim_pad1_tgt[14] = stim_pad1_tgt3_h[3:0];
assign stim_pad1_tgt[15] = stim_pad1_tgt3_h[7:4];

/*
assign stim_pad0_tgt = {stim_pad0_tgt3_h,stim_pad0_tgt3_l,
                        stim_pad0_tgt2_h,stim_pad0_tgt2_l,
			stim_pad0_tgt1_h,stim_pad0_tgt1_l,
			stim_pad0_tgt0_h,stim_pad0_tgt0_l};
assign stim_pad1_tgt = {stim_pad1_tgt3_h,stim_pad1_tgt3_l,
                        stim_pad1_tgt2_h,stim_pad1_tgt2_l,
                        stim_pad1_tgt1_h,stim_pad1_tgt1_l,
                        stim_pad1_tgt0_h,stim_pad1_tgt0_l};
*/
genvar g_i;
generate
    for (g_i = 0; g_i < 8; g_i = g_i + 1) begin : gen_bit_ctrl
always @(posedge i_clk or negedge i_rst_n) begin
  if (!i_rst_n)begin
	stim_mon_leadoff_int_clr[g_i] <= 1'b0;   //from spi
	stim_mon_leadoff_int_clr[8+g_i] <= 1'b0;   //from spi
	stim_mon_short_int_clr[g_i] <= 1'b0;   //from spi
	stim_mon_short_int_clr[8+g_i] <= 1'b0;   //from spi
   end else begin
	stim_mon_leadoff_int_clr[g_i]   <= 1'b0;
        stim_mon_leadoff_int_clr[8+g_i] <= 1'b0;
        stim_mon_short_int_clr[g_i]     <= 1'b0;
        stim_mon_short_int_clr[8+g_i]   <= 1'b0;	
     case (i_addr[7:0])
	`STIM_MON_LOFF_INT_STS0, `GENERAL_INTERUPT_STATUS_REG07 : begin
				 stim_mon_leadoff_int_clr[g_i]    <= (i_wr & !int_clear_type)? i_wr_data[g_i]: (i_rd & int_clear_type)? (stim_mon_leadoff_int_sts[g_i] & i_rd) : 1'b0;
			   end             
`STIM_MON_LOFF_INT_STS1, `GENERAL_INTERUPT_STATUS_REG08 : begin
				 stim_mon_leadoff_int_clr[8+g_i]    <= (i_wr & !int_clear_type)? i_wr_data[g_i]: (i_rd & int_clear_type)? (stim_mon_leadoff_int_sts[8+g_i] & i_rd) : 1'b0;
			   end             
`STIM_MON_SHORT_INT_STS0, `GENERAL_INTERUPT_STATUS_REG09 : begin
				 stim_mon_short_int_clr[g_i]    <= (i_wr & !int_clear_type)? i_wr_data[g_i]: (i_rd & int_clear_type)? (stim_mon_short_int_sts[g_i] & i_rd) : 1'b0;
			   end             
`STIM_MON_SHORT_INT_STS1, `GENERAL_INTERUPT_STATUS_REG0A : begin
				 stim_mon_short_int_clr[8+g_i]    <= (i_wr & !int_clear_type)? i_wr_data[g_i]: (i_rd & int_clear_type)? (stim_mon_short_int_sts[8+g_i] & i_rd) : 1'b0;
			   end             
default: ;
    endcase
  end
end
end
endgenerate

always @(posedge i_clk or negedge i_rst_n) begin
  if (!i_rst_n)begin
	stim_mon_int_topin_en_reg <= 3'b0;   //from spi
	stim_mon_delta_data_sel <= 2'b0;   //from spi
	stim_pad_ctrl        <= 8'hF;
	stim_pad_ctrl1        <= 8'h20;
	stim_mon_period_l    <= 8'h0;
	stim_mon_period_h    <= 8'h0;
	stim_mon_ctrl2<= 7'h04;
	stim_pad0_tgt0_l     <= 8'h10;
	stim_pad0_tgt0_h     <= 8'h32;
	stim_pad0_tgt1_l     <= 8'h54;
	stim_pad0_tgt1_h     <= 8'h76;
	stim_pad0_tgt2_l     <= 8'h98;
	stim_pad0_tgt2_h     <= 8'hBA;
	stim_pad0_tgt3_l     <= 8'hDC;
	stim_pad0_tgt3_h     <= 8'hFE;
	stim_pad1_tgt0_l     <= 8'h01;
	stim_pad1_tgt0_h     <= 8'h23;
	stim_pad1_tgt1_l     <= 8'h45;
	stim_pad1_tgt1_h     <= 8'h67;
	stim_pad1_tgt2_l     <= 8'h89;
	stim_pad1_tgt2_h     <= 8'hAB;
	stim_pad1_tgt3_l     <= 8'hCD;
	stim_pad1_tgt3_h     <= 8'hEF;
        stim_mon_delta_int_clr <= 1'b0;
        stim_mon_cycle_int_clr <= 1'b0;
	stim_mon_int_clr <= 1'b0;
	threshold_leadoff <= 10'b0;  	
	threshold_short <= 10'b0;  	
	threshold_tgt <= 8'b0;
	stim_mon_loff_short_int_ctrl <= 8'b0;
 	adc_delta_data_cap_in_manual <= 1'b0;
 	select_2nd_max_min <= 1'b0;
   end else begin
        stim_mon_delta_int_clr <= 1'b0;
        stim_mon_cycle_int_clr <= 1'b0;
	stim_mon_int_clr <= 1'b0;
     case (i_addr[7:0])
       `STIM_PAD_CTRL       :   stim_pad_ctrl <= i_wr ? i_wr_data[7:0] : stim_pad_ctrl;        
       `STIM_PAD_CTRL1      :   stim_pad_ctrl1 <= i_wr ? i_wr_data[7:0] : stim_pad_ctrl1;        
       `STIM_MON_PERIOD_L   :   stim_mon_period_l <= i_wr ? i_wr_data : stim_mon_period_l;     
       `STIM_MON_PERIOD_H   :   stim_mon_period_h <= i_wr ? i_wr_data : stim_mon_period_h;      
       `STIM_MON_CTRL2:  stim_mon_ctrl2 <= i_wr ? i_wr_data[6:0] : stim_mon_ctrl2;      

       `STIM_MON_INT_STS    : begin  
				 stim_mon_int_topin_en_reg <= i_wr ? i_wr_data[7:5] : stim_mon_int_topin_en_reg;
				 stim_mon_delta_data_sel <= i_wr ? i_wr_data[4:3] : stim_mon_delta_data_sel;
				 stim_mon_cycle_int_clr    <= (i_wr & !int_clear_type)? i_wr_data[2]: (i_rd & int_clear_type)? (stim_mon_cycle_int_sts & i_rd) : 1'b0;
				 stim_mon_delta_int_clr    <= (i_wr & !int_clear_type)? i_wr_data[0]: (i_rd & int_clear_type)? (stim_mon_delta_int_sts & i_rd) : 1'b0;
				 stim_mon_int_clr          <= (i_wr & !int_clear_type)? i_wr_data[1]: (i_rd & int_clear_type)? (stim_mon_int_sts & i_rd) : 1'b0;
       end
	`GENERAL_INTERUPT_STATUS_REG0B : begin
				 stim_mon_cycle_int_clr    <= (i_wr & !int_clear_type)? i_wr_data[2]: (i_rd & int_clear_type)? (stim_mon_cycle_int_sts & i_rd) : 1'b0;
				 stim_mon_delta_int_clr    <= (i_wr & !int_clear_type)? i_wr_data[0]: (i_rd & int_clear_type)? (stim_mon_delta_int_sts & i_rd) : 1'b0;
				 stim_mon_int_clr          <= (i_wr & !int_clear_type)? i_wr_data[1]: (i_rd & int_clear_type)? (stim_mon_int_sts & i_rd) : 1'b0;
	end

       `STIM_PAD0_TGT0_L    :   stim_pad0_tgt0_l <= i_wr ? i_wr_data : stim_pad0_tgt0_l; 
       `STIM_PAD0_TGT0_H    :   stim_pad0_tgt0_h <= i_wr ? i_wr_data : stim_pad0_tgt0_h; 
       `STIM_PAD0_TGT1_L    :   stim_pad0_tgt1_l <= i_wr ? i_wr_data : stim_pad0_tgt1_l; 
       `STIM_PAD0_TGT1_H    :   stim_pad0_tgt1_h <= i_wr ? i_wr_data : stim_pad0_tgt1_h; 
       `STIM_PAD0_TGT2_L    :   stim_pad0_tgt2_l <= i_wr ? i_wr_data : stim_pad0_tgt2_l; 
       `STIM_PAD0_TGT2_H    :   stim_pad0_tgt2_h <= i_wr ? i_wr_data : stim_pad0_tgt2_h; 
       `STIM_PAD0_TGT3_L    :   stim_pad0_tgt3_l <= i_wr ? i_wr_data : stim_pad0_tgt3_l; 
       `STIM_PAD0_TGT3_H    :   stim_pad0_tgt3_h <= i_wr ? i_wr_data : stim_pad0_tgt3_h; 
       `STIM_PAD1_TGT0_L    :   stim_pad1_tgt0_l <= i_wr ? i_wr_data : stim_pad1_tgt0_l; 
       `STIM_PAD1_TGT0_H    :   stim_pad1_tgt0_h <= i_wr ? i_wr_data : stim_pad1_tgt0_h; 
       `STIM_PAD1_TGT1_L    :   stim_pad1_tgt1_l <= i_wr ? i_wr_data : stim_pad1_tgt1_l; 
       `STIM_PAD1_TGT1_H    :   stim_pad1_tgt1_h <= i_wr ? i_wr_data : stim_pad1_tgt1_h; 
       `STIM_PAD1_TGT2_L    :   stim_pad1_tgt2_l <= i_wr ? i_wr_data : stim_pad1_tgt2_l; 
       `STIM_PAD1_TGT2_H    :   stim_pad1_tgt2_h <= i_wr ? i_wr_data : stim_pad1_tgt2_h; 
       `STIM_PAD1_TGT3_L    :   stim_pad1_tgt3_l <= i_wr ? i_wr_data : stim_pad1_tgt3_l; 
       `STIM_PAD1_TGT3_H    :   stim_pad1_tgt3_h <= i_wr ? i_wr_data : stim_pad1_tgt3_h; 

       `STIM_ADC_DELTA_DATA_TAG_H    :   begin 
					adc_delta_data_cap_in_manual <= i_wr ? i_wr_data[2] : adc_delta_data_cap_in_manual;
					select_2nd_max_min <= i_wr ? i_wr_data[3] : select_2nd_max_min;
					 end 

`STIM_MON_LOFF_SHORT_INT_CTRL   :  stim_mon_loff_short_int_ctrl <=  i_wr ? i_wr_data : stim_mon_loff_short_int_ctrl;    
`STIM_MON_LOFF_TH0           	:     threshold_leadoff[7:0] <=  i_wr ? i_wr_data : threshold_leadoff[7:0]; 
`STIM_MON_LOFF_TH1           	:      threshold_leadoff[9:8] <=  i_wr ? i_wr_data[1:0] : threshold_leadoff[9:8];
`STIM_MON_SHORT_TH0           	:      threshold_short[7:0] <=  i_wr ? i_wr_data : threshold_short[7:0];
`STIM_MON_SHORT_TH1           	:      threshold_short[9:8] <=  i_wr ? i_wr_data[1:0] : threshold_short[9:8];
`STIM_MON_TH_TGT           	:      threshold_tgt <=  i_wr ? i_wr_data : threshold_tgt;
	default : ;
    endcase
  end
end

//My add
always@(posedge i_clk or negedge i_rst_n) begin
  if (!i_rst_n) begin
    ana_en_sec_reg        <= 1'b0;
    ana_enable_reg [0][0] <= 8'h00;
    ana_enable_reg [0][1] <= 8'h02;
    ana_enable_reg [0][2] <= 8'h00;
    ana_enable_reg [0][3] <= 8'h00;
    ana_enable_reg [0][4] <= 8'h00;
    ana_enable_reg [0][5] <= 8'h00;
    ana_enable_reg [0][6] <= 8'h00;
    ana_enable_reg [0][7] <= 8'h00;
    ana_enable_reg [0][8] <= 8'h00;
    ana_enable_reg [0][9] <= 8'h00;
    ana_enable_reg [0][10] <= 8'h00;
    ana_enable_reg [0][11] <= 8'h00;
    ana_enable_reg [0][12] <= 8'h00;
    ana_enable_reg [0][13] <= 8'h00;      
    ana_enable_reg [0][14] <= 8'h00;
    // reset ENABLE
    for (int j = 0; j < 15; j++) begin
      ana_enable_reg[1][j] <= 8'h00;
    end
 end 
 else begin
   //ENABLE
   case (i_addr[7:0])
            `ANA_EN_SECTION_SEL  :   ana_en_sec_reg <= i_wr ? i_wr_data[0] :  ana_en_sec_reg;
            `ANA_ENABLE_REG_0    :   ana_enable_reg [ana_en_sec_reg][0]  <= i_wr ? i_wr_data : ana_enable_reg [ana_en_sec_reg][0];
            `ANA_ENABLE_REG_1    :   ana_enable_reg [ana_en_sec_reg][1]  <= i_wr ? i_wr_data : ana_enable_reg [ana_en_sec_reg][1];
            `ANA_ENABLE_REG_2    :   ana_enable_reg [ana_en_sec_reg][2]  <= i_wr ? i_wr_data : ana_enable_reg [ana_en_sec_reg][2];
            `ANA_ENABLE_REG_3    :   ana_enable_reg [ana_en_sec_reg][3]  <= i_wr ? i_wr_data : ana_enable_reg [ana_en_sec_reg][3];
            `ANA_ENABLE_REG_4    :   ana_enable_reg [ana_en_sec_reg][4]  <= i_wr ? i_wr_data : ana_enable_reg [ana_en_sec_reg][4];
            `ANA_ENABLE_REG_5    :   ana_enable_reg [ana_en_sec_reg][5]  <= i_wr ? i_wr_data : ana_enable_reg [ana_en_sec_reg][5];
            `ANA_ENABLE_REG_6    :   ana_enable_reg [ana_en_sec_reg][6]  <= i_wr ? i_wr_data : ana_enable_reg [ana_en_sec_reg][6];
            `ANA_ENABLE_REG_7    :   ana_enable_reg [ana_en_sec_reg][7]  <= i_wr ? i_wr_data : ana_enable_reg [ana_en_sec_reg][7];
            `ANA_ENABLE_REG_8    :   ana_enable_reg [ana_en_sec_reg][8]  <= i_wr ? i_wr_data : ana_enable_reg [ana_en_sec_reg][8];
            `ANA_ENABLE_REG_9    :   ana_enable_reg [ana_en_sec_reg][9]  <= i_wr ? i_wr_data : ana_enable_reg [ana_en_sec_reg][9];
            `ANA_ENABLE_REG_10   :   ana_enable_reg [ana_en_sec_reg][10]  <= i_wr ? i_wr_data : ana_enable_reg [ana_en_sec_reg][10];
            `ANA_ENABLE_REG_11   :   ana_enable_reg [ana_en_sec_reg][11]  <= i_wr ? i_wr_data : ana_enable_reg [ana_en_sec_reg][11];
            `ANA_ENABLE_REG_12   :   ana_enable_reg [ana_en_sec_reg][12]  <= i_wr ? i_wr_data : ana_enable_reg [ana_en_sec_reg][12];
            `ANA_ENABLE_REG_13   :   ana_enable_reg [ana_en_sec_reg][13]  <= i_wr ? i_wr_data : ana_enable_reg [ana_en_sec_reg][13];
            `ANA_ENABLE_REG_14   :   ana_enable_reg [ana_en_sec_reg][14]  <= i_wr ? i_wr_data : ana_enable_reg [ana_en_sec_reg][14];
    endcase
  end
end


always @(posedge i_clk or negedge i_rst_n) begin
  if (!i_rst_n) begin
     ana_gen_sec_reg	<= 3'b0;

/* Truong changed logic to reset all regs in all sections - 23/04/2026
			for (int j = 0; j < 14; j++)begin
				ana_gen_reg[ana_gen_sec_reg][j] <= 8'h00;	
      end		
*/
     for (int i = 0; i < 8; i++) begin
       for (int j = 0; j < 14; j++) begin
         ana_gen_reg[i][j] <= 8'h00;	
       end
     end		

   end else begin
     case (i_addr[7:0])
            `ANA_GEN_SECTION_SEL : ana_gen_sec_reg <= i_wr ? i_wr_data[2:0] :  ana_gen_sec_reg;
            `ANA_GEN_REG_1 :   ana_gen_reg[ana_gen_sec_reg][0]  <= i_wr ? i_wr_data : ana_gen_reg[ana_gen_sec_reg][0];
            `ANA_GEN_REG_2 :   ana_gen_reg[ana_gen_sec_reg][1]  <= i_wr ? i_wr_data : ana_gen_reg[ana_gen_sec_reg][1];
            `ANA_GEN_REG_3 :   ana_gen_reg[ana_gen_sec_reg][2]  <= i_wr ? i_wr_data : ana_gen_reg[ana_gen_sec_reg][2];
            `ANA_GEN_REG_4 :   ana_gen_reg[ana_gen_sec_reg][3]  <= i_wr ? i_wr_data : ana_gen_reg[ana_gen_sec_reg][3];
            `ANA_GEN_REG_5 :   ana_gen_reg[ana_gen_sec_reg][4]  <= i_wr ? i_wr_data : ana_gen_reg[ana_gen_sec_reg][4];
            `ANA_GEN_REG_6 :   ana_gen_reg[ana_gen_sec_reg][5]  <= i_wr ? i_wr_data : ana_gen_reg[ana_gen_sec_reg][5];
            `ANA_GEN_REG_7 :   ana_gen_reg[ana_gen_sec_reg][6]  <= i_wr ? i_wr_data : ana_gen_reg[ana_gen_sec_reg][6];
            `ANA_GEN_REG_8 :   ana_gen_reg[ana_gen_sec_reg][7]  <= i_wr ? i_wr_data : ana_gen_reg[ana_gen_sec_reg][7];
            `ANA_GEN_REG_9 :   ana_gen_reg[ana_gen_sec_reg][8]  <= i_wr ? i_wr_data : ana_gen_reg[ana_gen_sec_reg][8];
            `ANA_GEN_REG_10:   ana_gen_reg[ana_gen_sec_reg][9]  <= i_wr ? i_wr_data : ana_gen_reg[ana_gen_sec_reg][9];
            `ANA_GEN_REG_11:   ana_gen_reg[ana_gen_sec_reg][10] <= i_wr ? i_wr_data : ana_gen_reg[ana_gen_sec_reg][10];
            `ANA_GEN_REG_12:   ana_gen_reg[ana_gen_sec_reg][11] <= i_wr ? i_wr_data : ana_gen_reg[ana_gen_sec_reg][11];
            `ANA_GEN_REG_13:   ana_gen_reg[ana_gen_sec_reg][12] <= i_wr ? i_wr_data : ana_gen_reg[ana_gen_sec_reg][12];
            `ANA_GEN_REG_14:   ana_gen_reg[ana_gen_sec_reg][13] <= i_wr ? i_wr_data : ana_gen_reg[ana_gen_sec_reg][13];
     endcase
   end
end
assign ATM_MODE = {atm_adj_mode[13],atm_adj_mode[12],atm_adj_mode[11], atm_adj_mode[10], atm_adj_mode[9] || atm_adj_mode[8], atm_adj_mode[7] || atm_adj_mode[6],  atm_adj_mode[2] || atm_adj_mode[1], atm_adj_mode[0] || atm_adj_mode[14]};

	
always @(posedge i_clk or negedge i_rst_n) begin
  if (!i_rst_n) begin
    ana_gen_reg[0][14] <= 8'h00;
    ana_gen_reg[1][14] <= 8'h24;
    ana_gen_reg[2][14] <= 8'h00;
    ana_gen_reg[3][14] <= 8'h00;
    ana_gen_reg[4][14] <= 8'h00;
    ana_gen_reg[5][14] <= 8'h00;
    ana_gen_reg[6][14] <= 8'h0C;
    ana_gen_reg[7][14] <= 8'h00;
     // SPI WRITE NORMAL MODE
     end else if (i_wr) begin
       if(i_addr[7:0] == `ANA_GEN_REG_15) begin
         for (int x = 0; x < 8; x = x + 1)begin
           if (x == ana_gen_sec_reg) begin
             ana_gen_reg[x][14] <= i_wr_data;
	   end
	 end
      end
    end
    // IO WRITE ATM ADJ MODE
    else if (atm_adj) begin
      for (int x = 0; x < 8; x++) begin				
        if(ATM_MODE[x]) begin
          ana_gen_reg[x][14]	<= atm_adj_data;
        end
      end
    end
end
//to anac
//xin change temporily, pls Truong check
assign ana_lvd_sts	      = A2D_ANA_GEN_REG_0[0];      
//assign ana_lvd_sts	      = 1'b0;      

// pmu register output 
assign {o_otp_dpstb_en, o_hresetreq, o_sleepdeep, o_pmuenable} = pmu_reg0[3:0];
assign o_wave_gen_dis	      = pmu_reg0[4];
assign o_wave_gen_rst         = pmu_reg0[5];
assign  multi_intb_pin        = pmu_reg0[6];
//assign lead_off_dis	      = pmu_reg0[6];
//assign lead_off_rst           = pmu_reg0[7];

//assign lead_off_en            = ~lead_off_dis;

assign otp_rst_reg            = pmu_reg1[0];
assign dig_rst_reg            = pmu_reg1[1];

//clk_ctrl register output
assign  o_pclk_div            = clk_ctrl_reg[2:0];
//assign  o_fclk_dynen        = 1'b0;
assign  o_int_clk_out         = clk_ctrl_reg[3];  
assign iclk_div               = clk_ctrl_reg[7:4];

//////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////GPIO io pad control register  write/////////////////////////////////////////////// 
/////////////////////////////////////////////////////////////////////////////////////////////////////////
reg [7:0]   pu_ctrl;
reg [7:0]   pd_ctrl;
reg [2:0]   sr_pdrv0_1_ctrl;
reg         nirs_out_ctrl;
reg         normal_out_ctrl;

//reg [5:0] gpio_0_ctrl,gpio_1_ctrl,gpio_2_ctrl,gpio_3_ctrl,gpio_4_ctrl; 
//reg [5:0] gpio_5_ctrl,gpio_6_ctrl,gpio_7_ctrl,gpio_8_ctrl,gpio_9_ctrl;
//reg [5:0] gpio_10_ctrl,gpio_11_ctrl,gpio_12_ctrl,gpio_13_ctrl,gpio_14_ctrl;
//reg [5:0] gpio_15_ctrl;//,gpio_16_ctrl,gpio_17_ctrl,gpio_18_ctrl;

assign gpio_pu_ctrl           =  pu_ctrl;
assign gpio_pd_ctrl           =  pd_ctrl;
assign gpio_sr_pdrv0_1_ctrl   =  sr_pdrv0_1_ctrl;
assign gpio_nirs_out_ctrl     =  nirs_out_ctrl;
assign gpio_normal_out_ctrl   =  normal_out_ctrl;
//assign gpio_4_ctrl_all =  gpio_4_ctrl;
//assign gpio_5_ctrl_all =  gpio_5_ctrl;
//assign gpio_6_ctrl_all =  gpio_6_ctrl;
//assign gpio_7_ctrl_all =  gpio_7_ctrl;
//assign gpio_8_ctrl_all =  gpio_8_ctrl;
//assign gpio_9_ctrl_all =  gpio_9_ctrl;
//assign gpio_10_ctrl_all = gpio_10_ctrl;
//assign gpio_11_ctrl_all = gpio_11_ctrl;
//assign gpio_12_ctrl_all = gpio_12_ctrl;
//assign gpio_13_ctrl_all = gpio_13_ctrl;
//assign gpio_14_ctrl_all = gpio_14_ctrl;
//assign gpio_15_ctrl_all = gpio_15_ctrl;
//assign gpio_16_ctrl_all = gpio_16_ctrl;
//assign gpio_17_ctrl_all = gpio_17_ctrl;
//assign gpio_18_ctrl_all = gpio_18_ctrl;

always @(posedge i_clk or negedge i_rst_n) begin
  if (!i_rst_n) begin
  //Tried reducing number of spi registers because in normal mode only GPIO0~GPIO7 has been used so only PU/PD required to be configured for each GPIO. CS configuration not required(as per Mohsen), PDRV0/PDRV1/SR common bit used for all 8 GPIO's
     pu_ctrl    		  <= 8'h00; 
     pd_ctrl    		  <= 8'h1F; 
     sr_pdrv0_1_ctrl  <= 3'b000; 
     nirs_out_ctrl    <= 1'b0;	
     normal_out_ctrl  <= 1'b0;	
  end
  else begin
    case (i_addr[ADDR_WIDTH-1:0])
     `GPIO_PU_CTRL         : pu_ctrl         <= i_wr ? i_wr_data[7:0] : pu_ctrl;	  
     `GPIO_PD_CTRL     	   : pd_ctrl         <= i_wr ? i_wr_data[7:0] : pd_ctrl;
     `GPIO_SR_PDRV0_1_CTRL : sr_pdrv0_1_ctrl <= i_wr ? i_wr_data[2:0] : sr_pdrv0_1_ctrl;   
     `GPIO_NIRS_OUT_CTRL   : nirs_out_ctrl   <= i_wr ? i_wr_data[0]   : nirs_out_ctrl;
     `GPIO_NORMAL_OUT_CTRL : normal_out_ctrl   <= i_wr ? i_wr_data[0]   : normal_out_ctrl;
    endcase
  end
end

reg [2:0] int_ctrl_reg;
always @(posedge i_clk or negedge i_rst_n) begin
  if (!i_rst_n) begin
     int_ctrl_reg    <= 3'b100;      
  end
  else begin
    case (i_addr[ADDR_WIDTH-1:0])
     `GENERAL_INTERUPT_CTRL_REG   : int_ctrl_reg   <= i_wr ? i_wr_data[2:0] : int_ctrl_reg;        
    endcase
  end
end

assign int_length_slct  = int_ctrl_reg[0];//0:level; 1:pulse
assign int_clear_type   = int_ctrl_reg[1];//0:W1C;   1:R1C
assign int_active_level = int_ctrl_reg[2];//0:low    1: high

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////anac register ///////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//reg [3:0]                anac_short_blk_slct_reg;
//reg [31:0]               ana_int_ch_timer_th_reg[NO_OF_WAVEGEN-1:0];    
//reg [31:0]               ana_int_ch_cnt_th_reg[NO_OF_WAVEGEN-1:0];
//reg [NO_OF_WAVEGEN-1:0]  ana_int_stop_wavegen_reg;
reg                      ana_lvd_intr_en_reg;     
//reg [NO_OF_WAVEGEN-1:0]  ana_comp_ch_intr_en_reg;
//reg [NO_OF_WAVEGEN-1:0]  ana_comp_ch_intr_trans_sel_reg;
//reg [NO_OF_WAVEGEN-1:0]  ana_stimu_ch_intr_en_reg;
//reg [NO_OF_WAVEGEN-1:0]  ana_stimu_ch_intr_dig_reg;
//reg [NO_OF_WAVEGEN-1:0]  ana_stimu_ch_intr_pol_reg;
//reg [NO_OF_WAVEGEN-1:0]  ana_stimu_ch_intr_sts_clr_reg;
//reg [NO_OF_WAVEGEN-1:0]  ana_comp_ch_intr_sts_clr_reg;
//
//
//wire [NO_OF_WAVEGEN-1:0] ana_stimu_ch_intr_sts;
//wire [NO_OF_WAVEGEN-1:0] ana_comp_ch_intr_sts;
//wire                     ana_lvd_intr_pin;
//wire [31:0] counter_th_cnt_dbg[NO_OF_WAVEGEN-1 :0];
//
always @(posedge i_clk or negedge i_rst_n) begin
  if (!i_rst_n)begin
//   anac_short_blk_slct_reg         <= 4'b0;
     ana_lvd_intr_en_reg             <= 1'b1;
//   for(int b=0;b<NO_OF_WAVEGEN;b++)begin
//   ana_int_ch_timer_th_reg[b]        <= 32'h0; 
//   ana_int_ch_cnt_th_reg[b]          <= 32'h0;
//   ana_int_stop_wavegen_reg[b]       <= 1'b0;
//   ana_comp_ch_intr_en_reg[b]        <= 1'b1;
//   ana_comp_ch_intr_trans_sel_reg[b] <= 1'b0;
//   ana_stimu_ch_intr_dig_reg[b]      <= 1'b1;
//   ana_stimu_ch_intr_en_reg[b]       <= 1'b0;
//   ana_stimu_ch_intr_pol_reg[b]      <= 1'b0;
//   ana_stimu_ch_intr_sts_clr_reg[b]  <= 1'b0;
//   ana_comp_ch_intr_sts_clr_reg[b]   <= 1'b0;  
//   end
  end
  else begin
    case (i_addr[ADDR_WIDTH-1:0])
//   `ANAC_SHORT_BLK_SLCT               : anac_short_blk_slct_reg                                 <= i_wr?                     i_wr_data[3:0]  : anac_short_blk_slct_reg;
//   `ANA_STIM_CH_TIMER_CNT_TH00        : ana_int_ch_timer_th_reg[anac_short_blk_slct_reg][7:0]   <= i_wr?                     i_wr_data       : ana_int_ch_timer_th_reg[anac_short_blk_slct_reg][7:0];
//   `ANA_STIM_CH_TIMER_CNT_TH01        : ana_int_ch_timer_th_reg[anac_short_blk_slct_reg][15:8]  <= i_wr?                     i_wr_data       : ana_int_ch_timer_th_reg[anac_short_blk_slct_reg][15:8];
//   `ANA_STIM_CH_TIMER_CNT_TH02        : ana_int_ch_timer_th_reg[anac_short_blk_slct_reg][23:16] <= i_wr?                     i_wr_data       : ana_int_ch_timer_th_reg[anac_short_blk_slct_reg][23:16];
//   `ANA_STIM_CH_TIMER_CNT_TH03        : ana_int_ch_timer_th_reg[anac_short_blk_slct_reg][31:24] <= i_wr?                     i_wr_data       : ana_int_ch_timer_th_reg[anac_short_blk_slct_reg][31:24];
//   `ANA_STIM_CH_COUNTER_CNT_TH00      : ana_int_ch_cnt_th_reg[anac_short_blk_slct_reg][7:0]     <= i_wr?                     i_wr_data       : ana_int_ch_cnt_th_reg[anac_short_blk_slct_reg][7:0];
//   `ANA_STIM_CH_COUNTER_CNT_TH01      : ana_int_ch_cnt_th_reg[anac_short_blk_slct_reg][15:8]    <= i_wr?                     i_wr_data       : ana_int_ch_cnt_th_reg[anac_short_blk_slct_reg][15:8];
//   `ANA_STIM_CH_COUNTER_CNT_TH02      : ana_int_ch_cnt_th_reg[anac_short_blk_slct_reg][23:16]   <= i_wr?                     i_wr_data       : ana_int_ch_cnt_th_reg[anac_short_blk_slct_reg][23:16];
//   `ANA_STIM_CH_COUNTER_CNT_TH03      : ana_int_ch_cnt_th_reg[anac_short_blk_slct_reg][31:24]   <= i_wr?                     i_wr_data       : ana_int_ch_cnt_th_reg[anac_short_blk_slct_reg][31:24];
//   `ANA_INT_SOTP_WAVEGEN              : ana_int_stop_wavegen_reg                                <= i_wr?                     i_wr_data       : ana_int_stop_wavegen_reg;
     `ANAC_LVD_INT_EN                   : ana_lvd_intr_en_reg                                     <= i_wr?                     i_wr_data[0]    : ana_lvd_intr_en_reg;
//   `ANAC_COMP_INT_EN                  : ana_comp_ch_intr_en_reg                                 <= i_wr?                     i_wr_data       : ana_comp_ch_intr_en_reg;
//   `ANAC_COMP_INT_TRANS_SEL           : ana_comp_ch_intr_trans_sel_reg                          <= i_wr?                     i_wr_data       : ana_comp_ch_intr_trans_sel_reg;
//   `ANAC_STIMU_INT_EN                 : ana_stimu_ch_intr_en_reg                                <= i_wr?                     i_wr_data       : ana_stimu_ch_intr_en_reg;
//   `ANAC_STIMU_INT_DIG_EN             : ana_stimu_ch_intr_dig_reg                               <= i_wr?                     i_wr_data       : ana_stimu_ch_intr_dig_reg;
//   `ANAC_STIMU_INT_POL_EN             : ana_stimu_ch_intr_pol_reg                               <= i_wr?                     i_wr_data       : ana_stimu_ch_intr_pol_reg;	  
//   `ANA_INT_STIMU_STS                 : ana_stimu_ch_intr_sts_clr_reg                           <= (i_wr & !int_clear_type)? i_wr_data       : (i_rd & int_clear_type)? ana_stimu_ch_intr_sts : 8'b0;
//   `ANA_INT_COMP_STS                  : ana_comp_ch_intr_sts_clr_reg                            <= (i_wr & !int_clear_type)? i_wr_data       : (i_rd & int_clear_type)? ana_comp_ch_intr_sts : 8'b0; 
    endcase
  end
end

//interface spi-anac
assign spi_anac.ana_lvd_intr_en            = ana_lvd_intr_en_reg;
assign spi_anac.int_length_slct            = int_length_slct;
//assign spi_anac.ana_stimu_ch_timer_TH      = ana_int_ch_timer_th_reg;
//assign spi_anac.ana_stimu_ch_counter_TH    = ana_int_ch_cnt_th_reg;
//assign spi_anac.ana_comp_ch_intr_en        = ana_comp_ch_intr_en_reg;
//assign spi_anac.ana_comp_ch_intr_trans_sel = ana_comp_ch_intr_trans_sel_reg;
//assign spi_anac.ana_comp_ch_intr_sts_clr   = ana_comp_ch_intr_sts_clr_reg & ana_comp_ch_intr_sts;
//assign spi_anac.ana_stimu_ch_intr_sts_clr  = ana_stimu_ch_intr_sts_clr_reg & ana_stimu_ch_intr_sts;
//assign spi_anac.anac_short_int_en          =ana_stimu_ch_intr_en_reg ;
//assign spi_anac.anac_short_drive_en        = ana_stimu_ch_intr_dig_reg;
//assign spi_anac.anac_short_leadoff_en      = anac_short_blk_slct_reg[3];
//assign spi_anac.anac_int_pol               = ana_stimu_ch_intr_pol_reg;
wire ana_lvd_intr_pin;
assign ana_lvd_intr_pin      = spi_anac.ana_lvd_intr_pin;
//assign counter_th_cnt_dbg    = spi_anac.counter_th_cnt_dbg;
//assign ana_stimu_ch_intr_sts = spi_anac.ana_stimu_ch_intr_sts;
//assign ana_comp_ch_intr_sts  = spi_anac.ana_comp_ch_intr_sts;

//interface spi_leadoff
//wire [NO_OF_WAVEGEN-1:0] ana_comp_ch_intr_sts;
//wire                     ana_lvd_intr_pin;
//wire [NO_OF_WAVEGEN-1:0] counter_th_cnt_dbg[NO_OF_WAVEGEN-1 :0];

////-------------------------------------
//// lead off function
////-------------------------------------
//   wire  sel_stim;
//   wire [NO_OF_WAVEGEN-1:0]    lead_off_sts_clear;   
//
//   wire[31:0] lead_off_Counter_cnt_dac0_final_dbg[NO_OF_WAVEGEN-1:0];
//   wire[7:0]  lead_off_Counter_cnt_dac0_dbg[NO_OF_WAVEGEN-1:0]  ;
//   wire[NO_OF_WAVEGEN-1:0]       lead_off_result;   
//   wire[NO_OF_WAVEGEN-1:0]       lead_off_stop;   
//
//  reg  [3:0]  lead_off_blk_slct_reg;
//  reg  [31:0]  timer_cnt_tgt[NO_OF_WAVEGEN-1:0];
//  reg  [31 : 0]  counter_th_tgt[NO_OF_WAVEGEN-1:0];
//
//   reg [NO_OF_WAVEGEN-1:0] lead_off_dac_en;     
//   reg [NO_OF_WAVEGEN-1:0] lead_off_int_en;
//   reg [NO_OF_WAVEGEN-1:0] lead_off_stop_en;
//   reg [NO_OF_WAVEGEN-1:0] lead_off_comp_low_en;
//
////===================
//reg[7:0] lead_off_ctrl;
//reg[7:0] lead_off_tgt_reg;
//always@(posedge i_clk or negedge i_rst_n) begin
//  if(!i_rst_n)begin
//   lead_off_blk_slct_reg         <= 4'b0;
//   lead_off_ctrl         <= 8'b0;
//   lead_off_tgt_reg <= 8'b0;
//
//   for(int b=0;b<NO_OF_WAVEGEN;b++)begin
//   	timer_cnt_tgt[b]        <= 32'h0; 
//   	counter_th_tgt[b]          <= 32'h0;
//   	lead_off_dac_en[b]	      <= 1'b0;     
//   	lead_off_int_en[b]	      <= 1'b0;
//   	lead_off_stop_en[b]	      <= 1'b0;
//   	lead_off_comp_low_en[b]    <= 1'b0;
//   end
//  end
//  else begin
//    case (i_addr[ADDR_WIDTH-1:0])
//      `LEAD_OFF_CTRL          :  lead_off_ctrl[7:0]      <= i_wr? i_wr_data[7:0] : lead_off_ctrl[7:0]; 
//
//      `LEAD_OFF_TGT           : lead_off_tgt_reg  			     <= i_wr?                     i_wr_data[7:0]  : lead_off_tgt_reg	; 
//     `LEAD_OFF_BLK_SLCT       : lead_off_blk_slct_reg                        <= i_wr?                     i_wr_data[3:0]  : lead_off_blk_slct_reg;
//     `COUNTER_TH_TGT_0        : counter_th_tgt[lead_off_blk_slct_reg][7:0]   <= i_wr?                     i_wr_data       : counter_th_tgt[lead_off_blk_slct_reg][7:0];
//     `COUNTER_TH_TGT_1        : counter_th_tgt[lead_off_blk_slct_reg][15:8]  <= i_wr?                     i_wr_data       : counter_th_tgt[lead_off_blk_slct_reg][15:8];
//     `COUNTER_TH_TGT_2        : counter_th_tgt[lead_off_blk_slct_reg][23:16] <= i_wr?                     i_wr_data       : counter_th_tgt[lead_off_blk_slct_reg][23:16];
//     `COUNTER_TH_TGT_3        : counter_th_tgt[lead_off_blk_slct_reg][31:24] <= i_wr?                     i_wr_data       : counter_th_tgt[lead_off_blk_slct_reg][31:24];
//
//     `TIMER_CNT_TGT_0      : timer_cnt_tgt[lead_off_blk_slct_reg][7:0]     <= i_wr?                     i_wr_data       : timer_cnt_tgt[lead_off_blk_slct_reg][7:0];
//     `TIMER_CNT_TGT_1      : timer_cnt_tgt[lead_off_blk_slct_reg][15:8]    <= i_wr?                     i_wr_data       : timer_cnt_tgt[lead_off_blk_slct_reg][15:8];
//     `TIMER_CNT_TGT_2      : timer_cnt_tgt[lead_off_blk_slct_reg][23:16]   <= i_wr?                     i_wr_data       : timer_cnt_tgt[lead_off_blk_slct_reg][23:16];
//     `TIMER_CNT_TGT_3      : timer_cnt_tgt[lead_off_blk_slct_reg][31:24]   <= i_wr?                     i_wr_data       : timer_cnt_tgt[lead_off_blk_slct_reg][31:24];
//
//     `LEAD_OFF_DAC_EN      : lead_off_dac_en   <= i_wr?                     i_wr_data       : lead_off_dac_en;	
//     `LEAD_OFF_STOP_EN     : lead_off_stop_en   <= i_wr?                     i_wr_data       : lead_off_stop_en;	
//     `LEAD_OFF_INT_EN      : lead_off_int_en   <= i_wr?                     i_wr_data       : lead_off_int_en;	
//     `LEAD_OFF_COMP_LOW_EN : lead_off_comp_low_en   <= i_wr?                     i_wr_data       : lead_off_comp_low_en; 		
//        
//    endcase
//  end
//end
////===================
//assign spi_leadoff.timer_cnt_tgt =  timer_cnt_tgt;
//assign spi_leadoff.counter_th_tgt = counter_th_tgt ;
//assign spi_leadoff.lead_off_stop_en = lead_off_stop_en ;
//assign spi_leadoff.lead_off_sts_clear =  lead_off_sts_clear;
//assign spi_leadoff.dac_en_in = lead_off_dac_en ;
//assign spi_leadoff.sel_stim = sel_stim ;
//assign spi_leadoff.comp_low_en = lead_off_comp_low_en ;
//assign spi_leadoff.int_length_slct = int_length_slct ;
//assign spi_leadoff.lead_off_int_en = lead_off_int_en ;
//
//assign lead_off_stop      = spi_leadoff.lead_off_stop;
//assign lead_off_result    = spi_leadoff.lead_off_result;
//assign lead_off_Counter_cnt_dac0_final_dbg = spi_leadoff.lead_off_Counter_cnt_dac0_final_dbg;
//assign lead_off_Counter_cnt_dac0_dbg  = spi_leadoff.lead_off_Counter_cnt_dac0_dbg;

////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////filter register ///////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
localparam LPF_COEFF    = 14;
localparam NOTCH_COEFF  = 14; 
localparam HPF_COEFF    = 1;

reg [7:0]  coeff_addr;
reg [23:0] coeff_data [LPF_COEFF+NOTCH_COEFF+HPF_COEFF-1:0];

localparam [23:0] coeff_data_def [0:LPF_COEFF+NOTCH_COEFF+HPF_COEFF-1] = '{
//lpf
24'b0000_0000_0000_0000_0000_1001,
24'b0000_0000_0000_0000_1000_0111,
24'b0000_0000_0000_0010_1101_1011,
24'b0000_0000_0000_1001_0000_0101,
24'b0000_0000_0001_0011_0001_1011,
24'b0000_0000_0001_1011_1000_1111,
24'b0000_0000_0001_0111_0100_0011,
24'b0000_0011_1111_1110_0011_1111,
24'b0000_0011_1101_1001_0110_0101,
24'b0000_0011_1100_0111_0100_1101,
24'b0000_0011_1110_1011_1111_0010,
24'b0000_0000_0101_0001_0101_1110,
24'b0000_0000_1101_0011_1000_0010,
24'b0000_0001_0010_1111_0011_1100,

//notch
24'b000000111111100111110110,
24'b000010000110000010011000,
24'b000010000111101000011100,
24'b000000111111001110010001,
24'b000010000110100000000000,
24'b000010000110010111010111,
24'b000000111111010010101101,
24'b000000111111000111000010,
24'b000010000110001010110101,
24'b000010001000001111010100,
24'b000000111110001100000001,
24'b000010000110010111000110,
24'b000010000111101011100101,
24'b000000111110010000011001,


//24'b0000_0011_1111_1100_0000_0001,
//24'b0000_1000_0110_0100_0011_1011,
//24'b0000_1000_0111_0110_1110_1100,
//24'b0000_0011_1111_0111_1110_0110,
//24'b0000_1000_0110_0001_0100_0100,
//24'b0000_0011_1111_1000_1010_1110,
//24'b0000_0011_1111_0101_0010_1110,
//24'b0000_1000_1000_0010_0010_0010,
//24'b0000_0011_1110_1001_1010_1011,
//24'b0000_1000_0110_1111_1101_0011,
//24'b0000_0011_1110_1011_0110_1000,
//24'b0000_0011_1111_0000_1000_1001,
//24'b0000_1000_1000_0110_1111_0100,
//24'b0000_0011_1110_0000_0110_1111,
//24'b0000_1000_0111_1100_0111_0000,
//24'b0000_0011_1110_0001_1101_0001,
//24'b0000_0011_1110_1110_1110_0101,
//24'b0000_1000_1000_0100_1100_0101,
//24'b0000_0011_1101_1101_1100_1001,
//HPF
24'b0111_1111_1001_1001_0110_0001 //scale
};

//notch logic
assign notch_coeff_data_o[0]   = coeff_data[LPF_COEFF][19:0];
assign notch_coeff_data_o[1]   = 20'b0100_0000_0000_0000_0000;
assign notch_coeff_data_o[2]   = coeff_data[LPF_COEFF+1][19:0];
assign notch_coeff_data_o[3]   = 20'b0100_0000_0000_0000_0000;
assign notch_coeff_data_o[4]   = coeff_data[LPF_COEFF+2][19:0];
assign notch_coeff_data_o[5]   = coeff_data[LPF_COEFF+3][19:0];

assign notch_coeff_data_o[6]   = coeff_data[LPF_COEFF][19:0];
assign notch_coeff_data_o[7]   = 20'b0100_0000_0000_0000_0000;
assign notch_coeff_data_o[8]   = coeff_data[LPF_COEFF+4][19:0];
assign notch_coeff_data_o[9]   = 20'b0100_0000_0000_0000_0000;
assign notch_coeff_data_o[10]  = coeff_data[LPF_COEFF+5][19:0];
assign notch_coeff_data_o[11]  = coeff_data[LPF_COEFF+6][19:0];

assign notch_coeff_data_o[12]  = coeff_data[LPF_COEFF+7][19:0];
assign notch_coeff_data_o[13]  = 20'b0100_0000_0000_0000_0000;
assign notch_coeff_data_o[14]  = coeff_data[LPF_COEFF+8][19:0];
assign notch_coeff_data_o[15]  = 20'b0100_0000_0000_0000_0000;
assign notch_coeff_data_o[16]  = coeff_data[LPF_COEFF+9][19:0];
assign notch_coeff_data_o[17]  = coeff_data[LPF_COEFF+10][19:0];

assign notch_coeff_data_o[18]  = coeff_data[LPF_COEFF+7][19:0];
assign notch_coeff_data_o[19]  = 20'b0100_0000_0000_0000_0000;
assign notch_coeff_data_o[20]  = coeff_data[LPF_COEFF+11][19:0];
assign notch_coeff_data_o[21]  = 20'b0100_0000_0000_0000_0000;
assign notch_coeff_data_o[22]  = coeff_data[LPF_COEFF+12][19:0];
assign notch_coeff_data_o[23]  = coeff_data[LPF_COEFF+13][19:0];

//assign notch_coeff_data_o[24]  = coeff_data[LPF_COEFF+11][19:0];
//assign notch_coeff_data_o[25]  = 20'b0100_0000_0000_0000_0000;
//assign notch_coeff_data_o[26]  = coeff_data[LPF_COEFF+1][19:0];
//assign notch_coeff_data_o[27]  = 20'b0100_0000_0000_0000_0000;
//assign notch_coeff_data_o[28]  = coeff_data[LPF_COEFF+12][19:0];
//assign notch_coeff_data_o[29]  = coeff_data[LPF_COEFF+13][19:0];
//assign notch_coeff_data_o[30]  = coeff_data[LPF_COEFF+11][19:0];
//assign notch_coeff_data_o[31]  = 20'b0100_0000_0000_0000_0000;
//assign notch_coeff_data_o[32]  = coeff_data[LPF_COEFF+1][19:0];
//assign notch_coeff_data_o[33]  = 20'b0100_0000_0000_0000_0000;
//assign notch_coeff_data_o[34]  = coeff_data[LPF_COEFF+14][19:0];
//assign notch_coeff_data_o[35]  = coeff_data[LPF_COEFF+15][19:0];
//assign notch_coeff_data_o[36]  = coeff_data[LPF_COEFF+16][19:0];
//assign notch_coeff_data_o[37]  = 20'b0100_0000_0000_0000_0000;
//assign notch_coeff_data_o[38]  = coeff_data[LPF_COEFF+1][19:0];
//assign notch_coeff_data_o[39]  = 20'b0100_0000_0000_0000_0000;
//assign notch_coeff_data_o[40]  = coeff_data[LPF_COEFF+17][19:0];
//assign notch_coeff_data_o[41]  = coeff_data[LPF_COEFF+18][19:0];

//LPF LOGIC
genvar b;
generate
   for (b=0; b<LPF_COEFF; b++) begin : LPF_COEFFS
     assign lpf_coeff_data_o[b]           = coeff_data[b][17:0];
     assign lpf_coeff_data_o[LPF_COEFF+b] = coeff_data[LPF_COEFF-1-b][17:0];   
   end
endgenerate

// HPF
assign hpf_coeff_data_o = coeff_data[LPF_COEFF+NOTCH_COEFF+HPF_COEFF-1];


reg [15:0] notch_filter_bypass;
reg [15:0] lpf_filter_bypass;
reg [15:0] hpf_filter_bypass;

assign o_notch_filter_bypass = notch_filter_bypass[EEG_CHN_NUM-1:0];
assign o_lpf_filter_bypass   = lpf_filter_bypass[EEG_CHN_NUM-1:0];
assign o_hpf_filter_bypass   = hpf_filter_bypass[EEG_CHN_NUM-1:0];

always @(posedge i_clk or negedge i_rst_n) begin : FILTER_SPI_REG
  if (!i_rst_n) begin
//  filter_seq          <= 3'h0;
    notch_filter_bypass <= 16'hFFFF;
    lpf_filter_bypass   <= 16'hFFFF;
    hpf_filter_bypass   <= 16'hFFFF;
    eeg_int_en          <= 2'b0;
    eeg_int_clr         <= 1'b0;
    cic_data_ignore_tar <= 16'h3a94;
    coeff_addr      <= 8'h00;
    for(int a=0;a<LPF_COEFF+NOTCH_COEFF+HPF_COEFF;a++)begin
      coeff_data[a]  <= coeff_data_def[a];

      stim_eeg_sync_en <= 1'b0;
      filter_dly_tgt <= 24'hFF;
    end
  end
  else begin
    case (i_addr[ADDR_WIDTH-1:0])
//    `FILTER_SEQ_CTRL       :  filter_seq                         <= i_wr? i_wr_data[2:0] : filter_seq;
      `FILTER_HPF_BP_L       :  hpf_filter_bypass[7:0]             <= i_wr ? i_wr_data[7:0] : hpf_filter_bypass[7:0]; 
      `FILTER_HPF_BP_H       :  hpf_filter_bypass[15:8]            <= i_wr ? i_wr_data[7:0] : hpf_filter_bypass[15:8]; 
      `FILTER_LPF_BP_L       :  lpf_filter_bypass[7:0]             <= i_wr ? i_wr_data[7:0] : lpf_filter_bypass[7:0]; 
      `FILTER_LPF_BP_H       :  lpf_filter_bypass[15:8]            <= i_wr ? i_wr_data[7:0] : lpf_filter_bypass[15:8]; 
      `FILTER_NOF_BP_L       :  notch_filter_bypass[7:0]           <= i_wr ? i_wr_data[7:0] : notch_filter_bypass[7:0]; 
      `FILTER_NOF_BP_H       :  notch_filter_bypass[15:8]          <= i_wr ? i_wr_data[7:0] : notch_filter_bypass[15:8]; 
      `FILTER_INT_CTRL       :  eeg_int_en                         <= i_wr ? i_wr_data[1:0] : eeg_int_en; 
      `FILTER_INT_STS        :  eeg_int_clr                        <= (i_wr & !int_clear_type)? i_wr_data[0]: (i_rd & int_clear_type)? (eeg_int_sts & i_rd) : 1'b0;
      `GENERAL_INTERUPT_STATUS_REG01  :  eeg_int_clr               <= (i_rd & int_clear_type)? (eeg_int_sts & i_rd) : 1'b0;
      `FILTER_NOTCH_DATA_GONE_L       :  cic_data_ignore_tar[7:0]  <= i_wr ? i_wr_data[7:0] : cic_data_ignore_tar[7:0]; 
      `FILTER_NOTCH_DATA_GONE_H       :  cic_data_ignore_tar[15:8] <= i_wr ? i_wr_data[7:0] : cic_data_ignore_tar[15:8]; 
      `FILTER_COEFF_ADDR     :  coeff_addr                         <= i_wr ? i_wr_data[7:0] : coeff_addr;
      `FILTER_COEFF_DATA1    :  coeff_data[coeff_addr][7:0]        <= i_wr ? i_wr_data[7:0] : coeff_data[coeff_addr][7:0]; 
      `FILTER_COEFF_DATA2    :  coeff_data[coeff_addr][15:8]       <= i_wr ? i_wr_data[7:0] : coeff_data[coeff_addr][15:8]; 
      `FILTER_COEFF_DATA3    :  coeff_data[coeff_addr][23:16]      <= i_wr ? i_wr_data[7:0] : coeff_data[coeff_addr][23:16]; 
      `FILTER_DLY_TGT_0      :  filter_dly_tgt[7:0]                <= i_wr ? i_wr_data[7:0] : filter_dly_tgt[7:0];     
      `FILTER_DLY_TGT_1      :  filter_dly_tgt[15:8]               <= i_wr ? i_wr_data[7:0] : filter_dly_tgt[15:8];  
      `FILTER_DLY_TGT_2      :  filter_dly_tgt[23:16]              <= i_wr ? i_wr_data[7:0] : filter_dly_tgt[23:16];
      `FILTER_SYNC_CTRL      :  stim_eeg_sync_en                   <= i_wr ? i_wr_data[0] : stim_eeg_sync_en;
    endcase
  end
end

////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////Lead off register ///////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

//reg [NO_OF_WAVEGEN-1:0] lead_off_int;
//wire [NO_OF_WAVEGEN-1:0] lead_off_int_rstn;
//genvar c;
//generate
//for (c = 0; c < NO_OF_WAVEGEN; c = c + 1) begin : GEN_LEAD_OFF
//assign lead_off_int_rstn[c] = atpg_en ? i_rst_n : i_rst_n & (!((lead_off_result[c] == 1'b0)  ));
//
//always @(posedge i_clk or negedge lead_off_int_rstn[c]) begin
//  if (!lead_off_int_rstn[c]) begin
//    lead_off_int[c] <= 1'b0;
//  end 
//  else if ((i_addr[ADDR_WIDTH-1:0] == `LEAD_OFF_INT) & !int_clear_type) begin
//    lead_off_int[c] <= i_wr ? i_wr_data[c] : lead_off_int[c];
//  end
//  else if ((i_addr[ADDR_WIDTH-1:0] == `LEAD_OFF_INT) & int_clear_type) begin
//    lead_off_int[c] <= i_rd ? lead_off_result[c] ? 1'b1 : 1'b0 : lead_off_int[c];
//  end
//  else if ((i_addr[ADDR_WIDTH-1:0] == `GENERAL_INTERUPT_STATUS_REG04) & int_clear_type) begin
//    lead_off_int[c] <= i_rd ? lead_off_result[c] ? 1'b1 : 1'b0 : lead_off_int[c];
//  end
//end
//end
//endgenerate

//lead off outputs

//assign  sel_stim          = lead_off_ctrl[0];
//assign lead_off_sts_clear    = lead_off_int;   
//assign  dac_en            = lead_off_ctrl[5:4];
//assign lead_off_stop_en       = lead_off_int[0]; 
//assign lead_off_sts_clear    = lead_off_int[1];   
//assign lead_off_stop1_en       = lead_off_int[3]; 
//assign lead_off_int_en       = lead_off_int[5:4]; 
//assign comp_low_ch0              = lead_off_int[2]; 
//assign comp_low_ch1              = lead_off_int[6]; 

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////OTP_Registers Write///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


localparam NO_OF_TRIM = 17;
/////////////////////
////interface
/////////////////////
//spi-otp
//to otp
wire  [7:0] 	trim_to_otp[NO_OF_TRIM-1:0];

//local reg for otp inputs
wire [7:0] 	trim_from_otp[NO_OF_TRIM-1:0]; 
reg 		trim_reg_updated[NO_OF_TRIM-1:0];
reg [7:0] 	trim_reg[NO_OF_TRIM-1:0];

reg [7:0] 	d2a_spare_wr_reg0;
reg [7:0] 	d2a_spare_wr_reg1;
reg [7:0] 	d2a_spare_wr_reg2;
wire  		OTP_Reset_Done;
wire 		i_otp_busy;
wire [15:0] 	i_DEBUG_otp;
reg  [7:0]      unlock_reg;
wire   		otp_unlock;
wire   		otp_spi_wr;
wire            key_trim;
wire            wr_working;
wire            OTP_Reset_Done_sync;

//---------otp sync synchronours---------------//
//synchronious only the OTP_Reset_Done

common_sync_bit   //common_bit_sync 
 #(
.RST_VAL(0))
 u_otp_Reset_Done (
       .clk(i_clk),
       .rst_(i_rst_n),
       .async_in(OTP_Reset_Done),
       .sync_out(OTP_Reset_Done_sync)
       );

assign trim_from_otp = spi_otp.trim_read;

////////////////////////////////////////////////////////////////
/////trim0(trim_tag)
///////////////////////////////////////////////////////////////


genvar otp_num;
generate 

  for (otp_num=0;otp_num<NO_OF_TRIM-1;otp_num++) begin : otp_trim

    always@(posedge i_clk or negedge i_rst_n) begin
      if(!i_rst_n)begin
      trim_reg[otp_num]           <= 8'h00; //8'h5a;
      trim_reg_updated[otp_num]   <= 1'b0;
      end
      else if(OTP_Reset_Done_sync & !trim_reg_updated[otp_num])begin   // @OTP_Reset_Done OTP values are loaded
       trim_reg[otp_num]           <= trim_from_otp[otp_num];
       trim_reg_updated[otp_num]   <= 1'b1;
      end
      else if(!i_otp_busy & (i_addr[ADDR_WIDTH-1:0]==(`OTP_TRIMDATA0 + otp_num)) && i_wr) begin
        trim_reg[otp_num]          <= i_wr_data;
      end
    end

    assign trim_to_otp[otp_num] = trim_reg[otp_num];

  end

endgenerate

always@(posedge i_clk or negedge i_rst_n) begin
  if(!i_rst_n)begin
      trim_reg[NO_OF_TRIM-1]           <= 8'h00; //8'h5a;
      trim_reg_updated[NO_OF_TRIM-1]   <= 1'b0;
  end
  else if(OTP_Reset_Done_sync & !trim_reg_updated[NO_OF_TRIM-1])begin   // @OTP_Reset_Done OTP values are loaded
       trim_reg[NO_OF_TRIM-1]           <= trim_from_otp[NO_OF_TRIM-1];
       trim_reg_updated[NO_OF_TRIM-1]   <= 1'b1;
  end
end

assign trim_to_otp[NO_OF_TRIM-1] = trim_reg[NO_OF_TRIM-1];

////////////////////////////////////////////////////////////////
/////unlock
///////////////////////////////////////////////////////////////
wire wr_working_sync;
reg wr_working_sync_d1;
common_sync_bit    
 #(
.RST_VAL(0))
 u_wr_working_sync(
       .clk(i_clk),
       .rst_(i_rst_n),
       .async_in(wr_working),
       .sync_out(wr_working_sync)
       );

always@(posedge i_clk or negedge i_rst_n) begin
  if(!i_rst_n)begin
  wr_working_sync_d1      <=1'b0;
  end
  else begin
  wr_working_sync_d1       <= wr_working_sync;
  end
end

always@(posedge i_clk or negedge i_rst_n) begin
  if(!i_rst_n)begin
    unlock_reg <= 8'h00;
  end
  else if((i_addr[ADDR_WIDTH-1:0]==`OTP_UNLOCK) && i_wr) begin
    unlock_reg <= i_wr_data;
  end
  else if(wr_working_sync_d1 && !wr_working_sync) begin
    unlock_reg      <=8'h00;
  end
end

wire       key_data,spi_wr_data,spi_rd_data;
reg  [7:0] spi_otp_addr,spi_otp_data;
wire [7:0] spi_data_read;
wire       spi_otp_addr_valid;

assign spi_otp_addr_valid = (spi_otp_addr>=8'h14) && (spi_otp_addr<=8'h7F);
assign otp_unlock  = unlock_reg[0] && key_trim;
assign otp_spi_wr  = unlock_reg[1] && key_trim;
assign spi_wr_data = unlock_reg[0] && key_data && spi_otp_addr_valid;
assign spi_rd_data = unlock_reg[2] && key_data;
assign key_trim    = unlock_reg[7:3]==5'b10101;
assign key_data    = unlock_reg[7:3]==5'b01010; 

always@(posedge i_clk or negedge i_rst_n) begin
  if (!i_rst_n) begin
    spi_otp_data           <= 8'h00;
  end
  else if (!i_otp_busy & (i_addr[ADDR_WIDTH-1:0]==`OTP_DATA) && i_wr) begin
    spi_otp_data          <= i_wr_data;
  end
end

always@(posedge i_clk or negedge i_rst_n) begin
  if (!i_rst_n) begin
    spi_otp_addr           <= 8'h00;
  end
  else if (!i_otp_busy & (i_addr[ADDR_WIDTH-1:0]==`OTP_ADDR) && i_wr) begin
    spi_otp_addr           <= i_wr_data;
  end
end


reg  [3:0] otp_trims_sel;
wire [7:0] otp_trims_data;
always @(posedge i_clk or negedge i_rst_n) begin
  if (!i_rst_n) begin
    otp_trims_sel           <= 4'h0;
  end
  else if (!i_otp_busy & (i_addr[ADDR_WIDTH-1:0]==`OTP_TRIMS_DBG_SEL) && i_wr) begin
    otp_trims_sel           <= i_wr_data;
  end
end

assign otp_trims_data = trim_from_otp[otp_trims_sel]; 

reg [2:0] spi_otp_slct;
always @(posedge i_clk or negedge i_rst_n) begin
  if (!i_rst_n) begin
    spi_otp_slct           <= 3'b0;
  end
  else if (!i_otp_busy & (i_addr[ADDR_WIDTH-1:0]==`OTP_WAVEGEN_NUMBER) && i_wr) begin
    spi_otp_slct           <= i_wr_data[2:0];
  end
end

wire [7:0] otp_data_spi_sync;
common_sync_bit    
 #(
.RST_VAL(0))
 u_otp_data_spi_sync [7:0](
       .clk(i_clk),
       .rst_(i_rst_n),
       .async_in(spi_data_read),
       .sync_out(otp_data_spi_sync)
       );

////OTP outputs via interface 
assign spi_otp.trim = trim_to_otp;

assign PROD_ID = trim_from_otp[NO_OF_TRIM-1][2:0];

assign spi_otp.so_ctrl[0] = otp_unlock;
assign spi_otp.so_ctrl[1] = otp_spi_wr;
assign spi_otp.so_ctrl[2] = spi_wr_data;
assign spi_otp.so_ctrl[3] = spi_rd_data;
assign spi_otp.so_ctrl[11:4] = spi_otp_addr;
assign spi_otp.so_ctrl[19:12]= spi_otp_data;
assign spi_otp.so_ctrl[22:20]= spi_otp_slct;

assign OTP_Reset_Done = spi_otp.os_ctrl[0];
assign i_otp_busy     = spi_otp.os_ctrl[1];
assign i_DEBUG_otp    = spi_otp.os_ctrl[17:2];
assign wr_working     = spi_otp.os_ctrl[18];
assign spi_data_read  = spi_otp.os_ctrl[26:19];

//////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////wave gen inst //////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
assign spi_wg.global_en = drivea_global_en;
assign spi_wg.stop_wavegen = 1'b0; //ana_int_stop_wavegen_reg & ana_stimu_ch_intr_sts;
assign spi_wg.stimu_en = stimu_en;

wire i_rd_normal;
assign i_rd_normal = (drive_slct_03_47==2'b00)? (i_addr[ADDR_WIDTH-1:0] == `GENERAL_INTERUPT_STATUS_REG02) & i_rd :
                     (drive_slct_03_47==2'b01)? (i_addr[ADDR_WIDTH-1:0] == `GENERAL_INTERUPT_STATUS_REG03) & i_rd :
                     (drive_slct_03_47==2'b10)? (i_addr[ADDR_WIDTH-1:0] == `GENERAL_INTERUPT_STATUS_REG04) & i_rd : 
                     (drive_slct_03_47==2'b11)? (i_addr[ADDR_WIDTH-1:0] == `GENERAL_INTERUPT_STATUS_REG05) & i_rd : (i_addr[ADDR_WIDTH-1:0] == `GENERAL_INTERUPT_STATUS_REG02) & i_rd ;

wire [7:0] o_wg_driver_rd_data[NO_OF_WAVEGEN-1:0];

wire [15:0] wavegen_reg_acc;
wire        wavegen_reg_acc_en;
wire [15:0] wavegen_reg_acc_wr;
wire [9:0] wavegen_reg_acc_addr[15:0];

assign wavegen_reg_acc = {wavegen_reg_acc_8_15,wavegen_reg_acc_0_7};
assign      wavegen_reg_acc_en = |wavegen_reg_acc; 


genvar i;

generate 
  for(i=0;i<NO_OF_WAVEGEN;i=i+1) begin : wg_reg_block

assign wavegen_reg_acc_wr[i]   = wavegen_reg_acc_en? wavegen_reg_acc[i]? i_wavegen_wr : 1'b0 : i_wavegen_wr;
assign wavegen_reg_acc_addr[i] = wavegen_reg_acc[i]?   ({2'b00,i_addr} + 10'h40 * i) : {drive_slct_03_47,i_addr};


  spi_reg_wavegen#(
    .ADDR_WIDTH(10),
    .DATA_WIDTH(DATA_WIDTH),
    .HLF_WV_NO_PTS(HLF_WV_NO_PTS),
    .NO_OF_WAVEGEN(i),
    .OUT_NO_BITS(8))
  u_spi_reg_wavegen(
   .i_clk                     (i_clk),
   .i_rst_n                   (i_rst_n),
   .i_wr                      (wavegen_reg_acc_wr[i]),
   .i_rd			(i_wavegen_rd),
   .int_clear_type            (int_clear_type),
   .i_rd_normal               (i_rd_normal),
   .i_addr			(wavegen_reg_acc_addr[i]),
   .i_wr_data			(i_wr_data),
   . wavegen_burst_slct          ( wavegen_burst_slct),

   .i_wg_driver_in_wave_addr	(spi_wg.i_wg_driver_in_wave_addr[i]),
   .i_wg_driver_ems_wave_addr	(spi_wg.i_wg_driver_ems_wave_addr[i]),
   .i_wg_driver_source	(spi_wg.i_wg_driver_source[i]),
   .i_period_num              (spi_wg.i_period_num[i]),
   .o_wg_driver_en		(spi_wg.o_wg_driver_en[i]),
   .o_period_sel              (spi_wg.o_period_sel[i]),
   .w_isel                    (spi_wg.w_isel[i]),
   .o_mul_wave_repeat         (spi_wg.mul_wave_repeat[i]),
   .o_config_reg              (spi_wg.o_config_reg[i]),
   .o_wg_driver_sw_config     (spi_wg.o_wg_driver_sw_config[i]),
   .o_wg_driver_rest_t	(spi_wg.o_wg_driver_rest_t[i]), 
   .o_wg_driver_silent_t	(spi_wg.o_wg_driver_silent_t[i]),
   .o_wg_driver_rest_t1	(spi_wg.o_wg_driver_rest_t1[i]), 
   .o_wg_driver_silent_t1	(spi_wg.o_wg_driver_silent_t1[i]),
   .o_wg_driver_rest_t2	(spi_wg.o_wg_driver_rest_t2[i]), 
   .o_wg_driver_silent_t2	(spi_wg.o_wg_driver_silent_t2[i]),
   .o_wg_driver_delay_lim	(spi_wg.o_wg_driver_delay_lim[i]),
   .o_wg_driver_hlf_wave_prd	(spi_wg.o_wg_driver_hlf_wave_prd[i]),
   .o_wg_driver_neg_hlf_wave_prd	(spi_wg.o_wg_driver_neg_hlf_wave_prd[i]),
   .o_wg_driver_hlf_wave_prd1	(spi_wg.o_wg_driver_hlf_wave_prd1[i]),
   .o_wg_driver_neg_hlf_wave_prd1	(spi_wg.o_wg_driver_neg_hlf_wave_prd1[i]),
   .o_wg_driver_hlf_wave_prd2	(spi_wg.o_wg_driver_hlf_wave_prd2[i]),
   .o_wg_driver_neg_hlf_wave_prd2	(spi_wg.o_wg_driver_neg_hlf_wave_prd2[i]),		 
   .o_reg_wg_driver_point_config  (spi_wg.o_reg_wg_driver_point_config[i]),
   .o_wg_driver_alter_lim		(spi_wg.o_wg_driver_alter_lim[i]),
   .o_wg_driver_alter_silent_lim	(spi_wg.o_wg_driver_alter_silent_lim[i]),
   .o_wg_driver_alter_rest_lim          (spi_wg.o_wg_driver_alter_rest_lim[i]),
   .o_wg_driver_in_wave		(spi_wg.o_wg_driver_in_wave[i]),
   .o_mult_elec			(spi_wg.o_mult_elec[i]),
   .o_pullba_ctrl   (spi_wg.o_pullba_ctrl[i]),
   .o_dirve         (spi_wg.dirve[i]),
   .o_start_with_silent(spi_wg.o_start_with_silent[i]),
   .o_dds_mode                    (spi_wg.dds_mode[i]),

   .o_data_scl                    (spi_wg.o_data_scl[i]),
   .o_ems_data_ctrl               (spi_wg.o_ems_data_ctrl[i]),
   .alt_ems_cnt_tar               (spi_wg.alt_ems_cnt_tar[i]),
   .o_reg_wg_driver_neg_scale     (spi_wg.o_reg_wg_driver_neg_scale[i]),
   .o_wg_driver_pos_scale         (spi_wg.o_wg_driver_pos_scale[i]),
   .o_reg_wg_driver_neg_offset    (spi_wg.o_reg_wg_driver_neg_offset[i]),
   .o_reg_wg_driver_pos_offset    (spi_wg.o_reg_wg_driver_pos_offset[i]),

   .data_scl                      (spi_wg.data_scl[i]),
   .ems_data_ctrl                 (spi_wg.ems_data_ctrl[i]),
   .wg_driver_neg_scale           (spi_wg.wg_driver_neg_scale[i]),
   .wg_driver_pos_scale           (spi_wg.wg_driver_pos_scale[i]),
   .wg_driver_neg_offset          (spi_wg.wg_driver_neg_offset[i]),
   .wg_driver_pos_offset          (spi_wg.wg_driver_pos_offset[i]),      

   .o_reg_wg_cal_addr             (spi_wg.o_reg_wg_cal_addr[i]),

   .o_rd_data                     (o_wg_driver_rd_data[i]),
   .o_no_of_num_slient_disable(spi_wg.o_no_of_num_slient_disable[i]),
   .o_no_of_num_slient_tar(spi_wg.o_no_of_num_slient_tar[i]),
   .o_wg_driver_int_addr0         (spi_wg.o_wg_driver_int_addr0[i]),
   .o_wg_driver_int_addr1         (spi_wg.o_wg_driver_int_addr1[i]),
   .o_wg_driver_int_en            (spi_wg.o_wg_driver_int_en[i]),
   .o_addr0_int_clr               (spi_wg.o_addr0_int_clr[i]),    
   .o_addr1_int_clr               (spi_wg.o_addr1_int_clr[i]),
   .o_wg_driver_int_cnt           (spi_wg.o_wg_driver_int_cnt[i]),
   .i_wg_driver_int_sts           (spi_wg.i_wg_driver_int_sts[i])
  );
     end
endgenerate

//------------------------------------------------------------------------------------
//--------------------NIRS inst---------------------------------------------------
//------------------------------------------------------------------------------------
wire [7:0] nirs_rd_data;

  spi_reg_nirs  #(
    .ADDR_WIDTH     (ADDR_WIDTH),
    .DATA_WIDTH     (DATA_WIDTH),
    .NO_OF_CHANNEL  (NO_OF_NIRS)
  ) u_spi_reg_nirs (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_addr         (i_addr),
    .i_wr           (i_nirs_wr),
    .i_rd           (i_nirs_rd),
    .i_rd_normal    (i_rd),
    .i_wr_data      (i_wr_data),
    .o_rd_data      (nirs_rd_data),

    .atm_adj_mode   (atm_adj_mode[5:3]),
    .atm_adj        (atm_adj),
    .atm_adj_data   (atm_adj_data),

    .ppg_dis        (ppg_dis),
    .ppg_clk_div    (ppg_clk_div),
    .ana_ppgclk_inv (ana_ppgclk_inv),
    .ppg_clk50duty  (ppg_clk50duty),
    .ppg_rst_reg    (ppg_rst_reg),
    .int_clear_type (int_clear_type),

    .spi_nirs_if    (spi_nirs_if)
  );

//------------------------------------------------------------------------------------
//--------------------Register Read---------------------------------------------------
//------------------------------------------------------------------------------------
always @ (posedge i_clk or negedge i_rst_n) begin
  if (!i_rst_n)
    reg_rd_data <= 8'b0;
  else if(!i_wr) begin
    case(i_addr[ADDR_WIDTH-1:0])
      //imeas
      `IMEAS_EN_DIS_CHN_L : reg_rd_data <= imeas_en_dis_chn_l; 	   
      `IMEAS_EN_DIS_CHN_H : reg_rd_data <= imeas_en_dis_chn_h; 	   
      `IMEAS_REG_0        : reg_rd_data <= imeas_reg_0 ;
      `IMEAS_REG_1        : reg_rd_data <= imeas_reg_1 ;
      `IMEAS_REG_2        : reg_rd_data <= imeas_reg_2 ;
      `IMEAS_CTRL         : reg_rd_data <= imeas_ctrl ;
      `STABLE_TIME_0      : reg_rd_data <= stable_time_0 ;
      `STABLE_TIME_1      : reg_rd_data <= stable_time_1 ;

      `IMEAS_D0           : reg_rd_data <= imeas_chdata_wire[7:0];
      `IMEAS_D1           : reg_rd_data <= imeas_chdata_wire[15:8];
      `IMEAS_D2           : reg_rd_data <= imeas_chdata_wire[23:16];
    //`IMEAS_D3           : reg_rd_data <= imeas_chdata_wire[31:24];
 
      // clk_ctrl
      `CLK_CTRL_REG       :   reg_rd_data <={ clk_ctrl_reg};   //{2'b00,otp_to_clk_ctrl}; 
      `ANAC_CTRL          :   reg_rd_data <={ anac_ctrl};
      `TSC_EN_REG_SEL     :   reg_rd_data <=en_reg_sel;
      `TSC_CTRL           :   reg_rd_data <={4'b0,tsc_ctrl};
      `TSC_VDAC8B_DIN_CH1 :   reg_rd_data <= tsc_vdac8b_din_ch1;
      `SMP_DURATION	  :   reg_rd_data <= sample_duration;		
      `STABLE_DURATION_L  :   reg_rd_data <= stable_duration[7:0];		
      `STABLE_DURATION_H  :   reg_rd_data <= {4'b0,stable_duration[11:8]};	
      `TSC_INT_CRTL 	  :   reg_rd_data <= {6'b0,tsc_int_crtl_reg};
      `TSC_INT_STATUS     :   reg_rd_data <= {7'b0,tsc_intr_sts};

      `SMP_STS	          :   reg_rd_data <= {7'b0,busy_doing};		

      `VDAC_NOR_L         :   reg_rd_data <=VDAC_NOR[7:0];
    //`VDAC_NOR_H         :   reg_rd_data <={4'b0,VDAC_NOR[11:8]};

      // pmu  
      `PMU_REG0           :   reg_rd_data <= {pmu_reg0[7:0]};     
      `PMU_REG1           :   reg_rd_data <= {6'b0,pmu_reg1[1:0]};     
      `O_CLK_SEL          :   reg_rd_data <= {7'b0,o_clk_sel};     

      // otp
      `OTP_DEBUG1         :   reg_rd_data <=  i_DEBUG_otp[7:0];   //i_DEBUG_OTP[7:0];
      `OTP_DEBUG2         :   reg_rd_data <=  i_DEBUG_otp[15:8];  //i_DEBUG_OTP[15:8];

      `OTP_TRIMDATA0      :   reg_rd_data <=  trim_reg[0]; //trim_tag_reg; 
      `OTP_TRIMDATA1      :   reg_rd_data <=  trim_reg[1]; //d2a_trim1_to_otp;  
      `OTP_TRIMDATA2      :   reg_rd_data <=  trim_reg[2]; //d2a_trim2_to_otp; 
      `OTP_TRIMDATA3      :   reg_rd_data <=  trim_reg[3]; //d2a_trim3_to_otp; 
      `OTP_TRIMDATA4      :   reg_rd_data <=  trim_reg[4]; //d2a_trim4_to_otp; 
      `OTP_TRIMDATA5      :   reg_rd_data <=  trim_reg[5]; //d2a_trim5_to_otp; 
      `OTP_TRIMDATA6      :   reg_rd_data <=  trim_reg[6]; //d2a_trim6_to_otp;
      `OTP_TRIMDATA7      :   reg_rd_data <=  trim_reg[7]; //d2a_trim7_to_otp; 
      `OTP_TRIMDATA8      :   reg_rd_data <=  trim_reg[8]; //d2a_trim8_to_otp; 
      `OTP_TRIMDATA9      :   reg_rd_data <=  trim_reg[9]; //d2a_trim9_to_otp;
      `OTP_TRIMDATA10     :   reg_rd_data <=  trim_reg[10]; //d2a_trim9_to_otp;
      `OTP_TRIMDATA11     :   reg_rd_data <=  trim_reg[11]; //d2a_trim9_to_otp;
      `OTP_TRIMDATA12     :   reg_rd_data <=  trim_reg[12]; //d2a_trim9_to_otp;
      `OTP_TRIMDATA13     :   reg_rd_data <=  trim_reg[13]; //d2a_trim9_to_otp;
      `OTP_TRIMDATA14     :   reg_rd_data <=  trim_reg[14]; //d2a_trim9_to_otp;
      `OTP_TRIMDATA15     :   reg_rd_data <=  trim_reg[15]; //d2a_trim9_to_otp;
      `OTP_TRIMDATA16     :   reg_rd_data <=  trim_reg[16]; //d2a_trim9_to_otp;

      `OTP_WAVEGEN_NUMBER :   reg_rd_data <= {5'b0,spi_otp_slct};

      `OTP_UNLOCK         :   reg_rd_data <=   unlock_reg;
      `OTP_DATA           :   reg_rd_data <=  spi_otp_data;
      `OTP_ADDR           :   reg_rd_data <=  spi_otp_addr;
      `OTP_MEM_DATA       :   reg_rd_data <=  otp_data_spi_sync;
      `OTP_TRIMS_DBG_SEL  :   reg_rd_data <=  {4'h0,otp_trims_sel};
      `OTP_TRIMS_DBG_DATA :   reg_rd_data <=  otp_trims_data;
 
      `GPIO_PU_CTRL           :   reg_rd_data <= {pu_ctrl};				  	   
      `GPIO_PD_CTRL           :   reg_rd_data <= {pd_ctrl};                           	 
      `GPIO_SR_PDRV0_1_CTRL   :   reg_rd_data <= {5'b0, sr_pdrv0_1_ctrl};
      `GPIO_NIRS_OUT_CTRL     :   reg_rd_data <= {7'b0, nirs_out_ctrl};       
      `GPIO_NORMAL_OUT_CTRL   :   reg_rd_data <= {7'b0, normal_out_ctrl};                                           
       
      // lead off
//    `LEAD_OFF_CTRL          :  reg_rd_data  <= lead_off_ctrl 	; 

//    `COUNTER_TH_TGT_0       :  reg_rd_data  <= counter_th_tgt[lead_off_blk_slct_reg][7:0];
//    `COUNTER_TH_TGT_1       :  reg_rd_data  <= counter_th_tgt[lead_off_blk_slct_reg][15:8]; 
//    `COUNTER_TH_TGT_2       :  reg_rd_data  <= counter_th_tgt[lead_off_blk_slct_reg][23:16]; 
//    `COUNTER_TH_TGT_3       :  reg_rd_data  <= counter_th_tgt[lead_off_blk_slct_reg][31:24];

//    `TIMER_CNT_TGT_0     :  reg_rd_data  <= timer_cnt_tgt[lead_off_blk_slct_reg][7:0] 	; 
//    `TIMER_CNT_TGT_1     :  reg_rd_data  <= timer_cnt_tgt[lead_off_blk_slct_reg][15:8] 	; 
//    `TIMER_CNT_TGT_2     :  reg_rd_data  <= timer_cnt_tgt[lead_off_blk_slct_reg][23:16] 	; 
//    `TIMER_CNT_TGT_3     :  reg_rd_data  <= timer_cnt_tgt[lead_off_blk_slct_reg][31:24] 	; 

//    `LEAD_OFF_DAC_EN      : reg_rd_data  <= lead_off_dac_en      ; 
//    `LEAD_OFF_STOP_EN     : reg_rd_data  <= lead_off_stop_en     ; 
//    `LEAD_OFF_INT_EN      : reg_rd_data  <= lead_off_int_en      ; 
//    `LEAD_OFF_COMP_LOW_EN : reg_rd_data  <= lead_off_comp_low_en ; 		
//    `LEAD_OFF_STOP     : reg_rd_data  <= lead_off_stop     ; 


//    `LEAD_OFF_TGT           :  reg_rd_data  <= lead_off_tgt_reg 	; 
//    `LEAD_OFF_INT           :  reg_rd_data  <= lead_off_result; 
//    `LEAD_OFF_ANA           :  reg_rd_data  <= {A2D_COMP0_7}; 

      // stim mon 
      `STIM_PAD_CTRL       :  reg_rd_data  <=  {stim_pad_ctrl}    ;        
      `STIM_PAD_CTRL1       :  reg_rd_data  <=  {stim_pad_ctrl1}    ;        
      `STIM_MON_PERIOD_L   :  reg_rd_data  <=  stim_mon_period_l;     
      `STIM_MON_PERIOD_H   :  reg_rd_data  <=  stim_mon_period_h;      
      `STIM_MON_CTRL2    :  reg_rd_data  <=  {1'b0,stim_mon_ctrl2} ;      
      `STIM_MON_INT_STS    :  reg_rd_data  <= {stim_mon_int_topin_en_reg,stim_mon_delta_data_sel,stim_mon_cycle_int_sts,stim_mon_int_sts,stim_mon_delta_int_sts};

`STIM_MON_LOFF_INT_STS0        :   reg_rd_data  <= stim_mon_leadoff_int_sts[7:0]; 
`STIM_MON_LOFF_INT_STS1        :   reg_rd_data  <= stim_mon_leadoff_int_sts[15:8];
`STIM_MON_SHORT_INT_STS0       :   reg_rd_data  <= stim_mon_short_int_sts[7:0];
`STIM_MON_SHORT_INT_STS1       :   reg_rd_data  <= stim_mon_short_int_sts[15:8];

`STIM_MON_LOFF_SHORT_INT_CTRL   :  reg_rd_data  <= stim_mon_loff_short_int_ctrl;    
`STIM_MON_LOFF_TH0           	:  reg_rd_data  <=    threshold_leadoff[7:0]; 
`STIM_MON_LOFF_TH1           	:  reg_rd_data  <=     {6'b0,threshold_leadoff[9:8]};
`STIM_MON_SHORT_TH0           	:  reg_rd_data  <=     threshold_short[7:0];  
`STIM_MON_SHORT_TH1           	:  reg_rd_data  <=     {6'b0,threshold_short[9:8]};  
`STIM_MON_TH_TGT           	:  reg_rd_data  <=     threshold_tgt;         

      `STIM_PAD0_TGT0_L    :  reg_rd_data  <=  stim_pad0_tgt0_l ; 
      `STIM_PAD0_TGT0_H    :  reg_rd_data  <=  stim_pad0_tgt0_h ; 
      `STIM_PAD0_TGT1_L    :  reg_rd_data  <=  stim_pad0_tgt1_l ; 
      `STIM_PAD0_TGT1_H    :  reg_rd_data  <=  stim_pad0_tgt1_h ; 
      `STIM_PAD0_TGT2_L    :  reg_rd_data  <=  stim_pad0_tgt2_l ; 
      `STIM_PAD0_TGT2_H    :  reg_rd_data  <=  stim_pad0_tgt2_h ; 
      `STIM_PAD0_TGT3_L    :  reg_rd_data  <=  stim_pad0_tgt3_l ; 
      `STIM_PAD0_TGT3_H    :  reg_rd_data  <=  stim_pad0_tgt3_h ; 

      `STIM_PAD1_TGT0_L    : reg_rd_data  <=   stim_pad1_tgt0_l ; 
      `STIM_PAD1_TGT0_H    : reg_rd_data  <=   stim_pad1_tgt0_h ; 
      `STIM_PAD1_TGT1_L    : reg_rd_data  <=   stim_pad1_tgt1_l ; 
      `STIM_PAD1_TGT1_H    : reg_rd_data  <=   stim_pad1_tgt1_h ; 
      `STIM_PAD1_TGT2_L    : reg_rd_data  <=   stim_pad1_tgt2_l ; 
      `STIM_PAD1_TGT2_H    : reg_rd_data  <=   stim_pad1_tgt2_h ; 
      `STIM_PAD1_TGT3_L    : reg_rd_data  <=   stim_pad1_tgt3_l ; 
      `STIM_PAD1_TGT3_H    : reg_rd_data  <=   stim_pad1_tgt3_h ; 

      `STIM_ADC_DATA_TAG_L : reg_rd_data  <= A2D_ADC_DATA_TAG[7:0] ;        
      `STIM_ADC_DATA_TAG_H : reg_rd_data  <= A2D_ADC_DATA_TAG[15:8]  ;        
      `STIM_ADC_DELTA_DATA_TAG_L : reg_rd_data  <= A2D_ADC_DELTA_DATA_TAG[7:0] ;        
      `STIM_ADC_DELTA_DATA_TAG_H : reg_rd_data  <= {A2D_ADC_DELTA_DATA_TAG[15:12],select_2nd_max_min,adc_delta_data_cap_in_manual,A2D_ADC_DELTA_DATA_TAG[9:8]}  ;        

      // analog register
      // My add
      `ANA_EN_SECTION_SEL    :  reg_rd_data  <= read_adc_data_en ? one_cycle_data[1*8-1  : 0*8]  :   {7'b0, ana_en_sec_reg}            ;
      `ANA_ENABLE_REG_0      :  reg_rd_data  <= read_adc_data_en ? one_cycle_data[2*8-1  : 1*8]  :   ana_enable_reg[ana_en_sec_reg][0] ;
      `ANA_ENABLE_REG_1      :  reg_rd_data  <= read_adc_data_en ? one_cycle_data[3*8-1  : 2*8]  :   ana_enable_reg[ana_en_sec_reg][1] ;
      `ANA_ENABLE_REG_2      :  reg_rd_data  <= read_adc_data_en ? one_cycle_data[4*8-1  : 3*8]  :   ana_enable_reg[ana_en_sec_reg][2] ;
      `ANA_ENABLE_REG_3      :  reg_rd_data  <= read_adc_data_en ? one_cycle_data[5*8-1  : 4*8]  :   ana_enable_reg[ana_en_sec_reg][3] ;
      `ANA_ENABLE_REG_4      :  reg_rd_data  <= read_adc_data_en ? one_cycle_data[6*8-1  : 5*8]  :   ana_enable_reg[ana_en_sec_reg][4] ;
      `ANA_ENABLE_REG_5      :  reg_rd_data  <= read_adc_data_en ? one_cycle_data[7*8-1  : 6*8]  :   ana_enable_reg[ana_en_sec_reg][5] ;
      `ANA_ENABLE_REG_6      :  reg_rd_data  <= read_adc_data_en ? one_cycle_data[8*8-1  : 7*8]  :   ana_enable_reg[ana_en_sec_reg][6] ;
      `ANA_ENABLE_REG_7      :  reg_rd_data  <= read_adc_data_en ? one_cycle_data[9*8-1  : 8*8]  :   ana_enable_reg[ana_en_sec_reg][7] ;
      `ANA_ENABLE_REG_8      :  reg_rd_data  <= read_adc_data_en ? one_cycle_data[10*8-1 : 9*8]  :   ana_enable_reg[ana_en_sec_reg][8] ;
      `ANA_ENABLE_REG_9      :  reg_rd_data  <= read_adc_data_en ? one_cycle_data[11*8-1 : 10*8] :   ana_enable_reg[ana_en_sec_reg][9] ;
      `ANA_ENABLE_REG_10     :  reg_rd_data  <= read_adc_data_en ? one_cycle_data[12*8-1 : 11*8] :   ana_enable_reg[ana_en_sec_reg][10] ;
      `ANA_ENABLE_REG_11     :  reg_rd_data  <= read_adc_data_en ? one_cycle_data[13*8-1 : 12*8] :   ana_enable_reg[ana_en_sec_reg][11] ;
      `ANA_ENABLE_REG_12     :  reg_rd_data  <= read_adc_data_en ? one_cycle_data[14*8-1 : 13*8] :   ana_enable_reg[ana_en_sec_reg][12] ;
      `ANA_ENABLE_REG_13     :  reg_rd_data  <= read_adc_data_en ? one_cycle_data[15*8-1 : 14*8] :   ana_enable_reg[ana_en_sec_reg][13] ;
      `ANA_ENABLE_REG_14     :  reg_rd_data  <= read_adc_data_en ? one_cycle_data[16*8-1 : 15*8] :   ana_enable_reg[ana_en_sec_reg][14] ;

      `ANA_GEN_SECTION_SEL   :  reg_rd_data  <= read_adc_data_en ? one_cycle_data[17*8-1 : 16*8] :   {5'b0, ana_gen_sec_reg}          ;
      `ANA_GEN_REG_1         :  reg_rd_data  <= read_adc_data_en ? one_cycle_data[18*8-1 : 17*8] :   ana_gen_reg[ana_gen_sec_reg][0]  ;
      `ANA_GEN_REG_2         :  reg_rd_data  <= read_adc_data_en ? one_cycle_data[19*8-1 : 18*8] :   ana_gen_reg[ana_gen_sec_reg][1]  ;
      `ANA_GEN_REG_3         :  reg_rd_data  <= read_adc_data_en ? one_cycle_data[20*8-1 : 19*8] :   ana_gen_reg[ana_gen_sec_reg][2]  ;
      `ANA_GEN_REG_4         :  reg_rd_data  <= read_adc_data_en ? one_cycle_data[21*8-1 : 20*8] :   ana_gen_reg[ana_gen_sec_reg][3]  ;
      `ANA_GEN_REG_5         :  reg_rd_data  <= read_adc_data_en ? one_cycle_data[22*8-1 : 21*8] :   ana_gen_reg[ana_gen_sec_reg][4]  ;
      `ANA_GEN_REG_6         :  reg_rd_data  <= read_adc_data_en ? one_cycle_data[23*8-1 : 22*8] :   ana_gen_reg[ana_gen_sec_reg][5]  ;
      `ANA_GEN_REG_7         :  reg_rd_data  <= read_adc_data_en ? one_cycle_data[24*8-1 : 23*8] :   ana_gen_reg[ana_gen_sec_reg][6]  ;
      `ANA_GEN_REG_8         :  reg_rd_data  <= read_adc_data_en ? one_cycle_data[25*8-1 : 24*8] :   ana_gen_reg[ana_gen_sec_reg][7]  ;
      `ANA_GEN_REG_9         :  reg_rd_data  <= read_adc_data_en ? one_cycle_data[26*8-1 : 25*8] :   ana_gen_reg[ana_gen_sec_reg][8]  ;
      `ANA_GEN_REG_10        :  reg_rd_data  <= read_adc_data_en ? one_cycle_data[27*8-1 : 26*8] :   ana_gen_reg[ana_gen_sec_reg][9]  ;  
      `ANA_GEN_REG_11        :  reg_rd_data  <= read_adc_data_en ? one_cycle_data[28*8-1 : 27*8] :   ana_gen_reg[ana_gen_sec_reg][10] ;  
      `ANA_GEN_REG_12        :  reg_rd_data  <= read_adc_data_en ? one_cycle_data[29*8-1 : 28*8] :   ana_gen_reg[ana_gen_sec_reg][11] ;  
      `ANA_GEN_REG_13        :  reg_rd_data  <= read_adc_data_en ? one_cycle_data[30*8-1 : 29*8] :   ana_gen_reg[ana_gen_sec_reg][12] ;
      `ANA_GEN_REG_14        :  reg_rd_data  <= read_adc_data_en ? one_cycle_data[31*8-1 : 30*8] :   ana_gen_reg[ana_gen_sec_reg][13] ;
      `ANA_GEN_REG_15        :  reg_rd_data  <= read_adc_data_en ? one_cycle_data[32*8-1 : 31*8] :   ana_gen_reg[ana_gen_sec_reg][14] ;

      `A2D_ANA_GEN_REG_0     :  reg_rd_data <= A2D_ANA_GEN_REG_0 ;
      `A2D_ANA_GEN_REG_1     :  reg_rd_data <= A2D_ANA_GEN_REG_1 ;
      `A2D_ANA_GEN_REG_2     :  reg_rd_data <= A2D_ANA_GEN_REG_2 ;
      `A2D_ANA_GEN_REG_3     :  reg_rd_data <= A2D_ANA_GEN_REG_3 ;
      `A2D_ANA_GEN_REG_4     :  reg_rd_data <= A2D_ANA_GEN_REG_4 ;
      `A2D_ANA_GEN_REG_5     :  reg_rd_data <= A2D_ANA_GEN_REG_5 ;

//    `ANAC_SHORT_BLK_SLCT                  : reg_rd_data <= {4'b0,anac_short_blk_slct_reg};              
//    `ANA_INT_SOTP_WAVEGEN                 : reg_rd_data <= ana_int_stop_wavegen_reg;      
//
//    `ANA_STIM_CH_TIMER_CNT_TH00           :  reg_rd_data <= ana_int_ch_timer_th_reg[anac_short_blk_slct_reg][7:0];          
//    `ANA_STIM_CH_TIMER_CNT_TH01           :  reg_rd_data <= ana_int_ch_timer_th_reg[anac_short_blk_slct_reg][15:8];          
//    `ANA_STIM_CH_TIMER_CNT_TH02           :  reg_rd_data <= ana_int_ch_timer_th_reg[anac_short_blk_slct_reg][23:16];          
//    `ANA_STIM_CH_TIMER_CNT_TH03           :  reg_rd_data <= ana_int_ch_timer_th_reg[anac_short_blk_slct_reg][31:24];  
//
//    `ANA_STIM_CH_COUNTER_CNT_TH00         :  reg_rd_data <= ana_int_ch_cnt_th_reg[anac_short_blk_slct_reg][7:0];          
//    `ANA_STIM_CH_COUNTER_CNT_TH01         :  reg_rd_data <= ana_int_ch_cnt_th_reg[anac_short_blk_slct_reg][15:8];          
//    `ANA_STIM_CH_COUNTER_CNT_TH02         :  reg_rd_data <= ana_int_ch_cnt_th_reg[anac_short_blk_slct_reg][23:16];          
//    `ANA_STIM_CH_COUNTER_CNT_TH03         :  reg_rd_data <= ana_int_ch_cnt_th_reg[anac_short_blk_slct_reg][31:24];  
//
      `ANAC_LVD_INT_EN                      : reg_rd_data  <= {7'b0,ana_lvd_intr_en_reg};             
//    `ANAC_COMP_INT_EN                     : reg_rd_data  <= ana_comp_ch_intr_en_reg;         
//    `ANAC_COMP_INT_TRANS_SEL              : reg_rd_data  <= ana_comp_ch_intr_trans_sel_reg;  
//    `ANAC_STIMU_INT_EN                    : reg_rd_data  <= ana_stimu_ch_intr_en_reg;        
//    `ANAC_STIMU_INT_DIG_EN                : reg_rd_data  <= ana_stimu_ch_intr_dig_reg;       
//    `ANAC_STIMU_INT_POL_EN                : reg_rd_data  <= ana_stimu_ch_intr_pol_reg;       
//    `ANA_INT_STIMU_STS                    : reg_rd_data  <= ana_stimu_ch_intr_sts;   
//    `ANA_INT_COMP_STS                     : reg_rd_data  <= ana_comp_ch_intr_sts;    
      `ANA_INT_LVD_STS                      : reg_rd_data  <= ana_lvd_intr_pin;    

 
//    `COUNTER_CNT_DBG_SEL           :   reg_rd_data <= {4'b0,counter_cnt_dbg_sel[3:0]}; 
//    `COUNTER_CNT_DBG_0  : 	reg_rd_data <= lead_off_Counter_cnt_dac0_final_dbg[counter_cnt_dbg_sel][7:0]; 
//    `COUNTER_CNT_DBG_1  :  	reg_rd_data <= lead_off_Counter_cnt_dac0_final_dbg[counter_cnt_dbg_sel][15:8];
//    `COUNTER_CNT_DBG_2  :  	reg_rd_data <= lead_off_Counter_cnt_dac0_final_dbg[counter_cnt_dbg_sel][23:16];
//    `COUNTER_CNT_DBG_3  :  	reg_rd_data <= lead_off_Counter_cnt_dac0_final_dbg[counter_cnt_dbg_sel][31:24];

//    `LEAD_OFF_COUNTER_CNT   :  reg_rd_data  <= lead_off_Counter_cnt_dac0_dbg[counter_cnt_dbg_sel] 	; 

          
//    `ANA_INT_SIM_CL             :  reg_rd_data <= {6'b0,ana_stimu_ch2_intr_sts_sync,ana_stimu_ch1_intr_sts_sync};   
//    `ANA_INT_CH1_INT_NUMBER     :  reg_rd_data <= ana_stimu_int1_num;   
//    `ANA_INT_CH2_INT_NUMBER     :  reg_rd_data <= ana_stimu_int2_num;   

      `WAVEGEN_GLOBAL_REG         : reg_rd_data  <=  {3'b0,wavegen_burst_slct,stimu_en,drive_slct_03_47,drivea_global_en }; // (read/write register)
      `WAVEGEN_GLOBAL_REG01       : reg_rd_data  <= wavegen_reg_acc_0_7;
      `WAVEGEN_GLOBAL_REG02       : reg_rd_data  <= wavegen_reg_acc_8_15;
      `ATM_HC_SEL                 : reg_rd_data  <= {6'b0, atm_hc_sel_reg};

      `GENERAL_INTERUPT_CTRL_REG      : reg_rd_data  <= {5'b0, int_ctrl_reg};    
      //`GENERAL_INTERUPT_STATUS_REG01  : reg_rd_data  <= {tsc_intr_sts,2'b0,lead_off_result1,lead_off_result,1'b0,eeg_int_sts,ana_lvd_intr_pin};    
      `GENERAL_INTERUPT_STATUS_REG01  : reg_rd_data  <= {tsc_intr_sts,5'b0,eeg_int_sts,ana_lvd_intr_pin};    
      `GENERAL_INTERUPT_STATUS_REG02  : reg_rd_data  <= {spi_wg.i_wg_driver_int_sts[3],spi_wg.i_wg_driver_int_sts[2],spi_wg.i_wg_driver_int_sts[1],spi_wg.i_wg_driver_int_sts[0]};   
      `GENERAL_INTERUPT_STATUS_REG03  : reg_rd_data  <= {spi_wg.i_wg_driver_int_sts[7],spi_wg.i_wg_driver_int_sts[6],spi_wg.i_wg_driver_int_sts[5],spi_wg.i_wg_driver_int_sts[4]};   
      `GENERAL_INTERUPT_STATUS_REG04  : reg_rd_data  <= {spi_wg.i_wg_driver_int_sts[11],spi_wg.i_wg_driver_int_sts[10],spi_wg.i_wg_driver_int_sts[9],spi_wg.i_wg_driver_int_sts[8]};   
      `GENERAL_INTERUPT_STATUS_REG05  : reg_rd_data  <= {spi_wg.i_wg_driver_int_sts[15],spi_wg.i_wg_driver_int_sts[14],spi_wg.i_wg_driver_int_sts[13],spi_wg.i_wg_driver_int_sts[12]};   
      `GENERAL_INTERUPT_STATUS_REG06  : reg_rd_data  <= spi_nirs_if.NIRS_INT; 
//new for stim
      `GENERAL_INTERUPT_STATUS_REG07  : reg_rd_data  <= stim_mon_leadoff_int_sts[7:0]; 
      `GENERAL_INTERUPT_STATUS_REG08  : reg_rd_data  <= stim_mon_leadoff_int_sts[15:8]; 
      `GENERAL_INTERUPT_STATUS_REG09  : reg_rd_data  <= stim_mon_short_int_sts[7:0]; 
      `GENERAL_INTERUPT_STATUS_REG0A  : reg_rd_data  <= stim_mon_short_int_sts[15:8]; 
      `GENERAL_INTERUPT_STATUS_REG0B  : reg_rd_data  <= {5'b0,stim_mon_cycle_int_sts,stim_mon_int_sts,stim_mon_delta_int_sts}; 

//    `GENERAL_INTERUPT_STATUS_REG04  : reg_rd_data  <= lead_off_result;   

//    `FILTER_SEQ_CTRL                :  reg_rd_data  <= {5'b0,filter_seq};               
      `FILTER_HPF_BP_L                :  reg_rd_data  <= hpf_filter_bypass[7:0];  
      `FILTER_HPF_BP_H                :  reg_rd_data  <= hpf_filter_bypass[15:8];  
      `FILTER_LPF_BP_L                :  reg_rd_data  <= lpf_filter_bypass[7:0];   
      `FILTER_LPF_BP_H                :  reg_rd_data  <= lpf_filter_bypass[15:8];  
      `FILTER_NOF_BP_L                :  reg_rd_data  <= notch_filter_bypass[7:0]; 
      `FILTER_NOF_BP_H                :  reg_rd_data  <= notch_filter_bypass[15:8];
      `FILTER_INT_CTRL                :  reg_rd_data  <= {6'b0,eeg_int_en}; 
      `FILTER_INT_STS                 :  reg_rd_data  <= {7'b0,eeg_int_sts}; 

      `FILTER_NOTCH_DATA_GONE_L       :  reg_rd_data  <= cic_data_ignore_tar[7:0]; 
      `FILTER_NOTCH_DATA_GONE_H       :  reg_rd_data  <= cic_data_ignore_tar[15:8]; 
      `FILTER_COEFF_ADDR              :  reg_rd_data  <= coeff_addr;
      `FILTER_COEFF_DATA1             :  reg_rd_data  <= coeff_data[coeff_addr][7:0]; 
      `FILTER_COEFF_DATA2             :  reg_rd_data  <= coeff_data[coeff_addr][15:8]; 
      `FILTER_COEFF_DATA3             :  reg_rd_data  <= coeff_data[coeff_addr][23:16]; 
    //`FILTER_COEFF_DATA3             :  reg_rd_data  <= (coeff_addr < 8'd16)? {6'b0,coeff_data[coeff_addr][17:16]} : {4'b0,coeff_data[coeff_addr][19:16]}; 

      `FILTER_DLY_TGT_0               :  reg_rd_data  <= filter_dly_tgt[7:0] ;     
      `FILTER_DLY_TGT_1               :  reg_rd_data  <= filter_dly_tgt[15:8];  
      `FILTER_DLY_TGT_2               :  reg_rd_data  <= filter_dly_tgt[23:16];
      `FILTER_SYNC_CTRL               :  reg_rd_data  <= {7'b0,stim_eeg_sync_en};
      default                         :  reg_rd_data  <= 8'b0;
     endcase      
   end
   else
      reg_rd_data <= reg_rd_data;  //or 8'b0 =>rd_data=0 when not reading
 end

//////////////wave gen Read/////////////////
reg [7:0] wavegen_rd_data;

always@(*) begin
  case({drive_slct_03_47,i_addr[ADDR_WIDTH-1:6]})         
    4'b0000 : wavegen_rd_data = o_wg_driver_rd_data[0];
    4'b0001 : wavegen_rd_data = o_wg_driver_rd_data[1];
    4'b0010 : wavegen_rd_data = o_wg_driver_rd_data[2];
    4'b0011 : wavegen_rd_data = o_wg_driver_rd_data[3];
    4'b0100 : wavegen_rd_data = o_wg_driver_rd_data[4];
    4'b0101 : wavegen_rd_data = o_wg_driver_rd_data[5];
    4'b0110 : wavegen_rd_data = o_wg_driver_rd_data[6];
    4'b0111 : wavegen_rd_data = o_wg_driver_rd_data[7];
    4'b1000 : wavegen_rd_data = o_wg_driver_rd_data[8];
    4'b1001 : wavegen_rd_data = o_wg_driver_rd_data[9];
    4'b1010 : wavegen_rd_data = o_wg_driver_rd_data[10];
    4'b1011 : wavegen_rd_data = o_wg_driver_rd_data[11];
    4'b1100 : wavegen_rd_data = o_wg_driver_rd_data[12];
    4'b1101 : wavegen_rd_data = o_wg_driver_rd_data[13];
    4'b1110 : wavegen_rd_data = o_wg_driver_rd_data[14];
    4'b1111 : wavegen_rd_data = o_wg_driver_rd_data[15];
    default: wavegen_rd_data = 8'h00;
  endcase
end

assign o_rd_data = wavegen_cmd_reg ? wavegen_rd_data : (nirs_cmd_reg ? nirs_rd_data : reg_rd_data);

// Analog Inputs
assign  A2D_ANA_GEN_REG_0   = spi_ana_if.A2D_ANA_GEN_REG[0];
assign  A2D_ANA_GEN_REG_1   = spi_ana_if.A2D_ANA_GEN_REG[1];
assign  A2D_ANA_GEN_REG_2   = spi_ana_if.A2D_ANA_GEN_REG[2];
assign  A2D_ANA_GEN_REG_3   = spi_ana_if.A2D_ANA_GEN_REG[3];
assign  A2D_ANA_GEN_REG_4   = spi_ana_if.A2D_ANA_GEN_REG[4];
assign  A2D_ANA_GEN_REG_5   = spi_ana_if.A2D_ANA_GEN_REG[5]; 

// Analog Output's
assign spi_pinmux_if.ATM_HC_SEL         = atm_hc_sel_reg[0];
assign spi_pinmux_if.ANA_BIST_HC_SEL    = atm_hc_sel_reg[1];
assign spi_pinmux_if.INT_LEVEL_SEL      = int_active_level;
//assign spi_ana_if.ATM_HC_SEL            = atm_hc_sel_reg[0];

//My add
assign spi_pinmux_if.ANA_ENABLE_REG    = ana_enable_reg;
assign spi_ana_if.D2A_ANA_GEN_REG      = ana_gen_reg;


endmodule
