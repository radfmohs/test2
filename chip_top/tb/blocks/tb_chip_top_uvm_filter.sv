wire [(20-1):0] notch_coeffs [9:0][13:0];        //[65536Hz - 128Hz] [coeff_18 : coeff_0]
wire [(18-1):0] lpf_coeffs [13:0][6:0][27:0];   //[262144Hz - 32Hz] [Fpass=Fs/10  : Fpass=Fs/4] [coeff_27 : coeff_0]
wire [(24-1):0] hpf_coeffs [13:0][5:0];         //[262144Hz - 32Hz] [10, 5, 2, 1, 0.5, 0.2]Hz -> Fc


`include "blocks/notch_coeffs_list.svh"
`include "blocks/lpf_coeffs_list.svh"
`include "blocks/hpf_coeffs_list.svh"

`ifdef BEHAVIORAL
assign dut_vif.notch_clk  = `IMEAS_WRAPPER_TOP.notch_clk;
assign dut_vif.lpf_clk  = `IMEAS_WRAPPER_TOP.lpf_clk;
assign dut_vif.hpf_clk  = `IMEAS_WRAPPER_TOP.hpf_clk;
`endif

wire [23:0] local_imeas_chdata[`FILTER_NUM-1:0];
wire [23:0] hpf_filter_in[`FILTER_NUM-1:0];
wire [23:0] notch_filter_in[`FILTER_NUM-1:0];
wire [23:0] hpf_filter_out[`FILTER_NUM-1:0];
wire [23:0] notch_filter_out[`FILTER_NUM-1:0];
wire [23:0] lpf_filter_in[`FILTER_NUM-1:0];

`ifdef BEHAVIORAL
genvar i;
generate
for (i = 0; i < `FILTER_NUM; i = i + 1) begin
  assign local_imeas_chdata[i] = `IMEAS_WRAPPER_TOP.genblk1[i].u_filter_wrapper.chdata;
  assign hpf_filter_in[i]      = `IMEAS_WRAPPER_TOP.genblk1[i].u_filter_wrapper.U_filter_iir_hpf.filter_in;
  assign hpf_filter_out[i]     = `IMEAS_WRAPPER_TOP.genblk1[i].u_filter_wrapper.U_filter_iir_hpf.filter_out;
  assign notch_filter_in[i]    = `IMEAS_WRAPPER_TOP.genblk1[i].u_filter_wrapper.u_notch_filter.filter_in;
  assign notch_filter_out[i]   = `IMEAS_WRAPPER_TOP.genblk1[i].u_filter_wrapper.u_notch_filter.filter_out;
  assign lpf_filter_in[i]      = `IMEAS_WRAPPER_TOP.genblk1[i].u_filter_wrapper.u_filter_fir_lpf.filter_in; 
end
endgenerate 
`else
/*
  assign local_imeas_chdata[0] = `IMEAS_WRAPPER_TOP.genblk1_0__u_filter_wrapper.chdata;
  assign hpf_filter_in[0]      = `IMEAS_WRAPPER_TOP.genblk1_0__u_filter_wrapper.U_filter_iir_hpf.filter_in;
  assign hpf_filter_out[0]     = `IMEAS_WRAPPER_TOP.genblk1_0__u_filter_wrapper.U_filter_iir_hpf.filter_out;
  assign notch_filter_in[0]    = `IMEAS_WRAPPER_TOP.genblk1_0__u_filter_wrapper.u_notch_filter.filter_in;
  assign notch_filter_out[0]   = `IMEAS_WRAPPER_TOP.genblk1_0__u_filter_wrapper.u_notch_filter.filter_out;
  assign lpf_filter_in[0]      = `IMEAS_WRAPPER_TOP.genblk1_0__u_filter_wrapper.u_filter_fir_lpf.filter_in;

  assign local_imeas_chdata[1] = `IMEAS_WRAPPER_TOP.genblk1_1__u_filter_wrapper.chdata;
  assign hpf_filter_in[1]      = `IMEAS_WRAPPER_TOP.genblk1_1__u_filter_wrapper.U_filter_iir_hpf.filter_in;
  assign hpf_filter_out[1]     = `IMEAS_WRAPPER_TOP.genblk1_1__u_filter_wrapper.U_filter_iir_hpf.filter_out;
  assign notch_filter_in[1]    = `IMEAS_WRAPPER_TOP.genblk1_1__u_filter_wrapper.u_notch_filter.filter_in;
  assign notch_filter_out[1]   = `IMEAS_WRAPPER_TOP.genblk1_1__u_filter_wrapper.u_notch_filter.filter_out;
  assign lpf_filter_in[1]      = `IMEAS_WRAPPER_TOP.genblk1_1__u_filter_wrapper.u_filter_fir_lpf.filter_in;

  assign local_imeas_chdata[2] = `IMEAS_WRAPPER_TOP.genblk1_2__u_filter_wrapper.chdata;
  assign hpf_filter_in[2]      = `IMEAS_WRAPPER_TOP.genblk1_2__u_filter_wrapper.U_filter_iir_hpf.filter_in;
  assign hpf_filter_out[2]     = `IMEAS_WRAPPER_TOP.genblk1_2__u_filter_wrapper.U_filter_iir_hpf.filter_out;
  assign notch_filter_in[2]    = `IMEAS_WRAPPER_TOP.genblk1_2__u_filter_wrapper.u_notch_filter.filter_in;
  assign notch_filter_out[2]   = `IMEAS_WRAPPER_TOP.genblk1_2__u_filter_wrapper.u_notch_filter.filter_out;
  assign lpf_filter_in[2]      = `IMEAS_WRAPPER_TOP.genblk1_2__u_filter_wrapper.u_filter_fir_lpf.filter_in;

  assign local_imeas_chdata[3] = `IMEAS_WRAPPER_TOP.genblk1_3__u_filter_wrapper.chdata;
  assign hpf_filter_in[3]      = `IMEAS_WRAPPER_TOP.genblk1_3__u_filter_wrapper.U_filter_iir_hpf.filter_in;
  assign hpf_filter_out[3]     = `IMEAS_WRAPPER_TOP.genblk1_3__u_filter_wrapper.U_filter_iir_hpf.filter_out;
  assign notch_filter_in[3]    = `IMEAS_WRAPPER_TOP.genblk1_3__u_filter_wrapper.u_notch_filter.filter_in;
  assign notch_filter_out[3]   = `IMEAS_WRAPPER_TOP.genblk1_3__u_filter_wrapper.u_notch_filter.filter_out;
  assign lpf_filter_in[3]      = `IMEAS_WRAPPER_TOP.genblk1_3__u_filter_wrapper.u_filter_fir_lpf.filter_in;

  assign local_imeas_chdata[4] = `IMEAS_WRAPPER_TOP.genblk1_4__u_filter_wrapper.chdata;
  assign hpf_filter_in[4]      = `IMEAS_WRAPPER_TOP.genblk1_4__u_filter_wrapper.U_filter_iir_hpf.filter_in;
  assign hpf_filter_out[4]     = `IMEAS_WRAPPER_TOP.genblk1_4__u_filter_wrapper.U_filter_iir_hpf.filter_out;
  assign notch_filter_in[4]    = `IMEAS_WRAPPER_TOP.genblk1_4__u_filter_wrapper.u_notch_filter.filter_in;
  assign notch_filter_out[4]   = `IMEAS_WRAPPER_TOP.genblk1_4__u_filter_wrapper.u_notch_filter.filter_out;
  assign lpf_filter_in[4]      = `IMEAS_WRAPPER_TOP.genblk1_4__u_filter_wrapper.u_filter_fir_lpf.filter_in;

  assign local_imeas_chdata[5] = `IMEAS_WRAPPER_TOP.genblk1_5__u_filter_wrapper.chdata;
  assign hpf_filter_in[5]      = `IMEAS_WRAPPER_TOP.genblk1_5__u_filter_wrapper.U_filter_iir_hpf.filter_in;
  assign hpf_filter_out[5]     = `IMEAS_WRAPPER_TOP.genblk1_5__u_filter_wrapper.U_filter_iir_hpf.filter_out;
  assign notch_filter_in[5]    = `IMEAS_WRAPPER_TOP.genblk1_5__u_filter_wrapper.u_notch_filter.filter_in;
  assign notch_filter_out[5]   = `IMEAS_WRAPPER_TOP.genblk1_5__u_filter_wrapper.u_notch_filter.filter_out;
  assign lpf_filter_in[5]      = `IMEAS_WRAPPER_TOP.genblk1_5__u_filter_wrapper.u_filter_fir_lpf.filter_in;

  assign local_imeas_chdata[6] = `IMEAS_WRAPPER_TOP.genblk1_6__u_filter_wrapper.chdata;
  assign hpf_filter_in[6]      = `IMEAS_WRAPPER_TOP.genblk1_6__u_filter_wrapper.U_filter_iir_hpf.filter_in;
  assign hpf_filter_out[6]     = `IMEAS_WRAPPER_TOP.genblk1_6__u_filter_wrapper.U_filter_iir_hpf.filter_out;
  assign notch_filter_in[6]    = `IMEAS_WRAPPER_TOP.genblk1_6__u_filter_wrapper.u_notch_filter.filter_in;
  assign notch_filter_out[6]   = `IMEAS_WRAPPER_TOP.genblk1_6__u_filter_wrapper.u_notch_filter.filter_out;
  assign lpf_filter_in[6]      = `IMEAS_WRAPPER_TOP.genblk1_6__u_filter_wrapper.u_filter_fir_lpf.filter_in;

  assign local_imeas_chdata[0] = `IMEAS_WRAPPER_TOP.genblk1_7__u_filter_wrapper.chdata;
  assign hpf_filter_in[7]      = `IMEAS_WRAPPER_TOP.genblk1_7__u_filter_wrapper.U_filter_iir_hpf.filter_in;
  assign hpf_filter_out[7]     = `IMEAS_WRAPPER_TOP.genblk1_7__u_filter_wrapper.U_filter_iir_hpf.filter_out;
  assign notch_filter_in[7]    = `IMEAS_WRAPPER_TOP.genblk1_7__u_filter_wrapper.u_notch_filter.filter_in;
  assign notch_filter_out[7]   = `IMEAS_WRAPPER_TOP.genblk1_7__u_filter_wrapper.u_notch_filter.filter_out;
  assign lpf_filter_in[7]      = `IMEAS_WRAPPER_TOP.genblk1_7__u_filter_wrapper.u_filter_fir_lpf.filter_in;

  assign local_imeas_chdata[8] = `IMEAS_WRAPPER_TOP.genblk1_8__u_filter_wrapper.chdata;
  assign hpf_filter_in[8]      = `IMEAS_WRAPPER_TOP.genblk1_8__u_filter_wrapper.U_filter_iir_hpf.filter_in;
  assign hpf_filter_out[8]     = `IMEAS_WRAPPER_TOP.genblk1_8__u_filter_wrapper.U_filter_iir_hpf.filter_out;
  assign notch_filter_in[8]    = `IMEAS_WRAPPER_TOP.genblk1_8__u_filter_wrapper.u_notch_filter.filter_in;
  assign notch_filter_out[8]   = `IMEAS_WRAPPER_TOP.genblk1_8__u_filter_wrapper.u_notch_filter.filter_out;
  assign lpf_filter_in[8]      = `IMEAS_WRAPPER_TOP.genblk1_8__u_filter_wrapper.u_filter_fir_lpf.filter_in;

  assign local_imeas_chdata[9] = `IMEAS_WRAPPER_TOP.genblk1_9__u_filter_wrapper.chdata;
  assign hpf_filter_in[9]      = `IMEAS_WRAPPER_TOP.genblk1_9__u_filter_wrapper.U_filter_iir_hpf.filter_in;
  assign hpf_filter_out[9]     = `IMEAS_WRAPPER_TOP.genblk1_9__u_filter_wrapper.U_filter_iir_hpf.filter_out;
  assign notch_filter_in[9]    = `IMEAS_WRAPPER_TOP.genblk1_9__u_filter_wrapper.u_notch_filter.filter_in;
  assign notch_filter_out[9]   = `IMEAS_WRAPPER_TOP.genblk1_9__u_filter_wrapper.u_notch_filter.filter_out;
  assign lpf_filter_in[9]      = `IMEAS_WRAPPER_TOP.genblk1_9__u_filter_wrapper.u_filter_fir_lpf.filter_in;

  assign local_imeas_chdata[10] = `IMEAS_WRAPPER_TOP.genblk1_10__u_filter_wrapper.chdata;
  assign hpf_filter_in[10]      = `IMEAS_WRAPPER_TOP.genblk1_10__u_filter_wrapper.U_filter_iir_hpf.filter_in;
  assign hpf_filter_out[10]     = `IMEAS_WRAPPER_TOP.genblk1_10__u_filter_wrapper.U_filter_iir_hpf.filter_out;
  assign notch_filter_in[10]    = `IMEAS_WRAPPER_TOP.genblk1_10__u_filter_wrapper.u_notch_filter.filter_in;
  assign notch_filter_out[10]   = `IMEAS_WRAPPER_TOP.genblk1_10__u_filter_wrapper.u_notch_filter.filter_out;
  assign lpf_filter_in[10]      = `IMEAS_WRAPPER_TOP.genblk1_10__u_filter_wrapper.u_filter_fir_lpf.filter_in;

  assign local_imeas_chdata[11] = `IMEAS_WRAPPER_TOP.genblk1_11__u_filter_wrapper.chdata;
  assign hpf_filter_in[11]      = `IMEAS_WRAPPER_TOP.genblk1_11__u_filter_wrapper.U_filter_iir_hpf.filter_in;
  assign hpf_filter_out[11]     = `IMEAS_WRAPPER_TOP.genblk1_11__u_filter_wrapper.U_filter_iir_hpf.filter_out;
  assign notch_filter_in[11]    = `IMEAS_WRAPPER_TOP.genblk1_11__u_filter_wrapper.u_notch_filter.filter_in;
  assign notch_filter_out[11]   = `IMEAS_WRAPPER_TOP.genblk1_11__u_filter_wrapper.u_notch_filter.filter_out;
  assign lpf_filter_in[11]      = `IMEAS_WRAPPER_TOP.genblk1_11__u_filter_wrapper.u_filter_fir_lpf.filter_in;

  assign local_imeas_chdata[12] = `IMEAS_WRAPPER_TOP.genblk1_12__u_filter_wrapper.chdata;
  assign hpf_filter_in[12]      = `IMEAS_WRAPPER_TOP.genblk1_12__u_filter_wrapper.U_filter_iir_hpf.filter_in;
  assign hpf_filter_out[12]     = `IMEAS_WRAPPER_TOP.genblk1_12__u_filter_wrapper.U_filter_iir_hpf.filter_out;
  assign notch_filter_in[12]    = `IMEAS_WRAPPER_TOP.genblk1_12__u_filter_wrapper.u_notch_filter.filter_in;
  assign notch_filter_out[12]   = `IMEAS_WRAPPER_TOP.genblk1_12__u_filter_wrapper.u_notch_filter.filter_out;
  assign lpf_filter_in[12]      = `IMEAS_WRAPPER_TOP.genblk1_12__u_filter_wrapper.u_filter_fir_lpf.filter_in;

  assign local_imeas_chdata[13] = `IMEAS_WRAPPER_TOP.genblk1_13__u_filter_wrapper.chdata;
  assign hpf_filter_in[13]      = `IMEAS_WRAPPER_TOP.genblk1_13__u_filter_wrapper.U_filter_iir_hpf.filter_in;
  assign hpf_filter_out[13]     = `IMEAS_WRAPPER_TOP.genblk1_13__u_filter_wrapper.U_filter_iir_hpf.filter_out;
  assign notch_filter_in[13]    = `IMEAS_WRAPPER_TOP.genblk1_13__u_filter_wrapper.u_notch_filter.filter_in;
  assign notch_filter_out[13]   = `IMEAS_WRAPPER_TOP.genblk1_13__u_filter_wrapper.u_notch_filter.filter_out;
  assign lpf_filter_in[13]      = `IMEAS_WRAPPER_TOP.genblk1_13__u_filter_wrapper.u_filter_fir_lpf.filter_in;

  assign local_imeas_chdata[14] = `IMEAS_WRAPPER_TOP.genblk1_14__u_filter_wrapper.chdata;
  assign hpf_filter_in[14]      = `IMEAS_WRAPPER_TOP.genblk1_14__u_filter_wrapper.U_filter_iir_hpf.filter_in;
  assign hpf_filter_out[14]     = `IMEAS_WRAPPER_TOP.genblk1_14__u_filter_wrapper.U_filter_iir_hpf.filter_out;
  assign notch_filter_in[14]    = `IMEAS_WRAPPER_TOP.genblk1_14__u_filter_wrapper.u_notch_filter.filter_in;
  assign notch_filter_out[14]   = `IMEAS_WRAPPER_TOP.genblk1_14__u_filter_wrapper.u_notch_filter.filter_out;
  assign lpf_filter_in[14]      = `IMEAS_WRAPPER_TOP.genblk1_14__u_filter_wrapper.u_filter_fir_lpf.filter_in;

  assign local_imeas_chdata[15] = `IMEAS_WRAPPER_TOP.genblk1_15__u_filter_wrapper.chdata;
  assign hpf_filter_in[15]      = `IMEAS_WRAPPER_TOP.genblk1_15__u_filter_wrapper.U_filter_iir_hpf.filter_in;
  assign hpf_filter_out[15]     = `IMEAS_WRAPPER_TOP.genblk1_15__u_filter_wrapper.U_filter_iir_hpf.filter_out;
  assign notch_filter_in[15]    = `IMEAS_WRAPPER_TOP.genblk1_15__u_filter_wrapper.u_notch_filter.filter_in;
  assign notch_filter_out[15]   = `IMEAS_WRAPPER_TOP.genblk1_15__u_filter_wrapper.u_notch_filter.filter_out;
  assign lpf_filter_in[15]      = `IMEAS_WRAPPER_TOP.genblk1_15__u_filter_wrapper.u_filter_fir_lpf.filter_in;
*/
`endif

`ifdef BEHAVIORAL
genvar i;
generate
for (i = 0; i < `FILTER_NUM; i = i + 1) begin
  always@(posedge dut_vif.sys_clk)begin
     @(posedge imeas_vif.chdata_en[i]);

     //##########################  HPF -> NOTCH -> LPF ##########################

     // check IMEAS output = HPF input
     if(local_imeas_chdata[i] != hpf_filter_in[i])
      `nnc_error("SOC_TEST",$sformatf("Connection MISMATCH in FILTER_NUM =%0d Imeas output=%0h and HPF input= %0h,", i, local_imeas_chdata[i], hpf_filter_in[i]));

     // check HPF output = NOTCH input
     if(hpf_filter_out[i] != notch_filter_in[i])
      `nnc_error("SOC_TEST",$sformatf("Connection MISMATCH in FILTER_NUM =%0d HPF output=%0h and LPF input= %0h,", i, hpf_filter_out[i], notch_filter_in[i]));

     // check NOTCH output = LPF input
     if(notch_filter_out[i] != lpf_filter_in[i])
      `nnc_error("SOC_TEST",$sformatf("Connection MISMATCH in FILTER_NUM =%0d LPF output=%0h and NOTCH input= %0h,", i, notch_filter_out[i], lpf_filter_in[i]));

  end
end
endgenerate
`endif
