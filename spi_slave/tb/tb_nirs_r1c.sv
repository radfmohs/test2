//------------------------------------------------------------------------------
// Focused unit testbench for the NIRS R1C "mid-poll" status race.
//
// It drives spi_reg_nirs directly (the module that owns the status-clear logic)
// together with a small behavioural NIRS status core that mimics nirs_ppg_int:
//   - a per-channel sticky status bit (NIRS_INT) that is SET by an event and
//     CLEARED by the NIRS_INT_CLR pulse coming back from the register block.
//
// The testbench models the SPI controller's behaviour by sampling o_rd_data at
// the moment the read byte is latched (snapshot -> i_int_allowed) and pulsing
// i_rd later (the read strobe). This reproduces the window in which a status
// can be set after the byte the MCU receives is already frozen.
//
// It checks BOTH:
//   * the new (fixed) behaviour via the real NIRS_INT_CLR output, and
//   * what the legacy logic (clear gated only on the live, synced status) would
//     have done, to prove the race was real.
//------------------------------------------------------------------------------
`timescale 1ns/1ps

module tb_nirs_r1c;

  localparam ADDR_WIDTH    = 8;
  localparam DATA_WIDTH    = 8;
  localparam NO_OF_CHANNEL = 8;

  localparam [7:0] NIRS_INT_STATUS = 8'h20;
  localparam [7:0] NIRS_DOUT0_0    = 8'h21; // channel 0 final DOUT, bit[7] = status

  reg                   i_clk;
  reg                   i_rst_n;
  reg  [ADDR_WIDTH-1:0] i_addr;
  reg                   i_wr;
  reg                   i_rd;
  reg  [DATA_WIDTH-1:0] i_wr_data;
  reg                   int_clear_type;       // 0:W1C  1:R1C
  reg  [DATA_WIDTH-1:0] i_int_allowed;        // snapshot of byte shipped to MCU
  wire [DATA_WIDTH-1:0] o_rd_data;

  // Behavioural NIRS status core
  reg  [NO_OF_CHANNEL-1:0] status_set_evt;
  reg  [NO_OF_CHANNEL-1:0] status_model;

  integer errors = 0;

  spi_nirs_if #(.NO_OF_NIRS(NO_OF_CHANNEL)) nirs_if();

  // Drive the "nirs core" side of the interface.
  assign nirs_if.NIRS_INT = status_model;

  genvar gi, gj;
  generate
    for (gi = 0; gi < NO_OF_CHANNEL; gi = gi + 1) begin : g_drv
      // bit[7] of DOUTx_0 mirrors the per-channel status (per the manual)
      assign nirs_if.NIRS_DOUT[gi][0] = {status_model[gi], 7'h00};
      assign nirs_if.NIRS_DOUT[gi][1] = 8'h00;
      assign nirs_if.NIRS_DOUT[gi][2] = 8'h00;
      assign nirs_if.NIRS_DOUT[gi][3] = 8'h00;
      for (gj = 0; gj < 5; gj = gj + 1) begin : g_dbg
        assign nirs_if.NIRS_DEBUG[gi][gj] = 8'h00;
      end
    end
  endgenerate

  // 100 MHz reg-domain clock
  always #5 i_clk = ~i_clk;

  // Status core: SET on event, CLEAR on the NIRS_INT_CLR pulse from the DUT.
  integer k;
  always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      status_model <= '0;
    end else begin
      for (k = 0; k < NO_OF_CHANNEL; k = k + 1) begin
        if (nirs_if.NIRS_INT_CLR[k])
          status_model[k] <= 1'b0;
        else if (status_set_evt[k])
          status_model[k] <= 1'b1;
      end
    end
  end

  // TB-side replica of the DUT's 2-FF status synchroniser, used only to compute
  // what the LEGACY clear logic (live synced status) would have decided.
  reg [NO_OF_CHANNEL-1:0] sync_d1, sync_d2;
  always @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
      sync_d1 <= '0;
      sync_d2 <= '0;
    end else begin
      sync_d1 <= status_model;
      sync_d2 <= sync_d1;
    end
  end
  wire [NO_OF_CHANNEL-1:0] tb_sync = sync_d2;

  spi_reg_nirs #(
    .ADDR_WIDTH    (ADDR_WIDTH),
    .DATA_WIDTH    (DATA_WIDTH),
    .NO_OF_CHANNEL (NO_OF_CHANNEL)
  ) dut (
    .i_clk               (i_clk),
    .i_rst_n             (i_rst_n),
    .i_addr              (i_addr),
    .i_wr                (i_wr),
    .i_rd                (i_rd),
    .i_wr_data           (i_wr_data),
    .o_rd_data           (o_rd_data),
    .atm_adj_mode        (3'b0),
    .atm_adj             (1'b0),
    .atm_adj_data        (8'h0),
    .ppg_dis             (),
    .ppg_clk_div         (),
    .ana_ppgclk_inv      (),
    .ppg_clk50duty       (),
    .ppg_rst_reg         (),
    .ppg_clk_gate_bypass (),
    .int_clear_type      (int_clear_type),
    .i_int_allowed       (i_int_allowed),
    .spi_nirs_if         (nirs_if)
  );

  // Observe a clear pulse on a given channel across one read strobe.
  task automatic do_read_strobe(input [ADDR_WIDTH-1:0] addr);
    begin
      @(negedge i_clk);
      i_addr <= addr;
      i_rd   <= 1'b1;
      @(negedge i_clk);
      i_rd   <= 1'b0;
      i_addr <= 8'h00;
    end
  endtask

  // Snapshot what the MCU receives (controller latches o_rd_data into tx_buf).
  task automatic snapshot(input [ADDR_WIDTH-1:0] addr);
    begin
      @(negedge i_clk);
      i_addr        <= addr;
      #1 i_int_allowed = o_rd_data; // capture the delivered byte
    end
  endtask

  task automatic check(input cond, input string name);
    begin
      if (cond) $display("  [PASS] %0s", name);
      else begin
        $display("  [FAIL] %0s", name);
        errors = errors + 1;
      end
    end
  endtask

  reg legacy_would_clear_ch0;

  initial begin
    i_clk          = 1'b0;
    i_rst_n        = 1'b0;
    i_addr         = 8'h00;
    i_wr           = 1'b0;
    i_rd           = 1'b0;
    i_wr_data      = 8'h00;
    int_clear_type = 1'b1;  // R1C
    i_int_allowed  = 8'h00;
    status_set_evt = '0;

    repeat (4) @(negedge i_clk);
    i_rst_n = 1'b1;
    repeat (2) @(negedge i_clk);

    //--------------------------------------------------------------------------
    $display("\n==== TEST 1: status reg read, status delivered -> must CLEAR ====");
    // Event happens, status becomes sticky 1 and synchroniser settles.
    @(negedge i_clk); status_set_evt[0] = 1'b1;
    @(negedge i_clk); status_set_evt[0] = 1'b0;
    repeat (4) @(negedge i_clk);
    check(status_model[0] === 1'b1, "status[0] set before read");

    snapshot(NIRS_INT_STATUS);                 // MCU receives bit0 = 1
    check(i_int_allowed[0] === 1'b1, "delivered byte carries status[0]=1");
    do_read_strobe(NIRS_INT_STATUS);
    repeat (3) @(negedge i_clk);
    check(status_model[0] === 1'b0, "status[0] cleared after delivered read");

    //--------------------------------------------------------------------------
    $display("\n==== TEST 2: status reg read, status set MID-POLL -> must NOT clear ====");
    // Start clean.
    check(status_model[0] === 1'b0, "status[0] starts clear");
    // MCU latches the read byte while status is still 0.
    snapshot(NIRS_INT_STATUS);
    check(i_int_allowed[0] === 1'b0, "delivered byte has status[0]=0 (event not yet seen)");
    // Event fires AFTER the byte was frozen but BEFORE the read strobe.
    @(negedge i_clk); status_set_evt[0] = 1'b1;
    @(negedge i_clk); status_set_evt[0] = 1'b0;
    repeat (3) @(negedge i_clk); // let live synchroniser reach 1
    legacy_would_clear_ch0 = int_clear_type & tb_sync[0]; // old gating (no snapshot)
    check(legacy_would_clear_ch0 === 1'b1, "legacy logic WOULD have cleared (race exists)");
    do_read_strobe(NIRS_INT_STATUS);
    repeat (3) @(negedge i_clk);
    check(status_model[0] === 1'b1, "status[0] PRESERVED by fix (MCU catches it next poll)");

    //--------------------------------------------------------------------------
    $display("\n==== TEST 3: next poll genuinely delivers the preserved status -> CLEAR ====");
    snapshot(NIRS_INT_STATUS);
    check(i_int_allowed[0] === 1'b1, "delivered byte now carries status[0]=1");
    do_read_strobe(NIRS_INT_STATUS);
    repeat (3) @(negedge i_clk);
    check(status_model[0] === 1'b0, "status[0] cleared on the poll that delivered it");

    //--------------------------------------------------------------------------
    $display("\n==== TEST 4: DOUT0 read race (status in bit[7]) -> must NOT clear ====");
    check(status_model[0] === 1'b0, "status[0] starts clear");
    snapshot(NIRS_DOUT0_0);                    // bit7 captured = 0
    check(i_int_allowed[7] === 1'b0, "delivered DOUT0 byte has status bit[7]=0");
    @(negedge i_clk); status_set_evt[0] = 1'b1;
    @(negedge i_clk); status_set_evt[0] = 1'b0;
    repeat (3) @(negedge i_clk);
    do_read_strobe(NIRS_DOUT0_0);
    repeat (3) @(negedge i_clk);
    check(status_model[0] === 1'b1, "status[0] PRESERVED on DOUT0 mid-poll race");

    //--------------------------------------------------------------------------
    $display("\n==== TEST 5: DOUT0 read delivered (bit[7]=1) -> CLEAR ====");
    snapshot(NIRS_DOUT0_0);
    check(i_int_allowed[7] === 1'b1, "delivered DOUT0 byte has status bit[7]=1");
    do_read_strobe(NIRS_DOUT0_0);
    repeat (3) @(negedge i_clk);
    check(status_model[0] === 1'b0, "status[0] cleared on delivered DOUT0 read");

    //--------------------------------------------------------------------------
    $display("\n==== TEST 6: W1C still works (int_clear_type=0) ====");
    int_clear_type = 1'b0;
    @(negedge i_clk); status_set_evt[1] = 1'b1;
    @(negedge i_clk); status_set_evt[1] = 1'b0;
    repeat (3) @(negedge i_clk);
    check(status_model[1] === 1'b1, "status[1] set");
    // Write 1 to channel-1 bit of NIRS_INT_STATUS
    @(negedge i_clk);
    i_addr    <= NIRS_INT_STATUS;
    i_wr      <= 1'b1;
    i_wr_data <= 8'h02;
    @(negedge i_clk);
    i_wr      <= 1'b0;
    i_wr_data <= 8'h00;
    i_addr    <= 8'h00;
    repeat (3) @(negedge i_clk);
    check(status_model[1] === 1'b0, "status[1] cleared by W1C");

    //--------------------------------------------------------------------------
    repeat (4) @(negedge i_clk);
    $display("\n==================================================");
    if (errors == 0)
      $display("ALL TESTS PASSED");
    else
      $display("TESTS FAILED: %0d", errors);
    $display("==================================================\n");
    $finish;
  end

  initial begin
    #100000;
    $display("ERROR: timeout");
    $finish;
  end

endmodule
