//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap ENS2  
// File name:    spi_cpha_cpol_slct.v 
// Module Name : spi_cpha_cpol_slct
// Description : to select sclk via cpha && cpol PAD
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author          Description      
//------------------------------------------------------------------------------
// 0.1       2023/11/20      Zhen Cao       Initial Rev 
//------------------------------------------------------------------------------

module spi_cpha_cpol_slct(

input wire iopad_cpha,	
input wire iopad_cpol,
input wire i_sclk,

output wire o_sclk_latch_in,
output wire o_sclk_latch_out 
//output wire o_sclk	
);

wire i_sclk_inv;
wire o_sclk; 

//assign i_sclk_inv = ~i_sclk;
CLKINV_X12_A7TULL DNT_SCK_INV (.Y(i_sclk_inv), .A(i_sclk));
assign o_sclk = ~(iopad_cpha ^ iopad_cpol) ? i_sclk_inv : i_sclk;

/*
assign o_sclk_latch_in  = (iopad_cpha ^ iopad_cpol) ? o_sclk : ~o_sclk;
assign o_sclk_latch_out = (iopad_cpha ^ iopad_cpol) ? ~o_sclk : o_sclk  ; //: o_sclk;  //o_sclk
*/

assign o_sclk_latch_in  = (iopad_cpha ^ iopad_cpol) ? ~i_sclk : ~o_sclk;
assign o_sclk_latch_out = (iopad_cpha ^ iopad_cpol) ? i_sclk : o_sclk  ; //: o_sclk;  //o_sclk

endmodule
