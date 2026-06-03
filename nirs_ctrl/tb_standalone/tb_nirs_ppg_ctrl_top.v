// ============================================================================
// Standalone INTEGRATION testbench : nirs_ppg_ctrl_top
// ----------------------------------------------------------------------------
// Exercises the full per-channel NIRS datapath (pulse generator + measurement
// FSM + coarse/fine counters + DOUT compute + IDAC hysteresis loop + interrupt)
// end-to-end in RECEIVER-MASTER continuous mode, using a small behavioural
// "analog" model that emits IREF_COARSE / IREF_FINE in response to the EN /
// integration pulses (mimicking the current-mode dual-slope front end).
//
// Checks (per README section 12):
//   * pulse generator produces EN / RESET / IPD_SW / LED_ON every period
//   * a full measurement latches DOUTC>0 and DOUTF>0
//   * DOUT == RATIO*DOUTC - DOUTF   (RATIO=128, AVG_SEL=0)   <- ties counters
//                                                               to compute path
//   * DATA_READY / INT generated each clean measurement
//   * IDAC auto loop increments while DOUT stays above THRESHOLD_H
//   * IDAC manual mode forces a fixed code
//
// Free-running clk_ppg (fast) and clk_sys (2 MHz model) are supplied directly
// (the gating front-end nirs_ppg_cmd is verified separately).
// ============================================================================
`timescale 1ns/1ps

module tb_nirs_ppg_ctrl_top;

  localparam WIDTH = 13;

  reg              scan_mode, rst_n, clk_ppg, clk_sys;
  wire             COUNT_STOP;

  reg  [5:0]       MODE_SEL;
  reg              NIRS_EN, NIRS_MEAS;

  reg  [1:0]       AVG_SEL_0, AVG_SEL_1;
  reg  [7:0]       RATIO_MANUAL_0, RATIO_MANUAL_1;
  reg  [2:0]       RATIO_CTRL_0, RATIO_CTRL_1;
  wire [1:0]       D2A_RATIO_CTRL;

  reg  [18:0]      THRESHOLD_H_0, THRESHOLD_H_1;
  reg  [7:0]       THRESHOLD_L_0, THRESHOLD_L_1;
  reg              IDAC_MANUAL_EN_0, IDAC_MANUAL_EN_1;
  reg  [8:0]       IDAC_MANUAL_0, IDAC_MANUAL_1;
  reg              IDAC_IDAC_EN_0, IDAC_IDAC_EN_1;
  reg  [1:0]       IPDMIRROR_ADJ_0, IPDMIRROR_ADJ_1, IREFC_ADJ_0, IREFC_ADJ_1;
  wire [1:0]       IPDMIRROR_ADJ, IREFC_ADJ;

  reg  [2:0]       LED_STABLE_CTRL_0, LED_STABLE_CTRL_1;
  reg  [1:0]       LED_OFF_CTRL_0, LED_OFF_CTRL_1;
  reg  [3:0]       PERIOD_CTRL_0, PERIOD_CTRL_1;
  reg  [2:0]       RESET_CTRL_0, RESET_CTRL_1;
  reg  [3:0]       OTS_CTRL_0, OTS_CTRL_1;

  wire             IREF_COARSE_ON_NOT_OFF, IREF_COARSE_NOT_ON;
  wire             IREF_FINE_ON_NOT_OFF, IREF_FINE_NOT_ON, IDAC_MAX, IDAC_MIN;

  wire             EN, RESET, IPD_SW, IIN_SW, LED_ON;

  reg  [7:0]       NIRS_PPG_INT_SEL;
  reg              int_length_slct, INT_CLR;
  wire             INT, INT_IO;

  wire             IDAC_EN;
  wire [8:0]       IDAC;
  wire [WIDTH-1:0] DOUTC, DOUTF;
  wire [21:0]      DOUT;

  reg              IREF_COARSE, IREF_FINE;

  integer errors = 0;
  integer checks = 0;

  nirs_ppg_ctrl_top #(.WIDTH(WIDTH)) dut (
    .scan_mode (scan_mode), .rst_n (rst_n), .clk_ppg (clk_ppg), .clk_sys (clk_sys),
    .COUNT_STOP (COUNT_STOP),
    .NIRS_PPG_MODE_SEL_spi (MODE_SEL), .NIRS_PPG_EN_spi (NIRS_EN), .NIRS_PPG_MEAS_spi (NIRS_MEAS),
    .AVG_SEL_spi_0 (AVG_SEL_0), .AVG_SEL_spi_1 (AVG_SEL_1),
    .RATIO_MANUAL_spi_0 (RATIO_MANUAL_0), .RATIO_CTRL_spi_0 (RATIO_CTRL_0),
    .RATIO_MANUAL_spi_1 (RATIO_MANUAL_1), .RATIO_CTRL_spi_1 (RATIO_CTRL_1),
    .D2A_RATIO_CTRL (D2A_RATIO_CTRL),
    .THRESHOLD_H_spi_0 (THRESHOLD_H_0), .THRESHOLD_L_spi_0 (THRESHOLD_L_0),
    .IDAC_MANUAL_EN_spi_0 (IDAC_MANUAL_EN_0), .IDAC_MANUAL_spi_0 (IDAC_MANUAL_0),
    .IDAC_IDAC_EN_spi_0 (IDAC_IDAC_EN_0), .IPDMIRROR_ADJ_spi_0 (IPDMIRROR_ADJ_0), .IREFC_ADJ_spi_0 (IREFC_ADJ_0),
    .THRESHOLD_H_spi_1 (THRESHOLD_H_1), .THRESHOLD_L_spi_1 (THRESHOLD_L_1),
    .IDAC_MANUAL_EN_spi_1 (IDAC_MANUAL_EN_1), .IDAC_MANUAL_spi_1 (IDAC_MANUAL_1),
    .IDAC_IDAC_EN_spi_1 (IDAC_IDAC_EN_1), .IPDMIRROR_ADJ_spi_1 (IPDMIRROR_ADJ_1), .IREFC_ADJ_spi_1 (IREFC_ADJ_1),
    .IPDMIRROR_ADJ (IPDMIRROR_ADJ), .IREFC_ADJ (IREFC_ADJ),
    .LED_STABLE_CTRL_spi_0 (LED_STABLE_CTRL_0), .LED_OFF_CTRL_spi_0 (LED_OFF_CTRL_0),
    .PERIOD_CTRL_spi_0 (PERIOD_CTRL_0), .RESET_CTRL_spi_0 (RESET_CTRL_0), .OTS_CTRL_spi_0 (OTS_CTRL_0),
    .LED_STABLE_CTRL_spi_1 (LED_STABLE_CTRL_1), .LED_OFF_CTRL_spi_1 (LED_OFF_CTRL_1),
    .PERIOD_CTRL_spi_1 (PERIOD_CTRL_1), .RESET_CTRL_spi_1 (RESET_CTRL_1), .OTS_CTRL_spi_1 (OTS_CTRL_1),
    .IREF_COARSE_ON_NOT_OFF (IREF_COARSE_ON_NOT_OFF), .IREF_COARSE_NOT_ON (IREF_COARSE_NOT_ON),
    .IREF_FINE_ON_NOT_OFF (IREF_FINE_ON_NOT_OFF), .IREF_FINE_NOT_ON (IREF_FINE_NOT_ON),
    .IDAC_MAX (IDAC_MAX), .IDAC_MIN (IDAC_MIN),
    .EN (EN), .RESET (RESET), .IPD_SW (IPD_SW), .IIN_SW (IIN_SW), .LED_ON (LED_ON),
    .NIRS_PPG_INT_SEL_spi (NIRS_PPG_INT_SEL), .int_length_slct_spi (int_length_slct),
    .INT_CLR (INT_CLR), .INT (INT), .INT_IO (INT_IO),
    .IDAC_EN (IDAC_EN), .IDAC (IDAC), .DOUTC (DOUTC), .DOUTF (DOUTF), .DOUT (DOUT),
    .IREF_COARSE (IREF_COARSE), .IREF_FINE (IREF_FINE)
  );

  // clocks : clk_ppg fast, clk_sys 2 MHz model (cycle counts are what matter)
  always #5  clk_ppg = ~clk_ppg;   // period 10
  always #20 clk_sys = ~clk_sys;   // period 40 (4x slower than ppg)

  // --------------------------------------------------------------------------
  // Behavioural "analog" front-end model.
  //   On each rising edge of EN it waits a short gap, drives IREF_COARSE high
  //   for COARSE_W ppg cycles, then IREF_FINE high for FINE_W ppg cycles.
  //   (Mimics the dual-slope current-mode readout : coarse then fine.)
  // --------------------------------------------------------------------------
  localparam integer GAP     = 8;
  localparam integer COARSE_W = 40;
  localparam integer FINE_W   = 15;

  reg        en_q;
  integer    ph;        // 0 idle, 1 gap, 2 coarse, 3 gap, 4 fine
  integer    cnt;
  integer    meas_count;

  always @(posedge clk_ppg or negedge rst_n) begin
    if (!rst_n) begin
      IREF_COARSE <= 0; IREF_FINE <= 0; en_q <= 0; ph <= 0; cnt <= 0; meas_count <= 0;
    end else begin
      en_q <= EN;
      case (ph)
        0: begin
             IREF_COARSE <= 0; IREF_FINE <= 0;
             if (EN & ~en_q) begin ph <= 1; cnt <= 0; end   // EN rising
           end
        1: begin if (cnt >= GAP) begin ph <= 2; cnt <= 0; IREF_COARSE <= 1; end else cnt <= cnt + 1; end
        2: begin
             if (cnt >= COARSE_W) begin IREF_COARSE <= 0; ph <= 3; cnt <= 0; end
             else cnt <= cnt + 1;
           end
        3: begin if (cnt >= GAP) begin ph <= 4; cnt <= 0; IREF_FINE <= 1; end else cnt <= cnt + 1; end
        4: begin
             if (cnt >= FINE_W) begin IREF_FINE <= 0; ph <= 0; cnt <= 0; meas_count <= meas_count + 1; end
             else cnt <= cnt + 1;
           end
        default: ph <= 0;
      endcase
    end
  end

  // pulse activity + interrupt monitors
  integer en_pulses, led_pulses, reset_pulses, ipd_pulses;
  reg     prev_en, prev_led, prev_rst, prev_ipd;
  reg     saw_int;
  always @(posedge clk_sys) begin
    if (EN     & ~prev_en)  en_pulses    = en_pulses + 1;
    if (LED_ON & ~prev_led) led_pulses   = led_pulses + 1;
    if (RESET  & ~prev_rst) reset_pulses = reset_pulses + 1;
    if (IPD_SW & ~prev_ipd) ipd_pulses   = ipd_pulses + 1;
    prev_en=EN; prev_led=LED_ON; prev_rst=RESET; prev_ipd=IPD_SW;
  end
  always @(posedge clk_ppg) if (INT) saw_int = 1;

  task chk; input v; input [511:0] m; begin
    checks=checks+1;
    if (v!==1'b1) begin errors=errors+1; $display("  [FAIL] %0s", m); end
    else $display("  [ok]   %0s", m);
  end endtask
  task chk_gt; input integer g; input integer thr; input [511:0] m; begin
    checks=checks+1;
    if (!(g>thr)) begin errors=errors+1; $display("  [FAIL] %0s : %0d (expected > %0d)", m,g,thr); end
    else $display("  [ok]   %0s : %0d", m, g);
  end endtask

  task init_regs;
    begin
      scan_mode=0; NIRS_EN=0; NIRS_MEAS=0; MODE_SEL=6'b010000; // single LED, continuous-typ
      AVG_SEL_0=0; AVG_SEL_1=0;
      RATIO_MANUAL_0=0; RATIO_MANUAL_1=0; RATIO_CTRL_0=3'b000; RATIO_CTRL_1=3'b000; // auto 128
      THRESHOLD_H_0=19'd1000; THRESHOLD_H_1=19'd1000; THRESHOLD_L_0=8'd5; THRESHOLD_L_1=8'd5;
      IDAC_MANUAL_EN_0=0; IDAC_MANUAL_EN_1=0; IDAC_MANUAL_0=0; IDAC_MANUAL_1=0;
      IDAC_IDAC_EN_0=1; IDAC_IDAC_EN_1=1;
      IPDMIRROR_ADJ_0=0; IPDMIRROR_ADJ_1=0; IREFC_ADJ_0=0; IREFC_ADJ_1=0;
      LED_STABLE_CTRL_0=0; LED_STABLE_CTRL_1=0; LED_OFF_CTRL_0=0; LED_OFF_CTRL_1=0;
      PERIOD_CTRL_0=4'd0; PERIOD_CTRL_1=4'd0;          // 125 us
      RESET_CTRL_0=3'd0; RESET_CTRL_1=3'd0; OTS_CTRL_0=4'd2; OTS_CTRL_1=4'd2;
      NIRS_PPG_INT_SEL=8'b0000_0011;                   // DATA_READY_EN + pin enable
      int_length_slct=0; INT_CLR=0;
    end
  endtask

  task do_reset;
    begin
      rst_n=0; init_regs;
      en_pulses=0; led_pulses=0; reset_pulses=0; ipd_pulses=0; saw_int=0;
      prev_en=0; prev_led=0; prev_rst=0; prev_ipd=0;
      repeat (4) @(negedge clk_sys);
      rst_n=1;
      repeat (2) @(negedge clk_sys);
    end
  endtask

  integer prev_meas;
  reg [21:0] expect_dout;

  initial begin
    clk_ppg=0; clk_sys=0;
    $dumpfile("tb_nirs_ppg_ctrl_top.vcd");
    $dumpvars(0, tb_nirs_ppg_ctrl_top);
    $display("==== nirs_ppg_ctrl_top integration test ====");

    // ------------------------------------------------------------------
    // A) Continuous-typical measurement, auto ratio 128, AVG=0
    // ------------------------------------------------------------------
    $display("-- continuous measurement / compute path --");
    do_reset;
    NIRS_EN=1;
    // run for several 125us periods (250 sys cyc each)
    repeat (250*8) @(negedge clk_sys);

    chk_gt(en_pulses,    2, "EN pulses generated each period");
    chk_gt(led_pulses,   2, "LED_ON pulses generated each period");
    chk_gt(reset_pulses, 2, "RESET pulses generated each period");
    chk_gt(ipd_pulses,   2, "IPD_SW pulses generated each period");
    chk_gt(meas_count,   2, "analog measurements completed");
    chk_gt(DOUTC,        0, "DOUTC latched non-zero");
    chk_gt(DOUTF,        0, "DOUTF latched non-zero");

    // DOUT == 128*DOUTC - DOUTF (RATIO auto=128, AVG_SEL=0) once settled
    expect_dout = 22'd128*DOUTC - DOUTF;
    checks=checks+1;
    if (DOUT !== expect_dout) begin
      errors=errors+1;
      $display("  [FAIL] DOUT=%0d expected 128*DOUTC-DOUTF=%0d (DOUTC=%0d DOUTF=%0d)",
               DOUT, expect_dout, DOUTC, DOUTF);
    end else
      $display("  [ok]   DOUT = 128*DOUTC - DOUTF = %0d (DOUTC=%0d DOUTF=%0d)", DOUT, DOUTC, DOUTF);

    chk(saw_int, "INT raised on DATA_READY");

    // ------------------------------------------------------------------
    // B) IDAC auto loop : DOUT > THRESHOLD_H -> IDAC increments over periods
    // ------------------------------------------------------------------
    $display("-- IDAC auto hysteresis loop (increments) --");
    do_reset;
    THRESHOLD_H_0=19'd1000; THRESHOLD_L_0=8'd5;
    IDAC_MANUAL_EN_0=0; IDAC_IDAC_EN_0=1;
    NIRS_EN=1;
    repeat (250*3) @(negedge clk_sys);
    begin : idac_blk
      reg [8:0] idac_a;
      idac_a = IDAC;
      repeat (250*5) @(negedge clk_sys);
      chk_gt(IDAC, idac_a, "IDAC increased over additional periods (auto loop)");
    end

    // ------------------------------------------------------------------
    // C) IDAC manual mode : forced fixed code
    // ------------------------------------------------------------------
    $display("-- IDAC manual mode --");
    do_reset;
    IDAC_MANUAL_EN_0=1; IDAC_MANUAL_0=9'h123; IDAC_IDAC_EN_0=1;
    NIRS_EN=1;
    repeat (250*3) @(negedge clk_sys);
    checks=checks+1;
    if (IDAC !== 9'h123) begin errors=errors+1; $display("  [FAIL] manual IDAC=%h expected 0x123", IDAC); end
    else $display("  [ok]   manual IDAC forced to 0x123");

    $display("==== checks=%0d errors=%0d ====", checks, errors);
    if (errors==0) $display("RESULT: PASS"); else $display("RESULT: FAIL");
    $finish;
  end

  // safety timeout
  initial begin
    #5000000;
    $display("TIMEOUT");
    $display("RESULT: FAIL");
    $finish;
  end

endmodule
