//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap ENS2  
// File name:    top_dig.v 
// Module Name : ENS2 DIG TOP
// Description : 
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author          Description      
//------------------------------------------------------------------------------
// 0.1                                      Initial Rev 
//------------------------------------------------------------------------------

`timescale 1 ns /  1ps

module top_dig #( 
  parameter EEG_DATA_WIDTH  = 24, 
  parameter EEG_CHN_NUM     = 16, 
  parameter HLF_WV_NO_PTS   = 7, 
  parameter OUT_NO_BITS     = 12,
  parameter NO_OF_WAVEGEN   = 16,
  parameter NO_OF_NIRS      = 8,
  parameter TRIM_NUMBER     = 15,
  parameter EN_SEC_NUMBER   = 2,
  parameter EN_REG_NUMBER   = 15
)
( 

//tempory connected out for verification
//=====================
input [9:0] A2D_ADC_DATA, //from analog //ADC use posedge of sysclk to output data, 
		//digital use negedge to capture, so we have half sysclk cycle margin for it	
input  A2D_ADC_DATA_EN,//from analog	
output[3:0] D2A_STIM_PAD0,    //to analog	
output[3:0] D2A_STIM_PAD1,    //to analog	
output wire D2A_ADC_EN,    //to analog	
output wire D2A_ADC_CLK,    //to analog	
output wire ina_pga_ana_clk,    //to analog	
//=====================

//bps imeas
input  A2D_SDM_OUT0,
input  A2D_SDM_OUT1,
input  A2D_SDM_OUT2,
input  A2D_SDM_OUT3,
input  A2D_SDM_OUT4,
input  A2D_SDM_OUT5,
input  A2D_SDM_OUT6,
input  A2D_SDM_OUT7,
input  A2D_SDM_OUT8,
input  A2D_SDM_OUT9,
input  A2D_SDM_OUT10,
input  A2D_SDM_OUT11,
input  A2D_SDM_OUT12,
input  A2D_SDM_OUT13,
input  A2D_SDM_OUT14,
input  A2D_SDM_OUT15,

output D2A_SDM_CLK,
//===================
  //lead_off
//input wire A2D_COMP1,   
//input wire A2D_COMP2,   
//input   wire        A2D_COMP_OUT_STIMU0,
//input   wire        A2D_COMP_OUT_STIMU1,
//input   wire        A2D_COMP_OUT_STIMU2,
//input   wire        A2D_COMP_OUT_STIMU3,

  //-------------------------
  //input wire          iopad_cpha,
  //input wire          iopad_cpol, 
  // with OSC
  //input  wire         hfosc,            // osc base clock input
  input  wire           A2D_OSC_OUT,      // osc base clock input
  //input  wire         ext_clk_sel,      //from analog IO cells
  //input  wire         ext_hfclk,        //external clock from analog IO cells
  input  wire           CLKSEL_Y,         //from analog IO cells
  //input  wire         external_clock,   //external clock from analog IO cells with PMU
  //input  wire         por_resetn,       // power on reset, low active
  input  wire           A2D_SW_POWER_POR, // power on reset, low active

  // To/From always on
  output wire           scan_clk,
  output wire           scan_rst_n,
  output wire           atpg_en,
//output wire           poresetn_hf,      //from switchable digital POR time out //global reset after sync by hfclk
//output wire           spi_write,        //from spi
//output wire [2:0]     o_dc_clk_div_spi, 
//input wire  [2:0]   dc_clk_div_always_on, 
//input wire  [2:0]     D2A_CPCLK, 

  //io_buf_config
  output wire [21:0]    o_ens2_IOBUF_CS,
  output wire [21:0]    o_ens2_IOBUF_SR,
  output wire [21:0]    o_ens2_IOBUF_IE,
  output wire [21:0]    o_ens2_IOBUF_OE,
  output wire [21:0]    o_ens2_IOBUF_PU,
  output wire [21:0]    o_ens2_IOBUF_PD,
  output wire [21:0]    o_ens2_IOBUF_A,
  output wire [21:0]    o_ens2_IOBUF_PDRV0,
  output wire [21:0]    o_ens2_IOBUF_PDRV1,
  input  wire [21:0]    i_ens2_IOBUF_Y,

  output wire           o_IO_clksel_PD,
  output wire           o_IO_exresetn_PD,
  output wire           o_IO_testmode0_PD,
  output wire           o_IO_testmode1_PD,

  output wire           o_IO_clksel_PU,
  output wire           o_IO_exresetn_PU,
  output wire           o_IO_testmode0_PU,
  output wire           o_IO_testmode1_PU,

  input  wire           iopad_testmode0_en_y,
  input  wire           iopad_testmode1_en_y,
  input  wire           iopad_resetn_y,

  //trim
//output wire           otp_Reset_Done,
//output wire [4:0]     otp_to_ana_bgh_vtrim,  
//output wire [6:0]     otp_to_ana_bgh_ctrl,   
//output wire [4:0]     otp_to_ana_bgl_vtrim,  
//output wire [6:0]     otp_to_ana_bgl_ctrl,   
//output wire [1:0]     otp_to_ana_ldo1v5_trim,
//output wire [1:0]     otp_to_ana_dacbuf_trim,
//output wire [5:0]     otp_to_ana_osc_trim,
//input   wire        CHIP_otp_VREF,
//input  wire           VREF0P8,

  // power ground
//inout  wire           vdd_switchable, //switchable digital power
//inout  wire           vssi,
  inout  wire           VPP_OTP,                // VPP
//input  wire           AVDD_OTP,               // AVDD
  inout  wire           VDD_OTP,                // VDD_DIG
  inout  wire           VSUB_OTP,               // FROM ANALOG (MISSING)
  inout  wire           VSS_OTP,                // VSS_DIG
//output wire           D2ASW_EEPROM_VDD2_EN,   // VDD2_EN - from EEPROM 

//output wire           CLK_EN,

  //analog register outputs
  //ana_pmu
//output wire           o_BG_BUF_EN,
//output wire           o_DAC_BUF_EN,

  //ana_tsc
//output wire           D2A_TSC_EN,
//output wire           D2A_TSC_AMP_EN,
//output wire [2:0]     D2A_TSC_BJT_SEL,
//output wire [2:0]     D2A_TSC_GSEL,
//output wire           D2A_TSC_OUT_SEL,

  //ana i-meas ch1
//output wire           o_CH1_WE1_EN,
//output wire           o_CH1_WE1_DDA_EN,
//output wire  [3:0]    o_CH1_WE1_RFB_SEL,
//output wire  [2:0]    o_CH1_WE1_ROUT_SEL,
//output wire  [2:0]    o_CH1_WE1_VGAIN_SEL,

//output wire           o_CH1_WE2_EN,
//output wire           o_CH1_WE2_DDA_EN,
//output wire  [3:0]    o_CH1_WE2_RFB_SEL,
//output wire  [2:0]    o_CH1_WE2_ROUT_SEL,
//output wire  [2:0]    o_CH1_WE2_VGAIN_SEL,

//output wire           o_CH1_RCE_EN,
//output wire  [2:0]    o_CH1_CE_ROUT_SEL,

//output wire           o_CH1_WE_DAC_EN,
//output wire  [9:0]    o_CH1_DINWE,
//output wire           o_CH1_RCE_DAC_EN,
//output wire  [9:0]    o_CH1_DINRCE,

  //Peripheral
//output wire           o_BIST_EN,
//output wire  [2:0]    o_BIST_ISEL,
//output wire           o_DDA_EN,
//output wire  [2:0]    o_DDA_GSEL,
//output wire           D2A_PGA_EN,
//output wire  [2:0]    D2A_PGA_VIN_SEL,
//output wire  [1:0]    D2A_PGA_GSEL,
//output wire           o_ELE_BUF_EN,
//output wire  [2:0]    o_ELE_BUF_ISEL,


  pinmux_if.D2A         pinmux_if,
  spi_ana_if.spi        spi_ana_if,
  ana_nirs_if.nirs      ana_nirs_if,

  //WG
  output wire  [11:0]    o_out_wave_driver_idac[NO_OF_WAVEGEN-1:0],
  output wire [NO_OF_WAVEGEN-1:0]	o_ds_driver_en_driver,
  output wire 				o_ds_driver_en_current,
  output wire [NO_OF_WAVEGEN-1:0]       o_driver_en_sw,
  output wire 				o_stimu_en,            

  output wire              [NO_OF_WAVEGEN-1:0]    o_source_driver,
//output wire              [NO_OF_WAVEGEN-1:0]    o_sourceb_driver_a,
  output wire              [NO_OF_WAVEGEN-1:0]    o_pulldn_driver
//output wire              [NO_OF_WAVEGEN-1:0]    o_pulldb_driver_a
//output wire              [1:0]    o_driver_driver_a_en
//output wire              [2:0]    o_drivera_isel0,
//output wire              [2:0]    o_drivera_isel1
);

//  spi_leadoff      #(.NO_OF_WAVEGEN(NO_OF_WAVEGEN))  spi_leadoff();
spi_anac      #(.NO_OF_WAVEGEN(NO_OF_WAVEGEN))  spi_anac();
spi_otp       #(.TRIM_NUMBER  (TRIM_NUMBER+2))  spi_otp();
spi_wg        #(.NO_OF_WAVEGEN(NO_OF_WAVEGEN))  spi_wg();
spi_pinmux_if #(.EN_SEC_NUMBER(EN_SEC_NUMBER),
                .EN_REG_NUMBER(EN_REG_NUMBER))  spi_pinmux_if(); 
spi_nirs_if   #(.NO_OF_NIRS(NO_OF_NIRS))        spi_nirs_if();

//bps imeas
wire [EEG_DATA_WIDTH-1:0]  imeas_chdata_adcclk[EEG_CHN_NUM-1:0];
wire [EEG_CHN_NUM-1:0]  chdata_en_adcclk;

wire [EEG_DATA_WIDTH-1:0]  imeas_chdata[EEG_CHN_NUM-1:0];
wire [EEG_DATA_WIDTH-1:0]  imeas_chdata_filter[EEG_CHN_NUM-1:0];
wire [EEG_CHN_NUM-1:0]  chdata_en;
wire [EEG_CHN_NUM-1:0]  notch_filter_bypass;
wire [EEG_CHN_NUM-1:0]  lpf_filter_bypass;
wire [EEG_CHN_NUM-1:0]  hpf_filter_bypass;
//wire [2:0]              filter_seq;
wire                    meas_done_filter;
wire [1:0]              eeg_int_en;
wire                    eeg_int_clr;
wire                    o_eeg_int;
wire                    eeg_int_sts;
wire [15:0]             cic_data_ignore_tar;
wire [23:0]             hpf_coeff_data;
wire [17:0]             lpf_coeff_data [27:0];
wire [19:0]             notch_coeff_data[23:0];
wire                    o_nirs_int;

wire stim_global_en;
wire stim_eeg_sync_en;
wire[23:0] filter_dly_tgt;

//============
wire    hfosc_out;
wire    analog_test_mode;
wire    ext_clk_sel;                                                //from analog IO cells
//wire    ext_clk;                                                    // 08/04/2023 supriya: pending to cross check with Xin
wire    ext_hfclk;                                                  //external clock from analog IO cells
//assign  ext_clk_sel = analog_test_mode ? 1'b1     : ~CLKSEL_Y;      //from analog IO cells
//assign  ext_hfclk   = external_clock;                               //external clock from analog IO cells
//assign  ext_hfclk   = analog_test_mode ? CLKSEL_Y : ext_clk ;       // FROM GPIO0

wire    hfosc;                            // osc base clock input
assign  hfosc = A2D_OSC_OUT;              // osc base clock input

wire    por_resetn;                       // power on reset, low active
assign  por_resetn = A2D_SW_POWER_POR;    // power on reset, low active

//wire    CHIP_otp_VREF;
//assign  CHIP_otp_VREF = VREF0P8;

//wire        o_PGA_EN;
//wire  [2:0] o_PGA_VIN_SEL;
//wire  [1:0] o_PGA_GSEL;
//assign D2A_PGA_EN       = o_PGA_EN;
//assign D2A_PGA_VIN_SEL  = o_PGA_VIN_SEL;
//assign D2A_PGA_GSEL     = o_PGA_GSEL;

//wire        o_TSC_EN;
//wire        o_TSC_AMP_EN;
//wire  [2:0] o_TSC_BJT_SEL;
//wire  [2:0] o_TSC_GSEL;
//wire        o_TSC_OUT_SEL;
//assign      D2A_TSC_EN       = o_TSC_EN;
//assign      D2A_TSC_AMP_EN   = o_TSC_AMP_EN;
//assign      D2A_TSC_BJT_SEL  = o_TSC_BJT_SEL;
//assign      D2A_TSC_GSEL     = o_TSC_GSEL;
//assign      D2A_TSC_OUT_SEL  = o_TSC_OUT_SEL;

//wire  [2:0] dc_clk_div_always_on; 
//assign      dc_clk_div_always_on = D2A_CPCLK;

  //wire  [1:0]  A2D_TRIM0_SIG;
  //wire  [1:0]  A2D_TRIM1_SIG;
  //wire  [1:0]  A2D_TRIM2_SIG;
  //wire  [1:0]  A2D_TRIM3_SIG;
  //wire  [1:0]  A2D_TRIM4_SIG;
  //wire  [1:0]  A2D_TRIM5_SIG;
  //wire  [1:0]  A2D_TRIM6_SIG;
  //wire  [1:0]  A2D_TRIM7_SIG;
  //wire  [1:0]  A2D_TRIM8_SIG;

  //wire         ATM0;  
  //wire         ATM1;
  //wire         ATM2;
  //wire         ATM3;
  //wire         ATM4;
  //wire         ATM5;
  //wire         ATM6;
  //wire         ATM7;
  //wire         ATM8;

  //wire  [7:0]  D2A_TRIM0_SIG;
  //wire  [7:0]  D2A_TRIM1_SIG;
  //wire  [7:0]  D2A_TRIM2_SIG;
  //wire  [7:0]  D2A_TRIM3_SIG;
  //wire  [7:0]  D2A_TRIM4_SIG;
  //wire  [7:0]  D2A_TRIM5_SIG;
  //wire  [7:0]  D2A_TRIM6_SIG;
  //wire  [7:0]  D2A_TRIM7_SIG;
  //wire  [7:0]  D2A_TRIM8_SIG;

  //assign       A2D_TRIM0_SIG   = pinmux_if.A2D_TRIM0_SIG; 
  //assign       A2D_TRIM1_SIG   = pinmux_if.A2D_TRIM1_SIG; 
  //assign       A2D_TRIM2_SIG   = pinmux_if.A2D_TRIM2_SIG; 
  //assign       A2D_TRIM3_SIG   = pinmux_if.A2D_TRIM3_SIG; 
  //assign       A2D_TRIM4_SIG   = pinmux_if.A2D_TRIM4_SIG; 
  //assign       A2D_TRIM5_SIG   = pinmux_if.A2D_TRIM5_SIG; 
  //assign       A2D_TRIM6_SIG   = pinmux_if.A2D_TRIM6_SIG; 
  //assign       A2D_TRIM7_SIG   = pinmux_if.A2D_TRIM7_SIG; 
  //assign       A2D_TRIM8_SIG   = pinmux_if.A2D_TRIM8_SIG; 


  //assign       pinmux_if.D2A_ATM0        = ATM0;  
  //assign       pinmux_if.D2A_ATM1        = ATM1;
  //assign       pinmux_if.D2A_ATM2        = ATM2;
  //assign       pinmux_if.D2A_ATM3        = ATM3;
  //assign       pinmux_if.D2A_ATM4        = ATM4;
  //assign       pinmux_if.D2A_ATM5        = ATM5;
  //assign       pinmux_if.D2A_ATM6        = ATM6;
  //assign       pinmux_if.D2A_ATM7        = ATM7;
  //assign       pinmux_if.D2A_ATM8        = ATM8;

  //assign       pinmux_if.D2A_TRIM0_SIG = D2A_TRIM0_SIG;
  //assign       pinmux_if.D2A_TRIM1_SIG = D2A_TRIM1_SIG;
  //assign       pinmux_if.D2A_TRIM2_SIG = D2A_TRIM2_SIG;
  //assign       pinmux_if.D2A_TRIM3_SIG = D2A_TRIM3_SIG;
  //assign       pinmux_if.D2A_TRIM4_SIG = D2A_TRIM4_SIG;
  //assign       pinmux_if.D2A_TRIM5_SIG = D2A_TRIM5_SIG;
  //assign       pinmux_if.D2A_TRIM6_SIG = D2A_TRIM6_SIG;
  //assign       pinmux_if.D2A_TRIM7_SIG = D2A_TRIM7_SIG;
  //assign       pinmux_if.D2A_TRIM8_SIG = D2A_TRIM8_SIG;

  wire  [14:0] atm_mode;
  wire  [7:0] atm_data;
  wire  [7:0] atm_adj_data;
  wire        unlock_gpio;
  wire        atm_adj;
  wire [14:0] atm_adj_mode;

//  wire         atpg_en;
//wire         atpg_en_sw;      //16/04/2024 commented by supriya
//assign atpg_en = atpg_en_sw;  //16/04/2024 commented by supriya

// wire [OUT_NO_BITS-1:0]  o_out_wave_drivera_dac0;
// wire [OUT_NO_BITS-1:0]  o_out_wave_drivera_dac1;

  wire                    o_clk_sel;
  wire                    otp_rst_reg;
  wire                    dig_rst_reg;


   wire[31:0] lead_off_Counter_cnt_dac0_final_dbg;
   wire[31:0] lead_off_Counter_cnt_dac1_final_dbg;

//ppg
wire         ppg_dis;           //ppg disble 
wire  [1:0]  ppg_clk_div;       // ppg clock divider
wire         ana_ppgclk_inv_config;   // ana ppg clock setting 
wire         ppg_clk50duty;            
wire         ppg_rst_reg;
wire         ppg_clk_gate_bypass;

 wire 	    ppg_clk_running;
 wire        clk_ppg;           //digital ppg clock 
 wire        clk_sys_ppg;           //sys ppg  clock
 wire        ana_clk_ppg;           //analog ppg clock  

 wire        ppg_resetn;

//-------------------------------------
// lead off function
//-------------------------------------
   //wire[7:0] lead_off_cnt_dac0_dbg;
   //wire[7:0] lead_off_cnt_dac1_dbg;
   //wire[7:0] lead_off_Counter_cnt_dac0_dbg;
   //wire[7:0] lead_off_Counter_cnt_dac1_dbg;

  //wire                    lead_off_rst;
  //wire                    lead_off_en;
  //wire                    dly_en;
//  wire [OUT_NO_BITS-1:0]  TH_H;
//  wire [OUT_NO_BITS-1:0]  TH_L;
  //wire            [31:0]  measure_dly_tgt;
  //wire            [31:0]  measure_dly_tgt1;

  wire [31:0] timer_cnt_tgt          ;
  wire [31:0] timer_cnt_tgt1         ;
  wire [31:0] counter_th_tgt        ;
  wire [31:0] counter_th_tgt1       ;

  //wire             [7:0]  lead_off_tgt;
  //wire             [31:0]  lead_off_level_tgt;
  //wire             [1:0]  check_mode;         //00 is h/l both, 01 is high only, 10 is low only, 11 is h/l both
  wire                    lead_off_sts_clear;   
  wire                    lead_off1_sts_clear;   
  wire             [1:0]  dac_en;            //bit0=1 is dac0, , bit1=1 is dac1 
  //wire                    comp_reverse;
//wire                    A2D_COMP;   
  //wire                    lead_off_int_en;
  //wire                    lead_off_result;   
  wire[1:0]                    lead_off_int_en;
  wire                    lead_off_result;   
  wire                    lead_off_result1;   
  wire                    lead_off_int;   
   wire   lead_off_stop;
   wire   lead_off_stop1;
  wire   lead_off_stop_en;
  wire   lead_off_stop1_en;
  wire                    comp_low_ch0;
  wire                    comp_low_ch1;

//---------------------------------
  wire        cs_n, miso, mosi,miso1 , mosi1, dual_en, dual_wr, sclk;
  wire        hfosc_atpg;       // hfosc after atpg mux
  //wire        fclk;             // hf free-running clock

//otp bist
  wire        otp_bist_resetn;    // otp bist reset
  wire        otp_bist_en;        // otp bist enable
  wire        otp_bist_tck;       // otp bist TCK
  wire        otp_bist_tck_atpg;  // otp bist TCK after atpg mux
  wire        otp_bist_tdi;
  wire        otp_bist_oen;
  wire        otp_bist_tdo;
  wire        otp_bist_strobe;
  wire        otp_bist_tdo_serout;
//wire        otp_bist_wbusy;
  wire        bist_vpp_en;
  wire        otp_vpp_en;
// EEPROM

/*
  wire [11:0] Config_reg_from_otp;
  wire [15:0] EEPROM1_reg_from_otp;  
  wire [15:0] EEPROM2_reg_from_otp;  
  wire [15:0] EEPROM3_reg_from_otp;  
  wire  [7:0] clk_ctrl_reg_from_otp;
  wire  [1:0] por_cnt_sel_from_otp;

  wire [15:0] Config_reg_to_otp;   
  wire [15:0] EEPROM1_reg_to_otp;  
  wire [15:0] EEPROM2_reg_to_otp;  
  wire [15:0] EEPROM3_reg_to_otp; 
  wire  [7:0] clk_ctrl_reg_to_otp; 
  wire  [1:0] por_cnt_sel_to_otp;
*/



// EEPROM PREPARE TO SLEEP
/*
  wire        rst_ctrl_otp_vdd2_enable;
//  reg         prep_to_slp =   1'b0;
  wire        prep_to_slp_delay1clk;
  wire        prep_to_slp_delay2clk;
  wire        prep_to_slp_sync;
 */ 
  wire        otp_rstn;
  
  wire        trim_tag_en;
  wire        trim1_en;
  wire        trim2_en;
  wire        trim3_en;
  wire        trim4_en;
  wire        trim5_en;
  wire        trim6_en;
  
  wire        VDD;
  wire        VSUB;
//wire        VSS_OTP;
  
  wire  [7:0] analog_trim_flg;
  wire  [4:0] ana_bgh_vtrim  ;
  wire  [6:0] ana_bgh_ctrl   ;
  wire  [4:0] ana_bgl_vtrim  ;
  wire  [6:0] ana_bgl_ctrl   ;
  wire  [1:0] ana_ldo1v5_trim;
  wire  [1:0] ana_dacbuf_trim;
  wire  [5:0] ana_osc_trim   ;
//  wire        otp_unlock     ;
//  wire        otp_spi_wr     ;
  wire        wr_done_flg    ;
  
  wire        otp_BUSY;
  
  wire [15:0] DEBUG_otp; 
  wire [15:0] debug_reg;
  wire        scan_en;
  wire [8:0]  scan_in;
  wire [8:0]  scan_out;
  wire        scan_compression_in;
  
  wire        pmu_fclk_en;      // sclk enable when in idle state
  //wire        otp_por_resetn;   // otp por reset
  wire        presetn;
  wire        wave_gen_presetn;
  wire        poresetn;
  wire        ext_resetn;
  //wire        fclk_dynen;

//wire  [1:0] pclk_div;
  wire  [2:0] pclk_div;
  wire        pclk;
  wire        otp_pclk;
  wire anac_pclk;
  wire temp_sar_pclk;
  wire        hresetreq;
  wire        otp_bist_resetn_atpg;
  wire        pmuenable;
  wire        sleepdeep;    // to pmu

  wire        otp_dpstb_en;
  wire        anac_clock_en;
  wire        temp_sar_clock_dis;
  wire        anac_reset;
  wire [7:0]  en_reg_sel;
  wire [7:0]  tsc_vdac8b_din_ch1;
  wire        tsc_comp_low_ch1;
  wire        tsc_vdac8b_en_ch1;
  wire        tsc_en_ch1;
  wire        tsc_comp_en_ch1;
  wire [7:0]  d2a_tsc_vdac8b_din_ch1;
  wire        d2a_tsc_vdac8b_en_ch1;
  wire        d2a_tsc_en_ch1;
  wire        d2a_tsc_comp_en_ch1;
  wire [7:0] sample_duration;
  wire [11:0] stable_duration;
  wire busy_doing;
  wire [7:0]         VDAC_NOR;
  wire        temp_sar_reset;
  //wire        otp_dpstb;

  wire        int_alarm_en;
  wire [15:0] threshold_hi;
  wire [15:0] threshold_lo;
  
  wire  [2:0] PGA_VIN_SEL;
  wire  [1:0] PGA_GSEL;
  wire  [2:0] DDA_GSEL;
  wire  [2:0] CH1_WE1_VGAIN_SEL;
  wire  [2:0] CH1_WE2_VGAIN_SEL;
  wire  [2:0] CH2_WE1_VGAIN_SEL;
  wire  [2:0] CH2_WE2_VGAIN_SEL;
  wire        CH1_WE1_DDA_EN;
  wire        CH1_WE2_DDA_EN;
  wire        CH2_WE1_DDA_EN;
  wire        CH2_WE2_DDA_EN;
  
  
  wire  [7:0] comp0_ctrl_reg;  
  wire  [6:0] comp1_ctrl_reg;     
  wire  [6:0] pga_ctrl0_reg;      
  wire  [5:0] pga_ctrl1_reg;      
  wire  [4:0] charge_ctrl0_reg;  
  wire  [2:0] charge_ctrl1_reg;  
  wire  [5:0] pmu_ctrl_reg; 
  wire  [6:0] boost_ctrl0_reg;   
  wire  [6:0] boost_ctrl1_reg;    
  wire  [7:0] boost_ctrl2_reg;    
  wire  [6:0] ana_bist0_reg;   
  wire  [7:0] ana_bist1_reg;     
  
  wire  [7:0] gpio_pu_ctrl_reg;                  
  wire  [7:0] gpio_pd_ctrl_reg;            
  wire  [2:0] gpio_sr_pdrv0_1_ctrl_reg;    
  wire        gpio_nirs_out_ctrl_reg;   
  wire        gpio_normal_out_ctrl_reg;   

/*
 wire		w_D2A_LVD_EN;
 wire 		w_D2A_CLDO2P4_EN;
 wire [4:0]	w_D2A_LVD_TRIM;
 wire 		w_D2A_OSC2MHZEN;
 wire 		w_D2A_SC_DOUBLER_EN;
 wire 		w_D2A_DRIVERA_AMP_EN_CH1;
 wire		w_D2A_DRIVERA_SOURCEA_CH1;
 wire		w_D2A_DRIVERA_SOURCEB_CH1;
 wire		w_D2A_DRIVERA_PULLDA_CH1;
 wire 		w_D2A_DRIVERA_PULLDB_CH1;
 wire [4:0]	w_D2A_DRIVERA_CS_RTRIM_CH1;
 wire		w_D2A_COMP_EN_CH1;
 wire		w_D2A_IDAC_EN_CH1;
 wire [11:0]	w_D2A_IDAC_DIN_CH1;
 wire 		w_D2A_VDAC_EN_CH1;
 wire [11:0]	w_D2A_VDAC_DIN_CH1;
 wire 		w_D2A_DRIVERA_AMP_EN_CH2;
 wire 		w_D2A_DRIVERA_SOURCEA_CH2;
 wire 		w_D2A_DRIVERA_SOURCEB_CH2;
 wire		w_D2A_DRIVERA_PULLDA_CH2;
 wire		w_D2A_DRIVERA_PULLDB_CH2;
 wire 		w_D2A_COMP_EN_CH2;
 wire 		w_D2A_IDAC_EN_CH2;
 wire [11:0]	w_D2A_IDAC_DIN_CH2;	
 wire 		w_D2A_VDAC_EN_CH2;
 wire [11:0]	w_D2A_VDAC_DIN_CH2;
 wire [3:0] 	w_D2A_ANA_BIST;
*/

  wire [7:0] w_D2A_ANA_GEN_REG_0;
  wire [7:0] w_D2A_ANA_GEN_REG_1;
  wire [7:0] w_D2A_ANA_GEN_REG_2;
  wire [7:0] w_D2A_ANA_GEN_REG_3;
  wire [7:0] w_D2A_ANA_GEN_REG_4;
  wire [7:0] w_D2A_ANA_GEN_REG_5;
  wire [7:0] w_D2A_ANA_GEN_REG_6;
  wire [7:0] w_D2A_ANA_GEN_REG_7;
  wire [7:0] w_D2A_ANA_GEN_REG_8;
  wire [7:0] w_D2A_ANA_GEN_REG_9;
  wire [7:0] w_D2A_ANA_GEN_REG_A;
  wire [7:0] w_D2A_ANA_GEN_REG_B;
  wire [7:0] w_D2A_ANA_GEN_REG_C;
  wire [7:0] w_D2A_ANA_GEN_REG_D;
  wire [7:0] w_D2A_ANA_GEN_REG_E;
  wire [7:0] w_D2A_ANA_GEN_REG_F;
  wire [7:0] w_D2A_ANA_GEN_REG_10;
  wire [7:0] w_D2A_ANA_GEN_REG_11;
  wire [7:0] w_D2A_ANA_GEN_REG_12;

  wire 	     ana_lvd_sts;

  wire       anac_int;

  wire       imeas_intr_clr;

  wire          tsc_intr_en;
  wire          tsc_intr_trans_sel;
  wire          tsc_intr_sts_clr_pulse;
  wire          tsc_intr_sts; 
  wire          o_tsc_intb;
  
  wire        DDA_EN;   
  wire        PGA_EN;
//wire
  wire        CH1_WE_DAC_EN;
  wire        CH1_RCE_DAC_EN;
  wire  [9:0] CH1_DINWE;
  wire  [9:0] CH1_DINRCE;               
  wire        CH2_WE_DAC_EN;
  wire        CH2_RCE_DAC_EN;
  wire [11:0] CH2_DINWE;
  wire [11:0] CH2_DINRCE;
  wire  [1:0] dacbuf_trim;
  wire        R2R_DAC1_EN;
  wire [11:0] R2R_DAC1_DIN;
  wire        R2R_DAC2_EN;
  wire [11:0] R2R_DAC2_DIN;
  wire  [5:0] osc_trim;
  wire  [2:0] dc_clk_div_spi;
  wire  [2:0] BIST_ISEL;
  wire  [6:0] bgh_ctrl;
  wire  [4:0] bgh_vtrim;
  wire  [1:0] ldo1v5_trim;
  wire  [6:0] bgl_ctrl;
  wire  [4:0] bgl_vtrim;
  wire        TSC_EN; 
  wire  [2:0] TSC_GSEL;
  wire        TSC_OUT_SEL;
  wire  [2:0] TSC_BJT_SEL;                                   
  wire        Z_ADC_EN;
//wire        fifo_intr;    //03/04/2024 supriya:not used for ens2, so commented out
  wire  [9:0] DDS;
  wire        o_Z_ADC_EN;
  wire        DAISY_IN_Y;
  wire        iopad_cpha;
  wire        iopad_cpoln;
  wire        int_clk_out;
  wire        int_clk_out_gpio;
  wire        wg_driver_interrupt;
  wire         int_length_slct;

  wire         notch_filter_valid;
  wire  [EEG_CHN_NUM-1:0] notch_clk_gtg_en_imeas;
  wire  [EEG_CHN_NUM-1:0] lpf_clk_gtg_en_imeas;
  wire  [EEG_CHN_NUM-1:0] hpf_clk_gtg_en_imeas;

  wire  [15:0] notch_clk_gtg_en;
  wire  [15:0] lpf_clk_gtg_en;
  wire  [15:0] hpf_clk_gtg_en;

assign notch_clk_gtg_en = {{16-EEG_CHN_NUM{1'b0}}, notch_clk_gtg_en_imeas};
assign lpf_clk_gtg_en = {{16-EEG_CHN_NUM{1'b0}}, lpf_clk_gtg_en_imeas};
assign hpf_clk_gtg_en = {{16-EEG_CHN_NUM{1'b0}}, hpf_clk_gtg_en_imeas};




  wire [NO_OF_NIRS-1:0] NIRS_LED_ON;

gpio u_gpio(
  .i_scan_mode            (atpg_en),
  .i_gpio_pu_ctrl         (gpio_pu_ctrl_reg),             
  .i_gpio_pd_ctrl         (gpio_pd_ctrl_reg),            
  .i_gpio_sr_pdrv0_1_ctrl (gpio_sr_pdrv0_1_ctrl_reg), 
  .o_ens2_IOBUF_CS        (o_ens2_IOBUF_CS),
  .o_ens2_IOBUF_SR        (o_ens2_IOBUF_SR),
  .o_ens2_IOBUF_PDRV0     (o_ens2_IOBUF_PDRV0),
  .o_ens2_IOBUF_PDRV1     (o_ens2_IOBUF_PDRV1),
  .o_ens2_IOBUF_PU        (o_ens2_IOBUF_PU),
  .o_ens2_IOBUF_PD        (o_ens2_IOBUF_PD),
  
  .o_IO_clksel_PD         (o_IO_clksel_PD),
  .o_IO_exresetn_PD       (o_IO_exresetn_PD),
  .o_IO_testmode0_PD      (o_IO_testmode0_PD),
  .o_IO_testmode1_PD      (o_IO_testmode1_PD),

  .o_IO_clksel_PU         (o_IO_clksel_PU),
  .o_IO_exresetn_PU       (o_IO_exresetn_PU),
  .o_IO_testmode0_PU      (o_IO_testmode0_PU),
  .o_IO_testmode1_PU      (o_IO_testmode1_PU)
);

wire o_stim_mon_int;   //to INTB
wire  	     multi_intb_pin;
wire  	     adc_delta_data_cap_in_manual;
wire  	     select_2nd_max_min;

pinmux u_pinmux (

  .o_ens2_IOBUF_IE    (o_ens2_IOBUF_IE),
  .o_ens2_IOBUF_OE    (o_ens2_IOBUF_OE),
  .o_ens2_IOBUF_A     (o_ens2_IOBUF_A), 
  .i_ens2_IOBUF_Y     (i_ens2_IOBUF_Y),
//.altf_sel             (spi_otp.trim_read[10][1:0]),      //d2a_alt_fun_to_otp[1:0] 

  .scan_in              (scan_in),
  .scan_out             (scan_out),
  .scan_compression_in  (scan_compression_in),
  .scan_rst_n           (scan_rst_n),
  .scan_clk             (scan_clk),
  .scan_en              (scan_en),
  .pin_rstn             (ext_resetn),           //output from pinmux

  .otp_bist_resetn      (otp_bist_resetn),      //output from pinmux
  .otp_bist_en          (otp_bist_en),          //to otp
  .otp_bist_tck         (otp_bist_tck),         //to otp
  .otp_bist_tdi         (otp_bist_tdi),         //to otp
  .otp_bist_oen         (otp_bist_oen),         //from otp
  .otp_bist_tdo         (otp_bist_tdo),         //from otp
  .otp_bist_strobe      (otp_bist_strobe),      //to otp
  .otp_bist_tdo_serout  (otp_bist_tdo_serout),  //from otp
//.otp_bist_wbusy       (otp_bist_wbusy),
  .i_bist_vpp_en        (bist_vpp_en),
  .i_otp_vpp_en         (otp_vpp_en),
  .atpg_en              (atpg_en),

  .sclk                 (sclk),
  .cs_n                 (cs_n),
  .mosi                 (mosi),
  .mosi1                (mosi1),
  .miso                 (miso),
  .miso1                (miso1),
  .dual_en              (dual_en),
  .dual_wr              (dual_wr),

 .multi_intb_pin(multi_intb_pin),

  .o_cpoln              (iopad_cpoln),    
  .o_cpha               (iopad_cpha),
  .o_DAISY_IN           (DAISY_IN_Y),
  .hfosc_out            (hfosc_out),
  .i_ext_clk_sel        (CLKSEL_Y),
  .o_ext_clk_sel        (ext_clk_sel),
  .o_int_clk_out_gpio   (int_clk_out_gpio),
  .ext_clk              (ext_hfclk),           
  .iopad_testmode0_en_y (iopad_testmode0_en_y),
  .iopad_testmode1_en_y (iopad_testmode1_en_y),
  .iopad_resetn_y       (iopad_resetn_y),
  .i_wg_drviver_int     (wg_driver_interrupt),
  //.i_lead_off_int       (lead_off_int),
  //.i_lead_off_int       (1'b0),

 //lvd
//  .i_lvd_intr_pin       (lvd_intr_pin),
//  .i_comp_ch1_intr_pin  (comp_ch1_intr_pin),
//  .i_comp_ch2_intr_pin  (comp_ch2_intr_pin),
//  .i_stimu_ch1_intr_pin  (stimu_ch1_intr_pin),
//  .i_stimu_ch2_intr_pin  (stimu_ch2_intr_pin),
  .i_anac_int           (anac_int),
  .i_tsc_int            (o_tsc_intb),   
  .i_eeg_int            (o_eeg_int),
  .i_nirs_int            (o_nirs_int),
  .i_stim_mon_int            (o_stim_mon_int),

  .o_OTP_UNLOCK         (unlock_gpio),
  .o_OTP_ATM_MODE_SEL   (atm_mode),
  .o_OTP_ANA_TESTMODE   (analog_test_mode),
  .o_OTP_ATM_TRIM_DATA  (atm_data), 
  .o_SPI_ATM_MODE_SEL   (atm_adj_mode),
  .o_SPI_ANA_TESTMODE   (atm_adj),
  .o_SPI_ATM_ADJ_DATA   (atm_adj_data), 

//.NORMAL_OUT_SEL       (),
//.COMP_OUT_EN          (),
//.COMP_OUT_SEL         (),
//.COMP_OUT_SEL_STIM    (),
//.o_A2D_COMP0            (A2D_COMP1),
//.o_A2D_COMP1            (A2D_COMP2),
//.A2D_STIMU0_1             (spi_ana_if.A2D_ANA_GEN_REG[0][1]), //A2D_COMP_OUT_STIMU0
//.A2D_STIMU2_3             (spi_ana_if.A2D_ANA_GEN_REG[0][2]), //A2D_COMP_OUT_STIMU1

  .pinmux_if            (pinmux_if),
  .spi_pinmux_if        (spi_pinmux_if),
          
  .sys_d2a_trim_reg     (spi_otp.trim_read[TRIM_NUMBER:1]),
  .i_gpio_nirs_out_ctrl   (gpio_nirs_out_ctrl_reg),  
  .i_gpio_normal_out_ctrl   (gpio_normal_out_ctrl_reg),  

// TSC
  .d2a_tsc_vdac8b_din_ch1 (d2a_tsc_vdac8b_din_ch1),
//.d2a_tsc_vdac8b_en_ch1  (d2a_tsc_vdac8b_en_ch1),
//.d2a_tsc_comp_en_ch1    (d2a_tsc_comp_en_ch1),
  .d2a_tsc_en_ch1         (d2a_tsc_en_ch1),
// WG
  .i_ds_driver_en_current (o_ds_driver_en_current),
  .i_stimu_en             (o_stimu_en),

// NIRS
  .NIRS_LED_ON0           (NIRS_LED_ON[0]),
  .NIRS_LED_ON1           (NIRS_LED_ON[1]),
  .NIRS_LED_ON2           (NIRS_LED_ON[2]),
  .NIRS_LED_ON3           (NIRS_LED_ON[3]),
  .NIRS_LED_ON4           (NIRS_LED_ON[4]),
  .NIRS_LED_ON5           (NIRS_LED_ON[5]),
  .NIRS_LED_ON6           (NIRS_LED_ON[6]),
  .NIRS_LED_ON7           (NIRS_LED_ON[7]),		        
  .NIRS_RESET_SW0	        (ana_nirs_if.D2A_NIRS_RESET_SW[0]),
  .NIRS_IPD_SW0		        (ana_nirs_if.D2A_NIRS_IPD_SW[0]),
  .NIRS_IIN_SW0		        (ana_nirs_if.D2A_NIRS_IIN_SW[0]),
  .A2D_IREFCOARSE0	      (ana_nirs_if.A2D_NIRS_IREFCOARSE[0]),
  .A2D_IREFFINE0	        (ana_nirs_if.A2D_NIRS_IREFFINE[0])
);  

//wire lead_off_pclk;
//wire lead_off_presetn;
wire anac_presetn;
wire temp_sar_presetn;

wire wave_gen_pclk;
wire wave_gen_dds_clk[15:0];
wire wave_gen_fclk;
wire wave_gen_rst;
wire wave_gen_dis;
wire         dds_mode[15:0];
wire [31:0]  dds_step_spi[15:0];


//bps imeas
/*
wire is_2channels;
wire is_4channels;
wire is_6channels;
wire is_8channels;
*/
wire [15:0]  imeas_pclk;
wire [15:0]  imeas_dig_adc_clk;
wire [15:0]  notch_clk;
wire [15:0]  lpf_clk;
wire [15:0]  hpf_clk;
wire [15:0]  imeas_dig_filter_clk_post;

wire [EEG_CHN_NUM-1:0]  imeas_pclk_imeas;
wire [EEG_CHN_NUM-1:0]  imeas_dig_adc_clk_imeas;
wire [EEG_CHN_NUM-1:0]  notch_clk_imeas;
wire [EEG_CHN_NUM-1:0]  lpf_clk_imeas;
wire [EEG_CHN_NUM-1:0]  hpf_clk_imeas;
wire [EEG_CHN_NUM-1:0]  imeas_dig_filter_clk_post_imeas;

assign imeas_pclk_imeas = imeas_pclk[EEG_CHN_NUM-1:0];
assign imeas_dig_adc_clk_imeas = imeas_dig_adc_clk[EEG_CHN_NUM-1:0];
assign notch_clk_imeas = notch_clk[EEG_CHN_NUM-1:0];
assign lpf_clk_imeas = lpf_clk[EEG_CHN_NUM-1:0];
assign hpf_clk_imeas = hpf_clk[EEG_CHN_NUM-1:0];
assign imeas_dig_filter_clk_post_imeas = imeas_dig_filter_clk_post[EEG_CHN_NUM-1:0];

wire        adc_clk_running;
wire        imeas_adc_clk;
wire        imeas_adc_inv;
wire [7:0]  imeas_reg_0;
wire [15:0] imeas_en_chn;
//wire [3:0] DR = 3;
wire [3:0]  DR ;
wire        start_sample;
wire        stop_sample;
wire        start_sample_pclk;
wire        stop_sample_pclk;
//wire      single_shot_true;
wire [15:0] stable_time;
wire        adc_resetn;
wire        adc_ctrl_resetn;
wire        imeas_en;
wire [3:0]  iclk_div ;
wire [2:0]  iclk_div_ina_pga ;
wire   iclk_ina_pga_disable ;
//wire 	    D2A_POWER_EN;
wire 	    enable_cic;
wire        imeas_working_sync;
wire        imeas_working;
//====================
wire [4:0]  i_channel_max;
wire [2:0]  PROD_ID;

 wire adc_en;
//temporily connected for verification
 assign D2A_ADC_EN = adc_en;      //to analog	
 wire adc_mode;
 wire [15:0] adc_cap_period;
 wire [3:0] pair_num;
 wire [15:0] [3:0] stim_pad0_tgt;
 wire [15:0] [3:0] stim_pad1_tgt;
 wire [15:0]  A2D_ADC_DATA_TAG;
 wire [15:0]  A2D_ADC_DELTA_DATA_TAG;


//wire         iclk_stim_monitor_enable;               // stim monitor clock enable 
wire  [3:0]  iclk_div_stim_monitor;               // stim monitor clock divider
wire        iclk_stim_monitor_inv;               
wire        stim_monitor_rst_reg;               


wire 	     stim_monitor_ana_clk;
wire 	     stim_monitor_dig_clk;

wire  bypass_adc_data_en;   //from spi
wire  bypass_ignore_first;   //from spi
wire [3:0] stim_dly_tgt;   //from spi
wire [4:0] stim_mon_int_en;   //from spi
wire [4:0] stim_mon_int_topin_en;   //from spi
wire [1:0] stim_mon_delta_data_sel;   //from spi
wire stim_mon_int_clr;   //from spi
wire stim_mon_int_sts;   //to spi
wire stim_mon_delta_int_clr;   //from spi
wire stim_mon_delta_int_sts;   //to spi
wire stim_mon_cycle_int_clr;   //from spi
wire stim_mon_cycle_int_sts;   //to spi

 wire[15:0]  stim_mon_leadoff_int_clr;   //from spi
wire[15:0] stim_mon_leadoff_int_sts;   //to spi
 wire [15:0] stim_mon_short_int_clr;   //from spi
wire[15:0] stim_mon_short_int_sts;   //to spi

 wire [9:0] threshold_leadoff;  	
 wire [9:0] threshold_short;  	
 wire [7:0] threshold_tgt;
 wire  check_everyN;

wire stim_monitor_rstn;
wire stim_monitor_clk_running;
wire [255:0] one_cycle_data;
wire active_stim;

adc_cap_ctrl u_adc_cap_ctrl(
.sysclk(stim_monitor_dig_clk),	
.presetn(stim_monitor_rstn),
.scan_mode(atpg_en),

 .adc_delta_data_cap_in_manual(adc_delta_data_cap_in_manual),
 .select_2nd_max_min(select_2nd_max_min),
.active_stim(active_stim),

  .o_source_driver           (o_source_driver),//(o_sourcea_driver_a[3:0]),
  .o_pulldn_driver           (o_pulldn_driver),//(o_pullda_driver_a[3:0]),

  .int_length_slct      (int_length_slct),
 .stim_mon_int_en(stim_mon_int_en),   //from spi
 .bypass_adc_data_en(bypass_adc_data_en),   //from spi
 .bypass_ignore_first(bypass_ignore_first),   //from spi
 .stim_dly_tgt(stim_dly_tgt),   //from spi
 .stim_mon_int_topin_en(stim_mon_int_topin_en),   //from spi
 .stim_mon_delta_data_sel(stim_mon_delta_data_sel),   //from spi


 .stim_mon_int_clr(stim_mon_int_clr),   //from spi
 .stim_mon_int_sts(stim_mon_int_sts),   //to spi

 .stim_mon_delta_int_clr(stim_mon_delta_int_clr),   //from spi
 .stim_mon_delta_int_sts(stim_mon_delta_int_sts),   //to spi
 .stim_mon_cycle_int_clr(stim_mon_cycle_int_clr),   //from spi
 .stim_mon_cycle_int_sts(stim_mon_cycle_int_sts),   //to spi

.stim_mon_leadoff_int_clr(stim_mon_leadoff_int_clr),   //from spi
.stim_mon_leadoff_int_sts(stim_mon_leadoff_int_sts),   //to spi
.stim_mon_short_int_clr(stim_mon_short_int_clr),   //from spi
.stim_mon_short_int_sts(stim_mon_short_int_sts),   //to spi

.threshold_leadoff(threshold_leadoff),  	
.threshold_short(threshold_short),  	
.threshold_tgt(threshold_tgt),

.check_everyN(check_everyN),
//.check_everyN(1),

 .o_stim_mon_int(o_stim_mon_int),   //to INTB

.adc_mode(adc_mode),   //0 is manual mode, 1 is auto mode
     	//wavegen also need in manual mode if adc_mode is 0, should provide fixed stim waveform and source/pull
.adc_cap_period(adc_cap_period),	

.pair_num(pair_num),   //1 means has 2 pair, 2 means has 3 pair, max 16 pair	
//.pair_num(8),   //1 means has 2 pair, 2 means has 3 pair, max 16 pair	

.stim_pad0_tgt(stim_pad0_tgt),	
.stim_pad1_tgt(stim_pad1_tgt),	
//temporily connected for verification
/*
.A2D_ADC_DATA(), //from analog //ADC use posedge of sysclk to output data, 
		//digital use negedge to capture, so we have half sysclk cycle margin for it	
.A2D_ADC_DATA_EN(),//from analog	
.D2A_STIM_PAD0(),    //to analog	
.D2A_STIM_PAD1(),    //to analog	
*/
.A2D_ADC_DATA(A2D_ADC_DATA), //from analog //ADC use posedge of sysclk to output data, 
		//digital use negedge to capture, so we have half sysclk cycle margin for it	
.A2D_ADC_DATA_EN(A2D_ADC_DATA_EN),//from analog	
.D2A_STIM_PAD0(D2A_STIM_PAD0),    //to analog	
.D2A_STIM_PAD1(D2A_STIM_PAD1),    //to analog	


.A2D_ADC_DATA_VLD(),	
.A2D_ADC_DATA_TAG(A2D_ADC_DATA_TAG),	
.A2D_ADC_DELTA_DATA_VLD(),	
.A2D_ADC_DELTA_DATA_TAG(A2D_ADC_DELTA_DATA_TAG),	
.one_cycle_data_vld(),
.one_cycle_data(one_cycle_data)
);
//wire ina_pga_ana_clk;
clk_ctrl u_clk_ctrl
(
  //bps imeas
  .PROD_ID(PROD_ID),

  .i_channel_max(i_channel_max),

  .enable_cic(enable_cic),
  .imeas_working_sync(imeas_working_sync),
  .imeas_working(imeas_working),
  .en_channels(imeas_en_chn),

.iclk_ina_pga_disable(iclk_ina_pga_disable),               // ina_pga clock divider
.iclk_div_ina_pga(iclk_div_ina_pga),               // ina_pga clock divider
.ina_pga_ana_clk(ina_pga_ana_clk),   //before name pga_ana_clk, connected to analog or pinmux then analog top

 .iclk_stim_monitor_enable(adc_en),               // stim monitor clock enable 
 .iclk_div_stim_monitor(iclk_div_stim_monitor),               // stim monitor clock divider
.iclk_stim_monitor_inv(iclk_stim_monitor_inv),               
 .stim_monitor_ana_clk(D2A_ADC_CLK),    				//connected to analog or pinmux then analog top
 .stim_monitor_dig_clk(stim_monitor_dig_clk),
 .stim_monitor_clk_running(stim_monitor_clk_running),

  .iclk_div(iclk_div),
  .imeas_adc_inv(imeas_adc_inv),
  .imeas_pclk(imeas_pclk),
  .imeas_dig_adc_clk(imeas_dig_adc_clk),
  .imeas_adc_clk(imeas_adc_clk),
  .adc_clk_running(adc_clk_running),
  .adc_resetn  (adc_resetn),
  .adc_ctrl_resetn  (adc_ctrl_resetn),
  .notch_clk(notch_clk),
  .lpf_clk(lpf_clk),
  .hpf_clk(hpf_clk),
  .imeas_dig_filter_clk_post(imeas_dig_filter_clk_post),
  .notch_clk_gtg_en(notch_clk_gtg_en),
  .notch_filter_valid(notch_filter_valid),
  .lpf_clk_gtg_en(lpf_clk_gtg_en),
  .hpf_clk_gtg_en(hpf_clk_gtg_en),
  .osr_sel(DR),          

  .ppg_dis(ppg_dis),           //ppg disble 
  .ppg_clk_div(ppg_clk_div),       // ppg clock divider
  .ana_ppgclk_inv(ana_ppgclk_inv_config),   // ana ppg clock 
  .ppg_clk50duty(ppg_clk50duty),            

/*
  .ppg_dis(1),           //ppg disble 
  .ppg_clk_div(0),       // ppg clock divider
  .ana_ppgclk_inv(1),   // ana ppg clock 
  .ppg_clk50duty(1),            
*/
  .ppg_clk_running      (ppg_clk_running),
  .clk_ppg	        (clk_ppg),           //ppg digital 
  .clk_sys_ppg	        (clk_sys_ppg),           //ppg sys clock 
  .ana_clk_ppg	        (ana_clk_ppg),           //ppg analog clock 

  .presetn              (presetn),
  .poresetn             (poresetn),
  .ext_clk_sel          (ext_clk_sel),
  .ext_hfclk            (ext_hfclk),
  .hfosc                (hfosc),
  .otp_bist_tck         (otp_bist_tck),
  .scan_clk             (scan_clk),
  .atpg_en              (atpg_en),
  .scan_enable          (scan_en),            //tri change
  .pmu_fclk_en          (pmu_fclk_en),
  //.fclk_dynen           (fclk_dynen),         //from SPI //input  wire fclk_dynen
  .pclk_div             (pclk_div),           //from SPI //input  wire  [1:0]  pclk_div
  .int_clk_out          (int_clk_out),        //from SPI to select int clk going out when 1, no sync required, default 0
  .int_clk_out_gpio     (int_clk_out_gpio),   //from GPIO to select int clk going out when 1
  .hfosc_atpg           (hfosc_atpg),
  .otp_bist_tck_atpg    (otp_bist_tck_atpg),  //to otp
  //.fclk                 (fclk),

  .o_clk_sel            (o_clk_sel),

  .pclk                 (pclk),
  .anac_pclk            (anac_pclk),
  .otp_pclk             (otp_pclk),
  .otp_dpstb_en         (otp_dpstb_en),   //from SPI
  .anac_clock_en        (anac_clock_en),
  .temp_sar_clock_dis   (temp_sar_clock_dis),
  .temp_sar_pclk        (temp_sar_pclk),
  //.lead_off_en          (lead_off_en),
  //.lead_off_pclk        (lead_off_pclk),
  .wave_gen_dis         (wave_gen_dis),
  .wave_gen_pclk        (wave_gen_pclk),
  .wave_gen_fclk        (wave_gen_fclk),
  .wave_gen_dds_clk     (wave_gen_dds_clk),
  .dds_mode             (dds_mode),
  .dds_step_spi         (dds_step_spi),
  .hfosc_out            (hfosc_out)                    //to pinmux then to one of gpio io cells
);

//bps imeas
//wire      filter_re_rstn;
wire      filter_rstn;
wire      cic_rst;
wire      cic_rst_n;
wire      reset_cmd;
wire      start_cmd;
wire      stop_cmd;
//wire      wakeup_cmd;
//wire      standby_cmd;
wire       single_shot;

//===============
wire       poresetn_hf;      //from switchable digital POR time out //global reset after sync by hfclk

reset_ctrl u_reset_ctrl
(
//bps function
  .reset_cmd(reset_cmd),
//.start_meas(start_meas),
  .filter_rstn(filter_rstn),
  .cic_rst_n(cic_rst_n),//
  .adc_resetn  (adc_resetn),
  .adc_ctrl_resetn  (adc_ctrl_resetn),
  .cic_rst(cic_rst),//
  .adc_clk(adc_clk_running),//
  .start_sample(start_sample),
//.stop_sample(stop_sample),
  .start_sample_pclk(start_sample_pclk),
//.stop_sample_pclk(stop_sample_pclk),

  .por_resetn           (por_resetn),
  .ext_resetn           (ext_resetn),
  .otp_bist_resetn      (otp_bist_resetn),
  .scan_rst_n           (scan_rst_n),
  .atpg_en              (atpg_en),
  //.otp_bist_en          (otp_bist_en),
  .hfosc_atpg           (hfosc_atpg),
  //.fclk                 (fclk),
  .pclk                 (pclk),

.stim_monitor_rst_reg(stim_monitor_rst_reg), 
.stim_monitor_rstn(stim_monitor_rstn), 
.stim_monitor_clk_running(stim_monitor_clk_running), 

//ppg
  .ppg_clk_running	(ppg_clk_running),
  .ppg_resetn		(ppg_resetn),
  .ppg_rst_reg          (ppg_rst_reg),

  .wave_gen_rst         (wave_gen_rst),
  .wave_gen_presetn     (wave_gen_presetn),
  .poresetn             (poresetn),
  .poresetn_hf          (poresetn_hf),
  .presetn              (presetn),
  //.otp_por_resetn       (otp_por_resetn),
  .otp_bist_resetn_atpg (otp_bist_resetn_atpg), //connect to otp for bist resetn

  .stim_global_en 	(stim_global_en),
  .stim_eeg_sync_en 	(stim_eeg_sync_en),
  .filter_dly_tgt 	(filter_dly_tgt),


//  .stim_eeg_sync_en 	(1),
//  .stim_global_en 	(1),
//  .filter_dly_tgt 	(24'hff),

  .otp_rst_reg          (otp_rst_reg),
  .dig_rst_reg          (dig_rst_reg),
  //.lead_off_rst         (lead_off_rst),
  //.lead_off_presetn     (lead_off_presetn),
  .anac_reset           (anac_reset),
  .temp_sar_reset       (temp_sar_reset),
  .anac_presetn         (anac_presetn),
  .temp_sar_presetn     (temp_sar_presetn),

  // EEPROM
/*
  .prep_to_slp              (1'b0),
  .rst_ctrl_otp_vdd2_enable (rst_ctrl_otp_vdd2_enable),
  .prep_to_slp_delay1clk    (prep_to_slp_delay1clk),
  .prep_to_slp_delay2clk    (prep_to_slp_delay2clk),
  .prep_to_slp_sync         (prep_to_slp_sync),
*/
  .otp_rstn              (otp_rstn) 
);

// instantiate pmu
pmu u_pmu (
        //.wakeup_cmd(wakeup_cmd),
        //.standby_cmd(standby_cmd),
        //.D2A_POWER_EN(D2A_POWER_EN),
//===============

  //.presetn              (presetn),
  //.pclk                 (pclk),
  .poresetn_hf          (poresetn_hf),
  .hfosc_atpg           (hfosc_atpg),
  //.atpg_en              (atpg_en),
  .pmuenable            (pmuenable),      //From SPI
  .hresetreq            (hresetreq),      //can connect to SPI as a reset request
  .sleepdeep            (sleepdeep),      //From SPI
  //.otp_dpstb_en         (otp_dpstb_en),   //from SPI
  //.otp_por_resetn       (otp_por_resetn),
  .pmu_fclk_en          (pmu_fclk_en)
  //.otp_dpstb            (otp_dpstb)       //to otp
);


otp_ctrl_top u_otp_ctrl_top(
  .spi_otp(spi_otp),
  .clk                  (otp_pclk),  
  .rst_n                (otp_rstn), 
  .por_resetn           (por_resetn),
  .atpg_en              (atpg_en),  
  .hosc_sel             (pclk_div),
  .test_en              (otp_bist_en),
  .TCK                  (otp_bist_tck_atpg),
  .RESETb               (otp_bist_resetn_atpg),
  .TDI                  (otp_bist_tdi),
  .STROBE               (otp_bist_strobe),
  .TDO                  (otp_bist_tdo),
  .serout               (otp_bist_tdo_serout),
  .OEN                  (otp_bist_oen),
  .vpp_en               (bist_vpp_en), //output ,when programming otp by bist : 0 to 1 : vpp needs to go from vdd  to 7.5v in 19 tck cycles
                                                                              //1 to 0 : vpp needs to go from 7.5v to vdd  in 19 tck cycles
  .analog_test_mode     (analog_test_mode),
  .atm_mode             (atm_mode),
  .atm_data             (atm_data[7:0]),
  .unlock_gpio          (unlock_gpio),
                                                                 //(later adjust the tck cycles according to the actual situation) 
  .otp_vpp_en           (otp_vpp_en),   //output ,0 to 1 : vpp needs to go from vdd  to 7.5v within 8us
                                        //1 to 0 : vpp needs to go from 7.5v to vdd  within 8us

  .VPP                  (VPP_OTP),      
  .VDD                  (VDD_OTP),      
  .VSUB                 (VSUB_OTP),        
  .VSS_OTP              (VSS_OTP)
);


//otp_ctrl_top u_otp_ctrl_top(
//  .spi_otp(spi_otp),
//  .TCK                    (otp_bist_tck_atpg),           
//  .RESETb                 (otp_bist_resetn_atpg),
//  .TDI                    (otp_bist_tdi),
//  .STROBE                 (otp_bist_strobe),
//  .test_en                (otp_bist_en), 
//  .TDO                    (otp_bist_tdo),
//  .OEN                    (otp_bist_oen),
//  .serout                 (otp_bist_tdo_serout),
//
//  .analog_test_mode       (analog_test_mode),
//  .atm_mode               (atm_mode),
//  .atm_data               (atm_data[7:0]),
//  .unlock_gpio            (unlock_gpio),
//  .hosc_sel               (pclk_div), 
//  .clk                    (otp_pclk),       
//  .rst_n                  (otp_rstn), 
//  .VDD                    (VDD_OTP),
//  .VSUB                   (VSUB_OTP),
//  .VPP                    (VPP_OTP),
//  .AVDD                   (AVDD_OTP),
//  .VSS_OTP                (VSS_OTP),
//  .atpg_en                (atpg_en)    
//);

//=========================
//bps function
wire [15:0] imeas_adc_din;
assign imeas_adc_din = { A2D_SDM_OUT15,
                         A2D_SDM_OUT14,
                         A2D_SDM_OUT13,
                         A2D_SDM_OUT12,
                         A2D_SDM_OUT11,
                         A2D_SDM_OUT10,
                         A2D_SDM_OUT9,
                         A2D_SDM_OUT8,
                         A2D_SDM_OUT7,
                         A2D_SDM_OUT6,
                         A2D_SDM_OUT5,
                         A2D_SDM_OUT4,
                         A2D_SDM_OUT3,
                         A2D_SDM_OUT2,
                         A2D_SDM_OUT1,
                         A2D_SDM_OUT0
                        };

wire [EEG_CHN_NUM-1:0] imeas_adc_din_imeas;
assign imeas_adc_din_imeas = imeas_adc_din[EEG_CHN_NUM-1:0];

assign D2A_SDM_CLK = imeas_adc_clk;

wire stim_on_flag;

imeas_wrapper  #(
.DATA_WIDTH(EEG_DATA_WIDTH),
.CHN_NUM(EEG_CHN_NUM)
) u_imeas_wrapper (
//from old clk_ctrl
.stable_time	(stable_time),
.adc_resetn	(adc_resetn),
.adc_ctrl_resetn(adc_ctrl_resetn),
.adc_clk_running(adc_clk_running),
.imeas_pclk(imeas_pclk_imeas),
.imeas_dig_adc_clk(imeas_dig_adc_clk_imeas),

.active_stim(active_stim),
.stim_on_flag(stim_on_flag),
.imeas_working_sync(imeas_working_sync),
.imeas_working(imeas_working),

//.D2A_POWER_EN	(D2A_POWER_EN),
.imeas_en	(imeas_en),
//.imeas_en	(1),
.start_sample	(start_sample),
.start_sample_pclk	(start_sample_pclk),
//.stop_sample	(stop_sample),
//.stop_sample_pclk	(stop_sample_pclk),
.enable_cic	(enable_cic),    //to clk_ctrl
//++++++++++++++++++++++++++
//from old pmu
.start_y	(1'b0),

//.start_cmd	(1),
.start_cmd	(start_cmd),
.stop_cmd	(stop_cmd),
.single_shot	(single_shot),

//.data_rdyn	(),
//++++++++++++++++++++++++++

//clock and reset
.pclk	(pclk),             // pclk
//.presetn	(presetn),          // reset
.atpg_en	(atpg_en),          // atpg enable

.cic_rst_n	(cic_rst_n),
.filter_rstn	(filter_rstn),
.imeas_reg_0	(imeas_reg_0),
.DR	(DR),
//.DR	(2),
//.imeas_chdata_adcclk	(imeas_chdata_adcclk),
//.chdata_en_adcclk	(chdata_en_adcclk),

//.imeas_chdata	(imeas_chdata),
//.chdata_en	(chdata_en),
//with analog
.imeas_adc_din  (imeas_adc_din_imeas),  // adc serial data input

.clk(imeas_dig_filter_clk_post_imeas),   
.notch_clk(notch_clk_imeas),
.lpf_clk(lpf_clk_imeas),
.hpf_clk(hpf_clk_imeas),
//.pclk	(pclk),  // pclk
//.reset(cic_rst_n),
//.osr_sel(DR),
.iclk_div(iclk_div),
//.filter_seq(filter_seq),
.notch_filter_valid(notch_filter_valid),
.notch_clk_gtg_en(notch_clk_gtg_en_imeas),
.lpf_clk_gtg_en(lpf_clk_gtg_en_imeas),
.hpf_clk_gtg_en(hpf_clk_gtg_en_imeas),

.notch_filter_bypass(notch_filter_bypass),
.lpf_filter_bypass(lpf_filter_bypass),
.hpf_filter_bypass(hpf_filter_bypass),
//.hpf_filter_bypass(hpf_filter_bypass),
.int_length_slct(int_length_slct),
.eeg_int_en(eeg_int_en),
.eeg_int_clr(eeg_int_clr),
//.scan_mode(atpg_en),

.cic_data_ignore_tar(cic_data_ignore_tar),
.lpf_coeff_data(lpf_coeff_data),
.hpf_coeff_data(hpf_coeff_data),
.notch_coeff_data(notch_coeff_data),
.o_eeg_int(o_eeg_int),
.eeg_int_sts(eeg_int_sts),
.meas_done_d1(meas_done_filter),
.imeas_chdata_out(imeas_chdata_filter),
.i_imeas_intr_clr(imeas_intr_clr)
);                                                            

//=========================
//filter_wrapper #(
//.DATA_WIDTH(EEG_DATA_WIDTH),
//.CHN_NUM(EEG_CHN_NUM))
//u_filter_wrapper(
//.clk(imeas_dig_filter_clk_post),   
//.notch_clk(notch_clk),
//.lpf_clk(lpf_clk),
//.hpf_clk(hpf_clk),
//.pclk	(pclk),  // pclk
//.reset(cic_rst_n),
//.sign_en(~imeas_reg_0[7]),
//.osr_sel(DR),
//.iclk_div(iclk_div),
////.filter_seq(filter_seq),
//.notch_filter_valid(notch_filter_valid),
//.notch_clk_gtg_en(notch_clk_gtg_en),
//.lpf_clk_gtg_en(lpf_clk_gtg_en),
//.hpf_clk_gtg_en(hpf_clk_gtg_en),
//
//.notch_filter_bypass(notch_filter_bypass),
//.lpf_filter_bypass(lpf_filter_bypass),
//.hpf_filter_bypass(hpf_filter_bypass),
////.hpf_filter_bypass(hpf_filter_bypass),
//.int_length_slct(int_length_slct),
//.eeg_int_en(eeg_int_en),
//.eeg_int_clr(eeg_int_clr),
//.scan_mode(atpg_en),
////.imeas_chdata_in(imeas_chdata),
////.chdata_en(chdata_en),
//.imeas_chdata_in(imeas_chdata_adcclk),
//.chdata_en(chdata_en_adcclk),
//
//.cic_data_ignore_tar(cic_data_ignore_tar),
//.lpf_coeff_data(lpf_coeff_data),
//.hpf_coeff_data(hpf_coeff_data),
//.notch_coeff_data(notch_coeff_data),
//.o_eeg_int(o_eeg_int),
//.eeg_int_sts(eeg_int_sts),
//.meas_done_d1(meas_done_filter),
//.imeas_chdata_out(imeas_chdata_filter),
//.i_imeas_intr_clr(imeas_intr_clr)
//
//);

wire sel_stim;

//SPI to be modified to connect to i and z meas blocks
spi_top  #(
  .ADDR_WIDTH           (8),
  .DATA_WIDTH           (8),
  .HLF_WV_NO_PTS        (HLF_WV_NO_PTS),
  .NO_OF_WAVEGEN        (NO_OF_WAVEGEN),
  .EEG_CHN_NUM          (EEG_CHN_NUM),
  .OUT_NO_BITS          (OUT_NO_BITS)
)
u_spi_top (
  .i_channel_max(i_channel_max),

 .multi_intb_pin(multi_intb_pin),

 .adc_delta_data_cap_in_manual(adc_delta_data_cap_in_manual),
 .select_2nd_max_min(select_2nd_max_min),

.stim_on_flag(stim_on_flag),
  .stim_eeg_sync_en 	(stim_eeg_sync_en),
  .filter_dly_tgt 	(filter_dly_tgt),

//  .spi_leadoff(spi_leadoff),
  .spi_anac(spi_anac),
  .spi_otp(spi_otp),
  .spi_wg (spi_wg),
  .spi_ana_if(spi_ana_if),
  .spi_pinmux_if(spi_pinmux_if),
  .spi_nirs_if(spi_nirs_if),
  .SCANMODE             (atpg_en),
  .atm_adj_mode         (atm_adj_mode),
  .atm_adj_data         (atm_adj_data),
  .atm_adj              (atm_adj),
  .i_scanclk            (scan_clk),             
//.i_sys_clk            (pclk),
  .i_rst_n              (presetn),
  .iopad_cpha           (iopad_cpha),
  .iopad_cpol           (iopad_cpoln),
  .DAISY_IN_Y           (DAISY_IN_Y),
  
  .i_sclk                (sclk),             // sclk clock for the spi-slave controller and reg block 
  .i_cs_n                (cs_n),
  .i_mosi                (mosi),
  .i_mosi1               (mosi1),
  .o_miso                (miso),
  .o_miso1               (miso1),
  .o_dual_en             (dual_en),
  .o_dual_wr             (dual_wr),
  .o_imeas_intr_clr      (imeas_intr_clr),

  .i_imeas_done(meas_done_filter),
  .PROD_ID(PROD_ID),
//.rd_cmd_ind           (rd_cmd_ind),
//.first_neg_sclk       (first_neg_sclk),
//.reset_cmd            (reset_cmd),

//bps imeas
  .imeas_chdata(imeas_chdata_filter),
  .reset_cmd            (reset_cmd),
  .stable_time (stable_time),
  .start_cmd          (start_cmd),
  .stop_cmd           (stop_cmd),
//.wakeup_cmd         (wakeup_cmd),
//.standby_cmd        (standby_cmd),
  .single_shot        (single_shot),
  .iclk_div             (iclk_div),

.iclk_ina_pga_disable(iclk_ina_pga_disable),               // ina_pga clock divider
  .iclk_div_ina_pga             (iclk_div_ina_pga),

 .bypass_adc_data_en(bypass_adc_data_en),   //from spi
 .bypass_ignore_first(bypass_ignore_first),   //from spi
 .stim_dly_tgt(stim_dly_tgt),   //from spi
 .stim_mon_int_en(stim_mon_int_en),   //from spi
 .stim_mon_int_clr(stim_mon_int_clr),   //from spi
 .stim_mon_int_sts(stim_mon_int_sts),   //to spi

 .stim_mon_int_topin_en(stim_mon_int_topin_en),   //from spi
 .stim_mon_delta_data_sel(stim_mon_delta_data_sel),   //from spi
 .stim_mon_delta_int_clr(stim_mon_delta_int_clr),   //from spi
 .stim_mon_delta_int_sts(stim_mon_delta_int_sts),   //to spi
 .stim_mon_cycle_int_clr(stim_mon_cycle_int_clr),   //from spi
 .stim_mon_cycle_int_sts(stim_mon_cycle_int_sts),   //to spi

.stim_mon_leadoff_int_clr(stim_mon_leadoff_int_clr),   //from spi
.stim_mon_leadoff_int_sts(stim_mon_leadoff_int_sts),   //to spi
.stim_mon_short_int_clr(stim_mon_short_int_clr),   //from spi
.stim_mon_short_int_sts(stim_mon_short_int_sts),   //to spi

.threshold_leadoff(threshold_leadoff),  	
.threshold_short(threshold_short),  	
.threshold_tgt(threshold_tgt),

.check_everyN(check_everyN),

.one_cycle_data(one_cycle_data),

.adc_en(adc_en),
.adc_mode(adc_mode),
.adc_cap_period(adc_cap_period),
.pair_num(pair_num),
.stim_pad0_tgt(stim_pad0_tgt),
.stim_pad1_tgt(stim_pad1_tgt),
.iclk_div_stim_monitor(iclk_div_stim_monitor) ,
.iclk_stim_monitor_inv(iclk_stim_monitor_inv), 
.stim_monitor_rst_reg(stim_monitor_rst_reg), 
.A2D_ADC_DATA_TAG(A2D_ADC_DATA_TAG),
.A2D_ADC_DELTA_DATA_TAG(A2D_ADC_DELTA_DATA_TAG),	

.A2D_ADC_DATA(A2D_ADC_DATA), //from analog // 
.A2D_ADC_DATA_EN(A2D_ADC_DATA_EN),//from analog	

  .imeas_en             (imeas_en),
  .imeas_reg_0          (imeas_reg_0),
  .imeas_en_chn          (imeas_en_chn),
  .DR                   (DR),
  .imeas_adc_inv        (imeas_adc_inv),
  .cic_rst              (cic_rst),//
//=========================

// .filter_seq(filter_seq),
  .notch_filter_bypass(notch_filter_bypass),
  .lpf_filter_bypass(lpf_filter_bypass),
  .hpf_filter_bypass(hpf_filter_bypass),
  .eeg_int_en(eeg_int_en),
  .eeg_int_clr(eeg_int_clr),
  .eeg_int_sts(eeg_int_sts),

  //ppg
  .ppg_dis	(ppg_dis),           //ppg disble 
  .ppg_clk_div	(ppg_clk_div),       // ppg clock divider
  .ana_ppgclk_inv	(ana_ppgclk_inv_config),   // ana ppg clock 
  .ppg_clk50duty	(ppg_clk50duty),            
  .ppg_rst_reg	(ppg_rst_reg),
  .ppg_clk_gate_bypass  (ppg_clk_gate_bypass),

  //tsc int
 .tsc_intr_en(tsc_intr_en),
 .tsc_intr_trans_sel(tsc_intr_trans_sel),
 .tsc_intr_sts_clr(tsc_intr_sts_clr_pulse),
 .tsc_intr_sts(tsc_intr_sts),  
 .cic_data_ignore_tar(cic_data_ignore_tar),
 .lpf_coeff_data_o(lpf_coeff_data),
 .notch_coeff_data_o(notch_coeff_data),
 .hpf_coeff_data_o(hpf_coeff_data),

 // config
  //.fclk_dynen         (fclk_dynen),
  .pclk_div             (pclk_div),
  .o_int_clk_out        (int_clk_out),
  .wave_gen_dis         (wave_gen_dis),
  .wave_gen_rst         (wave_gen_rst),
  .pmuenable            (pmuenable),   // pmu enable
  .hresetreq            (hresetreq),   // system reset request
  .sleepdeep            (sleepdeep),   // system enters deep-sleep state
  .otp_dpstb_en         (otp_dpstb_en), // otp deep power down standby mode enable
  .anac_clock_en        (anac_clock_en),
  .temp_sar_clock_dis   (temp_sar_clock_dis),
  .anac_reset           (anac_reset),
  .temp_sar_reset       (temp_sar_reset),
  .en_reg_sel           (en_reg_sel),
  .tsc_vdac8b_din_ch1   (tsc_vdac8b_din_ch1),
  .tsc_comp_low_ch1     (tsc_comp_low_ch1),
  .tsc_vdac8b_en_ch1    (tsc_vdac8b_en_ch1),
  .tsc_comp_en_ch1      (tsc_comp_en_ch1),
  .tsc_en_ch1           (tsc_en_ch1),
  .sample_duration      (sample_duration),
  .stable_duration      (stable_duration),
  .busy_doing           (busy_doing),
  .VDAC_NOR             (VDAC_NOR),

  .int_length_slct      (int_length_slct),
  .ana_lvd_sts          (ana_lvd_sts),	//to ANAC

  .o_clk_sel          (o_clk_sel),
  .otp_rst_reg        (otp_rst_reg),
  .dig_rst_reg        (dig_rst_reg),


  //.lead_off_Counter_cnt_dac0_final_dbg  (lead_off_Counter_cnt_dac0_final_dbg),
  //.lead_off_Counter_cnt_dac1_final_dbg  (lead_off_Counter_cnt_dac1_final_dbg),

//lead_off
//------------------------------------
  //.lead_off_Counter_cnt_dac0_dbg  (lead_off_Counter_cnt_dac0_dbg),
  //.lead_off_Counter_cnt_dac1_dbg  (lead_off_Counter_cnt_dac1_dbg),

  //.lead_off_rst         (lead_off_rst),
  //.lead_off_en          (lead_off_en),
  //.timer_cnt_tgt           (timer_cnt_tgt),
  //.timer_cnt_tgt1          (timer_cnt_tgt1),
  //.counter_th_tgt          (counter_th_tgt),
  //.counter_th_tgt1         (counter_th_tgt1),

  //.sel_stim        	    (sel_stim),
  //.lead_off_sts_clear   (lead_off_sts_clear),   
  //.lead_off1_sts_clear   (lead_off1_sts_clear),   
  //.dac_en              (dac_en),            //bit0=1 is dac0, , bit1=1 is dac1 
  //.A2D_COMP1            (A2D_COMP1),   
  //.A2D_COMP2            (A2D_COMP2),   
  //..A2D_COMP0_7       ({14'b0,A2D_COMP2,A2D_COMP1}),   
  
  //.lead_off_result      (lead_off_result),   
  //.lead_off_result1      (lead_off_result1),   
  //.lead_off_int_en      (lead_off_int_en),
  //.lead_off_stop_en      (lead_off_stop_en),
  //.lead_off_stop1_en      (lead_off_stop1_en),

  //.comp_low_ch0      (comp_low_ch0),
  //.comp_low_ch1      (comp_low_ch1),

 //--gpio
  .gpio_pu_ctrl                 (gpio_pu_ctrl_reg),         
  .gpio_pd_ctrl                 (gpio_pd_ctrl_reg),        
  .gpio_nirs_out_ctrl           (gpio_nirs_out_ctrl_reg), 
  .gpio_normal_out_ctrl         (gpio_normal_out_ctrl_reg), 
  .gpio_sr_pdrv0_1_ctrl         (gpio_sr_pdrv0_1_ctrl_reg)

//output to always on
  
//analog register outputs


//-------Analog Register Output----------

      //.o_D2A_ANA_GEN_REG_0	(w_D2A_ANA_GEN_REG_0),
      //.o_D2A_ANA_GEN_REG_1	(w_D2A_ANA_GEN_REG_1),
      //.o_D2A_ANA_GEN_REG_2	(w_D2A_ANA_GEN_REG_2),
      //.o_D2A_ANA_GEN_REG_3	(w_D2A_ANA_GEN_REG_3),
      //.o_D2A_ANA_GEN_REG_4	(w_D2A_ANA_GEN_REG_4),
      //.o_D2A_ANA_GEN_REG_5	(w_D2A_ANA_GEN_REG_5),
      //.o_D2A_ANA_GEN_REG_6	(w_D2A_ANA_GEN_REG_6),
      //.o_D2A_ANA_GEN_REG_7	(w_D2A_ANA_GEN_REG_7),
      //.o_D2A_ANA_GEN_REG_8	(w_D2A_ANA_GEN_REG_8),
      //.o_D2A_ANA_GEN_REG_9	(w_D2A_ANA_GEN_REG_9),
      //.o_D2A_ANA_GEN_REG_A	(w_D2A_ANA_GEN_REG_A),
      //.o_D2A_ANA_GEN_REG_B	(w_D2A_ANA_GEN_REG_B),
      //.o_D2A_ANA_GEN_REG_C	(w_D2A_ANA_GEN_REG_C),
      //.o_D2A_ANA_GEN_REG_D	(w_D2A_ANA_GEN_REG_D),
      //.o_D2A_ANA_GEN_REG_E	(w_D2A_ANA_GEN_REG_E),
      //.o_D2A_ANA_GEN_REG_F	(w_D2A_ANA_GEN_REG_F),
      //.o_D2A_ANA_GEN_REG_10	(w_D2A_ANA_GEN_REG_10),
      //.o_D2A_ANA_GEN_REG_11	(w_D2A_ANA_GEN_REG_11),
      //.o_D2A_ANA_GEN_REG_12	(w_D2A_ANA_GEN_REG_12)

       /*
        .o_D2A_LVD_EN		(w_D2A_LVD_EN),
    .o_D2A_CLDO2P4_EN	(w_D2A_CLDO2P4_EN),
  .o_D2A_LVD_TRIM		(w_D2A_LVD_TRIM),
  .o_D2A_OSC2MHZEN	(w_D2A_OSC2MHZEN),
   .o_D2A_SC_DOUBLER_EN	(w_D2A_SC_DOUBLER_EN),
  .o_D2A_DRIVERA_AMP_EN_CH1(w_D2A_DRIVERA_AMP_EN_CH1),
   .o_D2A_DRIVERA_SOURCEA_CH1(w_D2A_DRIVERA_SOURCEA_CH1),
   .o_D2A_DRIVERA_SOURCEB_CH1(w_D2A_DRIVERA_SOURCEB_CH1),
   .o_D2A_DRIVERA_PULLDA_CH1(w_D2A_DRIVERA_PULLDA_CH1),
  .o_D2A_DRIVERA_PULLDB_CH1(w_D2A_DRIVERA_PULLDB_CH1),
  .o_D2A_DRIVERA_CS_RTRIM_CH1(w_D2A_DRIVERA_CS_RTRIM_CH1),
  .o_D2A_COMP_EN_CH1	(w_D2A_COMP_EN_CH1),
  .o_D2A_IDAC_EN_CH1	(w_D2A_IDAC_EN_CH1),
  .o_D2A_IDAC_DIN_CH1	(w_D2A_IDAC_DIN_CH1),
  .o_D2A_VDAC_EN_CH1	(w_D2A_VDAC_EN_CH1),
  .o_D2A_VDAC_DIN_CH1	(w_D2A_VDAC_DIN_CH1),
  .o_D2A_DRIVERA_AMP_EN_CH2(w_D2A_DRIVERA_AMP_EN_CH2),
  .o_D2A_DRIVERA_SOURCEA_CH2(w_D2A_DRIVERA_SOURCEA_CH2),
  .o_D2A_DRIVERA_SOURCEB_CH2(w_D2A_DRIVERA_SOURCEB_CH2),
  .o_D2A_DRIVERA_PULLDA_CH2(w_D2A_DRIVERA_PULLDA_CH2),
  .o_D2A_DRIVERA_PULLDB_CH2(w_D2A_DRIVERA_PULLDB_CH2),
  .o_D2A_COMP_EN_CH2	(w_D2A_COMP_EN_CH2),
   .o_D2A_IDAC_EN_CH2	(w_D2A_IDAC_EN_CH2),
   .o_D2A_IDAC_DIN_CH2	(w_D2A_IDAC_DIN_CH2),	
   .o_D2A_VDAC_EN_CH2	(w_D2A_VDAC_EN_CH2),
  .o_D2A_VDAC_DIN_CH2	(w_D2A_VDAC_DIN_CH2),
   .o_D2A_ANA_BIST		(w_D2A_ANA_BIST)
        */

  );
 
wire [NO_OF_WAVEGEN-1:0] drive_en;
wg_driver_top_wrapper #(
.HLF_WV_NO_PTS                  (HLF_WV_NO_PTS),
.OUT_NO_BITS                    (OUT_NO_BITS),
.ELEC_NO_C                      (NO_OF_WAVEGEN)
) u_wg_driver
(
/*AUTOINST*/
 // Outputs
  .o_out_wave_driver_idac      (o_out_wave_driver_idac),
  .drive_en                  (drive_en),            //bit0=1 is dac0, , bit1=1 is dac1 
  .o_source_driver           (o_source_driver),//(o_sourcea_driver_a[3:0]),
//  .o_sourceb_driver_c           (o_sourceb_driver_a),//(o_sourceb_driver_a[3:0]),
  .o_pulldn_driver           (o_pulldn_driver),//(o_pullda_driver_a[3:0]),
//  .o_pulldb_driver_c            (o_pulldb_driver_a),//(o_pulldb_driver_a[3:0]),

//  .o_ds_driver_c_ct0(),
//  .o_ds_driver_c_ct1(),
//  .o_ds_driver_c_ct2(),
//  .o_ds_driver_c_ct3(),
//  .o_ds_driver_c_ct4(),
//  .o_ds_driver_c_ct5(),
//  .o_ds_driver_c_ct6(),
//  .o_ds_driver_c_ct7(),
  .o_ds_driver_en_driver(o_ds_driver_en_driver),
  .o_ds_driver_en_current(o_ds_driver_en_current),// to Pinmux
  .o_driver_en_sw(o_driver_en_sw),
  .o_stimu_en(o_stimu_en),// to Pinmux

  .stim_global_en 	(stim_global_en),

//  .o_driver_driver_a_en         (o_driver_driver_a_en),//(o_driver_driver_a_en[3:0]),
//  .o_drivera_isel0              (o_drivera_isel0),//(o_drivera_isel0[2:0]),
//  .o_drivera_isel1              (o_drivera_isel1),//(o_drivera_isel1[2:0]),
//.o_drivera_isel2              (),//(o_drivera_isel2[2:0]),
//.o_drivera_isel3              (),//(o_drivera_isel3[2:0]),
//.o_pullup_ci_driver_b         (),//  (o_pullup_ci_driver_b[23:0]),
//.o_sink_ci_driver_b           (),//  (o_sink_ci_driver_b[23:0]),
//.o_driver_ci_driver_b_en      (),//  (o_driver_ci_driver_b_en),
//.o_out_wave_ci_driverb_data   (),//  (o_out_wave_ci_driverb_data[7:0]),
//.o_out_wave_ds_driver_c_dac0  (),//(o_out_wave_ds_driver_c_dac0[7:0]),
//.o_out_wave_ds_driver_c_dac1  (),//(o_out_wave_ds_driver_c_dac1[7:0]),
//.o_out_wave_ds_driver_c_dac2  (),//(o_out_wave_ds_driver_c_dac2[7:0]),
//.o_out_wave_ds_driver_c_dac3  (),//(o_out_wave_ds_driver_c_dac3[7:0]),
//.o_out_wave_ds_driver_c_dac4  (),//(o_out_wave_ds_driver_c_dac4[7:0]),
//.o_out_wave_ds_driver_c_dac5  (),//(o_out_wave_ds_driver_c_dac5[7:0]),
//.o_out_wave_ds_driver_c_dac6  (),//(o_out_wave_ds_driver_c_dac6[7:0]),
//.o_out_wave_ds_driver_c_dac7  (),//(o_out_wave_ds_driver_c_dac7[7:0]),
//.o_source_ds_driver_c         (),//(o_source_ds_driver_c[7:0]),
//.o_sink_ds_driver_c           (),//(o_sink_ds_driver_c[7:0]),
//.o_ds_driver_c_ct0            (),//(o_ds_driver_c_ct0[2:0]),
//.o_ds_driver_c_ct1            (),//(o_ds_driver_c_ct1[2:0]),
//.o_ds_driver_c_ct2            (),//(o_ds_driver_c_ct2[2:0]),
//.o_ds_driver_c_ct3            (),//(o_ds_driver_c_ct3[2:0]),
//.o_ds_driver_c_ct4            (),//(o_ds_driver_c_ct4[2:0]),
//.o_ds_driver_c_ct5            (),//(o_ds_driver_c_ct5[2:0]),
//.o_ds_driver_c_ct6            (),//(o_ds_driver_c_ct6[2:0]),
//.o_ds_driver_c_ct7            (),//(o_ds_driver_c_ct7[2:0]),
//.o_ds_driver_en_driver_c      (),//(o_ds_driver_en_driver_c[7:0]),
//.o_ds_driver_en_current_c     (),//(o_ds_driver_en_current_c),
//.o_sw_pullup_driver_c         (),//(o_sw_pullup_driver_c[7:0]),
//.o_sw_pulldn_driver_c         (),//(o_sw_pulldn_driver_c[7:0]),
//.o_driver_en_sw_c             (),//(o_driver_en_sw_c),
  .o_wg_driver_interrupt        (wg_driver_interrupt),   
  .int_length_slct              (int_length_slct),

//.i_pclk                       (pclk),
//.i_presetn                    (presetn),
  .dds_clk                      (wave_gen_dds_clk),
  .i_pclk                       (wave_gen_pclk),
  .i_fclk                       (wave_gen_fclk),
  .i_presetn                    (wave_gen_presetn),
  .scan_mode                    (atpg_en),   //tri change
  .dds_mode                     (dds_mode),
  .dds_step_spi                 (dds_step_spi),

  //.lead_off_stop	  ({6'b0,lead_off_stop1,lead_off_stop}),
  .lead_off_stop	  (0),//(spi_leadoff.lead_off_stop),
 
  .spi_wg (spi_wg) 
//  .o_wg_driver_in_wave_addr     (wg_driver_in_wave_addr),
//  .o_wg_driver_source           (wg_driver_source),
//  .o_hlf_wave_cnt               (hlf_wave_cnt),
//  .o_period_num                 (period_num),
//  .i_wg_driver_en               (wg_driver_en),
//  .i_period_sel                 (period_sel),
////.i_wg_drivera_en              (wg_drivera_en),
////.i_wg_driverc_en              (wg_driverc_en),
//  .i_config_reg                 (config_reg),
//  .i_wg_driver_rest_t           (wg_driver_rest_t), 
//  .i_wg_driver_silent_t         (wg_driver_silent_t),
//  .i_wg_driver_rest_t1          (wg_driver_rest_t1), 
//  .i_wg_driver_silent_t1        (wg_driver_silent_t1),
//  .i_wg_driver_rest_t2          (wg_driver_rest_t2), 
//  .i_wg_driver_silent_t2        (wg_driver_silent_t2),
//  .i_wg_driver_delay_lim        (wg_driver_delay_lim),
//  .i_wg_driver_hlf_wave_prd     (wg_driver_hlf_wave_prd),
//  .i_wg_driver_neg_hlf_wave_prd (wg_driver_neg_hlf_wave_prd),
//  .i_wg_driver_hlf_wave_prd1    (wg_driver_hlf_wave_prd1),
//  .i_wg_driver_neg_hlf_wave_prd1(wg_driver_neg_hlf_wave_prd1),
//  .i_wg_driver_hlf_wave_prd2    (wg_driver_hlf_wave_prd2),
//  .i_wg_driver_neg_hlf_wave_prd2(wg_driver_neg_hlf_wave_prd2),     
//  .i_wg_driver_point_config     (wg_driver_point_config),
//
//  .i_wg_driver_alter_lim        (wg_driver_alter_lim),
//  .i_wg_driver_alter_silent_lim (wg_driver_alter_silent_lim),
////.i_wg_driver_clk_freq         (wg_driver_clk_freq),
//  .i_wg_driver_in_wave          (wg_driver_in_wave),
////.i_wg_driver_elec_no          (wg_driver_elec_no),
//  .i_wg_driver_isel             (wg_driver_isel),
////.i_wg_driver_sw_config        (wg_driver_sw_config),
//  .i_mult_elec                  (mult_elec),
////.i_wg_driver_interrupt        (wg_driver_interrupt)
//  .i_wg_driver_int_addr0        (wg_driver_int_addr0),
//  .i_wg_driver_int_addr1        (wg_driver_int_addr1),
//  .i_wg_driver_int_en           (wg_driver_int_en),
//  .i_addr0_int_clr              (addr0_int_clr),    
//  .i_addr1_int_clr              (addr1_int_clr),
//  .i_wg_driver_int_cnt          (wg_driver_int_cnt),
//  .o_wg_driver_int_sts          (wg_driver_int_sts)
);

// xin add lead_off
//lead_off_detector_wrapper #(
//  .NO_OF_WAVEGEN              (NO_OF_WAVEGEN) 
//)
//u_lead_off_detector_wrapper(
//
//  .spi_leadoff          (spi_leadoff),
//  .drive_en              (drive_en),            //bit0=1 is dac0, , bit1=1 is dac1 
//  .o_lead_off_int             (lead_off_int),   
//
//  .A2D_COMP0_7       ({6'b0,A2D_COMP2,A2D_COMP1}),   
//  .A2D_STIMU0_15     ({6'b0,spi_ana_if.A2D_ANA_GEN_REG[0][2:1]}), //A2D_COMP_OUT_STIMU0
//
//  .i_pclk                   (lead_off_pclk),
//  .i_presetn                (lead_off_presetn)
//);

temp_sar_ctrl
#(
  .WIDTH_VDAC(8)
)
u_temp_sar_ctrl
(
  .sysclk           (temp_sar_pclk),
  .presetn          (temp_sar_presetn),
  .scan_enable      (scan_en),
  .scan_mode        (atpg_en),
  .en_reg_sel       (en_reg_sel),   //0 is state machine ctrl; 1 is reg ctrl

  .busy_doing       (busy_doing),
  .sample_duration  (sample_duration),
  .stable_duration  (stable_duration),


  .a2d_tsc_comp_out_ch1   (spi_ana_if.A2D_ANA_GEN_REG[0][1]),   //from analog

  .tsc_comp_low_ch1       (tsc_comp_low_ch1),   //from spi_reg
  .d2a_vdac8b_din_ch1_in  (tsc_vdac8b_din_ch1), //from spi_reg
  .d2a_vdac8b_en_ch1_in   (tsc_vdac8b_en_ch1),  //from spi_reg`
  .d2a_tsc_comp_en_ch1_in (tsc_comp_en_ch1),    //from spi_reg`
  .d2a_tsc_en_ch1_in      (tsc_en_ch1),         //from spi turn on tsc module

  .int_length_slct(int_length_slct),
  .tsc_intr_en(tsc_intr_en),
  .tsc_intr_trans_sel(tsc_intr_trans_sel),
  .tsc_intr_sts_clr(tsc_intr_sts_clr_pulse),

  .o_tsc_intb    (o_tsc_intb),
  .o_tsc_intr_sts(tsc_intr_sts),  

  .VDAC_NOR               (VDAC_NOR),  //to spi_reg

  .d2a_vdac8b_din_ch1_out (d2a_tsc_vdac8b_din_ch1), //to pinmux
  .d2a_vdac8b_en_ch1_out  (d2a_tsc_vdac8b_en_ch1), //to pinmux
  .d2a_tsc_comp_en_ch1_out(d2a_tsc_comp_en_ch1), //to pinmux 
  .d2a_tsc_en_ch1_out     (d2a_tsc_en_ch1)  //to pinmux
  
);

apb_anac #(
.NO_OF_WAVEGEN        (NO_OF_WAVEGEN)
)
u_anac(
  .spi_anac          (spi_anac),
  .sysclk            (anac_pclk),
//  .scan_mode         (atpg_en),   //tri change
 // .scan_enable              (scan_en),   //tri change
  //.presetn                  (presetn),
  .presetn           (anac_presetn),
 
// ANA_COMP
  .ana_lvd_sts(ana_lvd_sts),
//ANA_COMP
  //i/p
//  .A2D_COMP0_7       ({6'b0,A2D_COMP2,A2D_COMP1}),   
//  .A2D_STIMU0_15     ({6'b0,spi_ana_if.A2D_ANA_GEN_REG[0][2:1]}), //A2D_COMP_OUT_STIMU0

//  .drive_en          (drive_en),            //bit0=1 is dac0, , bit1=1 is dac1 
  .o_anac_int        (anac_int)
);

nirs_ppg_wrapper #(
  .NO_OF_NIRS(NO_OF_NIRS)
) u_nirs_wrapper (
  .scan_en              (scan_en),
  .scan_mode            (atpg_en),
  .rst_n                (ppg_resetn),
  .clk_ana              (ana_clk_ppg),
  .clk_ppg              (clk_ppg),
  .clk_sys              (clk_sys_ppg),
  .clk_gate_bypass      (ppg_clk_gate_bypass),

  .LED_ON_IO            (NIRS_LED_ON),
  .int_length_slct      (int_length_slct),
  .INT_IO               (o_nirs_int),

  .ana_nirs_if          (ana_nirs_if),
  .spi_nirs_if          (spi_nirs_if)
);

endmodule
