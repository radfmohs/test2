wire [(20-1):0] notch_coeffs [9:0][18:0];        //[65536Hz - 128Hz] [coeff_18 : coeff_0]
wire [(18-1):0] lpf_coeffs [13:0][6:0][31:0];   //[262144Hz - 32Hz] [Fpass=Fs/10  : Fpass=Fs/4] [coeff_31 : coeff_0]
wire [(24-1):0] hpf_coeffs [13:0][5:0];         //[262144Hz - 32Hz] [10, 5, 2, 1, 0.5, 0.2]Hz -> Fc


`include "blocks/notch_coeffs_list.svh"
`include "blocks/lpf_coeffs_list.svh"
`include "blocks/hpf_coeffs_list.svh"



assign dut_vif.notch_clk  = `FILTER_WRAPPER_TOP.notch_clk;
assign dut_vif.lpf_clk  = `FILTER_WRAPPER_TOP.lpf_clk;
assign dut_vif.hpf_clk  = `FILTER_WRAPPER_TOP.hpf_clk;
