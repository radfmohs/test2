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
`define SPI_REG soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_spi_top.spi_reg_u

nnc_wavegen_interface     wavegen_vif[`WAVEGEN_NUM_OF_MULT_CHIPS]();

//`ifdef BEHAVIORAL
//  `define SPI_WAVEGEN_REG_10 `SPI_REG.genblk1[0].u_spi_reg_wavegen
//  `define SPI_WAVEGEN_REG_11 `SPI_REG.genblk1[1].u_spi_reg_wavegen
//  wire [7:0] drive_ctrl_reg0_10 = `SPI_WAVEGEN_REG_10.drive_ctrl_reg0[7:0];
//  wire [7:0] drive_ctrl_reg1_10 = `SPI_WAVEGEN_REG_10.drive_ctrl_reg1[7:0]; 
//  wire [7:0] drive_ctrl_reg2_10 = `SPI_WAVEGEN_REG_10.drive_ctrl_reg2[7:0]; 
//  wire [7:0] drive_ctrl_reg0_11 = `SPI_WAVEGEN_REG_11.drive_ctrl_reg0[7:0];
//  wire [7:0] drive_ctrl_reg1_11 = `SPI_WAVEGEN_REG_11.drive_ctrl_reg1[7:0]; 
//  wire [7:0] drive_ctrl_reg2_11 = `SPI_WAVEGEN_REG_11.drive_ctrl_reg2[7:0];
//`else
//  `define SPI_WAVEGEN_REG_10 `SPI_REG.genblk1_0__u_spi_reg_wavegen
//  `define SPI_WAVEGEN_REG_11 `SPI_REG.genblk1_1__u_spi_reg_wavegen
//
//  wire [7:0] drive_ctrl_reg0_10 = {
//    `SPI_WAVEGEN_REG_10.drive_ctrl_reg0_reg_7_.Q, 
//    `SPI_WAVEGEN_REG_10.drive_ctrl_reg0_reg_6_.Q, 
//    `SPI_WAVEGEN_REG_10.drive_ctrl_reg0_reg_5_.Q, 
//    `SPI_WAVEGEN_REG_10.drive_ctrl_reg0_reg_4_.Q, 
//    `SPI_WAVEGEN_REG_10.drive_ctrl_reg0_reg_3_.Q, 
//    `SPI_WAVEGEN_REG_10.drive_ctrl_reg0_reg_2_.Q, 
//    `SPI_WAVEGEN_REG_10.drive_ctrl_reg0_reg_1_.Q, 
//    `SPI_WAVEGEN_REG_10.drive_ctrl_reg0_reg_0_.Q
//  };
//
//  wire [7:0] drive_ctrl_reg1_10 = {
//    `SPI_WAVEGEN_REG_10.drive_ctrl_reg1_reg_7_.Q, 
//    `SPI_WAVEGEN_REG_10.drive_ctrl_reg1_reg_6_.Q, 
//    `SPI_WAVEGEN_REG_10.drive_ctrl_reg1_reg_5_.Q, 
//    `SPI_WAVEGEN_REG_10.drive_ctrl_reg1_reg_4_.Q, 
//    `SPI_WAVEGEN_REG_10.drive_ctrl_reg1_reg_3_.Q, 
//    `SPI_WAVEGEN_REG_10.drive_ctrl_reg1_reg_2_.Q, 
//    `SPI_WAVEGEN_REG_10.drive_ctrl_reg1_reg_1_.Q, 
//    `SPI_WAVEGEN_REG_10.drive_ctrl_reg1_reg_0_.Q
//  };
//
//  wire [7:0] drive_ctrl_reg2_10 = {
//    `SPI_WAVEGEN_REG_10.drive_ctrl_reg2_reg_7_.Q, 
//    `SPI_WAVEGEN_REG_10.drive_ctrl_reg2_reg_6_.Q, 
//    `SPI_WAVEGEN_REG_10.drive_ctrl_reg2_reg_5_.Q, 
//    `SPI_WAVEGEN_REG_10.drive_ctrl_reg2_reg_4_.Q, 
//    `SPI_WAVEGEN_REG_10.drive_ctrl_reg2_reg_3_.Q, 
//    `SPI_WAVEGEN_REG_10.drive_ctrl_reg2_reg_2_.Q, 
//    `SPI_WAVEGEN_REG_10.drive_ctrl_reg2_reg_1_.Q, 
//    `SPI_WAVEGEN_REG_10.drive_ctrl_reg2_reg_0_.Q
//  };
//
//  wire [7:0] drive_ctrl_reg0_11 = {
//    `SPI_WAVEGEN_REG_11.drive_ctrl_reg0_reg_7_.Q, 
//    `SPI_WAVEGEN_REG_11.drive_ctrl_reg0_reg_6_.Q, 
//    `SPI_WAVEGEN_REG_11.drive_ctrl_reg0_reg_5_.Q, 
//    `SPI_WAVEGEN_REG_11.drive_ctrl_reg0_reg_4_.Q, 
//    `SPI_WAVEGEN_REG_11.drive_ctrl_reg0_reg_3_.Q, 
//    `SPI_WAVEGEN_REG_11.drive_ctrl_reg0_reg_2_.Q, 
//    `SPI_WAVEGEN_REG_11.drive_ctrl_reg0_reg_1_.Q, 
//    `SPI_WAVEGEN_REG_11.drive_ctrl_reg0_reg_0_.Q
//  };
//
//  wire [7:0] drive_ctrl_reg1_11 = {
//    `SPI_WAVEGEN_REG_11.drive_ctrl_reg1_reg_7_.Q, 
//    `SPI_WAVEGEN_REG_11.drive_ctrl_reg1_reg_6_.Q, 
//    `SPI_WAVEGEN_REG_11.drive_ctrl_reg1_reg_5_.Q, 
//    `SPI_WAVEGEN_REG_11.drive_ctrl_reg1_reg_4_.Q, 
//    `SPI_WAVEGEN_REG_11.drive_ctrl_reg1_reg_3_.Q, 
//    `SPI_WAVEGEN_REG_11.drive_ctrl_reg1_reg_2_.Q, 
//    `SPI_WAVEGEN_REG_11.drive_ctrl_reg1_reg_1_.Q, 
//    `SPI_WAVEGEN_REG_11.drive_ctrl_reg1_reg_0_.Q
//  };
//
//  wire [7:0] drive_ctrl_reg2_11 = {
//    `SPI_WAVEGEN_REG_11.drive_ctrl_reg2_reg_7_.Q, 
//    `SPI_WAVEGEN_REG_11.drive_ctrl_reg2_reg_6_.Q, 
//    `SPI_WAVEGEN_REG_11.drive_ctrl_reg2_reg_5_.Q, 
//    `SPI_WAVEGEN_REG_11.drive_ctrl_reg2_reg_4_.Q, 
//    `SPI_WAVEGEN_REG_11.drive_ctrl_reg2_reg_3_.Q, 
//    `SPI_WAVEGEN_REG_11.drive_ctrl_reg2_reg_2_.Q, 
//    `SPI_WAVEGEN_REG_11.drive_ctrl_reg2_reg_1_.Q, 
//    `SPI_WAVEGEN_REG_11.drive_ctrl_reg2_reg_0_.Q
//  };
//`endif
//
//always@(`ANA_WRAPPER_TOP.i_out_wave_drivera_dac0)
//    begin
//        wavegen_vif[0].wave_data_a = (drive_ctrl_reg0_10[5] === 1'b0) ? ((drive_ctrl_reg2_10[6:4] === 3'b000) ? `ANA_WRAPPER_TOP.i_out_wave_drivera_dac0[11:4] : (drive_ctrl_reg2_10[6:4] === 3'b001)?`ANA_WRAPPER_TOP.i_out_wave_drivera_dac0[10:3] : (drive_ctrl_reg2_10[6:4] === 3'b010) ? `ANA_WRAPPER_TOP.i_out_wave_drivera_dac0[9:2] : (drive_ctrl_reg2_10[6:4] === 3'b011) ?`ANA_WRAPPER_TOP.i_out_wave_drivera_dac0[8:1] : (drive_ctrl_reg2_10[6:4] === 3'b100)?`ANA_WRAPPER_TOP.i_out_wave_drivera_dac0[7:0] : `ANA_WRAPPER_TOP.i_out_wave_drivera_dac0[11:4]) : {drive_ctrl_reg2_10[3:0], drive_ctrl_reg1_10};
//        wavegen_vif[0].bitsel = drive_ctrl_reg2_10[6:4];
//    end
//
//assign wavegen_vif[0].daca_bit_len_sel = drive_ctrl_reg0_10[5];
//assign wavegen_vif[0].manual_mode[0]      = drive_ctrl_reg0_10[4];
//assign wavegen_vif[0].spi_reg[0]         = {drive_ctrl_reg2_10[3:0], drive_ctrl_reg1_10};
//assign wavegen_vif[0].ana_data[0]        = `ANA_WRAPPER_TOP.i_out_wave_drivera_dac0;
//
////`ifndef POSTSCAN
//`ifdef BEHAVIORAL
//  assign wavegen_vif[0].neg_scale[0] = `SPI_WAVEGEN_REG_10.reg_wg_driver_neg_scale;
//  assign wavegen_vif[0].pos_scale[0] = `SPI_WAVEGEN_REG_10.reg_wg_driver_isel;
//  //`ifndef POSTSCAN_PG 
//  assign wavegen_vif[0].neg_scale[1] = `SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale;
//  //`else
//  /*
//  assign wavegen_vif[0].neg_scale[1] = {
//    `SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_6_.Q,
//    `SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_5_.Q,
//    `SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_4_.Q,
//    `SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_3_.Q,
//    `SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_2_.Q,
//    `SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_1_.Q,
//    `SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_0_.Q
//  };
//  `endif
//  */
//  assign wavegen_vif[0].pos_scale[1] = `SPI_WAVEGEN_REG_11.reg_wg_driver_isel;
//`else
//  assign wavegen_vif[0].neg_scale[0] = {
//    `SPI_WAVEGEN_REG_10.reg_wg_driver_neg_scale_reg_6_.Q,
//    `SPI_WAVEGEN_REG_10.reg_wg_driver_neg_scale_reg_5_.Q,
//    `SPI_WAVEGEN_REG_10.reg_wg_driver_neg_scale_reg_4_.Q,
//    `SPI_WAVEGEN_REG_10.reg_wg_driver_neg_scale_reg_3_.Q,
//    `SPI_WAVEGEN_REG_10.reg_wg_driver_neg_scale_reg_2_.Q,
//    `SPI_WAVEGEN_REG_10.reg_wg_driver_neg_scale_reg_1_.Q,
//    `SPI_WAVEGEN_REG_10.reg_wg_driver_neg_scale_reg_0_.Q
//  };
//  assign wavegen_vif[0].pos_scale[0] = {
//    `SPI_WAVEGEN_REG_10.reg_wg_driver_isel_reg_7_.Q,
//    `SPI_WAVEGEN_REG_10.reg_wg_driver_isel_reg_6_.Q,
//    `SPI_WAVEGEN_REG_10.reg_wg_driver_isel_reg_5_.Q,
//    `SPI_WAVEGEN_REG_10.reg_wg_driver_isel_reg_4_.Q,
//    `SPI_WAVEGEN_REG_10.reg_wg_driver_isel_reg_3_.Q,
//    `SPI_WAVEGEN_REG_10.reg_wg_driver_isel_reg_2_.Q,
//    `SPI_WAVEGEN_REG_10.reg_wg_driver_isel_reg_1_.Q,
//    `SPI_WAVEGEN_REG_10.reg_wg_driver_isel_reg_0_.Q
//  };
//  assign wavegen_vif[0].neg_scale[1] = {
//    `SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_6_.Q,
//    `SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_5_.Q,
//    `SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_4_.Q,
//    `SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_3_.Q,
//    `SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_2_.Q,
//    `SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_1_.Q,
//    `SPI_WAVEGEN_REG_11.reg_wg_driver_neg_scale_reg_0_.Q
//  };
//  assign wavegen_vif[0].pos_scale[1] = {
//    `SPI_WAVEGEN_REG_11.reg_wg_driver_isel_reg_7_.Q,
//    `SPI_WAVEGEN_REG_11.reg_wg_driver_isel_reg_6_.Q,
//    `SPI_WAVEGEN_REG_11.reg_wg_driver_isel_reg_5_.Q,
//    `SPI_WAVEGEN_REG_11.reg_wg_driver_isel_reg_4_.Q,
//    `SPI_WAVEGEN_REG_11.reg_wg_driver_isel_reg_3_.Q,
//    `SPI_WAVEGEN_REG_11.reg_wg_driver_isel_reg_2_.Q,
//    `SPI_WAVEGEN_REG_11.reg_wg_driver_isel_reg_1_.Q,
//    `SPI_WAVEGEN_REG_11.reg_wg_driver_isel_reg_0_.Q
//  };
//`endif
//
//assign wavegen_vif[0].neg_offset[0] = 
//`ifndef POSTSCAN
//  `ifdef POSTLAYOUT_PG
//  {
//  `SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_7_.Q,
//  `SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_6_.Q,
//  `SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_5_.Q,
//  `SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_4_.Q,
//  `SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_3_.Q,
//  `SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_2_.Q,
//  `SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_1_.Q,
//  `SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_0_.Q                               
//  };
//  `else
//  `SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset;
//  `endif
//`else
//{
//  `SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_7_.Q,
//  `SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_6_.Q,
//  `SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_5_.Q,
//  `SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_4_.Q,
//  `SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_3_.Q,
//  `SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_2_.Q,
//  `SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_1_.Q,
//  `SPI_WAVEGEN_REG_10.reg_wg_driver_neg_offset_reg_0_.Q                               
//};
//`endif
//
//assign wavegen_vif[0].pos_offset[0] = 
////`ifndef POSTSCAN
//  `ifndef BEHAVIORAL // POSTLAYOUT_PG
//   {
//  `SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_7_.Q,
//  `SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_6_.Q,
//  `SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_5_.Q,
//  `SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_4_.Q,
//  `SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_3_.Q,
//  `SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_2_.Q,
//  `SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_1_.Q,
//  `SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_0_.Q
//   };
//  `else
//  `SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset;
//  `endif
////`else
////{
////  `SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_7_.Q,
////  `SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_6_.Q,
////  `SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_5_.Q,
////  `SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_4_.Q,
////  `SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_3_.Q,
////  `SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_2_.Q,
////  `SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_1_.Q,
////  `SPI_WAVEGEN_REG_10.reg_wg_driver_pos_offset_reg_0_.Q
////};
////`endif
//
//assign wavegen_vif[0].neg_offset[1] = 
////`ifndef POSTSCAN
//`ifdef BEHAVIORAL
//  `SPI_WAVEGEN_REG_11.reg_wg_driver_neg_offset;
//`else
//{
//  `SPI_WAVEGEN_REG_11.reg_wg_driver_neg_offset_reg_7_.Q,
//  `SPI_WAVEGEN_REG_11.reg_wg_driver_neg_offset_reg_6_.Q,
//  `SPI_WAVEGEN_REG_11.reg_wg_driver_neg_offset_reg_5_.Q,
//  `SPI_WAVEGEN_REG_11.reg_wg_driver_neg_offset_reg_4_.Q,
//  `SPI_WAVEGEN_REG_11.reg_wg_driver_neg_offset_reg_3_.Q,
//  `SPI_WAVEGEN_REG_11.reg_wg_driver_neg_offset_reg_2_.Q,
//  `SPI_WAVEGEN_REG_11.reg_wg_driver_neg_offset_reg_1_.Q,
//  `SPI_WAVEGEN_REG_11.reg_wg_driver_neg_offset_reg_0_.Q                               
//};
//`endif
//
//assign wavegen_vif[0].pos_offset[1] = 
//`ifdef BEHAVIORAL
//  `SPI_WAVEGEN_REG_11.reg_wg_driver_pos_offset;
//`else
//{
//  `SPI_WAVEGEN_REG_11.reg_wg_driver_pos_offset_reg_7_.Q,
//  `SPI_WAVEGEN_REG_11.reg_wg_driver_pos_offset_reg_6_.Q,
//  `SPI_WAVEGEN_REG_11.reg_wg_driver_pos_offset_reg_5_.Q,
//  `SPI_WAVEGEN_REG_11.reg_wg_driver_pos_offset_reg_4_.Q,
//  `SPI_WAVEGEN_REG_11.reg_wg_driver_pos_offset_reg_3_.Q,
//  `SPI_WAVEGEN_REG_11.reg_wg_driver_pos_offset_reg_2_.Q,
//  `SPI_WAVEGEN_REG_11.reg_wg_driver_pos_offset_reg_1_.Q,
//  `SPI_WAVEGEN_REG_11.reg_wg_driver_pos_offset_reg_0_.Q
//};
//`endif
//
//assign wavegen_vif[0].delay_lim[0] =  
//`ifdef BEHAVIORAL
//`SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim[15:0];
//`else
//{
//`SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_15_.Q,
//`SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_14_.Q,
//`SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_13_.Q,
//`SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_12_.Q,
//`SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_11_.Q,
//`SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_10_.Q,
//`SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_9_.Q,
//`SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_8_.Q,
//`SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_7_.Q,
//`SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_6_.Q,
//`SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_5_.Q,
//`SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_4_.Q,
//`SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_3_.Q,
//`SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_2_.Q,
//`SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_1_.Q,
//`SPI_WAVEGEN_REG_10.reg_wg_driver_delay_lim_reg_0_.Q
//};
//`endif
//
//assign wavegen_vif[0].delay_lim[1] =  
//`ifdef BEHAVIORAL
//`SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim[15:0];
//`else
//{
//`SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_15_.Q,
//`SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_14_.Q,
//`SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_13_.Q,
//`SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_12_.Q,
//`SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_11_.Q,
//`SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_10_.Q,
//`SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_9_.Q,
//`SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_8_.Q,
//`SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_7_.Q,
//`SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_6_.Q,
//`SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_5_.Q,
//`SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_4_.Q,
//`SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_3_.Q,
//`SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_2_.Q,
//`SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_1_.Q,
//`SPI_WAVEGEN_REG_11.reg_wg_driver_delay_lim_reg_0_.Q
//};
//`endif
//
//`ifdef BEHAVIORAL
//  assign wavegen_vif[0].wg_enable[0]      = `WG_DRIVER_TOP.wg_driver_top_inst.genblk1[0].arb_wave_gen_inst.enable;
//  assign wavegen_vif[0].wg_enable[1]      = `WG_DRIVER_TOP.wg_driver_top_inst.genblk1[1].arb_wave_gen_inst.enable;
//`else 
//  assign wavegen_vif[0].wg_enable[0]      = `WG_DRIVER_TOP.wg_driver_top_inst.genblk1_0__arb_wave_gen_inst.enable;
//  assign wavegen_vif[0].wg_enable[1]      = `WG_DRIVER_TOP.wg_driver_top_inst.genblk1_1__arb_wave_gen_inst.enable;
//`endif
//
//`ifdef BEHAVIORAL
//  assign wavegen_vif[0].pulse_data[0] = `SPI_WAVEGEN_REG_10.w_in_wave_tmp[7:0];
//  assign wavegen_vif[0].tmp_pos[0]    = `SPI_WAVEGEN_REG_10.boot_mul_wave_tmp_pos[7:0];
//  assign wavegen_vif[0].tmp_neg[0]    = `SPI_WAVEGEN_REG_10.boot_mul_wave_tmp_neg[7:0];
//  assign wavegen_vif[0].pulse_data[1] = `SPI_WAVEGEN_REG_11.w_in_wave_tmp[7:0];
//  assign wavegen_vif[0].tmp_pos[1]    = `SPI_WAVEGEN_REG_11.boot_mul_wave_tmp_pos[7:0];
//  assign wavegen_vif[0].tmp_neg[1]    = `SPI_WAVEGEN_REG_11.boot_mul_wave_tmp_neg[7:0];
//  assign wavegen_vif[0].state[0]      = `WG_DRIVER_TOP.wg_driver_top_inst.genblk1[0].arb_wave_gen_inst.state;
//  assign wavegen_vif[0].state[1]      = `WG_DRIVER_TOP.wg_driver_top_inst.genblk1[1].arb_wave_gen_inst.state;
//`else // not checking in NETLIST
//  assign wavegen_vif[0].pulse_data[0] = 'h0; 
//  assign wavegen_vif[0].tmp_pos[0]    = 'h0;
//  assign wavegen_vif[0].tmp_neg[0]    = 'h0;
//  assign wavegen_vif[0].pulse_data[1] = 'h0; 
//  assign wavegen_vif[0].tmp_pos[1]    = 'h0;
//  assign wavegen_vif[0].tmp_neg[1]    = 'h0;
//  assign wavegen_vif[0].state[0]    = 'h0;
//  assign wavegen_vif[0].state[1]    = 'h0;
//`endif
//
//// Design a logic to capture DATAs for Driver B
//always@(`ANA_WRAPPER_TOP.i_out_wave_drivera_dac1)
//    begin
//      wavegen_vif[0].wave_data_b = (drive_ctrl_reg0_11[5] === 1'b0)?((drive_ctrl_reg2_11[6:4] === 3'b000)?`ANA_WRAPPER_TOP.i_out_wave_drivera_dac1[11:4] : (drive_ctrl_reg2_11[6:4] === 3'b001)?`ANA_WRAPPER_TOP.i_out_wave_drivera_dac1[10:3] : (drive_ctrl_reg2_11[6:4] === 3'b010)?`ANA_WRAPPER_TOP.i_out_wave_drivera_dac1[9:2] : (drive_ctrl_reg2_11[6:4] === 3'b011)?`ANA_WRAPPER_TOP.i_out_wave_drivera_dac1[8:1] : (drive_ctrl_reg2_11[6:4] === 3'b100)?`ANA_WRAPPER_TOP.i_out_wave_drivera_dac1[7:0] : `ANA_WRAPPER_TOP.i_out_wave_drivera_dac1[11:4]):{drive_ctrl_reg2_11[3:0],drive_ctrl_reg1_11};
//    end
//assign wavegen_vif[0].dacb_bit_len_sel = drive_ctrl_reg0_11[5];
//assign wavegen_vif[0].manual_mode[1]      = drive_ctrl_reg0_11[4];
//assign wavegen_vif[0].spi_reg[1] = {drive_ctrl_reg2_11[3:0], drive_ctrl_reg1_11};
//assign wavegen_vif[0].ana_data[1] = `ANA_WRAPPER_TOP.i_out_wave_drivera_dac1;
//
`ifdef BEHAVIORAL
  assign wavegen_vif[0].wave_addr[0] = `WG_DRIVER_TOP.o_wg_driver_in_wave_addr[0];
  assign wavegen_vif[0].wave_addr[1] = `WG_DRIVER_TOP.o_wg_driver_in_wave_addr[1];
`else
  assign wavegen_vif[0].wave_addr[0] = `WG_DRIVER_TOP.spi_wg_i_wg_driver_in_wave_addr[7:0];
  assign wavegen_vif[0].wave_addr[1] = `WG_DRIVER_TOP.spi_wg_i_wg_driver_in_wave_addr[15:8];
`endif
//
//  //drv 0
//  assign wavegen_vif[0].pulla[0] = `ANA_WRAPPER_TOP.i_pullda_driver_a[0];
//  assign wavegen_vif[0].pullb[0] = `ANA_WRAPPER_TOP.i_pulldb_driver_a[0];
//  assign wavegen_vif[0].sourcea[0] = `ANA_WRAPPER_TOP.i_sourcea_driver_a[0];
//  assign wavegen_vif[0].sourceb[0] = `ANA_WRAPPER_TOP.i_sourceb_driver_a[0];
//  //drv 1
//  assign wavegen_vif[0].pulla[1] = `ANA_WRAPPER_TOP.i_pullda_driver_a[1];
//  assign wavegen_vif[0].pullb[1] = `ANA_WRAPPER_TOP.i_pulldb_driver_a[1];
//  assign wavegen_vif[0].sourcea[1] = `ANA_WRAPPER_TOP.i_sourcea_driver_a[1];
//  assign wavegen_vif[0].sourceb[1] = `ANA_WRAPPER_TOP.i_sourceb_driver_a[1];
//  
//`ifdef BEHAVIORAL
//  assign wavegen_vif[0].point_cfg_val[0] = `SPI_TOP.spi_reg_u.genblk1[0].u_spi_reg_wavegen.o_reg_wg_driver_point_config;
//  assign wavegen_vif[0].point_cfg_val[1] = `SPI_TOP.spi_reg_u.genblk1[1].u_spi_reg_wavegen.o_reg_wg_driver_point_config;
//  assign wavegen_vif[0].neg_ena[0] = `SPI_TOP.spi_reg_u.genblk1[0].u_spi_reg_wavegen.reg_wg_driver_config[1];
//  assign wavegen_vif[0].pos_ena[0] = `SPI_TOP.spi_reg_u.genblk1[0].u_spi_reg_wavegen.reg_wg_driver_config[7];
//  assign wavegen_vif[0].neg_ena[1] = `SPI_TOP.spi_reg_u.genblk1[1].u_spi_reg_wavegen.reg_wg_driver_config[1];
//  assign wavegen_vif[0].pos_ena[1] = `SPI_TOP.spi_reg_u.genblk1[1].u_spi_reg_wavegen.reg_wg_driver_config[7];
//  assign wavegen_vif[0].pos_neg[0] = `SPI_TOP.spi_reg_u.genblk1[0].u_spi_reg_wavegen.reg_wg_driver_config[3];  
//  assign wavegen_vif[0].pos_neg[1] = `SPI_TOP.spi_reg_u.genblk1[1].u_spi_reg_wavegen.reg_wg_driver_config[3];  
//  assign wavegen_vif[0].multi_electrode[0] = `SPI_TOP.spi_reg_u.genblk1[0].u_spi_reg_wavegen.reg_wg_driver_config[6];  
//  assign wavegen_vif[0].multi_electrode[1] = `SPI_TOP.spi_reg_u.genblk1[1].u_spi_reg_wavegen.reg_wg_driver_config[6];  
//`else
//  assign wavegen_vif[0].point_cfg_val[0] = {`SPI_WAVEGEN_REG_10.reg_wg_driver_point_config_reg_7_.Q,`SPI_WAVEGEN_REG_10.reg_wg_driver_point_config_reg_6_.Q,`SPI_WAVEGEN_REG_10.reg_wg_driver_point_config_reg_5_.Q,`SPI_WAVEGEN_REG_10.reg_wg_driver_point_config_reg_4_.Q,`SPI_WAVEGEN_REG_10.reg_wg_driver_point_config_reg_3_.Q,`SPI_WAVEGEN_REG_10.reg_wg_driver_point_config_reg_2_.Q,`SPI_WAVEGEN_REG_10.reg_wg_driver_point_config_reg_1_.Q,`SPI_WAVEGEN_REG_10.reg_wg_driver_point_config_reg_0_.Q};
//  assign wavegen_vif[0].point_cfg_val[1] = {`SPI_WAVEGEN_REG_11.reg_wg_driver_point_config_reg_7_.Q,`SPI_WAVEGEN_REG_11.reg_wg_driver_point_config_reg_6_.Q,`SPI_WAVEGEN_REG_11.reg_wg_driver_point_config_reg_5_.Q,`SPI_WAVEGEN_REG_11.reg_wg_driver_point_config_reg_4_.Q,`SPI_WAVEGEN_REG_11.reg_wg_driver_point_config_reg_3_.Q,`SPI_WAVEGEN_REG_11.reg_wg_driver_point_config_reg_2_.Q,`SPI_WAVEGEN_REG_11.reg_wg_driver_point_config_reg_1_.Q,`SPI_WAVEGEN_REG_11.reg_wg_driver_point_config_reg_0_.Q};
//  assign wavegen_vif[0].neg_ena[0] = `SPI_WAVEGEN_REG_10.reg_wg_driver_config_reg_1_.Q;
//  assign wavegen_vif[0].pos_ena[0] = `SPI_WAVEGEN_REG_10.reg_wg_driver_config_reg_7_.Q;
//  assign wavegen_vif[0].neg_ena[1] = `SPI_WAVEGEN_REG_11.reg_wg_driver_config_reg_1_.Q;
//  assign wavegen_vif[0].pos_ena[1] = `SPI_WAVEGEN_REG_11.reg_wg_driver_config_reg_7_.Q;
//  assign wavegen_vif[0].pos_neg[0] = `SPI_WAVEGEN_REG_10.reg_wg_driver_config_reg_3_.Q;
//  assign wavegen_vif[0].pos_neg[1] = `SPI_WAVEGEN_REG_11.reg_wg_driver_config_reg_3_.Q;
//  assign wavegen_vif[0].multi_electrode[0] = `SPI_WAVEGEN_REG_10.reg_wg_driver_config_reg_6_.Q;
//  assign wavegen_vif[0].multi_electrode[1] = `SPI_WAVEGEN_REG_11.reg_wg_driver_config_reg_6_.Q;
//
//`endif
//
//assign wavegen_vif[0].sysclk = `DIG_TOP.u_anac.sysclk;
//assign wavegen_vif[0].presetn = `DIG_TOP.u_anac.presetn;
//assign wavegen_vif[0].A2D_STIMU0 = `DIG_TOP.u_anac.A2D_STIMU0_1;//short circuit signal
//assign wavegen_vif[0].A2D_STIMU1 = `DIG_TOP.u_anac.A2D_STIMU0_1;//short circuit signal
//assign wavegen_vif[0].A2D_STIMU2 = `DIG_TOP.u_anac.A2D_STIMU2_3;//short circuit signal
//assign wavegen_vif[0].A2D_STIMU3 = `DIG_TOP.u_anac.A2D_STIMU2_3;//short circuit signal
//
//// NOTE : Added as stimu signals are 2 clock delayed from the original signals in design
//// So, to replicate the logic inside WG SB , added them as below. - Added by Shreeyal, Discussed with Ophina and designer-Zhen
//always_ff @(posedge wavegen_vif[0].sysclk)begin
//// wavegen_vif[0].stimu0_d2 <= `DIG_TOP.u_anac.A2D_STIMU0;
// wavegen_vif[0].stimu0_d2 <= !dut_vif.D2A_comp_stim0_1_sel & `ANA_TOP.A2D_COMP_OUT_STIMU0_1;
// wavegen_vif[0].A2D_STIMU0_delayed <= wavegen_vif[0].stimu0_d2;
//
// wavegen_vif[0].stimu1_d2 <= dut_vif.D2A_comp_stim0_1_sel & `ANA_TOP.A2D_COMP_OUT_STIMU0_1;
// wavegen_vif[0].A2D_STIMU1_delayed <= wavegen_vif[0].stimu1_d2;
//
// wavegen_vif[0].stimu2_d2 <= !dut_vif.D2A_comp_stim2_3_sel & `ANA_TOP.A2D_COMP_OUT_STIMU2_3;
// wavegen_vif[0].A2D_STIMU2_delayed <= wavegen_vif[0].stimu2_d2;
//
// wavegen_vif[0].stimu3_d2 <= dut_vif.D2A_comp_stim2_3_sel & `ANA_TOP.A2D_COMP_OUT_STIMU2_3;
// wavegen_vif[0].A2D_STIMU3_delayed <= wavegen_vif[0].stimu3_d2;
//end
//
//
//assign wavegen_vif[0].ch1_stim_pos = 0;//Ophina commented !dut_vif.D2A_comp_stim0_1_sel & (wavegen_vif[0].expected_anac_ch1_stim_delay_target_cntr == dut_vif.anac_short_CH1_tgt_dly) & wavegen_vif[0].source1[0] & !wavegen_vif[0].source2[0];
//assign wavegen_vif[0].ch1_stim_neg = 0;//Ophina commented dut_vif.D2A_comp_stim0_1_sel & (wavegen_vif[0].expected_anac_ch1_stim_delay_target_cntr == dut_vif.anac_short_CH1_tgt_dly) & !wavegen_vif[0].source1[0] & wavegen_vif[0].source2[0];
//
//assign wavegen_vif[0].ch2_stim_pos = 0;//Ophina commented !dut_vif.D2A_comp_stim2_3_sel & (wavegen_vif[0].expected_anac_ch2_stim_delay_target_cntr == dut_vif.anac_short_CH2_tgt_dly) & wavegen_vif[0].source1[1] & !wavegen_vif[0].source2[1];
//assign wavegen_vif[0].ch2_stim_neg = 0;//Ophina commented dut_vif.D2A_comp_stim2_3_sel & (wavegen_vif[0].expected_anac_ch2_stim_delay_target_cntr == dut_vif.anac_short_CH2_tgt_dly) & !wavegen_vif[0].source1[1] & wavegen_vif[0].source2[1];
//
//`ifdef BEHAVIORAL
//assign wavegen_vif[0].ch1_stim_pos_dut = 0;//Ophina commented `DIG_TOP.u_anac.comp_ch1_stim_pos;
//assign wavegen_vif[0].ch1_stim_neg_dut = 0;//Ophina commented `DIG_TOP.u_anac.comp_ch1_stim_neg; 
//assign wavegen_vif[0].ch2_stim_pos_dut = 0;//Ophina commented `DIG_TOP.u_anac.comp_ch2_stim_pos;
//assign wavegen_vif[0].ch2_stim_neg_dut = 0;//Ophina commented `DIG_TOP.u_anac.comp_ch2_stim_neg;
//`else // not checking in NETLIST
//assign wavegen_vif[0].ch1_stim_pos_dut = 0;
//assign wavegen_vif[0].ch1_stim_neg_dut = 0;
//assign wavegen_vif[0].ch2_stim_pos_dut = 0;
//assign wavegen_vif[0].ch2_stim_neg_dut = 0;
//`endif
//
//assign wavegen_vif[0].ana_comp_ch1_intr_en = `DIG_TOP.u_anac.ana_comp_ch1_intr_en;   //Analog comp_ch1 int enable
//assign wavegen_vif[0].ana_comp_ch2_intr_en = `DIG_TOP.u_anac.ana_comp_ch2_intr_en;   //Analog comp_ch2 int enable
//
////assign wavegen_vif[0].ana_int_comp_pol_reg = `DIG_TOP.u_anac.ana_int_comp_pol_reg[0];//Set 0 mean low,1 mean high
//assign wavegen_vif[0].ana_stimu_ch1_intr_sts = `DIG_TOP.u_anac.o_ana_stimu_ch1_intr_sts;  
//assign wavegen_vif[0].ana_stimu_ch2_intr_sts = `DIG_TOP.u_anac.o_ana_stimu_ch2_intr_sts;
//
//assign wavegen_vif[0].ana_stimu_ch1_intr_sts_clr = `DIG_TOP.u_anac.ana_stimu_ch1_intr_sts_clr;  
//assign wavegen_vif[0].ana_stimu_ch2_intr_sts_clr = `DIG_TOP.u_anac.ana_stimu_ch2_intr_sts_clr;
//
//`ifdef POSTSCAN_PG
//      assign wavegen_vif[0].ana_comp_ch1_stim_int = 0;//Ophina commented `DIG_TOP.u_anac.ana_comp_ch1_stim_int_reg.Q;
//      assign wavegen_vif[0].comp_ch1_stim_duration_dtct_int = 0;//Ophina commented `DIG_TOP.u_anac.comp_ch1_stim_duration_dtct_int_reg.Q; //comp_ch1_stim_duration_dtct_int;  //Supriya, 18/06/2025
//
//`else
//      assign wavegen_vif[0].ana_comp_ch1_stim_int = 0;//Ophina commented `DIG_TOP.u_anac.ana_comp_ch1_stim_int;
//      assign wavegen_vif[0].comp_ch1_stim_duration_dtct_int = 0;//Ophina commented `DIG_TOP.u_anac.comp_ch1_stim_duration_dtct_int;  //Supriya, 18/06/2025
//      
//`endif 
//`ifdef POSTSCAN_PG
//      assign wavegen_vif[0].ana_comp_ch2_stim_int = 0;//Ophina commented `DIG_TOP.u_anac.ana_comp_ch2_stim_int_reg.Q;
//      assign wavegen_vif[0].comp_ch2_stim_duration_dtct_int = 0;//Ophina commented `DIG_TOP.u_anac.comp_ch2_stim_duration_dtct_int;  //Supriya, 18/06/2025
//`else
//      assign wavegen_vif[0].ana_comp_ch2_stim_int = 0;//Ophina commented `DIG_TOP.u_anac.ana_comp_ch2_stim_int;
//      assign wavegen_vif[0].comp_ch2_stim_duration_dtct_int = 0;//Ophina commented `DIG_TOP.u_anac.comp_ch2_stim_duration_dtct_int;   //Supriya, 18/06/2025
//`endif 
////assign wavegen_vif[0].ana_stimu_int1_num = `DIG_TOP.u_anac.ana_stimu_int1_num;
////assign wavegen_vif[0].ana_stimu_int2_num = `DIG_TOP.u_anac.ana_stimu_int2_num;
////assign wavegen_vif[0].comp_stim_duration_tar_cnt[23:0] =`DIG_TOP.u_anac.comp_stim_duration_tar_cnt[23:0];   //Supriya, 18/06/2025 
////assign wavegen_vif[0].comp_ch1_stim_mul_duration_dtct_en =`DIG_TOP.u_anac.comp_ch1_stim_mul_duration_dtct_en;  //Supriya, 18/06/2025
////assign wavegen_vif[0].comp_ch2_stim_mul_duration_dtct_en =`DIG_TOP.u_anac.comp_ch2_stim_mul_duration_dtct_en;  //Supriya, 18/06/2025
//
//
//`ifdef BEHAVIORAL
//assign wavegen_vif[0].ana_stimu_int1_num_reg = 0;//Ophina commented `DIG_TOP.u_anac.ana_stimu_int1_num_reg;
//assign wavegen_vif[0].ana_stimu_int2_num_reg = 0;//Ophina commented `DIG_TOP.u_anac.ana_stimu_int2_num_reg;
//assign wavegen_vif[0].ana_comp_ch1_stimu_delay = 0;//Ophina commented `DIG_TOP.u_anac.comp_ch1_stim_delay[23:0];
//assign wavegen_vif[0].ana_comp_ch2_stimu_delay = 0;//Ophina commented `DIG_TOP.u_anac.comp_ch2_stim_delay[23:0];
//`else // not checking in NETLIST
//assign wavegen_vif[0].ana_stimu_int1_num_reg = 0;
//assign wavegen_vif[0].ana_stimu_int2_num_reg = 0;
//`endif
//
//assign wavegen_vif[0].stop_wavegen = 0;           //Enable wavegen1/2
//assign wavegen_vif[0].sim0_a00 = 0;//Ophina commented `DIG_TOP.u_anac.ana_int_sim0_a00_reg;
//assign wavegen_vif[0].sim0_a01 = 0;//Ophina commented `DIG_TOP.u_anac.ana_int_sim0_a01_reg;
//assign wavegen_vif[0].sim1_a10 = 0;//Ophina commented `DIG_TOP.u_anac.ana_int_sim1_a10_reg;
//assign wavegen_vif[0].sim1_a11 = 0;//Ophina commented `DIG_TOP.u_anac.ana_int_sim1_a11_reg;
//assign wavegen_vif[0].sim2_a20 = 0;//Ophina commented `DIG_TOP.u_anac.ana_int_sim2_a20_reg;
//assign wavegen_vif[0].sim2_a21 = 0;//Ophina commented `DIG_TOP.u_anac.ana_int_sim2_a21_reg;
//assign wavegen_vif[0].sim3_a30 = 0;//Ophina commented `DIG_TOP.u_anac.ana_int_sim3_a30_reg;
//assign wavegen_vif[0].sim3_a31 = 0;//Ophina commented `DIG_TOP.u_anac.ana_int_sim3_a31_reg;
//
//assign wavegen_vif[0].wavegen1_addr = 0;// Daniel `DIG_TOP.u_anac.wavegen1_addr;
//assign wavegen_vif[0].wavegen2_addr = 0;// Daniel  `DIG_TOP.u_anac.wavegen2_addr;
//
//// NOTE :  For clock per wavegen point is 1, wavegen addr are 1 clk shifted , so delaying them by 1 clk - Added by Shreeyal, Discussed with Ophina and designer-Zhen
//always_ff @(posedge wavegen_vif[0].sysclk)begin
//  wavegen_vif[0].wavegen1_addr_delayed <= 0;// Daniel `DIG_TOP.u_anac.wavegen1_addr;
//  wavegen_vif[0].wavegen2_addr_delayed <= 0;// Daniel `DIG_TOP.u_anac.wavegen2_addr;
//end
//
//assign wavegen_vif[0].source1 = 0;//Ophina commented `DIG_TOP.u_anac.sourcea_driver_a;
//assign wavegen_vif[0].source2 = 0;//Ophina commented `DIG_TOP.u_anac.sourceb_driver_a;
//
initial begin
    nnc_config_db#(virtual nnc_wavegen_interface)::set(uvm_root::get(), "uvm_test_top.*", "wavegen_vif[0]", wavegen_vif[0]);
end
initial begin
    nnc_config_db#(virtual nnc_wavegen_interface)::set(uvm_root::get(), "uvm_test_top.*", "wavegen_vif[1]", wavegen_vif[1]);
end
//
//always_ff @(posedge wavegen_vif[0].sysclk  or negedge wavegen_vif[0].presetn)begin
//  if(!wavegen_vif[0].presetn)
//     wavegen_vif[0].anac_duration_stimu_ch1_intr_sts_d = 1'b0;
//  else
//    wavegen_vif[0].anac_duration_stimu_ch1_intr_sts_d <= wavegen_vif[0].ana_stimu_ch1_intr_sts;
//end 
////generate intr_sts flag on rising edge
//assign wavegen_vif[0].posedge_flag_anac_duration_stimu_ch1_intr_sts = ~wavegen_vif[0].anac_duration_stimu_ch1_intr_sts_d & wavegen_vif[0].ana_stimu_ch1_intr_sts;
//
//always_ff @(posedge wavegen_vif[0].sysclk  or negedge wavegen_vif[0].presetn)begin
//  if(!wavegen_vif[0].presetn)
//     wavegen_vif[0].anac_duration_stimu_ch2_intr_sts_d = 1'b0;
//  else
//    wavegen_vif[0].anac_duration_stimu_ch2_intr_sts_d <= wavegen_vif[0].ana_stimu_ch2_intr_sts;
//end 
////generate intr_sts flag on rising edge
//assign wavegen_vif[0].posedge_flag_anac_duration_stimu_ch2_intr_sts = ~wavegen_vif[0].anac_duration_stimu_ch2_intr_sts_d & wavegen_vif[0].ana_stimu_ch2_intr_sts;             
//                                                                                                                                                                              
////this logic moved to wavegen monitor                                                                                                                                                               
////always_ff @(posedge wavegen_vif[0].sysclk  or negedge wavegen_vif[0].presetn)begin                                                                                
////  if(!wavegen_vif[0].presetn)begin
////     wavegen_vif[0].expected_anac_ch1_stim_delay_target_cntr = 24'b0;
////  end else if((!wavegen_vif[0].anac_stim_CH1_pulse_intr_en && !wavegen_vif[0].anac_comp_ch1_stim_duration_dtct_int_en) )begin
////     wavegen_vif[0].expected_anac_ch1_stim_delay_target_cntr = 24'b0;                                                         
////  end
////  else if((!dut_vif.D2A_comp_stim0_1_sel && wavegen_vif[0].source1[0] && !wavegen_vif[0].source2[0]) | (dut_vif.D2A_comp_stim0_1_sel && !wavegen_vif[0].source1[0] && wavegen_vif[0].source2[0]))begin 
////    if(wavegen_vif[0].expected_anac_ch1_stim_delay_target_cntr !== dut_vif.anac_short_CH1_tgt_dly && !wavegen_vif[0].ana_stimu_ch1_intr_sts)begin
////      wavegen_vif[0].expected_anac_ch1_stim_delay_target_cntr <=  wavegen_vif[0].expected_anac_ch1_stim_delay_target_cntr + 1'b1;
////    end
////  end
////  else if(wavegen_vif[0].expected_anac_ch1_stim_delay_target_cntr === dut_vif.anac_short_CH1_tgt_dly) begin
////    wavegen_vif[0].expected_anac_ch1_stim_delay_target_cntr <= 24'b0;
////  end
////end
////
////always_ff @(posedge wavegen_vif[0].sysclk  or negedge wavegen_vif[0].presetn)begin 
////  if(!wavegen_vif[0].presetn)                                                      
////     wavegen_vif[0].expected_anac_ch2_stim_delay_target_cntr = 24'b0;
////  else if((!wavegen_vif[0].anac_stim_CH2_pulse_intr_en && !wavegen_vif[0].anac_comp_ch2_stim_duration_dtct_int_en))begin
////     wavegen_vif[0].expected_anac_ch2_stim_delay_target_cntr = 24'b0;
////  end
////  else if ((!dut_vif.D2A_comp_stim2_3_sel && wavegen_vif[0].source1[1] && !wavegen_vif[0].source2[1]) | (dut_vif.D2A_comp_stim2_3_sel && !wavegen_vif[0].source1[1] && wavegen_vif[0].source2[1])) begin 
////    if(wavegen_vif[0].expected_anac_ch2_stim_delay_target_cntr !== dut_vif.anac_short_CH2_tgt_dly && !wavegen_vif[0].ana_stimu_ch2_intr_sts)begin
////      wavegen_vif[0].expected_anac_ch2_stim_delay_target_cntr <= wavegen_vif[0].expected_anac_ch2_stim_delay_target_cntr + 1'b1;
////    end
////  end 
////  else if(wavegen_vif[0].expected_anac_ch2_stim_delay_target_cntr === dut_vif.anac_short_CH2_tgt_dly) begin
////    wavegen_vif[0].expected_anac_ch2_stim_delay_target_cntr <= 24'b0;
////  end
////end 
//
//assign wavegen_vif[0].hex_data_a       = dut_vif.hex_data_a;  
//assign wavegen_vif[0].hex_data_b       = dut_vif.hex_data_b;  
//assign wavegen_vif[0].no_of_point_a    = dut_vif.no_of_point_a;
//assign wavegen_vif[0].no_of_point_b    = dut_vif.no_of_point_b;
//assign wavegen_vif[0].pos_neg_from_same_addr        = dut_vif.pos_neg_from_same_addr;    
//assign wavegen_vif[0].load_wave_data_till_points        = dut_vif.load_wave_data_till_points;    
//assign wavegen_vif[0].no_of_waveforms  = dut_vif.no_of_waveforms;    
//assign wavegen_vif[0].preload_sel       = dut_vif.preload_sel; 
////assign wavegen_vif[0].stop_check[0]     = dut_vif.stop_check[0];
////assign wavegen_vif[0].stop_check[1]     = dut_vif.stop_check[1];
//assign wavegen_vif[0].scale_en         = dut_vif.scale_en;
//assign wavegen_vif[0].noperiod         = dut_vif.noperiod;
//assign wavegen_vif[0].noperiod_pos_neg_sel         = dut_vif.noperiod_pos_neg_sel;
//assign wavegen_vif[0].swap_sdf_en      = dut_vif.swap_sdf_en;
//assign wavegen_vif[0].mult_chip_same_clk_en      = dut_vif.mult_chip_same_clk_en;
//assign wavegen_vif[0].PULLAB_pos_en      = dut_vif.PULLAB_pos_en;
//assign wavegen_vif[0].PULLAB_neg_en      = dut_vif.PULLAB_neg_en;
//assign wavegen_vif[0].PULLAB_lim         = dut_vif.PULLAB_lim;
//assign wavegen_vif[0].spi_o_clk_sel         = dut_vif.spi_o_clk_sel;
//
//assign wavegen_vif[0].wg_hlf_wave0_lim[0]     = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_hlf_wave0_lim[0];
//assign wavegen_vif[0].wg_hlf_wave0_lim[1]     = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_hlf_wave0_lim[1];
//assign wavegen_vif[0].wg_neg_hlf_wave0_lim[0] = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_neg_hlf_wave0_lim[0];
//assign wavegen_vif[0].wg_neg_hlf_wave0_lim[1] = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_neg_hlf_wave0_lim[1];
//assign wavegen_vif[0].wg_hlf_wave1_lim[0]     = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_hlf_wave1_lim[0];
//assign wavegen_vif[0].wg_hlf_wave1_lim[1]     = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_hlf_wave1_lim[1];
//assign wavegen_vif[0].wg_neg_hlf_wave1_lim[0] = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_neg_hlf_wave1_lim[0];
//assign wavegen_vif[0].wg_neg_hlf_wave1_lim[1] = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_neg_hlf_wave1_lim[1];
//assign wavegen_vif[0].wg_hlf_wave2_lim[0]     = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_hlf_wave2_lim[0];
//assign wavegen_vif[0].wg_hlf_wave2_lim[1]     = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_hlf_wave2_lim[1];
//assign wavegen_vif[0].wg_neg_hlf_wave2_lim[0] = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_neg_hlf_wave2_lim[0];
//assign wavegen_vif[0].wg_neg_hlf_wave2_lim[1] = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_neg_hlf_wave2_lim[1];
//
//assign wavegen_vif[0].wg_rest_wave0_lim[0]   = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_rest_wave0_lim[0];
//assign wavegen_vif[0].wg_rest_wave0_lim[1]   = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_rest_wave0_lim[1];
//assign wavegen_vif[0].wg_silent_wave0_lim[0] = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_silent_wave0_lim[0];
//assign wavegen_vif[0].wg_silent_wave0_lim[1] = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_silent_wave0_lim[1];
//assign wavegen_vif[0].wg_rest_wave1_lim[0]   = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_rest_wave1_lim[0];
//assign wavegen_vif[0].wg_rest_wave1_lim[1]   = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_rest_wave1_lim[1];
//assign wavegen_vif[0].wg_silent_wave1_lim[0] = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_silent_wave1_lim[0];
//assign wavegen_vif[0].wg_silent_wave1_lim[1] = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_silent_wave1_lim[1];
//assign wavegen_vif[0].wg_rest_wave2_lim[0]   = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_rest_wave2_lim[0];
//assign wavegen_vif[0].wg_rest_wave2_lim[1]   = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_rest_wave2_lim[1];
//assign wavegen_vif[0].wg_silent_wave2_lim[0] = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_silent_wave2_lim[0];
//assign wavegen_vif[0].wg_silent_wave2_lim[1] = (dut_vif.mult_chip_en === 1) && (dut_vif.mult_chip_same_clk_en === 0) ? 32'bz : dut_vif.wg_silent_wave2_lim[1];
//
//assign wavegen_vif[0].ana_int_comp_pol_reg                     = dut_vif.anac_stim_CH1_pol             ;  //Set 0 mean low,1 mean high
////need to add one more signal for CH2 polarity
////assign wavegen_vif[0].ana_int_comp_pol_reg                     = dut_vif.anac_stim_CH2_pol             ;  //Set 0 mean low,1 mean high
//assign wavegen_vif[0].anac_comp_stim_duration_tar_cnt          = 0;//dut_vif.anac_stim_duration_cnt        ;  //anac_comp_stim_duration_cnt, Comp_stim_duration_tar_cnt
//assign wavegen_vif[0].ana_stimu_int1_num                       = 0;//dut_vif.anac_stim_CH1_int_cnt         ;  //anac_stim_CH1_int_cnt
//assign wavegen_vif[0].ana_stimu_int2_num                       = 0;//dut_vif.anac_stim_CH2_int_cnt         ;  //anac_stim_CH2_int_cnt
//assign wavegen_vif[0].anac_stim_CH1_pulse_intr_en              = dut_vif.anac_stim_CH1_intr_en         ;  //comp_stim_CH1_intr_en
//assign wavegen_vif[0].anac_stim_CH2_pulse_intr_en              = dut_vif.anac_stim_CH2_intr_en         ;  //comp_stim_CH2_intr_en
//assign wavegen_vif[0].anac_comp_ch1_stim_duration_dtct_int_en  = 0;//dut_vif.anac_stim_CH1_duration_intr_en;  //comp_stim_CH1_duration_intr_en, Comp_ch1_stim_duration_dtct_int_en
//assign wavegen_vif[0].anac_comp_ch2_stim_duration_dtct_int_en  = 0;//dut_vif.anac_stim_CH2_duration_intr_en;  //comp_stim_CH2_duration_intr_en, Comp_ch2_stim_duration_dtct_int_en
//assign wavegen_vif[0].anac_comp_ch1_stim_mul_duration_dtct_en  = 0;//dut_vif.anac_mult_duration_cnt_clr1   ;  //comp_mult_duration_cnt_clr1, Comp_ch1_stim_mul_duration_dtct_en
//assign wavegen_vif[0].anac_comp_ch2_stim_mul_duration_dtct_en  = 0;//dut_vif.anac_mult_duration_cnt_clr2   ;  //comp_mult_duration_cnt_clr2, Comp_ch2_stim_mul_duration_dtct_en
//assign wavegen_vif[0].D2A_comp_stim0_1_sel                     = dut_vif.D2A_comp_stim0_1_sel;
//assign wavegen_vif[0].D2A_comp_stim2_3_sel                     = dut_vif.D2A_comp_stim2_3_sel;
//assign wavegen_vif[0].anac_short_CH1_tgt_dly_val	       = 0;//dut_vif.anac_short_CH1_tgt_dly;
//assign wavegen_vif[0].anac_short_CH2_tgt_dly_val	       = 0;//dut_vif.anac_short_CH2_tgt_dly;
//
//assign wavegen_vif[0].mult_chip_en = dut_vif.mult_chip_en;
//assign wavegen_vif[0].master_chip_wave1 = `SOC_TB.master_chip_wave1;
//assign wavegen_vif[0].master_chip_wave2 = `SOC_TB.master_chip_wave2;
//assign wavegen_vif[0].slave_chip_wave1 = `SOC_TB.slave_chip_wave1;
//assign wavegen_vif[0].slave_chip_wave2 = `SOC_TB.slave_chip_wave2;
//assign wavegen_vif[0].pclk = `WG_DRIVER_TOP.i_pclk;
//assign wavegen_vif[0].fclk = `WG_DRIVER_TOP.i_fclk;

nnc_wavegen_if     wavegen_agt_vif[`WAVEGEN_DRIVER_NUM]();

generate 
for(genvar i=0; i < `WAVEGEN_DRIVER_NUM; i++)begin    
    assign wavegen_agt_vif[i].clk         =  `WG_DRIVER_TOP.i_pclk;  
    assign wavegen_agt_vif[i].resetn      =  `WG_DRIVER_TOP.i_presetn;
    assign wavegen_agt_vif[i].fclk        =  `WG_DRIVER_TOP.i_fclk;
    assign wavegen_agt_vif[i].sclk        =   spi_vif.i_sclk;

    assign wavegen_agt_vif[i].wave_reg    =   {>>{spi_vif.REG_DATA[1][8'h00+8'h40*i:8'h3F+8'h40*i]}};

//int clear type -> r1c
always@(spi_vif.REG_RDATA[1][8'h2B+8'h40*i][5:4])begin
    wavegen_agt_vif[i].r1c_clr[0] = spi_vif.REG_RDATA[1][8'h2B+8'h40*i][4];
    wavegen_agt_vif[i].r1c_clr[1] = spi_vif.REG_RDATA[1][8'h2B+8'h40*i][5];
    #20000ns;
    wavegen_agt_vif[i].r1c_clr = '{default:0}; 
    spi_vif.REG_RDATA[1][8'h2B+8'h40*i][5:4] = 0;
end

always@(spi_vif.REG_RDATA[0][8'h7A + i/2])begin
    wavegen_agt_vif[i].r1c_clr[0] = spi_vif.REG_RDATA[0][8'h7A + i/4][(i%4)*2+0];
    wavegen_agt_vif[i].r1c_clr[1] = spi_vif.REG_RDATA[0][8'h7A + i/4][(i%4)*2+1];
    #20000ns;
    wavegen_agt_vif[i].r1c_clr = '{default:0}; 
    spi_vif.REG_RDATA[0][8'h7A + i/2] = 0;
end

assign wavegen_agt_vif[i].source     = `WG_DRIVER_TOP.o_source_driver[i];  
//assign wavegen_agt_vif[i].source     = `WG_DRIVER_TOP.o_source_driver[i];  
assign wavegen_agt_vif[i].pulldn       = `WG_DRIVER_TOP.o_pulldn_driver[i];   
//assign wavegen_agt_vif[i].pulldn       = `WG_DRIVER_TOP.o_pulldn_driver[i];   

end
endgenerate

assign wavegen_agt_vif[0].dac_din     = `WG_DRIVER_TOP.o_out_wave_driver_idac[0];
assign wavegen_agt_vif[1].dac_din     = `WG_DRIVER_TOP.o_out_wave_driver_idac[1];
assign wavegen_agt_vif[2].dac_din     = `WG_DRIVER_TOP.o_out_wave_driver_idac[2];
assign wavegen_agt_vif[3].dac_din     = `WG_DRIVER_TOP.o_out_wave_driver_idac[3];
assign wavegen_agt_vif[4].dac_din     = `WG_DRIVER_TOP.o_out_wave_driver_idac[4];
assign wavegen_agt_vif[5].dac_din     = `WG_DRIVER_TOP.o_out_wave_driver_idac[5];
assign wavegen_agt_vif[6].dac_din     = `WG_DRIVER_TOP.o_out_wave_driver_idac[6];
assign wavegen_agt_vif[7].dac_din     = `WG_DRIVER_TOP.o_out_wave_driver_idac[7];
assign wavegen_agt_vif[8].dac_din     = `WG_DRIVER_TOP.o_out_wave_driver_idac[8];
assign wavegen_agt_vif[9].dac_din     = `WG_DRIVER_TOP.o_out_wave_driver_idac[9];
assign wavegen_agt_vif[10].dac_din    = `WG_DRIVER_TOP.o_out_wave_driver_idac[10];
assign wavegen_agt_vif[11].dac_din    = `WG_DRIVER_TOP.o_out_wave_driver_idac[11];
assign wavegen_agt_vif[12].dac_din    = `WG_DRIVER_TOP.o_out_wave_driver_idac[12];
assign wavegen_agt_vif[13].dac_din    = `WG_DRIVER_TOP.o_out_wave_driver_idac[13];
assign wavegen_agt_vif[14].dac_din    = `WG_DRIVER_TOP.o_out_wave_driver_idac[14];
assign wavegen_agt_vif[15].dac_din    = `WG_DRIVER_TOP.o_out_wave_driver_idac[15];

//int clear type -> r1c 
//always@(spi_vif.REG_RDATA[0][8'h7A + i/2])begin
//    wavegen_agt_vif[i].r1c_clr[0] = spi_vif.REG_RDATA[0][8'h7A + i/4][(i%4)*2+0];
//    wavegen_agt_vif[i].r1c_clr[1] = spi_vif.REG_RDATA[0][8'h7A + i/4][(i%4)*2+1];
//    #20000ns;
//    wavegen_agt_vif[i].r1c_clr = '{default:0}; 
//    spi_vif.REG_RDATA[0][8'h7A + i/2] = 0;
//end


//`ifdef BEHAVIORAL
//// in rtl sim, drive_en and glb_en from wavegen_ref
//`else 
//assign wavegen_agt_vif[0].wave_glb_en =  {`WG_DRIVER_TOP.spi_wg_global_en, `WG_DRIVER_TOP.spi_wg_global_en};
//`ifdef SDFANNOTATE_MAX
//assign #1.412  wavegen_agt_vif.driver_en[0]   =  `WG_DRIVER_TOP.drive_en[0]; //there is a buffer from driver_en to input of sync.
//assign #2.523 wavegen_agt_vif.driver_en[1]   =  `WG_DRIVER_TOP.drive_en[1];  // some delay in sync_module of drive_en[1]  max corner path: soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_wg_driver.genblk1_1__u_driver_en_sync
//`elsif SDFANNOTATE_MIN
//assign #0.415  wavegen_agt_vif.driver_en[0]   =  `WG_DRIVER_TOP.drive_en[0]; //there is a buffer from driver_en to input of sync.
//assign #1.113 wavegen_agt_vif.driver_en[1]   =  `WG_DRIVER_TOP.drive_en[1];  //some delay in sync_module of drive_en[1]  min corner
//`else
//assign #1  wavegen_agt_vif.driver_en[0]   =  `WG_DRIVER_TOP.drive_en[0]; //there is a buffer from driver_en to input of sync.
//assign #2.523 wavegen_agt_vif.driver_en[1]   =  `WG_DRIVER_TOP.drive_en[1];  //some delay in sync_module of drive_en[1]  typ corner
//`endif
//`endif

//assign wavegen_agt_vif[0].dac_din     = `WG_DRIVER_TOP.o_out_wave_drivera_dac0;//`ANA_TOP.D2A_IDAC_DIN_CH1        ;//, `ANA_TOP.D2A_IDAC_DIN_CH2       };// WG_DRIVER_TOP.o_out_wave_drivera_dac0;
//assign wavegen_agt_vif[i].sourcea     = `WG_DRIVER_TOP.o_sourcea_driver_a[i];  //`ANA_TOP.D2A_DRIVERA_SOURCEA_CH1 ;//, `ANA_TOP.D2A_DRIVERA_SOURCEA_CH2};//`WG_DRIVER_TOP.o_sourcea_driver_a[i];  
//assign wavegen_agt_vif[i].sourceb     = `WG_DRIVER_TOP.o_sourceb_driver_a[i];  //`ANA_TOP.D2A_DRIVERA_SOURCEB_CH1 ;//, `ANA_TOP.D2A_DRIVERA_SOURCEB_CH2};//`WG_DRIVER_TOP.o_sourceb_driver_a[i]; 
//assign wavegen_agt_vif[i].pulla       = `WG_DRIVER_TOP.o_pullda_driver_a[i];   //`ANA_TOP.D2A_DRIVERA_PULLDA_CH1  ;//, `ANA_TOP.D2A_DRIVERA_PULLDA_CH2 };//`WG_DRIVER_TOP.o_pullda_driver_a[i]; /
//assign wavegen_agt_vif[i].pullb       = `WG_DRIVER_TOP.o_pulldb_driver_a[i];   //`ANA_TOP.D2A_DRIVERA_PULLDB_CH1  ;//, `ANA_TOP.D2A_DRIVERA_PULLDB_CH2 };//`WG_DRIVER_TOP.o_pulldb_driver_a[i]; /

//assign wavegen_agt_vif[1].dac_din     = `ANA_TOP.D2A_IDAC_DIN_CH2       ;
//assign wavegen_agt_vif[1].sourcea     = `ANA_TOP.D2A_DRIVERA_SOURCEA_CH2;
//assign wavegen_agt_vif[1].sourceb     = `ANA_TOP.D2A_DRIVERA_SOURCEB_CH2;
//assign wavegen_agt_vif[1].pulla       = `ANA_TOP.D2A_DRIVERA_PULLDA_CH2 ;
//assign wavegen_agt_vif[1].pullb       = `ANA_TOP.D2A_DRIVERA_PULLDB_CH2 ;

generate
for(genvar i=0; i < `WAVEGEN_DRIVER_NUM; i++)begin
    initial begin
        nnc_config_db#(virtual nnc_wavegen_if)::set(uvm_root::get(), "uvm_test_top.top_env.wavegen_env.wg_drvs_agt*", $sformatf("wg_vif[%0d]", i), wavegen_agt_vif[i]);
    end
end
endgenerate
//initial begin
//    nnc_config_db#(virtual nnc_wavegen_interface)::set(uvm_root::get(), "uvm_test_top.*", "wavegen_vif[0]", wavegen_vif[0]);
//end
