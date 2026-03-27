// --------------------------------------------------------------------------------------
// Project      : Nanochap ENS2
// File         : tb_chip_top_uvm_pinmux.sv
// Description  : ANALOG BLOCK TB (included file) 
// Designer     : Zion
// Date         : 26-9-2024
// Revision     : 0.1
/*--------------------------------------------------------------------------------------*/

// Design a logic to capture DATAs for Driver A
nnc_pinmux_interface     pinmux_vif();
    assign pinmux_vif.clksel = `SOC_TOP.CLKSEL;
    assign pinmux_vif.resetn = `SOC_TOP.RESETn;
    //assign pinmux_vif.clk = `EPROM_TOP.clk;      
    assign pinmux_vif.ext_clk = `DIG_TOP.u_pinmux.ext_clk;      

    //NORMAL MODE  
    assign pinmux_vif.cpol = `DIG_TOP.u_pinmux.o_cpoln;
    assign pinmux_vif.cpha = `DIG_TOP.u_pinmux.o_cpha;
    assign pinmux_vif.cs = `DIG_TOP.u_pinmux.cs_n;
    assign pinmux_vif.sclk = `DIG_TOP.u_pinmux.sclk;
    assign pinmux_vif.mosi = (`DIG_TOP.u_pinmux.mosi === 1'bx)? 1'b0 : `DIG_TOP.u_pinmux.mosi;
    assign pinmux_vif.miso = `DIG_TOP.u_pinmux.miso;
    assign pinmux_vif.intb = `DIG_TOP.u_pinmux.INTB;
    assign pinmux_vif.GPIO8_NORMAL_OUT = `DIG_TOP.u_pinmux.GPIO14_NORMAL_OUT;
    assign pinmux_vif.hfosc_out = `DIG_TOP.u_pinmux.hfosc_out;
    assign pinmux_vif.int_clk_out_gpio = `DIG_TOP.u_pinmux.o_int_clk_out_gpio;
    //SCAN MODE
    assign pinmux_vif.scan_rst_n = `DIG_TOP.u_pinmux.scan_rst_n;
    assign pinmux_vif.scan_clk = `DIG_TOP.u_pinmux.scan_clk;
    assign pinmux_vif.scan_en = `DIG_TOP.u_pinmux.scan_en;
    assign pinmux_vif.scan_compression_in = `DIG_TOP.u_pinmux.scan_compression_in;
    assign pinmux_vif.scan_in = `DIG_TOP.u_pinmux.scan_in[3:0];
    assign pinmux_vif.scan_out = `DIG_TOP.u_pinmux.scan_out[3:0];
    //BIST MODE
    assign pinmux_vif.otp_bist_resetn = `DIG_TOP.u_pinmux.otp_bist_resetn;
    assign pinmux_vif.otp_bist_tck = `DIG_TOP.u_pinmux.otp_bist_tck;
    assign pinmux_vif.otp_bist_strobe = `DIG_TOP.u_pinmux.otp_bist_strobe;
    assign pinmux_vif.otp_bist_tdi = `DIG_TOP.u_pinmux.otp_bist_tdi;
    assign pinmux_vif.otp_bist_tdo_serout = `DIG_TOP.u_pinmux.otp_bist_tdo_serout;
    assign pinmux_vif.otp_bist_tdo = `DIG_TOP.u_pinmux.otp_bist_tdo;
    //assign pinmux_vif.otp_bist_vpp_en = `DIG_TOP.u_pinmux.i_bist_vpp_en;
    //ATM MODE
    assign pinmux_vif.OTP_UNLOCK = `DIG_TOP.u_pinmux.o_OTP_UNLOCK;
    assign pinmux_vif.d2a_trim0_reg = `DIG_TOP.u_pinmux.pad_d2a_trim0_sig[5:0];
    assign pinmux_vif.d2a_trim1_reg = `DIG_TOP.u_pinmux.pad_d2a_trim1_sig[5:0];
    assign pinmux_vif.d2a_trim2_reg = `DIG_TOP.u_pinmux.pad_d2a_trim2_sig[5:0];
    assign pinmux_vif.d2a_trim3_reg = `DIG_TOP.u_pinmux.pad_d2a_trim3_sig[5:0];
    assign pinmux_vif.d2a_trim4_reg = `DIG_TOP.u_pinmux.pad_d2a_trim4_sig[5:0];
    assign pinmux_vif.d2a_trim5_reg = `DIG_TOP.u_pinmux.pad_d2a_trim5_sig[5:0];
    assign pinmux_vif.d2a_trim6_reg = `DIG_TOP.u_pinmux.pad_d2a_trim6_sig[5:0];
    assign pinmux_vif.d2a_trim7_reg = `DIG_TOP.u_pinmux.pad_d2a_trim7_sig[5:0];

initial begin
    nnc_config_db#(virtual nnc_pinmux_interface)::set(uvm_root::get(), "uvm_test_top.*", "pinmux_vif", pinmux_vif);
end    
