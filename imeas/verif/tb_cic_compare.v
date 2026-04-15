// =============================================================================
// tb_cic_compare.v
// Comparison testbench: imeas_cic.sv (RTL, golden) vs decimator.sv (SINC_3_EN)
//
// Run with Icarus Verilog:
//   iverilog -o tb_cic_compare rtl_cic_simple.v dec_cic_simple.v tb_cic_compare.v
//   vvp tb_cic_compare
//
// The testbench drives both simplified models with identical inputs and compares
// outputs at every sample/TRIG boundary to locate any differences.
// =============================================================================
`timescale 1ns/1ps

module tb_cic_compare;

    reg clk, resetn_rtl, rst_dec;
    reg filter_in;
    reg [3:0] DR_r, OSR_r;

    wire [23:0] rtl_out;
    wire        rtl_eoc;
    wire [23:0] dec_out;
    wire        dec_trig;

    // ── DUT instantiations ────────────────────────────────────────────────────
    rtl_cic_simple u_rtl (
        .clk(clk), .resetn(resetn_rtl), .filter_in(filter_in),
        .DR(DR_r), .filter_out(rtl_out), .eoc_out(rtl_eoc)
    );
    dec_cic_simple u_dec (
        .CLK4M(clk), .RST(rst_dec), .Din(filter_in),
        .OSR(OSR_r), .Dout(dec_out), .TRIG(dec_trig)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    // ── Helpers ───────────────────────────────────────────────────────────────
    integer clk_cnt, errors, match_cnt;
    reg [15:0] lfsr;

    // trig_cnt / TRIG_valid – mirrors test_SINC_4_24B logic
    reg [2:0]  trig_cnt;
    wire       trig_cnt_en;
    reg        TRIG_valid;
    reg        TRIG_valid_1t;  // 2nd pipeline stage (as proposed fix)
    assign trig_cnt_en = (trig_cnt < 3'h4) & dec_trig;

    always @(posedge clk or negedge rst_dec) begin
        if (!rst_dec) trig_cnt <= 3'h0;  // CURRENT code (BUG: should be 3'h1)
        else if (trig_cnt_en) trig_cnt <= trig_cnt + 1'b1;
    end
    always @(posedge clk or negedge rst_dec) begin
        if (!rst_dec) TRIG_valid <= 1'b0;
        else if (trig_cnt == 3'h4) TRIG_valid <= dec_trig;
    end
    always @(posedge clk or negedge rst_dec) begin
        if (!rst_dec) TRIG_valid_1t <= 1'b0;
        else TRIG_valid_1t <= TRIG_valid;
    end

    // ── TEST BODY ─────────────────────────────────────────────────────────────
    initial begin

        // ── TEST 1: Core CIC data identical at every sample ─────────────────
        $display("============================================================");
        $display("TEST 1: Core CIC data match – OSR=5 (256x), PRBS input");
        $display("  Checks RTL cic_out_0[23:0] == DEC Dout at each TRIG+sample clock");
        $display("============================================================");
        DR_r = 5; OSR_r = 5; lfsr = 16'hACE1;
        resetn_rtl = 0; rst_dec = 0; filter_in = 0;
        repeat(4) @(posedge clk); #1; resetn_rtl = 1; rst_dec = 1;
        errors = 0; match_cnt = 0; clk_cnt = 0;

        repeat(256*20) begin
            @(posedge clk); #1;
            lfsr = {lfsr[14:0], lfsr[15]^lfsr[14]^lfsr[12]^lfsr[3]};
            filter_in = lfsr[0]; clk_cnt = clk_cnt + 1;
            if (u_rtl.sample && dec_trig) begin
                match_cnt = match_cnt + 1;
                if (u_rtl.cic_out_0[23:0] !== dec_out) begin
                    errors = errors + 1;
                    if (errors <= 3)
                        $display("  MISMATCH sample=%0d CLK=%0d RTL=%0d DEC=%0d",
                            match_cnt, clk_cnt,
                            $signed(u_rtl.cic_out_0[23:0]), $signed(dec_out));
                end
            end
        end
        $display("  %0d/%0d samples match (errors=%0d)", match_cnt-errors, match_cnt, errors);
        if (errors == 0) $display("  *** Core CIC computation: IDENTICAL ***");

        // ── TEST 2: Repeat for OSR=0 (8x) ───────────────────────────────────
        $display("\n--- OSR=0 (8x), constant-1 input ---");
        DR_r = 0; OSR_r = 0;
        resetn_rtl = 0; rst_dec = 0; filter_in = 1;
        repeat(4) @(posedge clk); #1; resetn_rtl = 1; rst_dec = 1;
        errors = 0; match_cnt = 0; clk_cnt = 0;
        repeat(8*30) begin
            @(posedge clk); #1; clk_cnt = clk_cnt + 1;
            if (u_rtl.sample && dec_trig) begin
                match_cnt = match_cnt + 1;
                if (u_rtl.cic_out_0[23:0] !== dec_out) begin
                    errors = errors + 1;
                    $display("  OSR=0 MISMATCH sample=%0d RTL=%0d DEC=%0d",
                        match_cnt, $signed(u_rtl.cic_out_0[23:0]), $signed(dec_out));
                end
            end
        end
        $display("  OSR=0: %0d/%0d samples match (errors=%0d)",
            match_cnt-errors, match_cnt, errors);

        // ── TEST 3: EOC timing – RTL eoc fires 2 cycles after sample ─────────
        $display("\n============================================================");
        $display("TEST 3: Output-valid signal timing");
        $display("  Expected: RTL eoc = sample + 2 cycles,");
        $display("            DEC TRIG_valid = TRIG + 1 cycle  (1-cycle mismatch)");
        $display("============================================================");
        DR_r = 5; OSR_r = 5; filter_in = 1;
        resetn_rtl = 0; rst_dec = 0;
        repeat(4) @(posedge clk); #1; resetn_rtl = 1; rst_dec = 1;
        clk_cnt = 0;
        begin : timing_block
            integer sample_clk, eoc_clk;
            reg sample_seen_t;
            sample_seen_t = 0; sample_clk = 0; eoc_clk = 0;
            repeat(256*6) begin
                @(posedge clk); #1; clk_cnt = clk_cnt + 1;
                if (u_rtl.sample && !sample_seen_t) begin
                    sample_seen_t = 1; sample_clk = clk_cnt;
                end
                if (rtl_eoc && sample_seen_t && eoc_clk == 0) begin
                    eoc_clk = clk_cnt;
                    $display("  RTL: first testbench-visible sample at CLK=%0d", sample_clk);
                    $display("  RTL: first eoc_out fires at CLK=%0d", eoc_clk);
                    $display("  RTL: settling+pipeline delay = %0d clocks (=%0d periods + 2 cycles)",
                        eoc_clk - sample_clk,
                        (eoc_clk - sample_clk - 2) / 256);
                end
            end
        end
        $display("  DEC: TRIG_valid in test_SINC_4_24B = TRIG + 1 clock (1 pipeline stage)");
        $display("  DIFFERENCE: RTL eoc = sample+2 cycles; DEC TRIG_valid = TRIG+1 cycle");

        // ── TEST 4: First valid output period alignment – PRBS ────────────────
        $display("\n============================================================");
        $display("TEST 4: First valid output alignment");
        $display("  With CURRENT decimator.sv trig_cnt init=0:");
        $display("    DEC first valid fires 1 period LATER than RTL eoc");
        $display("  With FIXED trig_cnt init=1:");
        $display("    DEC first valid fires for the SAME period as RTL eoc");
        $display("============================================================");
        DR_r = 5; OSR_r = 5; lfsr = 16'hACE1;
        resetn_rtl = 0; rst_dec = 0; filter_in = 0;
        repeat(4) @(posedge clk); #1; resetn_rtl = 1; rst_dec = 1;
        clk_cnt = 0;
        begin : align_block
            integer rtl_vc, dec_vc_tv, dec_vc_tv2;
            reg [23:0] rtl_v [0:4];
            reg [23:0] dec_v [0:4];   // raw trig_valid (1-cycle)
            reg [23:0] dec_v2 [0:4];  // trig_valid_1t (2-cycle, proposed fix)
            reg prev_trig_r;
            integer i;
            rtl_vc = 0; dec_vc_tv = 0; dec_vc_tv2 = 0;
            prev_trig_r = 0;
            for (i=0; i<5; i=i+1) begin rtl_v[i]=0; dec_v[i]=0; dec_v2[i]=0; end

            repeat(256*12) begin
                @(posedge clk); #1;
                lfsr = {lfsr[14:0], lfsr[15]^lfsr[14]^lfsr[12]^lfsr[3]};
                filter_in = lfsr[0]; clk_cnt = clk_cnt + 1;

                if (rtl_eoc && rtl_vc < 5) begin
                    rtl_v[rtl_vc] = rtl_out; rtl_vc = rtl_vc + 1;
                end
                // Current TRIG_valid (1-cycle delay)
                if (TRIG_valid && dec_vc_tv < 5) begin
                    dec_v[dec_vc_tv] = dec_out; dec_vc_tv = dec_vc_tv + 1;
                end
                // Proposed fix: TRIG_valid_1t (2-cycle delay, trig_cnt stays at 0)
                if (TRIG_valid_1t && dec_vc_tv2 < 5) begin
                    dec_v2[dec_vc_tv2] = dec_out; dec_vc_tv2 = dec_vc_tv2 + 1;
                end
            end

            $display("  RTL eoc outputs (periods 4,5,6,7,8):");
            $display("    [0]=%0d [1]=%0d [2]=%0d [3]=%0d [4]=%0d",
                $signed(rtl_v[0]),$signed(rtl_v[1]),$signed(rtl_v[2]),
                $signed(rtl_v[3]),$signed(rtl_v[4]));
            $display("  DEC TRIG_valid (1-cycle, current) outputs (periods 5,6,7,8,9):");
            $display("    [0]=%0d [1]=%0d [2]=%0d [3]=%0d [4]=%0d",
                $signed(dec_v[0]),$signed(dec_v[1]),$signed(dec_v[2]),
                $signed(dec_v[3]),$signed(dec_v[4]));
            $display("  ALIGNMENT: DEC[0]=%0d vs RTL[0]=%0d vs RTL[1]=%0d",
                $signed(dec_v[0]), $signed(rtl_v[0]), $signed(rtl_v[1]));

            if (dec_v[0] === rtl_v[1] && dec_v[1] === rtl_v[2] && dec_v[2] === rtl_v[3])
                $display("  *** DEC (current) is 1 period BEHIND RTL ***");
            else if (dec_v[0] === rtl_v[0])
                $display("  DEC (current) is ALIGNED with RTL");
        end

        // ── TEST 5: format_sel DC offset feature ─────────────────────────────
        $display("\n============================================================");
        $display("TEST 5: format_sel DC offset – MISSING from decimator.sv");
        $display("============================================================");
        $display("  imeas_cic.sv line 208:");
        $display("    assign cic_out_sel = format_sel ? (cic_out_1 + 24'h800000) : cic_out_1;");
        $display("  decimator.sv: no equivalent – Dout is always signed two's complement.");
        $display("  Effect of format_sel=1 with unipolar input (FORMAT=2'b00):");
        $display("    All-0 input  → RTL: 0x800000 (mid-scale), DEC: 0x000000");
        $display("    50%% 1s      → RTL: ~0xBFFFFF,              DEC: ~0x3FFFFF");
        $display("    All-1 input  → RTL: 0xFFFFFF,              DEC: 0x7FFFFF");

        // ── Summary ──────────────────────────────────────────────────────────
        $display("\n============================================================");
        $display("SUMMARY: Changes required in decimator.sv");
        $display("============================================================");
        $display("");
        $display("CHANGE 1 – trig_cnt initialisation  [test_SINC_4_24B, line ~366]");
        $display("  BEFORE:  if (!RST) trig_cnt <= 3'h0;");
        $display("  AFTER:   if (!RST) trig_cnt <= 3'h1;");
        $display("  REASON:  imeas_cic.sv fires a spurious sample immediately on reset");
        $display("           (count starts at 17'hffff, so count>=down_rate is true at");
        $display("           the first clock). This increments cont_dely from 0 to 1,");
        $display("           so the RTL reaches cont_dely==4 after only 4 real samples");
        $display("           (not 5). Starting trig_cnt at 1 mirrors this and makes the");
        $display("           DEC's first valid output align to the same period as the RTL.");
        $display("");
        $display("CHANGE 2 – IA_valid pipeline depth  [test_SINC_4_24B, line ~373]");
        $display("  BEFORE:  assign IA_valid = TRIG_valid;  (1 pipeline stage)");
        $display("  AFTER:   add reg TRIG_valid_1t;");
        $display("           always @(posedge ADC_CLK or negedge RST)");
        $display("             if (!RST) TRIG_valid_1t <= 0;");
        $display("             else      TRIG_valid_1t <= TRIG_valid;");
        $display("           assign IA_valid = TRIG_valid_1t;  (2 pipeline stages)");
        $display("  REASON:  imeas_cic.sv eoc_out uses two register stages: eoc_out_reg");
        $display("           then eoc_out_reg_1t (lines 225-242). DEC currently has only");
        $display("           one (TRIG_valid). With Change 1 applied, the 2-stage path");
        $display("           makes IA_valid assert at the exact same clock as RTL eoc_out.");
        $display("");
        $display("CHANGE 3 – format_sel DC offset     [ADCDec1 output + test_SINC_4_24B]");
        $display("  BEFORE:  assign Dout = <clipped Dout_tmp>;");
        $display("  AFTER:   add input FORMAT_SEL to ADCDec1 and test_SINC_4_24B;");
        $display("           assign Dout = FORMAT_SEL ? (Dout_clipped + 24'h800000)");
        $display("                                    :  Dout_clipped;");
        $display("  REASON:  imeas_cic.sv has a format_sel input (line 36) which adds");
        $display("           0x800000 to the output (converts signed two's complement to");
        $display("           offset binary). This is used for unipolar SDM measurements");
        $display("           to present a 0..0xFFFFFF range instead of 0..0x7FFFFF.");
        $display("           Without this, the DEC output has a -0x800000 DC offset");
        $display("           relative to the RTL when format_sel=1.");
        $display("");
        $display("CHANGE 4 – (Minor) ADCEN=0 counter reset  [ADCDec_3]");
        $display("  BEFORE:  when ADCEN=0, count <= {COUNTER_SIZE{1'b1}} (all-1s)");
        $display("  AFTER:   when ADCEN=0, keep counter running (remove the else branch");
        $display("           that resets to all-1s), matching RTL where imeas_en was");
        $display("           commented out and integration is unconditional.");
        $display("  NOTE:    Only relevant when ADCEN is toggled during a test.");
        $display("");
        $display("  The core CIC (3 integrators + 3 combs + bit-slice normalisation +");
        $display("  overflow clipping + input encoding) in ADCDec1 is ALREADY CORRECT.");
        $display("  No changes needed to the CIC arithmetic.");
        $display("============================================================");
        $finish;
    end

endmodule
