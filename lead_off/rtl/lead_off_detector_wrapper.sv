//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap ENS2   
// File name:    lead_off_detector_wrapper.v 
// Module Name : LEAD OFF WRAPPER
// Description : 
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author          Description      
//------------------------------------------------------------------------------
// 0.1                                      Initial Rev 
//------------------------------------------------------------------------------

`timescale 1 ns /  1 ps

module lead_off_detector_wrapper #(
parameter 
	NO_OF_WAVEGEN = 8 
)(

  spi_leadoff.slave    spi_leadoff,
  input wire                     i_pclk,
  input wire                     i_presetn,

  input wire [NO_OF_WAVEGEN-1 :0 ] A2D_STIMU0_15,         
  input wire [NO_OF_WAVEGEN-1 :0 ] A2D_COMP0_7,   

  input  wire  [NO_OF_WAVEGEN-1:0]  drive_en,   

  output wire   o_lead_off_int   

  );


  wire  [NO_OF_WAVEGEN-1:0]  o_lead_off_int_tmp;   
  assign   o_lead_off_int = |o_lead_off_int_tmp;  

genvar i;
generate 
  for(i=0;i<NO_OF_WAVEGEN;i=i+1) begin :lead_off_block

lead_off_detector u_lead_off_detector(
  .i_pclk	(i_pclk),
  .i_presetn	(i_presetn),

  .timer_cnt_tgt	(spi_leadoff.timer_cnt_tgt[i]),
  .counter_th_tgt	(spi_leadoff.counter_th_tgt[i]),
  .lead_off_stop_en	(spi_leadoff.lead_off_stop_en[i]),
  .lead_off_int_en	(spi_leadoff.lead_off_int_en[i]),
  .lead_off_sts_clear	(spi_leadoff.lead_off_sts_clear[i]),
  .dac_en_in	(spi_leadoff.dac_en_in[i]),
  .drive_en	(drive_en[i]),
  .sel_stim 	(spi_leadoff.sel_stim),
  .int_length_slct	(spi_leadoff.int_length_slct),
  .comp_low_en	(spi_leadoff.comp_low_en[i]),
  .A2D_STIMU0_1	(A2D_STIMU0_15[i]),
  .A2D_COMP1	(A2D_COMP0_7[i]),

  .lead_off_stop	(spi_leadoff.lead_off_stop[i]),
  .lead_off_result	(spi_leadoff.lead_off_result[i]),
  .o_lead_off_int	(o_lead_off_int_tmp[i]),
  .lead_off_Counter_cnt_dac0_final_dbg	(spi_leadoff.lead_off_Counter_cnt_dac0_final_dbg[i]),
  .lead_off_Counter_cnt_dac0_dbg	(spi_leadoff.lead_off_Counter_cnt_dac0_dbg[i])
);

 end
endgenerate


endmodule

