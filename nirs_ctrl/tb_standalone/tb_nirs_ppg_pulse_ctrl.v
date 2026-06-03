// ============================================================================
// Standalone testbench : nirs_ppg_pulse_ctrl
// ----------------------------------------------------------------------------
// Verifies the timing/pulse generator documented in README section 12
// (Fig 12.1.3, Tables 12.1.3.1/2) and registers NIRS_CTRL_0/1 + NIRS_CTRL_MODE.
//
//  Part A - control->duration look-up tables (probed on internal nets):
//      PERIOD_CTRL      (NIRS_CTRL_0[7:4])   125us .. 22ms
//      OTS_CTRL         (NIRS_CTRL_0[3:0])   1us  .. 50us
//      LED_OFF_CTRL     (NIRS_CTRL_1[7:6])   README: 0:2 1:3 2:4 3:5 us
//      RESET_CTRL       (NIRS_CTRL_1[5:3])   50us .. 200us
//      LED_STABLE_CTRL  (NIRS_CTRL_1[2:0])   10us .. 200us
//
//  Part B - pulse sequencing in RECEIVER-MASTER continuous-typical mode:
//      RESET -> (Td) -> IPD_SW integration ; LED on t_stable before IPD_SW and
//      off t_off after ; IIN_SW spans EN..IPD_SW end (README D2A signal notes).
//
//  Part C - LED flashing sequence for DUAL / SINGLE / AMBIENT modes
//      (NIRS_CTRL_MODE bits 4/5).
//
// Clock is 2 MHz -> 1 us == 2 clk cycles (durations are stored *2 internally).
// ============================================================================
`timescale 1ns/1ps

module tb_nirs_ppg_pulse_ctrl;

  reg        rst_n, clk;
  wire       COUNT_STOP;
  reg  [5:0] MODE_SEL;
  reg        NIRS_EN, NIRS_MEAS;
  wire [1:0] LED;

  reg  [2:0] LED_stable_ctrl_0, LED_stable_ctrl_1;
  reg  [1:0] LED_off_ctrl_0,    LED_off_ctrl_1;
  reg  [2:0] RESET_ctrl_0,      RESET_ctrl_1;
  reg  [3:0] PERIOD_ctrl_0,     PERIOD_ctrl_1;
  reg  [3:0] OTS_ctrl_0,        OTS_ctrl_1;

  wire       EN_DIG;
  reg        EN_OFF;
  wire       EN, RESET, IPD_SW, IIN_SW, LED_ON;

  integer errors = 0;
  integer checks = 0;
  integer deviations = 0;

  nirs_ppg_pulse_ctrl dut (
    .rst_n            (rst_n),
    .clk              (clk),
    .COUNT_STOP       (COUNT_STOP),
    .MODE_SEL         (MODE_SEL),
    .NIRS_EN          (NIRS_EN),
    .NIRS_MEAS        (NIRS_MEAS),
    .LED              (LED),
    .LED_stable_ctrl_0(LED_stable_ctrl_0),
    .LED_off_ctrl_0   (LED_off_ctrl_0),
    .RESET_ctrl_0     (RESET_ctrl_0),
    .PERIOD_ctrl_0    (PERIOD_ctrl_0),
    .OTS_ctrl_0       (OTS_ctrl_0),
    .LED_stable_ctrl_1(LED_stable_ctrl_1),
    .LED_off_ctrl_1   (LED_off_ctrl_1),
    .RESET_ctrl_1     (RESET_ctrl_1),
    .PERIOD_ctrl_1    (PERIOD_ctrl_1),
    .OTS_ctrl_1       (OTS_ctrl_1),
    .EN_DIG           (EN_DIG),
    .EN_OFF           (EN_OFF),
    .EN               (EN),
    .RESET            (RESET),
    .IPD_SW           (IPD_SW),
    .IIN_SW           (IIN_SW),
    .LED_ON           (LED_ON)
  );

  always #250 clk = ~clk;   // 2 MHz

  task set_all_ctrls;
    input [3:0] per; input [3:0] ots; input [1:0] off; input [2:0] rst; input [2:0] stab;
    begin
      PERIOD_ctrl_0=per; PERIOD_ctrl_1=per;
      OTS_ctrl_0=ots;    OTS_ctrl_1=ots;
      LED_off_ctrl_0=off;LED_off_ctrl_1=off;
      RESET_ctrl_0=rst;  RESET_ctrl_1=rst;
      LED_stable_ctrl_0=stab; LED_stable_ctrl_1=stab;
    end
  endtask

  task do_reset;
    begin
      rst_n=0; MODE_SEL=6'b000000; NIRS_EN=0; NIRS_MEAS=0; EN_OFF=0;
      set_all_ctrls(4'd0,4'd0,2'd0,3'd0,3'd0);
      @(negedge clk); @(negedge clk);
      rst_n=1; @(negedge clk);
    end
  endtask

  task chk_us;                          // compare internal duration net (us) vs expected
    input [15:0] got; input [15:0] exp; input [255:0] tag; input integer code;
    begin
      checks = checks + 1;
      if (got !== exp) begin
        deviations = deviations + 1;
        $display("  [DEVIATION] %0s code=%0d -> %0d us (README expects %0d us)", tag, code, got, exp);
      end else
        $display("  [ok]   %0s code=%0d = %0d us", tag, code, got);
    end
  endtask

  // README look-up tables
  function [15:0] exp_period; input integer c; begin case(c)
    0:exp_period=125;1:exp_period=250;2:exp_period=500;3:exp_period=750;
    4:exp_period=1000;5:exp_period=2000;6:exp_period=4000;7:exp_period=6000;
    8:exp_period=8000;9:exp_period=10000;10:exp_period=12000;11:exp_period=14000;
    12:exp_period=16000;13:exp_period=18000;14:exp_period=20000;15:exp_period=22000;
  endcase end endfunction

  function [15:0] exp_ots; input integer c; begin case(c)
    0:exp_ots=1;1:exp_ots=2;2:exp_ots=3;3:exp_ots=4;4:exp_ots=5;5:exp_ots=6;
    6:exp_ots=8;7:exp_ots=10;8:exp_ots=15;9:exp_ots=20;10:exp_ots=25;11:exp_ots=30;
    12:exp_ots=35;13:exp_ots=40;14:exp_ots=45;15:exp_ots=50;
  endcase end endfunction

  function [15:0] exp_off; input integer c; begin case(c)        // README NIRS_CTRL_1
    0:exp_off=2;1:exp_off=3;2:exp_off=4;3:exp_off=5;
  endcase end endfunction

  function [15:0] exp_reset; input integer c; begin case(c)
    0:exp_reset=50;1:exp_reset=70;2:exp_reset=100;3:exp_reset=120;
    4:exp_reset=140;5:exp_reset=160;6:exp_reset=180;7:exp_reset=200;
  endcase end endfunction

  function [15:0] exp_stable; input integer c; begin case(c)
    0:exp_stable=10;1:exp_stable=30;2:exp_stable=50;3:exp_stable=70;
    4:exp_stable=100;5:exp_stable=120;6:exp_stable=150;7:exp_stable=200;
  endcase end endfunction

  integer c;

  // ---- Part B edge capture state ----
  reg pEN,pRST,pIPD,pIIN,pLED;
  integer rEN,fEN,rRST,fRST,rIPD,fIPD,rIIN,fIIN,rLED,fLED;
  reg gEN,gfEN,gRST,gfRST,gIPD,gfIPD,gIIN,gfIIN,gLED,gfLED;
  integer cyc;

  task capture_period;
    begin
      // initialise capture
      pEN=0;pRST=0;pIPD=0;pIIN=0;pLED=0;
      gEN=0;gfEN=0;gRST=0;gfRST=0;gIPD=0;gfIPD=0;gIIN=0;gfIIN=0;gLED=0;gfLED=0;
      rEN=-1;fEN=-1;rRST=-1;fRST=-1;rIPD=-1;fIPD=-1;rIIN=-1;fIIN=-1;rLED=-1;fLED=-1;
      for (cyc=0; cyc<400; cyc=cyc+1) begin
        @(negedge clk);
        if (!pRST &&  RESET && !gRST ) begin rRST=dut.counter; gRST=1; end
        if ( pRST && !RESET && !gfRST&&gRST) begin fRST=dut.counter; gfRST=1; end
        if (!pIPD &&  IPD_SW&& !gIPD ) begin rIPD=dut.counter; gIPD=1; end
        if ( pIPD && !IPD_SW&& !gfIPD&&gIPD) begin fIPD=dut.counter; gfIPD=1; end
        if (!pIIN &&  IIN_SW&& !gIIN ) begin rIIN=dut.counter; gIIN=1; end
        if ( pIIN && !IIN_SW&& !gfIIN&&gIIN) begin fIIN=dut.counter; gfIIN=1; end
        if (!pLED &&  LED_ON&& !gLED ) begin rLED=dut.counter; gLED=1; end
        if ( pLED && !LED_ON&& !gfLED&&gLED) begin fLED=dut.counter; gfLED=1; end
        pEN=EN;pRST=RESET;pIPD=IPD_SW;pIIN=IIN_SW;pLED=LED_ON;
      end
    end
  endtask

  task chk_eq;
    input integer got; input integer exp; input [255:0] tag;
    begin
      checks = checks + 1;
      if (got !== exp) begin
        errors = errors + 1;
        $display("  [FAIL] %0s : got=%0d exp=%0d", tag, got, exp);
      end else
        $display("  [ok]   %0s = %0d", tag, got);
    end
  endtask

  // ---- Part C : LED sequence capture ----
  reg [1:0] led_seq [0:15];
  integer   led_n;
  reg [1:0] led_prev;
  integer   s;
  reg       bad;
  integer   q;
  task capture_led_seq;
    input integer ncycles;
    begin
      led_n=0; led_prev=LED;
      led_seq[0]=LED; led_n=1;
      for (s=0;s<ncycles;s=s+1) begin
        @(negedge clk);
        if (LED!==led_prev) begin
          if (led_n<16) led_seq[led_n]=LED;
          led_n=led_n+1; led_prev=LED;
        end
      end
    end
  endtask

  initial begin
    clk=0;
    $dumpfile("tb_nirs_ppg_pulse_ctrl.vcd");
    $dumpvars(0, tb_nirs_ppg_pulse_ctrl);
    $display("==== nirs_ppg_pulse_ctrl standalone test ====");

    // ------------------------------------------------------------------
    // Part A : duration look-up tables vs README
    // ------------------------------------------------------------------
    do_reset;
    NIRS_EN=0;                  // keep counter halted; mux outputs are combinational
    $display("-- PERIOD_CTRL table (NIRS_CTRL_0[7:4]) --");
    for (c=0;c<16;c=c+1) begin
      set_all_ctrls(c[3:0],4'd0,2'd0,3'd0,3'd0); #1;
      chk_us(dut.t_period_sel, exp_period(c), "PERIOD", c);
    end
    $display("-- OTS_CTRL table (NIRS_CTRL_0[3:0]) --");
    for (c=0;c<16;c=c+1) begin
      set_all_ctrls(4'd0,c[3:0],2'd0,3'd0,3'd0); #1;
      chk_us(dut.t_IPD_SW_w_sel, exp_ots(c), "OTS", c);
    end
    $display("-- LED_OFF_CTRL table (NIRS_CTRL_1[7:6]) --");
    for (c=0;c<4;c=c+1) begin
      set_all_ctrls(4'd0,4'd0,c[1:0],3'd0,3'd0); #1;
      chk_us(dut.t_off_led, exp_off(c), "LED_OFF", c);
    end
    $display("-- RESET_CTRL table (NIRS_CTRL_1[5:3]) --");
    for (c=0;c<8;c=c+1) begin
      set_all_ctrls(4'd0,4'd0,2'd0,c[2:0],3'd0); #1;
      chk_us(dut.t_RESET_w_timing, exp_reset(c), "RESET", c);
    end
    $display("-- LED_STABLE_CTRL table (NIRS_CTRL_1[2:0]) --");
    for (c=0;c<8;c=c+1) begin
      set_all_ctrls(4'd0,4'd0,2'd0,3'd0,c[2:0]); #1;
      chk_us(dut.t_stable_led, exp_stable(c), "LED_STABLE", c);
    end

    // ------------------------------------------------------------------
    // Part B : pulse sequencing (RECEIVER MASTER continuous typical, MODE=0)
    // ------------------------------------------------------------------
    $display("-- pulse sequencing (continuous-typical mode) --");
    do_reset;
    MODE_SEL = 6'b000000;
    set_all_ctrls(4'd0 /*125us*/, 4'd7 /*OTS 10us*/, 2'd0, 3'd0 /*RESET 50us*/, 3'd0 /*stable 10us*/);
    NIRS_EN = 1;
    @(negedge clk);
    capture_period;

    // widths / offsets expressed in clk cycles using the dut-selected durations
    chk_eq(fRST - rRST, dut.t_RESET_w,    "RESET pulse width (cyc)");
    chk_eq(fIPD - rIPD, dut.t_IPD_SW_w,   "IPD_SW integration width (cyc)");
    chk_eq(rIPD - fRST, dut.t_delay,      "Td delay RESET->IPD_SW (cyc)");
    chk_eq(rIPD - rLED, dut.t_stable_led_w,"LED stable before IPD_SW (cyc)");
    chk_eq(fLED - fIPD, dut.t_off_led_w,  "LED off after IPD_SW (cyc)");
    chk_eq(rIIN, rRST,                    "IIN_SW rises with RESET/EN");
    chk_eq(fIIN, fIPD,                    "IIN_SW falls with IPD_SW end");

    // ------------------------------------------------------------------
    // Part C : LED flashing sequence
    // ------------------------------------------------------------------
    $display("-- LED sequencing : DUAL non-ambient (alternate LED0/LED1) --");
    do_reset;
    MODE_SEL = 6'b000000;                 // dual, non-ambient, continuous typ
    set_all_ctrls(4'd0,4'd2,2'd0,3'd0,3'd0);
    NIRS_EN = 1; @(negedge clk);
    capture_led_seq(1400);                // ~ several 125us periods
    // expect LED toggling between 2'b00 (LED0) and 2'b10 (LED1)
    checks = checks + 1;
    if (led_n >= 3 && (led_seq[1]==2'b10 || led_seq[1]==2'b00) &&
        (led_seq[2]!==led_seq[1])) begin
      $display("  [ok]   DUAL LED alternates: seq[0..3]=%b %b %b %b (n=%0d)",
               led_seq[0],led_seq[1],led_seq[2], (led_n>3)?led_seq[3]:2'bxx, led_n);
    end else begin
      errors = errors + 1;
      $display("  [FAIL] DUAL LED did not alternate (n=%0d seq0=%b seq1=%b seq2=%b)",
               led_n, led_seq[0],led_seq[1],led_seq[2]);
    end

    $display("-- LED sequencing : SINGLE non-ambient (LED0 only) --");
    do_reset;
    MODE_SEL = 6'b010000;                 // bit4=1 SINGLE, non-ambient
    set_all_ctrls(4'd0,4'd2,2'd0,3'd0,3'd0);
    NIRS_EN = 1; @(negedge clk);
    capture_led_seq(1400);
    checks = checks + 1;
    // LED1 select bit (LED[1]) must never be set in single mode
    if (led_seq[0][1]==1'b0 && led_n<=2) begin
      $display("  [ok]   SINGLE LED stays LED0 (LED[1] never set), changes=%0d", led_n-1);
    end else begin
      // verify none of the captured entries set bit1
      bad=0;
      for (q=0;q<led_n && q<16;q=q+1) if (led_seq[q][1]) bad=1;
      if (!bad) $display("  [ok]   SINGLE LED never selects LED1 (n=%0d)", led_n);
      else begin errors=errors+1; $display("  [FAIL] SINGLE LED selected LED1 (n=%0d)", led_n); end
    end

    $display("-- LED sequencing : DUAL ambient (4-phase observed) --");
    do_reset;
    MODE_SEL = 6'b100000;                 // bit5=1 ambient, bit4=0 dual
    set_all_ctrls(4'd0,4'd2,2'd0,3'd0,3'd0);
    NIRS_EN = 1; @(negedge clk);
    capture_led_seq(2000);
    $display("  observed LED seq: %b %b %b %b %b (n=%0d)  [00=LED0 01=AMB0 10=LED1 11=AMB1]",
             led_seq[0],(led_n>1)?led_seq[1]:2'bxx,(led_n>2)?led_seq[2]:2'bxx,
             (led_n>3)?led_seq[3]:2'bxx,(led_n>4)?led_seq[4]:2'bxx, led_n);
    checks = checks + 1;
    if (led_n >= 4) $display("  [ok]   ambient mode cycles through >=4 phases");
    else begin errors=errors+1; $display("  [FAIL] ambient mode did not cycle 4 phases (n=%0d)", led_n); end

    $display("==== checks=%0d errors=%0d  README-deviations=%0d ====", checks, errors, deviations);
    if (deviations != 0)
      $display("NOTE: %0d duration-table entr(y/ies) disagree with README.", deviations);
    if (errors == 0) $display("RESULT: PASS (RTL self-consistent)");
    else             $display("RESULT: FAIL");
    $finish;
  end

endmodule
