/*--------------------------------------------------------------------------------------*/
// Copyright 2021 Nanochap, Inc.
// All Rights Reserved Worldwide
// --------------------------------------------------------------------------------------
// Project      : Nanochap ENS1p4
// File         : tb_chip_top_uvm_eeprom.sv
// Description  : EPROM TB 
// Designer     : Daniel Dang
// Date         : 18-03-2024
// Revision     : 0.1
/*--------------------------------------------------------------------------------------*/

`define EPROM_BIST_SCOREBOARD_EN          top_cfg.eprom_cfg.nnc_eprom_scoreboard_en
// --------------------------------------------------------------------------------
// EPROM BIST MODEL
// --------------------------------------------------------------------------------
nnc_bistm_vip u_eprom_bist_master (
	.TDO(TDO),                     //output from bist design
	.TDO_SEROUT(TDO_SEROUT),              //output from bist design
	.TCK(TCK),                     //input to bist design      	       
	.RESETb(RESETb),               //input to bist design
	.TESTEN(TESTEN),               //input to bist design
	.STROBE(STROBE),                     //input to bist design
	.TDI(TDI),                     //input to bist design
        .VPP(VPP_BIST),
        .TESTMODE_SEL(dut_vif.testmode_sel),
        .bist_freq_sel(dut_vif.bistm_freq_sel), //output from TB to BistM
        .bist_freq(dut_vif.bistm_freq)          //output from TB to BistM        
);


// ==========================
// EPROM interface connection
// ==========================
// --------------------------------------------------------------------------------
// EPROM BIST interface connection 
// --------------------------------------------------------------------------------
nnc_eprom_bist_interface        eprom_bist_if();
assign eprom_bist_if.TDO			             =  TDO			          ;
assign eprom_bist_if.TCK			             =  TCK			          ;
assign eprom_bist_if.RESETb                      =  RESETb                  ; 
assign eprom_bist_if.TESTEN                      =  TESTEN                  ;     
assign eprom_bist_if.TDI                         =  TDI                     ;     
assign eprom_bist_if.STROBE                      =  STROBE                  ;     
assign eprom_bist_if.TDO_SEROUT                  =  TDO_SEROUT              ;  

`define EPROM_BIST_IF `SOC_TB.eprom_bist_if

// --------------------------------------------------------------------------------
// EPROM IP interface connection 
// --------------------------------------------------------------------------------
nnc_eprom_interface             eprom_ip_if();
assign eprom_ip_if.ADR    =    { `EPROM_IP1.PA   , `EPROM_IP.PA   }  ; 
assign eprom_ip_if.DIN    =    { `EPROM_IP1.PDIN , `EPROM_IP.PDIN }  ;   
assign eprom_ip_if.DOUT   =    { `EPROM_IP1.PDOB , `EPROM_IP.PDOB }  ;   
assign eprom_ip_if.PGM    =    { `EPROM_IP1.PWE  , `EPROM_IP.PWE  }  ;   
//assign eprom_ip_if.CS     =    { `EPROM_IP.XCE  , `EPROM_IP.XCE  }  ;   
assign eprom_ip_if.TM     =    { `EPROM_IP1.PTM  , `EPROM_IP.PTM  }  ;   
assign eprom_ip_if.READ   =    { `EPROM_IP1.POR  , `EPROM_IP.POR  }  ;   


initial begin
    nnc_config_db#(virtual nnc_eprom_bist_interface)::set(uvm_root::get(), "uvm_test_top.top_env.eprom_env.*", "eprom_bist_if", eprom_bist_if);
    nnc_config_db#(virtual nnc_eprom_interface)::set(uvm_root::get(), "uvm_test_top.top_env.eprom_env.*", "eprom_ip_if", eprom_ip_if);
end

// ------------------------
// Moving it to EPROM SB 
// ------------------------
always @ (`EPROM_IP.pic_err_count or `EPROM_IP.pic_vio_count) begin
      // Read Error from memory model
      if ((`EPROM_IP.pic_err_count !== 0) /* && (dut_vif.testmode_sel === 2'b00)*/ && (dut_vif.otp_ignore_check_en === 1'b0)) begin
       `nnc_error("SOC_TEST", $sformatf("Error!!! EPROM memory is having %d errors!!!", `EPROM_IP.pic_err_count))
      end
      if ((`EPROM_IP.pic_vio_count !== 0) /*&& (dut_vif.testmode_sel === 2'b00)*/ && (dut_vif.otp_ignore_check_en === 1'b0)) begin
       `nnc_error("SOC_TEST", $sformatf("Error!!! EPROM memory is having %d violations!!!", `EPROM_IP.pic_vio_count))
      end
end

always @ (`EPROM_IP_S1.pic_err_count or `EPROM_IP_S1.pic_vio_count) begin
      // Read Error from memory model
      if ((`EPROM_IP_S1.pic_err_count !== 0) && (dut_vif.mult_chip_en === 1'b1) && (dut_vif.swap_sdf_en === 1'b0) /*&& (dut_vif.testmode_sel === 2'b00)*/ && (dut_vif.otp_ignore_check_en === 1'b0))begin
       `nnc_error("SOC_TEST", $sformatf("Error!!! EPROM memory (slave chip) is having %d errors!!!", `EPROM_IP_S1.pic_err_count))
      end
      if ((`EPROM_IP_S1.pic_vio_count !== 0) && (dut_vif.mult_chip_en === 1'b1) && (dut_vif.swap_sdf_en === 1'b0) /*&& (dut_vif.testmode_sel === 2'b00)*/ && (dut_vif.otp_ignore_check_en === 1'b0))begin
       `nnc_error("SOC_TEST", $sformatf("Error!!! EPROM memory (slave chip) is having %d violations!!!", `EPROM_IP_S1.pic_vio_count))
      end
end

always @ (`EPROM_IP_S2.pic_err_count or `EPROM_IP_S2.pic_vio_count) begin
      // Read Error from memory model
      if ((`EPROM_IP_S2.pic_err_count !== 0) && (dut_vif.mult_chip_en === 1'b1) && (dut_vif.swap_sdf_en === 1'b1) /*&& (dut_vif.testmode_sel === 2'b00)*/ && (dut_vif.otp_ignore_check_en === 1'b0))begin
       `nnc_error("SOC_TEST", $sformatf("Error!!! EPROM memory (slave chip) is having %d errors!!!", `EPROM_IP_S2.pic_err_count))
      end
      if ((`EPROM_IP_S2.pic_vio_count !== 0) && (dut_vif.mult_chip_en === 1'b1) && (dut_vif.swap_sdf_en === 1'b1) /*&& (dut_vif.testmode_sel === 2'b00)*/ && (dut_vif.otp_ignore_check_en === 1'b0))begin
       `nnc_error("SOC_TEST", $sformatf("Error!!! EPROM memory (slave chip) is having %d violations!!!", `EPROM_IP_S2.pic_vio_count))
      end
end
