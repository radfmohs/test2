// ============================================================================
// Standalone testbench : nirs_ppg_cmd  (+ nirs_ppg_clk / common_clock_gate)
// ----------------------------------------------------------------------------
// Verifies the SPI command decoder and clock-gating behaviour documented in
// README NIRS_CTRL_CMD (0x0F):
//     00: HOLD   01: START   10: MEAS (MCU only)   11: STOP (continuous only)
// and the "ENABLE cmd starts the clks / CLK stops when counter holds / MEAS
// resumes the clks" description.
//   * START turns the gated sys+ppg clocks on and raises NIRS_PPG_EN.
//   * CLK_STOP (from the ctrl counter) gates the clocks off again.
//   * MEAS re-starts the clocks and pulses NIRS_PPG_MEAS.
//   * STOP clears NIRS_PPG_EN.
//   * NIRS_SINGLE makes NIRS_PPG_EN a single-shot (auto-clears).
//
// Compile with -DFPGA so common_clock_gate uses its behavioural model.
// ============================================================================
`timescale 1ns/1ps

module tb_nirs_ppg_cmd;

  reg        rst_n, atpg_en, clk_gate_bypass;
  reg        i_clk_sys, i_clk_ppg;
  wire       o_clk_sys_gated, o_clk_ppg_gated;
  reg  [1:0] CMD;
  reg        NIRS_SINGLE;
  wire       NIRS_PPG_EN, NIRS_PPG_MEAS;
  reg        CLK_STOP;

  integer errors = 0;
  integer checks = 0;

  integer sys_edges, ppg_edges;
  reg     saw_meas;

  nirs_ppg_cmd dut (
    .rst_n          (rst_n),
    .atpg_en        (atpg_en),
    .clk_gate_bypass(clk_gate_bypass),
    .i_clk_sys      (i_clk_sys),
    .i_clk_ppg      (i_clk_ppg),
    .o_clk_sys_gated(o_clk_sys_gated),
    .o_clk_ppg_gated(o_clk_ppg_gated),
    .CMD            (CMD),
    .NIRS_SINGLE    (NIRS_SINGLE),
    .NIRS_PPG_EN    (NIRS_PPG_EN),
    .NIRS_PPG_MEAS  (NIRS_PPG_MEAS),
    .CLK_STOP       (CLK_STOP)
  );

  // free running source clocks
  always #20 i_clk_sys = ~i_clk_sys;   // 25 MHz-ish, period 40
  always #5  i_clk_ppg = ~i_clk_ppg;   // faster

  // gated-clock activity counters
  always @(posedge o_clk_sys_gated) sys_edges = sys_edges + 1;
  always @(posedge o_clk_ppg_gated) ppg_edges = ppg_edges + 1;
  always @(posedge o_clk_sys_gated) if (NIRS_PPG_MEAS) saw_meas = 1;

  task win_reset; begin sys_edges=0; ppg_edges=0; end endtask

  // wait n source-sys cycles
  task wait_sys; input integer n; integer k; begin for(k=0;k<n;k=k+1) @(posedge i_clk_sys); end endtask

  task chk; input v; input [511:0] m; begin
    checks=checks+1;
    if (v!==1'b1) begin errors=errors+1; $display("  [FAIL] %0s", m); end
    else $display("  [ok]   %0s", m);
  end endtask

  task chk_gt; input integer g; input integer thr; input [511:0] m; begin
    checks=checks+1;
    if (!(g>thr)) begin errors=errors+1; $display("  [FAIL] %0s : count=%0d (expected > %0d)", m,g,thr); end
    else $display("  [ok]   %0s : count=%0d", m, g);
  end endtask

  task chk_eq; input integer g; input integer e; input [511:0] m; begin
    checks=checks+1;
    if (g!==e) begin errors=errors+1; $display("  [FAIL] %0s : count=%0d (expected %0d)", m,g,e); end
    else $display("  [ok]   %0s : count=%0d", m, g);
  end endtask

  initial begin
    i_clk_sys=0; i_clk_ppg=0;
    $dumpfile("tb_nirs_ppg_cmd.vcd");
    $dumpvars(0, tb_nirs_ppg_cmd);
    $display("==== nirs_ppg_cmd standalone test ====");

    rst_n=0; atpg_en=0; clk_gate_bypass=0; CMD=2'b00; NIRS_SINGLE=0; CLK_STOP=0;
    saw_meas=0; win_reset;
    wait_sys(2); rst_n=1; wait_sys(2);

    // 1) After reset, gated clocks are OFF (CLK_EN=0)
    $display("-- gated clocks off after reset --");
    win_reset; wait_sys(6);
    chk_eq(sys_edges, 0, "sys gated clock idle after reset");
    chk_eq(ppg_edges, 0, "ppg gated clock idle after reset");

    // 2) START turns the clocks on and raises NIRS_PPG_EN
    $display("-- CMD=START enables clocks + NIRS_PPG_EN --");
    CMD=2'b01; wait_sys(6);
    win_reset; wait_sys(8);
    chk_gt(sys_edges, 0, "sys gated clock running after START");
    chk_gt(ppg_edges, 0, "ppg gated clock running after START");
    chk   (NIRS_PPG_EN, "NIRS_PPG_EN high after START");

    // 3) HOLD keeps it enabled
    $display("-- CMD=HOLD keeps NIRS_PPG_EN --");
    CMD=2'b00; wait_sys(6);
    chk(NIRS_PPG_EN, "NIRS_PPG_EN stays high during HOLD");

    // 4) CLK_STOP (from ctrl) gates the clocks off
    $display("-- CLK_STOP gates clocks off --");
    CLK_STOP=1; wait_sys(4); CLK_STOP=0;
    win_reset; wait_sys(8);
    chk_eq(sys_edges, 0, "sys gated clock stopped by CLK_STOP");
    chk_eq(ppg_edges, 0, "ppg gated clock stopped by CLK_STOP");

    // 5) MEAS re-starts the clocks and pulses NIRS_PPG_MEAS
    $display("-- CMD=MEAS resumes clocks + pulses NIRS_PPG_MEAS --");
    saw_meas=0;
    CMD=2'b10; wait_sys(8);
    win_reset; wait_sys(8);
    chk_gt(sys_edges, 0, "sys gated clock resumed after MEAS");
    chk   (saw_meas,    "NIRS_PPG_MEAS pulsed after MEAS");

    // 6) STOP clears NIRS_PPG_EN (clocks still running)
    $display("-- CMD=STOP clears NIRS_PPG_EN --");
    CMD=2'b11; wait_sys(6);
    chk(~NIRS_PPG_EN, "NIRS_PPG_EN cleared by STOP");
    CLK_STOP=1; wait_sys(3); CLK_STOP=0; CMD=2'b00; wait_sys(3);

    // 7) NIRS_SINGLE -> single-shot enable (auto clears)
    $display("-- NIRS_SINGLE single-shot enable --");
    rst_n=0; wait_sys(2); rst_n=1; CMD=2'b00; NIRS_SINGLE=1; CLK_STOP=0; wait_sys(2);
    CMD=2'b01;                          // START
    wait_sys(12);                       // let it run several gated cycles
    chk(~NIRS_PPG_EN, "NIRS_PPG_EN auto-cleared in single-shot mode");

    $display("==== checks=%0d errors=%0d ====", checks, errors);
    if (errors==0) $display("RESULT: PASS"); else $display("RESULT: FAIL");
    $finish;
  end

endmodule
