// Library - YJT_GC2, Cell - ENS3, View - schematic
// LAST TIME SAVED: Oct 26 16:29:17 2022
// NETLIST TIME: Oct 26 16:31:54 2022
`timescale 1ns / 1ns 

module ENS2_ANA_CHIP ( 

`ifdef FPGA
  clk_in1,
`endif

  	A2D_SDM_OUT0,
        A2D_SDM_OUT1,
        A2D_SDM_OUT2,
        A2D_SDM_OUT3,
        A2D_SDM_OUT4,
        A2D_SDM_OUT5,
        A2D_SDM_OUT6,
        A2D_SDM_OUT7,
  A2D_SDM_OUT8,
  A2D_SDM_OUT9,
  A2D_SDM_OUT10,
  A2D_SDM_OUT11,
  A2D_SDM_OUT12,
  A2D_SDM_OUT13,
  A2D_SDM_OUT14,
  A2D_SDM_OUT15,

        D2A_SDM_CLK,


  // REMOVE THIS
  // A2D_external_en_I, A2D_Wake_UP_i, VDD_DIG_SW, A2D_COMP0, A2D_COMP1,

  VDDIO,  //Ross add for chip_en
  //AVDD,
  A2D_CLK2MHZ, A2D_COMP_OUT_CH1, A2D_COMP_OUT_CH2,
  A2D_COMP_OUT_STIMU0_1, A2D_COMP_OUT_STIMU2_3, A2D_LVD,
  A2D_POR_DVDD, A2D_SPARE_RO_REG_0, VDD_DIG, VSS_DIG, D2A_ATM0,
  D2A_ATM1, D2A_ATM2, D2A_ATM3, D2A_ATM4, D2A_ATM5, D2A_ATM6,
  D2A_ATM7, D2A_BG_TRIM, D2A_BIST_EN, D2A_BIST_SEL,
  D2A_CLDO1P8_TRIM, D2A_COMP_EN_CH1, D2A_COMP_EN_CH2,
  D2A_CS_EN_CH_CH1,
  D2A_CS_EN_CH_CH2, D2A_CS_TRIM_CH1, D2A_CS_TRIM_CH2,
  D2A_DRIVERA_CSAMP_EN_CH1, D2A_DRIVERA_CSAMP_EN_CH2,
  D2A_DRIVERA_PULLDA_CH1, D2A_DRIVERA_PULLDA_CH2,
  D2A_DRIVERA_PULLDB_CH1, D2A_DRIVERA_PULLDB_CH2,
  D2A_DRIVERA_SOURCEA_CH1, D2A_DRIVERA_SOURCEA_CH2,
  D2A_DRIVERA_SOURCEB_CH1, D2A_DRIVERA_SOURCEB_CH2,
  D2A_IBIAS_IDAC_TRIM, D2A_IDAC_DIN_CH1, D2A_IDAC_DIN_CH2,
  D2A_IDAC_EN_CH1, D2A_IDAC_EN_CH2, D2A_IREF_TRIM, D2A_LVD_EN,
  D2A_LVD_SEL, D2A_OSC2MHZEN, D2A_OSC2MHZ_TRIM, D2A_SPI_SPARE0,
  D2A_SPI_SPARE1, D2A_SPI_SPARE2, D2A_SPI_SPARE3,
  D2A_STIMU_COMP_EN_CH1, D2A_STIMU_COMP_EN_CH2,
  D2A_STIMU_COMP_SEL_CH1, D2A_STIMU_COMP_SEL_CH2,
  D2A_TRIM0_SIG_SPARE, D2A_VDAC_DIN_CH1, D2A_VDAC_DIN_CH2,
  D2A_VDAC_EN_CH1, D2A_VDAC_EN_CH2, D2A_VDAC_VTRIM_CH1,
  D2A_VDAC_VTRIM_CH2,

  D2A_PUMP_CLK_TRIM_CH1, D2A_PUMP_CLK_TRIM_CH2,
  D2A_PUMP_5V_EN_CH1, D2A_PUMP_5V_EN_CH2,
  D2A_PUMP_LDO_EN_CH1, D2A_PUMP_LDO_EN_CH2,
  D2A_LDO2P8_PUMP_TRIM_CH1, D2A_LDO2P8_PUMP_TRIM_CH2,
  D2A_LDO1P8_LDO2P8_CH1_SEL, 

  A2D_TSC_COMP_OUT_CH1, D2A_TSC_EN_CH1, D2A_TSC_TRIM_CH1, 
  D2A_IREF_TSC_OUT_SEL ,D2A_IDAC_TSC_COMP_OUT_SEL,
  D2A_TSC_COMP_EN_CH1, D2A_VDAC8B_EN_CH1, D2A_VDAC8B_DIN_CH1,
  D2A_LEAD_OFF_SEL_SA_SB_CH1, D2A_LEAD_OFF_SEL_SA_SB_CH2,
  D2A_CS_PGA_CLK_TRIM,

  D2A_BIST_SPARE_3,
  D2A_BIST_SPARE_4,
  D2A_BIST_SPARE_5,
  D2A_BIST_SPARE_7,

  D2A_NIRS_RESET_SW,
  D2A_NIRS_ILED_SW,
  D2A_NIRS_IIN_SW,
  D2A_NIRS_IDAC,
  D2A_NIRS_IREFCOARSE,
  D2A_NIRS_RATIO,
  A2D_NIRS_IREFCOARSE,
  A2D_NIRS_IREFFINE
);


`ifdef FPGA
        input clk_in1;
`endif

output  A2D_SDM_OUT0;
output  A2D_SDM_OUT1;
output  A2D_SDM_OUT2;
output  A2D_SDM_OUT3;
output  A2D_SDM_OUT4;
output  A2D_SDM_OUT5;
output  A2D_SDM_OUT6;
output  A2D_SDM_OUT7;
output  A2D_SDM_OUT8;
output  A2D_SDM_OUT9;
output  A2D_SDM_OUT10;
output  A2D_SDM_OUT11;
output  A2D_SDM_OUT12;
output  A2D_SDM_OUT13;
output  A2D_SDM_OUT14;
output  A2D_SDM_OUT15;

input   D2A_SDM_CLK;


// output  A2D_external_en_I;
// output  A2D_Wake_UP_i;
// inout   VDD_DIG_SW;
// output	A2D_COMP0;
// output	A2D_COMP1;


//CURRENT
output  A2D_CLK2MHZ;        //A2D_OSC_OUT
output  A2D_LVD;
output  A2D_POR_DVDD;       //A2D_SW_POWER_POR || A2D_VDDI_POR (ALWAYS ON)
output  A2D_COMP_OUT_CH1;   //A2D_COMP0
output  A2D_COMP_OUT_CH2;   //A2D_COMP1
inout   VDDIO;
inout   VDD_DIG;
inout   VSS_DIG;
//inout   AVDD;

//PMU
input  [7:0] D2A_BG_TRIM;
input  [7:0] D2A_IREF_TRIM;
input  [4:0] D2A_CLDO1P8_TRIM;
input        D2A_LVD_EN;
input  [2:0] D2A_LVD_SEL;
input  [3:0] D2A_IBIAS_IDAC_TRIM;

//OSC
input  [7:0] D2A_OSC2MHZ_TRIM;
input        D2A_OSC2MHZEN;
input        D2A_CS_PGA_CLK_TRIM;

//BIST
input        D2A_BIST_EN;
input  [3:0] D2A_BIST_SEL;

//HPF
//input        D2A_HPF_EN;
//input        D2A_HPF_ISEL;

//DRIVERA_CH1
input  [2:0] D2A_VDAC_VTRIM_CH1;
input        D2A_CS_EN_CH_CH1;
input        D2A_DRIVERA_SOURCEA_CH1;
input        D2A_DRIVERA_SOURCEB_CH1;
input        D2A_DRIVERA_PULLDA_CH1;
input        D2A_DRIVERA_PULLDB_CH1;
input        D2A_COMP_EN_CH1;
input        D2A_IDAC_EN_CH1;
input [11:0] D2A_IDAC_DIN_CH1;
input        D2A_VDAC_EN_CH1;
input [11:0] D2A_VDAC_DIN_CH1;  // [11:0] <- CHECK
input        D2A_DRIVERA_CSAMP_EN_CH1;
input        D2A_STIMU_COMP_SEL_CH1;
input        D2A_STIMU_COMP_EN_CH1;
input  [2:0] D2A_CS_TRIM_CH1;
input        D2A_LEAD_OFF_SEL_SA_SB_CH1;
input        D2A_PUMP_CLK_TRIM_CH1;
input        D2A_PUMP_5V_EN_CH1;
input        D2A_PUMP_LDO_EN_CH1;
input  [1:0] D2A_LDO2P8_PUMP_TRIM_CH1;
input        D2A_LDO1P8_LDO2P8_CH1_SEL;

output       A2D_COMP_OUT_STIMU0_1;

//DRIVERA_CH2
input  [2:0] D2A_VDAC_VTRIM_CH2;
input        D2A_CS_EN_CH_CH2;
input        D2A_DRIVERA_SOURCEA_CH2;
input        D2A_DRIVERA_SOURCEB_CH2;
input        D2A_DRIVERA_PULLDA_CH2;
input        D2A_DRIVERA_PULLDB_CH2;
input        D2A_COMP_EN_CH2;
input        D2A_IDAC_EN_CH2;
input [11:0] D2A_IDAC_DIN_CH2;
input        D2A_VDAC_EN_CH2;
input [11:0] D2A_VDAC_DIN_CH2; // [11:0] <- CHECK
input        D2A_DRIVERA_CSAMP_EN_CH2;
input        D2A_STIMU_COMP_SEL_CH2;
input        D2A_STIMU_COMP_EN_CH2;
input  [2:0] D2A_CS_TRIM_CH2;
input        D2A_LEAD_OFF_SEL_SA_SB_CH2;
input        D2A_PUMP_CLK_TRIM_CH2;
input        D2A_PUMP_5V_EN_CH2;
input        D2A_PUMP_LDO_EN_CH2;
input  [1:0] D2A_LDO2P8_PUMP_TRIM_CH2;

output       A2D_COMP_OUT_STIMU2_3;

input        D2A_ATM0;
input        D2A_ATM1;
input        D2A_ATM2;
input        D2A_ATM3;
input        D2A_ATM4;
input        D2A_ATM5;
input        D2A_ATM6;
input        D2A_ATM7;

//SPARE
input  [7:0] D2A_SPI_SPARE0;
input  [7:0] D2A_SPI_SPARE1;
input  [7:0] D2A_SPI_SPARE2;
input  [7:0] D2A_SPI_SPARE3;

input        D2A_BIST_SPARE_3;
input        D2A_BIST_SPARE_4;
input        D2A_BIST_SPARE_5;
input        D2A_BIST_SPARE_7;

input  [7:0] D2A_TRIM0_SIG_SPARE;
//input  [7:0] D2A_TRIM1_SIG_SPARE;
// input  [7:0] D2A_TRIM2_SIG_SPARE;
// input  [7:0] D2A_TRIM3_SIG_SPARE;
// input  [7:0] D2A_TRIM4_SIG_SPARE;

output [7:0] A2D_SPARE_RO_REG_0;

// TSC
output       A2D_TSC_COMP_OUT_CH1;
input  [3:0] D2A_TSC_TRIM_CH1;
input        D2A_IREF_TSC_OUT_SEL;
input        D2A_IDAC_TSC_COMP_OUT_SEL;
input        D2A_TSC_EN_CH1;
input        D2A_TSC_COMP_EN_CH1;
input        D2A_VDAC8B_EN_CH1;
input  [7:0] D2A_VDAC8B_DIN_CH1;

//NIRS
input         D2A_NIRS_RESET_SW;
input         D2A_NIRS_ILED_SW;
input         D2A_NIRS_IIN_SW;
input  [8:0]  D2A_NIRS_IDAC;
input  [1:0]  D2A_NIRS_IREFCOARSE;
input  [1:0]  D2A_NIRS_RATIO;
output        A2D_NIRS_IREFCOARSE;
output        A2D_NIRS_IREFFINE;

`ifndef MIX_SIM_EN

`ifdef ATPG_PATTERNS
initial begin
  //provided externally. analog should be off during scan test
  force VDD_DIG = 1'b1;
  force VSS_DIG = 1'b0;
end

`else

`ifndef ATPG_SIM
assign (pull1,pull0) A2D_COMP_OUT_CH1       = '0; 
assign (pull1,pull0) A2D_COMP_OUT_CH2       = '0; 
assign (pull1,pull0) A2D_COMP_OUT_STIMU0_1  = '0;
assign (pull1,pull0) A2D_COMP_OUT_STIMU2_3  = '0;
assign (pull1,pull0) A2D_LVD                = '0;
assign (pull1,pull0) A2D_SPARE_RO_REG_0     = '0;

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
assign A2D_CLK2MHZ = k256_clk;
`else
 wire [10:0]  hfosc_rcal ;

 wire         A2D_CLK2MHZ_int;
 assign A2D_CLK2MHZ = D2A_OSC2MHZEN && A2D_CLK2MHZ_int;

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
 assign A2D_POR_DVDD = por_resetn_pll;

`else
/*
 pmu_analog PMU_SW (
    .VDD_SW(),
    //.wakeup(),
    .VDD_DIG(VDD_DIG),
    .por_resetn            (  A2D_POR_DVDD              ),
    .cp_en                 (                     ),
    .bat_off               (                   )
  );  
*/
  pmu_analog PMU_SW (
    .POR      (A2D_POR_DVDD)
    //.CHIP_EN  (1'b1)
  );  


 pmu_analog_always_on PMU_ALW_ON (
    .VDD(VDDIO),
    .por_resetn            (  A2D_VDDI_POR    )
  ); 
`endif

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

`ifndef SOC_ATPG_EN
  assign A2D_COMP_OUT_CH1 = `SOC_TB.dut_vif.lead_off_comp_reverse ? (loff_short_ch2.comp_pol_high ? !A2D_COMP_OUT_CH2_tmp : A2D_COMP_OUT_CH2_tmp) : (loff_short_ch1.comp_pol_high ? !A2D_COMP_OUT_CH1_tmp : A2D_COMP_OUT_CH1_tmp);
  assign A2D_COMP_OUT_CH2 = `SOC_TB.dut_vif.lead_off_comp_reverse ? (loff_short_ch1.comp_pol_high ? !A2D_COMP_OUT_CH1_tmp : A2D_COMP_OUT_CH1_tmp) : (loff_short_ch2.comp_pol_high ? !A2D_COMP_OUT_CH2_tmp : A2D_COMP_OUT_CH2_tmp);
`endif

// LVD Instantiation
lvd_model lvd_circuit (
.LVD_EN(D2A_LVD_EN), 
.LVD_SEL(D2A_LVD_SEL), 
.ANA_LVD(A2D_LVD)
);

// TSC Monitoring for channel 1 Instantiation
tsc_monitoring_model tsc_monitoring_ch1 (
.D2A_TSC_COMP_EN_CHx(D2A_TSC_COMP_EN_CH1), 
.D2A_TSC_EN_CHx(D2A_TSC_EN_CH1), 
.D2A_TSC_TRIM_CHx(D2A_TSC_TRIM_CH1[2:0]), // connect 3-bit only 
.D2A_VDAC8B_EN_CHx(D2A_VDAC8B_EN_CH1), 
.D2A_VDAC8B_DIN_CHx(D2A_VDAC8B_DIN_CH1), 
.A2D_TSC_COMP_OUT_CHx(A2D_TSC_COMP_OUT_CH1)
);

// NIRS VIP Instantiation
ppg_nirs_model nirs_model(
  .D2A_NIRS_RESET_SW(D2A_NIRS_RESET_SW),      // 1-bit from DIG
  .D2A_NIRS_ILED_SW(D2A_NIRS_ILED_SW),       // 1-bit SW1  from DIG
  .D2A_NIRS_IIN_SW(D2A_NIRS_IIN_SW),        // 1-bit from DIG 
  .D2A_NIRS_IDAC(D2A_NIRS_IDAC),          // 9-bit from DIG
  .D2A_NIRS_IREFCOARSE(D2A_NIRS_IREFCOARSE),    // 2-bit from DIG 
  .D2A_NIRS_RATIO(D2A_NIRS_RATIO),         // 2-bit from DIG  
  .A2D_NIRS_IREFCOARSE(A2D_NIRS_IREFCOARSE),    // 1-bit SW2
  .A2D_NIRS_IREFFINE(A2D_NIRS_IREFFINE)       // 1-bit SW3 
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
        .adc_clk(D2A_SDM_CLK),
        .nrst(A2D_POR_DVDD),
        //.imeas_sd16off(imeas_sd16off),
        //.imeas_sd16slp(imeas_sd16slp),
        //.imeas_adc_in(imeas_adc_din)
        .imeas_adc_in(A2D_SDM_OUT0)
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
        .adc_clk(D2A_SDM_CLK),
        .nrst(A2D_POR_DVDD),
        .imeas_adc_in(A2D_SDM_OUT1)
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
        .adc_clk(D2A_SDM_CLK),
        .nrst(A2D_POR_DVDD),
        .imeas_adc_in(A2D_SDM_OUT2)
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
        .adc_clk(D2A_SDM_CLK),
        .nrst(A2D_POR_DVDD),
        .imeas_adc_in(A2D_SDM_OUT3)
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
        .adc_clk(D2A_SDM_CLK),
        .nrst(A2D_POR_DVDD),
        .imeas_adc_in(A2D_SDM_OUT4)
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
        .adc_clk(D2A_SDM_CLK),
        .nrst(A2D_POR_DVDD),
        .imeas_adc_in(A2D_SDM_OUT5)
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
        .adc_clk(D2A_SDM_CLK),
        .nrst(A2D_POR_DVDD),
        .imeas_adc_in(A2D_SDM_OUT6)
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
        .adc_clk(D2A_SDM_CLK),
        .nrst(A2D_POR_DVDD),
        .imeas_adc_in(A2D_SDM_OUT7)
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
        .adc_clk(D2A_SDM_CLK),
        .nrst(A2D_POR_DVDD),
        .imeas_adc_in(A2D_SDM_OUT8)
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
        .adc_clk(D2A_SDM_CLK),
        .nrst(A2D_POR_DVDD),
        .imeas_adc_in(A2D_SDM_OUT9)
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
        .adc_clk(D2A_SDM_CLK),
        .nrst(A2D_POR_DVDD),
        .imeas_adc_in(A2D_SDM_OUT10)
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
        .adc_clk(D2A_SDM_CLK),
        .nrst(A2D_POR_DVDD),
        .imeas_adc_in(A2D_SDM_OUT11)
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
        .adc_clk(D2A_SDM_CLK),
        .nrst(A2D_POR_DVDD),
        .imeas_adc_in(A2D_SDM_OUT12)
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
        .adc_clk(D2A_SDM_CLK),
        .nrst(A2D_POR_DVDD),
        .imeas_adc_in(A2D_SDM_OUT13)
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
        .adc_clk(D2A_SDM_CLK),
        .nrst(A2D_POR_DVDD),
        .imeas_adc_in(A2D_SDM_OUT14)
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
        .adc_clk(D2A_SDM_CLK),
        .nrst(A2D_POR_DVDD),
        .imeas_adc_in(A2D_SDM_OUT15)
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
