//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap ENS2  
// File name:    nirs_ppg_counter.v 
// Module Name : nirs_ppg_counter
// Description : 
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author          Description      
//------------------------------------------------------------------------------
// 0.1                                      Initial Rev 
//------------------------------------------------------------------------------

module nirs_ppg_counter #(
  parameter COUNTER_WIDTH = 13
) (
  input   rst_n, // system reset
  input   clk,
  input   RESET,
  input   enable,
  output wire [COUNTER_WIDTH-1:0] out
);

  reg [COUNTER_WIDTH-1:0] counter_reg;

  wire count_rst_n;
  assign count_rst_n = (rst_n & ~RESET);

  always @(posedge clk or negedge count_rst_n) begin
    if (!count_rst_n) begin
      counter_reg <= {COUNTER_WIDTH{1'b0}};
    end else if (enable) begin
      counter_reg <= counter_reg + 1;
    end
  end

  assign out = counter_reg;


endmodule  
