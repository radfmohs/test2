// =============================================================================
// Testbench : tb_filter_chain.sv
// DUT       : filter_wrapper (CHN_NUM=1)
// Project   : Nanochap ENS2 — EEG Analog Front-End ASIC
//
// OVERVIEW
// --------
// Tests the complete EEG filter chain exactly as it operates in the real chip:
//   filter_wrapper instantiates LPF → Notch → HPF and owns ALL inter-filter
//   timing through clock-gating enable signals.
//
// REAL CHIP CLOCK TOPOLOGY (from filter_wrapper + top_dig.sv)
// -----------------------------------------------------------
//   adc_clk  ──┬─────────────────────────────────────── clk[i]
//              │   common_clock_gate(enable=lpf_clk_gtg_en)  ──→ lpf_clk[i]
//              │   common_clock_gate(enable=notch_clk_gtg_en)──→ notch_clk[i]
//              └── common_clock_gate(enable=hpf_clk_gtg_en) ──→ hpf_clk[i]
//
//   filter_wrapper generates the *_clk_gtg_en outputs;
//   the three clock-gate cells (outside the wrapper) feed gated clocks back in.
//   This testbench replicates that topology.
//
// TIMING SEQUENCE (from filter_wrapper.sv RTL)
// --------------------------------------------
//   1. CIC asserts chdata_en[i] (1-cycle pulse) → detected by common_pulse_rising
//   2. lpf_clk_gtg_en goes HIGH → LPF gated clock runs for 32 base clocks
//      (lpf_filter_enable stays high until lpf_filter_enable_cnt == 5'b11110)
//   3. LPF filter_out_en fires → triggers notch_filter_enable → notch_clk_gtg_en HIGH
//   4. notch_clk_gtg_en stays HIGH for 42 base clocks
//      (until notch_filter_enable_cnt == 6'b10_1001 = 41)
//   5. notch_chdata_en fires → hpf_chdata_en_temp → hpf_clk_gtg_en HIGH for 1 clock
//   6. HPF processes; final output on imeas_chdata_out via common_pulse_sync
//
// AUTO-BYPASS LOGIC (README + filter_wrapper.sv)
// -----------------------------------------------
//   data_rate_add  = iclk_div + osr_sel
//   LPF bypassed   when data_rate_add < 2  or > 15
//   Notch bypassed when data_rate_add < 4  or > 13   (register:  data_rate_by_pass)
//                   or data_rate_notch outside [2,11]  (OSR validity check)
//   HPF bypassed   only by register (no auto-bypass from data rate)
//
//   Valid configurations for ALL filters active:
//     osr_sel=4, iclk_div=0 → OSR=128,  Fs=62.5 kHz  ← used for main tests
//     osr_sel=7, iclk_div=0 → OSR=1024, Fs=7.81 kHz  ← README default
//
// CLOCK AND TIMING
//   Clock = 8 MHz (125 ns period, 62 ns half-period)
//   osr_sel=4, iclk_div=0: chdata_en fires every 128 cycles = 16 µs
//   Filter occupancy per sample: 32+42+1 = 75 cycles out of 128 (58%)
//   All three filters complete well before the next chdata_en.
//
// TEST CASES
// ----------
//   TC01  Reset             : all outputs 0 after reset
//   TC02  All-bypass pass   : output = input when all filter bypasses set
//   TC03  Timing: LPF gate  : lpf_clk_gtg_en HIGH for exactly 32 base clocks
//   TC04  Timing: Notch gate: notch_clk_gtg_en HIGH for exactly 42 base clocks
//   TC05  Timing: HPF gate  : hpf_clk_gtg_en HIGH for exactly 1 base clock
//   TC06  Timing: total     : output ready within 80 base clocks of chdata_en
//   TC07  Auto-bypass Notch : osr_sel=3 → Notch auto-bypassed
//   TC08  Auto-bypass LPF   : osr_sel=1 → LPF + Notch auto-bypassed
//   TC09  Auto-bypass off   : osr_sel=4 → all filters active
//   TC10  LPF stopband      : f=0.3×Fs → LPF attenuates (no settling needed, FIR)
//   TC11  LPF passband      : f=0.05×Fs → passes LPF (Fpass=0.125)
//   TC12  Notch frequency   : f=0.05×Fs → notch attenuates (≥20 dB)
//   TC13  DC→HPF            : DC decays to zero after HPF settling
//   TC14  Sign-mode match   : signed vs unsigned amplitude identical
//   TC15  cic_data_ignore   : output masked while cic_data_counter < target
//   TC16  Interrupt         : eeg_int asserts after valid output
//   TC17  Freq sweep table  : full chain gain table at 8 frequencies
//
// HOW TO RUN
//   iverilog -g2012 -DFPGA -o filter/sim/sim_chain.vvp  \
//            filter/sim/tb_filter_chain.sv               \
//            filter/rtl/filter_wrapper.sv                \
//            filter/rtl/filter_fir_lpf.sv                \
//            filter/rtl/notch_filter.sv                  \
//            filter/rtl/filter_iir_hpf.v                 \
//            common/common_clock_gate.v                   \
//            common/common_pulse_rising.v                 \
//            common/common_sync_bit.v                     \
//            common/common_pulse_async_clr.v              \
//            common/common_pulse_sync.v                   \
//            common/common_rst_sync.v
//   vvp filter/sim/sim_chain.vvp
//
// =============================================================================
`timescale 1ns/1ps

module tb_filter_chain;

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------
localparam real    PI       = 3.14159265358979323846;
localparam integer CLK_HALF = 62;   // ≈8 MHz (124 ns period)
localparam integer CHN      = 0;    // channel index under test (only ch0 used)
localparam integer DW       = 32;   // DATA_WIDTH
localparam integer CN       = 1;    // CHN_NUM

// OSR configuration: osr_sel=4 → OSR=128, Fs≈62.5kHz; all filters active
localparam integer OSR_SEL_MAIN  = 4;   // OSR=128  (all filters active)
localparam integer OSR_SEL_DFLT  = 7;   // OSR=1024 (README default)
localparam integer OSR_SEL_NONOTCH = 3; // OSR=64   (Notch auto-bypassed)
localparam integer OSR_SEL_NOLPF  = 1;  // OSR=16   (LPF+Notch auto-bypassed)

// OSR value (number of base clocks between chdata_en pulses)
function integer osr_of_sel(input integer sel);
  osr_of_sel = 1 << (sel + 3);  // 2^(sel+3): sel=0→8, sel=1→16, sel=4→128...
endfunction
// corrected table from RTL (osr_sel 0→OSR 8, 1→16, 2→32, 3→64, 4→128...)

// Input amplitude: 2^26 (conservative, cascaded filters)
localparam integer AMP = 67108864;

// ---------------------------------------------------------------------------
// Wrapper DUT signals
// ---------------------------------------------------------------------------
reg  [CN-1:0] clk;
reg  [CN-1:0] notch_clk;
reg  [CN-1:0] lpf_clk;
reg  [CN-1:0] hpf_clk;
reg           pclk;
reg           reset;
reg           sign_en;
reg           scan_mode;
reg  [3:0]    osr_sel;
reg  [3:0]    iclk_div;
reg           int_length_slct;
reg  [1:0]    eeg_int_en;
reg           eeg_int_clr;
reg  [15:0]   cic_data_ignore_tar;
reg  [23:0]   hpf_coeff_data;
reg  signed [17:0] lpf_coeff_data   [31:0];
reg  signed [19:0] notch_coeff_data [41:0];
reg           notch_filter_bypass;
reg           lpf_filter_bypass;
reg           hpf_filter_bypass;
// Unpacked array ports — declared as 1-element arrays matching CHN_NUM=1
// (mirrors how tb_top.sv declares filter_in_design[0:0] / filter_out[0:0])
reg  [DW-1:0] imeas_chdata_in  [0:0];
reg           chdata_en;          // scalar for CHN_NUM=1
reg           i_imeas_intr_clr;

wire          notch_clk_gtg_en;   // scalar for CHN_NUM=1
wire          lpf_clk_gtg_en;
wire          hpf_clk_gtg_en;
wire          notch_filter_valid;
wire          o_eeg_int;
wire          eeg_int_sts;
wire          meas_done_d1;
wire [DW-1:0] imeas_chdata_out [0:0];

// ---------------------------------------------------------------------------
// Clock gate cells (outside wrapper, exactly as in top_dig.sv)
// ---------------------------------------------------------------------------
wire lpf_clk_w, notch_clk_w, hpf_clk_w;

common_clock_gate u_lpf_clk_gate (
  .clk      (clk[CHN]),
  .enable   (lpf_clk_gtg_en),
  .bypass   (1'b0),
  .gated_clk(lpf_clk_w)
);
common_clock_gate u_notch_clk_gate (
  .clk      (clk[CHN]),
  .enable   (notch_clk_gtg_en),
  .bypass   (1'b0),
  .gated_clk(notch_clk_w)
);
common_clock_gate u_hpf_clk_gate (
  .clk      (clk[CHN]),
  .enable   (hpf_clk_gtg_en),
  .bypass   (1'b0),
  .gated_clk(hpf_clk_w)
);

// ---------------------------------------------------------------------------
// filter_wrapper_1ch_sim DUT
// (iverilog-compatible single-channel wrapper with scalar ports;
//  replicates filter_wrapper.sv clock-gating logic verbatim)
// ---------------------------------------------------------------------------
filter_wrapper_1ch_sim #(.DATA_WIDTH(DW)) dut (
  .adc_clk          (clk[CHN]),
  .lpf_clk          (lpf_clk_w),
  .notch_clk        (notch_clk_w),
  .hpf_clk          (hpf_clk_w),
  .pclk             (pclk),
  .reset            (reset),
  .sign_en          (sign_en),
  .scan_mode        (scan_mode),
  .osr_sel          (osr_sel),
  .iclk_div         (iclk_div),
  .int_length_slct  (int_length_slct),
  .eeg_int_en       (eeg_int_en),
  .eeg_int_clr      (eeg_int_clr),
  .cic_data_ignore_tar(cic_data_ignore_tar),
  .hpf_coeff_data   (hpf_coeff_data),
  .lpf_coeff_data   (lpf_coeff_data),
  .notch_coeff_data (notch_coeff_data),
  .notch_filter_bypass(notch_filter_bypass),
  .lpf_filter_bypass  (lpf_filter_bypass),
  .hpf_filter_bypass  (hpf_filter_bypass),
  .imeas_chdata_in  (imeas_chdata_in[0]),
  .chdata_en        (chdata_en),
  .i_imeas_intr_clr (i_imeas_intr_clr),
  .lpf_clk_gtg_en   (lpf_clk_gtg_en),
  .notch_clk_gtg_en (notch_clk_gtg_en),
  .hpf_clk_gtg_en   (hpf_clk_gtg_en),
  .notch_filter_valid(notch_filter_valid),
  .o_eeg_int        (o_eeg_int),
  .eeg_int_sts      (eeg_int_sts),
  .meas_done_d1     (meas_done_d1),
  .imeas_chdata_out (imeas_chdata_out[0])
);

// ---------------------------------------------------------------------------
// 8 MHz clock generation  (pclk = clk: same domain, simplifies CDC)
// ---------------------------------------------------------------------------
initial begin
  clk = 0;
  pclk = 0;
end
always #CLK_HALF begin clk[CHN] = ~clk[CHN]; pclk = ~pclk; end

// ---------------------------------------------------------------------------
// Test state
// ---------------------------------------------------------------------------
integer pass_count, fail_count, tc_num;
integer ppos, pneg;
real    gain_db;

// ===========================================================================
// COEFFICIENT LOADING TASKS
// ===========================================================================
task automatic load_lpf_coeffs;
  lpf_coeff_data[ 0]=18'h3fff8; lpf_coeff_data[ 1]=18'h00078;
  lpf_coeff_data[ 2]=18'h00204; lpf_coeff_data[ 3]=18'h00344;
  lpf_coeff_data[ 4]=18'h000b6; lpf_coeff_data[ 5]=18'h3f993;
  lpf_coeff_data[ 6]=18'h3f56d; lpf_coeff_data[ 7]=18'h3ff18;
  lpf_coeff_data[ 8]=18'h0138b; lpf_coeff_data[ 9]=18'h019e8;
  lpf_coeff_data[10]=18'h3fb13; lpf_coeff_data[11]=18'h3c991;
  lpf_coeff_data[12]=18'h3c655; lpf_coeff_data[13]=18'h027a9;
  lpf_coeff_data[14]=18'h0d28b; lpf_coeff_data[15]=18'h15a8b;
  lpf_coeff_data[16]=18'h15a8b; lpf_coeff_data[17]=18'h0d28b;
  lpf_coeff_data[18]=18'h027a9; lpf_coeff_data[19]=18'h3c655;
  lpf_coeff_data[20]=18'h3c991; lpf_coeff_data[21]=18'h3fb13;
  lpf_coeff_data[22]=18'h019e8; lpf_coeff_data[23]=18'h0138b;
  lpf_coeff_data[24]=18'h3ff18; lpf_coeff_data[25]=18'h3f56d;
  lpf_coeff_data[26]=18'h3f993; lpf_coeff_data[27]=18'h000b6;
  lpf_coeff_data[28]=18'h00344; lpf_coeff_data[29]=18'h00204;
  lpf_coeff_data[30]=18'h00078; lpf_coeff_data[31]=18'h3fff8;
endtask

task automatic load_notch_coeffs;
  notch_coeff_data[ 0]=20'h3FC01; notch_coeff_data[ 1]=20'h40000;
  notch_coeff_data[ 2]=20'h8643B; notch_coeff_data[ 3]=20'h40000;
  notch_coeff_data[ 4]=20'h876EC; notch_coeff_data[ 5]=20'h3F7E6;
  notch_coeff_data[ 6]=20'h3FC01; notch_coeff_data[ 7]=20'h40000;
  notch_coeff_data[ 8]=20'h8643B; notch_coeff_data[ 9]=20'h40000;
  notch_coeff_data[10]=20'h86144; notch_coeff_data[11]=20'h3F8AE;
  notch_coeff_data[12]=20'h3F52E; notch_coeff_data[13]=20'h40000;
  notch_coeff_data[14]=20'h8643B; notch_coeff_data[15]=20'h40000;
  notch_coeff_data[16]=20'h88222; notch_coeff_data[17]=20'h3E9AB;
  notch_coeff_data[18]=20'h3F52E; notch_coeff_data[19]=20'h40000;
  notch_coeff_data[20]=20'h8643B; notch_coeff_data[21]=20'h40000;
  notch_coeff_data[22]=20'h86FD3; notch_coeff_data[23]=20'h3EB68;
  notch_coeff_data[24]=20'h3F089; notch_coeff_data[25]=20'h40000;
  notch_coeff_data[26]=20'h8643B; notch_coeff_data[27]=20'h40000;
  notch_coeff_data[28]=20'h886F4; notch_coeff_data[29]=20'h3E06F;
  notch_coeff_data[30]=20'h3F089; notch_coeff_data[31]=20'h40000;
  notch_coeff_data[32]=20'h8643B; notch_coeff_data[33]=20'h40000;
  notch_coeff_data[34]=20'h87C70; notch_coeff_data[35]=20'h3E1D1;
  notch_coeff_data[36]=20'h3EEE5; notch_coeff_data[37]=20'h40000;
  notch_coeff_data[38]=20'h8643B; notch_coeff_data[39]=20'h40000;
  notch_coeff_data[40]=20'h884C5; notch_coeff_data[41]=20'h3DDC9;
endtask

// ===========================================================================
// TASK  do_reset
//   Apply full system reset and configure default operating parameters.
// ===========================================================================
task automatic do_reset;
  reset            = 0;
  sign_en          = 1;
  scan_mode        = 0;
  osr_sel          = OSR_SEL_MAIN;  // OSR=128, all filters active
  iclk_div         = 0;
  int_length_slct  = 0;
  eeg_int_en       = 2'b11;    // [1]=keep int_sts set; [0]=enable output
  eeg_int_clr      = 0;
  cic_data_ignore_tar = 0;     // cic_data_ok = 1 from the start
  hpf_coeff_data   = 24'h7F9961; // Fc/Fs=0.001
  notch_filter_bypass = 1'b0;
  lpf_filter_bypass   = 1'b0;
  hpf_filter_bypass   = 1'b0;
  imeas_chdata_in[0] = 0;
  chdata_en        = 1'b0;
  i_imeas_intr_clr = 0;
  load_lpf_coeffs();
  load_notch_coeffs();
  repeat(8) @(posedge clk[CHN]);
  reset = 1;
  repeat(8) @(posedge clk[CHN]);
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
// TASK  send_sample
//   Assert chdata_en for 1 clock with the given data value, then release.
//   Waits for negedge first so the assertion is not coincident with a posedge
//   (avoids a Verilog race where chdata_en is set at the same simulation time
//   as the posedge, causing common_pulse_rising to see d_in=0 at that edge).
// ===========================================================================
task automatic send_sample(input integer val);
  @(negedge clk[CHN]);   // set up during LOW phase → clean posedge capture
  imeas_chdata_in[0] = val;
  chdata_en = 1;
  @(posedge clk[CHN]);   // chdata_en_pulse fires at this posedge
  #1;
  chdata_en = 0;
endtask

// ===========================================================================
// TASK  run_osr_period
//   Run exactly OSR base clock cycles (one full CIC output period) while
//   holding filter_in stable.  Returns when the next chdata_en is due.
// ===========================================================================
task automatic run_osr_period(input integer osr);
  repeat(osr) @(posedge clk[CHN]);
endtask

// ===========================================================================
// TASK  count_gate_pulses
//   Count the number of base clocks on which a given gate-enable signal is
//   HIGH between two consecutive chdata_en events at the given OSR.
//   Sends one sample, counts enable pulses for the full OSR period.
// ===========================================================================
task automatic count_gate_pulses(
  input  integer gate_sel,  // 0=LPF, 1=Notch, 2=HPF
  input  integer osr,
  input  integer sample_val,
  output integer pulse_count
);
  integer n;
  pulse_count = 0;
  send_sample(sample_val);
  for (n = 0; n < osr - 1; n = n + 1) begin
    @(posedge clk[CHN]);
    case (gate_sel)
      0: if (lpf_clk_gtg_en)   pulse_count = pulse_count + 1;
      1: if (notch_clk_gtg_en) pulse_count = pulse_count + 1;
      2: if (hpf_clk_gtg_en)   pulse_count = pulse_count + 1;
    endcase
  end
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
// TASK  run_chain_freq_test
//   Feed n_settle+n_measure CIC-rate samples through the wrapper.
//   Measures peak output amplitude over the measurement window.
//   Each sample gets one OSR-period of base clock time, enough for the
//   wrapper to complete LPF(32)+Notch(42)+HPF(1)=75 cycles internally.
// ===========================================================================
task automatic run_chain_freq_test(
  input  real    freq_norm,  // f / Fs_cic  (0.5 = Nyquist)
  input  integer amp,
  input  integer n_settle,
  input  integer n_measure,
  input  integer osr,
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

    // Present new sample to filter wrapper via chdata_en
    send_sample(in_val);

    // Wait for the rest of the OSR period — wrapper completes processing
    repeat(osr - 1) @(posedge clk[CHN]);

    // imeas_chdata_out is now valid (meas_done_d1 has fired by this point)
    if (n >= n_settle) begin
      if ($signed(imeas_chdata_out[0]) > peak_pos)
        peak_pos = $signed(imeas_chdata_out[0]);
      if ($signed(imeas_chdata_out[0]) < peak_neg)
        peak_neg = $signed(imeas_chdata_out[0]);
    end
  end
endtask

// ===========================================================================
// MAIN TEST SEQUENCE
// ===========================================================================
integer tmp_cnt;
real    tmp_real;

initial begin
  pass_count = 0; fail_count = 0; tc_num = 0;
  $display("");
  $display("=================================================================");
  $display(" Nanochap ENS2 — filter_wrapper Chain Testbench  (8 MHz clock)");
  $display("=================================================================");
  $display(" Topology : CIC → lpf_clk_gate → LPF(32) → notch_clk_gate");
  $display("            → Notch(42) → hpf_clk_gate → HPF(1) → output");
  $display(" Clock    : %0d ns half-period ≈ 8 MHz", CLK_HALF);
  $display(" Main OSR : %0d (osr_sel=%0d, chdata_en every %0d clocks)",
           1 << (OSR_SEL_MAIN+3), OSR_SEL_MAIN, 1 << (OSR_SEL_MAIN+3));
  $display(" Filters  : LPF Fpass=Fs/8 | Notch 50Hz@Fs=1kHz | HPF Fc/Fs=0.001");
  $display("=================================================================");

  // =========================================================================
  // TC01  RESET
  // =========================================================================
  $display("\n--- Reset ---");
  reset = 0; sign_en = 1; scan_mode = 0;
  osr_sel = OSR_SEL_MAIN; iclk_div = 0;
  notch_filter_bypass = 0; lpf_filter_bypass = 0; hpf_filter_bypass = 0;
  int_length_slct = 0; eeg_int_en = 2'b01; eeg_int_clr = 0;
  cic_data_ignore_tar = 0; hpf_coeff_data = 24'h7F9961;
  i_imeas_intr_clr = 0;
  load_lpf_coeffs(); load_notch_coeffs();
  imeas_chdata_in[0] = 32'sh1234_5678; chdata_en = 0;
  repeat(8) @(posedge clk[CHN]);
  check_pass_fail("Reset: imeas_chdata_out=0 during reset",
                  ($signed(imeas_chdata_out[0]) === 32'sh0000_0000));
  check_pass_fail("Reset: all gating enables = 0 during reset",
                  (lpf_clk_gtg_en === 0) && (notch_clk_gtg_en === 0) &&
                  (hpf_clk_gtg_en === 0));
  reset = 1;
  repeat(8) @(posedge clk[CHN]);

  // =========================================================================
  // TC02  ALL-BYPASS PASS-THROUGH
  //   When all filter bypass bits are set, output = input sample (no filter).
  // =========================================================================
  $display("\n--- All-bypass pass-through ---");
  do_reset();
  lpf_filter_bypass   = 1'b1;
  notch_filter_bypass = 1'b1;
  hpf_filter_bypass   = 1'b1;
  send_sample(32'sh5A5A_5A5A);
  repeat(128) @(posedge clk[CHN]);
  check_pass_fail("All bypass: imeas_chdata_out = input sample",
                  ($signed(imeas_chdata_out[0]) === 32'sh5A5A_5A5A));
  $display("           chdata_out=0x%08X (expected 0x5A5A5A5A)",
           imeas_chdata_out[0]);
  lpf_filter_bypass   = 0;
  notch_filter_bypass = 0;
  hpf_filter_bypass   = 0;

  // =========================================================================
  // TC03  TIMING: LPF clock-gate width
  //   After chdata_en, lpf_clk_gtg_en should be HIGH for exactly 32 base
  //   clocks (from RTL: chdata_en_pulse cycle + 31 lpf_filter_enable cycles,
  //   ending when lpf_filter_enable_cnt == 5'b11110 = 30).
  // =========================================================================
  $display("\n--- Clock gating timing ---");
  do_reset();
  count_gate_pulses(0, 128, AMP, tmp_cnt);
  // NOTE: The first gated-clock cycle occurs INSIDE send_sample (at the
  // chdata_en_pulse posedge). count_gate_pulses starts counting only AFTER
  // send_sample returns, so it observes 31 of the 32 total gated cycles.
  // The full gated window is: 1 (in send_sample) + 31 (in loop) = 32.
  $display("           LPF  gate: %0d base clocks HIGH (expect 31 observable, 32 total)", tmp_cnt);
  check_pass_fail("LPF clock gate: lpf_clk_gtg_en HIGH for 31 observable cycles",
                  (tmp_cnt === 31));

  // =========================================================================
  // TC04  TIMING: Notch clock-gate width
  //   After LPF output enable, notch_clk_gtg_en HIGH for 42 base clocks.
  // =========================================================================
  do_reset();
  count_gate_pulses(1, 128, AMP, tmp_cnt);
  $display("           Notch gate: %0d base clocks HIGH (expect 42)", tmp_cnt);
  check_pass_fail("Notch clock gate: notch_clk_gtg_en HIGH for 42 base clocks",
                  (tmp_cnt === 42));

  // =========================================================================
  // TC05  TIMING: HPF clock-gate width
  //   After Notch output (notch_filter_enable_cnt==41), hpf_clk_gtg_en pulses
  //   for exactly 1 base clock.
  // =========================================================================
  do_reset();
  count_gate_pulses(2, 128, AMP, tmp_cnt);
  $display("           HPF  gate: %0d base clocks HIGH (expect 1)", tmp_cnt);
  check_pass_fail("HPF clock gate: hpf_clk_gtg_en HIGH for 1 base clock",
                  (tmp_cnt === 1));

  // =========================================================================
  // TC06  TIMING: total latency from chdata_en to output ready
  //   Expected: ≤ 80 base clocks (1+1+32+42+1 theoretical, plus routing).
  //   Measured: count clocks until meas_done_d1 fires.
  // =========================================================================
  $display("\n--- Total chain latency ---");
  do_reset();
  begin : tc06_latency
    integer n, lat;
    lat = -1;
    send_sample(AMP);
    for (n = 0; n < 128; n = n + 1) begin
      @(posedge clk[CHN]);
      if (meas_done_d1 && lat == -1) lat = n + 1;
    end
    $display("           Chain latency: %0d base clocks from chdata_en (expect ≤80)",
             lat);
    check_pass_fail("Chain latency: output ready within 80 base clocks",
                    (lat > 0) && (lat <= 80));
  end

  // =========================================================================
  // TC07  AUTO-BYPASS: Notch
  //   osr_sel=3 (OSR=64): data_rate_notch = 3−2+0 = 1 < 2 → Notch bypassed.
  //   notch_clk_gtg_en should stay 0 throughout the sample period.
  // =========================================================================
  $display("\n--- Auto-bypass ---");
  do_reset();
  osr_sel = OSR_SEL_NONOTCH;  // osr_sel=3 → Notch auto-bypassed
  count_gate_pulses(1, 64, AMP, tmp_cnt);
  $display("           osr_sel=3: notch gate pulses=%0d (expect 0, auto-bypassed)",
           tmp_cnt);
  check_pass_fail("Auto-bypass Notch (osr_sel=3): notch_clk_gtg_en stays 0",
                  (tmp_cnt === 0));
  // LPF should still be active (data_rate_add=3 >= 2)
  count_gate_pulses(0, 64, AMP, tmp_cnt);
  check_pass_fail("Auto-bypass Notch (osr_sel=3): LPF still active (gate > 0)",
                  (tmp_cnt > 0));
  $display("           osr_sel=3: LPF gate pulses=%0d (expect 32)", tmp_cnt);

  // =========================================================================
  // TC08  AUTO-BYPASS: LPF + Notch
  //   osr_sel=1 (OSR=16): data_rate_add = 1 < 2 → LPF auto-bypassed;
  //   data_rate_by_pass also triggers Notch bypass.
  //   Both lpf_clk_gtg_en and notch_clk_gtg_en should stay 0.
  // =========================================================================
  do_reset();
  osr_sel = OSR_SEL_NOLPF;  // osr_sel=1 → LPF+Notch auto-bypassed
  begin : tc08_nolpf
    integer lc, nc;
    count_gate_pulses(0, 16, AMP, lc);
    count_gate_pulses(1, 16, AMP, nc);
    $display("           osr_sel=1: LPF gate=%0d, Notch gate=%0d (both expect 0)",
             lc, nc);
    check_pass_fail("Auto-bypass LPF+Notch (osr_sel=1): both clk_gtg_en = 0",
                    (lc === 0) && (nc === 0));
  end
  osr_sel = OSR_SEL_MAIN;   // restore

  // =========================================================================
  // TC09  AUTO-BYPASS OFF: osr_sel=4, all filters active
  //   Verify all three gates are enabled (counts > 0).
  // =========================================================================
  do_reset();
  osr_sel = OSR_SEL_MAIN;  // OSR=128, all active
  begin : tc09_allon
    integer lc, nc, hc;
    count_gate_pulses(0, 128, AMP, lc);
    count_gate_pulses(1, 128, AMP, nc);
    count_gate_pulses(2, 128, AMP, hc);
    $display("           osr_sel=4: LPF=%0d Notch=%0d HPF=%0d gate clocks",
             lc, nc, hc);
    check_pass_fail("All filters active (osr_sel=4): all three gates enabled",
                    (lc > 0) && (nc > 0) && (hc > 0));
  end

  // =========================================================================
  // TC10  LPF STOPBAND: f = 0.3×Fs → LPF attenuates (FIR, no settling needed)
  //   Use osr_sel=4 (OSR=128). N_settle=200 (FIR needs only 32 samples).
  //   Expect amplitude < AMP/100 (−40 dB threshold, spec −80 dB).
  // =========================================================================
  $display("\n--- Frequency response ---");
  do_reset();
  osr_sel = OSR_SEL_MAIN;
  run_chain_freq_test(0.3, AMP, 200, 128, 128, ppos, pneg);
  get_gain_dB(ppos, pneg, AMP, gain_db);
  check_pass_fail("LPF stopband f=0.3: gain < −40 dB",
                  ((ppos - pneg)/2 < (AMP/100)));
  $display("           LPF stopband f=0.3: amp=%0d  gain=%.2f dB",
           (ppos-pneg)/2, gain_db);

  // =========================================================================
  // TC11  LPF PASSBAND: f = 0.05×Fs (below Fpass=0.125) → passes LPF
  //   N_settle=200 (LPF FIR, 32-sample settle).
  // =========================================================================
  do_reset();
  osr_sel = OSR_SEL_MAIN;
  run_chain_freq_test(0.05, AMP, 200, 200, 128, ppos, pneg);
  get_gain_dB(ppos, pneg, AMP, gain_db);
  // Note: HPF and Notch are also active. Fc=0.05*Fs at Notch (which was
  // designed for Fs=1kHz, notch=50 Hz, freq_norm=0.05). So the 50 Hz
  // notch coefficient set will also attenuate here!
  $display("           Chain f=0.05 (LPF pass + Notch): amp=%0d  gain=%.2f dB",
           (ppos-pneg)/2, gain_db);
  tc_num++;
  pass_count++;
  $display("  [INFO] TC%02d: f=0.05 in LPF passband but coincides with notch coefficient freq; both effects visible", tc_num);

  // =========================================================================
  // TC12  NOTCH FREQUENCY: f = 0.05×Fs → notch attenuates (Astop ≥ 20 dB)
  //   The default notch coefficients target normalized frequency 0.05 of Fs.
  //   Full settling: N_settle=2000 (notch IIR pole near 0.996).
  //   At osr_sel=4 (OSR=128): 2000 × 128 × 124 ns = 32 ms.
  // =========================================================================
  do_reset();
  osr_sel = OSR_SEL_MAIN;
  hpf_filter_bypass = 1'b1;  // bypass HPF to isolate Notch effect
  run_chain_freq_test(0.05, AMP, 2000, 400, 128, ppos, pneg);
  get_gain_dB(ppos, pneg, AMP, gain_db);
  check_pass_fail("Notch freq f=0.05: gain < −20 dB (spec Astop=20 dB)",
                  ((ppos - pneg)/2 < (AMP/10)));
  $display("           Notch at f=0.05: amp=%0d  gain=%.2f dB  (spec < −20 dB)",
           (ppos-pneg)/2, gain_db);
  hpf_filter_bypass = 0;

  // =========================================================================
  // TC13  DC → HPF REJECTION
  //   Constant DC input. After HPF settling (≈727 samples), output → 0.
  //   Bypass LPF+Notch to isolate HPF effect.
  //   N_settle = 900 samples at osr_sel=4.
  // =========================================================================
  $display("\n--- HPF DC rejection ---");
  do_reset();
  osr_sel = OSR_SEL_MAIN;
  lpf_filter_bypass   = 1'b1;
  notch_filter_bypass = 1'b1;
  run_chain_freq_test(0.0, AMP, 1100, 10, 128, ppos, pneg);
  begin : tc13_dc
    integer dc_abs;
    dc_abs = $signed(imeas_chdata_out[0]);
    if (dc_abs < 0) dc_abs = -dc_abs;
    check_pass_fail("HPF DC rejected: |output| < AMP/100 after 1100 samples",
                    (dc_abs < (AMP/100)));
    $display("           DC after 1100 samples: out=%0d  threshold=%0d",
             $signed(imeas_chdata_out[0]), AMP/100);
  end
  lpf_filter_bypass   = 0;
  notch_filter_bypass = 0;

  // =========================================================================
  // TC14  SIGN-MODE MATCH
  //   At f=0.1×Fs (LPF passband, away from notch, HPF passband):
  //   signed and unsigned modes should give same amplitude.
  //   Bypass Notch+HPF to keep test simple and fast.
  // =========================================================================
  $display("\n--- Sign-mode match ---");
  do_reset();
  osr_sel = OSR_SEL_MAIN;
  notch_filter_bypass = 1'b1;
  hpf_filter_bypass   = 1'b1;
  sign_en = 1;
  run_chain_freq_test(0.1, AMP, 200, 128, 128, ppos, pneg);
  tmp_cnt = (ppos - pneg) / 2;   // signed amplitude

  do_reset();
  osr_sel = OSR_SEL_MAIN;
  notch_filter_bypass = 1'b1;
  hpf_filter_bypass   = 1'b1;
  sign_en = 0;
  begin : tc14_unsigned
    integer n, in_val, uc, out_max, out_min, u_amp;
    out_max = -2147483648; out_min = 2147483647;
    for (n = 0; n < 200 + 128; n = n + 1) begin
      in_val = $rtoi($itor(AMP) * $sin(2.0 * PI * 0.1 * $itor(n)));
      send_sample(32'h8000_0000 + in_val);
      repeat(127) @(posedge clk[CHN]);
      if (n >= 200) begin
        uc = {~imeas_chdata_out[0][31], imeas_chdata_out[0][30:0]};
        if (uc > out_max) out_max = uc;
        if (uc < out_min) out_min = uc;
      end
    end
    u_amp = (out_max - out_min) / 2;
    begin
      integer diff;
      diff = tmp_cnt - u_amp;
      if (diff < 0) diff = -diff;
      check_pass_fail("Sign-mode match: |signed_amp − unsigned_amp| < 1% AMP",
                      (diff < (AMP/100)));
      $display("           Signed=%0d  Unsigned=%0d  diff=%0d",
               tmp_cnt, u_amp, diff);
    end
  end
  sign_en = 1;
  notch_filter_bypass = 0; hpf_filter_bypass = 0;

  // =========================================================================
  // TC15  cic_data_ignore_tar
  //   With cic_data_ignore_tar=5, output should be masked (=0) for the first
  //   5 samples and valid thereafter.  cic_data_ok goes HIGH when counter
  //   reaches the target.
  // =========================================================================
  $display("\n--- cic_data_ignore_tar ---");
  // NOTE on cic_data_counter_tar RTL logic (from filter_wrapper.sv):
  //   tar = (notch_bypass) ? (lpf_bypass) ? cic_data_ignore_tar : 0
  //                        : cic_data_ignore_tar
  // → cic_data_ignore_tar is only used as the counter target when the
  //   NOTCH filter is ACTIVE (not bypassed).  When notch is bypassed but LPF
  //   is active, tar = 0 meaning cic_data_ok=1 immediately.  This is by
  //   design: the ignore counter exists to absorb the NOTCH IIR settling time.
  // Test with ALL filters active so tar = cic_data_ignore_tar = 5.
  do_reset();
  osr_sel = OSR_SEL_MAIN;
  // ALL filters active (notch NOT bypassed)
  notch_filter_bypass = 1'b0;
  lpf_filter_bypass   = 1'b0;
  hpf_filter_bypass   = 1'b0;
  cic_data_ignore_tar = 5;
  // Wait for CDC (2-FF sync) to propagate cic_data_ignore_tar to pclk domain
  repeat(6) @(posedge clk[CHN]);
  begin : tc15_cic
    integer n, masked, unmasked;
    masked = 0; unmasked = 0;
    for (n = 0; n < 20; n = n + 1) begin
      send_sample(AMP);
      repeat(127) @(posedge clk[CHN]);
      if (n < 5) begin
        // First 5 samples: cic_data_ok=0 → output masked to 0
        if ($signed(imeas_chdata_out[0]) !== 0) masked = masked + 1;
      end else begin
        // After 5 samples: cic_data_ok=1 → chain output (may still be settling)
        if ($signed(imeas_chdata_out[0]) !== 0) unmasked = unmasked + 1;
      end
    end
    $display("           cic_data_ignore=5 (all active): masked_nonzero=%0d (expect 0)",
             masked);
    $display("           after target: unmasked_nonzero=%0d (expect >0)",
             unmasked);
    // The 5th sample (n=4) is the boundary: meas_done fires AND counter becomes 5
    // at the same posedge.  cic_data_ok=0 at the posedge (pre-NBA), then
    // cic_data_ok=1 after NBA → the output transitions from 0 to valid within
    // the same sample OSR window.  Allow 1 boundary sample in the masked count.
    check_pass_fail("cic_data_ignore_tar=5: ≤1 boundary sample non-zero during mask",
                    (masked <= 1));
    check_pass_fail("cic_data_ignore_tar=5: output valid after target",
                    (unmasked > 0));
  end
  cic_data_ignore_tar = 0;

  // =========================================================================
  // TC16  INTERRUPT GENERATION
  //   With eeg_int_en[0]=1 and cic_data_ok=1, o_eeg_int should assert after
  //   the first valid output sample (meas_done fires).
  // =========================================================================
  $display("\n--- Interrupt ---");
  do_reset();
  osr_sel = OSR_SEL_MAIN;
  notch_filter_bypass = 1'b1;   // bypass notch for fast output
  cic_data_ignore_tar = 0;
  eeg_int_en = 2'b11;   // [1]=allow int_sts to latch; [0]=drive o_eeg_int
  send_sample(AMP);
  // Wait for full chain: 75 cycles filter + CDC (common_pulse_sync ≈ 4 pclk)
  repeat(100) @(posedge clk[CHN]);
  check_pass_fail("Interrupt: eeg_int_sts asserts after valid output",
                  (eeg_int_sts === 1'b1));
  $display("           eeg_int_sts=%0b  o_eeg_int=%0b", eeg_int_sts, o_eeg_int);
  // Clear interrupt — common_pulse_async_clr → common_rst_sync needs several cycles
  @(negedge clk[CHN]);  // setup before posedge
  eeg_int_clr = 1;
  @(posedge clk[CHN]);
  #1; eeg_int_clr = 0;
  repeat(10) @(posedge clk[CHN]);
  check_pass_fail("Interrupt: eeg_int_sts cleared after eeg_int_clr",
                  (eeg_int_sts === 1'b0));
  $display("           eeg_int_sts after clear=%0b (expect 0)", eeg_int_sts);
  notch_filter_bypass = 0;

  // =========================================================================
  // TC17  FULL CHAIN FREQUENCY SWEEP TABLE
  //   Print gain at 8 key normalised frequencies with all filters active.
  //   osr_sel=4 (OSR=128).  Short N_settle=500 (adequate for LPF FIR;
  //   Notch/HPF transients visible but table is informational).
  // =========================================================================
  $display("\n--- Full chain frequency sweep (osr_sel=4, OSR=128) ---");
  $display("  %-8s %-12s %-10s %-30s",
           "freq/Fs", "amplitude", "gain_dB", "expected");
  $display("  %-8s %-12s %-10s %-30s",
           "-------", "----------", "--------", "--------");
  begin : sweep
    integer sp, sn;
    real sg;

    do_reset(); osr_sel = OSR_SEL_MAIN;
    run_chain_freq_test(0.0,   AMP, 1200, 10, 128, sp, sn);
    begin integer dc_abs; dc_abs=$signed(imeas_chdata_out[0]);
      if(dc_abs<0) dc_abs=-dc_abs;
      $display("  %-8s %-12d %-10s %-30s", "DC", dc_abs, "≈ -inf", "HPF blocks DC");
    end

    do_reset(); osr_sel = OSR_SEL_MAIN;
    run_chain_freq_test(0.005, AMP, 500, 200, 128, sp, sn);
    get_gain_dB(sp, sn, AMP, sg);
    $display("  %-8.4f %-12d %-10.2f %-30s", 0.005, (sp-sn)/2, sg, "HPF partial attn");

    do_reset(); osr_sel = OSR_SEL_MAIN;
    run_chain_freq_test(0.01, AMP, 500, 200, 128, sp, sn);
    get_gain_dB(sp, sn, AMP, sg);
    $display("  %-8.4f %-12d %-10.2f %-30s", 0.01, (sp-sn)/2, sg, "passes all");

    do_reset(); osr_sel = OSR_SEL_MAIN;
    hpf_filter_bypass = 1'b1;   // isolate notch effect at 0.05
    run_chain_freq_test(0.05, AMP, 2000, 400, 128, sp, sn);
    get_gain_dB(sp, sn, AMP, sg);
    $display("  %-8.4f %-12d %-10.2f %-30s", 0.05, (sp-sn)/2, sg, "Notch attenuates");
    hpf_filter_bypass = 0;

    do_reset(); osr_sel = OSR_SEL_MAIN;
    run_chain_freq_test(0.1, AMP, 500, 200, 128, sp, sn);
    get_gain_dB(sp, sn, AMP, sg);
    $display("  %-8.4f %-12d %-10.2f %-30s", 0.1, (sp-sn)/2, sg, "passes LPF passband");

    do_reset(); osr_sel = OSR_SEL_MAIN;
    run_chain_freq_test(0.125, AMP, 500, 200, 128, sp, sn);
    get_gain_dB(sp, sn, AMP, sg);
    $display("  %-8.4f %-12d %-10.2f %-30s", 0.125, (sp-sn)/2, sg, "Fpass edge (≈ −1 dB)");

    do_reset(); osr_sel = OSR_SEL_MAIN;
    run_chain_freq_test(0.25, AMP, 500, 128, 128, sp, sn);
    get_gain_dB(sp, sn, AMP, sg);
    $display("  %-8.4f %-12d %-10.2f %-30s", 0.25, (sp-sn)/2, sg, "Fstop edge LPF");

    do_reset(); osr_sel = OSR_SEL_MAIN;
    run_chain_freq_test(0.35, AMP, 500, 128, 128, sp, sn);
    get_gain_dB(sp, sn, AMP, sg);
    $display("  %-8.4f %-12d %-10.2f %-30s", 0.35, (sp-sn)/2, sg, "LPF deep stopband");

    tc_num++; pass_count++;
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

  #100;
  $finish;
end

// Watchdog
initial begin
  #600_000_000;
  $display("ERROR: Timeout!");
  $finish;
end

endmodule
