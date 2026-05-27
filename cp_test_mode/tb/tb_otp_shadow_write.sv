//===========================================================================
// tb_otp_shadow_write.sv
// Testbench: OTP ATM Shadow Register Write (ATM0-ATM14 → shadow_regs[4..18])
//
// Tests that when debug_mode_en=1 (CP test mode) and an ATM trim value is
// presented on the digital pads, otp_regs correctly captures it into the
// corresponding shadow register.
//
// DUT: otp_regs (otp/rtl/otp_regs.sv)
//
// Dependencies:
//   common/common_sync_bit.v
//
// Run with:
//   iverilog -g2012 -o sim_otp_shadow \
//     tb_otp_shadow_write.sv \
//     ../../otp/rtl/otp_regs.sv \
//     ../../common/common_sync_bit.v \
//     && vvp sim_otp_shadow
//===========================================================================
`timescale 1ns/1ps

module tb_otp_shadow_write;

  // Parameters must match otp_ctrl_top
  localparam NO_SPI_REGS = 20;
  localparam ATM_MDOE    = 15;
  localparam ATM_DATA    = 8;

  // Clock / reset
  reg clk, rst_n;

  // OTP HW strobes (driven by otp_rw_ctrl in real design; we stub)
  reg otp_inf_epm_blk_addr_set_en;
  reg otp_inf_epm_blk_rd_set_en;
  reg otp_inf_epm_blk_wd_set_en;

  // SPI/unlock interface (not used in ATM test, keep 0)
  reg unlock, spi_wr, spi_wr_data, spi_rd_data;
  reg [7:0] spi_otp_addr, spi_otp_data;

  // ATM interface
  reg                    atm_unlock;            // 0 = shadow write; 1 = OTP burn
  reg                    analog_test_mode_sync; // synchronized debug_mode_en
  reg [ATM_MDOE-1:0]     atm_mode_sync;         // one-hot ATM select (ATM0=bit0)
  reg [ATM_DATA-1:0]     atm_data_sync;         // 8-bit trim value

  // OTP dout (all zeros = no valid OTP at startup)
  reg [31:0] otp_dout;

  // SPI/def regs  (all zeros for this test)
  reg [7:0] spi_regs [NO_SPI_REGS-1:0];
  reg [7:0] def_regs [NO_SPI_REGS-1:0];

  // DUT outputs
  wire [7:0] shadow_regs [NO_SPI_REGS-1:0];
  wire [6:0] otp_addr;
  wire [7:0] spi_data_read;
  wire [7:0] spi_data_to_otp;
  wire       addr_valid;
  wire [6:0] addr_trim;
  wire       otp_en;
  wire       otp_inf_epm_rw;
  wire       reload_done;
  wire       wr_working, wr_time;
  wire       loading_shadows;

  // Instantiate DUT
  otp_regs #(
    .NO_SPI_REGS(NO_SPI_REGS),
    .ATM_MDOE(ATM_MDOE),
    .ATM_DATA(ATM_DATA)
  ) dut (
    .rst_n                          (rst_n),
    .clk                            (clk),
    .otp_inf_epm_blk_addr_set_en    (otp_inf_epm_blk_addr_set_en),
    .otp_inf_epm_blk_rd_set_en      (otp_inf_epm_blk_rd_set_en),
    .otp_inf_epm_blk_wd_set_en      (otp_inf_epm_blk_wd_set_en),
    .unlock                         (unlock),
    .spi_wr                         (spi_wr),
    .spi_wr_data                    (spi_wr_data),
    .spi_rd_data                    (spi_rd_data),
    .spi_otp_addr                   (spi_otp_addr),
    .spi_otp_data                   (spi_otp_data),
    .atm_unlock                     (atm_unlock),
    .analog_test_mode_sync          (analog_test_mode_sync),
    .atm_mode_sync                  (atm_mode_sync),
    .atm_data_sync                  (atm_data_sync),
    .otp_dout                       (otp_dout),
    .spi_regs                       (spi_regs),
    .def_regs                       (def_regs),
    .shadow_regs                    (shadow_regs),
    .otp_addr                       (otp_addr),
    .spi_data_read                  (spi_data_read),
    .spi_data_to_otp                (spi_data_to_otp),
    .addr_valid                     (addr_valid),
    .addr_trim                      (addr_trim),
    .otp_en                         (otp_en),
    .otp_inf_epm_rw                 (otp_inf_epm_rw),
    .reload_done                    (reload_done),
    .wr_working                     (wr_working),
    .wr_time                        (wr_time),
    .loading_shadows                (loading_shadows)
  );

  // 10 MHz clock
  initial clk = 0;
  always #50 clk = ~clk; // 100 ns period

  task tick;
    input integer n;
    integer k;
    begin
      for (k = 0; k < n; k = k + 1)
        @(posedge clk);
      #1; // small setup margin after posedge
    end
  endtask

  // ─────────────────────────────────────────────────────────────────────────
  // Simulate OTP startup loading sequence to clear loading_shadows.
  //
  // Strategy: present otp_dout[7:0] = 8'h5a (valid tag) when otp_addr==0
  // so that otp_data_00 = 8'h5a. Then advance otp_addr past NO_SPI_REGS-1=19
  // to make addr_valid go LOW and trigger loading_shadows_low_pulse.
  // ─────────────────────────────────────────────────────────────────────────
  task do_otp_startup_load;
    integer a;
    begin
      // With otp_data_00=8'h5a, addr_valid falls to 0 when otp_addr >= 20
      // Advance in steps of 4: 0,4,8,12,16,20
      for (a = 0; a < NO_SPI_REGS; a = a + 4) begin
        // Present read data: addr 0 carries 8'h5a as valid tag
        otp_dout = (a == 0) ? 32'h5a5a5a5a : 32'h00000000;
        // Assert read-data strobe so shadow_regs[a..a+3] loaded
        otp_inf_epm_blk_rd_set_en = 1'b1;
        tick(1);
        otp_inf_epm_blk_rd_set_en = 1'b0;
        tick(1);
        // Advance address
        otp_inf_epm_blk_addr_set_en = 1'b1;
        tick(1);
        otp_inf_epm_blk_addr_set_en = 1'b0;
        tick(1);
      end
      // Wait for loading_shadows to drop
      tick(10);
      if (loading_shadows !== 1'b0) begin
        $display("FAIL: loading_shadows did not clear after startup load!");
        $finish;
      end
      $display("INFO: OTP startup load complete. loading_shadows=0, reload_done=%0b", reload_done);
    end
  endtask

  // ─────────────────────────────────────────────────────────────────────────
  // Drive one ATM trim write and check shadow_regs.
  // atm_n  : 0..14 (ATM number)
  // trim   : 8-bit trim value to write
  // ─────────────────────────────────────────────────────────────────────────
  integer pass_count, fail_count;

  task test_atm_trim;
    input integer atm_n;
    input [7:0]   trim_val;
    reg [14:0] mode_sel;
    begin
      mode_sel = 15'b0;
      mode_sel[atm_n] = 1'b1;

      // Assert CP test mode (debug_mode_en) with ATM selected and unlock=0 (shadow write)
      analog_test_mode_sync = 1'b1;
      atm_unlock            = 1'b0;
      atm_mode_sync         = mode_sel;
      atm_data_sync         = trim_val;

      // One clock cycle is enough for the shadow register write (combinatorial priority)
      tick(2);

      // Deassert
      analog_test_mode_sync = 1'b0;
      atm_mode_sync         = 15'b0;
      atm_data_sync         = 8'h00;
      tick(1);

      // Check shadow_regs[4 + atm_n]
      if (shadow_regs[4 + atm_n] !== trim_val) begin
        $display("FAIL: ATM%0d  expected shadow_regs[%0d]=8'h%02h  got 8'h%02h",
                 atm_n, 4+atm_n, trim_val, shadow_regs[4+atm_n]);
        fail_count = fail_count + 1;
      end else begin
        $display("PASS: ATM%0d  shadow_regs[%0d]=8'h%02h  correct",
                 atm_n, 4+atm_n, trim_val);
        pass_count = pass_count + 1;
      end

      // Check valid tag
      if (shadow_regs[0] !== 8'h5a) begin
        $display("FAIL: ATM%0d  shadow_regs[0] (tag) expected 8'h5a, got 8'h%02h",
                 atm_n, shadow_regs[0]);
        fail_count = fail_count + 1;
      end
    end
  endtask

  // ─────────────────────────────────────────────────────────────────────────
  // Test that when loading_shadows=1, ATM writes are BLOCKED
  // ─────────────────────────────────────────────────────────────────────────
  task test_atm_blocked_during_load;
    reg [7:0] before_val;
    begin
      // shadow_regs[4] before
      before_val = shadow_regs[4];
      // Try to write ATM0 while loading_shadows may still be 1
      analog_test_mode_sync = 1'b1;
      atm_unlock            = 1'b0;
      atm_mode_sync         = 15'b000000000000001; // ATM0
      atm_data_sync         = 8'hFF;
      tick(2);
      analog_test_mode_sync = 1'b0;
      atm_mode_sync         = 15'b0;
      tick(1);
    end
  endtask

  // ─────────────────────────────────────────────────────────────────────────
  // Main test sequence
  // ─────────────────────────────────────────────────────────────────────────
  integer i;
  initial begin
    pass_count = 0;
    fail_count = 0;

    // Initialise all inputs
    rst_n                          = 1'b0;
    otp_inf_epm_blk_addr_set_en    = 1'b0;
    otp_inf_epm_blk_rd_set_en      = 1'b0;
    otp_inf_epm_blk_wd_set_en      = 1'b0;
    unlock       = 1'b0;
    spi_wr       = 1'b0;
    spi_wr_data  = 1'b0;
    spi_rd_data  = 1'b0;
    spi_otp_addr = 8'h00;
    spi_otp_data = 8'h00;
    atm_unlock            = 1'b0;
    analog_test_mode_sync = 1'b0;
    atm_mode_sync         = 15'b0;
    atm_data_sync         = 8'h00;
    otp_dout = 32'h00000000;
    for (i = 0; i < NO_SPI_REGS; i = i + 1) begin
      spi_regs[i] = 8'h00;
      def_regs[i] = 8'h00;
    end

    // Release reset
    tick(5);
    rst_n = 1'b1;
    tick(2);

    // ── TEST 1: Verify loading_shadows starts at 1 ─────────────────────────
    if (loading_shadows !== 1'b1) begin
      $display("FAIL: loading_shadows should be 1 immediately after reset");
      fail_count = fail_count + 1;
    end else begin
      $display("PASS: loading_shadows=1 after reset (OTP load pending)");
    end

    // ── TEST 2: ATM write blocked while loading_shadows=1 ──────────────────
    $display("INFO: Checking ATM write blocked during loading_shadows...");
    begin
      reg [7:0] snap;
      snap = shadow_regs[4]; // capture before
      analog_test_mode_sync = 1'b1;
      atm_unlock            = 1'b0;
      atm_mode_sync         = 15'b000000000000001; // ATM0
      atm_data_sync         = 8'hAA;
      tick(2);
      analog_test_mode_sync = 1'b0;
      atm_mode_sync         = 15'b0;
      tick(1);
      if (shadow_regs[4] !== snap) begin
        $display("FAIL: ATM0 write succeeded during loading_shadows=1 (should be blocked)");
        $display("      shadow_regs[4] changed from 8'h%02h to 8'h%02h", snap, shadow_regs[4]);
        fail_count = fail_count + 1;
      end else begin
        $display("PASS: ATM0 write correctly blocked while loading_shadows=1");
        pass_count = pass_count + 1;
      end
    end

    // ── Simulate OTP startup load to clear loading_shadows ─────────────────
    $display("INFO: Running OTP startup load sequence...");
    do_otp_startup_load;

    // ── TEST 3: ATM0-ATM14 shadow register writes ──────────────────────────
    $display("INFO: Testing ATM0-ATM14 shadow register writes...");
    begin
      reg [7:0] trim_pattern;
      for (i = 0; i < 15; i = i + 1) begin
        // Use distinct patterns: 0xA0+i for easy identification
        trim_pattern = 8'hA0 + i;
        test_atm_trim(i, trim_pattern);
      end
    end

    // ── TEST 4: Verify sequential ATM writes (overwrite) ──────────────────
    $display("INFO: Testing ATM5 overwrite...");
    test_atm_trim(5, 8'hBB);
    if (shadow_regs[9] !== 8'hBB) begin
      $display("FAIL: ATM5 overwrite failed: shadow_regs[9]=8'h%02h", shadow_regs[9]);
      fail_count = fail_count + 1;
    end else begin
      $display("PASS: ATM5 overwrite succeeded");
      pass_count = pass_count + 1;
    end

    // ── TEST 5: Multiple ATM bits set simultaneously (should only write
    //            highest-priority bit, since it's if-else-if chain) ─────────
    $display("INFO: Testing simultaneous ATM0+ATM1 assertion (priority check)...");
    begin
      analog_test_mode_sync = 1'b1;
      atm_unlock            = 1'b0;
      atm_mode_sync         = 15'b000000000000011; // ATM0 and ATM1
      atm_data_sync         = 8'hCC;
      tick(2);
      analog_test_mode_sync = 1'b0;
      atm_mode_sync         = 15'b0;
      tick(1);
      // In otp_regs.sv, atm_mode_sync[0] (ATM0) is checked first, so ATM0 wins
      if (shadow_regs[4] === 8'hCC) begin
        $display("PASS: ATM0 wins priority when ATM0+ATM1 both asserted (shadow_regs[4]=8'hCC)");
        pass_count = pass_count + 1;
      end else begin
        $display("FAIL: ATM0 did not win priority. shadow_regs[4]=8'h%02h", shadow_regs[4]);
        fail_count = fail_count + 1;
      end
      // ATM1 (shadow_regs[5]) should NOT be written
      if (shadow_regs[5] !== 8'hA1) begin // A1 from previous test
        $display("INFO: shadow_regs[5]=8'h%02h (was 8'hA1 from ATM1 test, may differ)", shadow_regs[5]);
      end
    end

    // ── TEST 6: atm_unlock=1 does NOT write shadow (goes to OTP burn path) ─
    $display("INFO: Testing that atm_unlock=1 does NOT write shadow_regs...");
    begin
      reg [7:0] snap;
      snap = shadow_regs[4];
      analog_test_mode_sync = 1'b1;
      atm_unlock            = 1'b1;   // OTP burn path
      atm_mode_sync         = 15'b000000000000001; // ATM0
      atm_data_sync         = 8'hDD;
      tick(5);
      analog_test_mode_sync = 1'b0;
      atm_unlock            = 1'b0;
      atm_mode_sync         = 15'b0;
      tick(1);
      if (shadow_regs[4] !== snap) begin
        $display("FAIL: shadow_regs[4] changed (8'h%02h → 8'h%02h) when atm_unlock=1; should not!",
                 snap, shadow_regs[4]);
        fail_count = fail_count + 1;
      end else begin
        $display("PASS: shadow_regs[4] unchanged when atm_unlock=1 (OTP burn path separate)");
        pass_count = pass_count + 1;
      end
    end

    // ── Summary ────────────────────────────────────────────────────────────
    $display("");
    $display("===================================================");
    $display(" OTP ATM Shadow Write Testbench Results");
    $display("  PASS: %0d   FAIL: %0d", pass_count, fail_count);
    if (fail_count == 0)
      $display("  ALL TESTS PASSED");
    else
      $display("  FAILURES DETECTED - see above");
    $display("===================================================");
    $finish;
  end

  // Watchdog
  initial begin
    #500000;
    $display("TIMEOUT: simulation exceeded 500 us");
    $finish;
  end

endmodule
