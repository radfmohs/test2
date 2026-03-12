 
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

module wg_driver_top_wrapper#(
parameter ADDR_WIDTH = 12,
	HLF_WV_NO_PTS = 6, // number of points in the input quantised half (of the period) wave (e.g. 64 points for first half of the sine wave). Ensure it is a power of 2 value
	OUT_NO_BITS = 8, // number of bits for the generated output value (which goes into the DAC)
	WAVE_NO_BITS = 12,  
	ELEC_NO_C = 2 //number of electrodes for Driver A

)(
// analog side interface
//--------inputs from analog-------//
//NA
//--------outputs to analog------//
	 //DRIVER A
  spi_wg.slave           spi_wg,
  output logic  [WAVE_NO_BITS-1:0] o_out_wave_drivera_dac0,
  output logic  [WAVE_NO_BITS-1:0] o_out_wave_drivera_dac1,
  output logic  [WAVE_NO_BITS-1:0] o_out_wave_drivera_dac2,
  output logic  [WAVE_NO_BITS-1:0] o_out_wave_drivera_dac3,
  output logic  [WAVE_NO_BITS-1:0] o_out_wave_drivera_dac4,
  output logic  [WAVE_NO_BITS-1:0] o_out_wave_drivera_dac5,
  output logic  [WAVE_NO_BITS-1:0] o_out_wave_drivera_dac6,
  output logic  [WAVE_NO_BITS-1:0] o_out_wave_drivera_dac7,


  output logic [ELEC_NO_C-1:0] drive_en,

  output logic [ELEC_NO_C-1:0]   	o_sourcea_driver_c,       //
  output logic [ELEC_NO_C-1:0]   	o_sourceb_driver_c,       // 
  output logic [ELEC_NO_C-1:0]   	o_pullda_driver_c,       // 
  output logic [ELEC_NO_C-1:0]   	o_pulldb_driver_c,       // 

  output logic [2:0]    		o_ds_driver_c_ct0,
  output logic [2:0]    		o_ds_driver_c_ct1,
  output logic [2:0]    		o_ds_driver_c_ct2,
  output logic [2:0]    		o_ds_driver_c_ct3,
  output logic [2:0]    		o_ds_driver_c_ct4,
  output logic [2:0]    		o_ds_driver_c_ct5,
  output logic [2:0]    		o_ds_driver_c_ct6,
  output logic [2:0]    		o_ds_driver_c_ct7,
  output logic [ELEC_NO_C-1:0]		o_ds_driver_en_driver_c,
  output logic 				o_ds_driver_en_current_c,
  output logic 				o_driver_en_sw_c,


  
  
  input wire                     i_pclk,
  input wire                     i_fclk,
  input wire                     i_presetn,
  input wire                     scan_mode,  //tri add

  input wire [ELEC_NO_C-1:0]	lead_off_stop,

  input  wire         int_length_slct,

  output 	 		o_wg_driver_interrupt //one of the modules have run into an intrrupt to load the new waveform data
  );

wire wg_driver_interrupt;

assign o_wg_driver_interrupt = wg_driver_interrupt;

wire   [7:0]            o_wg_driver_in_wave_addr[ELEC_NO_C-1:0];
wire   [7:0]            o_wg_driver_ems_wave_addr[ELEC_NO_C-1:0];
wire   [1:0]            o_wg_driver_source[ELEC_NO_C-1:0];
//wire   [7:0]            o_hlf_wave_cnt[ELEC_NO_C-1:0];
wire   [1:0]            o_period_num[ELEC_NO_C-1:0];
wire   [1:0]            o_wg_driver_int_sts[ELEC_NO_C-1:0];


assign  spi_wg.i_wg_driver_in_wave_addr      = o_wg_driver_in_wave_addr     ;
assign  spi_wg.i_wg_driver_ems_wave_addr     = o_wg_driver_ems_wave_addr     ;
assign  spi_wg.i_wg_driver_source            = o_wg_driver_source           ;
//assign  spi_wg.i_hlf_wave_cnt                = o_hlf_wave_cnt               ;
assign  spi_wg.i_period_num                  = o_period_num                 ;
assign  spi_wg.i_wg_driver_int_sts           = o_wg_driver_int_sts          ;
//sync from sclk domain to sysclk domain

   wire           	        i_wg_driver_en_sync[ELEC_NO_C-1:0]       ;   
   wire   [4:0]          	i_period_sel_sync[ELEC_NO_C-1:0]       ;
//   wire           	        i_wg_drivera_en_sync[ELEC_NO_C-1:0]       ;   
//   wire           	        i_wg_driverc_en_sync[ELEC_NO_C-1:0]       ;   
   wire   [7:0]          	i_config_reg_sync[ELEC_NO_C-1:0];
   wire   [15:0]         	i_wg_driver_rest_t_sync[ELEC_NO_C-1:0] ;
   wire   [31:0]        	i_wg_driver_silent_t_sync[ELEC_NO_C-1:0] ;
   wire   [15:0]         	i_wg_driver_rest_t1_sync[ELEC_NO_C-1:0] ;
   wire   [31:0]        	i_wg_driver_silent_t1_sync[ELEC_NO_C-1:0] ;
   wire   [15:0]         	i_wg_driver_rest_t2_sync[ELEC_NO_C-1:0] ;
   wire   [31:0]        	i_wg_driver_silent_t2_sync[ELEC_NO_C-1:0] ;
   wire   [15:0]        	i_wg_driver_hlf_wave_prd_sync[ELEC_NO_C-1:0] ;
   wire   [15:0]        	i_wg_driver_neg_hlf_wave_prd_sync[ELEC_NO_C-1:0];
   wire   [15:0]        	i_wg_driver_hlf_wave_prd1_sync[ELEC_NO_C-1:0] ;
   wire   [15:0]        	i_wg_driver_neg_hlf_wave_prd1_sync[ELEC_NO_C-1:0];
   wire   [15:0]        	i_wg_driver_hlf_wave_prd2_sync[ELEC_NO_C-1:0] ;
   wire   [15:0]        	i_wg_driver_neg_hlf_wave_prd2_sync[ELEC_NO_C-1:0];
   wire   [7:0]          	i_wg_driver_point_config_sync[ELEC_NO_C-1:0];
   wire   [15:0]        	i_wg_driver_alter_lim_sync[ELEC_NO_C-1:0];
   wire   [15:0]                i_wg_driver_alter_silent_lim_sync[ELEC_NO_C-1:0];
   wire   [15:0]                i_wg_driver_alter_rest_lim_sync[ELEC_NO_C-1:0];
   wire   [15:0]                i_wg_driver_delay_lim_sync[ELEC_NO_C-1:0];
//   wire   [2:0]               	i_wg_driver_isel_sync[ELEC_NO_C-1:0];
   wire   [15:0]       	        i_wg_driver_sw_config_sync[ELEC_NO_C-1:0];
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
   wire                         i_no_of_num_slient_disable[ELEC_NO_C-1:0];
   wire [15:0]                  i_no_of_num_slient_tar[ELEC_NO_C-1:0];
   wire [7:0]                   i_reg_wg_cal_addr_sync[ELEC_NO_C-1:0];


reg [ELEC_NO_C-1:0]   	o_source_ds_driver_c;
reg [ELEC_NO_C-1:0]   	o_sink_ds_driver_c;
reg [ELEC_NO_C-1:0]   	o_sw_pulldn_driver_c;
reg [ELEC_NO_C-1:0]   	o_sw_pullup_driver_c;
//reg [ELEC_NO_C-1:0]	   	o_driver_driver_a_en_temp;
reg [ELEC_NO_C-1:0] [WAVE_NO_BITS-1:0]   o_out_wave_drivera_dac_temp;
//reg [WAVE_NO_BITS-1:0]   o_out_wave_drivera_dac1_temp;

wire [ELEC_NO_C-1:0] [1:0] w_source;      // source A:0 or B:1 packed array
//wire [ELEC_NO_C-1:0] [2:0] w_isel; // isel (current select)
wire [ELEC_NO_C-1:0] w_driver_sel; 
wire [ELEC_NO_C-1:0] [WAVE_NO_BITS-1:0] w_out_wave_val;
wire [ELEC_NO_C-1:0] [WAVE_NO_BITS-1:0]   o_out_wave_drivera_dac;
wire [7:0] w_elec_no;
reg [ELEC_NO_C-1:0] [2:0] driver_c_ct;
wire [1:0] w_sw[ELEC_NO_C-1:0] ;


assign o_out_wave_drivera_dac0 = o_out_wave_drivera_dac[0];
assign o_out_wave_drivera_dac1 = o_out_wave_drivera_dac[1];
assign o_out_wave_drivera_dac2 = o_out_wave_drivera_dac[2];
assign o_out_wave_drivera_dac3 = o_out_wave_drivera_dac[3];
assign o_out_wave_drivera_dac4 = o_out_wave_drivera_dac[4];
assign o_out_wave_drivera_dac5 = o_out_wave_drivera_dac[5];
assign o_out_wave_drivera_dac6 = o_out_wave_drivera_dac[6];
assign o_out_wave_drivera_dac7 = o_out_wave_drivera_dac[7];

assign o_ds_driver_c_ct0 = driver_c_ct[0];
assign o_ds_driver_c_ct1 = driver_c_ct[1] ;
assign o_ds_driver_c_ct2 = driver_c_ct[2] ;
assign o_ds_driver_c_ct3 = driver_c_ct[3] ;
assign o_ds_driver_c_ct4 = driver_c_ct[4] ;
assign o_ds_driver_c_ct5 = driver_c_ct[5] ;
assign o_ds_driver_c_ct6 = driver_c_ct[6] ;
assign o_ds_driver_c_ct7 = driver_c_ct[7] ;


genvar i;
generate 
   for (i=0;i < ELEC_NO_C; i=i+1) begin

assign  o_sourcea_driver_c[i]   = spi_wg.dirve[i][4]? spi_wg.dirve[i][0] : o_source_ds_driver_c[i];
assign  o_sourceb_driver_c[i]   = spi_wg.dirve[i][4]? spi_wg.dirve[i][1] : o_sink_ds_driver_c[i];
assign  o_pullda_driver_c[i]    = spi_wg.dirve[i][4]? spi_wg.dirve[i][2] : o_sw_pulldn_driver_c[i];
assign  o_pulldb_driver_c[i]    = spi_wg.dirve[i][4]? spi_wg.dirve[i][3] : o_sw_pullup_driver_c[i];
assign  o_out_wave_drivera_dac[i]  =  spi_wg.dirve[i][5]? spi_wg.dirve[i][17:6] : spi_wg.dirve[i][4]? spi_wg.dirve[i][17:6] : o_out_wave_drivera_dac_temp[i];

assign drive_en[i] = (spi_wg.global_en | spi_wg.o_wg_driver_en[i]) & !spi_wg.stop_wavegen[i] & (!(lead_off_stop[i]));

common_sync_bit   u_driver_en_sync (
       .clk(i_fclk),
       .rst_(i_presetn),
       .async_in(drive_en[i]),
       .sync_out(i_wg_driver_en_sync[i])
       );

assign i_period_sel_sync[i] = spi_wg.o_period_sel[i];

assign i_config_reg_sync[i] = spi_wg.o_config_reg[i];

assign i_wg_driver_rest_t_sync[i] = spi_wg.o_wg_driver_rest_t[i];

assign i_wg_driver_silent_t_sync[i] = spi_wg.o_wg_driver_silent_t[i];

assign i_wg_driver_rest_t1_sync[i] = spi_wg.o_wg_driver_rest_t1[i];

assign i_wg_driver_silent_t1_sync[i] = spi_wg.o_wg_driver_silent_t1[i];

assign i_wg_driver_rest_t2_sync[i] = spi_wg.o_wg_driver_rest_t2[i];

assign i_wg_driver_silent_t2_sync[i] = spi_wg.o_wg_driver_silent_t2[i];

assign i_wg_driver_hlf_wave_prd_sync[i] = spi_wg.o_wg_driver_hlf_wave_prd[i];

assign i_wg_driver_neg_hlf_wave_prd_sync[i] = spi_wg.o_wg_driver_neg_hlf_wave_prd[i];

assign i_wg_driver_hlf_wave_prd1_sync[i] = spi_wg.o_wg_driver_hlf_wave_prd1[i];

assign i_wg_driver_neg_hlf_wave_prd1_sync[i] = spi_wg.o_wg_driver_neg_hlf_wave_prd1[i];

assign i_wg_driver_hlf_wave_prd2_sync[i] = spi_wg.o_wg_driver_hlf_wave_prd2[i];

assign i_wg_driver_neg_hlf_wave_prd2_sync[i] = spi_wg.o_wg_driver_neg_hlf_wave_prd2[i];

assign i_wg_driver_point_config_sync[i] = spi_wg.o_reg_wg_driver_point_config[i];

assign i_wg_driver_alter_lim_sync[i] = spi_wg.o_wg_driver_alter_lim[i];

assign i_wg_driver_alter_silent_lim_sync[i] = spi_wg.o_wg_driver_alter_silent_lim[i];

assign i_wg_driver_alter_rest_lim_sync[i]   = spi_wg.o_wg_driver_alter_rest_lim[i];

assign i_wg_driver_delay_lim_sync[i] = spi_wg.o_wg_driver_delay_lim[i];

assign i_wg_driver_sw_config_sync[i] = spi_wg.o_wg_driver_sw_config[i];

assign i_mult_elec_sync[i] = spi_wg.o_mult_elec[i];

common_sync_bit   u_driver_int_addr0_sync[7:0](
       .clk(i_pclk),
       .rst_(i_presetn),
       .async_in(spi_wg.o_wg_driver_int_addr0[i]),
       .sync_out(i_wg_driver_int_addr0_sync[i])
       );

common_sync_bit   u_driver_int_addr1_sync[7:0](
       .clk(i_pclk),
       .rst_(i_presetn),
       .async_in(spi_wg.o_wg_driver_int_addr1[i]),
       .sync_out(i_wg_driver_int_addr1_sync[i])
       );


common_sync_bit   u_reg_wg_cal_addr_sync[7:0](
       .clk(i_pclk),
       .rst_(i_presetn),
       .async_in(spi_wg.o_reg_wg_cal_addr[i]),
       .sync_out(i_reg_wg_cal_addr_sync[i])
       );

assign wg_driver_int_cnt_sync[i] = spi_wg.o_wg_driver_int_cnt[i];

assign i_wg_driver_int_en_sync[i]     = spi_wg.o_wg_driver_int_en[i];
assign i_pullba_ctrl_sync[i]          = spi_wg.o_pullba_ctrl[i];

assign i_no_of_num_slient_disable[i]  = spi_wg.o_no_of_num_slient_disable[i];
assign i_no_of_num_slient_tar[i]      = spi_wg.o_no_of_num_slient_tar[i];

common_rst_sync u_addr0_int_clr_sync(
.RSTINn    (i_presetn),
.RSTREQ    (spi_wg.o_addr0_int_clr[i]),
.CLK       (i_pclk),
.SE        (1'b0),
.RSTBYPASS (scan_mode),  //tri change to fix dft issue
.RSTOUTn   (i_addr0_int_clr_sync[i])
);

common_rst_sync u_addr1_int_clr_sync(
.RSTINn    (i_presetn),
.RSTREQ    (spi_wg.o_addr1_int_clr[i]),
.CLK       (i_pclk),
.SE        (1'b0),
.RSTBYPASS (scan_mode),  //tri change to fix dft issue
.RSTOUTn   (i_addr1_int_clr_sync[i])
);

always_ff @(posedge i_pclk or negedge i_presetn) begin
	if (~i_presetn) begin
		//Driver A wire connections
		o_out_wave_drivera_dac_temp[i] <= 'b0;	
                driver_c_ct[i] 	               <= 'b0;
	end
        else begin
		o_out_wave_drivera_dac_temp[i] <= w_out_wave_val[i];	
                driver_c_ct[i] 	               <= spi_wg.w_isel[i];
        end
end


assign o_ds_driver_en_driver_c[i] = drive_en[i];

end

endgenerate

always_ff @(posedge i_pclk or negedge i_presetn) begin
	if (~i_presetn) begin
                o_driver_en_sw_c               <= 'b0;
                o_ds_driver_en_current_c       <= 'b0;
	end
        else begin
                o_driver_en_sw_c               <= o_ds_driver_en_current_c;  
                o_ds_driver_en_current_c       <= |drive_en;              
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
			if (w_driver_sel[idx]) begin
                             if(w_source[idx][0] && w_source[idx][1]) begin
				o_source_ds_driver_c[idx] <= 1'b0;
				o_sink_ds_driver_c[idx] <= 1'b0;
                             end
                             else begin
				o_source_ds_driver_c[idx] <= w_source[idx][0];
				o_sink_ds_driver_c[idx] <= w_source[idx][1];
                             end
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
for (idx = 0; idx < ELEC_NO_C; idx = idx+1) begin //number of switches
	always_ff @(posedge i_pclk or negedge i_presetn) begin
		if (~i_presetn) begin
			o_sw_pullup_driver_c[idx] <= 1'b0;
			o_sw_pulldn_driver_c[idx] <= 1'b0;
		end
		else begin
                      if(w_source[idx][0] && w_source[idx][1]) begin
	                o_sw_pullup_driver_c[idx] <= 1'b1;
			o_sw_pulldn_driver_c[idx] <= 1'b1;
                     end
	             else begin
			o_sw_pullup_driver_c[idx] <= w_sw[idx][0];
			o_sw_pulldn_driver_c[idx] <= w_sw[idx][1];
                     end
		end
	end
end


wg_driver_top#(
	.ADDR_WIDTH(ADDR_WIDTH),
	.HLF_WV_NO_PTS(HLF_WV_NO_PTS), // number of points in the input quantised half (of the period) wave (e.g. 64 points for first half of the sine wave). Ensure it is a power of 2 value
	.OUT_NO_BITS(WAVE_NO_BITS), // number of bits for the generated output value (which goes into the DAC)
	.ELEC_NO(ELEC_NO_C) //total number of electrodes 
//	.ELEC_NO_REGS_BLK(ELEC_NO_C+ELEC_NO_B-1) //which block requires electrode number registers (Driver B number which is ELEC_NO_C+ELEC_NO_B provided ELEC_NO_B is 1)
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
  .o_sw(w_sw),

// Digital side interface
//clock and reset
  .i_pclk(i_pclk),          // pclk
//  .i_pclkg(i_pclkg),         // gated clock
  .i_presetn(i_presetn),       // reset
 .scan_mode                     (scan_mode),   //tri change
 .int_length_slct(int_length_slct),

 .in_wave_addr  (o_wg_driver_in_wave_addr),
 .ems_wave_addr (o_wg_driver_ems_wave_addr),
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
 .alter_rest_lim      (i_wg_driver_alter_rest_lim_sync),
 //.clk_freq          (i_wg_driver_clk_freq_sync),
 .out_wave_val      (spi_wg.o_wg_driver_in_wave),
// .(i_wg_driver_elec_no),
// .w_isel            (i_wg_driver_isel_sync),
 .w_sw_config_reg   (i_wg_driver_sw_config_sync),
 .w_mult_elec       (i_mult_elec_sync),
 .pullba_ctrl       (i_pullba_ctrl_sync),

 .reg_wg_cal_addr               (i_reg_wg_cal_addr_sync),
 .i_data_scl                    (spi_wg.o_data_scl),
 .i_ems_data_ctrl               (spi_wg.o_ems_data_ctrl),
 .i_reg_wg_driver_neg_scale     (spi_wg.o_reg_wg_driver_neg_scale),
 .i_wg_driver_pos_scale         (spi_wg.o_wg_driver_pos_scale),
 .i_reg_wg_driver_neg_offset    (spi_wg.o_reg_wg_driver_neg_offset),
 .i_reg_wg_driver_pos_offset    (spi_wg.o_reg_wg_driver_pos_offset),
 .alt_ems_cnt_tar               (spi_wg.alt_ems_cnt_tar),
 .data_scl                      (spi_wg.data_scl),
 .ems_data_ctrl                 (spi_wg.ems_data_ctrl),
 .wg_driver_neg_scale           (spi_wg.wg_driver_neg_scale),
 .wg_driver_pos_scale           (spi_wg.wg_driver_pos_scale),
 .wg_driver_neg_offset          (spi_wg.wg_driver_neg_offset),
 .wg_driver_pos_offset          (spi_wg.wg_driver_pos_offset), 

// .w_interrupt       (i_wg_driver_interrupt_sync),
 .wg_driver_int_addr0  (i_wg_driver_int_addr0_sync),
 .wg_driver_int_addr1  (i_wg_driver_int_addr1_sync),
 .wg_driver_int_en     (i_wg_driver_int_en_sync),
 .addr0_int_clr        (i_addr0_int_clr_sync),
 .addr1_int_clr        (i_addr1_int_clr_sync),
 .no_of_num_slient_disable(i_no_of_num_slient_disable),
 .no_of_num_slient_tar    (i_no_of_num_slient_tar),
 .wg_driver_int_cnt    (wg_driver_int_cnt_sync),
 .wg_driver_int_sts    (o_wg_driver_int_sts),

  .o_wg_driver_interrupt(wg_driver_interrupt) //one of the modules have run into an intrrupt to load the new waveform data
  );

endmodule

