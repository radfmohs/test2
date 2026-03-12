//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap Glucose Chip   
// File name:    imeas.v 
// Module Name : IMEAS TOP
// Description : Glucose measument digital part
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author          Description      
//------------------------------------------------------------------------------
// 0.1        05/21/2019  Daniel Wang       Initial Rev 
//------------------------------------------------------------------------------

module imeas #(
parameter DATA_WIDTH =32 
)
(
//clock and reset
input wire           pclk,             // pclk
input wire           adc_clk,          // adc working clock, divider of 256khz
input wire [3:0]     DR,
input wire           presetn,          // reset
input wire           atpg_en,          // atpg enable

//input/ouput wires from/to SPI
//input [1:0]        imeas_input_format,
input  wire [7:0]    reg_ctrl,
input  wire          cic_rst_n,
//input  wire [7:0]  reg_ch,
//input  wire [2:0]  reg_seq,
//input  wire	     int_clr,
//output wire 	     imeas_int_sts,

//input  wire [15:0] threshold_hi,
//input  wire [15:0] threshold_lo,
//input  wire	     int_alarm_en,
//input  wire	     int_alarm_clr,
//output wire 	     imeas_int_alarm_sts,

/*
input wire           d2a_tsc_core_fch_reg,
input wire           d2a_tsc_sdm_chop_reg,
input wire           core_sel,
input wire           chop_sel,
input wire [1:0]     wave_sel,
output wire          d2a_tsc_core_fch,
output wire          d2a_tsc_sdm_chop,
*/

//output wire [15:0]             chdata,
output wire   [DATA_WIDTH-1:0]   chdata,
output wire                      chdata_en,
output wire   [DATA_WIDTH-1:0]   chdata_adcclk,
output wire                      chdata_en_adcclk,

//output wire       imeas_int,        // interrupt 
//output wire       imeas_int_alarm,  // interrupt 
//with analog
input  wire         imeas_adc_din     // adc serial data input

);

wire   [31:0]   chdata_tmp;
assign   chdata = chdata_tmp[DATA_WIDTH-1:0];

wire            int_set;
//wire          int_alarm_set;
wire [1:0]      imeas_input_format;

//internal wire
//wire   [2:0]  cic_rate;
//wire          chrsv;
wire            format_sel;
//wire          sd16rst;
//wire          cic_rst;
//wire          cic_rst_n;
wire            sd16eoc_sync;
//wire   [15:0] sd16cic_data;
wire   [31:0]   sd16cic_data;
wire            sd16eoc;
//wire   [1:0]  imeas_input_format;

imeas_reg u_imeas_reg(
//.pclk(pclk),
//.atpg_en(atpg_en),
//.preset_n(presetn),
//.int_set(int_set),

.reg_ctrl(reg_ctrl),
//.reg_ch(reg_ch),
//.reg_seq(reg_seq),
//.int_clr(int_clr),

//.int_alarm_en(int_alarm_en),

//.int_sts(imeas_int_sts),
//.imeas_int(imeas_int),

//.int_alarm_clr(int_alarm_clr),
//.int_alarm_sts(imeas_int_alarm_sts),
//.imeas_int_alarm(imeas_int_alarm),
//.int_alarm_set(int_alarm_set),

.imeas_input_format(imeas_input_format),
//.alpha_0(alpha_0),
//.alpha_1(alpha_1),
//.alpha_2(alpha_2),
//.cic_rate(cic_rate),
//.chrsv(chrsv),
.format_sel(format_sel)
//.sd16rst(sd16rst)
);

imeas_cdc u_imeas_cdc(
.pclk(pclk),
.adc_clk(adc_clk),
.preset_n(presetn),
.atpg_en(atpg_en),
.sd16eoc(sd16eoc),
//.cic_rst(cic_rst),
.sd16eoc_sync(sd16eoc_sync)
//.cic_rst_n(cic_rst_n)
);

imeas_ctrl u_imeas_ctrl(
//.adc_clk(adc_clk),
//.cic_rst_n(cic_rst_n),
.pclk(pclk),
.preset_n(presetn),
.sd16eoc_sync(sd16eoc_sync),
.sd16cic_data(sd16cic_data),
//.sd16rst(sd16rst),
//.chmod(chmod),
//.chnum(chnum),
.ch0data(chdata_tmp),
.ch0data_en(chdata_en),
//.cic_rst(cic_rst),
//.threshold_hi(threshold_hi),
//.threshold_lo(threshold_lo),
.int_set(int_set)
//.int_alarm_set(int_alarm_set)
);

imeas_cic u_imeas_cic(
.clk(adc_clk),
.resetn(cic_rst_n),
.imeas_input_format(imeas_input_format),
.DR(DR),
//.DR(1),
/*
 .d2a_tsc_core_fch_reg(d2a_tsc_core_fch_reg),
 .d2a_tsc_sdm_chop_reg(d2a_tsc_sdm_chop_reg),
 .core_sel(core_sel),
 .chop_sel(chop_sel),
 .wave_sel(wave_sel),
 .d2a_tsc_core_fch(d2a_tsc_core_fch),
 .d2a_tsc_sdm_chop(d2a_tsc_sdm_chop),
*/
.format_sel(format_sel),
.filter_in(imeas_adc_din),
.filter_out(sd16cic_data),
.eoc_out(sd16eoc)
);

assign    chdata_adcclk = sd16cic_data;
assign    chdata_en_adcclk = sd16eoc;

endmodule
