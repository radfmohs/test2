module nirs_ppg_idac_ctrl #(
  parameter WIDTH = 16
) (
  input  wire               rst_n,        // Active-low reset
  input  wire               clk,          // Clock input
  input  wire               IDAC_MANUAL_EN,
  input  wire               IDAC_INCREASE,
  input  wire        [8:0]  IDAC_MANUAL,
  input  wire               EN,
  input  wire  [WIDTH-1:0]  DOUTF,
  input  wire     [21:0]    DOUT_AC,      // 16-bit unsigned input data
  input  wire     [18:0]    THRESHOLD_H,  // Upper threshold
  input  wire      [7:0]    THRESHOLD_L,  // Lower threshold

// FLags
  output wire               IDAC_MAX,
  output wire               IDAC_MIN,

// Output
  output wire        [8:0]  IDAC          // 8-bit output current DAC value
);

  reg [8:0] IDAC_reg;
  reg IDAC_MAX_reg, IDAC_MIN_reg;

  wire IDAC_MAX_tmp, IDAC_MIN_tmp;
  assign IDAC_MAX_tmp = (IDAC_reg == 9'h1FF);
  assign IDAC_MIN_tmp = (IDAC_reg == 9'h0);

// Sequential logic for hysteresis control with saturation
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      // Reset condition: Initialize IDAC_reg to 0
      IDAC_reg <= 9'b0;
    end else if (EN) begin
      // Check if DOUT_AC exceeds upper threshold
      if ((DOUT_AC > THRESHOLD_H) || (DOUTF == {WIDTH{1'b0}}) || (IDAC_INCREASE)) begin
        // Increment IDAC_reg but clamp at 255 (no overflow)
        if (!IDAC_MAX_tmp)
          IDAC_reg <= IDAC_reg + 1'b1;
      end 
      // Check if DOUT_AC is below lower threshold
      else if (DOUT_AC < THRESHOLD_L) begin
        // Decrement IDAC_reg but clamp at 0 (no underflow)
        if (!IDAC_MIN_tmp)
          IDAC_reg <= IDAC_reg - 1'b1;
      end
      // If within thresholds, IDAC_reg remains unchanged
    end
  end
  
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      IDAC_MAX_reg <= 1'b0;
    else if (IDAC_MAX_tmp)
      IDAC_MAX_reg <= 1'b1;
    else
      IDAC_MAX_reg <= 1'b0;
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      IDAC_MIN_reg <= 1'b1;
    else if (IDAC_MIN_tmp)
      IDAC_MIN_reg <= 1'b1;
    else
      IDAC_MIN_reg <= 1'b0;
  end


  assign IDAC_MAX = IDAC_MAX_reg;
  assign IDAC_MIN = IDAC_MIN_reg;
  assign IDAC     = IDAC_MANUAL_EN ? IDAC_MANUAL : IDAC_reg;

endmodule