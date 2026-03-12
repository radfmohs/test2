//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap ENS2  
// File name:    ens2_if.sv 
// Module Name : ENS2 Interface
// Description : 
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author          Description      
//------------------------------------------------------------------------------
// 0.1                                      Initial Rev 
//------------------------------------------------------------------------------

interface spi_otp #(
TRIM_NUMBER = 10,
SO=23,
OS=27
)();

wire [7:0] trim [TRIM_NUMBER-1 :0]; //trim from spi to otp
wire [7:0] trim_read [TRIM_NUMBER-1 :0];//trim value from otp to spi
wire [SO-1:0] so_ctrl;//spi to otp
wire [OS-1:0] os_ctrl;//otp to spi

modport master(
output trim, 
output so_ctrl,
input  trim_read, 
input  os_ctrl
);
modport slave (
input  trim,
input  so_ctrl,
output trim_read,
output os_ctrl

);

endinterface

interface spi_wg #(
NO_OF_WAVEGEN = 2

)();

  // wavegen
wire  [7:0]    i_wg_driver_in_wave_addr[NO_OF_WAVEGEN-1:0];
wire  [7:0]    i_wg_driver_ems_wave_addr[NO_OF_WAVEGEN-1:0];
wire  [1:0]    i_wg_driver_source[NO_OF_WAVEGEN-1:0];
//wire  [7:0]    i_hlf_wave_cnt[NO_OF_WAVEGEN-1:0];
wire  [1:0]    i_period_num[NO_OF_WAVEGEN-1:0];
wire           o_wg_driver_en[NO_OF_WAVEGEN-1:0];    
wire  [4:0]  	 o_period_sel[NO_OF_WAVEGEN-1:0];                  
wire  [7:0]    o_config_reg[NO_OF_WAVEGEN-1:0];
wire  [15:0]   o_wg_driver_rest_t[NO_OF_WAVEGEN-1:0];
wire  [31:0]   o_wg_driver_silent_t[NO_OF_WAVEGEN-1:0]; 
wire  [15:0]   o_wg_driver_rest_t1[NO_OF_WAVEGEN-1:0];
wire  [31:0]   o_wg_driver_silent_t1[NO_OF_WAVEGEN-1:0];   
wire  [15:0]   o_wg_driver_rest_t2[NO_OF_WAVEGEN-1:0];
wire  [31:0]   o_wg_driver_silent_t2[NO_OF_WAVEGEN-1:0]; 
wire  [15:0]   o_wg_driver_hlf_wave_prd[NO_OF_WAVEGEN-1:0]; 
wire  [15:0]   o_wg_driver_neg_hlf_wave_prd[NO_OF_WAVEGEN-1:0]; 
wire  [15:0]   o_wg_driver_hlf_wave_prd1[NO_OF_WAVEGEN-1:0]; 
wire  [15:0]   o_wg_driver_neg_hlf_wave_prd1[NO_OF_WAVEGEN-1:0];
wire  [15:0]   o_wg_driver_hlf_wave_prd2[NO_OF_WAVEGEN-1:0];
wire  [15:0]   o_wg_driver_neg_hlf_wave_prd2[NO_OF_WAVEGEN-1:0];
wire  [7:0]    o_reg_wg_driver_point_config[NO_OF_WAVEGEN-1:0];
wire  [15:0]   o_wg_driver_alter_lim[NO_OF_WAVEGEN-1:0];
wire  [15:0]   o_wg_driver_alter_silent_lim[NO_OF_WAVEGEN-1:0]; 
wire  [15:0]   o_wg_driver_alter_rest_lim[NO_OF_WAVEGEN-1:0]; 
wire  [15:0]    o_wg_driver_sw_config[NO_OF_WAVEGEN-1:0];
wire  [15:0]   o_wg_driver_delay_lim[NO_OF_WAVEGEN-1:0];
//wire  [2:0]    o_wg_driver_isel[NO_OF_WAVEGEN-1:0];
wire  	       o_mult_elec[NO_OF_WAVEGEN-1:0];
wire  [11:0]   o_wg_driver_in_wave[NO_OF_WAVEGEN-1:0];
wire  [7:0]    o_wg_driver_int_addr0[NO_OF_WAVEGEN-1:0];
wire  [7:0]    o_wg_driver_int_addr1[NO_OF_WAVEGEN-1:0];
wire           o_wg_driver_int_en[NO_OF_WAVEGEN-1:0] ;
wire           o_addr0_int_clr[NO_OF_WAVEGEN-1:0] ;   
wire           o_addr1_int_clr[NO_OF_WAVEGEN-1:0] ;     
wire  [7:0]    o_wg_driver_int_cnt[NO_OF_WAVEGEN-1:0];
wire  [1:0]    i_wg_driver_int_sts[NO_OF_WAVEGEN-1:0];
wire  [7:0]    o_pullba_ctrl[NO_OF_WAVEGEN-1:0];
wire  [17:0]   dirve[NO_OF_WAVEGEN-1:0];      
wire           global_en;
wire  [NO_OF_WAVEGEN-1:0]    stop_wavegen;
wire           o_no_of_num_slient_disable[NO_OF_WAVEGEN-1:0];
wire  [15:0]    o_no_of_num_slient_tar[NO_OF_WAVEGEN-1:0];

wire [2:0]     w_isel[NO_OF_WAVEGEN-1:0];

wire [7:0]     o_reg_wg_cal_addr[NO_OF_WAVEGEN-1:0];
wire [3:0]     o_data_scl[NO_OF_WAVEGEN-1:0];
wire [5:0]     o_ems_data_ctrl[NO_OF_WAVEGEN-1:0];
wire [7:0]     o_reg_wg_driver_neg_scale[NO_OF_WAVEGEN-1:0];
wire [7:0]     o_wg_driver_pos_scale[NO_OF_WAVEGEN-1:0];
wire [7:0]     o_reg_wg_driver_neg_offset[NO_OF_WAVEGEN-1:0];
wire [7:0]     o_reg_wg_driver_pos_offset[NO_OF_WAVEGEN-1:0];
wire [7:0]     alt_ems_cnt_tar[NO_OF_WAVEGEN-1:0];
wire [3:0]     data_scl[NO_OF_WAVEGEN-1:0];
wire [3:0]     ems_data_ctrl[NO_OF_WAVEGEN-1:0];
wire [7:0]     wg_driver_neg_scale[NO_OF_WAVEGEN-1:0];
wire [7:0]     wg_driver_pos_scale[NO_OF_WAVEGEN-1:0];
wire [7:0]     wg_driver_neg_offset[NO_OF_WAVEGEN-1:0];
wire [7:0]     wg_driver_pos_offset[NO_OF_WAVEGEN-1:0];


modport master(
  output o_wg_driver_en,          
  output o_period_sel,                  
  output o_config_reg,
  output o_wg_driver_rest_t, 
  output o_wg_driver_silent_t, 
  output o_wg_driver_rest_t1, 
  output o_wg_driver_silent_t1,   
  output o_wg_driver_rest_t2, 
  output o_wg_driver_silent_t2, 
  output o_wg_driver_hlf_wave_prd, 
  output o_wg_driver_neg_hlf_wave_prd, 
  output o_wg_driver_hlf_wave_prd1, 
  output o_wg_driver_neg_hlf_wave_prd1,
  output o_wg_driver_hlf_wave_prd2, 
  output o_wg_driver_neg_hlf_wave_prd2,
  output o_reg_wg_driver_point_config,
  output o_wg_driver_alter_lim, 
  output o_wg_driver_alter_silent_lim, 
  output o_wg_driver_alter_rest_lim,
  output o_wg_driver_delay_lim, 
  output o_wg_driver_sw_config, 
  output o_mult_elec,
  output o_wg_driver_in_wave,
  output o_wg_driver_int_addr0,
  output o_wg_driver_int_addr1,
  output o_wg_driver_int_en,   
  output o_addr0_int_clr,      
  output o_addr1_int_clr,      
  output o_wg_driver_int_cnt,
  output o_pullba_ctrl,
  output dirve,
  output global_en,
  output stop_wavegen,
  output o_no_of_num_slient_disable,
  output o_no_of_num_slient_tar,

  output o_reg_wg_cal_addr,
  output o_data_scl,
  output o_ems_data_ctrl,
  output o_reg_wg_driver_neg_scale,
  output o_wg_driver_pos_scale,
  output o_reg_wg_driver_neg_offset,
  output o_reg_wg_driver_pos_offset,
  output alt_ems_cnt_tar,
  
  input  data_scl,
  input  ems_data_ctrl,
  input  wg_driver_neg_scale,
  input  wg_driver_pos_scale,
  input  wg_driver_neg_offset,
  input  wg_driver_pos_offset,

  output w_isel,

  input i_wg_driver_in_wave_addr,
  input i_wg_driver_ems_wave_addr,
  input i_wg_driver_source,
//  input i_hlf_wave_cnt, 
  input i_period_num,
  input i_wg_driver_int_sts
);

modport slave (
  input o_wg_driver_en,          
  input o_period_sel,                  
  input o_config_reg,
  input o_wg_driver_rest_t, 
  input o_wg_driver_silent_t, 
  input o_wg_driver_rest_t1, 
  input o_wg_driver_silent_t1,   
  input o_wg_driver_rest_t2, 
  input o_wg_driver_silent_t2, 
  input o_wg_driver_hlf_wave_prd, 
  input o_wg_driver_neg_hlf_wave_prd, 
  input o_wg_driver_hlf_wave_prd1, 
  input o_wg_driver_neg_hlf_wave_prd1,
  input o_wg_driver_hlf_wave_prd2, 
  input o_wg_driver_neg_hlf_wave_prd2,
  input o_reg_wg_driver_point_config,
  input o_wg_driver_alter_lim, 
  input o_wg_driver_alter_silent_lim, 
  input o_wg_driver_alter_rest_lim,
  input o_wg_driver_delay_lim, 
  input o_wg_driver_sw_config, 
  input o_mult_elec,
  input o_wg_driver_in_wave,
  input o_wg_driver_int_addr0,
  input o_wg_driver_int_addr1,
  input o_wg_driver_int_en,   
  input o_addr0_int_clr,      
  input o_addr1_int_clr,      
  input o_wg_driver_int_cnt,
  input o_pullba_ctrl,
  input dirve,
  input global_en,
  input stop_wavegen,
  input o_no_of_num_slient_disable,
  input o_no_of_num_slient_tar,

  input o_reg_wg_cal_addr,
  input o_data_scl,
  input o_ems_data_ctrl,
  input o_reg_wg_driver_neg_scale,
  input o_wg_driver_pos_scale,
  input o_reg_wg_driver_neg_offset,
  input o_reg_wg_driver_pos_offset,
  input alt_ems_cnt_tar,

  input w_isel,

  output  data_scl,
  output  ems_data_ctrl,
  output  wg_driver_neg_scale,
  output  wg_driver_pos_scale,
  output  wg_driver_neg_offset,
  output  wg_driver_pos_offset,

  output i_wg_driver_in_wave_addr,
  output i_wg_driver_ems_wave_addr,
  output i_wg_driver_source,
//  output i_hlf_wave_cnt, 
  output i_period_num,
  output i_wg_driver_int_sts

);



endinterface


interface spi_anac #(
NO_OF_WAVEGEN = 2
)();

//I
wire          ana_lvd_intr_en;
//O
wire          ana_lvd_intr_pin;
////I
wire                        int_length_slct;
//wire [31:0]                 ana_stimu_ch_timer_TH[NO_OF_WAVEGEN-1 :0];	
//wire [31:0]                 ana_stimu_ch_counter_TH[NO_OF_WAVEGEN-1 :0];	
//wire [NO_OF_WAVEGEN-1 :0 ]  ana_comp_ch_intr_en;
//wire [NO_OF_WAVEGEN-1 :0 ]  ana_comp_ch_intr_trans_sel;
//wire [NO_OF_WAVEGEN-1 :0 ]  ana_comp_ch_intr_sts_clr;
//wire [NO_OF_WAVEGEN-1 :0 ]  ana_stimu_ch_intr_sts_clr;
//wire [NO_OF_WAVEGEN-1 :0]   anac_short_int_en;
//wire [NO_OF_WAVEGEN-1 :0]   anac_short_drive_en;
//wire                        anac_short_leadoff_en;
//wire [NO_OF_WAVEGEN-1 :0]   anac_int_pol;
//
////O
//wire [31:0]                 counter_th_cnt_dbg[NO_OF_WAVEGEN-1 :0];
//wire [NO_OF_WAVEGEN-1 :0]   ana_stimu_ch_intr_sts;
//wire [NO_OF_WAVEGEN-1 :0]   ana_comp_ch_intr_sts;

modport master(
output ana_lvd_intr_en,
output int_length_slct,
//output ana_stimu_ch_timer_TH,
//output ana_stimu_ch_counter_TH,
//output ana_comp_ch_intr_en,
//output ana_comp_ch_intr_trans_sel,
//output ana_comp_ch_intr_sts_clr,
//output ana_stimu_ch_intr_sts_clr,
//output anac_short_int_en,
//output anac_short_drive_en,
//output anac_short_leadoff_en,
//output anac_int_pol,

input ana_lvd_intr_pin
//input counter_th_cnt_dbg,
//input ana_stimu_ch_intr_sts,
//input ana_comp_ch_intr_sts

);



modport slave (
input ana_lvd_intr_en,
input int_length_slct,
//input ana_stimu_ch_timer_TH,
//input ana_stimu_ch_counter_TH,
//input ana_comp_ch_intr_en,
//input ana_comp_ch_intr_trans_sel,
//input ana_comp_ch_intr_sts_clr,
//input ana_stimu_ch_intr_sts_clr,
//input anac_short_int_en,
//input anac_short_drive_en,
//input anac_short_leadoff_en,
//input anac_int_pol,


output ana_lvd_intr_pin
//output counter_th_cnt_dbg,
//output ana_stimu_ch_intr_sts,
//output ana_comp_ch_intr_sts

);




endinterface



//interface spi_leadoff #(
//NO_OF_WAVEGEN = 8
//)();
//
////I
//wire [31:0]                 timer_cnt_tgt[NO_OF_WAVEGEN-1 :0];	
//wire [31:0]                 counter_th_tgt[NO_OF_WAVEGEN-1 :0];	
//wire [NO_OF_WAVEGEN-1 :0]   lead_off_stop_en;
//wire [NO_OF_WAVEGEN-1 :0 ]  lead_off_sts_clear;
//wire [NO_OF_WAVEGEN-1 :0 ]  dac_en_in;
//wire  			    sel_stim;
//wire [NO_OF_WAVEGEN-1 :0 ]  comp_low_en;
//wire                        int_length_slct;
//wire [NO_OF_WAVEGEN-1 :0]   lead_off_int_en;
//
//
////O
//wire [NO_OF_WAVEGEN-1 :0 ]  lead_off_stop;
//wire [NO_OF_WAVEGEN-1 :0 ]  lead_off_result;
//wire [31:0]                 lead_off_Counter_cnt_dac0_final_dbg [NO_OF_WAVEGEN-1 :0];
//wire [7:0]                 lead_off_Counter_cnt_dac0_dbg [NO_OF_WAVEGEN-1 :0];
//
//modport master(
////I
//output   timer_cnt_tgt,	
//output   counter_th_tgt,	
//output   lead_off_stop_en,
//output   lead_off_sts_clear,
//output   dac_en_in,
//output   sel_stim,
//output   comp_low_en,
//output   int_length_slct,
//output   lead_off_int_en,
//
//
////O
//input   lead_off_stop,
//input   lead_off_result,
//input   lead_off_Counter_cnt_dac0_final_dbg ,
//input   lead_off_Counter_cnt_dac0_dbg 
//
//);



//modport slave (
////I
//input   timer_cnt_tgt,	
//input   counter_th_tgt,	
//input   lead_off_stop_en,
//input   lead_off_sts_clear,
//input   dac_en_in,
//input   sel_stim,
//input   comp_low_en,
//input   int_length_slct,
//input   lead_off_int_en,
//
//
////O
//output   lead_off_stop,
//output   lead_off_result,
//output   lead_off_Counter_cnt_dac0_final_dbg ,
//output   lead_off_Counter_cnt_dac0_dbg 
//
//);
//
//
//
//
//endinterface






// Interface between PINMUX and ANA_WRAPPER
interface pinmux_if #(
  TRIM_NUMBER = 8,
  EN_REG_NUMBER = 1
//SPARE_NUMBER  = 3
) ();

//wire              [7:0] D2A_TRIM_SIG_SPARE [SPARE_NUMBER-1:0];
wire              [7:0] D2A_ANA_ENABLE_REG [EN_REG_NUMBER-1:0];
wire  [TRIM_NUMBER-1:0] D2A_ATM;                        //from pinmux to ana
//wire            [2:0] ENCODED_ATM;                    //from pinmux to ana
wire              [7:0] D2A_TRIM_SIG [TRIM_NUMBER-1:0]; //from pinmux to ana 
//wire            [1:0] A2D_TRIM_SIG [TRIM_NUMBER-1:0]; //from ana to pinmux 
wire              [7:0] d2a_tsc_vdac8b_din_ch1; 
wire                    d2a_tsc_vdac8b_en_ch1;  
wire                    d2a_tsc_comp_en_ch1;    
wire                    d2a_tsc_en_ch1;       
wire                    D2A_ANA_OUT_SEL1;
wire                    D2A_ANA_OUT_SEL2;
wire                    D2A_ANA_OUT_SEL3;
wire                    D2A_ANA_OUT_SEL4;
wire                    D2A_ANA_OUT_SEL5;
wire                    D2A_ANA_OUT_SEL6;
wire                    D2A_ANA_OUT_SEL7;  

modport A2D (
//input  D2A_TRIM_SIG_SPARE,
  input  D2A_ANA_ENABLE_REG,
//input  ENCODED_ATM,
  input  D2A_ATM,
  input  D2A_TRIM_SIG,
//output A2D_TRIM_SIG
  input  d2a_tsc_vdac8b_din_ch1,
  input  d2a_tsc_vdac8b_en_ch1,
  input  d2a_tsc_comp_en_ch1,
  input  d2a_tsc_en_ch1,

  input   D2A_ANA_OUT_SEL1,
  input   D2A_ANA_OUT_SEL2,
  input   D2A_ANA_OUT_SEL3,
  input   D2A_ANA_OUT_SEL4,
  input   D2A_ANA_OUT_SEL5,
  input   D2A_ANA_OUT_SEL6,
  input   D2A_ANA_OUT_SEL7
);

modport D2A (
//output D2A_TRIM_SIG_SPARE,
  output D2A_ANA_ENABLE_REG,
//output ENCODED_ATM,
  output D2A_ATM,
  output D2A_TRIM_SIG,
//input  A2D_TRIM_SIG
  output d2a_tsc_vdac8b_din_ch1,
  output d2a_tsc_vdac8b_en_ch1,
  output d2a_tsc_comp_en_ch1,
  output d2a_tsc_en_ch1,

  output  D2A_ANA_OUT_SEL1,
  output  D2A_ANA_OUT_SEL2,
  output  D2A_ANA_OUT_SEL3,
  output  D2A_ANA_OUT_SEL4,
  output  D2A_ANA_OUT_SEL5,
  output  D2A_ANA_OUT_SEL6,
  output  D2A_ANA_OUT_SEL7
);
endinterface


// Interface between SPI and ANA_WRAPPER
interface spi_ana_if #(
  REG_NUMBER = 10
) ();

//wire       ATM_HC_SEL;
wire [7:0] D2A_ANA_GEN_REG [REG_NUMBER-1:0];
wire [7:0] A2D_ANA_GEN_REG [1:0];

modport spi (
//output ATM_HC_SEL,
  output D2A_ANA_GEN_REG,
  input  A2D_ANA_GEN_REG
);

modport ana (
//input  ATM_HC_SEL,
  input  D2A_ANA_GEN_REG,
  output A2D_ANA_GEN_REG
);
endinterface


// Interface between SPI and PINMUX
interface spi_pinmux_if #(
  EN_REG_NUMBER = 4
) ();

wire [7:0] ANA_ENABLE_REG [EN_REG_NUMBER-1:0];
wire       ATM_HC_SEL;
wire       ANA_BIST_HC_SEL;
wire       INT_LEVEL_SEL;

modport spi (
  output ANA_ENABLE_REG,
  output ATM_HC_SEL,
  output INT_LEVEL_SEL,
  output ANA_BIST_HC_SEL
);

modport pinmux(
  input  ANA_ENABLE_REG,
  input  ATM_HC_SEL,
  input  INT_LEVEL_SEL,
  input  ANA_BIST_HC_SEL
);
endinterface

// Interface between ANA and NIRS
interface ana_nirs_if
();

wire        D2A_NIRS_RESET_SW;
wire        D2A_NIRS_ILED_SW;
wire        D2A_NIRS_IIN_SW;
wire  [8:0] D2A_NIRS_IDAC;
wire  [1:0] D2A_NIRS_RATIO;
wire        A2D_NIRS_IREFCOARSE;
wire        A2D_NIRS_IREFFINE;

modport nirs (
  output    D2A_NIRS_RESET_SW,
  output    D2A_NIRS_ILED_SW,
  output    D2A_NIRS_IIN_SW,
  output    D2A_NIRS_IDAC,
  output    D2A_NIRS_RATIO,
  input     A2D_NIRS_IREFCOARSE,
  input     A2D_NIRS_IREFFINE
);

modport ana (
  input     D2A_NIRS_RESET_SW,
  input     D2A_NIRS_ILED_SW,
  input     D2A_NIRS_IIN_SW,
  input     D2A_NIRS_IDAC,
  input     D2A_NIRS_RATIO,
  output    A2D_NIRS_IREFCOARSE,
  output    A2D_NIRS_IREFFINE
);
endinterface

// Interface between SPI and NIRS
interface spi_nirs_if
();

  wire  [7:0] NIRS_CTRL[7:0];
  wire  [7:0] NIRS_DOUT[7:0];

modport nirs (
  input   NIRS_CTRL,
  output  NIRS_DOUT
);

modport spi (
  output  NIRS_CTRL,
  input   NIRS_DOUT
);
endinterface

