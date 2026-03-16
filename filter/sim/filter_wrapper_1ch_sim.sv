// =============================================================================
// filter_wrapper_1ch_sim.sv
// Single-channel simulation model of filter_wrapper (iverilog-compatible)
//
// PURPOSE
// -------
// filter_wrapper.sv uses unpacked-array ports (`[DW-1:0] imeas_chdata_in[N-1:0]`)
// which iverilog 12 cannot elaborate at instantiation time (it crashes with an
// internal assertion).  This module provides an identical 1-channel (CHN_NUM=1)
// implementation with fully scalar/packed ports so that iverilog can compile and
// simulate the complete filter chain.
//
// The clock-gating sequencer logic below is copied verbatim from
// filter_wrapper.sv so the timing behaviour under test is identical.
//
// FILTER ORDER (LPF → Notch → HPF — same as filter_wrapper)
//   input → filter5 → LPF(32) → filter6
//          filter3 = filter6 → Notch(42) → filter4
//          filter1 = filter4 → HPF(1)    → filter2
//          output = filter2
//
// CLOCK GATING (exact replica from filter_wrapper.sv)
//   lpf_clk_gtg_en   — chdata_en_pulse OR lpf_filter_enable
//                       de-asserts when lpf_filter_enable_cnt == 5'b11110
//   notch_clk_gtg_en — notch_filter_enable (set by lpf_filter_out_en,
//                       cleared when notch_filter_enable_cnt == 6'b10_1001)
//   hpf_clk_gtg_en   — hpf_chdata_en (single-cycle pulse from notch done)
//
// AUTO-BYPASS (exact replica from filter_wrapper.sv)
//   data_rate_add = iclk_div + osr_sel
//   LPF  bypassed when data_rate_add < 2  or > 15
//   Notch bypassed when data_rate_add < 4  or > 13 OR data_rate_notch outside [2,11]
//   HPF  bypassed only by register (hpf_filter_bypass)
// =============================================================================
`timescale 1ns/1ps

module filter_wrapper_1ch_sim #(
  parameter DATA_WIDTH = 32
)(
  // Base clock (≤ 8 MHz in the real chip)
  input  wire        adc_clk,
  input  wire        pclk,          // peripheral clock (can = adc_clk in TB)
  input  wire        reset,         // active-low reset (shared with all filters)
  input  wire        sign_en,
  input  wire        scan_mode,

  // OSR / clock-divide settings (determines auto-bypass behaviour)
  input  wire [3:0]  osr_sel,       // CIC decimation rate selector
  input  wire [3:0]  iclk_div,      // additional clock divider

  // Interrupt control
  input  wire        int_length_slct,
  input  wire [1:0]  eeg_int_en,
  input  wire        eeg_int_clr,
  input  wire [15:0] cic_data_ignore_tar,
  input  wire        i_imeas_intr_clr,

  // Coefficient buses (passed directly to filter instances)
  input  wire [23:0]       hpf_coeff_data,
  input  wire signed [17:0] lpf_coeff_data   [31:0],
  input  wire signed [19:0] notch_coeff_data [41:0],

  // Per-filter bypass (register-controlled)
  input  wire        notch_filter_bypass,
  input  wire        lpf_filter_bypass,
  input  wire        hpf_filter_bypass,

  // CIC sample interface (scalar — 1 channel)
  input  wire [DATA_WIDTH-1:0] imeas_chdata_in,
  input  wire        chdata_en,     // 1-cycle pulse per CIC output sample

  // Gated-clock enables (connect to common_clock_gate inputs in TB)
  output wire        lpf_clk_gtg_en,
  output wire        notch_clk_gtg_en,
  output wire        hpf_clk_gtg_en,

  // Gated clocks (fed back from common_clock_gate cells in testbench)
  input  wire        lpf_clk,
  input  wire        notch_clk,
  input  wire        hpf_clk,

  // Filter output + status
  output wire [DATA_WIDTH-1:0] imeas_chdata_out,
  output wire        notch_filter_valid,
  output wire        o_eeg_int,
  output reg         eeg_int_sts,
  output reg         meas_done_d1
);

// ---------------------------------------------------------------------------
// Internal filter interconnect
// ---------------------------------------------------------------------------
wire [DATA_WIDTH-1:0] filter1, filter2, filter3, filter4, filter5, filter6;
wire [DATA_WIDTH-1:0] imeas_chdata_out_temp;

// Filter chain order: LPF → Notch → HPF  (same as filter_wrapper L-N-H case)
assign filter5              = imeas_chdata_in;  // LPF input  = CIC output
assign filter3              = filter6;          // Notch input = LPF output
assign filter1              = filter4;          // HPF input   = Notch output
assign imeas_chdata_out_temp= filter2;          // chain output = HPF output

// ---------------------------------------------------------------------------
// Auto-bypass computations (verbatim from filter_wrapper.sv)
// ---------------------------------------------------------------------------
wire [4:0] data_rate_add;
wire [3:0] data_rate_notch;
wire       data_rate_by_pass;
wire       data_rate_by_pass_lpf;
wire       notch_filter_osr_valid;

assign data_rate_notch    = (data_rate_add <= 4'h3) ? 4'h0
                            : (osr_sel - 4'h2 + iclk_div);
assign data_rate_add      = {1'b0, iclk_div} + {1'b0, osr_sel};
assign data_rate_by_pass  = ~((data_rate_add >= 5'h4) & (data_rate_add <= 5'hd));
assign data_rate_by_pass_lpf = ~((data_rate_add >= 5'h2) & (data_rate_add <= 5'hf));

assign notch_filter_osr_valid = ~((data_rate_notch >= 4'h2) & (data_rate_notch <= 4'hb));

wire notch_filter_bypass_temp = notch_filter_bypass | notch_filter_osr_valid
                                | data_rate_by_pass;
wire lpf_filter_bypass_temp   = lpf_filter_bypass | data_rate_by_pass_lpf;
wire hpf_filter_bypass_temp   = hpf_filter_bypass;

assign notch_filter_valid = notch_filter_bypass_temp;

// ---------------------------------------------------------------------------
// LPF instance
// ---------------------------------------------------------------------------
wire lpf_filter_out_en_temp;
wire [4:0] lpf_filter_enable_cnt;

filter_fir_lpf u_lpf (
  .clk          (lpf_clk),
  .clk_enable   (1'b1),
  .reset        (reset),
  .sign_en      (sign_en),
  .bypass       (lpf_filter_bypass_temp),
  .o_cur_count  (lpf_filter_enable_cnt),
  .lpf_coeff_data(lpf_coeff_data),
  .filter_out_en(lpf_filter_out_en_temp),
  .filter_in    (filter5),
  .filter_out   (filter6)
);

wire lpf_filter_out_en = lpf_filter_bypass_temp ? chdata_en_pulse : lpf_filter_out_en_temp;

// ---------------------------------------------------------------------------
// Notch instance
// ---------------------------------------------------------------------------
wire [5:0] notch_filter_enable_cnt;

notch_filter u_notch (
  .clk             (notch_clk),
  .clk_enable      (1'b1),
  .reset           (reset),
  .sign_en         (sign_en),
  .bypass          (notch_filter_bypass_temp),
  .filter_in       (filter3),
  .o_cur_count     (notch_filter_enable_cnt),
  .notch_coeff_data(notch_coeff_data),
  .filter_out      (filter4)
);

// ---------------------------------------------------------------------------
// HPF instance
// ---------------------------------------------------------------------------
filter_iir_hpf u_hpf (
  .clk        (hpf_clk),
  .clk_enable (1'b1),
  .reset_n    (reset),
  .sign_en    (sign_en),
  .bypass     (hpf_filter_bypass_temp),
  .coeff      (hpf_coeff_data),
  .filter_in  (filter1),
  .filter_out (filter2)
);

// ---------------------------------------------------------------------------
// chdata_en rising-edge detector (verbatim from filter_wrapper)
// ---------------------------------------------------------------------------
wire chdata_en_pulse;
common_pulse_rising u_chdata_en_pulse (
  .d_in (chdata_en),
  .clk  (adc_clk),
  .rst_ (reset),
  .d_out(chdata_en_pulse)
);

// ---------------------------------------------------------------------------
// LPF clock-gate enable sequencer (verbatim from filter_wrapper.sv)
// ---------------------------------------------------------------------------
reg lpf_filter_enable;

always @ (posedge adc_clk or negedge reset) begin
  if (!reset)
    lpf_filter_enable <= 1'b0;
  else if (chdata_en_pulse & !lpf_filter_bypass_temp)
    lpf_filter_enable <= 1'b1;
  else if (lpf_filter_enable) begin
    if (lpf_filter_enable_cnt == 5'b11110)
      lpf_filter_enable <= 1'b0;
    else
      lpf_filter_enable <= 1'b1;
  end else
    lpf_filter_enable <= 1'b0;
end

assign lpf_clk_gtg_en = !lpf_filter_bypass_temp & (chdata_en_pulse | lpf_filter_enable);

// ---------------------------------------------------------------------------
// Notch clock-gate enable sequencer (verbatim from filter_wrapper.sv)
// ---------------------------------------------------------------------------
reg  notch_filter_enable;
reg  notch_chdata_en_temp;

always @ (posedge adc_clk or negedge reset) begin
  if (!reset) begin
    notch_filter_enable  <= 1'b0;
    notch_chdata_en_temp <= 1'b0;
  end else if (lpf_filter_out_en & !notch_filter_bypass_temp) begin
    notch_filter_enable  <= 1'b1;
    notch_chdata_en_temp <= 1'b0;
  end else if (notch_filter_enable) begin
    if (notch_filter_enable_cnt == 6'b10_1001) begin
      notch_filter_enable  <= 1'b0;
      notch_chdata_en_temp <= 1'b1;
    end else begin
      notch_filter_enable  <= 1'b1;
      notch_chdata_en_temp <= 1'b0;
    end
  end else begin
    notch_filter_enable  <= 1'b0;
    notch_chdata_en_temp <= 1'b0;
  end
end

assign notch_clk_gtg_en = !notch_filter_bypass_temp & notch_filter_enable;

wire notch_chdata_en = notch_filter_bypass_temp ? lpf_filter_out_en : notch_chdata_en_temp;

// ---------------------------------------------------------------------------
// HPF clock-gate enable sequencer (verbatim from filter_wrapper.sv)
// ---------------------------------------------------------------------------
reg  hpf_chdata_en_temp;

always @ (posedge adc_clk or negedge reset) begin
  if (!reset)
    hpf_chdata_en_temp <= 1'b0;
  else if (notch_chdata_en & !hpf_filter_bypass_temp)
    hpf_chdata_en_temp <= 1'b1;
  else
    hpf_chdata_en_temp <= 1'b0;
end

wire hpf_chdata_en = hpf_filter_bypass_temp ? notch_chdata_en : hpf_chdata_en_temp;

assign hpf_clk_gtg_en = !hpf_filter_bypass_temp & hpf_chdata_en;

// ---------------------------------------------------------------------------
// cic_data_ignore counter and output gating (verbatim from filter_wrapper.sv)
// ---------------------------------------------------------------------------
wire meas_done = hpf_chdata_en;   // final stage complete = chain done

// CDC sync (simplified: pclk = adc_clk in testbench, so just a 2-FF sync)
reg  [15:0] cic_data_counter;
wire [15:0] cic_data_counter_tar_sync;  // after CDC
wire        cic_data_counter_clr;

// Simplified CDC: just register through two FFs on pclk
reg  [15:0] cic_data_counter_tar_d1, cic_data_counter_tar_d2;
always @ (posedge pclk or negedge reset) begin
  if (!reset) begin
    cic_data_counter_tar_d1 <= 0;
    cic_data_counter_tar_d2 <= 0;
  end else begin
    cic_data_counter_tar_d1 <= cic_data_ignore_tar;
    cic_data_counter_tar_d2 <= cic_data_counter_tar_d1;
  end
end

wire clr_strobe = (cic_data_counter_tar_d1 != cic_data_counter_tar_d2);

always @ (posedge pclk or negedge reset) begin
  if (!reset)
    cic_data_counter <= 0;
  else if (clr_strobe)
    cic_data_counter <= 0;
  else if (meas_done & (cic_data_counter != cic_data_counter_tar_d2))
    cic_data_counter <= cic_data_counter + 1;
end

wire cic_data_ok = (cic_data_counter == cic_data_counter_tar_d2);

assign imeas_chdata_out = imeas_chdata_out_temp &
  ({DATA_WIDTH{cic_data_ok}} |
   {DATA_WIDTH{notch_filter_bypass_temp & lpf_filter_bypass_temp}});

// ---------------------------------------------------------------------------
// Interrupt generation (verbatim from filter_wrapper.sv)
// ---------------------------------------------------------------------------
// eeg_int_sts pulse
wire eeg_int_sts_pulse;
common_pulse_rising u_eeg_int_sts_pulse (
  .d_in (eeg_int_sts),
  .clk  (pclk),
  .rst_ (reset),
  .d_out(eeg_int_sts_pulse)
);

// eeg_sts_clr synchroniser
wire eeg_sts_clr_sync_pulse;
common_pulse_async_clr u_eeg_clr_sync (
  .d_in     (eeg_int_clr),
  .clk      (pclk),
  .rst_     (reset),
  .int_sts  (eeg_int_sts),
  .scan_mode(scan_mode),
  .d_out    (eeg_sts_clr_sync_pulse)
);

wire eeg_int_en_sync;
common_sync_bit u_eeg_int_en_sync (
  .clk      (pclk),
  .rst_     (reset),
  .async_in (eeg_int_en[1]),
  .sync_out (eeg_int_en_sync)
);

wire eeg_imeas_sts_clr_sync_pulse;
common_pulse_async_clr u_eeg_imeas_clr_sync (
  .d_in     (i_imeas_intr_clr),
  .clk      (pclk),
  .rst_     (reset),
  .int_sts  (eeg_int_sts),
  .scan_mode(scan_mode),
  .d_out    (eeg_imeas_sts_clr_sync_pulse)
);

always @ (posedge pclk or negedge reset) begin
  if (!reset)
    eeg_int_sts <= 1'b0;
  else if (eeg_sts_clr_sync_pulse | !eeg_int_en_sync | eeg_imeas_sts_clr_sync_pulse)
    eeg_int_sts <= 1'b0;
  else if (filter_chdata_en & (cic_data_ok |
           (notch_filter_bypass_temp & lpf_filter_bypass_temp)))
    eeg_int_sts <= 1'b1;
  else
    eeg_int_sts <= eeg_int_sts;
end

assign o_eeg_int = ((eeg_int_sts & !int_length_slct) |
                    (eeg_int_sts_pulse & int_length_slct)) & eeg_int_en[0];

// common_pulse_sync for filter_chdata_en (CDC from adc_clk to pclk)
// filter_chdata_en is the pclk-domain version of hpf_chdata_en; it is the
// authoritative "chain output ready" signal used for interrupts and meas_done.
wire filter_chdata_en;
common_pulse_sync u_chdata_en_sync (
  .i_a_clk  (adc_clk),
  .i_b_clk  (pclk),
  .i_a_rst_n(reset),
  .i_b_rst_n(reset),
  .i_test_mode(scan_mode),
  .i_a_pulse(hpf_chdata_en),
  .o_a_ready(),
  .o_b_pulse(filter_chdata_en)
);

// meas_done_d1 and eeg_int_sts use filter_chdata_en (pclk-domain), NOT
// hpf_chdata_en (adc_clk-domain).  Using the wrong domain signal in the
// always block clocked by pclk is a CDC violation.
always @ (posedge pclk or negedge reset) begin
  if (!reset)
    meas_done_d1 <= 1'b0;
  else if (cic_data_ok | (notch_filter_bypass_temp & lpf_filter_bypass_temp))
    meas_done_d1 <= filter_chdata_en;
end

endmodule
