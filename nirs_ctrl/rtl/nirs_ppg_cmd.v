module nirs_ppg_cmd (
  input  wire rst_n,
  input  wire clk_sys, // Max: 2MHz 

  input wire  [1:0] CMD,
  input wire        NIRS_SINGLE,

  output wire NIRS_PPG_EN,
  output wire NIRS_PPG_MEAS
); 
  reg   NIRS_PPG_EN_d;
  reg   NIRS_PPG_MEAS_d;
  wire  START, MEAS, STOP, START_tmp;
  /*
    CMD:
      00: HOLD - NOTHING
      01: START
      10: MEAS - MCU MASTER ONLY
      11: STOP 
  */
  assign START_tmp  = (CMD == 2'b01);
  assign MEAS       = (CMD == 2'b10);
  assign STOP       = (CMD == 2'b11);

  common_pulse_rising #(.RST_VAL(0)) u_read_rising_detect (
    .d_in   (START_tmp),
    .clk    (clk_sys),
    .rst_   (rst_n),
    .d_out  (START)
  );

  always  @(posedge clk_sys or negedge rst_n) begin
    if (!rst_n) begin
      NIRS_PPG_EN_d  <= 1'b0;
    end else if (START) begin
      NIRS_PPG_EN_d  <= 1'b1;
    end else if (STOP || NIRS_SINGLE) begin
      NIRS_PPG_EN_d  <= 1'b0; 
    end else begin
      NIRS_PPG_EN_d  <= NIRS_PPG_EN_d;
    end
  end

  always @(posedge clk_sys or negedge rst_n) begin
    if (!rst_n) begin
      NIRS_PPG_MEAS_d <= 1'b0;
    end else if (MEAS) begin
      NIRS_PPG_MEAS_d <= 1'b1;
    end else begin
      NIRS_PPG_MEAS_d <= 1'b0; 
    end
  end

  assign NIRS_PPG_EN    = NIRS_PPG_EN_d;
  assign NIRS_PPG_MEAS  = NIRS_PPG_MEAS_d;

endmodule