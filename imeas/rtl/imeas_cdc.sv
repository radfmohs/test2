//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap Glucose Chip   
// File name:    imeas_cdc.v 
// Module Name : imeas_cdc
// Description : 
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author          Description      
//------------------------------------------------------------------------------
// 0.1        05/21/2019  Daniel Wang       Initial Rev 
//------------------------------------------------------------------------------

module imeas_cdc(
  input  wire  pclk,
  input  wire  adc_clk,
  input  wire  preset_n,
  input  wire  atpg_en,
  input  wire  sd16eoc,
//input  wire  cic_rst,
//output wire  cic_rst_n,
  output wire  sd16eoc_sync
);

//wire cic_rst_atpg_n;
common_bit_sync u_sd16eoc_sync(
  .i_async_in(sd16eoc),
  .i_clk(pclk),
  .i_rst_n(preset_n),
  .o_sync_out(sd16eoc_sync)
);

/*
assign cic_rst_atpg_n = atpg_en ? preset_n : (preset_n & ~cic_rst);

common_rst_sync u_cic_rst_sync(
  .RSTINn    (cic_rst_atpg_n),
  .RSTREQ    (1'b0),
  .CLK       (adc_clk),
  .SE        (atpg_en),
  .RSTBYPASS (atpg_en),
  .RSTOUTn   (cic_rst_n)
);
*/

//assign cic_rst_n = cic_rst_atpg_n;

endmodule
