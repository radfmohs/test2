module nirs_ppg_cmd (
  input  wire rst_n,
  input  wire atpg_en,
  input  wire clk_gate_bypass,
  input  wire i_clk_sys, // 2MHz
  input  wire i_clk_ppg,
  output wire o_clk_sys_gated,
  output wire o_clk_ppg_gated, 

  input wire  [1:0] CMD,
  input wire        NIRS_SINGLE,

  output wire       NIRS_PPG_EN,
  output wire       NIRS_PPG_MEAS,
  input  wire       CLK_STOP
); 
  reg   NIRS_PPG_EN_d;
  reg   NIRS_PPG_MEAS_d;
  wire  STOP, START_tmp, MEAS_tmp;
  /*
    CMD:
      00: HOLD - NOTHING
      01: START
      10: MEAS - MCU MASTER ONLY
      11: STOP 
  */
  assign START_tmp  = (CMD == 2'b01);
  assign MEAS_tmp   = (CMD == 2'b10);
  assign STOP       = (CMD == 2'b11);

  reg START_tmp_d, START, START_d;
  always @ (posedge i_clk_sys or negedge rst_n) begin
    if (~rst_n) begin
      START_tmp_d <= 1'b0;
      START_d     <= 1'b0;
    end else begin 
      START_tmp_d <= START_tmp;
      START_d     <= START;
    end
  end

  assign START = !START_tmp_d & START_tmp;  // START local clock

  reg MEAS_tmp_d, MEAS, MEAS_d;
  always @ (posedge i_clk_sys or negedge rst_n) begin
    if (~rst_n) begin
      MEAS_tmp_d  <= 1'b0;
      MEAS_d      <= 1'b0;
    end else begin 
      MEAS_tmp_d  <= MEAS_tmp;
      MEAS_d      <= MEAS;
    end
  end

  assign MEAS = !MEAS_tmp_d & MEAS_tmp;  // RESUME local clock

/*
  ENABLE cmd from user starts the clks
  CLK will stop when counter from the ctrl either completely stop or hold
  MEAS cmd can resume the clks
*/
  nirs_ppg_clk u_nirs_ppg_clk (
    .rst_n          (rst_n),
    .atpg_en        (atpg_en),
    .bypass         (clk_gate_bypass),
    .i_clk_sys      (i_clk_sys),
    .i_clk_ppg      (i_clk_ppg),
    .o_clk_sys      (o_clk_sys_gated),
    .o_clk_ppg      (o_clk_ppg_gated),
    .CLK_START      (START || MEAS),
    .CLK_STOP       (CLK_STOP)
  );

// Start the NIRS CTRL
  always  @(posedge o_clk_sys_gated or negedge rst_n) begin
    if (!rst_n) begin
      NIRS_PPG_EN_d  <= 1'b0;
    end else if (START_d) begin
      NIRS_PPG_EN_d  <= 1'b1;
    end else if (STOP || NIRS_SINGLE) begin
      NIRS_PPG_EN_d  <= 1'b0; 
    end else begin
      NIRS_PPG_EN_d  <= NIRS_PPG_EN_d;
    end
  end

  always @(posedge o_clk_sys_gated or negedge rst_n) begin
    if (!rst_n) begin
      NIRS_PPG_MEAS_d <= 1'b0;
    end else if (MEAS_d) begin
      NIRS_PPG_MEAS_d <= 1'b1;
    end else begin
      NIRS_PPG_MEAS_d <= 1'b0; 
    end
  end

  assign NIRS_PPG_EN    = NIRS_PPG_EN_d;
  assign NIRS_PPG_MEAS  = NIRS_PPG_MEAS_d;

endmodule