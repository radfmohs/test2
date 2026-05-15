// Library - YJT_GC2, Cell - ENS3, View - schematic
// LAST TIME SAVED: Oct 26 16:29:17 2022
// NETLIST TIME: Oct 26 16:31:54 2022
`timescale 1ns / 1ns 

module ENS2_ANA_CHIP ( 
//temprily connected for verification
A2D_ADC_DATA, //from analog //ADC use posedge of sysclk to output data, 
		//digital use negedge to capture, so we have half sysclk cycle margin for it	
A2D_ADC_DATA_EN,//from analog	
D2A_STIM_PAD0,    //to analog	
D2A_STIM_PAD1,    //to analog	
D2A_ADC_EN,    //to analog	

`ifdef FPGA
  clk_in1,
`endif

// PMU
D2A_BG_TRIM, D2A_IREF_TRIM, D2A_BGBUFFER_CPTEST_EN, D2A_BGBUFFER_TRIM, D2A_LVD_EN, D2A_LVD_SEL, D2A_OSC8MHZEN, D2A_OSC8MHZ_TRIM, 
D2A_CLDO1P8_TRIM, D2A_EN_TSC, D2A_TSC_TRIM, D2A_VDAC8B_DIN, A2D_LVD,  A2D_POR, A2D_CLK8MHZ, A2D_TSC_COMP_OUT,

// BIST ANA
D2A_BIST_EN,
D2A_BIST_SEL,

// DC LEAD OFF
D2A_DCLOFFEN, D2A_LOFF_COMP_TH, D2A_LOFF_ISEL_ADJ, D2A_LOFF_IPOL, 
A2D_LOFF_STATP, A2D_LOFF_STATN,

D2A_BIAS_MEAS, D2A_BIASREF_INT, D2A_EEGLNA_EN, D2A_QSTRLNA_EN, D2A_EEGPGA_EN, D2A_QSTRPGA_EN, D2A_VCMGENBUFF_IADJ, D2A_VCMGENBUFF_EN, D2A_SDMVCMBUFF_EN, D2A_SDMVCMBUFF_IADJ, 
D2A_SDMVCMBUFF_SEL, D2A_SDMVREFPBUFF_EN, D2A_SDMVREFP_IADJ, D2A_SDMVREFP_SEL, D2A_RLD_EN, D2A_RLD_ELECTRODE_EN, D2A_RLD_IADJ, D2A_EEG_CH0_SET, D2A_EEG_CH1_SET, 
D2A_EEG_CH2_SET, D2A_EEG_CH3_SET, D2A_EEG_CH4_SET, D2A_EEG_CH5_SET, D2A_EEG_CH6_SET, D2A_EEG_CH7_SET, D2A_EEG_CH8_SET, D2A_EEG_CH9_SET, D2A_EEG_CH10_SET, D2A_EEG_CH11_SET, 
D2A_EEG_CH12_SET, D2A_EEG_CH13_SET, D2A_EEG_CH14_SET, D2A_EEG_CH15_SET, D2A_EEGLNA0_IADJ, D2A_EEGLNA1_IADJ, D2A_EEGLNA2_IADJ, D2A_EEGLNA3_IADJ, D2A_EEGLNA4_IADJ, D2A_EEGLNA5_IADJ, 
D2A_EEGLNA6_IADJ, D2A_EEGLNA7_IADJ, D2A_EEGLNA8_IADJ, D2A_EEGLNA9_IADJ, D2A_EEGLNA10_IADJ, D2A_EEGLNA11_IADJ, D2A_EEGLNA12_IADJ, D2A_EEGLNA13_IADJ, D2A_EEGLNA14_IADJ, D2A_EEGLNA15_IADJ, 
D2A_EEGLNA0_GAIN, D2A_EEGLNA1_GAIN, D2A_EEGLNA2_GAIN, D2A_EEGLNA3_GAIN, D2A_EEGLNA4_GAIN, D2A_EEGLNA5_GAIN, D2A_EEGLNA6_GAIN, D2A_EEGLNA7_GAIN, D2A_EEGLNA8_GAIN, D2A_EEGLNA9_GAIN, 
D2A_EEGLNA10_GAIN, D2A_EEGLNA11_GAIN, D2A_EEGLNA12_GAIN, D2A_EEGLNA13_GAIN, D2A_EEGLNA14_GAIN, D2A_EEGLNA15_GAIN, D2A_EEGPGA0A_GAIN, D2A_EEGPGA0B_GAIN, D2A_EEGPGA1A_GAIN, D2A_EEGPGA1B_GAIN, 
D2A_EEGPGA2A_GAIN, D2A_EEGPGA2B_GAIN, D2A_EEGPGA3A_GAIN, D2A_EEGPGA3B_GAIN, D2A_EEGPGA4A_GAIN, D2A_EEGPGA4B_GAIN, D2A_EEGPGA5A_GAIN, D2A_EEGPGA5B_GAIN, D2A_EEGPGA6A_GAIN, D2A_EEGPGA6B_GAIN, 
D2A_EEGPGA7A_GAIN, D2A_EEGPGA7B_GAIN, D2A_EEGPGA8A_GAIN, D2A_EEGPGA8B_GAIN, D2A_EEGPGA9A_GAIN, D2A_EEGPGA9B_GAIN, D2A_EEGPGA10A_GAIN, D2A_EEGPGA10B_GAIN, D2A_EEGPGA11A_GAIN, D2A_EEGPGA11B_GAIN, 
D2A_EEGPGA12A_GAIN, D2A_EEGPGA12B_GAIN, D2A_EEGPGA13A_GAIN, D2A_EEGPGA13B_GAIN, D2A_EEGPGA14A_GAIN, D2A_EEGPGA14B_GAIN, D2A_EEGPGA15A_GAIN, D2A_EEGPGA15B_GAIN, 
D2A_INA_CLK,
D2A_EEGPGA0A_IADJ, D2A_EEGPGA0B_IADJ, 
D2A_EEGPGA1A_IADJ, D2A_EEGPGA1B_IADJ, D2A_EEGPGA2A_IADJ, D2A_EEGPGA2B_IADJ, D2A_EEGPGA3A_IADJ, D2A_EEGPGA3B_IADJ, D2A_EEGPGA4A_IADJ, D2A_EEGPGA4B_IADJ, D2A_EEGPGA5A_IADJ, D2A_EEGPGA5B_IADJ, 
D2A_EEGPGA6A_IADJ, D2A_EEGPGA6B_IADJ, D2A_EEGPGA7A_IADJ, D2A_EEGPGA7B_IADJ, D2A_EEGPGA8A_IADJ, D2A_EEGPGA8B_IADJ, D2A_EEGPGA9A_IADJ, D2A_EEGPGA9B_IADJ, D2A_EEGPGA10A_IADJ, D2A_EEGPGA10B_IADJ, 
D2A_EEGPGA11A_IADJ, D2A_EEGPGA11B_IADJ, D2A_EEGPGA12A_IADJ, D2A_EEGPGA12B_IADJ, D2A_EEGPGA13A_IADJ, D2A_EEGPGA13B_IADJ, D2A_EEGPGA14A_IADJ, D2A_EEGPGA14B_IADJ, D2A_EEGPGA15A_IADJ, D2A_EEGPGA15B_IADJ,

// Stimulator
D2A_DATA_0, D2A_DATA_1, D2A_DATA_2, D2A_DATA_3, D2A_DATA_4, D2A_DATA_5, D2A_DATA_6, D2A_DATA_7, D2A_DATA_8, D2A_DATA_9, D2A_DATA_10, D2A_DATA_11, D2A_DATA_12, D2A_DATA_13, D2A_DATA_14, 
D2A_DATA_15, D2A_CBUF_EN, D2A_IDAC_EN, D2A_DRIVER_CUR_EN, D2A_DRIVER_CUR_TRIM, D2A_PULLD, D2A_SOURCE, D2A_STIMU_EN, 
D2A_DRIVERC_LEAD_OFF_EN, 
D2A_DRIVERC_LEAD_OFF_INSEL, 
D2A_DRIVERC_SHORT_DET_EN, 
D2A_DRIVERC_SHORT_DET_VINSEL, 
D2A_DRIVERC_SHORT_DET_VIPSEL, 
A2D_DRIVERC_LEAD_OFF_OUT, 
A2D_DRIVERC_SHORT_DET_OUT,

// NIRS
D2A_PDBIAS_EN, D2A_PDBIAS_ADJ, D2A_CLK_NIRS, D2A_NIRS_CHOPPER_EN, D2A_NIRS_FCHOP_ADJ, D2A_NIRS_TEST_EN, 
D2A_NIRS0_EN, D2A_NIRS0_IDAC_EN, D2A_NIRS0_RESET_SW, D2A_NIRS0_IPD_SW, D2A_NIRS0_IIN_SW, D2A_NIRS0_IPDMIRROR_ADJ, D2A_NIRS0_IREFC_ADJ, D2A_NIRS0_CFRATE_ADJ, D2A_NIRS0_IDAC_ADJ, 
D2A_NIRS1_EN, D2A_NIRS1_IDAC_EN, D2A_NIRS1_RESET_SW, D2A_NIRS1_IPD_SW, D2A_NIRS1_IIN_SW, D2A_NIRS1_IPDMIRROR_ADJ, D2A_NIRS1_IREFC_ADJ, D2A_NIRS1_CFRATE_ADJ, D2A_NIRS1_IDAC_ADJ, 
D2A_NIRS2_EN, D2A_NIRS2_IDAC_EN, D2A_NIRS2_RESET_SW, D2A_NIRS2_IPD_SW, D2A_NIRS2_IIN_SW, D2A_NIRS2_IPDMIRROR_ADJ, D2A_NIRS2_IREFC_ADJ, D2A_NIRS2_CFRATE_ADJ, D2A_NIRS2_IDAC_ADJ, 
D2A_NIRS3_EN, D2A_NIRS3_IDAC_EN, D2A_NIRS3_RESET_SW, D2A_NIRS3_IPD_SW, D2A_NIRS3_IIN_SW, D2A_NIRS3_IPDMIRROR_ADJ, D2A_NIRS3_IREFC_ADJ, D2A_NIRS3_CFRATE_ADJ, D2A_NIRS3_IDAC_ADJ, 
D2A_NIRS4_EN, D2A_NIRS4_IDAC_EN, D2A_NIRS4_RESET_SW, D2A_NIRS4_IPD_SW, D2A_NIRS4_IIN_SW, D2A_NIRS4_IPDMIRROR_ADJ, D2A_NIRS4_IREFC_ADJ, D2A_NIRS4_CFRATE_ADJ, D2A_NIRS4_IDAC_ADJ, 
D2A_NIRS5_EN, D2A_NIRS5_IDAC_EN, D2A_NIRS5_RESET_SW, D2A_NIRS5_IPD_SW, D2A_NIRS5_IIN_SW, D2A_NIRS5_IPDMIRROR_ADJ, D2A_NIRS5_IREFC_ADJ, D2A_NIRS5_CFRATE_ADJ, D2A_NIRS5_IDAC_ADJ, 
D2A_NIRS6_EN, D2A_NIRS6_IDAC_EN, D2A_NIRS6_RESET_SW, D2A_NIRS6_IPD_SW, D2A_NIRS6_IIN_SW, D2A_NIRS6_IPDMIRROR_ADJ, D2A_NIRS6_IREFC_ADJ, D2A_NIRS6_CFRATE_ADJ, D2A_NIRS6_IDAC_ADJ, 
D2A_NIRS7_EN, D2A_NIRS7_IDAC_EN, D2A_NIRS7_RESET_SW, D2A_NIRS7_IPD_SW, D2A_NIRS7_IIN_SW, D2A_NIRS7_IPDMIRROR_ADJ, D2A_NIRS7_IREFC_ADJ, D2A_NIRS7_CFRATE_ADJ, D2A_NIRS7_IDAC_ADJ, 
A2D_NIRS0_IREFCOARSE, A2D_NIRS0_IREFFINE, A2D_NIRS1_IREFCOARSE, A2D_NIRS1_IREFFINE, A2D_NIRS2_IREFCOARSE, A2D_NIRS2_IREFFINE, A2D_NIRS3_IREFCOARSE, A2D_NIRS3_IREFFINE, 
A2D_NIRS4_IREFCOARSE, A2D_NIRS4_IREFFINE, A2D_NIRS5_IREFCOARSE, A2D_NIRS5_IREFFINE, A2D_NIRS6_IREFCOARSE, A2D_NIRS6_IREFFINE, A2D_NIRS7_IREFCOARSE, A2D_NIRS7_IREFFINE,

// SDM
D2A_SDMEN, D2A_SDMCLK, D2A_SDMBUFF_EN, A2D_SDM0, A2D_SDM1, A2D_SDM2, A2D_SDM3, A2D_SDM4, A2D_SDM5, A2D_SDM6,
A2D_SDM7, A2D_SDM8, A2D_SDM9, A2D_SDM10, A2D_SDM11, A2D_SDM12, A2D_SDM13, A2D_SDM14, A2D_SDM15,

// SPARE
D2A_SPI_SPARE0, D2A_SPI_SPARE1, D2A_SPI_SPARE2, D2A_SPI_SPARE3, D2A_TRIM0_SIG_SPARE, D2A_TRIM1_SIG_SPARE, D2A_TRIM2_SIG_SPARE, 
D2A_TRIM3_SIG_SPARE, D2A_TRIM4_SIG_SPARE, D2A_TRIM5_SIG_SPARE, D2A_TRIM6_SIG_SPARE, D2A_TRIM7_SIG_SPARE, A2D_SPARE_RO_REG_0,

// POWER/GND
VDD_DIG,
VSS_DIG,
VDDIO

);
//temprily connected for verification
output wire [9:0] A2D_ADC_DATA; //from analog //ADC use posedge of sysclk to output data, 
		//digital use negedge to capture, so we have half sysclk cycle margin for it	
output wire  A2D_ADC_DATA_EN;//from analog	
input wire[3:0] D2A_STIM_PAD0;    //to analog	
input wire[3:0] D2A_STIM_PAD1;    //to analog	
input wire D2A_ADC_EN;    //to analog	

// PMU
input    [7:0]  D2A_BG_TRIM;
input    [7:0]  D2A_IREF_TRIM;
input           D2A_BGBUFFER_CPTEST_EN;
input    [7:0]  D2A_BGBUFFER_TRIM;
input           D2A_LVD_EN;
input    [2:0]  D2A_LVD_SEL;
input           D2A_OSC8MHZEN;
input    [7:0]  D2A_OSC8MHZ_TRIM;
input    [7:0]  D2A_CLDO1P8_TRIM;
input           D2A_EN_TSC;
input    [7:0]  D2A_TSC_TRIM;
input    [7:0]  D2A_VDAC8B_DIN;

output          A2D_LVD;
output          A2D_POR;
output          A2D_CLK8MHZ;
output          A2D_TSC_COMP_OUT;

// BIST ANA
input           D2A_BIST_EN;
input    [4:0]  D2A_BIST_SEL;

// DC LEAD OFF
input   [15:0]  D2A_DCLOFFEN;
input    [2:0]  D2A_LOFF_COMP_TH;
input    [3:0]  D2A_LOFF_ISEL_ADJ;
input           D2A_LOFF_IPOL;
output  [15:0]  A2D_LOFF_STATP;
output  [15:0]  A2D_LOFF_STATN;

// Recording(MUX-LNA-PGA)
input           D2A_BIAS_MEAS;
input           D2A_BIASREF_INT;
input   [15:0]  D2A_EEGLNA_EN;
input   [15:0]  D2A_QSTRLNA_EN;
input   [15:0]  D2A_EEGPGA_EN;
input   [15:0]  D2A_QSTRPGA_EN;
input    [7:0]  D2A_VCMGENBUFF_IADJ;
input           D2A_VCMGENBUFF_EN;
input           D2A_SDMVCMBUFF_EN;
input    [1:0]  D2A_SDMVCMBUFF_IADJ;
input    [5:0]  D2A_SDMVCMBUFF_SEL;
input           D2A_SDMVREFPBUFF_EN;
input    [1:0]  D2A_SDMVREFP_IADJ;
input    [5:0]  D2A_SDMVREFP_SEL;
input           D2A_RLD_EN;
input           D2A_RLD_ELECTRODE_EN;
input    [7:0]  D2A_RLD_IADJ;
input    [2:0]  D2A_EEG_CH0_SET;
input    [2:0]  D2A_EEG_CH1_SET;
input    [2:0]  D2A_EEG_CH2_SET;
input    [2:0]  D2A_EEG_CH3_SET;
input    [2:0]  D2A_EEG_CH4_SET;
input    [2:0]  D2A_EEG_CH5_SET;
input    [2:0]  D2A_EEG_CH6_SET;
input    [2:0]  D2A_EEG_CH7_SET;
input    [2:0]  D2A_EEG_CH8_SET;
input    [2:0]  D2A_EEG_CH9_SET;
input    [2:0]  D2A_EEG_CH10_SET;
input    [2:0]  D2A_EEG_CH11_SET;
input    [2:0]  D2A_EEG_CH12_SET;
input    [2:0]  D2A_EEG_CH13_SET;
input    [2:0]  D2A_EEG_CH14_SET;
input    [2:0]  D2A_EEG_CH15_SET;
input    [1:0]  D2A_EEGLNA0_IADJ;
input    [1:0]  D2A_EEGLNA1_IADJ;
input    [1:0]  D2A_EEGLNA2_IADJ;
input    [1:0]  D2A_EEGLNA3_IADJ;
input    [1:0]  D2A_EEGLNA4_IADJ;
input    [1:0]  D2A_EEGLNA5_IADJ;
input    [1:0]  D2A_EEGLNA6_IADJ;
input    [1:0]  D2A_EEGLNA7_IADJ;
input    [1:0]  D2A_EEGLNA8_IADJ;
input    [1:0]  D2A_EEGLNA9_IADJ;
input    [1:0]  D2A_EEGLNA10_IADJ;
input    [1:0]  D2A_EEGLNA11_IADJ;
input    [1:0]  D2A_EEGLNA12_IADJ;
input    [1:0]  D2A_EEGLNA13_IADJ;
input    [1:0]  D2A_EEGLNA14_IADJ;
input    [1:0]  D2A_EEGLNA15_IADJ;
input    [5:0]  D2A_EEGLNA0_GAIN;
input    [5:0]  D2A_EEGLNA1_GAIN;
input    [5:0]  D2A_EEGLNA2_GAIN;
input    [5:0]  D2A_EEGLNA3_GAIN;
input    [5:0]  D2A_EEGLNA4_GAIN;
input    [5:0]  D2A_EEGLNA5_GAIN;
input    [5:0]  D2A_EEGLNA6_GAIN;
input    [5:0]  D2A_EEGLNA7_GAIN;
input    [5:0]  D2A_EEGLNA8_GAIN;
input    [5:0]  D2A_EEGLNA9_GAIN;
input    [5:0]  D2A_EEGLNA10_GAIN;
input    [5:0]  D2A_EEGLNA11_GAIN;
input    [5:0]  D2A_EEGLNA12_GAIN;
input    [5:0]  D2A_EEGLNA13_GAIN;
input    [5:0]  D2A_EEGLNA14_GAIN;
input    [5:0]  D2A_EEGLNA15_GAIN;
input    [2:0]  D2A_EEGPGA0A_GAIN;
input    [4:0]  D2A_EEGPGA0B_GAIN;
input    [2:0]  D2A_EEGPGA1A_GAIN;
input    [4:0]  D2A_EEGPGA1B_GAIN;
input    [2:0]  D2A_EEGPGA2A_GAIN;
input    [4:0]  D2A_EEGPGA2B_GAIN;
input    [2:0]  D2A_EEGPGA3A_GAIN;
input    [4:0]  D2A_EEGPGA3B_GAIN;
input    [2:0]  D2A_EEGPGA4A_GAIN;
input    [4:0]  D2A_EEGPGA4B_GAIN;
input    [2:0]  D2A_EEGPGA5A_GAIN;
input    [4:0]  D2A_EEGPGA5B_GAIN;
input    [2:0]  D2A_EEGPGA6A_GAIN;
input    [4:0]  D2A_EEGPGA6B_GAIN;
input    [2:0]  D2A_EEGPGA7A_GAIN;
input    [4:0]  D2A_EEGPGA7B_GAIN;
input    [2:0]  D2A_EEGPGA8A_GAIN;
input    [4:0]  D2A_EEGPGA8B_GAIN;
input    [2:0]  D2A_EEGPGA9A_GAIN;
input    [4:0]  D2A_EEGPGA9B_GAIN;
input    [2:0]  D2A_EEGPGA10A_GAIN;
input    [4:0]  D2A_EEGPGA10B_GAIN;
input    [2:0]  D2A_EEGPGA11A_GAIN;
input    [4:0]  D2A_EEGPGA11B_GAIN;
input    [2:0]  D2A_EEGPGA12A_GAIN;
input    [4:0]  D2A_EEGPGA12B_GAIN;
input    [2:0]  D2A_EEGPGA13A_GAIN;
input    [4:0]  D2A_EEGPGA13B_GAIN;
input    [2:0]  D2A_EEGPGA14A_GAIN;
input    [4:0]  D2A_EEGPGA14B_GAIN;
input    [2:0]  D2A_EEGPGA15A_GAIN;
input    [4:0]  D2A_EEGPGA15B_GAIN;
input           D2A_INA_CLK;
input    [3:0]  D2A_EEGPGA0A_IADJ;
input    [3:0]  D2A_EEGPGA0B_IADJ;
input    [3:0]  D2A_EEGPGA1A_IADJ;
input    [3:0]  D2A_EEGPGA1B_IADJ;
input    [3:0]  D2A_EEGPGA2A_IADJ;
input    [3:0]  D2A_EEGPGA2B_IADJ;
input    [3:0]  D2A_EEGPGA3A_IADJ;
input    [3:0]  D2A_EEGPGA3B_IADJ;
input    [3:0]  D2A_EEGPGA4A_IADJ;
input    [3:0]  D2A_EEGPGA4B_IADJ;
input    [3:0]  D2A_EEGPGA5A_IADJ;
input    [3:0]  D2A_EEGPGA5B_IADJ;
input    [3:0]  D2A_EEGPGA6A_IADJ;
input    [3:0]  D2A_EEGPGA6B_IADJ;
input    [3:0]  D2A_EEGPGA7A_IADJ;
input    [3:0]  D2A_EEGPGA7B_IADJ;
input    [3:0]  D2A_EEGPGA8A_IADJ;
input    [3:0]  D2A_EEGPGA8B_IADJ;
input    [3:0]  D2A_EEGPGA9A_IADJ;
input    [3:0]  D2A_EEGPGA9B_IADJ;
input    [3:0]  D2A_EEGPGA10A_IADJ;
input    [3:0]  D2A_EEGPGA10B_IADJ;
input    [3:0]  D2A_EEGPGA11A_IADJ;
input    [3:0]  D2A_EEGPGA11B_IADJ;
input    [3:0]  D2A_EEGPGA12A_IADJ;
input    [3:0]  D2A_EEGPGA12B_IADJ;
input    [3:0]  D2A_EEGPGA13A_IADJ;
input    [3:0]  D2A_EEGPGA13B_IADJ;
input    [3:0]  D2A_EEGPGA14A_IADJ;
input    [3:0]  D2A_EEGPGA14B_IADJ;
input    [3:0]  D2A_EEGPGA15A_IADJ;
input    [3:0]  D2A_EEGPGA15B_IADJ;

// Stimulator
input   [11:0]  D2A_DATA_0;
input   [11:0]  D2A_DATA_1;
input   [11:0]  D2A_DATA_2;
input   [11:0]  D2A_DATA_3;
input   [11:0]  D2A_DATA_4;
input   [11:0]  D2A_DATA_5;
input   [11:0]  D2A_DATA_6;
input   [11:0]  D2A_DATA_7;
input   [11:0]  D2A_DATA_8;
input   [11:0]  D2A_DATA_9;
input   [11:0]  D2A_DATA_10;
input   [11:0]  D2A_DATA_11;
input   [11:0]  D2A_DATA_12;
input   [11:0]  D2A_DATA_13;
input   [11:0]  D2A_DATA_14;
input   [11:0]  D2A_DATA_15;
input   [15:0]  D2A_CBUF_EN;
input   [15:0]  D2A_IDAC_EN;
input           D2A_DRIVER_CUR_EN;
input    [7:0]  D2A_DRIVER_CUR_TRIM;
input   [15:0]  D2A_PULLD;
input   [15:0]  D2A_SOURCE;
input           D2A_STIMU_EN;
input           D2A_DRIVERC_LEAD_OFF_EN;
input    [3:0]  D2A_DRIVERC_LEAD_OFF_INSEL;
input           D2A_DRIVERC_SHORT_DET_EN;
input    [4:0]  D2A_DRIVERC_SHORT_DET_VINSEL;
input    [4:0]  D2A_DRIVERC_SHORT_DET_VIPSEL;
output          A2D_DRIVERC_LEAD_OFF_OUT;
output          A2D_DRIVERC_SHORT_DET_OUT;

// NIRS
input           D2A_PDBIAS_EN;
input    [1:0]  D2A_PDBIAS_ADJ;
input           D2A_CLK_NIRS;
input           D2A_NIRS_CHOPPER_EN;
input    [1:0]  D2A_NIRS_FCHOP_ADJ;
input           D2A_NIRS_TEST_EN;
input           D2A_NIRS0_EN;
input           D2A_NIRS0_IDAC_EN;
input           D2A_NIRS0_RESET_SW;
input           D2A_NIRS0_IPD_SW;
input           D2A_NIRS0_IIN_SW;
input    [1:0]  D2A_NIRS0_IPDMIRROR_ADJ;
input    [1:0]  D2A_NIRS0_IREFC_ADJ;
input    [1:0]  D2A_NIRS0_CFRATE_ADJ; 
input    [8:0]  D2A_NIRS0_IDAC_ADJ;
input           D2A_NIRS1_EN;
input           D2A_NIRS1_IDAC_EN;
input           D2A_NIRS1_RESET_SW;
input           D2A_NIRS1_IPD_SW;
input           D2A_NIRS1_IIN_SW;
input    [1:0]  D2A_NIRS1_IPDMIRROR_ADJ;
input    [1:0]  D2A_NIRS1_IREFC_ADJ;
input    [1:0]  D2A_NIRS1_CFRATE_ADJ; 
input    [8:0]  D2A_NIRS1_IDAC_ADJ;
input           D2A_NIRS2_EN;
input           D2A_NIRS2_IDAC_EN;
input           D2A_NIRS2_RESET_SW;
input           D2A_NIRS2_IPD_SW;
input           D2A_NIRS2_IIN_SW;
input    [1:0]  D2A_NIRS2_IPDMIRROR_ADJ;
input    [1:0]  D2A_NIRS2_IREFC_ADJ;
input    [1:0]  D2A_NIRS2_CFRATE_ADJ; 
input    [8:0]  D2A_NIRS2_IDAC_ADJ;
input           D2A_NIRS3_EN;
input           D2A_NIRS3_IDAC_EN;
input           D2A_NIRS3_RESET_SW;
input           D2A_NIRS3_IPD_SW;
input           D2A_NIRS3_IIN_SW;
input    [1:0]  D2A_NIRS3_IPDMIRROR_ADJ;
input    [1:0]  D2A_NIRS3_IREFC_ADJ;
input    [1:0]  D2A_NIRS3_CFRATE_ADJ; 
input    [8:0]  D2A_NIRS3_IDAC_ADJ;
input           D2A_NIRS4_EN;
input           D2A_NIRS4_IDAC_EN;
input           D2A_NIRS4_RESET_SW;
input           D2A_NIRS4_IPD_SW;
input           D2A_NIRS4_IIN_SW;
input    [1:0]  D2A_NIRS4_IPDMIRROR_ADJ;
input    [1:0]  D2A_NIRS4_IREFC_ADJ;
input    [5:0]  D2A_NIRS4_CFRATE_ADJ; 
input    [8:0]  D2A_NIRS4_IDAC_ADJ;
input           D2A_NIRS5_EN;
input           D2A_NIRS5_IDAC_EN;
input           D2A_NIRS5_RESET_SW;
input           D2A_NIRS5_IPD_SW;
input           D2A_NIRS5_IIN_SW;
input    [1:0]  D2A_NIRS5_IPDMIRROR_ADJ;
input    [1:0]  D2A_NIRS5_IREFC_ADJ;
input    [1:0]  D2A_NIRS5_CFRATE_ADJ; 
input    [8:0]  D2A_NIRS5_IDAC_ADJ;
input           D2A_NIRS6_EN;
input           D2A_NIRS6_IDAC_EN;
input           D2A_NIRS6_RESET_SW;
input           D2A_NIRS6_IPD_SW;
input           D2A_NIRS6_IIN_SW;
input    [1:0]  D2A_NIRS6_IPDMIRROR_ADJ;
input    [1:0]  D2A_NIRS6_IREFC_ADJ;
input    [1:0]  D2A_NIRS6_CFRATE_ADJ; 
input    [8:0]  D2A_NIRS6_IDAC_ADJ;
input           D2A_NIRS7_EN;
input           D2A_NIRS7_IDAC_EN;
input           D2A_NIRS7_RESET_SW;
input           D2A_NIRS7_IPD_SW;
input           D2A_NIRS7_IIN_SW;
input    [1:0]  D2A_NIRS7_IPDMIRROR_ADJ;
input    [1:0]  D2A_NIRS7_IREFC_ADJ;
input    [1:0]  D2A_NIRS7_CFRATE_ADJ; 
input    [8:0]  D2A_NIRS7_IDAC_ADJ;
output          A2D_NIRS0_IREFCOARSE;
output          A2D_NIRS0_IREFFINE;
output          A2D_NIRS1_IREFCOARSE;
output          A2D_NIRS1_IREFFINE;
output          A2D_NIRS2_IREFCOARSE;
output          A2D_NIRS2_IREFFINE;
output          A2D_NIRS3_IREFCOARSE;
output          A2D_NIRS3_IREFFINE;
output          A2D_NIRS4_IREFCOARSE;
output          A2D_NIRS4_IREFFINE;
output          A2D_NIRS5_IREFCOARSE;
output          A2D_NIRS5_IREFFINE;
output          A2D_NIRS6_IREFCOARSE;
output          A2D_NIRS6_IREFFINE;
output          A2D_NIRS7_IREFCOARSE;
output          A2D_NIRS7_IREFFINE;

// SDM
input   [15:0]  D2A_SDMEN;
input           D2A_SDMCLK;
input   [15:0]  D2A_SDMBUFF_EN;
output          A2D_SDM0;
output          A2D_SDM1;
output          A2D_SDM2;
output          A2D_SDM3;
output          A2D_SDM4;
output          A2D_SDM5;
output          A2D_SDM6;
output          A2D_SDM7;
output          A2D_SDM8;
output          A2D_SDM9;
output          A2D_SDM10;
output          A2D_SDM11;
output          A2D_SDM12;
output          A2D_SDM13;
output          A2D_SDM14;
output          A2D_SDM15;

// SPARE
input    [7:0]  D2A_SPI_SPARE0;
input    [7:0]  D2A_SPI_SPARE1;
input    [7:0]  D2A_SPI_SPARE2;
input    [7:0]  D2A_SPI_SPARE3;
input    [7:0]  D2A_TRIM0_SIG_SPARE;
input    [7:0]  D2A_TRIM1_SIG_SPARE;
input    [7:0]  D2A_TRIM2_SIG_SPARE;
input    [7:0]  D2A_TRIM3_SIG_SPARE;
input    [7:0]  D2A_TRIM4_SIG_SPARE;
input    [7:0]  D2A_TRIM5_SIG_SPARE;
input    [7:0]  D2A_TRIM6_SIG_SPARE;
input    [7:0]  D2A_TRIM7_SIG_SPARE;
output   [7:0]  A2D_SPARE_RO_REG_0;

// POWER/GND
inout           VDD_DIG;
inout           VSS_DIG;
inout           VDDIO;

`ifdef FPGA
        input clk_in1;
`endif



`ifndef MIX_SIM_EN

`ifdef ATPG_PATTERNS
initial begin
  //provided externally. analog should be off during scan test
  force VDD_DIG = 1'b1;
  force VSS_DIG = 1'b0;
end

`else

`ifndef ATPG_SIM
//assign (pull1,pull0) A2D_COMP_OUT_CH1       = '0; 
//assign (pull1,pull0) A2D_COMP_OUT_CH2       = '0; 
assign (pull1,pull0) A2D_TSC_COMP_OUT           = '0;
assign (pull1,pull0) A2D_LVD                    = '0;
assign (pull1,pull0) A2D_SPARE_RO_REG_0         = '0;
assign (pull1,pull0) A2D_DRIVERC_LEAD_OFF_OUT   = '0;
assign (pull1,pull0) A2D_DRIVERC_SHORT_DET_OUT  = '0;
assign (pull1,pull0) A2D_LOFF_STATP             = '0;
assign (pull1,pull0) A2D_LOFF_STATN             = '0;

// --------------------------------------------------------
 // Instantiate OSC
 // --------------------------------------------------------
`ifdef FPGA
wire m8_clk;
wire por_resetn_pll;
ens3_pllfpga u_ens3_pllfpga(
.clk_in1(clk_in1),
.clk_out1(m8_clk),
.locked(por_resetn_pll)
//.m8_clk(m8_clk),
//.por_resetn(por_resetn_pll)
);

reg[4:0] clk_256k_cnt;
always @(posedge m8_clk or negedge por_resetn_pll) begin
  if(~por_resetn_pll)
    clk_256k_cnt <= 5'b0;
  else if(clk_256k_cnt == 15)
    clk_256k_cnt <= 5'b0;
  else
    clk_256k_cnt <= clk_256k_cnt + 1;
end

reg k256_clk;
always @(posedge m8_clk or negedge por_resetn_pll) begin
  if(~por_resetn_pll)
    k256_clk <= 1'b0;
  else if(clk_256k_cnt == 15)	
    k256_clk <= ~k256_clk;
end
assign A2D_CLK8MHZ = k256_clk;
`else
 wire [10:0]  hfosc_rcal ;

 wire         A2D_CLK2MHZ_int;
 assign A2D_CLK8MHZ = D2A_OSC8MHZEN && A2D_CLK2MHZ_int;

 osc_analog OSC (
    //.hfosc                 (  hfosc                   ),
    .hfosc                 (  A2D_CLK2MHZ_int         ),
    .hfosc_rcal            (  hfosc_rcal              )
  );
`endif
 // --------------------------------------------------------
 // Instantiate PMU
 // --------------------------------------------------------

`ifdef FPGA
 assign A2D_POR = por_resetn_pll;

`else
/*
 pmu_analog PMU_SW (
    .VDD_SW(),
    //.wakeup(),
    .VDD_DIG(VDD_DIG),
    .por_resetn            (  A2D_POR              ),
    .cp_en                 (                     ),
    .bat_off               (                   )
  );  
*/
  pmu_analog PMU_SW (
    .POR      (A2D_POR)
    //.CHIP_EN  (1'b1)
  );  


 pmu_analog_always_on PMU_ALW_ON (
    .VDD(VDDIO),
    .por_resetn            (  A2D_VDDI_POR    )
  ); 
`endif

/*
// Daniel added this
wire A2D_COMP_OUT_CH1_tmp, A2D_COMP_OUT_CH2_tmp;

// Lead_off_Short for Channel 1 Instantiation
lead_off_short loff_short_ch1 (
.D2A_DRIVERA_SOURCEA_CHx(D2A_DRIVERA_SOURCEA_CH1),
.D2A_DRIVERA_SOURCEB_CHx(D2A_DRIVERA_SOURCEB_CH1),
.D2A_COMP_ISEL_CHx(1'b0), 
.D2A_COMP_EN_CHx(D2A_COMP_EN_CH1),
.D2A_IDAC_EN_CHx(D2A_IDAC_EN_CH1),
.D2A_IDAC_DIN_CHx(D2A_IDAC_DIN_CH1),
.D2A_VDAC_EN_CHx(D2A_VDAC_EN_CH1),
.D2A_VDAC_DIN_CHx(D2A_VDAC_DIN_CH1),
.D2A_STIMU_COMP_SEL_CHx(D2A_STIMU_COMP_SEL_CH1),
.D2A_STIMU_COMP_EN_CHx(D2A_STIMU_COMP_EN_CH1),
.A2D_COMP(A2D_COMP_OUT_CH1_tmp),
.A2D_COMP_STIMU(A2D_COMP_OUT_STIMU0_1),
.D2A_LEAD_OFF_SEL_SA_SB_CHx(D2A_LEAD_OFF_SEL_SA_SB_CH1)
);

// Lead_off_Short for Channel 2 Instantiation
lead_off_short loff_short_ch2 (
.D2A_DRIVERA_SOURCEA_CHx(D2A_DRIVERA_SOURCEA_CH2),
.D2A_DRIVERA_SOURCEB_CHx(D2A_DRIVERA_SOURCEB_CH2),
.D2A_COMP_ISEL_CHx(1'b0), 
.D2A_COMP_EN_CHx(D2A_COMP_EN_CH2),
.D2A_IDAC_EN_CHx(D2A_IDAC_EN_CH2),
.D2A_IDAC_DIN_CHx(D2A_IDAC_DIN_CH2),
.D2A_VDAC_EN_CHx(D2A_VDAC_EN_CH2),
.D2A_VDAC_DIN_CHx(D2A_VDAC_DIN_CH2),
.D2A_STIMU_COMP_SEL_CHx(D2A_STIMU_COMP_SEL_CH2),
.D2A_STIMU_COMP_EN_CHx(D2A_STIMU_COMP_EN_CH2),
.A2D_COMP(A2D_COMP_OUT_CH2_tmp),
.A2D_COMP_STIMU(A2D_COMP_OUT_STIMU2_3),
.D2A_LEAD_OFF_SEL_SA_SB_CHx(D2A_LEAD_OFF_SEL_SA_SB_CH2)
);
*/

`ifndef SOC_ATPG_EN
//assign A2D_COMP_OUT_CH1 = `SOC_TB.dut_vif.lead_off_comp_reverse ? (loff_short_ch2.comp_pol_high ? !A2D_COMP_OUT_CH2_tmp : A2D_COMP_OUT_CH2_tmp) : (loff_short_ch1.comp_pol_high ? !A2D_COMP_OUT_CH1_tmp : A2D_COMP_OUT_CH1_tmp);
//assign A2D_COMP_OUT_CH2 = `SOC_TB.dut_vif.lead_off_comp_reverse ? (loff_short_ch1.comp_pol_high ? !A2D_COMP_OUT_CH1_tmp : A2D_COMP_OUT_CH1_tmp) : (loff_short_ch2.comp_pol_high ? !A2D_COMP_OUT_CH2_tmp : A2D_COMP_OUT_CH2_tmp);
`endif

// LVD Instantiation
lvd_model lvd_circuit (
.LVD_EN(D2A_LVD_EN), 
.LVD_SEL(D2A_LVD_SEL), 
.ANA_LVD(A2D_LVD)
);

// TSC Monitoring for channel 1 Instantiation
tsc_monitoring_model tsc_monitoring_ch1 (
.D2A_TSC_COMP_EN_CHx(1'b0), 
.D2A_TSC_EN_CHx(D2A_EN_TSC), 
.D2A_TSC_TRIM_CHx(D2A_TSC_TRIM[2:0]), // connect 3-bit only 
.D2A_VDAC8B_EN_CHx(1'b0), 
.D2A_VDAC8B_DIN_CHx(D2A_VDAC8B_DIN), 
.A2D_TSC_COMP_OUT_CHx()
);

wire NIRS_IBIAS_65N;
wire NIRS_IBIAS_1U;
wire PDSINK0, PDSINK1, PDSINK2, PDSINK3, PDSINK4, PDSINK5, PDSINK6, PDSINK7;
wire CLK_NIRS_1P8;
wire CLKCHOP_1P8;
wire CHIP_IBIAS_NIRS;
wire VREF_1P2;
wire CHIP_EN_NIRS;

ppg_nirs_top_model ppg_nirs_top(
.AVDD5P_NIRS(),
.AVDD1P8_NIRS(),

.AVSS5P_NIRS(),
.AVSS1P8_NIRS(),

.CHIP_EN_NIRS(CHIP_EN_NIRS),
.CHIP_IBIAS_NIRS(CHIP_IBIAS_NIRS),

.D2A_CLK_NIRS(D2A_CLK_NIRS),
.D2A_NIRS_CHOPPER_EN(D2A_NIRS_CHOPPER_EN),
.D2A_NIRS_FCHOP_ADJ(D2A_NIRS_FCHOP_ADJ),
.D2A_NIRS_TEST_EN(D2A_NIRS_TEST_EN),

.D2A_PDBIAS_ADJ(D2A_PDBIAS_ADJ),

.NIRS_IBIAS_1U(NIRS_IBIAS_1U),
.NIRS_IBIAS_65N(NIRS_IBIAS_65N),
.VREF_1P2(VREF_1P2),
.CLK_NIRS_1P8(CLK_NIRS_1P8),
.CLKCHOP_1P8(CLKCHOP_1P8),

.PDSINK0(PDSINK0),
.PDSINK1(PDSINK1),
.PDSINK2(PDSINK2),
.PDSINK3(PDSINK3),
.PDSINK4(PDSINK4),
.PDSINK5(PDSINK5),
.PDSINK6(PDSINK6),
.PDSINK7(PDSINK7),

// NIRS 0
.D2A_NIRS0_RESET_SW(D2A_NIRS0_RESET_SW),
.D2A_NIRS0_IPD_SW(D2A_NIRS0_IPD_SW),
.D2A_NIRS0_IIN_SW(D2A_NIRS0_IIN_SW),
.D2A_NIRS0_IPDMIRROR_ADJ(D2A_NIRS0_IPDMIRROR_ADJ),
.D2A_NIRS0_IREFC_ADJ(D2A_NIRS0_IREFC_ADJ[1:0]),
.D2A_NIRS0_CFRATE_ADJ(D2A_NIRS0_CFRATE_ADJ),
.D2A_NIRS0_IDAC(D2A_NIRS0_IDAC_ADJ),
.D2A_NIRS0_EN(D2A_NIRS0_EN),
.D2A_NIRS0_IDAC_EN(D2A_NIRS0_IDAC_EN),

.A2D_NIRS0_IREFCOARSE(A2D_NIRS0_IREFCOARSE), // SW2
.A2D_NIRS0_IREFFINE(A2D_NIRS0_IREFFINE),   // SW3

// NIRS 1
.D2A_NIRS1_RESET_SW(D2A_NIRS1_RESET_SW),
.D2A_NIRS1_IPD_SW(D2A_NIRS1_IPD_SW),
.D2A_NIRS1_IIN_SW(D2A_NIRS1_IIN_SW),
.D2A_NIRS1_IPDMIRROR_ADJ(D2A_NIRS1_IPDMIRROR_ADJ),
.D2A_NIRS1_IREFC_ADJ(D2A_NIRS1_IREFC_ADJ[1:0]),
.D2A_NIRS1_CFRATE_ADJ(D2A_NIRS1_CFRATE_ADJ),
.D2A_NIRS1_IDAC(D2A_NIRS1_IDAC_ADJ),
.D2A_NIRS1_EN(D2A_NIRS1_EN),
.D2A_NIRS1_IDAC_EN(D2A_NIRS1_IDAC_EN),

.A2D_NIRS1_IREFCOARSE(A2D_NIRS1_IREFCOARSE), // SW2
.A2D_NIRS1_IREFFINE(A2D_NIRS1_IREFFINE),   // SW3

// NIRS 2
.D2A_NIRS2_RESET_SW(D2A_NIRS2_RESET_SW),
.D2A_NIRS2_IPD_SW(D2A_NIRS2_IPD_SW),
.D2A_NIRS2_IIN_SW(D2A_NIRS2_IIN_SW),
.D2A_NIRS2_IPDMIRROR_ADJ(D2A_NIRS2_IPDMIRROR_ADJ),
.D2A_NIRS2_IREFC_ADJ(D2A_NIRS2_IREFC_ADJ[1:0]),
.D2A_NIRS2_CFRATE_ADJ(D2A_NIRS2_CFRATE_ADJ),
.D2A_NIRS2_IDAC(D2A_NIRS2_IDAC_ADJ),
.D2A_NIRS2_EN(D2A_NIRS2_EN),
.D2A_NIRS2_IDAC_EN(D2A_NIRS2_IDAC_EN),

.A2D_NIRS2_IREFCOARSE(A2D_NIRS2_IREFCOARSE), // SW2
.A2D_NIRS2_IREFFINE(A2D_NIRS2_IREFFINE),   // SW3

// NIRS 3
.D2A_NIRS3_RESET_SW(D2A_NIRS3_RESET_SW),
.D2A_NIRS3_IPD_SW(D2A_NIRS3_IPD_SW),
.D2A_NIRS3_IIN_SW(D2A_NIRS3_IIN_SW),
.D2A_NIRS3_IPDMIRROR_ADJ(D2A_NIRS3_IPDMIRROR_ADJ),
.D2A_NIRS3_IREFC_ADJ(D2A_NIRS3_IREFC_ADJ[1:0]),
.D2A_NIRS3_CFRATE_ADJ(D2A_NIRS3_CFRATE_ADJ),
.D2A_NIRS3_IDAC(D2A_NIRS3_IDAC_ADJ),
.D2A_NIRS3_EN(D2A_NIRS3_EN),
.D2A_NIRS3_IDAC_EN(D2A_NIRS3_IDAC_EN),

.A2D_NIRS3_IREFCOARSE(A2D_NIRS3_IREFCOARSE), // SW2
.A2D_NIRS3_IREFFINE(A2D_NIRS3_IREFFINE),   // SW3

// NIRS 4
.D2A_NIRS4_RESET_SW(D2A_NIRS4_RESET_SW),
.D2A_NIRS4_IPD_SW(D2A_NIRS4_IPD_SW),
.D2A_NIRS4_IIN_SW(D2A_NIRS4_IIN_SW),
.D2A_NIRS4_IPDMIRROR_ADJ(D2A_NIRS4_IPDMIRROR_ADJ),
.D2A_NIRS4_IREFC_ADJ(D2A_NIRS4_IREFC_ADJ[1:0]),
.D2A_NIRS4_CFRATE_ADJ(D2A_NIRS4_CFRATE_ADJ),
.D2A_NIRS4_IDAC(D2A_NIRS4_IDAC_ADJ),
.D2A_NIRS4_EN(D2A_NIRS4_EN),
.D2A_NIRS4_IDAC_EN(D2A_NIRS4_IDAC_EN),

.A2D_NIRS4_IREFCOARSE(A2D_NIRS4_IREFCOARSE), // SW2
.A2D_NIRS4_IREFFINE(A2D_NIRS4_IREFFINE),   // SW3

.NIRS4_IREFCOARSE_TEST(NIRS4_IREFCOARSE_TEST),
.NIRS4_IREFFINE_TEST(NIRS4_IREFFINE_TEST),
.NIRS4_IDAC_TEST(NIRS4_IDAC_TEST),

// NIRS 5
.D2A_NIRS5_RESET_SW(D2A_NIRS5_RESET_SW),
.D2A_NIRS5_IPD_SW(D2A_NIRS5_IPD_SW),
.D2A_NIRS5_IIN_SW(D2A_NIRS5_IIN_SW),
.D2A_NIRS5_IPDMIRROR_ADJ(D2A_NIRS5_IPDMIRROR_ADJ),
.D2A_NIRS5_IREFC_ADJ(D2A_NIRS5_IREFC_ADJ[1:0]),
.D2A_NIRS5_CFRATE_ADJ(D2A_NIRS5_CFRATE_ADJ),
.D2A_NIRS5_IDAC(D2A_NIRS5_IDAC_ADJ),
.D2A_NIRS5_EN(D2A_NIRS5_EN),
.D2A_NIRS5_IDAC_EN(D2A_NIRS5_IDAC_EN),

.A2D_NIRS5_IREFCOARSE(A2D_NIRS5_IREFCOARSE), // SW2
.A2D_NIRS5_IREFFINE(A2D_NIRS5_IREFFINE),   // SW3

// NIRS 6
.D2A_NIRS6_RESET_SW(D2A_NIRS6_RESET_SW),
.D2A_NIRS6_IPD_SW(D2A_NIRS6_IPD_SW),
.D2A_NIRS6_IIN_SW(D2A_NIRS6_IIN_SW),
.D2A_NIRS6_IPDMIRROR_ADJ(D2A_NIRS6_IPDMIRROR_ADJ),
.D2A_NIRS6_IREFC_ADJ(D2A_NIRS6_IREFC_ADJ[1:0]),
.D2A_NIRS6_CFRATE_ADJ(D2A_NIRS6_CFRATE_ADJ),
.D2A_NIRS6_IDAC(D2A_NIRS6_IDAC_ADJ),
.D2A_NIRS6_EN(D2A_NIRS6_EN),
.D2A_NIRS6_IDAC_EN(D2A_NIRS6_IDAC_EN),

.A2D_NIRS6_IREFCOARSE(A2D_NIRS6_IREFCOARSE), // SW2
.A2D_NIRS6_IREFFINE(A2D_NIRS6_IREFFINE),   // SW3

// NIRS 7
.D2A_NIRS7_RESET_SW(D2A_NIRS7_RESET_SW),
.D2A_NIRS7_IPD_SW(D2A_NIRS7_IPD_SW),
.D2A_NIRS7_IIN_SW(D2A_NIRS7_IIN_SW),
.D2A_NIRS7_IPDMIRROR_ADJ(D2A_NIRS7_IPDMIRROR_ADJ),
.D2A_NIRS7_IREFC_ADJ(D2A_NIRS7_IREFC_ADJ[1:0]),
.D2A_NIRS7_CFRATE_ADJ(D2A_NIRS7_CFRATE_ADJ),
.D2A_NIRS7_IDAC(D2A_NIRS7_IDAC_ADJ),
.D2A_NIRS7_EN(D2A_NIRS7_EN),
.D2A_NIRS7_IDAC_EN(D2A_NIRS7_IDAC_EN),

.A2D_NIRS7_IREFCOARSE(A2D_NIRS7_IREFCOARSE), // SW2
.A2D_NIRS7_IREFFINE(A2D_NIRS7_IREFFINE),   // SW3

.PDBIAS_OUT(PDBIAS_OUT)
);
// End of this

 // --------------------------------------------------------------------------------
 // imeas analog
 // --------------------------------------------------------------------------------
`ifdef FPGA
 imeas_analog_0 #( 
`else
 imeas_analog #( 
`endif
 .file_adc0("../../../verification/models/analog/imeas/stimulus/dB0.dat"),
 .file_adc_noise("../../../verification/models/analog/imeas/stimulus/SDM_noise.dat")
 )
  u_imeas_analog_0(
  //.chnum(imeas_chnum),
  //.chnum({1'b0,D2A_SDM_VIN_SEL}),
        //.adc_clk(imeas_adc_clk),
        .adc_clk(D2A_SDMCLK),
        .nrst(A2D_POR),
        //.imeas_sd16off(imeas_sd16off),
        //.imeas_sd16slp(imeas_sd16slp),
        //.imeas_adc_in(imeas_adc_din)
        .imeas_adc_in(A2D_SDM0)
  );

`ifdef FPGA
 imeas_analog_1 #( 
`else
 imeas_analog #( 
`endif
 .file_adc0("../../../verification/models/analog/imeas/stimulus/dB1.dat"),
 .file_adc_noise("../../../verification/models/analog/imeas/stimulus/SDM_noise.dat")
 )
  u_imeas_analog_1(
        .adc_clk(D2A_SDMCLK),
        .nrst(A2D_POR),
        .imeas_adc_in(A2D_SDM1)
  );

`ifdef FPGA
 imeas_analog_2 #( 
`else
 imeas_analog #( 
`endif
 .file_adc0("../../../verification/models/analog/imeas/stimulus/dB2.dat"),
 .file_adc_noise("../../../verification/models/analog/imeas/stimulus/SDM_noise.dat")
 )
  u_imeas_analog_2(
        .adc_clk(D2A_SDMCLK),
        .nrst(A2D_POR),
        .imeas_adc_in(A2D_SDM2)
  );

`ifdef FPGA
 imeas_analog_3 #( 
`else
 imeas_analog #( 
`endif
 .file_adc0("../../../verification/models/analog/imeas/stimulus/dB3.dat"),
 .file_adc_noise("../../../verification/models/analog/imeas/stimulus/SDM_noise.dat")
 )
  u_imeas_analog_3(
        .adc_clk(D2A_SDMCLK),
        .nrst(A2D_POR),
        .imeas_adc_in(A2D_SDM3)
  );

`ifdef FPGA
 imeas_analog_4 #( 
`else
 imeas_analog #( 
`endif
 .file_adc0("../../../verification/models/analog/imeas/stimulus/dB4.dat"),
 .file_adc_noise("../../../verification/models/analog/imeas/stimulus/SDM_noise.dat")
 )
  u_imeas_analog_4(
        .adc_clk(D2A_SDMCLK),
        .nrst(A2D_POR),
        .imeas_adc_in(A2D_SDM4)
  );

`ifdef FPGA
 imeas_analog_5 #( 
`else
 imeas_analog #( 
`endif
 .file_adc0("../../../verification/models/analog/imeas/stimulus/dB5.dat"),
 .file_adc_noise("../../../verification/models/analog/imeas/stimulus/SDM_noise.dat")
 )
  u_imeas_analog_5(
        .adc_clk(D2A_SDMCLK),
        .nrst(A2D_POR),
        .imeas_adc_in(A2D_SDM5)
  );

`ifdef FPGA
 imeas_analog_6 #( 
`else
 imeas_analog #( 
`endif
 .file_adc0("../../../verification/models/analog/imeas/stimulus/dB6.dat"),
 .file_adc_noise("../../../verification/models/analog/imeas/stimulus/SDM_noise.dat")
 )
  u_imeas_analog_6(
        .adc_clk(D2A_SDMCLK),
        .nrst(A2D_POR),
        .imeas_adc_in(A2D_SDM6)
  );

`ifdef FPGA
 imeas_analog_7 #( 
`else
 imeas_analog #( 
`endif
 .file_adc0("../../../verification/models/analog/imeas/stimulus/dB7.dat"),
 .file_adc_noise("../../../verification/models/analog/imeas/stimulus/SDM_noise.dat")
 )
  u_imeas_analog_7(
        .adc_clk(D2A_SDMCLK),
        .nrst(A2D_POR),
        .imeas_adc_in(A2D_SDM7)
  );

`ifdef FPGA
 imeas_analog_8 #( 
`else
 imeas_analog #( 
`endif
 .file_adc0("../../../verification/models/analog/imeas/stimulus/dB8.dat"),
 .file_adc_noise("../../../verification/models/analog/imeas/stimulus/SDM_noise.dat")
 )
  u_imeas_analog_8(
        .adc_clk(D2A_SDMCLK),
        .nrst(A2D_POR),
        .imeas_adc_in(A2D_SDM8)
  );

`ifdef FPGA
 imeas_analog_9 #( 
`else
 imeas_analog #( 
`endif
 .file_adc0("../../../verification/models/analog/imeas/stimulus/dB10.dat"),
 .file_adc_noise("../../../verification/models/analog/imeas/stimulus/SDM_noise.dat")
 )
  u_imeas_analog_9(
        .adc_clk(D2A_SDMCLK),
        .nrst(A2D_POR),
        .imeas_adc_in(A2D_SDM9)
  );

`ifdef FPGA
 imeas_analog_10 #( 
`else
 imeas_analog #( 
`endif
 .file_adc0("../../../verification/models/analog/imeas/stimulus/dB20.dat"),
 .file_adc_noise("../../../verification/models/analog/imeas/stimulus/SDM_noise.dat")
 )
  u_imeas_analog_10(
        .adc_clk(D2A_SDMCLK),
        .nrst(A2D_POR),
        .imeas_adc_in(A2D_SDM10)
  );

`ifdef FPGA
 imeas_analog_11 #( 
`else
 imeas_analog #( 
`endif
 .file_adc0("../../../verification/models/analog/imeas/stimulus/dB30.dat"),
 .file_adc_noise("../../../verification/models/analog/imeas/stimulus/SDM_noise.dat")
 )
  u_imeas_analog_11(
        .adc_clk(D2A_SDMCLK),
        .nrst(A2D_POR),
        .imeas_adc_in(A2D_SDM11)
  );

`ifdef FPGA
 imeas_analog_12 #( 
`else
 imeas_analog #( 
`endif
 .file_adc0("../../../verification/models/analog/imeas/stimulus/dB40.dat"),
 .file_adc_noise("../../../verification/models/analog/imeas/stimulus/SDM_noise.dat")
 )
  u_imeas_analog_12(
        .adc_clk(D2A_SDMCLK),
        .nrst(A2D_POR),
        .imeas_adc_in(A2D_SDM12)
  );

`ifdef FPGA
 imeas_analog_13 #( 
`else
 imeas_analog #( 
`endif
 .file_adc0("../../../verification/models/analog/imeas/stimulus/dB50.dat"),
 .file_adc_noise("../../../verification/models/analog/imeas/stimulus/SDM_noise.dat")
 )
  u_imeas_analog_13(
        .adc_clk(D2A_SDMCLK),
        .nrst(A2D_POR),
        .imeas_adc_in(A2D_SDM13)
  );

`ifdef FPGA
 imeas_analog_14 #( 
`else
 imeas_analog #( 
`endif
 .file_adc0("../../../verification/models/analog/imeas/stimulus/dB60.dat"),
 .file_adc_noise("../../../verification/models/analog/imeas/stimulus/SDM_noise.dat")
 )
  u_imeas_analog_14(
        .adc_clk(D2A_SDMCLK),
        .nrst(A2D_POR),
        .imeas_adc_in(A2D_SDM14)
  );

`ifdef FPGA
 imeas_analog_15 #( 
`else
 imeas_analog #( 
`endif
 .file_adc0("../../../verification/models/analog/imeas/stimulus/dB70.dat"),
 .file_adc_noise("../../../verification/models/analog/imeas/stimulus/SDM_noise.dat")
 )
  u_imeas_analog_15(
        .adc_clk(D2A_SDMCLK),
        .nrst(A2D_POR),
        .imeas_adc_in(A2D_SDM15)
  );

// --------------------------------------------------------------------------------
// External HF_CLK
// --------------------------------------------------------------------------------
`ifdef FPGA
`else
/*
  ext_hfosc u_ext_hfsoc (
    .ext_hfclk                 (A2D_external_clock_I),
    .ext_hfclk_sel             (A2D_external_en_I)
  );
*/
`endif
`endif
`endif

`endif // MIX_SIM_EN
endmodule
