//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap ENS2  
// File name:    nirs_ppg_idac_ctrl.v 
// Module Name : nirs_ppg_idac_ctrl
// Description : 
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author          Description      
//------------------------------------------------------------------------------
// 0.1                                      Initial Rev 
//------------------------------------------------------------------------------
module nirs_ppg_idac_ctrl #(
  parameter WIDTH = 16
) (
  input               rst_n,        // Active-low reset
  input               clk,          // Clock input
  input               EN,
  input  [WIDTH-1:0]  DOUTF,
  input     [19-1:0]  DOUT_AC,      // 16-bit unsigned input data
  input     [19-1:0]  THRESHOLD_H,  // Upper threshold
  input     [19-1:0]  THRESHOLD_L,  // Lower threshold
  output wire  [8:0]  IDAC          // 8-bit output current DAC value
);

  reg [8:0] IDAC_reg;

// Sequential logic for hysteresis control with saturation
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      // Reset condition: Initialize IDAC_reg to 0
      IDAC_reg <= 9'b0;
    end else if (EN) begin
      // Check if DOUT_AC exceeds upper threshold
      if ((DOUT_AC > THRESHOLD_H) || (DOUTF == {WIDTH{1'b0}})) begin
        // Increment IDAC_reg but clamp at 255 (no overflow)
        IDAC_reg <= (IDAC_reg == 9'h1FF) ? 9'h1FF : IDAC_reg + 1'b1;
      end 
      // Check if DOUT_AC is below lower threshold
      else if (DOUT_AC < THRESHOLD_L) begin
        // Decrement IDAC_reg but clamp at 0 (no underflow)
        IDAC_reg <= (IDAC_reg == 9'h0) ?  9'h0    : IDAC_reg - 1'b1;
      end
      // If within thresholds, IDAC_reg remains unchanged
    end
  end

  assign IDAC = IDAC_reg;

endmodule
