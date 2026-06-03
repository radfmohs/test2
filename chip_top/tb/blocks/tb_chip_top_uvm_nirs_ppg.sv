//--------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------
// Project      : Nanochap ENS2
// File         : tb_chip_top_uvm_nirs_ppg.sv
// Description  : Assertion to check NIRS_PPG timing daigram 
// Designer     : Supriya
// Date         : 11-03-2026
// Revision     : 0.1
//--------------------------------------------------------------------------------------
// --------------------------------------------------------------------------------------

//add checkers nirs_ppg
//1) T_RESET_STABLE should be grater than zero (>0) else throw error
//"2) // After D2A_NIRS_RESET_SW deasserts(===1), 
//    2.a) RESET_SW signals must be stable for N cycles cycles
//    2.b)  During which LED/IPD remain quiet and INN_SW HIGH *N time or INN_SW HIGH  when RESET_SW rising edge occured"
//3) LED_ON can only be turon td0(receiver stable) Plus RESET_SW gets stable(this timing is missing in timing diagram of ENS2_NIRS_PPG_controller dic provided by truong)
//4) LED ON stability ==> LED ON time == N cycles
//5) During IPD_SW activity(rise or fall) check LED_ON rising and falling edge
//6) does it needs to be checked LED MIN TIME and MAX TIME
//7) When LED_ON==1, toggle IPD_SW and IIN_SW(falling edge) and rising edge toggle is not allowed when LED_ON is HIGH
//8) Coarse fine chnaged only when LED is off
//9) Minimum gap between iref coarse and iref fine
//10) IREF coarse chnage and hold for sometime (ON TIME)
//11) IREF FINE change and hold for some time(ON TIME)

nnc_nirs_ppg_interface nirs_ppg_vif();

assign  nirs_ppg_vif.nirs_ppg_rst               =  `NIRS_PPG_TOP.rst_n;
assign  nirs_ppg_vif.ens2_sys_clk               =  `NIRS_PPG_TOP.clk_sys;
assign  nirs_ppg_vif.nirs_ppg_clk               =  `NIRS_PPG_TOP.clk_ppg;
//
assign  nirs_ppg_vif.D2A_PDBIAS_ADJ             =  `ANA_TOP.D2A_PDBIAS_ADJ; 
assign  nirs_ppg_vif.D2A_PDBIAS_EN              =  `ANA_TOP.D2A_PDBIAS_EN;
//
wire   [7:0]  d2a_nirs_en_bus;
wire   [7:0]  d2a_nirs_idac_en_bus;
wire [7:0]  d2a_nirs_reset_sw_bus;
wire [7:0]  d2a_nirs_ipd_sw_bus;
wire [7:0]  d2a_nirs_iin_sw_bus;
wire [7:0]  d2a_nirs_ipdmirror_adj_bus;
wire [7:0]  d2a_nirs_irefc_adj_bus;
wire [7:0]  d2a_nirs_cfrate_adj_bus;
wire [7:0]  d2a_nirs_idac_adj_bus;
wire [7:0]  a2nd_nirs_irefcoarse_bus;
wire [7:0]  a2d_nirs_ireffine_bus;

//
assign d2a_nirs_en_bus      = {`ANA_TOP.D2A_NIRS7_EN,`ANA_TOP.D2A_NIRS6_EN,`ANA_TOP.D2A_NIRS5_EN,`ANA_TOP.D2A_NIRS4_EN,
                                     `ANA_TOP.D2A_NIRS3_EN,`ANA_TOP.D2A_NIRS2_EN,`ANA_TOP.D2A_NIRS1_EN,`ANA_TOP.D2A_NIRS0_EN};
//
assign d2a_nirs_idac_en_bus =  {`ANA_TOP.D2A_NIRS7_IDAC_EN, `ANA_TOP.D2A_NIRS6_IDAC_EN,`ANA_TOP.D2A_NIRS5_IDAC_EN,`ANA_TOP.D2A_NIRS4_IDAC_EN,
                                      `ANA_TOP.D2A_NIRS3_IDAC_EN,`ANA_TOP.D2A_NIRS2_IDAC_EN,`ANA_TOP.D2A_NIRS1_IDAC_EN,`ANA_TOP.D2A_NIRS0_IDAC_EN};
//
assign  nirs_ppg_vif.D2A_NIRS_TEST_EN           =  `ANA_TOP.D2A_NIRS_TEST_EN;
//
assign d2a_nirs_reset_sw_bus  = {`ANA_TOP.D2A_NIRS7_RESET_SW, `ANA_TOP.D2A_NIRS6_RESET_SW, `ANA_TOP.D2A_NIRS5_RESET_SW, `ANA_TOP.D2A_NIRS4_RESET_SW,
                                     `ANA_TOP.D2A_NIRS3_RESET_SW, `ANA_TOP.D2A_NIRS2_RESET_SW, `ANA_TOP.D2A_NIRS1_RESET_SW, `ANA_TOP.D2A_NIRS0_RESET_SW };
//  
assign d2a_nirs_ipd_sw_bus    = {`ANA_TOP.D2A_NIRS7_IPD_SW, `ANA_TOP.D2A_NIRS6_IPD_SW, `ANA_TOP.D2A_NIRS5_IPD_SW, `ANA_TOP.D2A_NIRS4_IPD_SW,
                                     `ANA_TOP.D2A_NIRS3_IPD_SW, `ANA_TOP.D2A_NIRS2_IPD_SW, `ANA_TOP.D2A_NIRS1_IPD_SW, `ANA_TOP.D2A_NIRS0_IPD_SW };
//
assign d2a_nirs_iin_sw_bus   = {`ANA_TOP.D2A_NIRS7_IIN_SW, `ANA_TOP.D2A_NIRS6_IIN_SW, `ANA_TOP.D2A_NIRS5_IIN_SW,  `ANA_TOP.D2A_NIRS4_IIN_SW,
                                    `ANA_TOP.D2A_NIRS3_IIN_SW, `ANA_TOP.D2A_NIRS2_IIN_SW, `ANA_TOP.D2A_NIRS1_IIN_SW,  `ANA_TOP.D2A_NIRS0_IIN_SW}; 
//
assign d2a_nirs_ipdmirror_adj_bus  = {`ANA_TOP.D2A_NIRS7_IPDMIRROR_ADJ, `ANA_TOP.D2A_NIRS6_IPDMIRROR_ADJ, `ANA_TOP.D2A_NIRS5_IPDMIRROR_ADJ, `ANA_TOP.D2A_NIRS4_IPDMIRROR_ADJ,
                                          `ANA_TOP.D2A_NIRS3_IPDMIRROR_ADJ, `ANA_TOP.D2A_NIRS2_IPDMIRROR_ADJ, `ANA_TOP.D2A_NIRS1_IPDMIRROR_ADJ, `ANA_TOP.D2A_NIRS0_IPDMIRROR_ADJ };
//
assign d2a_nirs_irefc_adj_bus      = {`ANA_TOP.D2A_NIRS7_IREFC_ADJ, `ANA_TOP.D2A_NIRS6_IREFC_ADJ, `ANA_TOP.D2A_NIRS5_IREFC_ADJ, `ANA_TOP.D2A_NIRS4_IREFC_ADJ,
                                          `ANA_TOP.D2A_NIRS3_IREFC_ADJ, `ANA_TOP.D2A_NIRS2_IREFC_ADJ, `ANA_TOP.D2A_NIRS1_IREFC_ADJ, `ANA_TOP.D2A_NIRS0_IREFC_ADJ };
//
assign d2a_nirs_cfrate_adj_bus     = {`ANA_TOP.D2A_NIRS7_CFRATE_ADJ, `ANA_TOP.D2A_NIRS6_CFRATE_ADJ, `ANA_TOP.D2A_NIRS5_CFRATE_ADJ, `ANA_TOP.D2A_NIRS4_CFRATE_ADJ,
                                          `ANA_TOP.D2A_NIRS3_CFRATE_ADJ, `ANA_TOP.D2A_NIRS2_CFRATE_ADJ, `ANA_TOP.D2A_NIRS1_CFRATE_ADJ, `ANA_TOP.D2A_NIRS0_CFRATE_ADJ };
//
assign d2a_nirs_idac_adj_bus       = {`ANA_TOP.D2A_NIRS7_IDAC_ADJ, `ANA_TOP.D2A_NIRS6_IDAC_ADJ, `ANA_TOP.D2A_NIRS5_IDAC_ADJ, `ANA_TOP.D2A_NIRS4_IDAC_ADJ,
                                          `ANA_TOP.D2A_NIRS3_IDAC_ADJ, `ANA_TOP.D2A_NIRS2_IDAC_ADJ, `ANA_TOP.D2A_NIRS1_IDAC_ADJ, `ANA_TOP.D2A_NIRS0_IDAC_ADJ };
//
assign a2nd_nirs_irefcoarse_bus    = {`ANA_TOP.A2D_NIRS7_IREFCOARSE, `ANA_TOP.A2D_NIRS6_IREFCOARSE, `ANA_TOP.A2D_NIRS5_IREFCOARSE, `ANA_TOP.A2D_NIRS4_IREFCOARSE,                                                                                                         `ANA_TOP.A2D_NIRS3_IREFCOARSE, `ANA_TOP.A2D_NIRS2_IREFCOARSE, `ANA_TOP.A2D_NIRS1_IREFCOARSE, `ANA_TOP.A2D_NIRS0_IREFCOARSE };
//
assign a2d_nirs_ireffine_bus       = {`ANA_TOP.A2D_NIRS7_IREFFINE, `ANA_TOP.A2D_NIRS6_IREFFINE, `ANA_TOP.A2D_NIRS5_IREFFINE, `ANA_TOP.A2D_NIRS4_IREFFINE,
                                          `ANA_TOP.A2D_NIRS3_IREFFINE, `ANA_TOP.A2D_NIRS2_IREFFINE, `ANA_TOP.A2D_NIRS1_IREFFINE, `ANA_TOP.A2D_NIRS0_IREFFINE };

//
//always_comb begin
genvar i;
generate
  for (i = 0; i < 8; i++) begin
  //for(int i=0; i<8; i++)begin
    always @(posedge `NIRS_PPG_TOP.clk_sys)begin
      nirs_ppg_vif.D2A_NIRS_EN[i]                <= d2a_nirs_en_bus[i];
      nirs_ppg_vif.D2A_NIRS_IDAC_EN[i]           <= d2a_nirs_idac_en_bus[i] ;
      nirs_ppg_vif.D2A_NIRS_RESET_SW[i]          <= d2a_nirs_reset_sw_bus[i];
      nirs_ppg_vif.D2A_NIRS_IPD_SW[i]            <= d2a_nirs_ipd_sw_bus[i];
      nirs_ppg_vif.D2A_NIRS_IIN_SW[i]            <= d2a_nirs_iin_sw_bus[i];
      nirs_ppg_vif.D2A_NIRS_IPDMIRROR_ADJ[i]     <= d2a_nirs_ipdmirror_adj_bus[i];
      nirs_ppg_vif.D2A_NIRS_IREFC_ADJ[i]         <= d2a_nirs_irefc_adj_bus[i];
      nirs_ppg_vif.D2A_NIRS_CFRATE_ADJ[i]        <= d2a_nirs_cfrate_adj_bus[i];
      nirs_ppg_vif.D2A_NIRS_IDAC_ADJ[i]          <= d2a_nirs_idac_adj_bus[i];
      nirs_ppg_vif.A2D_NIRS_IREFCOARSE[i]        <= a2nd_nirs_irefcoarse_bus[i];
      nirs_ppg_vif.A2D_NIRS_IREFFINE[i]          <= a2d_nirs_ireffine_bus[i];
    end
  end
endgenerate
 
assign  nirs_ppg_vif.D2A_CLK_NIRS               =  `ANA_TOP.D2A_CLK_NIRS;

assign  nirs_ppg_vif.D2A_NIRS_CHOPPER_EN        =  `ANA_TOP.D2A_NIRS_CHOPPER_EN;

assign  nirs_ppg_vif.D2A_NIRS_FCHOP_ADJ         =  `ANA_TOP.D2A_NIRS_FCHOP_ADJ;
    

//
genvar i;
generate
  for (i = 0; i < 8; i++) begin
    always @(posedge `NIRS_PPG_TOP.clk_sys or negedge `NIRS_PPG_TOP.rst_n) begin
      if (!`NIRS_PPG_TOP.rst_n)begin
        nirs_ppg_vif.nirs_ppg_en[i] <= 1'b0;
        nirs_ppg_vif.nirs_ppg_meas[i] <= 1'b0;
        nirs_ppg_vif.nirs_int_io[i]   <= 1'b0;
      end
      else begin
        // constant hierarchical reference per instance (macro expands to the path)
        nirs_ppg_vif.nirs_ppg_en[i]  <= `NIRS_PPG_TOP.u_nirs_ctrl_top[i].u_nirs_pulse_ctrl.NIRS_EN;
        nirs_ppg_vif.nirs_ppg_meas[i] <= `NIRS_PPG_TOP.u_nirs_ctrl_top[i].u_nirs_pulse_ctrl.NIRS_MEAS;
        nirs_ppg_vif.nirs_int_io[i]   <= `NIRS_PPG_TOP.u_nirs_ctrl_top[i].u_nirs_ppg_int.INT_IO;
      end
    end
  end
endgenerate

//{soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_nirs_wrapper.u_nirs_ctrl_top[0].u_nirs_pulse_ctrl.NIRS_MEAS}

// Set CONFIG_DB
initial begin
    //nnc_config_db#(virtual nnc_nirs_ppg_interface)::set(uvm_root::get(), "uvm_test_top.top_env.nirs_ppg_env.*", "nirs_ppg_vif", nirs_ppg_vif);
     nnc_config_db#(virtual nnc_nirs_ppg_interface)::set(uvm_root::get(), "*", "nirs_ppg_vif", nirs_ppg_vif);
end

`define  NIRS_PPG_CTRL_CFG           top_cfg.nirs_ppg_cfg
`define  NIRS_PPG_IF                 `SOC_TB.nirs_ppg_vif



//check D2A_NIRS_*
//D2A_PDBIAS_ADJ<1:0>
//D2A_PDBIAS_EN
//D2A_NIRS_TEST_EN
//D2A_CLK_NIRS
//D2A_NIRS_CHOPPER_EN
//D2A_NIRS_FCHOP_ADJ<1:0>

always @(posedge `NIRS_PPG_TOP.clk_sys) begin

     //if(!`NIRS_PPG_TOP.rst_n)begin
     //end
     if(`NIRS_PPG_IF.nirs_d2a_spi_adj0_regs_check_en === 1'b1 && `NIRS_PPG_TOP.rst_n === 1'b1 )begin

        if(`ANA_TOP.D2A_PDBIAS_ADJ !== `NIRS_PPG_IF.pdbias_adj)begin
          `nnc_error("NIRS_TB",$sformatf("ERROR!!!! `ANA_TOP.D2A_PDBIAS_ADJ =%0h, `NIRS_PPG_IF.pdbias_adj =%0h\n", `ANA_TOP.D2A_PDBIAS_ADJ, `NIRS_PPG_IF.pdbias_adj))
        end

        if(`ANA_TOP.D2A_PDBIAS_EN !== `NIRS_PPG_IF.pdbias_en)begin
          `nnc_error("NIRS_TB",$sformatf("ERROR!!!! `ANA_TOP.D2A_PDBIAS_EN =%0h, `NIRS_PPG_IF.pdbias_en =%0h\n", `ANA_TOP.D2A_PDBIAS_EN, `NIRS_PPG_IF.pdbias_en))
        end

        if(`ANA_TOP.D2A_NIRS_TEST_EN !== `NIRS_PPG_IF.test_en)begin
          `nnc_error("NIRS_TB",$sformatf("ERROR!!!!  `ANA_TOP.D2A_NIRS_TEST_EN =%0h, `NIRS_PPG_IF.test_en =%0h\n", `ANA_TOP.D2A_NIRS_TEST_EN, `NIRS_PPG_IF.test_en))
        end

        //if(`ANA_TOP.D2A_CLK_NIRS !== )begin
        //end
        if(`ANA_TOP.D2A_NIRS_CHOPPER_EN !== `NIRS_PPG_IF.chopper_en)begin
          `nnc_error("NIRS_TB",$sformatf("ERROR!!!! `ANA_TOP.D2A_NIRS_CHOPPER_EN =%0h, `NIRS_PPG_IF.chopper_en =%0h\n", `ANA_TOP.D2A_NIRS_CHOPPER_EN, `NIRS_PPG_IF.chopper_en))
        end

        if(`ANA_TOP.D2A_NIRS_FCHOP_ADJ !== `NIRS_PPG_IF.fchop_adj)begin
          `nnc_error("NIRS_TB",$sformatf("ERROR!!!! `ANA_TOP.D2A_NIRS_FCHOP_ADJ =%0h, `NIRS_PPG_IF.fchop_adj =%0h\n", `ANA_TOP.D2A_NIRS_FCHOP_ADJ, `NIRS_PPG_IF.fchop_adj))
        end        
      end
end

//D2A_NIRS*_IDAC_EN
//D2A_NIRS*_IPDMIRROR_ADJ<1:0>
//D2A_NIRS*_IREFC_ADJ<1:0>
//D2A_NIRS*_CFRATE_ADJ<1:0> 
//D2A_ NIRS*_IDAC_ADJ<8:0>
/*genvar ch;
generate
  for (ch = 0; ch < 8; ch++) begin
    always @(posedge `NIRS_PPG_TOP.clk_sys or negedge `NIRS_PPG_TOP.rst_n) begin
      if (`NIRS_PPG_IF.nirs_8ch_d2a_spi_adj_regs_check_en === 1'b1 && `NIRS_PPG_TOP.rst_n === 1'b1)begin
         if(d2a_nirs_ipdmirror_adj_bus !== `NIRS_PPG_IF.nirs_ppg_cfg_array[0][0].ipdmirror_ratio_adj)begin
         end
         if(d2a_nirs_irefc_adj_bus !== `NIRS_PPG_IF.nirs_ppg_cfg_array[0][0].iref_ratio_adj)begin
         end
         if(d2a_nirs_cfrate_adj_bus !== `NIRS_PPG_IF.nirs_ppg_cfg_array[0][0].ratio_ctrl)begin
         end
         //if(d2a_nirs_idac_adj_bus !== `NIRS_PPG_IF.nirs_ppg_cfg_array[0][0].)begin
         //end
         if(d2a_nirs_idac_en_bus !== `NIRS_PPG_IF.nirs_ppg_cfg_array[0][0].idac_en)begin
         end
      end
  end
endgenerate*/

//for below assertion added in NIRS INTERFACE
//D2A_ NIRS*_EN
//D2A_NIRS*_RESET_SW
//D2A_NIRS*_IPD_SW
//D2A_NIRS*_IIN_SW
//A2D_NIRS*_IREFCOARSE
//A2D_NIRS*_IREFCOARSE
    
//initial begin
//    nirs_ppg_vif.cfg = top_cfg.nirs_ppg_cfg; //`NIRS_PPG_CTRL_CFG;   // pass config handle
//end

