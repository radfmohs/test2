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
`define TEMP_NIRS0_LED_VAR `NIR0.u_nirs_pulse_ctrl.LED[1:0]
`define TEMP_NIRS1_LED_VAR `NIR1.u_nirs_pulse_ctrl.LED[1:0]
`define TEMP_NIRS2_LED_VAR `NIR2.u_nirs_pulse_ctrl.LED[1:0]
`define TEMP_NIRS3_LED_VAR `NIR3.u_nirs_pulse_ctrl.LED[1:0]
`define TEMP_NIRS4_LED_VAR `NIR4.u_nirs_pulse_ctrl.LED[1:0]
`define TEMP_NIRS5_LED_VAR `NIR5.u_nirs_pulse_ctrl.LED[1:0]
`define TEMP_NIRS6_LED_VAR `NIR6.u_nirs_pulse_ctrl.LED[1:0]
`define TEMP_NIRS7_LED_VAR `NIR7.u_nirs_pulse_ctrl.LED[1:0]
/*
`ifdef BEHAVIORAL
  `define TEMP_NIRS0_LED_VAR `NIR0.u_nirs_pulse_ctrl.LED[1:0]
`else
  `define TEMP_NIRS0_LED_VAR {`NIR0.u_nirs_pulse_ctrl.LED_1__BAR, `NIR0.u_nirs_pulse_ctrl.LED_0_}
`endif
*/
`define  NIRS_PPG_CTRL_CFG           top_cfg.nirs_ppg_cfg
`define  NIRS_PPG_IF                 `SOC_TB.nirs_ppg_vif

nnc_nirs_ppg_interface nirs_ppg_vif();

assign  nirs_ppg_vif.nirs_ppg_rst               =  `NIRS_PPG_TOP.rst_n;
assign  nirs_ppg_vif.ens2_sys_clk               =  `NIRS_PPG_TOP.clk_sys;
assign  nirs_ppg_vif.nirs_ppg_clk               =  `NIRS_PPG_TOP.clk_ppg;
//
assign  nirs_ppg_vif.D2A_PDBIAS_ADJ             =  `ANA_TOP.D2A_PDBIAS_ADJ; 
assign  nirs_ppg_vif.D2A_PDBIAS_EN              =  `ANA_TOP.D2A_PDBIAS_EN;
////
//wire   [7:0]  d2a_nirs_en_bus;
//wire   [7:0]  d2a_nirs_idac_en_bus;
//wire [7:0]  d2a_nirs_reset_sw_bus;
//wire [7:0]  d2a_nirs_ipd_sw_bus;
//wire [7:0]  d2a_nirs_iin_sw_bus;
//wire [7:0]  d2a_nirs_ipdmirror_adj_bus;
//wire [7:0]  d2a_nirs_irefc_adj_bus;
//wire [7:0]  d2a_nirs_cfrate_adj_bus;
//wire [7:0]  d2a_nirs_idac_adj_bus;
//wire [7:0]  a2nd_nirs_irefcoarse_bus;
//wire [7:0]  a2d_nirs_ireffine_bus;

//
assign nirs_ppg_vif.d2a_nirs_en_bus      = {`ANA_TOP.D2A_NIRS7_EN,`ANA_TOP.D2A_NIRS6_EN,`ANA_TOP.D2A_NIRS5_EN,`ANA_TOP.D2A_NIRS4_EN,
                                     `ANA_TOP.D2A_NIRS3_EN,`ANA_TOP.D2A_NIRS2_EN,`ANA_TOP.D2A_NIRS1_EN,`ANA_TOP.D2A_NIRS0_EN};
//
assign nirs_ppg_vif.d2a_nirs_idac_en_bus =  {`ANA_TOP.D2A_NIRS7_IDAC_EN, `ANA_TOP.D2A_NIRS6_IDAC_EN,`ANA_TOP.D2A_NIRS5_IDAC_EN,`ANA_TOP.D2A_NIRS4_IDAC_EN,
                                      `ANA_TOP.D2A_NIRS3_IDAC_EN,`ANA_TOP.D2A_NIRS2_IDAC_EN,`ANA_TOP.D2A_NIRS1_IDAC_EN,`ANA_TOP.D2A_NIRS0_IDAC_EN};
//
assign  nirs_ppg_vif.D2A_NIRS_TEST_EN           =  `ANA_TOP.D2A_NIRS_TEST_EN;
//
assign nirs_ppg_vif.d2a_nirs_reset_sw_bus  = {`ANA_TOP.D2A_NIRS7_RESET_SW, `ANA_TOP.D2A_NIRS6_RESET_SW, `ANA_TOP.D2A_NIRS5_RESET_SW, `ANA_TOP.D2A_NIRS4_RESET_SW,
                                     `ANA_TOP.D2A_NIRS3_RESET_SW, `ANA_TOP.D2A_NIRS2_RESET_SW, `ANA_TOP.D2A_NIRS1_RESET_SW, `ANA_TOP.D2A_NIRS0_RESET_SW };
//  
assign nirs_ppg_vif.d2a_nirs_ipd_sw_bus    = {`ANA_TOP.D2A_NIRS7_IPD_SW, `ANA_TOP.D2A_NIRS6_IPD_SW, `ANA_TOP.D2A_NIRS5_IPD_SW, `ANA_TOP.D2A_NIRS4_IPD_SW,
                                     `ANA_TOP.D2A_NIRS3_IPD_SW, `ANA_TOP.D2A_NIRS2_IPD_SW, `ANA_TOP.D2A_NIRS1_IPD_SW, `ANA_TOP.D2A_NIRS0_IPD_SW };
//
assign nirs_ppg_vif.d2a_nirs_iin_sw_bus   = {`ANA_TOP.D2A_NIRS7_IIN_SW, `ANA_TOP.D2A_NIRS6_IIN_SW, `ANA_TOP.D2A_NIRS5_IIN_SW,  `ANA_TOP.D2A_NIRS4_IIN_SW,
                                    `ANA_TOP.D2A_NIRS3_IIN_SW, `ANA_TOP.D2A_NIRS2_IIN_SW, `ANA_TOP.D2A_NIRS1_IIN_SW,  `ANA_TOP.D2A_NIRS0_IIN_SW}; 
//
assign nirs_ppg_vif.d2a_nirs_ipdmirror_adj_bus  = {`ANA_TOP.D2A_NIRS7_IPDMIRROR_ADJ, `ANA_TOP.D2A_NIRS6_IPDMIRROR_ADJ, `ANA_TOP.D2A_NIRS5_IPDMIRROR_ADJ, `ANA_TOP.D2A_NIRS4_IPDMIRROR_ADJ,
                                          `ANA_TOP.D2A_NIRS3_IPDMIRROR_ADJ, `ANA_TOP.D2A_NIRS2_IPDMIRROR_ADJ, `ANA_TOP.D2A_NIRS1_IPDMIRROR_ADJ, `ANA_TOP.D2A_NIRS0_IPDMIRROR_ADJ };
//
assign nirs_ppg_vif.d2a_nirs_irefc_adj_bus      = {`ANA_TOP.D2A_NIRS7_IREFC_ADJ, `ANA_TOP.D2A_NIRS6_IREFC_ADJ, `ANA_TOP.D2A_NIRS5_IREFC_ADJ, `ANA_TOP.D2A_NIRS4_IREFC_ADJ,
                                          `ANA_TOP.D2A_NIRS3_IREFC_ADJ, `ANA_TOP.D2A_NIRS2_IREFC_ADJ, `ANA_TOP.D2A_NIRS1_IREFC_ADJ, `ANA_TOP.D2A_NIRS0_IREFC_ADJ };
//
assign nirs_ppg_vif.d2a_nirs_cfrate_adj_bus     = {`ANA_TOP.D2A_NIRS7_CFRATE_ADJ, `ANA_TOP.D2A_NIRS6_CFRATE_ADJ, `ANA_TOP.D2A_NIRS5_CFRATE_ADJ, `ANA_TOP.D2A_NIRS4_CFRATE_ADJ,
                                          `ANA_TOP.D2A_NIRS3_CFRATE_ADJ, `ANA_TOP.D2A_NIRS2_CFRATE_ADJ, `ANA_TOP.D2A_NIRS1_CFRATE_ADJ, `ANA_TOP.D2A_NIRS0_CFRATE_ADJ };
//
assign nirs_ppg_vif.d2a_nirs_idac_adj_bus       = {`ANA_TOP.D2A_NIRS7_IDAC_ADJ, `ANA_TOP.D2A_NIRS6_IDAC_ADJ, `ANA_TOP.D2A_NIRS5_IDAC_ADJ, `ANA_TOP.D2A_NIRS4_IDAC_ADJ,
                                          `ANA_TOP.D2A_NIRS3_IDAC_ADJ, `ANA_TOP.D2A_NIRS2_IDAC_ADJ, `ANA_TOP.D2A_NIRS1_IDAC_ADJ, `ANA_TOP.D2A_NIRS0_IDAC_ADJ };
//
assign nirs_ppg_vif.a2d_nirs_irefcoarse_bus    = {`ANA_TOP.A2D_NIRS7_IREFCOARSE, `ANA_TOP.A2D_NIRS6_IREFCOARSE, `ANA_TOP.A2D_NIRS5_IREFCOARSE, `ANA_TOP.A2D_NIRS4_IREFCOARSE,                                                                                                         `ANA_TOP.A2D_NIRS3_IREFCOARSE, `ANA_TOP.A2D_NIRS2_IREFCOARSE, `ANA_TOP.A2D_NIRS1_IREFCOARSE, `ANA_TOP.A2D_NIRS0_IREFCOARSE };
//
assign nirs_ppg_vif.a2d_nirs_ireffine_bus       = {`ANA_TOP.A2D_NIRS7_IREFFINE, `ANA_TOP.A2D_NIRS6_IREFFINE, `ANA_TOP.A2D_NIRS5_IREFFINE, `ANA_TOP.A2D_NIRS4_IREFFINE,
                                          `ANA_TOP.A2D_NIRS3_IREFFINE, `ANA_TOP.A2D_NIRS2_IREFFINE, `ANA_TOP.A2D_NIRS1_IREFFINE, `ANA_TOP.A2D_NIRS0_IREFFINE };

//
//always_comb begin
genvar i;
generate
  for (i = 0; i < 8; i++) begin
  //for(int i=0; i<8; i++)begin
    always @(posedge `NIRS_PPG_TOP.clk_sys)begin
      nirs_ppg_vif.D2A_NIRS_EN[i]                <=  nirs_ppg_vif.d2a_nirs_en_bus[i];
      nirs_ppg_vif.D2A_NIRS_IDAC_EN[i]           <=  nirs_ppg_vif.d2a_nirs_idac_en_bus[i] ;
      nirs_ppg_vif.D2A_NIRS_RESET_SW[i]          <=  nirs_ppg_vif.d2a_nirs_reset_sw_bus[i];
      nirs_ppg_vif.D2A_NIRS_IPD_SW[i]            <=  nirs_ppg_vif.d2a_nirs_ipd_sw_bus[i];
      nirs_ppg_vif.D2A_NIRS_IIN_SW[i]            <=  nirs_ppg_vif.d2a_nirs_iin_sw_bus[i];
      nirs_ppg_vif.D2A_NIRS_IPDMIRROR_ADJ[i]     <=  nirs_ppg_vif.d2a_nirs_ipdmirror_adj_bus[i];
      nirs_ppg_vif.D2A_NIRS_IREFC_ADJ[i]         <=  nirs_ppg_vif.d2a_nirs_irefc_adj_bus[i];
      nirs_ppg_vif.D2A_NIRS_CFRATE_ADJ[i]        <=  nirs_ppg_vif.d2a_nirs_cfrate_adj_bus[i];
      nirs_ppg_vif.D2A_NIRS_IDAC_ADJ[i]          <=  nirs_ppg_vif.d2a_nirs_idac_adj_bus[i];
      //nirs_ppg_vif.A2D_NIRS_IREFCOARSE[i]        <= a2d_nirs_irefcoarse_bus[i]; // not used
      //nirs_ppg_vif.A2D_NIRS_IREFFINE[i]          <= a2d_nirs_ireffine_bus[i];    // not used
    end
  end
endgenerate

 
assign  nirs_ppg_vif.D2A_CLK_NIRS               =  `ANA_TOP.D2A_CLK_NIRS;

assign  nirs_ppg_vif.D2A_NIRS_CHOPPER_EN        =  `ANA_TOP.D2A_NIRS_CHOPPER_EN;

assign  nirs_ppg_vif.D2A_NIRS_FCHOP_ADJ         =  `ANA_TOP.D2A_NIRS_FCHOP_ADJ;
    
wire [7:0] nirs_enable;
wire [7:0] nirs_meas;

assign nirs_enable = {
  `NIR7.u_nirs_pulse_ctrl.NIRS_EN,
  `NIR6.u_nirs_pulse_ctrl.NIRS_EN,
  `NIR5.u_nirs_pulse_ctrl.NIRS_EN,
  `NIR4.u_nirs_pulse_ctrl.NIRS_EN,
  `NIR3.u_nirs_pulse_ctrl.NIRS_EN,
  `NIR2.u_nirs_pulse_ctrl.NIRS_EN,
  `NIR1.u_nirs_pulse_ctrl.NIRS_EN,
  `NIR0.u_nirs_pulse_ctrl.NIRS_EN
};
assign nirs_meas = {
  `NIR7.u_nirs_pulse_ctrl.NIRS_MEAS,
  `NIR6.u_nirs_pulse_ctrl.NIRS_MEAS,
  `NIR5.u_nirs_pulse_ctrl.NIRS_MEAS,
  `NIR4.u_nirs_pulse_ctrl.NIRS_MEAS,
  `NIR3.u_nirs_pulse_ctrl.NIRS_MEAS,
  `NIR2.u_nirs_pulse_ctrl.NIRS_MEAS,
  `NIR1.u_nirs_pulse_ctrl.NIRS_MEAS,
  `NIR0.u_nirs_pulse_ctrl.NIRS_MEAS
};

//
genvar i;
generate
  for (i = 0; i < 8; i++) begin
    always @(*)begin //posedge `NIRS_PPG_TOP.clk_sys or negedge `NIRS_PPG_TOP.rst_n) begin
      if (!`NIRS_PPG_TOP.rst_n)begin
        nirs_ppg_vif.nirs_ppg_en[i] <= 1'b0;
        nirs_ppg_vif.nirs_ppg_meas[i] <= 1'b0;
        //nirs_ppg_vif.nirs_int_io[i]   <= 1'b0;
      end
      else begin
        // constant hierarchical reference per instance (macro expands to the path)
        nirs_ppg_vif.nirs_ppg_en[i]  <= nirs_enable[i];
        nirs_ppg_vif.nirs_ppg_meas[i] <= nirs_meas[i];
        //nirs_ppg_vif.nirs_int_io[i]   <= `NIRS_PPG_TOP.u_nirs_ctrl_top[i].u_nirs_ppg_int.INT_IO;
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

        if(`ANA_TOP.D2A_NIRS_POWER_EN !== `NIRS_PPG_IF.d2a_nirs_power_en)begin
          `nnc_error("NIRS_TB",$sformatf("ERROR!!!! `ANA_TOP.D2A_NIRS_POWER_EN =%0h, `NIRS_PPG_IF.d2a_nirs_power_en =%0h\n", `ANA_TOP.D2A_NIRS_POWER_EN, `NIRS_PPG_IF.d2a_nirs_power_en))
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

// INTERRUPT PIN checking
assign nirs_ppg_vif.nirs_int_io[0]   = `NIR0.u_nirs_ppg_int.INT_IO;
assign nirs_ppg_vif.nirs_int_io[1]   = `NIR1.u_nirs_ppg_int.INT_IO;
assign nirs_ppg_vif.nirs_int_io[2]   = `NIR2.u_nirs_ppg_int.INT_IO;
assign nirs_ppg_vif.nirs_int_io[3]   = `NIR3.u_nirs_ppg_int.INT_IO;
assign nirs_ppg_vif.nirs_int_io[4]   = `NIR4.u_nirs_ppg_int.INT_IO;
assign nirs_ppg_vif.nirs_int_io[5]   = `NIR5.u_nirs_ppg_int.INT_IO;
assign nirs_ppg_vif.nirs_int_io[6]   = `NIR6.u_nirs_ppg_int.INT_IO;
assign nirs_ppg_vif.nirs_int_io[7]   = `NIR7.u_nirs_ppg_int.INT_IO;

//checker to check NIRS INT for each channel is one clock
genvar g_int;
generate
  for (g_int=0; g_int<8; g_int++) begin : INT_ASSERT

    property int_pulse_width_check;
      @(posedge `CLK_CTRL_TOP.clk_ppg)
      disable iff (!`NIRS_PPG_TOP.rst_n || !nirs_ppg_vif.nirs_int_pin_en)

      ((nirs_ppg_vif.gen_reg_int_active_level && nirs_ppg_vif.gen_reg_int_length_sel &&
         $rose(nirs_ppg_vif.nirs_int_io[g_int]))
        ||
        (!nirs_ppg_vif.gen_reg_int_active_level && nirs_ppg_vif.gen_reg_int_length_sel &&
         $fell(nirs_ppg_vif.nirs_int_io[g_int]))
      )
      |=> (nirs_ppg_vif.nirs_int_io[g_int]
           == 0);

    endproperty

    assert property (int_pulse_width_check) `nnc_info("SVA INT_IO", $sformatf("INT_IO pulse detected!!![%0d]",g_int), UVM_LOW)
      else
        `uvm_error("NIRS_INT",$sformatf("SVA INT_IO pulse width ERROR!!! channel %0d", g_int));

  end
endgenerate  

//check connectivity  
bit exp_int_pin;
bit wire_int_pin;
//assign     exp_int_pin =
//                   (`NIR0.u_nirs_ppg_int.INT_IO |
//                   `NIR1.u_nirs_ppg_int.INT_IO |
//                   `NIR2.u_nirs_ppg_int.INT_IO |
//                   `NIR3.u_nirs_ppg_int.INT_IO |
//                   `NIR4.u_nirs_ppg_int.INT_IO |
//                   `NIR5.u_nirs_ppg_int.INT_IO |
//                   `NIR6.u_nirs_ppg_int.INT_IO |
//                   `NIR7.u_nirs_ppg_int.INT_IO);

assign wire_int_pin =  nirs_ppg_vif.nirs_int_pin_en ? (`NIR0.u_nirs_ppg_int.INT_IO | `NIR1.u_nirs_ppg_int.INT_IO |
                        `NIR2.u_nirs_ppg_int.INT_IO |`NIR3.u_nirs_ppg_int.INT_IO |
                        `NIR4.u_nirs_ppg_int.INT_IO |`NIR5.u_nirs_ppg_int.INT_IO |
                        `NIR6.u_nirs_ppg_int.INT_IO |`NIR7.u_nirs_ppg_int.INT_IO) : 1'b0;

assign exp_int_pin = nirs_ppg_vif.gen_reg_int_active_level ? wire_int_pin : ~wire_int_pin;

always @(posedge nirs_ppg_vif.nirs_ppg_clk ) begin

  if(nirs_ppg_vif.nirs_ppg_rst && nirs_ppg_vif.nirs_int_io_checker_en)begin  
    //if (nirs_ppg_vif.nirs_int_pin_en) begin
       if (`SOC_TOP.IOBUF_PAD[11] !== exp_int_pin) begin
             `nnc_error("NIRS_INT",$sformatf("INT pin connectivity error!!! Expected=%0b Actual=%0b",exp_int_pin,`SOC_TOP.IOBUF_PAD[11]))
       end
    //end
    //else begin
    //   if (`SOC_TOP.IOBUF_PAD[11] !== exp_int_pin) begin
    //         `nnc_error("NIRS_INT",$sformatf("INT pin connectivity error!!! nirs_ppg_vif.nirs_int_pin_en =%0b(==0 don't output INT to pin) IOBUF_PAD[11]=%0b",nirs_ppg_vif.nirs_int_pin_en, `SOC_TOP.IOBUF_PAD[11]))
    //   end
    //end
  end
end

//NIRS IDAC DATA DATA CHECK
assign nirs_ppg_vif.counters_clear[0] =  `NIR0.u_nirs_ctrl.COUNTERS_CLEAR;
assign nirs_ppg_vif.counters_clear[1] =  `NIR1.u_nirs_ctrl.COUNTERS_CLEAR;
assign nirs_ppg_vif.counters_clear[2] =  `NIR2.u_nirs_ctrl.COUNTERS_CLEAR;
assign nirs_ppg_vif.counters_clear[3] =  `NIR3.u_nirs_ctrl.COUNTERS_CLEAR;
assign nirs_ppg_vif.counters_clear[4] =  `NIR4.u_nirs_ctrl.COUNTERS_CLEAR;
assign nirs_ppg_vif.counters_clear[5] =  `NIR5.u_nirs_ctrl.COUNTERS_CLEAR;
assign nirs_ppg_vif.counters_clear[6] =  `NIR6.u_nirs_ctrl.COUNTERS_CLEAR;
assign nirs_ppg_vif.counters_clear[7] =  `NIR7.u_nirs_ctrl.COUNTERS_CLEAR;
assign nirs_ppg_vif.final_doutq_c_latch_en[0]  =  `NIR0.u_nirs_ctrl.DOUTF_LATCH_EN;
assign nirs_ppg_vif.final_doutq_c_latch_en[1]  =  `NIR1.u_nirs_ctrl.DOUTF_LATCH_EN;
assign nirs_ppg_vif.final_doutq_c_latch_en[2]  =  `NIR2.u_nirs_ctrl.DOUTF_LATCH_EN;
assign nirs_ppg_vif.final_doutq_c_latch_en[3]  =  `NIR3.u_nirs_ctrl.DOUTF_LATCH_EN;
assign nirs_ppg_vif.final_doutq_c_latch_en[4]  =  `NIR4.u_nirs_ctrl.DOUTF_LATCH_EN;
assign nirs_ppg_vif.final_doutq_c_latch_en[5]  =  `NIR5.u_nirs_ctrl.DOUTF_LATCH_EN;
assign nirs_ppg_vif.final_doutq_c_latch_en[6]  =  `NIR6.u_nirs_ctrl.DOUTF_LATCH_EN;
assign nirs_ppg_vif.final_doutq_c_latch_en[7]  =  `NIR7.u_nirs_ctrl.DOUTF_LATCH_EN;
//`ifdef BEHAVIORAL
assign nirs_ppg_vif.dout_led0_en[0]            = `TEMP_NIRS0_LED_VAR == 2'b00 ? `NIR0.u_nirs_ctrl.DOUT_EN : 1'b0;
assign nirs_ppg_vif.dout_led0_en[1]            = `TEMP_NIRS1_LED_VAR == 2'b00 ? `NIR1.u_nirs_ctrl.DOUT_EN : 1'b0;
assign nirs_ppg_vif.dout_led0_en[2]            = `TEMP_NIRS2_LED_VAR == 2'b00 ? `NIR2.u_nirs_ctrl.DOUT_EN : 1'b0;
assign nirs_ppg_vif.dout_led0_en[3]            = `TEMP_NIRS3_LED_VAR == 2'b00 ? `NIR3.u_nirs_ctrl.DOUT_EN : 1'b0;
assign nirs_ppg_vif.dout_led0_en[4]            = `TEMP_NIRS4_LED_VAR == 2'b00 ? `NIR4.u_nirs_ctrl.DOUT_EN : 1'b0;
assign nirs_ppg_vif.dout_led0_en[5]            = `TEMP_NIRS5_LED_VAR == 2'b00 ? `NIR5.u_nirs_ctrl.DOUT_EN : 1'b0;
assign nirs_ppg_vif.dout_led0_en[6]            = `TEMP_NIRS6_LED_VAR == 2'b00 ? `NIR6.u_nirs_ctrl.DOUT_EN : 1'b0;
assign nirs_ppg_vif.dout_led0_en[7]            = `TEMP_NIRS7_LED_VAR == 2'b00 ? `NIR7.u_nirs_ctrl.DOUT_EN : 1'b0;
//
assign nirs_ppg_vif.dout_amb0_en[0]            = `TEMP_NIRS0_LED_VAR == 2'b01 ? `NIR0.u_nirs_ctrl.DOUT_EN : 1'b0;
assign nirs_ppg_vif.dout_amb0_en[1]            = `TEMP_NIRS1_LED_VAR == 2'b01 ? `NIR1.u_nirs_ctrl.DOUT_EN : 1'b0;
assign nirs_ppg_vif.dout_amb0_en[2]            = `TEMP_NIRS2_LED_VAR == 2'b01 ? `NIR2.u_nirs_ctrl.DOUT_EN : 1'b0;
assign nirs_ppg_vif.dout_amb0_en[3]            = `TEMP_NIRS3_LED_VAR == 2'b01 ? `NIR3.u_nirs_ctrl.DOUT_EN : 1'b0;
assign nirs_ppg_vif.dout_amb0_en[4]            = `TEMP_NIRS4_LED_VAR == 2'b01 ? `NIR4.u_nirs_ctrl.DOUT_EN : 1'b0;
assign nirs_ppg_vif.dout_amb0_en[5]            = `TEMP_NIRS5_LED_VAR == 2'b01 ? `NIR5.u_nirs_ctrl.DOUT_EN : 1'b0;
assign nirs_ppg_vif.dout_amb0_en[6]            = `TEMP_NIRS6_LED_VAR == 2'b01 ? `NIR6.u_nirs_ctrl.DOUT_EN : 1'b0;
assign nirs_ppg_vif.dout_amb0_en[7]            = `TEMP_NIRS7_LED_VAR == 2'b01 ? `NIR7.u_nirs_ctrl.DOUT_EN : 1'b0;
//
assign nirs_ppg_vif.dout_led1_en[0]            = `TEMP_NIRS0_LED_VAR == 2'b10 ? `NIR0.u_nirs_ctrl.DOUT_EN : 1'b0;
assign nirs_ppg_vif.dout_led1_en[1]            = `TEMP_NIRS1_LED_VAR == 2'b10 ? `NIR1.u_nirs_ctrl.DOUT_EN : 1'b0;
assign nirs_ppg_vif.dout_led1_en[2]            = `TEMP_NIRS2_LED_VAR == 2'b10 ? `NIR2.u_nirs_ctrl.DOUT_EN : 1'b0;
assign nirs_ppg_vif.dout_led1_en[3]            = `TEMP_NIRS3_LED_VAR == 2'b10 ? `NIR3.u_nirs_ctrl.DOUT_EN : 1'b0;
assign nirs_ppg_vif.dout_led1_en[4]            = `TEMP_NIRS4_LED_VAR == 2'b10 ? `NIR4.u_nirs_ctrl.DOUT_EN : 1'b0;
assign nirs_ppg_vif.dout_led1_en[5]            = `TEMP_NIRS5_LED_VAR == 2'b10 ? `NIR5.u_nirs_ctrl.DOUT_EN : 1'b0;
assign nirs_ppg_vif.dout_led1_en[6]            = `TEMP_NIRS6_LED_VAR == 2'b10 ? `NIR6.u_nirs_ctrl.DOUT_EN : 1'b0;
assign nirs_ppg_vif.dout_led1_en[7]            = `TEMP_NIRS7_LED_VAR == 2'b10 ? `NIR7.u_nirs_ctrl.DOUT_EN : 1'b0;
//
assign nirs_ppg_vif.dout_amb1_en[0]            = `TEMP_NIRS0_LED_VAR == 2'b11 ? `NIR0.u_nirs_ctrl.DOUT_EN : 1'b0;
assign nirs_ppg_vif.dout_amb1_en[1]            = `TEMP_NIRS1_LED_VAR == 2'b11 ? `NIR1.u_nirs_ctrl.DOUT_EN : 1'b0;
assign nirs_ppg_vif.dout_amb1_en[2]            = `TEMP_NIRS2_LED_VAR == 2'b11 ? `NIR2.u_nirs_ctrl.DOUT_EN : 1'b0;
assign nirs_ppg_vif.dout_amb1_en[3]            = `TEMP_NIRS3_LED_VAR == 2'b11 ? `NIR3.u_nirs_ctrl.DOUT_EN : 1'b0;
assign nirs_ppg_vif.dout_amb1_en[4]            = `TEMP_NIRS4_LED_VAR == 2'b11 ? `NIR4.u_nirs_ctrl.DOUT_EN : 1'b0;
assign nirs_ppg_vif.dout_amb1_en[5]            = `TEMP_NIRS5_LED_VAR == 2'b11 ? `NIR5.u_nirs_ctrl.DOUT_EN : 1'b0;
assign nirs_ppg_vif.dout_amb1_en[6]            = `TEMP_NIRS6_LED_VAR == 2'b11 ? `NIR6.u_nirs_ctrl.DOUT_EN : 1'b0;
assign nirs_ppg_vif.dout_amb1_en[7]            = `TEMP_NIRS7_LED_VAR == 2'b11 ? `NIR7.u_nirs_ctrl.DOUT_EN : 1'b0;
//
//
assign nirs_ppg_vif.idac_led0_en[0] = ((`NIR0.u_nirs_ctrl.IDAC_UPDATE_EN == 1'b1) && (`TEMP_NIRS0_LED_VAR == 2'b00) && nirs_ppg_vif.nirs_ppg_cfg_array[0][0].idac_en); //from testcase only array[0] used fro all channels
assign nirs_ppg_vif.idac_led0_en[1] = ((`NIR1.u_nirs_ctrl.IDAC_UPDATE_EN == 1'b1) && (`TEMP_NIRS1_LED_VAR == 2'b00) && nirs_ppg_vif.nirs_ppg_cfg_array[0][0].idac_en);
assign nirs_ppg_vif.idac_led0_en[2] = ((`NIR2.u_nirs_ctrl.IDAC_UPDATE_EN == 1'b1) && (`TEMP_NIRS2_LED_VAR == 2'b00) && nirs_ppg_vif.nirs_ppg_cfg_array[0][0].idac_en);
assign nirs_ppg_vif.idac_led0_en[3] = ((`NIR3.u_nirs_ctrl.IDAC_UPDATE_EN == 1'b1) && (`TEMP_NIRS3_LED_VAR == 2'b00) && nirs_ppg_vif.nirs_ppg_cfg_array[0][0].idac_en);
assign nirs_ppg_vif.idac_led0_en[4] = ((`NIR4.u_nirs_ctrl.IDAC_UPDATE_EN == 1'b1) && (`TEMP_NIRS4_LED_VAR == 2'b00) && nirs_ppg_vif.nirs_ppg_cfg_array[0][0].idac_en);
assign nirs_ppg_vif.idac_led0_en[5] = ((`NIR5.u_nirs_ctrl.IDAC_UPDATE_EN == 1'b1) && (`TEMP_NIRS5_LED_VAR == 2'b00) && nirs_ppg_vif.nirs_ppg_cfg_array[0][0].idac_en);
assign nirs_ppg_vif.idac_led0_en[6] = ((`NIR6.u_nirs_ctrl.IDAC_UPDATE_EN == 1'b1) && (`TEMP_NIRS6_LED_VAR == 2'b00) && nirs_ppg_vif.nirs_ppg_cfg_array[0][0].idac_en);
assign nirs_ppg_vif.idac_led0_en[7] = ((`NIR7.u_nirs_ctrl.IDAC_UPDATE_EN == 1'b1) && (`TEMP_NIRS7_LED_VAR == 2'b00) && nirs_ppg_vif.nirs_ppg_cfg_array[0][0].idac_en);

assign nirs_ppg_vif.idac_led1_en[0] = ((`NIR0.u_nirs_ctrl.IDAC_UPDATE_EN == 1'b1) && (`TEMP_NIRS0_LED_VAR == 2'b10) && nirs_ppg_vif.nirs_ppg_cfg_array[0][1].idac_en); //from testcase only array[0] used fro all channels
assign nirs_ppg_vif.idac_led1_en[1] = ((`NIR1.u_nirs_ctrl.IDAC_UPDATE_EN == 1'b1) && (`TEMP_NIRS1_LED_VAR == 2'b10) && nirs_ppg_vif.nirs_ppg_cfg_array[0][1].idac_en);
assign nirs_ppg_vif.idac_led1_en[2] = ((`NIR2.u_nirs_ctrl.IDAC_UPDATE_EN == 1'b1) && (`TEMP_NIRS2_LED_VAR == 2'b10) && nirs_ppg_vif.nirs_ppg_cfg_array[0][1].idac_en);
assign nirs_ppg_vif.idac_led1_en[3] = ((`NIR3.u_nirs_ctrl.IDAC_UPDATE_EN == 1'b1) && (`TEMP_NIRS3_LED_VAR == 2'b10) && nirs_ppg_vif.nirs_ppg_cfg_array[0][1].idac_en);
assign nirs_ppg_vif.idac_led1_en[4] = ((`NIR4.u_nirs_ctrl.IDAC_UPDATE_EN == 1'b1) && (`TEMP_NIRS4_LED_VAR == 2'b10) && nirs_ppg_vif.nirs_ppg_cfg_array[0][1].idac_en);
assign nirs_ppg_vif.idac_led1_en[5] = ((`NIR5.u_nirs_ctrl.IDAC_UPDATE_EN == 1'b1) && (`TEMP_NIRS5_LED_VAR == 2'b10) && nirs_ppg_vif.nirs_ppg_cfg_array[0][1].idac_en);
assign nirs_ppg_vif.idac_led1_en[6] = ((`NIR6.u_nirs_ctrl.IDAC_UPDATE_EN == 1'b1) && (`TEMP_NIRS6_LED_VAR == 2'b10) && nirs_ppg_vif.nirs_ppg_cfg_array[0][1].idac_en);
assign nirs_ppg_vif.idac_led1_en[7] = ((`NIR7.u_nirs_ctrl.IDAC_UPDATE_EN == 1'b1) && (`TEMP_NIRS7_LED_VAR == 2'b10) && nirs_ppg_vif.nirs_ppg_cfg_array[0][1].idac_en);

assign nirs_ppg_vif.idac_increas_en[0] = `NIR0.u_nirs_ctrl.IDAC_INCREASE;
assign nirs_ppg_vif.idac_increas_en[1] = `NIR1.u_nirs_ctrl.IDAC_INCREASE;
assign nirs_ppg_vif.idac_increas_en[2] = `NIR2.u_nirs_ctrl.IDAC_INCREASE;
assign nirs_ppg_vif.idac_increas_en[3] = `NIR3.u_nirs_ctrl.IDAC_INCREASE;
assign nirs_ppg_vif.idac_increas_en[4] = `NIR4.u_nirs_ctrl.IDAC_INCREASE;
assign nirs_ppg_vif.idac_increas_en[5] = `NIR5.u_nirs_ctrl.IDAC_INCREASE;
assign nirs_ppg_vif.idac_increas_en[6] = `NIR6.u_nirs_ctrl.IDAC_INCREASE;
//
assign nirs_ppg_vif.dout_reg_en[0] = `NIR0.u_nirs_ctrl.DOUT_EN;
assign nirs_ppg_vif.dout_reg_en[1] = `NIR1.u_nirs_ctrl.DOUT_EN;
assign nirs_ppg_vif.dout_reg_en[2] = `NIR2.u_nirs_ctrl.DOUT_EN;
assign nirs_ppg_vif.dout_reg_en[3] = `NIR3.u_nirs_ctrl.DOUT_EN;
assign nirs_ppg_vif.dout_reg_en[4] = `NIR4.u_nirs_ctrl.DOUT_EN;
assign nirs_ppg_vif.dout_reg_en[5] = `NIR5.u_nirs_ctrl.DOUT_EN;
assign nirs_ppg_vif.dout_reg_en[6] = `NIR6.u_nirs_ctrl.DOUT_EN;
assign nirs_ppg_vif.dout_reg_en[7] = `NIR7.u_nirs_ctrl.DOUT_EN;
//
assign nirs_ppg_vif.idac_reg_en[0] = `NIR0.u_nirs_ctrl.IDAC_UPDATE_EN;
assign nirs_ppg_vif.idac_reg_en[1] = `NIR1.u_nirs_ctrl.IDAC_UPDATE_EN;
assign nirs_ppg_vif.idac_reg_en[2] = `NIR2.u_nirs_ctrl.IDAC_UPDATE_EN;
assign nirs_ppg_vif.idac_reg_en[3] = `NIR3.u_nirs_ctrl.IDAC_UPDATE_EN;
assign nirs_ppg_vif.idac_reg_en[4] = `NIR4.u_nirs_ctrl.IDAC_UPDATE_EN;
assign nirs_ppg_vif.idac_reg_en[5] = `NIR5.u_nirs_ctrl.IDAC_UPDATE_EN;
assign nirs_ppg_vif.idac_reg_en[6] = `NIR6.u_nirs_ctrl.IDAC_UPDATE_EN;
assign nirs_ppg_vif.idac_reg_en[7] = `NIR7.u_nirs_ctrl.IDAC_UPDATE_EN;
//
assign nirs_ppg_vif.led0_en[0] = (`TEMP_NIRS0_LED_VAR == 2'b00);
assign nirs_ppg_vif.led0_en[1] = (`TEMP_NIRS1_LED_VAR == 2'b00);
assign nirs_ppg_vif.led0_en[2] = (`TEMP_NIRS2_LED_VAR == 2'b00);
assign nirs_ppg_vif.led0_en[3] = (`TEMP_NIRS3_LED_VAR == 2'b00);
assign nirs_ppg_vif.led0_en[4] = (`TEMP_NIRS4_LED_VAR == 2'b00);
assign nirs_ppg_vif.led0_en[5] = (`TEMP_NIRS5_LED_VAR == 2'b00);
assign nirs_ppg_vif.led0_en[6] = (`TEMP_NIRS6_LED_VAR == 2'b00);
assign nirs_ppg_vif.led0_en[7] = (`TEMP_NIRS7_LED_VAR == 2'b00);
//
assign nirs_ppg_vif.led1_en[0] = (`TEMP_NIRS0_LED_VAR == 2'b10);
assign nirs_ppg_vif.led1_en[1] = (`TEMP_NIRS1_LED_VAR == 2'b10);
assign nirs_ppg_vif.led1_en[2] = (`TEMP_NIRS2_LED_VAR == 2'b10);
assign nirs_ppg_vif.led1_en[3] = (`TEMP_NIRS3_LED_VAR == 2'b10);
assign nirs_ppg_vif.led1_en[4] = (`TEMP_NIRS4_LED_VAR == 2'b10);
assign nirs_ppg_vif.led1_en[5] = (`TEMP_NIRS5_LED_VAR == 2'b10);
assign nirs_ppg_vif.led1_en[6] = (`TEMP_NIRS6_LED_VAR == 2'b10);
assign nirs_ppg_vif.led1_en[7] = (`TEMP_NIRS7_LED_VAR == 2'b10);

assign nirs_ppg_vif.counter_en[0] = `NIR0.u_nirs_pulse_ctrl.count_cur;
assign nirs_ppg_vif.counter_en[2] = `NIR2.u_nirs_pulse_ctrl.count_cur;
assign nirs_ppg_vif.counter_en[3] = `NIR3.u_nirs_pulse_ctrl.count_cur;
`ifdef BEHAVIORAL
assign nirs_ppg_vif.counter_en[1] = `NIR1.u_nirs_pulse_ctrl.count_cur;
assign nirs_ppg_vif.counter_en[4] = `NIR4.u_nirs_pulse_ctrl.count_cur;
assign nirs_ppg_vif.counter_en[5] = `NIR5.u_nirs_pulse_ctrl.count_cur;
assign nirs_ppg_vif.counter_en[6] = `NIR6.u_nirs_pulse_ctrl.count_cur;
assign nirs_ppg_vif.counter_en[7] = `NIR7.u_nirs_pulse_ctrl.count_cur;
`else
assign nirs_ppg_vif.counter_en[1] = `NIR1.u_nirs_pulse_ctrl.count_cur_reg.Q;
assign nirs_ppg_vif.counter_en[4] = `NIR4.u_nirs_pulse_ctrl.count_cur_reg.Q; 
assign nirs_ppg_vif.counter_en[5] = `NIR5.u_nirs_pulse_ctrl.count_cur_reg.Q;
assign nirs_ppg_vif.counter_en[6] = `NIR6.u_nirs_pulse_ctrl.count_cur_reg.Q;
assign nirs_ppg_vif.counter_en[7] = `NIR7.u_nirs_pulse_ctrl.count_cur_reg.Q;
`endif

// A2D IREFCOARSE and A2DIREF FINE SYNC
genvar i;
generate
  for (i = 0; i < 8; i++) begin
    always @(posedge nirs_ppg_vif.nirs_ppg_clk or negedge `NIRS_PPG_TOP.rst_n) begin
      if (!`NIRS_PPG_TOP.rst_n)begin
        nirs_ppg_vif.a2d_nirs_ireffine_sync_d1[i] <= 1'b0;
        nirs_ppg_vif.a2d_nirs_ireffine_sync_d2[i] <= 1'b0;
      end
      else begin
         nirs_ppg_vif.a2d_nirs_ireffine_sync_d1[i]  <= nirs_ppg_vif.a2d_nirs_ireffine_bus[i];
         nirs_ppg_vif.a2d_nirs_ireffine_sync_d2[i]  <= nirs_ppg_vif.a2d_nirs_ireffine_sync_d1[i];
      end 
    end
  end
endgenerate

genvar i;
generate
  for (i = 0; i < 8; i++) begin
    always @(posedge nirs_ppg_vif.nirs_ppg_clk or negedge `NIRS_PPG_TOP.rst_n) begin
      if (!`NIRS_PPG_TOP.rst_n)begin
        nirs_ppg_vif.a2d_nirs_irefcoarse_sync_d1[i] <= 1'b0;
        nirs_ppg_vif.a2d_nirs_irefcoarse_sync_d2[i] <= 1'b0;
      end
      else begin
               nirs_ppg_vif.a2d_nirs_irefcoarse_sync_d1[i]  <= nirs_ppg_vif.a2d_nirs_irefcoarse_bus[i];
               nirs_ppg_vif.a2d_nirs_irefcoarse_sync_d2[i]  <= nirs_ppg_vif.a2d_nirs_irefcoarse_sync_d1[i];
       end 
    end
  end
endgenerate


//
genvar i;
generate
  for (i = 0; i < 8; i++) begin
      assign nirs_ppg_vif.A2D_NIRS_IREFCOARSE[i]  = nirs_ppg_vif.a2d_nirs_irefcoarse_sync_d2[i]; 
      assign nirs_ppg_vif.A2D_NIRS_IREFFINE[i]    = nirs_ppg_vif.a2d_nirs_ireffine_sync_d2[i];    
  end
endgenerate

//expected DOUTC generattion
genvar i;
generate
  for (i = 0; i < 8; i++) begin
    always @(posedge nirs_ppg_vif.nirs_ppg_clk or negedge `NIRS_PPG_TOP.rst_n) begin
      if (!`NIRS_PPG_TOP.rst_n)begin
        nirs_ppg_vif.expected_doutc[i] <= 1'b0;
         end
      else begin
        if(nirs_ppg_vif.ch_en_mask[i])begin
           if(nirs_ppg_vif.counters_clear[i] === 1'b1)begin
              nirs_ppg_vif.expected_doutc[i]  <= 1'h0;
           end
           //else if((nirs_ppg_vif.a2d_nirs_irefcoarse_sync_d1[i] === 1'b0) && (nirs_ppg_vif.a2d_nirs_irefcoarse_sync_d2[i] ===1'b1))begin
             //nirs_ppg_vif.expected_doutc[i]  <= nirs_ppg_vif.expected_doutc[i]; 
           //end
           else if((nirs_ppg_vif.a2d_nirs_irefcoarse_sync_d2[i] ===1'b1))begin
             nirs_ppg_vif.expected_doutc[i]  <= nirs_ppg_vif.expected_doutc[i] +1'b1;
           end
           else begin
             nirs_ppg_vif.expected_doutc[i]  <= nirs_ppg_vif.expected_doutc[i];
           end
        end //ch_en_mask
      end //else if
    end
  end
endgenerate

//NIRS IDAC DATA DATA CHECK
//expected DOUTF generattion
genvar i;
generate
  for (i = 0; i < 8; i++) begin
    always @(posedge nirs_ppg_vif.nirs_ppg_clk or negedge `NIRS_PPG_TOP.rst_n) begin
      if (!`NIRS_PPG_TOP.rst_n)begin
        nirs_ppg_vif.expected_doutf[i] <= 1'b0;
      end
      else begin
        if(nirs_ppg_vif.ch_en_mask[i])begin
            if(nirs_ppg_vif.counters_clear[i] === 1'b1)begin
              nirs_ppg_vif.expected_doutf[i]  <= 1'h0;
            end 
            //else if((nirs_ppg_vif.a2d_nirs_ireffine_sync_d1[i] === 1'b0) && ( nirs_ppg_vif.a2d_nirs_ireffine_sync_d2[i] === 1'b1))begin
              //nirs_ppg_vif.expected_doutf[i]  <= nirs_ppg_vif.expected_doutf[i] ;
            //end
            else if(nirs_ppg_vif.a2d_nirs_ireffine_sync_d2[i] === 1'b1)begin
              nirs_ppg_vif.expected_doutf[i]  <= nirs_ppg_vif.expected_doutf[i] +1'b1;
            end
            else begin
               nirs_ppg_vif.expected_doutf[i]  <= nirs_ppg_vif.expected_doutf[i];
            end
        end //ch_en_mask
      end //else if
    end
  end
endgenerate

//Final expected doutc and doutf
genvar i;
generate
  for (i = 0; i < 8; i++) begin
    always @(posedge nirs_ppg_vif.nirs_ppg_clk or negedge `NIRS_PPG_TOP.rst_n) begin
      if (!`NIRS_PPG_TOP.rst_n)begin
          nirs_ppg_vif.expected_final_doutc[i] <=1'b0;
          nirs_ppg_vif.expected_final_doutf[i] <= 1'b0;        
      end
      else if(nirs_ppg_vif.final_doutq_c_latch_en[i] === 1'b1)begin
          nirs_ppg_vif.expected_final_doutc[i] <= nirs_ppg_vif.expected_doutc[i];
          nirs_ppg_vif.expected_final_doutf[i] <= nirs_ppg_vif.expected_doutf[i];
      end
    end
  end
endgenerate

genvar i, j;
generate
  for(i=0; i<2; i++)begin : g_led    //2 leds
     for(j=0; j<8; j++)begin :g_ch//8 channels
        assign nirs_ppg_vif.expected_ratio_tmp[j][i] = (nirs_ppg_vif.nirs_ppg_cfg_array[0][i].ratio_ctrl == 2'b00) ? 8'd128 : 
                                                       (nirs_ppg_vif.nirs_ppg_cfg_array[0][i].ratio_ctrl == 2'b01) ? 8'd64  :
                                                       (nirs_ppg_vif.nirs_ppg_cfg_array[0][i].ratio_ctrl == 2'b10) ? 8'd32  :
                                                       (nirs_ppg_vif.nirs_ppg_cfg_array[0][i].ratio_ctrl == 2'b11) ? 8'd16  : 8'd128;
        
        //LED0 configuration
        assign nirs_ppg_vif.expected_ratio[j][i] = nirs_ppg_vif.nirs_ppg_cfg_array[0][i].ratio_mode ? nirs_ppg_vif.nirs_ppg_cfg_array[0][i].ratio_manual : nirs_ppg_vif.expected_ratio_tmp[j][i]; 

        assign nirs_ppg_vif.expected_avg_sel[j][i] = (nirs_ppg_vif.nirs_ppg_cfg_array[0][i].avg_sel == 2'b00)    ? 3'b000 :
                                                     (nirs_ppg_vif.nirs_ppg_cfg_array[0][i].avg_sel == 2'b10)    ? 3'b001 :
                                                     (nirs_ppg_vif.nirs_ppg_cfg_array[0][i].avg_sel == 2'b10)    ? 3'b010 :
                                                     (nirs_ppg_vif.nirs_ppg_cfg_array[0][i].avg_sel == 2'b11)    ? 3'b100 :  3'b000;         
     end
   end 
endgenerate

//{soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_nirs_wrapper.u_nirs_ctrl_top[3].u_nirs_pulse_ctrl.LED[1:0]}
genvar sub_ch;
generate
  for(sub_ch =0; sub_ch <8; sub_ch++)begin
     assign nirs_ppg_vif.expected_sub_result_led0[sub_ch] = ((nirs_ppg_vif.expected_ratio[sub_ch][0]*nirs_ppg_vif.expected_final_doutc[sub_ch]) - nirs_ppg_vif.expected_final_doutf[sub_ch]);
     assign nirs_ppg_vif.expected_sub_result_amb0[sub_ch] = ((nirs_ppg_vif.expected_ratio[sub_ch][0]*nirs_ppg_vif.expected_final_doutc[sub_ch]) - nirs_ppg_vif.expected_final_doutf[sub_ch]);
     assign nirs_ppg_vif.expected_sub_result_led1[sub_ch] = ((nirs_ppg_vif.expected_ratio[sub_ch][1]*nirs_ppg_vif.expected_final_doutc[sub_ch]) - nirs_ppg_vif.expected_final_doutf[sub_ch]);
     assign nirs_ppg_vif.expected_sub_result_amb1[sub_ch] = ((nirs_ppg_vif.expected_ratio[sub_ch][1]*nirs_ppg_vif.expected_final_doutc[sub_ch]) - nirs_ppg_vif.expected_final_doutf[sub_ch]);
  end 
endgenerate

genvar dout_temp;
generate
  for(dout_temp =0; dout_temp <8; dout_temp++)begin
     assign nirs_ppg_vif.expected_dout_temp_led0[dout_temp] = nirs_ppg_vif.expected_sub_result_led0[dout_temp] >>  nirs_ppg_vif.expected_avg_sel[dout_temp][0];
     assign nirs_ppg_vif.expected_dout_temp_amb0[dout_temp] = nirs_ppg_vif.expected_sub_result_amb0[dout_temp] >>  nirs_ppg_vif.expected_avg_sel[dout_temp][0];
     assign nirs_ppg_vif.expected_dout_temp_led1[dout_temp] = nirs_ppg_vif.expected_sub_result_led1[dout_temp] >>  nirs_ppg_vif.expected_avg_sel[dout_temp][1];
     assign nirs_ppg_vif.expected_dout_temp_amb1[dout_temp] = nirs_ppg_vif.expected_sub_result_amb1[dout_temp] >>  nirs_ppg_vif.expected_avg_sel[dout_temp][1];
  end 
endgenerate

//DOUT
genvar dout_loop;
generate
  for (dout_loop = 0; dout_loop < 8; dout_loop++) begin
    always @(posedge nirs_ppg_vif.nirs_ppg_clk or negedge `NIRS_PPG_TOP.rst_n) begin
      if (!`NIRS_PPG_TOP.rst_n)begin
         nirs_ppg_vif.expected_dout_led0[dout_loop]  <= 22'h0;
         nirs_ppg_vif.expected_dout_amb0[dout_loop]  <= 22'h0;
         nirs_ppg_vif.expected_dout_led1[dout_loop]  <= 22'h0;
         nirs_ppg_vif.expected_dout_amb1[dout_loop]  <= 22'h0;      
      end
      else begin
           if(nirs_ppg_vif.dout_led0_en[dout_loop] === 1'b1)begin
             nirs_ppg_vif.expected_dout_led0[dout_loop]  <= nirs_ppg_vif.expected_dout_temp_led0[dout_loop];
           end
           if(nirs_ppg_vif.dout_amb0_en[dout_loop] === 1'b1)begin
             nirs_ppg_vif.expected_dout_amb0[dout_loop]  <= nirs_ppg_vif.expected_dout_temp_amb0[dout_loop];
           end
           if(nirs_ppg_vif.dout_led1_en[dout_loop] === 1'b1)begin
             nirs_ppg_vif.expected_dout_led1[dout_loop]  <= nirs_ppg_vif.expected_dout_temp_led1[dout_loop] ;
           end
           if(nirs_ppg_vif.dout_amb1_en[dout_loop] === 1'b1)begin
             nirs_ppg_vif.expected_dout_amb1[dout_loop]  <= nirs_ppg_vif.expected_dout_temp_amb1[dout_loop];
           end
      end
    end
  end
endgenerate

//IDAC
assign nirs_ppg_vif.expected_dout_tmp[0] = (`TEMP_NIRS0_LED_VAR == 2'b00) ?  nirs_ppg_vif.expected_dout_led0[0] : (`TEMP_NIRS0_LED_VAR == 2'b01) ? nirs_ppg_vif.expected_dout_amb0[0] : (`TEMP_NIRS0_LED_VAR == 2'b10) ? nirs_ppg_vif.expected_dout_led1[0] : (`TEMP_NIRS0_LED_VAR == 2'b11) ? nirs_ppg_vif.expected_dout_amb1[0] : nirs_ppg_vif.expected_dout_led0[0];

assign nirs_ppg_vif.expected_dout_tmp[1] = (`TEMP_NIRS1_LED_VAR == 2'b00) ? nirs_ppg_vif.expected_dout_led0[1] : (`TEMP_NIRS1_LED_VAR == 2'b01) ? nirs_ppg_vif.expected_dout_amb0[1] : (`TEMP_NIRS1_LED_VAR == 2'b10)  ? nirs_ppg_vif.expected_dout_led1[1] : (`TEMP_NIRS1_LED_VAR == 2'b11)  ? nirs_ppg_vif.expected_dout_amb1[1] : nirs_ppg_vif.expected_dout_led0[0];

assign nirs_ppg_vif.expected_dout_tmp[2] = (`TEMP_NIRS2_LED_VAR == 2'b00)  ? nirs_ppg_vif.expected_dout_led0[2] : (`TEMP_NIRS2_LED_VAR == 2'b01) ? nirs_ppg_vif.expected_dout_amb0[2] : (`TEMP_NIRS2_LED_VAR == 2'b10)  ? nirs_ppg_vif.expected_dout_led1[2] : (`TEMP_NIRS2_LED_VAR == 2'b11)   ? nirs_ppg_vif.expected_dout_amb1[2] : nirs_ppg_vif.expected_dout_led0[0];

assign nirs_ppg_vif.expected_dout_tmp[3] = (`TEMP_NIRS3_LED_VAR == 2'b00)  ? nirs_ppg_vif.expected_dout_led0[3] : (`TEMP_NIRS3_LED_VAR == 2'b01) ? nirs_ppg_vif.expected_dout_amb0[3] : (`TEMP_NIRS3_LED_VAR == 2'b10)  ? nirs_ppg_vif.expected_dout_led1[3] : (`TEMP_NIRS3_LED_VAR == 2'b11)   ? nirs_ppg_vif.expected_dout_amb1[3] : nirs_ppg_vif.expected_dout_led0[0];

assign nirs_ppg_vif.expected_dout_tmp[4] = (`TEMP_NIRS4_LED_VAR == 2'b00)  ?  nirs_ppg_vif.expected_dout_led0[4] : (`TEMP_NIRS4_LED_VAR == 2'b01) ? nirs_ppg_vif.expected_dout_amb0[4] : (`TEMP_NIRS4_LED_VAR == 2'b10)  ? nirs_ppg_vif.expected_dout_led1[4] : (`TEMP_NIRS4_LED_VAR == 2'b11)   ? nirs_ppg_vif.expected_dout_amb1[4] : nirs_ppg_vif.expected_dout_led0[0];

assign nirs_ppg_vif.expected_dout_tmp[5] = (`TEMP_NIRS5_LED_VAR == 2'b00)  ?  nirs_ppg_vif.expected_dout_led0[5] :(`TEMP_NIRS5_LED_VAR == 2'b01) ? nirs_ppg_vif.expected_dout_amb0[5] : (`TEMP_NIRS5_LED_VAR == 2'b10)  ? nirs_ppg_vif.expected_dout_led1[5] : (`TEMP_NIRS5_LED_VAR == 2'b11)   ? nirs_ppg_vif.expected_dout_amb1[5] : nirs_ppg_vif.expected_dout_led0[0];

assign nirs_ppg_vif.expected_dout_tmp[6] = (`TEMP_NIRS6_LED_VAR == 2'b00)  ?  nirs_ppg_vif.expected_dout_led0[6] : (`TEMP_NIRS6_LED_VAR == 2'b01) ? nirs_ppg_vif.expected_dout_amb0[6] : (`TEMP_NIRS6_LED_VAR == 2'b10)  ? nirs_ppg_vif.expected_dout_led1[6] : (`TEMP_NIRS6_LED_VAR == 2'b11)   ? nirs_ppg_vif.expected_dout_amb1[6] : nirs_ppg_vif.expected_dout_led0[0];

assign nirs_ppg_vif.expected_dout_tmp[7] = (`TEMP_NIRS7_LED_VAR == 2'b00)  ?  nirs_ppg_vif.expected_dout_led0[7] : (`TEMP_NIRS7_LED_VAR == 2'b01) ? nirs_ppg_vif.expected_dout_amb0[7] : (`TEMP_NIRS7_LED_VAR == 2'b10)  ? nirs_ppg_vif.expected_dout_led1[7] : (`TEMP_NIRS7_LED_VAR == 2'b11)   ? nirs_ppg_vif.expected_dout_amb1[7] : nirs_ppg_vif.expected_dout_led0[0];

//expected dout_reg_en and idac_reg_en;
genvar dou_reg_en;
generate 
   for(dou_reg_en =0 ; dou_reg_en<8; dou_reg_en++)begin
      always @(posedge nirs_ppg_vif.nirs_ppg_clk or negedge `NIRS_PPG_TOP.rst_n) begin
          if(`NIRS_PPG_TOP.rst_n === 1'b0)begin
              nirs_ppg_vif.dout_en_d[dou_reg_en] <= 1'b0;
              nirs_ppg_vif.idac_en_d[dou_reg_en] <= 1'b0;
          end
          else begin
              nirs_ppg_vif.dout_en_d[dou_reg_en] <= nirs_ppg_vif.dout_reg_en[dou_reg_en];
              nirs_ppg_vif.idac_en_d[dou_reg_en] <= nirs_ppg_vif.idac_reg_en[dou_reg_en];
          end
      end 
   end 
endgenerate


//max_idac, min_idac
genvar max_ch, max_led;
generate 
  for(max_led =0 ; max_led<2; max_led++)begin
   for(max_ch=0; max_ch<8; max_ch++)begin
     assign nirs_ppg_vif.max_expected_idac_temp[max_ch][max_led] = (nirs_ppg_vif.expected_idac_temp[max_ch][max_led] == 9'h1FF); 
   end
  end
endgenerate

genvar min_ch, min_led;
generate 
  for(min_led =0 ; min_led<2; min_led++)begin
   for(min_ch=0; min_ch<8; min_ch++)begin
     assign nirs_ppg_vif.min_expected_idac_temp[min_ch][min_led] = (nirs_ppg_vif.expected_idac_temp[min_ch][min_led] == 9'h0); 
   end
  end
endgenerate

//
genvar idac_temp_loop, idac_temp_led;
generate
  for(idac_temp_led =0; idac_temp_led <2; idac_temp_led++)begin
    for (dout_loop = 0; dout_loop < 8; dout_loop++) begin
      always @(posedge nirs_ppg_vif.nirs_ppg_clk or negedge `NIRS_PPG_TOP.rst_n) begin
        if(!`NIRS_PPG_TOP.rst_n)begin
          nirs_ppg_vif.expected_idac_temp[dout_loop][idac_temp_led] <= 9'h0;
        end
        else begin
          if((idac_temp_led == 1'b0) && (nirs_ppg_vif.idac_led0_en[dout_loop] == 1'b1))begin
             if((nirs_ppg_vif.expected_dout_tmp[dout_loop] > ({nirs_ppg_vif.nirs_ppg_cfg_array[0][0].threshold_h_18_16, nirs_ppg_vif.nirs_ppg_cfg_array[0][0].threshold_h_15_8, nirs_ppg_vif.nirs_ppg_cfg_array[0][0].threshold_h_7_0})) ||
                (nirs_ppg_vif.expected_final_doutf[dout_loop] == 1'b0) || (nirs_ppg_vif.idac_increas_en[dout_loop] == 1'b1))begin
                if(nirs_ppg_vif.max_expected_idac_temp[dout_loop][0] === 1'b0)begin
                  nirs_ppg_vif.expected_idac_temp[dout_loop][0] <= nirs_ppg_vif.expected_idac_temp[dout_loop][0] + 1'b1;
                end 
             end
             else if(nirs_ppg_vif.expected_dout_tmp[dout_loop] < nirs_ppg_vif.nirs_ppg_cfg_array[0][0].threshold_l_7_0)begin
               if(nirs_ppg_vif.min_expected_idac_temp[dout_loop][idac_temp_led] == 1'b0) begin
                 nirs_ppg_vif.expected_idac_temp[dout_loop][0] <= nirs_ppg_vif.expected_idac_temp[dout_loop][0] - 1'b1;
               end
             end
          end //led0
          if((idac_temp_led == 1'b1) && (nirs_ppg_vif.idac_led1_en[dout_loop] ==1'b1))begin
             if((nirs_ppg_vif.expected_dout_tmp[dout_loop] > ({nirs_ppg_vif.nirs_ppg_cfg_array[0][1].threshold_h_18_16, nirs_ppg_vif.nirs_ppg_cfg_array[0][1].threshold_h_15_8, nirs_ppg_vif.nirs_ppg_cfg_array[0][1].threshold_h_7_0})) ||
                (nirs_ppg_vif.expected_final_doutf[dout_loop] == 1'b0) || (nirs_ppg_vif.idac_increas_en[dout_loop] == 1'b1))begin
                if(nirs_ppg_vif.max_expected_idac_temp[dout_loop][1] === 1'b0)begin
                  nirs_ppg_vif.expected_idac_temp[dout_loop][1] <= nirs_ppg_vif.expected_idac_temp[dout_loop][1] + 1'b1;
                end 
             end
             else if(nirs_ppg_vif.expected_dout_tmp[dout_loop] < nirs_ppg_vif.nirs_ppg_cfg_array[0][1].threshold_l_7_0)begin
               if(nirs_ppg_vif.min_expected_idac_temp[dout_loop][idac_temp_led] == 1'b0) begin
                 nirs_ppg_vif.expected_idac_temp[dout_loop][1] <= nirs_ppg_vif.expected_idac_temp[dout_loop][1] - 1'b1;
               end
             end
          end //idac_temp_led == 1'b1
        end //else
      end //always
    end //for
  end //for
endgenerate

genvar idac_loop, idac_leds;
generate
  for(idac_leds =0; idac_leds < 2; idac_leds++)begin
     for (idac_loop = 0; idac_loop < 8; idac_loop++) begin :g_idac_chx
         assign nirs_ppg_vif.expected_idac[idac_loop][idac_leds] = nirs_ppg_vif.nirs_ppg_cfg_array[idac_loop][idac_leds].idac_manual_en ? nirs_ppg_vif.nirs_ppg_cfg_array[idac_loop][idac_leds].idac_manual_8_0 : nirs_ppg_vif.expected_idac_temp[idac_loop][idac_leds]; 
     end
  end
endgenerate


//expected dout_reg_data and idac_reg_data
genvar dout_reg;
generate 
   for(dout_reg =0 ; dout_reg<8; dout_reg++)begin
      always @(posedge nirs_ppg_vif.nirs_ppg_clk or negedge `NIRS_PPG_TOP.rst_n) begin
          if(`NIRS_PPG_TOP.rst_n === 1'b0)begin
              nirs_ppg_vif.expected_dout_reg_data[dout_reg] <= 22'h0;
              nirs_ppg_vif.expected_idac_reg_data[dout_reg] <= 9'h0;
          end
          else begin
              if(nirs_ppg_vif.dout_en_d[dout_reg] === 1'b1)begin
                nirs_ppg_vif.expected_dout_reg_data[dout_reg] <= nirs_ppg_vif.expected_dout_tmp[dout_reg]; 
              end
              if(nirs_ppg_vif.idac_en_d[dout_reg] === 1'b1)begin
                 nirs_ppg_vif.expected_idac_reg_data[dout_reg] <= (nirs_ppg_vif.dout_led0_en[dout_reg] === 1'b1) ? 9'h0 : ((nirs_ppg_vif.dout_led1_en[dout_reg] === 1'b1) ? nirs_ppg_vif.expected_idac[dout_reg][1] : nirs_ppg_vif.expected_idac[dout_reg][0]);
              end
          end
      end 
   end 
endgenerate

//
assign nirs_ppg_vif.LED_ON_IO[0] = `PINMUX_TOP.i_gpio_nirs_out_ctrl ? `NIR0.LED_ON : `SOC_TOP.IOBUF_PAD[14]; // get LED_ON signal, when gpio_nirs_out_ctrl=1, IO wil server other functions
assign nirs_ppg_vif.LED_ON_IO[1] = `PINMUX_TOP.i_gpio_nirs_out_ctrl ? `NIR1.LED_ON : `SOC_TOP.IOBUF_PAD[15];
assign nirs_ppg_vif.LED_ON_IO[2] = `PINMUX_TOP.i_gpio_nirs_out_ctrl ? `NIR2.LED_ON : `SOC_TOP.IOBUF_PAD[16];
assign nirs_ppg_vif.LED_ON_IO[3] = `PINMUX_TOP.i_gpio_nirs_out_ctrl ? `NIR3.LED_ON : `SOC_TOP.IOBUF_PAD[17];
assign nirs_ppg_vif.LED_ON_IO[4] = `PINMUX_TOP.i_gpio_nirs_out_ctrl ? `NIR4.LED_ON : `SOC_TOP.IOBUF_PAD[18];
assign nirs_ppg_vif.LED_ON_IO[5] = `PINMUX_TOP.i_gpio_nirs_out_ctrl ? `NIR5.LED_ON : `SOC_TOP.IOBUF_PAD[19];
assign nirs_ppg_vif.LED_ON_IO[6] = `PINMUX_TOP.i_gpio_nirs_out_ctrl ? `NIR6.LED_ON : `SOC_TOP.IOBUF_PAD[20];
assign nirs_ppg_vif.LED_ON_IO[7] = `PINMUX_TOP.i_gpio_nirs_out_ctrl ? `NIR7.LED_ON : `SOC_TOP.IOBUF_PAD[21];
//assign expected_sub_result[0] =  (nirs_ppg_vif.expected_ratio*nirs_ppg_vif.expected_final_doutc[i]) - nirs_ppg_vif.expected_final_doutf[i]
//initial begin
//    nirs_ppg_vif.cfg = top_cfg.nirs_ppg_cfg; //`NIRS_PPG_CTRL_CFG;   // pass config handle
//end
//{soc_top_tb.u_Nanochap_ENS2.u_top_dig.u_nirs_wrapper.u_nirs_ctrl_top[0].u_nirs_ppg_int.INT_IO}
