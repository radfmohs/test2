//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap ENS2  
// File name:    pmu.v 
// Module Name : PMU
// Description : power management  unit 
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author          Description      
//------------------------------------------------------------------------------
// R001 first draft                 05/30/2019                                     
// R002 add otp_dpstb               07/30/2019                                   
// R003 add psw_wake event          11/19/2019
//------------------------------------------------------------------------------

module pmu (

//new added for bps function
//=====================
/*
input  wire 	    adc_ctrl_resetn,
input  wire 	    imeas_en,
input  wire 	    start_y,
input  wire 	    imeas_ch0data_en,
input  wire 	    imeas_ch1data_en,
input  wire 	    imeas_ch2data_en,
input  wire 	    imeas_ch3data_en,
input  wire 	    imeas_ch4data_en,
input  wire 	    imeas_ch5data_en,
input  wire 	    imeas_ch6data_en,
input  wire 	    imeas_ch7data_en,

input  wire 	    start_cmd,
input  wire 	    stop_cmd,

//input             wire start_sample_pclk,
input               wire stop_sample_pclk,

output reg          single_shot_true,
output wire         mode_chg,
output wire         meas_done_pos,

//input  wire 	    rd_cmd_ind,
input  wire 	    single_shot,
output reg 	    data_rdyn,
//output wire 	    start_meas, 
output reg 	    flg_measure,
input  wire	    pclk,
input  wire	    presetn,

input  wire 	    atpg_en,
*/
//input  wire       wakeup_cmd,
//input  wire       standby_cmd,
//output reg 	    D2A_POWER_EN,
//=====================

//input  wire	    pclk,
//input  wire	    presetn,

input  wire         hfosc_atpg,                 // high frequency clock
input  wire         poresetn_hf,             // global reset hfclk domain
//input  wire       atpg_en,              // atpg enable
input  wire         pmuenable,            // pmu enable
input  wire         hresetreq,            // system reset request
input  wire         sleepdeep,            // system enters deep-sleep state
//input  wire       otp_dpstb_en,       // otp deep power down standby mode enable
//input  wire       otp_por_resetn,     // otp por reset

output wire         pmu_fclk_en          // fclk enable when in idle state
//output wire       otp_dpstb           // otp deep power down standby mode
);

parameter  IDLE             = 2'b00;
parameter  DEEP_SLEEP       = 2'b01;
parameter  WAIT_CLK_STABLE  = 2'b10;
parameter  WAIT_COUNT  = 8'b10000;

wire          wakeup_all;
wire          enter_dpslp;

reg   [1:0]   pmu_cur;
reg   [1:0]   pmu_nxt;

reg   [7:0]   clk_stable_cnt;
wire          cnt_done;
wire          pmu_idle;
//wire        pmu_dpslp;
wire          pmu_wait_stclk;

//reg         reg_hfosc_en;

//reg         otp_dpstb_reg;

wire	      hresetreq_sync;
wire	      pmuenable_sync;
wire	      sleepdeep_sync;

// hresetreq cdc
common_sync_bit u_hresetreq_cdc(
  .async_in(hresetreq),
  .clk(hfosc_atpg),
  .rst_(poresetn_hf),
  .sync_out(hresetreq_sync)
);

// all wakeup event for deep-sleep mode
//assign wakeup_all = hresetreq_sync;
//wire wakeup_cmd_pos;
//assign wakeup_all = hresetreq_sync | wakeup_cmd_pos ;
assign wakeup_all = hresetreq_sync  ;

// pmuenable cdc
common_sync_bit u_pmuenable_cdc(
  .async_in(pmuenable),
  .clk(hfosc_atpg),
  .rst_(poresetn_hf),
  .sync_out(pmuenable_sync)
);

// sleepdeep cdc
common_sync_bit u_sleepdeep_cdc(
  .async_in(sleepdeep),
  .clk(hfosc_atpg),
  .rst_(poresetn_hf),
  .sync_out(sleepdeep_sync)
);

// enter deep sleep condition
//assign enter_dpslp = pmuenable_sync & sleepdeep_sync & ~wakeup_all;
//wire standby_cmd_pos;
//assign enter_dpslp = pmuenable_sync & (sleepdeep_sync | standby_cmd_pos) & ~wakeup_all ;
assign enter_dpslp = pmuenable_sync & (sleepdeep_sync) & ~wakeup_all ;

// pmu state fsm
always @ (posedge hfosc_atpg or negedge poresetn_hf) begin
  if (~poresetn_hf)
    pmu_cur <= IDLE;
  else
    pmu_cur <= pmu_nxt;
end

always @ (*) begin
  case (pmu_cur)
    IDLE: begin
      if (enter_dpslp)
        pmu_nxt = DEEP_SLEEP;
      else
        pmu_nxt = IDLE;
    end
    DEEP_SLEEP: begin
      if (wakeup_all)
        pmu_nxt = WAIT_CLK_STABLE;
      else
        pmu_nxt = DEEP_SLEEP;
    end
    WAIT_CLK_STABLE: begin
      if (cnt_done)
        pmu_nxt = IDLE;
      else
        pmu_nxt = WAIT_CLK_STABLE;
    end
    default: pmu_nxt = IDLE;
  endcase
end

assign pmu_idle       = (pmu_cur == IDLE);
//assign pmu_dpslp      = (pmu_cur == DEEP_SLEEP);
assign pmu_wait_stclk = (pmu_cur == WAIT_CLK_STABLE);

// wait clock stable count
assign cnt_done = (clk_stable_cnt == WAIT_COUNT);

always @ (posedge hfosc_atpg or negedge poresetn_hf) begin
  if (~poresetn_hf)
    clk_stable_cnt <= 8'b0;
  else if (cnt_done)
    clk_stable_cnt <= 8'b0;
  else if (pmu_wait_stclk)
    clk_stable_cnt <= clk_stable_cnt + 1'b1;
  else
    clk_stable_cnt <= clk_stable_cnt;
end

// otp deep power down standby mode
/*
always @(posedge hfosc_atpg or negedge otp_por_resetn) begin
  if (~otp_por_resetn)
    otp_dpstb_reg <= 1'b0;
  else
    otp_dpstb_reg <= pmu_dpslp & otp_dpstb_en; 
end

assign otp_dpstb = atpg_en ? 1'b0 : otp_dpstb_reg;
*/
// pmu_fclk_en_ cdc
common_sync_bit u_pmu_sclk_en_cdc(
  .async_in(pmu_idle),
  .clk(hfosc_atpg),
  .rst_(poresetn_hf),
  .sync_out(pmu_fclk_en)
);

//new add for bps function
//=======================
/*
wire 	    meas_done;
assign 	    meas_done = imeas_ch0data_en |	
			imeas_ch1data_en |
			imeas_ch2data_en |
			imeas_ch3data_en |
			imeas_ch4data_en |
			imeas_ch5data_en |
			imeas_ch6data_en |
			imeas_ch7data_en;

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
  .sync_out(imeas_en_sync)
);

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

//wire wakeup_cmd_pos;
//wire standby_cmd_pos;
wire start_cmd_pos;
wire stop_cmd_pos;

assign start_cmd_pos = start_cmd_sync & (~start_cmd_d1);
assign stop_cmd_pos  = stop_cmd_sync & (~stop_cmd_d1);
assign meas_done_pos  = meas_done & (~meas_done_d1);

wire 	    start_meas; 
//assign start_meas = start_pos | start_cmd_pos;
assign start_meas = start_pos | start_cmd_pos | imeas_en_pos;
wire stop_meas;

//change between signal and continuous
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

//cmd
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

//this is for change mode in the middle of measurement
//so it need to change after this time measurement
//wire mode_chg;
//assign  mode_chg = (neg_pulse_of_start || neg_pulse_of_start_cmd) || start_meas || start_sample_pclk || stop_sample_pclk;
assign  mode_chg = (neg_pulse_of_start || neg_pulse_of_start_cmd) || start_meas || stop_sample_pclk;

always @ (posedge pclk or negedge adc_ctrl_resetn)
  if (~adc_ctrl_resetn)
    single_shot_true <= 1'b0;
  else if(mode_chg)
    single_shot_true <= single_shot;

//single shot dont send stop cmd unless change mode
//assign stop_meas =  single_shot_true ? 1'b0 : (start_neg | stop_cmd_pos) ;
assign stop_meas = imeas_en_neg |  (single_shot_true ? 1'b0 : (start_neg | stop_cmd_pos)) ;

reg flg_stop_sent;
always @ (posedge pclk or negedge adc_ctrl_resetn) 
  if (~adc_ctrl_resetn)  
    flg_stop_sent <= 1'b0;
  //else if(stop_meas & (data_rdyn == 1'b0))
  else if(stop_meas & (!meas_done_pos))
    flg_stop_sent <= 1'b1;
  //else if((flg_measure & flg_stop_sent & meas_done_pos) | start_meas_d2 | (stop_meas & (data_rdyn == 1'b1)))
  else if((flg_measure & flg_stop_sent & meas_done_pos) | start_meas_d2)
    flg_stop_sent <= 1'b0;

always @ (posedge pclk or negedge adc_ctrl_resetn) 
  if (~adc_ctrl_resetn)  
    flg_measure <= 1'b0; 
  else if(start_meas_d2)    
    flg_measure <= 1'b1; 
  else if(flg_measure & (((!imeas_en_sync) & single_shot_true) ? meas_done_pos : 
			(flg_stop_sent & meas_done_pos)))  
			// (stop_meas & (data_rdyn == 1'b1))))) 
    flg_measure <= 1'b0; 

//stop don't affect data_rdy
//this is only for  continuous data rdy
wire rstn_drdy;
assign rstn_drdy = atpg_en ? adc_ctrl_resetn : (adc_ctrl_resetn & (~mode_chg));

always @ (posedge pclk or negedge rstn_drdy) 
  if (~rstn_drdy)  
    data_rdyn <= 1'b0;
  //else if(single_shot_true ? start_meas_d2 : 1'b0) 
    //data_rdyn <= 1'b0;
  //else if(single_shot_true ? meas_done_pos : 1'b0)
  else if(meas_done_pos)
    data_rdyn <= 1'b1;
  else
    data_rdyn <= 1'b0;
*/

/*
reg wakeup_cmd_d1;
reg standby_cmd_d1;
wire wakeup_cmd_sync;
common_sync_bit u_wakeup_cmd_sync(
  .async_in(wakeup_cmd),
  .clk(hfosc_atpg),
  .rst_(poresetn_hf),
  .sync_out(wakeup_cmd_sync)
);

wire standby_cmd_sync;
common_sync_bit u_standby_cmd_sync(
  .async_in(standby_cmd),
  .clk(hfosc_atpg),
  .rst_(poresetn_hf),
  .sync_out(standby_cmd_sync)
);

always @ (posedge hfosc_atpg or negedge poresetn_hf) begin
  if (~poresetn_hf) begin
    wakeup_cmd_d1 <= 1'b0;
    standby_cmd_d1 <= 1'b0;
  end else begin
    wakeup_cmd_d1  <= wakeup_cmd_sync;
    standby_cmd_d1 <= standby_cmd_sync;
  end
end

assign wakeup_cmd_pos = wakeup_cmd_sync & (~wakeup_cmd_d1);
assign standby_cmd_pos = standby_cmd_sync & (~standby_cmd_d1);

always @ (posedge hfosc_atpg or negedge poresetn_hf) begin
  if (~poresetn_hf)
    D2A_POWER_EN <= 1'b1;
  else if(standby_cmd_pos)
    D2A_POWER_EN <= 1'b0;
  else if(wakeup_cmd_pos)
    D2A_POWER_EN <= 1'b1;
end
*/

endmodule

