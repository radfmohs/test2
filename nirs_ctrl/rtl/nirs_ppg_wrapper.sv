//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap ENS2  
// File name:    nirs_ppg_wrapper.v 
// Module Name : nirs_ppg_wrapper
// Description : 
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author          Description      
//------------------------------------------------------------------------------
// 0.1                                      Initial Rev 
//------------------------------------------------------------------------------
module nirs_ppg_wrapper (

  input  wire             rst_n,
  input  wire             clk_ppg, // Max: 8Mhz
  input  wire             clk_sys, // Max: 2MHz

  ana_nirs_if.nirs        ana_nirs_if,
  spi_nirs_if.nirs        spi_nirs_if
);

wire [18:0] THRESHOLD_H;
wire [18:0] THRESHOLD_L;
wire [12:0] DOUTC;
wire [12:0] DOUTF;
wire [18:0] DOUT;
wire  [3:0] PERIOD_ctrl;
wire  [3:0] OTS_ctrl;
wire  [7:0] RATIO;


wire        RESET;
wire        ILED_SW;
wire        IIN_SW;
wire  [8:0] IDAC;
wire        IREF_COARSE;
wire        IREF_FINE;

/*
  No synchronizers between SPI and PPG due to configurations are not changed frequently
*/
assign PERIOD_ctrl          = spi_nirs_if.NIRS_CTRL[0][7:4];
assign OTS_ctrl             = spi_nirs_if.NIRS_CTRL[0][3:0];
assign RATIO                = spi_nirs_if.NIRS_CTRL[1];
assign THRESHOLD_H          = {spi_nirs_if.NIRS_CTRL[2][5:0], spi_nirs_if.NIRS_CTRL[3], spi_nirs_if.NIRS_CTRL[4][7:3]};
assign THRESHOLD_L          = {spi_nirs_if.NIRS_CTRL[4][2:0], spi_nirs_if.NIRS_CTRL[5], spi_nirs_if.NIRS_CTRL[6]};
assign spi_nirs_if.NIRS_DOUT[0] = DOUT[18:11];
assign spi_nirs_if.NIRS_DOUT[1] = DOUT[10:3];
assign spi_nirs_if.NIRS_DOUT[2] = {DOUT[2:0], DOUTF[12:8]};
assign spi_nirs_if.NIRS_DOUT[3] = DOUTF[7:0];
assign spi_nirs_if.NIRS_DOUT[4] = DOUTC[12:5];
assign spi_nirs_if.NIRS_DOUT[5] = {DOUTC[4:0], IDAC[8:6]};
assign spi_nirs_if.NIRS_DOUT[6] = {IDAC[5:0], RESET, ILED_SW};
assign spi_nirs_if.NIRS_DOUT[7] = {IIN_SW, IREF_COARSE, IREF_FINE, 5'b0};

assign ana_nirs_if.D2A_NIRS_RESET_SW    = RESET;
assign ana_nirs_if.D2A_NIRS_ILED_SW     = ILED_SW;
assign ana_nirs_if.D2A_NIRS_IIN_SW      = IIN_SW;
assign ana_nirs_if.D2A_NIRS_IDAC        = IDAC;
assign ana_nirs_if.D2A_NIRS_RATIO       = spi_nirs_if.NIRS_CTRL[2][7:6];
assign IREF_COARSE = ana_nirs_if.A2D_NIRS_IREFCOARSE;
assign IREF_FINE   = ana_nirs_if.A2D_NIRS_IREFFINE;  


nirs_ppg_ctrl_top u_nirs_ctrl_top (
  .rst_n        (rst_n),

//ctrl
  .clk_ppg      (clk_ppg),
  .RATIO        (RATIO),
  .THRESHOLD_H  (THRESHOLD_H),  
  .THRESHOLD_L  (THRESHOLD_L),  
  .IREF_COARSE  (IREF_COARSE),
  .IREF_FINE    (IREF_FINE),
  .DOUTC        (DOUTC),
  .DOUTF        (DOUTF),
  .DOUT         (DOUT),
  .IDAC         (IDAC),

//pulse ctrl
  .clk_sys        (clk_sys),
  .PERIOD_ctrl    (PERIOD_ctrl),
  .OTS_ctrl       (OTS_ctrl),
  .RESET          (RESET),
  .ILED_SW        (ILED_SW),
  .IIN_SW         (IIN_SW)
);

endmodule
