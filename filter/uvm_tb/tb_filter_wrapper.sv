// ============================================================================
// tb_filter_wrapper.sv – Comprehensive testbench for filter_wrapper
//
// Design intent (per README section 14.7 and new requirement)
// -----------------------------------------------------------
//   The filter_wrapper manages ALL inter-filter timing internally through
//   its own handshaking signals.  This testbench NEVER manually counts
//   pipeline stages; instead it:
//     1. Drives  chdata_en  (rising edge = "new sample ready")  and
//                imeas_chdata_in  (the sample value)
//     2. Waits for the wrapper's own  meas_done  pulse on pclk, which the
//        wrapper asserts only after all active filters have completed their
//        sequential processing (LPF → Notch → HPF).
//     3. Reads  imeas_chdata_out  immediately after meas_done.
//
// Filter chain sequence (hardcoded in filter_wrapper.sv, documented in README)
// ---------------------------------------------------------------------------
//   Input → LPF (32 cycles) → Notch (42 cycles) → HPF (1 cycle) → Output
//   Total pipeline depth: ≥ 75 clock cycles when all three are active.
//   Shorter (or zero) when individual filters are bypassed.
//
// Configuration
// -------------
//   CHN_NUM = 1  (single channel, simplest valid wrapper instance)
//   All clocks = same 100 MHz source.  pclk = same source.
//   Clock gating uses common_clock_gate with `define FPGA (latch-based model).
//   cic_data_ignore_tar = 0  so cic_data_ok stays true (counter never advances).
//   eeg_int_en = 2'b00  (we don't test the interrupt output here).
//
// Coefficients used
// -----------------
//   LPF (Set A from README 14.7.6 defaults, fpass=Fs/8, fstop=Fs/4):
//     32 18-bit sfix18_En20 coefficients (symmetric FIR)
//   Notch (Set B from tb_notch.sv: notch at 0.10*Fs, r=0.90):
//     Section 1 active notch; sections 2-7 identity passthrough
//   HPF: coeff = 24'h6E7E54  (Fc ≈ 0.05 * Fs, a ≈ -0.727, pole = +0.727)
//     tau ≈ 3.7 samples → Nskip=20 is generous
//
// Timing verification (README 14.7 – "Filter Chain Sequence and Timing")
// -----------------------------------------------------------------------
//   We measure the number of clock cycles between the first chdata_en
//   rising edge and the corresponding meas_done pulse for each bypass
//   configuration.  Expected order:
//     all bypass  <<  HPF only  <  LPF only  ≈  Notch only  <<  all active
//   No hard cycle-count thresholds are asserted because the exact count
//   depends on where in the LPF/Notch serial-MAC cycle the enable fires.
//   What is asserted: the ordering between configurations is correct.
//
// Scenarios
// ---------
//   1.  Reset: imeas_chdata_out == 0 while reset is asserted
//   2.  All bypass: output == input, meas_done fires quickly (< 30 cycles)
//   3.  HPF only: meas_done fires; stopband attenuated, passband passes
//   4.  LPF only: meas_done fires; passband passes, stopband attenuated;
//                 timing longer than all-bypass
//   5.  Notch only: meas_done fires; notch freq attenuated, others pass;
//                   timing longer than all-bypass
//   6.  All active – frequency response:
//       f=0.05*Fs passes all (above HPF cut, not at notch, below LPF stop)
//       f=0.10*Fs attenuated by notch
//       f=0.30*Fs attenuated by LPF
//       f=0.01*Fs attenuated by HPF
//   7.  All active – timing: longer than any individual filter alone
//   8.  Pipeline sequence correctness: a signal that passes LPF but is at
//       the notch freq is attenuated (verifies LPF→Notch order is correct)
//   9.  Sign_en=0 bypass: unsigned input passes through unchanged
//  10.  Sign_en=0 all active: unsigned notch input is attenuated
//  11.  All filters bypass per-channel register: LPF_BP=0 (enable) vs 1 (bypass)
//  12.  notch_filter_valid reflects bypass state
//  13.  Reset during active pipeline: output clears immediately
// ============================================================================
`define FPGA
`timescale 1ns/1ps

// ============================================================================
// Top module
// ============================================================================
module tb_filter_wrapper;

  // -------------------------------------------------------------------------
  // Parameters
  // -------------------------------------------------------------------------
  localparam CHN      = 1;
  localparam DW       = 32;
  localparam CLK_HALF = 5;          // 100 MHz
  localparam real PI  = 3.14159265358979;
  localparam real UNSIGNED_DC_BIAS = 2147483648.0;
  // Pipeline timing constants for verification (soft, relative)
  localparam TIMEOUT_CYCLES = 300;  // generous: ≥ 75 + all overhead

  // -------------------------------------------------------------------------
  // Clock and reset
  // -------------------------------------------------------------------------
  reg  clk_src;
  wire clk_w;
  assign clk_w = clk_src;
  initial clk_src = 0;
  always #CLK_HALF clk_src = ~clk_src;

  reg reset;   // active-LOW in wrapper

  // -------------------------------------------------------------------------
  // Wrapper inputs
  // -------------------------------------------------------------------------
  reg        sign_en;
  reg  [3:0] osr_sel;
  reg  [3:0] iclk_div;
  reg        int_length_slct;
  reg  [1:0] eeg_int_en;
  reg        eeg_int_clr;
  reg [15:0] cic_data_ignore_tar;
  reg [23:0] hpf_coeff_data;
  reg signed [17:0] lpf_coeff_data [0:31];
  reg signed [19:0] notch_coeff_data [0:41];

  reg  [CHN-1:0] notch_filter_bypass;
  reg  [CHN-1:0] lpf_filter_bypass;
  reg  [CHN-1:0] hpf_filter_bypass;

  reg  [DW-1:0] imeas_chdata_in [0:CHN-1];
  reg  [CHN-1:0] chdata_en;
  reg            i_imeas_intr_clr;

  // -------------------------------------------------------------------------
  // Wrapper outputs
  // -------------------------------------------------------------------------
  wire [CHN-1:0] notch_clk_gtg_en;
  wire [CHN-1:0] lpf_clk_gtg_en;
  wire [CHN-1:0] hpf_clk_gtg_en;
  wire           notch_filter_valid;
  wire           o_eeg_int;
  wire           eeg_int_sts;
  wire           meas_done_d1;
  wire [DW-1:0]  imeas_chdata_out [0:CHN-1];

  // -------------------------------------------------------------------------
  // Clock gates (one per filter, exactly as in tb_top.sv)
  // -------------------------------------------------------------------------
  wire notch_clk_w, lpf_clk_w, hpf_clk_w;

  common_clock_gate u_notch_clk_gate (
    .clk       (clk_src),
    .enable    (notch_clk_gtg_en[0]),
    .bypass    (1'b0),
    .gated_clk (notch_clk_w)
  );
  common_clock_gate u_lpf_clk_gate (
    .clk       (clk_src),
    .enable    (lpf_clk_gtg_en[0]),
    .bypass    (1'b0),
    .gated_clk (lpf_clk_w)
  );
  common_clock_gate u_hpf_clk_gate (
    .clk       (clk_src),
    .enable    (hpf_clk_gtg_en[0]),
    .bypass    (1'b0),
    .gated_clk (hpf_clk_w)
  );

  // -------------------------------------------------------------------------
  // DUT – filter_wrapper (single channel)
  // -------------------------------------------------------------------------
  filter_wrapper #(
    .DATA_WIDTH (DW),
    .CHN_NUM    (CHN)
  ) dut (
    .clk                 ({CHN{clk_src}}),
    .notch_clk           (notch_clk_w),
    .lpf_clk             (lpf_clk_w),
    .hpf_clk             (hpf_clk_w),
    .pclk                (clk_src),
    .reset               (reset),
    .sign_en             (sign_en),
    .scan_mode           (1'b0),
    .osr_sel             (osr_sel),
    .iclk_div            (iclk_div),
    .int_length_slct     (int_length_slct),
    .eeg_int_en          (eeg_int_en),
    .eeg_int_clr         (eeg_int_clr),
    .cic_data_ignore_tar (cic_data_ignore_tar),
    .hpf_coeff_data      (hpf_coeff_data),
    .lpf_coeff_data      (lpf_coeff_data),
    .notch_coeff_data    (notch_coeff_data),
    .notch_filter_bypass (notch_filter_bypass),
    .lpf_filter_bypass   (lpf_filter_bypass),
    .hpf_filter_bypass   (hpf_filter_bypass),
    .imeas_chdata_in     (imeas_chdata_in),
    .chdata_en           (chdata_en),
    .i_imeas_intr_clr    (i_imeas_intr_clr),
    .notch_clk_gtg_en    (notch_clk_gtg_en),
    .lpf_clk_gtg_en      (lpf_clk_gtg_en),
    .hpf_clk_gtg_en      (hpf_clk_gtg_en),
    .notch_filter_valid  (notch_filter_valid),
    .o_eeg_int           (o_eeg_int),
    .eeg_int_sts         (eeg_int_sts),
    .meas_done_d1        (meas_done_d1),
    .imeas_chdata_out    (imeas_chdata_out)
  );

  // meas_done internal wire (|filter_chdata_en on pclk)
  wire meas_done = dut.meas_done;

  // =========================================================================
  // Pass / fail counters
  // =========================================================================
  integer pass_cnt;
  integer fail_cnt;

  task automatic chk_flag;
    input string  lbl;
    input integer ok;
    begin
      if (ok) begin
        $display("  [PASS] %s", lbl);
        pass_cnt = pass_cnt + 1;
      end else begin
        $display("  [FAIL] %s", lbl);
        fail_cnt = fail_cnt + 1;
      end
    end
  endtask

  task automatic chk_ratio;
    input string  lbl;
    input integer ok;
    input real    r;
    real db;
    begin
      db = (r > 1.0e-9) ? 20.0 * $log10(r) : -180.0;
      if (ok) begin
        $display("  [PASS] %-60s ratio=%7.4f (%7.1f dB)", lbl, r, db);
        pass_cnt = pass_cnt + 1;
      end else begin
        $display("  [FAIL] %-60s ratio=%7.4f (%7.1f dB)", lbl, r, db);
        fail_cnt = fail_cnt + 1;
      end
    end
  endtask

  // =========================================================================
  // Coefficient loaders
  // =========================================================================

  // LPF Set A: README 14.7.6 defaults (fpass=Fs/8, fstop=Fs/4)
  // 18-bit sfix18_En20 symmetric 32-tap FIR
  task automatic load_lpf_setA;
    integer j;
    begin
      // Symmetric: coeff[0]==coeff[31], coeff[1]==coeff[30], etc.
      lpf_coeff_data[ 0] = 18'h3FFF8;  lpf_coeff_data[31] = 18'h3FFF8;
      lpf_coeff_data[ 1] = 18'h00078;  lpf_coeff_data[30] = 18'h00078;
      lpf_coeff_data[ 2] = 18'h00204;  lpf_coeff_data[29] = 18'h00204;
      lpf_coeff_data[ 3] = 18'h00344;  lpf_coeff_data[28] = 18'h00344;
      lpf_coeff_data[ 4] = 18'h000B6;  lpf_coeff_data[27] = 18'h000B6;
      lpf_coeff_data[ 5] = 18'h3F993;  lpf_coeff_data[26] = 18'h3F993;
      lpf_coeff_data[ 6] = 18'h3F56D;  lpf_coeff_data[25] = 18'h3F56D;
      lpf_coeff_data[ 7] = 18'h3FF18;  lpf_coeff_data[24] = 18'h3FF18;
      lpf_coeff_data[ 8] = 18'h0138B;  lpf_coeff_data[23] = 18'h0138B;
      lpf_coeff_data[ 9] = 18'h019E8;  lpf_coeff_data[22] = 18'h019E8;
      lpf_coeff_data[10] = 18'h3FB13;  lpf_coeff_data[21] = 18'h3FB13;
      lpf_coeff_data[11] = 18'h3C991;  lpf_coeff_data[20] = 18'h3C991;
      lpf_coeff_data[12] = 18'h3C655;  lpf_coeff_data[19] = 18'h3C655;
      lpf_coeff_data[13] = 18'h027A9;  lpf_coeff_data[18] = 18'h027A9;
      lpf_coeff_data[14] = 18'h0D28B;  lpf_coeff_data[17] = 18'h0D28B;
      lpf_coeff_data[15] = 18'h15A8B;  lpf_coeff_data[16] = 18'h15A8B;
    end
  endtask

  // Notch Set B (from tb_notch.sv): notch at 0.10*Fs, r=0.90
  // Section 1 active; sections 2-7 identity (passthrough)
  task automatic load_notch_setB;
    integer j;
    begin
      notch_coeff_data[ 0] = 20'h3B45D;  // scaleconst1 = 0.926 (unity DC gain)
      notch_coeff_data[ 1] = 20'h40000;  // b1 = +1.0
      notch_coeff_data[ 2] = 20'h987A0;  // b2 = -1.618 (2s-comp)
      notch_coeff_data[ 3] = 20'h40000;  // b3 = +1.0
      notch_coeff_data[ 4] = 20'hA2CFE;  // a2 = -1.456 (2s-comp)
      notch_coeff_data[ 5] = 20'h33D71;  // a3 = +0.810
      for (j = 1; j <= 6; j = j + 1) begin
        notch_coeff_data[6*j + 0] = 20'h40000;
        notch_coeff_data[6*j + 1] = 20'h40000;
        notch_coeff_data[6*j + 2] = 20'h00000;
        notch_coeff_data[6*j + 3] = 20'h00000;
        notch_coeff_data[6*j + 4] = 20'h00000;
        notch_coeff_data[6*j + 5] = 20'h00000;
      end
    end
  endtask

  // HPF: Fc ≈ 0.05 * Fs
  //   K = tan(pi*0.05) = 0.15838, a = (K-1)/(K+1) = -0.7267
  //   b0 = (1-a)/2 = 0.8633, R = round(b0 * 2^23) = 7241300 = 0x6E7E54
  task automatic load_hpf_fc005;
    begin
      hpf_coeff_data = 24'h6E7E54;
    end
  endtask

  // =========================================================================
  // Reset helper
  // =========================================================================
  task automatic do_reset;
    begin
      reset      = 1'b0;
      chdata_en  = {CHN{1'b0}};
      sign_en    = 1'b1;
      imeas_chdata_in[0] = 32'h0;
      repeat (20) @(posedge clk_src);
      #1;
      reset = 1'b1;
      repeat (5) @(posedge clk_src);
      #1;
    end
  endtask

  // =========================================================================
  // Core pipeline task
  // =========================================================================
  // Send one sample through the wrapper pipeline and wait for the wrapper's
  // own meas_done signal (not a manual cycle count).
  // Returns: the filtered output value and how many cycles meas_done took.
  //
  // The TB drives:
  //   1. imeas_chdata_in[0] = sample_in  (held stable throughout)
  //   2. chdata_en[0] = 1 for one clock cycle  (rising edge triggers LPF)
  //   3. Wait for wrapper-generated meas_done on pclk (TIMEOUT_CYCLES limit)
  //   4. Read imeas_chdata_out[0]
  //
  // This correctly exercises the wrapper's internal LPF→Notch→HPF handshaking.
  //
  // Timing note: the #1 inside the loop ensures we sample meas_done *after*
  // the posedge propagates through all combinational logic (Verilator timing).
  // =========================================================================
  task automatic send_and_receive;
    input  signed [31:0] sample_in;
    output signed [31:0] sample_out;
    output integer       cycles_taken;
    integer cnt;
    reg     found;
    begin
      // Hold input stable
      imeas_chdata_in[0] = sample_in;
      // Wait for a clean posedge before pulsing
      @(posedge clk_src); #1;
      // Rising edge on chdata_en (wrapper detects this via common_pulse_rising)
      chdata_en[0] = 1'b1;
      @(posedge clk_src); #1;
      chdata_en[0] = 1'b0;
      // Count cycles until meas_done fires (wrapper's own timing signal).
      // The #1 after each posedge ensures combinational signals (including
      // meas_done = |filter_chdata_en) have settled before we sample them.
      found = 0;
      cnt   = 0;
      while (!found && cnt < TIMEOUT_CYCLES) begin
        @(posedge clk_src); #1;
        cnt = cnt + 1;
        if (meas_done) found = 1;
      end
      // We are now 1ps after the posedge where meas_done fired;
      // imeas_chdata_out is valid and stable.
      sample_out   = imeas_chdata_out[0];
      cycles_taken = cnt;
    end
  endtask

  // =========================================================================
  // Frequency-response measurement
  // Sends Ntotal sine-wave samples one at a time through send_and_receive.
  // Skips the first Nskip outputs (pipeline settling).
  // Returns the peak-to-peak amplitude ratio (output / input).
  //
  // Note: because each sample requires its own meas_done handshake, this
  // correctly tests that the wrapper handles back-to-back samples.
  // =========================================================================
  task automatic run_sine_and_measure;
    input  real    freq_norm;
    input  real    ampl_frac;
    input  integer Ntotal;
    input  integer Nskip;
    output real    ampl_ratio;
    real    in_peak, theta, cur_out;
    real    out_max, out_min;
    integer k, in_int, cyc;
    reg  signed [31:0] sout;
    reg  [31:0] fo_bits;
    begin
      in_peak = ampl_frac * 268435456.0; // 2^28
      out_max = -1.0e30;
      out_min =  1.0e30;

      for (k = 0; k < Ntotal; k = k + 1) begin
        theta  = 2.0 * PI * freq_norm * real'(k);
        in_int = $rtoi(in_peak * $sin(theta));
        if (sign_en)
          send_and_receive(in_int, sout, cyc);
        else
          send_and_receive(in_int + 32'h8000_0000, sout, cyc);

        if (k >= Nskip) begin
          fo_bits = sout;
          if (sign_en) begin
            cur_out = $itor($signed(fo_bits));
          end else begin
            if (fo_bits[31] == 1'b1)
              cur_out =  $itor(fo_bits[30:0]);
            else
              cur_out =  $itor(fo_bits[30:0]) - UNSIGNED_DC_BIAS;
          end
          if (cur_out > out_max) out_max = cur_out;
          if (cur_out < out_min) out_min = cur_out;
        end
      end

      if (out_max > -1.0e29)
        ampl_ratio = (out_max - out_min) / 2.0 / in_peak;
      else
        ampl_ratio = 0.0;
    end
  endtask

  // =========================================================================
  // MAIN TEST SEQUENCE
  // =========================================================================
  real ratio, ratio_lpf, ratio_notch, ratio_hpf, ratio_all;
  real ratio_b;
  integer cycles_bypass, cycles_hpf, cycles_lpf, cycles_notch, cycles_all;
  reg  signed [31:0] sout;
  integer cyc, j;

  initial begin : main

    // ----- initialise -----
    pass_cnt           = 0;
    fail_cnt           = 0;
    sign_en            = 1'b1;
    osr_sel            = 4'h4;   // data rate valid for notch (osr_sel 2..11)
    iclk_div           = 4'h0;
    int_length_slct    = 1'b0;
    eeg_int_en         = 2'b00;
    eeg_int_clr        = 1'b0;
    cic_data_ignore_tar = 16'h0000; // cic_data_ok stays true (counter target=0)
    i_imeas_intr_clr   = 1'b0;
    notch_filter_bypass = {CHN{1'b1}};
    lpf_filter_bypass   = {CHN{1'b1}};
    hpf_filter_bypass   = {CHN{1'b1}};
    chdata_en           = {CHN{1'b0}};
    imeas_chdata_in[0]  = 32'h0;

    load_lpf_setA;
    load_notch_setB;
    load_hpf_fc005;

    $display("");
    $display("================================================================");
    $display(" tb_filter_wrapper: filter_wrapper Comprehensive Testbench");
    $display("  Chain (README 14.7): Input → LPF(32 cyc) → Notch(42 cyc) → HPF(1 cyc) → Output");
    $display("  TB drives chdata_en; waits for wrapper's own meas_done signal.");
    $display("  CHN=1 | CLK=100 MHz | pclk=clk | cic_data_ok always true");
    $display("  LPF: Set A (fpass=0.125*Fs, fstop=0.250*Fs)");
    $display("  Notch: Set B (notch at 0.10*Fs, r=0.90)");
    $display("  HPF: Fc=0.05*Fs (a=-0.727, pole=+0.727)");
    $display("================================================================");
    $display("");

    // -----------------------------------------------------------------------
    // Sc 1: Reset – imeas_chdata_out must be 0 while reset is asserted
    // -----------------------------------------------------------------------
    $display("--- Sc 1: Reset (active-low) ---");
    load_lpf_setA; load_notch_setB; load_hpf_fc005;
    reset   = 1'b0;
    sign_en = 1'b1;
    notch_filter_bypass = {CHN{1'b0}};
    lpf_filter_bypass   = {CHN{1'b0}};
    hpf_filter_bypass   = {CHN{1'b0}};
    imeas_chdata_in[0]  = 32'h5A5A_5A5A;
    repeat (10) @(posedge clk_src);
    chk_flag("reset=0: imeas_chdata_out==0",
             imeas_chdata_out[0] === 32'h0);

    // -----------------------------------------------------------------------
    // Sc 2: All bypass – output = input, meas_done fires quickly
    // -----------------------------------------------------------------------
    $display("\n--- Sc 2: All bypass - output = input ---");
    load_lpf_setA; load_notch_setB; load_hpf_fc005;
    do_reset;
    sign_en             = 1'b1;
    notch_filter_bypass = {CHN{1'b1}};
    lpf_filter_bypass   = {CHN{1'b1}};
    hpf_filter_bypass   = {CHN{1'b1}};

    send_and_receive(32'h1234_5678, sout, cycles_bypass);
    chk_flag("All bypass: output == input (0x12345678)",
             sout === 32'h1234_5678);
    chk_flag("All bypass: meas_done within 30 cycles",
             cycles_bypass < 30);
    $display("    (all-bypass latency: %0d cycles)", cycles_bypass);

    send_and_receive(32'h7FFF_FFFF, sout, cyc);
    chk_flag("All bypass: max positive passes unchanged",
             sout === 32'h7FFF_FFFF);

    send_and_receive(32'hDEAD_BEEF, sout, cyc);
    chk_flag("All bypass: 0xDEADBEEF passes unchanged",
             sout === 32'hDEAD_BEEF);

    // -----------------------------------------------------------------------
    // Sc 3: HPF only (LPF+notch bypass)
    //   HPF Fc=0.05*Fs: f=0.01 attenuated, f=0.30 passes
    //   Pipeline: only HPF active (1 cycle) so timing is short
    // -----------------------------------------------------------------------
    $display("\n--- Sc 3: HPF only (LPF+notch bypassed) ---");
    load_lpf_setA; load_notch_setB; load_hpf_fc005;
    do_reset;
    sign_en             = 1'b1;
    notch_filter_bypass = {CHN{1'b1}};
    lpf_filter_bypass   = {CHN{1'b1}};
    hpf_filter_bypass   = {CHN{1'b0}};   // HPF active

    run_sine_and_measure(0.010, 0.4, 100, 20, ratio);
    chk_ratio("HPF only: f=0.010 in stopband", ratio < 0.30, ratio);

    run_sine_and_measure(0.300, 0.4, 100, 20, ratio);
    chk_ratio("HPF only: f=0.300 in passband", ratio > 0.70, ratio);

    // Capture timing for ordering test in Sc 7
    send_and_receive(32'h0100_0000, sout, cycles_hpf);
    $display("    (HPF-only latency: %0d cycles)", cycles_hpf);

    // -----------------------------------------------------------------------
    // Sc 4: LPF only (notch+HPF bypass)
    //   LPF fpass=0.125*Fs, fstop=0.250*Fs: f=0.05 passes, f=0.35 attenuated
    //   Pipeline: only LPF active (32 cycles) so timing > HPF
    // -----------------------------------------------------------------------
    $display("\n--- Sc 4: LPF only (notch+HPF bypassed) ---");
    load_lpf_setA; load_notch_setB; load_hpf_fc005;
    do_reset;
    sign_en             = 1'b1;
    notch_filter_bypass = {CHN{1'b1}};
    lpf_filter_bypass   = {CHN{1'b0}};   // LPF active
    hpf_filter_bypass   = {CHN{1'b1}};

    run_sine_and_measure(0.050, 0.4, 120, 20, ratio);
    chk_ratio("LPF only: f=0.050 in passband", ratio > 0.70, ratio);

    run_sine_and_measure(0.350, 0.4, 120, 20, ratio);
    chk_ratio("LPF only: f=0.350 in stopband", ratio < 0.02, ratio);

    // Capture timing for ordering test in Sc 7
    send_and_receive(32'h0100_0000, sout, cycles_lpf);
    $display("    (LPF-only latency: %0d cycles)", cycles_lpf);

    // -----------------------------------------------------------------------
    // Sc 5: Notch only (LPF+HPF bypass)
    //   Notch at 0.10*Fs, r=0.90: f=0.10 attenuated, f=0.05 passes
    //   Pipeline: only Notch active (42 cycles) so timing > HPF
    // -----------------------------------------------------------------------
    $display("\n--- Sc 5: Notch only (LPF+HPF bypassed) ---");
    load_lpf_setA; load_notch_setB; load_hpf_fc005;
    do_reset;
    sign_en             = 1'b1;
    notch_filter_bypass = {CHN{1'b0}};   // Notch active
    lpf_filter_bypass   = {CHN{1'b1}};
    hpf_filter_bypass   = {CHN{1'b1}};

    run_sine_and_measure(0.050, 0.4, 120, 20, ratio);
    chk_ratio("Notch only: f=0.050 passband", ratio > 0.70, ratio);

    run_sine_and_measure(0.100, 0.4, 120, 20, ratio);
    chk_ratio("Notch only: f=0.100 at notch", ratio < 0.05, ratio);

    // Capture timing for ordering test in Sc 7
    send_and_receive(32'h0100_0000, sout, cycles_notch);
    $display("    (Notch-only latency: %0d cycles)", cycles_notch);

    // -----------------------------------------------------------------------
    // Sc 6: All active – frequency response through full LPF→Notch→HPF chain
    //   f=0.05*Fs: above HPF cut(0.05), not notch(0.10), below LPF stop(0.25)
    //              → should PASS all three filters
    //   f=0.10*Fs: notch frequency → ATTENUATED by notch
    //   f=0.30*Fs: above LPF stopband → ATTENUATED by LPF
    //   f=0.01*Fs: below HPF cutoff  → ATTENUATED by HPF
    // -----------------------------------------------------------------------
    $display("\n--- Sc 6: All active - full LPF->Notch->HPF chain ---");
    load_lpf_setA; load_notch_setB; load_hpf_fc005;
    do_reset;
    sign_en             = 1'b1;
    notch_filter_bypass = {CHN{1'b0}};
    lpf_filter_bypass   = {CHN{1'b0}};
    hpf_filter_bypass   = {CHN{1'b0}};

    // f=0.05: passes all (above HPF cut, not at notch, below LPF stop)
    run_sine_and_measure(0.050, 0.4, 120, 20, ratio_all);
    chk_ratio("All active: f=0.050 passes (above HPF cut, below LPF stop)",
              ratio_all > 0.40, ratio_all);

    // f=0.10: notch frequency – removed by notch stage
    run_sine_and_measure(0.100, 0.4, 120, 20, ratio);
    chk_ratio("All active: f=0.100 attenuated by notch",
              ratio < 0.05, ratio);

    // f=0.30: above LPF stopband – removed by LPF stage
    run_sine_and_measure(0.300, 0.4, 120, 20, ratio);
    chk_ratio("All active: f=0.300 attenuated by LPF",
              ratio < 0.02, ratio);

    // f=0.01: below HPF cutoff – removed by HPF stage
    run_sine_and_measure(0.010, 0.4, 120, 20, ratio);
    chk_ratio("All active: f=0.010 attenuated by HPF",
              ratio < 0.30, ratio);

    // Capture timing for ordering test in Sc 7
    send_and_receive(32'h0100_0000, sout, cycles_all);
    $display("    (All-active latency: %0d cycles)", cycles_all);

    // -----------------------------------------------------------------------
    // Sc 7: Pipeline timing ordering verification (README 14.7 timing table)
    //   The wrapper's internal handshaking must make more filters active
    //   always take at least as long as fewer:
    //     all bypass < HPF-only < LPF-only, Notch-only < All active
    //   This tests that the wrapper correctly sequences each stage before
    //   the next starts (the whole point of its inter-filter handshaking).
    // -----------------------------------------------------------------------
    $display("\n--- Sc 7: Wrapper pipeline timing ordering ---");
    $display("    Bypass=%0d  HPF-only=%0d  LPF-only=%0d  Notch-only=%0d  All=%0d cycles",
             cycles_bypass, cycles_hpf, cycles_lpf, cycles_notch, cycles_all);

    chk_flag("Timing: all-bypass < HPF-only < all-active",
             (cycles_bypass < cycles_hpf) && (cycles_hpf < cycles_all));
    chk_flag("Timing: all-bypass < LPF-only < all-active",
             (cycles_bypass < cycles_lpf) && (cycles_lpf < cycles_all));
    chk_flag("Timing: all-bypass < Notch-only < all-active",
             (cycles_bypass < cycles_notch) && (cycles_notch < cycles_all));
    chk_flag("Timing: all-active longer than any single filter alone",
             (cycles_all > cycles_lpf) && (cycles_all > cycles_notch));

    // -----------------------------------------------------------------------
    // Sc 8: Pipeline sequence correctness (LPF→Notch order)
    //   f=0.10 is: in LPF passband (passes LPF) but at notch frequency.
    //   With all active: attenuated (notch removes it after LPF passes it).
    //   With LPF-only: passes through (no notch applied yet).
    //   This verifies the order is indeed LPF first, then Notch.
    // -----------------------------------------------------------------------
    $display("\n--- Sc 8: LPF->Notch sequence correctness ---");
    // LPF-only: f=0.10 is in LPF passband, so it passes
    load_lpf_setA; load_notch_setB; load_hpf_fc005;
    do_reset;
    sign_en             = 1'b1;
    notch_filter_bypass = {CHN{1'b1}};
    lpf_filter_bypass   = {CHN{1'b0}};
    hpf_filter_bypass   = {CHN{1'b1}};
    run_sine_and_measure(0.100, 0.4, 120, 20, ratio_lpf);

    // All active: f=0.10 is removed by the notch (which follows LPF)
    load_lpf_setA; load_notch_setB; load_hpf_fc005;
    do_reset;
    sign_en             = 1'b1;
    notch_filter_bypass = {CHN{1'b0}};
    lpf_filter_bypass   = {CHN{1'b0}};
    hpf_filter_bypass   = {CHN{1'b1}};
    run_sine_and_measure(0.100, 0.4, 120, 20, ratio_notch);

    $display("    f=0.10: LPF-only ratio=%.4f, LPF+Notch ratio=%.4f",
             ratio_lpf, ratio_notch);
    chk_ratio("LPF-only: f=0.10 passes LPF (in passband)",
              ratio_lpf > 0.50, ratio_lpf);
    chk_ratio("LPF+Notch: f=0.10 attenuated after notch stage",
              ratio_notch < 0.05, ratio_notch);
    chk_flag("Sequence confirmed: Notch adds attenuation after LPF passes f=0.10",
             (ratio_lpf > 0.50) && (ratio_notch < 0.05));

    // -----------------------------------------------------------------------
    // Sc 9: Unsigned bypass mode
    // -----------------------------------------------------------------------
    $display("\n--- Sc 9: Unsigned bypass mode ---");
    load_lpf_setA; load_notch_setB; load_hpf_fc005;
    do_reset;
    sign_en             = 1'b0;
    notch_filter_bypass = {CHN{1'b1}};
    lpf_filter_bypass   = {CHN{1'b1}};
    hpf_filter_bypass   = {CHN{1'b1}};

    send_and_receive(32'hABCD_1234, sout, cyc);
    chk_flag("Unsigned bypass: 0xABCD1234 passes unchanged",
             sout === 32'hABCD_1234);
    send_and_receive(32'hFFFF_FFFF, sout, cyc);
    chk_flag("Unsigned bypass: 0xFFFFFFFF passes unchanged",
             sout === 32'hFFFF_FFFF);
    send_and_receive(32'h0000_0000, sout, cyc);
    chk_flag("Unsigned bypass: 0x00000000 passes unchanged",
             sout === 32'h0000_0000);

    // -----------------------------------------------------------------------
    // Sc 10: Unsigned all-active: notch attenuates notch freq
    // -----------------------------------------------------------------------
    $display("\n--- Sc 10: Unsigned all active - notch attenuates notch freq ---");
    load_lpf_setA; load_notch_setB; load_hpf_fc005;
    do_reset;
    sign_en             = 1'b0;
    notch_filter_bypass = {CHN{1'b0}};
    lpf_filter_bypass   = {CHN{1'b0}};
    hpf_filter_bypass   = {CHN{1'b0}};

    run_sine_and_measure(0.050, 0.3, 100, 20, ratio);
    chk_ratio("Unsigned all active: f=0.050 passes", ratio > 0.30, ratio);

    run_sine_and_measure(0.100, 0.3, 100, 20, ratio);
    chk_ratio("Unsigned all active: f=0.100 at notch, attenuated",
              ratio < 0.05, ratio);

    // -----------------------------------------------------------------------
    // Sc 11: Per-channel bypass register
    //   lpf_filter_bypass=0 (LPF enabled): f=0.35 is attenuated
    //   lpf_filter_bypass=1 (LPF disabled): f=0.35 passes
    // -----------------------------------------------------------------------
    $display("\n--- Sc 11: Per-channel LPF bypass register ---");
    load_lpf_setA; load_notch_setB; load_hpf_fc005;
    do_reset;
    sign_en             = 1'b1;
    notch_filter_bypass = {CHN{1'b1}};
    lpf_filter_bypass   = {CHN{1'b0}};   // LPF enabled
    hpf_filter_bypass   = {CHN{1'b1}};
    run_sine_and_measure(0.350, 0.4, 100, 20, ratio);
    chk_ratio("LPF_bypass=0 (LPF active): f=0.350 attenuated",
              ratio < 0.02, ratio);

    do_reset;
    lpf_filter_bypass   = {CHN{1'b1}};   // LPF bypassed
    run_sine_and_measure(0.350, 0.4, 100, 20, ratio_b);
    chk_ratio("LPF_bypass=1 (LPF bypassed): f=0.350 passes",
              ratio_b > 0.70, ratio_b);

    chk_flag("LPF bypass register controls LPF activity",
             (ratio < 0.02) && (ratio_b > 0.70));

    // -----------------------------------------------------------------------
    // Sc 12: notch_filter_valid reflects notch bypass state
    //   notch_filter_valid = |notch_filter_bypass_temp
    //   When bypass=0 (notch active, osr valid): notch_filter_valid=0
    //   When bypass=1 (notch bypassed):           notch_filter_valid=1
    // -----------------------------------------------------------------------
    $display("\n--- Sc 12: notch_filter_valid signal ---");
    load_lpf_setA; load_notch_setB; load_hpf_fc005;
    do_reset;
    notch_filter_bypass = {CHN{1'b1}};  // notch bypassed
    lpf_filter_bypass   = {CHN{1'b1}};
    hpf_filter_bypass   = {CHN{1'b1}};
    #1;
    chk_flag("notch_filter_valid=1 when notch bypassed",
             notch_filter_valid === 1'b1);

    // Notch active with valid osr_sel (4): notch_filter_bypass_temp should be 0
    // But notch_filter_valid = |notch_filter_bypass_temp; if all bypassed=0 → 0
    notch_filter_bypass = {CHN{1'b0}};
    #1;
    chk_flag("notch_filter_valid=0 when notch active and osr_sel valid",
             notch_filter_valid === 1'b0);

    // -----------------------------------------------------------------------
    // Sc 13: Reset during active pipeline
    //   Prime the pipeline with a signal, then assert reset.
    //   After reset, output must clear to 0 immediately.
    //   After deassert + flush with zeros, output stays at 0.
    // -----------------------------------------------------------------------
    $display("\n--- Sc 13: Reset during active pipeline ---");
    load_lpf_setA; load_notch_setB; load_hpf_fc005;
    do_reset;
    sign_en             = 1'b1;
    notch_filter_bypass = {CHN{1'b0}};
    lpf_filter_bypass   = {CHN{1'b0}};
    hpf_filter_bypass   = {CHN{1'b0}};

    // Send a few samples to prime the pipeline
    repeat (3) begin
      send_and_receive(32'h0200_0000, sout, cyc);
    end

    // Assert reset mid-pipeline
    #1;
    reset = 1'b0;
    repeat (5) @(posedge clk_src); #1;
    chk_flag("Reset during pipeline: imeas_chdata_out cleared to 0",
             imeas_chdata_out[0] === 32'h0);

    // Deassert and flush zeros
    reset = 1'b1;
    imeas_chdata_in[0] = 32'h0;
    // Wait for pipeline to stabilise (no need to manually count – just wait
    // generously since we're not testing timing here)
    repeat (200) @(posedge clk_src); #1;
    chk_flag("After reset: output remains 0 with zero input",
             $signed(imeas_chdata_out[0]) === 32'h0);

    // -----------------------------------------------------------------------
    // Summary
    // -----------------------------------------------------------------------
    $display("");
    $display("================================================================");
    $display(" PASS: %0d   FAIL: %0d   TOTAL: %0d",
             pass_cnt, fail_cnt, pass_cnt + fail_cnt);
    $display("================================================================");
    if (fail_cnt == 0)
      $display(" *** ALL TESTS PASSED ***");
    else
      $display(" *** %0d TEST(S) FAILED ***", fail_cnt);
    $display("");
    $finish;
  end

endmodule
