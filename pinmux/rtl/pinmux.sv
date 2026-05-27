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
  output wire         mosi1,
  input  wire         miso,
  input  wire         miso1,
  input  wire         dual_en,
  input  wire         dual_wr,
  output wire         o_cpoln,   
  output wire         o_cpha,
  output wire         o_DAISY_IN, 

  input  wire 	     multi_intb_pin,

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
 // input  wire         i_lead_off_int,  
//input  wire 	      i_lvd_intr_pin,
//input  wire 	      i_comp_ch1_intr_pin,
//input  wire 	      i_comp_ch2_intr_pin, 
//input  wire 	      i_stimu_ch1_intr_pin,
//input  wire 	      i_stimu_ch2_intr_pin, 
  input  wire         i_anac_int,
  input  wire         i_tsc_int,
  input  wire         i_eeg_int,
  input  wire         i_nirs_int,
  input  wire         i_stim_mon_int,

  output wire         pin_rstn,

  //debug modes
  output wire         o_OTP_UNLOCK,
  output wire [14:0]   o_OTP_ATM_MODE_SEL,
  output wire         o_OTP_ANA_TESTMODE,
  output wire [7:0]   o_OTP_ATM_TRIM_DATA,

  input wire  [7:0]   sys_d2a_trim_reg        [14:0], 
  output wire [14:0]  o_SPI_ATM_MODE_SEL,
  output wire         o_SPI_ANA_TESTMODE,
  output wire [7:0]   o_SPI_ATM_ADJ_DATA,

  input  wire         i_gpio_normal_out_ctrl,
//input  wire         COMP_OUT_EN,
//input  wire         COMP_OUT_SEL,
//input  wire         o_A2D_COMP0,
//input  wire         o_A2D_COMP1,
//input  wire         COMP_OUT_SEL_STIM,
//input  wire         A2D_STIMU0_1,
//input  wire         A2D_STIMU2_3,
//input  wire         COMP_OUT_SEL,
  
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
  input  wire     i_gpio_nirs_out_ctrl,

  pinmux_if.D2A         pinmux_if,
  spi_pinmux_if.pinmux  spi_pinmux_if,

// TSC
  input wire   [7:0]  d2a_tsc_vdac8b_din_ch1,
//input wire          d2a_tsc_vdac8b_en_ch1,
//input wire          d2a_tsc_comp_en_ch1,
  input wire          d2a_tsc_en_ch1,

// WG 
  input wire          i_ds_driver_en_current,
  input wire          i_stimu_en
);
  wire        GPIO8_NORMAL_OUT;
  wire        GPIO15_NORMAL_OUT;
  wire        GPIO16_NORMAL_OUT;
  wire        GPIO17_NORMAL_OUT;
  wire        GPIO18_NORMAL_OUT;
  wire        GPIO19_NORMAL_OUT;
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
  wire        pad_mosi1;
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
  wire        ATM8;
  wire        ATM9;
  wire        ATM10;
  wire        ATM11;
  wire        ATM12;
  wire        ATM13;
  wire        ATM14;
  wire        ATM15;
  wire        ATM16;
  wire        ATM17;
  wire        ATM18;
  wire        ATM19;
  wire        ATM20;
  wire        ATM21;
  wire        ATM22;
  wire        ATM23;
  wire        ATM24;
  wire        ATM25;
  wire        ATM26;
  wire        ATM27;
  wire        ATM28;
  wire        ATM29;
  wire [7:0]  pad_d2a_trim0_sig;
  wire [7:0]  pad_d2a_trim1_sig;
  wire [7:0]  pad_d2a_trim2_sig;
  wire [7:0]  pad_d2a_trim3_sig;
  wire [7:0]  pad_d2a_trim4_sig;
  wire [7:0]  pad_d2a_trim5_sig;
  wire [7:0]  pad_d2a_trim6_sig;
  wire [7:0]  pad_d2a_trim7_sig;
  wire [7:0]  pad_d2a_trim8_sig;
  wire [7:0]  pad_d2a_trim9_sig;
  wire [7:0]  pad_d2a_trim10_sig;
  wire [7:0]  pad_d2a_trim11_sig;
  wire [7:0]  pad_d2a_trim12_sig;
  wire [7:0]  pad_d2a_trim13_sig;
  wire [7:0]  pad_d2a_trim14_sig;
  wire [7:0]  pad_d2a_adj0_sig; 
  wire [7:0]  pad_d2a_adj1_sig;
  wire [7:0]  pad_d2a_adj2_sig;
  wire [7:0]  pad_d2a_adj3_sig;
  wire [7:0]  pad_d2a_adj4_sig;
  wire [7:0]  pad_d2a_adj5_sig;
  wire [7:0]  pad_d2a_adj6_sig;
  wire [7:0]  pad_d2a_adj7_sig;
  wire [7:0]  pad_d2a_adj8_sig;
  wire [7:0]  pad_d2a_adj9_sig;
  wire [7:0]  pad_d2a_adj10_sig;
  wire [7:0]  pad_d2a_adj11_sig;
  wire [7:0]  pad_d2a_adj12_sig;
  wire [7:0]  pad_d2a_adj13_sig;
  wire [7:0]  pad_d2a_adj14_sig;
  wire [7:0]  CONFIG_ROM0 [29:0];
  wire [7:0]  CONFIG_ROM1 [29:0];
  wire [7:0]  CONFIG_ROM2 [29:0];
  wire [7:0]  CONFIG_ROM3 [29:0]; 
  wire [7:0]  CONFIG_ROM4 [29:0]; 
  wire [7:0]  CONFIG_ROM5 [29:0]; 
  wire [7:0]  CONFIG_ROM6 [29:0]; 
  wire [7:0]  CONFIG_ROM7 [29:0]; 
  wire [7:0]  CONFIG_ROM8 [29:0]; 
  wire [7:0]  CONFIG_ROM9 [29:0]; 
  wire [7:0]  CONFIG_ROM10[29:0]; 
  wire [7:0]  CONFIG_ROM11[29:0]; 
  wire [7:0]  CONFIG_ROM12[29:0]; 
  wire [7:0]  CONFIG_ROM13[29:0]; 
  wire [7:0]  CONFIG_ROM14[29:0]; 
  wire [7:0]  CONFIG_ROM15[29:0]; 
  wire [7:0]  CONFIG_ROM16[29:0]; 
  wire [7:0]  CONFIG_ROM17[29:0]; 
  wire [7:0]  CONFIG_ROM18[29:0]; 
  wire [7:0]  CONFIG_ROM19[29:0]; 
  wire [7:0]  CONFIG_ROM20[29:0]; 
  wire [7:0]  CONFIG_ROM21[29:0]; 


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
  assign ATM8 = (debug_mode_en && (ana_test_mode== 5'b01000))  ? 1'b1 : 1'b0;
  assign ATM9 = (debug_mode_en && (ana_test_mode== 5'b01001))  ? 1'b1 : 1'b0;
  assign ATM10 = (debug_mode_en && (ana_test_mode== 5'b01010))  ? 1'b1 : 1'b0;
  assign ATM11 = (debug_mode_en && (ana_test_mode== 5'b01011))  ? 1'b1 : 1'b0;
  assign ATM12 = (debug_mode_en && (ana_test_mode== 5'b01100))  ? 1'b1 : 1'b0;
  assign ATM13 = (debug_mode_en && (ana_test_mode== 5'b01101))  ? 1'b1 : 1'b0;
  assign ATM14 = (debug_mode_en && (ana_test_mode== 5'b01110))  ? 1'b1 : 1'b0;
  assign ATM15 = (debug_mode_en && (ana_test_mode== 5'b01111))  ? 1'b1 : 1'b0;
  assign ATM16 = (debug_mode_en && (ana_test_mode== 5'b10000))  ? 1'b1 : 1'b0;
  assign ATM17 = (debug_mode_en && (ana_test_mode== 5'b10001))  ? 1'b1 : 1'b0;
  assign ATM18 = (debug_mode_en && (ana_test_mode== 5'b10010))  ? 1'b1 : 1'b0;
  assign ATM19 = (debug_mode_en && (ana_test_mode== 5'b10011))  ? 1'b1 : 1'b0;
  assign ATM20 = (debug_mode_en && (ana_test_mode== 5'b10100))  ? 1'b1 : 1'b0;
  assign ATM21 = (debug_mode_en && (ana_test_mode== 5'b10101))  ? 1'b1 : 1'b0;
  assign ATM22 = (debug_mode_en && (ana_test_mode== 5'b10110))  ? 1'b1 : 1'b0;
  assign ATM23 = (debug_mode_en && (ana_test_mode== 5'b10111))  ? 1'b1 : 1'b0;
  assign ATM24 = (debug_mode_en && (ana_test_mode== 5'b11000))  ? 1'b1 : 1'b0;
  assign ATM25 = (debug_mode_en && (ana_test_mode== 5'b11001))  ? 1'b1 : 1'b0;
  assign ATM26 = (debug_mode_en && (ana_test_mode== 5'b11010))  ? 1'b1 : 1'b0;
  assign ATM27 = (debug_mode_en && (ana_test_mode== 5'b11011))  ? 1'b1 : 1'b0;
  assign ATM28 = (debug_mode_en && (ana_test_mode== 5'b11100))  ? 1'b1 : 1'b0;
  assign ATM29 = (debug_mode_en && (ana_test_mode== 5'b11101))  ? 1'b1 : 1'b0;
//assign ATM8 = (ana_test_mode== 4'b1001)  ? 1'b1 : 1'b0;
  assign pinmux_if.debug_mode_en = debug_mode_en;
  assign pinmux_if.D2A_ATM       = { ATM29 ,ATM28, ATM27, ATM26, ATM25, ATM24,ATM23, ATM22, ATM21, ATM20, 
				    ATM19,ATM18, ATM17, ATM16,ATM15, ATM14, ATM13, ATM12, ATM11, 
				    ATM10, ATM9,ATM8, ATM7, ATM6, ATM5, ATM4, ATM3, ATM2, ATM1, ATM0};
//assign pinmux_if.ENCODED_ATM  = ana_test_mode;
  
  assign ATM_CONFG =  debug_mode_en ? 1'b1 : 1'b0;
  
  assign test_sel = ((scan_mode    == 1'b1) ? 5'b00000: 
                    (otp_bist_en   == 1'b1) ? 5'b00001: 
                    (ana_test_mode == 5'd0) ? 5'b00010:
                    (ana_test_mode == 5'd1) ? 5'b00011:
                    (ana_test_mode == 5'd2) ? 5'b00100:
                    (ana_test_mode == 5'd3) ? 5'b00101:
                    (ana_test_mode == 5'd4) ? 5'b00110:
                    (ana_test_mode == 5'd5) ? 5'b00111:
                    (ana_test_mode == 5'd6) ? 5'b01000:
                    (ana_test_mode == 5'd7) ? 5'b01001: 
                    (ana_test_mode == 5'd8) ? 5'b01010: 
                    (ana_test_mode == 5'd9) ? 5'b01011: 
                    (ana_test_mode == 5'd10)? 5'b01100: 
                    (ana_test_mode == 5'd11)? 5'b01101: 
                    (ana_test_mode == 5'd12)? 5'b01110: 
                    (ana_test_mode == 5'd13)? 5'b01111: 
                    (ana_test_mode == 5'd14)? 5'b10000: 
                    (ana_test_mode == 5'd15)? 5'b10001: 
                    (ana_test_mode == 5'd16)? 5'b10010: 
                    (ana_test_mode == 5'd17)? 5'b10011: 
                    (ana_test_mode == 5'd18)? 5'b10100: 
                    (ana_test_mode == 5'd19)? 5'b10101:
                    (ana_test_mode == 5'd20)? 5'b10110:
                    (ana_test_mode == 5'd21)? 5'b10111:
                    (ana_test_mode == 5'd22)? 5'b11000:
                    (ana_test_mode == 5'd23)? 5'b11001:
                    (ana_test_mode == 5'd24)? 5'b11010:
                    (ana_test_mode == 5'd25)? 5'b11011:
                    (ana_test_mode == 5'd26)? 5'b11100:
                    (ana_test_mode == 5'd27)? 5'b11101:
                    (ana_test_mode == 5'd28)? 5'b11110: 
                    (ana_test_mode == 5'd29)? 5'b11111: 	5'b00000);
   
 wire INTB_EEG;
 wire INT0;
 wire INT1;
 wire INT2;
 wire INT3;
//these following 3 will be assigned to GPIOs
 wire INTB_WG;
 wire INTB_ANAC;  //include i_anac_int, i_tsc, i_stim_mon_int
 wire INTB_NIRS;

 assign INTB_EEG =   (INT_LEVEL_SEL == 1'b1) ? i_eeg_int : ~i_eeg_int;  //when using one pin, this pin will be combined interrupt pin

//these following 3 will be assigned to GPIOs
 assign INTB_WG =    (INT_LEVEL_SEL == 1'b1) ? i_wg_drviver_int : ~i_wg_drviver_int;
 assign INTB_ANAC =  (INT_LEVEL_SEL == 1'b1) ? (i_anac_int | i_tsc_int | i_stim_mon_int) : ~(i_anac_int | i_tsc_int | i_stim_mon_int);  
 assign INTB_NIRS =  (INT_LEVEL_SEL == 1'b1) ? i_nirs_int : ~i_nirs_int;

 assign INT1 = INTB_WG;
 assign INT2 = INTB_ANAC;
 assign INT3 = INTB_NIRS;

 assign GPIO8_NORMAL_OUT = ~i_gpio_normal_out_ctrl ? INT0 : i_otp_vpp_en ;
//combine interrupt
 //assign INTB_tmp  = (i_wg_drviver_int | i_lead_off_int | i_anac_int | i_tsc_int | i_eeg_int | i_nirs_int | i_stim_mon_int); 
 assign INTB_tmp  =  (i_wg_drviver_int  | i_anac_int | i_tsc_int | i_eeg_int | i_nirs_int | i_stim_mon_int); 
 wire INTB_tmp_combined;
 assign INTB_tmp_combined =(INT_LEVEL_SEL == 1'b1) ? INTB_tmp : ~INTB_tmp ;

 //assign INTB      = (INT_LEVEL_SEL == 1'b1) ? INTB_tmp : ~INTB_tmp;
 assign INT0      = multi_intb_pin ? INTB_EEG : INTB_tmp_combined;

// EXTERNAL CLOCK
  assign ext_clk = ~test_en ?  ext_clk_normal : (debug_mode_en ? ext_clk_0 : 1'b0);

//NORMAL MODE - SPI
  assign o_cpoln = ~test_en ?  pad_cpoln  : 1'b0;
  assign o_cpha  = ~test_en ?  pad_cpha   : 1'b0;
  assign cs_n    = ~test_en ?  pad_cs_n   : 1'b1;
  assign sclk    = ~test_en ?  pad_sclk   : ext_clk;
  assign mosi    = ~test_en ?  pad_mosi   : 1'b0;
  assign mosi1   = ~test_en ?  pad_mosi1   : 1'b0;

//assign GPIO8_NORMAL_OUT = ~test_en ? (~COMP_OUT_EN ? i_otp_vpp_en : (~COMP_OUT_SEL ? A2D_COMP1 : A2D_COMP2)) : 1'b0;
//assign GPIO8_NORMAL_OUT = ~test_en ? (~COMP_OUT_EN ? 1'b0 : (~COMP_OUT_SEL ? A2D_COMP1 : A2D_COMP2)) : 1'b0;
//assign GPIO8_NORMAL_OUT = ~test_en ?  (NORMAL_OUT_SEL ? ((~COMP_OUT_EN ? i_otp_vpp_en : COMP_OUT_SEL_STIM ? 
//                                        (~COMP_OUT_SEL ? A2D_STIMU0_1 : A2D_STIMU2_3) :
//                                        (~COMP_OUT_SEL ? A2D_COMP1 : A2D_COMP2))) : INTB) : 1'b0;
//assign GPIO14_NORMAL_OUT = ~ test_en ?  (~NIRS_LED_ON0 ? NIRS_RESET_SW0 : (~NIRS_IPD_SW0 ? NIRS_IIN_SW0 : (~A2D_IREFCOARSE0 ? A2D_IREFFINE0 : 1'b0))) : 1'b0;
  assign GPIO15_NORMAL_OUT = i_gpio_nirs_out_ctrl ?  NIRS_RESET_SW0 : NIRS_LED_ON1;
  assign GPIO16_NORMAL_OUT = i_gpio_nirs_out_ctrl ?  NIRS_IPD_SW0   : NIRS_LED_ON2;
  assign GPIO17_NORMAL_OUT = i_gpio_nirs_out_ctrl ?  NIRS_IIN_SW0   : NIRS_LED_ON3;
  assign GPIO18_NORMAL_OUT = i_gpio_nirs_out_ctrl ?  A2D_IREFCOARSE0 : NIRS_LED_ON4;
  assign GPIO19_NORMAL_OUT = i_gpio_nirs_out_ctrl ?  A2D_IREFFINE0   : NIRS_LED_ON5;

                           
  assign o_int_clk_out_gpio = ~test_en ? int_clk_out_gpio : 1'b0;

  pinmux_rom  u_pinmux_rom (
    .CONFIG_ROM0   (CONFIG_ROM0),
    .CONFIG_ROM1   (CONFIG_ROM1),
    .CONFIG_ROM2   (CONFIG_ROM2),
    .CONFIG_ROM3   (CONFIG_ROM3),
    .CONFIG_ROM4   (CONFIG_ROM4),
    .CONFIG_ROM5   (CONFIG_ROM5),
    .CONFIG_ROM6   (CONFIG_ROM6),
    .CONFIG_ROM7   (CONFIG_ROM7),
    .CONFIG_ROM8   (CONFIG_ROM8),
    .CONFIG_ROM9   (CONFIG_ROM9),
    .CONFIG_ROM10  (CONFIG_ROM10),
    .CONFIG_ROM11  (CONFIG_ROM11),
    .CONFIG_ROM12  (CONFIG_ROM12),
    .CONFIG_ROM13  (CONFIG_ROM13),
    .CONFIG_ROM14  (CONFIG_ROM14),
    .CONFIG_ROM15  (CONFIG_ROM15),
    .CONFIG_ROM16  (CONFIG_ROM16),
    .CONFIG_ROM17  (CONFIG_ROM17),
    .CONFIG_ROM18  (CONFIG_ROM18),
    .CONFIG_ROM19  (CONFIG_ROM19),
    .CONFIG_ROM20  (CONFIG_ROM20),
    .CONFIG_ROM21  (CONFIG_ROM21)
);

  assign ATM_HC_SEL       = spi_pinmux_if.ATM_HC_SEL;
  assign ANA_BIST_HC_SEL  = spi_pinmux_if.ANA_BIST_HC_SEL;
  assign INT_LEVEL_SEL    = spi_pinmux_if.INT_LEVEL_SEL;
  assign pinmux_if.ATM_HC_SEL = ATM_HC_SEL;

  assign pinmux_if.d2a_tsc_vdac8b_din_ch1 = d2a_tsc_vdac8b_din_ch1;
//assign pinmux_if.d2a_tsc_vdac8b_en_ch1  = (ATM_CONFG & (ATM_HC_SEL == 1'b0) & ATM6)           ?  1'b1  : d2a_tsc_vdac8b_en_ch1;
//assign pinmux_if.d2a_tsc_comp_en_ch1    = (ATM_CONFG & (ATM_HC_SEL == 1'b0) & ATM6)           ?  1'b1  : d2a_tsc_comp_en_ch1;
//assign pinmux_if.d2a_tsc_en_ch1         = (ATM_CONFG & (ATM_HC_SEL == 1'b0) & (ATM6 || ATM1)) ?  1'b1  : d2a_tsc_en_ch1;
  assign pinmux_if.d2a_tsc_en_ch1         = (ATM_CONFG & (ATM_HC_SEL == 1'b0) & ( ATM5  || ATM15|| ATM29)) ?  1'b1  : d2a_tsc_en_ch1;
  assign pinmux_if.i_ds_driver_en_current = (ATM_CONFG & (ATM_HC_SEL == 1'b0) &  ATM6) ?  1'b1  : i_ds_driver_en_current;
  assign pinmux_if.i_stimu_en             = (ATM_CONFG & (ATM_HC_SEL == 1'b0) &  ATM6) ?  1'b1  : i_stimu_en;

genvar i; 
  generate 
    for (i = 0; i < 8; i = i + 1) begin
      assign pinmux_if.D2A_ANA_ENABLE_REG[0][0][i]   = (ATM_CONFG & ((ATM_HC_SEL == 1'b0) | (ANA_BIST_HC_SEL == 1'b0)))  ? (CONFIG_ROM0[ATM_sel][i]  ? 1'b1   : spi_pinmux_if.ANA_ENABLE_REG[0][0][i]) : spi_pinmux_if.ANA_ENABLE_REG[0][0][i];
      assign pinmux_if.D2A_ANA_ENABLE_REG[0][1][i]   = (ATM_CONFG & (ATM_HC_SEL == 1'b0))  ? (CONFIG_ROM1[ATM_sel][i]  ? 1'b1   : spi_pinmux_if.ANA_ENABLE_REG[0][1][i])  : spi_pinmux_if.ANA_ENABLE_REG[0][1][i];
      assign pinmux_if.D2A_ANA_ENABLE_REG[0][2][i]   = (ATM_CONFG & (ATM_HC_SEL == 1'b0))  ? (CONFIG_ROM2[ATM_sel][i]  ? 1'b1   : spi_pinmux_if.ANA_ENABLE_REG[0][2][i])  : spi_pinmux_if.ANA_ENABLE_REG[0][2][i];
      assign pinmux_if.D2A_ANA_ENABLE_REG[0][3][i]   = (ATM_CONFG & (ATM_HC_SEL == 1'b0))  ? (CONFIG_ROM3[ATM_sel][i]  ? 1'b1   : spi_pinmux_if.ANA_ENABLE_REG[0][3][i])  : spi_pinmux_if.ANA_ENABLE_REG[0][3][i];
      assign pinmux_if.D2A_ANA_ENABLE_REG[0][4][i]   = (ATM_CONFG & (ATM_HC_SEL == 1'b0))  ? (CONFIG_ROM4[ATM_sel][i]  ? 1'b1   : spi_pinmux_if.ANA_ENABLE_REG[0][4][i])  : spi_pinmux_if.ANA_ENABLE_REG[0][4][i];
      assign pinmux_if.D2A_ANA_ENABLE_REG[0][5][i]   = (ATM_CONFG & (ATM_HC_SEL == 1'b0))  ? (CONFIG_ROM5[ATM_sel][i]  ? 1'b1   : spi_pinmux_if.ANA_ENABLE_REG[0][5][i])  : spi_pinmux_if.ANA_ENABLE_REG[0][5][i];
      assign pinmux_if.D2A_ANA_ENABLE_REG[0][6][i]   = (ATM_CONFG & (ATM_HC_SEL == 1'b0))  ? (CONFIG_ROM6[ATM_sel][i]  ? 1'b1   : spi_pinmux_if.ANA_ENABLE_REG[0][6][i])  : spi_pinmux_if.ANA_ENABLE_REG[0][6][i];
      assign pinmux_if.D2A_ANA_ENABLE_REG[0][7][i]   = (ATM_CONFG & (ATM_HC_SEL == 1'b0))  ? (CONFIG_ROM7[ATM_sel][i]  ? 1'b1   : spi_pinmux_if.ANA_ENABLE_REG[0][7][i])  : spi_pinmux_if.ANA_ENABLE_REG[0][7][i];
      assign pinmux_if.D2A_ANA_ENABLE_REG[0][8][i]   = (ATM_CONFG & (ATM_HC_SEL == 1'b0))  ? (CONFIG_ROM8[ATM_sel][i]  ? 1'b1   : spi_pinmux_if.ANA_ENABLE_REG[0][8][i])  : spi_pinmux_if.ANA_ENABLE_REG[0][8][i];
      assign pinmux_if.D2A_ANA_ENABLE_REG[0][9][i]   = (ATM_CONFG & (ATM_HC_SEL == 1'b0))  ? (CONFIG_ROM9[ATM_sel][i]  ? 1'b1   : spi_pinmux_if.ANA_ENABLE_REG[0][9][i])  : spi_pinmux_if.ANA_ENABLE_REG[0][9][i];
      assign pinmux_if.D2A_ANA_ENABLE_REG[0][10][i]  = (ATM_CONFG & (ATM_HC_SEL == 1'b0))  ? (CONFIG_ROM10[ATM_sel][i] ? 1'b1   : spi_pinmux_if.ANA_ENABLE_REG[0][10][i]) : spi_pinmux_if.ANA_ENABLE_REG[0][10][i];
      assign pinmux_if.D2A_ANA_ENABLE_REG[0][11][i]  = (ATM_CONFG & (ATM_HC_SEL == 1'b0))  ? (CONFIG_ROM11[ATM_sel][i] ? 1'b1   : spi_pinmux_if.ANA_ENABLE_REG[0][11][i]) : spi_pinmux_if.ANA_ENABLE_REG[0][11][i];
      assign pinmux_if.D2A_ANA_ENABLE_REG[0][12][i]  = (ATM_CONFG & (ATM_HC_SEL == 1'b0))  ? (CONFIG_ROM12[ATM_sel][i] ? 1'b1   : spi_pinmux_if.ANA_ENABLE_REG[0][12][i]) : spi_pinmux_if.ANA_ENABLE_REG[0][12][i];
      assign pinmux_if.D2A_ANA_ENABLE_REG[0][13][i]  = (ATM_CONFG & (ATM_HC_SEL == 1'b0))  ? (CONFIG_ROM13[ATM_sel][i] ? 1'b1   : spi_pinmux_if.ANA_ENABLE_REG[0][13][i]) : spi_pinmux_if.ANA_ENABLE_REG[0][13][i];
      assign pinmux_if.D2A_ANA_ENABLE_REG[0][14][i]  = (ATM_CONFG & (ATM_HC_SEL == 1'b0))  ? (CONFIG_ROM14[ATM_sel][i] ? 1'b1   : spi_pinmux_if.ANA_ENABLE_REG[0][14][i]) : spi_pinmux_if.ANA_ENABLE_REG[0][14][i];
      assign pinmux_if.D2A_ANA_ENABLE_REG[1][0][i]   = (ATM_CONFG & (ATM_HC_SEL == 1'b0))  ? (CONFIG_ROM15[ATM_sel][i] ? 1'b1   : spi_pinmux_if.ANA_ENABLE_REG[1][0][i])  : spi_pinmux_if.ANA_ENABLE_REG[1][0][i];
      assign pinmux_if.D2A_ANA_ENABLE_REG[1][1][i]   = (ATM_CONFG & (ATM_HC_SEL == 1'b0))  ? (CONFIG_ROM16[ATM_sel][i] ? 1'b1   : spi_pinmux_if.ANA_ENABLE_REG[1][1][i])  : spi_pinmux_if.ANA_ENABLE_REG[1][1][i];
      assign pinmux_if.D2A_ANA_ENABLE_REG[1][2][i]   = (ATM_CONFG & (ATM_HC_SEL == 1'b0))  ? (CONFIG_ROM17[ATM_sel][i] ? 1'b1   : spi_pinmux_if.ANA_ENABLE_REG[1][2][i])  : spi_pinmux_if.ANA_ENABLE_REG[1][2][i];
      assign pinmux_if.D2A_ANA_ENABLE_REG[1][3][i]   = (ATM_CONFG & (ATM_HC_SEL == 1'b0))  ? (CONFIG_ROM18[ATM_sel][i] ? 1'b1   : spi_pinmux_if.ANA_ENABLE_REG[1][3][i])  : spi_pinmux_if.ANA_ENABLE_REG[1][3][i];
      assign pinmux_if.D2A_ANA_ENABLE_REG[1][4][i]   = (ATM_CONFG & (ATM_HC_SEL == 1'b0))  ? (CONFIG_ROM19[ATM_sel][i] ? 1'b1   : spi_pinmux_if.ANA_ENABLE_REG[1][4][i])  : spi_pinmux_if.ANA_ENABLE_REG[1][4][i];
      assign pinmux_if.D2A_ANA_ENABLE_REG[1][5][i]   = (ATM_CONFG & (ATM_HC_SEL == 1'b0))  ? (CONFIG_ROM20[ATM_sel][i] ? 1'b1   : spi_pinmux_if.ANA_ENABLE_REG[1][5][i])  : spi_pinmux_if.ANA_ENABLE_REG[1][5][i];
      assign pinmux_if.D2A_ANA_ENABLE_REG[1][6][i]   = (ATM_CONFG & (ATM_HC_SEL == 1'b0))  ? (CONFIG_ROM21[ATM_sel][i] ? 1'b1   : spi_pinmux_if.ANA_ENABLE_REG[1][6][i])  : spi_pinmux_if.ANA_ENABLE_REG[1][6][i];
    end
  endgenerate


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

//debug_signal_mode1(ATM7) - SPARE
  assign pinmux_if.D2A_TRIM_SIG[7] =  ATM7 ? pad_d2a_trim7_sig : sys_d2a_trim_reg[7];

//debug_signal_mode1(ATM8)- SPARE
  assign pinmux_if.D2A_TRIM_SIG[8] =  ATM8 ? pad_d2a_trim8_sig : sys_d2a_trim_reg[8];

//debug_signal_mode1(ATM9)- SPARE
 assign pinmux_if.D2A_TRIM_SIG[9] =  ATM9 ? pad_d2a_trim9_sig : sys_d2a_trim_reg[9];

//debug_signal_mode1(ATM10)- SPARE
 assign pinmux_if.D2A_TRIM_SIG[10] = ATM10 ? pad_d2a_trim10_sig : sys_d2a_trim_reg[10];

//debug_signal_mode1(ATM11)- SPARE
 assign pinmux_if.D2A_TRIM_SIG[11] = ATM11 ? pad_d2a_trim11_sig : sys_d2a_trim_reg[11];

//debug_signal_mode1(ATM12)- SPARE
 assign pinmux_if.D2A_TRIM_SIG[12] = ATM12 ? pad_d2a_trim12_sig : sys_d2a_trim_reg[12];

//debug_signal_mode1(ATM13)- SPARE
 assign pinmux_if.D2A_TRIM_SIG[13] = ATM13 ? pad_d2a_trim13_sig : sys_d2a_trim_reg[13];

//debug_signal_mode1(ATM14)- SPARE
 assign pinmux_if.D2A_TRIM_SIG[14] = ATM14 ? pad_d2a_trim14_sig : sys_d2a_trim_reg[14];

//debug_signal_mode1(ATM15)- ADJUST PATH not stored to OTP
 assign pinmux_if.D2A_ADJ_IO[0] =  ATM15 ? pad_d2a_adj0_sig : 8'b00;
 
//debug_signal_mode1(ATM16)- ADJUST PATH not stored to OTP
 assign pinmux_if.D2A_ADJ_IO[1] =  ATM16 ? pad_d2a_adj1_sig : 8'b00;
 
//debug_signal_mode1(ATM17)- ADJUST PATH not stored to OTP
 assign pinmux_if.D2A_ADJ_IO[2] =  ATM17 ? pad_d2a_adj2_sig : 8'b00;
 
//debug_signal_mode1(ATM18)- ADJUST PATH not stored to OTP
 assign pinmux_if.D2A_ADJ_IO[3] =  ATM18 ? pad_d2a_adj3_sig : 8'b00;
 
//debug_signal_mode1(ATM19)- ADJUST PATH not stored to OTP
 assign pinmux_if.D2A_ADJ_IO[4] =  ATM19 ? pad_d2a_adj4_sig : 8'b00;
 
//debug_signal_mode1(ATM20)- ADJUST PATH not stored to OTP
 assign pinmux_if.D2A_ADJ_IO[5] =  ATM20 ? pad_d2a_adj5_sig : 8'b00;
 
//debug_signal_mode1(ATM21)- ADJUST PATH not stored to OTP
 assign pinmux_if.D2A_ADJ_IO[6] =  ATM21 ? pad_d2a_adj6_sig : 8'b00;
 
//debug_signal_mode1(ATM22)- ADJUST PATH not stored to OTP
 assign pinmux_if.D2A_ADJ_IO[7] =  ATM22 ? pad_d2a_adj7_sig : 8'b00;

//debug_signal_mode1(ATM23)- ADJUST PATH not stored to OTP
 assign pinmux_if.D2A_ADJ_IO[8] =  ATM23 ? pad_d2a_adj8_sig : 8'b00;

//debug_signal_mode1(ATM24)- ADJUST PATH not stored to OTP
 assign pinmux_if.D2A_ADJ_IO[9] =  ATM24 ? pad_d2a_adj9_sig : 8'b00;

//debug_signal_mode1(ATM25)- ADJUST PATH not stored to OTP
 assign pinmux_if.D2A_ADJ_IO[10] =  ATM25 ? pad_d2a_adj10_sig : 8'b00;

//debug_signal_mode1(ATM26)- ADJUST PATH not stored to OTP
 assign pinmux_if.D2A_ADJ_IO[11] =  ATM26 ? pad_d2a_adj11_sig : 8'b00;

//debug_signal_mode1(ATM27)- ADJUST PATH not stored to OTP
 assign pinmux_if.D2A_ADJ_IO[12] =  ATM27 ? pad_d2a_adj12_sig : 8'b00;

//debug_signal_mode1(ATM28)- ADJUST PATH not stored to OTP
 assign pinmux_if.D2A_ADJ_IO[13] =  ATM28 ? pad_d2a_adj13_sig : 8'b00;

//debug_signal_mode1(ATM29)- ADJUST PATH not stored to OTP
 assign pinmux_if.D2A_ADJ_IO[14] =  ATM29 ? pad_d2a_adj14_sig : 8'b00;
  
//LOAD TRIMS to OTP
  assign o_OTP_ATM_MODE_SEL   = { ATM14, ATM13, ATM12, ATM11, ATM10, ATM9, ATM8,
				ATM7, ATM6, ATM5, ATM4, ATM3, ATM2, ATM1, ATM0};

  assign o_OTP_ANA_TESTMODE   = debug_mode_en;

  assign o_OTP_ATM_TRIM_DATA  = ATM0 ? pad_d2a_trim0_sig : 
                                ATM1 ? pad_d2a_trim1_sig :
                                ATM2 ? pad_d2a_trim2_sig :
                                ATM3 ? pad_d2a_trim3_sig :
                                ATM4 ? pad_d2a_trim4_sig :
                                ATM5 ? pad_d2a_trim5_sig :
                                ATM6 ? pad_d2a_trim6_sig :
                                ATM7 ? pad_d2a_trim7_sig : 
                                ATM8 ? pad_d2a_trim8_sig :
                                ATM9 ? pad_d2a_trim9_sig :
                                ATM10 ? pad_d2a_trim10_sig :
                                ATM11 ? pad_d2a_trim11_sig :
                                ATM12 ? pad_d2a_trim12_sig :
                                ATM13 ? pad_d2a_trim13_sig : 
                                ATM14 ? pad_d2a_trim14_sig : 8'h00;

  assign o_OTP_UNLOCK         = debug_mode_en ? i_ext_clk_sel : 1'b0;
 

  assign o_SPI_ATM_MODE_SEL = {ATM29, ATM28, ATM27, ATM26, ATM25, ATM24, ATM23, ATM22,
                               ATM21, ATM20, ATM19, ATM18, ATM17, ATM16, ATM15};
  assign o_SPI_ANA_TESTMODE   = debug_mode_en;

  assign o_SPI_ATM_ADJ_DATA  =  ATM15 ? pad_d2a_adj0_sig : 
                                ATM16 ? pad_d2a_adj1_sig :
                                ATM17 ? pad_d2a_adj2_sig : 
                                ATM18 ? pad_d2a_adj3_sig : 
                                ATM19 ? pad_d2a_adj4_sig : 
                                ATM20 ? pad_d2a_adj5_sig : 
                                ATM21 ? pad_d2a_adj6_sig : 
                                ATM22 ? pad_d2a_adj7_sig : 
                                ATM23 ? pad_d2a_adj8_sig : 
                                ATM24 ? pad_d2a_adj9_sig : 
                                ATM25 ? pad_d2a_adj10_sig : 
                                ATM26 ? pad_d2a_adj11_sig : 
                                ATM27 ? pad_d2a_adj12_sig : 
                                ATM28 ? pad_d2a_adj13_sig : 
                                ATM29 ? pad_d2a_adj14_sig : 
                                8'h00;
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
// test11: ext_clk
// test12: ext_clk
// test13: ext_clk
// test14: ext_clk
// test15: ext_clk
// test16: ext_clk
// test17: ext_clk
// test18: ext_clk
// test19: ext_clk
// test20: ext_clk
// test21: ext_clk
// test22: ext_clk
// test23: ext_clk
// test24: ext_clk
// test25: ext_clk
// test26: ext_clk
// test27: ext_clk
// test28: ext_clk
// test29: ext_clk
// test30: ext_clk
// test31: ext_clk

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
.TEST9_CLKIN(1),
.TEST10_CLKIN(1),
.TEST11_CLKIN(1),
.TEST12_CLKIN(1),
.TEST13_CLKIN(1),
.TEST14_CLKIN(1),
.TEST15_CLKIN(1),
.TEST16_CLKIN(1),
.TEST17_CLKIN(1),
.TEST18_CLKIN(1),
.TEST19_CLKIN(1),
.TEST20_CLKIN(1),
.TEST21_CLKIN(1),
.TEST22_CLKIN(1),
.TEST23_CLKIN(1),
.TEST24_CLKIN(1),
.TEST25_CLKIN(1),
.TEST26_CLKIN(1),
.TEST27_CLKIN(1),
.TEST28_CLKIN(1),
.TEST29_CLKIN(1),
.TEST30_CLKIN(1),
.TEST31_CLKIN(1))
// .TEST10_CLKIN(0))
u_gpio0_pinmux (
// test and alternate select
//.altf_sel   (2'd0),
.test_sel   (scan_mode ? 5'd0 : (otp_bist_en ? 5'd1 : (debug_mode_en ? 5'd2 : 5'd0))),
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
.test10_en   (1'b0),
.test11_en   (1'b0),
.test12_en   (1'b0),
.test13_en   (1'b0),
.test14_en   (1'b0),
.test15_en   (1'b0),
.test16_en   (1'b0),
.test17_en   (1'b0),
.test18_en   (1'b0),
.test19_en   (1'b0),
.test20_en   (1'b0),
.test21_en   (1'b0),
.test22_en   (1'b0),
.test23_en   (1'b0),
.test24_en   (1'b0),
.test25_en   (1'b0),
.test26_en   (1'b0),
.test27_en   (1'b0),
.test28_en   (1'b0),
.test29_en   (1'b0),
.test30_en   (1'b0),
.test31_en   (1'b0),
//.test_ana   (1'b0),       //Disable IE/OE/A:: TESTMODE0 GPIO0 serves pure analog signal
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
.test10_ie   (1'b0),
.test10_oe   (1'b0),
.test10_a    (1'b0),
.test10_def  (1'b0),
.test10_y    (),
// test11
.test11_ie   (1'b0),
.test11_oe   (1'b0),
.test11_a    (1'b0),
.test11_def  (1'b0),
.test11_y    (),
// test12
.test12_ie   (1'b0),
.test12_oe   (1'b0),
.test12_a    (1'b0),
.test12_def  (1'b0),
.test12_y    (),
// test13
.test13_ie   (1'b0),
.test13_oe   (1'b0),
.test13_a    (1'b0),
.test13_def  (1'b0),
.test13_y    (),
// test14
.test14_ie   (1'b0),
.test14_oe   (1'b0),
.test14_a    (1'b0),
.test14_def  (1'b0),
.test14_y    (),
// test15
.test15_ie   (1'b0),
.test15_oe   (1'b0),
.test15_a    (1'b0),
.test15_def  (1'b0),
.test15_y    (),
// test16
.test16_ie   (1'b0),
.test16_oe   (1'b0),
.test16_a    (1'b0),
.test16_def  (1'b0),
.test16_y    (),
// test17
.test17_ie   (1'b0),
.test17_oe   (1'b0),
.test17_a    (1'b0),
.test17_def  (1'b0),
.test17_y    (),
// test18
.test18_ie   (1'b0),
.test18_oe   (1'b0),
.test18_a    (1'b0),
.test18_def  (1'b0),
.test18_y    (),
// test19
.test19_ie   (1'b0),
.test19_oe   (1'b0),
.test19_a    (1'b0),
.test19_def  (1'b0),
.test19_y    (),
// test20
.test20_ie   (1'b0),
.test20_oe   (1'b0),
.test20_a    (1'b0),
.test20_def  (1'b0),
.test20_y    (),
// test21
.test21_ie   (1'b0),
.test21_oe   (1'b0),
.test21_a    (1'b0),
.test21_def  (1'b0),
.test21_y    (),
// test22
.test22_ie   (1'b0),
.test22_oe   (1'b0),
.test22_a    (1'b0),
.test22_def  (1'b0),
.test22_y    (),
// test23
.test23_ie   (1'b0),
.test23_oe   (1'b0),
.test23_a    (1'b0),
.test23_def  (1'b0),
.test23_y    (),
// test24
.test24_ie   (1'b0),
.test24_oe   (1'b0),
.test24_a    (1'b0),
.test24_def  (1'b0),
.test24_y    (),
// test25
.test25_ie   (1'b0),
.test25_oe   (1'b0),
.test25_a    (1'b0),
.test25_def  (1'b0),
.test25_y    (),
// test26
.test26_ie   (1'b0),
.test26_oe   (1'b0),
.test26_a    (1'b0),
.test26_def  (1'b0),
.test26_y    (),
// test27
.test27_ie   (1'b0),
.test27_oe   (1'b0),
.test27_a    (1'b0),
.test27_def  (1'b0),
.test27_y    (),
// test28
.test28_ie   (1'b0),
.test28_oe   (1'b0),
.test28_a    (1'b0),
.test28_def  (1'b0),
.test28_y    (),
// test29
.test29_ie   (1'b0),
.test29_oe   (1'b0),
.test29_a    (1'b0),
.test29_def  (1'b0),
.test29_y    (),
// test30
.test30_ie   (1'b0),
.test30_oe   (1'b0),
.test30_a    (1'b0),
.test30_def  (1'b0),
.test30_y    (),
// test31
.test31_ie   (1'b0),
.test31_oe   (1'b0),
.test31_a    (1'b0),
.test31_def  (1'b0),
.test31_y    (),

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
// test11: pad_d2a_trim9_sig[0]
// test12: pad_d2a_trim10_sig[0]
// test13: pad_d2a_trim11_sig[0]
// test14: pad_d2a_trim12_sig[0]
// test15: pad_d2a_trim13_sig[0]
// test16: pad_d2a_trim14_sig[0]
// test17: pad_d2a_adj0_sig[0]
// test18: pad_d2a_adj1_sig[0]
// test19: pad_d2a_adj2_sig[0]
// test20: pad_d2a_adj3_sig[0]
// test21: pad_d2a_adj4_sig[0]
// test22: pad_d2a_adj5_sig[0]
// test23: pad_d2a_adj6_sig[0]
// test24: pad_d2a_adj7_sig[0]
// test25: pad_d2a_adj8_sig[0]
// test26: pad_d2a_adj9_sig[0]
// test27: pad_d2a_adj10_sig[0]
// test28: pad_d2a_adj11_sig[0]
// test29: pad_d2a_adj12_sig[0]
// test30: pad_d2a_adj13_sig[0]
// test31: pad_d2a_adj14_sig[0]

 
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
.TEST10_CLKIN(0),
.TEST11_CLKIN(0),
.TEST12_CLKIN(0),
.TEST13_CLKIN(0),
.TEST14_CLKIN(0),
.TEST15_CLKIN(0),
.TEST16_CLKIN(0),
.TEST17_CLKIN(0),
.TEST18_CLKIN(0),
.TEST19_CLKIN(0),
.TEST20_CLKIN(0),
.TEST21_CLKIN(0),
.TEST22_CLKIN(0),
.TEST23_CLKIN(0),
.TEST24_CLKIN(0),
.TEST25_CLKIN(0),
.TEST26_CLKIN(0),
.TEST27_CLKIN(0),
.TEST28_CLKIN(0),
.TEST29_CLKIN(0),
.TEST30_CLKIN(0),
.TEST31_CLKIN(0))
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
.test10_en  (ATM8),
.test11_en  (ATM9),
.test12_en  (ATM10),
.test13_en  (ATM11),
.test14_en  (ATM12),
.test15_en  (ATM13),
.test16_en  (ATM14),
.test17_en  (ATM15),
.test18_en  (ATM16),
.test19_en  (ATM17),
.test20_en  (ATM18),
.test21_en  (ATM19),
.test22_en  (ATM20),
.test23_en  (ATM21),
.test24_en  (ATM22),
.test25_en  (ATM23),
.test26_en  (ATM24),
.test27_en  (ATM25),
.test28_en  (ATM26),
.test29_en  (ATM27),
.test30_en  (ATM28),
.test31_en  (ATM29),
//.test10_en  (ATM8),
//.test_ana   (1'b0),       //Disable IE/OE/A:: TESTMODE0 GPIO0 serves pure analog signal
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
.test10_ie   (1'b1),
.test10_oe   (1'b0),
.test10_a    (1'b0),
.test10_def  (1'b0),
.test10_y    (pad_d2a_trim8_sig[0]),
// test11
.test11_ie   (1'b1),
.test11_oe   (1'b0),
.test11_a    (1'b0),
.test11_def  (1'b0),
.test11_y    (pad_d2a_trim9_sig[0]),
// test12
.test12_ie   (1'b1),
.test12_oe   (1'b0),
.test12_a    (1'b0),
.test12_def  (1'b0),
.test12_y    (pad_d2a_trim10_sig[0]),
// test13
.test13_ie   (1'b1),
.test13_oe   (1'b0),
.test13_a    (1'b0),
.test13_def  (1'b0),
.test13_y    (pad_d2a_trim11_sig[0]),
// test14
.test14_ie   (1'b1),
.test14_oe   (1'b0),
.test14_a    (1'b0),
.test14_def  (1'b0),
.test14_y    (pad_d2a_trim12_sig[0]),
// test15
.test15_ie   (1'b1),
.test15_oe   (1'b0),
.test15_a    (1'b0),
.test15_def  (1'b0),
.test15_y    (pad_d2a_trim13_sig[0]),
// test16
.test16_ie   (1'b1),
.test16_oe   (1'b0),
.test16_a    (1'b0),
.test16_def  (1'b0),
.test16_y    (pad_d2a_trim14_sig[0]),
// test17
.test17_ie   (1'b1),
.test17_oe   (1'b0),
.test17_a    (1'b0),
.test17_def  (1'b0),
.test17_y    (pad_d2a_adj0_sig[0]),
// test18
.test18_ie   (1'b1),
.test18_oe   (1'b0),
.test18_a    (1'b0),
.test18_def  (1'b0),
.test18_y    (pad_d2a_adj1_sig[0]),
// test19
.test19_ie   (1'b1),
.test19_oe   (1'b0),
.test19_a    (1'b0),
.test19_def  (1'b0),
.test19_y    (pad_d2a_adj2_sig[0]),
// test20
.test20_ie   (1'b1),
.test20_oe   (1'b0),
.test20_a    (1'b0),
.test20_def  (1'b0),
.test20_y    (pad_d2a_adj3_sig[0]),
// test21
.test21_ie   (1'b1),
.test21_oe   (1'b0),
.test21_a    (1'b0),
.test21_def  (1'b0),
.test21_y    (pad_d2a_adj4_sig[0]),
// test22
.test22_ie   (1'b1),
.test22_oe   (1'b0),
.test22_a    (1'b0),
.test22_def  (1'b0),
.test22_y    (pad_d2a_adj5_sig[0]),
// test23
.test23_ie   (1'b1),
.test23_oe   (1'b0),
.test23_a    (1'b0),
.test23_def  (1'b0),
.test23_y    (pad_d2a_adj6_sig[0]),
// test24
.test24_ie   (1'b1),
.test24_oe   (1'b0),
.test24_a    (1'b0),
.test24_def  (1'b0),
.test24_y    (pad_d2a_adj7_sig[0]),
// test25
.test25_ie   (1'b1),
.test25_oe   (1'b0),
.test25_a    (1'b0),
.test25_def  (1'b0),
.test25_y    (pad_d2a_adj8_sig[0]),
// test26
.test26_ie   (1'b1),
.test26_oe   (1'b0),
.test26_a    (1'b0),
.test26_def  (1'b0),
.test26_y    (pad_d2a_adj9_sig[0]),
// test27
.test27_ie   (1'b1),
.test27_oe   (1'b0),
.test27_a    (1'b0),
.test27_def  (1'b0),
.test27_y    (pad_d2a_adj10_sig[0]),
// test28
.test28_ie   (1'b1),
.test28_oe   (1'b0),
.test28_a    (1'b0),
.test28_def  (1'b0),
.test28_y    (pad_d2a_adj11_sig[0]),
// test29
.test29_ie   (1'b1),
.test29_oe   (1'b0),
.test29_a    (1'b0),
.test29_def  (1'b0),
.test29_y    (pad_d2a_adj12_sig[0]),
// test30
.test30_ie   (1'b1),
.test30_oe   (1'b0),
.test30_a    (1'b0),
.test30_def  (1'b0),
.test30_y    (pad_d2a_adj13_sig[0]),
// test31
.test31_ie   (1'b1),
.test31_oe   (1'b0),
.test31_a    (1'b0),
.test31_def  (1'b0),
.test31_y    (pad_d2a_adj14_sig[0]),


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
// test11: pad_d2a_trim9_sig[1]
// test12: pad_d2a_trim10_sig[1]
// test13: pad_d2a_trim11_sig[1]
// test14: pad_d2a_trim12_sig[1]
// test15: pad_d2a_trim13_sig[1]
// test16: pad_d2a_trim14_sig[1]
// test17: pad_d2a_adj0_sig[1]
// test18: pad_d2a_adj1_sig[1]
// test19: pad_d2a_adj2_sig[1]
// test20: pad_d2a_adj3_sig[1]
// test21: pad_d2a_adj4_sig[1]
// test22: pad_d2a_adj5_sig[1]
// test23: pad_d2a_adj6_sig[1]
// test24: pad_d2a_adj7_sig[1]
// test25: pad_d2a_adj8_sig[1]
// test26: pad_d2a_adj9_sig[1]
// test27: pad_d2a_adj10_sig[1]
// test28: pad_d2a_adj11_sig[1]
// test29: pad_d2a_adj12_sig[1]
// test30: pad_d2a_adj13_sig[1]
// test31: pad_d2a_adj14_sig[1]

  
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
.TEST10_CLKIN(0),
.TEST11_CLKIN(0),
.TEST12_CLKIN(0),
.TEST13_CLKIN(0),
.TEST14_CLKIN(0),
.TEST15_CLKIN(0),
.TEST16_CLKIN(0),
.TEST17_CLKIN(0),
.TEST18_CLKIN(0),
.TEST19_CLKIN(0),
.TEST20_CLKIN(0),
.TEST21_CLKIN(0),
.TEST22_CLKIN(0),
.TEST23_CLKIN(0),
.TEST24_CLKIN(0),
.TEST25_CLKIN(0),
.TEST26_CLKIN(0),
.TEST27_CLKIN(0),
.TEST28_CLKIN(0),
.TEST29_CLKIN(0),
.TEST30_CLKIN(0),
.TEST31_CLKIN(0))
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
.test10_en  (ATM8),
.test11_en  (ATM9),
.test12_en  (ATM10),
.test13_en  (ATM11),
.test14_en  (ATM12),
.test15_en  (ATM13),
.test16_en  (ATM14),
.test17_en  (ATM15),
.test18_en  (ATM16),
.test19_en  (ATM17),
.test20_en  (ATM18),
.test21_en  (ATM19),
.test22_en  (ATM20),
.test23_en  (ATM21),
.test24_en  (ATM22),
.test25_en  (ATM23),
.test26_en  (ATM24),
.test27_en  (ATM25),
.test28_en  (ATM26),
.test29_en  (ATM27),
.test30_en  (ATM28),
.test31_en  (ATM29),
//.test_ana   (1'b0),       //Disable IE/OE/A:: TESTMODE0 GPIO0 serves pure analog signal
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
.test10_ie   (1'b1),
.test10_oe   (1'b0),
.test10_a    (1'b0),
.test10_def  (1'b0),
.test10_y    (pad_d2a_trim8_sig[1]),
// test11
.test11_ie   (1'b1),
.test11_oe   (1'b0),
.test11_a    (1'b0),
.test11_def  (1'b0),
.test11_y    (pad_d2a_trim9_sig[1]),
// test12
.test12_ie   (1'b1),
.test12_oe   (1'b0),
.test12_a    (1'b0),
.test12_def  (1'b0),
.test12_y    (pad_d2a_trim10_sig[1]),
// test13
.test13_ie   (1'b1),
.test13_oe   (1'b0),
.test13_a    (1'b0),
.test13_def  (1'b0),
.test13_y    (pad_d2a_trim11_sig[1]),
// test14
.test14_ie   (1'b1),
.test14_oe   (1'b0),
.test14_a    (1'b0),
.test14_def  (1'b0),
.test14_y    (pad_d2a_trim12_sig[1]),
// test15
.test15_ie   (1'b1),
.test15_oe   (1'b0),
.test15_a    (1'b0),
.test15_def  (1'b0),
.test15_y    (pad_d2a_trim13_sig[1]),
// test16
.test16_ie   (1'b1),
.test16_oe   (1'b0),
.test16_a    (1'b0),
.test16_def  (1'b0),
.test16_y    (pad_d2a_trim14_sig[1]),
// test17
.test17_ie   (1'b1),
.test17_oe   (1'b0),
.test17_a    (1'b0),
.test17_def  (1'b0),
.test17_y    (pad_d2a_adj0_sig[1]),
// test18
.test18_ie   (1'b1),
.test18_oe   (1'b0),
.test18_a    (1'b0),
.test18_def  (1'b0),
.test18_y    (pad_d2a_adj1_sig[1]),
// test19
.test19_ie   (1'b1),
.test19_oe   (1'b0),
.test19_a    (1'b0),
.test19_def  (1'b0),
.test19_y    (pad_d2a_adj2_sig[1]),
// test20
.test20_ie   (1'b1),
.test20_oe   (1'b0),
.test20_a    (1'b0),
.test20_def  (1'b0),
.test20_y    (pad_d2a_adj3_sig[1]),
// test21
.test21_ie   (1'b1),
.test21_oe   (1'b0),
.test21_a    (1'b0),
.test21_def  (1'b0),
.test21_y    (pad_d2a_adj4_sig[1]),
// test22
.test22_ie   (1'b1),
.test22_oe   (1'b0),
.test22_a    (1'b0),
.test22_def  (1'b0),
.test22_y    (pad_d2a_adj5_sig[1]),
// test23
.test23_ie   (1'b1),
.test23_oe   (1'b0),
.test23_a    (1'b0),
.test23_def  (1'b0),
.test23_y    (pad_d2a_adj6_sig[1]),
// test24
.test24_ie   (1'b1),
.test24_oe   (1'b0),
.test24_a    (1'b0),
.test24_def  (1'b0),
.test24_y    (pad_d2a_adj7_sig[1]),
// test25
.test25_ie   (1'b1),
.test25_oe   (1'b0),
.test25_a    (1'b0),
.test25_def  (1'b0),
.test25_y    (pad_d2a_adj8_sig[1]),
// test26
.test26_ie   (1'b1),
.test26_oe   (1'b0),
.test26_a    (1'b0),
.test26_def  (1'b0),
.test26_y    (pad_d2a_adj9_sig[1]),
// test27
.test27_ie   (1'b1),
.test27_oe   (1'b0),
.test27_a    (1'b0),
.test27_def  (1'b0),
.test27_y    (pad_d2a_adj10_sig[1]),
// test28
.test28_ie   (1'b1),
.test28_oe   (1'b0),
.test28_a    (1'b0),
.test28_def  (1'b0),
.test28_y    (pad_d2a_adj11_sig[1]),
// test29
.test29_ie   (1'b1),
.test29_oe   (1'b0),
.test29_a    (1'b0),
.test29_def  (1'b0),
.test29_y    (pad_d2a_adj12_sig[1]),
// test30
.test30_ie   (1'b1),
.test30_oe   (1'b0),
.test30_a    (1'b0),
.test30_def  (1'b0),
.test30_y    (pad_d2a_adj13_sig[1]),
// test30
.test31_ie   (1'b1),
.test31_oe   (1'b0),
.test31_a    (1'b0),
.test31_def  (1'b0),
.test31_y    (pad_d2a_adj14_sig[1]),
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
// test11: pad_d2a_trim9_sig[2]
// test12: pad_d2a_trim10_sig[2]
// test13: pad_d2a_trim11_sig[2]
// test14: pad_d2a_trim12_sig[2]
// test15: pad_d2a_trim13_sig[2]
// test16: pad_d2a_trim14_sig[2]
// test17: pad_d2a_adj0_sig[2]
// test18: pad_d2a_adj1_sig[2]
// test19: pad_d2a_adj2_sig[2]
// test20: pad_d2a_adj3_sig[2]
// test21: pad_d2a_adj4_sig[2]
// test22: pad_d2a_adj5_sig[2]
// test23: pad_d2a_adj6_sig[2]
// test24: pad_d2a_adj7_sig[2]
// test25: pad_d2a_adj8_sig[2]
// test26: pad_d2a_adj9_sig[2]
// test27: pad_d2a_adj10_sig[2]
// test28: pad_d2a_adj11_sig[2]
// test29: pad_d2a_adj12_sig[2]
// test30: pad_d2a_adj13_sig[2]
// test31: pad_d2a_adj14_sig[2]

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
.TEST10_CLKIN(0),
.TEST11_CLKIN(0),
.TEST12_CLKIN(0),
.TEST13_CLKIN(0),
.TEST14_CLKIN(0),
.TEST15_CLKIN(0),
.TEST16_CLKIN(0),
.TEST17_CLKIN(0),
.TEST18_CLKIN(0),
.TEST19_CLKIN(0),
.TEST20_CLKIN(0),
.TEST21_CLKIN(0),
.TEST22_CLKIN(0),
.TEST23_CLKIN(0),
.TEST24_CLKIN(0),
.TEST25_CLKIN(0),
.TEST26_CLKIN(0),
.TEST27_CLKIN(0),
.TEST28_CLKIN(0),
.TEST29_CLKIN(0),
.TEST30_CLKIN(0),
.TEST31_CLKIN(0))
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
.test10_en  (ATM8),
.test11_en  (ATM9),
.test12_en  (ATM10),
.test13_en  (ATM11),
.test14_en  (ATM12),
.test15_en  (ATM13),
.test16_en  (ATM14),
.test17_en  (ATM15),
.test18_en  (ATM16),
.test19_en  (ATM17),
.test20_en  (ATM18),
.test21_en  (ATM19),
.test22_en  (ATM20),
.test23_en  (ATM21),
.test24_en  (ATM22),
.test25_en  (ATM23),
.test26_en  (ATM24),
.test27_en  (ATM25),
.test28_en  (ATM26),
.test29_en  (ATM27),
.test30_en  (ATM28),
.test31_en  (ATM29),
//.test10_en  (ATM8),
//.test_ana   (1'b0),       //Disable IE/OE/A:: TESTMODE0 GPIO0 serves pure analog signal
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
.test10_ie   (1'b1),
.test10_oe   (1'b0),
.test10_a    (1'b0),
.test10_def  (1'b0),
.test10_y    (pad_d2a_trim8_sig[2]),
// test11
.test11_ie   (1'b1),
.test11_oe   (1'b0),
.test11_a    (1'b0),
.test11_def  (1'b0),
.test11_y    (pad_d2a_trim9_sig[2]),
// test12
.test12_ie   (1'b1),
.test12_oe   (1'b0),
.test12_a    (1'b0),
.test12_def  (1'b0),
.test12_y    (pad_d2a_trim10_sig[2]),
// test13
.test13_ie   (1'b1),
.test13_oe   (1'b0),
.test13_a    (1'b0),
.test13_def  (1'b0),
.test13_y    (pad_d2a_trim11_sig[2]),
// test14
.test14_ie   (1'b1),
.test14_oe   (1'b0),
.test14_a    (1'b0),
.test14_def  (1'b0),
.test14_y    (pad_d2a_trim12_sig[2]),
// test15
.test15_ie   (1'b1),
.test15_oe   (1'b0),
.test15_a    (1'b0),
.test15_def  (1'b0),
.test15_y    (pad_d2a_trim13_sig[2]),
// test16
.test16_ie   (1'b1),
.test16_oe   (1'b0),
.test16_a    (1'b0),
.test16_def  (1'b0),
.test16_y    (pad_d2a_trim14_sig[2]),
// test17
.test17_ie   (1'b1),
.test17_oe   (1'b0),
.test17_a    (1'b0),
.test17_def  (1'b0),
.test17_y    (pad_d2a_adj0_sig[2]),
// test18
.test18_ie   (1'b1),
.test18_oe   (1'b0),
.test18_a    (1'b0),
.test18_def  (1'b0),
.test18_y    (pad_d2a_adj1_sig[2]),
// test19
.test19_ie   (1'b1),
.test19_oe   (1'b0),
.test19_a    (1'b0),
.test19_def  (1'b0),
.test19_y    (pad_d2a_adj2_sig[2]),
// test20
.test20_ie   (1'b1),
.test20_oe   (1'b0),
.test20_a    (1'b0),
.test20_def  (1'b0),
.test20_y    (pad_d2a_adj3_sig[2]),
// test21
.test21_ie   (1'b1),
.test21_oe   (1'b0),
.test21_a    (1'b0),
.test21_def  (1'b0),
.test21_y    (pad_d2a_adj4_sig[2]),
// test22
.test22_ie   (1'b1),
.test22_oe   (1'b0),
.test22_a    (1'b0),
.test22_def  (1'b0),
.test22_y    (pad_d2a_adj5_sig[2]),
// test23
.test23_ie   (1'b1),
.test23_oe   (1'b0),
.test23_a    (1'b0),
.test23_def  (1'b0),
.test23_y    (pad_d2a_adj6_sig[2]),
// test24
.test24_ie   (1'b1),
.test24_oe   (1'b0),
.test24_a    (1'b0),
.test24_def  (1'b0),
.test24_y    (pad_d2a_adj7_sig[2]),
// test25
.test25_ie   (1'b1),
.test25_oe   (1'b0),
.test25_a    (1'b0),
.test25_def  (1'b0),
.test25_y    (pad_d2a_adj8_sig[2]),
// test26
.test26_ie   (1'b1),
.test26_oe   (1'b0),
.test26_a    (1'b0),
.test26_def  (1'b0),
.test26_y    (pad_d2a_adj9_sig[2]),
// test27
.test27_ie   (1'b1),
.test27_oe   (1'b0),
.test27_a    (1'b0),
.test27_def  (1'b0),
.test27_y    (pad_d2a_adj10_sig[2]),
// test28
.test28_ie   (1'b1),
.test28_oe   (1'b0),
.test28_a    (1'b0),
.test28_def  (1'b0),
.test28_y    (pad_d2a_adj11_sig[2]),
// test29
.test29_ie   (1'b1),
.test29_oe   (1'b0),
.test29_a    (1'b0),
.test29_def  (1'b0),
.test29_y    (pad_d2a_adj12_sig[2]),
// test30
.test30_ie   (1'b1),
.test30_oe   (1'b0),
.test30_a    (1'b0),
.test30_def  (1'b0),
.test30_y    (pad_d2a_adj13_sig[2]),
// test31
.test31_ie   (1'b1),
.test31_oe   (1'b0),
.test31_a    (1'b0),
.test31_def  (1'b0),
.test31_y    (pad_d2a_adj14_sig[2]),

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
// test11: pad_d2a_trim9_sig[3]
// test12: pad_d2a_trim10_sig[3]
// test13: pad_d2a_trim11_sig[3]
// test14: pad_d2a_trim12_sig[3]
// test15: pad_d2a_trim13_sig[3]
// test16: pad_d2a_trim14_sig[3]
// test17: pad_d2a_adj0_sig[3]
// test18: pad_d2a_adj1_sig[3]
// test19: pad_d2a_adj2_sig[3]
// test20: pad_d2a_adj3_sig[3]
// test21: pad_d2a_adj4_sig[3]
// test22: pad_d2a_adj5_sig[3]
// test23: pad_d2a_adj6_sig[3]
// test24: pad_d2a_adj7_sig[3]
// test25: pad_d2a_adj8_sig[3]
// test26: pad_d2a_adj9_sig[3]
// test27: pad_d2a_adj10_sig[3]
// test28: pad_d2a_adj11_sig[3]
// test29: pad_d2a_adj12_sig[3]
// test30: pad_d2a_adj13_sig[3]
// test31: pad_d2a_adj14_sig[3]
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
.TEST9_CLKIN(0),
.TEST10_CLKIN(0),
.TEST11_CLKIN(0),
.TEST12_CLKIN(0),
.TEST13_CLKIN(0),
.TEST14_CLKIN(0),
.TEST15_CLKIN(0),
.TEST16_CLKIN(0),
.TEST17_CLKIN(0),
.TEST18_CLKIN(0),
.TEST19_CLKIN(0),
.TEST20_CLKIN(0),
.TEST21_CLKIN(0),
.TEST22_CLKIN(0),
.TEST23_CLKIN(0),
.TEST24_CLKIN(0),
.TEST25_CLKIN(0),
.TEST26_CLKIN(0),
.TEST27_CLKIN(0),
.TEST28_CLKIN(0),
.TEST29_CLKIN(0),
.TEST30_CLKIN(0),
.TEST31_CLKIN(0))
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
.test10_en  (ATM8),
.test11_en  (ATM9),
.test12_en  (ATM10),
.test13_en  (ATM11),
.test14_en  (ATM12),
.test15_en  (ATM13),
.test16_en  (ATM14),
.test17_en  (ATM15),
.test18_en  (ATM16),
.test19_en  (ATM17),
.test20_en  (ATM18),
.test21_en  (ATM19),
.test22_en  (ATM20),
.test23_en  (ATM21),
.test24_en  (ATM22),
.test25_en  (ATM23),
.test26_en  (ATM24),
.test27_en  (ATM25),
.test28_en  (ATM26),
.test29_en  (ATM27),
.test30_en  (ATM28),
.test31_en  (ATM29),
//.test_ana   (1'b0),       //Disable IE/OE/A:: TESTMODE0 GPIO0 serves pure analog signal
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
.test10_ie   (1'b1),
.test10_oe   (1'b0),
.test10_a    (1'b0),
.test10_def  (1'b0),
.test10_y    (pad_d2a_trim8_sig[3]),
// test11
.test11_ie   (1'b1),
.test11_oe   (1'b0),
.test11_a    (1'b0),
.test11_def  (1'b0),
.test11_y    (pad_d2a_trim9_sig[3]),
// test12
.test12_ie   (1'b1),
.test12_oe   (1'b0),
.test12_a    (1'b0),
.test12_def  (1'b0),
.test12_y    (pad_d2a_trim10_sig[3]),
// test13
.test13_ie   (1'b1),
.test13_oe   (1'b0),
.test13_a    (1'b0),
.test13_def  (1'b0),
.test13_y    (pad_d2a_trim11_sig[3]),
// test14
.test14_ie   (1'b1),
.test14_oe   (1'b0),
.test14_a    (1'b0),
.test14_def  (1'b0),
.test14_y    (pad_d2a_trim12_sig[3]),
// test15
.test15_ie   (1'b1),
.test15_oe   (1'b0),
.test15_a    (1'b0),
.test15_def  (1'b0),
.test15_y    (pad_d2a_trim13_sig[3]),
// test16
.test16_ie   (1'b1),
.test16_oe   (1'b0),
.test16_a    (1'b0),
.test16_def  (1'b0),
.test16_y    (pad_d2a_trim14_sig[3]),
// test17
.test17_ie   (1'b1),
.test17_oe   (1'b0),
.test17_a    (1'b0),
.test17_def  (1'b0),
.test17_y    (pad_d2a_adj0_sig[3]),
// test18
.test18_ie   (1'b1),
.test18_oe   (1'b0),
.test18_a    (1'b0),
.test18_def  (1'b0),
.test18_y    (pad_d2a_adj1_sig[3]),
// test19
.test19_ie   (1'b1),
.test19_oe   (1'b0),
.test19_a    (1'b0),
.test19_def  (1'b0),
.test19_y    (pad_d2a_adj2_sig[3]),
// test20
.test20_ie   (1'b1),
.test20_oe   (1'b0),
.test20_a    (1'b0),
.test20_def  (1'b0),
.test20_y    (pad_d2a_adj3_sig[3]),
// test21
.test21_ie   (1'b1),
.test21_oe   (1'b0),
.test21_a    (1'b0),
.test21_def  (1'b0),
.test21_y    (pad_d2a_adj4_sig[3]),
// test22
.test22_ie   (1'b1),
.test22_oe   (1'b0),
.test22_a    (1'b0),
.test22_def  (1'b0),
.test22_y    (pad_d2a_adj5_sig[3]),
// test23
.test23_ie   (1'b1),
.test23_oe   (1'b0),
.test23_a    (1'b0),
.test23_def  (1'b0),
.test23_y    (pad_d2a_adj6_sig[3]),
// test24
.test24_ie   (1'b1),
.test24_oe   (1'b0),
.test24_a    (1'b0),
.test24_def  (1'b0),
.test24_y    (pad_d2a_adj7_sig[3]),
// test25
.test25_ie   (1'b1),
.test25_oe   (1'b0),
.test25_a    (1'b0),
.test25_def  (1'b0),
.test25_y    (pad_d2a_adj8_sig[3]),
// test26
.test26_ie   (1'b1),
.test26_oe   (1'b0),
.test26_a    (1'b0),
.test26_def  (1'b0),
.test26_y    (pad_d2a_adj9_sig[3]),
// test27
.test27_ie   (1'b1),
.test27_oe   (1'b0),
.test27_a    (1'b0),
.test27_def  (1'b0),
.test27_y    (pad_d2a_adj10_sig[3]),
// test28
.test28_ie   (1'b1),
.test28_oe   (1'b0),
.test28_a    (1'b0),
.test28_def  (1'b0),
.test28_y    (pad_d2a_adj11_sig[3]),
// test29
.test29_ie   (1'b1),
.test29_oe   (1'b0),
.test29_a    (1'b0),
.test29_def  (1'b0),
.test29_y    (pad_d2a_adj12_sig[3]),
// test30
.test30_ie   (1'b1),
.test30_oe   (1'b0),
.test30_a    (1'b0),
.test30_def  (1'b0),
.test30_y    (pad_d2a_adj13_sig[3]),
// test31
.test31_ie   (1'b1),
.test31_oe   (1'b0),
.test31_a    (1'b0),
.test31_def  (1'b0),
.test31_y    (pad_d2a_adj14_sig[3]),

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
// test11: pad_d2a_trim9_sig[4]
// test12: pad_d2a_trim10_sig[4]
// test13: pad_d2a_trim11_sig[4]
// test14: pad_d2a_trim12_sig[4]
// test15: pad_d2a_trim13_sig[4]
// test16: pad_d2a_trim14_sig[4]
// test17: pad_d2a_adj0_sig[4]
// test18: pad_d2a_adj1_sig[4]
// test19: pad_d2a_adj2_sig[4]
// test20: pad_d2a_adj3_sig[4]
// test21: pad_d2a_adj4_sig[4]
// test22: pad_d2a_adj5_sig[4]
// test23: pad_d2a_adj6_sig[4]
// test24: pad_d2a_adj7_sig[4]
// test25: pad_d2a_adj8_sig[4]
// test26: pad_d2a_adj9_sig[4]
// test27: pad_d2a_adj10_sig[4]
// test28: pad_d2a_adj11_sig[4]
// test29: pad_d2a_adj12_sig[4]
// test30: pad_d2a_adj13_sig[4]
// test31: pad_d2a_adj14_sig[4]
  
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
.TEST10_CLKIN(0),
.TEST11_CLKIN(0),
.TEST12_CLKIN(0),
.TEST13_CLKIN(0),
.TEST14_CLKIN(0),
.TEST15_CLKIN(0),
.TEST16_CLKIN(0),
.TEST17_CLKIN(0),
.TEST18_CLKIN(0),
.TEST19_CLKIN(0),
.TEST20_CLKIN(0),
.TEST21_CLKIN(0),
.TEST22_CLKIN(0),
.TEST23_CLKIN(0),
.TEST24_CLKIN(0),
.TEST25_CLKIN(0),
.TEST26_CLKIN(0),
.TEST27_CLKIN(0),
.TEST28_CLKIN(0),
.TEST29_CLKIN(0),
.TEST30_CLKIN(0),
.TEST31_CLKIN(0))
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
.test10_en  (ATM8),
.test11_en  (ATM9),
.test12_en  (ATM10),
.test13_en  (ATM11),
.test14_en  (ATM12),
.test15_en  (ATM13),
.test16_en  (ATM14),
.test17_en  (ATM15),
.test18_en  (ATM16),
.test19_en  (ATM17),
.test20_en  (ATM18),
.test21_en  (ATM19),
.test22_en  (ATM20),
.test23_en  (ATM21),
.test24_en  (ATM22),
.test25_en  (ATM23),
.test26_en  (ATM24),
.test27_en  (ATM25),
.test28_en  (ATM26),
.test29_en  (ATM27),
.test30_en  (ATM28),
.test31_en  (ATM29),
//.test10_en  (ATM8),
//.test_ana   (1'b0),       //Disable IE/OE/A:: 
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
.altf_ie   (dual_en ? (dual_wr ? 1'b1 : 1'b0) : 1'b1),         //!dual_en || dual_wr
.altf_oe   (dual_en ? (dual_wr ? 1'b0 : 1'b1)  :1'b0),             //~(dual_en && dual_wr)      
.altf_a    (miso1),   //miso                      
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
.test10_ie   (1'b1),
.test10_oe   (1'b0),
.test10_a    (1'b0),
.test10_def  (1'b0),
.test10_y    (pad_d2a_trim8_sig[4]),
// test11
.test11_ie   (1'b1),
.test11_oe   (1'b0),
.test11_a    (1'b0),
.test11_def  (1'b0),
.test11_y    (pad_d2a_trim9_sig[4]),
// test12
.test12_ie   (1'b1),
.test12_oe   (1'b0),
.test12_a    (1'b0),
.test12_def  (1'b0),
.test12_y    (pad_d2a_trim10_sig[4]),
// test13
.test13_ie   (1'b1),
.test13_oe   (1'b0),
.test13_a    (1'b0),
.test13_def  (1'b0),
.test13_y    (pad_d2a_trim11_sig[4]),
// test14
.test14_ie   (1'b1),
.test14_oe   (1'b0),
.test14_a    (1'b0),
.test14_def  (1'b0),
.test14_y    (pad_d2a_trim12_sig[4]),
// test15
.test15_ie   (1'b1),
.test15_oe   (1'b0),
.test15_a    (1'b0),
.test15_def  (1'b0),
.test15_y    (pad_d2a_trim13_sig[4]),
// test16
.test16_ie   (1'b1),
.test16_oe   (1'b0),
.test16_a    (1'b0),
.test16_def  (1'b0),
.test16_y    (pad_d2a_trim14_sig[4]),
// test17
.test17_ie   (1'b1),
.test17_oe   (1'b0),
.test17_a    (1'b0),
.test17_def  (1'b0),
.test17_y    (pad_d2a_adj0_sig[4]),
// test18
.test18_ie   (1'b1),
.test18_oe   (1'b0),
.test18_a    (1'b0),
.test18_def  (1'b0),
.test18_y    (pad_d2a_adj1_sig[4]),
// test19
.test19_ie   (1'b1),
.test19_oe   (1'b0),
.test19_a    (1'b0),
.test19_def  (1'b0),
.test19_y    (pad_d2a_adj2_sig[4]),
// test20
.test20_ie   (1'b1),
.test20_oe   (1'b0),
.test20_a    (1'b0),
.test20_def  (1'b0),
.test20_y    (pad_d2a_adj3_sig[4]),
// test21
.test21_ie   (1'b1),
.test21_oe   (1'b0),
.test21_a    (1'b0),
.test21_def  (1'b0),
.test21_y    (pad_d2a_adj4_sig[4]),
// test22
.test22_ie   (1'b1),
.test22_oe   (1'b0),
.test22_a    (1'b0),
.test22_def  (1'b0),
.test22_y    (pad_d2a_adj5_sig[4]),
// test23
.test23_ie   (1'b1),
.test23_oe   (1'b0),
.test23_a    (1'b0),
.test23_def  (1'b0),
.test23_y    (pad_d2a_adj6_sig[4]),
// test24
.test24_ie   (1'b1),
.test24_oe   (1'b0),
.test24_a    (1'b0),
.test24_def  (1'b0),
.test24_y    (pad_d2a_adj7_sig[4]),
// test25
.test25_ie   (1'b1),
.test25_oe   (1'b0),
.test25_a    (1'b0),
.test25_def  (1'b0),
.test25_y    (pad_d2a_adj8_sig[4]),
// test26
.test26_ie   (1'b1),
.test26_oe   (1'b0),
.test26_a    (1'b0),
.test26_def  (1'b0),
.test26_y    (pad_d2a_adj9_sig[4]),
// test27
.test27_ie   (1'b1),
.test27_oe   (1'b0),
.test27_a    (1'b0),
.test27_def  (1'b0),
.test27_y    (pad_d2a_adj10_sig[4]),
// test28
.test28_ie   (1'b1),
.test28_oe   (1'b0),
.test28_a    (1'b0),
.test28_def  (1'b0),
.test28_y    (pad_d2a_adj11_sig[4]),
// test29
.test29_ie   (1'b1),
.test29_oe   (1'b0),
.test29_a    (1'b0),
.test29_def  (1'b0),
.test29_y    (pad_d2a_adj12_sig[4]),
// test30
.test30_ie   (1'b1),
.test30_oe   (1'b0),
.test30_a    (1'b0),
.test30_def  (1'b0),
.test30_y    (pad_d2a_adj13_sig[4]),
// test31
.test31_ie   (1'b1),
.test31_oe   (1'b0),
.test31_a    (1'b0),
.test31_def  (1'b0),
.test31_y    (pad_d2a_adj14_sig[4]),
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
// test11: pad_d2a_trim9_sig[5]
// test12: pad_d2a_trim10_sig[5]
// test13: pad_d2a_trim11_sig[5]
// test14: pad_d2a_trim12_sig[5]
// test15: pad_d2a_trim13_sig[5]
// test16: pad_d2a_trim14_sig[5]
// test17: pad_d2a_adj0_sig[5]
// test18: pad_d2a_adj1_sig[5]
// test19: pad_d2a_adj2_sig[5]
// test20: pad_d2a_adj3_sig[5]
// test21: pad_d2a_adj4_sig[5]
// test22: pad_d2a_adj5_sig[5]
// test23: pad_d2a_adj6_sig[5]
// test24: pad_d2a_adj7_sig[5]
// test25: pad_d2a_adj8_sig[5]
// test26: pad_d2a_adj9_sig[5]
// test27: pad_d2a_adj10_sig[5]
// test28: pad_d2a_adj11_sig[5]
// test29: pad_d2a_adj12_sig[5]
// test30: pad_d2a_adj13_sig[5]
// test31: pad_d2a_adj14_sig[5]

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
.TEST10_CLKIN(0),
.TEST11_CLKIN(0),
.TEST12_CLKIN(0),
.TEST13_CLKIN(0),
.TEST14_CLKIN(0),
.TEST15_CLKIN(0),
.TEST16_CLKIN(0),
.TEST17_CLKIN(0),
.TEST18_CLKIN(0),
.TEST19_CLKIN(0),
.TEST20_CLKIN(0),
.TEST21_CLKIN(0),
.TEST22_CLKIN(0),
.TEST23_CLKIN(0),
.TEST24_CLKIN(0),
.TEST25_CLKIN(0),
.TEST26_CLKIN(0),
.TEST27_CLKIN(0),
.TEST28_CLKIN(0),
.TEST29_CLKIN(0),
.TEST30_CLKIN(0),
.TEST31_CLKIN(0))
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
.test10_en  (ATM8),
.test11_en  (ATM9),
.test12_en  (ATM10),
.test13_en  (ATM11),
.test14_en  (ATM12),
.test15_en  (ATM13),
.test16_en  (ATM14),
.test17_en  (ATM15),
.test18_en  (ATM16),
.test19_en  (ATM17),
.test20_en  (ATM18),
.test21_en  (ATM19),
.test22_en  (ATM20),
.test23_en  (ATM21),
.test24_en  (ATM22),
.test25_en  (ATM23),
.test26_en  (ATM24),
.test27_en  (ATM25),
.test28_en  (ATM26),
.test29_en  (ATM27),
.test30_en  (ATM28),
.test31_en  (ATM29),
//.test10_en  (ATM8),
//.test_ana   (1'b0),       //Disable IE/OE/A:: 
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
.altf_ie   (dual_en ? (dual_wr ? 1'b1 : 1'b0) : 1'b0),         //dual_en && dual_wr
.altf_oe   (dual_en ? (dual_wr ? 1'b0 : 1'b1) : 1'b1),      //!dual_en || !dual_wr
//.altf_oe   (~cs_n),
.altf_a    (miso), //miso1
.altf_def  (1'b0),
.altf_y    (pad_mosi1), //pad_mosi1 
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
.test10_ie   (1'b1),
.test10_oe   (1'b0),
.test10_a    (1'b0),
.test10_def  (1'b0),
.test10_y    (pad_d2a_trim8_sig[5]),
// test11
.test11_ie   (1'b1),
.test11_oe   (1'b0),
.test11_a    (1'b0),
.test11_def  (1'b0),
.test11_y    (pad_d2a_trim9_sig[5]),
// test12
.test12_ie   (1'b1),
.test12_oe   (1'b0),
.test12_a    (1'b0),
.test12_def  (1'b0),
.test12_y    (pad_d2a_trim10_sig[5]),
// test13
.test13_ie   (1'b1),
.test13_oe   (1'b0),
.test13_a    (1'b0),
.test13_def  (1'b0),
.test13_y    (pad_d2a_trim11_sig[5]),
// test14
.test14_ie   (1'b1),
.test14_oe   (1'b0),
.test14_a    (1'b0),
.test14_def  (1'b0),
.test14_y    (pad_d2a_trim12_sig[5]),
// test15
.test15_ie   (1'b1),
.test15_oe   (1'b0),
.test15_a    (1'b0),
.test15_def  (1'b0),
.test15_y    (pad_d2a_trim13_sig[5]),
// test16
.test16_ie   (1'b1),
.test16_oe   (1'b0),
.test16_a    (1'b0),
.test16_def  (1'b0),
.test16_y    (pad_d2a_trim14_sig[5]),
// test17
.test17_ie   (1'b1),
.test17_oe   (1'b0),
.test17_a    (1'b0),
.test17_def  (1'b0),
.test17_y    (pad_d2a_adj0_sig[5]),
// test18
.test18_ie   (1'b1),
.test18_oe   (1'b0),
.test18_a    (1'b0),
.test18_def  (1'b0),
.test18_y    (pad_d2a_adj1_sig[5]),
// test19
.test19_ie   (1'b1),
.test19_oe   (1'b0),
.test19_a    (1'b0),
.test19_def  (1'b0),
.test19_y    (pad_d2a_adj2_sig[5]),
// test20
.test20_ie   (1'b1),
.test20_oe   (1'b0),
.test20_a    (1'b0),
.test20_def  (1'b0),
.test20_y    (pad_d2a_adj3_sig[5]),
// test21
.test21_ie   (1'b1),
.test21_oe   (1'b0),
.test21_a    (1'b0),
.test21_def  (1'b0),
.test21_y    (pad_d2a_adj4_sig[5]),
// test22
.test22_ie   (1'b1),
.test22_oe   (1'b0),
.test22_a    (1'b0),
.test22_def  (1'b0),
.test22_y    (pad_d2a_adj5_sig[5]),
// test23
.test23_ie   (1'b1),
.test23_oe   (1'b0),
.test23_a    (1'b0),
.test23_def  (1'b0),
.test23_y    (pad_d2a_adj6_sig[5]),
// test24
.test24_ie   (1'b1),
.test24_oe   (1'b0),
.test24_a    (1'b0),
.test24_def  (1'b0),
.test24_y    (pad_d2a_adj7_sig[5]),
// test25
.test25_ie   (1'b1),
.test25_oe   (1'b0),
.test25_a    (1'b0),
.test25_def  (1'b0),
.test25_y    (pad_d2a_adj8_sig[5]),
// test26
.test26_ie   (1'b1),
.test26_oe   (1'b0),
.test26_a    (1'b0),
.test26_def  (1'b0),
.test26_y    (pad_d2a_adj9_sig[5]),
// test27
.test27_ie   (1'b1),
.test27_oe   (1'b0),
.test27_a    (1'b0),
.test27_def  (1'b0),
.test27_y    (pad_d2a_adj10_sig[5]),
// test28
.test28_ie   (1'b1),
.test28_oe   (1'b0),
.test28_a    (1'b0),
.test28_def  (1'b0),
.test28_y    (pad_d2a_adj11_sig[5]),
// test29
.test29_ie   (1'b1),
.test29_oe   (1'b0),
.test29_a    (1'b0),
.test29_def  (1'b0),
.test29_y    (pad_d2a_adj12_sig[5]),
// test30
.test30_ie   (1'b1),
.test30_oe   (1'b0),
.test30_a    (1'b0),
.test30_def  (1'b0),
.test30_y    (pad_d2a_adj13_sig[5]),
// test31
.test31_ie   (1'b1),
.test31_oe   (1'b0),
.test31_a    (1'b0),
.test31_def  (1'b0),
.test31_y    (pad_d2a_adj14_sig[5]),


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
// test11: pad_d2a_trim9_sig[6]
// test12: pad_d2a_trim10_sig[6]
// test13: pad_d2a_trim11_sig[6]
// test14: pad_d2a_trim12_sig[6]
// test15: pad_d2a_trim13_sig[6]
// test16: pad_d2a_trim14_sig[6]
// test17: pad_d2a_adj0_sig[6]
// test18: pad_d2a_adj1_sig[6]
// test19: pad_d2a_adj2_sig[6]
// test20: pad_d2a_adj3_sig[6]
// test21: pad_d2a_adj4_sig[6]
// test22: pad_d2a_adj5_sig[6]
// test23: pad_d2a_adj6_sig[6]
// test24: pad_d2a_adj7_sig[6]
// test25: pad_d2a_adj8_sig[6]
// test26: pad_d2a_adj9_sig[6]
// test27: pad_d2a_adj10_sig[6]
// test28: pad_d2a_adj11_sig[6]
// test29: pad_d2a_adj12_sig[6]
// test30: pad_d2a_adj13_sig[6]
// test31: pad_d2a_adj14_sig[6]


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
.TEST10_CLKIN(0),
.TEST11_CLKIN(0),
.TEST12_CLKIN(0),
.TEST13_CLKIN(0),
.TEST14_CLKIN(0),
.TEST15_CLKIN(0),
.TEST16_CLKIN(0),
.TEST17_CLKIN(0),
.TEST18_CLKIN(0),
.TEST19_CLKIN(0),
.TEST20_CLKIN(0),
.TEST21_CLKIN(0),
.TEST22_CLKIN(0),
.TEST23_CLKIN(0),
.TEST24_CLKIN(0),
.TEST25_CLKIN(0),
.TEST26_CLKIN(0),
.TEST27_CLKIN(0),
.TEST28_CLKIN(0),
.TEST29_CLKIN(0),
.TEST30_CLKIN(0),
.TEST31_CLKIN(0))
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
.test10_en  (ATM8),
.test11_en  (ATM9),
.test12_en  (ATM10),
.test13_en  (ATM11),
.test14_en  (ATM12),
.test15_en  (ATM13),
.test16_en  (ATM14),
.test17_en  (ATM15),
.test18_en  (ATM16),
.test19_en  (ATM17),
.test20_en  (ATM18),
.test21_en  (ATM19),
.test22_en  (ATM20),
.test23_en  (ATM21),
.test24_en  (ATM22),
.test25_en  (ATM23),
.test26_en  (ATM24),
.test27_en  (ATM25),
.test28_en  (ATM26),
.test29_en  (ATM27),
.test30_en  (ATM28),
.test31_en  (ATM29),
//.test_ana   (1'b0),       //Disable IE/OE/A:: 
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
.test10_ie   (1'b1),
.test10_oe   (1'b0),
.test10_a    (1'b0),
.test10_def  (1'b0),
.test10_y    (pad_d2a_trim8_sig[6]),
// test11
.test11_ie   (1'b1),
.test11_oe   (1'b0),
.test11_a    (1'b0),
.test11_def  (1'b0),
.test11_y    (pad_d2a_trim9_sig[6]),
// test12
.test12_ie   (1'b1),
.test12_oe   (1'b0),
.test12_a    (1'b0),
.test12_def  (1'b0),
.test12_y    (pad_d2a_trim10_sig[6]),
// test13
.test13_ie   (1'b1),
.test13_oe   (1'b0),
.test13_a    (1'b0),
.test13_def  (1'b0),
.test13_y    (pad_d2a_trim11_sig[6]),
// test14
.test14_ie   (1'b1),
.test14_oe   (1'b0),
.test14_a    (1'b0),
.test14_def  (1'b0),
.test14_y    (pad_d2a_trim12_sig[6]),
// test15
.test15_ie   (1'b1),
.test15_oe   (1'b0),
.test15_a    (1'b0),
.test15_def  (1'b0),
.test15_y    (pad_d2a_trim13_sig[6]),
// test16
.test16_ie   (1'b1),
.test16_oe   (1'b0),
.test16_a    (1'b0),
.test16_def  (1'b0),
.test16_y    (pad_d2a_trim14_sig[6]),
// test17
.test17_ie   (1'b1),
.test17_oe   (1'b0),
.test17_a    (1'b0),
.test17_def  (1'b0),
.test17_y    (pad_d2a_adj0_sig[6]),
// test18
.test18_ie   (1'b1),
.test18_oe   (1'b0),
.test18_a    (1'b0),
.test18_def  (1'b0),
.test18_y    (pad_d2a_adj1_sig[6]),
// test19
.test19_ie   (1'b1),
.test19_oe   (1'b0),
.test19_a    (1'b0),
.test19_def  (1'b0),
.test19_y    (pad_d2a_adj2_sig[6]),
// test20
.test20_ie   (1'b1),
.test20_oe   (1'b0),
.test20_a    (1'b0),
.test20_def  (1'b0),
.test20_y    (pad_d2a_adj3_sig[6]),
// test21
.test21_ie   (1'b1),
.test21_oe   (1'b0),
.test21_a    (1'b0),
.test21_def  (1'b0),
.test21_y    (pad_d2a_adj4_sig[6]),
// test22
.test22_ie   (1'b1),
.test22_oe   (1'b0),
.test22_a    (1'b0),
.test22_def  (1'b0),
.test22_y    (pad_d2a_adj5_sig[6]),
// test23
.test23_ie   (1'b1),
.test23_oe   (1'b0),
.test23_a    (1'b0),
.test23_def  (1'b0),
.test23_y    (pad_d2a_adj6_sig[6]),
// test24
.test24_ie   (1'b1),
.test24_oe   (1'b0),
.test24_a    (1'b0),
.test24_def  (1'b0),
.test24_y    (pad_d2a_adj7_sig[6]),
// test25
.test25_ie   (1'b1),
.test25_oe   (1'b0),
.test25_a    (1'b0),
.test25_def  (1'b0),
.test25_y    (pad_d2a_adj8_sig[6]),
// test26
.test26_ie   (1'b1),
.test26_oe   (1'b0),
.test26_a    (1'b0),
.test26_def  (1'b0),
.test26_y    (pad_d2a_adj9_sig[6]),
// test27
.test27_ie   (1'b1),
.test27_oe   (1'b0),
.test27_a    (1'b0),
.test27_def  (1'b0),
.test27_y    (pad_d2a_adj10_sig[6]),
// test28
.test28_ie   (1'b1),
.test28_oe   (1'b0),
.test28_a    (1'b0),
.test28_def  (1'b0),
.test28_y    (pad_d2a_adj11_sig[6]),
// test29
.test29_ie   (1'b1),
.test29_oe   (1'b0),
.test29_a    (1'b0),
.test29_def  (1'b0),
.test29_y    (pad_d2a_adj12_sig[6]),
// test30
.test30_ie   (1'b1),
.test30_oe   (1'b0),
.test30_a    (1'b0),
.test30_def  (1'b0),
.test30_y    (pad_d2a_adj13_sig[6]),
// test31
.test31_ie   (1'b1),
.test31_oe   (1'b0),
.test31_a    (1'b0),
.test31_def  (1'b0),
.test31_y    (pad_d2a_adj14_sig[6]),

// with pad interface
.iopad_gpio_y    (i_ens2_IOBUF_Y[7]),
.iopad_gpio_ie   (o_ens2_IOBUF_IE[7]),
.iopad_gpio_oe   (o_ens2_IOBUF_OE[7]),
.iopad_gpio_a    (o_ens2_IOBUF_A[7])
); 

// GPIO8 pad
// normal: GPIO8_NORMAL_OUT
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
// test11: pad_d2a_trim9_sig[7]
// test12: pad_d2a_trim10_sig[7]
// test13: pad_d2a_trim11_sig[7]
// test14: pad_d2a_trim12_sig[7]
// test15: pad_d2a_trim13_sig[7]
// test16: pad_d2a_trim14_sig[7]
// test17: pad_d2a_adj0_sig[7]
// test18: pad_d2a_adj1_sig[7]
// test19: pad_d2a_adj2_sig[7]
// test20: pad_d2a_adj3_sig[7]
// test21: pad_d2a_adj4_sig[7]
// test22: pad_d2a_adj5_sig[7]
// test23: pad_d2a_adj6_sig[7]
// test24: pad_d2a_adj7_sig[7]
// test25: pad_d2a_adj8_sig[7]
// test26: pad_d2a_adj9_sig[7]
// test27: pad_d2a_adj10_sig[7]
// test28: pad_d2a_adj11_sig[7]
// test29: pad_d2a_adj12_sig[7]
// test30: pad_d2a_adj13_sig[7]
// test31: pad_d2a_adj14_sig[7]
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
.TEST10_CLKIN(0),
.TEST11_CLKIN(0),
.TEST12_CLKIN(0),
.TEST13_CLKIN(0),
.TEST14_CLKIN(0),
.TEST15_CLKIN(0),
.TEST16_CLKIN(0),
.TEST17_CLKIN(0),
.TEST18_CLKIN(0),
.TEST19_CLKIN(0),
.TEST20_CLKIN(0),
.TEST21_CLKIN(0),
.TEST22_CLKIN(0),
.TEST23_CLKIN(0),
.TEST24_CLKIN(0),
.TEST25_CLKIN(0),
.TEST26_CLKIN(0),
.TEST27_CLKIN(0),
.TEST28_CLKIN(0),
.TEST29_CLKIN(0),
.TEST30_CLKIN(0),
.TEST31_CLKIN(0))
//.TEST10_CLKIN(0))
u_gpio8_pinmux (
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
.test10_en  (ATM8),
.test11_en  (ATM9),
.test12_en  (ATM10),
.test13_en  (ATM11),
.test14_en  (ATM12),
.test15_en  (ATM13),
.test16_en  (ATM14),
.test17_en  (ATM15),
.test18_en  (ATM16),
.test19_en  (ATM17),
.test20_en  (ATM18),
.test21_en  (ATM19),
.test22_en  (ATM20),
.test23_en  (ATM21),
.test24_en  (ATM22),
.test25_en  (ATM23),
.test26_en  (ATM24),
.test27_en  (ATM25),
.test28_en  (ATM26),
.test29_en  (ATM27),
.test30_en  (ATM28),
.test31_en  (ATM29),

//.test10_en  (ATM8),
//.test_ana   (1'b0),       //Disable IE/OE/A:: 
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
.altf_a    (GPIO8_NORMAL_OUT),
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
.test10_ie   (1'b1),
.test10_oe   (1'b0),
.test10_a    (1'b0),
.test10_def  (1'b0),
.test10_y    (pad_d2a_trim8_sig[7]),
// test11
.test11_ie   (1'b1),
.test11_oe   (1'b0),
.test11_a    (1'b0),
.test11_def  (1'b0),
.test11_y    (pad_d2a_trim9_sig[7]),
// test12
.test12_ie   (1'b1),
.test12_oe   (1'b0),
.test12_a    (1'b0),
.test12_def  (1'b0),
.test12_y    (pad_d2a_trim10_sig[7]),
// test13
.test13_ie   (1'b1),
.test13_oe   (1'b0),
.test13_a    (1'b0),
.test13_def  (1'b0),
.test13_y    (pad_d2a_trim11_sig[7]),
// test14
.test14_ie   (1'b1),
.test14_oe   (1'b0),
.test14_a    (1'b0),
.test14_def  (1'b0),
.test14_y    (pad_d2a_trim12_sig[7]),
// test15
.test15_ie   (1'b1),
.test15_oe   (1'b0),
.test15_a    (1'b0),
.test15_def  (1'b0),
.test15_y    (pad_d2a_trim13_sig[7]),
// test16
.test16_ie   (1'b1),
.test16_oe   (1'b0),
.test16_a    (1'b0),
.test16_def  (1'b0),
.test16_y    (pad_d2a_trim14_sig[7]),
// test17
.test17_ie   (1'b1),
.test17_oe   (1'b0),
.test17_a    (1'b0),
.test17_def  (1'b0),
.test17_y    (pad_d2a_adj0_sig[7]),
// test18
.test18_ie   (1'b1),
.test18_oe   (1'b0),
.test18_a    (1'b0),
.test18_def  (1'b0),
.test18_y    (pad_d2a_adj1_sig[7]),
// test19
.test19_ie   (1'b1),
.test19_oe   (1'b0),
.test19_a    (1'b0),
.test19_def  (1'b0),
.test19_y    (pad_d2a_adj2_sig[7]),
// test20
.test20_ie   (1'b1),
.test20_oe   (1'b0),
.test20_a    (1'b0),
.test20_def  (1'b0),
.test20_y    (pad_d2a_adj3_sig[7]),
// test21
.test21_ie   (1'b1),
.test21_oe   (1'b0),
.test21_a    (1'b0),
.test21_def  (1'b0),
.test21_y    (pad_d2a_adj4_sig[7]),
// test22
.test22_ie   (1'b1),
.test22_oe   (1'b0),
.test22_a    (1'b0),
.test22_def  (1'b0),
.test22_y    (pad_d2a_adj5_sig[7]),
// test23
.test23_ie   (1'b1),
.test23_oe   (1'b0),
.test23_a    (1'b0),
.test23_def  (1'b0),
.test23_y    (pad_d2a_adj6_sig[7]),
// test24
.test24_ie   (1'b1),
.test24_oe   (1'b0),
.test24_a    (1'b0),
.test24_def  (1'b0),
.test24_y    (pad_d2a_adj7_sig[7]),
// test25
.test25_ie   (1'b1),
.test25_oe   (1'b0),
.test25_a    (1'b0),
.test25_def  (1'b0),
.test25_y    (pad_d2a_adj8_sig[7]),
// test26
.test26_ie   (1'b1),
.test26_oe   (1'b0),
.test26_a    (1'b0),
.test26_def  (1'b0),
.test26_y    (pad_d2a_adj9_sig[7]),
// test27
.test27_ie   (1'b1),
.test27_oe   (1'b0),
.test27_a    (1'b0),
.test27_def  (1'b0),
.test27_y    (pad_d2a_adj10_sig[7]),
// test28
.test28_ie   (1'b1),
.test28_oe   (1'b0),
.test28_a    (1'b0),
.test28_def  (1'b0),
.test28_y    (pad_d2a_adj11_sig[7]),
// test29
.test29_ie   (1'b1),
.test29_oe   (1'b0),
.test29_a    (1'b0),
.test29_def  (1'b0),
.test29_y    (pad_d2a_adj12_sig[7]),
// test30
.test30_ie   (1'b1),
.test30_oe   (1'b0),
.test30_a    (1'b0),
.test30_def  (1'b0),
.test30_y    (pad_d2a_adj13_sig[7]),
// test31
.test31_ie   (1'b1),
.test31_oe   (1'b0),
.test31_a    (1'b0),
.test31_def  (1'b0),
.test31_y    (pad_d2a_adj14_sig[7]),


// with pad interface
.iopad_gpio_y    (i_ens2_IOBUF_Y[8]),
.iopad_gpio_ie   (o_ens2_IOBUF_IE[8]),
.iopad_gpio_oe   (o_ens2_IOBUF_OE[8]),
.iopad_gpio_a    (o_ens2_IOBUF_A[8])
); 

// GPIO9 pad
// normal: INT1
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
// test11: OTP_VPP_EN
// test12: OTP_VPP_EN
// test13: OTP_VPP_EN
// test14: OTP_VPP_EN
// test15: OTP_VPP_EN
// test16: OTP_VPP_EN
// test17: OTP_VPP_EN
// test18: OTP_VPP_EN
// test19: OTP_VPP_EN
// test20: OTP_VPP_EN
// test21: OTP_VPP_EN
// test22: OTP_VPP_EN
// test23: OTP_VPP_EN
// test24: OTP_VPP_EN
// test25: OTP_VPP_EN
// test26: OTP_VPP_EN
// test27: OTP_VPP_EN
// test28: OTP_VPP_EN
// test29: OTP_VPP_EN
// test30: OTP_VPP_EN
// test31: OTP_VPP_EN

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
.TEST10_CLKIN(0),
.TEST11_CLKIN(0),
.TEST12_CLKIN(0),
.TEST13_CLKIN(0),
.TEST14_CLKIN(0),
.TEST15_CLKIN(0),
.TEST16_CLKIN(0),
.TEST17_CLKIN(0),
.TEST18_CLKIN(0),
.TEST19_CLKIN(0),
.TEST20_CLKIN(0),
.TEST21_CLKIN(0),
.TEST22_CLKIN(0),
.TEST23_CLKIN(0),
.TEST24_CLKIN(0),
.TEST25_CLKIN(0),
.TEST26_CLKIN(0),
.TEST27_CLKIN(0),
.TEST28_CLKIN(0),
.TEST29_CLKIN(0),
.TEST30_CLKIN(0),
.TEST31_CLKIN(0))
//.TEST10_CLKIN(0))
u_gpio9_pinmux (
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
.test10_en  (ATM8),
.test11_en  (ATM9),
.test12_en  (ATM10),
.test13_en  (ATM11),
.test14_en  (ATM12),
.test15_en  (ATM13),
.test16_en  (ATM14),
.test17_en  (ATM15),
.test18_en  (ATM16),
.test19_en  (ATM17),
.test20_en  (ATM18),
.test21_en  (ATM19),
.test22_en  (ATM20),
.test23_en  (ATM21),
.test24_en  (ATM22),
.test25_en  (ATM23),
.test26_en  (ATM24),
.test27_en  (ATM25),
.test28_en  (ATM26),
.test29_en  (ATM27),
.test30_en  (ATM28),
.test31_en  (ATM29),
//.test10_en  (ATM8),
//.test_ana   (1'b0),       //Disable IE/OE/A:: 
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
.altf_a    (INT1),
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
.test2_oe   (1'b1),
.test2_a    (i_otp_vpp_en),
.test2_def  (1'b0),
.test2_y    (),
// test3
.test3_ie   (1'b0),
.test3_oe   (1'b1),
.test3_a    (i_otp_vpp_en),
.test3_def  (1'b0),
.test3_y    (),
// test4
.test4_ie   (1'b0),
.test4_oe   (1'b1),
.test4_a    (i_otp_vpp_en),
.test4_def  (1'b0),
.test4_y    (),
// test5
.test5_ie   (1'b0),
.test5_oe   (1'b1),
.test5_a    (i_otp_vpp_en),
.test5_def  (1'b0),
.test5_y    (),
// test6
.test6_ie   (1'b0),
.test6_oe   (1'b1),
.test6_a    (i_otp_vpp_en),
.test6_def  (1'b0),
.test6_y    (),
// test7
.test7_ie   (1'b0),
.test7_oe   (1'b1),
.test7_a    (i_otp_vpp_en),
.test7_def  (1'b0),
.test7_y    (),
// test8
.test8_ie   (1'b0),
.test8_oe   (1'b1),
.test8_a    (i_otp_vpp_en),
.test8_def  (1'b0),
.test8_y    (),
// test9
.test9_ie   (1'b0),
.test9_oe   (1'b1),
.test9_a    (i_otp_vpp_en),
.test9_def  (1'b0),
.test9_y    (),
// test10
.test10_ie   (1'b0),
.test10_oe   (1'b1),
.test10_a    (i_otp_vpp_en),
.test10_def  (1'b0),
.test10_y    (),
// test11
.test11_ie   (1'b0),
.test11_oe   (1'b1),
.test11_a    (i_otp_vpp_en),
.test11_def  (1'b0),
.test11_y    (),
// test12
.test12_ie   (1'b0),
.test12_oe   (1'b1),
.test12_a    (i_otp_vpp_en),
.test12_def  (1'b0),
.test12_y    (),
// test13
.test13_ie   (1'b0),
.test13_oe   (1'b1),
.test13_a    (i_otp_vpp_en),
.test13_def  (1'b0),
.test13_y    (),
// test14
.test14_ie   (1'b0),
.test14_oe   (1'b1),
.test14_a    (i_otp_vpp_en),
.test14_def  (1'b0),
.test14_y    (),
// test15
.test15_ie   (1'b0),
.test15_oe   (1'b1),
.test15_a    (i_otp_vpp_en),
.test15_def  (1'b0),
.test15_y    (),
// test16
.test16_ie   (1'b0),
.test16_oe   (1'b1),
.test16_a    (i_otp_vpp_en),
.test16_def  (1'b0),
.test16_y    (),
// test17
.test17_ie   (1'b0),
.test17_oe   (1'b1),
.test17_a    (i_otp_vpp_en),
.test17_def  (1'b0),
.test17_y    (),
// test18
.test18_ie   (1'b0),
.test18_oe   (1'b1),
.test18_a    (i_otp_vpp_en),
.test18_def  (1'b0),
.test18_y    (),
// test19
.test19_ie   (1'b0),
.test19_oe   (1'b1),
.test19_a    (i_otp_vpp_en),
.test19_def  (1'b0),
.test19_y    (),
// test20
.test20_ie   (1'b0),
.test20_oe   (1'b1),
.test20_a    (i_otp_vpp_en),
.test20_def  (1'b0),
.test20_y    (),
// test21
.test21_ie   (1'b0),
.test21_oe   (1'b1),
.test21_a    (i_otp_vpp_en),
.test21_def  (1'b0),
.test21_y    (),
// test22
.test22_ie   (1'b0),
.test22_oe   (1'b1),
.test22_a    (i_otp_vpp_en),
.test22_def  (1'b0),
.test22_y    (),
// test23
.test23_ie   (1'b0),
.test23_oe   (1'b1),
.test23_a    (i_otp_vpp_en),
.test23_def  (1'b0),
.test23_y    (),
// test24
.test24_ie   (1'b0),
.test24_oe   (1'b1),
.test24_a    (i_otp_vpp_en),
.test24_def  (1'b0),
.test24_y    (),
// test25
.test25_ie   (1'b0),
.test25_oe   (1'b1),
.test25_a    (i_otp_vpp_en),
.test25_def  (1'b0),
.test25_y    (),
// test26
.test26_ie   (1'b0),
.test26_oe   (1'b1),
.test26_a    (i_otp_vpp_en),
.test26_def  (1'b0),
.test26_y    (),
// test27
.test27_ie   (1'b0),
.test27_oe   (1'b1),
.test27_a    (i_otp_vpp_en),
.test27_def  (1'b0),
.test27_y    (),
// test28
.test28_ie   (1'b0),
.test28_oe   (1'b1),
.test28_a    (i_otp_vpp_en),
.test28_def  (1'b0),
.test28_y    (),
// test29
.test29_ie   (1'b0),
.test29_oe   (1'b1),
.test29_a    (i_otp_vpp_en),
.test29_def  (1'b0),
.test29_y    (),
// test30
.test30_ie   (1'b0),
.test30_oe   (1'b1),
.test30_a    (i_otp_vpp_en),
.test30_def  (1'b0),
.test30_y    (),
// test31
.test31_ie   (1'b0),
.test31_oe   (1'b1),
.test31_a    (i_otp_vpp_en),
.test31_def  (1'b0),
.test31_y    (),

// with pad interface
.iopad_gpio_y    (i_ens2_IOBUF_Y[9]),
.iopad_gpio_ie   (o_ens2_IOBUF_IE[9]),          
.iopad_gpio_oe   (o_ens2_IOBUF_OE[9]),                                    
.iopad_gpio_a    (o_ens2_IOBUF_A[9])                                     
); 
// GPIO10 pad
// normal: INT2 
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
// test11: None
// test12: None
// test13: None
// test14: None
// test15: None
// test16: None
// test17: None
// test18: None
// test19: None
// test20: None
// test21: None
// test22: None
// test23: None
// test24: None
// test25: None
// test26: None
// test27: None
// test28: None
// test29: None
// test30: None
// test31: None
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
.TEST9_CLKIN(0),
.TEST10_CLKIN(0),
.TEST11_CLKIN(0),
.TEST12_CLKIN(0),
.TEST13_CLKIN(0),
.TEST14_CLKIN(0),
.TEST15_CLKIN(0),
.TEST16_CLKIN(0),
.TEST17_CLKIN(0),
.TEST18_CLKIN(0),
.TEST19_CLKIN(0),
.TEST20_CLKIN(0),
.TEST21_CLKIN(0),
.TEST22_CLKIN(0),
.TEST23_CLKIN(0),
.TEST24_CLKIN(0),
.TEST25_CLKIN(0),
.TEST26_CLKIN(0),
.TEST27_CLKIN(0),
.TEST28_CLKIN(0),
.TEST29_CLKIN(0),
.TEST30_CLKIN(0),
.TEST31_CLKIN(0))
//.TEST10_CLKIN(0))
u_gpio10_pinmux (
// test and alternate select
//.altf_sel   (altf_sel),   
.test_sel   (scan_mode ? 5'd0 : (ATM_CONFG ? 5'd1 : 5'd31)),     
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
.test10_en   (1'b0),
.test11_en   (1'b0),
.test12_en   (1'b0),
.test13_en   (1'b0),
.test14_en   (1'b0),
.test15_en   (1'b0),
.test16_en   (1'b0),
.test17_en   (1'b0),
.test18_en   (1'b0),
.test19_en   (1'b0),
.test20_en   (1'b0),
.test21_en   (1'b0),
.test22_en   (1'b0),
.test23_en   (1'b0),
.test24_en   (1'b0),
.test25_en   (1'b0),
.test26_en   (1'b0),
.test27_en   (1'b0),
.test28_en   (1'b0),
.test29_en   (1'b0),
.test30_en   (1'b0),
.test31_en   (1'b0),
//.test10_en  (1'b0),
//.test_ana   (1'b0),      //Disable IE/OE/A:: 
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
.altf_a    (INT2),
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
.test10_ie   (1'b0),
.test10_oe   (1'b0),
.test10_a    (1'b0),
.test10_def  (1'b0),
.test10_y    (),
// test11
.test11_ie   (1'b0),
.test11_oe   (1'b0),
.test11_a    (1'b0),
.test11_def  (1'b0),
.test11_y    (),
// test12
.test12_ie   (1'b0),
.test12_oe   (1'b0),
.test12_a    (1'b0),
.test12_def  (1'b0),
.test12_y    (),
// test13
.test13_ie   (1'b0),
.test13_oe   (1'b0),
.test13_a    (1'b0),
.test13_def  (1'b0),
.test13_y    (),
// test14
.test14_ie   (1'b0),
.test14_oe   (1'b0),
.test14_a    (1'b0),
.test14_def  (1'b0),
.test14_y    (),
// test15
.test15_ie   (1'b0),
.test15_oe   (1'b0),
.test15_a    (1'b0),
.test15_def  (1'b0),
.test15_y    (),
// test16
.test16_ie   (1'b0),
.test16_oe   (1'b0),
.test16_a    (1'b0),
.test16_def  (1'b0),
.test16_y    (),
// test17
.test17_ie   (1'b0),
.test17_oe   (1'b0),
.test17_a    (1'b0),
.test17_def  (1'b0),
.test17_y    (),
// test18
.test18_ie   (1'b0),
.test18_oe   (1'b0),
.test18_a    (1'b0),
.test18_def  (1'b0),
.test18_y    (),
// test19
.test19_ie   (1'b0),
.test19_oe   (1'b0),
.test19_a    (1'b0),
.test19_def  (1'b0),
.test19_y    (),
// test20
.test20_ie   (1'b0),
.test20_oe   (1'b0),
.test20_a    (1'b0),
.test20_def  (1'b0),
.test20_y    (),
// test21
.test21_ie   (1'b0),
.test21_oe   (1'b0),
.test21_a    (1'b0),
.test21_def  (1'b0),
.test21_y    (),
// test22
.test22_ie   (1'b0),
.test22_oe   (1'b0),
.test22_a    (1'b0),
.test22_def  (1'b0),
.test22_y    (),
// test23
.test23_ie   (1'b0),
.test23_oe   (1'b0),
.test23_a    (1'b0),
.test23_def  (1'b0),
.test23_y    (),
// test24
.test24_ie   (1'b0),
.test24_oe   (1'b0),
.test24_a    (1'b0),
.test24_def  (1'b0),
.test24_y    (),
// test25
.test25_ie   (1'b0),
.test25_oe   (1'b0),
.test25_a    (1'b0),
.test25_def  (1'b0),
.test25_y    (),
// test26
.test26_ie   (1'b0),
.test26_oe   (1'b0),
.test26_a    (1'b0),
.test26_def  (1'b0),
.test26_y    (),
// test27
.test27_ie   (1'b0),
.test27_oe   (1'b0),
.test27_a    (1'b0),
.test27_def  (1'b0),
.test27_y    (),
// test28
.test28_ie   (1'b0),
.test28_oe   (1'b0),
.test28_a    (1'b0),
.test28_def  (1'b0),
.test28_y    (),
// test29
.test29_ie   (1'b0),
.test29_oe   (1'b0),
.test29_a    (1'b0),
.test29_def  (1'b0),
.test29_y    (),
// test30
.test30_ie   (1'b0),
.test30_oe   (1'b0),
.test30_a    (1'b0),
.test30_def  (1'b0),
.test30_y    (),
// test31
.test31_ie   (1'b0),
.test31_oe   (1'b0),
.test31_a    (1'b0),
.test31_def  (1'b0),
.test31_y    (),
// with pad interface
.iopad_gpio_y    (i_ens2_IOBUF_Y[10]),
.iopad_gpio_ie   (o_ens2_IOBUF_IE[10]),
.iopad_gpio_oe   (o_ens2_IOBUF_OE[10]),
.iopad_gpio_a    (o_ens2_IOBUF_A[10])
); 


// GPIO11 pad
// normal: INT3 
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
// test11: None
// test12: None
// test13: None
// test14: None
// test15: None
// test16: None
// test17: None
// test18: None
// test19: None
// test20: None
// test21: None
// test22: None
// test23: None
// test24: None
// test25: None
// test26: None
// test27: None
// test28: None
// test29: None
// test30: None
// test31: None
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
.TEST10_CLKIN(0),
.TEST11_CLKIN(0),
.TEST12_CLKIN(0),
.TEST13_CLKIN(0),
.TEST14_CLKIN(0),
.TEST15_CLKIN(0),
.TEST16_CLKIN(0),
.TEST17_CLKIN(0),
.TEST18_CLKIN(0),
.TEST19_CLKIN(0),
.TEST20_CLKIN(0),
.TEST21_CLKIN(0),
.TEST22_CLKIN(0),
.TEST23_CLKIN(0),
.TEST24_CLKIN(0),
.TEST25_CLKIN(0),
.TEST26_CLKIN(0),
.TEST27_CLKIN(0),
.TEST28_CLKIN(0),
.TEST29_CLKIN(0),
.TEST30_CLKIN(0),
.TEST31_CLKIN(0))
//.TEST10_CLKIN(0))
u_gpio11_pinmux (
// test and alternate select
//.altf_sel   (2'b0),   
.test_sel   (scan_mode ? 5'd0 : (ATM_CONFG ? 5'd1 : 5'd31)),     
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
.test10_en   (1'b0),
.test11_en   (1'b0),
.test12_en   (1'b0),
.test13_en   (1'b0),
.test14_en   (1'b0),
.test15_en   (1'b0),
.test16_en   (1'b0),
.test17_en   (1'b0),
.test18_en   (1'b0),
.test19_en   (1'b0),
.test20_en   (1'b0),
.test21_en   (1'b0),
.test22_en   (1'b0),
.test23_en   (1'b0),
.test24_en   (1'b0),
.test25_en   (1'b0),
.test26_en   (1'b0),
.test27_en   (1'b0),
.test28_en   (1'b0),
.test29_en   (1'b0),
.test30_en   (1'b0),
.test31_en   (1'b0),
//.test10_en  (ATM8),
//.test_ana   (1'b0),       //Disable IE/OE/A:: 
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
.altf_a    (INT3),
.altf_def  (1'b0),
.altf_y    (),
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
.test10_ie   (1'b0),
.test10_oe   (1'b0),
.test10_a    (1'b0),
.test10_def  (1'b0),
.test10_y    (),
// test11
.test11_ie   (1'b0),
.test11_oe   (1'b0),
.test11_a    (1'b0),
.test11_def  (1'b0),
.test11_y    (),
// test12
.test12_ie   (1'b0),
.test12_oe   (1'b0),
.test12_a    (1'b0),
.test12_def  (1'b0),
.test12_y    (),
// test13
.test13_ie   (1'b0),
.test13_oe   (1'b0),
.test13_a    (1'b0),
.test13_def  (1'b0),
.test13_y    (),
// test14
.test14_ie   (1'b0),
.test14_oe   (1'b0),
.test14_a    (1'b0),
.test14_def  (1'b0),
.test14_y    (),
// test15
.test15_ie   (1'b0),
.test15_oe   (1'b0),
.test15_a    (1'b0),
.test15_def  (1'b0),
.test15_y    (),
// test16
.test16_ie   (1'b0),
.test16_oe   (1'b0),
.test16_a    (1'b0),
.test16_def  (1'b0),
.test16_y    (),
// test17
.test17_ie   (1'b0),
.test17_oe   (1'b0),
.test17_a    (1'b0),
.test17_def  (1'b0),
.test17_y    (),
// test18
.test18_ie   (1'b0),
.test18_oe   (1'b0),
.test18_a    (1'b0),
.test18_def  (1'b0),
.test18_y    (),
// test19
.test19_ie   (1'b0),
.test19_oe   (1'b0),
.test19_a    (1'b0),
.test19_def  (1'b0),
.test19_y    (),
// test20
.test20_ie   (1'b0),
.test20_oe   (1'b0),
.test20_a    (1'b0),
.test20_def  (1'b0),
.test20_y    (),
// test21
.test21_ie   (1'b0),
.test21_oe   (1'b0),
.test21_a    (1'b0),
.test21_def  (1'b0),
.test21_y    (),
// test22
.test22_ie   (1'b0),
.test22_oe   (1'b0),
.test22_a    (1'b0),
.test22_def  (1'b0),
.test22_y    (),
// test23
.test23_ie   (1'b0),
.test23_oe   (1'b0),
.test23_a    (1'b0),
.test23_def  (1'b0),
.test23_y    (),
// test24
.test24_ie   (1'b0),
.test24_oe   (1'b0),
.test24_a    (1'b0),
.test24_def  (1'b0),
.test24_y    (),
// test25
.test25_ie   (1'b0),
.test25_oe   (1'b0),
.test25_a    (1'b0),
.test25_def  (1'b0),
.test25_y    (),
// test26
.test26_ie   (1'b0),
.test26_oe   (1'b0),
.test26_a    (1'b0),
.test26_def  (1'b0),
.test26_y    (),
// test27
.test27_ie   (1'b0),
.test27_oe   (1'b0),
.test27_a    (1'b0),
.test27_def  (1'b0),
.test27_y    (),
// test28
.test28_ie   (1'b0),
.test28_oe   (1'b0),
.test28_a    (1'b0),
.test28_def  (1'b0),
.test28_y    (),
// test29
.test29_ie   (1'b0),
.test29_oe   (1'b0),
.test29_a    (1'b0),
.test29_def  (1'b0),
.test29_y    (),
// test30
.test30_ie   (1'b0),
.test30_oe   (1'b0),
.test30_a    (1'b0),
.test30_def  (1'b0),
.test30_y    (),
// test31
.test31_ie   (1'b0),
.test31_oe   (1'b0),
.test31_a    (1'b0),
.test31_def  (1'b0),
.test31_y    (),


// with pad interface
.iopad_gpio_y    (i_ens2_IOBUF_Y[11]),
.iopad_gpio_ie   (o_ens2_IOBUF_IE[11]),          
.iopad_gpio_oe   (o_ens2_IOBUF_OE[11]),                                    
.iopad_gpio_a    (o_ens2_IOBUF_A[11])                                     
); 

// GPIO12 pad
// normal: hfosc_out 
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
// test11: None
// test12: None
// test13: None
// test14: None
// test15: None
// test16: None
// test17: None
// test18: None
// test19: None
// test20: None
// test21: None
// test22: None
// test23: None
// test24: None
// test25: None
// test26: None
// test27: None
// test28: None
// test29: None
// test30: None
// test31: None

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
.TEST10_CLKIN(0),
.TEST11_CLKIN(0),
.TEST12_CLKIN(0),
.TEST13_CLKIN(0),
.TEST14_CLKIN(0),
.TEST15_CLKIN(0),
.TEST16_CLKIN(0),
.TEST17_CLKIN(0),
.TEST18_CLKIN(0),
.TEST19_CLKIN(0),
.TEST20_CLKIN(0),
.TEST21_CLKIN(0),
.TEST22_CLKIN(0),
.TEST23_CLKIN(0),
.TEST24_CLKIN(0),
.TEST25_CLKIN(0),
.TEST26_CLKIN(0),
.TEST27_CLKIN(0),
.TEST28_CLKIN(0),
.TEST29_CLKIN(0),
.TEST30_CLKIN(0),
.TEST31_CLKIN(0))
//.TEST10_CLKIN(0))
u_gpio12_pinmux (
// test and alternate select
//.altf_sel   (altf_sel),   
.test_sel   (scan_mode ? 5'd0 : (ATM_CONFG ? 5'd1 : 5'd31)),     
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
.test10_en   (1'b0),
.test11_en   (1'b0),
.test12_en   (1'b0),
.test13_en   (1'b0),
.test14_en   (1'b0),
.test15_en   (1'b0),
.test16_en   (1'b0),
.test17_en   (1'b0),
.test18_en   (1'b0),
.test19_en   (1'b0),
.test20_en   (1'b0),
.test21_en   (1'b0),
.test22_en   (1'b0),
.test23_en   (1'b0),
.test24_en   (1'b0),
.test25_en   (1'b0),
.test26_en   (1'b0),
.test27_en   (1'b0),
.test28_en   (1'b0),
.test29_en   (1'b0),
.test30_en   (1'b0),
.test31_en   (1'b0),
//.test_ana   (1'b0),      //Disable IE/OE/A:: 
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
.test10_ie   (1'b0),
.test10_oe   (1'b0),
.test10_a    (1'b0),
.test10_def  (1'b0),
.test10_y    (),
// test11
.test11_ie   (1'b0),
.test11_oe   (1'b0),
.test11_a    (1'b0),
.test11_def  (1'b0),
.test11_y    (),
// test12
.test12_ie   (1'b0),
.test12_oe   (1'b0),
.test12_a    (1'b0),
.test12_def  (1'b0),
.test12_y    (),
// test13
.test13_ie   (1'b0),
.test13_oe   (1'b0),
.test13_a    (1'b0),
.test13_def  (1'b0),
.test13_y    (),
// test14
.test14_ie   (1'b0),
.test14_oe   (1'b0),
.test14_a    (1'b0),
.test14_def  (1'b0),
.test14_y    (),
// test15
.test15_ie   (1'b0),
.test15_oe   (1'b0),
.test15_a    (1'b0),
.test15_def  (1'b0),
.test15_y    (),
// test16
.test16_ie   (1'b0),
.test16_oe   (1'b0),
.test16_a    (1'b0),
.test16_def  (1'b0),
.test16_y    (),
// test17
.test17_ie   (1'b0),
.test17_oe   (1'b0),
.test17_a    (1'b0),
.test17_def  (1'b0),
.test17_y    (),
// test18
.test18_ie   (1'b0),
.test18_oe   (1'b0),
.test18_a    (1'b0),
.test18_def  (1'b0),
.test18_y    (),
// test19
.test19_ie   (1'b0),
.test19_oe   (1'b0),
.test19_a    (1'b0),
.test19_def  (1'b0),
.test19_y    (),
// test20
.test20_ie   (1'b0),
.test20_oe   (1'b0),
.test20_a    (1'b0),
.test20_def  (1'b0),
.test20_y    (),
// test21
.test21_ie   (1'b0),
.test21_oe   (1'b0),
.test21_a    (1'b0),
.test21_def  (1'b0),
.test21_y    (),
// test22
.test22_ie   (1'b0),
.test22_oe   (1'b0),
.test22_a    (1'b0),
.test22_def  (1'b0),
.test22_y    (),
// test23
.test23_ie   (1'b0),
.test23_oe   (1'b0),
.test23_a    (1'b0),
.test23_def  (1'b0),
.test23_y    (),
// test24
.test24_ie   (1'b0),
.test24_oe   (1'b0),
.test24_a    (1'b0),
.test24_def  (1'b0),
.test24_y    (),
// test25
.test25_ie   (1'b0),
.test25_oe   (1'b0),
.test25_a    (1'b0),
.test25_def  (1'b0),
.test25_y    (),
// test26
.test26_ie   (1'b0),
.test26_oe   (1'b0),
.test26_a    (1'b0),
.test26_def  (1'b0),
.test26_y    (),
// test27
.test27_ie   (1'b0),
.test27_oe   (1'b0),
.test27_a    (1'b0),
.test27_def  (1'b0),
.test27_y    (),
// test28
.test28_ie   (1'b0),
.test28_oe   (1'b0),
.test28_a    (1'b0),
.test28_def  (1'b0),
.test28_y    (),
// test29
.test29_ie   (1'b0),
.test29_oe   (1'b0),
.test29_a    (1'b0),
.test29_def  (1'b0),
.test29_y    (),
// test30
.test30_ie   (1'b0),
.test30_oe   (1'b0),
.test30_a    (1'b0),
.test30_def  (1'b0),
.test30_y    (),
// test31
.test31_ie   (1'b0),
.test31_oe   (1'b0),
.test31_a    (1'b0),
.test31_def  (1'b0),
.test31_y    (),

// with pad interface
.iopad_gpio_y    (i_ens2_IOBUF_Y[12]),
.iopad_gpio_ie   (o_ens2_IOBUF_IE[12]),
.iopad_gpio_oe   (o_ens2_IOBUF_OE[12]),
.iopad_gpio_a    (o_ens2_IOBUF_A[12])
); 

// GPIO13 pad
// normal:  int_clk_out_gpio
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
// test10: None
// test11: None
// test12: None
// test13: None
// test14: None
// test15: None
// test16: None
// test17: None
// test18: None
// test19: None
// test20: None
// test21: None
// test22: None
// test23: None
// test24: None
// test25: None
// test26: None
// test27: None
// test28: None
// test29: None
// test30: None
// test31: None
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
.TEST10_CLKIN(0),
.TEST11_CLKIN(0),
.TEST12_CLKIN(0),
.TEST13_CLKIN(0),
.TEST14_CLKIN(0),
.TEST15_CLKIN(0),
.TEST16_CLKIN(0),
.TEST17_CLKIN(0),
.TEST18_CLKIN(0),
.TEST19_CLKIN(0),
.TEST20_CLKIN(0),
.TEST21_CLKIN(0),
.TEST22_CLKIN(0),
.TEST23_CLKIN(0),
.TEST24_CLKIN(0),
.TEST25_CLKIN(0),
.TEST26_CLKIN(0),
.TEST27_CLKIN(0),
.TEST28_CLKIN(0),
.TEST29_CLKIN(0),
.TEST30_CLKIN(0),
.TEST31_CLKIN(0))
//.TEST10_CLKIN(0))
u_gpio13_pinmux (
// test and alternate select
//.altf_sel   (altf_sel),   
.test_sel   (scan_mode ? 5'd0 : (ATM_CONFG ? 5'd1 : 5'd31)),    
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
.test10_en   (1'b0),
.test11_en   (1'b0),
.test12_en   (1'b0),
.test13_en   (1'b0),
.test14_en   (1'b0),
.test15_en   (1'b0),
.test16_en   (1'b0),
.test17_en   (1'b0),
.test18_en   (1'b0),
.test19_en   (1'b0),
.test20_en   (1'b0),
.test21_en   (1'b0),
.test22_en   (1'b0),
.test23_en   (1'b0),
.test24_en   (1'b0),
.test25_en   (1'b0),
.test26_en   (1'b0),
.test27_en   (1'b0),
.test28_en   (1'b0),
.test29_en   (1'b0),
.test30_en   (1'b0),
.test31_en   (1'b0),
//.test10_en  (1'b0),
//.test_ana   (1'b0),       //Disable IE/OE/A:: 
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
.altf_ie   (1'b1),
.altf_oe   (1'b0),
.altf_a    (1'b0),
.altf_def  (1'b0),
.altf_y    (int_clk_out_gpio),
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
.test10_ie   (1'b0),
.test10_oe   (1'b0),
.test10_a    (1'b0),
.test10_def  (1'b0),
.test10_y    (),
// test11
.test11_ie   (1'b0),
.test11_oe   (1'b0),
.test11_a    (1'b0),
.test11_def  (1'b0),
.test11_y    (),
// test12
.test12_ie   (1'b0),
.test12_oe   (1'b0),
.test12_a    (1'b0),
.test12_def  (1'b0),
.test12_y    (),
// test13
.test13_ie   (1'b0),
.test13_oe   (1'b0),
.test13_a    (1'b0),
.test13_def  (1'b0),
.test13_y    (),
// test14
.test14_ie   (1'b0),
.test14_oe   (1'b0),
.test14_a    (1'b0),
.test14_def  (1'b0),
.test14_y    (),
// test15
.test15_ie   (1'b0),
.test15_oe   (1'b0),
.test15_a    (1'b0),
.test15_def  (1'b0),
.test15_y    (),
// test16
.test16_ie   (1'b0),
.test16_oe   (1'b0),
.test16_a    (1'b0),
.test16_def  (1'b0),
.test16_y    (),
// test17
.test17_ie   (1'b0),
.test17_oe   (1'b0),
.test17_a    (1'b0),
.test17_def  (1'b0),
.test17_y    (),
// test18
.test18_ie   (1'b0),
.test18_oe   (1'b0),
.test18_a    (1'b0),
.test18_def  (1'b0),
.test18_y    (),
// test19
.test19_ie   (1'b0),
.test19_oe   (1'b0),
.test19_a    (1'b0),
.test19_def  (1'b0),
.test19_y    (),
// test20
.test20_ie   (1'b0),
.test20_oe   (1'b0),
.test20_a    (1'b0),
.test20_def  (1'b0),
.test20_y    (),
// test21
.test21_ie   (1'b0),
.test21_oe   (1'b0),
.test21_a    (1'b0),
.test21_def  (1'b0),
.test21_y    (),
// test22
.test22_ie   (1'b0),
.test22_oe   (1'b0),
.test22_a    (1'b0),
.test22_def  (1'b0),
.test22_y    (),
// test23
.test23_ie   (1'b0),
.test23_oe   (1'b0),
.test23_a    (1'b0),
.test23_def  (1'b0),
.test23_y    (),
// test24
.test24_ie   (1'b0),
.test24_oe   (1'b0),
.test24_a    (1'b0),
.test24_def  (1'b0),
.test24_y    (),
// test25
.test25_ie   (1'b0),
.test25_oe   (1'b0),
.test25_a    (1'b0),
.test25_def  (1'b0),
.test25_y    (),
// test26
.test26_ie   (1'b0),
.test26_oe   (1'b0),
.test26_a    (1'b0),
.test26_def  (1'b0),
.test26_y    (),
// test27
.test27_ie   (1'b0),
.test27_oe   (1'b0),
.test27_a    (1'b0),
.test27_def  (1'b0),
.test27_y    (),
// test28
.test28_ie   (1'b0),
.test28_oe   (1'b0),
.test28_a    (1'b0),
.test28_def  (1'b0),
.test28_y    (),
// test29
.test29_ie   (1'b0),
.test29_oe   (1'b0),
.test29_a    (1'b0),
.test29_def  (1'b0),
.test29_y    (),
// test30
.test30_ie   (1'b0),
.test30_oe   (1'b0),
.test30_a    (1'b0),
.test30_def  (1'b0),
.test30_y    (),
// test31
.test31_ie   (1'b0),
.test31_oe   (1'b0),
.test31_a    (1'b0),
.test31_def  (1'b0),
.test31_y    (),

// with pad interface
.iopad_gpio_y    (i_ens2_IOBUF_Y[13]),
.iopad_gpio_ie   (o_ens2_IOBUF_IE[13]),
.iopad_gpio_oe   (o_ens2_IOBUF_OE[13]),
.iopad_gpio_a    (o_ens2_IOBUF_A[13])
); 

// GPIO14 pad
// normal: NIRS_LED_ON0
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
// test11: None
// test12: None
// test13: None
// test14: None
// test15: None
// test16: None
// test17: None
// test18: None
// test19: None
// test20: None
// test21: None
// test22: None
// test23: None
// test24: None
// test25: None
// test26: None
// test27: None
// test28: None
// test29: None
// test30: None
// test31: None
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
.TEST10_CLKIN(0),
.TEST11_CLKIN(0),
.TEST12_CLKIN(0),
.TEST13_CLKIN(0),
.TEST14_CLKIN(0),
.TEST15_CLKIN(0),
.TEST16_CLKIN(0),
.TEST17_CLKIN(0),
.TEST18_CLKIN(0),
.TEST19_CLKIN(0),
.TEST20_CLKIN(0),
.TEST21_CLKIN(0),
.TEST22_CLKIN(0),
.TEST23_CLKIN(0),
.TEST24_CLKIN(0),
.TEST25_CLKIN(0),
.TEST26_CLKIN(0),
.TEST27_CLKIN(0),
.TEST28_CLKIN(0),
.TEST29_CLKIN(0),
.TEST30_CLKIN(0),
.TEST31_CLKIN(0))
//.TEST10_CLKIN(0))
u_gpio14_pinmux (
// test and alternate select
//.altf_sel   (altf_sel),   
.test_sel   (scan_mode ? 5'd0 : (ATM_CONFG ? 5'd1 : 5'd31)),    // this needs to be changed if more than 10 testmodes require(including scan &bist), currently scan,otpbist,ATM0-8 supported
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
.test10_en   (1'b0),
.test11_en   (1'b0),
.test12_en   (1'b0),
.test13_en   (1'b0),
.test14_en   (1'b0),
.test15_en   (1'b0),
.test16_en   (1'b0),
.test17_en   (1'b0),
.test18_en   (1'b0),
.test19_en   (1'b0),
.test20_en   (1'b0),
.test21_en   (1'b0),
.test22_en   (1'b0),
.test23_en   (1'b0),
.test24_en   (1'b0),
.test25_en   (1'b0),
.test26_en   (1'b0),
.test27_en   (1'b0),
.test28_en   (1'b0),
.test29_en   (1'b0),
.test30_en   (1'b0),
.test31_en   (1'b0),
//.test10_en  (1'b0),
//.test_ana   (1'b0),       //Disable IE/OE/A:: 
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
.altf_a    (NIRS_LED_ON0),
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
.test10_ie   (1'b0),
.test10_oe   (1'b0),
.test10_a    (1'b0),
.test10_def  (1'b0),
.test10_y    (),
// test11
.test11_ie   (1'b0),
.test11_oe   (1'b0),
.test11_a    (1'b0),
.test11_def  (1'b0),
.test11_y    (),
// test12
.test12_ie   (1'b0),
.test12_oe   (1'b0),
.test12_a    (1'b0),
.test12_def  (1'b0),
.test12_y    (),
// test13
.test13_ie   (1'b0),
.test13_oe   (1'b0),
.test13_a    (1'b0),
.test13_def  (1'b0),
.test13_y    (),
// test14
.test14_ie   (1'b0),
.test14_oe   (1'b0),
.test14_a    (1'b0),
.test14_def  (1'b0),
.test14_y    (),
// test15
.test15_ie   (1'b0),
.test15_oe   (1'b0),
.test15_a    (1'b0),
.test15_def  (1'b0),
.test15_y    (),
// test16
.test16_ie   (1'b0),
.test16_oe   (1'b0),
.test16_a    (1'b0),
.test16_def  (1'b0),
.test16_y    (),
// test17
.test17_ie   (1'b0),
.test17_oe   (1'b0),
.test17_a    (1'b0),
.test17_def  (1'b0),
.test17_y    (),
// test18
.test18_ie   (1'b0),
.test18_oe   (1'b0),
.test18_a    (1'b0),
.test18_def  (1'b0),
.test18_y    (),
// test19
.test19_ie   (1'b0),
.test19_oe   (1'b0),
.test19_a    (1'b0),
.test19_def  (1'b0),
.test19_y    (),
// test20
.test20_ie   (1'b0),
.test20_oe   (1'b0),
.test20_a    (1'b0),
.test20_def  (1'b0),
.test20_y    (),
// test21
.test21_ie   (1'b0),
.test21_oe   (1'b0),
.test21_a    (1'b0),
.test21_def  (1'b0),
.test21_y    (),
// test22
.test22_ie   (1'b0),
.test22_oe   (1'b0),
.test22_a    (1'b0),
.test22_def  (1'b0),
.test22_y    (),
// test23
.test23_ie   (1'b0),
.test23_oe   (1'b0),
.test23_a    (1'b0),
.test23_def  (1'b0),
.test23_y    (),
// test24
.test24_ie   (1'b0),
.test24_oe   (1'b0),
.test24_a    (1'b0),
.test24_def  (1'b0),
.test24_y    (),
// test25
.test25_ie   (1'b0),
.test25_oe   (1'b0),
.test25_a    (1'b0),
.test25_def  (1'b0),
.test25_y    (),
// test26
.test26_ie   (1'b0),
.test26_oe   (1'b0),
.test26_a    (1'b0),
.test26_def  (1'b0),
.test26_y    (),
// test27
.test27_ie   (1'b0),
.test27_oe   (1'b0),
.test27_a    (1'b0),
.test27_def  (1'b0),
.test27_y    (),
// test28
.test28_ie   (1'b0),
.test28_oe   (1'b0),
.test28_a    (1'b0),
.test28_def  (1'b0),
.test28_y    (),
// test29
.test29_ie   (1'b0),
.test29_oe   (1'b0),
.test29_a    (1'b0),
.test29_def  (1'b0),
.test29_y    (),
// test30
.test30_ie   (1'b0),
.test30_oe   (1'b0),
.test30_a    (1'b0),
.test30_def  (1'b0),
.test30_y    (),
// test31
.test31_ie   (1'b0),
.test31_oe   (1'b0),
.test31_a    (1'b0),
.test31_def  (1'b0),
.test31_y    (),

// with pad interface
.iopad_gpio_y    (i_ens2_IOBUF_Y[14]),
.iopad_gpio_ie   (o_ens2_IOBUF_IE[14]),         
.iopad_gpio_oe   (o_ens2_IOBUF_OE[14]),                                    
.iopad_gpio_a    (o_ens2_IOBUF_A[14])                                     
); 


// GPIO15 pad
// normal: NIRS_LED_ON1/NIRS_RESET_SW0 
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
// test11: None
// test12: None
// test13: None
// test14: None
// test15: None
// test16: None
// test17: None
// test18: None
// test19: None
// test20: None
// test21: None
// test22: None
// test23: None
// test24: None
// test25: None
// test26: None
// test27: None
// test28: None
// test29: None
// test30: None
// test31: None
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
.TEST10_CLKIN(0),
.TEST11_CLKIN(0),
.TEST12_CLKIN(0),
.TEST13_CLKIN(0),
.TEST14_CLKIN(0),
.TEST15_CLKIN(0),
.TEST16_CLKIN(0),
.TEST17_CLKIN(0),
.TEST18_CLKIN(0),
.TEST19_CLKIN(0),
.TEST20_CLKIN(0),
.TEST21_CLKIN(0),
.TEST22_CLKIN(0),
.TEST23_CLKIN(0),
.TEST24_CLKIN(0),
.TEST25_CLKIN(0),
.TEST26_CLKIN(0),
.TEST27_CLKIN(0),
.TEST28_CLKIN(0),
.TEST29_CLKIN(0),
.TEST30_CLKIN(0),
.TEST31_CLKIN(0))
//.TEST10_CLKIN(0))
u_gpio15_pinmux (
// test and alternate select
//.altf_sel   (altf_sel),   
.test_sel   (test_sel),
.test_en    (test_en),
.test0_en   (scan_mode),
.test1_en   (1'b0),
.test2_en   (1'b0), 
.test3_en   (1'b0),
.test4_en   (1'b0),
.test5_en   (1'b0),
.test6_en   (1'b0),
.test7_en   (1'b0),
.test8_en   (1'b0),
.test9_en   (1'b0),
.test10_en   (1'b0),
.test11_en   (1'b0),
.test12_en   (1'b0),
.test13_en   (1'b0),
.test14_en   (1'b0),
.test15_en   (1'b0),
.test16_en   (1'b0),
.test17_en   (1'b0),
.test18_en   (1'b0),
.test19_en   (1'b0),
.test20_en   (1'b0),
.test21_en   (1'b0),
.test22_en   (1'b0),
.test23_en   (1'b0),
.test24_en   (1'b0),
.test25_en   (1'b0),
.test26_en   (1'b0),
.test27_en   (1'b0),
.test28_en   (1'b0),
.test29_en   (1'b0),
.test30_en   (1'b0),
.test31_en   (1'b0),
//.test10_en  (ATM8),
//.test_ana   (1'b0),       //Disable IE/OE/A:: TESTMODE0 GPIO0 serves pure analog signal
// alternate function
.altf_ie   (1'b0),
.altf_oe   (1'b1),
.altf_a    (GPIO15_NORMAL_OUT),
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
.test10_ie   (1'b0),
.test10_oe   (1'b0),
.test10_a    (1'b0),
.test10_def  (1'b0),
.test10_y    (),
// test11
.test11_ie   (1'b0),
.test11_oe   (1'b0),
.test11_a    (1'b0),
.test11_def  (1'b0),
.test11_y    (),
// test12
.test12_ie   (1'b0),
.test12_oe   (1'b0),
.test12_a    (1'b0),
.test12_def  (1'b0),
.test12_y    (),
// test13
.test13_ie   (1'b0),
.test13_oe   (1'b0),
.test13_a    (1'b0),
.test13_def  (1'b0),
.test13_y    (),
// test14
.test14_ie   (1'b0),
.test14_oe   (1'b0),
.test14_a    (1'b0),
.test14_def  (1'b0),
.test14_y    (),
// test15
.test15_ie   (1'b0),
.test15_oe   (1'b0),
.test15_a    (1'b0),
.test15_def  (1'b0),
.test15_y    (),
// test16
.test16_ie   (1'b0),
.test16_oe   (1'b0),
.test16_a    (1'b0),
.test16_def  (1'b0),
.test16_y    (),
// test17
.test17_ie   (1'b0),
.test17_oe   (1'b0),
.test17_a    (1'b0),
.test17_def  (1'b0),
.test17_y    (),
// test18
.test18_ie   (1'b0),
.test18_oe   (1'b0),
.test18_a    (1'b0),
.test18_def  (1'b0),
.test18_y    (),
// test19
.test19_ie   (1'b0),
.test19_oe   (1'b0),
.test19_a    (1'b0),
.test19_def  (1'b0),
.test19_y    (),
// test20
.test20_ie   (1'b0),
.test20_oe   (1'b0),
.test20_a    (1'b0),
.test20_def  (1'b0),
.test20_y    (),
// test21
.test21_ie   (1'b0),
.test21_oe   (1'b0),
.test21_a    (1'b0),
.test21_def  (1'b0),
.test21_y    (),
// test22
.test22_ie   (1'b0),
.test22_oe   (1'b0),
.test22_a    (1'b0),
.test22_def  (1'b0),
.test22_y    (),
// test23
.test23_ie   (1'b0),
.test23_oe   (1'b0),
.test23_a    (1'b0),
.test23_def  (1'b0),
.test23_y    (),
// test24
.test24_ie   (1'b0),
.test24_oe   (1'b0),
.test24_a    (1'b0),
.test24_def  (1'b0),
.test24_y    (),
// test25
.test25_ie   (1'b0),
.test25_oe   (1'b0),
.test25_a    (1'b0),
.test25_def  (1'b0),
.test25_y    (),
// test26
.test26_ie   (1'b0),
.test26_oe   (1'b0),
.test26_a    (1'b0),
.test26_def  (1'b0),
.test26_y    (),
// test27
.test27_ie   (1'b0),
.test27_oe   (1'b0),
.test27_a    (1'b0),
.test27_def  (1'b0),
.test27_y    (),
// test28
.test28_ie   (1'b0),
.test28_oe   (1'b0),
.test28_a    (1'b0),
.test28_def  (1'b0),
.test28_y    (),
// test29
.test29_ie   (1'b0),
.test29_oe   (1'b0),
.test29_a    (1'b0),
.test29_def  (1'b0),
.test29_y    (),
// test30
.test30_ie   (1'b0),
.test30_oe   (1'b0),
.test30_a    (1'b0),
.test30_def  (1'b0),
.test30_y    (),
// test31
.test31_ie   (1'b0),
.test31_oe   (1'b0),
.test31_a    (1'b0),
.test31_def  (1'b0),
.test31_y    (),
// with pad interface
.iopad_gpio_y    (i_ens2_IOBUF_Y[15]),
.iopad_gpio_ie   (o_ens2_IOBUF_IE[15]),         
.iopad_gpio_oe   (o_ens2_IOBUF_OE[15]),                                    
.iopad_gpio_a    (o_ens2_IOBUF_A[15])                                     
); 


// GPIO16 pad
// normal: NIRS_LED_ON2/NIRS_IPD_SW0 
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
// test11: None
// test12: None
// test13: None
// test14: None
// test15: None
// test16: None
// test17: None
// test18: None
// test19: None
// test20: None
// test21: None
// test22: None
// test23: None
// test24: None
// test25: None
// test26: None
// test27: None
// test28: None
// test29: None
// test30: None
// test31: None

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
.TEST10_CLKIN(0),
.TEST11_CLKIN(0),
.TEST12_CLKIN(0),
.TEST13_CLKIN(0),
.TEST14_CLKIN(0),
.TEST15_CLKIN(0),
.TEST16_CLKIN(0),
.TEST17_CLKIN(0),
.TEST18_CLKIN(0),
.TEST19_CLKIN(0),
.TEST20_CLKIN(0),
.TEST21_CLKIN(0),
.TEST22_CLKIN(0),
.TEST23_CLKIN(0),
.TEST24_CLKIN(0),
.TEST25_CLKIN(0),
.TEST26_CLKIN(0),
.TEST27_CLKIN(0),
.TEST28_CLKIN(0),
.TEST29_CLKIN(0),
.TEST30_CLKIN(0),
.TEST31_CLKIN(0))
//.TEST10_CLKIN(0))
u_gpio16_pinmux (
// test and alternate select
//.altf_sel   (altf_sel),   
.test_sel   (test_sel),
.test_en    (test_en),
.test0_en   (scan_mode),
.test1_en   (1'b0),
.test2_en   (1'b0), 
.test3_en   (1'b0),
.test4_en   (1'b0),
.test5_en   (1'b0),
.test6_en   (1'b0),
.test7_en   (1'b0),
.test8_en   (1'b0),
.test9_en   (1'b0),
.test10_en   (1'b0),
.test11_en   (1'b0),
.test12_en   (1'b0),
.test13_en   (1'b0),
.test14_en   (1'b0),
.test15_en   (1'b0),
.test16_en   (1'b0),
.test17_en   (1'b0),
.test18_en   (1'b0),
.test19_en   (1'b0),
.test20_en   (1'b0),
.test21_en   (1'b0),
.test22_en   (1'b0),
.test23_en   (1'b0),
.test24_en   (1'b0),
.test25_en   (1'b0),
.test26_en   (1'b0),
.test27_en   (1'b0),
.test28_en   (1'b0),
.test29_en   (1'b0),
.test30_en   (1'b0),
.test31_en   (1'b0),
//.test10_en  (ATM8),
//.test_ana   (1'b0),       //Disable IE/OE/A:: TESTMODE0 GPIO0 serves pure analog signal
// alternate function
.altf_ie   (1'b0),
.altf_oe   (1'b1),
.altf_a    (GPIO16_NORMAL_OUT),
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
.test10_ie   (1'b0),
.test10_oe   (1'b0),
.test10_a    (1'b0),
.test10_def  (1'b0),
.test10_y    (),
// test11
.test11_ie   (1'b0),
.test11_oe   (1'b0),
.test11_a    (1'b0),
.test11_def  (1'b0),
.test11_y    (),
// test12
.test12_ie   (1'b0),
.test12_oe   (1'b0),
.test12_a    (1'b0),
.test12_def  (1'b0),
.test12_y    (),
// test13
.test13_ie   (1'b0),
.test13_oe   (1'b0),
.test13_a    (1'b0),
.test13_def  (1'b0),
.test13_y    (),
// test14
.test14_ie   (1'b0),
.test14_oe   (1'b0),
.test14_a    (1'b0),
.test14_def  (1'b0),
.test14_y    (),
// test15
.test15_ie   (1'b0),
.test15_oe   (1'b0),
.test15_a    (1'b0),
.test15_def  (1'b0),
.test15_y    (),
// test16
.test16_ie   (1'b0),
.test16_oe   (1'b0),
.test16_a    (1'b0),
.test16_def  (1'b0),
.test16_y    (),
// test17
.test17_ie   (1'b0),
.test17_oe   (1'b0),
.test17_a    (1'b0),
.test17_def  (1'b0),
.test17_y    (),
// test18
.test18_ie   (1'b0),
.test18_oe   (1'b0),
.test18_a    (1'b0),
.test18_def  (1'b0),
.test18_y    (),
// test19
.test19_ie   (1'b0),
.test19_oe   (1'b0),
.test19_a    (1'b0),
.test19_def  (1'b0),
.test19_y    (),
// test20
.test20_ie   (1'b0),
.test20_oe   (1'b0),
.test20_a    (1'b0),
.test20_def  (1'b0),
.test20_y    (),
// test21
.test21_ie   (1'b0),
.test21_oe   (1'b0),
.test21_a    (1'b0),
.test21_def  (1'b0),
.test21_y    (),
// test22
.test22_ie   (1'b0),
.test22_oe   (1'b0),
.test22_a    (1'b0),
.test22_def  (1'b0),
.test22_y    (),
// test23
.test23_ie   (1'b0),
.test23_oe   (1'b0),
.test23_a    (1'b0),
.test23_def  (1'b0),
.test23_y    (),
// test24
.test24_ie   (1'b0),
.test24_oe   (1'b0),
.test24_a    (1'b0),
.test24_def  (1'b0),
.test24_y    (),
// test25
.test25_ie   (1'b0),
.test25_oe   (1'b0),
.test25_a    (1'b0),
.test25_def  (1'b0),
.test25_y    (),
// test26
.test26_ie   (1'b0),
.test26_oe   (1'b0),
.test26_a    (1'b0),
.test26_def  (1'b0),
.test26_y    (),
// test27
.test27_ie   (1'b0),
.test27_oe   (1'b0),
.test27_a    (1'b0),
.test27_def  (1'b0),
.test27_y    (),
// test28
.test28_ie   (1'b0),
.test28_oe   (1'b0),
.test28_a    (1'b0),
.test28_def  (1'b0),
.test28_y    (),
// test29
.test29_ie   (1'b0),
.test29_oe   (1'b0),
.test29_a    (1'b0),
.test29_def  (1'b0),
.test29_y    (),
// test30
.test30_ie   (1'b0),
.test30_oe   (1'b0),
.test30_a    (1'b0),
.test30_def  (1'b0),
.test30_y    (),
// test31
.test31_ie   (1'b0),
.test31_oe   (1'b0),
.test31_a    (1'b0),
.test31_def  (1'b0),
.test31_y    (),
// with pad interface
.iopad_gpio_y    (i_ens2_IOBUF_Y[16]),
.iopad_gpio_ie   (o_ens2_IOBUF_IE[16]),         
.iopad_gpio_oe   (o_ens2_IOBUF_OE[16]),                                    
.iopad_gpio_a    (o_ens2_IOBUF_A[16])                                     
); 

// GPIO17 pad
// normal: NIRS_LED_ON3/NIRS_IIN_SW0/
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
// test11: None
// test12: None
// test13: None
// test14: None
// test15: None
// test16: None
// test17: None
// test18: None
// test19: None
// test20: None
// test21: None
// test22: None
// test23: None
// test24: None
// test25: None
// test26: None
// test27: None
// test28: None
// test29: None
// test30: None
// test31: None
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
.TEST10_CLKIN(0),
.TEST11_CLKIN(0),
.TEST12_CLKIN(0),
.TEST13_CLKIN(0),
.TEST14_CLKIN(0),
.TEST15_CLKIN(0),
.TEST16_CLKIN(0),
.TEST17_CLKIN(0),
.TEST18_CLKIN(0),
.TEST19_CLKIN(0),
.TEST20_CLKIN(0),
.TEST21_CLKIN(0),
.TEST22_CLKIN(0),
.TEST23_CLKIN(0),
.TEST24_CLKIN(0),
.TEST25_CLKIN(0),
.TEST26_CLKIN(0),
.TEST27_CLKIN(0),
.TEST28_CLKIN(0),
.TEST29_CLKIN(0),
.TEST30_CLKIN(0),
.TEST31_CLKIN(0))
//.TEST10_CLKIN(0))
u_gpio17_pinmux (
// test and alternate select
//.altf_sel   (altf_sel),   
.test_sel   (test_sel),
.test_en    (test_en),
.test0_en   (scan_mode),
.test1_en   (1'b0),
.test2_en   (1'b0), 
.test3_en   (1'b0),
.test4_en   (1'b0),
.test5_en   (1'b0),
.test6_en   (1'b0),
.test7_en   (1'b0),
.test8_en   (1'b0),
.test9_en   (1'b0),
.test10_en   (1'b0),
.test11_en   (1'b0),
.test12_en   (1'b0),
.test13_en   (1'b0),
.test14_en   (1'b0),
.test15_en   (1'b0),
.test16_en   (1'b0),
.test17_en   (1'b0),
.test18_en   (1'b0),
.test19_en   (1'b0),
.test20_en   (1'b0),
.test21_en   (1'b0),
.test22_en   (1'b0),
.test23_en   (1'b0),
.test24_en   (1'b0),
.test25_en   (1'b0),
.test26_en   (1'b0),
.test27_en   (1'b0),
.test28_en   (1'b0),
.test29_en   (1'b0),
.test30_en   (1'b0),
.test31_en   (1'b0),
//.test10_en  (ATM8),
//.test_ana   (1'b0),       //Disable IE/OE/A:: TESTMODE0 GPIO0 serves pure analog signal
// alternate function
.altf_ie   (1'b0),
.altf_oe   (1'b1),
.altf_a    (GPIO17_NORMAL_OUT),
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
.test10_ie   (1'b0),
.test10_oe   (1'b0),
.test10_a    (1'b0),
.test10_def  (1'b0),
.test10_y    (),
// test11
.test11_ie   (1'b0),
.test11_oe   (1'b0),
.test11_a    (1'b0),
.test11_def  (1'b0),
.test11_y    (),
// test12
.test12_ie   (1'b0),
.test12_oe   (1'b0),
.test12_a    (1'b0),
.test12_def  (1'b0),
.test12_y    (),
// test13
.test13_ie   (1'b0),
.test13_oe   (1'b0),
.test13_a    (1'b0),
.test13_def  (1'b0),
.test13_y    (),
// test14
.test14_ie   (1'b0),
.test14_oe   (1'b0),
.test14_a    (1'b0),
.test14_def  (1'b0),
.test14_y    (),
// test15
.test15_ie   (1'b0),
.test15_oe   (1'b0),
.test15_a    (1'b0),
.test15_def  (1'b0),
.test15_y    (),
// test16
.test16_ie   (1'b0),
.test16_oe   (1'b0),
.test16_a    (1'b0),
.test16_def  (1'b0),
.test16_y    (),
// test17
.test17_ie   (1'b0),
.test17_oe   (1'b0),
.test17_a    (1'b0),
.test17_def  (1'b0),
.test17_y    (),
// test18
.test18_ie   (1'b0),
.test18_oe   (1'b0),
.test18_a    (1'b0),
.test18_def  (1'b0),
.test18_y    (),
// test19
.test19_ie   (1'b0),
.test19_oe   (1'b0),
.test19_a    (1'b0),
.test19_def  (1'b0),
.test19_y    (),
// test20
.test20_ie   (1'b0),
.test20_oe   (1'b0),
.test20_a    (1'b0),
.test20_def  (1'b0),
.test20_y    (),
// test21
.test21_ie   (1'b0),
.test21_oe   (1'b0),
.test21_a    (1'b0),
.test21_def  (1'b0),
.test21_y    (),
// test22
.test22_ie   (1'b0),
.test22_oe   (1'b0),
.test22_a    (1'b0),
.test22_def  (1'b0),
.test22_y    (),
// test23
.test23_ie   (1'b0),
.test23_oe   (1'b0),
.test23_a    (1'b0),
.test23_def  (1'b0),
.test23_y    (),
// test24
.test24_ie   (1'b0),
.test24_oe   (1'b0),
.test24_a    (1'b0),
.test24_def  (1'b0),
.test24_y    (),
// test25
.test25_ie   (1'b0),
.test25_oe   (1'b0),
.test25_a    (1'b0),
.test25_def  (1'b0),
.test25_y    (),
// test26
.test26_ie   (1'b0),
.test26_oe   (1'b0),
.test26_a    (1'b0),
.test26_def  (1'b0),
.test26_y    (),
// test27
.test27_ie   (1'b0),
.test27_oe   (1'b0),
.test27_a    (1'b0),
.test27_def  (1'b0),
.test27_y    (),
// test28
.test28_ie   (1'b0),
.test28_oe   (1'b0),
.test28_a    (1'b0),
.test28_def  (1'b0),
.test28_y    (),
// test29
.test29_ie   (1'b0),
.test29_oe   (1'b0),
.test29_a    (1'b0),
.test29_def  (1'b0),
.test29_y    (),
// test30
.test30_ie   (1'b0),
.test30_oe   (1'b0),
.test30_a    (1'b0),
.test30_def  (1'b0),
.test30_y    (),
// test31
.test31_ie   (1'b0),
.test31_oe   (1'b0),
.test31_a    (1'b0),
.test31_def  (1'b0),
.test31_y    (),
// with pad interface
.iopad_gpio_y    (i_ens2_IOBUF_Y[17]),
.iopad_gpio_ie   (o_ens2_IOBUF_IE[17]),         
.iopad_gpio_oe   (o_ens2_IOBUF_OE[17]),                                    
.iopad_gpio_a    (o_ens2_IOBUF_A[17])                                     
); 
// GPIO18 pad
// normal: NIRS_LED_ON4/A2D_IREFCOARSE0 
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
// test11: None
// test12: None
// test13: None
// test14: None
// test15: None
// test16: None
// test17: None
// test18: None
// test19: None
// test20: None
// test21: None
// test22: None
// test23: None
// test24: None
// test25: None
// test26: None
// test27: None
// test28: None
// test29: None
// test30: None
// test31: None

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
.TEST10_CLKIN(0),
.TEST11_CLKIN(0),
.TEST12_CLKIN(0),
.TEST13_CLKIN(0),
.TEST14_CLKIN(0),
.TEST15_CLKIN(0),
.TEST16_CLKIN(0),
.TEST17_CLKIN(0),
.TEST18_CLKIN(0),
.TEST19_CLKIN(0),
.TEST20_CLKIN(0),
.TEST21_CLKIN(0),
.TEST22_CLKIN(0),
.TEST23_CLKIN(0),
.TEST24_CLKIN(0),
.TEST25_CLKIN(0),
.TEST26_CLKIN(0),
.TEST27_CLKIN(0),
.TEST28_CLKIN(0),
.TEST29_CLKIN(0),
.TEST30_CLKIN(0),
.TEST31_CLKIN(0))
//.TEST10_CLKIN(0))
u_gpio18_pinmux (
// test and alternate select
//.altf_sel   (altf_sel),   
.test_sel   (test_sel),
.test_en    (test_en),
.test0_en   (scan_mode),
.test1_en   (1'b0),
.test2_en   (1'b0), 
.test3_en   (1'b0),
.test4_en   (1'b0),
.test5_en   (1'b0),
.test6_en   (1'b0),
.test7_en   (1'b0),
.test8_en   (1'b0),
.test9_en   (1'b0),
.test10_en   (1'b0),
.test11_en   (1'b0),
.test12_en   (1'b0),
.test13_en   (1'b0),
.test14_en   (1'b0),
.test15_en   (1'b0),
.test16_en   (1'b0),
.test17_en   (1'b0),
.test18_en   (1'b0),
.test19_en   (1'b0),
.test20_en   (1'b0),
.test21_en   (1'b0),
.test22_en   (1'b0),
.test23_en   (1'b0),
.test24_en   (1'b0),
.test25_en   (1'b0),
.test26_en   (1'b0),
.test27_en   (1'b0),
.test28_en   (1'b0),
.test29_en   (1'b0),
.test30_en   (1'b0),
.test31_en   (1'b0),
//.test10_en  (ATM8),
//.test_ana   (1'b0),       //Disable IE/OE/A:: TESTMODE0 GPIO0 serves pure analog signal
// alternate function
.altf_ie   (1'b0),
.altf_oe   (1'b1),
.altf_a    (GPIO18_NORMAL_OUT),
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
.test10_ie   (1'b0),
.test10_oe   (1'b0),
.test10_a    (1'b0),
.test10_def  (1'b0),
.test10_y    (),
// test11
.test11_ie   (1'b0),
.test11_oe   (1'b0),
.test11_a    (1'b0),
.test11_def  (1'b0),
.test11_y    (),
// test12
.test12_ie   (1'b0),
.test12_oe   (1'b0),
.test12_a    (1'b0),
.test12_def  (1'b0),
.test12_y    (),
// test13
.test13_ie   (1'b0),
.test13_oe   (1'b0),
.test13_a    (1'b0),
.test13_def  (1'b0),
.test13_y    (),
// test14
.test14_ie   (1'b0),
.test14_oe   (1'b0),
.test14_a    (1'b0),
.test14_def  (1'b0),
.test14_y    (),
// test15
.test15_ie   (1'b0),
.test15_oe   (1'b0),
.test15_a    (1'b0),
.test15_def  (1'b0),
.test15_y    (),
// test16
.test16_ie   (1'b0),
.test16_oe   (1'b0),
.test16_a    (1'b0),
.test16_def  (1'b0),
.test16_y    (),
// test17
.test17_ie   (1'b0),
.test17_oe   (1'b0),
.test17_a    (1'b0),
.test17_def  (1'b0),
.test17_y    (),
// test18
.test18_ie   (1'b0),
.test18_oe   (1'b0),
.test18_a    (1'b0),
.test18_def  (1'b0),
.test18_y    (),
// test19
.test19_ie   (1'b0),
.test19_oe   (1'b0),
.test19_a    (1'b0),
.test19_def  (1'b0),
.test19_y    (),
// test20
.test20_ie   (1'b0),
.test20_oe   (1'b0),
.test20_a    (1'b0),
.test20_def  (1'b0),
.test20_y    (),
// test21
.test21_ie   (1'b0),
.test21_oe   (1'b0),
.test21_a    (1'b0),
.test21_def  (1'b0),
.test21_y    (),
// test22
.test22_ie   (1'b0),
.test22_oe   (1'b0),
.test22_a    (1'b0),
.test22_def  (1'b0),
.test22_y    (),
// test23
.test23_ie   (1'b0),
.test23_oe   (1'b0),
.test23_a    (1'b0),
.test23_def  (1'b0),
.test23_y    (),
// test24
.test24_ie   (1'b0),
.test24_oe   (1'b0),
.test24_a    (1'b0),
.test24_def  (1'b0),
.test24_y    (),
// test25
.test25_ie   (1'b0),
.test25_oe   (1'b0),
.test25_a    (1'b0),
.test25_def  (1'b0),
.test25_y    (),
// test26
.test26_ie   (1'b0),
.test26_oe   (1'b0),
.test26_a    (1'b0),
.test26_def  (1'b0),
.test26_y    (),
// test27
.test27_ie   (1'b0),
.test27_oe   (1'b0),
.test27_a    (1'b0),
.test27_def  (1'b0),
.test27_y    (),
// test28
.test28_ie   (1'b0),
.test28_oe   (1'b0),
.test28_a    (1'b0),
.test28_def  (1'b0),
.test28_y    (),
// test29
.test29_ie   (1'b0),
.test29_oe   (1'b0),
.test29_a    (1'b0),
.test29_def  (1'b0),
.test29_y    (),
// test30
.test30_ie   (1'b0),
.test30_oe   (1'b0),
.test30_a    (1'b0),
.test30_def  (1'b0),
.test30_y    (),
// test31
.test31_ie   (1'b0),
.test31_oe   (1'b0),
.test31_a    (1'b0),
.test31_def  (1'b0),
.test31_y    (),
// with pad interface
.iopad_gpio_y    (i_ens2_IOBUF_Y[18]),
.iopad_gpio_ie   (o_ens2_IOBUF_IE[18]),         
.iopad_gpio_oe   (o_ens2_IOBUF_OE[18]),                                    
.iopad_gpio_a    (o_ens2_IOBUF_A[18])                                     
); 
// GPIO19 pad
// normal: NIRS_LED_ON5/A2D_IREFFINE0 
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
// test11: None
// test12: None
// test13: None
// test14: None
// test15: None
// test16: None
// test17: None
// test18: None
// test19: None
// test20: None
// test21: None
// test22: None
// test23: None
// test24: None
// test25: None
// test26: None
// test27: None
// test28: None
// test29: None
// test30: None
// test31: None

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
.TEST10_CLKIN(0),
.TEST11_CLKIN(0),
.TEST12_CLKIN(0),
.TEST13_CLKIN(0),
.TEST14_CLKIN(0),
.TEST15_CLKIN(0),
.TEST16_CLKIN(0),
.TEST17_CLKIN(0),
.TEST18_CLKIN(0),
.TEST19_CLKIN(0),
.TEST20_CLKIN(0),
.TEST21_CLKIN(0),
.TEST22_CLKIN(0),
.TEST23_CLKIN(0),
.TEST24_CLKIN(0),
.TEST25_CLKIN(0),
.TEST26_CLKIN(0),
.TEST27_CLKIN(0),
.TEST28_CLKIN(0),
.TEST29_CLKIN(0),
.TEST30_CLKIN(0),
.TEST31_CLKIN(0))
//.TEST10_CLKIN(0))
u_gpio19_pinmux (
// test and alternate select
//.altf_sel   (altf_sel),   
.test_sel   (test_sel),
.test_en    (test_en),
.test0_en   (scan_mode),
.test1_en   (1'b0),
.test2_en   (1'b0), 
.test3_en   (1'b0),
.test4_en   (1'b0),
.test5_en   (1'b0),
.test6_en   (1'b0),
.test7_en   (1'b0),
.test8_en   (1'b0),
.test9_en   (1'b0),
.test10_en   (1'b0),
.test11_en   (1'b0),
.test12_en   (1'b0),
.test13_en   (1'b0),
.test14_en   (1'b0),
.test15_en   (1'b0),
.test16_en   (1'b0),
.test17_en   (1'b0),
.test18_en   (1'b0),
.test19_en   (1'b0),
.test20_en   (1'b0),
.test21_en   (1'b0),
.test22_en   (1'b0),
.test23_en   (1'b0),
.test24_en   (1'b0),
.test25_en   (1'b0),
.test26_en   (1'b0),
.test27_en   (1'b0),
.test28_en   (1'b0),
.test29_en   (1'b0),
.test30_en   (1'b0),
.test31_en   (1'b0),
//.test10_en  (ATM8),
//.test_ana   (1'b0),       //Disable IE/OE/A:: TESTMODE0 GPIO0 serves pure analog signal
// alternate function
.altf_ie   (1'b0),
.altf_oe   (1'b1),
.altf_a    (GPIO19_NORMAL_OUT),
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
.test10_ie   (1'b0),
.test10_oe   (1'b0),
.test10_a    (1'b0),
.test10_def  (1'b0),
.test10_y    (),
// test11
.test11_ie   (1'b0),
.test11_oe   (1'b0),
.test11_a    (1'b0),
.test11_def  (1'b0),
.test11_y    (),
// test12
.test12_ie   (1'b0),
.test12_oe   (1'b0),
.test12_a    (1'b0),
.test12_def  (1'b0),
.test12_y    (),
// test13
.test13_ie   (1'b0),
.test13_oe   (1'b0),
.test13_a    (1'b0),
.test13_def  (1'b0),
.test13_y    (),
// test14
.test14_ie   (1'b0),
.test14_oe   (1'b0),
.test14_a    (1'b0),
.test14_def  (1'b0),
.test14_y    (),
// test15
.test15_ie   (1'b0),
.test15_oe   (1'b0),
.test15_a    (1'b0),
.test15_def  (1'b0),
.test15_y    (),
// test16
.test16_ie   (1'b0),
.test16_oe   (1'b0),
.test16_a    (1'b0),
.test16_def  (1'b0),
.test16_y    (),
// test17
.test17_ie   (1'b0),
.test17_oe   (1'b0),
.test17_a    (1'b0),
.test17_def  (1'b0),
.test17_y    (),
// test18
.test18_ie   (1'b0),
.test18_oe   (1'b0),
.test18_a    (1'b0),
.test18_def  (1'b0),
.test18_y    (),
// test19
.test19_ie   (1'b0),
.test19_oe   (1'b0),
.test19_a    (1'b0),
.test19_def  (1'b0),
.test19_y    (),
// test20
.test20_ie   (1'b0),
.test20_oe   (1'b0),
.test20_a    (1'b0),
.test20_def  (1'b0),
.test20_y    (),
// test21
.test21_ie   (1'b0),
.test21_oe   (1'b0),
.test21_a    (1'b0),
.test21_def  (1'b0),
.test21_y    (),
// test22
.test22_ie   (1'b0),
.test22_oe   (1'b0),
.test22_a    (1'b0),
.test22_def  (1'b0),
.test22_y    (),
// test23
.test23_ie   (1'b0),
.test23_oe   (1'b0),
.test23_a    (1'b0),
.test23_def  (1'b0),
.test23_y    (),
// test24
.test24_ie   (1'b0),
.test24_oe   (1'b0),
.test24_a    (1'b0),
.test24_def  (1'b0),
.test24_y    (),
// test25
.test25_ie   (1'b0),
.test25_oe   (1'b0),
.test25_a    (1'b0),
.test25_def  (1'b0),
.test25_y    (),
// test26
.test26_ie   (1'b0),
.test26_oe   (1'b0),
.test26_a    (1'b0),
.test26_def  (1'b0),
.test26_y    (),
// test27
.test27_ie   (1'b0),
.test27_oe   (1'b0),
.test27_a    (1'b0),
.test27_def  (1'b0),
.test27_y    (),
// test28
.test28_ie   (1'b0),
.test28_oe   (1'b0),
.test28_a    (1'b0),
.test28_def  (1'b0),
.test28_y    (),
// test29
.test29_ie   (1'b0),
.test29_oe   (1'b0),
.test29_a    (1'b0),
.test29_def  (1'b0),
.test29_y    (),
// test30
.test30_ie   (1'b0),
.test30_oe   (1'b0),
.test30_a    (1'b0),
.test30_def  (1'b0),
.test30_y    (),
// test31
.test31_ie   (1'b0),
.test31_oe   (1'b0),
.test31_a    (1'b0),
.test31_def  (1'b0),
.test31_y    (),
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
// test11: None
// test12: None
// test13: None
// test14: None
// test15: None
// test16: None
// test17: None
// test18: None
// test19: None
// test20: None
// test21: None
// test22: None
// test23: None
// test24: None
// test25: None
// test26: None
// test27: None
// test28: None
// test29: None
// test30: None
// test31: None
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
.TEST10_CLKIN(0),
.TEST11_CLKIN(0),
.TEST12_CLKIN(0),
.TEST13_CLKIN(0),
.TEST14_CLKIN(0),
.TEST15_CLKIN(0),
.TEST16_CLKIN(0),
.TEST17_CLKIN(0),
.TEST18_CLKIN(0),
.TEST19_CLKIN(0),
.TEST20_CLKIN(0),
.TEST21_CLKIN(0),
.TEST22_CLKIN(0),
.TEST23_CLKIN(0),
.TEST24_CLKIN(0),
.TEST25_CLKIN(0),
.TEST26_CLKIN(0),
.TEST27_CLKIN(0),
.TEST28_CLKIN(0),
.TEST29_CLKIN(0),
.TEST30_CLKIN(0),
.TEST31_CLKIN(0))
//.TEST10_CLKIN(0))
u_gpio20_pinmux (
// test and alternate select
//.altf_sel   (altf_sel),   
.test_sel   (test_sel),
.test_en    (test_en),
.test0_en   (scan_mode),
.test1_en   (1'b0),
.test2_en   (1'b0), 
.test3_en   (1'b0),
.test4_en   (1'b0),
.test5_en   (1'b0),
.test6_en   (1'b0),
.test7_en   (1'b0),
.test8_en   (1'b0),
.test9_en   (1'b0),
.test10_en   (1'b0),
.test11_en   (1'b0),
.test12_en   (1'b0),
.test13_en   (1'b0),
.test14_en   (1'b0),
.test15_en   (1'b0),
.test16_en   (1'b0),
.test17_en   (1'b0),
.test18_en   (1'b0),
.test19_en   (1'b0),
.test20_en   (1'b0),
.test21_en   (1'b0),
.test22_en   (1'b0),
.test23_en   (1'b0),
.test24_en   (1'b0),
.test25_en   (1'b0),
.test26_en   (1'b0),
.test27_en   (1'b0),
.test28_en   (1'b0),
.test29_en   (1'b0),
.test30_en   (1'b0),
.test31_en   (1'b0),
//.test10_en  (ATM8),
//.test_ana   (1'b0),       //Disable IE/OE/A:: TESTMODE0 GPIO0 serves pure analog signal
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
.test10_ie   (1'b0),
.test10_oe   (1'b0),
.test10_a    (1'b0),
.test10_def  (1'b0),
.test10_y    (),
// test11
.test11_ie   (1'b0),
.test11_oe   (1'b0),
.test11_a    (1'b0),
.test11_def  (1'b0),
.test11_y    (),
// test12
.test12_ie   (1'b0),
.test12_oe   (1'b0),
.test12_a    (1'b0),
.test12_def  (1'b0),
.test12_y    (),
// test13
.test13_ie   (1'b0),
.test13_oe   (1'b0),
.test13_a    (1'b0),
.test13_def  (1'b0),
.test13_y    (),
// test14
.test14_ie   (1'b0),
.test14_oe   (1'b0),
.test14_a    (1'b0),
.test14_def  (1'b0),
.test14_y    (),
// test15
.test15_ie   (1'b0),
.test15_oe   (1'b0),
.test15_a    (1'b0),
.test15_def  (1'b0),
.test15_y    (),
// test16
.test16_ie   (1'b0),
.test16_oe   (1'b0),
.test16_a    (1'b0),
.test16_def  (1'b0),
.test16_y    (),
// test17
.test17_ie   (1'b0),
.test17_oe   (1'b0),
.test17_a    (1'b0),
.test17_def  (1'b0),
.test17_y    (),
// test18
.test18_ie   (1'b0),
.test18_oe   (1'b0),
.test18_a    (1'b0),
.test18_def  (1'b0),
.test18_y    (),
// test19
.test19_ie   (1'b0),
.test19_oe   (1'b0),
.test19_a    (1'b0),
.test19_def  (1'b0),
.test19_y    (),
// test20
.test20_ie   (1'b0),
.test20_oe   (1'b0),
.test20_a    (1'b0),
.test20_def  (1'b0),
.test20_y    (),
// test21
.test21_ie   (1'b0),
.test21_oe   (1'b0),
.test21_a    (1'b0),
.test21_def  (1'b0),
.test21_y    (),
// test22
.test22_ie   (1'b0),
.test22_oe   (1'b0),
.test22_a    (1'b0),
.test22_def  (1'b0),
.test22_y    (),
// test23
.test23_ie   (1'b0),
.test23_oe   (1'b0),
.test23_a    (1'b0),
.test23_def  (1'b0),
.test23_y    (),
// test24
.test24_ie   (1'b0),
.test24_oe   (1'b0),
.test24_a    (1'b0),
.test24_def  (1'b0),
.test24_y    (),
// test25
.test25_ie   (1'b0),
.test25_oe   (1'b0),
.test25_a    (1'b0),
.test25_def  (1'b0),
.test25_y    (),
// test26
.test26_ie   (1'b0),
.test26_oe   (1'b0),
.test26_a    (1'b0),
.test26_def  (1'b0),
.test26_y    (),
// test27
.test27_ie   (1'b0),
.test27_oe   (1'b0),
.test27_a    (1'b0),
.test27_def  (1'b0),
.test27_y    (),
// test28
.test28_ie   (1'b0),
.test28_oe   (1'b0),
.test28_a    (1'b0),
.test28_def  (1'b0),
.test28_y    (),
// test29
.test29_ie   (1'b0),
.test29_oe   (1'b0),
.test29_a    (1'b0),
.test29_def  (1'b0),
.test29_y    (),
// test30
.test30_ie   (1'b0),
.test30_oe   (1'b0),
.test30_a    (1'b0),
.test30_def  (1'b0),
.test30_y    (),
// test31
.test31_ie   (1'b0),
.test31_oe   (1'b0),
.test31_a    (1'b0),
.test31_def  (1'b0),
.test31_y    (),
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
// test11: None
// test12: None
// test13: None
// test14: None
// test15: None
// test16: None
// test17: None
// test18: None
// test19: None
// test20: None
// test21: None
// test22: None
// test23: None
// test24: None
// test25: None
// test26: None
// test27: None
// test28: None
// test29: None
// test30: None
// test31: None

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
.TEST10_CLKIN(0),
.TEST11_CLKIN(0),
.TEST12_CLKIN(0),
.TEST13_CLKIN(0),
.TEST14_CLKIN(0),
.TEST15_CLKIN(0),
.TEST16_CLKIN(0),
.TEST17_CLKIN(0),
.TEST18_CLKIN(0),
.TEST19_CLKIN(0),
.TEST20_CLKIN(0),
.TEST21_CLKIN(0),
.TEST22_CLKIN(0),
.TEST23_CLKIN(0),
.TEST24_CLKIN(0),
.TEST25_CLKIN(0),
.TEST26_CLKIN(0),
.TEST27_CLKIN(0),
.TEST28_CLKIN(0),
.TEST29_CLKIN(0),
.TEST30_CLKIN(0),
.TEST31_CLKIN(0))
//.TEST10_CLKIN(0))
u_gpio21_pinmux (
// test and alternate select
//.altf_sel   (altf_sel),   
.test_sel   (test_sel),
.test_en    (test_en),
.test0_en   (scan_mode),
.test1_en   (1'b0),
.test2_en   (1'b0), 
.test3_en   (1'b0),
.test4_en   (1'b0),
.test5_en   (1'b0),
.test6_en   (1'b0),
.test7_en   (1'b0),
.test8_en   (1'b0),
.test9_en   (1'b0),
.test10_en   (1'b0),
.test11_en   (1'b0),
.test12_en   (1'b0),
.test13_en   (1'b0),
.test14_en   (1'b0),
.test15_en   (1'b0),
.test16_en   (1'b0),
.test17_en   (1'b0),
.test18_en   (1'b0),
.test19_en   (1'b0),
.test20_en   (1'b0),
.test21_en   (1'b0),
.test22_en   (1'b0),
.test23_en   (1'b0),
.test24_en   (1'b0),
.test25_en   (1'b0),
.test26_en   (1'b0),
.test27_en   (1'b0),
.test28_en   (1'b0),
.test29_en   (1'b0),
.test30_en   (1'b0),
.test31_en   (1'b0),
//.test10_en  (ATM8),
//.test_ana   (1'b0),       //Disable IE/OE/A:: TESTMODE0 GPIO0 serves pure analog signal
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
.test10_ie   (1'b0),
.test10_oe   (1'b0),
.test10_a    (1'b0),
.test10_def  (1'b0),
.test10_y    (),
// test11
.test11_ie   (1'b0),
.test11_oe   (1'b0),
.test11_a    (1'b0),
.test11_def  (1'b0),
.test11_y    (),
// test12
.test12_ie   (1'b0),
.test12_oe   (1'b0),
.test12_a    (1'b0),
.test12_def  (1'b0),
.test12_y    (),
// test13
.test13_ie   (1'b0),
.test13_oe   (1'b0),
.test13_a    (1'b0),
.test13_def  (1'b0),
.test13_y    (),
// test14
.test14_ie   (1'b0),
.test14_oe   (1'b0),
.test14_a    (1'b0),
.test14_def  (1'b0),
.test14_y    (),
// test15
.test15_ie   (1'b0),
.test15_oe   (1'b0),
.test15_a    (1'b0),
.test15_def  (1'b0),
.test15_y    (),
// test16
.test16_ie   (1'b0),
.test16_oe   (1'b0),
.test16_a    (1'b0),
.test16_def  (1'b0),
.test16_y    (),
// test17
.test17_ie   (1'b0),
.test17_oe   (1'b0),
.test17_a    (1'b0),
.test17_def  (1'b0),
.test17_y    (),
// test18
.test18_ie   (1'b0),
.test18_oe   (1'b0),
.test18_a    (1'b0),
.test18_def  (1'b0),
.test18_y    (),
// test19
.test19_ie   (1'b0),
.test19_oe   (1'b0),
.test19_a    (1'b0),
.test19_def  (1'b0),
.test19_y    (),
// test20
.test20_ie   (1'b0),
.test20_oe   (1'b0),
.test20_a    (1'b0),
.test20_def  (1'b0),
.test20_y    (),
// test21
.test21_ie   (1'b0),
.test21_oe   (1'b0),
.test21_a    (1'b0),
.test21_def  (1'b0),
.test21_y    (),
// test22
.test22_ie   (1'b0),
.test22_oe   (1'b0),
.test22_a    (1'b0),
.test22_def  (1'b0),
.test22_y    (),
// test23
.test23_ie   (1'b0),
.test23_oe   (1'b0),
.test23_a    (1'b0),
.test23_def  (1'b0),
.test23_y    (),
// test24
.test24_ie   (1'b0),
.test24_oe   (1'b0),
.test24_a    (1'b0),
.test24_def  (1'b0),
.test24_y    (),
// test25
.test25_ie   (1'b0),
.test25_oe   (1'b0),
.test25_a    (1'b0),
.test25_def  (1'b0),
.test25_y    (),
// test26
.test26_ie   (1'b0),
.test26_oe   (1'b0),
.test26_a    (1'b0),
.test26_def  (1'b0),
.test26_y    (),
// test27
.test27_ie   (1'b0),
.test27_oe   (1'b0),
.test27_a    (1'b0),
.test27_def  (1'b0),
.test27_y    (),
// test28
.test28_ie   (1'b0),
.test28_oe   (1'b0),
.test28_a    (1'b0),
.test28_def  (1'b0),
.test28_y    (),
// test29
.test29_ie   (1'b0),
.test29_oe   (1'b0),
.test29_a    (1'b0),
.test29_def  (1'b0),
.test29_y    (),
// test30
.test30_ie   (1'b0),
.test30_oe   (1'b0),
.test30_a    (1'b0),
.test30_def  (1'b0),
.test30_y    (),
// test31
.test31_ie   (1'b0),
.test31_oe   (1'b0),
.test31_a    (1'b0),
.test31_def  (1'b0),
.test31_y    (),
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
