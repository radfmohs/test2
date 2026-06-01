// =============================================================================
// Testbench: spi_reg_controller_tb
//
// Reproduces a timing bug in spi_reg_wavegen.sv where the register read-data
// mux used a clocked (posedge i_clk) always block instead of a combinational
// one.  spi_reg.sv and spi_reg_nirs.sv had already been converted to
// combinational reads, but spi_reg_wavegen.sv was missed.
//
// Root cause
// ----------
// The SPI controller (spi_slave_controller) latches o_addr at SPI falling-
// edge cycle K=10 and then loads tx_buf from i_rd_data at K=15 (≈312 ns later
// at 16 MHz SPI).  With a system clock much slower than 3 MHz there are ZERO
// sys_clk rising edges in that 312 ns window.  Because the wavegen read path
// updates reg_rd_data only on posedge i_clk, it still reflects the PREVIOUS
// address at the moment tx_buf is loaded, returning stale data to the master.
//
// How to run
// ----------
// Bug (clocked read):
//   iverilog -g2012 -o /tmp/spi_tb \
//     spi_slave/tb/spi_reg_controller_tb.sv \
//     spi_slave/rtl/spi_reg_controller_test.sv && vvp /tmp/spi_tb
//
// Fix (combinational read):
//   iverilog -g2012 -DUSE_COMB_WG -o /tmp/spi_tb \
//     spi_slave/tb/spi_reg_controller_tb.sv \
//     spi_slave/rtl/spi_reg_controller_test.sv && vvp /tmp/spi_tb
// =============================================================================

`timescale 1ns/1ps

module spi_reg_controller_tb;

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------
localparam real  SPI_HALF  = 31.25; // 16 MHz SPI  (half-period in ns)
localparam real  SYS_HALF  = 5000;  // 100 kHz system clock – far slower than SPI
localparam       DATA_W    = 8;
localparam       ADDR_W    = 8;
localparam       EEG_CHN   = 1;

// Command byte encoding (single mode)
// cmd[7]=R/W  cmd[6:4]=peripheral  cmd[1]=burst  cmd[0]=dual
localparam [7:0] CMD_NORMAL_WR = 8'h80;  // R/W=1, normal
localparam [7:0] CMD_NORMAL_RD = 8'h00;  // R/W=0, normal
localparam [7:0] CMD_WG_WR     = 8'hE0;  // R/W=1, cmd[6:4]=3'b110
localparam [7:0] CMD_WG_RD     = 8'h60;  // R/W=0, cmd[6:4]=3'b110

// ---------------------------------------------------------------------------
// DUT interface
// ---------------------------------------------------------------------------
reg               i_rst_n;
reg               i_sclk;
wire              i_sclk_neg;
reg               i_cs_n;
reg               i_mosi;
wire              o_miso;

wire [ADDR_W-1:0] o_addr;
wire              o_wr;
wire              o_rd;
wire              wavegen_cmd_reg;
wire              o_wavegen_wr;
wire              o_wavegen_rd;
wire              nirs_cmd_reg;
wire              o_nirs_wr;
wire              o_nirs_rd;
wire [DATA_W-1:0] o_wr_data;
reg  [DATA_W-1:0] i_rd_data;

assign i_sclk_neg = ~i_sclk;   // slave clocks on falling edge of SCLK

// ---------------------------------------------------------------------------
// System clock (intentionally much slower than SPI to expose the stale-read)
// ---------------------------------------------------------------------------
reg sys_clk;
initial sys_clk = 1'b0;
always #(SYS_HALF) sys_clk = ~sys_clk;

// ---------------------------------------------------------------------------
// DUT
// ---------------------------------------------------------------------------
spi_slave_controller #(
    .EEG_CHN_NUM  (EEG_CHN),
    .EEG_DATA_SIZE(24),
    .DATA_WIDTH   (DATA_W),
    .ADDR_WIDTH   (ADDR_W)
) dut (
    .i_rst_n        (i_rst_n),
    .i_sclk         (i_sclk),
    .i_sclk_neg     (i_sclk_neg),
    .o_dual_en      (),
    .o_dual_wr      (),
    .i_cs_n         (i_cs_n),
    .i_channel_max  (5'd1),
    .i_mosi         (i_mosi),
    .i_mosi1        (1'b0),
    .i_status_words (40'b0),
    .cpha           (1'b0),
    .daisy_en       (1'b0),
    .daisy_in       (1'b0),
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
    .i_rd_data      (i_rd_data),
    .o_miso         (o_miso),
    .o_miso1        (),
    .o_imeas_intr_clr(),
    .mode           (2'b10)
    // imeas_chdata left unconnected: unused in register read/write tests
);

// ---------------------------------------------------------------------------
// Simple register model
// ---------------------------------------------------------------------------
reg [DATA_W-1:0] normal_regs [0:255];
reg [DATA_W-1:0] wg_regs     [0:255];

integer idx;
initial begin
    for (idx = 0; idx < 256; idx = idx + 1) begin
        normal_regs[idx] = 8'h00;
        wg_regs[idx]     = 8'h00;
    end
end

// Write capture: DUT asserts o_wr / o_wavegen_wr for one SPI cycle after
// latch_state fires.  Capture on the posedge of each strobe.
always @(posedge o_wr)        normal_regs[o_addr] = o_wr_data;
always @(posedge o_wavegen_wr) wg_regs[o_addr]    = o_wr_data;

// ---- BUG: clocked WG read (mirrors the buggy always @ (posedge i_clk) in
//      spi_reg_wavegen.sv before the fix) ---------------------------------
// wg_rd_data_clk is only refreshed on posedge sys_clk.  Between o_addr
// settling (SPI cycle K=10) and tx_buf sampling i_rd_data (K=15) there are
// only ~312 ns.  sys_clk period = 10 µs >> 312 ns, so no sys_clk edge
// occurs and wg_rd_data_clk holds the value computed for the PREVIOUS address.
reg [DATA_W-1:0] wg_rd_data_clk;
initial wg_rd_data_clk = 8'h00;
always @(posedge sys_clk)
    wg_rd_data_clk <= wg_regs[o_addr];

// ---- FIX: combinational WG read (mirrors the corrected always @ (*) in
//      spi_reg_wavegen.sv after the fix) ----------------------------------
wire [DATA_W-1:0] wg_rd_data_comb = wg_regs[o_addr];

// i_rd_data mux: USE_COMB_WG selects the fixed path
always @(*) begin
`ifdef USE_COMB_WG
    i_rd_data = wavegen_cmd_reg ? wg_rd_data_comb : normal_regs[o_addr];
`else
    i_rd_data = wavegen_cmd_reg ? wg_rd_data_clk  : normal_regs[o_addr];
`endif
end

// ---------------------------------------------------------------------------
// SPI master tasks
//
// Protocol (single-mode, CPOL=0 CPHA=1-equivalent):
//   SCLK idles LOW.  Master drives MOSI before the rising edge; slave
//   samples MOSI at the falling edge (posedge i_sclk_neg).
//
//   Write  (32 SCLK cycles): CS_N=0 | addr[7:0] | cmd[7:0] | data[7:0] |
//                             pad[7:0] | CS_N=1
//     o_wavegen_wr fires one SPI cycle after latch_state (at SPI cycle K=26).
//
//   Read   (24 SCLK cycles): CS_N=0 | addr[7:0] | cmd[7:0] | dummy[7:0] |
//                             CS_N=1
//     Slave drives MISO from the rising edge of cycle 17 onward.
//     Master samples MISO at the falling edges of cycles 17-24 (b=7..0).
// ---------------------------------------------------------------------------

task spi_write;
    input [7:0] addr;
    input [7:0] cmd;
    input [7:0] data;
    reg [31:0] pkt;
    integer b;
    begin
        pkt    = {addr, cmd, data, 8'h00};
        i_cs_n = 1'b0;
        #(SPI_HALF);
        for (b = 31; b >= 0; b = b - 1) begin
            i_mosi = pkt[b];  // drive before rising edge
            i_sclk = 1'b1;
            #(SPI_HALF);
            i_sclk = 1'b0;   // falling edge: slave samples MOSI
            #(SPI_HALF);
        end
        i_cs_n = 1'b1;
        i_mosi = 1'b0;
        #(SPI_HALF * 4);
    end
endtask

task spi_read;
    input  [7:0] addr;
    input  [7:0] cmd;
    output [7:0] result;
    reg [23:0] pkt;
    reg [7:0]  miso_data;
    integer b;
    begin
        pkt       = {addr, cmd, 8'h00};
        miso_data = 8'h00;
        i_cs_n    = 1'b0;
        #(SPI_HALF);
        for (b = 23; b >= 0; b = b - 1) begin
            i_mosi = pkt[b];
            i_sclk = 1'b1;
            #(SPI_HALF);
            i_sclk = 1'b0;
            // tx_buf loaded at K=15; slave drives dff_miso from rising edge of
            // K=17 onward.  At falling edge K=17 (b=7) through K=24 (b=0) the
            // master reads the 8 data bits MSB-first.
            if (b <= 7) miso_data[b] = o_miso;
            #(SPI_HALF);
        end
        result = miso_data;
        i_cs_n = 1'b1;
        i_mosi = 1'b0;
        #(SPI_HALF * 4);
    end
endtask

// ---------------------------------------------------------------------------
// Test sequence
// ---------------------------------------------------------------------------
integer fail_cnt;
reg [7:0] rd_result;

initial begin
    $dumpfile("/tmp/spi_tb.vcd");
    $dumpvars(0, spi_reg_controller_tb);

    fail_cnt  = 0;
    i_rst_n   = 1'b0;
    i_cs_n    = 1'b1;
    i_sclk    = 1'b0;
    i_mosi    = 1'b0;
    i_rd_data = 8'h00;
    #200;
    i_rst_n = 1'b1;
    #100;

    // ------------------------------------------------------------------
    // Test 1 – NORMAL register write then read (baseline, always passes)
    // ------------------------------------------------------------------
    $display("--- Test 1: NORMAL write 0xAB to addr 0x12, read back ---");
    spi_write(8'h12, CMD_NORMAL_WR, 8'hAB);
    spi_read (8'h12, CMD_NORMAL_RD, rd_result);
    if (rd_result === 8'hAB)
        $display("PASS: got 0x%02h", rd_result);
    else begin
        $display("FAIL: got 0x%02h, expected 0xAB", rd_result);
        fail_cnt = fail_cnt + 1;
    end

    // ------------------------------------------------------------------
    // Test 2 – WG write then read at the SAME address (both paths pass)
    // After @(posedge sys_clk) wg_rd_data_clk is up-to-date for addr 0x40.
    // ------------------------------------------------------------------
    $display("--- Test 2: WG write 0xCD to addr 0x40, read back ---");
    spi_write(8'h40, CMD_WG_WR, 8'hCD);
    @(posedge sys_clk); #1;   // let clocked model absorb write to addr 0x40; o_addr is still 0x40 here
    spi_read (8'h40, CMD_WG_RD, rd_result);
    if (rd_result === 8'hCD)
        $display("PASS: got 0x%02h", rd_result);
    else begin
        $display("FAIL: got 0x%02h, expected 0xCD", rd_result);
        fail_cnt = fail_cnt + 1;
    end

    // ------------------------------------------------------------------
    // Test 3 – THE TIMING BUG
    //
    // Write 0xAB to WG addr 0x40, then read WG addr 0x41 (never written,
    // so the correct answer is 0x00).
    //
    // Steps:
    //  1. spi_write → wg_regs[0x40]=0xAB, o_addr stays at 0x40 (CS=1)
    //  2. @(posedge sys_clk) → wg_rd_data_clk = wg_regs[0x40] = 0xAB
    //  3. spi_read(0x41) starts IMMEDIATELY after step 2
    //     – o_addr changes to 0x41 at SPI cycle K=10 (~625 ns in)
    //     – tx_buf latches i_rd_data at K=15 (~937 ns in)
    //     – window between addr change and latch = ~312 ns
    //     – sys_clk period = 10 µs >> 312 ns → no sys_clk fires in window
    //
    //  BUG (clocked): wg_rd_data_clk still = 0xAB (stale addr 0x40)
    //                 → tx_buf = 0xAB, master receives 0xAB  WRONG
    //  FIX (comb):    wg_rd_data_comb = wg_regs[0x41] = 0x00 immediately
    //                 → tx_buf = 0x00, master receives 0x00  CORRECT
    // ------------------------------------------------------------------
    $display("--- Test 3 [TIMING BUG]: WG write 0xAB->0x40, read 0x41 (expect 0x00) ---");
    spi_write(8'h40, CMD_WG_WR, 8'hAB);
    // Force wg_rd_data_clk to reflect addr 0x40 (= 0xAB) by waiting for
    // one sys_clk posedge.  After this, o_addr is still 0x40 (SPI idle).
    @(posedge sys_clk); #1;
    // Start read of 0x41 immediately – sys_clk period >> read window
    spi_read (8'h41, CMD_WG_RD, rd_result);
    if (rd_result === 8'h00)
        $display("PASS: got 0x%02h", rd_result);
    else begin
        $display("FAIL: got 0x%02h, expected 0x00 -- STALE DATA BUG", rd_result);
        fail_cnt = fail_cnt + 1;
    end

    // ------------------------------------------------------------------
    // Test 4 – WG write 0x55 to addr 0x41, read back (sanity check)
    // ------------------------------------------------------------------
    $display("--- Test 4: WG write 0x55 to addr 0x41, read back ---");
    spi_write(8'h41, CMD_WG_WR, 8'h55);
    @(posedge sys_clk); #1;
    spi_read (8'h41, CMD_WG_RD, rd_result);
    if (rd_result === 8'h55)
        $display("PASS: got 0x%02h", rd_result);
    else begin
        $display("FAIL: got 0x%02h, expected 0x55", rd_result);
        fail_cnt = fail_cnt + 1;
    end

    // ------------------------------------------------------------------
    // Summary
    // ------------------------------------------------------------------
    $display("=============================");
    if (fail_cnt == 0)
        $display("ALL 4 TESTS PASSED");
    else
        $display("%0d / 4 TEST(s) FAILED", fail_cnt);
    $display("=============================");
    $finish;
end

endmodule
