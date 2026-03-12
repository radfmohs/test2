//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//
// Module Name : spi_top
// Description : top module which has  spi slave  controller and register block 
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author
//------------------------------------------------------------------------------
// 0.1          7/09/2022  Jayanthi 
// Initial Rev
//------------------------------------------------------------------------------

`timescale 1ns/1ps

module spi_top#(
  parameter ADDR_WIDTH =8,
  parameter DATA_WIDTH =8,
  parameter HLF_WV_NO_PTS = 6, 
  parameter OUT_NO_BITS = 12,
        parameter addr_width = 8,
        parameter data_width = 8,

        parameter NO_OF_WAVEGEN=8)
(
//  spi_leadoff.master         spi_leadoff,
  spi_anac.master         spi_anac,
  spi_otp.master          spi_otp,
  spi_wg.master           spi_wg,
  spi_ana_if.spi          spi_ana_if,
  spi_pinmux_if.spi       spi_pinmux_if,
  spi_nirs_if.spi         spi_nirs_if,



  input		      SCANMODE,
  input    	    i_scanclk,
  input         i_rst_n,
  input         iopad_cpha,
  input         iopad_cpol,
  input         DAISY_IN_Y,
//        input         i_sys_clk,
  input         i_sclk,
  input         i_cs_n,
  input         i_mosi,
  output        o_miso,

//bps imeas
        input  wire[31:0]   imeas_chdata[15:0],
        input               i_imeas_done,
        output  wire        reset_cmd,
        output  wire        start_cmd,
        output  wire        stop_cmd,
        //output  wire        wakeup_cmd,
        //output  wire        standby_cmd,
        output wire         single_shot,
        output wire [3:0]       iclk_div,
        output wire             imeas_en,
        output wire [7:0]       imeas_reg_0,
        output wire [15:0]       imeas_en_chn,
        output wire [3:0]       DR,
        output wire             imeas_adc_inv,
        output wire             cic_rst,
        output wire [15:0]      stable_time,
//====================

        output wire 	  ana_lvd_sts,

        input wire  [4:0] i_channel_max,
        //input wire        daisy_in,
 

//        output wire [7:0] ana_stimu_int1_num,
//        output wire [7:0] ana_stimu_int2_num,

 
    //    output wire       o_comp_ch1_intr_pin,
     //   output wire       o_comp_ch2_intr_pin,
       // input wire   [7:0]    A2D_ANA_GEN_REG_0,
       // input wire   [7:0]    A2D_SPARE_RO_REG_0,

output wire         ppg_dis,           //ppg disble 
output wire  [1:0]  ppg_clk_div,       // ppg clock divider
output wire         ana_ppgclk_inv,   // ana ppg clock 
output wire         ppg_clk50duty,            
output  wire 	    ppg_rst_reg,
  
   output wire o_clk_sel,


   //input  wire    A2D_COMP1,   
   //input  wire    A2D_COMP2,   
   input  wire [NO_OF_WAVEGEN-1:0]   A2D_COMP0_7,   


   output wire otp_rst_reg,
   output wire dig_rst_reg,
   output wire lead_off_rst,
   output wire   lead_off_en,
   //output wire   dly_en,
//   output wire [OUT_NO_BITS-1 : 0]  TH_H,
//   output wire [OUT_NO_BITS-1 : 0]  TH_L,
/*
  output wire [31:0] timer_cnt_tgt          ,
  output wire [31:0] timer_cnt_tgt1         ,
  output wire [31:0] counter_th_tgt        ,
  output wire [31:0] counter_th_tgt1       ,
*/
   //output wire [31 : 0]  measure_dly_tgt,
   //output wire [31 : 0]  measure_dly_tgt1,
   //output wire [1 : 0]   check_mode,   //00 is h/l both, 01 is high only, 10 is low only, 11 is h/l both
//---------------------------------


  //output  wire         fclk_dynen,
  //output  wire  [1:0]  pclk_div,
  output  wire  [2:0]  pclk_div,
        output wire  o_int_clk_out,
  output    wave_gen_dis,
  output    wave_gen_rst,
 //TRIM values
//        input wire [7:0] d2a_trim0_from_otp, // trim value to analog,only read by spi bus
//        input wire [7:0] d2a_trim1_from_otp, 
//        input wire [7:0] d2a_trim2_from_otp,
//        input wire [7:0] d2a_trim3_from_otp,
//        input wire [7:0] d2a_trim4_from_otp,
//        input wire [7:0] d2a_trim5_from_otp,
//        input wire [7:0] d2a_trim6_from_otp,
//        input wire [7:0] d2a_trim7_from_otp,
//        input wire [7:0] d2a_trim8_from_otp,
//        input wire [7:0] d2a_trim9_from_otp,

//        input wire [7:0] d2a_spi_alt_fun_from_otp,
//        input wire [7:0] d2a_trim8_from_otp,       //spare registers
//        input wire [7:0] d2a_trim9_from_otp,       //spare registers
//
//        output wire  [7:0] trim_tag_reg,
//        output wire  [7:0] d2a_trim1_to_otp,
//        output wire  [7:0] d2a_trim2_to_otp,
//        output wire  [7:0] d2a_trim3_to_otp,
//        output wire  [7:0] d2a_trim4_to_otp,
//        output wire  [7:0] d2a_trim5_to_otp,
//        output wire  [7:0] d2a_trim6_to_otp,
//        output wire  [7:0] d2a_alt_fun_to_otp,
//        output wire  [7:0] d2a_trim8_to_otp,
//        output wire  [7:0] d2a_trim9_to_otp,
  
//        input wire [7:0] otp_to_ana_trim7,
//        input wire       OTP_Reset_Done,
//     	input wire  [15:0]    DEBUG_otp,
//        input wire      otp_BUSY, 

       //trim 
//       output wire  [7:0] analog_trim_flg,
//       output wire  [4:0] ana_bgh_vtrim  ,
//       output wire  [6:0] ana_bgh_ctrl   ,
//       output wire  [4:0] ana_bgl_vtrim  ,
//       output wire  [6:0] ana_bgl_ctrl   ,
//       output wire  [1:0] ana_ldo1v5_trim,
//       output wire  [1:0] ana_dacbuf_trim,
//       output wire  [5:0] ana_osc_trim   ,
//       output wire        otp_unlock   , 
//       output wire        otp_spi_wr,
//       input  wire        wr_done_flg    ,


//       input  wire analog_test_mode,
//       input  wire [3:0] atm_mode,
//       input  wire [13:0] atm_data,
//       input  wire unlock_gpio,

    //output to always on    
     //   output         fclk_dynen_otp,
     //   output         dc_dc_en_otp,
//        output [2:0]   dc_clk_div_otp, 

      output  wire   pmuenable,            // pmu enable
  output  wire   hresetreq,            // system reset request
  output  wire   sleepdeep,            // system enters deep-sleep state
  output  wire   otp_dpstb_en,        // otp deep power down standby mode enable 
  output  wire   anac_clock_en,
  output  wire   temp_sar_clock_dis,
  output  wire   anac_reset,
  output  wire   temp_sar_reset,

  output  wire [7:0]  en_reg_sel,
  output  wire [7:0]  tsc_vdac8b_din_ch1,
  output  wire        tsc_comp_low_ch1,
  output  wire        tsc_vdac8b_en_ch1,
  output  wire        tsc_comp_en_ch1,
  output  wire        tsc_en_ch1,
  output  reg  [7:0]  sample_duration,
  output  reg [11:0]  stable_duration,
  input   wire        busy_doing,
  input   wire [7:0] VDAC_NOR,


  output  wire         o_imeas_intr_clr,

  output  wire         tsc_intr_en, 
  output  wire         tsc_intr_trans_sel,
  output  wire         tsc_intr_sts_clr,
  input   wire 	       tsc_intr_sts,

  output  wire [15:0]  notch_filter_bypass,
  output  wire [15:0]  lpf_filter_bypass,
  output  wire [15:0]  hpf_filter_bypass,
//  output  wire [2:0]   filter_seq,
  output  wire [1:0]   eeg_int_en,
  output  wire         eeg_int_clr,
  input   wire         eeg_int_sts,
  output  wire [15:0]  cic_data_ignore_tar,
  output  wire [17:0]  lpf_coeff_data_o[31:0],
  output  wire [19:0]  notch_coeff_data_o[41:0],
  output  wire [23:0]  hpf_coeff_data_o,

    //    output  wire   fclk_sleep_en,
  output  wire      int_length_slct, 
  //gpio
  output wire [7:0] gpio_pu_ctrl,
  output wire [7:0] gpio_pd_ctrl,
  output wire [2:0] gpio_sr_pdrv0_1_ctrl,
  output wire [3:0] gpio_comp_out_ctrl

//analog register outputs

//Analog 
//output  wire [7:0] o_D2A_ANA_GEN_REG_0,
//output  wire [7:0] o_D2A_ANA_GEN_REG_1,
//output  wire [7:0] o_D2A_ANA_GEN_REG_2,
//output  wire [7:0] o_D2A_ANA_GEN_REG_3,
//output  wire [7:0] o_D2A_ANA_GEN_REG_4,
//output  wire [7:0] o_D2A_ANA_GEN_REG_5,
//output  wire [7:0] o_D2A_ANA_GEN_REG_6,
//output  wire [7:0] o_D2A_ANA_GEN_REG_7,
//output  wire [7:0] o_D2A_ANA_GEN_REG_8,
//output  wire [7:0] o_D2A_ANA_GEN_REG_9,
//output  wire [7:0] o_D2A_ANA_GEN_REG_A,
//output  wire [7:0] o_D2A_ANA_GEN_REG_B,
//output  wire [7:0] o_D2A_ANA_GEN_REG_C,
//output  wire [7:0] o_D2A_ANA_GEN_REG_D,
//output  wire [7:0] o_D2A_ANA_GEN_REG_E,
//output  wire [7:0] o_D2A_ANA_GEN_REG_F,
//output  wire [7:0] o_D2A_ANA_GEN_REG_10,
//output  wire [7:0] o_D2A_ANA_GEN_REG_11,
//output  wire [7:0] o_D2A_ANA_GEN_REG_12


/*
 output  wire		o_D2A_LVD_EN,
 output  wire 		o_D2A_CLDO2P4_EN,
 output  wire [4:0]	o_D2A_LVD_TRIM,
 output  wire 		o_D2A_OSC2MHZEN,
 output  wire 		o_D2A_SC_DOUBLER_EN,
 output  wire 		o_D2A_DRIVERA_AMP_EN_CH1,
 output  wire		o_D2A_DRIVERA_SOURCEA_CH1,
 output  wire		o_D2A_DRIVERA_SOURCEB_CH1,
 output  wire		o_D2A_DRIVERA_PULLDA_CH1,
 output  wire 		o_D2A_DRIVERA_PULLDB_CH1,
 output  wire [4:0]	o_D2A_DRIVERA_CS_RTRIM_CH1,
 output  wire		o_D2A_COMP_EN_CH1,
 output  wire		o_D2A_IDAC_EN_CH1,
 output  wire [11:0]	o_D2A_IDAC_DIN_CH1,
 output  wire 		o_D2A_VDAC_EN_CH1,
 output  wire [11:0]	o_D2A_VDAC_DIN_CH1,
 output  wire 		o_D2A_DRIVERA_AMP_EN_CH2,
 output  wire 		o_D2A_DRIVERA_SOURCEA_CH2,
 output  wire 		o_D2A_DRIVERA_SOURCEB_CH2,
 output  wire		o_D2A_DRIVERA_PULLDA_CH2,
 output  wire		o_D2A_DRIVERA_PULLDB_CH2,
 output  wire 		o_D2A_COMP_EN_CH2,
 output  wire 		o_D2A_IDAC_EN_CH2,
 output  wire [11:0]	o_D2A_IDAC_DIN_CH2,	
 output  wire 		o_D2A_VDAC_EN_CH2,
 output  wire [11:0]	o_D2A_VDAC_DIN_CH2,
 output  wire [3:0] 	o_D2A_ANA_BIST
*/

 
);



         wire        daisy_in;
         assign        daisy_in = DAISY_IN_Y;

//for testing
//assign rd_cmd_ind = 1'b0;
//assign first_neg_sclk = 1'b0;
//assign reset_cmd  = 0;
//assign otp_unlock = 0;
//assign daisy_in = 1'b1;

//parameter addr_width = 8;
//parameter data_width = 8;

//internal signals

wire [addr_width-1:0] addr;
wire                   wr;
wire                   rd;
wire                  wavegen_wr;
wire                  wavegen_rd;
wire                  wavegen_cmd_reg;
wire [data_width-1:0] wr_data;
wire [data_width-1:0] rd_data;
//wire  addr_vld_for_int_clr;
//wire burst_cmd;
//wire [addr_width-1:0] pre_addr;

//assign i_channel_max = 5'd8; 
wire int_clk = SCANMODE ? i_scanclk : i_sclk;

//scl selction for cpho,cpol combination

//wire iopad_cpol;
wire o_sclk;
wire i_sclk_inv;

wire sclk_latch_in;
wire sclk_latch_out;

//wire sclk_latch_in_tmp;
wire sclk_latch_out_tmp;

wire daisy_en;
wire [1:0]  mode;

//assign iopad_cpha=1'b0;  //need to be connected to the external pin
//assign iopad_cpol=1'b0;  //need to be connented to the external pin

//later move to clk_ctrl
spi_cpha_cpol_slct u_spi_cpha_cpol_slct(
.iopad_cpha(iopad_cpha),
.iopad_cpol(iopad_cpol),
.i_sclk(int_clk),  //(i_sclk),// int_clk
.o_sclk_latch_in(sclk_latch_in),
.o_sclk_latch_out(sclk_latch_out_tmp)
);

//assign sclk_latch_in =  SCANMODE ? int_clk : sclk_latch_in_tmp;
assign sclk_latch_out = SCANMODE ? int_clk : sclk_latch_out_tmp;

/*
assign i_sclk_inv = ~i_sclk;
//assign o_sclk = ~(iopad_cpha ^ iopad_cpol) ? i_sclk : i_sclk_inv;
assign o_sclk = ~(1 ^ 1) ? i_sclk_inv : i_sclk;


wire sclk_latch_in;
assign sclk_latch_in= (1^1) ? o_sclk : ~o_sclk;

//assign sclk_latch_in   = ~o_sclk;


//assign sclk_true = o_sclk;
wire sclk_latch_out ;
assign sclk_latch_out =(1^1) ? ~o_sclk : o_sclk;
//assign sclk_latch_out  = o_sclk;
*/



spi_slave_controller
spi_slv_ctrl_u (
  .i_rst_n       (i_rst_n),
//  .i_sclk        (int_clk),    //original for ENS1-P4     //clk for spi_slave 
//  .i_sclk(o_sclk),

//  .i_sclk(sclk_true),
//  .i_sclk_neg(sclk_neg_edge),


   .i_sclk_neg (sclk_latch_in),
   .i_sclk     (sclk_latch_out),
   .cpha       (iopad_cpha),  
  .imeas_chdata(imeas_chdata),     // Thanh added
  .i_channel_max(i_channel_max),
  .daisy_in      (daisy_in),
  .daisy_en      (daisy_en),
  .mode          (mode), 
 // .atpg_en	 (SCANMODE),
  .i_cs_n        (i_cs_n),
  .i_mosi        (i_mosi),
  .i_rd_data     (rd_data),
  .o_miso        (o_miso),
  .o_addr        (addr),
  //.o_addr_vld_for_int_clr(addr_vld_for_int_clr),
  .o_wr          (wr),
  .o_rd          (rd),
  .wavegen_cmd_reg(wavegen_cmd_reg),
  .o_wavegen_wr  (wavegen_wr),
  .o_wavegen_rd  (wavegen_rd),
  .o_wr_data     (wr_data),
  .o_imeas_intr_clr (o_imeas_intr_clr)
  
  //.burst_cmd_reg   (burst_cmd),
//  .o_pre_addr      (pre_addr)
);

defparam spi_slv_ctrl_u.addr_width = addr_width;
defparam spi_slv_ctrl_u.data_width = data_width;

spi_reg #(

    .ADDR_WIDTH		(ADDR_WIDTH),
    .DATA_WIDTH             (DATA_WIDTH),
    .HLF_WV_NO_PTS		(HLF_WV_NO_PTS),
    .NO_OF_WAVEGEN          (NO_OF_WAVEGEN),
    .OUT_NO_BITS		(OUT_NO_BITS)
)
spi_reg_u (
//  .spi_leadoff(spi_leadoff),
  .spi_anac(spi_anac),
  .spi_otp(spi_otp),
  .spi_wg (spi_wg),
  .spi_ana_if(spi_ana_if),
  .spi_pinmux_if(spi_pinmux_if),
  .spi_nirs_if(spi_nirs_if),
  .i_clk(int_clk),            //clk for reg block same as sclk 
  .i_rst_n(i_rst_n),

  .atpg_en(SCANMODE),

  .i_addr(addr),
  .i_wr(wr),
  .i_rd(rd),
  .wavegen_cmd_reg(wavegen_cmd_reg),
  .i_wavegen_wr(wavegen_wr),
  .i_wavegen_rd(wavegen_rd),
  .i_wr_data(wr_data),
  .o_rd_data(rd_data),
//        .i_addr_vld_for_int_clr(addr_vld_for_int_clr),

       // .i_burst_cmd   (burst_cmd),
       // .i_pre_addr    (pre_addr),

//imeas bps
  .imeas_chdata(imeas_chdata),

        .reset_cmd(reset_cmd),
        .start_cmd(start_cmd),
        .stop_cmd(stop_cmd),
        //.wakeup_cmd(wakeup_cmd),
        //.standby_cmd(standby_cmd),
        .single_shot(single_shot),
        .iclk_div(iclk_div),
        .imeas_en(imeas_en),
        .imeas_reg_0(imeas_reg_0),
        .imeas_en_chn(imeas_en_chn),
        .DR(DR),
        .daisy_en(daisy_en),
        .mode(mode),
        .imeas_adc_inv(imeas_adc_inv),
        .cic_rst(cic_rst),
        .stable_time(stable_time),
//==========================
//  .filter_seq(filter_seq),
  .notch_filter_bypass(notch_filter_bypass),
  .lpf_filter_bypass(lpf_filter_bypass),
  .hpf_filter_bypass(hpf_filter_bypass),
  .eeg_int_en(eeg_int_en),
  .eeg_int_clr(eeg_int_clr),
  .eeg_int_sts(eeg_int_sts),
  .cic_data_ignore_tar(cic_data_ignore_tar),
  .lpf_coeff_data_o(lpf_coeff_data_o),
  .notch_coeff_data_o(notch_coeff_data_o),
  .hpf_coeff_data_o(hpf_coeff_data_o),

///----------config----	
      ///clk
  //.o_fclk_dynen(fclk_dynen),
  .o_pclk_div(pclk_div),
        .o_int_clk_out(o_int_clk_out),
  .o_wave_gen_dis(wave_gen_dis),
  .o_wave_gen_rst(wave_gen_rst),
        //.o_always_on_spi_write(o_always_on_spi_write),

  .tsc_intr_en(tsc_intr_en),
  .tsc_intr_trans_sel(tsc_intr_trans_sel),
  .tsc_intr_sts_clr(tsc_intr_sts_clr),
  .tsc_intr_sts(tsc_intr_sts),  
       //PMU
  .o_pmuenable(pmuenable),            // pmu enable
  .o_hresetreq(hresetreq),            // system reset request
  .o_sleepdeep(sleepdeep),            // system enters deep-sleep state
  .o_otp_dpstb_en(otp_dpstb_en),        // otp deep power down standby mode enable
  .anac_clock_en(anac_clock_en),
  .temp_sar_clock_dis(temp_sar_clock_dis),

        .ppg_dis(ppg_dis),           //ppg disble 
   	.ppg_clk_div(ppg_clk_div),       // ppg clock divider
        .ana_ppgclk_inv(ana_ppgclk_inv),   // ana ppg clock 
        .ppg_clk50duty(ppg_clk50duty),            
 	.ppg_rst_reg(ppg_rst_reg),

  .anac_reset(anac_reset),
  .temp_sar_reset(temp_sar_reset),
  .en_reg_sel(en_reg_sel),
  .tsc_vdac8b_din_ch1(tsc_vdac8b_din_ch1),
  .tsc_comp_low_ch1(tsc_comp_low_ch1),
  .tsc_vdac8b_en_ch1(tsc_vdac8b_en_ch1),
  .tsc_comp_en_ch1(tsc_comp_en_ch1),
  .tsc_en_ch1(tsc_en_ch1),
  .sample_duration(sample_duration),
  .stable_duration(stable_duration),
  .busy_doing(busy_doing),
  .VDAC_NOR(VDAC_NOR),

    //    .o_fclk_sleep_en(fclk_sleep_en),
   .int_length_slct         (int_length_slct),

         .ana_lvd_sts               (ana_lvd_sts),	
         

     .o_clk_sel(o_clk_sel),
     .otp_rst_reg(otp_rst_reg),
     .dig_rst_reg(dig_rst_reg),


   //.lead_off_Counter_cnt_dac0_final_dbg(lead_off_Counter_cnt_dac0_final_dbg),
   //.lead_off_Counter_cnt_dac1_final_dbg(lead_off_Counter_cnt_dac1_final_dbg),

//-----------------------------------
//lead_off
//------------------------------------
  //.lead_off_cnt_dac0_dbg  (lead_off_cnt_dac0_dbg),
  //.lead_off_cnt_dac1_dbg  (lead_off_cnt_dac1_dbg),
  //.lead_off_Counter_cnt_dac0_dbg  (lead_off_Counter_cnt_dac0_dbg),
  //.lead_off_Counter_cnt_dac1_dbg  (lead_off_Counter_cnt_dac1_dbg),

     .lead_off_rst(lead_off_rst),
     .lead_off_en(lead_off_en),
   //.timer_cnt_tgt  (timer_cnt_tgt)        ,
   //.timer_cnt_tgt1 (timer_cnt_tgt1)       ,
   //.counter_th_tgt (counter_th_tgt)       ,
   //.counter_th_tgt1(counter_th_tgt1)       ,
     //.sel_stim(sel_stim),
     //.lead_off_sts_clear(lead_off_sts_clear),   
     //.lead_off1_sts_clear(lead_off1_sts_clear),   
     //.dac_en(dac_en),    //bit0=1 is dac0, , bit1=1 is dac1 
     //.comp_reverse(comp_reverse),
	.A2D_COMP0_7(A2D_COMP0_7),
     //.A2D_COMP1(A2D_COMP1),   
     //.A2D_COMP2(A2D_COMP2),   
     //.lead_off_result(lead_off_result),   
     //.lead_off_result1(lead_off_result1),   
     //.lead_off_int_en(lead_off_int_en),
     //.lead_off_stop_en(lead_off_stop_en),
     //.lead_off_stop1_en(lead_off_stop1_en),
     //.comp_low_ch0(comp_low_ch0),
     //.comp_low_ch1(comp_low_ch1),

//----GPIO-------
  .gpio_pu_ctrl(gpio_pu_ctrl),	
  .gpio_pd_ctrl(gpio_pd_ctrl),
  .gpio_sr_pdrv0_1_ctrl(gpio_sr_pdrv0_1_ctrl),
  .gpio_comp_out_ctrl(gpio_comp_out_ctrl)

//-------Analog Register Output----------
      //.o_D2A_ANA_GEN_REG_0	(o_D2A_ANA_GEN_REG_0),
      //.o_D2A_ANA_GEN_REG_1	(o_D2A_ANA_GEN_REG_1),
      //.o_D2A_ANA_GEN_REG_2	(o_D2A_ANA_GEN_REG_2),
      //.o_D2A_ANA_GEN_REG_3	(o_D2A_ANA_GEN_REG_3),
      //.o_D2A_ANA_GEN_REG_4	(o_D2A_ANA_GEN_REG_4),
      //.o_D2A_ANA_GEN_REG_5	(o_D2A_ANA_GEN_REG_5),
      //.o_D2A_ANA_GEN_REG_6	(o_D2A_ANA_GEN_REG_6),
      //.o_D2A_ANA_GEN_REG_7	(o_D2A_ANA_GEN_REG_7),
      //.o_D2A_ANA_GEN_REG_8	(o_D2A_ANA_GEN_REG_8),
      //.o_D2A_ANA_GEN_REG_9	(o_D2A_ANA_GEN_REG_9),
      //.o_D2A_ANA_GEN_REG_A	(o_D2A_ANA_GEN_REG_A),
      //.o_D2A_ANA_GEN_REG_B	(o_D2A_ANA_GEN_REG_B),
      //.o_D2A_ANA_GEN_REG_C	(o_D2A_ANA_GEN_REG_C),
      //.o_D2A_ANA_GEN_REG_D	(o_D2A_ANA_GEN_REG_D),
      //.o_D2A_ANA_GEN_REG_E	(o_D2A_ANA_GEN_REG_E),
      //.o_D2A_ANA_GEN_REG_F	(o_D2A_ANA_GEN_REG_F),
      //.o_D2A_ANA_GEN_REG_10	(o_D2A_ANA_GEN_REG_10),
      //.o_D2A_ANA_GEN_REG_11	(o_D2A_ANA_GEN_REG_11),
      //.o_D2A_ANA_GEN_REG_12	(o_D2A_ANA_GEN_REG_12)





      /*
        .o_D2A_LVD_EN		(o_D2A_LVD_EN),
    .o_D2A_CLDO2P4_EN	(o_D2A_CLDO2P4_EN),
  .o_D2A_LVD_TRIM		(o_D2A_LVD_TRIM),
  .o_D2A_OSC2MHZEN	(o_D2A_OSC2MHZEN),
   .o_D2A_SC_DOUBLER_EN	(o_D2A_SC_DOUBLER_EN),
  .o_D2A_DRIVERA_AMP_EN_CH1(o_D2A_DRIVERA_AMP_EN_CH1),
   .o_D2A_DRIVERA_SOURCEA_CH1(o_D2A_DRIVERA_SOURCEA_CH1),
   .o_D2A_DRIVERA_SOURCEB_CH1(o_D2A_DRIVERA_SOURCEB_CH1),
   .o_D2A_DRIVERA_PULLDA_CH1(o_D2A_DRIVERA_PULLDA_CH1),
  .o_D2A_DRIVERA_PULLDB_CH1(o_D2A_DRIVERA_PULLDB_CH1),
  .o_D2A_DRIVERA_CS_RTRIM_CH1(o_D2A_DRIVERA_CS_RTRIM_CH1),
  .o_D2A_COMP_EN_CH1	(o_D2A_COMP_EN_CH1),
  .o_D2A_IDAC_EN_CH1	(o_D2A_IDAC_EN_CH1),
  .o_D2A_IDAC_DIN_CH1	(o_D2A_IDAC_DIN_CH1),
  .o_D2A_VDAC_EN_CH1	(o_D2A_VDAC_EN_CH1),
  .o_D2A_VDAC_DIN_CH1	(o_D2A_VDAC_DIN_CH1),
  .o_D2A_DRIVERA_AMP_EN_CH2(o_D2A_DRIVERA_AMP_EN_CH2),
  .o_D2A_DRIVERA_SOURCEA_CH2(o_D2A_DRIVERA_SOURCEA_CH2),
  .o_D2A_DRIVERA_SOURCEB_CH2(o_D2A_DRIVERA_SOURCEB_CH2),
  .o_D2A_DRIVERA_PULLDA_CH2(o_D2A_DRIVERA_PULLDA_CH2),
  .o_D2A_DRIVERA_PULLDB_CH2(o_D2A_DRIVERA_PULLDB_CH2),
  .o_D2A_COMP_EN_CH2	(o_D2A_COMP_EN_CH2),
   .o_D2A_IDAC_EN_CH2	(o_D2A_IDAC_EN_CH2),
   .o_D2A_IDAC_DIN_CH2	(o_D2A_IDAC_DIN_CH2),	
   .o_D2A_VDAC_EN_CH2	(o_D2A_VDAC_EN_CH2),
  .o_D2A_VDAC_DIN_CH2	(o_D2A_VDAC_DIN_CH2),
   .o_D2A_ANA_BIST		(o_D2A_ANA_BIST)
*/


//----------analog register outputs
/*
    //ana_pmu
        .o_BG_BUF_EN(o_BG_BUF_EN),
        .o_DAC_BUF_EN(o_DAC_BUF_EN),
    //ana_tsc
        .o_TSC_EN(o_TSC_EN),
        .o_TSC_BJT_SEL(o_TSC_BJT_SEL),
        .o_TSC_GSEL(o_TSC_GSEL),
        .o_TSC_OUT_SEL(o_TSC_OUT_SEL),

  //Peripheral
       .o_BIST_EN(o_BIST_EN),
       .o_TSC_AMP_EN(o_TSC_AMP_EN),
       .o_BIST_ISEL(o_BIST_ISEL),
       .o_DDA_EN(o_DDA_EN),
       .o_DDA_GSEL(o_DDA_GSEL),
       .o_PGA_EN(o_PGA_EN),
       .o_PGA_VIN_SEL(o_PGA_VIN_SEL),
       .o_PGA_GSEL(o_PGA_GSEL),
       .o_ELE_BUF_EN(o_ELE_BUF_EN),
       .o_ELE_BUF_ISEL(o_ELE_BUF_ISEL),
       .o_SDM_EN(o_SDM_EN),
       .o_SDM_CHOP_EN(o_SDM_CHOP_EN),

        .comp0_ctrl_reg                 (comp0_ctrl_reg),  
        .comp1_ctrl_reg                 (comp1_ctrl_reg),  
        .pga_ctrl0_reg                  (pga_ctrl0_reg),   
        .pga_ctrl1_reg                  (pga_ctrl1_reg),   
        .charge_ctrl0_reg               (charge_ctrl0_reg),
        .charge_ctrl1_reg               (charge_ctrl1_reg),
        .pmu_ctrl_reg                   (pmu_ctrl_reg),    
        .boost_ctrl0_reg                (boost_ctrl0_reg), 
        .boost_ctrl1_reg                (boost_ctrl1_reg), 
        .boost_ctrl2_reg                (boost_ctrl2_reg), 
        .ana_bist0_reg                  (ana_bist0_reg),   
        .ana_bist1_reg                  (ana_bist1_reg),  

  .comp0_out                      (comp0_out),
        .comp1_out                      (comp1_out),
        .charger_ok                     (charger_ok),
        .charger_end                    (charger_end),
        .lvd_out                        (lvd_out),
        .temp_150c_trig                 (temp_150c_trig),
        .boost_oc                       (boost_oc),
        .boost_ot                       (boost_ot),
        .boost_ov                       (boost_ov)
*/

 

 
);

endmodule


//------------------------------------------ 

//	.i_wg_driver_in_wave_addr	(i_wg_driver_in_wave_addr),
//	.i_wg_driver_source		(i_wg_driver_source),
//        .i_hlf_wave_cnt                 (i_hlf_wave_cnt),
//        .i_period_num                   (i_period_num),
//	.o_wg_driver_en		        (o_wg_driver_en),
//        .o_period_sel                   (o_period_sel),
////	.o_wg_drivera_en		(o_wg_drivera_en),
////	.o_wg_driverc_en		(o_wg_driverc_en),
//	.o_config_reg			(o_config_reg),
//	.o_wg_driver_rest_t		(o_wg_driver_rest_t), 
//	.o_wg_driver_silent_t		(o_wg_driver_silent_t),
//	.o_wg_driver_rest_t1		(o_wg_driver_rest_t1), 
//	.o_wg_driver_silent_t1		(o_wg_driver_silent_t1),
//	.o_wg_driver_rest_t2		(o_wg_driver_rest_t2), 
//	.o_wg_driver_silent_t2		(o_wg_driver_silent_t2),
//	.o_wg_driver_delay_lim		(o_wg_driver_delay_lim),
//	.o_wg_driver_hlf_wave_prd	(o_wg_driver_hlf_wave_prd),
//	.o_wg_driver_neg_hlf_wave_prd	(o_wg_driver_neg_hlf_wave_prd),
//        .o_wg_driver_hlf_wave_prd1	(o_wg_driver_hlf_wave_prd1),
//	.o_wg_driver_neg_hlf_wave_prd1	(o_wg_driver_neg_hlf_wave_prd1),
//	.o_wg_driver_hlf_wave_prd2	(o_wg_driver_hlf_wave_prd2),
//	.o_wg_driver_neg_hlf_wave_prd2	(o_wg_driver_neg_hlf_wave_prd2),		 
//	.o_reg_wg_driver_point_config   (o_reg_wg_driver_point_config),
//	.o_wg_driver_alter_lim		(o_wg_driver_alter_lim),
//	.o_wg_driver_alter_silent_lim	(o_wg_driver_alter_silent_lim),
////	.o_wg_driver_clk_freq		(o_wg_driver_clk_freq),
//	.o_wg_driver_in_wave		(o_wg_driver_in_wave),
////	.o_wg_driver_elec_no		(o_wg_driver_elec_no),
//	.o_wg_driver_isel		(o_wg_driver_isel),
////	.o_wg_driver_sw_config		(o_wg_driver_sw_config),
//	.o_mult_elec			(o_mult_elec),
////	.o_wg_driver_interrupt		(o_wg_driver_interrupt),
//        .o_wg_driver_int_addr0         (o_wg_driver_int_addr0),
//        .o_wg_driver_int_addr1         (o_wg_driver_int_addr1),
//        .o_wg_driver_int_en            (o_wg_driver_int_en),
//        .o_addr0_int_clr               (o_addr0_int_clr),    
//        .o_addr1_int_clr               (o_addr1_int_clr),
//        .o_wg_driver_int_cnt      (o_wg_driver_int_cnt),
//        .i_wg_driver_int_sts           (i_wg_driver_int_sts),

        
//	.d2a_trim0_from_otp  (d2a_trim0_from_otp), 
//	.d2a_trim1_from_otp  (d2a_trim1_from_otp), 
//	.d2a_trim2_from_otp  (d2a_trim2_from_otp),
//	.d2a_trim3_from_otp  (d2a_trim3_from_otp),
//	.d2a_trim4_from_otp  (d2a_trim4_from_otp),
//	.d2a_trim5_from_otp  (d2a_trim5_from_otp),
//	.d2a_trim6_from_otp  (d2a_trim6_from_otp),
//        .d2a_alt_fun_from_otp(d2a_alt_fun_from_otp),
//	.d2a_trim8_from_otp  (d2a_trim8_from_otp),
//	.d2a_trim9_from_otp  (d2a_trim9_from_otp),
//	.i_DEBUG_otp(DEBUG_otp),
 //       .otp_unlock(otp_unlock),
//        .otp_spi_wr(otp_spi_wr),
        
//        .trim_tag_reg(trim_tag_reg),
//        //.d2a_trim0_to_otp(trim_tag_reg), // trim0 - NEED TO CHECK WITH MOHSEN!
//        .d2a_trim1_to_otp(d2a_trim1_to_otp),
//        .d2a_trim2_to_otp(d2a_trim2_to_otp),
//        .d2a_trim3_to_otp(d2a_trim3_to_otp),
//        .d2a_trim4_to_otp(d2a_trim4_to_otp),
//        .d2a_trim5_to_otp(d2a_trim5_to_otp),
//        .d2a_trim6_to_otp(d2a_trim6_to_otp),
//        .d2a_alt_fun_to_otp(d2a_alt_fun_to_otp),
//        .d2a_trim8_to_otp(d2a_trim8_to_otp),
//        .d2a_trim9_to_otp(d2a_trim9_to_otp),


//	.i_otp_busy(otp_BUSY),
//        .OTP_Reset_Done(OTP_Reset_Done),

        //.gpio_0_ctrl_all (gpio_0_ctrl_all ),			  //16/04/2024 commented by supriya 
        //.gpio_1_ctrl_all (gpio_1_ctrl_all ),                    //16/04/2024 commented by supriya
        //.gpio_2_ctrl_all (gpio_2_ctrl_all ),                    //16/04/2024 commented by supriya
        //.gpio_3_ctrl_all (gpio_3_ctrl_all ),                    //16/04/2024 commented by supriya
        //.gpio_4_ctrl_all (gpio_4_ctrl_all ),                    //16/04/2024 commented by supriya
        //.gpio_5_ctrl_all (gpio_5_ctrl_all ),                    //16/04/2024 commented by supriya
        //.gpio_6_ctrl_all (gpio_6_ctrl_all ),                    //16/04/2024 commented by supriya
        //.gpio_7_ctrl_all (gpio_7_ctrl_all ),                    //16/04/2024 commented by supriya
        //.gpio_8_ctrl_all (gpio_8_ctrl_all ),                    //16/04/2024 commented by supriya
        //.gpio_9_ctrl_all (gpio_9_ctrl_all ),                    //16/04/2024 commented by supriya
        //.gpio_10_ctrl_all(gpio_10_ctrl_all),                    //16/04/2024 commented by supriya
        //.gpio_11_ctrl_all(gpio_11_ctrl_all),                    //16/04/2024 commented by supriya
        //.gpio_12_ctrl_all(gpio_12_ctrl_all),                    //16/04/2024 commented by supriya
        //.gpio_13_ctrl_all(gpio_13_ctrl_all),                    //16/04/2024 commented by supriya
        //.gpio_14_ctrl_all(gpio_14_ctrl_all),                    //16/04/2024 commented by supriya
        //.gpio_15_ctrl_all(gpio_15_ctrl_all), 
//        .gpio_16_ctrl_all(gpio_16_ctrl_all), 
//        .gpio_17_ctrl_all(gpio_17_ctrl_all), 
//        .gpio_18_ctrl_all(gpio_18_ctrl_all), 	

