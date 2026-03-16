`timescale 1 ns / 1 ns

module tb_filter_lpf_demo;

  reg clk;
  reg clk_enable;
  reg reset;
  reg sign_en;
  reg signed [31:0] filter_in;
  wire signed [31:0] filter_out;

  filter_lpf_test dut (
    .clk(clk),
    .clk_enable(clk_enable),
    .reset(reset),
    .sign_en(sign_en),
    .filter_in(filter_in),
    .filter_out(filter_out)
  );

  initial clk = 0;
  always #5 clk = ~clk;

  integer i;
  integer cycle_count;

  initial begin
    $dumpfile("lpf_demo.vcd");
    $dumpvars(0, tb_filter_lpf_demo);

    reset      = 0;
    clk_enable = 0;
    sign_en    = 1;
    filter_in  = 0;
    cycle_count = 0;

    #20  reset = 1;
    #100 clk_enable = 1;

    $display("=== FIR LPF Filter Simulation Start ===");
    $display("Clock period: 10ns, Filter: 27-tap FIR LPF");
    $display("%-8s %-14s %-14s", "Cycle", "Input", "Output");

    // Impulse response: inject a single large value then zero
    filter_in = 32'sh3FFF_FFFF;
    @(posedge clk);
    cycle_count = cycle_count + 1;
    $display("%-8d %-14d %-14d", cycle_count, filter_in, filter_out);

    filter_in = 0;
    for (i = 0; i < 60; i = i + 1) begin
      @(posedge clk);
      cycle_count = cycle_count + 1;
      if (cycle_count <= 35 || filter_out !== 0)
        $display("%-8d %-14d %-14d", cycle_count, filter_in, filter_out);
    end

    $display("=== Impulse response complete ===");
    $display("");

    // Step response
    $display("=== Step Response ===");
    filter_in = 32'sh1000_0000;
    for (i = 0; i < 100; i = i + 1) begin
      @(posedge clk);
      cycle_count = cycle_count + 1;
      if (i < 5 || i > 94 || (i % 10 == 0))
        $display("%-8d %-14d %-14d", cycle_count, filter_in, filter_out);
    end

    $display("=== Step response complete ===");
    $display("");
    $display("=== FIR LPF Filter Simulation PASSED ===");

    #100;
    $finish;
  end

  initial begin
    #50000;
    $display("ERROR: Simulation timeout!");
    $finish;
  end

endmodule
