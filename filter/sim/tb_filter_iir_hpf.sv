// =============================================================================
// Testbench : tb_filter_iir_hpf.sv
// DUT       : filter_iir_hpf  (1st-order IIR High-Pass Filter)
// Project   : Nanochap ENS2 – EEG Analog Front-End ASIC
//
// OVERVIEW
// --------
// The IIR HPF is the last stage of the EEG filter chain (after LPF → Notch).
// It removes baseline wander (DC and very low frequencies) from the EEG signal.
// It is a fully-parallel 1st-order Section (Direct Form II), 1 clock per output
// sample (unlike the LPF which uses a 32-clock serial MAC).
//
// TRANSFER FUNCTION
//   H(z) = b₀ × (1 − z⁻¹) / (1 + a × z⁻¹)
//   b₀ = scaleconst1 = (1 − a) / 2 = 1 / (K + 1)
//   a  = coeff_a2    = (K − 1) / (K + 1)          (negative, close to −1)
//   K  = tan(π × Fc / Fs)
//
// HARDCODED COEFFICIENTS (from RTL)
//   coeff_b1 = +1   (24'b010000000000000000000000, sfix24_En22)
//   coeff_b2 = −1   (24'b110000000000000000000000, sfix24_En22)
//   coeff_b3 =  0
//   coeff_a3 =  0
//   coeff_a2 = coeff_b1 − coeff  = 1 − b₀  ≈ −a   (computed internally)
//
// PROGRAMMABLE COEFFICIENT
//   coeff [23:0] = scaleconst1 = b₀ in sfix24_En23
//               = round(b₀ × 2²³)
//
// FREQUENCY RESPONSE
//   |H(f)| → 0         as f → 0   (DC completely blocked)
//   |H(Fc)| = 1/√2     (−3 dB by design)
//   |H(f)| ≈ f/Fc / √(1 + (f/Fc)²) for f << Fc  (–20 dB/decade slope)
//   |H(f)| → b₀ ≈ 1   as f → Fs/2 (Nyquist passes at near unity)
//
// SIGNAL FORMATS (same as LPF)
//   sign_en = 1: 32-bit two's complement input/output
//   sign_en = 0: offset-binary (0x80000000 = 0, subtract/add midpoint internally)
//
// HPF BYPASS (filter_wrapper.sv)
//   hpf_filter_bypass_temp = hpf_filter_bypass  (NO auto-bypass from data rate)
//   The bypass port is directly user-controlled (SPI reg 0xB1/0xB2).
//
// SETTLING TIME
//   n_settle = ln(0.01) / ln(|a|)  samples  (time to reach 1% of initial value)
//   For a = −0.9937 (Fc=1Hz, Fs=1kHz): n_settle ≈ 727 samples
//   For a = −0.939  (Fc=10Hz, Fs=1kHz): n_settle ≈ 72 samples
//   For a = −0.510  (Fc=100Hz, Fs=1kHz): n_settle ≈ 7 samples
//
// COEFFICIENT PRESETS (Fs=1kHz, three EEG-relevant cutoff frequencies)
//   Fc/Fs = 0.001  (Fc=1Hz)  : K=tan(π/1000)≈0.003142  coeff=24'h7F9961
//   Fc/Fs = 0.01   (Fc=10Hz) : K=tan(π/100)≈0.031426   coeff=24'h7C18E7
//   Fc/Fs = 0.1    (Fc=100Hz): K=tan(π/10)≈0.32492     coeff=24'h609E01
//   Default register value from README (Fs=1kHz, Fc=1Hz): 0x7F9961
//
// TEST CASES
// ----------
//   TC01  Reset             : filter_out=0, out register=0 while reset_n=0
//   TC02  Bypass (static)   : filter_out = filter_in for any 32-bit value
//   TC03  DC rejection (s)  : constant +AMP → output decays to ≈0 (signed)
//   TC04  DC rejection (u)  : constant DC   → offset-binary output → midpoint
//   TC05  Passband high  (f=100×Fc)  : gain > −1 dB
//   TC06  Passband mid   (f=10×Fc)   : gain > −1 dB
//   TC07  At Fc          (f=1×Fc)    : gain in [−4 dB, −2 dB]
//   TC08  Stopband low   (f=Fc/10)   : gain < −18 dB  (≈−20 dB expected)
//   TC09  Sign-mode match            : signed vs unsigned give same amplitude
//   TC10  Saturation +max DC         : output positive, no wraparound
//   TC11  Saturation −max DC         : output negative, no wraparound
//   TC12  Settling time              : output < 1% of input after n_settle
//   TC13  Impulse response           : single pulse → exponential IIR tail
//   TC14  Zero input                 : output always 0 (200 samples)
//   TC15  Bypass + DC                : DC passes unchanged when bypass=1
//   TC16  Bypass + lowfreq sine      : low-freq sine passes at full amplitude
//   TC17  Zero coeff                 : coeff=0 → output=0 (degenerate case)
//   TC18  clk_enable gating          : filter holds when clk_enable=0
//   TC19  Fc=10×Fc config            : verify attenuation moves with coeff
//   TC20  Fc=100×Fc config           : fast settling, full freq sweep
//   TC21  Frequency sweep table      : DC … Nyquist gain table (high-Fc coeff)
//
// HOW TO RUN
//   iverilog -g2012 -o filter/sim/sim_hpf.vvp \
//            filter/sim/tb_filter_iir_hpf.sv   \
//            filter/rtl/filter_iir_hpf.v
//   vvp filter/sim/sim_hpf.vvp
//
// =============================================================================
`timescale 1ns/1ps

module tb_filter_iir_hpf;

// ---------------------------------------------------------------------------
// Global parameters
// ---------------------------------------------------------------------------
localparam real    PI       = 3.14159265358979323846;
localparam integer CLK_HALF = 5;   // 10 ns period = 100 MHz

// Input amplitude: 2^28 (25% of full-scale – safe headroom for the IIR)
localparam integer AMP = 268435456;

// Threshold: amplitude > AMP×0.891 means gain > −1 dB (passband pass)
localparam integer PASS_THRESH = 239066906;

// Threshold: amplitude in [AMP×0.5, AMP×0.9] means gain ≈ −3 dB (at Fc)
localparam integer FC_LOW_THRESH  = 134217728;   // AMP/2 = −6 dB lower bound
localparam integer FC_HIGH_THRESH = 241591910;   // AMP×0.9 = −0.9 dB upper

// Threshold: amplitude < AMP×0.15 means attenuation > −16.5 dB (below Fc)
localparam integer STOP_THRESH_16 = 40265319;   // AMP×0.15

// Threshold: amplitude < AMP×0.02 means attenuation > −34 dB (well below Fc)
localparam integer STOP_THRESH_34 = 5368709;    // AMP×0.02

// DC rejection threshold: |output| < AMP×0.01 after n_settle samples
localparam integer DC_REJECT_THRESH = 2684355;   // AMP/100 = −40 dB

// ---------------------------------------------------------------------------
// Coefficient presets (sfix24_En23 format; coeff = round(b₀ × 2²³))
//   b₀ = 1/(K+1),  K = tan(π × Fc/Fs)
// ---------------------------------------------------------------------------
// Fc/Fs = 0.001  (e.g. Fc=1 Hz,   Fs=1 kHz) → K≈0.003142  a≈−0.9937
localparam [23:0] COEFF_FC_0P001 = 24'h7F9961;  // b₀≈0.9969  (README default)
// Fc/Fs = 0.01   (e.g. Fc=10 Hz,  Fs=1 kHz) → K≈0.031426  a≈−0.9388
localparam [23:0] COEFF_FC_0P01  = 24'h7C18E7;  // b₀≈0.9695
// Fc/Fs = 0.1    (e.g. Fc=100 Hz, Fs=1 kHz) → K≈0.32492   a≈−0.5094
localparam [23:0] COEFF_FC_0P1   = 24'h609E01;  // b₀≈0.7548

// ---------------------------------------------------------------------------
// DUT ports
// ---------------------------------------------------------------------------
reg        clk;
reg        clk_enable;
reg        reset_n;
reg        sign_en;
reg        bypass;
reg [23:0] coeff;
reg signed [31:0] filter_in;
wire signed [31:0] filter_out;

// Test state
integer pass_count, fail_count, tc_num;
integer ppos, pneg;
real    gain_db;

// ---------------------------------------------------------------------------
// DUT instantiation
// ---------------------------------------------------------------------------
filter_iir_hpf dut (
  .clk        (clk),
  .clk_enable (clk_enable),
  .reset_n    (reset_n),
  .sign_en    (sign_en),
  .bypass     (bypass),
  .coeff      (coeff),
  .filter_in  (filter_in),
  .filter_out (filter_out)
);

// ---------------------------------------------------------------------------
// 100 MHz clock (= 1 output sample per clock cycle in standalone mode)
// ---------------------------------------------------------------------------
initial clk = 0;
always #CLK_HALF clk = ~clk;

// ===========================================================================
// TASK  do_reset
// ===========================================================================
task automatic do_reset;
  reset_n    = 0;
  clk_enable = 1;
  sign_en    = 1;
  bypass     = 0;
  coeff      = COEFF_FC_0P001;  // default: Fc/Fs = 0.001
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
//   Feed (n_settle + n_measure) output samples of a sine wave at frequency
//   freq_norm × Fs.  The HPF is fully parallel: 1 sample per clock cycle.
//   sign_en and coeff must be configured before calling.
// ===========================================================================
task automatic run_sine_test(
  input  real    freq_norm,   // f/Fs  (0=DC, 0.5=Nyquist)
  input  integer amp,         // signed input amplitude
  input  integer n_settle,    // samples to discard
  input  integer n_measure,   // samples to measure
  output integer peak_pos,    // maximum output seen
  output integer peak_neg     // minimum output seen
);
  integer n, in_val;
  real    rad_step;
  rad_step = 2.0 * PI * freq_norm;
  peak_pos = -2147483648;
  peak_neg =  2147483647;

  for (n = 0; n < n_settle + n_measure; n = n + 1) begin
    if (freq_norm < 1.0e-9)
      in_val = amp;          // DC
    else
      in_val = $rtoi($itor(amp) * $sin($itor(n) * rad_step));

    filter_in = in_val;
    @(posedge clk);          // 1 clock = 1 output sample (fully parallel IIR)

    if (n >= n_settle) begin
      if ($signed(filter_out) > peak_pos) peak_pos = $signed(filter_out);
      if ($signed(filter_out) < peak_neg) peak_neg = $signed(filter_out);
    end
  end
endtask

// ===========================================================================
// TASK  run_unsigned_sine_test
//   Offset-binary mode (sign_en=0).  Flips MSB to centre around 0x80000000
//   before tracking peak-to-peak amplitude.
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
    @(posedge clk);

    if (n >= n_settle) begin
      out_conv = {~filter_out[31], filter_out[30:0]};  // offset-bin → 2's comp
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
  if (out_amp < 1.0) begin
    if ($itor(amp_in) > 0.0 && $itor(p_pos) > 0.0)
      result_db = 20.0 * ($ln($itor(p_pos) / $itor(amp_in)) / $ln(10.0));
    else
      result_db = -999.0;
  end else
    result_db = 20.0 * ($ln(out_amp / $itor(amp_in)) / $ln(10.0));
endtask

// ===========================================================================
// TASK  freq_test_hpf
//   Reset, configure, run, and print one frequency test row.
// ===========================================================================
task automatic freq_test_hpf(
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

  $display("");
  $display("=================================================================");
  $display(" Nanochap ENS2 — filter_iir_hpf Comprehensive Testbench");
  $display("=================================================================");
  $display(" Default coeff : 0x%06X  (Fc/Fs=0.001, e.g. Fc=1Hz Fs=1kHz)",
           COEFF_FC_0P001);
  $display(" Transfer fn   : H(z)=b0*(1-z^-1)/(1+a*z^-1)  [1st-order IIR]");
  $display(" Key property  : H(DC)=0, H(Nyquist)≈1, H(Fc)=-3 dB");
  $display(" AMP           : %0d (2^28)", AMP);
  $display("=================================================================");

  // =========================================================================
  // TC01  RESET
  // =========================================================================
  $display("\n--- Reset ---");
  reset_n    = 0;
  clk_enable = 1;
  sign_en    = 1;
  bypass     = 0;
  coeff      = COEFF_FC_0P001;
  filter_in  = 32'sh1234_5678;
  repeat(8) @(posedge clk);
  check_pass_fail("Reset: filter_out=0 while reset_n=0",
                  ($signed(filter_out) === 32'sh0000_0000));
  reset_n = 1;
  repeat(4) @(posedge clk);

  // =========================================================================
  // TC02  BYPASS (static)
  // =========================================================================
  $display("\n--- Bypass ---");
  do_reset();
  bypass = 1;

  filter_in = 32'sh1234_5678;
  repeat(4) @(posedge clk);
  check_pass_fail("Bypass: out=in for +ve value",
                  ($signed(filter_out) === 32'sh1234_5678));

  filter_in = 32'shDEAD_BEEF;
  repeat(4) @(posedge clk);
  check_pass_fail("Bypass: out=in for arbitrary bit pattern",
                  ($signed(filter_out) === 32'shDEAD_BEEF));

  filter_in = 32'h8000_0000;
  repeat(4) @(posedge clk);
  check_pass_fail("Bypass: out=in for 0x80000000",
                  (filter_out === 32'h8000_0000));
  bypass = 0;

  // =========================================================================
  // TC03  DC REJECTION – SIGNED MODE
  //   Constant +AMP input.  After n_settle samples, the IIR HPF should have
  //   drained the DC; output must be < AMP×0.01 (−40 dB, 1% of input).
  //   n_settle = 1000 > 727 (formula: ln(0.01)/ln(0.9937)) for Fc/Fs=0.001.
  // =========================================================================
  $display("\n--- DC rejection (signed, Fc/Fs=0.001) ---");
  do_reset();
  sign_en = 1;
  begin : tc03
    integer n, out_abs;
    for (n = 0; n < 1000; n = n + 1) begin
      filter_in = AMP;
      @(posedge clk);
    end
    out_abs = $signed(filter_out);
    if (out_abs < 0) out_abs = -out_abs;
    check_pass_fail("DC rejected: |output| < AMP/100 after 1000 samples",
                    (out_abs < DC_REJECT_THRESH));
    $display("           DC out after 1000 samples = %0d  (threshold %0d)",
             $signed(filter_out), DC_REJECT_THRESH);
  end

  // =========================================================================
  // TC04  DC REJECTION – UNSIGNED MODE
  //   Input = 0x80000000 + AMP/2 (DC in offset-binary).
  //   After settling, output should be close to 0x80000000 (zero crossing).
  // =========================================================================
  $display("\n--- DC rejection (unsigned) ---");
  do_reset();
  sign_en = 0;
  begin : tc04
    integer n, out_centered, out_abs;
    for (n = 0; n < 1000; n = n + 1) begin
      filter_in = 32'h8000_0000 + (AMP >> 1);
      @(posedge clk);
    end
    // Flip MSB to measure deviation from 0x80000000
    out_centered = {~filter_out[31], filter_out[30:0]};
    out_abs = out_centered;
    if (out_abs < 0) out_abs = -out_abs;
    check_pass_fail("DC rejected (unsigned): |output − 0x80000000| < AMP/100",
                    (out_abs < DC_REJECT_THRESH));
    $display("           DC unsigned out deviation = %0d  (threshold %0d)",
             out_centered, DC_REJECT_THRESH);
  end
  sign_en = 1;

  // =========================================================================
  // TC05  PASSBAND – f = 100×Fc  (freq_norm = 0.1)
  //   At 100×Fc the 1st-order HPF is essentially flat (gain ≈ −0.004 dB).
  //   The default coefficient has a pole at z ≈ 0.994 → n_settle=800 needed
  //   for the transient component (a^n × input) to decay to < 1%.
  //   n_measure=200 covers 20 full periods of the 10-sample sine.
  // =========================================================================
  $display("\n--- Passband (Fc/Fs=0.001 coeff) ---");
  freq_test_hpf(0.1, 800, 200, "100*Fc", ppos, pneg, gain_db);
  check_pass_fail("f=100*Fc: gain > −1 dB (well inside passband)",
                  ((ppos - pneg)/2 > PASS_THRESH));

  // =========================================================================
  // TC06  PASSBAND – f = 10×Fc  (freq_norm = 0.01)
  //   n_settle=800, n_measure=2000 covers ≥20 full periods of the 100-sample
  //   sine, ensuring the IIR transient (pole at 0.994) has decayed < 1%.
  // =========================================================================
  freq_test_hpf(0.01, 800, 2000, "10*Fc", ppos, pneg, gain_db);
  check_pass_fail("f=10*Fc: gain > −1 dB (passband)",
                  ((ppos - pneg)/2 > PASS_THRESH));

  // =========================================================================
  // TC07  AT CUTOFF FREQUENCY – f = Fc  (freq_norm = 0.001)
  //   Expected gain = −3 dB.  n_settle=900, n_measure=5000 (5 full periods).
  //   Pass if gain is between −5 dB and −1 dB (numerical precision margin).
  // =========================================================================
  $display("\n--- At cutoff frequency (Fc/Fs=0.001) ---");
  freq_test_hpf(0.001, 900, 5000, "at Fc", ppos, pneg, gain_db);
  check_pass_fail("f=Fc: gain in [−5 dB, −1 dB] (−3 dB design target)",
                  ((ppos - pneg)/2 > FC_LOW_THRESH) &&
                  ((ppos - pneg)/2 < FC_HIGH_THRESH));
  $display("           Expected ≈ −3 dB; bounds: [%0d, %0d]",
           FC_LOW_THRESH, FC_HIGH_THRESH);

  // =========================================================================
  // TC08  STOPBAND – f = Fc/10  (freq_norm = 0.0001)
  //   Expected gain ≈ −20 dB (1st-order, −20 dB/decade).
  //   n_settle=900, n_measure=15000 covers ≥ 1.5 full periods (period=10000).
  // =========================================================================
  $display("\n--- Stopband (below Fc) ---");
  freq_test_hpf(0.0001, 900, 15000, "Fc/10", ppos, pneg, gain_db);
  check_pass_fail("f=Fc/10: gain < −16 dB (stopband, −20 dB expected)",
                  ((ppos - pneg)/2 < STOP_THRESH_16));
  $display("           −20 dB reference amp = %0d; measured = %0d",
           AMP/10, (ppos - pneg)/2);

  // =========================================================================
  // TC09  SIGN-MODE MATCH
  //   Signed and unsigned modes should produce identical amplitude at 10×Fc.
  // =========================================================================
  $display("\n--- Sign-mode match ---");
  do_reset();
  sign_en = 1;
  run_sine_test(0.01, AMP, 50, 1000, ppos, pneg);
  tmp_int = (ppos - pneg) / 2;

  do_reset();
  sign_en = 0;
  run_unsigned_sine_test(0.01, AMP, 50, 1000, tmp2_int);
  sign_en = 1;

  begin : tc09_check
    integer diff;
    diff = tmp_int - tmp2_int;
    if (diff < 0) diff = -diff;
    check_pass_fail("Sign modes: |signed_amp − unsigned_amp| < 1% AMP",
                    (diff < (AMP / 100)));
    $display("           Signed=%0d  Unsigned=%0d  diff=%0d",
             tmp_int, tmp2_int, diff);
  end

  // =========================================================================
  // TC10  SATURATION – max positive DC
  // =========================================================================
  $display("\n--- Saturation ---");
  do_reset();
  sign_en = 1;
  filter_in = 32'sh7fff_ffff;
  repeat(200) @(posedge clk);
  check_pass_fail("Saturation: max +ve DC → output positive, no wraparound",
                  ($signed(filter_out) > 0));
  $display("           Max +ve DC: filter_out=0x%08X (%0d)",
           filter_out, $signed(filter_out));

  // =========================================================================
  // TC11  SATURATION – max negative DC
  // =========================================================================
  do_reset();
  sign_en = 1;
  filter_in = 32'sh8000_0000;
  repeat(200) @(posedge clk);
  check_pass_fail("Saturation: max −ve DC → output negative, no wraparound",
                  ($signed(filter_out) < 0));
  $display("           Max −ve DC: filter_out=0x%08X (%0d)",
           filter_out, $signed(filter_out));

  // =========================================================================
  // TC12  SETTLING TIME
  //   Feed constant +AMP for N cycles; verify output decays to < 1% of AMP.
  //   For a = −0.9937: n_settle ≈ 727.  We use 900 to be safe.
  //   The formula: y[n] = b₀ × AMP + a × y[n-1] → y[∞] = b₀ × AMP × (1/(1+a)) × 0 = 0
  //   The actual convergence: y[n] ≈ AMP × ... × a^n → 0.
  // =========================================================================
  $display("\n--- Settling time ---");
  do_reset();
  sign_en = 1;
  begin : tc12
    integer n, out_abs;
    for (n = 0; n < 900; n = n + 1) begin
      filter_in = AMP;
      @(posedge clk);
    end
    out_abs = $signed(filter_out);
    if (out_abs < 0) out_abs = -out_abs;
    check_pass_fail("Settling: |output| < 1% AMP after 900 samples (DC input)",
                    (out_abs < DC_REJECT_THRESH));
    $display("           After 900 samples (n_settle≈727): |out|=%0d  thr=%0d",
             out_abs, DC_REJECT_THRESH);
  end

  // =========================================================================
  // TC13  IMPULSE RESPONSE
  //   A single nonzero sample drives the IIR pole.  The output should show
  //   an exponential tail (not zero) for many samples, confirming the IIR
  //   memory.  After 100 samples of zeros, the tail should be nonzero (for
  //   Fc/Fs=0.001, |a|=0.9937 → decay per sample is tiny).
  // =========================================================================
  $display("\n--- Impulse response ---");
  do_reset();
  sign_en = 1;
  filter_in = AMP;
  @(posedge clk);         // one impulse sample
  filter_in = 0;
  // After 100 samples the IIR tail should still be nonzero (pole near −1)
  begin : tc13
    integer n, n100_out;
    for (n = 0; n < 99; n = n + 1) @(posedge clk);
    n100_out = $signed(filter_out);
    check_pass_fail("Impulse: IIR tail still nonzero at n=100 (memory confirms)",
                    (n100_out !== 0));
    $display("           Output at n=100 after impulse: %0d (should be ≠ 0)",
             n100_out);
    // After 2000 samples the tail should be negligible (a^2000 ≈ 3.3e-6)
    for (n = 0; n < 1900; n = n + 1) @(posedge clk);
    check_pass_fail("Impulse: tail decays to <1% AMP after 2100 samples",
                    ($signed(filter_out) < DC_REJECT_THRESH) &&
                    ($signed(filter_out) > -DC_REJECT_THRESH));
    $display("           Output at n=2100: %0d  (threshold ±%0d)",
             $signed(filter_out), DC_REJECT_THRESH);
  end

  // =========================================================================
  // TC14  ZERO INPUT
  // =========================================================================
  $display("\n--- Zero input ---");
  do_reset();
  sign_en = 1;
  filter_in = 0;
  begin : tc14_loop
    integer n, nz;
    nz = 0;
    for (n = 0; n < 200; n = n + 1) begin
      @(posedge clk);
      if ($signed(filter_out) !== 0) nz = nz + 1;
    end
    check_pass_fail("Zero input: output always 0 (200 samples)", (nz === 0));
    $display("           Non-zero output count: %0d (expect 0)", nz);
  end

  // =========================================================================
  // TC15  BYPASS + DC
  //   When bypass=1, constant DC input must pass through unchanged.
  // =========================================================================
  $display("\n--- Bypass + DC ---");
  do_reset();
  bypass    = 1;
  sign_en   = 1;
  filter_in = 32'sh1A2B_3C4D;
  repeat(8) @(posedge clk);
  check_pass_fail("Bypass+DC: filter_out = filter_in (DC passes unchanged)",
                  ($signed(filter_out) === 32'sh1A2B_3C4D));
  bypass = 0;

  // =========================================================================
  // TC16  BYPASS + LOW-FREQUENCY SINE
  //   At f = Fc (0.001 × Fs), without bypass the HPF is at −3 dB.
  //   With bypass=1, the sine must pass at full amplitude (≈ 0 dB).
  // =========================================================================
  $display("\n--- Bypass + low-freq sine ---");
  do_reset();
  bypass  = 1;
  sign_en = 1;
  run_sine_test(0.001, AMP, 50, 5000, ppos, pneg);
  get_gain_dB(ppos, pneg, AMP, gain_db);
  check_pass_fail("Bypass+Fc sine: amplitude > PASS_THRESH (no filtering)",
                  ((ppos - pneg)/2 > PASS_THRESH));
  $display("           Bypass Fc sine: amp=%0d  gain=%.2f dB",
           (ppos-pneg)/2, gain_db);
  bypass = 0;

  // =========================================================================
  // TC17  ZERO COEFFICIENT
  //   coeff = 0 → b₀ = 0 → numerator = 0 → output always 0.
  // =========================================================================
  $display("\n--- Zero coefficient ---");
  do_reset();
  coeff     = 24'h000000;
  sign_en   = 1;
  filter_in = AMP;
  repeat(50) @(posedge clk);
  check_pass_fail("Zero coeff: output = 0 for any input",
                  ($signed(filter_out) === 32'sh0000_0000));
  $display("           Zero-coeff output: %0d (expect 0)", $signed(filter_out));
  coeff = COEFF_FC_0P001;   // restore

  // =========================================================================
  // TC18  clk_enable GATING
  //   When clk_enable=0, the filter state register must not update.
  // =========================================================================
  $display("\n--- clk_enable gating ---");
  do_reset();
  sign_en = 1;
  // Let filter settle with AMP for a few cycles
  filter_in = AMP;
  repeat(10) @(posedge clk);
  begin : tc18
    integer val_before, val_after;
    val_before = $signed(filter_out);
    // Hold clk_enable=0; state must freeze
    clk_enable = 0;
    filter_in  = 0;          // change input
    repeat(20) @(posedge clk);
    val_after  = $signed(filter_out);
    check_pass_fail("clk_enable=0: filter_out unchanged when gated",
                    (val_after === val_before));
    $display("           Before gate=%0d  After 20 gated cycles=%0d",
             val_before, val_after);
  end
  clk_enable = 1;

  // =========================================================================
  // TC19  Fc = 10× NOMINAL (coeff = COEFF_FC_0P01)
  //   Switch to Fc/Fs=0.01 coefficient.  At f = 0.001 (which was Fc in TC07,
  //   now f = Fc_new/10) the gain should drop below −16 dB (in the new
  //   stopband).  This confirms the Fc moves with the coefficient.
  //   n_settle=100 sufficient for a = −0.939 (settling ≈ 72 samples).
  // =========================================================================
  $display("\n--- Fc shift: coeff for Fc/Fs=0.01 ---");
  do_reset();
  coeff   = COEFF_FC_0P01;
  sign_en = 1;
  // f = 0.001 is now Fc/10 for this coeff (Fc/Fs = 0.01)
  run_sine_test(0.001, AMP, 100, 2000, ppos, pneg);
  get_gain_dB(ppos, pneg, AMP, gain_db);
  check_pass_fail("Fc×10 coeff: f=0.001*Fs now in stopband (gain < −16 dB)",
                  ((ppos - pneg)/2 < STOP_THRESH_16));
  $display("           f=0.001*Fs with Fc/Fs=0.01 coeff: amp=%0d  gain=%.2f dB",
           (ppos-pneg)/2, gain_db);
  // f = 0.1 should now be well in the passband (100×Fc)
  run_sine_test(0.1, AMP, 50, 200, ppos, pneg);
  get_gain_dB(ppos, pneg, AMP, gain_db);
  check_pass_fail("Fc×10 coeff: f=0.1*Fs in passband (gain > −1 dB)",
                  ((ppos - pneg)/2 > PASS_THRESH));
  $display("           f=0.1*Fs with Fc/Fs=0.01 coeff:  amp=%0d  gain=%.2f dB",
           (ppos-pneg)/2, gain_db);
  coeff = COEFF_FC_0P001;

  // =========================================================================
  // TC20  HIGH-Fc COEFFICIENT (coeff = COEFF_FC_0P1, Fc/Fs=0.1)
  //   Very fast settling (a ≈ −0.509, n_settle ≈ 7 samples).
  //   Test full frequency response at:  Fc/100, Fc/10, Fc, 10×Fc, Nyquist
  // =========================================================================
  $display("\n--- High-Fc coefficient (Fc/Fs=0.1) ---");
  coeff   = COEFF_FC_0P1;   // Fc/Fs = 0.1

  // f = 10×Fc = 1.0*Fs? No: Fc=0.1, so 10×Fc = 1.0 which is Nyquist×2 —
  // test at f = 0.4 (4×Fc) instead for well-in-passband.
  do_reset(); coeff = COEFF_FC_0P1; sign_en = 1;
  run_sine_test(0.4, AMP, 20, 200, ppos, pneg);
  get_gain_dB(ppos, pneg, AMP, gain_db);
  check_pass_fail("High-Fc: f=4*Fc passband gain > −1 dB",
                  ((ppos - pneg)/2 > PASS_THRESH));
  $display("           f=0.4*Fs (4*Fc): amp=%0d  gain=%.2f dB",
           (ppos-pneg)/2, gain_db);

  // f = Fc = 0.1: should be ≈ −3 dB  
  do_reset(); coeff = COEFF_FC_0P1; sign_en = 1;
  run_sine_test(0.1, AMP, 20, 100, ppos, pneg);
  get_gain_dB(ppos, pneg, AMP, gain_db);
  check_pass_fail("High-Fc: f=Fc gain in [−5 dB, −1 dB]",
                  ((ppos - pneg)/2 > FC_LOW_THRESH) &&
                  ((ppos - pneg)/2 < FC_HIGH_THRESH));
  $display("           f=Fc=0.1*Fs: amp=%0d  gain=%.2f dB  (target −3 dB)",
           (ppos-pneg)/2, gain_db);

  // f = Fc/10 = 0.01: should be below −16 dB
  do_reset(); coeff = COEFF_FC_0P1; sign_en = 1;
  run_sine_test(0.01, AMP, 20, 1000, ppos, pneg);
  get_gain_dB(ppos, pneg, AMP, gain_db);
  check_pass_fail("High-Fc: f=Fc/10 stopband gain < −16 dB",
                  ((ppos - pneg)/2 < STOP_THRESH_16));
  $display("           f=Fc/10=0.01*Fs: amp=%0d  gain=%.2f dB  (target ≈ −20 dB)",
           (ppos-pneg)/2, gain_db);

  // f = Fc/100 = 0.001: should be well below −34 dB
  do_reset(); coeff = COEFF_FC_0P1; sign_en = 1;
  run_sine_test(0.001, AMP, 20, 10000, ppos, pneg);
  get_gain_dB(ppos, pneg, AMP, gain_db);
  check_pass_fail("High-Fc: f=Fc/100 deep stopband gain < −34 dB",
                  ((ppos - pneg)/2 < STOP_THRESH_34));
  $display("           f=Fc/100=0.001*Fs: amp=%0d  gain=%.2f dB  (target ≈ −40 dB)",
           (ppos-pneg)/2, gain_db);

  coeff = COEFF_FC_0P001;   // restore default

  // =========================================================================
  // TC21  FREQUENCY SWEEP TABLE (using high-Fc coeff Fc/Fs=0.1 for speed)
  //   The normalised response shape is the same for all coefficients.
  //   This sweep characterises the 1st-order HPF's shape fully.
  // =========================================================================
  $display("\n--- Frequency sweep (Fc/Fs=0.1 coefficient) ---");
  $display("  %-12s %-12s %-12s %-12s", "freq/Fs", "out_amp", "gain_dB", "region");
  $display("  %-12s %-12s %-12s %-12s",
           "----------", "----------", "----------", "----------");
  coeff = COEFF_FC_0P1;   // Fc = 0.1 × Fs  (fast settling: n_settle=20)
  begin : sweep
    integer sp, sn, sa;
    real sg;

    // DC
    do_reset(); coeff = COEFF_FC_0P1; sign_en = 1;
    filter_in = AMP;
    repeat(1000) @(posedge clk);
    sp = $signed(filter_out); sn = sp;
    if (sp < 0) sa = -sp; else sa = sp;
    $display("  %-12s %-12d %-12s %-12s", "DC (0 Hz)", sa, "≈ -inf", "STOPBAND");

    // f = Fc/100 = 0.001
    do_reset(); coeff = COEFF_FC_0P1; sign_en = 1;
    run_sine_test(0.001, AMP, 20, 10000, sp, sn);
    get_gain_dB(sp, sn, AMP, sg);
    $display("  %-12.4f %-12d %-12.2f %-12s", 0.001, (sp-sn)/2, sg, "STOPBAND");

    // f = Fc/10 = 0.01
    do_reset(); coeff = COEFF_FC_0P1; sign_en = 1;
    run_sine_test(0.01,  AMP, 20, 1000, sp, sn);
    get_gain_dB(sp, sn, AMP, sg);
    $display("  %-12.4f %-12d %-12.2f %-12s", 0.01, (sp-sn)/2, sg, "STOPBAND");

    // f = Fc/3 ≈ 0.033
    do_reset(); coeff = COEFF_FC_0P1; sign_en = 1;
    run_sine_test(0.033, AMP, 20, 500, sp, sn);
    get_gain_dB(sp, sn, AMP, sg);
    $display("  %-12.4f %-12d %-12.2f %-12s", 0.033, (sp-sn)/2, sg, "BELOW Fc");

    // f = Fc = 0.1
    do_reset(); coeff = COEFF_FC_0P1; sign_en = 1;
    run_sine_test(0.1,   AMP, 20, 100, sp, sn);
    get_gain_dB(sp, sn, AMP, sg);
    $display("  %-12.4f %-12d %-12.2f %-12s", 0.1, (sp-sn)/2, sg, "Fc (−3 dB)");

    // f = 2×Fc = 0.2
    do_reset(); coeff = COEFF_FC_0P1; sign_en = 1;
    run_sine_test(0.2,   AMP, 20, 100, sp, sn);
    get_gain_dB(sp, sn, AMP, sg);
    $display("  %-12.4f %-12d %-12.2f %-12s", 0.2, (sp-sn)/2, sg, "ABOVE Fc");

    // f = 0.3
    do_reset(); coeff = COEFF_FC_0P1; sign_en = 1;
    run_sine_test(0.3,   AMP, 20, 100, sp, sn);
    get_gain_dB(sp, sn, AMP, sg);
    $display("  %-12.4f %-12d %-12.2f %-12s", 0.3, (sp-sn)/2, sg, "PASSBAND");

    // f = 0.4
    do_reset(); coeff = COEFF_FC_0P1; sign_en = 1;
    run_sine_test(0.4,   AMP, 20, 200, sp, sn);
    get_gain_dB(sp, sn, AMP, sg);
    $display("  %-12.4f %-12d %-12.2f %-12s", 0.4, (sp-sn)/2, sg, "PASSBAND");

    // Nyquist-ε = 0.499
    do_reset(); coeff = COEFF_FC_0P1; sign_en = 1;
    run_sine_test(0.499, AMP, 20, 200, sp, sn);
    get_gain_dB(sp, sn, AMP, sg);
    $display("  %-12.4f %-12d %-12.2f %-12s", 0.499, (sp-sn)/2, sg, "NYQUIST");

    tc_num++;
    pass_count++;
    $display("  [INFO] TC%02d: Frequency sweep complete", tc_num);
  end
  coeff = COEFF_FC_0P001;

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
    $display(" OVERALL: FAIL  ← see [FAIL] lines above");
  $display("=================================================================");
  $display("");

  #100;
  $finish;
end

// ---------------------------------------------------------------------------
// Simulation timeout watchdog (5 ms should be plenty)
// ---------------------------------------------------------------------------
initial begin
  #5_000_000;
  $display("ERROR: Simulation timeout after 5 ms!");
  $finish;
end

endmodule
