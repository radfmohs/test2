//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap Glucose Chip   
// File name:    gpio.v 
// Module Name : GPIO TOP
// Description : 
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author          Description      
//------------------------------------------------------------------------------
// 0.1                                      Initial Rev 
//------------------------------------------------------------------------------
module gpio (
  input  wire 		    i_scan_mode,
  input  wire  [3:0]  i_gpio_comp_out_ctrl,
  input	 wire  [7:0]  i_gpio_pu_ctrl,
  input  wire  [7:0]  i_gpio_pd_ctrl,
  input  wire  [2:0]	i_gpio_sr_pdrv0_1_ctrl,
  output      [10:0]  o_ens2_IOBUF_CS,
  output      [10:0]  o_ens2_IOBUF_SR,
  output      [10:0]  o_ens2_IOBUF_PDRV0,
  output      [10:0]  o_ens2_IOBUF_PDRV1,
  output      [10:0]  o_ens2_IOBUF_PU,
  output      [10:0]  o_ens2_IOBUF_PD,

  output              o_IO_clksel_PD,
  output              o_IO_exresetn_PD,
  output              o_IO_testmode0_PD,
  output              o_IO_testmode1_PD,

  output              o_IO_clksel_PU,
  output              o_IO_exresetn_PU,
  output              o_IO_testmode0_PU,
  output              o_IO_testmode1_PU,

  // COMP
  output              o_NORMAL_OUT_SEL,
  output              o_COMP_OUT_EN,
  output              o_COMP_OUT_SEL_STIM,
  output              o_COMP_OUT_SEL
);

wire [10:0] gpio_cs;
wire [10:0] gpio_sr;
wire [10:0] gpio_pd;
wire [10:0] gpio_pu;
wire        io_clk_sel_pd;
wire [10:0] gpio_pdrv0;
wire [10:0] gpio_pdrv1;
wire        gpio_normal_out_sel;
wire        gpio_comp_out_en;
wire        gpio_comp_out_sel;
wire        gpio_comp_out_sel_stim;

assign  gpio_cs		            =  11'b0;
assign  gpio_sr		            =  {11{i_gpio_sr_pdrv0_1_ctrl[0]}};
assign  gpio_pdrv0		        =  {11{i_gpio_sr_pdrv0_1_ctrl[1]}};
assign  gpio_pdrv1		        =  {11{i_gpio_sr_pdrv0_1_ctrl[2]}};
assign  gpio_pu               =  {{5{1'b0}}, i_gpio_pu_ctrl[2:0], {3{1'b0}}};
assign  gpio_pd               =  {i_gpio_pd_ctrl[4], {7{1'b0}}, i_gpio_pd_ctrl[3:1]}; 
assign  io_clk_sel_pd         =  i_gpio_pd_ctrl[0];
assign  gpio_normal_out_sel   =  i_gpio_comp_out_ctrl[0];
assign  gpio_comp_out_en      =  i_gpio_comp_out_ctrl[1];       
assign  gpio_comp_out_sel     =  i_gpio_comp_out_ctrl[2];    
assign  gpio_comp_out_sel_stim = i_gpio_comp_out_ctrl[3];    

assign  o_ens2_IOBUF_CS	    =  ~({11{i_scan_mode}}) & gpio_cs   [10:0];         
assign  o_ens2_IOBUF_SR	    =  ~({11{i_scan_mode}}) & gpio_sr   [10:0];
assign  o_ens2_IOBUF_PDRV0	=  ~({11{i_scan_mode}}) & gpio_pdrv0[10:0];
assign  o_ens2_IOBUF_PDRV1	=  ~({11{i_scan_mode}}) & gpio_pdrv1[10:0];
assign  o_ens2_IOBUF_PU	    =  ~({11{i_scan_mode}}) & gpio_pu   [10:0];
assign  o_ens2_IOBUF_PD	    =  ~({11{i_scan_mode}}) & gpio_pd   [10:0];

assign  o_IO_exresetn_PD      = 1'b0;
assign  o_IO_testmode0_PD     = 1'b1;
assign  o_IO_testmode1_PD     = 1'b1;
assign  o_IO_clksel_PD        = i_scan_mode ? 1'b1 : io_clk_sel_pd; 

assign  o_IO_exresetn_PU      = 1'b1;
assign  o_IO_testmode0_PU     = 1'b0;
assign  o_IO_testmode1_PU     = 1'b0;
assign  o_IO_clksel_PU        = 1'b0;

assign  o_NORMAL_OUT_SEL      = ~i_scan_mode & gpio_normal_out_sel;
assign  o_COMP_OUT_EN         = ~i_scan_mode & gpio_comp_out_en;
assign  o_COMP_OUT_SEL        = ~i_scan_mode & gpio_comp_out_sel;
assign  o_COMP_OUT_SEL_STIM   = ~i_scan_mode & gpio_comp_out_sel_stim;


endmodule	
