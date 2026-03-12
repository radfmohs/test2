 
//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap ENS2  
// Module Name : Wave Generator Driver TOP Wrapper
// Description : TOP Wrapper block for Arbitrary Wave Generator Controller mainly for wire name changing for easy interfacing
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Design
//------------------------------------------------------------------------------
// 0.1          27/08/2021  Mohsen Radfar
// Initial Rev
//------------------------------------------------------------------------------

`timescale 1 ns /  1 ps

module wg_driver_top_wrapper_analog#(
parameter ADDR_WIDTH = 12,
	HLF_WV_NO_PTS = 6, // number of points in the input quantised half (of the period) wave (e.g. 64 points for first half of the sine wave). Ensure it is a power of 2 value
	OUT_NO_BITS = 8, // number of bits for the generated output value (which goes into the DAC)
	WAVE_NO_BITS = 8,  
	ELEC_NO_A = 2, //number of electrodes for Driver A
//	ELEC_NO_B = 1, //number of electrodes for Driver B
//	ELEC_B_OUTPUT = 23, //number outputs for Driver B
	ELEC_NO_C = 2 //number of electrodes for Driver C
)(
// analog side interface
//--------inputs from analog-------//
//NA
//--------outputs to analog------//
	 //DRIVER A
//  spi_wg.slave           spi_wg,
  output logic  [OUT_NO_BITS-1:0] o_out_wave_drivera_dac0,
  output logic  [OUT_NO_BITS-1:0] o_out_wave_drivera_dac1,
 // output logic  [OUT_NO_BITS-1:0] o_out_wave_drivera_dac2,
//  output logic  [OUT_NO_BITS-1:0] o_out_wave_drivera_dac3,
  output logic [ELEC_NO_A-1:0]   	o_sourcea_driver_a,       //
  output logic [ELEC_NO_A-1:0]   	o_sourceb_driver_a,       // 
  output logic [ELEC_NO_A-1:0]   	o_pullda_driver_a,       // 
  output logic [ELEC_NO_A-1:0]   	o_pulldb_driver_a,       // 
 // output logic [ELEC_NO_A-1:0]		o_driver_driver_a_en,
//  output logic [2:0]    		o_drivera_isel0,
//  output logic [2:0]    		o_drivera_isel1,
//  output logic [2:0]    		o_drivera_isel2,
//  output logic [2:0]    		o_drivera_isel3,
  	
	//DRIVER B
//  output logic [ELEC_B_OUTPUT:0]   		o_pullup_ci_driver_b,       //one extra wire connection for reference
//  output logic [ELEC_B_OUTPUT:0]   		o_sink_ci_driver_b,       // one extra wire connection for reference
//  output logic 				o_driver_ci_driver_b_en,
//  output logic  [OUT_NO_BITS-1:0] 	o_out_wave_ci_driverb_data,

	//DRIVER C
//  output logic  [OUT_NO_BITS-1:0] o_out_wave_ds_driver_c_dac0,
//  output logic  [OUT_NO_BITS-1:0] o_out_wave_ds_driver_c_dac1,
//  output logic  [OUT_NO_BITS-1:0] o_out_wave_ds_driver_c_dac2,
//  output logic  [OUT_NO_BITS-1:0] o_out_wave_ds_driver_c_dac3,
//  output logic  [OUT_NO_BITS-1:0] o_out_wave_ds_driver_c_dac4,
//  output logic  [OUT_NO_BITS-1:0] o_out_wave_ds_driver_c_dac5,
//  output logic  [OUT_NO_BITS-1:0] o_out_wave_ds_driver_c_dac6,
//  output logic  [OUT_NO_BITS-1:0] o_out_wave_ds_driver_c_dac7,
//  output logic [ELEC_NO_C-1:0]   	o_source_ds_driver_c,       // 
//  output logic [ELEC_NO_C-1:0]   	o_sink_ds_driver_c,       // 
//  output logic [2:0]    		o_ds_driver_c_ct0,
//  output logic [2:0]    		o_ds_driver_c_ct1,
//  output logic [2:0]    		o_ds_driver_c_ct2,
//  output logic [2:0]    		o_ds_driver_c_ct3,
//  output logic [2:0]    		o_ds_driver_c_ct4,
//  output logic [2:0]    		o_ds_driver_c_ct5,
//  output logic [2:0]    		o_ds_driver_c_ct6,
//  output logic [2:0]    		o_ds_driver_c_ct7,
//  output logic [ELEC_NO_C-1:0]		o_ds_driver_en_driver_c,
//  output logic 				o_ds_driver_en_current_c,
//  output logic [ELEC_NO_C-1:0]   	o_sw_pullup_driver_c,       // 
//  output logic [ELEC_NO_C-1:0]   	o_sw_pulldn_driver_c,       // 
//  output logic 				o_driver_en_sw_c,
  
  
  input wire                     i_pclk,
  input wire                     i_presetn,
  input wire                     scan_mode,  //tri add

//  output wire   [7:0]            o_wg_driver_in_wave_addr[ELEC_NO_C-1:0],
//  output wire   [1:0]            o_wg_driver_source[ELEC_NO_C-1:0],
//  output wire   [7:0]            o_hlf_wave_cnt[ELEC_NO_C-1:0],
//  output wire   [1:0]            o_period_num[ELEC_NO_C-1:0],
//  input wire           	        i_wg_driver_en[ELEC_NO_C-1:0],          
//  input wire    [4:0]         	i_period_sel[ELEC_NO_C-1:0], 
// // input wire           	        i_wg_drivera_en[ELEC_NO_C-1:0],          
////  input wire           	        i_wg_driverc_en[ELEC_NO_C-1:0],          
//  input wire   [7:0]        	i_config_reg[ELEC_NO_C-1:0],
//  input wire   [15:0]        	i_wg_driver_rest_t[ELEC_NO_C-1:0], 
//  input wire   [23:0]        	i_wg_driver_silent_t[ELEC_NO_C-1:0], 
//  input wire   [15:0]        	i_wg_driver_rest_t1[ELEC_NO_C-1:0], 
//  input wire   [23:0]        	i_wg_driver_silent_t1[ELEC_NO_C-1:0], 
//  input wire   [15:0]        	i_wg_driver_rest_t2[ELEC_NO_C-1:0], 
//  input wire   [23:0]        	i_wg_driver_silent_t2[ELEC_NO_C-1:0], 
//  input wire   [15:0]        	i_wg_driver_hlf_wave_prd[ELEC_NO_C-1:0], 
//  input wire   [15:0]        	i_wg_driver_neg_hlf_wave_prd[ELEC_NO_C-1:0], 
//  input wire   [15:0]        	i_wg_driver_hlf_wave_prd1[ELEC_NO_C-1:0], 
//  input wire   [15:0]        	i_wg_driver_neg_hlf_wave_prd1[ELEC_NO_C-1:0],
//  input wire   [15:0]        	i_wg_driver_hlf_wave_prd2[ELEC_NO_C-1:0], 
//  input wire   [15:0]        	i_wg_driver_neg_hlf_wave_prd2[ELEC_NO_C-1:0],
//  input wire   [7:0]        	i_wg_driver_point_config[ELEC_NO_C-1:0],
//  input wire   [15:0]        	i_wg_driver_alter_lim[ELEC_NO_C-1:0], 
//  input wire   [15:0]           i_wg_driver_alter_silent_lim[ELEC_NO_C-1:0], 
//  input wire   [15:0]           i_wg_driver_delay_lim[ELEC_NO_C-1:0], 
//  input wire   [2:0]       	i_wg_driver_isel[ELEC_NO_C-1:0], 
////  input wire   [7:0]       	    i_wg_driver_sw_config[ELEC_NO_C-1:0], 
////  input wire   [7:0]                i_wg_driver_clk_freq[ELEC_NO_C-1:0],
//  input wire  		            i_mult_elec[ELEC_NO_C-1:0],
//  input wire   [OUT_NO_BITS-1:0]    i_wg_driver_in_wave[ELEC_NO_C-1:0],
////  input wire   [7:0]                i_wg_driver_elec_no[ELEC_NO_C-1:0],
////  input wire                        i_wg_driver_interrupt[ELEC_NO_C-1:0],
//  input   wire [7:0]                i_wg_driver_int_addr0[ELEC_NO_C-1:0],
//  input   wire [7:0]                i_wg_driver_int_addr1[ELEC_NO_C-1:0],
//  input   wire                      i_wg_driver_int_en[ELEC_NO_C-1:0],
//  input   wire                      i_addr0_int_clr[ELEC_NO_C-1:0],
//  input   wire                      i_addr1_int_clr[ELEC_NO_C-1:0],
//  input   wire [7:0]                i_wg_driver_int_cnt[ELEC_NO_C-1:0],
//  output  wire [1:0]                o_wg_driver_int_sts[ELEC_NO_C-1:0],

output  wire   [7:0]            o_wg_driver_in_wave_addr[ELEC_NO_C-1:0],
output  wire   [1:0]            o_wg_driver_source[ELEC_NO_C-1:0],
output  wire   [1:0]            o_period_num[ELEC_NO_C-1:0],
output  wire   [1:0]            o_wg_driver_int_sts[ELEC_NO_C-1:0],

input   wire           o_wg_driver_en[ELEC_NO_C-1:0],
input   wire  [4:0]  	 o_period_sel[ELEC_NO_C-1:0],              
input   wire  [7:0]    o_config_reg[ELEC_NO_C-1:0],
input   wire  [15:0]   o_wg_driver_rest_t[ELEC_NO_C-1:0],
input   wire  [23:0]   o_wg_driver_silent_t[ELEC_NO_C-1:0],
input   wire  [15:0]   o_wg_driver_rest_t1[ELEC_NO_C-1:0],
input   wire  [23:0]   o_wg_driver_silent_t1[ELEC_NO_C-1:0] , 
input   wire  [15:0]   o_wg_driver_rest_t2[ELEC_NO_C-1:0],
input   wire  [23:0]   o_wg_driver_silent_t2[ELEC_NO_C-1:0],
input   wire  [15:0]   o_wg_driver_hlf_wave_prd[ELEC_NO_C-1:0] ,
input   wire  [15:0]   o_wg_driver_neg_hlf_wave_prd[ELEC_NO_C-1:0],
input   wire  [15:0]   o_wg_driver_hlf_wave_prd1[ELEC_NO_C-1:0],
input   wire  [15:0]   o_wg_driver_neg_hlf_wave_prd1[ELEC_NO_C-1:0],
input   wire  [15:0]   o_wg_driver_hlf_wave_prd2[ELEC_NO_C-1:0],
input   wire  [15:0]   o_wg_driver_neg_hlf_wave_prd2[ELEC_NO_C-1:0],
input   wire  [7:0]    o_reg_wg_driver_point_config[ELEC_NO_C-1:0],
input   wire  [15:0]   o_wg_driver_alter_lim[ELEC_NO_C-1:0],
input   wire  [15:0]   o_wg_driver_alter_silent_lim[ELEC_NO_C-1:0],
input   wire  [15:0]   o_wg_driver_delay_lim[ELEC_NO_C-1:0],
//wire  [2:0]    o_wg_driver_isel[ELEC_NO_C-1:0];
input   wire  	       o_mult_elec[ELEC_NO_C-1:0],
input   wire  [7:0]    o_wg_driver_in_wave[ELEC_NO_C-1:0],
input   wire  [7:0]    o_wg_driver_int_addr0[ELEC_NO_C-1:0],
input   wire  [7:0]    o_wg_driver_int_addr1[ELEC_NO_C-1:0],
input   wire           o_wg_driver_int_en[ELEC_NO_C-1:0] ,
input   wire           o_addr0_int_clr[ELEC_NO_C-1:0],
input   wire           o_addr1_int_clr[ELEC_NO_C-1:0],
input   wire  [7:0]    o_wg_driver_int_cnt[ELEC_NO_C-1:0],
input   wire  [7:0]    o_pullba_ctrl[ELEC_NO_C-1:0],
input   wire  [20:0]   dirve[ELEC_NO_C-1:0],
input   wire           global_en,
input   wire  [1:0]    stop_wavegen,





  output 	 		o_wg_driver_interrupt //one of the modules have run into an intrrupt to load the new waveform data
  );



//sync from sclk domain to sysclk domain

   wire           	        i_wg_driver_en_sync[ELEC_NO_C-1:0]       ;   
   wire   [4:0]          	i_period_sel_sync[ELEC_NO_C-1:0]       ;
//   wire           	        i_wg_drivera_en_sync[ELEC_NO_C-1:0]       ;   
//   wire           	        i_wg_driverc_en_sync[ELEC_NO_C-1:0]       ;   
   wire   [7:0]          	i_config_reg_sync[ELEC_NO_C-1:0];
   wire   [15:0]         	i_wg_driver_rest_t_sync[ELEC_NO_C-1:0] ;
   wire   [23:0]        	i_wg_driver_silent_t_sync[ELEC_NO_C-1:0] ;
   wire   [15:0]         	i_wg_driver_rest_t1_sync[ELEC_NO_C-1:0] ;
   wire   [23:0]        	i_wg_driver_silent_t1_sync[ELEC_NO_C-1:0] ;
   wire   [15:0]         	i_wg_driver_rest_t2_sync[ELEC_NO_C-1:0] ;
   wire   [23:0]        	i_wg_driver_silent_t2_sync[ELEC_NO_C-1:0] ;
   wire   [15:0]        	i_wg_driver_hlf_wave_prd_sync[ELEC_NO_C-1:0] ;
   wire   [15:0]        	i_wg_driver_neg_hlf_wave_prd_sync[ELEC_NO_C-1:0];
   wire   [15:0]        	i_wg_driver_hlf_wave_prd1_sync[ELEC_NO_C-1:0] ;
   wire   [15:0]        	i_wg_driver_neg_hlf_wave_prd1_sync[ELEC_NO_C-1:0];
   wire   [15:0]        	i_wg_driver_hlf_wave_prd2_sync[ELEC_NO_C-1:0] ;
   wire   [15:0]        	i_wg_driver_neg_hlf_wave_prd2_sync[ELEC_NO_C-1:0];
   wire   [7:0]          	i_wg_driver_point_config_sync[ELEC_NO_C-1:0];
   wire   [15:0]        	i_wg_driver_alter_lim_sync[ELEC_NO_C-1:0];
   wire   [15:0]                i_wg_driver_alter_silent_lim_sync[ELEC_NO_C-1:0];
   wire   [15:0]                i_wg_driver_delay_lim_sync[ELEC_NO_C-1:0];
//   wire   [2:0]               	i_wg_driver_isel_sync[ELEC_NO_C-1:0];
//   wire   [7:0]       	        i_wg_driver_sw_config_sync[ELEC_NO_C-1:0];
//   wire   [7:0]                 i_wg_driver_clk_freq_sync[ELEC_NO_C-1:0];
   wire  		        i_mult_elec_sync[ELEC_NO_C-1:0];
//   wire   [OUT_NO_BITS-1:0]     i_wg_driver_in_wave_sync[ELEC_NO_C-1:0];
//   wire                         i_wg_driver_interrupt_sync[ELEC_NO_C-1:0];

   wire [7:0]                   i_wg_driver_int_addr0_sync[ELEC_NO_C-1:0];
   wire [7:0]                   i_wg_driver_int_addr1_sync[ELEC_NO_C-1:0];
   wire                         i_wg_driver_int_en_sync[ELEC_NO_C-1:0];
   wire                         i_addr0_int_clr_sync[ELEC_NO_C-1:0];
   wire                         i_addr1_int_clr_sync[ELEC_NO_C-1:0];
   wire [7:0]                   wg_driver_int_cnt_sync[ELEC_NO_C-1:0];
   wire [7:0]                   i_pullba_ctrl_sync[ELEC_NO_C-1:0];
wire [5:0] drive1_sync,drive2_sync;
wire [2:0] data_scl1,data_scl2,data_scl1_r,data_scl2_r;
reg [ELEC_NO_A-1:0]   	o_sourcea_driver_a_temp;
reg [ELEC_NO_A-1:0]   	o_sourceb_driver_a_temp;
reg [ELEC_NO_A-1:0]   	o_pullda_driver_a_temp;
reg [ELEC_NO_A-1:0]   	o_pulldb_driver_a_temp;
//reg [ELEC_NO_A-1:0]	   	o_driver_driver_a_en_temp;
reg [WAVE_NO_BITS-1:0]   o_out_wave_drivera_dac0_temp;
reg [WAVE_NO_BITS-1:0]   o_out_wave_drivera_dac1_temp;

common_sync_bit   u_drive1_sync [5:0] (
       .clk(i_pclk),
       .rst_(i_presetn),
       .async_in(dirve[0][5:0]),
       .sync_out(drive1_sync)
);

common_sync_bit   u_drive2_sync [5:0] (
       .clk(i_pclk),
       .rst_(i_presetn),
       .async_in(dirve[1][5:0]),
       .sync_out(drive2_sync)
);


common_sync_bit   u_data_scl1_sync [2:0] (
       .clk(i_pclk),
       .rst_(i_presetn),
       .async_in(dirve[0][20:18]),
       .sync_out(data_scl1)
);

common_sync_bit   u_data_scl2_sync [2:0] (
       .clk(i_pclk),
       .rst_(i_presetn),
       .async_in(dirve[1][20:18]),
       .sync_out(data_scl2)
);


assign data_scl1_r = (data_scl1<=3'b100)? data_scl1 : 3'h0;
assign data_scl2_r = (data_scl2<=3'b100)? data_scl2 : 3'h0;

//assign  o_driver_driver_a_en[0] =  o_driver_driver_a_en_temp[0];
assign  o_sourcea_driver_a[0]   = drive1_sync[4]? drive1_sync[0] : o_sourcea_driver_a_temp[0];
assign  o_sourceb_driver_a[0]   = drive1_sync[4]? drive1_sync[1] : o_sourceb_driver_a_temp[0];
assign  o_pullda_driver_a[0]    = drive1_sync[4]? drive1_sync[2] : o_pullda_driver_a_temp[0];
assign  o_pulldb_driver_a[0]    = drive1_sync[4]? drive1_sync[3] : o_pulldb_driver_a_temp[0];
assign  o_out_wave_drivera_dac0  =  drive1_sync[5]? dirve[0][17:6] : drive1_sync[4]? dirve[0][17:6] : {o_out_wave_drivera_dac0_temp,4'h0} >> data_scl1_r;

//assign  o_driver_driver_a_en[1] = o_driver_driver_a_en_temp[1];
assign  o_sourcea_driver_a[1]   = drive2_sync[4]? drive2_sync[0] : o_sourcea_driver_a_temp[1];
assign  o_sourceb_driver_a[1]   = drive2_sync[4]? drive2_sync[1] : o_sourceb_driver_a_temp[1];
assign  o_pullda_driver_a[1]    = drive2_sync[4]? drive2_sync[2] : o_pullda_driver_a_temp[1];
assign  o_pulldb_driver_a[1]    = drive2_sync[4]? drive2_sync[3] : o_pulldb_driver_a_temp[1];

assign  o_out_wave_drivera_dac1  =  drive2_sync[5]? dirve[1][17:6] : drive2_sync[4]? dirve[1][17:6] : {o_out_wave_drivera_dac1_temp,4'h0} >> data_scl2_r;

wire drive_en[ELEC_NO_C-1:0];
//wire global_en;

//assign global_en = spi_wg.global_en;
assign drive_en[0] = (global_en | o_wg_driver_en[0]) & !stop_wavegen[0];
assign drive_en[1] = (global_en | o_wg_driver_en[1]) & !stop_wavegen[1];

genvar i;
generate 
   for (i=0;i < ELEC_NO_C; i=i+1) begin

common_sync_bit   u_driver_en_sync (
       .clk(i_pclk),
       .rst_(i_presetn),
       .async_in(drive_en[i]),
       .sync_out(i_wg_driver_en_sync[i])
       );

//assign i_wg_driver_en_sync[i] = drive_en[i];

//common_sync_bit   u_period_sel_sync[4:0] (
//       .clk(i_pclk),
//       .rst_(i_presetn),
//       .async_in(i_period_sel[i]),
//       .sync_out(i_period_sel_sync[i])
//       );
assign i_period_sel_sync[i] = o_period_sel[i];

//common_sync_bit   u_drivera_en_sync (
//       .clk(i_pclk),
//       .rst_(i_presetn),
//       .async_in(i_wg_drivera_en[i]),
//       .sync_out(i_wg_drivera_en_sync[i])
//       );

//common_sync_bit   u_driverc_en_sync (
//       .clk(i_pclk),
//       .rst_(i_presetn),
//       .async_in(i_wg_driverc_en[i]),
//       .sync_out(i_wg_driverc_en_sync[i])
//       );

//common_sync_bit   u_config_reg_sync[7:0] (
//       .clk(i_pclk),
//       .rst_(i_presetn),
//       .async_in(i_config_reg[i]),
//       .sync_out(i_config_reg_sync[i])
//       );
assign i_config_reg_sync[i] = o_config_reg[i];

//common_sync_bit   u_rest_sync[15:0] (
//       .clk(i_pclk),
//       .rst_(i_presetn),
//       .async_in(i_wg_driver_rest_t[i]),
//       .sync_out(i_wg_driver_rest_t_sync[i])
//       );
assign i_wg_driver_rest_t_sync[i] = o_wg_driver_rest_t[i];


//common_sync_bit   u_silent_sync[31:0] (
//       .clk(i_pclk),
//       .rst_(i_presetn),
//       .async_in(i_wg_driver_silent_t[i]),
//       .sync_out(i_wg_driver_silent_t_sync[i])
//       );
assign i_wg_driver_silent_t_sync[i] = o_wg_driver_silent_t[i];

//common_sync_bit   u_rest1_sync[15:0] (
//       .clk(i_pclk),
//       .rst_(i_presetn),
//       .async_in(i_wg_driver_rest_t1[i]),
//       .sync_out(i_wg_driver_rest_t1_sync[i])
//       );
assign i_wg_driver_rest_t1_sync[i] = o_wg_driver_rest_t1[i];

//common_sync_bit   u_silent1_sync[31:0] (
//       .clk(i_pclk),
//       .rst_(i_presetn),
//       .async_in(i_wg_driver_silent_t1[i]),
//       .sync_out(i_wg_driver_silent_t1_sync[i])
//       );
assign i_wg_driver_silent_t1_sync[i] = o_wg_driver_silent_t1[i];

//common_sync_bit   u_rest2_sync[15:0] (
//       .clk(i_pclk),
//       .rst_(i_presetn),
//       .async_in(i_wg_driver_rest_t2[i]),
//       .sync_out(i_wg_driver_rest_t2_sync[i])
//       );
assign i_wg_driver_rest_t2_sync[i] = o_wg_driver_rest_t2[i];

//common_sync_bit   u_silent2_sync[31:0] (
//       .clk(i_pclk),
//       .rst_(i_presetn),
//       .async_in(i_wg_driver_silent_t2[i]),
//       .sync_out(i_wg_driver_silent_t2_sync[i])
//       );
assign i_wg_driver_silent_t2_sync[i] = o_wg_driver_silent_t2[i];

//common_sync_bit   u_hlf_wave_prd_sync[31:0] (
//       .clk(i_pclk),
//       .rst_(i_presetn),
//       .async_in(i_wg_driver_hlf_wave_prd[i]),
//       .sync_out(i_wg_driver_hlf_wave_prd_sync[i])
//       );
assign i_wg_driver_hlf_wave_prd_sync[i] = o_wg_driver_hlf_wave_prd[i];

//common_sync_bit   u_neg_hlf_wave_prd_sync[31:0] (
//       .clk(i_pclk),
//       .rst_(i_presetn),
//       .async_in(i_wg_driver_neg_hlf_wave_prd[i]),
//       .sync_out(i_wg_driver_neg_hlf_wave_prd_sync[i])
//       );
assign i_wg_driver_neg_hlf_wave_prd_sync[i] = o_wg_driver_neg_hlf_wave_prd[i];

//common_sync_bit   u_hlf_wave_prd1_sync[31:0] (
//       .clk(i_pclk),
//       .rst_(i_presetn),
//       .async_in(i_wg_driver_hlf_wave_prd1[i]),
//       .sync_out(i_wg_driver_hlf_wave_prd1_sync[i])
//       );
assign i_wg_driver_hlf_wave_prd1_sync[i] = o_wg_driver_hlf_wave_prd1[i];

//common_sync_bit   u_neg_hlf_wave_prd1_sync[31:0] (
//       .clk(i_pclk),
//       .rst_(i_presetn),
//       .async_in(i_wg_driver_neg_hlf_wave_prd1[i]),
//       .sync_out(i_wg_driver_neg_hlf_wave_prd1_sync[i])
//       );
assign i_wg_driver_neg_hlf_wave_prd1_sync[i] = o_wg_driver_neg_hlf_wave_prd1[i];

//common_sync_bit   u_hlf_wave_prd2_sync[31:0] (
//       .clk(i_pclk),
//       .rst_(i_presetn),
//       .async_in(i_wg_driver_hlf_wave_prd2[i]),
//       .sync_out(i_wg_driver_hlf_wave_prd2_sync[i])
//       );
assign i_wg_driver_hlf_wave_prd2_sync[i] = o_wg_driver_hlf_wave_prd2[i];

//common_sync_bit   u_neg_hlf_wave_prd2_sync[31:0] (
//       .clk(i_pclk),
//       .rst_(i_presetn),
//       .async_in(i_wg_driver_neg_hlf_wave_prd2[i]),
//       .sync_out(i_wg_driver_neg_hlf_wave_prd2_sync[i])
//       );
assign i_wg_driver_neg_hlf_wave_prd2_sync[i] = o_wg_driver_neg_hlf_wave_prd2[i];

//common_sync_bit   u_point_config_sync[7:0] (
//       .clk(i_pclk),
//       .rst_(i_presetn),
//       .async_in(i_wg_driver_point_config[i]),
//       .sync_out(i_wg_driver_point_config_sync[i])
//       );
assign i_wg_driver_point_config_sync[i] = o_reg_wg_driver_point_config[i];

//common_sync_bit   u_alter_sync[15:0] (
//       .clk(i_pclk),
//       .rst_(i_presetn),
//       .async_in(i_wg_driver_alter_lim[i]),
//       .sync_out(i_wg_driver_alter_lim_sync[i])
//       );
assign i_wg_driver_alter_lim_sync[i] = o_wg_driver_alter_lim[i];

//common_sync_bit   u_alter_silent_sync[15:0] (
//       .clk(i_pclk),
//       .rst_(i_presetn),
//       .async_in(i_wg_driver_alter_silent_lim[i]),
//       .sync_out(i_wg_driver_alter_silent_lim_sync[i])
//       );
assign i_wg_driver_alter_silent_lim_sync[i] = o_wg_driver_alter_silent_lim[i];

//common_sync_bit   u_delay_sync[15:0] (
//       .clk(i_pclk),
//       .rst_(i_presetn),
//       .async_in(i_wg_driver_delay_lim[i]),
//       .sync_out(i_wg_driver_delay_lim_sync[i])
//       );
assign i_wg_driver_delay_lim_sync[i] = o_wg_driver_delay_lim[i];

//common_sync_bit   u_driver_isel_sync[2:0] (
//       .clk(i_pclk),
//       .rst_(i_presetn),
//       .async_in(spi_wg.o_wg_driver_isel[i]),
//       .sync_out(i_wg_driver_isel_sync[i])
//       );
//assign i_wg_driver_isel_sync[i] = spi_wg.o_wg_driver_isel[i] & {3{i_wg_driver_en_sync[i]}};

//common_sync_bit   u_sw_config_sync[7:0] (
//       .clk(i_pclk),
//       .rst_(i_presetn),
//       .async_in(i_wg_driver_sw_config[i]),
//       .sync_out(i_wg_driver_sw_config_sync[i])
//       );

//common_sync_bit   u_clk_freq_sync[7:0] (
//       .clk(i_pclk),
//       .rst_(i_presetn),
//       .async_in(i_wg_driver_clk_freq[i]),
//       .sync_out(i_wg_driver_clk_freq_sync[i])
//       );


//common_sync_bit   u_mult_elec_sync(
//       .clk(i_pclk),
//       .rst_(i_presetn),
//       .async_in(i_mult_elec[i]),
//       .sync_out(i_mult_elec_sync[i])
//       );
assign i_mult_elec_sync[i] = o_mult_elec[i];


//common_sync_bit   u_driver_in_wave_sync[OUT_NO_BITS-1:0](
//       .clk(i_pclk),
//       .rst_(i_presetn),
//       .async_in(i_wg_driver_in_wave[i]),
//       .sync_out(i_wg_driver_in_wave_sync[i])
//       );

//common_sync_bit   u_driver_interrupt_sync(
//       .clk(i_pclk),
//       .rst_(i_presetn),
//       .async_in(i_wg_driver_interrupt[i]),
//       .sync_out(i_wg_driver_interrupt_sync[i])
//       );


common_sync_bit   u_driver_int_addr0_sync[7:0](
       .clk(i_pclk),
       .rst_(i_presetn),
       .async_in(o_wg_driver_int_addr0[i]),
       .sync_out(i_wg_driver_int_addr0_sync[i])
       );

common_sync_bit   u_driver_int_addr1_sync[7:0](
       .clk(i_pclk),
       .rst_(i_presetn),
       .async_in(o_wg_driver_int_addr1[i]),
       .sync_out(i_wg_driver_int_addr1_sync[i])
       );

//common_sync_bit   u_wg_driver_int_cnt_sync[7:0](
//       .clk(i_pclk),
//       .rst_(i_presetn),
//       .async_in(i_wg_driver_int_cnt[i]),
//       .sync_out(wg_driver_int_cnt_sync[i])
//       );
assign wg_driver_int_cnt_sync[i] = o_wg_driver_int_cnt[i];

//common_sync_bit   u_driver_int_en_sync(
//       .clk(i_pclk),
//       .rst_(i_presetn),
//       .async_in(i_wg_driver_int_en[i]),
//       .sync_out(i_wg_driver_int_en_sync[i])
//       );
assign i_wg_driver_int_en_sync[i] = o_wg_driver_int_en[i];


assign i_pullba_ctrl_sync[i]      = o_pullba_ctrl[i];

common_rst_sync u_addr0_int_clr_sync(
.RSTINn    (i_presetn),
.RSTREQ    (o_addr0_int_clr[i]),
.CLK       (i_pclk),
.SE        (1'b0),
.RSTBYPASS (scan_mode),  //tri change to fix dft issue
.RSTOUTn   (i_addr0_int_clr_sync[i])
);

common_rst_sync u_addr1_int_clr_sync(
.RSTINn    (i_presetn),
.RSTREQ    (o_addr1_int_clr[i]),
.CLK       (i_pclk),
.SE        (1'b0),
.RSTBYPASS (scan_mode),  //tri change to fix dft issue
.RSTOUTn   (i_addr1_int_clr_sync[i])
);

    end
endgenerate


//wire [ELEC_NO_C-1:0] w_driver_enable;       // Driver enable, active high
wire [ELEC_NO_C-1:0] [1:0] w_source;      // source A:0 or B:1 packed array
//wire [ELEC_NO_C-1:0] [2:0] w_isel; // isel (current select)
wire [ELEC_NO_C-1:0] w_driver_sel; 
wire [ELEC_NO_C-1:0] [WAVE_NO_BITS-1:0] w_out_wave_val;
wire [7:0] w_elec_no;
//wire [7:0] [1:0]		w_sw;
//wire i_wg_drivera_en_sync_or;

//assign i_wg_drivera_en_sync_or = i_wg_drivera_en_sync[0] | i_wg_drivera_en_sync[1] | i_wg_drivera_en_sync[2]| i_wg_drivera_en_sync[3];

//assign i_wg_driverc_en_sync_or = i_wg_driverc_en_sync[0] | i_wg_driverc_en_sync[1] | i_wg_driverc_en_sync[2]| i_wg_driverc_en_sync[3]|
//                                 i_wg_driverc_en_sync[4] | i_wg_driverc_en_sync[5] | i_wg_driverc_en_sync[6]| i_wg_driverc_en_sync[7];


//wire [7:0] w_driver_enable_a,w_driver_enable_c;

//genvar k;
//generate 
//    for (k=0;k < ELEC_NO_C; k=k+1) begin
//  assign    w_driver_enable_a[k] = i_wg_drivera_en_sync[k] && w_driver_enable[k];
//  assign    w_driver_enable_c[k] = i_wg_driverc_en_sync[k] && w_driver_enable[k];
//    end
//endgenerate
//wire o_pullup_ci_driver_b_ref, o_sink_ci_driver_b_ref;
//logic [ELEC_B_OUTPUT-1:0]   		o_pullup_ci_driver_b_w;       //
//logic [ELEC_B_OUTPUT-1:0]   		o_sink_ci_driver_b_w;       // 

always_ff @(posedge i_pclk or negedge i_presetn) begin
	if (~i_presetn) begin
		//Driver A wire connections
		o_out_wave_drivera_dac0_temp <= 'b0;
		o_out_wave_drivera_dac1_temp <= 'b0;
//		o_out_wave_drivera_dac2 <= 'b0;
//		o_out_wave_drivera_dac3 <= 'b0;

//		o_driver_driver_a_en_temp <= 'b0;

//		o_drivera_isel0 <= 'b0;
//		o_drivera_isel1 <= 'b0;
//		o_drivera_isel2 <= 'b0;
//		o_drivera_isel3 <= 'b0;

		//Driver B wire connections
//		o_out_wave_ci_driverb_data <= 'b0;

//		o_driver_ci_driver_b_en <= 'b0;

		//DRIVER C wire connections
//		o_out_wave_ds_driver_c_dac0 <= 'b0;
//		o_out_wave_ds_driver_c_dac1 <= 'b0;
//		o_out_wave_ds_driver_c_dac2 <= 'b0;
//		o_out_wave_ds_driver_c_dac3 <= 'b0;
//		o_out_wave_ds_driver_c_dac4 <= 'b0;
//		o_out_wave_ds_driver_c_dac5 <= 'b0;
//		o_out_wave_ds_driver_c_dac6 <= 'b0;
//		o_out_wave_ds_driver_c_dac7 <= 'b0;
//
//
//		o_ds_driver_c_ct0 <= 'b0;
//		o_ds_driver_c_ct1 <= 'b0;
//		o_ds_driver_c_ct2 <= 'b0;
//		o_ds_driver_c_ct3 <= 'b0;
//		o_ds_driver_c_ct4 <= 'b0;
//		o_ds_driver_c_ct5 <= 'b0;
//		o_ds_driver_c_ct6 <= 'b0;
//		o_ds_driver_c_ct7 <= 'b0;
//
//		o_ds_driver_en_driver_c <= 'b0;
//		o_ds_driver_en_current_c <= 'b0;
//		o_driver_en_sw_c <= 'b0;
	end
//        else if(i_wg_drivera_en_sync_or) begin
        else begin
		//Driver A wire connections
		o_out_wave_drivera_dac0_temp <= w_out_wave_val[0];
		o_out_wave_drivera_dac1_temp <= w_out_wave_val[1];
//		o_out_wave_drivera_dac2 <= w_out_wave_val[2];
//		o_out_wave_drivera_dac3 <= w_out_wave_val[3];

//		o_driver_driver_a_en_temp <= w_driver_enable[ELEC_NO_A-1:0];

//		o_drivera_isel0 <= w_isel[0];
//		o_drivera_isel1 <= w_isel[1];
//		o_drivera_isel2 <= w_isel[2];
//		o_drivera_isel3 <= w_isel[3];
		//DRIVER C wire connections
//		o_out_wave_ds_driver_c_dac0 <= 'b0;
//		o_out_wave_ds_driver_c_dac1 <= 'b0;
//		o_out_wave_ds_driver_c_dac2 <= 'b0;
//		o_out_wave_ds_driver_c_dac3 <= 'b0;
//		o_out_wave_ds_driver_c_dac4 <= 'b0;
//		o_out_wave_ds_driver_c_dac5 <= 'b0;
//		o_out_wave_ds_driver_c_dac6 <= 'b0;
//		o_out_wave_ds_driver_c_dac7 <= 'b0;
//
//
//		o_ds_driver_c_ct0 <= 'b0;
//		o_ds_driver_c_ct1 <= 'b0;
//		o_ds_driver_c_ct2 <= 'b0;
//		o_ds_driver_c_ct3 <= 'b0;
//		o_ds_driver_c_ct4 <= 'b0;
//		o_ds_driver_c_ct5 <= 'b0;
//		o_ds_driver_c_ct6 <= 'b0;
//		o_ds_driver_c_ct7 <= 'b0;
//
//		o_ds_driver_en_driver_c <= 'b0;
//		o_ds_driver_en_current_c <= 'b0;
//		o_driver_en_sw_c <= 'b0;


        end
//	else if(i_wg_driverc_en_sync_or)begin
//
//		//Driver A wire connections
//		o_out_wave_drivera_dac0 <= 'b0;
//		o_out_wave_drivera_dac1 <= 'b0;
//		o_out_wave_drivera_dac2 <= 'b0;
//		o_out_wave_drivera_dac3 <= 'b0;
//
//		o_driver_driver_a_en <= 'b0;
//
//		o_drivera_isel0 <= 'b0;
//		o_drivera_isel1 <= 'b0;
//		o_drivera_isel2 <= 'b0;
//		o_drivera_isel3 <= 'b0;
//
//
//
//		//Driver B wire connections
////		o_out_wave_ci_driverb_data <= w_out_wave_val[0];
//
////		o_driver_ci_driver_b_en <= |w_driver_enable[ELEC_NO_A+ELEC_NO_B-1:ELEC_NO_A];
//
//		//DRIVER C wire connections
//		o_out_wave_ds_driver_c_dac0 <= w_out_wave_val[0];
//		o_out_wave_ds_driver_c_dac1 <= w_out_wave_val[1];
//		o_out_wave_ds_driver_c_dac2 <= w_out_wave_val[2];
//		o_out_wave_ds_driver_c_dac3 <= w_out_wave_val[3];
//		o_out_wave_ds_driver_c_dac4 <= w_out_wave_val[4];
//		o_out_wave_ds_driver_c_dac5 <= w_out_wave_val[5];
//		o_out_wave_ds_driver_c_dac6 <= w_out_wave_val[6];
//		o_out_wave_ds_driver_c_dac7 <= w_out_wave_val[7];
//
//
//		o_ds_driver_c_ct0 <= w_isel[0];
//		o_ds_driver_c_ct1 <= w_isel[1];
//		o_ds_driver_c_ct2 <= w_isel[2];
//		o_ds_driver_c_ct3 <= w_isel[3];
//		o_ds_driver_c_ct4 <= w_isel[4];
//		o_ds_driver_c_ct5 <= w_isel[5];
//		o_ds_driver_c_ct6 <= w_isel[6];
//		o_ds_driver_c_ct7 <= w_isel[7];
//
//		o_ds_driver_en_driver_c <= w_driver_enable_c[7:0];
//		o_ds_driver_en_current_c <= |w_driver_enable_c[7:0];
//		o_driver_en_sw_c <= o_ds_driver_en_current_c; //when Driver C is enabled, switches are enabled too
//	end
end

//driver a connections
always_ff @(posedge i_pclk or negedge i_presetn) begin
	if (~i_presetn) begin
		o_sourcea_driver_a_temp <= {ELEC_NO_A{1'b0}};
		o_pulldb_driver_a_temp <= {ELEC_NO_A{1'b0}};
		o_sourceb_driver_a_temp <= {ELEC_NO_A{1'b0}};
		o_pullda_driver_a_temp <= {ELEC_NO_A{1'b0}};
	end
	else begin
		for (integer idx = 0; idx < ELEC_NO_A; idx = idx+1) begin
			if (w_driver_sel[idx]) begin
         if(w_source[idx][0] && w_source[idx][1]) begin
			  	o_sourcea_driver_a_temp[idx] <= 1'b0;
			  	o_pulldb_driver_a_temp[idx]  <= 1'b1;
			   	o_sourceb_driver_a_temp[idx] <= 1'b0;
			  	o_pullda_driver_a_temp[idx]  <= 1'b1;
         end
         else begin
			  	o_sourcea_driver_a_temp[idx] <= w_source[idx][0];
			  	o_pulldb_driver_a_temp[idx] <= w_source[idx][0];
			   	o_sourceb_driver_a_temp[idx] <= w_source[idx][1];
			  	o_pullda_driver_a_temp[idx] <= w_source[idx][1];
         end
			end
			else begin
				o_sourcea_driver_a_temp[idx] <= 1'b0;
				o_pulldb_driver_a_temp[idx] <= 1'b0;
				o_sourceb_driver_a_temp[idx] <= 1'b0;
				o_pullda_driver_a_temp[idx] <= 1'b0;
			end
		end
	end
end
/*
//driver b connections
always_comb begin
	for (integer idx = 0; idx < ELEC_NO_B; idx = idx+1) begin
		if (w_driver_sel[idx+ELEC_NO_A]) begin
			for (integer idx2 = 0; idx2 < ELEC_B_OUTPUT; idx2 = idx2 + 1) begin
				if(idx2 == w_elec_no) begin
					o_pullup_ci_driver_b_w[idx2] = w_source[0][0];
					o_sink_ci_driver_b_w[idx2] = w_source[0][1];
				end
				else begin
					o_pullup_ci_driver_b_w[idx2] = 1'b0;
					o_sink_ci_driver_b_w[idx2] = 1'b0;
				end
			end
		end
		else begin
			o_pullup_ci_driver_b_w = {ELEC_B_OUTPUT{1'b0}};
			o_sink_ci_driver_b_w = {ELEC_B_OUTPUT{1'b0}};
		end
	end
end

assign o_pullup_ci_driver_b_ref = (|o_sink_ci_driver_b_w[ELEC_B_OUTPUT-1:0])==1?w_source[0][1]:1'b0;//electrode 23 is reference (receipient)
assign o_sink_ci_driver_b_ref = (|o_pullup_ci_driver_b_w[ELEC_B_OUTPUT-1:0])==1?w_source[0][0]:1'b0;//electrode 23 is reference (receipient)
	
always_ff @(posedge i_pclk or negedge i_presetn) begin
	if (~i_presetn) begin
		o_pullup_ci_driver_b <= {(ELEC_B_OUTPUT+1){1'b0}};
		o_sink_ci_driver_b <= {(ELEC_B_OUTPUT+1){1'b0}};
	end
	else begin
		o_pullup_ci_driver_b <= {o_pullup_ci_driver_b_ref,o_pullup_ci_driver_b_w[ELEC_B_OUTPUT-1:0]};
		o_sink_ci_driver_b <= {o_sink_ci_driver_b_ref,o_sink_ci_driver_b_w[ELEC_B_OUTPUT-1:0]};
	end
end

//driver c connections
always_ff @(posedge i_pclk or negedge i_presetn) begin
	if (~i_presetn) begin
		o_source_ds_driver_c <= {ELEC_NO_C{1'b0}};
		o_sink_ds_driver_c <= {ELEC_NO_C{1'b0}};
	end
	else begin
		for (integer idx = 0; idx < ELEC_NO_C; idx = idx+1) begin
			if (w_driver_sel[idx] && i_wg_driverc_en_sync_or) begin
				o_source_ds_driver_c[idx] <= w_source[idx][0];
				o_sink_ds_driver_c[idx] <= w_source[idx][1];
			end
			else begin
				o_source_ds_driver_c[idx] <= 1'b0;
				o_sink_ds_driver_c[idx] <= 1'b0;
			end
		end
	end
end

//driver C switch connections
genvar idx;
for (idx = 0; idx < 8; idx = idx+1) begin //number of switches
	always_ff @(posedge i_pclk or negedge i_presetn) begin
		if (~i_presetn) begin
			o_sw_pullup_driver_c[idx] <= 1'b0;
			o_sw_pulldn_driver_c[idx] <= 1'b0;
		end
		else if(i_wg_driverc_en_sync_or) begin
			o_sw_pullup_driver_c[idx] <= w_sw[idx][0];
			o_sw_pulldn_driver_c[idx] <= w_sw[idx][1];
		end
	end
end
*/

wg_driver_top#(
	.ADDR_WIDTH(ADDR_WIDTH),
	.HLF_WV_NO_PTS(HLF_WV_NO_PTS), // number of points in the input quantised half (of the period) wave (e.g. 64 points for first half of the sine wave). Ensure it is a power of 2 value
	.OUT_NO_BITS(WAVE_NO_BITS), // number of bits for the generated output value (which goes into the DAC)
	.ELEC_NO(ELEC_NO_C) //total number of electrodes 
//	.ELEC_NO_REGS_BLK(ELEC_NO_A+ELEC_NO_B-1) //which block requires electrode number registers (Driver B number which is ELEC_NO_A+ELEC_NO_B provided ELEC_NO_B is 1)
)
wg_driver_top_inst
(
// analog side interface
//--------inputs from analog-------//
//NA
//--------outputs to analog------//
  .o_out_wave_val(w_out_wave_val),
//  .o_elec_no(w_elec_no),
//  .o_driver_enable(w_driver_enable),       // Driver enable, active high
  .o_source(w_source),       // source A:0 or B:1
//  .o_isel(w_isel),       // isel (current select)
  .o_driver_sel(w_driver_sel), //which driver this waveform will go to
 // .o_sw(w_sw),

// Digital side interface
//clock and reset
  .i_pclk(i_pclk),          // pclk
//  .i_pclkg(i_pclkg),         // gated clock
  .i_presetn(i_presetn),       // reset
 .scan_mode                     (scan_mode),   //tri change

 .in_wave_addr  (o_wg_driver_in_wave_addr),
 .w_source	(o_wg_driver_source),
 //.hlf_wave_cnt  (o_hlf_wave_cnt),
 .period_num    (o_period_num),
 .i_wg_driver_en(i_wg_driver_en_sync),
 .i_period_sel  (i_period_sel_sync),
 .config_reg    (i_config_reg_sync),
 .rest_t        (i_wg_driver_rest_t_sync), 
 .silent_t      (i_wg_driver_silent_t_sync),
 .rest_t1        (i_wg_driver_rest_t1_sync), 
 .silent_t1      (i_wg_driver_silent_t1_sync),
 .rest_t2        (i_wg_driver_rest_t2_sync), 
 .silent_t2      (i_wg_driver_silent_t2_sync),
 .delay_lim     (i_wg_driver_delay_lim_sync),
 .hlf_wave_per  (i_wg_driver_hlf_wave_prd_sync),
 .neg_hlf_wave_per  (i_wg_driver_neg_hlf_wave_prd_sync),
 .hlf_wave_per1  (i_wg_driver_hlf_wave_prd1_sync),
 .neg_hlf_wave_per1  (i_wg_driver_neg_hlf_wave_prd1_sync),
 .hlf_wave_per2  (i_wg_driver_hlf_wave_prd2_sync),
 .neg_hlf_wave_per2  (i_wg_driver_neg_hlf_wave_prd2_sync),
 .point_config  (i_wg_driver_point_config_sync),
 .alter_lim         (i_wg_driver_alter_lim_sync),
 .alter_silent_lim  (i_wg_driver_alter_silent_lim_sync),
 //.clk_freq          (i_wg_driver_clk_freq_sync),
 .out_wave_val      (o_wg_driver_in_wave),
// .(i_wg_driver_elec_no),
// .w_isel            (i_wg_driver_isel_sync),
// .w_sw_config_reg   (i_wg_driver_sw_config_sync),
 .w_mult_elec       (i_mult_elec_sync),
 .pullba_ctrl       (i_pullba_ctrl_sync),
// .w_interrupt       (i_wg_driver_interrupt_sync),
 .wg_driver_int_addr0  (i_wg_driver_int_addr0_sync),
 .wg_driver_int_addr1  (i_wg_driver_int_addr1_sync),
 .wg_driver_int_en     (i_wg_driver_int_en_sync),
 .addr0_int_clr        (i_addr0_int_clr_sync),
 .addr1_int_clr        (i_addr1_int_clr_sync),
 .wg_driver_int_cnt    (wg_driver_int_cnt_sync),
 .wg_driver_int_sts    (o_wg_driver_int_sts),

  .o_wg_driver_interrupt(o_wg_driver_interrupt) //one of the modules have run into an intrrupt to load the new waveform data
  );

endmodule

