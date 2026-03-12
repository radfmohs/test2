//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap Glucose Chip   
// File name:    imeas_reg.v 
// Module Name : imeas_reg
// Description : IMEAS register
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author          Description      
//------------------------------------------------------------------------------
// 0.1       05/21/2019    Daniel Wang      Initial Rev 
// 0.2       05/21/2019    Mohsen Radfar    Change to conennect to SPI rahter than AHB
//------------------------------------------------------------------------------

module imeas_reg(
//input  wire        pclk,        // pclk 
//input  wire        preset_n,    // Reset
//input  wire	     atpg_en, //in scan mode
//input  wire        int_set,     // interrupt 1T pulse

input  wire [7:0]    reg_ctrl,
//input  wire [7:0]  reg_ch,
//input  wire [2:0]  reg_seq,

//input  wire	     int_clr,
//output reg         int_sts,

//input  wire	     int_alarm_clr,
//input  wire        int_alarm_set,     // interrupt 1T pulse
//output reg         int_alarm_sts,

//removed as the new pin list
//output wire        alpha_0,
//output wire        alpha_1,
//output wire        alpha_2,
//output wire [2:0]  cic_rate,
output wire          format_sel,
//output wire        sd16rst,
output wire [1:0]    imeas_input_format
//output wire        imeas_int_alarm, // interrupt
//output wire        imeas_int // interrupt
);

//wire	        int_alarm_en;
//wire          int_en;
reg   [31:0]    read_data;

//[0] is meas_en
//assign sd16rst = reg_ctrl[1];
//assign cic_rate = reg_ctrl[6:4];

assign imeas_input_format = reg_ctrl[3:2];
assign format_sel = reg_ctrl[7];

//assign sd16rst = reg_seq[2];
//assign sd16rst = reg_ctrl[8];

//interrupt generate
//wire imeas_int_rstn;
//assign imeas_int_rstn = atpg_en ? preset_n: preset_n & (~int_clr);
//always @(posedge pclk or negedge preset_n) begin
//always @(posedge pclk or negedge imeas_int_rstn) begin
  //if (~preset_n)
//  if (~imeas_int_rstn)
//    int_sts <= 1'b0;
//  else if (int_clr)
//    int_sts <= 1'b0;
//  else if (int_set)
//    int_sts <= 1'b1;
//  else
//    int_sts <= int_sts;
//end

//assign imeas_int = int_sts & int_en;

//alarm int
//wire imeas_int_alarm_rstn = atpg_en ? preset_n : preset_n & (~int_alarm_clr);
//always @(posedge pclk or negedge imeas_int_alarm_rstn) begin
/*
always @(posedge pclk or negedge preset_n) begin
    if (~preset_n)
        int_alarm_sts <= 1'b0;
    else if (int_alarm_clr)
        int_alarm_sts <= 1'b0;
    else if (int_alarm_set)
        int_alarm_sts <= 1'b1;
    else
        int_alarm_sts <= int_alarm_sts;
end
 
assign imeas_int_alarm = int_alarm_sts & int_alarm_en;
 */ 

endmodule
