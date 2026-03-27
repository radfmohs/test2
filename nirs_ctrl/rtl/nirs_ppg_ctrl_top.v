module nirs_ppg_ctrl_top #(
  parameter WIDTH = 13
) (
  input  wire             rst_n,
  input  wire             scan_mode,
  input  wire             clk_ppg, // for counters and latch final counting values - Should match with ppg clock
  input  wire             clk_sys, // a stable 2Mhz to control pulses with pre-set widths

  input  wire      [3:0]  NIRS_PGG_MODE_SEL_spi,
  input  wire             NIRS_PPG_EN_spi,    // NIRS/PPG enable
  input  wire             NIRS_PPG_MEAS_spi,

// RATIO for DOUT - OPTIONAL for MANUAL MODE
  input  wire      [7:0]  RATIO_MANUAL_spi,   // Value for manual mode
  input  wire      [2:0]  RATIO_CTRL_spi,         // ratio[1:0], manual_en for Ratio

// Thresholds and manual mode for IDAC - MUST have manual mode
  input  wire     [18:0]  THRESHOLD_H_spi,    // High threhold
  input  wire      [7:0]  THRESHOLD_L_spi,    // Low threshold
  input  wire             IDAC_MANUAL_EN_spi, // Enable IDAC manual mode
  input  wire      [8:0]  IDAC_MANUAL_spi,    // Value for manual mode

// Pulse config signals - Users control
  input  wire       [2:0] LED_STABLE_CTRL_spi,
  input  wire       [1:0] LED_OFF_CTRL_spi,
  input  wire       [2:0] REC_STABLE_CTRL_spi,
  input  wire       [3:0] PERIOD_CTRL_spi,
  input  wire       [2:0] RESET_CTRL_spi,
  input  wire       [3:0] OTS_CTRL_spi,

// FLAGs
  output wire             IREF_COARSE_ON_NOT_OFF,
  output wire             IREF_COARSE_NOT_ON,
  output wire             IREF_FINE_ON_NOT_OFF,
  output wire             IREF_FINE_NOT_ON,

// Pulses to Analog
  output wire             EN,
  output wire             RESET,
  output wire             IPD_SW,
  output wire             IIN_SW,
  output wire             LED_ON,

// Counters to Analog
  output wire       [8:0] IDAC,
  output wire [WIDTH-1:0] DOUTC, // Coarse counter
  output wire [WIDTH-1:0] DOUTF, // Fine counter
  output wire      [18:0] DOUT,  // Coarse + Fine

// From Analog
  input  wire             IREF_COARSE,
  input  wire             IREF_FINE
);

  wire [WIDTH-1:0] QC, QF;
  
  wire QC_COUNTER_EN, QF_COUNTER_EN, COUNTERS_CLEAR;
  wire DOUTC_LATCH_EN, DOUTF_LATCH_EN, DOUT_EN;
  wire sync_bypass_sys, sync_bypass_ppg;

  wire   [3:0]  NIRS_PGG_MODE_SEL = NIRS_PGG_MODE_SEL_spi;
  wire          NIRS_PPG_EN       = NIRS_PPG_EN_spi;
  wire          NIRS_PGG_MEAS     = NIRS_PPG_MEAS_spi;
  wire   [7:0]  RATIO_MANUAL      = RATIO_MANUAL_spi;     // Value for manual mode
  wire   [2:0]  RATIO_CTRL        = RATIO_CTRL_spi;       // ratio[1:0], manual_en for Ratio
  wire  [18:0]  THRESHOLD_H       = THRESHOLD_H_spi;      // High threhold
  wire   [7:0]  THRESHOLD_L       = THRESHOLD_L_spi;      // Low threshold
  wire          IDAC_MANUAL_EN    = IDAC_MANUAL_EN_spi;   // Enable IDAC manual mode
  wire   [8:0]  IDAC_MANUAL       = IDAC_MANUAL_spi;      // Value for manual mode
  wire   [2:0]  LED_stable_ctrl   = LED_STABLE_CTRL_spi;
  wire   [1:0]  LED_off_ctrl      = LED_OFF_CTRL_spi;
  wire   [2:0]  REC_stable_ctrl   = REC_STABLE_CTRL_spi;
  wire   [3:0]  PERIOD_ctrl       = PERIOD_CTRL_spi;
  wire   [2:0]  RESET_ctrl        = RESET_CTRL_spi;
  wire   [3:0]  OTS_ctrl          = OTS_CTRL_spi;

  wire IDAC_UPDATE_EN, IDAC_INCREASE;

  // common_sync_bit u_sync_bypass_ppg (
  //   .clk      (clk_ppg),
  //   .rst_     (rst_n),
  //   .async_in (sync_bypass_spi),
  //   .sync_out (sync_bypass_ppg)
  // );

  // common_sync_bit u_sync_bypass_sys (
  //   .clk      (clk_sys),
  //   .rst_     (rst_n),
  //   .async_in (sync_bypass_spi),
  //   .sync_out (sync_bypass_sys)
  // );

  nirs_ppg_counter #(.COUNTER_WIDTH(WIDTH)) IREF_COARSE_COUNTER (
    .rst_n      (rst_n),
    .scan_mode  (scan_mode),
    .clk        (clk_ppg),
    .RESET      (COUNTERS_CLEAR),
    .enable     (QC_COUNTER_EN),
    .out        (QC)
  );

  nirs_ppg_latch #(.LATCH_WIDTH(WIDTH)) IREF_COARSE_LATCH (
    .rst_n  (rst_n),
    .clk    (clk_ppg),
    .en     (DOUTC_LATCH_EN),
    .in     (QC),
    .out    (DOUTC)
  );

  nirs_ppg_subtract_dout #(.IN_WDTH(WIDTH)) u_subtract_dout (
    .rst_n        (rst_n),
    .clk          (clk_ppg),
    .en           (DOUT_EN),
    .DOUTF        (DOUTF),
    .DOUTC        (DOUTC),
    .RATIO_MANUAL (RATIO_MANUAL),
    .RATIO_CTRL   (RATIO_CTRL),
    .DOUT         (DOUT)
  );

  nirs_ppg_counter #(.COUNTER_WIDTH(WIDTH)) IREF_FINE_COUNTER (
    .rst_n  (rst_n),
    .scan_mode  (scan_mode),
    .clk    (clk_ppg),
    .RESET  (COUNTERS_CLEAR),
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
    .rst_n          (rst_n),
    .clk            (clk_ppg),
    .IDAC_MANUAL_EN (IDAC_MANUAL_EN),
    .IDAC_MANUAL    (IDAC_MANUAL),
    .EN             (IDAC_UPDATE_EN),
    .IDAC_INCREASE  (IDAC_INCREASE),
    .DOUTF          (DOUTF),
    .DOUT_AC        (DOUT),
    .THRESHOLD_H    (THRESHOLD_H),
    .THRESHOLD_L    (THRESHOLD_L),
    .IDAC           (IDAC)
  );

  wire EN_DIG, EN_DIG_ppg, IREF_COARSE_ppg, IREF_FINE_ppg, EN_OFF_ppg, EN_OFF_sys;

  common_sync_bit u_RESET_sync (
    .async_in (EN_DIG),
    .clk      (clk_ppg),
    .rst_     (rst_n),
    .sync_out (EN_DIG_ppg)
  );

  common_pulse_cdc u_EN_OFF_sync (
    .aclk     (clk_ppg),
    .bclk     (clk_sys),
    .arst_    (rst_n),
    .brst_    (rst_n),
    .atpg_en  (1'b0),
    .a_pulse  (EN_OFF_ppg),
    .b_pulse  (EN_OFF_sys)
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

    .EN             (EN_DIG_ppg),
    .IREF_COARSE    (IREF_COARSE_ppg),
    .IREF_FINE      (IREF_FINE_ppg),

    .IREF_COARSE_ON_NOT_OFF (IREF_COARSE_ON_NOT_OFF),
    .IREF_COARSE_NOT_ON (IREF_COARSE_NOT_ON),
    .IREF_FINE_ON_NOT_OFF (IREF_FINE_ON_NOT_OFF),
    .IREF_FINE_NOT_ON (IREF_FINE_NOT_ON),

    .EN_OFF         (EN_OFF_ppg),
    .IDAC_INCREASE  (IDAC_INCREASE),
    .IDAC_UPDATE_EN (IDAC_UPDATE_EN),
    .COUNTERS_CLEAR (COUNTERS_CLEAR),
    .QC_COUNTER_EN  (QC_COUNTER_EN),
    .QF_COUNTER_EN  (QF_COUNTER_EN),
    .DOUTC_LATCH_EN (DOUTC_LATCH_EN),
    .DOUTF_LATCH_EN (DOUTF_LATCH_EN),
    .DOUT_EN        (DOUT_EN)
  );

/*
  Run on a 2MHz clock to provide stable pusles
*/
  nirs_ppg_pulse_ctrl u_nirs_pulse_ctrl (
    .rst_n            (rst_n),
    .clk              (clk_sys),

    .MODE_SEL         (NIRS_PGG_MODE_SEL),
    .NIRS_EN          (NIRS_PPG_EN),
    .NIRS_MEAS        (NIRS_PGG_MEAS),

    .LED_stable_ctrl  (LED_stable_ctrl),
    .LED_off_ctrl     (LED_off_ctrl),
    .REC_stable_ctrl  (REC_stable_ctrl),
    .PERIOD_ctrl      (PERIOD_ctrl),
    .RESET_ctrl       (RESET_ctrl),
    .OTS_ctrl         (OTS_ctrl),

    .EN_DIG           (EN_DIG),
    .EN_OFF           (EN_OFF_sys),
    .EN               (EN),
    .RESET            (RESET),
    .IPD_SW           (IPD_SW),
    .IIN_SW           (IIN_SW),
    .LED_ON           (LED_ON)
  );

endmodule
