//------------------------------------------------------------------------------
// Testbench for spi_reg_controller_test.sv (spi_slave_controller module)
//
// Tests all scenarios in single and dual SPI mode:
//   - Normal register write / read
//   - Burst write / burst read (with address auto-increment)
//   - Wavegen write / read
//   - NIRS write / read
//   - RDATA command (read ADC channel data)
//   - RDATAC command (continuous ADC data read)
//   - Dual-mode enable and all the above in dual SPI mode
//
// Clock relationship for CPOL=0, CPHA=0:
//   i_sclk_neg = actual SPI clock  (state machine clocked on posedge)
//   i_sclk     = ~actual SPI clock (MISO output reg clocked on posedge)
//
// Command encoding (single mode, MSB first):
//   cmd[7]=1  write, 0 read
//   cmd[6:4]: 000=normal, 110=wavegen, 111=NIRS, 1x0=RDATA group (cmd[7]=0,cmd[6]=1)
//   cmd[1]=1  burst (addr auto-increment)
//   cmd[0]=1  enable dual SPI on next transaction
//
// Command encoding (dual mode – different mapping):
//   cmd[7:6]: 01=write, 00=read, 10=RDATA group
//   cmd[5:4]: 00=normal, 10=wavegen, 11=NIRS
//   cmd[1]=1  burst; cmd[5]=1 within RDATA group -> RDATAC
//------------------------------------------------------------------------------

`timescale 1ns/1ps

module spi_reg_controller_tb;

  //--------------------------------------------------------------------------
  // Parameters
  //--------------------------------------------------------------------------
  parameter SPI_CLK_HALF = 31;      // half period of SPI clock (ns) ~16 MHz
  parameter DATA_WIDTH   = 8;
  parameter ADDR_WIDTH   = 8;
  parameter EEG_CHN_NUM  = 16;

  //--------------------------------------------------------------------------
  // Command byte constants (single SPI mode)
  //--------------------------------------------------------------------------
  localparam CMD_S_WR        = 8'h80; // normal write
  localparam CMD_S_RD        = 8'h00; // normal read
  localparam CMD_S_BURST_WR  = 8'h82; // burst write  (addr auto-incr)
  localparam CMD_S_BURST_RD  = 8'h02; // burst read   (addr auto-incr)
  localparam CMD_S_WG_WR     = 8'hE0; // wavegen write
  localparam CMD_S_WG_RD     = 8'h60; // wavegen read
  localparam CMD_S_NIRS_WR   = 8'hF0; // NIRS write
  localparam CMD_S_NIRS_RD   = 8'h70; // NIRS read
  localparam CMD_S_RDATA     = 8'h40; // RDATA
  localparam CMD_S_RDATAC    = 8'h50; // RDATAC
  localparam CMD_DUAL_ENABLE = 8'h01; // OR to enable dual on next txn

  //--------------------------------------------------------------------------
  // Command byte constants (dual SPI mode)
  //--------------------------------------------------------------------------
  localparam CMD_D_WR        = 8'h40; // dual write   cmd[7:6]=01
  localparam CMD_D_RD        = 8'h00; // dual read    cmd[7:6]=00
  localparam CMD_D_BURST_WR  = 8'h42; // dual burst write
  localparam CMD_D_BURST_RD  = 8'h02; // dual burst read
  localparam CMD_D_WG_WR     = 8'h60; // dual wavegen write  01,10
  localparam CMD_D_WG_RD     = 8'h20; // dual wavegen read   00,10
  localparam CMD_D_NIRS_WR   = 8'h70; // dual NIRS write     01,11
  localparam CMD_D_NIRS_RD   = 8'h30; // dual NIRS read      00,11
  localparam CMD_D_RDATA     = 8'h80; // dual RDATA          10,0x
  localparam CMD_D_RDATAC    = 8'hA0; // dual RDATAC         10,1x

  //--------------------------------------------------------------------------
  // DUT signals
  //--------------------------------------------------------------------------
  reg                   i_rst_n;
  reg                   sclk;      // raw SPI clock from master
  reg                   i_cs_n;
  reg                   i_mosi;
  reg                   i_mosi1;
  reg [DATA_WIDTH-1:0]  i_rd_data;
  reg [23:0]            imeas_chdata [EEG_CHN_NUM-1:0];
  reg [4:0]             i_channel_max;
  reg                   daisy_in;
  reg                   daisy_en;
  reg [1:0]             mode;
  reg                   cpha;
  reg [39:0]            i_status_words;

  wire                  i_sclk_neg;  // = sclk  (DUT state machine clocked here)
  wire                  i_sclk;      // = ~sclk (DUT MISO output reg clocked here)

  wire                  o_dual_en;
  wire                  o_dual_wr;
  wire [ADDR_WIDTH-1:0] o_addr;
  wire                  o_wr;
  wire                  o_rd;
  wire                  wavegen_cmd_reg;
  wire                  o_wavegen_wr;
  wire                  o_wavegen_rd;
  wire                  nirs_cmd_reg;
  wire                  o_nirs_wr;
  wire                  o_nirs_rd;
  wire [DATA_WIDTH-1:0] o_wr_data;
  wire                  o_miso;
  wire                  o_miso1;
  wire                  o_imeas_intr_clr;

  // CPOL=0, CPHA=0
  assign i_sclk_neg = sclk;
  assign i_sclk     = ~sclk;

  //--------------------------------------------------------------------------
  // DUT instantiation
  //--------------------------------------------------------------------------
  spi_slave_controller #(
    .EEG_CHN_NUM (EEG_CHN_NUM),
    .DATA_WIDTH  (DATA_WIDTH),
    .ADDR_WIDTH  (ADDR_WIDTH)
  ) dut (
    .i_rst_n         (i_rst_n),
    .i_sclk          (i_sclk),
    .i_sclk_neg      (i_sclk_neg),
    .o_dual_en       (o_dual_en),
    .o_dual_wr       (o_dual_wr),
    .i_cs_n          (i_cs_n),
    .i_channel_max   (i_channel_max),
    .i_mosi          (i_mosi),
    .i_mosi1         (i_mosi1),
    .i_status_words  (i_status_words),
    .cpha            (cpha),
    .daisy_en        (daisy_en),
    .daisy_in        (daisy_in),
    .o_addr          (o_addr),
    .o_wr            (o_wr),
    .o_rd            (o_rd),
    .wavegen_cmd_reg (wavegen_cmd_reg),
    .o_wavegen_wr    (o_wavegen_wr),
    .o_wavegen_rd    (o_wavegen_rd),
    .nirs_cmd_reg    (nirs_cmd_reg),
    .o_nirs_wr       (o_nirs_wr),
    .o_nirs_rd       (o_nirs_rd),
    .o_wr_data       (o_wr_data),
    .i_rd_data       (i_rd_data),
    .o_miso          (o_miso),
    .o_miso1         (o_miso1),
    .o_imeas_intr_clr(o_imeas_intr_clr),
    .mode            (mode),
    .imeas_chdata    (imeas_chdata)
  );

  //--------------------------------------------------------------------------
  // Test tracking
  //--------------------------------------------------------------------------
  integer test_num;
  integer pass_cnt;
  integer fail_cnt;

  task pass_test;
    input [255:0] name;
    begin
      $display("[PASS] Test %0d: %s", test_num, name);
      pass_cnt = pass_cnt + 1;
      test_num = test_num + 1;
    end
  endtask

  task fail_test;
    input [255:0] name;
    input [7:0]   got;
    input [7:0]   exp;
    begin
      $display("[FAIL] Test %0d: %s  got=0x%02h  exp=0x%02h",
               test_num, name, got, exp);
      fail_cnt = fail_cnt + 1;
      test_num = test_num + 1;
    end
  endtask

  //--------------------------------------------------------------------------
  // Shared data buffers (avoids unpacked array task ports, unsupported by
  // iverilog 12 when passed by reference)
  //--------------------------------------------------------------------------
  // Incoming byte(s) written by master tasks, read by test code
  reg [7:0] xfr_rd_byte;           // last received MISO byte (single_read etc.)
  reg [7:0] xfr_rd_buf  [0:63];    // burst / RDATA received bytes
  // Outgoing byte(s) provided by test code, consumed by master tasks
  reg [7:0] xfr_wr_buf  [0:7];     // burst write data (set before calling task)
  integer   xfr_len;               // number of bytes for burst tasks (set before call)

  //--------------------------------------------------------------------------
  // Captured DUT output state
  //--------------------------------------------------------------------------
  reg [ADDR_WIDTH-1:0] cap_addr;
  reg [DATA_WIDTH-1:0] cap_wr_data;
  reg                  cap_wr;
  reg                  cap_rd;
  reg                  cap_wavegen_wr;
  reg                  cap_wavegen_rd;
  reg                  cap_nirs_wr;
  reg                  cap_nirs_rd;

  always @(posedge o_wr) begin
    cap_addr    <= o_addr;
    cap_wr_data <= o_wr_data;
    cap_wr      <= 1;
  end
  always @(negedge o_wr)       cap_wr      <= 0;
  always @(posedge o_rd) begin
    cap_addr    <= o_addr;
    cap_rd      <= 1;
  end
  always @(negedge o_rd)       cap_rd      <= 0;
  always @(posedge o_wavegen_wr) begin
    cap_addr    <= o_addr;
    cap_wr_data <= o_wr_data;
    cap_wavegen_wr <= 1;
  end
  always @(negedge o_wavegen_wr) cap_wavegen_wr <= 0;
  always @(posedge o_wavegen_rd) begin
    cap_addr    <= o_addr;
    cap_wavegen_rd <= 1;
  end
  always @(negedge o_wavegen_rd) cap_wavegen_rd <= 0;
  always @(posedge o_nirs_wr) begin
    cap_addr    <= o_addr;
    cap_wr_data <= o_wr_data;
    cap_nirs_wr <= 1;
  end
  always @(negedge o_nirs_wr) cap_nirs_wr <= 0;
  always @(posedge o_nirs_rd) begin
    cap_addr    <= o_addr;
    cap_nirs_rd <= 1;
  end
  always @(negedge o_nirs_rd) cap_nirs_rd <= 0;

  //--------------------------------------------------------------------------
  // SPI master low-level helpers
  //--------------------------------------------------------------------------

  // Send one byte MSB-first in single mode
  task single_send_byte;
    input [7:0] data;
    integer b;
    begin
      for (b = 7; b >= 0; b = b - 1) begin
        @(negedge sclk);
        i_mosi = data[b];
        @(posedge sclk); // DUT samples on posedge of i_sclk_neg
      end
    end
  endtask

  // Receive one byte MSB-first from MISO in single mode
  task single_recv_byte;
    integer b;
    begin
      for (b = 7; b >= 0; b = b - 1) begin
        @(posedge sclk);
        xfr_rd_byte[b] = o_miso;
      end
    end
  endtask

  // Send one byte MSB-first in dual mode (MOSI1=MSB bit, MOSI=LSB bit per pair)
  task dual_send_byte;
    input [7:0] data;
    integer p;
    begin
      for (p = 3; p >= 0; p = p - 1) begin
        @(negedge sclk);
        i_mosi1 = data[2*p+1];
        i_mosi  = data[2*p];
        @(posedge sclk);
      end
    end
  endtask

  // Receive one byte from dual MISO (o_miso1=odd bit, o_miso=even bit) over 4 clocks
  task dual_recv_byte;
    integer p;
    begin
      for (p = 3; p >= 0; p = p - 1) begin
        @(posedge sclk);
        xfr_rd_byte[2*p+1] = o_miso1; // odd bit of pair
        xfr_rd_byte[2*p]   = o_miso;  // even bit of pair
      end
    end
  endtask

  // Assert CS# and drive addr MSB on MOSI simultaneously (single mode)
  // This prevents a dead Z clock on the first bit that would corrupt rx_buf.
  task single_start_txn;
    input [7:0] addr;
    integer b;
    begin
      @(negedge sclk);
      i_cs_n = 0;
      i_mosi = addr[7]; // drive MSB at CS# assertion — no dead clock
      @(posedge sclk);
      for (b = 6; b >= 0; b = b - 1) begin
        @(negedge sclk); i_mosi = addr[b];
        @(posedge sclk);
      end
    end
  endtask

  // Assert CS# and drive addr MSB pair on {MOSI1, MOSI} simultaneously (dual mode)
  task dual_start_txn;
    input [7:0] addr;
    integer p;
    begin
      @(negedge sclk);
      i_cs_n  = 0;
      i_mosi1 = addr[7]; // drive MSB pair at CS# assertion
      i_mosi  = addr[6];
      @(posedge sclk);
      for (p = 2; p >= 0; p = p - 1) begin
        @(negedge sclk);
        i_mosi1 = addr[2*p+1];
        i_mosi  = addr[2*p];
        @(posedge sclk);
      end
    end
  endtask

  //--------------------------------------------------------------------------
  // SINGLE-MODE transactions
  // All use shared xfr_* buffers – no array ports.
  //--------------------------------------------------------------------------

  // single_write: addr(8) + CMD_S_WR(8) + data(8) + pad(8)
  task single_write;
    input [7:0] addr;
    input [7:0] data;
    begin
      single_start_txn(addr);
      single_send_byte(CMD_S_WR);
      single_send_byte(data);
      single_send_byte(8'h00); // pad so last data byte shifts fully into DUT
      @(negedge sclk); i_cs_n = 1; i_mosi = 1'bz;
      repeat(4) @(posedge sclk);
    end
  endtask

  // single_read: writes addr(8) + CMD_S_RD(8), then reads one byte from MISO
  // Result in xfr_rd_byte
  task single_read;
    input [7:0] addr;
    begin
      single_start_txn(addr);
      single_send_byte(CMD_S_RD);
      single_recv_byte();
      @(negedge sclk); i_cs_n = 1; i_mosi = 1'bz;
      repeat(4) @(posedge sclk);
    end
  endtask

  // single_burst_write: xfr_len bytes from xfr_wr_buf[], auto-incrementing addr
  task single_burst_write;
    input [7:0] addr;
    integer j;
    begin
      single_start_txn(addr);
      single_send_byte(CMD_S_BURST_WR);
      for (j = 0; j < xfr_len; j = j + 1)
        single_send_byte(xfr_wr_buf[j]);
      single_send_byte(8'h00); // pad
      @(negedge sclk); i_cs_n = 1; i_mosi = 1'bz;
      repeat(4) @(posedge sclk);
    end
  endtask

  // single_burst_read: reads xfr_len bytes into xfr_rd_buf[]
  task single_burst_read;
    input [7:0] addr;
    integer j;
    begin
      single_start_txn(addr);
      single_send_byte(CMD_S_BURST_RD);
      for (j = 0; j < xfr_len; j = j + 1) begin
        single_recv_byte();
        xfr_rd_buf[j] = xfr_rd_byte;
      end
      @(negedge sclk); i_cs_n = 1; i_mosi = 1'bz;
      repeat(4) @(posedge sclk);
    end
  endtask

  // single_wavegen_write
  task single_wavegen_write;
    input [7:0] addr;
    input [7:0] data;
    begin
      single_start_txn(addr);
      single_send_byte(CMD_S_WG_WR);
      single_send_byte(data);
      single_send_byte(8'h00);
      @(negedge sclk); i_cs_n = 1; i_mosi = 1'bz;
      repeat(4) @(posedge sclk);
    end
  endtask

  // single_wavegen_read; result in xfr_rd_byte
  task single_wavegen_read;
    input [7:0] addr;
    begin
      single_start_txn(addr);
      single_send_byte(CMD_S_WG_RD);
      single_recv_byte();
      @(negedge sclk); i_cs_n = 1; i_mosi = 1'bz;
      repeat(4) @(posedge sclk);
    end
  endtask

  // single_nirs_write
  task single_nirs_write;
    input [7:0] addr;
    input [7:0] data;
    begin
      single_start_txn(addr);
      single_send_byte(CMD_S_NIRS_WR);
      single_send_byte(data);
      single_send_byte(8'h00);
      @(negedge sclk); i_cs_n = 1; i_mosi = 1'bz;
      repeat(4) @(posedge sclk);
    end
  endtask

  // single_nirs_read; result in xfr_rd_byte
  task single_nirs_read;
    input [7:0] addr;
    begin
      single_start_txn(addr);
      single_send_byte(CMD_S_NIRS_RD);
      single_recv_byte();
      @(negedge sclk); i_cs_n = 1; i_mosi = 1'bz;
      repeat(4) @(posedge sclk);
    end
  endtask

  // single_rdata: reads xfr_len*3 bytes into xfr_rd_buf[]
  task single_rdata;
    integer j, total;
    begin
      total = xfr_len * 3;
      single_start_txn(8'h00);
      single_send_byte(CMD_S_RDATA);
      for (j = 0; j < total; j = j + 1) begin
        single_recv_byte();
        xfr_rd_buf[j] = xfr_rd_byte;
      end
      @(negedge sclk); i_cs_n = 1; i_mosi = 1'bz;
      repeat(4) @(posedge sclk);
    end
  endtask

  // single_rdatac: same packet format as rdata
  task single_rdatac;
    integer j, total;
    begin
      total = xfr_len * 3;
      single_start_txn(8'h00);
      single_send_byte(CMD_S_RDATAC);
      for (j = 0; j < total; j = j + 1) begin
        single_recv_byte();
        xfr_rd_buf[j] = xfr_rd_byte;
      end
      @(negedge sclk); i_cs_n = 1; i_mosi = 1'bz;
      repeat(4) @(posedge sclk);
    end
  endtask

  //--------------------------------------------------------------------------
  // Enable dual SPI mode: send a write with cmd[0]=1; dual_en activates on the
  // next CS assertion.
  //--------------------------------------------------------------------------
  task enable_dual_mode;
    begin
      single_start_txn(8'hFF);
      single_send_byte(CMD_S_WR | CMD_DUAL_ENABLE);
      single_send_byte(8'h00);
      single_send_byte(8'h00);
      @(negedge sclk); i_cs_n = 1; i_mosi = 1'bz; i_mosi1 = 1'bz;
      repeat(8) @(posedge sclk);
    end
  endtask

  //--------------------------------------------------------------------------
  // DUAL-MODE transactions
  //--------------------------------------------------------------------------

  // dual_write
  task dual_write;
    input [7:0] addr;
    input [7:0] data;
    begin
      dual_start_txn(addr);
      dual_send_byte(CMD_D_WR);
      dual_send_byte(data);
      dual_send_byte(8'h00);
      @(negedge sclk); i_cs_n = 1; i_mosi = 1'bz; i_mosi1 = 1'bz;
      repeat(4) @(posedge sclk);
    end
  endtask

  // dual_read; result in xfr_rd_byte
  task dual_read;
    input [7:0] addr;
    begin
      dual_start_txn(addr);
      dual_send_byte(CMD_D_RD);
      @(posedge sclk); // wait for first data bit to be driven on MISO
      dual_recv_byte();
      @(negedge sclk); i_cs_n = 1; i_mosi = 1'bz; i_mosi1 = 1'bz;
      repeat(4) @(posedge sclk);
    end
  endtask

  // dual_burst_write: xfr_len bytes from xfr_wr_buf[]
  task dual_burst_write;
    input [7:0] addr;
    integer j;
    begin
      dual_start_txn(addr);
      dual_send_byte(CMD_D_BURST_WR);
      for (j = 0; j < xfr_len; j = j + 1)
        dual_send_byte(xfr_wr_buf[j]);
      dual_send_byte(8'h00);
      @(negedge sclk); i_cs_n = 1; i_mosi = 1'bz; i_mosi1 = 1'bz;
      repeat(4) @(posedge sclk);
    end
  endtask

  // dual_burst_read: reads xfr_len bytes into xfr_rd_buf[]
  task dual_burst_read;
    input [7:0] addr;
    integer j;
    begin
      dual_start_txn(addr);
      dual_send_byte(CMD_D_BURST_RD);
      @(posedge sclk); // wait for first data bit to be driven on MISO
      for (j = 0; j < xfr_len; j = j + 1) begin
        dual_recv_byte();
        xfr_rd_buf[j] = xfr_rd_byte;
      end
      @(negedge sclk); i_cs_n = 1; i_mosi = 1'bz; i_mosi1 = 1'bz;
      repeat(4) @(posedge sclk);
    end
  endtask

  // dual_wavegen_write
  task dual_wavegen_write;
    input [7:0] addr;
    input [7:0] data;
    begin
      dual_start_txn(addr);
      dual_send_byte(CMD_D_WG_WR);
      dual_send_byte(data);
      dual_send_byte(8'h00);
      @(negedge sclk); i_cs_n = 1; i_mosi = 1'bz; i_mosi1 = 1'bz;
      repeat(4) @(posedge sclk);
    end
  endtask

  // dual_wavegen_read; result in xfr_rd_byte
  task dual_wavegen_read;
    input [7:0] addr;
    begin
      dual_start_txn(addr);
      dual_send_byte(CMD_D_WG_RD);
      @(posedge sclk); // wait for first data bit to be driven on MISO
      dual_recv_byte();
      @(negedge sclk); i_cs_n = 1; i_mosi = 1'bz; i_mosi1 = 1'bz;
      repeat(4) @(posedge sclk);
    end
  endtask

  // dual_nirs_write
  task dual_nirs_write;
    input [7:0] addr;
    input [7:0] data;
    begin
      dual_start_txn(addr);
      dual_send_byte(CMD_D_NIRS_WR);
      dual_send_byte(data);
      dual_send_byte(8'h00);
      @(negedge sclk); i_cs_n = 1; i_mosi = 1'bz; i_mosi1 = 1'bz;
      repeat(4) @(posedge sclk);
    end
  endtask

  // dual_nirs_read; result in xfr_rd_byte
  task dual_nirs_read;
    input [7:0] addr;
    begin
      dual_start_txn(addr);
      dual_send_byte(CMD_D_NIRS_RD);
      @(posedge sclk); // wait for first data bit to be driven on MISO
      dual_recv_byte();
      @(negedge sclk); i_cs_n = 1; i_mosi = 1'bz; i_mosi1 = 1'bz;
      repeat(4) @(posedge sclk);
    end
  endtask

  // dual_rdata: reads xfr_len*3 bytes into xfr_rd_buf[]
  task dual_rdata;
    integer j, total;
    begin
      total = xfr_len * 3;
      dual_start_txn(8'h00);
      dual_send_byte(CMD_D_RDATA);
      @(posedge sclk); // wait for first data bit to be driven on MISO
      for (j = 0; j < total; j = j + 1) begin
        dual_recv_byte();
        xfr_rd_buf[j] = xfr_rd_byte;
      end
      @(negedge sclk); i_cs_n = 1; i_mosi = 1'bz; i_mosi1 = 1'bz;
      repeat(4) @(posedge sclk);
    end
  endtask

  // dual_rdatac
  task dual_rdatac;
    integer j, total;
    begin
      total = xfr_len * 3;
      dual_start_txn(8'h00);
      dual_send_byte(CMD_D_RDATAC);
      @(posedge sclk); // wait for first data bit to be driven on MISO
      for (j = 0; j < total; j = j + 1) begin
        dual_recv_byte();
        xfr_rd_buf[j] = xfr_rd_byte;
      end
      @(negedge sclk); i_cs_n = 1; i_mosi = 1'bz; i_mosi1 = 1'bz;
      repeat(4) @(posedge sclk);
    end
  endtask

  //--------------------------------------------------------------------------
  // Clock generation
  //--------------------------------------------------------------------------
  initial sclk = 0;
  always #(SPI_CLK_HALF) sclk = ~sclk;

  //--------------------------------------------------------------------------
  // VCD dump
  //--------------------------------------------------------------------------
  initial begin
    $dumpfile("spi_reg_controller_tb.vcd");
    $dumpvars(0, spi_reg_controller_tb);
  end

  //--------------------------------------------------------------------------
  // Reset & default signal values
  //--------------------------------------------------------------------------
  integer idx;
  initial begin
    i_rst_n        = 1;
    i_cs_n         = 1;
    i_mosi         = 1'bz;
    i_mosi1        = 1'bz;
    i_rd_data      = 8'hA5;
    i_channel_max  = 5'd4;
    daisy_in       = 0;
    daisy_en       = 0;
    mode           = 2'b10;   // imeas mode: skip status bytes
    cpha           = 0;
    i_status_words = 40'hDEADBEEF01;
    cap_wr = 0; cap_rd = 0;
    cap_wavegen_wr = 0; cap_wavegen_rd = 0;
    cap_nirs_wr = 0; cap_nirs_rd = 0;

    for (idx = 0; idx < EEG_CHN_NUM; idx = idx + 1)
      imeas_chdata[idx] = {8'(8'h10 + idx), 8'(8'h20 + idx), 8'(8'h30 + idx)};

    #5; i_rst_n = 0;
    repeat(4) @(posedge sclk);
    i_rst_n = 1;
    repeat(4) @(posedge sclk);
  end

  //--------------------------------------------------------------------------
  // Main test program
  //--------------------------------------------------------------------------
  initial begin
    test_num = 0; pass_cnt = 0; fail_cnt = 0;
    xfr_len  = 0;
    xfr_rd_byte = 0;

    // Wait for reset de-assertion
    wait(i_rst_n === 1);
    repeat(8) @(posedge sclk);

    $display("==========================================================");
    $display("  SPI Reg Controller TB  (spi_reg_controller_test.sv)");
    $display("==========================================================");

    // ====================================================================
    // SECTION 1 – SINGLE SPI MODE
    // ====================================================================
    $display("\n=== SINGLE SPI MODE ===");

    // ------------------------------------------------------------------
    // TC01: Normal write
    // ------------------------------------------------------------------
    $display("\n[TC01] Normal write  addr=0x01  data=0xA5");
    single_write(8'h01, 8'hA5);
    repeat(2) @(posedge sclk);
    if (cap_addr === 8'h01 && cap_wr_data === 8'hA5)
      pass_test("TC01a: o_wr addr=0x01");
    else
      fail_test("TC01a: wrong addr", cap_addr, 8'h01);
    if (cap_wr_data === 8'hA5)
      pass_test("TC01b: o_wr data=0xA5");
    else
      fail_test("TC01b: wrong data", cap_wr_data, 8'hA5);

    // ------------------------------------------------------------------
    // TC02: Normal read
    // ------------------------------------------------------------------
    $display("\n[TC02] Normal read  addr=0x01  (i_rd_data=0xA5)");
    i_rd_data = 8'hA5;
    single_read(8'h01);
    repeat(2) @(posedge sclk);
    if (xfr_rd_byte === 8'hA5)
      pass_test("TC02a: MISO=0xA5");
    else
      fail_test("TC02a: MISO mismatch", xfr_rd_byte, 8'hA5);
    if (cap_addr === 8'h01)
      pass_test("TC02b: o_rd addr=0x01");
    else
      fail_test("TC02b: o_rd addr wrong", cap_addr, 8'h01);

    // ------------------------------------------------------------------
    // TC03: Write to several addresses (edge cases)
    // ------------------------------------------------------------------
    $display("\n[TC03] Write to addr=0x00 and 0xFF");
    single_write(8'h00, 8'h00);
    repeat(2) @(posedge sclk);
    if (cap_addr === 8'h00 && cap_wr_data === 8'h00)
      pass_test("TC03a: addr=0x00 data=0x00");
    else
      fail_test("TC03a: mismatch", cap_wr_data, 8'h00);

    single_write(8'hFF, 8'hFF);
    repeat(2) @(posedge sclk);
    if (cap_addr === 8'hFF && cap_wr_data === 8'hFF)
      pass_test("TC03b: addr=0xFF data=0xFF");
    else
      fail_test("TC03b: mismatch", cap_wr_data, 8'hFF);

    // ------------------------------------------------------------------
    // TC04: Burst write (address auto-increment)
    // ------------------------------------------------------------------
    $display("\n[TC04] Burst write  3 bytes from addr=0x10");
    xfr_wr_buf[0] = 8'hAA; xfr_wr_buf[1] = 8'hBB; xfr_wr_buf[2] = 8'hCC;
    xfr_len = 3;
    single_burst_write(8'h10);
    repeat(4) @(posedge sclk);
    // Last write strobe: addr should be 0x12, data 0xCC
    if (cap_addr === 8'h12)
      pass_test("TC04a: last addr=0x12 (auto-incremented)");
    else
      fail_test("TC04a: last addr wrong", cap_addr, 8'h12);
    if (cap_wr_data === 8'hCC)
      pass_test("TC04b: last data=0xCC");
    else
      fail_test("TC04b: last data wrong", cap_wr_data, 8'hCC);

    // ------------------------------------------------------------------
    // TC05: Burst read (address auto-increment)
    // ------------------------------------------------------------------
    $display("\n[TC05] Burst read  3 bytes from addr=0x10  (i_rd_data=0xDE)");
    i_rd_data = 8'hDE;
    xfr_len = 3;
    single_burst_read(8'h10);
    repeat(4) @(posedge sclk);
    if (xfr_rd_buf[0] === 8'hDE)
      pass_test("TC05a: byte[0]=0xDE");
    else
      fail_test("TC05a: byte[0] wrong", xfr_rd_buf[0], 8'hDE);
    if (xfr_rd_buf[1] === 8'hDE)
      pass_test("TC05b: byte[1]=0xDE");
    else
      fail_test("TC05b: byte[1] wrong", xfr_rd_buf[1], 8'hDE);
    if (xfr_rd_buf[2] === 8'hDE)
      pass_test("TC05c: byte[2]=0xDE");
    else
      fail_test("TC05c: byte[2] wrong", xfr_rd_buf[2], 8'hDE);

    // ------------------------------------------------------------------
    // TC06: Burst write with maximum burst (8 bytes)
    // ------------------------------------------------------------------
    $display("\n[TC06] Burst write  8 bytes from addr=0x40");
    xfr_wr_buf[0]=8'h01; xfr_wr_buf[1]=8'h02; xfr_wr_buf[2]=8'h03;
    xfr_wr_buf[3]=8'h04; xfr_wr_buf[4]=8'h05; xfr_wr_buf[5]=8'h06;
    xfr_wr_buf[6]=8'h07; xfr_wr_buf[7]=8'h08;
    xfr_len = 8;
    single_burst_write(8'h40);
    repeat(4) @(posedge sclk);
    if (cap_addr === 8'h47)
      pass_test("TC06a: last addr=0x47");
    else
      fail_test("TC06a: last addr wrong", cap_addr, 8'h47);
    if (cap_wr_data === 8'h08)
      pass_test("TC06b: last data=0x08");
    else
      fail_test("TC06b: last data wrong", cap_wr_data, 8'h08);

    // ------------------------------------------------------------------
    // TC07: Wavegen write
    // ------------------------------------------------------------------
    $display("\n[TC07] Wavegen write  addr=0x20  data=0x77");
    single_wavegen_write(8'h20, 8'h77);
    repeat(2) @(posedge sclk);
    if (cap_addr === 8'h20 && cap_wr_data === 8'h77)
      pass_test("TC07a: wavegen write addr/data correct");
    else
      fail_test("TC07a: wavegen write mismatch", cap_wr_data, 8'h77);
    if (cap_wr === 0)
      pass_test("TC07b: o_wr NOT asserted for wavegen write");
    else
      fail_test("TC07b: o_wr unexpectedly asserted", 8'(cap_wr), 8'h0);

    // ------------------------------------------------------------------
    // TC08: Wavegen read
    // ------------------------------------------------------------------
    $display("\n[TC08] Wavegen read  addr=0x20  (i_rd_data=0x77)");
    i_rd_data = 8'h77;
    single_wavegen_read(8'h20);
    repeat(2) @(posedge sclk);
    if (xfr_rd_byte === 8'h77)
      pass_test("TC08a: MISO=0x77");
    else
      fail_test("TC08a: MISO mismatch", xfr_rd_byte, 8'h77);
    if (cap_rd === 0)
      pass_test("TC08b: o_rd NOT asserted for wavegen read");
    else
      fail_test("TC08b: o_rd unexpectedly asserted", 8'(cap_rd), 8'h0);

    // ------------------------------------------------------------------
    // TC09: NIRS write
    // ------------------------------------------------------------------
    $display("\n[TC09] NIRS write  addr=0x30  data=0x3C");
    single_nirs_write(8'h30, 8'h3C);
    repeat(2) @(posedge sclk);
    if (cap_addr === 8'h30 && cap_wr_data === 8'h3C)
      pass_test("TC09a: NIRS write addr/data correct");
    else
      fail_test("TC09a: NIRS write mismatch", cap_wr_data, 8'h3C);
    if (cap_wr === 0)
      pass_test("TC09b: o_wr NOT asserted for NIRS write");
    else
      fail_test("TC09b: o_wr unexpectedly asserted", 8'(cap_wr), 8'h0);

    // ------------------------------------------------------------------
    // TC10: NIRS read
    // ------------------------------------------------------------------
    $display("\n[TC10] NIRS read  addr=0x30  (i_rd_data=0x3C)");
    i_rd_data = 8'h3C;
    single_nirs_read(8'h30);
    repeat(2) @(posedge sclk);
    if (xfr_rd_byte === 8'h3C)
      pass_test("TC10a: MISO=0x3C");
    else
      fail_test("TC10a: MISO mismatch", xfr_rd_byte, 8'h3C);
    if (cap_rd === 0)
      pass_test("TC10b: o_rd NOT asserted for NIRS read");
    else
      fail_test("TC10b: o_rd unexpectedly asserted", 8'(cap_rd), 8'h0);

    // ------------------------------------------------------------------
    // TC11: RDATA command  (mode=imeas, 2 channels)
    // ------------------------------------------------------------------
    $display("\n[TC11] RDATA command  2 channels  (mode=2'b10)");
    mode = 2'b10;
    i_channel_max = 5'd2;
    xfr_len = 2; // 2 channels -> 6 bytes
    single_rdata();
    repeat(4) @(posedge sclk);
    // imeas_chdata[0] = {0x10, 0x20, 0x30}
    if (xfr_rd_buf[0] === imeas_chdata[0][23:16])
      pass_test("TC11a: RDATA ch0 byte0");
    else
      fail_test("TC11a: RDATA ch0 byte0 wrong", xfr_rd_buf[0], imeas_chdata[0][23:16]);
    if (xfr_rd_buf[1] === imeas_chdata[0][15:8])
      pass_test("TC11b: RDATA ch0 byte1");
    else
      fail_test("TC11b: RDATA ch0 byte1 wrong", xfr_rd_buf[1], imeas_chdata[0][15:8]);
    if (xfr_rd_buf[2] === imeas_chdata[0][7:0])
      pass_test("TC11c: RDATA ch0 byte2");
    else
      fail_test("TC11c: RDATA ch0 byte2 wrong", xfr_rd_buf[2], imeas_chdata[0][7:0]);

    // ------------------------------------------------------------------
    // TC12: RDATAC command  (continuous, 2 channels)
    // ------------------------------------------------------------------
    $display("\n[TC12] RDATAC command  2 channels");
    xfr_len = 2;
    single_rdatac();
    repeat(4) @(posedge sclk);
    if (xfr_rd_buf[0] === imeas_chdata[0][23:16])
      pass_test("TC12a: RDATAC ch0 byte0");
    else
      fail_test("TC12a: RDATAC ch0 byte0 wrong", xfr_rd_buf[0], imeas_chdata[0][23:16]);
    if (xfr_rd_buf[3] === imeas_chdata[1][23:16])
      pass_test("TC12b: RDATAC ch1 byte0");
    else
      fail_test("TC12b: RDATAC ch1 byte0 wrong", xfr_rd_buf[3], imeas_chdata[1][23:16]);

    // ------------------------------------------------------------------
    // TC13: Back-to-back write then read
    // ------------------------------------------------------------------
    $display("\n[TC13] Back-to-back write/read");
    single_write(8'h07, 8'hF0);
    repeat(2) @(posedge sclk);
    i_rd_data = 8'hF0;
    single_read(8'h07);
    repeat(2) @(posedge sclk);
    if (xfr_rd_byte === 8'hF0)
      pass_test("TC13: back-to-back write then read MISO=0xF0");
    else
      fail_test("TC13: mismatch", xfr_rd_byte, 8'hF0);

    // ====================================================================
    // SECTION 2 – ENABLE DUAL SPI MODE
    // ====================================================================
    $display("\n=== ENABLING DUAL SPI MODE ===");
    enable_dual_mode();
    repeat(4) @(posedge sclk);
    if (o_dual_en === 1'b1)
      pass_test("TC14: o_dual_en asserted after dual-enable command");
    else
      fail_test("TC14: o_dual_en NOT asserted", 8'(o_dual_en), 8'h1);

    // ====================================================================
    // SECTION 3 – DUAL SPI MODE
    // ====================================================================
    $display("\n=== DUAL SPI MODE ===");

    // ------------------------------------------------------------------
    // TC15: Dual normal write
    // ------------------------------------------------------------------
    $display("\n[TC15] Dual write  addr=0x01  data=0xBE");
    dual_write(8'h01, 8'hBE);
    repeat(2) @(posedge sclk);
    if (cap_addr === 8'h01 && cap_wr_data === 8'hBE)
      pass_test("TC15a: dual write addr/data correct");
    else
      fail_test("TC15a: dual write mismatch", cap_wr_data, 8'hBE);

    // ------------------------------------------------------------------
    // TC16: Dual normal read
    // ------------------------------------------------------------------
    $display("\n[TC16] Dual read  addr=0x01  (i_rd_data=0xBE)");
    i_rd_data = 8'hBE;
    dual_read(8'h01);
    repeat(2) @(posedge sclk);
    if (xfr_rd_byte === 8'hBE)
      pass_test("TC16a: dual read MISO=0xBE");
    else
      fail_test("TC16a: dual read MISO mismatch", xfr_rd_byte, 8'hBE);

    // ------------------------------------------------------------------
    // TC17: Dual writes to edge-case addresses
    // ------------------------------------------------------------------
    $display("\n[TC17] Dual writes to addr=0x00 and 0xFF");
    dual_write(8'h00, 8'h5A);
    repeat(2) @(posedge sclk);
    if (cap_addr === 8'h00 && cap_wr_data === 8'h5A)
      pass_test("TC17a: addr=0x00 data=0x5A");
    else
      fail_test("TC17a: mismatch", cap_wr_data, 8'h5A);

    dual_write(8'hFF, 8'hA5);
    repeat(2) @(posedge sclk);
    if (cap_addr === 8'hFF && cap_wr_data === 8'hA5)
      pass_test("TC17b: addr=0xFF data=0xA5");
    else
      fail_test("TC17b: mismatch", cap_wr_data, 8'hA5);

    // ------------------------------------------------------------------
    // TC18: Dual burst write
    // ------------------------------------------------------------------
    $display("\n[TC18] Dual burst write  3 bytes from addr=0x20");
    xfr_wr_buf[0]=8'h11; xfr_wr_buf[1]=8'h22; xfr_wr_buf[2]=8'h33;
    xfr_len = 3;
    dual_burst_write(8'h20);
    repeat(4) @(posedge sclk);
    if (cap_addr === 8'h22)
      pass_test("TC18a: last addr=0x22");
    else
      fail_test("TC18a: last addr wrong", cap_addr, 8'h22);
    if (cap_wr_data === 8'h33)
      pass_test("TC18b: last data=0x33");
    else
      fail_test("TC18b: last data wrong", cap_wr_data, 8'h33);

    // ------------------------------------------------------------------
    // TC19: Dual burst read
    // ------------------------------------------------------------------
    $display("\n[TC19] Dual burst read  3 bytes from addr=0x20  (i_rd_data=0xCB)");
    i_rd_data = 8'hCB;
    xfr_len = 3;
    dual_burst_read(8'h20);
    repeat(4) @(posedge sclk);
    if (xfr_rd_buf[0] === 8'hCB)
      pass_test("TC19a: byte[0]=0xCB");
    else
      fail_test("TC19a: byte[0] wrong", xfr_rd_buf[0], 8'hCB);
    if (xfr_rd_buf[1] === 8'hCB)
      pass_test("TC19b: byte[1]=0xCB");
    else
      fail_test("TC19b: byte[1] wrong", xfr_rd_buf[1], 8'hCB);
    if (xfr_rd_buf[2] === 8'hCB)
      pass_test("TC19c: byte[2]=0xCB");
    else
      fail_test("TC19c: byte[2] wrong", xfr_rd_buf[2], 8'hCB);

    // ------------------------------------------------------------------
    // TC20: Dual wavegen write
    // ------------------------------------------------------------------
    $display("\n[TC20] Dual wavegen write  addr=0x40  data=0x88");
    dual_wavegen_write(8'h40, 8'h88);
    repeat(2) @(posedge sclk);
    if (cap_addr === 8'h40 && cap_wr_data === 8'h88)
      pass_test("TC20a: dual wavegen write addr/data correct");
    else
      fail_test("TC20a: dual wavegen write mismatch", cap_wr_data, 8'h88);
    if (cap_wr === 0)
      pass_test("TC20b: o_wr NOT asserted for dual wavegen write");
    else
      fail_test("TC20b: o_wr unexpectedly asserted", 8'(cap_wr), 8'h0);

    // ------------------------------------------------------------------
    // TC21: Dual wavegen read
    // ------------------------------------------------------------------
    $display("\n[TC21] Dual wavegen read  addr=0x40  (i_rd_data=0x88)");
    i_rd_data = 8'h88;
    dual_wavegen_read(8'h40);
    repeat(2) @(posedge sclk);
    if (xfr_rd_byte === 8'h88)
      pass_test("TC21a: dual wavegen read MISO=0x88");
    else
      fail_test("TC21a: dual wavegen read MISO mismatch", xfr_rd_byte, 8'h88);
    if (cap_rd === 0)
      pass_test("TC21b: o_rd NOT asserted for dual wavegen read");
    else
      fail_test("TC21b: o_rd unexpectedly asserted", 8'(cap_rd), 8'h0);

    // ------------------------------------------------------------------
    // TC22: Dual NIRS write
    // ------------------------------------------------------------------
    $display("\n[TC22] Dual NIRS write  addr=0x50  data=0xCC");
    dual_nirs_write(8'h50, 8'hCC);
    repeat(2) @(posedge sclk);
    if (cap_addr === 8'h50 && cap_wr_data === 8'hCC)
      pass_test("TC22a: dual NIRS write addr/data correct");
    else
      fail_test("TC22a: dual NIRS write mismatch", cap_wr_data, 8'hCC);
    if (cap_wr === 0)
      pass_test("TC22b: o_wr NOT asserted for dual NIRS write");
    else
      fail_test("TC22b: o_wr unexpectedly asserted", 8'(cap_wr), 8'h0);

    // ------------------------------------------------------------------
    // TC23: Dual NIRS read
    // ------------------------------------------------------------------
    $display("\n[TC23] Dual NIRS read  addr=0x50  (i_rd_data=0xCC)");
    i_rd_data = 8'hCC;
    dual_nirs_read(8'h50);
    repeat(2) @(posedge sclk);
    if (xfr_rd_byte === 8'hCC)
      pass_test("TC23a: dual NIRS read MISO=0xCC");
    else
      fail_test("TC23a: dual NIRS read MISO mismatch", xfr_rd_byte, 8'hCC);
    if (cap_rd === 0)
      pass_test("TC23b: o_rd NOT asserted for dual NIRS read");
    else
      fail_test("TC23b: o_rd unexpectedly asserted", 8'(cap_rd), 8'h0);

    // ------------------------------------------------------------------
    // TC24: Dual RDATA command  (2 channels)
    // ------------------------------------------------------------------
    $display("\n[TC24] Dual RDATA  2 channels  (mode=2'b10)");
    mode = 2'b10;
    i_channel_max = 5'd2;
    xfr_len = 2;
    dual_rdata();
    repeat(4) @(posedge sclk);
    if (xfr_rd_buf[0] === imeas_chdata[0][23:16])
      pass_test("TC24a: dual RDATA ch0 byte0");
    else
      fail_test("TC24a: dual RDATA ch0 byte0 wrong", xfr_rd_buf[0], imeas_chdata[0][23:16]);
    if (xfr_rd_buf[1] === imeas_chdata[0][15:8])
      pass_test("TC24b: dual RDATA ch0 byte1");
    else
      fail_test("TC24b: dual RDATA ch0 byte1 wrong", xfr_rd_buf[1], imeas_chdata[0][15:8]);
    if (xfr_rd_buf[2] === imeas_chdata[0][7:0])
      pass_test("TC24c: dual RDATA ch0 byte2");
    else
      fail_test("TC24c: dual RDATA ch0 byte2 wrong", xfr_rd_buf[2], imeas_chdata[0][7:0]);

    // ------------------------------------------------------------------
    // TC25: Dual RDATAC command  (2 channels)
    // ------------------------------------------------------------------
    // NOTE: DUT limitation in dual RDATAC mode — rdata_cmd is de-asserted
    // once cmd_reg_5 is fully decoded (at bc=14), causing tx_buf to load
    // from i_rd_data instead of imeas_temp for all bytes after the first.
    // This means dual RDATAC does not correctly stream imeas_chdata for
    // channels beyond ch0 byte0. TC25b intentionally exposes this DUT bug.
    $display("\n[TC25] Dual RDATAC  2 channels");
    xfr_len = 2;
    dual_rdatac();
    repeat(4) @(posedge sclk);
    if (xfr_rd_buf[0] === imeas_chdata[0][23:16])
      pass_test("TC25a: dual RDATAC ch0 byte0");
    else
      fail_test("TC25a: dual RDATAC ch0 byte0 wrong", xfr_rd_buf[0], imeas_chdata[0][23:16]);
    // TC25b exposes DUT bug: dual RDATAC falls back to i_rd_data for ch1
    if (xfr_rd_buf[3] === imeas_chdata[1][23:16])
      pass_test("TC25b: dual RDATAC ch1 byte0");
    else
      fail_test("TC25b: dual RDATAC ch1 byte0 wrong", xfr_rd_buf[3], imeas_chdata[1][23:16]);

    // ------------------------------------------------------------------
    // TC26: Dual back-to-back write/read
    // ------------------------------------------------------------------
    $display("\n[TC26] Dual back-to-back write/read");
    dual_write(8'h0B, 8'hE7);
    repeat(2) @(posedge sclk);
    i_rd_data = 8'hE7;
    dual_read(8'h0B);
    repeat(2) @(posedge sclk);
    if (xfr_rd_byte === 8'hE7)
      pass_test("TC26: dual back-to-back MISO=0xE7");
    else
      fail_test("TC26: dual back-to-back mismatch", xfr_rd_byte, 8'hE7);

    // ------------------------------------------------------------------
    // TC27: Dual burst write (8 bytes)
    // ------------------------------------------------------------------
    $display("\n[TC27] Dual burst write  8 bytes from addr=0x60");
    xfr_wr_buf[0]=8'hA0; xfr_wr_buf[1]=8'hB1; xfr_wr_buf[2]=8'hC2;
    xfr_wr_buf[3]=8'hD3; xfr_wr_buf[4]=8'hE4; xfr_wr_buf[5]=8'hF5;
    xfr_wr_buf[6]=8'h06; xfr_wr_buf[7]=8'h17;
    xfr_len = 8;
    dual_burst_write(8'h60);
    repeat(4) @(posedge sclk);
    if (cap_addr === 8'h67)
      pass_test("TC27a: last addr=0x67");
    else
      fail_test("TC27a: last addr wrong", cap_addr, 8'h67);
    if (cap_wr_data === 8'h17)
      pass_test("TC27b: last data=0x17");
    else
      fail_test("TC27b: last data wrong", cap_wr_data, 8'h17);

    // ====================================================================
    // Summary
    // ====================================================================
    $display("\n==========================================================");
    $display("  Test Summary: %0d PASS, %0d FAIL  (total %0d)",
             pass_cnt, fail_cnt, test_num);
    $display("==========================================================\n");

    #(SPI_CLK_HALF * 20);
    $finish;
  end

  // Watchdog
  initial begin
    #10_000_000;
    $display("WATCHDOG: simulation timeout at %0t", $time);
    $finish;
  end

endmodule
