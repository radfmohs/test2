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
 input wire  [7:0] spi_to_otp_trim_tag,
 input wire  [7:0] spi_to_otp_trim1,
 input wire  [7:0] spi_to_otp_trim2,
 input wire  [7:0] spi_to_otp_trim3,
 input wire  [7:0] spi_to_otp_trim4,
 input wire  [7:0] spi_to_otp_trim5,
 input wire  [7:0] spi_to_otp_trim6,
 input wire  [7:0] spi_to_otp_trim7,
 input wire  [7:0] spi_to_otp_trim8,
 input wire  [7:0] spi_to_otp_trim9,
// input wire  [7:0] spi_to_otp_trim10,
// input wire  [7:0] spi_to_otp_trim11,
// input wire  [7:0] spi_to_otp_trim12,

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

 output  wire [7:0] otp_to_ana_trim0, 
 output  wire [7:0] otp_to_ana_trim1, 
 output  wire [7:0] otp_to_ana_trim2,
 output  wire [7:0] otp_to_ana_trim3,
 output  wire [7:0] otp_to_ana_trim4,
 output  wire [7:0] otp_to_ana_trim5,
 output  wire [7:0] otp_to_ana_trim6,
 output  wire [7:0] otp_to_ana_trim7,
 output  wire [7:0] otp_to_ana_trim8,
 output  wire [7:0] otp_to_ana_trim9
// output  wire [7:0] otp_to_ana_trim10,
// output  wire [7:0] otp_to_ana_trim11
// output  wire [7:0] otp_to_ana_trim12



);

wire [7:0] spi_to_otp_trim_tag_sync;
wire [7:0] spi_to_otp_trim1_sync;
wire [7:0] spi_to_otp_trim2_sync;
wire [7:0] spi_to_otp_trim3_sync;
wire [7:0] spi_to_otp_trim4_sync;
wire [7:0] spi_to_otp_trim5_sync;
wire [7:0] spi_to_otp_trim6_sync;
wire [7:0] spi_to_otp_trim7_sync;
wire [7:0] spi_to_otp_trim8_sync;
wire [7:0] spi_to_otp_trim9_sync;


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

assign spi_to_otp_trim_tag_sync = spi_to_otp_trim_tag;

//common_sync_bit u_spi_to_otp_trim1_sync[7:0](
//       .clk(clk),
//       .rst_(rst_n),
//       .async_in(spi_to_otp_trim1),
//       .sync_out(spi_to_otp_trim1_sync)
//);

//common_sync_bit u_spi_to_otp_trim2_sync[7:0](
//       .clk(clk),
//       .rst_(rst_n),
//       .async_in(spi_to_otp_trim2),
//       .sync_out(spi_to_otp_trim2_sync)
//);

//common_sync_bit u_spi_to_otp_trim3_sync[7:0](
//       .clk(clk),
//       .rst_(rst_n),
//       .async_in(spi_to_otp_trim3),
//       .sync_out(spi_to_otp_trim3_sync)
//);

//common_sync_bit u_spi_to_otp_trim4_sync[7:0](
//       .clk(clk),
//       .rst_(rst_n),
//       .async_in(spi_to_otp_trim4),
//       .sync_out(spi_to_otp_trim4_sync)
//);

//common_sync_bit u_spi_to_otp_trim5_sync[7:0](
//       .clk(clk),
//       .rst_(rst_n),
//       .async_in(spi_to_otp_trim5),
//       .sync_out(spi_to_otp_trim5_sync)
//);

//common_sync_bit u_spi_to_otp_trim6_sync[7:0](
//       .clk(clk),
//       .rst_(rst_n),
//       .async_in(spi_to_otp_trim6),
//       .sync_out(spi_to_otp_trim6_sync)
//
//);

//common_sync_bit u_spi_to_otp_trim7_sync[7:0](
//       .clk(clk),
//       .rst_(rst_n),
//       .async_in(spi_to_otp_trim7),
//       .sync_out(spi_to_otp_trim7_sync)
//
//);

//common_sync_bit u_spi_to_otp_trim8_sync[7:0](
//       .clk(clk),
//       .rst_(rst_n),
//       .async_in(spi_to_otp_trim8),
//       .sync_out(spi_to_otp_trim8_sync)
//
//);

//common_sync_bit u_spi_to_otp_trim9_sync[7:0](
//       .clk(clk),
//       .rst_(rst_n),
//       .async_in(spi_to_otp_trim9),
//       .sync_out(spi_to_otp_trim9_sync)
//
//);
assign spi_to_otp_trim1_sync = spi_to_otp_trim1;
assign spi_to_otp_trim2_sync = spi_to_otp_trim2;
assign spi_to_otp_trim3_sync = spi_to_otp_trim3;
assign spi_to_otp_trim4_sync = spi_to_otp_trim4;
assign spi_to_otp_trim5_sync = spi_to_otp_trim5;
assign spi_to_otp_trim6_sync = spi_to_otp_trim6;
assign spi_to_otp_trim7_sync = spi_to_otp_trim7;
assign spi_to_otp_trim8_sync = spi_to_otp_trim8;
assign spi_to_otp_trim9_sync = spi_to_otp_trim9;


assign  spi_regs[0]     = spi_to_otp_trim_tag_sync;
assign  spi_regs[1]     = shadow_regs[1];
assign  spi_regs[2]     = shadow_regs[2];
assign  spi_regs[3]     = shadow_regs[3];

assign  spi_regs[4]     = spi_to_otp_trim1_sync; 
assign  spi_regs[5]     = spi_to_otp_trim2_sync; 
assign  spi_regs[6]     = spi_to_otp_trim3_sync; 
assign  spi_regs[7]     = spi_to_otp_trim4_sync; 
assign  spi_regs[8]     = spi_to_otp_trim5_sync;
assign  spi_regs[9]     = spi_to_otp_trim6_sync;
assign  spi_regs[10]    = spi_to_otp_trim7_sync;
assign  spi_regs[11]    = spi_to_otp_trim8_sync;
assign  spi_regs[12]    = shadow_regs[12];
assign  spi_regs[13]    = shadow_regs[13];
assign  spi_regs[14]    = shadow_regs[14];
assign  spi_regs[15]    = shadow_regs[15];


assign  otp_to_ana_trim0         = shadow_regs[0];
assign  otp_to_ana_trim1         = shadow_regs[4]; 
assign  otp_to_ana_trim2         = shadow_regs[5]; 
assign  otp_to_ana_trim3         = shadow_regs[6]; 
assign  otp_to_ana_trim4         = shadow_regs[7]; 
assign  otp_to_ana_trim5         = shadow_regs[8];
assign  otp_to_ana_trim6         = shadow_regs[9];
assign  otp_to_ana_trim7         = shadow_regs[10];
assign  otp_to_ana_trim8         = shadow_regs[11];
assign  otp_to_ana_trim9         = shadow_regs[12];
//assign  otp_to_ana_trim10        = shadow_regs[13];
//assign  otp_to_ana_trim11        = shadow_regs[14];
//assign  otp_to_ana_trim12        = shadow_regs[15];


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
assign  def_regs[13]            = 8'h00;
assign  def_regs[14]            = 8'h00;
assign  def_regs[15]            = 8'h00;

/*
reg trim_lock;
always@(posedge clk or negedge rst_n)begin
  if(!rst_n) begin
     otp_to_ana_trim0 <= 8'h5a;
     otp_to_ana_trim1 <= 8'h10;
     otp_to_ana_trim2 <= 8'h40;
     otp_to_ana_trim3 <= 8'h10;
     otp_to_ana_trim4 <= 8'h40;
     otp_to_ana_trim5 <= 8'h02;
     otp_to_ana_trim6 <= 8'h02;
     trim_lock        <= 1'b1;
  end
  else if(reload_done && trim_lock) begin
     otp_to_ana_trim0      <= shadow_regs[0];
//     otp_to_ana_trim0      <= shadow_regs[1];
//     otp_to_ana_trim0      <= shadow_regs[2];
//     otp_to_ana_trim0      <= shadow_regs[3];

     otp_to_ana_trim1      <= shadow_regs[4]; 
     otp_to_ana_trim2      <= shadow_regs[5]; 
     otp_to_ana_trim3      <= shadow_regs[6]; 
     otp_to_ana_trim4      <= shadow_regs[7]; 
     otp_to_ana_trim5      <= shadow_regs[8];
     otp_to_ana_trim6      <= shadow_regs[9];
     trim_lock             <= 1'b0;
  end  
  else begin //??//
     otp_to_ana_trim0      <= trim_tag_en_sync? spi_to_otp_trim_tag_sync : otp_to_ana_trim0;
     otp_to_ana_trim1      <= trim1_en_sync   ? spi_to_otp_trim1_sync    : otp_to_ana_trim1;
     otp_to_ana_trim2      <= trim2_en_sync   ? spi_to_otp_trim2_sync    : otp_to_ana_trim2;
     otp_to_ana_trim3      <= trim3_en_sync   ? spi_to_otp_trim3_sync    : otp_to_ana_trim3;
     otp_to_ana_trim4      <= trim4_en_sync   ? spi_to_otp_trim4_sync    : otp_to_ana_trim4;
     otp_to_ana_trim5      <= trim5_en_sync   ? spi_to_otp_trim5_sync    : otp_to_ana_trim5;	  
     otp_to_ana_trim6      <= trim6_en_sync   ? spi_to_otp_trim6_sync    : otp_to_ana_trim6;
  end

end
*/
endmodule
