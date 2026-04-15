// Simplified CIC filter based on imeas_cic.sv (RTL)
// SINC3: 3 integrators, 3 combs
// FORMAT=2'b00 (0/1 unsigned input), active-low resetn
// Output: 24-bit
`timescale 1ns/1ps

module rtl_cic_simple (
    input  wire        clk,
    input  wire        resetn,
    input  wire        filter_in,
    input  wire [3:0]  DR,
    output wire [23:0] filter_out,
    output wire        eoc_out
);

    reg  [49:0] integ1, integ2, integ3;
    reg  [49:0] comb1,  comb2,  comb3;

    wire [49:0] comb1_dec, comb2_dec, comb3_dec;
    wire [49:0] din_use, din_use1;
    wire [16:0] down_rate;
    reg  [16:0] count;
    wire        sample_tmp;
    reg         sample_tmp_d1;
    wire        sample;

    // input encoding FORMAT=2'b00: map 0->0, 1->+1
    assign din_use = filter_in ? {{49{1'b0}},1'b1} : 50'h0;

    // down_rate = OSR - 1  (sample when count >= down_rate)
    assign down_rate = (DR==4'd0) ? 17'h7   :
                       (DR==4'd1) ? 17'hf   :
                       (DR==4'd2) ? 17'h1f  :
                       (DR==4'd3) ? 17'h3f  :
                       (DR==4'd4) ? 17'h7f  :
                       (DR==4'd5) ? 17'hff  :
                       (DR==4'd6) ? 17'h1ff :
                       (DR==4'd7) ? 17'h3ff :
                       (DR==4'd8) ? 17'h7ff :
                       (DR==4'd9) ? 17'hfff : 17'hfff;

    // input scaling: shift input left so max accumulator value stays fixed
    // from imeas_cic.sv: din_use1 = din_use << (3*(16-DR)) = f(DR)
    assign din_use1 = (DR==4'd0) ? {din_use[10:0], 39'b0} :
                      (DR==4'd1) ? {din_use[13:0], 36'b0} :
                      (DR==4'd2) ? {din_use[16:0], 33'b0} :
                      (DR==4'd3) ? {din_use[19:0], 30'b0} :
                      (DR==4'd4) ? {din_use[22:0], 27'b0} :
                      (DR==4'd5) ? {din_use[25:0], 24'b0} :
                      (DR==4'd6) ? {din_use[28:0], 21'b0} :
                      (DR==4'd7) ? {din_use[31:0], 18'b0} :
                      (DR==4'd8) ? {din_use[34:0], 15'b0} :
                      (DR==4'd9) ? {din_use[37:0], 12'b0} : din_use;

    // sample pulse: one-cycle pulse when count first reaches down_rate
    assign sample_tmp = (count >= down_rate);
    always @(posedge clk or negedge resetn)
        if (!resetn) sample_tmp_d1 <= 1'b0;
        else         sample_tmp_d1 <= sample_tmp;
    assign sample = sample_tmp & (~sample_tmp_d1);

    // counter: reset to ffff so sample fires quickly after reset
    always @(posedge clk or negedge resetn)
        if (!resetn)     count <= 17'hffff;
        else if (sample) count <= 17'h0;
        else             count <= count + 17'b1;

    // 3-stage integrators run at full clock rate (non-blocking = 1-cycle pipeline)
    always @(posedge clk or negedge resetn)
        if (!resetn) begin
            integ1 <= 50'h0; integ2 <= 50'h0; integ3 <= 50'h0;
        end else begin
            integ1 <= integ1 + din_use1;
            integ2 <= integ1 + integ2;   // uses integ1[n-1]
            integ3 <= integ2 + integ3;   // uses integ2[n-1]
        end

    // comb differences (purely combinatorial using old registered comb values)
    assign comb1_dec = integ3 - comb1;
    assign comb2_dec = comb1_dec - comb2;
    assign comb3_dec = comb2_dec - comb3;

    // comb registers + output register, update only on sample pulse
    // cic_out_0 is 33-bit per imeas_cic.sv; assigned comb3_dec[49:25] (25 bits -> right-justified)
    reg  [32:0] cic_out_0;
    always @(posedge clk or negedge resetn)
        if (!resetn) begin
            comb1 <= 50'h0; comb2 <= 50'h0; comb3 <= 50'h0;
            cic_out_0 <= 33'h0;
        end else if (sample) begin
            comb1     <= integ3;          // store current integrator output
            comb2     <= comb1_dec;       // store difference 1
            comb3     <= comb2_dec;       // store difference 2
            // cic_out_0[24:0] = comb3_dec[49:25], upper bits 0
            cic_out_0 <= {8'b0, comb3_dec[49:25]};
        end

    // For FORMAT=2'b00: output = cic_out_0[23:0] = comb3_dec[48:25]
    // cic_out_0[24] = comb3_dec[49] is the extra "overflow" sign bit
    assign filter_out = cic_out_0[23:0];

    // eoc generation: skip first 4 samples (settling), then assert on each sample
    reg [2:0] cont_dely;
    always @(posedge clk or negedge resetn)
        if (!resetn) cont_dely <= 3'h0;
        else if ((cont_dely < 3'h4) & sample) cont_dely <= cont_dely + 1'b1;

    reg eoc_reg;
    always @(posedge clk or negedge resetn)
        if (!resetn) eoc_reg <= 1'b0;
        else if (cont_dely == 3'h4) eoc_reg <= sample;

    reg eoc_reg_d1;
    always @(posedge clk or negedge resetn)
        if (!resetn) eoc_reg_d1 <= 1'b0;
        else         eoc_reg_d1 <= eoc_reg;

    assign eoc_out = eoc_reg_d1;

endmodule
