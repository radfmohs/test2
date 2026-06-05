//==============================================================================
// Standalone testbench for the IMEAS sinc(CIC) -> HPF -> Notch -> LPF datapath
//
// Drives a 1-bit sigma-delta (SDM) bitstream, generated from a multi-tone
// analog signal, into imeas (the on-chip sinc/CIC decimator) and through the
// HPF / Notch / LPF chain inside filter_wrapper (the per-channel core that
// imeas_wrapper replicates 16x). Captures the decimated sinc-only output
// (chdata) and the final filtered output (imeas_chdata_out) for offline FFT
// analysis.
//
// All filter coefficients are the exact production defaults taken from
// spi_slave/rtl/spi_reg.sv (coeff_data_def + the notch/lpf/hpf mapping).
//
// Configurable via plusargs:
//   +DR=<n>          CIC decimation select (OSR = 2^(DR+3)); default 5 -> OSR 256
//   +NOTCH_BYP=<0|1> bypass notch  (default 1)
//   +LPF_BYP=<0|1>   bypass LPF    (default 1)
//   +HPF_BYP=<0|1>   bypass HPF    (default 1)
//   +NCAP=<n>        number of decimated output samples to capture (default 2560)
//   +ADC_FS=<hz>     SDM oversample rate in Hz used for tone math (default 512000)
//   +TONES=<file>    input tone list "freq amp phase" per line (default tones.txt)
//   +OUT=<file>      output dump "idx sinc filtered" (default out.txt)
//==============================================================================
`timescale 1ns/1ps

module tb_filter_chain;

  localparam DATA_WIDTH = 24;

  // ---- plusarg-configurable parameters -------------------------------------
  integer DR_arg;
  integer notch_byp_arg, lpf_byp_arg, hpf_byp_arg;
  integer ncap;
  real    adc_fs;
  real    dc_offset;
  integer hpf_coeff_arg;
  integer hpf_coeff_override;
  reg [1023:0] tones_file;
  reg [1023:0] out_file;

  // ---- DUT I/O --------------------------------------------------------------
  reg  mclk;          // master clock: drives clk, adc_clk and pclk
  reg  rst_n;         // active-low reset (cic_rst_n + presetn)
  reg  sdm_bit;       // 1-bit SDM stream into imeas
  reg  [3:0] DR;
  reg  [7:0] reg_ctrl;
  reg  sign_en;
  reg  cic_data_ok;

  reg  notch_byp, lpf_byp, hpf_byp;

  // coefficients
  reg  [23:0] hpf_coeff_data;
  reg  signed [17:0] lpf_coeff_data   [27:0];
  reg  signed [19:0] notch_coeff_data [23:0];

  // gated filter clocks
  wire notch_clk, lpf_clk, hpf_clk;
  wire notch_clk_gtg_en, lpf_clk_gtg_en, hpf_clk_gtg_en;

  // outputs
  wire [DATA_WIDTH-1:0] chdata;            // sinc(CIC)-only decimated output
  wire                  chdata_en;
  wire [DATA_WIDTH-1:0] imeas_chdata_out;  // final filtered output
  wire                  filter_chdata_en;

  // ---- clock generation -----------------------------------------------------
  real adc_period_ns;
  initial mclk = 1'b0;
  always #(adc_period_ns/2.0) mclk = ~mclk;

  // gated clocks (behavioral ICG via -DFPGA)
  common_clock_gate u_notch_cg(.clk(mclk), .enable(notch_clk_gtg_en), .bypass(1'b0), .gated_clk(notch_clk));
  common_clock_gate u_lpf_cg  (.clk(mclk), .enable(lpf_clk_gtg_en),   .bypass(1'b0), .gated_clk(lpf_clk));
  common_clock_gate u_hpf_cg  (.clk(mclk), .enable(hpf_clk_gtg_en),   .bypass(1'b0), .gated_clk(hpf_clk));

  // ---- DUT ------------------------------------------------------------------
  filter_wrapper #(.DATA_WIDTH(DATA_WIDTH)) dut (
    .clk        (mclk),
    .notch_clk  (notch_clk),
    .lpf_clk    (lpf_clk),
    .hpf_clk    (hpf_clk),
    .pclk       (mclk),
    .sign_en    (sign_en),

    .adc_clk    (mclk),
    .DR         (DR),
    .presetn    (rst_n),
    .atpg_en    (1'b0),
    .reg_ctrl   (reg_ctrl),
    .cic_rst_n  (rst_n),

    .chdata     (chdata),
    .chdata_en  (chdata_en),
    .imeas_adc_din (sdm_bit),

    .cic_data_ok(cic_data_ok),

    .hpf_coeff_data  (hpf_coeff_data),
    .lpf_coeff_data  (lpf_coeff_data),
    .notch_coeff_data(notch_coeff_data),

    .notch_clk_gtg_en(notch_clk_gtg_en),
    .lpf_clk_gtg_en  (lpf_clk_gtg_en),
    .hpf_clk_gtg_en  (hpf_clk_gtg_en),

    .notch_filter_bypass_temp(notch_byp),
    .lpf_filter_bypass_temp  (lpf_byp),
    .hpf_filter_bypass_temp  (hpf_byp),

    .filter_chdata_en(filter_chdata_en),
    .imeas_chdata_out(imeas_chdata_out)
  );

  // ---- production default coefficients (from spi_reg.sv coeff_data_def) -----
  reg [23:0] cdef [0:28];
  integer b;
  task load_coeffs;
    begin
      // ---- LPF base (14) ----
      cdef[0]  = 24'b0000_0000_0000_0000_0000_1001;
      cdef[1]  = 24'b0000_0000_0000_0000_1000_0111;
      cdef[2]  = 24'b0000_0000_0000_0010_1101_1011;
      cdef[3]  = 24'b0000_0000_0000_1001_0000_0101;
      cdef[4]  = 24'b0000_0000_0001_0011_0001_1011;
      cdef[5]  = 24'b0000_0000_0001_1011_1000_1111;
      cdef[6]  = 24'b0000_0000_0001_0111_0100_0011;
      cdef[7]  = 24'b0000_0011_1111_1110_0011_1111;
      cdef[8]  = 24'b0000_0011_1101_1001_0110_0101;
      cdef[9]  = 24'b0000_0011_1100_0111_0100_1101;
      cdef[10] = 24'b0000_0011_1110_1011_1111_0010;
      cdef[11] = 24'b0000_0000_0101_0001_0101_1110;
      cdef[12] = 24'b0000_0000_1101_0011_1000_0010;
      cdef[13] = 24'b0000_0001_0010_1111_0011_1100;
      // ---- Notch base (14) ----
      cdef[14] = 24'b0000_0011_1111_1001_1111_0110;
      cdef[15] = 24'b0000_1000_0110_0000_1001_1000;
      cdef[16] = 24'b0000_1000_0111_1010_0001_1100;
      cdef[17] = 24'b0000_0011_1111_0011_1001_0001;
      cdef[18] = 24'b0000_1000_0110_1000_0000_0000;
      cdef[19] = 24'b0000_1000_0110_0101_1101_0111;
      cdef[20] = 24'b0000_0011_1111_0100_1010_1101;
      cdef[21] = 24'b0000_0011_1111_0001_1100_0010;
      cdef[22] = 24'b0000_1000_0110_0010_1011_0101;
      cdef[23] = 24'b0000_1000_1000_0011_1101_0100;
      cdef[24] = 24'b0000_0011_1110_0011_0000_0001;
      cdef[25] = 24'b0000_1000_0110_0101_1100_0110;
      cdef[26] = 24'b0000_1000_0111_1010_1110_0101;
      cdef[27] = 24'b0000_0011_1110_0100_0001_1001;
      // ---- HPF (1) ----
      cdef[28] = 24'b0111_1111_1001_1001_0110_0001;

      // LPF: 28 symmetric taps
      for (b=0; b<14; b=b+1) begin
        lpf_coeff_data[b]    = cdef[b][17:0];
        lpf_coeff_data[14+b] = cdef[13-b][17:0];
      end

      // Notch: 24 coeffs (mapping from spi_reg, hard "1.0" = 20'h40000 = En18 1.0)
      notch_coeff_data[0]  = cdef[14][19:0];
      notch_coeff_data[1]  = 20'h40000;
      notch_coeff_data[2]  = cdef[15][19:0];
      notch_coeff_data[3]  = 20'h40000;
      notch_coeff_data[4]  = cdef[16][19:0];
      notch_coeff_data[5]  = cdef[17][19:0];
      notch_coeff_data[6]  = cdef[14][19:0];
      notch_coeff_data[7]  = 20'h40000;
      notch_coeff_data[8]  = cdef[18][19:0];
      notch_coeff_data[9]  = 20'h40000;
      notch_coeff_data[10] = cdef[19][19:0];
      notch_coeff_data[11] = cdef[20][19:0];
      notch_coeff_data[12] = cdef[21][19:0];
      notch_coeff_data[13] = 20'h40000;
      notch_coeff_data[14] = cdef[22][19:0];
      notch_coeff_data[15] = 20'h40000;
      notch_coeff_data[16] = cdef[23][19:0];
      notch_coeff_data[17] = cdef[24][19:0];
      notch_coeff_data[18] = cdef[21][19:0];
      notch_coeff_data[19] = 20'h40000;
      notch_coeff_data[20] = cdef[25][19:0];
      notch_coeff_data[21] = 20'h40000;
      notch_coeff_data[22] = cdef[26][19:0];
      notch_coeff_data[23] = cdef[27][19:0];

      // HPF
      hpf_coeff_data = cdef[28];
    end
  endtask

  // ---- multi-tone stimulus --------------------------------------------------
  localparam MAXTONE = 128;
  real tone_f   [0:MAXTONE-1];
  real tone_a   [0:MAXTONE-1];
  real tone_p   [0:MAXTONE-1];
  integer ntone;

  task load_tones;
    integer fd, code;
    real f, a, p;
    begin
      ntone = 0;
      fd = $fopen(tones_file, "r");
      if (fd == 0) begin
        $display("ERROR: cannot open tones file %0s", tones_file);
        $finish;
      end
      while (!$feof(fd)) begin
        code = $fscanf(fd, "%f %f %f\n", f, a, p);
        if (code == 3) begin
          tone_f[ntone] = f;
          tone_a[ntone] = a;
          tone_p[ntone] = p;
          ntone = ntone + 1;
        end
      end
      $fclose(fd);
      $display("Loaded %0d tones from %0s", ntone, tones_file);
    end
  endtask

  // ---- 2nd-order sigma-delta modulator (analog -> 1-bit) --------------------
  real PI;
  real sdm_i1, sdm_i2, sdm_v, sdm_x;
  integer ksamp;        // adc sample index
  integer t;

  task reset_sdm;
    begin
      sdm_i1 = 0.0; sdm_i2 = 0.0; sdm_v = -1.0; ksamp = 0; sdm_bit = 1'b0;
    end
  endtask

  // generate next SDM bit (Candy 2nd-order single-loop)
  always @(negedge mclk) begin
    if (!rst_n) begin
      // hold reset state
      sdm_x = 0.0;
    end else begin
      sdm_x = dc_offset;
      for (t = 0; t < ntone; t = t + 1)
        sdm_x = sdm_x + tone_a[t]*$sin(2.0*PI*tone_f[t]*ksamp/adc_fs + tone_p[t]);
      sdm_i1 = sdm_i1 + (sdm_x - sdm_v);
      sdm_i2 = sdm_i2 + (sdm_i1 - sdm_v);
      sdm_bit = (sdm_i2 >= 0.0) ? 1'b1 : 1'b0;
      sdm_v   = sdm_bit ? 1.0 : -1.0;
      ksamp   = ksamp + 1;
    end
  end

  // ---- output capture -------------------------------------------------------
  integer ofd;
  integer cap_cnt;
  reg signed [DATA_WIDTH-1:0] sinc_s, filt_s;

  always @(posedge mclk) begin
    if (rst_n && filter_chdata_en) begin
      sinc_s = $signed(chdata);
      filt_s = $signed(imeas_chdata_out);
      $fwrite(ofd, "%0d %0d %0d\n", cap_cnt, sinc_s, filt_s);
      cap_cnt = cap_cnt + 1;
      if (cap_cnt >= ncap) begin
        $fclose(ofd);
        $display("Captured %0d samples to %0s", cap_cnt, out_file);
        $finish;
      end
    end
  end

  // ---- main -----------------------------------------------------------------
  initial begin
    PI = 3.14159265358979323846;

    // defaults
    DR_arg = 5; notch_byp_arg = 1; lpf_byp_arg = 1; hpf_byp_arg = 1;
    ncap = 2560; adc_fs = 512000.0; dc_offset = 0.0;
    hpf_coeff_override = 0; hpf_coeff_arg = 0;
    tones_file = "tones.txt";
    out_file   = "out.txt";

    if ($value$plusargs("DR=%d", DR_arg)) ;
    if ($value$plusargs("NOTCH_BYP=%d", notch_byp_arg)) ;
    if ($value$plusargs("LPF_BYP=%d",   lpf_byp_arg)) ;
    if ($value$plusargs("HPF_BYP=%d",   hpf_byp_arg)) ;
    if ($value$plusargs("NCAP=%d", ncap)) ;
    if ($value$plusargs("ADC_FS=%f", adc_fs)) ;
    if ($value$plusargs("TONES=%s", tones_file)) ;
    if ($value$plusargs("OUT=%s",   out_file)) ;
    if ($value$plusargs("DC=%f", dc_offset)) ;
    if ($value$plusargs("HPF_COEFF=%h", hpf_coeff_arg)) hpf_coeff_override = 1;

    adc_period_ns = 1.0e9/adc_fs;

    DR        = DR_arg[3:0];
    notch_byp = notch_byp_arg[0];
    lpf_byp   = lpf_byp_arg[0];
    hpf_byp   = hpf_byp_arg[0];

    // signed bipolar input format: reg_ctrl[3:2]=2'b10, reg_ctrl[7]=0 -> sign_en=1
    reg_ctrl  = 8'b0000_1000;
    sign_en   = 1'b1;
    cic_data_ok = 1'b1;

    load_coeffs;
    if (hpf_coeff_override) hpf_coeff_data = hpf_coeff_arg[23:0];

    ofd = $fopen(out_file, "w");
    if (ofd == 0) begin $display("ERROR: cannot open out file %0s", out_file); $finish; end
    cap_cnt = 0;

    $display("CONFIG DR=%0d OSR=%0d ADC_FS=%0.1f Fdec=%0.3f notch_byp=%0d lpf_byp=%0d hpf_byp=%0d NCAP=%0d",
             DR, (1<<(DR+3)), adc_fs, adc_fs/(1<<(DR+3)), notch_byp, lpf_byp, hpf_byp, ncap);

    rst_n   = 1'b0;
    reset_sdm;
    #(adc_period_ns*20);
    load_tones;
    @(negedge mclk);
    rst_n = 1'b1;

    // safety timeout
    #(adc_period_ns * ( (ncap+64) * (1<<(DR+3)) + 100000 ));
    $display("ERROR: timeout, captured %0d/%0d", cap_cnt, ncap);
    $fclose(ofd);
    $finish;
  end

endmodule
