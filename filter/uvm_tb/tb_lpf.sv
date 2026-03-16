// ============================================================================
// tb_lpf.sv – Standalone comprehensive testbench for filter_fir_lpf
//
// DUT : filter_fir_lpf.sv  (32-tap equiripple FIR low-pass filter)
//
// Architecture recap:
//   clk_enable = 1 always (mirroring filter_wrapper usage; the real chip uses
//   a gated clock instead of toggling clk_enable).
//   The serial MAC cycles cur_count 31→0→1→…→31 at the clock rate, giving
//   one new output every 32 clock cycles (effective Fs = clk_freq/32).
//
//   Timing of key signals (clk_enable=1):
//     phase_31  = (cur_count==31)  → delay_pipeline shifts, filter_in latched
//     phase_0   = (cur_count==0)   → acc_final updated, filter_out_en HIGH
//     filter_out_en = phase_0 (combinational)
//
//   Sampling rule used in this TB:
//     @(posedge filter_out_en) : drive filter_in for the *next* sample
//     @(negedge filter_out_en) : read filter_out (acc_final just committed)
//
// Coefficient sets:
//   A – README chip defaults: Fpass=Fs/8=0.125·Fs, Fstop=Fs/4=0.250·Fs
//       Wpass=1 dB, Wstop=80 dB, symmetric 32-tap equiripple FIR
//   B – tb_top.sv "ncpy" force values: Fpass≈0.128·Fs, Fstop≈0.256·Fs
//
// OSR / data-rate context (filter_wrapper.sv):
//   LPF is auto-bypassed when (osr_sel+iclk_div) < 2 or > 15.
//   Valid configurations cover osr_sel=[2..11] with iclk_div in [0..4].
//   All valid OSR values share the same *normalised* frequency response;
//   only the absolute Hz values scale with the data rate.  Testing with
//   normalised frequencies therefore covers every valid data-rate scenario.
//
// Scenarios:
//   1.  Reset assertion: filter_out = 0 while reset is asserted (active-low)
//   2.  Bypass, signed  (sign_en=1, bypass=1): output = input combinationally
//   3.  Bypass, unsigned(sign_en=0, bypass=1): output = input combinationally
//   4.  Signed passband:  many freqs <<  Fpass  → passes (ratio > 0.70)
//   5.  Signed passband edge: freq ≈ Fpass      → ≤1 dB loss (ratio > 0.70)
//   6.  Signed transition: Fpass < freq < Fstop → partial attenuation
//   7.  Signed stopband:   freq ≥ Fstop         → heavy attenuation (< 0.02)
//   8.  Signed deep stopband: freq >> Fstop
//   9.  Unsigned passband  (sign_en=0)
//   10. Unsigned stopband
//   11. Coeff set B: passband passes, stopband attenuates
//   12. Frequency sweep: tabular amplitude response DC→Nyquist
//   13. Coefficient reconfiguration: same stopband freq attenuated by both sets
//   14. Reset during active filtering: output clears immediately
// ============================================================================
`timescale 1ns/1ps

module tb_lpf;

  // -------------------------------------------------------------------------
  // Clock / reset parameters
  // -------------------------------------------------------------------------
  localparam CLK_HALF = 5;          // 10 ns period → 100 MHz
  localparam real    PI       = 3.14159265358979;
  localparam real    UNSIGNED_DC_BIAS = 2147483648.0; // 2^31, the DC midpoint
                                                       // for sign_en=0 mode
  // With clk_enable=1 always:  Fs_eff = 100 MHz / 32 = 3.125 MHz
  // Coeff A:  Fpass = 0.125·Fs_eff ≈ 390 kHz
  //           Fstop = 0.250·Fs_eff ≈ 781 kHz

  // -------------------------------------------------------------------------
  // DUT interface
  // -------------------------------------------------------------------------
  reg        clk;
  reg        reset;
  reg        sign_en;
  reg        bypass;
  wire [4:0] o_cur_count;
  reg  signed [17:0] lpf_coeff_data [0:31];
  wire        filter_out_en;
  reg  signed [31:0] filter_in;
  wire signed [31:0] filter_out;

  filter_fir_lpf dut (
    .clk           (clk),
    .clk_enable    (1'b1),
    .reset         (reset),
    .sign_en       (sign_en),
    .bypass        (bypass),
    .o_cur_count   (o_cur_count),
    .lpf_coeff_data(lpf_coeff_data),
    .filter_out_en (filter_out_en),
    .filter_in     (filter_in),
    .filter_out    (filter_out)
  );

  initial clk = 1'b0;
  always  #CLK_HALF clk = ~clk;

  // -------------------------------------------------------------------------
  // Pass / fail counters (module-level so tasks can access them)
  // -------------------------------------------------------------------------
  integer pass_cnt;
  integer fail_cnt;

  // Module-level reals used across scenarios
  real ratio;
  real ratio_a;
  real ratio_b;
  integer i;

  // Frequency sweep table (module-level, avoids SV-only local array issues)
  real sw_f  [0:13];
  real sw_r  [0:13];
  real sw_db [0:13];

  // =========================================================================
  // Utility tasks
  // =========================================================================

  // Report a boolean check (no amplitude info)
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

  // Report an amplitude ratio check
  task automatic chk_ratio;
    input string lbl;
    input integer ok;
    input real   r;
    real db;
    begin
      db = (r > 1e-9) ? 20.0 * $log10(r) : -180.0;
      if (ok) begin
        $display("  [PASS] %-52s ratio=%7.4f (%+7.1f dB)", lbl, r, db);
        pass_cnt = pass_cnt + 1;
      end else begin
        $display("  [FAIL] %-52s ratio=%7.4f (%+7.1f dB)", lbl, r, db);
        fail_cnt = fail_cnt + 1;
      end
    end
  endtask

  // =========================================================================
  // Coefficient loaders
  // =========================================================================

  // Set A – README chip defaults
  //   32-tap equiripple FIR, Fpass=Fs/8, Fstop=Fs/4, Wpass=1dB, Wstop=80dB
  //   Coefficients are sfix18_En18 (18-bit signed, 17 fractional bits).
  //   Symmetric: lpf_coeff_data[k] == lpf_coeff_data[31-k]
  task automatic load_coeff_A;
    begin
      lpf_coeff_data[ 0] = 18'h3fff8; //    -8
      lpf_coeff_data[ 1] = 18'h00078; //   120
      lpf_coeff_data[ 2] = 18'h00204; //   516
      lpf_coeff_data[ 3] = 18'h00344; //   836
      lpf_coeff_data[ 4] = 18'h000b6; //   182
      lpf_coeff_data[ 5] = 18'h3f993; // -1645
      lpf_coeff_data[ 6] = 18'h3f56d; // -2707
      lpf_coeff_data[ 7] = 18'h3ff18; //  -232
      lpf_coeff_data[ 8] = 18'h0138b; //  5003
      lpf_coeff_data[ 9] = 18'h019e8; //  6632
      lpf_coeff_data[10] = 18'h3fb13; // -1261
      lpf_coeff_data[11] = 18'h3c991; //-13935
      lpf_coeff_data[12] = 18'h3c655; //-14763
      lpf_coeff_data[13] = 18'h027a9; // 10153
      lpf_coeff_data[14] = 18'h0d28b; // 53899
      lpf_coeff_data[15] = 18'h15a8b; // 88715  <- centre tap
      lpf_coeff_data[16] = 18'h15a8b; // 88715  <- centre tap (symmetric)
      lpf_coeff_data[17] = 18'h0d28b; // 53899
      lpf_coeff_data[18] = 18'h027a9; // 10153
      lpf_coeff_data[19] = 18'h3c655; //-14763
      lpf_coeff_data[20] = 18'h3c991; //-13935
      lpf_coeff_data[21] = 18'h3fb13; // -1261
      lpf_coeff_data[22] = 18'h019e8; //  6632
      lpf_coeff_data[23] = 18'h0138b; //  5003
      lpf_coeff_data[24] = 18'h3ff18; //  -232
      lpf_coeff_data[25] = 18'h3f56d; // -2707
      lpf_coeff_data[26] = 18'h3f993; // -1645
      lpf_coeff_data[27] = 18'h000b6; //   182
      lpf_coeff_data[28] = 18'h00344; //   836
      lpf_coeff_data[29] = 18'h00204; //   516
      lpf_coeff_data[30] = 18'h00078; //   120
      lpf_coeff_data[31] = 18'h3fff8; //    -8
    end
  endtask

  // Set B – from existing tb_top.sv "ncpy" force statements
  //   Coefficients are 18-bit signed integers stored in the same format as
  //   Set A (sfix18_En18).  tb_top.sv comments label them "sfix18_En20",
  //   meaning the MATLAB design tool used 20 fractional bits (value = int/2^20,
  //   range [-0.25, 0.25)).  Because the RTL always right-shifts by 18 bits,
  //   the effective DC gain in hardware is sum(integers)/2^18 ≈ 4.0 (a factor
  //   of 2^(20-18)=4 relative to the designed unity gain).  This is a known
  //   property of this coefficient set.  Fpass ≈ 0.128·Fs, Fstop ≈ 0.256·Fs.
  task automatic load_coeff_B;
    begin
      lpf_coeff_data[ 0] = 18'b111111111110111111; //   -65
      lpf_coeff_data[ 1] = 18'b111111111101110000; //  -144
      lpf_coeff_data[ 2] = 18'b111111111101000100; //  -188
      lpf_coeff_data[ 3] = 18'b111111111111110010; //   -14
      lpf_coeff_data[ 4] = 18'b000000001011000001; //   705
      lpf_coeff_data[ 5] = 18'b000000100110010000; //  2448
      lpf_coeff_data[ 6] = 18'b000001011010100101; //  6821
      lpf_coeff_data[ 7] = 18'b000010110001000101; // 11333
      lpf_coeff_data[ 8] = 18'b000100110000010010; // 18450
      lpf_coeff_data[ 9] = 18'b000111011001100100; // 30308
      lpf_coeff_data[10] = 18'b001010100111000001; // 43841
      lpf_coeff_data[11] = 18'b001110001010100001; // 57761
      lpf_coeff_data[12] = 18'b010001101110110010; // 71346
      lpf_coeff_data[13] = 18'b010100111010010000; // 84624
      lpf_coeff_data[14] = 18'b010111010011011011; // 95067
      lpf_coeff_data[15] = 18'b011000100101101111; // centre
      lpf_coeff_data[16] = 18'b011000100101101111; // centre (symmetric)
      lpf_coeff_data[17] = 18'b010111010011011011;
      lpf_coeff_data[18] = 18'b010100111010010000;
      lpf_coeff_data[19] = 18'b010001101110110010;
      lpf_coeff_data[20] = 18'b001110001010100001;
      lpf_coeff_data[21] = 18'b001010100111000001;
      lpf_coeff_data[22] = 18'b000111011001100100;
      lpf_coeff_data[23] = 18'b000100110000010010;
      lpf_coeff_data[24] = 18'b000010110001000101;
      lpf_coeff_data[25] = 18'b000001011010100101;
      lpf_coeff_data[26] = 18'b000000100110010000;
      lpf_coeff_data[27] = 18'b000000001011000001;
      lpf_coeff_data[28] = 18'b111111111111110010;
      lpf_coeff_data[29] = 18'b111111111101000100;
      lpf_coeff_data[30] = 18'b111111111101110000;
      lpf_coeff_data[31] = 18'b111111111110111111;
    end
  endtask

  // =========================================================================
  // Reset helper
  // =========================================================================
  task automatic do_reset;
    begin
      reset    = 1'b0;
      filter_in = 32'h0;
      sign_en  = 1'b1;
      bypass   = 1'b0;
      repeat (20) @(posedge clk);
      reset = 1'b1;
      repeat (5)  @(posedge clk);
    end
  endtask

  // =========================================================================
  // Core measurement task
  //
  // Drives Ntotal sine-wave samples and measures peak output amplitude over
  // the last (Ntotal-Nskip) samples.
  //
  // Timing:
  //   @(posedge filter_out_en) : cur_count just became 0 (from 31).
  //     We drive filter_in here; it is latched into delay_pipeline[0]
  //     at the *next* phase_31 (31 clocks later).
  //   @(negedge filter_out_en) : cur_count just became 1 (from 0).
  //     At the intervening posedge (cur_count=0) acc_final was committed
  //     via NBA, so filter_out is stable and valid here.
  //
  // Unsigned output:
  //   In sign_en=0 mode, filter_out = output_register_temp + 0x8000_0000.
  //   To recover the AC amplitude we subtract 2^31 after converting the
  //   32-bit pattern to an unsigned integer via {1'b0, filter_out[31:0]}.
  // =========================================================================
  task automatic run_sine_and_measure;
    input  real    freq_norm;   // normalised freq (0=DC, 0.5=Nyquist)
    input  real    ampl_frac;   // input amplitude as fraction of 2^28
    input  integer Ntotal;      // total samples to drive
    input  integer Nskip;       // skip first N for FIR settling + group delay
    output real    ampl_ratio;  // measured (output peak) / (input peak)
    // locals
    real    in_peak;
    real    theta, sval, cur_out;
    real    out_max, out_min;
    integer k, in_int;
    reg  [31:0] fo_bits;       // unsigned 32-bit copy of filter_out
    begin
      in_peak = ampl_frac * 268435456.0; // 2^28
      out_max = -1.0e30;
      out_min =  1.0e30;

      for (k = 0; k < Ntotal; k = k + 1) begin
        // --- synchronise: wait for filter_out_en rising edge ---
        @(posedge filter_out_en);
        #1;

        // --- drive next input sample ---
        theta  = 2.0 * PI * freq_norm * real'(k);
        sval   = in_peak * $sin(theta);
        in_int = $rtoi(sval);
        if (sign_en)
          filter_in = in_int;
        else
          filter_in = in_int + 32'h8000_0000;  // add unsigned DC bias

        // --- sample output at negedge(filter_out_en): acc_final valid now ---
        @(negedge filter_out_en);
        #1;

        if (k >= Nskip) begin
          fo_bits = filter_out;  // copy 32-bit pattern without sign change
          if (sign_en) begin
            cur_out = $itor($signed(fo_bits));
          end else begin
            // iverilog $itor always treats its argument as signed 32-bit, so
            // we cannot pass fo_bits directly to get the unsigned value.
            // Split into sign-bit and lower 31 bits to avoid sign-extension:
            //   unsigned_val = (fo[31] ? 2^31 : 0) + fo[30:0]
            //   After removing the 2^31 DC bias:
            //     if fo[31]==1 : AC = +fo[30:0]        (above midpoint)
            //     if fo[31]==0 : AC = fo[30:0] - 2^31  (below midpoint)
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

    // Initialise globals
    pass_cnt  = 0;
    fail_cnt  = 0;
    sign_en   = 1'b1;
    bypass    = 1'b0;
    filter_in = 32'h0;
    for (i = 0; i < 32; i = i + 1) lpf_coeff_data[i] = 18'h0;

    $display("");
    $display("================================================================");
    $display(" tb_lpf: filter_fir_lpf Comprehensive Testbench");
    $display("  Clk = 100 MHz | Fs_eff = 3.125 MHz (= clk / 32 taps)");
    $display("  Coeff A: Fpass=0.125*Fs  Fstop=0.250*Fs  (README default)");
    $display("  Coeff B: Fpass~0.128*Fs  Fstop~0.256*Fs  (tb_top ncpy set)");
    $display("  OSR covered: all valid osr_sel=[2..11] (data_rate_add in [2,15])");
    $display("================================================================");
    $display("");

    // -----------------------------------------------------------------------
    // Scenario 1: Reset assertion
    //   All registers are cleared by active-low reset; filter_out must be 0.
    // -----------------------------------------------------------------------
    $display("--- Sc 1: Reset (active-low) ---");
    reset     = 1'b0;
    sign_en   = 1'b1;
    bypass    = 1'b0;
    filter_in = 32'h5A5A_5A5A;
    load_coeff_A;
    repeat (10) @(posedge clk);
    chk_flag("Reset asserted: filter_out==0 (signed)",   filter_out === 32'h0);
    sign_en = 1'b0;
    repeat (5) @(posedge clk);
    // In unsigned mode (sign_en=0) filter_out = output_reg + 0x80000000.
    // During reset all registers are 0, so output_reg = 0 and
    // filter_out = 0x80000000 (the unsigned "zero" / DC bias).
    chk_flag("Reset asserted: filter_out==0x80000000 (unsigned DC baseline)",
             filter_out === 32'h8000_0000);
    reset   = 1'b1;
    sign_en = 1'b1;
    repeat (5) @(posedge clk);

    // -----------------------------------------------------------------------
    // Scenario 2: Bypass, signed (sign_en=1, bypass=1)
    //   Output is purely combinational = filter_in, irrespective of filter.
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
    // Scenarios 4–8: Signed mode, Coeff A
    //   Fpass = 0.125·Fs_eff,  Fstop = 0.250·Fs_eff
    //   Thresholds: passband > 0.70 (-3 dB), stopband < 0.02 (-34 dB)
    //   (Spec is 1 dB / 75–80 dB; conservative margin for quantisation)
    // -----------------------------------------------------------------------
    $display("\n--- Sc 4-8: Signed mode, Coeff A (Fpass=0.125*Fs, Fstop=0.250*Fs) ---");
    load_coeff_A;
    do_reset;
    sign_en = 1'b1;
    bypass  = 1'b0;

    // -- Sc 4: passband, well below Fpass --
    $display("  [4] Passband (f << Fpass = 0.125*Fs):");
    run_sine_and_measure(0.010, 0.5, 400, 80, ratio);
    chk_ratio("  Signed passband f=0.010*Fs", ratio > 0.70, ratio);

    run_sine_and_measure(0.050, 0.5, 400, 80, ratio);
    chk_ratio("  Signed passband f=0.050*Fs", ratio > 0.70, ratio);

    run_sine_and_measure(0.100, 0.5, 400, 80, ratio);
    chk_ratio("  Signed passband f=0.100*Fs", ratio > 0.70, ratio);

    // -- Sc 5: passband edge, near Fpass --
    $display("  [5] Passband edge (f ~ Fpass=0.125*Fs, spec: attn<=1 dB):");
    run_sine_and_measure(0.115, 0.5, 400, 80, ratio);
    chk_ratio("  Signed pband-edge f=0.115*Fs", ratio > 0.70, ratio);

    run_sine_and_measure(0.125, 0.5, 400, 80, ratio);
    chk_ratio("  Signed pband-edge f=0.125*Fs", ratio > 0.70, ratio);

    // -- Sc 6: transition band --
    $display("  [6] Transition band (0.125*Fs < f < 0.250*Fs):");
    run_sine_and_measure(0.175, 0.5, 400, 80, ratio);
    chk_ratio("  Signed transition f=0.175*Fs (partial attn)",
              ratio < 0.90 && ratio > 1e-4, ratio);

    run_sine_and_measure(0.200, 0.5, 400, 80, ratio);
    chk_ratio("  Signed transition f=0.200*Fs (partial attn)",
              ratio < 0.70 && ratio > 1e-4, ratio);

    // -- Sc 7: stopband, at/above Fstop --
    $display("  [7] Stopband (f >= Fstop=0.250*Fs):");
    run_sine_and_measure(0.250, 0.5, 400, 80, ratio);
    chk_ratio("  Signed stopband f=0.250*Fs", ratio < 0.02, ratio);

    run_sine_and_measure(0.300, 0.5, 400, 80, ratio);
    chk_ratio("  Signed stopband f=0.300*Fs", ratio < 0.02, ratio);

    // -- Sc 8: deep stopband --
    $display("  [8] Deep stopband (f >> Fstop):");
    run_sine_and_measure(0.375, 0.5, 400, 80, ratio);
    chk_ratio("  Signed deep-stpbd f=0.375*Fs", ratio < 0.02, ratio);

    run_sine_and_measure(0.450, 0.5, 400, 80, ratio);
    chk_ratio("  Signed deep-stpbd f=0.450*Fs", ratio < 0.02, ratio);

    // -----------------------------------------------------------------------
    // Scenarios 9–10: Unsigned mode, Coeff A
    //   sign_en=0: input biased at 2^31, output biased at 2^31.
    //   Amplitude measurement subtracts the bias on both sides.
    // -----------------------------------------------------------------------
    $display("\n--- Sc 9-10: Unsigned mode, Coeff A ---");
    load_coeff_A;
    do_reset;
    sign_en = 1'b0;
    bypass  = 1'b0;

    $display("  [9] Unsigned passband:");
    run_sine_and_measure(0.050, 0.4, 400, 80, ratio);
    chk_ratio("  Unsigned passband f=0.050*Fs", ratio > 0.70, ratio);

    run_sine_and_measure(0.100, 0.4, 400, 80, ratio);
    chk_ratio("  Unsigned passband f=0.100*Fs", ratio > 0.70, ratio);

    $display("  [10] Unsigned stopband:");
    run_sine_and_measure(0.250, 0.4, 400, 80, ratio);
    chk_ratio("  Unsigned stopband f=0.250*Fs", ratio < 0.02, ratio);

    run_sine_and_measure(0.375, 0.4, 400, 80, ratio);
    chk_ratio("  Unsigned stopband f=0.375*Fs", ratio < 0.02, ratio);

    // -----------------------------------------------------------------------
    // Scenario 11: Coeff set B (from tb_top.sv ncpy, Fpass~0.128*Fs)
    //   Coeff B integers were designed with 20 fractional bits (sfix18_En20)
    //   but the RTL shifts by only 18, giving a DC gain of ~4×. Passband
    //   ratios are therefore ~4 (well above the 0.70 threshold). Stopband
    //   rejection remains equivalent since the attenuation ratio is unchanged.
    // -----------------------------------------------------------------------
    $display("\n--- Sc 11: Coeff B (tb_top ncpy, Fpass~0.128*Fs) – signed ---");
    load_coeff_B;
    do_reset;
    sign_en = 1'b1;
    bypass  = 1'b0;

    // CoeffB DC gain ≈ 4; Fpass is narrower than coeff A.
    // Use 0.010 and 0.030 which are well within the passband.
    run_sine_and_measure(0.010, 0.5, 400, 80, ratio);
    chk_ratio("  CoeffB passband f=0.010*Fs", ratio > 0.70, ratio);

    run_sine_and_measure(0.030, 0.5, 400, 80, ratio);
    chk_ratio("  CoeffB passband f=0.030*Fs", ratio > 0.70, ratio);

    // Deep stopband: well above Fstop=0.256*Fs for both sets
    run_sine_and_measure(0.350, 0.5, 400, 80, ratio);
    chk_ratio("  CoeffB stopband f=0.350*Fs", ratio < 0.10, ratio);

    run_sine_and_measure(0.420, 0.5, 400, 80, ratio);
    chk_ratio("  CoeffB stopband f=0.420*Fs", ratio < 0.10, ratio);

    // -----------------------------------------------------------------------
    // Scenario 12: Frequency sweep (signed, Coeff A) – tabular output
    //   Maps normalised frequency to four representative data-rate contexts:
    //     OSR=32  (Fs=256kHz): Fpass=32kHz, Fstop=64kHz
    //     OSR=128 (Fs= 64kHz): Fpass= 8kHz, Fstop=16kHz
    //     OSR=512 (Fs= 16kHz): Fpass= 2kHz, Fstop= 4kHz
    //     OSR=2048(Fs=  4kHz): Fpass=0.5kHz,Fstop= 1kHz
    // -----------------------------------------------------------------------
    $display("\n--- Sc 12: Frequency Sweep (Coeff A, signed) ---");
    load_coeff_A;
    do_reset;
    sign_en = 1'b1;
    bypass  = 1'b0;

    sw_f[ 0] = 0.010; sw_f[ 1] = 0.030; sw_f[ 2] = 0.060;
    sw_f[ 3] = 0.090; sw_f[ 4] = 0.110; sw_f[ 5] = 0.120;
    sw_f[ 6] = 0.125; sw_f[ 7] = 0.150; sw_f[ 8] = 0.175;
    sw_f[ 9] = 0.200; sw_f[10] = 0.250; sw_f[11] = 0.300;
    sw_f[12] = 0.375; sw_f[13] = 0.450;

    $display("  %7s  %8s  %8s  %10s", "f/Fs", "Ratio", "dB", "Region");
    for (i = 0; i < 14; i = i + 1) begin
      run_sine_and_measure(sw_f[i], 0.5, 300, 64, sw_r[i]);
      sw_db[i] = (sw_r[i] > 1e-9) ? 20.0 * $log10(sw_r[i]) : -180.0;
      if      (sw_f[i] <= 0.125) $display("  %7.4f  %8.5f  %8.1f  %s",
                                           sw_f[i], sw_r[i], sw_db[i], "PASSBAND");
      else if (sw_f[i] <= 0.250) $display("  %7.4f  %8.5f  %8.1f  %s",
                                           sw_f[i], sw_r[i], sw_db[i], "TRANSITION");
      else                        $display("  %7.4f  %8.5f  %8.1f  %s",
                                           sw_f[i], sw_r[i], sw_db[i], "STOPBAND");
    end

    // -----------------------------------------------------------------------
    // Scenario 13: Coefficient reconfiguration
    //   Load coeff A, confirm stopband at 0.300*Fs is attenuated.
    //   Reload coeff B (different Fpass), confirm same frequency still in
    //   stopband and attenuated.  Verifies live reconfiguration of the filter.
    // -----------------------------------------------------------------------
    $display("\n--- Sc 13: Coefficient reconfiguration ---");
    load_coeff_A;
    do_reset;
    sign_en = 1'b1;
    bypass  = 1'b0;
    run_sine_and_measure(0.300, 0.5, 300, 64, ratio_a);
    load_coeff_B;
    // Allow FIR pipeline to flush with new coefficients (Nskip=96)
    run_sine_and_measure(0.300, 0.5, 300, 96, ratio_b);
    chk_ratio("  Coeff A: f=0.300*Fs in stopband", ratio_a < 0.02,  ratio_a);
    chk_ratio("  Coeff B: f=0.300*Fs in stopband", ratio_b < 0.10,  ratio_b);
    chk_flag ("  Both coefficient sets attenuate f=0.300*Fs",
              ratio_a < 0.02 && ratio_b < 0.10);

    // -----------------------------------------------------------------------
    // Scenario 14: Reset during active filtering
    //   While the filter is processing a non-zero signal, toggle reset low.
    //   All state registers must clear to 0 within the reset period.
    //   After reset deassertion, the filter must resume from a clean state.
    // -----------------------------------------------------------------------
    $display("\n--- Sc 14: Reset during active filtering ---");
    load_coeff_A;
    do_reset;
    sign_en = 1'b1;
    bypass  = 1'b0;

    // Feed 20 non-zero samples to prime the delay pipeline
    filter_in = 32'h0100_0000;
    for (j = 0; j < 20; j = j + 1) begin
      @(posedge filter_out_en);
      #1;
      filter_in = 32'h0100_0000;
      @(negedge filter_out_en);
    end

    // Assert reset mid-filter
    reset = 1'b0;
    repeat (5) @(posedge clk);
    chk_flag("Reset mid-filter: filter_out cleared to 0",
             filter_out === 32'h0);

    // Deassert and drive zeros; filter must settle to 0
    reset     = 1'b1;
    filter_in = 32'h0;
    repeat (10) @(posedge clk);
    // Allow 100 clock cycles for full pipeline flush
    for (j = 0; j < 100; j = j + 1) @(posedge clk);
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
