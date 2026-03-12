//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//
// Module Name : apb_anac
// Description : APB analog control module
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author
//------------------------------------------------------------------------------
// 0.1          15/07/2021  Daniel Wang 
// Initial Rev
//------------------------------------------------------------------------------

module apb_anac #(
parameter NO_OF_WAVEGEN = 2

)(

spi_anac.slave     spi_anac,
// system
input  wire         sysclk,
input  wire         presetn,
//input  wire         scan_clk,
//input  wire         scan_mode,
//input  wire         scan_enable,
input wire          ana_lvd_sts,

//input  wire [NO_OF_WAVEGEN-1 :0 ] A2D_COMP0_7,		
//input  wire [NO_OF_WAVEGEN-1 :0 ] A2D_STIMU0_15, 


//input wire [NO_OF_WAVEGEN-1 :0 ]  drive_en,
output wire         o_anac_int
//output wire         o_ana_comp_ch1_intr_pin,
//output wire         o_ana_comp_ch2_intr_pin	

);

//LVD
assign spi_anac.ana_lvd_intr_pin= spi_anac.ana_lvd_intr_en ? (ana_lvd_sts ? 1'b1: 1'b0): 1'b0;

wire int_length_slct;
assign int_length_slct = spi_anac.int_length_slct;

//===================================================================================
wire anac_int_temp;
common_pulse_rising u_anac_int_temp_rising(
.d_in(spi_anac.ana_lvd_intr_pin),
.clk(sysclk),
.rst_(presetn),
.d_out(anac_int_temp)
);
assign o_anac_int = (spi_anac.ana_lvd_intr_pin & !int_length_slct) | (anac_int_temp & int_length_slct);


//===================================================================================
//int
//wire [NO_OF_WAVEGEN-1 :0 ] ana_stimu_ch_intr_pin;
//wire [NO_OF_WAVEGEN-1 :0 ] ana_comp_ch_intr_pin;
//wire [NO_OF_WAVEGEN-1 :0 ] ana_stimu_ch_polarity;

//wire [NO_OF_WAVEGEN*2:0] int_comb;
//assign int_comb = {ana_stimu_ch_intr_pin, ana_comp_ch_intr_pin, spi_anac.ana_lvd_intr_pin};

//wire [NO_OF_WAVEGEN*2:0] anac_int_temp;
//common_pulse_rising u_anac_int_temp_rising[NO_OF_WAVEGEN*2:0](
//.d_in(int_comb),
//.clk(sysclk),
//.rst_(presetn),
//.d_out(anac_int_temp)
//);
//assign o_anac_int = ((|int_comb) & !int_length_slct) | ((|anac_int_temp) & int_length_slct);



/////////////////--ANA_COMP_CH1_INTERRUPT_GENARTION---///////////////

//genvar i;
//generate 
//  for(i=0;i<NO_OF_WAVEGEN;i=i+1) begin : comp_short_detection
//
//anac_int_edge_dtct u_comp(
//.sysclk                      (sysclk),	
//.presetn                     (presetn),
//.scan_mode                   (scan_mode),
//
//.A2D_COMP                    (A2D_COMP0_7[i]),	
//
//.ana_comp_ch_intr_en         (spi_anac.ana_comp_ch_intr_en[i]),
//.ana_comp_ch_intr_trans_sel  (spi_anac.ana_comp_ch_intr_trans_sel[i]),
//.ana_comp_ch_intr_sts_clr    (spi_anac.ana_comp_ch_intr_sts_clr[i]),
//
//.o_ana_comp_ch_intr_sts      (spi_anac.ana_comp_ch_intr_sts[i]),
//.o_ana_comp_ch_intr_pin      (ana_comp_ch_intr_pin[i])
//
//);
//
//
////short circuit//
//assign ana_stimu_ch_polarity[i] = spi_anac.anac_short_leadoff_en? 
//	                           spi_anac.anac_int_pol[i]? ~A2D_COMP0_7[i] : A2D_COMP0_7[i] : 
//				   spi_anac.anac_int_pol[i]? ~A2D_STIMU0_15[i] : A2D_STIMU0_15[i];
//
//anac_short_dtct u_anac_short_dtct_ch(
//.sysclk                    (sysclk),
//.presetn                   (presetn),
//.scan_mode                 (scan_mode),
//.drive_en                  (drive_en[i] & spi_anac.anac_short_drive_en[i]),
//.A2D_COMP                  (ana_stimu_ch_polarity[i]),
//.int_en                    (spi_anac.anac_short_int_en[i]),
//.timer_TH                  (spi_anac.ana_stimu_ch_timer_TH[i]),	
//.counter_TH                (spi_anac.ana_stimu_ch_counter_TH[i]),	
//.ana_stimu_ch_intr_sts_clr (spi_anac.ana_stimu_ch_intr_sts_clr[i]),
//.counter_th_cnt_dbg        (spi_anac.counter_th_cnt_dbg[i]),
//.o_ana_stimu_chx_intr_sts  (spi_anac.ana_stimu_ch_intr_sts[i]),
//.o_ana_stimu_chx_intr_pin  (ana_stimu_ch_intr_pin[i])
//
//);
//
//
//
//     end
//endgenerate

endmodule

