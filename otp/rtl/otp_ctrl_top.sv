/*--------------------------------------------------------------------------------------*/
/*      Nanochap Confidential                                                           */
/*--------------------------------------------------------------------------------------*/
/* File Name	 : OTP_ctrl_top.v                                                       */
/* Project	 : ENS1P4 Chip                                                          */
/* Designer	 : Zhen	                                                                */
/* Description	 : OTP controller top (wrapper)                                         */
/* Date		 : 1/4/2024                                                             */
/*--------------------------------------------------------------------------------------*/
/* Revision History :                                                                   */    
/* Data         Rev.     By             Description                                     */
/*--------------------------------------------------------------------------------------*/
/* 							                                */
/*--------------------------------------------------------------------------------------*/
//if you want to add/reduce the trim, just change the paramter NO_SPI_REGS,then
// add the signals in otp_trim_if.v
//
module otp_ctrl_top
#(parameter NO_SPI_REGS = 16, //this parameter should be  4*n, n is the number of otp addr [6:2] bits which using
  parameter ATM_MDOE    = 8,
  parameter NO_OF_WAVEGEN_OTP = 1,
  parameter ATM_DATA    = 8
)(
spi_otp.slave          spi_otp,

input                  	clk,  
input                   rst_n, 
input                   por_resetn,
input			              atpg_en, 
input                  	VPP,
input                  	VDD,
input                  	VSUB,
input                  	VSS_OTP,
//input			unlock,
//input			spi_wr,
input wire  [2:0]       hosc_sel,

//vdd logic
//input wire              vpp_h_en, //vpp from vdd to 7.5
//input wire              vpp_l_en, //vpp from 7.5v to vdd
output wire		otp_vpp_en,//0-> 1: vpp from vdd to 7.5v, 1->0: vpp from 7.5v to vdd

////bist
 input	           test_en,
 input             TCK,
 input             RESETb,
 input             TDI,
 input             STROBE,
 output            TDO,
 output            serout,
 output            OEN,
 output            vpp_en,

////ATM 
 input wire                 analog_test_mode,
 input wire  [ATM_MDOE-1:0] atm_mode,
 input wire  [ATM_DATA-1:0] atm_data,
 input wire                 unlock_gpio



);


wire otp_rstn,por_resetn_temp,otp_rstn_tmp;

BUF_X2_A7TULL DNT_POR ( .A(por_resetn), .Y(por_resetn_temp));
AND2_X1_A7TULL DNT_OTP_RST ( .A(rst_n), .B(por_resetn_temp), .Y(otp_rstn_tmp));
MX2_X8_A7TULL DNT_OTP_RST_ATPG ( .A(otp_rstn_tmp), .B(rst_n), .S0(atpg_en), .Y(otp_rstn));



////interface/////
wire  [7:0] i_spi_to_otp_trim_tag;
wire  [7:0] i_spi_to_otp_trim1;
wire  [7:0] i_spi_to_otp_trim2;
wire  [7:0] i_spi_to_otp_trim3;
wire  [7:0] i_spi_to_otp_trim4;
wire  [7:0] i_spi_to_otp_trim5;
wire  [7:0] i_spi_to_otp_trim6;
wire  [7:0] i_spi_to_otp_trim7;
wire  [7:0] i_spi_to_otp_trim8;
wire  [7:0] i_spi_to_otp_trim9;
//wire  [7:0] i_spi_to_otp_trim10;
//wire  [7:0] i_spi_to_otp_trim11;
//wire  [7:0] i_spi_to_otp_trim12;

wire  [7:0] otp_to_ana_trim0;
wire  [7:0] otp_to_ana_trim1;
wire  [7:0] otp_to_ana_trim2;
wire  [7:0] otp_to_ana_trim3;
wire  [7:0] otp_to_ana_trim4;
wire  [7:0] otp_to_ana_trim5;
wire  [7:0] otp_to_ana_trim6;
wire  [7:0] otp_to_ana_trim7;
wire  [7:0] otp_to_ana_trim8;
wire  [7:0] otp_to_ana_trim9;
//wire  [7:0] otp_to_ana_trim10;
//wire  [7:0] otp_to_ana_trim11;
//wire  [7:0] otp_to_ana_trim12;




assign  i_spi_to_otp_trim_tag = spi_otp.trim[0];
assign  i_spi_to_otp_trim1    = spi_otp.trim[1];
assign  i_spi_to_otp_trim2    = spi_otp.trim[2];
assign  i_spi_to_otp_trim3    = spi_otp.trim[3];
assign  i_spi_to_otp_trim4    = spi_otp.trim[4];
assign  i_spi_to_otp_trim5    = spi_otp.trim[5];
assign  i_spi_to_otp_trim6    = spi_otp.trim[6];
assign  i_spi_to_otp_trim7    = spi_otp.trim[7];
assign  i_spi_to_otp_trim8    = spi_otp.trim[8];
assign  i_spi_to_otp_trim9    = spi_otp.trim[9];
//assign  i_spi_to_otp_trim10   = spi_otp.trim[10];
//assign  i_spi_to_otp_trim11   = spi_otp.trim[11];
//assign  i_spi_to_otp_trim12   = spi_otp.trim[12];


assign spi_otp.trim_read[0]   = otp_to_ana_trim0;
assign spi_otp.trim_read[1]   = otp_to_ana_trim1;
assign spi_otp.trim_read[2]   = otp_to_ana_trim2;
assign spi_otp.trim_read[3]   = otp_to_ana_trim3;
assign spi_otp.trim_read[4]   = otp_to_ana_trim4;
assign spi_otp.trim_read[5]   = otp_to_ana_trim5;
assign spi_otp.trim_read[6]   = otp_to_ana_trim6;
assign spi_otp.trim_read[7]   = otp_to_ana_trim7;
assign spi_otp.trim_read[8]   = otp_to_ana_trim8;
assign spi_otp.trim_read[9]   = otp_to_ana_trim9;
//assign spi_otp.trim_read[10]  = otp_to_ana_trim10;
//assign spi_otp.trim_read[11]  = otp_to_ana_trim11;
//assign spi_otp.trim_read[12]  = otp_to_ana_trim12;


wire unlock,spi_wr,spi_wr_data,spi_rd_data;
wire [7:0]  spi_otp_addr,spi_otp_data;
wire [2:0]  spi_otp_slct;  
wire  [2:0] BIST_OTP_OTP;

wire OTP_Reset_Done,loading_shadows;
wire [15:0] debug_reg;
wire    wr_working,wr_time;
wire [7:0] spi_data_read;

assign unlock       = spi_otp.so_ctrl[0];
assign spi_wr       = spi_otp.so_ctrl[1];
assign spi_wr_data  = spi_otp.so_ctrl[2];
assign spi_rd_data  = spi_otp.so_ctrl[3];
assign spi_otp_addr = spi_otp.so_ctrl[11:4];
assign spi_otp_data = spi_otp.so_ctrl[19:12];
assign spi_otp_slct = test_en? BIST_OTP_OTP :  spi_otp.so_ctrl[22:20] & {3{!loading_shadows}};//spi_otp.so_ctrl[19:12];


assign spi_otp.os_ctrl[0]     = OTP_Reset_Done;
assign spi_otp.os_ctrl[1]     = loading_shadows;
assign spi_otp.os_ctrl[17:2]  = debug_reg;
assign spi_otp.os_ctrl[18]    = wr_working || wr_time;
assign spi_otp.os_ctrl[26:19] = spi_data_read;

wire		otp_wr_enter;
wire		otp_READ;
wire		otp_WR;
wire  [6:0]    	otp_ADR;
wire  [7:0]    	otp_DIN;
wire  [31:0]    otp_DOUT;
wire 		otp_inf_epm_blk_rd_set_en;
wire  [6:0]     otp_inf_epm_adr;
wire  [6:0]     otp_inf_epm_adr_temp;
wire            wr_enter_h_en;
wire            wr_enter_l_en;
wire            wr_vpp_l_en;
wire            read_h_en;
wire            read_l_en;
wire            wr_h_en;
wire            wr_l_en;

wire  [12:0]    otp_tRD;
wire  [12:0]    otp_tPGM;
wire  [12:0]    otp_tPGM_rec;
wire  [12:0]    otp_tVPP;


wire 		otp_en;
wire            addr_valid;
wire		otp_inf_epm_rw;
wire		otp_inf_epm_blk_wd_set_en;
wire            otp_inf_epm_blk_addr_set_en;         
wire                 BIST_OTP_wr_enter;
wire                 BIST_OTP_READ;
wire                 BIST_OTP_WR  ;
wire  [6:0]          BIST_OTP_ADR ;
wire  [1:0]          BIST_OTP_MRGN;
wire  [7:0]          BIST_OTP_DIN ;
wire  [31:0]         BIST_OTP_DQ  ;



wire		unlock_sync;
wire            spi_wr_sync;
wire            spi_wr_data_sync;
wire            spi_rd_data_sync;
wire            atm_unlock_sync;
wire            analog_test_mode_sync;
wire  [ATM_MDOE-1:0] atm_mode_sync;
wire  [ATM_DATA-1:0] atm_data_sync;

wire		[7:0] spi_regs [NO_SPI_REGS-1:0];
wire		[7:0] def_regs [NO_SPI_REGS-1:0];
wire		[7:0] shadow_regs [NO_SPI_REGS-1:0];

wire                 otp_IP_wr_enter    ;
wire                 otp_IP_READ  ;
wire                 otp_IP_WR    ;
wire  [6:0]          otp_IP_ADR   ;
wire  [1:0]          otp_IP_PTM  ;
wire  [7:0]          otp_IP_DIN   ;
wire  [31:0]         otp_DOUT_temp;
wire  [31:0]         otp_DOUT_temp_0;

wire  [31:0]         otp_bist_DOUT;
wire  [7:0]          spi_data_to_otp;
wire  [7:0]          spi_data_to_otp_temp;
wire  [6:0]          addr_trim;
//wire [15:0] debug_reg;
wire  [6:0]          otp_IP_ADR_wavgen[NO_OF_WAVEGEN_OTP-1:0];
wire  [31:0]         otp_DOUT_temp_wavgen[NO_OF_WAVEGEN_OTP-1:0];
wire  [1:0]          otp_IP_PTM_wavgen[NO_OF_WAVEGEN_OTP-1:0]  ;
wire  [7:0]          otp_IP_DIN_wavgen[NO_OF_WAVEGEN_OTP-1:0]   ;
wire                 otp_IP_wr_enter_wavgen[NO_OF_WAVEGEN_OTP-1:0]    ;
wire                 otp_IP_READ_wavgen[NO_OF_WAVEGEN_OTP-1:0]  ;
wire                 otp_IP_WR_wavgen[NO_OF_WAVEGEN_OTP-1:0]    ;

wire  [32*NO_OF_WAVEGEN_OTP+31:0] otp_DOUT_temp_wavgen_temp;

wire reload_done;

assign debug_reg[15:9] = 7'h0; 
assign debug_reg[8]    = otp_vpp_en; 
assign debug_reg[7]    = loading_shadows;
assign debug_reg[6]    = wr_working;
assign debug_reg[5]    = reload_done;
assign debug_reg[4]    = otp_IP_wr_enter;      
assign debug_reg[3]    = otp_IP_READ;    
assign debug_reg[2]    = otp_IP_WR;      
assign debug_reg[1:0]  = otp_IP_PTM;

assign spi_data_to_otp_temp = spi_wr_data_sync? ~spi_data_to_otp :  otp_DIN;
wire test_en_inv;
assign test_en_inv = ~test_en;

assign  otp_IP_wr_enter = atpg_en ? 1'b0 : test_en & BIST_OTP_wr_enter |   test_en_inv  & otp_wr_enter;
assign  otp_IP_READ     = atpg_en ? 1'b0 : (|spi_otp_slct)? 1'b0 : test_en & BIST_OTP_READ     |   test_en_inv  & otp_READ;
assign  otp_IP_WR       = atpg_en ? 1'b0 : (|spi_otp_slct)? 1'b0 : test_en & BIST_OTP_WR       |   test_en_inv  & otp_WR    ;
assign  otp_IP_ADR      = atpg_en ? 7'b0 : (|spi_otp_slct)? 7'b0 :  {7{test_en}} & BIST_OTP_ADR     |   {7{test_en_inv}} & otp_ADR   ;
assign  otp_IP_PTM      = atpg_en ? 2'b0 : (|spi_otp_slct)? 2'b0 :  {2{test_en}} & BIST_OTP_MRGN    |    2'b0      ;
assign  otp_IP_DIN      = atpg_en ? 8'b0 : (|spi_otp_slct)? 8'b0 :  {8{test_en}} & BIST_OTP_DIN     |   {8{test_en_inv}} & spi_data_to_otp_temp;

assign OTP_Reset_Done		= reload_done;

assign otp_bist_DOUT   = atpg_en ? {12'hb0,otp_IP_READ,otp_IP_wr_enter,otp_IP_WR,otp_IP_ADR,otp_IP_PTM,otp_DIN} : test_en ? otp_DOUT_temp : 32'h0;
assign otp_DOUT        = atpg_en ? {12'hb0,otp_IP_READ,otp_IP_wr_enter,otp_IP_WR,otp_IP_ADR,otp_IP_PTM,otp_DIN} : test_en ? 32'h0 : otp_DOUT_temp;
assign otp_inf_epm_adr = otp_inf_epm_adr_temp;

otp_trim_if #(
.NO_SPI_REGS(NO_SPI_REGS),
.ATM_MDOE(ATM_MDOE),
.ATM_DATA(ATM_DATA)
)u_otp_trim_if(
.rst_n 	           (otp_rstn),
.clk 	           (clk),
.spi_regs          (spi_regs),
.def_regs          (def_regs),
.shadow_regs       (shadow_regs),
.otp_to_ana_trim0  (otp_to_ana_trim0), 
.otp_to_ana_trim1  (otp_to_ana_trim1), 
.otp_to_ana_trim2  (otp_to_ana_trim2),
.otp_to_ana_trim3  (otp_to_ana_trim3),
.otp_to_ana_trim4  (otp_to_ana_trim4),
.otp_to_ana_trim5  (otp_to_ana_trim5),
.otp_to_ana_trim6  (otp_to_ana_trim6),
.otp_to_ana_trim7  (otp_to_ana_trim7),
.otp_to_ana_trim8  (otp_to_ana_trim8),
.otp_to_ana_trim9  (otp_to_ana_trim9),
//.otp_to_ana_trim10 (otp_to_ana_trim10),
//.otp_to_ana_trim11 (otp_to_ana_trim11),
//.otp_to_ana_trim12 (otp_to_ana_trim12),
.unlock            (unlock),
.unlock_sync       (unlock_sync),
.spi_wr            (spi_wr),
.spi_wr_sync       (spi_wr_sync),
.spi_wr_data       (spi_wr_data),
.spi_wr_data_sync  (spi_wr_data_sync),
.spi_rd_data       (spi_rd_data),
.spi_rd_data_sync  (spi_rd_data_sync),
.atm_unlock_sync   (atm_unlock_sync),
.analog_test_mode_sync  (analog_test_mode_sync),
.atm_mode_sync          (atm_mode_sync),
.atm_data_sync          (atm_data_sync),
.analog_test_mode  (analog_test_mode),
.atm_mode          (atm_mode),
.atm_data          (atm_data),
.unlock_gpio       (unlock_gpio),
.spi_to_otp_trim_tag(i_spi_to_otp_trim_tag),
.spi_to_otp_trim1(i_spi_to_otp_trim1),
.spi_to_otp_trim2(i_spi_to_otp_trim2),
.spi_to_otp_trim3(i_spi_to_otp_trim3),
.spi_to_otp_trim4(i_spi_to_otp_trim4),
.spi_to_otp_trim5(i_spi_to_otp_trim5),
.spi_to_otp_trim6(i_spi_to_otp_trim6),
.spi_to_otp_trim7(i_spi_to_otp_trim7),
.spi_to_otp_trim8(i_spi_to_otp_trim8),
.spi_to_otp_trim9(i_spi_to_otp_trim9)
//.spi_to_otp_trim10(i_spi_to_otp_trim10),
//.spi_to_otp_trim11(i_spi_to_otp_trim11)
//.spi_to_otp_trim12(i_spi_to_otp_trim12)

);



eprom_bist_top u_eprom_bist_top (


.TCK   (TCK), 
.RESETb(RESETb), 
.TDI   (TDI), 
.TESTEN(test_en), 
.STROBE(STROBE), 
.TDO   (TDO), 
.serout(serout), 
.OEN   (OEN), 
.vpp_en (vpp_en),

.o_BIST_EPROM_XENTER   (BIST_OTP_wr_enter), 
.o_BIST_EPROM_XREAD (BIST_OTP_READ), 
.o_BIST_EPROM_XTM   (BIST_OTP_MRGN), 
.o_BIST_EPROM_PGM   (BIST_OTP_WR), 
.o_BIST_EPROM_XA    (BIST_OTP_ADR), 
.o_BIST_EPROM_XDIN  (BIST_OTP_DIN), 
.o_BIST_EPROM_OTP   (BIST_OTP_OTP),
//.o_BIST_EPROM_SEL   (BIST_EPROM_SEL), 
.i_BIST_EPROM_DQ    (otp_bist_DOUT)
);


otp_regs #(
.NO_SPI_REGS(NO_SPI_REGS),
.ATM_MDOE(ATM_MDOE),
.ATM_DATA(ATM_DATA)

)
u_otp_regs (
.rst_n 				(otp_rstn),
.clk 				(clk),
.otp_inf_epm_blk_addr_set_en    (otp_inf_epm_blk_addr_set_en),
.otp_inf_epm_blk_rd_set_en 	(otp_inf_epm_blk_rd_set_en),
.otp_inf_epm_blk_wd_set_en 	(otp_inf_epm_blk_wd_set_en),
.unlock 			(unlock_sync),
.spi_wr                         (spi_wr_sync),
.spi_wr_data                    (spi_wr_data_sync),
.spi_rd_data                    (spi_rd_data_sync),
.atm_unlock                     (atm_unlock_sync),
.analog_test_mode_sync          (analog_test_mode_sync),
.atm_mode_sync                  (atm_mode_sync),
.atm_data_sync                  (atm_data_sync),
.spi_regs 			(spi_regs),
.def_regs                       (def_regs),
.shadow_regs			(shadow_regs),
.otp_dout 			(otp_DOUT),
.otp_addr 			(otp_inf_epm_adr_temp),
.addr_trim                      (addr_trim),
.otp_en 			(otp_en),
.spi_otp_addr                   (spi_otp_addr),
.spi_otp_data                   (spi_otp_data),
.spi_data_read                  (spi_data_read),
.spi_data_to_otp                (spi_data_to_otp),
.addr_valid                     (addr_valid),
.otp_inf_epm_rw 		(otp_inf_epm_rw),
.reload_done                    (reload_done),
.wr_working                     (wr_working),
.wr_time                        (wr_time),
.loading_shadows		(loading_shadows)
);


otp_clkcnt u_otp_clkcnt(

.hosc_sel(hosc_sel),
.otp_tRD(otp_tRD),
.otp_tPGM(otp_tPGM),
.otp_tVPP(otp_tVPP),
.otp_tPGM_rec(otp_tPGM_rec)

);



otp_rw_ctrl u_otp_rw_ctrl  (
.clk                         	(clk),
.reset_n                     	(otp_rstn),
//.atpg_en			(atpg_en),
.otp_tRD                        (otp_tRD),
.otp_tPGM                       (otp_tPGM),
.otp_tPGM_rec                   (otp_tPGM_rec),
.otp_tVPP                       (otp_tVPP),
.otp_en               	        (otp_en),
.addr_valid                     (addr_valid),
.otp_inf_epm_rw                 (otp_inf_epm_rw),
.wr_enter_h_en                  (wr_enter_h_en),
.wr_enter_l_en                  (wr_enter_l_en),
.wr_vpp_l_en                    (wr_vpp_l_en),
//.vpp_h_en                       (vpp_h_en),
//.vpp_l_en                       (vpp_l_en),
.read_h_en                   	(read_h_en),
.read_l_en                   	(read_l_en),
.wr_h_en                     	(wr_h_en),
.wr_l_en                     	(wr_l_en),
.wr_working                     (wr_working),
.otp_inf_epm_blk_addr_set_en    (otp_inf_epm_blk_addr_set_en),
.otp_inf_epm_blk_rd_set_en      (otp_inf_epm_blk_rd_set_en),
.otp_inf_epm_blk_wd_set_en      (otp_inf_epm_blk_wd_set_en)
);

otp_out_ctrl u_otp_out_ctrl (	
.clk                      (clk),
.reset_n                  (otp_rstn),
.wr_enter_h_en            (wr_enter_h_en),
.wr_enter_l_en            (wr_enter_l_en),
.wr_vpp_l_en              (wr_vpp_l_en),

.read_h_en                (read_h_en),
.read_l_en                (read_l_en),
.wr_h_en                  (wr_h_en),
.wr_l_en                  (wr_l_en),
.otp_inf_epm_adr          (otp_inf_epm_adr),
.otp_inf_spi_wdata        (spi_regs[addr_trim]),
.otp_inf_sha_wdata        (shadow_regs[addr_trim]),
.analog_test_mode_sync    (analog_test_mode_sync),
.otp_wr_enter             (otp_wr_enter),
.otp_vpp_en               (otp_vpp_en),
.otp_READ	          (otp_READ),
.otp_WR                   (otp_WR),
.otp_ADR                  (otp_ADR),
.otp_DIN                  (otp_DIN)
);

assign otp_DOUT_temp = otp_DOUT_temp_wavgen_temp >> spi_otp_slct*32;

assign otp_DOUT_temp_wavgen_temp[31 : 0] = {32{!(|spi_otp_slct)}} & otp_DOUT_temp_0;


EO32X32GCT2Q_H3_PA u_EO32X32GCT2Q_H3 (
.PA(otp_IP_ADR),
.PDIN(otp_IP_DIN),
.PDOB(otp_DOUT_temp_0),
.PTM(otp_IP_PTM),
.PWE(otp_IP_WR),
.PPROG(otp_IP_wr_enter),
.POR(otp_IP_READ),
.HV_VSS(VSUB),
.VDD(VDD),
.VSS(VSS_OTP),
.VPP(VPP) 
);

genvar i;
generate
   for (i=0;i<NO_OF_WAVEGEN_OTP;i++) begin : WAVEGEN_COEFFS

     assign otp_IP_ADR_wavgen[i]           = atpg_en ? 7'b0 : (spi_otp_slct!=(i+1))? 7'b0 :  {7{test_en}} & BIST_OTP_ADR     |   {7{test_en_inv}} & otp_ADR;
//     assign otp_IP_wr_enter_wavgen[i]      = atpg_en ? 1'b0 : (spi_otp_slct!=(i+1))? 1'b0 :  test_en & BIST_OTP_wr_enter     |   test_en_inv  & otp_wr_enter;
     assign otp_IP_READ_wavgen[i]          = atpg_en ? 1'b0 : (spi_otp_slct!=(i+1))? 1'b0 :  test_en & BIST_OTP_READ         |   test_en_inv  & otp_READ & !loading_shadows  ;
     assign otp_IP_WR_wavgen[i]            = atpg_en ? 1'b0 : (spi_otp_slct!=(i+1))? 1'b0 :  test_en & BIST_OTP_WR           |   test_en_inv  & otp_WR    ;
     assign otp_IP_PTM_wavgen[i]           = atpg_en ? 2'b0 : (spi_otp_slct!=(i+1))? 2'b0 :  {2{test_en}} & BIST_OTP_MRGN    |    2'b0      ;
     assign otp_IP_DIN_wavgen[i]           = atpg_en ? 8'b0 : (spi_otp_slct!=(i+1))? 8'b0 :  {8{test_en}} & BIST_OTP_DIN     |   {8{test_en_inv}} & spi_data_to_otp_temp;

     assign otp_DOUT_temp_wavgen_temp[i*32+63 : i*32+32]  =  {32{!(spi_otp_slct!=(i+1))}} & otp_DOUT_temp_wavgen[i];

     EO32X32GCT2Q_H3_PA u_EO32X32GCT2Q_H3_wavgen (
     .PA(otp_IP_ADR_wavgen[i]),
     .PDIN(otp_IP_DIN_wavgen[i]),
     .PDOB(otp_DOUT_temp_wavgen[i]),
     .PTM(otp_IP_PTM_wavgen[i]),
     .PWE(otp_IP_WR_wavgen[i]),
     .PPROG(otp_IP_wr_enter),//need to check again, report error when program trim otp
     .POR(otp_IP_READ_wavgen[i]),
     .HV_VSS(VSUB),
     .VDD(VDD),
     .VSS(VSS_OTP),
     .VPP(VPP) 
     );

   end
endgenerate


endmodule


