//------------------------------------------------------------------------------
// Self-checking testbench for the ENS2 SPI slave controller.
//
// Exercises the real spi_slave_controller RTL through the real
// spi_cpha_cpol_slct clock-mode logic and verifies the SPI features documented
// in the README:
//   * Single-mode register write / read
//   * Burst register write / read (auto address increment)
//   * Dual-mode (2-bit) register write / read
//   * Command decode for waveform-generator and NIRS instructions
//   * Operation across all four SPI modes (CPOL/CPHA 0..3)
//
// A behavioral register file is attached to the controller's register
// interface (o_addr/o_wr/o_wr_data/i_rd_data) so reads return what was written.
//------------------------------------------------------------------------------

`timescale 1ns/1ps

module tb_spi_slave_selfcheck;

  localparam int H = 25; // SCLK half period (ns) -> 50ns period = 20 MHz (datasheet max)

  // ---- mode / control ----
  logic        cpol, cpha;     // current SPI mode
  logic  [1:0] dut_mode;       // controller "mode" input (status/imeas select)

  // ---- raw master pins ----
  logic        i_rst_n;
  logic        sck;            // raw external SCLK (idle level = cpol)
  logic        csn;            // chip select (active low)
  logic        mosi;           // single / dual low-bit
  logic        mosi1;          // dual high-bit

  // ---- derived clocks from cpha/cpol select block ----
  wire         sclk_latch_in;  // -> controller i_sclk_neg (sample edge)
  wire         sclk_latch_out; // -> controller i_sclk      (shift edge)

  // ---- controller register interface ----
  wire  [7:0]  o_addr;
  wire         o_wr, o_rd;
  wire  [7:0]  o_wr_data;
  logic [7:0]  i_rd_data;

  wire         wavegen_cmd_reg, o_wavegen_wr, o_wavegen_rd;
  wire         nirs_cmd_reg,    o_nirs_wr,    o_nirs_rd;

  wire         o_miso, o_miso1;
  wire         o_dual_en, o_dual_wr;
  wire         o_imeas_intr_clr;

  // ---- tie-offs for imeas/daisy features (not under test here) ----
  wire  [23:0] imeas_chdata [15:0];
  logic [39:0] i_status_words;
  logic [4:0]  i_channel_max;
  logic        daisy_in, daisy_en, imeas_16bit_sel;

  genvar gi;
  generate
    for (gi = 0; gi < 16; gi = gi + 1) begin : g_imeas
      assign imeas_chdata[gi] = 24'h0;
    end
  endgenerate

  // ---- scoreboard ----
  integer errors = 0;
  integer checks = 0;

  // ===========================================================================
  // Clock-mode select (real RTL) + DUT (real RTL)
  // ===========================================================================
  spi_cpha_cpol_slct u_clk_sel (
    .iopad_cpha       (cpha),
    .iopad_cpol       (cpol),
    .i_sclk           (sck),
    .o_sclk_latch_in  (sclk_latch_in),
    .o_sclk_latch_out (sclk_latch_out)
  );

  spi_slave_controller #(
    .EEG_CHN_NUM (16),
    .DATA_WIDTH  (8),
    .ADDR_WIDTH  (8)
  ) dut (
    .i_rst_n          (i_rst_n),
    .i_sclk           (sclk_latch_out),
    .i_sclk_neg       (sclk_latch_in),
    .o_dual_en        (o_dual_en),
    .o_dual_wr        (o_dual_wr),
    .i_cs_n           (csn),
    .i_channel_max    (i_channel_max),
    .i_mosi           (mosi),
    .i_mosi1          (mosi1),
    .i_status_words   (i_status_words),
    .cpha             (cpha),
    .daisy_en         (daisy_en),
    .daisy_in         (daisy_in),
    .o_addr           (o_addr),
    .o_wr             (o_wr),
    .o_rd             (o_rd),
    .wavegen_cmd_reg  (wavegen_cmd_reg),
    .o_wavegen_wr     (o_wavegen_wr),
    .o_wavegen_rd     (o_wavegen_rd),
    .nirs_cmd_reg     (nirs_cmd_reg),
    .o_nirs_wr        (o_nirs_wr),
    .o_nirs_rd        (o_nirs_rd),
    .o_wr_data        (o_wr_data),
    .i_rd_data        (i_rd_data),
    .o_miso           (o_miso),
    .o_miso1          (o_miso1),
    .o_imeas_intr_clr (o_imeas_intr_clr),
    .mode             (dut_mode),
    .imeas_16bit_sel  (imeas_16bit_sel),
    .imeas_chdata     (imeas_chdata)
  );

  // ===========================================================================
  // Behavioral register file on the controller's register port.
  // o_wr / o_addr / o_wr_data are all driven by posedge(i_sclk_neg) flops, so
  // sampling them together on posedge(i_sclk_neg) is self-consistent.
  // Reads are combinational so the controller can fetch before the data phase.
  // ===========================================================================
  logic [7:0] regfile [0:255];

  always @(posedge sclk_latch_in) begin
    if (o_wr)
      regfile[o_addr] <= o_wr_data;
  end

  always @(*) i_rd_data = regfile[o_addr];

  // ===========================================================================
  // Low-level SPI bit drivers (one SCLK period each).
  //   cpha==0 : master changes MOSI while clock idle, slave samples on leading
  //             edge, MISO is sampled by master just before the leading edge.
  //   cpha==1 : master changes MOSI on leading edge, slave samples on trailing
  //             edge, MISO is sampled by master just before the trailing edge.
  // ===========================================================================
  task automatic clk_single(input logic txb, output logic rxb);
    begin
      if (cpha == 1'b0) begin
        mosi = txb;
        #(H);
        rxb  = o_miso;
        sck  = ~cpol;     // leading edge
        #(H);
        sck  = cpol;      // trailing edge
      end else begin
        sck  = ~cpol;     // leading edge
        mosi = txb;
        #(H);
        rxb  = o_miso;
        sck  = cpol;      // trailing edge
        #(H);
      end
    end
  endtask

  task automatic clk_dual(input logic hi, input logic lo,
                          output logic rhi, output logic rlo);
    begin
      if (cpha == 1'b0) begin
        mosi1 = hi; mosi = lo;
        #(H);
        rhi = o_miso; rlo = o_miso1;
        sck = ~cpol;
        #(H);
        sck = cpol;
      end else begin
        sck = ~cpol;
        mosi1 = hi; mosi = lo;
        #(H);
        rhi = o_miso; rlo = o_miso1;
        sck = cpol;
        #(H);
      end
    end
  endtask

  // Send/receive one byte (MSB first) in single mode.
  task automatic byte_single(input logic [7:0] tx, output logic [7:0] rx);
    integer i; logic b;
    begin
      for (i = 7; i >= 0; i = i - 1) begin
        clk_single(tx[i], b);
        rx[i] = b;
      end
    end
  endtask

  // Send/receive one byte (MSB first) in dual mode: 4 clocks, 2 bits each.
  task automatic byte_dual(input logic [7:0] tx, output logic [7:0] rx);
    integer i; logic rh, rl;
    begin
      for (i = 3; i >= 0; i = i - 1) begin
        clk_dual(tx[2*i+1], tx[2*i], rh, rl);
        rx[2*i+1] = rh;
        rx[2*i]   = rl;
      end
    end
  endtask

  task automatic cs_start;
    begin
      sck  = cpol;
      mosi = 1'b0;
      mosi1= 1'b0;
      csn  = 1'b0;
      #(H);
    end
  endtask

  task automatic cs_stop;
    begin
      #(H);
      csn  = 1'b1;
      mosi = 1'b0;
      mosi1= 1'b0;
      sck  = cpol;
      #(4*H);
    end
  endtask

  // ===========================================================================
  // High level single-mode transactions
  // ===========================================================================
  task automatic single_write(input [7:0] addr, input [7:0] instr, input [7:0] data);
    logic [7:0] junk;
    begin
      cs_start;
      byte_single(addr,  junk);
      byte_single(instr, junk);
      byte_single(data,  junk);
      byte_single(8'h00, junk); // pad
      cs_stop;
    end
  endtask

  task automatic single_read(input [7:0] addr, input [7:0] instr, output [7:0] data);
    logic [7:0] junk;
    begin
      cs_start;
      byte_single(addr,  junk);
      byte_single(instr, junk);
      byte_single(8'h00, data); // pad byte: MISO returns register data
      cs_stop;
    end
  endtask

  task automatic burst_write(input [7:0] addr, input [7:0] instr, input int n);
    logic [7:0] junk; integer k;
    begin
      cs_start;
      byte_single(addr,  junk);
      byte_single(instr, junk);
      for (k = 0; k < n; k = k + 1)
        byte_single(wdat[k], junk);
      byte_single(8'h00, junk); // trailing pad
      cs_stop;
    end
  endtask

  task automatic burst_read(input [7:0] addr, input [7:0] instr, input int n);
    logic [7:0] junk, tmp; integer k;
    begin
      cs_start;
      byte_single(addr,  junk);
      byte_single(instr, junk);
      for (k = 0; k < n; k = k + 1) begin
        byte_single(8'h00, tmp);
        rdat[k] = tmp;
      end
      cs_stop;
    end
  endtask

  // ===========================================================================
  // High level dual-mode transactions
  // ===========================================================================
  task automatic dual_write(input [7:0] addr, input [7:0] instr, input [7:0] data);
    logic [7:0] junk;
    begin
      cs_start;
      byte_dual(addr,  junk);
      byte_dual(instr, junk);
      byte_dual(data,  junk);
      byte_dual(8'h00, junk); // pad
      cs_stop;
    end
  endtask

  task automatic dual_read(input [7:0] addr, input [7:0] instr, output [7:0] data);
    logic [7:0] junk;
    begin
      cs_start;
      byte_dual(addr,  junk);
      byte_dual(instr, junk);
      byte_dual(8'h00, junk);  // padding clocks where read happens (decode/turnaround)
      byte_dual(8'h00, data);  // data returned here
      cs_stop;
    end
  endtask

  task automatic dual_burst_write(input [7:0] addr, input [7:0] instr, input int n);
    logic [7:0] junk; integer k;
    begin
      cs_start;
      byte_dual(addr,  junk);
      byte_dual(instr, junk);
      for (k = 0; k < n; k = k + 1)
        byte_dual(wdat[k], junk);
      byte_dual(8'h00, junk); // trailing pad
      cs_stop;
    end
  endtask

  task automatic dual_burst_read(input [7:0] addr, input [7:0] instr, input int n);
    logic [7:0] junk, tmp; integer k;
    begin
      cs_start;
      byte_dual(addr,  junk);
      byte_dual(instr, junk);
      for (k = 0; k < n; k = k + 1) begin
        byte_dual(8'h00, tmp);
        rdat[k] = tmp;
      end
      cs_stop;
    end
  endtask

  // ===========================================================================
  // Checks
  // ===========================================================================
  task automatic check_byte(input string name, input [7:0] got, input [7:0] exp);
    begin
      checks = checks + 1;
      if (got !== exp) begin
        errors = errors + 1;
        $display("  [FAIL] %-40s got=0x%02h exp=0x%02h", name, got, exp);
      end else begin
        $display("  [PASS] %-40s val=0x%02h", name, got);
      end
    end
  endtask

  task automatic check_bit(input string name, input logic got, input logic exp);
    begin
      checks = checks + 1;
      if (got !== exp) begin
        errors = errors + 1;
        $display("  [FAIL] %-40s got=%0b exp=%0b", name, got, exp);
      end else begin
        $display("  [PASS] %-40s val=%0b", name, got);
      end
    end
  endtask

  // ---- instruction encodings (per README Table 52 + RTL decode) ----
  localparam [7:0] INS_WR_GEN_S = 8'b1000_0000; // write general, single
  localparam [7:0] INS_RD_GEN_S = 8'b0000_0000; // read  general, single
  localparam [7:0] INS_WR_GEN_B = 8'b1000_0010; // write general, burst (bit1)
  localparam [7:0] INS_RD_GEN_B = 8'b0000_0010; // read  general, burst
  localparam [7:0] INS_WR_GEN_D = 8'b1000_0001; // write general, single, DUAL_EN
  localparam [7:0] INS_WR_WG_S  = 8'b1110_0000; // write wavegen,  single (DATA_SEL=110)
  localparam [7:0] INS_RD_WG_S  = 8'b0110_0000; // read  wavegen,  single
  localparam [7:0] INS_WR_NIRS_S= 8'b1111_0000; // write nirs,     single (DATA_SEL=111)
  localparam [7:0] INS_RD_NIRS_S= 8'b0111_0000; // read  nirs,     single

  // Dual-mode decode differs (controller: cmd_reg_write = !instr[7] & !instr[6]).
  // General WRITE  : instr[7]=0, instr[6]=0  -> 0x00
  // General READ   : cmd_reg==0 & not rdata/wg/nirs -> instr[6]=1, instr[5]=0 -> 0x40
  localparam [7:0] INS_WR_GEN_DUAL = 8'b0000_0000;
  localparam [7:0] INS_RD_GEN_DUAL = 8'b0100_0000;

  // Monitor command-decode strobes during a transaction
  logic seen_wg_wr, seen_wg_rd, seen_nirs_wr, seen_nirs_rd;
  always @(posedge sclk_latch_in) begin
    if (o_wavegen_wr) seen_wg_wr   = 1'b1;
    if (o_wavegen_rd) seen_wg_rd   = 1'b1;
    if (o_nirs_wr)    seen_nirs_wr = 1'b1;
    if (o_nirs_rd)    seen_nirs_rd = 1'b1;
  end

  // ===========================================================================
  // Test sequences
  // ===========================================================================
  logic [7:0] rd;
  logic [7:0] wdat [0:7];
  logic [7:0] rdat [0:7];

  task automatic init_signals;
    begin
      i_rst_n        = 1'b0;
      csn            = 1'b1;
      sck            = cpol;
      mosi           = 1'b0;
      mosi1          = 1'b0;
      daisy_in       = 1'b0;
      daisy_en       = 1'b0;
      imeas_16bit_sel= 1'b0;
      i_channel_max  = 5'd1;
      i_status_words = 40'h0;
      dut_mode       = 2'b11; // disable status-word injection on read path
    end
  endtask

  task automatic do_reset;
    begin
      i_rst_n = 1'b0;
      #(4*H);
      i_rst_n = 1'b1;
      #(4*H);
    end
  endtask

  // ---------- Single + burst tests for a given SPI mode ----------
  task automatic run_single_mode_tests(input [1:0] m);
    begin
      cpol = m[1];
      cpha = m[0];
      init_signals;
      do_reset;
      $display("\n========== SPI MODE %0d (CPOL=%0b CPHA=%0b) : SINGLE / BURST ==========", m, cpol, cpha);

      // single write then read back
      single_write(8'h10, INS_WR_GEN_S, 8'hA5);
      single_read (8'h10, INS_RD_GEN_S, rd);
      check_byte($sformatf("mode%0d single wr/rd @0x10", m), rd, 8'hA5);

      single_write(8'h11, INS_WR_GEN_S, 8'h3C);
      single_read (8'h11, INS_RD_GEN_S, rd);
      check_byte($sformatf("mode%0d single wr/rd @0x11", m), rd, 8'h3C);

      single_write(8'h7E, INS_WR_GEN_S, 8'hFF);
      single_read (8'h7E, INS_RD_GEN_S, rd);
      check_byte($sformatf("mode%0d single wr/rd @0x7E", m), rd, 8'hFF);

      // burst write 4 regs then burst read back
      wdat[0]=8'h11; wdat[1]=8'h22; wdat[2]=8'h33; wdat[3]=8'h44;
      burst_write(8'h20, INS_WR_GEN_B, 4);
      check_byte($sformatf("mode%0d burst wr regfile[0x20]", m), regfile[8'h20], 8'h11);
      check_byte($sformatf("mode%0d burst wr regfile[0x21]", m), regfile[8'h21], 8'h22);
      check_byte($sformatf("mode%0d burst wr regfile[0x22]", m), regfile[8'h22], 8'h33);
      check_byte($sformatf("mode%0d burst wr regfile[0x23]", m), regfile[8'h23], 8'h44);

      burst_read(8'h20, INS_RD_GEN_B, 4);
      check_byte($sformatf("mode%0d burst rd[0]@0x20", m), rdat[0], 8'h11);
      check_byte($sformatf("mode%0d burst rd[1]@0x21", m), rdat[1], 8'h22);
      check_byte($sformatf("mode%0d burst rd[2]@0x22", m), rdat[2], 8'h33);
      check_byte($sformatf("mode%0d burst rd[3]@0x23", m), rdat[3], 8'h44);
    end
  endtask

  // ---------- command decode test ----------
  task automatic run_cmd_decode_tests(input [1:0] m);
    begin
      cpol = m[1];
      cpha = m[0];
      init_signals;
      do_reset;
      $display("\n========== SPI MODE %0d : COMMAND DECODE (WG / NIRS) ==========", m);

      seen_wg_wr=0; seen_wg_rd=0; seen_nirs_wr=0; seen_nirs_rd=0;

      single_write(8'h05, INS_WR_WG_S, 8'h5A);
      check_bit($sformatf("mode%0d wavegen write strobe", m), seen_wg_wr, 1'b1);
      // general-register write must NOT fire for a wavegen instruction
      check_bit($sformatf("mode%0d gen write quiet on WG instr", m),
                (regfile[8'h05]===8'h5A), 1'b0);

      single_read(8'h05, INS_RD_WG_S, rd);
      check_bit($sformatf("mode%0d wavegen read strobe", m), seen_wg_rd, 1'b1);

      single_write(8'h06, INS_WR_NIRS_S, 8'h77);
      check_bit($sformatf("mode%0d nirs write strobe", m), seen_nirs_wr, 1'b1);

      single_read(8'h06, INS_RD_NIRS_S, rd);
      check_bit($sformatf("mode%0d nirs read strobe", m), seen_nirs_rd, 1'b1);
    end
  endtask

  // ---------- dual-mode test ----------
  task automatic run_dual_mode_tests(input [1:0] m);
    begin
      cpol = m[1];
      cpha = m[0];
      init_signals;
      do_reset;
      $display("\n========== SPI MODE %0d : DUAL MODE ==========", m);

      // Seed some registers in single mode first.
      single_write(8'h30, INS_WR_GEN_S, 8'h00);
      single_write(8'h31, INS_WR_GEN_S, 8'h00);

      // Enter dual mode: a single-mode general write with DUAL_EN=1.
      check_bit($sformatf("mode%0d dual_en deasserted pre-entry", m), o_dual_en, 1'b0);
      single_write(8'h7F, INS_WR_GEN_D, 8'hC3);
      check_bit($sformatf("mode%0d dual_en asserted after entry", m), o_dual_en, 1'b1);
      check_byte($sformatf("mode%0d entry write also stored", m), regfile[8'h7F], 8'hC3);

      // Now operate in dual (2-bit) mode.
      dual_write(8'h30, INS_WR_GEN_DUAL, 8'h9E);
      check_byte($sformatf("mode%0d dual write regfile[0x30]", m), regfile[8'h30], 8'h9E);

      dual_write(8'h31, INS_WR_GEN_DUAL, 8'h6D);
      check_byte($sformatf("mode%0d dual write regfile[0x31]", m), regfile[8'h31], 8'h6D);

      dual_read(8'h30, INS_RD_GEN_DUAL, rd);
      check_byte($sformatf("mode%0d dual read @0x30", m), rd, 8'h9E);

      dual_read(8'h31, INS_RD_GEN_DUAL, rd);
      check_byte($sformatf("mode%0d dual read @0x31", m), rd, 8'h6D);

      // Dual-mode burst (auto address increment)
      wdat[0]=8'hDE; wdat[1]=8'hAD; wdat[2]=8'hBE; wdat[3]=8'hEF;
      dual_burst_write(8'h40, INS_WR_GEN_DUAL | 8'h02, 4);
      check_byte($sformatf("mode%0d dual burst wr [0x40]", m), regfile[8'h40], 8'hDE);
      check_byte($sformatf("mode%0d dual burst wr [0x41]", m), regfile[8'h41], 8'hAD);
      check_byte($sformatf("mode%0d dual burst wr [0x42]", m), regfile[8'h42], 8'hBE);
      check_byte($sformatf("mode%0d dual burst wr [0x43]", m), regfile[8'h43], 8'hEF);

      dual_burst_read(8'h40, INS_RD_GEN_DUAL | 8'h02, 4);
      check_byte($sformatf("mode%0d dual burst rd[0]@0x40", m), rdat[0], 8'hDE);
      check_byte($sformatf("mode%0d dual burst rd[1]@0x41", m), rdat[1], 8'hAD);
      check_byte($sformatf("mode%0d dual burst rd[2]@0x42", m), rdat[2], 8'hBE);
      check_byte($sformatf("mode%0d dual burst rd[3]@0x43", m), rdat[3], 8'hEF);

      // Reset returns the controller to single mode.
      do_reset;
      check_bit($sformatf("mode%0d dual_en cleared by reset", m), o_dual_en, 1'b0);
    end
  endtask

  // ===========================================================================
  // Main
  // ===========================================================================
  integer mi;
  initial begin
`ifdef DUMP_VCD
    $dumpfile("tb_spi_slave_selfcheck.vcd");
    $dumpvars(0, tb_spi_slave_selfcheck);
`endif

    $display("SIM START");
    for (int ri = 0; ri < 256; ri = ri + 1) regfile[ri] = 8'h00;
    cpol = 0; cpha = 0;
    init_signals;
    $display("SIM after init_signals");

    // All four SPI modes, single + burst
    for (mi = 0; mi < 4; mi = mi + 1)
      run_single_mode_tests(mi[1:0]);

    // Command decode (mode 0 is representative; decode is mode independent)
    run_cmd_decode_tests(2'b00);

    // Dual mode across all four SPI modes
    for (mi = 0; mi < 4; mi = mi + 1)
      run_dual_mode_tests(mi[1:0]);

    $display("\n==================== SUMMARY ====================");
    $display("  checks run : %0d", checks);
    $display("  errors     : %0d", errors);
    if (errors == 0)
      $display("  RESULT     : ALL TESTS PASSED");
    else
      $display("  RESULT     : FAILED (%0d mismatches)", errors);
    $display("=================================================\n");
    $finish;
  end

  // global watchdog
  initial begin
    #5_000_000;
    $display("ERROR: simulation watchdog timeout");
    $finish;
  end

endmodule
