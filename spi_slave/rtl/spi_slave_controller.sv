//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//
// Module Name : spi
// Description : spi slave controller 
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author
//------------------------------------------------------------------------------
// 0.1          5/08/2021  Jayanthi 
// Initial Rev
//------------------------------------------------------------------------------
//slave samples at posedge of sclk and changes data at posedge of sclk. master has to place the data at posdeg of master clk and samples on posedge of master clk)
//supported mode  general cpol=0,cpha=0, data latch and sample at same as master posdeg of sclk and master clk
//master equavalent is cpol=0,cpha=1(master won't work, it can't latch the data)

`timescale 1ns/1ps

module spi_slave_controller (
i_rst_n          ,
i_sclk           ,
i_sclk_neg       ,
//atpg_e	 ,
i_cs_n           ,
i_channel_max    ,       
i_mosi           ,
i_status_words   ,
cpha             ,
daisy_en         ,
daisy_in         ,
o_addr           ,
o_wr             ,
o_rd             ,
wavegen_cmd_reg  ,
o_wavegen_wr     ,
o_wavegen_rd     ,
o_wr_data        ,
i_rd_data        ,
o_miso           ,
o_imeas_intr_clr ,     
mode             ,
imeas_chdata
);

parameter data_width = 8;
parameter addr_width = 8;

//Port declarations
input                   i_rst_n;
input                   i_sclk;
input                   i_sclk_neg;
//input                 atpg_en;
input                   i_cs_n;
input                   i_mosi;
input [data_width-1:0]  i_rd_data;
input   wire [31:0]     imeas_chdata[15:0];
input   wire [4:0]      i_channel_max;
input   wire            daisy_in;
input   wire            daisy_en;
input   wire [1:0]      mode;
input wire              cpha;
input  wire  [39:0]     i_status_words;

output reg              o_wr;
output reg              o_rd;
output reg              wavegen_cmd_reg;
output reg              o_wavegen_wr;
output reg              o_wavegen_rd;
output reg [data_width-1:0] o_wr_data;
output reg [addr_width-1:0] o_addr;
output wire             o_miso;
output wire             o_imeas_intr_clr;

//output reg            o_addr_vld_for_int_clr;
//output reg            burst_cmd_reg;
//output reg [addr_width-1:0] o_pre_addr;

reg                     burst_cmd_reg;
reg [addr_width-1:0]    o_pre_addr;

reg [data_width-1:0]    rx_buf ;
reg [data_width-1:0]    tx_buf ;
reg [5:0]               bit_cnt;
reg                     tx_d,cs_n_d;
reg                     rd_data_rdy;
reg                     cmd_reg,i_mosi_d;
reg                     latch_state,latch_state_d;
reg                     rdata_cmd;
reg                     rdatac_cmd;
reg                     dff_miso;
wire                    cov_int_clr;
reg [7:0]               tx_buf_tmp;
reg [2:0]               byte_bit_count;
wire                    cov_done;
wire [1:0]              adc_inc_val;
wire [2:0]              chdata_size;
wire [2:0]              num_status_byte;
wire                    status_done;
wire                    detect_first_bit;
wire                    comb_miso;
reg                     detect_first_bit_sync;
wire                    detect_flag;
reg [7:0]               imeas_temp;
reg [1:0]               byte_cnt_tmp;
reg [6:0]               byte_cnt; // max is 63
reg [7:0]               status_temp;
reg [7:0]               buffer [68:0];
reg                     next_dev_valid; // max is 15

wire [7:0]              status_5th_byte;
wire [7:0]              status_4th_byte;
wire [7:0]              status_3rd_byte;
wire [7:0]              status_2nd_byte;
wire [7:0]              status_1st_byte;

wire [7:0]              imeas_4th_byte;
wire [7:0]              imeas_3rd_byte;
wire [7:0]              imeas_2nd_byte;
wire [7:0]              imeas_1st_byte;

wire [2:0] mul_val;

// chip select latch
//assign i_status_words = 40'hAABBCCDDEE;

//always@(posedge i_sclk, negedge i_rst_n) begin
/*always@(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
    tx_buf_tmp <= 0;
  end else if (cs_n_d == 1'b1) begin
    tx_buf_tmp <= 0;
  end else if(bit_cnt ==6'h02) begin
    tx_buf_tmp <= 0;
  end else if (bit_cnt > 6'h8 && byte_bit_count==3'h0 && cov_done==1'b1) begin
    tx_buf_tmp <= (!mode[1] && !status_done) ? {status_temp[data_width-2:0],1'b0} : {imeas_temp[data_width-2:0],1'b0};
  end else begin
    tx_buf_tmp <= tx_buf_tmp;
  end 
end */

//always@(posedge i_sclk or negedge i_rst_n)           //include reset
always@(posedge i_sclk_neg, negedge i_rst_n) 
 begin
   if(!i_rst_n)
    cs_n_d <= 1;   //active low
   else
    cs_n_d <= i_cs_n;
 end

// mosi latch
//always@(posedge i_sclk or negedge i_rst_n)            //include reset
always@(posedge i_sclk_neg, negedge i_rst_n) 
  begin
   if(!i_rst_n)
   // i_mosi_d <=1'bz;
    i_mosi_d <=1'b0;
   else
    i_mosi_d <= i_mosi;
  end

//always@(posedge i_sclk , negedge i_rst_n) begin
always@(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
    rx_buf <= {data_width{1'b0}};
  end 
 else if (cs_n_d == 1'b1) begin
    rx_buf <= {data_width{1'b0}};
  end 
 else begin
   rx_buf <= {rx_buf[data_width-2:0],i_mosi_d};
  end
end

//bit cnt logic
wire bit_cnt_reset = i_rst_n & !i_cs_n;
//always@(posedge i_sclk or negedge bit_cnt_reset)begin //or negedge i_cs_n)  begin // or negedge i_cs_n) begin
always@(posedge i_sclk_neg, negedge bit_cnt_reset) begin
 // if (!i_rst_n) begin
   if (!bit_cnt_reset) begin
    bit_cnt <= 0;
  end
  else if (i_cs_n)begin
    bit_cnt <= 0;
  end
// else if (cs_n_d == 1'b1) begin
//    bit_cnt <= 0;
//  end
 else begin  
// if ((bit_cnt ==6'h21 && 
//     imeas_cnt <= (rdata_cmd & imeas_cnt < max_cnt) ? imeas_cnt + 1 : 0;cmd_reg==1 ) || (bit_cnt == 6'h19 && cmd_reg==0))    // if number of bit in cmd is 24
 if ((bit_cnt ==6'h20 && cmd_reg==1 ) || (bit_cnt == 6'h18 && cmd_reg==0))    // if number of bit in cmd is 24
    bit_cnt <= bit_cnt;
   else
    bit_cnt <= bit_cnt + 1;
 end
end

//------ byte_done logic------------//
//always@(posedge i_sclk, negedge i_rst_n) begin
always@(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
   byte_bit_count <=3'b111;
  end
// else if(byte_bit_count==8'h00  || bit_cnt==6'h01) begin   //starts counting the bits of wr_data //|| bit_cnt ==6'h12 ||
  else if(bit_cnt==6'h00) begin   //starts counting the bits of wr_data //|| bit_cnt ==6'h12 ||
   byte_bit_count<= 3'b111;
  end
  else  begin
   byte_bit_count <=byte_bit_count-1;
  end
end

wire byte_done;
assign byte_done = (byte_bit_count==3'h0);

reg burst_mode;
//always@(posedge i_sclk, negedge i_rst_n) begin
always@(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
   burst_mode <=1'b0;
  end
 //else if(bit_cnt ==5'h02) begin
else if(bit_cnt ==6'h00) begin
   burst_mode <=1'b0;
  end
  // else if ((bit_cnt ==6'h21 &&  cmd_reg==1 ) || (bit_cnt == 5'h19 && cmd_reg==0)) begin
 else if ((bit_cnt ==6'h20 &&  cmd_reg==1 ) || (bit_cnt == 6'h18 && cmd_reg==0)) begin
   burst_mode <=1'b1;
  end
end

//-------------------address-------------//
//always@(posedge i_sclk or negedge i_rst_n) begin
always@(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
    o_addr   <= 0;
   // o_addr_vld_for_int_clr <=0;
    o_pre_addr <=0;
  end else if (bit_cnt == 6'h09 ) begin //original 8
    o_addr  <= rx_buf[addr_width-1:0];    
   // o_addr_vld_for_int_clr <=1; 
    o_pre_addr <= o_addr;
  end
    else if ((cmd_reg==1 && burst_cmd_reg && bit_cnt>6'h18 && byte_done )||(cmd_reg==0 && burst_cmd_reg &&  bit_cnt >6'h12 && byte_bit_count==3'h4))  begin
     o_addr   <= o_addr+1'B1; 
    // o_addr_vld_for_int_clr <=1;
     o_pre_addr <= o_addr;
   end
   else
    begin
    o_addr   <= o_addr;
   // o_addr_vld_for_int_clr <=0;
    o_pre_addr <= o_pre_addr;
   end
end

//-------------------Command type (RD/WR)-----------/
//always@(posedge i_sclk, negedge i_rst_n) begin
always@(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
    cmd_reg <= 1'b0;
  end else if (cs_n_d == 1'b1) begin
    cmd_reg <= 1'b0;
  end else if(bit_cnt == 6'h00) begin
    cmd_reg <= 1'b0;
 // end else if (bit_cnt == 6'h0b )begin        // 9th bit is the command bit(9+2 =11) 
  end else if (bit_cnt == 6'h0a )begin        // 9th bit is the command bit(9+1 =10) 
    cmd_reg <= rx_buf[0];            
  end
end

//-------------WAVEGEN_CMD---------------------//
//always@(posedge i_sclk, negedge i_rst_n) begin
always@(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
    wavegen_cmd_reg <= 1'b0;
  end else if (cs_n_d == 1'b1) begin
    wavegen_cmd_reg <= 1'b0;
 // end else if (bit_cnt == 6'h0c )begin        // 10th bit is the command bit(10+2=12) 
 end else if (bit_cnt == 6'h0b )begin        // 10th bit is the command bit(10+1=11) 
    wavegen_cmd_reg <= rx_buf[0];            
  end
end

//-------------Burst_CMD-------------------//
//always@(posedge i_sclk, negedge i_rst_n) begin
always@(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
    burst_cmd_reg <= 1'b0;
  end else if (cs_n_d == 1'b1) begin
    burst_cmd_reg <= 1'b0;
  end else if(bit_cnt == 6'h00) begin
   burst_cmd_reg <= 1'b0;
//  end else if (bit_cnt == 6'h0d )begin        // 11th bit is the command bit(11+2=13) 
 end else if (bit_cnt == 6'h0c )begin        // 11th bit is the command bit(11+1=12)
    burst_cmd_reg <= rx_buf[0];            
  end
end

// Thanh Huu added
//-------------RDATA_CMD------------------//
always@(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
    rdata_cmd <= 1'b0;
  end else if(cs_n_d == 1'b1) begin
    rdata_cmd <= 1'b0;
  end else if(bit_cnt == 6'h00) begin
    rdata_cmd <= 1'b0; 
  end else if(bit_cnt == 6'h0d) begin
    rdata_cmd <= rx_buf[0];
  end
end

always@(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
    rdatac_cmd <= 1'b0;
  end else if(cs_n_d == 1'b1) begin
    rdatac_cmd <= 1'b0;
  end else if(bit_cnt == 6'h00) begin
    rdatac_cmd <= 1'b0;
  end else if(bit_cnt == 6'h0e) begin
    rdatac_cmd <= rx_buf[0];
  end
end
// End of Thanh Huu added

//-----------------------wr_data logic--------------------/
//latch 
//always@(posedge i_sclk, negedge i_rst_n) begin
always@(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
    latch_state <= 1'b0;
 end else if (cs_n_d == 1'b1) begin
    latch_state <= 1'b0;
 end else if(bit_cnt==6'h0) begin
    latch_state <= 1'b0;
 //end else if (burst_mode ==1'b0 && bit_cnt ==6'h19 && cmd_reg==1 )begin // after receiving data1 is 7th bit
end else if (burst_mode ==1'b0 && bit_cnt ==6'h18 && cmd_reg==1 )begin // after receiving data1 is 7th bit
    latch_state <= 1'b1;
// end else if ( bit_cnt ==6'h21 && byte_bit_count==3'h0 && cmd_reg==1) begin //burst_mode==1'b1
 end else if ( bit_cnt ==6'h20 && byte_bit_count==3'h0 && cmd_reg==1) begin //burst_mode==1'b1
   latch_state <= 1'b1;
  end else begin
    latch_state <= 1'b0;
  end
end

//wr_data
//always@(posedge i_sclk, negedge i_rst_n) begin
always@(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
    o_wr_data <= 0;
  end else if (latch_state) begin
    o_wr_data <= rx_buf[data_width-1:0];
  end
end

// wr_enable
//always@(posedge i_sclk, negedge i_rst_n) begin
always@(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
    o_wr <= 1'b0;
  end
 else if(bit_cnt ==6'h0)begin
    o_wr <=1'b0;
 end else if ((latch_state) && (cmd_reg == 1'b1) && !wavegen_cmd_reg) begin    //can be latch_state
    o_wr <= 1'b1;
  end else begin
    o_wr <= 1'b0;
  end
end

// wavegen wr_enable
//always@(posedge i_sclk, negedge i_rst_n) begin
always@(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
    o_wavegen_wr <= 1'b0;
  end
 else if(bit_cnt ==6'h0)begin
    o_wavegen_wr <=1'b0;
 end else if ((latch_state) && (cmd_reg == 1'b1) && wavegen_cmd_reg) begin    //can be latch_state
    o_wavegen_wr <= 1'b1;
  end else begin
    o_wavegen_wr <= 1'b0;
  end
end

// wr_enable
//always@(posedge i_sclk, negedge i_rst_n) begin
always@(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
    o_rd <= 1'b0;
  end
 else if(bit_cnt ==6'h0)begin
    o_rd <=1'b0;
 end else if ((bit_cnt ==6'h15) && (cmd_reg == 1'b0) && !wavegen_cmd_reg) begin    //can be latch_state
    o_rd <= 1'b1;
  end else begin
    o_rd <= 1'b0;
  end
end

// wavegen wr_enable
//always@(posedge i_sclk, negedge i_rst_n) begin
always@(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
    o_wavegen_rd <= 1'b0;
  end
 else if(bit_cnt ==6'h0)begin
    o_wavegen_rd <=1'b0;
 end else if ((bit_cnt ==6'h15) && (cmd_reg == 1'b0) && wavegen_cmd_reg) begin    //can be latch_state
    o_wavegen_rd <= 1'b1;
  end else begin
    o_wavegen_rd <= 1'b0;
  end
end

//-----------------------------mosi output------------------//

/*always@(posedge i_sclk, negedge i_rst_n) begin
  if (!i_rst_n) begin
      o_miso <= 1'b0;
  end else if (cs_n_d == 1'b1) begin
      o_miso <= 1'b0;
  end else if (cov_done == 1'b1) begin
      o_miso <= !mode[1] ? status_temp[7] : imeas_temp[7]; 
  end else if ((byte_cnt[6:0] == 6'h01) && (rd_data_rdy == 1) && (rdatac_cmd == 1'b1) && (bit_cnt == 6'h18) && (byte_done == 1'b0)) begin
      o_miso <= tx_buf_tmp[byte_bit_count]; 
  end else begin
    o_miso <= tx_d;
  end 
end */


always@(posedge i_sclk, negedge i_rst_n) begin
  if (!i_rst_n) begin
      dff_miso <= 1'b0;
  end else if (cs_n_d == 1'b1) begin
      dff_miso <= 1'b0;
  end else if ((cov_done == 1'b1) && (cpha != 1'b0)) begin
      dff_miso <= (!mode[1] && !next_dev_valid) ? status_temp[7] : imeas_temp[7]; 
  end else if ((byte_cnt[6:0] == 7'h01) && (rd_data_rdy == 1'b1) && (rdatac_cmd == 1'b1) && (bit_cnt == 6'h18) && (byte_done == 1'b0)) begin
      dff_miso <= !mode[1] ? status_5th_byte[byte_bit_count - 1] : imeas_4th_byte[byte_bit_count - 1]; 
  end else begin
      dff_miso <= tx_d;
  end 
end

assign comb_miso = (!mode[1] && !next_dev_valid) ? status_temp[7] : imeas_temp[7];

assign detect_flag = detect_first_bit && detect_first_bit_sync;

assign o_miso = detect_flag ? comb_miso : dff_miso;

assign detect_first_bit = cov_done && rdata_cmd && rdatac_cmd && (cpha == 1'b0);

always@(posedge i_sclk, negedge i_rst_n) begin
  if (!i_rst_n) begin
      detect_first_bit_sync <= 1'b0;
  end else if (cs_n_d == 1'b1) begin
      detect_first_bit_sync <= 1'b0;
  end else begin
    detect_first_bit_sync <= detect_first_bit;
  end 
end

//tx_d
//always@(posedge i_sclk, negedge i_rst_n) begin
always@(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
    tx_d <= 1'b0;
  end else if (cs_n_d == 1'b1) begin
    tx_d <= 1'b0;
   end else if (rd_data_rdy == 1) begin
     tx_d <= tx_buf[data_width-1];
  end else begin
    tx_d <= rx_buf[5]; // just send what is received //original 2  
 end
end

//rd_data_rdy
//always@(posedge i_sclk, negedge i_rst_n) begin
always@(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
    rd_data_rdy <= 1'b0;
  end else if (cs_n_d == 1'b1) begin
     rd_data_rdy <= 1'b0;
  end else if (bit_cnt ==6'h4 ) begin  // bit_cnt == 2) begin   //when sampling the cmd instruction 2
    rd_data_rdy <= 1'b0; 
 end else if (bit_cnt > 6'h8 && byte_bit_count==3'h2 && cmd_reg == 1'b0) begin // @ the end of the 2nd byte(cmd byte)
// end else if (bit_cnt > 6'h8 && byte_bit_count==3'h3 && cmd_reg == 1'b0) begin // @ the end of the 2nd byte(cmd byte)
    rd_data_rdy <= 1'b1;
  end
end

//always@(posedge i_sclk, negedge i_rst_n) begin
always@(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
    tx_buf <= 0;
  end else if (cs_n_d == 1'b1) begin
     tx_buf <= 0;
  end else if(bit_cnt ==6'h02) begin
     tx_buf <= 0;
   end else if (bit_cnt > 6'h8 && byte_bit_count==3'h2) begin // @ the end of the 2nd byte(cmd byte)
//  end else if (bit_cnt > 6'h8 && byte_bit_count==3'h3) begin // @ the end of the 2nd byte(cmd byte)
//     tx_buf <= rdata_cmd ? imeas_temp : i_rd_data; 
    tx_buf <= (!mode[1] && !status_done && rdata_cmd && !next_dev_valid) ? status_temp : rdata_cmd ? imeas_temp : i_rd_data;
  end else begin
     tx_buf <= {tx_buf[data_width-2:0],1'b0};
  end
end

// ------------------------------CONTROL SIGNAL---------------------------------//
assign adc_inc_val = mode[0] ? 2'b10 : 2'b11;
assign chdata_size = mode[0] ? 3'h3 : 3'h4;

always @(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
    byte_cnt <= 7'h0;
  end else if (cs_n_d == 1'b1) begin
    byte_cnt <= 7'h0;
  end else if (bit_cnt == 6'h0) begin
    byte_cnt <= 7'h0;
  end else if ((byte_done == 1'b1) && (rdata_cmd == 1'b1) && (byte_cnt == num_status_byte + i_channel_max * chdata_size[2:0] - 1) && !next_dev_valid) begin
    byte_cnt <= 7'h0;
  end else if ( bit_cnt < 6'h10 ) begin
    byte_cnt <= byte_cnt;
//  end else if ((byte_done == 1'b1) && (rdata_cmd == 1'b1) && (byte_cnt < num_status_byte + i_channel_max * chdata_size[2:0] - 1) && !next_dev_valid) begin
//    byte_cnt <= byte_cnt + 1;
  end else if ((byte_done == 1'b1) && (rdata_cmd == 1'b1)) begin
    byte_cnt <= byte_cnt + 1;
  end else begin 
    byte_cnt <= byte_cnt;
  end
end

always @(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
    byte_cnt_tmp <= 2'h0;
  end else if (cs_n_d == 1'b1) begin
    byte_cnt_tmp <= 2'h0;
  end else if (bit_cnt == 6'h0) begin
    byte_cnt_tmp <= 2'h0;
  end else if (!mode[1] && (byte_cnt < 7'h5 || ( byte_cnt == 7'h5 && !byte_done )) && !next_dev_valid) begin
    byte_cnt_tmp <= 2'h0;
  end else if ((byte_done == 1'b1) && (rdata_cmd == 1'b1) && (byte_cnt_tmp == adc_inc_val)) begin  // (byte_cnt == num_status_byte + i_channel_max * chdata_size[2:0] - 1) ||
    byte_cnt_tmp <= 2'h0;
  end else if ( bit_cnt < 6'h10 ) begin
    byte_cnt_tmp <= byte_cnt_tmp;
//  end else if ((byte_done == 1'b1) && (rdata_cmd == 1'b1) && (byte_cnt < num_status_byte + i_channel_max * chdata_size[2:0] - 1)) begin
//    byte_cnt_tmp <= byte_cnt_tmp + 1;
  end else if ((byte_done == 1'b1) && (rdata_cmd == 1'b1)) begin
    byte_cnt_tmp <= byte_cnt_tmp + 1;
  end else begin
    byte_cnt_tmp <= byte_cnt_tmp;
  end
end

// cov_done = 1 if byte_cnt == (i_channel_max * 4 - 1) -> keep 1 until
// first clock of SCK comes , only support for non-daisy (RDATAC mode is used
// for reading multiple convs of 1 chips. In this case, NSS is always asserted
// when reading many conversions.
// When daisy_en, always use RDATA to read each of conv from multiple chips).
// It means NSS will be de-asserted after conv is done 

//reg cov_done;
reg cov_done_d1;

assign cov_done = ((byte_done == 1'b1) && (rdata_cmd == 1'b1) && (rdatac_cmd == 1'b1) && (byte_cnt == 7'h00) && (bit_cnt == 6'h18));

always @(posedge i_sclk_neg, negedge i_rst_n) begin
   if (!i_rst_n) begin
    cov_done_d1 <= 1'b0;
  end else if (cs_n_d == 1'b1) begin
    cov_done_d1 <= 1'b0;
  end else begin
    cov_done_d1 <= cov_done;
  end
end

assign cov_int_clr = !cov_done && cov_done_d1;

reg [4:0] adc_cnt; // max is 15
always @(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
    adc_cnt <= 5'h0;
  end else if (cs_n_d == 1'b1) begin
    adc_cnt <= 5'h0;
  end else if (bit_cnt == 6'h0) begin
    adc_cnt <= 5'h0;
  end else if(next_dev_valid && (byte_cnt_tmp[1:0] == adc_inc_val) && byte_done && ((adc_cnt == 5'd16 && mul_val== 3'd4) || (adc_cnt == 5'd22 && mul_val== 3'd3))) begin
    adc_cnt <= 5'h0;
  end else if ((adc_cnt == i_channel_max - 1) && (byte_cnt_tmp[1:0] == adc_inc_val) && (byte_done == 1'b1) && (rdata_cmd == 1'b1) && !next_dev_valid) begin
    adc_cnt <= 5'h0; 
  end else if ((byte_cnt_tmp[1:0] == adc_inc_val) && (byte_done == 1'b1) && (rdata_cmd == 1'b1) && (adc_cnt < i_channel_max - 1) && !next_dev_valid) begin
    adc_cnt <= adc_cnt + 1;
  end else if ((byte_cnt_tmp[1:0] == adc_inc_val) && (byte_done == 1'b1) && (rdata_cmd == 1'b1)) begin
    adc_cnt <= adc_cnt + 1;
  end else begin
    adc_cnt <= adc_cnt;
  end
end

always @(*)
  begin
    case (byte_cnt_tmp[1:0])
      2'b00: imeas_temp = imeas_4th_byte;
      2'b01: imeas_temp = imeas_3rd_byte;
      2'b10: imeas_temp = imeas_2nd_byte;
      2'b11: imeas_temp = imeas_1st_byte;
      default: imeas_temp = 8'h0;
    endcase 
  end

wire [31:0]  imeas_chdata_reg;

wire next_dev_en;
assign next_dev_en = (adc_cnt == i_channel_max - 1) && daisy_en && byte_done && (byte_cnt_tmp == adc_inc_val);

always @(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
    next_dev_valid <= 1'b0;
  end else if (cs_n_d == 1'b1) begin
    next_dev_valid <= 1'b0;
  end else if (bit_cnt == 6'h0) begin
    next_dev_valid <= 1'b0;
  end else if (next_dev_en) begin
    next_dev_valid <= 1'b1;
  end else begin
    next_dev_valid <= next_dev_valid;
  end 
end


assign mul_val = (mode[0] == 1'b1) ? 3'd3 : 3'd4;
wire [7:0] x;
assign x = adc_cnt * mul_val;

assign imeas_chdata_reg = next_dev_valid ? {buffer[x], buffer[x + 7'd1], buffer[x + 7'd2], buffer[x + 7'd3]} : imeas_chdata[adc_cnt];

assign imeas_4th_byte = imeas_chdata_reg[31:24];
assign imeas_3rd_byte = imeas_chdata_reg[23:16];
assign imeas_2nd_byte = imeas_chdata_reg[15:8];
assign imeas_1st_byte = imeas_chdata_reg[7:0];

assign o_imeas_intr_clr = (rdata_cmd & (byte_cnt == 7'h01) && (bit_cnt < 6'h18)) || cov_int_clr;

//------------------------------STATUS HANDLE------------------------------//
assign num_status_byte = !mode[1] ? 3'h5 : 3'h0;

assign status_done = !mode[1] && (byte_cnt > 7'h4 && byte_cnt != 7'h0) && rdata_cmd && bit_cnt == 6'h18;

assign status_5th_byte = !mode[1] ? i_status_words[39:32] : 8'h00;
assign status_4th_byte = !mode[1] ? i_status_words[31:24] : 8'h00;
assign status_3rd_byte = !mode[1] ? i_status_words[23:16] : 8'h00;
assign status_2nd_byte = !mode[1] ? i_status_words[15:8]  : 8'h00;
assign status_1st_byte = !mode[1] ? i_status_words[7:0]   : 8'h00;

always @(*) begin
  if(!mode[1] && !next_dev_valid) begin
    case(byte_cnt)
      7'h0: status_temp = status_5th_byte;
      7'h1: status_temp = status_4th_byte;
      7'h2: status_temp = status_3rd_byte;
      7'h3: status_temp = status_2nd_byte;
      7'h4: status_temp = status_1st_byte;
      default: status_temp = 8'h0;
    endcase
  end else begin
    status_temp = 8'h00;
  end
end

//-------------------------------DAISY HANDLE--------------------------------//
reg [7:0] shift_reg;
reg [2:0] index_cnt;
reg [6:0] byte_ptr;
//reg [7:0] buffer [68:0];

integer i;

always @(posedge i_sclk_neg or negedge i_rst_n) begin
  if(!i_rst_n) begin
    for(i=0; i<=67; i=i+1) begin
      buffer[i] <= 8'h0;
    end
    shift_reg <= 8'h0;
    index_cnt <= 3'd0;
    byte_ptr  <= 7'd0;
  end
  else if(bit_cnt == 6'h0) begin
    shift_reg <= 8'h0;
    index_cnt <= 3'd0;
    byte_ptr  <= 7'd0;
  end
  else if(bit_cnt > 6'h0f && daisy_en && rdata_cmd) begin
      shift_reg <= {shift_reg[6:0], daisy_in};
      index_cnt <= index_cnt + 1'b1;
      if(index_cnt == 3'd7) begin
        buffer[byte_ptr] <= {shift_reg[6:0], daisy_in};
        if(byte_ptr == 7'd67)
          byte_ptr <= 7'd0;
        else
          byte_ptr <= byte_ptr + 1'b1;
       end
  end
end
// End of Thanh Huu added

endmodule
