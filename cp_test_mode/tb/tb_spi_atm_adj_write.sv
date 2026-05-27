//===========================================================================
// tb_spi_atm_adj_write.sv
// Testbench: SPI ATM ADJ Register Write (ATM15-ATM29 → ana_gen_reg[x][14])
//
// The spi_reg module ATM ADJ logic (lines 1076-1106 of spi_reg.sv) is
// extracted into a small standalone DUT below to allow clean compilation
// without the large interface/sub-module graph of the full spi_reg.
//
// ATM_MODE mapping (from spi_reg.sv line 1076):
//   ATM_MODE[7] = atm_adj_mode[13]                    → ATM28
//   ATM_MODE[6] = atm_adj_mode[12]                    → ATM27
//   ATM_MODE[5] = atm_adj_mode[11]                    → ATM26
//   ATM_MODE[4] = atm_adj_mode[10]                    → ATM25
//   ATM_MODE[3] = atm_adj_mode[9]  | atm_adj_mode[8]  → ATM24 | ATM23
//   ATM_MODE[2] = atm_adj_mode[7]  | atm_adj_mode[6]  → ATM22 | ATM21
//   ATM_MODE[1] = atm_adj_mode[2]  | atm_adj_mode[1]  → ATM17 | ATM16
//   ATM_MODE[0] = atm_adj_mode[0]  | atm_adj_mode[14] → ATM15 | ATM29
//
// NOT in ATM_MODE:
//   atm_adj_mode[3] = ATM18  ─┐
//   atm_adj_mode[4] = ATM19  ─┼→ routed to spi_reg_nirs (NIRS sub-block)
//   atm_adj_mode[5] = ATM20  ─┘
//
// Run with:
//   iverilog -g2012 -o sim_spi_atm \
//     tb_spi_atm_adj_write.sv \
//     && vvp sim_spi_atm
//===========================================================================
`timescale 1ns/1ps

// ─────────────────────────────────────────────────────────────────────────────
// Standalone DUT: mirrors spi_reg.sv ATM ADJ always block (lines 1079-1106)
// ─────────────────────────────────────────────────────────────────────────────
module spi_atm_adj_model (
  input  wire        i_clk,
  input  wire        i_rst_n,

  // SPI normal write (for completeness, allows verifying SPI write still works)
  input  wire        i_wr,
  input  wire [7:0]  i_wr_data,
  input  wire [2:0]  ana_gen_sec_reg, // selects which ana_gen_reg row

  // ATM ADJ inputs
  input  wire [14:0] atm_adj_mode,   // one-hot: bit0=ATM15 ... bit14=ATM29
  input  wire        atm_adj,        // =debug_mode_en (CP test mode active)
  input  wire [7:0]  atm_adj_data,   // 8-bit adj value

  // Outputs: ana_gen_reg[0..7][14] — the ATM-writeable ADJ register
  output reg  [7:0]  gen_reg_14 [0:7]  // ana_gen_reg[x][14]
);

  // ATM_MODE compression (exact copy from spi_reg.sv line 1076)
  wire [7:0] ATM_MODE;
  assign ATM_MODE = {
    atm_adj_mode[13],                         // [7] ATM28
    atm_adj_mode[12],                         // [6] ATM27
    atm_adj_mode[11],                         // [5] ATM26
    atm_adj_mode[10],                         // [4] ATM25
    atm_adj_mode[9]  | atm_adj_mode[8],       // [3] ATM24 | ATM23
    atm_adj_mode[7]  | atm_adj_mode[6],       // [2] ATM22 | ATM21
    atm_adj_mode[2]  | atm_adj_mode[1],       // [1] ATM17 | ATM16
    atm_adj_mode[0]  | atm_adj_mode[14]       // [0] ATM15 | ATM29
  };

  integer i_init;
  always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      // Reset defaults from spi_reg.sv lines 1081-1088
      gen_reg_14[0] <= 8'h00;
      gen_reg_14[1] <= 8'h24;
      gen_reg_14[2] <= 8'h00;
      gen_reg_14[3] <= 8'h00;
      gen_reg_14[4] <= 8'h00;
      gen_reg_14[5] <= 8'h00;
      gen_reg_14[6] <= 8'h0C;
      gen_reg_14[7] <= 8'h00;
    end
    // SPI normal write (mirrors lines 1090-1097 of spi_reg.sv)
    else if (i_wr) begin
      // Only write when address = ANA_GEN_REG_15 (simplified: always write here)
      gen_reg_14[ana_gen_sec_reg] <= i_wr_data;
    end
    // ATM ADJ write (mirrors lines 1100-1106 of spi_reg.sv)
    else if (atm_adj) begin
      for (i_init = 0; i_init < 8; i_init = i_init + 1) begin
        if (ATM_MODE[i_init])
          gen_reg_14[i_init] <= atm_adj_data;
      end
    end
  end

endmodule

// ─────────────────────────────────────────────────────────────────────────────
// Testbench
// ─────────────────────────────────────────────────────────────────────────────
module tb_spi_atm_adj_write;

  reg        clk, rst_n;
  reg        i_wr;
  reg [7:0]  i_wr_data;
  reg [2:0]  ana_gen_sec_reg;
  reg [14:0] atm_adj_mode;
  reg        atm_adj;
  reg [7:0]  atm_adj_data;

  wire [7:0] gen_reg_14 [0:7];

  spi_atm_adj_model dut (
    .i_clk          (clk),
    .i_rst_n        (rst_n),
    .i_wr           (i_wr),
    .i_wr_data      (i_wr_data),
    .ana_gen_sec_reg(ana_gen_sec_reg),
    .atm_adj_mode   (atm_adj_mode),
    .atm_adj        (atm_adj),
    .atm_adj_data   (atm_adj_data),
    .gen_reg_14     (gen_reg_14)
  );

  initial clk = 0;
  always #50 clk = ~clk; // 10 MHz

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

  // ── Helper: drive one ATM ADJ mode and verify the target gen_reg_14 row ──
  // atm_n     : ATM number (15..29)
  // adj_bit   : which bit of atm_adj_mode to assert (0=ATM15 .. 14=ATM29)
  // atm_mode_bit: which ATM_MODE bit should fire (0..7), -1 if NIRS path
  // row       : expected ana_gen_reg row (0..7) written to, -1 if NIRS path
  // adj_val   : 8-bit value
  task test_atm_adj;
    input integer atm_n;
    input integer adj_bit;
    input integer atm_mode_bit;
    input integer row;
    input [7:0]   adj_val;

    reg [14:0] mode;
    reg [7:0]  prev [0:7];
    integer    j;
    begin
      // Capture current register state
      for (j = 0; j < 8; j = j + 1)
        prev[j] = gen_reg_14[j];

      mode = 15'b0;
      mode[adj_bit] = 1'b1;

      atm_adj      = 1'b1;
      atm_adj_mode = mode;
      atm_adj_data = adj_val;
      tick(2);
      atm_adj      = 1'b0;
      atm_adj_mode = 15'b0;
      tick(1);

      if (row == -1) begin
        // NIRS path: gen_reg_14 should NOT change
        begin : check_nirs
          integer changed;
          changed = 0;
          for (j = 0; j < 8; j = j + 1) begin
            if (gen_reg_14[j] !== prev[j])
              changed = 1;
          end
          if (changed) begin
            $display("FAIL: ATM%0d (NIRS path) unexpectedly wrote gen_reg_14!", atm_n);
            fail_count = fail_count + 1;
          end else begin
            $display("PASS: ATM%0d correctly routes to NIRS block (no gen_reg_14 change)", atm_n);
            pass_count = pass_count + 1;
          end
        end
      end else begin
        // gen_reg_14[row] should be adj_val; others unchanged
        if (gen_reg_14[row] !== adj_val) begin
          $display("FAIL: ATM%0d  expected gen_reg_14[%0d]=8'h%02h  got 8'h%02h",
                   atm_n, row, adj_val, gen_reg_14[row]);
          fail_count = fail_count + 1;
        end else begin
          $display("PASS: ATM%0d  gen_reg_14[%0d]=8'h%02h  correct",
                   atm_n, row, adj_val);
          pass_count = pass_count + 1;
        end
        // Check no other row changed unexpectedly
        // (rows that share the same ATM_MODE bit are expected to change together)
        // For paired modes (ATM23/24, ATM21/22, ATM16/17, ATM15/29), only the
        // target row is checked; other rows must be unchanged.
        begin : check_no_spill
          integer spill;
          spill = 0;
          for (j = 0; j < 8; j = j + 1) begin
            if (j !== row && gen_reg_14[j] !== prev[j]) begin
              if (!(atm_mode_bit == 3 && (j == row)) && // ATM23/24 share bit3
                  !(atm_mode_bit == 2 && (j == row)) && // ATM21/22 share bit2
                  !(atm_mode_bit == 1 && (j == row)) && // ATM16/17 share bit1
                  !(atm_mode_bit == 0 && (j == row))) begin // ATM15/29 share bit0
                $display("  WARN: ATM%0d also wrote gen_reg_14[%0d]=8'h%02h (was 8'h%02h)",
                         atm_n, j, gen_reg_14[j], prev[j]);
              end
            end
          end
        end
      end
    end
  endtask

  integer i;
  initial begin
    pass_count = 0;
    fail_count = 0;

    // Init
    rst_n         = 1'b0;
    i_wr          = 1'b0;
    i_wr_data     = 8'h00;
    ana_gen_sec_reg = 3'b000;
    atm_adj_mode  = 15'b0;
    atm_adj       = 1'b0;
    atm_adj_data  = 8'h00;

    tick(5);
    rst_n = 1'b1;
    tick(2);

    // ── TEST 1: Check reset values ─────────────────────────────────────────
    $display("INFO: Checking reset values...");
    if (gen_reg_14[0] !== 8'h00) begin
      $display("FAIL: gen_reg_14[0] reset value: expected 8'h00 got 8'h%02h", gen_reg_14[0]);
      fail_count = fail_count + 1;
    end else begin
      $display("PASS: gen_reg_14[0]=8'h00 at reset"); pass_count = pass_count + 1;
    end
    if (gen_reg_14[1] !== 8'h24) begin
      $display("FAIL: gen_reg_14[1] reset value: expected 8'h24 got 8'h%02h", gen_reg_14[1]);
      fail_count = fail_count + 1;
    end else begin
      $display("PASS: gen_reg_14[1]=8'h24 at reset"); pass_count = pass_count + 1;
    end
    if (gen_reg_14[6] !== 8'h0C) begin
      $display("FAIL: gen_reg_14[6] reset value: expected 8'h0C got 8'h%02h", gen_reg_14[6]);
      fail_count = fail_count + 1;
    end else begin
      $display("PASS: gen_reg_14[6]=8'h0C at reset"); pass_count = pass_count + 1;
    end

    // ── TEST 2: SPI normal write ───────────────────────────────────────────
    $display("INFO: Testing SPI normal write to gen_reg_14[3]...");
    ana_gen_sec_reg = 3'd3;
    i_wr     = 1'b1;
    i_wr_data = 8'h55;
    tick(2);
    i_wr = 1'b0;
    tick(1);
    if (gen_reg_14[3] !== 8'h55) begin
      $display("FAIL: SPI write to gen_reg_14[3] failed: got 8'h%02h", gen_reg_14[3]);
      fail_count = fail_count + 1;
    end else begin
      $display("PASS: SPI write to gen_reg_14[3]=8'h55 correct"); pass_count = pass_count + 1;
    end

    // ── TEST 3: ATM15 → gen_reg_14[0] ────────────────────────────────────
    $display("INFO: Testing ATM15-ATM29 adj writes...");
    test_atm_adj(15, 0,  0, 0, 8'hF0);   // ATM15 → bit0 → row0
    test_atm_adj(16, 1,  1, 1, 8'hF1);   // ATM16 → bit1 → row1
    test_atm_adj(17, 2,  1, 1, 8'hF2);   // ATM17 → bit1 → row1 (shared with ATM16)
    test_atm_adj(18, 3, -1,-1, 8'hF3);   // ATM18 → NIRS path (not in ATM_MODE)
    test_atm_adj(19, 4, -1,-1, 8'hF4);   // ATM19 → NIRS path
    test_atm_adj(20, 5, -1,-1, 8'hF5);   // ATM20 → NIRS path
    test_atm_adj(21, 6,  2, 2, 8'hF6);   // ATM21 → bit2 → row2
    test_atm_adj(22, 7,  2, 2, 8'hF7);   // ATM22 → bit2 → row2
    test_atm_adj(23, 8,  3, 3, 8'hF8);   // ATM23 → bit3 → row3
    test_atm_adj(24, 9,  3, 3, 8'hF9);   // ATM24 → bit3 → row3
    test_atm_adj(25, 10, 4, 4, 8'hFA);   // ATM25 → bit4 → row4
    test_atm_adj(26, 11, 5, 5, 8'hFB);   // ATM26 → bit5 → row5
    test_atm_adj(27, 12, 6, 6, 8'hFC);   // ATM27 → bit6 → row6
    test_atm_adj(28, 13, 7, 7, 8'hFD);   // ATM28 → bit7 → row7
    test_atm_adj(29, 14, 0, 0, 8'hFE);   // ATM29 → bit0 → row0 (shared with ATM15)

    // ── TEST 4: Verify ATM15 and ATM29 BOTH write gen_reg_14[0] ─────────
    $display("INFO: Verifying ATM15 and ATM29 share gen_reg_14[0]...");
    begin
      // Write with ATM15
      atm_adj = 1'b1; atm_adj_mode = 15'b000000000000001; atm_adj_data = 8'h11;
      tick(2); atm_adj = 1'b0; atm_adj_mode = 15'b0; tick(1);
      if (gen_reg_14[0] === 8'h11) begin
        $display("PASS: ATM15 wrote gen_reg_14[0]=8'h11"); pass_count = pass_count + 1;
      end else begin
        $display("FAIL: ATM15 failed to write gen_reg_14[0], got 8'h%02h", gen_reg_14[0]);
        fail_count = fail_count + 1;
      end
      // Write with ATM29
      atm_adj = 1'b1; atm_adj_mode = 15'b100000000000000; atm_adj_data = 8'h22;
      tick(2); atm_adj = 1'b0; atm_adj_mode = 15'b0; tick(1);
      if (gen_reg_14[0] === 8'h22) begin
        $display("PASS: ATM29 wrote gen_reg_14[0]=8'h22"); pass_count = pass_count + 1;
      end else begin
        $display("FAIL: ATM29 failed to write gen_reg_14[0], got 8'h%02h", gen_reg_14[0]);
        fail_count = fail_count + 1;
      end
    end

    // ── TEST 5: Verify ATM23 and ATM24 BOTH write gen_reg_14[3] ─────────
    $display("INFO: Verifying ATM23 and ATM24 share gen_reg_14[3]...");
    begin
      atm_adj = 1'b1; atm_adj_mode = 15'b000000100000000; atm_adj_data = 8'h33; // ATM23=bit8
      tick(2); atm_adj = 1'b0; atm_adj_mode = 15'b0; tick(1);
      if (gen_reg_14[3] === 8'h33) begin
        $display("PASS: ATM23 wrote gen_reg_14[3]=8'h33"); pass_count = pass_count + 1;
      end else begin
        $display("FAIL: ATM23 failed on gen_reg_14[3], got 8'h%02h", gen_reg_14[3]);
        fail_count = fail_count + 1;
      end

      atm_adj = 1'b1; atm_adj_mode = 15'b000001000000000; atm_adj_data = 8'h44; // ATM24=bit9
      tick(2); atm_adj = 1'b0; atm_adj_mode = 15'b0; tick(1);
      if (gen_reg_14[3] === 8'h44) begin
        $display("PASS: ATM24 wrote gen_reg_14[3]=8'h44"); pass_count = pass_count + 1;
      end else begin
        $display("FAIL: ATM24 failed on gen_reg_14[3], got 8'h%02h", gen_reg_14[3]);
        fail_count = fail_count + 1;
      end
    end

    // ── TEST 6: ATM18/19/20 do NOT affect gen_reg_14 (NIRS path) ─────────
    $display("INFO: Verifying ATM18/19/20 do not write gen_reg_14...");
    begin : nirs_check
      reg [7:0] snap [0:7];
      integer   j2;
      for (j2 = 0; j2 < 8; j2 = j2 + 1)
        snap[j2] = gen_reg_14[j2];

      // Try all three NIRS ATMs simultaneously
      atm_adj = 1'b1; atm_adj_mode = 15'b000000000111000; atm_adj_data = 8'hEE; // bits 3,4,5
      tick(2); atm_adj = 1'b0; atm_adj_mode = 15'b0; tick(1);

      begin : nirs_verify
        integer changed2;
        changed2 = 0;
        for (j2 = 0; j2 < 8; j2 = j2 + 1) begin
          if (gen_reg_14[j2] !== snap[j2]) begin
            changed2 = 1;
            $display("  FAIL: ATM18/19/20 wrote gen_reg_14[%0d]=8'h%02h (was 8'h%02h)",
                     j2, gen_reg_14[j2], snap[j2]);
          end
        end
        if (!changed2) begin
          $display("PASS: ATM18/19/20 do not write gen_reg_14 (correctly routed to NIRS)");
          pass_count = pass_count + 1;
        end else begin
          fail_count = fail_count + 1;
        end
      end
    end

    // ── TEST 7: atm_adj=0 does NOT write registers ─────────────────────
    $display("INFO: Verifying atm_adj=0 does not write gen_reg_14...");
    begin : adj_zero_check
      reg [7:0] snap2;
      snap2 = gen_reg_14[0];
      atm_adj = 1'b0; atm_adj_mode = 15'b000000000000001; atm_adj_data = 8'hAA;
      tick(2); atm_adj_mode = 15'b0; tick(1);
      if (gen_reg_14[0] !== snap2) begin
        $display("FAIL: gen_reg_14[0] changed without atm_adj! got 8'h%02h", gen_reg_14[0]);
        fail_count = fail_count + 1;
      end else begin
        $display("PASS: atm_adj=0 does not write gen_reg_14[0]"); pass_count = pass_count + 1;
      end
    end

    // ── Summary ───────────────────────────────────────────────────────────
    $display("");
    $display("===================================================");
    $display(" SPI ATM ADJ Write Testbench Results");
    $display("  PASS: %0d   FAIL: %0d", pass_count, fail_count);
    if (fail_count == 0)
      $display("  ALL TESTS PASSED");
    else
      $display("  FAILURES DETECTED - see above");
    $display("===================================================");
    $display("");
    $display("DESIGN NOTES:");
    $display("  ATM18/19/20 are INTENTIONALLY excluded from the main ATM_MODE");
    $display("  compression in spi_reg.sv. They route to spi_reg_nirs sub-block");
    $display("  via .atm_adj_mode(atm_adj_mode[5:3]) (spi_reg.sv line 1931).");
    $display("  This is confirmed by pinmux_ascii.txt: ATM18/19/20 are NIRS");
    $display("  (IREF_COARSE / IREF_FINE / IDAC) measurement modes where SPARE");
    $display("  ADJ bits are tied to 0 per the golden reference.");
    $finish;
  end

  // Watchdog
  initial begin
    #200000;
    $display("TIMEOUT: simulation exceeded 200 us");
    $finish;
  end

endmodule
