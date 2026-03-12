/*--------------------------------------------------------------------------------------*/
// Copyright 2021 Nanochap, Inc.
// All Rights Reserved Worldwide
// --------------------------------------------------------------------------------------
// Project      : Nanochap ENS2
// File         : tb_chip_top_uvm_spi.sv
// Description  : SPI TB 
// Designer     : Daniel Dang
// Date         : 18-03-2024
// Revision     : 0.1
/*--------------------------------------------------------------------------------------*/
wire IOBUF_CPOLn, IOBUF_CPHA;

spi_master_vip spim_vip 
(
.spi_rst_n(sys_rst_n),
.spi_clk(sys_clk),
.spi_clk_sel(dut_vif.pclk_sel),
.spi_sclk_freq(dut_vif.spi_sclk_freq),         // unit is Khz (1Khz to 16.000Khz)
.spi_clk_jitter(dut_vif.spi_clk_jitter),       // unit is percentage (0-100)
.spi_sclk_jitter(dut_vif.spi_sclk_jitter),     // unit is percentage (0-100)
.tcssc(dut_vif.tcssc),   
.tsccs(dut_vif.tsccs),                         // min is 17ns
.tcsh(dut_vif.tcsh),                           // min is 2 tcks (1/spi_clk)
.tdist(dut_vif.tdist),                         // unit is percentage (0-100)
.tch(dut_vif.tch),                             // unit is percentage (0-100)
.spi_nss(spi_nss),
.spi_sck(spi_sck),
.spi_mosi(spi_mosi),
.spi_miso(spi_miso),
.spi_mode(dut_vif.spimode_sel),
.spi_cpol(IOBUF_CPOLn),
.spi_cpha(IOBUF_CPHA)
);

`ifndef BEHAVIORAL
always @(*)
  begin
    if (`SOC_TOP.VDD_DIG == 0) force dut_vif.io_model_check_off = 1'b1;
    else release dut_vif.io_model_check_off;
  end 

initial begin
  force `SOC_TOP.u_iopad_gpio_0_.PAD = 1'b0;
  force `SOC_TOP.u_iopad_gpio_1_.PAD = 1'b0;
  force `SOC_TOP.u_iopad_gpio_2_.PAD = 1'b0;
  force `SOC_TOP.u_iopad_gpio_3_.PAD = 1'b0;
  force `SOC_TOP.u_iopad_gpio_4_.PAD = 1'b0;
  force `SOC_TOP.u_iopad_gpio_5_.PAD = 1'b0;
  force `SOC_TOP.u_iopad_gpio_10_.PAD = 1'b0;

  force `SOC_TOP_1.u_iopad_gpio_0_.PAD = 1'b0;
  force `SOC_TOP_1.u_iopad_gpio_1_.PAD = 1'b0;
  force `SOC_TOP_1.u_iopad_gpio_2_.PAD = 1'b0;
  force `SOC_TOP_1.u_iopad_gpio_3_.PAD = 1'b0;
  force `SOC_TOP_1.u_iopad_gpio_4_.PAD = 1'b0;
  force `SOC_TOP_1.u_iopad_gpio_5_.PAD = 1'b0;
  force `SOC_TOP_1.u_iopad_gpio_10_.PAD = 1'b0;

  force `SOC_TOP_2.u_iopad_gpio_0_.PAD = 1'b0;
  force `SOC_TOP_2.u_iopad_gpio_1_.PAD = 1'b0;
  force `SOC_TOP_2.u_iopad_gpio_2_.PAD = 1'b0;
  force `SOC_TOP_2.u_iopad_gpio_3_.PAD = 1'b0;
  force `SOC_TOP_2.u_iopad_gpio_4_.PAD = 1'b0;
  force `SOC_TOP_2.u_iopad_gpio_5_.PAD = 1'b0;
  force `SOC_TOP_2.u_iopad_gpio_10_.PAD = 1'b0;

  #1us;
  release `SOC_TOP.u_iopad_gpio_0_.PAD;
  release `SOC_TOP.u_iopad_gpio_1_.PAD;
  release `SOC_TOP.u_iopad_gpio_2_.PAD;
  release `SOC_TOP.u_iopad_gpio_3_.PAD;
  release `SOC_TOP.u_iopad_gpio_4_.PAD;
  release `SOC_TOP.u_iopad_gpio_5_.PAD ;
  release `SOC_TOP.u_iopad_gpio_10_.PAD;

  release `SOC_TOP_1.u_iopad_gpio_0_.PAD;
  release `SOC_TOP_1.u_iopad_gpio_1_.PAD;
  release `SOC_TOP_1.u_iopad_gpio_2_.PAD;
  release `SOC_TOP_1.u_iopad_gpio_3_.PAD;
  release `SOC_TOP_1.u_iopad_gpio_4_.PAD;
  release `SOC_TOP_1.u_iopad_gpio_5_.PAD ;
  release `SOC_TOP_1.u_iopad_gpio_10_.PAD;

  release `SOC_TOP_2.u_iopad_gpio_0_.PAD;
  release `SOC_TOP_2.u_iopad_gpio_1_.PAD;
  release `SOC_TOP_2.u_iopad_gpio_2_.PAD;
  release `SOC_TOP_2.u_iopad_gpio_3_.PAD;
  release `SOC_TOP_2.u_iopad_gpio_4_.PAD;
  release `SOC_TOP_2.u_iopad_gpio_5_.PAD ;
  release `SOC_TOP_2.u_iopad_gpio_10_.PAD;

end
`endif

nnc_spi_interface   spi_vif();

assign    spi_vif.i_scanclk  = `SPI_TOP.i_scanclk;
assign    spi_vif.i_rst_n    = `SPI_TOP.spi_reg_u.i_rst_n;

assign    spi_vif.iopad_cpha = `SOC_TB.IOBUF_CPHA;
assign    spi_vif.iopad_cpol = `SOC_TB.IOBUF_CPOLn;
assign    spi_vif.i_sclk     = `SOC_TB.spi_sck;
assign    spi_vif.i_cs_n     = ((dut_vif.mult_chip_en === 1'b1) && (dut_vif.mult_chip_mode === 2'b10)) ? 1'b1 : `SOC_TB.spi_nss; //`SOC_TB.spi_nss;
assign    spi_vif.i_mosi     = `SOC_TB.spi_mosi;
assign    spi_vif.o_miso     = `SOC_TB.spi_miso;


assign    spi_vif.i_pclk              =       `CLK_CTRL_TOP.pclk        ;
assign    spi_vif.i_clk               =       `SPI_TOP.spi_reg_u.i_clk  ;
`ifdef POSTLAYOUT
assign    spi_vif.resetn              =       `SPI_TOP.spi_reg_u.i_rst_n; //`SPI_TOP.IN8          ;
`else
assign    spi_vif.resetn              =       `SPI_TOP.i_rst_n          ;
`endif
assign    spi_vif.i_fclk              =       `CLK_CTRL_TOP.hfosc_atpg  ;

/*
`ifdef BEHAVIORAL

assign    spi_vif.REG_BACKDOOR[0][8'h01]         =   `SPI_TOP.spi_reg_u.pmu_reg0 ;
assign    spi_vif.REG_BACKDOOR[0][8'h02]         =   `SPI_TOP.spi_reg_u.clk_ctrl_reg;
assign    spi_vif.REG_BACKDOOR[0][8'h03]         =   {7'b0, `SPI_TOP.spi_reg_u.drivea_global_en};
assign    spi_vif.REG_BACKDOOR[0][8'h04]         =   {6'b0, `SPI_TOP.spi_reg_u.anac_ctrl};  
assign    spi_vif.REG_BACKDOOR[0][8'h05]         =   `SPI_TOP.spi_reg_u.pmu_reg1 ; 
assign    spi_vif.REG_BACKDOOR[0][8'h06]         =   {7'b0, `SPI_TOP.spi_reg_u.o_clk_sel} ;
assign    spi_vif.REG_BACKDOOR[0][8'h0a]         =   `SPI_TOP.spi_reg_u.i_DEBUG_otp[7:0];
assign    spi_vif.REG_BACKDOOR[0][8'h0b]         =   `SPI_TOP.spi_reg_u.i_DEBUG_otp[15:8];
assign    spi_vif.REG_BACKDOOR[0][8'h0c]         =   `SPI_TOP.spi_reg_u.trim_tag_reg[7:0];
assign    spi_vif.REG_BACKDOOR[0][8'h0d]         =   `SPI_TOP.spi_reg_u.d2a_trim1_to_otp[7:0];   
assign    spi_vif.REG_BACKDOOR[0][8'h0e]         =   `SPI_TOP.spi_reg_u.d2a_trim2_to_otp[7:0];   
assign    spi_vif.REG_BACKDOOR[0][8'h0f]         =   `SPI_TOP.spi_reg_u.d2a_trim3_to_otp[7:0];   
assign    spi_vif.REG_BACKDOOR[0][8'h10]         =   `SPI_TOP.spi_reg_u.d2a_trim4_to_otp[7:0];   
assign    spi_vif.REG_BACKDOOR[0][8'h11]         =   `SPI_TOP.spi_reg_u.d2a_trim5_to_otp[7:0];   
assign    spi_vif.REG_BACKDOOR[0][8'h12]         =   `SPI_TOP.spi_reg_u.d2a_trim6_to_otp[7:0];
assign    spi_vif.REG_BACKDOOR[0][8'h13]         =   `SPI_TOP.spi_reg_u.d2a_trim7_to_otp[7:0];   
assign    spi_vif.REG_BACKDOOR[0][8'h14]         =   `SPI_TOP.spi_reg_u.d2a_trim8_to_otp[7:0];   
assign    spi_vif.REG_BACKDOOR[0][8'h15]         =   {`SPI_TOP.spi_reg_u.unlock_reg};
assign    spi_vif.REG_BACKDOOR[0][8'h16]         =   `SPI_TOP.spi_reg_u.spi_otp_data[7:0];   
assign    spi_vif.REG_BACKDOOR[0][8'h17]         =   {`SPI_TOP.spi_reg_u.spi_otp_addr};
assign    spi_vif.REG_BACKDOOR[0][8'h18]         =   {7'b0,`SPI_TOP.spi_reg_u.spi_otp_addr01};
assign    spi_vif.REG_BACKDOOR[0][8'h19]         =   `SPI_TOP.spi_reg_u.otp_data_spi_sync[7:0];
assign    spi_vif.REG_BACKDOOR[0][8'h20]         =   `SPI_TOP.spi_reg_u.pd_ctrl;
assign    spi_vif.REG_BACKDOOR[0][8'h21]         =   `SPI_TOP.spi_reg_u.ds_ctrl;              
assign    spi_vif.REG_BACKDOOR[0][8'h22]         =   {6'b0, `SPI_TOP.spi_reg_u.comp_out_ctrl};
assign    spi_vif.REG_BACKDOOR[0][8'h26]         =   `SPI_TOP.spi_reg_u.lead_off_ctrl 	;
assign    spi_vif.REG_BACKDOOR[0][8'h27]         =   `SPI_TOP.spi_reg_u.lead_off_tgt_reg 	; 
assign    spi_vif.REG_BACKDOOR[0][8'h28]         =   {1'b0, `SPI_TOP.spi_reg_u.lead_off_int[6:0]};
assign    spi_vif.REG_BACKDOOR[0][8'h29]         =   `SPI_TOP.spi_reg_u.counter_th_tgt_0 ;
assign    spi_vif.REG_BACKDOOR[0][8'h2a]         =   `SPI_TOP.spi_reg_u.counter_th_tgt_1 ;
assign    spi_vif.REG_BACKDOOR[0][8'h2b]         =   `SPI_TOP.spi_reg_u.counter_th_tgt_2 ;
assign    spi_vif.REG_BACKDOOR[0][8'h2c]         =   `SPI_TOP.spi_reg_u.counter_th_tgt_3 ;
assign    spi_vif.REG_BACKDOOR[0][8'h2d]         =   `SPI_TOP.spi_reg_u.timer_cnt_tgt_0 	; 
assign    spi_vif.REG_BACKDOOR[0][8'h2e]         =   `SPI_TOP.spi_reg_u.timer_cnt_tgt_1 	; 
assign    spi_vif.REG_BACKDOOR[0][8'h2f]         =   `SPI_TOP.spi_reg_u.timer_cnt_tgt_2 	; 
assign    spi_vif.REG_BACKDOOR[0][8'h30]         =   `SPI_TOP.spi_reg_u.timer_cnt_tgt_3 	; 
assign    spi_vif.REG_BACKDOOR[0][8'h31]         =   `SPI_TOP.spi_reg_u.counter_th_tgt1[7:0];
assign    spi_vif.REG_BACKDOOR[0][8'h32]         =   `SPI_TOP.spi_reg_u.counter_th_tgt1[15:8];
assign    spi_vif.REG_BACKDOOR[0][8'h33]         =   `SPI_TOP.spi_reg_u.counter_th_tgt1[23:16];
assign    spi_vif.REG_BACKDOOR[0][8'h34]         =   `SPI_TOP.spi_reg_u.counter_th_tgt1[31:24];
assign    spi_vif.REG_BACKDOOR[0][8'h35]         =   `SPI_TOP.spi_reg_u.timer_cnt_tgt1_0[7:0];
assign    spi_vif.REG_BACKDOOR[0][8'h36]         =   `SPI_TOP.spi_reg_u.timer_cnt_tgt1_1[7:0];
assign    spi_vif.REG_BACKDOOR[0][8'h37]         =   `SPI_TOP.spi_reg_u.timer_cnt_tgt1_2[7:0];
assign    spi_vif.REG_BACKDOOR[0][8'h38]         =   `SPI_TOP.spi_reg_u.timer_cnt_tgt1_3[7:0];
assign    spi_vif.REG_BACKDOOR[0][8'h39]         =   {6'b0, `SPI_TOP.spi_reg_u.A2D_COMP2, `SPI_TOP.spi_reg_u.A2D_COMP1};
assign    spi_vif.REG_BACKDOOR[0][8'h40]         =   `SPI_TOP.spi_reg_u.ana_enable_reg_0 ; 
assign    spi_vif.REG_BACKDOOR[0][8'h41]         =   `SPI_TOP.spi_reg_u.ana_enable_reg_1 ; 
assign    spi_vif.REG_BACKDOOR[0][8'h42]         =   `SPI_TOP.spi_reg_u.ana_enable_reg_2 ; 
assign    spi_vif.REG_BACKDOOR[0][8'h43]         =   `SPI_TOP.spi_reg_u.ana_enable_reg_3 ;
assign    spi_vif.REG_BACKDOOR[0][8'h44]         =   `SPI_TOP.spi_reg_u.ana_gen_reg_1 ; 
assign    spi_vif.REG_BACKDOOR[0][8'h45]         =   `SPI_TOP.spi_reg_u.ana_gen_reg_2 ; 
assign    spi_vif.REG_BACKDOOR[0][8'h46]         =   `SPI_TOP.spi_reg_u.ana_gen_reg_3 ; 
assign    spi_vif.REG_BACKDOOR[0][8'h47]         =   `SPI_TOP.spi_reg_u.ana_gen_reg_4 ; 
assign    spi_vif.REG_BACKDOOR[0][8'h48]         =   `SPI_TOP.spi_reg_u.ana_gen_reg_5 ; 
assign    spi_vif.REG_BACKDOOR[0][8'h49]         =   `SPI_TOP.spi_reg_u.ana_gen_reg_6 ; 
assign    spi_vif.REG_BACKDOOR[0][8'h4a]         =   `SPI_TOP.spi_reg_u.ana_gen_reg_7 ; 
assign    spi_vif.REG_BACKDOOR[0][8'h4B]         =   `SPI_TOP.spi_reg_u.ana_gen_reg_8 ; 
assign    spi_vif.REG_BACKDOOR[0][8'h4C]         =   `SPI_TOP.spi_reg_u.ana_gen_reg_9 ; 
assign    spi_vif.REG_BACKDOOR[0][8'h4d]         =   {5'h0, `ANA_TOP.A2D_COMP_OUT_STIMU2_3, `ANA_TOP.A2D_COMP_OUT_STIMU0_1, `ANA_TOP.A2D_LVD} ;
assign    spi_vif.REG_BACKDOOR[0][8'h4e]         =   `ANA_TOP.A2D_SPARE_RO_REG_0 ;

assign    spi_vif.REG_BACKDOOR[0][8'h50]         =   { 3'b0,
                                                       `SPI_TOP.ana_comp_ch2_intr_trans_sel,
                                                       `SPI_TOP.ana_comp_ch1_intr_trans_sel,
                                                       `SPI_TOP.spi_reg_u.ana_comp_ch2_intr_en, 
                                                       `SPI_TOP.spi_reg_u.ana_comp_ch1_intr_en, 
                                                       `SPI_TOP.spi_reg_u.ana_lvd_intr_en
                                                     };
assign    spi_vif.REG_BACKDOOR[0][8'h51]         =   {5'b0, `SPI_TOP.spi_reg_u.ana_int_comp_pol_reg}; 
assign    spi_vif.REG_BACKDOOR[0][8'h52]         =   {6'b0, `SPI_TOP.spi_reg_u.ana_int_stop_wavegen_reg};
assign    spi_vif.REG_BACKDOOR[0][8'h53]         =   `SPI_TOP.spi_reg_u.ana_int_ch1_timer_th_reg[7:0] ;
assign    spi_vif.REG_BACKDOOR[0][8'h54]         =   `SPI_TOP.spi_reg_u.ana_int_ch1_timer_th_reg[15:8]; 
assign    spi_vif.REG_BACKDOOR[0][8'h55]         =   `SPI_TOP.spi_reg_u.ana_int_ch1_timer_th_reg[23:16]; 
assign    spi_vif.REG_BACKDOOR[0][8'h56]         =   `SPI_TOP.spi_reg_u.ana_int_ch1_timer_th_reg[31:24]; 
assign    spi_vif.REG_BACKDOOR[0][8'h57]         =   `SPI_TOP.spi_reg_u.ana_int_ch1_cnt_th_reg[7:0];
assign    spi_vif.REG_BACKDOOR[0][8'h58]         =   `SPI_TOP.spi_reg_u.ana_int_ch1_cnt_th_reg[15:8];
assign    spi_vif.REG_BACKDOOR[0][8'h59]         =   `SPI_TOP.spi_reg_u.ana_int_ch1_cnt_th_reg[23:16];
assign    spi_vif.REG_BACKDOOR[0][8'h5a]         =   `SPI_TOP.spi_reg_u.ana_int_ch1_cnt_th_reg[31:24];
assign    spi_vif.REG_BACKDOOR[0][8'h5b]         =   `SPI_TOP.spi_reg_u.ana_int_ch2_timer_th_reg[7:0] ;
assign    spi_vif.REG_BACKDOOR[0][8'h5c]         =   `SPI_TOP.spi_reg_u.ana_int_ch2_timer_th_reg[15:8]; 
assign    spi_vif.REG_BACKDOOR[0][8'h5d]         =   `SPI_TOP.spi_reg_u.ana_int_ch2_timer_th_reg[23:16];
assign    spi_vif.REG_BACKDOOR[0][8'h5e]         =   `SPI_TOP.spi_reg_u.ana_int_ch2_timer_th_reg[31:24]; 
assign    spi_vif.REG_BACKDOOR[0][8'h5f]         =   `SPI_TOP.spi_reg_u.ana_int_ch2_cnt_th_reg[7:0];
assign    spi_vif.REG_BACKDOOR[0][8'h60]         =   `SPI_TOP.spi_reg_u.ana_int_ch2_cnt_th_reg[15:8];
assign    spi_vif.REG_BACKDOOR[0][8'h61]         =   `SPI_TOP.spi_reg_u.ana_int_ch2_cnt_th_reg[23:16];
assign    spi_vif.REG_BACKDOOR[0][8'h62]         =   `SPI_TOP.spi_reg_u.ana_int_ch2_cnt_th_reg[31:24];
assign    spi_vif.REG_BACKDOOR[0][8'h63]         =   {6'b0,`SPI_TOP.spi_reg_u.ana_stimu_ch2_intr_sts, `SPI_TOP.spi_reg_u.ana_stimu_ch1_intr_sts};
assign    spi_vif.REG_BACKDOOR[0][8'h64]         =   {5'b0, `SPI_TOP.spi_reg_u.ana_comp_ch2_intr_sts, `SPI_TOP.spi_reg_u.ana_comp_ch1_intr_sts, `ANA_TOP.A2D_LVD && spi_vif.REG_BACKDOOR[0][8'h52][0]};
assign    spi_vif.REG_BACKDOOR[0][8'h6b]         =   `SPI_TOP.spi_reg_u.en_reg_sel;
assign    spi_vif.REG_BACKDOOR[0][8'h6c]         =   {4'b0,`SPI_TOP.spi_reg_u.tsc_ctrl};
assign    spi_vif.REG_BACKDOOR[0][8'h6d]         =   `SPI_TOP.spi_reg_u.sample_duration;
assign    spi_vif.REG_BACKDOOR[0][8'h6e]         =   `SPI_TOP.spi_reg_u.stable_duration;
assign    spi_vif.REG_BACKDOOR[0][8'h6f]         =   {4'h0, `SPI_TOP.spi_reg_u.stable_duration[11:8]};
assign    spi_vif.REG_BACKDOOR[0][8'h70]         =   `SPI_TOP.tsc_vdac8b_din_ch1;
assign    spi_vif.REG_BACKDOOR[0][8'h71]         =   {6'b0,`SPI_TOP.spi_reg_u.tsc_int_crtl_reg};
assign    spi_vif.REG_BACKDOOR[0][8'h72]         =   8'hxx; //RO  int status
assign    spi_vif.REG_BACKDOOR[0][8'h73]         =   8'hxx; //RO  VDAC_NOR
assign    spi_vif.REG_BACKDOOR[0][8'h74]         =   8'hxx; //RO  tsc smp sts
assign    spi_vif.REG_BACKDOOR[0][8'h78]         =   {5'b0, `SPI_TOP.spi_reg_u.int_ctrl_reg};
assign    spi_vif.REG_BACKDOOR[0][8'h79]         =   8'hxx; //RO 
assign    spi_vif.REG_BACKDOOR[0][8'h7a]         =   8'hxx; //RO 

assign #10   spi_vif.REG_BACKDOOR[0][8'h7e]         =   {6'b0, `SPI_TOP.spi_reg_u.atm_hc_sel_reg};

assign    spi_vif.REG_BACKDOOR[0][8'h80]         =   {6'b0, `SPI_TOP.spi_reg_u.counter_cnt_dbg_sel[1:0]};
assign    spi_vif.REG_BACKDOOR[0][8'h81]         =   `SPI_TOP.spi_reg_u.counter_cnt_dbg[7:0];
assign    spi_vif.REG_BACKDOOR[0][8'h82]         =   `SPI_TOP.spi_reg_u.counter_cnt_dbg[15:8];
assign    spi_vif.REG_BACKDOOR[0][8'h83]         =   `SPI_TOP.spi_reg_u.counter_cnt_dbg[23:16];
assign    spi_vif.REG_BACKDOOR[0][8'h84]         =   `SPI_TOP.spi_reg_u.counter_cnt_dbg[31:24];
assign    spi_vif.REG_BACKDOOR[0][8'h85]         =   8'hxx; // RO
assign    spi_vif.REG_BACKDOOR[0][8'h86]         =   8'hxx; // RO
`endif
*/

/*
`else
 
assign    spi_vif.REG_BACKDOOR[0][8'h01]         =       { `SPI_TOP.spi_reg_u.pmu_reg0_reg_7_.Q ,
                                                           `SPI_TOP.spi_reg_u.pmu_reg0_reg_6_.Q ,
                                                           `SPI_TOP.spi_reg_u.pmu_reg0_reg_5_.Q ,
                                                           `SPI_TOP.spi_reg_u.pmu_reg0_reg_4_.Q ,
                                                           `SPI_TOP.spi_reg_u.pmu_reg0_reg_3_.Q , 
                                                           `SPI_TOP.spi_reg_u.pmu_reg0_reg_2_.Q ,
                                                           `SPI_TOP.spi_reg_u.pmu_reg0_reg_1_.Q ,
                                                           `SPI_TOP.spi_reg_u.pmu_reg0_reg_0_.Q
                                                         };

assign    spi_vif.REG_BACKDOOR[0][8'h02]         =       { `SPI_TOP.spi_reg_u.clk_ctrl_reg_reg_3_.Q, 
                                                           `SPI_TOP.spi_reg_u.clk_ctrl_reg_reg_2_.Q, 
                                                           `SPI_TOP.spi_reg_u.clk_ctrl_reg_reg_1_.Q, 
                                                           `SPI_TOP.spi_reg_u.clk_ctrl_reg_reg_0_.Q
                                                         };

assign    spi_vif.REG_BACKDOOR[0][8'h03]         =       { 7'b0, `SPI_TOP.spi_reg_u.drivea_global_en_reg.Q };

`ifdef BEHAVIORAL
   assign    spi_vif.REG_BACKDOOR[0][8'h04]      =       { 7'b0, `SPI_TOP.spi_reg_u.anac_clock_en_reg.Q };
`else
   assign    spi_vif.REG_BACKDOOR[0][8'h04]      =       { 7'b0, `SPI_TOP.spi_reg_u.anac_clock_en_reg.Q };
`endif

assign    spi_vif.REG_BACKDOOR[0][8'h05]         =       { `SPI_TOP.spi_reg_u.pmu_reg1_reg_7_.Q,
                                                           `SPI_TOP.spi_reg_u.pmu_reg1_reg_6_.Q,
                                                           `SPI_TOP.spi_reg_u.pmu_reg1_reg_5_.Q, 
                                                           `SPI_TOP.spi_reg_u.pmu_reg1_reg_4_.Q,
                                                           `SPI_TOP.spi_reg_u.pmu_reg1_reg_3_.Q, 
                                                           `SPI_TOP.spi_reg_u.pmu_reg1_reg_2_.Q,
                                                           `SPI_TOP.spi_reg_u.pmu_reg1_reg_1_.Q,
                                                           `SPI_TOP.spi_reg_u.pmu_reg1_reg_0_.Q
                                                          };

assign    spi_vif.REG_BACKDOOR[0][8'h06]         =        { 7'b0, `SPI_TOP.spi_reg_u.o_clk_sel_reg.Q };

assign    spi_vif.REG_BACKDOOR[0][8'h10]         =       `SPI_TOP.spi_otp_os_ctrl[9:2];

assign    spi_vif.REG_BACKDOOR[0][8'h11]         =       `SPI_TOP.spi_otp_os_ctrl[17:10];

assign    spi_vif.REG_BACKDOOR[0][8'h12]         =       `SPI_TOP.spi_otp_trim[7:0];

assign    spi_vif.REG_BACKDOOR[0][8'h13]         =       `SPI_TOP.spi_otp_trim[15:8]  ;   

assign    spi_vif.REG_BACKDOOR[0][8'h14]         =       `SPI_TOP.spi_otp_trim[23:16] ;   

assign    spi_vif.REG_BACKDOOR[0][8'h15]         =       `SPI_TOP.spi_otp_trim[31:24] ;   

assign    spi_vif.REG_BACKDOOR[0][8'h16]         =       `SPI_TOP.spi_otp_trim[39:32] ;   

assign    spi_vif.REG_BACKDOOR[0][8'h17]         =       `SPI_TOP.spi_otp_trim[47:40] ;   

assign    spi_vif.REG_BACKDOOR[0][8'h18]         =       `SPI_TOP.spi_otp_trim[55:48] ;   

assign    spi_vif.REG_BACKDOOR[0][8'h19]         =       `SPI_TOP.spi_otp_trim[63:56] ;   

assign    spi_vif.REG_BACKDOOR[0][8'h1A]         =       `SPI_TOP.spi_otp_trim[71:64] ;   

assign    spi_vif.REG_BACKDOOR[0][8'h1B]         =       { 7'b0,`SPI_TOP.spi_otp_so_ctrl[0] };

assign    spi_vif.REG_BACKDOOR[0][8'h1C]         =       { `SPI_TOP.spi_reg_u.spi_otp_data_reg_7_.Q,
                                                           `SPI_TOP.spi_reg_u.spi_otp_data_reg_6_.Q, 
                                                           `SPI_TOP.spi_reg_u.spi_otp_data_reg_5_.Q, 
                                                           `SPI_TOP.spi_reg_u.spi_otp_data_reg_4_.Q, 
                                                           `SPI_TOP.spi_reg_u.spi_otp_data_reg_3_.Q,
                                                           `SPI_TOP.spi_reg_u.spi_otp_data_reg_2_.Q,
                                                           `SPI_TOP.spi_reg_u.spi_otp_data_reg_1_.Q, 
                                                           `SPI_TOP.spi_reg_u.spi_otp_data_reg_0_.Q
                                                         };
   
assign    spi_vif.REG_BACKDOOR[0][8'h1D]         =   { `SPI_TOP.spi_reg_u.spi_otp_addr_reg_7_.Q, 
                                                       `SPI_TOP.spi_reg_u.spi_otp_addr_reg_6_.Q, 
                                                       `SPI_TOP.spi_reg_u.spi_otp_addr_reg_5_.Q, 
                                                       `SPI_TOP.spi_reg_u.spi_otp_addr_reg_4_.Q, 
                                                       `SPI_TOP.spi_reg_u.spi_otp_addr_reg_3_.Q, 
                                                       `SPI_TOP.spi_reg_u.spi_otp_addr_reg_2_.Q, 
                                                       `SPI_TOP.spi_reg_u.spi_otp_addr_reg_1_.Q, 
                                                       `SPI_TOP.spi_reg_u.spi_otp_addr_reg_0_.Q
                                                     };

assign    spi_vif.REG_BACKDOOR[0][8'h1f]         =   `SPI_TOP.spi_reg_u.spi_otp_os_ctrl[26:19]; //{`SPI_TOP.spi_reg_u.otp_data_spi_sync_reg_7_.Q, `SPI_TOP.spi_reg_u.otp_data_spi_sync_reg_6_.Q, `SPI_TOP.spi_reg_u.otp_data_spi_sync_reg_5_.Q, `SPI_TOP.spi_reg_u.otp_data_spi_sync_reg_4_.Q, `SPI_TOP.spi_reg_u.otp_data_spi_sync_reg_3_.Q, `SPI_TOP.spi_reg_u.otp_data_spi_sync_reg_2_.Q, `SPI_TOP.spi_reg_u.otp_data_spi_sync_reg_1_.Q, `SPI_TOP.spi_reg_u.otp_data_spi_sync_reg_0_.Q};

assign    spi_vif.REG_BACKDOOR[0][8'h1e]         =   {7'b0,`SPI_TOP.spi_reg_u.spi_otp_addr01_reg.Q};

assign    spi_vif.REG_BACKDOOR[0][8'h20]         =   { `SPI_TOP.spi_reg_u.pd_ctrl_reg_7_.Q, 
                                                       `SPI_TOP.spi_reg_u.pd_ctrl_reg_6_.Q, 
                                                       `SPI_TOP.spi_reg_u.pd_ctrl_reg_5_.Q, 
                                                       `SPI_TOP.spi_reg_u.pd_ctrl_reg_4_.Q, 
                                                       `SPI_TOP.spi_reg_u.pd_ctrl_reg_3_.Q, 
                                                       `SPI_TOP.spi_reg_u.pd_ctrl_reg_2_.Q, 
                                                       `SPI_TOP.spi_reg_u.pd_ctrl_reg_1_.Q, 
                                                       `SPI_TOP.spi_reg_u.pd_ctrl_reg_0_.Q};			    

assign    spi_vif.REG_BACKDOOR[0][8'h21]         =   `SPI_TOP.spi_reg_u.ds_ctrl_reg.Q ;

assign    spi_vif.REG_BACKDOOR[0][8'h22]         =   { 6'b0, `SPI_TOP.spi_reg_u.comp_out_ctrl_reg_1_.Q, `SPI_TOP.spi_reg_u.comp_out_ctrl_reg_0_.Q};

assign    spi_vif.REG_BACKDOOR[0][8'h30]         =   { `SPI_TOP.spi_reg_u.lead_off_ctrl_reg_7_.Q, 
                                                       `SPI_TOP.spi_reg_u.lead_off_ctrl_reg_6_.Q, 
                                                       `SPI_TOP.spi_reg_u.lead_off_ctrl_reg_5_.Q, 
                                                       `SPI_TOP.spi_reg_u.lead_off_ctrl_reg_4_.Q, 
                                                       `SPI_TOP.spi_reg_u.lead_off_ctrl_reg_3_.Q, 
                                                       `SPI_TOP.spi_reg_u.lead_off_ctrl_reg_2_.Q, 
                                                       `SPI_TOP.spi_reg_u.lead_off_ctrl_reg_1_.Q, 
                                                       `SPI_TOP.spi_reg_u.lead_off_ctrl_reg_0_.Q
                                                      };

//assign    spi_vif.REG_BACKDOOR[0][8'h31]         =   { `SPI_TOP.spi_reg_u.led_off_th_h_reg_7_.Q, 
//                                                       `SPI_TOP.spi_reg_u.led_off_th_h_reg_6_.Q, 
//                                                       `SPI_TOP.spi_reg_u.led_off_th_h_reg_5_.Q, 
//                                                       `SPI_TOP.spi_reg_u.led_off_th_h_reg_4_.Q,
//                                                       `SPI_TOP.spi_reg_u.led_off_th_h_reg_3_.Q, 
//                                                       `SPI_TOP.spi_reg_u.led_off_th_h_reg_2_.Q, 
//                                                       `SPI_TOP.spi_reg_u.led_off_th_h_reg_1_.Q, 
//                                                       `SPI_TOP.spi_reg_u.led_off_th_h_reg_0_.Q
//                                                     }; 
//
//assign    spi_vif.REG_BACKDOOR[0][8'h32]         =   { 4'h0, 
//                                                       `SPI_TOP.spi_reg_u.led_off_th_h_reg_11_.Q, 
//                                                       `SPI_TOP.spi_reg_u.led_off_th_h_reg_10_.Q, 
//                                                       `SPI_TOP.spi_reg_u.led_off_th_h_reg_9_.Q, 
//                                                       `SPI_TOP.spi_reg_u.led_off_th_h_reg_8_.Q
//                                                     }; 
//
//assign    spi_vif.REG_BACKDOOR[0][8'h33]         =   { `SPI_TOP.spi_reg_u.led_off_th_l_reg_7_.Q, 
//                                                       `SPI_TOP.spi_reg_u.led_off_th_l_reg_6_.Q, 
//                                                       `SPI_TOP.spi_reg_u.led_off_th_l_reg_5_.Q, 
//                                                       `SPI_TOP.spi_reg_u.led_off_th_l_reg_4_.Q, 
//                                                       `SPI_TOP.spi_reg_u.led_off_th_l_reg_3_.Q, 
//                                                       `SPI_TOP.spi_reg_u.led_off_th_l_reg_2_.Q, 
//                                                       `SPI_TOP.spi_reg_u.led_off_th_l_reg_1_.Q, 
//                                                       `SPI_TOP.spi_reg_u.led_off_th_l_reg_0_.Q
//                                                      };
// 
//assign    spi_vif.REG_BACKDOOR[0][8'h34]         =   { 4'h0, 
//                                                       `SPI_TOP.spi_reg_u.led_off_th_l_reg_11_.Q, 
//                                                       `SPI_TOP.spi_reg_u.led_off_th_l_reg_10_.Q, 
//                                                       `SPI_TOP.spi_reg_u.led_off_th_l_reg_9_.Q, 
//                                                       `SPI_TOP.spi_reg_u.led_off_th_l_reg_8_.Q
//                                                      };

assign    spi_vif.REG_BACKDOOR[0][8'h35]         =    { `SPI_TOP.spi_reg_u.measure_dly_tgt_0_reg_7_.Q, 
                                                        `SPI_TOP.spi_reg_u.measure_dly_tgt_0_reg_6_.Q, 
                                                        `SPI_TOP.spi_reg_u.measure_dly_tgt_0_reg_5_.Q, 
                                                        `SPI_TOP.spi_reg_u.measure_dly_tgt_0_reg_4_.Q, 
                                                        `SPI_TOP.spi_reg_u.measure_dly_tgt_0_reg_3_.Q, 
                                                        `SPI_TOP.spi_reg_u.measure_dly_tgt_0_reg_2_.Q, 
                                                        `SPI_TOP.spi_reg_u.measure_dly_tgt_0_reg_1_.Q, 
                                                        `SPI_TOP.spi_reg_u.measure_dly_tgt_0_reg_0_.Q
                                                      };

assign    spi_vif.REG_BACKDOOR[0][8'h36]         =   { `SPI_TOP.spi_reg_u.measure_dly_tgt_1_reg_7_.Q, 
                                                       `SPI_TOP.spi_reg_u.measure_dly_tgt_1_reg_6_.Q, 
                                                       `SPI_TOP.spi_reg_u.measure_dly_tgt_1_reg_5_.Q, 
                                                       `SPI_TOP.spi_reg_u.measure_dly_tgt_1_reg_4_.Q, 
                                                       `SPI_TOP.spi_reg_u.measure_dly_tgt_1_reg_3_.Q, 
                                                       `SPI_TOP.spi_reg_u.measure_dly_tgt_1_reg_2_.Q, 
                                                       `SPI_TOP.spi_reg_u.measure_dly_tgt_1_reg_1_.Q, 
                                                       `SPI_TOP.spi_reg_u.measure_dly_tgt_1_reg_0_.Q
                                                      };
 
assign    spi_vif.REG_BACKDOOR[0][8'h37]         =   { `SPI_TOP.spi_reg_u.measure_dly_tgt_2_reg_7_.Q, 
                                                       `SPI_TOP.spi_reg_u.measure_dly_tgt_2_reg_6_.Q, 
                                                       `SPI_TOP.spi_reg_u.measure_dly_tgt_2_reg_5_.Q, 
                                                       `SPI_TOP.spi_reg_u.measure_dly_tgt_2_reg_4_.Q, 
                                                       `SPI_TOP.spi_reg_u.measure_dly_tgt_2_reg_3_.Q, 
                                                       `SPI_TOP.spi_reg_u.measure_dly_tgt_2_reg_2_.Q, 
                                                       `SPI_TOP.spi_reg_u.measure_dly_tgt_2_reg_1_.Q, 
                                                       `SPI_TOP.spi_reg_u.measure_dly_tgt_2_reg_0_.Q
                                                      };
 
assign    spi_vif.REG_BACKDOOR[0][8'h38]         =   { `SPI_TOP.spi_reg_u.measure_dly_tgt_3_reg_7_.Q, 
                                                       `SPI_TOP.spi_reg_u.measure_dly_tgt_3_reg_6_.Q, 
                                                       `SPI_TOP.spi_reg_u.measure_dly_tgt_3_reg_5_.Q, 
                                                       `SPI_TOP.spi_reg_u.measure_dly_tgt_3_reg_4_.Q, 
                                                       `SPI_TOP.spi_reg_u.measure_dly_tgt_3_reg_3_.Q, 
                                                       `SPI_TOP.spi_reg_u.measure_dly_tgt_3_reg_2_.Q, 
                                                       `SPI_TOP.spi_reg_u.measure_dly_tgt_3_reg_1_.Q, 
                                                       `SPI_TOP.spi_reg_u.measure_dly_tgt_3_reg_0_.Q
                                                      };
 
assign    spi_vif.REG_BACKDOOR[0][8'h39]         =   { `SPI_TOP.spi_reg_u.lead_off_tgt_reg_reg_7_.Q, 
                                                       `SPI_TOP.spi_reg_u.lead_off_tgt_reg_reg_6_.Q, 
                                                       `SPI_TOP.spi_reg_u.lead_off_tgt_reg_reg_5_.Q,  
                                                       `SPI_TOP.spi_reg_u.lead_off_tgt_reg_reg_4_.Q, 
                                                       `SPI_TOP.spi_reg_u.lead_off_tgt_reg_reg_3_.Q, 
                                                       `SPI_TOP.spi_reg_u.lead_off_tgt_reg_reg_2_.Q, 
                                                       `SPI_TOP.spi_reg_u.lead_off_tgt_reg_reg_1_.Q, 
                                                       `SPI_TOP.spi_reg_u.lead_off_tgt_reg_reg_0_.Q
                                                      };
 
assign    spi_vif.REG_BACKDOOR[0][8'h3A]         =   { `SPI_TOP.spi_reg_u.lead_off_result, 
                                                       `SPI_TOP.spi_reg_u.lead_off_int_reg_5_.Q, 
                                                       `SPI_TOP.spi_reg_u.lead_off_int_reg_4_.Q, 
                                                       `SPI_TOP.spi_reg_u.lead_off_int_reg_3_.Q, 
                                                       `SPI_TOP.spi_reg_u.lead_off_int_reg_2_.Q, 
                                                       `SPI_TOP.spi_reg_u.lead_off_int_reg_1_.Q, 
                                                       `SPI_TOP.spi_reg_u.lead_off_int_reg_0_.Q 
                                                      };

assign    spi_vif.REG_BACKDOOR[0][8'h3C]         =   { `SPI_TOP.spi_reg_u.lead_off_level_tgt_reg_reg_7_.Q,
                                                       `SPI_TOP.spi_reg_u.lead_off_level_tgt_reg_reg_6_.Q,
                                                       `SPI_TOP.spi_reg_u.lead_off_level_tgt_reg_reg_5_.Q,
                                                       `SPI_TOP.spi_reg_u.lead_off_level_tgt_reg_reg_4_.Q,
                                                       `SPI_TOP.spi_reg_u.lead_off_level_tgt_reg_reg_3_.Q,
                                                       `SPI_TOP.spi_reg_u.lead_off_level_tgt_reg_reg_2_.Q,
                                                       `SPI_TOP.spi_reg_u.lead_off_level_tgt_reg_reg_1_.Q,
                                                       `SPI_TOP.spi_reg_u.lead_off_level_tgt_reg_reg_0_.Q
                                                      };

assign    spi_vif.REG_BACKDOOR[0][8'h3D]         =   { `SPI_TOP.spi_reg_u.lead_off_level_tgt_reg_reg_15_.Q,
                                                       `SPI_TOP.spi_reg_u.lead_off_level_tgt_reg_reg_14_.Q,
                                                       `SPI_TOP.spi_reg_u.lead_off_level_tgt_reg_reg_13_.Q,
                                                       `SPI_TOP.spi_reg_u.lead_off_level_tgt_reg_reg_12_.Q,
                                                       `SPI_TOP.spi_reg_u.lead_off_level_tgt_reg_reg_11_.Q,
                                                       `SPI_TOP.spi_reg_u.lead_off_level_tgt_reg_reg_10_.Q,
                                                       `SPI_TOP.spi_reg_u.lead_off_level_tgt_reg_reg_9_.Q,
                                                       `SPI_TOP.spi_reg_u.lead_off_level_tgt_reg_reg_8_.Q
                                                      };

assign    spi_vif.REG_BACKDOOR[0][8'h3E]         =   { `SPI_TOP.spi_reg_u.lead_off_level_tgt_reg_reg_23_.Q,
                                                       `SPI_TOP.spi_reg_u.lead_off_level_tgt_reg_reg_22_.Q,
                                                       `SPI_TOP.spi_reg_u.lead_off_level_tgt_reg_reg_21_.Q,
                                                       `SPI_TOP.spi_reg_u.lead_off_level_tgt_reg_reg_20_.Q,
                                                       `SPI_TOP.spi_reg_u.lead_off_level_tgt_reg_reg_19_.Q,
                                                       `SPI_TOP.spi_reg_u.lead_off_level_tgt_reg_reg_18_.Q,
                                                       `SPI_TOP.spi_reg_u.lead_off_level_tgt_reg_reg_17_.Q,
                                                       `SPI_TOP.spi_reg_u.lead_off_level_tgt_reg_reg_16_.Q
                                                      };

assign    spi_vif.REG_BACKDOOR[0][8'h3F]         =   { `SPI_TOP.spi_reg_u.lead_off_level_tgt_reg_reg_31_.Q,
                                                       `SPI_TOP.spi_reg_u.lead_off_level_tgt_reg_reg_30_.Q,
                                                       `SPI_TOP.spi_reg_u.lead_off_level_tgt_reg_reg_29_.Q,
                                                       `SPI_TOP.spi_reg_u.lead_off_level_tgt_reg_reg_28_.Q,
                                                       `SPI_TOP.spi_reg_u.lead_off_level_tgt_reg_reg_27_.Q,
                                                       `SPI_TOP.spi_reg_u.lead_off_level_tgt_reg_reg_26_.Q,
                                                       `SPI_TOP.spi_reg_u.lead_off_level_tgt_reg_reg_25_.Q,
                                                       `SPI_TOP.spi_reg_u.lead_off_level_tgt_reg_reg_24_.Q
                                                      };

assign    spi_vif.REG_BACKDOOR[0][8'h3B]         =   {6'b0, `SPI_TOP.spi_reg_u.A2D_COMP2, `SPI_TOP.spi_reg_u.A2D_COMP1}; 





assign    spi_vif.REG_BACKDOOR[0][8'h40]         =   { `SPI_TOP.spi_reg_u.ana_enable_reg_0_reg_7_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_enable_reg_0_reg_6_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_enable_reg_0_reg_5_.Q,
                                                       `SPI_TOP.spi_reg_u.ana_enable_reg_0_reg_4_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_enable_reg_0_reg_3_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_enable_reg_0_reg_2_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_enable_reg_0_reg_1_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_enable_reg_0_reg_0_.Q
                                                      }; 

assign    spi_vif.REG_BACKDOOR[0][8'h41]         =   { `SPI_TOP.spi_reg_u.ana_enable_reg_1_reg_7_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_enable_reg_1_reg_6_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_enable_reg_1_reg_5_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_enable_reg_1_reg_4_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_enable_reg_1_reg_3_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_enable_reg_1_reg_2_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_enable_reg_1_reg_1_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_enable_reg_1_reg_0_.Q
                                                      };
 
assign    spi_vif.REG_BACKDOOR[0][8'h42]         =   { `SPI_TOP.spi_reg_u.ana_enable_reg_2_reg_7_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_enable_reg_2_reg_6_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_enable_reg_2_reg_5_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_enable_reg_2_reg_4_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_enable_reg_2_reg_3_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_enable_reg_2_reg_2_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_enable_reg_2_reg_1_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_enable_reg_2_reg_0_.Q
                                                     }; 

assign    spi_vif.REG_BACKDOOR[0][8'h43]         =   { `SPI_TOP.spi_reg_u.ana_enable_reg_3_reg_7_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_enable_reg_3_reg_6_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_enable_reg_3_reg_5_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_enable_reg_3_reg_4_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_enable_reg_3_reg_3_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_enable_reg_3_reg_2_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_enable_reg_3_reg_1_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_enable_reg_3_reg_0_.Q
                                                     };

assign    spi_vif.REG_BACKDOOR[0][8'h44]         =   { `SPI_TOP.spi_reg_u.ana_gen_reg_1_reg_7_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_1_reg_6_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_1_reg_5_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_1_reg_4_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_1_reg_3_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_1_reg_2_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_1_reg_1_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_1_reg_0_.Q
                                                     };
 
assign    spi_vif.REG_BACKDOOR[0][8'h45]         =   { `SPI_TOP.spi_reg_u.ana_gen_reg_2_reg_7_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_2_reg_6_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_2_reg_5_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_2_reg_4_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_2_reg_3_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_2_reg_2_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_2_reg_1_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_2_reg_0_.Q
                                                     };
  
assign    spi_vif.REG_BACKDOOR[0][8'h46]         =   { `SPI_TOP.spi_reg_u.ana_gen_reg_3_reg_7_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_3_reg_6_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_3_reg_5_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_3_reg_4_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_3_reg_3_.Q,
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_3_reg_2_.Q,
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_3_reg_1_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_3_reg_0_.Q
                                                      };
 
assign    spi_vif.REG_BACKDOOR[0][8'h47]         =   { `SPI_TOP.spi_reg_u.ana_gen_reg_4_reg_7_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_4_reg_6_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_4_reg_5_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_4_reg_4_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_4_reg_3_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_4_reg_2_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_4_reg_1_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_4_reg_0_.Q
                                                     };
 
assign    spi_vif.REG_BACKDOOR[0][8'h48]         =   { `SPI_TOP.spi_reg_u.ana_gen_reg_5_reg_7_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_5_reg_6_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_5_reg_5_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_5_reg_4_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_5_reg_3_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_5_reg_2_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_5_reg_1_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_5_reg_0_.Q
                                                     };
 
assign    spi_vif.REG_BACKDOOR[0][8'h49]         =   { `SPI_TOP.spi_reg_u.ana_gen_reg_6_reg_7_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_6_reg_6_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_6_reg_5_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_6_reg_4_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_6_reg_3_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_6_reg_2_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_6_reg_1_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_6_reg_0_.Q
                                                      }; 

assign    spi_vif.REG_BACKDOOR[0][8'h4A]         =   { `SPI_TOP.spi_reg_u.ana_gen_reg_7_reg_7_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_7_reg_6_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_7_reg_5_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_7_reg_4_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_7_reg_3_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_7_reg_2_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_7_reg_1_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_7_reg_0_.Q
                                                     };

assign    spi_vif.REG_BACKDOOR[0][8'h4B]         =   { `SPI_TOP.spi_reg_u.ana_gen_reg_8_reg_7_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_8_reg_6_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_8_reg_5_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_8_reg_4_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_8_reg_3_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_8_reg_2_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_8_reg_1_.Q,
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_8_reg_0_.Q
                                                      }; 

assign    spi_vif.REG_BACKDOOR[0][8'h4C]         =   { `SPI_TOP.spi_reg_u.ana_gen_reg_9_reg_7_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_9_reg_6_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_9_reg_5_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_9_reg_4_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_9_reg_3_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_9_reg_2_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_9_reg_1_.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_gen_reg_9_reg_0_.Q
                                                      };

assign    spi_vif.REG_BACKDOOR[0][8'h50]         =   {5'h0, `ANA_TOP.A2D_COMP_OUT_STIMU2_3, `ANA_TOP.A2D_COMP_OUT_STIMU0_1, `ANA_TOP.A2D_LVD} ;

assign    spi_vif.REG_BACKDOOR[0][8'h51]         =   `ANA_TOP.A2D_SPARE_RO_REG_0 ;

assign    spi_vif.REG_BACKDOOR[0][8'h52]         =   { 3'h0,
                                                       `SPI_TOP.ana_comp_ch2_intr_trans_sel,
                                                       `SPI_TOP.ana_comp_ch1_intr_trans_sel,
                                                       `SPI_TOP.spi_reg_u.ana_comp_ch2_intr_en_reg_reg.Q, 
                                                       `SPI_TOP.spi_reg_u.ana_comp_ch1_intr_en_reg_reg.Q,
                                                       `SPI_TOP.spi_reg_u.ana_lvd_intr_en_reg_reg.Q
                                                     };

assign    spi_vif.REG_BACKDOOR[0][8'h53]         =   {5'b0, `SPI_TOP.spi_reg_u.ana_comp_ch2_intr_sts, `SPI_TOP.spi_reg_u.ana_comp_ch1_intr_sts, `ANA_TOP.A2D_LVD && spi_vif.REG_BACKDOOR[0][8'h52][0]};

assign    spi_vif.REG_BACKDOOR[0][8'h54]         =   {5'b0, `SPI_TOP.spi_reg_u.ana_int_comp_pol_reg}; 

assign    spi_vif.REG_BACKDOOR[0][8'h55]         =   {6'b0, `SPI_TOP.spi_reg_u.ana_int_stop_wavegen_reg_reg_1_.Q, `SPI_TOP.spi_reg_u.ana_int_stop_wavegen_reg_reg_0_.Q};

assign    spi_vif.REG_BACKDOOR[0][8'h56]         =   `SPI_TOP.spi_reg_u.ana_int_sim0_a00_reg;

assign    spi_vif.REG_BACKDOOR[0][8'h57]         =   `SPI_TOP.spi_reg_u.ana_int_sim0_a01_reg; 

assign    spi_vif.REG_BACKDOOR[0][8'h58]         =   `SPI_TOP.spi_reg_u.ana_int_sim1_a10_reg; 

//assign    spi_vif.REG_BACKDOOR[0][8'h59]         =   `SPI_TOP.spi_reg_u.ana_int_sim1_a11_reg; 

//assign    spi_vif.REG_BACKDOOR[0][8'h5a]         =   `SPI_TOP.spi_reg_u.ana_stimu_int1_num;

assign    spi_vif.REG_BACKDOOR[0][8'h5b]         =   `SPI_TOP.spi_reg_u.ana_int_sim2_a20_reg; 

assign    spi_vif.REG_BACKDOOR[0][8'h5c]         =   `SPI_TOP.spi_reg_u.ana_int_sim2_a21_reg; 

assign    spi_vif.REG_BACKDOOR[0][8'h5d]         =   `SPI_TOP.spi_reg_u.ana_int_sim3_a30_reg; 

//assign    spi_vif.REG_BACKDOOR[0][8'h5e]         =   `SPI_TOP.spi_reg_u.ana_int_sim3_a31_reg; 

//assign    spi_vif.REG_BACKDOOR[0][8'h5f]         =   `SPI_TOP.spi_reg_u.ana_stimu_int2_num;

assign    spi_vif.REG_BACKDOOR[0][8'h60]         =   {6'b0,`SPI_TOP.spi_reg_u.ana_stimu_ch2_intr_sts, `SPI_TOP.spi_reg_u.ana_stimu_ch1_intr_sts};

assign    spi_vif.REG_BACKDOOR[0][8'h61]         =   { `SPI_TOP.spi_reg_u.comp_stim_duration_tar_cnt_reg_7_.Q,
                                                       `SPI_TOP.spi_reg_u.comp_stim_duration_tar_cnt_reg_6_.Q,
                                                       `SPI_TOP.spi_reg_u.comp_stim_duration_tar_cnt_reg_5_.Q,
                                                       `SPI_TOP.spi_reg_u.comp_stim_duration_tar_cnt_reg_4_.Q,
                                                       `SPI_TOP.spi_reg_u.comp_stim_duration_tar_cnt_reg_3_.Q,
                                                       `SPI_TOP.spi_reg_u.comp_stim_duration_tar_cnt_reg_2_.Q,
                                                       `SPI_TOP.spi_reg_u.comp_stim_duration_tar_cnt_reg_1_.Q,
                                                       `SPI_TOP.spi_reg_u.comp_stim_duration_tar_cnt_reg_0_.Q
                                                      };

assign    spi_vif.REG_BACKDOOR[0][8'h62]         =   { `SPI_TOP.spi_reg_u.comp_stim_duration_tar_cnt_reg_15_.Q,
                                                       `SPI_TOP.spi_reg_u.comp_stim_duration_tar_cnt_reg_14_.Q,
                                                       `SPI_TOP.spi_reg_u.comp_stim_duration_tar_cnt_reg_13_.Q,
                                                       `SPI_TOP.spi_reg_u.comp_stim_duration_tar_cnt_reg_12_.Q,
                                                       `SPI_TOP.spi_reg_u.comp_stim_duration_tar_cnt_reg_11_.Q,
                                                       `SPI_TOP.spi_reg_u.comp_stim_duration_tar_cnt_reg_10_.Q,
                                                       `SPI_TOP.spi_reg_u.comp_stim_duration_tar_cnt_reg_9_.Q,
                                                       `SPI_TOP.spi_reg_u.comp_stim_duration_tar_cnt_reg_8_.Q
                                                      };

assign    spi_vif.REG_BACKDOOR[0][8'h63]         =   { `SPI_TOP.spi_reg_u.comp_stim_duration_tar_cnt_reg_23_.Q,
                                                       `SPI_TOP.spi_reg_u.comp_stim_duration_tar_cnt_reg_22_.Q,
                                                       `SPI_TOP.spi_reg_u.comp_stim_duration_tar_cnt_reg_21_.Q,
                                                       `SPI_TOP.spi_reg_u.comp_stim_duration_tar_cnt_reg_20_.Q,
                                                       `SPI_TOP.spi_reg_u.comp_stim_duration_tar_cnt_reg_19_.Q,
                                                       `SPI_TOP.spi_reg_u.comp_stim_duration_tar_cnt_reg_18_.Q,
                                                       `SPI_TOP.spi_reg_u.comp_stim_duration_tar_cnt_reg_17_.Q,
                                                       `SPI_TOP.spi_reg_u.comp_stim_duration_tar_cnt_reg_16_.Q
                                                      };

assign    spi_vif.REG_BACKDOOR[0][8'h64]         =   {`SPI_TOP.spi_reg_u.measure_dly_tgt1_0_reg_7_.Q,
                                                      `SPI_TOP.spi_reg_u.measure_dly_tgt1_0_reg_6_.Q,
                                                      `SPI_TOP.spi_reg_u.measure_dly_tgt1_0_reg_5_.Q,
                                                      `SPI_TOP.spi_reg_u.measure_dly_tgt1_0_reg_4_.Q,
                                                      `SPI_TOP.spi_reg_u.measure_dly_tgt1_0_reg_3_.Q,
                                                      `SPI_TOP.spi_reg_u.measure_dly_tgt1_0_reg_2_.Q,
                                                      `SPI_TOP.spi_reg_u.measure_dly_tgt1_0_reg_1_.Q,
                                                      `SPI_TOP.spi_reg_u.measure_dly_tgt1_0_reg_0_.Q
                                                      };

assign    spi_vif.REG_BACKDOOR[0][8'h65]         =   {`SPI_TOP.spi_reg_u.measure_dly_tgt1_1_reg_7_.Q,
                                                      `SPI_TOP.spi_reg_u.measure_dly_tgt1_1_reg_6_.Q,
                                                      `SPI_TOP.spi_reg_u.measure_dly_tgt1_1_reg_5_.Q,
                                                      `SPI_TOP.spi_reg_u.measure_dly_tgt1_1_reg_4_.Q,
                                                      `SPI_TOP.spi_reg_u.measure_dly_tgt1_1_reg_3_.Q,
                                                      `SPI_TOP.spi_reg_u.measure_dly_tgt1_1_reg_2_.Q,
                                                      `SPI_TOP.spi_reg_u.measure_dly_tgt1_1_reg_1_.Q,
                                                      `SPI_TOP.spi_reg_u.measure_dly_tgt1_1_reg_0_.Q
                                                      };

assign    spi_vif.REG_BACKDOOR[0][8'h66]         =   {`SPI_TOP.spi_reg_u.measure_dly_tgt1_2_reg_7_.Q,
                                                      `SPI_TOP.spi_reg_u.measure_dly_tgt1_2_reg_6_.Q,
                                                      `SPI_TOP.spi_reg_u.measure_dly_tgt1_2_reg_5_.Q,
                                                      `SPI_TOP.spi_reg_u.measure_dly_tgt1_2_reg_4_.Q,
                                                      `SPI_TOP.spi_reg_u.measure_dly_tgt1_2_reg_3_.Q,
                                                      `SPI_TOP.spi_reg_u.measure_dly_tgt1_2_reg_2_.Q,
                                                      `SPI_TOP.spi_reg_u.measure_dly_tgt1_2_reg_1_.Q,
                                                      `SPI_TOP.spi_reg_u.measure_dly_tgt1_2_reg_0_.Q
                                                      };

assign    spi_vif.REG_BACKDOOR[0][8'h67]         =   {`SPI_TOP.spi_reg_u.measure_dly_tgt1_3_reg_7_.Q,
                                                      `SPI_TOP.spi_reg_u.measure_dly_tgt1_3_reg_6_.Q,
                                                      `SPI_TOP.spi_reg_u.measure_dly_tgt1_3_reg_5_.Q,
                                                      `SPI_TOP.spi_reg_u.measure_dly_tgt1_3_reg_4_.Q,
                                                      `SPI_TOP.spi_reg_u.measure_dly_tgt1_3_reg_3_.Q,
                                                      `SPI_TOP.spi_reg_u.measure_dly_tgt1_3_reg_2_.Q,
                                                      `SPI_TOP.spi_reg_u.measure_dly_tgt1_3_reg_1_.Q,
                                                      `SPI_TOP.spi_reg_u.measure_dly_tgt1_3_reg_0_.Q
                                                      };

assign    spi_vif.REG_BACKDOOR[0][8'h70]         =   {6'b0, `SPI_TOP.spi_reg_u.atm_hc_sel_reg_reg_1_.Q, `SPI_TOP.spi_reg_u.atm_hc_sel_reg_reg_0_.Q};
`endif
*/
/*
genvar i;                               
generate                                
   for(i=0;i<2;i=i+1) begin             

`ifdef BEHAVIORAL
assign   spi_vif.REG_BACKDOOR[1][8'h00+8'h40*i]        =   `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_config[7:0]             ;
assign   spi_vif.REG_BACKDOOR[1][8'h01+8'h40*i]        =   `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_ctrl[7:0]               ;
assign   spi_vif.REG_BACKDOOR[1][8'h02+8'h40*i]        =     `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_point_config[7:0];
assign   spi_vif.REG_BACKDOOR[1][8'h03+8'h40*i]        =   `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_in_wave_addr[7:0] ;
assign   spi_vif.REG_BACKDOOR[1][8'h04+8'h40*i]        =   `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_in_wave[`SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_in_wave_addr];
assign   spi_vif.REG_BACKDOOR[1][8'h05+8'h40*i]        =   `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_rest_t[7:0]             ;
assign   spi_vif.REG_BACKDOOR[1][8'h06+8'h40*i]        =   `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_rest_t[15:8]            ;
assign   spi_vif.REG_BACKDOOR[1][8'h07+8'h40*i]        =   `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_silent_t[7:0]           ;
assign   spi_vif.REG_BACKDOOR[1][8'h08+8'h40*i]        =   `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_silent_t[15:8]          ;
assign   spi_vif.REG_BACKDOOR[1][8'h09+8'h40*i]        =   `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_silent_t[23:16]         ;
assign   spi_vif.REG_BACKDOOR[1][8'h0a+8'h40*i]        =   `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_silent_t[31:24];
assign   spi_vif.REG_BACKDOOR[1][8'h0b+8'h40*i]        =   `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_hlf_wave_prd[7:0]       ;
assign   spi_vif.REG_BACKDOOR[1][8'h0c+8'h40*i]        =   `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_hlf_wave_prd[15:8]      ;
assign   spi_vif.REG_BACKDOOR[1][8'h0d+8'h40*i]        =   `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_neg_hlf_wave_prd[7:0]   ;
assign   spi_vif.REG_BACKDOOR[1][8'h0e+8'h40*i]        =   `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_neg_hlf_wave_prd[15:8]  ;
assign   spi_vif.REG_BACKDOOR[1][8'h0f+8'h40*i]        =     `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_rest_t1[7:0];
assign   spi_vif.REG_BACKDOOR[1][8'h10+8'h40*i]        =     `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_rest_t1[15:8];
assign   spi_vif.REG_BACKDOOR[1][8'h11+8'h40*i]        =     `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_silent_t1[7:0];
assign   spi_vif.REG_BACKDOOR[1][8'h12+8'h40*i]        =     `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_silent_t1[15:8];
assign   spi_vif.REG_BACKDOOR[1][8'h13+8'h40*i]        =     `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_silent_t1[23:16];
assign   spi_vif.REG_BACKDOOR[1][8'h14+8'h40*i]        =     `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_silent_t1[31:24];
assign   spi_vif.REG_BACKDOOR[1][8'h15+8'h40*i]        =     `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_hlf_wave_prd1[7:0];   
assign   spi_vif.REG_BACKDOOR[1][8'h16+8'h40*i]        =     `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_hlf_wave_prd1[15:8];
assign   spi_vif.REG_BACKDOOR[1][8'h17+8'h40*i]        =     `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_neg_hlf_wave_prd1[7:0];
assign   spi_vif.REG_BACKDOOR[1][8'h18+8'h40*i]        =     `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_neg_hlf_wave_prd1[15:8];
assign   spi_vif.REG_BACKDOOR[1][8'h19+8'h40*i]        =     `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_rest_t2[7:0];
assign   spi_vif.REG_BACKDOOR[1][8'h1a+8'h40*i]        =     `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_rest_t2[15:8];
assign   spi_vif.REG_BACKDOOR[1][8'h1b+8'h40*i]        =     `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_silent_t2[7:0];
assign   spi_vif.REG_BACKDOOR[1][8'h1c+8'h40*i]        =     `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_silent_t2[15:8];
assign   spi_vif.REG_BACKDOOR[1][8'h1d+8'h40*i]        =     `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_silent_t2[23:16];
assign   spi_vif.REG_BACKDOOR[1][8'h1e+8'h40*i]        =     `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_silent_t2[31:24];
assign   spi_vif.REG_BACKDOOR[1][8'h1f+8'h40*i]        =     `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_hlf_wave_prd2[7:0];
assign   spi_vif.REG_BACKDOOR[1][8'h20+8'h40*i]        =     `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_hlf_wave_prd2[15:8];
assign   spi_vif.REG_BACKDOOR[1][8'h21+8'h40*i]        =     `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_neg_hlf_wave_prd2[7:0];
assign   spi_vif.REG_BACKDOOR[1][8'h22+8'h40*i]        =     `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_neg_hlf_wave_prd2[15:8];
assign   spi_vif.REG_BACKDOOR[1][8'h23+8'h40*i]        =   `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_delay_lim[7:0]         ;
assign   spi_vif.REG_BACKDOOR[1][8'h24+8'h40*i]        =   `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_delay_lim[15:8]        ;
assign   spi_vif.REG_BACKDOOR[1][8'h25+8'h40*i]        =   `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_neg_scale[7:0]         ;
assign   spi_vif.REG_BACKDOOR[1][8'h26+8'h40*i]        =   `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_neg_offset[7:0]        ;
assign   spi_vif.REG_BACKDOOR[1][8'h27+8'h40*i]        =   {`SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.wg_driver_pos_scale, `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_isel[7:0]} ;
assign   spi_vif.REG_BACKDOOR[1][8'h28+8'h40*i]        =   `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_pos_offset[7:0]       ;
assign   spi_vif.REG_BACKDOOR[1][8'h29+8'h40*i]        =     `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_pullba         ;
assign   spi_vif.REG_BACKDOOR[1][8'h2A+8'h40*i]        =   `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.o_wg_driver_int_cnt[7:0];
assign   spi_vif.REG_BACKDOOR[1][8'h2b+8'h40*i]        =   {2'b00,`SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.i_wg_driver_int_sts[1:0], `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.o_wg_driver_int_en, `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.NO_OF_WAVEGEN[2:0]};
assign   spi_vif.REG_BACKDOOR[1][8'h2c+8'h40*i]        =   `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_int[15:8]              ;
assign   spi_vif.REG_BACKDOOR[1][8'h2d+8'h40*i]        =   `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_int[23:16]             ;
assign   spi_vif.REG_BACKDOOR[1][8'h2e+8'h40*i]        =   `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_alt_lim[7:0]           ;
assign   spi_vif.REG_BACKDOOR[1][8'h2f+8'h40*i]        =   `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_alt_lim[15:8]          ;
assign   spi_vif.REG_BACKDOOR[1][8'h30+8'h40*i]        =   `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_alt_silent_lim[7:0]    ;
assign   spi_vif.REG_BACKDOOR[1][8'h31+8'h40*i]        =   `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.reg_wg_driver_alt_silent_lim[15:8]   ;
assign   spi_vif.REG_BACKDOOR[1][8'h32+8'h40*i]        =     `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.drive_ctrl_reg0       ;
assign   spi_vif.REG_BACKDOOR[1][8'h33+8'h40*i]        =     `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.drive_ctrl_reg1       ;
assign   spi_vif.REG_BACKDOOR[1][8'h34+8'h40*i]        =     `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.drive_ctrl_reg2       ;
assign   spi_vif.REG_BACKDOOR[1][8'h35+8'h40*i]        =     {7'b0,`SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.o_no_of_num_slient_disable};
assign   spi_vif.REG_BACKDOOR[1][8'h36+8'h40*i]        =     `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.o_no_of_num_slient_tar[7:0];
assign   spi_vif.REG_BACKDOOR[1][8'h37+8'h40*i]        =     `SPI_TOP.spi_reg_u.genblk1[i].u_spi_reg_wavegen.o_no_of_num_slient_tar[15:8];
`endif
end                                                                                                                                               
endgenerate  
*/  
/*
`ifndef BEHAVIORAL
   //if(i==0) begin
     `define u_spi_reg_wavegen0_path  `SPI_TOP.spi_reg_u.genblk1_0__u_spi_reg_wavegen
     `define u_wavegen0_path          `WG_DRIVER_TOP.wg_driver_top_inst.genblk1_0__arb_wave_gen_inst
   //end
   //else if(i==1) begin
     `define u_spi_reg_wavegen1_path  `SPI_TOP.spi_reg_u.genblk1_1__u_spi_reg_wavegen
     `define u_wavegen1_path          `WG_DRIVER_TOP.wg_driver_top_inst.genblk1_1__arb_wave_gen_inst
   //end

     string signal_path0 = "soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_spi_top.spi_reg_u.genblk1_0__u_spi_reg_wavegen";//.reg_wg_driver_in_wave";
     string signal_path1 = "soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_spi_top.spi_reg_u.genblk1_1__u_spi_reg_wavegen";//.reg_wg_driver_in_wave";

    function int get_drv_in_wave_reg(string signal_path, bit[6:0] addr); 
        bit [7:0] signal_value;
        for(int i=0; i<8; i++) begin
            uvm_hdl_read($sformatf("%0s.reg_wg_driver_in_wave_reg_%0d__%0d_.Q", signal_path, addr, i), signal_value[i]);
            //$display("%s, %0b  , %b",$sformatf("%0s_%0d_", signal_path, addr*8+i) , signal_value[i], signal_value);
        end
        return signal_value;
    endfunction


    assign   spi_vif.REG_BACKDOOR[1][8'h00] ={`u_spi_reg_wavegen0_path.reg_wg_driver_config_reg_7_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_config_reg_6_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_config_reg_5_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_config_reg_4_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_config_reg_3_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_config_reg_2_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_config_reg_1_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_config_reg_0_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h01] ={`u_spi_reg_wavegen0_path.reg_wg_driver_ctrl_reg_7_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_ctrl_reg_6_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_ctrl_reg_5_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_ctrl_reg_4_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_ctrl_reg_3_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_ctrl_reg_2_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_ctrl_reg_1_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_ctrl_reg_0_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h06] ={`u_spi_reg_wavegen0_path.reg_wg_driver_rest_t_reg_15_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t_reg_14_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t_reg_13_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t_reg_12_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t_reg_11_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t_reg_10_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t_reg_9_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t_reg_8_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h05] ={`u_spi_reg_wavegen0_path.reg_wg_driver_rest_t_reg_7_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t_reg_6_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t_reg_5_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t_reg_4_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t_reg_3_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t_reg_2_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t_reg_1_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t_reg_0_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h07] ={`u_spi_reg_wavegen0_path.reg_wg_driver_silent_t_reg_7_.Q,  `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t_reg_6_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t_reg_5_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t_reg_4_.Q,  `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t_reg_3_.Q,  `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t_reg_2_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t_reg_1_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t_reg_0_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h08] ={`u_spi_reg_wavegen0_path.reg_wg_driver_silent_t_reg_15_.Q,  `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t_reg_14_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t_reg_13_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t_reg_12_.Q,  `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t_reg_11_.Q,  `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t_reg_10_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t_reg_9_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t_reg_8_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h09] ={`u_spi_reg_wavegen0_path.reg_wg_driver_silent_t_reg_23_.Q,  `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t_reg_22_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t_reg_21_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t_reg_20_.Q,  `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t_reg_19_.Q,  `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t_reg_18_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t_reg_17_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t_reg_16_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h0a] ={`u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd_reg_7_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd_reg_6_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd_reg_5_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd_reg_4_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd_reg_3_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd_reg_2_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd_reg_1_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd_reg_0_.Q}  ;
    assign   spi_vif.REG_BACKDOOR[1][8'h0b] ={`u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd_reg_15_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd_reg_14_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd_reg_13_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd_reg_12_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd_reg_11_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd_reg_10_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd_reg_9_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd_reg_8_.Q}  ;
    assign   spi_vif.REG_BACKDOOR[1][8'h0c] ={`u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd_reg_7_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd_reg_6_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd_reg_5_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd_reg_4_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd_reg_3_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd_reg_2_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd_reg_1_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd_reg_0_.Q}  ;
    assign   spi_vif.REG_BACKDOOR[1][8'h0d] ={`u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd_reg_15_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd_reg_14_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd_reg_13_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd_reg_12_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd_reg_11_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd_reg_10_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd_reg_9_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd_reg_8_.Q}  ;
    assign   spi_vif.REG_BACKDOOR[1][8'h03] ={`u_spi_reg_wavegen0_path.reg_wg_driver_in_wave_addr_reg_7_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_in_wave_addr_reg_6_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_in_wave_addr_reg_5_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_in_wave_addr_reg_4_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_in_wave_addr_reg_3_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_in_wave_addr_reg_2_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_in_wave_addr_reg_1_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_in_wave_addr_reg_0_.Q} ;

`ifdef PRESCAN
    //always @(spi_vif.REG_WDATA[1][8'h4] or spi_vif.REG_WDATA[1][8'h3] or spi_vif.REG_RDATA[1][8'h4] or spi_vif.REG_RDATA[1][8'h3]) begin repeat(4) @(posedge spi_vif.i_clk); #15ns;  spi_vif.addr_wg_drv_in_wave_reg1[0] = get_drv_in_wave_reg(signal_path0, `u_spi_reg_wavegen0_path.reg_wg_driver_in_wave_addr); end
    assign  spi_vif.REG_BACKDOOR[1][8'h04]         ={`u_spi_reg_wavegen0_path.reg_wg_driver_in_wave[`u_spi_reg_wavegen0_path.reg_wg_driver_in_wave_addr*8+7], `u_spi_reg_wavegen0_path.reg_wg_driver_in_wave[`u_spi_reg_wavegen0_path.reg_wg_driver_in_wave_addr*8+6], `u_spi_reg_wavegen0_path.reg_wg_driver_in_wave[`u_spi_reg_wavegen0_path.reg_wg_driver_in_wave_addr*8+5], `u_spi_reg_wavegen0_path.reg_wg_driver_in_wave[`u_spi_reg_wavegen0_path.reg_wg_driver_in_wave_addr*8+4], `u_spi_reg_wavegen0_path.reg_wg_driver_in_wave[`u_spi_reg_wavegen0_path.reg_wg_driver_in_wave_addr*8+3], `u_spi_reg_wavegen0_path.reg_wg_driver_in_wave[`u_spi_reg_wavegen0_path.reg_wg_driver_in_wave_addr*8+2], `u_spi_reg_wavegen0_path.reg_wg_driver_in_wave[`u_spi_reg_wavegen0_path.reg_wg_driver_in_wave_addr*8+1], `u_spi_reg_wavegen0_path.reg_wg_driver_in_wave[`u_spi_reg_wavegen0_path.reg_wg_driver_in_wave_addr*8]};
`else
    always @(spi_vif.REG_DATA[1][8'h4] or spi_vif.REG_DATA[1][8'h3] or spi_vif.REG_RDATA[1][8'h4] or spi_vif.REG_RDATA[1][8'h3]) 
      begin 
        repeat(4) 
          @(posedge spi_vif.i_clk); 
          #15ns; 
          spi_vif.REG_BACKDOOR[1][8'h04] = get_drv_in_wave_reg(signal_path0, { `u_spi_reg_wavegen0_path.reg_wg_driver_in_wave_addr_reg_7_.Q, 
                                                                                       `u_spi_reg_wavegen0_path.reg_wg_driver_in_wave_addr_reg_6_.Q,
                                                                                       `u_spi_reg_wavegen0_path.reg_wg_driver_in_wave_addr_reg_5_.Q,
										       `u_spi_reg_wavegen0_path.reg_wg_driver_in_wave_addr_reg_4_.Q,
										       `u_spi_reg_wavegen0_path.reg_wg_driver_in_wave_addr_reg_3_.Q,
										       `u_spi_reg_wavegen0_path.reg_wg_driver_in_wave_addr_reg_2_.Q,
										       `u_spi_reg_wavegen0_path.reg_wg_driver_in_wave_addr_reg_1_.Q,
										       `u_spi_reg_wavegen0_path.reg_wg_driver_in_wave_addr_reg_0_.Q});  
      end
`endif

    assign   spi_vif.REG_BACKDOOR[1][8'h27]          =`u_spi_reg_wavegen0_path.o_wg_driver_int_cnt[7:0];
    assign   spi_vif.REG_BACKDOOR[1][8'h2c]          ={`u_spi_reg_wavegen0_path.reg_wg_driver_alt_lim_reg_15_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_alt_lim_reg_14_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_alt_lim_reg_13_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_alt_lim_reg_12_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_alt_lim_reg_11_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_alt_lim_reg_10_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_alt_lim_reg_9_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_alt_lim_reg_8_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h2b]          ={`u_spi_reg_wavegen0_path.reg_wg_driver_alt_lim_reg_7_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_alt_lim_reg_6_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_alt_lim_reg_5_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_alt_lim_reg_4_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_alt_lim_reg_3_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_alt_lim_reg_2_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_alt_lim_reg_1_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_alt_lim_reg_0_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h2d]          ={`u_spi_reg_wavegen0_path.reg_wg_driver_alt_silent_lim_reg_7_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_alt_silent_lim_reg_6_.Q,  `u_spi_reg_wavegen0_path.reg_wg_driver_alt_silent_lim_reg_5_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_alt_silent_lim_reg_4_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_alt_silent_lim_reg_3_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_alt_silent_lim_reg_2_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_alt_silent_lim_reg_1_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_alt_silent_lim_reg_0_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h2e]          ={`u_spi_reg_wavegen0_path.reg_wg_driver_alt_silent_lim_reg_15_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_alt_silent_lim_reg_14_.Q,  `u_spi_reg_wavegen0_path.reg_wg_driver_alt_silent_lim_reg_13_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_alt_silent_lim_reg_12_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_alt_silent_lim_reg_11_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_alt_silent_lim_reg_10_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_alt_silent_lim_reg_9_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_alt_silent_lim_reg_8_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h20]          ={`u_spi_reg_wavegen0_path.reg_wg_driver_delay_lim_reg_7_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_delay_lim_reg_6_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_delay_lim_reg_5_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_delay_lim_reg_4_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_delay_lim_reg_3_.Q,  `u_spi_reg_wavegen0_path.reg_wg_driver_delay_lim_reg_2_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_delay_lim_reg_1_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_delay_lim_reg_0_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h21]          ={`u_spi_reg_wavegen0_path.reg_wg_driver_delay_lim_reg_15_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_delay_lim_reg_14_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_delay_lim_reg_13_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_delay_lim_reg_12_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_delay_lim_reg_11_.Q,  `u_spi_reg_wavegen0_path.reg_wg_driver_delay_lim_reg_10_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_delay_lim_reg_9_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_delay_lim_reg_8_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h22]          ={`u_spi_reg_wavegen0_path.reg_wg_driver_neg_scale_reg_7_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_scale_reg_6_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_scale_reg_5_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_scale_reg_4_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_scale_reg_3_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_scale_reg_2_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_scale_reg_1_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_scale_reg_0_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h23]          ={`u_spi_reg_wavegen0_path.reg_wg_driver_neg_offset_reg_7_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_offset_reg_6_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_offset_reg_5_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_offset_reg_4_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_offset_reg_3_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_offset_reg_2_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_offset_reg_1_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_offset_reg_0_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h24]          ={`u_spi_reg_wavegen0_path.reg_wg_driver_isel_reg_7_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_isel_reg_6_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_isel_reg_5_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_isel_reg_4_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_isel_reg_3_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_isel_reg_2_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_isel_reg_1_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_isel_reg_0_.Q}  ;
    assign   spi_vif.REG_BACKDOOR[1][8'h25]          ={`u_spi_reg_wavegen0_path.reg_wg_driver_pos_offset_reg_7_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_pos_offset_reg_6_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_pos_offset_reg_5_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_pos_offset_reg_4_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_pos_offset_reg_3_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_pos_offset_reg_2_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_pos_offset_reg_1_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_pos_offset_reg_0_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h28]          ={4'b0,`u_spi_reg_wavegen0_path.reg_wg_driver_int_reg_0_.Q, 3'b0} ; // check connection if see issue in test
    assign   spi_vif.REG_BACKDOOR[1][8'h29]          ={`u_spi_reg_wavegen0_path.reg_wg_driver_int_reg_15_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_int_reg_14_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_int_reg_13_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_int_reg_12_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_int_reg_11_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_int_reg_10_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_int_reg_9_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_int_reg_8_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h2A]          ={`u_spi_reg_wavegen0_path.reg_wg_driver_int_reg_23_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_int_reg_22_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_int_reg_21_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_int_reg_20_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_int_reg_19_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_int_reg_18_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_int_reg_17_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_int_reg_16_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h13]          =  {`u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd1_reg_7_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd1_reg_6_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd1_reg_5_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd1_reg_4_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd1_reg_3_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd1_reg_2_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd1_reg_1_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd1_reg_0_.Q} ;   
    assign   spi_vif.REG_BACKDOOR[1][8'h14]          =  {`u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd1_reg_15_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd1_reg_14_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd1_reg_13_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd1_reg_12_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd1_reg_11_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd1_reg_10_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd1_reg_9_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd1_reg_8_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h15]          =  {`u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd1_reg_7_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd1_reg_6_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd1_reg_5_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd1_reg_4_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd1_reg_3_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd1_reg_2_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd1_reg_1_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd1_reg_0_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h16]          =  {`u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd1_reg_15_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd1_reg_14_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd1_reg_13_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd1_reg_12_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd1_reg_11_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd1_reg_10_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd1_reg_9_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd1_reg_8_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h1c]          =  {`u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd2_reg_7_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd2_reg_6_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd2_reg_5_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd2_reg_4_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd2_reg_3_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd2_reg_2_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd2_reg_1_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd2_reg_0_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h1d]          =  {`u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd2_reg_15_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd2_reg_14_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd2_reg_13_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd2_reg_12_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd2_reg_11_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd2_reg_10_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd2_reg_9_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_hlf_wave_prd2_reg_8_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h1e]          =  {`u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd2_reg_7_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd2_reg_6_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd2_reg_5_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd2_reg_4_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd2_reg_3_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd2_reg_2_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd2_reg_1_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd2_reg_0_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h1f]          =  {`u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd2_reg_15_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd2_reg_14_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd2_reg_13_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd2_reg_12_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd2_reg_11_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd2_reg_10_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd2_reg_9_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_neg_hlf_wave_prd2_reg_8_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h02]          =  {`u_spi_reg_wavegen0_path.reg_wg_driver_point_config_reg_7_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_point_config_reg_6_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_point_config_reg_5_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_point_config_reg_4_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_point_config_reg_3_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_point_config_reg_2_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_point_config_reg_1_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_point_config_reg_0_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h0e]          = {`u_spi_reg_wavegen0_path.reg_wg_driver_rest_t1_reg_7_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t1_reg_6_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t1_reg_5_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t1_reg_4_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t1_reg_3_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t1_reg_2_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t1_reg_1_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t1_reg_0_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h0f]          =  {`u_spi_reg_wavegen0_path.reg_wg_driver_rest_t1_reg_15_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t1_reg_14_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t1_reg_13_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t1_reg_12_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t1_reg_11_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t1_reg_10_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t1_reg_9_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t1_reg_8_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h10]          =  {`u_spi_reg_wavegen0_path.reg_wg_driver_silent_t1_reg_7_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t1_reg_6_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t1_reg_5_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t1_reg_4_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t1_reg_3_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t1_reg_2_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t1_reg_1_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t1_reg_0_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h11]          =  {`u_spi_reg_wavegen0_path.reg_wg_driver_silent_t1_reg_15_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t1_reg_14_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t1_reg_13_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t1_reg_12_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t1_reg_11_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t1_reg_10_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t1_reg_9_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t1_reg_8_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h12]          =  {`u_spi_reg_wavegen0_path.reg_wg_driver_silent_t1_reg_23_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t1_reg_22_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t1_reg_21_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t1_reg_20_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t1_reg_19_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t1_reg_18_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t1_reg_17_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t1_reg_16_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h17]          =  {`u_spi_reg_wavegen0_path.reg_wg_driver_rest_t2_reg_7_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t2_reg_6_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t2_reg_5_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t2_reg_4_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t2_reg_3_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t2_reg_2_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t2_reg_1_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t2_reg_0_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h18]          =  {`u_spi_reg_wavegen0_path.reg_wg_driver_rest_t2_reg_15_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t2_reg_14_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t2_reg_13_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t2_reg_12_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t2_reg_11_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t2_reg_10_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t2_reg_9_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_rest_t2_reg_8_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h19]          =  {`u_spi_reg_wavegen0_path.reg_wg_driver_silent_t2_reg_7_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t2_reg_6_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t2_reg_5_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t2_reg_4_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t2_reg_3_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t2_reg_2_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t2_reg_1_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t2_reg_0_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h1a]          =  {`u_spi_reg_wavegen0_path.reg_wg_driver_silent_t2_reg_15_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t2_reg_14_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t2_reg_13_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t2_reg_12_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t2_reg_11_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t2_reg_10_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t2_reg_9_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t2_reg_8_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h1b]          =  {`u_spi_reg_wavegen0_path.reg_wg_driver_silent_t2_reg_23_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t2_reg_22_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t2_reg_21_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t2_reg_20_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t2_reg_19_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t2_reg_18_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t2_reg_17_.Q, `u_spi_reg_wavegen0_path.reg_wg_driver_silent_t2_reg_16_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h26]          =  {`u_spi_reg_wavegen0_path.reg_wg_pullba_reg_7_.Q, `u_spi_reg_wavegen0_path.reg_wg_pullba_reg_6_.Q,`u_spi_reg_wavegen0_path.reg_wg_pullba_reg_5_.Q,`u_spi_reg_wavegen0_path.reg_wg_pullba_reg_4_.Q,`u_spi_reg_wavegen0_path.reg_wg_pullba_reg_3_.Q,`u_spi_reg_wavegen0_path.reg_wg_pullba_reg_2_.Q,`u_spi_reg_wavegen0_path.reg_wg_pullba_reg_1_.Q,`u_spi_reg_wavegen0_path.reg_wg_pullba_reg_0_.Q}      ;  
    assign   spi_vif.REG_BACKDOOR[1][8'h2f]          =  {`u_spi_reg_wavegen0_path.drive_ctrl_reg0_reg_7_.Q, `u_spi_reg_wavegen0_path.drive_ctrl_reg0_reg_6_.Q,`u_spi_reg_wavegen0_path.drive_ctrl_reg0_reg_5_.Q,`u_spi_reg_wavegen0_path.drive_ctrl_reg0_reg_4_.Q,`u_spi_reg_wavegen0_path.drive_ctrl_reg0_reg_3_.Q,`u_spi_reg_wavegen0_path.drive_ctrl_reg0_reg_2_.Q,`u_spi_reg_wavegen0_path.drive_ctrl_reg0_reg_1_.Q,`u_spi_reg_wavegen0_path.drive_ctrl_reg0_reg_0_.Q}       ;
    assign   spi_vif.REG_BACKDOOR[1][8'h30]          =  {`u_spi_reg_wavegen0_path.drive_ctrl_reg1_reg_7_.Q, `u_spi_reg_wavegen0_path.drive_ctrl_reg1_reg_6_.Q,`u_spi_reg_wavegen0_path.drive_ctrl_reg1_reg_5_.Q,`u_spi_reg_wavegen0_path.drive_ctrl_reg1_reg_4_.Q,`u_spi_reg_wavegen0_path.drive_ctrl_reg1_reg_3_.Q,`u_spi_reg_wavegen0_path.drive_ctrl_reg1_reg_2_.Q,`u_spi_reg_wavegen0_path.drive_ctrl_reg1_reg_1_.Q,`u_spi_reg_wavegen0_path.drive_ctrl_reg1_reg_0_.Q}       ;
    assign   spi_vif.REG_BACKDOOR[1][8'h31]          =  {`u_spi_reg_wavegen0_path.drive_ctrl_reg2_reg_7_.Q, `u_spi_reg_wavegen0_path.drive_ctrl_reg2_reg_6_.Q,`u_spi_reg_wavegen0_path.drive_ctrl_reg2_reg_5_.Q,`u_spi_reg_wavegen0_path.drive_ctrl_reg2_reg_4_.Q,`u_spi_reg_wavegen0_path.drive_ctrl_reg2_reg_3_.Q,`u_spi_reg_wavegen0_path.drive_ctrl_reg2_reg_2_.Q,`u_spi_reg_wavegen0_path.drive_ctrl_reg2_reg_1_.Q,`u_spi_reg_wavegen0_path.drive_ctrl_reg2_reg_0_.Q}       ;
    
//    assign #6ns  spi_vif.b_i[0]  =`u_spi_reg_wavegen0_path.u_boot_mul.b_i[7:0];
//    assign #6ns  spi_vif.a_i[0]  =`u_spi_reg_wavegen0_path.u_boot_mul.a_i[7:0];
//    assign #6ns  spi_vif.mul_o[0]=`u_spi_reg_wavegen0_path.u_boot_mul.mul_o[15:0];

    assign   spi_vif.REG_BACKDOOR[1][8'h00+8'h40]      ={`u_spi_reg_wavegen1_path.reg_wg_driver_config_reg_7_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_config_reg_6_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_config_reg_5_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_config_reg_4_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_config_reg_3_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_config_reg_2_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_config_reg_1_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_config_reg_0_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h01+8'h40]      ={`u_spi_reg_wavegen1_path.reg_wg_driver_ctrl_reg_7_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_ctrl_reg_6_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_ctrl_reg_5_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_ctrl_reg_4_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_ctrl_reg_3_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_ctrl_reg_2_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_ctrl_reg_1_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_ctrl_reg_0_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h06+8'h40]      ={`u_spi_reg_wavegen1_path.reg_wg_driver_rest_t_reg_15_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t_reg_14_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t_reg_13_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t_reg_12_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t_reg_11_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t_reg_10_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t_reg_9_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t_reg_8_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h05+8'h40]      ={`u_spi_reg_wavegen1_path.reg_wg_driver_rest_t_reg_7_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t_reg_6_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t_reg_5_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t_reg_4_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t_reg_3_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t_reg_2_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t_reg_1_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t_reg_0_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h07+8'h40]      ={`u_spi_reg_wavegen1_path.reg_wg_driver_silent_t_reg_7_.Q,  `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t_reg_6_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t_reg_5_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t_reg_4_.Q,  `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t_reg_3_.Q,  `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t_reg_2_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t_reg_1_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t_reg_0_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h08+8'h40]      ={`u_spi_reg_wavegen1_path.reg_wg_driver_silent_t_reg_15_.Q,  `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t_reg_14_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t_reg_13_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t_reg_12_.Q,  `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t_reg_11_.Q,  `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t_reg_10_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t_reg_9_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t_reg_8_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h09+8'h40]      ={`u_spi_reg_wavegen1_path.reg_wg_driver_silent_t_reg_23_.Q,  `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t_reg_22_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t_reg_21_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t_reg_20_.Q,  `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t_reg_19_.Q,  `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t_reg_18_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t_reg_17_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t_reg_16_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h0a+8'h40]      ={`u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd_reg_7_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd_reg_6_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd_reg_5_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd_reg_4_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd_reg_3_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd_reg_2_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd_reg_1_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd_reg_0_.Q}  ;
    assign   spi_vif.REG_BACKDOOR[1][8'h0b+8'h40]      ={`u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd_reg_15_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd_reg_14_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd_reg_13_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd_reg_12_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd_reg_11_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd_reg_10_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd_reg_9_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd_reg_8_.Q}  ;
    assign   spi_vif.REG_BACKDOOR[1][8'h0c+8'h40]      ={`u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd_reg_7_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd_reg_6_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd_reg_5_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd_reg_4_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd_reg_3_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd_reg_2_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd_reg_1_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd_reg_0_.Q}  ;
    assign   spi_vif.REG_BACKDOOR[1][8'h0d+8'h40]      ={`u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd_reg_15_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd_reg_14_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd_reg_13_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd_reg_12_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd_reg_11_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd_reg_10_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd_reg_9_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd_reg_8_.Q}  ;
    assign   spi_vif.REG_BACKDOOR[1][8'h03+8'h40]      ={`u_spi_reg_wavegen1_path.reg_wg_driver_in_wave_addr_reg_7_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_in_wave_addr_reg_6_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_in_wave_addr_reg_5_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_in_wave_addr_reg_4_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_in_wave_addr_reg_3_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_in_wave_addr_reg_2_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_in_wave_addr_reg_1_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_in_wave_addr_reg_0_.Q} ;

`ifdef PRESCAN
    assign   spi_vif.REG_BACKDOOR[1][8'h04+8'h40]         ={`u_spi_reg_wavegen1_path.reg_wg_driver_in_wave[`u_spi_reg_wavegen1_path.reg_wg_driver_in_wave_addr*8+7], `u_spi_reg_wavegen1_path.reg_wg_driver_in_wave[`u_spi_reg_wavegen1_path.reg_wg_driver_in_wave_addr*8+6], `u_spi_reg_wavegen1_path.reg_wg_driver_in_wave[`u_spi_reg_wavegen1_path.reg_wg_driver_in_wave_addr*8+5], `u_spi_reg_wavegen1_path.reg_wg_driver_in_wave[`u_spi_reg_wavegen1_path.reg_wg_driver_in_wave_addr*8+4], `u_spi_reg_wavegen1_path.reg_wg_driver_in_wave[`u_spi_reg_wavegen1_path.reg_wg_driver_in_wave_addr*8+3], `u_spi_reg_wavegen1_path.reg_wg_driver_in_wave[`u_spi_reg_wavegen1_path.reg_wg_driver_in_wave_addr*8+2], `u_spi_reg_wavegen1_path.reg_wg_driver_in_wave[`u_spi_reg_wavegen1_path.reg_wg_driver_in_wave_addr*8+1], `u_spi_reg_wavegen1_path.reg_wg_driver_in_wave[`u_spi_reg_wavegen1_path.reg_wg_driver_in_wave_addr*8]};
`else
    always @(spi_vif.REG_DATA[1][8'h44] or spi_vif.REG_DATA[1][8'h43] or spi_vif.REG_RDATA[1][8'h44] or spi_vif.REG_RDATA[1][8'h43]) 
      begin 
        repeat(4) 
          @(posedge spi_vif.i_clk); 
          #15ns; 
          spi_vif.REG_BACKDOOR[1][8'h04+8'h40] = get_drv_in_wave_reg(signal_path1, { `u_spi_reg_wavegen1_path.reg_wg_driver_in_wave_addr_reg_7_.Q, 
                                                                                       `u_spi_reg_wavegen1_path.reg_wg_driver_in_wave_addr_reg_6_.Q,
                                                                                       `u_spi_reg_wavegen1_path.reg_wg_driver_in_wave_addr_reg_5_.Q,
										       `u_spi_reg_wavegen1_path.reg_wg_driver_in_wave_addr_reg_4_.Q,
										       `u_spi_reg_wavegen1_path.reg_wg_driver_in_wave_addr_reg_3_.Q,
										       `u_spi_reg_wavegen1_path.reg_wg_driver_in_wave_addr_reg_2_.Q,
										       `u_spi_reg_wavegen1_path.reg_wg_driver_in_wave_addr_reg_1_.Q,
										       `u_spi_reg_wavegen1_path.reg_wg_driver_in_wave_addr_reg_0_.Q});  
      end
`endif
    assign   spi_vif.REG_BACKDOOR[1][8'h27+8'h40]  =`u_spi_reg_wavegen1_path.o_wg_driver_int_cnt[7:0];
    assign   spi_vif.REG_BACKDOOR[1][8'h2c+8'h40]  ={`u_spi_reg_wavegen1_path.reg_wg_driver_alt_lim_reg_15_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_alt_lim_reg_14_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_alt_lim_reg_13_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_alt_lim_reg_12_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_alt_lim_reg_11_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_alt_lim_reg_10_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_alt_lim_reg_9_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_alt_lim_reg_8_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h2b+8'h40]  ={`u_spi_reg_wavegen1_path.reg_wg_driver_alt_lim_reg_7_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_alt_lim_reg_6_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_alt_lim_reg_5_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_alt_lim_reg_4_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_alt_lim_reg_3_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_alt_lim_reg_2_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_alt_lim_reg_1_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_alt_lim_reg_0_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h2d+8'h40]  ={`u_spi_reg_wavegen1_path.reg_wg_driver_alt_silent_lim_reg_7_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_alt_silent_lim_reg_6_.Q,  `u_spi_reg_wavegen1_path.reg_wg_driver_alt_silent_lim_reg_5_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_alt_silent_lim_reg_4_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_alt_silent_lim_reg_3_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_alt_silent_lim_reg_2_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_alt_silent_lim_reg_1_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_alt_silent_lim_reg_0_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h2e+8'h40]  ={`u_spi_reg_wavegen1_path.reg_wg_driver_alt_silent_lim_reg_15_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_alt_silent_lim_reg_14_.Q,  `u_spi_reg_wavegen1_path.reg_wg_driver_alt_silent_lim_reg_13_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_alt_silent_lim_reg_12_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_alt_silent_lim_reg_11_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_alt_silent_lim_reg_10_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_alt_silent_lim_reg_9_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_alt_silent_lim_reg_8_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h20+8'h40]  ={`u_spi_reg_wavegen1_path.reg_wg_driver_delay_lim_reg_7_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_delay_lim_reg_6_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_delay_lim_reg_5_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_delay_lim_reg_4_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_delay_lim_reg_3_.Q,  `u_spi_reg_wavegen1_path.reg_wg_driver_delay_lim_reg_2_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_delay_lim_reg_1_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_delay_lim_reg_0_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h21+8'h40]  ={`u_spi_reg_wavegen1_path.reg_wg_driver_delay_lim_reg_15_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_delay_lim_reg_14_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_delay_lim_reg_13_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_delay_lim_reg_12_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_delay_lim_reg_11_.Q,  `u_spi_reg_wavegen1_path.reg_wg_driver_delay_lim_reg_10_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_delay_lim_reg_9_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_delay_lim_reg_8_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h22+8'h40]  ={`u_spi_reg_wavegen1_path.reg_wg_driver_neg_scale_reg_7_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_scale_reg_6_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_scale_reg_5_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_scale_reg_4_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_scale_reg_3_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_scale_reg_2_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_scale_reg_1_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_scale_reg_0_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h23+8'h40]  ={`u_spi_reg_wavegen1_path.reg_wg_driver_neg_offset_reg_7_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_offset_reg_6_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_offset_reg_5_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_offset_reg_4_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_offset_reg_3_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_offset_reg_2_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_offset_reg_1_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_offset_reg_0_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h24+8'h40]  ={`u_spi_reg_wavegen1_path.reg_wg_driver_isel_reg_7_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_isel_reg_6_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_isel_reg_5_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_isel_reg_4_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_isel_reg_3_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_isel_reg_2_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_isel_reg_1_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_isel_reg_0_.Q}  ;
    assign   spi_vif.REG_BACKDOOR[1][8'h25+8'h40]  ={`u_spi_reg_wavegen1_path.reg_wg_driver_pos_offset_reg_7_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_pos_offset_reg_6_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_pos_offset_reg_5_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_pos_offset_reg_4_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_pos_offset_reg_3_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_pos_offset_reg_2_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_pos_offset_reg_1_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_pos_offset_reg_0_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h28+8'h40]  ={4'b0,`u_spi_reg_wavegen1_path.reg_wg_driver_int_reg_0_.Q, 3'b0} ; // check connection if see issue in test
    assign   spi_vif.REG_BACKDOOR[1][8'h29+8'h40]  ={`u_spi_reg_wavegen1_path.reg_wg_driver_int_reg_15_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_int_reg_14_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_int_reg_13_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_int_reg_12_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_int_reg_11_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_int_reg_10_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_int_reg_9_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_int_reg_8_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h2A+8'h40]  ={`u_spi_reg_wavegen1_path.reg_wg_driver_int_reg_23_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_int_reg_22_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_int_reg_21_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_int_reg_20_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_int_reg_19_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_int_reg_18_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_int_reg_17_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_int_reg_16_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h13+8'h40]  =  {`u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd1_reg_7_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd1_reg_6_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd1_reg_5_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd1_reg_4_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd1_reg_3_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd1_reg_2_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd1_reg_1_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd1_reg_0_.Q} ;   
    assign   spi_vif.REG_BACKDOOR[1][8'h14+8'h40]  =  {`u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd1_reg_15_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd1_reg_14_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd1_reg_13_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd1_reg_12_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd1_reg_11_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd1_reg_10_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd1_reg_9_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd1_reg_8_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h15+8'h40]  =  {`u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd1_reg_7_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd1_reg_6_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd1_reg_5_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd1_reg_4_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd1_reg_3_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd1_reg_2_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd1_reg_1_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd1_reg_0_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h16+8'h40]  =  {`u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd1_reg_15_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd1_reg_14_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd1_reg_13_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd1_reg_12_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd1_reg_11_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd1_reg_10_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd1_reg_9_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd1_reg_8_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h1c+8'h40]  =  {`u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd2_reg_7_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd2_reg_6_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd2_reg_5_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd2_reg_4_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd2_reg_3_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd2_reg_2_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd2_reg_1_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd2_reg_0_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h1d+8'h40]  =  {`u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd2_reg_15_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd2_reg_14_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd2_reg_13_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd2_reg_12_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd2_reg_11_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd2_reg_10_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd2_reg_9_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_hlf_wave_prd2_reg_8_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h1e+8'h40]  =  {`u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd2_reg_7_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd2_reg_6_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd2_reg_5_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd2_reg_4_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd2_reg_3_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd2_reg_2_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd2_reg_1_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd2_reg_0_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h1f+8'h40]  =  {`u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd2_reg_15_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd2_reg_14_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd2_reg_13_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd2_reg_12_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd2_reg_11_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd2_reg_10_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd2_reg_9_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_neg_hlf_wave_prd2_reg_8_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h02+8'h40]  =  {`u_spi_reg_wavegen1_path.reg_wg_driver_point_config_reg_7_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_point_config_reg_6_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_point_config_reg_5_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_point_config_reg_4_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_point_config_reg_3_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_point_config_reg_2_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_point_config_reg_1_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_point_config_reg_0_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h0e+8'h40]    = {`u_spi_reg_wavegen1_path.reg_wg_driver_rest_t1_reg_7_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t1_reg_6_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t1_reg_5_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t1_reg_4_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t1_reg_3_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t1_reg_2_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t1_reg_1_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t1_reg_0_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h0f+8'h40]    =  {`u_spi_reg_wavegen1_path.reg_wg_driver_rest_t1_reg_15_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t1_reg_14_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t1_reg_13_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t1_reg_12_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t1_reg_11_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t1_reg_10_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t1_reg_9_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t1_reg_8_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h10+8'h40]    =  {`u_spi_reg_wavegen1_path.reg_wg_driver_silent_t1_reg_7_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t1_reg_6_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t1_reg_5_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t1_reg_4_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t1_reg_3_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t1_reg_2_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t1_reg_1_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t1_reg_0_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h11+8'h40]    =  {`u_spi_reg_wavegen1_path.reg_wg_driver_silent_t1_reg_15_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t1_reg_14_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t1_reg_13_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t1_reg_12_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t1_reg_11_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t1_reg_10_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t1_reg_9_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t1_reg_8_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h12+8'h40]    =  {`u_spi_reg_wavegen1_path.reg_wg_driver_silent_t1_reg_23_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t1_reg_22_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t1_reg_21_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t1_reg_20_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t1_reg_19_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t1_reg_18_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t1_reg_17_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t1_reg_16_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h17+8'h40]    =  {`u_spi_reg_wavegen1_path.reg_wg_driver_rest_t2_reg_7_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t2_reg_6_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t2_reg_5_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t2_reg_4_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t2_reg_3_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t2_reg_2_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t2_reg_1_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t2_reg_0_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h18+8'h40]    =  {`u_spi_reg_wavegen1_path.reg_wg_driver_rest_t2_reg_15_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t2_reg_14_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t2_reg_13_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t2_reg_12_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t2_reg_11_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t2_reg_10_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t2_reg_9_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_rest_t2_reg_8_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h19+8'h40]    =  {`u_spi_reg_wavegen1_path.reg_wg_driver_silent_t2_reg_7_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t2_reg_6_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t2_reg_5_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t2_reg_4_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t2_reg_3_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t2_reg_2_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t2_reg_1_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t2_reg_0_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h1a+8'h40]    =  {`u_spi_reg_wavegen1_path.reg_wg_driver_silent_t2_reg_15_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t2_reg_14_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t2_reg_13_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t2_reg_12_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t2_reg_11_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t2_reg_10_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t2_reg_9_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t2_reg_8_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h1b+8'h40]    =  {`u_spi_reg_wavegen1_path.reg_wg_driver_silent_t2_reg_23_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t2_reg_22_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t2_reg_21_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t2_reg_20_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t2_reg_19_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t2_reg_18_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t2_reg_17_.Q, `u_spi_reg_wavegen1_path.reg_wg_driver_silent_t2_reg_16_.Q} ;
    assign   spi_vif.REG_BACKDOOR[1][8'h26+8'h40]  =  {`u_spi_reg_wavegen1_path.reg_wg_pullba_reg_7_.Q, `u_spi_reg_wavegen1_path.reg_wg_pullba_reg_6_.Q,`u_spi_reg_wavegen1_path.reg_wg_pullba_reg_5_.Q,`u_spi_reg_wavegen1_path.reg_wg_pullba_reg_4_.Q,`u_spi_reg_wavegen1_path.reg_wg_pullba_reg_3_.Q,`u_spi_reg_wavegen1_path.reg_wg_pullba_reg_2_.Q,`u_spi_reg_wavegen1_path.reg_wg_pullba_reg_1_.Q,`u_spi_reg_wavegen1_path.reg_wg_pullba_reg_0_.Q}      ;  
    assign   spi_vif.REG_BACKDOOR[1][8'h2f+8'h40]  =  {`u_spi_reg_wavegen1_path.drive_ctrl_reg0_reg_7_.Q, `u_spi_reg_wavegen1_path.drive_ctrl_reg0_reg_6_.Q,`u_spi_reg_wavegen1_path.drive_ctrl_reg0_reg_5_.Q,`u_spi_reg_wavegen1_path.drive_ctrl_reg0_reg_4_.Q,`u_spi_reg_wavegen1_path.drive_ctrl_reg0_reg_3_.Q,`u_spi_reg_wavegen1_path.drive_ctrl_reg0_reg_2_.Q,`u_spi_reg_wavegen1_path.drive_ctrl_reg0_reg_1_.Q,`u_spi_reg_wavegen1_path.drive_ctrl_reg0_reg_0_.Q}       ;
    assign   spi_vif.REG_BACKDOOR[1][8'h30+8'h40]  =  {`u_spi_reg_wavegen1_path.drive_ctrl_reg1_reg_7_.Q, `u_spi_reg_wavegen1_path.drive_ctrl_reg1_reg_6_.Q,`u_spi_reg_wavegen1_path.drive_ctrl_reg1_reg_5_.Q,`u_spi_reg_wavegen1_path.drive_ctrl_reg1_reg_4_.Q,`u_spi_reg_wavegen1_path.drive_ctrl_reg1_reg_3_.Q,`u_spi_reg_wavegen1_path.drive_ctrl_reg1_reg_2_.Q,`u_spi_reg_wavegen1_path.drive_ctrl_reg1_reg_1_.Q,`u_spi_reg_wavegen1_path.drive_ctrl_reg1_reg_0_.Q}       ;
    assign   spi_vif.REG_BACKDOOR[1][8'h31+8'h40]  =  {`u_spi_reg_wavegen1_path.drive_ctrl_reg2_reg_7_.Q, `u_spi_reg_wavegen1_path.drive_ctrl_reg2_reg_6_.Q,`u_spi_reg_wavegen1_path.drive_ctrl_reg2_reg_5_.Q,`u_spi_reg_wavegen1_path.drive_ctrl_reg2_reg_4_.Q,`u_spi_reg_wavegen1_path.drive_ctrl_reg2_reg_3_.Q,`u_spi_reg_wavegen1_path.drive_ctrl_reg2_reg_2_.Q,`u_spi_reg_wavegen1_path.drive_ctrl_reg2_reg_1_.Q,`u_spi_reg_wavegen1_path.drive_ctrl_reg2_reg_0_.Q}       ;
*/


initial begin
    nnc_config_db#(virtual nnc_spi_interface)::set(uvm_root::get(), "uvm_test_top.top_env", "spi_vif", spi_vif);
    nnc_config_db#(virtual nnc_spi_interface)::set(uvm_root::get(), "uvm_test_top.top_env.*", "spi_vif", spi_vif);
end
