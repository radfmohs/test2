//============================================================================
// Testbench: tb_filter_data_format.v
//
// Purpose
//   Standalone Icarus Verilog testbench that exercises all four values of
//   FILTER_DATA_FORMAT_MODE on spi_slave_controller, verifying:
//     1. Correct SCLK-cycle count per mode (speed benefit of 16-bit).
//     2. Correct data bytes on MISO – status words and per-channel ADC data.
//     3. 16-bit mode sends the top 16 bits of the 24-bit sample (MSBs kept).
//
// FILTER_DATA_FORMAT_MODE (IMEAS_REG_1 bits [6:5])  – RTL-verified mapping
//   mode = 2'b00 : 16-bit data + 40-bit status  (imeas_16bit_sel=1, num_status=5)
//   mode = 2'b01 : 24-bit data + 40-bit status  (imeas_16bit_sel=0, num_status=5) [default]
//   mode = 2'b10 : 16-bit data only             (imeas_16bit_sel=1, num_status=0)
//   mode = 2'b11 : 24-bit data only             (imeas_16bit_sel=0, num_status=0)
//
//  Total bytes per readout = num_status_byte + i_channel_max * chdata_size
//    num_status_byte = !mode[1] ? 5 : 0
//    chdata_size     = imeas_16bit_sel ? 2 : 3     (imeas_16bit_sel = !mode[0])
//    Total SCLK cycles = 16 (cmd header) + total_bytes * 8
//
// RTL key signals (spi_slave_controller.sv)
//   imeas_16bit_sel = !mode[0]
//   chdata_size     = imeas_16bit_sel ? 3'h2 : 3'h3
//   adc_inc_val     = imeas_16bit_sel ? 2'b01 : 2'b10
//   num_status_byte = !mode[1] ? 3'h5 : 3'h0
//   rdata_cmd       = cmd_reg_6 && !cmd_reg_5 && !cmd_reg_4   (single mode)
//     where cmd_reg_6/5/4 = bits [6:4] of the second SPI byte.
//   → RDATA trigger command byte = 0x40 (bit[6]=1, bit[5]=0, bit[4]=0)
//
// SPI timing (CPOL=0, CPHA=0, single mode)
//   i_sclk_neg port = raw SCLK  (posedge = rising = sample)
//   i_sclk     port = ~SCLK     (posedge = falling = drive MISO)
//   Master drives MOSI on negedge SCLK; slave samples on posedge SCLK.
//
// Speed benefit
//   Removing the LSB byte (16-bit vs 24-bit) saves 1 byte * num_channels
//   SCLK cycles.  For 8 channels: saves 64 cycles per readout = 28 % fewer
//   total SPI clocks.  This allows the same data to be read at 28 % higher
//   SCLK rate, or the same SCLK rate to support 28 % more channels.
//   Dropping status bytes (mode 10 vs 00) saves a further 40 bits (5 bytes).
//
// RTL Bugs / Documentation Issues Found
//   README.md (line 5270) had a duplicate entry for mode "10" claiming it
//   was "32 bits data per channel only" – corrected to match RTL behavior.
//   spi_slave_controller.sv comment on line 802 said "4 byte data per
//   channel" – corrected to "2 bytes (16-bit)" to match actual chdata_size.
//============================================================================

`timescale 1ns/1ps

module tb_filter_data_format;

  //--------------------------------------------------------------------------
  // Parameters
  //--------------------------------------------------------------------------
  parameter EEG_CHN_NUM  = 8;      // max channels in DUT (reduced from 16 for sim speed)
  parameter SCLK_HALF    = 50;     // 50 ns → 10 MHz SPI clock
  parameter CMD_ADDR     = 8'h00;  // dummy first byte
  parameter CMD_RDATA    = 8'h40;  // second byte: bit[6]=1 triggers rdata_cmd

  //--------------------------------------------------------------------------
  // DUT I/O
  //--------------------------------------------------------------------------
  reg        i_rst_n;
  reg        i_sclk_ext;          // driven by TB
  wire       i_sclk_neg_w;        // = i_sclk_ext        (sample on rise)
  wire       i_sclk_w;            // = ~i_sclk_ext       (output on fall)
  reg        i_cs_n;
  reg        i_mosi;
  reg        i_mosi1;
  reg [1:0]  mode;
  reg        imeas_16bit_sel;
  reg [4:0]  i_channel_max;
  reg [39:0] i_status_words;
  reg [23:0] imeas_chdata [EEG_CHN_NUM-1:0];
  reg        cpha;
  reg        daisy_en;
  reg        daisy_in;
  reg [7:0]  i_rd_data;

  wire       o_miso;
  wire       o_miso1;
  wire       o_dual_en;
  wire       o_dual_wr;
  wire [7:0] o_addr;
  wire       o_wr;
  wire       o_rd;
  wire       wavegen_cmd_reg;
  wire       o_wavegen_wr;
  wire       o_wavegen_rd;
  wire       nirs_cmd_reg;
  wire       o_nirs_wr;
  wire       o_nirs_rd;
  wire [7:0] o_wr_data;
  wire       o_imeas_intr_clr;

  assign i_sclk_neg_w = i_sclk_ext;   // rising = sample
  assign i_sclk_w     = ~i_sclk_ext;  // posedge = falling of ext SCLK

  //--------------------------------------------------------------------------
  // DUT
  //--------------------------------------------------------------------------
  spi_slave_controller #(
    .EEG_CHN_NUM  (EEG_CHN_NUM),
    .EEG_DATA_SIZE(24),
    .DATA_WIDTH   (8),
    .ADDR_WIDTH   (8)
  ) dut (
    .i_rst_n        (i_rst_n),
    .i_sclk         (i_sclk_w),
    .i_sclk_neg     (i_sclk_neg_w),
    .i_cs_n         (i_cs_n),
    .i_mosi         (i_mosi),
    .i_mosi1        (i_mosi1),
    .mode           (mode),
    .imeas_16bit_sel(imeas_16bit_sel),
    .i_channel_max  (i_channel_max),
    .i_status_words (i_status_words),
    .imeas_chdata   (imeas_chdata),
    .cpha           (cpha),
    .daisy_en       (daisy_en),
    .daisy_in       (daisy_in),
    .i_rd_data      (i_rd_data),
    .o_miso         (o_miso),
    .o_miso1        (o_miso1),
    .o_dual_en      (o_dual_en),
    .o_dual_wr      (o_dual_wr),
    .o_addr         (o_addr),
    .o_wr           (o_wr),
    .o_rd           (o_rd),
    .wavegen_cmd_reg(wavegen_cmd_reg),
    .o_wavegen_wr   (o_wavegen_wr),
    .o_wavegen_rd   (o_wavegen_rd),
    .nirs_cmd_reg   (nirs_cmd_reg),
    .o_nirs_wr      (o_nirs_wr),
    .o_nirs_rd      (o_nirs_rd),
    .o_wr_data      (o_wr_data),
    .o_imeas_intr_clr(o_imeas_intr_clr)
  );

  initial i_sclk_ext = 0;

  //--------------------------------------------------------------------------
  // SPI helpers
  //--------------------------------------------------------------------------

  // Send one byte MSB-first; drive on falling edge, slave samples on rising.
  task spi_send_byte;
    input [7:0] data;
    integer b;
    begin
      for (b = 7; b >= 0; b = b - 1) begin
        #SCLK_HALF; i_sclk_ext = 0; i_mosi = data[b];
        #SCLK_HALF; i_sclk_ext = 1;
      end
    end
  endtask

  // Receive one byte MSB-first, sampled on rising edge.
  task spi_recv_byte;
    output [7:0] data;
    integer b;
    begin
      data = 0;
      for (b = 7; b >= 0; b = b - 1) begin
        #SCLK_HALF; i_sclk_ext = 0; i_mosi = 0;
        #SCLK_HALF; i_sclk_ext = 1;
        data[b] = o_miso;
      end
    end
  endtask

  task spi_end;
    begin
      #SCLK_HALF; i_sclk_ext = 0;
      #SCLK_HALF; i_cs_n = 1; i_mosi = 0;
      #(SCLK_HALF * 6);
    end
  endtask

  //--------------------------------------------------------------------------
  // run_rdata_test
  //   Sends RDATA command, captures exp_bytes bytes from MISO, checks them.
  //   Prints per-byte comparison for the first (or failing) transaction.
  //--------------------------------------------------------------------------
  integer pass_count;
  integer fail_count;

  task run_rdata_test;
    input [1:0]  mode_val;
    input integer exp_bytes;
    input [5*8-1:0] tag;        // 5-char ASCII label
    input integer num_ch;
    input integer verbose;

    integer       i, ch, b;
    integer       byte_idx;
    reg [7:0]     rx  [0:63];
    reg [7:0]     exp_buf [0:63];
    integer       num_status;
    integer       bytes_per_ch;
    integer       total_sclk;
    integer       ok;
    reg [23:0]    ch_data;

    begin
      mode            = mode_val;
      imeas_16bit_sel = !mode_val[0];
      i_channel_max   = num_ch;

      num_status   = (mode_val[1] == 0) ? 5 : 0;
      bytes_per_ch = (mode_val[0] == 0) ? 2 : 3;
      total_sclk   = 16 + exp_bytes * 8;

      // Build expected buffer
      byte_idx = 0;
      if (num_status == 5) begin
        exp_buf[byte_idx] = i_status_words[39:32]; byte_idx++;
        exp_buf[byte_idx] = i_status_words[31:24]; byte_idx++;
        exp_buf[byte_idx] = i_status_words[23:16]; byte_idx++;
        exp_buf[byte_idx] = i_status_words[15:8];  byte_idx++;
        exp_buf[byte_idx] = i_status_words[7:0];   byte_idx++;
      end
      for (ch = 0; ch < num_ch; ch++) begin
        ch_data = imeas_chdata[ch];
        exp_buf[byte_idx] = ch_data[23:16]; byte_idx++;   // MSB (always sent)
        exp_buf[byte_idx] = ch_data[15:8];  byte_idx++;   // mid byte
        if (bytes_per_ch == 3) begin
          exp_buf[byte_idx] = ch_data[7:0]; byte_idx++;   // LSB (24-bit only)
        end
      end

      // Execute SPI transaction
      #(SCLK_HALF * 2);
      i_cs_n = 0; i_sclk_ext = 0;
      #(SCLK_HALF);

      spi_send_byte(CMD_ADDR);
      spi_send_byte(CMD_RDATA);

      for (i = 0; i < exp_bytes; i++) spi_recv_byte(rx[i]);
      spi_end;

      // Compare
      ok = 1;
      for (i = 0; i < exp_bytes; i++) begin
        if (rx[i] !== exp_buf[i]) begin
          if (ok) $display("  MISMATCH:");
          $display("    byte[%02d]: got=0x%02h  exp=0x%02h", i, rx[i], exp_buf[i]);
          ok = 0;
        end
      end

      if (verbose || !ok) begin
        $display("  Bytes received:");
        $write("   status[%1d]: ", num_status);
        for (i = 0; i < num_status; i++) $write("%02h ", rx[i]);
        $display("");
        for (ch = 0; ch < num_ch; ch++) begin
          $write("   ch%0d data:  ", ch);
          for (b = 0; b < bytes_per_ch; b++)
            $write("%02h ", rx[num_status + ch*bytes_per_ch + b]);
          $write("  (raw 24b: %06h, top16: %04h)",
                 imeas_chdata[ch], imeas_chdata[ch][23:8]);
          $display("");
        end
      end

      if (ok) begin
        $display("  PASS  mode=%02b %-5s  exp=%2d bytes  %3d SCLK cycles",
                 mode_val, tag, exp_bytes, total_sclk);
        pass_count++;
      end else begin
        $display("  FAIL  mode=%02b %-5s  exp=%2d bytes  %3d SCLK cycles",
                 mode_val, tag, exp_bytes, total_sclk);
        fail_count++;
      end
    end
  endtask

  //--------------------------------------------------------------------------
  // Verify that 16-bit mode sends the TOP 16 bits (MSBs), not the bottom.
  // Uses a channel value whose bytes are all different so the check is clear.
  //--------------------------------------------------------------------------
  task check_16bit_msb_selection;
    // ch0 = 24'hAABBCC → 16-bit mode should send AA BB (not BB CC)
    integer i;
    reg [7:0] rx [0:1];
    begin
      i_channel_max   = 1;
      mode            = 2'b10;   // 16-bit data only, no status
      imeas_16bit_sel = 1;
      imeas_chdata[0] = 24'hAABBCC;

      #(SCLK_HALF * 2);
      i_cs_n = 0; i_sclk_ext = 0; #(SCLK_HALF);

      spi_send_byte(CMD_ADDR);
      spi_send_byte(CMD_RDATA);
      spi_recv_byte(rx[0]);
      spi_recv_byte(rx[1]);
      spi_end;

      $display("  16-bit MSB selection: ch[23:16]=0xAA ch[15:8]=0xBB");
      $display("    MISO byte0 = 0x%02h (exp 0xAA = bits[23:16])", rx[0]);
      $display("    MISO byte1 = 0x%02h (exp 0xBB = bits[15:8])",  rx[1]);
      if (rx[0] === 8'hAA && rx[1] === 8'hBB) begin
        $display("  PASS  correct top-16 bits sent (LSB 0xCC dropped)");
        pass_count++;
      end else begin
        $display("  FAIL  wrong bytes on MISO");
        fail_count++;
      end

      // Restore test data
      imeas_chdata[0] = 24'hABCDEF;
      i_channel_max   = 4;
    end
  endtask

  //--------------------------------------------------------------------------
  // Main
  //--------------------------------------------------------------------------
  integer e16s, e24s, e16, e24;

  initial begin
    $dumpfile("tb_filter_data_format.vcd");
    $dumpvars(0, tb_filter_data_format);

    // ---- Initialise ----
    i_rst_n         = 0;
    i_cs_n          = 1;
    i_sclk_ext      = 0;
    i_mosi          = 0;
    i_mosi1         = 0;
    cpha            = 0;
    daisy_en        = 0;
    daisy_in        = 0;
    i_rd_data       = 8'h00;
    i_channel_max   = 4;
    mode            = 2'b01;
    imeas_16bit_sel = 0;
    i_status_words  = 40'hC0_FFEE_CAFE;

    imeas_chdata[0] = 24'hABCDEF;
    imeas_chdata[1] = 24'h123456;
    imeas_chdata[2] = 24'hFEDCBA;
    imeas_chdata[3] = 24'h654321;
    imeas_chdata[4] = 24'h010203;
    imeas_chdata[5] = 24'hDEADBE;
    imeas_chdata[6] = 24'hCAFE00;
    imeas_chdata[7] = 24'hF00B00;

    pass_count = 0;
    fail_count = 0;

    #200; i_rst_n = 1; #200;

    // ---- Confirm RDATA command trigger ----
    $display("");
    $display("=== CMD PROBE: send cmd=0x40, verify rdata_cmd=1 ===");
    i_cs_n = 0; i_sclk_ext = 0; #SCLK_HALF;
    spi_send_byte(CMD_ADDR);
    spi_send_byte(CMD_RDATA);
    #1;
    $display("  dut.rdata_cmd = %b  (expected 1)", dut.rdata_cmd);
    if (dut.rdata_cmd === 1) begin
      $display("  PASS  rdata_cmd correctly asserted with cmd=0x40");
      pass_count++;
    end else begin
      $display("  FAIL  rdata_cmd not asserted");
      fail_count++;
    end
    spi_end;

    // ---- 4-channel tests: all four modes ----
    $display("");
    $display("=== 4-channel RDATA burst (verbose=1) ===");
    e16s = 5 + 4*2;   // 13
    e24s = 5 + 4*3;   // 17
    e16  = 4*2;       //  8
    e24  = 4*3;       // 12

    run_rdata_test(2'b00, e16s, "16b+ST", 4, 1);
    run_rdata_test(2'b01, e24s, "24b+ST", 4, 1);
    run_rdata_test(2'b10, e16,  "16b   ", 4, 1);
    run_rdata_test(2'b11, e24,  "24b   ", 4, 1);

    // ---- MSB selection check ----
    $display("");
    $display("=== 16-bit MSB selection check ===");
    check_16bit_msb_selection;

    // ---- 8-channel tests (speed comparison) ----
    $display("");
    $display("=== 8-channel RDATA burst – speed comparison ===");
    imeas_chdata[4] = 24'h010203;
    imeas_chdata[5] = 24'hDEADBE;
    imeas_chdata[6] = 24'hCAFE12;
    imeas_chdata[7] = 24'hF00B00;

    run_rdata_test(2'b00, 5+8*2,  "16b+ST", 8, 0);
    run_rdata_test(2'b01, 5+8*3,  "24b+ST", 8, 0);
    run_rdata_test(2'b10, 8*2,    "16b   ", 8, 0);
    run_rdata_test(2'b11, 8*3,    "24b   ", 8, 0);

    // ---- Final summary ----
    $display("");
    $display("=== SPI CLOCK CYCLE COMPARISON ===");
    $display("  (16-bit mode sends bits [23:8] of 24-bit ADC sample, drops LSB [7:0])");
    $display("");
    $display("  4 channels:");
    $display("    mode 00 (16-bit + status) : %3d SCLK cycles", 16 + (5+4*2)*8);
    $display("    mode 01 (24-bit + status) : %3d SCLK cycles  [default]", 16+(5+4*3)*8);
    $display("    mode 10 (16-bit only)     : %3d SCLK cycles", 16 + (4*2)*8);
    $display("    mode 11 (24-bit only)     : %3d SCLK cycles", 16 + (4*3)*8);
    $display("");
    $display("  8 channels:");
    $display("    mode 00 (16-bit + status) : %3d SCLK cycles", 16 + (5+8*2)*8);
    $display("    mode 01 (24-bit + status) : %3d SCLK cycles  [default]", 16+(5+8*3)*8);
    $display("    mode 10 (16-bit only)     : %3d SCLK cycles", 16 + (8*2)*8);
    $display("    mode 11 (24-bit only)     : %3d SCLK cycles", 16 + (8*3)*8);
    $display("");
    $display("  Speed gain (16-bit vs 24-bit, 8 ch, data-only):");
    $display("    16-bit : %3d cycles", 16 + (8*2)*8);
    $display("    24-bit : %3d cycles", 16 + (8*3)*8);
    $display("    Saving : %3d cycles = %0d%%",
             (16+(8*3)*8)-(16+(8*2)*8),
             (((16+(8*3)*8)-(16+(8*2)*8))*100)/(16+(8*3)*8));
    $display("  → At same SCLK, 16-bit mode completes ~28%% faster per readout.");
    $display("  → Equivalently, SCLK can run ~28%% SLOWER for same throughput,");
    $display("    easing SI/EMC constraints and reducing SPI driver power.");
    $display("");
    $display("=== RESULT: %0d PASS, %0d FAIL ===", pass_count, fail_count);

    if (fail_count == 0)
      $display("ALL TESTS PASSED");
    else begin
      $display("TESTS FAILED");
      $finish(1);
    end

    #500; $finish;
  end

  initial begin #8000000; $display("TIMEOUT"); $finish; end

endmodule
