/*--------------------------------------------------------------------------------------*/
/*      Nanochap Confidential                                                           */
/*--------------------------------------------------------------------------------------*/
/* File Name	 : otp_trim_if.v                                                        */
/* Project	 : ENS1P4 Chip                                                          */
/* Designer	 : zhen                                                                 */
/* Description	 : the interface of spi and otp                                         */
/* Date		 : 1/4/2024                                                             */
/*--------------------------------------------------------------------------------------*/
/* Revision History :                                                                   */    
/* Data         Rev.     By             Description                                     */
/*--------------------------------------------------------------------------------------*/
/* 9/1/2024     1     zhen              the interface of spi and otp                    */
/*--------------------------------------------------------------------------------------*/

module otp_trim_if#(
parameter NO_SPI_REGS = 3,
parameter NO_OF_TRIM  = 17,
parameter ATM_MDOE    = 5,
parameter ATM_DATA    = 12
)(

 input wire                  clk,  
 input wire                  rst_n, 
 output wire [7:0]           spi_regs[NO_SPI_REGS-1:0],
 output wire [7:0]           def_regs[NO_SPI_REGS-1:0],
 input wire  [7:0]           shadow_regs[NO_SPI_REGS-1:0],

 input wire        unlock,  
input wire         spi_wr,
input wire         spi_wr_data,
input wire         spi_rd_data,
input wire  [7:0] spi_to_otp_trim[NO_OF_TRIM-1:0],


////ATM 
 input wire                 analog_test_mode,
 input wire  [ATM_MDOE-1:0] atm_mode,
 input wire  [ATM_DATA-1:0] atm_data,
 input wire                 unlock_gpio,

 output  wire       unlock_sync,
 output  wire       spi_wr_sync,
 output  wire       spi_wr_data_sync,
 output  wire       spi_rd_data_sync,
 output  wire       atm_unlock_sync,
 output  wire       analog_test_mode_sync,
 output  wire  [ATM_MDOE-1:0] atm_mode_sync,
 output  wire  [ATM_DATA-1:0] atm_data_sync,

 output  wire [7:0] otp_to_ana_trim[NO_OF_TRIM-1:0] 





);



common_sync_bit u_unlock_sync(
       .clk(clk),
       .rst_(rst_n),
       .async_in(unlock),
       .sync_out(unlock_sync)
);

common_sync_bit u_spi_wr_sync(
       .clk(clk),
       .rst_(rst_n),
       .async_in(spi_wr),
       .sync_out(spi_wr_sync)
);

common_sync_bit u_spi_wr_data_sync(
       .clk(clk),
       .rst_(rst_n),
       .async_in(spi_wr_data),
       .sync_out(spi_wr_data_sync)
);

common_sync_bit u_spi_rd_data_sync(
       .clk(clk),
       .rst_(rst_n),
       .async_in(spi_rd_data),
       .sync_out(spi_rd_data_sync)
);

common_sync_bit u_unlock_gpio_sync(
       .clk(clk),
       .rst_(rst_n),
       .async_in(unlock_gpio),
       .sync_out(atm_unlock_sync)
);

common_sync_bit u_analog_test_mode_sync(
       .clk(clk),
       .rst_(rst_n),
       .async_in(analog_test_mode),
       .sync_out(analog_test_mode_sync)
);

//common_sync_bit u_atm_mode_sync[ATM_MDOE-1:0](
//       .clk(clk),
//       .rst_(rst_n),
//       .async_in(atm_mode),
//       .sync_out(atm_mode_sync)
//);
assign atm_mode_sync = atm_mode;
//common_sync_bit u_atm_data_sync[ATM_DATA-1:0](
//       .clk(clk),
//       .rst_(rst_n),
//       .async_in(atm_data),
//       .sync_out(atm_data_sync)
//);
assign atm_data_sync = atm_data;
//common_sync_bit u_spi_to_otp_trim_tag_sync[7:0](
//       .clk(clk),
//       .rst_(rst_n),
//       .async_in(spi_to_otp_trim_tag),
//       .sync_out(spi_to_otp_trim_tag_sync)
//);


assign  spi_regs[0]     = spi_to_otp_trim[0];
assign  spi_regs[1]     = shadow_regs[1];
assign  spi_regs[2]     = shadow_regs[2];
assign  spi_regs[3]     = shadow_regs[3];

assign  spi_regs[4]     = spi_to_otp_trim[1]; 
assign  spi_regs[5]     = spi_to_otp_trim[2]; 
assign  spi_regs[6]     = spi_to_otp_trim[3]; 
assign  spi_regs[7]     = spi_to_otp_trim[4]; 
assign  spi_regs[8]     = spi_to_otp_trim[5];
assign  spi_regs[9]     = spi_to_otp_trim[6];
assign  spi_regs[10]    = spi_to_otp_trim[7];
assign  spi_regs[11]    = spi_to_otp_trim[8];

assign  spi_regs[12]    = spi_to_otp_trim[9];
assign  spi_regs[13]    = spi_to_otp_trim[10];
assign  spi_regs[14]    = spi_to_otp_trim[11];
assign  spi_regs[15]    = spi_to_otp_trim[12];
assign  spi_regs[16]    = spi_to_otp_trim[13];
assign  spi_regs[17]    = spi_to_otp_trim[14];
assign  spi_regs[18]    = spi_to_otp_trim[15];
assign  spi_regs[19]    = shadow_regs[19];






assign  otp_to_ana_trim[0]         = shadow_regs[0];
assign  otp_to_ana_trim[1]         = shadow_regs[4]; 
assign  otp_to_ana_trim[2]         = shadow_regs[5]; 
assign  otp_to_ana_trim[3]         = shadow_regs[6]; 
assign  otp_to_ana_trim[4]         = shadow_regs[7]; 
assign  otp_to_ana_trim[5]         = shadow_regs[8];
assign  otp_to_ana_trim[6]         = shadow_regs[9];
assign  otp_to_ana_trim[7]         = shadow_regs[10];
assign  otp_to_ana_trim[8]         = shadow_regs[11];
assign  otp_to_ana_trim[9]         = shadow_regs[12];

assign  otp_to_ana_trim[10]         = shadow_regs[13];
assign  otp_to_ana_trim[11]         = shadow_regs[14];
assign  otp_to_ana_trim[12]         = shadow_regs[15];
assign  otp_to_ana_trim[13]         = shadow_regs[16];
assign  otp_to_ana_trim[14]         = shadow_regs[17];
assign  otp_to_ana_trim[15]         = shadow_regs[18];
assign  otp_to_ana_trim[16]         = shadow_regs[19];




assign  def_regs[0]             = `DFAULT_TRIM_TAG;
assign  def_regs[1]             = 8'h00;
assign  def_regs[2]             = 8'h00;
assign  def_regs[3]             = 8'h00;
assign  def_regs[4]             = `DFAULT_TRIM0;
assign  def_regs[5]             = `DFAULT_TRIM1;
assign  def_regs[6]             = `DFAULT_TRIM2;
assign  def_regs[7]             = `DFAULT_TRIM3;
assign  def_regs[8]             = `DFAULT_TRIM4;
assign  def_regs[9]             = `DFAULT_TRIM5;
assign  def_regs[10]            = `DFAULT_TRIM6;
assign  def_regs[11]            = `DFAULT_TRIM7;
assign  def_regs[12]            = `DFAULT_TRIM8;

assign  def_regs[13]            = `DFAULT_TRIM9;
assign  def_regs[14]            = `DFAULT_TRIM10;
assign  def_regs[15]            = `DFAULT_TRIM11;
assign  def_regs[16]            = `DFAULT_TRIM12;
assign  def_regs[17]            = `DFAULT_TRIM13;
assign  def_regs[18]            = `DFAULT_TRIM14;
assign  def_regs[19]            = `DFAULT_TRIM15;


endmodule
