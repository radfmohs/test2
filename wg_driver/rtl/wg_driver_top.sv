
//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap ENS2  
// Module Name : Wave Generator Driver TOP
// Description : TOP block for Arbitrary Wave Generator Controller for the Analogue Drivers
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Design
//------------------------------------------------------------------------------
// 0.1          12/07/2021  Mohsen Radfar
// Initial Rev
//------------------------------------------------------------------------------

module wg_driver_top#(
parameter ADDR_WIDTH = 12,
	HLF_WV_NO_PTS = 6, // number of points in the input quantised half (of the period) wave (e.g. 64 points for first half of the sine wave). Ensure it is a power of 2 value
	OUT_NO_BITS = 8, // number of bits for the generated output value (which goes into the DAC)
	ELEC_NO = 13 //total number of electrodes
//	ELEC_NO_REGS_BLK = 4 //which block requires electrode number registers (Driver B number)
)(
// analog side interface
//--------inputs from analog-------//
//NA
//--------outputs to analog------//
  output logic [ELEC_NO-1:0] [OUT_NO_BITS-1:0] 	o_out_wave_val, //
//  output logic [7:0] 			o_elec_no,
//  output logic [ELEC_NO-1:0]		o_driver_enable,       // Driver enable, active high
  output logic [ELEC_NO-1:0] [1:0]       o_source,       // source A:0 or B:1
 // output logic [ELEC_NO-1:0] [2:0]       		o_isel,       // isel (current select)
  output logic [ELEC_NO-1:0]		o_driver_sel, //which driver this waveform will go to
//  output logic [7:0] [1:0]		o_sw,

// Digital side interface
//clock and reset
  input          		i_pclk,          // pclk
//  input          		i_pclkg,         // gated clock
  input          		i_presetn,       // reset
  input wire                    scan_mode,  //tri add
  input  wire                   int_length_slct,

  output wire  [7:0] in_wave_addr[ELEC_NO-1:0], //
  output wire  [7:0] ems_wave_addr[ELEC_NO-1:0], //
  output wire  [1:0] w_source[ELEC_NO-1:0],
  output reg  [1:0] o_sw[ELEC_NO-1:0],
//  output wire [7:0] hlf_wave_cnt[ELEC_NO-1:0],
  output wire [1:0] period_num[ELEC_NO-1:0],

  input wire  [15:0] rest_t[ELEC_NO-1:0], 	//resting time (in microseconds) between the positive side and the negative side of the wave in a period
  input wire  [31:0] silent_t[ELEC_NO-1:0], 	//silent time (in microseconds) before the next wave period
  input wire  [15:0] rest_t1[ELEC_NO-1:0], 	//resting time (in microseconds) between the positive side and the negative side of the wave in a period
  input wire  [31:0] silent_t1[ELEC_NO-1:0], 	//silent time (in microseconds) before the next wave period
  input wire  [15:0] rest_t2[ELEC_NO-1:0], 	//resting time (in microseconds) between the positive side and the negative side of the wave in a period
  input wire  [31:0] silent_t2[ELEC_NO-1:0], 	//silent time (in microseconds) before the next wave period
  input wire  [15:0] hlf_wave_per[ELEC_NO-1:0], //positive half of the period of the arbitrary (e.g. sine or square) wave (in microseconds)
  input wire  [15:0] neg_hlf_wave_per[ELEC_NO-1:0], //negative half of the period of the arbitrary (e.g. sine or square) wave (in microseconds)
  input wire  [15:0] hlf_wave_per1[ELEC_NO-1:0], //positive half of the period of the arbitrary (e.g. sine or square) wave (in microseconds)
  input wire  [15:0] neg_hlf_wave_per1[ELEC_NO-1:0], //negative half of the period of the arbitrary (e.g. sine or square) wave (in microseconds)
  input wire  [15:0] hlf_wave_per2[ELEC_NO-1:0], //positive half of the period of the arbitrary (e.g. sine or square) wave (in microseconds)
  input wire  [15:0] neg_hlf_wave_per2[ELEC_NO-1:0], //negative half of the period of the arbitrary (e.g. sine or square) wave (in microseconds)
  input wire  [7:0]  point_config[ELEC_NO-1:0],
  input wire  [15:0] alter_lim[ELEC_NO-1:0], //
  input wire  [15:0] alter_silent_lim[ELEC_NO-1:0], //
  input wire  [15:0] alter_rest_lim[ELEC_NO-1:0], //
  input wire  [15:0] delay_lim[ELEC_NO-1:0], //
 // input wire  [7:0] clk_freq[ELEC_NO-1:0], //clock frequency in MHz
  input wire  [7:0] config_reg[ELEC_NO-1:0], //
  input wire  [OUT_NO_BITS-1:0] out_wave_val[ELEC_NO-1:0],
  input wire 	w_mult_elec[ELEC_NO-1:0], //allow multiple electrodes to be active at the same time
  input wire 	[7:0]  pullba_ctrl[ELEC_NO-1:0],
//  input wire  	w_interrupt[ELEC_NO-1:0],
  input wire  [15:0] w_sw_config_reg[ELEC_NO-1:0],
//  input wire  [2:0] w_isel[ELEC_NO-1:0],
  input wire        i_wg_driver_en[ELEC_NO-1:0],
  input wire  [4:0] i_period_sel[ELEC_NO-1:0],

  input wire       no_of_num_slient_disable[ELEC_NO-1:0],
  input wire [15:0] no_of_num_slient_tar[ELEC_NO-1:0],

  input wire [7:0]  reg_wg_cal_addr[ELEC_NO-1:0],
  input wire [3:0]   i_data_scl[ELEC_NO-1:0],                 
  input wire [5:0]   i_ems_data_ctrl[ELEC_NO-1:0], 
  input wire [7:0]   i_reg_wg_driver_neg_scale[ELEC_NO-1:0],  
  input wire [7:0]   i_wg_driver_pos_scale[ELEC_NO-1:0],      
  input wire [7:0]   i_reg_wg_driver_neg_offset[ELEC_NO-1:0], 
  input wire [7:0]   i_reg_wg_driver_pos_offset[ELEC_NO-1:0], 
  input wire [7:0]   alt_ems_cnt_tar[ELEC_NO-1:0],
  output wire [3:0] data_scl[ELEC_NO-1:0],      
  output wire [3:0] ems_data_ctrl[ELEC_NO-1:0],                
  output wire [7:0] wg_driver_neg_scale[ELEC_NO-1:0],        
  output wire [7:0] wg_driver_pos_scale[ELEC_NO-1:0],        
  output wire [7:0] wg_driver_neg_offset[ELEC_NO-1:0],       
  output wire [7:0] wg_driver_pos_offset[ELEC_NO-1:0], 

  input wire [7:0] wg_driver_int_addr0[ELEC_NO-1:0],
  input wire [7:0] wg_driver_int_addr1[ELEC_NO-1:0],
  input wire       wg_driver_int_en[ELEC_NO-1:0],
  input wire       addr0_int_clr[ELEC_NO-1:0],
  input wire       addr1_int_clr[ELEC_NO-1:0],
  input wire [7:0] wg_driver_int_cnt[ELEC_NO-1:0],
  output wire [1:0] wg_driver_int_sts[ELEC_NO-1:0],

  output 	 		o_wg_driver_interrupt //one of the modules have run into an intrrupt to load the new waveform data
  );

wire [ELEC_NO-1:0] w_interrupt;

//always_comb begin
//	for (integer idx = 0; idx < ELEC_NO; idx = idx+1) begin
//               o_isel[idx] = w_isel[idx];
//               o_driver_enable[idx] = i_wg_driver_en[idx];
//	end
//end

genvar i;
for(i=0; i<ELEC_NO; i=i+1) begin : WG_SUB_BLOCK	

	arb_wave_gen
	#( // parameters
		.HLF_WV_NO_PTS(HLF_WV_NO_PTS),
		.OUT_NO_BITS(OUT_NO_BITS)
	)
	arb_wave_gen_inst
	( //arguments
		.rest_t			(rest_t[i]), //resting time (in microseconds) between the positive side and the negative side of the wave in a period
		.silent_t		(silent_t[i]), //silent time (in microseconds) before the next wave period
		.rest_t1		(rest_t1[i]), //resting time (in microseconds) between the positive side and the negative side of the wave in a period
		.silent_t1		(silent_t1[i]), //silent time (in microseconds) before the next wave period
		.rest_t2		(rest_t2[i]), //resting time (in microseconds) between the positive side and the negative side of the wave in a period
		.silent_t2		(silent_t2[i]), //silent time (in microseconds) before the next wave period
		.hlf_wave_per		(hlf_wave_per[i]), //half of the period of the arbitrary (e.g. sine or square) wave (in microseconds); h1f4=500 us = 2 KHz
		.neg_hlf_wave_per	(neg_hlf_wave_per[i]), //half of the period of the arbitrary (e.g. sine or square) wave (in microseconds); h1f4=500 us = 2 KHz
		.hlf_wave_per1		(hlf_wave_per1[i]), //half of the period of the arbitrary (e.g. sine or square) wave (in microseconds); h1f4=500 us = 2 KHz
		.neg_hlf_wave_per1	(neg_hlf_wave_per1[i]), //half of the period of the arbitrary (e.g. sine or square) wave (in microseconds); h1f4=500 us = 2 KHz
		.hlf_wave_per2		(hlf_wave_per2[i]), //half of the period of the arbitrary (e.g. sine or square) wave (in microseconds); h1f4=500 us = 2 KHz
		.neg_hlf_wave_per2	(neg_hlf_wave_per2[i]), //half of the period of the arbitrary (e.g. sine or square) wave (in microseconds); h1f4=500 us = 2 KHz               
                .point_config           (point_config[i]),
		.alt_lim		(alter_lim[i]), //
		.alt_silent_lim		(alter_silent_lim[i]), //
		.alt_rest_lim		(alter_rest_lim[i]), //
		.delay_lim		(delay_lim[i]), 
//		.clk_freq		(clk_freq[i]), //clock frequency in MHz
		.i_config_reg		(config_reg[i]), //bit 0:rest enable, 1:negative enable, 2: silent enable, 3: source B enable, 4: alternating (+/-) the positive side
		.clk			(i_pclk),
		.reset			(i_presetn),
                .scan_mode              (scan_mode),   //tri change
                .int_length_slct(int_length_slct),
		.enable			(i_wg_driver_en[i]),
                .period_sel           (i_period_sel[i]),
                .reg_wg_cal_addr      (reg_wg_cal_addr[i]),
                .wg_driver_int_addr0  (wg_driver_int_addr0[i]),
                .wg_driver_int_addr1  (wg_driver_int_addr1[i]),
                .wg_driver_int_en     (wg_driver_int_en[i]),
                .addr0_int_clr        (addr0_int_clr[i]),
                .addr1_int_clr        (addr1_int_clr[i]),
                .wg_driver_int_cnt    (wg_driver_int_cnt[i]),
                .wg_driver_int_sts    (wg_driver_int_sts[i]),
                .wg_driver_interrupt  (w_interrupt[i]),
		.o_in_wave_addr	      (in_wave_addr[i]),
		.o_ems_wave_addr      (ems_wave_addr[i]),

                .i_data_scl                    (i_data_scl[i]),
                .i_ems_data_ctrl               (i_ems_data_ctrl[i]),
                .i_reg_wg_driver_neg_scale     (i_reg_wg_driver_neg_scale[i]),
                .i_wg_driver_pos_scale         (i_wg_driver_pos_scale[i]),
                .i_reg_wg_driver_neg_offset    (i_reg_wg_driver_neg_offset[i]),
                .i_reg_wg_driver_pos_offset    (i_reg_wg_driver_pos_offset[i]),
                .alt_ems_cnt_tar               (alt_ems_cnt_tar[i]),
                .data_scl                      (data_scl[i]),
                .ems_data_ctrl                 (ems_data_ctrl[i]),
                .wg_driver_neg_scale           (wg_driver_neg_scale[i]),
                .wg_driver_pos_scale           (wg_driver_pos_scale[i]),
                .wg_driver_neg_offset          (wg_driver_neg_offset[i]),
                .wg_driver_pos_offset          (wg_driver_pos_offset[i]), 

                .o_period_num           (period_num[i]),
                .pullba_ctrl            (pullba_ctrl[i]),
                .no_of_num_slient_disable(no_of_num_slient_disable[i]),
                .no_of_num_slient_tar    (no_of_num_slient_tar[i]),
		.source			(w_source[i])
	);

/*
	//-------------------- apb_register block------------------------

	wg_driver_reg#(
		.ADDR_WIDTH		(ADDR_WIDTH),
		.HLF_WV_NO_PTS		(HLF_WV_NO_PTS),
		.OUT_NO_BITS		(OUT_NO_BITS),
		.blk_i			(i),
		.ELEC_NO_REGS		(i==ELEC_NO_REGS_BLK?1:0)
	)
	wg_driver_reg(
		 .i_pclk			(i_pclk),
		 .i_pclkg			(i_pclkg),
		 .i_presetn			(i_presetn),
		 .i_psel			(i_psel),
		 .i_paddr			(i_paddr),
		 .i_penable			(i_penable),
		 .i_pwrite			(i_pwrite),
		 .i_pwdata			(i_pwdata),
		 .i_pstrb			(i_pstrb),
		 .o_prdata			(prdata[i]),
		 .o_pready			(pready[i]),
		 .o_pslverr			(pslverr[i]),
		 .o_drv_sel			(drv_sel[i]),

		 .i_wg_driver_in_wave_addr	(in_wave_addr[i]),
		 .i_wg_driver_source		(w_source[i]),
		 .o_wg_driver_en		(o_driver_enable[i]),
		 .o_config_reg			(config_reg[i]),
		 .o_wg_driver_rest_t		(rest_t[i]), 
		 .o_wg_driver_silent_t		(silent_t[i]),
		 .o_wg_driver_delay_lim		(delay_lim[i]),
		 .o_wg_driver_hlf_wave_prd	(hlf_wave_per[i]),
		 .o_wg_driver_neg_hlf_wave_prd	(neg_hlf_wave_per[i]),
		 .o_wg_driver_alter_lim		(alter_lim[i]),
		 .o_wg_driver_alter_silent_lim	(alter_silent_lim[i]),
		 .o_wg_driver_clk_freq		(clk_freq[i]),
		 .o_wg_driver_in_wave		(out_wave_val[i]),
		 .o_wg_driver_elec_no		(elec_no[i]),
		 .o_wg_driver_isel		(o_isel[i]),
		 .o_wg_driver_sw_config		(w_sw_config_reg[i]),
		 .o_mult_elec			(w_mult_elec[i]),
		 .o_wg_driver_interrupt		(w_interrupt[i])
	);
*/
end

//assign o_driver_enable = 	|w_enable;
assign o_wg_driver_interrupt = 	|w_interrupt;
//assign o_pready = 		|pready;
//assign o_pslverr = 		|pslverr;

//assign o_elec_no = elec_no[ELEC_NO_REGS_BLK];

//wire w_mult_elec_or = |w_mult_elec;

reg [ELEC_NO-1:0] w_source_or;

assign w_source_or[0] = |w_source[0];

genvar gidx;
generate
for (gidx=1; gidx < ELEC_NO; gidx++) begin
	always_comb begin
		if (|w_source_or[gidx-1:0])
			w_source_or[gidx] = 0;
		else
			w_source_or[gidx] = |w_source[gidx];
	end
end
endgenerate

generate
for (gidx=0; gidx < ELEC_NO; gidx++) begin //8 switches
	always_comb begin
		o_sw[gidx] = 2'b00;
		for (integer idxi = 0; idxi < ELEC_NO; idxi = idxi+1) begin
			if (w_sw_config_reg[idxi][gidx] == 1'b1) begin
				o_sw[gidx] = (w_source[idxi]==2'b00)?2'b00:(2'b11-w_source[idxi]);//if source a (1) is on, turn on switch b (2), if source b (2) is on, turn on switch a (1), if no sources are on (0), no switches are on (0)
			end
		end
	end
end
endgenerate
	

//TODO: make sure this is wired (combinational) after synthesis otherwise too many registers will be wasted
always_comb begin
	for (integer idx = 0; idx < ELEC_NO; idx = idx+1) begin
		if (w_mult_elec[idx]) begin
			o_out_wave_val[idx] = out_wave_val[idx];
			o_source[idx] = w_source[idx];
			o_driver_sel[idx] = 1'b1;
		end
		else if(w_source_or[idx]) begin //use the slowest frequency (smallest index) first for output; that is; slowest frequencies get priority to access the electrodes
			if (idx==0) begin
				o_out_wave_val[0] = out_wave_val[idx];
				o_source[0] = w_source[idx];
			end
			else begin
				o_out_wave_val[0] = out_wave_val[idx];
				o_source[0] = w_source[idx];
				o_out_wave_val[idx] = 0;
				o_source[idx] = 0;
			end
			o_driver_sel[idx] = 1'b1;//1'b1 << idx; 
		end
		else begin //if no output was active
			o_out_wave_val[idx] = 0;
			o_driver_sel[idx] = 0;
			o_source[idx] = 0;
		end
	end
end

//always_comb begin
//	o_prdata = 0;
//	for (integer idx = 0; idx < ELEC_NO; idx = idx+1) begin
//		if(drv_sel[idx]) begin
//			o_prdata = prdata[idx];
//		end
//	end
//end

endmodule
