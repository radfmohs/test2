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

input wire bypass_adc_data_en,
input wire bypass_ignore_first,
input wire [3:0] stim_dly_tgt,   //from spi
//for int
input wire [4:0] stim_mon_int_en,   //from spi
input wire [4:0] stim_mon_int_topin_en,   //from spi
input wire [1:0] stim_mon_delta_data_sel,   //from spi
input wire [15:0]   	o_source_driver,
input wire [15:0]   	o_pulldn_driver, 

input wire stim_mon_int_clr,   //from spi
output reg stim_mon_int_sts,   //to spi
input wire stim_mon_delta_int_clr,   //from spi
output reg stim_mon_delta_int_sts,   //to spi
input wire stim_mon_cycle_int_clr,   //from spi
output reg stim_mon_cycle_int_sts,   //to spi

input wire[15:0]  stim_mon_leadoff_int_clr,   //from spi
output reg[15:0] stim_mon_leadoff_int_sts,   //to spi
input wire [15:0] stim_mon_short_int_clr,   //from spi
output reg[15:0] stim_mon_short_int_sts,   //to spi

input wire [9:0] threshold_leadoff,  	
input wire [9:0] threshold_short,  	
input wire [7:0] threshold_tgt,  	

output reg o_stim_mon_int,   //to INTB
input wire int_length_slct,

input wire adc_mode,   //0 is manual mode, 1 is auto mode
			//wavegen also need in manual mode if adc_mode is 0, should provide fixed stim waveform and source/pull
input wire [15:0] adc_cap_period, //0 means 1 true sample data out, 1 means 2 true sample data out	
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
output wire [15:0] A2D_ADC_DELTA_DATA_TAG,
output wire  one_cycle_data_vld,	
output reg[255:0] one_cycle_data

	
);


//the following code is saying only do the real sampling to this pair, then can transfer to next pair when meet to the target number 
//the condition is final_active_stim and has the sampling happen(A2D_ADC_DATA_EN) during final_active_stim period
//because adc sampling is always running, so the first A2D_ADC_DATA_EN maybe not this stim/pair result, it could be previous unuseful sampling result
//so better condidtion is when final_active_stim is high, then 2nd A2D_ADC_DATA_EN and following is real sampling data enable
//for example: A2D_ADC_DATA_EN  ___|--------|______
//             final_active_stim_______|-------|____
//so the first A2D_ADC_DATA_EN maybe not the fully stimulated source if sample clock is slower than stim clock
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

wire latch_ind;
//assign latch_ind = (A2D_ADC_DATA_EN & final_active_stim);
assign latch_ind = (bypass_adc_data_en ? 1'b1 : A2D_ADC_DATA_EN) & final_active_stim;

wire real_latch;
reg  real_latch_reg; //when real_latch=1, means the data indicated by A2D_ADC_DATA_EN will be used as sample data
		 //this signal does just make sure the first latch_ind in current adc_cap_period will be ignored
wire [15:0] adc_cap_period_tgt; //when bypass_ignore_first=1, then bigest adc_cap_period van be set to 16'hfffe	
//assign adc_cap_period_tgt = (bypass_ignore_first ? adc_cap_period :  (adc_cap_period + 16'b1));	
assign adc_cap_period_tgt =  adc_cap_period ;	
reg [15:0] adc_cap_period_cnt;	
always @ (posedge sysclk or negedge presetn) begin
  if (~presetn) 
 	real_latch_reg <= 1'b0;
  else if(bypass_ignore_first)
 	real_latch_reg <= 1'b0;
  else begin 
	if(!final_active_stim)
 		real_latch_reg <= 1'b0;
	else if (latch_ind) begin
		//if((adc_cap_period_cnt >= adc_cap_period_tgt) && real_latch) 
		if((adc_cap_period_cnt >= adc_cap_period_tgt) && real_latch_reg) 
 			real_latch_reg <= 1'b0;
  		else  
 			real_latch_reg <= 1'b1;
	end
  end
end
/*
reg final_active_stim_d1;
always @ (posedge sysclk or negedge presetn) begin
  if (~presetn) 
	final_active_stim_d1 <= 1'b0;
  else 
	final_active_stim_d1 <= final_active_stim;
end
*/
assign real_latch = bypass_ignore_first ? 1'b1 : real_latch_reg & final_active_stim;
wire sample_cap_now;
assign sample_cap_now = latch_ind & real_latch;

always @ (posedge sysclk or negedge presetn) begin
  if (~presetn) 
	adc_cap_period_cnt <= 16'b0;	
  //else if(latch_ind & (real_latch || (adc_cap_period_cnt == 16'b0))) begin
  else if(latch_ind) begin
	 if(real_latch || bypass_ignore_first) begin
		if(adc_cap_period_cnt >= adc_cap_period_tgt) 
			adc_cap_period_cnt <= 16'b0;	
  		else 
			adc_cap_period_cnt <= adc_cap_period_cnt + 16'b1;	
         end
  end
end


reg check_pulse;
reg check_pulse_d1;
reg check_pulse_cycle;
reg check_pulse_cycle_d1;
reg check_pulse_cycle_d2;
reg check_pulse_cycle_d3;
reg check_pulse_cycle_d4;
reg[3:0] pair_cnt;
always @ (posedge sysclk or negedge presetn) begin
  if (~presetn) begin 
 	pair_cnt <= 4'b0;
	check_pulse <= 1'b0;
  end else if(~adc_mode) begin
 	pair_cnt <= 4'b0;
	check_pulse <= 1'b0;
  end else if(latch_ind && (real_latch || bypass_ignore_first) && (adc_cap_period_cnt >= adc_cap_period_tgt)) begin
 	pair_cnt <= ((pair_cnt >= pair_num) || (pair_cnt == 4'd15)) ? 4'b0 : (pair_cnt + 4'b1);
	check_pulse <= 1'b1;
  end else
	check_pulse <= 1'b0;
end

always @ (posedge sysclk or negedge presetn) begin
  if (~presetn)  
	check_pulse_cycle <= 1'b0;
  else if(latch_ind && (real_latch || bypass_ignore_first) && (adc_cap_period_cnt >= adc_cap_period_tgt) && (pair_cnt >= pair_num))
	check_pulse_cycle <= 1'b1;
  else
	check_pulse_cycle <= 1'b0;
end

always @ (posedge sysclk or negedge presetn) begin
  if (~presetn) begin 
	check_pulse_d1 <= 1'b0;
	check_pulse_cycle_d1 <= 1'b0;
	check_pulse_cycle_d2 <= 1'b0;
	check_pulse_cycle_d3 <= 1'b0;
	check_pulse_cycle_d4 <= 1'b0;
  end else begin
	check_pulse_d1 <= check_pulse;
	check_pulse_cycle_d1 <= check_pulse_cycle;
	check_pulse_cycle_d2 <= check_pulse_cycle_d1;
	check_pulse_cycle_d3 <= check_pulse_cycle_d2;
	check_pulse_cycle_d4 <= check_pulse_cycle_d3;
  end
end

assign  A2D_ADC_DELTA_DATA_VLD = check_pulse_d1;	

assign  one_cycle_data_vld = check_pulse_cycle_d4;	



reg[9:0] A2D_ADC_DATA_CAP;
reg[3:0] A2D_ADC_TAG_CAP;
always @ (posedge sysclk or negedge presetn) begin
  if (~presetn) begin 
	A2D_ADC_DATA_CAP <= 10'b0;
	A2D_ADC_TAG_CAP <= 4'b0;
	A2D_ADC_DATA_VLD <= 1'b0;
  //end else if(A2D_ADC_DATA_EN) begin
  //end else if(A2D_ADC_DATA_EN & active_stim) begin
  //end else if(A2D_ADC_DATA_EN & final_active_stim) begin
  end else if(latch_ind & real_latch) begin
	A2D_ADC_DATA_CAP <= A2D_ADC_DATA;
	A2D_ADC_TAG_CAP <= pair_cnt;
	A2D_ADC_DATA_VLD <= 1'b1;
  end else begin
	A2D_ADC_DATA_VLD <= 1'b0;
  end
end

//leadoff/short
//++++++++++++++++++++++++++++

reg [7:0] leadoff_cnt;  	
reg [7:0] short_cnt;  	
/* 
//redundant logic
wire [9:0] comp_high;
wire [9:0] comp_low;
assign comp_high = (A2D_ADC_DATA_CAP >= 10'h200) ? A2D_ADC_DATA_CAP - 10'h200  : 10'h0;
assign comp_low  = (A2D_ADC_DATA_CAP <= 10'h200) ? 10'h200 - A2D_ADC_DATA_CAP  : 10'h0;

wire is_short_condition;
assign is_short_condition = (comp_high <= threshold_short) && (comp_low <= threshold_short);
wire is_leadoff_condition;
assign is_leadoff_condition = (comp_high >= threshold_leadoff) || (comp_low >= threshold_leadoff);
*/
wire [9:0] adc_abs_delta;
wire [9:0] adc_abs_delta_now;
wire is_short_condition_now;
wire is_leadoff_condition_now;
wire [7:0] leadoff_cnt_eff;
wire [7:0] short_cnt_eff;

assign adc_abs_delta =
    (A2D_ADC_DATA_CAP >= 10'h200) ?
    (A2D_ADC_DATA_CAP - 10'h200) :
    (10'h200 - A2D_ADC_DATA_CAP);
assign adc_abs_delta_now =
    (A2D_ADC_DATA >= 10'h200) ?
    (A2D_ADC_DATA - 10'h200) :
    (10'h200 - A2D_ADC_DATA);
assign is_short_condition =
    (adc_abs_delta <= threshold_short);
assign is_short_condition_now =
    (adc_abs_delta_now <= threshold_short);

assign is_leadoff_condition =
    (adc_abs_delta >= threshold_leadoff);
assign is_leadoff_condition_now =
    (adc_abs_delta_now >= threshold_leadoff);

assign leadoff_cnt_eff =
    (sample_cap_now && is_leadoff_condition_now && (leadoff_cnt < threshold_tgt)) ?
    (leadoff_cnt + 8'b1) : leadoff_cnt;
assign short_cnt_eff =
    (sample_cap_now && is_short_condition_now && (short_cnt < threshold_tgt)) ?
    (short_cnt + 8'b1) : short_cnt;


always @ (posedge sysclk or negedge presetn) begin
  if (~presetn) begin
 	leadoff_cnt <= 8'b0;  	
  end else if(check_pulse) begin
 	leadoff_cnt <= 8'b0;  	
  end else if (sample_cap_now && is_leadoff_condition_now && (leadoff_cnt < threshold_tgt)) begin
  	leadoff_cnt <= leadoff_cnt + 8'b1;  	
  end 
end

//  end else if(A2D_ADC_DATA_VLD) begin
//        if( ((comp_high <= threshold_short) & (comp_high != 10'h0))
//          | ((comp_low <= threshold_short)  & (comp_low  != 10'h0))
//          | ((comp_high == 10'h0) & (comp_low == 10'h0)))

always @ (posedge sysclk or negedge presetn) begin
  if (~presetn) begin
        short_cnt   <= 8'b0;
  end else if(check_pulse) begin
        short_cnt   <= 8'b0;
  end else if (sample_cap_now && is_short_condition_now && (short_cnt < threshold_tgt)) begin
        short_cnt <= short_cnt + 8'b1;
  end
end

/*
//not useful
//======================
reg leadoff_pulse;
reg short_pulse;
always @ (posedge sysclk or negedge presetn) begin
  if (~presetn) begin
	leadoff_pulse <= 1'b0;
  end else if(leadoff_cnt >= threshold_tgt) begin
	leadoff_pulse <= 1'b1;
  end else if(check_pulse) begin
	leadoff_pulse <= 1'b0;
  end else
	leadoff_pulse <= 1'b0;
end

always @ (posedge sysclk or negedge presetn) begin
  if (~presetn) begin
	short_pulse <= 1'b0;
  end else if(short_cnt >= threshold_tgt) begin
	short_pulse <= 1'b1;
  end else if(check_pulse) begin
	short_pulse <= 1'b0;
  end else
	short_pulse <= 1'b0;
end
//=============================
*/

reg [3:0] previous_pair_cnt;
always @(posedge sysclk or negedge presetn) begin
  if(~presetn)
    previous_pair_cnt <= 4'b0;
  else
    previous_pair_cnt <= pair_cnt; //
end

reg[15:0] leadoff_pulse_pair;
reg[15:0] short_pulse_pair;
always @(posedge sysclk or negedge presetn) begin
  if(~presetn) begin
	leadoff_pulse_pair <= 16'b0;
	short_pulse_pair   <= 16'b0;
  end else if(check_pulse) begin
	leadoff_pulse_pair <=  (leadoff_cnt_eff >= threshold_tgt) ? (16'b1 << previous_pair_cnt) : 16'b0;
	short_pulse_pair <=  (short_cnt_eff >= threshold_tgt) ?(16'b1 << previous_pair_cnt) : 16'b0;
  end else begin
	leadoff_pulse_pair <= 16'b0;
	short_pulse_pair   <= 16'b0;
  end
end
//==========================
wire[15:0] stim_mon_leadoff_int_sts_pulse;
wire[15:0] stim_mon_leadoff_sts_clr_sync_pulse;

wire[15:0] stim_mon_leadoff_int_en_flag;
assign stim_mon_leadoff_int_en_flag = leadoff_pulse_pair;

genvar i;
generate
  for(i=0; i<16; i=i+1) begin
always @(posedge sysclk or negedge presetn) begin
  if(~presetn) begin
    stim_mon_leadoff_int_sts[i] <= 1'b0;
  end
  else if(stim_mon_leadoff_int_en_flag[i])begin
    stim_mon_leadoff_int_sts[i] <= 1'b1;
  end
  else if(stim_mon_leadoff_sts_clr_sync_pulse[i] | (!stim_mon_int_en[3]))begin
    stim_mon_leadoff_int_sts[i] <= 1'b0;
  end
  else begin
    stim_mon_leadoff_int_sts[i] <= stim_mon_leadoff_int_sts[i];
  end
end

common_pulse_rising u_stim_mon_leadoff_int_sts_pulse(
.d_in(stim_mon_leadoff_int_sts[i]),
.clk(sysclk),
.rst_(presetn),
.d_out(stim_mon_leadoff_int_sts_pulse[i])
);

common_pulse_async_clr u_stim_mon_leadoff_clr_sync(
.d_in(stim_mon_leadoff_int_clr[i]),
.clk(sysclk),
.rst_(presetn),
.int_sts(stim_mon_leadoff_int_sts[i]),
.scan_mode(scan_mode),
.d_out(stim_mon_leadoff_sts_clr_sync_pulse[i])
);

end

endgenerate
//========================
wire[15:0] stim_mon_short_int_sts_pulse;
wire[15:0] stim_mon_short_sts_clr_sync_pulse;

wire[15:0] stim_mon_short_int_en_flag;
assign stim_mon_short_int_en_flag = short_pulse_pair;

genvar j;
generate
  for(j=0; j<16; j=j+1) begin
always @(posedge sysclk or negedge presetn) begin
  if(~presetn) begin
    stim_mon_short_int_sts[j] <= 1'b0;
  end
  else if(stim_mon_short_int_en_flag[j])begin
    stim_mon_short_int_sts[j] <= 1'b1;
  end
  else if(stim_mon_short_sts_clr_sync_pulse[j] | (!stim_mon_int_en[4]))begin
    stim_mon_short_int_sts[j] <= 1'b0;
  end
  else begin
    stim_mon_short_int_sts[j] <= stim_mon_short_int_sts[j];
  end
end

common_pulse_rising u_stim_mon_short_int_sts_pulse(
.d_in(stim_mon_short_int_sts[j]),
.clk(sysclk),
.rst_(presetn),
.d_out(stim_mon_short_int_sts_pulse[j])
);

common_pulse_async_clr u_stim_mon_short_clr_sync(
.d_in(stim_mon_short_int_clr[j]),
.clk(sysclk),
.rst_(presetn),
.int_sts(stim_mon_short_int_sts[j]),
.scan_mode(scan_mode),
.d_out(stim_mon_short_sts_clr_sync_pulse[j])
);

end

endgenerate

//+++++++++++++++++++++++++++
wire[3:0] safe_pair_idx;
assign safe_pair_idx = (pair_cnt > pair_num) ? 4'b0 : pair_cnt;
wire [3:0]  D2A_STIM_PAD0_wire;
wire [3:0]  D2A_STIM_PAD1_wire;	
assign D2A_STIM_PAD0_wire = adc_mode ? stim_pad0_tgt[safe_pair_idx] : stim_pad0_tgt[4'b0];
assign D2A_STIM_PAD1_wire = adc_mode ? stim_pad1_tgt[safe_pair_idx] : stim_pad1_tgt[4'b0];
assign A2D_ADC_DATA_TAG	 = adc_mode ? {A2D_ADC_TAG_CAP,2'b0,A2D_ADC_DATA_CAP} : {4'b0,2'b0,A2D_ADC_DATA_CAP};
assign 	D2A_STIM_PAD0 = D2A_STIM_PAD0_wire;
assign 	D2A_STIM_PAD1 = D2A_STIM_PAD1_wire;	

/*
always @ (posedge sysclk or negedge presetn) begin
  if (~presetn) begin 
 	D2A_STIM_PAD0 <= 4'b0;
 	D2A_STIM_PAD1 <= 4'b0;	
  end else begin
 	D2A_STIM_PAD0 <= D2A_STIM_PAD0_wire;
 	D2A_STIM_PAD1 <= D2A_STIM_PAD1_wire;	
  end
end
*/
//calculate the peak to peak

reg [9:0] A2D_ADC_DATA_max;  	
reg [9:0] A2D_ADC_DATA_min;  	
reg [9:0] A2D_ADC_DATA_delta;  	
reg [9:0] A2D_ADC_DATA_max_cap;  	
reg [9:0] A2D_ADC_DATA_min_cap;  	
reg [9:0] A2D_ADC_DATA_last_cap;  	
wire first_sample_in_window;
wire [9:0] A2D_ADC_DATA_max_eff;
wire [9:0] A2D_ADC_DATA_min_eff;
assign first_sample_in_window = (A2D_ADC_DATA_max < A2D_ADC_DATA_min);
assign A2D_ADC_DATA_max_eff =
    sample_cap_now ?
    (first_sample_in_window ? A2D_ADC_DATA :
    ((A2D_ADC_DATA >= A2D_ADC_DATA_max) ? A2D_ADC_DATA : A2D_ADC_DATA_max)) :
    A2D_ADC_DATA_max;
assign A2D_ADC_DATA_min_eff =
    sample_cap_now ?
    (first_sample_in_window ? A2D_ADC_DATA :
    ((A2D_ADC_DATA <= A2D_ADC_DATA_min) ? A2D_ADC_DATA : A2D_ADC_DATA_min)) :
    A2D_ADC_DATA_min;
always @ (posedge sysclk or negedge presetn) begin
  if (~presetn)  
	A2D_ADC_DATA_max <= 10'h0;  	
  //else if(check_pulse_d1) 
  else if(check_pulse)   //check_pulse has higher priority, if check_pulse happen at same time with A2D_ADC_DATA_VLD,
			//then A2D_ADC_DATA_VLD data will be ignored 
	A2D_ADC_DATA_max <= 10'h0;  	
  else if(sample_cap_now) 
	A2D_ADC_DATA_max <= A2D_ADC_DATA_max_eff;  	
end

always @ (posedge sysclk or negedge presetn) begin
  if (~presetn)  
	A2D_ADC_DATA_min <= 10'h3ff;  	
  //else if(check_pulse_d1) 
  else if(check_pulse) 
	A2D_ADC_DATA_min <= 10'h3ff;  	
  else if(sample_cap_now) 
	A2D_ADC_DATA_min <= A2D_ADC_DATA_min_eff;  	
end

reg[3:0] A2D_ADC_TAG_CAP_delta;
always @ (posedge sysclk or negedge presetn) begin
  if (~presetn) begin 
	A2D_ADC_DATA_delta <= 10'h0;  	
	A2D_ADC_TAG_CAP_delta <= 4'b0;
	A2D_ADC_DATA_max_cap <= 10'h0;  	
	A2D_ADC_DATA_min_cap <= 10'h0;  	
	A2D_ADC_DATA_last_cap <= 10'h0;  	
  end else if(check_pulse) begin 
	A2D_ADC_DATA_delta <= (A2D_ADC_DATA_max_eff < A2D_ADC_DATA_min_eff) ? 10'h0: (A2D_ADC_DATA_max_eff - A2D_ADC_DATA_min_eff);  	
	A2D_ADC_TAG_CAP_delta <= A2D_ADC_TAG_CAP;
	A2D_ADC_DATA_max_cap <= A2D_ADC_DATA_max_eff;  	
	A2D_ADC_DATA_min_cap <= A2D_ADC_DATA_min_eff;  	
	A2D_ADC_DATA_last_cap <= A2D_ADC_DATA_CAP;  	
  end
end
wire [9:0] A2D_ADC_DATA_delta_final;  	
assign  A2D_ADC_DATA_delta_final = (stim_mon_delta_data_sel == 2'b00) ? A2D_ADC_DATA_delta :
				   (stim_mon_delta_data_sel == 2'b01) ? A2D_ADC_DATA_min_cap :
				   (stim_mon_delta_data_sel == 2'b10) ? A2D_ADC_DATA_max_cap : A2D_ADC_DATA_last_cap;  	

assign A2D_ADC_DELTA_DATA_TAG	 = adc_mode ? {A2D_ADC_TAG_CAP_delta,2'b0,A2D_ADC_DATA_delta_final} : {4'b0,2'b0,A2D_ADC_DATA_delta_final};
//One data is latched per adc_cap_period, and these are then organized into pair_num sets of data, which are read out in a single SPI operation

reg[255:0] one_cycle_data_bak;
always @ (posedge sysclk or negedge presetn) begin
  if (~presetn)  
	one_cycle_data_bak <= 256'b0;
  else if (check_pulse_cycle_d4) // 
    	one_cycle_data_bak <= 256'b0;
  else if(A2D_ADC_DELTA_DATA_VLD)
	one_cycle_data_bak <= {one_cycle_data_bak[239:0],A2D_ADC_DELTA_DATA_TAG};
end

always @ (posedge sysclk or negedge presetn) begin
  if (~presetn)  
	one_cycle_data <= 256'b0;
  else if(check_pulse_cycle_d3)
	one_cycle_data <= one_cycle_data_bak;
end

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
  else if(stim_mon_int_en_flag)begin
    stim_mon_int_sts <= 1'b1;
  end
  else if(stim_mon_sts_clr_sync_pulse | !stim_mon_int_en[1])begin
    stim_mon_int_sts <= 1'b0;
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
  else if(stim_mon_delta_int_en_flag)begin
    stim_mon_delta_int_sts <= 1'b1;
  end
  else if(stim_mon_delta_sts_clr_sync_pulse | !stim_mon_int_en[0])begin
    stim_mon_delta_int_sts <= 1'b0;
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
//for one cycle adc sampling data int
//++++++++++++++++++++++++++++++++++++++++
wire stim_mon_cycle_int_sts_pulse;
wire stim_mon_cycle_sts_clr_sync_pulse;

wire stim_mon_cycle_int_en_flag;
assign stim_mon_cycle_int_en_flag = one_cycle_data_vld;
always @(posedge sysclk or negedge presetn) begin
  if(~presetn) begin
    stim_mon_cycle_int_sts <= 1'b0;
  end
  else if(stim_mon_cycle_int_en_flag)begin
    stim_mon_cycle_int_sts <= 1'b1;
  end
  else if(stim_mon_cycle_sts_clr_sync_pulse | !stim_mon_int_en[2])begin
    stim_mon_cycle_int_sts <= 1'b0;
  end
  else begin
    stim_mon_cycle_int_sts <= stim_mon_cycle_int_sts;
  end
end

common_pulse_rising u_stim_mon_cycle_int_sts_pulse(
.d_in(stim_mon_cycle_int_sts),
.clk(sysclk),
.rst_(presetn),
.d_out(stim_mon_cycle_int_sts_pulse)
);

common_pulse_async_clr u_stim_mon_cycle_clr_sync(
.d_in(stim_mon_cycle_int_clr),
.clk(sysclk),
.rst_(presetn),
.int_sts(stim_mon_cycle_int_sts),
.scan_mode(scan_mode),
.d_out(stim_mon_cycle_sts_clr_sync_pulse)
);
//+++++++++++++++++++++++++++++++++++++++

wire stim_mon_leadoff_all_int_sts;
wire stim_mon_short_all_int_sts;
wire stim_mon_leadoff_all_int_sts_pulse;
wire stim_mon_short_all_int_sts_pulse;
assign stim_mon_leadoff_all_int_sts = |stim_mon_leadoff_int_sts;
assign stim_mon_short_all_int_sts = |stim_mon_short_int_sts;
assign stim_mon_leadoff_all_int_sts_pulse = |stim_mon_leadoff_int_sts_pulse;
assign stim_mon_short_all_int_sts_pulse = |stim_mon_short_int_sts_pulse;

wire o_stim_mon_int_bak;
assign o_stim_mon_int_bak = (((stim_mon_int_sts & !int_length_slct) | (stim_mon_int_sts_pulse & int_length_slct)) & stim_mon_int_topin_en[1]) |
			    (((stim_mon_delta_int_sts & !int_length_slct) | (stim_mon_delta_int_sts_pulse & int_length_slct)) & stim_mon_int_topin_en[0]) |
		            (((stim_mon_cycle_int_sts & !int_length_slct) | (stim_mon_cycle_int_sts_pulse & int_length_slct)) & stim_mon_int_topin_en[2]) |
			    (((stim_mon_leadoff_all_int_sts & !int_length_slct) | (stim_mon_leadoff_all_int_sts_pulse & int_length_slct)) & stim_mon_int_topin_en[3]) |
			    (((stim_mon_short_all_int_sts & !int_length_slct) | (stim_mon_short_all_int_sts_pulse & int_length_slct)) & stim_mon_int_topin_en[4]);

always @(posedge sysclk or negedge presetn) begin
  if(~presetn) 
 	o_stim_mon_int <= 1'b0;
  else
 	o_stim_mon_int <= o_stim_mon_int_bak; 
end


endmodule
