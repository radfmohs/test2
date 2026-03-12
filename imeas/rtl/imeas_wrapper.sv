//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap Glucose Chip   
// File name: imeas_wrapper.v 
// Module Name : imeas_wrapper.v
// Description : 
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author          Description      
//------------------------------------------------------------------------------
// 0.1                                      Initial Rev 
//------------------------------------------------------------------------------

module imeas_wrapper  #(
parameter DATA_WIDTH = 32,
          CHN_NUM    = 16
) (
//from old clk_ctrl
input  wire [15:0]            stable_time,
input  wire                   adc_resetn,
input  wire                   adc_ctrl_resetn,
input  wire                   adc_clk_running,
input  wire [CHN_NUM-1:0]     imeas_pclk,    	     // adc serial data input
input  wire [CHN_NUM-1:0]     imeas_dig_adc_clk,    // adc serial data input
input  wire                   first_neg_sclk,
/*
input wire                    is_2channels,
input wire                    is_4channels,
input wire                    is_6channels,
input wire                    is_8channels,
*/

//input  wire                 flg_measure,
//input  wire                 D2A_POWER_EN,
//output wire                 meas_done,
input  wire                   imeas_en,
output wire                   start_sample,
//output wire                   stop_sample,
output wire                   start_sample_pclk,
//output wire                   stop_sample_pclk,
output reg                    enable_cic,    //to clk_ctrl
output wire                   imeas_working,
output wire                   imeas_working_sync,

//++++++++++++++++++++++++++
//from old pmu
input  wire                   start_y,

input  wire                   start_cmd,
input  wire                   stop_cmd,
input  wire                   single_shot,

//output wire                   data_rdyn,

//++++++++++++++++++++++++++
//clock and reset
input wire                    pclk,             // pclk
//input wire                  presetn,          // reset
input wire                    atpg_en,          // atpg enable

input wire 	 	      cic_rst_n,
input wire 		      filter_rstn,
input wire [7:0]  	      imeas_reg_0,
input wire [3:0]  	      DR,

output wire [DATA_WIDTH-1:0]  imeas_chdata_adcclk[CHN_NUM-1:0] ,
output wire [CHN_NUM-1:0]     chdata_en_adcclk,

//output wire [DATA_WIDTH-1:0]imeas_chdata[CHN_NUM-1:0] ,
//output wire [CHN_NUM-1:0]   chdata_en,
//with analog
input  wire [CHN_NUM-1:0]     imeas_adc_din    // adc serial data input

);

// Internal signals declaration
 wire stop_sample;
 wire stop_sample_pclk;
wire [DATA_WIDTH-1:0]         imeas_chdata[CHN_NUM-1:0] ;
wire [CHN_NUM-1:0]            chdata_en;

//wire [CHN_NUM-1:0]          chdata_en;
wire                          meas_done;

assign meas_done = |chdata_en;
//assign      imeas_chdata_en = meas_done;

wire start_y_d2;
common_sync_bit common_bit_start_y(
  .async_in(start_y),
  .clk(pclk),
  .rst_(adc_ctrl_resetn),
  .sync_out(start_y_d2)
);

reg start_y_d3;
reg start_y_d4;
always @ (posedge pclk or negedge adc_ctrl_resetn) begin
  if (~adc_ctrl_resetn)  begin
    start_y_d3 <= 1'b0;
    start_y_d4 <= 1'b0;
  end else begin
    start_y_d3 <= start_y_d2;
    start_y_d4 <= start_y_d3;
  end
end

wire final_start;
assign final_start =  start_y_d4;

reg final_start_d1;
always @ (posedge pclk or negedge adc_ctrl_resetn)
  if (~adc_ctrl_resetn)
        final_start_d1 <= 1'b0;
  else
        final_start_d1 <= final_start;

wire start_pos;
assign start_pos = final_start & (!final_start_d1);

wire start_neg;
assign start_neg = (~final_start) & (final_start_d1);

reg start_cmd_d1;
reg stop_cmd_d1;
reg meas_done_d1;

wire start_cmd_sync;
common_sync_bit u_start_cmd_sync(
                .async_in(start_cmd),
                .clk(pclk),
                .rst_(adc_ctrl_resetn),
                .sync_out(start_cmd_sync));

wire stop_cmd_sync;
common_sync_bit u_stop_cmd_sync(
                .async_in(stop_cmd),
                .clk(pclk),
                .rst_(adc_ctrl_resetn),
                .sync_out(stop_cmd_sync));


always @ (posedge pclk or negedge adc_ctrl_resetn)
  if (~adc_ctrl_resetn) begin
    start_cmd_d1 <= 1'b0;
    stop_cmd_d1 <= 1'b0;
    meas_done_d1 <= 1'b0;
  end else begin
    start_cmd_d1 <= start_cmd_sync;
    stop_cmd_d1  <= stop_cmd_sync;
    meas_done_d1 <= meas_done;
  end

wire imeas_en_sync;
common_sync_bit u_imeas_en_sync(
                .async_in(imeas_en),
                .clk(pclk),
                .rst_(adc_ctrl_resetn),
                .sync_out(imeas_en_sync));

reg imeas_en_sync_d1;
always @ (posedge pclk or negedge adc_ctrl_resetn)
  if (~adc_ctrl_resetn) begin
        imeas_en_sync_d1 <= 1'b0;
  end else begin
        imeas_en_sync_d1 <= imeas_en_sync;
  end

wire imeas_en_pos;
wire imeas_en_neg;
assign imeas_en_pos = imeas_en_sync & (!imeas_en_sync_d1);
assign imeas_en_neg = (!imeas_en_sync) & (imeas_en_sync_d1);

wire start_cmd_pos;
wire stop_cmd_pos;

wire meas_done_pos;
assign start_cmd_pos = start_cmd_sync & (~start_cmd_d1);
assign stop_cmd_pos  = stop_cmd_sync & (~stop_cmd_d1);
assign meas_done_pos  = meas_done & (~meas_done_d1);

wire start_meas;
wire stop_meas;
assign start_meas = start_pos | start_cmd_pos | imeas_en_pos;

reg flg_start;
reg flg_start_d1;
always @ (posedge pclk or negedge adc_ctrl_resetn)
  if (~adc_ctrl_resetn)
        flg_start <= 1'b0;
  else if(start_neg)
        flg_start <= 1'b1;
  else if(start_pos)
        flg_start <= 1'b0;

always @ (posedge pclk or negedge adc_ctrl_resetn)
  if (~adc_ctrl_resetn)
        flg_start_d1 <= 1'b0;
  else
        flg_start_d1 <= flg_start;

wire neg_pulse_of_start;
assign neg_pulse_of_start = (~flg_start) & flg_start_d1;

reg flg_start_cmd;
reg flg_start_cmd_d1;
always @ (posedge pclk or negedge adc_ctrl_resetn)
  if (~adc_ctrl_resetn)
        flg_start_cmd <= 1'b0;
  else if(stop_cmd_pos)
        flg_start_cmd <= 1'b1;
  else if(start_cmd_pos)
        flg_start_cmd <= 1'b0;

always @ (posedge pclk or negedge adc_ctrl_resetn)
  if (~adc_ctrl_resetn)
        flg_start_cmd_d1 <= 1'b0;
  else
        flg_start_cmd_d1 <= flg_start_cmd;

wire neg_pulse_of_start_cmd;
assign neg_pulse_of_start_cmd = (~flg_start_cmd) & flg_start_cmd_d1;

reg start_meas_d1;
reg start_meas_d2;
always @ (posedge pclk or negedge adc_ctrl_resetn)
  if (~adc_ctrl_resetn) begin
        start_meas_d1 <= 1'b0;
        start_meas_d2 <= 1'b0;
  end else begin
        start_meas_d1 <= start_meas;
        start_meas_d2 <= start_meas_d1;
  end

wire mode_chg;
assign  mode_chg = (neg_pulse_of_start || neg_pulse_of_start_cmd) || start_meas || stop_sample_pclk;

reg single_shot_true;
always @ (posedge pclk or negedge adc_ctrl_resetn)
  if (~adc_ctrl_resetn)
        single_shot_true <= 1'b0;
  else if(mode_chg)
        single_shot_true <= single_shot;

assign stop_meas = imeas_en_neg |  (single_shot_true ? 1'b0 : (start_neg | stop_cmd_pos)) ;

reg flg_stop_sent;
reg flg_measure;
always @ (posedge pclk or negedge adc_ctrl_resetn)
  if (~adc_ctrl_resetn)
    flg_stop_sent <= 1'b0;
  //else if(stop_meas & (!meas_done_pos))
  else if(stop_meas)
    flg_stop_sent <= 1'b1;
  else if((flg_measure & flg_stop_sent & meas_done_pos) | start_meas_d2)
    flg_stop_sent <= 1'b0;

always @ (posedge pclk or negedge adc_ctrl_resetn)
  if (~adc_ctrl_resetn)
    flg_measure <= 1'b0;
  else if(start_meas_d2)
    flg_measure <= 1'b1;
  else if(flg_measure & (((!imeas_en_sync) & single_shot_true) ? meas_done_pos :
                        (flg_stop_sent & meas_done_pos)))
    flg_measure <= 1'b0;


//seems the following is not useful
//==================================
/*
reg          data_rdyn_single;
=======
>>>>>>> 3bd481b7e831258b00299a95e67a28028d2b96cf
wire rstn_drdy;
assign rstn_drdy = atpg_en ? adc_ctrl_resetn : (adc_ctrl_resetn & (~mode_chg));

reg  data_rdyn_single;
always @ (posedge pclk or negedge rstn_drdy)
  if (~rstn_drdy)
    data_rdyn_single <= 1'b0;
  else if(start_meas_d2)
    data_rdyn_single <= 1'b0;
  else if(((!imeas_en_sync) & single_shot_true) & meas_done_pos)
    data_rdyn_single <= 1'b1;

wire 	    first_neg_sclk_inv;
assign 	    first_neg_sclk_inv = ~first_neg_sclk;

wire rdyn_rstn_cont;
assign rdyn_rstn_cont = atpg_en ? adc_ctrl_resetn : (adc_ctrl_resetn &  first_neg_sclk_inv & (~mode_chg));

reg data_rdyn_cont;
always @ (posedge pclk or negedge rdyn_rstn_cont ) 
  if (~rdyn_rstn_cont)  
    data_rdyn_cont <= 1'b0;
  else if(start_meas_d2) 
    data_rdyn_cont <= 1'b0;
  else if(meas_done_pos & (! ((!imeas_en_sync) & single_shot_true)  ))
    data_rdyn_cont <= 1'b1;

//assign data_rdyn = ((!imeas_en_sync) & single_shot_true) ? data_rdyn_single : data_rdyn_cont;

reg data_rdyn_tmp;
always @ (posedge pclk or negedge rstn_drdy)
  if (~rstn_drdy)
    data_rdyn_tmp <= 1'b0;
  else if(meas_done_pos)
    data_rdyn_tmp <= 1'b1;
  else
    data_rdyn_tmp <= 1'b0;

assign data_rdyn = data_rdyn_tmp;
*/
//=============================================
//+++++++++++++++
//reg         flg_measure;

//assign imeas_working = (imeas_en_sync | flg_measure) & D2A_POWER_EN;
assign imeas_working = (imeas_en_sync | flg_measure) ;

common_sync_bit u_imeas_working_sync(
                .async_in(imeas_working),
                .clk(adc_clk_running),
                .rst_(adc_resetn),
                .sync_out(imeas_working_sync));

reg imeas_working_sync_d1;
reg imeas_working_sync_d2;
reg imeas_working_sync_d3;
always @ (posedge adc_clk_running or negedge adc_resetn) begin
  if (~adc_resetn) begin
    imeas_working_sync_d1 <= 1'b0;
    imeas_working_sync_d2 <= 1'b0;
    imeas_working_sync_d3 <= 1'b0;
  end else begin
    imeas_working_sync_d1 <= imeas_working_sync;
    imeas_working_sync_d2 <= imeas_working_sync_d1;
    imeas_working_sync_d3 <= imeas_working_sync_d2;
  end
end

reg imeas_working_sync_d1_pclk;
always @ (posedge pclk or negedge adc_ctrl_resetn) begin
  if (~adc_ctrl_resetn)
    imeas_working_sync_d1_pclk <= 1'b0;
  else
    imeas_working_sync_d1_pclk <= imeas_working;
end

assign start_sample = imeas_working_sync & (!imeas_working_sync_d1);
assign stop_sample = (!imeas_working_sync) & (imeas_working_sync_d1);
assign start_sample_pclk = imeas_working & (!imeas_working_sync_d1_pclk);
assign stop_sample_pclk = (!imeas_working) & (imeas_working_sync_d1_pclk);

reg start_sample_d1;
reg start_sample_d2;
reg start_sample_d3;
always @ (posedge adc_clk_running or negedge adc_resetn) begin
  if (~adc_resetn) begin
    start_sample_d1 <= 1'b0;
    start_sample_d2 <= 1'b0;
    start_sample_d3 <= 1'b0;
  end else begin
    start_sample_d1 <= start_sample;
    start_sample_d2 <= start_sample_d1;
    start_sample_d3 <= start_sample_d2;
  end
end

reg [15:0] cnt_stable_time;
always @ (posedge adc_clk_running or negedge adc_resetn) begin
  if (~adc_resetn)
    cnt_stable_time <= 16'b0;
  //else if(start_sample |stop_sample | (cnt_stable_time >= stable_time))
  else if(start_sample_d3 |stop_sample | (cnt_stable_time >= stable_time))
    cnt_stable_time <= 16'b0;
  //else if ((!enable_cic) & imeas_working_sync)
  else if ((!enable_cic) & imeas_working_sync_d3 & imeas_working_sync)
    cnt_stable_time <= cnt_stable_time + 16'b1;
end

always @ (posedge adc_clk_running or negedge adc_resetn) begin
  if (~adc_resetn)
    enable_cic <= 1'b0;
  //else if((start_sample | stop_sample) & (stable_time != 16'b0))
  else if((start_sample_d3 | stop_sample) & (stable_time != 16'b0))
    enable_cic <= 1'b0;
  //else if((!stop_sample) & (cnt_stable_time >= stable_time) & imeas_working_sync)
  else if((!stop_sample) & (cnt_stable_time >= stable_time) & imeas_working_sync_d3 & imeas_working_sync)
    enable_cic <= 1'b1;
end


wire            int_set;
//wire          int_alarm_set;
wire [1:0]      imeas_input_format;
wire            format_sel;
wire            sd16eoc_sync;
wire   [31:0]   sd16cic_data;
wire            sd16eoc;

genvar i;
generate
for(i=0; i<16; i=i+1) begin
imeas #(
.DATA_WIDTH(DATA_WIDTH)
)
u_imeas(

	.pclk(imeas_pclk[i]),
	.adc_clk(imeas_dig_adc_clk[i]), //SDM_CLK,imeas_dig_adc_clk
	.DR(DR),
	.presetn(filter_rstn),
	.reg_ctrl(imeas_reg_0),//input  wire [15:0] 
	.cic_rst_n(cic_rst_n),// 

        .chdata_adcclk(imeas_chdata_adcclk[i]),//output wire   [15:0]
        .chdata_en_adcclk(chdata_en_adcclk[i]),//output wire   [15:0]
	
        .chdata(imeas_chdata[i]),//output wire   [15:0]
        .chdata_en(chdata_en[i]),//output wire   [15:0]
	.atpg_en(atpg_en),
	.imeas_adc_din(imeas_adc_din[i])	//SDM_OUT, imeas_adc_din
);
end
endgenerate

endmodule
