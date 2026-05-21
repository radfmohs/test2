`timescale 1ns/1ps

module adc_cap_ctrl_tb;

  reg sysclk = 1'b0;
  reg presetn = 1'b0;
  reg scan_mode = 1'b0;

  reg bypass_adc_data_en = 1'b0;
  reg bypass_ignore_first = 1'b1;
  reg [3:0] stim_dly_tgt = 4'd0;
  reg [4:0] stim_mon_int_en = 5'd0;
  reg [4:0] stim_mon_int_topin_en = 5'd0;
  reg [1:0] stim_mon_delta_data_sel = 2'b00;
  reg [15:0] o_source_driver = 16'd0;
  reg [15:0] o_pulldn_driver = 16'd0;

  reg stim_mon_int_clr = 1'b0;
  wire stim_mon_int_sts;
  reg stim_mon_delta_int_clr = 1'b0;
  wire stim_mon_delta_int_sts;
  reg stim_mon_cycle_int_clr = 1'b0;
  wire stim_mon_cycle_int_sts;

  reg [15:0] stim_mon_leadoff_int_clr = 16'd0;
  wire [15:0] stim_mon_leadoff_int_sts;
  reg [15:0] stim_mon_short_int_clr = 16'd0;
  wire [15:0] stim_mon_short_int_sts;

  reg [9:0] threshold_leadoff = 10'd100;
  reg [9:0] threshold_short = 10'd20;
  reg [7:0] threshold_tgt = 8'd1;

  wire o_stim_mon_int;
  reg int_length_slct = 1'b0;

  reg adc_mode = 1'b0;
  reg [15:0] adc_cap_period = 16'd0;
  reg [3:0] pair_num = 4'd0;
  reg [15:0][3:0] stim_pad0_tgt;
  reg [15:0][3:0] stim_pad1_tgt;
  reg [9:0] A2D_ADC_DATA = 10'd0;
  reg A2D_ADC_DATA_EN = 1'b0;

  wire [3:0] D2A_STIM_PAD0;
  wire [3:0] D2A_STIM_PAD1;
  wire A2D_ADC_DATA_VLD;
  wire [15:0] A2D_ADC_DATA_TAG;
  wire A2D_ADC_DELTA_DATA_VLD;
  wire [15:0] A2D_ADC_DELTA_DATA_TAG;
  wire one_cycle_data_vld;
  wire [255:0] one_cycle_data;

  integer failures = 0;

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

  always #5 sysclk = ~sysclk;

  task automatic fail_msg(input [8*96-1:0] msg);
    begin
      failures = failures + 1;
      $display("FAIL: %0s @ %0t", msg, $time);
    end
  endtask

  task automatic expect_true(input bit cond, input [8*96-1:0] msg);
    begin
      if (!cond) begin
        fail_msg(msg);
      end
    end
  endtask

  task automatic expect_false(input bit cond, input [8*96-1:0] msg);
    begin
      if (cond) begin
        fail_msg(msg);
      end
    end
  endtask

  task automatic expect_u4(input [3:0] got, input [3:0] exp, input [8*96-1:0] msg);
    begin
      if (got !== exp) begin
        failures = failures + 1;
        $display("FAIL: %0s got=%0d exp=%0d @ %0t", msg, got, exp, $time);
      end
    end
  endtask

  task automatic expect_u16(input [15:0] got, input [15:0] exp, input [8*96-1:0] msg);
    begin
      if (got !== exp) begin
        failures = failures + 1;
        $display("FAIL: %0s got=0x%04h exp=0x%04h @ %0t", msg, got, exp, $time);
      end
    end
  endtask

  task automatic defaults;
    integer idx;
    begin
      scan_mode = 1'b0;
      bypass_adc_data_en = 1'b0;
      bypass_ignore_first = 1'b1;
      stim_dly_tgt = 4'd0;
      stim_mon_int_en = 5'd0;
      stim_mon_int_topin_en = 5'd0;
      stim_mon_delta_data_sel = 2'b00;
      o_source_driver = 16'd0;
      o_pulldn_driver = 16'd0;
      stim_mon_int_clr = 1'b0;
      stim_mon_delta_int_clr = 1'b0;
      stim_mon_cycle_int_clr = 1'b0;
      stim_mon_leadoff_int_clr = 16'd0;
      stim_mon_short_int_clr = 16'd0;
      threshold_leadoff = 10'd100;
      threshold_short = 10'd20;
      threshold_tgt = 8'd1;
      int_length_slct = 1'b0;
      adc_mode = 1'b0;
      adc_cap_period = 16'd0;
      pair_num = 4'd0;
      A2D_ADC_DATA = 10'd0;
      A2D_ADC_DATA_EN = 1'b0;
      for (idx = 0; idx < 16; idx = idx + 1) begin
        stim_pad0_tgt[idx] = idx[3:0];
        stim_pad1_tgt[idx] = (idx + 1) & 4'hf;
      end
    end
  endtask

  task automatic do_reset;
    begin
      defaults();
      presetn = 1'b0;
      repeat (3) @(posedge sysclk);
      #1;
      presetn = 1'b1;
      repeat (2) @(posedge sysclk);
      #1;
    end
  endtask

  task automatic send_sample(input [9:0] data, input bit en);
    begin
      @(negedge sysclk);
      A2D_ADC_DATA = data;
      A2D_ADC_DATA_EN = en;
      @(posedge sysclk);
      #1;
      A2D_ADC_DATA_EN = 1'b0;
    end
  endtask

  task automatic idle_cycles(input integer count);
    integer n;
    begin
      for (n = 0; n < count; n = n + 1) begin
        @(negedge sysclk);
        A2D_ADC_DATA_EN = 1'b0;
        @(posedge sysclk);
        #1;
      end
    end
  endtask

  task automatic wait_for_delta_vld;
    integer n;
    begin
      for (n = 0; n < 6; n = n + 1) begin
        if (A2D_ADC_DELTA_DATA_VLD) begin
          disable wait_for_delta_vld;
        end
        @(posedge sysclk);
        #1;
      end
    end
  endtask

  task automatic wait_for_cycle_vld;
    integer n;
    begin
      for (n = 0; n < 8; n = n + 1) begin
        if (one_cycle_data_vld) begin
          disable wait_for_cycle_vld;
        end
        @(posedge sysclk);
        #1;
      end
    end
  endtask

  task automatic test_manual_mode_sample;
    begin
      $display("TEST: manual mode sample capture");
      do_reset();
      stim_mon_int_en[1] = 1'b1;
      stim_mon_int_topin_en[1] = 1'b1;
      adc_mode = 1'b0;
      bypass_ignore_first = 1'b1;
      o_source_driver = 16'h0003;

      expect_u4(D2A_STIM_PAD0, 4'd0, "manual mode pad0 selects pair0");
      expect_u4(D2A_STIM_PAD1, 4'd1, "manual mode pad1 selects pair0");

      send_sample(10'h155, 1'b1);

      expect_true(A2D_ADC_DATA_VLD, "manual mode sample should be valid");
      expect_u16(A2D_ADC_DATA_TAG, {4'd0, 2'b00, 10'h155}, "manual sample tag");
      idle_cycles(2);
      expect_true(stim_mon_int_sts, "sample interrupt status should set");
      expect_true(o_stim_mon_int, "sample interrupt should reach pin");
      expect_false(A2D_ADC_DELTA_DATA_VLD, "manual mode should not emit delta data");
      expect_false(one_cycle_data_vld, "manual mode should not emit cycle data");

      stim_mon_int_clr = 1'b1;
      idle_cycles(1);
      stim_mon_int_clr = 1'b0;
      idle_cycles(4);
      expect_false(stim_mon_int_sts, "sample interrupt status should clear");
      expect_false(o_stim_mon_int, "sample interrupt pin should clear");
    end
  endtask

  task automatic test_ignore_first;
    begin
      $display("TEST: ignore first adc_data_en");
      do_reset();
      adc_mode = 1'b1;
      bypass_ignore_first = 1'b0;
      o_source_driver = 16'h0003;

      send_sample(10'h012, 1'b1);
      expect_false(A2D_ADC_DATA_VLD, "first adc_data_en should be ignored");

      send_sample(10'h123, 1'b1);
      expect_true(A2D_ADC_DATA_VLD, "second adc_data_en should be accepted");
      expect_u16(A2D_ADC_DATA_TAG, {4'd0, 2'b00, 10'h123}, "ignored-first captured data");
    end
  endtask

  task automatic test_bypass_adc_data_en;
    begin
      $display("TEST: bypass adc_data_en");
      do_reset();
      adc_mode = 1'b1;
      bypass_ignore_first = 1'b1;
      bypass_adc_data_en = 1'b1;
      o_source_driver = 16'h0003;

      send_sample(10'h1ab, 1'b0);
      expect_true(A2D_ADC_DATA_VLD, "bypass_adc_data_en should capture without data_en");
      expect_u16(A2D_ADC_DATA_TAG, {4'd0, 2'b00, 10'h1ab}, "bypass adc_data_en tag");
    end
  endtask

  task automatic test_stim_delay;
    begin
      $display("TEST: stim delay handling");
      do_reset();
      adc_mode = 1'b1;
      bypass_ignore_first = 1'b1;
      stim_dly_tgt = 4'd2;

      send_sample(10'h020, 1'b1);
      expect_false(A2D_ADC_DATA_VLD, "delay target should block first sample before stimulation");

      o_source_driver = 16'h0003;
      send_sample(10'h021, 1'b1);
      expect_false(A2D_ADC_DATA_VLD, "delay target should block first active cycle");

      send_sample(10'h022, 1'b1);
      expect_false(A2D_ADC_DATA_VLD, "delay target should block second active cycle");

      send_sample(10'h023, 1'b1);
      expect_true(A2D_ADC_DATA_VLD, "delay target should allow third active cycle");
      expect_u16(A2D_ADC_DATA_TAG, {4'd0, 2'b00, 10'h023}, "delay captured sample tag");
    end
  endtask

  task automatic test_delta_and_cycle;
    begin
      $display("TEST: delta output and cycle packing");
      do_reset();
      adc_mode = 1'b1;
      bypass_ignore_first = 1'b1;
      adc_cap_period = 16'd1;
      pair_num = 4'd1;
      stim_mon_delta_data_sel = 2'b00;
      stim_mon_int_en[2:0] = 3'b111;
      stim_mon_int_topin_en[2:0] = 3'b111;
      o_source_driver = 16'h000f;

      send_sample(10'd100, 1'b1);
      expect_true(A2D_ADC_DATA_VLD, "pair0 sample0 valid");
      send_sample(10'd300, 1'b1);
      expect_true(A2D_ADC_DATA_VLD, "pair0 sample1 valid");
      wait_for_delta_vld();
      expect_true(A2D_ADC_DELTA_DATA_VLD, "pair0 delta should become valid");
      expect_u16(A2D_ADC_DELTA_DATA_TAG, {4'd0, 2'b00, 10'd200}, "pair0 delta should include both samples");

      expect_u4(D2A_STIM_PAD0, 4'd1, "auto mode should advance to pair1 after pair0");
      expect_u4(D2A_STIM_PAD1, 4'd2, "auto mode pad1 should advance to pair1");

      send_sample(10'd400, 1'b1);
      expect_true(A2D_ADC_DATA_VLD, "pair1 sample0 valid");
      send_sample(10'd390, 1'b1);
      expect_true(A2D_ADC_DATA_VLD, "pair1 sample1 valid");
      wait_for_delta_vld();
      expect_true(A2D_ADC_DELTA_DATA_VLD, "pair1 delta should become valid");
      expect_u16(A2D_ADC_DELTA_DATA_TAG, {4'd1, 2'b00, 10'd10}, "pair1 delta should include both samples");

      wait_for_cycle_vld();
      expect_true(one_cycle_data_vld, "full cycle should become valid");
      expect_u16(one_cycle_data[31:16], {4'd0, 2'b00, 10'd200}, "cycle data should contain pair0 delta");
      expect_u16(one_cycle_data[15:0], {4'd1, 2'b00, 10'd10}, "cycle data should contain pair1 delta");
      idle_cycles(1);
      expect_true(stim_mon_delta_int_sts, "delta interrupt status should set");
      expect_true(stim_mon_cycle_int_sts, "cycle interrupt status should set");
      expect_true(o_stim_mon_int, "delta/cycle interrupt should reach pin");
    end
  endtask

  task automatic test_delta_select_modes;
    begin
      $display("TEST: delta selector modes and single-sample period");
      do_reset();
      adc_mode = 1'b1;
      bypass_ignore_first = 1'b1;
      adc_cap_period = 16'd0;
      pair_num = 4'd0;
      o_source_driver = 16'h0003;

      stim_mon_delta_data_sel = 2'b00;
      send_sample(10'd341, 1'b1);
      wait_for_delta_vld();
      expect_true(A2D_ADC_DELTA_DATA_VLD, "single-sample delta valid");
      expect_u16(A2D_ADC_DELTA_DATA_TAG, {4'd0, 2'b00, 10'd0}, "single-sample delta should be zero");

      stim_mon_delta_data_sel = 2'b01;
      send_sample(10'd111, 1'b1);
      wait_for_delta_vld();
      expect_u16(A2D_ADC_DELTA_DATA_TAG, {4'd0, 2'b00, 10'd111}, "min selector should return minimum sample");

      stim_mon_delta_data_sel = 2'b10;
      send_sample(10'd222, 1'b1);
      wait_for_delta_vld();
      expect_u16(A2D_ADC_DELTA_DATA_TAG, {4'd0, 2'b00, 10'd222}, "max selector should return maximum sample");

      stim_mon_delta_data_sel = 2'b11;
      send_sample(10'd333, 1'b1);
      wait_for_delta_vld();
      expect_u16(A2D_ADC_DELTA_DATA_TAG, {4'd0, 2'b00, 10'd333}, "last-sample selector should return captured sample");
    end
  endtask

  task automatic test_leadoff_status;
    begin
      $display("TEST: leadoff threshold across full capture window");
      do_reset();
      adc_mode = 1'b1;
      bypass_ignore_first = 1'b1;
      adc_cap_period = 16'd1;
      pair_num = 4'd0;
      stim_mon_int_en[3] = 1'b1;
      stim_mon_int_topin_en[3] = 1'b1;
      threshold_leadoff = 10'd100;
      threshold_tgt = 8'd1;
      o_source_driver = 16'h0003;

      send_sample(10'h200, 1'b1);
      send_sample(10'h3ff, 1'b1);
      idle_cycles(2);

      expect_true(stim_mon_leadoff_int_sts[0], "last leadoff sample should count toward pair status");
      idle_cycles(1);
      expect_true(o_stim_mon_int, "leadoff interrupt should reach pin");
    end
  endtask

  task automatic test_short_status;
    begin
      $display("TEST: short threshold across full capture window");
      do_reset();
      adc_mode = 1'b1;
      bypass_ignore_first = 1'b1;
      adc_cap_period = 16'd1;
      pair_num = 4'd0;
      stim_mon_int_en[4] = 1'b1;
      stim_mon_int_topin_en[4] = 1'b1;
      threshold_short = 10'd20;
      threshold_tgt = 8'd1;
      o_source_driver = 16'h0003;

      send_sample(10'h280, 1'b1);
      send_sample(10'h200, 1'b1);
      idle_cycles(2);

      expect_true(stim_mon_short_int_sts[0], "last short sample should count toward pair status");
      idle_cycles(1);
      expect_true(o_stim_mon_int, "short interrupt should reach pin");
    end
  endtask

  initial begin
    test_manual_mode_sample();
    test_ignore_first();
    test_bypass_adc_data_en();
    test_stim_delay();
    test_delta_and_cycle();
    test_delta_select_modes();
    test_leadoff_status();
    test_short_status();

    if (failures != 0) begin
      $display("RESULT: %0d checks failed", failures);
      $finish_and_return(1);
    end

    $display("RESULT: all adc_cap_ctrl checks passed");
    $finish_and_return(0);
  end

endmodule
