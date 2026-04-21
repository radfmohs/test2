module nirs_ppg_ctrl_top #(
  parameter WIDTH = 13
) (
  input  wire             scan_mode,
  input  wire             rst_n,
  input  wire             clk_ppg, // for counters and latch final counting values - Should match with ppg clock
  input  wire             clk_sys, // a stable 2Mhz to control pulses with pre-set widths

  input  wire      [4:0]  NIRS_PGG_MODE_SEL_spi,
  input  wire             NIRS_PPG_EN_spi,    // NIRS/PPG enable
  input  wire             NIRS_PPG_MEAS_spi,

// RATIO for DOUT - OPTIONAL for MANUAL MODE
  input  wire      [7:0]  RATIO_MANUAL_spi,   // Value for manual mode
  input  wire      [2:0]  RATIO_CTRL_spi,         // ratio[1:0], manual_en for Ratio

// Thresholds and manual mode for IDAC - MUST have manual mode
  input  wire     [18:0]  THRESHOLD_H_spi_0,    // High threhold
  input  wire      [7:0]  THRESHOLD_L_spi_0,    // Low threshold
  input  wire             IDAC_MANUAL_EN_spi_0, // Enable IDAC manual mode
  input  wire      [8:0]  IDAC_MANUAL_spi_0,    // Value for manual mode
  input  wire             IDAC_IDAC_EN_spi_0,

  input  wire     [18:0]  THRESHOLD_H_spi_1,    // High threhold
  input  wire      [7:0]  THRESHOLD_L_spi_1,    // Low threshold
  input  wire             IDAC_MANUAL_EN_spi_1, // Enable IDAC manual mode
  input  wire      [8:0]  IDAC_MANUAL_spi_1,    // Value for manual mode
  input  wire             IDAC_IDAC_EN_spi_1,

// Pulse config signals - Users control
  input  wire       [2:0] LED_STABLE_CTRL_spi_0,
  input  wire       [1:0] LED_OFF_CTRL_spi_0,
  input  wire       [3:0] PERIOD_CTRL_spi_0,
  input  wire       [2:0] RESET_CTRL_spi_0,
  input  wire       [3:0] OTS_CTRL_spi_0,

  input  wire       [2:0] LED_STABLE_CTRL_spi_1,
  input  wire       [1:0] LED_OFF_CTRL_spi_1,
  input  wire       [3:0] PERIOD_CTRL_spi_1,
  input  wire       [2:0] RESET_CTRL_spi_1,
  input  wire       [3:0] OTS_CTRL_spi_1,

// FLAGs
  output wire             IREF_COARSE_ON_NOT_OFF,
  output wire             IREF_COARSE_NOT_ON,
  output wire             IREF_FINE_ON_NOT_OFF,
  output wire             IREF_FINE_NOT_ON,
  output wire             IDAC_MAX,
  output wire             IDAC_MIN,

// Pulses to Analog
  output wire             EN,
  output wire             RESET,
  output wire             IPD_SW,
  output wire             IIN_SW,
  output wire             LED_ON,

// Interrupts
  input  wire       [7:0] NIRS_PPG_INT_SEL_spi,
  input  wire             int_length_slct_spi,
  input  wire             INT_CLR,
  output wire             INT,
  output wire             INT_IO,

// Counters to Analog
  output wire             IDAC_EN,
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

  wire   [4:0]  NIRS_PGG_MODE_SEL;
  wire          NIRS_PPG_EN;
  wire          NIRS_PGG_MEAS;
  wire   [7:0]  RATIO_MANUAL;             // Value for manual mode
  wire   [2:0]  RATIO_CTRL;               // ratio[1:0], manual_en for Ratio

  wire  [18:0]  THRESHOLD_H_0;  // High threhold
  wire   [7:0]  THRESHOLD_L_0;  // Low threshold
  wire          IDAC_MANUAL_EN_0;  // Enable IDAC manual mode
  wire   [8:0]  IDAC_MANUAL_0;  // Value for manual mode
  wire          IDAC_IDAC_EN_0;
  wire   [2:0]  LED_stable_ctrl_0;
  wire   [1:0]  LED_off_ctrl_0;
  wire   [3:0]  PERIOD_ctrl_0;
  wire   [2:0]  RESET_ctrl_0;
  wire   [3:0]  OTS_ctrl_0;

  wire  [18:0]  THRESHOLD_H_1;  // High threhold
  wire   [7:0]  THRESHOLD_L_1;  // Low threshold
  wire          IDAC_MANUAL_EN_1;  // Enable IDAC manual mode
  wire   [8:0]  IDAC_MANUAL_1;  // Value for manual mode
  wire          IDAC_IDAC_EN_1;
  wire   [2:0]  LED_stable_ctrl_1;
  wire   [1:0]  LED_off_ctrl_1;
  wire   [3:0]  PERIOD_ctrl_1;
  wire   [2:0]  RESET_ctrl_1;
  wire   [3:0]  OTS_ctrl_1;

  wire   [7:0]  NIRS_PPG_INT_SEL;
  wire          int_length_slct_spi;

  assign NIRS_PGG_MODE_SEL  = NIRS_PGG_MODE_SEL_spi;
  assign NIRS_PPG_EN        = NIRS_PPG_EN_spi;
  assign NIRS_PGG_MEAS      = NIRS_PPG_MEAS_spi;
  assign RATIO_MANUAL       = RATIO_MANUAL_spi;
  assign RATIO_CTRL         = RATIO_CTRL_spi;
  assign THRESHOLD_H_0      = THRESHOLD_H_spi_0;
  assign THRESHOLD_L_0      = THRESHOLD_L_spi_0;
  assign IDAC_MANUAL_EN_0   = IDAC_MANUAL_EN_spi_0;
  assign IDAC_MANUAL_0      = IDAC_MANUAL_spi_0;
  assign IDAC_IDAC_EN_0     = IDAC_IDAC_EN_spi_0;
  assign LED_stable_ctrl_0  = LED_STABLE_CTRL_spi_0;
  assign LED_off_ctrl_0     = LED_OFF_CTRL_spi_0;
  assign PERIOD_ctrl_0      = PERIOD_CTRL_spi_0;
  assign RESET_ctrl_0       = RESET_CTRL_spi_0;
  assign OTS_ctrl_0         = OTS_CTRL_spi_0;

  assign THRESHOLD_H_1     = THRESHOLD_H_spi_1;
  assign THRESHOLD_L_1     = THRESHOLD_L_spi_1;
  assign IDAC_MANUAL_EN_1  = IDAC_MANUAL_EN_spi_1;
  assign IDAC_MANUAL_1     = IDAC_MANUAL_spi_1;
  assign IDAC_IDAC_EN_1     = IDAC_IDAC_EN_spi_1;
  assign LED_stable_ctrl_1 = LED_STABLE_CTRL_spi_1;
  assign LED_off_ctrl_1    = LED_OFF_CTRL_spi_1;
  assign PERIOD_ctrl_1     = PERIOD_CTRL_spi_1;
  assign RESET_ctrl_1      = RESET_CTRL_spi_1;
  assign OTS_ctrl_1        = OTS_CTRL_spi_1;

  assign NIRS_PPG_INT_SEL  = NIRS_PPG_INT_SEL_spi;
  assign int_length_slct   = int_length_slct_spi;


  wire IDAC_UPDATE_EN, IDAC_INCREASE;
  wire LED; // 0: LED0 - 1: LED1

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


/*
  DUAL LED sel for IDAC
*/
  wire IDAC_LED0_EN = IDAC_UPDATE_EN && ~LED && IDAC_IDAC_EN_0;
  wire IDAC_LED1_EN = IDAC_UPDATE_EN && LED  && IDAC_IDAC_EN_1;
  wire [8:0] IDAC_tmp [1:0];
  wire IDAC_MAX_tmp [1:0];
  wire IDAC_MIN_tmp [1:0];

  assign IDAC_EN  = LED ? IDAC_IDAC_EN_1  : IDAC_IDAC_EN_0; 
  assign IDAC     = LED ? IDAC_tmp[1]     : IDAC_tmp[0];
  assign IDAC_MAX = LED ? IDAC_MAX_tmp[1] : IDAC_MAX_tmp[0];
  assign IDAC_MIN = LED ? IDAC_MIN_tmp[1] : IDAC_MIN_tmp[0];

  nirs_ppg_idac_ctrl #(.WIDTH(WIDTH)) u_idac_led0_ctrl (
    .rst_n          (rst_n),
    .clk            (clk_ppg),
    .IDAC_MANUAL_EN (IDAC_MANUAL_EN_0),
    .IDAC_MANUAL    (IDAC_MANUAL_0),
    .EN             (IDAC_LED0_EN),
    .IDAC_INCREASE  (IDAC_INCREASE),
    .DOUTF          (DOUTF),
    .DOUT_AC        (DOUT),
    .THRESHOLD_H    (THRESHOLD_H_0),
    .THRESHOLD_L    (THRESHOLD_L_0),
    .IDAC_MAX       (IDAC_MAX_tmp[0]),
    .IDAC_MIN       (IDAC_MIN_tmp[0]),
    .IDAC           (IDAC_tmp[0])
  );

    nirs_ppg_idac_ctrl #(.WIDTH(WIDTH)) u_idac_led1_ctrl (
    .rst_n          (rst_n),
    .clk            (clk_ppg),
    .IDAC_MANUAL_EN (IDAC_MANUAL_EN_1),
    .IDAC_MANUAL    (IDAC_MANUAL_1),
    .EN             (IDAC_LED1_EN),
    .IDAC_INCREASE  (IDAC_INCREASE),
    .DOUTF          (DOUTF),
    .DOUT_AC        (DOUT),
    .THRESHOLD_H    (THRESHOLD_H_1),
    .THRESHOLD_L    (THRESHOLD_L_1),
    .IDAC_MAX       (IDAC_MAX_tmp[1]),
    .IDAC_MIN       (IDAC_MIN_tmp[1]),
    .IDAC           (IDAC_tmp[1])
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
    .atpg_en  (scan_mode),
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

/* Flags */
  wire DATA_READY;

  nirs_ppg_ctrl u_nirs_ctrl (
    .rst_n          (rst_n),
    .clk            (clk_ppg),

    .EN             (EN_DIG_ppg),
    .IREF_COARSE    (IREF_COARSE_ppg),
    .IREF_FINE      (IREF_FINE_ppg),

    .IREF_COARSE_ON_NOT_OFF (IREF_COARSE_ON_NOT_OFF),
    .IREF_COARSE_NOT_ON     (IREF_COARSE_NOT_ON),
    .IREF_FINE_ON_NOT_OFF   (IREF_FINE_ON_NOT_OFF),
    .IREF_FINE_NOT_ON       (IREF_FINE_NOT_ON),
    .DATA_READY             (DATA_READY),

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
    .LED              (LED),

    .LED_stable_ctrl_0  (LED_stable_ctrl_0),
    .LED_off_ctrl_0     (LED_off_ctrl_0),
    .PERIOD_ctrl_0      (PERIOD_ctrl_0),
    .RESET_ctrl_0       (RESET_ctrl_0),
    .OTS_ctrl_0         (OTS_ctrl_0),

    .LED_stable_ctrl_1  (LED_stable_ctrl_1),
    .LED_off_ctrl_1     (LED_off_ctrl_1),
    .PERIOD_ctrl_1      (PERIOD_ctrl_1),
    .RESET_ctrl_1       (RESET_ctrl_1),
    .OTS_ctrl_1         (OTS_ctrl_1),

    .EN_DIG           (EN_DIG),
    .EN_OFF           (EN_OFF_sys),
    .EN               (EN),
    .RESET            (RESET),
    .IPD_SW           (IPD_SW),
    .IIN_SW           (IIN_SW),
    .LED_ON           (LED_ON)
  );

  nirs_ppg_int  u_nirs_ppg_int (
    .scan_mode              (scan_mode),
    .rst_n                  (rst_n),
    .clk_sys                (clk_sys),
    .INT_CONFIG             (NIRS_PPG_INT_SEL),
    .int_length_slct        (int_length_slct),
    .IREF_COARSE_ON_NOT_OFF (IREF_COARSE_ON_NOT_OFF),
    .IREF_COARSE_NOT_ON     (IREF_COARSE_NOT_ON),
    .IREF_FINE_ON_NOT_OFF   (IREF_FINE_ON_NOT_OFF),
    .IREF_FINE_NOT_ON       (IREF_FINE_NOT_ON),
    .IDAC_MAX               (IDAC_MAX),
    .IDAC_MIN               (IDAC_MIN),
    .DATA_READY             (DATA_READY),
    .INT_CLR                (INT_CLR),
    .INT                    (INT),
    .INT_IO                 (INT_IO)
  );


endmodule
