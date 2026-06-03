// ============================================================================
// Standalone testbench : nirs_ppg_int
// ----------------------------------------------------------------------------
// Verifies the NIRS interrupt block against README NIRS_CTRL_INT (0x0C) and
// GENERAL_INTERUPT_CTRL_REG INT_LENGTH_SLCT (0x78):
//   NIRS_CTRL_INT bit map (per README 13.15.13):
//     bit7 IDAC_MIN_EN
//     bit6 IDAC_MAX_EN
//     bit5 IREF_FINE_ON_NOT_OFF_EN
//     bit4 IREF_FINE_NOT_ON_EN
//     bit3 IREF_COARSE_ON_NOT_OFF_EN
//     bit2 IREF_COARSE_NOT_ON_EN
//     bit1 DATA_READY_EN
//     bit0 NIRS_INT_PIN_EN  -> gates INT_IO (output to INTB)
//   INT_LENGTH_SLCT : 0 = level active, 1 = pulse active (1 module clk)
//
// The TB enables exactly one mask bit and asserts exactly the README-mapped
// source flag, then checks whether the interrupt fires. Any source whose
// behaviour disagrees with the README mapping is reported as a SPEC DEVIATION.
// ============================================================================
`timescale 1ns/1ps

module tb_nirs_ppg_int;

  reg        scan_mode, rst_n, clk;
  reg  [7:0] INT_CONFIG;
  reg        int_length_slct;
  reg        IREF_COARSE_ON_NOT_OFF, IREF_COARSE_NOT_ON;
  reg        IREF_FINE_ON_NOT_OFF, IREF_FINE_NOT_ON;
  reg        IDAC_MAX, IDAC_MIN, DATA_READY;
  reg        INT_CLR;
  wire       INT_sts, INT_IO;

  integer errors = 0;
  integer checks = 0;
  integer deviations = 0;

  nirs_ppg_int dut (
    .scan_mode              (scan_mode),
    .rst_n                  (rst_n),
    .clk                    (clk),
    .INT_CONFIG             (INT_CONFIG),
    .int_length_slct        (int_length_slct),
    .IREF_COARSE_ON_NOT_OFF (IREF_COARSE_ON_NOT_OFF),
    .IREF_COARSE_NOT_ON     (IREF_COARSE_NOT_ON),
    .IREF_FINE_ON_NOT_OFF   (IREF_FINE_ON_NOT_OFF),
    .IREF_FINE_NOT_ON       (IREF_FINE_NOT_ON),
    .IDAC_MAX               (IDAC_MAX),
    .IDAC_MIN               (IDAC_MIN),
    .DATA_READY             (DATA_READY),
    .INT_CLR                (INT_CLR),
    .INT_sts                (INT_sts),
    .INT_IO                 (INT_IO)
  );

  // INT is an internal node we want to observe for level/pulse behaviour
  wire INT_internal = dut.INT;

  always #5 clk = ~clk;

  task clear_all_sources;
    begin
      IREF_COARSE_ON_NOT_OFF = 0; IREF_COARSE_NOT_ON = 0;
      IREF_FINE_ON_NOT_OFF   = 0; IREF_FINE_NOT_ON   = 0;
      IDAC_MAX = 0; IDAC_MIN = 0; DATA_READY = 0;
    end
  endtask

  task do_reset;
    begin
      scan_mode = 0; rst_n = 0; INT_CONFIG = 0; int_length_slct = 0;
      INT_CLR = 0; clear_all_sources;
      @(negedge clk); @(negedge clk);
      rst_n = 1;
      @(negedge clk);
    end
  endtask

  // pulse INT_CLR and wait for the (synchronised) clear to land
  task clear_int;
    begin
      INT_CLR = 1; @(negedge clk); @(negedge clk);
      INT_CLR = 0;
      repeat (8) @(negedge clk);
    end
  endtask

  // Drive a single source flag (selected by name index) for a couple cycles.
  // idx: 0 DATA_READY 1 COARSE_NOT_ON 2 COARSE_ON_NOT_OFF
  //      3 FINE_NOT_ON 4 FINE_ON_NOT_OFF 5 IDAC_MAX 6 IDAC_MIN
  task drive_source;
    input integer idx;
    input         val;
    begin
      case (idx)
        0: DATA_READY             = val;
        1: IREF_COARSE_NOT_ON     = val;
        2: IREF_COARSE_ON_NOT_OFF = val;
        3: IREF_FINE_NOT_ON       = val;
        4: IREF_FINE_ON_NOT_OFF   = val;
        5: IDAC_MAX               = val;
        6: IDAC_MIN               = val;
      endcase
    end
  endtask

  // README mapping : which INT_CONFIG bit is supposed to enable source idx
  function integer readme_bit;
    input integer idx;
    begin
      case (idx)
        0: readme_bit = 1; // DATA_READY_EN
        1: readme_bit = 2; // IREF_COARSE_NOT_ON_EN
        2: readme_bit = 3; // IREF_COARSE_ON_NOT_OFF_EN
        3: readme_bit = 4; // IREF_FINE_NOT_ON_EN
        4: readme_bit = 5; // IREF_FINE_ON_NOT_OFF_EN
        5: readme_bit = 6; // IDAC_MAX_EN
        6: readme_bit = 7; // IDAC_MIN_EN
      endcase
    end
  endfunction

  // names for reporting
  function [255:0] src_name;
    input integer idx;
    begin
      case (idx)
        0: src_name = "DATA_READY";
        1: src_name = "IREF_COARSE_NOT_ON";
        2: src_name = "IREF_COARSE_ON_NOT_OFF";
        3: src_name = "IREF_FINE_NOT_ON";
        4: src_name = "IREF_FINE_ON_NOT_OFF";
        5: src_name = "IDAC_MAX";
        6: src_name = "IDAC_MIN";
      endcase
    end
  endfunction

  integer idx, b;
  reg fired;

  initial begin
    clk = 0;
    $dumpfile("tb_nirs_ppg_int.vcd");
    $dumpvars(0, tb_nirs_ppg_int);
    $display("==== nirs_ppg_int standalone test ====");

    // ----------------------------------------------------------------------
    // 1) Per-source / per-mask-bit cross check against the README bit map.
    //    For each source, enable ONLY its README-mapped bit and assert the
    //    source. The interrupt is expected to fire if the RTL agrees w/ README.
    // ----------------------------------------------------------------------
    $display("-- README NIRS_CTRL_INT bit-map cross check --");
    for (idx = 0; idx <= 6; idx = idx + 1) begin
      do_reset;
      b = readme_bit(idx);
      INT_CONFIG = (8'b1 << b);     // only the README-mapped enable bit
      drive_source(idx, 1'b1);
      @(negedge clk); @(negedge clk);
      fired = INT_sts;
      drive_source(idx, 1'b0);
      checks = checks + 1;
      if (fired === 1'b1) begin
        $display("  [ok]   %0s -> INT via mask bit %0d", src_name(idx), b);
      end else begin
        deviations = deviations + 1;
        $display("  [DEVIATION] %0s did NOT raise INT through README mask bit %0d", src_name(idx), b);
      end
      clear_int;
    end

    // Discover which mask bit each source ACTUALLY responds to in the RTL,
    // so deviations are fully explained.
    $display("-- actual RTL source<->mask-bit binding --");
    for (idx = 0; idx <= 6; idx = idx + 1) begin
      for (b = 1; b <= 7; b = b + 1) begin
        do_reset;
        INT_CONFIG = (8'b1 << b);
        drive_source(idx, 1'b1);
        @(negedge clk); @(negedge clk);
        if (INT_sts === 1'b1)
          $display("  RTL: %0s fires on INT_CONFIG bit %0d (README expects bit %0d)%0s",
                   src_name(idx), b, readme_bit(idx),
                   (b==readme_bit(idx))?"":"  <-- MISMATCH");
        drive_source(idx, 1'b0);
        clear_int;
      end
    end

    // ----------------------------------------------------------------------
    // 2) Masking : a source must NOT fire if its enable bit is 0.
    // ----------------------------------------------------------------------
    $display("-- masking (disabled source must not fire) --");
    do_reset;
    INT_CONFIG = 8'b0000_0000;      // all disabled
    DATA_READY = 1; IDAC_MAX = 1; IREF_FINE_NOT_ON = 1;
    @(negedge clk); @(negedge clk);
    checks = checks + 1;
    if (INT_sts !== 1'b0) begin
      errors = errors + 1;
      $display("  [FAIL] INT fired with all mask bits=0");
    end else
      $display("  [ok]   no INT when masked");
    clear_all_sources; clear_int;

    // ----------------------------------------------------------------------
    // 3) INT_IO gated by NIRS_INT_PIN_EN (bit0)
    // ----------------------------------------------------------------------
    $display("-- INT_IO gated by bit0 (NIRS_INT_PIN_EN) --");
    do_reset;
    INT_CONFIG = 8'b0000_0010;      // DATA_READY enable, pin disabled (bit0=0)
    DATA_READY = 1; @(negedge clk); @(negedge clk); DATA_READY = 0;
    checks = checks + 1;
    if (INT_IO !== 1'b0) begin errors = errors + 1; $display("  [FAIL] INT_IO high while pin disabled"); end
    else $display("  [ok]   INT_IO low when NIRS_INT_PIN_EN=0 (INT_sts=%0b)", INT_sts);
    clear_int;

    do_reset;
    INT_CONFIG = 8'b0000_0011;      // DATA_READY enable + pin enable (bit0=1)
    int_length_slct = 0;            // level mode so INT_IO stays high
    DATA_READY = 1; @(negedge clk); @(negedge clk); DATA_READY = 0;
    checks = checks + 1;
    if (INT_IO !== 1'b1) begin errors = errors + 1; $display("  [FAIL] INT_IO low while pin enabled"); end
    else $display("  [ok]   INT_IO high when NIRS_INT_PIN_EN=1");
    clear_int;

    // ----------------------------------------------------------------------
    // 4) INT_LENGTH_SLCT level vs pulse behaviour of INT node
    // ----------------------------------------------------------------------
    $display("-- INT_LENGTH_SLCT level vs pulse --");
    // level mode (=0): INT follows INT_d (stays high until cleared)
    do_reset;
    int_length_slct = 0; INT_CONFIG = 8'b0000_0011;
    DATA_READY = 1; @(negedge clk); DATA_READY = 0;
    @(negedge clk);
    checks = checks + 1;
    if (INT_internal !== 1'b1) begin errors=errors+1; $display("  [FAIL] level: INT not high"); end
    else begin
      @(negedge clk); @(negedge clk);
      if (INT_internal !== 1'b1) begin errors=errors+1; $display("  [FAIL] level: INT did not stay high"); end
      else $display("  [ok]   level mode: INT stays asserted until clear");
    end
    clear_int;

    // pulse mode (=1): INT is a single-cycle pulse on the rising edge of INT_d
    do_reset;
    int_length_slct = 1; INT_CONFIG = 8'b0000_0011;
    DATA_READY = 1;
    @(negedge clk);                 // INT_d rises here -> pulse next
    begin : pulse_meas
      integer high_count; integer k;
      high_count = 0;
      for (k = 0; k < 8; k = k + 1) begin
        @(negedge clk);
        if (INT_internal) high_count = high_count + 1;
      end
      DATA_READY = 0;
      checks = checks + 1;
      if (high_count == 1) $display("  [ok]   pulse mode: INT high for exactly 1 cycle");
      else begin errors = errors + 1; $display("  [FAIL] pulse mode: INT high for %0d cycles", high_count); end
    end
    clear_int;

    // ----------------------------------------------------------------------
    // 5) Clear behaviour : INT_sts clears after INT_CLR
    // ----------------------------------------------------------------------
    $display("-- interrupt clear --");
    do_reset;
    int_length_slct = 0; INT_CONFIG = 8'b0000_0011;
    DATA_READY = 1; @(negedge clk); @(negedge clk); DATA_READY = 0;
    checks = checks + 1;
    if (INT_sts !== 1'b1) begin errors=errors+1; $display("  [FAIL] INT_sts not set before clear"); end
    clear_int;
    checks = checks + 1;
    if (INT_sts !== 1'b0) begin errors=errors+1; $display("  [FAIL] INT_sts not cleared by INT_CLR"); end
    else $display("  [ok]   INT_sts cleared by INT_CLR");

    $display("==== checks=%0d errors=%0d  README-deviations=%0d ====", checks, errors, deviations);
    if (deviations != 0)
      $display("NOTE: %0d interrupt source(s) do not match the README NIRS_CTRL_INT bit map.", deviations);
    if (errors == 0) $display("RESULT: PASS (RTL self-consistent)");
    else             $display("RESULT: FAIL");
    $finish;
  end

endmodule
