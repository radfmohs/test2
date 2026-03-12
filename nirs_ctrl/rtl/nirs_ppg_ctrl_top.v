//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap ENS2  
// File name:    nirs_ppg_ctrl_top.v 
// Module Name : nirs_ppg_ctrl_top
// Description : 
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author          Description      
//------------------------------------------------------------------------------
// 0.1                                      Initial Rev 
//------------------------------------------------------------------------------
module nirs_ppg_ctrl_top #(
  parameter WIDTH = 13
) (
  input  wire             rst_n,
  input  wire             clk_ppg,
  input  wire      [7:0]  RATIO,
  input  wire     [18:0]  THRESHOLD_H,
  input  wire     [18:0]  THRESHOLD_L,

  input  wire             IREF_COARSE,
  input  wire             IREF_FINE,

  output wire [WIDTH-1:0] DOUTC, 
  output wire [WIDTH-1:0] DOUTF,
  output wire      [18:0] DOUT,
  output wire       [8:0] IDAC,

  input  wire             clk_sys, //2Mhz
  input  wire       [3:0] PERIOD_ctrl,
  input  wire       [3:0] OTS_ctrl,

  output wire             RESET,
  output wire             ILED_SW,
  output wire             IIN_SW
);

  wire [WIDTH-1:0] QC, QF;
  
  wire QC_COUNTER_EN, QF_COUNTER_EN;
  wire DOUTC_LATCH_EN, DOUTF_LATCH_EN, DOUT_EN;
  wire IDAC_UPDATE_EN;

  nirs_ppg_counter #(.COUNTER_WIDTH(WIDTH)) IREF_COARSE_COUNTER (
    .rst_n  (rst_n),
    .clk    (clk_ppg),
    .RESET  (ILED_SW),
    .enable (QC_COUNTER_EN),
    .out    (QC)
  );

  nirs_ppg_latch #(.LATCH_WIDTH(WIDTH)) IREF_COARSE_LATCH (
    .rst_n  (rst_n),
    .clk    (clk_ppg),
    .en     (DOUTC_LATCH_EN),
    .in     (QC),
    .out    (DOUTC)
  );

  nirs_ppg_subtract_dout #(.IN_WDTH(WIDTH)) u_subtract_dout (
    .rst_n  (rst_n),
    .clk    (clk_ppg),
    .en     (DOUT_EN),
    .DOUTF  (DOUTF),
    .DOUTC  (DOUTC),
    .RATIO  (RATIO),
    .DOUT   (DOUT)
  );

  nirs_ppg_counter #(.COUNTER_WIDTH(WIDTH)) IREF_FINE_COUNTER (
    .rst_n  (rst_n),
    .clk    (clk_ppg),
    .RESET  (ILED_SW),
    .enable (QF_COUNTER_EN),
    .out    (QF)
  );

  nirs_ppg_latch #(.LATCH_WIDTH(WIDTH)) IREF_FINE_LATCH (
    .rst_n  (rst_n),
    .clk    (clk_ppg),
    .en     (DOUTF_LATCH_EN),
    .in     (QF),
    .out    (DOUTF)
  );

  nirs_ppg_idac_ctrl #(.WIDTH(WIDTH)) u_idac_ctrl (
    .rst_n       (rst_n),
    .clk         (clk_ppg),
    .EN          (IDAC_UPDATE_EN),
    .DOUTF       (DOUTF),
    .DOUT_AC     (DOUT),
    .THRESHOLD_H (THRESHOLD_H),
    .THRESHOLD_L (THRESHOLD_L),
    .IDAC        (IDAC)
  );

  wire RESET_ppg, IREF_COARSE_ppg, IREF_FINE_ppg;
  common_sync_bit u_RESET_sync (
    .async_in (RESET),
    .clk      (clk_ppg),
    .rst_     (rst_n),
    .sync_out (RESET_ppg)
  );

  common_sync_bit u_IREF_COARSE_sync (
    .async_in (IREF_COARSE),
    .clk      (clk_ppg),
    .rst_     (rst_n),
    .sync_out (IREF_COARSE_ppg)
  );

  common_sync_bit u_IREF_FINE_sync (
    .async_in (IREF_FINE),
    .clk      (clk_ppg),
    .rst_     (rst_n),
    .sync_out (IREF_FINE_ppg)
  );

  nirs_ppg_ctrl u_nirs_ctrl (
    .rst_n          (rst_n),
    .clk            (clk_ppg),
    .RESET          (RESET_ppg),


    .IREF_COARSE    (IREF_COARSE_ppg),
    .IREF_FINE      (IREF_FINE_ppg),

    .IDAC_UPDATE_EN (IDAC_UPDATE_EN),
    .QC_COUNTER_EN  (QC_COUNTER_EN),
    .QF_COUNTER_EN  (QF_COUNTER_EN),
    .DOUTC_LATCH_EN (DOUTC_LATCH_EN),
    .DOUTF_LATCH_EN (DOUTF_LATCH_EN),
    .DOUT_EN        (DOUT_EN)
  );


  nirs_ppg_pulse_ctrl u_nirs_pulse_ctrl (
    .rst_n          (rst_n),
    .clk            (clk_sys),
    .PERIOD_ctrl    (PERIOD_ctrl),
    .OTS_ctrl       (OTS_ctrl),

    .RESET          (RESET),
    .ILED_SW        (ILED_SW),
    .IIN_SW         (IIN_SW)
);

endmodule  
