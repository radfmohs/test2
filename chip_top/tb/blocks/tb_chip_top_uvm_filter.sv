wire [(20-1):0] notch_coeffs [9:0][18:0];        //[65536Hz - 128Hz] [coeff_18 : coeff_0]
wire [(18-1):0] lpf_coeffs [13:0][6:0][31:0];   //[262144Hz - 32Hz] [Fpass=Fs/10  : Fpass=Fs/4] [coeff_31 : coeff_0]
wire [(24-1):0] hpf_coeffs [13:0][5:0];         //[262144Hz - 32Hz] [10, 5, 2, 1, 0.5, 0.2]Hz -> Fc


`include "blocks/notch_coeffs_list.svh"
`include "blocks/lpf_coeffs_list.svh"
`include "blocks/hpf_coeffs_list.svh"



assign dut_vif.notch_clk  = `IMEAS_WRAPPER_TOP.notch_clk;
assign dut_vif.lpf_clk  = `IMEAS_WRAPPER_TOP.lpf_clk;
assign dut_vif.hpf_clk  = `IMEAS_WRAPPER_TOP.hpf_clk;

genvar i;
generate
for (i = 0; i < `FILTER_NUM; i = i + 1) begin
  always@(posedge dut_vif.sys_clk)begin
     @(posedge imeas_vif.chdata_en[i]);

     // check IMEAS output = LPF input
     if(`IMEAS_WRAPPER_TOP.genblk1[i].u_filter_wrapper.chdata != `IMEAS_WRAPPER_TOP.genblk1[i].u_filter_wrapper.u_filter_fir_lpf.filter_in)
      `nnc_error("SOC_TEST",$sformatf("Connection MISMATCH in FILTER_NUM =%0d Imeas output=%0h and LPF input= %0h,",i,`IMEAS_WRAPPER_TOP.genblk1[i].u_filter_wrapper.chdata,`IMEAS_WRAPPER_TOP.genblk1[i].u_filter_wrapper.u_filter_fir_lpf.filter_in));

     // check LPF output = NOTCH input
     if(`IMEAS_WRAPPER_TOP.genblk1[i].u_filter_wrapper.u_filter_fir_lpf.filter_out != `IMEAS_WRAPPER_TOP.genblk1[i].u_filter_wrapper.u_notch_filter.filter_in)
      `nnc_error("SOC_TEST",$sformatf("Connection MISMATCH in FILTER_NUM =%0d LPF output=%0h and Notch input= %0h,",i,`IMEAS_WRAPPER_TOP.genblk1[i].u_filter_wrapper.u_filter_fir_lpf.filter_out,`IMEAS_WRAPPER_TOP.genblk1[i].u_filter_wrapper.u_notch_filter.filter_in));

     // check NOTCH output = HPF input
     if(`IMEAS_WRAPPER_TOP.genblk1[i].u_filter_wrapper.u_notch_filter.filter_out != `IMEAS_WRAPPER_TOP.genblk1[i].u_filter_wrapper.U_filter_iir_hpf.filter_in)
      `nnc_error("SOC_TEST",$sformatf("Connection MISMATCH in FILTER_NUM =%0d Notch output=%0h and LPF input= %0h,",i,`IMEAS_WRAPPER_TOP.genblk1[i].u_filter_wrapper.u_notch_filter.filter_out,`IMEAS_WRAPPER_TOP.genblk1[i].u_filter_wrapper.U_filter_iir_hpf.filter_in));
    
      //`nnc_info("SOC_TEST",$sformatf("MATCH"),UVM_LOW);
  end
end
endgenerate
