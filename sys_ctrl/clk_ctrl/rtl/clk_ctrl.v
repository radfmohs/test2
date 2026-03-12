//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap ENS2  
// File name:    clk_ctrl.sv 
// Module Name : clk_ctrl
// Description : clock control
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author          Description      
//------------------------------------------------------------------------------
// R001 first draft                             05/28/2019                            
// R002 add scan_clk mux                        07/29/2019                            
// R003 remove sram_en/dotp_en                  09/10/2019                         
//------------------------------------------------------------------------------
module clk_ctrl (
input  wire         presetn,                // global reset after sync by hfosc
input  wire         poresetn,               // global reset after sync by hfosc
input  wire 	      adc_resetn,
input  wire 	      adc_ctrl_resetn,
input  wire         ext_clk_sel,            // external clk select
input  wire         ext_hfclk,              // external high frequency clk
input  wire         hfosc,                  // hfosc base clock input
input  wire         otp_bist_tck,           // otp bist clock
input  wire         scan_clk,               // atpg clock
input  wire         atpg_en,                // atpg enable
input  wire         scan_enable,            // scan enable
input  wire         wave_gen_dis,           // wave_gen  disable
input  wire         pmu_fclk_en,            // fclk enable when in idle state

input  wire         ppg_dis,           //ppg disble 
input  wire  [1:0]  ppg_clk_div,       // ppg clock divider
input  wire         ana_ppgclk_inv,   // ana ppg clock 
input  wire         ppg_clk50duty,            

output  wire 	    ppg_clk_running,
output  wire        clk_ppg,           //ppg  
output  wire        clk_sys_ppg,           //ppg  
output  wire        ana_clk_ppg,           //ppg  
//==================
//for bps function
//==================
////the following is for data_rdyn_cont_clk
//input wire mode_chg,
/*
input wire single_shot_true,
input wire meas_done_pos,
input  wire [15:0] stable_time,
input  wire  adc_resetn,
input  wire  adc_ctrl_resetn,
//======
input wire is_2channels,
input wire is_4channels,
input wire is_6channels,
input wire is_8channels,
input  wire	    flg_measure,
input  wire 	    D2A_POWER_EN,
input  wire         imeas_en,
output wire start_sample,
output wire stop_sample,
output wire start_sample_pclk,
output wire stop_sample_pclk,
*/


input wire [2:0]  PROD_ID,

input  wire enable_cic,
input  wire imeas_working_sync,
input  wire imeas_working,
input  wire [15:0] en_channels,

input  wire  [3:0]  iclk_div,               // imeas adc clock divider
input  wire	    imeas_adc_inv,	    // invert the input to analog imeas if 1, otherwise not inverted
output wire [15:0]        imeas_pclk,             // for imeas pclk
output wire [15:0]        imeas_dig_adc_clk,      // imeas adc clock for digital 
output wire [15:0]        notch_clk,  
output wire [15:0]        lpf_clk,
output wire [15:0]        hpf_clk,
output wire [15:0]        imeas_dig_filter_clk_post,
output wire         imeas_adc_clk,          // imeas adc clock for analog
output wire 	    adc_clk_running,

input  wire         notch_filter_valid,
input  wire [15:0]  notch_clk_gtg_en,
input  wire [15:0]  lpf_clk_gtg_en,
input  wire [15:0]  hpf_clk_gtg_en,
input  wire [3:0]   osr_sel,
//==================
//input  wire         fclk_dynen,             // fclk dynamic clock enable
//input  wire  [1:0]  pclk_div,             // pclk divider
input  wire 	    o_clk_sel,             //0 is osc, 1 is mux 
input  wire  [2:0]  pclk_div,               // pclk divider
input  wire         int_clk_out,            // from spi for multi chip mode (if 1, then int clk is sent out)
input  wire         int_clk_out_gpio,       // from gpio for multi chip mode (if 1, then int clk is sent out)
output wire         hfosc_atpg,             // hfosc after atpg mux
output wire         otp_bist_tck_atpg,      // otp bist clock after atpg mux
//output wire         fclk,                   // fclk after clock switching
output wire         pclk,                   // periperal clock free-running
input  wire         otp_dpstb_en,
input  wire         anac_clock_en,
input  wire         temp_sar_clock_dis,
input  wire         lead_off_en,
output wire         otp_pclk,   
output wire         anac_pclk,
output wire         temp_sar_pclk,
output wire         lead_off_pclk,
output wire         wave_gen_pclk,          // for wave gen pclk
output wire         wave_gen_fclk,          // for wave gen pclk
output wire         hfosc_out
);

//reg  [2:0]  pclk_div_cnt;
reg  [6:0]  pclk_div_cnt;
wire         i_pclken;
wire		    fclk_en;
reg         div_fclk_d;
reg         div_fclk_d_1t;
wire	      div_fclk_q;
wire        hfosc_mux;
wire         fclk;                   // fclk after clock switching

`ifdef FPGA
assign hfosc_mux = hfosc;
assign hfosc_atpg = hfosc_mux;
assign otp_bist_tck_atpg = otp_bist_tck;
`else
// external clock select
// wire hfosc_gate;
//assign hfosc_gate = hfosc;
/*
common_clock_gate 
u_hfosc_gate_hclk (
.clk        (hfosc),
.enable     (1'b1),
.bypass     (atpg_en),
.gated_clk  (hfosc_gate));
*/

//NBL_CKMX2D0 DNT_HFOSC_MUX (.D0(hfosc), .D1(ext_hfclk), .S(ext_clk_sel), .Z(hfosc_mux));
CLKMX2_X4_A7TULL DNT_HFOSC_MUX (.A(hfosc), .B(ext_hfclk), .S0(ext_clk_sel), .Y(hfosc_mux));
//if multiple wavegen chip needed, and this is master chip for clk, then ext_clk_sel can be fixed to 1 externally, then spi writes int_clk_out to 1, 
//then chip will get clk (from hfosc_out going out and then from ext_hfclk coming back (and also going to slave wavegen chip))
//if multiple wavegen chip needed, and this is slave chip for clk, then ext_clk_sel fixed to 1, and ext_hfclk will be connected to hfosc_out of master chip for clk
//assign hfosc_out = hfosc & (int_clk_out | int_clk_out_gpio);//hfosc_out goes to pin mux then io cell. int_clk_out is from spi. no need to sync otherwise chip won't work at startup
wire  clk_outside;
assign  clk_outside = o_clk_sel ? hfosc_mux : hfosc;
//assign hfosc_out = hfosc_mux & (int_clk_out | int_clk_out_gpio);//hfosc_out goes to pin mux then io cell. int_clk_out is from spi. no need to sync otherwise chip won't work at startup
assign hfosc_out = clk_outside & (int_clk_out | int_clk_out_gpio);//hfosc_out goes to pin mux then io cell. int_clk_out is from spi. no need to sync otherwise chip won't work at startup

// scan clock mux
//NBL_CKMX2D0 DNT_HFOSC_ATPG (.D0(hfosc_mux), .D1(scan_clk), .S(atpg_en), .Z(hfosc_atpg));
CLKMX2_X4_A7TULL DNT_HFOSC_ATPG (.A(hfosc_mux), .B(scan_clk), .S0(atpg_en), .Y(hfosc_atpg));
// otp_bist_tck atpg mux
//NBL_CKMX2D0 DNT_FLASH_BIST_TCK_ATPG (.D0(otp_bist_tck), .D1(scan_clk), .S(atpg_en), .Z(otp_bist_tck_atpg));
CLKMX2_X4_A7TULL DNT_FLASH_BIST_TCK_ATPG (.A(otp_bist_tck), .B(scan_clk), .S0(atpg_en), .Y(otp_bist_tck_atpg));
`endif

//assign fclk_en = ~fclk_dynen | pmu_fclk_en;
assign fclk_en =  pmu_fclk_en;
//hclk gating
common_clock_gate 
u_cmsdk_clock_gate_hclk (
.clk        (hfosc_atpg),
.enable     (fclk_en),
.bypass     (scan_enable),
.gated_clk  (fclk));

wire [2:0] pclk_div_sync;
common_sync_bit common_bit_sync_pclk_div[2:0](
                .async_in(pclk_div),
                //.async_in(3'd7),
                .clk(fclk),
                .rst_(poresetn),      
                .sync_out(pclk_div_sync));

/*
wire fclk_inv_bak;
assign fclk_inv_bak= ~fclk;
wire fclk_inv;
//NBL_CKMX2D0 DNT_HFOSCINV_ATPG (.D0(fclk_inv_bak), .D1(scan_clk), .S(atpg_en), .Z(fclk_inv));
CLKMX2_X4_A7TULL DNT_HFOSCINV_ATPG (.A(fclk_inv_bak), .B(scan_clk), .S0(atpg_en), .Y(fclk_inv));
*/

//wire poresetn_fclk;
//wire poresetn_tmp;
//assign poresetn_tmp = fclk_en & poresetn;
//CKMX2D0 DNT_FCLK_EN_RSTN_ATPG (.A(poresetn_tmp), .B(poresetn), .S0(atpg_en), .Y(poresetn_fclk));
//change to 50% duty cycle
//reg pclk_reg;
//wire not_divided;
//reg [2:0] pclk_gate_reg;
/*
wire pclk_div_sync_chg;
always @ (posedge fclk or negedge poresetn) begin
  if (~poresetn) 
//always @ (posedge fclk or negedge poresetn_fclk) begin
//  if (~poresetn_fclk) 
    pclk_div_cnt <= 7'd0;
  //removed for clock gating to generate pclk 30May2025
//  else if(!not_divided && (pclk_gate_reg!=3'b110))//zhen added 202505285
//    pclk_div_cnt <= 6'd0;
  else if(pclk_div_sync_chg)
    pclk_div_cnt <= 7'd0;
  else
    pclk_div_cnt <= pclk_div_cnt + 7'd1;
end

wire [2:0] pclk_div_sync;
common_sync_bit common_bit_sync_pclk_div[2:0](
                .async_in(pclk_div),
                //.async_in(3'd7),
                .clk(fclk),
                .rst_(poresetn),      
                .sync_out(pclk_div_sync));

reg [2:0] pclk_div_sync_d1;
always @ (posedge fclk or negedge poresetn) begin
  if (~poresetn) 
  pclk_div_sync_d1 <= 3'b0;
  else
  pclk_div_sync_d1 <= pclk_div_sync;
end
assign pclk_div_sync_chg = pclk_div_sync_d1 != pclk_div_sync;
//new solution, hopefully no difference between different chip
*/
/*
reg [2:0] pclk_div_sync0_d1;
reg [2:0] pclk_div_sync0_d2;
reg [2:0] pclk_div_sync0_d3;
always @ (posedge fclk or negedge poresetn) begin
  if (~poresetn) 
  pclk_div_sync0_d1 <= 3'b0;
  else
  pclk_div_sync0_d1 <= pclk_div;
end
always @ (posedge fclk_inv or negedge poresetn) begin
  if (~poresetn) 
  pclk_div_sync0_d2 <= 3'b0;
  else
  pclk_div_sync0_d2 <= pclk_div_sync0_d1;
end
always @ (posedge fclk or negedge poresetn) begin
  if (~poresetn) 
  pclk_div_sync0_d3 <= 3'b0;
  else
  pclk_div_sync0_d3 <= pclk_div_sync0_d2;
end
wire pclk_div_sync0_chg = pclk_div_sync0_d3 != pclk_div_sync0_d2;


reg [2:0] pclk_div_sync1_d1;
reg [2:0] pclk_div_sync1_d2;
reg [2:0] pclk_div_sync1_d3;
always @ (posedge fclk_inv or negedge poresetn) begin
  if (~poresetn) 
  pclk_div_sync1_d1 <= 3'b0;
  else
  pclk_div_sync1_d1 <= pclk_div;
end
always @ (posedge fclk or negedge poresetn) begin
  if (~poresetn) 
  pclk_div_sync1_d2 <= 3'b0;
  else
  pclk_div_sync1_d2 <= pclk_div_sync1_d1;
end
always @ (posedge fclk_inv or negedge poresetn) begin
  if (~poresetn) 
  pclk_div_sync1_d3 <= 3'b0;
  else
  pclk_div_sync1_d3 <= pclk_div_sync1_d2;
end
wire pclk_div_sync1_chg = pclk_div_sync1_d3 != pclk_div_sync1_d2;
*/
wire poresetn_final;
//   NBL_CKMX2D0 DNT_RSTINV_ATPG (.D0((!(pclk_div_sync0_chg | pclk_div_sync1_chg)) & poresetn ) , .D1(poresetn),  .S(atpg_en), .Z(poresetn_final));
//CLKMX2_X4_A7TULL DNT_RSTINV_ATPG (.A ((!(pclk_div_sync0_chg | pclk_div_sync1_chg)) & poresetn ),   .B(poresetn), .S0(atpg_en), .Y(poresetn_final));
CLKMX2_X4_A7TULL DNT_RSTINV_ATPG (.A (poresetn),   .B(poresetn), .S0(atpg_en), .Y(poresetn_final));
always @ (posedge fclk or negedge poresetn_final) begin
  if (~poresetn_final) 
//always @ (posedge fclk or negedge poresetn_fclk) begin
//  if (~poresetn_fclk) 
    //pclk_div_cnt <= 7'd0;
    pclk_div_cnt <= 7'h7D;
  //removed for clock gating to generate pclk 30May2025
//  else if(!not_divided && (pclk_gate_reg!=3'b110))//zhen added 202505285
//    pclk_div_cnt <= 6'd0;
  else
    pclk_div_cnt <= pclk_div_cnt + 7'd1;
end

//wire pclk_div_sync_chg;
//assign pclk_div_sync_chg = pclk_div_sync0_chg | pclk_div_sync1_chg;

//removed for clock gating to generate pclk 30May2025
/*
always @ (*) begin
  //case (pclk_div)
  case (pclk_div_sync)
    3'b000: i_pclken = 1'b1;
    3'b001: i_pclken = (pclk_div_cnt==6'd0);
    3'b010: i_pclken = (pclk_div_cnt==6'd1);
    3'b011: i_pclken = (pclk_div_cnt==6'd3);
    3'b100: i_pclken = (pclk_div_cnt==6'd7);
    3'b101: i_pclken = (pclk_div_cnt==6'd15);
    3'b110: i_pclken = (pclk_div_cnt==6'd31);
    3'b111: i_pclken = (pclk_div_cnt==6'd63);
    default: i_pclken = 1'b1;
  endcase
end
*/
reg i_pclken_bak;
always @ (*) begin
  //case (pclk_div)
  case (pclk_div_sync)
  //case (pclk_div_sync0_d3)
    3'b000: i_pclken_bak = 1'b1;
    3'b001: i_pclken_bak = (pclk_div_cnt[0]==1'd0);
    3'b010: i_pclken_bak = (pclk_div_cnt[1:0]==2'd0);
    3'b011: i_pclken_bak = (pclk_div_cnt[2:0]==3'd0);
    3'b100: i_pclken_bak = (pclk_div_cnt[3:0]==4'd0);
    3'b101: i_pclken_bak = (pclk_div_cnt[4:0]==5'd0);
    3'b110: i_pclken_bak = (pclk_div_cnt[5:0]==6'd0);
    3'b111: i_pclken_bak = (pclk_div_cnt[6:0]==7'd0);
    default: i_pclken_bak = 1'b1;
  endcase
end
//assign i_pclken = pclk_div_sync_chg ? 1'b0 : i_pclken_bak;
assign i_pclken =  i_pclken_bak;


  //removed for clock gating to generate pclk 30May2025
/*
wire pclk_div_changed_sync;
common_sync_bit u_pclk_div_changed_sync(
                .async_in(pclk_div != pclk_div_sync),
                .clk(fclk),
                .rst_(poresetn),      
                .sync_out(pclk_div_changed_sync));

always @ (posedge fclk or negedge poresetn) begin
  if (~poresetn) 
  pclk_gate_reg <= 3'b0;
  else if (pclk_div_changed_sync)	
  pclk_gate_reg <= 3'b0;
  else if(pclk_gate_reg != 3'b110)
  pclk_gate_reg <= pclk_gate_reg + 1'b1;
end


always @ (posedge fclk or negedge poresetn) begin
  if (~poresetn) 
//always @ (posedge fclk or negedge poresetn_fclk) begin
//  if (~poresetn_fclk) 
  //pclk_reg <= 1'b1;   //why default is 1? 2024.Oct.8
  pclk_reg <= 1'b0;
  else if (not_divided && (pclk_gate_reg==3'b110))	
  pclk_reg <= 1'b0;
//  else if(!not_divided && (pclk_gate_reg!=3'b110))//zhen added 202505285
//        pclk_reg <= 6'd0;
  else if(i_pclken)
  pclk_reg <= ~pclk_reg;
end

//assign not_divided = (pclk_div == 3'b000); 
assign not_divided = (pclk_div_sync == 3'b000); 
*/
wire pclk_wire;

`ifdef FPGA
//assign pclk = not_divided ? fclk : pclk_reg;
assign pclk = fclk;
`else
//NBL_CKMX2D0 DNT_DIV_PCLK (.D0(pclk_reg), .D1(fclk), .S(not_divided), .Z(pclk_wire));

  //removed for clock gating to generate pclk 30May2025
/*
common_clk_switch u_DIV_PCLK(
.i_clk_a(pclk_reg),
.i_clk_b(fclk),
.i_rst_n_a(poresetn),
.i_rst_n_b(poresetn),
.i_sel_b(not_divided),
.i_scan_mode(atpg_en),
.i_scan_enable(scan_enable),
.o_clk_out(pclk_wire),
.o_ind_a(),
.o_ind_b()
);
*/
common_clock_gate 
u_cmsdk_clock_gate_pclk (
.clk        (fclk),
.enable     (i_pclken), .bypass     (scan_enable), .gated_clk  (pclk_wire));

//  NBL_CKMX2D0  DNT_DIV_PCLK_ATPG (.D0(pclk_wire), .D1(scan_clk),  .S(atpg_en), .Z(pclk));
CLKMX2_X4_A7TULL DNT_DIV_PCLK_ATPG  (.A(pclk_wire),  .B(scan_clk), .S0(atpg_en), .Y(pclk));

`endif

wire wave_gen_dis_sync;
common_sync_bit common_bit_sync_i_data_rd_req(
                .async_in(wave_gen_dis),
                .clk(pclk),
                .rst_(presetn),      
                .sync_out(wave_gen_dis_sync));

wire otp_dpstb_en_sync;
common_sync_bit u_otp_dpstb_en_sync(
                .async_in(!otp_dpstb_en),
                .clk(pclk),
                .rst_(presetn),      
                .sync_out(otp_dpstb_en_sync));	

wire anac_clock_en_sync;
common_sync_bit u_anac_clock_en_sync(
                .async_in(!anac_clock_en),
                .clk(pclk),
                .rst_(presetn),      
                .sync_out(anac_clock_en_sync));	

wire temp_sar_clock_en_sync;
common_sync_bit u_temp_sar_clock_en_sync(
                .async_in(!temp_sar_clock_dis),
                .clk(pclk),
                .rst_(presetn),      
                .sync_out(temp_sar_clock_en_sync));	
wire ppg_dis_sync;
common_sync_bit common_bit_sync_fclk_ppg(
                .async_in(ppg_dis),
                .clk(fclk),
                .rst_(poresetn),      
                .sync_out(ppg_dis_sync));


wire ppg_sys_en;
assign ppg_sys_en = (pclk_div_cnt[1:0]==2'd0) & (~ppg_dis_sync);
common_clock_gate 
u_cmsdk_clock_gate_sys_ppg (
.clk        (fclk),
.enable     (ppg_sys_en), .bypass     (scan_enable), .gated_clk  (clk_sys_ppg)); 

//wave gen pclk/pclkg gating

common_clock_gate 
u_cmsdk_clock_gate_wave_gen_pclk (
.clk        (pclk),
.enable     (~wave_gen_dis_sync), .bypass     (scan_enable), .gated_clk  (wave_gen_pclk)); 

common_clock_gate 
u_cmsdk_clock_gate_wave_gen_fclk (
.clk        (fclk),
.enable     (~wave_gen_dis_sync), .bypass     (scan_enable), .gated_clk  (wave_gen_fclk));

wire lead_off_en_sync;
common_sync_bit common_bit_sync_lead_off(
                .async_in(lead_off_en),
                .clk(pclk),
                .rst_(presetn),      
                .sync_out(lead_off_en_sync));

common_clock_gate 
u_cmsdk_clock_gate_lead_off_pclk (
.clk        (pclk),
.enable     (lead_off_en_sync), .bypass     (scan_enable), .gated_clk  (lead_off_pclk)); 

common_clock_gate 
u_cmsdk_clock_gate_otp_pclk (
.clk        (pclk),
.enable     (otp_dpstb_en_sync), .bypass     (scan_enable), .gated_clk  (otp_pclk)); 

common_clock_gate 
u_cmsdk_clock_gate_anac_pclk (
.clk        (pclk),
.enable     (anac_clock_en_sync), .bypass     (scan_enable), .gated_clk  (anac_pclk)); 

common_clock_gate 
u_cmsdk_clock_gate_temp_sar_pclk (
.clk        (pclk),
.enable     (temp_sar_clock_en_sync), .bypass     (scan_enable), .gated_clk  (temp_sar_pclk)); 


//====================
//for bps function
//====================
//reg         div_fclk_d;
//reg         div_fclk_d_1t;
//wire	    div_fclk_q;

reg  [10:0]  iclk_div_cnt;
reg  [10:0]  iclk_div_num;
wire        iclk;
wire	    imeas_adc_inv_atpg;

/*
wire imeas_en_sync;
common_sync_bit u_imeas_en_sync(
                .async_in(imeas_en),
    //.async_in(1),
    .clk(pclk),
                .rst_(presetn),
                .sync_out(imeas_en_sync));


//wire imeas_working;
assign imeas_working = (imeas_en_sync | flg_measure) & D2A_POWER_EN;

//wire imeas_working_sync;
common_sync_bit u_imeas_working_sync(
                .async_in(imeas_working),
                .clk(adc_clk_running),
                .rst_(adc_resetn),      
                .sync_out(imeas_working_sync));	
reg imeas_working_sync_d1;
always @ (posedge adc_clk_running or negedge adc_resetn) begin
  if (~adc_resetn)
  imeas_working_sync_d1 <= 1'b0;
  else
  imeas_working_sync_d1 <= imeas_working_sync;
end

reg imeas_working_sync_d1_pclk;
always @ (posedge pclk or negedge adc_ctrl_resetn) begin
  if (~adc_ctrl_resetn)
  imeas_working_sync_d1_pclk <= 1'b0;
  else
  imeas_working_sync_d1_pclk <= imeas_working;
end


//wire [7:0] en_channels;
assign en_channels=8'hff;
*/
/*
assign en_channels = is_2channels ? 8'b00000011 :
         is_4channels ? 8'b00001111 : 
           is_6channels ? 8'b00111111 :
         is_8channels ? 8'b11111111 : 
            8'b11111111 ;
*/
//input  wire 	    adc_resetn,
//input  wire 	    adc_ctrl_resetn,

reg [15:0] en_channels_prod;
always @ (*) begin
  case (PROD_ID)
    3'b000: en_channels_prod  = 16'hffff;   //16 channels
    3'b001: en_channels_prod  = 16'h3fff;   //14 channels
    3'b010: en_channels_prod  = 16'hfff;   //12 channels
    3'b011: en_channels_prod  = 16'h3ff;   //10 channels
    3'b100: en_channels_prod  = 16'hff;   //8 channels
    3'b101: en_channels_prod  = 16'h3f;   //6 channels
    3'b110: en_channels_prod  = 16'hf;   //4 channels
    3'b111: en_channels_prod  = 16'h3;   //2 channels
    default: en_channels_prod = 16'hffff;   //16 channels
  endcase
end


wire [15:0] en_channels_final;
assign      en_channels_final = en_channels_prod & en_channels;
wire [15:0] en_channels_sync_adcclk;
wire [15:0] en_channels_sync_pclk;
common_sync_bit u_en_channel_sync_adc[15:0](
                //.async_in(en_channels),
                .async_in(en_channels_final),
                .clk(adc_clk_running),
                .rst_(adc_resetn),      
                .sync_out(en_channels_sync_adcclk));	
common_sync_bit u_en_channel_sync_pclk[15:0](
                //.async_in(en_channels),
                .async_in(en_channels_final),
                .clk(pclk),
                .rst_(adc_ctrl_resetn),      
                .sync_out(en_channels_sync_pclk));	


//imeas pclk/pclkg gating
common_clock_gate 
u_cmsdk_clock_gate_imeas_pclk[15:0] (
.clk        (pclk),
//.enable     (imeas_en),
//.enable     ({16{imeas_working}} & en_channels), .bypass     (atpg_en),
.enable     ({16{imeas_working}} & en_channels_sync_pclk), .bypass     (atpg_en),
.gated_clk  (imeas_pclk[15:0])); 
//imeas adc clock divider 50% duty
wire  [3:0]  iclk_div_final;               // imeas adc clock divider
assign iclk_div_final =  iclk_div ;               // imeas adc clock divider
always @ (*) begin
  //case (iclk_div)
  case (iclk_div_final)
    4'b0001: iclk_div_num = 10'd0;
    4'b0010: iclk_div_num = 10'd1;
    4'b0011: iclk_div_num = 10'd3;
    4'b0100: iclk_div_num = 10'd7;
    4'b0101: iclk_div_num = 10'd15;
    4'b0110: iclk_div_num = 10'd31;
    4'b0111: iclk_div_num = 10'd63;
    4'b1000: iclk_div_num = 10'd127;
    4'b1001: iclk_div_num = 10'd255;
    4'b1010: iclk_div_num = 10'd511;
    4'b1011: iclk_div_num = 10'd1023;
    default: iclk_div_num = 10'd0;
  endcase
end

always @ (posedge fclk or negedge poresetn) begin
  if (~poresetn) 
    iclk_div_cnt <= 11'b0;
  else if (iclk_div_cnt >= iclk_div_num)
    iclk_div_cnt <= 11'b0;
  else
    iclk_div_cnt <= iclk_div_cnt + 11'b1;
end

always @ (*) begin
    if (iclk_div_cnt >= iclk_div_num)
        div_fclk_d = ~div_fclk_d_1t;
    else
        div_fclk_d = div_fclk_d_1t;
end

always @ (posedge fclk or negedge poresetn) begin
    if (~poresetn)
        div_fclk_d_1t <= 1'b0;
    else
        div_fclk_d_1t <= div_fclk_d;
end

`ifdef FPGA
reg div_fclk_q_reg;
assign div_fclk_q = div_fclk_q_reg;
always @(posedge fclk or negedge poresetn) begin
if(~poresetn)
  div_fclk_q_reg <= 1'b0;
else	
  div_fclk_q_reg <= div_fclk_d;
end
assign iclk = (iclk_div_final == 4'b000) ? fclk : div_fclk_q;
`else
// creat_generate_clk here
//DFFRQX4M DFF_DIV_FCLK (.Q(div_fclk_q), .CK(fclk), .D(div_fclk_d), .RN(poresetn));
DFFRHQ_X4_A7TULL DFF_DIV_FCLK (.Q(div_fclk_q), .CK(fclk), .D(div_fclk_d), .RN(poresetn));
wire not_dividor;
assign not_dividor = (iclk_div_final == 4'b000);
wire div_fclk_q_final;
//CLKMX2X4M DNT_DIV_ADC_CLK (.A(div_fclk_q), .B(fclk), .S0(not_dividor), .Y(div_fclk_q_final));
//CLKMX2X4M DNT_DIV_FCLK_ATPG (.A(div_fclk_q_final), .B(scan_clk), .S0(atpg_en), .Y(iclk));
CLKMX2_X4_A7TULL DNT_DIV_ADC_CLK (.A(div_fclk_q), .B(fclk), .S0(not_dividor), .Y(div_fclk_q_final));
CLKMX2_X4_A7TULL DNT_DIV_FCLK_ATPG (.A(div_fclk_q_final), .B(scan_clk), .S0(atpg_en), .Y(iclk));
`endif

assign adc_clk_running = iclk;
//reg enable_cic;

//imeas adc clock gating
common_clock_gate 
u_cmsdk_clock_gate_iadc_clk[15:0] (
.clk        (iclk),
//.enable     (imeas_en),
//.enable     ({8{imeas_working}} & en_channels & {8{enable_cic}}),
//.enable     ({16{imeas_working_sync}} & en_channels & {16{enable_cic}}),
.enable     ({16{imeas_working_sync}} & en_channels_sync_adcclk & {16{enable_cic}}),
.bypass     (atpg_en),
.gated_clk  (imeas_dig_adc_clk[15:0]));

wire imeas_analog_adc_clk;
common_clock_gate 
u_cmsdk_clock_gate_analog_adcclk (
.clk        (iclk),
//.enable     (imeas_working),
.enable     (imeas_working_sync),
.bypass     (atpg_en),
.gated_clk  (imeas_analog_adc_clk));


`ifdef FPGA
assign imeas_adc_clk = imeas_adc_inv ? imeas_dig_adc_clk[0] : ~imeas_dig_adc_clk[0];
`else
//CLKMX2X2M DNT_ADC_CLK_ATPG (.A(imeas_adc_inv), .B(1'b0), .S0(atpg_en), .Y(imeas_adc_inv_atpg));
CLKMX2_X4_A7TULL DNT_ADC_CLK_ATPG (.A(imeas_adc_inv), .B(1'b0), .S0(atpg_en), .Y(imeas_adc_inv_atpg));
//need change if analog seperate different clock
//CLKMX2X4M DNT_ADC_CLK_INV  (.A(imeas_dig_adc_clk[0]),
CLKMX2_X4_A7TULL DNT_ADC_CLK_INV  (.A(imeas_analog_adc_clk),
.B(~imeas_analog_adc_clk), .S0(imeas_adc_inv_atpg), .Y(imeas_adc_clk));
`endif

//for analog stable

//wire start_sample;
//wire stop_sample;
/*
assign start_sample = imeas_working_sync & (!imeas_working_sync_d1);
assign stop_sample = (!imeas_working_sync) & (imeas_working_sync_d1);
assign start_sample_pclk = imeas_working & (!imeas_working_sync_d1_pclk);
assign stop_sample_pclk = (!imeas_working) & (imeas_working_sync_d1_pclk);

reg [15:0] cnt_stable_time;
always @ (posedge adc_clk_running or negedge adc_resetn) begin
  if (~adc_resetn)
  cnt_stable_time <= 16'b0;
  else if(start_sample |stop_sample | (cnt_stable_time >= stable_time))
  cnt_stable_time <= 16'b0;
  else if ((!enable_cic) & imeas_working_sync) 
  cnt_stable_time <= cnt_stable_time + 16'b1;
end

wire meas_done_pos_bclk;
common_pulse_cdc u_meas_done_pos_sync(
.aclk(pclk),       //source clock
.bclk(adc_clk_running),       //destination clock
.arst_(presetn),      //source reset
.brst_(adc_resetn),      //destination reset
.atpg_en(atpg_en),  //Reset by pass
.a_pulse(meas_done_pos),    //source pulse
.b_pulse(meas_done_pos_bclk)     //destination pulse after cdc
); 


always @ (posedge adc_clk_running or negedge adc_resetn) begin
  if (~adc_resetn)
  enable_cic <= 1'b0;
  //else if(((start_sample | stop_sample) & (stable_time != 16'b0)) | (single_shot_true & meas_done_pos_bclk ))
  else if((start_sample | stop_sample) & (stable_time != 16'b0)) 
  enable_cic <= 1'b0;
  else if((!stop_sample) & (cnt_stable_time >= stable_time) & imeas_working_sync)
  enable_cic <= 1'b1;
end
*/


//====================

wire filter_clk_sclt;
assign filter_clk_sclt = notch_filter_valid? ~(|osr_sel[3:2]) && ~(&osr_sel[1:0]) : ~(|osr_sel[3:1]);

CLKMX2_X4_A7TULL DNT_NOTCH_FILTER_CLK[15:0] (.A(imeas_dig_adc_clk), .B(fclk), .S0(filter_clk_sclt), .Y(imeas_dig_filter_clk_post));

//HPF CLOCK
common_clock_gate u_hpf_clk_gate[15:0] (
.clk        (imeas_dig_filter_clk_post),
.enable     (hpf_clk_gtg_en),
.bypass     (atpg_en),
.gated_clk  (hpf_clk));

//END

//LPF CLOCK
common_clock_gate u_lpf_clk_gate[15:0] (
.clk        (imeas_dig_filter_clk_post),
.enable     (lpf_clk_gtg_en),
.bypass     (atpg_en),
.gated_clk  (lpf_clk));

//END

//NOTCH CLOCK

common_clock_gate u_notch_clk_gate[15:0] (
.clk        (imeas_dig_filter_clk_post),
.enable     (notch_clk_gtg_en),
.bypass     (atpg_en),
.gated_clk  (notch_clk));

//END
//for ppg
reg  [1:0]  ppg_clk_div_cnt;
reg  [1:0]  ppg_clk_div_num;
wire        ppg_clk;
wire  [1:0]  ppg_clk_div_final;               // imeas adc clock divider
assign ppg_clk_div_final =  ppg_clk_div ;               // imeas adc clock divider
always @ (*) begin
  case (ppg_clk_div_final)
    2'b01: ppg_clk_div_num = 2'd3; //6M
    2'b10: ppg_clk_div_num = 2'd0; //4M
    2'b11: ppg_clk_div_num = 2'd1; //2M
    default: ppg_clk_div_num = 2'd0;
  endcase
end
wire fclk_gate;
wire fclk_gate_en;
assign fclk_gate_en = ppg_clk50duty ? (ppg_clk_div_final[1]==1'b1)  : 1'b0;
common_clock_gate 
u_cmsdk_clock_gate_fclk_1 (
.clk        (fclk),
.enable     (fclk_gate_en), .bypass     (scan_enable), .gated_clk  (fclk_gate));

//always @ (posedge fclk or negedge poresetn) begin
always @ (posedge fclk_gate or negedge poresetn) begin
  if (~poresetn) 
    ppg_clk_div_cnt <= 2'b0;
  else if(ppg_clk50duty & (ppg_clk_div_cnt >= ppg_clk_div_num))
    ppg_clk_div_cnt <= 2'b0;
  else
    ppg_clk_div_cnt <= ppg_clk_div_cnt + 2'b1;
end

reg ppg_div_fclk_d;
reg ppg_div_fclk_d_1t;
reg ppg_div_fclk_q;
always @ (*) begin
    if (ppg_clk_div_cnt >= ppg_clk_div_num)
        ppg_div_fclk_d = ~ppg_div_fclk_d_1t;
    else
        ppg_div_fclk_d = ppg_div_fclk_d_1t;
end

//always @ (posedge fclk or negedge poresetn) begin
always @ (posedge fclk_gate or negedge poresetn) begin
    if (~poresetn)
        ppg_div_fclk_d_1t <= 1'b0;
    else
        ppg_div_fclk_d_1t <= ppg_div_fclk_d;
end

`ifdef FPGA
`else
// creat_generate_clk here
//DFFRQX4M DFF_DIV_FCLK (.Q(div_fclk_q), .CK(fclk), .D(div_fclk_d), .RN(poresetn));
//DFFRHQ_X4_A7TULL DFF_PPG_DIV_FCLK (.Q(ppg_div_fclk_q), .CK(fclk), .D(ppg_div_fclk_d), .RN(poresetn));
DFFRHQ_X4_A7TULL DFF_PPG_DIV_FCLK (.Q(ppg_div_fclk_q), .CK(fclk_gate), .D(ppg_div_fclk_d), .RN(poresetn));
wire duty50_div0_1;
assign duty50_div0_1 = ppg_clk50duty ? ((ppg_clk_div_final == 2'b00) | (ppg_clk_div_final == 2'b01)) : 1'b0;


reg ppg_clk_en;
always @ (*) begin
  case (ppg_clk_div_final)
    2'b00: ppg_clk_en = 1'b1;
    2'b01: ppg_clk_en = (ppg_clk_div_cnt[1:0]!=2'd3); //6M
    2'b10: ppg_clk_en = (ppg_clk_div_cnt[0]==1'd0); //4M
    2'b11: ppg_clk_en = (ppg_clk_div_cnt[1:0]==2'd0); //2M
    default: ppg_clk_en = 1'b1;
  endcase
end

wire ppg_clk_gateG;
common_clock_gate 
u_cmsdk_clock_gate_ppgclk_gate (
.clk        (fclk),
.enable     (ppg_clk_en), .bypass     (scan_enable), .gated_clk  (ppg_clk_gateG));
wire ppg_div_fclk_q_final;
//wire ppg_clk_8m_6m;
wire ppg_div_fclk_q_final_50;
//CLKMX2_X4_A7TULL DNT_DIV_PRE_PPG_CLK (.A(fclk), .B(ppg_clk_gateG), .S0((ppg_clk_div_final == 2'b01)), .Y(ppg_clk_8m_6m));
CLKMX2_X4_A7TULL DNT_DIV_PPG_50_CLK (.A(ppg_div_fclk_q), .B(ppg_clk_gateG), .S0(duty50_div0_1), .Y(ppg_div_fclk_q_final_50));


CLKMX2_X4_A7TULL DNT_DIV_PPG_CLK (.A(ppg_clk_gateG), .B(ppg_div_fclk_q_final_50), .S0(ppg_clk50duty), .Y(ppg_div_fclk_q_final));
CLKMX2_X4_A7TULL DNT_DIV_PPGCLK_ATPG (.A(ppg_div_fclk_q_final), .B(scan_clk), .S0(atpg_en), .Y(ppg_clk));
`endif

assign ppg_clk_running = ppg_clk;

//imeas adc clock gating
common_clock_gate 
u_cmsdk_clock_gate_ippg_clk (
.clk        (ppg_clk),
.enable     (~ppg_dis_sync),
.bypass     (atpg_en),
.gated_clk  (clk_ppg));

wire ppg_analog_ppg_clk;
common_clock_gate 
u_cmsdk_clock_gate_analog_clk (
.clk        (ppg_clk),
.enable     (~ppg_dis_sync),
.bypass     (atpg_en),
.gated_clk  (ppg_analog_ppg_clk));


`ifdef FPGA
`else
wire ppg_inv_atpg;
CLKMX2_X4_A7TULL DNT_PPG_CLK_ATPG (.A(ana_ppgclk_inv), .B(1'b0), .S0(atpg_en), .Y(ppg_inv_atpg));
//need change if analog seperate different clock
//CLKMX2X4M DNT_ADC_CLK_INV  (.A(ppg_dig_adc_clk[0]),
CLKMX2_X4_A7TULL DNT_PPG_CLK_INV  (.A(ppg_analog_ppg_clk),
.B(~ppg_analog_ppg_clk), .S0(ppg_inv_atpg), .Y(ana_clk_ppg));
`endif

endmodule

