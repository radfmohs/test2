//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap ENS2  
// Module Name : top chip module  
// Description : 
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Design
//------------------------------------------------------------------------------
// 0.1          07/2021   Mohsen Radfar   Initial Rev
//------------------------------------------------------------------------------

 `timescale 1 ns /  1ps

module Nanochap_ENS2  (
  // digital power ground pads
`ifdef FPGA 
  input wire        clk_in1,
  inout wire [10:0] IOBUF_PAD     //xin might change
`else
  inout wire        VPP,          //Supriya:22/03/2024:ENS2 pending to check with Xin
  inout wire        VDDIO,        //Supriya:22/03/2024:ENS2 pending to check with Xin
  inout wire        VSSIO,        //Supriya:22/03/2024:ENS2 pending to check with Xin
  inout wire        VDD_DIG,      //Supriya:22/03/2024:ENS2 pending to check with Xin
//inout wire        VDD_DIG_SW,   //Supriya:22/03/2024:ENS2 pending to check with Xin 
//inout wire        DVSS_1P5_ANA,
//inout wire        VDD_DIG_AO,   //Supriya:22/03/2024:ENS2 pending to check with Xin
  inout wire        VSS_DIG,      //Supriya:22/03/2024:ENS2 pending to check with Xin
//inout wire        VSS_DIG_AO,   //Supriya:22/03/2024:ENS2 pending to check with Xin  
// digital data/clk pads
  inout wire [10:0] IOBUF_PAD,
//inout wire        CLK,          //Supriya:22/03/2024:ENS2 pending to check with Xin
  input wire        CLKSEL,
//added by supriya
  input wire        iopad_testmode0,
  input wire        iopad_testmode1,
  input wire        RESETn   
`endif
);

  //wire        AVDD;
  wire        A2D_COMP1;
  wire        A2D_COMP2;
//wire        A2D_COMP_OUT_STIMU0;
//wire        A2D_COMP_OUT_STIMU1;
//wire        A2D_COMP_OUT_STIMU2;
//wire        A2D_COMP_OUT_STIMU3;
  
  wire        DVDD_1P5_ANA;
//with OSC
//wire        cpoln_y;
//wire        cpha_y;
//with OSC
  wire        A2D_OSC_OUT;
//with PMU
  wire        A2D_SW_POWER_POR;    //??? //V
  wire        A2D_VDDI_POR;  //V
  wire [10:0] IOBUF_CS;
  wire [10:0] IOBUF_SR;
  wire [10:0] IOBUF_IE;
  wire [10:0] IOBUF_OE;
  wire [10:0] IOBUF_PU;
  wire [10:0] IOBUF_PD;
  wire [10:0] IOBUF_A;
  wire [10:0] IOBUF_PDRV0;
  wire [10:0] IOBUF_PDRV1;
  wire [10:0] IOBUF_Y;
  
  wire        IO_clksel_PU;
  wire        IO_exresetn_PU;
  wire        IO_testmode0_PU;
  wire        IO_testmode1_PU;
  
  wire        IO_clksel_PD;
  wire        IO_exresetn_PD;
  wire        IO_testmode0_PD;
  wire        IO_testmode1_PD;
  
  
  wire        POC, POCB;
  wire        iopad_testmode0_en_y;
  wire        iopad_testmode1_en_y;
  wire        iopad_resetn_y;
//wire  [2:0] D2A_CPCLK;
//always on
//wire  [2:0] dc_clk_div_spi;
  //wire        poresetn_hf;
//wire        spi_write;
//wire        external_clock; //external clock from analog IO cells
  wire        CLKSEL_Y; //external clock from analog IO cells
  wire        scan_clk;
  wire        scan_rst_n;
  wire        A2D_external_RESET;
  wire        A2D_Wake_UP_i;
  wire  [4:0] otp_to_ana_bgh_vtrim; 
  wire  [6:0] otp_to_ana_bgh_ctrl;  
  wire  [4:0] otp_to_ana_bgl_vtrim;  
  wire  [6:0] otp_to_ana_bgl_ctrl;  
  wire  [1:0] otp_to_ana_ldo1v5_trim;
  wire  [1:0] otp_to_ana_dacbuf_trim;
  wire  [5:0] otp_to_ana_osc_trim;
  wire  [4:0] D2A_BGH_VTRIM;
  wire  [6:0] D2A_BGH_CTRIM;
  wire  [4:0] D2A_BGL_VTRIM;
  wire  [6:0] D2A_BGL_CTRIM;
  wire  [1:0] D2A_LDO1V5_TRIM;
  wire  [1:0] D2A_DAC_BUF_TRIM;
  wire  [5:0] D2A_OSC_TRIM;
//wire        VREF0P8;
//analog i/p
  wire        BG_BUF_EN;
  wire        DAC_BUF_EN;
  wire        D2A_TSC_EN;
  wire        D2A_TSC_AMP_EN;
  wire  [2:0] D2A_TSC_BJT_SEL;
  wire  [2:0] D2A_TSC_GSEL;
  wire        D2A_TSC_OUT_SEL;
  wire        CH1_WE1_EN;
  wire        CH1_WE1_DDA_EN;
  wire  [3:0] CH1_WE1_RFB_SEL;
  wire  [2:0] CH1_WE1_ROUT_SEL;
  wire  [2:0] CH1_WE1_VGAIN_SEL;
  wire        CH1_WE2_EN;
  wire        CH1_WE2_DDA_EN;
  wire  [3:0] CH1_WE2_RFB_SEL;
  wire  [2:0] CH1_WE2_ROUT_SEL;
  wire  [2:0] CH1_WE2_VGAIN_SEL;
  wire        CH1_RCE_EN;
  wire  [2:0] CH1_CE_ROUT_SEL;
  wire        CH1_WE_DAC_EN;
  wire  [9:0] CH1_DINWE;
  wire        CH1_RCE_DAC_EN;
  wire  [9:0] CH1_DINRCE;
//Peripheral
  wire        BIST_EN;
  wire  [2:0] BIST_ISEL;
  wire        DDA_EN;
  wire  [2:0] DDA_GSEL;
  wire        D2A_PGA_EN;
  wire  [2:0] D2A_PGA_VIN_SEL;
  wire  [1:0] D2A_PGA_GSEL;
  wire        ELE_BUF_EN;
  wire  [2:0] ELE_BUF_ISEL;

 wire  A2D_SDM_OUT0;
wire  A2D_SDM_OUT1;
wire  A2D_SDM_OUT2;
wire  A2D_SDM_OUT3;
wire  A2D_SDM_OUT4;
wire  A2D_SDM_OUT5;
wire  A2D_SDM_OUT6;
wire  A2D_SDM_OUT7;
wire  A2D_SDM_OUT8;
wire  A2D_SDM_OUT9;
wire  A2D_SDM_OUT10;
wire  A2D_SDM_OUT11;
wire  A2D_SDM_OUT12;
wire  A2D_SDM_OUT13;
wire  A2D_SDM_OUT14;
wire  A2D_SDM_OUT15;
wire  D2A_SDM_CLK;
 

 
  pinmux_if  #(.TRIM_NUMBER(8), .EN_REG_NUMBER(4))  pinmux_if();
  spi_ana_if #(.REG_NUMBER(9))                     spi_ana_if(); 
  ana_nirs_if                                       ana_nirs_if();

//WG
  wire  [11:0] out_wave_drivera_dac0;
  wire  [11:0] out_wave_drivera_dac1;
  wire  [11:0] out_wave_drivera_dac2;
  wire  [11:0] out_wave_drivera_dac3;
  wire  [11:0] out_wave_drivera_dac4;
  wire  [11:0] out_wave_drivera_dac5;
  wire  [11:0] out_wave_drivera_dac6;
  wire  [11:0] out_wave_drivera_dac7;
  wire  [15:0] sourcea_driver_a;
  wire  [15:0] sourceb_driver_a;
  wire  [15:0] pullda_driver_a;
  wire  [15:0] pulldb_driver_a;

`ifdef FPGA
fpga_behavior u_fpga_hehavior(

  .iopad_testmode0_en_y (iopad_testmode0_en_y_always_on),
  .iopad_testmode1_en_y (iopad_testmode1_en_y_always_on),
  .iopad_resetn_y       (iopad_resetn_y_always_on),
  .IOBUF_PAD            (IOBUF_PAD),
  .IOBUF_A              (IOBUF_A_always_on),
  .IOBUF_OE             (IOBUF_OE_always_on),
  .IOBUF_Y              (IOBUF_Y_always_on)

);
`endif
wire atpg_en;
// instaniate top_dig
top_dig u_top_dig (

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


  .A2D_COMP1        (A2D_COMP1),
  .A2D_COMP2        (A2D_COMP2),
  .A2D_OSC_OUT      (A2D_OSC_OUT),
  .CLKSEL_Y         (CLKSEL_Y),       //from analog IO cells

  //To/From always on
  .atpg_en          (atpg_en),
  .scan_clk         (scan_clk),
  .scan_rst_n       (scan_rst_n),

  .A2D_SW_POWER_POR(A2D_SW_POWER_POR),

//io_buf_config
  .o_ens2_IOBUF_CS    (IOBUF_CS),
  .o_ens2_IOBUF_SR    (IOBUF_SR),
  .o_ens2_IOBUF_IE    (IOBUF_IE),
  .o_ens2_IOBUF_OE    (IOBUF_OE),
  .o_ens2_IOBUF_PU    (IOBUF_PU),
  .o_ens2_IOBUF_PD    (IOBUF_PD),
  .o_ens2_IOBUF_A     (IOBUF_A),
  .o_ens2_IOBUF_PDRV0 (IOBUF_PDRV0),
  .o_ens2_IOBUF_PDRV1 (IOBUF_PDRV1),
  .i_ens2_IOBUF_Y     (IOBUF_Y),
  .iopad_testmode0_en_y (iopad_testmode0_en_y),
  .iopad_testmode1_en_y (iopad_testmode1_en_y),
  .iopad_resetn_y       (iopad_resetn_y),

  .o_IO_clksel_PD       (IO_clksel_PD),
  .o_IO_exresetn_PD     (IO_exresetn_PD),
  .o_IO_testmode0_PD    (IO_testmode0_PD),
  .o_IO_testmode1_PD    (IO_testmode1_PD),

  .o_IO_clksel_PU       (IO_clksel_PU),
  .o_IO_exresetn_PU     (IO_exresetn_PU),
  .o_IO_testmode0_PU    (IO_testmode0_PU),
  .o_IO_testmode1_PU    (IO_testmode1_PU),

  .VPP_OTP              (VPP), //vpp for otp
//.AVDD_OTP             (AVDD),
  .VDD_OTP              (VDD_DIG),
  .VSUB_OTP             (VSS_DIG),
  .VSS_OTP              (VSS_DIG),
  .pinmux_if            (pinmux_if),
  .spi_ana_if           (spi_ana_if), 
  .ana_nirs_if          (ana_nirs_if),

  //WG
  .o_out_wave_drivera_dac0  (out_wave_drivera_dac0),
  .o_out_wave_drivera_dac1  (out_wave_drivera_dac1),
  .o_out_wave_drivera_dac2  (out_wave_drivera_dac2),
  .o_out_wave_drivera_dac3  (out_wave_drivera_dac3),
  .o_out_wave_drivera_dac4  (out_wave_drivera_dac4),
  .o_out_wave_drivera_dac5  (out_wave_drivera_dac5),
  .o_out_wave_drivera_dac6  (out_wave_drivera_dac6),
  .o_out_wave_drivera_dac7  (out_wave_drivera_dac7),

  .o_sourcea_driver_a       (sourcea_driver_a),
  .o_sourceb_driver_a       (sourceb_driver_a),
  .o_pullda_driver_a        (pullda_driver_a),
  .o_pulldb_driver_a        (pulldb_driver_a)


); 

`ifdef FPGA
`else

GF_CI_IN_S_POC u_iopad_exresetn (
  .PU     (IO_exresetn_PU),
  .PD     (IO_exresetn_PD),
  .PAD    (RESETn),
  .Y      (iopad_resetn_y),
  .DVDD   (VDDIO),
  .DVSS   (VSSIO),
  .VDD    (VDD_DIG),
  .VSS    (VSS_DIG),
  .POC    (POC),//(POC),
  .POCB   (POCB)// (~POC)
);

GF_CI_IN_C_POC u_iopad_clksel (
  .PU     (IO_clksel_PU),
  .PD     (IO_clksel_PD),
  .PAD    (CLKSEL),
  .Y      (CLKSEL_Y),
  .DVDD   (VDDIO),
  .DVSS   (VSSIO),
  .VDD    (VDD_DIG),
  .VSS    (VSS_DIG),
  .POC    (POC),//(POC),
  .POCB   (POCB)// (~POC)
);

GF_CI_IN_C_POC u_iopad_testmode1 (
  .PU     (IO_testmode1_PU),
  .PD     (IO_testmode1_PD),
  .PAD    (iopad_testmode1),
  .Y      (iopad_testmode1_en_y),
  .DVDD   (VDDIO),
  .DVSS   (VSSIO),
  .VDD    (VDD_DIG),
  .VSS    (VSS_DIG),
  .POC    (POC),//(POC),
  .POCB   (POCB)// (~POC)
);

GF_CI_IN_C_POC u_iopad_testmode0 (
  .PU     (IO_testmode0_PU),
  .PD     (IO_testmode0_PD),
  .PAD    (iopad_testmode0),
  .Y      (iopad_testmode0_en_y),
  .DVDD   (VDDIO),
  .DVSS   (VSSIO),
  .VDD    (VDD_DIG),  
  .VSS    (VSS_DIG),
  .POC    (POC),//(POC),
  .POCB   (POCB)// (~POC)
);

// 5V I/O ground cell
GF_CI_DVSS u_dvss(
  .DVDD       (VDDIO),
  .DVSS       (VSSIO),      //this is for IO Ring Power
  .VDD        (VDD_DIG), 
  .VSS        (VSS_DIG),
  .POC        (POC),        //come from analog model
  .POCB       (POCB)        //come from analog model
);

// 1.8V Core ground
GF_CI_VSS  u_iopad_plvss0(
  .DVDD       (VDDIO),
  .DVSS       (VSSIO),      //this is for IO Ring Power
  .VDD        (VDD_DIG), 
  .VSS        (VSS_DIG),
  .POC        (POC),        //come from analog model
  .POCB       (POCB)        //come from analog model

);

GF_CI_VSS  u_iopad_plvss1(
  .DVDD       (VDDIO),
  .DVSS       (VSSIO),      //this is for IO Ring Power
  .VDD        (VDD_DIG), 
  .VSS        (VSS_DIG),
  .POC        (POC),        //come from analog model
  .POCB       (POCB)        //come from analog model

);

// 1.8 Core power supply
GF_CI_VDD u_iopad_plvdd0(
  .DVDD       (VDDIO),
  .DVSS       (VSSIO),
  .VDD        (VDD_DIG),    //this is for backup solution connect to sw_power
  .VSS        (VSS_DIG),
  .POC        (POC),        //come from analog model
  .POCB       (POCB)        //come from analog model
);

GF_CI_VDD u_iopad_plvdd1(
  .DVDD       (VDDIO),
  .DVSS       (VSSIO),
  .VDD        (VDD_DIG),    //this is for backup solution connect to sw_power
  .VSS        (VSS_DIG),
  .POC        (POC),        //come from analog model
  .POCB       (POCB)        //come from analog model
);

// 5V I/O power supply
GF_CI_DVDD_POC u_dvdd (
  .DVDD       (VDDIO), 
  .DVSS       (VSSIO), 
  .VDD        (VDD_DIG), 
  .VSS        (VSS_DIG), 
  .POC        (POC), 
  .POCB       (POCB)
);

// VPP for flash
GF_CI_VPP u_iopad_plvpp (
  .VPP        (VPP),
  .DVDD       (VDDIO),
  .DVSS       (VSS_DIG),
  .VDD        (VDD_DIG),
  .VSS        (VSS_DIG),
  .POC        (POC),
  .POCB       (POCB)
);

// GPIO
GF_CI_BI_T_POC  u_iopad_gpio[10:0]
(
  .CS         (IOBUF_CS),       // Input Type select: 0: CMOS buffer; 1: Schmitt Trigger
  .SL         (IOBUF_SR),       // Output Slew Rate: 0: Fast; 1: Slow
  .IE         (IOBUF_IE),       // Input Enable
  .OE         (IOBUF_OE),       // Output Enable
  .PU         (IOBUF_PU),       // Pull Up
  .PD         (IOBUF_PD),       // Pull Down
  .A          (IOBUF_A),        // Data from core to PAD
  .PDRV0      (IOBUF_PDRV0),    // Slew Rate select //**need to recheck**
  .PDRV1      (IOBUF_PDRV1),    // {PDRV1, PDRV0}: 00: 4mA; 01: 8mA; 10: 12mA; 11: 16mA //**need to recheck**
  .PAD        (IOBUF_PAD[10:0]),// PAD
  .Y          (IOBUF_Y),        // Data from PAD to core
  .DVDD       (VDDIO),
  .DVSS       (VSSIO),
  .VDD        (VDD_DIG),
  .VSS        (VSS_DIG),
  .POC        (POC),//(POC),
  .POCB       (POCB)// (~POC)
);

`endif
  

ENS2_ANA_CHIP_wrapper u_top_ana_wrapper ( 
`ifdef FPGA
  .clk_in1              (clk_in1),  
`endif
  .D2A_SDM_CLK(D2A_SDM_CLK),

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

  .atpg_en                  (atpg_en),
  .A2D_CLK2MHZ              (A2D_OSC_OUT),
//.A2D_LVD                  (),
  .A2D_POR_DVDD             (A2D_SW_POWER_POR),
  .A2D_COMP_OUT_CH1         (A2D_COMP1),
  .A2D_COMP_OUT_CH2         (A2D_COMP2),
  .VDDIO                  (VDDIO),
  .VDD_DIG                  (VDD_DIG),
  .VSS_DIG                  (VSS_DIG),
  //.AVDD                     (AVDD),

  .pinmux_if                (pinmux_if),
  .spi_ana_if               (spi_ana_if),
  .ana_nirs_if              (ana_nirs_if),

  //WG
  .i_out_wave_drivera_dac0  (out_wave_drivera_dac0),
  .i_out_wave_drivera_dac1  (out_wave_drivera_dac1),
  .i_sourcea_driver_a       (sourcea_driver_a),
  .i_sourceb_driver_a       (sourceb_driver_a),
  .i_pullda_driver_a        (pullda_driver_a),
  .i_pulldb_driver_a        (pulldb_driver_a)
 );  

endmodule
