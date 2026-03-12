//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap Glucose Chip   
// File name:    anac_short_dtct.v 
// Module Name : anac_short_dtct
// Description : 
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author          Description      
//------------------------------------------------------------------------------
// 0.1                                      Initial Rev 
//------------------------------------------------------------------------------

module anac_short_dtct(

input  wire         sysclk,
input  wire         presetn,
input  wire         scan_mode,
input  wire 	    A2D_COMP,
input  wire 	    drive_en,
input  wire         int_en,

input wire [31:0]   timer_TH,	
input wire [31:0]   counter_TH,	
//input wire [7:0]    ana_stimu_int_num,

input  wire         ana_stimu_ch_intr_sts_clr,

output reg [31:0] counter_th_cnt_dbg,
output wire         o_ana_stimu_chx_intr_sts,
output wire         o_ana_stimu_chx_intr_pin	
	
);

reg [31:0] timer_th_cnt, counter_th_cnt;
reg        ana_comp_ch_stim_int_re;
wire        ana_comp_ch_stim_int;
//reg [7:0]  ana_stimu_int_num_reg;
reg        stimu_ch_int_d1;

wire addr_ch_clr_pls;
wire A2D_COMP_sync;

wire ana_stimu_ch_intr_sts_clr_sync_tmp;
wire ana_stimu_ch_intr_sts_clr_sync;

wire timer_flag,counter_flg;
assign timer_flag    = (timer_th_cnt==timer_TH);
assign counter_flg   = (counter_th_cnt<counter_TH);
//assign int_cnt_reset = (timer_th_cnt==timer_TH) & !counter_flg & A2D_COMP_sync;

common_rst_sync u_ana_stimu_ch1_intr_sts_sync(
.RSTINn    (presetn),
.RSTREQ    (ana_stimu_ch_intr_sts_clr),
.CLK       (sysclk),
.SE        (1'b0),
.RSTBYPASS (scan_mode),  
.RSTOUTn   (ana_stimu_ch_intr_sts_clr_sync_tmp)
);

assign ana_stimu_ch_intr_sts_clr_sync = scan_mode ? ana_comp_ch_stim_int : ana_stimu_ch_intr_sts_clr_sync_tmp;
assign ana_comp_ch_stim_int = counter_flg & timer_flag & !ana_comp_ch_stim_int_re;
//assign int_num_gen_int_en = (!(|ana_stimu_int_num))? 1'b1 : (ana_stimu_int_num_reg[7:0] == ana_stimu_int_num);

//analog_comp_ch_interrupt_clear_sync_pulse generation
reg ana_stimu_ch_intr_sts_clr_sync_d1,ana_stimu_ch_intr_sts_clr_sync_d2,ana_stimu_ch_intr_sts_clr_sync_d3;
wire ana_stimu_ch_intr_sts_clr_sync_pulse;
wire short_dtct_en;

always @ (posedge sysclk or negedge presetn) begin
  if (~presetn) begin
    ana_stimu_ch_intr_sts_clr_sync_d1<=1'b0; 
    ana_stimu_ch_intr_sts_clr_sync_d2<=1'b0; 
    ana_stimu_ch_intr_sts_clr_sync_d3<=1'b0; 

  end
  else begin
   ana_stimu_ch_intr_sts_clr_sync_d1 <= ana_stimu_ch_intr_sts_clr_sync;
   ana_stimu_ch_intr_sts_clr_sync_d2 <= ana_stimu_ch_intr_sts_clr_sync_d1;
   ana_stimu_ch_intr_sts_clr_sync_d3 <= ana_stimu_ch_intr_sts_clr_sync_d2;

  end
end

assign ana_stimu_ch_intr_sts_clr_sync_pulse = ana_stimu_ch_intr_sts_clr_sync_d2 & (~ana_stimu_ch_intr_sts_clr_sync_d3);


common_sync_bit u_A2D_COMP_sync(
       .clk(sysclk),
       .rst_(presetn),
       .async_in(A2D_COMP),
       .sync_out(A2D_COMP_sync)
);

common_sync_bit u_short_dtct_en_sync(
       .clk(sysclk),
       .rst_(presetn),
       .async_in(drive_en),
       .sync_out(short_dtct_en)
);


//timer
always @(posedge sysclk or negedge presetn)begin
    if(~presetn) begin
    timer_th_cnt <= 32'h0;
    end
    else if (!short_dtct_en | ana_comp_ch_stim_int_re) begin
    timer_th_cnt <= 32'h0;    
    end
    else if (ana_stimu_ch_intr_sts_clr_sync_pulse) begin
    timer_th_cnt <= 32'h0;    
    end 
    else if (timer_th_cnt!=timer_TH) begin
    timer_th_cnt <= timer_th_cnt + 32'h1;
    end	    
    else begin
    timer_th_cnt <= 32'h0;     
    end
end

//counter when a2d is 1
always @(posedge sysclk or negedge presetn)begin
    if(~presetn) begin
    counter_th_cnt <= 32'h0;
    end
    else if (!short_dtct_en | ana_comp_ch_stim_int_re) begin
    counter_th_cnt <= 32'h0;    
    end
    else if (ana_stimu_ch_intr_sts_clr_sync_pulse) begin
    counter_th_cnt <= 32'h0;    
    end 
    else if (timer_flag)begin
    counter_th_cnt <= 32'h0;     
    end    
    else if (A2D_COMP_sync) begin
    counter_th_cnt <= counter_th_cnt + 32'h1;
    end	    

end
always @(posedge sysclk or negedge presetn)begin
    if(~presetn) begin
    counter_th_cnt_dbg <= 32'h0;
    end
    else if(timer_flag) begin
    counter_th_cnt_dbg <= counter_th_cnt;
    end
end

//int number
//always @(posedge sysclk or negedge presetn) begin
//  if (~presetn) 
//    ana_stimu_int_num_reg <=8'h00;
//  else if(ana_stimu_ch_intr_sts_clr_sync_pulse | int_cnt_reset | ana_comp_ch_stim_int_re | !short_dtct_en)   	  
//    ana_stimu_int_num_reg <=8'h00;    
//  else if(ana_stimu_int_num!=ana_stimu_int_num_reg[7:0]) begin
//             if(ana_comp_ch_stim_int)
//              ana_stimu_int_num_reg <= ana_stimu_int_num_reg + 8'b1;
//  end
//end

//int
always @ (posedge sysclk or negedge presetn) begin
  if (~presetn) begin
    ana_comp_ch_stim_int_re <= 1'b0;
  end 
  else if(ana_stimu_ch_intr_sts_clr_sync_pulse) begin
    ana_comp_ch_stim_int_re <= 1'b0;     
  end  
//  else if(int_num_gen_int_en)begin
  else if(counter_flg & timer_flag) begin
          ana_comp_ch_stim_int_re <= 1'b1;     
        end
//  end
end

assign o_ana_stimu_chx_intr_sts          =  ana_comp_ch_stim_int_re;
assign o_ana_stimu_chx_intr_pin          =  ana_comp_ch_stim_int_re & int_en;

endmodule

