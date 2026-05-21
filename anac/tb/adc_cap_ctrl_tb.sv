//==============================================================================
// Test Bench for adc_cap_ctrl module
// Comprehensive test suite for ADC capture control functionality
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

// Stimulus pad target arrays (packed 2D arrays)
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

// Test status
integer test_count = 0;
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
    forever #5 sysclk = ~sysclk;  // 10ns period = 100 MHz
end

//==============================================================================
// Helper Tasks
//==============================================================================

task reset_dut();
    begin
        presetn = 0;
        #20;
        presetn = 1;
        #20;
    end
endtask

task init_defaults();
    begin
        bypass_adc_data_en = 0;
        bypass_ignore_first = 0;
        stim_dly_tgt = 4'b0;
        stim_mon_int_en = 5'b11111;
        stim_mon_int_topin_en = 5'b11111;
        stim_mon_delta_data_sel = 2'b00;  // delta mode
        adc_mode = 1'b1;  // auto mode
        adc_cap_period = 16'b0;  // single sample per pair
        pair_num = 4'b0001;  // 2 pairs
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
        
        // Initialize stimulus pad targets
        for (int i=0; i<16; i++) begin
            stim_pad0_tgt[i] = i;
            stim_pad1_tgt[i] = (i+1) % 16;
        end
    end
endtask

task test_pass(string test_name);
    begin
        pass_count = pass_count + 1;
        $display("[PASS] Test %d: %s", test_count, test_name);
    end
endtask

task test_fail(string test_name, string reason);
    begin
        fail_count = fail_count + 1;
        $display("[FAIL] Test %d: %s - %s", test_count, test_name, reason);
    end
endtask

task wait_clocks(int num_clocks);
    begin
        repeat(num_clocks) @(posedge sysclk);
    end
endtask

task stimulate_adc(input [9:0] adc_data);
    begin
        @(posedge sysclk);
        A2D_ADC_DATA = adc_data;
        A2D_ADC_DATA_EN = 1;
        @(posedge sysclk);
        A2D_ADC_DATA_EN = 0;
    end
endtask

task set_source_driver(input [15:0] driver_mask, input [3:0] pad0, input [3:0] pad1);
    begin
        o_source_driver = driver_mask;
        stim_pad0_tgt[0] = pad0;
        stim_pad1_tgt[0] = pad1;
        wait_clocks(2);
    end
endtask

//==============================================================================
// Test Cases
//==============================================================================

initial begin
    $display("===============================================");
    $display("ADC CAP CTRL Testbench - Starting Tests");
    $display("===============================================");
    
    init_defaults();
    reset_dut();
    
    //==========================================================================
    // Test 1: Basic Reset and Initialization
    //==========================================================================
    test_count = 1;
    begin
        $display("\n--- Test 1: Reset and Initialization ---");
        if (A2D_ADC_DATA_VLD === 0 && A2D_ADC_DELTA_DATA_VLD === 0) begin
            test_pass("Reset clears outputs");
        end else begin
            test_fail("Reset clears outputs", "Outputs not zero after reset");
        end
    end
    
    //==========================================================================
    // Test 2: Simple ADC Data Capture (Manual Mode)
    //==========================================================================
    test_count = 2;
    begin
        $display("\n--- Test 2: Simple ADC Data Capture (Manual Mode) ---");
        adc_mode = 1'b0;  // Manual mode
        o_source_driver = 16'h0001;  // Enable driver for first electrode
        wait_clocks(2);
        
        // First ADC sample
        stimulate_adc(10'd500);
        wait_clocks(2);
        
        // The first sample should be ignored (bypass_ignore_first=0)
        // Check if output is as expected
        if (A2D_ADC_DATA_VLD === 0) begin
            test_pass("First sample correctly ignored in manual mode");
        end else begin
            test_fail("First sample correctly ignored", "First sample not ignored");
        end
    end
    
    //==========================================================================
    // Test 3: Multi-Pair Auto Mode (2 pairs)
    //==========================================================================
    test_count = 3;
    begin
        $display("\n--- Test 3: Multi-Pair Auto Mode (2 pairs) ---");
        adc_mode = 1'b1;  // Auto mode
        pair_num = 4'b0001;  // 2 pairs
        bypass_ignore_first = 1'b1;  // Don't ignore first sample
        o_source_driver = 16'h0001;  // Enable driver
        wait_clocks(2);
        
        // First pair, first sample
        stimulate_adc(10'd512);
        wait_clocks(3);
        
        // Second pair should trigger delta int
        stimulate_adc(10'd520);
        wait_clocks(5);
        
        if (A2D_ADC_DELTA_DATA_VLD === 1) begin
            test_pass("Delta interrupt triggered after 2 pairs");
        end else begin
            test_fail("Delta interrupt triggered", "No delta interrupt after 2 pairs");
        end
    end
    
    //==========================================================================
    // Test 4: Lead-off Detection
    //==========================================================================
    test_count = 4;
    begin
        $display("\n--- Test 4: Lead-off Detection ---");
        init_defaults();
        adc_mode = 1'b1;
        pair_num = 4'b0001;  // 2 pairs
        bypass_ignore_first = 1'b1;
        threshold_leadoff = 10'd200;  // Low threshold to trigger
        threshold_tgt = 8'd1;  // Trigger after 1 sample
        o_source_driver = 16'h0001;
        wait_clocks(2);
        
        // ADC data far from mid-point (512) - should trigger leadoff
        stimulate_adc(10'd50);  // Far from 512
        wait_clocks(3);
        
        stimulate_adc(10'd50);
        wait_clocks(5);
        
        if (stim_mon_leadoff_int_sts[0] === 1) begin
            test_pass("Lead-off detection triggered");
        end else begin
            test_fail("Lead-off detection", "Lead-off not detected for extreme ADC value");
        end
    end
    
    //==========================================================================
    // Test 5: Short Detection
    //==========================================================================
    test_count = 5;
    begin
        $display("\n--- Test 5: Short Detection ---");
        init_defaults();
        adc_mode = 1'b1;
        pair_num = 4'b0001;  // 2 pairs
        bypass_ignore_first = 1'b1;
        threshold_short = 10'd30;  // Low threshold
        threshold_tgt = 8'd1;  // Trigger after 1 sample
        o_source_driver = 16'h0001;
        wait_clocks(2);
        
        // ADC data very close to mid-point (512)
        stimulate_adc(10'd512);  // Exactly mid-point
        wait_clocks(3);
        
        stimulate_adc(10'd512);
        wait_clocks(5);
        
        if (stim_mon_short_int_sts[0] === 1) begin
            test_pass("Short detection triggered");
        end else begin
            test_fail("Short detection", "Short not detected for ADC=512");
        end
    end
    
    //==========================================================================
    // Test 6: Stimulus Delay
    //==========================================================================
    test_count = 6;
    begin
        $display("\n--- Test 6: Stimulus Delay ---");
        init_defaults();
        adc_mode = 1'b1;
        pair_num = 4'b0001;
        bypass_ignore_first = 1'b1;
        stim_dly_tgt = 4'd2;  // 2-cycle delay
        o_source_driver = 16'h0000;
        wait_clocks(2);
        
        // Enable source driver
        o_source_driver = 16'h0001;
        wait_clocks(1);
        
        // ADC data should not be captured immediately due to delay
        stimulate_adc(10'd512);
        wait_clocks(1);
        
        if (A2D_ADC_DATA_VLD === 0) begin
            test_pass("Stimulus delay prevents early capture");
        end else begin
            test_fail("Stimulus delay", "Data captured before delay completed");
        end
        
        // Wait for delay to complete
        wait_clocks(3);
        stimulate_adc(10'd512);
        wait_clocks(2);
    end
    
    //==========================================================================
    // Test 7: Bypass ADC Enable
    //==========================================================================
    test_count = 7;
    begin
        $display("\n--- Test 7: Bypass ADC Enable ---");
        init_defaults();
        adc_mode = 1'b1;
        bypass_adc_data_en = 1'b1;  // Bypass ADC enable
        bypass_ignore_first = 1'b1;
        pair_num = 4'b0001;
        o_source_driver = 16'h0001;
        wait_clocks(2);
        
        // ADC_DATA_EN is not asserted, but should still work due to bypass
        A2D_ADC_DATA = 10'd512;
        A2D_ADC_DATA_EN = 0;  // Not asserted
        wait_clocks(2);
        
        if (A2D_ADC_DATA_VLD === 1) begin
            test_pass("Bypass ADC enable works");
        end else begin
            test_fail("Bypass ADC enable", "Data not captured with bypass enabled");
        end
    end
    
    //==========================================================================
    // Test 8: Delta Data Calculation (Max-Min)
    //==========================================================================
    test_count = 8;
    begin
        $display("\n--- Test 8: Delta Data Calculation (Max-Min) ---");
        init_defaults();
        adc_mode = 1'b1;
        pair_num = 4'b0000;  // 1 pair
        bypass_ignore_first = 1'b1;
        adc_cap_period = 16'd3;  // 4 samples per pair
        stim_mon_delta_data_sel = 2'b00;  // Delta mode (max-min)
        o_source_driver = 16'h0001;
        wait_clocks(2);
        
        // Generate ADC samples
        stimulate_adc(10'd400);  // Sample 1
        wait_clocks(1);
        stimulate_adc(10'd600);  // Sample 2
        wait_clocks(1);
        stimulate_adc(10'd450);  // Sample 3
        wait_clocks(1);
        stimulate_adc(10'd550);  // Sample 4
        wait_clocks(3);
        
        // Expected delta = 600 - 400 = 200
        if (A2D_ADC_DELTA_DATA_VLD === 1) begin
            test_pass("Delta data calculation completed");
        end else begin
            test_fail("Delta data calculation", "No delta data output");
        end
    end
    
    //==========================================================================
    // Test 9: Interrupt Clearing
    //==========================================================================
    test_count = 9;
    begin
        $display("\n--- Test 9: Interrupt Clearing ---");
        init_defaults();
        adc_mode = 1'b1;
        pair_num = 4'b0001;
        bypass_ignore_first = 1'b1;
        o_source_driver = 16'h0001;
        wait_clocks(2);
        
        // Generate data to trigger interrupt
        stimulate_adc(10'd512);
        wait_clocks(2);
        stimulate_adc(10'd512);
        wait_clocks(5);
        
        // Interrupt should be set
        if (stim_mon_int_sts === 1) begin
            test_pass("Interrupt triggered");
            
            // Clear interrupt
            stim_mon_int_clr = 1;
            wait_clocks(2);
            stim_mon_int_clr = 0;
            wait_clocks(3);
            
            if (stim_mon_int_sts === 0) begin
                test_pass("Interrupt cleared successfully");
            end else begin
                test_fail("Interrupt clearing", "Interrupt not cleared");
            end
        end else begin
            test_fail("Interrupt triggering", "Interrupt not triggered");
        end
    end
    
    //==========================================================================
    // Test 10: Multiple Stimulus Pads
    //==========================================================================
    test_count = 10;
    begin
        $display("\n--- Test 10: Multiple Stimulus Pads ---");
        init_defaults();
        adc_mode = 1'b1;
        pair_num = 4'b0011;  // 4 pairs
        bypass_ignore_first = 1'b1;
        o_source_driver = 16'h0001;
        
        // Set different pad targets for each pair
        for (int i=0; i<4; i++) begin
            stim_pad0_tgt[i] = i;
            stim_pad1_tgt[i] = i+1;
        end
        wait_clocks(2);
        
        // Run through pairs
        for (int i=0; i<5; i++) begin
            stimulate_adc(10'd512);
            wait_clocks(2);
        end
        
        if (one_cycle_data_vld === 1) begin
            test_pass("Multiple pairs cycle completed");
        end else begin
            test_fail("Multiple pairs", "Cycle not completed for 4 pairs");
        end
    end
    
    //==========================================================================
    // Test 11: Edge Case - ADC data at boundaries
    //==========================================================================
    test_count = 11;
    begin
        $display("\n--- Test 11: ADC Data at Boundaries ---");
        init_defaults();
        adc_mode = 1'b1;
        pair_num = 4'b0001;
        bypass_ignore_first = 1'b1;
        o_source_driver = 16'h0001;
        wait_clocks(2);
        
        // Test at 0
        stimulate_adc(10'd0);
        wait_clocks(2);
        stimulate_adc(10'd0);
        wait_clocks(3);
        
        if (A2D_ADC_DATA_VLD === 1) begin
            test_pass("ADC=0 handled correctly");
        end else begin
            test_fail("ADC boundary", "ADC=0 not handled");
        end
        
        // Test at 1023
        stimulate_adc(10'd1023);
        wait_clocks(2);
        stimulate_adc(10'd1023);
        wait_clocks(3);
        
        if (A2D_ADC_DATA_VLD === 1) begin
            test_pass("ADC=1023 handled correctly");
        end else begin
            test_fail("ADC boundary", "ADC=1023 not handled");
        end
    end
    
    //==========================================================================
    // Test 12: Pair Counter Wraparound
    //==========================================================================
    test_count = 12;
    begin
        $display("\n--- Test 12: Pair Counter Wraparound ---");
        init_defaults();
        adc_mode = 1'b1;
        pair_num = 4'b1111;  // 16 pairs (maximum)
        bypass_ignore_first = 1'b1;
        o_source_driver = 16'h0001;
        wait_clocks(2);
        
        // Run through 17 samples to test wraparound
        for (int i=0; i<17; i++) begin
            stimulate_adc(10'd512);
            wait_clocks(1);
        end
        
        // After 16 pairs, counter should wrap
        if (one_cycle_data_vld === 1) begin
            test_pass("Pair counter wraparound at maximum (16 pairs)");
        end else begin
            test_fail("Pair counter wraparound", "Counter didn't wrap at 16 pairs");
        end
    end
    
    //==========================================================================
    // Test 13: adc_cap_period = max value
    //==========================================================================
    test_count = 13;
    begin
        $display("\n--- Test 13: High ADC Capture Period ---");
        init_defaults();
        adc_mode = 1'b1;
        pair_num = 4'b0000;  // 1 pair
        bypass_ignore_first = 1'b1;
        adc_cap_period = 16'hFFFF;  // Very high value
        o_source_driver = 16'h0001;
        wait_clocks(2);
        
        // Send many samples
        for (int i=0; i<10; i++) begin
            stimulate_adc(10'd512);
            wait_clocks(1);
        end
        
        // Should still capture at least one
        if (A2D_ADC_DATA_VLD === 1) begin
            test_pass("High ADC capture period handled");
        end else begin
            test_fail("ADC capture period", "No data captured with high period");
        end
    end
    
    //==========================================================================
    // Summary
    //==========================================================================
    wait_clocks(10);
    $display("\n===============================================");
    $display("Test Summary");
    $display("===============================================");
    $display("Total Tests:  %d", test_count);
    $display("Passed:       %d", pass_count);
    $display("Failed:       %d", fail_count);
    
    if (fail_count == 0) begin
        $display("Result: ALL TESTS PASSED!");
    end else begin
        $display("Result: SOME TESTS FAILED!");
    end
    $display("===============================================\n");
    
    $finish;
end

endmodule

