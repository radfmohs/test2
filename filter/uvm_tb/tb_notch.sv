// ============================================================================
// tb_notch.sv – Standalone comprehensive testbench for notch_filter
//
// DUT : notch_filter.sv  (14th-order IIR bandstop – 7 cascaded biquad sections,
//                         serial MAC, 42 clock cycles per output sample)
//
// Architecture recap
// ------------------
// With clk_enable = 1'b1 always (matching filter_wrapper usage where a gated
// clock controls the data rate, not clk_enable):
//   cur_count cycles 0 → 1 → … → 41 → 0, one complete pass per output sample.
//   phase_41  : cur_count == 41   → output_register updated (new output valid)
//   phase_0   : cur_count == 0    → delay_section states shift, computation begins
//
// Sampling convention used in this TB
// ------------------------------------
//   At every rising edge where cur_count == 41:
//     • output_register is captured (new filtered output available)
//     • input_register  captures whatever filter_in was BEFORE this edge
//   => Drive filter_in BEFORE the rising edge that makes cur_count go 41→0.
//      Read filter_out AFTER that same rising edge (+#1 for stability).
//
// Coefficient sets
// ----------------
// Set A – Default (from tb_top.sv "ncpy" force values):
//   7 sections, 50 Hz notch @ Fs = 64 kHz, normalised f_notch ≈ 0.000780·Fs
//   Poles very close to unit circle (r ≈ 0.9999) → settling ~ 50 000 samples.
//   Used ONLY for reset / bypass tests (coefficient-independent).
//
// Set B – "Wide" test notch (normalised f_notch = 0.10·Fs, r = 0.90):
//   Section 1 is an active notch biquad:
//     ω₀  = 2π × 0.10 = 0.6283 rad → zeros on unit circle at ±ω₀
//     b1  = b3 = 1.0,  b2 = −2cos(ω₀) = −1.61803
//     a2  = −2·r·cos(ω₀) = −1.45624,  a3 = r² = 0.81
//     scaleconst chosen for unity DC gain ≈ 0.9261
//   Sections 2–7 are identity (passthrough): scaleconst=1, b1=1, rest=0.
//   Poles at r = 0.9 → settling τ ≈ 10 samples → Nskip = 100 is sufficient.
//   Computed response:  f=0.02·Fs → H≈1.00,  f=0.10·Fs → H≈0.005 (−46 dB),
//                       f=0.15·Fs → H≈0.97
//
// Set C – Identity / allpass (all 7 sections passthrough):
//   scaleconst=1, b1=1, b2=b3=a2=a3=0 for every section.
//   Used to verify coefficient reconfiguration (notch freq should now PASS).
//
// OSR note: filter_wrapper auto-bypasses the notch for osr_sel outside [2,11].
// The normalised-frequency approach used here covers all valid OSR configs.
//
// Scenarios
// ---------
//   1.  Reset (active-low)  – filter_out = 0 while reset is asserted
//   2.  Bypass, signed      (sign_en=1, bypass=1) – out = in (combinational)
//   3.  Bypass, unsigned    (sign_en=0, bypass=1) – out = in (combinational)
//   4.  Signed passband, Set B: 4 freqs well below notch (0.02–0.07·Fs), ratio>0.5
//   5.  Signed notch stopband, Set B: f=0.10·Fs, ratio < 0.05  (≈−46 dB)
//   6.  Signed passband above notch, Set B: 3 freqs (0.13–0.20·Fs), ratio>0.5
//   7.  Signed high-freq passband, Set B: f=0.35·Fs, ratio > 0.5
//   8.  Unsigned passband, Set B: f=0.02·Fs, ratio > 0.5
//   9.  Unsigned notch, Set B: f=0.10·Fs, ratio < 0.05
//   10. Frequency sweep, Set B: tabular response DC → near-Nyquist
//   11. Coefficient reconfiguration A→B→C:
//       notch (0.10) attenuated with Set B, then passes with Set C (identity)
//   12. Default coefficients (Set A): check reset and bypass behavior
//   13. Reset during active filtering: output clears immediately
// ============================================================================
`timescale 1ns/1ps

module tb_notch;

  // -------------------------------------------------------------------------
  // Parameters
  // -------------------------------------------------------------------------
  localparam CLK_HALF            = 5;          // 10 ns → 100 MHz
  localparam real PI             = 3.14159265358979;
  localparam real UNSIGNED_DC_BIAS = 2147483648.0; // 2^31, unsigned mid-scale

  // -------------------------------------------------------------------------
  // DUT interface
  // -------------------------------------------------------------------------
  reg         clk;
  reg         reset;
  reg         sign_en;
  reg         bypass;
  wire [5:0]  o_cur_count;
  reg  signed [19:0] notch_coeff_data [0:41];
  reg  signed [31:0] filter_in;
  wire signed [31:0] filter_out;

  notch_filter dut (
    .clk              (clk),
    .clk_enable       (1'b1),
    .reset            (reset),
    .sign_en          (sign_en),
    .bypass           (bypass),
    .o_cur_count      (o_cur_count),
    .notch_coeff_data (notch_coeff_data),
    .filter_in        (filter_in),
    .filter_out       (filter_out)
  );

  initial clk = 1'b0;
  always  #CLK_HALF clk = ~clk;

  // -------------------------------------------------------------------------
  // Pass / fail counters (module-level)
  // -------------------------------------------------------------------------
  integer pass_cnt;
  integer fail_cnt;

  // Reuse-level reals used across tasks and scenarios
  real ratio;
  real ratio_b;
  real ratio_c;

  // Sweep table
  real sw_f  [0:15];
  real sw_r  [0:15];
  real sw_db [0:15];

  integer i;

  // =========================================================================
  // Utility tasks
  // =========================================================================
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
        $display("  [PASS] %-54s ratio=%7.4f (%+7.1f dB)", lbl, r, db);
        pass_cnt = pass_cnt + 1;
      end else begin
        $display("  [FAIL] %-54s ratio=%7.4f (%+7.1f dB)", lbl, r, db);
        fail_cnt = fail_cnt + 1;
      end
    end
  endtask

  // =========================================================================
  // Coefficient loaders
  // =========================================================================

  // Set A – tb_top.sv "ncpy" force values: 50 Hz notch @ Fs = 64 kHz
  // All coefficients are sfix20_En18 (1 sign bit, 1 integer bit, 18 frac bits,
  // range [-2, +2)).  Negative values are given as their 20-bit 2s-complement.
  task automatic load_coeff_A;
    integer j;
    begin
      // Section 1
      notch_coeff_data[ 0] = 20'b00111111111111110001; // scaleconst1 ≈ +1.0
      notch_coeff_data[ 1] = 20'b01000000000000000000; // b1_s1        = +1.0
      notch_coeff_data[ 2] = 20'b10000000000000000110; // b2_s1        ≈ −2.0
      notch_coeff_data[ 3] = 20'b01000000000000000000; // b3_s1        = +1.0
      notch_coeff_data[ 4] = 20'b10000000000000100111; // a2_s1        ≈ −2.0
      notch_coeff_data[ 5] = 20'b00111111111111100000; // a3_s1        ≈ +1.0
      // Section 2
      notch_coeff_data[ 6] = 20'b00111111111111110001;
      notch_coeff_data[ 7] = 20'b01000000000000000000;
      notch_coeff_data[ 8] = 20'b10000000000000000110;
      notch_coeff_data[ 9] = 20'b01000000000000000000;
      notch_coeff_data[10] = 20'b10000000000000100011;
      notch_coeff_data[11] = 20'b00111111111111100011;
      // Section 3
      notch_coeff_data[12] = 20'b00111111111111010101;
      notch_coeff_data[13] = 20'b01000000000000000000;
      notch_coeff_data[14] = 20'b10000000000000000110;
      notch_coeff_data[15] = 20'b01000000000000000000;
      notch_coeff_data[16] = 20'b10000000000001100001;
      notch_coeff_data[17] = 20'b00111111111110100110;
      // Section 4
      notch_coeff_data[18] = 20'b00111111111111010101;
      notch_coeff_data[19] = 20'b01000000000000000000;
      notch_coeff_data[20] = 20'b10000000000000000110;
      notch_coeff_data[21] = 20'b01000000000000000000;
      notch_coeff_data[22] = 20'b10000000000001011001;
      notch_coeff_data[23] = 20'b00111111111110101101;
      // Section 5
      notch_coeff_data[24] = 20'b00111111111111000010;
      notch_coeff_data[25] = 20'b01000000000000000000;
      notch_coeff_data[26] = 20'b10000000000000000110;
      notch_coeff_data[27] = 20'b01000000000000000000;
      notch_coeff_data[28] = 20'b10000000000010000110;
      notch_coeff_data[29] = 20'b00111111111110000000;
      // Section 6
      notch_coeff_data[30] = 20'b00111111111111000010;
      notch_coeff_data[31] = 20'b01000000000000000000;
      notch_coeff_data[32] = 20'b10000000000000000110;
      notch_coeff_data[33] = 20'b01000000000000000000;
      notch_coeff_data[34] = 20'b10000000000010000000;
      notch_coeff_data[35] = 20'b00111111111110000110;
      // Section 7
      notch_coeff_data[36] = 20'b00111111111110111011;
      notch_coeff_data[37] = 20'b01000000000000000000;
      notch_coeff_data[38] = 20'b10000000000000000110;
      notch_coeff_data[39] = 20'b01000000000000000000;
      notch_coeff_data[40] = 20'b10000000000010010001;
      notch_coeff_data[41] = 20'b00111111111101110101;
    end
  endtask

  // Set B – "Wide" test notch: f_notch = 0.10·Fs, pole radius r = 0.9
  //   Section 1 is the active biquad; sections 2–7 are identity (passthrough).
  //   All values in sfix20_En18 (×262144 = ×2^18).
  //
  //   Section 1 derived values (exact floats → quantised):
  //     ω₀ = 2π×0.10 = 0.62832 rad,  cos(ω₀) = 0.80902
  //     b2  = −2·cos(ω₀) = −1.61803  → −424032 → 2s-comp: 624544 = 0x987A0
  //     a2  = −2·r·cos(ω₀) = −1.45624→ −381698 → 2s-comp: 666878 = 0xA2CFE
  //     a3  = r² = 0.81000            →  212337 =          212337 = 0x33D71
  //     scaleconst for unit DC gain:  → 242781 = 0x3B45D
  //
  //   Identity section (all others):
  //     scaleconst = b1 = 1.0 → 262144 = 0x40000,  b2=b3=a2=a3=0
  task automatic load_coeff_B;
    integer j;
    begin
      // Section 1: active notch at f=0.10·Fs
      notch_coeff_data[ 0] = 20'h3B45D;  // scaleconst1 = 0.92611 (unity DC gain)
      notch_coeff_data[ 1] = 20'h40000;  // b1_s1  = +1.0
      notch_coeff_data[ 2] = 20'h987A0;  // b2_s1  = −1.61803 (2s-comp of −424032)
      notch_coeff_data[ 3] = 20'h40000;  // b3_s1  = +1.0
      notch_coeff_data[ 4] = 20'hA2CFE;  // a2_s1  = −1.45624 (2s-comp of −381698)
      notch_coeff_data[ 5] = 20'h33D71;  // a3_s1  = +0.81000

      // Sections 2–7: identity (passthrough)
      // Indices per section k (0-based k=1..6): base = 6+6*(k-1)
      //   [base+0]=scaleconst=0x40000, [base+1]=b1=0x40000, [base+2..5]=0
      for (j = 1; j <= 6; j = j + 1) begin
        notch_coeff_data[6*j + 0] = 20'h40000; // scaleconst = 1.0
        notch_coeff_data[6*j + 1] = 20'h40000; // b1 = 1.0
        notch_coeff_data[6*j + 2] = 20'h00000; // b2 = 0
        notch_coeff_data[6*j + 3] = 20'h00000; // b3 = 0
        notch_coeff_data[6*j + 4] = 20'h00000; // a2 = 0
        notch_coeff_data[6*j + 5] = 20'h00000; // a3 = 0
      end
    end
  endtask

  // Set C – Identity / allpass: every section is a trivial passthrough
  //   H_total(z) = 1  →  output = input (no filtering at any frequency)
  task automatic load_coeff_C;
    integer j;
    begin
      for (j = 0; j <= 6; j = j + 1) begin
        notch_coeff_data[6*j + 0] = 20'h40000; // scaleconst = 1.0
        notch_coeff_data[6*j + 1] = 20'h40000; // b1 = 1.0
        notch_coeff_data[6*j + 2] = 20'h00000; // b2 = 0
        notch_coeff_data[6*j + 3] = 20'h00000; // b3 = 0
        notch_coeff_data[6*j + 4] = 20'h00000; // a2 = 0
        notch_coeff_data[6*j + 5] = 20'h00000; // a3 = 0
      end
    end
  endtask

  // =========================================================================
  // Reset helper
  // =========================================================================
  task automatic do_reset;
    begin
      reset     = 1'b0;
      filter_in = 32'h0;
      sign_en   = 1'b1;
      bypass    = 1'b0;
      repeat (20) @(posedge clk);
      reset = 1'b1;
      repeat (5)  @(posedge clk);
    end
  endtask

  // =========================================================================
  // Core measurement task
  //
  // Drives Ntotal sine-wave samples and measures peak output amplitude over
  // the last (Ntotal - Nskip) samples.
  //
  // Timing model (with clk_enable = 1 always):
  //   • Synchronise: wait until cur_count reaches 41 (phase_41 is imminent).
  //   • Set filter_in = x[0] and wait for @(posedge clk):
  //     this is the 41→0 transition — output_register updated, x[0] latched.
  //   • Loop: at start of each iteration set filter_in = x[k+1], then
  //     wait repeat(42) clocks (one full 0→41→0 cycle) and read filter_out
  //     which now contains the filtered result for x[k].
  //
  // Unsigned output reconstruction (same trick as tb_lpf.sv):
  //   iverilog $itor() always treats its 32-bit argument as signed.
  //   We extract the unsigned value by splitting on bit 31:
  //     if fo[31]=1: AC value = +fo[30:0]           (above midpoint)
  //     if fo[31]=0: AC value = fo[30:0] - 2^31      (below midpoint)
  // =========================================================================
  task automatic run_sine_and_measure;
    input  real    freq_norm;
    input  real    ampl_frac;
    input  integer Ntotal;
    input  integer Nskip;
    output real    ampl_ratio;
    // locals
    real    in_peak, theta, cur_out;
    real    out_max, out_min;
    integer k, in_int;
    reg  [31:0] fo_bits;
    begin
      in_peak = ampl_frac * 268435456.0; // 2^28
      out_max = -1.0e30;
      out_min =  1.0e30;

      // --- synchronise to just before a new 41→0 transition ---
      // Step 1: wait until cur_count is NOT currently 41
      //   (prevents exiting immediately on a stale 41)
      while (o_cur_count == 6'd41) @(posedge clk);
      // Step 2: advance until cur_count reaches 41
      while (o_cur_count !== 6'd41) @(posedge clk);
      // Now: cur_count just became 41; next posedge will be the 41→0 transition

      // Drive x[0] (will be latched as input_register at the next posedge)
      theta  = 0.0;
      in_int = $rtoi(in_peak * $sin(theta));
      if (sign_en)
        filter_in = in_int;
      else
        filter_in = in_int + 32'h8000_0000;

      // Wait for the 41→0 transition posedge
      @(posedge clk);
      #1;
      // State now: cur_count=0, input_register=x[0], output_register updated

      // Main loop
      for (k = 0; k < Ntotal; k = k + 1) begin
        // Drive x[k+1] — captured at the 41→0 transition inside repeat(42)
        theta  = 2.0 * PI * freq_norm * real'(k + 1);
        in_int = $rtoi(in_peak * $sin(theta));
        if (sign_en)
          filter_in = in_int;
        else
          filter_in = in_int + 32'h8000_0000;

        // Wait one full filter cycle (42 clocks: cur_count 0→1→…→41→0)
        repeat (42) @(posedge clk);
        #1;

        // Read filter_out — holds the result for x[k]
        if (k >= Nskip) begin
          fo_bits = filter_out;
          if (sign_en) begin
            cur_out = $itor($signed(fo_bits));
          end else begin
            if (fo_bits[31] == 1'b1)
              cur_out = $itor(fo_bits[30:0]);
            else
              cur_out = $itor(fo_bits[30:0]) - UNSIGNED_DC_BIAS;
          end
          if (cur_out > out_max) out_max = cur_out;
          if (cur_out < out_min) out_min = cur_out;
        end
      end // for k

      if (out_max > -1.0e29)
        ampl_ratio = (out_max - out_min) / 2.0 / in_peak;
      else
        ampl_ratio = 0.0;
    end
  endtask

  // =========================================================================
  // MAIN TEST SEQUENCE
  // =========================================================================
  initial begin : main
    integer j;

    pass_cnt  = 0;
    fail_cnt  = 0;
    sign_en   = 1'b1;
    bypass    = 1'b0;
    filter_in = 32'h0;
    for (i = 0; i < 42; i = i + 1) notch_coeff_data[i] = 20'h0;

    $display("");
    $display("================================================================");
    $display(" tb_notch: notch_filter Comprehensive Testbench");
    $display("  Clk = 100 MHz | Fs_eff = ~2.381 MHz (= clk / 42 MAC cycles)");
    $display("  Set A: 50 Hz notch @ Fs=64 kHz (normalised ≈ 0.000780*Fs)");
    $display("  Set B: test notch @ 0.10*Fs,  r=0.90  (1 active + 6 identity sections)");
    $display("  Set C: identity (allpass, all sections passthrough)");
    $display("  OSR covered: all valid osr_sel=[2..11] via normalised freq tests");
    $display("================================================================");
    $display("");

    // -----------------------------------------------------------------------
    // Scenario 1: Reset assertion (active-low)
    //   All state registers clear to 0 while reset is low.
    //   Signed: filter_out = 0; Unsigned: bypass=0 → same 0 register → 0x8000_0000
    // -----------------------------------------------------------------------
    $display("--- Sc 1: Reset (active-low) ---");
    load_coeff_A;
    reset     = 1'b0;
    sign_en   = 1'b1;
    bypass    = 1'b0;
    filter_in = 32'h5A5A_5A5A;
    repeat (10) @(posedge clk);
    chk_flag("Reset asserted: filter_out==0 (signed)",  filter_out === 32'h0);

    sign_en = 1'b0;
    repeat (5) @(posedge clk);
    // During reset: output_register = 0 → filter_out = 0 + 0x80000000 = 0x80000000
    chk_flag("Reset asserted: filter_out==0x80000000 (unsigned DC baseline)",
             filter_out === 32'h8000_0000);
    reset   = 1'b1;
    sign_en = 1'b1;
    repeat (5) @(posedge clk);

    // -----------------------------------------------------------------------
    // Scenario 2: Bypass, signed (sign_en=1, bypass=1)
    //   filter_out = filter_in combinationally, independent of filter state.
    // -----------------------------------------------------------------------
    $display("\n--- Sc 2: Bypass, signed (sign_en=1) ---");
    load_coeff_A;
    do_reset;
    bypass  = 1'b1;
    sign_en = 1'b1;

    filter_in = 32'h1234_5678; @(posedge clk); #1;
    chk_flag("Bypass signed: in=0x12345678 → out=0x12345678",
             filter_out === 32'h1234_5678);
    filter_in = 32'h7FFF_FFFF; @(posedge clk); #1;
    chk_flag("Bypass signed: in=0x7FFFFFFF (max +)",
             filter_out === 32'h7FFF_FFFF);
    filter_in = 32'h8000_0000; @(posedge clk); #1;
    chk_flag("Bypass signed: in=0x80000000 (max -)",
             filter_out === 32'h8000_0000);
    filter_in = 32'hDEAD_BEEF; @(posedge clk); #1;
    chk_flag("Bypass signed: in=0xDEADBEEF",
             filter_out === 32'hDEAD_BEEF);

    // -----------------------------------------------------------------------
    // Scenario 3: Bypass, unsigned (sign_en=0, bypass=1)
    // -----------------------------------------------------------------------
    $display("\n--- Sc 3: Bypass, unsigned (sign_en=0) ---");
    sign_en = 1'b0;

    filter_in = 32'h0000_0000; @(posedge clk); #1;
    chk_flag("Bypass unsigned: in=0x00000000",
             filter_out === 32'h0000_0000);
    filter_in = 32'h8000_0000; @(posedge clk); #1;
    chk_flag("Bypass unsigned: in=0x80000000 (mid-scale)",
             filter_out === 32'h8000_0000);
    filter_in = 32'hFFFF_FFFF; @(posedge clk); #1;
    chk_flag("Bypass unsigned: in=0xFFFFFFFF (max)",
             filter_out === 32'hFFFF_FFFF);
    bypass = 1'b0;

    // -----------------------------------------------------------------------
    // Scenarios 4–7: Signed mode, Set B
    //   Notch at 0.10·Fs, pole radius r=0.9, settling τ≈10 samples.
    //   Passband threshold: ratio > 0.50
    //   Stopband threshold: ratio < 0.05  (Set B predicted H≈0.005 at notch)
    // -----------------------------------------------------------------------
    $display("\n--- Sc 4-7: Signed mode, Set B (f_notch=0.10*Fs) ---");
    load_coeff_B;
    do_reset;
    sign_en = 1'b1;
    bypass  = 1'b0;

    // -- Sc 4: passband below notch --
    $display("  [4] Passband below notch (f << 0.10*Fs):");
    run_sine_and_measure(0.020, 0.5, 500, 100, ratio);
    chk_ratio("  Signed passband f=0.020*Fs", ratio > 0.50, ratio);

    run_sine_and_measure(0.040, 0.5, 500, 100, ratio);
    chk_ratio("  Signed passband f=0.040*Fs", ratio > 0.50, ratio);

    run_sine_and_measure(0.060, 0.5, 500, 100, ratio);
    chk_ratio("  Signed passband f=0.060*Fs", ratio > 0.50, ratio);

    run_sine_and_measure(0.070, 0.5, 500, 100, ratio);
    chk_ratio("  Signed passband f=0.070*Fs", ratio > 0.50, ratio);

    // -- Sc 5: notch stopband --
    $display("  [5] Notch stopband (f = 0.10*Fs):");
    run_sine_and_measure(0.100, 0.5, 500, 100, ratio);
    chk_ratio("  Signed notch f=0.100*Fs", ratio < 0.05, ratio);

    // -- Sc 6: passband above notch --
    $display("  [6] Passband above notch (f > 0.10*Fs):");
    run_sine_and_measure(0.130, 0.5, 500, 100, ratio);
    chk_ratio("  Signed passband f=0.130*Fs", ratio > 0.50, ratio);

    run_sine_and_measure(0.150, 0.5, 500, 100, ratio);
    chk_ratio("  Signed passband f=0.150*Fs", ratio > 0.50, ratio);

    run_sine_and_measure(0.200, 0.5, 500, 100, ratio);
    chk_ratio("  Signed passband f=0.200*Fs", ratio > 0.50, ratio);

    // -- Sc 7: high-frequency passband (well above notch) --
    $display("  [7] High-frequency passband:");
    run_sine_and_measure(0.350, 0.5, 500, 100, ratio);
    chk_ratio("  Signed passband f=0.350*Fs", ratio > 0.50, ratio);

    // -----------------------------------------------------------------------
    // Scenarios 8–9: Unsigned mode, Set B
    // -----------------------------------------------------------------------
    $display("\n--- Sc 8-9: Unsigned mode, Set B ---");
    load_coeff_B;
    do_reset;
    sign_en = 1'b0;
    bypass  = 1'b0;

    $display("  [8] Unsigned passband:");
    run_sine_and_measure(0.040, 0.4, 500, 100, ratio);
    chk_ratio("  Unsigned passband f=0.040*Fs", ratio > 0.50, ratio);

    $display("  [9] Unsigned notch:");
    run_sine_and_measure(0.100, 0.4, 500, 100, ratio);
    chk_ratio("  Unsigned notch f=0.100*Fs", ratio < 0.05, ratio);

    // -----------------------------------------------------------------------
    // Scenario 10: Frequency sweep (signed, Set B) – tabular output
    //   Maps normalised frequency to representative real data-rate contexts:
    //     Fs = 64 kHz (osr_sel=2):  f_notch = 0.10×64k = 6400 Hz
    //     Fs =  8 kHz (osr_sel=7):  f_notch = 0.10×8k  =  800 Hz
    //     Fs =  2 kHz (osr_sel=9):  f_notch = 0.10×2k  =  200 Hz
    //     Fs = 512 Hz (osr_sel=11): f_notch = 0.10×512 =  51.2 Hz
    // -----------------------------------------------------------------------
    $display("\n--- Sc 10: Frequency Sweep (Set B, signed) ---");
    load_coeff_B;
    do_reset;
    sign_en = 1'b1;
    bypass  = 1'b0;

    sw_f[ 0] = 0.005; sw_f[ 1] = 0.010; sw_f[ 2] = 0.020;
    sw_f[ 3] = 0.040; sw_f[ 4] = 0.060; sw_f[ 5] = 0.080;
    sw_f[ 6] = 0.090; sw_f[ 7] = 0.095; sw_f[ 8] = 0.100;
    sw_f[ 9] = 0.105; sw_f[10] = 0.110; sw_f[11] = 0.130;
    sw_f[12] = 0.150; sw_f[13] = 0.200; sw_f[14] = 0.300;
    sw_f[15] = 0.400;

    $display("  %7s  %8s  %8s  %10s", "f/Fs", "Ratio", "dB", "Region");
    for (i = 0; i < 16; i = i + 1) begin
      run_sine_and_measure(sw_f[i], 0.5, 400, 80, sw_r[i]);
      sw_db[i] = (sw_r[i] > 1.0e-9) ? 20.0 * $log10(sw_r[i]) : -180.0;
      if      (sw_f[i] < 0.089) $display("  %7.4f  %8.5f  %8.1f  PASSBAND",
                                           sw_f[i], sw_r[i], sw_db[i]);
      else if (sw_f[i] <= 0.111) $display("  %7.4f  %8.5f  %8.1f  NOTCH",
                                           sw_f[i], sw_r[i], sw_db[i]);
      else                        $display("  %7.4f  %8.5f  %8.1f  PASSBAND",
                                           sw_f[i], sw_r[i], sw_db[i]);
    end

    // -----------------------------------------------------------------------
    // Scenario 11: Coefficient reconfiguration B → C
    //   With Set B: notch freq 0.10*Fs is heavily attenuated.
    //   Switch to Set C (identity): same freq should now pass (ratio ≈ 1.0).
    //   This verifies live coefficient reconfiguration.
    // -----------------------------------------------------------------------
    $display("\n--- Sc 11: Coefficient reconfiguration B → C ---");
    load_coeff_B;
    do_reset;
    sign_en = 1'b1;
    bypass  = 1'b0;
    // Measure with Set B (notch active)
    run_sine_and_measure(0.100, 0.5, 500, 100, ratio_b);

    // Switch to Set C (identity – notch removed), allow transient to clear
    load_coeff_C;
    do_reset;
    run_sine_and_measure(0.100, 0.5, 500, 100, ratio_c);

    chk_ratio("  Set B: f=0.100*Fs in notch stopband", ratio_b < 0.05,  ratio_b);
    chk_ratio("  Set C: f=0.100*Fs passes (identity)",  ratio_c > 0.50,  ratio_c);
    chk_flag ("  Reconfiguration changes response at notch freq",
              (ratio_b < 0.05) && (ratio_c > 0.50));

    // -----------------------------------------------------------------------
    // Scenario 12: Default coefficients (Set A) – reset and bypass
    //   Set A has r≈0.9999 → 50 000+ samples needed for frequency tests.
    //   Instead, verify reset and bypass behavior with Set A loaded, which
    //   confirms the hardware interface works with production coefficients.
    // -----------------------------------------------------------------------
    $display("\n--- Sc 12: Default coefficients (Set A) – reset & bypass ---");
    load_coeff_A;

    reset     = 1'b0;
    sign_en   = 1'b1;
    bypass    = 1'b0;
    filter_in = 32'hCAFE_BABE;
    repeat (10) @(posedge clk);
    chk_flag("Set A + reset: filter_out==0 (signed)", filter_out === 32'h0);

    reset   = 1'b1;
    bypass  = 1'b1;
    sign_en = 1'b1;
    repeat (3) @(posedge clk); #1;
    chk_flag("Set A + bypass signed: out==in",
             filter_out === 32'hCAFE_BABE);

    sign_en   = 1'b0;
    filter_in = 32'hDEAD_BEEF;
    @(posedge clk); #1;
    chk_flag("Set A + bypass unsigned: out==in",
             filter_out === 32'hDEAD_BEEF);
    bypass = 1'b0;

    // -----------------------------------------------------------------------
    // Scenario 13: Reset during active filtering (Set B)
    //   Prime the filter pipeline with non-zero data, then assert reset.
    //   All internal registers must clear to 0 within the reset period.
    //   After deassert + clean input: output must settle back to 0.
    // -----------------------------------------------------------------------
    $display("\n--- Sc 13: Reset during active filtering ---");
    load_coeff_B;
    do_reset;
    sign_en = 1'b1;
    bypass  = 1'b0;

    // Feed 30 non-zero samples to prime the pipeline
    filter_in = 32'h0200_0000;
    for (j = 0; j < 30; j = j + 1) begin
      while (o_cur_count !== 6'd41) @(posedge clk);
      @(posedge clk);
      #1;
    end

    // Assert reset mid-computation
    reset = 1'b0;
    repeat (5) @(posedge clk);
    chk_flag("Reset mid-filter: filter_out cleared to 0",
             filter_out === 32'h0);

    // Deassert and feed zeros; after full flush, output must be 0
    reset     = 1'b1;
    filter_in = 32'h0;
    repeat (5) @(posedge clk);
    // Advance 200 cycles (>> filter order) to flush pipeline
    repeat (200) @(posedge clk);
    chk_flag("After reset: filter settled to 0",
             $signed(filter_out) === 32'h0);

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
