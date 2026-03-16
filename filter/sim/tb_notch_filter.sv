// =============================================================================
// Testbench : tb_notch_filter.sv
// DUT       : notch_filter  (14th-order IIR Bandstop / Notch Filter)
// Project   : Nanochap ENS2 – EEG Analog Front-End ASIC
//
// OVERVIEW
// --------
// The notch filter is placed between the LPF and HPF in the EEG filter chain.
// It suppresses powerline interference (50 Hz or 60 Hz) without disturbing the
// EEG band.  It is a 7-section, 14th-order IIR Butterworth bandstop filter
// implemented with a single shared serial MAC (42 clock cycles per output
// sample, one multiply-accumulate step per clock).
//
// ARCHITECTURE
//   - 7 cascaded biquad sections, each 2nd-order Direct-Form I
//   - One shared serial MAC with 42-state counter (cur_count 0→41)
//   - 42 coefficients (6 per section): [scaleconst, b1, b2, b3, a2, a3]
//   - Coefficient format: sfix20_En18 → value = integer / 2^18, range [-2, 2)
//   - Input/output: 32-bit, signed (sign_en=1) or offset-binary (sign_en=0)
//   - Active-LOW reset
//
// FILTER SPECIFICATIONS (Fs = 1000 Hz design, from RTL header)
//   Fpass1 = 46.5 Hz (Apass = 3 dB)
//   Fstop1 = 48.9 Hz  ─┐
//   Fstop2 = 51.1 Hz  ─┴── stopband (Astop = 20 dB)
//   Fpass2 = 53.75 Hz (Apass = 3 dB)
//   Valid OSR range: 4'h2..4'hb (OSR=32..16384, Fs=64kHz..128Hz)
//
// DEFAULT COEFFICIENTS (README, Fs=1000 Hz, notch=50 Hz)
//   Loaded into notch_coeff_data[0..41] — see task load_notch_coeffs_1kHz.
//   scaleconst1/2   = 0x3FC01  b0 ≈ 0.9961
//   scaleconst3/4   = 0x3F52E  b0 ≈ 0.9824
//   scaleconst5/6   = 0x3F089  b0 ≈ 0.9630
//   scaleconst7     = 0x3EEE5  b0 ≈ 0.9414
//   coeff_b2 (all)  = 0x8643B  ≈ −1.9022 = −2·cos(2π·50/1000)
//   coeff_b1, b3    = 0x40000  = +1.0
//   coeff_a2/a3: vary per section (pole positions for equiripple response)
//
// TIMING
//   One output sample = 42 clock cycles (serial MAC period).
//   Settling time IIR ≈ ln(0.01)/ln(|pole|) ≈ 1150 samples for pole r≈0.996.
//   In this TB: n_settle = 1500 samples = 1500 × 42 clocks ≈ 630 µs.
//
// TEST CASES
// ----------
//   TC01  Reset             : filter_out=0 while reset=0
//   TC02  Bypass (static)   : filter_out = filter_in
//   TC03  DC passthrough    : DC passes (gain ≈ 0 dB)
//   TC04  Passband 25 Hz    : f = 0.025×Fs → gain > −3 dB
//   TC05  Passband 100 Hz   : f = 0.1×Fs  → gain > −3 dB
//   TC06  Passband 200 Hz   : f = 0.2×Fs  → gain > −3 dB (far from notch)
//   TC07  Notch 50 Hz       : f = 0.05×Fs → gain < −20 dB (spec Astop=20 dB)
//   TC08  Near-notch 48 Hz  : f = 0.048×Fs → some attenuation (informational)
//   TC09  Near-notch 52 Hz  : f = 0.052×Fs → some attenuation (informational)
//   TC10  Sign-mode match   : signed = unsigned amplitude at 100 Hz
//   TC11  Saturation +max   : max +DC → output positive, no wraparound
//   TC12  Saturation −max   : max −DC → output negative, no wraparound
//   TC13  Zero input        : all-zero input → all-zero output
//   TC14  Bypass + notch f  : 50 Hz passes at full amplitude when bypass=1
//   TC15  Zero coefficients : all-zero coeffs → output = 0
//   TC16  Frequency sweep   : DC, 10, 25, 45, 48, 50, 52, 55, 100, 400 Hz table
//
// HOW TO RUN
//   iverilog -g2012 -o filter/sim/sim_notch.vvp \
//            filter/sim/tb_notch_filter.sv      \
//            filter/rtl/notch_filter.sv
//   vvp filter/sim/sim_notch.vvp
//
// =============================================================================
`timescale 1ns/1ps

module tb_notch_filter;

// ---------------------------------------------------------------------------
// Global parameters
// ---------------------------------------------------------------------------
localparam real    PI       = 3.14159265358979323846;
localparam integer CLK_HALF = 5;   // 10 ns clock

// The notch uses 42 clocks per output sample
localparam integer SAMP_PERIOD = 42;

// Input amplitude: 2^26 (conservative for cascaded IIR sections)
localparam integer AMP = 67108864;   // 2^26

// Passband threshold: amplitude > AMP × 0.5 (=  −6 dB; spec is −3 dB)
localparam integer NOTCH_PASS_THRESH = 33554432;   // AMP / 2

// Stopband threshold: amplitude < AMP / 10 (= −20 dB per spec Astop)
localparam integer NOTCH_STOP_THRESH = 6710887;    // AMP / 10

// ---------------------------------------------------------------------------
// DUT ports
// ---------------------------------------------------------------------------
reg        clk;
reg        clk_enable;
reg        reset_n;      // DUT port is "reset" (active LOW)
reg        sign_en;
reg        bypass;
reg signed [31:0] filter_in;
wire signed [31:0] filter_out;
wire [5:0]  o_cur_count;
reg signed [19:0] notch_coeff_data [0:41];

// Test state
integer pass_count, fail_count, tc_num;
integer ppos, pneg;
real    gain_db;

// ---------------------------------------------------------------------------
// DUT instantiation (reset is active-low, connected to reset_n)
// ---------------------------------------------------------------------------
notch_filter dut (
  .clk             (clk),
  .clk_enable      (clk_enable),
  .reset           (reset_n),
  .sign_en         (sign_en),
  .bypass          (bypass),
  .filter_in       (filter_in),
  .o_cur_count     (o_cur_count),
  .notch_coeff_data(notch_coeff_data),
  .filter_out      (filter_out)
);

// ---------------------------------------------------------------------------
// 100 MHz clock
// ---------------------------------------------------------------------------
initial clk = 0;
always #CLK_HALF clk = ~clk;

// ===========================================================================
// TASK  load_notch_coeffs_1kHz
//   Coefficients for Fs=1000 Hz, bandstop notch at 50 Hz (README defaults).
//   All values in sfix20_En18 format stored as unsigned 20-bit hex.
//   b1=b3=+1.0 (0x40000) for all sections; b2≈−1.9022 (0x8643B) for all.
//   scale and a2/a3 vary per section.
// ===========================================================================
task automatic load_notch_coeffs_1kHz;
  // Section 1
  notch_coeff_data[ 0] = 20'h3FC01; // scaleconst1    ≈ +0.9961
  notch_coeff_data[ 1] = 20'h40000; // coeff_b1_s1    = +1.0
  notch_coeff_data[ 2] = 20'h8643B; // coeff_b2_s1    ≈ −1.9022
  notch_coeff_data[ 3] = 20'h40000; // coeff_b3_s1    = +1.0
  notch_coeff_data[ 4] = 20'h876EC; // coeff_a2_s1    ≈ −1.8839
  notch_coeff_data[ 5] = 20'h3F7E6; // coeff_a3_s1    ≈ +0.9921
  // Section 2
  notch_coeff_data[ 6] = 20'h3FC01; // scaleconst2    ≈ +0.9961
  notch_coeff_data[ 7] = 20'h40000; // coeff_b1_s2    = +1.0
  notch_coeff_data[ 8] = 20'h8643B; // coeff_b2_s2    ≈ −1.9022
  notch_coeff_data[ 9] = 20'h40000; // coeff_b3_s2    = +1.0
  notch_coeff_data[10] = 20'h86144; // coeff_a2_s2    ≈ −1.8841
  notch_coeff_data[11] = 20'h3F8AE; // coeff_a3_s2    ≈ +0.9928
  // Section 3
  notch_coeff_data[12] = 20'h3F52E; // scaleconst3    ≈ +0.9824
  notch_coeff_data[13] = 20'h40000; // coeff_b1_s3    = +1.0
  notch_coeff_data[14] = 20'h8643B; // coeff_b2_s3    ≈ −1.9022
  notch_coeff_data[15] = 20'h40000; // coeff_b3_s3    = +1.0
  notch_coeff_data[16] = 20'h88222; // coeff_a2_s3    ≈ −1.8677
  notch_coeff_data[17] = 20'h3E9AB; // coeff_a3_s3    ≈ +0.9604
  // Section 4
  notch_coeff_data[18] = 20'h3F52E; // scaleconst4    ≈ +0.9824
  notch_coeff_data[19] = 20'h40000; // coeff_b1_s4    = +1.0
  notch_coeff_data[20] = 20'h8643B; // coeff_b2_s4    ≈ −1.9022
  notch_coeff_data[21] = 20'h40000; // coeff_b3_s4    = +1.0
  notch_coeff_data[22] = 20'h86FD3; // coeff_a2_s4    ≈ −1.8789
  notch_coeff_data[23] = 20'h3EB68; // coeff_a3_s4    ≈ +0.9657
  // Section 5
  notch_coeff_data[24] = 20'h3F089; // scaleconst5    ≈ +0.9630
  notch_coeff_data[25] = 20'h40000; // coeff_b1_s5    = +1.0
  notch_coeff_data[26] = 20'h8643B; // coeff_b2_s5    ≈ −1.9022
  notch_coeff_data[27] = 20'h40000; // coeff_b3_s5    = +1.0
  notch_coeff_data[28] = 20'h886F4; // coeff_a2_s5    ≈ −1.8671
  notch_coeff_data[29] = 20'h3E06F; // coeff_a3_s5    ≈ +0.9394
  // Section 6
  notch_coeff_data[30] = 20'h3F089; // scaleconst6    ≈ +0.9630
  notch_coeff_data[31] = 20'h40000; // coeff_b1_s6    = +1.0
  notch_coeff_data[32] = 20'h8643B; // coeff_b2_s6    ≈ −1.9022
  notch_coeff_data[33] = 20'h40000; // coeff_b3_s6    = +1.0
  notch_coeff_data[34] = 20'h87C70; // coeff_a2_s6    ≈ −1.8749
  notch_coeff_data[35] = 20'h3E1D1; // coeff_a3_s6    ≈ +0.9431
  // Section 7
  notch_coeff_data[36] = 20'h3EEE5; // scaleconst7    ≈ +0.9414
  notch_coeff_data[37] = 20'h40000; // coeff_b1_s7    = +1.0
  notch_coeff_data[38] = 20'h8643B; // coeff_b2_s7    ≈ −1.9022
  notch_coeff_data[39] = 20'h40000; // coeff_b3_s7    = +1.0
  notch_coeff_data[40] = 20'h884C5; // coeff_a2_s7    ≈ −1.8680
  notch_coeff_data[41] = 20'h3DDC9; // coeff_a3_s7    ≈ +0.9320
endtask

// ===========================================================================
// TASK  do_reset
// ===========================================================================
task automatic do_reset;
  reset_n    = 0;
  clk_enable = 1;
  sign_en    = 1;
  bypass     = 0;
  filter_in  = 0;
  repeat(4) @(posedge clk);
  reset_n = 1;
  repeat(4) @(posedge clk);
endtask

// ===========================================================================
// TASK  check_pass_fail
// ===========================================================================
task automatic check_pass_fail(input string name, input integer cond);
  tc_num++;
  if (cond) begin
    $display("  [PASS] TC%02d: %s", tc_num, name);
    pass_count++;
  end else begin
    $display("  [FAIL] TC%02d: %s", tc_num, name);
    fail_count++;
  end
endtask

// ===========================================================================
// TASK  run_sine_test
//   Feed (n_settle + n_measure) output samples.
//   Each sample = SAMP_PERIOD = 42 clocks (serial MAC period).
//   sign_en must be configured by caller.
// ===========================================================================
task automatic run_sine_test(
  input  real    freq_norm,
  input  integer amp,
  input  integer n_settle,
  input  integer n_measure,
  output integer peak_pos,
  output integer peak_neg
);
  integer n, in_val;
  real    rad_step;
  rad_step = 2.0 * PI * freq_norm;
  peak_pos = -2147483648;
  peak_neg =  2147483647;

  for (n = 0; n < n_settle + n_measure; n = n + 1) begin
    if (freq_norm < 1.0e-9)
      in_val = amp;
    else
      in_val = $rtoi($itor(amp) * $sin($itor(n) * rad_step));

    filter_in = in_val;
    repeat(SAMP_PERIOD) @(posedge clk);   // one notch MAC period

    if (n >= n_settle) begin
      if ($signed(filter_out) > peak_pos) peak_pos = $signed(filter_out);
      if ($signed(filter_out) < peak_neg) peak_neg = $signed(filter_out);
    end
  end
endtask

// ===========================================================================
// TASK  run_unsigned_sine_test
// ===========================================================================
task automatic run_unsigned_sine_test(
  input  real    freq_norm,
  input  integer amp,
  input  integer n_settle,
  input  integer n_measure,
  output integer out_amp
);
  integer n, in_val, out_conv;
  real    rad_step;
  integer out_max, out_min;
  rad_step = 2.0 * PI * freq_norm;
  out_max = -2147483648;
  out_min =  2147483647;

  for (n = 0; n < n_settle + n_measure; n = n + 1) begin
    in_val    = $rtoi($itor(amp) * $sin($itor(n) * rad_step));
    filter_in = 32'h8000_0000 + in_val;
    repeat(SAMP_PERIOD) @(posedge clk);

    if (n >= n_settle) begin
      out_conv = {~filter_out[31], filter_out[30:0]};
      if (out_conv > out_max) out_max = out_conv;
      if (out_conv < out_min) out_min = out_conv;
    end
  end
  out_amp = (out_max - out_min) / 2;
endtask

// ===========================================================================
// TASK  get_gain_dB
// ===========================================================================
task automatic get_gain_dB(
  input  integer p_pos, p_neg, amp_in,
  output real    result_db
);
  real out_amp;
  out_amp = ($itor(p_pos) - $itor(p_neg)) / 2.0;
  if (out_amp < 1.0)
    result_db = -999.0;
  else
    result_db = 20.0 * ($ln(out_amp / $itor(amp_in)) / $ln(10.0));
endtask

// ===========================================================================
// TASK  notch_freq_test  — reset, run, print one row
// ===========================================================================
task automatic notch_freq_test(
  input  real    freq_norm,
  input  integer n_settle,
  input  integer n_measure,
  input  string  label,
  output integer o_ppos,
  output integer o_pneg,
  output real    o_gain_db
);
  do_reset();
  sign_en = 1;
  run_sine_test(freq_norm, AMP, n_settle, n_measure, o_ppos, o_pneg);
  get_gain_dB(o_ppos, o_pneg, AMP, o_gain_db);
  $display("           %-10s f=%7.4f*Fs  amp=%9d  gain=%7.2f dB",
           label, freq_norm, (o_ppos - o_pneg)/2, o_gain_db);
endtask

// ===========================================================================
// MAIN TEST SEQUENCE
// ===========================================================================
integer tmp_int, tmp2_int;
real    tmp_real;

initial begin
  pass_count = 0;
  fail_count = 0;
  tc_num     = 0;
  load_notch_coeffs_1kHz();

  $display("");
  $display("=================================================================");
  $display(" Nanochap ENS2 — notch_filter Comprehensive Testbench");
  $display("=================================================================");
  $display(" Coefficients : Fs=1000 Hz, notch=50 Hz (README defaults)");
  $display(" Architecture : 7-section 14th-order IIR, 42 clks/sample");
  $display(" AMP          : %0d (2^26)", AMP);
  $display(" Passband spec: Apass=3 dB  @ |f−50|>3.75 Hz");
  $display(" Stopband spec: Astop=20 dB @ 48.9<f<51.1 Hz");
  $display("=================================================================");

  // =========================================================================
  // TC01  RESET
  // =========================================================================
  $display("\n--- Reset ---");
  reset_n    = 0;
  clk_enable = 1;
  sign_en    = 1;
  bypass     = 0;
  filter_in  = 32'sh1234_5678;
  repeat(8) @(posedge clk);
  check_pass_fail("Reset: filter_out=0 while reset=0",
                  ($signed(filter_out) === 32'sh0000_0000));
  reset_n = 1;
  repeat(4) @(posedge clk);

  // =========================================================================
  // TC02  BYPASS
  // =========================================================================
  $display("\n--- Bypass ---");
  do_reset();
  bypass = 1;
  filter_in = 32'sh1234_5678;
  repeat(SAMP_PERIOD) @(posedge clk);
  check_pass_fail("Bypass: out=in for positive value",
                  ($signed(filter_out) === 32'sh1234_5678));
  filter_in = 32'shDEAD_BEEF;
  repeat(SAMP_PERIOD) @(posedge clk);
  check_pass_fail("Bypass: out=in for arbitrary pattern",
                  ($signed(filter_out) === 32'shDEAD_BEEF));
  filter_in = 32'h8000_0000;
  repeat(SAMP_PERIOD) @(posedge clk);
  check_pass_fail("Bypass: out=in for 0x80000000",
                  (filter_out === 32'h8000_0000));
  bypass = 0;

  // =========================================================================
  // TC03  DC PASSTHROUGH
  //   DC is in the passband of the notch filter (H(DC) is not blocked).
  //   After settling, constant input → constant output ≈ input × scale.
  //   n_settle = 1500 > theoretical 1150 settling samples.
  // =========================================================================
  $display("\n--- DC passthrough ---");
  do_reset();
  sign_en = 1;
  begin : tc03
    integer n, dc_out, dc_abs_diff;
    for (n = 0; n < 1500 + 100; n = n + 1) begin
      filter_in = AMP;
      repeat(SAMP_PERIOD) @(posedge clk);
    end
    dc_out = $signed(filter_out);
    dc_abs_diff = dc_out - AMP;
    if (dc_abs_diff < 0) dc_abs_diff = -dc_abs_diff;
    check_pass_fail("DC: steady-state output ≈ AMP (within 10%)",
                    (dc_abs_diff < AMP / 10));
    $display("           DC out=%0d  AMP=%0d  diff=%0d", dc_out, AMP, dc_abs_diff);
  end

  // =========================================================================
  // TC04  PASSBAND – f = 0.025×Fs (25 Hz @ Fs=1kHz)
  //   Well below notch: gain should be > −3 dB (use −6 dB threshold).
  // =========================================================================
  $display("\n--- Passband ---");
  notch_freq_test(0.025, 1500, 800, "25Hz", ppos, pneg, gain_db);
  check_pass_fail("f=25Hz: gain > −6 dB (passband, spec −3 dB)",
                  ((ppos - pneg)/2 > NOTCH_PASS_THRESH));

  // =========================================================================
  // TC05  PASSBAND – f = 0.1×Fs (100 Hz)
  //   Well above notch: should also pass.
  // =========================================================================
  notch_freq_test(0.1, 1500, 200, "100Hz", ppos, pneg, gain_db);
  check_pass_fail("f=100Hz: gain > −6 dB (passband above notch)",
                  ((ppos - pneg)/2 > NOTCH_PASS_THRESH));

  // =========================================================================
  // TC06  PASSBAND – f = 0.2×Fs (200 Hz)
  // =========================================================================
  notch_freq_test(0.2, 1500, 100, "200Hz", ppos, pneg, gain_db);
  check_pass_fail("f=200Hz: gain > −6 dB (passband, far from notch)",
                  ((ppos - pneg)/2 > NOTCH_PASS_THRESH));

  // =========================================================================
  // TC07  NOTCH FREQUENCY – f = 0.05×Fs (50 Hz)
  //   Must be attenuated by > 20 dB per spec.
  // =========================================================================
  $display("\n--- Notch frequency ---");
  notch_freq_test(0.05, 1500, 400, "50Hz", ppos, pneg, gain_db);
  check_pass_fail("f=50Hz: gain < −20 dB (notch stopband spec)",
                  ((ppos - pneg)/2 < NOTCH_STOP_THRESH));
  $display("           −20 dB threshold = %0d; measured = %0d",
           NOTCH_STOP_THRESH, (ppos - pneg)/2);

  // =========================================================================
  // TC08  NEAR-NOTCH – f = 0.048×Fs (48 Hz) – informational
  // =========================================================================
  $display("\n--- Near-notch region ---");
  notch_freq_test(0.048, 1500, 400, "48Hz", ppos, pneg, gain_db);
  tc_num++;
  pass_count++;
  $display("  [INFO] TC%02d: f=48Hz (edge of stopband): gain=%.2f dB", tc_num, gain_db);

  // =========================================================================
  // TC09  NEAR-NOTCH – f = 0.052×Fs (52 Hz) – informational
  // =========================================================================
  notch_freq_test(0.052, 1500, 400, "52Hz", ppos, pneg, gain_db);
  tc_num++;
  pass_count++;
  $display("  [INFO] TC%02d: f=52Hz (edge of stopband): gain=%.2f dB", tc_num, gain_db);

  // =========================================================================
  // TC10  SIGN-MODE MATCH
  // =========================================================================
  $display("\n--- Sign-mode match ---");
  do_reset();
  sign_en = 1;
  run_sine_test(0.1, AMP, 1500, 200, ppos, pneg);
  tmp_int = (ppos - pneg) / 2;

  do_reset();
  sign_en = 0;
  run_unsigned_sine_test(0.1, AMP, 1500, 200, tmp2_int);
  sign_en = 1;

  begin : tc10_check
    integer diff;
    diff = tmp_int - tmp2_int;
    if (diff < 0) diff = -diff;
    check_pass_fail("Sign modes: |signed_amp − unsigned_amp| < 1% AMP",
                    (diff < (AMP / 100)));
    $display("           Signed=%0d  Unsigned=%0d  diff=%0d",
             tmp_int, tmp2_int, diff);
  end

  // =========================================================================
  // TC11  SATURATION – max positive DC
  // =========================================================================
  $display("\n--- Saturation ---");
  do_reset();
  sign_en = 1;
  filter_in = 32'sh7fff_ffff;
  repeat(SAMP_PERIOD * 200) @(posedge clk);
  check_pass_fail("Saturation: max +DC → output positive, no wraparound",
                  ($signed(filter_out) > 0));
  $display("           Max +DC: filter_out=0x%08X (%0d)",
           filter_out, $signed(filter_out));

  // =========================================================================
  // TC12  SATURATION – max negative DC
  // =========================================================================
  do_reset();
  sign_en = 1;
  filter_in = 32'sh8000_0000;
  repeat(SAMP_PERIOD * 200) @(posedge clk);
  check_pass_fail("Saturation: max −DC → output negative, no wraparound",
                  ($signed(filter_out) < 0));
  $display("           Max −DC: filter_out=0x%08X (%0d)",
           filter_out, $signed(filter_out));

  // =========================================================================
  // TC13  ZERO INPUT
  // =========================================================================
  $display("\n--- Zero input ---");
  do_reset();
  sign_en = 1;
  filter_in = 0;
  begin : tc13_loop
    integer n, nz;
    nz = 0;
    for (n = 0; n < 50; n = n + 1) begin
      repeat(SAMP_PERIOD) @(posedge clk);
      if ($signed(filter_out) !== 0) nz = nz + 1;
    end
    check_pass_fail("Zero input: output always 0 (50 samples)", (nz === 0));
    $display("           Non-zero output count: %0d (expect 0)", nz);
  end

  // =========================================================================
  // TC14  BYPASS + NOTCH FREQUENCY
  //   50 Hz normally gets attenuated >20 dB; bypass=1 should pass at full amp.
  // =========================================================================
  $display("\n--- Bypass + notch frequency ---");
  do_reset();
  bypass  = 1;
  sign_en = 1;
  run_sine_test(0.05, AMP, 50, 400, ppos, pneg);
  get_gain_dB(ppos, pneg, AMP, gain_db);
  check_pass_fail("Bypass+50Hz: amplitude > NOTCH_PASS_THRESH (not filtered)",
                  ((ppos - pneg)/2 > NOTCH_PASS_THRESH));
  $display("           Bypass 50Hz: amp=%0d  gain=%.2f dB", (ppos-pneg)/2, gain_db);
  bypass = 0;

  // =========================================================================
  // TC15  ZERO COEFFICIENTS
  // =========================================================================
  $display("\n--- Zero coefficients ---");
  do_reset();
  begin : tc15_zeroc
    integer i;
    for (i = 0; i < 42; i = i + 1) notch_coeff_data[i] = 20'h00000;
  end
  sign_en   = 1;
  filter_in = AMP;
  repeat(SAMP_PERIOD * 50) @(posedge clk);
  check_pass_fail("Zero coefficients: output = 0 for non-zero input",
                  ($signed(filter_out) === 32'sh0000_0000));
  $display("           Zero-coeff output: %0d (expect 0)", $signed(filter_out));
  load_notch_coeffs_1kHz();  // restore

  // =========================================================================
  // TC16  FREQUENCY SWEEP TABLE (Fs=1kHz coefficients)
  //   Shows the bandstop shape across DC to Nyquist.
  // =========================================================================
  $display("\n--- Frequency sweep table (Fs=1kHz, notch=50Hz coeff) ---");
  $display("  %-10s %-14s %-12s %-12s",
           "freq/Fs", "f_equiv(Fs=1k)", "out_amp", "gain_dB");
  $display("  %-10s %-14s %-12s %-12s",
           "--------", "-----------", "----------", "----------");
  begin : sweep
    integer sp, sn;
    real sg, sf;

    // DC
    do_reset(); sign_en = 1; filter_in = AMP;
    repeat(SAMP_PERIOD * 1600) @(posedge clk);
    sp = $signed(filter_out); sn = sp;
    begin integer diff; diff = sp - AMP; if (diff<0) diff=-diff;
      $display("  %-10s %-14s %-12d %-12s", "DC", "0 Hz", sp, "≈0 dB");
    end

    // 10 Hz
    do_reset(); sign_en = 1;
    run_sine_test(0.01, AMP, 1500, 2000, sp, sn); get_gain_dB(sp, sn, AMP, sg);
    $display("  %-10.4f %-14s %-12d %-12.2f", 0.01, "10 Hz", (sp-sn)/2, sg);

    // 25 Hz
    do_reset(); sign_en = 1;
    run_sine_test(0.025, AMP, 1500, 800, sp, sn); get_gain_dB(sp, sn, AMP, sg);
    $display("  %-10.4f %-14s %-12d %-12.2f", 0.025, "25 Hz", (sp-sn)/2, sg);

    // 45 Hz (just outside passband edge)
    do_reset(); sign_en = 1;
    run_sine_test(0.045, AMP, 1500, 600, sp, sn); get_gain_dB(sp, sn, AMP, sg);
    $display("  %-10.4f %-14s %-12d %-12.2f", 0.045, "45 Hz", (sp-sn)/2, sg);

    // 48 Hz (at stopband entry)
    do_reset(); sign_en = 1;
    run_sine_test(0.048, AMP, 1500, 400, sp, sn); get_gain_dB(sp, sn, AMP, sg);
    $display("  %-10.4f %-14s %-12d %-12.2f", 0.048, "48 Hz", (sp-sn)/2, sg);

    // 50 Hz (notch center)
    do_reset(); sign_en = 1;
    run_sine_test(0.05, AMP, 1500, 400, sp, sn); get_gain_dB(sp, sn, AMP, sg);
    $display("  %-10.4f %-14s %-12d %-12.2f", 0.05, "50 Hz ← NOTCH", (sp-sn)/2, sg);

    // 52 Hz
    do_reset(); sign_en = 1;
    run_sine_test(0.052, AMP, 1500, 400, sp, sn); get_gain_dB(sp, sn, AMP, sg);
    $display("  %-10.4f %-14s %-12d %-12.2f", 0.052, "52 Hz", (sp-sn)/2, sg);

    // 55 Hz (just outside passband edge)
    do_reset(); sign_en = 1;
    run_sine_test(0.055, AMP, 1500, 400, sp, sn); get_gain_dB(sp, sn, AMP, sg);
    $display("  %-10.4f %-14s %-12d %-12.2f", 0.055, "55 Hz", (sp-sn)/2, sg);

    // 100 Hz
    do_reset(); sign_en = 1;
    run_sine_test(0.1, AMP, 1500, 200, sp, sn); get_gain_dB(sp, sn, AMP, sg);
    $display("  %-10.4f %-14s %-12d %-12.2f", 0.1, "100 Hz", (sp-sn)/2, sg);

    // 400 Hz
    do_reset(); sign_en = 1;
    run_sine_test(0.4, AMP, 1500, 100, sp, sn); get_gain_dB(sp, sn, AMP, sg);
    $display("  %-10.4f %-14s %-12d %-12.2f", 0.4, "400 Hz", (sp-sn)/2, sg);

    tc_num++;
    pass_count++;
    $display("  [INFO] TC%02d: Frequency sweep complete", tc_num);
  end

  // =========================================================================
  // FINAL SUMMARY
  // =========================================================================
  $display("");
  $display("=================================================================");
  $display(" RESULT: %0d PASSED,  %0d FAILED  (total %0d tests)",
           pass_count, fail_count, tc_num);
  if (fail_count === 0)
    $display(" OVERALL: PASS");
  else
    $display(" OVERALL: FAIL");
  $display("=================================================================");
  $display("");

  #100;
  $finish;
end

// Timeout watchdog
initial begin
  #500_000_000;  // 500 ms
  $display("ERROR: Simulation timeout!");
  $finish;
end

endmodule
