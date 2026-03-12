//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap ENS2  
// File name:    nirs_ppg_subtract_dout.v 
// Module Name : nirs_ppg_subtract_dout
// Description : 
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author          Description      
//------------------------------------------------------------------------------
// 0.1                                      Initial Rev 
//------------------------------------------------------------------------------
module nirs_ppg_subtract_dout #(
  parameter IN_WDTH   = 13,
  parameter OUT_WIDTH = 19
) ( 
  input  wire                   rst_n,   // Active-low reset (optional)
  input  wire                   clk,     // Clock signal
  input  wire                   en,
  input  wire   [IN_WDTH-1:0]   DOUTF,   // 13-bit input
  input  wire   [IN_WDTH-1:0]   DOUTC,   // 13-bit input
  input  wire           [7:0]   RATIO,   // 7-bit input
  output wire [OUT_WIDTH-1:0]   DOUT     // 20-bit registered output
);

// Calculate: (RATIO * DOUTC) - DOUTF
// Zero-extend DOUTF to 20 bits for correct subtraction
wire[18:0] sub_result;
reg [18:0] DOUT_reg;

assign sub_result = (RATIO * DOUTC) - DOUTF;

// Update DOUT synchronously on rising clock edge
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        DOUT_reg <= {OUT_WIDTH{1'b0}};          // Reset to 0 (optional)
    end else if (en) begin
        DOUT_reg <= sub_result;     // Assign result to DOUT
    end
end

assign DOUT = DOUT_reg;

endmodule
