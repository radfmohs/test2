//==============================================================================
// Test Bench for adc_cap_ctrl module - Version 2 with diagnostics
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

//==============================================================================
// Diagnostic Test Cases
//==============================================================================

initial begin
    $display("===============================================");
    $display("ADC CAP CTRL Testbench - Diagnostic Tests");
    $display("===============================================");
    
    init_defaults();
    reset_dut();
    
    //==========================================================================
    // Diagnostic Test 1: Detailed bypass_adc_data_en behavior
    //==========================================================================
    test_count = 1;
    begin
        $display("\n--- Diagnostic Test 1: bypass_adc_data_en behavior ---");
        
        init_defaults();
        adc_mode = 1'b1;
        bypass_adc_data_en = 1'b1;
        bypass_ignore_first = 1'b1;
        pair_num = 4'b0000;  // 1 pair
        o_source_driver = 16'h0001;
        wait_clocks(2);
        
        // Monitor signals for 20 clocks
        for (int i=0; i<20; i++) begin
            A2D_ADC_DATA = 10'd512;
            A2D_ADC_DATA_EN = 0;  // Not asserted
            wait_clocks(1);
            
            $display("  Clock %2d: ADC_DATA_VLD=%b, DELTA_DATA_VLD=%b, one_cycle_vld=%b, D2A_STIM_PAD0=%d, D2A_STIM_PAD1=%d",
                i, A2D_ADC_DATA_VLD, A2D_ADC_DELTA_DATA_VLD, one_cycle_data_vld, D2A_STIM_PAD0, D2A_STIM_PAD1);
        end
    end
    
    //==========================================================================
    // Diagnostic Test 2: Active stimulation signal analysis
    //==========================================================================
    test_count = 2;
    begin
        $display("\n--- Diagnostic Test 2: Active stimulation signal analysis ---");
        
        init_defaults();
        reset_dut();
        adc_mode = 1'b1;
        bypass_ignore_first = 1'b1;
        pair_num = 4'b0001;  // 2 pairs
        o_source_driver = 16'h0000;  // No source driver initially
        
        wait_clocks(2);
        
        // Enable source driver
        o_source_driver = 16'h0001;
        wait_clocks(1);
        
        // Monitor for 15 clocks
        for (int i=0; i<15; i++) begin
            A2D_ADC_DATA = 10'd512;
            A2D_ADC_DATA_EN = (i == 5) ? 1 : 0;  // ADC valid at clock 5
            wait_clocks(1);
            
            $display("  Clock %2d: source_drv=%h, D2A_PAD0=%d, ADC_EN=%b, ADC_VLD=%b, DELTA_VLD=%b",
                i, o_source_driver, D2A_STIM_PAD0, A2D_ADC_DATA_EN, A2D_ADC_DATA_VLD, A2D_ADC_DELTA_DATA_VLD);
        end
    end
    
    //==========================================================================
    // Diagnostic Test 3: Multi-pair behavior in detail
    //==========================================================================
    test_count = 3;
    begin
        $display("\n--- Diagnostic Test 3: Multi-pair behavior ---");
        
        init_defaults();
        reset_dut();
        adc_mode = 1'b1;
        bypass_ignore_first = 1'b1;
        pair_num = 4'b0011;  // 4 pairs
        o_source_driver = 16'h0001;
        wait_clocks(2);
        
        // Send 5 samples to complete one cycle
        for (int i=0; i<5; i++) begin
            A2D_ADC_DATA = 10'd512 + i;
            A2D_ADC_DATA_EN = 1;
            wait_clocks(1);
            A2D_ADC_DATA_EN = 0;
            
            wait_clocks(1);
            $display("  Sample %d: ADC_VLD=%b, DELTA_VLD=%b, cycle_vld=%b",
                i, A2D_ADC_DATA_VLD, A2D_ADC_DELTA_DATA_VLD, one_cycle_data_vld);
        end
        
        // Wait additional clocks to see delayed outputs
        wait_clocks(10);
        $display("  After wait: DELTA_VLD=%b, cycle_vld=%b", A2D_ADC_DELTA_DATA_VLD, one_cycle_data_vld);
    end
    
    //==========================================================================
    // Diagnostic Test 4: Lead-off/Short detection with actual ADC values
    //==========================================================================
    test_count = 4;
    begin
        $display("\n--- Diagnostic Test 4: Lead-off/Short detection ---");
        
        init_defaults();
        reset_dut();
        adc_mode = 1'b1;
        bypass_ignore_first = 1'b1;
        pair_num = 4'b0000;  // 1 pair
        adc_cap_period = 16'd2;  // 3 samples per pair
        threshold_leadoff = 10'd200;
        threshold_short = 10'd30;
        threshold_tgt = 8'd2;
        o_source_driver = 16'h0001;
        wait_clocks(2);
        
        // Send samples at various values
        reg [9:0] test_values[0:5] = '{10'd50, 10'd100, 10'd900, 10'd950, 10'd512, 10'd520};
        
        for (int i=0; i<6; i++) begin
            A2D_ADC_DATA = test_values[i];
            A2D_ADC_DATA_EN = 1;
            wait_clocks(1);
            A2D_ADC_DATA_EN = 0;
            wait_clocks(1);
            
            // Check absolute delta
            reg [9:0] abs_delta;
            if (test_values[i] >= 10'h200)
                abs_delta = test_values[i] - 10'h200;
            else
                abs_delta = 10'h200 - test_values[i];
            
            $display("  Sample %d: ADC=%4d (delta from 512: %3d), leadoff=%b, short=%b, leadoff_sts=%b, short_sts=%b",
                i, test_values[i], abs_delta, 
                (abs_delta >= threshold_leadoff), (abs_delta <= threshold_short),
                stim_mon_leadoff_int_sts[0], stim_mon_short_int_sts[0]);
        end
    end
    
    //==========================================================================
    // Summary
    //==========================================================================
    wait_clocks(10);
    $display("\n===============================================");
    $display("Diagnostic Tests Complete");
    $display("===============================================\n");
    
    $finish;
end

endmodule

