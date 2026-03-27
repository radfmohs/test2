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

module ENS2_ANA_CHIP_wrapper ( 

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
  output  A2D_CLK2MHZ,
  output  A2D_POR_DVDD,
  output  A2D_COMP_OUT_CH1,
  output  A2D_COMP_OUT_CH2,
  inout   VDDIO,
  inout   VDD_DIG,
  inout   VSS_DIG,
  //inout   AVDD,

  pinmux_if.A2D   pinmux_if,
  spi_ana_if.ana  spi_ana_if,
  ana_nirs_if.ana ana_nirs_if,

  //WG
  input wire [11:0] i_out_wave_driver_idac[15:0],
  input wire [15:0] i_ds_driver_en_driver,
  input wire 	    i_ds_driver_en_current,
  input wire [15:0] i_driver_en_sw,
  input wire 	    i_stimu_en,            

  input [15:0] i_source_driver,
//  input [15:0] i_sourceb_driver_a,
  input [15:0] i_pulldn_driver
//  input [15:0] i_pulldb_driver_a
);

wire  [7:0] A2D_ANA_GEN_REG_0;
wire  [7:0] A2D_SPARE_RO_REG_0;
wire  [7:0] A2D_SPARE_RO_REG_0_tmp;
wire        A2D_COMP_OUT_CH1_tmp;
wire        A2D_COMP_OUT_CH2_tmp;
wire        A2D_TSC_COMP_OUT_CH1_tmp;

wire        D2A_ATM0;
wire        D2A_ATM1;
wire        D2A_ATM2;
wire        D2A_ATM3;
wire        D2A_ATM4;
wire        D2A_ATM5;
wire        D2A_ATM6;
wire        D2A_ATM7;

wire  [7:0] D2A_TRIM0_SIG_SPARE;
wire  [7:0] D2A_TRIM0_SIG;
wire  [7:0] D2A_TRIM1_SIG;
wire  [7:0] D2A_TRIM2_SIG;
wire  [7:0] D2A_TRIM3_SIG;
wire  [7:0] D2A_TRIM4_SIG;
wire  [7:0] D2A_TRIM5_SIG;
wire  [7:0] D2A_TRIM6_SIG;

wire  [1:0] A2D_TRIM0_SIG;
wire  [1:0] A2D_TRIM1_SIG;
wire  [1:0] A2D_TRIM2_SIG;
wire  [1:0] A2D_TRIM3_SIG;
wire  [1:0] A2D_TRIM4_SIG;
wire  [1:0] A2D_TRIM5_SIG;
wire  [1:0] A2D_TRIM6_SIG;
wire  [1:0] A2D_TRIM7_SIG;

wire        D2A_ANA_OUT_SEL1;
wire        D2A_ANA_OUT_SEL2;
wire        D2A_ANA_OUT_SEL3;
wire        D2A_ANA_OUT_SEL4;
wire        D2A_ANA_OUT_SEL5;
wire        D2A_ANA_OUT_SEL6;
wire        D2A_ANA_OUT_SEL7;

wire        A2D_COMP_OUT_STIMU0_1;
wire        A2D_COMP_OUT_STIMU2_3;

//PMU
wire  [7:0] D2A_BG_TRIM;
wire  [7:0] D2A_IREF_TRIM;
wire  [4:0] D2A_CLDO1P8_TRIM;
wire        D2A_LVD_EN;
wire  [2:0] D2A_LVD_SEL;
wire        A2D_LVD; 
wire  [3:0] D2A_IBIAS_IDAC_TRIM;

//OSC
wire  [7:0] D2A_OSC2MHZ_TRIM;
wire        D2A_OSC2MHZEN;
wire        D2A_CS_PGA_CLK_TRIM;

//HPF
//wire        D2A_HPF_EN;
//wire        D2A_HPF_ISEL;

//BIST
wire        D2A_BIST_EN;
wire  [3:0] D2A_BIST_SEL;

//DRIVERA_CH1
wire  [2:0] D2A_VDAC_VTRIM_CH1;
wire        D2A_CS_EN_CH_CH1;
wire        D2A_DRIVERA_CSAMP_EN_CH1;
wire        D2A_COMP_EN_CH1;
wire        D2A_IDAC_EN_CH1;
wire        D2A_VDAC_EN_CH1;
wire [11:0] D2A_VDAC_DIN_CH1;
wire        D2A_STIMU_COMP_SEL_CH1; 
wire        D2A_STIMU_COMP_EN_CH1; 
wire  [2:0] D2A_CS_TRIM_CH1;
wire        D2A_LEAD_OFF_SEL_SA_SB_CH1;

// WG_CH1
wire        D2A_DRIVERA_SOURCEA_CH1;
wire        D2A_DRIVERA_SOURCEB_CH1;
wire        D2A_DRIVERA_PULLDA_CH1;
wire        D2A_DRIVERA_PULLDB_CH1;
wire [11:0] D2A_IDAC_DIN_CH1;

//PUMP_CH1
wire        D2A_PUMP_CLK_TRIM_CH1;
wire        D2A_PUMP_5V_EN_CH1;
wire        D2A_PUMP_LDO_EN_CH1;
wire  [1:0] D2A_LDO2P8_PUMP_TRIM_CH1;
wire        D2A_LDO1P8_LDO2P8_CH1_SEL;

//DRIVERA_CH2
wire  [2:0] D2A_VDAC_VTRIM_CH2;
wire        D2A_CS_EN_CH_CH2;
wire        D2A_DRIVERA_CSAMP_EN_CH2;
wire        D2A_COMP_EN_CH2;
wire        D2A_IDAC_EN_CH2;
wire        D2A_VDAC_EN_CH2;
wire [11:0] D2A_VDAC_DIN_CH2;
wire        D2A_STIMU_COMP_SEL_CH2; 
wire        D2A_STIMU_COMP_EN_CH2; 
wire  [2:0] D2A_CS_TRIM_CH2;
wire        D2A_LEAD_OFF_SEL_SA_SB_CH2;

//WG_CH2
wire        D2A_DRIVERA_SOURCEA_CH2;
wire        D2A_DRIVERA_SOURCEB_CH2;
wire        D2A_DRIVERA_PULLDA_CH2;
wire        D2A_DRIVERA_PULLDB_CH2;
wire [11:0] D2A_IDAC_DIN_CH2;

//PUMP_CH2
wire        D2A_PUMP_CLK_TRIM_CH2;
wire        D2A_PUMP_5V_EN_CH2;
wire        D2A_PUMP_LDO_EN_CH2;
wire  [1:0] D2A_LDO2P8_PUMP_TRIM_CH2;

wire  [7:0] ANA_ENABLE_REG_0;
wire  [7:0] ANA_ENABLE_REG_1;
wire  [7:0] ANA_ENABLE_REG_2;
wire  [7:0] ANA_ENABLE_REG_3;
wire  [7:0] ANA_GEN_REG_1;
wire  [7:0] ANA_GEN_REG_2;
wire  [7:0] ANA_GEN_REG_3;
wire  [7:0] ANA_GEN_REG_4;
wire  [7:0] ANA_GEN_REG_5;
wire  [7:0] ANA_GEN_REG_6;
wire  [7:0] ANA_GEN_REG_7;
wire  [7:0] ANA_GEN_REG_8;
wire  [7:0] ANA_GEN_REG_9;
// wire [7:0] ANA_GEN_REG_A;
// wire [7:0] ANA_GEN_REG_B;
// wire [7:0] ANA_GEN_REG_C;
// wire [7:0] ANA_GEN_REG_D;
// wire [7:0] ANA_GEN_REG_E;
// wire [7:0] ANA_GEN_REG_F;
// wire [7:0] ANA_GEN_REG_10;
// wire [7:0] ANA_GEN_REG_11;
// wire [7:0] ANA_GEN_REG_12;

//TSC
wire        A2D_TSC_COMP_OUT_CH1;
wire  [3:0] D2A_TSC_TRIM_CH1;
wire  [7:0] D2A_VDAC8B_DIN_CH1; 
wire        D2A_VDAC8B_EN_CH1;  
wire        D2A_TSC_COMP_EN_CH1;    
wire        D2A_TSC_EN_CH1; 
wire        D2A_IREF_TSC_OUT_SEL;
wire        D2A_IDAC_TSC_COMP_OUT_SEL;

//NIRS
wire        D2A_NIRS_EN         [7:0];
wire        D2A_NIRS_RESET_SW   [7:0];
wire        D2A_NIRS_IPD_SW     [7:0];
wire        D2A_NIRS_IIN_SW     [7:0];
wire  [8:0] D2A_NIRS_IDAC       [7:0];
wire  [1:0] D2A_NIRS_RATIO      [7:0];
wire        A2D_NIRS_IREFCOARSE [7:0];
wire        A2D_NIRS_IREFFINE   [7:0];

assign A2D_ANA_GEN_REG_0    = atpg_en ? 8'b0 : {4'b0, A2D_TSC_COMP_OUT_CH1, A2D_COMP_OUT_STIMU2_3, A2D_COMP_OUT_STIMU0_1, A2D_LVD};
assign A2D_SPARE_RO_REG_0   = atpg_en ? 8'b0 : A2D_SPARE_RO_REG_0_tmp;
assign A2D_COMP_OUT_CH1     = atpg_en ? 1'b0 : A2D_COMP_OUT_CH1_tmp; 
assign A2D_COMP_OUT_CH2     = atpg_en ? 1'b0 : A2D_COMP_OUT_CH2_tmp; 
assign A2D_TSC_COMP_OUT_CH1 = atpg_en ? 1'b0 : A2D_TSC_COMP_OUT_CH1_tmp; 

//assign ATM            = pinmux_if.ENCODED_ATM;
assign D2A_ATM0       = D2A_BIST_EN ? (pinmux_if.D2A_ATM[0] || (D2A_BIST_SEL == 4'b0000)) : 1'b0;
assign D2A_ATM1       = D2A_BIST_EN ? (pinmux_if.D2A_ATM[1] || (D2A_BIST_SEL == 4'b0001)) : 1'b0;
assign D2A_ATM2       = D2A_BIST_EN ? (pinmux_if.D2A_ATM[2] || (D2A_BIST_SEL == 4'b0010)) : 1'b0;
assign D2A_ATM3       = D2A_BIST_EN ? (pinmux_if.D2A_ATM[3] || (D2A_BIST_SEL == 4'b0011)) : 1'b0;
assign D2A_ATM4       = D2A_BIST_EN ? (pinmux_if.D2A_ATM[4] || (D2A_BIST_SEL == 4'b0100)) : 1'b0;
assign D2A_ATM5       = D2A_BIST_EN ? (pinmux_if.D2A_ATM[5] || (D2A_BIST_SEL == 4'b0101)) : 1'b0;
assign D2A_ATM6       = D2A_BIST_EN ? (pinmux_if.D2A_ATM[6] || (D2A_BIST_SEL == 4'b0110)) : 1'b0;
assign D2A_ATM7       = D2A_BIST_EN ? (pinmux_if.D2A_ATM[7] || (D2A_BIST_SEL == 4'b0111)) : 1'b0;
//assign D2A_ATM8       = pinmux_if.D2A_ATM[8];

assign D2A_TRIM0_SIG_SPARE = pinmux_if.D2A_TRIM_SIG[7];

assign D2A_TRIM0_SIG  = pinmux_if.D2A_TRIM_SIG[0];
assign D2A_TRIM1_SIG  = pinmux_if.D2A_TRIM_SIG[1];
assign D2A_TRIM2_SIG  = pinmux_if.D2A_TRIM_SIG[2];
assign D2A_TRIM3_SIG  = pinmux_if.D2A_TRIM_SIG[3];
assign D2A_TRIM4_SIG  = pinmux_if.D2A_TRIM_SIG[4];
assign D2A_TRIM5_SIG  = pinmux_if.D2A_TRIM_SIG[5];
assign D2A_TRIM6_SIG  = pinmux_if.D2A_TRIM_SIG[6];

// assign pinmux_if.A2D_TRIM_SIG[0]  = A2D_TRIM0_SIG;
// assign pinmux_if.A2D_TRIM_SIG[1]  = A2D_TRIM1_SIG;
// assign pinmux_if.A2D_TRIM_SIG[2]  = A2D_TRIM2_SIG;
// assign pinmux_if.A2D_TRIM_SIG[3]  = A2D_TRIM3_SIG;
// assign pinmux_if.A2D_TRIM_SIG[4]  = A2D_TRIM4_SIG;
// assign pinmux_if.A2D_TRIM_SIG[5]  = A2D_TRIM5_SIG;
// assign pinmux_if.A2D_TRIM_SIG[6]  = A2D_TRIM6_SIG;
// assign pinmux_if.A2D_TRIM_SIG[7]  = A2D_TRIM7_SIG;
// assign pinmux_if.A2D_TRIM_SIG[8]  = A2D_TRIM8_SIG;

assign ANA_ENABLE_REG_0 = pinmux_if.D2A_ANA_ENABLE_REG[0];
assign ANA_ENABLE_REG_1 = pinmux_if.D2A_ANA_ENABLE_REG[1];
assign ANA_ENABLE_REG_2 = pinmux_if.D2A_ANA_ENABLE_REG[2];
assign ANA_ENABLE_REG_3 = pinmux_if.D2A_ANA_ENABLE_REG[3];

assign spi_ana_if.A2D_ANA_GEN_REG[0] = A2D_ANA_GEN_REG_0 ;
assign spi_ana_if.A2D_ANA_GEN_REG[1] = A2D_SPARE_RO_REG_0;
assign ANA_GEN_REG_1    = spi_ana_if.D2A_ANA_GEN_REG[0];
assign ANA_GEN_REG_2    = spi_ana_if.D2A_ANA_GEN_REG[1];
assign ANA_GEN_REG_3    = spi_ana_if.D2A_ANA_GEN_REG[2];
assign ANA_GEN_REG_4    = spi_ana_if.D2A_ANA_GEN_REG[3];
assign ANA_GEN_REG_5    = spi_ana_if.D2A_ANA_GEN_REG[4];
assign ANA_GEN_REG_6	  = spi_ana_if.D2A_ANA_GEN_REG[5];
assign ANA_GEN_REG_7	  = spi_ana_if.D2A_ANA_GEN_REG[6];
assign ANA_GEN_REG_8    = spi_ana_if.D2A_ANA_GEN_REG[7];
assign ANA_GEN_REG_9    = spi_ana_if.D2A_ANA_GEN_REG[8];

// ANA SEL
assign D2A_ANA_OUT_SEL1 = pinmux_if.D2A_ANA_OUT_SEL1;
assign D2A_ANA_OUT_SEL2 = pinmux_if.D2A_ANA_OUT_SEL2;
assign D2A_ANA_OUT_SEL3 = pinmux_if.D2A_ANA_OUT_SEL3;
assign D2A_ANA_OUT_SEL4 = pinmux_if.D2A_ANA_OUT_SEL4;
assign D2A_ANA_OUT_SEL5 = pinmux_if.D2A_ANA_OUT_SEL5;
assign D2A_ANA_OUT_SEL6 = pinmux_if.D2A_ANA_OUT_SEL6;
assign D2A_ANA_OUT_SEL7 = pinmux_if.D2A_ANA_OUT_SEL7;

//PMU
assign D2A_BG_TRIM          = D2A_TRIM0_SIG;
assign D2A_IREF_TRIM        = D2A_TRIM1_SIG[7:0];
assign D2A_CLDO1P8_TRIM     = {D2A_TRIM2_SIG[7], D2A_TRIM2_SIG[3:0]};
assign D2A_LVD_EN           = ANA_ENABLE_REG_0[0];
assign D2A_LVD_SEL          = ANA_GEN_REG_1[2:0];   //BUS 8 bits?
assign D2A_IBIAS_IDAC_TRIM  = {D2A_TRIM6_SIG[7], D2A_TRIM6_SIG[2:0]};


//OSC
assign D2A_OSC2MHZ_TRIM   = D2A_TRIM3_SIG;
assign D2A_OSC2MHZEN      = ANA_ENABLE_REG_0[1];
assign D2A_CS_PGA_CLK_TRIM = D2A_TRIM2_SIG[6];

//HPF
//assign D2A_HPF_EN        = ANA_ENABLE_REG_0[2];
//assign D2A_HPF_ISEL      = ANA_GEN_REG_1[3];

//BIST
assign D2A_BIST_EN        = ANA_ENABLE_REG_3[0];
assign D2A_BIST_SEL       = ANA_ENABLE_REG_3[4:1];

//DRIVERA_CH1
assign D2A_VDAC_VTRIM_CH1       = D2A_TRIM4_SIG[2:0];
assign D2A_CS_EN_CH_CH1         = ANA_ENABLE_REG_1[0]; // i_driver_driver_a_en[0];  //ANA_GEN_REG_2[0]; 
assign D2A_DRIVERA_CSAMP_EN_CH1 = ANA_ENABLE_REG_1[1];
assign D2A_COMP_EN_CH1          = ANA_ENABLE_REG_1[2];
assign D2A_IDAC_EN_CH1          = ANA_ENABLE_REG_1[3];
assign D2A_VDAC_EN_CH1          = ANA_ENABLE_REG_1[4];
// assign D2A_STIMU0_COMP_EN       = ANA_ENABLE_REG_1[5];
// assign D2A_STIMU1_COMP_EN       = ANA_ENABLE_REG_1[6];
assign D2A_STIMU_COMP_EN_CH1    = ANA_ENABLE_REG_1[5];
assign D2A_STIMU_COMP_SEL_CH1   = ANA_ENABLE_REG_1[6];
assign D2A_LEAD_OFF_SEL_SA_SB_CH1 = ANA_GEN_REG_3[5];
//assign D2A_VDAC_DIN_CH1         = (pinmux_if.D2A_ATM[4] & (spi_ana_if.ATM_HC_SEL == 1'b0)) ? 12'hFFF : {ANA_GEN_REG_3[3:0], ANA_GEN_REG_2};
assign D2A_VDAC_DIN_CH1         = {ANA_GEN_REG_3[3:0], ANA_GEN_REG_2};
assign D2A_CS_TRIM_CH1          = {D2A_TRIM4_SIG[7], D2A_TRIM4_SIG[4:3]};

// WG_CH1
assign D2A_DRIVERA_SOURCEA_CH1  = i_source_driver[0];    //ANA_GEN_REG_2[1]; 
//assign D2A_DRIVERA_SOURCEB_CH1  = i_sourceb_driver_a[0];    //ANA_GEN_REG_2[2]; 
assign D2A_DRIVERA_PULLDA_CH1   = i_pulldn_driver[0];     //ANA_GEN_REG_2[3]; 
//assign D2A_DRIVERA_PULLDB_CH1   = i_pulldb_driver_a[0];     //ANA_GEN_REG_2[4]; 
assign D2A_IDAC_DIN_CH1         = i_out_wave_driver_idac[0];  //{ANA_GEN_REG_6, ANA_GEN_REG_5};

// PUMP_CH1
assign D2A_PUMP_CLK_TRIM_CH1    = D2A_TRIM4_SIG[5];
assign D2A_PUMP_5V_EN_CH1       = ANA_ENABLE_REG_0[2];
assign D2A_PUMP_LDO_EN_CH1      = ANA_ENABLE_REG_0[3];
assign D2A_LDO2P8_PUMP_TRIM_CH1 = D2A_TRIM2_SIG[5:4];
assign D2A_LDO1P8_LDO2P8_CH1_SEL = D2A_ANA_OUT_SEL2;


//DRIVERA_CH2
assign D2A_VDAC_VTRIM_CH2       = D2A_TRIM5_SIG[2:0];
assign D2A_CS_EN_CH_CH2         = ANA_ENABLE_REG_2[0]; //i_driver_driver_a_en[1];  //ANA_GEN_REG_A[0]
assign D2A_DRIVERA_CSAMP_EN_CH2 = ANA_ENABLE_REG_2[1];
assign D2A_COMP_EN_CH2          = ANA_ENABLE_REG_2[2];
assign D2A_IDAC_EN_CH2          = ANA_ENABLE_REG_2[3];
assign D2A_VDAC_EN_CH2          = ANA_ENABLE_REG_2[4];
// assign D2A_STIMU2_COMP_EN       = ANA_ENABLE_REG_2[5];
// assign D2A_STIMU3_COMP_EN       = ANA_ENABLE_REG_2[6];
assign D2A_STIMU_COMP_EN_CH2    = ANA_ENABLE_REG_2[5];
assign D2A_STIMU_COMP_SEL_CH2   = ANA_ENABLE_REG_2[6];
assign D2A_LEAD_OFF_SEL_SA_SB_CH2 = ANA_GEN_REG_5[5];
//assign D2A_VDAC_DIN_CH2         = (pinmux_if.D2A_ATM[5] & (spi_ana_if.ATM_HC_SEL == 1'b0)) ? 12'hFFF : {ANA_GEN_REG_5[3:0], ANA_GEN_REG_4};
assign D2A_VDAC_DIN_CH2         = {ANA_GEN_REG_5[3:0], ANA_GEN_REG_4};
assign D2A_CS_TRIM_CH2          = {D2A_TRIM5_SIG[7], D2A_TRIM5_SIG[4:3]};


// FROM WG
assign D2A_DRIVERA_SOURCEA_CH2  = i_source_driver[1];    //ANA_GEN_REG_A[1]
//assign D2A_DRIVERA_SOURCEB_CH2  = i_sourceb_driver_a[1];    //ANA_GEN_REG_A[2]
assign D2A_DRIVERA_PULLDA_CH2   = i_pulldn_driver[1];     //ANA_GEN_REG_A[3]
//assign D2A_DRIVERA_PULLDB_CH2   = i_pulldb_driver_a[1];     //ANA_GEN_REG_A[4]
assign D2A_IDAC_DIN_CH2         = i_out_wave_driver_idac[1];  //{ANA_GEN_REG_E, ANA_GEN_REG_D};

// PUMP_CH2
assign D2A_PUMP_CLK_TRIM_CH2    = D2A_TRIM4_SIG[6];
assign D2A_PUMP_5V_EN_CH2       = ANA_ENABLE_REG_0[4];
assign D2A_PUMP_LDO_EN_CH2      = ANA_ENABLE_REG_0[5];
assign D2A_LDO2P8_PUMP_TRIM_CH2 = D2A_TRIM5_SIG[6:5];

//TSC
assign D2A_TSC_TRIM_CH1         = D2A_TRIM6_SIG[6:3];
assign D2A_IREF_TSC_OUT_SEL     = D2A_ANA_OUT_SEL1;
assign D2A_IDAC_TSC_COMP_OUT_SEL = D2A_ANA_OUT_SEL6;
assign D2A_VDAC8B_DIN_CH1       = pinmux_if.d2a_tsc_vdac8b_din_ch1;
assign D2A_VDAC8B_EN_CH1        = pinmux_if.d2a_tsc_vdac8b_en_ch1;
assign D2A_TSC_COMP_EN_CH1      = pinmux_if.d2a_tsc_comp_en_ch1;
assign D2A_TSC_EN_CH1           = pinmux_if.d2a_tsc_en_ch1;

//NIRS
assign D2A_NIRS_EN              = ana_nirs_if.D2A_NIRS_EN;
assign D2A_NIRS_RESET_SW        = ana_nirs_if.D2A_NIRS_RESET_SW;
assign D2A_NIRS_IPD_SW          = ana_nirs_if.D2A_NIRS_IPD_SW;
assign D2A_NIRS_IIN_SW          = ana_nirs_if.D2A_NIRS_IIN_SW;
assign D2A_NIRS_IDAC            = ana_nirs_if.D2A_NIRS_IDAC;
assign D2A_NIRS_RATIO           = ana_nirs_if.D2A_NIRS_RATIO;
assign ana_nirs_if.A2D_NIRS_IREFCOARSE  = A2D_NIRS_IREFCOARSE;
assign ana_nirs_if.A2D_NIRS_IREFFINE    = A2D_NIRS_IREFFINE;


ENS2_ANA_CHIP u_top_ana (
`ifdef FPGA
  .clk_in1              (clk_in1)
`endif

  //bps imeas
    .A2D_SDM_OUT0(A2D_SDM_OUT0),
        .A2D_SDM_OUT1(A2D_SDM_OUT1),
        .A2D_SDM_OUT2(A2D_SDM_OUT2),
        .A2D_SDM_OUT3(A2D_SDM_OUT3),
        .A2D_SDM_OUT4(A2D_SDM_OUT4),
        .A2D_SDM_OUT5(A2D_SDM_OUT5),
        .A2D_SDM_OUT6(A2D_SDM_OUT6),
        .A2D_SDM_OUT7(A2D_SDM_OUT7),
        .A2D_SDM_OUT8(A2D_SDM_OUT8),
        .A2D_SDM_OUT9(A2D_SDM_OUT9),
        .A2D_SDM_OUT10(A2D_SDM_OUT10),
        .A2D_SDM_OUT11(A2D_SDM_OUT11),
        .A2D_SDM_OUT12(A2D_SDM_OUT12),
        .A2D_SDM_OUT13(A2D_SDM_OUT13),
        .A2D_SDM_OUT14(A2D_SDM_OUT14),
        .A2D_SDM_OUT15(A2D_SDM_OUT15),
        .D2A_SDM_CLK(D2A_SDM_CLK),

/*
  .A2D_external_en_I  (A2D_external_en_I),
  .A2D_Wake_UP_i      (A2D_Wake_UP_i),
  .VDD_DIG_SW         (VDD_DIG_SW),
  .A2D_COMP0          (A2D_COMP0),
  .A2D_COMP1          (A2D_COMP1),
*/
  .VDDIO                  (VDDIO),

  //CURRENT
  .A2D_CLK2MHZ              (A2D_CLK2MHZ),
  .A2D_LVD                  (A2D_LVD),
  .A2D_POR_DVDD             (A2D_POR_DVDD),
  .A2D_COMP_OUT_CH1         (A2D_COMP_OUT_CH1_tmp),
  .A2D_COMP_OUT_CH2         (A2D_COMP_OUT_CH2_tmp),
  .VDD_DIG                  (VDD_DIG),
  .VSS_DIG                  (VSS_DIG),
  //.AVDD                     (AVDD),

  //PMU
  .D2A_BG_TRIM              (D2A_BG_TRIM),
  .D2A_IREF_TRIM            (D2A_IREF_TRIM),
  .D2A_CLDO1P8_TRIM         (D2A_CLDO1P8_TRIM),
  .D2A_LVD_EN               (D2A_LVD_EN),
  .D2A_LVD_SEL              (D2A_LVD_SEL),
  .D2A_IBIAS_IDAC_TRIM      (D2A_IBIAS_IDAC_TRIM),

  //OSC
  .D2A_OSC2MHZ_TRIM         (D2A_OSC2MHZ_TRIM),
  .D2A_OSC2MHZEN            (D2A_OSC2MHZEN),
  .D2A_CS_PGA_CLK_TRIM      (D2A_CS_PGA_CLK_TRIM),

  //HPF
//.D2A_HPF_EN		            (D2A_HPF_EN),
//.D2A_HPF_ISEL             (D2A_HPF_ISEL),

  //BIST
  .D2A_BIST_EN              (D2A_BIST_EN),
  .D2A_BIST_SEL             (D2A_BIST_SEL),

  //DRIVERA_CH1
  .D2A_VDAC_VTRIM_CH1       (D2A_VDAC_VTRIM_CH1),
  .D2A_CS_EN_CH_CH1         (D2A_CS_EN_CH_CH1),
  .D2A_DRIVERA_CSAMP_EN_CH1 (D2A_DRIVERA_CSAMP_EN_CH1),
  .D2A_COMP_EN_CH1          (D2A_COMP_EN_CH1),
  .D2A_IDAC_EN_CH1          (D2A_IDAC_EN_CH1),
  .D2A_VDAC_EN_CH1          (D2A_VDAC_EN_CH1),
  .D2A_VDAC_DIN_CH1         (D2A_VDAC_DIN_CH1),
  .D2A_CS_TRIM_CH1          (D2A_CS_TRIM_CH1),
  .D2A_LEAD_OFF_SEL_SA_SB_CH1 (D2A_LEAD_OFF_SEL_SA_SB_CH1),

  //WG_CH1
  .D2A_DRIVERA_SOURCEA_CH1  (D2A_DRIVERA_SOURCEA_CH1),
  .D2A_DRIVERA_SOURCEB_CH1  (D2A_DRIVERA_SOURCEB_CH1),
  .D2A_DRIVERA_PULLDA_CH1   (D2A_DRIVERA_PULLDA_CH1),
  .D2A_DRIVERA_PULLDB_CH1   (D2A_DRIVERA_PULLDB_CH1),
  .D2A_IDAC_DIN_CH1         (D2A_IDAC_DIN_CH1),

  .D2A_STIMU_COMP_SEL_CH1   (D2A_STIMU_COMP_SEL_CH1),
  .D2A_STIMU_COMP_EN_CH1    (D2A_STIMU_COMP_EN_CH1),
  .A2D_COMP_OUT_STIMU0_1    (A2D_COMP_OUT_STIMU0_1),

  //PUMP_CH1
  .D2A_PUMP_CLK_TRIM_CH1    (D2A_PUMP_CLK_TRIM_CH1),
  .D2A_PUMP_5V_EN_CH1       (D2A_PUMP_5V_EN_CH1),
  .D2A_PUMP_LDO_EN_CH1      (D2A_PUMP_LDO_EN_CH1),
  .D2A_LDO2P8_PUMP_TRIM_CH1 (D2A_LDO2P8_PUMP_TRIM_CH1),
  .D2A_LDO1P8_LDO2P8_CH1_SEL (D2A_LDO1P8_LDO2P8_CH1_SEL),

  //DRIVERA_CH2
  .D2A_VDAC_VTRIM_CH2       (D2A_VDAC_VTRIM_CH2),
  .D2A_CS_EN_CH_CH2         (D2A_CS_EN_CH_CH2),
  .D2A_DRIVERA_CSAMP_EN_CH2 (D2A_DRIVERA_CSAMP_EN_CH2),
  .D2A_COMP_EN_CH2          (D2A_COMP_EN_CH2),
  .D2A_IDAC_EN_CH2          (D2A_IDAC_EN_CH2),
  .D2A_VDAC_EN_CH2          (D2A_VDAC_EN_CH2),
  .D2A_VDAC_DIN_CH2         (D2A_VDAC_DIN_CH2),
  .D2A_CS_TRIM_CH2          (D2A_CS_TRIM_CH2),
  .D2A_LEAD_OFF_SEL_SA_SB_CH2 (D2A_LEAD_OFF_SEL_SA_SB_CH2),

  //WG_CH2
  .D2A_DRIVERA_SOURCEA_CH2  (D2A_DRIVERA_SOURCEA_CH2),
  .D2A_DRIVERA_SOURCEB_CH2  (D2A_DRIVERA_SOURCEB_CH2),
  .D2A_DRIVERA_PULLDA_CH2   (D2A_DRIVERA_PULLDA_CH2),
  .D2A_DRIVERA_PULLDB_CH2   (D2A_DRIVERA_PULLDB_CH2),
  .D2A_IDAC_DIN_CH2         (D2A_IDAC_DIN_CH2),

  .D2A_STIMU_COMP_SEL_CH2   (D2A_STIMU_COMP_SEL_CH2),
  .D2A_STIMU_COMP_EN_CH2    (D2A_STIMU_COMP_EN_CH2),
  .A2D_COMP_OUT_STIMU2_3    (A2D_COMP_OUT_STIMU2_3),

  //PUMP_CH2
  .D2A_PUMP_CLK_TRIM_CH2    (D2A_PUMP_CLK_TRIM_CH2),
  .D2A_PUMP_5V_EN_CH2       (D2A_PUMP_5V_EN_CH2),
  .D2A_PUMP_LDO_EN_CH2      (D2A_PUMP_LDO_EN_CH2),
  .D2A_LDO2P8_PUMP_TRIM_CH2 (D2A_LDO2P8_PUMP_TRIM_CH2),

//.ATM                      (ATM),
  .D2A_ATM0                 (D2A_ATM0), 
  .D2A_ATM1                 (D2A_ATM1), 
  .D2A_ATM2                 (D2A_ATM2), 
  .D2A_ATM3                 (D2A_ATM3), 
  .D2A_ATM4                 (D2A_ATM4), 
  .D2A_ATM5                 (D2A_ATM5),
  .D2A_ATM6                 (D2A_ATM6), 
  .D2A_ATM7                 (D2A_ATM7),

//SPARE
  .D2A_SPI_SPARE0           (ANA_GEN_REG_6),
  .D2A_SPI_SPARE1           (ANA_GEN_REG_7),
  .D2A_SPI_SPARE2           (ANA_GEN_REG_8),
  .D2A_SPI_SPARE3           (ANA_GEN_REG_9),

  .D2A_BIST_SPARE_3         (D2A_ANA_OUT_SEL3),
  .D2A_BIST_SPARE_4         (D2A_ANA_OUT_SEL4),
  .D2A_BIST_SPARE_5         (D2A_ANA_OUT_SEL5),
  .D2A_BIST_SPARE_7         (D2A_ANA_OUT_SEL7),

  .D2A_TRIM0_SIG_SPARE      (D2A_TRIM0_SIG_SPARE),
  
  .A2D_SPARE_RO_REG_0       (A2D_SPARE_RO_REG_0_tmp),

// TSC
  .A2D_TSC_COMP_OUT_CH1     (A2D_TSC_COMP_OUT_CH1_tmp),
  .D2A_TSC_TRIM_CH1         (D2A_TSC_TRIM_CH1),   
  .D2A_IREF_TSC_OUT_SEL     (D2A_IREF_TSC_OUT_SEL),
  .D2A_IDAC_TSC_COMP_OUT_SEL(D2A_IDAC_TSC_COMP_OUT_SEL),        
  .D2A_TSC_EN_CH1           (D2A_TSC_EN_CH1),           
  .D2A_TSC_COMP_EN_CH1      (D2A_TSC_COMP_EN_CH1),            
  .D2A_VDAC8B_EN_CH1        (D2A_VDAC8B_EN_CH1),            
  .D2A_VDAC8B_DIN_CH1       (D2A_VDAC8B_DIN_CH1),

  .D2A_NIRS_RESET_SW        (D2A_NIRS_RESET_SW[0]),
  .D2A_NIRS_ILED_SW         (D2A_NIRS_IPD_SW[0]),
  .D2A_NIRS_IIN_SW          (D2A_NIRS_IIN_SW[0]),
  .D2A_NIRS_IDAC            (D2A_NIRS_IDAC[0]),
  .D2A_NIRS_IREFCOARSE      (), //TRIM signal - name will be changed
  .D2A_NIRS_RATIO           (D2A_NIRS_RATIO[0]),
  .A2D_NIRS_IREFCOARSE      (A2D_NIRS_IREFCOARSE[0]),
  .A2D_NIRS_IREFFINE        (A2D_NIRS_IREFFINE[0])

);

endmodule
