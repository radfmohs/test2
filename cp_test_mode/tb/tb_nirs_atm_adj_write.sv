//===========================================================================
// tb_nirs_atm_adj_write.sv
// Testbench: NIRS SPI ATM ADJ Register Write (ATM18-20 → nirs_ctrl_reg)
//
// ATM18/19/20 route to the spi_reg_nirs sub-block via atm_adj_mode[5:3]
// in spi_reg.sv (passed as atm_adj_mode[2:0] to spi_reg_nirs).
//
// spi_reg_nirs ATM write logic (lines 201-208 of spi_reg_nirs.sv):
//   ATM18 (mode[0]) or ATM19 (mode[1]):
//     nirs_ctrl_reg[4][1][7][4:3] <= atm_adj_data[1:0]  (IREF fine/coarse)
//     nirs_ctrl_reg[4][1][7][2:1] <= atm_adj_data[3:2]
//     NOTE: atm_adj_data[7:4] are SPARE bits tied to 0 per golden reference
//   ATM20 (mode[2]):
//     nirs_ctrl_reg[4][1][3][7:5] <= atm_adj_data[2:0]  (IDAC current)
//     nirs_ctrl_reg[4][1][2][4:0] <= atm_adj_data[7:3]
//
// Golden reference (ENS2_Digital_Pinmux_ascii.txt):
//   ATM18: NIRS IREF_COARSE measurement — SPARE ADJ bits not saved, tied to 0
//   ATM19: NIRS IREF_FINE measurement  — SPARE ADJ bits not saved, tied to 0
//   ATM20: NIRS IDAC measurement       — ADJ bits used for IDAC calibration
//
// Run with:
//   iverilog -g2012 -o sim_nirs_atm \
//     tb_nirs_atm_adj_write.sv \
//     && vvp sim_nirs_atm
//===========================================================================
`timescale 1ns/1ps

// ─────────────────────────────────────────────────────────────────────────────
// Standalone model: mirrors spi_reg_nirs.sv ATM write block (lines 201-208)
// nirs_ctrl_reg[4][1][reg_idx] is the target (channel=4, LED=1)
// ─────────────────────────────────────────────────────────────────────────────
module nirs_atm_adj_model (
  input  wire       i_clk,
  input  wire       i_rst_n,

  // ATM ADJ inputs (from spi_reg: atm_adj_mode[5:3] → here [2:0])
  input  wire [2:0] atm_adj_mode,  // [0]=ATM18, [1]=ATM19, [2]=ATM20
  input  wire       atm_adj,       // debug_mode_en
  input  wire [7:0] atm_adj_data,  // 8-bit adj value from GPIO1-8

  // Observation outputs: nirs_ctrl_reg[4][1][2,3,7]
  // (the only registers modified by ATM18/19/20)
  output reg [7:0]  nirs_ch4_led1_reg7,   // nirs_ctrl_reg[4][1][7]
  output reg [7:0]  nirs_ch4_led1_reg3,   // nirs_ctrl_reg[4][1][3]
  output reg [7:0]  nirs_ch4_led1_reg2    // nirs_ctrl_reg[4][1][2]
);

  // Reset defaults from spi_reg_nirs.sv lines 186-198:
  //   nirs_ctrl_reg[x][y][7] <= 8'h00
  //   nirs_ctrl_reg[x][y][3] <= 8'h07
  //   nirs_ctrl_reg[x][y][2] <= 8'h00
  always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      nirs_ch4_led1_reg7 <= 8'h00;
      nirs_ch4_led1_reg3 <= 8'h07;
      nirs_ch4_led1_reg2 <= 8'h00;
    end
    // ATM ADJ write — exact copy of spi_reg_nirs.sv lines 201-208
    else if (atm_adj) begin
      if (atm_adj_mode[0] || atm_adj_mode[1]) begin
        nirs_ch4_led1_reg7[4:3] <= atm_adj_data[1:0];
        nirs_ch4_led1_reg7[2:1] <= atm_adj_data[3:2];
      end else if (atm_adj_mode[2]) begin
        nirs_ch4_led1_reg3[7:5] <= atm_adj_data[2:0];
        nirs_ch4_led1_reg2[4:0] <= atm_adj_data[7:3];
      end
    end
  end

endmodule

// ─────────────────────────────────────────────────────────────────────────────
// Testbench
// ─────────────────────────────────────────────────────────────────────────────
module tb_nirs_atm_adj_write;

  reg       clk, rst_n;
  reg [2:0] atm_adj_mode;
  reg       atm_adj;
  reg [7:0] atm_adj_data;

  wire [7:0] nirs_ch4_led1_reg7;
  wire [7:0] nirs_ch4_led1_reg3;
  wire [7:0] nirs_ch4_led1_reg2;

  nirs_atm_adj_model dut (
    .i_clk           (clk),
    .i_rst_n         (rst_n),
    .atm_adj_mode    (atm_adj_mode),
    .atm_adj         (atm_adj),
    .atm_adj_data    (atm_adj_data),
    .nirs_ch4_led1_reg7 (nirs_ch4_led1_reg7),
    .nirs_ch4_led1_reg3 (nirs_ch4_led1_reg3),
    .nirs_ch4_led1_reg2 (nirs_ch4_led1_reg2)
  );

  initial clk = 0;
  always #50 clk = ~clk;

  task tick;
    input integer n;
    integer k;
    begin
      for (k = 0; k < n; k = k + 1)
        @(posedge clk);
      #1;
    end
  endtask

  integer pass_count, fail_count;

  initial begin
    pass_count = 0;
    fail_count = 0;

    rst_n = 1'b0;
    atm_adj_mode = 3'b000;
    atm_adj      = 1'b0;
    atm_adj_data = 8'h00;

    tick(5);
    rst_n = 1'b1;
    tick(2);

    // ── TEST 1: Check reset values ─────────────────────────────────────────
    $display("INFO: Checking reset values...");
    if (nirs_ch4_led1_reg7 !== 8'h00) begin
      $display("FAIL: reg7 reset: expected 8'h00, got 8'h%02h", nirs_ch4_led1_reg7);
      fail_count = fail_count + 1;
    end else begin
      $display("PASS: nirs_ctrl_reg[4][1][7] reset = 8'h00"); pass_count = pass_count + 1;
    end
    if (nirs_ch4_led1_reg3 !== 8'h07) begin
      $display("FAIL: reg3 reset: expected 8'h07, got 8'h%02h", nirs_ch4_led1_reg3);
      fail_count = fail_count + 1;
    end else begin
      $display("PASS: nirs_ctrl_reg[4][1][3] reset = 8'h07"); pass_count = pass_count + 1;
    end
    if (nirs_ch4_led1_reg2 !== 8'h00) begin
      $display("FAIL: reg2 reset: expected 8'h00, got 8'h%02h", nirs_ch4_led1_reg2);
      fail_count = fail_count + 1;
    end else begin
      $display("PASS: nirs_ctrl_reg[4][1][2] reset = 8'h00"); pass_count = pass_count + 1;
    end

    // ── TEST 2: ATM18 → atm_adj_mode[0] writes IREF_COARSE to reg7 ───────
    $display("INFO: Testing ATM18 (IREF_COARSE) write...");
    // Drive a pattern where bits [3:0] = 4'hA (meaningful), bits [7:4] = SPARE
    // Expected: reg7[4:3] = atm_adj_data[1:0] = 2'b10
    //           reg7[2:1] = atm_adj_data[3:2] = 2'b10
    //           reg7[7:5] and reg7[0] unchanged from reset (8'h00)
    atm_adj = 1'b1; atm_adj_mode = 3'b001; atm_adj_data = 8'b01101010; // [3:0]=4'hA=1010
    tick(2);
    atm_adj = 1'b0; atm_adj_mode = 3'b000; tick(1);
    begin : atm18_check
      reg [7:0] expected_reg7;
      expected_reg7 = 8'h00; // reset state
      expected_reg7[4:3] = 2'b10; // atm_adj_data[1:0] = 2'b10
      expected_reg7[2:1] = 2'b10; // atm_adj_data[3:2] = 2'b10
      if (nirs_ch4_led1_reg7 !== expected_reg7) begin
        $display("FAIL: ATM18 reg7: expected 8'h%02h, got 8'h%02h", expected_reg7, nirs_ch4_led1_reg7);
        fail_count = fail_count + 1;
      end else begin
        $display("PASS: ATM18 nirs_ctrl_reg[4][1][7]=8'h%02h correct", nirs_ch4_led1_reg7);
        pass_count = pass_count + 1;
      end
      // reg3 and reg2 should be unchanged from reset
      if (nirs_ch4_led1_reg3 !== 8'h07) begin
        $display("FAIL: ATM18 modified reg3 unexpectedly: 8'h%02h", nirs_ch4_led1_reg3);
        fail_count = fail_count + 1;
      end else begin
        $display("PASS: ATM18 did not modify reg3"); pass_count = pass_count + 1;
      end
    end

    // ── TEST 3: ATM18 SPARE bits [7:4] not written ────────────────────────
    $display("INFO: Verifying ATM18 spare bits [7:4] are ignored...");
    // Reset reg7 by resetting DUT
    rst_n = 1'b0; tick(2); rst_n = 1'b1; tick(2);
    // Drive with all ones in spare bits [7:4]
    atm_adj = 1'b1; atm_adj_mode = 3'b001; atm_adj_data = 8'hFF; // [3:0]=1111, [7:4]=1111
    tick(2); atm_adj = 1'b0; atm_adj_mode = 3'b000; tick(1);
    begin : atm18_spare_check
      reg [7:0] expected_reg7;
      expected_reg7 = 8'h00;
      expected_reg7[4:3] = 2'b11; // atm_adj_data[1:0] = 2'b11
      expected_reg7[2:1] = 2'b11; // atm_adj_data[3:2] = 2'b11
      // bits [7:5] and [0] should remain 0 — spare bits NOT written
      if (nirs_ch4_led1_reg7 !== expected_reg7) begin
        $display("FAIL: ATM18 spare bits leaked into reg7: expected 8'h%02h got 8'h%02h",
                 expected_reg7, nirs_ch4_led1_reg7);
        fail_count = fail_count + 1;
      end else begin
        $display("PASS: ATM18 spare bits [7:4] correctly not written to reg7");
        pass_count = pass_count + 1;
      end
    end

    // ── TEST 4: ATM19 → atm_adj_mode[1], writes same reg7 as ATM18 ───────
    $display("INFO: Testing ATM19 (IREF_FINE) write...");
    rst_n = 1'b0; tick(2); rst_n = 1'b1; tick(2);
    atm_adj = 1'b1; atm_adj_mode = 3'b010; atm_adj_data = 8'h05; // [3:0]=0101
    tick(2); atm_adj = 1'b0; atm_adj_mode = 3'b000; tick(1);
    begin : atm19_check
      reg [7:0] expected_reg7;
      expected_reg7 = 8'h00;
      expected_reg7[4:3] = 2'b01; // atm_adj_data[1:0]=01
      expected_reg7[2:1] = 2'b01; // atm_adj_data[3:2]=01
      if (nirs_ch4_led1_reg7 !== expected_reg7) begin
        $display("FAIL: ATM19 reg7: expected 8'h%02h, got 8'h%02h", expected_reg7, nirs_ch4_led1_reg7);
        fail_count = fail_count + 1;
      end else begin
        $display("PASS: ATM19 nirs_ctrl_reg[4][1][7]=8'h%02h correct", nirs_ch4_led1_reg7);
        pass_count = pass_count + 1;
      end
    end

    // ── TEST 5: ATM20 → atm_adj_mode[2], writes reg3 and reg2 ────────────
    $display("INFO: Testing ATM20 (IDAC) write...");
    rst_n = 1'b0; tick(2); rst_n = 1'b1; tick(2);
    // atm_adj_data = 8'b10110101 → [2:0]=101, [7:3]=10110
    atm_adj = 1'b1; atm_adj_mode = 3'b100; atm_adj_data = 8'b10110101;
    tick(2); atm_adj = 1'b0; atm_adj_mode = 3'b000; tick(1);
    begin : atm20_check
      reg [7:0] expected_reg3, expected_reg2;
      // reg3[7:5] <= atm_adj_data[2:0] = 3'b101
      expected_reg3 = 8'h07; // reset value first
      expected_reg3[7:5] = 3'b101; // = 8'h07 with bits[7:5]=101 → 8'hA7
      // reg2[4:0] <= atm_adj_data[7:3] = 5'b10110
      expected_reg2 = 8'h00; // reset
      expected_reg2[4:0] = 5'b10110; // = 8'h16
      if (nirs_ch4_led1_reg3 !== expected_reg3) begin
        $display("FAIL: ATM20 reg3: expected 8'h%02h, got 8'h%02h", expected_reg3, nirs_ch4_led1_reg3);
        fail_count = fail_count + 1;
      end else begin
        $display("PASS: ATM20 nirs_ctrl_reg[4][1][3]=8'h%02h correct", nirs_ch4_led1_reg3);
        pass_count = pass_count + 1;
      end
      if (nirs_ch4_led1_reg2 !== expected_reg2) begin
        $display("FAIL: ATM20 reg2: expected 8'h%02h, got 8'h%02h", expected_reg2, nirs_ch4_led1_reg2);
        fail_count = fail_count + 1;
      end else begin
        $display("PASS: ATM20 nirs_ctrl_reg[4][1][2]=8'h%02h correct", nirs_ch4_led1_reg2);
        pass_count = pass_count + 1;
      end
      // reg7 should be unchanged (= reset = 8'h00)
      if (nirs_ch4_led1_reg7 !== 8'h00) begin
        $display("FAIL: ATM20 modified reg7 unexpectedly: 8'h%02h", nirs_ch4_led1_reg7);
        fail_count = fail_count + 1;
      end else begin
        $display("PASS: ATM20 did not modify reg7"); pass_count = pass_count + 1;
      end
    end

    // ── TEST 6: atm_adj=0 does NOT write ──────────────────────────────────
    $display("INFO: Testing that atm_adj=0 does not write NIRS regs...");
    rst_n = 1'b0; tick(2); rst_n = 1'b1; tick(2);
    atm_adj = 1'b0; atm_adj_mode = 3'b111; atm_adj_data = 8'hFF;
    tick(2); tick(1);
    if (nirs_ch4_led1_reg7 !== 8'h00 || nirs_ch4_led1_reg3 !== 8'h07) begin
      $display("FAIL: NIRS regs changed without atm_adj=1!");
      fail_count = fail_count + 1;
    end else begin
      $display("PASS: atm_adj=0 does not write NIRS regs"); pass_count = pass_count + 1;
    end

    // ── Summary ───────────────────────────────────────────────────────────
    $display("");
    $display("===================================================");
    $display(" NIRS ATM ADJ Write Testbench Results");
    $display("  PASS: %0d   FAIL: %0d", pass_count, fail_count);
    if (fail_count == 0)
      $display("  ALL TESTS PASSED");
    else
      $display("  FAILURES DETECTED - see above");
    $display("===================================================");
    $display("");
    $display("DESIGN NOTES:");
    $display("  ATM18/19 write bits[4:1] of nirs_ctrl_reg[4][1][7] (IREF current).");
    $display("  ATM20 writes nirs_ctrl_reg[4][1][3][7:5] and reg[2][4:0] (IDAC).");
    $display("  For ATM18/19: only atm_adj_data[3:0] are used; bits[7:4] are SPARE.");
    $display("  These are NIRS current measurement calibrations, separate from OTP.");
    $finish;
  end

  initial begin
    #200000;
    $display("TIMEOUT");
    $finish;
  end

endmodule
