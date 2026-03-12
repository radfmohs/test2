`timescale 1us/1us

module kaiser_fir_19taps_tb;

    // Parameters
    localparam integer CLK_PERIOD = 62; // 16 kHz => 62.5 us
    localparam integer SAMPLE_COUNT = 600; // Number of samples to simulate
    localparam integer SEGMENT = SAMPLE_COUNT / 3; // Each segment length

    // Clock and reset
    reg clk = 0;
    reg rst = 1;

    // Input and output
    reg  [31:0] data_in;
    wire [31:0] data_out;

    // FIR filter module
    kaiser_fir_19taps dut (
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .data_out(data_out)
    );

    // Test signal generation
    integer i;
    real t; // time in seconds
    real sin_val; // Declare at module level

    // Frequencies
    localparam real FREQ1 = 512.0;   // below cutoff
    localparam real FREQ2 = 2048.0;  // above cutoff
    localparam real FS    = 16000.0; // sample rate

    // Fixed-point conversion
    function [31:0] real_to_fixed;
        input real val;
        begin
            // Q1.31 format: [-1,1) maps to [-2^31,2^31-1]
            real_to_fixed = $rtoi(val * (2.0**31-1));
        end
    endfunction

    // Clock generation
    always #(CLK_PERIOD/2) clk = ~clk;

    initial begin
        // Enable VPD dumping
        $vcdpluson;
        $vcdplusmemon;
        $vcdplusfile("wave.vpd");

        // Reset
        rst = 1;
        #(2*CLK_PERIOD);
        rst = 0;

        // Test
        for (i = 0; i < SAMPLE_COUNT; i = i + 1) begin
            t = i / FS; // time in seconds

            if (i < SEGMENT) begin
                // First segment: below cutoff sine
                sin_val = $sin(2.0 * 3.1415926535 * FREQ1 * t);
            end else if (i < 2*SEGMENT) begin
                // Middle segment: silence
                sin_val = 0.0;
            end else begin
                // Last segment: above cutoff sine
                sin_val = $sin(2.0 * 3.1415926535 * FREQ2 * t);
            end

            data_in = real_to_fixed(sin_val);

            #(CLK_PERIOD); // wait for next clock
        end

        // Wait a bit then stop
        #(20*CLK_PERIOD);
        $vcdplusoff;
        $finish;
    end

    // Optionally, print output for inspection
    always @(posedge clk) begin
        if (!rst) begin
            $display("t=%0d us, data_in=%0d, data_out=%0d", $time, data_in, data_out);
        end
    end
endmodule
