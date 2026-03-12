//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap ENS2  
// Module Name : reset_ctrl
// Description : simple reset selection MUX 
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author
//------------------------------------------------------------------------------
// 0.1          4/11/2021  Mohsen Radfar Initial Rev
//------------------------------------------------------------------------------

module reset_ctrl (
input  wire         por_resetn,                 // Power on reset, low active
input  wire         ext_resetn,                 // External reset, low active
input  wire         otp_bist_resetn,          // otp bist reset
input  wire         scan_rst_n,                 // Scan Reset
input  wire         atpg_en,                    // ATPG enable (for DFT)
//input  wire         otp_bist_en,              // otp bist mode 
input  wire         hfosc_atpg,                 // hfosc base clock input
//input  wire         fclk,                       // fclk after clock switch
input  wire         pclk,                       // APB clock

input  wire 	    ppg_clk_running,
output wire        ppg_resetn,
input  wire ppg_rst_reg,
//for bps function
input wire         cic_rst,
input wire         adc_clk,
output wire        cic_rst_n,
output wire        adc_resetn,
output wire        adc_ctrl_resetn,
input  wire         reset_cmd,
//input  wire         start_meas,
output wire         filter_rstn,
input wire start_sample,
//input wire stop_sample,
input wire start_sample_pclk,
//input wire stop_sample_pclk,
//==========



input  wire otp_rst_reg,
input  wire dig_rst_reg,
input  wire lead_off_rst,
input  wire anac_reset,
input  wire temp_sar_reset,
output wire lead_off_presetn,
output wire anac_presetn,
output wire temp_sar_presetn,

input  wire         wave_gen_rst,
output wire         wave_gen_presetn,
output wire         poresetn,                   // Connect to poresetn of CORTEXM0INTEGRATION
output wire         poresetn_hf,                // hfclk poresetn
output wire         presetn,                    // Connect to presetn of CORTEXM0INTEGRATION
//output wire         otp_por_resetn,           // otp por reset that will early 1ms than system por reset 
output wire         otp_bist_resetn_atpg,     // otp bist reset after atpg mux

// EEPROM 
/*
input  wire         prep_to_slp,
output reg          rst_ctrl_otp_vdd2_enable,                    // Connect to presetn of CORTEXM0INTEGRATION
output reg          prep_to_slp_delay1clk,
output reg          prep_to_slp_delay2clk,
output wire         prep_to_slp_sync,
*/
output wire 	    otp_rstn
);

wire global_rstn;

reg [15:0]  por_cnt;
wire        por_tmout;
reg         por_tmout_resetn;
//wire        otp_por_tmout;
//reg         otp_por_tmout_resetn;

wire        por_resetn_atpg;
wire        global_rstn_atpg;

// otp_bist_reset atpg mux
assign otp_bist_resetn_atpg = atpg_en ? scan_rst_n : otp_bist_resetn;

// por reset atpg mux
//assign por_resetn_atpg = atpg_en ? scan_rst_n : (por_resetn & ext_resetn & (~reset_cmd));
assign por_resetn_atpg = atpg_en ? scan_rst_n : (por_resetn & ext_resetn);

`ifdef FAST_SIM
assign por_tmout        = (por_cnt==16'h000f);
//assign otp_por_tmout  = (por_cnt==16'h000a); 
`else
assign por_tmout        = (por_cnt==16'h0300);
//assign otp_por_tmout  = (por_cnt==16'h00c0);  
`endif

wire por_resetn_atpg_sync;
common_rst_sync u_por_resetn_sync (
.CLK(hfosc_atpg),
.RSTBYPASS(atpg_en),
.RSTREQ(1'b0),
.SE(1'b0),
.RSTINn(por_resetn_atpg),
.RSTOUTn(por_resetn_atpg_sync));


// POR delay to ensure clock stable
//always @(posedge hfosc_atpg or negedge por_resetn_atpg) begin
    //if (~por_resetn_atpg)
always @(posedge hfosc_atpg or negedge por_resetn_atpg_sync) begin
    if (~por_resetn_atpg_sync)
        por_cnt <= 16'b0;
    else if (~por_tmout)
        por_cnt <= por_cnt + 1'b1;
    else
        por_cnt <= por_cnt;
end

// system por delay 1ms 
//always @(posedge hfosc_atpg or negedge por_resetn_atpg) begin
 //   if (~por_resetn_atpg)
always @(posedge hfosc_atpg or negedge por_resetn_atpg_sync) begin
    if (~por_resetn_atpg_sync)
        por_tmout_resetn <= 1'b0;
    else if (por_tmout)
        por_tmout_resetn <= 1'b1;
    else
        por_tmout_resetn <= por_tmout_resetn;
end
/*
// otp por delay 14ms, as otp can work after otp por 10us 
always @(posedge hfosc_atpg or negedge por_resetn_atpg) begin
    if (~por_resetn_atpg)
        otp_por_tmout_resetn <= 1'b0;
    else if (otp_por_tmout)
        otp_por_tmout_resetn <= 1'b1;
    else
        otp_por_tmout_resetn <= otp_por_tmout_resetn;
end
*/
//reset cmd should not affect the otp???
//assign otp_por_resetn = (otp_bist_en | atpg_en) ? por_resetn_atpg : otp_por_tmout_resetn;
//assign otp_por_resetn = (otp_bist_en | atpg_en) ? por_resetn_atpg : (otp_por_tmout_resetn & (~reset_cmd_pulse));



// Global reset
//assign global_rstn = por_tmout_resetn & ext_resetn;
//assign global_rstn = por_tmout_resetn;
wire global_rstn_bak;
assign global_rstn_bak = atpg_en ? scan_rst_n : (por_tmout_resetn & ext_resetn & dig_rst_reg);
common_rst_sync u_global_rstn_bak_sync (
.CLK(hfosc_atpg),
.RSTBYPASS(atpg_en),
.RSTREQ(1'b0),
.SE(1'b0),
.RSTINn(global_rstn_bak),
.RSTOUTn(global_rstn));
// Global reset atpg mux
//assign global_rstn_atpg = atpg_en ? scan_rst_n : global_rstn;
MX2_X4_A7TULL DNT_MX2 (.A(global_rstn), .B(scan_rst_n), .S0(atpg_en), .Y(global_rstn_atpg));


// --------------------
// Reset synchronisers
// --------------------
/*
common_rst_sync u_poresetn_hf_sync(
.RSTINn    (global_rstn_atpg),
.RSTREQ    (1'b0),
.CLK       (hfosc_atpg),
.SE        (atpg_en),
.RSTBYPASS (atpg_en),
.RSTOUTn   (poresetn_hf)
);
*/
assign poresetn_hf = global_rstn_atpg;

// fclk domain poresetn sync  
/*
common_rst_sync u_poresetn_sync(
.RSTINn    (global_rstn_atpg),
.RSTREQ    (1'b0),
.CLK       (fclk),
.SE        (atpg_en),
.RSTBYPASS (atpg_en),
.RSTOUTn   (poresetn)
);
*/
assign poresetn = global_rstn_atpg;

// pclk domain poresetn sync  
/*
common_rst_sync u_presetn_sync(
.RSTINn    (global_rstn_atpg),
.RSTREQ    (1'b0),
.CLK       (pclk),
.SE        (atpg_en),
.RSTBYPASS (atpg_en),
.RSTOUTn   (presetn)
);
*/
assign presetn = global_rstn_atpg;

wire wave_gen_presetn_tmp;
assign wave_gen_presetn_tmp = atpg_en? scan_rst_n :  (global_rstn_atpg & (~wave_gen_rst)); 

common_rst_sync u_wave_gen_presetn_sync(
.RSTINn    (wave_gen_presetn_tmp),
.RSTREQ    (1'b0),
.CLK       (pclk),
.SE        (atpg_en),
.RSTBYPASS (atpg_en),
.RSTOUTn   (wave_gen_presetn)
);

wire lead_off_presetn_tmp;
assign lead_off_presetn_tmp = atpg_en? scan_rst_n : (global_rstn_atpg & (~lead_off_rst));
common_rst_sync u_lead_off_rst_sync(
.RSTINn    (lead_off_presetn_tmp),
.RSTREQ    (1'b0),
.CLK       (pclk),
.SE        (atpg_en),
.RSTBYPASS (atpg_en),
.RSTOUTn   (lead_off_presetn)
);

wire anac_presetn_tmp;
assign anac_presetn_tmp = atpg_en? scan_rst_n : (global_rstn_atpg & (~anac_reset));
common_rst_sync u_anac_rst_sync(
.RSTINn    (anac_presetn_tmp),
.RSTREQ    (1'b0),
.CLK       (pclk),
.SE        (atpg_en),
.RSTBYPASS (atpg_en),
.RSTOUTn   (anac_presetn)
);

wire temp_sar_presetn_tmp;
assign temp_sar_presetn_tmp = atpg_en? scan_rst_n : (global_rstn_atpg & (~temp_sar_reset));
common_rst_sync u_temp_sar_rst_sync(
.RSTINn    (temp_sar_presetn_tmp),
.RSTREQ    (1'b0),
.CLK       (pclk),
.SE        (atpg_en),
.RSTBYPASS (atpg_en),
.RSTOUTn   (temp_sar_presetn)
);


wire ppg_rst_presetn_tmp;
assign ppg_rst_presetn_tmp = atpg_en? scan_rst_n : (global_rstn_atpg & (~ppg_rst_reg));
common_rst_sync u_ppg_rst_rst_sync(
.RSTINn    (ppg_rst_presetn_tmp),
.RSTREQ    (1'b0),
.CLK       (ppg_clk_running),
.SE        (atpg_en),
.RSTBYPASS (atpg_en),
.RSTOUTn   (ppg_resetn)
);

// EEPROM 
/*
common_bit_sync sync_clk_busy (
.i_clk     (pclk),
.i_rst_n   (presetn),
.i_async_in(prep_to_slp),
.o_sync_out(prep_to_slp_sync)
);


always @(posedge pclk or negedge presetn) begin
    if (~presetn)
	rst_ctrl_otp_vdd2_enable <= 1'b0;
    else
	rst_ctrl_otp_vdd2_enable <= 1'b1;
end

reg prep_to_slp_delay3clk;
always @ (posedge pclk or negedge presetn)
	if (~presetn) begin
        prep_to_slp_delay1clk  <= 1'b0;
	    prep_to_slp_delay2clk  <= 1'b0;
        prep_to_slp_delay3clk  <= 1'b0;
    end else if (rst_ctrl_otp_vdd2_enable) begin
	    prep_to_slp_delay1clk <= prep_to_slp_sync;
	    prep_to_slp_delay2clk <= prep_to_slp_delay1clk;
        prep_to_slp_delay3clk <= prep_to_slp_delay2clk;
    end

wire   otp_rst_again_en;
assign otp_rst_again_en = prep_to_slp_delay3clk & (!prep_to_slp_delay2clk);
wire   otp_rst_again;
assign otp_rst_again = otp_rst_again_en;

*/
wire otp_presetn_tmp;
wire otp_presetn;
assign otp_presetn_tmp = atpg_en? scan_rst_n : (global_rstn_atpg & (~otp_rst_reg));
common_rst_sync u_otp_rst_sync(
.RSTINn    (otp_presetn_tmp),
.RSTREQ    (1'b0),
.CLK       (pclk),
.SE        (atpg_en),
.RSTBYPASS (atpg_en),
.RSTOUTn   (otp_presetn)
);

wire otp_rst_atpg;   //tri add to fix dft
//assign otp_rst_atpg = atpg_en? scan_rst_n : (presetn & (!otp_rst_again));  //tri add to fix dft
//assign otp_rst_atpg = atpg_en? scan_rst_n : presetn;  //tri add to fix dft
assign otp_rst_atpg = otp_presetn;  //tri add to fix dft

/*
common_rst_sync u_presetn_otp(
.RSTINn    (otp_rst_atpg),
.RSTREQ    (1'b0),
.CLK       (pclk),
.SE        (atpg_en),
.RSTBYPASS (atpg_en),
.RSTOUTn   (otp_rstn)
);
*/
assign otp_rstn = otp_rst_atpg;


//for bps function
wire reset_cmd_d2;
reg reset_cmd_d3;
common_sync_bit common_bit_sync_rst_cmd(
                .async_in(reset_cmd),
                .clk(hfosc_atpg),
                .rst_(por_resetn_atpg),      
                .sync_out(reset_cmd_d2));

always @(posedge hfosc_atpg or negedge por_resetn_atpg) begin
    if (~por_resetn_atpg) begin
	reset_cmd_d3 <= 1'b0;
    end else begin
	reset_cmd_d3 <= reset_cmd_d2;
    end
end
wire reset_cmd_pulse;
assign reset_cmd_pulse = reset_cmd_d2 & (!reset_cmd_d3);

//wire    start_measn;
//assign  start_measn = ~start_meas;

wire         filter_rstn_atpg;
//MX2X4M DNT_MX_FILTER (.A(global_rstn_atpg  & start_measn), .B(scan_rst_n), .S0(atpg_en), .Y(filter_rstn_atpg));
//MX2_X4_A7TULL DNT_MX_FILTER (.A(global_rstn_atpg & (~cic_rst) & (~reset_cmd_pulse) &  (!(start_sample_pclk | stop_sample_pclk))), .B(scan_rst_n), .S0(atpg_en), .Y(filter_rstn_atpg));
MX2_X4_A7TULL DNT_MX_FILTER (.A(global_rstn_atpg & (~cic_rst) & (~reset_cmd_pulse) &  (!(start_sample_pclk ))), .B(scan_rst_n), .S0(atpg_en), .Y(filter_rstn_atpg));

common_rst_sync u_presetn_filter_sync(
.RSTINn    (filter_rstn_atpg),
.RSTREQ    (1'b0),
.CLK       (pclk),
.SE        (atpg_en),
.RSTBYPASS (atpg_en),
.RSTOUTn   (filter_rstn)
);

wire cic_rst_atpg_n;
//assign cic_rst_atpg_n = atpg_en ? presetn : (presetn & (~cic_rst)  & (~reset_cmd_pulse) & (!(start_sample | stop_sample)));
assign cic_rst_atpg_n = atpg_en ? presetn : (presetn & (~cic_rst)  & (~reset_cmd_pulse) & (!(start_sample )));

common_rst_sync u_cic_rst_sync(
.RSTINn    (cic_rst_atpg_n),
.RSTREQ    (1'b0),
.CLK       (adc_clk),
.SE        (atpg_en),
.RSTBYPASS (atpg_en),
.RSTOUTn   (cic_rst_n)
);

wire adc_resetn_pre;
assign adc_resetn_pre = atpg_en ? presetn : (presetn & (~cic_rst) & (~reset_cmd_pulse)) ;
common_rst_sync u_adc_rst_sync(
.RSTINn    (adc_resetn_pre),
.RSTREQ    (1'b0),
.CLK       (adc_clk),
.SE        (atpg_en),
.RSTBYPASS (atpg_en),
.RSTOUTn   (adc_resetn)
);

common_rst_sync u_adc_ctrl_rst_sync(
.RSTINn    (adc_resetn_pre),
.RSTREQ    (1'b0),
.CLK       (hfosc_atpg),
.SE        (atpg_en),
.RSTBYPASS (atpg_en),
.RSTOUTn   (adc_ctrl_resetn)
);

//===============

endmodule


