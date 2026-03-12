//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap ENS2  
// File name:    arb_wave_gen.sv 
// Module Name : arb_wave_gen
// Description : Generates Arbitrary Waveforms
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author          Description      
//------------------------------------------------------------------------------
// 0.1         17/06/2021   Mohsen Radfar                 Initial Rev 
//------------------------------------------------------------------------------

`timescale 1 ns /  1 ps

module arb_wave_gen 
#( // parameters
	parameter HLF_WV_NO_PTS = 6, // number of points in the input quantised half (of the period) wave (e.g. 64 points for first half of the sine wave). Ensure it is a power of 2 value
	OUT_NO_BITS = 8 // number of bits for the generated output value (which goes into the DAC)
)
( //arguments
	input wire [15:0] rest_t, //resting time (in microseconds) between the positive side and the negative side of the wave in a period
	input wire [31:0] silent_t, //silent time (in microseconds) before the next wave period
	input wire [15:0] rest_t1, //resting time (in microseconds) between the positive side and the negative side of the wave in a period
	input wire [31:0] silent_t1, //silent time (in microseconds) before the next wave period
	input wire [15:0] rest_t2, //resting time (in microseconds) between the positive side and the negative side of the wave in a period
	input wire [31:0] silent_t2, //silent time (in microseconds) before the next wave period
	input wire [15:0] hlf_wave_per, //positive half of the wave of the arbitrary (e.g. sine or square) wave (in microseconds)
	input wire [15:0] neg_hlf_wave_per, //negative half of the wave of the arbitrary (e.g. sine or square) wave (in microseconds)
	input wire [15:0] hlf_wave_per1, //positive half of the wave of the arbitrary (e.g. sine or square) wave (in microseconds)
	input wire [15:0] neg_hlf_wave_per1, //negative half of the wave of the arbitrary (e.g. sine or square) wave (in microseconds)
	input wire [15:0] hlf_wave_per2, //positive half of the wave of the arbitrary (e.g. sine or square) wave (in microseconds)
	input wire [15:0] neg_hlf_wave_per2, //negative half of the wave of the arbitrary (e.g. sine or square) wave (in microseconds)
	input wire [7:0] point_config,
	input wire [15:0] alt_lim, //number of clocks for a period of alt period
	//input wire [15:0] alter_per, //period of alternating frequency (in nanoseconds); ensure it is larger than a clock period
	//input wire [15:0] alter_silent_t, //period of time after the alternating for no signal (in nanoseconds); ensure it is larger than a clock period
	input wire [15:0] alt_silent_lim, //number of clocks for each silent period
	input wire [15:0] alt_rest_lim,
	//input wire [15:0] delay_t, //delay after enable before the wave generation starts (in nanoseconds); ensure it is larger than a clock period
	input wire [15:0] delay_lim, //number of clocks for initial delay before wave is generated
//	input wire [7:0] clk_freq, //clock frequency in MHz
	//input wire [(2**HLF_WV_NO_PTS) * OUT_NO_BITS - 1:0] in_wave,
	input wire [7:0] i_config_reg, //bit 0:rest enable, 1:negative enable, 2: silent enable, 3: source B enable, 4: alternating (+/-) the positive side, 5: continue repeating the waveform if one (see wg_sriver_rg.v), works together with interrupt if zero
	input wire [7:0]  pullba_ctrl,
	input wire clk,
	input wire reset,
	input wire enable,     
        input wire scan_mode,  //tri add
        input wire int_length_slct,
        input wire [4:0] period_sel,
        input wire [7:0] reg_wg_cal_addr,
        input wire [7:0] wg_driver_int_addr0,
        input wire [7:0] wg_driver_int_addr1,
        input wire       wg_driver_int_en,
        input wire       addr0_int_clr,
        input wire       addr1_int_clr,
        input wire [7:0] wg_driver_int_cnt,
        input wire       no_of_num_slient_disable,
        input wire [15:0] no_of_num_slient_tar,
        output wire       wg_driver_interrupt,
        output wire [1:0] wg_driver_int_sts,

        input wire [3:0]   i_data_scl,                 
        input wire [7:0]   i_reg_wg_driver_neg_scale,  
        input wire [7:0]   i_wg_driver_pos_scale,      
        input wire [7:0]   i_reg_wg_driver_neg_offset, 
        input wire [7:0]   i_reg_wg_driver_pos_offset, 
        input wire [5:0]   i_ems_data_ctrl,
        input wire [7:0]   alt_ems_cnt_tar,

        output reg [3:0] data_scl,  
        output reg [3:0] ems_data_ctrl,                 
        output reg [7:0] wg_driver_neg_scale,        
        output reg [7:0] wg_driver_pos_scale,        
        output reg [7:0] wg_driver_neg_offset,       
        output reg [7:0] wg_driver_pos_offset, 

        output wire [1:0] o_period_num,
	output wire [7:0] o_in_wave_addr,
	output wire [7:0] o_ems_wave_addr,
	output reg  [1:0] source //bit 0: source a, 1: source b
);

localparam  S0 = 3'h0;
localparam  S1 = 3'h1;
localparam  S2 = 3'h2;
localparam  S3 = 3'h3;
localparam  S4 = 3'h4;
localparam  S5 = 3'h5;
localparam  S6 = 3'h6;
localparam  S7 = 3'h7;

reg [7:0] in_wave_addr;

reg [2:0] state;

wire [15:0] hlf_wave_lim; // number of clocks for positive half wave
wire [15:0] neg_hlf_wave_lim; // number of clocks for negative half wave
reg [31:0] hlf_wave_cnt;
//wire [15:0] alt_lim; // number of clocks for a period of alt period
reg [17:0] alt_cnt;
wire [15:0] nxt_wave_val_lim; // number of clocks for positive value of the wave
wire [15:0] neg_nxt_wave_val_lim; // number of clocks for negative value of the wave
reg [15:0] nxt_wave_val_cnt; // count until (2**HLF_WV_NO_PTS)
wire [15:0] rest_lim; // number of clocks for each rest period
//reg [15:0] rest_cnt;
wire [31:0] silent_lim; // number of clocks for each silent period
//reg [15:0] rest_cnt;
//wire [15:0] alt_silent_lim; // number of clocks for each silent period
//wire [15:0] delay_lim; // number of clocks for initial delay before wave is generated
//reg [15:0] silent_cnt;

wire gclk; //gated clock
reg [1:0]   period_num;
wire        waveform_change_flag;
wire        point_will_overflow,point_will_overflow_128;
wire [7:0]  point_will_overflow_max;
wire [15:0] next_addr;
wire [15:0] hlf_wave_cnt_max;
wire [15:0] hlf_wave_cnt_max1;
wire [15:0] hlf_wave_cnt_max2;
wire [15:0] hlf_wave_cnt_max_m1;

reg [15:0]  no_of_num_before_slient;
wire[7:0] config_reg;
wire no_of_num_slient_valid;
      
assign no_of_num_slient_valid = (no_of_num_before_slient==no_of_num_slient_tar);
assign config_reg = (!no_of_num_slient_disable)? i_config_reg : i_config_reg & {5'b11111,no_of_num_slient_valid,2'b11};

assign o_period_num   = period_num;
//assign o_hlf_wave_cnt = hlf_wave_cnt[7:0];

assign hlf_wave_cnt_max =(point_config <= 8'd128)?  {8'b0,point_config} :  16'd128;

//assign hlf_wave_cnt_max =(period_sel[2:0]==3'b000)? (point_config <= 8'd128)?  {24'b0,point_config} :  32'd128;
//                          (period_sel[2:0]==3'b001)? (point_config <= 8'd64) ?  {24'b0,point_config} :  8'd64:
//                          (period_sel[2:0]==3'b010)? (point_config <= 8'd42) ?  {24'b0,point_config} :  8'd42:                       
//                                                     (point_config <= 8'd128)?  {24'b0,point_config} :  8'd128;
//assign hlf_wave_cnt_max  = ((!config_reg[7])^config_reg[1])? hlf_wave_cnt_max1 : hlf_wave_cnt_max2;

assign hlf_wave_cnt_max_m1 = hlf_wave_cnt_max-1;
assign next_addr = (hlf_wave_cnt + 1 < {16'h0,hlf_wave_cnt_max}) ? hlf_wave_cnt[15:0] + 1 : 0;
assign point_will_overflow_128 = period_sel[4] ? ((hlf_wave_cnt[15:0] == hlf_wave_cnt_max_m1) && (state == S3)) && (({1'b0,in_wave_addr}+{1'b0,hlf_wave_cnt_max[7:0]}) > 9'd128):
                                                 ((hlf_wave_cnt[15:0] == hlf_wave_cnt_max_m1) && (state != S0)) && (({1'b0,in_wave_addr}+{1'b0,hlf_wave_cnt_max[7:0]}) > 9'd128);

assign point_will_overflow_max = ((period_sel[2:0]==3'b000) && ((!config_reg[7])^config_reg[1]))? 8'd128:
                                 ((period_sel[2:0]==3'b001) && ((!config_reg[7])^config_reg[1]))? (hlf_wave_cnt_max[7:0]<<1) :                        
                                 ((period_sel[2:0]==3'b010) && ((!config_reg[7])^config_reg[1]))? (hlf_wave_cnt_max[7:0]<<1) + hlf_wave_cnt_max[7:0]: 
                                 (({period_sel[4],period_sel[2:0]}==4'b1000) && !((!config_reg[7])^config_reg[1]))? 8'd128:
                                 (({period_sel[4],period_sel[2:0]}==4'b1001) && !((!config_reg[7])^config_reg[1]))? (hlf_wave_cnt_max[7:0]<<1) :                        
                                 (({period_sel[4],period_sel[2:0]}==4'b1010) && !((!config_reg[7])^config_reg[1]))? (hlf_wave_cnt_max[7:0]<<1) + (hlf_wave_cnt_max[7:0]) :
                                 (({period_sel[4],period_sel[2:0]}==4'b0000) && !((!config_reg[7])^config_reg[1]))? 8'd128:
                                 (({period_sel[4],period_sel[2:0]}==4'b0001) && !((!config_reg[7])^config_reg[1]))? (hlf_wave_cnt_max[7:0]<<2) :                        
                                 (({period_sel[4],period_sel[2:0]}==4'b0010) && !((!config_reg[7])^config_reg[1]))? (hlf_wave_cnt_max[7:0]<<2) + (hlf_wave_cnt_max[7:0]<<1) : 8'd128;

assign point_will_overflow = ((in_wave_addr== point_will_overflow_max - 1) && (state != S7)) || point_will_overflow_128;

wire state1_end,state2_end,state3_end,state4_end;


assign state1_end = ((hlf_wave_cnt[15:0] == hlf_wave_cnt_max_m1) && ((nxt_wave_val_cnt == (nxt_wave_val_lim-1)) && (state == S1))); 
assign state2_end = (((hlf_wave_cnt == {16'h0,(rest_lim-1'b1)}        ) && (state == S2))); 
assign state3_end = ((hlf_wave_cnt[15:0] == hlf_wave_cnt_max_m1) && ((nxt_wave_val_cnt == (neg_hlf_wave_lim-1)) && (state == S3))); 
assign state4_end = (((hlf_wave_cnt == (silent_lim-1)      ) && (state == S4))); 

assign waveform_change_flag= (config_reg[7] &&  config_reg[0] && config_reg[1] && config_reg[2] && (!(&(rest_lim -1))))? state2_end : 
                             ( config_reg[2] && (!(&(silent_lim -1))))? state4_end : 
                             ( config_reg[1] && (!(&(neg_nxt_wave_val_lim -1))))? state3_end : 
                             ( config_reg[0] && (!(&(rest_lim -1))))? state2_end : 
                             (!config_reg[7] && (!(&(hlf_wave_lim -1))))? state1_end : 1'b0;

assign hlf_wave_lim = (period_sel[2:0]==3'b000)? hlf_wave_per : 
                      (period_sel[2:0]==3'b001)? (period_num==2'b00)? hlf_wave_per : hlf_wave_per1 :           
                      (period_sel[2:0]==3'b010)? (period_num==2'b00)? hlf_wave_per : (period_num==2'b01)? hlf_wave_per1 :   hlf_wave_per2 : hlf_wave_per  ;

assign neg_hlf_wave_lim = (period_sel[2:0]==3'b000)? neg_hlf_wave_per : 
                      (period_sel[2:0]==3'b001)? (period_num==2'b00)? neg_hlf_wave_per : neg_hlf_wave_per1 :           
                      (period_sel[2:0]==3'b010)? (period_num==2'b00)? neg_hlf_wave_per : (period_num==2'b01)? neg_hlf_wave_per1 :   neg_hlf_wave_per2 : neg_hlf_wave_per  ;

//assign alt_lim = alter_per * clk_freq / 1000;
assign nxt_wave_val_lim = hlf_wave_lim; //hlf_wave_lim >> $clog2((2**HLF_WV_NO_PTS)) OR hlf_wave_lim >> HLF_WV_NO_PTS
assign neg_nxt_wave_val_lim = neg_hlf_wave_lim; //hlf_wave_lim >> $clog2((2**HLF_WV_NO_PTS)) OR hlf_wave_lim >> HLF_WV_NO_PTS
assign rest_lim = (period_sel[2:0]==3'b000)? rest_t : 
                  (period_sel[2:0]==3'b001)? (period_num==2'b00)? rest_t : rest_t1 :           
                  (period_sel[2:0]==3'b010)? (period_num==2'b00)? rest_t : (period_num==2'b01)? rest_t1 :   rest_t2 : rest_t;

assign silent_lim = (period_sel[2:0]==3'b000)? silent_t : 
                    (period_sel[2:0]==3'b001)? (period_num==2'b00)? silent_t : silent_t1 :           
                    (period_sel[2:0]==3'b010)? (period_num==2'b00)? silent_t : (period_num==2'b01)? silent_t1 :   silent_t2 : silent_t;



reg [7:0] in_wave_addr_temp;
always @(posedge clk, negedge reset) begin
	if (!reset) begin
        in_wave_addr_temp <= 8'h00;
        end
        else begin
          if(enable) begin
              if(!period_sel[3] || point_will_overflow && !(period_sel[4] && ((state == S1) || (state == S2) || (state == S6) || (state == S7)))) begin
                in_wave_addr_temp <= 8'h00;
              end    
              else if(period_sel[4]) begin
                 if ((hlf_wave_cnt[15:0] == hlf_wave_cnt_max_m1) && (state == S3)) begin
                   in_wave_addr_temp <= in_wave_addr + 1;
                 end             
              end   
              else if ((hlf_wave_cnt[15:0] == hlf_wave_cnt_max_m1) && (state != S0) && (state != S6) && (state != S7)) begin
                   in_wave_addr_temp <= in_wave_addr + 1;
              end
          end
          else begin
                   in_wave_addr_temp <= 8'h00;
          end
        end
end

always @(posedge clk, negedge reset) begin
	if (!reset) begin
        period_num <= 2'b00;
        end
        else begin 
            if(enable) begin
                   if(period_sel[2:0]==3'b000) begin
                   period_num <= 2'b00;
                   end
                   else if((period_sel[2:0]==3'b001) && waveform_change_flag) begin
                         if(period_num==2'b01)
                           period_num <= 2'b00;
                         else
                           period_num <= period_num + 1'b1;
                   end
                   else if((period_sel[2:0]==3'b010) && waveform_change_flag) begin
                         if(period_num==2'b10)
                           period_num <= 2'b00;
                         else
                           period_num <= period_num + 1'b1;       
                   end
             end
             else begin
                   period_num <= 2'b00;
             end
        end
end

always @(posedge clk, negedge reset) begin
	if (!reset) begin
        no_of_num_before_slient <= 16'h00;
        end
        else begin 
           if(enable) begin
               if(!no_of_num_slient_disable)begin
                 no_of_num_before_slient <= 16'h00;
               end
               else if((state==S1 | state==S3) & ((hlf_wave_cnt[15:0] == 16'h0000) && (nxt_wave_val_cnt == (nxt_wave_val_lim-1))) && ((!config_reg[7])^config_reg[1]))begin
                 no_of_num_before_slient  <= no_of_num_before_slient + 16'b1;
               end
               else if((state==S3) & ((hlf_wave_cnt[15:0] == 16'h0000) && (nxt_wave_val_cnt == (nxt_wave_val_lim-1))) && !((!config_reg[7])^config_reg[1]))begin
                 no_of_num_before_slient  <= no_of_num_before_slient + 16'b1;
               end
               else if((state==S4) & (hlf_wave_cnt == (silent_lim-1)))begin
                 no_of_num_before_slient <= 16'h00;
               end
           end
           else begin
              no_of_num_before_slient <= 16'h00;           
           end
        end
end


//Used for avioding disturb when scale/offset/MSB_SEL is wrote by SPI
wire cal_addr_match;
wire [7:0] reg_wg_cal_addr_temp;


reg  enable_dly1;
wire enable_rising;
assign enable_rising = enable & !enable_dly1;
always @(posedge clk, negedge reset) begin
   if (!reset) begin
       enable_dly1             <= 1'b0;
   end
   else begin 
       enable_dly1             <= enable;
   end
end

always @(posedge clk, negedge reset) begin : DISTURB
   if (!reset) begin
       data_scl             <= 4'b0;
       wg_driver_neg_scale  <= 8'h01;
       wg_driver_pos_scale  <= 8'h01;
       wg_driver_neg_offset <= 8'b0;
       wg_driver_pos_offset <= 8'b0;
       ems_data_ctrl        <= 3'b0;
   end
   else if ((cal_addr_match & enable) | enable_rising) begin 
       data_scl             <= i_data_scl;
       ems_data_ctrl        <= i_ems_data_ctrl[3:0];
       wg_driver_neg_scale  <= i_reg_wg_driver_neg_scale;
       wg_driver_pos_scale  <= i_wg_driver_pos_scale;
       wg_driver_neg_offset <= i_reg_wg_driver_neg_offset;
       wg_driver_pos_offset <= i_reg_wg_driver_pos_offset;
   end
end
//END

//used for cotrol EMS waveform
reg  [7:0] alt_ems_cnt;
reg  [7:0] alt_ems_addr_cnt;
wire [7:0] alt_ems_addr_tar;
wire       alt_ems_cnt_flg,alt_ems_addr_flg,ems_enable;
wire       ams_en;
assign     ams_en           = i_ems_data_ctrl[3];

assign ems_enable       = enable & (state==S1) & ams_en & config_reg[4] & (|alt_ems_cnt_tar);
assign alt_ems_cnt_flg  = (alt_cnt == alt_lim + alt_rest_lim + alt_silent_lim -1);
assign alt_ems_addr_flg = (alt_ems_cnt==alt_ems_cnt_tar-1) & alt_ems_cnt_flg;  
assign alt_ems_addr_tar = 8'd127-hlf_wave_cnt_max[7:0]; 

always @(posedge clk, negedge reset) begin : EMS_CNT
   if (!reset) begin
       alt_ems_cnt             <= 8'b0;
   end
   else if (ems_enable) begin 
          if((alt_ems_cnt == (alt_ems_cnt_tar-1)) & alt_ems_cnt_flg)begin            
             alt_ems_cnt             <= 8'b0;
          end         
          else if(alt_ems_cnt_flg)begin
             alt_ems_cnt       <= alt_ems_cnt + 1'b1;
          end
   end
   else begin
       alt_ems_cnt             <= 8'b0;
   end
end

always @(posedge clk, negedge reset) begin : EMS_ADDR
   if (!reset) begin
       alt_ems_addr_cnt             <= 8'b0;
   end
   else if (ems_enable) begin 
          if((alt_ems_addr_cnt == alt_ems_addr_tar) & (alt_ems_cnt == (alt_ems_cnt_tar-1)) & alt_ems_cnt_flg)begin            
             alt_ems_addr_cnt       <= 8'b0;
          end         
          else if(alt_ems_addr_flg)begin
             alt_ems_addr_cnt       <= alt_ems_addr_cnt + 1'b1;
          end
   end
   else begin
       alt_ems_addr_cnt             <= 8'b0;
   end
end


assign o_ems_wave_addr  = ems_enable? alt_ems_addr_tar + in_wave_addr +1'b1 : 8'h00;
assign o_in_wave_addr   = ems_enable? alt_ems_addr_cnt : in_wave_addr;


//ENDS
assign reg_wg_cal_addr_temp = |reg_wg_cal_addr? (reg_wg_cal_addr-1'b1) : (hlf_wave_cnt_max-1'b1); 
assign cal_addr_match = ems_enable? ((alt_ems_addr_cnt == alt_ems_addr_tar) & (alt_ems_cnt == (alt_ems_cnt_tar-1)) & alt_ems_cnt_flg) : 
                   (reg_wg_cal_addr_temp == in_wave_addr) & (((nxt_wave_val_cnt == (nxt_wave_val_lim-1)) & (state == S1)) | ((nxt_wave_val_cnt == (neg_hlf_wave_lim-1)) & (state == S3)));




//pos-neg-neg-pos//
wire pnnp_en,ppnp_en;
assign pnnp_en = i_ems_data_ctrl[4];
assign ppnp_en = i_ems_data_ctrl[5];

reg pnnp_flag,ppnp_flag;

always @(posedge clk, negedge reset) begin
   if (!reset) begin
       pnnp_flag             <= 1'b0;
   end
   else if (enable)begin 
           if (!pnnp_en)begin          
             pnnp_flag             <= 1'b0;
           end
           else if(state1_end)begin
             pnnp_flag             <= 1'b1;
           end
           else if(state3_end)begin
             pnnp_flag             <= 1'b0;
           end
   end
   else begin
       pnnp_flag             <= 1'b0;
   end
end

always @(posedge clk, negedge reset) begin
   if (!reset) begin
       ppnp_flag             <= 1'b1;
   end
   else if (enable)begin 
           if (!ppnp_en)begin          
             ppnp_flag             <= 1'b0;
           end
           else if(state1_end)begin
             ppnp_flag             <= 1'b0;
           end
           else if(state3_end)begin
             ppnp_flag             <= 1'b1;
           end
   end
   else begin
       ppnp_flag             <= 1'b1;
   end
end





//ends






always @(posedge clk, negedge reset) begin
	if (!reset) begin
		//out_wave_val <= 0;
		in_wave_addr <= 0;
		hlf_wave_cnt <= 0;
		alt_cnt <= 0;
		nxt_wave_val_cnt <= 0;
		//rest_cnt <= 0;
		//silent_cnt <= 0;
		state <= 0;
		source <= 0;
	end
	else begin
		case (state)
		       S0: begin //delay before the state machine starts
		  	   alt_cnt <=  0;
			   if (enable) begin
				   if ((delay_lim > 16'b0) & (hlf_wave_cnt < {16'b0,delay_lim} - 1)) begin
					hlf_wave_cnt <= hlf_wave_cnt + 1;
				   end
				   else begin
					hlf_wave_cnt <= 0;
                                        if((~(|(config_reg & 8'h80))) && !(&(nxt_wave_val_lim -1))) begin
                                             if(pullba_ctrl[7]) begin
	                         	            state <= S6;
	                         	            source[0] <= 1;
	                         		    source[1] <= 1;
                                             end
                                             else begin
	                         	            state <= S1;  
	                         		    source[0] <= 1;
	                          		    source[1] <= 0;
                                             end 
                                       end              
                                       else if (|(config_reg & 8'h02) && !(&(neg_nxt_wave_val_lim -1)))begin
                                             if(pullba_ctrl[6]) begin
					       	    state <= S7;
					            source[0] <= 1;
						    source[1] <= 1;
                                             end
                                             else begin
						    state <= S3;
						    source[|(config_reg & 8'h08)] <= 1;
						    source[1'b1-|(config_reg & 8'h08)] <= 0;
                                             end
                                      end			  				  
				      else begin
					   state <= S5;
                                      end
                                   end
			   end
                       end
		       S1: begin //first half wave (positive)
				if (enable) begin
//                                    if(~(|(config_reg & 8'h80))) begin
					if (nxt_wave_val_cnt < (nxt_wave_val_lim-1) | hlf_wave_cnt[15:0] < hlf_wave_cnt_max_m1) begin
						if (|(config_reg & 8'h10)) begin //alternating part
							if (alt_cnt < (alt_lim>>1)-1) begin
								source[0] <= 1;
								source[1] <= 0;
								alt_cnt <= alt_cnt + 1;
							end
							else if (alt_cnt < (alt_lim>>1) + alt_rest_lim -1) begin
								source[0] <= 0;
								source[1] <= 0;
								alt_cnt <= alt_cnt + 1;
							end
							else if (alt_cnt < alt_lim + alt_rest_lim-1) begin
								source[0] <= 0;
								source[1] <= 1;
								alt_cnt <= alt_cnt + 1;
							end
							else if (alt_cnt < alt_lim + alt_silent_lim + alt_rest_lim- 1) begin
								source[0] <= 0;
								source[1] <= 0;
								alt_cnt <= alt_cnt + 1;
							end
							else begin
								source[0] <= 1;
								source[1] <= 0;
								alt_cnt <= 0;
							end
						end
						else begin//do not alternate
							source[0] <= 1;
							source[1] <= 0;
						end

						//out_wave_val <= in_wave[OUT_NO_BITS*hlf_wave_cnt +: OUT_NO_BITS];
						//out_wave_val <= in_wave;
						if (nxt_wave_val_cnt < nxt_wave_val_lim-1) begin //clock is faster than wave resolution; wait nxt_wave_val_lim clocks until next wave value
							nxt_wave_val_cnt <= nxt_wave_val_cnt + 1;
						end
						else begin
							nxt_wave_val_cnt <= 0;
							if (hlf_wave_cnt[15:0] < hlf_wave_cnt_max_m1) begin // counting wave points for the positive side
								hlf_wave_cnt <= {16'h0,next_addr};
                                                                if(!period_sel[3]) begin
								  in_wave_addr <= next_addr[7:0];
                                                                end 
                                                                else begin
			        					in_wave_addr <= in_wave_addr_temp + next_addr[7:0];                                                                  
                                                                end							
							end
						end
					end
					else begin
						hlf_wave_cnt <= 0;
						nxt_wave_val_cnt <= 0;
						if (|(config_reg & 8'h01) && !(&(rest_lim -1)) & !ppnp_flag) begin//if rest enabled
							source[0] <= 0;
							source[1] <= 0;
							state <= S2;
                                                        if(!period_sel[3]) begin
							  in_wave_addr <= hlf_wave_cnt_max_m1[7:0];
                                                        end
						end
                                                else if(pullba_ctrl[6] && (|(config_reg & 8'h02) && !(&(neg_nxt_wave_val_lim -1))) && !ppnp_flag) begin
						  state <= S7;
						  source[0] <= 1;
						  source[1] <= 1;
                                                  if(!period_sel[3] || point_will_overflow && !period_sel[4]) begin
							in_wave_addr <= 0;
                                                  end
                                                  else if(period_sel[4]) begin
							in_wave_addr <=  in_wave_addr_temp;          
                                                  end
                                                  else begin
							in_wave_addr <= in_wave_addr + 1;                                                  
                                                  end							
                                                end
						else if (|(config_reg & 8'h02) && !(&(neg_nxt_wave_val_lim -1)) && !ppnp_flag) begin //if negative enabled
							state <= S3;						
							source[|(config_reg & 8'h08)] <= 1;
							source[1'b1-|(config_reg & 8'h08)] <= 0;
                                                        if(!period_sel[3] || point_will_overflow && !period_sel[4]) begin
							  in_wave_addr <= 0;
                                                        end
                                                        else if(period_sel[4]) begin
							  in_wave_addr <=  in_wave_addr_temp;          
                                                        end
                                                        else begin
							  in_wave_addr <= in_wave_addr + 1;                                                  
                                                        end
						end					
						else if (|(config_reg & 8'h04) && !(&(silent_lim -1)) && (~ems_enable | ((alt_ems_addr_cnt == alt_ems_addr_tar) & (alt_ems_cnt == (alt_ems_cnt_tar-1)) & alt_ems_cnt_flg)) && !ppnp_flag) begin //if silent enabled
							source[0] <= 0;
							source[1] <= 0;
							state <= S4;
                                                        if(!period_sel[3]) begin
						  	  in_wave_addr <= hlf_wave_cnt_max_m1[7:0];
                                                        end
						end
 						else begin
							state <= S1;
                                                        if(!period_sel[3] || point_will_overflow) begin
							  in_wave_addr <= 0;
                                                        end
                                                        else begin
							in_wave_addr <= in_wave_addr + 1;                                                  
                                                        end
						     	if (|(config_reg & 8'h10)) begin //alternating part
					                          if (alt_cnt < (alt_lim>>1)-1) begin
							          	source[0] <= 1;
							          	source[1] <= 0;
							          	alt_cnt <= alt_cnt + 1;
							          end
							          else if (alt_cnt < (alt_lim>>1) + alt_rest_lim -1) begin
							          	source[0] <= 0;
							          	source[1] <= 0;
							          	alt_cnt <= alt_cnt + 1;
							          end
							          else if (alt_cnt < alt_lim + alt_rest_lim-1) begin
							          	source[0] <= 0;
							          	source[1] <= 1;
							          	alt_cnt <= alt_cnt + 1;
							          end
							          else if (alt_cnt < alt_lim + alt_silent_lim + alt_rest_lim- 1) begin
							          	source[0] <= 0;
							          	source[1] <= 0;
							          	alt_cnt <= alt_cnt + 1;
							          end
							          else begin
							          	source[0] <= 1;
							          	source[1] <= 0;
							          	alt_cnt <= 0;
							          end
						        end
						end
					end
                                end
				else
					state <= S5;
			end
			S2: begin //rest period
		  	   alt_cnt <=  0;
				if (enable) begin
					if (hlf_wave_cnt < {16'h0,(rest_lim-1'b1)}) begin
						hlf_wave_cnt <= hlf_wave_cnt + 1;
						source[0] <= 0;
						source[1] <= 0;
					end
					else begin
						hlf_wave_cnt <= 0;
                                                if(pullba_ctrl[6] && (|(config_reg & 8'h02) && !(&(neg_nxt_wave_val_lim -1)))) begin
						  state <= S7;
						  source[0] <= 1;
						  source[1] <= 1;
                                                  if(!period_sel[3] || point_will_overflow && !period_sel[4]) begin
							in_wave_addr <= 0;
                                                  end
                                                  else if(period_sel[4]) begin
							in_wave_addr <=  in_wave_addr_temp;          
                                                  end
                                                  else begin
							in_wave_addr <= in_wave_addr + 1;                                                  
                                                  end		           
                                                end
						else if (|(config_reg & 8'h02) && !(&(neg_nxt_wave_val_lim -1))) begin //if negative enabled
							state <= S3;
							source[|(config_reg & 8'h08)] <= 1;
							source[1'b1-|(config_reg & 8'h08)] <= 0;
                                                        if(!period_sel[3] || point_will_overflow && !period_sel[4]) begin
							  in_wave_addr <= 0;
                                                        end
                                                        else if(period_sel[4]) begin
							  in_wave_addr <=  in_wave_addr_temp;          
                                                        end
                                                        else begin
							  in_wave_addr <= in_wave_addr + 1;                                                  
                                                        end
						end
						else if (|(config_reg & 8'h04) && !(&(silent_lim -1))) begin //if silent enabled
							state <= S4;
                                                        if(!period_sel[3]) begin
						          in_wave_addr <= hlf_wave_cnt_max_m1[7:0];
                                                        end
						end
                                                else if(pullba_ctrl[7]) begin
						        state <= S6;
						        source[0] <= 1;
						        source[1] <= 1;
                                                        if(!period_sel[3] || point_will_overflow) begin
							  in_wave_addr <= 0;
                                                        end
                                                        else begin
						          in_wave_addr <= in_wave_addr + 1;                                                  
                                                        end			           
                                                end
						else begin
							state <= S1;						
							source[0] <= 1;
							source[1] <= 0;
                                                        if(!period_sel[3] || point_will_overflow) begin
							  in_wave_addr <= 0;
                                                        end
                                                        else begin
							in_wave_addr <= in_wave_addr + 1;                                                  
                                                        end
						end
					end
				end
				else
					state <= S5;
			end
			S3: begin //second half wave
		  	   alt_cnt <=  0;
				if (enable) begin
					if (nxt_wave_val_cnt < (neg_nxt_wave_val_lim-1) | hlf_wave_cnt[15:0] < hlf_wave_cnt_max_m1) begin
						source[|(config_reg & 8'h08)] <= 1;
						source[1'b1-|(config_reg & 8'h08)] <= 0;
						if (nxt_wave_val_cnt < neg_nxt_wave_val_lim-1) begin //clock is faster than wave resolution; wait neg_nxt_wave_val_lim clocks until next wave value
							nxt_wave_val_cnt <= nxt_wave_val_cnt + 1;
						end
						else begin
							nxt_wave_val_cnt <= 0;
							if (hlf_wave_cnt[15:0] < hlf_wave_cnt_max_m1) begin // counting wave points for the positive side
								hlf_wave_cnt <= {16'h0,next_addr};
                                                                if(!period_sel[3]) begin
								  in_wave_addr <= next_addr[7:0];
                                                                end
                                                                else begin
								in_wave_addr <= in_wave_addr_temp + next_addr[7:0];                                                               
                                                                end
							end
						end
					end
					else begin
						hlf_wave_cnt <= 0;
						nxt_wave_val_cnt <= 0;
						if (|(config_reg & 8'h04) && !(&(silent_lim -1)) && !pnnp_flag) begin //if silent enabled
							source[|(config_reg & 8'h08)] <= 0;
							source[1'b1-|(config_reg & 8'h08)] <= 0;
							state <= S4;
                                                        if(!period_sel[3]) begin
							  in_wave_addr <= hlf_wave_cnt_max_m1[7:0];
                                                        end
						end
                                                else if((|(config_reg & 8'h80)) || pnnp_flag) begin
						 	state <= S3;
                                                        if(!period_sel[3] || point_will_overflow) begin
							   in_wave_addr <= 0;
                                                        end
                                                        else begin
						           in_wave_addr <= in_wave_addr + 1;                                                  
                                                        end					
                                                end
                                                else if(&(nxt_wave_val_lim -1)) begin
							state <= S3;
                                                        if(!period_sel[3] || point_will_overflow) begin
						     	in_wave_addr <= 0;
                                                        end
                                                        else begin
						     	in_wave_addr <= in_wave_addr + 1;                                                  
                                                        end					
                                                end
                                                else if(pullba_ctrl[7]) begin
						        state <= S6;
						        source[0] <= 1;
						        source[1] <= 1;
                                                        if(!period_sel[3] || point_will_overflow) begin
							  in_wave_addr <= 0;
                                                        end
                                                        else begin
						          in_wave_addr <= in_wave_addr + 1;                                                  
                                                        end			
                                                end
						else begin
							state <= S1;
							source[0] <= 1;
						 	source[1] <= 0;
                                                        if(!period_sel[3] || point_will_overflow) begin
						  	  in_wave_addr <= 0;
                                                        end	
                                                        else begin
						          in_wave_addr <= in_wave_addr + 1;                                                  
                                                        end					
						end
					end
				end
				else
					state <= S5;
			end
			S4: begin //silent period
		  	   alt_cnt <=  0;
				if (enable) begin
				   if (hlf_wave_cnt < silent_lim-1) begin
						hlf_wave_cnt <= hlf_wave_cnt + 1;
						source[0] <= 0;
						source[1] <= 0;
				   end
				   else if ((|(config_reg & 8'h80)) && (|(config_reg & 8'h01)) && !(&(rest_lim -1))) begin//if rest enabled
					        source[0] <= 0;
					        source[1] <= 0;
					        state <= S2;
					       	hlf_wave_cnt <= 0;
                                                if(!period_sel[3]) begin
					           in_wave_addr <= hlf_wave_cnt_max_m1[7:0];
                                                end
				   end
				   else if ((&(nxt_wave_val_lim -1)) && (|(config_reg & 8'h01)) && !(&(rest_lim -1))) begin//if rest enabled
					        source[0] <= 0;
					        source[1] <= 0;
					        state <= S2;
						hlf_wave_cnt <= 0;
                                                if(!period_sel[3]) begin
					          in_wave_addr <= hlf_wave_cnt_max_m1[7:0];
                                                end
				   end
                                   else if(pullba_ctrl[6] && ((|(config_reg & 8'h80)) || (&(nxt_wave_val_lim -1)))) begin
						state <= S7;
						source[0] <= 1;
						source[1] <= 1;
						hlf_wave_cnt <= 0;
                                                if(!period_sel[3] || point_will_overflow) begin
					          in_wave_addr <= 0;
                                                end
                                                else begin
						     in_wave_addr <= in_wave_addr + 1;                                                  
                                                end			            
                                   end
                                   else if((|(config_reg & 8'h80)) && !(&(neg_nxt_wave_val_lim -1))) begin
						state <= S3;
						hlf_wave_cnt <= 0;
						source[|(config_reg & 8'h08)] <= 1;
						source[1'b1-|(config_reg & 8'h08)] <= 0;
                                                if(!period_sel[3] || point_will_overflow) begin
					   	  in_wave_addr <= 0;
                                                end
                                                else begin
					   	in_wave_addr <= in_wave_addr + 1;                                                  
                                                end					
                                   end
                                   else if((&(nxt_wave_val_lim -1)) && !(&(neg_nxt_wave_val_lim -1))) begin
						state <= S3;
						hlf_wave_cnt <= 0;
						source[|(config_reg & 8'h08)] <= 1;
						source[1'b1-|(config_reg & 8'h08)] <= 0;
                                                if(!period_sel[3] || point_will_overflow) begin
						  in_wave_addr <= 0;
                                                end
                                                else begin
						  in_wave_addr <= in_wave_addr + 1;                                                  
                                                end					
                                    end
                                   else if(pullba_ctrl[7]) begin
						state <= S6;
						source[0] <= 1;
						source[1] <= 1;
						hlf_wave_cnt <= 0;
                                                if(!period_sel[3] || point_will_overflow) begin
						  in_wave_addr <= 0;
                                                end
                                                else begin
						  in_wave_addr <= in_wave_addr + 1;                                                  
                                                end			            
                                   end
				   else begin
						hlf_wave_cnt <= 0;
						state <= S1;
						source[0] <= 1;
						source[1] <= 0;
                                                if(!period_sel[3] || point_will_overflow) begin
						  in_wave_addr <= 0;
                                                end	
                                                else begin
					          in_wave_addr <= in_wave_addr + 1;                                                  
                                                end									
				   end
				end
				else
					state <= S5;
			end
			S5: begin //reset on enable 0
		  	   alt_cnt <=  0;
				if (enable)
					state <= S0;
				else begin
					in_wave_addr <= 0;
					hlf_wave_cnt <= 0;					
					nxt_wave_val_cnt <= 0;
					source <= 0;
				end
			end
			S6: begin 
		  	   alt_cnt <=  0;
				if (!enable)
					state <= S5;
				else begin
					nxt_wave_val_cnt <= nxt_wave_val_cnt;					
					if((hlf_wave_cnt < {26'b0,pullba_ctrl[5:0]} - 1'b1)) begin
					  hlf_wave_cnt <= hlf_wave_cnt + 1;
				   	  source <= 2'b11;
					  state <= S6;   
					end
                                        else begin             
					  state <= S1;   
					  hlf_wave_cnt <= 0;
				   	  source <= 2'b01;
                                          if(!period_sel[3] || point_will_overflow && !period_sel[4]) begin
				            in_wave_addr <= 0;
                                          end	
                                          else begin
					    in_wave_addr <= in_wave_addr;                                                  
                                          end	
                                        end
				end
			end
			S7: begin 
		  	   alt_cnt <=  0;
				if (!enable)
					state <= S5;
				else begin
					nxt_wave_val_cnt <= nxt_wave_val_cnt;					
					if ((hlf_wave_cnt < {26'b0,pullba_ctrl[5:0]} - 1'b1)) begin
					  hlf_wave_cnt <= hlf_wave_cnt + 1;
				      	  source <= 2'b11;
					  state <= S7;   
					end
                                        else begin             
					  state <= S3;   
					  hlf_wave_cnt <= 0;
					  source[|(config_reg & 8'h08)] <= 1;
					  source[1'b1-|(config_reg & 8'h08)] <= 0;				   
                                          if(!period_sel[3] || point_will_overflow && !period_sel[4]) begin
					    in_wave_addr <= 0;
                                          end	
                                          else begin
				            in_wave_addr <= in_wave_addr;                                                  
                                          end	
                                        end
				end
			end
			default: begin 
				in_wave_addr <= 0;
				hlf_wave_cnt <= 0;
				alt_cnt <= 0;
				nxt_wave_val_cnt <= 0;
				source <= 0;
			end
		endcase
	end
end		


//address interrupts
wire w_addr_int,w_addr_flag0,w_addr_flag1,w_addr_int0,w_addr_int1;
reg [1:0] reg_wg_driver_int_sts;
reg addr0_int_clr_reg,addr1_int_clr_reg;
reg addr0_int_clr_reg_dly1,addr1_int_clr_reg_dly1;
wire addr0_int_clr_valid,addr1_int_clr_valid;

always @(posedge clk or negedge addr0_int_clr) begin
  if (!addr0_int_clr)begin
    addr0_int_clr_reg <= 1'b0;
    addr0_int_clr_reg_dly1 <= 1'b0;
  end
  else begin
    addr0_int_clr_reg <= 1'b1;
    addr0_int_clr_reg_dly1 <= addr0_int_clr_reg;

  end
end

always @(posedge clk or negedge addr1_int_clr) begin
  if (!addr1_int_clr)begin
    addr1_int_clr_reg <= 1'b0;
    addr1_int_clr_reg_dly1 <= 1'b0;
  end
  else begin
    addr1_int_clr_reg <= 1'b1;
    addr1_int_clr_reg_dly1 <= addr1_int_clr_reg;
  end
end
wire addr0_int_clr_atpg;
wire addr1_int_clr_atpg;
assign addr0_int_clr_atpg = scan_mode ? 1'b0 : addr0_int_clr_reg;
assign addr1_int_clr_atpg = scan_mode ? 1'b0 : addr1_int_clr_reg;
assign addr0_int_clr_valid = addr0_int_clr_atpg && ~addr0_int_clr_reg_dly1;
assign addr1_int_clr_valid = addr1_int_clr_atpg && ~addr1_int_clr_reg_dly1;

reg [7:0] addr0_int_cnt,addr1_int_cnt,wg_driver_int_cnt_reg;
reg wg_driver_int_cnt_diff, int0_clr_int1;
always @(posedge clk or negedge reset) begin
  if (!reset)
    wg_driver_int_cnt_reg <= 8'h00;
  else
    wg_driver_int_cnt_reg <= wg_driver_int_cnt;
end

always @(posedge clk or negedge reset) begin
  if (!reset) begin
    wg_driver_int_cnt_diff <= 1'b0;
    int0_clr_int1          <= 1'b0;
  end
  else if(!enable) begin
    wg_driver_int_cnt_diff <= 1'b0;
    int0_clr_int1          <= 1'b0;
  end
  else if(wg_driver_int_cnt_reg !=  wg_driver_int_cnt)
    wg_driver_int_cnt_diff <= 1'b1;
  else if(w_addr_int0)
    int0_clr_int1          <= 1'b1;
  else if((nxt_wave_val_cnt == (nxt_wave_val_lim-1)) && (hlf_wave_cnt[15:0] == hlf_wave_cnt_max_m1)) begin
    wg_driver_int_cnt_diff <= 1'b0;
    int0_clr_int1          <= 1'b0;
  end
end

always @(posedge clk or negedge reset) begin
  if (!reset)
    addr0_int_cnt <= 8'h00;
  else begin
    if(enable) begin
     if (addr0_int_clr_valid || w_addr_int0 || reg_wg_driver_int_sts[0] || (wg_driver_int_cnt_diff && ((nxt_wave_val_cnt == (nxt_wave_val_lim-1)) && (hlf_wave_cnt[15:0] == hlf_wave_cnt_max_m1))))
       addr0_int_cnt <= 8'h00;
     else if(w_addr_flag0 & wg_driver_int_en & enable)
       addr0_int_cnt <= addr0_int_cnt + 1'b1;
    end
    else begin
    addr0_int_cnt <= 8'h00;
    end
   end
end

always @(posedge clk or negedge reset) begin
  if (!reset)
    addr1_int_cnt <= 8'h00;
  else begin
    if(enable) begin  
      if (addr1_int_clr_valid || w_addr_int1 || reg_wg_driver_int_sts[1] || (wg_driver_int_cnt_diff && ((nxt_wave_val_cnt == (nxt_wave_val_lim-1)) && (hlf_wave_cnt[15:0] == hlf_wave_cnt_max_m1))))
        addr1_int_cnt <= 8'h00;
      else if (int0_clr_int1 && ((nxt_wave_val_cnt == (nxt_wave_val_lim-1)) && (hlf_wave_cnt[15:0] == hlf_wave_cnt_max_m1)) && !(w_addr_flag1 & wg_driver_int_en & enable & reg_wg_driver_int_sts[0]))
        addr1_int_cnt <= 8'h00;
      else if((w_addr_flag1 & wg_driver_int_en & enable & ~int0_clr_int1) || (w_addr_flag1 & wg_driver_int_en & enable & reg_wg_driver_int_sts[0]))
        addr1_int_cnt <= addr1_int_cnt + 1'b1;
    end
    else begin
     addr1_int_cnt <= 8'h00;
    end
  end
end

always @(posedge clk or negedge reset) begin
  if (!reset)
    reg_wg_driver_int_sts[1:0]  <= 2'b0;
  else begin
    if(enable)begin
      if(addr0_int_clr_valid | addr1_int_clr_valid) begin
	 if (addr0_int_clr_valid) 
     		reg_wg_driver_int_sts[0] <= 1'b0;
  	 if (addr1_int_clr_valid) 
     		reg_wg_driver_int_sts[1] <= 1'b0;
      end
      else if(w_addr_int & wg_driver_int_en & enable) begin
  	 if (w_addr_int0)
		reg_wg_driver_int_sts[0] <= 1'b1;
	 if (w_addr_int1)
		reg_wg_driver_int_sts[1] <= 1'b1;
      end
     else begin
        reg_wg_driver_int_sts  <= reg_wg_driver_int_sts;
     end
   end
   else begin
    reg_wg_driver_int_sts[1:0]  <= 2'b0;
   end
  end
end  

//adc interrupt output
assign w_addr_int0  = addr0_int_cnt == (wg_driver_int_cnt+1'b1);
assign w_addr_int1  = addr1_int_cnt == (wg_driver_int_cnt+1'b1) && reg_wg_driver_int_sts[0];// && (in_wave_addr == wg_driver_int_addr1);
//assign w_addr_flag0 = in_wave_addr == wg_driver_int_addr0  && (nxt_wave_val_cnt==16'h0) && (state==S1 || state==S3);
//assign w_addr_flag1 = in_wave_addr == wg_driver_int_addr1  && (nxt_wave_val_cnt==16'h0) && (state==S1 || state==S3);
wire ams_int_adder;
assign ams_int_adder = ems_enable? ((alt_ems_cnt==8'b0) & (alt_cnt==18'h0)) & (state==S1) : (nxt_wave_val_cnt==16'h0) & (state==S1 || state==S3);

assign w_addr_flag0 = (o_in_wave_addr == wg_driver_int_addr0)  & ams_int_adder;
assign w_addr_flag1 = (o_in_wave_addr == wg_driver_int_addr1)  & ams_int_adder;
assign w_addr_int  = w_addr_int0 | w_addr_int1;
//assign wg_driver_interrupt = |reg_wg_driver_int_sts & wg_driver_int_en;
assign wg_driver_int_sts=reg_wg_driver_int_sts;



wire [1:0] wg_driver_int_sts_temp;
common_pulse_rising u_o_wg_driver_interrupt_rising[1:0](
.d_in(wg_driver_int_sts),
.clk(clk),
.rst_(reset),
.d_out(wg_driver_int_sts_temp)

);

assign wg_driver_interrupt = (((|wg_driver_int_sts) & !int_length_slct) | ((|wg_driver_int_sts_temp) & int_length_slct)) & wg_driver_int_en;

endmodule

