//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap ENS2  
// File name:    nirs_ppg_latch.v 
// Module Name : nirs_ppg_latch
// Description : 
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author          Description      
//------------------------------------------------------------------------------
// 0.1                                      Initial Rev 
//------------------------------------------------------------------------------
module nirs_ppg_latch #(
  parameter LATCH_WIDTH = 13
) (
  input  wire                   rst_n,
  input  wire                   clk,
  input  wire                   en,
  input  wire [LATCH_WIDTH-1:0] in,
  output wire [LATCH_WIDTH-1:0] out
);

  reg [LATCH_WIDTH-1:0] latch_reg;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      latch_reg <= {LATCH_WIDTH{1'b0}};
    end else if (en) begin
      latch_reg <= in;
    end
  end

  assign out = latch_reg;

endmodule
