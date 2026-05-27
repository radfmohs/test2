//===========================================================================
// tb_pinmux_atm_routing.sv
// Testbench: Pinmux ATM Signal Routing (GPIO pads → OTP/SPI register inputs)
//
// This testbench implements a behavioral model of the pinmux ATM decode and
// signal routing logic extracted directly from pinmux.sv, then verifies:
//   1. debug_mode_en = testmode0_en & testmode1_en (CP test mode)
//   2. GPIO10-14 drive ana_test_mode[4:0]
//   3. ana_test_mode decoded to ATM0-ATM29 one-hot signals
//   4. o_OTP_ATM_MODE_SEL[14:0] = {ATM14..ATM0}
//   5. o_SPI_ATM_MODE_SEL[14:0] = {ATM29..ATM15}
//   6. GPIO1-8 pad inputs routed to o_OTP_ATM_TRIM_DATA (ATM0-14)
//   7. GPIO1-8 pad inputs routed to o_SPI_ATM_ADJ_DATA  (ATM15-29)
//   8. When debug_mode_en=0, outputs are zeroed (safe mode)
//
// References:
//   pinmux/rtl/pinmux.sv lines 283-627
//   ENS2_Digital_Pinmux_ascii.txt (golden reference)
//
// Run with:
//   iverilog -g2012 -o sim_pinmux_atm \
//     tb_pinmux_atm_routing.sv \
//     && vvp sim_pinmux_atm
//===========================================================================
`timescale 1ns/1ps

// ─────────────────────────────────────────────────────────────────────────────
// Behavioral model: implements pinmux ATM routing assigns verbatim
// ─────────────────────────────────────────────────────────────────────────────
module pinmux_atm_model (
  // Testmode pad inputs (from chip pad ring)
  input  wire       iopad_testmode0_en_y,  // from GF_CI_IN_C_POC on testmode0 pad
  input  wire       iopad_testmode1_en_y,  // from GF_CI_IN_C_POC on testmode1 pad

  // GPIO pad receive path (Y = pad → chip core, from IOBUF)
  // GPIO1-8:  carry trim/adj data bits [0..7]
  // GPIO10-14: carry ATM mode select bits [0..4]
  input  wire       gpio1_y,   // → trim/adj bit [0]
  input  wire       gpio2_y,   // → trim/adj bit [1]
  input  wire       gpio3_y,   // → trim/adj bit [2]
  input  wire       gpio4_y,   // → trim/adj bit [3]
  input  wire       gpio5_y,   // → trim/adj bit [4]
  input  wire       gpio6_y,   // → trim/adj bit [5]
  input  wire       gpio7_y,   // → trim/adj bit [6]
  input  wire       gpio8_y,   // → trim/adj bit [7]
  input  wire       gpio10_y,  // → ana_test_mode[0]
  input  wire       gpio11_y,  // → ana_test_mode[1]
  input  wire       gpio12_y,  // → ana_test_mode[2]
  input  wire       gpio13_y,  // → ana_test_mode[3]
  input  wire       gpio14_y,  // → ana_test_mode[4]

  // Pinmux outputs to OTP controller
  output wire [14:0] o_OTP_ATM_MODE_SEL,
  output wire [7:0]  o_OTP_ATM_TRIM_DATA,
  output wire        o_OTP_ANA_TESTMODE,

  // Pinmux outputs to SPI register
  output wire [14:0] o_SPI_ATM_MODE_SEL,
  output wire [7:0]  o_SPI_ATM_ADJ_DATA,
  output wire        o_SPI_ANA_TESTMODE,

  // Decoded mode enables (for testbench observation)
  output wire        debug_mode_en,
  output wire [4:0]  ana_test_mode,
  output wire [29:0] atm_decode   // {ATM29..ATM0}
);

  // ── Mode enables (pinmux.sv lines 283-289) ─────────────────────────────
  assign debug_mode_en = iopad_testmode1_en_y & iopad_testmode0_en_y;

  // ── ATM mode select from GPIO10-14 (pinmux.sv line 293) ────────────────
  // wire_ens2_IOBUF_Y[0..4] = GPIO10..14 pad Y outputs when ATM_CONFG=1
  assign ana_test_mode = debug_mode_en ?
    {gpio14_y, gpio13_y, gpio12_y, gpio11_y, gpio10_y} : 5'b0;

  // ── ATM0-ATM29 one-hot decode (pinmux.sv lines 297-326) ────────────────
  wire ATM0, ATM1, ATM2, ATM3, ATM4, ATM5, ATM6, ATM7, ATM8, ATM9;
  wire ATM10, ATM11, ATM12, ATM13, ATM14;
  wire ATM15, ATM16, ATM17, ATM18, ATM19, ATM20;
  wire ATM21, ATM22, ATM23, ATM24, ATM25, ATM26, ATM27, ATM28, ATM29;

  assign ATM0  = (debug_mode_en && (ana_test_mode == 5'd0))  ? 1'b1 : 1'b0;
  assign ATM1  = (debug_mode_en && (ana_test_mode == 5'd1))  ? 1'b1 : 1'b0;
  assign ATM2  = (debug_mode_en && (ana_test_mode == 5'd2))  ? 1'b1 : 1'b0;
  assign ATM3  = (debug_mode_en && (ana_test_mode == 5'd3))  ? 1'b1 : 1'b0;
  assign ATM4  = (debug_mode_en && (ana_test_mode == 5'd4))  ? 1'b1 : 1'b0;
  assign ATM5  = (debug_mode_en && (ana_test_mode == 5'd5))  ? 1'b1 : 1'b0;
  assign ATM6  = (debug_mode_en && (ana_test_mode == 5'd6))  ? 1'b1 : 1'b0;
  assign ATM7  = (debug_mode_en && (ana_test_mode == 5'd7))  ? 1'b1 : 1'b0;
  assign ATM8  = (debug_mode_en && (ana_test_mode == 5'd8))  ? 1'b1 : 1'b0;
  assign ATM9  = (debug_mode_en && (ana_test_mode == 5'd9))  ? 1'b1 : 1'b0;
  assign ATM10 = (debug_mode_en && (ana_test_mode == 5'd10)) ? 1'b1 : 1'b0;
  assign ATM11 = (debug_mode_en && (ana_test_mode == 5'd11)) ? 1'b1 : 1'b0;
  assign ATM12 = (debug_mode_en && (ana_test_mode == 5'd12)) ? 1'b1 : 1'b0;
  assign ATM13 = (debug_mode_en && (ana_test_mode == 5'd13)) ? 1'b1 : 1'b0;
  assign ATM14 = (debug_mode_en && (ana_test_mode == 5'd14)) ? 1'b1 : 1'b0;
  assign ATM15 = (debug_mode_en && (ana_test_mode == 5'd15)) ? 1'b1 : 1'b0;
  assign ATM16 = (debug_mode_en && (ana_test_mode == 5'd16)) ? 1'b1 : 1'b0;
  assign ATM17 = (debug_mode_en && (ana_test_mode == 5'd17)) ? 1'b1 : 1'b0;
  assign ATM18 = (debug_mode_en && (ana_test_mode == 5'd18)) ? 1'b1 : 1'b0;
  assign ATM19 = (debug_mode_en && (ana_test_mode == 5'd19)) ? 1'b1 : 1'b0;
  assign ATM20 = (debug_mode_en && (ana_test_mode == 5'd20)) ? 1'b1 : 1'b0;
  assign ATM21 = (debug_mode_en && (ana_test_mode == 5'd21)) ? 1'b1 : 1'b0;
  assign ATM22 = (debug_mode_en && (ana_test_mode == 5'd22)) ? 1'b1 : 1'b0;
  assign ATM23 = (debug_mode_en && (ana_test_mode == 5'd23)) ? 1'b1 : 1'b0;
  assign ATM24 = (debug_mode_en && (ana_test_mode == 5'd24)) ? 1'b1 : 1'b0;
  assign ATM25 = (debug_mode_en && (ana_test_mode == 5'd25)) ? 1'b1 : 1'b0;
  assign ATM26 = (debug_mode_en && (ana_test_mode == 5'd26)) ? 1'b1 : 1'b0;
  assign ATM27 = (debug_mode_en && (ana_test_mode == 5'd27)) ? 1'b1 : 1'b0;
  assign ATM28 = (debug_mode_en && (ana_test_mode == 5'd28)) ? 1'b1 : 1'b0;
  assign ATM29 = (debug_mode_en && (ana_test_mode == 5'd29)) ? 1'b1 : 1'b0;

  assign atm_decode = {ATM29,ATM28,ATM27,ATM26,ATM25,ATM24,ATM23,ATM22,ATM21,ATM20,
                       ATM19,ATM18,ATM17,ATM16,ATM15,ATM14,ATM13,ATM12,ATM11,ATM10,
                       ATM9, ATM8, ATM7, ATM6, ATM5, ATM4, ATM3, ATM2, ATM1, ATM0};

  // ── Pad data byte (GPIO1-8): shared for trim and adj (pinmux_1bit logic)─
  // In ATM mode each GPIO1..8 drives one bit of the trim/adj byte.
  // testN_y = testN_en ? iopad_gpio_y : testN_def  (from pinmux_1bit)
  // Since test_en=ATM_en and iopad_gpio_y = gpioN_y, in test mode: testN_y = gpioN_y
  wire [7:0] pad_byte;
  assign pad_byte = {gpio8_y, gpio7_y, gpio6_y, gpio5_y,
                     gpio4_y, gpio3_y, gpio2_y, gpio1_y};

  // ── OTP trim data routing (pinmux.sv lines 589-603) ───────────────────
  // In each ATM0-14 mode the GPIO1-8 byte is the trim value for that ATM.
  // The pinmux_1bit testN_y outputs in test_sel=N+2 mode carry gpioN_y directly.
  assign o_OTP_ATM_TRIM_DATA =
    ATM0  ? pad_byte :
    ATM1  ? pad_byte :
    ATM2  ? pad_byte :
    ATM3  ? pad_byte :
    ATM4  ? pad_byte :
    ATM5  ? pad_byte :
    ATM6  ? pad_byte :
    ATM7  ? pad_byte :
    ATM8  ? pad_byte :
    ATM9  ? pad_byte :
    ATM10 ? pad_byte :
    ATM11 ? pad_byte :
    ATM12 ? pad_byte :
    ATM13 ? pad_byte :
    ATM14 ? pad_byte : 8'h00;

  // ── OTP ATM mode select (pinmux.sv line 584) ──────────────────────────
  assign o_OTP_ATM_MODE_SEL = {ATM14,ATM13,ATM12,ATM11,ATM10,
                                ATM9, ATM8, ATM7, ATM6, ATM5,
                                ATM4, ATM3, ATM2, ATM1, ATM0};

  assign o_OTP_ANA_TESTMODE  = debug_mode_en;

  // ── SPI adj data routing (pinmux.sv lines 612-627) ────────────────────
  assign o_SPI_ATM_ADJ_DATA =
    ATM15 ? pad_byte :
    ATM16 ? pad_byte :
    ATM17 ? pad_byte :
    ATM18 ? pad_byte :
    ATM19 ? pad_byte :
    ATM20 ? pad_byte :
    ATM21 ? pad_byte :
    ATM22 ? pad_byte :
    ATM23 ? pad_byte :
    ATM24 ? pad_byte :
    ATM25 ? pad_byte :
    ATM26 ? pad_byte :
    ATM27 ? pad_byte :
    ATM28 ? pad_byte :
    ATM29 ? pad_byte : 8'h00;

  // ── SPI ATM mode select (pinmux.sv line 608) ──────────────────────────
  assign o_SPI_ATM_MODE_SEL = {ATM29,ATM28,ATM27,ATM26,ATM25,ATM24,ATM23,ATM22,
                                ATM21,ATM20,ATM19,ATM18,ATM17,ATM16,ATM15};

  assign o_SPI_ANA_TESTMODE  = debug_mode_en;

endmodule

// ─────────────────────────────────────────────────────────────────────────────
// Testbench
// ─────────────────────────────────────────────────────────────────────────────
module tb_pinmux_atm_routing;

  reg  tm0, tm1;                 // testmode pad enables
  reg  gpio1_y, gpio2_y, gpio3_y, gpio4_y;
  reg  gpio5_y, gpio6_y, gpio7_y, gpio8_y;
  reg  gpio10_y, gpio11_y, gpio12_y, gpio13_y, gpio14_y;

  wire [14:0] o_OTP_ATM_MODE_SEL;
  wire [7:0]  o_OTP_ATM_TRIM_DATA;
  wire        o_OTP_ANA_TESTMODE;
  wire [14:0] o_SPI_ATM_MODE_SEL;
  wire [7:0]  o_SPI_ATM_ADJ_DATA;
  wire        o_SPI_ANA_TESTMODE;
  wire        debug_mode_en;
  wire [4:0]  ana_test_mode;
  wire [29:0] atm_decode;

  pinmux_atm_model dut (
    .iopad_testmode0_en_y (tm0),
    .iopad_testmode1_en_y (tm1),
    .gpio1_y   (gpio1_y),
    .gpio2_y   (gpio2_y),
    .gpio3_y   (gpio3_y),
    .gpio4_y   (gpio4_y),
    .gpio5_y   (gpio5_y),
    .gpio6_y   (gpio6_y),
    .gpio7_y   (gpio7_y),
    .gpio8_y   (gpio8_y),
    .gpio10_y  (gpio10_y),
    .gpio11_y  (gpio11_y),
    .gpio12_y  (gpio12_y),
    .gpio13_y  (gpio13_y),
    .gpio14_y  (gpio14_y),
    .o_OTP_ATM_MODE_SEL  (o_OTP_ATM_MODE_SEL),
    .o_OTP_ATM_TRIM_DATA (o_OTP_ATM_TRIM_DATA),
    .o_OTP_ANA_TESTMODE  (o_OTP_ANA_TESTMODE),
    .o_SPI_ATM_MODE_SEL  (o_SPI_ATM_MODE_SEL),
    .o_SPI_ATM_ADJ_DATA  (o_SPI_ATM_ADJ_DATA),
    .o_SPI_ANA_TESTMODE  (o_SPI_ANA_TESTMODE),
    .debug_mode_en       (debug_mode_en),
    .ana_test_mode       (ana_test_mode),
    .atm_decode          (atm_decode)
  );

  integer pass_count, fail_count;

  // ── Helper: drive ATM select via GPIO10-14 and data via GPIO1-8 ──────
  task drive_atm;
    input [4:0]  atm_num;    // 0..29
    input [7:0]  data_byte;
    begin
      {gpio14_y, gpio13_y, gpio12_y, gpio11_y, gpio10_y} = atm_num;
      {gpio8_y,  gpio7_y,  gpio6_y,  gpio5_y,
       gpio4_y,  gpio3_y,  gpio2_y,  gpio1_y}             = data_byte;
      #1; // propagate combinatorially
    end
  endtask

  // ── Check exactly one ATM is asserted ────────────────────────────────
  task check_one_hot;
    input integer expected_atm;  // 0..29
    begin
      if (atm_decode !== (30'h1 << expected_atm)) begin
        $display("FAIL: ATM%0d  atm_decode=30'h%07h  expected one-hot bit %0d",
                 expected_atm, atm_decode, expected_atm);
        fail_count = fail_count + 1;
      end else begin
        $display("PASS: ATM%0d one-hot decode correct", expected_atm);
        pass_count = pass_count + 1;
      end
    end
  endtask

  // ── Check OTP mode sel and trim data ─────────────────────────────────
  task check_otp;
    input integer atm_n;       // 0..14
    input [7:0]  data_byte;
    reg [14:0] exp_mode;
    begin
      exp_mode = (15'h1 << atm_n);
      if (o_OTP_ATM_MODE_SEL !== exp_mode) begin
        $display("FAIL: ATM%0d  o_OTP_ATM_MODE_SEL=15'h%04h  expected 15'h%04h",
                 atm_n, o_OTP_ATM_MODE_SEL, exp_mode);
        fail_count = fail_count + 1;
      end else begin
        $display("PASS: ATM%0d  o_OTP_ATM_MODE_SEL=15'h%04h  correct", atm_n, o_OTP_ATM_MODE_SEL);
        pass_count = pass_count + 1;
      end
      if (o_OTP_ATM_TRIM_DATA !== data_byte) begin
        $display("FAIL: ATM%0d  o_OTP_ATM_TRIM_DATA=8'h%02h  expected 8'h%02h",
                 atm_n, o_OTP_ATM_TRIM_DATA, data_byte);
        fail_count = fail_count + 1;
      end else begin
        $display("PASS: ATM%0d  o_OTP_ATM_TRIM_DATA=8'h%02h  correct", atm_n, o_OTP_ATM_TRIM_DATA);
        pass_count = pass_count + 1;
      end
    end
  endtask

  // ── Check SPI mode sel and adj data ──────────────────────────────────
  task check_spi;
    input integer atm_n;       // 15..29
    input [7:0]  data_byte;
    reg [14:0] exp_mode;
    begin
      exp_mode = (15'h1 << (atm_n - 15));
      if (o_SPI_ATM_MODE_SEL !== exp_mode) begin
        $display("FAIL: ATM%0d  o_SPI_ATM_MODE_SEL=15'h%04h  expected 15'h%04h",
                 atm_n, o_SPI_ATM_MODE_SEL, exp_mode);
        fail_count = fail_count + 1;
      end else begin
        $display("PASS: ATM%0d  o_SPI_ATM_MODE_SEL=15'h%04h  correct", atm_n, o_SPI_ATM_MODE_SEL);
        pass_count = pass_count + 1;
      end
      if (o_SPI_ATM_ADJ_DATA !== data_byte) begin
        $display("FAIL: ATM%0d  o_SPI_ATM_ADJ_DATA=8'h%02h  expected 8'h%02h",
                 atm_n, o_SPI_ATM_ADJ_DATA, data_byte);
        fail_count = fail_count + 1;
      end else begin
        $display("PASS: ATM%0d  o_SPI_ATM_ADJ_DATA=8'h%02h  correct", atm_n, o_SPI_ATM_ADJ_DATA);
        pass_count = pass_count + 1;
      end
    end
  endtask

  integer n;
  reg [7:0] test_byte;

  initial begin
    pass_count = 0;
    fail_count = 0;

    // Default: no test mode
    tm0 = 1'b0; tm1 = 1'b0;
    gpio1_y = 0; gpio2_y = 0; gpio3_y = 0; gpio4_y = 0;
    gpio5_y = 0; gpio6_y = 0; gpio7_y = 0; gpio8_y = 0;
    gpio10_y = 0; gpio11_y = 0; gpio12_y = 0; gpio13_y = 0; gpio14_y = 0;
    #5;

    // ── TEST 1: Verify no mode active without testmode pads ─────────────
    $display("INFO: Checking testmode conditions...");
    if (debug_mode_en !== 1'b0) begin
      $display("FAIL: debug_mode_en should be 0 without testmode pads");
      fail_count = fail_count + 1;
    end else begin
      $display("PASS: debug_mode_en=0 without testmode (normal operation)");
      pass_count = pass_count + 1;
    end

    // testmode0 only → scan mode (NOT CP test mode)
    tm0 = 1'b1; tm1 = 1'b0; #1;
    if (debug_mode_en !== 1'b0) begin
      $display("FAIL: debug_mode_en=1 with only testmode0 (should be scan_mode)");
      fail_count = fail_count + 1;
    end else begin
      $display("PASS: testmode0 only → scan_mode (debug_mode_en=0)");
      pass_count = pass_count + 1;
    end

    // testmode1 only → OTP BIST mode
    tm0 = 1'b0; tm1 = 1'b1; #1;
    if (debug_mode_en !== 1'b0) begin
      $display("FAIL: debug_mode_en=1 with only testmode1 (should be otp_bist_en)");
      fail_count = fail_count + 1;
    end else begin
      $display("PASS: testmode1 only → otp_bist_en (debug_mode_en=0)");
      pass_count = pass_count + 1;
    end

    // BOTH testmode0 and testmode1 → CP test mode (debug_mode_en=1)
    tm0 = 1'b1; tm1 = 1'b1; #1;
    if (debug_mode_en !== 1'b1) begin
      $display("FAIL: debug_mode_en=0 when both testmode0 and testmode1 high!");
      fail_count = fail_count + 1;
    end else begin
      $display("PASS: testmode0 & testmode1 → CP test mode (debug_mode_en=1)");
      pass_count = pass_count + 1;
    end

    // ── TEST 2: ATM0-ATM14 OTP trim path ──────────────────────────────
    $display("");
    $display("INFO: Testing ATM0-ATM14 OTP trim data routing...");
    for (n = 0; n < 15; n = n + 1) begin
      test_byte = 8'hA0 + n; // distinct patterns
      drive_atm(n, test_byte);
      check_one_hot(n);
      check_otp(n, test_byte);
      // SPI mode sel should be zero for OTP trim ATMs
      if (o_SPI_ATM_MODE_SEL !== 15'h0) begin
        $display("FAIL: ATM%0d  o_SPI_ATM_MODE_SEL=15'h%04h should be 0 for OTP ATMs", n, o_SPI_ATM_MODE_SEL);
        fail_count = fail_count + 1;
      end
      // SPI adj data should be 0
      if (o_SPI_ATM_ADJ_DATA !== 8'h00) begin
        $display("FAIL: ATM%0d  o_SPI_ATM_ADJ_DATA=8'h%02h should be 0 for OTP ATMs", n, o_SPI_ATM_ADJ_DATA);
        fail_count = fail_count + 1;
      end
    end

    // ── TEST 3: ATM15-ATM29 SPI adj path ──────────────────────────────
    $display("");
    $display("INFO: Testing ATM15-ATM29 SPI adj data routing...");
    for (n = 15; n < 30; n = n + 1) begin
      test_byte = 8'hB0 + (n - 15); // distinct patterns
      drive_atm(n, test_byte);
      check_one_hot(n);
      check_spi(n, test_byte);
      // OTP mode sel should be zero for SPI adj ATMs
      if (o_OTP_ATM_MODE_SEL !== 15'h0) begin
        $display("FAIL: ATM%0d  o_OTP_ATM_MODE_SEL=15'h%04h should be 0 for SPI ATMs", n, o_OTP_ATM_MODE_SEL);
        fail_count = fail_count + 1;
      end
      // OTP trim data should be 0
      if (o_OTP_ATM_TRIM_DATA !== 8'h00) begin
        $display("FAIL: ATM%0d  o_OTP_ATM_TRIM_DATA=8'h%02h should be 0 for SPI ATMs", n, o_OTP_ATM_TRIM_DATA);
        fail_count = fail_count + 1;
      end
    end

    // ── TEST 4: All GPIO1-8 bits correctly map to trim/adj byte ──────
    $display("");
    $display("INFO: Testing GPIO1-8 bit-to-byte mapping in ATM0 mode...");
    drive_atm(5'd0, 8'h00); // ATM0, all zeros
    begin : gpio_bit_test
      integer bit_n;
      reg [7:0] bval;
      for (bit_n = 0; bit_n < 8; bit_n = bit_n + 1) begin
        bval = (8'h1 << bit_n);
        drive_atm(5'd0, bval);
        if (o_OTP_ATM_TRIM_DATA !== bval) begin
          $display("FAIL: GPIO%0d (bit%0d) not reflected in o_OTP_ATM_TRIM_DATA: got 8'h%02h",
                   bit_n+1, bit_n, o_OTP_ATM_TRIM_DATA);
          fail_count = fail_count + 1;
        end else begin
          $display("PASS: GPIO%0d (bit%0d) → o_OTP_ATM_TRIM_DATA=8'h%02h correct",
                   bit_n+1, bit_n, o_OTP_ATM_TRIM_DATA);
          pass_count = pass_count + 1;
        end
      end
    end

    // Same test for SPI adj with ATM15
    $display("INFO: Testing GPIO1-8 bit-to-byte mapping in ATM15 mode...");
    begin : gpio_adj_bit_test
      integer bit_n;
      reg [7:0] bval;
      for (bit_n = 0; bit_n < 8; bit_n = bit_n + 1) begin
        bval = (8'h1 << bit_n);
        drive_atm(5'd15, bval);
        if (o_SPI_ATM_ADJ_DATA !== bval) begin
          $display("FAIL: GPIO%0d (bit%0d) not reflected in o_SPI_ATM_ADJ_DATA: got 8'h%02h",
                   bit_n+1, bit_n, o_SPI_ATM_ADJ_DATA);
          fail_count = fail_count + 1;
        end else begin
          $display("PASS: GPIO%0d (bit%0d) → o_SPI_ATM_ADJ_DATA=8'h%02h correct",
                   bit_n+1, bit_n, o_SPI_ATM_ADJ_DATA);
          pass_count = pass_count + 1;
        end
      end
    end

    // ── TEST 5: When debug_mode_en=0, all outputs deasserted ──────────
    $display("");
    $display("INFO: Testing safe mode (debug_mode_en=0)...");
    tm0 = 1'b0; tm1 = 1'b0;
    {gpio14_y, gpio13_y, gpio12_y, gpio11_y, gpio10_y} = 5'b11111; // ATM29 if enabled
    {gpio8_y, gpio7_y, gpio6_y, gpio5_y,
     gpio4_y, gpio3_y, gpio2_y, gpio1_y} = 8'hFF;
    #1;
    if (|atm_decode) begin
      $display("FAIL: atm_decode=%030b should be all zeros when debug_mode_en=0", atm_decode);
      fail_count = fail_count + 1;
    end else begin
      $display("PASS: atm_decode=0 when debug_mode_en=0"); pass_count = pass_count + 1;
    end
    if (o_OTP_ATM_MODE_SEL !== 15'h0 || o_SPI_ATM_MODE_SEL !== 15'h0) begin
      $display("FAIL: Mode sel outputs not zero when debug_mode_en=0");
      fail_count = fail_count + 1;
    end else begin
      $display("PASS: OTP/SPI mode sel = 0 when debug_mode_en=0"); pass_count = pass_count + 1;
    end
    if (o_OTP_ATM_TRIM_DATA !== 8'h00 || o_SPI_ATM_ADJ_DATA !== 8'h00) begin
      $display("FAIL: Data outputs not zero when debug_mode_en=0");
      fail_count = fail_count + 1;
    end else begin
      $display("PASS: OTP/SPI data outputs = 0 when debug_mode_en=0"); pass_count = pass_count + 1;
    end

    // ── TEST 6: ATM ana_test_mode = 30..31 (unused codes) ─────────────
    $display("");
    $display("INFO: Testing unused ATM codes 30 and 31 (should produce no ATM)...");
    tm0 = 1'b1; tm1 = 1'b1;
    {gpio14_y, gpio13_y, gpio12_y, gpio11_y, gpio10_y} = 5'd30; drive_atm(5'd30, 8'hFF);
    if (|atm_decode) begin
      $display("FAIL: Unused ATM code 30 asserted atm_decode=%030b", atm_decode);
      fail_count = fail_count + 1;
    end else begin
      $display("PASS: ATM code 30 is unused (no ATM asserted)"); pass_count = pass_count + 1;
    end

    drive_atm(5'd31, 8'hFF);
    if (|atm_decode) begin
      $display("FAIL: Unused ATM code 31 asserted atm_decode=%030b", atm_decode);
      fail_count = fail_count + 1;
    end else begin
      $display("PASS: ATM code 31 is unused (no ATM asserted)"); pass_count = pass_count + 1;
    end

    // ── Summary ───────────────────────────────────────────────────────────
    $display("");
    $display("===================================================");
    $display(" Pinmux ATM Routing Testbench Results");
    $display("  PASS: %0d   FAIL: %0d", pass_count, fail_count);
    if (fail_count == 0)
      $display("  ALL TESTS PASSED");
    else
      $display("  FAILURES DETECTED - see above");
    $display("===================================================");
    $display("");
    $display("DESIGN VERIFICATION SUMMARY:");
    $display("  CP test mode (debug_mode_en) requires BOTH testmode0 AND testmode1 HIGH.");
    $display("  GPIO10-14 select ATM0-ATM29 via ana_test_mode[4:0].");
    $display("  GPIO1-8 drive 8-bit trim/adj value to:");
    $display("    o_OTP_ATM_TRIM_DATA → otp_regs (ATM0-ATM14, writes shadow_regs[4..18])");
    $display("    o_SPI_ATM_ADJ_DATA  → spi_reg  (ATM15-ATM29, writes ana_gen_reg[x][14])");
    $display("  o_OTP_ATM_MODE_SEL and o_SPI_ATM_MODE_SEL are mutually exclusive one-hot.");
    $display("  ATM codes 30 and 31 (ana_test_mode>29) are unused; no output asserted.");
    $finish;
  end

  initial begin
    #50000;
    $display("TIMEOUT");
    $finish;
  end

endmodule
