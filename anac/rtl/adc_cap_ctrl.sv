//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap Glucose Chip   
// File name:    adc_cap_ctrl.v 
// Module Name : adc_cap_ctrl
// Description : 
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author          Description      
//------------------------------------------------------------------------------
// 0.1                                      Initial Rev 
//------------------------------------------------------------------------------

module adc_cap_ctrl(
input wire sysclk,	
input wire presetn,
input wire scan_mode,

input wire [3:0] stim_dly_tgt,   //from spi
//for int
input wire [1:0] stim_mon_int_en,   //from spi
input wire [1:0] stim_mon_int_topin_en,   //from spi
input wire [1:0] stim_mon_delta_data_sel,   //from spi
input wire [15:0]   	o_source_driver,
input wire [15:0]   	o_pulldn_driver, 

input wire stim_mon_int_clr,   //from spi
output reg stim_mon_int_sts,   //to spi
input wire stim_mon_delta_int_clr,   //from spi
output reg stim_mon_delta_int_sts,   //to spi


input wire o_stim_mon_int,   //to INTB
input wire int_length_slct,

input wire adc_mode,   //0 is manual mode, 1 is auto mode
			//wavegen also need in manual mode if adc_mode is 0, should provide fixed stim waveform and source/pull
input wire [15:0] adc_cap_period,	
input wire [3:0] pair_num,   //1 means has 2 pair, 2 means has 3 pair, max 16 pair	
input wire [15:0] [3:0] stim_pad0_tgt,	
input wire [15:0] [3:0] stim_pad1_tgt,	
input wire [9:0] A2D_ADC_DATA,  //ADC use negedge of sysclk to output data, so we have half sysclk cycle margin for it	
input wire  	 A2D_ADC_DATA_EN,	
output wire [3:0]  D2A_STIM_PAD0,
output wire [3:0]  D2A_STIM_PAD1,	
output reg  A2D_ADC_DATA_VLD,	
output wire [15:0] A2D_ADC_DATA_TAG,	
output wire  A2D_ADC_DELTA_DATA_VLD,	
output wire [15:0] A2D_ADC_DELTA_DATA_TAG	

	
);

reg [15:0] adc_cap_period_cnt;	
always @ (posedge sysclk or negedge presetn) begin
  if (~presetn) 
	adc_cap_period_cnt <= 16'b0;	
  else if(adc_cap_period_cnt >= adc_cap_period)
	adc_cap_period_cnt <= 16'b0;	
  else
	adc_cap_period_cnt <= adc_cap_period_cnt + 16'b1;	
end

reg check_pulse;
reg check_pulse_d1;
reg[3:0] pair_cnt;
reg[3:0] pair_cnt_d1;
always @ (posedge sysclk or negedge presetn) begin
  if (~presetn) begin 
 	pair_cnt <= 4'b0;
	check_pulse <= 1'b0;
  end else if(adc_cap_period_cnt >= adc_cap_period) begin
 	pair_cnt <= (pair_cnt >= pair_num) ? 4'b0 : (pair_cnt + 4'b1);
	check_pulse <= 1'b1;
  end else
	check_pulse <= 1'b0;
end

always @ (posedge sysclk or negedge presetn) begin
  if (~presetn)  
	check_pulse_d1 <= 1'b0;
  else
	check_pulse_d1 <= check_pulse;
end
assign  A2D_ADC_DELTA_DATA_VLD = check_pulse_d1;	


wire active_stim;
// stim_pad0/1 defines which channel is currently being stimulated
assign active_stim = o_source_driver[D2A_STIM_PAD0[3:0]] | o_source_driver[D2A_STIM_PAD1[3:0]] |
		     o_pulldn_driver[D2A_STIM_PAD0[3:0]] | o_pulldn_driver[D2A_STIM_PAD1[3:0]] ;

//add delay for active_stim incase the adc will response lately
reg[15:0] delayed_active_stim;
always @ (posedge sysclk or negedge presetn) begin
  if (~presetn)  
	delayed_active_stim <= 16'b0;
  else 
	delayed_active_stim <= {delayed_active_stim[14:0],active_stim};
end
wire final_active_stim;
assign final_active_stim = (stim_dly_tgt == 4'b0) ? active_stim : active_stim & delayed_active_stim[stim_dly_tgt - 4'b1];


reg[9:0] A2D_ADC_DATA_CAP;
reg[3:0] A2D_ADC_TAG_CAP;
always @ (posedge sysclk or negedge presetn) begin
  if (~presetn) begin 
	A2D_ADC_DATA_CAP <= 10'b0;
	A2D_ADC_TAG_CAP <= 4'b0;
	A2D_ADC_DATA_VLD <= 1'b0;
  //end else if(A2D_ADC_DATA_EN) begin
  //end else if(A2D_ADC_DATA_EN & active_stim) begin
  end else if(A2D_ADC_DATA_EN & final_active_stim) begin
	A2D_ADC_DATA_CAP <= A2D_ADC_DATA;
	A2D_ADC_TAG_CAP <= pair_cnt;
	A2D_ADC_DATA_VLD <= 1'b1;
  end else begin
	A2D_ADC_DATA_VLD <= 1'b0;
  end
end

assign D2A_STIM_PAD0 = adc_mode ? stim_pad0_tgt[pair_cnt] : stim_pad0_tgt[4'b0];
assign D2A_STIM_PAD1 = adc_mode ? stim_pad1_tgt[pair_cnt] : stim_pad1_tgt[4'b0];
assign A2D_ADC_DATA_TAG	 = adc_mode ? {A2D_ADC_TAG_CAP,2'b0,A2D_ADC_DATA_CAP} : {4'b0,2'b0,A2D_ADC_DATA_CAP};

//calculate the peak to peak

reg [9:0] A2D_ADC_DATA_max;  	
reg [9:0] A2D_ADC_DATA_min;  	
reg [9:0] A2D_ADC_DATA_delta;  	
reg [9:0] A2D_ADC_DATA_max_cap;  	
reg [9:0] A2D_ADC_DATA_min_cap;  	
always @ (posedge sysclk or negedge presetn) begin
  if (~presetn)  
	A2D_ADC_DATA_max <= 10'h0;  	
  //else if(check_pulse_d1) 
  else if(check_pulse)   //check_pulse has higher priority, if check_pulse happen at same time with A2D_ADC_DATA_VLD,
			//then A2D_ADC_DATA_VLD data will be ignored 
	A2D_ADC_DATA_max <= 10'h0;  	
  else if(A2D_ADC_DATA_VLD & (A2D_ADC_DATA_CAP >= A2D_ADC_DATA_max)) 
	A2D_ADC_DATA_max <= A2D_ADC_DATA_CAP;  	
end

always @ (posedge sysclk or negedge presetn) begin
  if (~presetn)  
	A2D_ADC_DATA_min <= 10'h3ff;  	
  //else if(check_pulse_d1) 
  else if(check_pulse) 
	A2D_ADC_DATA_min <= 10'h3ff;  	
  else if(A2D_ADC_DATA_VLD & (A2D_ADC_DATA_CAP <= A2D_ADC_DATA_min)) 
	A2D_ADC_DATA_min <= A2D_ADC_DATA_CAP;  	
end

reg[3:0] A2D_ADC_TAG_CAP_delta;
always @ (posedge sysclk or negedge presetn) begin
  if (~presetn) begin 
	A2D_ADC_DATA_delta <= 10'h0;  	
 	A2D_ADC_TAG_CAP_delta <= 4'b0;
 	A2D_ADC_DATA_max_cap <= 10'h0;  	
 	A2D_ADC_DATA_min_cap <= 10'h0;  	
  end else if(check_pulse) begin 
	A2D_ADC_DATA_delta <= (A2D_ADC_DATA_max < A2D_ADC_DATA_min) ? 10'h0: (A2D_ADC_DATA_max - A2D_ADC_DATA_min);  	
 	A2D_ADC_TAG_CAP_delta <= A2D_ADC_TAG_CAP;
 	A2D_ADC_DATA_max_cap <= A2D_ADC_DATA_max;  	
 	A2D_ADC_DATA_min_cap <= A2D_ADC_DATA_min;  	
  end
end
wire [9:0] A2D_ADC_DATA_delta_final;  	
assign  A2D_ADC_DATA_delta_final = (stim_mon_delta_data_sel == 2'b00) ? A2D_ADC_DATA_delta :
				   (stim_mon_delta_data_sel == 2'b01) ? A2D_ADC_DATA_min_cap :
				   (stim_mon_delta_data_sel == 2'b10) ? A2D_ADC_DATA_max_cap : A2D_ADC_DATA_delta;  	

assign A2D_ADC_DELTA_DATA_TAG	 = adc_mode ? {A2D_ADC_TAG_CAP_delta,2'b0,A2D_ADC_DATA_delta_final} : {4'b0,2'b0,A2D_ADC_DATA_delta_final};

//interrupt

//for one adc sampling int
//++++++++++++++++++++++++++++++++++++++++
wire stim_mon_int_sts_pulse;
wire stim_mon_sts_clr_sync_pulse;
wire stim_mon_int_en_flag;
assign stim_mon_int_en_flag = A2D_ADC_DATA_VLD ;
always @(posedge sysclk or negedge presetn) begin
  if(~presetn) begin
    stim_mon_int_sts <= 1'b0;
  end
  else if(stim_mon_sts_clr_sync_pulse | !stim_mon_int_en[1])begin
    stim_mon_int_sts <= 1'b0;
  end
  else if(stim_mon_int_en_flag)begin
    stim_mon_int_sts <= 1'b1;
  end
  else begin
    stim_mon_int_sts <= stim_mon_int_sts;
  end
end

common_pulse_rising u_stim_mon_int_sts_pulse(
.d_in(stim_mon_int_sts),
.clk(sysclk),
.rst_(presetn),
.d_out(stim_mon_int_sts_pulse)
);

common_pulse_async_clr u_stim_mon_clr_sync(
.d_in(stim_mon_int_clr),
.clk(sysclk),
.rst_(presetn),
.int_sts(stim_mon_int_sts),
.scan_mode(scan_mode),
.d_out(stim_mon_sts_clr_sync_pulse)
);
//+++++++++++++++++++++++++++++++++++++++

//for one adc sampling delta_int
//++++++++++++++++++++++++++++++++++++++++
wire stim_mon_delta_int_sts_pulse;
wire stim_mon_delta_sts_clr_sync_pulse;

wire stim_mon_delta_int_en_flag;
assign stim_mon_delta_int_en_flag = A2D_ADC_DELTA_DATA_VLD;
always @(posedge sysclk or negedge presetn) begin
  if(~presetn) begin
    stim_mon_delta_int_sts <= 1'b0;
  end
  else if(stim_mon_delta_sts_clr_sync_pulse | !stim_mon_int_en[0])begin
    stim_mon_delta_int_sts <= 1'b0;
  end
  else if(stim_mon_delta_int_en_flag)begin
    stim_mon_delta_int_sts <= 1'b1;
  end
  else begin
    stim_mon_delta_int_sts <= stim_mon_delta_int_sts;
  end
end

common_pulse_rising u_stim_mon_delta_int_sts_pulse(
.d_in(stim_mon_delta_int_sts),
.clk(sysclk),
.rst_(presetn),
.d_out(stim_mon_delta_int_sts_pulse)
);

common_pulse_async_clr u_stim_mon_delta_clr_sync(
.d_in(stim_mon_delta_int_clr),
.clk(sysclk),
.rst_(presetn),
.int_sts(stim_mon_delta_int_sts),
.scan_mode(scan_mode),
.d_out(stim_mon_delta_sts_clr_sync_pulse)
);
//+++++++++++++++++++++++++++++++++++++++




assign o_stim_mon_int = (((stim_mon_int_sts & !int_length_slct) | (stim_mon_int_sts_pulse & int_length_slct)) & stim_mon_int_topin_en[1]) |
			(((stim_mon_delta_int_sts & !int_length_slct) | (stim_mon_delta_int_sts_pulse & int_length_slct)) & stim_mon_int_topin_en[0]) ;


endmodule

