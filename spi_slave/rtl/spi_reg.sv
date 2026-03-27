//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//
// Module Name : spi_reg
// Description : register block contains config and status registers 
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author
//------------------------------------------------------------------------------
// 0.1          8/09/2022  Jayanthi 
// Initial Rev
//------------------------------------------------------------------------------

//`include "spi_defines_default_ana_trim.v"

//analog register define
`define DEFINE_DEFAULT_ANA_ENABLE_REG_0		8'h02 
`define DEFINE_DEFAULT_ANA_ENABLE_REG_1		8'h00 
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

//system ctrl
`define  SYSTEM_CTRL_BASE_ADDR          8'h01
`define  PMU_REG0		        `SYSTEM_CTRL_BASE_ADDR+8'h00//01
`define  CLK_CTRL_REG                   `SYSTEM_CTRL_BASE_ADDR+8'h01//02
`define  WAVEGEN_GLOBAL_REG             `SYSTEM_CTRL_BASE_ADDR+8'h02//03
`define  ANAC_CTRL                      `SYSTEM_CTRL_BASE_ADDR+8'h03//04
`define  PMU_REG1		        `SYSTEM_CTRL_BASE_ADDR+8'h04//05
`define  O_CLK_SEL		        `SYSTEM_CTRL_BASE_ADDR+8'h05//06
 //spare reg `SYSTEM_CTRL_BASE_ADDR + 8'h06~`SYSTEM_CTRL_BASE_ADDR + 8'h08//07~09

//OTP Registers
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
`define  OTP_UNLOCK                     `OTP_BASE_ADDR+8'h0B//15
`define  OTP_DATA                       `OTP_BASE_ADDR+8'h0C//16  
`define  OTP_ADDR                       `OTP_BASE_ADDR+8'h0D//17   
`define  OTP_MEM_DATA                   `OTP_BASE_ADDR+8'h0E//18 
`define  OTP_TRIMDATA9                  `OTP_BASE_ADDR+8'h0F//19 
`define  OTP_WAVEGEN_NUMBER             `OTP_BASE_ADDR+8'h10//1a 

//spare reg `OTP_BASE_ADDR + 8'h10~`OTP_BASE_ADDR + 8'h15//1a~1F

//gpio
`define  GPIO_BASE_ADDR                 8'h20
`define  GPIO_PU_CTRL                   `GPIO_BASE_ADDR+8'h00//20
`define  GPIO_PD_CTRL                   `GPIO_BASE_ADDR+8'h01//21
`define  GPIO_SR_PDRV0_1_CTRL           `GPIO_BASE_ADDR+8'h02//22
 //spare reg `GPIO_BASE_ADDR + 8'h03~`GPIO_BASE_ADDR + 8'h05//23~25

//lead_off
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

//analog register define
`define  ANA_REG_BASE_ADDR               8'h40
`define  ANA_ENABLE_REG_0		 `ANA_REG_BASE_ADDR+8'h00//40
`define  ANA_ENABLE_REG_1		 `ANA_REG_BASE_ADDR+8'h01//41
`define  ANA_ENABLE_REG_2         	 `ANA_REG_BASE_ADDR+8'h02//42
`define  ANA_ENABLE_REG_3         	 `ANA_REG_BASE_ADDR+8'h03//43
`define  ANA_GEN_REG_1			 `ANA_REG_BASE_ADDR+8'h04//44
`define  ANA_GEN_REG_2			 `ANA_REG_BASE_ADDR+8'h05//45
`define  ANA_GEN_REG_3			 `ANA_REG_BASE_ADDR+8'h06//46
`define  ANA_GEN_REG_4			 `ANA_REG_BASE_ADDR+8'h07//47
`define  ANA_GEN_REG_5			 `ANA_REG_BASE_ADDR+8'h08//48
`define  ANA_GEN_REG_6			 `ANA_REG_BASE_ADDR+8'h09//49
`define  ANA_GEN_REG_7			 `ANA_REG_BASE_ADDR+8'h0A//4A
`define  ANA_GEN_REG_8			 `ANA_REG_BASE_ADDR+8'h0B//4B
`define  ANA_GEN_REG_9			 `ANA_REG_BASE_ADDR+8'h0C//4C
`define  A2D_ANA_GEN_REG_0               `ANA_REG_BASE_ADDR+8'h0D//4D
`define  A2D_SPARE_RO_REG_0              `ANA_REG_BASE_ADDR+8'H0E//4E
 //spare reg `ANA_REG_BASE_ADDR + 8'h0F//4F

//anac
`define  ANA_SHORT_BASE_ADDR             8'h50
`define  ANAC_LVD_INT_EN                 `ANA_SHORT_BASE_ADDR+8'h00//50
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

//tsc
`define TSC_BASE_ADDR                   8'h6B
`define TSC_EN_REG_SEL		        `TSC_BASE_ADDR+8'h00//6b
`define TSC_CTRL			`TSC_BASE_ADDR+8'h01//6c
`define SMP_DURATION			`TSC_BASE_ADDR+8'h02//6d
`define STABLE_DURATION_L		`TSC_BASE_ADDR+8'h03//6e
`define STABLE_DURATION_H		`TSC_BASE_ADDR+8'h04//6f
`define TSC_VDAC8B_DIN_CH1              `TSC_BASE_ADDR+8'h05//70
`define TSC_INT_CRTL      		`TSC_BASE_ADDR+8'h06//71
`define TSC_INT_STATUS   		`TSC_BASE_ADDR+8'h07//72
`define VDAC_NOR_L			`TSC_BASE_ADDR+8'h08//73
`define SMP_STS			 	`TSC_BASE_ADDR+8'h09//74
 //spare reg `TSC_BASE_ADDR + 8'h0a~`TSC_BASE_ADDR+8'h0c//75~77

//int read
`define  INT_REG_BASE_ADDR               8'h78
`define  GENERAL_INTERUPT_CTRL_REG       `INT_REG_BASE_ADDR+8'h00//78
`define  GENERAL_INTERUPT_STATUS_REG01   `INT_REG_BASE_ADDR+8'h01//79
`define  GENERAL_INTERUPT_STATUS_REG02   `INT_REG_BASE_ADDR+8'h02//7A
`define  GENERAL_INTERUPT_STATUS_REG03   `INT_REG_BASE_ADDR+8'h03//7B
`define  GENERAL_INTERUPT_STATUS_REG04   `INT_REG_BASE_ADDR+8'h04//7C
`define  GENERAL_INTERUPT_STATUS_REG05   `INT_REG_BASE_ADDR+8'h05//7D
 //spare reg `TSC_REG_BASE_ADDR + 8'h04~`TSC_REG_BASE_ADDR+8'h05//7C~7D

//pinmux
`define  PINMUX_REG_BASE_ADDR            8'h7E
`define  ATM_HC_SEL                      `PINMUX_REG_BASE_ADDR+8'h00
//spare reg `PINMUX_REG_BASE_ADDR + 8'h01//7F

//debug
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

`define NIRS_REG_BASE_ADDR_0            8'hC0

`define NIRS_CTRL_ADDR                  `NIRS_REG_BASE_ADDR_0 + 8'h00 
`define NIRS_CTRL_0                     `NIRS_REG_BASE_ADDR_0 + 8'h01
`define NIRS_CTRL_1                     `NIRS_REG_BASE_ADDR_0 + 8'h02
`define NIRS_CTRL_2                     `NIRS_REG_BASE_ADDR_0 + 8'h03
`define NIRS_CTRL_3                     `NIRS_REG_BASE_ADDR_0 + 8'h04
`define NIRS_CTRL_4                     `NIRS_REG_BASE_ADDR_0 + 8'h05  
`define NIRS_CTRL_5                     `NIRS_REG_BASE_ADDR_0 + 8'h06
`define NIRS_CTRL_6                     `NIRS_REG_BASE_ADDR_0 + 8'h07
`define NIRS_CTRL_7                     `NIRS_REG_BASE_ADDR_0 + 8'h08
`define NIRS_CTRL_8                     `NIRS_REG_BASE_ADDR_0 + 8'h09
`define NIRS_CTRL_9                     `NIRS_REG_BASE_ADDR_0 + 8'h0A
`define NIRS_CTRL_10                    `NIRS_REG_BASE_ADDR_0 + 8'h0B
//`define NIRS_CTRL_11                    `NIRS_REG_BASE_ADDR_0 + 8'h0C
`define NIRS_CTRL_CLK                   `NIRS_REG_BASE_ADDR_0 + 8'h0D
`define NIRS_CTRL_EN                    `NIRS_REG_BASE_ADDR_0 + 8'h0E
`define NIRS_CTRL_MEAS                  `NIRS_REG_BASE_ADDR_0 + 8'h0F

`define NIRS_REG_BASE_ADDR_1            8'hD0
`define NIRS_DEBUG_0                    `NIRS_REG_BASE_ADDR_1 + 8'h00
`define NIRS_DEBUG_1                    `NIRS_REG_BASE_ADDR_1 + 8'h01
`define NIRS_DEBUG_2                    `NIRS_REG_BASE_ADDR_1 + 8'h02
`define NIRS_DEBUG_3                    `NIRS_REG_BASE_ADDR_1 + 8'h03
`define NIRS_DEBUG_4                    `NIRS_REG_BASE_ADDR_1 + 8'h04
`define NIRS_DEBUG_5                    `NIRS_REG_BASE_ADDR_1 + 8'h05
//`define NIRS_DEBUG_6                    `NIRS_REG_BASE_ADDR_1 + 8'h06
`define NIRS_INT_STATUS                 `NIRS_REG_BASE_ADDR_1 + 8'h07

`define NIRS_DOUT_0                     `NIRS_REG_BASE_ADDR_1 + 8'h08
`define NIRS_DOUT_1                     `NIRS_REG_BASE_ADDR_1 + 8'h09
`define NIRS_DOUT_2                     `NIRS_REG_BASE_ADDR_1 + 8'h0A
`define NIRS_DOUT_3                     `NIRS_REG_BASE_ADDR_1 + 8'h0B
`define NIRS_DOUT_4                     `NIRS_REG_BASE_ADDR_1 + 8'h0C
`define NIRS_DOUT_5                     `NIRS_REG_BASE_ADDR_1 + 8'h0D
`define NIRS_DOUT_6                     `NIRS_REG_BASE_ADDR_1 + 8'h0E
`define NIRS_DOUT_7                     `NIRS_REG_BASE_ADDR_1 + 8'h0F 

`define NIRS_REG_BASE_ADDR_2             8'hE0
`define NIRS_DOUT_8                     `NIRS_REG_BASE_ADDR_2 + 8'h00
`define NIRS_DOUT_9                     `NIRS_REG_BASE_ADDR_2 + 8'h01
`define NIRS_DOUT_10                    `NIRS_REG_BASE_ADDR_2 + 8'h02
`define NIRS_DOUT_11                    `NIRS_REG_BASE_ADDR_2 + 8'h03
`define NIRS_DOUT_12                    `NIRS_REG_BASE_ADDR_2 + 8'h04
`define NIRS_DOUT_13                    `NIRS_REG_BASE_ADDR_2 + 8'h05
`define NIRS_DOUT_14                    `NIRS_REG_BASE_ADDR_2 + 8'h06
`define NIRS_DOUT_15                    `NIRS_REG_BASE_ADDR_2 + 8'h07
`define NIRS_DOUT_16                    `NIRS_REG_BASE_ADDR_2 + 8'h08
`define NIRS_DOUT_17                    `NIRS_REG_BASE_ADDR_2 + 8'h09
`define NIRS_DOUT_18                    `NIRS_REG_BASE_ADDR_2 + 8'h0A


`timescale 1ns/1ps
module spi_reg #(
  parameter ADDR_WIDTH =8,
  parameter DATA_WIDTH =8,
  parameter HLF_WV_NO_PTS = 6, 
  parameter OUT_NO_BITS = 12,
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
  input		         atpg_en,
  input [ADDR_WIDTH-1:0] i_addr,
  input                  i_wr,
  input                  i_rd,
  input                  wavegen_cmd_reg,
  input                  i_wavegen_wr,
  input                  i_wavegen_rd,
  input [DATA_WIDTH-1:0] i_wr_data  ,
//input                  i_addr_vld_for_int_clr,
//input                  i_burst_cmd,
//input [ADDR_WIDTH-1:0] i_pre_addr,
        
  // outputs
  spi_ana_if.spi          spi_ana_if,
  spi_pinmux_if.spi       spi_pinmux_if,
  spi_nirs_if.spi         spi_nirs_if,

  output [DATA_WIDTH-1:0] o_rd_data, 
        
  // system outputs
  // inputs from other blocks
       
  output  reg  	          o_clk_sel,


//imeas       
  input   wire [31:0]     imeas_chdata[15:0],

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
  output  wire  	  lead_off_rst,
  output  wire  	  lead_off_en,

  input  wire [NO_OF_WAVEGEN-1:0]  	A2D_COMP0_7,   
 
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

  output reg  [15:0]      notch_filter_bypass,
  output reg  [15:0]      lpf_filter_bypass,
  output reg  [15:0]      hpf_filter_bypass,
//  output reg  [2:0]     filter_seq,
  output reg  [1:0]       eeg_int_en,
  output reg              eeg_int_clr,
  input  wire             eeg_int_sts,
  output reg  [15:0]      cic_data_ignore_tar,

  output wire [17:0]      lpf_coeff_data_o[31:0],
  output wire [19:0]      notch_coeff_data_o[41:0],
  output wire [23:0]      hpf_coeff_data_o,
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
 wire [7:0]     A2D_SPARE_RO_REG_0;

 reg [7:0]      ana_gen_reg_0;
 reg [7:0] 	ana_enable_reg_0;
 reg [7:0] 	ana_enable_reg_1;
 reg [7:0] 	ana_enable_reg_2;
 reg [7:0] 	ana_enable_reg_3;
 //reg [7:0] 	ana_enable_reg_4;
// reg [7:0] 	ana_enable_reg_5;
 reg [7:0] 	ana_gen_reg_1;
 reg [7:0] 	ana_gen_reg_2; 
 reg [7:0] 	ana_gen_reg_3;
 reg [7:0] 	ana_gen_reg_4;
 reg [7:0] 	ana_gen_reg_5;
 reg [7:0] 	ana_gen_reg_6; 
 reg [7:0] 	ana_gen_reg_7;
 reg [7:0] 	ana_gen_reg_8;
 reg [7:0] 	ana_gen_reg_9;
 reg [7:0] 	ana_gen_reg_A; 
 reg [7:0] 	ana_gen_reg_B;
 reg [7:0] 	ana_gen_reg_C;
 reg [7:0] 	ana_gen_reg_D;
 reg [7:0] 	ana_gen_reg_E; 
 reg [7:0] 	ana_gen_reg_F;
 reg [7:0] 	ana_gen_reg_10;
 reg [7:0] 	ana_gen_reg_11; 
 reg [7:0] 	ana_gen_reg_12;


 reg            drivea_global_en;
 reg            stimu_en;
 reg [1:0]      drive_slct_03_47;
 
 reg [1:0]      atm_hc_sel_reg;

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

reg[31:0] imeas_chdata_wire;

always @(*) begin
  case(imeas_data_sel)
    4'h0 : imeas_chdata_wire = imeas_chdata[4'd0];
    4'h1 : imeas_chdata_wire = imeas_chdata[4'd1];
    4'h2 : imeas_chdata_wire = imeas_chdata[4'd2];
    4'h3 : imeas_chdata_wire = imeas_chdata[4'd3];
    4'h4 : imeas_chdata_wire = imeas_chdata[4'd4];
    4'h5 : imeas_chdata_wire = imeas_chdata[4'd5];
    4'h6 : imeas_chdata_wire = imeas_chdata[4'd6];
    4'h7 : imeas_chdata_wire = imeas_chdata[4'd7];
    4'h8 : imeas_chdata_wire = imeas_chdata[4'd8];
    4'h9 : imeas_chdata_wire = imeas_chdata[4'd9];
    4'hA : imeas_chdata_wire = imeas_chdata[4'd10];
    4'hB : imeas_chdata_wire = imeas_chdata[4'd11];
    4'hC : imeas_chdata_wire = imeas_chdata[4'd12];
    4'hD : imeas_chdata_wire = imeas_chdata[4'd13];
    4'hE : imeas_chdata_wire = imeas_chdata[4'd14];
    4'hF : imeas_chdata_wire = imeas_chdata[4'd15];
    default: imeas_chdata_wire = imeas_chdata[4'd0];
  endcase
end

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
reg[3:0]  anac_ctrl;
assign anac_clock_en      = anac_ctrl[0];
assign anac_reset         = anac_ctrl[1];
assign temp_sar_reset     = anac_ctrl[2];
assign temp_sar_clock_dis = anac_ctrl[3];

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

always@(posedge i_clk or negedge i_rst_n) begin
  if(!i_rst_n)begin
    // pmu ctrl
    pmu_reg0             <= 8'h01;  
    pmu_reg1             <= 2'b10;  
    o_clk_sel            <= 1'h0;  
    //bps imeas
    imeas_en_dis_chn_l   <= 8'b0;
    imeas_en_dis_chn_h   <= 8'b0;
    imeas_reg_0          <= 8'h18;
    imeas_reg_1          <= 8'h47;
    imeas_reg_2          <= 8'h0;
    imeas_ctrl           <= 8'h0;
    stable_time_0        <= 8'h10;
    stable_time_1        <= 8'h0;
    // clk_ctrl
    clk_ctrl_reg         <= 8'h30; 
    anac_ctrl            <= 4'b0;
    tsc_ctrl             <= 4'b0;
    sample_duration      <= 8'h10;
    stable_duration      <= 12'h1ff;
    en_reg_sel           <= 8'b0;
    tsc_vdac8b_din_ch1   <= 8'hFF;
    // analog_regsiters
    ana_enable_reg_0     <=`DEFINE_DEFAULT_ANA_ENABLE_REG_0 ; //8'h00;
    ana_enable_reg_1     <=`DEFINE_DEFAULT_ANA_ENABLE_REG_1;  //8'h00;
    ana_enable_reg_2     <=`DEFINE_DEFAULT_ANA_ENABLE_REG_2;  //8'h00;
    ana_enable_reg_3     <=`DEFINE_DEFAULT_ANA_ENABLE_REG_3;  //8'h00;
    ana_gen_reg_1        <=`DEFINE_DEFAULT_ANA_GEN_REG_1;     //8'h00;
    ana_gen_reg_2        <=`DEFINE_DEFAULT_ANA_GEN_REG_2;     //8'h00;
    ana_gen_reg_3        <=`DEFINE_DEFAULT_ANA_GEN_REG_3;     //8'h00;
    ana_gen_reg_4        <=`DEFINE_DEFAULT_ANA_GEN_REG_4;     //8'h00;
    ana_gen_reg_5        <=`DEFINE_DEFAULT_ANA_GEN_REG_5;     //8'h00;
    ana_gen_reg_6        <=`DEFINE_DEFAULT_ANA_GEN_REG_6;     //8'h00;
    ana_gen_reg_7        <=`DEFINE_DEFAULT_ANA_GEN_REG_7;     //8'h00;  
    ana_gen_reg_8        <=`DEFINE_DEFAULT_ANA_GEN_REG_8;    //8'h00;
    ana_gen_reg_9        <=`DEFINE_DEFAULT_ANA_GEN_REG_9;    //8'h00;
    drivea_global_en     <= 1'b0;
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
      `ANAC_CTRL                 : anac_ctrl             <=  i_wr ?  i_wr_data[3:0]: anac_ctrl;
      `TSC_EN_REG_SEL            : en_reg_sel            <=  i_wr ?  i_wr_data[7:0]: en_reg_sel;
      `TSC_CTRL                  : tsc_ctrl              <=  i_wr ?  i_wr_data[3:0]: tsc_ctrl;
      `TSC_VDAC8B_DIN_CH1        : tsc_vdac8b_din_ch1    <=  i_wr ?  i_wr_data[7:0]: tsc_vdac8b_din_ch1;
      `TSC_INT_CRTL              : tsc_int_crtl_reg      <=  i_wr ?  i_wr_data[1:0]: tsc_int_crtl_reg;
      `TSC_INT_STATUS            : tsc_intr_sts_clr      <= (i_wr & !int_clear_type)? i_wr_data[0]: (i_rd & int_clear_type)? {tsc_intr_sts & i_rd} : 1'b0;
      `SMP_DURATION	         : sample_duration       <=  i_wr ?  i_wr_data[7:0]: sample_duration;		
      `STABLE_DURATION_L	 : stable_duration[7:0]  <=  i_wr ?  i_wr_data[7:0]: stable_duration[7:0];		
      `STABLE_DURATION_H	 : stable_duration[11:8] <=  i_wr ?  i_wr_data[3:0]: stable_duration[11:8];		
      // ANALOG Registers
      `ANA_ENABLE_REG_0		 : ana_enable_reg_0	 <= i_wr ? i_wr_data[7:0] : ana_enable_reg_0;
      `ANA_ENABLE_REG_1		 : ana_enable_reg_1	 <= i_wr ? i_wr_data[7:0] : ana_enable_reg_1;
      `ANA_ENABLE_REG_2		 : ana_enable_reg_2	 <= i_wr ? i_wr_data[7:0] : ana_enable_reg_2;
      `ANA_ENABLE_REG_3		 : ana_enable_reg_3	 <= i_wr ? i_wr_data[7:0] : ana_enable_reg_3;
      `ANA_GEN_REG_1		: ana_gen_reg_1		 <= i_wr ? i_wr_data[7:0] : ana_gen_reg_1;
      `ANA_GEN_REG_2		: ana_gen_reg_2		 <= i_wr ? i_wr_data[7:0] : ana_gen_reg_2;
      `ANA_GEN_REG_3		: ana_gen_reg_3		 <= i_wr ? i_wr_data[7:0] : ana_gen_reg_3;
      `ANA_GEN_REG_4		: ana_gen_reg_4		 <= i_wr ? i_wr_data[7:0] : ana_gen_reg_4;
      `ANA_GEN_REG_5		: ana_gen_reg_5		 <= i_wr ? i_wr_data[7:0] : ana_gen_reg_5;
      `ANA_GEN_REG_6		: ana_gen_reg_6		 <= i_wr ? i_wr_data[7:0] : ana_gen_reg_6;
      `ANA_GEN_REG_7		: ana_gen_reg_7		 <= i_wr ? i_wr_data[7:0] : ana_gen_reg_7;
      `ANA_GEN_REG_8		: ana_gen_reg_8		 <= i_wr ? i_wr_data[7:0] : ana_gen_reg_8;
      `ANA_GEN_REG_9		: ana_gen_reg_9		 <= i_wr ? i_wr_data[7:0] : ana_gen_reg_9;
      `GENERAL_INTERUPT_STATUS_REG01 : tsc_intr_sts_clr <= (i_rd & int_clear_type)? tsc_intr_sts & i_rd : 1'b0; 
//    `COUNTER_CNT_DBG_SEL      : counter_cnt_dbg_sel[3:0]  <= i_wr? i_wr_data[3:0]       :         counter_cnt_dbg_sel[3:0];
//    `ANA_INT_CH1_INT_NUMBER   : ana_stimu_int1_num        <= i_wr? i_wr_data       :        ana_stimu_int1_num; 
//    `ANA_INT_CH2_INT_NUMBER   : ana_stimu_int2_num        <= i_wr? i_wr_data       :        ana_stimu_int2_num; 
      `WAVEGEN_GLOBAL_REG      :  {stimu_en,drive_slct_03_47,drivea_global_en}         <= i_wr ? i_wr_data[3:0]   : {stimu_en,drive_slct_03_47,drivea_global_en};
      `ATM_HC_SEL              :  atm_hc_sel_reg            <= i_wr ? i_wr_data[1:0] : atm_hc_sel_reg;
      //  default :  begin  
      //            end
    endcase  
  end
end

//to anac
assign ana_lvd_sts	           = A2D_ANA_GEN_REG_0[0];      

// pmu register output 
assign {o_otp_dpstb_en, o_hresetreq, o_sleepdeep, o_pmuenable} = pmu_reg0[3:0];
assign o_wave_gen_dis	      = pmu_reg0[4];
assign o_wave_gen_rst         = pmu_reg0[5];
assign lead_off_dis	      = pmu_reg0[6];
assign lead_off_rst           = pmu_reg0[7];

assign lead_off_en            = ~lead_off_dis;

assign otp_rst_reg           = pmu_reg1[0];
assign dig_rst_reg           = pmu_reg1[1];

//clk_ctrl register output
assign  o_pclk_div              = clk_ctrl_reg[2:0];
//assign  o_fclk_dynen            = 1'b0;
assign  o_int_clk_out           = clk_ctrl_reg[3];  
assign iclk_div                 = clk_ctrl_reg[7:4];


//////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////GPIO io pad control register  write/////////////////////////////////////////////// 
/////////////////////////////////////////////////////////////////////////////////////////////////////////
reg [7:0]   pu_ctrl;
reg [7:0]   pd_ctrl;
reg [2:0]   sr_pdrv0_1_ctrl;


//reg [5:0] gpio_0_ctrl,gpio_1_ctrl,gpio_2_ctrl,gpio_3_ctrl,gpio_4_ctrl; 
//reg [5:0] gpio_5_ctrl,gpio_6_ctrl,gpio_7_ctrl,gpio_8_ctrl,gpio_9_ctrl;
//reg [5:0] gpio_10_ctrl,gpio_11_ctrl,gpio_12_ctrl,gpio_13_ctrl,gpio_14_ctrl;
//reg [5:0] gpio_15_ctrl;//,gpio_16_ctrl,gpio_17_ctrl,gpio_18_ctrl;

assign gpio_pu_ctrl           =  pu_ctrl;
assign gpio_pd_ctrl           =  pd_ctrl;
assign gpio_sr_pdrv0_1_ctrl   =  sr_pdrv0_1_ctrl;
//assign gpio_3_ctrl_all =  gpio_3_ctrl;
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

always@(posedge i_clk or negedge i_rst_n) begin
  if(!i_rst_n)begin
  //Tried reducing number of spi registers because in normal mode only GPIO0~GPIO7 has been used so only PU/PD required to be configured for each GPIO. CS configuration not required(as per Mohsen), PDRV0/PDRV1/SR common bit used for all 8 GPIO's
     pu_ctrl    		  <= 8'h00; 
     pd_ctrl    		  <= 8'h1F; 
     sr_pdrv0_1_ctrl  <= 3'b000; 	
  end
  else begin
    case (i_addr[ADDR_WIDTH-1:0])
     `GPIO_PU_CTRL         : pu_ctrl         <= i_wr ? i_wr_data[7:0] : pu_ctrl;	  
     `GPIO_PD_CTRL     	   : pd_ctrl         <= i_wr ? i_wr_data[7:0] : pd_ctrl;
     `GPIO_SR_PDRV0_1_CTRL : sr_pdrv0_1_ctrl <= i_wr ? i_wr_data[2:0] : sr_pdrv0_1_ctrl;   
    endcase
  end
end

reg [2:0] int_ctrl_reg;
always@(posedge i_clk or negedge i_rst_n) begin
  if(!i_rst_n)begin
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
always@(posedge i_clk or negedge i_rst_n) begin
  if(!i_rst_n)begin
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
//     `ANAC_SHORT_BLK_SLCT               : anac_short_blk_slct_reg                                 <= i_wr?                     i_wr_data[3:0]  : anac_short_blk_slct_reg;
//     `ANA_STIM_CH_TIMER_CNT_TH00        : ana_int_ch_timer_th_reg[anac_short_blk_slct_reg][7:0]   <= i_wr?                     i_wr_data       : ana_int_ch_timer_th_reg[anac_short_blk_slct_reg][7:0];
//     `ANA_STIM_CH_TIMER_CNT_TH01        : ana_int_ch_timer_th_reg[anac_short_blk_slct_reg][15:8]  <= i_wr?                     i_wr_data       : ana_int_ch_timer_th_reg[anac_short_blk_slct_reg][15:8];
//     `ANA_STIM_CH_TIMER_CNT_TH02        : ana_int_ch_timer_th_reg[anac_short_blk_slct_reg][23:16] <= i_wr?                     i_wr_data       : ana_int_ch_timer_th_reg[anac_short_blk_slct_reg][23:16];
//     `ANA_STIM_CH_TIMER_CNT_TH03        : ana_int_ch_timer_th_reg[anac_short_blk_slct_reg][31:24] <= i_wr?                     i_wr_data       : ana_int_ch_timer_th_reg[anac_short_blk_slct_reg][31:24];
//     `ANA_STIM_CH_COUNTER_CNT_TH00      : ana_int_ch_cnt_th_reg[anac_short_blk_slct_reg][7:0]     <= i_wr?                     i_wr_data       : ana_int_ch_cnt_th_reg[anac_short_blk_slct_reg][7:0];
//     `ANA_STIM_CH_COUNTER_CNT_TH01      : ana_int_ch_cnt_th_reg[anac_short_blk_slct_reg][15:8]    <= i_wr?                     i_wr_data       : ana_int_ch_cnt_th_reg[anac_short_blk_slct_reg][15:8];
//     `ANA_STIM_CH_COUNTER_CNT_TH02      : ana_int_ch_cnt_th_reg[anac_short_blk_slct_reg][23:16]   <= i_wr?                     i_wr_data       : ana_int_ch_cnt_th_reg[anac_short_blk_slct_reg][23:16];
//     `ANA_STIM_CH_COUNTER_CNT_TH03      : ana_int_ch_cnt_th_reg[anac_short_blk_slct_reg][31:24]   <= i_wr?                     i_wr_data       : ana_int_ch_cnt_th_reg[anac_short_blk_slct_reg][31:24];
//     `ANA_INT_SOTP_WAVEGEN              : ana_int_stop_wavegen_reg                                <= i_wr?                     i_wr_data       : ana_int_stop_wavegen_reg;
     `ANAC_LVD_INT_EN                   : ana_lvd_intr_en_reg                                     <= i_wr?                     i_wr_data[0]    : ana_lvd_intr_en_reg;
//     `ANAC_COMP_INT_EN                  : ana_comp_ch_intr_en_reg                                 <= i_wr?                     i_wr_data       : ana_comp_ch_intr_en_reg;
//     `ANAC_COMP_INT_TRANS_SEL           : ana_comp_ch_intr_trans_sel_reg                          <= i_wr?                     i_wr_data       : ana_comp_ch_intr_trans_sel_reg;
//     `ANAC_STIMU_INT_EN                 : ana_stimu_ch_intr_en_reg                                <= i_wr?                     i_wr_data       : ana_stimu_ch_intr_en_reg;
//     `ANAC_STIMU_INT_DIG_EN             : ana_stimu_ch_intr_dig_reg                               <= i_wr?                     i_wr_data       : ana_stimu_ch_intr_dig_reg;
//     `ANAC_STIMU_INT_POL_EN             : ana_stimu_ch_intr_pol_reg                               <= i_wr?                     i_wr_data       : ana_stimu_ch_intr_pol_reg;	  
//     `ANA_INT_STIMU_STS                 : ana_stimu_ch_intr_sts_clr_reg                           <= (i_wr & !int_clear_type)? i_wr_data       : (i_rd & int_clear_type)? ana_stimu_ch_intr_sts : 8'b0;
//     `ANA_INT_COMP_STS                  : ana_comp_ch_intr_sts_clr_reg                            <= (i_wr & !int_clear_type)? i_wr_data       : (i_rd & int_clear_type)? ana_comp_ch_intr_sts : 8'b0; 
//        
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
localparam LPF_COEFF    = 16;
localparam NOTCH_COEFF  = 19; 
localparam HPF_COEFF    = 1;

reg [7:0]  coeff_addr;
reg [23:0] coeff_data [LPF_COEFF+NOTCH_COEFF+HPF_COEFF-1:0];

localparam [23:0] coeff_data_def [0:LPF_COEFF+NOTCH_COEFF+HPF_COEFF-1] = '{
//lpf
24'b0000_0011_1111_1111_1111_1000,
24'b0000_0000_0000_0000_0111_1000,
24'b0000_0000_0000_0010_0000_0100,
24'b0000_0000_0000_0011_0100_0100,
24'b0000_0000_0000_0000_1011_0110,
24'b0000_0011_1111_1001_1001_0011,
24'b0000_0011_1111_0101_0110_1101,
24'b0000_0011_1111_1111_0001_1000,
24'b0000_0000_0001_0011_1000_1011,
24'b0000_0000_0001_1001_1110_1000,
24'b0000_0011_1111_1011_0001_0011,
24'b0000_0011_1100_1001_1001_0001,
24'b0000_0011_1100_0110_0101_0101,
24'b0000_0000_0010_0111_1010_1001,
24'b0000_0000_1101_0010_1000_1011,
24'b0000_0001_0101_1010_1000_1011,

//notch
24'b0000_0011_1111_1100_0000_0001,
24'b0000_1000_0110_0100_0011_1011,
24'b0000_1000_0111_0110_1110_1100,
24'b0000_0011_1111_0111_1110_0110,
24'b0000_1000_0110_0001_0100_0100,
24'b0000_0011_1111_1000_1010_1110,
24'b0000_0011_1111_0101_0010_1110,
24'b0000_1000_1000_0010_0010_0010,
24'b0000_0011_1110_1001_1010_1011,
24'b0000_1000_0110_1111_1101_0011,
24'b0000_0011_1110_1011_0110_1000,
24'b0000_0011_1111_0000_1000_1001,
24'b0000_1000_1000_0110_1111_0100,
24'b0000_0011_1110_0000_0110_1111,
24'b0000_1000_0111_1100_0111_0000,
24'b0000_0011_1110_0001_1101_0001,
24'b0000_0011_1110_1110_1110_0101,
24'b0000_1000_1000_0100_1100_0101,
24'b0000_0011_1101_1101_1100_1001,
//HPF
24'b0111_1111_1001_1001_0110_0001 //scale
};

//notch logic
assign notch_coeff_data_o[0]  = coeff_data[LPF_COEFF][19:0];
assign notch_coeff_data_o[1]  = 20'b0100_0000_0000_0000_0000;
assign notch_coeff_data_o[2]  = coeff_data[LPF_COEFF+1][19:0];
assign notch_coeff_data_o[3]  = 20'b0100_0000_0000_0000_0000;
assign notch_coeff_data_o[4]  = coeff_data[LPF_COEFF+2][19:0];
assign notch_coeff_data_o[5]  = coeff_data[LPF_COEFF+3][19:0];
assign notch_coeff_data_o[6]  = coeff_data[LPF_COEFF][19:0];
assign notch_coeff_data_o[7]  = 20'b0100_0000_0000_0000_0000;
assign notch_coeff_data_o[8]  = coeff_data[LPF_COEFF+1][19:0];
assign notch_coeff_data_o[9]  = 20'b0100_0000_0000_0000_0000;
assign notch_coeff_data_o[10] = coeff_data[LPF_COEFF+4][19:0];
assign notch_coeff_data_o[11] = coeff_data[LPF_COEFF+5][19:0];
assign notch_coeff_data_o[12]  = coeff_data[LPF_COEFF+6][19:0];
assign notch_coeff_data_o[13]  = 20'b0100_0000_0000_0000_0000;
assign notch_coeff_data_o[14]  = coeff_data[LPF_COEFF+1][19:0];
assign notch_coeff_data_o[15]  = 20'b0100_0000_0000_0000_0000;
assign notch_coeff_data_o[16]  = coeff_data[LPF_COEFF+7][19:0];
assign notch_coeff_data_o[17]  = coeff_data[LPF_COEFF+8][19:0];
assign notch_coeff_data_o[18]  = coeff_data[LPF_COEFF+6][19:0];
assign notch_coeff_data_o[19]  = 20'b0100_0000_0000_0000_0000;
assign notch_coeff_data_o[20]  = coeff_data[LPF_COEFF+1][19:0];
assign notch_coeff_data_o[21]  = 20'b0100_0000_0000_0000_0000;
assign notch_coeff_data_o[22] = coeff_data[LPF_COEFF+9][19:0];
assign notch_coeff_data_o[23] = coeff_data[LPF_COEFF+10][19:0];
assign notch_coeff_data_o[24]  = coeff_data[LPF_COEFF+11][19:0];
assign notch_coeff_data_o[25]  = 20'b0100_0000_0000_0000_0000;
assign notch_coeff_data_o[26]  = coeff_data[LPF_COEFF+1][19:0];
assign notch_coeff_data_o[27]  = 20'b0100_0000_0000_0000_0000;
assign notch_coeff_data_o[28]  = coeff_data[LPF_COEFF+12][19:0];
assign notch_coeff_data_o[29]  = coeff_data[LPF_COEFF+13][19:0];
assign notch_coeff_data_o[30]  = coeff_data[LPF_COEFF+11][19:0];
assign notch_coeff_data_o[31]  = 20'b0100_0000_0000_0000_0000;
assign notch_coeff_data_o[32]  = coeff_data[LPF_COEFF+1][19:0];
assign notch_coeff_data_o[33]  = 20'b0100_0000_0000_0000_0000;
assign notch_coeff_data_o[34] = coeff_data[LPF_COEFF+14][19:0];
assign notch_coeff_data_o[35] = coeff_data[LPF_COEFF+15][19:0];
assign notch_coeff_data_o[36]  = coeff_data[LPF_COEFF+16][19:0];
assign notch_coeff_data_o[37]  = 20'b0100_0000_0000_0000_0000;
assign notch_coeff_data_o[38]  = coeff_data[LPF_COEFF+1][19:0];
assign notch_coeff_data_o[39]  = 20'b0100_0000_0000_0000_0000;
assign notch_coeff_data_o[40] = coeff_data[LPF_COEFF+17][19:0];
assign notch_coeff_data_o[41] = coeff_data[LPF_COEFF+18][19:0];

//LPF LOGIC
genvar b;
generate
   for(b=0;b<LPF_COEFF;b++) begin : LPF_COEFFS
     assign lpf_coeff_data_o[b]           = coeff_data[b][17:0];
     assign lpf_coeff_data_o[LPF_COEFF+b] = coeff_data[LPF_COEFF-1-b][17:0];   
   end
endgenerate

// HPF
assign hpf_coeff_data_o = coeff_data[LPF_COEFF+NOTCH_COEFF+HPF_COEFF-1];

always@(posedge i_clk or negedge i_rst_n) begin : FILTER_SPI_REG
  if(!i_rst_n)begin
//    filter_seq          <= 3'h0;
    notch_filter_bypass <= 16'hFFFF;
    lpf_filter_bypass   <= 16'hFFFF;
    hpf_filter_bypass   <= 16'hFFFF;
    eeg_int_en          <= 2'b0;
    eeg_int_clr         <= 1'b0;
    cic_data_ignore_tar <= 16'h3a94;
    coeff_addr      <= 8'h00;
    for(int a=0;a<LPF_COEFF+NOTCH_COEFF+HPF_COEFF;a++)begin
    coeff_data[a]  <= coeff_data_def[a];
    end
  end
  else begin
    case (i_addr[ADDR_WIDTH-1:0])
//  `FILTER_SEQ_CTRL       :  filter_seq               <= i_wr? i_wr_data[2:0] : filter_seq;
  `FILTER_HPF_BP_L       :  hpf_filter_bypass[7:0]   <= i_wr? i_wr_data[7:0] : hpf_filter_bypass[7:0]; 
  `FILTER_HPF_BP_H       :  hpf_filter_bypass[15:8]  <= i_wr? i_wr_data[7:0] : hpf_filter_bypass[15:8]; 
  `FILTER_LPF_BP_L       :  lpf_filter_bypass[7:0]   <= i_wr? i_wr_data[7:0] : lpf_filter_bypass[7:0]; 
  `FILTER_LPF_BP_H       :  lpf_filter_bypass[15:8]  <= i_wr? i_wr_data[7:0] : lpf_filter_bypass[15:8]; 
  `FILTER_NOF_BP_L       :  notch_filter_bypass[7:0] <= i_wr? i_wr_data[7:0] : notch_filter_bypass[7:0]; 
  `FILTER_NOF_BP_H       :  notch_filter_bypass[15:8]<= i_wr? i_wr_data[7:0] : notch_filter_bypass[15:8]; 
  `FILTER_INT_CTRL       :  eeg_int_en               <= i_wr? i_wr_data[1:0]   : eeg_int_en; 
  `FILTER_INT_STS        :  eeg_int_clr              <= (i_wr & !int_clear_type)? i_wr_data[0]: (i_rd & int_clear_type)? (eeg_int_sts & i_rd) : 1'b0;
  `GENERAL_INTERUPT_STATUS_REG01 :  eeg_int_clr      <= (i_rd & int_clear_type)? (eeg_int_sts & i_rd) : 1'b0;
  `FILTER_NOTCH_DATA_GONE_L       :  cic_data_ignore_tar[7:0] <= i_wr? i_wr_data[7:0] : cic_data_ignore_tar[7:0]; 
  `FILTER_NOTCH_DATA_GONE_H       :  cic_data_ignore_tar[15:8]<= i_wr? i_wr_data[7:0] : cic_data_ignore_tar[15:8]; 
  `FILTER_COEFF_ADDR          :  coeff_addr                         <= i_wr? i_wr_data[7:0] : coeff_addr;
  `FILTER_COEFF_DATA1         :  coeff_data[coeff_addr][7:0]    <= i_wr? i_wr_data[7:0] : coeff_data[coeff_addr][7:0]; 
  `FILTER_COEFF_DATA2         :  coeff_data[coeff_addr][15:8]   <= i_wr? i_wr_data[7:0] : coeff_data[coeff_addr][15:8]; 
  `FILTER_COEFF_DATA3         :  coeff_data[coeff_addr][23:16]  <= i_wr? i_wr_data[7:0] : coeff_data[coeff_addr][23:16]; 
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


localparam NO_OF_TRIM = 10;
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

  for (otp_num=0;otp_num<NO_OF_TRIM;otp_num++) begin : otp_trim

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

wire key_data,spi_wr_data,spi_rd_data;
reg  [7:0] spi_otp_addr,spi_otp_data;
wire [7:0] spi_data_read;
wire       spi_otp_addr_valid;

assign spi_otp_addr_valid = (spi_otp_addr>=8'h10) && (spi_otp_addr<=8'h7F);
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

assign PROD_ID = trim_from_otp[9][2:0];

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
assign spi_data_read = spi_otp.os_ctrl[26:19];

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
genvar i;

generate 
  for(i=0;i<NO_OF_WAVEGEN;i=i+1) begin : wg_reg_block

  spi_reg_wavegen#(
    .ADDR_WIDTH(10),
    .DATA_WIDTH(DATA_WIDTH),
    .HLF_WV_NO_PTS(HLF_WV_NO_PTS),
    .NO_OF_WAVEGEN(i),
    .OUT_NO_BITS(8))
  u_spi_reg_wavegen(
   .i_clk                     (i_clk),
   .i_rst_n                   (i_rst_n),
   .i_wr                      (i_wavegen_wr),
   .i_rd			(i_wavegen_rd),
   .int_clear_type            (int_clear_type),
   .i_rd_normal               (i_rd_normal),
   .i_addr			({drive_slct_03_47,i_addr}),
   .i_wr_data			(i_wr_data),

   .i_wg_driver_in_wave_addr	(spi_wg.i_wg_driver_in_wave_addr[i]),
   .i_wg_driver_ems_wave_addr	(spi_wg.i_wg_driver_ems_wave_addr[i]),
   .i_wg_driver_source	(spi_wg.i_wg_driver_source[i]),
   .i_period_num              (spi_wg.i_period_num[i]),
   .o_wg_driver_en		(spi_wg.o_wg_driver_en[i]),
   .o_period_sel              (spi_wg.o_period_sel[i]),
   .w_isel                    (spi_wg.w_isel[i]),
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
//--------------------NIRS Register---------------------------------------------------
//------------------------------------------------------------------------------------
  reg [2:0] nirs_ctrl_addr_reg;
  reg [5:0] nirs_ctrl_clk_reg;
  reg [7:0] nirs_ctrl_en_reg;
  reg [7:0] nirs_ctrl_meas_reg;

  wire [7:0] nirs_ctrl_tmp[10:0];
  wire [7:0] nirs_debug_tmp[5:0];  
  reg [7:0] nirs_ctrl_reg[NO_OF_NIRS-1:0][10:0];
  reg [7:0] nirs_debug_reg[NO_OF_NIRS-1:0][5:0];

  reg [7:0] nirs_int_sts_reg;
  reg [7:0] nirs_dout_reg[18:0];

assign ppg_dis          = nirs_ctrl_clk_reg[0];           //ppg disble 
assign ana_ppgclk_inv   = nirs_ctrl_clk_reg[1];   // ana ppg clock 
assign ppg_clk_div      = nirs_ctrl_clk_reg[3:2];       // ppg clock divider
assign ppg_clk50duty    = nirs_ctrl_clk_reg[4];            
assign ppg_rst_reg      = nirs_ctrl_clk_reg[5];

always@(posedge i_clk or negedge i_rst_n) begin
  if(!i_rst_n) begin
    nirs_ctrl_addr_reg  <= 3'h0;
    nirs_ctrl_clk_reg   <= 6'h00;
    nirs_ctrl_en_reg    <= 8'h00;
    nirs_ctrl_meas_reg  <= 8'h00;
  end else begin
    case (i_addr[ADDR_WIDTH-1:0])
      `NIRS_CTRL_ADDR : nirs_ctrl_addr_reg  <= i_wr ? i_wr_data[2:0] : nirs_ctrl_addr_reg [2:0];
      `NIRS_CTRL_CLK  : nirs_ctrl_clk_reg   <= i_wr ? i_wr_data[5:0] : nirs_ctrl_clk_reg  [5:0];
      `NIRS_CTRL_EN   : nirs_ctrl_en_reg    <= i_wr ? i_wr_data[7:0] : nirs_ctrl_en_reg   [7:0];
      `NIRS_CTRL_MEAS : nirs_ctrl_meas_reg  <= i_wr ? i_wr_data[7:0] : nirs_ctrl_meas_reg [7:0];
    endcase
  end
end

always@(posedge i_clk or negedge i_rst_n) begin
  if(!i_rst_n) begin
    for(int x = 0; x < NO_OF_NIRS; x = x + 1) begin
      nirs_ctrl_reg [x][0]  <= 8'h00;
      nirs_ctrl_reg [x][1]  <= 8'h00;
      nirs_ctrl_reg [x][2]  <= 8'h00;
      nirs_ctrl_reg [x][3]  <= 8'h00;
      nirs_ctrl_reg [x][4]  <= 8'h00;
      nirs_ctrl_reg [x][5]  <= 8'h00;
      nirs_ctrl_reg [x][6]  <= 8'h00;
      nirs_ctrl_reg [x][7]  <= 8'h00;
      nirs_ctrl_reg [x][8]  <= 8'h00;
      nirs_ctrl_reg [x][9]  <= 8'h00;
      nirs_ctrl_reg [x][10] <= 8'h00;
    end

  end else begin
    for (int y = 0; y < NO_OF_NIRS; y = y + 1)
      if (nirs_ctrl_addr_reg == y) begin
        nirs_ctrl_reg [y][0]  <= i_wr ? i_wr_data : nirs_ctrl_reg [y][0];
        nirs_ctrl_reg [y][1]  <= i_wr ? i_wr_data : nirs_ctrl_reg [y][1];
        nirs_ctrl_reg [y][2]  <= i_wr ? i_wr_data : nirs_ctrl_reg [y][2];
        nirs_ctrl_reg [y][3]  <= i_wr ? i_wr_data : nirs_ctrl_reg [y][3];
        nirs_ctrl_reg [y][4]  <= i_wr ? i_wr_data : nirs_ctrl_reg [y][4];
        nirs_ctrl_reg [y][5]  <= i_wr ? i_wr_data : nirs_ctrl_reg [y][5];
        nirs_ctrl_reg [y][6]  <= i_wr ? i_wr_data : nirs_ctrl_reg [y][6];
        nirs_ctrl_reg [y][7]  <= i_wr ? i_wr_data : nirs_ctrl_reg [y][7];
        nirs_ctrl_reg [y][8]  <= i_wr ? i_wr_data : nirs_ctrl_reg [y][8];
        nirs_ctrl_reg [y][9]  <= i_wr ? i_wr_data : nirs_ctrl_reg [y][9];
        nirs_ctrl_reg [y][10] <= i_wr ? i_wr_data : nirs_ctrl_reg [y][10];
      end
  end
end

  assign nirs_ctrl_tmp  = nirs_ctrl_reg[nirs_ctrl_addr_reg];
  assign nirs_debug_tmp = nirs_debug_reg[nirs_ctrl_addr_reg];


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
      `IMEAS_D3           : reg_rd_data <= imeas_chdata_wire[31:24];
 
    // clk_ctrl
      `CLK_CTRL_REG       :   reg_rd_data <={ clk_ctrl_reg};   //{2'b00,otp_to_clk_ctrl}; 
      `ANAC_CTRL          :   reg_rd_data <={ 4'b0,anac_ctrl};
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
       
    //lead off
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

      // analog register
      `ANA_ENABLE_REG_0	:  reg_rd_data  <= ana_enable_reg_0;
      `ANA_ENABLE_REG_1	:  reg_rd_data  <= ana_enable_reg_1;
      `ANA_ENABLE_REG_2	:  reg_rd_data  <= ana_enable_reg_2;
      `ANA_ENABLE_REG_3	:  reg_rd_data  <= ana_enable_reg_3;
      `ANA_GEN_REG_1	:  reg_rd_data  <= ana_gen_reg_1;
      `ANA_GEN_REG_2	:  reg_rd_data  <= ana_gen_reg_2;
      `ANA_GEN_REG_3	:  reg_rd_data  <= ana_gen_reg_3;
      `ANA_GEN_REG_4	:  reg_rd_data  <= ana_gen_reg_4;
      `ANA_GEN_REG_5	:  reg_rd_data  <= ana_gen_reg_5;
      `ANA_GEN_REG_6	:  reg_rd_data  <= ana_gen_reg_6;
      `ANA_GEN_REG_7	:  reg_rd_data  <= ana_gen_reg_7;
      `ANA_GEN_REG_8	:  reg_rd_data  <= ana_gen_reg_8;
      `ANA_GEN_REG_9	:  reg_rd_data  <= ana_gen_reg_9;

      `A2D_ANA_GEN_REG_0  :  reg_rd_data <= A2D_ANA_GEN_REG_0 ;
      `A2D_SPARE_RO_REG_0 :  reg_rd_data <= A2D_SPARE_RO_REG_0;
 
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

      `WAVEGEN_GLOBAL_REG         : reg_rd_data  <=  {4'b0,stimu_en,drive_slct_03_47,drivea_global_en }; // (read/write register)

      `ATM_HC_SEL                 : reg_rd_data  <= {6'b0, atm_hc_sel_reg};

      `GENERAL_INTERUPT_CTRL_REG      : reg_rd_data  <= {5'b0, int_ctrl_reg};    
      //`GENERAL_INTERUPT_STATUS_REG01  : reg_rd_data  <= {tsc_intr_sts,2'b0,lead_off_result1,lead_off_result,1'b0,eeg_int_sts,ana_lvd_intr_pin};    
      `GENERAL_INTERUPT_STATUS_REG01  : reg_rd_data  <= {tsc_intr_sts,5'b0,eeg_int_sts,ana_lvd_intr_pin};    
      `GENERAL_INTERUPT_STATUS_REG02  : reg_rd_data  <= {spi_wg.i_wg_driver_int_sts[3],spi_wg.i_wg_driver_int_sts[2],spi_wg.i_wg_driver_int_sts[1],spi_wg.i_wg_driver_int_sts[0]};   
      `GENERAL_INTERUPT_STATUS_REG03  : reg_rd_data  <= {spi_wg.i_wg_driver_int_sts[7],spi_wg.i_wg_driver_int_sts[6],spi_wg.i_wg_driver_int_sts[5],spi_wg.i_wg_driver_int_sts[4]};   
      `GENERAL_INTERUPT_STATUS_REG04  : reg_rd_data  <= {spi_wg.i_wg_driver_int_sts[11],spi_wg.i_wg_driver_int_sts[10],spi_wg.i_wg_driver_int_sts[9],spi_wg.i_wg_driver_int_sts[8]};   
      `GENERAL_INTERUPT_STATUS_REG05  : reg_rd_data  <= {spi_wg.i_wg_driver_int_sts[15],spi_wg.i_wg_driver_int_sts[14],spi_wg.i_wg_driver_int_sts[13],spi_wg.i_wg_driver_int_sts[12]};   

//    `GENERAL_INTERUPT_STATUS_REG04  : reg_rd_data  <= lead_off_result;   

//    `FILTER_SEQ_CTRL    :  reg_rd_data  <= {5'b0,filter_seq};               
      `FILTER_HPF_BP_L    :  reg_rd_data  <= hpf_filter_bypass[7:0];  
      `FILTER_HPF_BP_H    :  reg_rd_data  <= hpf_filter_bypass[15:8];  
      `FILTER_LPF_BP_L    :  reg_rd_data  <= lpf_filter_bypass[7:0];   
      `FILTER_LPF_BP_H    :  reg_rd_data  <= lpf_filter_bypass[15:8];  
      `FILTER_NOF_BP_L    :  reg_rd_data  <= notch_filter_bypass[7:0]; 
      `FILTER_NOF_BP_H    :  reg_rd_data  <= notch_filter_bypass[15:8];
      `FILTER_INT_CTRL    :  reg_rd_data  <= {6'b0,eeg_int_en}; 
      `FILTER_INT_STS     :  reg_rd_data  <= {7'b0,eeg_int_sts}; 

      `FILTER_NOTCH_DATA_GONE_L    :  reg_rd_data  <= cic_data_ignore_tar[7:0]; 
      `FILTER_NOTCH_DATA_GONE_H    :  reg_rd_data  <= cic_data_ignore_tar[15:8]; 
      `FILTER_COEFF_ADDR  :  reg_rd_data  <= coeff_addr;
      `FILTER_COEFF_DATA1 :  reg_rd_data  <= coeff_data[coeff_addr][7:0]; 
      `FILTER_COEFF_DATA2 :  reg_rd_data  <= coeff_data[coeff_addr][15:8]; 
      `FILTER_COEFF_DATA3 :  reg_rd_data  <= coeff_data[coeff_addr][23:16]; 
    //`FILTER_COEFF_DATA3 :  reg_rd_data  <= (coeff_addr < 8'd16)? {6'b0,coeff_data[coeff_addr][17:16]} : {4'b0,coeff_data[coeff_addr][19:16]}; 

      `NIRS_CTRL_ADDR     :  reg_rd_data  <= nirs_ctrl_addr_reg; 
      `NIRS_CTRL_CLK      :  reg_rd_data  <= nirs_ctrl_clk_reg;
      `NIRS_CTRL_EN       :  reg_rd_data  <= nirs_ctrl_en_reg;
      `NIRS_CTRL_MEAS     :  reg_rd_data  <= nirs_ctrl_meas_reg;
    //`NIRS_INT_STATUS    :  reg_rd_data  <= nirs_int_sts_reg;
      
      `NIRS_DOUT_0        :  reg_rd_data  <= nirs_dout_reg[0];
      `NIRS_DOUT_1        :  reg_rd_data  <= nirs_dout_reg[1];
      `NIRS_DOUT_2        :  reg_rd_data  <= nirs_dout_reg[2];
      `NIRS_DOUT_3        :  reg_rd_data  <= nirs_dout_reg[3];
      `NIRS_DOUT_4        :  reg_rd_data  <= nirs_dout_reg[4];
      `NIRS_DOUT_5        :  reg_rd_data  <= nirs_dout_reg[5];
      `NIRS_DOUT_6        :  reg_rd_data  <= nirs_dout_reg[6];
      `NIRS_DOUT_7        :  reg_rd_data  <= nirs_dout_reg[7];
      `NIRS_DOUT_8        :  reg_rd_data  <= nirs_dout_reg[8];
      `NIRS_DOUT_9        :  reg_rd_data  <= nirs_dout_reg[9];
      `NIRS_DOUT_10       :  reg_rd_data  <= nirs_dout_reg[10];
      `NIRS_DOUT_11       :  reg_rd_data  <= nirs_dout_reg[11];
      `NIRS_DOUT_12       :  reg_rd_data  <= nirs_dout_reg[12];
      `NIRS_DOUT_13       :  reg_rd_data  <= nirs_dout_reg[13];
      `NIRS_DOUT_14       :  reg_rd_data  <= nirs_dout_reg[14];
      `NIRS_DOUT_15       :  reg_rd_data  <= nirs_dout_reg[15];
      `NIRS_DOUT_16       :  reg_rd_data  <= nirs_dout_reg[16];
      `NIRS_DOUT_17       :  reg_rd_data  <= nirs_dout_reg[17];
      `NIRS_DOUT_18       :  reg_rd_data  <= nirs_dout_reg[18];

      `NIRS_CTRL_0        :  reg_rd_data  <= nirs_ctrl_tmp[0]; 
      `NIRS_CTRL_1        :  reg_rd_data  <= nirs_ctrl_tmp[1]; 
      `NIRS_CTRL_2        :  reg_rd_data  <= nirs_ctrl_tmp[2]; 
      `NIRS_CTRL_3        :  reg_rd_data  <= nirs_ctrl_tmp[3]; 
      `NIRS_CTRL_4        :  reg_rd_data  <= nirs_ctrl_tmp[4];
      `NIRS_CTRL_5        :  reg_rd_data  <= nirs_ctrl_tmp[5];
      `NIRS_CTRL_6        :  reg_rd_data  <= nirs_ctrl_tmp[6];
      `NIRS_CTRL_7        :  reg_rd_data  <= nirs_ctrl_tmp[7];
      `NIRS_CTRL_8        :  reg_rd_data  <= nirs_ctrl_tmp[8];
      `NIRS_CTRL_9        :  reg_rd_data  <= nirs_ctrl_tmp[9];
      `NIRS_CTRL_10       :  reg_rd_data  <= nirs_ctrl_tmp[10];
      `NIRS_DEBUG_0       :  reg_rd_data  <= nirs_debug_tmp[0];
      `NIRS_DEBUG_1       :  reg_rd_data  <= nirs_debug_tmp[1];
      `NIRS_DEBUG_2       :  reg_rd_data  <= nirs_debug_tmp[2];
      `NIRS_DEBUG_3       :  reg_rd_data  <= nirs_debug_tmp[3];
      `NIRS_DEBUG_4       :  reg_rd_data  <= nirs_debug_tmp[4];
      `NIRS_DEBUG_5       :  reg_rd_data  <= nirs_debug_tmp[5];

      default             :  reg_rd_data  <= 8'b0;
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

assign o_rd_data = wavegen_cmd_reg? wavegen_rd_data : reg_rd_data;

// Analog Inputs
assign  A2D_ANA_GEN_REG_0   = spi_ana_if.A2D_ANA_GEN_REG[0];
assign  A2D_SPARE_RO_REG_0  = spi_ana_if.A2D_ANA_GEN_REG[1]; 


// Analog Output's
assign spi_pinmux_if.ATM_HC_SEL         = atm_hc_sel_reg[0];
assign spi_pinmux_if.ANA_BIST_HC_SEL    = atm_hc_sel_reg[1];
assign spi_pinmux_if.INT_LEVEL_SEL      = int_active_level;
//assign spi_ana_if.ATM_HC_SEL            = atm_hc_sel_reg[0];

assign spi_pinmux_if.ANA_ENABLE_REG[0]  = ana_enable_reg_0;
assign spi_pinmux_if.ANA_ENABLE_REG[1]  = ana_enable_reg_1; //ana_gen_reg_1;
assign spi_pinmux_if.ANA_ENABLE_REG[2]  = ana_enable_reg_2; //ana_gen_reg_2;
assign spi_pinmux_if.ANA_ENABLE_REG[3]  = ana_enable_reg_3; //ana_gen_reg_2;
assign spi_ana_if.D2A_ANA_GEN_REG[0]    = ana_gen_reg_1;
assign spi_ana_if.D2A_ANA_GEN_REG[1]    = ana_gen_reg_2;
assign spi_ana_if.D2A_ANA_GEN_REG[2]    = ana_gen_reg_3;
assign spi_ana_if.D2A_ANA_GEN_REG[3]    = ana_gen_reg_4;
assign spi_ana_if.D2A_ANA_GEN_REG[4]    = ana_gen_reg_5;
assign spi_ana_if.D2A_ANA_GEN_REG[5]    = ana_gen_reg_6;
assign spi_ana_if.D2A_ANA_GEN_REG[6]    = ana_gen_reg_7;
assign spi_ana_if.D2A_ANA_GEN_REG[7]    = ana_gen_reg_8;
assign spi_ana_if.D2A_ANA_GEN_REG[8]    = ana_gen_reg_9;

//NIRS

  assign spi_nirs_if.NIRS_CTRL      = nirs_ctrl_reg;
  assign spi_nirs_if.NIRS_CTRL_EN   = nirs_ctrl_en_reg;
  assign spi_nirs_if.NIRS_CTRL_MEAS = nirs_ctrl_meas_reg;
  assign nirs_debug_reg             = spi_nirs_if.NIRS_DEBUG;
  assign nirs_dout_reg              = spi_nirs_if.NIRS_DOUT;


endmodule
