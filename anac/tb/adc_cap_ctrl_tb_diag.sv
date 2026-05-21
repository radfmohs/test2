//==============================================================================
// Test Bench for adc_cap_ctrl module - Diagnostic
//==============================================================================

`timescale 1ns/1ps

module adc_cap_ctrl_tb();

// Clock and Reset
reg sysclk;
reg presetn;
reg scan_mode;

// Control signals
reg bypass_adc_data_en;
reg bypass_ignore_first;
reg [3:0] stim_dly_tgt;
reg adc_mode;
reg [15:0] adc_cap_period;
reg [3:0] pair_num;

// Interrupt controls
reg [4:0] stim_mon_int_en;
reg [4:0] stim_mon_int_topin_en;
reg [1:0] stim_mon_delta_data_sel;
reg stim_mon_int_clr;
reg stim_mon_delta_int_clr;
reg stim_mon_cycle_int_clr;
reg [15:0] stim_mon_leadoff_int_clr;
reg [15:0] stim_mon_short_int_clr;
reg int_length_slct;

// Driver control
reg [15:0] o_source_driver;
reg [15:0] o_pulldn_driver;

// Stimulus pad target arrays
reg [15:0][3:0] stim_pad0_tgt;
reg [15:0][3:0] stim_pad1_tgt;

// ADC input
reg [9:0] A2D_ADC_DATA;
reg A2D_ADC_DATA_EN;

// Detection thresholds
reg [9:0] threshold_leadoff;
reg [9:0] threshold_short;
reg [7:0] threshold_tgt;

// DUT outputs
wire [3:0] D2A_STIM_PAD0;
wire [3:0] D2A_STIM_PAD1;
wire A2D_ADC_DATA_VLD;
wire [15:0] A2D_ADC_DATA_TAG;
wire A2D_ADC_DELTA_DATA_VLD;
wire [15:0] A2D_ADC_DELTA_DATA_TAG;
wire one_cycle_data_vld;
wire [255:0] one_cycle_data;

// Interrupt outputs
wire [15:0] stim_mon_leadoff_int_sts;
wire [15:0] stim_mon_short_int_sts;
wire stim_mon_int_sts;
wire stim_mon_delta_int_sts;
wire stim_mon_cycle_int_sts;
wire o_stim_mon_int;

//==============================================================================
// Instantiate DUT
//==============================================================================
adc_cap_ctrl dut (
    .sysclk(sysclk),
    .presetn(presetn),
    .scan_mode(scan_mode),
    .bypass_adc_data_en(bypass_adc_data_en),
    .bypass_ignore_first(bypass_ignore_first),
    .stim_dly_tgt(stim_dly_tgt),
    .stim_mon_int_en(stim_mon_int_en),
    .stim_mon_int_topin_en(stim_mon_int_topin_en),
    .stim_mon_delta_data_sel(stim_mon_delta_data_sel),
    .o_source_driver(o_source_driver),
    .o_pulldn_driver(o_pulldn_driver),
    .stim_mon_int_clr(stim_mon_int_clr),
    .stim_mon_int_sts(stim_mon_int_sts),
    .stim_mon_delta_int_clr(stim_mon_delta_int_clr),
    .stim_mon_delta_int_sts(stim_mon_delta_int_sts),
    .stim_mon_cycle_int_clr(stim_mon_cycle_int_clr),
    .stim_mon_cycle_int_sts(stim_mon_cycle_int_sts),
    .stim_mon_leadoff_int_clr(stim_mon_leadoff_int_clr),
    .stim_mon_leadoff_int_sts(stim_mon_leadoff_int_sts),
    .stim_mon_short_int_clr(stim_mon_short_int_clr),
    .stim_mon_short_int_sts(stim_mon_short_int_sts),
    .threshold_leadoff(threshold_leadoff),
    .threshold_short(threshold_short),
    .threshold_tgt(threshold_tgt),
    .o_stim_mon_int(o_stim_mon_int),
    .int_length_slct(int_length_slct),
    .adc_mode(adc_mode),
    .adc_cap_period(adc_cap_period),
    .pair_num(pair_num),
    .stim_pad0_tgt(stim_pad0_tgt),
    .stim_pad1_tgt(stim_pad1_tgt),
    .A2D_ADC_DATA(A2D_ADC_DATA),
    .A2D_ADC_DATA_EN(A2D_ADC_DATA_EN),
    .D2A_STIM_PAD0(D2A_STIM_PAD0),
    .D2A_STIM_PAD1(D2A_STIM_PAD1),
    .A2D_ADC_DATA_VLD(A2D_ADC_DATA_VLD),
    .A2D_ADC_DATA_TAG(A2D_ADC_DATA_TAG),
    .A2D_ADC_DELTA_DATA_VLD(A2D_ADC_DELTA_DATA_VLD),
    .A2D_ADC_DELTA_DATA_TAG(A2D_ADC_DELTA_DATA_TAG),
    .one_cycle_data_vld(one_cycle_data_vld),
    .one_cycle_data(one_cycle_data)
);

//==============================================================================
// Clock Generation
//==============================================================================
initial begin
    sysclk = 0;
    forever #5 sysclk = ~sysclk;
end

//==============================================================================
// Main Test
//==============================================================================
initial begin
    $display("===============================================");
    $display("ADC CAP CTRL Testbench - Diagnostic Run");
    $display("===============================================\n");
    
    // Initialize
    presetn = 0;
    bypass_adc_data_en = 0;
    bypass_ignore_first = 1;
    stim_dly_tgt = 4'b0;
    stim_mon_int_en = 5'b11111;
    stim_mon_int_topin_en = 5'b11111;
    stim_mon_delta_data_sel = 2'b00;
    adc_mode = 1'b1;
    adc_cap_period = 16'b0;
    pair_num = 4'b0001;
    o_source_driver = 16'h0000;
    o_pulldn_driver = 16'h0000;
    stim_mon_int_clr = 0;
    stim_mon_delta_int_clr = 0;
    stim_mon_cycle_int_clr = 0;
    stim_mon_leadoff_int_clr = 16'h0000;
    stim_mon_short_int_clr = 16'h0000;
    threshold_leadoff = 10'd800;
    threshold_short = 10'd50;
    threshold_tgt = 8'd3;
    int_length_slct = 0;
    scan_mode = 0;
    A2D_ADC_DATA = 10'b0;
    A2D_ADC_DATA_EN = 0;
    
    // Initialize pad targets
    for (int i=0; i<16; i++) begin
        stim_pad0_tgt[i] = i;
        stim_pad1_tgt[i] = (i+1) % 16;
    end
    
    #20;
    presetn = 1;
    #20;
    
    //==========================================================================
    // Test 1: Simple ADC capture with real_latch behavior
    //==========================================================================
    $display("--- Test 1: Simple ADC Data Capture ---");
    o_source_driver = 16'h0001;
    #20;
    
    $display("Step 1: First stimulus, should ignore first sample");
    A2D_ADC_DATA = 10'd512;
    A2D_ADC_DATA_EN = 1;
    #10;
    A2D_ADC_DATA_EN = 0;
    #40;
    $display("  A2D_ADC_DATA_VLD = %b (expected 0)", A2D_ADC_DATA_VLD);
    $display("  A2D_ADC_DELTA_DATA_VLD = %b (expected 0)", A2D_ADC_DELTA_DATA_VLD);
    
    $display("Step 2: Second sample for first pair");
    A2D_ADC_DATA = 10'd520;
    A2D_ADC_DATA_EN = 1;
    #10;
    A2D_ADC_DATA_EN = 0;
    #40;
    $display("  A2D_ADC_DATA_VLD = %b (expected 1)", A2D_ADC_DATA_VLD);
    $display("  A2D_ADC_DELTA_DATA_VLD = %b", A2D_ADC_DELTA_DATA_VLD);
    
    $display("Step 3: First sample for second pair");
    A2D_ADC_DATA = 10'd530;
    A2D_ADC_DATA_EN = 1;
    #10;
    A2D_ADC_DATA_EN = 0;
    #40;
    $display("  A2D_ADC_DATA_VLD = %b", A2D_ADC_DATA_VLD);
    $display("  A2D_ADC_DELTA_DATA_VLD = %b (expected 1)", A2D_ADC_DELTA_DATA_VLD);
    
    #100;
    
    //==========================================================================
    // Test 2: Lead-off detection with low threshold
    //==========================================================================
    $display("\n--- Test 2: Lead-off Detection ---");
    adc_mode = 1'b1;
    pair_num = 4'b0001;
    threshold_leadoff = 10'd200;  // Low threshold
    threshold_tgt = 8'd1;
    bypass_ignore_first = 1'b1;
    o_source_driver = 16'h0001;
    #20;
    
    $display("Sending ADC sample at 50 (delta from 512 = 462, > 200)");
    A2D_ADC_DATA = 10'd50;
    A2D_ADC_DATA_EN = 1;
    #10;
    A2D_ADC_DATA_EN = 0;
    #40;
    $display("  leadoff_int_sts[0] = %b (expected 0 - still counting)", stim_mon_leadoff_int_sts[0]);
    
    $display("Sending second sample with ADC at 50");
    A2D_ADC_DATA = 10'd50;
    A2D_ADC_DATA_EN = 1;
    #10;
    A2D_ADC_DATA_EN = 0;
    #40;
    $display("  leadoff_int_sts[0] = %b (expected 1 - threshold_tgt=1)", stim_mon_leadoff_int_sts[0]);
    
    #100;
    
    //==========================================================================
    // Test 3: Short detection
    //==========================================================================
    $display("\n--- Test 3: Short Detection ---");
    stim_mon_leadoff_int_clr = 16'hFFFF;
    #10;
    stim_mon_leadoff_int_clr = 16'h0000;
    
    threshold_short = 10'd30;
    threshold_tgt = 8'd1;
    #20;
    
    $display("Sending ADC sample at 512 (delta = 0, < 30)");
    A2D_ADC_DATA = 10'd512;
    A2D_ADC_DATA_EN = 1;
    #10;
    A2D_ADC_DATA_EN = 0;
    #40;
    $display("  short_int_sts[0] = %b (expected 0 - still counting)", stim_mon_short_int_sts[0]);
    
    $display("Sending second sample with ADC at 512");
    A2D_ADC_DATA = 10'd512;
    A2D_ADC_DATA_EN = 1;
    #10;
    A2D_ADC_DATA_EN = 0;
    #40;
    $display("  short_int_sts[0] = %b (expected 1 - threshold_tgt=1)", stim_mon_short_int_sts[0]);
    
    #100;
    $display("\n===============================================");
    $display("Diagnostic Tests Complete");
    $display("===============================================\n");
    
    $finish;
end

endmodule

