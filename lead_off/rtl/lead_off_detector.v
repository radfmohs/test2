//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap ENS2  
// File name:    lead_off_detector.v 
// Module Name : LEAD OFF TOP
// Description : 
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author          Description      
//------------------------------------------------------------------------------
// 0.1                                      Initial Rev 
//------------------------------------------------------------------------------

`timescale 1 ns /  1 ps

module lead_off_detector
(
  input  wire [31 : 0]  timer_cnt_tgt,
  input  wire [31 : 0]   counter_th_tgt,
  output wire   lead_off_stop,
  input wire   lead_off_stop_en,

  input  wire    lead_off_sts_clear,   
  //input  wire    comp_reverse,    //0: dac0 compare A2D_COMP1 and dac1 compare A2D_COMP2  
  input  wire    dac_en_in,   
  input  wire    drive_en,   

  //input  wire [7 : 0]  lead_off_tgt,
				  
  input wire sel_stim ,       	    
  input wire A2D_STIMU0_1,         
  input  wire    A2D_COMP1,   
//xin add for level interrupt 11Jun2025
  //output reg    lead_off_result,   
  //input  wire   lead_off_int_en,   
  output reg     lead_off_result,   
  input  wire    lead_off_int_en,   
  input  wire 	      comp_low_en,
  input  wire         int_length_slct, 
 
  output wire   o_lead_off_int,   

  output reg[31:0] lead_off_Counter_cnt_dac0_final_dbg,
  output wire[7:0] lead_off_Counter_cnt_dac0_dbg,

  
  input wire                     i_pclk,
  input wire                     i_presetn

  );
//xin add for level interrupt 11Jun2025
    //wire   lead_off_int_en_sync;
    wire    lead_off_int_en_sync;


//xin add for level interrupt 11Jun2025
   wire [31 : 0]   counter_th_tgt_sync;

  wire [31 : 0]  timer_cnt_tgt_sync;

   assign lead_off_int_en_sync 	= lead_off_int_en;

   assign counter_th_tgt_sync 	= counter_th_tgt;

   assign  timer_cnt_tgt_sync = timer_cnt_tgt;
   //assign TH_H_sync 		= TH_H;
   //assign TH_L_sync 		= TH_L;



/*
  wire   lead_off_en_sync;
common_sync_bit   u_lead_off_en (
       .clk(i_pclk),
       .rst_(i_presetn),
       .async_in(lead_off_en),
       .sync_out(lead_off_en_sync)
       );
reg lead_off_en_sync_d1;
always @(posedge i_pclk or negedge i_presetn) begin
	if (~i_presetn)
		lead_off_en_sync_d1 <= 1'b0;
	else
		lead_off_en_sync_d1 <= lead_off_en;
end
wire lead_off_rst;
assign lead_off_rst = lead_off_en & (~lead_off_en_sync_d1);
wire lead_off_rstn;
assign lead_off_rstn = atpg_en ? i_presetn : i_presetn & (~lead_off_rst);
*/
wire lead_off_rstn;
assign lead_off_rstn =  i_presetn ;

wire lead_off_sts_clear_sync;
common_sync_bit   u_lead_off_sts_clear (
       .clk(i_pclk),
       .rst_(lead_off_rstn),
       .async_in(lead_off_sts_clear),
       .sync_out(lead_off_sts_clear_sync)
       );
reg lead_off_sts_clear_sync_d1;
always @(posedge i_pclk or negedge lead_off_rstn) begin
	if (~lead_off_rstn)
		lead_off_sts_clear_sync_d1 <= 1'b0;
	else	
		lead_off_sts_clear_sync_d1 <= lead_off_sts_clear_sync;
end
wire lead_off_sts_clear_sync_pulse;
assign lead_off_sts_clear_sync_pulse = lead_off_sts_clear_sync & (~lead_off_sts_clear_sync_d1);


reg [31 : 0]  timer_cnt_cnt_dac0;


wire A2D_COMP1_sync;
wire A2D_COMP1_sync_bak1;
wire A2D_COMP1_sync_bak;
common_sync_bit u_A2D_COMP1_sync(
       .clk(i_pclk),
       .rst_(lead_off_rstn),
       .async_in(A2D_COMP1),
       .sync_out(A2D_COMP1_sync_bak1)
);

wire A2D_STIMU0_1_sync;
wire A2D_STIMU0_1_sync_bak;
common_sync_bit u_A2D_STIMU0_1_sync(
       .clk(i_pclk),
       .rst_(lead_off_rstn),
       .async_in(A2D_STIMU0_1),
       .sync_out(A2D_STIMU0_1_sync_bak)
);


assign A2D_COMP1_sync_bak = sel_stim ? A2D_STIMU0_1_sync_bak : A2D_COMP1_sync_bak1;

assign A2D_COMP1_sync = comp_low_en ? ~A2D_COMP1_sync_bak : A2D_COMP1_sync_bak;


wire dac0_trig_Counter_final;
assign dac0_trig_Counter_final =   A2D_COMP1_sync;
//=====================
   wire    dac_en;   
   wire    dac_en_bak;   
   assign   dac_en_bak = dac_en_in & drive_en;   

common_sync_bit u_dac0_en(
       .clk(i_pclk),
       .rst_(lead_off_rstn),
       .async_in(dac_en_bak),
       .sync_out(dac_en)
);


wire dac0_cnt_dis;
assign dac0_cnt_dis = (!(dac_en)) | lead_off_result;

always @(posedge i_pclk or negedge lead_off_rstn) begin
	if (~lead_off_rstn)
		timer_cnt_cnt_dac0 <= 32'b0;
	//else if((~dac_en[0]))
	else if(dac0_cnt_dis)
		timer_cnt_cnt_dac0 <= 32'b0;
	else if(timer_cnt_cnt_dac0 == timer_cnt_tgt_sync)
		timer_cnt_cnt_dac0 <= 32'b0;
	else  
		timer_cnt_cnt_dac0 <= timer_cnt_cnt_dac0 + 32'b1;
end

//xin add level trig cnt 11Jun2025
reg[31:0] lead_off_Counter_cnt_dac0;
always @(posedge i_pclk or negedge lead_off_rstn) begin
	if (~lead_off_rstn)
		lead_off_Counter_cnt_dac0 <= 32'b0;
	//else if(~dac_en[0])
	else if(dac0_cnt_dis)
		lead_off_Counter_cnt_dac0 <= 32'b0;
	else if(timer_cnt_cnt_dac0 == timer_cnt_tgt_sync)
		lead_off_Counter_cnt_dac0 <= 32'b0;
	//else if(dac0_trig_Counter_final & dac_en[0])
	else if(dac0_trig_Counter_final)
		lead_off_Counter_cnt_dac0 <= lead_off_Counter_cnt_dac0 + 32'b1;
end

always @(posedge i_pclk or negedge lead_off_rstn) begin
	if (~lead_off_rstn)
  		lead_off_Counter_cnt_dac0_final_dbg <= 32'b0;
	else if(timer_cnt_cnt_dac0 == timer_cnt_tgt_sync)
  		lead_off_Counter_cnt_dac0_final_dbg <= lead_off_Counter_cnt_dac0;
end
//===============
reg lead_off_result_bak;

reg lead_off_result_bak_d1;
always @(posedge i_pclk or negedge lead_off_rstn) begin
	if (~lead_off_rstn)
		lead_off_result_bak_d1 <= 1'b0;
	else
		lead_off_result_bak_d1 <= lead_off_result_bak;
end
wire lead_off_result_bak_neg;
assign lead_off_result_bak_neg = lead_off_result_bak_d1 & (!lead_off_result_bak);

wire lead_off_cond;
wire   lead_off_cond_final;
always @(posedge i_pclk or negedge lead_off_rstn) begin
	if (~lead_off_rstn)
		lead_off_result_bak <= 1'b0;
	else if(lead_off_cond_final & lead_off_sts_clear_sync_pulse)
		lead_off_result_bak <= 1'b1;
	else if(~lead_off_sts_clear_sync)
		lead_off_result_bak <= 1'b0;
end


assign lead_off_cond = (timer_cnt_cnt_dac0 == timer_cnt_tgt_sync) & (lead_off_Counter_cnt_dac0 < counter_th_tgt_sync);
//assign lead_off_cond_final = (lead_off_cnt == lead_off_tgt) & lead_off_cond;
assign lead_off_cond_final =  lead_off_cond;
always @(posedge i_pclk or negedge lead_off_rstn) begin
	if (~lead_off_rstn)
		lead_off_result <= 1'b0;
	else if(lead_off_sts_clear_sync_pulse)
		lead_off_result <= 1'b0;
	else if(lead_off_result_bak_neg)
		lead_off_result <= 1'b1;
	else if(lead_off_cond_final)
		lead_off_result <= 1'b1;
end


wire  lead_off_int_temp,lead_off_int;
common_pulse_rising u_o_lead_off_int_rising(
.d_in(lead_off_int),
.clk(i_pclk),
.rst_(lead_off_rstn),
.d_out(lead_off_int_temp)

);

assign o_lead_off_int = ((|lead_off_int) & !int_length_slct) | ((|lead_off_int_temp) & int_length_slct);

//========================

  assign   lead_off_int = (lead_off_result  & lead_off_int_en_sync) ; 

  assign   lead_off_stop = lead_off_result  & lead_off_stop_en;

  assign lead_off_Counter_cnt_dac0_dbg = lead_off_Counter_cnt_dac0[7:0];

endmodule

