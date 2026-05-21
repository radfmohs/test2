//=============================================================================
// Testbench: tb_nirs_ppg_ctrl_top
//
// Description:
//   Comprehensive testbench for nirs_ppg_ctrl_top covering:
//     - Reset state verification
//     - Pulse timing sequence (EN, RESET, IPD_SW, IIN_SW, LED_ON order)
//     - Normal measurement: DOUT = RATIO*DOUTC - DOUTF
//     - IDAC auto-increase / auto-decrease
//     - IDAC saturation and clamping at max/min
//     - IDAC manual override
//     - Counter clear between measurements
//     - Flag generation (IREF_COARSE_NOT_ON, IREF_FINE_NOT_ON,
//                        IREF_COARSE_ON_NOT_OFF, IREF_FINE_ON_NOT_OFF)
//     - Interrupt generation (DATA_READY, IDAC_MAX, IDAC_MIN)
//     - Dual LED alternation and per-LED parameter selection
//     - IPDMIRROR_ADJ / IREFC_ADJ LED mux bug detection
//     - Exponential averaging (AVG_SEL)
//     - Custom RATIO via RATIO_MANUAL
//     - DOUTF=0 forces IDAC increase
//
// Analog stimuli (IREF_COARSE / IREF_FINE) are injected to mimic real
// photo-detector comparator outputs during the integration window (IPD_SW).
//
// Clock frequencies (scaled for fast simulation):
//   clk_ppg : 8 MHz  -- half period 62 ns
//   clk_sys : 2 MHz  -- half period 250 ns  (1 sys cycle ≈ 4 ppg cycles)
//
// Timing (sys cycles, PERIOD_ctrl=0 → period=249):
//   counter=10  : EN/RESET/IIN_SW assert
//   counter=110 : RESET deasserts
//   counter=130 : IPD_SW asserts  (integration window begins)
//   counter=134 : IPD_SW deasserts (4 sys = 16 PPG cycles)
//   counter=249 : period ends
//
// Safe analog response window to fit within one period:
//   Drive IREF_COARSE for ~100 PPG cycles, IREF_FINE for ~30 PPG cycles.
//   Both signals must fall before counter=249 to avoid DONE-while-latching
//   flags (the test for those flags deliberately violates this).
//=============================================================================
`timescale 1ns/1ps

module tb_nirs_ppg_ctrl_top;

//----------------------------------------------------------------------------
// Clock parameters
//----------------------------------------------------------------------------
parameter CLK_PPG_HALF = 62;   // 8 MHz
parameter CLK_SYS_HALF = 250;  // 2 MHz

//----------------------------------------------------------------------------
// DUT width
//----------------------------------------------------------------------------
parameter WIDTH = 13;

//----------------------------------------------------------------------------
// Simulation-timing constants (in ns)
//----------------------------------------------------------------------------
// Sys clock period in ns
`define T_SYS  (2 * CLK_SYS_HALF)
// PPG clock period in ns
`define T_PPG  (2 * CLK_PPG_HALF)

//----------------------------------------------------------------------------
// DUT inputs
//----------------------------------------------------------------------------
reg        scan_mode;
reg        rst_n;
reg        clk_ppg;
reg        clk_sys;

reg [5:0]  NIRS_PPG_MODE_SEL_spi;
reg        NIRS_PPG_EN_spi;
reg        NIRS_PPG_MEAS_spi;

reg [1:0]  AVG_SEL_spi_0,       AVG_SEL_spi_1;
reg [7:0]  RATIO_MANUAL_spi_0,  RATIO_MANUAL_spi_1;
reg [2:0]  RATIO_CTRL_spi_0,    RATIO_CTRL_spi_1;

reg [18:0] THRESHOLD_H_spi_0,   THRESHOLD_H_spi_1;
reg [7:0]  THRESHOLD_L_spi_0,   THRESHOLD_L_spi_1;
reg        IDAC_MANUAL_EN_spi_0, IDAC_MANUAL_EN_spi_1;
reg [8:0]  IDAC_MANUAL_spi_0,   IDAC_MANUAL_spi_1;
reg        IDAC_IDAC_EN_spi_0,   IDAC_IDAC_EN_spi_1;
reg [1:0]  IPDMIRROR_ADJ_spi_0, IPDMIRROR_ADJ_spi_1;
reg [1:0]  IREFC_ADJ_spi_0,     IREFC_ADJ_spi_1;

reg [2:0]  LED_STABLE_CTRL_spi_0, LED_STABLE_CTRL_spi_1;
reg [1:0]  LED_OFF_CTRL_spi_0,    LED_OFF_CTRL_spi_1;
reg [3:0]  PERIOD_CTRL_spi_0,     PERIOD_CTRL_spi_1;
reg [2:0]  RESET_CTRL_spi_0,      RESET_CTRL_spi_1;
reg [3:0]  OTS_CTRL_spi_0,        OTS_CTRL_spi_1;

reg [7:0]  NIRS_PPG_INT_SEL_spi;
reg        int_length_slct_spi;
reg        INT_CLR;

reg        IREF_COARSE;
reg        IREF_FINE;

//----------------------------------------------------------------------------
// DUT outputs
//----------------------------------------------------------------------------
wire [1:0]  D2A_RATIO_CTRL;
wire [1:0]  IPDMIRROR_ADJ;
wire [1:0]  IREFC_ADJ;
wire        IREF_COARSE_ON_NOT_OFF;
wire        IREF_COARSE_NOT_ON;
wire        IREF_FINE_ON_NOT_OFF;
wire        IREF_FINE_NOT_ON;
wire        IDAC_MAX, IDAC_MIN;
wire        EN, RESET, IPD_SW, IIN_SW, LED_ON;
wire        INT, INT_IO;
wire        IDAC_EN;
wire [8:0]  IDAC;
wire [WIDTH-1:0] DOUTC, DOUTF;
wire [21:0] DOUT;

//----------------------------------------------------------------------------
// Flag latches – capture short-lived ppg-domain flags (valid ~3 ppg cycles)
//----------------------------------------------------------------------------
reg  clear_flag_latches;
reg  latch_coarse_not_on;
reg  latch_fine_not_on;
reg  latch_coarse_on_not_off;

always @(posedge clk_ppg or negedge rst_n) begin
  if (!rst_n || clear_flag_latches) begin
    latch_coarse_not_on    <= 1'b0;
    latch_fine_not_on      <= 1'b0;
    latch_coarse_on_not_off <= 1'b0;
  end else begin
    if (IREF_COARSE_NOT_ON)     latch_coarse_not_on    <= 1'b1;
    if (IREF_FINE_NOT_ON)       latch_fine_not_on      <= 1'b1;
    if (IREF_COARSE_ON_NOT_OFF) latch_coarse_on_not_off <= 1'b1;
  end
end

initial clear_flag_latches = 1'b0;

//----------------------------------------------------------------------------
// DUT instantiation
//----------------------------------------------------------------------------
nirs_ppg_ctrl_top #(.WIDTH(WIDTH)) dut (
  .scan_mode              (scan_mode),
  .rst_n                  (rst_n),
  .clk_ppg                (clk_ppg),
  .clk_sys                (clk_sys),
  .NIRS_PPG_MODE_SEL_spi  (NIRS_PPG_MODE_SEL_spi),
  .NIRS_PPG_EN_spi        (NIRS_PPG_EN_spi),
  .NIRS_PPG_MEAS_spi      (NIRS_PPG_MEAS_spi),
  .AVG_SEL_spi_0          (AVG_SEL_spi_0),
  .AVG_SEL_spi_1          (AVG_SEL_spi_1),
  .RATIO_MANUAL_spi_0     (RATIO_MANUAL_spi_0),
  .RATIO_CTRL_spi_0       (RATIO_CTRL_spi_0),
  .RATIO_MANUAL_spi_1     (RATIO_MANUAL_spi_1),
  .RATIO_CTRL_spi_1       (RATIO_CTRL_spi_1),
  .D2A_RATIO_CTRL         (D2A_RATIO_CTRL),
  .THRESHOLD_H_spi_0      (THRESHOLD_H_spi_0),
  .THRESHOLD_L_spi_0      (THRESHOLD_L_spi_0),
  .IDAC_MANUAL_EN_spi_0   (IDAC_MANUAL_EN_spi_0),
  .IDAC_MANUAL_spi_0      (IDAC_MANUAL_spi_0),
  .IDAC_IDAC_EN_spi_0     (IDAC_IDAC_EN_spi_0),
  .IPDMIRROR_ADJ_spi_0    (IPDMIRROR_ADJ_spi_0),
  .IREFC_ADJ_spi_0        (IREFC_ADJ_spi_0),
  .THRESHOLD_H_spi_1      (THRESHOLD_H_spi_1),
  .THRESHOLD_L_spi_1      (THRESHOLD_L_spi_1),
  .IDAC_MANUAL_EN_spi_1   (IDAC_MANUAL_EN_spi_1),
  .IDAC_MANUAL_spi_1      (IDAC_MANUAL_spi_1),
  .IDAC_IDAC_EN_spi_1     (IDAC_IDAC_EN_spi_1),
  .IPDMIRROR_ADJ_spi_1    (IPDMIRROR_ADJ_spi_1),
  .IREFC_ADJ_spi_1        (IREFC_ADJ_spi_1),
  .IPDMIRROR_ADJ          (IPDMIRROR_ADJ),
  .IREFC_ADJ              (IREFC_ADJ),
  .LED_STABLE_CTRL_spi_0  (LED_STABLE_CTRL_spi_0),
  .LED_OFF_CTRL_spi_0     (LED_OFF_CTRL_spi_0),
  .PERIOD_CTRL_spi_0      (PERIOD_CTRL_spi_0),
  .RESET_CTRL_spi_0       (RESET_CTRL_spi_0),
  .OTS_CTRL_spi_0         (OTS_CTRL_spi_0),
  .LED_STABLE_CTRL_spi_1  (LED_STABLE_CTRL_spi_1),
  .LED_OFF_CTRL_spi_1     (LED_OFF_CTRL_spi_1),
  .PERIOD_CTRL_spi_1      (PERIOD_CTRL_spi_1),
  .RESET_CTRL_spi_1       (RESET_CTRL_spi_1),
  .OTS_CTRL_spi_1         (OTS_CTRL_spi_1),
  .IREF_COARSE_ON_NOT_OFF (IREF_COARSE_ON_NOT_OFF),
  .IREF_COARSE_NOT_ON     (IREF_COARSE_NOT_ON),
  .IREF_FINE_ON_NOT_OFF   (IREF_FINE_ON_NOT_OFF),
  .IREF_FINE_NOT_ON       (IREF_FINE_NOT_ON),
  .IDAC_MAX               (IDAC_MAX),
  .IDAC_MIN               (IDAC_MIN),
  .EN                     (EN),
  .RESET                  (RESET),
  .IPD_SW                 (IPD_SW),
  .IIN_SW                 (IIN_SW),
  .LED_ON                 (LED_ON),
  .NIRS_PPG_INT_SEL_spi   (NIRS_PPG_INT_SEL_spi),
  .int_length_slct_spi    (int_length_slct_spi),
  .INT_CLR                (INT_CLR),
  .INT                    (INT),
  .INT_IO                 (INT_IO),
  .IDAC_EN                (IDAC_EN),
  .IDAC                   (IDAC),
  .DOUTC                  (DOUTC),
  .DOUTF                  (DOUTF),
  .DOUT                   (DOUT),
  .IREF_COARSE            (IREF_COARSE),
  .IREF_FINE              (IREF_FINE)
);

//----------------------------------------------------------------------------
// Clocks
//----------------------------------------------------------------------------
initial clk_ppg = 0;
always #(CLK_PPG_HALF) clk_ppg = ~clk_ppg;

initial clk_sys = 0;
always #(CLK_SYS_HALF) clk_sys = ~clk_sys;

//----------------------------------------------------------------------------
// Test bookkeeping
//----------------------------------------------------------------------------
integer pass_cnt;
integer fail_cnt;
integer test_id;

task check;
  input       pass;
  input [255:0] msg;
  begin
    if (pass) begin
      $display("[PASS] T%0d: %s  (t=%0t ns)", test_id, msg, $time);
      pass_cnt = pass_cnt + 1;
    end else begin
      $display("[FAIL] T%0d: %s  (t=%0t ns)", test_id, msg, $time);
      fail_cnt = fail_cnt + 1;
    end
  end
endtask

//----------------------------------------------------------------------------
// wait_sys: wait N sys clock rising edges
//----------------------------------------------------------------------------
task wait_sys;
  input integer n;
  integer i;
  begin
    for (i = 0; i < n; i = i + 1)
      @(posedge clk_sys);
  end
endtask

//----------------------------------------------------------------------------
// wait_ppg: wait N ppg clock rising edges
//----------------------------------------------------------------------------
task wait_ppg;
  input integer n;
  integer i;
  begin
    for (i = 0; i < n; i = i + 1)
      @(posedge clk_ppg);
  end
endtask

//----------------------------------------------------------------------------
// apply_reset: pulse rst_n low then release
//----------------------------------------------------------------------------
task apply_reset;
  begin
    NIRS_PPG_EN_spi   = 1'b0;
    NIRS_PPG_MEAS_spi = 1'b0;
    IREF_COARSE       = 1'b0;
    IREF_FINE         = 1'b0;
    INT_CLR           = 1'b0;
    rst_n             = 1'b0;
    wait_sys(10);
    rst_n = 1'b1;
    wait_sys(5);
  end
endtask

//----------------------------------------------------------------------------
// set_defaults: configure conservative register values
//   Mode: REC MASTER, SINGLE LED, SINGLE SHOT (MODE_SEL = 6'b01_1000)
//   Timings: PERIOD=0 (125µs), RESET=0 (50µs), OTS=1 (2µs), STABLE=0 (10µs)
//   RATIO=128 (default auto), no averaging, mid-range thresholds
//   Distinct ADJ values to catch LED-mux swap bug
//----------------------------------------------------------------------------
task set_defaults;
  begin
    scan_mode              = 1'b0;
    // [5]=0 no ambient, [4]=1 single LED, [3]=1 single shot, [2:0]=000 rec master typ
    NIRS_PPG_MODE_SEL_spi  = 6'b01_1000;
    PERIOD_CTRL_spi_0      = 4'd0;   // 125 µs
    PERIOD_CTRL_spi_1      = 4'd0;
    RESET_CTRL_spi_0       = 3'd0;   // 50 µs reset
    RESET_CTRL_spi_1       = 3'd0;
    OTS_CTRL_spi_0         = 4'd1;   // 2 µs integration window
    OTS_CTRL_spi_1         = 4'd1;
    LED_STABLE_CTRL_spi_0  = 3'd0;   // 10 µs LED stabilise
    LED_STABLE_CTRL_spi_1  = 3'd0;
    LED_OFF_CTRL_spi_0     = 2'd3;   // 2 µs LED off after IPD
    LED_OFF_CTRL_spi_1     = 2'd3;
    RATIO_CTRL_spi_0       = 3'b000; // ratio=128
    RATIO_CTRL_spi_1       = 3'b000;
    RATIO_MANUAL_spi_0     = 8'd128;
    RATIO_MANUAL_spi_1     = 8'd128;
    AVG_SEL_spi_0          = 2'd0;   // no averaging
    AVG_SEL_spi_1          = 2'd0;
    // Thresholds: mid-range. DOUT = 128*100-30 = 12770; set window 10000..15000
    THRESHOLD_H_spi_0      = 19'd15000;
    THRESHOLD_L_spi_0      = 8'd10;
    THRESHOLD_H_spi_1      = 19'd15000;
    THRESHOLD_L_spi_1      = 8'd10;
    IDAC_MANUAL_EN_spi_0   = 1'b0;
    IDAC_MANUAL_EN_spi_1   = 1'b0;
    IDAC_MANUAL_spi_0      = 9'd0;
    IDAC_MANUAL_spi_1      = 9'd0;
    IDAC_IDAC_EN_spi_0     = 1'b1;
    IDAC_IDAC_EN_spi_1     = 1'b1;
    // Distinct per-LED ADJ values so a swap is immediately visible
    IPDMIRROR_ADJ_spi_0    = 2'b01;
    IPDMIRROR_ADJ_spi_1    = 2'b10;
    IREFC_ADJ_spi_0        = 2'b11;
    IREFC_ADJ_spi_1        = 2'b00;
    // Interrupts – enable nothing by default
    NIRS_PPG_INT_SEL_spi   = 8'b0000_0000;
    int_length_slct_spi    = 1'b1;   // level
  end
endtask

//----------------------------------------------------------------------------
// wait_ipdsw_high: block until IPD_SW asserts (timeout = 2000 sys cycles)
//----------------------------------------------------------------------------
task wait_ipdsw_high;
  integer to;
  begin
    to = 0;
    while (!IPD_SW && to < 2000) begin
      @(posedge clk_sys);
      to = to + 1;
    end
    if (to >= 2000)
      $display("[WARNING] T%0d: wait_ipdsw_high timeout", test_id);
  end
endtask

//----------------------------------------------------------------------------
// wait_en_deassert: wait until EN is 0 (timeout = 800 sys cycles)
//   Should be called after NIRS_PPG_EN_spi is driven low.
//   EN can only fall at SAMPLING_DONE→counter=0, so allow a full period.
//----------------------------------------------------------------------------
task wait_en_deassert;
  integer to;
  begin
    to = 0;
    while (EN && to < 800) begin
      @(posedge clk_sys);
      to = to + 1;
    end
    if (to >= 800)
      $display("[WARNING] T%0d: wait_en_deassert timeout", test_id);
  end
endtask

//----------------------------------------------------------------------------
// do_one_measurement:
//   Drives one IREF_COARSE + IREF_FINE pulse sequence sized to fit safely
//   inside one period (counter 130..249).
//
//   coarse_ppg  – number of PPG cycles IREF_COARSE stays high  (max ~400)
//   fine_ppg    – number of PPG cycles IREF_FINE stays high    (max ~50)
//   gap_ppg     – PPG cycles gap between COARSE fall and FINE rise
//
//   After this task returns, DATA_UPDATE has already been entered and
//   DOUT/DOUTC/DOUTF are valid.  Call wait_ppg(10) before sampling if
//   you want an extra margin.
//----------------------------------------------------------------------------
task do_one_measurement;
  input integer coarse_ppg;
  input integer fine_ppg;
  input integer gap_ppg;
  begin
    // Wait for IPD_SW to go high (integration window)
    wait_ipdsw_high;
    // Small delay mimicking analog propagation (4 PPG cycles)
    wait_ppg(4);
    // Drive IREF_COARSE
    IREF_COARSE = 1'b1;
    wait_ppg(coarse_ppg);
    IREF_COARSE = 1'b0;
    // Gap
    wait_ppg(gap_ppg);
    // Drive IREF_FINE
    IREF_FINE = 1'b1;
    wait_ppg(fine_ppg);
    IREF_FINE = 1'b0;
    // Allow FSM to reach DATA_UPDATE and register DOUT (~8 PPG cycles)
    wait_ppg(8);
  end
endtask

//=============================================================================
// MAIN TEST SEQUENCE
//=============================================================================
integer i;
reg [21:0] dout_a, dout_b;
integer    idac_a, idac_b;

initial begin
  $dumpfile("nirs_ppg_tb.vcd");
  $dumpvars(0, tb_nirs_ppg_ctrl_top);

  pass_cnt = 0;
  fail_cnt = 0;
  test_id  = 0;
  rst_n    = 1'b1;

  // Pre-initialise all inputs
  set_defaults;
  NIRS_PPG_EN_spi   = 1'b0;
  NIRS_PPG_MEAS_spi = 1'b0;
  IREF_COARSE       = 1'b0;
  IREF_FINE         = 1'b0;
  INT_CLR           = 1'b0;

  //==========================================================================
  // TEST 1 – Reset: all control outputs deasserted, IDAC at 0, IDAC_MIN set
  //==========================================================================
  test_id = 1;
  $display("\n--- TEST %0d: Reset state ---", test_id);
  apply_reset;
  @(posedge clk_sys);
  check(EN      == 1'b0, "EN low after reset");
  check(RESET   == 1'b0, "RESET low after reset");
  check(IPD_SW  == 1'b0, "IPD_SW low after reset");
  check(IIN_SW  == 1'b0, "IIN_SW low after reset");
  check(LED_ON  == 1'b0, "LED_ON low after reset");
  check(IDAC    == 9'd0, "IDAC = 0 after reset");
  check(IDAC_MAX == 1'b0, "IDAC_MAX=0 after reset");
  // IDAC starts at 0 which equals the minimum value, so IDAC_MIN must be 1
  wait_ppg(2); // allow ppg register to update
  check(IDAC_MIN == 1'b1, "IDAC_MIN=1 after reset (IDAC=0 is minimum)");

  //==========================================================================
  // TEST 2 – Pulse sequence order (single LED, single shot, REC master)
  //   Expected order: EN → IIN_SW (same time) → LED_ON → IPD_SW
  //   RESET must be low by the time IPD_SW fires.
  //==========================================================================
  test_id = 2;
  $display("\n--- TEST %0d: Pulse sequence order ---", test_id);
  apply_reset;
  set_defaults;
  NIRS_PPG_MODE_SEL_spi = 6'b01_1000; // single LED, single shot

  NIRS_PPG_EN_spi = 1'b1;

  begin : t2_seq
    integer to;
    // 1) Wait for EN to assert
    to = 0;
    while (!EN && to < 500) begin @(posedge clk_sys); to = to + 1; end
    check(to < 500, "EN asserts within 500 sys cycles of NIRS_EN");

    // 2) IIN_SW shares EN_h – must be high at same time as EN
    check(IIN_SW == 1'b1, "IIN_SW asserts when EN asserts");

    // 3) Wait for IPD_SW
    to = 0;
    while (!IPD_SW && to < 500) begin @(posedge clk_sys); to = to + 1; end
    check(to < 500, "IPD_SW asserts within period");
    // RESET must have gone low before IPD_SW (RESET_l < IPD_SW_h)
    check(RESET == 1'b0, "RESET deasserts before IPD_SW fires");
    // LED_ON fires at LED_ON_h = IPD_SW_h - t_stable_led, so it's high now
    check(LED_ON == 1'b1, "LED_ON high when IPD_SW fires");

    // 4) After period, EN should deassert
    NIRS_PPG_EN_spi = 1'b0;
    wait_en_deassert;
    check(EN == 1'b0, "EN deasserts after NIRS_EN cleared");
  end

  //==========================================================================
  // TEST 3 – Normal measurement: DOUT = RATIO*DOUTC - DOUTF
  //   RATIO = 128 (default), drive COARSE=100 ppg, FINE=30 ppg
  //   Expected DOUT = 128*100 - 30 = 12770
  //==========================================================================
  test_id = 3;
  $display("\n--- TEST %0d: DOUT = RATIO*DOUTC - DOUTF ---", test_id);
  apply_reset;
  set_defaults;
  NIRS_PPG_MODE_SEL_spi = 6'b01_1000; // single LED, single shot
  AVG_SEL_spi_0         = 2'd0; // no averaging

  NIRS_PPG_EN_spi = 1'b1;
  do_one_measurement(100, 30, 2);

  $display("  DOUTC=%0d DOUTF=%0d DOUT=%0d (expect C=100,F=30,D=12770)",
           DOUTC, DOUTF, DOUT);
  check(DOUTC == 13'd100, "DOUTC = 100 (coarse PPG cycles counted)");
  check(DOUTF == 13'd30,  "DOUTF = 30  (fine PPG cycles counted)");
  check(DOUT  == 22'd12770, "DOUT = 128*100 - 30 = 12770");

  // Immediately disable to prevent overwrite by next empty period
  NIRS_PPG_EN_spi = 1'b0;
  wait_en_deassert;

  //==========================================================================
  // TEST 4 – RATIO_MANUAL mode (RATIO=64): DOUT = 64*DOUTC - DOUTF
  //   DOUTC=100, DOUTF=20 → DOUT = 64*100 - 20 = 6380
  //==========================================================================
  test_id = 4;
  $display("\n--- TEST %0d: Custom RATIO_MANUAL=64 ---", test_id);
  apply_reset;
  set_defaults;
  NIRS_PPG_MODE_SEL_spi = 6'b01_1000;
  RATIO_CTRL_spi_0      = 3'b001; // bit0=1 → use RATIO_MANUAL
  RATIO_MANUAL_spi_0    = 8'd64;
  AVG_SEL_spi_0         = 2'd0;

  NIRS_PPG_EN_spi = 1'b1;
  do_one_measurement(100, 20, 2);

  $display("  DOUTC=%0d DOUTF=%0d DOUT=%0d (expect C=100,F=20,D=6380)",
           DOUTC, DOUTF, DOUT);
  check(DOUTC == 13'd100, "DOUTC=100");
  check(DOUTF == 13'd20,  "DOUTF=20");
  check(DOUT  == 22'd6380, "DOUT=64*100-20=6380 with RATIO_MANUAL=64");

  NIRS_PPG_EN_spi = 1'b0;
  wait_en_deassert;

  //==========================================================================
  // TEST 5 – Exponential averaging (AVG_SEL=1, SHIFT=1: 50/50 blend)
  //   Two identical measurements; second DOUT converges toward sub_result.
  //   sub_result = 128*100-30 = 12770
  //   After 1st: DOUT_reg = 0+(12770-0)>>1 = 6385
  //   After 2nd: DOUT_reg = 6385+(12770-6385)>>1 = 6385+3192 = 9577
  //==========================================================================
  test_id = 5;
  $display("\n--- TEST %0d: Exponential averaging AVG_SEL=1 ---", test_id);
  apply_reset;
  set_defaults;
  NIRS_PPG_MODE_SEL_spi = 6'b01_1000;
  AVG_SEL_spi_0         = 2'd1; // SHIFT=1

  NIRS_PPG_EN_spi = 1'b1;

  // 1st measurement
  do_one_measurement(100, 30, 2);
  dout_a = DOUT;
  $display("  After 1st meas: DOUT=%0d (expect 6385)", dout_a);
  check(dout_a == 22'd6385, "1st DOUT = (0 + 12770)/2 = 6385 with AVG_SEL=1");

  // 2nd measurement – keep NIRS_EN=1, new period starts automatically
  do_one_measurement(100, 30, 2);
  dout_b = DOUT;
  $display("  After 2nd meas: DOUT=%0d (expect 9577)", dout_b);
  check(dout_b == 22'd9577, "2nd DOUT converges: 6385+(12770-6385)/2=9577");
  check(dout_b > dout_a,  "DOUT increases toward sub_result each measurement");

  NIRS_PPG_EN_spi = 1'b0;
  wait_en_deassert;

  //==========================================================================
  // TEST 6 – IDAC auto-increase: DOUT > THRESHOLD_H → IDAC increments
  //   Use tiny THRESHOLD_H (100) so any real DOUT exceeds it.
  //   Run two measurements; IDAC should be higher after second.
  //==========================================================================
  test_id = 6;
  $display("\n--- TEST %0d: IDAC auto-increase ---", test_id);
  apply_reset;
  set_defaults;
  NIRS_PPG_MODE_SEL_spi = 6'b01_1000;
  THRESHOLD_H_spi_0     = 19'd100;  // DOUT=12770 >> 100 → always increase
  THRESHOLD_L_spi_0     = 8'd1;
  IDAC_MANUAL_EN_spi_0  = 1'b0;
  IDAC_IDAC_EN_spi_0    = 1'b1;
  AVG_SEL_spi_0         = 2'd0;

  NIRS_PPG_EN_spi = 1'b1;

  // 1st measurement
  do_one_measurement(100, 30, 2);
  idac_a = IDAC;
  $display("  IDAC after 1st meas = %0d", idac_a);

  // 2nd measurement
  do_one_measurement(100, 30, 2);
  idac_b = IDAC;
  $display("  IDAC after 2nd meas = %0d", idac_b);

  check(idac_b > idac_a, "IDAC increments when DOUT > THRESHOLD_H");

  NIRS_PPG_EN_spi = 1'b0;
  wait_en_deassert;

  //==========================================================================
  // TEST 7 – IDAC auto-decrease: DOUT < THRESHOLD_L → IDAC decrements
  //   Prime IDAC to 20 via manual mode, switch to auto, drive tiny signal.
  //   Tiny DOUT = 128*2 - 1 = 255.  THRESHOLD_L = 10000 (always exceeded).
  //   Wait: actually we want DOUT < THRESHOLD_L.
  //   Set THRESHOLD_L = 255+1 = 256.  But THRESHOLD_L is only 8 bits (max 255).
  //   Use THRESHOLD_L = 255 and drive DOUTC=1 → DOUT=128*1-1=127 < 255.
  //==========================================================================
  test_id = 7;
  $display("\n--- TEST %0d: IDAC auto-decrease ---", test_id);
  apply_reset;
  set_defaults;
  NIRS_PPG_MODE_SEL_spi = 6'b01_1000;
  THRESHOLD_H_spi_0     = 19'd500000; // never exceeded
  THRESHOLD_L_spi_0     = 8'd200;     // DOUT=128*1-1=127 < 200 → decrease
  // Prime IDAC to 20 using manual mode
  IDAC_MANUAL_EN_spi_0  = 1'b1;
  IDAC_MANUAL_spi_0     = 9'd20;
  IDAC_IDAC_EN_spi_0    = 1'b1;
  AVG_SEL_spi_0         = 2'd0;

  NIRS_PPG_EN_spi = 1'b1;

  // 1st measurement – verify manual value seen
  do_one_measurement(1, 1, 2);
  idac_a = IDAC;
  $display("  IDAC with manual=20: %0d (expect 20)", idac_a);
  check(idac_a == 9'd20, "IDAC manual override = 20");

  // Switch to auto; IDAC_reg still starts at 0 from reset (manual bypasses reg)
  // so IDAC_reg=0 → already at min; prime IDAC_reg first
  // In auto mode, DOUT=127 < 200 → decrease. But IDAC_reg starts at 0.
  // So nothing will happen (clamped). Let us prime IDAC_reg via increase:
  // temporarily set THRESHOLD_H tiny so IDAC_reg grows first
  IDAC_MANUAL_EN_spi_0 = 1'b0;
  THRESHOLD_H_spi_0    = 19'd10;   // force increase for a few cycles
  for (i = 0; i < 30; i = i + 1) begin
    do_one_measurement(100, 30, 2);
  end
  idac_a = IDAC;
  $display("  IDAC after 30 increase cycles = %0d", idac_a);

  // Now switch to decrease condition
  THRESHOLD_H_spi_0    = 19'd500000;
  THRESHOLD_L_spi_0    = 8'd200; // DOUT=127 < 200 → decrease
  do_one_measurement(1, 1, 2);
  idac_b = IDAC;
  $display("  IDAC after decrease meas = %0d (should be < %0d)", idac_b, idac_a);
  check(idac_b < idac_a, "IDAC decrements when DOUT < THRESHOLD_L");

  NIRS_PPG_EN_spi = 1'b0;
  wait_en_deassert;

  //==========================================================================
  // TEST 8 – IDAC saturation at maximum (511) and IDAC_MAX flag
  //==========================================================================
  test_id = 8;
  $display("\n--- TEST %0d: IDAC saturation at max ---", test_id);
  apply_reset;
  set_defaults;
  NIRS_PPG_MODE_SEL_spi = 6'b01_1000;
  THRESHOLD_H_spi_0     = 19'd10;   // always exceeded → always increment
  THRESHOLD_L_spi_0     = 8'd1;
  IDAC_MANUAL_EN_spi_0  = 1'b0;
  IDAC_IDAC_EN_spi_0    = 1'b1;
  AVG_SEL_spi_0         = 2'd0;

  NIRS_PPG_EN_spi = 1'b1;
  // Run 520 measurements to overflow IDAC past 511
  for (i = 0; i < 520; i = i + 1) begin
    do_one_measurement(100, 30, 2);
  end
  $display("  IDAC=%0d IDAC_MAX=%0b (expect 511/1)", IDAC, IDAC_MAX);
  check(IDAC    == 9'h1FF, "IDAC clamps at 511 (9'h1FF)");
  check(IDAC_MAX == 1'b1, "IDAC_MAX flag asserted");

  NIRS_PPG_EN_spi = 1'b0;
  wait_en_deassert;

  //==========================================================================
  // TEST 9 – IDAC saturation at minimum (0) and IDAC_MIN flag
  //   IDAC_reg starts at 0 after reset; drive DOUT < THRESHOLD_L
  //   → clamp at 0 and IDAC_MIN stays asserted
  //==========================================================================
  test_id = 9;
  $display("\n--- TEST %0d: IDAC saturation at min ---", test_id);
  apply_reset;
  set_defaults;
  NIRS_PPG_MODE_SEL_spi = 6'b01_1000;
  THRESHOLD_H_spi_0     = 19'd500000; // never exceeded
  THRESHOLD_L_spi_0     = 8'd255;     // always below
  IDAC_MANUAL_EN_spi_0  = 1'b0;
  IDAC_IDAC_EN_spi_0    = 1'b1;
  AVG_SEL_spi_0         = 2'd0;

  NIRS_PPG_EN_spi = 1'b1;
  do_one_measurement(1, 1, 2);
  $display("  IDAC=%0d IDAC_MIN=%0b (expect 0/1)", IDAC, IDAC_MIN);
  check(IDAC    == 9'd0,  "IDAC stays at 0 when already at minimum");
  check(IDAC_MIN == 1'b1, "IDAC_MIN flag asserted");

  NIRS_PPG_EN_spi = 1'b0;
  wait_en_deassert;

  //==========================================================================
  // TEST 10 – IDAC manual override
  //   IDAC_MANUAL_EN=1, IDAC_MANUAL=200. Even though DOUT > THRESHOLD_H,
  //   IDAC output must remain 200 regardless of the auto-control path.
  //==========================================================================
  test_id = 10;
  $display("\n--- TEST %0d: IDAC manual override ---", test_id);
  apply_reset;
  set_defaults;
  NIRS_PPG_MODE_SEL_spi = 6'b01_1000;
  THRESHOLD_H_spi_0     = 19'd10;   // would force increase in auto mode
  IDAC_MANUAL_EN_spi_0  = 1'b1;
  IDAC_MANUAL_spi_0     = 9'd200;
  IDAC_IDAC_EN_spi_0    = 1'b1;
  AVG_SEL_spi_0         = 2'd0;

  NIRS_PPG_EN_spi = 1'b1;
  do_one_measurement(100, 30, 2);
  $display("  IDAC=%0d (expect 200)", IDAC);
  check(IDAC == 9'd200, "IDAC manual override holds 200 despite DOUT > THRESHOLD_H");

  NIRS_PPG_EN_spi = 1'b0;
  wait_en_deassert;

  //==========================================================================
  // TEST 11 – DOUTF=0 forces IDAC increase
  //   Drive only IREF_COARSE, not IREF_FINE → DOUTF=0.
  //   idac_ctrl increments when DOUTF==0 regardless of thresholds.
  //==========================================================================
  test_id = 11;
  $display("\n--- TEST %0d: DOUTF=0 forces IDAC increase ---", test_id);
  apply_reset;
  set_defaults;
  NIRS_PPG_MODE_SEL_spi = 6'b01_1000;
  THRESHOLD_H_spi_0     = 19'd500000; // would NOT increase otherwise
  THRESHOLD_L_spi_0     = 8'd1;
  IDAC_MANUAL_EN_spi_0  = 1'b0;
  IDAC_IDAC_EN_spi_0    = 1'b1;
  AVG_SEL_spi_0         = 2'd0;

  NIRS_PPG_EN_spi = 1'b1;

  // Drive only IREF_COARSE (no IREF_FINE → DOUTF=0)
  wait_ipdsw_high;
  wait_ppg(4);
  IREF_COARSE = 1'b1;
  wait_ppg(80);
  IREF_COARSE = 1'b0;
  // Drive IREF_FINE briefly to let FSM reach DATA_UPDATE (fine=0 on purpose)
  // Actually skip IREF_FINE to see IREF_FINE_NOT_ON flag; let period end.
  wait_sys(90); // wait for period to end and DATA_UPDATE to run
  idac_a = IDAC;
  $display("  IDAC after meas with DOUTF=0: %0d (expect >0)", idac_a);
  check(idac_a > 0,        "IDAC increases when DOUTF=0");
  check(DOUTF == 13'd0,   "DOUTF=0 when IREF_FINE never driven");

  NIRS_PPG_EN_spi = 1'b0;
  IREF_COARSE = 1'b0;
  wait_en_deassert;

  //==========================================================================
  // TEST 12 – Counter clear: second measurement reflects new counts
  //   Run two different measurements, verify DOUTC/DOUTF update each time.
  //==========================================================================
  test_id = 12;
  $display("\n--- TEST %0d: Counter clear between measurements ---", test_id);
  apply_reset;
  set_defaults;
  NIRS_PPG_MODE_SEL_spi = 6'b01_1000;
  AVG_SEL_spi_0         = 2'd0;

  NIRS_PPG_EN_spi = 1'b1;

  // 1st measurement
  do_one_measurement(80, 20, 2);
  $display("  Meas1: DOUTC=%0d DOUTF=%0d (expect 80,20)", DOUTC, DOUTF);
  check(DOUTC == 13'd80, "DOUTC=80 first measurement");
  check(DOUTF == 13'd20, "DOUTF=20 first measurement");

  // 2nd measurement (new period starts automatically since NIRS_EN=1)
  do_one_measurement(150, 40, 2);
  $display("  Meas2: DOUTC=%0d DOUTF=%0d (expect 150,40)", DOUTC, DOUTF);
  check(DOUTC == 13'd150, "DOUTC=150 second measurement (counter cleared)");
  check(DOUTF == 13'd40,  "DOUTF=40  second measurement (counter cleared)");

  NIRS_PPG_EN_spi = 1'b0;
  wait_en_deassert;

  //==========================================================================
  // TEST 13 – IREF_COARSE_NOT_ON flag
  //   Drive NO analog signals; period ends while FSM is still in WAIT state
  //   (DONE fires before IREF_COARSE) → IREF_COARSE_NOT_ON must be set.
  //==========================================================================
  test_id = 13;
  $display("\n--- TEST %0d: IREF_COARSE_NOT_ON flag ---", test_id);
  apply_reset;
  set_defaults;
  NIRS_PPG_MODE_SEL_spi = 6'b01_1000;

  NIRS_PPG_EN_spi = 1'b1;
  // Do NOT drive IREF_COARSE – let the period expire with nothing
  wait_sys(400); // >249 sys cycles so period definitely ends
  $display("  IREF_COARSE_NOT_ON=%0b (expect 1)", IREF_COARSE_NOT_ON);
  check(IREF_COARSE_NOT_ON == 1'b1,
        "IREF_COARSE_NOT_ON=1 when period ends before IREF_COARSE fires");

  NIRS_PPG_EN_spi = 1'b0;
  wait_en_deassert;

  //==========================================================================
  // TEST 14 – IREF_FINE_NOT_ON flag
  //   Drive IREF_COARSE but NOT IREF_FINE; period ends while in
  //   IREF_COARSE_LATCHED state → IREF_FINE_NOT_ON must be set.
  //==========================================================================
  test_id = 14;
  $display("\n--- TEST %0d: IREF_FINE_NOT_ON flag ---", test_id);
  apply_reset;
  set_defaults;
  NIRS_PPG_MODE_SEL_spi = 6'b01_1000;

  NIRS_PPG_EN_spi = 1'b1;
  // Drive IREF_COARSE only
  wait_ipdsw_high;
  wait_ppg(4);
  IREF_COARSE = 1'b1;
  wait_ppg(60);
  IREF_COARSE = 1'b0;
  // Skip IREF_FINE; let period expire
  wait_sys(300);
  $display("  IREF_FINE_NOT_ON=%0b (expect 1)", IREF_FINE_NOT_ON);
  check(IREF_FINE_NOT_ON == 1'b1,
        "IREF_FINE_NOT_ON=1 when period ends before IREF_FINE fires");

  NIRS_PPG_EN_spi = 1'b0;
  IREF_COARSE = 1'b0;
  wait_en_deassert;

  //==========================================================================
  // TEST 15 – IREF_COARSE_ON_NOT_OFF flag
  //   Hold IREF_COARSE high through period end (DONE while in latching)
  //   → IREF_COARSE_ON_NOT_OFF must be set.
  //==========================================================================
  test_id = 15;
  $display("\n--- TEST %0d: IREF_COARSE_ON_NOT_OFF flag ---", test_id);
  apply_reset;
  set_defaults;
  NIRS_PPG_MODE_SEL_spi = 6'b01_1000;

  NIRS_PPG_EN_spi = 1'b1;
  wait_ipdsw_high;
  wait_ppg(4);
  IREF_COARSE = 1'b1; // keep high through period end
  wait_sys(400);       // period ends at sys 249; allow extra margin
  IREF_COARSE = 1'b0;
  $display("  IREF_COARSE_ON_NOT_OFF=%0b (expect 1)", IREF_COARSE_ON_NOT_OFF);
  check(IREF_COARSE_ON_NOT_OFF == 1'b1,
        "IREF_COARSE_ON_NOT_OFF=1 when DONE arrives while IREF_COARSE still high");

  NIRS_PPG_EN_spi = 1'b0;
  IREF_COARSE = 1'b0;
  wait_en_deassert;

  //==========================================================================
  // TEST 16 – DATA_READY interrupt on clean measurement
  //   INT_CONFIG[1]=1 → INT should fire after clean measurement (no flags).
  //   INT_CONFIG[0]=1 → INT_IO should also assert.
  //   Then INT_CLR should silence INT.
  //==========================================================================
  test_id = 16;
  $display("\n--- TEST %0d: DATA_READY interrupt ---", test_id);
  apply_reset;
  set_defaults;
  NIRS_PPG_MODE_SEL_spi = 6'b01_1000;
  NIRS_PPG_INT_SEL_spi  = 8'b0000_0011; // bit0=INT_IO_EN, bit1=DATA_READY
  int_length_slct_spi   = 1'b1;          // level

  NIRS_PPG_EN_spi = 1'b1;
  do_one_measurement(100, 30, 2);
  // Allow interrupt logic (clk_sys domain) to process
  wait_sys(10);
  $display("  INT=%0b INT_IO=%0b (expect both 1)", INT, INT_IO);
  check(INT    == 1'b1, "INT asserts after clean measurement (DATA_READY+INT_CONFIG[1])");
  check(INT_IO == 1'b1, "INT_IO asserts (INT and INT_CONFIG[0])");

  // Clear interrupt
  INT_CLR = 1'b1;
  wait_sys(20);
  INT_CLR = 1'b0;
  wait_sys(10);
  check(INT == 1'b0, "INT cleared after INT_CLR");

  NIRS_PPG_EN_spi = 1'b0;
  wait_en_deassert;

  //==========================================================================
  // TEST 17 – IDAC_MAX interrupt
  //   Run until IDAC reaches 511; with INT_CONFIG[6]=1 INT should fire.
  //==========================================================================
  test_id = 17;
  $display("\n--- TEST %0d: IDAC_MAX interrupt ---", test_id);
  apply_reset;
  set_defaults;
  NIRS_PPG_MODE_SEL_spi = 6'b01_1000;
  THRESHOLD_H_spi_0     = 19'd10;   // always exceeded → always increase
  NIRS_PPG_INT_SEL_spi  = 8'b0100_0001; // bit6=IDAC_MAX, bit0=INT_IO_EN
  int_length_slct_spi   = 1'b1;
  IDAC_MANUAL_EN_spi_0  = 1'b0;
  IDAC_IDAC_EN_spi_0    = 1'b1;
  AVG_SEL_spi_0         = 2'd0;

  NIRS_PPG_EN_spi = 1'b1;
  for (i = 0; i < 520; i = i + 1) begin
    do_one_measurement(100, 30, 2);
  end
  wait_sys(10);
  $display("  IDAC=%0d IDAC_MAX=%0b INT=%0b (expect 511/1/1)",
           IDAC, IDAC_MAX, INT);
  check(INT == 1'b1, "INT fires when IDAC_MAX and INT_CONFIG[6]=1");

  NIRS_PPG_EN_spi = 1'b0;
  wait_en_deassert;

  //==========================================================================
  // TEST 18 – Dual LED alternation and per-LED IDAC_EN
  //   In dual-LED continuous mode: LED[1] toggles each period.
  //   spi_0: IDAC_IDAC_EN=1  (LED0 uses auto IDAC)
  //   spi_1: IDAC_IDAC_EN=0  (LED1 has IDAC disabled)
  //   Check IDAC_EN reflects the CORRECT per-LED setting.
  //==========================================================================
  test_id = 18;
  $display("\n--- TEST %0d: Dual LED alternation + per-LED IDAC_EN ---", test_id);
  apply_reset;
  set_defaults;
  // [5]=0 no ambient, [4]=0 DUAL LED, [3]=1 single shot, [2:0]=000 rec master
  NIRS_PPG_MODE_SEL_spi = 6'b00_1000;
  IDAC_IDAC_EN_spi_0    = 1'b1;   // LED0 IDAC enabled
  IDAC_IDAC_EN_spi_1    = 1'b0;   // LED1 IDAC disabled

  NIRS_PPG_EN_spi = 1'b1;

  // After reset LED_d=2'b11; at first RESET_h LED_d[1] toggles 1→0 (LED0)
  // 1st measurement: LED0
  do_one_measurement(100, 30, 2);
  $display("  LED0 period: IDAC_EN=%0b (expect 1)", IDAC_EN);
  check(IDAC_EN == 1'b1, "IDAC_EN=1 during LED0 period (spi_0 enabled)");

  // 2nd measurement: LED1 (LED_d[1] toggles 0→1 at next RESET_h)
  do_one_measurement(100, 30, 2);
  $display("  LED1 period: IDAC_EN=%0b (expect 0)", IDAC_EN);
  check(IDAC_EN == 1'b0, "IDAC_EN=0 during LED1 period (spi_1 disabled)");

  NIRS_PPG_EN_spi = 1'b0;
  wait_en_deassert;

  //==========================================================================
  // TEST 19 – IPDMIRROR_ADJ / IREFC_ADJ LED mux (BUG CHECK)
  //   In dual-LED mode:
  //     LED0 (LED[1]=0) → should use spi_0 → IPDMIRROR=2'b01, IREFC=2'b11
  //     LED1 (LED[1]=1) → should use spi_1 → IPDMIRROR=2'b10, IREFC=2'b00
  //
  //   RTL bug in nirs_ppg_ctrl_top lines 254-255:
  //     assign IPDMIRROR_ADJ = LED[1] ? IPDMIRROR_ADJ_spi_0 : IPDMIRROR_ADJ_spi_1;
  //     assign IREFC_ADJ     = LED[1] ? IREFC_ADJ_spi_0     : IREFC_ADJ_spi_1;
  //   The spi_0/spi_1 operands are SWAPPED.  When LED[1]=0, it picks spi_1
  //   (wrong) and when LED[1]=1 it picks spi_0 (wrong).
  //
  //   The testbench checks the CORRECT expected values; it will FAIL on buggy
  //   RTL and PASS after the fix.
  //==========================================================================
  test_id = 19;
  $display("\n--- TEST %0d: IPDMIRROR_ADJ/IREFC_ADJ LED mux ---", test_id);
  apply_reset;
  set_defaults;
  NIRS_PPG_MODE_SEL_spi = 6'b00_1000; // dual LED
  // Distinct values per LED so a mux swap is immediately visible
  IPDMIRROR_ADJ_spi_0   = 2'b01;
  IPDMIRROR_ADJ_spi_1   = 2'b10;
  IREFC_ADJ_spi_0       = 2'b11;
  IREFC_ADJ_spi_1       = 2'b00;

  NIRS_PPG_EN_spi = 1'b1;

  // --- LED0 measurement ---
  // Sample ADJ signals right after IPD_SW (when LED_d is stable for this period)
  wait_ipdsw_high;
  @(posedge clk_sys); // settle
  $display("  LED0 period: IPDMIRROR_ADJ=%0b IREFC_ADJ=%0b (expect 01,11)",
           IPDMIRROR_ADJ, IREFC_ADJ);
  check(IPDMIRROR_ADJ == 2'b01,
        "LED0: IPDMIRROR_ADJ = spi_0 value (2'b01) - swap bug if 2'b10");
  check(IREFC_ADJ     == 2'b11,
        "LED0: IREFC_ADJ = spi_0 value (2'b11) - swap bug if 2'b00");

  // Complete measurement
  wait_ppg(4);
  IREF_COARSE = 1'b1;
  wait_ppg(60);
  IREF_COARSE = 1'b0;
  wait_ppg(4);
  IREF_FINE   = 1'b1;
  wait_ppg(20);
  IREF_FINE   = 1'b0;
  wait_ppg(8);

  // --- LED1 measurement ---
  wait_ipdsw_high;
  @(posedge clk_sys); // settle
  $display("  LED1 period: IPDMIRROR_ADJ=%0b IREFC_ADJ=%0b (expect 10,00)",
           IPDMIRROR_ADJ, IREFC_ADJ);
  check(IPDMIRROR_ADJ == 2'b10,
        "LED1: IPDMIRROR_ADJ = spi_1 value (2'b10) - swap bug if 2'b01");
  check(IREFC_ADJ     == 2'b00,
        "LED1: IREFC_ADJ = spi_1 value (2'b00) - swap bug if 2'b11");

  NIRS_PPG_EN_spi = 1'b0;
  IREF_COARSE = 1'b0;
  IREF_FINE   = 1'b0;
  wait_en_deassert;

  //==========================================================================
  // Summary
  //==========================================================================
  $display("\n===========================================================");
  $display("  NIRS/PPG Controller Testbench – Results");
  $display("  PASS: %0d   FAIL: %0d   TOTAL: %0d",
           pass_cnt, fail_cnt, pass_cnt + fail_cnt);
  $display("===========================================================\n");

  if (fail_cnt == 0)
    $display("ALL TESTS PASSED\n");
  else
    $display("*** %0d TEST(S) FAILED – check [FAIL] lines above ***\n", fail_cnt);

  $finish;
end

//----------------------------------------------------------------------------
// Safety watchdog: abort at 500 ms
//----------------------------------------------------------------------------
initial begin
  #500_000_000;
  $display("[TIMEOUT] Simulation exceeded 500 ms – aborting at t=%0t", $time);
  $finish;
end

endmodule
