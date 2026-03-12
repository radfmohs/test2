//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap Glucose Chip   
// File name:    imeas_ctrl.v 
// Module Name : imeas_ctrl
// Description : IMEAS Control module
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author          Description      
//------------------------------------------------------------------------------
// 0.1       05/21/2019    Daniel Wang      Initial Rev 
//------------------------------------------------------------------------------

`timescale 1ns/1ps

module imeas_ctrl(
//input               adc_clk,
//input               cic_rst_n,
input  wire           pclk,
input  wire           preset_n,
input  wire           sd16eoc_sync,
//input  wire  [15:0] sd16cic_data,
input  wire  [31:0]   sd16cic_data,
//input  wire         sd16rst,
//output wire  [15:0] ch0data,
output wire  [31:0]   ch0data,
output wire           ch0data_en,
//output wire  [3:0]  chnum_out,
//output wire         cic_rst,

//input  wire [15:0]  threshold_hi,
//input  wire [15:0]  threshold_lo,

//output wire         int_alarm_set,
output wire           int_set
);

wire          sd16eoc_pos; 
wire          grp_mod;
reg           sd16eoc_sync_d1;
//reg  [15:0] ch0data_reg;
reg  [31:0]   ch0data_reg;
reg           ch0data_en_reg;
reg  [7:0]    rst_cnt;
//reg         cic_rst_reg;

always @ (posedge pclk or negedge preset_n) begin
  if (~preset_n)
    sd16eoc_sync_d1 <= 1'b0;
  else
    sd16eoc_sync_d1 <= sd16eoc_sync;
end

assign sd16eoc_pos = sd16eoc_sync & ~sd16eoc_sync_d1; //1t pusle of sd16eoc posedge 

//and of sw reset, output to cic filter  
/*
always @ (posedge pclk or negedge preset_n) begin
  if (~preset_n)
    cic_rst_reg <= 1'b0;
  else
    cic_rst_reg <= sd16rst;
end
*/
//assign cic_rst = cic_rst_reg;
//assign cic_rst = sd16rst;

//interrupt set, 1T pulse
assign int_set = sd16eoc_pos;

/*
wire bigger_than_threshold_hi = sd16cic_data > threshold_hi;
wire smaller_than_threshold_lo = sd16cic_data < threshold_lo;

assign int_alarm_set =  sd16eoc_pos & (bigger_than_threshold_hi
				       | smaller_than_threshold_lo);
*/

//channel 0 data 
always @ (posedge pclk or negedge preset_n) begin
  if (~preset_n)
    //ch0data_reg <= 16'h0;
    ch0data_reg <= 32'h0;
  else if (sd16eoc_pos)
    ch0data_reg <= sd16cic_data;
  else
    ch0data_reg <= ch0data_reg;
end

always @ (posedge pclk or negedge preset_n) begin
  if (~preset_n)
    ch0data_en_reg <= 1'b0;
  else if (sd16eoc_pos)
    ch0data_en_reg <= 1'b1;
  else
    ch0data_en_reg <= 1'b0;
end

assign ch0data = ch0data_reg;
assign ch0data_en = ch0data_en_reg;

endmodule
