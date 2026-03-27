//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap ENS2  
// File name:    spi_reg_wavegen.sv 
// Module Name : spi_reg_wavegen
// Description : 
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author          Description      
//------------------------------------------------------------------------------
// 0.1                                      Initial Rev 
//------------------------------------------------------------------------------

// waveform generator register array
`define ADDR_WG_DRV_CONFIG_REG0   	        10'h00 
`define ADDR_WG_DRV_CTRL_REG0     	        10'h01
`define ADDR_WG_DRV_POINT_CONFIG                10'h02
//addr and data
`define ADDR_WG_DRV_IN_WAVE_ADDR_REG0	        10'h03
`define ADDR_WG_DRV_IN_WAVE_REG01 	        10'h04
//wave0 period
`define ADDR_WG_DRV_REST_CLK_REG01     	        10'h05
`define ADDR_WG_DRV_REST_CLK_REG02     	        10'h06
`define ADDR_WG_DRV_SILENT_CLK_REG01  	        10'h07
`define ADDR_WG_DRV_SILENT_CLK_REG02  	        10'h08
`define ADDR_WG_DRV_SILENT_CLK_REG03  	        10'h09
`define ADDR_WG_DRV_SILENT_CLK_REG04  	        10'h0A
`define ADDR_WG_DRV_HLF_WAVE_CLK_PNT_REG01   	10'h0B
`define ADDR_WG_DRV_HLF_WAVE_CLK_PNT_REG02   	10'h0C
`define ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT_REG01  10'h0D
`define ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT_REG02  10'h0E
//wave1 period
`define ADDR_WG_DRV_REST_CLK1_REG01    	        10'h0F
`define ADDR_WG_DRV_REST_CLK1_REG02    	        10'h10
`define ADDR_WG_DRV_SILENT_CLK1_REG01  	        10'h11
`define ADDR_WG_DRV_SILENT_CLK1_REG02  	        10'h12
`define ADDR_WG_DRV_SILENT_CLK1_REG03  	        10'h13
`define ADDR_WG_DRV_SILENT_CLK1_REG04  	        10'h14
`define ADDR_WG_DRV_HLF_WAVE_CLK_PNT1_REG01     10'h15
`define ADDR_WG_DRV_HLF_WAVE_CLK_PNT1_REG02     10'h16
`define ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT1_REG01 10'h17
`define ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT1_REG02 10'h18
//wave2 period
`define ADDR_WG_DRV_REST_CLK2_REG01    	        10'h19
`define ADDR_WG_DRV_REST_CLK2_REG02    	        10'h1A
`define ADDR_WG_DRV_SILENT_CLK2_REG01  	        10'h1B
`define ADDR_WG_DRV_SILENT_CLK2_REG02  	        10'h1C
`define ADDR_WG_DRV_SILENT_CLK2_REG03  	        10'h1D
`define ADDR_WG_DRV_SILENT_CLK2_REG04  	        10'h1E
`define ADDR_WG_DRV_HLF_WAVE_CLK_PNT2_REG01   	10'h1F
`define ADDR_WG_DRV_HLF_WAVE_CLK_PNT2_REG02   	10'h20
`define ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT2_REG01 10'h21
`define ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT2_REG02 10'h22
//delay time
`define ADDR_WG_DRV_DELAY_LIM_REG01	        10'h23
`define ADDR_WG_DRV_DELAY_LIM_REG02	        10'h24
//slope amd offset
`define ADDR_WG_DRV_NEG_SCALE_REG0	        10'h25
`define ADDR_WG_DRV_NEG_OFFSET_REG0	        10'h26
`define ADDR_WG_DRV_POS_SCALE_REG0              10'h27
`define ADDR_WG_DRV_POS_OFFSET_REG0	        10'h28
//PULLB
`define ADDR_WG_DRV_PULLBA_REG                  10'h29
//int function
`define ADDR_WG_DRV_INT_NUM_REG02 	        10'h2A
`define ADDR_WG_DRV_INT_REG01		        10'h2B
`define ADDR_WG_DRV_INT_REG02		        10'h2C
`define ADDR_WG_DRV_INT_REG03		        10'h2D
//alt function
`define ADDR_WG_DRV_ALT_LIM_REG01		10'h2E
`define ADDR_WG_DRV_ALT_LIM_REG02		10'h2F
`define ADDR_WG_DRV_ALT_SILENT_LIM_REG01        10'h30
`define ADDR_WG_DRV_ALT_SILENT_LIM_REG02	10'h31
`define ADDR_WG_DRV_ALT_REST_LIM_REG01          10'h32
`define ADDR_WG_DRV_ALT_REST_LIM_REG02	        10'h33
//manual mode
`define DRIVE_REG_CTRL0		                10'h34
`define DRIVE_REG_CTRL1			        10'h35
`define DRIVE_REG_CTRL2			        10'h36

//running with some cycle, then enter slient time
`define NO_OF_NUM_SLIENT_CTR0		        10'h37
`define NO_OF_NUM_SLIENT_TAR0 			10'h38
`define NO_OF_NUM_SLIENT_TAR1 			10'h39

//for the address that scale/offset/MSB_SEL take effect 
`define ADDR_IS_VALID_FOR_CAL 			10'h3A

//EMS control
`define EMS_REG_CTRL                            10'h3B
`define EMS_DATA_NUM                            10'h3C

//ISEL
`define AWG_DRIVEC_ISEL                         10'h3D
`define AWG_DRIVEC_SW_CFG0                      10'h3E
`define AWG_DRIVEC_SW_CFG1                      10'h3F

module spi_reg_wavegen #(
	parameter ADDR_WIDTH =8,
	parameter DATA_WIDTH =8, 
	parameter HLF_WV_NO_PTS = 6, 
	parameter NO_OF_WAVEGEN =8,
	parameter OUT_NO_BITS = 8)
(
  input wire                  i_clk,
  input wire                  i_rst_n,
  input wire                  i_wr,
  input wire                  i_rd,
  input wire [ADDR_WIDTH-1:0] i_addr,
  input wire [DATA_WIDTH-1:0] i_wr_data,	
	

//inputs from ctrl block
  input  wire [7:0]           i_wg_driver_in_wave_addr,
  input  wire [7:0]           i_wg_driver_ems_wave_addr,
  input  wire [1:0]           i_wg_driver_source, //which source is active?
//input  wire [7:0]           i_hlf_wave_cnt, 
  input  wire [1:0]           i_period_num,   
//outputs to ctrl block
  output  wire	              o_wg_driver_en,              // wg_driver enable
  output  wire [4:0]          o_period_sel,
  output  wire                w_isel,
//output  wire	              o_wg_drivera_en,              // wg_driver enable
//output  wire	              o_wg_driverc_en,              // wg_driver enable
  output  wire [7:0]          o_config_reg, 
  output  wire [15:0]         o_wg_driver_rest_t, 
  output  wire [31:0]         o_wg_driver_silent_t, 
  output  wire [15:0]         o_wg_driver_rest_t1, 
  output  wire [31:0]         o_wg_driver_silent_t1,
  output  wire [15:0]         o_wg_driver_rest_t2, 
  output  wire [31:0]         o_wg_driver_silent_t2,
  output  wire [15:0]         o_wg_driver_hlf_wave_prd, 
  output  wire [15:0]         o_wg_driver_neg_hlf_wave_prd, 
  output  wire [15:0]         o_wg_driver_hlf_wave_prd1, 
  output  wire [15:0]         o_wg_driver_neg_hlf_wave_prd1,
  output  wire [15:0]         o_wg_driver_hlf_wave_prd2, 
  output  wire [15:0]         o_wg_driver_neg_hlf_wave_prd2,
  output  wire [7:0]          o_reg_wg_driver_point_config,
  output  wire [15:0]         o_wg_driver_alter_lim, 
  output  wire [15:0]         o_wg_driver_alter_silent_lim, 
  output  wire [15:0]         o_wg_driver_alter_rest_lim,
  output  wire [15:0]         o_wg_driver_delay_lim, 
//output  wire [2:0]          o_wg_driver_isel, 
  output  wire [7:0]          o_pullba_ctrl,
  output  wire [17:0]         o_dirve,

  output  wire [7:0]          o_reg_wg_cal_addr,

  output  wire [3:0]          o_data_scl,
  output  wire [5:0]          o_ems_data_ctrl,
  output  wire [7:0]          o_reg_wg_driver_neg_scale,
  output  wire [7:0]          o_wg_driver_pos_scale,
  output  wire [7:0]          o_reg_wg_driver_neg_offset,
  output  wire [7:0]          o_reg_wg_driver_pos_offset,
  output  reg [7:0]           alt_ems_cnt_tar,
  output  wire [15:0]         o_wg_driver_sw_config,
  input  wire [3:0]           data_scl,
  input  wire [3:0]           ems_data_ctrl,
  input  wire [7:0]           wg_driver_neg_scale,
  input  wire [7:0]           wg_driver_pos_scale,
  input  wire [7:0]           wg_driver_neg_offset,
  input  wire [7:0]           wg_driver_pos_offset,

//output  wire [7:0]          o_wg_driver_sw_config, 
//output  wire [7:0]          o_wg_driver_clk_freq, 
  output  wire  	      o_mult_elec, //allow multiple electrodes to be active at the same time
  output  wire [11:0]         o_wg_driver_in_wave,
//output  wire [7:0]          o_wg_driver_elec_no, 
  output  wire [7:0]          o_rd_data, 
  output wire  [7:0]          o_wg_driver_int_addr0,
  output wire  [7:0]          o_wg_driver_int_addr1,
  output wire                 o_wg_driver_int_en,   
  output reg                  o_addr0_int_clr,      
  output reg                  o_addr1_int_clr,      
  output reg                  o_no_of_num_slient_disable,
  output reg  [15:0]          o_no_of_num_slient_tar,            
  output wire  [7:0]          o_wg_driver_int_cnt,
  input  wire                 int_clear_type,
  input  wire                 i_rd_normal,
  input  wire  [1:0]          i_wg_driver_int_sts  

//output   wire               o_wg_driver_interrupt
);

//WG_DRV_CONFIG_REG
reg [7:0]   reg_wg_driver_config;
wire        reg_wg_driver_config_wr0;
wire	    w_continue;

//WG_DRV_CTRL_REG
wire [1:0]  waveform_preload;
reg [7:0]   reg_wg_driver_ctrl;
wire        reg_wg_driver_ctrl_wr0;

//ADDR_WG_DRV_REST_CLK_REG
reg [15:0]  reg_wg_driver_rest_t;
wire        reg_wg_driver_rest_t_wr0;
wire        reg_wg_driver_rest_t_wr1;

//ADDR_WG_DRV_SILENT_CLK_REG
reg [31:0]  reg_wg_driver_silent_t;
wire        reg_wg_driver_silent_t_wr0;
wire	    reg_wg_driver_silent_t_wr1;
wire	    reg_wg_driver_silent_t_wr2;
wire	    reg_wg_driver_silent_t_wr3;

//ADDR_WG_DRV_REST_CLK_REG
reg [15:0]  reg_wg_driver_rest_t1;
wire        reg_wg_driver_rest_t1_wr0;
wire        reg_wg_driver_rest_t1_wr1;

//ADDR_WG_DRV_SILENT_CLK_REG
reg [31:0]  reg_wg_driver_silent_t1;
wire        reg_wg_driver_silent_t1_wr0;
wire	    reg_wg_driver_silent_t1_wr1;
wire	    reg_wg_driver_silent_t1_wr2;
wire	    reg_wg_driver_silent_t1_wr3;

//ADDR_WG_DRV_REST_CLK_REG
reg [15:0]  reg_wg_driver_rest_t2;
wire        reg_wg_driver_rest_t2_wr0;
wire        reg_wg_driver_rest_t2_wr1;

//ADDR_WG_DRV_SILENT_CLK_REG
reg [31:0]  reg_wg_driver_silent_t2;
wire        reg_wg_driver_silent_t2_wr0;
wire	    reg_wg_driver_silent_t2_wr1;
wire	    reg_wg_driver_silent_t2_wr2;
wire	    reg_wg_driver_silent_t2_wr3;

//ADDR_WG_DRV_HLF_WAVE_CLK_PNT_REG
reg [15:0]  reg_wg_driver_hlf_wave_prd;
wire        reg_wg_driver_hlf_wave_prd_wr0;
wire        reg_wg_driver_hlf_wave_prd_wr1;
//wire        reg_wg_driver_hlf_wave_prd_wr2;
//wire        reg_wg_driver_hlf_wave_prd_wr3;

//ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT_REG
reg [15:0]  reg_wg_driver_neg_hlf_wave_prd;
wire        reg_wg_driver_neg_hlf_wave_prd_wr0;
wire        reg_wg_driver_neg_hlf_wave_prd_wr1;
//wire        reg_wg_driver_neg_hlf_wave_prd_wr2;
//wire        reg_wg_driver_neg_hlf_wave_prd_wr3;

//ADDR_WG_DRV_HLF_WAVE_CLK_PNT1_REG
reg [15:0]  reg_wg_driver_hlf_wave_prd1;
wire        reg_wg_driver_hlf_wave_prd1_wr0;
wire        reg_wg_driver_hlf_wave_prd1_wr1;
//wire        reg_wg_driver_hlf_wave_prd1_wr2;
//wire        reg_wg_driver_hlf_wave_prd1_wr3;

//ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT1_REG
reg [15:0]  reg_wg_driver_neg_hlf_wave_prd1;
wire        reg_wg_driver_neg_hlf_wave_prd1_wr0;
wire        reg_wg_driver_neg_hlf_wave_prd1_wr1;
//wire        reg_wg_driver_neg_hlf_wave_prd1_wr2;
//wire        reg_wg_driver_neg_hlf_wave_prd1_wr3;

//ADDR_WG_DRV_HLF_WAVE_CLK_PNT2_REG
reg [15:0]  reg_wg_driver_hlf_wave_prd2;
wire        reg_wg_driver_hlf_wave_prd2_wr0;
wire        reg_wg_driver_hlf_wave_prd2_wr1;
//wire        reg_wg_driver_hlf_wave_prd2_wr2;
//wire        reg_wg_driver_hlf_wave_prd2_wr3;

//ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT2_REG
reg [15:0]  reg_wg_driver_neg_hlf_wave_prd2;
wire        reg_wg_driver_neg_hlf_wave_prd2_wr0;
wire        reg_wg_driver_neg_hlf_wave_prd2_wr1;
//wire        reg_wg_driver_neg_hlf_wave_prd2_wr2;
//wire        reg_wg_driver_neg_hlf_wave_prd2_wr3;

//ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT2_REG
reg [7:0]   reg_wg_driver_point_config;
wire        reg_wg_driver_point_config_wr;

//ADDR_WG_DRV_CLK_FREQ_REG
//reg [7:0]  reg_wg_driver_clk_freq;
//wire        reg_wg_driver_clk_freq_wr0;

//ADDR_WG_DRV_IN_WAVE_ADDR_REG
reg [7:0]   reg_wg_driver_in_wave_addr;
wire        reg_wg_driver_in_wave_addr_wr0;

//ADDR_WG_DRV_IN_WAVE_REG
reg [OUT_NO_BITS-1:0] reg_wg_driver_in_wave[(2**HLF_WV_NO_PTS)-1:0];
wire        reg_wg_driver_in_wave_wr0;

//ADDR_WG_DRV_ALT_LIM_REG		
reg [15:0]  reg_wg_driver_alt_lim;
wire        reg_wg_driver_alt_lim_wr0;
wire        reg_wg_driver_alt_lim_wr1;

//ADDR_WG_DRV_ALT_SILENT_LIM_REG		
reg [15:0]  reg_wg_driver_alt_silent_lim;
wire        reg_wg_driver_alt_silent_lim_wr0;
wire        reg_wg_driver_alt_silent_lim_wr1;

//ADDR_WG_DRV_DELAY_LIM_REG	
reg [15:0]  reg_wg_driver_delay_lim;
wire        reg_wg_driver_delay_lim_wr0;
wire        reg_wg_driver_delay_lim_wr1;

//ADDR_WG_DRV_NEG_SCALE_REG
reg [7:0]   reg_wg_driver_neg_scale;
wire        reg_wg_driver_neg_scale_wr0;

//ADDR_WG_DRV_NEG_OFFSET_REG
reg [7:0]   reg_wg_driver_neg_offset;
wire        reg_wg_driver_neg_offset_wr0;

//ADDR_WG_DRV_ISEL_REG
reg [7:0]   reg_wg_driver_isel;
wire        reg_wg_driver_isel_wr0;

//ADDR_WG_DRV_SW_CONFIG_REG
reg [7:0]   reg_wg_driver_pos_offset;
wire        reg_wg_driver_pos_offset_wr0;
//wire [7:0] wg_driver_pos_scale;
//ADDR_WG_DRV_INT_REG 			
reg [31:0]  reg_wg_driver_int;
wire	    reg_wg_driver_int_wr0;
wire	    reg_wg_driver_int_wr1;
wire	    reg_wg_driver_int_wr2;
wire        reg_wg_driver_int_wr3;
wire        auto_intr_addr_swap;
//wire	    wg_driver_int_en;
//wire [7:0]  wg_driver_int_addr0;
//wire [7:0]  wg_driver_int_addr1;
wire 	    reg_wg_driver_int_sts_wr0;
wire 	    reg_wg_driver_int_sts_rd0;
//wire        addr0_int_clr;
//wire        addr1_int_clr;
//wire	    w_addr_flag0;
//wire	    w_addr_flag1;
//wire	    w_addr_flag;
//reg [1:0]   reg_wg_driver_int_sts;

//ADDR_WG_DRV_PULLBA_REG  
wire 	  reg_wg_pullba_wr0;
reg [7:0] reg_wg_pullba;

reg [7:0] drive_ctrl_reg0;
reg [7:0] drive_ctrl_reg1;
reg [7:0] drive_ctrl_reg2;
/////////////////////////////////////////////////////////
// waveform generator register array begin
/////////////////////////////////////////////////////////
//-----------------------------------------------
//ADDR_WG_DRV_CONFIG_REG 
//-----------------------------------------------
assign reg_wg_driver_config_wr0 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_CONFIG_REG0+10'h40 * NO_OF_WAVEGEN));

//write to wg_driver_config_reg
always @(posedge i_clk or negedge i_rst_n) begin
  if (~i_rst_n)
    reg_wg_driver_config[7:0] <= 8'h00;
  else begin 
    reg_wg_driver_config[7:0]  <= reg_wg_driver_config_wr0 ? i_wr_data[7:0]  : reg_wg_driver_config [7:0];
  end
end
 
assign o_config_reg = reg_wg_driver_config;
assign w_continue = reg_wg_driver_config[5];
assign o_mult_elec = reg_wg_driver_config[6];//allow multiple electrodes to be active at the same time

//-----------------------------------------------
//ADDR_WG_DRV_CTRL_REG 
//-----------------------------------------------
assign reg_wg_driver_ctrl_wr0 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_CTRL_REG0+10'h40 * NO_OF_WAVEGEN));

//write to register
always @(posedge i_clk or negedge i_rst_n) begin
  if (~i_rst_n) begin
    reg_wg_driver_ctrl[7:0]  <= 8'h00;
  end
  else begin
    reg_wg_driver_ctrl[7:0]  <= reg_wg_driver_ctrl_wr0 ? i_wr_data[7:0]  : reg_wg_driver_ctrl[7:0];
 end
end

assign o_wg_driver_en       = reg_wg_driver_ctrl[0];
assign waveform_preload     = reg_wg_driver_ctrl[2:1];
assign o_period_sel         = reg_wg_driver_ctrl[7:3]; // 000:64;001:32;010:16;011:8;100:4;101:2;110:1;111:64;
//assign o_wg_drivera_en      = reg_wg_driver_ctrl[1];
//assign o_wg_driverc_en      = reg_wg_driver_ctrl[2];
//-----------------------------------------------
//ADDR_WG_DRV_REST_CLK_REG 
//-----------------------------------------------

assign reg_wg_driver_rest_t_wr0 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_REST_CLK_REG01+10'h40 * NO_OF_WAVEGEN));
assign reg_wg_driver_rest_t_wr1 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_REST_CLK_REG02+10'h40 * NO_OF_WAVEGEN));

//write to register
always @(posedge i_clk or negedge i_rst_n) begin
  if (~i_rst_n) begin
    reg_wg_driver_rest_t[7:0]   <= 8'h00;
    reg_wg_driver_rest_t[15:8]  <= 8'h00;
  end
  else begin
    reg_wg_driver_rest_t[7:0]   <= reg_wg_driver_rest_t_wr0 ? i_wr_data[7:0]  : reg_wg_driver_rest_t[7:0];
    reg_wg_driver_rest_t[15:8]  <= reg_wg_driver_rest_t_wr1 ? i_wr_data[7:0]  : reg_wg_driver_rest_t[15:8];    
 end
end

assign o_wg_driver_rest_t      = reg_wg_driver_rest_t;

//-----------------------------------------------
//ADDR_WG_DRV_SILENT_CLK_REG
//-----------------------------------------------
assign reg_wg_driver_silent_t_wr0 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_SILENT_CLK_REG01+10'h40 * NO_OF_WAVEGEN));
assign reg_wg_driver_silent_t_wr1 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_SILENT_CLK_REG02+10'h40 * NO_OF_WAVEGEN));
assign reg_wg_driver_silent_t_wr2 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_SILENT_CLK_REG03+10'h40 * NO_OF_WAVEGEN));
assign reg_wg_driver_silent_t_wr3 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_SILENT_CLK_REG04+10'h40 * NO_OF_WAVEGEN));

always @(posedge i_clk or negedge i_rst_n) begin
  if (~i_rst_n) begin
    reg_wg_driver_silent_t[7:0]  <= 8'h00;
    reg_wg_driver_silent_t[15:8] <= 8'h00;
    reg_wg_driver_silent_t[23:16] <= 8'h00;
    reg_wg_driver_silent_t[31:24] <= 8'h00;
  end
  else begin
    reg_wg_driver_silent_t[7:0]  <= reg_wg_driver_silent_t_wr0 ? i_wr_data[7:0]  : reg_wg_driver_silent_t[7:0];
    reg_wg_driver_silent_t[15:8] <= reg_wg_driver_silent_t_wr1 ? i_wr_data[7:0]  : reg_wg_driver_silent_t[15:8];
    reg_wg_driver_silent_t[23:16] <= reg_wg_driver_silent_t_wr2 ? i_wr_data[7:0]  : reg_wg_driver_silent_t[23:16];
    reg_wg_driver_silent_t[31:24] <= reg_wg_driver_silent_t_wr3 ? i_wr_data[7:0]  : reg_wg_driver_silent_t[31:24];
 end
end

assign o_wg_driver_silent_t      = reg_wg_driver_silent_t;

//-----------------------------------------------
//ADDR_WG_DRV_REST_CLK1_REG 
//-----------------------------------------------
assign reg_wg_driver_rest_t1_wr0 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_REST_CLK1_REG01+10'h40 * NO_OF_WAVEGEN));
assign reg_wg_driver_rest_t1_wr1 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_REST_CLK1_REG02+10'h40 * NO_OF_WAVEGEN));

//write to register
always @(posedge i_clk or negedge i_rst_n) begin
  if (~i_rst_n) begin
    reg_wg_driver_rest_t1[7:0]   <= 8'h00;
    reg_wg_driver_rest_t1[15:8]  <= 8'h00;
  end
  else begin
    reg_wg_driver_rest_t1[7:0]   <= reg_wg_driver_rest_t1_wr0 ? i_wr_data[7:0]  : reg_wg_driver_rest_t1[7:0];
    reg_wg_driver_rest_t1[15:8]  <= reg_wg_driver_rest_t1_wr1 ? i_wr_data[7:0]  : reg_wg_driver_rest_t1[15:8];    
 end
end

assign o_wg_driver_rest_t1      = reg_wg_driver_rest_t1;

//-----------------------------------------------
//ADDR_WG_DRV_SILENT_CLK1_REG
//-----------------------------------------------
assign reg_wg_driver_silent_t1_wr0 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_SILENT_CLK1_REG01+10'h40 * NO_OF_WAVEGEN));
assign reg_wg_driver_silent_t1_wr1 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_SILENT_CLK1_REG02+10'h40 * NO_OF_WAVEGEN));
assign reg_wg_driver_silent_t1_wr2 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_SILENT_CLK1_REG03+10'h40 * NO_OF_WAVEGEN));
assign reg_wg_driver_silent_t1_wr3 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_SILENT_CLK1_REG04+10'h40 * NO_OF_WAVEGEN));

always @(posedge i_clk or negedge i_rst_n) begin
  if (~i_rst_n) begin
    reg_wg_driver_silent_t1[7:0]  <= 8'h00;
    reg_wg_driver_silent_t1[15:8] <= 8'h00;
    reg_wg_driver_silent_t1[23:16] <= 8'h00;
    reg_wg_driver_silent_t1[31:24] <= 8'h00;
  end
  else begin
    reg_wg_driver_silent_t1[7:0]  <= reg_wg_driver_silent_t1_wr0 ? i_wr_data[7:0]  : reg_wg_driver_silent_t1[7:0];
    reg_wg_driver_silent_t1[15:8] <= reg_wg_driver_silent_t1_wr1 ? i_wr_data[7:0]  : reg_wg_driver_silent_t1[15:8];
    reg_wg_driver_silent_t1[23:16] <= reg_wg_driver_silent_t1_wr2 ? i_wr_data[7:0]  : reg_wg_driver_silent_t1[23:16];
    reg_wg_driver_silent_t1[31:24] <= reg_wg_driver_silent_t1_wr3 ? i_wr_data[7:0]  : reg_wg_driver_silent_t1[31:24];
 end
end

assign o_wg_driver_silent_t1      = reg_wg_driver_silent_t1;


//-----------------------------------------------
//ADDR_WG_DRV_REST_CLK2_REG 
//-----------------------------------------------
assign reg_wg_driver_rest_t2_wr0 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_REST_CLK2_REG01+10'h40 * NO_OF_WAVEGEN));
assign reg_wg_driver_rest_t2_wr1 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_REST_CLK2_REG02+10'h40 * NO_OF_WAVEGEN));

//write to register
always @(posedge i_clk or negedge i_rst_n) begin
  if (~i_rst_n) begin
    reg_wg_driver_rest_t2[7:0]   <= 8'h00;
    reg_wg_driver_rest_t2[15:8]  <= 8'h00;
  end
  else begin
    reg_wg_driver_rest_t2[7:0]   <= reg_wg_driver_rest_t2_wr0 ? i_wr_data[7:0]  : reg_wg_driver_rest_t2[7:0];
    reg_wg_driver_rest_t2[15:8]  <= reg_wg_driver_rest_t2_wr1 ? i_wr_data[7:0]  : reg_wg_driver_rest_t2[15:8];    
 end
end

assign o_wg_driver_rest_t2      = reg_wg_driver_rest_t2;

//-----------------------------------------------
//ADDR_WG_DRV_SILENT_CLK2_REG
//-----------------------------------------------
assign reg_wg_driver_silent_t2_wr0 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_SILENT_CLK2_REG01+10'h40 * NO_OF_WAVEGEN));
assign reg_wg_driver_silent_t2_wr1 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_SILENT_CLK2_REG02+10'h40 * NO_OF_WAVEGEN));
assign reg_wg_driver_silent_t2_wr2 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_SILENT_CLK2_REG03+10'h40 * NO_OF_WAVEGEN));
assign reg_wg_driver_silent_t2_wr3 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_SILENT_CLK2_REG04+10'h40 * NO_OF_WAVEGEN));

always @(posedge i_clk or negedge i_rst_n) begin
  if (~i_rst_n) begin
    reg_wg_driver_silent_t2[7:0]  <= 8'h00;
    reg_wg_driver_silent_t2[15:8] <= 8'h00;
    reg_wg_driver_silent_t2[23:16] <= 8'h00;
    reg_wg_driver_silent_t2[31:24] <= 8'h00;
  end
  else begin
    reg_wg_driver_silent_t2[7:0]  <= reg_wg_driver_silent_t2_wr0 ? i_wr_data[7:0]  : reg_wg_driver_silent_t2[7:0];
    reg_wg_driver_silent_t2[15:8] <= reg_wg_driver_silent_t2_wr1 ? i_wr_data[7:0]  : reg_wg_driver_silent_t2[15:8];
    reg_wg_driver_silent_t2[23:16] <= reg_wg_driver_silent_t2_wr2 ? i_wr_data[7:0]  : reg_wg_driver_silent_t2[23:16];
    reg_wg_driver_silent_t2[31:24] <= reg_wg_driver_silent_t2_wr3 ? i_wr_data[7:0]  : reg_wg_driver_silent_t2[31:24];
 end
end

assign o_wg_driver_silent_t2      = reg_wg_driver_silent_t2;

//-----------------------------------------------
//ADDR_WG_DRV_HLF_WAVE_CLK_PNT_REG 
//-----------------------------------------------
assign reg_wg_driver_hlf_wave_prd_wr0 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_HLF_WAVE_CLK_PNT_REG01+10'h40 * NO_OF_WAVEGEN));
assign reg_wg_driver_hlf_wave_prd_wr1 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_HLF_WAVE_CLK_PNT_REG02+10'h40 * NO_OF_WAVEGEN));
//assign reg_wg_driver_hlf_wave_prd_wr2 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_HLF_WAVE_CLK_PNT_REG03+10'h40 * NO_OF_WAVEGEN));
//assign reg_wg_driver_hlf_wave_prd_wr3 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_HLF_WAVE_CLK_PNT_REG04+10'h40 * NO_OF_WAVEGEN));

//write to register
always @(posedge i_clk or negedge i_rst_n) begin
  if (~i_rst_n) begin
    reg_wg_driver_hlf_wave_prd[7:0]  <= 8'h00;
    reg_wg_driver_hlf_wave_prd[15:8] <= 8'h00;
//  reg_wg_driver_hlf_wave_prd[23:16] <= 8'h00;
//  reg_wg_driver_hlf_wave_prd[31:24] <= 8'h00;
  end
  else begin
    reg_wg_driver_hlf_wave_prd[7:0]  <= reg_wg_driver_hlf_wave_prd_wr0 ? i_wr_data[7:0]  : reg_wg_driver_hlf_wave_prd[7:0];
    reg_wg_driver_hlf_wave_prd[15:8] <= reg_wg_driver_hlf_wave_prd_wr1 ? i_wr_data[7:0]  : reg_wg_driver_hlf_wave_prd[15:8];
//  reg_wg_driver_hlf_wave_prd[23:16] <= reg_wg_driver_hlf_wave_prd_wr2 ? i_wr_data[7:0]  : reg_wg_driver_hlf_wave_prd[23:16];
//  reg_wg_driver_hlf_wave_prd[31:24] <= reg_wg_driver_hlf_wave_prd_wr3 ? i_wr_data[7:0]  : reg_wg_driver_hlf_wave_prd[31:24];
 end
end

assign o_wg_driver_hlf_wave_prd      = reg_wg_driver_hlf_wave_prd;

//-----------------------------------------------
//ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT_REG 
//-----------------------------------------------
assign reg_wg_driver_neg_hlf_wave_prd_wr0 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT_REG01+10'h40 * NO_OF_WAVEGEN));
assign reg_wg_driver_neg_hlf_wave_prd_wr1 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT_REG02+10'h40 * NO_OF_WAVEGEN));
//assign reg_wg_driver_neg_hlf_wave_prd_wr2 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT_REG03+10'h40 * NO_OF_WAVEGEN));
//assign reg_wg_driver_neg_hlf_wave_prd_wr3 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT_REG04+10'h40 * NO_OF_WAVEGEN));

//write to register
always @(posedge i_clk or negedge i_rst_n) begin
  if (~i_rst_n) begin
    reg_wg_driver_neg_hlf_wave_prd[7:0]  <= 8'h00;
    reg_wg_driver_neg_hlf_wave_prd[15:8] <= 8'h00;
//  reg_wg_driver_neg_hlf_wave_prd[23:16] <= 8'h00;
//  reg_wg_driver_neg_hlf_wave_prd[31:24] <= 8'h00;
  end
  else begin
    reg_wg_driver_neg_hlf_wave_prd[7:0]  <= reg_wg_driver_neg_hlf_wave_prd_wr0 ? i_wr_data[7:0]  : reg_wg_driver_neg_hlf_wave_prd[7:0];
    reg_wg_driver_neg_hlf_wave_prd[15:8] <= reg_wg_driver_neg_hlf_wave_prd_wr1 ? i_wr_data[7:0]  : reg_wg_driver_neg_hlf_wave_prd[15:8];
//  reg_wg_driver_neg_hlf_wave_prd[23:16] <= reg_wg_driver_neg_hlf_wave_prd_wr2 ? i_wr_data[7:0]  : reg_wg_driver_neg_hlf_wave_prd[23:16];
//  reg_wg_driver_neg_hlf_wave_prd[31:24] <= reg_wg_driver_neg_hlf_wave_prd_wr3 ? i_wr_data[7:0]  : reg_wg_driver_neg_hlf_wave_prd[31:24];
 end
end

assign o_wg_driver_neg_hlf_wave_prd      = reg_wg_driver_neg_hlf_wave_prd;

//-----------------------------------------------
//ADDR_WG_DRV_HLF_WAVE_CLK_PNT1_REG 
//-----------------------------------------------
assign reg_wg_driver_hlf_wave_prd1_wr0 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_HLF_WAVE_CLK_PNT1_REG01+10'h40 * NO_OF_WAVEGEN));
assign reg_wg_driver_hlf_wave_prd1_wr1 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_HLF_WAVE_CLK_PNT1_REG02+10'h40 * NO_OF_WAVEGEN));
//assign reg_wg_driver_hlf_wave_prd1_wr2 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_HLF_WAVE_CLK_PNT1_REG03+10'h40 * NO_OF_WAVEGEN));
//assign reg_wg_driver_hlf_wave_prd1_wr3 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_HLF_WAVE_CLK_PNT1_REG04+10'h40 * NO_OF_WAVEGEN));

//write to register
always @(posedge i_clk or negedge i_rst_n) begin
  if (~i_rst_n) begin
    reg_wg_driver_hlf_wave_prd1[7:0]  <= 8'h00;
    reg_wg_driver_hlf_wave_prd1[15:8] <= 8'h00;
//  reg_wg_driver_hlf_wave_prd1[23:16] <= 8'h00;
//  reg_wg_driver_hlf_wave_prd1[31:24] <= 8'h00;
  end
  else begin
    reg_wg_driver_hlf_wave_prd1[7:0]  <= reg_wg_driver_hlf_wave_prd1_wr0 ? i_wr_data[7:0]  : reg_wg_driver_hlf_wave_prd1[7:0];
    reg_wg_driver_hlf_wave_prd1[15:8] <= reg_wg_driver_hlf_wave_prd1_wr1 ? i_wr_data[7:0]  : reg_wg_driver_hlf_wave_prd1[15:8];
//  reg_wg_driver_hlf_wave_prd1[23:16] <= reg_wg_driver_hlf_wave_prd1_wr2 ? i_wr_data[7:0]  : reg_wg_driver_hlf_wave_prd1[23:16];
//  reg_wg_driver_hlf_wave_prd1[31:24] <= reg_wg_driver_hlf_wave_prd1_wr3 ? i_wr_data[7:0]  : reg_wg_driver_hlf_wave_prd1[31:24];
 end
end

assign o_wg_driver_hlf_wave_prd1      = reg_wg_driver_hlf_wave_prd1;

//-----------------------------------------------
//ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT1_REG 
//-----------------------------------------------
assign reg_wg_driver_neg_hlf_wave_prd1_wr0 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT1_REG01+10'h40 * NO_OF_WAVEGEN));
assign reg_wg_driver_neg_hlf_wave_prd1_wr1 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT1_REG02+10'h40 * NO_OF_WAVEGEN));
//assign reg_wg_driver_neg_hlf_wave_prd1_wr2 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT1_REG03+10'h40 * NO_OF_WAVEGEN));
//assign reg_wg_driver_neg_hlf_wave_prd1_wr3 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT1_REG04+10'h40 * NO_OF_WAVEGEN));

//write to register
always @(posedge i_clk or negedge i_rst_n) begin
  if (~i_rst_n) begin
    reg_wg_driver_neg_hlf_wave_prd1[7:0]  <= 8'h00;
    reg_wg_driver_neg_hlf_wave_prd1[15:8] <= 8'h00;
//  reg_wg_driver_neg_hlf_wave_prd1[23:16] <= 8'h00;
//  reg_wg_driver_neg_hlf_wave_prd1[31:24] <= 8'h00;
  end
  else begin
    reg_wg_driver_neg_hlf_wave_prd1[7:0]  <= reg_wg_driver_neg_hlf_wave_prd1_wr0 ? i_wr_data[7:0]  : reg_wg_driver_neg_hlf_wave_prd1[7:0];
    reg_wg_driver_neg_hlf_wave_prd1[15:8] <= reg_wg_driver_neg_hlf_wave_prd1_wr1 ? i_wr_data[7:0]  : reg_wg_driver_neg_hlf_wave_prd1[15:8];
//  reg_wg_driver_neg_hlf_wave_prd1[23:16] <= reg_wg_driver_neg_hlf_wave_prd1_wr2 ? i_wr_data[7:0]  : reg_wg_driver_neg_hlf_wave_prd1[23:16];
//  reg_wg_driver_neg_hlf_wave_prd1[31:24] <= reg_wg_driver_neg_hlf_wave_prd1_wr3 ? i_wr_data[7:0]  : reg_wg_driver_neg_hlf_wave_prd1[31:24];
 end
end

assign o_wg_driver_neg_hlf_wave_prd1      = reg_wg_driver_neg_hlf_wave_prd1;

//-----------------------------------------------
//ADDR_WG_DRV_HLF_WAVE_CLK_PNT2_REG 
//-----------------------------------------------
assign reg_wg_driver_hlf_wave_prd2_wr0 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_HLF_WAVE_CLK_PNT2_REG01+10'h40 * NO_OF_WAVEGEN));
assign reg_wg_driver_hlf_wave_prd2_wr1 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_HLF_WAVE_CLK_PNT2_REG02+10'h40 * NO_OF_WAVEGEN));
//assign reg_wg_driver_hlf_wave_prd2_wr2 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_HLF_WAVE_CLK_PNT2_REG03+10'h40 * NO_OF_WAVEGEN));
//assign reg_wg_driver_hlf_wave_prd2_wr3 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_HLF_WAVE_CLK_PNT2_REG04+10'h40 * NO_OF_WAVEGEN));

//write to register
always @(posedge i_clk or negedge i_rst_n) begin
  if (~i_rst_n) begin
    reg_wg_driver_hlf_wave_prd2[7:0]  <= 8'h00;
    reg_wg_driver_hlf_wave_prd2[15:8] <= 8'h00;
//  reg_wg_driver_hlf_wave_prd2[23:16] <= 8'h00;
//  reg_wg_driver_hlf_wave_prd2[31:24] <= 8'h00;
  end
  else begin
    reg_wg_driver_hlf_wave_prd2[7:0]  <= reg_wg_driver_hlf_wave_prd2_wr0 ? i_wr_data[7:0]  : reg_wg_driver_hlf_wave_prd2[7:0];
    reg_wg_driver_hlf_wave_prd2[15:8] <= reg_wg_driver_hlf_wave_prd2_wr1 ? i_wr_data[7:0]  : reg_wg_driver_hlf_wave_prd2[15:8];
//  reg_wg_driver_hlf_wave_prd2[23:16] <= reg_wg_driver_hlf_wave_prd2_wr2 ? i_wr_data[7:0]  : reg_wg_driver_hlf_wave_prd2[23:16];
//  reg_wg_driver_hlf_wave_prd2[31:24] <= reg_wg_driver_hlf_wave_prd2_wr3 ? i_wr_data[7:0]  : reg_wg_driver_hlf_wave_prd2[31:24];
 end
end

assign o_wg_driver_hlf_wave_prd2      = reg_wg_driver_hlf_wave_prd2;

//-----------------------------------------------
//ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT2_REG 
//-----------------------------------------------
assign reg_wg_driver_neg_hlf_wave_prd2_wr0 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT2_REG01+10'h40 * NO_OF_WAVEGEN));
assign reg_wg_driver_neg_hlf_wave_prd2_wr1 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT2_REG02+10'h40 * NO_OF_WAVEGEN));
//assign reg_wg_driver_neg_hlf_wave_prd2_wr2 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT2_REG03+10'h40 * NO_OF_WAVEGEN));
//assign reg_wg_driver_neg_hlf_wave_prd2_wr3 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT2_REG04+10'h40 * NO_OF_WAVEGEN));

//write to register
always @(posedge i_clk or negedge i_rst_n) begin
  if (~i_rst_n) begin
    reg_wg_driver_neg_hlf_wave_prd2[7:0]  <= 8'h00;
    reg_wg_driver_neg_hlf_wave_prd2[15:8] <= 8'h00;
//  reg_wg_driver_neg_hlf_wave_prd2[23:16] <= 8'h00;
//  reg_wg_driver_neg_hlf_wave_prd2[31:24] <= 8'h00;
  end
  else begin
    reg_wg_driver_neg_hlf_wave_prd2[7:0]  <= reg_wg_driver_neg_hlf_wave_prd2_wr0 ? i_wr_data[7:0]  : reg_wg_driver_neg_hlf_wave_prd2[7:0];
    reg_wg_driver_neg_hlf_wave_prd2[15:8] <= reg_wg_driver_neg_hlf_wave_prd2_wr1 ? i_wr_data[7:0]  : reg_wg_driver_neg_hlf_wave_prd2[15:8];
//  reg_wg_driver_neg_hlf_wave_prd2[23:16] <= reg_wg_driver_neg_hlf_wave_prd2_wr2 ? i_wr_data[7:0]  : reg_wg_driver_neg_hlf_wave_prd2[23:16];
//  reg_wg_driver_neg_hlf_wave_prd2[31:24] <= reg_wg_driver_neg_hlf_wave_prd2_wr3 ? i_wr_data[7:0]  : reg_wg_driver_neg_hlf_wave_prd2[31:24];
 end
end

assign o_wg_driver_neg_hlf_wave_prd2      = reg_wg_driver_neg_hlf_wave_prd2;

//-----------------------------------------------
//ADDR_WG_DRV_POINT_CONFIG 
//-----------------------------------------------
assign reg_wg_driver_point_config_wr = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_POINT_CONFIG+10'h40 * NO_OF_WAVEGEN));

//write to register
always @(posedge i_clk or negedge i_rst_n) begin
  if (~i_rst_n) begin
    reg_wg_driver_point_config  <= 8'h40;
  end
  else begin
    reg_wg_driver_point_config  <= reg_wg_driver_point_config_wr? i_wr_data[7:0]  : reg_wg_driver_point_config;
 end
end

assign o_reg_wg_driver_point_config      = reg_wg_driver_point_config;



//-----------------------------------------------
//ADDR_WG_DRV_CLK_FREQ_REG 
//-----------------------------------------------
//
//assign reg_wg_driver_clk_freq_wr0 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_CLK_FREQ_REG0+10'h40 * NO_OF_WAVEGEN));

//write to register
//always @(posedge i_clk or negedge i_rst_n) begin
//  if (~i_rst_n) begin
//    reg_wg_driver_clk_freq[7:0]  <= 8'h00;
//  end
//  else begin
//    reg_wg_driver_clk_freq[7:0]  <= reg_wg_driver_clk_freq_wr0 ? i_wr_data[7:0]  : reg_wg_driver_clk_freq[7:0];
// end
//end

//assign o_wg_driver_clk_freq	     = reg_wg_driver_clk_freq;

//-----------------------------------------------
//ADDR_WG_DRV_IN_WAVE_ADDR_REG 0X18 AND ADDR_WG_DRV_IN_WAVE_REG	
//-----------------------------------------------

assign reg_wg_driver_in_wave_addr_wr0 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_IN_WAVE_ADDR_REG0+10'h40 * NO_OF_WAVEGEN));
assign reg_wg_driver_in_wave_wr0 = 	i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_IN_WAVE_REG01+10'h40 * NO_OF_WAVEGEN));

//write to reg_wg_driver_in_wave
always @(posedge i_clk or negedge i_rst_n) begin
  if (~i_rst_n) begin
    reg_wg_driver_in_wave_addr[7:0]  <= 8'h00;
    for(integer i=0;i<2**HLF_WV_NO_PTS;i=i+1)begin
    reg_wg_driver_in_wave[i]  <= 8'h00;
    end
  end
  else begin
    reg_wg_driver_in_wave_addr[7:0]  <= 			reg_wg_driver_in_wave_addr_wr0 ? i_wr_data[7:0]  : reg_wg_driver_in_wave_addr[7:0];
    reg_wg_driver_in_wave[reg_wg_driver_in_wave_addr]  <= 	reg_wg_driver_in_wave_wr0 ? 	 i_wr_data[7:0]  : reg_wg_driver_in_wave[reg_wg_driver_in_wave_addr];
 end
end


wire [OUT_NO_BITS-1:0] wave_sine_arr[(2**HLF_WV_NO_PTS)/2:0];
wire [OUT_NO_BITS-1:0] wave_pluse_arr;
wire [OUT_NO_BITS-1:0] wave_triangle_arr[(2**HLF_WV_NO_PTS)/2:0];

assign wave_sine_arr[64:0]  =  '{8'h00,8'h06,8'h0c,8'h12,8'h18,8'h1f,8'h25,8'h2b,8'h31,8'h37,8'h3d,8'h44,8'h4a,8'h4f,8'h55,8'h5b,8'h61,8'h67,8'h6d,8'h72,8'h78,8'h7d,8'h83,8'h88,8'h8d,8'h92,8'h97,8'h9c, 8'ha1,8'ha6, 8'hab,8'haf,8'hb4,8'hb8,8'hbc,8'hc1,8'hc5,8'hc9,8'hcc,8'hd0,8'hd4,8'hd7,8'hda,8'hdd,8'he0,8'he3,8'he6,8'he9,8'heb,8'hed,8'hf0,8'hf2,8'hf4,8'hf5,8'hf7,8'hf8,8'hfa,8'hfb,8'hfc,8'hfd,8'hfd,8'hfe,8'hfe,8'hfe,8'hff};

assign wave_pluse_arr       = 8'hff;

assign wave_triangle_arr[64:0]  =  '{8'd00,8'h03,8'h07,8'h0b,8'h0f,8'h13,8'h17,8'h1b,8'h1f,8'h23,8'h27,8'h2b,8'h2f,8'h33,8'h37,8'h3b,8'h3f,8'h43,8'h47,8'h4b,8'h4f,8'h53,8'h57,8'h5b,8'h5f,8'h63,8'h67,8'h6b,8'h6f,8'h73,8'h77,8'h7b,8'h7f,8'h83,8'h87,8'h8b,8'h8f,8'h93,8'h97,8'h9b,8'h9f,8'ha3,8'ha7,8'hab,8'haf,8'hb3,8'hb7,8'hbb,8'hbf,8'hc3,8'hc7,8'hcb,8'hcf,8'hd3,8'hd7,8'hdb,8'hdf,8'he3,8'he7,8'heb,8'hef,8'hf3,8'hf7,8'hfb,8'hff};

wire [7:0] w_in_wave_tmp;
wire [7:0] w_in_wave_tmp_sine;
wire [7:0] w_in_wave_tmp_pluse;
wire [7:0] w_in_wave_tmp_triangle;

wire [7:0]  wg_driver_in_wave_addr_sine;
wire [7:0]  wg_driver_in_wave_addr_triangle;
wire [7:0]  wg_driver_in_wave_addr_normal;

wire sine_en,triangle_en,normal_en;
assign sine_en     = ((o_period_sel[2:0]==3'b000) && (waveform_preload==2'b00)) || ((o_period_sel[2:0]==3'b001) && !waveform_preload[1]) || ((o_period_sel[2:0]==3'b010) && !waveform_preload[1]);
assign triangle_en = ((o_period_sel[2:0]==3'b000) && (waveform_preload==2'b10)) || ((o_period_sel[2:0]==3'b001) && ^waveform_preload) || ((o_period_sel[2:0]==3'b010) && !waveform_preload[1]);
assign normal_en   = ((o_period_sel[2:0]==3'b000) && (waveform_preload==2'b11)) || ((o_period_sel[2:0]==3'b001) && &waveform_preload) || ((o_period_sel[2:0]==3'b010) &&  waveform_preload[1]) || (o_period_sel[2:0]==3'b011) || (o_period_sel[2]==1'b1);
                                       
assign wg_driver_in_wave_addr_sine     = i_wg_driver_in_wave_addr & ({8{sine_en}});
assign wg_driver_in_wave_addr_triangle = i_wg_driver_in_wave_addr & ({8{triangle_en}});
assign wg_driver_in_wave_addr_normal   = i_wg_driver_in_wave_addr & ({8{normal_en}});

wire wave_1st,wave_2nd,wave_3rd;
assign wave_1st = i_period_num==2'b00;
assign wave_2nd = i_period_num==2'b01;
assign wave_3rd = i_period_num==2'b10;

assign w_in_wave_tmp = (o_period_sel[2:0]==3'b000)? (waveform_preload==2'b00) ?  w_in_wave_tmp_sine  :
	                                            (waveform_preload==2'b01) ?  w_in_wave_tmp_pluse :
	                                            (waveform_preload==2'b10) ?  w_in_wave_tmp_triangle : reg_wg_driver_in_wave[wg_driver_in_wave_addr_normal] : 
                       (o_period_sel[2:0]==3'b001)? (waveform_preload==2'b00) ?  (w_in_wave_tmp_sine & ({8{wave_1st}})) | (w_in_wave_tmp_pluse & ({8{wave_2nd}})) :
	                                            (waveform_preload==2'b01) ?  (w_in_wave_tmp_sine & ({8{wave_1st}})) | (w_in_wave_tmp_triangle & ({8{wave_2nd}})):
	                                            (waveform_preload==2'b10) ?  (w_in_wave_tmp_pluse & ({8{wave_1st}}))| (w_in_wave_tmp_triangle & ({8{wave_2nd}})) : reg_wg_driver_in_wave[wg_driver_in_wave_addr_normal] : 
                       (o_period_sel[2:0]==3'b010)? (waveform_preload==2'b00) ?  (w_in_wave_tmp_sine & ({8{wave_1st}})) | (w_in_wave_tmp_pluse & ({8{wave_2nd}}))    | (w_in_wave_tmp_triangle & ({8{wave_3rd}})):
	                                            (waveform_preload==2'b01) ?  (w_in_wave_tmp_sine & ({8{wave_1st}})) | (w_in_wave_tmp_triangle & ({8{wave_2nd}})) | (w_in_wave_tmp_pluse & ({8{wave_3rd}})):
	                                                                         reg_wg_driver_in_wave[wg_driver_in_wave_addr_normal] : reg_wg_driver_in_wave[wg_driver_in_wave_addr_normal];

wire [7:0] addr_con,pos_addr_con,neg_addr_con,pos_addr_con1,neg_addr_con1;

wire point_index_33_64,point_index_17_32,point_index_9_16,point_index_5_8,point_index_3_4,point_index_2,point_index_1,point_index_0;
wire [2:0] point_slt_index;

assign  point_index_33_64 = (o_reg_wg_driver_point_config >= 8'h41) && (o_reg_wg_driver_point_config <= 8'h80);
assign  point_index_17_32 = (o_reg_wg_driver_point_config >= 8'h21) && (o_reg_wg_driver_point_config <= 8'h40);
assign  point_index_9_16  = (o_reg_wg_driver_point_config >= 8'h11) && (o_reg_wg_driver_point_config <= 8'h20);
assign  point_index_5_8   = (o_reg_wg_driver_point_config >= 8'h9)  && (o_reg_wg_driver_point_config <= 8'h10);
assign  point_index_3_4   = (o_reg_wg_driver_point_config >= 8'h5)  && (o_reg_wg_driver_point_config <= 8'h8 );
assign  point_index_2     = (o_reg_wg_driver_point_config == 8'h3)  || (o_reg_wg_driver_point_config == 8'h4 );
assign  point_index_1     = (o_reg_wg_driver_point_config == 8'h2);
assign  point_index_0     = (o_reg_wg_driver_point_config == 8'h1);

assign point_slt_index = point_index_17_32 ? 3'b000 : 
                         point_index_9_16  ? 3'b001 :
                         point_index_5_8   ? 3'b010 :
                         point_index_3_4   ? 3'b011 :
                         point_index_2     ? 3'b100 :
                         point_index_1     ? 3'b101 :
                         point_index_0     ? 3'b110 :
                         point_index_33_64 ? 3'b111 : 3'b000;

assign addr_con = (point_slt_index[2:0]==3'b000)? 8'd31 :
                  (point_slt_index[2:0]==3'b001)? 8'd15 :
                  (point_slt_index[2:0]==3'b010)? 8'd7  :
                  (point_slt_index[2:0]==3'b011)? 8'd3  :
                  (point_slt_index[2:0]==3'b100)? 8'd1  :
                  (point_slt_index[2:0]==3'b101)? 8'd0  :
                  (point_slt_index[2:0]==3'b110)? 8'd0  : 
                  (point_slt_index[2:0]==3'b111)? 8'd63 :  8'd31;                  

assign pos_addr_con = (wg_driver_in_wave_addr_sine <= addr_con)? (point_slt_index[2:0]==3'b000)? (8'd62 - wg_driver_in_wave_addr_sine*2) :
                                                                 (point_slt_index[2:0]==3'b001)? (8'd60 - wg_driver_in_wave_addr_sine*4) :
                                                                 (point_slt_index[2:0]==3'b010)? (8'd56 - wg_driver_in_wave_addr_sine*8) :
                                                                 (point_slt_index[2:0]==3'b011)? (8'd48 - wg_driver_in_wave_addr_sine*16) :
                                                                 (point_slt_index[2:0]==3'b100)? (8'd32 - wg_driver_in_wave_addr_sine*32) :
                                                                 (point_slt_index[2:0]==3'b101)? (8'd0) :
                                                                 (point_slt_index[2:0]==3'b110)? (8'd0) : 
                                                                 (point_slt_index[2:0]==3'b111)? (8'd63 - wg_driver_in_wave_addr_sine) :        (8'd62 - wg_driver_in_wave_addr_sine*2)
                                                               : 8'h00;

assign neg_addr_con = (wg_driver_in_wave_addr_sine <= addr_con)? 8'h00 :
                                                                 (point_slt_index[2:0]==3'b000)? (wg_driver_in_wave_addr_sine*2  - 8'd62) :
                                                                 (point_slt_index[2:0]==3'b001)? (wg_driver_in_wave_addr_sine*4  - 8'd60) :
                                                                 (point_slt_index[2:0]==3'b010)? (wg_driver_in_wave_addr_sine*8  - 8'd56) :
                                                                 (point_slt_index[2:0]==3'b011)? (wg_driver_in_wave_addr_sine*16 - 8'd48) :
                                                                 (point_slt_index[2:0]==3'b100)? (wg_driver_in_wave_addr_sine*32 - 8'd32) :
                                                                 (point_slt_index[2:0]==3'b101)? (8'd64) :
                                                                 (point_slt_index[2:0]==3'b110)? (8'd0) : 
                                                                 (point_slt_index[2:0]==3'b111)? (wg_driver_in_wave_addr_sine-8'd63) :        (8'd62 - wg_driver_in_wave_addr_sine*2);

assign pos_addr_con1 = (wg_driver_in_wave_addr_triangle <= addr_con)?  (point_slt_index[2:0]==3'b000)? (8'd62 - wg_driver_in_wave_addr_triangle*2) :
                                                                       (point_slt_index[2:0]==3'b001)? (8'd60 - wg_driver_in_wave_addr_triangle*4) :
                                                                       (point_slt_index[2:0]==3'b010)? (8'd56 - wg_driver_in_wave_addr_triangle*8) :
                                                                       (point_slt_index[2:0]==3'b011)? (8'd48 - wg_driver_in_wave_addr_triangle*16) :
                                                                       (point_slt_index[2:0]==3'b100)? (8'd32 - wg_driver_in_wave_addr_triangle*32) :
                                                                       (point_slt_index[2:0]==3'b101)? (8'd0) :
                                                                       (point_slt_index[2:0]==3'b110)? (8'd0) : 
                                                                       (point_slt_index[2:0]==3'b111)? (8'd63 - wg_driver_in_wave_addr_triangle) :        (8'd62 - wg_driver_in_wave_addr_triangle*2)
                                                                    : 8'h00;

assign neg_addr_con1 = (wg_driver_in_wave_addr_triangle <= addr_con)?  8'h00 :
                                                                       (point_slt_index[2:0]==3'b000)? (wg_driver_in_wave_addr_triangle*2  - 8'd62) :
                                                                       (point_slt_index[2:0]==3'b001)? (wg_driver_in_wave_addr_triangle*4  - 8'd60) :
                                                                       (point_slt_index[2:0]==3'b010)? (wg_driver_in_wave_addr_triangle*8  - 8'd56) :
                                                                       (point_slt_index[2:0]==3'b011)? (wg_driver_in_wave_addr_triangle*16 - 8'd48) :
                                                                       (point_slt_index[2:0]==3'b100)? (wg_driver_in_wave_addr_triangle*32 - 8'd32) :
                                                                       (point_slt_index[2:0]==3'b101)? (8'd64) :
                                                                       (point_slt_index[2:0]==3'b110)? (8'd0) : 
                                                                       (point_slt_index[2:0]==3'b111)? (wg_driver_in_wave_addr_triangle-8'd63) :        (8'd62 - wg_driver_in_wave_addr_triangle*2);

assign w_in_wave_tmp_sine     = (wg_driver_in_wave_addr_sine <= addr_con)? wave_sine_arr[pos_addr_con] : wave_sine_arr[neg_addr_con];
assign w_in_wave_tmp_pluse    =  wave_pluse_arr;
assign w_in_wave_tmp_triangle = (wg_driver_in_wave_addr_triangle <= addr_con)? wave_triangle_arr[pos_addr_con1] : wave_triangle_arr[neg_addr_con1];

wire [15:0] boot_mul_wave_tmp_neg;
wire [15:0] boot_mul_wave_tmp_pos;
wire [16:0] pos_wg_driver_in_wave,neg_wg_driver_in_wave;
wire [11:0] pos_wg_driver_in_wave_temp,neg_wg_driver_in_wave_temp;
wire [7:0] data_carrier;
wire [11:0]  data_envelope;
wire [19:0] data_mul_final;

assign neg_wg_driver_in_wave = wg_driver_neg_scale[7] ?  (({9'b0,w_in_wave_tmp} >> wg_driver_neg_scale[6:0]) + {9'b0,wg_driver_neg_offset}): {1'b0,boot_mul_wave_tmp_neg} + {9'b0,wg_driver_neg_offset};
assign pos_wg_driver_in_wave = wg_driver_pos_scale[7]     ?  (({9'b0,w_in_wave_tmp} >> wg_driver_pos_scale[6:0]) + {9'b0,wg_driver_pos_offset} ): {1'b0,boot_mul_wave_tmp_pos} + {9'b0,wg_driver_pos_offset};

assign pos_wg_driver_in_wave_temp = (pos_wg_driver_in_wave<= 17'hfff)? pos_wg_driver_in_wave[11:0] : 12'hfff;
assign neg_wg_driver_in_wave_temp = (neg_wg_driver_in_wave<= 17'hfff)? neg_wg_driver_in_wave[11:0] : 12'hfff;

assign data_envelope  = (!w_continue & i_wg_driver_int_sts[1]) ? 12'b0 : (i_wg_driver_source==2) ? neg_wg_driver_in_wave_temp : pos_wg_driver_in_wave_temp; //if we arrive at the second address interrupt (meaning that we are falling behind in inserting new waves), if w_continue is 1, then we ignore the interrupt and will repeat the wave in the output as a reult. For hearing aid, it means the person will hear a repeating sound if microcontroller is slow in loading the next sound waveform. Unless w_continue is 0, in which case no wave form will be sent out until the interrupt is cleared
assign data_carrier = ems_data_ctrl[3]? reg_wg_driver_in_wave[i_wg_driver_ems_wave_addr] : 8'h01;
assign data_mul_final= data_carrier * data_envelope;
assign o_wg_driver_in_wave = ems_data_ctrl[3]? data_mul_final >> ems_data_ctrl[2:0] : data_mul_final[11:0];

/*
boot_mul#(.BOOT_MUL(1'b0))
u_boot_mul(
.a_i(w_in_wave_tmp),
.b_i(reg_wg_driver_neg_scale),
.sign_i(1'b0),
.mul_o(boot_mul_wave_tmp_neg)

);

boot_mul#(.BOOT_MUL(1'b0))
u_boot_mul_pos(
.a_i(w_in_wave_tmp),
.b_i(wg_driver_pos_scale),
.sign_i(1'b0),
.mul_o(boot_mul_wave_tmp_pos)

);
*/

wire [3:0] data_scl_r;
assign o_data_scl   = (drive_ctrl_reg2[6:4]<=3'b100)? drive_ctrl_reg2[7:4] : {drive_ctrl_reg2[7],3'h0};
assign data_scl_r   = data_scl;

wire [7:0] w_in_wave_tmp_lp,w_in_wave_tmp_lp1;

assign w_in_wave_tmp_lp = data_scl[3]? w_in_wave_tmp : 8'h00;
assign w_in_wave_tmp_lp1 = ~data_scl[3]? w_in_wave_tmp : 8'h00;

assign boot_mul_wave_tmp_neg = wg_driver_neg_scale[7]? 16'h0000 : !data_scl[3]? ({4'b0,w_in_wave_tmp_lp1,4'b0} >> data_scl_r) : {8'h00,w_in_wave_tmp_lp} * {8'h00,wg_driver_neg_scale};
assign boot_mul_wave_tmp_pos = wg_driver_pos_scale[7]    ? 16'h0000 : !data_scl[3]? ({4'b0,w_in_wave_tmp_lp1,4'b0} >> data_scl_r) : {8'h00,w_in_wave_tmp_lp} * {8'h00,wg_driver_pos_scale};

//-----------------------------------------------
//ADDR_WG_DRV_ALT_LIM_REG		
//-----------------------------------------------
assign reg_wg_driver_alt_lim_wr0 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_ALT_LIM_REG01+10'h40 * NO_OF_WAVEGEN));
assign reg_wg_driver_alt_lim_wr1 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_ALT_LIM_REG02+10'h40 * NO_OF_WAVEGEN));

//write to register
always @(posedge i_clk or negedge i_rst_n) begin
  if (~i_rst_n) begin
    reg_wg_driver_alt_lim[7:0]  <= 8'h00;
    reg_wg_driver_alt_lim[15:8] <= 8'h00;
  end
  else begin
    reg_wg_driver_alt_lim[7:0]  <= reg_wg_driver_alt_lim_wr0 ? i_wr_data[7:0]  : reg_wg_driver_alt_lim[7:0];
    reg_wg_driver_alt_lim[15:8] <= reg_wg_driver_alt_lim_wr1 ? i_wr_data[7:0]  : reg_wg_driver_alt_lim[15:8];
 end
end

assign o_wg_driver_alter_lim      = reg_wg_driver_alt_lim;

//-----------------------------------------------
//ADDR_WG_DRV_ALT_SILENT_LIM_REG		
//-----------------------------------------------
assign reg_wg_driver_alt_silent_lim_wr0 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_ALT_SILENT_LIM_REG01+10'h40 * NO_OF_WAVEGEN));
assign reg_wg_driver_alt_silent_lim_wr1 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_ALT_SILENT_LIM_REG02+10'h40 * NO_OF_WAVEGEN));

//write to register
always @(posedge i_clk or negedge i_rst_n) begin
  if (~i_rst_n) begin
    reg_wg_driver_alt_silent_lim[7:0]  <= 8'h00;
    reg_wg_driver_alt_silent_lim[15:8] <= 8'h00;
  end
  else begin
    reg_wg_driver_alt_silent_lim[7:0]  <= reg_wg_driver_alt_silent_lim_wr0 ? i_wr_data[7:0]  : reg_wg_driver_alt_silent_lim[7:0];
    reg_wg_driver_alt_silent_lim[15:8] <= reg_wg_driver_alt_silent_lim_wr1 ? i_wr_data[7:0]  : reg_wg_driver_alt_silent_lim[15:8];
 end
end

assign o_wg_driver_alter_silent_lim      = reg_wg_driver_alt_silent_lim;

//-----------------------------------------------
//ADDR_WG_DRV_ALT_REST_LIM_REG		
//-----------------------------------------------
wire reg_wg_driver_alt_rest_lim_wr0,reg_wg_driver_alt_rest_lim_wr1;
reg [15:0] reg_wg_driver_alt_rest_lim;

assign reg_wg_driver_alt_rest_lim_wr0 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_ALT_REST_LIM_REG01+8'h40 * NO_OF_WAVEGEN));
assign reg_wg_driver_alt_rest_lim_wr1 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_ALT_REST_LIM_REG02+8'h40 * NO_OF_WAVEGEN));

//write to register
always @(posedge i_clk or negedge i_rst_n) begin
  if (~i_rst_n) begin
    reg_wg_driver_alt_rest_lim[7:0]  <= 8'h00;
    reg_wg_driver_alt_rest_lim[15:8] <= 8'h00;
  end
  else begin
    reg_wg_driver_alt_rest_lim[7:0]  <= reg_wg_driver_alt_rest_lim_wr0 ? i_wr_data[7:0]  : reg_wg_driver_alt_rest_lim[7:0];
    reg_wg_driver_alt_rest_lim[15:8] <= reg_wg_driver_alt_rest_lim_wr1 ? i_wr_data[7:0]  : reg_wg_driver_alt_rest_lim[15:8];
 end
end

assign o_wg_driver_alter_rest_lim      = reg_wg_driver_alt_rest_lim;

//-----------------------------------------------
//ADDR_WG_DRV_DELAY_LIM_REG		
//-----------------------------------------------
assign reg_wg_driver_delay_lim_wr0 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_DELAY_LIM_REG01+10'h40 * NO_OF_WAVEGEN));
assign reg_wg_driver_delay_lim_wr1 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_DELAY_LIM_REG02+10'h40 * NO_OF_WAVEGEN));

//write to register
always @(posedge i_clk or negedge i_rst_n) begin
  if (~i_rst_n) begin
    reg_wg_driver_delay_lim[7:0]  <= 8'h00;
    reg_wg_driver_delay_lim[15:8] <= 8'h00;
  end
  else begin
    reg_wg_driver_delay_lim[7:0]  <= reg_wg_driver_delay_lim_wr0 ? i_wr_data[7:0]  : reg_wg_driver_delay_lim[7:0];
    reg_wg_driver_delay_lim[15:8] <= reg_wg_driver_delay_lim_wr1 ? i_wr_data[7:0]  : reg_wg_driver_delay_lim[15:8];
 end
end

assign o_wg_driver_delay_lim      = reg_wg_driver_delay_lim;

//-----------------------------------------------
//ADDR_WG_DRV_NEG_SCALE_REG 
//-----------------------------------------------
assign reg_wg_driver_neg_scale_wr0 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_NEG_SCALE_REG0+10'h40 * NO_OF_WAVEGEN));

//write to register
always @(posedge i_clk or negedge i_rst_n) begin
  if (~i_rst_n) begin
    reg_wg_driver_neg_scale[7:0]  <= 8'h01;
  end
  else begin
    reg_wg_driver_neg_scale[7:0]  <= reg_wg_driver_neg_scale_wr0 ? i_wr_data[7:0]  : reg_wg_driver_neg_scale[7:0];
 end
end

assign o_reg_wg_driver_neg_scale = reg_wg_driver_neg_scale;

//-----------------------------------------------
//ADDR_WG_DRV_NEG_OFFSET_REG 
//-----------------------------------------------
assign reg_wg_driver_neg_offset_wr0 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_NEG_OFFSET_REG0+10'h40 * NO_OF_WAVEGEN));

//write to register
always @(posedge i_clk or negedge i_rst_n) begin
  if (~i_rst_n) begin
    reg_wg_driver_neg_offset[7:0]  <= 8'h00;
  end
  else begin
    reg_wg_driver_neg_offset[7:0]  <= reg_wg_driver_neg_offset_wr0 ? i_wr_data[7:0]  : reg_wg_driver_neg_offset[7:0];
 end
end

assign o_reg_wg_driver_neg_offset = reg_wg_driver_neg_offset;

//-----------------------------------------------
//ADDR_WG_DRV_ISEL_REG 
//-----------------------------------------------
assign reg_wg_driver_isel_wr0 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_POS_SCALE_REG0+10'h40 * NO_OF_WAVEGEN));

//write to register
always @(posedge i_clk or negedge i_rst_n) begin
  if (~i_rst_n) begin
    reg_wg_driver_isel[7:0]  <= 8'h01;
  end
  else begin
    reg_wg_driver_isel[7:0]  <= reg_wg_driver_isel_wr0 ? i_wr_data[7:0]  : reg_wg_driver_isel[7:0];
 end
end

//assign o_wg_driver_isel        =  reg_wg_driver_isel[2:0];
assign o_wg_driver_pos_scale     = reg_wg_driver_isel;

//-----------------------------------------------
//ADDR_WG_DRV_SW_CONFIG_REG 
//-----------------------------------------------
assign reg_wg_driver_pos_offset_wr0 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_POS_OFFSET_REG0+10'h40 * NO_OF_WAVEGEN));

//write to register
always @(posedge i_clk or negedge i_rst_n) begin
  if (~i_rst_n) begin
    reg_wg_driver_pos_offset[7:0]  <= 8'h00;
  end
  else begin
    reg_wg_driver_pos_offset[7:0]  <= reg_wg_driver_pos_offset_wr0 ? i_wr_data[7:0]  : reg_wg_driver_pos_offset[7:0];
 end
end

assign o_reg_wg_driver_pos_offset = reg_wg_driver_pos_offset;

//assign o_wg_driver_sw_config      = reg_wg_driver_pos_offset[7:0];

assign reg_wg_pullba_wr0 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_PULLBA_REG+10'h40 * NO_OF_WAVEGEN));

//write to register
always @(posedge i_clk or negedge i_rst_n) begin
  if (~i_rst_n) begin
    reg_wg_pullba[7:0]  <= 8'h00;
  end
  else begin
    reg_wg_pullba[7:0]  <= reg_wg_pullba_wr0 ? i_wr_data[7:0]  : reg_wg_pullba[7:0];
 end
end

assign o_pullba_ctrl = reg_wg_pullba;

//-----------------------------------------------
//ADDR_WG_DRV_INT_REG 			
//-----------------------------------------------
assign reg_wg_driver_int_wr0 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_INT_REG01+10'h40 * NO_OF_WAVEGEN));
assign reg_wg_driver_int_wr1 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_INT_REG02+10'h40 * NO_OF_WAVEGEN));
assign reg_wg_driver_int_wr2 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_INT_REG03+10'h40 * NO_OF_WAVEGEN));
assign reg_wg_driver_int_wr3 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_INT_NUM_REG02+10'h40 * NO_OF_WAVEGEN));

//write to reg_wg_driver_int
wire [1:0] i_wg_driver_int_sts_sync;
always @(posedge i_clk or negedge i_rst_n) begin
  if (~i_rst_n) begin
    reg_wg_driver_int[7:0] <= 8'h00;
    reg_wg_driver_int[15:8] <= 8'h00;
    reg_wg_driver_int[23:16] <= 8'h00;
    reg_wg_driver_int[31:24] <= 8'h00;
  end
  else begin
    reg_wg_driver_int[7:0] <= 		reg_wg_driver_int_wr0 ? i_wr_data      : reg_wg_driver_int[7:0] ;
    reg_wg_driver_int[15:8] <= 		reg_wg_driver_int_wr1 ? i_wr_data      : auto_intr_addr_swap ? reg_wg_driver_int[23:16] : reg_wg_driver_int[15:8] ;
    reg_wg_driver_int[23:16] <= 	reg_wg_driver_int_wr2 ? i_wr_data      : auto_intr_addr_swap ? reg_wg_driver_int[15:8]  : reg_wg_driver_int[23:16] ;
    reg_wg_driver_int[31:24] <= 	reg_wg_driver_int_wr3 ? i_wr_data      : reg_wg_driver_int[31:24] ;
  end 
end

assign o_wg_driver_int_en  =          	reg_wg_driver_int[0];
assign auto_intr_addr_swap =          	reg_wg_driver_int[3] & reg_wg_driver_int_wr0 & i_wg_driver_int_sts[0] & i_wr_data[1] & !int_clear_type | 
                                        reg_wg_driver_int[3] & reg_wg_driver_int_sts_rd0 & i_wg_driver_int_sts[0] & int_clear_type |
                                        reg_wg_driver_int[3] & i_rd_normal & i_wg_driver_int_sts[0] & int_clear_type;

assign o_wg_driver_int_addr0  = 	reg_wg_driver_int[15:8];
assign o_wg_driver_int_addr1  = 	reg_wg_driver_int[23:16];
assign o_wg_driver_int_cnt    = 	reg_wg_driver_int[31:24];

assign reg_wg_driver_int_sts_wr0 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_INT_REG01+10'h40 * NO_OF_WAVEGEN));
assign reg_wg_driver_int_sts_rd0 = i_rd & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_WG_DRV_INT_REG01+10'h40 * NO_OF_WAVEGEN));

always @(posedge i_clk or negedge i_rst_n) begin
  if (~i_rst_n) begin
   o_addr0_int_clr     <= 1'b0;   
  end
  else if(reg_wg_driver_int_sts_wr0 & i_wr_data[1] & !int_clear_type) begin
   o_addr0_int_clr     <= 1'b1;
  end
  else if(i_wg_driver_int_sts_sync[0] & reg_wg_driver_int_sts_rd0 & int_clear_type) begin
   o_addr0_int_clr     <= 1'b1;
  end
  else if(i_wg_driver_int_sts_sync[0] & i_rd_normal & int_clear_type) begin
   o_addr0_int_clr     <= 1'b1;
  end
  else begin
   o_addr0_int_clr     <= 1'b0;
  end
end

always @(posedge i_clk or negedge i_rst_n) begin
  if (~i_rst_n) begin
   o_addr1_int_clr     <= 1'b0;   
  end
  else if(reg_wg_driver_int_sts_wr0 & i_wr_data[2] & !int_clear_type) begin
   o_addr1_int_clr     <= 1'b1;
  end
  else if(i_wg_driver_int_sts_sync[1] & reg_wg_driver_int_sts_rd0 & int_clear_type) begin
   o_addr1_int_clr     <= 1'b1;
  end
  else if(i_wg_driver_int_sts_sync[1] & i_rd_normal & int_clear_type) begin
   o_addr1_int_clr     <= 1'b1;
  end
  else begin
   o_addr1_int_clr     <= 1'b0;
  end
end

always@(posedge i_clk or negedge i_rst_n) begin
  if(!i_rst_n)begin
  drive_ctrl_reg0   <= 8'h00; 
  drive_ctrl_reg1   <= 8'h00; 
  drive_ctrl_reg2   <= 8'h00; 
  end
  else begin
	  case (i_addr[ADDR_WIDTH-1:0])
            `DRIVE_REG_CTRL0+10'h40 * NO_OF_WAVEGEN      :  drive_ctrl_reg0   <= i_wr? i_wr_data[7:0]   : drive_ctrl_reg0; 
            `DRIVE_REG_CTRL1+10'h40 * NO_OF_WAVEGEN      :  drive_ctrl_reg1   <= i_wr? i_wr_data[7:0]   : drive_ctrl_reg1;
            `DRIVE_REG_CTRL2+10'h40 * NO_OF_WAVEGEN      :  drive_ctrl_reg2   <= i_wr? i_wr_data[7:0]   : drive_ctrl_reg2;
     endcase
  end
end

assign o_dirve = {drive_ctrl_reg2[3:0],drive_ctrl_reg1[7:0],drive_ctrl_reg0[5:0]};

//slient time with specify waveform
always@(posedge i_clk or negedge i_rst_n) begin
  if(!i_rst_n)begin
  o_no_of_num_slient_disable   <= 1'b0; 
  o_no_of_num_slient_tar       <= 16'h0005; 
  end
  else begin
	  case (i_addr[ADDR_WIDTH-1:0])
            `NO_OF_NUM_SLIENT_CTR0+10'h40 * NO_OF_WAVEGEN     :  o_no_of_num_slient_disable  <= i_wr? i_wr_data[0]   : o_no_of_num_slient_disable; 
            `NO_OF_NUM_SLIENT_TAR0+10'h40 * NO_OF_WAVEGEN      :  o_no_of_num_slient_tar[7:0]      <= i_wr? i_wr_data[7:0] : o_no_of_num_slient_tar[7:0];
            `NO_OF_NUM_SLIENT_TAR1+10'h40 * NO_OF_WAVEGEN      :  o_no_of_num_slient_tar[15:8]      <= i_wr? i_wr_data[7:0] : o_no_of_num_slient_tar[15:8];
     endcase
  end
end

//for the address that scale/offset/MSB_SEL take effect 
wire       reg_wg_cal_addr_wr;
reg  [7:0] reg_wg_cal_addr;

assign reg_wg_cal_addr_wr = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`ADDR_IS_VALID_FOR_CAL+10'h40 * NO_OF_WAVEGEN));

//write to register
always @(posedge i_clk or negedge i_rst_n) begin
  if (~i_rst_n) begin
    reg_wg_cal_addr  <= 8'h00;
  end
  else begin
    reg_wg_cal_addr  <= reg_wg_cal_addr_wr ? i_wr_data[7:0]  : reg_wg_cal_addr;
 end
end

assign o_reg_wg_cal_addr = reg_wg_cal_addr;
//END

//EMS
wire       ems_ctrl_wr;
wire       ems_data_num_wr;
reg [5:0]  reg_ems_data_ctrl;

assign ems_ctrl_wr     = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`EMS_REG_CTRL+10'h40 * NO_OF_WAVEGEN));
assign ems_data_num_wr = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`EMS_DATA_NUM+10'h40 * NO_OF_WAVEGEN));


//write to register
always @(posedge i_clk or negedge i_rst_n) begin
  if (~i_rst_n) begin
    alt_ems_cnt_tar   <= 8'h00;
    reg_ems_data_ctrl <= 6'h0;
  end
  else begin
    alt_ems_cnt_tar   <= ems_data_num_wr ? i_wr_data[7:0]  : alt_ems_cnt_tar;
    reg_ems_data_ctrl <= ems_ctrl_wr     ? i_wr_data[5:0]  : reg_ems_data_ctrl;
 end
end

assign o_ems_data_ctrl = reg_ems_data_ctrl;
//END

/////////////////////////////////////////////
////drive C Isel
////////////////////////////////////////////
wire w_isel_addr_wr;
reg  w_isel_reg;

assign w_isel_addr_wr = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`AWG_DRIVEC_ISEL + 10'h40 * NO_OF_WAVEGEN));

//write to register
always @(posedge i_clk or negedge i_rst_n) begin
  if (~i_rst_n) begin
    w_isel_reg  <= 1'b0;
  end
  else begin
    w_isel_reg  <= w_isel_addr_wr ? i_wr_data[7:0]  : w_isel_reg;
 end
end

assign w_isel = w_isel_reg;

/////////////////////////////////////////////
////drive C Isel
////////////////////////////////////////////
wire sw_config_addr_wr0,sw_config_addr_wr1;
reg [15:0] sw_config_reg;

assign sw_config_addr_wr0 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`AWG_DRIVEC_SW_CFG0 + 10'h40 * NO_OF_WAVEGEN));
assign sw_config_addr_wr1 = i_wr & (i_addr[ADDR_WIDTH-1:0]==(`AWG_DRIVEC_SW_CFG1 + 10'h40 * NO_OF_WAVEGEN));

//write to register
always @(posedge i_clk or negedge i_rst_n) begin
  if (~i_rst_n) begin
    sw_config_reg  <= 16'b0;
  end
  else begin
    sw_config_reg[7:0]   <= sw_config_addr_wr0 ? i_wr_data[7:0]  : sw_config_reg[7:0];
    sw_config_reg[15:8]  <= sw_config_addr_wr1 ? i_wr_data[7:0]  : sw_config_reg[15:8];

 end
end

assign o_wg_driver_sw_config = sw_config_reg;

//int sync for reading
common_sync_bit   u_int_sync[1:0] (
       .clk(i_clk),
       .rst_(i_rst_n),
       .async_in(i_wg_driver_int_sts),
       .sync_out(i_wg_driver_int_sts_sync)
       );

/////////////////////////////////////////////////////////
// waveform generator register array end
/////////////////////////////////////////////////////////

reg [7:0] reg_rd_data;
always @ (posedge i_clk or negedge i_rst_n) begin
//always @ (*) begin
   if (!i_rst_n)
        reg_rd_data <= 8'b0;
   else if(!i_wr) begin
      case(i_addr[ADDR_WIDTH-1:0]-10'h40 * NO_OF_WAVEGEN)

        `ADDR_WG_DRV_CONFIG_REG0   	    :   reg_rd_data <= reg_wg_driver_config[7:0]; 
        `ADDR_WG_DRV_CTRL_REG0     	    :   reg_rd_data <= reg_wg_driver_ctrl[7:0]; 
        `ADDR_WG_DRV_REST_CLK_REG01     	    :   reg_rd_data <= reg_wg_driver_rest_t[7:0]; 
        `ADDR_WG_DRV_REST_CLK_REG02     	    :   reg_rd_data <= reg_wg_driver_rest_t[15:8]; 	
        `ADDR_WG_DRV_SILENT_CLK_REG01  	    :   reg_rd_data <= reg_wg_driver_silent_t[7:0]; 
        `ADDR_WG_DRV_SILENT_CLK_REG02  	    :   reg_rd_data <= reg_wg_driver_silent_t[15:8]; 
        `ADDR_WG_DRV_SILENT_CLK_REG03  	    :   reg_rd_data <= reg_wg_driver_silent_t[23:16]; 
        `ADDR_WG_DRV_SILENT_CLK_REG04  	    :   reg_rd_data <= reg_wg_driver_silent_t[31:24]; 
        `ADDR_WG_DRV_HLF_WAVE_CLK_PNT_REG01     :   reg_rd_data <= reg_wg_driver_hlf_wave_prd[7:0];  
        `ADDR_WG_DRV_HLF_WAVE_CLK_PNT_REG02     :   reg_rd_data <= reg_wg_driver_hlf_wave_prd[15:8];  
//      `ADDR_WG_DRV_HLF_WAVE_CLK_PNT_REG03     :   reg_rd_data <= reg_wg_driver_hlf_wave_prd[23:16];  
//      `ADDR_WG_DRV_HLF_WAVE_CLK_PNT_REG04     :   reg_rd_data <= reg_wg_driver_hlf_wave_prd[31:24];  
        `ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT_REG01 :   reg_rd_data <= reg_wg_driver_neg_hlf_wave_prd[7:0];  
        `ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT_REG02 :   reg_rd_data <= reg_wg_driver_neg_hlf_wave_prd[15:8];  
//      `ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT_REG03 :   reg_rd_data <= reg_wg_driver_neg_hlf_wave_prd[23:16];  
//      `ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT_REG04 :   reg_rd_data <= reg_wg_driver_neg_hlf_wave_prd[31:24];  
//      `ADDR_WG_DRV_CLK_FREQ_REG0          :   reg_rd_data <= 8'h00;  
        `ADDR_WG_DRV_IN_WAVE_ADDR_REG0	    :   reg_rd_data <= reg_wg_driver_in_wave_addr[7:0]; 
        `ADDR_WG_DRV_IN_WAVE_REG01 	    :   reg_rd_data <= reg_wg_driver_in_wave[reg_wg_driver_in_wave_addr]; 
        `ADDR_WG_DRV_INT_NUM_REG02 	    :   reg_rd_data <= o_wg_driver_int_cnt; 
        `ADDR_WG_DRV_ALT_LIM_REG01	    :   reg_rd_data <= reg_wg_driver_alt_lim[7:0]; 
        `ADDR_WG_DRV_ALT_LIM_REG02	    :   reg_rd_data <= reg_wg_driver_alt_lim[15:8]; 
        `ADDR_WG_DRV_ALT_SILENT_LIM_REG01   :   reg_rd_data <= reg_wg_driver_alt_silent_lim[7:0];  
        `ADDR_WG_DRV_ALT_SILENT_LIM_REG02   :   reg_rd_data <= reg_wg_driver_alt_silent_lim[15:8];  
        `ADDR_WG_DRV_ALT_REST_LIM_REG01   :   reg_rd_data <= reg_wg_driver_alt_rest_lim[7:0];  
        `ADDR_WG_DRV_ALT_REST_LIM_REG02   :   reg_rd_data <= reg_wg_driver_alt_rest_lim[15:8];
        `ADDR_WG_DRV_DELAY_LIM_REG01	    :   reg_rd_data <= reg_wg_driver_delay_lim[7:0]; 
        `ADDR_WG_DRV_DELAY_LIM_REG02	    :   reg_rd_data <= reg_wg_driver_delay_lim[15:8]; 
        `ADDR_WG_DRV_NEG_SCALE_REG0	    :   reg_rd_data <= reg_wg_driver_neg_scale[7:0]; 
        `ADDR_WG_DRV_NEG_OFFSET_REG0	    :   reg_rd_data <= reg_wg_driver_neg_offset[7:0]; 
        `ADDR_WG_DRV_INT_REG01		    :   reg_rd_data <= {reg_wg_driver_int[3],i_wg_driver_int_sts_sync,o_wg_driver_int_en, NO_OF_WAVEGEN[3:0]}; 
        `ADDR_WG_DRV_INT_REG02		    :   reg_rd_data <= reg_wg_driver_int[15:8]; 
        `ADDR_WG_DRV_INT_REG03		    :   reg_rd_data <= reg_wg_driver_int[23:16]; 
        `ADDR_WG_DRV_POS_SCALE_REG0    :   reg_rd_data <= reg_wg_driver_isel; 
        `ADDR_WG_DRV_POS_OFFSET_REG0	    :   reg_rd_data <= reg_wg_driver_pos_offset[7:0]; 
        `ADDR_WG_DRV_HLF_WAVE_CLK_PNT1_REG01     :   reg_rd_data <= reg_wg_driver_hlf_wave_prd1[7:0];  
        `ADDR_WG_DRV_HLF_WAVE_CLK_PNT1_REG02     :   reg_rd_data <= reg_wg_driver_hlf_wave_prd1[15:8];  
//      `ADDR_WG_DRV_HLF_WAVE_CLK_PNT1_REG03     :   reg_rd_data <= reg_wg_driver_hlf_wave_prd1[23:16];  
//      `ADDR_WG_DRV_HLF_WAVE_CLK_PNT1_REG04     :   reg_rd_data <= reg_wg_driver_hlf_wave_prd1[31:24];  
        `ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT1_REG01 :   reg_rd_data <= reg_wg_driver_neg_hlf_wave_prd1[7:0];  
        `ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT1_REG02 :   reg_rd_data <= reg_wg_driver_neg_hlf_wave_prd1[15:8];  
//      `ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT1_REG03 :   reg_rd_data <= reg_wg_driver_neg_hlf_wave_prd1[23:16];  
//      `ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT1_REG04 :   reg_rd_data <= reg_wg_driver_neg_hlf_wave_prd1[31:24];  
        `ADDR_WG_DRV_HLF_WAVE_CLK_PNT2_REG01     :   reg_rd_data <= reg_wg_driver_hlf_wave_prd2[7:0];  
        `ADDR_WG_DRV_HLF_WAVE_CLK_PNT2_REG02     :   reg_rd_data <= reg_wg_driver_hlf_wave_prd2[15:8];  
//      `ADDR_WG_DRV_HLF_WAVE_CLK_PNT2_REG03     :   reg_rd_data <= reg_wg_driver_hlf_wave_prd2[23:16];  
//      `ADDR_WG_DRV_HLF_WAVE_CLK_PNT2_REG04     :   reg_rd_data <= reg_wg_driver_hlf_wave_prd2[31:24];  
        `ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT2_REG01 :   reg_rd_data <= reg_wg_driver_neg_hlf_wave_prd2[7:0];  
        `ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT2_REG02 :   reg_rd_data <= reg_wg_driver_neg_hlf_wave_prd2[15:8];  
//      `ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT2_REG03 :   reg_rd_data <= reg_wg_driver_neg_hlf_wave_prd2[23:16];  
//      `ADDR_WG_DRV_NEG_HLF_WAVE_CLK_PNT2_REG04 :   reg_rd_data <= reg_wg_driver_neg_hlf_wave_prd2[31:24];  
        `ADDR_WG_DRV_POINT_CONFIG                :   reg_rd_data <= reg_wg_driver_point_config;
        `ADDR_WG_DRV_REST_CLK1_REG01     	    :   reg_rd_data <= reg_wg_driver_rest_t1[7:0]; 
        `ADDR_WG_DRV_REST_CLK1_REG02     	    :   reg_rd_data <= reg_wg_driver_rest_t1[15:8]; 	
        `ADDR_WG_DRV_SILENT_CLK1_REG01  	    :   reg_rd_data <= reg_wg_driver_silent_t1[7:0]; 
        `ADDR_WG_DRV_SILENT_CLK1_REG02  	    :   reg_rd_data <= reg_wg_driver_silent_t1[15:8]; 
        `ADDR_WG_DRV_SILENT_CLK1_REG03  	    :   reg_rd_data <= reg_wg_driver_silent_t1[23:16]; 
        `ADDR_WG_DRV_SILENT_CLK1_REG04  	    :   reg_rd_data <= reg_wg_driver_silent_t1[31:24]; 
        `ADDR_WG_DRV_REST_CLK2_REG01     	    :   reg_rd_data <= reg_wg_driver_rest_t2[7:0]; 
        `ADDR_WG_DRV_REST_CLK2_REG02     	    :   reg_rd_data <= reg_wg_driver_rest_t2[15:8]; 	
        `ADDR_WG_DRV_SILENT_CLK2_REG01  	    :   reg_rd_data <= reg_wg_driver_silent_t2[7:0]; 
        `ADDR_WG_DRV_SILENT_CLK2_REG02  	    :   reg_rd_data <= reg_wg_driver_silent_t2[15:8]; 
        `ADDR_WG_DRV_SILENT_CLK2_REG03  	    :   reg_rd_data <= reg_wg_driver_silent_t2[23:16]; 
        `ADDR_WG_DRV_SILENT_CLK2_REG04  	    :   reg_rd_data <= reg_wg_driver_silent_t2[31:24]; 
       `ADDR_WG_DRV_PULLBA_REG                :   reg_rd_data <= reg_wg_pullba;

        `DRIVE_REG_CTRL0                     :  reg_rd_data  <=    drive_ctrl_reg0;     
        `DRIVE_REG_CTRL1                     :  reg_rd_data  <=    drive_ctrl_reg1;
        `DRIVE_REG_CTRL2                     :  reg_rd_data  <=    drive_ctrl_reg2;

        `NO_OF_NUM_SLIENT_CTR0               :  reg_rd_data  <=  {7'b0,o_no_of_num_slient_disable}; 
        `NO_OF_NUM_SLIENT_TAR0               :  reg_rd_data  <=  o_no_of_num_slient_tar[7:0];
        `NO_OF_NUM_SLIENT_TAR1               :  reg_rd_data  <=  o_no_of_num_slient_tar[15:8];
        `AWG_DRIVEC_ISEL                     :  reg_rd_data  <=  {7'b0,w_isel_reg};
        `AWG_DRIVEC_SW_CFG0                  :  reg_rd_data  <=  sw_config_reg[7:0];
        `AWG_DRIVEC_SW_CFG1                  :  reg_rd_data  <=  sw_config_reg[15:8];
	default                             :   reg_rd_data <= 8'h00;
      endcase
   end
end

assign o_rd_data = reg_rd_data;

endmodule


