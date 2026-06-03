
 


ENS2
Reference Manual


Author: 
Design Team


O
Rev. [0.1]

 
Revision History
Rev	Date	Author	Description 
0.1	20/03/2024	Daniel Dang	First draft from ENS1p4
0.2	26/08/2025	Xin	Draft version of ENS2
0.3	05/09/2025	Xin	Add EEG filter feature
0.4	08/09/2025	Xin	1. Add imeas_ctrl register(0x99) and 
Move the imeas_reg_2[7:3] to imeas_ctrl[7:3]
2. Move iclk_div from imeas_reg_1[7:4] to clk_ctrl[7:4] and change imeas_reg_1[7:4] default to 0
0.5 	15/09/2025	Zhen 	1. Upload LPF rtl code and report, updated the doc, see section 13.7
2. Upload Notch filter  RTL code and report, updated the doc, see section 13.8

0.6	16/09/2025	Xin	Add IMEAS_EN_DIS_CH(0x9A/0x9B)
0.7	16/09/2025
	Zhen
	Added filter reg 0xB0~0XB6
see section 12.11.7~12.11.10

0.8	17/09/2025	Zhen
	Added filter reg 0xB7~0XB8
see section 12.11.11~12.11.12

0.9 	17/09/2025	Zhen
	1. Added reg 0xB9/0xBA, see section 12.11.13
2. Changed the default value of reg 0xB1/0xB2/0xB3/0xB4/0xB5/0xB6 from 0x00 to 0xFF

0.11	18/09/2025	Zhen	1. Updated reg 0xB7,see 12.11.11
2. Updated detail description for filter top, see section 13.7
OSC0.12	22/9/2025	Zhen 	Updated reg 12.8.3
0.13	25/9/2025	Zhen	Updated LPF architecture- use Kaiser filter,see 13.7.7
Added reg 0xBB~0xBE，see 12.11
0.14	27/10/2025	Zhen 	1. Removed kaiser filter
2. Updated register 0xBB~0xBE
3. Added LPF explanation of the Ripple Architecture
4. Update the description of the notch filter
5. Remove the hardware code of the filter, and the filter coefficients need to be written through SPI
See section 13.7.7/13.7.8/12.11.14/12.11.15
0.15	27/10/2025	Zhen 	Removed reg 0xB0
0.16	28/10/2025	Thanh	Added RDATA/DAISY
0.17	30/10/2025	Zhen 	Change the notch filter multiplier architecture to a serial multiplier and update the filter preset parameters.
0.18	6/11/2025	Zhen 	Updated clock of filter , see section 13.7.2
0.19	17/11/2025	Zhen 	Updated the coefficient of notch, see 13.7.7.2
0.20	23/11/2025	Truong	Updated the coefficient of HPF, see 12.11.14 and 13.7.8
0.21	24/11/2024	Zhen 	Added OTP1, which is used to store current calibration coefficients of wavegen.added spi register 0x1A; see 7.6, 12.4.15 and 12.4.17
0.22	26/11/2024	Zhen 	Updated notch filter, it is 14-orders now,see 13.7.7
0.22	28/11/2024	Xin	Add   NIRS_CTRL_7
0.23	30/11/2025	Truong	Added description for NIRS
0.24	16/12/2025	Zhen 	1. Updated wavegen to support 8 drives(Currently, it is drive A. Subsequently, corresponding modifications will be made based on drive C.)
2. Updated ANAC to support 8 dirves
See register 0x03, register 0x50~0x62,section 13.6.34
0.25	16/12/2025	Zhen 	Updated global INT register, see register 0x79/0x7A, added new register 0x7B
0.26	1712/2025	Zhen 	1. Added EMS feature for wavegen, see section 9.9.11, 9.9.12
2. Added wavegen registers 0x38/0X39/0X3A
0.27	1812/2025	Zhen 	1. Added rest time for ALT function
2. Added AWG registers 0x32/0x33
3. Remaped AWG registers 0x32~0x3A
0.28	19/12/2025	Xin	Integrate the 8 leadoff and rearrange the register
0x26-0x39, 0x80-0x85
And add 0x7c, move the leadoff_result to this register
0.29	24/12/2025	Zhen 	1. Added drive C, removed drive A
2. Added AWG registers 0x3D/0D3E
See charter 9, 13.15.28,13.15.29
0.30	9/3/2026	Zhen 	1. Removed short detection
2. Removed lead-off detection
3. Removed A2D_COMP edge detection
4. Removed register 0x26~0x39/0x51~0x61/0x7c/0x80~0x85
0.31	10/3/2026	Zhen 	1. Increase the drivers of wavegen to 16 
2. Added Normal Registers 0x7C/0x7D
3. Added wavegen register 0x3F
4. Updated Normal Register 0x03
5. Updated wavegen register 0x3E
0.32	11/3/2026	Zhen 	1. Removed wavegen register 0x00 bit[1]/bit[3]
2. Removed wavegen register 0x01 bit[7]
3. Removed wavegen register 0x0D/0x0E/0x17/0x18/0x25/0x26
4. Removed wavegen register 0x29 bit[3]
5. Updated wavegen register 0x2B bit[2:0],read access part
6. Removed wavegen register 0x3B bit[5:4]
7. Removed wavegen register 0x34 bit[1],bit[3],bit[7:6]
8. Removed chart 9.9.9/9.9.12
9. Updated rtl code, Remove the functionality related to negative edges and only remove the relevant registers.
0.33	13/3/2026	Zhen 	1. Normal Register 0x03: added bit[3]: D2A_STIMU_EN
2. Wavegen register  0x3d ：changed it to D2A_CBUF_EN
0.34	17/3/2026	Zhen 	1. Added section 9.9.1: negative edge
2. Added more description for wavegen register 0x 3E/0x3F, see section 11.15.39 
0.35	18/03/2026	Truong	1. GPIO 11 -> 15
2. GPIO_PD_CTRL 
3. INT_OSC_OUT_EN MOVED FROM GPIO[10] to GPIO[12]
4. Removed GPIO_COMP_OUT_CTRL: 0x23
0.36	26/3/2026	Zhen 	1. Added  new 7 spare trim registers according to new register mapping
2. Remap 0x1c(new address)
3. Remap 0x1d~0x21(new address)
4. Remap 0x30~0x32(new address)
0.37	28/03/2026	Truong	Support flags for IDAC_MAX and IDAC_MIN - NIRS_DEBUG_5: 0xD5  
0.38	30/03/2026	My	Updated ANA_ENABLE_REG[2:0]
0.39	1/4/2026	Zhen	Updated Notch filter：
changed the order 14 to order 12,see 14.7.7
0.40	2/4/2026	Zhen	Updated LPF filter：
changed the from order 31 to order 27,see 14.7.6/14.7.7.2/14.7.8.2
0.41	03/04/2026	Truong	Update SPI CMD to support NIRS CMD
See 6.5.4
0.42	05/04/2026	Truong	Moved NIRS regs to its own address map
See 13.14
0.43	14;/04/2026	Xin	IMEAS_REG_1 default to 0x27
0.44	14/04/2026	My	Update ANA_ENABLE_REG and ANA_GEN_REG
0.45	15/04/2026	My	Reserve ANA_GEN_REG[4][7] to ANA_GEN_REG[6][8] 
0.46	20/04/2026	My	Added 15.3.3  GPIO_NIRS_OUT_CTRL to support NIRS module
0.47	20/04/2026	Truong	Supported int for NIRS
Check 13.14 and 13.10.7 GENERAL INTERRUPT
0.48	21/04/2026	Truong	Moved PINMUX_REG_BASE_ADDR from 0x7E to 0x7F
0.49	24/04/2026	Truong	Updated some NIRS timings/settings + Supported Ambient mode
0.5	2/05/2026	Xin	Add 0xF0-0xF3 for wavegen and EEG/NIRS sync feature, detail is at chapter 13.14
0.51	6/05/2026	Xin	Add ANAC_CTRL[7:4] for pga clock generation
0.52	06/05/2026	Truong	Added moving-average feature for DOUT and increased width to 22 bits.
See 13.15.5 and DOUT registers
0.53	07/05/2026	Xin	Add the voltage check and resistor check by ADC sampling, see 11.6 for details
0.54	07/05/2026	Zhen	Updated Notch filter: 
1. Register 0xBB,  see 13.13.14
2. NF unstable time, see 14.7.5.1
3. NF info,see 14.7.8.2
4. HPF coefficient address,see 13.13.14
0.55	7/5/2026	My	Update ANA_GEN_REG[0][14]-> ANA_GEN_REG[7][14] and Register map.
0.56	11/5/2026	Xin		Change STIM_PAD_CTRL[7:6] and STIM_MON_INT[7:4], STIM_MON_INT[1:0] definition
	Add STIM_ADC_DELTA_DATA_TAG: 0xF6 – 0xF7 for vpeak value
0.57	12/5/2026	Zhen 		Removed 9.9.1
	Updated mul-electrode,see 9.9.9
	Changed shape register from 128 to 64
0.58	12/5/2026	Zhen 		Added burst for wavegen shape register,see 9.9.14
0.59	13/05/2026	My	Updated D2A_DCLOFFEN to D2A_DCLOFFEN[15:0], see 13.7.22 and 13.7.23

0.60	13/5/2026	Zhen 	Updated notch filter mapping, see 14.7.7.4
0.61	13/5/2026	Zhen 	updated offset logic of wavegen,see 9.9.7
0.62	13/5/2026	Xin	Add 0x47 register for delay of stimulation incase adc is not stable
0.63	14/5/2026	Zhen 	Added mul-wavegen access function,see 9.9.15
Added general register 0x07/0x08
0.64	14/5/2026	Zhen 		Move bit0 of 0x3D(old address, already removed) to bit[1] of 0x37(old address)/0x38(new address)
	Increase rest time of wave0 to 24 bits(new rest register address is 0x07)
	Remap wavegen address, map 0x07~0x3c to 0x08~0x3d
(All the above register addresses are wavegen registers.)
	Change wavegen enable logic from “global_en | driver_en” to “global_en & driver_en”
	Added clock gating logic for each driver
0.65	15/5/2026	Xin	Bit4 of STIM_MON_CLK_RST_CTRL(MON_ADC_CLK_INV) default to 0
0.66	18/5/2026	Xin		Rearrange the INT_EN/adc_en bit in STIM_PAD_CTRL, STIM_MON_INT, and STIM_PAD_CTRL1 and add more option for configuration
	Add burst read cycle data feature
0.67	20/5/2026	Xin	 Add 0x51-0x5A registers for leadoff/short detection
0.68	20/5/2026	Zhen		Updated special waveform for silent time，see 9.9.11
	Added DDS mode，see 9.9.16
	Added mul-waveform repetition function， see，9.9.17
	Added enable signals for DDS、mul-waveform repetition，see wavegen register 0x38 bit[2]/bit[3]
0.69	20/5/2026	Xin	Bit7:6 of PMU_REG reserved and remove leadoff_pclk and leadoff_resetn
0.70	21/5/2026	Xin	Add bit6 MULTI_INTB_PIN in PMU_REG for multiple INTB pin
0.71	21/5/2026	My	Add 13.5.5 GPIO_NORMAL_OUT_CTRL for GPIO[8]
0.72	22/5/2026	Xin		Update the clock and reset diagram
2) add stim_on_flag on status field

0.73	25/5/2026	Zhen 	Remap wavegen register
0x00->0x02
0x01->0x03
0x02->0x04
0x03->0x01
0x04->0x00
0.74	26/5/2026	Xin		Add bit10 w/r of STIM_ADC_DELTA_DATA_TAG for delta data capture in manual mode
	Add bit11 w/r of STIM_ADC_DELTA_DATA_TAG for 2nd max/min data
0.75	27/5/2026	Xin	Rearrange 2 register address and add more register for general int 
	TSC_VDAC_NOR address is changed from 0x73 to 0x69
	TSC_SMP_STS address is changed from 0x74 to 0x6A
	Add GENERAL_INTERUPT_STATUS_REG07 to GENERAL_INTERUPT_STATUS_REG0B address (0x73-0x77)
0.76	28/5/2026	Xin	Change the 0x43 register name to STIM_MON_CTRL2 and add bit6 for more option of adc controller
0.77	29/5/2026	Xin	Add STIM_ORIG_ADC_DATA(0xF4-0xF5) for debug purpose
This data is from analog directly
0.78	2/6/2026	Xin	Add 0x5B/0x5C for longer stim monitor period
STIM_MON_PERIOD_H


 

Contents
1.	Overview	20
Applications	20
Features	20
Block Diagram	22
2.	Pin Description	24
Pin and Package definition	24
3.	Power-up sequence	25
4.	System Control Unit (SCU)	27
This block contains the clock control, reset control and PMU.	27
4.1.	PMU (Power Management Unit)	27
4.2.	Reset Control	27
4.3.	Clock Control	28
4.3.1.	Clock Tree Structure	28
5.	Interrupt Sources to INTB Pin	31
5.1.	Diagram	31
5.2.	Interrupt Source Table	31
6.	Serial Peripheral Interface (SPI)	33
6.1.	Overview	33
6.2.	Block Diagram	33
6.3.	Functional Description	34
6.4.	Interface	34
6.5.	SPI Slave Controller Specification	36
6.5.1.	SPI Slave Controller Features:	36
6.5.2.	Communication:	36
6.5.3.	SPI Modes:	36
6.5.4.	Data communication format between Master and Slave	37
6.5.5.	SPI-Timing Characteristics:	45
7.	One Time Program	46
7.1.	Introduction	46
7.2.	Architecture	47
7.3.	Feature List	48
7.4.	Interface	49
7.5.	Model and Timing	51
7.5.1.	Supported user operating mode	51
7.5.2.	Timing parameters	52
7.5.3.	Timing waveforms	53
7.5.4.	USER MODE - READ operation timing	53
7.5.5.	USER MODE -WRITE operation timing	54
7.6.	Function and Registers	55
7.6.1.	Function description	55
7.6.2.	ANALOG TRIM BY GPIO	57
7.7.	VPP timing	61
7.8.	Registers	62
8.	OTP BIST	64
8.1.	Introduction	64
8.2.	Architecture	64
8.2.1.	Block Diagram	64
8.2.2.	Feature List	64
8.2.3.	Interface	64
8.3.	Functional Description	65
8.3.1.	Operation Mode	65
8.3.2.	OTP Cell State by Program operation and XDIN	66
8.3.3.	Program Operation	66
8.3.4.	Read Operation	67
8.3.5.	Margin Read Operation (Test)	67
8.4.	Timing	68
8.5.	VPP TIMING	69
8.5.1.	Access timing via Master	69
8.6.	Serial TDI Input Definition	70
8.7.	Serial TDO Input Definition	71
8.8.	Serial TDI Input Timing	71
8.9.	Serial TDO output Timing	71
9.	Arbitrary Wave Generator	72
9.1.	Overview	72
9.2.	Block Diagram of Wave Generator	73
9.3.	Pin definition	73
9.4.	Registers	75
9.5.	Preloaded function	75
9.5.1.	ENS2 supports preloaded sine, triangle and pulse waveforms. It is hardwired. And be controlled by AWG_DRV_CTRL_REG0 register	75
9.5.2.	Pre-loaded waveform select table:	76
9.6.	PULLB AND PULLA (Glitch removal time)	77
9.7.	Operation mode	77
9.8.	Specification	78
9.9.	Block’s design	79
9.9.1.	Negative edge	79
9.9.2.	The AWG block consists of a state machine which has 8 states:	79
9.9.3.	State table	80
9.9.4.	Test Waveform	81
9.9.5.	Alternating function	84
9.9.6.	Multi-waveform function	85
9.9.7.	Waveform Scaling	87
9.9.8.	Interrupt	88
9.9.9.	multi-electrode	89
9.9.10.	Source B	91
9.9.11.	Special waveform processing for silent time	92
9.9.12.	EMS waveform without interrupts	93
9.9.13.	two consecutive positive or negative waveforms without using interrupts	96
9.9.14.	BURST function for wavegen shape registers	97
9.9.15.	mul-wavegen access function	98
9.9.16.	DDS Mode	99
9.9.17.	Multiple waveform repetition	103
10.	LEAD OFF DETECTOR	105
10.1.	Analog Part (Analog Model)	105
10.2.	Digital Part	109
11.	ANAC (Analog Controller)	113
11.1.	LVD (Low Voltage Detection)	113
11.1.1.	Block Diagram (Analog LVD Model)	113
11.1.2.	Feature	113
11.1.3.	Analog LVD Interrupt:	113
11.2.	Analog Comparators Interrupts:	114
11.3.	Register 0x55 ：	114
11.4.	Short Circuit Detection Design	114
11.4.1.	Analog Circuit Design (Analog Model)	114
11.4.2.	Digital Short Circuit Detection using A2D_COMP_OUT_STIMU0 to 3	116
11.5.	Over-Temperature Protection (TSC)	117
11.5.1.	Functional Overview	118
11.5.2.	SAR state machine	120
11.5.3.	Registers of Over-temperature Protection	121
11.5.4.	TSC Comparators Interrupts:	123
11.6.	Stimulator Voltage Measurement and Resistor Monitor Block:	123
12.	NIRS/PPG CONTROLLER – MISSING LED DRIVER in ANA	140
Index Terms - Photoplethysmogram (PPG), near-infrared spectroscopy (NIRS)	140
12.1.1.	NIRS/PPG_TOP Registers Illustration	140
12.1.2.	NIRS/PPG Control Method	141
12.1.3.	FSM Methods	142
13.	Register Map	145
13.1.	Register Map	145
13.2.	Register Name Change Log	153
13.3.	General Register	155
13.3.1.	PMU_REG: 0x01 (General Register)	155
13.3.2.	CLK_CTRL_REG: Offset - 0x02 (General Register)	156
13.3.3.	WAVEGEN_GLOBAL_REG_0: 0x03 (General Register)	157
13.3.4.	ANAC_CTRL: 0x04 (General Register)	157
13.3.5.	PMU_REG1: 0x05 (General Register)	158
13.3.6.	O_CLK_SEL: 0x06 (General Register)	158
13.3.7.	WAVEGEN_GLOBAL_REG_01: 0x07 (General Register)	158
13.3.8.	WAVEGEN_GLOBAL_REG_02: 0x08 (General Register)	159
13.4.	OTP registers	159
13.4.1.	Debug1 register: 0x0A	159
13.4.2.	Debug2 register: 0x0B	160
13.4.3.	Trim Tag register: 0x0C (General Register)	161
13.4.4.	TRIM_DATA_1 register: 0x0D (General Register)	161
13.4.5.	TRIM_DATA_2 register: 0x0E (General Register)	161
13.4.6.	TRIM_DATA_3 register: 0x0F (General Register)	161
13.4.7.	TRIM_DATA_4 register: 0x10 (General Register)	161
13.4.8.	TRIM_DATA_5 register: 0x11(General Register)	161
13.4.9.	TRIM_DATA_6 register: 0x12(General Register)	161
13.4.10.	TRIM_DATA_7 register: 0x13 (General Register)	161
13.4.11.	TRIM_DATA_8 register: 0x14 (General Register)	161
13.4.12.	TRIM_DATA_9 register: 0x15 (General Register)	162
13.4.13.	TRIM_DATA_10 register: 0x16 (General Register)	162
13.4.14.	TRIM_DATA_11 register: 0x17 (General Register)	162
13.4.15.	TRIM_DATA_12 register: 0x18 (General Register)	162
13.4.16.	TRIM_DATA_13 register: 0x19 (General Register)	162
13.4.17.	TRIM_DATA_14 register: 0x1A (General Register)	162
13.4.18.	TRIM_DATA_15 register: 0x1B (General Register)	162
13.4.19.	TRIM_DATA_16 register: 0x1C (General Register)	162
13.4.20.	OTP_UNLOCK Register: 0x1D (General Register)	163
13.4.21.	OTP_DATA (0x1E) register (General Register)	163
13.4.22.	OTP_ADDR (0x1F) register:	163
13.4.23.	OTP_EME_DATA (0x20) register (General Register)	164
13.4.24.	OTP_WAVEGEN_NUMBER (0x21) register (General Register)	164
13.5.	GPIO Registers	164
13.5.1.	GPIO_PU_CTRL: 0x30 (General Register)	164
13.5.2.	GPIO_PD_CTRL: 0x31 (General Register)	165
13.5.3.	GPIO_SR_PDRV0_1_CTRL: 0x32 (General Register)	165
13.5.4.	GPIO_NIRS_OUT_CTRL: 0x33 (General Register)	165
13.5.5.	GPIO_NORMAL_OUT_CTRL: 0x34 (General Register) –	166
13.6.	Lead Off Detection Register	166
13.6.1.	LEAD_OFF_CTRL: LEAD OFF detection control: 0x26 (General Register)	166
13.6.2.	RESERVED: Reserved Register – Offset: 0x27 (General Register)	166
13.6.3.	LEAD_OFF_INT: Lead Off Detection Interrupt Control: 0x28 (General Register)	166
13.6.4.	COUNTER_TH_TGT_CH: channel comparator status counter target 0x29-0x2C (General Register)	167
13.6.5.	TIMER_CNT_TGT_CH1: Channel check duration target 0x2D-0x30 (General Register)	167
13.6.6.	LEAD_OFF_BLK_SLCT:  channel number of leadoff config 0x31 (General Register)	167
13.6.7.	LEAD_OFF_DAC_EN: lead off channel enable 0x32 (General Register)	167
13.6.8.	LEAD_OFF_STOP_EN: lead off stop wavegen enable 0x33 (General Register)	168
13.6.9.	LEAD_OFF_INT_EN: lead off interrupt output enable 0x34 (General Register)	168
13.6.10.	LEAD_OFF_COMP_LOW_EN: low is lead off indicator 0x35 (General Register)	168
13.6.11.	LEAD_OFF_STOP: state of wavegen should be when lead off happen 0x36 (General Register)	168
13.6.12.	LEAD_OFF_ANA: Lead Off detection compare result from Analog: 0x39(General Register)	169
13.7.	Analog registers	169
13.7.1.	ANA_EN_SECTION_SEL: Offset: 0xC0	169
13.7.2.	ANA_ENABLE_REG[0][0]: Offset: 0xC1	170
13.7.3.	ANA_ENABLE_REG[0][1]: Offset: 0xC2	171
13.7.4.	ANA_ENABLE_REG[0][2]: Offset: 0xC3	171
13.7.5.	ANA_ENABLE_REG[0][3]: Offset: 0xC4	171
13.7.6.	ANA_ENABLE_REG[0][4]: Offset: 0xC5	172
13.7.7.	ANA_ENABLE_REG[0][5]: Offset: 0xC6	172
13.7.8.	ANA_ENABLE_REG[0][6]: Offset: 0xC7	172
13.7.9.	ANA_ENABLE_REG[0][7]: Offset: 0xC8	173
13.7.10.	ANA_ENABLE_REG[0][8]: Offset: 0xC9	173
13.7.11.	ANA_ENABLE_REG[0][9]: Offset: 0xCA	173
13.7.12.	ANA_ENABLE_REG[0][10]: Offset: 0xCB	173
13.7.13.	ANA_ENABLE_REG[0][11]: Offset: 0xCC	174
13.7.14.	ANA_ENABLE_REG[0][12]: Offset: 0xCD	174
13.7.15.	ANA_ENABLE_REG[0][13]: Offset: 0xCE	174
13.7.16.	ANA_ENABLE_REG[0][14]: Offset: 0xCF	174
13.7.17.	ANA_ENABLE_REG[1][0]: Offset: 0xC1	174
13.7.18.	ANA_ENABLE_REG[1][1]: Offset: 0xC2	174
13.7.19.	ANA_ENABLE_REG[1][2]: Offset: 0xC3	175
13.7.20.	ANA_ENABLE_REG[1][3]: Offset: 0xC4	175
13.7.21.	ANA_ENABLE_REG[1][4]: Offset: 0xC5	175
13.7.22.	ANA_ENABLE_REG[1][5]: Offset: 0xC6	175
13.7.23.	ANA_ENABLE_REG[1][6]: Offset: 0xC7	175
13.7.24.	ANA_GEN_SECTION_SEL: Offset: 0xD0	176
13.7.25.	ANA_GEN_REG[0][0]: Offset: 0xD1	176
13.7.26.	ANA_GEN_REG[0][1]: Offset: 0xD2	176
13.7.27.	ANA_GEN_REG[0][2]: Offset: 0xD3	177
13.7.28.	ANA_GEN_REG[0][3]: Offset: 0xD4	177
13.7.29.	ANA_GEN_REG[0][4]: Offset: 0xD5	177
13.7.30.	ANA_GEN_REG[0][5]: Offset: 0xD6	178
13.7.31.	ANA_GEN_REG[0][6]: Offset: 0xD7	178
13.7.32.	ANA_GEN_REG[0][7]: Offset: 0xD8	178
13.7.33.	ANA_GEN_REG[0][8]: Offset: 0xD9	178
13.7.34.	ANA_GEN_REG[0][9]: Offset: 0xDA	178
13.7.35.	ANA_GEN_REG[0][10]: Offset: 0xDB	178
13.7.36.	ANA_GEN_REG[0][11]: Offset: 0xDC	179
13.7.37.	ANA_GEN_REG[0][12]: Offset: 0xDD	179
13.7.38.	ANA_GEN_REG[1][0]: Offset: 0xD1	179
13.7.39.	ANA_GEN_REG[1][1]: Offset: 0xD2	179
13.7.40.	ANA_GEN_REG[1][2]: Offset: 0xD3	179
13.7.41.	ANA_GEN_REG[1][3]: Offset: 0xD4	180
13.7.42.	ANA_GEN_REG[1][4]: Offset: 0xD5	180
13.7.43.	ANA_GEN_REG[1][5]: Offset: 0xD6	180
13.7.44.	ANA_GEN_REG[1][6]: Offset: 0xD7	180
13.7.45.	ANA_GEN_REG[1][7]: Offset: 0xD8	180
13.7.46.	ANA_GEN_REG[1][8]: Offset: 0xD9	180
13.7.47.	ANA_GEN_REG[1][9]: Offset: 0xDA	181
13.7.48.	ANA_GEN_REG[1][10]: Offset: 0xDB	181
13.7.49.	ANA_GEN_REG[1][11]: Offset: 0xDC	181
13.7.50.	ANA_GEN_REG[1][12]: Offset: 0xDD	181
13.7.51.	ANA_GEN_REG[2][0]: Offset: 0xD1	181
13.7.52.	ANA_GEN_REG[2][1]: Offset: 0xD2	181
13.7.53.	ANA_GEN_REG[2][2]: Offset: 0xD3	182
13.7.54.	ANA_GEN_REG[2][3]: Offset: 0xD4	182
13.7.55.	ANA_GEN_REG[2][4]: Offset: 0xD5	182
13.7.56.	ANA_GEN_REG[2][5]: Offset: 0xD6	182
13.7.57.	ANA_GEN_REG[2][6]: Offset: 0xD7	182
13.7.58.	ANA_GEN_REG[2][7]: Offset: 0xD8	182
13.7.59.	ANA_GEN_REG[2][8]: Offset: 0xD9	182
13.7.60.	ANA_GEN_REG[2][9]: Offset: 0xDA	183
13.7.61.	ANA_GEN_REG[2][10]: Offset: 0xDB	183
13.7.62.	ANA_GEN_REG[2][11]: Offset: 0xDC	183
13.7.63.	ANA_GEN_REG[2][12]: Offset: 0xDD	183
13.7.64.	ANA_GEN_REG[3][0]: Offset: 0xD1	183
13.7.65.	ANA_GEN_REG[3][1]: Offset: 0xD2	183
13.7.66.	ANA_GEN_REG[3][2]: Offset: 0xD3	183
13.7.67.	ANA_GEN_REG[3][3]: Offset: 0xD4	183
13.7.68.	ANA_GEN_REG[3][4]: Offset: 0xD5	184
13.7.69.	ANA_GEN_REG[3][5]: Offset: 0xD6	184
13.7.70.	ANA_GEN_REG[3][6]: Offset: 0xD7	184
13.7.71.	ANA_GEN_REG[3][7]: Offset: 0xD8	184
13.7.72.	ANA_GEN_REG[3][8]: Offset: 0xD9	184
13.7.73.	ANA_GEN_REG[3][9]: Offset: 0xDA	184
13.7.74.	ANA_GEN_REG[3][10]: Offset: 0xDB	184
13.7.75.	ANA_GEN_REG[3][11]: Offset: 0xDC	185
13.7.76.	ANA_GEN_REG[3][12]: Offset: 0xDD	185
13.7.77.	ANA_GEN_REG[4][0]: Offset: 0xD1	185
13.7.78.	ANA_GEN_REG[4][1]: Offset: 0xD2	185
13.7.79.	ANA_GEN_REG[4][2]: Offset: 0xD3	185
13.7.80.	ANA_GEN_REG[4][3]: Offset: 0xD4	185
13.7.81.	ANA_GEN_REG[4][4]: Offset: 0xD5	185
13.7.82.	ANA_GEN_REG[4][5]: Offset: 0xD6	185
13.7.83.	ANA_GEN_REG[4][6]: Offset: 0xD7	186
13.7.84.	ANA_GEN_REG[4][7]: Offset: 0xD8	186
13.7.85.	ANA_GEN_REG[4][8]: Offset: 0xD9	186
13.7.86.	ANA_GEN_REG[4][9]: Offset: 0xDA	186
13.7.87.	ANA_GEN_REG[4][10]: Offset: 0xDB	186
13.7.88.	ANA_GEN_REG[4][11]: Offset: 0xDC	186
13.7.89.	ANA_GEN_REG[4][12]: Offset: 0xDD	186
13.7.90.	ANA_GEN_REG[5][0]: Offset: 0xD1	186
13.7.91.	ANA_GEN_REG[5][1]: Offset: 0xD2	186
13.7.92.	ANA_GEN_REG[5][2]: Offset: 0xD3	187
13.7.93.	ANA_GEN_REG[5][3]: Offset: 0xD4	187
13.7.94.	ANA_GEN_REG[5][4]: Offset: 0xD5	187
13.7.95.	ANA_GEN_REG[5][5]: Offset: 0xD6	187
13.7.96.	ANA_GEN_REG[5][6]: Offset: 0xD7	187
13.7.97.	ANA_GEN_REG[5][7]: Offset: 0xD8	187
13.7.98.	ANA_GEN_REG[5][8]: Offset: 0xD9	187
13.7.99.	ANA_GEN_REG[5][9]: Offset: 0xDA	187
13.7.100.	ANA_GEN_REG[5][10]: Offset: 0xDB	187
13.7.101.	ANA_GEN_REG[5][11]: Offset: 0xDC	187
13.7.102.	ANA_GEN_REG[5][12]: Offset: 0xDD	188
13.7.103.	ANA_GEN_REG[6][0]: Offset: 0xD1	188
13.7.104.	ANA_GEN_REG[6][1]: Offset: 0xD2	188
13.7.105.	ANA_GEN_REG[6][2]: Offset: 0xD3	188
13.7.106.	ANA_GEN_REG[6][3]: Offset: 0xD4	188
13.7.107.	ANA_GEN_REG[6][4]: Offset: 0xD5	188
13.7.108.	ANA_GEN_REG[6][5]: Offset: 0xD6	188
13.7.109.	ANA_GEN_REG[6][6]: Offset: 0xD7	188
13.7.110.	ANA_GEN_REG[6][7]: Offset: 0xD8	188
13.7.111.	ANA_GEN_REG[6][8]: Offset: 0xD9	189
13.7.112.	ANA_GEN_REG[6][9]: Offset: 0xDA	189
13.7.113.	ANA_GEN_REG[6][10]: Offset: 0xDB	189
13.7.114.	ANA_GEN_REG[0][13]: Offset: 0xDE	189
13.7.115.	ANA_GEN_REG[1][13]: Offset: 0xDE	189
13.7.116.	ANA_GEN_REG[2][13]: Offset: 0xDE	189
13.7.117.	ANA_GEN_REG[3][13]: Offset: 0xDE	189
13.7.118.	ANA_GEN_REG[4][13]: Offset: 0xDE	189
13.7.119.	ANA_GEN_REG[5][13]: Offset: 0xDE	190
13.7.120.	ANA_GEN_REG[6][13]: Offset: 0xDE	190
13.7.121.	ANA_GEN_REG[7][13]: Offset: 0xDE	190
13.7.122.	ANA_GEN_REG[0][14]: Offset: 0xDF	190
13.7.123.	ANA_GEN_REG[1][14]: Offset: 0xDF	190
13.7.124.	ANA_GEN_REG[2][14]: Offset: 0xDF	191
13.7.125.	ANA_GEN_REG[3][14]: Offset: 0xDF	191
13.7.126.	ANA_GEN_REG[4][14]: Offset: 0xDF	191
13.7.127.	ANA_GEN_REG[5][14]: Offset: 0xDF	191
13.7.128.	ANA_GEN_REG[6][14]: Offset: 0xDF	191
13.7.129.	ANA_GEN_REG[7][14]: Offset: 0xDF	192
13.7.130.	A2D_ANA_GEN_REG_0: 0xA0 (General Register)	192
13.7.131.	A2D_ANA_GEN_REG_1: 0xA1 (General Register)	192
13.7.132.	A2D_ANA_GEN_REG_2: 0xA2  (General Register)	192
13.7.133.	A2D_ANA_GEN_REG_3: 0xA3 (General Register)	192
13.7.134.	A2D_ANA_GEN_REG_4: 0xA4 (General Register)	193
13.7.135.	A2D_SPARE_RO_REG_0: 0xA5 (General Register)	193
13.8.	ANAC registers	193
13.8.1.	ANA_LVD_INT_EN: 0x50 (General Register)	193
13.8.2.	ANA_COMP_INT_EN: 0x51 (General Register)	193
13.8.3.	ANA_COMP_INT_TRANS_EN: 0x52 (General Register)	194
13.8.4.	ANA_INT_STOP_WAVEGEN: 0x53 (General Register)	195
13.8.5.	ANA_STUMI_INT_EN: 0x54 (General Register)	195
13.8.6.	ANA_STIMU_INT_DIG_EN: 0x55 (General Register)	196
13.8.7.	ANA_STIMU_INT_POL_EN: 0x56 (General Register)	196
13.8.8.	ANA_SHORT_BLOCK_SLCT: 0x57 (General Register)	197
13.8.9.	ANA_STIM _CH_TIMER_CNT_TH00: 0x58 (General Register)	197
13.8.10.	ANA_STIM _CH_TIMER_CNT_TH01: 0x59 (General Register)	198
13.8.11.	ANA_STIM _CH_TIMER_CNT_TH02: 0x5A (General Register)	198
13.8.12.	ANA_STIM _CH_TIMER_CNT_TH03: 0x5B (General Register)	198
13.8.13.	ANA_STIM _CH1_COUNTER_CNT_TH00: 0x5C (General Register)	198
13.8.14.	ANA_STIM _CH_COUNTER_CNT_TH01: 0x5D (General Register)	198
13.8.15.	ANA_STIM _CH_COUNTER_CNT_TH02: 0x5E（General Register)	198
13.8.16.	ANA_STIM _CH_COUNTER_CNT_TH03: 0x5F (General Register)	199
13.8.17.	ANA_INTR_STIMU_STS: 0x60 (General Register)	199
13.8.18.	ANA_INT_COMP_STS: 0x61General Register)	200
13.8.19.	ANA_INT_LVD_STS: 0x62 (General Register)	201
13.9.	TSC registers	201
13.9.1.	TSC_VDAC_NOR: 0x69 (General Register)	201
13.9.2.	TSC_SMP_STS: 0x6A (General Register)	201
13.9.3.	TSC_EN_REG_CTRL: 0x6B (General Register)	201
13.9.4.	TSC_CTRL: 0x6C (General Register)	201
13.9.5.	SMP_DURATION: 0x6D (General Register)	202
13.9.6.	STABLE_DURATION: 0x6E-0x6F (General Register)	202
13.9.7.	TSC_VDAC8B_DIN_CH1: 0x70 (General Register)	202
13.9.8.	TSC_INT_CTRL: 0x71 (General Register)	202
13.9.9.	TSC_INT_ STATUS: 0x72 (General Register)	202
13.10.	General Interrupt Registers	203
13.10.1.	GENERAL_INTERUPT_STATUS_REG07-08 : 0x73-0x74 (General Register)	203
13.10.2.	GENERAL_INTERUPT_STATUS_REG09-0A: 0x75-0x76 (General Register)	203
13.10.3.	GENERAL_INTERUPT_STATUS_REG0B (General Register)	203
13.10.4.	GENERAL_INTERUPT_CTRL_REG: Offset:0x78 (General Register)	204
13.10.5.	GENERAL_INTERUPT_STATUS_REG01: 0x79 (General Register)	204
13.10.6.	GENERAL_INTERUPT_STATUS_REG02: 0x7A (General Register)	205
13.10.7.	GENERAL_INTERUPT_STATUS_REG03: 0x7B (General Register)	206
13.10.8.	GENERAL_INTERUPT_STATUS_REG04: 0x7C (General Register)	207
13.10.9.	GENERAL_INTERUPT_STATUS_REG05: 0x7D (General Register)	209
13.10.10.	GENERAL_INTERUPT_STATUS_REG06: 0x7E (General Register)	210
13.10.11.	GENERAL_INTERUPT_STATUS_REG04: 0x7C (General Register)	211
13.11.	PINMUX registers	212
13.11.1.	ATM_HC_SEL: Offset Address: 0x7F	212
13.12.	DEBUG registers	212
13.12.1.	COUNTER_CNT_DBG_SEL: 0x80 (General Register)	212
13.12.2.	COUNTER_CNT_DBG: 0x81-0x84 (General Register)	212
13.12.3.	LEAD_OFF_COUNTER_CNT_DAC: Lead Off DAC counter for level 0x85 (General Register)	212
13.12.4.	OTP_TRIMS_DBG_SEL: 0x87 (General Register)	213
13.12.5.	OTP_TRIMS_DBG_DATA: 0x88 (General Register)	213
13.13.	EEG Register	213
13.13.1.	IMEAS_REG_0: 0x90 (Normal Register)	213
13.13.2.	IMEAS_REG_1: 0x91 (Normal Register)	214
13.13.3.	IMEAS_REG_2: 0x92 (Normal Register)	215
13.13.4.	STABLE_TIME: 0x93-0x94 (Normal Register)	215
13.13.5.	IMEAS_DATA: 0x95-0x98 (Normal Register)	215
13.13.6.	IMEAS_CTRL: 0x99 (Normal Register)	215
13.13.7.	IMEAS_EN_DIS_CH: 0x9A-0x9B (Normal Register)	216
13.13.8.	FILTER_HPF_BP: 0xB1-0xB2 (Normal Register)	216
13.13.9.	FILTER_LPF_BP: 0xB3-0xB4 (Normal Register)	216
13.13.10.	FILTER_NOF_BP: 0xB5-0xB6 (Normal Register)	217
13.13.11.	FILTER_INT_CTRL: 0xB7 (Normal Register)	217
13.13.12.	FILTER_INT_STS: 0xB8 (Normal Register)	217
13.13.13.	FILTER_NOTCH_DATA_GONE: 0xB9-0xBA (Normal Register)	218
13.13.14.	FILTER_COEFF_ADDR: 0xBB (Normal Register)	218
13.13.15.	FILTER_COEFF_DATA: 0xBC - 0xBE (Normal Register)	218
13.14.	FILTER SYNC CTRL Registers	218
13.15.	NIRS Registers	219
13.15.1.	NIRS_CTRL_CHANNEL: 0x00 (NIRS register)	219
13.15.2.	NIRS_CTRL_LED: 0x01 (NIRS register)	219
13.15.3.	NIRS_CTRL_0: 0x02 (NIRS register)	220
13.15.4.	NIRS_CTRL_1: 0x03 (NIRS register)	221
13.15.5.	NIRS_CTRL_2: 0x04 (NIRS register)	221
13.15.6.	NIRS_CTRL_3: 0x05 (NIRS register)	222
13.15.7.	NIRS_CTRL_4: 0x06 (NIRS register)	222
13.15.8.	NIRS_CTRL_5: 0x07 (NIRS register)	222
13.15.9.	NIRS_CTRL_6: 0x08 (NIRS register)	222
13.15.10.	NIRS_CTRL_7: 0x09 (NIRS register)	222
13.15.11.	NIRS_CTRL_8: 0x0A (NIRS register)	223
13.15.12.	NIRS_CTRL_MODE: 0x0B (NIRS register)	223
13.15.13.	NIRS_CTRL_INT: 0x0C (NIRS register) – Applied for both LED	224
13.15.14.	NIRS_CTRL_ADJ0: 0x0D (NIRS register) – ALL channels and LEDs work on the same setting!	224
13.15.15.	NIRS_CTRL_CLK: 0x0E (NIRS register) - PPG CLOCK – ALL channels and LEDs work on the same setting!	225
13.15.16.	NIRS_CTRL_CMD: 0x0F (NIRS register)	226
13.15.17.	01: START	226
13.15.18.	10: MEAS – MCU mode only	226
13.15.19.	11: STOP – CONTINOUS mode only	226
13.15.20.	NIRS_DEBUG_SEL 0x10 (NIRS register) - Virtual memory approach	226
13.15.21.	NIRS_DEBUG_0 0x11 (NIRS register)	226
13.15.22.	NIRS_DEBUG_1 0x12 (NIRS register)	227
13.15.23.	NIRS_DEBUG_2 0x13 (NIRS register)	227
13.15.24.	NIRS_DEBUG_3 0x14 (NIRS register)	227
13.15.25.	NIRS_DEBUG_4: 0x15  (NIRS register)	227
13.15.26.	NIRS_INT_STATUS 0x20 (NIRS register)	228
13.15.27.	NIRS_DOUT0_0 0x21 (NIRS register)	228
13.15.28.	NIRS_DOUT0_1 0x22 (NIRS register)	228
13.15.29.	NIRS_DOUT0_2 0x23 (NIRS register)	228
13.15.30.	NIRS_DOUT0_3 0x24 (NIRS register)	229
13.15.31.	NIRS_DOUT1_0 0x25 (NIRS register)	229
13.15.32.	NIRS_DOUT1_1 0x26 (NIRS register)	229
13.15.33.	NIRS_DOUT1_2 0x27 (NIRS register)	229
13.15.34.	NIRS_DOUT1_3 0x28 (NIRS register)	229
13.15.35.	NIRS_DOUT2_0 0x29 (NIRS register)	229
13.15.36.	NIRS_DOUT2_1 0x2A (NIRS register)	230
13.15.37.	NIRS_DOUT2_2 0x2B (NIRS register)	230
13.15.38.	NIRS_DOUT2_3 0x2C (NIRS register)	230
13.15.39.	NIRS_DOUT3_0 0x2D (NIRS register)	230
13.15.40.	NIRS_DOUT3_1 0x2E (NIRS register)	230
13.15.41.	NIRS_DOUT3_2 0x2F (NIRS register)	230
13.15.42.	NIRS_DOUT3_3 0x30 (NIRS register)	231
13.15.43.	NIRS_DOUT4_0 0x31 (NIRS register)	231
13.15.44.	NIRS_DOUT4_1 0x32 (NIRS register)	231
13.15.45.	NIRS_DOUT4_2 0x33 (NIRS register)	231
13.15.46.	NIRS_DOUT4_3 0x34 (NIRS register)	231
13.15.47.	NIRS_DOUT5_0 0x35 (NIRS register)	232
13.15.48.	NIRS_DOUT5_1 0x36 (NIRS register)	232
13.15.49.	NIRS_DOUT5_2 0x37 (NIRS register)	232
13.15.50.	NIRS_DOUT5_3 0x38 (NIRS register)	232
13.15.51.	NIRS_DOUT6_0 0x39 (NIRS register)	232
13.15.52.	NIRS_DOUT6_1 0x3A (NIRS register)	232
13.15.53.	NIRS_DOUT6_2 0x3B (NIRS register)	233
13.15.54.	NIRS_DOUT6_3 0x3C (NIRS register)	233
13.15.55.	NIRS_DOUT7_0 0x3D (NIRS register)	233
13.15.56.	NIRS_DOUT7_1 0x3E (NIRS register)	233
13.15.57.	NIRS_DOUT7_2 0x3F (NIRS register)	233
13.15.58.	NIRS_DOUT7_3 0x40 (NIRS register)	234
13.16.	AWG Register	234
13.16.1.	AWG_CONFIG_REG0: 0x02 (AWG Register)	234
13.16.2.	AWG_CTRL_REG0: 0x03 (AWG Register)	234
13.16.3.	AWG_POINT_CONFIG_REG: 0x04 (AWG Register)	235
13.16.4.	AWG_IN_WAVE_ADDR_REG: 0x01 (AWG Register)	236
13.16.5.	AWG_IN_WAVE_REG: 0x00 (AWG Register)	236
13.16.6.	AWG_REST_CLK_REG: 0x05~0x07 (AWG Register)	237
13.16.7.	AWG_SILENT_CLK_REG: 0x08~0x0B (AWG Register)	237
13.16.8.	AWG_POS_PHASE_CLK_PNT_REG: 0x0C~0x0D (AWG Register)	237
13.16.9.	AWG_NEG_PHASE_CLK_PNT_REG: 0x0E~0x0F (AWG Register)	237
13.16.10.	AWG_REST_CLK1_REG: 0x10~0x11 (AWG Register)	237
13.16.11.	AWG_SILENT_CLK1_REG: 0x12~0x15 (AWG Register)	237
13.16.12.	AWG_POS_PHASE_CLK_PNT1_REG: 0x16~0x17 (AWG Register)	238
13.16.13.	AWG_NEG_PHASE_CLK_PNT1_REG: 0x18~0x19 (AWG Register)	238
13.16.14.	AWG_REST_CLK2_REG: 0x1A~0x1B (AWG Register)	238
13.16.15.	AWG_SILENT_CLK2_REG: 0x1C~0x1F (AWG Register)	238
13.16.16.	AWG_POS_PHASE_CLK_PNT2_REG: 0x20~0x21 (4 AWG Register)	238
13.16.17.	AWG_NEG_PHASE_CLK_PNT2_ REG: 0x22~0x23 (4 AWG Register)	238
13.16.18.	AWG_DELAY_LIM_REG: 0x24~0x25 (AWG Register)	239
13.16.19.	AWG_NEG_SCALE_REG: 0x26 (AWG Register)	239
13.16.20.	AWG_NEG_OFFSET_REG: 0x27 (AWG Register)	239
13.16.21.	AWG_POS_SCALE_REG: 0x28 (AWG Register)	239
13.16.22.	AWG_POS_OFFSET_REG0: 0x29 (AWG Register)	239
13.16.23.	AWG_DEBOUNCE_REG (Old Name: ADDR_WG_DRV_PULLBA_REG): 0x2A (AWG Register)	239
13.16.24.	AWG_INT_NUM_WAVE_REG: 0x2B (AWG Register)	240
13.16.25.	AWG_INT_REG: 0x2C~0x2E (AWG Register)	240
13.16.26.	AWG_ALT_LIM_REG: 0x2F~0x30 (AWG Register)	240
13.16.27.	AWG_ALT_SILENT_LIM_REG: 0x31~0x32 (AWG Register)	241
13.16.28.	AWG_ALT_REST_LIM_REG: 0x33~0x34 (AWG Register)	241
13.16.29.	DRIVE_REG_CTRL0: Offset: 0x35 (AWG Register)	241
13.16.30.	DRIVE_REG_CTRL1: Offset: 0x36 (AWG Register)	241
13.16.31.	DRIVE_REG_CTRL2: Offset: 0x37 (AWG Register)	242
13.16.32.	NO_OF_NUM_SLIENT_CTR0: Offset: 0x38 (AWG Register)	242
13.16.33.	NO_OF_NUM_SLIENT_TAR_LSB: Offset: 0x39 (AWG Register)	242
13.16.34.	NO_OF_NUM_SLIENT_TAR_MSB: Offset:0x3A (AWG Register)	242
13.16.35.	ADDR_IS_VALID_FOR_CAL: Offset: 0x3B (AWG Register)	243
13.16.36.	EMS_REG_CTRL: Offset: 0x3C (AWG Register)	243
13.16.37.	EMS_REG_NUM: Offset: 0x3D (AWG Register)	244
13.16.38.	AWG_DRIVEC_SW_CFG: Offset: 0x3E ~ 0x3F (AWG Register)	244
13.16.39.	AWG MAP	247
14.	EEG FILTER	248
14.1.	Block Diagram	248
14.2.	Interface Table	249
14.3.	Timing Sequence	249
14.3.1.	One shot conversion mode	249
14.3.2.	Channel continuous conversion mode	250
14.4.	Integer Multiple Decimation of Signal	251
14.5.	CIC Decimation Filter Design	254
14.5.1.	Four-stage CIC Decimation Filter	254
14.5.2.	Digital Filter Technical Index	256
14.5.3.	Maximum Register Growth in CIC Decimator	258
14.6.	CIC Decimation Filter RTL Implementation	261
14.7.	Filter Wrapper	263
14.7.1.	Overview	263
14.7.2.	Data Rate	264
14.7.3.	Disable Filter	264
14.7.4.	Interrupt	264
14.7.5.	Unstable time for filter	265
14.7.6.	Low-Pass Filter	266
14.7.7.	Stopband_Notch Filter(50HZ)	269
14.7.8.	High-pass filter	273
15.	Data Acquisition	282
15.1.	Start Mode	282
15.2.	Data Ready (DRDY)	282
15.3.	Data Retrieval	282
15.4.	Single-Shot Mode	282
15.5.	Continuous Conversion Mode	283
15.6.	Multiple-Device Configuration	283
15.6.1.	Cascade Configuration	284
15.6.2.	Daisy-Chain Configuration	284
16.	PPG controller	286
APPENDIX	301
Stimulation parameters	301
Stimulation channel	301
Waveform example	301





 Overview
 
The ENS2 is a single chip stimulating device. It integrates the SPI interface with an integrated battery charger circuit, power supply switcher, and a high-compliance stimulation block. The ENS2 can be utilized in targeted applications with minimal off-chip components. The stimulate block is designed to drive anodic and cathodic stimulation currents pulses up to 60mA. Two channels (four electrodes) of drivers are available on this device. The ENS2 generates multiple stimulation patterns to support various applications. The system can be configured to support intermediate frequency physiotherapy, conventional TENS, Muscle Rehabilitation, and implantable stimulation.
The ENS2 is a low-power, multichannel, simultaneously-sampling, 24-bit delta-sigma (ΔΣ) Analog-to-Digital converters (ADCs) with integrated programmable gain amplifiers (PGAs). it incorporates various ECG-specific functions that make them well-suited for scalable electrocardiogram (ECG), electroencephalography (EEG), and electromyography (EMG) applications. it is also used in high performance, multichannel data acquisition systems by powering down the ECG-specific circuitry.
The ENS2 is also an ultra-low power, low-voltage programmable analog front-end PPG chip.

Applications
	Muscle Strengthening and Weak Muscle Rehabilitation.
	Intermediate Frequency Physiotherapy.
	Deep Brain Stimulation.
	Spinal Cord Stimulation.
	Cochlear Implant. 
	Medical Instrumentation (ECG, EMG, and EEG): Patient Monitoring; Holter, Event, Stress, and Vital Signs Including ECG, AED, Telemedicine Bi-spectral Index (BIS), Evoked Audio Potential (EAP), Sleep Study Monitor.
	Heart rate and blood oxygen monitoring.

Features
	Operation temperature range: -40℃ to 85℃
	Operating voltage range: 2.7V to 5.5V
	Input-referred noise: 0.9 µV (0.1-100 Hz) 
	Memories
	32x32 bit OTP memory
	Clocks 
	HSI RC 8MHz 
	Up to 8MHz external clock
	Low power mode
	Sleep mode
	Low-power run mode
	16 Middle-Range Drivers (16 electrodes) (8 Stimulator) (Max 60V) 
	0~60 mA output current, 8 bits
	10~1000 uS pulse width
	1~10 KHz stimulation frequency
	Square, triangular and sine stimulation waveform
	Can be used for DBS, SCS 
	Arbitrary waveform generation powered by an intelligent driver controller. 
	Support simultaneous stimulation 
	Peripheral analog circuits
	Power-on/Power down reset (POR/PDR)
	Low Voltage Detector (LVD)
	24-bit delta-sigma (ΔΣ) ADC 
	Low drop-out regulator (LDO) 
	Transimpedance amplifier (TIA) 
	Precision amplifier 
	GPIOs
	PGAs 
	PPG
	Multiple ADC clock schemes: 3.9Khz, ..., 0.5Mhz, 1Mhz, 2Mhz, 4Mhz, 8MHz
	OSR: 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768, 65536 
	Data Rate: 1 SPS to 1000000 SPS
	Max Effective Number of Bits (ENOB): 22 for OSRmax= 65536 
	Built-In Right Leg Drive Amplifier (RLD), Lead-Off/Short Detection
	Internal or external Reference
	High CMRR: ≥ 110 dB 
	Programmable low pass filter: 8-10000 Hz 
	High pass filter: 0.1-0.5Hz 
	50/60 Hz notch filter 
	Input impedance: ≥ 1GΩ 
	High dynamic range fNIRS module 
	Analog ambient current cancellation scheme
	Rail-to-rail electrode offset rejection 
	Tolerant to common mode interference 
	SPI™-Compatible Serial Interface


Block Diagram
Figure 1 Top Level Block Diagram

 

 

	

	
	

Pin Description
Pin and Package definition 
Table 1 Interface Signal Table
Pin Number	Pin Name	Pin Type	Pin Function	Description
1	iopad_testmode0	CTRL	Test Mode 0 Selection	{iopad_testmode1, iopad_testmode0}
00: Normal mode
01: Scan mode
10: BIST mode
11: CP test mode
2	iopad_testmode1	CTRL	Test Mode 1 Selection	
3	VDD_DIG	PWR	DIG VDD	1.8V VDD for digital core
4	VSS_DIG	GND	DIG VSS	VSS for digital core
20:5	IOBUF_PAD [15:0]	I/O	I16 PADS of GPIO	I/O pads
21	VDD_IO	PWR	VDD IO	3-5V I/O power supply 
22	VSS_IO	GND	VSS IO	I/O ground
23	CLKSEL	CTRL	Clock Selection	0: Internal clock
1: External clock
24	RESETn	RESET	Reset Pin	External reset
25	VPP	PWR	VPP for OTP	OTP VPP
26	CLK	Clock	External Master clock input	
27	DAISY_IN	CTRL	Daisy-chain input; if not used, short to DGND	



Power-up sequence

 
 
 
 
 

System Control Unit (SCU)
This block contains the clock control, reset control and PMU.
PMU (Power Management Unit)
This unit has a state machine which will manage putting the modules into clock gating mode and returning from clock gating mode. 
SPI register bit “SLEEP_DEEP_EN” can put the modules into clock gating mode. Once in this mode, the FCLK from above clock control module will be disabled. SPI register bit hresetq can wake up the modules returning to normal model from the clock gating mode.  
Reset Control
In this block, OTP reset and the normal reset have their own POR timers, respectively. The final POR after timer will be synchronized with different clocks such as hfosc_atpg, FCLK and pclk and will generate different reset signals of poresetn_hf, poresetn and present respectively. Same for the OTP reset.
ENS2 reset control includes the control of two kinds of reset, power reset, and system reset. The power-on reset, known as a cold reset, resets the full system during a power up. A system reset resets the internal modules.
Power reset is generated by Power-on Reset and Power Down Reset (POR/PDR reset). The power reset sets all registers to their reset values. The power reset which active signal is low will be de-asserted when the internal LDO voltage regulator is ready to provide 1.8V power. 
A system reset is generated by the following events:
	Power on reset
	External reset pin
	Reset register
	 



Clock Control
Clock Tree Structure
Two different clock sources can be used:
	HSI RC - a high-speed fully integrated RC oscillator producing HSI clock (up to 8MHz)
	HSE - a high-speed external clock (up to 8MHz)
 
The clock tree structure as below: 
 

Figure 3 Clock Tree
 
One of the following clocks can be selected as system clock:
	HSI
	HSE
The system clock maximum frequency is 8MHz. Upon system reset, the HSI clock is selected as a system clock.
HSE clock is directly coming from IO cell pin GPIO0/EXT_CLK. For HIS to be activated, another IO cell pin called CLK_SEL needs to be activated (default pulled down to 0, which means by default system clock is used)
If it is required to output an internal OSC clock from pin GPIO9 in normal mode (for multi-chip scenario for example), SPI register bit O_INT_CLK_OUT in CLK_CTRL_REG (0x02) can set to 1 (default 0). Direct access through GPIO10 is also available.
Interrupt Sources to INTB Pin

Diagram
 
Interrupt Source Table
(*1) For example, 0x82/0x28 means that this status is located at the General Interrupt Status Register (0x82) and IP Interrupt Status Register (0x28).
General Interrupt Status Registers (0x81 and 0x82) are designed as a high-level layer of chip system which helps Users to read one burst length of 2 to address 0x81 and 0x82 whenever MCU detects the interrupt from INTB Pin.  
MCU can select R1C* (Read 1 to clear) or RW1C* (Write 1 to clear). It helps User not to need to clear.
MCU can configure INTB to be Pulse Active or Level Active. In case of Pulse, MCU detects INTB without clearing INTB if required.
INTB can be selected as Low Active or High Active.
Note: for R1C, 3 PCLKs is needed between two SPI read commands

Interrupt Source Names (IP Name)	Register Enable Address	Register Status Address (*1)	Clear Condition	Output to INTB
I_WG_DRIVER_INT_STS[0][0]	0x28
(AWG Register)	0x82/0x28	RW1C*/R1C*	YES
I_WG_DRIVER_INT_STS[0][1]	0x28
(AWG Register)	0x82/0x28	RW1C*/R1C*	YES
I_WG_DRIVER_INT_STS[1][0]	0x68
(AWG Register)	0x82/0x68	RW1C*/R1C*	YES
I_WG_DRIVER_INT_STS[1][1]	0x68
(AWG Register)	0x82/0x68	RW1C*/R1C*	YES
ANA_LVD_INTR_STS	0x52
(General Register)	0x81/0x53	Can't be clear	YES
ANA_COMP_CH1_INTR_STS	0x52
(General Register)	0x81/0x53	RW1C*/R1C*	YES
ANA_COMP_CH2_INTR_STS	0x52
(General Register)	0x81/0x53	RW1C*/R1C*	YES
ANA_STIMU_CH1_INTR_STS	0x54
(General Register)	0x81/0x60	RW1C*/R1C*	YES
ANA_STIMU_CH2_INTR_STS	0x54
(General Register)	0x81/0x60	RW1C*/R1C*	YES
LEAD_OFF_CH1_STATUS	0x3A
(General Register)	0x81/0x3A	RW1C*/R1C*	YES
LEAD_OFF_CH2_STATUS	0x30
 (General Register)	0x81/0x30	RW1C*/R1C*	YES
TSC_INT_STATUS	0x88
 (General Register)	0x81/0x89	RW1C*/R1C*	YES
Serial Peripheral Interface (SPI)
 
Overview
In ENS2 project, the off-chip SPI Master can configure the ENS2 Registers and read the ENS2 waveform generator registers through this SPI Interface. Where this SPI top has the SPI register block which is used to store the configuration values of the Register as well as its system status values. The registers in the register block can be read/write through the SPI slave controller which provides the SPI protocol compatibility for the SPI register access. SPI Controller supports burst read write.
Block Diagram
                                           Figure ‎71. SPI Slave Block Diagram
  
Functional Description
SPI controller will receive the SPI command formats from the SPI master and based on the command format it can write/read the data from the register block and send it to the SPI Master.
The command format to access the registers is single write/burst write, single read, burst read command where the SPI Slave controller will automatically increment the register access address in burst mode.  
Interface
Table ‎11. SPI top Interface
IO	Direction	Bits	Definition
Off chip SPI interface
I_CS	Input	1	Chip select from SPI Master
I_SCLK	Input	1	SPI clock from SPI Master
 I_MOSI	Input	1	SPI Master out slave input. (Line for the Master to send data to the Slave.)
O_MISO	Output	1	SPI Master in slave output. (Line for the slave to send data to the master).
Internal system I/F
I_rst_n	Input	1	System reset
I_scanclk	Input 	1	Scan Clock
SCANMODE	Input	1	Scan mode enable input
Waveform generator
i_wg_driver _in_wave_ addr	Input 	8bits *8	Address for reading the next 8 bits of the output wave values from the register file of SPI where the wave values are stored. Each half wave is 64 points, each point 8 bit between 0 and 255.
i_wg_driver_source	Input 	2bits*8	bit 0: source a
bit 1: source b 
i_wg_driver_int_sts	Input 	2bits*8	Address interrupt
o_wg_driver_en	output	1bit*8	Coming from SPI registers for enabling the wave gen block
o_wg_drivera_en	output	1bit*8	Coming from SPI registers for enabling drive A
o_wg_driverc_en	output	1bit*8	Coming from SPI registers for enabling drive C
o_config_reg	output	8bit*8	bit-0: Rest Enable
bit-1: Negative Enable, 
bit-2: Silent Enable, 
bit-3: Source B Enable, 
bit-4: Alternating (+/-) positive side. 
bit-5: Continue repeating the waveform if one works together with interrupt if zero 
bit-6: Multi-Electrode. 
o_wg_driver_rest_t	output	16bit*8	Resting time (in microseconds) between the positive side and the negative side of the wave in a period. 

Driver A (pulse modes) = 0 to 200 us. 
o_wg_driver_silent_t	output	32bit*8	Silent time (in microseconds) before the next wave period. 

Driver A, constant mode: (4,000 – 100) us to (500,000 – 100) us. 
Driver A, sweep mode: (4,000 – 100) us to (1,00,000 – 100) us. 
Driver A, burst mode: (142,000 (7 Hz) – 100) us to (500,000 – 100) us. 
Driver C: (100 (10 KHz) – 60) us to (1,000,000 (1 Hz) – 60) us.
o_wg_driver_hlf_wave_prd	output	32bit*8	Half of the period of the arbitrary (e.g., sine or square) wave (in microseconds). 

Driver A (pulse modes): 50 to 400 us. 
Driver A (IFT mode, sine wave): 100us to 500us. 
Driver A (EMS mode): 4,000 us (250Hz) to 500,000us (20 Hz).  
Driver C: 20us to 1000us.
 
o_wg_driver_neg_hlf_wave_prd	output	32bit*8	tNegative half of the period of the arbitrary (e.g., sine or square) wave (in microseconds). Values same as hlf_wave_per
 
o_wg_driver_alter_lim	output	16bit*8	Number of clocks for a period of alternating signal. Driver A (EMS mode) for each clock values change. 

32 MHz: 3,200 (10 KHz) to 16,000 (2 KHz). 
1 MHz: 100 (10 KHz) to 500 (2 KHz). (1000 us). 1 MHz: 20 (20 us) to 1000 (1000 us). 
 
o_wg_driver_alter_silent_lim	output	16bit*8	Number of clocks for each silent duration for the alternating frequency. Range is not clear right now. Will be fixed after system level verification.
 
o_wg_driver_delay_lim	output	16bit*8	Number of clocks for initial delay after the reset is disabled and before the waves are generated. Range is not clear right now. Will be fixed after system level verification.
 
o_wg_driver_isel	output	3bit*8	Current select value 
o_wg_driver_sw_config	output	8bit*8	Switch selection for the electrode. 
Which switch(es) should be used for this electrode. 
Bit 0: switch 0 is used for the electrode. 
Bit 1: switch 1 is used for the electrode and so on. Combination of bits can be used
o_mult_elec	output	1bit*8	Allow multiple electrodes to be active at the same time
o_wg_driver_in_wave	output	8bit*8	Next half wave point value to be written to the address specified by AWG_DRV_IN_WAVE_ADDR_ REG. Total half wave is 64 points, each point 8 bit between 0 and 255. 
o_wg_driver_int_addr0	output	8bit*8	Interrupt Address 0
o_wg_driver_int_addr1	output	8bit*8	Interrupt Address 1
o_wg_driver_int_en	output	1bit*8	Interrupt Enable
o_addr0_int_clr	output	1bit*8	Clear the Interruption of Address 0
o_addrz_int_clr	output	1bit*8	Clear the Interruption of Address 0
 
SPI Slave Controller Specification
SPI Slave Controller Features:
          * 8-bit data length format
          * Support SPI MODE 0/1/2/3
          * Support write/write burst command
          * Support read/read burst command
          * Support waveform generator command 
          * Support nirs command 
Communication:
The master transmits the data to the slave via the MOSI (Master Output, Slave Input line) and receives data from the slave via the MISO (Master Input, Slave Output line). SPI communication is always initiated by the master by making Chip Select to be Low and sending the SCLK (Clock) to the SPI Slave. For successful data transmission, the SPI Master and SPI Slave should agree upon clock frequency, Clock Polarity (CPOL), and Clock Phase (CPHA) where this CPOL and CPHA are two properties work together to define when the bits are output and when they are sampled.  The SPI Slave controller’s CPOL and CPHA are fixed. They are not configurable, so it’s SPI Master responsibility to send the Data’s based upon the agreed mode between the SPI Master and SPI Slave.
This SPI Slave controller works in 4 modes as the following table.
 SPI Modes:
	Clock polarity: 
	0: SCK to 0 when idle
	1: SCK to 1 when idle        

	Clock phase:
	0: Data sampled on the leading edge of each clock pulse
	1: Data sampled on the trailing edge of each clock pulse

Mode	CPOL	CPHA	Clock Idle	SPI master & SPI slave latch data on	SPI master & SPI slave send out data on
0	0	0	Low	Rising edge	Leading edge	Falling edge
1	0	1	Low	Falling edge	Trailing edge	Rising edge
2	1	0	High	Falling edge	Leading edge	Rising edge
3	1	1	High	Rising edge	Trailing edge	Falling edge

                                                                                

 
                                                        Figure ‎52. SPI modes

When the data frame transfer is complete (all the bits are shifted), the information between the master and slave is exchanged.
 Data communication format between Master and Slave
The SPI Slave Controller communicates with a SPI master by using the RD/WR cycle format.
	32-bit Write Frame Format
	WR_ADDR (7:0) + INSTRUCTION (7:0) + WR_DATA (7:0) + PADDING_BITS (7:0)
	24-bit Read Frame Format
	 RD_ADDR (7:0) + INSTRUCTION (7:0) + PADDING_BITS (7:0) 

 Table ‎52. Instruction Structure
7	6 	5 	4	3 	2 	1	LSB (0)
WR_RD_CMD	DATA_SEL	RESERVED	RESERVED	BURST	DUAL_EN

Bit 7           WR_RD_CMD 
                      	1 => Write Mode
                      	0 => Read Mode
Bit 6:4         DATA_SEL
                      	0XX: RESERVED
		100: RDATA_EN
		101: RDATAC_EN
		110: WG_EN
		111: NIRS_EN
Bit:4            RDATAC_EN – Multiple chip
                       1 => Enable RDATAC - (RDATA_EN will be on automatically)
   (RDATA_EN = 1 before setting this bit - OLD)
                       0 => Disable RDATAC
Bit 3:2         RESERVED
Bit 1            BURST_EN
                       1 => Burst Mode
                       0 => Single Mode
Bit 0	        DUAL MODE EN
                     Bit 7
Bit6:4	0	1
0XX	Read General Register	Write General Register
110	Read Waveform generator register	Write Waveform generator register
111	Read NIRS generator register	Write NIRS generator register

 
Decode for Dual SPI CMD only

 Write cycle:
Whenever Master wants to write into the registers of the SPI Register Block. Master initiates the Transmission by making Chip Select (CSn) to be Low level and supply the SCLK, then send’s the 4 bytes of write cycle data on MOSI. 
The write cycle data contains 8-bit Write Instruction followed by 8-bit WR_ADDR, 8-bit WR_DATA and 8-bit PADDING bits.
     Figure ‎43. Write Cycle
The SPI slave controller will sample write cycle data and send the WR_ADDR, WR_DATA, set REG_TYPE_ACCESS (0: General Registers, 1: AWG Registers) to the SPI Register block.
(During 1st SCLK the CSn and MOSI will be latched to the internal latches (cs_n, mosi_d), on the 2nd SCLK the mosi_d data will be latched to the rx_buffer), padding bits are added to provide the SCLK, to output the data which is received from the master as it’s in the miso line during the full duplex mode).
In full duplex mode, the MISO line will output doesn’t care during the instruction phase, and instruction on WR_ADDR phase, and WR_ADDR in the first padding bit phase, and WR_DATA in the 2nd padding bit phase.
 Write burst:
 For register burst write access, additional groups of 8 SCLK cycles are applied after the initial 24 cycles which will be followed by 8 padding bits. The register address is automatically incremented after the 24th SCLK cycle and after each subsequent group of 8 SCLK cycles. The data bytes received after the first 24 SCLK cycles are sequentially written to their automatically calculated address. Therefore, if a transaction is (24 + (8 x N) SCLK cycles long, N + 1 adjacent registers are written starting at the address specified by the first byte.
 Figure 44. SPI write burst
Whenever SPI Master wants to read from the registers in the SPI Register block. SPI Master initiates the Transmission by making chip select (cs_n) low and supply the SCLK, then send’s the 3-byte of Read Cycle Data on MOSI.
Where The Read Cycle Data contains an 8-bit Read Instruction which will be followed by 8-bit RD_ADDR, and 1-byte of PADDING bits.
 Figure 45‎. Single Read cycle
SPI Slave controller samples the read cycle data and sends RD_ADDR and read enable command to SPI Register block during the first 2 phases of the read cycle, during the last phase (PADDING bytes-1) outputs the data read from SPI Register block through MISO line.    
Single-byte register read transactions fetch the requested data before the 16th SCLK rising edge and present the MSB of the requested data on the following SCLK falling edge, allowing the Microcontroller to latch the data MSB on the 17th SCLK rising edge. To conclude the transaction, CSn is de-asserted after the 24th SCLK rising edge.
 
 
Read Burst:
For a register burst read access, additional groups of 8 SCLK cycles are applied after the initial 24 cycles. The register address is automatically incremented after the 24th SCLK cycle and after each subsequent group of 8 SCLK cycles. The content of those automatically calculated addresses is retrieved each time a new group of 8 SCLK cycles are applied. Therefore, if a transaction is (24 + (8 x N)) SCLK cycles long, N + 1 adjacent registers are read starting at the address specified by the first byte.
 Figure 46. Burst Read cycle

 

RDATA:
Instruction Structure
7	6 	5 	4	3 	2 	1	LSB (0)
WR_RD_CMD	BURST_EN	RDATA_EN	RDATAC_EN	WG_EN	NIRS_EN	RESERVED	RESERVED

Enable bits 6 and 5 to enter RDATA mode, other bits remain 0.
 
Figure 47. Burst Read cycle

Similar to read burst, during the RDATA operation, from SCLK 0 to SCLK 16, the SPI slave decodes the RD_ADDR and CMD signals on the MOSI line. (Figure 46)
At the same time, the MISO line starts transmitting data — beginning with RD_ADDR at SCLK 8.
After SCLK 16, the IMEAS data is sent out.
Each data channel requires 4 bytes to be fully transmitted. 
In addition to the EEG payload, the data packet includes a 40-bit status field. Within this field, the lower 32 bits are allocated to LOFF_STATP and LOFF_STATN in ascending order (from LSB to MSB), while the remaining 8 bits field consists of a 1-bit status flag (stim_on_flag) and 7 reserved bits for feature use. A logic high on stim_on_flag indicates that a stimulation event occurred during the current EEG sampling window. 
 
DAISY READ:
  Enable daisy mode by config bit 4 of register IMEAS_REG_1(0x91) to 1. The following Figure shows the daisy chain configuration. In this configuration, SCLK, DIN, and CS are shared across multiple devices. Connect the MISO pin of the ENS2_1 to the DAISY_IN pin of the ENS2_0, thereby creating a chain. Short the DAISY_IN pin to digital ground if not used. 
 MISO outputs imeas_chdata based on the maximum number of channels (i_channel_max).
ENS2_1 transfers its data to ENS2_0 via DAISY_IN, where the data is stored in a buffer (daisy_buf).
  Once ENS2_0 finishes outputting its own imeas_chdata through MISO, it then continues by outputting the imeas_chdata from ENS2_1, which was previously stored in the buffer.

 
Figure 48. Daisy Connection


 


SPI-Timing Characteristics:
Parameter	Symbol	Conditions	Min	Typ	Max	Units
SCLK Frequency	fSCLK	 -		 -	20	Mhz
SCLK Period	tCP	 -	50.00	 -	 -	ns
SCLK Pulse width High	tCH	 -	20.00	 -	 -	ns
SCLK Pulse Width Low	tCL	 -	20.00	 -	 -	ns
CS fall to SCLK rise Time	tCSSO	 -	20.00	 -	 -	ns
SCLK Fall to CS rise Time	tCSH1	 -	20.00	 -	 -	ns
CS pulse width High	tCSPW	 -	50.00	 -	 -	ns
MOSI to SCLK Rise Setup time	tDS	 -	10.00	 -	 -	ns
MOSI to SCLK Rise Hold Time	tDH	 -	10.00	 -	 -	ns
SCLK Fall to MISO Transition	tDOT	 -	  -	 -	10.00	ns

 
One Time Program 

Introduction 
 
 

 


Architecture 
A functional block diagram of the OTP controller is shown below. 
   
   Top Level Block Diagram 

 Feature List 

 
 
 
Interface 
Name	Direction	Description
clk and reset
clk	I	System CLK
rst_n	I	system reset (active Low)
OTP top
atpg_en	I	ATPG enable
otp_vpp_en	I	VPP enable
hosc_sel	I	Control OTP timing according to different system clock
analog_test_mode	I	 Analog test mode
atm_mode	I	ATM mode
atm_data	I	ATM data
gpio_unlock	I	Unlock from GPIO
Interface define - trim	I	Trims from SPI to OTP
Trim[0]	I	Analog trim tag
Trim[1]	I	Analog trim
Trim[2]	I	Analog trim
Trim[3]	I	Analog trim
Trim[4]	I	Analog trim
Trim[5]	I	Analog trim
Trim[6]	I	Analog trim
Trim[7]	I	Analog trim
Trim[8]	I	Spare register0
Trim[9]	I	Spare register1
Trim[10]	I	Spare register2
Trim[11]	 I	Spare register3
Trim[12]	I	Spare register4
Trim[13]	I	Spare register5
Trim[14]	I	Spare register6
Trim[15]	I	Spare register7
Interface define – so_ctrl	I	Control signals from SPI to OTP
so_ctrl[0]	I	unlock
so_ctrl[1]	I	spi_wr
Interface  define – trim_read	O	Trims from OTP to SPI/PINMUX
trim_read[0]	O	Analog trim tag
trim_read[1]	O	Analog trim
trim_read[2]	O	Analog trim
trim_read[3]	O	Analog trim
trim_read[4]	O	Analog trim
trim_read[5]	O	Analog trim
trim_read[6]	O	Analog trim
trim_read[7]	O	Analog trim
trim_read[8]	O	Analog trim
trim_read[9]	O	Spare register 0
trim_read[10]	O	Spare register 1
trim_read[11]	O	Spare register 2
Interface define – os_ctrl	O
	Control signals from OTP to SPI
os_ctrl[0]
	O	Indicates that OTP is reseted and all OTP values are loaded into SPI register to read
os_ctrl[1]	O	OTP is busy
os_ctrl[17:2]	O	Debug register
os_ctrl[18]	O	Write Status is on going 
 
 
 
 
 
Model and Timing 
 Supported user operating mode 
 
 
 
 
Timing parameters 
  

 Timing waveforms 
 
 
 USER MODE - READ operation timing 
 
 
 
 
 
USER MODE -WRITE operation timing 
 
 
 Function and Registers 
OTP controller (top) is made of otp_regs, otp_rw_ctrl, otp_out_ctrl, and the otp_trim_if, otp_regs block will start reading and writing procedures. During the start-up, it will initiate a read process that reads OTP data into otp_regs’ shadow registers. During a user initiated write command (which starts after setting the unlock input to 1), otp_regs will start a write command where spi_regs are written into OTP and subsequently into shadow registers.  
otp_rw_ctrl is responsible for the state machine that handles the read and write sequences in OTP, that is, exact wait times, read and write timings are used in this block. otp_out_ctrl simply takes the output and input to the main OTP block and translates into otp_rw_ctrl signals. 
Function description 
There are two OTPS for this project, one is used for storing TRIM and filter coefficients (OTP0) and the other is used for storing current calibration coefficients of Wavegens (OTP1)
 Reload function (OTP0)
otp_reg module will load the Trim value or not according to the Trim Tag value after power on automatically, the address of Trim Tag is 0x00 of OTP, there are two cases as below: 
Trim Tag value is not 0x5A 
	After power on, otp_regs read the value that comes from 0x00 of OTP. 
	OTP judges if TRIM_TAG value is 0x5A.  
	In this case, TRIM_TAG is not 0x5A. 
	OTP doesn’t load values from OTP Memory to shadow registers (shadow_regs) and SPI registers (spi_regs).     
Trim Tag value is 0x5A 
	After power on, otp_regs read the value that comes from 0x00 of OTP. 
	OTP judges if TRIM_TAG value is 0x5A.  
	In this case, TRIM_TAG is 0x5A. 
	OTP loads values to shadow_regs/spi_regs. 

Trim Write function for OTP (OTP0)
	Data ready: write the data to spi_reg.
	Write OTP_Unlock register to set KEY-WORD(5’b10101)
	Write OTP_Unlock register to set unlock to high level (keyword is valid)
	Wait OTP_VPP_EN to 1 (connect to PAD, or read via SPI), boost VPP to 7.5V in 20 us.
	Wait OTP_VPP_EN to 0 (connect to PAD, or read via SPI), change back VPP to VDD in 20 us.
	Power down, and power on.
	Read the value that is written in step 2.
	Check whether written data and read data are consistent.
	Clear OTP_Unlock register before next programming

Trim Write function for OTP shadow register (OTP shadow register)
Data ready: writes the Data to SPI registers (SPI Interface)
Configure OTP_Unlock register to set KEY-WORD to 5’b10101
Configure spi_wr register to assert “SPI_WR” to 1’b1. (keyword is valid)
Check whether written data and read data are consistent.


Random SPI Write function for OTP (OTP0, OTP1)
Please note this function can’t access the first 20 addresses(0x00~0x13) of OTP0
 
Address ready:  configure the address to SPI register: OTP_ADDR (0x2B)                
Data ready: configure the data to SPI register: OTP_DATA (0x0C)
Configure OTP_Unlock register to set KEY-DATA (5’b01010)
Configure OTP_Unlock register to assert unlock (Bit0) to high level (key-data is valid)
When OTP_VPP_EN to 1 (connect to PAD, or read via SPI), boost VPP to 7.5V in 20 us (required for programming to OTP)
Wait OTP_VPP_EN to 0 (connect to PAD, or read via SPI), change back VPP to VDD in 20 us.
Read the value that is written in step 2.
Check whether written data and read data are consistent.

Randomize SPI Read Write function (OTP0, OTP1)
Address ready:  write the address to SPI reg: OTP_ADDR (0x0D)
Write OTP_Unlock register to set KEY-DATA (5’b01010)
Write OTP_Unlock register to set unlock (Bit2) to high level (key-data is valid)
Read data

 
 
 
 
 
 
Figure: how pin mux will mux between IO cells and internal connections  
 
ANALOG TRIM BY GPIO 
This function is used to write analog trim to shadow reg and OTP by GPIO in analog test mode, this process is to write the data in the pad in analog test mode to the shadow register, and then use the unlock signal to write the data in shadow register to the OTP 
 Block Diagram 
 
Figure 1 Top Level Block Diagram 

Introduction
   The function is analog trim should be written into shadow reg by GPIO, and when all analog trim values are written into shadow registers, if unlock is 1, then the data in shadow register is automatically written to the corresponding address in the OTP. 
GPIO signal 	GPIO10 	GPIO9 	GPIO8 	TEST_MODE 
ATM0 	0 	0 	0 	Iopad_testmode1 && Iopad_testmode0 
 
ATM1 	0 	0 	1 	
ATM2 	0 	1 	0 	
ATM3 	0 	1 	1 	
ATM4 	1 	0 	0 	
ATM5 	1 	0 	1 	
ATM6 	1 	1 	0 	
ATM7 	1 	1 	1 	
ATM signals and TRIM signals 
atm_mode = {ATM7, ATM6, ATM5, ATM4, ATM3, ATM2, ATM1, ATM0}; 
atm_mode 	analog trim reg 	ATM 
9’h1 	trimdata1 	ATM0 
9’h2 	trimdata2 	ATM1 
9’h4 	trimdata3 	ATM2 
9’h8 	trimdata4 	ATM3 
9’h10 	trimdata5 	ATM4 
9’h20 	trimdata6 	ATM5 
9’h40 	trimdata7 	ATM6 
9’h80 	trimdata8 	ATM7 
  
 TRIM signals and GPIO 
ATM0 
GPIO 	TRIM REG 
iopad_gpio[1] 	 trimdata1 <0> 
iopad_gpio[2] 	 trimdata1 <1> 
iopad_gpio[3] 	 trimdata1 <2> 
iopad_gpio[4] 	 trimdata1 <3> 
iopad_gpio[5] 	 trimdata1 <4> 
iopad_gpio[6] 	 trimdata1 <5> 
iopad_gpio[7] 	 trimdata1 <6> 
 
ATM1 
GPIO 	TRIM REG 
iopad_gpio[1] 	 trimdata2 <0> 
iopad_gpio[2] 	 trimdata2 <1> 
iopad_gpio[3] 	 trimdata2 <2> 
iopad_gpio[4] 	 trimdata2 <3> 
iopad_gpio[5] 	 trimdata2 <4> 
iopad_gpio[6] 	 trimdata2 <5> 
iopad_gpio[7] 	 trimdata2 <6> 
 
ATM2 
GPIO 	TRIM REG 
iopad_gpio[1] 	 trimdata3 <0> 
iopad_gpio[2] 	 trimdata3 <1> 
iopad_gpio[3] 	 trimdata3 <2> 
iopad_gpio[4] 	 trimdata3 <3> 
iopad_gpio[5] 	 trimdata3 <4> 
iopad_gpio[6] 	 trimdata3 <5> 
iopad_gpio[7] 	 trimdata3 <6> 
 
ATM3 
GPIO 	TRIM REG 
iopad_gpio[1] 	 trimdata4 <0> 
iopad_gpio[2] 	 trimdata4 <1> 
iopad_gpio[3] 	 trimdata4 <2> 
iopad_gpio[4] 	 trimdata4 <3> 
iopad_gpio[5] 	 trimdata4 <4> 
iopad_gpio[6] 	 trimdata4 <5> 
iopad_gpio[7] 	 trimdata4 <6> 
 
ATM4 
GPIO 	TRIM REG 
iopad_gpio[1] 	 trimdata5 <0> 
iopad_gpio[2] 	 trimdata5 <1> 
iopad_gpio[3] 	 trimdata5 <2> 
iopad_gpio[4] 	 trimdata5 <3> 
iopad_gpio[5] 	 trimdata5 <4> 
iopad_gpio[6] 	 trimdata5 <5> 
iopad_gpio[7] 	 trimdata5 <6> 
 
ATM5 
GPIO 	TRIM REG 
iopad_gpio[1] 	 trimdata6 <0> 
iopad_gpio[2] 	 trimdata6 <1> 
iopad_gpio[3] 	 trimdata6 <2> 
iopad_gpio[4] 	 trimdata6 <3> 
iopad_gpio[5] 	 trimdata6 <4> 
iopad_gpio[6] 	 trimdata6 <5> 
iopad_gpio[7] 	 trimdata6 <6> 
 
ATM6 
GPIO 	TRIM REG 
iopad_gpio[1] 	 trimdata7 <0> 
iopad_gpio[2] 	 trimdata7 <1> 
iopad_gpio[3] 	 trimdata7 <2> 
iopad_gpio[4] 	 trimdata7 <3> 
iopad_gpio[5] 	 trimdata7 <4> 
iopad_gpio[6] 	 trimdata7 <5> 
iopad_gpio[7] 	 trimdata7 <6> 
 
ATM7 
GPIO 	TRIM REG 
iopad_gpio[1] 	 trimdata8 <0> 
iopad_gpio[2] 	 trimdata8 <1> 
iopad_gpio[3] 	 trimdata8 <2> 
iopad_gpio[4] 	 trimdata8 <3> 
iopad_gpio[5] 	 trimdata8 <4> 
iopad_gpio[6] 	 trimdata8 <5> 
iopad_gpio[7] 	 trimdata8 <6> 
 
ATM8 
GPIO 	TRIM REG 
iopad_gpio[1] 	 trimdata9 <0> 
iopad_gpio[2] 	 trimdata9 <1> 
iopad_gpio[3] 	 trimdata9 <2> 
iopad_gpio[4] 	 trimdata9 <3> 
iopad_gpio[5] 	 trimdata9 <4> 
iopad_gpio[6] 	 trimdata9 <5> 
iopad_gpio[7] 	 trimdata9 <6> 
 
Analog Test Mode Unlock 

Signal 	Test pad 
Analog_test_mode 	 iopad_testmode0_y ==1; 
 iopad_testmode1_y ==1; 
Unlock 	 CLK_SEL 
 
Write shadow register by GPIO 

	Enter analog test mode 
	Select ATMx according to the analog trim that user wants to test 
	Trim data is written by using GPIO 
	Data from the PAD in Test mode is automatically written to the corresponding trim register in otp_regbank for use in analog test mode next time. 

Program the value of shadow reg to OTP 
After all ATM tests are finished, and the validator wants to write data from the shadow register into OTP, then just asserting unlock, the trim value is automatically written to the OTP. 
In summary, every change of IO pad values will immediately go to the OTP shadow registers (if external clock is supplied) and, as a result, will change the analog D2A trim values consequently. Now, if validator is happy with the trim value results, they can unlock, or, without turning off the power, go to the next ATM mode, without losing current OTP shadow register trim values, and continue with the new trim values (which again reflect immediately, after each clock, on the respective shadow registers). Validator can write at the end of each ATM mode or (without powering off and losing previous ATM mode trim values) after the final ATM mode by the OTP UNLOCK IO cells. 
NOTE: trim values of all ATM modes will remain in OTP registers (as long as the chip is powered) and will be written into the OTP, each time UNLOCK is activated, regardless of which ATM step we are at. As a result, if any previous trim values in the memory are not final, do not UNLOCK, otherwise all trim values will be written at once. More specifically, if 1 is written to an OTP bit, it cannot be changed to 0 later. 0, can be written multiple times. 
 VPP timing 
Goes to high after UNLOCK enable: (5+1)~(5+ Otp_tVPP) clocks 
Goes to low after UNLOCK enable: (5+ Otp_tVPP +1 +(Otp_tPGM+4)*12+1)~ (5+ Otp_tVPP +1 +(Otp_tPGM+4)*12+ Otp_tVPP) 
 
PCLK_div 	Otp_tPGM 	Otp_tVPP 	The max time from VPP_EN to VPP HIGH(7.5V)
000 	665 	50	(50+1)*0.5=25.5us;Considering clock uncertainty, multiply by 80%;  25.5 * 0.8 = 20.4us
001 	333 	50	(50+1)*1=51us;Considering clock uncertainty, multiply by 80%;  51 * 0.8 = 40.8us
010 	165 	50	(50+1)*2=102us;Considering clock uncertainty, multiply by 80%;  102 * 0.8 = 81.6us
011 	82 	50	(50+1)*4=204us;Considering clock uncertainty, multiply by 80%;  204* 0.8 = 163.2us
100 	41 	50	(50+1)*8=408us;Considering clock uncertainty, multiply by 80%;  408* 0.8 = 326.4us
101 	20 	25	(25+1)*16=416us;Considering clock uncertainty, multiply by 80%;  416 * 0.8 = 332.8us
110 	9 	12	(12+1)*32=416us;Considering clock uncertainty, multiply by 80%;  416 * 0.8 = 332.8us
111 	4 	6	(6-+1)*64=446us; Considering clock uncertainty, multiply by 80%;  446 * 0.8 = 358.4us

Registers 
 Register Map 
OTP address 	SPI address 	Type 	Default (OTP) 	Name 	ANALOG NAME 
  	0x0A	R 	0x00	debug1 	 
  	0x0B	R 	0x00 	debug2 	 
0x00 	0x0C	RW 	0x5A 	Trim tag 	 TRIM TAG
0x01-0x03 	- 	- 	- 	Trim tag(0x000000) 	- 
0x04 	0x0D	RW 	0x00	Analog trim1 	D2A_BG_TRIM 
0x05 	0x0E	RW 	0x00	Analog trim2 	D2A_IREF_TRIM 
0x06 	0x0F	RW 	0x00	Analog trim3 	D2A_CLDO1P8_TRIM 
0x07 	0x10	RW 	0x00	Analog trim4 	D2A_OSC8MHZ_TRIM 
0x08 	0x11	RW 	0x00	Analog trim5 	D2A_BGBUFFER_TRIM
0x09 	0x12	RW 	0x00	Analog trim6 	D2A_TSC_TRIM
0x0A 	0x13	RW 	0x00	Analog trim7 	D2A_DRIVER_CUR_TRIM<
0x0B 	0x14	RW 	0x00	Analog trim8 	Spare register0
0x0C	0x15	RW 	0x00	Analog trim9 	Spare register1
0x0D 	0x16	RW 	0x00	Analog trim10	Spare register2
0x0E 	0x17	RW 	0x00	Analog trim11 	Spare register3
0x0F 	0x18	RW 	0x00	Analog trim12	Spare register4
0x10 	0x19	RW 	0x00	Analog trim13 	Spare register5
0x11 	0x1A	RW 	0x00	Analog trim14 	Spare register6
0x12 	0x1B	RW 	0x00	Analog trim15 	Spare register7
0x13	0x1C	RO	0x00	PROD_ID	
0x14-0x7F 	-	- 	- 	SPI read/write 	- 
 	0x1D	RW 	0x00	UNLOCK 	 
 	0x1E	RW 	0x00	OTP_DATA 	 
 	0x1F	RW 	0x00	OTP_ADDR 	 
 	0x20	RO 	0x00	OTP_MEM_DATA 	 
	0x21	RW	0x00	OTP_WAVEGEN_NUMBER	

OTP BIST 
 Introduction 
The OTP controller is to provide normal and test controller for the OTP EO32X32GCT2Q_H3. This OTP is provided by GF company.  
The OTP is a one-time programmable (OTP) memory, using BCD 0.18um process without any extra mask and process. This OTP IP consists of 5.0V isolated standard VT NMOS/PMOS device. During writing operation, a VPP voltage of 7.5V is required. 
There are four memory operations: Program, Read, Margin Read, and Stand-by. 
NOTE: Margin read mode provides a critical read condition to filter out “weak programmed” bits during test in the testing flow 
Architecture 
Block Diagram 
 
Feature List 

	Memory organization: OTP block (32x32 bits) 
	OTP block supports word read and byte program operation. 
	Test mode includes MARGIN READ OPERATION. 

Interface 
Name 	Direction 	Description 
BIST interface 
TCK 	I 	BIST clock 
RESETb 	I 	BIST reset, active LOW 
TESTEN 	I 	BIST test-enable, active HIGH 
STROBE 	I 	BIST strobe, active LOW 
TDI 	I 	BIST serial INPUT data 
TDO 	O 	BIST serial OUTPUT data 
OEN 	O 	BIST OUTPUT enable 
SEROUT 	O 	BIST OUTPUT ready 
vpp_en 	O 	vpp_en  transitions from 0 to1: VPP needs to go from VDD to 7.5v within 19 TCKs 
vpp_en  transitions from 1 to 0: VPP needs to go from 7.5v to VDD within 19 TCKs 
BIST signals to OTP IP 
o_BIST_OTP_XENTER 	O 	IP chip-select INPUT, active HIGH 
o_BIST_OTP_XREAD 	O 	IP read control INPUT, active HIGH 
o_BIST_OTP_XTM 	O 	IP margin read control INPUT, active HIGH 
o_BIST_OTP_PGM 	O 	IP program control INPUT, active HIGH 
o_BIST_OTP_XA 	O 	IP program/read INPUT address 
o_BIST_OTP_XDIN 	O 	IP program INPUT data 
i_BIST_OTP_DQ 	I 	IP read OUTPUT data 
O_BIST_OTP_OTP	O	OTP select

Functional Description 
Operation Mode 
For stable operation, all input signals should not be floated for all operation modes. 
Operation mode selection is showed in following table: 
 
  
OTP Cell State by Program operation and XDIN 
  
 Program Operation 
  
  
 Read Operation 
  
Margin Read Operation (Test) 

  
  
 Timing 

  	1 Mhz 	10 Mhz 	20 Mhz 	32 Mhz 	Unit 
t_tRD 	1 	2 	2 	3 	clk 
t_tRD_marge 	5 	10 	10 	15 	
t_tPGM 	325 	3250 	6500 	10400 	
t_tPGM_RC 	12 	120 	240 	384 	
t_pori 	2 	4 	8 	12 	
Table 3.6 Timing Table According to Frequency 
 
VPP TIMING 
  When we want to write into (program) OTP, external high voltage VPP is needed. This external high voltage needs to follow a timing. It cannot be always applied. Only for a short period of time, VPP is applied during the writing process. VPP_EN pin helps tell the user when to apply the VPP high voltage. Simply apply high voltage (7.5 V, see details below), when VPP_EN is 1 and stop applying high voltage when VPP_EN becomes 0. VPP_EN, however, is only available during BIST and NORMAL mode. During ATM mode, VPP_EN is not available for OSC trimming. OSC trim can be written 1) either by manual VPP timing, that is, when user intends to program OTP by enabling UNLOCK pin (in the OSC ATM mode), they need to manually wait for some specific time, then apply VPP high voltage, then wait for some other specific time, then remove the VPP high voltage (check the section related to write shadow reg to OTP for details) 2) or by recording the trim values in the ATE machine and then later (after all trimmings are done), write OSC trim values via OTP BIST.  
  When in read mode, OTP VPP is connected to VDD 1.8 V which is generated by internal LDO. VDD_DIG pin is then directed back to VPP (via bonding or in the PCB) in a normal mode condition. Final user will not need to write to OTP, but they will need to read it via SPI as well as normal trim loads. 
   When program command is sent to BIST slave via TDI, VPP must obey the timing as below two ways: 
 Access timing via Master  
  When STROBE goes 0 from 1, VPP must be 7.5v within 4 to 24 clocks 
  When STROBE goes 1 from 0 
	In PROGRAM mode, VPP must come back to VDD within (24+t_tPGM+3) to (24+t_tPGM+18) clocks 
	In Multiple PROGRAM mode, VPP must come back to VDD within (24+(t_tPGM+3*128) to (24+（t_tPGM+3）*128 +18) clocks 

Access timing via vpp_en 
	VPP_EN transitions from 0 to 1: VPP needs to go from VDD to 7.5v within 19 TCKs 
	VPP_EN transitions from 1 to 0: VPP needs to go from 7.5v to VDD within 19 TCKs 
Serial TDI Input Definition 
    The serial input signals are sent in following order: 
  	  	  	  	  Bit 25	Bit 24 
  	  	  	  	  OTP_SEL	FREQ[1] 
Bit 23 	Bit 22 	Bit 21 	Bit 20 	Bit 19 	Bit 18 
FREQ[0] 	MODE[2] 	MODE[1] 	MODE[0] 	DIN[7] 	DIN[6] 
Bit 17 	Bit 16 	Bit 15 	Bit 14 	Bit 13 	Bit 12 
DIN[5] 	DIN[4] 	DIN[3] 	DIN[2] 	DIN[1] 	DIN[0] 
Bit 11 	Bit 10 	Bit 9 	Bit 8 	Bit 7 	Bit 6 
ADR[6] 	ADR[5] 	ADR[4] 	ADR[3] 	ADR[2] 	ADR[1] 
Bit 5 	Bit 4 	Bit 3 	Bit 2 	Bit 1 	Bit 0 
ADR[0] 	PTM[1] 	PTM[0] 	PGM 	READ 	ENTER 

	ENTER: program enter 
	READ: enable output from OTP 
	PGM: program access 
	PTM: margin read enable 
	ADR: address 
	DIN: data 
	MODE: operation mode 
	FREQ: clock frequency 
	OTP_SEL: select OTP0/OTP1
S_MS: Operation mode selection, shown in following table: 
S_MS[17] 	S_MS[16] 	S_MS[15] 	Mode 
0 	0 	0 	STANDBY 
0 	0 	1 	BY PASS 
0 	1 	0 	SINGLE READ 
0 	1 	1 	MULTIPLE READ 
1 	0 	0 	SINGLE MARGIN READ 
1 	0 	1 	MULTIPLE MARGIN READ 
1 	1 	0 	PROGRAM 
1 	1 	1 	-
Table operating mode selection 
  
S_FREQ: Frequency selection, shown in following table: 
S_FREQ[19+otp_num] 	S_FREQ[18+otp_num] 	Frequency 
0 	0 	1MHz (supported) 
0 	1 	10MHz 
1 	0 	20MHz 
1 	1 	32MHz 
Table Frequency Selection 
  
 Serial TDO Input Definition 
Bit 7 	Bit 6 	Bit 5 	Bit 4 
Dout[7] 	Dout[6] 	Dout[5] 	Dout[4] 
Bit 3 	Bit 2 	Bit 1 	Bit 0 
Dout[3] 	Dout[2] 	Dout[1] 	Dout[0] 
  When serout goes to 1, master can receive 8 - bit data from next TCK, the first bit is bit 0 
 Serial TDI Input Timing 
  Serial TDI input timing is shown in figure following. 
    
Figure TDI input timing 
  
Serial TDO output Timing 
Serial TDO output timing is shown in figure following
   
 Figure TDO output timing 
 
Arbitrary Wave Generator
Overview
  Arbitrary Wave Generator (AWG) digital block was designed for working with the analogue block Driver C for different types of applications such as TENS, IFT/IFC, EMS Therapy (Driver C), nervous system stimulations (SCS and DBS). For details of the interfaces and requirements of the Drivers, refer to its manual “ENS2 Stimulators (Drivers) Specification”.
Note*: all registers should not be changed after enable driver apart from interrupt registers, if user want to config registers, the better way is:
disabled AWG -> config registers -> enable AWG.

Figure  1 Stimulus Waveform
 
Driver function
  

  There are 16 drives, The current stimulation can happen between any drivers by controlling of SOURCE and PULL_DOWN.





 Block Diagram of Wave Generator
  


Block Diagram of Wave Generator Block

Pin definition
 
Table 1. Pin definition for top AWG block
Name	IO	Definition
 Interface:
Analogue Interface (to analog):	 	see Drivers’ manual for details of each signal
o_out_wave_driver_dac[11:0] [15:0]	output	Waveform outputs in 12 bits (11:0) for Driver Values: 0 to 255(automatic mode)
o_ds_driver_en_dirver[15:0] (DRIVE_EN)	output	Enable Driver  (active high) (16 Driver As: 0 to 15)
o_pulln_driver[15:0] (PULLA)	output	Pull down enable for each Driver
o_source_driver[15:0] (SOURCEB)	output	Source enable for each Driver
0_ds_driver_en_current	output	Current enable for Driver 
O_driver_en_sw[15:0]	output	Current buffer enable for each driver
O_stimu_en	output	Control signal for two big power switch(5V and 1.8V)
CLK and Reset		
I_pclk 	input 	Clock to the wave gen block 
I_fclk 	input 	Clock to the wave gen block 
I_presetn 	input 	Same as reset but active high 
Scan_mode	input	Scan mode
interrupt (INT)	output 	interrupt 
Interface for each Wave Gen block (spi_wg interface):
O_wg_drive_en	input 	Dirve enable signal
O_period_sel	Input	Control the work mode of wavegen
O_config_reg	input 	bit 0: rest enable, 1: negative enable, 2: silent enable, 3: source B enable, 4: alternating (+/-) the positive side, 5: continue repeating the waveform if one works together with interrupt if zero, 6: multi-electrode  
O_wg_drive_rest_t<15:0> 
O_wg_drive_rest_t1<15:0> 
O_wg_drive_rest_t2<15:0> 
 	input 	resting time (in microseconds) between the positive side and the negative side of the wave in wave0/wave1/wave2
O_wg_drive silent_t<23:0> 
O_wg_drive silent_t1<23:0> 
O_wg_drive silent_t2<23:0> 
 
 	input 	silent time (in microseconds) before the next wave period
O_wg_drive_hlf_wave_per<15:0> 
O_wg_drive hlf_wave_per1<15:0> 
O_wg_drive hlf_wave_per2<15:0> 
 	input 	Half of the period of the arbitrary (e.g., sine or square) wave0/wave1/wave2 (in microseconds). 
O_wg_drive neg_hlf_wave_per<15:0> 
O_wg_drive neg_hlf_wave_per1<15:0> 
O_wg_drive neg_hlf_wave_per2<15:0> 
 	input 	Negative half of the period of the arbitrary (e.g., sine or square) wave0/wave1/wave2 (in microseconds). Values same as hlf_wave_per 
O_reg_wg_drive_point_config	input	The number of point each waveform
O_wg_drive alt_lim<15:0> 	input 	Number of clocks for a period of alternating signal.x 
O_wg_drive alt_silent_lim<15:0> 	input 	Number of clocks for each silent duration for the alternating frequency. Range is not clear right now. Will be fixed after system level verification.
O_wg_drive delay_lim<15:0> 	input 	Number of clocks for initial delay after the reset is disabled and before the waves are generated. The range is not clear right now. Will be fixed after system level verification. 
O_wg_drive_isel	Input 	Current select value
O_mult_elec	input	Allow multiple electrodes
O_wg_drive_in_wave	input	The data from SPI registers
O_wg_drive_ in_en	input	Interrupt Enable
O_wg_drive_ int_Addr0[7:0] 	input 	Interrupt address0 
O_wg_drive_ int_Addr1[7:0] 	input 	Interrupt address1 
O_wg_drive_ Addr0_int_clr 	input 	Clear the interrupt of address 0 
O_wg_drive_ Addr1_int_clr 	input 	Clear the interrupt of address 1 
O_wg_drive_ Int_Cnt[7:0] 	input 	The number of Interrupt 
O_short pullb/a to ground_ctrl	input	Enable pullb and pulla, and control the time
dirve	input	Manual mode/12-bit control signals
Global_en 	input	 Two drives can work at the same time
Stimu_en	Input 	Control signal for two big power switch(5V and 1.8V)
Stop_wavegen	Input 	Stop Wavegen when there are shorts
I_wg_drive_in_wave_addr	output	The address is used to load current data
I_wg_drive_source	output	The state of source
I_hlf_wave_cnt	output	The address is used to load current data
I_period_num	output	The wave(wave0/wave1/wave2) that is currently running
Int_sts[1:0] 	output 	Interrupt states
 
Registers
Please refer to “13.16 waveform regenerator function &&Register table”

Preloaded function
ENS2 supports preloaded sine, triangle and pulse waveforms. It is hardwired. And be controlled by AWG_DRV_CTRL_REG0 register
	For a pre-loaded sine waveform, the values are 8'h06, 8'h0c, 8'h12, 8'h18, 8'h1f, 8'h25, 8'h2B, 8'h31, 8'h37 , 8'h3D, 8'h44, 8'h4A, 8'h4F, 8'h55, 8'h5B, 8'h61, 8'h67, 8'h6D, 8'h72, 8'h78, 8'h7D, 8'h83, 8'h88, 8'h8D, 8'h92, 8'h97, 8'h9D, 8'hA1,9’HA6, 8'hAB, 8'hAF, 8'hB4, 8'hB8, 8'hBC, 8'hC1, 8'hC5, 8'hC9, 8'hCC, 8'hD0, 8'hD4, 8'hD7, 8'hDA, 8'hDD, 8'hE0, 8'hE3, 8'hE6, 8'hE9, 8'hEB, 8'hED, 8'hF0, 8'hF2, 8'hF4, 8'hF5, 8'hF7, 8'hF8, 8'hFA, 8'hFB, 8'hFC, 8'hFD, 8'hFE, 8'hFE, 8'hFE, 8'hFF, 8'hFE, 8'hFE, 8'hFE, 8'hFD, 8'hFC, 8'hFB, 8'hFA, 8'hF8, 8'hF7, 8'hF5, 8'hF4, 8'hF2, 8'hF0, 8'hED, 8'hEB, 8'hE9, 8'hE6, 8'hE3, 8'hE0, 8'hDD, 8'hDA, 8'hD7, 8'hD4, 8'hD0, 8'hCC, 8'hC9, 8'hC5, 8'hC1, 8'hBC, 8'hB8, 8'hB4, 8'hAF, 8'hAB, 8'hA6, 8'hA1, 8'h9C, 8'h97, 8'h92, 8'h8D, 8'h88, 8'h83, 8'h7D, 8'h78, 8'h72, 8'h6D, 8'h67, 8'h61, 8'h5B, 8'h55, 8'h4F, 8'h4A, 8'h44, 8'h3D, 8'h37, 8'h31, 8'h2B, 8'h25, 8'h1F, 8'h18, 8'h12, 8'h0C, 8'h06, 8'h00
	For preloaded pulse waveform, the value is 8'hff
	For preloaded triangle waveform, the value is 8'h03, 8'h07, 8'h0b, 8'h0f, 8'h13, 8'h17, 8'h1B, 8'h1F, 8'h23, 8'h27, 8'h2B, 8'h2F, 8'h33, 8'h37, 8'h3B, 8'h3F, 8'h43, 8'h47, 8'h4B, 8'h4F, 8'h53, 8'h57, 8'h5B, 8'h5F, 8'h63, 8'h67, 8'h6B, 8'h6F, 8'h73, 8'h77, 8'h7B, 8'h7F, 8'h83, 8'h87, 8'h8B, 8'h8F, 8'h93, 8'h97, 8'h9B, 8'h9F, 8'hA3, 8'hA7, 8'hAB, 8'hAF, 8'hB3, 8'hB7, 8'hBB, 8'hBF, 8'hC3, 8'hC7, 8'hCB, 8'hCF, 8'hD3, 8'hD7, 8'hDB, 8'hDF, 8'hE3, 8'hE7, 8'hEB, 8'hEF, 88'hF3, 8'hF7, 8'hFB, 8'hFF, 8'hFB, 8'hF7, 8'hF3, 8'hEF, 8'hEB, 8'hE7, 8'hE3, 8'hDF, 8'hDB, 8'hD7, 88'hD3,‘HCF, 8'hCB, 8'hC7, 8'hC3, 8'hBF, 8'hBB, 8'hB7, 8'hB3, 8'hAF, 8'hAB, 8'hA7, 8'hA3, 8'h9F, 8'h9B, 8'h97, 8'h93, 8'h8F, 8'h8B, 8'h87, 8'h83, 8'h7F, 8'h7B, 8'h77, 8'h73, 8'h6F, 8'h6B, 8'h67, 8'h63, 8'h5F, 8'h5B, 8'h57, 8'h53, 8'h4F, 8'h4B, 8'h47, 8'h43, 8'h3F, 8'h3B, 8'h37, 8'h33, 8'h2F, 8'h2B, 8'h27, 8'h23, 8'h1F, 8'h1B, 8'h17, 8'h13, 8'h0F, 8’B0B, 8'h07, 8'h03, 8'h00
  If not used all points in preload function, Then the selected values are chosen from 8'FF and extend to both sides according to the set points. If the selected points are 2**x, then select a point every 2**(7-x).
Pre-loaded waveform select table: 

Registers address  	Waveform	Shape of Waveform
0x03(AWG_DRV_CTRL_REG0)	0x03(AWG_DRV_CTRL_REG0)	
bit5~bit3	Bit2~Bit1	
000	00	sine
	01	pulse
	10	triangle
	11	normal
001	00	Sine-pulse
	01	Sine-triangle
	10	pulse -triangle
	11	normal
010	00	Sine-pulse -triangle
	01	Sine-triangle –pulse
	10	normal
	11	normal
others	-	normal

PULLB AND PULLA (Glitch removal time)
  Use AWG_DRV_SHORT PULLB/A TO GROUND_REG register to enable PA and PB at the same time, there are two options available. one is glitch removal for pos side, and another for neg side glitch removal. The idea is that, before pos (neg) starts, we turn on both pull down 0 and 1 (PA and PB) for some time to discharge to ground any charge accumulated on the electrodes, and then immediately start the pos (neg) side. These two glitch removal times are independent, meaning, we can enable for pos only, or for neg only, or for both. Duration is the same for both, however, enable is two different enables.
 
Operation mode
  We have two modes: Manual mode and Automatic mode
  We have waveform registers to directly and independently control switches for source  and pull-down  as well as an 8 (12) bit (bit[5] of 0x35) register for directly controlling the waveform value (IDAC) and another bit(bit[4] of 0x35) to switch between manual control or automatic (wavegen module) control, for example (drive0):
	bit[5] of 0x35=0 and bit[4] of 0x35=0: automatic mode, data is 8 bits, data comes from internal 64 wave points registers (filled up by SPI using reg 0x00)/preload data
	bit[5] of 0x35=0 and bit[4] of 0x35=1: manual mode, data is 12 bits, data comes from waveform registers 0x36, 0x37
	bit[5] of 0x35=1 and bit[4] of 0x35=0: automatic mode, data is 12 bits, data comes from waveform registers 0x36, 0x37
	bit[5] of 0x35=1 and bit[4] of 0x35=1: manual mode, data is 12 bits, data comes from waveform registers 0x36, 0x37
Specification
  Customized waveform (many other input arrays) is set by the upper-level register where it is read from an array of wave values. The max of the array can have 128 values; values are stored in an unpacked memory in the interface. An example of a sine wave (64 points) input value at the registers is below. 
12,  24,  37,  49,  61,  74,  85,  97, 109, 120, 131, 141, 151, 161, 171, 180, 188, 197, 204, 212, 218, 224, 230, 235, 240, 244, 247, 250, 252, 253, 254, 255, 254, 253, 252, 250, 247, 244, 240, 235, 230, 224, 218, 212, 204, 197, 188, 180, 171, 161, 151, 141, 131, 120, 109,  97,  85,  74,  61,  49,  37,  24,  12,   0
Note zero (0) is at the end of the input wave shape. These decimal numbers map to the following half wave shape:
  
Fig 2. Sine wave example
Block’s design
Negative edge
  This driver only has a source but no sink. When a negative edge is used, the negative edge will also be treated as a source, when the negative edge is used, it means wavegen register 0x00 bit[1]=1 & wavegen register 0x00 bit[3]=1 or register 0x00 bit[4]=1（alt mode), if positive edge also is used, then We will execute the following algorithm.

 A: IDAC (wrote by wavegen register 0x03&0x04 and calibration by scale and offset reg)
 B : SCALE BIT (wavegen register 0x36 bit[6:4])
 O : OUTPUT (go to analog)
When positive edge :  O=    A >> 1 + (12’h7f8 >> B)
When negative edge : O= - (A >> 1) + (12’h7f8 >> B)
when reset time/silent time : O = 0;

Note :  if not use negative edge, O=A

 
The AWG block consists of a state machine which has 8 states: 
S0: IDLE, FSM doesn’t work
S1: positive phase
S2: the rest time / Inter phase delay
S3: negative phase
S4: the silent time / Inter stimulus delay 
S5: standby mode if FSM doesn’t generate waveform after enable
S6: positive phase glitch time
S7: negative phase glitch time
State table
Note that if the time of a state is preset to 0, it is equivalent to disable the state, for example:
Enable positive side (0x00, bit7), but set positive side time 0 (0x08, 0x09), it means disable positive side, same for rest, negative and silent
Current state	Conditions	Next state
S0	Enable positive side
Disable pos short pullb/a to ground	S1
	Enable positive side
enable pos short pullb/a to ground	S6
	Disable positive side
Enable negative side
Disable neg short pullb/a to ground	S3
	Disable positive side
Enable negative side
enable neg short pullb/a to ground	S7
	Disable positive side
Disable negative side	S5
	Don't enable drive	S0

Current state	Conditions	Next state
S1	Enable rest 	S2
	Disable rest
Enable negative side
Disable neg short pullb/a to ground	S3
	Disable rest
Enable negative side
enable neg short pullb/a to ground	S7
	Disable rest
Disable negative side
Enable silent	S4
	Disable reset
Disable negative side
Disable silent	S1
	Don't enable drive	S5

Current state	Conditions	Next state
S2	Enable negative side
Disable neg short pullb/a to ground	S3
	Enable negative side
Enable neg short pullb/a to ground	S7
	Disable negative side
Enable silent	S4
	Disable negative side
Disable silent
Enable pos short pullb/a to ground	S6
	Disable negative side
Disable silent
Disable pos short pullb/a to ground	S1
	Don't enable drive	S5

Current state	Conditions	Next state
S3	Enable silent	S4
	Disable silent
Disable positive side	S3
	Disable silent
Enable positive side
Enable pos short pullb/a to ground	S6
	Disable silent
Enable positive side
Disable pos short pullb/a to ground	S1
	Don't enable drive	S5


Current state	Conditions	Next state
S4	Disable positive side
Enable rest	S2
	Disable positive side
Disable rest
Enable negative side
Disable neg short pullb/a to ground	S3
	Disable positive side
Disable rest
Enable negative side
Enable neg short pullb/a to ground	S7
	Enable positive side
Enable pos short pullb/a to ground	S6
	Enable positive side
Disable pos short pullb/a to ground	S1
	Don't enable drive	S5

Current state	Conditions	Next state
S5	enable drive	S0
	Don't enable drive	S5

Current state	Conditions	Next state
S6	enable drive	S1
	Don't enable drive	S0

Current state	conditions	Next state
S7	enable drive	S3
	Don't enable drive	S0

Test Waveform
Below are the waveforms we support, configured by register AWG_DRV_CONFIG_REG0(0x00)
Short pullb/a to ground[7:6] = 00(0x26)
AWG_DRV_CONFIG_REG0 (0x00)	Waveform composition
8'h07	Positive side - rest - negative side - silent - Positive side
8'h06	Positive side - negative side – silent - Positive side
8'h05	Positive side - rest - silent - Positive side
8'h04	Positive side – silent - Positive side
8'h03	Positive side - rest - negative side - Positive side
8'h02	Positive side - negative side - Positive side
8'h01	Positive side - rest - Positive side
8'h00	Positive side - Positive side （pos_DC）
8'h87	negative side - silent - rest-negative side
8'h86	negative side – silent - negative side
8'h85	No waveform
8'h84	No waveform
8'h83	negative side- negative side (neg_DC)
8'h82	negative side- negative side (neg_DC)
8'h81	No waveform
8'h80	No waveform

Short pullb/a to ground[7:6]=10(0x3c)
AWG_DRV_CONFIG_REG0 (0x00)	Waveform composition
8'h07	Glitch time -Positive side - rest - negative side - silent - Glitch time
8'h06	Glitch time - Positive side - negative side – silent - Glitch time
8'h05	Glitch time - Positive side - rest - silent - Glitch time
8'h04	Glitch time - Positive side – silent - Glitch time - Positive side 
8'h03	Glitch time - Positive side - rest - negative side - Glitch time
8'h02	Glitch time - Positive side - negative side - Glitch time
8'h01	Glitch time - Positive side - rest - Glitch time
8'h00	Glitch time - Positive side - Positive side （pos_DC）
8'h87	negative side - silent - rest-negative side
8'h86	negative side – silent - negative side
8'h85	No waveform
8'h84	No waveform
8'h83	negative side- negative side (neg_DC)
8'h82	negative side- negative side (neg_DC)
8'h81	No waveform
8'h80	No waveform

Short pullb/a to ground[7:6] = 01 (0x3c)
AWG_DRV_CONFIG_REG0 (0x00)	Waveform composition
8'h07	Positive side - rest - Glitch time - negative side - silent - Positive side
8'h06	Positive side - Glitch time - negative side – silent - Positive side
8'h05	Positive side - rest - silent - Positive side
8'h04	Positive side – silent - Positive side
8'h03	Positive side - rest - Glitch time - negative side - Positive side
8'h02	Positive side - Glitch time - negative side - Positive side
8'h01	Positive side - rest - Positive side
8'h00	Positive side - Positive side （pos_DC）
8'h87	Glitch time - negative side - silent - rest- Glitch time 
8'h86	Glitch time - negative side – silent - Glitch time 
8'h85	No waveform
8'h84	No waveform
8'h83	Glitch time - negative side- negative side (neg_DC)
8'h82	Glitch time -negative side- negative side (neg_DC)
8'h81	No waveform
8'h80	No waveform

Short pullb/a to ground[7:6]=11(0x3c)
AWG_DRV_CONFIG_REG0 (0x00)	Waveform composition
8'h07	Glitch time -Positive side - rest - Glitch time - negative side - silent - Glitch time
8'h06	Glitch time - Positive side - Glitch time - negative side – silent - Glitch time
8'h05	Glitch time - Positive side - rest - silent - Glitch time
8'h04	Glitch time - Positive side – silent - Glitch time - Positive side 
8'h03	Glitch time - Positive side - rest - Glitch time - negative side - Glitch time
8'h02	Glitch time - Positive side - Glitch time - negative side - Glitch time
8'h01	Glitch time - Positive side - rest - Glitch time
8'h00	Glitch time - Positive side - Positive side （pos_DC）
8'h87	Glitch time - negative side - silent – rest- Glitch time 
8'h86	Glitch time - negative side – silent - Glitch time 
8'h85	No waveform
8'h84	No waveform
8'h83	Glitch time - negative side- negative side (neg_DC)
8'h82	Glitch time - negative side- negative side (neg_DC)
8'h81	No waveform
8'h80	No waveform

Alternating function
  Alternating function (0x02, bit4) is used to generate alternating positive and negative waves when the state machine is operating in the S1 state, we have two registers to control the time of alternating, see AWG_DRV_ALT_LIM_REG
  And AWG_DRV_ALT_REST_LIM_REG, AWG_DRV_ALT_SILENT_LIM_REG the positive and negative waveform times in the alterative function are the same: AWG_DRV_ALT_LIM_REG/2
Note : in this project, negative edge of alt function will be used as rest
 

STEPs
D0：SINK，POS TIME:P0, REST TIME:R0, NEG TIME ：N0, SILENT TIME:S0
D1:  source，POS TIME:P1, REST TIME:R1, NEG TIME ：N1, SILENT TIME:S1
	Config AWG_DRV_ALT_LIM_REG to SET P0/N0,P1/N1（P*=N*= AWG_DRV_ALT_LIM_REG/2）
	Config  AWG_DRV_ALT_REST_LIM_REG to set R0、R1; AWG_DRV_ALT_SILENT_LIM_REG to set S0、S1
	Config  silent registers（AWG 0x08~0x0b）to control the timing
For T0,  T0=P1+R1
For T1,  T1=P0+R0


	Config data, period and points registers and so on
	Enable driver
Waveform
 

Multi-waveform function
  Chip supports up to three waveforms working together, called wave0, wave1, wave2, which have independent positive cycle registers, negative cycle registers, rest registers, silent registers, we can control the number of waves by AWG_DRV_CTRL_REG0[5:3] (0x03) yin.
Data Ready
   There are 64x8 bits registers array, we stored the data into those registers by SPI, 
the method of writing data is to write the address to the address register (0x01) first, and then write data to the data register (0x00), so that the data is written to the corresponding address in the address register.

 
Read Data
The data which is stored in SPI registers can be load by Wavegen:
- Firstly, set the point register(0x04) to tell Wavegen how many points to load for half a cycle (positive and negative cycles)
- Set AWG_DRV_CTRL_REG0[6] (0x03, bit6) to decides whether to load all points or only load the points set by point register:
Bit6=0: only load the points set by point register, repeats the wave data    after the reaching number of points 
Bit6=1: load all points
- For 1 waveform:  goes through pos and neg periods for number of periods in bits[5:3] and loads data from wave data (0x00) continuously until reaches number of points (0x01) multiply X (the number of periods next) which will larger than 64
- For 2 waveforms or 3 waveforms: go through pos and neg periods for number of periods in bits[5:3] and loads data from wave data (0x00) continuously until reaches number of points (0x00) multiply by number of waves (bit[5:3] + 1).
Set AWG_DRV_CTRL_REG0[7] (0x03, bit7) to decides positive side and negative neg whether to load data from same data registers)

0: in one period, positive side and negative neg load data from different data registers(0x00)
1: in one period, positive side and negative neg load data from same data registers(0x00) when waveform is symmetric.

For an example
When point register (0x04) is 8'ha, there are 10 points for positive period and 10 points for negative period.
- If bit6 is 0, both pos and neg load data from point0~point9 of data register (0x00). 
- If bit6 is 1 and bit7 is 0,  
For waveform 0: pos period loads data from point0~point9 and neg period loads data from point10~point19；
For waveform 1:  pos period loads data from point20~point29, neg period loads data from point30~point39; 
For waveform 2:  pos period loads data from point40~point49, neg period loads data from point50~point59; 
- If bit6 is 1 and bit7 is 1
For waveform 0: pos period loads data from point0~point9 and neg period loads data from point0~point9；
For waveform 1: pos period loads data from point10~point19, neg period loads data from point10~point19; 
For waveform 2: pos period loads data from point20~point29, neg period loads data from point20~point29; that means if we set bit7 to 1, we can get a higher resolution.
Notes: 
If using 2 or 3 waveforms, bit 6 must set 1.
Waveform Scaling
  Chip supports data waveform scaling through multiplication and division (shift right), and positive and negative sides have their own independent calibration registers. Moreover, offsetting is also provided. See AWG_DRV_NEG_SCALE_REG0, AWG_DRV_POS_SCALE_REG0, AWG_DRV_NEG_OFFSET_REG0, AWG_DRV_POS_OFFSET_REG0
The scaling formula is: 
A: The 12-bit value goes to analog
B: The 8-bit data from SPI register
C: Bit [6:4] of DRIVE_REG_CTRL2
multiplication:
If bit [7] of DRIVE_REG_CTRL2 is 1: 
                         A = {4’b0, B} * {4’b0, SCALE} + {OFFSET,4’b0}
（ A = B * SCALE + OFFSET <=0xFFF, otherwise will be overflow, if overflow, the value will fix to 0xFFF）
If bit[7] of DRIVE_REG_CTRL2 is 0 :
                         A = {B,4’b0} >> C + {OFFSET,4’b0}
Division:         
                         A = {4’b0, B} >> {4’b0, SCALE} + {OFFSET,4’b0}
  The purpose for this is to provide an option to users to change the waveforms, especially predefined waveforms, without having to load wave values. 
For example, User can change a waveform so that it has different amplitude and offset on positive side with respect to negative side, without needing to load different values into each side.
  As another example, User can use preloaded waveforms (pulse, sine and triangle) and change their amplitude and offset without requiring loading any waveforms into the chip.
Interrupt
 Interrupt function
  The interrupt has two interrupt addresses (int_addr0: 0x2D, int_addr1: 0x2E). After the interrupt is enabled, the internal register reads the data on the interrupt address and generates an interrupt signal for changing the address. The two addresses correspond to two interrupt signals. This interrupt supports two functions:
  One is that the interrupt indicates how many waveform cycles have been run, that is, an interrupt is generated after the number of cycles we set. This number of interrupts can be set in register 0x2B.
  The other is to detect if the first address is missed, if the first address is not interrupted and the second address is interrupted, the first address is missed.
  The interrupts can be cleared by writing register (see 0x2C).
Interrupt with repeating waveform
  If int_addr1 generates an interrupt, it indicates that the next waveform is incorrect, at which time we can set whether to continue generating the next waveform by the register: AWG_DRV_CONFIG_REG0[5] (0x02, bit 5).
Bit5=1: continue repeating the waveform.
Bit5=0: doesn’t continue repeating the waveform.

multi-electrode
  There are 16 drivers in ENS2, test 16 electrodes are completely independent and require timing control.
  They are controlled by AWG_DRV_CONFIG_REG0[6] (0x02, bit 6): 
0: this electrode is used as source
1: this electrode is used as sink
For source, use silent time to control the timing, the silent time is :
   Silent time(source) = positive time(sink) + rest time(sink) + negative time(sink)

For sink, use silent time to control the timing, the silent time is:
Silent time(sink) = positive time(source) + rest time(source) + negative time(source)

 

NOTE: It is recommended to use only positive edges (although we also support negative edges). Because when using negative edges, there is no rest or silent time.
 

Source B
  The function is set by AWG_DRV_CONFIG_REG0[3] (0x02, bit 3), It is used to control whether negative waveforms are generated after negative waveforms are enabled,
Bit3=1: generating negative waveform in S3 state,
Bit3=0: generating positive waveform in S3 state,
Special waveform processing for silent time
  This item is mainly used to generate special waveforms for silent time, that is when we set bit[0] of Wavegen register at address 0x38, then this feature is enabled, next, during the waveform generation, there will be no silent time, even if you enable it and set the clock count for it. The waveform will continue to run until the number of cycles reaches the value set in register 0x39&0x3A. Only then will it enter the silent time. After exiting the silent time, this process will repeat.
Notes: 
1. It is necessary to enable silent and set the number of clocks for it.
2. The maximum number of clock cycles before entering the silent period is 0xFFFF.
3. Here, "Silent" actually refers to the negative edge time， but don’t enable negative edge enable
 
 



EMS waveform without interrupts
  This function is used to generate EMS waveforms in alternating mode without the need for interruption intervention.
Data distribution
  Wavegen has a total of 64 data points. Under this function, it is divided into two parts: one part is the envelope data points and the other part is the carrier data points. When the point register is set to X, then X represents the carrier data points and the envelope data points are 64 - X.
 

Data algorithm
  The data is divided into two parts: one part is the envelope signal and the other part is the carrier signal. To generate the EMS waveform, each point of the envelope signal is multiplied by the carrier signal in sequence
 
 
High-frequency carrier
  It can be used for the register 0x3C&0x3D to achieve high-frequency carrier. By using this register, the number of repetitions for each envelope point can be set to obtain a higher carrier frequency.
  
 
 

Decimal configurability
  By register 0x3c, it is able to set the envelope data to be optional fractional data. By default, all envelope points are integers.
  Envelope data(E) is 12its with scale and offset, carrier data(C) is 8bits
So, envelope data * carrier data(Y) is 20 bits
Y[19:0] = E*C
ANALOG_DATA=Y>>A (the value of 0x3c
Note that ANALOG_DATA shouldn’t be overflowed
A	C	E	ANALOG_DATA
000	8-bit integer
0 decimal places	12-bit integer	Y[11:0]
001	7-bit integer
1 decimal places	12-bit integer	Y[12:1]
010	6-bit integer
2 decimal places	12-bit integer	Y[13:2]
011	5-bit integer
3 decimal places	12-bit integer	Y[14:3]
100	4-bit integer
4 decimal places	12-bit integer	Y[15:4]
101	3-bit integer
5 decimal places	12-bit integer	Y[16:5]
110	2-bit integer
6 decimal places	12-bit integer	Y[17:6]
111 	1-bit integer
7 decimal places	12-bit integer	Y[18:7]
  
Setup steps

  Envelope data and carrier data are written through registers 0x00 and 0x01.
  Set the period (0x0B & 0x0C) of the positive periodic point to P1
  Set the configuration register (0x02) to 0x50
  Set the point register (0x04) to X.
  Set alter_lim (0x1Ax1B)  to X*P1*2
Set silent time (0x09~0x0B)  to X*P1
(Note if use rest and slient time, then set alter_lim (0x2Fx30)+ alter_slient_lim (0x31x32) alter_rest_lim (0x33x34) to alter_lim, It is recommended that the values set for the three registers be multiples of P1 or can be divided by P1.）
  Set EMS_REG_CTRL(0x3C)
  Set EMS_DATA_NUM(0x3D)
  Set control register (0x03) to enable wavegen



two consecutive positive or negative waveforms without using interrupts
By configuring the 0x25 register, two consecutive positive or negative cycles can occur. At this time, bit6 and bit7 of 0x01 should be at their default values.
This feature is not suitable for alter mode. It is compatible with rest, silent and pullba.

 


BURST function for wavegen shape registers
For wavegen shape registers(wavegen reg 0x00/0x0) , there are 2 ways to write:
	One address, one data, first, write the target address of the data to register 0x01, and then write the data to register 0x00. Using this method, each piece of data requires two SPI communications.
	Use burst function, no need to write address, only write data, address can increase automatically, the steps can be done as below:
	Config WAVEGEN_GLOBAL_REG(0x03 of general register) bit[4]
	Use burst function write the data to ADDR_WG_DRV_IN_WAVE_REG01(0x00 of wavegen register) via SPI bus

 
Note : Here, 0x00 is the data address of driver0. If it is drive1, it is 0x40; for driver2, it is 0x80, and so on.
Note ： 1. if use this feature, must be write all 64 datas for shape register, if user doesn’t write all 64 datas, need to reset shape address register by writing 0x00 to ADDR_WG_DRV_IN_ADDR_REG0(0x01 of wavegen register) via SPI bus before next write operation, normally, if user write all 64 datas, the address can be reset automatically

mul-wavegen access function
This function is used to simultaneously access multiple wavegen register modules and perform write operations on them. However, the prerequisite is that all the wavegen register modules must have exactly the same configuration, including configuration registers and waveform shape registers. For registers with different configurations, this function needs to be disabled and they should be written to separately.
Steps：
	config general register 0x07/0x08 to select The target wavgen module to be written this time(for example if user want write same data to driver1,driver3,driver9,driver14, then set bit[1]/bit[3] of 0x07 to 1, bit[1]/bit[6] of 0x08 to 1, other bits keep 0)
	use spi to accress target registers, these register addresses must be based on drive0, the range is from 0x00 to 0x3f








DDS Mode
introduction
This module is used to generate Temporal Interference Stimulation (TIS), TIS is a brain stimulation method that uses two or more high-frequency electrical signals to create a low-frequency stimulation effect deep inside the brain

How it works
• Two AC currents with slightly different frequencies are applied through 
electrodes on the scalp. 
• Example: 
	Signal 1 = 5000 Hz 
	Signal 2 = 5010 Hz 
• Inside the brain, these signals interfere with each other. 
• The difference frequency appears as a low-frequency “envelope”:
5010 − 5000 = 10 Hz
• Neurons do not respond strongly to the individual 5kHz signals, but they can 
respond to the 10 Hz envelope. 
This allows stimulation of deeper brain regions without strongly stimulating the 
surface cortex.

 

 

Theory
In this project, we use 32-bit register to do DDS, set those parameters as below : 
	CPP: the number of clocks per point
	Fdds : frequency of clock to the wavegen (after this divider)
	Fsin  : frequency of sine wave required
	Phlf  : number of points per period (64)
	Regw : width of DDS reg (32 bits)
	M      : how many clock cycles are required in total during the Fsin period, it is 2 * Phlf * CPP, 
	FCW: The proportion occupied by each point after quantization； FCW= round[(2^regw) * (Fsin*M/Fpclk] = round[(2^32)*128*CPP*Fsin/8MHz]= round[68719.476736*CPP*Fsin]. Fdds is Fsin * M. Fdds should be always less than 8 MHz so Fsin * CPP <= 625000. if Fsin increased, CPP should be reduced. Number of clocks per period is M*(2^32)/FCW.

What we need to config is that，the value of FCW should be written into 32 bits DDS_STEP registers(shared mul-waveform register, the base address is 0x12~0x15, Note, it means The multi-waveform function and DDS mode cannot be used simultaneously.)


Step :
	Enable DDS MODE by writing wavegen register 0x38 bit[3]
	Write FCW into DDS_STEP registers
	Configure cycle，point register, etc.
	Enable drivers

Based on the above parameters, we have the following formula:

FCW= 68719.476736(64 points & 8mhz) * CPP * Fsin;

Set CPP = 8, then 
    If Fsin = 1000hz, FCW=68719.476736 * 8 * 1000= 549755813.888=549755813
If Fsin = 1001hz, FCW=68719.476736 * 8 * 1001= 550305569.701888=550305569

Waveform 
Here, use d0/d1 to generate the Fsin with1000hz, use d2/d3 to generate the Fsin with1001hz
The result of envelope = (d1-d0) – (d3-d2) = 1hz
Source : d1/d3
Sink     : d0/d2
 


 
Multiple waveform repetition
We previously introduced the multi-waveform function, which by default cycles through wave0-wave1-wave2-wave0, meaning each waveform appears only once per complete cycle.
This section introduces a new feature—the multi-waveform repetition function—allowing wave0, wave1, and wave2 to repeat multiple times within a complete cycle. This enables waveform sequences such as wave0-wave0-wave0-wave1-wave1-wave2-wave2-wave2-wave2-wave2-wave2-wave0.

STEP
	Enable multi-waveform repetition function by writing wavegen register 0x38 bit[2]
	Configure the number of repetitions for wave0 waveform by writing wavegen register 0x39/0x3A(This register shares functionality with the one described in 9.9.11, so these two features cannot be used simultaneously.)
	Configure the number of repetitions for wave1 waveform by writing wavegen register 0x31(This register shares functionality with the one described in 9.9.5, so these two features cannot be used simultaneously.)
	Configure the number of repetitions for wave2 waveform by writing wavegen register 0x32(This register shares functionality with the one described in 9.9.5, so these two features cannot be used simultaneously.)
	Configure the period of each waveform according to the multi-waveform function, and set the number of points register(if N is the points for each waveform, then 3N < 64)
	Enable drivers

Waveform 
Wave0 ： repeat 16 times
Wave1 ： repeat 32 times
Wave2 ： repeat 8 times
 
LEAD OFF DETECTOR 

This module is used to detect Lead Off which means the stimulation pad is unconnected with stimulation load
The theory of lead detection is to select a stimulation period as a checking period, when stimulation, the analog comparator is expected to have response (A2D_COMP will change to high if the current is larger than a value), if comparator doesn’t have the response, then the A2D_COMP will keep low. We will count the response status during the checking period, because user know what the stimulation waveform is, so user should know the rough number of responses, at the end of the checking period, we can compare the rough number of responses with preset number we expected, if less than the preset number, then we think has possibility of lead off. In order to get a robust result of lead off, we can set a target number of this detected lead off as real lead off and issue interrupt and turn off the Wavegen optionally.

Analog Part (Analog Model)

How Analog design to generate A2D_COMP, this circuit will show the behavior:
 
 
When will Lead Off happen?
Positive Wave Lead Off

 

Negative Wave Lead Off:
 

The delay is 217ns at rising edge and 390ns at falling edge of A2D_COMP*
Digital Part
Below diagram is the idea of the implementation:
 

 
 
 
 
 
 

The Timer_TH is the checking period we set. The Counter_TH is the number of A2D_COMP from comparator (count the A2D_COMP every clock cycle if the A2D_COMP is 1), when time reach to the Timer_TH, we check whether the number of 1 of A2D_COMP, if the number(Counter_LO) is less than Counter_TH, then we think it is  lead off and issue interrupt and turn off the Wavegen (if set the option to turn off Wavegen)

Note: 
The normal working waveform voltage value should be bigger than the VDAC voltage value, otherwise this lead-off doesn’t work.


 

During Wavegen is stopped (stop Wavegen feature is ON if find Lead-Off), the timer counter also will stop because Wavegen will restart again if enable Wavegen again. If the stop feature is not ON, the Wavegen will not stop, so the timer will keep running.

ANAC (Analog Controller)
This module generates Analog Comparator interrupts and Analog LVD interrupt.
By monitoring the corresponding signals from Analog part to Digital part along with the interrupt enable register set by the User.
LVD (Low Voltage Detection)
Block Diagram (Analog LVD Model)
 
Feature
LVD is a feature to compare VBAT with a Threshold Voltage, if it is lower than this threshold voltage, then ANA_LVD is asserted from ANA Top to Digital Top, and Digital part just generates an interrupt and output to MCU as A WARNING ALARM.
Analog LVD Interrupt:
LVD_EN (bit-0 of ANA_ENABLE_REG_0 at offset address 0x40) is set to 1’b1 to enable it from Digital Top to Ana Top). The default value of LVD_EN is 1’b0 to disable LVD circuit.
Whenever ANA_LVD status will be asserted, and ANA_LVD_INTR_EN bit[0] set as=1 (default value=1) by User, an ANA_LVD interrupt is generated, ORed with the Lead Off Detection, Short Detection and Wavegen interrupts, ... etc. Interrupt status can also be read via SPI by reading ANA_LVD_STS (bit-0 of A2D_ANA_GEN_REG_0: Offset 0x50). 
To disable the interrupt, either User needs to change the battery or change interrupt voltage level via LVD_SEL (bit [2:0] of ANA_GEN_REG_1: Offset:0x44) or disable the interrupt. 
 Analog Comparators Interrupts:
Whenever Analog COMP_CH1, COMP_CH2 status becomes 1, and ANA_INTR_EN bit [1,2] are set as 11 (default value=1) by the user, the Analog COMP_CH1, COMP_CH2 interrupts are generated and ORed with the leadoff/short and Wavegen, ANA_LVD Interrupts. 
These interrupts status can be cleared by writing 1 to BIT [1]/ [2] in ANA_INTR_STS_REG Register (0x53).
 Register 0x55 ：
ANA_INT_STOP_WAVEGEN_REG[0]: such that if set this bit to 1, we can stop Wavegen 1 if the interrupt happens in register ANA_INTR_SIM_CL, bit0.
ANA_INT_STOP_WAVEGEN_REG[1]: such that if set this bit to 1, we can stop Wavegen 2 if the interrupt happens in register ANA_INTR_SIM_CL, bit1.
 Short Circuit Detection Design
Analog Circuit Design (Analog Model)
How Analog design to generate A2D_COMP_STIMU, this circuit will show the behavior:
 
When short-circuit happens, depending on D2A_STIMU_COMP_SEL_CHx which is used to detect Positive Phase or Negative Phase
Short Detection will be detected in positive phase when D2A_STIMU_COMP_SEL is 0
 
Short Detection will be not detected in negative phase when D2A_STIMU_COMP_SEL is 0
 
Digital Short Circuit Detection using A2D_COMP_OUT_STIMU0 to 3

 1. 1x 32-bit Timer, user can set value for the 32-bit Time 32 register.
 2. 1x 32-bit counter LO, User can set value for 32-bit Counter TH register.
Working principle: within the set timer's duration: the counter increases. When A2D_STIMU0_1/ A2D_STIMU2_3 is active (configured by register 0x54; bit0 for CH1, bit1 for CH2). When the timer expires, a comparison between the Counter LO value and the set threshold Counter TH will be performed. A decision is made depending on the outcome of this comparison.
If Counter LO value >= threshold Counter TH, it means that the number of (A2D = 1) meets the requirement and no short circuit has occurred.
If Counter LO value < threshold Counter TH, it means that the number of (A2D = 1) doesn’t meets the requirement and short circuit has occurred.
 
Note: 
1. Short-circuit detection works in conjunction with the waveform generator. Only when you enable the waveform generator, the short-circuit detection function can be activated.
2. When you set bit4 of reg 0x54 to 1, the short-circuit detection will automatically switch to the lead-off detection.
3. The threshold is used for the timer should be larger than the threshold used for the counter that detects the A2D signal.

 Over-Temperature Protection (TSC)
The over-temperature protection mechanism in ENS2 relies on accurate digital configuration of the 8-bit VDAC value corresponding to room temperature. This VDAC value serves as the reference threshold for detecting thermal events via the temperature sensor comparator, which belongs to the analog domain. The digital subsystem is responsible for configuring and controlling this VDAC value through a sequence of register operations and state machine logic, as shown in Figure 101.
  
Figure 101 Functional diagram for over-temperature protection.
 
Analog model
 
Functional Overview
Upon power-up or before initiating temperature monitoring, the TEMP_SAR_T_NOR module performs a binary search using a Successive Approximation Register (SAR) algorithm to determine the digital input Dnom_tsc<7:0> that corresponds to the real-time temperature voltage (VTSC) of the chip. This digital value is stored in the TSC_n register (0x77) and serves as reference of the comparator.
The search process is internally controlled by a dedicated state machine, which manipulates several control signals:
D2A_VDAC_EN: Enables the DAC
D2A_COMP_EN: Enables the comparator
D2A_TSC_EN: Enables the temperature sensor circuit
D2A_VDAC_DIN: Provides comparator input from DAC
To enable user-defined over-temperature protection, the ENS2 module requires configuration of an 8-bit DAC value (Dhigh_tsc[7:0]) that corresponds to the target over-temperature condition. This value is input into the comparator via the TSC_VDAC8B_DIN_CH1 register. The formula for calculating the correct DAC value is derived from the linear behaviour of the temperature sensor's analog output.
Dhigh_tsc[7:0] = (Thigh − Troom) × α+ Dnom_tsc  	(1)
Where:
	Dhigh_tsc[7:0]: DAC value to be configured for over-temperature detection
	Thigh: Target over-temperature threshold in °C
	Troom: Measured room temperature in °C (used to establish baseline)
	Dnom_tsc : DAC value corresponding to room temperature (measured and stored in TSC_VDAC_NOR)
	α: Temperature-to-DAC scaling factor, typically 0.64 LSB/°C
This calculated value is then written by the user into the TSC_VDAC8B_DIN_CH1 register (0x4F) via SPI. During active monitoring, the analog comparator compares the current VTSC with this over-temperature DAC threshold, and if VTSC > VDAC, the comparator outputs a logic HIGH, signaling an over-temperature condition.
 
Figure 102 Block diagram of the VDAC

Configuration and Monitoring Flow 
	TEMP_SAR_T_NOR is triggered to find the VDAC value using SAR.
	State machine activates analog blocks using:
	D2A_VDAC_EN
	D2A_COMP_EN
	D2A_TSC_EN
	The VDAC value corresponding to room temperature is written to:
	TSC_VDAC_NOR register (0x73)
	User reads TSC_VDAC_NOR through SPI.
	User computes Dhigh_tsc based on temperature difference and writes it to:
	TSC_VDAC8B_DIN_CH1 register (0x40)
	User enables temperature monitoring by setting bits in:
	TSC_CTRL register (0x6c)
	Monitoring status is checked through:
	TSC_SMP_STS.BUSY_DOING (0x74)
	Interrupt status (if enabled)
SAR state machine
 
There are 6 states: SET_BIT is used to set DAC value to generate analog voltage for comparator to compare; because DAC and comparator need time to stable, WAIT state is used for this stable time, when COMPARE is done, if it is the last bit to set, then goes to FINISH state to get the final DAC value, otherwise, will try to set another DAC value for next round of comparing. Just like the following:
 

 
The analog_stable_cnt is for the whole analog stable for example VDAC, Temperature sensor, etc. the comp_wait_cnt is for the VDAC to stable when changing the Vdac value.

Registers of Over-temperature Protection
The digital verification team is responsible for verifying the correct configuration and behaviour of the following registers and logic components:
Register Name	Address	Default	Description
TSC_EN_REG_SEL	0x6B	0x00	Analog block control source selection
TSC_CTRL	0x6C	0x00	Comparator behavior control
TSC_VDAC8B_DIN_CH1	0x70	0xFF	DAC threshold value for over-temp
TSC_VDAC_NOR	0x69	0x00	Output of SAR-based room temperature DAC
TSC_SMP_STS	0x6A	0x00	Indicates comparator activity status
STABLE_DURATION	0x6E–0x6F	0x1FF	Analog stabilization delay after enable
SMP_DURATION	0x6D	0x10	Comparator sample duration

TSC_EN_REG_SEL: 0x6B (General Register)
Bit	Field Name	Attribute	Default	Description
7:5	 RESERVED	RW	0	 reserved
4	 TSC_VDAC8B_DIN_CH1	RW	0	 1: Register control
 0: State machine control
3	 TSC_EN_CH1	RW	0	 1: Register control
 0: State machine control
2	 RESERVED	 RW	0	 reserved
1	 TSC_COMP_EN_CH1	RW	0	 1: Register control
 0: State machine control
0	 D2A_VDAC8B_EN_CH1	RW	0	 1: Register control
 0: State machine control
TSC_CTRL: 0x6C (General Register)
Bit	Field Name	Attribute	Default	Description
7:4	 RESERVED	RO	0	 No use
3	 TSC_COMP_LOW_CH1	RW	0	 0:  A2D_TSC_COMP 0 means normal  temperature, 1 is over temperature
 1: A2D_TSC_COMP 1 means normal temperature, 0 is over temperature
2:1	 RESERVED	RO	0	 No use
0	 TSC_EN_CH1	RW	0	 Temperature Sensor Module Enable
 1: Enable
 0: Disable
 
TSC_VDAC8B_DIN_CH1: 0x70 (General Register)
 
Bit	Field Name	Attribute	Default	Description
7:0	 TSC_VDAC8B_DIN_CH1	RW	8'hFF	DIN for 8bit DAC (Dhigh_tsc[7:0])

TSC_SMP_STS: 0x6A (General Register)
Bit	Field Name	Attribute	Default	Description
7:1	 RESERVED	RO	0	 
0	 BUSY	RO	0	 Comparator status
 0: Finish
 1: In progress

TSC_VDAC_NOR: 0x69 (General Register)
Bit	Field Name	Attribute	Default	Description
7:0	 TSC_VDAC_NOR	RO	0x00	 Room temperature VDAC value (Dnom_tsc[7:0])

TSC_STABLE_DURATION: 0x6e-0x6f (General Register)
Bit	Field Name	Attribute	Default	Description
11:0	 STABLE_DURATION	RW	0x1FF	Temp sensor analog stable time

TSC_SMP_DURATION: 0x6d (General Register)
Bit	Field Name	Attribute	Default	Description
7:0	 SAMPLE_DURATION	RW	0x10	 Comparation sample duration

TEMP_SAR_T_NOR
The TEMP_SAR_T_NOR module contains a state machine that performs a SAR search by comparing DAC output values with the temperature sensor. It iteratively resolves the VDAC digital value bit-by-bit, starting from the most significant bit (MSB) down to the least significant bit (LSB). Upon completion, the final 8-bit result—representing the room temperature equivalent DAC input—is made available in the TSC_VDAC_NOR register for retrieval via the SPI interface.
TSC Comparators Interrupts:
Whenever the TSC comparator output transitions to logic '1', and the TSC_INT_EN bit has been explicitly enabled by the user (default value = 0), an over-temperature interrupt is generated. It shares the same interrupt pin (INTB) with other sources including Lead-Off detection, short-circuit detection, AWG events, and LVD interrupts, to form a combined interrupt output to the system.

Stimulator Voltage Measurement and Resistor Monitor Block:
The device integrates an auxiliary ADC and a flexible digital control engine to monitor the stimulation voltage across active electrode pairs. By analyzing the measured voltage/impedance data transmitted to the host MCU, users can diagnostic the electrode-tissue interface status, including Lead-Off (open circuit), Normal Operation, and Short-Circuit conditions.
The system supports up to 16 channels, which can be flexibly paired into up to 16 independent measurement pairs (N <=16) via a multiplexed Analog Front-End (AFE).

 

Key Features
	Flexible Channel Pairing: Any of the 16 channels can be configured to form a measurement pair (e.g., Pair_0 = {CH_5,CH_2}, Pair_1 = {CH_7, CH_0}).
	Automated Time-Division Multiplexing (TDM): The system automatically scans through configured pairs sequentially.
	Configurable Dwell Time: The measurement period (dwell time) for pair is programmable.
	Auto-Looping Mechanism: The scan engine loops from Pair_0 to Pair_N-1, and automatically rolls back to Pair_0 after completing the sequence.
	Control Manually: this measurement is mostly for resistor check or initial stimulator pad connection check
Operation Modes & Scan Sequence
The scan engine dynamically adjusts its loop boundary based on the configured active pair number register (PAIR_NUM[3:0]).
Case 1: 16-Pair Full Scan Loop (N = 16, PAIR_NUM = 15)
The controller loops through all 16 pre-configured pairs sequentially:
Pair_0 -> Pair_1-> … Pair_15-> Pair_0 …
 
Case 2: 8-Pair Partial Scan Loop (N = 8, PAIR_NUM = 7)
The controller limits the scan boundary to the first 8 pre-configured pairs:
Pair_0 -> Pair_1-> … Pair_7-> Pair_0 …
 
Custom Pair Configuration Example
Each measurement pair is defined by mapping source and sink channels to the corresponding target registers.
	Pair_0: Active Electrode 0 = CH_5, Active Electrode 1 = CH_2
	Pair_1: Active Electrode 0 = CH_7, Active Electrode 1 = CH_0
 
ADC value meaning
 


Differential Output Voltage Mapping (Offset Binary Format)
The differential voltage (VA - VB) is represented in a 10-bit offset binary format, where mid-scale corresponds to a zero-voltage condition:
	10'h3FF: Positive Full-Scale (+VFS), representing the maximum positive voltage (e.g., +1.8V).
	10'h200: Mid-Scale (Zero Volts), representing a null/no-load voltage condition (0.0V).
	10'h000: Negative Full-Scale (-VFS), representing the maximum negative voltage (e.g., -1.8V).

Transfer Function and Data Coding
The load voltage is driven differentially from node A to node B. The digital control word utilizes a 10-bit coding scheme centered at a mid-scale bias of 10'h200 to represent a zero-voltage state across the load.
The dynamic range spans from negative full-scale to positive full-scale. For a reference maximum voltage of 1.8V, the transfer function maps 10'h3FF to +1.8V (maximum positive swing), 10'h200 to 0V(idle state), and 10'h000 to -1.8V (maximum negative swing).

Note:  If user want to change any parameters during the stimulation monitoring process, user need to first set the reset bit STIM_MON_RST_REG to 1, then modify the parameters, and finally release STIM_MON_RST_REG back to 0. We do not support changing parameters while monitoring is in progress.
Registers：
STIM_PAD_CTRL: 0x40 (General Register)
Bit	Field Name	Attribute	Default	Description
7:5	STIM_MON_INT_EN	RW	0x0	Interrupt enable
7: adc cycle value interrupt status enable
Cycle value mean only output 1 data each pair and when all PAIR_NUM of data are latched, then issue cycle data interrupt
6: adc sample interrupt status enable
5: adc sample delta interrupt status enable
(output the delta value(max-min, or max or min) during the defined sample period)

4	ADC_MODE	RW	0	How to do the measure
0: Manual
1: automatic
Manual means the pair is selected by register directly and stimulator also need to be controlled manually
The pair selected is the pair0 when used as manual mode
3:0	PAIR_NUM	RW	0xF	When CHECK_EVERY_N is set to 1, then this 4 bits is for adc sample interrupt, this means is number of samples to interrupt and should disable the cycle interrupt.
When CHECK_EVERY_N is set to 0;
How many pairs be Measured
0: 1 pair
1: 2 pair
…
F: 16 pair
STIM_MON_PERIOD: 0x41 – 0x42(General Register)
Bit	Field Name	Attribute	Default	Description
15:0	 STIM_MON_PERIOD	RW	0x0	How long the measurement should be done for one pair(based on ADC sampling clock)
    STIM_MON_PERIOD_H: 0x5B – 0x5C(General Register)
Bit	Field Name	Attribute	Default	Description
15:0	 STIM_MON_PERIOD_H	RW	0x0	How long the measurement should be done for one pair(based on ADC sampling clock)

0x41 is lower bytes, 0x5B is lower bytes
So the total period is { STIM_MON_PERIOD_H , STIM_MON_PERIOD }, 32 bits
STIM_MON_CTRL2: 0x43  (General Register)
Bit	Field Name	Attribute	Default	Description
7	RESERVED	RO	0	-
6	CHECK_EVERY_N	RW	0	Interrupt Generation Mode for ADC sample interrupt(INT_MOD)
	0: Individual Sample Interrupt Mode. An interrupt is triggered upon the completion of every single ADC sample.
	1: Sample Accumulation Interrupt Mode. Interrupts are issued only after aggregating a programmable number of samples, specified by PAIR_NUM.
Note: When this bit is asserted (set to 1), the standard cycle interrupt must be disabled. The PAIR_NUM field defines the exact block size (number of samples) required to trigger the interrupt.

5	STIM_MON_RST_REG	RW	0	Stim monitor software reset
0: not reset
1: reset
Note: stimulator monitor reset will sync with wavegen reset, which mean wavegen reset, the stim monitor ctrl will also reset
4	 MON_ADC_CLK_INV	RW	0x0	Digital adc sample clock is invert of original digital adc controller clock(which is analog adc clock)
0: same phase
1: invert of digital adc controller
3:0	 MON_CLK_DIV	RW	0x4	Adc sampling clock dividor
0: 4M
1: 2M
2: 1M
3: 512k
4: 256k
5: 128k
6: 64k
7: 32k
8: 16k
9: 8k
A: 4K
B: 8M(normally don’t used)
Others: 4M
The analog clock shape is ¼ high pulse and ¾ low pulse except 8M
STIM_ADC_DATA_TAG: 0x44 – 0x45 (General Register)
Bit	Field Name	Attribute	Default	Description
15:12	 A2D_ADC_TAG_CAP	RO	0x0	Indicate which pair data 
11:10	Reserved	RO	0x0	
9:0	A2D_ADC_DATA_CAP	RO	0x0	Data captured from ADC
0x44 is lower bytes
STIM_MON_INT: 0x46 (General Register)
Bit2:0 of this register is same as GENERAL_INTERRUPT_STATUS_REG0B
Bit	Field Name	Attribute	Default	Description
7:5	STIM_MON_INT_TO_PIN_EN	RW	0x0	Output to the sampling or delta value to INT pin enable
7: cycle value int to pin enable
6: sample value int to pin enable
5: delta value int to pin enable
1  means enable
4:3	STIM_DELTA_DATA_SEL	RW	2’b0	Peak data select
00: delta data(max-min)
01: Min data
10: Max data
11: the last sample data during this pair
2	STIM_MON_CYCLE_INT	RW/RC/W1C	0x0	The interrupt generate has higher priority then clear interrupt, for example, if generate interrupt and clear interrupt happens at the same time, then will generate interrupt, ignore clear action
Stimulator adc cycle value interrupt status or write to clear or read to clear depend on which interrupt clear
1	STIM_MON_INT	RW/RC/W1C	0x0	The interrupt generate has higher priority then clear interrupt, for example, if generate interrupt and clear interrupt happens at the same time, then will generate interrupt, ignore clear action
Stimulator adc interrupt status or write to clear or read to clear depend on which interrupt clear 
0	STIM_MON_DELTA_INT	RW/RC/W1C	0x0	The interrupt generate has higher priority then clear interrupt, for example, if generate interrupt and clear interrupt happens at the same time, then will generate interrupt, ignore clear action
Stimulator adc delta value interrupt status or write to clear or read to clear depend on which interrupt clear 
STIM_PAD_CTRL1: 0x47 (General Register)
Bit	Field Name	Attribute	Default	Description
7	BYPASS_ADC_DATA_EN	RW	0x0	Bypass the A2D_DATA_EN from analog, consider every data from analog is valid
0: keep A2D_DATA_EN from analog
1: ignore the  A2D_DATA_EN from analog
6	READ_ADC_DATA_EN	RW	0	Read adc cycle data enable (max 32 bytes depends on how many pairs are stimulation in one cycle). If this bit is set to 1, then address 0xC0 – 0xDF are used as cycle adc data address instead of analog register,which make cycle data can be easily burst read 
so the 0xC1-0xC0 is the ADC data of pair number
The 0xC3-0xC2 is the ADC data of pair number -1
…..
5	BYPASS_IGNORE_FIRST	RW	1	Bypass ignore first analog adc_data_en, which means every adc_data_en is valid
0: ignore first analog adc_data_en
1: consider the first analog adc_data_en is valid
Because analog adc_data_en always running, the stimulation can be in the middle of adc_data_en, if this happens, we consider to ignore this adc_data_en if this bit is set to 0
4	ADC_EN	RW	0x0	Analog ADC enable and digital ADC controller enable
0: disable
1: enable
3:0	STIM_DLY_TGT	RW	0x0	Delay stimulator indicator to capture the ADC data incase ADC is not stable
0: don’t delay
1: delay one cycle
…
14: delay 14 cycle
15: don’t support

 

If the adc is slow, then STIM_ON could be ON in the middle of A2D_sampling period, which will cause the following A2D_ADC_DATA_EN is not a valid sampling data, we should ignore this A2D_ADC_DATA_EN(red one) and use the next A2D_ADC_DATA_EN(green one).



 

STIM_PAD0_TGT0: 0x48-0x49 (General Register)
Bit	Field Name	Attribute	Default	Description
15:0	 STIM_PAD0_TGT0	RW	0x3210	STIM_PAD0_PAIR
3:0  Pair0
7:4  Pair1
11:8 Pair2
15:12 Pair3
When ADC_MODE=0(manual mode), the 3:0 is the manual mode pad 
0x48 is lower byte
STIM_PAD0_TGT1: 0x4A-0x4B (General Register)
Bit	Field Name	Attribute	Default	Description
15:0	 STIM_PAD0_TGT1	RW	0x7654	STIM_PAD0_PAIR
3:0  Pair4
7:4  Pair5
11:8 Pair6
15:12 Pair7
STIM_PAD0_TGT2: 0x4C-0x4D (General Register)
Bit	Field Name	Attribute	Default	Description
15:0	 STIM_PAD0_TGT2	RW	0xBA98	STIM_PAD0_PAIR
3:0  Pair8
7:4  Pair9
11:8 PairA
15:12 PairB
STIM_PAD0_TGT3: 0x4E-0x4F (General Register)
Bit	Field Name	Attribute	Default	Description
15:0	 STIM_PAD0_TGT3	RW	0xFEDC	STIM_PAD0_PAIR
3:0  PairC
7:4  PairD
11:8 PairE
15:12 PairF

STIM_MON_LOFF_INT_STS0: 0x51-0x52 (General Register)
these registers are same as GENERAL_INTERRUPT_STATUS_REG07/08
Bit	Field Name	Attribute	Default	Description
15:0	 STIM_MON_LOFF_INT_STS0	RW/RC/W1C	0x0	Leadoff interrupt status or write to clear or read to clear depend on which interrupt clear
0: pair0 leadoff status
1: pair1 leadoff status
…
15: pair15 leadoff status
STIM_MON_SHORT_INT_STS0: 0x53-0x54 (General Register)
these registers are same as GENERAL_INTERRUPT_STATUS_REG09/0A
Bit	Field Name	Attribute	Default	Description
15:0	 STIM_MON_SHORT_INT_STS0	RW/RC/W1C	0x0	Short interrupt status or write to clear or read to clear depend on which interrupt clear
0: pair0 short status
1: pair1 short status
…
15: pair15 short status

STIM_MON_LOFF_SHORT_INT_CTRL: 0x55 (General Register)
Bit	Field Name	Attribute	Default	Description
7:4	reserved	RW	0x0	
3:0	STIM_MON_LOFF_SHORT_INT_CTRL	RW	0	0: leadoff interrupt enable
1: short interrupt enable
2: leadoff interrupt to PIN enable
3: short interrupt to PIN enable

STIM_MON_LOFF_TH: 0x56-0x57 (General Register)
Bit	Field Name	Attribute	Default	Description
15:10	reserved	RO	0x0	
9:0	STIM_MON_LOFF_TH	RW	0	Leadoff threshold,  more than this value will be treaded leadoff one time

STIM_MON_SHORT_TH: 0x58-0x59 (General Register)
Bit	Field Name	Attribute	Default	Description
15:10	reserved	RO	0x0	
9:0	STIM_MON_SHORT_TH	RW	0	short threshold,  less than this value will be treaded short one time


 


Threshold Voltage Mapping and Interrupt Detection Window
The system utilizes a 10-bit Offset Binary coding scheme to digitize the differential input voltage (Vdiff = VA - VB). The total dynamic range spans from -1.8V to +1.8V(example). Two pairs of symmetrical digital thresholds—LOFF_TH (Lead-Off Threshold) and SHORT_TH (Short-Circuit Threshold)—are implemented to monitor the real-time channel status and trigger corresponding hardware interrupts.

Window Comparator and Interrupt Detection Logic
The digital monitoring logic divides the entire input range into distinct functional zones based on window comparison:
	Zone A: Lead-Off Detection Window (LEAD_OFF)
This window detects electrode or lead detachment, which typically causes the instrumentation amplifier to saturate toward the supply rails due to extremely high input impedance.
	Positive Lead-Off: Triggered when Vdiff > +1.7V(for example, the digital code exceeds the upper LOFF_TH boundary).
	Negative Lead-Off: Triggered when Vdiff < -1.7V(for example,the digital code drops below the lower LOFF_TH boundary).
	Behavior: When the digitized signal enters either of these outer saturation zones, a LEAD_OFF interrupt pulse is asserted.
	Zone B: Short-Circuit Detection Window (SHORT)
This window identifies physical short-circuits between differential leads or severe signal attenuation where the input voltage abnormally collapses toward the zero-voltage baseline.
	Detection Range: Triggered when the differential voltage falls within the narrow central band: -0.1V <= Vdiff <= 0.1V(for example, the digital code drops in the  SHORT_TH boundary).
	Behavior: In terms of digital codes, a SHORT interrupt is asserted if the code is simultaneously less than or equal to the positive short threshold (corresponding to +0.1V,around 10’h201 for example) and greater than or equal to the negative short threshold (corresponding to -0.1V, around 10'h1FF for example). Effectively, it triggers whenever the absolute differential voltage satisfies Vdiff <= 0.1V(for example).
	Zone C: Normal Operation Window
	Range: Consists of the two symmetrical bands between the short and lead-off thresholds: -1.7V<= Vdiff < -0.1V and  +0.1V < Vdiff <= +1.7V(for example).
	Behavior: Within these zones, both LEAD_OFF and SHORT interrupts remain de-asserted, indicating valid biopotential signal acquisition.
STIM_MON_TH_TGT: 0x5A(General Register)
Bit	Field Name	Attribute	Default	Description
7:0	STIM_MON_TH_TGT	RW	0	Leadoff/short target number to be treated as real leadoff/short and issue interrupt.
Leadoff/short share this target number, but leadoff/short will count itself number

Note: STIM_MON_TH_TGT must not exceed STIM_MON_PERIOD; otherwise, leadoff/short detection will never be triggered.

STIM_ORIG_ADC_DATA: 0xF4 – 0xF5 (General Register)
Bit	Field Name	Attribute	Default	Description
15	 A2D_ADC_DATA_EN	RO	0x0	Indicate adc data enable from analog 
14:10	RESERVED	Ro	0x0	
9:0	 A2D_ADC_DATA	RO	0x0	Indicate adc data from analog 

STIM_ADC_DELTA_DATA_TAG: 0xF6 – 0xF7 (General Register)
Bit	Field Name	Attribute	Default	Description
15:12	 A2D_DELTA_ADC_TAG_CAP	RO	0x0	Indicate which pair data 
11	SELECT_2ND_MAX_MIN	RW	0x0	Select 2nd max/min value
0: max/min value
1: 2nd max/min value
10	ADC_DELTA_DATA_CAP_IN_MANUAL	RW	0x0	Delta Data Capture Trigger (Manual Mode Only) This bit triggers a delta data capture when the device operates in manual mode. It is ignored and has no effect in auto mode.
	0: Capture disabled / No action.
	1: Initiate delta data capture.
Usage Note: before switch the monitored channel pair in manual mode, software must follow this sequence:
	Clear this bit to 0 to reset the capture logic.
	Set this bit to 1 to capture the current delta data(keep longer than 3 adc clocks)
	Wait for interrupt, then clear the int status
	Read the delta data
	Switch to the target channel pair.
	Do the step 1,2 again
9:0	A2D_ADC_DELTA_DATA_CAP	RO	0x0	Delta(vpeak, max-min or max or min depend on STIM_DELTA_DATA_SEL) Data captured from ADC during defined sampling period

STIM_PAD1_TGT0: 0xF8-0xF9 (General Register)
Bit	Field Name	Attribute	Default	Description
15:0	 STIM_PAD1_TGT0	RW	0x2301	STIM_PAD1_PAIR
3:0  Pair0
7:4  Pair1
11:8 Pair2
15:12 Pair3
When ADC_MODE=0(manual mode), the 3:0 is the manual mode pad
STIM_PAD1_TGT1: 0xFA-0xFB (General Register)
Bit	Field Name	Attribute	Default	Description
15:0	 STIM_PAD1_TGT1	RW	0x6745	STIM_PAD1_PAIR
3:0  Pair4
7:4  Pair5
11:8 Pair6
15:12 Pair7
STIM_PAD1_TGT2: 0xFC-0xFD (General Register)
Bit	Field Name	Attribute	Default	Description
15:0	 STIM_PAD1_TGT2	RW	0xAB89	STIM_PAD1_PAIR
3:0  Pair8
7:4  Pair9
11:8 PairA
15:12 PairB
STIM_PAD1_TGT3: 0xFE-0xFF (General Register)
Bit	Field Name	Attribute	Default	Description
15:0	 STIM_PAD1_TGT3	RW	0xEFCD	STIM_PAD1_PAIR
3:0  PairC
7:4  PairD
11:8 PairE
15:12 PairF



NIRS/PPG CONTROLLER – MISSING LED DRIVER in ANA

	Index Terms - Photoplethysmogram (PPG), near-infrared spectroscopy (NIRS)
Optical sensing techniques (600 nm-900 nm):
	Curent-mode (CM) readout
	PPG: green/red/infrared -  photodiode (PD) 
	NIRS: red/infrared - silicon photomultiplier (SIPM)

NIRS/PPG_TOP Registers Illustration
Note: ENS2 doesn’t have internal LED Driver 
block	Registers Name	Description	Default 
NIRS/PPG control	D2A_NIRS_PDBIAS_ADJ<1:0>	Bias voltage for Photodiode (PPG)
00: PDSINK= 1.5V
01: PDSINK= 1.8V
10: PDSINK= 2.1V              
11: PDSINK= 2.4V               	2’b01
	D2A_ NIRS_EN	Enable the whole NIRS block
0: Disable all NIRS’s blocks
1: Enable NIRS	1’b0 
	D2A_NIRS_IDAC_EN	Enable IDAC to compensate DC component
0: Disable NIRS’s IDAC
1: Enable NIRS’s IDAC	1’b0
	D2A_NIRS_TEST_EN	Enable NIRS testmode to measure IREFCOARSE and IREFFINE current then find real IREFCOARSE/IREFFINE ratio	1’b0 
	D2A_NIRS_RESET_SW	Reset	1’b0 
	D2A_NIRS_IPD_SW	PPG/NIRS Signal Integration	1’b0 
	D2A_NIRS_IIN_SW	Reset + Signal Integration	 2’b01
	D2A_NIRS_IPDMIRROR_ADJ<1:0>	Mirror ratio [(IPD-IDAC) : IMIRROR]
00= 1:1 
01= 2:1
10= 1:2
11= 1:1.5	 2’b01
	D2A_NIRS_IREFC_ADJ<1:0>	Iref_coarse current 
00= 0.52 uA
01= 1.04 uA
10= 2.08 uA
11= 4.16 uA	 2’b01
	D2A_NIRS_CFRATE_ADJ<1:0> -RATIO	Ratio Iref_coare:Iref_fine
00= 128:1
01= 64:1
10= 32:1
11= 16:1

Note: “RATIO” variable at digital block must follow these ratio setting	9’b0_0000_0000 
NIRS/PPG Control Method
There are four LED drivers in the PPG system for each channel, their names can be organised in the below table. 

RED 	LED_A 
INFRARED 	LED_B 
GREEN1 	LED_C 
GREEN0 	LED_D 
 
When the NIRS/PPG system is working, any of two LEDs is chosen to flash alternatively as shown in Fig 1 (for NIRS system, only use RED and INFRARED) 
  
Fig 12.1.2 LED driver method 
FSM Methods
The digital circuitry in the system consists of 2 parts: a timing control logic for clock generation, and a current DAC controller within the DR enhancing loop. 
Table 12.1.3.1 & 12.1.3.2 &Fig 12.1.3.1  shows the timing control  
Fig 3 shows the working sequence of the hysteresis control of the current DAC. It compares the digital output from the ac path to the threshold values and adjusts the output of the current DAC automatically whenever the output of the ac path exceeds the threshold window. 
 
ON_TIME_SEL<3:0> 	Duration 	Unit 
0 	1 	us 
1 	2 	us 
2 	3 	us 
3 	4 	us 
4 	5 	us 
5 	6 	us 
6 	7 	us 
7 	8 	us 
8 	9 	us 
9 	10 	us 
10 	12 	us 
11 	14 	us 
12 	16 	us 
13 	18 	us 
14 	20 	us 
15 	25 	us 
Table 12.1.3.1 

Period<3:0> 	Duration 	Unit 
0 	125 	us 
1 	250 	us 
2 	500 	us 
3 	750 	us 
4 	1 	ms 
5 	2 	ms 
6 	4 	ms 
7 	6 	ms 
8 	8 	ms 
9 	10 	ms 
10 	12 	ms 
11 	14 	ms 
12 	16 	ms 
13 	18 	ms 
14 	20 	ms 
15 	22 	ms 

Table 12.1.3.2

Treset = 5us; Td=5us 
 
  
Fig 12.1.3.1

 
Fig 12.1.3.2
 
Fig 12.1.3.3

    Register Map
Register Map
FUNCTION	BASE ADDRESSES NAME	BASE ADDRESSES
SYSTEM	SYSTEM_CTRL_BASE_ADDR	0X01
OTP	OTP_BASE_ADDR	0X0A
GPIO	GPIO_BASE_ADDR	0X30
MON_ADC	MON_ADC_ADDR	0x40
LEAD_OFF	LEAD_OFF_BASE_ADDR	0X26
ANA_REG	ANA_REG_BASE_ADDR	0X40
SHORT	ANA_SHORT_BASE_ADDR	0X50
TSC	TSC_BASE_ADDR	0X6B
INT	INT_REG_BASE_ADDR	0X78
PINMUX	PINMUX_REG_BASE_ADDR	0X7E
DEBUG	DEBUG_REG_BASE_ADDR	0X80
EEG	EEG_BASE_ADDR	0X90
	FILTER_REG_BASE_ADDR	0XB0
ANA	A2D_ANA_REG_BASE_ADDR	0xA0
ANA	ANA_EN_BASE_ADDR	0xC0
ANA	ANA_REG_BASE_ADDR	0xD0
FILTER_SYNC	FILTER_SYNC_ADDR	0xF0
MON_ADC	MON_ADC_ADDR	0xF8


Offset address	Register name	Attribute	Default
Part I- General Register Map (refer to SPI command to access to General Registers)
0x00	-	-	-
0x01	PMU_REG	WR	0x01
0x02	CLK_CRTL_REG	WR	0x00
0x03	WAVEGEN_GLOBAL_REG	WR	0x00
0x04	CLOCK_GATING_REG_0	WR	0x00
0x05	PMU_REG1	WR	0x02
0x06	O_CLK_SEL	WR	0x00
0x07~0x09	Reserved		
OTP Registers			
0x0A	OTP_DEBUG1	R	0x00
0x0B	OTP_DEBUG2	R	0x00
0x0C	OTP_TRIMDATA0	RW	0x5A
0x0D	OTP_TRIMDATA1	RW	0x00
0x0E	OTP_TRIMDATA2	RW	0x00
0X0F	OTP_TRIMDATA3	RW	0x00
0x10	OTP_TRIMDATA4 (TO ANA TOP)	RW	0x00
0x11	OTP_TRIMDATA5 (TO ANA TOP)	RW	0x00
0x12	OTP_TRIMDATA6 (TO ANA TOP)	RW	0x00
0x13	OTP_TRIMDATA7 (TO ANA TOP)	RW	0x00
0x14	OTP_TRIMDATA8 (TO ANA TOP)	RW	0x00
0x15	OTP_TRIMDATA9 (TO ANA TOP)	RW	0x00
0x16	OTP_TRIMDATA10 (TO ANA TOP)	RW	0x00
0x17	OTP_TRIMDATA11 (TO ANA TOP)	RW	0x00
0x18	OTP_TRIMDATA12 (TO ANA TOP)	RW	0x00
0x19	OTP_TRIMDATA13 (TO ANA TOP)	RW	0x00
0x1a	OTP_TRIMDATA14 (TO ANA TOP)	RW	0x00
0x1b	OTP_TRIMDATA15 (TO ANA TOP)	RW	0x00
0x1c	OTP_TRIMDATA16 (PROC ID)	RO	0x00
0x1d	OTP_UNLOCK	RW	0x00
0x1e	OTP_DATA	RW	0x00
0x1f	OTP_ADDR	RW	0x00
0x20	OTP_EME_DATA	RO	0x00
0x21	OTP_WAVEGEN_NUMBER	RW	0x00
0x22 - 0x2F	Reserved	-	-
GPIO REGISTERS	-	-	-
0x30	GPIO_PD_CRTL	RW	0x1F
0x31	GPIO_DS	RW	0x00
0x32	GPIO_COMP_OUT_CTRL	RW	0x00
0x23~0x25	Reserved	-	-
LEAD OFF Register			
0x26	LEAD_OFF_CTRL	RW	0x0
0x27	LEAD_OFF_TGT	RW	0x0
0x28	LEAD_OFF_INT	RW	0x00
0x29	COUNTER_TH_TGT_0	RW	0x00
0x2A	COUNTER_TH_TGT_1	RW	0x00
0x2B	COUNTER_TH_TGT_2	RW	0x00
0x2C	COUNTER_TH_TGT_3	RW	0x00
0x2D	TIMER_TH_TGT_0	RW	0x00
0x2E	TIMER_TH_TGT_1	RW	0x00
0x2F	TIMER_TH_TGT_2	RW	0x00
0x30	TIMER_TH_TGT_3	RW	0x00
0x31	LEAD_OFF_BLK_SLCT	RW	0x00
0x32	LEAD_OFF_DAC_EN	RW	0x00
0x33	LEAD_OFF_STOP_EN	RW	0x00
0x34	LEAD_OFF_INT_EN	RW	0x00
0x35	LEAD_OFF_COMP_LOW_EN	RW	0x00
0x36	LEAD_OFF_STOP	RW	0x00
0x39	LEAD_OFF_ANA	R	0x00
0x3A~0x3F	Reserved	-	-
ANALOG_REGISTERS			
0x40	ANA_ENABLE_REG_0	RW	0x02
0x41	ANA_ENABLE_REG_1	RW	0x00
0x42	ANA_ENABLE_REG_2	RW	0x00
0x43	ANA_ENABLE_REG_3	RW	0x00
0x44	ANA_GEN_REG_1	RW	0x04
0x45	ANA_GEN_REG_2	RW	0x00
0x46	ANA_GEN_REG_3	RW	0x00
0x47	ANA_GEN_REG_4	RW	0x00
0x48	ANA_GEN_REG_5	RW	0x00
0x49	ANA_GEN_REG_6	RW	0x00
0x4A	ANA_GEN_REG_7	RW	0x00
0x4B	ANA_GEN_REG_8	RW	0x00
0x4C	ANA_GEN_REG_9	RW	0x00
0x4D	A2D_ANA_GEN_REG_0	R	0x00
0x4E	A2D_SPARE_RO_REG_0	R	0x00
0x4F	Reserved	-	-
MON_ADC			
0x4	STIM_PAD_CTRL		
0x0x41-42	STIM_MON_PERIOD		
0x43	STIM_MON_CLK_DIV		
0x44-0x45	STIM_ADC_DATA_TAG		
0x46	STIM_MON_INT		
0x47	Reserved		
0x48-0x4F	STIM_PAD0_TGT0-3		
SHORT DETECTION			
0x50	ANA_INTR_EN	RW	0x07
0x51	ANA_INT_COMP_POL	RW	0x00
0x52	ANA_INT_STOP_WAVEGEN	RW	0x00
0x53	ANA_STIM_CH1_TIMER_CNT_TH00	RW	0x00
0x54	ANA_STIM_CH1_TIMER_CNT_TH01	RW	0x00
0x55	ANA_STIM_CH1_TIMER_CNT_TH02	RW	0x00
0x56	ANA_STIM_CH1_TIMER_CNT_TH03	RW	0x00
0x57	ANA_STIM_CH1_COUNTER_CNT_TH00	RW	0x00
0x58	ANA_STIM_CH1_COUNTER_CNT_TH01	RW	0x00
0x58	ANA_STIM_CH1_COUNTER_CNT_TH02	RW	0x00
0x5A	ANA_STIM_CH1_COUNTER_CNT_TH03	RW	0x00
0x5B	ANA_STIM_CH2_TIMER_CNT_TH00	RW	0x00
0x5C	ANA_STIM_CH2_TIMER_CNT_TH01	RW	0x00
0x5D	ANA_STIM_CH2_TIMER_CNT_TH02	RW	0x00
0x5E	ANA_STIM_CH2_TIMER_CNT_TH03	RW	0x00
0x5F	ANA_STIM_CH2_COUNTER_CNT_TH00	RW	0x00
0x60	ANA_STIM_CH2_COUNTER_CNT_TH01	RW	0x00
0x61	ANA_STIM_CH2_COUNTER_CNT_TH02	RW	0x00
0x62	ANA_INT_LVD_STS	R	0x00
0x63	ANA_INTR_SIM_CL	RW1C	0x00
0x64	ANA_INTR_STS_REG	R	0x00
0x65~0x6a	Reserved	-	-
TSC			
0x69	VDAC_NOR_L	RW	0x00
0x6A	SMP_STS	RW	0x00
0x6B	TSC_EN_REG_SEL	RW	0x00
0x6C	TSC_CTRL	RW	0x00
0x6D	SAMP_DURATION	RW	0x10
0x6E	STABLE_DURATION_L	RW	0xff
0x6F	STABLE_DURATION_H	RW	0x01
0x70	TSC_VDAC8B_DIN_CH1	RW	0xff
0x71	TSC_INT_CTRL	RW	0x00
0x72	TSC_INT_STATUS	RW	0x00
		-	-
INT REG			
0x73	GENERAL_INTERRUPT_STATUS_REG07	RW	0x00
0x74	GENERAL_INTERRUPT_STATUS_REG08	RW	0x00
0x75	GENERAL_INTERRUPT_STATUS_REG09	RW	0x00
0x76	GENERAL_INTERRUPT_STATUS_REG0A	RW	0x00
0x77	GENERAL_INTERRUPT_STATUS_REG0B	RW	0x00
0x78	GENERAL_INTERRUPT_CTRL_REG	RW	0x00
0x79	GENERAL_INTERRUPT_STATUS_REG01	RW	0x00
0x7A	GENERAL_INTERRUPT_STATUS_REG02	RW	0x00
0x7B	GENERAL_INTERRUPT_STATUS_REG03	RW	0x00
0x7C	GENERAL_INTERRUPT_STATUS_REG04	RW	0x00
0x7D	GENERAL_INTERRUPT_STATUS_REG05	RW	0x00
0x7E		GENERAL_INTERRUPT_STATUS_REG06	RW	0x00
PINMUX			
0x7F	ATM_HC_SEL	RW	0x00
DEBUG			
0x80	COUNTER_CNT_DBG_SEL	RW	0x00
0x81	COUNTER_CNT_DBG_0	RW	0x00
0x82	COUNTER_CNT_DBG_1	RW	0x00
0x83	COUNTER_CNT_DBG_2	RW	0x00
0x84	COUNTER_CNT_DBG_3	RW	0x00
0x85	LEAD_OFF_COUNTER_CNT_DAC0	RW	0x00
0x86	-		
0x87	OTP_TRIMS_DBG_SEL	RW	0x00
0x88	OTP_TRIMS_DBG_DATA	RO	0x00
0x89-0x8F	Reserved	-	-
IMEAS Register	-	-	-
0x90	IMEAS_REG_0	WR	0x18
0x91	IMEAS_REG_1	WR	0x27
0x92	IMEAS_REG_2	WR	0x0
0x93	STABLE_TIME_0	WR	0x10
0x94	STABLE_TIME_1	WR	0
0x95	IMEAS_D_0	RO	0
0x96	IMEAS_D_1	RO	0
0x97	IMEAS_D_2	RO	0
0x98	IMEAS_D_3	RO	0
0x99	IMEAS_CTRL	RW	0
0x9A	IMEAS_EN_DIS_CH_L	RW	0
0x9B	IMEAS_EN_DIS_CH_H	RW	0
0x9C - 0xAF	Reserved		
FILTER register			
0xB0	FILTER_SEQ_CTRL	[7:3] RO
Others: RW	0
0xB1-0xB2	FILTER_HPF_BP	RW	0xffff
0xB3-0xB4	FILTER_LPF_BP	RW	0xffff
0xB5-0xB6	FILTER_NOF_BP	RW	0xffff
0xB7	FILTER_INT_CTRL	[7:2] RO
Others RW	0
0xB8	FILTER_INT_STS	[7:1] RO
Others W1C/R1C	0
0xB9-0xBA	FILTER_NOTCH_DATA_GONE	RW	0x3A94
0xBB - 0xBF	Reserved		
0XF0-0xF2	FILTER_DLY_TGT	RW	0xFF
0xF3	FILTER_SYNC_CTRL	RW	0x1
0xF4-0xF7	Reserved		
MON_ADC			
0xF8-0xFF	STIM_PAD1_TGT0-3		
ANALOG_REGISTERS			
0x A0	A2D_ANA_GEN_REG_0	RO	0x00
0x A1	A2D_ANA_GEN_REG_1	RO	0x00
0x A2	A2D_ANA_GEN_REG_2	RO	0x00
0x A3	A2D_ANA_GEN_REG_3	RO	0x00
0x A4	A2D_ANA_GEN_REG_4	RO	0x00
0x A5	A2D_ANA_GEN_REG_5	RO	0x00
ANALOG_REGISTERS			
0xC0	ANA_EN_SECTION_SEL	RW	0x00
0xC1	ANA_ENABLE_REG_0	RW	0x00
0xC2	ANA_ENABLE_REG_1	RW	0x02
0xC3	ANA_ENABLE_REG_2	RW	0x00
0xC4	ANA_ENABLE_REG_3	RW	0x00
0xC5	ANA_ENABLE_REG_4	RW	0x00
0xC6	ANA_ENABLE_REG_5	RW	0x00
0xC7	ANA_ENABLE_REG_6	RW	0x00
0xC8	ANA_ENABLE_REG_7	RW	0x00
0xC9	ANA_ENABLE_REG_8	RW	0x00
0xCA		ANA_ENABLE_REG_9	RW	0x00
0xCB	ANA_ENABLE_REG_10	RW	0x00
0xCC	ANA_ENABLE_REG_11	RW	0x00
0xCD	ANA_ENABLE_REG_12	RW	0x00
0xCE	ANA_ENABLE_REG_13	RW	0x00
0xCF	ANA_ENABLE_REG_14	RW	0x00
ANALOG_REGISTERS			
0xD0	ANA_GEN_SECTION_SEL	RW	0x00
0xD1	ANA_GEN_REG_1	RW	0x00
0xD2	ANA_GEN_REG_2	RW	0x00
0xD3	ANA_GEN_REG_3	RW	0x00
0xD4	ANA_GEN_REG_4	RW	0x00
0xD5	ANA_GEN_REG_5	RW	0x00
0xD6	ANA_GEN_REG_6	RW	0x00
0xD7	ANA_GEN_REG_7	RW	0x00
0xD8	ANA_GEN_REG_8	RW	0x00
0xD9	ANA_GEN_REG_9	RW	0x00
0xDA	ANA_GEN_REG_10	RW	0x00
0xDB	ANA_GEN_REG_11	RW	0x00
0xDC	ANA_GEN_REG_12	RW	0x00
0xDD	ANA_GEN_REG_13	RW	0x00
0xDE	ANA_GEN_REG_14	RW	0x00
0xDF	ANA_GEN_REG_15	RW	0x00
Part II: Waveform generator Register Map (Waveform generator reg Access command=1)
Drive A CH 1
0x00	AWG_CONFIG_REG0	RW	0x00
0x01	AWG_CTRL_REG0	RW	0x00
0x02	AWG_POINT_CONFIG_REG	RW	0x40
0x03	AWG_IN_WAVE_ADDR_REG0	RW	0x00
0x04	AWG_IN_WAVE_REG01	RW	0x00
0x05	AWG_REST_CLK_REG01	RW	0x00
0x06	AWG_REST_CLK_REG02	RW	0x00
0x07	AWG_REST_CLK_REG03	RW	0x00
0x08	AWG_SILENT_CLK_REG01	RW	0x00
0x09	AWG_SILENT_CLK_REG02	RW	0x00
0x0A	AWG_SILENT_CLK_REG03	RW	0x00
0x0B	AWG_SILENT_CLK_REG04	RW	0x00
0x0C	AWG_POS_PHASE_CLK_PNT_REG01	RW	0x00
0x0D	AWG_POS_PHASE_CLK_PNT_REG02	RW	0x00
0x0E	AWG_NEG_PHASE_CLK_PNT_ REG01	RW	0x00
0x0F	AWG_NEG_PHASE_CLK_PNT_ REG02	RW	0x00
0x10	AWG_REST_CLK1_REG01	RW	0x00
0x11	AWG_REST_CLK1_REG02	RW	0x00
0x12	AWG_SILENT_CLK1_REG01	RW	0x00
0x13	AWG_SILENT_CLK1_REG02	RW	0x00
0x14	AWG_SILENT_CLK1_REG03	RW	0x00
0x15	AWG_SILENT_CLK1_REG04	RW	0x00
0x16	AWG_POS_PHASE_CLK1_PNT_REG01	RW	0x00
0x17	AWG_POS_PHASE_CLK1_PNT_REG02	RW	0x00
0x18	AWG_NEG_PHASE_CLK1_PNT_ REG01	RW	0x00
0x19	AWG_NEG_PHASE_CLK1_PNT_ REG02	RW	0x00
0x1A	AWG_REST_CLK2_REG01	RW	0x00
0x1B	AWG_REST_CLK2_REG02	RW	0x00
0x1C	AWG_SILENT_CLK2_REG01	RW	0x00
0x1D	AWG_SILENT_CLK2_REG02	RW	0x00
0x1E	AWG_SILENT_CLK2_REG03	RW	0x00
0x1F	AWG_SILENT_CLK2_REG04	RW	0x00
0x20	AWG_POS_PHASE_CLK2_PNT_REG01	RW	0x00
0x21	AWG_POS_PHASE_CLK2_PNT _REG02	RW	0x00
0x22	AWG_NEG_PHASE_CLK2_PNT_REG01	RW	0x00
0x23	AWG_NEG_PHASE_CLK2_PNT_ REG02	RW	0x00
0x24	AWG_DELAY_LIM_REG01	RW	0x00
0x25	AWG_DELAY_LIM_REG02	RW	0x00
0x26	AWG_NEG_SCALE_REG0	RW	0x01
0x27	AWG_NEG_OFFSET_REG0	RW	0x00
0x28	AWG_POS_SCALE_REG0	RW	0x01
0x29	AWG_POS_OFFSET_REG0	RW	0x00
0x2A	AWG_PULLBA_REG	RW	0x00
0x2B	AWG_INT_NUM_ REG02	RW	0x00
0x2C	AWG_INT_REG01	RW	0x00
0x2D	AWG_INT_REG02	RW	0x00
0x2E	AWG_INT_REG02	RW	0x00
0x2F	AWG_ALT_LIM_REG01	RW	0x00
0x30	AWG_ALT_LIM_REG02	RW	0x00
0x31	AWG_ALT_SILENT_LIM_REG01	RW	0x00
0x32	AWG_ALT_SILENT_LIM_REG02	RW	0x00
0x33	AWG_ALT_REST_LIM_REG01	RW	0x00
0x34	AWG_ALT_REST_LIM_REG02	RW	0x00
0x35	DRIVE_REG_CTRL0	RW	0x00
0x36	DRIVE_REG_CTRL1	RW	0x00
0X37	DRIVE_REG_CTRL2	RW	0x00
0x38	NO_OF_NUM_SILENT_CTR0	RW	0x00
0x39	NO_OF_NUM_SILENT_TAR1	RW	0x05
0x3a	NO_OF_NUM_SILENT_TAR2	RW	0x00
0x3b	ADDR_IS_VALID_FOR_CAL	RW	0x00
0x3c	EMS_REG_CRAL	RW	0x00
0x3d	EMS_DATA_NUM	RW	0x00
0x3e	AWG_DRIVEC_SW_CFG0	RW	0x00
0x3f	AWG_DRIVEC_SW_CFG1	RW	0x00
Drive A CH 2
			
Register Name Change Log
Offset	Register name (Updated)	Register name (Previous)
	General Register	Normal Register
	AWG Register	Wavegen Register
0x00	AWG_CONFIG_REG0	ADDR_WG_DRV_CONFIG_REG0
0x01	AWG_CTRL_REG0	ADDR_WG_DRV_CTRL_REG0
0x02	AWG_POINT_CONFIG_REG	DDR_WG_DRV_POINT_CONFIG
0x03	AWG_IN_WAVE_ADDR_REG0	ADDR_WG_DRV_IN_WAVE_ADDR_REG0
0x04	AWG_IN_WAVE_REG01	ADDR_WG_DRV_IN_WAVE_REG01
0x05	AWG_REST_CLK_REG01	ADDR_WG_DRV_REST_CLK_REG01
0x06	AWG_REST_CLK_REG02	ADDR_WG_DRV_REST_CLK_REG02
0x07	AWG_SILENT_CLK_REG01	ADDR_WG_DRV_SILENT_CLK_REG01
0x08	AWG_SILENT_CLK_REG02	ADDR_WG_DRV_SILENT_CLK_REG02
0x09	AWG_SILENT_CLK_REG03	ADDR_WG_DRV_SILENT_CLK_REG03
0x0A	AWG_POS_PHASE_CLK_PNT_REG01	ADDR_WG_DRV_HLF_WAVE_CLK_PNT_REG01
0x0B	AWG_POS_PHASE_CLK_PNT_REG02	ADDR_WG_DRV_HLF_WAVE_CLK_PNT _REG02
0x0C	AWG_NEG_PHASE_CLK_PNT_REG01	ADDR_WG_DRV_NEG_HLF_WAVE_ CLK_PNT _ REG01
0x0D	AWG_NEG_PHASE_CLK_PNT_REG02	ADDR_WG_DRV_NEG_HLF_WAVE_ CLK_PNT _ REG02
0x0E	AWG_REST_CLK1_REG01	ADDR_WG_DRV_REST_CLK1_REG01
0x0F	AWG_REST_CLK1_REG02	ADDR_WG_DRV_REST_CLK1_REG02
0x10	AWG_SILENT_CLK1_REG01	ADDR_WG_DRV_SILENT_CLK1_REG01
0x11	AWG_SILENT_CLK1_REG02	ADDR_WG_DRV_SILENT_CLK1_REG02
0x12	AWG_SILENT_CLK1_REG03	ADDR_WG_DRV_SILENT_CLK1_REG03
0x13	AWG_POS_PHASE_CLK1_PNT_REG01	ADDR_WG_DRV_HLF_WAVE_CLK1_PNT_REG01
0x14	AWG_POS_PHASE_CLK1_PNT_REG02	ADDR_WG_DRV_HLF_WAVE_CLK1_PNT _REG02
0x15	AWG_NEG_PHASE_CLK1_PNT_REG01	ADDR_WG_DRV_NEG_HLF_WAVE_ CLK1_PNT _ REG01
0x16	AWG_NEG_PHASE_CLK1_PNT_REG02	ADDR_WG_DRV_NEG_HLF_WAVE_ CLK1_PNT _ REG02
0x17	AWG_REST_CLK2_REG01	ADDR_WG_DRV_REST_CLK2_REG01
0x18	AWG_REST_CLK2_REG02	ADDR_WG_DRV_REST_CLK2_REG02
0x19	AWG_SILENT_CLK2_REG01	ADDR_WG_DRV_SILENT_CLK2_REG01
0x1A	AWG_SILENT_CLK2_REG02	ADDR_WG_DRV_SILENT_CLK2_REG02
0x1B	AWG_SILENT_CLK2_REG03	ADDR_WG_DRV_SILENT_CLK2_REG03
0x1C	AWG_POS_PHASE_CLK2_PNT_REG01	ADDR_WG_DRV_HLF_WAVE_CLK2_PNT_REG01
0x1D	AWG_POS_PHASE_CLK2_PNT_REG02	ADDR_WG_DRV_HLF_WAVE_CLK2_PNT _REG02
0x1E	AWG_NEG_PHASE_CLK2_PNT_REG01	ADDR_WG_DRV_NEG_HLF_WAVE_ CLK2_PNT _ REG01
0x1F	AWG_NEG_PHASE_CLK2_PNT_REG02	ADDR_WG_DRV_NEG_HLF_WAVE_ CLK2_PNT_ REG02
0x20	AWG_DELAY_LIM_REG01	ADDR_WG_DRV_DELAY_LIM_REG01
0x21	AWG_DELAY_LIM_REG02	ADDR_WG_DRV_DELAY_LIM_REG02
0x22	AWG_NEG_SCALE_REG0	ADDR_WG_DRV_NEG_SCALE_REG 0
0x23	AWG_NEG_OFFSET_REG0	ADDR_WG_DRV_NEG_OFFSET_REG 0
0x24	AWG_POS_SCALE_REG0	ADDR_WG_DRV_POS_SCALE_REG0
0x25	AWG_POS_OFFSET_REG0	ADDR_WG_DRV_POS_OFFSET_REG0
0x26	AWG_DEBOUNCE_REG	ADDR_WG_DRV_SHORT PULLB/A TO GROUND_REG
0x27	AWG_INT_NUM_ REG02	ADDR_WG_DRV_INT_NUM_ REG02
0x28	AWG_INT_REG01	ADDR_WG_DRV_INT_REG01
0x29	AWG_INT_REG02	ADDR_WG_DRV_INT_REG02
0x2A	AWG_INT_REG02	ADDR_WG_DRV_INT_REG02
0x2B	AWG_ALT_LIM_REG01	ADDR_WG_DRV_ALT_LIM_REG01
0x2C	AWG_ALT_LIM_REG02	ADDR_WG_DRV_ALT_LIM_REG02
0x2D	AWG_ALT_SILENT_LIM_REG01	ADDR_WG_DRV_ALT_SILENT_LIM_REG01
0x2E	AWG_ALT_SILENT_LIM_REG02	ADDR_WG_DRV_ALT_SILENT_LIM_REG02
0x2F	DRIVE_REG_CTRL0	DRIVE_REG_CTRL0
0x30	DRIVE_REG_CTRL1	DRIVE_REG_CTRL1
0x31	DRIVE_REG_CTRL2	DRIVE_REG_CTRL2
0x32~3F	-	-
Drive A2
0x40	AWG_CONFIG_REG0	ADDR_WG_DRV_CONFIG_REG0
0x41	AWG_CTRL_REG0	ADDR_WG_DRV_CTRL_REG0
0x42	AWG_POINT_CONFIG_REG	DDR_WG_DRV_POINT_CONFIG
0x43	AWG_IN_WAVE_ADDR_REG0	ADDR_WG_DRV_IN_WAVE_ADDR_REG0
0x44	AWG_IN_WAVE_REG01	ADDR_WG_DRV_IN_WAVE_REG01
0x45	AWG_REST_CLK_REG01	ADDR_WG_DRV_REST_CLK_REG01
0x46	AWG_REST_CLK_REG02	ADDR_WG_DRV_REST_CLK_REG02
0x47	AWG_SILENT_CLK_REG01	ADDR_WG_DRV_SILENT_CLK_REG01
0x48	AWG_SILENT_CLK_REG02	ADDR_WG_DRV_SILENT_CLK_REG02
0x49	AWG_SILENT_CLK_REG03	ADDR_WG_DRV_SILENT_CLK_REG03
0x4A	AWG_POS_PHASE_CLK_PNT_REG01	ADDR_WG_DRV_HLF_WAVE_CLK_PNT_REG01
0x4B	AWG_POS_PHASE_CLK_PNT_REG02	ADDR_WG_DRV_HLF_WAVE_CLK_PNT_REG02
0x4C	AWG_NEG_PHASE_CLK_PNT_REG01	ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT_REG01
0x4D	AWG_NEG_PHASE_CLK_PNT_REG02	ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT_REG02
0x4E	AWG_REST_CLK1_REG01	ADDR_WG_DRV_REST_CLK1_REG01
0x4F	AWG_REST_CLK1_REG02	ADDR_WG_DRV_REST_CLK1_REG02
0x50	AWG_SILENT_CLK1_REG01	ADDR_WG_DRV_SILENT_CLK1_REG01
0x51	AWG_SILENT_CLK1_REG02	ADDR_WG_DRV_SILENT_CLK1_REG02
0x52	AWG_SILENT_CLK1_REG03	ADDR_WG_DRV_SILENT_CLK1_REG03
0x53	AWG_POS_PHASE_CLK1_PNT_REG01	ADDR_WG_DRV_HLF_WAVE_CLK1_PNT_REG01
0x54	AWG_POS_PHASE_CLK1_PNT_REG02	ADDR_WG_DRV_HLF_WAVE_CLK1_PNT_REG02
0x55	AWG_NEG_PHASE_CLK1_PNT_REG01	ADDR_WG_DRV_NEG_HLF_WAVE_ CLK1_PNT_REG01
0x56	AWG_NEG_PHASE_CLK1_PNT_REG02	ADDR_WG_DRV_NEG_HLF_WAVE_ CLK1_PNT_REG02
0x57	AWG_REST_CLK2_REG01	ADDR_WG_DRV_REST_CLK2_REG01
0x58	AWG_REST_CLK2_REG02	ADDR_WG_DRV_REST_CLK2_REG02
0x59	AWG_SILENT_CLK2_REG01	ADDR_WG_DRV_SILENT_CLK2_REG01
0x5A	AWG_SILENT_CLK2_REG02	ADDR_WG_DRV_SILENT_CLK2_REG02
0x5B	AWG_SILENT_CLK2_REG03	ADDR_WG_DRV_SILENT_CLK2_REG03
0x5C	AWG_POS_PHASE_CLK2_PNT_REG01	ADDR_WG_DRV_HLF_WAVE_CLK2_PNT_REG01
0x5D	AWG_POS_PHASE_CLK2_PNT_REG02	ADDR_WG_DRV_HLF_WAVE_CLK2_PNT _REG02
0x5E	AWG_NEG_PHASE_CLK2_PNT_REG01	ADDR_WG_DRV_NEG_HLF_WAVE_ CLK2_PNT_REG01
0x5F	AWG_NEG_PHASE_CLK2_PNT_REG02	ADDR_WG_DRV_NEG_HLF_WAVE_ CLK2_PNT_REG02
0x60	AWG_DELAY_LIM_REG01	ADDR_WG_DRV_DELAY_LIM_REG01
0x61	AWG_DELAY_LIM_REG02	ADDR_WG_DRV_DELAY_LIM_REG02
0x62	AWG_NEG_SCALE_REG0	ADDR_WG_DRV_NEG_SCALE_REG 0
0x65	AWG_NEG_OFFSET_REG0	ADDR_WG_DRV_NEG_OFFSET_REG 0
0x64	AWG_POS_SCALE_REG0	ADDR_WG_DRV_POS_SCALE_REG0
0x65	AWG_POS_OFFSET_REG0	ADDR_WG_DRV_POS_OFFSET_REG0
0x66	AWG_DEBOUNCE_REG	ADDR_WG_DRV_SHORT PULLB/A TO GROUND_REG
0x67	AWG_INT_NUM_ REG02	ADDR_WG_DRV_INT_NUM_ REG02
0x68	AWG_INT_REG01	ADDR_WG_DRV_INT_REG01
0x69	AWG_INT_REG02	ADDR_WG_DRV_INT_REG02
0x6A	AWG_INT_REG02	ADDR_WG_DRV_INT_REG02
0x6B	AWG_ALT_LIM_REG01	ADDR_WG_DRV_ALT_LIM_REG01
0x6C	AWG_ALT_LIM_REG02	ADDR_WG_DRV_ALT_LIM_REG02
0x6D	AWG_ALT_SILENT_LIM_REG01	ADDR_WG_DRV_ALT_SILENT_LIM_REG01
0x6E	AWG_ALT_SILENT_LIM_REG02	ADDR_WG_DRV_ALT_SILENT_LIM_REG02
0x6F	DRIVE_REG_CTRL0	DRIVE_REG_CTRL0
0x70	DRIVE_REG_CTRL1	DRIVE_REG_CTRL1
0x71	DRIVE_REG_CTRL2	DRIVE_REG_CTRL2
0x72~0x7F	-	-
General Register
PMU_REG: 0x01 (General Register)
Bit	Field Name	Attribute	Default	Description
7	Reserved	RW	0	
6	MULTI_INTB_PIN	RW	1	0: All interrupts are combined into a single pin.
1: Interrupts are separated into four pins.
5	WAVE_GEN_RESET	RW	1’b0	SW Wave Generator Reset
0: Inactive Reset
1: Active reset
4	WAVE_GEN_DISABLE	RW	1’b0	Wavegen Disable Signal
0: Wavegen is enabled
1: Wavegen is disabled
3	OTP_DEEPSLEEP_STANDBY_EN	RW	1’b0	OTP Gated Clock Enable
0: Disable OTP clock gating
1: Enable OTP clock gating
2	HRESET_REQ	RW	1’b0	Software active clock Request
0: don’t active clock
1: Active clock
1	SLEEP_DEEP_EN	RW	1’b0	Sleep Deep Mode Enable
0: Disable
1: Enable
0	PMU_EN 	RW	1’b1	PMU Enable
0: Disable
1: Enable

CLK_CTRL_REG: Offset - 0x02 (General Register)
Bit	Field Name	Attribute	Default	Description
7:4	ICLK_DIV	R/W	4’h3	ADC clock divider
000: divided by 1
001: divided by 2
010: divided by 4
011: divided by 8
100: divided by 16
101: divided by 32
110: divided by 64
111: divided by 128
1000: divided by 256
1001: divided by 512
1010: divided by 1024
1011: divided by 2048
Others: divided by 2
3	INT_CLK_OUT	WR	1’b0	There are 2 ways to enable internal clock to be output to GPIO9, one is controlled by GPIO, one is controlled by this register. One of them can control internal clock to be output.

Internal clock will be output to GPIO9 for multiple chip applications.

If GPIO controlled output is disabled, then
0: Disable
1: Enable

if GPIO control output is enabled, no matter what value to be set, the internal clock will be output. It is same when this bit is set, no matter GPIO control is enabled or not, the internal clock will be output

2:0	PCLK_DIV	WR	3’b000	PCLK Divider: (PCLK=FCLK/2^PCLK_DIV)

000: FCLK not divided
001: FCLK divided by 2
010: FCLK divided by 4
011: FCLK divided by 8
100: FCLK divided by 16
101: FCLK divided by 32
110: FCLK divided by 64 (can’t be used for OTP READ)
111: FCLK divided by 128(can’t be used for OTP READ)
Pclk should be faster than ADC clock

WAVEGEN_GLOBAL_REG_0: 0x03 (General Register)
Bit	Field Name	Attribute	Default	Description
7:5	RESERVED	RO	5’h00	No use
4	BURST_FOR_SHAPE_REG	RW	1’b0	0: burst function for wavegen config register
1: burst function for wavegen shape register

Note: must be enable burst of spi bus
3	STIMU_EN	RW	1’b0	D2A_STIMU_EN：
Control signal for two big power switch (5V and 1.8V)
2:1	DRIVE_SLCT	RW	2’b00	This register is used to control the selection of Wavegen. When writing to or reading from the Wavegen registers using SPI:

2‘b00: Select DRIVER0~DRIVER3 as the write/read objects.
2‘b01:   Select DRIVER4~DRIVER7 as the write/read objects.
2‘b10: Select DRIVER8~DRIVER11 as the write/read objects.
2‘b11:   Select DRIVER12~DRIVER15 as the write/read objects.
0	GLOBE_DRIVE_EN	RW	1’b0	Globe Drive Enable 

1: Enable
0: Disable
All 16 drivers can be driven at the same time
ANAC_CTRL: 0x04 (General Register)
Bit	Field Name	Attribute	Default	Description
7	ICLK_INA_PGA_DISABLE	 RW	1’b0	PGA clock disable
0: enable
1: disable
6:4	ICLK_INA_PGA_DIV	RW	3’h3	Analog pga clock dividor
000: fclk
001: fclk/2
010: fclk/4
011: fclk/8
100: fclk/16
101: fclk/32
110: fclk/64
111: fclk/128
3	TEMP_SAR_CLK_DISABLE	RW	1’b0	Temp SAR module clock disable
0: Enable
1: Disable
2	TEMP_SAR_RESET	RW	1’b0	Temp SAR control reset
0: dont’ reset
1: reset
1	ANAC_RESET	RW	1’b0	ANAC block reset
0: don’t reset
1: reset
0	ANAC_CLOCK_EN	RW	1’b0	ANAC Clock Enable
0: Enable
1: Disable
PMU_REG1: 0x05 (General Register)
Bit	Field Name	Attribute	Default	Description
7:2	RESERVED	RO	6’h00	No Use
1	DIG_RESET_EN	WR	1’b1	Digital Reset Signal
1: Inactive Reset
0: Active Reset
0	OTP_RESET_EN	WR	1’b0	OTP Reset Signal
1: Active Reset
0: Inactive Reset
O_CLK_SEL: 0x06 (General Register)
Bit	Field Name	Attribute	Default	Description
7:1	RESERVED	RO	7’h00	
0	O_CLK_SEL	RW	1’b0	Select output to outside clock source
0: Internal OSC
1: Mux of Internal and external OSC

WAVEGEN_GLOBAL_REG_01: 0x07 (General Register)
Bit	Field Name	Attribute	Default	Description
7	WAVEGEN_REG_ACCE7	RW	0	Driver7：
0 ：disable mul-wavegen access function
1： enable mul-wavegen access function
6	WAVEGEN_REG_ACCE6	RW	0	Driver6：
0 ：disable mul-wavegen access function
1： enable mul-wavegen access function
5	WAVEGEN_REG_ACCE5	RW	0	Driver5：
0 ：disable mul-wavegen access function
1： enable mul-wavegen access function
4	WAVEGEN_REG_ACCE4	RW	0	Driver4：
0 ：disable mul-wavegen access function
1： enable mul-wavegen access function
3	WAVEGEN_REG_ACCE3	RW	0	Driver3：
0 ：disable mul-wavegen access function
1： enable mul-wavegen access function
2	WAVEGEN_REG_ACCE2	RW	0	Driver2：
0 ：disable mul-wavegen access function
1： enable mul-wavegen access function
1	WAVEGEN_REG_ACCE1	RW	0	Driver1：
0 ：disable mul-wavegen access function
1： enable mul-wavegen access function
0	WAVEGEN_REG_ACCE0	RW	0	Driver0：
0 ：disable mul-wavegen access function
1： enable mul-wavegen access function

WAVEGEN_GLOBAL_REG_02: 0x08 (General Register)
Bit	Field Name	Attribute	Default	Description
7	WAVEGEN_REG_ACCE15	RW	0	Driver15：
0 ：disable mul-wavegen access function
1： enable mul-wavegen access function
6	WAVEGEN_REG_ACCE14	RW	0	Driver14：
0 ：disable mul-wavegen access function
1： enable mul-wavegen access function
5	WAVEGEN_REG_ACCE13	RW	0	Driver13：
0 ：disable mul-wavegen access function
1： enable mul-wavegen access function
4	WAVEGEN_REG_ACCE12	RW	0	Driver12：
0 ： disable mul-wavegen access function
1：enable mul-wavegen access function
3	WAVEGEN_REG_ACCE11	RW	0	Driver11：
0 ：disable mul-wavegen access function
1： enable mul-wavegen access function
2	WAVEGEN_REG_ACCE10	RW	0	Driver10：
0 ：disable mul-wavegen access function
1： enable mul-wavegen access function
1	WAVEGEN_REG_ACCE9	RW	0	Driver9：
0 ：disable mul-wavegen access function
1： enable mul-wavegen access function
0	WAVEGEN_REG_ACCE8	RW	0	Driver8：
0 ：disable mul-wavegen access function
1： enable mul-wavegen access function

  OTP registers
Debug1 register: 0x0A
Bit	Field Name	 Type	Default	Description
7 	LOADING_SHADOWS	RO 	1’b1	Shadow Register Loading Status 
1: Loading is on progress
0: Loading is done
6 	WR_WORKING	RO 	1’b0 	OTP Memory Program Status in OTP IP
1: Program is on progress
0: Program is done
5 	RELOAD_DONE	RO 	1’b0 	Reload Done from OTP to SPI Registers Status 

1:  Reload is done
0:  Reload is on progress
4 	OTP_IP_WR_ENTER	RO 	1’b0 	PPROG signal Monitor control in OTP IP
1: asserted
0: de-asserted
3 	OTP_IP_READ	RO 	1’b0 	POR signal Monitor in OTP IP 
1: Loading is on progress
0: Loading is done
2 	OTP_IP_WR	RO 	1’b0 	WR signal Monitor in OTP IP
1: asserted
0: de-asserted
1 :0	OTP_IP_PTM	RO 	1’b0 	PTM Signal Monitor control in OTP IP
1: asserted
0: de-asserted



Debug2 register: 0x0B
Bit  	Field name	 Type  	Default 	Description
7:1	RESERVED	RO 	7’h00 	Not used 
0	OTP_VPP_STATUS	RO 	1’b0 	OTP VPP Status
1 : VPP enable
0: VPP disable

 
Trim Tag register: 0x0C (General Register)    
Bit	Field Name	 Attribute	Default 	Description
7:0	TRIM_TAG_REG	RW 	0x00	Trim Tag Register
 
TRIM_DATA_1 register: 0x0D (General Register)   
Bit	Field Name	 Attribute  	Default 	Description
7:0	D2A_TRIM1_TO_OTP	RW 	0x00	Analog Trim 1
TRIM_DATA_2 register: 0x0E (General Register)    
Bit  	Field Name	 Attribute  	Default 	Description
7:0 	D2A_TRIM2_TO_OTP	RW 	0x00	Analog Trim 2

TRIM_DATA_3 register: 0x0F (General Register)   
Bit  	Field Name	 Attribute  	Default 	Description
7:0	D2A_TRIM3_TO_OTP	RW 	0x00	Analog Trim 3

TRIM_DATA_4 register: 0x10 (General Register)   
Bit  	Field Name	 Attribute  	Default 	Description
7:0	D2A_TRIM4_TO_OTP	RW 	0x00	Analog Trim 4

 TRIM_DATA_5 register: 0x11(General Register)   
Bit  	Field Name	 Attribute  	Default 	Description
7:0 	D2A_TRIM5_TO_OTP	RW 	0x00	Analog Trim 5

 TRIM_DATA_6 register: 0x12(General Register)   
Bit  	Field Name	 Attribute  	Default 	Description
7:0 	D2A_TRIM6_TO_OTP	RW 	0x00	Analog Trim 6

TRIM_DATA_7 register: 0x13 (General Register)   
Bit  	Field Name	 Attribute  	Default 	Description
7:0 	D2A_TRIM7_TO_OTP	RW 	0x00	Analog Trim 7

TRIM_DATA_8 register: 0x14 (General Register)   
Bit	Field Name	 Attribute  	Default 	Description
7:0	D2A_TRIM8_TO_OTP	RW 	0x00	Analog Trim 8

TRIM_DATA_9 register: 0x15 (General Register)   
Bit	Field Name	 Attribute  	Default 	Description
7:0	D2A_TRIM9_TO_OTP	RW 	0x00	Analog Trim 9

TRIM_DATA_10 register: 0x16 (General Register)   
Bit	Field Name	 Attribute  	Default 	Description
7:0	D2A_TRIM10_TO_OTP	RW 	0x00	Analog Trim 10

TRIM_DATA_11 register: 0x17 (General Register)   
Bit	Field Name	 Attribute  	Default 	Description
7:0	D2A_TRIM11_TO_OTP	RW 	0x00	Analog Trim 11

TRIM_DATA_12 register: 0x18 (General Register)   
Bit	Field Name	 Attribute  	Default 	Description
7:0	D2A_TRIM12_TO_OTP	RW 	0x00	Analog Trim 12

TRIM_DATA_13 register: 0x19 (General Register)   
Bit	Field Name	 Attribute  	Default 	Description
7:0	D2A_TRIM13_TO_OTP	RW 	0x00	Analog Trim 13


TRIM_DATA_14 register: 0x1A (General Register)   
Bit	Field Name	 Attribute  	Default 	Description
7:0	D2A_TRIM14_TO_OTP	RW 	0x00	Analog Trim 14

TRIM_DATA_15 register: 0x1B (General Register)   
Bit	Field Name	 Attribute  	Default 	Description
7:0	D2A_TRIM15_TO_OTP	RW 	0x00	Analog Trim 15


TRIM_DATA_16 register: 0x1C (General Register)   
Bit	Field Name	 Attribute  	Default 	Description
7:0	PROD_ID	RO	0x00	The product ID. can only be modified through OTP BIST.



OTP_UNLOCK Register: 0x1D (General Register)   
Bit	Field Name	 Attribute	Default	Description
7:3	KEY-WORD	RW	5’h0 	KEY-WORD: Key to access from SPI registers to/from OTP or SPI read from OTP 
5’b10101: can write trim by bit0/bit1
5’b01010: can write data into OTP by bit-0 / read data from OTP by bit-2
Others: no operation 
2	SPI_READ_OTP_EN	RW
	1’b0	SPI Read OTP Enable
1: Enable
0: Disable
Notes: the read command which is used to read data from OTP
1	SPI_WR_SHADOW_EN	RW 	1’b0 	SPI Write Shadows Registers Enable
1: Programming data to shadow registers
0: No operationFor bit1, the registers are not automatically cleared.
0 	UNLOCK	RW 	1’b0 	Unlock bit for OTP Program
1: Programming data to OTP
0: No operation For bit0, the register is automatically cleared after the write operation is complete.

OTP_DATA (0x1E) register (General Register)
Bit  	Field name	 Type  	Default 	Description
7:0 	OTP PROGRAM DATA	RW 	8’h00	The data for SPI write/program function to UNTRIM area in OTP

OTP_ADDR (0x1F) register:
Bit  	Field name	 Type  	Default 	Description
7:0 	OTP ADDRESS	RW 	8’h00	The address for random SPI read/write function, the range of this registers should be ：
1. OTP0 for storing trim and filter coefficients
address for storing trim the range from 0x00~0x0f is invalid
address for storing filter coefficients, the range from 0x10 ~0x7f is valid
2. OTP1 for storing current calibration coefficients, the addresses range from 0x00 ~0x7f is valid

OTP_EME_DATA (0x20) register (General Register)
Bit  	Field name	 Type  	Default 	Description
7:0 	OTP READ DATA	RO 	8’h00	The data from UNTRIM OTP area to SPI Register

Note: After sending the READ CMD, in theory, around 5 pclks are needed to wait to read the data.
OTP_WAVEGEN_NUMBER (0x21) register (General Register)
Bit  	Field name	 Type  	Default 	Description
7:3 	RESERVED	RO 	5’h00	-
2:0	OTP_SELECT	RW	3’b000	For selecting which OTP to read or write

3’b000：OTP0 for storing trim and filter coefficients
3’b001: . OTP1 for storing current calibration coefficients

GPIO Registers
NOTE: Non-configurable IO cells are FLOATING by default, except:
	Resetn: PULLUP
	TESTMODE0 & TESTMODE1: PULLDOWN
GPIO_PU_CTRL: 0x30 (General Register)
IO cell pullup configuration only supported for GPIO[3] ~ GPIO[5]  
Bit	Field Name	Attribute	Default	Description
7:3	RESERVED	RO	5’b0	Reserved
2	GPIO[5] - SPI_MOSI	RW	1’b0	0:  FLOATING
1:  PULLUP
1	GPIO[4] - SPI_SCK	RW	1’b0	0:  FLOATING
 1:  PULLUP
0	GPIO[3] - SPI_CS	RW	1’b0	0:  FLOATING
1:  PULLUP

GPIO_PD_CTRL: 0x31 (General Register)
In normal mode IO cell configuration of DS common bits used for GPIO0 ~ GPIO10
Bit	Field Name	Attribute	Default	Description
7:5	RESERVED	RO	3’b0	Reserved
4	GPIO[13] - INT_OSC_OUT_EN	RW	1’b1	0:  FLOATING
1:  PULLDOWN
3	GPIO[2] - CPHA	RW	1’b1	0:  FLOATING
1:  PULLDOWN
2	GPIO[1] – CPOLn	RW	1’b1	0:  FLOATING
1:  PULLDOWN
1	GPIO[0] – EXT_CLK	RW	1’b1	0:  FLOATING
1:  PULLDOWN
0	CLK_SEL	RW	1’b1	0:  FLOATING
1:  PULLDOWN
GPIO_SR_PDRV0_1_CTRL: 0x32 (General Register)
In normal mode IO cell configuration of SR/PDRV0/PDRV1 common bits used for GPIO0 ~ GPIO10
Bit	Field Name	Attribute	Default	Description
7:3	RESERVED	RO	5’b0	Reserved
2	PDRV1	RW	1’b0	Output drive strength
 00: 4mA
 01: 8mA
10: 12mA
11: 16mA
1	PDRV0	RW	1’b0	
0	SR	RW	1’b0	Output Slew Rate
0:  Fast
1:  Slow


GPIO_NIRS_OUT_CTRL: 0x33 (General Register) 
Controls the output of NIRS module during Normal Mode for GPIO[15]-GPIO[19]
Bit	Field Name	Attribute	Default	Description
7:1	RESERVED	RO	7’b0	Reserved
0	NIRS_OUT_CTRL	RW	1’b0	Selects the output signal driven to GPIO pads:
1: Output analog control signals
- IO_PAD[15] = NIRS_RESET_SW0
- IO_PAD[16] = NIRS_IPD_SW0
- IO_PAD[17] = NIRS_IIN_SW0
- IO_PAD[18] = A2D_IREFCOARSE0
- IO_PAD[19] = A2D_IREFFINE0
0: Output LED control signals:
- IO_PAD[15] = NIRS_LED_ON1
- IO_PAD[16] = NIRS_LED_ON2
- IO_PAD[17] = NIRS_LED_ON3
- IO_PAD[18] = NIRS_LED_ON4
- IO_PAD[19] = NIRS_LED_ON5

GPIO_NORMAL_OUT_CTRL: 0x34 (General Register) – 
Controls the output of GPIO8 during Normal Mode
Bit	Field Name	Attribute	Default	Description
7:1	RESERVED	RO	7’b0	Reserved
0	NORMAL_OUT_CTRL	RW	1’b0	0: INT0
1: VPP_EN

Lead Off Detection Register
LEAD_OFF_CTRL: LEAD OFF detection control: 0x26 (General Register)
Bit	Field Name	Attribute	Default	Description
7:1	RESERVED	RW	7’h0	No Use
0	SHORT_DETECT_BY_LEAD_OFF_EN	RW	1’b0	Just in case want to use lead off comparator to do the short
0: use lead off comparator output
1: use short comparator output
When this bit is 1, then don’t set bit1(COMPARE_REVERSE) to 1
RESERVED: Reserved Register – Offset: 0x27 (General Register)
Bit	Field Name	Attribute	Default	Description
7:0	 RESERVED	RW	0x0	 No use

LEAD_OFF_INT: Lead Off Detection Interrupt Control: 0x28 (General Register)

Bit	Field Name	Attribute	Default	Description
7:0	LEAD_OFF_CH_STATUS	RW/R1C	0	Clear the Channel 1 interrupt for 8 Channel 0-7

When write
0: don’t write 0 if you don’t want to be 0 by writing, it will set this register to 0
1: clear
When read:
Lead off channel 1 interrupt status

This bit can be cleared by reading  this bit 1

COUNTER_TH_TGT_CH: channel comparator status counter target 0x29-0x2C (General Register)
Bit	Field Name	Attribute	Default	Description
31:0	 COUNTER_TH_TGT _CH	RW	0x00	 Channel  target counter of A2D_COMP_CH1
0x29 is lower byte, 0x2c is higher byte
TIMER_CNT_TGT_CH1: Channel check duration target 0x2D-0x30 (General Register)
Bit	Field Name	Attribute	Default	Description
31:0	 TIMER_CNT_TGT_CH	RW	0x00	 Channel  target counter duration for check the lead off result
0x2D is lowest 8-bit, 0x30 is highest 8-bit
LEAD_OFF_BLK_SLCT:  channel number of leadoff config 0x31 (General Register)
Bit	Field Name	Attribute	Default	Description
7:4	 RESERVED	RO	0x0	 No Use
3:0	 LEAD_OFF_BLK_SLCT	RW	0x0	 Lead off channel config indicator

LEAD_OFF_DAC_EN: lead off channel enable 0x32 (General Register)
Bit	Field Name	Attribute	Default	Description
7:0	LEAD_OFF_DAC_EN	RW	0	8-bit for 8 Drivers of Wavegen

When this DAC_EN bit is 1 and LEAD_OFF_EN（pmu0[6]) is ON and  wavegen related channel is 1 then Leadoff of that channel detection will be ON

Bit x: 
 1: DACx Enable
0: DACx Disable


LEAD_OFF_STOP_EN: lead off stop wavegen enable 0x33 (General Register)
Bit	Field Name	Attribute	Default	Description
7:0	LEAD_OFF_STOP_EN	RW	0	8-bit for 8 Drivers of Wavegen

0: Lead Off don’t affect the Wavegen generation of channel 
1: Lead Off will stop the Wavegen  generation of channel 

LEAD_OFF_INT_EN: lead off interrupt output enable 0x34 (General Register)
Bit	Field Name	Attribute	Default	Description
7:0	LEAD_OFF_INT_EN	RW	0	8-bit for 8 Drivers of Wavegen

This register only affect INT pin output or not, don’t affect interrupt status
Bit4: Channel  interrupt enable

0: interrupt is disabled
1: interrupt is enabled


LEAD_OFF_COMP_LOW_EN: low is lead off indicator 0x35 (General Register)
Bit	Field Name	Attribute	Default	Description
7:0	LEAD_OFF_COMP_LOW_EN	RW	0	8-bit for 8 Drivers of Wavegen

This signal shows the Active Level of Response.
0: A2D_COMP_CH is high active
1: A2D_COMP_CH is low active
Notes:
0: Lead off happens when A2D_COMP_CH is 0
1: Lead off happens when A2D_COMP_CH is 1

LEAD_OFF_STOP: state of wavegen should be when lead off happen 0x36 (General Register)
Bit	Field Name	Attribute	Default	Description	
7:0	 LEAD_OFF_STOP	RO	0	8-bit for 8 Drivers of Wavegen

When leadoff happens, these bits indicator the wavegen of different channel should be 
0: not stop
1: stop	

LEAD_OFF_ANA: Lead Off detection compare result from Analog: 0x39(General Register)
Bit	Field Name	Attribute	Default	Description
7:0	 A2D_COMP_CH2	RO	0	8-bit for 8 Drivers of Wavegen

Lead Off detection compare result from analog (comparator output of Driver A)

 Analog registers
There are two sections of ANA_ENABLE_REG and eight sections of ANA_GEN_REG. Each section contains 15 usable registers and one dedicated register for section select.
ANA_ENABLE_REG* registers:
0xC0 - ANA_EN_SECTION_SEL <- Section select
0xC1 – ANA_ENABLE_REG_0
…
0xCF – ANA_ENABLE_REG_14
ANA_GEN_REG* registers:
0xD0 - ANA_GEN_SECTION_SEL <- Section select
0xD1 – ANA_GEN_REG_1
…
0xDD – ANA_GEN_REG_13 
0xDE – ANA_GEN_REG_14 – SPARE
0xDF – ANA_GEN_REG_15 - ADJ

ANA_EN_SECTION_SEL: Offset: 0xC0
Bit	Field Name	Attribute	Default	Description
7:1	RESERVED	RO	7’h00	No use
0	ANA_EN_SECTION_SEL	RW	1’b0	Section selection for ANA Registers
  1’b0: section 0 (ANA_ENABLE_REG[0][n])
  1’b1: section 1 (ANA_ENABLE_REG[1][n])

ANA_ENABLE_REG[0][0]: Offset: 0xC1
Bit	Field Name	Attribute	Default	Description
7:6	RESERVED	RO	2’b0	No use
5:1	D2A_BIST_SEL	RW	5’b00000	Analog Bist Mode Select
  5’b00000: BG 
  5’b00001: Bandgap Buffer
  5’b00010: IREF 
  5’b00011: LDO 
  5’b00100: OSC 
  5’b00101: TSC 
  5’b00110: IDAC 
  5’b00111: SPARE
  5’b01000: SPARE
  5’b01001: SPARE
  5’b01010: SPARE
  5’b01011: SPARE
  5’b01100: SDM_BUF Negative output
  5’b01101: SDM_BUF Negative output
  5’b01110: Output SDM
  5’b01111: TSC_VDAC_OUT
 5’b10000: DC LEAD OFF ( Testing positive electrode)
 5’b10001: DC LEAD OFF ( Testing negative electrode)
  5’b10010: NIRS (IREF_COARSE)
  5’b10011: NIRS (IREF_FINE)
  5’b10100: NIRS (IDAC)
  5’b10101: Positive output for LNA
  5’b10110: Negative output for LNA
  5’b10111: Positive output for PGA
  5’b11000: Negative output for PGA
  5’b11001: VCM GEN Buffer
  5’b11010: SDM VCM Buffer
  5’b11011: VREFP Buffer for SDM
  5’b11100: RLD
  5’b11101: TSC_VDAC_OUT
0	D2A_BIST_EN	RW	1’b0	Analog BIST Mode Enable
  0: Disabled
  1: Enabled

ANA_ENABLE_REG[0][1]: Offset: 0xC2
Bit	Field Name	Attribute	Default	Description
7:5	RESERVED	RO	3’b0	No use
4	RESERVED	RO	1’b0	No use
3	RESERVED	RO	1’b0	No use
2	RESERVED	RO	1’b0	No use
1	D2A_OSC8MHZEN	RW	1’b1	OSC enable
0: Disable
1: Enable
0	D2A_BGBUFFER_CPTEST_EN	RW	1’b0	Frequency Compensation for 1.2V Buffer in CP test
0: Disable
1: Enable

ANA_ENABLE_REG[0][2]: Offset: 0xC3 
Bit	Field Name	Attribute	Default	Description
7:4	RESERVED	RO	4’b0	No use
3	D2A_SDMVREFPBUFF_EN	RW	1’b0	Enable SDM VREFP Buffer
0: Disable
1: Enable
2	D2A_SDMVCMBUFF_EN	RW	1’b0	Enable SDM VCM Buffer
0: Disable
1: Enable
1	D2A_VCMGENBUFF_EN	RW	1’b0	Enable General VCM Buffer
0: Disable
1: Enable
0	D2A_RLD_ELECTRODE_EN	RW	1’b0	Enable ELECTRODE
0: Disable
1: Enable

ANA_ENABLE_REG[0][3]: Offset: 0xC4
Bit	Field Name	Attribute	Default	Description
7:5	RESERVED	RO	3’b0	No use
4	D2A_DRIVERC_SHORT_DET_EN	RW	1’b0	short detection function enable
3	D2A_DRIVERC_LEAD_OFF_EN	RW	1’b0	lead off function enable
2	D2A_RLD_EN	RW	1’b0	Enable RLD
0: Disable
1: Enable
1	D2A_BIAS_MEAS	RW	1’b0	"Enable BIAS_IN for INN and INNP
0: Disable
1: if
D2A_EEG_CHx_SET<2:0>=100-->Bias Measurement (INP is connected to the output of RLD through BIASIN_PIN and INN is connected to VCM) (Main SW is open)
or
D2A_EEG_CHx_SET<2:0>=101-->Bias Measurement (INN is connected to the output of RLD through BIASIN_PIN and INP is connected to VCM) (Main SW is open)
"
0	D2A_LVD_EN	RW	1’b0	LVD enable

ANA_ENABLE_REG[0][4]: Offset: 0xC5
Bit	Field Name	Attribute	Default	Description
7:0	D2A_EEGLNA_EN[7:0]	RW	8’b0	Enable LNA
0: Disable
1: Enable

ANA_ENABLE_REG[0][5]: Offset: 0xC6
Bit	Field Name	Attribute	Default	Description
7:0	D2A_EEGLNA_EN[15:8]	RW	8’b0	Enable LNA
0: Disable
1: Enable

ANA_ENABLE_REG[0][6]: Offset: 0xC7
Bit	Field Name	Attribute	Default	Description
7:0	D2A_QSTRLNA_EN[7:0]	RW	8’b0	Enable quick start-up LNA
0: Disable
1: Enable
This interface should be user-controllable via SPI. It may be necessary to hold it high for a fixed duration (e.g., 50 ms) during LNA start-up (whenever the LNA is enabled) and then drive it low.

ANA_ENABLE_REG[0][7]: Offset: 0xC8
Bit	Field Name	Attribute	Default	Description
7:0	D2A_QSTRLNA_EN[15:8]	RW	8’b0	Enable quick start-up LNA
0: Disable
1: Enable
This interface should be user-controllable via SPI. It may be necessary to hold it high for a fixed duration (e.g., 50 ms) during LNA start-up (whenever the LNA is enabled) and then drive it low.

ANA_ENABLE_REG[0][8]: Offset: 0xC9
Bit	Field Name	Attribute	Default	Description
7:0	D2A_EEGPGA_EN[7:0]	RW	8’b0	Enable PGA
0: Disable
1: Enable
ANA_ENABLE_REG[0][9]: Offset: 0xCA
Bit	Field Name	Attribute	Default	Description
7:0	D2A_EEGPGA_EN[15:8]	RW	8’b0	Enable PGA
0: Disable
1: Enable

ANA_ENABLE_REG[0][10]: Offset: 0xCB
Bit	Field Name	Attribute	Default	Description
7:0	D2A_QSTRPGA_EN[7:0]	RW	8’b00	Enable quick start-up PGA
0: Disable
1: Enable
This interface should be user-controllable via SPI. It may be necessary to hold it high for a fixed duration (e.g., 50 ms) during PGA  start-up (whenever the LNA is enabled) and then drive it low.

ANA_ENABLE_REG[0][11]: Offset: 0xCC
Bit	Field Name	Attribute	Default	Description
7:0	D2A_QSTRPGA_EN[15:8]	RW	8’b0	Enable quick start-up PGA
0: Disable
1: Enable
This interface should be user-controllable via SPI. It may be necessary to hold it high for a fixed duration (e.g., 50 ms) during PGA  start-up (whenever the LNA is enabled) and then drive it low.

ANA_ENABLE_REG[0][12]: Offset: 0xCD
Bit	Field Name	Attribute	Default	Description
7:0	RESERVED	RO	8’h0	No use  

ANA_ENABLE_REG[0][13]: Offset: 0xCE
Bit	Field Name	Attribute	Default	Description
7:0	RESERVED	RO	8’h0	No use  

ANA_ENABLE_REG[0][14]: Offset: 0xCF
Bit	Field Name	Attribute	Default	Description
7:0	RESERVED	RO	8’h0	No use  

ANA_ENABLE_REG[1][0]: Offset: 0xC1
Bit	Field Name	Attribute	Default	Description
7:0	RESERVED	RO	8’h0	No use  

ANA_ENABLE_REG[1][1]: Offset: 0xC2
Bit	Field Name	Attribute	Default	Description
7:0	D2A_SDMEN[7:0]	RW	8’b00	Enable SDM
0: Disable
1: Enable
Output to ANA TOP to enable SDM

ANA_ENABLE_REG[1][2]: Offset: 0xC3
Bit	Field Name	Attribute	Default	Description
7:0	D2A_SDMEN[15:8]	RW	8’b00	Enable SDM
0: Disable
1: Enable

ANA_ENABLE_REG[1][3]: Offset: 0xC4
Bit	Field Name	Attribute	Default	Description
7:0	D2A_SDMBUFF_EN[7:0]	RW	8’b00	Enable SDM Buffer
0: Disable
1: Enable

ANA_ENABLE_REG[1][4]: Offset: 0xC5
Bit	Field Name	Attribute	Default	Description
7:0	D2A_SDMBUFF_EN[15:8]	RW	8’b00	Enable SDM Buffer
0: Disable
1: Enable
ANA_ENABLE_REG[1][5]: Offset: 0xC6
Bit	Field Name	Attribute	Default	Description
7:0	D2A_DCLOFFEN [7:0]	RW	8’b00	DC LEAD OFF Enable to detect for each 16 channel


ANA_ENABLE_REG[1][6]: Offset: 0xC7
Bit	Field Name	Attribute	Default	Description
7:0	D2A_DCLOFFEN[15:8]	RW	8’b00	DC LEAD OFF Enable to detect for each 16 channel

ANA_GEN_SECTION_SEL: Offset: 0xD0
Bit	Field Name	Attribute	Default	Description
7:3	RESERVED	RO	5’h00	No use
2:0	ANA_GEN_SECTION_SEL	RW	3’h0	Section selection
  3’h0: section 0 (ANA_GEN_REG[0][n])
  3’h1: section 1 (ANA_GEN_REG[1][n])
  3’h2: section 2 (ANA_GEN_REG[2][n])
  3’h3: section 3 (ANA_GEN_REG[3][n])
  3’h4: section 4 (ANA_GEN_REG[4][n])
  3’h5: section 5 (ANA_GEN_REG[5][n])
  3’h6: section 6 (ANA_GEN_REG[6][n])
  3’h7: section 7 (ANA_GEN_REG[7][n])
ANA_GEN_REG[0][0]: Offset: 0xD1
Bit	Field Name	Attribute	Default	Description
7:4	RESERVED	RO	4’h0	No use
3	D2A_BIASREF_INT	RW	1’b0	0: --> External VCM is used for RLD, 
1: --> Otherwise by default Internal VCM is used for RLD)
2:0	D2A_LVD_SEL[2:0] 	RW	3’b000	Trim bits for LVD:
000: 2.7V
001: 3.07V
010: 3.45V
011: 3.82V
100: 4.19V
101: 4.56V
110: 4.93V
111: 5.3V

ANA_GEN_REG[0][1]: Offset: 0xD2
Bit	Field Name	Attribute	Default	Description
7:6	RESERVED	RO	2’h0	No use
5:3	D2A_EEG_CH1_SET	RW	3’b000	Configure EEG CH1 similar to CH0
2:0	D2A_EEG_CH0_SET	RW	3’b000	Configure EEG CH0
000: Main (Sequential Montage) (Fully Differential input) (All other switches are open) Normal Electrode Input
001: Main (Referential Montage) (Single-ended) (means SRB1=1, all INN are connected to reference Electrode through SRB1 pin)
010: Main (Referential Montage) (Single-ended) (means SRB2=1, all INP are connected to reference Electrode through SRB2 pin)
011: Input shorted (for offset and noise measurements) (Main SW is open)
100: Bias Measurement (INP is connected to the output of RLD through BIASIN_PIN and INN is connected to VCM) (Main SW is open)
101: Bias Measurement (INN is connected to the output of RLD through BIASIN_PIN and INP is connected to VCM) (Main SW is open)

ANA_GEN_REG[0][2]: Offset: 0xD3
Bit	Field Name	Attribute	Default	Description
7:6	RESERVED	RO	2’h0	No use
5:3	D2A_EEG_CH3_SET	RW	3’b000	Configure EEG CH3 similar to CH0
2:0	D2A_EEG_CH2_SET	RW	3’b000	Configure EEG CH3 similar to CH0

ANA_GEN_REG[0][3]: Offset: 0xD4
Bit	Field Name	Attribute	Default	Description
7:6	RESERVED	RO	2’h0	No use
5:3	D2A_EEG_CH5_SET	RW	3’b000	Configure EEG CH5 similar to CH0
2:0	D2A_EEG_CH4_SET	RW	3’b000	Configure EEG CH4 similar to CH0

ANA_GEN_REG[0][4]: Offset: 0xD5
Bit	Field Name	Attribute	Default	Description
7:6	RESERVED	RO	2’h0	No use
5:3	D2A_EEG_CH7_SET	RW	3’b000	Configure EEG CH7 similar to CH0
2:0	D2A_EEG_CH6_SET	RW	3’b000	Configure EEG CH6 similar to CH0

ANA_GEN_REG[0][5]: Offset: 0xD6
Bit	Field Name	Attribute	Default	Description
7:6	RESERVED	RO	2’h0	No use
5:3	D2A_EEG_CH9_SET	RW	3’b000	Configure EEG CH9 similar to CH0
2:0	D2A_EEG_CH8_SET	RW	3’b000	Configure EEG CH8 similar to CH0

ANA_GEN_REG[0][6]: Offset: 0xD7
Bit	Field Name	Attribute	Default	Description
7:6	RESERVED	RO	2’h0	No use
5:3	D2A_EEG_CH11_SET	RW	3’b000	Configure EEG CH11 similar to CH0
2:0	D2A_EEG_CH10_SET	RW	3’b000	Configure EEG CH10 similar to CH0

ANA_GEN_REG[0][7]: Offset: 0xD8
Bit	Field Name	Attribute	Default	Description
7:6	RESERVED	RO	2’h0	No use
5:3	D2A_EEG_CH13_SET	RW	3’b000	Configure EEG CH13 similar to CH0
2:0	D2A_EEG_CH12_SET	RW	3’b000	Configure EEG CH12 similar to CH0
ANA_GEN_REG[0][8]: Offset: 0xD9
Bit	Field Name	Attribute	Default	Description
7:6	RESERVED	RO	2’h0	No use
5:3	D2A_EEG_CH15_SET	RW	3’b000	Configure EEG CH15 similar to CH0
2:0	D2A_EEG_CH14_SET	RW	3’b000	Configure EEG CH14 similar to CH0
ANA_GEN_REG[0][9]: Offset: 0xDA
Bit	Field Name	Attribute	Default	Description
7:6	D2A_EEGLNA3_IADJ	RW	2’h0	Trim bias current of LNA
5:4	D2A_EEGLNA2_IADJ	RW	2’h0	Trim bias current of LNA
3:2	D2A_EEGLNA1_IADJ	RW	2’h0	Trim bias current of LNA
1:0	D2A_EEGLNA0_IADJ	RW	2’h0	Trim bias current of LNA
ANA_GEN_REG[0][10]: Offset: 0xDB
Bit	Field Name	Attribute	Default	Description
7:6	D2A_EEGLNA7_IADJ	RW	2’h0	Trim bias current of LNA
5:4	D2A_EEGLNA6_IADJ	RW	2’h0	Trim bias current of LNA
3:2	D2A_EEGLNA5_IADJ	RW	2’h0	Trim bias current of LNA
1:0	D2A_EEGLNA4_IADJ	RW	2’h0	Trim bias current of LNA

ANA_GEN_REG[0][11]: Offset: 0xDC
Bit	Field Name	Attribute	Default	Description
7:6	D2A_EEGLNA12_IADJ	RW	2’h0	Trim bias current of LNA
5:4	D2A_EEGLNA11_IADJ	RW	2’h0	Trim bias current of LNA
3:2	D2A_EEGLNA10_IADJ	RW	2’h0	Trim bias current of LNA
1:0	D2A_EEGLNA9_IADJ	RW	2’h0	Trim bias current of LNA
ANA_GEN_REG[0][12]: Offset: 0xDD
Bit	Field Name	Attribute	Default	Description
7:6	RESERVED	RO	2’h0	No use
5:4	D2A_EEGLNA15_IADJ	RW	2’h0	Trim bias current of LNA
3:2	D2A_EEGLNA14_IADJ	RW	2’h0	Trim bias current of LNA
1:0	D2A_EEGLNA13_IADJ	RW	2’h0	Trim bias current of LNA

ANA_GEN_REG[1][0]: Offset: 0xD1
Bit	Field Name	Attribute	Default	Description
7:6	RESERVED	RO	2’h0	No use  
5:0	D2A_EEGLNA0_GAIN	RW	6’h0	Trim bias current of PGA

ANA_GEN_REG[1][1]: Offset: 0xD2
Bit	Field Name	Attribute	Default	Description
7:6	RESERVED	RO	2’h0	No use  
5:0	D2A_EEGLNA1_GAIN	RW	6’h0	Trim bias current of PGA

ANA_GEN_REG[1][2]: Offset: 0xD3
Bit	Field Name	Attribute	Default	Description
7:6	RESERVED	RO	2’h0	No use  
5:0	D2A_EEGLNA2_GAIN	RW	6’h0	Trim bias current of PGA

ANA_GEN_REG[1][3]: Offset: 0xD4
Bit	Field Name	Attribute	Default	Description
7:6	RESERVED	RO	2’h0	No use  
5:0	D2A_EEGLNA3_GAIN	RW	6’h0	Trim bias current of PGA

ANA_GEN_REG[1][4]: Offset: 0xD5
Bit	Field Name	Attribute	Default	Description
7:6	RESERVED	RO	2’h0	No use  
5:0	D2A_EEGLNA4_GAIN	RW	6’h0	Trim bias current of PGA

ANA_GEN_REG[1][5]: Offset: 0xD6
Bit	Field Name	Attribute	Default	Description
7:6	RESERVED	RO	2’h0	No use  
5:0	D2A_EEGLNA5_GAIN	RW	6’h0	Trim bias current of PGA
ANA_GEN_REG[1][6]: Offset: 0xD7
Bit	Field Name	Attribute	Default	Description
7:6	RESERVED	RO	2’h0	No use  
5:0	D2A_EEGLNA6_GAIN	RW	6’h0	Trim bias current of PGA

ANA_GEN_REG[1][7]: Offset: 0xD8
Bit	Field Name	Attribute	Default	Description
7:6	RESERVED	RO	2’h0	No use  
5:0	D2A_EEGLNA7_GAIN	RW	6’h0	Trim bias current of PGA

ANA_GEN_REG[1][8]: Offset: 0xD9
Bit	Field Name	Attribute	Default	Description
7:6	RESERVED	RO	2’h0	No use  
5:0	D2A_EEGLNA9_GAIN	RW	6’h0	Trim bias current of PGA

ANA_GEN_REG[1][9]: Offset: 0xDA
Bit	Field Name	Attribute	Default	Description
7:6	RESERVED	RO	2’h0	No use  
5:0	D2A_EEGLNA10_GAIN	RW	6’h0	Trim bias current of PGA

ANA_GEN_REG[1][10]: Offset: 0xDB
Bit	Field Name	Attribute	Default	Description
7:6	RESERVED	RO	2’h0	No use  
5:0	D2A_EEGLNA11_GAIN	RW	6’h0	Trim bias current of PGA

ANA_GEN_REG[1][11]: Offset: 0xDC
Bit	Field Name	Attribute	Default	Description
7:6	RESERVED	RO	2’h0	No use  
5:0	D2A_EEGLNA12_GAIN	RW	6’h0	Trim bias current of PGA

ANA_GEN_REG[1][12]: Offset: 0xDD
Bit	Field Name	Attribute	Default	Description
7:6	RESERVED	RO	2’h0	No use  
5:0	D2A_EEGLNA13_GAIN	RW	6’h0	Trim bias current of PGA
ANA_GEN_REG[2][0]: Offset: 0xD1
Bit	Field Name	Attribute	Default	Description
7:6	RESERVED	RO	2’h0	No use  
5:0	D2A_EEGLNA14_GAIN	RW	6’h0	Trim bias current of PGA
ANA_GEN_REG[2][1]: Offset: 0xD2
Bit	Field Name	Attribute	Default	Description
7:6	RESERVED	RO	2’h0	No use  
5:0	D2A_EEGLNA15_GAIN	RW	6’h0	Trim bias current of PGA

ANA_GEN_REG[2][2]: Offset: 0xD3
Bit	Field Name	Attribute	Default	Description
7:3	D2A_EEGPGA0B_GAIN	RW	5’b000	PGA GAIN Select
2:0	D2A_EEGPGA0A_GAIN	RW	3’b000	PGA GAIN Select 000:1 001:3 010:5 011:7 100:9 101:11 110:13 111:15
ANA_GEN_REG[2][3]: Offset: 0xD4
Bit	Field Name	Attribute	Default	Description
7:3	D2A_EEGPGA1B_GAIN	RW	5’h00	PGA GAIN Select
2:0	D2A_EEGPGA1A_GAIN	RW	3’b000	PGA GAIN Select
ANA_GEN_REG[2][4]: Offset: 0xD5
Bit	Field Name	Attribute	Default	Description
7:3	D2A_EEGPGA2B_GAIN	RW	5’h00	PGA GAIN Select
2:0	D2A_EEGPGA2A_GAIN	RW	3’b000	PGA GAIN Select
ANA_GEN_REG[2][5]: Offset: 0xD6
Bit	Field Name	Attribute	Default	Description
7:3	D2A_EEGPGA3B_GAIN	RW	5’h00	PGA GAIN Select
2:0	D2A_EEGPGA3A_GAIN	RW	3’b000	PGA GAIN Select
ANA_GEN_REG[2][6]: Offset: 0xD7
Bit	Field Name	Attribute	Default	Description
7:3	D2A_EEGPGA4B_GAIN	RW	5’h00	PGA GAIN Select
2:0	D2A_EEGPGA4A_GAIN	RW	3’b000	PGA GAIN Select
ANA_GEN_REG[2][7]: Offset: 0xD8
Bit	Field Name	Attribute	Default	Description
7:3	D2A_EEGPGA5B_GAIN	RW	5’h00	PGA GAIN Select
2:0	D2A_EEGPGA5A_GAIN	RW	3’b000	PGA GAIN Select
ANA_GEN_REG[2][8]: Offset: 0xD9
Bit	Field Name	Attribute	Default	Description
7:3	D2A_EEGPGA6B_GAIN	RW	5’h00	PGA GAIN Select
2:0	D2A_EEGPGA6A_GAIN	RW	3’b000	PGA GAIN Select
ANA_GEN_REG[2][9]: Offset: 0xDA
Bit	Field Name	Attribute	Default	Description
7:3	D2A_EEGPGA7B_GAIN	RW	5’h00	PGA GAIN Select
2:0	D2A_EEGPGA7A_GAIN	RW	3’b000	PGA GAIN Select
ANA_GEN_REG[2][10]: Offset: 0xDB
Bit	Field Name	Attribute	Default	Description
7:3	D2A_EEGPGA9B_GAIN	RW	5’h00	PGA GAIN Select
2:0	D2A_EEGPGA9A_GAIN	RW	3’b000	PGA GAIN Select
ANA_GEN_REG[2][11]: Offset: 0xDC
Bit	Field Name	Attribute	Default	Description
7:3	D2A_EEGPGA10B_GAIN	RW	5’h00	PGA GAIN Select
2:0	D2A_EEGPGA10A_GAIN	RW	3’b000	PGA GAIN Select
ANA_GEN_REG[2][12]: Offset: 0xDD
Bit	Field Name	Attribute	Default	Description
7:3	D2A_EEGPGA11B_GAIN	RW	5’h00	PGA GAIN Select
2:0	D2A_EEGPGA11A_GAIN	RW	3’b000	PGA GAIN Select
ANA_GEN_REG[3][0]: Offset: 0xD1
Bit	Field Name	Attribute	Default	Description
7:3	D2A_EEGPGA12B_GAIN	RW	5’h00	PGA GAIN Select
2:0	D2A_EEGPGA12A_GAIN	RW	3’b000	PGA GAIN Select
ANA_GEN_REG[3][1]: Offset: 0xD2
Bit	Field Name	Attribute	Default	Description
7:3	D2A_EEGPGA13B_GAIN	RW	5’h00	PGA GAIN Select
2:0	D2A_EEGPGA13A_GAIN	RW	3’b000	PGA GAIN Select
ANA_GEN_REG[3][2]: Offset: 0xD3
Bit	Field Name	Attribute	Default	Description
7:3	D2A_EEGPGA14B_GAIN	RW	5’h00	PGA GAIN Select
2:0	D2A_EEGPGA14A_GAIN	RW	3’b000	PGA GAIN Select
ANA_GEN_REG[3][3]: Offset: 0xD4
Bit	Field Name	Attribute	Default	Description
7:3	D2A_EEGPGA15B_GAIN	RW	5’h00	PGA GAIN Select
2:0	D2A_EEGPGA15A_GAIN	RW	3’b000	PGA GAIN Select
ANA_GEN_REG[3][4]: Offset: 0xD5
Bit	Field Name	Attribute	Default	Description
7:4	D2A_EEGPGA0B_IADJ	RW	4’h0	Trim bias current of PGA
3:0	D2A_EEGPGA0A_IADJ	RW	4’h0	Trim bias current of PGA
ANA_GEN_REG[3][5]: Offset: 0xD6
Bit	Field Name	Attribute	Default	Description
7:4	D2A_EEGPGA1B_IADJ	RW	4’h0	Trim bias current of PGA
3:0	D2A_EEGPGA1A_IADJ	RW	4’h0	Trim bias current of PGA
ANA_GEN_REG[3][6]: Offset: 0xD7
Bit	Field Name	Attribute	Default	Description
7:4	D2A_EEGPGA2B_IADJ	RW	4’h0	Trim bias current of PGA
3:0	D2A_EEGPGA2A_IADJ	RW	4’h0	Trim bias current of PGA
ANA_GEN_REG[3][7]: Offset: 0xD8
Bit	Field Name	Attribute	Default	Description
7:4	D2A_EEGPGA3B_IADJ	RW	4’h0	Trim bias current of PGA
3:0	D2A_EEGPGA3A_IADJ	RW	4’h0	Trim bias current of PGA
ANA_GEN_REG[3][8]: Offset: 0xD9
Bit	Field Name	Attribute	Default	Description
7:4	D2A_EEGPGA4B_IADJ	RW	4’h0	Trim bias current of PGA
3:0	D2A_EEGPGA4A_IADJ	RW	4’h0	Trim bias current of PGA
ANA_GEN_REG[3][9]: Offset: 0xDA
Bit	Field Name	Attribute	Default	Description
7:4	D2A_EEGPGA5B_IADJ	RW	4’h0	Trim bias current of PGA
3:0	D2A_EEGPGA5A_IADJ	RW	4’h0	Trim bias current of PGA
ANA_GEN_REG[3][10]: Offset: 0xDB
Bit	Field Name	Attribute	Default	Description
B:4	D2A_EEGPGA6B_IADJ	RW	4’h0	Trim bias current of PGA
3:0	D2A_EEGPGA6A_IADJ	RW	4’h0	Trim bias current of PGA
ANA_GEN_REG[3][11]: Offset: 0xDC
Bit	Field Name	Attribute	Default	Description
7:4	D2A_EEGPGA7B_IADJ	RW	4’h0	Trim bias current of PGA
3:0	D2A_EEGPGA7A_IADJ	RW	4’h0	Trim bias current of PGA
ANA_GEN_REG[3][12]: Offset: 0xDD
Bit	Field Name	Attribute	Default	Description
7:4	D2A_EEGPGA8B_IADJ	RW	4’h0	Trim bias current of PGA
3:0	D2A_EEGPGA8A_IADJ	RW	4’h0	Trim bias current of PGA
ANA_GEN_REG[4][0]: Offset: 0xD1
Bit	Field Name	Attribute	Default	Description
7:4	D2A_EEGPGA9B_IADJ	RW	4’h0	Trim bias current of PGA
3:0	D2A_EEGPGA9A_IADJ	RW	4’h0	Trim bias current of PGA
ANA_GEN_REG[4][1]: Offset: 0xD2
Bit	Field Name	Attribute	Default	Description
7:4	D2A_EEGPGA10B_IADJ	RW	4’h0	Trim bias current of PGA
3:0	D2A_EEGPGA10A_IADJ	RW	4’h0	Trim bias current of PGA
ANA_GEN_REG[4][2]: Offset: 0xD3
Bit	Field Name	Attribute	Default	Description
7:4	D2A_EEGPGA11B_IADJ	RW	4’h0	Trim bias current of PGA
3:0	D2A_EEGPGA11A_IADJ	RW	4’h0	Trim bias current of PGA
ANA_GEN_REG[4][3]: Offset: 0xD4
Bit	Field Name	Attribute	Default	Description
7:4	D2A_EEGPGA12B_IADJ	RW	4’h0	Trim bias current of PGA
3:0	D2A_EEGPGA12A_IADJ	RW	4’h0	Trim bias current of PGA
ANA_GEN_REG[4][4]: Offset: 0xD5
Bit	Field Name	Attribute	Default	Description
7:4	D2A_EEGPGA13B_IADJ	RW	4’h0	Trim bias current of PGA
3:0	D2A_EEGPGA13A_IADJ	RW	4’h0	Trim bias current of PGA
ANA_GEN_REG[4][5]: Offset: 0xD6
Bit	Field Name	Attribute	Default	Description
7:4	D2A_EEGPGA14B_IADJ	RW	4’h0	Trim bias current of PGA
3:0	D2A_EEGPGA14A_IADJ 	RW	4’h0	Trim bias current of PGA
ANA_GEN_REG[4][6]: Offset: 0xD7
Bit	Field Name	Attribute	Default	Description
7:4	D2A_EEGPGA15B_IADJ	RW	4’h0	Trim bias current of PGA
3:0	D2A_EEGPGA15A_IADJ	RW	4’h0	Trim bias current of PGA
ANA_GEN_REG[4][7]: Offset: 0xD8
Bit	Field Name	Attribute	Default	Description
7:0	RESERVED	RO	8’h0	No use  
ANA_GEN_REG[4][8]: Offset: 0xD9
Bit	Field Name	Attribute	Default	Description
7:0	RESERVED	RO	8’h0	No use  
ANA_GEN_REG[4][9]: Offset: 0xDA
Bit	Field Name	Attribute	Default	Description
7:0	RESERVED	RO	8’h0	No use  
ANA_GEN_REG[4][10]: Offset: 0xDB
Bit	Field Name	Attribute	Default	Description
7:0	RESERVED	RO	8’h0	No use  
ANA_GEN_REG[4][11]: Offset: 0xDC
Bit	Field Name	Attribute	Default	Description
7:0	RESERVED	RO	8’h0	No use  
ANA_GEN_REG[4][12]: Offset: 0xDD
Bit	Field Name	Attribute	Default	Description
7:0	RESERVED	RO	8’h0	No use  
ANA_GEN_REG[5][0]: Offset: 0xD1
Bit	Field Name	Attribute	Default	Description
7:0	RESERVED	RO	8’h0	No use  
ANA_GEN_REG[5][1]: Offset: 0xD2
Bit	Field Name	Attribute	Default	Description
7:0	RESERVED	RO	8’h0	No use  
ANA_GEN_REG[5][2]: Offset: 0xD3
Bit	Field Name	Attribute	Default	Description
7:0	RESERVED	RO	8’h0	No use  
ANA_GEN_REG[5][3]: Offset: 0xD4
Bit	Field Name	Attribute	Default	Description
7:0	RESERVED	RO	8’h0	No use  
ANA_GEN_REG[5][4]: Offset: 0xD5
Bit	Field Name	Attribute	Default	Description
7:0	RESERVED	RO	8’h0	No use  
ANA_GEN_REG[5][5]: Offset: 0xD6
Bit	Field Name	Attribute	Default	Description
7:0	RESERVED	RO	8’h0	No use  
ANA_GEN_REG[5][6]: Offset: 0xD7
Bit	Field Name	Attribute	Default	Description
7:0	RESERVED	RO	8’h0	No use  
ANA_GEN_REG[5][7]: Offset: 0xD8
Bit	Field Name	Attribute	Default	Description
7:0	RESERVED	RO	8’h0	No use  
ANA_GEN_REG[5][8]: Offset: 0xD9
Bit	Field Name	Attribute	Default	Description
7:0	RESERVED	RO	8’h0	No use  
ANA_GEN_REG[5][9]: Offset: 0xDA
Bit	Field Name	Attribute	Default	Description
7:0	RESERVED	RO	8’h0	No use  
ANA_GEN_REG[5][10]: Offset: 0xDB
Bit	Field Name	Attribute	Default	Description
7:0	RESERVED	RO	8’h0	No use  
ANA_GEN_REG[5][11]: Offset: 0xDC
Bit	Field Name	Attribute	Default	Description
7:0	RESERVED	RO	8’h0	No use  
ANA_GEN_REG[5][12]: Offset: 0xDD
Bit	Field Name	Attribute	Default	Description
7:0	RESERVED	RO	8’h0	No use  
ANA_GEN_REG[6][0]: Offset: 0xD1
Bit	Field Name	Attribute	Default	Description
7:0	RESERVED	RO	8’h0	No use  
ANA_GEN_REG[6][1]: Offset: 0xD2
Bit	Field Name	Attribute	Default	Description
7:0	RESERVED	RO	8’h0	No use  
ANA_GEN_REG[6][2]: Offset: 0xD3
Bit	Field Name	Attribute	Default	Description
7:0	RESERVED	RO	8’h0	No use  
ANA_GEN_REG[6][3]: Offset: 0xD4
Bit	Field Name	Attribute	Default	Description
7:0	RESERVED	RO	8’h0	No use  
ANA_GEN_REG[6][4]: Offset: 0xD5
Bit	Field Name	Attribute	Default	Description
7:0	RESERVED	RO	8’h0	No use  
ANA_GEN_REG[6][5]: Offset: 0xD6
Bit	Field Name	Attribute	Default	Description
7:0	RESERVED	RO	8’h0	No use  
ANA_GEN_REG[6][6]: Offset: 0xD7
Bit	Field Name	Attribute	Default	Description
7:0	RESERVED	RO	8’h0	No use  
ANA_GEN_REG[6][7]: Offset: 0xD8
Bit	Field Name	Attribute	Default	Description
7:0	RESERVED	RO	8’h0	No use  
ANA_GEN_REG[6][8]: Offset: 0xD9
Bit	Field Name	Attribute	Default	Description
7:0	RESERVED	RO	8’h0	No use  
ANA_GEN_REG[6][9]: Offset: 0xDA
Bit	Field Name	Attribute	Default	Description
7:4	D2A_DRIVERC_SHORT_DET_VINSEL– LSB [3:0]	RW	4’h0	short detection function comparator negative input selection
3:0	D2A_DRIVERC_LEAD_OFF_INSEL	RW	4’h0	lead off comparator comparator input selection
ANA_GEN_REG[6][10]: Offset: 0xDB
Bit	Field Name	Attribute	Default	Description
7:6	RESERVED	RO	2’h0	No use
5:1	D2A_DRIVERC_SHORT_DET_VIPSEL	RW	5’h0	short detedtion function comparator positive input selection
0	D2A_DRIVERC_SHORT_DET_VINSEL– MSB [4]	RW	1’h0	short detection function comparator negative input selection

Spare register table
ANA_GEN_REG[0][13]: Offset: 0xDE
Bit	Field Name	Attribute	Default	Description
7:0	SPARE_REGISTER	RW	8'h0	Spare Register for User Purpose
ANA_GEN_REG[1][13]: Offset: 0xDE
Bit	Field Name	Attribute	Default	Description
7:0	SPARE_REGISTER	RW	8'h0	Spare Register for User Purpose
ANA_GEN_REG[2][13]: Offset: 0xDE
Bit	Field Name	Attribute	Default	Description
7:0	SPARE_REGISTER	RW	8'h0	Spare Register for User Purpose
ANA_GEN_REG[3][13]: Offset: 0xDE
Bit	Field Name	Attribute	Default	Description
7:0	SPARE_REGISTER	RW	8'h0	Spare Register for User Purpose
ANA_GEN_REG[4][13]: Offset: 0xDE
Bit	Field Name	Attribute	Default	Description
7:0	SPARE_REGISTER	RW	8'h0	Spare Register for User Purpose
ANA_GEN_REG[5][13]: Offset: 0xDE
Bit	Field Name	Attribute	Default	Description
7:0	SPARE_REGISTER	RW	8'h0	Spare Register for User Purpose
ANA_GEN_REG[6][13]: Offset: 0xDE
Bit	Field Name	Attribute	Default	Description
7:0	SPARE_REGISTER	RW	8'h0	Spare Register for User Purpose
ANA_GEN_REG[7][13]: Offset: 0xDE
Bit	Field Name	Attribute	Default	Description
7:0	SPARE_REGISTER	RW	8'h0	Spare Register for User Purpose

ANA_GEN_REG[0][14]: Offset: 0xDF
This register is only considered under CP TEST MODE.
During normal mode, please refer to TSC_VDAC8B_DIN_CH1: 0x70 to control this signal.
Bit	Field Name	Attribute	Default	Description
7:0	D2A_VDAC8B_DIN	RW	8'h0	Adjust bits for 8bit DAC inside TSC
ANA_GEN_REG[1][14]: Offset: 0xDF
Bit	Field Name	Attribute	Default	Description
7:4	D2A_LOFF_ISEL_ADJ	RW	0010	These bits determine the magnitude of current for the current lead-off mode
00: 6.5 nA
01: 26 nA
10: 6 uA
11: 24 uA
3	D2A_LOFF_IPOL	RW	1'b0	Select Polarity Source/sink current
0: No flip, INP is pulled to AVDD and INN is pulled to AVSS
1: Flipped, INP is pulled to AVSS and INN is pulled to AVDD
2:0	D2A_LOFF_COMP_TH	RW	100	Comparator Positive side
000: 95% AVDD
001: 92.5% AVDD
010: 90% AVDD
011: 87.5% AVDD
100: 85% AVDD
101: 80% AVDD
110: 75% AVDD
111: 70% AVDD
Comparator Negative side
000: 5% AVDD
001: 7.5% AVDD
010: 10% AVDD
011: 12.5% AVDD
100: 15% AVDD
101: 20% AVDD
110: 25% AVDD
111: 30% AVDD
ANA_GEN_REG[2][14]: Offset: 0xDF
Bit	Field Name	Attribute	Default	Description
7:6	D2A_EEGLNA8_IADJ	RW	2'h0	Trim bias current of LNA
5:0	D2A_EEGLNA8_GAIN	RW	6'h0	Change LNA gain:000000:x10 000001:x20….111111:x500
ANA_GEN_REG[3][14]: Offset: 0xDF
Bit	Field Name	Attribute	Default	Description
7:3	D2A_EEGPGA8B_GAIN	RW	5'd0	PGA GAIN Select
2:0	D2A_EEGPGA8A_GAIN	RW	3'd0	PGA GAIN Select
ANA_GEN_REG[4][14]: Offset: 0xDF
Bit	Field Name	Attribute	Default	Description
7:0	D2A_VCMGENBUFF_IADJ	RW	8'h00	Adjust bias current of General VCM Buffer
ANA_GEN_REG[5][14]: Offset: 0xDF
Bit	Field Name	Attribute	Default	Description
7:2	D2A_SDMVCMBUFF_SEL	RW	6'h00	Output VCM voltage:
00:  1.4V
01: 1.5V
10: 1.6V
11: 1.7V
1:0	D2A_SDMVCMBUFF_IADJ	RW	2'h00	Adjust bias current of SDM VCM Buffer
ANA_GEN_REG[6][14]: Offset: 0xDF
Bit	Field Name	Attribute	Default	Description
7:2	D2A_SDMVREFP_SEL	RW	000011	Output VREFP voltage:
00: 1.2V
01: 1.5V
10: 1.8V
11: 2.4V
1:0	D2A_SDMVREFP_IADJ	RW	2'h00	Adjust bias current of SDM VREFP Buffer
ANA_GEN_REG[7][14]: Offset: 0xDF
Bit	Field Name	Attribute	Default	Description
7:0	D2A_RLD_IADJ	RW	8'h00	Adjust bias current of RLD

A2D_ANA_GEN_REG_0: 0xA0 (General Register)
Bit	Field Name	Attribute	Default	Description
7:4	RESERVED	RO	4’h0	Spare read register
3	A2D_DRIVERC_SHORT_DET_OUT	RO	1’b0	comparator output of short detection
2	A2D_DRIVERC_LEAD_OFF_OUT	RO	1’b0	comparator output of lead off detection
1	A2D_TSC_COMP_OUT	RO	1’b0	Temperature sensor output
    0: normal
    1: overheat
0	A2D_LVD	RO	1’b0	Analog LVD status (Analog to digital input)
To disable the interrupt, either user needs to change the battery or change interrupt voltage level via LVD_SEL or disable the interrupt.

A2D_ANA_GEN_REG_1: 0xA1 (General Register)
Bit	Field Name	Attribute	Default	Description
7:0	A2D_LOFF_STATP[7:0]	RO	8’b0	Status for Positive Signal for 16 channels EEG
If Source side ( InP or InN depends on D2A_LOFF_IPOL) exceeds High threshold voltage, LOFF_STATP = '1', otherwise LOFF_STATP='0'
If D2A_LOFFEN = '0', don't care status LOFF_STATP

A2D_ANA_GEN_REG_2: 0xA2  (General Register)
Bit	Field Name	Attribute	Default	Description
7:0	A2D_LOFF_STATP[15:8]	RO	8’b0	Status for Positive Signal for 16 channels EEG
If Source side ( InP or InN depends on D2A_LOFF_IPOL) exceeds High threshold voltage, LOFF_STATP = '1', otherwise LOFF_STATP='0'
If D2A_LOFFEN = '0', don't care status LOFF_STATP

A2D_ANA_GEN_REG_3: 0xA3 (General Register)
Bit	Field Name	Attribute	Default	Description
7:0	A2D_LOFF_STATN[7:0]	RO	8’b0	Status for Negative Signal for 16 channels EEG
If Sink side ( InP or InN depends on D2A_LOFF_IPOL) belows Low threshold voltage, LOFF_STATN = '1', otherwise LOFF_STATN='0'
If D2A_LOFFEN = '0', don't care status LOFF_STATN

A2D_ANA_GEN_REG_4: 0xA4 (General Register)
Bit	Field Name	Attribute	Default	Description
7:0	A2D_LOFF_STATN[15:8]	RO	8’b0	Status for Negative Signal for 16 channels EEG
If Sink side ( InP or InN depends on D2A_LOFF_IPOL) belows Low threshold voltage, LOFF_STATN = '1', otherwise LOFF_STATN='0'
If D2A_LOFFEN = '0', don't care status LOFF_STATN
A2D_SPARE_RO_REG_0: 0xA5 (General Register)
Bit	Field Name	Attribute	Default	Description
7:0	A2D_SPARE_RO_REG_0	RO	8’b0	Spare read register 0

 ANAC registers
ANA_LVD_INT_EN: 0x50 (General Register)
Bit	Field Name	Attribute	Default	Description
7:1	 RESERVED	RO	3’h0	 No use
0	ANA_LVD_INTR_EN	RW	1’b1	Analog LVD interrupt Enable
1: Enabled
0: Disabled

ANA_COMP_INT_EN: 0x51 (General Register)
Bit	Field Name	Attribute	Default	Description
7	ANA_COMP_CH7_INTR_EN	RW	1’b1	Analog Comp Channel 7 Interrupt Enable
1: Enabled
0: Disabled
6	ANA_COMP_CH6_INTR_EN	RW	1’b1	Analog Comp Channel 6 Interrupt Enable
1: Enabled
0: Disabled
     5	ANA_COMP_CH5_INTR_EN	RW	1’b1	Analog Comp Channel 5 Interrupt Enable
1: Enabled
0: Disabled
4	ANA_COMP_CH4_INTR_EN	RW	1’b1	Analog Comp Channel 4 Interrupt Enable
1: Enabled
0: Disabled
3	ANA_COMP_CH3_INTR_EN	RW	1’b1	Analog Comp Channel 3 Interrupt Enable
1: Enabled
0: Disabled
2	ANA_COMP_CH2_INTR_EN	RW	1’b1	Analog Comp Channel 2 Interrupt Enable
1: Enabled
0: Disabled
1	ANA_COMP_CH1_INTR_EN	RW	1’b1	Analog Comp Channel 1 Interrupt Enable
1: Enabled
0: Disabled
0	ANA_COMP_CH0_INTR_EN	RW	1’b1	Analog Comp Channel 0 Interrupt Enable
1: Enabled
0: Disabled

ANA_COMP_INT_TRANS_EN: 0x52 (General Register)
Bit	Field Name	Attribute	Default	Description
7	ANA_COMP_CH7_INTR_TRANS_SEL	RW	1’b0	0: 0->1 Transition 
(ANA_COMP_CH7_INTR_STS
 for channel 2 is generated when the ANA_COMP signal changes from 0 to 1 & interrupt is enabled).
1: 1->0 Transition 
(ANA_COMP_CH7_INTR_STS
 for channel 2 is generated when the ANA_COMP signal changes from 1 to 0, and interrupt is enabled).
6	ANA_COMP_CH6_INTR_TRANS_SEL	RW	1’b0	0: 0->1 Transition
(ANA_COMP_CH6_INTR_STS
 for channel 1 is generated when the ANA_COMP signal changes from 0 to 1 & interrupt is enabled).
1: 1->0 Transition 
(ANA_COMP_CH6_INTR_STS
 for channel 1 is generated when the ANA_COMP signal changes from 1 to 0 & interrupt is enabled).
5	ANA_COMP_CH5_INTR_TRANS_SEL	RW	1’b0	0: 0->1 Transition
(ANA_COMP_CH5_INTR_STS
 for channel 1 is generated when the ANA_COMP signal changes from 0 to 1 & interrupt is enabled).
1: 1->0 Transition 
(ANA_COMP_CH5_INTR_STS
 for channel 1 is generated when the ANA_COMP signal changes from 1 to 0 & interrupt is enabled).
4	ANA_COMP_CH4_INTR_TRANS_SEL	RW	1’b0	0: 0->1 Transition 
(ANA_COMP_CH4_INTR_STS
 for channel 2 is generated when the ANA_COMP signal changes from 0 to 1 & interrupt is enabled).
1: 1->0 Transition 
(ANA_COMP_CH4_INTR_STS
 for channel 2 is generated when the ANA_COMP signal changes from 1 to 0, and interrupt is enabled).
3	ANA_COMP_CH3_INTR_TRANS_SEL	RW	1’b0	0: 0->1 Transition 
(ANA_COMP_CH3_INTR_STS
 for channel 2 is generated when the ANA_COMP signal changes from 0 to 1 & interrupt is enabled).
1: 1->0 Transition 
(ANA_COMP_CH3_INTR_STS
 for channel 2 is generated when the ANA_COMP signal changes from 1 to 0, and interrupt is enabled).
2	ANA_COMP_CH2_INTR_TRANS_SEL	RW	1’b0	0: 0->1 Transition
(ANA_COMP_CH2_INTR_STS
 for channel 1 is generated when the ANA_COMP signal changes from 0 to 1 & interrupt is enabled).
1: 1->0 Transition 
(ANA_COMP_CH2_INTR_STS
 for channel 1 is generated when the ANA_COMP signal changes from 1 to 0 & interrupt is enabled).
1	ANA_COMP_CH1_INTR_TRANS_SEL	RW	1’b0	0: 0->1 Transition 
(ANA_COMP_CH1_INTR_STS
 for channel 2 is generated when the ANA_COMP signal changes from 0 to 1 & interrupt is enabled).
1: 1->0 Transition 
(ANA_COMP_CH1_INTR_STS
 for channel 2 is generated when the ANA_COMP signal changes from 1 to 0, and interrupt is enabled).
0	ANA_COMP_CH0_INTR_TRANS_SEL	RW	1’b0	0: 0->1 Transition
(ANA_COMP_CH0_INTR_STS
 for channel 1 is generated when the ANA_COMP signal changes from 0 to 1 & interrupt is enabled).
1: 1->0 Transition 
(ANA_COMP_CH0_INTR_STS
 for channel 1 is generated when the ANA_COMP signal changes from 1 to 0 & interrupt is enabled).

ANA_INT_STOP_WAVEGEN: 0x53 (General Register)
Bit	Field Name	Attribute	Default	Description
7	ANA_INT_STOP_WAVEGEN_CH7_EN	RW	1’b0	Wavegen Channel 7 Stop Enable
0: Normal
1: Stop
6	ANA_INT_STOP_WAVEGEN_CH6_EN	RW	1’b0	Wavegen Channel 6 Stop Enable
0: Normal
1: Stop
5	ANA_INT_STOP_WAVEGEN_CH5_EN	RW	1’b0	Wavegen Channel 5 Stop Enable
0: Normal
1: Stop
4	ANA_INT_STOP_WAVEGEN_CH4_EN	RW	1’b0	Wavegen Channel 4 Stop Enable
0: Normal
1: Stop
3	ANA_INT_STOP_WAVEGEN_CH3_EN	RW	1’b0	Wavegen Channel 3 Stop Enable
0: Normal
1: Stop
2	ANA_INT_STOP_WAVEGEN_CH2_EN	RW	1’b0	Wavegen Channel 2 Stop Enable
0: Normal
1: Stop
1	ANA_INT_STOP_WAVEGEN_CH1_EN	RW	1’b0	Wavegen Channel 1 Stop Enable
0: Normal
1: Stop
0	ANA_INT_STOP_WAVEGEN_CH0_EN	RW	1’b0	Wavegen Channel 0 Stop Enable
0: Normal
1: Stop

ANA_STUMI_INT_EN: 0x54 (General Register)
Bit	Field Name	Attribute	Default	Description
7	ANA_STIMU_CH7_INTR_EN	RW	1’b0	Analog STIMU14/15 Interrupt Enable for INTB
0: Disabled
1: Enabled
6	ANA_STIMU_CH6_INTR_EN	RW	1’b0	Analog STIMU12/13 Interrupt enable for INTB
0: Disabled
1: Enabled
5	ANA_STIMU_CH5_INTR_EN	RW	1’b0	Analog STIMU10/11 Interrupt Enable for INTB
0: Disabled
1: Enabled
4	ANA_STIMU_CH4_INTR_EN	RW	1’b0	Analog STIMU8/9 Interrupt enable for INTB
0: Disabled
1: Enabled
3	ANA_STIMU_CH3_INTR_EN	RW	1’b0	Analog STIMU6/7 Interrupt Enable for INTB
0: Disabled
1: Enabled
2	ANA_STIMU_CH2_INTR_EN	RW	1’b0	Analog STIMU4/5 Interrupt enable for INTB
0: Disabled
1: Enabled
1	ANA_STIMU_CH1_INTR_EN	RW	1’b0	Analog STIMU2/3 Interrupt Enable for INTB
0: Disabled
1: Enabled
0	ANA_STIMU_CH0_INTR_EN	RW	1’b0	Analog STIMU0/1 Interrupt enable for INTB
0: Disabled
1: Enabled

ANA_STIMU_INT_DIG_EN: 0x55 (General Register)
Bit	Field Name	Attribute	Default	Description
7	DIG_SHORT_BLOCK_CH7_EN	RW	1’b1	Analog STIMU14/15 Interrupt Enable for REG STATUS
0: Disabled
1: Enabled
6	DIG_SHORT_BLOCK_CH6_EN	RW	1’b1	Analog STIMU12/13 Interrupt enable for REG STATUS
0: Disabled
1: Enabled
5	DIG_SHORT_BLOCK_CH5_EN	RW	1’b1	Analog STIMU10/11 Interrupt Enable for REG STATUS
0: Disabled
1: Enabled
4	DIG_SHORT_BLOCK_CH4_EN
	RW	1’b1	Analog STIMU8/9 Interrupt enable for REG STATUS
0: Disabled
1: Enabled
3	DIG_SHORT_BLOCK_CH3_EN	RW	1’b1	Analog STIMU6/7 Interrupt Enable for REG STATUS
0: Disabled
1: Enabled
2	DIG_SHORT_BLOCK_CH2_EN
	RW	1’b1	Analog STIMU4/5 Interrupt enable for REG STATUS
0: Disabled
1: Enabled
1	DIG_SHORT_BLOCK_CH1_EN	RW	1’b1	Analog STIMU2/3 Interrupt Enable for REG STATUS
0: Disabled
1: Enabled
0	DIG_SHORT_BLOCK_CH0_EN
	RW	1’b1	Analog STIMU0/1 Interrupt enable for REG STATUS
0: Disabled
1: Enabled


ANA_STIMU_INT_POL_EN: 0x56 (General Register)
Bit	Field Name	Attribute	Default	Description
7	 ANA_INT_COMP_POL_CH7	RW	1’b0	 This signal shows the Active Level of Response for CH7.
0: short-circuit happens when A2D_TIMU14_15 is 0.
1: short-circuit happens when A2D_TIMU14_15 is 1.
(only for short-circuit, no need to verify for Lead-off).
6	 ANA_INT_COMP_POL_CH6	RW	1’b0	 This signal shows the Active Level of Response for CH6.

0: short-circuit happens when A2D_TIMU12_13is 0.
1: short-circuit happens when A2D_ TIMU12_13 is 1.
Only for short-circuit, no need to verify for lead-off).
5	 ANA_INT_COMP_POL_CH5	RW	1’b0	 This signal shows the Active Level of Response for CH5.
0: short-circuit happens when A2D_TIMU10_11 is 0.
1: short-circuit happens when A2D_TIMU10_11 is 1.
(only for short-circuit, no need to verify for Lead-off).
4	 ANA_INT_COMP_POL_CH4	RW	1’b0	 This signal shows the Active Level of Response for CH4.
0: short-circuit happens when A2D_ TIMU8_9 is 0.
1: short-circuit happens when A2D_ TIMU8_9 is 1.
Only for short-circuit, no need to verify for lead-off).
3	 ANA_INT_COMP_POL_CH3	RW	1’b0	 This signal shows the Active Level of Response for CH3.
0: short-circuit happens when A2D_TIMU6_7 is 0.
1: short-circuit happens when A2D_TIMU6_7 is 1.
(only for short-circuit, no need to verify for Lead-off).
2	 ANA_INT_COMP_POL_CH2	RW	1’b0	 This signal shows the Active Level of Response for CH2.
0: short-circuit happens when A2D_ TIMU4_5 is 0.
1: short-circuit happens when A2D_ TIMU4_5 is 1.
Only for short-circuit, no need to verify for lead-off).
1	 ANA_INT_COMP_POL_CH1	RW	1’b0	 This signal shows the Active Level of Response for CH2.
0: short-circuit happens when A2D_TIMU2_3 is 0.
1: short-circuit happens when A2D_TIMU2_3 is 1.
(only for short-circuit, no need to verify for Lead-off).
0	 ANA_INT_COMP_POL_CH0	RW	1’b0	 This signal shows the Active Level of Response for CH1.
0: short-circuit happens when A2D_ TIMU0_1 is 0.
1: short-circuit happens when A2D_ TIMU0_1 is 1.
Only for short-circuit, no need to verify for lead-off).

ANA_SHORT_BLOCK_SLCT: 0x57 (General Register)
Bit	Field Name	Attribute	Default	Description
7:4	 RESERVED	RO	4’b0	 No use
3	LEAD_OFF_BY_SHORT_CIRCUIT_EN
	RW	1‘b’0	Just in case want to use short-circuit comparator to do the lead off
0: Use A2D_STIMU0_1~A2D_STIMU14_15 output of the short comparator.
1: Use A2D_COMP0~ A2D_COMP7 output of the lead off comparator.
2:0	ANA_SHORT_BLOCK_SLCT	RW	3’b0	The count time and timer for setting the short-circuit detector of which channel.
000：channel 0
001：channel 1
010：channel 2
011：channel 3
100：channel 4
101：channel 5
110：channel 6
111：channel 7



ANA_STIM _CH_TIMER_CNT_TH00: 0x58 (General Register)
Bit	Field Name	Attribute	Default	Description
7:0	ANA_STIM _CH_TIMER_CNT_TH	RW	8'h00	The timer threshold for channel 0~ channel 7; BIT[7:0]
The channel is selected by the register ANA_SHORT_BLOCK_SLCT.

ANA_STIM _CH_TIMER_CNT_TH01: 0x59 (General Register)
Bit	Field Name	Attribute	Default	Description
7:0	ANA_STIM _CH_TIMER_CNT_TH
	RW	8'h00	The timer threshold for channel 1~ channel 7; BIT[15:8]
The channel is selected by the register ANA_SHORT_BLOCK_SLCT.

ANA_STIM _CH_TIMER_CNT_TH02: 0x5A (General Register)
Bit	Field Name	Attribute	Default	Description
7:0	ANA_STIM _CH_TIMER_CNT_TH	RW	8'h00	The timer threshold for channel 1~ channel 7; BIT[23:16]
The channel is selected by the register ANA_SHORT_BLOCK_SLCT.

ANA_STIM _CH_TIMER_CNT_TH03: 0x5B (General Register)
Bit	Field Name	Attribute	Default	Description
7:0	ANA_STIM_CH_TIMER_CNT_TH	RW	8'h00	The timer threshold for channel 1~ channel 7; BIT[31:24]
The channel is selected by the register ANA_SHORT_BLOCK_SLCT.

ANA_STIM _CH1_COUNTER_CNT_TH00: 0x5C (General Register)
Bit	Field Name	Attribute	Default	Description
7:0	ANA_STIM _CH1_COUNTER_CNT_TH	RW	8'h00	The COUNTER threshold for channel 1 ~ channel 7 to generate interrupt; BIT[7:0]
The channel is selected by the register ANA_SHORT_BLOCK_SLCT.

ANA_STIM _CH_COUNTER_CNT_TH01: 0x5D (General Register)
Bit	Field Name	Attribute	Default	Description
7:0	ANA_STIM _CH_COUNTER_CNT_TH	RW	8'h00	The COUNTER threshold for channel 1 ~ channel 7 to generate interrupt; BIT[15:8]
The channel is selected by the register ANA_SHORT_BLOCK_SLCT.

ANA_STIM _CH_COUNTER_CNT_TH02: 0x5E（General Register)
Bit	Field Name	Attribute	Default	Description
7:0	ANA_STIM _CH_COUNTER_CNT_TH	RW	8'h00	The COUNTER threshold for channel 1 ~ channel 7 to generate interrupt; BIT[23:16]
The channel is selected by the register ANA_SHORT_BLOCK_SLCT.

ANA_STIM _CH_COUNTER_CNT_TH03: 0x5F (General Register)
Bit	Field Name	Attribute	Default	Description
7:0	ANA_STIM _CH_COUNTER_CNT_TH	RW	8'h00	The COUNTER threshold for channel 1 t~ channel 7 o generate interrupt; BIT[31:24]
The channel is selected by the register ANA_SHORT_BLOCK_SLCT.

ANA_INTR_STIMU_STS: 0x60 (General Register)
Bit	Field Name	Attribute	Default	Description
7	ANA_STIMU_CH7_INTR_STS	RRW1C*/R1C*	1’b0	Analog STIMU14/15 Interrupt Status
0: Interrupt is inactive.
1: Interrupt is active.
Clear Condition:
This bit can be cleared by writing 1 to this bit.
This bit can be cleared by reading this bit 1.
6	ANA_STIMU_CH6_INTR_STS	RRW1C*/R1C*	1’b0	Analog STIMU12/13 Interrupt Status
0: Interrupt is inactive.
1: Interrupt is active.
Clear Condition:
 This bit can be cleared by writing 1 to this bit.
This bit can be cleared by reading this bit 1
5	ANA_STIMU_CH5_INTR_STS	RRW1C*/R1C*	1’b0	Analog STIMU10/11 Interrupt Status
0: Interrupt is inactive.
1: Interrupt is active.
Clear Condition:
This bit can be cleared by writing 1 to this bit.
This bit can be cleared by reading this bit 1.
4	ANA_STIMU_CH4_INTR_STS	RRW1C*/R1C*	1’b0	Analog STIMU8/9 Interrupt Status
0: Interrupt is inactive.
1: Interrupt is active.
Clear Condition:
 This bit can be cleared by writing 1 to this bit.
This bit can be cleared by reading this bit 1
3	ANA_STIMU_CH3_INTR_STS	RRW1C*/R1C*	1’b0	Analog STIMU6/7 Interrupt Status
0: Interrupt is inactive.
1: Interrupt is active.
Clear Condition:
This bit can be cleared by writing 1 to this bit.
This bit can be cleared by reading this bit 1.
2	ANA_STIMU_CH2_INTR_STS	RRW1C*/R1C*	1’b0	Analog STIMU4/5 Interrupt Status
0: Interrupt is inactive.
1: Interrupt is active.
Clear Condition:
 This bit can be cleared by writing 1 to this bit.
This bit can be cleared by reading this bit 1
1	ANA_STIMU_CH1_INTR_STS	RRW1C*/R1C*	1’b0	Analog STIMU2/3 Interrupt Status
0: Interrupt is inactive.
1: Interrupt is active.
Clear Condition:
This bit can be cleared by writing 1 to this bit.
This bit can be cleared by reading this bit 1.
0	ANA_STIMU_CH0_INTR_STS	RRW1C*/R1C*	1’b0	Analog STIMU0/1 Interrupt Status
0: Interrupt is inactive.
1: Interrupt is active.
Clear Condition:
 This bit can be cleared by writing 1 to this bit.
This bit can be cleared by reading this bit 1

ANA_INT_COMP_STS: 0x61General Register)
Bit	Field Name	Attribute	Default	Description
7	ANA_COMP_CH7_INTR_STS	RRW1C*/R1C*	1’b0	Analog Comparator Channel 7 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
This bit can be cleared by writing 1 to this bit.
This bit can be cleared by reading this bit 1.
6	ANA_COMP_CH6_INTR_STS	RRW1C*/R1C*	1’b0	Analog Comparator Channel 6 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
This bit can be cleared by writing 1 to this bit.
This bit can be cleared by reading this bit 1.
5	ANA_COMP_CH5_INTR_STS	RRW1C*/R1C*	1’b0	Analog Comparator Channel 5 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition: 
This bit can be cleared by writing 1 to This bit.
This bit can be cleared by reading this bit 1.
4	ANA_COMP_CH4_INTR_STS	RRW1C*/R1C*	1’b0	Analog Comparator Channel 4 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
This bit can be cleared by writing 1 to this bit.
This bit can be cleared by reading this bit 1.
3	ANA_COMP_CH3_INTR_STS	RRW1C*/R1C*	1’b0	Analog Comparator Channel 3 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition: 
This bit can be cleared by writing 1 to This bit.
This bit can be cleared by reading this bit 1.
2	ANA_COMP_CH2_INTR_STS	RRW1C*/R1C*	1’b0	Analog Comparator Channel 2 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
This bit can be cleared by writing 1 to this bit.
This bit can be cleared by reading this bit 1.
1	ANA_COMP_CH1_INTR_STS	RRW1C*/R1C*	1’b0	Analog C Channel 1 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition: 
This bit can be cleared by writing 1 to This bit.
This bit can be cleared by reading this bit 1.
0	ANA_COMP_CH0_INTR_STS	RRW1C*/R1C*	1’b0	Analog Comparator Channel 0 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
This bit can be cleared by writing 1 to this bit.
This bit can be cleared by reading this bit 1.

ANA_INT_LVD_STS: 0x62 (General Register)
Bit	Field Name	Attribute	Default	Description
7:1	 RESERVED	RO	5’h0	 No use
0	ANA_LVD_INTR_STS	R0	1’b0	Analog LVD Interrupt Status
0: Interrupt is inactive
1: Interrupt is active

TSC registers
TSC_VDAC_NOR: 0x69 (General Register)
Bit	Field Name	Attribute	Default	Description
7:0	 TSC_VDAC_NOR	RO	8’b0	 Room temperature VDAC value (Dnom_tsc[7:0])

TSC_SMP_STS: 0x6A (General Register)
Bit	Field Name	Attribute	Default	Description
7:1	 RESERVED	RO	0	
0	 BUSY_DOING	RO	0	 Doing the comparator status
 0: Finish
 1: Doing in progress

TSC_EN_REG_CTRL: 0x6B (General Register)
Bit	Field Name	Attribute	Default	Description
7:5	RESERVED	RW	0	 No use
4	TSC_VDAC8B_DIN_CH1	RW	0	1: Register control
0: State machine control
3	TSC_EN_CH1	RW	0	1: Register control
0: State machine control
2	RESERVED	RW	0	 No use
1	TSC_COMP_EN_CH1	RW	0	1: Register control
0: State machine control
0	D2A_VDAC8B_EN_CH1	RW	0	1: Register control
0: State machine control

TSC_CTRL: 0x6C (General Register)
Bit	Field Name	Attribute	Default	Description
7:4	RESERVED	RO	0	No use
3	TSC_COMP_LOW_CH1	RW	1’b0	0:  A2D_TSC_COMP 0 means normal temperature, 1 is over temperature
1: A2D_TSC_COMP 1 means normal temperature, 0 is over temperature
2:1	RESERVED	RO	0	No use
0	TSC_EN_CH1	RW	1’b0	Temperature Sensor Module Enable
1: Enable
0: Disable
SMP_DURATION: 0x6D (General Register)
Bit	Field Name	Attribute	Default	Description
7:0	 SAMPLE_DURATION	RW	8'h10	 Do the comparation time

STABLE_DURATION: 0x6E-0x6F (General Register)
Bit	Field Name	Attribute	Default	Description
11:0	 STABLE_DURATION	RW	12’h1ff	Temp sensor analog stable time
0x86 is LSB 8-bit, 0x87 is MSB 4-bit
TSC_VDAC8B_DIN_CH1: 0x70 (General Register)
Bit	Field Name	Attribute	Default	Description
7:0	 TSC_VDAC8B_DIN_CH1	RW	8'hFF	DIN for 8bit DAC (Dhigh_tsc[7:0])
TSC_INT_CTRL: 0x71 (General Register)
Bit	Field Name	Attribute	Default	Description
7:2	 RESERVED	RO	6’h0	 No use
1	TSC_INTR_TRANS_SEL	RW	1’b0	0: 0->1 Transition 
 for tsc, int is generated when the ANA_COMP signal changes from 0 to 1 & interrupt is enabled).
1: 1->0 Transition 
 for tsc, int is generated when the ANA_COMP signal changes from 1 to 0, and interrupt is enabled).
0	TSC_INTR_EN	RW	1’b0	TSC interrupt Enable
1: Enabled
0: Disabled
TSC_INT_ STATUS: 0x72 (General Register)
Bit	Field Name	Attribute	Default	Description
7:1	 RESERVED	RO	7’h0	 No use
0	TSC_INT_STATUS	W1C/R1C	1’b0	TSC interrupt STATUS
1: overheat
0: no overheat


General Interrupt Registers
 GENERAL_INTERUPT_STATUS_REG07-08 : 0x73-0x74 (General Register)
STIM_MON_LOFF_INT_STS0: 0x51-0x52 (General Register)
   Write STIM_MON_LOFF_INT_STS0 or GENERAL_INTERUPT_STATUS_REG07-08  is same result
	
Bit	Field Name	Attribute	Default	Description
15:0	 STIM_MON_LOFF_INT_STS0/
GENERAL_INTERRUPT_STATUS_REG07-08	RW/RC/W1C	0x0	Leadoff interrupt status or write to clear or read to clear depend on which interrupt clear
0: pair0 leadoff status
1: pair1 leadoff status
…
15: pair15 leadoff status

 GENERAL_INTERUPT_STATUS_REG09-0A: 0x75-0x76 (General Register)
STIM_MON_SHORT_INT_STS0: 0x53-0x54 (General Register)
Write STIM_MON_SHORT_INT_STS0 or GENERAL_INTERUPT_STATUS_REG09-0A is same result
Bit	Field Name	Attribute	Default	Description
15:0	 STIM_MON_SHORT_INT_STS0/
GENERAL_INTERRUPT_STATUS_REG09-0A	RW/RC/W1C	0x0	Short interrupt status or write to clear or read to clear depend on which interrupt clear
0: pair0 short status
1: pair1 short status
…
15: pair15 short status
 GENERAL_INTERUPT_STATUS_REG0B (General Register)
	STIM_MON_INT: 0x46 (General Register)
Write bit2:0 STIM_MON_INT or GENERAL_INTERUPT_STATUS_REG0B  is same result
The bit7:4 of GENERAL_INTERUPT_STATUS_REGB is 0 for reading
The bit7:4 of STIM_MON_INT has other meaning
So, reading bit7:4 of these 2 registers is different.
Bit	Field Name	Attribute	Default	Description
7:4	 Reserved	RO	0	
2	STIM_MON_CYCLE_INT/ GENERAL_INTERRUPT_STATUS_REG0B[2]	RW/RC/W1C	0x0	Stimulator adc cycle value interrupt status or write to clear or read to clear depend on which interrupt clear
1	STIM_MON_INT/
GENERAL_INTERRUPT_STATUS_REG0B[1]	RW/RC/W1C	0x0	Stimulator adc interrupt status or write to clear or read to clear depend on which interrupt clear 
0	STIM_MON_DELTA_INT/
GENERAL_INTERRUPT_STATUS_REG0B[0]	RW/RC/W1C	0x0	Stimulator adc delta value interrupt status or write to clear or read to clear depend on which interrupt clear 


 GENERAL_INTERUPT_CTRL_REG: Offset:0x78 (General Register)
Bit	Field Name	Attribute	Default	Description
7:3	RESERVED	RO	6’h0	No use
2	INT_ACTIVE_LEVEL	RW	1’b1	Control the active level of interrupts
0: Active low
1: Active high
1	INT_CLEAR_TYPE	RW	1’b0	The method for clearing control interrupts:
0: Write 1 to clear manually (RW1C)
1: Read 1 to clear automatically (R1C)
0	INT_LENGTH_SLCT	RW	4’h0	Selecting INTB is level active or pulse active
0：Level Active
1：Pulse Active (1 module CLK)
For example, for EEG module, then will be 1 EEG clock

 GENERAL_INTERUPT_STATUS_REG01: 0x79 (General Register)
Bit	Field Name	Attribute	Default	Description
7	TSC_INT_STATUS	RW1C*/R1C*	1’h0	TSC Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by writing 1 to bit[0] of normal 0x89 or read bit [0] of General Register at 0x89 with 1’b1.
R1C*: this bit can be cleared automatically when read 1’b1
6:2	 RESERVED	RO	5’h0	 No use
1	EEG_INT_STATUS	RW1C*/R1C*	1’h0	EEG Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by writing 1 to bit[0] of normal 0xD8 or read bit [0] of General Register at 0xD8 with 1’b1.
R1C*: this bit can be cleared automatically when read 1’b1
0	ANA_LVD_INTR_STS	RO	1’b0	Analog LVD Interrupt Status
0: Interrupt is inactive
1: Interrupt is active

 GENERAL_INTERUPT_STATUS_REG02: 0x7A (General Register)
Bit	Field Name	Attribute	Default	Description
7	I_WG_DRIVER_INT_STS[3][1]	RW1C*/R1C*	1’b0	INT ADDR2 of  Channel 3 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by writing 1 to bit[2] of wavegen 0xE8 or read bit [5] of wavegen reg 0xE8 1.
R1C*: this bit can be cleared automatically when read 1
6	I_WG_DRIVER_INT_STS[3][0]	RW1C*/R1C*	1’b0	INT ADDR1 of  Channel 3 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by writing 1 to bit[1] of wavegen 0xE8 or read  bit [4] of wavegen reg 0xE8 1
R1C*: this bit can be cleared automatically when read 1
5	I_WG_DRIVER_INT_STS[2][1]	RW1C*/R1C*	1’b0	INT ADDR2 of  Channel 2 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by writing 1 to bit[2] of wavegen 0xA8 or read  bit [5] of wavegen reg 0xA8 1
R1C*: this bit can be cleared automatically when read 1
4	I_WG_DRIVER_INT_STS [2][0]	RW1C*/R1C*	1’b0	INT ADDR1 of  Channel 2 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by writing 1 to bit[1] of wavegen 0xA8 or read  bit [4] of AWG Register 0xA8 1
R1C*: this bit can be cleared automatically when read 1
3	I_WG_DRIVER_INT_STS[1][1]	RW1C*/R1C*	1’b0	INT ADDR2 of  Channel 1 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by writing 1 to bit[2] of wavegen 0x68 or read bit [5] of wavegen reg 0x68 1.
R1C*: this bit can be cleared automatically when read 1
2	I_WG_DRIVER_INT_STS[1][0]	RW1C*/R1C*	1’b0	INT ADDR1 of  Channel 1 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by writing 1 to bit[1] of wavegen 0x68 or read  bit [4] of wavegen reg 0x68 1
R1C*: this bit can be cleared automatically when read 1
1	I_WG_DRIVER_INT_STS[0][1]	RW1C*/R1C*	1’b0	INT ADDR2 of  Channel 0 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by writing 1 to bit[2] of wavegen 0x28 or read  bit [5] of wavegen reg 0x28 1
R1C*: this bit can be cleared automatically when read 1
0	I_WG_DRIVER_INT_STS [0][0]	RW1C*/R1C*	1’b0	INT ADDR1 of  Channel 0 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by writing 1 to bit[1] of wavegen 0x28 or read  bit [4] of AWG Register 0x28 1
R1C*: this bit can be cleared automatically when read 1

 GENERAL_INTERUPT_STATUS_REG03: 0x7B (General Register)
Bit	Field Name	Attribute	Default	Description
7	I_WG_DRIVER_INT_STS[7][1]	RW1C*/R1C*	1’b0	INT ADDR2 of  Channel 7 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by writing 1 to bit[2] of wavegen 0xE8 or read bit [5] of wavegen reg 0xE8 1.
R1C*: this bit can be cleared automatically when read 1
6	I_WG_DRIVER_INT_STS[7][0]	RW1C*/R1C*	1’b0	INT ADDR1 of  Channel 7 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by writing 1 to bit[1] of wavegen 0xE8 or read  bit [4] of wavegen reg 0xE8 1
R1C*: this bit can be cleared automatically when read 1
5	I_WG_DRIVER_INT_STS[6][1]	RW1C*/R1C*	1’b0	INT ADDR2 of  Channel 6 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by writing 1 to bit[2] of wavegen 0xA8 or read  bit [5] of wavegen reg 0xA8 1
R1C*: this bit can be cleared automatically when read 1
4	I_WG_DRIVER_INT_STS [6][0]	RW1C*/R1C*	1’b0	INT ADDR1 of  Channel 6 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by writing 1 to bit[1] of wavegen 0xA8 or read  bit [4] of AWG Register 0xA8 1
R1C*: this bit can be cleared automatically when read 1
3	I_WG_DRIVER_INT_STS[5][1]	RW1C*/R1C*	1’b0	INT ADDR2 of  Channel 5 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by writing 1 to bit[2] of wavegen 0x68 or read bit [5] of wavegen reg 0x68 1.
R1C*: this bit can be cleared automatically when read 1
2	I_WG_DRIVER_INT_STS[5][0]	RW1C*/R1C*	1’b0	INT ADDR1 of  Channel 5 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by writing 1 to bit[1] of wavegen 0x68 or read  bit [4] of wavegen reg 0x68 1
R1C*: this bit can be cleared automatically when read 1
1	I_WG_DRIVER_INT_STS[4][1]	RW1C*/R1C*	1’b0	INT ADDR2 of  Channel 4 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by writing 1 to bit[2] of wavegen 0x28 or read  bit [5] of wavegen reg 0x28 1
R1C*: this bit can be cleared automatically when read 1
0	I_WG_DRIVER_INT_STS [4][0]	RW1C*/R1C*	1’b0	INT ADDR1 of  Channel 4 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by writing 1 to bit[1] of wavegen 0x28 or read  bit [4] of AWG Register 0x28 1
R1C*: this bit can be cleared automatically when read 1

 GENERAL_INTERUPT_STATUS_REG04: 0x7C (General Register)
Bit	Field Name	Attribute	Default	Description
7	I_WG_DRIVER_INT_STS[7][1]	RW1C*/R1C*	1’b0	INT ADDR2 of  Channel 11 inerrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by writing 1 to bit[2] of wavegen 0xE8 or read bit [5] of wavegen reg 0xE8 1.
R1C*: this bit can be cleared automatically when read 1
6	I_WG_DRIVER_INT_STS[7][0]	RW1C*/R1C*	1’b0	INT ADDR1 of  Channel 11 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by writing 1 to bit[1] of wavegen 0xE8 or read  bit [4] of wavegen reg 0xE8 1
R1C*: this bit can be cleared automatically when read 1
5	I_WG_DRIVER_INT_STS[6][1]	RW1C*/R1C*	1’b0	INT ADDR2 of  Channel 10 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by writing 1 to bit[2] of wavegen 0xA8 or read  bit [5] of wavegen reg 0xA8 1
R1C*: this bit can be cleared automatically when read 1
4	I_WG_DRIVER_INT_STS [6][0]	RW1C*/R1C*	1’b0	INT ADDR1 of  Channel 10 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by writing 1 to bit[1] of wavegen 0xA8 or read  bit [4] of AWG Register 0xA8 1
R1C*: this bit can be cleared automatically when read 1
3	I_WG_DRIVER_INT_STS[5][1]	RW1C*/R1C*	1’b0	INT ADDR2 of  Channel 9 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by writing 1 to bit[2] of wavegen 0x68 or read bit [5] of wavegen reg 0x68 1.
R1C*: this bit can be cleared automatically when read 1
2	I_WG_DRIVER_INT_STS[5][0]	RW1C*/R1C*	1’b0	INT ADDR1 of  Channel 9 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by writing 1 to bit[1] of wavegen 0x68 or read  bit [4] of wavegen reg 0x68 1
R1C*: this bit can be cleared automatically when read 1
1	I_WG_DRIVER_INT_STS[4][1]	RW1C*/R1C*	1’b0	INT ADDR2 of  Channel 8 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by writing 1 to bit[2] of wavegen 0x28 or read  bit [5] of wavegen reg 0x28 1
R1C*: this bit can be cleared automatically when read 1
0	I_WG_DRIVER_INT_STS [4][0]	RW1C*/R1C*	1’b0	INT ADDR1 of  Channel 8 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by writing 1 to bit[1] of wavegen 0x28 or read  bit [4] of AWG Register 0x28 1
R1C*: this bit can be cleared automatically when read 1

 GENERAL_INTERUPT_STATUS_REG05: 0x7D (General Register)
Bit	Field Name	Attribute	Default	Description
7	I_WG_DRIVER_INT_STS[7][1]	RW1C*/R1C*	1’b0	INT ADDR2 of  Channel 15 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by writing 1 to bit[2] of wavegen 0xE8 or read bit [5] of wavegen reg 0xE8 1.
R1C*: this bit can be cleared automatically when read 1
6	I_WG_DRIVER_INT_STS[7][0]	RW1C*/R1C*	1’b0	INT ADDR1 of  Channel 15 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by writing 1 to bit[1] of wavegen 0xE8 or read  bit [4] of wavegen reg 0xE8 1
R1C*: this bit can be cleared automatically when read 1
5	I_WG_DRIVER_INT_STS[6][1]	RW1C*/R1C*	1’b0	INT ADDR2 of  Channel 14 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by writing 1 to bit[2] of wavegen 0xA8 or read  bit [5] of wavegen reg 0xA8 1
R1C*: this bit can be cleared automatically when read 1
4	I_WG_DRIVER_INT_STS [6][0]	RW1C*/R1C*	1’b0	INT ADDR1 of  Channel 14 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by writing 1 to bit[1] of wavegen 0xA8 or read  bit [4] of AWG Register 0xA8 1
R1C*: this bit can be cleared automatically when read 1
3	I_WG_DRIVER_INT_STS[5][1]	RW1C*/R1C*	1’b0	INT ADDR2 of  Channel 13 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by writing 1 to bit[2] of wavegen 0x68 or read bit [5] of wavegen reg 0x68 1.
R1C*: this bit can be cleared automatically when read 1
2	I_WG_DRIVER_INT_STS[5][0]	RW1C*/R1C*	1’b0	INT ADDR1 of  Channel 13 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by writing 1 to bit[1] of wavegen 0x68 or read  bit [4] of wavegen reg 0x68 1
R1C*: this bit can be cleared automatically when read 1
1	I_WG_DRIVER_INT_STS[4][1]	RW1C*/R1C*	1’b0	INT ADDR2 of  Channel 12 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by writing 1 to bit[2] of wavegen 0x28 or read  bit [5] of wavegen reg 0x28 1
R1C*: this bit can be cleared automatically when read 1
0	I_WG_DRIVER_INT_STS [4][0]	RW1C*/R1C*	1’b0	INT ADDR1 of  Channel 12 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by writing 1 to bit[1] of wavegen 0x28 or read  bit [4] of AWG Register 0x28 1
R1C*: this bit can be cleared automatically when read 1

 GENERAL_INTERUPT_STATUS_REG06: 0x7E (General Register)
Bit	Field Name	Attribute	Default	Description
7	 NIRS_INT_STS[7]	R1C*	1’b0	NIRS Channel 7 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by reading/writing 1 to bit[7] NIRS_INT_STATUS 0x20
R1C*: this bit can be cleared automatically when read 1
6	 NIRS_INT_STS[6]	R1C*	1’b0	NIRS Channel 6 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by reading/writing 1 to bit[6] NIRS_INT_STATUS 0x20
R1C*: this bit can be cleared automatically when read 1
5	 NIRS_INT_STS[5]	R1C*	1’b0	NIRS Channel 5 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by reading/writing 1 to bit[5] NIRS_INT_STATUS 0x20
R1C*: this bit can be cleared automatically when read 1
4	 NIRS_INT_STS[4]	R1C*	1’b0	NIRS Channel 4 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by reading/writing 1 to bit[4] NIRS_INT_STATUS 0x20
R1C*: this bit can be cleared automatically when read 1
3	 NIRS_INT_STS[3]	R1C*	1’b0	NIRS Channel 3 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by reading/writing 1 to bit[3] NIRS_INT_STATUS 0x20
R1C*: this bit can be cleared automatically when read 1
2	 NIRS_INT_STS[2]	R1C*	1’b0	 NIRS Channel 2 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by reading/writing 1 to bit[2] NIRS_INT_STATUS 0x20
R1C*: this bit can be cleared automatically when read 1
1	 NIRS_INT_STS[1]	R1C*	1’b0	NIRS Channel 1 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by reading/writing 1 to bit[1] NIRS_INT_STATUS 0x20
R1C*: this bit can be cleared automatically when read 1
0	 NIRS_INT_STS[0]	R1C*	1’b0	NIRS Channel 0 Interrupt Status
0: Interrupt is inactive
1: Interrupt is active
Clear Condition:
RW1C*: This bit can be cleared by reading/writing 1 to bit[0] NIRS_INT_STATUS 0x20
R1C*: this bit can be cleared automatically when read 1

 GENERAL_INTERUPT_STATUS_REG04: 0x7C (General Register)
Bit	Field Name	Attribute	Default	Description
7:0	LEAD_OFF_CHx_RESULT	RW1C*/R1C*	0	Lead Off Channel x Status
1: Lead Off Status is active
0: Lead Off status is inactive
RW1C*: This bit can be cleared by writing 1 to bit[x] of normal 0x28 or read bit [x] of General Register at 0x7c.
R1C*: this bit can be cleared automatically when read 1

PINMUX registers
 ATM_HC_SEL: Offset Address: 0x7F
Bit	Field Name	Attribute	Default	Description
7:2	RESERVED	RO	6’b0	No use
1	ANA_BIST_HC_SEL	R/W	1’b0	For CP TEST ONLY and ATM_HC_SEL = 1
0: Pre-hardcoded values will be used for D2A_BIST_EN and D2A_BIST_SEL during CP test mode.
1: D2A_BIST_EN and D2A_BIST_SEL are controlled by system registers during CP test mode.
Notes: 
ANA_ENABLE_REG_3 is the register for D2A_BIST_EN and D2A_BIST_SEL
0	ATM_HC_SEL	R/W	1’b0	For CP TEST ONLY
0: Pre-hardcoded values will be used during CP test mode (If needed).
1: Except for trims, signals are controlled by SPI registers during CP test mode.
All ANA_ENABLE_REGs, except ANA_ENABLE_REG_3

DEBUG registers
COUNTER_CNT_DBG_SEL: 0x80 (General Register)
Bit	Field Name	Attribute	Default	Description
7:4	  RESERVED	RO	0	 No use
3:0	 COUNTER_CNT_DBG_SEL
	RW	4’h00	COUNT_TH (Count Threshold) value selection when Timer expires
Channel number indicator for debug register

COUNTER_CNT_DBG: 0x81-0x84 (General Register)
Bit	Field Name	Attribute	Default	Description
31:0	 COUNTER_CNT_DBG	RO	8'h00	 COUNT_TH value when Time expires
0x81 is the lowest byte, 0x84 is the highest byte

LEAD_OFF_COUNTER_CNT_DAC: Lead Off DAC counter for level 0x85 (General Register)
Bit	Field Name	Attribute	Default	Description
7:0	 LEAD_OFF_COUNTER_CNT_DAC	RO	0x0	For debug purpose, this is the counter lowest 8 bits of Channel x

OTP_TRIMS_DBG_SEL: 0x87 (General Register)
Bit	Field Name	Attribute	Default	Description
7:4	RESERVED	RO	4’h0	Not use
3:0	 OTP_TRIMS_DBG_SEL	RW	4’h0	For debug purpose, read shadow reg
4’h0: trim tag
4’h1: analog trim1
4’h2: analog trim2
4’h3: analog trim3
4’h4: analog trim4
4’h5: analog trim5
4’h6: analog trim6
4’h7: analog trim7
4’h8: analog trim8

OTP_TRIMS_DBG_DATA: 0x88 (General Register)
Bit	Field Name	Attribute	Default	Description
7:0	 OTP_TRIMS_DBG_DATA	RO	0x0	For debug purpose, the trim data comes from otp shadow reg, select by OTP_TRIMS_DBG_SEL


EEG Register
IMEAS_REG_0: 0x90 (Normal Register)
Bit	Field Name	Attribute	Default	Field Description
7	OUTPUT_FORMAT	R/W	1’b0	Output format select 
0: sign output 
1: no sign output
6:5	RESERVED	R/W	2’b00	-
4	IMEAS_ADC_INV	R/W	1’b1	Imeas analog ADC clock phase with digital ADC clock
0: same phase
1: invert phase
3:2	INPUT_FORMAT	R/W	2’b10	Input Format Select
00: 0 meas 0, 1 meas 1
01: 0 meas1, 1 meas -1
10: 0 meas -1, 1 meas 1
11: 0 meas -1, 1 meas 0
1	IMEAS_RST	R/W	1’b0	IMEAS reset 
0: No reset
1: Reset
0	IMEAS_MANUAL_EN	R/W	1’b0	IMEAS manual enable 
If  this bit is 1, then the filter will be controlled by user, it will always running no matter it is one shot or not unless this bit is set to 0
If this bit is 0, then filter will be controlled by start cmd and one shot register.
0: Disable
1: Enable
Next imeas_manual_en can be sent at least 2 ADC clock after previous sampling done

IMEAS_REG_1: 0x91 (Normal Register)
Bit	Field Name	Attribute	Default	Field Description
7	RESERVED	R/W	0	
6:5	FILTER_DATA_FORMAT_MODE	R/W	01	00: 40 bits status + 16 bits data per channel
01: 40 bits status + 24 bits data per channel
10: 32 bits data per channel only 
10: 16 bits data per channel only
11: 24 bits data per channel only
4	DAISY_EN	R/W	0	Daisy enable:
1: Enable
0: Disable
3:0	DR	R/W	7	Output sample rate 
These bits determine the output sample rate of the device. 
000: ADC clock / 8 
001: ADC clock / 16 
010: ADC clock / 32 
011: ADC clock / 64 
100: ADC clock / 128 
101: ADC clock / 256 
110: ADC clock / 512 
111: ADC clock / 1024 
1000: ADC clock / 2048 
1001: ADC clock / 4096
1010: ADC clock / 8192 
1011: ADC clock / 16384 
1100: ADC clock / 32768
1101: ADC clock / 65536

IMEAS_REG_2: 0x92 (Normal Register)
Bit	Field Name	Attribute	Default	Field Description
7:3	RESERVED	R/W	0H	-
2:0	CMD	R/W	0	0/1: reserved
2: start sample cmd
3: stop sample cmd
4: reset cmd
5/6/7: reserved
When set the start cmd, and must set stop cmd firstly when do the next start no matter it is single shot or continuous sampling
Note: the stop cmd should send at least 2 ADC clock after sampling done in single shot
Next start cmd can be sent at least 2 ADC clock after sampling done

STABLE_TIME: 0x93-0x94 (Normal Register)
Bit	Field Name	Attribute	Default	Field Description
15:0	STABLE_TIME	R/W	16’h0010	Analog time stable time before filtering
0x8 is low bytes

IMEAS_DATA: 0x95-0x98 (Normal Register)
Bit	Field Name	Attribute	Default	Field Description
31:0	IMEAS_DATA	RO	32’h0	Imeas data

IMEAS_CTRL: 0x99 (Normal Register)
Bit	Field Name	Attribute	Default	Field Description
7:4	IMEAS_DATA_SEL	R/W	4’h0	Select which channel data to be read by SPI
0: channel0 data
1: channel1 data
……
15: channel15 data

3	SINGLE_SHOT	R/W	1’b0	0: continuous sample
1: single sample
2:0	RESERVED	R/W	3’b000	-

IMEAS_EN_DIS_CH: 0x9A-0x9B (Normal Register)
Bit	Field Name	Attribute	Default	Field Description
15:0	Imeas_en_dis_chn	R/W	0H	Channel disable 
0: Enable
1: Disable
0x9B is high bytes

FILTER_HPF_BP: 0xB1-0xB2 (Normal Register)
Bit	Field Name	Attribute	Default	Field Description
7:0	FILTER_HPF_BP_L	R/W	FFh	The enable signal for the filtering function of the high-pass filter
Bit[x]: x is 0~7
0:  Enable HPF for channel x+1
1:  Disable HPF for channel x+1
15:8	FILTER_HPF_BP_H	R/W	8’hFF	The enable signal for the filtering function of the high-pass filter
Bit[x]: x is 0~7
0:  Enable HPF for channel x+9
1:  Disable HPF for channel x+9
0xB2 is the high byte


FILTER_LPF_BP: 0xB3-0xB4 (Normal Register)
Bit	Field Name	Attribute	Default	Field Description
7:0	FILTER_LPF_BP_L	R/W	FFh	The enable signal for the filtering function of the low-pass filter
Bit[x]: x is 0~7
0:  enable LPF for channel x+1
1:  disable LPF for channel x+1
15:8	FILTER_LPF_BP_H	R/W	FFh	The enable signal for the filtering function of the low-pass filter
Bit[x]: x is 0~7
0:  enable LPF for channel x+9
1:  disable LPF for channel x+9
0xB4 is the high byte

FILTER_NOF_BP: 0xB5-0xB6 (Normal Register)
Bit	Field Name	Attribute	Default	Field Description
7:0	FILTER_NOF_BP_L	R/W	FFh	The enable signal for the filtering function of the notch filter
Bit[x]: x is 0~7
0 :  enable NOF for channel x+1
1:  disable NOF for channel x+1
15:8	FILTER_NOF_BP_H	R/W	FFh	The enable signal for the filtering function of the notch filter
Bit[x]: x is 0~7
0 :  enable NOF for channel x+9
1:  disable NOF for channel x+9
0xB6 is the high byte

FILTER_INT_CTRL: 0xB7 (Normal Register)
Bit	Field Name	Attribute	Default	Field Description
7:2	RESREVED	RO	0h	-
1	EEG_INT_REG_EN	R/W	0h	Used to control whether the interrupt is generated
0 : don’t generate interrupt
1 :  generate interrupt
0	EEG_INT_PIN_EN	R/W	0h	Used to control whether the interrupt is output to the interrupt IO(INTB)
0 : don’t output to INTB
1:  output to INTB

FILTER_INT_STS: 0xB8 (Normal Register)
Bit	Field Name	Attribute	Default	Field Description
7:1	RESREVED	RO	7’h0	-
0	EEG_INT_STS	W1C/R1C	1’b0	EEG data Interrupt Status
0: Interrupt is inactive.
1: Interrupt is active.

Clear Condition:
This bit can be cleared by writing 1 to this bit.
This bit can be cleared by reading this bit 1.

FILTER_NOTCH_DATA_GONE: 0xB9-0xBA (Normal Register)
Bit	Field Name	Attribute	Default	Field Description
7:0	FILTER_NOTCH_DATA_GON _L	R/W	8’h94	It is used for applying a NOTCH filter / LOW-POWER filter to shield the number of data generated during unstable periods.
15:8	FILTER_NOTCH_DATA_GON _H	R/W	8’h3A	
0xBA is the high byte

FILTER_COEFF_ADDR: 0xBB (Normal Register)
Bit	Field Name	Attribute	Default	Field Description
7:0	FILTER_COEFF_DATA_ADD	R/W	00h	Address pointer for storing coefficients
The range is from 0x00 to 0x19

FILTER_COEFF_DATA: 0xBC - 0xBE (Normal Register)
Bit	Field Name	Attribute	Default	Field Description
7:0	FILTER_COEFF_DATA_DATA1	R/W	09h	The array for storing LPF coefficients, notch filter coefficient, and HPF coefficient with the array address specified by register 0xBB, has address 0 for the first coefficient, address 1 for the second coefficient, and so on.
15:8	FILTER_COEFF_DATA_DATA2	R/W	00h	
19:16	FILTER_COEFF_DATA_DATA3	R/W	00h	
0xBE is the high byte

NOTE: for FILTER_COEFF_DATA_DATA3, The upper 2 bits are read-only for the low-pass filter coefficients and read-write for the notch filter coefficients.

FILTER SYNC CTRL Registers
FILTER_DLY_TGT: 0xF0 - 0xF2 (Normal Register)
Bit	Field Name	Attribute	Default	Field Description
7:0	FILTER_DLY_0	R/W	8’hFF	If FILTER_SYNC_EN is 1 and wavegen global enable is 1, then EEG/NIRS will delay FILTER_DLY_TGT ，than start;
and if wavegen reset, then EEG/NIRS reset and repeat the delay again
15:8	FILTER_DLY_1	R/W	8’h00	
23:16	FILTER_DLY_2	R/W	8’h00	

FILTER_SYNC_CTRL: 0xF3 (Normal Register)
Bit	Field Name	Attribute	Default	Field Description
7:6	Reserved	RO	0	
0	FILTER_SYNC_EN	R/W	1’h0	Filter/NIRS sync with wavegen enable


NIRS Registers
NOTE: SWITCH TO NIRS_REG mode to access the NIRS registers. Refer to SPI command section (6.5.4)
NIRS_CTRL_CHANNEL: 0x00 (NIRS register)
There are 8 NIRS channels and 2 LEDs for each channel. To select which channel and which LED to be configured, enable its respective bit in NIRS_CTRL_CHANNEL and NIRS_CTRL_LED. 
For example, if both LEDs of channels 0, 1, and 3 are needs to be configured, write 8’b00001011 to NIRS_CTRL_CHANNEL and 8’b00000011 to NIRS_CTRL_LED. In this setting, both LEDs of channels 0, 1, and 3 are configured simultaneously with the same settings from NIRS_CTRL_x registers.
Bit	Field Name	Attribute	Default	Field Description
7	CHANNEL 7	R/W	0h	 Enable configuring channel 7
6	CHANNEL 6	R/W	0h	 Enable configuring channel 6
5	CHANNEL 5	R/W	0h	 Enable configuring channel 5
4	CHANNEL 4	R/W	0h	 Enable configuring channel 4
3	CHANNEL 3	R/W	0h	 Enable configuring channel 3
2	CHANNEL 2	R/W	0h	 Enable configuring channel 2
1	CHANNEL 1	R/W	0h	 Enable configuring channel 1
0	CHANNEL 0	R/W	0h	 Enable configuring channel 0
 
NIRS_CTRL_LED: 0x01 (NIRS register)
Bit	Field Name	Attribute	Default	Field Description
7:2	RESERVED	R/W	0h	
1	LED 1	R/W	0h	 Enable configuring LED 1
0	LED 0	R/W	0h	 Enable configuring LED 0
 
NIRS_CTRL_0: 0x02 (NIRS register)
Bit	Field Name	Attribute	Default	Field Description
7:4	PERIOD_CTRL	R/W	4h	Control period of the whole operation
Must greater than (t_reset + 10us + t_OTS + t_LED_OFF)
0: 125 us
1: 250 us
2: 500 us
3: 750 us
4: 1 ms
5: 2 ms
6: 4 ms
7: 6 ms
8: 8 ms
9: 10 ms
10: 12 ms
11: 14 ms
12: 16 ms
13: 18 ms
14: 20 ms
15: 22 ms
3:0	OTS_CTRL	R/W	4h	0: 1 us
1: 2 us
2: 3 us
3: 4 us
4: 5 us
5: 6 us
6: 8 us
7: 10 us
8: 15 us
9: 20 us
10: 25 us
11: 30 us
12: 35 us
13: 40 us
14: 45 us
15: 50 us
 
NIRS_CTRL_1: 0x03 (NIRS register)
Bit	Field Name	Attribute	Default	Field Description
7:6	LED_OFF_CTRL	R/W	0h	LED OFF after IPD_SW
0: 2 us
1: 3 us
2: 4 us
3: 5 us
5:3	RESET_CTRL 	R/W	0h	RESET on control
0: 50 us
1: 70 us
2: 100 us
3: 120 us
4: 140 us
5: 160 us
6: 180 us
7: 200 us
2:0	LED_STABLE_CTRL	R/W	2h	Time for LED stable before IPD_SW
*Must less than or equal t_reset
0: 10 us
1: 30 us
2: 50 us
3: 70 us
4: 100 us
5: 120 us
6: 150 us
7: 200 us
 
NIRS_CTRL_2: 0x04 (NIRS register)
Bit	Field Name	Attribute	Default	Field Description
7:6	AVG_SEL	R/W	0h	Selects the moving-average operation applied to DOUT
0: DOUT_final=DOUT_computed
1: DOUT_final=1/2 DOUT_PREV+1/2 DOUT_computed
2: DOUT_final=3/4 DOUT_PREV+1/4 DOUT_computed
3:DOUT_final=15/16 DOUT_PREV+1/16 DOUT_computed
5:0	IDAC_MANUAL[8:3]	R/W	0h	Manual value of IDAC
 
NIRS_CTRL_3: 0x05 (NIRS register)
Bit	Field Name	Attribute	Default	Field Description
7:5	IDAC_MANUAL[2:0]	R/W	0h	 Manual value of IDAC
4	IDAC_MANUAL_EN	R/W	0h	Control the working mode of IDAC:
 0: Automatic
 1: Manual
3	IDAC_EN
(D2A_IDAC_EN)	RW	1h	Enable IDAC in each NIRS channel
0: Disable IDAC
1: Enable IDAC
2:0	THRESHOLD_H[18:16]	R/W	8’h7	High threshold for the IDAC auto cancellation
 
NIRS_CTRL_4: 0x06 (NIRS register)
Bit	Field Name	Attribute	Default	Field Description
7:0	THRESHOLD_H[15:8]	R/W	8’hFF	High threshold for the IDAC auto cancellation
 
NIRS_CTRL_5: 0x07 (NIRS register)
Bit	Field Name	Attribute	Default	Field Description
7:0	THRESHOLD_H[7:0]	R/W	8’hFF	High threshold for the IDAC auto cancellation
 
NIRS_CTRL_6: 0x08 (NIRS register)
Bit	Field Name	Attribute	Default	Field Description
7:0	THRESHOLD_L[7:0]	R/W	8’hFF	Low threshold for the IDAC auto cancellation
 
NIRS_CTRL_7: 0x09 (NIRS register)

Bit	Field Name	Attribute	Default	Field Description
7	RESERVED	RO	00h	 
6:5	IPDMIRROR_ADJ
(D2A_IPDMIRROR_ADJ)	RW	0h	Mirror ratio [(IPD-IDAC) : IMIRROR]
00= 1:1 
01= 2:1
10= 1:2
11= 1:1.5
4:3	IREFC_ADJ
(D2A_IREFC_ADJ)	RW	0h	Iref_coarse current 
00= 0.52 uA
01= 1.04 uA
10= 2.08 uA
11= 4.16 uA
2:1	RATIO_CTRL
(D2A_NIRS_RATIO)	RW	0h	Set the automatic ratio for DOUT
 0: 128
 1: 64
 2: 32
 3: 16
0	RATIO_MODE	RW	0h	 Control the working ratio mode for DOUT:
     0: Automatic
 1: Manual – Set the value using “RATIO_MANUAL”

NIRS_CTRL_8: 0x0A (NIRS register)
Bit	Field Name	Attribute	Default	Field Description
7:0	RATIO_MANUAL	R/W	00h	Ratio for DOUT

NIRS_CTRL_MODE: 0x0B (NIRS register)
Bit	Field Name	Attribute	Default	Field Description
7:6	RESERVED	RO	3’h00	
5	NIRS_PGG_LED_AMBIENT_EN	RW	0h	  0: Only LED mode
 1: AMBIENT mode
	NIRS_PGG_LED_SINGLE_EN = 0: LED0 on ODD cycles -> Ambient0 on EVEN cycles
	NIRS_PGG_LED_SINGLE_EN = 1: LED0 on cycle 1-> Ambient0 on cycle 2 -> LED1 on cycle 3 -> Ambient1 on cycle 4
4	NIRS_PGG_LED_SINGLE_EN	RW	0h	0: DUAL LED mode – Both LED0 and LED1
1: SINGLE LED mode – Only LED0
3:0	NIRS_PGG_MODE_SEL	R/W	0h	Control the working mode of NIRS
0000: RECEIVER MASTER (CONTINOUS – TYPICAL – EN follows period counter)
0100:  RECEIVER MASTER (CON TYP) - EN always on – The measuring cycles still strictly follow the period counter
0x10: RECEIVER MASTER (CON FAST – EN always on) - Counter reset is still available. At the time the falling edge of IREFFINE is detected, we will start new measuring period and reset the counter. 
xxx1: MCU MASTER
1xx0: RECEIVER SINGLE

NIRS_CTRL_INT: 0x0C (NIRS register) – Applied for both LED
Bit	Field Name	Attribute	Default	Field Description
7	IDAC_MIN_EN	R/W	0h	Generate interrupt if IDAC reaches minimum (h’00)
6	IDAC_MAX_EN	R/W	0h	Generate interrupt if IDAC reaches maximum (h’1ff)
5	IREF_FINE_ON_NOT_OFF_EN	R/W	0h	Generate interrupt if IREAF_FINE is ON BUT NOT OFF in a period
4	IREF_FINE_NOT_ON_EN	R/W	0h	Generate interrupt if IREAF_FINE is NOT ON in a period
3	IREF_COARSE_ON_NOT_OFF_EN	R/W	0h	Generate interrupt if IREAF_COARSE is ON BUT NOT OFF in a period
2	IREF_COARSE_NOT_ON_EN	R/W	0h	Generate interrupt if IREAF_CORASE is NOT ON in a period
1	DATA_READY_EN	R/W	0h	Generate interrupt when data is ready
0	NIRS_INT_PIN_EN	R/W	0h	Used to control whether the interrupt is output to the interrupt IO(INTB)
0: don’t output to INTB
1:  output to INTB

NIRS_CTRL_ADJ0: 0x0D (NIRS register) – ALL channels and LEDs work on the same setting!

Bit	Field Name	Attribute	Default	Field Description
7	RESERVED	RO	0h	
6	PDBIAS_EN
(D2A_PDBIAS_EN)	RW	0h	Enable PDBIAS block (only for PPG)
0: Disable
1: Enable 
5:4	PDBIAS_ADJ
(D2A_PDBIAS_ADJ)	RW	0h	Bias voltage for Photodiode (PPG)
00: PDSINK= 1.5V
01: PDSINK= 1.8V
10: PDSINK= 2.1V              
11: PDSINK= 2.4V               
3:2	FCHOP_ADJ
(D2A_FCHOP_ADJ)	RW	0h	Chopper frequency
00: CLK_NIRS/8
01: CLK_NIRS/4
10: CLK_NIRS/2
11: CLK_NIRS/1
1	CHOPPER_EN
(D2A_CHOPPER_EN)	RW	0h	 Enable chopper
0: Disable
1: Enable
0	TEST_EN
(D2A_TEST_EN)	RW	0h	Enable NIRS testmode to measure IREFCOARSE and IREFFINE current then find real IREFCOARSE/IREFFINE ratio

NIRS_CTRL_CLK: 0x0E (NIRS register) - PPG CLOCK – ALL channels and LEDs work on the same setting!
Bit	Field Name	Attribute	Default	Field Description
7:6	RESERVED	R/W	0h	-
5	PPG_RST_REG	R/W	0	Software reset PPG module
0: no reset
1: software reset
4	PPG_CLK50DUTY	R/W	0	PPG clock 50% duty cycle
This is only effective when PPG_CLK_DIV=2 or 3
0： not 50% duty cycle
1:  50 duty cycle
3:2	PPG_CLK_DIV	R/W	0	PPG clock divider
0: 8M
1: 6M
2: 4M
3: 2M
1	ANA_PPG_CLK_INV	R/W	1	Analog ppg clock invert with digital ppg clock
0: same phase
1: invert phase
0	PPG_DIS	R/W	0	Disable NIRS module
0: enable
1: disable

NIRS_CTRL_CMD: 0x0F (NIRS register)
Can enable/stop one or all channels at once, just need to choose which channel to command in NIRS_CTRL_CHANNEL.
For example, if channels 0, 2, 3, and 4 are chosen in the NIRS_CTRL_CHANNEL, then we can start/stop these 4 channels at once.
Bit	Field Name	Attribute	Default	Field Description
7:2	RESERVED	RW	0h	
1:0	NIRS_PPG_CMD	R/W	0h	00: HOLD
01: START
10: MEAS – MCU mode only
11: STOP – CONTINOUS mode only

NIRS_DEBUG_SEL 0x10 (NIRS register) - Virtual memory approach
For example, to choose Channel 2 to work on, write 2 to this register. In this case, all the debugging registers only return information on channel 2.
7:5	RESERVED	RW	0h	 
4	DEBUG LED	RW	0h	 Select the led to be debugged – CTRL REGs ONLY
3:0	DEBUG CHANNEL	RW	0h	Select the channel to be debugged 

NIRS_DEBUG_0 0x11 (NIRS register)
Bit	Field Name	Attribute	Default	Field Description
7:5	RESERVED	RO	0h	 
4:0	DOUTF[12:8]	RO	0h	Output of counter of fine quantization phase
 
NIRS_DEBUG_1 0x12 (NIRS register)
Bit	Field Name	Attribute	Default	Field Description
7:0	DOUF[7:0]	RO	00h	Output of counter of fine quantization phase
 
NIRS_DEBUG_2 0x13 (NIRS register)
Bit	Field Name	Attribute	Default	Field Description
7:5	RESERVED	RO	0h	
4:0	DOUTC[12:8]	RO	00h	Output of counter of coarse quantization phase
 
NIRS_DEBUG_3 0x14 (NIRS register)
Bit	Field Name	Attribute	Default	Field Description
7:0	DOUTC[7:0]	RO	00h	Output of counter of coarse quantization phase
 
NIRS_DEBUG_4: 0x15  (NIRS register) 
Bit	Field Name	Attribute	Default	Field Description
7:6	RESERVED	RO	0h	 
5	IDAC_MAX	RO	0h	IDAC reaches maximum (0x1FF)
4	IDAC_MIN	RO	1h	IDAC reaches minimum (0x0)
3	IREF_COARSE_ON_NOT_OFF	RO	0h	COARSE is ON but not OFF within one period
WRITE 1 to clear
2	IREF_COARSE_NOT_ON	RO	0h	COARSE is not ON within one period
WRITE 1 to clear
1	IREF_FINE_ON_NOT_OFF	RO	0h	FINE is ON but not OFF within one period
WRITE 1 to clear
0	IREF_FINE_NOT_ON	RO	0h	FINE is not ON within one period
WRITE 1 to clear
  
NIRS_INT_STATUS 0x20 (NIRS register)
NIRS data Interrupt Status
0: Interrupt is inactive.
1: Interrupt is active.
 
Clear Condition:
This bit can be cleared by writing 1 to this bit.
This bit can be cleared by reading this bit 1.
Bit	Field Name	Attribute	Default	Field Description
7	NIRS_INT_STS7	W1C/R1C	1’b0	Channel 7
6	NIRS_INT_STS6	W1C/R1C	1’b0	Channel 6
5	NIRS_INT_STS5	W1C/R1C	1’b0	Channel 5
4	NIRS_INT_STS4	W1C/R1C	1’b0	Channel 4
3	NIRS_INT_STS3	W1C/R1C	1’b0	Channel 3
2	NIRS_INT_STS2	W1C/R1C	1’b0	Channel 2
1	NIRS_INT_STS1	W1C/R1C	1’b0	Channel 1
0	NIRS_INT_STS0	W1C/R1C	1’b0	 Channel 0
 
NIRS_DOUT0_0 0x21 (NIRS register)
Final DOUT
Dout = (RATIO_DIG * DOUTC) - DOUTF
Bit	Field Name	Attribute	Default	Field Description
7	RESERVED	RO	0h	
6:0	DOUT0[21:15]	RO	0h	Channel 0 DOUT
 
NIRS_DOUT0_1 0x22 (NIRS register)
Bit	Field Name	Attribute	Default	Field Description
7:0	DOUT0[14:7]	RO	00h	Channel 0 DOUT
 
NIRS_DOUT0_2 0x23 (NIRS register)
Bit	Field Name	Attribute	Default	Field Description
7:1	DOUT0[6:0]	RO	00h	Channel 0 DOUT
0	IDAC0[8]	RO	0h	Channel 0 IDAC
 
NIRS_DOUT0_3 0x24 (NIRS register)
Bit	Field Name	Attribute	Default	Field Description
7:0	IDAC0[7:0]	RO	00h	Channel 0 IDAC

NIRS_DOUT1_0 0x25 (NIRS register)
Final DOUT
Dout = (RATIO_DIG * DOUTC) - DOUTF
Bit	Field Name	Attribute	Default	Field Description
7	RESERVED	RO	0h	
6:0	DOUT1[21:15]	RO	0h	Channel 1 DOUT
 
NIRS_DOUT1_1 0x26 (NIRS register)
Bit	Field Name	Attribute	Default	Field Description
7:0	DOUT1[14:7]	RO	00h	Channel 1 DOUT
 
NIRS_DOUT1_2 0x27 (NIRS register)
Bit	Field Name	Attribute	Default	Field Description
7:1	DOUT1[6:0]	RO	00h	Channel 1 DOUT
0	IDAC1[8]	RO	0h	Channel 1 IDAC
 
NIRS_DOUT1_3 0x28 (NIRS register)
Bit	Field Name	Attribute	Default	Field Description
7:0	IDAC1[7:0]	RO	00h	Channel 1 IDAC

NIRS_DOUT2_0 0x29 (NIRS register)
Final DOUT
Dout = (RATIO_DIG * DOUTC) - DOUTF
Bit	Field Name	Attribute	Default	Field Description
7	RESERVED	RO	0h	
6:0	DOUT2[21:15]	RO	0h	Channel 2 DOUT
 
NIRS_DOUT2_1 0x2A (NIRS register)
Bit	Field Name	Attribute	Default	Field Description
7:0	DOUT2[14:7]	RO	00h	Channel 2 DOUT
 
NIRS_DOUT2_2 0x2B (NIRS register)
Bit	Field Name	Attribute	Default	Field Description
7:1	DOUT2[6:0]	RO	00h	Channel 2 DOUT
0	IDAC2[8]	RO	0h	Channel 2 IDAC
 
NIRS_DOUT2_3 0x2C (NIRS register)
Bit	Field Name	Attribute	Default	Field Description
7:0	IDAC2[7:0]	RO	00h	Channel 2 IDAC

NIRS_DOUT3_0 0x2D (NIRS register)
Final DOUT
Dout = (RATIO_DIG * DOUTC) - DOUTF
Bit	Field Name	Attribute	Default	Field Description
7	RESERVED	RO	0h	
6:0	DOUT3[21:15]	RO	0h	Channel 3 DOUT
 
NIRS_DOUT3_1 0x2E (NIRS register)
Bit	Field Name	Attribute	Default	Field Description
7:0	DOUT3[14:7]	RO	00h	Channel 3 DOUT
 
NIRS_DOUT3_2 0x2F (NIRS register)
Bit	Field Name	Attribute	Default	Field Description
7:1	DOUT3[6:0]	RO	00h	Channel 3 DOUT
0	IDAC3[8]	RO	0h	Channel 3 IDAC
 
NIRS_DOUT3_3 0x30 (NIRS register)
Bit	Field Name	Attribute	Default	Field Description
7:0	IDAC3[7:0]	RO	00h	Channel 3 IDAC

NIRS_DOUT4_0 0x31 (NIRS register)
Final DOUT
Dout = (RATIO_DIG * DOUTC) - DOUTF
Bit	Field Name	Attribute	Default	Field Description
7	RESERVED	RO	0h	
6:0	DOUT4[21:15]	RO	0h	Channel 4 DOUT
 
NIRS_DOUT4_1 0x32 (NIRS register)
Bit	Field Name	Attribute	Default	Field Description
7:0	DOUT4[14:7]	RO	00h	Channel 4 DOUT
 
NIRS_DOUT4_2 0x33 (NIRS register)
Bit	Field Name	Attribute	Default	Field Description
7:1	DOUT4[6:0]	RO	00h	Channel 4 DOUT
0	IDAC4[8]	RO	0h	Channel 4 IDAC
 
NIRS_DOUT4_3 0x34 (NIRS register)
Bit	Field Name	Attribute	Default	Field Description
7:0	IDAC4[7:0]	RO	00h	Channel 4 IDAC

NIRS_DOUT5_0 0x35 (NIRS register)
Final DOUT
Dout = (RATIO_DIG * DOUTC) - DOUTF
Bit	Field Name	Attribute	Default	Field Description
7	RESERVED	RO	0h	
6:0	DOUT5[21:15]	RO	0h	Channel 5 DOUT
 
NIRS_DOUT5_1 0x36 (NIRS register)
Bit	Field Name	Attribute	Default	Field Description
7:0	DOUT5[14:7]	RO	00h	Channel 5 DOUT
 
NIRS_DOUT5_2 0x37 (NIRS register)
Bit	Field Name	Attribute	Default	Field Description
7:1	DOUT5[6:0]	RO	00h	Channel 5 DOUT
0	IDAC5[8]	RO	0h	Channel 5 IDAC

NIRS_DOUT5_3 0x38 (NIRS register)
Bit	Field Name	Attribute	Default	Field Description
7:0	IDAC5[7:0]	RO	00h	Channel 5 IDAC

NIRS_DOUT6_0 0x39 (NIRS register)
Final DOUT
Dout = (RATIO_DIG * DOUTC) - DOUTF
Bit	Field Name	Attribute	Default	Field Description
7	RESERVED	RO	0h	
6:0	DOUT6[21:15]	RO	0h	Channel 6 DOUT
 
NIRS_DOUT6_1 0x3A (NIRS register)
Bit	Field Name	Attribute	Default	Field Description
7:0	DOUT6[14:7]	RO	00h	Channel 6 DOUT
 
NIRS_DOUT6_2 0x3B (NIRS register)
Bit	Field Name	Attribute	Default	Field Description
7:1	DOUT6[6:0]	RO	00h	Channel 6 DOUT
0	IDAC6[8]	RO	0h	Channel 6 IDAC

NIRS_DOUT6_3 0x3C (NIRS register)
Bit	Field Name	Attribute	Default	Field Description
7:0	IDAC6[7:0]	RO	00h	Channel 6 IDAC

NIRS_DOUT7_0 0x3D (NIRS register)
Final DOUT
Dout = (RATIO_DIG * DOUTC) - DOUTF
Bit	Field Name	Attribute	Default	Field Description
7	RESERVED	RO	0h	
6:0	DOUT7[21:15]	RO	0h	Channel 7 DOUT
 
NIRS_DOUT7_1 0x3E (NIRS register)
Bit	Field Name	Attribute	Default	Field Description
7:0	DOUT7[14:7]	RO	00h	Channel 7 DOUT
 
NIRS_DOUT7_2 0x3F (NIRS register)
Bit	Field Name	Attribute	Default	Field Description
7:1	DOUT7[6:0]	RO	00h	Channel 7 DOUT
0	IDAC7[8]	RO	0h	Channel 7 IDAC

NIRS_DOUT7_3 0x40 (NIRS register)
Bit	Field Name	Attribute	Default	Field Description
7:0	IDAC7[[7:0]	RO	00h	Channel 7 IDAC

AWG Register
AWG has a total of 2 identical modules, each module has 64 registers, a total of 64*2=128 registers are used for waveform generator. 
AWG_CONFIG_REG0: 0x02 (AWG Register)
Bit	Field	Type	Default	Description
7 	POSITIVE_PHASE_DISABLE_BIT	R/W	0	Positive Phase Disable 
0：Active
1：Inactive
6	MULTI_ELECTROD	R/W	0	0: source
1: sink
5	CONTIMUE_WAVEFORM	R/W	0	- 1: Continue repeating the waveform when getting second interrupt
- 0:  Don’t continue repeating the waveform when getting second interrupt
4	ALTERNATING (+/-) THE POSITIVE SIDE	R/W	0	0：Disabled
1：Enabled
3	SOURCEB_ENABLE_BIT*	R/W	0	0：Disabled Source B
1：Enabled Source B
2	SILENT_TIME_ENABLE_BIT	R/W	0	0：Disabled Silent Time
1：Enabled Silent Time
1	NEGATIVE_PHASE_ENABLE_BIT	R/W	0	0：Disabled Negative Phase
1：Enabled Negative Phase
0	REST_TIME_ENABLE	R/W	0	0：Disabled Rest Time
1：Enabled Rest Time

AWG_CTRL_REG0: 0x03 (AWG Register)
Bit	Field	Type	Default	Description
7	RESOLUTION_CTRL	R/W	0	0: if, in one period we have positive and negative side, then neg side loads data from different wave data address 
1: if, in one period we have positive and negative side, then neg side loads data from the same wave data address as positive side (which makes waveform symmetric).
For an example
When the point register (0x02) is 8'h14, there are 20 points for positive period and 20 points for negative period. 
- If bit-6 is 0, both pos and neg load data from point0~point19 of data register (bit7 not effective). 
- If bit-6 is 1 and bit-7 is 0, for waveform0, pos period loads data from point0~point19 and neg period loads data from point20~point39；for waveform1, pos period loads data from point40~point59, neg period loads data from point60~point79; for waveform2, pos period loads data from point80~point99, neg period loads data from point100~point119; 
- If bit-6 is 1 and bit-7 is 1,  for waveform0, pos period loads data from point0~point19 and neg period loads data from point0~point19；for waveform1, pos period loads data from point20~point39, neg period loads data from point20~point39; for waveform2, pos period loads data from point40~point59, neg period loads data from point40~point59; that means if we set bit7 1 , we can get a higher resolution)
6	SYM_OR_ASYMMETRICAL _WAVEFORM_EN			Symmetrical Asymmetrical Waveform Selection

0: Symmetrical waveform
1: Asymmetrical waveform
Note:
0: repeats the wave data after reaching number of points per half wave (0x02) 
1: 
For 1 waveform (which means bits[5:3] is 000), goes through pos and neg periods and loads data from wave data (loaded using 0x04 already) continuously until reaches max integer multiple of the number of points (0x02) which is less than 64
For 2 waveforms or 3 waveforms (which means bits[5:3] is 001 or 010), goes through pos and neg periods and loads data from wave data loaded using 0x04 already) continuously until reaches number of points (0x30) multiply by number of waves (bit[5:3] + 1).
(for preload function, this bit should keep 0)
If using 2 or 3 waveforms, bit-6 must set 1
5:3	WAVEFORM_NUM_SEL	0		000: 1 waveform
001: 2 waveforms
010: 3 waveforms
Others: 1 waveform
2:1	WAVEFORM_SEL	0		00: Use the preloaded sine value
01 : Use the preloaded pulse value
10 : Use the preloaded triangle value
11: use the waveform loaded by SPI  
0	WAVEGEN_EN	0		1 ：Enable the wave gen; 
0 ：Disable the wave gen
AWG_POINT_CONFIG_REG: 0x04 (AWG Register)
Name	Address	Default	Attribute	Description
POINTS_NUM_SEL_PER_PHASE

 	0x02	0x40	RW	The number of points which is used per phase.
Depending on register 0x00, bit1 (neg enable/disable), bit7 (pos enable/disable) and register 0x01, bit[5:3] (number of waveforms) and register 0x01, bit[7] (whether load value from same data register) setting, there are the following options:
Normal waveform: 
- If 1 waveform used and either pos or neg enabled, then max value is 64
- If 2 waveforms used and either pos or neg enabled, then max value is 32
- If 3 waveforms used and either pos or neg enabled, then max value is 21
- If 1 waveform used and both pos and neg enabled and load value from different registers, then max value is 32
- If 2 waveforms used and both pos and neg enabled and load value from different registers, then max value is 16
- If 3 waveforms used and both pos and neg enabled and load value from different registers, then max value is 10
- If 1 waveform used and both pos and neg enabled and load value from same registers, then max value is 64
- If 2 waveforms used and both pos and neg enabled and load value from same   registers, then max value is 32
- If 3 waveforms used and both pos and neg enabled and load value from same registers, then max value is 21
Preload function:
The number of points only can be the power of 2: 1, 2, 4, 8, 16, 32, 64
AWG_IN_WAVE_ADDR_REG: 0x01 (AWG Register) 
Name	Address	Default	Attribute	Description
AWG_IN_WAVE_ADDR_REG0 	0x03	0x00	RW	Address for SPI writing the next 8 bit of the wave form value to the register where the wave values are stored.
The value is 0~63
AWG_IN_WAVE_REG: 0x00 (AWG Register) 
Name	Address	Default	Attribute	Description
AWG_IN_WAVE_REG01 
 	0x04	0x00	RW	Next half wave point value to be 
written to the address specified by 
AWG_IN_WAVE_ADDR_ 
REG. 
(depend-on AWG_POINT_CONFIG), 
each point 8 bit between 0 and 255. 
AWG_REST_CLK_REG: 0x05~0x07 (AWG Register)
Name	Address	Default	Attribute	Description
AWG_REST_CLK_REG01	0x05	0x00	RW	Waveform 0: number of clocks for resting time between the positive side and the 
negative side of the wave 0 in a period
 
AWG_REST_CLK_REG02	0x06	0x00	RW	
AWG_REST_CLK_REG03	0x07	0x00	RW	
AWG_SILENT_CLK_REG: 0x08~0x0B (AWG Register) 
Name	Address	Default	Attribute	Description
AWG_SILENT_CLK_REG01	0x08	0x00	RW	Waveform 0: number of clocks for silent time before the next wave period.
AWG_SILENT_CLK_REG02	0x09	0x00	RW	
AWG_SILENT_CLK_REG03	0x0A	0x00	RW	
AWG_SILENT_CLK_REG04	0x0B	0x00	RW	
AWG_POS_PHASE_CLK_PNT_REG: 0x0C~0x0D (AWG Register)
Name	Address	Default	Attribute	Description
AWG_POS_PHASE_CLK_PNT_REG01	0x0B	0x00	RW	Number of system clock per point for the pos halfwave of wave 0 (for example, a pos half-wave can have 64 points, and each point takes 4 clocks, then this register needs to be set 4)
AWG_POS_PHASE_CLK_PNT_REG02	0x0C	0x00	RW	
AWG_NEG_PHASE_CLK_PNT_REG: 0x0E~0x0F (AWG Register)
Name	Address	Default	Attribute	Description
AWG_NEG_PHASE_CLK_PNT_REG01	0x0E	0x00	RW	Number of system clock per point for the neg halfwave of wave 0 (for example, a neg half-wave can have 64 points, and each point takes 4 clocks, then this register needs to be set 4)
AWG_NEG_PHASE_CLK_PNT_REG02	0x0F	0x00	RW	
AWG_REST_CLK1_REG: 0x10~0x11 (AWG Register)
Name	Address	Default	Attribute	Description
AWG_REST_CLK1_REG01
 	0x10	0x00	RW	Waveform1： Number of clocks for resting time between the positive side and the 
``negative side of the wave 1 in a period
AWG_REST_CLK1_REG02	0x11	0x00	RW	
AWG_SILENT_CLK1_REG: 0x12~0x15 (AWG Register) 
Name	Address	Default	Attribute	Description
AWG_SILENT_CLK1_REG01	0x12	0x00	RW	Waveform1： Number of clocks for silent time before the next wave period 
 
AWG_SILENT_CLK1_REG02	0x13	0x00	RW	
AWG_SILENT_CLK1_REG03	0x14	0x00	RW	
AWG_SILENT_CLK1_REG03	0x15	0x00	RW	
AWG_POS_PHASE_CLK_PNT1_REG: 0x16~0x17 (AWG Register)
Name	Address	Default	Attribute	Description
AWG_POS_PHASE_CLK_PNT1_REG01	0x16	0x00	RW	Number of system clock per point for the pos halfwave for wave 1 (for example, a pos half-wave can have 64 points, and each point takes 4 clocks, then this register needs to be set 4)
AWG_POS_PHASE_CLK_PNT1_REG02	0x17	0x00	RW	
AWG_NEG_PHASE_CLK_PNT1_REG: 0x18~0x19 (AWG Register)
Name	Address	Default	Attribute	Description
AWG_NEG_PHASE_CLK_PNT1_ REG01	0x18	0x00	RW	Number of system clock per point for the neg halfwave for wave 1 (for example, a neg half-wave can have 64 points, and each point takes 4 clocks, then this register needs to be set 4)
AWG_NEG_PHASE_CLK_PNT1_ REG02	0x19	0x00	RW	
AWG_REST_CLK2_REG: 0x1A~0x1B (AWG Register)
Name	Address	Default	Attribute	Description
AWG_REST_CLK2_REG01
 	0x1A	0x00	RW	Waveform2 ： 
Number of clocks for resting time between the positive side and the negative side of the wave 2 in a period
 
AWG_REST_CLK2_REG02	0x1B	0x00	RW	
AWG_SILENT_CLK2_REG: 0x1C~0x1F (AWG Register) 
Name	Address	Default	Attribute	Description
AWG_SILENT_CLK2_REG01	0x1C	0x00	RW	Waveform2： Number of clocks for silent time before the next wave period 
AWG_SILENT_CLK2_REG02	0x1D	0x00	RW	
AWG_SILENT_CLK2_REG03	0x1E	0x00	RW	
AWG_SILENT_CLK2_REG04	0x1F	0x00	RW	
AWG_POS_PHASE_CLK_PNT2_REG: 0x20~0x21 (4 AWG Register)
Name	Address	Default	Attribute	Description
AWG_POS_PHASE_CLK_PNT2_REG01	0x20	0x00	RW	Number of system clock per point for the pos halfwave for wave 2 (for example, a pos half-wave can have 64 points, and each point takes 4 clocks, then this register needs to be set 4) 
AWG_POS_PHASE_CLK_PNT2_REG02	0x21	0x00	RW	
AWG_NEG_PHASE_CLK_PNT2_ REG: 0x22~0x23 (4 AWG Register)
Name	Address	Default	Attribute	Description
AWG_NEG_PHASE_CLK_PNT2_ REG01	0x22	0x00	RW	Number of system clock per point for the neg halfwave for wave 2 (for example, a neg half-wave can have 64 points, and each point takes 4 clocks, then this register needs to be set 4)
AWG_NEG_PHASE_CLK_PNT2_ REG02	0x23	0x00	RW	
AWG_DELAY_LIM_REG: 0x24~0x25 (AWG Register)
Name	Address	Default	Attribute	Description
AWG_DELAY_LIM_REG01 	0x24	0x00	RW	Number of clocks for initial delay after the reset is disabled and before the waves are generated 
AWG_DELAY_LIM_REG02	0x25	0x00	RW	
AWG_NEG_SCALE_REG: 0x26 (AWG Register) 
Name	Address	Default	Attribute	Description
AWG_NEG_SCALE_REG 0 
 	0x26	0x01	RW	Bit 7:
0: Scale up the negative side of the waveform by the value of bit[6:0] 
(multiply by this value) 
1: Scale down the negative side of the waveform by the value of bit[6:0] 
(shift right by this value)

For scale-up function of section 9.9.6
DRIVE_REG_CTRL2 is 1
AWG_NEG_OFFSET_REG: 0x27 (AWG Register)
Name	Address	Default	Attribute	Description
AWG_NEG_OFFSET_REG 0 	0x27	0x00	RW	Offset (shift) the negative side of the waveform by this unsigned value 
AWG_POS_SCALE_REG: 0x28 (AWG Register) 
Bit	Name	Default	Attribute	Description
7	SCALE_MODE_SEL	0x01	RW	Scale Mode Selection for Positive Side
0: Scale up the positive side of the waveform by the value of  bit[6:0] 
(multiply by this value) 
1: Scale down by the value of  bit[6:0] 
(shift right by this value)

For scale up function of section 9.9.6
DRIVE_REG_CTRL2 is 1
[6:0]	SCALE_VALUE			ScaleValue of Positive Side
AWG_POS_OFFSET_REG0: 0x29 (AWG Register)
Name	Address	Default	Attribute	Description
AWG_POS_OFFSET_REG 0	0x29	0x00	RW	Offset (shift) the pos side of the waveform by this unsigned value
AWG_DEBOUNCE_REG (Old Name: ADDR_WG_DRV_PULLBA_REG): 0x2A (AWG Register) 
Bit	Name	Default	Attribute	Description
7	PULLAB_BEFORE_POS_EN	1’b0	RW	Enable PULLB & PULLA can be 1 at the same time before next pos side
6	PULLAB_BEFORE_NEG_EN	1’b0	RW	Enable PULLB & PULLA can be 1 at the same time before next neg side
[5:0]	PULLAB_CYCLES_NUM	6’h00	RW	the number of clocks during which PULLB & PULLA is 1
AWG_INT_NUM_WAVE_REG: 0x2B (AWG Register) 
Name	Address	Default	Attribute	Description
AWG_INT_NUM_WAVE_REG02	0x2B	0x00	RW	The number of interrupts suppressed before generating an actual interrupt.
AWG_INT_REG: 0x2C~0x2E (AWG Register)
Name	Address	Default	Attribute	Description
AWG_INT_REG01 
 	0x2C	0x00	RW/RW1C*/R1C*	Write access: 
bit-0: enable interrupting process. 
0：Disable
1：Enable
bit-1: if 1, clears address 1 interrupt. 
bit-2: if 1, clears address 2 interrupt
bit-3: if 1, auto exchange the addresses of int addr1 and int addr2 when clearing address 1 interrupt.
Rest of bits reserved

Read Access: 
bit[3:0]: Wave generator’s 
number whose interrupt status we are reading,each wavegen block has 4 drivers, there are 4 wavegen blocks (select by Normal Register 0x03) 
The first driver a is 4’b000;
The second drive a is 4’b001;
The third driver is 4‘b010；
and so on, the 
last driver is 4'b1111.

bit-4: Interrupt is enabled 
bit-5: First address interrupt 
happened. Enabled when wave gen 
arrives at the first waveform address. 
Support read 1 to clear
bit -6: second address interrupt 
happened. Enabled when wave gen 
arrives at the second waveform address.
Support read 1 to clear
bit -7:  read back the value of bit3 written in write access.
AWG_INT_REG02 
 	0x2D	0x00	RW	First Address Interrupt. 
Enable the SPI interrupt signal when wave gen arrives at this waveform address (there are 64 points 
wave form, hence,64 addresses to 
be used as first address interrupt).
AWG_INT_REG03 
 	0x2E	0x00	RW	Second Address Interrupt. 
Enable the interrupt signal when wave gen arrives at this wave form address (there are 64 points wave form, hence, 64 addresses to be used as second address interrupt).
AWG_ALT_LIM_REG: 0x2F~0x30 (AWG Register)
Name	Address	Default	Attribute	Description
AWG_ALT_LIM_REG01 
 	0x2F	0x00	RW	Number of clocks for a period of 
alternating signal for Channel 1
AWG_ALT_LIM_REG02	0x30	0x00	RW	Number of clocks for a period of 
alternating signal for Channel 2
AWG_ALT_SILENT_LIM_REG: 0x31~0x32 (AWG Register)
Name	Address	Default	Attribute	Description
AWG_ALT_SILENT_LIM_REG01 	0x31	0x00	RW	Number of clocks for each silent duration for the alternating frequency for Channel 1
AWG_ALT_SILENT_LIM_REG02	0x32	0x00	RW	Number of clocks for each silent duration for the alternating frequency for Channel 2

AWG_ALT_REST_LIM_REG: 0x33~0x34 (AWG Register)
Bit	Name	Default	Attribute	Description
[7:0]	AWG_ALT_REST_LIM_REG01 	0x00	RW	Number of clocks for each rest duration for the alternating frequency 
[7:0]	AWG_ALT_REST_LIM_REG02	0x00	RW	Number of clocks for each rest duration for the alternating frequency 

DRIVE_REG_CTRL0: Offset: 0x35 (AWG Register)
Bit	Field Name	Attribute	Default	Description
7:6	RESERVED	RW	2’b00	No use
5	DATA_OUTPUT_MODE	RW	1’b0	To output 

0: 8 bits data (automatic mode)
1: 12 bits data (manual mode and automatic mode)
4	MODE_SEL	RW	1’b0	0: Use automatic mode
1: Use manual mode
3	RESERVED	RW	1’b0	No use
2	DRIVERA_PULLDA	RW	1’b0	DRIVERA_PULLDA (applicable only in manual mode)
0: Disable PA
1: Enable PA
1	RESERVED	RW	1’b0	No use
0	DRIVERA_SOURCEA	RW	1’b0	DRIVERA_SOURCEA (applicable only in manual mode)
0: Disable SA
1: Enable SA
DRIVE_REG_CTRL1: Offset: 0x36 (AWG Register)
Bit	Field Name	Attribute	Default	Description
7:0	D2A_IDAC_DIN_LSB	RW	8’h00	D2A_IDAC_DIN (LSB[7:0])
DRIVE_REG_CTRL2: Offset: 0x37 (AWG Register)
Bit	Field Name	Attribute	Default	Description
7	MULTI ARGO CONTROL	RW	1’b0	Multiplier algorithm control:
0: use right-shift
1: Use a multiplier
6:4	8-BIT_LOCATION_SEL	RW	3’b000	For scale up function of section 9.9.7
000: bit[11:4]
001: bit[10:3]
010: bit[9:2]
011: bit[8:1]
100: bit[7:0]
Others: bit[11:4]
3:0	D2A_IDAC_DIN_MSB	RW	4’b0000	D2A_IDAC_DIN (MSB [3:0]) 
NO_OF_NUM_SLIENT_CTR0: Offset: 0x38 (AWG Register)
Bit	Field Name	Attribute	Default	Description
7:4	RESERVED	RO	6’h00	No use
3	DDS_MODE	RW	1’b0	0 ：disable DDS_MODE
1： enable DDS_MODE
2	MUL_WAVE_REPEAT	RW	1’b0	0 ： disable 
1 ： enable
1	DRIVER_ISEL	RW	1’b0	D2A_CBUF_EN:
Current buffer enable for each driver
(only go to analog） 
0	NO_OF_NUM_SLIENT_DISABLE	RW	1’b0	0: no operation
1: The silent period will only be entered after the number of cycles set in 0x36/0x37 is reached.
NO_OF_NUM_SLIENT_TAR_LSB: Offset: 0x39 (AWG Register)
Bit	Field Name	Attribute	Default	Description
7:0	NO_OF_NUM_SLIENT_TAR_LSB	RW	0x05	The number of cycles that need to be run before entering the silent period.
Bit[7:0]
NO_OF_NUM_SLIENT_TAR_MSB: Offset:0x3A (AWG Register)
Bit	Field Name	Attribute	Default	Description
7:0	NO_OF_NUM_SLIENT_TAR_MSB	RW	0x00	The number of cycles that need to be run before entering the silent period.
Bit[15:8]

ADDR_IS_VALID_FOR_CAL: Offset: 0x3B (AWG Register)
Bit	Field Name	Attribute	Default	Description
7:0	ADDR_IS_VALID_FOR_CAL	RW	0x00	The effective address of scale/offset/MSB_SEL/DECIMAL_SEL
（0x26/0x27/0x28/0x29/0x37 bit[6:4]/0x3c bit[3:0]）
Note: When the value is 0x00, the address is POINT  REG - 1
 
EMS_REG_CTRL: Offset: 0x3C (AWG Register)
Bit	Field Name	Attribute	Default	Description
7:6	RESERVED	RO	2’b00	No use
5:4	PNN_PPN_CTRL	RW	2’b00	To achieve two consecutive positive or negative waveforms without using interrupts.
2‘b00：pos-neg-pos-neg
2’b01:  pos-neg-neg-pos
2’b10:  pos-pos-neg-pos-pos
2’b1: pos-pos-neg-neg
Note: bit6 (SYM_OR_ASYMMETRICAL _WAVEFORM_EN
) of AW_CTRL_REG0 (0x01) should be 0
3	EMS_EN	RW	1’b0	EMS Enable
2:0	DECIMAL_SEL	RW	3’h0	How many decimal places does the specified envelope have
000: 0 decimal place
001: 1 decimal place
010: 2 decimal place
011: 3 decimal place
100: 4 decimal place
101: 5 decimal place
110: 6 decimal place
111: 7 decimal place
 
EMS_REG_NUM: Offset: 0x3D (AWG Register)
Bit	Field Name	Attribute	Default	Description
7:0	EMS_REG_NUM	RW	0x00	In the alternate mode, the number of times the carrier of the same amplitude repeats.


AWG_DRIVEC_SW_CFG: Offset: 0x3E ~ 0x3F (AWG Register)
Bit	Field Name	Attribute	Default	Description
7:0	DRIVEC_SW_CFG0	RW	8’h00	Switch selection for the electrode. Which switch(es) should be used for this electrode. 
Bit 0: switch 0 is used for the electrode. Bit 1: switch 1 is used for the electrode and so on. Combination of bits can be used.
15:8	DRIVEC_SW_CFG1	RW	8’h00	

X -> AWG_DRIVEC_SW_CFG
Y -> the driver which is using
 
                                                       Example 1
 
Example 2

 












Waveform generator1 has same function as waveform regenerator0, the only difference is that SPI addresses are different, the address of Waveform regenerator N (N=0,1) as below:
AWG N = AWG 0 + 8'h40 * N;
AWG MAP
Waveform regenerator	DRIVE_SLCT（normal register）
（Address 0x03 - bit[2:1])	SPI Address
Waveform generator 0	00	0x00 ~ 0x3F
Waveform generator 1	00	0x40 ~ 0x7F
Waveform generator 2	00	0x80 ~ 0BF
Waveform generator 3	00	0xC0 ~ 0xFF
Waveform generator 4	01	0x00 ~ 0x3F
Waveform generator 5	01	0x40 ~ 0x7F
Waveform generator 6	01	0x80 ~ 0BF
Waveform generator 7	01	0xC0 ~ 0xFF
Waveform generator 8	10	0x00 ~ 0x3F
Waveform generator 9	10	0x40 ~ 0x7F
Waveform generator 10	10	0x80 ~ 0BF
Waveform generator 11	10	0xC0 ~ 0xFF
Waveform generator 12	11	0x00 ~ 0x3F
Waveform generator 13	11	0x40 ~ 0x7F
Waveform generator 14	11	0x80 ~ 0BF
Waveform generator 15	11	0xC0 ~ 0xFF
 
EEG FILTER
Block Diagram
The module consists of an on-chip programmable, gain amplifier (PGA), and a Sigma-delta Analog-to-Digital Converter (ADC).
The ADC has up to 16 fully differential analog input pairs. The converter is based on a first order Sigma-delta modulator whose output is over sampled followed by a digital decimation filter. 
Digital filter is a cascaded integrator-comb (CIC) filter with programmable rate change from 8 to 65536.
Features of the module include:
• Up to 16 differential analog inputs
• Programmable sigma-delta output sampling frequency
• CIC filter
• Programmable filter parameter
• Low power
The digital block includes three modules: CIC digital filter, APB Register and EEG CTRL. 
SPI will generate register to other modules.
CIC (cascade integrator comb) is a simple, hardware economical decimation filter, and convert serial ADC data to parallel 24-bit data.
EEG CTRL module samples the 24-bit data from filter when EOC, and based on different channel mode, generate interrupt status and load the convert data to registers. 
 
Interface Table
Name	Direction	Description
Clock and Reset
PCLK	I	Free running APB Clock
PCLKG	I	Gated APB Clock
ADC clock	I	ADC working clock, divider of 2.048MHz
PRESETn	I	APB Reset 
With Analog
ADC_DIN	I	ADC serial data input
Digital filter 
Data_out	O	Filter output data
Data_en	O	Filter output data enable

 Timing Sequence
One shot conversion mode
	Start conversion
	when conversion complete, SD16EOC is asserted, then hardware loads the conversion data into registers 
	stop
 
Channel continuous conversion mode
	Start conversion
	when conversion complete, SD16EOC is asserted, then hardware loads the conversion data into registers
	Continue output conversion data until stop command
 
 

Integer Multiple Decimation of Signal
Decimation is the process of reducing the sampling rate to remove redundant data.
  is the sampling of continuous signal  and the sampling frequency is  . If the sampling rate is reduced to the original  , the   which is an integer that is greater than 1 is called the decimation factor. The new sequence   generates through decimating 1 point per D from  . The sampling rate is   and the relation between   and   is  . So, there is following relational expression.
          (1.1)
When  ,  . 
Figure 1.1 shows the above decimation system:
 

Figure 1.1
The sampling frequency is reduced by decimation, which may cause spectrum aliasing. 
Fourier transforms   and  of   and   are respectively                (1.2)
                         (1.3)
where   rad/s,   is the analog frequency and   is the digital frequency. The   can be expressed as follows:
                                     (1.4)
According to the relational expression between the Fourier Transform of time-domain discrete signal and Fourier Transform of analog signal, there is following relational expression.
                            (1.5)
where   rad/s called the sampling frequency.
     Fourier Transform   of   is shown in figure 1.2(a). Fourier Transform of   is  . When meeting the sampling theorem, the spectrum   is no aliasing phenomenon, as shown in figure 1.2(b). If the sampling rate is reduced to the original    , the spectrum  of   is shown in figure 1.2(c). The cycle   of   has following relational expression.
                             (1.6)
    As can be seen from figure 1.2(c),   aliases and   cannot be recovered from  . So, there is not able to arbitrarily decimate from  . The original signal   can be restored only when the sampling theorem can be satisfied after decimation. Otherwise, low-pass filtering is carried out on signal before decimation. So that the frequency band of the signal is limited to under  . This is called anti-aliasing filtering.
 
Figure 1.2
The block diagram of the decimation system with anti-aliasing filtering is shown in figure 1.3. In the figure   is an anti-aliasing filtering and the highest frequency of its output   is limited below   by  . That is the stop-band cut-off frequency of anti-aliasing filtering. The corresponding digital stop-band cut-off frequency is
                               (1.7)
Therefore, ideally the frequency response   of   can be expressed as follows:

                              (1.8)

 
Figure 1.3
      The spectrum of   is shown in figure 1.4(a). The high-frequency part of   is filtered out. After decimation the spectrum of   avoids aliasing, so   retains the low-frequency part of   and the low-frequency part of   can be recovered from  .
       
 
Figure 1.4
CIC Decimation Filter Design
Four-stage CIC Decimation Filter
The CIC (cascade integrator comb) is a simple, hardware economical decimation filter. When the sampling frequency is much larger than the bandwidth of the input signal, the filter that is using is very fit. The filter consists of four integrator and four comb.
     Three integrators of CIC decimation filter operate at high sampling rate  . The transfer function of single integrator is
                                              (2.1)
     Three combs of CIC decimation filter operate at low sampling rate   . When a single comb operates at high sampling rate  ,the transfer function is
                                          (2.2)
     According to equations (2.1) and (2.2), at high sampling rate  , the transfer function of three-stage CIC filter is
                           (2.3)
The amplitude-frequency response function of the transfer function is

                                     (2.4)
When R=32, the frequency response curve is shown in figure 2.2 according to equations (2.4). The filter is a low-pass filter.

 
Figure 2.2
 
 Digital Filter Technical Index
The technical index of the filter is usually represented by amplitude-frequency response.

 
Figure 2.3
As shown in figure 2.3,  is the cutoff frequency of the passband that is the frequency of the boundary point between the passband and transitional band and drops to   of an artificial lower limit.  is the stop band cutoff frequency that is the frequency of the boundary point between the stop band and transitional band and drops to   of an artificial lower limit.  is the transition frequency and signal attenuates to 3dB. In many cases,  is often used as the pass- band or stop band cutoff frequency. The passband frequency range is  . In the passband,   is required. Stop band frequency range is  . In the stop band,   is required. The range of   to   is called the transitional band.
Maximum attenuation of the passband:
                                 (2.5)
Minimum attenuation of stop band:
                                  (2.6)



 
Figure 2.5
Three-stage CIC decimation filter frequency response:
                                           (2.7)   
Amplitude frequency response characteristic curve of three-stage CIC decimation filter is showed in figure 2.5. When  ,  is   in the passband. When  = , the response value is 0. 
In the stop band, when  , the value of the side bias:
                       (2.8) 
So, it can be seen
                      （2.9）
which can be approximately:  
When  ,  .
When signal attenuate to 3dB,   is used as the cutoff frequency of passband. In this case,   and  .
When  , signal attenuation is 
               
According to the above analysis,   is known.   locate in the transitional band.
Maximum Register Growth in CIC Decimator
In order to prevent data loss due to register overflow, the bit width L of the register must satisfy the following relationship:
                                         （2.10）
N is stage of CIC filter, R is decimation factor and   is the bit width of the input data. 
In CIC filter there are N - j +1 integrators and N combs. The system function is simply
           ,                    (2.11)
Substituting (2.1) and (2.2) into (2.11) results in 
                          (2.12)
This equation can be expanded by dividing the denominator into the numerator resulting in

                (2.13)
A dimensional analysis of (2.13) indicates that the order of the polynomial in terms of   is
                       (2.14)
Thus, the system function can be expressed as a fully expanded polynomial of the same order. The polynomial has the form

                                 (2.15)
where  are the polynomial coefficients.
Using (2.15) definition, the maximum register growth from the first stage up to and including the last stage is simply
                        (2.16)
When j = 1, the system function of CIC filter is 
         (2.17)
Combining (2.15) and (2.17) two equations results in
       (2.18)
and evaluating (2.18) at Z = 1 results in
            (2.19)
 
In equation (2.17) it is noted that the system function is the product of N system functions of the form
                            (2.20)
Since this polynomial has all positive coefficients, it follows that the product of two or more of these polynomials results in a polynomial that also has all positive coefficients. As a result, we can equate the coefficients with their absolute values. This results in a version of (2.19) with the form
                     (2.21)
Substituting this expression into (2.16) results in 
                        (2.22)
If the number of bits in the input data stream is  , then the register growth can be used to calculate  , the most significant bit at the filter output. That is,
               (2.23)

So, the bit width L of the register must satisfy the following relationship (2.10) 
that be derived.
CIC Decimation Filter RTL Implementation
     The input and output signals of CIC decimation filter EEG cic module are defined in table 2.1.
Table 2.1
Signal name	Signal type	Description
clk	input	clock
resentn	input	reset
filter_in	input	data input
cic_rate	input	Decimation factor selection
format_sel	Input	Unsigned output selection
filter_out	output	Filter data output
eoc_out	output	data output valid

The corresponding relationship between cic_rate and R is shown in table 2.2.

Table 2.2
cic_rate	R
0000	8
0001	16
0010	32
0011	64
0100	128
0101	256
0110	512
0111	1024
1000	2048
1001	4096
1010	8192
1011	16384
1100	32768
1101	65536

	bit filter_out that is cut from register c4 of EEG cic
The output data of Sigma-delta ADC analog modulator is 0 and 1 bit data stream. The data stream that input to the CIC decimation need to convert 0 into 1 and 1 into -1. Meanwhile, the input 1 bit data need to be extended to 65 bits according to the cic_rate value.
Four-stage integrator implements an algorithm that accumulates the input data. After the accumulation of the Rth input data, the output data of the four-stage integrator enters into four-stage comb. 
Eoc_out does not work for four counting cycles and remains low after resent. On the fifth counting cycle of count eoc_out outputs the effective high level 
 
When input data continuously is 0, the CIC decimation filter will overflow. The data should be converted into 0X7FFFFFFF. 
Filter Wrapper
Overview
This filter includes three filters, they are High-Pass filter, Low-Pass filter and Notch filter , High-pass filters are used to filter out low-frequency interference signals, low-pass filters are used to filter out high-frequency interference signals, and NOTCH filters can effectively filter out a specific frequency
ENS2_details_report_for_filter_top.xlsx
 
 


Data Rate 
For notch filter, it only supports the data rate: 125hz~64khz, if the The clock frequency generated by the combination of iclk_div and DR is invalid for the notch filter, and the notch filter will be automatically disabled
 

For Low-Pass filter, it only supports the data rate : 31.25hz~256khz, if the The clock frequency generated by the combination of iclk_div and DR is invalid for the Low-Pass filter, and the Low-Pass filter will be automatically disabled
 

For High-Pass filter, it supports data rate: 31.25hz~256khz with no constraint on OSR, if the clock frequency generated by the combination of iclk_div and DR is invalid for the High-Pass filter, and the High-Pass filter will be automatically disabled
 
Disable Filter
If the data rate generated by a combination of iclk_div and DR is invalid, the filter will be automatically disabled, In addition, we can also control and turn off the corresponding filters through the SPI registers, see SPI registers 0xB1~0xB6
Interrupt 
After the data is filtered, an interrupt can be generated(controlled by 0xB7). When the user detects the interrupt, they can check the interrupt register(0xB8) of the filter to see if there is valid data.
There are two types of interrupt triggering methods: level-triggered and pulse-triggered.
There are two ways to clear interrupts: clearing by writing 1 and clearing by reading 1
Unstable time for filter
Whether it is LPF or NF, after the system initialization starts working, it needs to wait for a certain period of time until the system is initially stable before outputting data. The value of this unstable time is 1% of the noise amplitude. That is, assuming the noise amplitude is A, data can be output only when the amplitude fluctuation range of noise is between -0.01A ~  +0.01A
Convert to dB:
Auntable_time = -20log10(A/0.01A) = -40dB

That is, after the unstable period, the noise attenuation is not less than 40 dB.
NOTCH filter
For notch filters, There is an unstable period, approximately 800 milliseconds, during this period, the filter will not output data. This unstable time can be configured and is controlled by SPI registers 0xB9/0xBA, 
Note : As long as one notch filter is disabled, the data interrupt will be output normally. Only when all notch registers are in use will the data interrupt be output after the stabilization time.

LPF 
For LPF, there are an unstable time as below
Data rate	unstable time
256000	0.1ms
128000	0.2ms
64000	0.4ms
32000	0.8ms
16000	1.6ms
8000	3.2ms
4000	6.4ms
2000	12.8ms
1000	25.6ms
500	51.2ms
250	102.4ms
125	204.8ms
62.5	405.6ms
31.25	811.2ms

NOTE : If both LPF and notch are used simultaneously, the unstable time of NOTCH has a higher priority. That is, the unstable time of notch is used as the unstable time of the overall filter.

The formula for register setting time

Register data: A（decimalism）ICLK: B（decimalism）output Y（decimalism）
Y= A* 1E9/8.192E6 *（2^B）*  OSR

Low-Pass Filter
This low-pass filter is based on the equiripple algorithm with FIR and is used to remove high-frequency noise signals.

The following are the design specifications for the low-pass filter.
Parameter 	Value 	Description 
Order 	27	The filter order is 27, which means it has 28 taps. This filter requires 28 coefficients.
Wpass	1dB	Maximum attenuation within the passband
Wstop1 	70dB	When the transition band is Fs/10, the minimum attenuation in the stopband（The transition bandwidth must not be less than FS/10.)
Wstop2	78dB	When the transition band is Fs/8, the minimum attenuation in the stopband
Fs	Set by user	Data rate
Fpass 	Set by user	Passband cutoff frequency
Fstop	Set by user	Stopband cutoff frequency
coefficients	18	The filter coefficients are quantized to 18-bit binary numbers, with 1 sign bit and 17 fractional bits.



Filter coefficients
The coefficients of the low-pass filter can be set using SPI bus:
The value of register 0xBB	coefficients	Default value of {0XBE,0xBD,0xBC}
（Fpass=fs/8, Fstop=fs/4)
0x00	Coeff1	0x09
0x01	Coeff2	0x87
0x02	Coeff3	0x2db
0x03	Coeff4	0x905
0x04	Coeff5	0x131b
0x05	Coeff6	0x1b8f
0x06	Coeff7	0x1743
0x07	Coeff8	0x3fe3f
0x08	Coeff9	0x3d965
0x09	Coeff10	0x3c74d
0x0A	Coeff11	0x3ebf2
0x0B	Coeff12	0x515e
0x0C	Coeff13	0xd382
0x0D	Coeff14	0x12f3c
0x0D	Coeff15	0x12f3c
0x0C	Coeff16	0xd382
0x0B	Coeff17	0x515e
0x0A	Coeff18	0x3ebf2
0x09	Coeff19	0x3c74d
0x08	Coeff20	0x3d965
0x07	Coeff21	0x3fe3f
0x06	Coeff22	0x1743
0x05	Coeff23	0x1b8f
0x04	Coeff24	0x131b
0x03	Coeff25	0x905
0x02	Coeff26	0x2db
0x01	Coeff27	0x87
0x00	Coeff28	0x9

Coefficient calculation
We provide the following code, through which users can obtain the coefficients using Python:

#!/usr/bin/env python3
import numpy as np
from scipy.signal import remez	
 
spec = {
    "Fs": 8192.0,
    "Fpass": 1024.0,
    "Fstop": 2048.0,      # fs/4
    "N": 27,
    "Wpass": 1.0,
    "Wstop": 80.0,
    "DensityFactor": 20
}
def design_lowpass(spec):
    Fs, Fp, Fs2 = spec["Fs"], spec["Fpass"], spec["Fstop"]
    N = int(spec["N"])
    Wp, Ws = float(spec["Wpass"]), float(spec["Wstop"])
    DF = int(spec["DensityFactor"])
    bands = [0.0, Fp, Fs2, Fs/2.0]
    desired = [1.0, 0.0]
    weights = [Wp, Ws]
    numtaps = N + 1
    b = remez(numtaps, bands, desired,
              weight=weights, grid_density=DF, fs=Fs, maxiter=10000)
    return b
 
def quantize_sfix18(b, En=18):
    qbits = 18
    scale = 2**En
    x = np.round(b * scale).astype(np.int64)
    x = np.clip(x, -(1<<(qbits-1)), (1<<(qbits-1))-1)
    return x
 
def hex18_list(x):
    qbits = 18
    return [format(int(v) & ((1<<qbits)-1), '05x').upper() for v in x]
 
b = design_lowpass(spec)
bqi = quantize_sfix18(b)
hexs = hex18_list(bqi)
 
for i in range(0, len(hexs), 4):
    row = hexs[i:i+4]
    print("    " + ", ".join(f"0x{h}" for h in row) + ",")
Stopband_Notch Filter(50HZ)
An IIR notch filter is also implemented at the output of FIR ( LOW-PASS filter) which is ADC 24 bit output. This ADC output will be filtered for any 50 Hz noise. In fact, the stop band of the filter can be changed to any stop band by changing the coefficients. Not only the stop band, other characteristics can also be changed by the change of the coefficients: stop bandwidth, stopband attenuation, gain, filter type (Butterworth, Chebyshev), and sampling rate
To change design parameters of the filter, you need to ensure that you use Matlab Filter Designer tool with Response Type: Bandstop, Design Method: IIR, and Match exactly: stopband, as options (see figure below). Final filter design must have Order 8 and Sections 4 and the following fixed parameters for quantization. Green underlined sections must be the same as figures below. Yellow highlighted values can be changed to generate new coefficients/filter.


The following are the design specifications for the low-pass filter.
Parameter 	Value 	Description 
Order 	8-order and 4 -section	The filter order is 8, It is divided into 4 sections
Apass1	1dB	Maximum attenuation within the passband
Astop	50dB	Attenuation in the stopband
Apass2	1dB	Maximum attenuation within the passband
Fs	Set by user	Data rate
Fpass 1	46.5	Passband cutoff frequency
Fstop1	49	Stopband cutoff frequency
Fstop 2	51	Stopband cutoff frequency
Fpass 2	53.75	Passband cutoff frequency
coefficients	20	The filter coefficients are quantized to 20-bit binary numbers, with 1 sign bit , 1 integer bit and 18 fractional bits.

Filter coefficient 	

The value of register 0xBB	coefficients	Default value of {0XBE,0xBD,0xBC}
(Fs=1000)
0x0e	Scaleconst1/
Scaleconst2	0x3f9f6
0x0f	Coeff_b2_section1	0x86098
0x10	Coeff_a2_section1	0x87a1c
0x11	Coeff_a3_section1	0x3f391
0x12	Coeff_b2_section2	86800
0x13	Coeff_a2_section2	0x865d7
0x14	Coeff_a3_section2	0x3f4ad
0x15	Scaleconst3/
Scaleconst4	0x3f1c2
0x16	Coeff_b2_section3	0x862b5
0x17	Coeff_a2_section3	0x883d4
0x18	Coeff_a3_section3	0x3e301
0x19	Coeff_b2_section4	0x865c6
0x1a	Coeff_a2_section4	0x87ae5
0x1b	Coeff_a3_section4	0x3e419
0x19	Scaleconst5/
Scaleconst6	0x3f089
0x1A	Coeff_a2_section5	0x886f4
0x1B	Coeff_a3_section5	0x3e06f
0x1C	Coeff_a2_section6	0x87c70
0x1D	Coeff_a3_section6	0x3e1d1
0x20	Scaleconst	0x3eee5
0x21	Coeff_a2_section7	0x884c5
0x22	Coeff_a3_section7	0x3ddc9
Coefficient calculation

import subprocess
import sys
import os
 
def run_matlab_filter_design(fs_value):
    script_name = "temp_gen_filter.m"

    matlab_code = f"""
Fs = {fs_value};
Fpass1 = 46.5; Fstop1 = 49; Fstop2 = 51; Fpass2 = 53.75;
Apass1 = 1; Astop = 50; Apass2 = 1; match = 'stopband';
 
h = fdesign.bandstop(Fpass1, Fstop1, Fstop2, Fpass2, Apass1, Astop, Apass2, Fs);
Hd = design(h, 'cheby2', 'MatchExactly', match);
 
set(Hd, 'Arithmetic', 'fixed', 'CoeffWordLength', 20, 'CoeffAutoScale', false, ...
    'NumFracLength', 18, 'DenFracLength', 18, 'ScaleValueFracLength', 18);
 
sos = Hd.sosMatrix;
g = Hd.ScaleValues;
 
for i = 1:size(sos, 1)
    sc = dec2bin(typecast(int32(g(i) * 2^18), 'uint32'), 20);
    b1 = dec2bin(typecast(int32(sos(i,1) * 2^18), 'uint32'), 20);
    b2 = dec2bin(typecast(int32(sos(i,2) * 2^18), 'uint32'), 20);
    b3 = dec2bin(typecast(int32(sos(i,3) * 2^18), 'uint32'), 20);
    a2 = dec2bin(typecast(int32(sos(i,5) * 2^18), 'uint32'), 20);
    a3 = dec2bin(typecast(int32(sos(i,6) * 2^18), 'uint32'), 20);
 
    fprintf('scaleconst%d = 20''b%s\\n', i, sc(end-19:end));
    fprintf('coeff_b1_section%d = 20''b%s\\n', i, b1(end-19:end));
    fprintf('coeff_b2_section%d = 20''b%s\\n', i, b2(end-19:end));
    fprintf('coeff_b3_section%d = 20''b%s\\n', i, b3(end-19:end));
    fprintf('coeff_a2_section%d = 20''b%s\\n', i, a2(end-19:end));
    fprintf('coeff_a3_section%d = 20''b%s\\n', i, a3(end-19:end));
end
 
if length(g) > size(sos,1)
    last_sc = dec2bin(typecast(int32(g(end) * 2^18), 'uint32'), 20);
    fprintf('final_scale = 20''b%s\\n', last_sc(end-19:end));
end
exit;
"""
 
    # 1. Write the code to a temporary .m file
    with open(script_name, "w") as f:
        f.write(matlab_code)
 
    # 2. Run MATLAB on that file
    # -nodesktop -nosplash -r runs the script
    cmd = ["matlab", "-batch", script_name.replace(".m", "")]
 
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        print(result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"Error running MATLAB:\n{e.stderr}\n{e.stdout}")
    finally:
        # 3. Clean up the temporary file
        if os.path.exists(script_name):
            os.remove(script_name)
 
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python get_coeffs.py <sampling_frequency>")
        sys.exit(1)

    fs_arg = sys.argv[1]
    run_matlab_filter_design(fs_arg)

High-pass filter
The following are the design specifications for the high-pass filter.
Parameter 	Value 	Description 
Order 	1-order and 1 -section	The filter order is 1 with one section
Fs	Determined by user	Data rate
Fc 	Determined by user	Cutoff frequency
Scale coefficient	24	The scale coefficient is quantized to 24-bit binary numbers, with 1 sign bit and 23 fractional bits.
Section coefficients	24	The coefficients are quantized to 24-bit binary numbers, with 1 sign bit, 1 integer bit and 22 fractional bits.


Filter coefficient 	
The high-pass filter (HPF) is used to attenuate or remove low-frequency components with an attenuation of 3dB at Fc and a slope of 20dB/dec. To configure the HPF: 
	Determine the sampling rate (Fs) and the cutoff frequency (Fc)
	Calculate the filter coefficient as shown below
	Write into the respective SPI register
The value of register 0xBB	coefficients	Default value of {0xBE,0xBD,0xBC}
(Fs = 1000Hz – Fc = 1Hz)
1c	Scaleconst1	0x7F9961
-	Coeff_b1_section1	0x400000 – Hardcoded
-	Coeff_b2_section1	0xC00000 – Hardcoded
-	Coeff_b3_section1	0x000000 – Hardcoded
-	Coeff_a2_section2	0XC0000A – Calculated automatically  
-	Coeff_a3_section2	0x000000 – Hardcoded

Calculating coefficient value – 24 bits version:
Compute the normalized ratio:
r=F_c/F_s 
Find K:
K=tan(πr)  - Radian
Calculate a – reference denominator (proved in the below section):
a=(K-1)/(K+1)
Calculate b – reference gain:
		HPF:
b_0=(1- a)/2
Quantize b_0 into R (This is the coefficient value programmed into the filter):
b0 is always positive, so it is better to quantize b0 not a.
R=round(b_0*2^23)
Internally, coefficient and constant values will be calculated as following (24 bits in 2’s format):
scaleconsts=b_0 (sfix24_En23 – (-1, 1])
a2=a (sfix24_En22 – (-2, 2])
b1=1 (sfix24_En22 – (-2, 2])
b2=-1 (sfix24_En22 – (-2, 2])
a2=(1-2b_0 ) 2^22=2^22-b_0*2^23=2^22-R

Unstable time:
	Similar to LPF and NF, the HPF needs to wait for the noise amplitude to be attenuated to its 1%. The number of samples it takes for the HPF to reach the desired attenuation of 1%, or 40dB:
 
n_settle=(ln⁡(0.01))/(ln⁡(|a|))
	ln⁡(0.01): desired attenuation
	ln⁡(a):how fast the filter decay per sample
Convert to time domain:
t_settle=n_settle/F_s 
Examples
Fs = 256 kHz, Fc = 0.1 Hz
r=3.9×10^(-7)
K=1.227*10^(-6)
a=-0.9999975456
b_0=0.9999987728
R=83885988
Internally
scalconsts=b_0=0.9999987728*2^23= 8,388,598 =24'b011111111111111111110110
a2=a=-0.9999975456*2^22=-4,194,294=24^' b110000000000000000001010
b1 = 1 = 24'b010000000000000000000000
b2=-1= 24'b110000000000000000000000
n_settle=1876289 samples
t_settle=7.3 s
 

The 1-st order IIR HPF with unity gain at Nyquist:
y[n]=(1 - a)/2*(x[n]-x[n-1])-ay[n-1]
Note:
Y[z]=(1-a)/2*(X[z]-z^(-1) X[z])-az^(-1) Y[z]
Y[z]=(1-a)/2*(X[z]-z^(-1) X[z])-az^(-1) Y[z]
Y[z]  + az^(-1) Y[z]=(1-a)/2*X[z](1-z^(-1) )
Y[z](1 + az^(-1))=(1-a)/2*X[z](1-z^(-1) )
Y[z]/(X[z])=(1-a)/2*((1-z^(-1) ))/((1 + az^(-1)))

The transfer function is
H(z)=(1-a)/2  (1-z^(-1))/(1+az^(-1) )
z=e^jw
H(e^jw )=(1-a)/2  (1-e^(-jw))/(1+ae^(-jw) )
Set gain magnitude to 1/√2 (-3dB)
|H(e^jw )|=1/√2
|H(e^jw )|^2=|(1-a)/2  (1-e^(-jw))/(1+ae^(-jw) )|^2=|1-a|^2/4  |1-e^(-jw) |^2/|1+ae^(-jw) |^2   (*)=1/2

|x|=x x* and 〖(e〗^(-jw))*=e^jw, so (1-e^(-jw))*=1-e^jw (Conjugation)
|1-a|^2/4  (1-e^(-jw) )(1-e^jw )/(1+ae^(-jw) )(1+〖ae〗^jw ) =1/2
|1-a|^2/4  (1-e^jw-e^(-jw)+e^jw e^(-jw))/(1+〖ae〗^jw+〖ae〗^(-jw)+〖a^2 e〗^jw e^(-jw) )=1/2
e^(-jw) e^jw=1
|1-a|^2/4  (1-e^jw-e^(-jw)+1)/(1+〖ae〗^jw+〖ae〗^(-jw)+a^2 )=1/2
e^jw+e^(-jw)=2cos(w)
|1-a|^2/4  (2-〖(e〗^jw+e^(-jw)))/(1+〖a(e〗^jw+e^(-jw))+a^2 )=1/2
|1-a|^2/4  (2-2cos(w))/(1+2acos(w)+a^2 )=1/2
Now solve for a:
(1-a)^2 (1-cos(w))=1+2acos(w)+a^2
If cos(w) ≠0(w ≠  π/2 )
a=(-2±√(4-4〖cos〗^2 (w)))/(2cos(w))=(-1±sin(w))/(cos(w))
For a first-order digital filter, the feedback coefficient must: 
|a|<1
So,
a=-(1-sin(w))/(cos(w))
With bilinear transform, prewarping k=tan(w/2)=tan((2π f_c/f_s )/2)=tan(π f_c/f_s ) ensures -3dB cutoff occurs at desired F_C
Assume k=tan(w/2)=tan((2π f_c/f_s )/2)=tan(π f_c/f_s )
From half-angle identities, sin(w)=(2tan(w/2))/(1+〖tan〗^2 (w/2))=2k/(1+k^2 ) and cos(w)=(1 - 〖tan〗^2 (w/2))/(1+〖tan〗^2 (w/2))=(1-k^2)/(1+k^2 )
a=-(1-2k/(1+k^2 ))/((1-k^2)/(1+k^2 ))=-(1-2k+k^2)/(1+k^2 )  (1+k^2)/(1-k^2 )=-〖(1-k)〗^2/(1-k^2 )
a=(K-1)/(K+1),K=tan(π f_c/f_s )
Default case work through
Fs = 1000 Hz, Fc = 1 Hz – Slope 20dB/dec 
Attenuation of 20dB is at 0.1Hz
 
Fig 14.7.8.3.1 Magnitude & Phase response
 
Fig 14.7.8.3.2 Noise spectrum
Coefficient calculation:
r=1×10^(-3)
K=3.141603*10^(-3)
a=-0.9937364715
b_0=0.9968682358
R=8362337
Internally
scalconsts=b_0=0.9968682358*2^23= 8,362,337=24'b011111111001100101100001
a2=a=-0.9937364715*2^22=-4,168,033=〖24〗^' b110000000110011010011111
b1 = 1 = 24'b010000000000000000000000
b2=-1= 24'b110000000000000000000000
Unstable time:
 
Fig 14.7.8.3.3 Step response
n_settle=733 samples
t_settle=0.733 s=733 ms
Check attenuation:
H(z)=(1-a)/2  (1-z^(-1))/(1+az^(-1) ),|H(e^jw )|=|(1-a)/2  (1-e^(-jw))/(1+ae^(-jw) )|
H(e^jw )=(1-(-0.9937364715))/2  (1-e^(-jw))/(1+(-0.9937364715)e^(-jw) )
|H(e^jw )|^2=|(1+0.9937364715)/2  (1-e^(-jw))/(1-0.9937364715e^(-jw) )|^2

|H(e^jw )|^2=|1.9937364715|^2/4  (2-2cos(w))/(1-2*0.9937364715cos(w)+〖0.9937364715〗^2 )
F=1Hz,  w=0.006283 rad
	|H(e^jw )|≈1/√2=> 20〖log〗_10 |H(e^jw )|≈-3 dB
F=0.1Hz,  w=0.0006283 rad
	|H(e^jw )|≈0.0995⇒ 20〖log〗_10 |0.0995|≈-20 dB

RTL simulation:
	In the 2 figures below, the top waveforms plot both the input and output signals relatively with each other. The bottom waveforms plot solely the output signals.
 
Fig 14.7.8.3.4 Signed simulation
  Fig 14.7.8.3.5 Unsigned simulation

Data Acquisition

Start Mode 
Send the START command to begin conversions. If the START command has not been sent, the device does not issue a DRD (conversions are halted). Using the START opcode to begin conversions. The chip feature two modes to control conversion: continuous and single-shot. The mode is selected by SINGLE_SHOT
In multiple device configurations, can using start cmd to synchronize devices
 
Data Ready (DRDY)
When DRDY transitions high, new conversion data are ready.
DOUT latches at the rising edge of SCLK. The device pulls DRDY low at the first falling edge of SCLK, regardless of whether data are being retrieved from the device or a command is being sent through the DIN pin. The data starts from the MSB of the status word and then proceeds to the ADC channel data in sequential order (that is, channel 1, channel 2, ..., channel x). Channels that are powered down still have a position in the data stream; however, the data is not valid and can be ignored. 

Data Retrieval 
It provides a multiple-readback feature. Set the DAISY_IN bit register to 1 for multiple readbacks. Simply provide additional SCLKs to read data multiple times; the MSB data byte repeats after reading the last byte.
 
Single-Shot Mode 
Enable single-shot mode by setting the SINGLE_SHOT bit register to 1. In single-shot mode, the chip performs a single conversion when the START opcode command is sent. when a conversion completes, DRDY goes high and further conversions are stopped. To begin a new conversion, transmit the STOP opcode and transmit the START opcode again. When switching from continuous conversion mode to single-shot mode, make sure to issue a STOP command followed by a START command.
 
  
Continuous Conversion Mode 
Conversions begin when the START opcode command is sent. As seen in Following figure, the DRDY output goes low when conversions are started and goes high when data are ready. Conversions continue indefinitely until the STOP opcode command is transmitted. When the stop command is issued, the conversion in progress is allowed to complete. When switching from single-shot mode to continuous conversion mode, issue a STOP command followed by a START command
  
 
Multiple-Device Configuration
The device provides configuration flexibility when multiple devices are connected in a system. The serial interface typically requires four signals: DIN, DOUT, SCLK, and CS. With one additional chip select signal per device, multiple devices can be connected together. The number of signals required to interface n devices is 3 + n. To use the internal oscillator in a daisy-chain configuration, set one of the devices as the master for the clock source with the internal oscillator enabled (CLKSEL pin = 1) and the internal oscillator clock brought out of the devic. Use this master device clock as the external clock source for the other devices. When using multiple devices, synchronize the devices with the START cmd.
  
There are two configurations used to connect multiple devices with an optimal number of interface pins: cascade or daisy-chain.
Cascade Configuration 
The following Figure shows a configuration with two devices cascaded together.  DOUT, SCLK, and DIN are shared. Each device has its own chip-select. When a device is not selected by the corresponding CS being driven to logic 1, the DOUT of this device is High-impedance. This structure allows the other device to take control of the DOUT bus.
  
Daisy-Chain Configuration 
Enable daisy-chain mode by setting the DAISY_EN bit register. The following Figure shows the daisy chain configuration. In this configuration, SCLK, DIN, and CS are shared across multiple devices. Connect the DOUT pin of the first device to the DAISY_IN pin of the next device, thereby creating a chain. Issue one extra SCLK between each data set. Note that when using daisy-chain mode, the multiple readback feature is not available. Short the DAISY_IN pin to digital ground if not used. Data from the device1 appears first on DOUT, followed by a don’t care bit, and finally by the status and data words from the device2.
  
  
The interface timing of Daisy-Chain is:
  

PPG controller

Available SPI registers	Directly connecting	FSM
ppg_enable	ppg_enable = 0 (mode 1)	ppg_enable = 1 (mode 2)
Registers used in Mode1 or Mode 2:		Spi ppg reg -->ppg_controller-->analog ppg
Spi_to_ppg_ LEDDAC_SEL	D2A_ LEDDAC_SEL	Changed automatically by FSM
Spi_to_ppg_ LEDSEL<1:0>	D2A_ LEDSEL<1:0>	Changed automatically by FSM
Spi_to_ppg_LED_STANDBYEN	D2A_LED_STANDBYEN	Changed automatically by FSM
Spi_to_ppg_ LED_EN	D2A_ LED_EN	Changed automatically by FSM
Spi_to_ppg_ TIA_IDAC<7:0>	D2A_ TIA_IDAC<7:0>	D2A_ TIA_IDAC<7:0> (two register words available in FSM for LED0 and 1)
Spi_to_ppg_TIA_GAIN<3:0>	D2A_TIA_GAIN<3:0>	D2A_TIA_GAIN<3:0> (two register words available in FSM for LED0 and 1)
Spi_to_ppg_ EN_PPG_AF	D2A_ EN_PPG_AF	Changed automatically by FSM
Spi_to_ppg_ PPG_SH_CK	D2A_ PPG_SH_CK	Changed automatically by FSM
Spi_to_ppg_ EN_PPG_SH	D2A_ EN_PPG_SH	Changed automatically by FSM
Spi_to_ppg_EN_TIA	D2A_EN_TIA	Changed automatically by FSM
Spi_to_ppg_EN_PPG_BUFFER
 	D2A_ EN_PPG_BUFFER
 	Changed automatically by FSM
Spi_to_ppg_EN_PPGDAC_BUFFER
 	D2A_EN_PPGDAC_BUFFER
 	Changed automatically by FSM
Spi_to_ppg_ EN_TIA_VREFBUFFER	D2A_ EN_TIA_VREFBUFFER	Changed automatically by FSM
Sync_by_pass		0: use sync module;1: don’t use sync module;
Spi_to_ppg_PPG_DAC0_VSEL	PPG_DAC0_VSEL	FSM may perform sync
Spi_to_ppg_ PPG_DAC0_EN	PPG_DAC0_EN	FSM may perform sync
Spi_to_ppg_PPG_DAC1_VSEL	PPG_DAC1_VSEL	FSM may perform sync
Spi_to_ppg_ PPG_DAC1_EN	PPG_DAC1_EN	FSM may perform sync
Spi_to_ppg_PPG_TEST_OUT	PPG_TEST_OUT	FSM may perform sync
Spi_to_ppg_PPG_TEST_IN	PPG_TEST_IN	FSM may perform sync
Spi_to_ppg_PPG_PDV_REF_SEL	PG_PDV_REF_SEL	FSM may perform sync
Registers used in Mode2 only: 	Spi ppg control reg -->ppg_controller-->ppg FSM--> analog ppg	
ppg_mode_sel<2:0>	 	ppg_mode_sel<2:0>
ppg_led_time_sel<3:0>	 	ppg_led_time_sel<3:0>
ppg_led_Freq_sel<3:0>	 	ppg_led_Freq_sel<3:0>
ppg_idac_led_Sel	 	ppg_idac_led_Sel
		


block	Registers Name	Description	Default
LED DAC control	PPG_DAC0_VSEL <11:0>	 	00 0000 0000
	PPG_DAC1_VSEL <11:0>	 	00 0000 0000
	PPG_DAC0_EN
		0
	PPG_DAC1_EN
	 	0
	D2A_ LEDDAC_SEL (controlled by FSM in Mode 2)	“0” select  LEDDAC0;
”1” select  LEDDAC1	0
LED Drivier control	D2A_LED_STANDBYEN  (controlled by FSM in Mode 2)	 	0
	D2A_ LED_EN  (controlled by FSM in Mode 2)	 	0
	D2A_ LEDSEL<1:0>  (controlled by FSM in Mode 2)	00=  RED
01=  INFRED
10=  GREEN1
11=  GREEN0	00
 
PPG TIA control	D2A_VREF_SEL<1:0>	00              1.6-1.4=0.2V
01              1.7-1.5=0.4V
10              1.8-1.2=0.6V
11              1.9-1.1=0.8V	00
	D2A_ EN_TIA_VREFBUFFER  (controlled by FSM in Mode 2)	 	0
	D2A_EN_TIA  (controlled by FSM in Mode 2)	 	0
	D2A_TIA_GAIN<3:0>  (controlled by FSM in Mode 2)	1111= 6M 
1110=4.5M 
1101=3.5M 
1100=2.5M 
1011=1.5M
1010=1.1M
1001=0.85M
1000=0.6M
0111=0.5M
0110=0.32M
0101=0.16M
0100=0.08M
0011=0.04M
0010=0.02M
0001=0.01M
0000=1.4K	0000
	D2A_ TIA_IDAC<7:0> (controlled by FSM in Mode 2)	0000 0000=0A;
 
0000 0001~0111 1111
=65nA~65nA*127;
 
1000 0001~1111 1111
=2uA~2uA*127	0000 0000
PPG AF control	D2A_ EN_PPG_AF (controlled by FSM in Mode 2)	 	0
PPG SH control	D2A_ PPG_SH_CK (controlled by FSM in Mode 2)
 	 	0
	D2A_ EN_PPG_SH (controlled by FSM in Mode 2)	 	0
PPG Buffer control	D2A_ EN_PPG_BUFFER (controlled by FSM in Mode 2)	 	0
 	D2A_PPG_TEST_IN<1:0>	 	00 @ controller control mode
	D2A_PPG_TEST_OUT<1:0>	 	00 @ controller control mode

Spi digital signals all from SPI
CONTROL MODE, once received SPI then repeat the configuration 
There are four LED drivers in the PPG system, their name can be organised in the below table.
RED	LED_A
INFRED	LED_B
GREEN1	LED_C
GREEN0	LED_D
 
When PPG system is working, any of two LEDs are chosen to flash alternatively as shown in the Fig 1. During the enable of LED flashing, corresponding DC offset cancelation current should be applied. Each chosen LED is controlled by a DAC. There, two DACs are required.
 
Fig 1. LED driver method
The required digital controller diagram is shown in the Fig 2.
 

Fig 2. Diagram of digital controller (NEEDS update. This is from BMS3)
Updated:
 

The PPG working method is illustrated in the Figure 3.
 



 

Fig 3. PPG function
Where, the function of Mode_Sel is illustrated in the below table.
Mode Sel (FSM input from SPI)	LED1	LED2
000	LED_A	LED_A
001	LED_A	LED_B
010	LED_A	LED_C
011	LED_B	LED_B
100	LED_B	LED_C
101	LED_C	LED_C
110	LED_C	LED_D
111	LED_A	LED_A



For TIA_GAIN and TIA_IDAC, there are two sets of register arrays (reg1 and reg2) in FSM respectively. When IDAC_LEDSEL changes from 0 to 1, data is written to reg1. When IDAC_LEDSEL changes from 1 to 0, data is written to reg2(write data only when IDAC_LEDSEL changes) 
The D2A_LEDDAC_SEL choose the input reference (which is also the DAC buffer output) of the LED_BUFFER.
In PPG analog, the D2A_LEDSEL<1:0> control the LED_BUFFER connections to four LED switches as shown in the blow table.
 

LEDSEL (FSM output)	BUFFER connection
0	LED_A
1	LED_B
2	LED_C
3	LED_D

on_time_sel<3:0> (FSM input from SPI)	duration	unit
0	125	us
1	150	us
2	175	us
3	200	us
4	225	us
5	250	us
6	275	us
7	300	us
8	325	us
9	350	us
10	375	us
11	400	us
12	425	us
13	450	us
14	475	us
 
Period<3:0> (FSM input from SPI)	duration	unit
0	10	ms
1	12	ms
2	14	ms
3	16	ms
4	18	ms
5	20	ms
6	22	ms
7	24	ms
8	26	ms
9	28	ms
10	30	ms
11	32	ms
12	34	ms
13	36	ms
14	38	ms
15	40	ms

 

 


 

PPG REGISTERS:
 
PPG_REG_CTRL_1: Offset Address: 0x72
Bit	Attribute	Default	Field Description
7:6	RO	-	Reserved
5	R/W	1’B0	PPG_SYNC_BYPASS
4:2	RW	3’b000	PPG_MODE_SEL (Mode Selection)
1	RW	1’b0	PPG_IDAC_LED_SEL
0	RW	1’b0	PPG Enable

PPG_LED_TIME_SEL: Offset Address: 0x73
Bit	Attribute	Default	Field Description
7:4	RO	4’b0	RESERVED
3:0	RW	4’b0	PPG LED_TIME_SEL

on_time_sel<3:0>	duration	unit
0	125	us
1	150	us
2	175	us
3	200	us
4	225	us
5	250	us
6	275	us
7	300	us
8	325	us
9	350	us
10	375	us
11	400	us
12	425	us
13	450	us
14	475	us
15	500	us



PPG_LED_FREQ_SEL: Offset Address: 0x74
Bit	Attribute	Default	Field Description
7:4	RO	4’b0	RESERVED
3:0	RW	4’b0	PPG LED_FRQ_SEL

Period<3:0>	duration	unit
0	10	ms
1	12	ms
2	14	ms
3	16	ms
4	18	ms
5	20	ms
6	22	ms
7	24	ms
8	26	ms
9	28	ms
10	30	ms
11	32	ms
12	34	ms
13	36	ms
14	38	ms
15	40	ms

PPG_LED_STATUS: Offset Address: 0x75
Bit	Attribute	Default	Field Description
7:1	RO	4’b0	RESERVED
0	RO	1’b0	PPG_LED_STATUS





APPENDIX
 
 Stimulation parameters
Stimulation channel
Item	Value	Unit
Supply Voltage	5~60	V
Charge Imbalance	<10	uC/sec
 	<0.75uA	mm2
Current Array	8 drivers with current and switches (8 current sources, 8 current sinks)	 
Current Range	0~60, 8bits	mA
Stimulation Frequency	1~10K	Hz
Pulse Width	10~1000, step:10	us
Unit Current	16~240, 16 steps 	uA
Resistance Measurement	0.1~10	k
Waveform example
Figure 23 Square waveform
  
 
 
 
Figure 24 Sine waveform
  
Figure 25 Triangle waveform
  
 






Sine:
 
Triangle : 
 
Pluse :
 




Sine-triangle:
 
sine – pluse :
 

Triangle – pluse :

 




Sine-triangle-pluse:
 

Sine-pluse-triangle:

 


Application Examples ： 
	NORMAL WAVEFROM
In this case,use 4 drivers to generate waveform, named d0,d1,d2,d3; among them, d0 is used as the sink, while d1, d2, and d3 are used as sources.
	Set pos/rest/silent time for d0,d1,d2,d3
For sink, set pos time A0，rest time B0，silent C0
For source，set pos time A1，rest time B1，silent C1


	


















 







