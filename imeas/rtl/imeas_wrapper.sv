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
//output wire                 stop_sample,
output wire                   start_sample_pclk,
//output wire                 stop_sample_pclk,
output reg                    enable_cic,    //to clk_ctrl
output wire                   imeas_working,
output wire                   imeas_working_sync,

//++++++++++++++++++++++++++
//from old pmu
input  wire                   start_y,

input  wire                   start_cmd,
input  wire                   stop_cmd,
input  wire                   single_shot,

//output wire                 data_rdyn,

//++++++++++++++++++++++++++
//clock and reset
input wire                    pclk,             // pclk
//input wire                  presetn,          // reset
input wire                    atpg_en,          // atpg enable

input wire 	 	      cic_rst_n,
input wire 		      filter_rstn,
input wire [7:0]  	      imeas_reg_0,
input wire [3:0]  	      DR,

//output wire [DATA_WIDTH-1:0]  imeas_chdata_adcclk[CHN_NUM-1:0] ,
//output wire [CHN_NUM-1:0]     chdata_en_adcclk,

//output wire [DATA_WIDTH-1:0]imeas_chdata[CHN_NUM-1:0] ,
//output wire [CHN_NUM-1:0]   chdata_en,
//with analog
input  wire [CHN_NUM-1:0]     imeas_adc_din,    // adc serial data input


//lpf-nf-hpf
input wire [CHN_NUM-1:0]   clk,   
input wire [CHN_NUM-1:0]   notch_clk,
input wire [CHN_NUM-1:0]   lpf_clk,
input wire [CHN_NUM-1:0]   hpf_clk,
//input wire    reset,
//input wire    scan_mode,

//input wire [3:0]   DR,
input wire [3:0]   iclk_div,

input wire         int_length_slct,
input wire [1:0]   eeg_int_en,
input wire         eeg_int_clr,
input wire [15:0]  cic_data_ignore_tar,
input wire [23:0]  hpf_coeff_data, 
input wire [17:0]  lpf_coeff_data [31:0],
input wire [19:0]  notch_coeff_data[41:0],


input wire [CHN_NUM-1:0] notch_filter_bypass,
input wire [CHN_NUM-1:0] lpf_filter_bypass,
input wire [CHN_NUM-1:0] hpf_filter_bypass,

input wire                   i_imeas_intr_clr,

output wire [CHN_NUM-1:0]    notch_clk_gtg_en,
output wire [CHN_NUM-1:0]    lpf_clk_gtg_en,
output wire [CHN_NUM-1:0]    hpf_clk_gtg_en,
output wire                  notch_filter_valid,

output wire                   o_eeg_int,
output reg                    eeg_int_sts,
output reg                    meas_done_d1,
output wire  [DATA_WIDTH-1:0] imeas_chdata_out[CHN_NUM-1:0]



);

// Internal signals declaration
 wire stop_sample;
 wire stop_sample_pclk;
wire [DATA_WIDTH-1:0]         imeas_chdata[CHN_NUM-1:0] ;
wire [CHN_NUM-1:0]            chdata_en;

//wire [CHN_NUM-1:0]          chdata_en;
wire                          meas_done;

//assign meas_done = |chdata_en;
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
//reg meas_done_d1;

wire start_cmd_sync;
common_sync_bit u_start_cmd_sync(
                .async_in(start_cmd),
                .clk(pclk),
                .rst_(adc_ctrl_resetn),
                .sync_out(start_cmd_sync)
);

wire stop_cmd_sync;
common_sync_bit u_stop_cmd_sync(
                .async_in(stop_cmd),
                .clk(pclk),
                .rst_(adc_ctrl_resetn),
                .sync_out(stop_cmd_sync)
);

always @ (posedge pclk or negedge adc_ctrl_resetn)
  if (~adc_ctrl_resetn) begin
    start_cmd_d1 <= 1'b0;
    stop_cmd_d1 <= 1'b0;
//    meas_done_d1 <= 1'b0;
  end else begin
    start_cmd_d1 <= start_cmd_sync;
    stop_cmd_d1  <= stop_cmd_sync;
//    meas_done_d1 <= meas_done;
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

wire [CHN_NUM-1:0] notch_filter_bypass_temp; 
wire [CHN_NUM-1:0] lpf_filter_bypass_temp;
wire        cic_data_ok;
wire meas_done_pos;
assign start_cmd_pos = start_cmd_sync & (~start_cmd_d1);
assign stop_cmd_pos  = stop_cmd_sync & (~stop_cmd_d1);
//assign meas_done_pos  = meas_done & (~meas_done_d1);
assign meas_done_pos  = (meas_done & ((cic_data_ok) | ((&(notch_filter_bypass_temp)) && (&(lpf_filter_bypass_temp))))) & (~meas_done_d1);

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
  .sync_out(imeas_working_sync)
);

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


//////////////////////////////////////
//LPF-NF-HPF logic
//////////////////////////////////////

//wire [CHN_NUM-1:0] notch_filter_bypass_temp; 
//wire [CHN_NUM-1:0] lpf_filter_bypass_temp;
wire [CHN_NUM-1:0] hpf_filter_bypass_temp;
wire [CHN_NUM-1:0] filter_chdata_en;


assign notch_filter_valid = |notch_filter_bypass_temp;


//OSR logic
  //NOTCH 
wire [3:0] data_rate_notch;
wire [4:0] data_rate_add;
wire       data_rate_by_pass;
wire       data_rate_by_pass_lpf;


assign data_rate_notch = (data_rate_add<=4'h3)? 4'h0 : (DR - 4'h2 + iclk_div);  
              

assign data_rate_add     = {1'b0,iclk_div} + {1'b0,DR};
assign data_rate_by_pass = ~((data_rate_add>=5'h4) & (data_rate_add<=5'hd));

//LPF
//
assign data_rate_by_pass_lpf = ~((data_rate_add>=5'h2) & (data_rate_add<=5'hf));

//HPF//



//int
wire        meas_done_pulse;
wire        eeg_sts_clr_sync_pulse;
wire        eeg_int_sts_pulse;
wire        eeg_imeas_sts_clr_sync_pulse;

//for shadow notch filter
reg  [15:0] cic_data_counter;
wire [15:0] cic_data_counter_tar;
wire [15:0] cic_data_counter_tar_temp;
//wire        cic_data_ok;
wire        cic_data_counter_clr;
assign cic_data_counter_tar =  (|notch_filter_bypass_temp)?  (|lpf_filter_bypass_temp)? cic_data_ignore_tar : 16'h0000 : cic_data_ignore_tar;    

common_sync_bit u_cic_data_counter_tar_sync[15:0](
       .clk(pclk),
       .rst_(cic_rst_n),
       .async_in(cic_data_counter_tar),
       .sync_out(cic_data_counter_tar_temp)
);

common_sync_bit u_cic_data_counter_clr_sync(
       .clk(pclk),
       .rst_(cic_rst_n),
       .async_in(cic_data_counter_tar!=cic_data_counter_tar_temp),
       .sync_out(cic_data_counter_clr)
);

always @(posedge pclk or negedge cic_rst_n) begin
  if(~cic_rst_n) begin
    cic_data_counter <= 16'h0000;
  end
        else if(cic_data_counter_clr) begin
    cic_data_counter <= 16'h0000;
        end
        else if(meas_done & (cic_data_counter!=cic_data_counter_tar_temp)) begin
    cic_data_counter <= cic_data_counter + 1'b1;
        end
end

assign cic_data_ok = cic_data_counter==cic_data_counter_tar_temp;

//int
assign meas_done = |filter_chdata_en;
assign o_eeg_int = ((eeg_int_sts & !int_length_slct) | (eeg_int_sts_pulse & int_length_slct)) & eeg_int_en[0];

common_pulse_rising u_eeg_int_sts_pulse(
.d_in(eeg_int_sts),
.clk(pclk),
.rst_(cic_rst_n),
.d_out(eeg_int_sts_pulse)
);

common_pulse_async_clr u_eeg_clr_sync(
.d_in(eeg_int_clr),
.clk(pclk),
.rst_(cic_rst_n),
.int_sts(eeg_int_sts),
.scan_mode(atpg_en),
.d_out(eeg_sts_clr_sync_pulse)
);

wire eeg_int_en_sync;
common_sync_bit u_eeg_int_en_sync(
       .clk(pclk),
       .rst_(cic_rst_n),
       .async_in(eeg_int_en[1]),
       .sync_out(eeg_int_en_sync)
);

common_pulse_async_clr u_eeg_imeas_clr_sync(
.d_in(i_imeas_intr_clr),
.clk(pclk),
.rst_(cic_rst_n),
.int_sts(eeg_int_sts),
.scan_mode(atpg_en),
.d_out(eeg_imeas_sts_clr_sync_pulse)
);

always @(posedge pclk or negedge cic_rst_n) begin
  if(~cic_rst_n) begin
    eeg_int_sts <= 1'b0;
  end
        else if(eeg_sts_clr_sync_pulse | !eeg_int_en_sync | eeg_imeas_sts_clr_sync_pulse)begin
    eeg_int_sts <= 1'b0;
        end
        else if(meas_done & ((cic_data_ok) | ((&(notch_filter_bypass_temp)) && (&(lpf_filter_bypass_temp)))))begin
    eeg_int_sts <= 1'b1;
        end
        else begin
    eeg_int_sts <= eeg_int_sts;
        end
end

always @(posedge pclk or negedge cic_rst_n) begin
  if(~cic_rst_n) begin
    meas_done_d1 <= 1'b0;
  end
        //else if(cic_data_ok | ((&(notch_filter_bypass_temp)) && (&(lpf_filter_bypass_temp)))) begin
    //meas_done_d1 <= meas_done;
        else if(meas_done & ((cic_data_ok) | ((&(notch_filter_bypass_temp)) && (&(lpf_filter_bypass_temp))))) begin
    meas_done_d1 <= 1'b1;
	end
	else
    meas_done_d1 <= 1'b0;
end

//notch with the osr that it doesn't support
wire   notch_filter_osr_valid;
assign notch_filter_osr_valid   =   ~((data_rate_notch >= 4'h2) & (data_rate_notch <= 4'hb));
assign notch_filter_bypass_temp = notch_filter_bypass | {CHN_NUM{notch_filter_osr_valid}} | {CHN_NUM{data_rate_by_pass}};


//lpf with the osr that it doesn't support
assign lpf_filter_bypass_temp = lpf_filter_bypass | {CHN_NUM{data_rate_by_pass_lpf}};

//lpf with the osr that it doesn't support
assign hpf_filter_bypass_temp = hpf_filter_bypass;



//////////////////////////////////////////
genvar i;
generate
for(i=0; i<CHN_NUM; i=i+1) begin
filter_wrapper #(
  .DATA_WIDTH(DATA_WIDTH)
)
u_filter_wrapper(
  .pclk(imeas_pclk[i]),
  .adc_clk(imeas_dig_adc_clk[i]), //SDM_CLK,imeas_dig_adc_clk
  .DR(DR),
  .presetn(filter_rstn),
  .reg_ctrl(imeas_reg_0),//input  wire [15:0] 
  .cic_rst_n(cic_rst_n),// 
	
  .chdata(imeas_chdata[i]),//output wire   [15:0]
  .chdata_en(chdata_en[i]),//output wire   [15:0]
  .atpg_en(atpg_en),
  .imeas_adc_din(imeas_adc_din[i]),	//SDM_OUT, imeas_adc_din

/////////////////////////////////////////////////////////
.cic_data_ok(cic_data_ok),
.clk(clk[i]),   
.notch_clk(notch_clk[i]),
.lpf_clk(lpf_clk[i]),
.hpf_clk(hpf_clk[i]),
//.reset(cic_rst_n),
.sign_en(~imeas_reg_0[7]),
.notch_clk_gtg_en(notch_clk_gtg_en[i]),
.lpf_clk_gtg_en(lpf_clk_gtg_en[i]),
.hpf_clk_gtg_en(hpf_clk_gtg_en[i]),

.notch_filter_bypass_temp(notch_filter_bypass_temp[i]),
.lpf_filter_bypass_temp(lpf_filter_bypass_temp[i]),
.hpf_filter_bypass_temp(hpf_filter_bypass_temp[i]),
.scan_mode(atpg_en),

.lpf_coeff_data(lpf_coeff_data),
.hpf_coeff_data(hpf_coeff_data),
.notch_coeff_data(notch_coeff_data),
.imeas_chdata_out(imeas_chdata_out[i]),
.filter_chdata_en(filter_chdata_en[i])



);
end
endgenerate

endmodule
