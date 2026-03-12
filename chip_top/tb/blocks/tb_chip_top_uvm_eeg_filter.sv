/*--------------------------------------------------------------------------------------*/
// Copyright 2021 Nanochap, Inc.
// All Rights Reserved Worldwide
// --------------------------------------------------------------------------------------
// Project      : Nanochap_ENS2
// File         : tb_chip_top_uvm_eeg_filter.sv
// Description  : IMEAS TB 
// Designer     : Ophina Correya
// Date         : 05/09/2025
// Revision     : 0.1
/*--------------------------------------------------------------------------------------*/

// --------------------------------------------------------------------------------
// IMEAS REF MODEL
// --------------------------------------------------------------------------------
wire [`FILTER_DATA_WIDTH-1:0] exp_cic_out[`FILTER_NUM-1:0];
wire [`FILTER_DATA_WIDTH-1:0] exp_cic_out_dev2[`FILTER_NUM-1:0];
wire [`FILTER_NUM-1:0]        offset;
wire [`FILTER_NUM-1:0]        offset_dev2;
wire [`FILTER_NUM-1:0]        exp_cic_out_valid;
wire [`FILTER_NUM-1:0]        exp_cic_out_valid_dev2;
wire                          sdm_adc_clk;
wire                          sdm_adc_rst;
wire                          sdm_adc_clk_dev2;
wire                          sdm_adc_rst_dev2;

genvar i;
generate
 for (i = 0; i < `FILTER_NUM; i = i + 1) begin
   buf #(1) (offset[i], `CLK_CTRL_TOP.u_cmsdk_clock_gate_iadc_clk[i].enable);
   buf #(1) (offset_dev2[i], `CLK_CTRL_TOP_S1.u_cmsdk_clock_gate_iadc_clk[i].enable);
 end
endgenerate

assign sdm_adc_clk = (dut_vif.imeas_adc_inv === 1'b1) ? ~`ANA_TOP.D2A_SDM_CLK : `ANA_TOP.D2A_SDM_CLK;
assign sdm_adc_clk_dev2 = (dut_vif.imeas_adc_inv === 1'b1) ? ~`ANA_TOP_S1.D2A_SDM_CLK : `ANA_TOP_S1.D2A_SDM_CLK;
assign sdm_adc_rst = `RST_CTRL_TOP.cic_rst_n;
assign sdm_adc_rst_dev2 = `RST_CTRL_TOP_S1.cic_rst_n;

// --------------------------------------------------------------------------------
// IMEAS REF MODEL
// --------------------------------------------------------------------------------
// =====================
// Chip DEV1
// =====================
test_SINC_4_24B #(
 .file_adc("../../../verification/models/analog/imeas/stimulus/dB0.dat"),
 .file_adc_out("./ADC0_OUT.txt")
 )
  u_imeas_ch0_refmodel(
	.POR(`ANA_TOP.A2D_POR_DVDD),
	.ADC_RST(sdm_adc_rst),
        .ADC_CLK(sdm_adc_clk),
	.ADC_IN(`ANA_TOP.A2D_SDM_OUT0),
        .CH_EN(1'b1),
	.OSR(`IMEAS_WRAPPER_TOP.DR),
	.OFFSET(offset[0]),
	.FORMAT(`IMEAS_WRAPPER_TOP.imeas_reg_0[3:2]),
	.IA(exp_cic_out[0]),
	.IA_valid(exp_cic_out_valid[0])
  );

test_SINC_4_24B #(
 .file_adc("../../../verification/models/analog/imeas/stimulus/dB1.dat"),
 .file_adc_out("./ADC1_OUT.txt")
 )
  u_imeas_ch1_refmodel(
	.POR(`ANA_TOP.A2D_POR_DVDD),
	.ADC_RST(sdm_adc_rst),
        .ADC_CLK(sdm_adc_clk),
	.ADC_IN(`ANA_TOP.A2D_SDM_OUT1),
        .CH_EN(1'b1),
	.OSR(`IMEAS_WRAPPER_TOP.DR),
	.OFFSET(offset[1]),
	.FORMAT(`IMEAS_WRAPPER_TOP.imeas_reg_0[3:2]),
	.IA(exp_cic_out[1]),
	.IA_valid(exp_cic_out_valid[1])
  );

test_SINC_4_24B #(
 .file_adc("../../../verification/models/analog/imeas/stimulus/dB2.dat"),
 .file_adc_out("./ADC2_OUT.txt")
 )
  u_imeas_ch2_refmodel(
	.POR(`ANA_TOP.A2D_POR_DVDD),
        .ADC_CLK(sdm_adc_clk),
	.ADC_RST(sdm_adc_rst),
	.ADC_IN(`ANA_TOP.A2D_SDM_OUT2),
        .CH_EN(1'b1),
	.OSR(`IMEAS_WRAPPER_TOP.DR),
	.OFFSET(offset[2]),
	.FORMAT(`IMEAS_WRAPPER_TOP.imeas_reg_0[3:2]),
	.IA(exp_cic_out[2]),
	.IA_valid(exp_cic_out_valid[2])
  );

test_SINC_4_24B #(
 .file_adc("../../../verification/models/analog/imeas/stimulus/dB3.dat"),
 .file_adc_out("./ADC3_OUT.txt")
 )
  u_imeas_ch3_refmodel(
	.POR(`ANA_TOP.A2D_POR_DVDD),
        .ADC_CLK(sdm_adc_clk),
	.ADC_RST(sdm_adc_rst),
	.ADC_IN(`ANA_TOP.A2D_SDM_OUT3),
        .CH_EN(1'b1),
	.OSR(`IMEAS_WRAPPER_TOP.DR),
	.OFFSET(offset[3]),
	.FORMAT(`IMEAS_WRAPPER_TOP.imeas_reg_0[3:2]),
	.IA(exp_cic_out[3]),
	.IA_valid(exp_cic_out_valid[3])
  );

test_SINC_4_24B #(
 .file_adc("../../../verification/models/analog/imeas/stimulus/dB4.dat"),
 .file_adc_out("./ADC4_OUT.txt")
 )
  u_imeas_ch4_refmodel(
	.POR(`ANA_TOP.A2D_POR_DVDD),
        .ADC_CLK(sdm_adc_clk),
	.ADC_RST(sdm_adc_rst),
	.ADC_IN(`ANA_TOP.A2D_SDM_OUT4),
        .CH_EN(1'b1),
	.OSR(`IMEAS_WRAPPER_TOP.DR),
	.OFFSET(offset[4]),
	.FORMAT(`IMEAS_WRAPPER_TOP.imeas_reg_0[3:2]),
	.IA(exp_cic_out[4]),
	.IA_valid(exp_cic_out_valid[4])
  );

test_SINC_4_24B #(
 .file_adc("../../../verification/models/analog/imeas/stimulus/dB5.dat"),
 .file_adc_out("./ADC5_OUT.txt")
 )
  u_imeas_ch5_refmodel(
	.POR(`ANA_TOP.A2D_POR_DVDD),
        .ADC_CLK(sdm_adc_clk),
	.ADC_RST(sdm_adc_rst),
	.ADC_IN(`ANA_TOP.A2D_SDM_OUT5),
        .CH_EN(1'b1),
	.OSR(`IMEAS_WRAPPER_TOP.DR),
	.OFFSET(offset[5]),
	.FORMAT(`IMEAS_WRAPPER_TOP.imeas_reg_0[3:2]),
	.IA(exp_cic_out[5]),
	.IA_valid(exp_cic_out_valid[5])
  );

test_SINC_4_24B #(
 .file_adc("../../../verification/models/analog/imeas/stimulus/dB6.dat"),
 .file_adc_out("./ADC6_OUT.txt")
 )
  u_imeas_ch6_refmodel(
	.POR(`ANA_TOP.A2D_POR_DVDD),
        .ADC_CLK(sdm_adc_clk),
	.ADC_RST(sdm_adc_rst),
	.ADC_IN(`ANA_TOP.A2D_SDM_OUT6),
        .CH_EN(1'b1),
	.OSR(`IMEAS_WRAPPER_TOP.DR),
	.OFFSET(offset[6]),
	.FORMAT(`IMEAS_WRAPPER_TOP.imeas_reg_0[3:2]),
	.IA(exp_cic_out[6]),
	.IA_valid(exp_cic_out_valid[6])
  );

test_SINC_4_24B #(
 .file_adc("../../../verification/models/analog/imeas/stimulus/dB7.dat"),
 .file_adc_out("./ADC7_OUT.txt")
 )
  u_imeas_ch7_refmodel(
	.POR(`ANA_TOP.A2D_POR_DVDD),
        .ADC_CLK(sdm_adc_clk),
	.ADC_RST(sdm_adc_rst),
	.ADC_IN(`ANA_TOP.A2D_SDM_OUT7),
        .CH_EN(1'b1),
	.OSR(`IMEAS_WRAPPER_TOP.DR),
	.OFFSET(offset[7]),
	.FORMAT(`IMEAS_WRAPPER_TOP.imeas_reg_0[3:2]),
	.IA(exp_cic_out[7]),
	.IA_valid(exp_cic_out_valid[7])
  );

test_SINC_4_24B #(
 .file_adc("../../../verification/models/analog/imeas/stimulus/dB8.dat"),
 .file_adc_out("./ADC8_OUT.txt")
 )
  u_imeas_ch8_refmodel(
	.POR(`ANA_TOP.A2D_POR_DVDD),
        .ADC_CLK(sdm_adc_clk),
	.ADC_RST(sdm_adc_rst),
	.ADC_IN(`ANA_TOP.A2D_SDM_OUT8),
        .CH_EN(1'b1),
	.OSR(`IMEAS_WRAPPER_TOP.DR),
	.OFFSET(offset[8]),
	.FORMAT(`IMEAS_WRAPPER_TOP.imeas_reg_0[3:2]),
	.IA(exp_cic_out[8]),
	.IA_valid(exp_cic_out_valid[8])
  );

test_SINC_4_24B #(
 .file_adc("../../../verification/models/analog/imeas/stimulus/dB10.dat"),
 .file_adc_out("./ADC9_OUT.txt")
 )
  u_imeas_ch9_refmodel(
	.POR(`ANA_TOP.A2D_POR_DVDD),
        .ADC_CLK(sdm_adc_clk),
	.ADC_RST(sdm_adc_rst),
	.ADC_IN(`ANA_TOP.A2D_SDM_OUT9),
        .CH_EN(1'b1),
	.OSR(`IMEAS_WRAPPER_TOP.DR),
	.OFFSET(offset[9]),
	.FORMAT(`IMEAS_WRAPPER_TOP.imeas_reg_0[3:2]),
	.IA(exp_cic_out[9]),
	.IA_valid(exp_cic_out_valid[9])
  );

test_SINC_4_24B #(
 .file_adc("../../../verification/models/analog/imeas/stimulus/dB20.dat"),
 .file_adc_out("./ADC10_OUT.txt")
 )
  u_imeas_ch10_refmodel(
	.POR(`ANA_TOP.A2D_POR_DVDD),
        .ADC_CLK(sdm_adc_clk),
	.ADC_RST(sdm_adc_rst),
	.ADC_IN(`ANA_TOP.A2D_SDM_OUT10),
        .CH_EN(1'b1),
	.OSR(`IMEAS_WRAPPER_TOP.DR),
	.OFFSET(offset[10]),
	.FORMAT(`IMEAS_WRAPPER_TOP.imeas_reg_0[3:2]),
	.IA(exp_cic_out[10]),
	.IA_valid(exp_cic_out_valid[10])
  );

test_SINC_4_24B #(
 .file_adc("../../../verification/models/analog/imeas/stimulus/dB30.dat"),
 .file_adc_out("./ADC11_OUT.txt")
 )
  u_imeas_ch11_refmodel(
	.POR(`ANA_TOP.A2D_POR_DVDD),
        .ADC_CLK(sdm_adc_clk),
	.ADC_RST(sdm_adc_rst),
	.ADC_IN(`ANA_TOP.A2D_SDM_OUT11),
        .CH_EN(1'b1),
	.OSR(`IMEAS_WRAPPER_TOP.DR),
	.OFFSET(offset[11]),
	.FORMAT(`IMEAS_WRAPPER_TOP.imeas_reg_0[3:2]),
	.IA(exp_cic_out[11]),
	.IA_valid(exp_cic_out_valid[11])
  );

test_SINC_4_24B #(
 .file_adc("../../../verification/models/analog/imeas/stimulus/dB40.dat"),
 .file_adc_out("./ADC12_OUT.txt")
 )
  u_imeas_ch12_refmodel(
	.POR(`ANA_TOP.A2D_POR_DVDD),
        .ADC_CLK(sdm_adc_clk),
	.ADC_RST(sdm_adc_rst),
	.ADC_IN(`ANA_TOP.A2D_SDM_OUT12),
        .CH_EN(1'b1),
	.OSR(`IMEAS_WRAPPER_TOP.DR),
	.OFFSET(offset[12]),
	.FORMAT(`IMEAS_WRAPPER_TOP.imeas_reg_0[3:2]),
	.IA(exp_cic_out[12]),
	.IA_valid(exp_cic_out_valid[12])
  );

test_SINC_4_24B #(
 .file_adc("../../../verification/models/analog/imeas/stimulus/dB50.dat"),
 .file_adc_out("./ADC13_OUT.txt")
 )
  u_imeas_ch13_refmodel(
	.POR(`ANA_TOP.A2D_POR_DVDD),
        .ADC_CLK(sdm_adc_clk),
	.ADC_RST(sdm_adc_rst),
	.ADC_IN(`ANA_TOP.A2D_SDM_OUT13),
        .CH_EN(1'b1),
	.OSR(`IMEAS_WRAPPER_TOP.DR),
	.OFFSET(offset[13]),
	.FORMAT(`IMEAS_WRAPPER_TOP.imeas_reg_0[3:2]),
	.IA(exp_cic_out[13]),
	.IA_valid(exp_cic_out_valid[13])
  );

test_SINC_4_24B #(
 .file_adc("../../../verification/models/analog/imeas/stimulus/dB60.dat"),
 .file_adc_out("./ADC14_OUT.txt")
 )
  u_imeas_ch14_refmodel(
	.POR(`ANA_TOP.A2D_POR_DVDD),
        .ADC_CLK(sdm_adc_clk),
	.ADC_RST(sdm_adc_rst),
	.ADC_IN(`ANA_TOP.A2D_SDM_OUT14),
        .CH_EN(1'b1),
	.OSR(`IMEAS_WRAPPER_TOP.DR),
	.OFFSET(offset[14]),
	.FORMAT(`IMEAS_WRAPPER_TOP.imeas_reg_0[3:2]),
	.IA(exp_cic_out[14]),
	.IA_valid(exp_cic_out_valid[14])
  );

test_SINC_4_24B #(
 .file_adc("../../../verification/models/analog/imeas/stimulus/dB70.dat"),
 .file_adc_out("./ADC15_OUT.txt")
 )
  u_imeas_ch15_refmodel(
	.POR(`ANA_TOP.A2D_POR_DVDD),
        .ADC_CLK(sdm_adc_clk),
	.ADC_RST(sdm_adc_rst),
	.ADC_IN(`ANA_TOP.A2D_SDM_OUT15),
        .CH_EN(1'b1),
	.OSR(`IMEAS_WRAPPER_TOP.DR),
	.OFFSET(offset[15]),
	.FORMAT(`IMEAS_WRAPPER_TOP.imeas_reg_0[3:2]),
	.IA(exp_cic_out[15]),
	.IA_valid(exp_cic_out_valid[15])
  );
// =====================
// Chip DEV2
// =====================
test_SINC_4_24B #(
 .file_adc("../../../verification/models/analog/imeas/stimulus/dB0.dat"),
 .file_adc_out("./ADC0_DEV2_OUT.txt")
 )
  u_imeas_ch0_refmodel_dev2(
	.POR(`ANA_TOP_S1.A2D_POR_DVDD),
        .ADC_CLK(sdm_adc_clk_dev2),
	.ADC_RST(sdm_adc_rst_dev2),
	.ADC_IN(`ANA_TOP_S1.A2D_SDM_OUT0),
        .CH_EN(1'b1),
	.OSR(`IMEAS_WRAPPER_TOP_S1.DR),
	.OFFSET(offset_dev2[0]),
	.FORMAT(`IMEAS_WRAPPER_TOP_S1.imeas_reg_0[3:2]),
	.IA(exp_cic_out_dev2[0]),
	.IA_valid(exp_cic_out_valid_dev2[0])
  );

test_SINC_4_24B #(
 .file_adc("../../../verification/models/analog/imeas/stimulus/dB1.dat"),
 .file_adc_out("./ADC1_DEV2_OUT.txt")
 )
  u_imeas_ch1_refmodel_dev2(
	.POR(`ANA_TOP_S1.A2D_POR_DVDD),
        .ADC_CLK(sdm_adc_clk_dev2),
	.ADC_RST(sdm_adc_rst_dev2),
	.ADC_IN(`ANA_TOP_S1.A2D_SDM_OUT1),
        .CH_EN(1'b1),
	.OSR(`IMEAS_WRAPPER_TOP_S1.DR),
	.OFFSET(offset_dev2[1]),
	.FORMAT(`IMEAS_WRAPPER_TOP_S1.imeas_reg_0[3:2]),
	.IA(exp_cic_out_dev2[1]),
	.IA_valid(exp_cic_out_valid_dev2[1])
  );

test_SINC_4_24B #(
 .file_adc("../../../verification/models/analog/imeas/stimulus/dB2.dat"),
 .file_adc_out("./ADC2_DEV2_OUT.txt")
 )
  u_imeas_ch2_refmodel_dev2(
	.POR(`ANA_TOP_S1.A2D_POR_DVDD),
        .ADC_CLK(sdm_adc_clk_dev2),
	.ADC_RST(sdm_adc_rst_dev2),
	.ADC_IN(`ANA_TOP_S1.A2D_SDM_OUT2),
        .CH_EN(1'b1),
	.OSR(`IMEAS_WRAPPER_TOP_S1.DR),
	.OFFSET(offset_dev2[2]),
	.FORMAT(`IMEAS_WRAPPER_TOP_S1.imeas_reg_0[3:2]),
	.IA(exp_cic_out_dev2[2]),
	.IA_valid(exp_cic_out_valid_dev2[2])
  );

test_SINC_4_24B #(
 .file_adc("../../../verification/models/analog/imeas/stimulus/dB3.dat"),
 .file_adc_out("./ADC3_DEV2_OUT.txt")
 )
  u_imeas_ch3_refmodel_dev2(
	.POR(`ANA_TOP_S1.A2D_POR_DVDD),
        .ADC_CLK(sdm_adc_clk_dev2),
	.ADC_RST(sdm_adc_rst_dev2),
	.ADC_IN(`ANA_TOP_S1.A2D_SDM_OUT3),
        .CH_EN(1'b1),
	.OSR(`IMEAS_WRAPPER_TOP_S1.DR),
	.OFFSET(offset_dev2[3]),
	.FORMAT(`IMEAS_WRAPPER_TOP_S1.imeas_reg_0[3:2]),
	.IA(exp_cic_out_dev2[3]),
	.IA_valid(exp_cic_out_valid_dev2[3])
  );

test_SINC_4_24B #(
 .file_adc("../../../verification/models/analog/imeas/stimulus/dB4.dat"),
 .file_adc_out("./ADC4_DEV2_OUT.txt")
 )
  u_imeas_ch4_refmodel_dev2(
	.POR(`ANA_TOP_S1.A2D_POR_DVDD),
        .ADC_CLK(sdm_adc_clk_dev2),
	.ADC_RST(sdm_adc_rst_dev2),
	.ADC_IN(`ANA_TOP_S1.A2D_SDM_OUT4),
        .CH_EN(1'b1),
	.OSR(`IMEAS_WRAPPER_TOP_S1.DR),
	.OFFSET(offset_dev2[4]),
	.FORMAT(`IMEAS_WRAPPER_TOP_S1.imeas_reg_0[3:2]),
	.IA(exp_cic_out_dev2[4]),
	.IA_valid(exp_cic_out_valid_dev2[4])
  );

test_SINC_4_24B #(
 .file_adc("../../../verification/models/analog/imeas/stimulus/dB5.dat"),
 .file_adc_out("./ADC5_DEV2_OUT.txt")
 )
  u_imeas_ch5_refmodel_dev2(
	.POR(`ANA_TOP_S1.A2D_POR_DVDD),
        .ADC_CLK(sdm_adc_clk_dev2),
	.ADC_RST(sdm_adc_rst_dev2),
	.ADC_IN(`ANA_TOP_S1.A2D_SDM_OUT5),
        .CH_EN(1'b1),
	.OSR(`IMEAS_WRAPPER_TOP_S1.DR),
	.OFFSET(offset_dev2[5]),
	.FORMAT(`IMEAS_WRAPPER_TOP_S1.imeas_reg_0[3:2]),
	.IA(exp_cic_out_dev2[5]),
	.IA_valid(exp_cic_out_valid_dev2[5])
  );

test_SINC_4_24B #(
 .file_adc("../../../verification/models/analog/imeas/stimulus/dB6.dat"),
 .file_adc_out("./ADC6_DEV2_OUT.txt")
 )
  u_imeas_ch6_refmodel_dev2(
	.POR(`ANA_TOP_S1.A2D_POR_DVDD),
        .ADC_CLK(sdm_adc_clk_dev2),
	.ADC_RST(sdm_adc_rst_dev2),
	.ADC_IN(`ANA_TOP_S1.A2D_SDM_OUT6),
        .CH_EN(1'b1),
	.OSR(`IMEAS_WRAPPER_TOP_S1.DR),
	.OFFSET(offset_dev2[6]),
	.FORMAT(`IMEAS_WRAPPER_TOP_S1.imeas_reg_0[3:2]),
	.IA(exp_cic_out_dev2[6]),
	.IA_valid(exp_cic_out_valid_dev2[6])
  );

test_SINC_4_24B #(
 .file_adc("../../../verification/models/analog/imeas/stimulus/dB7.dat"),
 .file_adc_out("./ADC7_DEV2_OUT.txt")
 )
  u_imeas_ch7_refmodel_dev2(
	.POR(`ANA_TOP_S1.A2D_POR_DVDD),
        .ADC_CLK(sdm_adc_clk_dev2),
	.ADC_RST(sdm_adc_rst_dev2),
	.ADC_IN(`ANA_TOP_S1.A2D_SDM_OUT7),
        .CH_EN(1'b1),
	.OSR(`IMEAS_WRAPPER_TOP_S1.DR),
	.OFFSET(offset_dev2[7]),
	.FORMAT(`IMEAS_WRAPPER_TOP_S1.imeas_reg_0[3:2]),
	.IA(exp_cic_out_dev2[7]),
	.IA_valid(exp_cic_out_valid_dev2[7])
  );

test_SINC_4_24B #(
 .file_adc("../../../verification/models/analog/imeas/stimulus/dB8.dat"),
 .file_adc_out("./ADC8_DEV2_OUT.txt")
 )
  u_imeas_ch8_refmodel_dev2(
	.POR(`ANA_TOP_S1.A2D_POR_DVDD),
        .ADC_CLK(sdm_adc_clk_dev2),
	.ADC_RST(sdm_adc_rst_dev2),
	.ADC_IN(`ANA_TOP_S1.A2D_SDM_OUT8),
        .CH_EN(1'b1),
	.OSR(`IMEAS_WRAPPER_TOP_S1.DR),
	.OFFSET(offset_dev2[8]),
	.FORMAT(`IMEAS_WRAPPER_TOP_S1.imeas_reg_0[3:2]),
	.IA(exp_cic_out_dev2[8]),
	.IA_valid(exp_cic_out_valid_dev2[8])
  );

test_SINC_4_24B #(
 .file_adc("../../../verification/models/analog/imeas/stimulus/dB10.dat"),
 .file_adc_out("./ADC9_DEV2_OUT.txt")
 )
  u_imeas_ch9_refmodel_dev2(
	.POR(`ANA_TOP.A2D_POR_DVDD),
        .ADC_CLK(sdm_adc_clk_dev2),
	.ADC_RST(sdm_adc_rst_dev2),
	.ADC_IN(`ANA_TOP_S1.A2D_SDM_OUT9),
        .CH_EN(1'b1),
	.OSR(`IMEAS_WRAPPER_TOP.DR),
	.OFFSET(offset_dev2[9]),
	.FORMAT(`IMEAS_WRAPPER_TOP.imeas_reg_0[3:2]),
	.IA(exp_cic_out_dev2[9]),
	.IA_valid(exp_cic_out_valid_dev2[9])
  );

test_SINC_4_24B #(
 .file_adc("../../../verification/models/analog/imeas/stimulus/dB20.dat"),
 .file_adc_out("./ADC10_DEV2_OUT.txt")
 )
  u_imeas_ch10_refmodel_dev2(
	.POR(`ANA_TOP.A2D_POR_DVDD),
        .ADC_CLK(sdm_adc_clk_dev2),
	.ADC_RST(sdm_adc_rst_dev2),
	.ADC_IN(`ANA_TOP_S1.A2D_SDM_OUT10),
        .CH_EN(1'b1),
	.OSR(`IMEAS_WRAPPER_TOP.DR),
	.OFFSET(offset_dev2[10]),
	.FORMAT(`IMEAS_WRAPPER_TOP.imeas_reg_0[3:2]),
	.IA(exp_cic_out_dev2[10]),
	.IA_valid(exp_cic_out_valid_dev2[10])
  );

test_SINC_4_24B #(
 .file_adc("../../../verification/models/analog/imeas/stimulus/dB30.dat"),
 .file_adc_out("./ADC11_DEV2_OUT.txt")
 )
  u_imeas_ch11_refmodel_dev2(
	.POR(`ANA_TOP.A2D_POR_DVDD),
        .ADC_CLK(sdm_adc_clk_dev2),
	.ADC_RST(sdm_adc_rst_dev2),
	.ADC_IN(`ANA_TOP_S1.A2D_SDM_OUT11),
        .CH_EN(1'b1),
	.OSR(`IMEAS_WRAPPER_TOP.DR),
	.OFFSET(offset_dev2[11]),
	.FORMAT(`IMEAS_WRAPPER_TOP.imeas_reg_0[3:2]),
	.IA(exp_cic_out_dev2[11]),
	.IA_valid(exp_cic_out_valid_dev2[11])
  );

test_SINC_4_24B #(
 .file_adc("../../../verification/models/analog/imeas/stimulus/dB40.dat"),
 .file_adc_out("./ADC12_DEV2_OUT.txt")
 )
  u_imeas_ch12_refmodel_dev2(
	.POR(`ANA_TOP.A2D_POR_DVDD),
        .ADC_CLK(sdm_adc_clk_dev2),
	.ADC_RST(sdm_adc_rst_dev2),
	.ADC_IN(`ANA_TOP_S1.A2D_SDM_OUT12),
        .CH_EN(1'b1),
	.OSR(`IMEAS_WRAPPER_TOP.DR),
	.OFFSET(offset_dev2[12]),
	.FORMAT(`IMEAS_WRAPPER_TOP.imeas_reg_0[3:2]),
	.IA(exp_cic_out_dev2[12]),
	.IA_valid(exp_cic_out_valid_dev2[12])
  );

test_SINC_4_24B #(
 .file_adc("../../../verification/models/analog/imeas/stimulus/dB50.dat"),
 .file_adc_out("./ADC13_DEV2_OUT.txt")
 )
  u_imeas_ch13_refmodel_dev2(
	.POR(`ANA_TOP.A2D_POR_DVDD),
        .ADC_CLK(sdm_adc_clk_dev2),
	.ADC_RST(sdm_adc_rst_dev2),
	.ADC_IN(`ANA_TOP_S1.A2D_SDM_OUT13),
        .CH_EN(1'b1),
	.OSR(`IMEAS_WRAPPER_TOP.DR),
	.OFFSET(offset_dev2[13]),
	.FORMAT(`IMEAS_WRAPPER_TOP.imeas_reg_0[3:2]),
	.IA(exp_cic_out_dev2[13]),
	.IA_valid(exp_cic_out_valid_dev2[13])
  );

test_SINC_4_24B #(
 .file_adc("../../../verification/models/analog/imeas/stimulus/dB60.dat"),
 .file_adc_out("./ADC14_DEV2_OUT.txt")
 )
  u_imeas_ch14_refmodel_dev2(
	.POR(`ANA_TOP.A2D_POR_DVDD),
        .ADC_CLK(sdm_adc_clk_dev2),
	.ADC_RST(sdm_adc_rst_dev2),
	.ADC_IN(`ANA_TOP_S1.A2D_SDM_OUT14),
        .CH_EN(1'b1),
	.OSR(`IMEAS_WRAPPER_TOP.DR),
	.OFFSET(offset_dev2[14]),
	.FORMAT(`IMEAS_WRAPPER_TOP.imeas_reg_0[3:2]),
	.IA(exp_cic_out_dev2[14]),
	.IA_valid(exp_cic_out_valid_dev2[14])
  );

test_SINC_4_24B #(
 .file_adc("../../../verification/models/analog/imeas/stimulus/dB70.dat"),
 .file_adc_out("./ADC15_DEV2_OUT.txt")
 )
  u_imeas_ch15_refmodel_dev2(
	.POR(`ANA_TOP.A2D_POR_DVDD),
        .ADC_CLK(sdm_adc_clk_dev2),
	.ADC_RST(sdm_adc_rst_dev2),
	.ADC_IN(`ANA_TOP_S1.A2D_SDM_OUT15),
        .CH_EN(1'b1),
	.OSR(`IMEAS_WRAPPER_TOP.DR),
	.OFFSET(offset_dev2[15]),
	.FORMAT(`IMEAS_WRAPPER_TOP.imeas_reg_0[3:2]),
	.IA(exp_cic_out_dev2[15]),
	.IA_valid(exp_cic_out_valid_dev2[15])
  );

nnc_imeas_if        imeas_vif();
assign imeas_vif.adc_clk             = `CLK_CTRL_TOP.imeas_dig_adc_clk;
assign imeas_vif.pclk                = `CLK_CTRL_TOP.pclk;
assign imeas_vif.sdm_clk             = sdm_adc_clk;
assign imeas_vif.sdm_rst             = sdm_adc_rst;
assign imeas_vif.presetn             = `RST_CTRL_TOP.presetn;
assign imeas_vif.cic_rst_n           = `RST_CTRL_TOP.filter_rstn;
assign imeas_vif.ref_model           = exp_cic_out;
assign imeas_vif.ref_model_dev2      = exp_cic_out_dev2; //24/10/2025, added by supriya to support for dev2 when daisy_en is enabled
assign imeas_vif.offset              = offset; 
assign imeas_vif.chdata              = `IMEAS_WRAPPER_TOP.imeas_chdata_adcclk;
assign imeas_vif.chdata_en           = `IMEAS_WRAPPER_TOP.chdata_en_adcclk;
assign imeas_vif.ch_en               = ~dut_vif.imeas_en_dis_ch; /*& ((dut_vif.no_of_adc_dev1 == 0) ? 8'h03 :
                                       (dut_vif.no_of_adc_dev1 == 1) ? 'hF :
                                       (dut_vif.no_of_adc_dev1 == 2) ? 'h3F :
                                       (dut_vif.no_of_adc_dev1 == 3) ? 'hFF :
                                       (dut_vif.no_of_adc_dev1 == 4) ? 'h3FF :
                                       (dut_vif.no_of_adc_dev1 == 5) ? 'hFFF :
                                       (dut_vif.no_of_adc_dev1 == 6) ? 'h3FFF :  'hFFFF);*/

assign imeas_vif.conv_valid          = |imeas_vif.chdata_en;
assign imeas_vif.exp_chdata_en       = exp_cic_out_valid;
assign imeas_vif.exp_conv_valid      = |exp_cic_out_valid;
assign imeas_vif.IMEAS_EN            = `SPI_TOP.spi_reg_u.imeas_en;
assign imeas_vif.START_CMD           = `SPI_TOP.spi_reg_u.start_cmd;
assign imeas_vif.STOP_CMD            = `SPI_TOP.spi_reg_u.stop_cmd;
assign imeas_vif.RESET_CMD           = `SPI_TOP.spi_reg_u.reset_cmd;
assign imeas_vif.CIC_RATE            = dut_vif.cic_rate;
assign imeas_vif.FORMAT_SEL          = dut_vif.output_format;
assign imeas_vif.SINGLE_SHOT_EN      = `SPI_TOP.spi_reg_u.single_shot;//dut_vif.single_shot_en;
assign imeas_vif.STABLE_TIME         = dut_vif.stable_time;
assign imeas_vif.IMEAS_REG_RST       = `SPI_TOP.spi_reg_u.imeas_reg_0[1];//imeas_rst
assign imeas_vif.stable_cnt_dis_rstn = `RST_CTRL_TOP.adc_resetn;
assign dut_vif.imeas_pos_done        =  |imeas_vif.chdata_en;
assign dut_vif.filter_data_out        = `FILTER_WRAPPER_TOP.imeas_chdata_out;
assign dut_vif.filter_data_out_dev2   = `FILTER_WRAPPER_TOP_S1.imeas_chdata_out;

assign `SPI_TOP.i_channel_max =  dut_vif.no_of_adc_dev1 == 0 ? 2 
                               : dut_vif.no_of_adc_dev1 == 1 ? 4
                               : dut_vif.no_of_adc_dev1 == 2 ? 6 
                               : dut_vif.no_of_adc_dev1 == 3 ? 8 
                               : dut_vif.no_of_adc_dev1 == 4 ? 10 
                               : dut_vif.no_of_adc_dev1 == 5 ? 12
                               : dut_vif.no_of_adc_dev1 == 6 ? 14 
                               : dut_vif.no_of_adc_dev1 == 7 ? 16 :0  ; 

assign `SPI_TOP_S1.i_channel_max = dut_vif.no_of_adc_dev2 == 0 ? 2 
                               : dut_vif.no_of_adc_dev2 == 1 ? 4
                               : dut_vif.no_of_adc_dev2 == 2 ? 6 
                               : dut_vif.no_of_adc_dev2 == 3 ? 8 
                               : dut_vif.no_of_adc_dev2 == 4 ? 10 
                               : dut_vif.no_of_adc_dev2 == 5 ? 12
                               : dut_vif.no_of_adc_dev2 == 6 ? 14 
                               : dut_vif.no_of_adc_dev2 == 7 ? 16 :0  ;

assign dut_vif.max_ch_dev1 = `SPI_TOP.i_channel_max ;
assign dut_vif.max_ch_dev2 = `SPI_TOP_S1.i_channel_max ;

//assign `SPI_TOP.daisy_in = `SPI_TOP_S1.o_miso;
//assign `SPI_TOP_S1.daisy_in = !`SPI_TOP.o_miso;
//assign `SPI_TOP_S2.daisy_in = (dut_vif.total_chip_num == 3) ? (!`SPI_TOP_S1.daisy_in) : 'bz ;

assign dut_vif.exp_chdata            = imeas_vif.exp_chdata;
assign dut_vif.exp_chdata_dev2       = imeas_vif.exp_chdata_dev2; //24/10/2025, added by supriya to support for dev2 when daisy_en is enabled
assign dut_vif.adc_clk               = imeas_vif.adc_clk;
assign dut_vif.no_of_samples_rcvd    = imeas_vif.chdata_cnt;

assign `ANA_TOP.u_imeas_analog_0.counter_clk   = `IMEAS_WRAPPER_TOP.imeas_dig_adc_clk[0];
assign `ANA_TOP.u_imeas_analog_1.counter_clk   = `IMEAS_WRAPPER_TOP.imeas_dig_adc_clk[1];
assign `ANA_TOP.u_imeas_analog_2.counter_clk   = `IMEAS_WRAPPER_TOP.imeas_dig_adc_clk[2];
assign `ANA_TOP.u_imeas_analog_3.counter_clk   = `IMEAS_WRAPPER_TOP.imeas_dig_adc_clk[3];
assign `ANA_TOP.u_imeas_analog_4.counter_clk   = `IMEAS_WRAPPER_TOP.imeas_dig_adc_clk[4];
assign `ANA_TOP.u_imeas_analog_5.counter_clk   = `IMEAS_WRAPPER_TOP.imeas_dig_adc_clk[5];
assign `ANA_TOP.u_imeas_analog_6.counter_clk   = `IMEAS_WRAPPER_TOP.imeas_dig_adc_clk[6];
assign `ANA_TOP.u_imeas_analog_7.counter_clk   = `IMEAS_WRAPPER_TOP.imeas_dig_adc_clk[7];
assign `ANA_TOP.u_imeas_analog_8.counter_clk   = `IMEAS_WRAPPER_TOP.imeas_dig_adc_clk[8];
assign `ANA_TOP.u_imeas_analog_9.counter_clk   = `IMEAS_WRAPPER_TOP.imeas_dig_adc_clk[9];
assign `ANA_TOP.u_imeas_analog_10.counter_clk  = `IMEAS_WRAPPER_TOP.imeas_dig_adc_clk[10];
assign `ANA_TOP.u_imeas_analog_11.counter_clk  = `IMEAS_WRAPPER_TOP.imeas_dig_adc_clk[11];
assign `ANA_TOP.u_imeas_analog_12.counter_clk  = `IMEAS_WRAPPER_TOP.imeas_dig_adc_clk[12];
assign `ANA_TOP.u_imeas_analog_13.counter_clk  = `IMEAS_WRAPPER_TOP.imeas_dig_adc_clk[13];
assign `ANA_TOP.u_imeas_analog_14.counter_clk  = `IMEAS_WRAPPER_TOP.imeas_dig_adc_clk[14];
assign `ANA_TOP.u_imeas_analog_15.counter_clk  = `IMEAS_WRAPPER_TOP.imeas_dig_adc_clk[15];
assign `ANA_TOP.u_imeas_analog_0.input_format  = dut_vif.input_format;
assign `ANA_TOP.u_imeas_analog_1.input_format  = dut_vif.input_format;
assign `ANA_TOP.u_imeas_analog_2.input_format  = dut_vif.input_format;
assign `ANA_TOP.u_imeas_analog_3.input_format  = dut_vif.input_format;
assign `ANA_TOP.u_imeas_analog_4.input_format  = dut_vif.input_format;
assign `ANA_TOP.u_imeas_analog_5.input_format  = dut_vif.input_format;
assign `ANA_TOP.u_imeas_analog_6.input_format  = dut_vif.input_format;
assign `ANA_TOP.u_imeas_analog_7.input_format  = dut_vif.input_format;
assign `ANA_TOP.u_imeas_analog_8.input_format  = dut_vif.input_format;
assign `ANA_TOP.u_imeas_analog_9.input_format  = dut_vif.input_format;
assign `ANA_TOP.u_imeas_analog_10.input_format = dut_vif.input_format;
assign `ANA_TOP.u_imeas_analog_11.input_format = dut_vif.input_format;
assign `ANA_TOP.u_imeas_analog_12.input_format = dut_vif.input_format;
assign `ANA_TOP.u_imeas_analog_13.input_format = dut_vif.input_format;
assign `ANA_TOP.u_imeas_analog_14.input_format = dut_vif.input_format;
assign `ANA_TOP.u_imeas_analog_15.input_format = dut_vif.input_format;
assign `ANA_TOP_S1.u_imeas_analog_0.counter_clk   = `IMEAS_WRAPPER_TOP.imeas_dig_adc_clk[0];
assign `ANA_TOP_S1.u_imeas_analog_1.counter_clk   = `IMEAS_WRAPPER_TOP.imeas_dig_adc_clk[1];
assign `ANA_TOP_S1.u_imeas_analog_2.counter_clk   = `IMEAS_WRAPPER_TOP.imeas_dig_adc_clk[2];
assign `ANA_TOP_S1.u_imeas_analog_3.counter_clk   = `IMEAS_WRAPPER_TOP.imeas_dig_adc_clk[3];
assign `ANA_TOP_S1.u_imeas_analog_4.counter_clk   = `IMEAS_WRAPPER_TOP.imeas_dig_adc_clk[4];
assign `ANA_TOP_S1.u_imeas_analog_5.counter_clk   = `IMEAS_WRAPPER_TOP.imeas_dig_adc_clk[5];
assign `ANA_TOP_S1.u_imeas_analog_6.counter_clk   = `IMEAS_WRAPPER_TOP.imeas_dig_adc_clk[6];
assign `ANA_TOP_S1.u_imeas_analog_7.counter_clk   = `IMEAS_WRAPPER_TOP.imeas_dig_adc_clk[7];
assign `ANA_TOP_S1.u_imeas_analog_8.counter_clk   = `IMEAS_WRAPPER_TOP.imeas_dig_adc_clk[8];
assign `ANA_TOP_S1.u_imeas_analog_9.counter_clk   = `IMEAS_WRAPPER_TOP.imeas_dig_adc_clk[9];
assign `ANA_TOP_S1.u_imeas_analog_10.counter_clk  = `IMEAS_WRAPPER_TOP.imeas_dig_adc_clk[10];
assign `ANA_TOP_S1.u_imeas_analog_11.counter_clk  = `IMEAS_WRAPPER_TOP.imeas_dig_adc_clk[11];
assign `ANA_TOP_S1.u_imeas_analog_12.counter_clk  = `IMEAS_WRAPPER_TOP.imeas_dig_adc_clk[12];
assign `ANA_TOP_S1.u_imeas_analog_13.counter_clk  = `IMEAS_WRAPPER_TOP.imeas_dig_adc_clk[13];
assign `ANA_TOP_S1.u_imeas_analog_14.counter_clk  = `IMEAS_WRAPPER_TOP.imeas_dig_adc_clk[14];
assign `ANA_TOP_S1.u_imeas_analog_15.counter_clk  = `IMEAS_WRAPPER_TOP.imeas_dig_adc_clk[15];
assign `ANA_TOP_S1.u_imeas_analog_0.input_format  = dut_vif.input_format;
assign `ANA_TOP_S1.u_imeas_analog_1.input_format  = dut_vif.input_format;
assign `ANA_TOP_S1.u_imeas_analog_2.input_format  = dut_vif.input_format;
assign `ANA_TOP_S1.u_imeas_analog_3.input_format  = dut_vif.input_format;
assign `ANA_TOP_S1.u_imeas_analog_4.input_format  = dut_vif.input_format;
assign `ANA_TOP_S1.u_imeas_analog_5.input_format  = dut_vif.input_format;
assign `ANA_TOP_S1.u_imeas_analog_6.input_format  = dut_vif.input_format;
assign `ANA_TOP_S1.u_imeas_analog_7.input_format  = dut_vif.input_format;
assign `ANA_TOP_S1.u_imeas_analog_8.input_format  = dut_vif.input_format;
assign `ANA_TOP_S1.u_imeas_analog_9.input_format  = dut_vif.input_format;
assign `ANA_TOP_S1.u_imeas_analog_10.input_format = dut_vif.input_format;
assign `ANA_TOP_S1.u_imeas_analog_11.input_format = dut_vif.input_format;
assign `ANA_TOP_S1.u_imeas_analog_12.input_format = dut_vif.input_format;
assign `ANA_TOP_S1.u_imeas_analog_13.input_format = dut_vif.input_format;
assign `ANA_TOP_S1.u_imeas_analog_14.input_format = dut_vif.input_format;
assign `ANA_TOP_S1.u_imeas_analog_15.input_format = dut_vif.input_format;

assign `ANA_TOP.u_imeas_analog_0.imeas_sin_gen_en  = dut_vif.imeas_sin_gen_en;
assign `ANA_TOP.u_imeas_analog_1.imeas_sin_gen_en  = dut_vif.imeas_sin_gen_en;
assign `ANA_TOP.u_imeas_analog_2.imeas_sin_gen_en  = dut_vif.imeas_sin_gen_en;
assign `ANA_TOP.u_imeas_analog_3.imeas_sin_gen_en  = dut_vif.imeas_sin_gen_en;
assign `ANA_TOP.u_imeas_analog_4.imeas_sin_gen_en  = dut_vif.imeas_sin_gen_en;
assign `ANA_TOP.u_imeas_analog_5.imeas_sin_gen_en  = dut_vif.imeas_sin_gen_en;
assign `ANA_TOP.u_imeas_analog_6.imeas_sin_gen_en  = dut_vif.imeas_sin_gen_en;
assign `ANA_TOP.u_imeas_analog_7.imeas_sin_gen_en  = dut_vif.imeas_sin_gen_en;
assign `ANA_TOP.u_imeas_analog_8.imeas_sin_gen_en  = dut_vif.imeas_sin_gen_en;
assign `ANA_TOP.u_imeas_analog_9.imeas_sin_gen_en  = dut_vif.imeas_sin_gen_en;
assign `ANA_TOP.u_imeas_analog_10.imeas_sin_gen_en = dut_vif.imeas_sin_gen_en;
assign `ANA_TOP.u_imeas_analog_11.imeas_sin_gen_en = dut_vif.imeas_sin_gen_en;
assign `ANA_TOP.u_imeas_analog_12.imeas_sin_gen_en = dut_vif.imeas_sin_gen_en;
assign `ANA_TOP.u_imeas_analog_13.imeas_sin_gen_en = dut_vif.imeas_sin_gen_en;
assign `ANA_TOP.u_imeas_analog_14.imeas_sin_gen_en = dut_vif.imeas_sin_gen_en;
assign `ANA_TOP.u_imeas_analog_15.imeas_sin_gen_en = dut_vif.imeas_sin_gen_en;
assign `ANA_TOP.u_imeas_analog_0.imeas_noise_gen_en  = dut_vif.imeas_noise_gen_en;
assign `ANA_TOP.u_imeas_analog_1.imeas_noise_gen_en  = dut_vif.imeas_noise_gen_en;
assign `ANA_TOP.u_imeas_analog_2.imeas_noise_gen_en  = dut_vif.imeas_noise_gen_en;
assign `ANA_TOP.u_imeas_analog_3.imeas_noise_gen_en  = dut_vif.imeas_noise_gen_en;
assign `ANA_TOP.u_imeas_analog_4.imeas_noise_gen_en  = dut_vif.imeas_noise_gen_en;
assign `ANA_TOP.u_imeas_analog_5.imeas_noise_gen_en  = dut_vif.imeas_noise_gen_en;
assign `ANA_TOP.u_imeas_analog_6.imeas_noise_gen_en  = dut_vif.imeas_noise_gen_en;
assign `ANA_TOP.u_imeas_analog_7.imeas_noise_gen_en  = dut_vif.imeas_noise_gen_en;
assign `ANA_TOP.u_imeas_analog_8.imeas_noise_gen_en  = dut_vif.imeas_noise_gen_en;
assign `ANA_TOP.u_imeas_analog_9.imeas_noise_gen_en  = dut_vif.imeas_noise_gen_en;
assign `ANA_TOP.u_imeas_analog_10.imeas_noise_gen_en = dut_vif.imeas_noise_gen_en;
assign `ANA_TOP.u_imeas_analog_11.imeas_noise_gen_en = dut_vif.imeas_noise_gen_en;
assign `ANA_TOP.u_imeas_analog_12.imeas_noise_gen_en = dut_vif.imeas_noise_gen_en;
assign `ANA_TOP.u_imeas_analog_13.imeas_noise_gen_en = dut_vif.imeas_noise_gen_en;
assign `ANA_TOP.u_imeas_analog_14.imeas_noise_gen_en = dut_vif.imeas_noise_gen_en;
assign `ANA_TOP.u_imeas_analog_15.imeas_noise_gen_en = dut_vif.imeas_noise_gen_en;
assign `ANA_TOP_S1.u_imeas_analog_0.imeas_sin_gen_en  = dut_vif.imeas_sin_gen_en;
assign `ANA_TOP_S1.u_imeas_analog_1.imeas_sin_gen_en  = dut_vif.imeas_sin_gen_en;
assign `ANA_TOP_S1.u_imeas_analog_2.imeas_sin_gen_en  = dut_vif.imeas_sin_gen_en;
assign `ANA_TOP_S1.u_imeas_analog_3.imeas_sin_gen_en  = dut_vif.imeas_sin_gen_en;
assign `ANA_TOP_S1.u_imeas_analog_4.imeas_sin_gen_en  = dut_vif.imeas_sin_gen_en;
assign `ANA_TOP_S1.u_imeas_analog_5.imeas_sin_gen_en  = dut_vif.imeas_sin_gen_en;
assign `ANA_TOP_S1.u_imeas_analog_6.imeas_sin_gen_en  = dut_vif.imeas_sin_gen_en;
assign `ANA_TOP_S1.u_imeas_analog_7.imeas_sin_gen_en  = dut_vif.imeas_sin_gen_en;
assign `ANA_TOP_S1.u_imeas_analog_8.imeas_sin_gen_en  = dut_vif.imeas_sin_gen_en;
assign `ANA_TOP_S1.u_imeas_analog_9.imeas_sin_gen_en  = dut_vif.imeas_sin_gen_en;
assign `ANA_TOP_S1.u_imeas_analog_10.imeas_sin_gen_en  = dut_vif.imeas_sin_gen_en;
assign `ANA_TOP_S1.u_imeas_analog_11.imeas_sin_gen_en  = dut_vif.imeas_sin_gen_en;
assign `ANA_TOP_S1.u_imeas_analog_12.imeas_sin_gen_en  = dut_vif.imeas_sin_gen_en;
assign `ANA_TOP_S1.u_imeas_analog_13.imeas_sin_gen_en  = dut_vif.imeas_sin_gen_en;
assign `ANA_TOP_S1.u_imeas_analog_14.imeas_sin_gen_en  = dut_vif.imeas_sin_gen_en;
assign `ANA_TOP_S1.u_imeas_analog_15.imeas_sin_gen_en  = dut_vif.imeas_sin_gen_en;
assign `ANA_TOP_S1.u_imeas_analog_0.imeas_noise_gen_en  = dut_vif.imeas_noise_gen_en;
assign `ANA_TOP_S1.u_imeas_analog_1.imeas_noise_gen_en  = dut_vif.imeas_noise_gen_en;
assign `ANA_TOP_S1.u_imeas_analog_2.imeas_noise_gen_en  = dut_vif.imeas_noise_gen_en;
assign `ANA_TOP_S1.u_imeas_analog_3.imeas_noise_gen_en  = dut_vif.imeas_noise_gen_en;
assign `ANA_TOP_S1.u_imeas_analog_4.imeas_noise_gen_en  = dut_vif.imeas_noise_gen_en;
assign `ANA_TOP_S1.u_imeas_analog_5.imeas_noise_gen_en  = dut_vif.imeas_noise_gen_en;
assign `ANA_TOP_S1.u_imeas_analog_6.imeas_noise_gen_en  = dut_vif.imeas_noise_gen_en;
assign `ANA_TOP_S1.u_imeas_analog_7.imeas_noise_gen_en  = dut_vif.imeas_noise_gen_en;
assign `ANA_TOP_S1.u_imeas_analog_8.imeas_noise_gen_en  = dut_vif.imeas_noise_gen_en;
assign `ANA_TOP_S1.u_imeas_analog_9.imeas_noise_gen_en  = dut_vif.imeas_noise_gen_en;
assign `ANA_TOP_S1.u_imeas_analog_10.imeas_noise_gen_en  = dut_vif.imeas_noise_gen_en;
assign `ANA_TOP_S1.u_imeas_analog_11.imeas_noise_gen_en  = dut_vif.imeas_noise_gen_en;
assign `ANA_TOP_S1.u_imeas_analog_12.imeas_noise_gen_en  = dut_vif.imeas_noise_gen_en;
assign `ANA_TOP_S1.u_imeas_analog_13.imeas_noise_gen_en  = dut_vif.imeas_noise_gen_en;
assign `ANA_TOP_S1.u_imeas_analog_14.imeas_noise_gen_en  = dut_vif.imeas_noise_gen_en;
assign `ANA_TOP_S1.u_imeas_analog_15.imeas_noise_gen_en  = dut_vif.imeas_noise_gen_en;

assign `ANA_TOP.u_imeas_analog_0.imeas_sin_no_clk_per_period  = dut_vif.imeas_sin_no_clk_per_period;
assign `ANA_TOP.u_imeas_analog_1.imeas_sin_no_clk_per_period  = dut_vif.imeas_sin_no_clk_per_period;
assign `ANA_TOP.u_imeas_analog_2.imeas_sin_no_clk_per_period  = dut_vif.imeas_sin_no_clk_per_period;
assign `ANA_TOP.u_imeas_analog_3.imeas_sin_no_clk_per_period  = dut_vif.imeas_sin_no_clk_per_period;
assign `ANA_TOP.u_imeas_analog_4.imeas_sin_no_clk_per_period  = dut_vif.imeas_sin_no_clk_per_period;
assign `ANA_TOP.u_imeas_analog_5.imeas_sin_no_clk_per_period  = dut_vif.imeas_sin_no_clk_per_period;
assign `ANA_TOP.u_imeas_analog_6.imeas_sin_no_clk_per_period  = dut_vif.imeas_sin_no_clk_per_period;
assign `ANA_TOP.u_imeas_analog_7.imeas_sin_no_clk_per_period  = dut_vif.imeas_sin_no_clk_per_period;
assign `ANA_TOP.u_imeas_analog_8.imeas_sin_no_clk_per_period  = dut_vif.imeas_sin_no_clk_per_period;
assign `ANA_TOP.u_imeas_analog_9.imeas_sin_no_clk_per_period  = dut_vif.imeas_sin_no_clk_per_period;
assign `ANA_TOP.u_imeas_analog_10.imeas_sin_no_clk_per_period = dut_vif.imeas_sin_no_clk_per_period;
assign `ANA_TOP.u_imeas_analog_11.imeas_sin_no_clk_per_period = dut_vif.imeas_sin_no_clk_per_period;
assign `ANA_TOP.u_imeas_analog_12.imeas_sin_no_clk_per_period = dut_vif.imeas_sin_no_clk_per_period;
assign `ANA_TOP.u_imeas_analog_13.imeas_sin_no_clk_per_period = dut_vif.imeas_sin_no_clk_per_period;
assign `ANA_TOP.u_imeas_analog_14.imeas_sin_no_clk_per_period = dut_vif.imeas_sin_no_clk_per_period;
assign `ANA_TOP.u_imeas_analog_15.imeas_sin_no_clk_per_period = dut_vif.imeas_sin_no_clk_per_period;
assign `ANA_TOP_S1.u_imeas_analog_0.imeas_sin_no_clk_per_period  = dut_vif.imeas_sin_no_clk_per_period;
assign `ANA_TOP_S1.u_imeas_analog_1.imeas_sin_no_clk_per_period  = dut_vif.imeas_sin_no_clk_per_period;
assign `ANA_TOP_S1.u_imeas_analog_2.imeas_sin_no_clk_per_period  = dut_vif.imeas_sin_no_clk_per_period;
assign `ANA_TOP_S1.u_imeas_analog_3.imeas_sin_no_clk_per_period  = dut_vif.imeas_sin_no_clk_per_period;
assign `ANA_TOP_S1.u_imeas_analog_4.imeas_sin_no_clk_per_period  = dut_vif.imeas_sin_no_clk_per_period;
assign `ANA_TOP_S1.u_imeas_analog_5.imeas_sin_no_clk_per_period  = dut_vif.imeas_sin_no_clk_per_period;
assign `ANA_TOP_S1.u_imeas_analog_6.imeas_sin_no_clk_per_period  = dut_vif.imeas_sin_no_clk_per_period;
assign `ANA_TOP_S1.u_imeas_analog_7.imeas_sin_no_clk_per_period  = dut_vif.imeas_sin_no_clk_per_period;
assign `ANA_TOP_S1.u_imeas_analog_8.imeas_sin_no_clk_per_period  = dut_vif.imeas_sin_no_clk_per_period;
assign `ANA_TOP_S1.u_imeas_analog_9.imeas_sin_no_clk_per_period  = dut_vif.imeas_sin_no_clk_per_period;
assign `ANA_TOP_S1.u_imeas_analog_10.imeas_sin_no_clk_per_period = dut_vif.imeas_sin_no_clk_per_period;
assign `ANA_TOP_S1.u_imeas_analog_11.imeas_sin_no_clk_per_period = dut_vif.imeas_sin_no_clk_per_period;
assign `ANA_TOP_S1.u_imeas_analog_12.imeas_sin_no_clk_per_period = dut_vif.imeas_sin_no_clk_per_period;
assign `ANA_TOP_S1.u_imeas_analog_13.imeas_sin_no_clk_per_period = dut_vif.imeas_sin_no_clk_per_period;
assign `ANA_TOP_S1.u_imeas_analog_14.imeas_sin_no_clk_per_period = dut_vif.imeas_sin_no_clk_per_period;
assign `ANA_TOP_S1.u_imeas_analog_15.imeas_sin_no_clk_per_period = dut_vif.imeas_sin_no_clk_per_period;


initial begin
    nnc_config_db#(virtual nnc_imeas_if)::set(uvm_root::get(),"uvm_test_top.*", "imeas_vif", imeas_vif);
end

