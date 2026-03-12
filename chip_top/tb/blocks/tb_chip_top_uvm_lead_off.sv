/*--------------------------------------------------------------------------------------*/
// Copyright 2021 Nanochap, Inc.
// All Rights Reserved Worldwide
// --------------------------------------------------------------------------------------
// Project      : Nanochap ENS2
// File         : tb_chip_top_uvm_lead_off.sv
// Description  : LEAD OFF DETECTOR TB 
// Designer     : Ophina Correya
// Date         : 10-04-2024
// Revision     : 0.1
/*--------------------------------------------------------------------------------------*/

initial begin

`ifdef BEHAVIORAL
  wait(`DIG_TOP.spi_wg.o_wg_driver_en[0] === 1'b1);
`else
  wait(`SPI_TOP.spi_wg_o_wg_driver_en[0] === 1'b1);
`endif
end

initial begin

`ifdef BEHAVIORAL
  wait(`DIG_TOP.spi_wg.o_wg_driver_en[1] === 1'b1);
`else
  wait(`SPI_TOP.spi_wg_o_wg_driver_en[1] === 1'b1);
`endif

end

wire A2D_comp0_random_in;
wire A2D_comp1_random_in;
assign A2D_comp0_random_in = dut_vif.A2D_comp0_in;
assign A2D_comp1_random_in = dut_vif.A2D_comp1_in;
//Currently using leadoff_short analog model to drive, so random input no longer used
//assign `ANA_TOP.A2D_COMP_OUT_CH1 = (dut_vif.lead_off_en === 1) ? 'hz : ((dut_vif.A2D_comp_sel[0] === 1'b1) ? dut_vif.A2D_comp0_in : 1'bz);
//assign `ANA_TOP.A2D_COMP_OUT_CH2 = (dut_vif.lead_off_en === 1) ? 'hz : ((dut_vif.A2D_comp_sel[1] === 1'b1) ? dut_vif.A2D_comp1_in : 1'bz);

nnc_lead_off_interface     lead_off_vif();

logic temp0;
logic temp1;

//assign   lead_off_vif.pclk_sel          =   dut_vif.pclk_sel; 
//assign   lead_off_vif.fclk              =   `WG_DRIVER_TOP.i_fclk;
// leadoff removed //assign   lead_off_vif.pclk              =   `LEADOFF_WRAPPER_TOP.i_pclk;
// leadoff removed //assign   lead_off_vif.presetn           =   `LEADOFF_WRAPPER_TOP.i_presetn;
// leadoff removed //
// leadoff removed ////`ifdef BEHAVIORAL
// leadoff removed ////  assign   lead_off_vif.dly_en            =   `LEADOFF_TOP.dly_en;
// leadoff removed ////`elsif PRESCAN
// leadoff removed ////  assign   lead_off_vif.dly_en            =   `LEADOFF_TOP.dly_en;
// leadoff removed ////`elsif POSTSCAN_PG
// leadoff removed ////  assign   lead_off_vif.dly_en            =   `LEADOFF_TOP.dly_en;
// leadoff removed ////`else
// leadoff removed ////  assign   lead_off_vif.dly_en            =   `LEADOFF_TOP.dly_en;
// leadoff removed ////`endif
// leadoff removed //
// leadoff removed //assign   lead_off_vif.lead_off_level_tgt         =   dut_vif.lead_off_level_tgt;
// leadoff removed //assign   lead_off_vif.lead_off_stop_en           =   dut_vif.lead_off_stop_en_ch0;
// leadoff removed //assign   lead_off_vif.lead_off_comp_low_active   =   dut_vif.lead_off_ch0_comp_low_active;
// leadoff removed //assign   lead_off_vif.lead_off_pulse_int_en      =   dut_vif.lead_off_pulse_int_en;
// leadoff removed //assign   lead_off_vif.lead_off_level_int_en      =   dut_vif.lead_off_level_int_en;
// leadoff removed //assign   lead_off_vif.lead_off_tgt_dly_dac0      =   dut_vif.lead_off_tgt_dly_dac0;
// leadoff removed //assign   lead_off_vif.lead_off_tgt_dly_dac1      =   dut_vif.lead_off_tgt_dly_dac1;
// leadoff removed //assign   lead_off_vif.lead_off_tgt               =   dut_vif.lead_off_tgt;
// leadoff removed //assign   lead_off_vif.dac_sel                    =   dut_vif.lead_off_dac_sel;
// leadoff removed //assign   lead_off_vif.check_mode                 =   dut_vif.lead_off_check_mode;
// leadoff removed //assign   lead_off_vif.comp_reverse               =   dut_vif.lead_off_comp_reverse;
// leadoff removed //assign   lead_off_vif.dly_en                     =   dut_vif.lead_off_dly_en;       
// leadoff removed //
// leadoff removed ////assign   lead_off_vif.TH_H              =   `LEADOFF_TOP.TH_H;
// leadoff removed ////assign   lead_off_vif.TH_L              =   `LEADOFF_TOP.TH_L;
// leadoff removed ////assign   lead_off_vif.dly_tgt           =   `LEADOFF_TOP.measure_dly_tgt;
// leadoff removed ////assign   lead_off_vif.lead_off_tgt      =   `LEADOFF_TOP.lead_off_tgt;
// leadoff removed ////assign   lead_off_vif.check_mode        =   `LEADOFF_TOP.check_mode;
// leadoff removed ////assign   lead_off_vif.dac_sel           =   `LEADOFF_TOP.dac_sel;
// leadoff removed ////`ifdef POSTSCAN_PG
// leadoff removed ////  assign   lead_off_vif.comp_reverse      =   `LEADOFF_TOP.comp_reverse;
// leadoff removed ////`else
// leadoff removed ////  assign   lead_off_vif.comp_reverse      =   `LEADOFF_TOP.comp_reverse;
// leadoff removed ////`endif
// leadoff removed //
// leadoff removed //assign   lead_off_vif.A2D_COMP0         =   `LEADOFF_TOP_0.A2D_COMP1;
// leadoff removed //assign   lead_off_vif.A2D_COMP1         =   `LEADOFF_TOP_1.A2D_COMP1;
// leadoff removed //
// leadoff removed ////drv 0
// leadoff removed //assign lead_off_vif.pulla[0] = `ANA_WRAPPER_TOP.i_pullda_driver_a[0];
// leadoff removed //assign lead_off_vif.pullb[0] = `ANA_WRAPPER_TOP.i_pulldb_driver_a[0];
// leadoff removed //assign lead_off_vif.sourcea[0] = `ANA_WRAPPER_TOP.i_sourcea_driver_a[0];
// leadoff removed //assign lead_off_vif.sourceb[0] = `ANA_WRAPPER_TOP.i_sourceb_driver_a[0];
// leadoff removed ////drv 1
// leadoff removed //assign lead_off_vif.pulla[1] = `ANA_WRAPPER_TOP.i_pullda_driver_a[1];
// leadoff removed //assign lead_off_vif.pullb[1] = `ANA_WRAPPER_TOP.i_pulldb_driver_a[1];
// leadoff removed //assign lead_off_vif.sourcea[1] = `ANA_WRAPPER_TOP.i_sourcea_driver_a[1];
// leadoff removed //assign lead_off_vif.sourceb[1] = `ANA_WRAPPER_TOP.i_sourceb_driver_a[1];
// leadoff removed //
// leadoff removed //// in lead off detect design , there is a delay of 2 clock between A2D_COMP and A2D_COMP_sync signals, to mimic that in scb, added below logic 
// leadoff removed //always@(posedge `LEADOFF_WRAPPER_TOP.i_pclk)begin
// leadoff removed //  temp0   <=  lead_off_vif.A2D_COMP0; 
// leadoff removed //  temp1   <=  lead_off_vif.A2D_COMP1;
// leadoff removed //  if(~lead_off_vif.presetn)begin
// leadoff removed //    lead_off_vif.A2D_COMP0_delayed   <=   0; 
// leadoff removed //    lead_off_vif.A2D_COMP1_delayed   <=   0;
// leadoff removed //  end
// leadoff removed //  else if(lead_off_vif.lead_off_comp_low_active === 0)begin
// leadoff removed //    lead_off_vif.A2D_COMP0_delayed   <=   temp0; 
// leadoff removed //    lead_off_vif.A2D_COMP1_delayed   <=   temp1;
// leadoff removed //  end
// leadoff removed //  else begin
// leadoff removed //    lead_off_vif.A2D_COMP0_delayed   <=   ~temp0; 
// leadoff removed //    lead_off_vif.A2D_COMP1_delayed   <=   ~temp1;
// leadoff removed //  end
// leadoff removed //end
// leadoff removed //
// leadoff removed //assign lead_off_vif.dac0_pos_check =  lead_off_vif.dac_sel[0] && lead_off_vif.sourcea[0];
// leadoff removed //assign lead_off_vif.dac0_neg_check =  lead_off_vif.dac_sel[0] && lead_off_vif.sourceb[0];
// leadoff removed //
// leadoff removed //assign lead_off_vif.dac1_pos_check =  lead_off_vif.dac_sel[1] && lead_off_vif.sourcea[1];
// leadoff removed //assign lead_off_vif.dac1_neg_check =  lead_off_vif.dac_sel[1] && lead_off_vif.sourceb[1];
// leadoff removed //
// leadoff removed //always@(posedge `LEADOFF_WRAPPER_TOP.i_pclk)begin
// leadoff removed //  lead_off_vif.dac0_pos_check_delayed   <= lead_off_vif.dac0_pos_check;
// leadoff removed //  lead_off_vif.dac0_neg_check_delayed   <= lead_off_vif.dac0_neg_check;
// leadoff removed //  lead_off_vif.dac1_pos_check_delayed   <= lead_off_vif.dac1_pos_check;
// leadoff removed //  lead_off_vif.dac1_neg_check_delayed   <= lead_off_vif.dac1_neg_check;
// leadoff removed //end
// leadoff removed //
// leadoff removed //// level counters will not chagne for 3-4 clock during positive to negative side(or vice versa) change, so to consider this in scb added below logic
// leadoff removed //assign lead_off_vif.dac0_no_rest_silent_time = ((lead_off_vif.dac0_pos_check_delayed & lead_off_vif.dac0_neg_check) | (lead_off_vif.dac0_neg_check_delayed & lead_off_vif.dac0_pos_check)) ? 1 : 0 ;
// leadoff removed //assign lead_off_vif.dac1_no_rest_silent_time = ((lead_off_vif.dac1_pos_check_delayed & lead_off_vif.dac1_neg_check) | (lead_off_vif.dac1_neg_check_delayed & lead_off_vif.dac1_pos_check)) ? 1 : 0 ;
// leadoff removed // 
// leadoff removed //assign lead_off_vif.dac0_trig = (lead_off_vif.check_mode == 2'b00) ? ((lead_off_vif.dac0_pos_check | lead_off_vif.dac0_neg_check) & (~lead_off_vif.dac0_no_rest_silent_time)) 
// leadoff removed //                                : (lead_off_vif.check_mode == 2'b01) ? (lead_off_vif.dac0_pos_check)                             
// leadoff removed //                                : (lead_off_vif.check_mode == 2'b10) ? (lead_off_vif.dac0_neg_check)                             
// leadoff removed //                                : ((lead_off_vif.dac0_pos_check | lead_off_vif.dac0_neg_check) & (~lead_off_vif.dac0_no_rest_silent_time)) ;                            
// leadoff removed //     
// leadoff removed //assign lead_off_vif.dac1_trig = (lead_off_vif.check_mode == 2'b00) ? ((lead_off_vif.dac1_pos_check | lead_off_vif.dac1_neg_check) & (~lead_off_vif.dac1_no_rest_silent_time))
// leadoff removed //                                : (lead_off_vif.check_mode == 2'b01) ? (lead_off_vif.dac1_pos_check)                             
// leadoff removed //                                : (lead_off_vif.check_mode == 2'b10) ? (lead_off_vif.dac1_neg_check)                             
// leadoff removed //                                : ((lead_off_vif.dac1_pos_check | lead_off_vif.dac1_neg_check) & (~lead_off_vif.dac1_no_rest_silent_time)) ;
// leadoff removed //
// leadoff removed ////assign   lead_off_vif.lead_off_pulse_result[0]   =  `LEADOFF_TOP.lead_off_result[0]; // ch0 pulse 
// leadoff removed ////assign   lead_off_vif.lead_off_level_result[0]   =  `LEADOFF_TOP.lead_off_result[1]; // ch0 level 
// leadoff removed ////assign   lead_off_vif.lead_off_pulse_result[1]   =  `LEADOFF_TOP.lead_off_result1[0]; // ch1 pulse 
// leadoff removed ////assign   lead_off_vif.lead_off_level_result[1]   =  `LEADOFF_TOP.lead_off_result1[1]; // ch1 level 
// leadoff removed //
// leadoff removed //assign   lead_off_vif.dac0_wave_cnt     =   0;//Daniel `LEADOFF_TOP.o_out_wave_drivera_dac0;
// leadoff removed //assign   lead_off_vif.dac1_wave_cnt     =   0;//Daniel `LEADOFF_TOP.o_out_wave_drivera_dac1;
// leadoff removed ////assign   lead_off_vif.dac0_wave_cnt     =   `LEADOFF_TOP.o_out_wave_drivera_dac0 && (`ANA_TOP.D2A_DRIVERA_SOURCEA_CH1 || `ANA_TOP.D2A_DRIVERA_SOURCEB_CH1);
// leadoff removed ////assign   lead_off_vif.dac1_wave_cnt     =   `LEADOFF_TOP.o_out_wave_drivera_dac1 && (`ANA_TOP.D2A_DRIVERA_SOURCEA_CH2 || `ANA_TOP.D2A_DRIVERA_SOURCEB_CH2);   
// leadoff removed //
// leadoff removed //always@(negedge `LEADOFF_WRAPPER_TOP.i_pclk)begin
// leadoff removed // lead_off_vif.dac0_wave_cnt_delayed     <=   0;//Daniel `LEADOFF_TOP.o_out_wave_drivera_dac0;
// leadoff removed // lead_off_vif.dac1_wave_cnt_delayed     <=   0;//Daniel `LEADOFF_TOP.o_out_wave_drivera_dac1;
// leadoff removed // //lead_off_vif.dac0_wave_cnt_delayed     <=   `LEADOFF_TOP.o_out_wave_drivera_dac0 && (`ANA_TOP.D2A_DRIVERA_SOURCEA_CH1 || `ANA_TOP.D2A_DRIVERA_SOURCEB_CH1);
// leadoff removed // //lead_off_vif.dac1_wave_cnt_delayed     <=   `LEADOFF_TOP.o_out_wave_drivera_dac1 && (`ANA_TOP.D2A_DRIVERA_SOURCEA_CH2 || `ANA_TOP.D2A_DRIVERA_SOURCEB_CH2);   
// leadoff removed //end

//assign   lead_off_vif.lead_off_cnt_dac0     =   
///*`ifndef POSTSCAN  
//  `ifdef POSTLAYOUT_PG
//  {`LEADOFF_TOP.lead_off_cnt_dac0_reg_7_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac0_reg_6_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac0_reg_5_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac0_reg_4_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac0_reg_3_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac0_reg_2_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac0_reg_1_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac0_reg_0_.Q
//  };
//  `else
//  `LEADOFF_TOP.lead_off_cnt_dac0;
//  `endif
//`else
//  {`LEADOFF_TOP.lead_off_cnt_dac0_reg_7_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac0_reg_6_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac0_reg_5_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac0_reg_4_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac0_reg_3_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac0_reg_2_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac0_reg_1_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac0_reg_0_.Q
//  };
//`endif
//*/
//`ifdef BEHAVIORAL
//  `LEADOFF_TOP.lead_off_cnt_dac0;
//`else
//{`LEADOFF_TOP.lead_off_cnt_dac0_reg_7_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac0_reg_6_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac0_reg_5_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac0_reg_4_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac0_reg_3_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac0_reg_2_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac0_reg_1_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac0_reg_0_.Q
//  };
//`endif
//
//assign lead_off_vif.lead_off_level_cnt_dac0 = 
//`ifdef BEHAVIORAL
//  `LEADOFF_TOP.lead_off_level_cnt_dac0[31:0];
//`else
//  {`LEADOFF_TOP.lead_off_level_cnt_dac0_reg_31_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac0_reg_30_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac0_reg_29_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac0_reg_28_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac0_reg_27_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac0_reg_26_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac0_reg_25_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac0_reg_24_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac0_reg_23_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac0_reg_22_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac0_reg_21_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac0_reg_20_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac0_reg_19_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac0_reg_18_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac0_reg_17_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac0_reg_16_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac0_reg_15_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac0_reg_14_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac0_reg_13_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac0_reg_12_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac0_reg_11_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac0_reg_10_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac0_reg_9_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac0_reg_8_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac0_reg_7_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac0_reg_6_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac0_reg_5_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac0_reg_4_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac0_reg_3_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac0_reg_2_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac0_reg_1_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac0_reg_0_.Q 
//  };
//`endif
//
//assign lead_off_vif.lead_off_level_cnt_dac1 = 
//`ifdef BEHAVIORAL
//  `LEADOFF_TOP.lead_off_level_cnt_dac1[31:0];
//`else
//  {`LEADOFF_TOP.lead_off_level_cnt_dac1_reg_31_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac1_reg_30_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac1_reg_29_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac1_reg_28_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac1_reg_27_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac1_reg_26_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac1_reg_25_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac1_reg_24_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac1_reg_23_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac1_reg_22_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac1_reg_21_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac1_reg_20_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac1_reg_19_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac1_reg_18_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac1_reg_17_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac1_reg_16_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac1_reg_15_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac1_reg_14_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac1_reg_13_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac1_reg_12_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac1_reg_11_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac1_reg_10_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac1_reg_9_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac1_reg_8_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac1_reg_7_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac1_reg_6_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac1_reg_5_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac1_reg_4_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac1_reg_3_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac1_reg_2_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac1_reg_1_.Q, 
//   `LEADOFF_TOP.lead_off_level_cnt_dac1_reg_0_.Q 
//  };
//`endif
//
//assign   lead_off_vif.lead_off_cnt_dac1     =   
///*`ifndef POSTSCAN
//  `ifdef POSTLAYOUT_PG
//   {`LEADOFF_TOP.lead_off_cnt_dac1_reg_7_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac1_reg_6_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac1_reg_5_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac1_reg_4_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac1_reg_3_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac1_reg_2_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac1_reg_1_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac1_reg_0_.Q
//   };
//  `else
//  `LEADOFF_TOP.lead_off_cnt_dac1;
//  `endif
//`else
//  {`LEADOFF_TOP.lead_off_cnt_dac1_reg_7_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac1_reg_6_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac1_reg_5_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac1_reg_4_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac1_reg_3_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac1_reg_2_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac1_reg_1_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac1_reg_0_.Q
//  };
//`endif
//*/
//`ifdef BEHAVIORAL
//  `LEADOFF_TOP.lead_off_cnt_dac1;
//`else
//{`LEADOFF_TOP.lead_off_cnt_dac1_reg_7_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac1_reg_6_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac1_reg_5_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac1_reg_4_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac1_reg_3_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac1_reg_2_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac1_reg_1_.Q, 
//   `LEADOFF_TOP.lead_off_cnt_dac1_reg_0_.Q
//  };
//`endif

//`ifdef BEHAVIORAL
//assign   lead_off_vif.dac0_setdly_cnt   =   `LEADOFF_TOP.measure_dly_cnt_dac0;
//assign   lead_off_vif.dac1_setdly_cnt   =   `LEADOFF_TOP.measure_dly_cnt_dac1;
//`endif

// leadoff removed //assign   lead_off_vif.lead_off_sts_clear[0] =   `LEADOFF_TOP_0.lead_off_sts_clear;                                             
// leadoff removed //assign   lead_off_vif.lead_off_sts_clear[1] =   `LEADOFF_TOP_1.lead_off_sts_clear;                                             

////Supriya starting to add
//assign dut_vif.dut_ana_stimu_ch1_intr_sts = `ANAC_TOP.u_anac_short_dtct_ch1.o_ana_stimu_chx_intr_sts;  
//assign dut_vif.dut_ana_stimu_ch2_intr_sts = `ANAC_TOP.u_anac_short_dtct_ch2.o_ana_stimu_chx_intr_sts;
//
//assign dut_vif.ana_stimu_ch1_intr_sts_clr      = `DIG_TOP.u_anac.ana_stimu_ch1_intr_sts_clr;  //14/07/2025 added by supriya
//assign dut_vif.ana_stimu_ch2_intr_sts_clr      = `DIG_TOP.u_anac.ana_stimu_ch2_intr_sts_clr;  //14/07/2025 added by supriya
//
//`ifdef BEHAVIORAL
//  assign dut_vif.wg_enable[0]      = `WG_DRIVER_TOP.wg_driver_top_inst.genblk1[0].arb_wave_gen_inst.enable;  //through register configuration passed to sync modules so considered from this path instead from spi reg configuration
//  assign dut_vif.wg_enable[1]      = `WG_DRIVER_TOP.wg_driver_top_inst.genblk1[1].arb_wave_gen_inst.enable;
//`else 
//  assign dut_vif.wg_enable[0]      = `WG_DRIVER_TOP.wg_driver_top_inst.genblk1_0__arb_wave_gen_inst.enable;
//  assign dut_vif.wg_enable[1]      = `WG_DRIVER_TOP.wg_driver_top_inst.genblk1_1__arb_wave_gen_inst.enable;
//`endif
////assign dut_vif.wavegen_en[1:0]                 = `DIG_TOP.drive_en[1:0]; //14/07/2025 added by supriya , Pending to get from testcase
//
//assign dut_vif.expected_short_ch1_resp_cnt_en   = dut_vif.short_detect_by_lead_off_en ? dut_vif.anac_stim_CH1_pol ? ~`ANA_TOP.A2D_COMP_OUT_CH1 : `ANA_TOP.A2D_COMP_OUT_CH1 : dut_vif.anac_stim_CH1_pol ? ~`ANA_TOP.A2D_COMP_OUT_STIMU0_1 : `ANA_TOP.A2D_COMP_OUT_STIMU0_1 ; //`DUT_IF.anac_stim_CH2_intr_en, `DUT_IF.anac_stim_CH1_intr_en, `DUT_IF.anac_stim_CH2_pol, `DUT_IF.anac_stim_CH1_pol
//assign dut_vif_expected_short_ch2_resp_cnt_en   = dut_vif.short_detect_by_lead_off_en ? dut_vif.anac_stim_CH2_pol ? `ANA_TOP.A2D_COMP_OUT_CH2  : `ANA_TOP.A2D_COMP_OUT_CH2 : dut_vif.anac_stim_CH2_pol ? ~`ANA_TOP.A2D_COMP_OUT_STIMU2_3 : `ANA_TOP.A2D_COMP_OUT_STIMU2_3;
//assign dut_vif.A2D_COMP_OUT_CH1                         = dut_vif.lead_off_detect_by_short_circuit_en ? `ANA_TOP.A2D_COMP_OUT_CH1 : `ANA_TOP.A2D_COMP_OUT_STIMU0_1;
//assign dut_vif.A2D_COMP_OUT_CH2                         = dut_vif.lead_off_detect_by_short_circuit_en ? `ANA_TOP.A2D_COMP_OUT_CH2 : `ANA_TOP.A2D_COMP_OUT_STIMU2_3;
//assign dut_vif.A2D_COMP_OUT_CH1_tmp                     = dut_vif.lead_off_ch0_comp_low_active ? ~dut_vif.A2D_COMP_OUT_CH1 : dut_vif.A2D_COMP_OUT_CH1;
//assign dut_vif.A2D_COMP_OUT_CH2_tmp                     = dut_vif.lead_off_ch1_comp_low_active ? ~dut_vif.A2D_COMP_OUT_CH1 : dut_vif.A2D_COMP_OUT_CH1;
//assign dut_vif.expected_ch0_leadoff_en                  = dut_vif.lead_off_comp_reverse ? dut_vif.A2D_COMP_OUT_CH2_tmp : dut_vif.A2D_COMP_OUT_CH1_tmp;
//assign dut_vif.expected_ch1_leadoff_en                  = dut_vif.lead_off_comp_reverse ? dut_vif.A2D_COMP_OUT_CH1_tmp : dut_vif.A2D_COMP_OUT_CH2_tmp;
//assign dut_vif.dut_short_ch1_timer_th_cnt	        = `ANAC_TOP.u_anac_short_dtct_ch1.timer_th_cnt;
//assign dut_vif.dut_short_ch2_timer_th_cnt	        = `ANAC_TOP.u_anac_short_dtct_ch2.timer_th_cnt;
//assign dut_vif.dut_short_ch1_counter_th_cnt             = `ANAC_TOP.u_anac_short_dtct_ch1.counter_th_cnt;
//assign dut_vif.dut_short_ch2_counter_th_cnt             = `ANAC_TOP.u_anac_short_dtct_ch2.counter_th_cnt;
//assign dut_vif.dut_timer_cnt_cnt_dac0			= `LEADOFF_TOP.timer_cnt_cnt_dac0;       	
//assign dut_vif.dut_timer_cnt_cnt_dac1                   = `LEADOFF_TOP.timer_cnt_cnt_dac1;
//assign dut_vif.dut_lead_off_Counter_cnt_dac0            = `LEADOFF_TOP.lead_off_Counter_cnt_dac0;
//assign dut_vif.dut_lead_off_Counter_cnt_dac1            = `LEADOFF_TOP.lead_off_Counter_cnt_dac1;
//assign dut_vif.leadoff_pclk                             = `LEADOFF_WRAPPER_TOP.i_pclk;
//assign dut_vif.leadoff_presetn                          = `LEADOFF_WRAPPER_TOP.i_presetn;
//assign dut_vif.anac_pclk                                = `ANAC_TOP.sysclk;
//assign dut_vif.anac_presetn                             = `ANAC_TOP.presetn;
////supriya ends ading


initial begin
    nnc_config_db#(virtual nnc_lead_off_interface)::set(uvm_root::get(), "uvm_test_top.*", "lead_off_vif", lead_off_vif);
end
