//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap ENS2  
// Module Name : ENS2_ANA_CHIP_wrapper  
// Description : 
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Design
//------------------------------------------------------------------------------
// 0.1                                  Initial Rev
//------------------------------------------------------------------------------

// Library - YJT_GC2, Cell - ENS2, View - schematic
// LAST TIME SAVED: Oct 26 16:29:17 2022
// NETLIST TIME: Oct 26 16:31:54 2022
`timescale 1ns / 1ns 

module ENS2_ANA_CHIP_wrapper #(
  parameter EN_SEC_NUMBER       = 2,
  parameter EN_REG_NUMBER       = 15,
  parameter A2D_REG_NUMBER      = 8,
  parameter GEN_SEC_NUMBER      = 8,
  parameter GEN_REG_NUMBER      = 15
) ( 

//temprily connected for verification
output wire [9:0] A2D_ADC_DATA, //from analog //ADC use posedge of sysclk to output data, 
		//digital use negedge to capture, so we have half sysclk cycle margin for it	
output wire  A2D_ADC_DATA_EN,//from analog	
input wire[3:0] D2A_STIM_PAD0,    //to analog	
input wire[3:0] D2A_STIM_PAD1,    //to analog
input wire[3:0] D2A_ADC_DELAY,
input wire[1:0] D2A_ADBUF_GSEL,
	
input wire D2A_ADC_EN,    //to analog	
input wire D2A_ADC_CLK,    //to analog	
input wire ina_pga_ana_clk,

`ifdef FPGA
  input clk_in1;
`endif
  input atpg_en,


//bps imeas
output wire  A2D_SDM_OUT0,
output wire  A2D_SDM_OUT1,
output wire  A2D_SDM_OUT2,
output wire  A2D_SDM_OUT3,
output wire  A2D_SDM_OUT4,
output wire  A2D_SDM_OUT5,
output wire  A2D_SDM_OUT6,
output wire  A2D_SDM_OUT7,
output wire  A2D_SDM_OUT8,
output wire  A2D_SDM_OUT9,
output wire  A2D_SDM_OUT10,
output wire  A2D_SDM_OUT11,
output wire  A2D_SDM_OUT12,
output wire  A2D_SDM_OUT13,
output wire  A2D_SDM_OUT14,
output wire  A2D_SDM_OUT15,
input  wire  D2A_SDM_CLK,

  // CURRENT
  output  A2D_CLK8MHZ,
  output  A2D_POR,
  inout   VDDIO,
  inout   VDD_DIG,
  inout   VSS_DIG,
  inout   VSSIO,
  //inout   AVDD,

  pinmux_if.A2D   pinmux_if,
  spi_ana_if.ana  spi_ana_if,
  ana_nirs_if.ana ana_nirs_if,

  //WG
  input wire [11:0] i_out_wave_driver_idac[15:0], //
  input wire [15:0] i_ds_driver_en_driver,
//input wire 	      i_ds_driver_en_current, //
  input wire [15:0] i_driver_en_sw, // 
//input wire 	      i_stimu_en,    //        

  input      [15:0] i_source_driver, //
//input      [15:0] i_sourceb_driver_a,
  input      [15:0] i_pulldn_driver //
//input      [15:0] i_pulldb_driver_a
);

wire  [7:0] A2D_ANA_GEN_REG_0;
wire  [7:0] A2D_ANA_GEN_REG_1;
wire  [7:0] A2D_ANA_GEN_REG_2;
wire  [7:0] A2D_ANA_GEN_REG_3;
wire  [7:0] A2D_ANA_GEN_REG_4;

wire  [7:0] A2D_SPARE_RO_REG_0;
wire  [7:0] A2D_SPARE_RO_REG_0_tmp;
wire        A2D_TSC_COMP_OUT_CH1_tmp;

wire  [7:0] D2A_TRIM0_SIG_SPARE;
wire  [7:0] D2A_TRIM1_SIG_SPARE;
wire  [7:0] D2A_TRIM2_SIG_SPARE;
wire  [7:0] D2A_TRIM3_SIG_SPARE;
wire  [7:0] D2A_TRIM4_SIG_SPARE;
wire  [7:0] D2A_TRIM5_SIG_SPARE;
wire  [7:0] D2A_TRIM6_SIG_SPARE;
wire  [7:0] D2A_TRIM7_SIG_SPARE;
wire  [7:0] D2A_TRIM0_SIG;
wire  [7:0] D2A_TRIM1_SIG;
wire  [7:0] D2A_TRIM2_SIG;
wire  [7:0] D2A_TRIM3_SIG;
wire  [7:0] D2A_TRIM4_SIG;
wire  [7:0] D2A_TRIM5_SIG;
wire  [7:0] D2A_TRIM6_SIG;
//wire  [7:0] D2A_ADJ0_IO;
wire  [7:0] D2A_ADJ0_14_IO;
//wire  [7:0] D2A_ADJ1_IO;
//wire  [7:0] D2A_ADJ2_IO;
wire  [7:0] D2A_ADJ1_2_IO;
//wire  [7:0] D2A_ADJ3_IO;
//wire  [7:0] D2A_ADJ4_IO;
//wire  [7:0] D2A_ADJ5_IO;
//wire  [7:0] D2A_ADJ6_IO;
//wire  [7:0] D2A_ADJ7_IO;
wire  [7:0] D2A_ADJ6_7_IO;
//wire  [7:0] D2A_ADJ8_IO;
//wire  [7:0] D2A_ADJ9_IO;
wire  [7:0] D2A_ADJ8_9_IO;
wire  [7:0] D2A_ADJ10_IO;
wire  [7:0] D2A_ADJ11_IO;
wire  [7:0] D2A_ADJ12_IO;
wire  [7:0] D2A_ADJ13_IO;
//wire  [7:0] D2A_ADJ14_IO;
wire  [7:0] DC_LOFF_SEL;
wire  [7:0] NIRS_IREF_SEL;
wire  [7:0] EEGLNA8_SEL;
wire  [7:0] PGALNA8_SEL;
wire  [7:0] SDMVCMBUFF_SEL;


//PMU
wire  [7:0] D2A_BG_TRIM;
wire  [7:0] D2A_BGBUFFER_TRIM;
wire  [7:0] D2A_IREF_TRIM;
wire  [7:0] D2A_CLDO1P8_TRIM;
wire        D2A_BGBUFFER_CPTEST_EN;
wire        D2A_LVD_EN;
wire  [2:0] D2A_LVD_SEL;
wire        A2D_LVD; 
wire        A2D_TSC_COMP_OUT;
wire  [7:0] D2A_OSC8MHZ_TRIM;
wire        D2A_EN_TSC; 
wire        D2A_OSC8MHZEN;
wire  [7:0] D2A_TSC_TRIM;
wire  [7:0] D2A_VDAC8B_DIN;



//BIST
wire        D2A_BIST_EN;
wire  [4:0] D2A_BIST_SEL;

//DC LEAD OFF
wire [15:0] D2A_DCLOFFEN;
wire  [2:0] D2A_LOFF_COMP_TH;
wire  [3:0] D2A_LOFF_ISEL_ADJ;
wire        D2A_LOFF_IPOL;
wire [15:0] A2D_LOFF_STATP;
wire [15:0] A2D_LOFF_STATN;

//RECORDING
wire        D2A_BIAS_MEAS;           
wire        D2A_BIASREF_INT;         
wire [15:0] D2A_EEGLNA_EN;      
wire [15:0] D2A_QSTRLNA_EN;
wire [15:0] D2A_EEGPGA_EN; 
wire [15:0] D2A_QSTRPGA_EN;          
//wire        D2A_VCMGENBUFF_EN;   
wire        D2A_SDMVCMBUFF_EN; 
wire [7:0]  D2A_VCMGENBUFF_IADJ;
wire [1:0]  D2A_SDMVCMBUFF_IADJ;
wire [5:0]  D2A_SDMVCMBUFF_SEL;
wire        D2A_RLD_EN;      
wire        D2A_RLD_ELECTRODE_EN;  
//wire [15:0] D2A_SDMBUFF_EN;                  
wire        D2A_SDMVREFPBUFF_EN; 
wire [1:0]  D2A_SDMVREFP_IADJ;
wire [5:0]  D2A_SDMVREFP_SEL; 
wire [7:0]  D2A_RLD_IADJ; 

wire [2:0]  D2A_EEG_CH0_SET;
wire [2:0]  D2A_EEG_CH1_SET;
wire [2:0]  D2A_EEG_CH2_SET;
wire [2:0]  D2A_EEG_CH3_SET;
wire [2:0]  D2A_EEG_CH4_SET;
wire [2:0]  D2A_EEG_CH5_SET;
wire [2:0]  D2A_EEG_CH6_SET;
wire [2:0]  D2A_EEG_CH7_SET;
wire [2:0]  D2A_EEG_CH8_SET;
wire [2:0]  D2A_EEG_CH9_SET;
wire [2:0]  D2A_EEG_CH10_SET;
wire [2:0]  D2A_EEG_CH11_SET;
wire [2:0]  D2A_EEG_CH12_SET;
wire [2:0]  D2A_EEG_CH13_SET;
wire [2:0]  D2A_EEG_CH14_SET;
wire [2:0]  D2A_EEG_CH15_SET;
wire           D2A_INA_CLK;
wire [3:0]  D2A_GAIN_PGA_CH0_ADJ;
wire [3:0]  D2A_GAIN_PGA_CH1_ADJ;
wire [3:0]  D2A_GAIN_PGA_CH2_ADJ;
wire [3:0]  D2A_GAIN_PGA_CH3_ADJ;
wire [3:0]  D2A_GAIN_PGA_CH4_ADJ;
wire [3:0]  D2A_GAIN_PGA_CH5_ADJ;
wire [3:0]  D2A_GAIN_PGA_CH6_ADJ;
wire [3:0]  D2A_GAIN_PGA_CH7_ADJ;
wire [3:0]  D2A_GAIN_PGA_CH8_ADJ;
wire [3:0]  D2A_GAIN_PGA_CH9_ADJ;
wire [3:0]  D2A_GAIN_PGA_CH10_ADJ;
wire [3:0]  D2A_GAIN_PGA_CH11_ADJ;
wire [3:0]  D2A_GAIN_PGA_CH12_ADJ;
wire [3:0]  D2A_GAIN_PGA_CH13_ADJ;
wire [3:0]  D2A_GAIN_PGA_CH14_ADJ;
wire [3:0]  D2A_GAIN_PGA_CH15_ADJ;
wire [2:0]  D2A_GAIN_DDA_CH0_ADJ;
wire [2:0]  D2A_GAIN_DDA_CH1_ADJ;
wire [2:0]  D2A_GAIN_DDA_CH2_ADJ;
wire [2:0]  D2A_GAIN_DDA_CH3_ADJ;
wire [2:0]  D2A_GAIN_DDA_CH4_ADJ;
wire [2:0]  D2A_GAIN_DDA_CH5_ADJ;
wire [2:0]  D2A_GAIN_DDA_CH6_ADJ;
wire [2:0]  D2A_GAIN_DDA_CH7_ADJ;
wire [2:0]  D2A_GAIN_DDA_CH8_ADJ;
wire [2:0]  D2A_GAIN_DDA_CH9_ADJ;
wire [2:0]  D2A_GAIN_DDA_CH10_ADJ;
wire [2:0]  D2A_GAIN_DDA_CH11_ADJ;
wire [2:0]  D2A_GAIN_DDA_CH12_ADJ;
wire [2:0]  D2A_GAIN_DDA_CH13_ADJ;
wire [2:0]  D2A_GAIN_DDA_CH14_ADJ;
wire [2:0]  D2A_GAIN_DDA_CH15_ADJ;
wire        D2A_INADC_ADJ;
wire [15:0]  D2A_PGAEN;
wire [15:0]  D2A_PGA_ENCH;
wire [2:0]   D2A_PGA_IADJ;
wire [15:0]  D2A_RLDEN_INA;
wire [15:0]  D2A_DDAEN;
wire [2:0]   D2A_DDA_IADJ;
wire         D2A_EEG_EN;
wire         D2A_VCM_INA_ADJ;
wire         D2A_VCM_INAEN;
wire [1:0]  D2A_SDMVCMBUFF_ADJ;
wire [1:0]  D2A_SDMVREFP_ADJ;


//STIMULATOR
wire [11:0]  D2A_DATA_0;
wire [11:0]  D2A_DATA_1;  
wire [11:0]  D2A_DATA_2;
wire [11:0]  D2A_DATA_3;
wire [11:0]  D2A_DATA_4;
wire [11:0]  D2A_DATA_5;
wire [11:0]  D2A_DATA_6;
wire [11:0]  D2A_DATA_7;
wire [11:0]  D2A_DATA_8;
wire [11:0]  D2A_DATA_9;
wire [11:0]  D2A_DATA_10;
wire [11:0]  D2A_DATA_11;
wire [11:0]  D2A_DATA_12;
wire [11:0]  D2A_DATA_13;
wire [11:0]  D2A_DATA_14;
wire [11:0]  D2A_DATA_15;
wire [15:0]  D2A_CBUF_EN;
wire [15:0]  D2A_IDAC_EN;
wire         D2A_DRIVER_CUR_EN;
wire  [7:0]  D2A_DRIVER_CUR_TRIM;
wire [15:0]  D2A_PULLD;
wire [15:0]  D2A_SOURCE;

wire [15:0]  D2A_SDMEN;
wire         D2A_STIMU_EN;
wire [7:0]  D2A_SPI_SPARE0;
wire [7:0]  D2A_SPI_SPARE1;
wire [7:0]  D2A_SPI_SPARE2;
wire [7:0]  D2A_SPI_SPARE3;
wire [7:0]  D2A_SPI_SPARE4;
wire [7:0]  D2A_SPI_SPARE5;
wire [7:0]  D2A_SPI_SPARE6;
wire [7:0]  D2A_SPI_SPARE7;


wire        D2A_SDM_TEST;
wire        D2A_NIRS4_EN;
//wire        D2A_NIRS_TEST_EN;
wire        D2A_NIRS4_IDAC_EN;
wire [1:0]  D2A_NIRS4_IREFC_ADJ;
wire [5:0]  D2A_NIRS4_CFRATE_ADJ;
wire [7:0]  D2A_NIRS4_IDAC_ADJ;

//DRIVERA_CH1

//wire        D2A_DRIVERA_CSAMP_EN_CH1;
//wire        D2A_COMP_EN_CH1;
//wire        D2A_IDAC_EN_CH1;
//wire        D2A_VDAC_EN_CH1;
//wire [11:0] D2A_VDAC_DIN_CH1;
//wire        D2A_STIMU_COMP_SEL_CH1; 
//wire        D2A_STIMU_COMP_EN_CH1; 
//wire  [2:0] D2A_CS_TRIM_CH1;
//wire        D2A_LEAD_OFF_SEL_SA_SB_CH1;

// WG_CH1
//wire        D2A_DRIVERA_SOURCEA_CH1;
//wire        D2A_DRIVERA_SOURCEB_CH1;
//wire        D2A_DRIVERA_PULLDA_CH1;
//wire        D2A_DRIVERA_PULLDB_CH1;
//wire [11:0] D2A_IDAC_DIN_CH1;

//PUMP_CH1
//wire        D2A_PUMP_CLK_TRIM_CH1;
//wire        D2A_PUMP_5V_EN_CH1;
//wire        D2A_PUMP_LDO_EN_CH1;
//wire  [1:0] D2A_LDO2P8_PUMP_TRIM_CH1;
//wire        D2A_LDO1P8_LDO2P8_CH1_SEL;

//DRIVERA_CH2
//wire  [2:0] D2A_VDAC_VTRIM_CH2;
//wire        D2A_CS_EN_CH_CH2;
//wire        D2A_DRIVERA_CSAMP_EN_CH2;
//wire        D2A_COMP_EN_CH2;
//wire        D2A_IDAC_EN_CH2;
//wire        D2A_VDAC_EN_CH2;
//wire [11:0] D2A_VDAC_DIN_CH2;
//wire        D2A_STIMU_COMP_SEL_CH2; 
//wire        D2A_STIMU_COMP_EN_CH2; 
//wire  [2:0] D2A_CS_TRIM_CH2;
//wire        D2A_LEAD_OFF_SEL_SA_SB_CH2;

//WG_CH2
//wire        D2A_DRIVERA_SOURCEA_CH2;
//wire        D2A_DRIVERA_SOURCEB_CH2;
//wire        D2A_DRIVERA_PULLDA_CH2;
//wire        D2A_DRIVERA_PULLDB_CH2;
//wire [11:0] D2A_IDAC_DIN_CH2;

wire [7:0] ANA_ENABLE_REG   [EN_SEC_NUMBER-1:0][EN_REG_NUMBER-1:0];
wire [7:0] ANA_GEN_REG      [GEN_SEC_NUMBER-1:0][GEN_REG_NUMBER-1:0];
wire [7:0] A2D_ANA_GEN_REG  [A2D_REG_NUMBER-1:0];


//assign A2D_ANA_GEN_REG_0    = atpg_en ? 8'b0 : {4'b0, A2D_TSC_COMP_OUT_CH1, A2D_COMP_OUT_STIMU2_3, A2D_COMP_OUT_STIMU0_1, A2D_LVD};
assign A2D_ANA_GEN_REG_0     = atpg_en ? 8'b0 : {6'b0, A2D_TSC_COMP_OUT, A2D_LVD};
assign A2D_ANA_GEN_REG_1     = atpg_en ? 8'b0 : A2D_LOFF_STATP[7:0];
assign A2D_ANA_GEN_REG_2     = atpg_en ? 8'b0 : A2D_LOFF_STATP[15:8];
assign A2D_ANA_GEN_REG_3     = atpg_en ? 8'b0 : A2D_LOFF_STATN[7:0];
assign A2D_ANA_GEN_REG_4     = atpg_en ? 8'b0 : A2D_LOFF_STATN[15:8];
assign A2D_SPARE_RO_REG_0    = atpg_en ? 8'b0 : A2D_SPARE_RO_REG_0_tmp;
assign A2D_TSC_COMP_OUT      = atpg_en ? 1'b0 : A2D_TSC_COMP_OUT_CH1_tmp; 

assign D2A_TRIM0_SIG  = pinmux_if.D2A_TRIM_SIG[0];
assign D2A_TRIM1_SIG  = pinmux_if.D2A_TRIM_SIG[1];
assign D2A_TRIM2_SIG  = pinmux_if.D2A_TRIM_SIG[2];
assign D2A_TRIM3_SIG  = pinmux_if.D2A_TRIM_SIG[3];
assign D2A_TRIM4_SIG  = pinmux_if.D2A_TRIM_SIG[4];
assign D2A_TRIM5_SIG  = pinmux_if.D2A_TRIM_SIG[5];
assign D2A_TRIM6_SIG  = pinmux_if.D2A_TRIM_SIG[6];

assign D2A_TRIM0_SIG_SPARE = pinmux_if.D2A_TRIM_SIG[7];
assign D2A_TRIM1_SIG_SPARE = pinmux_if.D2A_TRIM_SIG[8];
assign D2A_TRIM2_SIG_SPARE = pinmux_if.D2A_TRIM_SIG[9];
assign D2A_TRIM3_SIG_SPARE = pinmux_if.D2A_TRIM_SIG[10];
assign D2A_TRIM4_SIG_SPARE = pinmux_if.D2A_TRIM_SIG[11];
assign D2A_TRIM5_SIG_SPARE = pinmux_if.D2A_TRIM_SIG[12];
assign D2A_TRIM6_SIG_SPARE = pinmux_if.D2A_TRIM_SIG[13];
assign D2A_TRIM7_SIG_SPARE = pinmux_if.D2A_TRIM_SIG[14];


assign D2A_ADJ0_14_IO = pinmux_if.D2A_ATM[15] ?  pinmux_if.D2A_ADJ_IO[0]  : (pinmux_if.D2A_ATM[29] ?  pinmux_if.D2A_ADJ_IO[14] : ANA_GEN_REG[0][14]);
assign D2A_ADJ1_2_IO  = pinmux_if.D2A_ATM[16] ?  pinmux_if.D2A_ADJ_IO[1]  : (pinmux_if.D2A_ATM[17] ?  pinmux_if.D2A_ADJ_IO[2] : ANA_GEN_REG[1][14]);

//assign D2A_ADJ3_IO   = pinmux_if.D2A_ADJ_IO[3];//NIRS
//assign D2A_ADJ4_IO   = pinmux_if.D2A_ADJ_IO[4];//NIRS
//assign D2A_ADJ5_IO   = pinmux_if.D2A_ADJ_IO[5];//NIRS
assign D2A_ADJ6_7_IO = pinmux_if.D2A_ATM[21] ?  pinmux_if.D2A_ADJ_IO[6] :  (pinmux_if.D2A_ATM[22] ?  pinmux_if.D2A_ADJ_IO[7] : ANA_GEN_REG[2][14]);

assign D2A_ADJ8_9_IO = pinmux_if.D2A_ATM[23] ?  pinmux_if.D2A_ADJ_IO[8]  : (pinmux_if.D2A_ATM[24] ?  pinmux_if.D2A_ADJ_IO[9] : ANA_GEN_REG[3][14]);

assign D2A_ADJ10_IO  = pinmux_if.D2A_ATM[25] ?  pinmux_if.D2A_ADJ_IO[10]  : ANA_GEN_REG[4][14];
assign D2A_ADJ11_IO  = pinmux_if.D2A_ATM[26] ?  pinmux_if.D2A_ADJ_IO[11]  : ANA_GEN_REG[5][14];
assign D2A_ADJ12_IO  = pinmux_if.D2A_ATM[27] ?  pinmux_if.D2A_ADJ_IO[12]  : ANA_GEN_REG[6][14];
assign D2A_ADJ13_IO  = pinmux_if.D2A_ATM[28] ?  pinmux_if.D2A_ADJ_IO[13]  : ANA_GEN_REG[7][14];

assign ANA_ENABLE_REG = pinmux_if.D2A_ANA_ENABLE_REG;
assign ANA_GEN_REG    = spi_ana_if.D2A_ANA_GEN_REG;
assign spi_ana_if.A2D_ANA_GEN_REG[0] = A2D_ANA_GEN_REG_0;
assign spi_ana_if.A2D_ANA_GEN_REG[1] = A2D_ANA_GEN_REG_1;
assign spi_ana_if.A2D_ANA_GEN_REG[2] = A2D_ANA_GEN_REG_2;
assign spi_ana_if.A2D_ANA_GEN_REG[3] = A2D_ANA_GEN_REG_3;
assign spi_ana_if.A2D_ANA_GEN_REG[4] = A2D_ANA_GEN_REG_4;
assign spi_ana_if.A2D_ANA_GEN_REG[5] = A2D_SPARE_RO_REG_0;

//ADJ//

                                                                     
assign D2A_LOFF_COMP_TH          = D2A_ADJ1_2_IO[2:0];//D2A_ADJ1_IO //D2A_ADJ2_IO
assign D2A_LOFF_IPOL				     = D2A_ADJ1_2_IO[3];
assign D2A_LOFF_ISEL_ADJ         = D2A_ADJ1_2_IO[7:4];

//LNA 
//assign D2A_EEGLNA8_GAIN          = D2A_ADJ6_7_IO[5:0];//D2A_ADJ6_IO //D2A_ADJ7_IO
//assign D2A_EEGLNA8_IADJ          = D2A_ADJ6_7_IO[7:6];

//PGA
//assign D2A_EEGPGA8A_GAIN         = D2A_ADJ8_9_IO[2:0];//D2A_ADJ8_IO //D2A_ADJ9_IO
//assign D2A_EEGPGA8B_GAIN         = D2A_ADJ8_9_IO[7:3];

//VCMGEN (PAD)
//assign D2A_VCMGENBUFF_IADJ       = D2A_ADJ10_IO;//D2A_ADJ10_IO

//SDMVCMBUFF (PAD))
assign D2A_SDMVCMBUFF_IADJ      = D2A_ADJ11_IO[1:0];//D2A_ADJ11_IO
//assign D2A_SDMVCMBUFF_SEL       = D2A_ADJ11_IO[7:2];

//VREFP (PAD)
assign D2A_SDMVREFP_IADJ        = D2A_ADJ12_IO[1:0];//D2A_ADJ12_IO
//assign D2A_SDMVREFP_SEL         = D2A_ADJ12_IO[7:2];

//RLD (PAD)
assign D2A_RLD_IADJ             = D2A_ADJ13_IO;//D2A_ADJ13_IO


//PMU
assign D2A_BG_TRIM            	 = D2A_TRIM0_SIG;
assign D2A_BGBUFFER_TRIM  	     = D2A_TRIM1_SIG;
assign D2A_IREF_TRIM             = D2A_TRIM2_SIG;
assign D2A_BGBUFFER_CPTEST_EN    = ANA_ENABLE_REG[0][1][0]; 
assign D2A_CLDO1P8_TRIM          = D2A_TRIM3_SIG;
assign D2A_LVD_EN                = ANA_ENABLE_REG[0][3][0];
assign D2A_LVD_SEL               = ANA_GEN_REG[0][0][2:0];   

//OSC
assign D2A_OSC8MHZ_TRIM          = D2A_TRIM4_SIG;
assign D2A_OSC8MHZEN	           = ANA_ENABLE_REG[0][1][1];

//TSC
assign D2A_TSC_TRIM              = D2A_TRIM5_SIG;
assign D2A_VDAC8B_DIN            = pinmux_if.debug_mode_en ? D2A_ADJ0_14_IO : pinmux_if.d2a_tsc_vdac8b_din_ch1;
assign D2A_EN_TSC                = pinmux_if.d2a_tsc_en_ch1;

//BIST
assign D2A_BIST_EN               = ANA_ENABLE_REG[0][0][0];
assign D2A_BIST_SEL              = ANA_ENABLE_REG[0][0][5:1];

//LEAD OFF
assign D2A_DCLOFFEN              = {ANA_ENABLE_REG[1][1],ANA_ENABLE_REG[1][0]}; 

//RECORDING
assign D2A_BIAS_MEAS             = ANA_ENABLE_REG[0][3][1];
assign D2A_BIASREF_INT           = ANA_GEN_REG[0][0][3];  
//assign D2A_EEGLNA_EN             = {ANA_ENABLE_REG[0][5],ANA_ENABLE_REG[0][4]}; 
//assign D2A_QSTRLNA_EN            = {ANA_ENABLE_REG[0][7],ANA_ENABLE_REG[0][6]};  
//assign D2A_EEGPGA_EN             = {ANA_ENABLE_REG[0][9],ANA_ENABLE_REG[0][8]}; 
//assign D2A_QSTRPGA_EN            = {ANA_ENABLE_REG[0][11],ANA_ENABLE_REG[0][10]}; 
//assign D2A_VCMGENBUFF_EN         = ANA_ENABLE_REG[0][2][1];
assign D2A_SDMVCMBUFF_EN         = ANA_ENABLE_REG[0][2][2];
assign D2A_SDMVREFPBUFF_EN       = ANA_ENABLE_REG[0][2][3];
assign D2A_RLD_EN                = ANA_ENABLE_REG[0][3][2];
assign D2A_RLD_ELECTRODE_EN      = ANA_ENABLE_REG[0][2][0];


assign D2A_EEG_CH0_SET           = ANA_GEN_REG[0][1][2:0];
assign D2A_EEG_CH1_SET           = ANA_GEN_REG[0][1][5:3];
assign D2A_EEG_CH2_SET           = ANA_GEN_REG[0][2][2:0];
assign D2A_EEG_CH3_SET           = ANA_GEN_REG[0][2][5:3];
assign D2A_EEG_CH4_SET           = ANA_GEN_REG[0][3][2:0];
assign D2A_EEG_CH5_SET           = ANA_GEN_REG[0][3][5:3];
assign D2A_EEG_CH6_SET           = ANA_GEN_REG[0][4][2:0];
assign D2A_EEG_CH7_SET           = ANA_GEN_REG[0][4][5:3];
assign D2A_EEG_CH8_SET           = ANA_GEN_REG[0][5][2:0];
assign D2A_EEG_CH9_SET           = ANA_GEN_REG[0][5][5:3];
assign D2A_EEG_CH10_SET          = ANA_GEN_REG[0][6][2:0];
assign D2A_EEG_CH11_SET          = ANA_GEN_REG[0][6][5:3];
assign D2A_EEG_CH12_SET          = ANA_GEN_REG[0][7][2:0];
assign D2A_EEG_CH13_SET          = ANA_GEN_REG[0][7][5:3];
assign D2A_EEG_CH14_SET          = ANA_GEN_REG[0][8][2:0];
assign D2A_EEG_CH15_SET          = ANA_GEN_REG[0][8][5:3];


assign D2A_GAIN_PGA_CH0_ADJ      = ANA_GEN_REG[0][9][3:0];
assign D2A_GAIN_PGA_CH1_ADJ      = ANA_GEN_REG[0][9][7:4];
assign D2A_GAIN_PGA_CH2_ADJ      = ANA_GEN_REG[0][10][3:0];
assign D2A_GAIN_PGA_CH3_ADJ      = ANA_GEN_REG[0][10][7:4];
assign D2A_GAIN_PGA_CH4_ADJ      = ANA_GEN_REG[0][11][3:0];
assign D2A_GAIN_PGA_CH5_ADJ      = ANA_GEN_REG[0][11][7:4];
assign D2A_GAIN_PGA_CH6_ADJ      = ANA_GEN_REG[0][12][3:0];
assign D2A_GAIN_PGA_CH7_ADJ      = ANA_GEN_REG[0][12][7:4];
assign D2A_GAIN_PGA_CH8_ADJ      = ANA_GEN_REG[1][0][3:0];
assign D2A_GAIN_PGA_CH9_ADJ      = ANA_GEN_REG[1][0][7:4];
assign D2A_GAIN_PGA_CH10_ADJ     = ANA_GEN_REG[1][1][3:0];
assign D2A_GAIN_PGA_CH11_ADJ     = ANA_GEN_REG[1][1][7:4];
assign D2A_GAIN_PGA_CH12_ADJ     = ANA_GEN_REG[1][2][3:0];
assign D2A_GAIN_PGA_CH13_ADJ     = ANA_GEN_REG[1][2][7:4];
assign D2A_GAIN_PGA_CH14_ADJ     = ANA_GEN_REG[1][3][3:0];
assign D2A_GAIN_PGA_CH15_ADJ     = ANA_GEN_REG[1][3][7:4];

assign D2A_GAIN_DDA_CH0_ADJ      = ANA_GEN_REG[1][4][2:0];
assign D2A_GAIN_DDA_CH1_ADJ      = ANA_GEN_REG[1][4][5:3];
assign D2A_GAIN_DDA_CH2_ADJ      = ANA_GEN_REG[1][5][2:0];
assign D2A_GAIN_DDA_CH3_ADJ      = ANA_GEN_REG[1][5][5:3];
assign D2A_GAIN_DDA_CH4_ADJ      = ANA_GEN_REG[1][6][2:0];
assign D2A_GAIN_DDA_CH5_ADJ      = ANA_GEN_REG[1][6][5:3];
assign D2A_GAIN_DDA_CH6_ADJ      = ANA_GEN_REG[1][7][2:0];
assign D2A_GAIN_DDA_CH7_ADJ      = ANA_GEN_REG[1][7][5:3];
assign D2A_GAIN_DDA_CH8_ADJ      = ANA_GEN_REG[1][8][2:0];
assign D2A_GAIN_DDA_CH9_ADJ      = ANA_GEN_REG[1][8][5:3];
assign D2A_GAIN_DDA_CH10_ADJ     = ANA_GEN_REG[1][9][2:0];
assign D2A_GAIN_DDA_CH11_ADJ     = ANA_GEN_REG[1][9][5:3];
assign D2A_GAIN_DDA_CH12_ADJ     = ANA_GEN_REG[1][10][2:0];
assign D2A_GAIN_DDA_CH13_ADJ     = ANA_GEN_REG[1][10][5:3];
assign D2A_GAIN_DDA_CH14_ADJ     = ANA_GEN_REG[1][11][2:0];
assign D2A_GAIN_DDA_CH15_ADJ     = ANA_GEN_REG[1][11][5:3];

assign D2A_INADC_ADJ             = ANA_GEN_REG[1][11][6];
assign D2A_PGAEN                 = {ANA_ENABLE_REG[0][5],ANA_ENABLE_REG[0][4]}; 
assign D2A_PGA_ENCH              = {ANA_ENABLE_REG[0][7],ANA_ENABLE_REG[0][6]}; 
assign D2A_PGA_IADJ              = ANA_GEN_REG[1][12][2:0];
assign D2A_RLDEN_INA             = {ANA_ENABLE_REG[0][9],ANA_ENABLE_REG[0][8]}; 
assign D2A_DDAEN                 = {ANA_ENABLE_REG[0][11],ANA_ENABLE_REG[0][10]}; 
assign D2A_DDA_IADJ              = ANA_GEN_REG[1][12][5:3];
assign D2A_EEG_EN                = ANA_ENABLE_REG[0][12][0];
assign D2A_VCM_INAEN             = ANA_ENABLE_REG[0][12][1];
assign D2A_VCM_INA_ADJ           = ANA_GEN_REG[1][12][6];
assign D2A_SDMVCMBUFF_ADJ        = ANA_GEN_REG[2][0][1:0];
assign D2A_SDMVREFP_ADJ          = ANA_GEN_REG[2][0][3:2];

//STIMULATOR
assign D2A_DATA_0            =  i_out_wave_driver_idac[0];   // {ANA_GEN_REG[4][8][3:0],ANA_GEN_REG[4][7]};
assign D2A_DATA_1            =  i_out_wave_driver_idac[1];   // {ANA_GEN_REG[4][9],ANA_GEN_REG[4][8][7:4]};  
assign D2A_DATA_2            =  i_out_wave_driver_idac[2];   // {ANA_GEN_REG[4][11][3:0],ANA_GEN_REG[4][10]};
assign D2A_DATA_3            =  i_out_wave_driver_idac[3];   // {ANA_GEN_REG[4][12],ANA_GEN_REG[4][11][7:4]};
assign D2A_DATA_4            =  i_out_wave_driver_idac[4];   // {ANA_GEN_REG[5][1][3:0],ANA_GEN_REG[5][0]};
assign D2A_DATA_5            =  i_out_wave_driver_idac[5];   // {ANA_GEN_REG[5][2],ANA_GEN_REG[5][1][7:4]};
assign D2A_DATA_6            =  i_out_wave_driver_idac[6];   // {ANA_GEN_REG[5][4][3:0],ANA_GEN_REG[5][3]};
assign D2A_DATA_7            =  i_out_wave_driver_idac[7];   // {ANA_GEN_REG[5][5],ANA_GEN_REG[5][4][7:4]};
assign D2A_DATA_8            =  i_out_wave_driver_idac[8];   // {ANA_GEN_REG[5][7][3:0],ANA_GEN_REG[5][6]};
assign D2A_DATA_9            =  i_out_wave_driver_idac[9];   // {ANA_GEN_REG[5][8],ANA_GEN_REG[5][7][7:4]};
assign D2A_DATA_10           =  i_out_wave_driver_idac[10];   // {ANA_GEN_REG[5][10][3:0],ANA_GEN_REG[5][9]};
assign D2A_DATA_11           =  i_out_wave_driver_idac[11];   // {ANA_GEN_REG[5][11],ANA_GEN_REG[5][10][7:4]};
assign D2A_DATA_12           =  i_out_wave_driver_idac[12];   // {ANA_GEN_REG[6][0][3:0],ANA_GEN_REG[5][12]};
assign D2A_DATA_13           =  i_out_wave_driver_idac[13];   // {ANA_GEN_REG[6][1],ANA_GEN_REG[6][0][7:4]};
assign D2A_DATA_14           =  i_out_wave_driver_idac[14];   // {ANA_GEN_REG[6][3][3:0],ANA_GEN_REG[6][2]};
assign D2A_DATA_15           =  i_out_wave_driver_idac[15];   // {ANA_GEN_REG[6][4],ANA_GEN_REG[6][3][7:4]};

assign D2A_CBUF_EN           = i_driver_en_sw; 
assign D2A_IDAC_EN           = i_ds_driver_en_driver;   // {ANA_ENABLE_REG[1][0],ANA_ENABLE_REG[0][14]}; 
//assign D2A_DRIVER_CUR_EN   = i_ds_driver_en_current;  // ANA_ENABLE_REG[0][1][2];
assign D2A_DRIVER_CUR_EN     = pinmux_if.i_ds_driver_en_current;  // ANA_ENABLE_REG[0][1][2];
assign D2A_DRIVER_CUR_TRIM   = D2A_TRIM6_SIG;
assign D2A_PULLD             = i_pulldn_driver;         // {ANA_GEN_REG[6][6],ANA_GEN_REG[6][5]};
assign D2A_SOURCE            = i_source_driver;         // {ANA_GEN_REG[6][8],ANA_GEN_REG[6][7]};
//assign D2A_STIMU_EN          = i_stimu_en;              // ANA_ENABLE_REG[0][1][3];
assign D2A_STIMU_EN          = pinmux_if.i_stimu_en;              // ANA_ENABLE_REG[0][1][3];
//assign D2A_DRIVERC_LEAD_OFF_EN       = ANA_ENABLE_REG[0][3][3];
//assign D2A_ADBUF_GSEL            = ANA_GEN_REG[2][0][5:4];
//assign D2A_AD_INSELA             = ANA_GEN_REG[2][1][3:0];
//assign D2A_AD_INSELB             = ANA_GEN_REG[2][1][7:4];
//assign D2A_DRIVERC_LEAD_OFF_INSEL    = ANA_GEN_REG[6][9][3:0];
//assign D2A_DRIVERC_SHORT_DET_EN      = ANA_ENABLE_REG[0][3][4];
//assign D2A_DRIVERC_SHORT_DET_VINSEL  = {ANA_GEN_REG[6][10][0],ANA_GEN_REG[6][9][7:4]};
//assign D2A_DRIVERC_SHORT_DET_VIPSEL  = ANA_GEN_REG[6][10][5:1];

//NIRS
//assign D2A_NIRS4_EN          = ANA_ENABLE_REG[0][1][5];
//assign D2A_NIRS_TEST_EN      = ANA_ENABLE_REG[0][1][6];
//assign D2A_NIRS4_IDAC_EN     = ANA_ENABLE_REG[0][1][7];

//SDM
assign D2A_SDMEN             = {ANA_ENABLE_REG[0][14],ANA_ENABLE_REG[0][13]}; 
assign D2A_SDM_TEST          = ANA_ENABLE_REG[0][1][2];
//assign D2A_SDMBUFF_EN        = {ANA_ENABLE_REG[1][4],ANA_ENABLE_REG[1][3]}; 

//SPARE
assign D2A_SPI_SPARE0        = ANA_GEN_REG[0][13];
assign D2A_SPI_SPARE1        = ANA_GEN_REG[1][13];
assign D2A_SPI_SPARE2        = ANA_GEN_REG[2][13];
assign D2A_SPI_SPARE3        = ANA_GEN_REG[3][13];
assign D2A_SPI_SPARE4        = ANA_GEN_REG[4][13];
assign D2A_SPI_SPARE5        = ANA_GEN_REG[5][13];
assign D2A_SPI_SPARE6        = ANA_GEN_REG[6][13];
assign D2A_SPI_SPARE7        = ANA_GEN_REG[7][13];


// WG_CH1
//assign D2A_DRIVERA_SOURCEA_CH1    = i_source_driver[0];    //ANA_GEN_REG_2[1]; 
//assign D2A_DRIVERA_SOURCEB_CH1  = i_sourceb_driver_a[0];    //ANA_GEN_REG_2[2]; 
//assign D2A_DRIVERA_PULLDA_CH1    = i_pulldn_driver[0];     //ANA_GEN_REG_2[3]; 
//assign D2A_DRIVERA_PULLDB_CH1   = i_pulldb_driver_a[0];     //ANA_GEN_REG_2[4]; 
//assign D2A_IDAC_DIN_CH1           = i_out_wave_driver_idac[0];  //{ANA_GEN_REG_6, ANA_GEN_REG_5};


// FROM WG
//assign D2A_DRIVERA_SOURCEA_CH2  = i_source_driver[1];    //ANA_GEN_REG_A[1]
//assign D2A_DRIVERA_SOURCEB_CH2  = i_sourceb_driver_a[1];    //ANA_GEN_REG_A[2]
//assign D2A_DRIVERA_PULLDA_CH2   = i_pulldn_driver[1];     //ANA_GEN_REG_A[3]
//assign D2A_DRIVERA_PULLDB_CH2   = i_pulldb_driver_a[1];     //ANA_GEN_REG_A[4]
//assign D2A_IDAC_DIN_CH2         = i_out_wave_driver_idac[1];  //{ANA_GEN_REG_E, ANA_GEN_REG_D};


/*************NIRS************/
wire        D2A_PDBIAS_EN;
wire  [1:0] D2A_PDBIAS_ADJ;
wire        D2A_CLK_NIRS;
wire        D2A_NIRS_CHOPPER_EN;
wire  [1:0] D2A_NIRS_FCHOP_ADJ;
wire        D2A_NIRS_TEST_EN;
wire        D2A_NIRS_POWER_EN;
wire        D2A_NIRS_EN             [7:0];
wire        D2A_NIRS_IDAC_EN        [7:0];
wire        D2A_NIRS_RESET_SW       [7:0];
wire        D2A_NIRS_IPD_SW         [7:0];
wire        D2A_NIRS_IIN_SW         [7:0];
wire  [1:0] D2A_NIRS_IPDMIRROR_ADJ  [7:0];
wire  [1:0] D2A_NIRS_IREFC_ADJ      [7:0];
wire  [1:0] D2A_NIRS_CFRATE_ADJ0; //RATIO
wire  [1:0] D2A_NIRS_CFRATE_ADJ1; //RATIO
wire  [1:0] D2A_NIRS_CFRATE_ADJ2; //RATIO
wire  [1:0] D2A_NIRS_CFRATE_ADJ3; //RATIO
wire  [5:0] D2A_NIRS_CFRATE_ADJ4; //RATIO
wire  [1:0] D2A_NIRS_CFRATE_ADJ5; //RATIO
wire  [1:0] D2A_NIRS_CFRATE_ADJ6; //RATIO
wire  [1:0] D2A_NIRS_CFRATE_ADJ7; //RATIO
wire  [8:0] D2A_NIRS_IDAC_ADJ       [7:0];

wire        A2D_NIRS_IREFCOARSE     [7:0];
wire        A2D_NIRS_IREFFINE       [7:0];

assign D2A_PDBIAS_EN            = ana_nirs_if.D2A_PDBIAS_EN;
assign D2A_PDBIAS_ADJ           = ana_nirs_if.D2A_PDBIAS_ADJ;
assign D2A_CLK_NIRS             = ana_nirs_if.D2A_CLK_NIRS;
assign D2A_NIRS_CHOPPER_EN      = ana_nirs_if.D2A_CHOPPER_EN;
assign D2A_NIRS_FCHOP_ADJ       = ana_nirs_if.D2A_FCHOP_ADJ;
assign D2A_NIRS_TEST_EN         = ((pinmux_if.D2A_ATM[18] || pinmux_if.D2A_ATM[19] || pinmux_if.D2A_ATM[20]) && pinmux_if.ATM_HC_SEL == 1'b0) ? 1'b1 : ana_nirs_if.D2A_TEST_EN;
assign D2A_NIRS_POWER_EN        = ana_nirs_if.D2A_NIRS_POWER_EN;

assign D2A_NIRS_EN[3:0]         = ana_nirs_if.D2A_NIRS_EN[3:0];
assign D2A_NIRS_EN[4]           = ((pinmux_if.D2A_ATM[18] || pinmux_if.D2A_ATM[19] || pinmux_if.D2A_ATM[20]) && pinmux_if.ATM_HC_SEL == 1'b0) ? 1'b1 : ana_nirs_if.D2A_NIRS_EN[4];
assign D2A_NIRS_EN[7:5]         = ana_nirs_if.D2A_NIRS_EN[7:5];

assign D2A_NIRS_IDAC_EN[3:0]    = ana_nirs_if.D2A_IDAC_EN[3:0];
assign D2A_NIRS_IDAC_EN[4]      = (pinmux_if.D2A_ATM[20]  && pinmux_if.ATM_HC_SEL == 1'b0) ? 1'b1 : ana_nirs_if.D2A_IDAC_EN[4];
assign D2A_NIRS_IDAC_EN[7:5]    = ana_nirs_if.D2A_IDAC_EN[7:5];

assign D2A_NIRS_RESET_SW        = ana_nirs_if.D2A_NIRS_RESET_SW;
assign D2A_NIRS_IPD_SW          = ana_nirs_if.D2A_NIRS_IPD_SW;
assign D2A_NIRS_IIN_SW          = ana_nirs_if.D2A_NIRS_IIN_SW;
assign D2A_NIRS_IPDMIRROR_ADJ   = ana_nirs_if.D2A_IPDMIRROR_ADJ;
assign D2A_NIRS_IREFC_ADJ[3:0]  = ana_nirs_if.D2A_IREFC_ADJ[3:0];
assign D2A_NIRS_IREFC_ADJ[4]    = pinmux_if.D2A_ATM[18] ? pinmux_if.D2A_ADJ_IO[3][1:0] : pinmux_if.D2A_ATM[19] ? pinmux_if.D2A_ADJ_IO[4][1:0] : ana_nirs_if.D2A_IREFC_ADJ[4];
assign D2A_NIRS_IREFC_ADJ[7:5]  = ana_nirs_if.D2A_IREFC_ADJ[7:5];
assign D2A_NIRS_IDAC_ADJ[3:0]   = ana_nirs_if.D2A_NIRS_IDAC[3:0];
assign D2A_NIRS_IDAC_ADJ[4]     = pinmux_if.debug_mode_en ? (pinmux_if.D2A_ATM[20] ? {1'b0, pinmux_if.D2A_ADJ_IO[5]} : ana_nirs_if.IDAC_MANUAL_ATM) : ana_nirs_if.D2A_NIRS_IDAC[4];
assign D2A_NIRS_IDAC_ADJ[7:5]   = ana_nirs_if.D2A_NIRS_IDAC[7:5];
assign D2A_NIRS_CFRATE_ADJ0     = ana_nirs_if.D2A_NIRS_RATIO[0];
assign D2A_NIRS_CFRATE_ADJ1     = ana_nirs_if.D2A_NIRS_RATIO[1];
assign D2A_NIRS_CFRATE_ADJ2     = ana_nirs_if.D2A_NIRS_RATIO[2];
assign D2A_NIRS_CFRATE_ADJ3     = ana_nirs_if.D2A_NIRS_RATIO[3];
assign D2A_NIRS_CFRATE_ADJ4     = pinmux_if.D2A_ATM[18] ? pinmux_if.D2A_ADJ_IO[3][7:2] : pinmux_if.D2A_ATM[19] ? pinmux_if.D2A_ADJ_IO[4][7:2] : {4'b0, ana_nirs_if.D2A_NIRS_RATIO[4]};
assign D2A_NIRS_CFRATE_ADJ5     = ana_nirs_if.D2A_NIRS_RATIO[5];
assign D2A_NIRS_CFRATE_ADJ6     = ana_nirs_if.D2A_NIRS_RATIO[6];
assign D2A_NIRS_CFRATE_ADJ7     = ana_nirs_if.D2A_NIRS_RATIO[7];
assign ana_nirs_if.A2D_NIRS_IREFCOARSE  = A2D_NIRS_IREFCOARSE;
assign ana_nirs_if.A2D_NIRS_IREFFINE    = A2D_NIRS_IREFFINE;
/***********NIRS END**********/

ENS2_ANA_CHIP u_top_ana (

`ifdef FPGA
  .clk_in1              (clk_in1)
`endif

// PMU
  .D2A_BG_TRIM            (D2A_BG_TRIM), 
  .D2A_IREF_TRIM          (D2A_IREF_TRIM), 
  .D2A_BGBUFFER_CPTEST_EN (D2A_BGBUFFER_CPTEST_EN),
  .D2A_BGBUFFER_TRIM      (D2A_BGBUFFER_TRIM), 
  .D2A_LVD_EN             (D2A_LVD_EN), 
  .D2A_LVD_SEL            (D2A_LVD_SEL),
  .D2A_OSC8MHZEN          (D2A_OSC8MHZEN), 
  .D2A_OSC8MHZ_TRIM       (D2A_OSC8MHZ_TRIM), 
  .D2A_CLDO1P8_TRIM       (D2A_CLDO1P8_TRIM), 
  .D2A_EN_TSC             (D2A_EN_TSC), 
  .D2A_TSC_TRIM           (D2A_TSC_TRIM), 
  .D2A_VDAC8B_DIN         (D2A_VDAC8B_DIN),
  .A2D_LVD                (A2D_LVD), 
  .A2D_POR                (A2D_POR), 
  .A2D_CLK8MHZ            (A2D_CLK8MHZ), 
  .A2D_TSC_COMP_OUT       (A2D_TSC_COMP_OUT_CH1_tmp),

// BIST AMA
  .D2A_BIST_EN            (D2A_BIST_EN),
  .D2A_BIST_SEL           (D2A_BIST_SEL), 

// DC LEAD OFF
  .D2A_DCLOFFEN           (D2A_DCLOFFEN), 
  .D2A_LOFF_COMP_TH       (D2A_LOFF_COMP_TH), 
  .D2A_LOFF_ISEL_ADJ      (D2A_LOFF_ISEL_ADJ), 
  .D2A_LOFF_IPOL          (D2A_LOFF_IPOL),
  .A2D_LOFF_STATP         (A2D_LOFF_STATP), 
  .A2D_LOFF_STATN         (A2D_LOFF_STATN),

// Recording(MUX-LNA-PGA)
  .D2A_BIAS_MEAS          (D2A_BIAS_MEAS), 
  .D2A_BIASREF_INT        (D2A_BIASREF_INT),
  .D2A_SDMVCMBUFF_EN      (D2A_SDMVCMBUFF_EN),
  .D2A_SDMVCMBUFF_IADJ    (D2A_SDMVCMBUFF_IADJ), 
  .D2A_SDMVREFPBUFF_EN    (D2A_SDMVREFPBUFF_EN),
  .D2A_SDMVREFP_IADJ      (D2A_SDMVREFP_IADJ), 
  .D2A_RLD_EN             (D2A_RLD_EN),
  .D2A_RLD_ELECTRODE_EN   (D2A_RLD_ELECTRODE_EN), 
  .D2A_RLD_IADJ           (D2A_RLD_IADJ), 
  .D2A_EEG_CH0_SET        (D2A_EEG_CH0_SET), 
  .D2A_EEG_CH1_SET        (D2A_EEG_CH1_SET), 
  .D2A_EEG_CH2_SET        (D2A_EEG_CH2_SET),
  .D2A_EEG_CH3_SET        (D2A_EEG_CH3_SET), 
  .D2A_EEG_CH4_SET        (D2A_EEG_CH4_SET), 
  .D2A_EEG_CH5_SET        (D2A_EEG_CH5_SET),
  .D2A_EEG_CH6_SET        (D2A_EEG_CH6_SET), 
  .D2A_EEG_CH7_SET        (D2A_EEG_CH7_SET), 
  .D2A_EEG_CH8_SET        (D2A_EEG_CH8_SET),
  .D2A_EEG_CH9_SET        (D2A_EEG_CH9_SET), 
  .D2A_EEG_CH10_SET       (D2A_EEG_CH10_SET),
  .D2A_EEG_CH11_SET       (D2A_EEG_CH11_SET), 
  .D2A_EEG_CH12_SET       (D2A_EEG_CH12_SET),
  .D2A_EEG_CH13_SET       (D2A_EEG_CH13_SET), 
  .D2A_EEG_CH14_SET       (D2A_EEG_CH14_SET),
  .D2A_EEG_CH15_SET       (D2A_EEG_CH15_SET),
  .D2A_INA_CLK            (ina_pga_ana_clk),
  .D2A_GAIN_PGA_CH0_ADJ   (D2A_GAIN_PGA_CH0_ADJ),
  .D2A_GAIN_PGA_CH1_ADJ   (D2A_GAIN_PGA_CH1_ADJ),
  .D2A_GAIN_PGA_CH2_ADJ   (D2A_GAIN_PGA_CH2_ADJ),
  .D2A_GAIN_PGA_CH3_ADJ   (D2A_GAIN_PGA_CH3_ADJ),
  .D2A_GAIN_PGA_CH4_ADJ   (D2A_GAIN_PGA_CH4_ADJ),
  .D2A_GAIN_PGA_CH5_ADJ   (D2A_GAIN_PGA_CH5_ADJ),
  .D2A_GAIN_PGA_CH6_ADJ   (D2A_GAIN_PGA_CH6_ADJ),
  .D2A_GAIN_PGA_CH7_ADJ   (D2A_GAIN_PGA_CH7_ADJ),
  .D2A_GAIN_PGA_CH8_ADJ   (D2A_GAIN_PGA_CH8_ADJ),
  .D2A_GAIN_PGA_CH9_ADJ   (D2A_GAIN_PGA_CH9_ADJ),
  .D2A_GAIN_PGA_CH10_ADJ  (D2A_GAIN_PGA_CH10_ADJ),
  .D2A_GAIN_PGA_CH11_ADJ  (D2A_GAIN_PGA_CH11_ADJ),
  .D2A_GAIN_PGA_CH12_ADJ  (D2A_GAIN_PGA_CH12_ADJ),
  .D2A_GAIN_PGA_CH13_ADJ  (D2A_GAIN_PGA_CH13_ADJ),
  .D2A_GAIN_PGA_CH14_ADJ  (D2A_GAIN_PGA_CH14_ADJ),
  .D2A_GAIN_PGA_CH15_ADJ  (D2A_GAIN_PGA_CH15_ADJ),
  .D2A_GAIN_DDA_CH0_ADJ   (D2A_GAIN_DDA_CH0_ADJ),
  .D2A_GAIN_DDA_CH1_ADJ   (D2A_GAIN_DDA_CH1_ADJ),
  .D2A_GAIN_DDA_CH2_ADJ   (D2A_GAIN_DDA_CH2_ADJ),
  .D2A_GAIN_DDA_CH3_ADJ   (D2A_GAIN_DDA_CH3_ADJ),
  .D2A_GAIN_DDA_CH4_ADJ   (D2A_GAIN_DDA_CH4_ADJ),
  .D2A_GAIN_DDA_CH5_ADJ   (D2A_GAIN_DDA_CH5_ADJ),
  .D2A_GAIN_DDA_CH6_ADJ   (D2A_GAIN_DDA_CH6_ADJ),
  .D2A_GAIN_DDA_CH7_ADJ   (D2A_GAIN_DDA_CH7_ADJ),
  .D2A_GAIN_DDA_CH8_ADJ   (D2A_GAIN_DDA_CH8_ADJ),
  .D2A_GAIN_DDA_CH9_ADJ   (D2A_GAIN_DDA_CH9_ADJ),
  .D2A_GAIN_DDA_CH10_ADJ  (D2A_GAIN_DDA_CH10_ADJ),
  .D2A_GAIN_DDA_CH11_ADJ  (D2A_GAIN_DDA_CH11_ADJ),
  .D2A_GAIN_DDA_CH12_ADJ  (D2A_GAIN_DDA_CH12_ADJ),
  .D2A_GAIN_DDA_CH13_ADJ  (D2A_GAIN_DDA_CH13_ADJ),
  .D2A_GAIN_DDA_CH14_ADJ  (D2A_GAIN_DDA_CH14_ADJ),
  .D2A_GAIN_DDA_CH15_ADJ  (D2A_GAIN_DDA_CH15_ADJ),
  .D2A_INADC_ADJ          (D2A_INADC_ADJ),
  .D2A_PGAEN              (D2A_PGAEN),
  .D2A_PGA_ENCH           (D2A_PGA_ENCH),
  .D2A_PGA_IADJ           (D2A_PGA_IADJ),
  .D2A_RLDEN_INA          (D2A_RLDEN_INA),
  .D2A_DDAEN              (D2A_DDAEN),
  .D2A_DDA_IADJ           (D2A_DDA_IADJ),
  .D2A_EEG_EN             (D2A_EEG_EN),
  .D2A_VCM_INA_ADJ        (D2A_VCM_INA_ADJ),
  .D2A_VCM_INAEN          (D2A_VCM_INAEN),
  .D2A_SDMVCMBUFF_ADJ     (D2A_SDMVCMBUFF_ADJ),
  .D2A_SDMVREFP_ADJ       (D2A_SDMVREFP_ADJ),
  
// Stimulator - WG
  .D2A_DATA_0             (D2A_DATA_0),
  .D2A_DATA_1             (D2A_DATA_1), 
  .D2A_DATA_2             (D2A_DATA_2), 
  .D2A_DATA_3             (D2A_DATA_3),
  .D2A_DATA_4             (D2A_DATA_4), 
  .D2A_DATA_5             (D2A_DATA_5), 
  .D2A_DATA_6             (D2A_DATA_6),
  .D2A_DATA_7             (D2A_DATA_7), 
  .D2A_DATA_8             (D2A_DATA_8), 
  .D2A_DATA_9             (D2A_DATA_9),
  .D2A_DATA_10            (D2A_DATA_10), 
  .D2A_DATA_11            (D2A_DATA_11), 
  .D2A_DATA_12            (D2A_DATA_12),
  .D2A_DATA_13            (D2A_DATA_13), 
  .D2A_DATA_14            (D2A_DATA_14), 
  .D2A_DATA_15            (D2A_DATA_15),
  .D2A_CBUF_EN            (D2A_CBUF_EN),
  .D2A_IDAC_EN            (D2A_IDAC_EN),
  .D2A_DRIVER_CUR_EN      (D2A_DRIVER_CUR_EN), 
  .D2A_DRIVER_CUR_TRIM    (D2A_DRIVER_CUR_TRIM),
  .D2A_PULLD              (D2A_PULLD), 
  .D2A_SOURCE             (D2A_SOURCE),
  .D2A_STIMU_EN           (D2A_STIMU_EN), 
  .D2A_ADBUF_GSEL         (D2A_ADBUF_GSEL),
  .D2A_ADC_CLK            (D2A_ADC_CLK),    //to analog	
  .D2A_ADC_DELAY          (D2A_ADC_DELAY),
  .D2A_ADC_EN             (D2A_ADC_EN),     //to analog	
  .D2A_STIM_PAD0          (D2A_STIM_PAD0),  //to analog	
  .D2A_STIM_PAD1          (D2A_STIM_PAD1),  //to analog	
  .A2D_ADC_DATA           (A2D_ADC_DATA),   //from analog //ADC use posedge of sysclk to output data, 
  .A2D_ADC_DATA_EN        (A2D_ADC_DATA_EN),//from analog	


// NIRS
  .D2A_PDBIAS_EN          (D2A_PDBIAS_EN),
  .D2A_PDBIAS_ADJ         (D2A_PDBIAS_ADJ),
  .D2A_CLK_NIRS           (D2A_CLK_NIRS), 
  .D2A_NIRS_CHOPPER_EN    (D2A_NIRS_CHOPPER_EN), 
  .D2A_NIRS_FCHOP_ADJ     (D2A_NIRS_FCHOP_ADJ), 
  .D2A_NIRS_TEST_EN       (D2A_NIRS_TEST_EN),
  .D2A_NIRS_POWER_EN      (D2A_NIRS_POWER_EN),

  .D2A_NIRS0_EN           (D2A_NIRS_EN[0]), 
  .D2A_NIRS0_IDAC_EN      (D2A_NIRS_IDAC_EN[0]), 
  .D2A_NIRS0_RESET_SW     (D2A_NIRS_RESET_SW[0]),
  .D2A_NIRS0_IPD_SW       (D2A_NIRS_IPD_SW[0]), 
  .D2A_NIRS0_IIN_SW       (D2A_NIRS_IIN_SW[0]),
  .D2A_NIRS0_IPDMIRROR_ADJ(D2A_NIRS_IPDMIRROR_ADJ[0]),
  .D2A_NIRS0_IREFC_ADJ    (D2A_NIRS_IREFC_ADJ[0]),
  .D2A_NIRS0_IDAC_ADJ     (D2A_NIRS_IDAC_ADJ[0]),
  .D2A_NIRS0_CFRATE_ADJ   (D2A_NIRS_CFRATE_ADJ0), 

  .D2A_NIRS1_EN           (D2A_NIRS_EN[1]), 
  .D2A_NIRS1_IDAC_EN      (D2A_NIRS_IDAC_EN[1]), 
  .D2A_NIRS1_RESET_SW     (D2A_NIRS_RESET_SW[1]),
  .D2A_NIRS1_IPD_SW       (D2A_NIRS_IPD_SW[1]), 
  .D2A_NIRS1_IIN_SW       (D2A_NIRS_IIN_SW[1]),
  .D2A_NIRS1_IPDMIRROR_ADJ(D2A_NIRS_IPDMIRROR_ADJ[1]),
  .D2A_NIRS1_IREFC_ADJ    (D2A_NIRS_IREFC_ADJ[1]),
  .D2A_NIRS1_IDAC_ADJ     (D2A_NIRS_IDAC_ADJ[1]),
  .D2A_NIRS1_CFRATE_ADJ   (D2A_NIRS_CFRATE_ADJ1), 

  .D2A_NIRS2_EN           (D2A_NIRS_EN[2]), 
  .D2A_NIRS2_IDAC_EN      (D2A_NIRS_IDAC_EN[2]), 
  .D2A_NIRS2_RESET_SW     (D2A_NIRS_RESET_SW[2]),
  .D2A_NIRS2_IPD_SW       (D2A_NIRS_IPD_SW[2]), 
  .D2A_NIRS2_IIN_SW       (D2A_NIRS_IIN_SW[2]),
  .D2A_NIRS2_IPDMIRROR_ADJ(D2A_NIRS_IPDMIRROR_ADJ[2]),
  .D2A_NIRS2_IREFC_ADJ    (D2A_NIRS_IREFC_ADJ[2]),
  .D2A_NIRS2_IDAC_ADJ     (D2A_NIRS_IDAC_ADJ[2]),
  .D2A_NIRS2_CFRATE_ADJ   (D2A_NIRS_CFRATE_ADJ2), 

  .D2A_NIRS3_EN           (D2A_NIRS_EN[3]), 
  .D2A_NIRS3_IDAC_EN      (D2A_NIRS_IDAC_EN[3]), 
  .D2A_NIRS3_RESET_SW     (D2A_NIRS_RESET_SW[3]),
  .D2A_NIRS3_IPD_SW       (D2A_NIRS_IPD_SW[3]), 
  .D2A_NIRS3_IIN_SW       (D2A_NIRS_IIN_SW[3]),
  .D2A_NIRS3_IPDMIRROR_ADJ(D2A_NIRS_IPDMIRROR_ADJ[3]),
  .D2A_NIRS3_IREFC_ADJ    (D2A_NIRS_IREFC_ADJ[3]),
  .D2A_NIRS3_IDAC_ADJ     (D2A_NIRS_IDAC_ADJ[3]),
  .D2A_NIRS3_CFRATE_ADJ   (D2A_NIRS_CFRATE_ADJ3), 

  .D2A_NIRS4_EN           (D2A_NIRS_EN[4]), 
  .D2A_NIRS4_IDAC_EN      (D2A_NIRS_IDAC_EN[4]), 
  .D2A_NIRS4_RESET_SW     (D2A_NIRS_RESET_SW[4]),
  .D2A_NIRS4_IPD_SW       (D2A_NIRS_IPD_SW[4]), 
  .D2A_NIRS4_IIN_SW       (D2A_NIRS_IIN_SW[4]),
  .D2A_NIRS4_IPDMIRROR_ADJ(D2A_NIRS_IPDMIRROR_ADJ[4]),
  .D2A_NIRS4_IREFC_ADJ    (D2A_NIRS_IREFC_ADJ[4]),
  .D2A_NIRS4_IDAC_ADJ     (D2A_NIRS_IDAC_ADJ[4]),
  .D2A_NIRS4_CFRATE_ADJ   (D2A_NIRS_CFRATE_ADJ4), 

  .D2A_NIRS5_EN           (D2A_NIRS_EN[5]), 
  .D2A_NIRS5_IDAC_EN      (D2A_NIRS_IDAC_EN[5]), 
  .D2A_NIRS5_RESET_SW     (D2A_NIRS_RESET_SW[5]),
  .D2A_NIRS5_IPD_SW       (D2A_NIRS_IPD_SW[5]), 
  .D2A_NIRS5_IIN_SW       (D2A_NIRS_IIN_SW[5]),
  .D2A_NIRS5_IPDMIRROR_ADJ(D2A_NIRS_IPDMIRROR_ADJ[5]),
  .D2A_NIRS5_IREFC_ADJ    (D2A_NIRS_IREFC_ADJ[5]),
  .D2A_NIRS5_IDAC_ADJ     (D2A_NIRS_IDAC_ADJ[5]),
  .D2A_NIRS5_CFRATE_ADJ   (D2A_NIRS_CFRATE_ADJ5), 

  .D2A_NIRS6_EN           (D2A_NIRS_EN[6]), 
  .D2A_NIRS6_IDAC_EN      (D2A_NIRS_IDAC_EN[6]), 
  .D2A_NIRS6_RESET_SW     (D2A_NIRS_RESET_SW[6]),
  .D2A_NIRS6_IPD_SW       (D2A_NIRS_IPD_SW[6]), 
  .D2A_NIRS6_IIN_SW       (D2A_NIRS_IIN_SW[6]),
  .D2A_NIRS6_IPDMIRROR_ADJ(D2A_NIRS_IPDMIRROR_ADJ[6]),
  .D2A_NIRS6_IREFC_ADJ    (D2A_NIRS_IREFC_ADJ[6]),
  .D2A_NIRS6_IDAC_ADJ     (D2A_NIRS_IDAC_ADJ[6]),
  .D2A_NIRS6_CFRATE_ADJ   (D2A_NIRS_CFRATE_ADJ6), 

  .D2A_NIRS7_EN           (D2A_NIRS_EN[7]), 
  .D2A_NIRS7_IDAC_EN      (D2A_NIRS_IDAC_EN[7]), 
  .D2A_NIRS7_RESET_SW     (D2A_NIRS_RESET_SW[7]),
  .D2A_NIRS7_IPD_SW       (D2A_NIRS_IPD_SW[7]), 
  .D2A_NIRS7_IIN_SW       (D2A_NIRS_IIN_SW[7]),
  .D2A_NIRS7_IPDMIRROR_ADJ(D2A_NIRS_IPDMIRROR_ADJ[7]),
  .D2A_NIRS7_IREFC_ADJ    (D2A_NIRS_IREFC_ADJ[7]),
  .D2A_NIRS7_IDAC_ADJ     (D2A_NIRS_IDAC_ADJ[7]),
  .D2A_NIRS7_CFRATE_ADJ   (D2A_NIRS_CFRATE_ADJ7), 


  .A2D_NIRS0_IREFCOARSE   (A2D_NIRS_IREFCOARSE[0]),
  .A2D_NIRS0_IREFFINE     (A2D_NIRS_IREFFINE[0]), 
  .A2D_NIRS1_IREFCOARSE   (A2D_NIRS_IREFCOARSE[1]), 
  .A2D_NIRS1_IREFFINE     (A2D_NIRS_IREFFINE[1]),
  .A2D_NIRS2_IREFCOARSE   (A2D_NIRS_IREFCOARSE[2]), 
  .A2D_NIRS2_IREFFINE     (A2D_NIRS_IREFFINE[2]), 
  .A2D_NIRS3_IREFCOARSE   (A2D_NIRS_IREFCOARSE[3]),
  .A2D_NIRS3_IREFFINE     (A2D_NIRS_IREFFINE[3]), 
  .A2D_NIRS4_IREFCOARSE   (A2D_NIRS_IREFCOARSE[4]), 
  .A2D_NIRS4_IREFFINE     (A2D_NIRS_IREFFINE[4]),
  .A2D_NIRS5_IREFCOARSE   (A2D_NIRS_IREFCOARSE[5]), 
  .A2D_NIRS5_IREFFINE     (A2D_NIRS_IREFFINE[5]), 
  .A2D_NIRS6_IREFCOARSE   (A2D_NIRS_IREFCOARSE[6]),
  .A2D_NIRS6_IREFFINE     (A2D_NIRS_IREFFINE[6]), 
  .A2D_NIRS7_IREFCOARSE   (A2D_NIRS_IREFCOARSE[7]), 
  .A2D_NIRS7_IREFFINE     (A2D_NIRS_IREFFINE[7]),

// SDM
  .D2A_SDMEN              (D2A_SDMEN), 
  .D2A_SDMCLK             (D2A_SDM_CLK), 
  .D2A_SDM_TEST           (D2A_SDM_TEST),
  .A2D_SDM0               (A2D_SDM_OUT0), 
  .A2D_SDM1               (A2D_SDM_OUT1), 
  .A2D_SDM2               (A2D_SDM_OUT2), 
  .A2D_SDM3               (A2D_SDM_OUT3), 
  .A2D_SDM4               (A2D_SDM_OUT4),
  .A2D_SDM5               (A2D_SDM_OUT5), 
  .A2D_SDM6               (A2D_SDM_OUT6), 
  .A2D_SDM7               (A2D_SDM_OUT7), 
  .A2D_SDM8               (A2D_SDM_OUT8), 
  .A2D_SDM9               (A2D_SDM_OUT9), 
  .A2D_SDM10              (A2D_SDM_OUT10),
  .A2D_SDM11              (A2D_SDM_OUT11), 
  .A2D_SDM12              (A2D_SDM_OUT12), 
  .A2D_SDM13              (A2D_SDM_OUT13), 
  .A2D_SDM14              (A2D_SDM_OUT14),
  .A2D_SDM15              (A2D_SDM_OUT15), 

// SPARE
  .D2A_SPI_SPARE0         (D2A_SPI_SPARE0),
  .D2A_SPI_SPARE1         (D2A_SPI_SPARE1),
  .D2A_SPI_SPARE2         (D2A_SPI_SPARE2),
  .D2A_SPI_SPARE3         (D2A_SPI_SPARE3),
  .D2A_SPI_SPARE4         (D2A_SPI_SPARE4),
  .D2A_SPI_SPARE5         (D2A_SPI_SPARE5),
  .D2A_SPI_SPARE6         (D2A_SPI_SPARE6),
  .D2A_SPI_SPARE7         (D2A_SPI_SPARE7),
  .D2A_TRIM0_SIG_SPARE    (D2A_TRIM0_SIG_SPARE), 
  .D2A_TRIM1_SIG_SPARE    (D2A_TRIM1_SIG_SPARE),
  .D2A_TRIM2_SIG_SPARE    (D2A_TRIM2_SIG_SPARE), 
  .D2A_TRIM3_SIG_SPARE    (D2A_TRIM3_SIG_SPARE),
  .D2A_TRIM4_SIG_SPARE    (D2A_TRIM4_SIG_SPARE), 
  .D2A_TRIM5_SIG_SPARE    (D2A_TRIM5_SIG_SPARE),
  .D2A_TRIM6_SIG_SPARE    (D2A_TRIM6_SIG_SPARE), 
  .D2A_TRIM7_SIG_SPARE    (D2A_TRIM7_SIG_SPARE),
  .A2D_SPARE_RO_REG_0     (A2D_SPARE_RO_REG_0_tmp),

// POWER/GND
  .VDD_DIG                (VDD_DIG), 
  .VSS_DIG                (VSS_DIG), 
  .VDDIO                  (VDDIO),
  .VSSIO                  (VSSIO)

);

endmodule
