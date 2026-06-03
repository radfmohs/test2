// ============================================================================
// Standalone testbench : nirs_ppg_idac_ctrl
// ----------------------------------------------------------------------------
// Verifies the current-DAC hysteresis loop documented in README section 12
// ("hysteresis control of the current DAC ... adjusts the output of the current
//  DAC automatically whenever the output of the ac path exceeds the threshold
//  window") and registers NIRS_CTRL_2/3/4/5/6 + NIRS_DEBUG_4:
//   * IDAC is 9-bit (max 0x1FF, min 0x000)        (NIRS_CTRL_INT IDAC_MIN/MAX)
//   * DOUT_AC > THRESHOLD_H        -> IDAC++ (clamped at 0x1FF)
//   * DOUT_AC < THRESHOLD_L        -> IDAC-- (clamped at 0x000)
//   * within window                -> IDAC holds
//   * DOUTF==0 or IDAC_INCREASE    -> forced IDAC++
//   * IDAC_MANUAL_EN=1             -> IDAC == IDAC_MANUAL
//   * IDAC_MAX / IDAC_MIN status flags
// ============================================================================
`timescale 1ns/1ps

module tb_nirs_ppg_idac_ctrl;

  localparam WIDTH = 13;

  reg               rst_n, clk;
  reg               IDAC_MANUAL_EN;
  reg               IDAC_INCREASE;
  reg  [8:0]        IDAC_MANUAL;
  reg               EN;
  reg  [WIDTH-1:0]  DOUTF;
  reg  [21:0]       DOUT_AC;
  reg  [18:0]       THRESHOLD_H;
  reg  [7:0]        THRESHOLD_L;
  wire              IDAC_MAX, IDAC_MIN;
  wire [8:0]        IDAC;

  integer errors = 0;
  integer checks = 0;
  integer i;
  reg [8:0] model;     // golden model of IDAC_reg
  reg [8:0] prev_v;    // scratch
  reg       up, down;

  nirs_ppg_idac_ctrl #(.WIDTH(WIDTH)) dut (
    .rst_n          (rst_n),
    .clk            (clk),
    .IDAC_MANUAL_EN (IDAC_MANUAL_EN),
    .IDAC_INCREASE  (IDAC_INCREASE),
    .IDAC_MANUAL    (IDAC_MANUAL),
    .EN             (EN),
    .DOUTF          (DOUTF),
    .DOUT_AC        (DOUT_AC),
    .THRESHOLD_H    (THRESHOLD_H),
    .THRESHOLD_L    (THRESHOLD_L),
    .IDAC_MAX       (IDAC_MAX),
    .IDAC_MIN       (IDAC_MIN),
    .IDAC           (IDAC)
  );

  always #5 clk = ~clk;

  task do_reset;
    begin
      rst_n = 0; EN = 0; IDAC_MANUAL_EN = 0; IDAC_INCREASE = 0;
      IDAC_MANUAL = 0; DOUTF = 13'd100; DOUT_AC = 0; THRESHOLD_H = 0; THRESHOLD_L = 0;
      model = 0;
      @(negedge clk); @(negedge clk);
      rst_n = 1;
      @(negedge clk);
    end
  endtask

  // one EN cycle, update golden model, compare register output
  task step;
    begin
      EN = 1;
      @(negedge clk);
      EN = 0;
      up   = (DOUT_AC > THRESHOLD_H) || (DOUTF == {WIDTH{1'b0}}) || IDAC_INCREASE;
      down = (!up) && (DOUT_AC < THRESHOLD_L);
      if (up   && (model != 9'h1FF)) model = model + 1'b1;
      else if (down && (model != 9'h000)) model = model - 1'b1;
      checks = checks + 1;
      if (!IDAC_MANUAL_EN && (IDAC !== model)) begin
        errors = errors + 1;
        $display("  [FAIL] IDAC=%0d expected=%0d (DOUT_AC=%0d THn=%0d THl=%0d DOUTF=%0d inc=%0b)",
                 IDAC, model, DOUT_AC, THRESHOLD_H, THRESHOLD_L, DOUTF, IDAC_INCREASE);
      end
    end
  endtask

  task expect_eq;
    input [31:0] got; input [31:0] exp; input [255:0] msg;
    begin
      checks = checks + 1;
      if (got !== exp) begin
        errors = errors + 1;
        $display("  [FAIL] %0s : got=%0d exp=%0d", msg, got, exp);
      end else
        $display("  [ok]   %0s = %0d", msg, got);
    end
  endtask

  initial begin
    clk = 0;
    $dumpfile("tb_nirs_ppg_idac_ctrl.vcd");
    $dumpvars(0, tb_nirs_ppg_idac_ctrl);
    $display("==== nirs_ppg_idac_ctrl standalone test ====");

    // 1) Manual mode -> IDAC follows IDAC_MANUAL exactly
    $display("-- manual mode --");
    do_reset;
    IDAC_MANUAL_EN = 1;
    IDAC_MANUAL = 9'h0AA; @(negedge clk);
    expect_eq(IDAC, 9'h0AA, "manual IDAC 0xAA");
    IDAC_MANUAL = 9'h1FF; @(negedge clk);
    expect_eq(IDAC, 9'h1FF, "manual IDAC 0x1FF");

    // 2) Auto increment when above high threshold
    $display("-- auto increment above THRESHOLD_H --");
    do_reset;
    THRESHOLD_H = 19'd1000; THRESHOLD_L = 8'd10; DOUT_AC = 22'd5000; DOUTF = 13'd50;
    for (i = 0; i < 20; i = i + 1) step;
    expect_eq(IDAC, model, "IDAC after 20 increments");
    if (IDAC == 0) errors = errors + 1; // sanity: should have moved

    // 3) Auto decrement when below low threshold
    $display("-- auto decrement below THRESHOLD_L --");
    DOUT_AC = 22'd0; THRESHOLD_L = 8'd200; DOUTF = 13'd50; // DOUT_AC < TL
    for (i = 0; i < 5; i = i + 1) step;
    expect_eq(IDAC, model, "IDAC after 5 decrements");

    // 4) Hold within window
    $display("-- hold within hysteresis window --");
    DOUT_AC = 22'd100; THRESHOLD_H = 19'd1000; THRESHOLD_L = 8'd10; DOUTF = 13'd50;
    prev_v = IDAC;
    for (i = 0; i < 8; i = i + 1) step;
    expect_eq(IDAC, prev_v, "IDAC unchanged within window");

    // 5) DOUTF==0 forces increment regardless of thresholds
    $display("-- DOUTF==0 forces increment --");
    DOUT_AC = 22'd0; THRESHOLD_L = 8'd255; DOUTF = 13'd0;
    prev_v = IDAC;
    step;
    expect_eq(IDAC, (prev_v==9'h1FF)?prev_v:prev_v+1, "IDAC++ when DOUTF==0");

    // 6) IDAC_INCREASE forces increment
    $display("-- IDAC_INCREASE forces increment --");
    DOUT_AC = 22'd0; THRESHOLD_L = 8'd255; DOUTF = 13'd50; IDAC_INCREASE = 1;
    prev_v = IDAC;
    step;
    expect_eq(IDAC, (prev_v==9'h1FF)?prev_v:prev_v+1, "IDAC++ when IDAC_INCREASE");
    IDAC_INCREASE = 0;

    // 7) Saturation at max (0x1FF) + IDAC_MAX flag
    $display("-- saturate at 0x1FF and IDAC_MAX flag --");
    do_reset;
    THRESHOLD_H = 19'd10; THRESHOLD_L = 8'd5; DOUT_AC = 22'd5000; DOUTF = 13'd50;
    for (i = 0; i < 600; i = i + 1) step; // more than 511 increments
    expect_eq(IDAC, 9'h1FF, "IDAC saturated at 0x1FF");
    @(negedge clk);
    expect_eq(IDAC_MAX, 1'b1, "IDAC_MAX flag set at max");

    // 8) Saturation at min (0x000) + IDAC_MIN flag
    $display("-- saturate at 0x000 and IDAC_MIN flag --");
    DOUT_AC = 22'd0; THRESHOLD_L = 8'd255; DOUTF = 13'd50; IDAC_INCREASE = 0;
    for (i = 0; i < 600; i = i + 1) step;
    expect_eq(IDAC, 9'h000, "IDAC saturated at 0x000");
    @(negedge clk);
    expect_eq(IDAC_MIN, 1'b1, "IDAC_MIN flag set at min");

    // 9) randomized regression of auto loop
    $display("-- randomized regression --");
    do_reset;
    for (i = 0; i < 1000; i = i + 1) begin
      DOUT_AC       = {$random} % 22'd8000;
      THRESHOLD_H   = {$random} % 19'd4000;
      THRESHOLD_L   = {$random} % 8'd200;
      DOUTF         = {$random} % 13'd200;
      IDAC_INCREASE = $random;
      step;
    end
    expect_eq(IDAC, model, "IDAC matches model after random loop");

    $display("==== checks=%0d errors=%0d ====", checks, errors);
    if (errors == 0) $display("RESULT: PASS"); else $display("RESULT: FAIL");
    $finish;
  end

endmodule
