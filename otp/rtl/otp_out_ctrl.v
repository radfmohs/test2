/*--------------------------------------------------------------------------------------*/
/*      Nanochap Confidential                                                           */
/*--------------------------------------------------------------------------------------*/
/* File Name	 : otp_out_ctrl.v                                                       */
/* Project	 : ENS1P4 Chip                                                          */
/* Designer	 : zhen                                                                 */
/* Description	 : otp controller read/write control logic                              */
/* Date		 : 1/4/2024                                                             */
/*--------------------------------------------------------------------------------------*/
/* Revision History :                                                                   */    
/* Data         Rev.     By             Description                                     */
/*--------------------------------------------------------------------------------------*/
/* 9/1/2024     1       zhen           otp controller read/write control logic          */
/*--------------------------------------------------------------------------------------*/

module otp_out_ctrl (
   input wire clk,
   input wire reset_n,
   input wire wr_enter_h_en,
   input wire wr_enter_l_en,
   input wire wr_vpp_l_en,
   input wire read_h_en,
   input wire read_l_en,
   input wire wr_h_en,
   input wire wr_l_en,
   input wire [6:0] otp_inf_epm_adr,
   input wire [7:0] otp_inf_spi_wdata,
   input wire [7:0] otp_inf_sha_wdata,
   input wire       analog_test_mode_sync,
   output reg otp_wr_enter,
   output reg otp_vpp_en,
   output reg otp_READ,
   output reg otp_WR,
   output [6:0] otp_ADR,
//   output otp_OTP,
   output [7:0] otp_DIN

);

//internal signals
reg otp_inf_eprom_rw_stage;

// OTP ADR control
assign otp_ADR =  otp_inf_epm_adr;

// OTP DATA control
assign otp_DIN = analog_test_mode_sync? ~otp_inf_sha_wdata : ~otp_inf_spi_wdata;//OTP DIN  control

//OTP CS control
always @ (posedge clk or negedge reset_n)
       if (~reset_n) otp_wr_enter <= 1'b0;
       else if (wr_enter_h_en) otp_wr_enter <= 1'b1;
       else if (wr_enter_l_en) otp_wr_enter <= 1'b0;       

always @ (posedge clk or negedge reset_n)
       if (~reset_n) otp_vpp_en <= 1'b0;
       else if (wr_enter_h_en) otp_vpp_en <= 1'b1;
       else if (wr_vpp_l_en) otp_vpp_en <= 1'b0;
       
//OTP read control
always @ (posedge clk or negedge reset_n)
       if (~reset_n) otp_READ <= 1'b0;
       else if (read_h_en) otp_READ <= 1'b1;
       else if (read_l_en) otp_READ <= 1'b0;

//OTP write control
always @ (posedge clk or negedge reset_n)
       if (~reset_n) otp_WR <= 1'b0;
       else if (wr_h_en) otp_WR <= 1'b1;
       else if (wr_l_en) otp_WR <= 1'b0;

  

endmodule 
