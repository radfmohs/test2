// ============================================================================
// Standalone testbench : nirs_ppg_ctrl
// ----------------------------------------------------------------------------
// Verifies the measurement state machine that performs the coarse/fine
// quantization and produces the status flags described in README section 12
// and NIRS_DEBUG_4 / NIRS_CTRL_INT:
//   * normal sequence EN^ -> IREF_COARSE pulse -> IREF_FINE pulse -> data
//     update, asserting QC_COUNTER_EN during coarse and QF_COUNTER_EN during
//     fine, latching DOUTC/DOUTF and pulsing DOUT_EN, and finally DATA_READY.
//   * error flags raised when the EN window ends early (DONE) in a given phase:
//       IREF_COARSE_NOT_ON      - coarse never turned on
//       IREF_COARSE_ON_NOT_OFF  - coarse on but never off
//       IREF_FINE_NOT_ON        - fine never on
//       IREF_FINE_ON_NOT_OFF    - fine on but never off
//   * EN_OFF pulse on the falling edge of fine integration.
//
// Note: the flags are transient (cleared when the FSM returns to IDLE), so the
// testbench captures them with sticky monitors sampled #1 after each negedge.
// ============================================================================
`timescale 1ns/1ps

module tb_nirs_ppg_ctrl;

  reg  rst_n, clk;
  reg  EN, IREF_COARSE, IREF_FINE;
  wire IREF_COARSE_ON_NOT_OFF, IREF_COARSE_NOT_ON;
  wire IREF_FINE_ON_NOT_OFF, IREF_FINE_NOT_ON, DATA_READY;
  wire EN_OFF, IDAC_INCREASE, IDAC_UPDATE_EN;
  wire QC_COUNTER_EN, QF_COUNTER_EN, COUNTERS_CLEAR;
  wire DOUTC_LATCH_EN, DOUTF_LATCH_EN, DOUT_EN;

  integer errors = 0;
  integer checks = 0;

  // sticky monitors
  reg mon_en;
  reg saw_dr, saw_enoff;
  reg saw_cna, saw_cono, saw_fna, saw_fono;   // coarse_not_on, coarse_on_not_off, fine_not_on, fine_on_not_off
  reg qc_seen, qf_seen;
  integer doutc_pulses, doutf_pulses, douten_pulses, idacupd_pulses, cclr_pulses;

  nirs_ppg_ctrl dut (
    .rst_n (rst_n), .clk (clk),
    .EN (EN), .IREF_COARSE (IREF_COARSE), .IREF_FINE (IREF_FINE),
    .IREF_COARSE_ON_NOT_OFF (IREF_COARSE_ON_NOT_OFF),
    .IREF_COARSE_NOT_ON     (IREF_COARSE_NOT_ON),
    .IREF_FINE_ON_NOT_OFF   (IREF_FINE_ON_NOT_OFF),
    .IREF_FINE_NOT_ON       (IREF_FINE_NOT_ON),
    .DATA_READY             (DATA_READY),
    .EN_OFF (EN_OFF), .IDAC_INCREASE (IDAC_INCREASE), .IDAC_UPDATE_EN (IDAC_UPDATE_EN),
    .QC_COUNTER_EN (QC_COUNTER_EN), .QF_COUNTER_EN (QF_COUNTER_EN),
    .COUNTERS_CLEAR (COUNTERS_CLEAR),
    .DOUTC_LATCH_EN (DOUTC_LATCH_EN), .DOUTF_LATCH_EN (DOUTF_LATCH_EN),
    .DOUT_EN (DOUT_EN)
  );

  always #5 clk = ~clk;

  // sample 1ns after negedge so stimulus (applied on negedge) has settled and
  // combinational transition strobes are observable
  always @(negedge clk) begin
    #1;
    if (mon_en) begin
      if (DATA_READY)             saw_dr   = 1;
      if (EN_OFF)                 saw_enoff= 1;
      if (IREF_COARSE_NOT_ON)     saw_cna  = 1;
      if (IREF_COARSE_ON_NOT_OFF) saw_cono = 1;
      if (IREF_FINE_NOT_ON)       saw_fna  = 1;
      if (IREF_FINE_ON_NOT_OFF)   saw_fono = 1;
      if (QC_COUNTER_EN)          qc_seen  = 1;
      if (QF_COUNTER_EN)          qf_seen  = 1;
      if (DOUTC_LATCH_EN) doutc_pulses  = doutc_pulses + 1;
      if (DOUTF_LATCH_EN) doutf_pulses  = doutf_pulses + 1;
      if (DOUT_EN)        douten_pulses = douten_pulses + 1;
      if (IDAC_UPDATE_EN) idacupd_pulses= idacupd_pulses + 1;
      if (COUNTERS_CLEAR) cclr_pulses   = cclr_pulses + 1;
    end
  end

  task clr_mon;
    begin
      saw_dr=0; saw_enoff=0; saw_cna=0; saw_cono=0; saw_fna=0; saw_fono=0;
      qc_seen=0; qf_seen=0;
      doutc_pulses=0; doutf_pulses=0; douten_pulses=0; idacupd_pulses=0; cclr_pulses=0;
    end
  endtask

  task do_reset;
    begin
      rst_n=0; EN=0; IREF_COARSE=0; IREF_FINE=0; mon_en=0; clr_mon;
      @(negedge clk); @(negedge clk);
      rst_n=1; @(negedge clk);
    end
  endtask

  task tick; begin @(negedge clk); end endtask
  task ticks; input integer n; integer k; begin for(k=0;k<n;k=k+1) @(negedge clk); end endtask

  task chk; input v; input [511:0] m; begin
    checks=checks+1;
    if (v!==1'b1) begin errors=errors+1; $display("  [FAIL] %0s", m); end
    else $display("  [ok]   %0s", m);
  end endtask
  task chk0; input v; input [511:0] m; begin
    checks=checks+1;
    if (v!==1'b0) begin errors=errors+1; $display("  [FAIL] %0s (expected 0)", m); end
    else $display("  [ok]   %0s (==0)", m);
  end endtask
  task chk_eq; input integer g; input integer e; input [511:0] m; begin
    checks=checks+1;
    if (g!==e) begin errors=errors+1; $display("  [FAIL] %0s got=%0d exp=%0d", m,g,e); end
    else $display("  [ok]   %0s = %0d", m,g);
  end endtask

  initial begin
    clk=0;
    $dumpfile("tb_nirs_ppg_ctrl.vcd");
    $dumpvars(0, tb_nirs_ppg_ctrl);
    $display("==== nirs_ppg_ctrl standalone test ====");

    // ------------------------------------------------------------------
    // 1) Clean measurement
    // ------------------------------------------------------------------
    $display("-- clean coarse+fine measurement --");
    do_reset; clr_mon; mon_en=1;
    EN=1; tick;                         // START
    IREF_COARSE=1; ticks(6);            // coarse integration window
    IREF_COARSE=0; ticks(2);            // coarse done -> COARSE_LATCHED
    IREF_FINE=1;   ticks(4);            // fine integration window
    IREF_FINE=0;   ticks(2);            // fine done -> DATA_UPDATE
    ticks(3);                           // DATA_UPDATE -> IDLE, flags settle
    EN=0; ticks(3);
    mon_en=0;
    chk (qc_seen,  "QC_COUNTER_EN asserted during coarse");
    chk (qf_seen,  "QF_COUNTER_EN asserted during fine");
    chk (saw_dr,   "DATA_READY asserted on clean measurement");
    chk0(saw_cna|saw_cono|saw_fna|saw_fono, "no error flags on clean measurement");
    chk (saw_enoff,"EN_OFF pulse on fine falling edge");
    chk_eq(doutc_pulses, 1, "DOUTC latched once");
    chk_eq(doutf_pulses, 1, "DOUTF latched once");
    chk_eq(douten_pulses,1, "DOUT_EN pulsed once");
    chk_eq(idacupd_pulses,1,"IDAC_UPDATE_EN pulsed once");
    chk_eq(cclr_pulses,  1, "COUNTERS_CLEAR pulsed once");

    // ------------------------------------------------------------------
    // 2) COARSE_NOT_ON : EN window ends while still in WAIT (no coarse)
    // ------------------------------------------------------------------
    $display("-- error flag: IREF_COARSE_NOT_ON --");
    do_reset; clr_mon; mon_en=1;
    EN=1; ticks(3);                     // WAIT, no coarse
    EN=0; ticks(4);                     // DONE in WAIT
    ticks(3); mon_en=0;
    chk (saw_cna,  "IREF_COARSE_NOT_ON captured");
    chk0(saw_dr,   "DATA_READY not set on faulty measurement");

    // ------------------------------------------------------------------
    // 3) COARSE_ON_NOT_OFF : coarse goes high then EN ends while still high
    // ------------------------------------------------------------------
    $display("-- error flag: IREF_COARSE_ON_NOT_OFF --");
    do_reset; clr_mon; mon_en=1;
    EN=1; tick;
    IREF_COARSE=1; ticks(3);            // in COARSE_LATCHING, coarse still high
    EN=0; ticks(4);                     // DONE while coarse high
    IREF_COARSE=0; ticks(3); mon_en=0;
    chk (saw_cono, "IREF_COARSE_ON_NOT_OFF captured");

    // ------------------------------------------------------------------
    // 4) FINE_NOT_ON : coarse completes, EN ends before fine
    // ------------------------------------------------------------------
    $display("-- error flag: IREF_FINE_NOT_ON --");
    do_reset; clr_mon; mon_en=1;
    EN=1; tick;
    IREF_COARSE=1; ticks(3);
    IREF_COARSE=0; ticks(2);            // COARSE_LATCHED
    EN=0; ticks(4);                     // DONE before fine
    ticks(3); mon_en=0;
    chk (saw_fna,  "IREF_FINE_NOT_ON captured");

    // ------------------------------------------------------------------
    // 5) FINE_ON_NOT_OFF : fine high then EN ends while still high
    // ------------------------------------------------------------------
    $display("-- error flag: IREF_FINE_ON_NOT_OFF --");
    do_reset; clr_mon; mon_en=1;
    EN=1; tick;
    IREF_COARSE=1; ticks(3);
    IREF_COARSE=0; ticks(2);
    IREF_FINE=1;   ticks(3);            // FINE_LATCHING, fine still high
    EN=0; ticks(4);                     // DONE while fine high
    IREF_FINE=0; ticks(3); mon_en=0;
    chk (saw_fono, "IREF_FINE_ON_NOT_OFF captured");

    $display("==== checks=%0d errors=%0d ====", checks, errors);
    if (errors==0) $display("RESULT: PASS"); else $display("RESULT: FAIL");
    $finish;
  end

endmodule
