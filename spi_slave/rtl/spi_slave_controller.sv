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

module spi_slave_controller#(
  parameter EEG_CHN_NUM = 16,
  parameter EEG_DATA_SIZE = 24,
  parameter DATA_WIDTH = 8,
  parameter ADDR_WIDTH = 8
) (
i_rst_n          ,
i_sclk           ,
i_sclk_neg       ,
atpg_en       	 ,
o_dual_en        ,
o_dual_wr        ,
i_cs_n           ,
i_channel_max    ,       
i_mosi           ,
i_mosi1           ,
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
nirs_cmd_reg     ,
o_nirs_wr        ,
o_nirs_rd        ,
o_wr_data        ,
i_rd_data        ,
o_miso           ,
o_miso1           ,
o_imeas_intr_clr ,     
mode             ,
imeas_16bit_sel  ,
imeas_chdata     ,
o_int_allowed
);

//Port declarations
input                   i_rst_n;
input                   i_sclk;
input                   i_sclk_neg;
input                   atpg_en;
output                  o_dual_en;
output                  o_dual_wr;
input                   i_cs_n;
input                   i_mosi;
input                   i_mosi1;
input [DATA_WIDTH-1:0]  i_rd_data;
input   wire [23:0]     imeas_chdata[EEG_CHN_NUM-1:0];
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
output reg              nirs_cmd_reg;
output reg              o_nirs_wr;
output reg              o_nirs_rd;
output reg [DATA_WIDTH-1:0] o_wr_data;
output reg [ADDR_WIDTH-1:0] o_addr;
output wire             o_miso;
output wire             o_miso1;
output wire             o_imeas_intr_clr;
input  wire             imeas_16bit_sel;
output reg [DATA_WIDTH-1:0] o_int_allowed;

//output reg            o_addr_vld_for_int_clr;
//output reg            burst_cmd_reg;
//output reg [ADDR_WIDTH-1:0] o_pre_addr;

reg                     burst_cmd_reg;
reg [ADDR_WIDTH-1:0]    o_pre_addr;

reg [DATA_WIDTH-1:0]    rx_buf ;
reg [DATA_WIDTH-1:0]    tx_buf ;
reg [5:0]               bit_cnt;
reg                     tx_d,tx_d1,cs_n_d;
reg                     rd_data_rdy;
reg                     cmd_reg,i_mosi_d;
reg                     latch_state,latch_state_d;
reg                     rdata_cmd;
reg                     rdatac_cmd;
reg                     dff_miso;
reg                     dff_miso1;
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
wire                    comb_miso1;
reg                     detect_first_bit_sync;
wire                    detect_flag;
reg [7:0]               imeas_temp;
reg [5:0]               byte_cnt_tmp;
reg [6:0]               byte_cnt; // max is 63
reg [7:0]               status_temp;

reg [7:0]               buffer [52:0];
reg                     next_dev_valid; // max is 15

wire [7:0]              status_5th_byte;
wire [7:0]              status_4th_byte;
wire [7:0]              status_3rd_byte;
wire [7:0]              status_2nd_byte;
wire [7:0]              status_1st_byte;

//wire [7:0]              imeas_4th_byte;
wire [7:0]              imeas_3rd_byte;
wire [7:0]              imeas_2nd_byte;
wire [7:0]              imeas_1st_byte;

reg cmd_reg_0, cmd_reg_1;
//reg cmd_reg_2, cmd_reg_3; 
reg cmd_reg_4, cmd_reg_5; 
reg cmd_reg_6, cmd_reg_7;
reg rdata_rdatac_cmd;

//--------------------------------------------------//
//        dual control    													//
//--------------------------------------------------//
reg dual_pending;
reg  dual_en, dual_wr_reg_neg, dual_wr_reg;
assign o_dual_en = dual_en;
assign o_dual_wr = dual_wr_reg; //(dual_en && !rd_data_rdy);

/*
  On falling edge of the 6'h10, switch to read mode for mosi/miso -  dual_wr_reg
  Use dual_wr_reg_neg on the rising edge at bit_cnt == 6'h0E for timing closure 
  Same for reset it at the end - 8'h18
*/
//always@(posedge i_sclk, negedge i_rst_n) begin
/*
always@(posedge i_sclk_neg, negedge i_rst_n) begin  // negedge: half-cycle earlier
  if(!i_rst_n)
    dual_wr_reg_neg <= 1'b1;
  else if (burst_cmd_reg == 1'b0 && bit_cnt == 6'h16)  
    dual_wr_reg_neg <= 1'b1; 
  else if (bit_cnt == 6'h0E && rd_data_rdy)  
    dual_wr_reg_neg <= 1'b0; 
end

always@(posedge i_sclk, negedge i_rst_n) begin
  if(!i_rst_n)
    dual_wr_reg <= 1'b1;
  else
    dual_wr_reg <= dual_wr_reg_neg;
end
*/

wire dual_wr_reset_n = atpg_en ? i_rst_n : i_rst_n & !i_cs_n;

always@(posedge i_sclk_neg, negedge dual_wr_reset_n) begin  // negedge: half-cycle earlier
  if(!dual_wr_reset_n)
    dual_wr_reg_neg <= 1'b1;
  else if (bit_cnt == 6'h0E && rd_data_rdy)  
    dual_wr_reg_neg <= 1'b0; 
end

//always@(posedge i_sclk, negedge i_rst_n) begin
always@(posedge i_sclk, negedge dual_wr_reset_n) begin
  if(!dual_wr_reset_n)
    dual_wr_reg <= 1'b1;
  else
    dual_wr_reg <= dual_wr_reg_neg;
end

always@(posedge i_sclk_neg, negedge i_rst_n) begin
  if(!i_rst_n)
    dual_pending <= 1'b0;
  else if (bit_cnt == 6'h12)   // one cycle after cmd_reg_0 is decoded at 0x11
    dual_pending <= (cmd_reg_7 && cmd_reg_0); // sclk is running here, no cs_n_d needed
end
 
/*
  One cycle after cmd_reg_0 decoded -> raise dual_pending
  At bit_cnt == 1f, at the end of the current transaction -> switch to dual
  No logical mechanism to exit dual mode. Assert reset to go back to single!
*/
always@(posedge i_sclk_neg, negedge i_rst_n) begin
  if(!i_rst_n)
    dual_en <= 1'b0;
  else if (bit_cnt == 6'h1f && dual_pending)
    dual_en <= 1'b1;
end

//--------------------------------------------------//
//        chip select latch													//
//--------------------------------------------------//
//always@(posedge i_sclk or negedge i_rst_n)           //include reset
always@(posedge i_sclk_neg, negedge i_rst_n) begin
  if(!i_rst_n)
    cs_n_d <= 1;   //active low
  else
    cs_n_d <= i_cs_n;
end


reg       i_mosi1_d;
//--------------------------------------------------//
//          MOSI latch															//
//--------------------------------------------------//

//single mode
//always@(posedge i_sclk or negedge i_rst_n)            //include reset
always@(posedge i_sclk_neg, negedge i_rst_n) begin
  if(!i_rst_n)
  //i_mosi_d <=1'bz;
    i_mosi_d <= 1'b0;
  else
    i_mosi_d <= i_mosi;
end

//dual mode
//always@(posedge i_sclk or negedge i_rst_n)            //include reset
always@(posedge i_sclk_neg, negedge i_rst_n) begin
  if(!i_rst_n)
    i_mosi1_d <= 1'b0;
  else if (dual_en)
    i_mosi1_d <= i_mosi1;
  else
    i_mosi1_d <= 1'b0;
end

//--------------------------------------------------//
//            RX buffer 														//
//--------------------------------------------------//
//assign i_mosi1_d = 1'b0;
//always@(posedge i_sclk , negedge i_rst_n) begin
always@(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
    rx_buf <= {DATA_WIDTH{1'b0}};
  end else if (cs_n_d == 1'b1) begin
    rx_buf <= {DATA_WIDTH{1'b0}};
  end else if (dual_en) begin
    rx_buf <= {rx_buf[DATA_WIDTH-3:0], i_mosi1_d, i_mosi_d};
  end else begin
    rx_buf <= {rx_buf[DATA_WIDTH-2:0],i_mosi_d};
  end
end

//--------------------------------------------------//
//            bit cnt logic								  				//
//--------------------------------------------------//

wire bit_cnt_reset = atpg_en ? i_rst_n : i_rst_n & !i_cs_n;
//always@(posedge i_sclk or negedge bit_cnt_reset)begin //or negedge i_cs_n)  begin // or negedge i_cs_n) begin
always@(posedge i_sclk_neg, negedge bit_cnt_reset) begin
//if (!i_rst_n) begin
  if (!bit_cnt_reset) begin
    bit_cnt <= 0;
  end else if (i_cs_n)begin
    bit_cnt <= 0;
  end
//else if (cs_n_d == 1'b1) begin
//  bit_cnt <= 0;
//end
 else begin  
//if ((bit_cnt ==6'h21 && 
//  imeas_cnt <= (rdata_cmd & imeas_cnt < max_cnt) ? imeas_cnt + 1 : 0;cmd_reg==1 ) || (bit_cnt == 6'h19 && cmd_reg==0))    // if number of bit in cmd is 24
    
  if ((bit_cnt ==6'h20 && cmd_reg==1 ) || (bit_cnt == 6'h18 && cmd_reg==0))    // if number of bit in cmd is 24
    bit_cnt <= bit_cnt;
  else 
    if (dual_en)
      bit_cnt <= bit_cnt + 2;
    else
      bit_cnt <= bit_cnt + 1;
  end
end

//--------------------------------------------------//
//            byte_done logic				  		  				//
//--------------------------------------------------//

//always@(posedge i_sclk, negedge i_rst_n) begin
always@(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
    byte_bit_count <= 3'b111;
  end
  else if (dual_en) begin
    if(bit_cnt== 6'h00) begin
      byte_bit_count <= 3'b110;
    end else begin
      byte_bit_count <= byte_bit_count - 2;
    end
  end

//else if(byte_bit_count==8'h00  || bit_cnt==6'h01) begin   //starts counting the bits of wr_data //|| bit_cnt ==6'h12 ||
  else begin 
    if(bit_cnt== 6'h00) begin   //starts counting the bits of wr_data //|| bit_cnt ==6'h12 ||
      byte_bit_count <= 3'b111;
    end else begin 
      byte_bit_count <= byte_bit_count - 1;
    end
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
  //o_addr_vld_for_int_clr <=0;
    o_pre_addr <=0;
  end else if (dual_en) begin
    if (bit_cnt == 6'h0a ) begin //original 8
      o_addr  <= rx_buf[ADDR_WIDTH-1:0];    
      o_pre_addr <= o_addr;
    end else if ((cmd_reg==1 && burst_cmd_reg && bit_cnt>6'h18 && byte_done ) || (cmd_reg==0 && burst_cmd_reg &&  bit_cnt >6'h10 && byte_bit_count==3'h6)) begin
      o_addr   <= o_addr + 1'b1; 
    //o_addr_vld_for_int_clr <=1;
      o_pre_addr <= o_addr;
    end else begin
      o_addr   <= o_addr;
    //o_addr_vld_for_int_clr <=0;
      o_pre_addr <= o_pre_addr;
    end 
  end else begin
    if (bit_cnt == 6'h09 ) begin //original 8
      o_addr  <= rx_buf[ADDR_WIDTH-1:0];    
    //o_addr_vld_for_int_clr <=1; 
      o_pre_addr <= o_addr;
    end else if ((cmd_reg==1 && burst_cmd_reg && bit_cnt>6'h18 && byte_done )||(cmd_reg==0 && burst_cmd_reg &&  bit_cnt >6'h12 && byte_bit_count==3'h4))  begin
      o_addr   <= o_addr+1'b1; 
    //o_addr_vld_for_int_clr <=1;
      o_pre_addr <= o_addr;
    end else begin
      o_addr   <= o_addr;
    //o_addr_vld_for_int_clr <=0;
      o_pre_addr <= o_pre_addr;
    end
  end
end

//--------------------------------------------------//
//                 CMD                              //
//--------------------------------------------------//
wire cmd_reg_4_early, cmd_reg_5_early;

assign burst_cmd_reg    =  cmd_reg_1 ;

assign cmd_reg          = dual_en ? (!cmd_reg_7 && !cmd_reg_6 ) : cmd_reg_7;

assign cmd_reg_5_early  = dual_en ? ((bit_cnt == 6'h0c) && i_mosi1_d) : 1'b0;
assign cmd_reg_4_early  = dual_en ? ((bit_cnt == 6'h0c) && i_mosi_d)  : 1'b0;

assign wavegen_cmd_reg  = dual_en ? ((cmd_reg_5 && !cmd_reg_4) || (cmd_reg_5_early && !cmd_reg_4_early)) : (cmd_reg_6 && ( cmd_reg_5 && !cmd_reg_4));
assign nirs_cmd_reg     = dual_en ? ((cmd_reg_5 &&  cmd_reg_4) || (cmd_reg_5_early &&  cmd_reg_4_early)) : (cmd_reg_6 && ( cmd_reg_5 &&  cmd_reg_4));

// Early RDATA/RDATAC detection to start the TX pipeline for both RDATA and RDATAC in dual mode only.
// At bit_cnt = 0E, CMD[5] distinguishes between RDATA and RDATAC.

assign rdata_rdatac_cmd = dual_en ? (cmd_reg_7 && !cmd_reg_6) : 1'b0;  
assign rdata_cmd        = dual_en ? ((rdata_rdatac_cmd && !cmd_reg_5) || rdatac_cmd): ((cmd_reg_6 && (!cmd_reg_5 && !cmd_reg_4)) || rdatac_cmd);
assign rdatac_cmd       = dual_en ? (rdata_rdatac_cmd && cmd_reg_5) :(cmd_reg_6 && (!cmd_reg_5 &&  cmd_reg_4));

//always@(posedge i_sclk, negedge i_rst_n) begin
always@(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
    cmd_reg_7 <= 1'b0;
  end else if (cs_n_d == 1'b1) begin
    cmd_reg_7 <= 1'b0;
  end else if(bit_cnt == 6'h00) begin
    cmd_reg_7 <= 1'b0;
  //end else if (bit_cnt == 6'h0b )begin        // 9th bit is the command bit(9+2 =11)
  end else if(dual_en) begin
    if (bit_cnt == 6'h0a)       // 1 count earlier
      cmd_reg_7 <= i_mosi1_d;   // direct: latched MOSI1 bit
  end else begin
    if (bit_cnt == 6'h0a )  //single       // 9th bit is the command bit(9+1 =10)
      cmd_reg_7 <= rx_buf[0];
  end
end

//always@(posedge i_sclk, negedge i_rst_n) begin
always@(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
    cmd_reg_6 <= 1'b0;
  end else if (cs_n_d == 1'b1) begin
    cmd_reg_6 <= 1'b0;
  end else if(bit_cnt == 6'h00) begin
    cmd_reg_6 <= 1'b0;
//end else if (bit_cnt == 6'h0d )begin        // 11th bit is the command bit(11+2=13)
  end else if (dual_en) begin
    if (bit_cnt == 6'h0a)     // same cycle as cmd_reg_7, 3 counts earlier
      cmd_reg_6 <= i_mosi_d;  // direct: the freshly latched MOSI0 bit
  end else begin
    if (bit_cnt == 6'h0b)
      cmd_reg_6 <= rx_buf[0];
  end
end

// Thanh Huu added
//-------------RDATA_CMD------------------//
always@(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
    cmd_reg_5 <= 1'b0;
  end else if(cs_n_d == 1'b1) begin
    cmd_reg_5 <= 1'b0;
  end else if(bit_cnt == 6'h00) begin
    cmd_reg_5 <= 1'b0;
  end else if (dual_en) begin
    if(bit_cnt == 6'h0c)       // 1 count earlier
      cmd_reg_5 <= i_mosi1_d;  // direct: latched MOSI1 bit
  end else begin
    if(bit_cnt == 6'h0c)  //single 
      cmd_reg_5 <= rx_buf[0];
  end
end

always@(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
    cmd_reg_4 <= 1'b0;
  end else if(cs_n_d == 1'b1) begin
    cmd_reg_4 <= 1'b0;
  end else if(bit_cnt == 6'h00) begin
    cmd_reg_4 <= 1'b0;
  end else if (dual_en) begin   // dual mode: command bit arrives 1 cycle earlier
    if (bit_cnt == 6'h0c)     // same cycle as cmd_reg_5, 3 counts earlier
      cmd_reg_4 <= i_mosi_d;  // direct: the freshly latched MOSI0 bit
  end else begin
    if (bit_cnt == 6'h0d)
      cmd_reg_4 <= rx_buf[0];
  end
end

//always@(posedge i_sclk, negedge i_rst_n) begin
// always@(posedge i_sclk_neg, negedge i_rst_n) begin
//   if (!i_rst_n) begin
//     cmd_reg_3 <= 1'b0;
//   end else if (cs_n_d == 1'b1) begin
//     cmd_reg_3 <= 1'b0;
//   end else if (dual_en) begin
//     if (bit_cnt == 6'h10 )       
//     cmd_reg_3 <= rx_buf[1]; 
//   end else begin
//     if (bit_cnt == 6'h0e )       //single 
//     cmd_reg_3 <= rx_buf[0];           
//   end
// end


//always@(posedge i_sclk, negedge i_rst_n) begin
// always@(posedge i_sclk_neg, negedge i_rst_n) begin
//   if (!i_rst_n) begin
//     cmd_reg_2 <= 1'b0;
//   end else if (cs_n_d == 1'b1) begin
//     cmd_reg_2 <= 1'b0;
//   end else if (dual_en) begin
//     if (bit_cnt == 6'h10)
//       cmd_reg_2 <= rx_buf[0];  // dual mode: command bit arrives 1 cycle earlier
//   end else begin
//     if(bit_cnt == 6'h0f)
//       cmd_reg_2 <= rx_buf[0];  
//   end
// end

always@(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
    cmd_reg_1 <= 1'b0;
  end else if (cs_n_d == 1'b1) begin
    cmd_reg_1 <= 1'b0;
//end else if (bit_cnt == 6'h0c )begin        // 10th bit is the command bit(10+2=12)
  end else if (dual_en) begin
    if (bit_cnt == 6'h10 )   // 1 count earlier       
    cmd_reg_1 <= i_mosi1_d;  // direct: latched MOSI1 bit 
  end else begin
    if (bit_cnt == 6'h10 )       //single 
    cmd_reg_1 <= rx_buf[0];           
  end
end


always@(posedge i_sclk_neg, negedge i_rst_n) begin
  if(!i_rst_n) begin
    cmd_reg_0 <= 1'b0;   //active low
  end else if (cs_n_d == 1'b1) begin
    cmd_reg_0 <= cmd_reg_0; 
  end else if (dual_en) begin
    if (bit_cnt == 6'h10)     // same cycle as cmd_reg_1, 3 counts earlier
      cmd_reg_0 <= i_mosi_d;  // direct: the freshly latched MOSI0 bit
  end else begin
    if (bit_cnt == 6'h11)
      cmd_reg_0 <= rx_buf[0];
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
//end else if ( bit_cnt ==6'h21 && byte_bit_count==3'h0 && cmd_reg==1) begin //burst_mode==1'b1
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
    o_wr_data <= rx_buf[DATA_WIDTH-1:0];
  end
end

// wr_enable
//always@(posedge i_sclk, negedge i_rst_n) begin
always@(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
    o_wr <= 1'b0;
  end else if(bit_cnt ==6'h0)begin
    o_wr <=1'b0;
  end else if ((latch_state) && (cmd_reg == 1'b1) && !wavegen_cmd_reg && !nirs_cmd_reg) begin    //can be latch_state
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
  end else if(bit_cnt ==6'h0)begin
    o_wavegen_wr <=1'b0;
  end else if ((latch_state) && (cmd_reg == 1'b1) && wavegen_cmd_reg && !nirs_cmd_reg) begin    //can be latch_state
    o_wavegen_wr <= 1'b1;
  end else begin
    o_wavegen_wr <= 1'b0;
  end
end

// nirs wr_enable
//always@(posedge i_sclk, negedge i_rst_n) begin
always@(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
    o_nirs_wr <= 1'b0;
  end else if(bit_cnt ==6'h0)begin
    o_nirs_wr <=1'b0;
  end else if ((latch_state) && (cmd_reg == 1'b1) && nirs_cmd_reg && !wavegen_cmd_reg) begin    //can be latch_state
    o_nirs_wr <= 1'b1;
  end else begin
    o_nirs_wr <= 1'b0;
  end
end

// rd_enable
//always@(posedge i_sclk, negedge i_rst_n) begin
always@(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
    o_rd <= 1'b0;
  end else if(bit_cnt ==6'h0)begin
    o_rd <=1'b0;
  end else if (dual_en) begin
    if ((bit_cnt ==6'h12) && (cmd_reg == 1'b0) && !wavegen_cmd_reg && !nirs_cmd_reg) begin
      o_rd <= 1'b1;
    end else begin
      o_rd <= 1'b0;
    end
  end else begin
    if ((bit_cnt ==6'h15) && (cmd_reg == 1'b0) && !wavegen_cmd_reg && !nirs_cmd_reg) begin    //can be latch_state
      o_rd <= 1'b1;
    end else begin
      o_rd <= 1'b0;
    end
  end
end

// wavegen rd_enable
//always@(posedge i_sclk, negedge i_rst_n) begin
always@(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
    o_wavegen_rd <= 1'b0;
  end else if(bit_cnt ==6'h0)begin
    o_wavegen_rd <=1'b0;
  end else if (dual_en) begin
    if ((bit_cnt ==6'h12) && (cmd_reg == 1'b0) && wavegen_cmd_reg && !nirs_cmd_reg) begin
      o_wavegen_rd <= 1'b1;
    end else begin
      o_wavegen_rd <= 1'b0;
    end
  end else begin 
    if ((bit_cnt ==6'h15) && (cmd_reg == 1'b0) && wavegen_cmd_reg && !nirs_cmd_reg) begin    //can be latch_state
      o_wavegen_rd <= 1'b1;
    end else begin
      o_wavegen_rd <= 1'b0;
    end
  end
end

// nirs rd_enable
//always@(posedge i_sclk, negedge i_rst_n) begin
always@(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
    o_nirs_rd <= 1'b0;
  end else if(bit_cnt ==6'h0)begin
    o_nirs_rd <=1'b0;
  end else if (dual_en) begin
    if((bit_cnt ==6'h12) && (cmd_reg == 1'b0) && nirs_cmd_reg && !wavegen_cmd_reg) begin    //can be latch_state
      o_nirs_rd <= 1'b1;
    end else begin
      o_nirs_rd <= 1'b0;
    end
  end else begin
    if ((bit_cnt ==6'h15) && (cmd_reg == 1'b0) && nirs_cmd_reg && !wavegen_cmd_reg) begin    //can be latch_state
      o_nirs_rd <= 1'b1;
    end else begin
      o_nirs_rd <= 1'b0;
    end
  end
end

//-----------------------------mosi output------------------//

always@(posedge i_sclk, negedge i_rst_n) begin
  if (!i_rst_n) begin
    dff_miso <= 1'b0;
  end else if (cs_n_d == 1'b1) begin
    dff_miso <= 1'b0;
  end else if ((cov_done == 1'b1) && (cpha != 1'b0)) begin
    dff_miso <= (!mode[1] && !next_dev_valid) ? status_temp[7] : imeas_temp[7]; 
  end else if ((byte_cnt[6:0] == 7'h01) && (rd_data_rdy == 1'b1) && (rdatac_cmd == 1'b1) && (bit_cnt == 6'h18) && (byte_done == 1'b0)) begin
    dff_miso <= !mode[1] ? status_5th_byte[byte_bit_count - 1] : imeas_3rd_byte[byte_bit_count - 1]; 
  end else begin
    dff_miso <= tx_d;
  end 
end

//dual mode
always@(posedge i_sclk, negedge i_rst_n) begin
  if (!i_rst_n) begin
    dff_miso1 <= 1'b0;
  end else if (cs_n_d == 1'b1) begin
    dff_miso1 <= 1'b0;
  end else if (dual_en) begin
    if ((cov_done == 1'b1) && (cpha != 1'b0)) begin
      dff_miso1 <= (!mode[1] && !next_dev_valid) ? status_temp[6] : imeas_temp[6]; 
    end else if ((byte_cnt[6:0] == 7'h01) && (rd_data_rdy == 1'b1) && (rdatac_cmd == 1'b1) && (bit_cnt == 6'h18) && (byte_done == 1'b0)) begin
      dff_miso1 <= !mode[1] ? status_5th_byte[byte_bit_count - 2] : imeas_3rd_byte[byte_bit_count - 2]; 
    end else begin
      dff_miso1 <= tx_d1;
    end
  end 
end

assign comb_miso  = (!mode[1] && !next_dev_valid) ? status_temp[7] : imeas_temp[7];
assign comb_miso1 = (!mode[1] && !next_dev_valid) ? status_temp[6] : imeas_temp[6];

assign detect_flag = detect_first_bit && detect_first_bit_sync;

assign o_miso  = detect_flag ? comb_miso  : dff_miso;
assign o_miso1 = detect_flag ? comb_miso1 : dff_miso1;
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
  end else if (dual_en) begin
    if (rd_data_rdy == 1) begin
      tx_d <= tx_buf[DATA_WIDTH-1];
    end else begin
      tx_d <= 1'b0; // just send what is received //original 2  
    end
  end else begin
    if (rd_data_rdy == 1) begin
      tx_d <= tx_buf[DATA_WIDTH-1];
    end else begin
      tx_d <= rx_buf[5]; // just send what is received //original 2  
    end
  end
end

//dual mode
always @(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
    tx_d1 <= 1'b0;
  end else if (cs_n_d == 1'b1) begin
    tx_d1 <= 1'b0;
  end else if (!dual_en) begin
    tx_d1 <= 1'b0;
  end else if (rd_data_rdy == 1) begin
    tx_d1 <= tx_buf[DATA_WIDTH-2];
  end else begin
    tx_d1 <= 1'b0; 
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
  end else if (dual_en) begin
    if (bit_cnt > 6'h8 && byte_bit_count==3'h4 && cmd_reg == 1'b0) 
      rd_data_rdy <= 1'b1;
  end else begin
    if (bit_cnt > 6'h8 && byte_bit_count==3'h2 && cmd_reg == 1'b0)  // @ the end of the 2nd byte(cmd byte)
//end else if (bit_cnt > 6'h8 && byte_bit_count==3'h3 && cmd_reg == 1'b0) begin // @ the end of the 2nd byte(cmd byte)
      rd_data_rdy <= 1'b1;
  end
end

//always@(posedge i_sclk, negedge i_rst_n) begin
always@(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
    tx_buf <= 0;
    o_int_allowed <= 0;
  end else if (cs_n_d == 1'b1) begin
    tx_buf <= 0;
    o_int_allowed <= 0;
  end else if(bit_cnt ==6'h02) begin
    tx_buf <= 0;
    o_int_allowed <= 0;
  end else if (dual_en) begin
    if ((bit_cnt > 6'h8 && byte_bit_count== 3'h4) || (burst_cmd_reg && bit_cnt > 6'h10 && byte_bit_count== 3'h4)) begin
      tx_buf <= (!mode[1] && !status_done && rdata_rdatac_cmd ) ? status_temp : rdata_rdatac_cmd ? imeas_temp : i_rd_data;
      o_int_allowed <= i_rd_data;
    end else begin
      tx_buf <= {tx_buf[DATA_WIDTH-3:0], 2'b0};
    end
  end else begin
    if (bit_cnt > 6'h8 && byte_bit_count==3'h2) begin // @ the end of the 2nd byte(cmd byte)
      tx_buf <= (!mode[1] && !status_done && rdata_cmd && !next_dev_valid) ? status_temp : rdata_cmd ? imeas_temp : i_rd_data;
      o_int_allowed <= i_rd_data;
    end else begin
      tx_buf <= {tx_buf[DATA_WIDTH-2:0],1'b0};
    end
  end
end

// ------------------------------CONTROL SIGNAL---------------------------------//

// imeas_16bit_sel=1 (mode[0]=0) -> 2 bytes per channel (16-bit)
// imeas_16bit_sel=0 (mode[0]=1) -> 3 bytes per channel (24-bit)

assign adc_inc_val = imeas_16bit_sel ? 2'b01 : 2'b10;


assign chdata_size = imeas_16bit_sel ? 3'h2  : 3'h3;

/*********************************************
- When master chip has not finished sending its imeas data (!next_dev_valid) 
then byte_cnt reset when it reach maximum number of bytes per channel (3 or 4) 
multiply by number of channel (i_channel_max) plus number of status byte
- byte_cnt start counting when bit_cnt reach 16 as MISO
start sending read_data at this time.
- When master chip finished sending its imeas data (next_dev_valid) 
then when after every 8 i_sclk_neg or byte_done, byte_cnt increase bt 1 
*********************************************/
always @(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
    byte_cnt <= 7'h0;
  end else if (cs_n_d == 1'b1) begin
    byte_cnt <= 7'h0;
  end else if (bit_cnt == 6'h0) begin
    byte_cnt <= 7'h0;
  end else if ((byte_done == 1'b1) && (rdata_cmd == 1'b1) && (byte_cnt == {4'b0, num_status_byte} + ({2'b0, i_channel_max} * {4'b0, chdata_size[2:0]}) - 1) && !next_dev_valid) begin
    byte_cnt <= 7'h0;
  end else if ( bit_cnt < 6'h10 ) begin
    byte_cnt <= byte_cnt;
  end else if ((byte_done == 1'b1) && (rdata_cmd == 1'b1) && !next_dev_valid) begin
    byte_cnt <= byte_cnt + 1;
  end else begin 
    byte_cnt <= byte_cnt;
  end
end

/*********************************************
Used to track the number of byte count per channel, 
reset when reach adc_inc_val or when status mode (!mode[1])
and byte_cnt <= 7'h5
*********************************************/
always @(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
    byte_cnt_tmp <= 6'h0;
  end else if (cs_n_d == 1'b1) begin
    byte_cnt_tmp <= 6'h0;
  end else if (bit_cnt == 6'h0) begin
    byte_cnt_tmp <= 6'h0;
  end else if (!mode[1] && (byte_cnt < 7'h5 || ( byte_cnt == 7'h5 && !byte_done )) && !next_dev_valid) begin
    byte_cnt_tmp <= 6'h0;
  end else if ((byte_done == 1'b1) && (rdata_cmd == 1'b1) && (byte_cnt_tmp == {4'b0, adc_inc_val}) && !next_dev_valid) begin  
    byte_cnt_tmp <= 6'h0;
  end else if ((byte_done == 1'b1) && (rdata_cmd == 1'b1) && (byte_cnt_tmp == 6'd52) && next_dev_valid) begin
    byte_cnt_tmp <= 6'h0;
  end else if ( bit_cnt < 6'h10 ) begin
    byte_cnt_tmp <= byte_cnt_tmp;
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

assign cov_done = (dual_en) ? ((byte_done == 1'b1) && (rdata_cmd == 1'b1) && (rdatac_cmd == 1'b1) && (byte_cnt == 7'h00) && (bit_cnt == 6'h18)) : 
                              ((byte_done == 1'b1) && (rdata_cmd == 1'b1) && (rdatac_cmd == 1'b1) && (byte_cnt == 7'h00) && (bit_cnt == 6'h18));

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

reg [5:0] adc_cnt; 
/******************************************************
Count the number of channels froom 0 to i_channel_max when !next_dev_valid
When next_dev_valid, if 4 bytes data per channel then adc_cnt reset when reach 5'd16
(because imeas_chdata_reg = {buffer[x],buffer[x+1],buffer[x+2],buffer[x+3]
while x*4 + 3 = 67 as discussed in buffer definition => adc_cnt should reset at 5'd16

Similarly, if 3 bytes data per channel then adc_cnt reset when reach 5'd22.
Because, 22 * 3 = 66 => imeas_chdata_reg = {buffer[x],buffer[x+1],buffer[x+2],buffer[x+3].
Notice when x+2 and x+3 are 68 and 69, just don't care as no more i_sclk_neg
******************************************************/
always @(posedge i_sclk_neg, negedge i_rst_n) begin
  if (!i_rst_n) begin
    adc_cnt <= 6'h0;
  end else if (cs_n_d == 1'b1) begin
    adc_cnt <= 6'h0;
  end else if (bit_cnt == 6'h0) begin
    adc_cnt <= 6'h0;
  end else if ((adc_cnt == ({1'b0, i_channel_max} - 1)) && (byte_cnt_tmp[1:0] == adc_inc_val) && (byte_done == 1'b1) && (rdata_cmd == 1'b1) && !next_dev_valid) begin
    adc_cnt <= 6'h0; 
  end else if ((byte_cnt_tmp[1:0] == adc_inc_val) && (byte_done == 1'b1) && (rdata_cmd == 1'b1) && (adc_cnt < ({ 1'b0, i_channel_max} - 1)) && !next_dev_valid) begin
    adc_cnt <= adc_cnt + 1;
  end else begin
    adc_cnt <= adc_cnt;
  end
end


always @(*) begin
  if(!next_dev_valid) begin
    case (byte_cnt_tmp[1:0])
      2'b00: imeas_temp = imeas_3rd_byte;
      2'b01: imeas_temp = imeas_2nd_byte;
      2'b10: imeas_temp = imeas_1st_byte;
      default: imeas_temp = 8'h0;
    endcase 
  end else begin
    imeas_temp = buffer[byte_cnt_tmp];
  end
end

wire [23:0]  imeas_chdata_reg;

wire next_dev_en;
assign next_dev_en = (adc_cnt == ({ 1'b0, i_channel_max} - 1)) && daisy_en && byte_done && (byte_cnt_tmp == {4'b0 ,adc_inc_val});

/***********************************************
When master chip has finished transfer its data 
through MISO, it started sending data of other chip
stored in buffer.
***********************************************/
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

assign imeas_chdata_reg = imeas_chdata[adc_cnt];

assign imeas_3rd_byte = imeas_chdata_reg[23:16];
assign imeas_2nd_byte = imeas_chdata_reg[15:8];
assign imeas_1st_byte = imeas_chdata_reg[7:0];

assign o_imeas_intr_clr = (rdata_cmd & (byte_cnt == 7'h01) && (bit_cnt < 6'h18)) || cov_int_clr; // affected by byte_cnt = 1 -> should check

//------------------------------STATUS HANDLE------------------------------//
assign num_status_byte = !mode[1] ? 3'h5 : 3'h0;

assign status_done = !mode[1] && (byte_cnt > 7'h4 && byte_cnt != 7'h0) && rdata_cmd ; // affected by byte_cnt = 1 -> should check

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
wire byte_ptr_last;

assign byte_ptr_last = (byte_ptr == 7'd52);
/*******************************************************
At first, buffer is designed with 69 elements, each one with 8 bytes 
because we have maximum 16 channels, each channel maximum is 4 bytes 
plus 5 bytes status, which make the buffer size 69. However, exploiting  
imeas_chdata_reg has 4 bytes, later imeas_chdata_reg is assign with 
{buffer[x], buffer[x+1], buffer[x+2], buffer[x+3]}, in which maximum x is 
max number of channel (16) multiply by max number of byte per channel (4).
So buffer size is 16 * 4 + 3 = 67 instead of 68
*******************************************************/
always @(posedge i_sclk_neg or negedge i_rst_n) begin
  if(!i_rst_n) begin
    for(i=0; i<=52; i=i+1) begin
      buffer[i] <= 8'h0;
    end
    shift_reg <= 8'h0;
    index_cnt <= 3'd0;
    byte_ptr  <= 7'd0;
  end else if(bit_cnt == 6'h0) begin
    shift_reg <= 8'h0;
    index_cnt <= 3'd0;
    byte_ptr  <= 7'd0;
  end else if(bit_cnt > 6'h0f && daisy_en && rdata_cmd && !rdatac_cmd) begin
    shift_reg <= {shift_reg[6:0], daisy_in};
    index_cnt <= index_cnt + 1'b1;
    if(index_cnt == 3'd7) begin
        buffer[byte_ptr] <= {shift_reg[6:0], daisy_in};
      if(byte_ptr_last)
        byte_ptr <= 7'd0;
      else
        byte_ptr <= byte_ptr + 1'b1;
    end
  end
end
// End of Thanh Huu added

endmodule
