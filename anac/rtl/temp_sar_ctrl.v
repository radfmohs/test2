//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap Glucose Chip   
// File name:    temp_sar_ctrl.v 
// Module Name : temp_sar_ctrl
// Description : 
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author          Description      
//------------------------------------------------------------------------------
// 0.1                                      Initial Rev 
//------------------------------------------------------------------------------

module temp_sar_ctrl
#(
  parameter WIDTH_VDAC =8 
)
(

input  wire         sysclk,
input  wire         presetn,
input  wire         scan_enable,
input  wire         scan_mode,
input  wire [7:0]   en_reg_sel,   //0 is state machine ctrl; 1 is reg ctrl


//int
input  wire         int_length_slct,
input  wire         tsc_intr_en, 
input  wire         tsc_intr_trans_sel,
input  wire         tsc_intr_sts_clr,
output  wire 	    o_tsc_intr_sts,
output  wire 	    o_tsc_intb,

//
input  wire [7:0]   sample_duration,
input  wire [11:0]   stable_duration,
input  wire 	    tsc_comp_low_ch1,
input  wire 	    a2d_tsc_comp_out_ch1,
input  wire [WIDTH_VDAC -1:0] d2a_vdac8b_din_ch1_in ,  //from spi_reg
input  wire 	    d2a_vdac8b_en_ch1_in,
input  wire 	    d2a_tsc_comp_en_ch1_in,
//new add signal in ens2
input  wire 	    d2a_tsc_en_ch1_in,   //turn on tsc module

output  wire busy_doing,
output  wire [WIDTH_VDAC -1:0] VDAC_NOR,  //to spi_reg
output  wire [WIDTH_VDAC -1:0] d2a_vdac8b_din_ch1_out ,  //to pinmux
output  wire 	    d2a_vdac8b_en_ch1_out, //to pinmux
output  wire 	    d2a_tsc_comp_en_ch1_out, //to pinmux
output  wire 	    d2a_tsc_en_ch1_out   //to pinmux
	
);

//for TEMP_SAR_T_NOR module
//tsc_comp_low_ch1,  //0: P>N then high; 1: P>N then low  N is vdac value
//a2d_tsc_comp_out_ch1
//wire done_pulse;
wire [WIDTH_VDAC -1:0] VDAC_NOR_OUT;
//wire busy_doing;
//=======================
/*
always @ (posedge sysclk or negedge presetn) begin
  if (~presetn) begin
 	VDAC_NOR <= 1'b0;
  end
  else if (done_pulse) begin
 	VDAC_NOR <= VDAC_NOR_OUT;
  end
end
*/
wire done;
reg [11:0] stable_period_cnt;
reg sample_period;
reg cnt_lock;
always @ (posedge sysclk or negedge presetn) begin
  if (~presetn) begin
	stable_period_cnt <= 12'b0;
        cnt_lock          <= 1'b1;
  end
  else if((stable_period_cnt <= stable_duration) & cnt_lock)begin
	stable_period_cnt <= stable_period_cnt + 12'b1;
	cnt_lock          <= 1'b1;
   end
  else if(done)begin
	stable_period_cnt <= 12'b0;
	cnt_lock          <= 1'b0;
   end   
end

always @ (posedge sysclk or negedge presetn) begin
  if (~presetn) 
	sample_period <= 1'b0;
  else if(stable_period_cnt == stable_duration)
	sample_period <= 1'b1;
  else if(done)
	sample_period <= 1'b0;
end

reg sample_period_d1;
reg sample_period_d2;
reg sample_period_d3;
always @ (posedge sysclk or negedge presetn) begin
  if (~presetn)  begin
	sample_period_d1 <= 1'b0;
	sample_period_d2 <= 1'b0;
	sample_period_d3 <= 1'b0;	
  end else begin
	//sample_period_d1 <= sample_period;
	sample_period_d1 <= sample_period & cnt_lock;
	sample_period_d2 <= sample_period_d1;
	sample_period_d3 <= sample_period_d2;	
  end
end

wire working_period;
//assign working_period = sample_period | sample_period_d1 | sample_period_d2;
assign working_period = (sample_period & cnt_lock ) | sample_period_d1 | sample_period_d2;

assign    busy_doing = cnt_lock;

wire sarclk;
common_clock_gate 
u_cmsdk_clock_gate_sar_clk (
.clk        (sysclk),
.enable     (working_period),
.bypass     (scan_enable),
.gated_clk  (sarclk));


temp_sar_t_nom  
#(
  .WIDTH_VDAC(WIDTH_VDAC)
)
u_temp_sar_t_nom
(
    //.clk(sysclk),
    .clk(sarclk),
    .resetn(presetn),
    //input start,

    .sample_duration(sample_duration),
    .tsc_comp_low_ch1(tsc_comp_low_ch1),
    .a2d_tsc_comp_out_ch1(a2d_tsc_comp_out_ch1),         // 1 if Vin > Vdac, else 0
    .VDAC_NOR_OUT(VDAC_NOR_OUT),     // SAR output connected to DAC
    .VDAC_NOR(VDAC_NOR),
    .done(done)
    //.busy_doing(busy_doing)
);


//in spi module, should programmable VDAC_NOR using spi or this


 wire 	    d2a_vdac8b_en_ch1_st;
 wire 	    d2a_tsc_comp_en_ch1_st;
 wire 	    d2a_tsc_en_ch1_st;   //turn on tsc module
 wire [WIDTH_VDAC -1:0] d2a_vdac8b_din_ch1_st ;  

 //assign    d2a_vdac8b_en_ch1_st  = busy_doing ? 1'b1 : d2a_vdac8b_en_ch1_in;
 assign    d2a_vdac8b_en_ch1_st  = busy_doing ? 1'b1 : d2a_vdac8b_en_ch1_in;
 assign    d2a_tsc_comp_en_ch1_st  = busy_doing ? 1'b1 : d2a_tsc_comp_en_ch1_in;
 assign    d2a_tsc_en_ch1_st       = busy_doing ? 1'b1 : d2a_tsc_en_ch1_in;
 assign    d2a_vdac8b_din_ch1_st = busy_doing ? VDAC_NOR_OUT : d2a_vdac8b_din_ch1_in;  

assign 	    d2a_vdac8b_en_ch1_out  = en_reg_sel[0] ? d2a_vdac8b_en_ch1_in  :  d2a_vdac8b_en_ch1_st;
assign 	    d2a_tsc_comp_en_ch1_out  = en_reg_sel[1] ? d2a_tsc_comp_en_ch1_in  :  d2a_tsc_comp_en_ch1_st;
assign 	    d2a_tsc_en_ch1_out       = en_reg_sel[3] ? d2a_tsc_en_ch1_in       :  d2a_tsc_en_ch1_st;
assign 	    d2a_vdac8b_din_ch1_out = en_reg_sel[4] ? d2a_vdac8b_din_ch1_in :  d2a_vdac8b_din_ch1_st;


//interrupt
wire tsc_intr_pin;
anac_int_edge_dtct u_tsc(
.sysclk(sysclk),	
.presetn(presetn),
.scan_mode(scan_mode),

.A2D_COMP(a2d_tsc_comp_out_ch1 & !busy_doing & !sample_period_d3),	

.ana_comp_ch_intr_en(tsc_intr_en),
.ana_comp_ch_intr_trans_sel(tsc_intr_trans_sel),
.ana_comp_ch_intr_sts_clr(tsc_intr_sts_clr),

.o_ana_comp_ch_intr_sts(o_tsc_intr_sts),
.o_ana_comp_ch_intr_pin(tsc_intr_pin)
);

wire tsc_int_temp;
common_pulse_rising u_anac_int_temp_rising(
.d_in(tsc_intr_pin),
.clk(sysclk),
.rst_(presetn),
.d_out(tsc_int_temp)
);

assign o_tsc_intb = (tsc_intr_pin & !int_length_slct) | (tsc_int_temp & int_length_slct);

endmodule

