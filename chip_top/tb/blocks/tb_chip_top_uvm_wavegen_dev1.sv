/*--------------------------------------------------------------------------------------*/
// Copyright 2021 Nanochap, Inc.
// All Rights Reserved Worldwide
// --------------------------------------------------------------------------------------
// Project      : Nanochap ENS2
// File         : tb_chip_top_uvm_wavegen.sv
// Description  : ANALOG BLOCK TB (included file) 
// Designer     : Daniel Dang
// Date         : 18-03-2024
// Revision     : 0.1
/*--------------------------------------------------------------------------------------*/

// Design a logic to capture DATAs for Driver A
`define CHIP_1_SPI_REG soc_top_tb.u_Nanochap_ENS2_1.u_top_dig.u_spi_top.spi_reg_u
`define CHIP_1_ANA_WRAPPER_TOP `ANA_WRAPPER_TOP_1
`define CHIP_1_SPI_TOP `SPI_TOP_1
`define CHIP_1_WG_DRIVER_TOP `WG_DRIVER_TOP_1

`define CHIP_2_SPI_REG soc_top_tb.u_Nanochap_ENS2_2.u_top_dig.u_spi_top.spi_reg_u
`define CHIP_2_ANA_WRAPPER_TOP `ANA_WRAPPER_TOP_2
`define CHIP_2_SPI_TOP `SPI_TOP_2
`define CHIP_2_WG_DRIVER_TOP `WG_DRIVER_TOP_2

//nnc_wavegen_interface     wavegen_vif[1]();
//nnc_wavegen_interface     wavegen_vif[WAVEGEN_NUM_OF_MULT_CHIPS]();

`ifdef BEHAVIORAL
  `define CHIP_1_SPI_WAVEGEN_REG_10 `CHIP_1_SPI_REG.genblk1[0].u_spi_reg_wavegen
  `define CHIP_1_SPI_WAVEGEN_REG_11 `CHIP_1_SPI_REG.genblk1[1].u_spi_reg_wavegen
  `define CHIP_2_SPI_WAVEGEN_REG_10 `CHIP_2_SPI_REG.genblk1[0].u_spi_reg_wavegen
  `define CHIP_2_SPI_WAVEGEN_REG_11 `CHIP_2_SPI_REG.genblk1[1].u_spi_reg_wavegen  
  wire [7:0] other_chip_drive_ctrl_reg0_10 = (dut_vif.swap_sdf_en === 1'b1) ? `CHIP_2_SPI_WAVEGEN_REG_10.drive_ctrl_reg0[7:0] : `CHIP_1_SPI_WAVEGEN_REG_10.drive_ctrl_reg0[7:0];
  wire [7:0] other_chip_drive_ctrl_reg1_10 = (dut_vif.swap_sdf_en === 1'b1) ? `CHIP_2_SPI_WAVEGEN_REG_10.drive_ctrl_reg1[7:0] : `CHIP_1_SPI_WAVEGEN_REG_10.drive_ctrl_reg1[7:0]; 
  wire [7:0] other_chip_drive_ctrl_reg2_10 = (dut_vif.swap_sdf_en === 1'b1) ? `CHIP_2_SPI_WAVEGEN_REG_10.drive_ctrl_reg2[7:0] : `CHIP_1_SPI_WAVEGEN_REG_10.drive_ctrl_reg2[7:0]; 
  wire [7:0] other_chip_drive_ctrl_reg0_11 = (dut_vif.swap_sdf_en === 1'b1) ? `CHIP_2_SPI_WAVEGEN_REG_11.drive_ctrl_reg0[7:0] : `CHIP_1_SPI_WAVEGEN_REG_11.drive_ctrl_reg0[7:0];
  wire [7:0] other_chip_drive_ctrl_reg1_11 = (dut_vif.swap_sdf_en === 1'b1) ? `CHIP_2_SPI_WAVEGEN_REG_11.drive_ctrl_reg1[7:0] : `CHIP_1_SPI_WAVEGEN_REG_11.drive_ctrl_reg1[7:0]; 
  wire [7:0] other_chip_drive_ctrl_reg2_11 = (dut_vif.swap_sdf_en === 1'b1) ? `CHIP_2_SPI_WAVEGEN_REG_11.drive_ctrl_reg2[7:0] : `CHIP_1_SPI_WAVEGEN_REG_11.drive_ctrl_reg2[7:0];
`else
  `define CHIP_1_SPI_WAVEGEN_REG_10 `CHIP_1_SPI_TOP.spi_reg_u.genblk1_0__u_spi_reg_wavegen
  `define CHIP_1_SPI_WAVEGEN_REG_11 `CHIP_1_SPI_TOP.spi_reg_u.genblk1_1__u_spi_reg_wavegen
  `define CHIP_2_SPI_WAVEGEN_REG_10 `CHIP_2_SPI_TOP.spi_reg_u.genblk1_0__u_spi_reg_wavegen
  `define CHIP_2_SPI_WAVEGEN_REG_11 `CHIP_2_SPI_TOP.spi_reg_u.genblk1_1__u_spi_reg_wavegen

  wire [7:0] other_chip_drive_ctrl_reg0_10 = (dut_vif.swap_sdf_en === 1'b1)?
    {`CHIP_2_SPI_WAVEGEN_REG_10.drive_ctrl_reg0_reg_7_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_10.drive_ctrl_reg0_reg_6_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_10.drive_ctrl_reg0_reg_5_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_10.drive_ctrl_reg0_reg_4_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_10.drive_ctrl_reg0_reg_3_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_10.drive_ctrl_reg0_reg_2_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_10.drive_ctrl_reg0_reg_1_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_10.drive_ctrl_reg0_reg_0_.Q} 
    : 
    {
    `CHIP_1_SPI_WAVEGEN_REG_10.drive_ctrl_reg0_reg_7_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_10.drive_ctrl_reg0_reg_6_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_10.drive_ctrl_reg0_reg_5_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_10.drive_ctrl_reg0_reg_4_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_10.drive_ctrl_reg0_reg_3_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_10.drive_ctrl_reg0_reg_2_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_10.drive_ctrl_reg0_reg_1_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_10.drive_ctrl_reg0_reg_0_.Q};

  wire [7:0] other_chip_drive_ctrl_reg1_10 = (dut_vif.swap_sdf_en === 1'b1)?
   {`CHIP_2_SPI_WAVEGEN_REG_10.drive_ctrl_reg1_reg_7_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_10.drive_ctrl_reg1_reg_6_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_10.drive_ctrl_reg1_reg_5_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_10.drive_ctrl_reg1_reg_4_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_10.drive_ctrl_reg1_reg_3_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_10.drive_ctrl_reg1_reg_2_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_10.drive_ctrl_reg1_reg_1_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_10.drive_ctrl_reg1_reg_0_.Q}
    :
   {`CHIP_1_SPI_WAVEGEN_REG_10.drive_ctrl_reg1_reg_7_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_10.drive_ctrl_reg1_reg_6_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_10.drive_ctrl_reg1_reg_5_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_10.drive_ctrl_reg1_reg_4_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_10.drive_ctrl_reg1_reg_3_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_10.drive_ctrl_reg1_reg_2_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_10.drive_ctrl_reg1_reg_1_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_10.drive_ctrl_reg1_reg_0_.Q };

  wire [7:0] other_chip_drive_ctrl_reg2_10 = (dut_vif.swap_sdf_en === 1'b1)?
   {`CHIP_2_SPI_WAVEGEN_REG_10.drive_ctrl_reg2_reg_7_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_10.drive_ctrl_reg2_reg_6_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_10.drive_ctrl_reg2_reg_5_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_10.drive_ctrl_reg2_reg_4_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_10.drive_ctrl_reg2_reg_3_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_10.drive_ctrl_reg2_reg_2_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_10.drive_ctrl_reg2_reg_1_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_10.drive_ctrl_reg2_reg_0_.Q}
    :
    {`CHIP_1_SPI_WAVEGEN_REG_10.drive_ctrl_reg2_reg_7_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_10.drive_ctrl_reg2_reg_6_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_10.drive_ctrl_reg2_reg_5_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_10.drive_ctrl_reg2_reg_4_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_10.drive_ctrl_reg2_reg_3_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_10.drive_ctrl_reg2_reg_2_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_10.drive_ctrl_reg2_reg_1_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_10.drive_ctrl_reg2_reg_0_.Q};

  wire [7:0] other_chip_drive_ctrl_reg0_11 = (dut_vif.swap_sdf_en === 1'b1)?
   {
    `CHIP_2_SPI_WAVEGEN_REG_11.drive_ctrl_reg0_reg_7_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_11.drive_ctrl_reg0_reg_6_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_11.drive_ctrl_reg0_reg_5_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_11.drive_ctrl_reg0_reg_4_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_11.drive_ctrl_reg0_reg_3_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_11.drive_ctrl_reg0_reg_2_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_11.drive_ctrl_reg0_reg_1_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_11.drive_ctrl_reg0_reg_0_.Q}
    :
    {`CHIP_1_SPI_WAVEGEN_REG_11.drive_ctrl_reg0_reg_7_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_11.drive_ctrl_reg0_reg_6_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_11.drive_ctrl_reg0_reg_5_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_11.drive_ctrl_reg0_reg_4_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_11.drive_ctrl_reg0_reg_3_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_11.drive_ctrl_reg0_reg_2_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_11.drive_ctrl_reg0_reg_1_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_11.drive_ctrl_reg0_reg_0_.Q};

  wire [7:0] other_chip_drive_ctrl_reg1_11 = (dut_vif.swap_sdf_en === 1'b1)?
    {
    `CHIP_2_SPI_WAVEGEN_REG_11.drive_ctrl_reg1_reg_7_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_11.drive_ctrl_reg1_reg_6_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_11.drive_ctrl_reg1_reg_5_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_11.drive_ctrl_reg1_reg_4_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_11.drive_ctrl_reg1_reg_3_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_11.drive_ctrl_reg1_reg_2_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_11.drive_ctrl_reg1_reg_1_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_11.drive_ctrl_reg1_reg_0_.Q}
    :
    {`CHIP_1_SPI_WAVEGEN_REG_11.drive_ctrl_reg1_reg_7_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_11.drive_ctrl_reg1_reg_6_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_11.drive_ctrl_reg1_reg_5_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_11.drive_ctrl_reg1_reg_4_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_11.drive_ctrl_reg1_reg_3_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_11.drive_ctrl_reg1_reg_2_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_11.drive_ctrl_reg1_reg_1_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_11.drive_ctrl_reg1_reg_0_.Q};

  wire [7:0] other_chip_drive_ctrl_reg2_11 = (dut_vif.swap_sdf_en === 1'b1)? 
   {
    `CHIP_2_SPI_WAVEGEN_REG_11.drive_ctrl_reg2_reg_7_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_11.drive_ctrl_reg2_reg_6_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_11.drive_ctrl_reg2_reg_5_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_11.drive_ctrl_reg2_reg_4_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_11.drive_ctrl_reg2_reg_3_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_11.drive_ctrl_reg2_reg_2_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_11.drive_ctrl_reg2_reg_1_.Q, 
    `CHIP_2_SPI_WAVEGEN_REG_11.drive_ctrl_reg2_reg_0_.Q}
   :
   {
    `CHIP_1_SPI_WAVEGEN_REG_11.drive_ctrl_reg2_reg_7_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_11.drive_ctrl_reg2_reg_6_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_11.drive_ctrl_reg2_reg_5_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_11.drive_ctrl_reg2_reg_4_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_11.drive_ctrl_reg2_reg_3_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_11.drive_ctrl_reg2_reg_2_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_11.drive_ctrl_reg2_reg_1_.Q, 
    `CHIP_1_SPI_WAVEGEN_REG_11.drive_ctrl_reg2_reg_0_.Q};
`endif

always@(`CHIP_1_ANA_WRAPPER_TOP.i_out_wave_drivera_dac0 )
    if(dut_vif.swap_sdf_en === 1'b0)begin
      wavegen_vif[1].wave_data_a = (other_chip_drive_ctrl_reg0_10[5] === 1'b0) ? ((other_chip_drive_ctrl_reg2_10[6:4] === 3'b000) ? `CHIP_1_ANA_WRAPPER_TOP.i_out_wave_drivera_dac0[11:4] : (other_chip_drive_ctrl_reg2_10[6:4] === 3'b001)?`CHIP_1_ANA_WRAPPER_TOP.i_out_wave_drivera_dac0[10:3] : (other_chip_drive_ctrl_reg2_10[6:4] === 3'b010) ? `CHIP_1_ANA_WRAPPER_TOP.i_out_wave_drivera_dac0[9:2] : (other_chip_drive_ctrl_reg2_10[6:4] === 3'b011) ?`CHIP_1_ANA_WRAPPER_TOP.i_out_wave_drivera_dac0[8:1] : (other_chip_drive_ctrl_reg2_10[6:4] === 3'b100)?`CHIP_1_ANA_WRAPPER_TOP.i_out_wave_drivera_dac0[7:0] : `CHIP_1_ANA_WRAPPER_TOP.i_out_wave_drivera_dac0[11:4]) : {other_chip_drive_ctrl_reg2_10[3:0], other_chip_drive_ctrl_reg1_10};
      wavegen_vif[1].bitsel = other_chip_drive_ctrl_reg2_10[6:4];
    end

always@(`CHIP_2_ANA_WRAPPER_TOP.i_out_wave_drivera_dac0)
     if(dut_vif.swap_sdf_en === 1'b1)begin
      wavegen_vif[1].wave_data_a = (other_chip_drive_ctrl_reg0_10[5] === 1'b0) ? ((other_chip_drive_ctrl_reg2_10[6:4] === 3'b000) ? `CHIP_2_ANA_WRAPPER_TOP.i_out_wave_drivera_dac0[11:4] : (other_chip_drive_ctrl_reg2_10[6:4] === 3'b001)?`CHIP_2_ANA_WRAPPER_TOP.i_out_wave_drivera_dac0[10:3] : (other_chip_drive_ctrl_reg2_10[6:4] === 3'b010) ? `CHIP_2_ANA_WRAPPER_TOP.i_out_wave_drivera_dac0[9:2] : (other_chip_drive_ctrl_reg2_10[6:4] === 3'b011) ?`CHIP_2_ANA_WRAPPER_TOP.i_out_wave_drivera_dac0[8:1] : (other_chip_drive_ctrl_reg2_10[6:4] === 3'b100)?`CHIP_2_ANA_WRAPPER_TOP.i_out_wave_drivera_dac0[7:0] : `CHIP_2_ANA_WRAPPER_TOP.i_out_wave_drivera_dac0[11:4]) : {other_chip_drive_ctrl_reg2_10[3:0], other_chip_drive_ctrl_reg1_10};
      wavegen_vif[1].bitsel = other_chip_drive_ctrl_reg2_10[6:4];
    end

assign wavegen_vif[1].daca_bit_len_sel = other_chip_drive_ctrl_reg0_10[5];
assign wavegen_vif[1].manual_mode[0] = other_chip_drive_ctrl_reg0_10[4];
assign wavegen_vif[1].spi_reg[0] = {other_chip_drive_ctrl_reg2_10[3:0], other_chip_drive_ctrl_reg1_10};
assign wavegen_vif[1].ana_data[0] = (dut_vif.swap_sdf_en === 1'b1)? `CHIP_2_ANA_WRAPPER_TOP.i_out_wave_drivera_dac0 : `CHIP_1_ANA_WRAPPER_TOP.i_out_wave_drivera_dac0;

//`ifndef POSTSCAN
`ifdef BEHAVIORAL
  assign wavegen_vif[1].neg_scale[0] = (dut_vif.swap_sdf_en === 1'b1)? `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_scale : `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_scale;
  assign wavegen_vif[1].pos_scale[0] = (dut_vif.swap_sdf_en === 1'b1)? `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_isel : `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_isel;
//`ifndef POSTSCAN_PG
  assign wavegen_vif[1].neg_scale[1] = (dut_vif.swap_sdf_en === 1'b1)? `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale : `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale;
/*
  `else
  assign wavegen_vif[1].neg_scale[1] = (dut_vif.swap_sdf_en === 1'b1)? 
{
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_6_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_5_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_4_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_3_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_2_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_1_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_0_.Q
}
:
{
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_6_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_5_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_4_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_3_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_2_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_1_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_0_.Q
};
`endif
*/
assign wavegen_vif[1].pos_scale[1] = (dut_vif.swap_sdf_en === 1'b1)? `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_isel : `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_isel;
`else
assign wavegen_vif[1].neg_scale[0] = (dut_vif.swap_sdf_en === 1'b1)? 
{
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_scale_reg_6_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_scale_reg_5_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_scale_reg_4_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_scale_reg_3_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_scale_reg_2_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_scale_reg_1_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_scale_reg_0_.Q
}
:
{
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_scale_reg_6_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_scale_reg_5_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_scale_reg_4_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_scale_reg_3_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_scale_reg_2_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_scale_reg_1_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_scale_reg_0_.Q
};
assign wavegen_vif[1].pos_scale[0] = (dut_vif.swap_sdf_en === 1'b1)?
{
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_isel_reg_7_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_isel_reg_6_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_isel_reg_5_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_isel_reg_4_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_isel_reg_3_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_isel_reg_2_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_isel_reg_1_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_isel_reg_0_.Q
}
:
{
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_isel_reg_7_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_isel_reg_6_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_isel_reg_5_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_isel_reg_4_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_isel_reg_3_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_isel_reg_2_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_isel_reg_1_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_isel_reg_0_.Q
};
assign wavegen_vif[1].neg_scale[1] = (dut_vif.swap_sdf_en === 1'b1)? 
{
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_6_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_5_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_4_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_3_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_2_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_1_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_0_.Q
}
:
{
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_6_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_5_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_4_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_3_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_2_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_1_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_0_.Q
};
assign wavegen_vif[1].pos_scale[1] = (dut_vif.swap_sdf_en === 1'b1)?
{
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_isel_reg_7_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_isel_reg_6_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_isel_reg_5_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_isel_reg_4_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_isel_reg_3_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_isel_reg_2_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_isel_reg_1_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_isel_reg_0_.Q
}
:
{
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_isel_reg_7_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_isel_reg_6_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_isel_reg_5_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_isel_reg_4_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_isel_reg_3_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_isel_reg_2_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_isel_reg_1_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_isel_reg_0_.Q
};
`endif

assign wavegen_vif[1].neg_offset[0] = (dut_vif.swap_sdf_en === 1'b1) ?
`ifndef POSTSCAN
  `ifdef POSTLAYOUT_PG
  {
    `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_7_.Q,
    `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_6_.Q,
    `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_5_.Q,
    `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_4_.Q,
    `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_3_.Q,
    `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_2_.Q,
    `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_1_.Q,
    `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_0_.Q                               
  } :
  {
    `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_7_.Q,
    `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_6_.Q,
    `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_5_.Q,
    `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_4_.Q,
    `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_3_.Q,
    `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_2_.Q,
    `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_1_.Q,
    `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_0_.Q                               
  }
  ;
  `else
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset :  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset;
  `endif
`else
{
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_7_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_6_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_5_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_4_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_3_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_2_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_1_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_0_.Q                               
} :
{
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_7_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_6_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_5_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_4_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_3_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_2_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_1_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_0_.Q                               
}
;
`endif

assign wavegen_vif[1].pos_offset[0] =  (dut_vif.swap_sdf_en === 1'b1) ? 
//`ifndef POSTSCAN
  `ifndef BEHAVIORAL //POSTLAYOUT_PG
  {
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_7_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_6_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_5_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_4_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_3_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_2_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_1_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_0_.Q
  }
  :
  {
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_7_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_6_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_5_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_4_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_3_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_2_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_1_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_0_.Q
  };
  `else
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset : `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset;
  `endif
/*
`else
  {
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_7_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_6_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_5_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_4_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_3_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_2_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_1_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_0_.Q
  }
  :
  {
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_7_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_6_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_5_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_4_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_3_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_2_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_1_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_0_.Q
  };
`endif
*/
assign wavegen_vif[1].neg_offset[1] = (dut_vif.swap_sdf_en === 1'b1) ?
`ifdef BEHAVIORAL
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_offset :  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_offset;
`else
{
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_offset_reg_7_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_offset_reg_6_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_offset_reg_5_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_offset_reg_4_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_offset_reg_3_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_offset_reg_2_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_offset_reg_1_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_offset_reg_0_.Q                               
} :
{
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_offset_reg_7_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_offset_reg_6_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_offset_reg_5_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_offset_reg_4_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_offset_reg_3_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_offset_reg_2_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_offset_reg_1_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_neg_offset_reg_0_.Q                               
}
;
`endif

assign wavegen_vif[1].pos_offset[1] =  (dut_vif.swap_sdf_en === 1'b1) ? 
`ifdef BEHAVIORAL
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_pos_offset : `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_pos_offset;
`else
  {
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_pos_offset_reg_7_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_pos_offset_reg_6_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_pos_offset_reg_5_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_pos_offset_reg_4_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_pos_offset_reg_3_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_pos_offset_reg_2_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_pos_offset_reg_1_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_pos_offset_reg_0_.Q
  }
  :
  {
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_pos_offset_reg_7_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_pos_offset_reg_6_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_pos_offset_reg_5_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_pos_offset_reg_4_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_pos_offset_reg_3_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_pos_offset_reg_2_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_pos_offset_reg_1_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_pos_offset_reg_0_.Q
  };
`endif

assign wavegen_vif[1].delay_lim[0] =  (dut_vif.swap_sdf_en === 1'b1) ? 
`ifdef BEHAVIORAL
`CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim[15:0] : `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim[15:0];
`else
  {
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_15_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_14_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_13_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_12_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_11_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_10_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_9_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_8_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_7_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_6_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_5_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_4_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_3_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_2_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_1_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_0_.Q
  }
  :
  {
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_15_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_14_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_13_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_12_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_11_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_10_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_9_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_8_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_7_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_6_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_5_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_4_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_3_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_2_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_1_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_0_.Q
  };
`endif

assign wavegen_vif[1].delay_lim[1] =  (dut_vif.swap_sdf_en === 1'b1) ? 
`ifdef BEHAVIORAL
`CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim[15:0] : `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim[15:0];
`else
  {
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_15_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_14_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_13_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_12_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_11_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_10_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_9_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_8_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_7_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_6_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_5_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_4_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_3_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_2_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_1_.Q,
  `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_0_.Q
  }
  :
  {
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_15_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_14_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_13_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_12_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_11_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_10_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_9_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_8_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_7_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_6_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_5_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_4_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_3_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_2_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_1_.Q,
  `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_0_.Q
  };
`endif

`ifdef BEHAVIORAL
  assign wavegen_vif[1].wg_enable[0]      = (dut_vif.swap_sdf_en === 1'b1) ? `CHIP_2_WG_DRIVER_TOP.wg_driver_top_inst.genblk1[0].arb_wave_gen_inst.enable : `CHIP_1_WG_DRIVER_TOP.wg_driver_top_inst.genblk1[0].arb_wave_gen_inst.enable;
  assign wavegen_vif[1].wg_enable[1]      = (dut_vif.swap_sdf_en === 1'b1) ? `CHIP_2_WG_DRIVER_TOP.wg_driver_top_inst.genblk1[1].arb_wave_gen_inst.enable : `CHIP_1_WG_DRIVER_TOP.wg_driver_top_inst.genblk1[1].arb_wave_gen_inst.enable;
`else 
  assign wavegen_vif[1].wg_enable[0]      = (dut_vif.swap_sdf_en === 1'b1) ? `CHIP_2_WG_DRIVER_TOP.wg_driver_top_inst.genblk1_0__arb_wave_gen_inst.enable : `CHIP_1_WG_DRIVER_TOP.wg_driver_top_inst.genblk1_0__arb_wave_gen_inst.enable;
  assign wavegen_vif[1].wg_enable[1]      = (dut_vif.swap_sdf_en === 1'b1) ? `CHIP_2_WG_DRIVER_TOP.wg_driver_top_inst.genblk1_1__arb_wave_gen_inst.enable : `CHIP_1_WG_DRIVER_TOP.wg_driver_top_inst.genblk1_1__arb_wave_gen_inst.enable;
`endif

`ifdef BEHAVIORAL
  assign wavegen_vif[1].pulse_data[0] = (dut_vif.swap_sdf_en === 1'b1) ? `CHIP_2_SPI_WAVEGEN_REG_10.w_in_wave_tmp[7:0]         : `CHIP_1_SPI_WAVEGEN_REG_10.w_in_wave_tmp[7:0];
  assign wavegen_vif[1].tmp_pos[0]    = (dut_vif.swap_sdf_en === 1'b1) ? `CHIP_2_SPI_WAVEGEN_REG_10.boot_mul_wave_tmp_pos[7:0] : `CHIP_1_SPI_WAVEGEN_REG_10.boot_mul_wave_tmp_pos[7:0];
  assign wavegen_vif[1].tmp_neg[0]    = (dut_vif.swap_sdf_en === 1'b1) ? `CHIP_2_SPI_WAVEGEN_REG_10.boot_mul_wave_tmp_neg[7:0] : `CHIP_1_SPI_WAVEGEN_REG_10.boot_mul_wave_tmp_neg[7:0];
  assign wavegen_vif[1].pulse_data[1] = (dut_vif.swap_sdf_en === 1'b1) ? `CHIP_2_SPI_WAVEGEN_REG_11.w_in_wave_tmp[7:0]         : `CHIP_1_SPI_WAVEGEN_REG_11.w_in_wave_tmp[7:0];
  assign wavegen_vif[1].tmp_pos[1]    = (dut_vif.swap_sdf_en === 1'b1) ? `CHIP_2_SPI_WAVEGEN_REG_11.boot_mul_wave_tmp_pos[7:0] : `CHIP_1_SPI_WAVEGEN_REG_11.boot_mul_wave_tmp_pos[7:0];
  assign wavegen_vif[1].tmp_neg[1]    = (dut_vif.swap_sdf_en === 1'b1) ? `CHIP_2_SPI_WAVEGEN_REG_11.boot_mul_wave_tmp_neg[7:0] : `CHIP_1_SPI_WAVEGEN_REG_11.boot_mul_wave_tmp_neg[7:0];
  assign wavegen_vif[1].state[0]      = (dut_vif.swap_sdf_en === 1'b1) ? `CHIP_2_WG_DRIVER_TOP.wg_driver_top_inst.genblk1[0].arb_wave_gen_inst.state : `CHIP_1_WG_DRIVER_TOP.wg_driver_top_inst.genblk1[0].arb_wave_gen_inst.state;
  assign wavegen_vif[1].state[1]      = (dut_vif.swap_sdf_en === 1'b1) ? `CHIP_2_WG_DRIVER_TOP.wg_driver_top_inst.genblk1[1].arb_wave_gen_inst.state : `CHIP_1_WG_DRIVER_TOP.wg_driver_top_inst.genblk1[1].arb_wave_gen_inst.state;
`else // not checking in NETLIST
  assign wavegen_vif[1].pulse_data[0] = 'h0; 
  assign wavegen_vif[1].tmp_pos[0]    = 'h0;
  assign wavegen_vif[1].tmp_neg[0]    = 'h0;
  assign wavegen_vif[1].pulse_data[1] = 'h0; 
  assign wavegen_vif[1].tmp_pos[1]    = 'h0;
  assign wavegen_vif[1].tmp_neg[1]    = 'h0;
  assign wavegen_vif[1].state[0]    = 'h0;
  assign wavegen_vif[1].state[1]    = 'h0;
`endif

// Design a logic to capture DATAs for Driver B
always@(`CHIP_1_ANA_WRAPPER_TOP.i_out_wave_drivera_dac1)
    if(dut_vif.swap_sdf_en === 1'b0)begin
      wavegen_vif[1].wave_data_b = (other_chip_drive_ctrl_reg0_11[5] === 1'b0) ? ((other_chip_drive_ctrl_reg2_11[6:4] === 3'b000) ? `CHIP_1_ANA_WRAPPER_TOP.i_out_wave_drivera_dac1[11:4] : (other_chip_drive_ctrl_reg2_11[6:4] === 3'b001) ? `CHIP_1_ANA_WRAPPER_TOP.i_out_wave_drivera_dac1[10:3] : (other_chip_drive_ctrl_reg2_11[6:4] === 3'b010) ? `CHIP_1_ANA_WRAPPER_TOP.i_out_wave_drivera_dac1[9:2] : (other_chip_drive_ctrl_reg2_11[6:4] === 3'b011) ? `CHIP_1_ANA_WRAPPER_TOP.i_out_wave_drivera_dac1[8:1] : (other_chip_drive_ctrl_reg2_11[6:4] === 3'b100) ? `CHIP_1_ANA_WRAPPER_TOP.i_out_wave_drivera_dac1[7:0] : `CHIP_1_ANA_WRAPPER_TOP.i_out_wave_drivera_dac1[11:4]) : {other_chip_drive_ctrl_reg2_11[3:0], other_chip_drive_ctrl_reg1_11};
    end

always@(`CHIP_2_ANA_WRAPPER_TOP.i_out_wave_drivera_dac1)
    if(dut_vif.swap_sdf_en === 1'b1)begin
      wavegen_vif[1].wave_data_b = (other_chip_drive_ctrl_reg0_11[5] === 1'b0)?((other_chip_drive_ctrl_reg2_11[6:4] === 3'b000)?`CHIP_2_ANA_WRAPPER_TOP.i_out_wave_drivera_dac1[11:4] : (other_chip_drive_ctrl_reg2_11[6:4] === 3'b001)?`CHIP_2_ANA_WRAPPER_TOP.i_out_wave_drivera_dac1[10:3] : (other_chip_drive_ctrl_reg2_11[6:4] === 3'b010) ? `CHIP_2_ANA_WRAPPER_TOP.i_out_wave_drivera_dac1[9:2] : (other_chip_drive_ctrl_reg2_11[6:4] === 3'b011)?`CHIP_2_ANA_WRAPPER_TOP.i_out_wave_drivera_dac1[8:1] : (other_chip_drive_ctrl_reg2_11[6:4] === 3'b100)?`CHIP_2_ANA_WRAPPER_TOP.i_out_wave_drivera_dac1[7:0] : `CHIP_2_ANA_WRAPPER_TOP.i_out_wave_drivera_dac1[11:4]):{other_chip_drive_ctrl_reg2_11[3:0], other_chip_drive_ctrl_reg1_11};
    end

assign wavegen_vif[1].dacb_bit_len_sel = other_chip_drive_ctrl_reg0_11[5];
assign wavegen_vif[1].manual_mode[1] = other_chip_drive_ctrl_reg0_11[4];

assign wavegen_vif[1].spi_reg[1]         = {other_chip_drive_ctrl_reg2_11[3:0], other_chip_drive_ctrl_reg1_11};

assign wavegen_vif[1].ana_data[1]        = (dut_vif.swap_sdf_en === 1'b1)? `CHIP_2_ANA_WRAPPER_TOP.i_out_wave_drivera_dac1 : `CHIP_1_ANA_WRAPPER_TOP.i_out_wave_drivera_dac1;

`ifdef BEHAVIORAL
  assign wavegen_vif[1].wave_addr[0] = (dut_vif.swap_sdf_en === 1'b1)?`CHIP_2_WG_DRIVER_TOP.o_wg_driver_in_wave_addr[0] : `CHIP_1_WG_DRIVER_TOP.o_wg_driver_in_wave_addr[0];
  assign wavegen_vif[1].wave_addr[1] = (dut_vif.swap_sdf_en === 1'b1)?`CHIP_2_WG_DRIVER_TOP.o_wg_driver_in_wave_addr[1] : `CHIP_1_WG_DRIVER_TOP.o_wg_driver_in_wave_addr[1];
`else
//  assign wavegen_vif[1].wave_addr[0] = (dut_vif.swap_sdf_en === 1'b1)?`CHIP_2_SPI_WAVEGEN_REG_10.i_wg_driver_in_wave_addr[7:0] : `CHIP_1_SPI_WAVEGEN_REG_10.i_wg_driver_in_wave_addr[7:0];
/*  assign wavegen_vif[1].wave_addr[0] = (dut_vif.swap_sdf_en === 1'b1)?
                                     {`CHIP_2_SPI_WAVEGEN_REG_10.i_wg_driver_in_wave_addr_7_,
                                      `CHIP_2_SPI_WAVEGEN_REG_10.i_wg_driver_in_wave_addr_6_,
                                      !`CHIP_2_SPI_WAVEGEN_REG_10.i_wg_driver_in_wave_addr_5__BAR,
                                      `CHIP_2_SPI_WAVEGEN_REG_10.i_wg_driver_in_wave_addr_4_,
                                      `CHIP_2_SPI_WAVEGEN_REG_10.i_wg_driver_in_wave_addr_3_,
                                      `CHIP_2_SPI_WAVEGEN_REG_10.i_wg_driver_in_wave_addr_2_,
                                      `CHIP_2_SPI_WAVEGEN_REG_10.i_wg_driver_in_wave_addr_1_,
                                      `CHIP_2_SPI_WAVEGEN_REG_10.i_wg_driver_in_wave_addr_0_}
                                      :
	                             {`CHIP_1_SPI_WAVEGEN_REG_10.i_wg_driver_in_wave_addr_7_,
	                              `CHIP_1_SPI_WAVEGEN_REG_10.i_wg_driver_in_wave_addr_6_,
	                              !`CHIP_1_SPI_WAVEGEN_REG_10.i_wg_driver_in_wave_addr_5__BAR,
	                              `CHIP_1_SPI_WAVEGEN_REG_10.i_wg_driver_in_wave_addr_4_,
	                              `CHIP_1_SPI_WAVEGEN_REG_10.i_wg_driver_in_wave_addr_3_,
	                              `CHIP_1_SPI_WAVEGEN_REG_10.i_wg_driver_in_wave_addr_2_,
	                              `CHIP_1_SPI_WAVEGEN_REG_10.i_wg_driver_in_wave_addr_1_,
	                              `CHIP_1_SPI_WAVEGEN_REG_10.i_wg_driver_in_wave_addr_0_};

assign wavegen_vif[1].wave_addr[1] = (dut_vif.swap_sdf_en === 1'b1)?`CHIP_2_SPI_WAVEGEN_REG_11.i_wg_driver_in_wave_addr[7:0] : `CHIP_1_SPI_WAVEGEN_REG_11.i_wg_driver_in_wave_addr[7:0];
*/  assign wavegen_vif[1].wave_addr[0] = (dut_vif.swap_sdf_en === 1'b1)?`CHIP_2_WG_DRIVER_TOP.spi_wg_i_wg_driver_in_wave_addr[7:0] : `CHIP_1_WG_DRIVER_TOP.spi_wg_i_wg_driver_in_wave_addr[7:0];
    assign wavegen_vif[1].wave_addr[1] = (dut_vif.swap_sdf_en === 1'b1)?`CHIP_2_WG_DRIVER_TOP.spi_wg_i_wg_driver_in_wave_addr[15:8] : `CHIP_1_WG_DRIVER_TOP.spi_wg_i_wg_driver_in_wave_addr[15:8];
/*assign wavegen_vif[1].wave_addr[1] = (dut_vif.swap_sdf_en === 1'b1)?
                                     {`CHIP_2_SPI_WAVEGEN_REG_10.i_wg_driver_in_wave_addr_7_,
                                      `CHIP_2_SPI_WAVEGEN_REG_10.i_wg_driver_in_wave_addr_6_,
                                      !`CHIP_2_SPI_WAVEGEN_REG_10.i_wg_driver_in_wave_addr_5__BAR,
                                      `CHIP_2_SPI_WAVEGEN_REG_10.i_wg_driver_in_wave_addr_4_,
                                      `CHIP_2_SPI_WAVEGEN_REG_10.i_wg_driver_in_wave_addr_3_,
                                      `CHIP_2_SPI_WAVEGEN_REG_10.i_wg_driver_in_wave_addr_2_,
                                      `CHIP_2_SPI_WAVEGEN_REG_10.i_wg_driver_in_wave_addr_1_,
                                      `CHIP_2_SPI_WAVEGEN_REG_10.i_wg_driver_in_wave_addr_0_}
                                      : 
                                      {`CHIP_1_SPI_WAVEGEN_REG_10.i_wg_driver_in_wave_addr_7_,
                                      `CHIP_1_SPI_WAVEGEN_REG_10.i_wg_driver_in_wave_addr_6_,
                                      !`CHIP_1_SPI_WAVEGEN_REG_10.i_wg_driver_in_wave_addr_5__BAR,
                                      `CHIP_1_SPI_WAVEGEN_REG_10.i_wg_driver_in_wave_addr_4_,
                                      `CHIP_1_SPI_WAVEGEN_REG_10.i_wg_driver_in_wave_addr_3_,
                                      `CHIP_1_SPI_WAVEGEN_REG_10.i_wg_driver_in_wave_addr_2_,
                                      `CHIP_1_SPI_WAVEGEN_REG_10.i_wg_driver_in_wave_addr_1_,
                                      `CHIP_1_SPI_WAVEGEN_REG_10.i_wg_driver_in_wave_addr_0_};
*/
`endif

  //drv 0
  assign wavegen_vif[1].pulla[0]   = (dut_vif.swap_sdf_en === 1'b1)?`CHIP_2_ANA_WRAPPER_TOP.i_pullda_driver_a[0] :  `CHIP_1_ANA_WRAPPER_TOP.i_pullda_driver_a[0];
  assign wavegen_vif[1].pullb[0]   = (dut_vif.swap_sdf_en === 1'b1)?`CHIP_2_ANA_WRAPPER_TOP.i_pulldb_driver_a[0] : `CHIP_1_ANA_WRAPPER_TOP.i_pulldb_driver_a[0];
  assign wavegen_vif[1].sourcea[0] = (dut_vif.swap_sdf_en === 1'b1)?`CHIP_2_ANA_WRAPPER_TOP.i_sourcea_driver_a[0] : `CHIP_1_ANA_WRAPPER_TOP.i_sourcea_driver_a[0];
  assign wavegen_vif[1].sourceb[0] = (dut_vif.swap_sdf_en === 1'b1)?`CHIP_2_ANA_WRAPPER_TOP.i_sourceb_driver_a[0] : `CHIP_1_ANA_WRAPPER_TOP.i_sourceb_driver_a[0];
  
  //drv 1
  assign wavegen_vif[1].pulla[1]   = (dut_vif.swap_sdf_en === 1'b1)?`CHIP_2_ANA_WRAPPER_TOP.i_pullda_driver_a[1] :  `CHIP_1_ANA_WRAPPER_TOP.i_pullda_driver_a[1];
  assign wavegen_vif[1].pullb[1]   = (dut_vif.swap_sdf_en === 1'b1)?`CHIP_2_ANA_WRAPPER_TOP.i_pulldb_driver_a[1] : `CHIP_1_ANA_WRAPPER_TOP.i_pulldb_driver_a[1];
  assign wavegen_vif[1].sourcea[1] = (dut_vif.swap_sdf_en === 1'b1)?`CHIP_2_ANA_WRAPPER_TOP.i_sourcea_driver_a[1] : `CHIP_1_ANA_WRAPPER_TOP.i_sourcea_driver_a[1];
  assign wavegen_vif[1].sourceb[1] = (dut_vif.swap_sdf_en === 1'b1)?`CHIP_2_ANA_WRAPPER_TOP.i_sourceb_driver_a[1] : `CHIP_1_ANA_WRAPPER_TOP.i_sourceb_driver_a[1];
  
`ifdef BEHAVIORAL
  assign wavegen_vif[1].point_cfg_val[0] = (dut_vif.swap_sdf_en === 1'b1) ? 
                                        `CHIP_2_SPI_WAVEGEN_REG_10.o_reg_wg_driver_point_config : 
                                        `CHIP_1_SPI_WAVEGEN_REG_10.o_reg_wg_driver_point_config;

  assign wavegen_vif[1].point_cfg_val[1] = (dut_vif.swap_sdf_en === 1'b1) ? 
                                        `CHIP_2_SPI_WAVEGEN_REG_11.o_reg_wg_driver_point_config : 
                                        `CHIP_1_SPI_WAVEGEN_REG_11.o_reg_wg_driver_point_config;

  assign wavegen_vif[1].neg_ena[0]       = (dut_vif.swap_sdf_en === 1'b1) ? 
                                        `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_config[1] :
				        `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_config[1];

  assign wavegen_vif[1].pos_ena[0]       = (dut_vif.swap_sdf_en === 1'b1) ?
                                        `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_config[7] :
				        `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_config[7];

  assign wavegen_vif[1].neg_ena[1]       = (dut_vif.swap_sdf_en === 1'b1) ? 
                                        `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_config[1] :
				        `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_config[1];

  assign wavegen_vif[1].pos_ena[1]       = (dut_vif.swap_sdf_en === 1'b1) ?
                                        `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_config[7] :
				        `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_config[7];

  assign wavegen_vif[1].pos_neg[0]       = (dut_vif.swap_sdf_en === 1'b1) ?
                                        `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_config[3] :
				        `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_config[3];  

  assign wavegen_vif[1].pos_neg[1]       = (dut_vif.swap_sdf_en === 1'b1) ?
                                        `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_config[3] :
				        `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_config[3];  

  assign wavegen_vif[1].multi_electrode[0]       = (dut_vif.swap_sdf_en === 1'b1) ?
                                                 `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_config[6] :
				                 `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_config[6];  

  assign wavegen_vif[1].multi_electrode[1]       = (dut_vif.swap_sdf_en === 1'b1) ?
                                                 `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_config[6] :
				                 `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_config[6];  
`else
  assign wavegen_vif[1].point_cfg_val[0] =(dut_vif.swap_sdf_en === 1'b1) ?                                  
    {
    `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_point_config_reg_7_.Q,
    `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_point_config_reg_6_.Q,
    `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_point_config_reg_5_.Q,
    `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_point_config_reg_4_.Q,
    `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_point_config_reg_3_.Q,
    `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_point_config_reg_2_.Q,
    `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_point_config_reg_1_.Q,
    `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_point_config_reg_0_.Q
    }
  : 
    {
    `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_point_config_reg_7_.Q,
    `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_point_config_reg_6_.Q,
    `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_point_config_reg_5_.Q,
    `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_point_config_reg_4_.Q,
    `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_point_config_reg_3_.Q,
    `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_point_config_reg_2_.Q,
    `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_point_config_reg_1_.Q,
    `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_point_config_reg_0_.Q
    };

  assign wavegen_vif[1].point_cfg_val[1] =(dut_vif.swap_sdf_en === 1'b1) ?                                  
    {
    `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_point_config_reg_7_.Q,
    `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_point_config_reg_6_.Q,
    `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_point_config_reg_5_.Q,
    `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_point_config_reg_4_.Q,
    `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_point_config_reg_3_.Q,
    `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_point_config_reg_2_.Q,
    `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_point_config_reg_1_.Q,
    `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_point_config_reg_0_.Q
    }
  : 
    {
    `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_point_config_reg_7_.Q,
    `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_point_config_reg_6_.Q,
    `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_point_config_reg_5_.Q,
    `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_point_config_reg_4_.Q,
    `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_point_config_reg_3_.Q,
    `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_point_config_reg_2_.Q,
    `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_point_config_reg_1_.Q,
    `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_point_config_reg_0_.Q
    };

  assign wavegen_vif[1].neg_ena[0] = (dut_vif.swap_sdf_en === 1'b1) ? `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_config_reg_1_.Q : `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_config_reg_1_.Q;
  assign wavegen_vif[1].pos_ena[0] = (dut_vif.swap_sdf_en === 1'b1) ? `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_config_reg_7_.Q : `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_config_reg_7_.Q;
  assign wavegen_vif[1].pos_neg[0] = (dut_vif.swap_sdf_en === 1'b1) ? `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_config_reg_3_.Q : `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_config_reg_3_.Q;
  assign wavegen_vif[1].multi_electrode[0] = (dut_vif.swap_sdf_en === 1'b1) ? `CHIP_2_SPI_WAVEGEN_REG_10.reg_wg_driver_config_reg_6_.Q : `CHIP_1_SPI_WAVEGEN_REG_10.reg_wg_driver_config_reg_6_.Q;
  assign wavegen_vif[1].neg_ena[1] = (dut_vif.swap_sdf_en === 1'b1) ? `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_config_reg_1_.Q : `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_config_reg_1_.Q;
  assign wavegen_vif[1].pos_ena[1] = (dut_vif.swap_sdf_en === 1'b1) ? `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_config_reg_7_.Q : `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_config_reg_7_.Q;
  assign wavegen_vif[1].pos_neg[1] = (dut_vif.swap_sdf_en === 1'b1) ? `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_config_reg_3_.Q : `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_config_reg_3_.Q;
  assign wavegen_vif[1].multi_electrode[1] = (dut_vif.swap_sdf_en === 1'b1) ? `CHIP_2_SPI_WAVEGEN_REG_11.reg_wg_driver_config_reg_6_.Q : `CHIP_1_SPI_WAVEGEN_REG_11.reg_wg_driver_config_reg_6_.Q;

`endif

//initial begin
//    nnc_config_db#(virtual nnc_wavegen_interface)::set(uvm_root::get(), "uvm_test_top.*", "wavegen_vif[1]", wavegen_vif[1]);
//end


assign wavegen_vif[1].hex_data_a                 = dut_vif.hex_data_a;  
assign wavegen_vif[1].hex_data_b                 = dut_vif.hex_data_b;  
assign wavegen_vif[1].no_of_point_a              = dut_vif.no_of_point_a;
assign wavegen_vif[1].no_of_point_b              = dut_vif.no_of_point_b;
assign wavegen_vif[1].pos_neg_from_same_addr     = dut_vif.pos_neg_from_same_addr;    
assign wavegen_vif[1].load_wave_data_till_points = dut_vif.load_wave_data_till_points;    
assign wavegen_vif[1].no_of_waveforms            = dut_vif.no_of_waveforms;    
assign wavegen_vif[1].preload_sel                = dut_vif.preload_sel; 
//assign wavegen_vif[1].stop_check[0]                 = dut_vif.stop_check[0];
//assign wavegen_vif[1].stop_check[1]                 = dut_vif.stop_check[1];
assign wavegen_vif[1].scale_en                   = dut_vif.scale_en;
assign wavegen_vif[1].noperiod                   = dut_vif.noperiod;
assign wavegen_vif[1].noperiod_pos_neg_sel         = dut_vif.noperiod_pos_neg_sel;
assign wavegen_vif[1].swap_sdf_en                = dut_vif.swap_sdf_en;
assign wavegen_vif[1].mult_chip_same_clk_en      = dut_vif.mult_chip_same_clk_en;
assign wavegen_vif[1].PULLAB_pos_en              = dut_vif.PULLAB_pos_en;
assign wavegen_vif[1].PULLAB_neg_en              = dut_vif.PULLAB_neg_en;
assign wavegen_vif[1].PULLAB_lim                 = dut_vif.PULLAB_lim;

assign wavegen_vif[1].wg_hlf_wave0_lim[0]     = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_hlf_wave0_lim[0];
assign wavegen_vif[1].wg_hlf_wave0_lim[1]     = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_hlf_wave0_lim[1];
assign wavegen_vif[1].wg_neg_hlf_wave0_lim[0] = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_neg_hlf_wave0_lim[0];
assign wavegen_vif[1].wg_neg_hlf_wave0_lim[1] = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_neg_hlf_wave0_lim[1];
assign wavegen_vif[1].wg_hlf_wave1_lim[0]     = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_hlf_wave1_lim[0];
assign wavegen_vif[1].wg_hlf_wave1_lim[1]     = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_hlf_wave1_lim[1];
assign wavegen_vif[1].wg_neg_hlf_wave1_lim[0] = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_neg_hlf_wave1_lim[0];
assign wavegen_vif[1].wg_neg_hlf_wave1_lim[1] = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_neg_hlf_wave1_lim[1];
assign wavegen_vif[1].wg_hlf_wave2_lim[0]     = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_hlf_wave2_lim[0];
assign wavegen_vif[1].wg_hlf_wave2_lim[1]     = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_hlf_wave2_lim[1];
assign wavegen_vif[1].wg_neg_hlf_wave2_lim[0] = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_neg_hlf_wave2_lim[0];
assign wavegen_vif[1].wg_neg_hlf_wave2_lim[1] = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_neg_hlf_wave2_lim[1];

assign wavegen_vif[1].wg_rest_wave0_lim[0]   = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_rest_wave0_lim[0];
assign wavegen_vif[1].wg_rest_wave0_lim[1]   = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_rest_wave0_lim[1];
assign wavegen_vif[1].wg_silent_wave0_lim[0] = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_silent_wave0_lim[0];
assign wavegen_vif[1].wg_silent_wave0_lim[1] = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_silent_wave0_lim[1];
assign wavegen_vif[1].wg_rest_wave1_lim[0]   = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_rest_wave1_lim[0];
assign wavegen_vif[1].wg_rest_wave1_lim[1]   = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_rest_wave1_lim[1];
assign wavegen_vif[1].wg_silent_wave1_lim[0] = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_silent_wave1_lim[0];
assign wavegen_vif[1].wg_silent_wave1_lim[1] = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_silent_wave1_lim[1];
assign wavegen_vif[1].wg_rest_wave2_lim[0]   = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_rest_wave2_lim[0];
assign wavegen_vif[1].wg_rest_wave2_lim[1]   = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_rest_wave2_lim[1];
assign wavegen_vif[1].wg_silent_wave2_lim[0] = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_silent_wave2_lim[0];
assign wavegen_vif[1].wg_silent_wave2_lim[1] = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_silent_wave2_lim[1];

assign wavegen_vif[1].mult_chip_en               = dut_vif.mult_chip_en;
assign wavegen_vif[1].master_chip_wave1          = `SOC_TB.master_chip_wave1;
assign wavegen_vif[1].master_chip_wave2          = `SOC_TB.master_chip_wave2;
assign wavegen_vif[1].slave_chip_wave1           = `SOC_TB.slave_chip_wave1;
assign wavegen_vif[1].slave_chip_wave2           = `SOC_TB.slave_chip_wave2;
assign wavegen_vif[1].pclk                       = (dut_vif.swap_sdf_en === 1'b1) ? `CHIP_2_WG_DRIVER_TOP.i_pclk : `CHIP_1_WG_DRIVER_TOP.i_pclk;

//moved this check to wavegen monitor
/*
  always @(`SOC_TB.master_chip_wave1 or `SOC_TB.master_chip_wave2 or `SOC_TB.slave_chip_wave1 or `SOC_TB.slave_chip_wave2) begin
`ifdef POSTSCAN_PG
    if (wavegen_vif[1].swap_sdf_en === 1'b1) begin
      #20ns;  
    end
`elsif POSTLAYOUT_PG
    if (wavegen_vif[1].swap_sdf_en === 1'b1) begin
      #20ns;
    end
`endif
    if((`SOC_TB.master_chip_wave1 !== `SOC_TB.slave_chip_wave1) && (wavegen_vif[1].mult_chip_en === 1'b1))
	`nnc_error("SOC_TEST", "master & slave chip driver 0 wave mismatch error!!!")
    if((`SOC_TB.master_chip_wave2 !== `SOC_TB.slave_chip_wave2) && (wavegen_vif[1].mult_chip_en === 1'b1))
	`nnc_error("SOC_TEST", "master & slave chip driver 1 wave mismatch error!!!")
  end
*/
