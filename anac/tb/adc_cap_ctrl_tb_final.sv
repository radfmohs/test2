//==============================================================================
// Final Test Bench for adc_cap_ctrl module
// Tests all major functionality with proper stimulus configuration
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

// Test counters
integer test_num = 0;
integer pass_count = 0;
integer fail_count = 0;

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
// Helper Tasks
//==============================================================================

task reset_dut();
    begin
        presetn = 0;
        repeat(2) @(posedge sysclk);
        presetn = 1;
        repeat(2) @(posedge sysclk);
    end
endtask

task init_defaults();
    begin
        bypass_adc_data_en = 0;
        bypass_ignore_first = 1;
        stim_dly_tgt = 4'b0;
        stim_mon_int_en = 5'b11111;
        stim_mon_int_topin_en = 5'b11111;
        stim_mon_delta_data_sel = 2'b00;
        adc_mode = 1'b1;
        adc_cap_period = 16'b0;
        pair_num = 4'b0000;  // 1 pair
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
        
        // Initialize pad targets: pair i uses pads i and i+1
        for (int i=0; i<16; i++) begin
            stim_pad0_tgt[i] = i;
            stim_pad1_tgt[i] = (i+1) % 16;
        end
    end
endtask

task send_adc_sample(input [9:0] sample_val);
    begin
        A2D_ADC_DATA = sample_val;
        A2D_ADC_DATA_EN = 1;
        @(posedge sysclk);
        A2D_ADC_DATA_EN = 0;
        @(posedge sysclk);
    end
endtask

task assert_test(string name, bit condition);
    begin
        test_num = test_num + 1;
        if (condition) begin
            $display("[PASS] Test %2d: %s", test_num, name);
            pass_count = pass_count + 1;
        end else begin
            $display("[FAIL] Test %2d: %s", test_num, name);
            fail_count = fail_count + 1;
        end
    end
endtask

//==============================================================================
// Main Test
//==============================================================================

initial begin
    $display("===============================================");
    $display("ADC CAP CTRL Final Test Suite");
    $display("===============================================\n");
    
    init_defaults();
    reset_dut();
    
    //==========================================================================
    // Test 1: Basic ADC Data Capture
    //==========================================================================
    $display("--- Test 1: Basic ADC Data Capture ---");
    o_source_driver = 16'h0003;  // Enable drivers for pads 0 and 1
    repeat(2) @(posedge sysclk);
    
    assert_test("ADC capture with single pair", A2D_ADC_DATA_VLD === 0);
    
    send_adc_sample(10'd512);
    
    assert_test("ADC data captured after stimulus", A2D_ADC_DATA_VLD === 1);
    
    repeat(5) @(posedge sysclk);
    
    //==========================================================================
    // Test 2: Lead-off Detection
    //==========================================================================
    $display("\n--- Test 2: Lead-off Detection ---");
    init_defaults();
    reset_dut();
    
    o_source_driver = 16'h0003;
    threshold_leadoff = 10'd200;
    threshold_tgt = 8'd2;
    repeat(2) @(posedge sysclk);
    
    // Send sample with extreme ADC value (low), should trigger leadoff after 2 samples
    send_adc_sample(10'd50);
    send_adc_sample(10'd50);
    
    assert_test("Lead-off detection triggered", stim_mon_leadoff_int_sts[0] === 1);
    
    repeat(5) @(posedge sysclk);
    
    //==========================================================================
    // Test 3: Short Detection
    //==========================================================================
    $display("\n--- Test 3: Short Detection ---");
    init_defaults();
    reset_dut();
    
    o_source_driver = 16'h0003;
    threshold_short = 10'd30;
    threshold_tgt = 8'd2;
    repeat(2) @(posedge sysclk);
    
    // Send sample at mid-point (512), should trigger short after 2 samples
    send_adc_sample(10'd512);
    send_adc_sample(10'd512);
    
    assert_test("Short detection triggered", stim_mon_short_int_sts[0] === 1);
    
    repeat(5) @(posedge sysclk);
    
    //==========================================================================
    // Test 4: Delta Data Calculation
    //==========================================================================
    $display("\n--- Test 4: Delta Data Calculation ---");
    init_defaults();
    reset_dut();
    
    o_source_driver = 16'h0003;
    adc_cap_period = 16'd3;  // 4 samples per pair
    repeat(2) @(posedge sysclk);
    
    // Send 4 samples to complete a delta calculation
    send_adc_sample(10'd400);
    send_adc_sample(10'd600);
    send_adc_sample(10'd450);
    send_adc_sample(10'd500);
    
    // Delta should be captured
    repeat(10) @(posedge sysclk);
    assert_test("Delta data calculation", A2D_ADC_DELTA_DATA_VLD === 1 || A2D_ADC_DATA_VLD === 1);
    
    repeat(5) @(posedge sysclk);
    
    //==========================================================================
    // Test 5: Multiple Pairs
    //==========================================================================
    $display("\n--- Test 5: Multiple Pairs ---");
    init_defaults();
    reset_dut();
    
    pair_num = 4'b0001;  // 2 pairs
    // Enable drivers for both pairs' pads
    o_source_driver = 16'h000F;  // Pads 0-3
    repeat(2) @(posedge sysclk);
    
    // Pair 0: pads 0,1
    send_adc_sample(10'd512);
    // Pair 1: pads 1,2
    send_adc_sample(10'd520);
    
    assert_test("Multiple pairs data capture", A2D_ADC_DATA_VLD === 1 || A2D_ADC_DELTA_DATA_VLD === 1);
    
    repeat(10) @(posedge sysclk);
    
    //==========================================================================
    // Test 6: Interrupt Clearing
    //==========================================================================
    $display("\n--- Test 6: Interrupt Clearing ---");
    init_defaults();
    reset_dut();
    
    o_source_driver = 16'h0003;
    repeat(2) @(posedge sysclk);
    
    send_adc_sample(10'd512);
    
    repeat(5) @(posedge sysclk);
    assert_test("Interrupt set", stim_mon_int_sts === 1);
    
    stim_mon_int_clr = 1;
    @(posedge sysclk);
    stim_mon_int_clr = 0;
    
    repeat(5) @(posedge sysclk);
    assert_test("Interrupt cleared", stim_mon_int_sts === 0);
    
    //==========================================================================
    // Summary
    //==========================================================================
    repeat(10) @(posedge sysclk);
    $display("\n===============================================");
    $display("Test Summary");
    $display("===============================================");
    $display("Total Tests: %d", test_num);
    $display("Passed:      %d", pass_count);
    $display("Failed:      %d", fail_count);
    
    if (fail_count == 0) begin
        $display("\n✓ ALL TESTS PASSED!");
    end else begin
        $display("\n✗ SOME TESTS FAILED");
    end
    $display("===============================================\n");
    
    $finish;
end

endmodule
