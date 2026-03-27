//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap ENS2  
// File name:    pinmux.v
// Module Name : pinmux
// Description : 
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author          Description      
//------------------------------------------------------------------------------
// 0.1         25/10/2021  Jayanthi         Initial Rev 
//------------------------------------------------------------------------------

`timescale 1ns/1ps

module pinmux (

  //PADs 
  output [21:0]       o_ens2_IOBUF_IE, 
  output [21:0]       o_ens2_IOBUF_OE, 
  output [21:0]       o_ens2_IOBUF_A,  
  input  [21:0]       i_ens2_IOBUF_Y,       
        
  //spi 
  output wire         sclk,
  output wire         cs_n,
  output wire         mosi,
  input  wire         miso,
  output wire         o_cpoln,   
  output wire         o_cpha,
  output wire         o_DAISY_IN, 

  input  wire         i_ext_clk_sel,
  output wire         o_ext_clk_sel,
  output wire         o_int_clk_out_gpio,

  input  wire         hfosc_out,
  output wire         ext_clk,
    
  // SCAN
  output wire         atpg_en,                    // atpg enable
  output wire         scan_rst_n,                 // scan resetn
  output wire         scan_clk,                   // scan clock
  output wire         scan_en,                    // scan enable
  output wire [8:0]   scan_in,                    // scan in
  input  wire [8:0]   scan_out,                   // scan out
  output wire         scan_compression_in,        // pin is used to select normal scan mode or compression scan mode. Compression scan mode is used to accelerate scan test, save more time and money.if we have more than 5 scan chain, then we can apply compression scan mode    

//input  wire [1:0]   altf_sel,     //1. configured through bist & store value in otp and switch back to normal(real application we will follow this)
                                    //2. through spi reg we can configure (as per Mohsen this feature supported to cross check/verify)        
  //OTP BIST
  output wire         otp_bist_en,              // otp bist enable  
  output wire         otp_bist_resetn,          // otp bist reset
  output wire         otp_bist_tck,             // otp bist TCK
  output wire         otp_bist_tdi,             // otp bist serial in data
  input  wire         otp_bist_oen,             // otp bist TDO output enable, low-active, no used 
  input  wire         otp_bist_tdo,             // otp bist TDO
  output wire         otp_bist_strobe,          // otp_bist_strobe
  input  wire         otp_bist_tdo_serout,      // otp_bist_tdo_serout
//input  wire         otp_bist_wbusy,
  input  wire         i_bist_vpp_en, 
  input  wire         i_otp_vpp_en,
  //added by supriya
  input  wire         iopad_testmode0_en_y,
  input  wire         iopad_testmode1_en_y,
  input  wire         iopad_resetn_y,

  //interrupts
  input  wire         i_wg_drviver_int,
  input  wire         i_lead_off_int,  
//input  wire 	      i_lvd_intr_pin,
//input  wire 	      i_comp_ch1_intr_pin,
//input  wire 	      i_comp_ch2_intr_pin, 
//input  wire 	      i_stimu_ch1_intr_pin,
//input  wire 	      i_stimu_ch2_intr_pin, 
  input  wire         i_anac_int,
  input  wire         i_tsc_int,
  input  wire         i_eeg_int,

  output wire         pin_rstn,

  //debug modes
  output wire         o_OTP_UNLOCK,
  output wire [7:0]   o_OTP_ATM_MODE_SEL,
  output wire         o_OTP_ANA_TESTMODE,
  output wire [7:0]   o_OTP_ATM_TRIM_DATA,

  input wire  [7:0]   sys_d2a_trim_reg        [7:0], 

  //COMP
//input  wire         NORMAL_OUT_SEL,
//input  wire         COMP_OUT_EN,
//input  wire         COMP_OUT_SEL,
  input  wire         o_A2D_COMP0,
  input  wire         o_A2D_COMP1,
//input  wire         COMP_OUT_SEL_STIM,
  input  wire         A2D_STIMU0_1,
  input  wire         A2D_STIMU2_3,
  
//NIRS
  input  wire		  NIRS_LED_ON0,
  input  wire		  NIRS_LED_ON1,
  input  wire		  NIRS_LED_ON2,
  input  wire		  NIRS_LED_ON3,
  input  wire		  NIRS_LED_ON4,
  input  wire		  NIRS_LED_ON5,
  input  wire		  NIRS_LED_ON6,
  input  wire		  NIRS_LED_ON7,
  input  wire		  NIRS_RESET_SW0,
  input  wire		  NIRS_IPD_SW0,
  input  wire		  NIRS_IIN_SW0,
  input  wire		  A2D_IREFCOARSE0,
  input  wire		  A2D_IREFFINE0,

  pinmux_if.D2A         pinmux_if,
  spi_pinmux_if.pinmux  spi_pinmux_if,

// TSC
  input wire   [7:0]  d2a_tsc_vdac8b_din_ch1,
  input wire          d2a_tsc_vdac8b_en_ch1,
  input wire          d2a_tsc_comp_en_ch1,
  input wire          d2a_tsc_en_ch1
);

  wire        GPIO14_NORMAL_OUT;
  wire        ext_clk_sel;
  wire        scan_mode; 
//wire [3:0]  ana_test_mode;
  wire [4:0]  ana_test_mode;
  wire [4:0]  ATM_sel;
  wire [4:0]  test_sel;
  wire        test_en;
  wire        INTB;
  wire        INTB_tmp;
  wire        debug_mode_en;
  wire [4:0]  wire_ens2_IOBUF_Y; 
  wire        ATM_CONFG;
  wire        pad_cpoln;
  wire        pad_cpha;
  wire        pad_cs_n;
  wire        pad_sclk;
  wire        pad_mosi;
  wire        ext_clk_normal;
  wire        ext_clk_0;
  wire        int_clk_out_gpio;
  wire        ATM0;
  wire        ATM1;
  wire        ATM2;
  wire        ATM3;
  wire        ATM4;
  wire        ATM5;
  wire        ATM6;
  wire        ATM7;
  wire [7:0]  pad_d2a_trim0_sig;
  wire [7:0]  pad_d2a_trim1_sig;
  wire [7:0]  pad_d2a_trim2_sig;
  wire [7:0]  pad_d2a_trim3_sig;
  wire [7:0]  pad_d2a_trim4_sig;
  wire [7:0]  pad_d2a_trim5_sig;
  wire [7:0]  pad_d2a_trim6_sig;
  wire [7:0]  pad_d2a_trim7_sig;
  wire [7:0]  CONFIG_ROM0 [7:0];
  wire [7:0]  CONFIG_ROM1 [7:0];
  wire [7:0]  CONFIG_ROM2 [7:0];
  wire [7:0]  CONFIG_ROM3 [7:0];

//ENABLE_REG
  wire        ATM_HC_SEL;
  wire        ANA_BIST_HC_SEL;
  wire        INT_LEVEL_SEL;

//assign pad_d2a_trim0_sig[6] = 1'b0;
//assign pad_d2a_trim1_sig[6] = 1'b0;
//assign pad_d2a_trim2_sig[6] = 1'b0;
//assign pad_d2a_trim3_sig[6] = 1'b0;
//assign pad_d2a_trim4_sig[6] = 1'b0;
//assign pad_d2a_trim5_sig[6] = 1'b0;
//assign pad_d2a_trim6_sig[6] = 1'b0;
//assign pad_d2a_trim7_sig[6] = 1'b0;

//assign pad_d2a_trim0_sig[6] = 1'b0;
//assign pad_d2a_trim0_sig[7] = 1'b0;
//assign pad_d2a_trim1_sig[7] = 1'b0;
//assign pad_d2a_trim2_sig[7] = 1'b0;
//assign pad_d2a_trim3_sig[7] = 1'b0;
//assign pad_d2a_trim4_sig[7] = 1'b0;
//assign pad_d2a_trim5_sig[7] = 1'b0;
//assign pad_d2a_trim6_sig[7] = 1'b0;
//assign pad_d2a_trim7_sig[7] = 1'b0;

  assign pin_rstn         = iopad_resetn_y;
  assign scan_rst_n       = pin_rstn;
  assign otp_bist_resetn  = pin_rstn;
  assign o_ext_clk_sel    = ext_clk_sel;

  wire scan_mode_pre;
  assign scan_mode_pre    =  (~iopad_testmode1_en_y &  iopad_testmode0_en_y)  ? 1'b1 : 1'b0;
  BUF_X8_A7TULL DNT_BUF_scan_mode (.A(scan_mode_pre), .Y(scan_mode));

// MODE enables
  assign ext_clk_sel    = debug_mode_en ? 1'b1 : i_ext_clk_sel;
  assign otp_bist_en    = (iopad_testmode1_en_y  &  ~iopad_testmode0_en_y) ? 1'b1 : 1'b0;
  assign debug_mode_en  = (iopad_testmode1_en_y  &  iopad_testmode0_en_y)  ? 1'b1 : 1'b0;
  assign atpg_en        = scan_mode;
  assign test_en        = (scan_mode | otp_bist_en | debug_mode_en) ? 1'b1 : 1'b0;
//assign ana_test_mode  = debug_mode_en ? ({wire_ens2_IOBUF_Y[3],  wire_ens2_IOBUF_Y[2],   wire_ens2_IOBUF_Y[1],   wire_ens2_IOBUF_Y[0]}) : 4'b0; 
  assign ana_test_mode  = debug_mode_en ? ({wire_ens2_IOBUF_Y[4], wire_ens2_IOBUF_Y[3], wire_ens2_IOBUF_Y[2],   wire_ens2_IOBUF_Y[1],   wire_ens2_IOBUF_Y[0]}) : 5'b0; 
  assign ATM_sel        = debug_mode_en ? ana_test_mode : 5'b0;

//ANALOG OUTPUTS 
  assign ATM0 = (debug_mode_en && (ana_test_mode== 5'b00000))  ? 1'b1 : 1'b0;
  assign ATM1 = (debug_mode_en && (ana_test_mode== 5'b00001))  ? 1'b1 : 1'b0;   
  assign ATM2 = (debug_mode_en && (ana_test_mode== 5'b00010))  ? 1'b1 : 1'b0; 
  assign ATM3 = (debug_mode_en && (ana_test_mode== 5'b00011))  ? 1'b1 : 1'b0;
  assign ATM4 = (debug_mode_en && (ana_test_mode== 5'b00100))  ? 1'b1 : 1'b0;
  assign ATM5 = (debug_mode_en && (ana_test_mode== 5'b00101))  ? 1'b1 : 1'b0;
  assign ATM6 = (debug_mode_en && (ana_test_mode== 5'b00110))  ? 1'b1 : 1'b0;
  assign ATM7 = (debug_mode_en && (ana_test_mode== 5'b00111))  ? 1'b1 : 1'b0;
//assign ATM8 = (ana_test_mode== 4'b1001)  ? 1'b1 : 1'b0;

  assign pinmux_if.D2A_ATM      = {ATM7, ATM6, ATM5, ATM4, ATM3, ATM2, ATM1, ATM0};
//assign pinmux_if.ENCODED_ATM  = ana_test_mode;
  
  assign ATM_CONFG =  debug_mode_en ? 1'b1 : 1'b0;
  
  assign test_sel = ((scan_mode    == 1'b1) ? 5'b00000 : 
                    (otp_bist_en   == 1'b1) ? 5'b00001 : 
                    (ana_test_mode == 5'd0) ? 5'b00010 :
                    (ana_test_mode == 5'd1) ? 5'b00011 :
                    (ana_test_mode == 5'd2) ? 5'b00100 :
                    (ana_test_mode == 5'd3) ? 5'b00101 :
                    (ana_test_mode == 5'd4) ? 5'b00110 :
                    (ana_test_mode == 5'd5) ? 5'b00111 :
                    (ana_test_mode == 5'd6) ? 5'b01000 :
                    (ana_test_mode == 5'd7) ? 5'b01001 : 5'b01011);   //this needs to be updated if require more ATM modes
   
//combine interrupt
 assign INTB_tmp  = (i_wg_drviver_int | i_lead_off_int | i_anac_int | i_tsc_int | i_eeg_int); 
 assign INTB      = (INT_LEVEL_SEL == 1'b1) ? INTB_tmp : ~INTB_tmp;

// EXTERNAL CLOCK
  assign ext_clk = ~test_en ?  ext_clk_normal : (debug_mode_en ? ext_clk_0 : 1'b0);

//NORMAL MODE - SPI
  assign o_cpoln = ~test_en ?  pad_cpoln  : 1'b0;
  assign o_cpha  = ~test_en ?  pad_cpha   : 1'b0;
  assign cs_n    = ~test_en ?  pad_cs_n   : 1'b0;
  assign sclk    = ~test_en ?  pad_sclk   : 1'b0;
  assign mosi    = ~test_en ?  pad_mosi   : 1'b0;

//assign GPIO8_NORMAL_OUT = ~test_en ? (~COMP_OUT_EN ? i_otp_vpp_en : (~COMP_OUT_SEL ? A2D_COMP1 : A2D_COMP2)) : 1'b0;
//assign GPIO8_NORMAL_OUT = ~test_en ? (~COMP_OUT_EN ? 1'b0 : (~COMP_OUT_SEL ? A2D_COMP1 : A2D_COMP2)) : 1'b0;
//assign GPIO8_NORMAL_OUT = ~test_en ?  (NORMAL_OUT_SEL ? ((~COMP_OUT_EN ? i_otp_vpp_en : COMP_OUT_SEL_STIM ? 
//                                        (~COMP_OUT_SEL ? A2D_STIMU0_1 : A2D_STIMU2_3) :
//                                        (~COMP_OUT_SEL ? A2D_COMP1 : A2D_COMP2))) : INTB) : 1'b0;
  assign GPIO14_NORMAL_OUT = ~ test_en ?  (~NIRS_LED_ON0 ? NIRS_RESET_SW0 : (~NIRS_IPD_SW0 ? NIRS_IIN_SW0 : (~A2D_IREFCOARSE0 ? A2D_IREFFINE0 : 1'b0))) : 1'b0;
                           
  assign o_int_clk_out_gpio = ~test_en ? int_clk_out_gpio : 1'b0;

  pinmux_rom  u_pinmux_rom (
    .CONFIG_ROM0  (CONFIG_ROM0),
    .CONFIG_ROM1  (CONFIG_ROM1),
    .CONFIG_ROM2  (CONFIG_ROM2),
    .CONFIG_ROM3  (CONFIG_ROM3)
  );

  assign ATM_HC_SEL       = spi_pinmux_if.ATM_HC_SEL;
  assign ANA_BIST_HC_SEL  = spi_pinmux_if.ANA_BIST_HC_SEL;
  assign INT_LEVEL_SEL    = spi_pinmux_if.INT_LEVEL_SEL;

  assign pinmux_if.d2a_tsc_vdac8b_din_ch1 = d2a_tsc_vdac8b_din_ch1;
  assign pinmux_if.d2a_tsc_vdac8b_en_ch1  = (ATM_CONFG & (ATM_HC_SEL == 1'b0) & ATM6)           ?  1'b1  : d2a_tsc_vdac8b_en_ch1;
  assign pinmux_if.d2a_tsc_comp_en_ch1    = (ATM_CONFG & (ATM_HC_SEL == 1'b0) & ATM6)           ?  1'b1  : d2a_tsc_comp_en_ch1;
  assign pinmux_if.d2a_tsc_en_ch1         = (ATM_CONFG & (ATM_HC_SEL == 1'b0) & (ATM6 || ATM1)) ?  1'b1  : d2a_tsc_en_ch1;

  assign pinmux_if.D2A_ANA_ENABLE_REG[0]  = (ATM_CONFG & (ATM_HC_SEL == 1'b0))  ? CONFIG_ROM0[ATM_sel]  : spi_pinmux_if.ANA_ENABLE_REG[0];
  assign pinmux_if.D2A_ANA_ENABLE_REG[1]  = (ATM_CONFG & (ATM_HC_SEL == 1'b0))  ? CONFIG_ROM1[ATM_sel]  : spi_pinmux_if.ANA_ENABLE_REG[1];
  assign pinmux_if.D2A_ANA_ENABLE_REG[2]  = (ATM_CONFG & (ATM_HC_SEL == 1'b0))  ? CONFIG_ROM2[ATM_sel]  : spi_pinmux_if.ANA_ENABLE_REG[2];
  assign pinmux_if.D2A_ANA_ENABLE_REG[3]  = (ATM_CONFG & ((ATM_HC_SEL == 1'b0) | (ANA_BIST_HC_SEL == 1'b0)))  ? CONFIG_ROM3[ATM_sel]  : spi_pinmux_if.ANA_ENABLE_REG[3];

//debug_signal_mode0(ATM0)
  assign pinmux_if.D2A_TRIM_SIG[0] =  ATM0 ? pad_d2a_trim0_sig : sys_d2a_trim_reg[0];

//debug_signal_mode1(ATM1)
  assign pinmux_if.D2A_TRIM_SIG[1] =  ATM1 ? pad_d2a_trim1_sig : sys_d2a_trim_reg[1];

//debug_signal_mode1(ATM2)
  assign pinmux_if.D2A_TRIM_SIG[2] =  ATM2 ? pad_d2a_trim2_sig : sys_d2a_trim_reg[2];

//debug_signal_mode1(ATM3)
  assign pinmux_if.D2A_TRIM_SIG[3] =  ATM3 ? pad_d2a_trim3_sig : sys_d2a_trim_reg[3];

//debug_signal_mode1(ATM4)
  assign pinmux_if.D2A_TRIM_SIG[4] =  ATM4 ? pad_d2a_trim4_sig : sys_d2a_trim_reg[4];

//debug_signal_mode1(ATM5)
  assign pinmux_if.D2A_TRIM_SIG[5] =  ATM5 ? pad_d2a_trim5_sig : sys_d2a_trim_reg[5];

//debug_signal_mode1(ATM6)
  assign pinmux_if.D2A_TRIM_SIG[6] =  ATM6 ? pad_d2a_trim6_sig : sys_d2a_trim_reg[6];

//debug_signal_mode1(ATM7)
  assign pinmux_if.D2A_TRIM_SIG[7] =  ATM7 ? pad_d2a_trim7_sig : sys_d2a_trim_reg[7];

//debug_signal_mode1(ATM8)
// assign pinmux_if.D2A_TRIM_SIG[8] =  ATM8 ? pad_d2a_trim8_sig : sys_d2a_trim_reg[8];

// spare
//assign pinmux_if.D2A_TRIM_SIG_SPARE[0]  =  sys_d2a_trim_reg_spare[0];
//assign pinmux_if.D2A_TRIM_SIG_SPARE[1]  =  sys_d2a_trim_reg_spare[1];
//assign pinmux_if.D2A_TRIM_SIG_SPARE[2]  =  sys_d2a_trim_reg_spare[2];

  assign pinmux_if.D2A_ANA_OUT_SEL1 = ATM1 ? i_ext_clk_sel : 1'b0;
  assign pinmux_if.D2A_ANA_OUT_SEL2 = ATM2 ? i_ext_clk_sel : 1'b0;
  assign pinmux_if.D2A_ANA_OUT_SEL3 = ATM3 ? i_ext_clk_sel : 1'b0;
  assign pinmux_if.D2A_ANA_OUT_SEL4 = ATM4 ? i_ext_clk_sel : 1'b0;
  assign pinmux_if.D2A_ANA_OUT_SEL5 = ATM5 ? i_ext_clk_sel : 1'b0;
  assign pinmux_if.D2A_ANA_OUT_SEL6 = ATM6 ? i_ext_clk_sel : 1'b0;
  assign pinmux_if.D2A_ANA_OUT_SEL7 = ATM7 ? i_ext_clk_sel : 1'b0;
  
//LOAD TRIMS to OTP
  assign o_OTP_ATM_MODE_SEL   = {ATM7, ATM6, ATM5, ATM4, ATM3, ATM2, ATM1, ATM0};

  assign o_OTP_ANA_TESTMODE   = debug_mode_en;

  assign o_OTP_ATM_TRIM_DATA  = ATM0 ? pad_d2a_trim0_sig : 
                                ATM1 ? pad_d2a_trim1_sig :
                                ATM2 ? pad_d2a_trim2_sig :
                                ATM3 ? pad_d2a_trim3_sig :
                                ATM4 ? pad_d2a_trim4_sig :
                                ATM5 ? pad_d2a_trim5_sig :
                                ATM6 ? pad_d2a_trim6_sig :
                                ATM7 ? pad_d2a_trim7_sig : 8'h00;

  assign o_OTP_UNLOCK         = ATM0 ? i_ext_clk_sel : 1'b0;

// non-scan pad
// pad->core force to 0, NOT USING in scan mode
//assign i_ens2_IOBUF15_Y = ~scan_mode &  i_ens2_IOBUF_Y[13];

//Supriya:Added
// GPIO0 pad
// normal: ext_clk
// test0 : scan_clk 
// test1 : otp_bist_tck 
// test2 : ext_clk 
// test3 : ext_clk
// test4 : ext_clk
// test5 : ext_clk
// test6 : ext_clk
// test7 : ext_clk
// test8 : ext_clk
// test9 : ext_clk
// test10: ext_clk
pinmux_1bit 
#(
.ALTF_CLKIN(1),
.TEST0_CLKIN(1),
.TEST1_CLKIN(1),
.TEST2_CLKIN(1),
.TEST3_CLKIN(1),
.TEST4_CLKIN(1),
.TEST5_CLKIN(1),
.TEST6_CLKIN(1),
.TEST7_CLKIN(1),
.TEST8_CLKIN(1),
.TEST9_CLKIN(1))
// .TEST10_CLKIN(0))
u_gpio0_pinmux (
// test and alternate select
//.altf_sel   (2'd0),
.test_sel   (scan_mode ? 5'd0 : (otp_bist_en ? 5'd1 : (debug_mode_en ? 5'd2 : 5'd29))),
.test_en    (test_en),
.test0_en   (scan_mode),
.test1_en   (otp_bist_en),
.test2_en   (debug_mode_en),     
.test3_en   (1'b0),
.test4_en   (1'b0),
.test5_en   (1'b0),
.test6_en   (1'b0),
.test7_en   (1'b0),
.test8_en   (1'b0),
.test9_en   (1'b0),
// .test10_en  (1'b0),
.test_ana   (1'b0),       //Disable IE/OE/A:: TESTMODE0 GPIO0 serves pure analog signal
// alternate function
/*
// altf0
.altf0_ie   (ext_clk_sel),          
.altf0_oe   (1'b0),                         
.altf0_a    (1'b0),                         
.altf0_def  (1'b0),                         
.altf0_y    (ext_clk_normal),
// altf1
.altf1_ie   (1'b0),         
.altf1_oe   (1'b0),                         
.altf1_a    (1'b0),                         
.altf1_def  (1'b0),                         
.altf1_y    (), 
// altf2
.altf2_ie   (1'b0),         
.altf2_oe   (1'b0),                         
.altf2_a    (1'b0),                         
.altf2_def  (1'b0),                         
.altf2_y    (), 
// altf3
.altf3_ie   (1'b0),         
.altf3_oe   (1'b0),                         
.altf3_a    (1'b0),                         
.altf3_def  (1'b0),                         
.altf3_y    (),
*/
.altf_ie   (ext_clk_sel),          
.altf_oe   (1'b0),                         
.altf_a    (1'b0),                         
.altf_def  (1'b0),                         
.altf_y    (ext_clk_normal),
// test mode function
// test0
.test0_ie   (1'b1),
.test0_oe   (1'b0),
.test0_a    (1'b0),
.test0_def  (1'b0),
.test0_y    (scan_clk),
// test1
.test1_ie   (1'b1),         
.test1_oe   (1'b0),         
.test1_a    (1'b0),         
.test1_def  (1'b0),         
.test1_y    (otp_bist_tck),
// test2
.test2_ie   (1'b1),
.test2_oe   (1'b0),
.test2_a    (1'b0),
.test2_def  (1'b0),
.test2_y    (ext_clk_0),
// test3
.test3_ie   (1'b0),
.test3_oe   (1'b0),
.test3_a    (1'b0),
.test3_def  (1'b0),
.test3_y    (),
// test4
.test4_ie   (1'b0),
.test4_oe   (1'b0),
.test4_a    (1'b0),
.test4_def  (1'b0),
.test4_y    (),
// test5
.test5_ie   (1'b0),
.test5_oe   (1'b0),
.test5_a    (1'b0),
.test5_def  (1'b0),
.test5_y    (),
// test6
.test6_ie   (1'b0),
.test6_oe   (1'b0),
.test6_a    (1'b0),
.test6_def  (1'b0),
.test6_y    (),
// test7
.test7_ie   (1'b0),
.test7_oe   (1'b0),
.test7_a    (1'b0),
.test7_def  (1'b0),
.test7_y    (),
// test8
.test8_ie   (1'b0),
.test8_oe   (1'b0),
.test8_a    (1'b0),
.test8_def  (1'b0),
.test8_y    (),
// test9
.test9_ie   (1'b0),
.test9_oe   (1'b0),
.test9_a    (1'b0),
.test9_def  (1'b0),
.test9_y    (),
// test10
// .test10_ie   (1'b0),
// .test10_oe   (1'b0),
// .test10_a    (1'b0),
// .test10_def  (1'b0),
// .test10_y    (),
// with pad interface
.iopad_gpio_y    (i_ens2_IOBUF_Y[0]),
.iopad_gpio_ie   (o_ens2_IOBUF_IE[0]),
.iopad_gpio_oe   (o_ens2_IOBUF_OE[0]),
.iopad_gpio_a    (o_ens2_IOBUF_A[0])
); 


// GPIO1 pad
// normal: CPOLn
// test0 : scan_en
// test1 : None 
// test2 : pad_d2a_trim0_sig[0] 
// test3 : pad_d2a_trim1_sig[0]
// test4 : pad_d2a_trim2_sig[0]
// test5 : pad_d2a_trim3_sig[0]
// test6 : pad_d2a_trim4_sig[0]
// test7 : pad_d2a_trim5_sig[0]
// test8 : pad_d2a_trim6_sig[0]
// test9 : pad_d2a_trim7_sig[0]
// test10: pad_d2a_trim8_sig[0]
 
pinmux_1bit 
#(
.ALTF_CLKIN(0),
.TEST0_CLKIN(0),
.TEST1_CLKIN(0),
.TEST2_CLKIN(0),
.TEST3_CLKIN(0),
.TEST4_CLKIN(0),
.TEST5_CLKIN(0),
.TEST6_CLKIN(0),
.TEST7_CLKIN(0),
.TEST8_CLKIN(0),
.TEST9_CLKIN(0))
//.TEST10_CLKIN(0))
u_gpio1_pinmux (
// test and alternate select
//.altf_sel   (altf_sel),
.test_sel   (test_sel),
.test_en    (test_en),
.test0_en   (scan_mode),
.test1_en   (1'b0),        
.test2_en   (ATM0),
.test3_en   (ATM1),
.test4_en   (ATM2),
.test5_en   (ATM3),
.test6_en   (ATM4),
.test7_en   (ATM5),
.test8_en   (ATM6),
.test9_en   (ATM7),
//.test10_en  (ATM8),
.test_ana   (1'b0),       //Disable IE/OE/A:: TESTMODE0 GPIO0 serves pure analog signal
// alternate function
/*
// altf0
.altf0_ie   (1'b1),         
.altf0_oe   (1'b0),                         
.altf0_a    (1'b0),                         
.altf0_def  (1'b0),                         
.altf0_y    (o_cpoln_0),  
// altf1
.altf1_ie   (1'b1),         
.altf1_oe   (1'b0),                         
.altf1_a    (1'b0),                         
.altf1_def  (1'b0),                         
.altf1_y    (o_cpoln_1), 
// altf2
.altf2_ie   (1'b1),         
.altf2_oe   (1'b0),                         
.altf2_a    (1'b0),                         
.altf2_def  (1'b0),                         
.altf2_y    (o_cpoln_2), 
// altf3
.altf3_ie   (1'b1),         
.altf3_oe   (1'b0),                         
.altf3_a    (1'b0),                         
.altf3_def  (1'b0),                         
.altf3_y    (o_cpoln_3),
*/
.altf_ie   (1'b1),         
.altf_oe   (1'b0),                         
.altf_a    (1'b0),                         
.altf_def  (1'b0),                         
.altf_y    (pad_cpoln),  
// test mode function
// test0
.test0_ie   (1'b1),				
.test0_oe   (1'b0),                             
.test0_a    (1'b0),                             
.test0_def  (1'b0),       			
.test0_y    (scan_en),
// test1
.test1_ie   (1'b0),            
.test1_oe   (1'b0),            
.test1_a    (1'b0),            
.test1_def  (1'b0),            
.test1_y    (),
// test2
.test2_ie   (1'b1),
.test2_oe   (1'b0),
.test2_a    (1'b0),
.test2_def  (1'b0),
.test2_y    (pad_d2a_trim0_sig[0]),
// test3
.test3_ie   (1'b1),
.test3_oe   (1'b0),
.test3_a    (1'b0),
.test3_def  (1'b0),
.test3_y    (pad_d2a_trim1_sig[0]),
// test4
.test4_ie   (1'b1),
.test4_oe   (1'b0),
.test4_a    (1'b0),
.test4_def  (1'b0),
.test4_y    (pad_d2a_trim2_sig[0]),
// test5
.test5_ie   (1'b1),
.test5_oe   (1'b0),
.test5_a    (1'b0),
.test5_def  (1'b0),
.test5_y    (pad_d2a_trim3_sig[0]),
// test6
.test6_ie   (1'b1),
.test6_oe   (1'b0),
.test6_a    (1'b0),
.test6_def  (1'b0),
.test6_y    (pad_d2a_trim4_sig[0]),
// test7
.test7_ie   (1'b1),
.test7_oe   (1'b0),
.test7_a    (1'b0),
.test7_def  (1'b0),
.test7_y    (pad_d2a_trim5_sig[0]),
// test8
.test8_ie   (1'b1),
.test8_oe   (1'b0),
.test8_a    (1'b0),
.test8_def  (1'b0),
.test8_y    (pad_d2a_trim6_sig[0]),
// test9
.test9_ie   (1'b1),
.test9_oe   (1'b0),
.test9_a    (1'b0),
.test9_def  (1'b0),
.test9_y    (pad_d2a_trim7_sig[0]),
// test10
// .test10_ie   (1'b1),
// .test10_oe   (1'b0),
// .test10_a    (1'b0),
// .test10_def  (1'b0),
// .test10_y    (pad_d2a_trim8_sig[0]),
// with pad interface
.iopad_gpio_y    (i_ens2_IOBUF_Y[1]),
.iopad_gpio_ie   (o_ens2_IOBUF_IE[1]),
.iopad_gpio_oe   (o_ens2_IOBUF_OE[1]),
.iopad_gpio_a    (o_ens2_IOBUF_A[1])
); 

// GPIO2 pad
// normal: CPHA  
// test0 : scan_compression_in
// test1 : None
// test2 : pad_d2a_trim0_sig[1] 
// test3 : pad_d2a_trim1_sig[1]
// test4 : pad_d2a_trim2_sig[1]
// test5 : pad_d2a_trim3_sig[1]
// test6 : pad_d2a_trim4_sig[1]
// test7 : pad_d2a_trim5_sig[1]
// test8 : pad_d2a_trim6_sig[1]
// test9 : pad_d2a_trim7_sig[1]
// test10: pad_d2a_trim8_sig[1]
  
pinmux_1bit 
#(
.ALTF_CLKIN(0),
.TEST0_CLKIN(0),
.TEST1_CLKIN(0),
.TEST2_CLKIN(0),
.TEST3_CLKIN(0),
.TEST4_CLKIN(0),
.TEST5_CLKIN(0),
.TEST6_CLKIN(0),
.TEST7_CLKIN(0),
.TEST8_CLKIN(0),
.TEST9_CLKIN(0))
//.TEST10_CLKIN(0))
u_gpio2_pinmux (
// test and alternate select
//.altf_sel   (altf_sel),
.test_sel   (test_sel),
.test_en    (test_en),
.test0_en   (scan_mode),
.test1_en   (1'b0),
.test2_en   (ATM0),
.test3_en   (ATM1),
.test4_en   (ATM2),
.test5_en   (ATM3),
.test6_en   (ATM4),
.test7_en   (ATM5),
.test8_en   (ATM6),
.test9_en   (ATM7),
//.test10_en  (ATM8),
.test_ana   (1'b0),       //Disable IE/OE/A:: TESTMODE0 GPIO0 serves pure analog signal
// alternate function
/*
// altf0
.altf0_ie   (1'b1),         
.altf0_oe   (1'b0),                         
.altf0_a    (1'b0),                         
.altf0_def  (1'b0),                         
.altf0_y    (o_cpha_0),
// altf1
.altf1_ie   (1'b1),         
.altf1_oe   (1'b0),                         
.altf1_a    (1'b0),                         
.altf1_def  (1'b0),                         
.altf1_y    (o_cpha_1), 
// altf2
.altf2_ie   (1'b1),         
.altf2_oe   (1'b0),                         
.altf2_a    (1'b0),                         
.altf2_def  (1'b0),                         
.altf2_y    (o_cpha_2), 
// altf3
.altf3_ie   (1'b1),         
.altf3_oe   (1'b0),                         
.altf3_a    (1'b0),                         
.altf3_def  (1'b0),                         
.altf3_y    (o_cpha_3),
*/
.altf_ie   (1'b1),         
.altf_oe   (1'b0),                         
.altf_a    (1'b0),                         
.altf_def  (1'b0),                         
.altf_y    (pad_cpha),
// test mode function
// test0
.test0_ie   (1'b1),       
.test0_oe   (1'b0),                             
.test0_a    (1'b0),                             
.test0_def  (1'b0),             
.test0_y    (scan_compression_in),                  
// test1
.test1_ie   (1'b0),
.test1_oe   (1'b0),
.test1_a    (1'b0),
.test1_def  (1'b0),
.test1_y    (),
// test2
.test2_ie   (1'b1),
.test2_oe   (1'b0),
.test2_a    (1'b0),
.test2_def  (1'b0),
.test2_y    (pad_d2a_trim0_sig[1]),
// test3
.test3_ie   (1'b1),
.test3_oe   (1'b0),
.test3_a    (1'b0),
.test3_def  (1'b0),
.test3_y    (pad_d2a_trim1_sig[1]),
// test4
.test4_ie   (1'b1),
.test4_oe   (1'b0),
.test4_a    (1'b0),
.test4_def  (1'b0),
.test4_y    (pad_d2a_trim2_sig[1]),
// test5
.test5_ie   (1'b1),
.test5_oe   (1'b0),
.test5_a    (1'b0),
.test5_def  (1'b0),
.test5_y    (pad_d2a_trim3_sig[1]),
// test6
.test6_ie   (1'b1),
.test6_oe   (1'b0),
.test6_a    (1'b0),
.test6_def  (1'b0),
.test6_y    (pad_d2a_trim4_sig[1]),
// test7
.test7_ie   (1'b1),
.test7_oe   (1'b0),
.test7_a    (1'b0),
.test7_def  (1'b0),
.test7_y    (pad_d2a_trim5_sig[1]),
// test8
.test8_ie   (1'b1),
.test8_oe   (1'b0),
.test8_a    (1'b0),
.test8_def  (1'b0),
.test8_y    (pad_d2a_trim6_sig[1]),
// test9
.test9_ie   (1'b1),
.test9_oe   (1'b0),
.test9_a    (1'b0),
.test9_def  (1'b0),
.test9_y    (pad_d2a_trim7_sig[1]),
// test10
// .test10_ie   (1'b1),
// .test10_oe   (1'b0),
// .test10_a    (1'b0),
// .test10_def  (1'b0),
// .test10_y    (pad_d2a_trim8_sig[1]),
// with pad interface
.iopad_gpio_y    (i_ens2_IOBUF_Y[2]),
.iopad_gpio_ie   (o_ens2_IOBUF_IE[2]),
.iopad_gpio_oe   (o_ens2_IOBUF_OE[2]),
.iopad_gpio_a    (o_ens2_IOBUF_A[2])
); 

// GPIO3 pad
// normal: csn
// test0 : scan_in[0]
// test1 : otp_bist_tdo_serout
// test2 : pad_d2a_trim0_sig[2] 
// test3 : pad_d2a_trim1_sig[2]
// test4 : pad_d2a_trim2_sig[2]
// test5 : pad_d2a_trim3_sig[2]
// test6 : pad_d2a_trim4_sig[2]
// test7 : pad_d2a_trim5_sig[2]
// test8 : pad_d2a_trim6_sig[2]
// test9 : pad_d2a_trim7_sig[2]
// test10: pad_d2a_trim8_sig[2]

pinmux_1bit 
#(
.ALTF_CLKIN(0),
.TEST0_CLKIN(0),
.TEST1_CLKIN(0),
.TEST2_CLKIN(0),
.TEST3_CLKIN(0),
.TEST4_CLKIN(0),
.TEST5_CLKIN(0),
.TEST6_CLKIN(0),
.TEST7_CLKIN(0),
.TEST8_CLKIN(0),
.TEST9_CLKIN(0))
//.TEST10_CLKIN(0))
u_gpio3_pinmux (
// test and alternate select
//.altf_sel   (altf_sel),
.test_sel   (test_sel),
.test_en    (test_en),
.test0_en   (scan_mode),
.test1_en   (otp_bist_en),
.test2_en   (ATM0),
.test3_en   (ATM1),
.test4_en   (ATM2),
.test5_en   (ATM3),
.test6_en   (ATM4),
.test7_en   (ATM5),
.test8_en   (ATM6),
.test9_en   (ATM7),
//.test10_en  (ATM8),
.test_ana   (1'b0),       //Disable IE/OE/A:: TESTMODE0 GPIO0 serves pure analog signal
// alternate function
  /*
// altf0
.altf0_ie   (1'b1),
.altf0_oe   (1'b0),
.altf0_a    (1'b0),
.altf0_def  (1'b0),
.altf0_y    (cs_n_0),
// altf1
.altf1_ie   (1'b1),
.altf1_oe   (1'b0),
.altf1_a    (1'b0),
.altf1_def  (1'b0),
.altf1_y    (cs_n_1),
// altf2
.altf2_ie   (1'b1),
.altf2_oe   (1'b0),
.altf2_a    (1'b0),
.altf2_def  (1'b0),
.altf2_y    (cs_n_2),
// altf3
.altf3_ie   (1'b1),
.altf3_oe   (1'b0),
.altf3_a    (1'b0),
.altf3_def  (1'b0),
.altf3_y    (cs_n_3),
*/
.altf_ie   (1'b1),
.altf_oe   (1'b0),
.altf_a    (1'b0),
.altf_def  (1'b0),
.altf_y    (pad_cs_n),
// test mode function
// test0
.test0_ie   (1'b1),     
.test0_oe   (1'b0),                     
.test0_a    (1'b0),                     
.test0_def  (1'b0),                     
.test0_y    (scan_in[0]),
// test1
.test1_ie   (1'b0),
.test1_oe   (1'b1),
.test1_a    (otp_bist_tdo_serout),
.test1_def  (1'b0),
.test1_y    (),
// test2
.test2_ie   (1'b1),
.test2_oe   (1'b0),
.test2_a    (1'b0),
.test2_def  (1'b0),
.test2_y    (pad_d2a_trim0_sig[2]),
// test3
.test3_ie   (1'b1),
.test3_oe   (1'b0),
.test3_a    (1'b0),
.test3_def  (1'b0),
.test3_y    (pad_d2a_trim1_sig[2]),
// test4
.test4_ie   (1'b1),
.test4_oe   (1'b0),
.test4_a    (1'b0),
.test4_def  (1'b0),
.test4_y    (pad_d2a_trim2_sig[2]),
// test5
.test5_ie   (1'b1),
.test5_oe   (1'b0),
.test5_a    (1'b0),
.test5_def  (1'b0),
.test5_y    (pad_d2a_trim3_sig[2]),
// test6
.test6_ie   (1'b1),
.test6_oe   (1'b0),
.test6_a    (1'b0),
.test6_def  (1'b0),
.test6_y    (pad_d2a_trim4_sig[2]),
// test7
.test7_ie   (1'b1),
.test7_oe   (1'b0),
.test7_a    (1'b0),
.test7_def  (1'b0),
.test7_y    (pad_d2a_trim5_sig[2]),
// test8
.test8_ie   (1'b1),
.test8_oe   (1'b0),
.test8_a    (1'b0),
.test8_def  (1'b0),
.test8_y    (pad_d2a_trim6_sig[2]),
// test9
.test9_ie   (1'b1),
.test9_oe   (1'b0),
.test9_a    (1'b0),
.test9_def  (1'b0),
.test9_y    (pad_d2a_trim7_sig[2]),
// test10
// .test10_ie   (1'b1),
// .test10_oe   (1'b0),
// .test10_a    (1'b0),
// .test10_def  (1'b0),
// .test10_y    (pad_d2a_trim8_sig[2]),
// with pad interface
.iopad_gpio_y    (i_ens2_IOBUF_Y[3]),
.iopad_gpio_ie   (o_ens2_IOBUF_IE[3]),
.iopad_gpio_oe   (o_ens2_IOBUF_OE[3]),
.iopad_gpio_a    (o_ens2_IOBUF_A[3])
); 

// GPIO4 pad
// normal: sck
// test0 : scan_in[1]
// test1 : otp_bist_tdo
// test2 : pad_d2a_trim0_sig[3] 
// test3 : pad_d2a_trim1_sig[3]
// test4 : pad_d2a_trim2_sig[3]
// test5 : pad_d2a_trim3_sig[3]
// test6 : pad_d2a_trim4_sig[3]
// test7 : pad_d2a_trim5_sig[3]
// test8 : pad_d2a_trim6_sig[3]
// test9 : pad_d2a_trim7_sig[3]
// test10: pad_d2a_trim8_sig[3]
pinmux_1bit 
#(
.ALTF_CLKIN(1),
.TEST0_CLKIN(0),
.TEST1_CLKIN(0),
.TEST2_CLKIN(0),
.TEST3_CLKIN(0),
.TEST4_CLKIN(0),
.TEST5_CLKIN(0),
.TEST6_CLKIN(0),
.TEST7_CLKIN(0),
.TEST8_CLKIN(0),
.TEST9_CLKIN(0))
//.TEST10_CLKIN(0))
u_gpio4_pinmux (
// test and alternate select
//.altf_sel   (altf_sel),
.test_sel   (test_sel),
.test_en    (test_en),
.test0_en   (scan_mode),
.test1_en   (otp_bist_en),
.test2_en   (ATM0),
.test3_en   (ATM1),
.test4_en   (ATM2),
.test5_en   (ATM3),
.test6_en   (ATM4),
.test7_en   (ATM5),
.test8_en   (ATM6),
.test9_en   (ATM7),
//.test10_en  (ATM8),
.test_ana   (1'b0),       //Disable IE/OE/A:: TESTMODE0 GPIO0 serves pure analog signal
// alternate function
/*
// altf0
.altf0_ie   (1'b1),       
.altf0_oe   (1'b0),       
.altf0_a    (1'b0),                             
.altf0_def  (1'b0),                             
.altf0_y    (sclk_0), 
// altf1
.altf1_ie   (1'b1),         
.altf1_oe   (1'b0),                         
.altf1_a    (1'b0),                         
.altf1_def  (1'b0),                         
.altf1_y    (sclk_1), 
// altf2
.altf2_ie   (1'b1),         
.altf2_oe   (1'b0),                         
.altf2_a    (1'b0),                         
.altf2_def  (1'b1),                         
.altf2_y    (mosi_2), 
// altf3
.altf3_ie   (1'b0),         
.altf3_oe   (~cs_n),                         
.altf3_a    (miso),                         
.altf3_def  (1'b0),                         
.altf3_y    (),  
*/
.altf_ie   (1'b1),       
.altf_oe   (1'b0),       
.altf_a    (1'b0),                             
.altf_def  (1'b0),                             
.altf_y    (pad_sclk), 
// test mode function
// test0
.test0_ie   (1'b1),
.test0_oe   (1'b0),
.test0_a    (1'b0),
.test0_def  (1'b0),
.test0_y    (scan_in[1]),
// test1
.test1_ie   (1'b0),
.test1_oe   (~otp_bist_oen),
.test1_a    (otp_bist_tdo),
.test1_def  (1'b1),
.test1_y    (),
// test2
.test2_ie   (1'b1),
.test2_oe   (1'b0),
.test2_a    (1'b0),
.test2_def  (1'b0),
.test2_y    (pad_d2a_trim0_sig[3]),
// test3
.test3_ie   (1'b1),
.test3_oe   (1'b0),
.test3_a    (1'b0),
.test3_def  (1'b0),
.test3_y    (pad_d2a_trim1_sig[3]),
// test4
.test4_ie   (1'b1),
.test4_oe   (1'b0),
.test4_a    (1'b0),
.test4_def  (1'b0),
.test4_y    (pad_d2a_trim2_sig[3]),
// test5
.test5_ie   (1'b1),
.test5_oe   (1'b0),
.test5_a    (1'b0),
.test5_def  (1'b0),
.test5_y    (pad_d2a_trim3_sig[3]),
// test6
.test6_ie   (1'b1),
.test6_oe   (1'b0),
.test6_a    (1'b0),
.test6_def  (1'b0),
.test6_y    (pad_d2a_trim4_sig[3]),
// test7
.test7_ie   (1'b1),
.test7_oe   (1'b0),
.test7_a    (1'b0),
.test7_def  (1'b0),
.test7_y    (pad_d2a_trim5_sig[3]),
// test8
.test8_ie   (1'b1),
.test8_oe   (1'b0),
.test8_a    (1'b0),
.test8_def  (1'b0),
.test8_y    (pad_d2a_trim6_sig[3]),
// test9
.test9_ie   (1'b1),
.test9_oe   (1'b0),
.test9_a    (1'b0),
.test9_def  (1'b0),
.test9_y    (pad_d2a_trim7_sig[3]),
// test10
// .test10_ie   (1'b1),
// .test10_oe   (1'b0),
// .test10_a    (1'b0),
// .test10_def  (1'b0),
// .test10_y    (pad_d2a_trim8_sig[3]),
// with pad interface
.iopad_gpio_y    (i_ens2_IOBUF_Y[4]),
.iopad_gpio_ie   (o_ens2_IOBUF_IE[4]),
.iopad_gpio_oe   (o_ens2_IOBUF_OE[4]),
.iopad_gpio_a    (o_ens2_IOBUF_A[4])
); 

// GPIO5 pad
// normal: mosi
// test0 : scan_in[2]
// test1 : otp_bist_strobe
// test2 : pad_d2a_trim0_sig[4] 
// test3 : pad_d2a_trim1_sig[4]
// test4 : pad_d2a_trim2_sig[4]
// test5 : pad_d2a_trim3_sig[4]
// test6 : pad_d2a_trim4_sig[4]
// test7 : pad_d2a_trim5_sig[4]
// test8 : pad_d2a_trim6_sig[4]
// test9 : pad_d2a_trim7_sig[4]
// test10: pad_d2a_trim8_sig[4]
  
pinmux_1bit 
#(
.ALTF_CLKIN(0),
.TEST0_CLKIN(0),
.TEST1_CLKIN(0),
.TEST2_CLKIN(0),
.TEST3_CLKIN(0),
.TEST4_CLKIN(0),
.TEST5_CLKIN(0),
.TEST6_CLKIN(0),
.TEST7_CLKIN(0),
.TEST8_CLKIN(0),
.TEST9_CLKIN(0))
//.TEST10_CLKIN(0))
u_gpio5_pinmux (
// test and alternate select
//.altf_sel   (altf_sel),
.test_sel   (test_sel),
.test_en    (test_en),
.test0_en   (scan_mode),
.test1_en   (otp_bist_en),
.test2_en   (ATM0),
.test3_en   (ATM1),
.test4_en   (ATM2),
.test5_en   (ATM3),
.test6_en   (ATM4),
.test7_en   (ATM5),
.test8_en   (ATM6),
.test9_en   (ATM7),
//.test10_en  (ATM8),
.test_ana   (1'b0),       //Disable IE/OE/A:: 
// alternate function
/*
// altf0
.altf0_ie   (1'b1),         
.altf0_oe   (1'b0),                         
.altf0_a    (1'b0),                         
.altf0_def  (1'b1),                         
.altf0_y    (mosi_0),
// altf1
.altf1_ie   (1'b0),         
.altf1_oe   (~cs_n),                         
.altf1_a    (miso),                         
.altf1_def  (1'b0),                         
.altf1_y    (), 
// altf2
.altf2_ie   (1'b0),         
.altf2_oe   (~cs_n),                         
.altf2_a    (miso),                         
.altf2_def  (1'b0),                         
.altf2_y    (), 
// altf3
.altf3_ie   (1'b1),         
.altf3_oe   (1'b0),                         
.altf3_a    (1'b0),                         
.altf3_def  (1'b1),                         
.altf3_y    (mosi_3),    
*/
.altf_ie   (1'b1),         
.altf_oe   (1'b0),                         
.altf_a    (1'b0),                         
.altf_def  (1'b1),                         
.altf_y    (pad_mosi),
// test mode function
// test0
.test0_ie   (1'b1),
.test0_oe   (1'b0),
.test0_a    (1'b0),
.test0_def  (1'b0),
.test0_y    (scan_in[2]),
// test1
.test1_ie   (1'b1),
.test1_oe   (1'b0),
.test1_a    (1'b0),
.test1_def  (1'b0),
.test1_y    (otp_bist_strobe),
// test2
.test2_ie   (1'b1),
.test2_oe   (1'b0),
.test2_a    (1'b0),
.test2_def  (1'b0),
.test2_y    (pad_d2a_trim0_sig[4]), 
// test3
.test3_ie   (1'b1),
.test3_oe   (1'b0),
.test3_a    (1'b0),
.test3_def  (1'b0),
.test3_y    (pad_d2a_trim1_sig[4]),
// test4
.test4_ie   (1'b1),
.test4_oe   (1'b0),
.test4_a    (1'b0),
.test4_def  (1'b0),
.test4_y    (pad_d2a_trim2_sig[4]),
// test5
.test5_ie   (1'b1),
.test5_oe   (1'b0),
.test5_a    (1'b0),
.test5_def  (1'b0),
.test5_y    (pad_d2a_trim3_sig[4]),
// test6
.test6_ie   (1'b1),
.test6_oe   (1'b0),
.test6_a    (1'b0),
.test6_def  (1'b0),
.test6_y    (pad_d2a_trim4_sig[4]),
// test7
.test7_ie   (1'b1),
.test7_oe   (1'b0),
.test7_a    (1'b0),
.test7_def  (1'b0),
.test7_y    (pad_d2a_trim5_sig[4]),
// test8
.test8_ie   (1'b1),
.test8_oe   (1'b0),
.test8_a    (1'b0),
.test8_def  (1'b0),
.test8_y    (pad_d2a_trim6_sig[4]),
// test9
.test9_ie   (1'b1),
.test9_oe   (1'b0),
.test9_a    (1'b0),
.test9_def  (1'b0),
.test9_y    (pad_d2a_trim7_sig[4]),
// test10
// .test10_ie   (1'b1),
// .test10_oe   (1'b0),
// .test10_a    (1'b0),
// .test10_def  (1'b0),
// .test10_y    (pad_d2a_trim8_sig[4]),
// with pad interface
.iopad_gpio_y    (i_ens2_IOBUF_Y[5]),
.iopad_gpio_ie   (o_ens2_IOBUF_IE[5]),
.iopad_gpio_oe   (o_ens2_IOBUF_OE[5]),
.iopad_gpio_a    (o_ens2_IOBUF_A[5])
); 


// GPIO6 pad
// normal: miso
// test0 : scan_in[3]
// test1 : otp_bist_tdi
// test2 : pad_d2a_trim0_sig[5] 
// test3 : pad_d2a_trim1_sig[5]
// test4 : pad_d2a_trim2_sig[5]
// test5 : pad_d2a_trim3_sig[5]
// test6 : pad_d2a_trim4_sig[5]
// test7 : pad_d2a_trim5_sig[5]
// test8 : pad_d2a_trim6_sig[5]
// test9 : pad_d2a_trim7_sig[5]
// test10: pad_d2a_trim8_sig[5]

pinmux_1bit 
#(
.ALTF_CLKIN(0),
.TEST0_CLKIN(0),
.TEST1_CLKIN(0),
.TEST2_CLKIN(0),
.TEST3_CLKIN(0),
.TEST4_CLKIN(0),
.TEST5_CLKIN(0),
.TEST6_CLKIN(0),
.TEST7_CLKIN(0),
.TEST8_CLKIN(0),
.TEST9_CLKIN(0))
//.TEST10_CLKIN(0))
u_gpio6_pinmux (
// test and alternate select
//.altf_sel   (altf_sel),   
.test_sel   (test_sel),    
.test_en    (test_en),
.test0_en   (scan_mode),
.test1_en   (otp_bist_en),
.test2_en   (ATM0),
.test3_en   (ATM1),
.test4_en   (ATM2),
.test5_en   (ATM3),
.test6_en   (ATM4),
.test7_en   (ATM5),
.test8_en   (ATM6),
.test9_en   (ATM7),
//.test10_en  (ATM8),
.test_ana   (1'b0),       //Disable IE/OE/A:: 
// alternate function
  /*
// altf0
.altf0_ie   (1'b0),   
.altf0_oe   (~cs_n),
.altf0_a    (miso),
.altf0_def  (1'b0),
.altf0_y    (),
// altf1
.altf1_ie   (1'b1),         
.altf1_oe   (1'b0),                         
.altf1_a    (1'b0),                         
.altf1_def  (1'b1),                         
.altf1_y    (mosi_1), 
// altf2
.altf2_ie   (1'b1),         
.altf2_oe   (1'b0),                         
.altf2_a    (1'b0),                         
.altf2_def  (1'b0),                         
.altf2_y    (sclk_2), 
// altf3
.altf3_ie   (1'b1),         
.altf3_oe   (1'b0),                         
.altf3_a    (1'b0),                         
.altf3_def  (1'b0),                         
.altf3_y    (sclk_3),   
*/
.altf_ie   (1'b0),   
.altf_oe   (~cs_n),
.altf_a    (miso),
.altf_def  (1'b0),
.altf_y    (), 
// test mode function
// test0
.test0_ie   (1'b1),    
.test0_oe   (1'b0),     
.test0_a    (1'b0),    
.test0_def  (1'b0),    
.test0_y    (scan_in[3]),
// test1
.test1_ie   (otp_bist_oen),
.test1_oe   (1'b0),
.test1_a    (1'b0),
.test1_def  (1'b0),
.test1_y    (otp_bist_tdi),
// test2
.test2_ie   (1'b1),
.test2_oe   (1'b0),
.test2_a    (1'b0),
.test2_def  (1'b0),           
.test2_y    (pad_d2a_trim0_sig[5]),                                 
// test3
.test3_ie   (1'b1),
.test3_oe   (1'b0),
.test3_a    (1'b0),
.test3_def  (1'b0),
.test3_y    (pad_d2a_trim1_sig[5]),           
// test4
.test4_ie   (1'b1),
.test4_oe   (1'b0),
.test4_a    (1'b0),
.test4_def  (1'b0),
.test4_y    (pad_d2a_trim2_sig[5]),
// test5
.test5_ie   (1'b1),
.test5_oe   (1'b0),
.test5_a    (1'b0),
.test5_def  (1'b0),
.test5_y    (pad_d2a_trim3_sig[5]),
// test6
.test6_ie   (1'b1),
.test6_oe   (1'b0),
.test6_a    (1'b0),
.test6_def  (1'b0),
.test6_y    (pad_d2a_trim4_sig[5]),
// test7
.test7_ie   (1'b1),
.test7_oe   (1'b0),
.test7_a    (1'b0),
.test7_def  (1'b0),
.test7_y    (pad_d2a_trim5_sig[5]),
// test8
.test8_ie   (1'b1),
.test8_oe   (1'b0),
.test8_a    (1'b0),
.test8_def  (1'b0),
.test8_y    (pad_d2a_trim6_sig[5]),
// test9
.test9_ie   (1'b1),
.test9_oe   (1'b0),
.test9_a    (1'b0),
.test9_def  (1'b0),
.test9_y    (pad_d2a_trim7_sig[5]),
// test10
// .test10_ie   (1'b1),
// .test10_oe   (1'b0),
// .test10_a    (1'b0),
// .test10_def  (1'b0),
// .test10_y    (pad_d2a_trim8_sig[5]),
// with pad interface
.iopad_gpio_y    (i_ens2_IOBUF_Y[6]),
.iopad_gpio_ie   (o_ens2_IOBUF_IE[6]),          
.iopad_gpio_oe   (o_ens2_IOBUF_OE[6]),                                    
.iopad_gpio_a    (o_ens2_IOBUF_A[6])                                     
); 

// GPIO7 pad
// normal: DAISY_IN
// test0 : scan_in[4]
// test1 : bist_vpp_en
// test2 : pad_d2a_trim0_sig[6]
// test3 : pad_d2a_trim1_sig[6]
// test4 : pad_d2a_trim2_sig[6]
// test5 : pad_d2a_trim3_sig[6]
// test7 : pad_d2a_trim4_sig[6]
// test6 : pad_d2a_trim5_sig[6]
// test8 : pad_d2a_trim6_sig[6]
// test9 : pad_d2a_trim7_sig[6]
// test10: pad_d2a_trim8_sig[6]

pinmux_1bit 
#(
.ALTF_CLKIN(0),
.TEST0_CLKIN(0),
.TEST1_CLKIN(0),
.TEST2_CLKIN(0),
.TEST3_CLKIN(0),
.TEST4_CLKIN(0),
.TEST5_CLKIN(0),
.TEST6_CLKIN(0),
.TEST7_CLKIN(0),
.TEST8_CLKIN(0),
.TEST9_CLKIN(0))
//.TEST10_CLKIN(0))
u_gpio7_pinmux (
// test and alternate select
//.altf_sel   (altf_sel),   
.test_sel   (test_sel),     
.test_en    (test_en),                  
.test0_en   (scan_mode),
.test1_en   (otp_bist_en),
.test2_en   (ATM0),
.test3_en   (ATM1),
.test4_en   (ATM2),
.test5_en   (ATM3),
.test6_en   (ATM4),
.test7_en   (ATM5),
.test8_en   (ATM6),
.test9_en   (ATM7),
//.test10_en  (ATM8),
.test_ana   (1'b0),       //Disable IE/OE/A:: 
// alternate function
/*
// altf0
.altf0_ie   (1'b0),
.altf0_oe   (1'b1),
.altf0_a    (INTB),
.altf0_def  (1'b0),
.altf0_y    (),
// altf1
.altf1_ie   (1'b0),
.altf1_oe   (1'b1),
.altf1_a    (INTB),
.altf1_def  (1'b0),
.altf1_y    (),
// altf2
.altf2_ie   (1'b0),
.altf2_oe   (1'b1),
.altf2_a    (INTB),
.altf2_def  (1'b0),
.altf2_y    (),
// altf3
.altf3_ie   (1'b0),
.altf3_oe   (1'b1),
.altf3_a    (INTB),
.altf3_def  (1'b0),
.altf3_y    (),
*/
.altf_ie   (1'b1),
.altf_oe   (1'b0),
.altf_a    (1'b0),
.altf_def  (1'b0),
.altf_y    (o_DAISY_IN),
// test mode function
// test0
.test0_ie   (1'b1),    
.test0_oe   (1'b0),     
.test0_a    (1'b0),    
.test0_def  (1'b0),    
.test0_y    (scan_in[4]),
// test1
.test1_ie   (1'b0),
.test1_oe   (1'b1),
.test1_a    (i_bist_vpp_en),
.test1_def  (1'b0),
.test1_y    (),
// test2
.test2_ie   (1'b1),
.test2_oe   (1'b0),
.test2_a    (1'b0),
.test2_def  (1'b0),
.test2_y    (pad_d2a_trim0_sig[6]),                                
// test3
.test3_ie   (1'b1),
.test3_oe   (1'b0),
.test3_a    (1'b0),
.test3_def  (1'b0),
.test3_y    (pad_d2a_trim1_sig[6]),           
// test4
.test4_ie   (1'b1),
.test4_oe   (1'b0),
.test4_a    (1'b0),
.test4_def  (1'b0),
.test4_y    (pad_d2a_trim2_sig[6]),
// test5
.test5_ie   (1'b1),
.test5_oe   (1'b0),
.test5_a    (1'b0),
.test5_def  (1'b0),
.test5_y    (pad_d2a_trim3_sig[6]),
// test6
.test6_ie   (1'b1),
.test6_oe   (1'b0),
.test6_a    (1'b0),
.test6_def  (1'b0),
.test6_y    (pad_d2a_trim4_sig[6]),
// test7
.test7_ie   (1'b1),
.test7_oe   (1'b0),
.test7_a    (1'b0),
.test7_def  (1'b0),
.test7_y    (pad_d2a_trim5_sig[6]),
// test8
.test8_ie   (1'b1),
.test8_oe   (1'b0),
.test8_a    (1'b0),
.test8_def  (1'b0),
.test8_y    (pad_d2a_trim6_sig[6]),
// test9
.test9_ie   (1'b1),
.test9_oe   (1'b0),
.test9_a    (1'b0),
.test9_def  (1'b0),
.test9_y    (pad_d2a_trim7_sig[6]),
// test10
// .test10_ie   (1'b1),
// .test10_oe   (1'b0),
// .test10_a    (1'b0),
// .test10_def  (1'b0),
// .test10_y    (pad_d2a_trim8_sig[6]),
// with pad interface
.iopad_gpio_y    (i_ens2_IOBUF_Y[7]),
.iopad_gpio_ie   (o_ens2_IOBUF_IE[7]),
.iopad_gpio_oe   (o_ens2_IOBUF_OE[7]),
.iopad_gpio_a    (o_ens2_IOBUF_A[7])
); 

// GPIO8 pad
// normal: INTB
// test0 : scan_in[5]
// test1 : None 
// test2 : pad_d2a_trim0_sig[7]
// test3 : pad_d2a_trim1_sig[7]
// test4 : pad_d2a_trim2_sig[7]
// test5 : pad_d2a_trim3_sig[7]
// test7 : pad_d2a_trim4_sig[7]
// test6 : pad_d2a_trim5_sig[7]
// test8 : pad_d2a_trim6_sig[7]
// test9 : pad_d2a_trim7_sig[7]
// test10: pad_d2a_trim8_sig[7]

pinmux_1bit 
#(
.ALTF_CLKIN(0),
.TEST0_CLKIN(0),
.TEST1_CLKIN(0),
.TEST2_CLKIN(0),
.TEST3_CLKIN(0),
.TEST4_CLKIN(0),
.TEST5_CLKIN(0),
.TEST6_CLKIN(0),
.TEST7_CLKIN(0),
.TEST8_CLKIN(0),
.TEST9_CLKIN(0))
//.TEST10_CLKIN(0))
u_gpio8_pinmux (
// test and alternate select
//.altf_sel   (altf_sel),   
.test_sel   (test_sel),     
.test_en    (test_en),                  
.test0_en   (scan_mode),
.test1_en   (otp_bist_en),
.test2_en   (ATM0),
.test3_en   (ATM1),
.test4_en   (ATM2),
.test5_en   (ATM3),
.test6_en   (ATM4),
.test7_en   (ATM5),
.test8_en   (ATM6),
.test9_en   (ATM7),
//.test10_en  (ATM8),
.test_ana   (1'b0),       //Disable IE/OE/A:: 
// alternate function
/*
// altf0
.altf0_ie   (1'b0),
.altf0_oe   (1'b1),
.altf0_a    (i_otp_vpp_en),
.altf0_def  (1'b0),
.altf0_y    (),
// altf1
.altf1_ie   (1'b0),         
.altf1_oe   (1'b1),                         
.altf1_a    (i_otp_vpp_en),                         
.altf1_def  (1'b0),                         
.altf1_y    (), 
// altf2
.altf2_ie   (1'b0),         
.altf2_oe   (1'b1),                         
.altf2_a    (i_otp_vpp_en),                         
.altf2_def  (1'b0),                         
.altf2_y    (), 
// altf3
.altf3_ie   (1'b0),         
.altf3_oe   (1'b1),                         
.altf3_a    (i_otp_vpp_en),                         
.altf3_def  (1'b0),                         
.altf3_y    (),      
*/
.altf_ie   (1'b0),
.altf_oe   (1'b1),
.altf_a    (INTB),
.altf_def  (1'b0),
.altf_y    (),
// test mode function
// test0
.test0_ie   (1'b1),    
.test0_oe   (1'b0),     
.test0_a    (1'b0),    
.test0_def  (1'b0),    
.test0_y    (scan_in[5]),
// test1
.test1_ie   (1'b0),
.test1_oe   (1'b0),
.test1_a    (1'b0),
.test1_def  (1'b0),
.test1_y    (),
// test2
.test2_ie   (1'b1),
.test2_oe   (1'b0),
.test2_a    (1'b0),
.test2_def  (1'b0),
.test2_y    (pad_d2a_trim0_sig[7]),                                
// test3
.test3_ie   (1'b1),
.test3_oe   (1'b0),
.test3_a    (1'b0),
.test3_def  (1'b0),
.test3_y    (pad_d2a_trim1_sig[7]),           
// test4
.test4_ie   (1'b1),
.test4_oe   (1'b0),
.test4_a    (1'b0),
.test4_def  (1'b0),
.test4_y    (pad_d2a_trim2_sig[7]),
// test5
.test5_ie   (1'b1),
.test5_oe   (1'b0),
.test5_a    (1'b0),
.test5_def  (1'b0),
.test5_y    (pad_d2a_trim3_sig[7]),
// test6
.test6_ie   (1'b1),
.test6_oe   (1'b0),
.test6_a    (1'b0),
.test6_def  (1'b0),
.test6_y    (pad_d2a_trim4_sig[7]),
// test7
.test7_ie   (1'b1),
.test7_oe   (1'b0),
.test7_a    (1'b0),
.test7_def  (1'b0),
.test7_y    (pad_d2a_trim5_sig[7]),
// test8
.test8_ie   (1'b1),
.test8_oe   (1'b0),
.test8_a    (1'b0),
.test8_def  (1'b0),
.test8_y    (pad_d2a_trim6_sig[7]),
// test9
.test9_ie   (1'b1),
.test9_oe   (1'b0),
.test9_a    (1'b0),
.test9_def  (1'b0),
.test9_y    (pad_d2a_trim7_sig[7]),
// test10
// .test10_ie   (1'b1),
// .test10_oe   (1'b0),
// .test10_a    (1'b0),
// .test10_def  (1'b0),
// .test10_y    (pad_d2a_trim8_sig[7]),
// with pad interface
.iopad_gpio_y    (i_ens2_IOBUF_Y[8]),
.iopad_gpio_ie   (o_ens2_IOBUF_IE[8]),
.iopad_gpio_oe   (o_ens2_IOBUF_OE[8]),
.iopad_gpio_a    (o_ens2_IOBUF_A[8])
); 

// GPIO9 pad
// normal: OTP_VPP_EN
// test0 : scan_in[6]
// test1 : None
// test2 : OTP_VPP_EN
// test3 : OTP_VPP_EN
// test4 : OTP_VPP_EN
// test5 : OTP_VPP_EN
// test6 : OTP_VPP_EN
// test7 : OTP_VPP_EN
// test8 : OTP_VPP_EN
// test9 : OTP_VPP_EN
// test10: OTP_VPP_EN
pinmux_1bit 
#(
.ALTF_CLKIN(0),
.TEST0_CLKIN(0),
.TEST1_CLKIN(0),
.TEST2_CLKIN(0),
.TEST3_CLKIN(0),
.TEST4_CLKIN(0),
.TEST5_CLKIN(0),
.TEST6_CLKIN(0),
.TEST7_CLKIN(0),
.TEST8_CLKIN(0),
.TEST9_CLKIN(0))
//.TEST10_CLKIN(0))
u_gpio9_pinmux (
// test and alternate select
//.altf_sel   (altf_sel),   
.test_sel   (test_sel),     
.test_en    (test_en),                  
.test0_en   (scan_mode),
.test1_en   (otp_bist_en),
.test2_en   (ATM0),
.test3_en   (ATM1),
.test4_en   (ATM2),
.test5_en   (ATM3),
.test6_en   (ATM4),
.test7_en   (ATM5),
.test8_en   (ATM6),
.test9_en   (ATM7),
//.test10_en  (ATM8),
.test_ana   (1'b0),       //Disable IE/OE/A:: 
// alternate function
/*
// altf0
.altf0_ie   (1'b0),
.altf0_oe   (1'b1),
.altf0_a    (hfosc_out),
.altf0_def  (1'b0),
.altf0_y    (),
// altf1
.altf1_ie   (1'b0),         
.altf1_oe   (1'b0),                         
.altf1_a    (1'b0),                         
.altf1_def  (1'b0),                         
.altf1_y    (), 
// altf2
.altf2_ie   (1'b0),         
.altf2_oe   (1'b0),                         
.altf2_a    (1'b0),                         
.altf2_def  (1'b0),                         
.altf2_y    (), 
// altf3
.altf3_ie   (1'b0),         
.altf3_oe   (1'b0),                         
.altf3_a    (1'b0),                         
.altf3_def  (1'b0),                         
.altf3_y    (),   
*/   
.altf_ie   (1'b0),
.altf_oe   (1'b1),
.altf_a    (i_otp_vpp_en),
.altf_def  (1'b0),
.altf_y    (),

// test0
.test0_ie   (1'b1),    
.test0_oe   (1'b0),     
.test0_a    (1'b0),    
.test0_def  (1'b0),    
.test0_y    (scan_in[6]),
// test1
.test1_ie   (1'b0),
.test1_oe   (1'b0),
.test1_a    (1'b0),
.test1_def  (1'b0),
.test1_y    (),
// test2
.test2_ie   (1'b0),
.test2_oe   (1'b0),
.test2_a    (1'b0),
.test2_def  (1'b0),         
.test2_y    (),   
// test3
.test3_ie   (1'b0),
.test3_oe   (1'b0),
.test3_a    (1'b0),
.test3_def  (1'b0),
.test3_y    (),
// test4
.test4_ie   (1'b0),
.test4_oe   (1'b0),
.test4_a    (1'b0),
.test4_def  (1'b0),
.test4_y    (),
// test5
.test5_ie   (1'b0),
.test5_oe   (1'b0),
.test5_a    (1'b0),
.test5_def  (1'b0),
.test5_y    (),
// test6
.test6_ie   (1'b0),
.test6_oe   (1'b0),
.test6_a    (1'b0),
.test6_def  (1'b0),
.test6_y    (),
// test7
.test7_ie   (1'b0),
.test7_oe   (1'b0),
.test7_a    (1'b0),
.test7_def  (1'b0),
.test7_y    (),
// test8
.test8_ie   (1'b0),
.test8_oe   (1'b0),
.test8_a    (1'b0),
.test8_def  (1'b0),
.test8_y    (),
// test9
.test9_ie   (1'b0),
.test9_oe   (1'b0),
.test9_a    (1'b0),
.test9_def  (1'b0),
.test9_y    (),
// test10
// .test10_ie   (1'b0),
// .test10_oe   (1'b1),
// .test10_a    (i_otp_vpp_en),
// .test10_def  (1'b0),
// .test10_y    (),
// with pad interface
.iopad_gpio_y    (i_ens2_IOBUF_Y[9]),
.iopad_gpio_ie   (o_ens2_IOBUF_IE[9]),          
.iopad_gpio_oe   (o_ens2_IOBUF_OE[9]),                                    
.iopad_gpio_a    (o_ens2_IOBUF_A[9])                                     
); 
// GPIO10 pad
// normal: hfosc_out 
// test0 : scan_in[7]
// test1 : wire_ens2_IOBUF_Y[0]
// test2 : None
// test3 : None
// test4 : None
// test5 : None
// test6 : None
// test7 : None
// test8 : None
// test9 : None
// test10: None

pinmux_1bit 
#(
.ALTF_CLKIN(1),
.TEST0_CLKIN(0),
.TEST1_CLKIN(0),
.TEST2_CLKIN(0),
.TEST3_CLKIN(0),
.TEST4_CLKIN(0),
.TEST5_CLKIN(0),
.TEST6_CLKIN(0),
.TEST7_CLKIN(0),
.TEST8_CLKIN(0),
.TEST9_CLKIN(0))
//.TEST10_CLKIN(0))
u_gpio10_pinmux (
// test and alternate select
//.altf_sel   (altf_sel),   
.test_sel   (scan_mode ? 5'd0 : (ATM_CONFG ? 5'd1 : 5'd11)),     
.test_en    (test_en),                  
.test0_en   (scan_mode),
.test1_en   (ATM_CONFG),
.test2_en   (1'b0), 
.test3_en   (1'b0),
.test4_en   (1'b0),
.test5_en   (1'b0),
.test6_en   (1'b0),
.test7_en   (1'b0),
.test8_en   (1'b0),
.test9_en   (1'b0),
//.test10_en  (1'b0),
.test_ana   (1'b0),      //Disable IE/OE/A:: 
// alternate function
/*
// altf0
.altf0_ie   (1'b1),
.altf0_oe   (1'b0),
.altf0_a    (1'b0),
.altf0_def  (1'b0),
.altf0_y    (int_clk_out_gpio[0]),
// altf1
.altf1_ie   (1'b1),
.altf1_oe   (1'b0),
.altf1_a    (1'b0),
.altf1_def  (1'b0),
.altf1_y    (int_clk_out_gpio[1]),
// altf2
.altf2_ie   (1'b1),         
.altf2_oe   (1'b0),                         
.altf2_a    (1'b0),                         
.altf2_def  (1'b0),                         
.altf2_y    (int_clk_out_gpio[2]), 
// altf3
.altf3_ie   (1'b1),         
.altf3_oe   (1'b0),                         
.altf3_a    (1'b0),                         
.altf3_def  (1'b0),                         
.altf3_y    (int_clk_out_gpio[3]), 
*/
.altf_ie   (1'b0),
.altf_oe   (1'b1),
.altf_a    (hfosc_out),
.altf_def  (1'b0),
.altf_y    (),  
// test mode function
// test0
.test0_ie   (1'b1),    
.test0_oe   (1'b0),     
.test0_a    (1'b0),    
.test0_def  (1'b0),    
.test0_y    (scan_in[7]),
// test1
.test1_ie   (1'b1),
.test1_oe   (1'b0),
.test1_a    (1'b0),
.test1_def  (1'b0),
.test1_y    (wire_ens2_IOBUF_Y[0]),
// test2
.test2_ie   (1'b0),
.test2_oe   (1'b0),
.test2_a    (1'b0),
.test2_def  (1'b0),         
.test2_y    (),           
// test3
.test3_ie   (1'b0),
.test3_oe   (1'b0),
.test3_a    (1'b0),
.test3_def  (1'b0),
.test3_y    (),
// test4
.test4_ie   (1'b0),
.test4_oe   (1'b0),
.test4_a    (1'b0),
.test4_def  (1'b0),
.test4_y    (),
// test5
.test5_ie   (1'b0),
.test5_oe   (1'b0),
.test5_a    (1'b0),
.test5_def  (1'b0),
.test5_y    (),
// test6
.test6_ie   (1'b0),
.test6_oe   (1'b0),
.test6_a    (1'b0),
.test6_def  (1'b0),
.test6_y    (),
// test7
.test7_ie   (1'b0),
.test7_oe   (1'b0),
.test7_a    (1'b0),
.test7_def  (1'b0),
.test7_y    (),
// test8
.test8_ie   (1'b0),
.test8_oe   (1'b0),
.test8_a    (1'b0),
.test8_def  (1'b0),
.test8_y    (),
// test9
.test9_ie   (1'b0),
.test9_oe   (1'b0),
.test9_a    (1'b0),
.test9_def  (1'b0),
.test9_y    (),
// test10
// .test10_ie   (1'b0),
// .test10_oe   (1'b0),
// .test10_a    (1'b0),
// .test10_def  (1'b0),
// .test10_y    (),
// with pad interface
.iopad_gpio_y    (i_ens2_IOBUF_Y[10]),
.iopad_gpio_ie   (o_ens2_IOBUF_IE[10]),
.iopad_gpio_oe   (o_ens2_IOBUF_OE[10]),
.iopad_gpio_a    (o_ens2_IOBUF_A[10])
); 


// GPIO11 pad
// normal: int_clk_out_gpio 
// test0 : scan_in[8]
// test1 : wire_ens2_IOBUF_Y[1]
// test2 : None
// test3 : None
// test4 : None
// test5 : None
// test6 : None
// test7 : None
// test8 : None
// test9 : None
// test10: None
pinmux_1bit 
#(
.ALTF_CLKIN(0),
.TEST0_CLKIN(0),
.TEST1_CLKIN(0),
.TEST2_CLKIN(0),
.TEST3_CLKIN(0),
.TEST4_CLKIN(0),
.TEST5_CLKIN(0),
.TEST6_CLKIN(0),
.TEST7_CLKIN(0),
.TEST8_CLKIN(0),
.TEST9_CLKIN(0))
//.TEST10_CLKIN(0))
u_gpio11_pinmux (
// test and alternate select
//.altf_sel   (2'b0),   
.test_sel   (scan_mode ? 5'd0 : (ATM_CONFG ? 5'd1 : 5'd11)),     
.test_en    (test_en),                  
.test0_en   (scan_mode),
.test1_en   (ATM_CONFG),
.test2_en   (1'b0), 
.test3_en   (1'b0),
.test4_en   (1'b0),
.test5_en   (1'b0),
.test6_en   (1'b0),
.test7_en   (1'b0),
.test8_en   (1'b0),
.test9_en   (1'b0),
//.test10_en  (ATM8),
.test_ana   (1'b0),       //Disable IE/OE/A:: 
// alternate function
/*
// altf0
.altf0_ie   (1'b0),
.altf0_oe   (1'b1),
.altf0_a    (hfosc_out),
.altf0_def  (1'b0),
.altf0_y    (),
// altf1
.altf1_ie   (1'b0),         
.altf1_oe   (1'b0),                         
.altf1_a    (1'b0),                         
.altf1_def  (1'b0),                         
.altf1_y    (), 
// altf2
.altf2_ie   (1'b0),         
.altf2_oe   (1'b0),                         
.altf2_a    (1'b0),                         
.altf2_def  (1'b0),                         
.altf2_y    (), 
// altf3
.altf3_ie   (1'b0),         
.altf3_oe   (1'b0),                         
.altf3_a    (1'b0),                         
.altf3_def  (1'b0),                         
.altf3_y    (),   
*/   
.altf_ie   (1'b1),
.altf_oe   (1'b0),
.altf_a    (1'b0),
.altf_def  (1'b0),
.altf_y    (int_clk_out_gpio),
// test mode function
// test0
.test0_ie   (1'b1),     
.test0_oe   (1'b0),                     
.test0_a    (1'b0),                     
.test0_def  (1'b0),                     
.test0_y    (scan_in[8]),
// test1
.test1_ie   (1'b1),
.test1_oe   (1'b0),
.test1_a    (1'b0),
.test1_def  (1'b0),
.test1_y    (wire_ens2_IOBUF_Y[1]),
// test2
.test2_ie   (1'b0),
.test2_oe   (1'b0),
.test2_a    (1'b0),
.test2_def  (1'b0),         
.test2_y    (),           
// test3
.test3_ie   (1'b0),
.test3_oe   (1'b0),
.test3_a    (1'b0),
.test3_def  (1'b0),
.test3_y    (),
// test4
.test4_ie   (1'b0),
.test4_oe   (1'b0),
.test4_a    (1'b0),
.test4_def  (1'b0),
.test4_y    (),
// test5
.test5_ie   (1'b0),
.test5_oe   (1'b0),
.test5_a    (1'b0),
.test5_def  (1'b0),
.test5_y    (),
// test6
.test6_ie   (1'b0),
.test6_oe   (1'b0),
.test6_a    (1'b0),
.test6_def  (1'b0),
.test6_y    (),
// test7
.test7_ie   (1'b0),
.test7_oe   (1'b0),
.test7_a    (1'b0),
.test7_def  (1'b0),
.test7_y    (),
// test8
.test8_ie   (1'b0),
.test8_oe   (1'b0),
.test8_a    (1'b0),
.test8_def  (1'b0),
.test8_y    (),
// test9
.test9_ie   (1'b0),
.test9_oe   (1'b0),
.test9_a    (1'b0),
.test9_def  (1'b0),
.test9_y    (),
// test10
// .test10_ie   (1'b0),
// .test10_oe   (1'b1),
// .test10_a    (i_otp_vpp_en),
// .test10_def  (1'b0),
// .test10_y    (),
// with pad interface
.iopad_gpio_y    (i_ens2_IOBUF_Y[11]),
.iopad_gpio_ie   (o_ens2_IOBUF_IE[11]),          
.iopad_gpio_oe   (o_ens2_IOBUF_OE[11]),                                    
.iopad_gpio_a    (o_ens2_IOBUF_A[11])                                     
); 

// GPIO12 pad
// normal: A2D_COMP0 
// test0 : scan_out[0]
// test1 : wire_ens2_IOBUF_Y[2]
// test2 : None
// test3 : None
// test4 : None
// test5 : None
// test6 : None
// test7 : None
// test8 : None
// test9 : None
// test10: None

pinmux_1bit 
#(
.ALTF_CLKIN(1),
.TEST0_CLKIN(0),
.TEST1_CLKIN(0),
.TEST2_CLKIN(0),
.TEST3_CLKIN(0),
.TEST4_CLKIN(0),
.TEST5_CLKIN(0),
.TEST6_CLKIN(0),
.TEST7_CLKIN(0),
.TEST8_CLKIN(0),
.TEST9_CLKIN(0))
//.TEST10_CLKIN(0))
u_gpio12_pinmux (
// test and alternate select
//.altf_sel   (altf_sel),   
.test_sel   (scan_mode ? 5'd0 : (ATM_CONFG ? 5'd1 : 5'd11)),     
.test_en    (test_en),                  
.test0_en   (scan_mode),
.test1_en   (ATM_CONFG),
.test2_en   (1'b0), 
.test3_en   (1'b0),
.test4_en   (1'b0),
.test5_en   (1'b0),
.test6_en   (1'b0),
.test7_en   (1'b0),
.test8_en   (1'b0),
.test9_en   (1'b0),
//.test10_en  (1'b0),
.test_ana   (1'b0),      //Disable IE/OE/A:: 
// alternate function
/*
// altf0
.altf0_ie   (1'b1),
.altf0_oe   (1'b0),
.altf0_a    (1'b0),
.altf0_def  (1'b0),
.altf0_y    (int_clk_out_gpio[0]),
// altf1
.altf1_ie   (1'b1),
.altf1_oe   (1'b0),
.altf1_a    (1'b0),
.altf1_def  (1'b0),
.altf1_y    (int_clk_out_gpio[1]),
// altf2
.altf2_ie   (1'b1),         
.altf2_oe   (1'b0),                         
.altf2_a    (1'b0),                         
.altf2_def  (1'b0),                         
.altf2_y    (int_clk_out_gpio[2]), 
// altf3
.altf3_ie   (1'b1),         
.altf3_oe   (1'b0),                         
.altf3_a    (1'b0),                         
.altf3_def  (1'b0),                         
.altf3_y    (int_clk_out_gpio[3]), 
*/
.altf_ie   (1'b0),
.altf_oe   (1'b1),
.altf_a    (o_A2D_COMP0),
.altf_def  (1'b0),
.altf_y    (), 
// test mode function
// test0
.test0_ie   (1'b0), 
.test0_oe   (1'b1), 
.test0_a    (scan_out[0]), 
.test0_def  (1'b0),      
.test0_y    (),
// test1
.test1_ie   (1'b1),
.test1_oe   (1'b0),
.test1_a    (1'b0),
.test1_def  (1'b0),
.test1_y    (wire_ens2_IOBUF_Y[2]),
// test2
.test2_ie   (1'b0),
.test2_oe   (1'b0),
.test2_a    (1'b0),
.test2_def  (1'b0),         
.test2_y    (),           
// test3
.test3_ie   (1'b0),
.test3_oe   (1'b0),
.test3_a    (1'b0),
.test3_def  (1'b0),
.test3_y    (),
// test4
.test4_ie   (1'b0),
.test4_oe   (1'b0),
.test4_a    (1'b0),
.test4_def  (1'b0),
.test4_y    (),
// test5
.test5_ie   (1'b0),
.test5_oe   (1'b0),
.test5_a    (1'b0),
.test5_def  (1'b0),
.test5_y    (),
// test6
.test6_ie   (1'b0),
.test6_oe   (1'b0),
.test6_a    (1'b0),
.test6_def  (1'b0),
.test6_y    (),
// test7
.test7_ie   (1'b0),
.test7_oe   (1'b0),
.test7_a    (1'b0),
.test7_def  (1'b0),
.test7_y    (),
// test8
.test8_ie   (1'b0),
.test8_oe   (1'b0),
.test8_a    (1'b0),
.test8_def  (1'b0),
.test8_y    (),
// test9
.test9_ie   (1'b0),
.test9_oe   (1'b0),
.test9_a    (1'b0),
.test9_def  (1'b0),
.test9_y    (),
// test10
// .test10_ie   (1'b0),
// .test10_oe   (1'b0),
// .test10_a    (1'b0),
// .test10_def  (1'b0),
// .test10_y    (),
// with pad interface
.iopad_gpio_y    (i_ens2_IOBUF_Y[12]),
.iopad_gpio_ie   (o_ens2_IOBUF_IE[12]),
.iopad_gpio_oe   (o_ens2_IOBUF_OE[12]),
.iopad_gpio_a    (o_ens2_IOBUF_A[12])
); 

// GPIO13 pad
// normal:  A2D_COMP1
// test0 :  scan_out[1] 
// test1 :  wire_ens2_IOBUF_Y[3]
// test2 :  None 
// test3 :  None
// test4 :  None
// test5 :  None
// test6 :  None
// test7 :  None
// test8 :  None
// test9 :  None
// test10:  None

pinmux_1bit 
#(
.ALTF_CLKIN(0),
.TEST0_CLKIN(0),
.TEST1_CLKIN(0),
.TEST2_CLKIN(0),
.TEST3_CLKIN(0),
.TEST4_CLKIN(0),
.TEST5_CLKIN(0),
.TEST6_CLKIN(0),
.TEST7_CLKIN(0),
.TEST8_CLKIN(0),
.TEST9_CLKIN(0))
//.TEST10_CLKIN(0))
u_gpio13_pinmux (
// test and alternate select
//.altf_sel   (altf_sel),   
.test_sel   (scan_mode ? 5'd0 : (ATM_CONFG ? 5'd1 : 5'd11)),    
.test_en    (test_en),                  
.test0_en   (scan_mode),
.test1_en   (ATM_CONFG),
.test2_en   (1'b0), 
.test3_en   (1'b0),
.test4_en   (1'b0),
.test5_en   (1'b0),
.test6_en   (1'b0),
.test7_en   (1'b0),
.test8_en   (1'b0),
.test9_en   (1'b0),
//.test10_en  (1'b0),
.test_ana   (1'b0),       //Disable IE/OE/A:: 
// alternate function
/*
// altf0
.altf0_ie   (1'b0),
.altf0_oe   (1'b0),
.altf0_a    (1'b0),
.altf0_def  (1'b0),
.altf0_y    (),
// altf1
.altf1_ie   (1'b0),         
.altf1_oe   (1'b0),                         
.altf1_a    (1'b0),                         
.altf1_def  (1'b0),                         
.altf1_y    (), 
// altf2
.altf2_ie   (1'b0),         
.altf2_oe   (1'b0),                         
.altf2_a    (1'b0),                         
.altf2_def  (1'b0),                         
.altf2_y    (), 
// altf3
.altf3_ie   (1'b0),         
.altf3_oe   (1'b0),                         
.altf3_a    (1'b0),                         
.altf3_def  (1'b0),                         
.altf3_y    (),     
*/
.altf_ie   (1'b0),
.altf_oe   (1'b1),
.altf_a    (o_A2D_COMP1),
.altf_def  (1'b0),
.altf_y    (),
// test mode function
// test0
.test0_ie   (1'b0),
.test0_oe   (1'b1), 
.test0_a    (scan_out[1]),
.test0_def  (1'b0),
.test0_y    (),
// test1
.test1_ie   (1'b1),
.test1_oe   (1'b0),
.test1_a    (1'b0),
.test1_def  (1'b0),
.test1_y    (wire_ens2_IOBUF_Y[3]),
// test2
.test2_ie   (1'b0),
.test2_oe   (1'b0),
.test2_a    (1'b0),
.test2_def  (1'b0),         
.test2_y    (),           
// test3
.test3_ie   (1'b0),
.test3_oe   (1'b0),
.test3_a    (1'b0),
.test3_def  (1'b0),
.test3_y    (),
// test4
.test4_ie   (1'b0),
.test4_oe   (1'b0),
.test4_a    (1'b0),
.test4_def  (1'b0),
.test4_y    (),
// test5
.test5_ie   (1'b0),
.test5_oe   (1'b0),
.test5_a    (1'b0),
.test5_def  (1'b0),
.test5_y    (),
// test6
.test6_ie   (1'b0),
.test6_oe   (1'b0),
.test6_a    (1'b0),
.test6_def  (1'b0),
.test6_y    (),
// test7
.test7_ie   (1'b0),
.test7_oe   (1'b0),
.test7_a    (1'b0),
.test7_def  (1'b0),
.test7_y    (),
// test8
.test8_ie   (1'b0),
.test8_oe   (1'b0),
.test8_a    (1'b0),
.test8_def  (1'b0),
.test8_y    (),
// test9
.test9_ie   (1'b0),
.test9_oe   (1'b0),
.test9_a    (1'b0),
.test9_def  (1'b0),
.test9_y    (),
// test10
// .test10_ie   (1'b0),
// .test10_oe   (1'b0),
// .test10_a    (1'b0),
// .test10_def  (1'b0),
// .test10_y    (),
// with pad interface
.iopad_gpio_y    (i_ens2_IOBUF_Y[13]),
.iopad_gpio_ie   (o_ens2_IOBUF_IE[13]),
.iopad_gpio_oe   (o_ens2_IOBUF_OE[13]),
.iopad_gpio_a    (o_ens2_IOBUF_A[13])
); 

// GPIO14 pad
// normal: NIRS_LED_ON0/NIRS_RESET_SW0/NIRS_IPD_SW0/NIRS_IIN_SW0/A2D_IREFCOARSE0/A2D_IREFFINE0
// test0 : scan_out[2]
// test1 : wire_ens2_IOBUF_Y[4]
// test2 : None 
// test3 : None
// test4 : None
// test5 : None
// test6 : None
// test7 : None
// test8 : None
// test9 : None
// test10: None

pinmux_1bit 
#(
.ALTF_CLKIN(0),
.TEST0_CLKIN(0),
.TEST1_CLKIN(0),
.TEST2_CLKIN(0),
.TEST3_CLKIN(0),
.TEST4_CLKIN(0),
.TEST5_CLKIN(0),
.TEST6_CLKIN(0),
.TEST7_CLKIN(0),
.TEST8_CLKIN(0),
.TEST9_CLKIN(0))
//.TEST10_CLKIN(0))
u_gpio14_pinmux (
// test and alternate select
//.altf_sel   (altf_sel),   
.test_sel   (scan_mode ? 5'd0 : (ATM_CONFG ? 5'd1 : 5'd11)),    // this needs to be changed if more than 10 testmodes require(including scan &bist), currently scan,otpbist,ATM0-8 supported
.test_en    (test_en),                  
.test0_en   (scan_mode),
.test1_en   (ATM_CONFG),
.test2_en   (1'b0), 
.test3_en   (1'b0),
.test4_en   (1'b0),
.test5_en   (1'b0),
.test6_en   (1'b0),
.test7_en   (1'b0),
.test8_en   (1'b0),
.test9_en   (1'b0),
//.test10_en  (1'b0),
.test_ana   (1'b0),       //Disable IE/OE/A:: 
// alternate function
/*
// altf0
.altf0_ie   (1'b0),
.altf0_oe   (1'b0),
.altf0_a    (1'b0),
.altf0_def  (1'b0),
.altf0_y    (),
// altf1
.altf1_ie   (1'b0),         
.altf1_oe   (1'b0),                         
.altf1_a    (1'b0),                         
.altf1_def  (1'b0),                         
.altf1_y    (), 
// altf2
.altf2_ie   (1'b0),         
.altf2_oe   (1'b0),                         
.altf2_a    (1'b0),                         
.altf2_def  (1'b0),                         
.altf2_y    (), 
// altf3
.altf3_ie   (1'b0),
.altf3_oe   (1'b0),
.altf3_a    (1'b0),
.altf3_def  (1'b0),
.altf3_y    (),    
*/
.altf_ie   (1'b0),
.altf_oe   (1'b1),
.altf_a    (GPIO14_NORMAL_OUT),
.altf_def  (1'b0),
.altf_y    (), 
// test mode function
// test0
.test0_ie   (1'b0),     
.test0_oe   (1'b1),      
.test0_a    (scan_out[2]),
.test0_def  (1'b0),
.test0_y    (),
// test1
.test1_ie   (1'b1),
.test1_oe   (1'b0),
.test1_a    (1'b0),
.test1_def  (1'b0),
.test1_y    (wire_ens2_IOBUF_Y[4]),
// test2
.test2_ie   (1'b0),
.test2_oe   (1'b0),
.test2_a    (1'b0),
.test2_def  (1'b0),         
.test2_y    (),           
// test3
.test3_ie   (1'b0),
.test3_oe   (1'b0),
.test3_a    (1'b0),
.test3_def  (1'b0),
.test3_y    (),
// test4
.test4_ie   (1'b0),
.test4_oe   (1'b0),
.test4_a    (1'b0),
.test4_def  (1'b0),
.test4_y    (),
// test5
.test5_ie   (1'b0),
.test5_oe   (1'b0),
.test5_a    (1'b0),
.test5_def  (1'b0),
.test5_y    (),
// test6
.test6_ie   (1'b0),
.test6_oe   (1'b0),
.test6_a    (1'b0),
.test6_def  (1'b0),
.test6_y    (),
// test7
.test7_ie   (1'b0),
.test7_oe   (1'b0),
.test7_a    (1'b0),
.test7_def  (1'b0),
.test7_y    (),
// test8
.test8_ie   (1'b0),
.test8_oe   (1'b0),
.test8_a    (1'b0),
.test8_def  (1'b0),
.test8_y    (),
// test9
.test9_ie   (1'b0),
.test9_oe   (1'b0),
.test9_a    (1'b0),
.test9_def  (1'b0),
.test9_y    (),
// test10
// .test10_ie   (1'b0),
// .test10_oe   (1'b0),
// .test10_a    (1'b0),
// .test10_def  (1'b0),
// .test10_y    (),
// with pad interface
.iopad_gpio_y    (i_ens2_IOBUF_Y[14]),
.iopad_gpio_ie   (o_ens2_IOBUF_IE[14]),         
.iopad_gpio_oe   (o_ens2_IOBUF_OE[14]),                                    
.iopad_gpio_a    (o_ens2_IOBUF_A[14])                                     
); 


// GPIO15 pad
// normal: NIRS_LED_ON1 
// test0 : scan_out[3]
// test1 : None
// test2 : None 
// test3 : None
// test4 : None
// test5 : None
// test6 : None
// test7 : None
// test8 : None
// test9 : None
// test10: None

pinmux_1bit 
#(
.ALTF_CLKIN(0),
.TEST0_CLKIN(0),
.TEST1_CLKIN(0),
.TEST2_CLKIN(0),
.TEST3_CLKIN(0),
.TEST4_CLKIN(0),
.TEST5_CLKIN(0),
.TEST6_CLKIN(0),
.TEST7_CLKIN(0),
.TEST8_CLKIN(0),
.TEST9_CLKIN(0))
//.TEST10_CLKIN(0))
u_gpio15_pinmux (
// test and alternate select
//.altf_sel   (altf_sel),   
.test_sel   (test_sel),
.test_en    (test_en),
.test0_en   (scan_mode),
.test1_en   (1'b0),
.test2_en   (ATM0),
.test3_en   (ATM1),
.test4_en   (ATM2),
.test5_en   (ATM3),
.test6_en   (ATM4),
.test7_en   (ATM5),
.test8_en   (ATM6),
.test9_en   (ATM7),
//.test10_en  (ATM8),
.test_ana   (1'b0),       //Disable IE/OE/A:: TESTMODE0 GPIO0 serves pure analog signal
// alternate function
.altf_ie   (1'b0),
.altf_oe   (1'b1),
.altf_a    (NIRS_LED_ON1),
.altf_def  (1'b0),
.altf_y    (), 
// test mode function
// test0
.test0_ie   (1'b0),     
.test0_oe   (1'b1),      
.test0_a    (scan_out[3]),
.test0_def  (1'b0),
.test0_y    (),
// test1
.test1_ie   (1'b0),
.test1_oe   (1'b0),
.test1_a    (1'b0),
.test1_def  (1'b0),         
.test1_y    (),
// test2
.test2_ie   (1'b0),
.test2_oe   (1'b0),
.test2_a    (1'b0),
.test2_def  (1'b0),         
.test2_y    (),           
// test3
.test3_ie   (1'b0),
.test3_oe   (1'b0),
.test3_a    (1'b0),
.test3_def  (1'b0),
.test3_y    (),
// test4
.test4_ie   (1'b0),
.test4_oe   (1'b0),
.test4_a    (1'b0),
.test4_def  (1'b0),
.test4_y    (),
// test5
.test5_ie   (1'b0),
.test5_oe   (1'b0),
.test5_a    (1'b0),
.test5_def  (1'b0),
.test5_y    (),
// test6
.test6_ie   (1'b0),
.test6_oe   (1'b0),
.test6_a    (1'b0),
.test6_def  (1'b0),
.test6_y    (),
// test7
.test7_ie   (1'b0),
.test7_oe   (1'b0),
.test7_a    (1'b0),
.test7_def  (1'b0),
.test7_y    (),
// test8
.test8_ie   (1'b0),
.test8_oe   (1'b0),
.test8_a    (1'b0),
.test8_def  (1'b0),
.test8_y    (),
// test9
.test9_ie   (1'b0),
.test9_oe   (1'b0),
.test9_a    (1'b0),
.test9_def  (1'b0),
.test9_y    (),
// test10
// .test10_ie   (1'b0),
// .test10_oe   (1'b0),
// .test10_a    (1'b0),
// .test10_def  (1'b0),
// .test10_y    (),
// with pad interface
.iopad_gpio_y    (i_ens2_IOBUF_Y[15]),
.iopad_gpio_ie   (o_ens2_IOBUF_IE[15]),         
.iopad_gpio_oe   (o_ens2_IOBUF_OE[15]),                                    
.iopad_gpio_a    (o_ens2_IOBUF_A[15])                                     
); 


// GPIO16 pad
// normal: NIRS_LED_ON2 
// test0 : scan_out[4]
// test1 : None
// test2 : None 
// test3 : None
// test4 : None
// test5 : None
// test6 : None
// test7 : None
// test8 : None
// test9 : None
// test10: None

pinmux_1bit 
#(
.ALTF_CLKIN(0),
.TEST0_CLKIN(0),
.TEST1_CLKIN(0),
.TEST2_CLKIN(0),
.TEST3_CLKIN(0),
.TEST4_CLKIN(0),
.TEST5_CLKIN(0),
.TEST6_CLKIN(0),
.TEST7_CLKIN(0),
.TEST8_CLKIN(0),
.TEST9_CLKIN(0))
//.TEST10_CLKIN(0))
u_gpio16_pinmux (
// test and alternate select
//.altf_sel   (altf_sel),   
.test_sel   (test_sel),
.test_en    (test_en),
.test0_en   (scan_mode),
.test1_en   (1'b0),
.test2_en   (ATM0),
.test3_en   (ATM1),
.test4_en   (ATM2),
.test5_en   (ATM3),
.test6_en   (ATM4),
.test7_en   (ATM5),
.test8_en   (ATM6),
.test9_en   (ATM7),
//.test10_en  (ATM8),
.test_ana   (1'b0),       //Disable IE/OE/A:: TESTMODE0 GPIO0 serves pure analog signal
// alternate function
.altf_ie   (1'b0),
.altf_oe   (1'b1),
.altf_a    (NIRS_LED_ON2),
.altf_def  (1'b0),
.altf_y    (), 
// test mode function
// test0
.test0_ie   (1'b0),     
.test0_oe   (1'b1),      
.test0_a    (scan_out[4]),
.test0_def  (1'b0),
.test0_y    (),
// test1
.test1_ie   (1'b0),
.test1_oe   (1'b0),
.test1_a    (1'b0),
.test1_def  (1'b0),         
.test1_y    (),
// test2
.test2_ie   (1'b0),
.test2_oe   (1'b0),
.test2_a    (1'b0),
.test2_def  (1'b0),         
.test2_y    (),           
// test3
.test3_ie   (1'b0),
.test3_oe   (1'b0),
.test3_a    (1'b0),
.test3_def  (1'b0),
.test3_y    (),
// test4
.test4_ie   (1'b0),
.test4_oe   (1'b0),
.test4_a    (1'b0),
.test4_def  (1'b0),
.test4_y    (),
// test5
.test5_ie   (1'b0),
.test5_oe   (1'b0),
.test5_a    (1'b0),
.test5_def  (1'b0),
.test5_y    (),
// test6
.test6_ie   (1'b0),
.test6_oe   (1'b0),
.test6_a    (1'b0),
.test6_def  (1'b0),
.test6_y    (),
// test7
.test7_ie   (1'b0),
.test7_oe   (1'b0),
.test7_a    (1'b0),
.test7_def  (1'b0),
.test7_y    (),
// test8
.test8_ie   (1'b0),
.test8_oe   (1'b0),
.test8_a    (1'b0),
.test8_def  (1'b0),
.test8_y    (),
// test9
.test9_ie   (1'b0),
.test9_oe   (1'b0),
.test9_a    (1'b0),
.test9_def  (1'b0),
.test9_y    (),
// test10
// .test10_ie   (1'b0),
// .test10_oe   (1'b0),
// .test10_a    (1'b0),
// .test10_def  (1'b0),
// .test10_y    (),
// with pad interface
.iopad_gpio_y    (i_ens2_IOBUF_Y[16]),
.iopad_gpio_ie   (o_ens2_IOBUF_IE[16]),         
.iopad_gpio_oe   (o_ens2_IOBUF_OE[16]),                                    
.iopad_gpio_a    (o_ens2_IOBUF_A[16])                                     
); 

// GPIO17 pad
// normal: NIRS_LED_ON3
// test0 : scan_out[5]
// test1 : None
// test2 : None 
// test3 : None
// test4 : None
// test5 : None
// test6 : None
// test7 : None
// test8 : None
// test9 : None
// test10: None

pinmux_1bit 
#(
.ALTF_CLKIN(0),
.TEST0_CLKIN(0),
.TEST1_CLKIN(0),
.TEST2_CLKIN(0),
.TEST3_CLKIN(0),
.TEST4_CLKIN(0),
.TEST5_CLKIN(0),
.TEST6_CLKIN(0),
.TEST7_CLKIN(0),
.TEST8_CLKIN(0),
.TEST9_CLKIN(0))
//.TEST10_CLKIN(0))
u_gpio17_pinmux (
// test and alternate select
//.altf_sel   (altf_sel),   
.test_sel   (test_sel),
.test_en    (test_en),
.test0_en   (scan_mode),
.test1_en   (1'b0),
.test2_en   (ATM0),
.test3_en   (ATM1),
.test4_en   (ATM2),
.test5_en   (ATM3),
.test6_en   (ATM4),
.test7_en   (ATM5),
.test8_en   (ATM6),
.test9_en   (ATM7),
//.test10_en  (ATM8),
.test_ana   (1'b0),       //Disable IE/OE/A:: TESTMODE0 GPIO0 serves pure analog signal
// alternate function
.altf_ie   (1'b0),
.altf_oe   (1'b1),
.altf_a    (NIRS_LED_ON3),
.altf_def  (1'b0),
.altf_y    (), 
// test mode function
// test0
.test0_ie   (1'b0),     
.test0_oe   (1'b1),      
.test0_a    (scan_out[5]),
.test0_def  (1'b0),
.test0_y    (),
// test1
.test1_ie   (1'b0),
.test1_oe   (1'b0),
.test1_a    (1'b0),
.test1_def  (1'b0),         
.test1_y    (),
// test2
.test2_ie   (1'b0),
.test2_oe   (1'b0),
.test2_a    (1'b0),
.test2_def  (1'b0),         
.test2_y    (),           
// test3
.test3_ie   (1'b0),
.test3_oe   (1'b0),
.test3_a    (1'b0),
.test3_def  (1'b0),
.test3_y    (),
// test4
.test4_ie   (1'b0),
.test4_oe   (1'b0),
.test4_a    (1'b0),
.test4_def  (1'b0),
.test4_y    (),
// test5
.test5_ie   (1'b0),
.test5_oe   (1'b0),
.test5_a    (1'b0),
.test5_def  (1'b0),
.test5_y    (),
// test6
.test6_ie   (1'b0),
.test6_oe   (1'b0),
.test6_a    (1'b0),
.test6_def  (1'b0),
.test6_y    (),
// test7
.test7_ie   (1'b0),
.test7_oe   (1'b0),
.test7_a    (1'b0),
.test7_def  (1'b0),
.test7_y    (),
// test8
.test8_ie   (1'b0),
.test8_oe   (1'b0),
.test8_a    (1'b0),
.test8_def  (1'b0),
.test8_y    (),
// test9
.test9_ie   (1'b0),
.test9_oe   (1'b0),
.test9_a    (1'b0),
.test9_def  (1'b0),
.test9_y    (),
// test10
// .test10_ie   (1'b0),
// .test10_oe   (1'b0),
// .test10_a    (1'b0),
// .test10_def  (1'b0),
// .test10_y    (),
// with pad interface
.iopad_gpio_y    (i_ens2_IOBUF_Y[17]),
.iopad_gpio_ie   (o_ens2_IOBUF_IE[17]),         
.iopad_gpio_oe   (o_ens2_IOBUF_OE[17]),                                    
.iopad_gpio_a    (o_ens2_IOBUF_A[17])                                     
); 
// GPIO18 pad
// normal: NIRS_LED_ON4 
// test0 : scan_out[6]
// test1 : None
// test2 : None 
// test3 : None
// test4 : None
// test5 : None
// test6 : None
// test7 : None
// test8 : None
// test9 : None
// test10: None

pinmux_1bit 
#(
.ALTF_CLKIN(0),
.TEST0_CLKIN(0),
.TEST1_CLKIN(0),
.TEST2_CLKIN(0),
.TEST3_CLKIN(0),
.TEST4_CLKIN(0),
.TEST5_CLKIN(0),
.TEST6_CLKIN(0),
.TEST7_CLKIN(0),
.TEST8_CLKIN(0),
.TEST9_CLKIN(0))
//.TEST10_CLKIN(0))
u_gpio18_pinmux (
// test and alternate select
//.altf_sel   (altf_sel),   
.test_sel   (test_sel),
.test_en    (test_en),
.test0_en   (scan_mode),
.test1_en   (1'b0),
.test2_en   (ATM0),
.test3_en   (ATM1),
.test4_en   (ATM2),
.test5_en   (ATM3),
.test6_en   (ATM4),
.test7_en   (ATM5),
.test8_en   (ATM6),
.test9_en   (ATM7),
//.test10_en  (ATM8),
.test_ana   (1'b0),       //Disable IE/OE/A:: TESTMODE0 GPIO0 serves pure analog signal
// alternate function
.altf_ie   (1'b0),
.altf_oe   (1'b1),
.altf_a    (NIRS_LED_ON4),
.altf_def  (1'b0),
.altf_y    (), 
// test mode function
// test0
.test0_ie   (1'b0),     
.test0_oe   (1'b1),      
.test0_a    (scan_out[6]),
.test0_def  (1'b0),
.test0_y    (),
// test1
.test1_ie   (1'b0),
.test1_oe   (1'b0),
.test1_a    (1'b0),
.test1_def  (1'b0),         
.test1_y    (),
// test2
.test2_ie   (1'b0),
.test2_oe   (1'b0),
.test2_a    (1'b0),
.test2_def  (1'b0),         
.test2_y    (),           
// test3
.test3_ie   (1'b0),
.test3_oe   (1'b0),
.test3_a    (1'b0),
.test3_def  (1'b0),
.test3_y    (),
// test4
.test4_ie   (1'b0),
.test4_oe   (1'b0),
.test4_a    (1'b0),
.test4_def  (1'b0),
.test4_y    (),
// test5
.test5_ie   (1'b0),
.test5_oe   (1'b0),
.test5_a    (1'b0),
.test5_def  (1'b0),
.test5_y    (),
// test6
.test6_ie   (1'b0),
.test6_oe   (1'b0),
.test6_a    (1'b0),
.test6_def  (1'b0),
.test6_y    (),
// test7
.test7_ie   (1'b0),
.test7_oe   (1'b0),
.test7_a    (1'b0),
.test7_def  (1'b0),
.test7_y    (),
// test8
.test8_ie   (1'b0),
.test8_oe   (1'b0),
.test8_a    (1'b0),
.test8_def  (1'b0),
.test8_y    (),
// test9
.test9_ie   (1'b0),
.test9_oe   (1'b0),
.test9_a    (1'b0),
.test9_def  (1'b0),
.test9_y    (),
// test10
// .test10_ie   (1'b0),
// .test10_oe   (1'b0),
// .test10_a    (1'b0),
// .test10_def  (1'b0),
// .test10_y    (),
// with pad interface
.iopad_gpio_y    (i_ens2_IOBUF_Y[18]),
.iopad_gpio_ie   (o_ens2_IOBUF_IE[18]),         
.iopad_gpio_oe   (o_ens2_IOBUF_OE[18]),                                    
.iopad_gpio_a    (o_ens2_IOBUF_A[18])                                     
); 
// GPIO19 pad
// normal: NIRS_LED_ON5 
// test0 : scan_out[7]
// test1 : None
// test2 : None 
// test3 : None
// test4 : None
// test5 : None
// test6 : None
// test7 : None
// test8 : None
// test9 : None
// test10: None

pinmux_1bit 
#(
.ALTF_CLKIN(0),
.TEST0_CLKIN(0),
.TEST1_CLKIN(0),
.TEST2_CLKIN(0),
.TEST3_CLKIN(0),
.TEST4_CLKIN(0),
.TEST5_CLKIN(0),
.TEST6_CLKIN(0),
.TEST7_CLKIN(0),
.TEST8_CLKIN(0),
.TEST9_CLKIN(0))
//.TEST10_CLKIN(0))
u_gpio19_pinmux (
// test and alternate select
//.altf_sel   (altf_sel),   
.test_sel   (test_sel),
.test_en    (test_en),
.test0_en   (scan_mode),
.test1_en   (1'b0),
.test2_en   (ATM0),
.test3_en   (ATM1),
.test4_en   (ATM2),
.test5_en   (ATM3),
.test6_en   (ATM4),
.test7_en   (ATM5),
.test8_en   (ATM6),
.test9_en   (ATM7),
//.test10_en  (ATM8),
.test_ana   (1'b0),       //Disable IE/OE/A:: TESTMODE0 GPIO0 serves pure analog signal
// alternate function
.altf_ie   (1'b0),
.altf_oe   (1'b1),
.altf_a    (NIRS_LED_ON5),
.altf_def  (1'b0),
.altf_y    (), 
// test mode function
// test0
.test0_ie   (1'b0),     
.test0_oe   (1'b1),      
.test0_a    (scan_out[7]),
.test0_def  (1'b0),
.test0_y    (),
// test1
.test1_ie   (1'b0),
.test1_oe   (1'b0),
.test1_a    (1'b0),
.test1_def  (1'b0),         
.test1_y    (),
// test2
.test2_ie   (1'b0),
.test2_oe   (1'b0),
.test2_a    (1'b0),
.test2_def  (1'b0),         
.test2_y    (),           
// test3
.test3_ie   (1'b0),
.test3_oe   (1'b0),
.test3_a    (1'b0),
.test3_def  (1'b0),
.test3_y    (),
// test4
.test4_ie   (1'b0),
.test4_oe   (1'b0),
.test4_a    (1'b0),
.test4_def  (1'b0),
.test4_y    (),
// test5
.test5_ie   (1'b0),
.test5_oe   (1'b0),
.test5_a    (1'b0),
.test5_def  (1'b0),
.test5_y    (),
// test6
.test6_ie   (1'b0),
.test6_oe   (1'b0),
.test6_a    (1'b0),
.test6_def  (1'b0),
.test6_y    (),
// test7
.test7_ie   (1'b0),
.test7_oe   (1'b0),
.test7_a    (1'b0),
.test7_def  (1'b0),
.test7_y    (),
// test8
.test8_ie   (1'b0),
.test8_oe   (1'b0),
.test8_a    (1'b0),
.test8_def  (1'b0),
.test8_y    (),
// test9
.test9_ie   (1'b0),
.test9_oe   (1'b0),
.test9_a    (1'b0),
.test9_def  (1'b0),
.test9_y    (),
// test10
// .test10_ie   (1'b0),
// .test10_oe   (1'b0),
// .test10_a    (1'b0),
// .test10_def  (1'b0),
// .test10_y    (),
// with pad interface
.iopad_gpio_y    (i_ens2_IOBUF_Y[19]),
.iopad_gpio_ie   (o_ens2_IOBUF_IE[19]),         
.iopad_gpio_oe   (o_ens2_IOBUF_OE[19]),                                    
.iopad_gpio_a    (o_ens2_IOBUF_A[19])                                     
); 
// GPIO20 pad
// normal: NIRS_LED_ON6 
// test0 : scan_out[8]
// test1 : None
// test2 : None 
// test3 : None
// test4 : None
// test5 : None
// test6 : None
// test7 : None
// test8 : None
// test9 : None
// test10: None

pinmux_1bit 
#(
.ALTF_CLKIN(0),
.TEST0_CLKIN(0),
.TEST1_CLKIN(0),
.TEST2_CLKIN(0),
.TEST3_CLKIN(0),
.TEST4_CLKIN(0),
.TEST5_CLKIN(0),
.TEST6_CLKIN(0),
.TEST7_CLKIN(0),
.TEST8_CLKIN(0),
.TEST9_CLKIN(0))
//.TEST10_CLKIN(0))
u_gpio20_pinmux (
// test and alternate select
//.altf_sel   (altf_sel),   
.test_sel   (test_sel),
.test_en    (test_en),
.test0_en   (scan_mode),
.test1_en   (1'b0),
.test2_en   (ATM0),
.test3_en   (ATM1),
.test4_en   (ATM2),
.test5_en   (ATM3),
.test6_en   (ATM4),
.test7_en   (ATM5),
.test8_en   (ATM6),
.test9_en   (ATM7),
//.test10_en  (ATM8),
.test_ana   (1'b0),       //Disable IE/OE/A:: TESTMODE0 GPIO0 serves pure analog signal
// alternate function
.altf_ie   (1'b0),
.altf_oe   (1'b1),
.altf_a    (NIRS_LED_ON6),
.altf_def  (1'b0),
.altf_y    (), 
// test mode function
// test0
.test0_ie   (1'b0),     
.test0_oe   (1'b1),      
.test0_a    (scan_out[8]),
.test0_def  (1'b0),
.test0_y    (),
// test1
.test1_ie   (1'b0),
.test1_oe   (1'b0),
.test1_a    (1'b0),
.test1_def  (1'b0),         
.test1_y    (),
// test2
.test2_ie   (1'b0),
.test2_oe   (1'b0),
.test2_a    (1'b0),
.test2_def  (1'b0),         
.test2_y    (),           
// test3
.test3_ie   (1'b0),
.test3_oe   (1'b0),
.test3_a    (1'b0),
.test3_def  (1'b0),
.test3_y    (),
// test4
.test4_ie   (1'b0),
.test4_oe   (1'b0),
.test4_a    (1'b0),
.test4_def  (1'b0),
.test4_y    (),
// test5
.test5_ie   (1'b0),
.test5_oe   (1'b0),
.test5_a    (1'b0),
.test5_def  (1'b0),
.test5_y    (),
// test6
.test6_ie   (1'b0),
.test6_oe   (1'b0),
.test6_a    (1'b0),
.test6_def  (1'b0),
.test6_y    (),
// test7
.test7_ie   (1'b0),
.test7_oe   (1'b0),
.test7_a    (1'b0),
.test7_def  (1'b0),
.test7_y    (),
// test8
.test8_ie   (1'b0),
.test8_oe   (1'b0),
.test8_a    (1'b0),
.test8_def  (1'b0),
.test8_y    (),
// test9
.test9_ie   (1'b0),
.test9_oe   (1'b0),
.test9_a    (1'b0),
.test9_def  (1'b0),
.test9_y    (),
// test10
// .test10_ie   (1'b0),
// .test10_oe   (1'b0),
// .test10_a    (1'b0),
// .test10_def  (1'b0),
// .test10_y    (),
// with pad interface
.iopad_gpio_y    (i_ens2_IOBUF_Y[20]),
.iopad_gpio_ie   (o_ens2_IOBUF_IE[20]),         
.iopad_gpio_oe   (o_ens2_IOBUF_OE[20]),                                    
.iopad_gpio_a    (o_ens2_IOBUF_A[20])                                     
); 
// GPIO21 pad
// normal: NIRS_LED_ON7 
// test0 : None
// test1 : None
// test2 : None 
// test3 : None
// test4 : None
// test5 : None
// test6 : None
// test7 : None
// test8 : None
// test9 : None
// test10: None

pinmux_1bit 
#(
.ALTF_CLKIN(0),
.TEST0_CLKIN(0),
.TEST1_CLKIN(0),
.TEST2_CLKIN(0),
.TEST3_CLKIN(0),
.TEST4_CLKIN(0),
.TEST5_CLKIN(0),
.TEST6_CLKIN(0),
.TEST7_CLKIN(0),
.TEST8_CLKIN(0),
.TEST9_CLKIN(0))
//.TEST10_CLKIN(0))
u_gpio21_pinmux (
// test and alternate select
//.altf_sel   (altf_sel),   
.test_sel   (test_sel),
.test_en    (test_en),
.test0_en   (scan_mode),
.test1_en   (1'b0),
.test2_en   (ATM0),
.test3_en   (ATM1),
.test4_en   (ATM2),
.test5_en   (ATM3),
.test6_en   (ATM4),
.test7_en   (ATM5),
.test8_en   (ATM6),
.test9_en   (ATM7),
//.test10_en  (ATM8),
.test_ana   (1'b0),       //Disable IE/OE/A:: TESTMODE0 GPIO0 serves pure analog signal
// alternate function
.altf_ie   (1'b0),
.altf_oe   (1'b1),
.altf_a    (NIRS_LED_ON7),
.altf_def  (1'b0),
.altf_y    (), 
// test mode function
// test0
.test0_ie   (1'b0),
.test0_oe   (1'b0),
.test0_a    (1'b0),
.test0_def  (1'b0),         
.test0_y    (),
// test1
.test1_ie   (1'b0),
.test1_oe   (1'b0),
.test1_a    (1'b0),
.test1_def  (1'b0),         
.test1_y    (),
// test2
.test2_ie   (1'b0),
.test2_oe   (1'b0),
.test2_a    (1'b0),
.test2_def  (1'b0),         
.test2_y    (),           
// test3
.test3_ie   (1'b0),
.test3_oe   (1'b0),
.test3_a    (1'b0),
.test3_def  (1'b0),
.test3_y    (),
// test4
.test4_ie   (1'b0),
.test4_oe   (1'b0),
.test4_a    (1'b0),
.test4_def  (1'b0),
.test4_y    (),
// test5
.test5_ie   (1'b0),
.test5_oe   (1'b0),
.test5_a    (1'b0),
.test5_def  (1'b0),
.test5_y    (),
// test6
.test6_ie   (1'b0),
.test6_oe   (1'b0),
.test6_a    (1'b0),
.test6_def  (1'b0),
.test6_y    (),
// test7
.test7_ie   (1'b0),
.test7_oe   (1'b0),
.test7_a    (1'b0),
.test7_def  (1'b0),
.test7_y    (),
// test8
.test8_ie   (1'b0),
.test8_oe   (1'b0),
.test8_a    (1'b0),
.test8_def  (1'b0),
.test8_y    (),
// test9
.test9_ie   (1'b0),
.test9_oe   (1'b0),
.test9_a    (1'b0),
.test9_def  (1'b0),
.test9_y    (),
// test10
// .test10_ie   (1'b0),
// .test10_oe   (1'b0),
// .test10_a    (1'b0),
// .test10_def  (1'b0),
// .test10_y    (),
// with pad interface
.iopad_gpio_y    (i_ens2_IOBUF_Y[21]),
.iopad_gpio_ie   (o_ens2_IOBUF_IE[21]),         
.iopad_gpio_oe   (o_ens2_IOBUF_OE[21]),                                    
.iopad_gpio_a    (o_ens2_IOBUF_A[21])                                     
); 
/*
// GPIO14 pad
// normal: None 
// test0 : scan_out[5]
// test1 : wire_ens2_IOBUF_Y[2]
// test2 : None 
// test3 : None
// test4 : None
// test5 : None
// test6 : None
// test7 : None
// test8 : None
// test9 : None
// test10: None

pinmux_1bit 
#(
.ALTF_CLKIN(0),
.TEST0_CLKIN(0),
.TEST1_CLKIN(0),
.TEST2_CLKIN(0),
.TEST3_CLKIN(0),
.TEST4_CLKIN(0),
.TEST5_CLKIN(0),
.TEST6_CLKIN(0),
.TEST7_CLKIN(0),
.TEST8_CLKIN(0),
.TEST9_CLKIN(0),
.TEST10_CLKIN(0))
u_gpio14_pinmux (
// test and alternate select
//.altf_sel   (altf_sel),   
.test_sel   (scan_mode ? 4'd0 : (ATM_CONFG ? 4'd1 : 4'd11)),// this needs to be changed if more than 10 testmodes require(including scan &bist), currently scan,otpbist,ATM0-8 supported
.test_en    (test_en),                  
.test0_en   (scan_mode),
.test1_en   (ATM_CONFG),
.test2_en   (1'b0), 
.test3_en   (1'b0),
.test4_en   (1'b0),
.test5_en   (1'b0),
.test6_en   (1'b0),
.test7_en   (1'b0),
.test8_en   (1'b0),
.test9_en   (1'b0),
.test10_en  (1'b0),
.test_ana   (1'b0),       //Disable IE/OE/A:: 
// alternate function
// altf0
.altf0_ie   (1'b0),
.altf0_oe   (1'b0),
.altf0_a    (1'b0),
.altf0_def  (1'b0),
.altf0_y    (),
// altf1
.altf1_ie   (1'b0),         
.altf1_oe   (1'b0),                         
.altf1_a    (1'b0),                         
.altf1_def  (1'b0),                         
.altf1_y    (), 
// altf2
.altf2_ie   (1'b0),         
.altf2_oe   (1'b1),                         
.altf2_a    (INTB),                         
.altf2_def  (1'b0),                         
.altf2_y    (), 
// altf3
.altf3_ie   (1'b0),         
.altf3_oe   (1'b0),                         
.altf3_a    (1'b0),                         
.altf3_def  (1'b0),                         
.altf3_y    (),      
.altf_ie   (1'b0),
.altf_oe   (1'b0),
.altf_a    (1'b0),
.altf_def  (1'b0),
.altf_y    (),
// test mode function
// test0
.test0_ie   (1'b0),     
.test0_oe   (1'b1),      
.test0_a    (scan_out[5]),
.test0_def  (1'b0),
.test0_y    (),
// test1
.test1_ie   (1'b1),
.test1_oe   (1'b0),
.test1_a    (1'b0),
.test1_def  (1'b0),
.test1_y    (wire_ens2_IOBUF_Y[2]),
// test2
.test2_ie   (1'b0),
.test2_oe   (1'b0),
.test2_a    (1'b0),
.test2_def  (1'b0),         
.test2_y    (),           
// test3
.test3_ie   (1'b0),
.test3_oe   (1'b0),
.test3_a    (1'b0),
.test3_def  (1'b0),
.test3_y    (),
// test4
.test4_ie   (1'b0),
.test4_oe   (1'b0),
.test4_a    (1'b0),
.test4_def  (1'b0),
.test4_y    (),
// test5
.test5_ie   (1'b0),
.test5_oe   (1'b0),
.test5_a    (1'b0),
.test5_def  (1'b0),
.test5_y    (),
// test6
.test6_ie   (1'b0),
.test6_oe   (1'b0),
.test6_a    (1'b0),
.test6_def  (1'b0),
.test6_y    (),
// test7
.test7_ie   (1'b0),
.test7_oe   (1'b0),
.test7_a    (1'b0),
.test7_def  (1'b0),
.test7_y    (),
// test8
.test8_ie   (1'b0),
.test8_oe   (1'b0),
.test8_a    (1'b0),
.test8_def  (1'b0),
.test8_y    (),
// test9
.test9_ie   (1'b0),
.test9_oe   (1'b0),
.test9_a    (1'b0),
.test9_def  (1'b0),
.test9_y    (),
// test10
.test10_ie   (1'b0),
.test10_oe   (1'b0),
.test10_a    (1'b0),
.test10_def  (1'b0),
.test10_y    (),
// with pad interface
.iopad_gpio_y    (i_ens2_IOBUF_Y[14]),
.iopad_gpio_ie   (o_ens2_IOBUF_IE[14]),         
.iopad_gpio_oe   (o_ens2_IOBUF_OE[14]),                                    
.iopad_gpio_a    (o_ens2_IOBUF_A[14])                                     
); 

// GPIO15 pad
// normal: None 
// test0 : None
// test1 : wire_ens2_IOBUF_Y[3]
// test2 : None 
// test3 : None
// test4 : None
// test5 : None
// test6 : None
// test7 : None
// test8 : None
// test9 : None
// test10: None

pinmux_1bit 
#(
.ALTF_CLKIN(0),
.TEST0_CLKIN(0),
.TEST1_CLKIN(0),
.TEST2_CLKIN(0),
.TEST3_CLKIN(0),
.TEST4_CLKIN(0),
.TEST5_CLKIN(0),
.TEST6_CLKIN(0),
.TEST7_CLKIN(0),
.TEST8_CLKIN(0),
.TEST9_CLKIN(0),
.TEST10_CLKIN(0))
u_gpio15_pinmux (
// test and alternate select
//.altf_sel   (altf_sel),   
.test_sel   (4'd1),
.test_en    (test_en),                  
.test0_en   (1'b0),
.test1_en   (ATM_CONFG),
.test2_en   (1'b0), 
.test3_en   (1'b0),
.test4_en   (1'b0),
.test5_en   (1'b0),
.test6_en   (1'b0),
.test7_en   (1'b0),
.test8_en   (1'b0),
.test9_en   (1'b0),
.test10_en  (1'b0),
.test_ana   (1'b0),       //Disable IE/OE/A:: 
// alternate function
// altf0
.altf0_ie   (1'b0),
.altf0_oe   (1'b0),
.altf0_a    (1'b0),
.altf0_def  (1'b0),
.altf0_y    (),
// altf1
.altf1_ie   (1'b0),         
.altf1_oe   (1'b0),                         
.altf1_a    (1'b0),                         
.altf1_def  (1'b0),                         
.altf1_y    (), 
// altf2
.altf2_ie   (1'b0),         
.altf2_oe   (1'b0),                         
.altf2_a    (1'b0),                         
.altf2_def  (1'b0),                         
.altf2_y    (), 
// altf3
.altf3_ie   (1'b0),         
.altf3_oe   (1'b0),                         
.altf3_a    (1'b0),                         
.altf3_def  (1'b0),                         
.altf3_y    (),    
.altf_ie   (1'b0),
.altf_oe   (1'b0),
.altf_a    (1'b0),
.altf_def  (1'b0),
.altf_y    (),
// test mode function
// test0
.test0_ie   (1'b0),
.test0_oe   (1'b0), 
.test0_a    (1'b0),
.test0_def  (1'b0),
.test0_y    (),
// test1
.test1_ie   (1'b1),
.test1_oe   (1'b0),
.test1_a    (1'b0),
.test1_def  (1'b0),
.test1_y    (wire_ens2_IOBUF_Y[3]),
// test2
.test2_ie   (1'b0),
.test2_oe   (1'b0),
.test2_a    (1'b0),
.test2_def  (1'b0),         
.test2_y    (),           
// test3
.test3_ie   (1'b0),
.test3_oe   (1'b0),
.test3_a    (1'b0),
.test3_def  (1'b0),
.test3_y    (),
// test4
.test4_ie   (1'b0),
.test4_oe   (1'b0),
.test4_a    (1'b0),
.test4_def  (1'b0),
.test4_y    (),
// test5
.test5_ie   (1'b0),
.test5_oe   (1'b0),
.test5_a    (1'b0),
.test5_def  (1'b0),
.test5_y    (),
// test6
.test6_ie   (1'b0),
.test6_oe   (1'b0),
.test6_a    (1'b0),
.test6_def  (1'b0),
.test6_y    (),
// test7
.test7_ie   (1'b0),
.test7_oe   (1'b0),
.test7_a    (1'b0),
.test7_def  (1'b0),
.test7_y    (),
// test8
.test8_ie   (1'b0),
.test8_oe   (1'b0),
.test8_a    (1'b0),
.test8_def  (1'b0),
.test8_y    (),
// test9
.test9_ie   (1'b0),
.test9_oe   (1'b0),
.test9_a    (1'b0),
.test9_def  (1'b0),
.test9_y    (),
// test10
.test10_ie   (1'b0),
.test10_oe   (1'b0),
.test10_a    (1'b0),
.test10_def  (1'b0),
.test10_y    (),
// with pad interface
.iopad_gpio_y    (i_ens2_IOBUF15_Y),
.iopad_gpio_ie   (o_ens2_IOBUF_IE[15]),         
.iopad_gpio_oe   (o_ens2_IOBUF_OE[15]),                                    
.iopad_gpio_a    (o_ens2_IOBUF_A[15])                                     
); 
*/
endmodule
