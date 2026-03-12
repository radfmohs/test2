`timescale 1ns/1ps
`default_nettype none

module tb_hpf_dyadic_leak;

  // ---------------- Plusargs ----------------
  string MODE_str = "SINE";   // "SINE" or "SQUARE"
  real   FS_HZ    = 256_000.0;
  real   FREQ_HZ  = 100.0;
  real   AMP      = 0.9;
  int    M        = 82;
  int    K        = 25;
  real   SIM_TIME_S = 0.02;

  // Derived
  int  MODE_SEL;            // 0=SINE, 1=SQUARE
  real clk_period_ns;       // ns
  int  halfP_i;             // integer half-period for SQUARE (>=1)

  // Clock/reset
  logic clk = 1'b0;
  logic reset = 1'b1, clk_enable = 1'b1;

  // DUT I/O
  localparam int IN_WIDTH    = 32;  // Q1.31
  localparam int STATE_WIDTH = 48;
  localparam int M_BITS      = 8;

  logic signed [IN_WIDTH-1:0] filter_in;
  logic signed [IN_WIDTH-1:0] filter_out;

  logic [M_BITS-1:0] m_cfg;
  logic [7:0]        K_cfg;

  // Read plusargs
  initial begin
    real r; int i; string s;
    if ($value$plusargs("MODE=%s", s))      MODE_str = s;
    if ($value$plusargs("FS_HZ=%f", r))     FS_HZ    = r;
    if ($value$plusargs("FREQ_HZ=%f", r))   FREQ_HZ  = r;
    if ($value$plusargs("AMP=%f", r))       AMP      = r;
    if ($value$plusargs("SIM_TIME_S=%f", r))SIM_TIME_S = r;
    if ($value$plusargs("M=%d", i))         M        = i;
    if ($value$plusargs("K=%d", i))         K        = i;

    MODE_SEL = (MODE_str == "SQUARE") ? 1 : 0;
    clk_period_ns = 1.0e9 / FS_HZ;

    if (MODE_SEL == 1) begin
      real hp = FS_HZ / (FREQ_HZ * 2.0);
      halfP_i = (hp < 1.0) ? 1 : $rtoi(hp + 0.5); // robust rounding
      $display("DBG half-period: Fs=%0.3f Hz  F=%0.3f Hz  hp(real)=%0.6f  halfP_i=%0d",
               FS_HZ, FREQ_HZ, hp, halfP_i);
    end else begin
      halfP_i = 1;
    end

    $display("--------------------------------------------------------------------------------");
    $display(" TB: MODE=%s  Fs=%0.f  F=%0.f  Amp=%.6f  m=%0d  K=%0d  T=%.3f  halfP_i=%0d",
             MODE_str, FS_HZ, FREQ_HZ, AMP, M, K, SIM_TIME_S, halfP_i);
    $display("--------------------------------------------------------------------------------");
  end

  // Clock
  always #(clk_period_ns/2.0) clk = ~clk;

  // Reset (no repeat/empty stmt warnings)
  int rst_count = 0;
  always @(posedge clk) begin
    if (rst_count < 8) begin
      reset     <= 1'b1;
      rst_count <= rst_count + 1;
    end else begin
      reset <= 1'b0;
    end
  end

  // DUT wiring
  always @* begin
    m_cfg = (M <= 0) ? 8'd1 : M[M_BITS-1:0];
    K_cfg = (K < 1) ? 8'd1 :
            (K > (STATE_WIDTH-1)) ? (STATE_WIDTH-1) : K[7:0];
  end

  hpf_dyadic_leak #(
    .IN_WIDTH    (IN_WIDTH),
    .STATE_WIDTH (STATE_WIDTH),
    .M_BITS      (M_BITS)
  ) dut (
    .clk         (clk),
    .clk_enable  (clk_enable),
    .reset       (reset),
    .m           (m_cfg),
    .K           (K_cfg),
    .filter_in   (filter_in),
    .filter_out  (filter_out)
  );

  // Helpers
  // ---- Helpers (keep as-is) ----
  function automatic int signed real_to_q31 (input real x);
    real xr; int signed q;
    begin
      xr = (x > (1.0 - (1.0/2147483648.0))) ? (1.0 - (1.0/2147483648.0)) :
           (x < -1.0) ? -1.0 : x;
      q  = $rtoi(xr * 2147483648.0);
      return q;
    end
  endfunction

  localparam int signed Q31_POS_HALF = 32'sh4000_0000;  // +0.5
  localparam int signed Q31_NEG_HALF = -32'sh4000_0000; // -0.5

  // ---- NEW: phase-accumulated sine ----
  real phase, phase_inc;   // radians
  localparam real TWO_PI = 6.28318530717958647693;

  // Compute once, after plusargs read:
  initial begin
    // ... (your existing plusargs and halfP_i calc)
    phase     = 0.0;
    phase_inc = TWO_PI * (FREQ_HZ / FS_HZ);  // radians per sample
    $display("DBG sine: Fs=%0.3f  F=%0.3f  phase_inc=%0.9f rad/sample", FS_HZ, FREQ_HZ, phase_inc);
  end

  // ---- State for square ----
  longint n = 0;
  int      sq_cnt = 0;
  bit      sq_pol = 0;

  // ---- Stimulus: drives EVERY clock ----
  always @(posedge clk) begin
    if (reset) begin
      n         <= 0;
      sq_cnt    <= 0;
      sq_pol    <= 0;
      filter_in <= 32'sd0;                 // start at 0 during reset
      phase     <= 0.0;                    // reset sine phase
    end else if (clk_enable) begin
      if (MODE_SEL == 1) begin
        // SQUARE (integer, deterministic)
        filter_in <= (sq_pol ? Q31_POS_HALF : Q31_NEG_HALF);
        if (sq_cnt == (halfP_i-1)) begin
          sq_cnt <= 0;
          sq_pol <= ~sq_pol;
        end else begin
          sq_cnt <= sq_cnt + 1;
        end
      end else begin
        // SINE (phase accumulator -> robust in VCS)
        phase = phase + phase_inc;
        if (phase >= TWO_PI) phase = phase - TWO_PI;  // wrap
        filter_in <= real_to_q31( AMP * $sin(phase) );
      end
      n <= n + 1;
    end
  end

  // Print first N samples
  int printed = 0;
  always @(posedge clk) if (!reset && clk_enable && printed < 32) begin
    printed += 1;
    $display("SMP n=%0d  in=%0d  out=%0d  (sq_cnt=%0d sq_pol=%0d)", n, filter_in, filter_out, sq_cnt, sq_pol);
  end

  // FSDB dump
  initial begin
    $fsdbDumpfile("waves.fsdb");
    $fsdbDumpvars(0, tb_hpf_dyadic_leak);
  end

  // Finish
  initial begin
    #(SIM_TIME_S * 1.0e9);
    $display("SIM DONE");
    $finish;
  end

endmodule

