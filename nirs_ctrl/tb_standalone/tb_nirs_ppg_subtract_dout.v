// ============================================================================
// Standalone testbench : nirs_ppg_subtract_dout
// ----------------------------------------------------------------------------
// Verifies the DOUT compute datapath documented in README section 12 / 13.15:
//   * DOUT  = RATIO * DOUTC - DOUTF
//   * RATIO_CTRL (NIRS_CTRL_7) automatic mapping  0:128 1:64 2:32 3:16
//   * RATIO manual mode (RATIO_MODE=1 -> use RATIO_MANUAL, NIRS_CTRL_8)
//   * AVG_SEL (NIRS_CTRL_2) moving average:
//       0 : DOUT_final = DOUT_computed
//       1 : DOUT_final = 1/2 prev + 1/2 computed
//       2 : DOUT_final = 3/4 prev + 1/4 computed
//       3 : DOUT_final = 15/16 prev + 1/16 computed
//
// Self-checking, no dependency on repo testbenches.
// ============================================================================
`timescale 1ns/1ps

module tb_nirs_ppg_subtract_dout;

  localparam IN_WDTH   = 13;
  localparam OUT_WIDTH = 22;

  reg                    rst_n;
  reg                    clk;
  reg                    en;
  reg  [IN_WDTH-1:0]     DOUTF;
  reg  [IN_WDTH-1:0]     DOUTC;
  reg  [1:0]             AVG_SEL;
  reg  [2:0]             RATIO_CTRL;
  reg  [7:0]             RATIO_MANUAL;
  wire [OUT_WIDTH-1:0]   DOUT;

  integer errors = 0;
  integer checks = 0;

  nirs_ppg_subtract_dout #(.IN_WDTH(IN_WDTH), .OUT_WIDTH(OUT_WIDTH)) dut (
    .rst_n        (rst_n),
    .clk          (clk),
    .en           (en),
    .DOUTF        (DOUTF),
    .DOUTC        (DOUTC),
    .AVG_SEL      (AVG_SEL),
    .RATIO_CTRL   (RATIO_CTRL),
    .RATIO_MANUAL (RATIO_MANUAL),
    .DOUT         (DOUT)
  );

  always #5 clk = ~clk;

  // ---- reference helpers ----------------------------------------------------
  function [7:0] ratio_of;
    input [2:0] rctrl;
    input [7:0] rman;
    begin
      if (rctrl[0])               ratio_of = rman;            // manual mode
      else case (rctrl[2:1])
        2'd0: ratio_of = 8'd128;
        2'd1: ratio_of = 8'd64;
        2'd2: ratio_of = 8'd32;
        2'd3: ratio_of = 8'd16;
      endcase
    end
  endfunction

  function [2:0] shift_of;
    input [1:0] avg;
    begin
      case (avg)
        2'd0: shift_of = 0;
        2'd1: shift_of = 1;
        2'd2: shift_of = 2;
        2'd3: shift_of = 4;
      endcase
    end
  endfunction

  // golden model of the registered output
  reg [OUT_WIDTH-1:0] model;
  function [OUT_WIDTH-1:0] next_dout;
    input [OUT_WIDTH-1:0] prev;
    input [IN_WDTH-1:0]   c;
    input [IN_WDTH-1:0]   f;
    input [2:0]           rctrl;
    input [7:0]           rman;
    input [1:0]           avg;
    reg [OUT_WIDTH-1:0] sub_result;
    reg [2:0] sh;
    begin
      sub_result = (ratio_of(rctrl,rman) * c) - f;
      sh = shift_of(avg);
      if (sub_result < prev)
        next_dout = prev - ((prev - sub_result) >> sh);
      else
        next_dout = prev + ((sub_result - prev) >> sh);
    end
  endfunction

  task do_reset;
    begin
      rst_n = 0; en = 0; model = 0;
      @(negedge clk); @(negedge clk);
      rst_n = 1;
      @(negedge clk);
    end
  endtask

  // apply inputs, pulse en for one clk, compare with model
  task step;
    input [IN_WDTH-1:0] c;
    input [IN_WDTH-1:0] f;
    input [2:0]         rctrl;
    input [7:0]         rman;
    input [1:0]         avg;
    begin
      DOUTC = c; DOUTF = f; RATIO_CTRL = rctrl; RATIO_MANUAL = rman; AVG_SEL = avg;
      en = 1;
      @(negedge clk);          // capture edge happened on the posedge inside
      en = 0;
      model = next_dout(model, c, f, rctrl, rman, avg);
      checks = checks + 1;
      if (DOUT !== model) begin
        errors = errors + 1;
        $display("  [FAIL] DOUT=%0d expected=%0d (C=%0d F=%0d rctrl=%b rman=%0d avg=%0d)",
                  DOUT, model, c, f, rctrl, rman, avg);
      end
    end
  endtask

  // directed check of the raw RATIO*C - F relationship with AVG_SEL=0
  task check_ratio;
    input [2:0] rctrl;
    input [7:0] rman;
    input [31:0] expected_ratio;
    reg [OUT_WIDTH-1:0] exp;
    begin
      do_reset;
      DOUTC = 13'd100; DOUTF = 13'd7; RATIO_CTRL = rctrl; RATIO_MANUAL = rman; AVG_SEL = 2'd0;
      en = 1; @(negedge clk); en = 0;
      exp = expected_ratio*100 - 7;
      checks = checks + 1;
      if (DOUT !== exp) begin
        errors = errors + 1;
        $display("  [FAIL] RATIO map rctrl=%b -> DOUT=%0d expected=%0d (ratio=%0d)", rctrl, DOUT, exp, expected_ratio);
      end else
        $display("  [ok]   RATIO map rctrl=%b uses ratio=%0d  DOUT=%0d", rctrl, expected_ratio, DOUT);
    end
  endtask

  integer i;
  initial begin
    clk = 0;
    $dumpfile("tb_nirs_ppg_subtract_dout.vcd");
    $dumpvars(0, tb_nirs_ppg_subtract_dout);

    $display("==== nirs_ppg_subtract_dout standalone test ====");

    // 1) RATIO automatic mapping (README NIRS_CTRL_7 RATIO_CTRL)
    $display("-- RATIO automatic mapping --");
    check_ratio(3'b000, 8'd0, 128); // [2:1]=00 manual=0
    check_ratio(3'b010, 8'd0,  64); // [2:1]=01
    check_ratio(3'b100, 8'd0,  32); // [2:1]=10
    check_ratio(3'b110, 8'd0,  16); // [2:1]=11

    // 2) RATIO manual mode (RATIO_MODE bit0 = 1)
    $display("-- RATIO manual mode --");
    check_ratio(3'b001, 8'd77, 77);
    check_ratio(3'b111, 8'd5,   5);

    // 3) AVG_SEL=0 : DOUT == computed sub_result every sample
    $display("-- AVG_SEL=0 (no averaging) --");
    do_reset;
    step(13'd50, 13'd3, 3'b000, 8'd0, 2'd0);
    step(13'd80, 13'd9, 3'b010, 8'd0, 2'd0);

    // 4) Moving-average convergence for AVG_SEL = 1,2,3 (constant input -> settle)
    $display("-- AVG_SEL moving average convergence --");
    for (i = 0; i < 4; i = i + 1) begin
      do_reset;
      repeat (40) step(13'd120, 13'd10, 3'b000, 8'd0, i[1:0]);
    end

    // 5) Random regression across all knobs
    $display("-- randomized regression --");
    do_reset;
    for (i = 0; i < 400; i = i + 1) begin
      step($random, $random, $random, $random, $random);
    end

    $display("==== checks=%0d errors=%0d ====", checks, errors);
    if (errors == 0) $display("RESULT: PASS");
    else             $display("RESULT: FAIL");
    $finish;
  end

endmodule
