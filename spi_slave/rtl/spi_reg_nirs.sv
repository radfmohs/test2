//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap ENS2  
// File name:    spi_reg_nirs.sv 
// Module Name : spi_reg_nirs
// Description : 
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author          Description      
//------------------------------------------------------------------------------
// 0.1                                      Initial Rev 
//------------------------------------------------------------------------------

`define NIRS_REG_BASE_ADDR_0            8'h00

`define NIRS_CTRL_CHANNEL               `NIRS_REG_BASE_ADDR_0 + 8'h00 
`define NIRS_CTRL_LED                   `NIRS_REG_BASE_ADDR_0 + 8'h01 
`define NIRS_CTRL_0                     `NIRS_REG_BASE_ADDR_0 + 8'h02
`define NIRS_CTRL_1                     `NIRS_REG_BASE_ADDR_0 + 8'h03
`define NIRS_CTRL_2                     `NIRS_REG_BASE_ADDR_0 + 8'h04
`define NIRS_CTRL_3                     `NIRS_REG_BASE_ADDR_0 + 8'h05
`define NIRS_CTRL_4                     `NIRS_REG_BASE_ADDR_0 + 8'h06  
`define NIRS_CTRL_5                     `NIRS_REG_BASE_ADDR_0 + 8'h07
`define NIRS_CTRL_6                     `NIRS_REG_BASE_ADDR_0 + 8'h08
`define NIRS_CTRL_7                     `NIRS_REG_BASE_ADDR_0 + 8'h09
`define NIRS_CTRL_8                     `NIRS_REG_BASE_ADDR_0 + 8'h0A

`define NIRS_CTRL_MODE                  `NIRS_REG_BASE_ADDR_0 + 8'h0B
`define NIRS_CTRL_INT                   `NIRS_REG_BASE_ADDR_0 + 8'h0C
`define NIRS_CTRL_ADJ_0                 `NIRS_REG_BASE_ADDR_0 + 8'h0D
`define NIRS_CTRL_CLK                   `NIRS_REG_BASE_ADDR_0 + 8'h0E
`define NIRS_CTRL_CMD                   `NIRS_REG_BASE_ADDR_0 + 8'h0F

`define NIRS_REG_BASE_ADDR_1            8'h10
`define NIRS_DEBUG_SEL                  `NIRS_REG_BASE_ADDR_1 + 8'h00
`define NIRS_DEBUG_0                    `NIRS_REG_BASE_ADDR_1 + 8'h01
`define NIRS_DEBUG_1                    `NIRS_REG_BASE_ADDR_1 + 8'h02
`define NIRS_DEBUG_2                    `NIRS_REG_BASE_ADDR_1 + 8'h03
`define NIRS_DEBUG_3                    `NIRS_REG_BASE_ADDR_1 + 8'h04
`define NIRS_DEBUG_4                    `NIRS_REG_BASE_ADDR_1 + 8'h05

`define NIRS_DATA_BASE_ADDR             8'h20
`define NIRS_INT_STATUS                 `NIRS_DATA_BASE_ADDR + 8'h00

`define NIRS_DOUT0_0                    `NIRS_DATA_BASE_ADDR + 8'h01
`define NIRS_DOUT0_1                    `NIRS_DATA_BASE_ADDR + 8'h02
`define NIRS_DOUT0_2                    `NIRS_DATA_BASE_ADDR + 8'h03
`define NIRS_DOUT0_3                    `NIRS_DATA_BASE_ADDR + 8'h04
`define NIRS_DOUT1_0                    `NIRS_DATA_BASE_ADDR + 8'h05
`define NIRS_DOUT1_1                    `NIRS_DATA_BASE_ADDR + 8'h06
`define NIRS_DOUT1_2                    `NIRS_DATA_BASE_ADDR + 8'h07
`define NIRS_DOUT1_3                    `NIRS_DATA_BASE_ADDR + 8'h08
`define NIRS_DOUT2_0                    `NIRS_DATA_BASE_ADDR + 8'h09
`define NIRS_DOUT2_1                    `NIRS_DATA_BASE_ADDR + 8'h0A
`define NIRS_DOUT2_2                    `NIRS_DATA_BASE_ADDR + 8'h0B
`define NIRS_DOUT2_3                    `NIRS_DATA_BASE_ADDR + 8'h0C
`define NIRS_DOUT3_0                    `NIRS_DATA_BASE_ADDR + 8'h0D
`define NIRS_DOUT3_1                    `NIRS_DATA_BASE_ADDR + 8'h0E
`define NIRS_DOUT3_2                    `NIRS_DATA_BASE_ADDR + 8'h0F
`define NIRS_DOUT3_3                    `NIRS_DATA_BASE_ADDR + 8'h10
`define NIRS_DOUT4_0                    `NIRS_DATA_BASE_ADDR + 8'h11
`define NIRS_DOUT4_1                    `NIRS_DATA_BASE_ADDR + 8'h12
`define NIRS_DOUT4_2                    `NIRS_DATA_BASE_ADDR + 8'h13
`define NIRS_DOUT4_3                    `NIRS_DATA_BASE_ADDR + 8'h14
`define NIRS_DOUT5_0                    `NIRS_DATA_BASE_ADDR + 8'h15
`define NIRS_DOUT5_1                    `NIRS_DATA_BASE_ADDR + 8'h16
`define NIRS_DOUT5_2                    `NIRS_DATA_BASE_ADDR + 8'h17
`define NIRS_DOUT5_3                    `NIRS_DATA_BASE_ADDR + 8'h18
`define NIRS_DOUT6_0                    `NIRS_DATA_BASE_ADDR + 8'h19
`define NIRS_DOUT6_1                    `NIRS_DATA_BASE_ADDR + 8'h1A
`define NIRS_DOUT6_2                    `NIRS_DATA_BASE_ADDR + 8'h1B
`define NIRS_DOUT6_3                    `NIRS_DATA_BASE_ADDR + 8'h1C
`define NIRS_DOUT7_0                    `NIRS_DATA_BASE_ADDR + 8'h1D
`define NIRS_DOUT7_1                    `NIRS_DATA_BASE_ADDR + 8'h1E
`define NIRS_DOUT7_2                    `NIRS_DATA_BASE_ADDR + 8'h1F
`define NIRS_DOUT7_3                    `NIRS_DATA_BASE_ADDR + 8'h20

module spi_reg_nirs #(
  parameter ADDR_WIDTH    = 8,
  parameter DATA_WIDTH    = 8,
  parameter NO_OF_CHANNEL = 8
) (
  
  input                   i_clk,
  input                   i_rst_n,
  input  [ADDR_WIDTH-1:0] i_addr,
  input                   i_wr,
  input                   i_rd,
  input                   i_rd_normal,
  input  [DATA_WIDTH-1:0] i_wr_data,
  output [DATA_WIDTH-1:0] o_rd_data,


  output  wire            ppg_dis,           //ppg disble 
  output  wire  [1:0]     ppg_clk_div,       // ppg clock divider
  output  wire            ana_ppgclk_inv,   // ana ppg clock 
  output  wire            ppg_clk50duty,            
  output  wire 	          ppg_rst_reg,
  
  input   wire            int_clear_type,

  spi_nirs_if.spi         spi_nirs_if
);




//------------------------------------------------------------------------------------
//--------------------NIRS Register---------------------------------------------------
//------------------------------------------------------------------------------------
  reg [7:0] nirs_ctrl_channel_reg;
  reg [1:0] nirs_ctrl_led_reg;
  reg [5:0] nirs_ctrl_clk_reg;
  reg [7:0] nirs_ctrl_adj_reg;
  reg [1:0] nirs_ctrl_cmd_reg [NO_OF_CHANNEL-1:0];
  reg [7:0] nirs_ctrl_int_reg [NO_OF_CHANNEL-1:0];
  reg [4:0] nirs_debug_sel_reg;

  wire [7:0] nirs_ctrl_tmp  [8:0];
  wire [7:0] nirs_debug_tmp [4:0];  
  reg  [5:0] nirs_ctrl_mode_reg [NO_OF_CHANNEL-1:0];
  reg  [7:0] nirs_ctrl_reg      [NO_OF_CHANNEL-1:0][1:0][8:0];
  reg  [7:0] nirs_debug_reg     [NO_OF_CHANNEL-1:0][4:0];

  reg [7:0] nirs_int_sts_reg;
  reg [7:0] nirs_dout_reg[7:0][3:0];

  assign ppg_dis          = nirs_ctrl_clk_reg[0];           //ppg disble 
  assign ana_ppgclk_inv   = nirs_ctrl_clk_reg[1];   // ana ppg clock 
  assign ppg_clk_div      = nirs_ctrl_clk_reg[3:2];       // ppg clock divider
  assign ppg_clk50duty    = nirs_ctrl_clk_reg[4];            
  assign ppg_rst_reg      = nirs_ctrl_clk_reg[5];

  always@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
      nirs_ctrl_channel_reg <= 8'h0;
      nirs_ctrl_led_reg     <= 2'h0;
      nirs_ctrl_clk_reg     <= 6'h02;
      nirs_ctrl_adj_reg     <= 8'h00;
      nirs_debug_sel_reg    <= 5'b0;

      for(int x = 0; x < NO_OF_CHANNEL; x = x + 1) begin
        nirs_ctrl_mode_reg[x] <= 6'h0;
        nirs_ctrl_cmd_reg [x] <= 2'h0;
        nirs_ctrl_int_reg [x] <= 8'h00;
      end

    end else begin
      if (i_wr)
      case (i_addr[ADDR_WIDTH-1:0])
        `NIRS_CTRL_CHANNEL  : nirs_ctrl_channel_reg <= i_wr_data[7:0];
        `NIRS_CTRL_LED      : nirs_ctrl_led_reg     <= i_wr_data[1:0];
        `NIRS_CTRL_CLK      : nirs_ctrl_clk_reg     <= i_wr_data[5:0];
        `NIRS_DEBUG_SEL     : nirs_debug_sel_reg    <= i_wr_data[4:0];
        `NIRS_CTRL_ADJ_0    : nirs_ctrl_adj_reg     <= i_wr_data[7:0];

        `NIRS_CTRL_CMD      : begin
          for (int x = 0; x < NO_OF_CHANNEL; x = x + 1)
            if (nirs_ctrl_channel_reg[x])
              nirs_ctrl_cmd_reg[x]  <= i_wr_data[1:0];
        end

        `NIRS_CTRL_MODE     : begin
          for (int x = 0; x < NO_OF_CHANNEL; x = x + 1)
            if (nirs_ctrl_channel_reg[x])
              nirs_ctrl_mode_reg[x]  <= i_wr_data[5:0];
        end

        `NIRS_CTRL_INT      : begin
          for (int x = 0; x < NO_OF_CHANNEL; x = x + 1)
            if (nirs_ctrl_channel_reg[x])
              nirs_ctrl_int_reg[x]  <= i_wr_data;
        end

      endcase
    end
  end

  always@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
      for(int x = 0; x < NO_OF_CHANNEL; x = x + 1) begin
        for(int y = 0; y < 2; y = y + 1) begin
          nirs_ctrl_reg [x][y][0]  <= 8'h44;
          nirs_ctrl_reg [x][y][1]  <= 8'h02;
          nirs_ctrl_reg [x][y][2]  <= 8'h00;
          nirs_ctrl_reg [x][y][3]  <= 8'h0F;
          nirs_ctrl_reg [x][y][4]  <= 8'hFF;
          nirs_ctrl_reg [x][y][5]  <= 8'hFF;
          nirs_ctrl_reg [x][y][6]  <= 8'hFF;
          nirs_ctrl_reg [x][y][7]  <= 8'h00 ;
          nirs_ctrl_reg [x][y][8]  <= 8'h00;
        end
      end

    end else begin
      if (i_wr) begin
        for (int x = 0; x < NO_OF_CHANNEL; x = x + 1) begin
          if (nirs_ctrl_channel_reg[x]) begin
            for (int y = 0; y < 2; y = y + 1) begin
              if (nirs_ctrl_led_reg[y]) begin
                case (i_addr[ADDR_WIDTH-1:0])
                  `NIRS_CTRL_0:   nirs_ctrl_reg [x][y][0] <= i_wr_data;
                  `NIRS_CTRL_1:   nirs_ctrl_reg [x][y][1] <= i_wr_data;
                  `NIRS_CTRL_2:   nirs_ctrl_reg [x][y][2] <= i_wr_data;
                  `NIRS_CTRL_3:   nirs_ctrl_reg [x][y][3] <= i_wr_data;
                  `NIRS_CTRL_4:   nirs_ctrl_reg [x][y][4] <= i_wr_data;
                  `NIRS_CTRL_5:   nirs_ctrl_reg [x][y][5] <= i_wr_data;
                  `NIRS_CTRL_6:   nirs_ctrl_reg [x][y][6] <= i_wr_data;
                  `NIRS_CTRL_7:   nirs_ctrl_reg [x][y][7] <= i_wr_data;
                  `NIRS_CTRL_8:   nirs_ctrl_reg [x][y][8] <= i_wr_data;
                endcase
              end
            end
          end
        end
      end
    end
  end

//------------------------------------------------------------------------------------
//---------------------- INTTERRUPT --------------------------------------------------
//------------------------------------------------------------------------------------
wire nirs_int_sts_rd, nirs_int_sts_wr, int_gen_sts_rd;
reg  [7:0] nirs_int_clr;
wire [7:0] nirs_int_sts_sync;

//int sync for reading
common_sync_bit   u_int_sync [7:0] (
       .clk(i_clk),
       .rst_(i_rst_n),
       .async_in(nirs_int_sts_reg),
       .sync_out(nirs_int_sts_sync)
);

assign nirs_int_sts_wr  = i_wr        & (i_addr[ADDR_WIDTH-1:0] == (`NIRS_INT_STATUS));
assign nirs_int_sts_rd  = i_rd        & (i_addr[ADDR_WIDTH-1:0] == (`NIRS_INT_STATUS));
assign int_gen_sts_rd   = i_rd_normal & (i_addr[ADDR_WIDTH-1:0] == `GENERAL_INTERUPT_STATUS_REG06);


always @(posedge i_clk or negedge i_rst_n) begin
  if (~i_rst_n) begin
      nirs_int_clr     <= 8'b0;   
  end else begin
    for (int x = 0; x < NO_OF_CHANNEL; x++) begin
      if (nirs_int_sts_sync[x]) begin
        if (nirs_int_sts_wr & i_wr_data[x] & !int_clear_type) begin // WRITE 1 to clear RW1C
          nirs_int_clr[x] <= 1'b1;
        end else if (nirs_int_sts_rd & int_clear_type) begin // READ 1 to clear - NIRS INT reg
          nirs_int_clr[x] <= 1'b1;
        end else if (int_gen_sts_rd & int_clear_type) begin // READ 1 to clear - GEN INT reg
          nirs_int_clr[x] <= 1'b1;
        end
      end else begin
          nirs_int_clr[x] <= 1'b0;
      end
    end
  end
end

//------------------------------------------------------------------------------------
//--------------------Register Read---------------------------------------------------
//------------------------------------------------------------------------------------

  assign nirs_ctrl_tmp  = nirs_ctrl_reg[nirs_debug_sel_reg[3:0]][nirs_debug_sel_reg[4]];
  assign nirs_debug_tmp = nirs_debug_reg[nirs_debug_sel_reg[3:0]];

  reg [7:0] reg_rd_data;
  always @ (posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n)
      reg_rd_data <= 8'b0;
    else if(!i_wr) begin
      case(i_addr[ADDR_WIDTH-1:0])
      `NIRS_CTRL_CHANNEL  :  reg_rd_data  <= nirs_ctrl_channel_reg; 
      `NIRS_CTRL_LED      :  reg_rd_data  <= {6'b0, nirs_ctrl_led_reg};
      `NIRS_CTRL_CLK      :  reg_rd_data  <= {2'b0, nirs_ctrl_clk_reg};
      `NIRS_CTRL_MODE     :  reg_rd_data  <= {2'b0, nirs_ctrl_mode_reg[nirs_debug_sel_reg[3:0]]};
      `NIRS_CTRL_CMD      :  reg_rd_data  <= {6'b0, nirs_ctrl_cmd_reg[nirs_debug_sel_reg[3:0]]};
      `NIRS_CTRL_INT      :  reg_rd_data  <= nirs_ctrl_int_reg[nirs_debug_sel_reg[3:0]];
      `NIRS_CTRL_ADJ_0    :  reg_rd_data  <= nirs_ctrl_adj_reg;

      `NIRS_INT_STATUS    :  reg_rd_data  <= nirs_int_sts_reg;
    
      `NIRS_DOUT0_0       : reg_rd_data   <= nirs_dout_reg[0][0];
      `NIRS_DOUT0_1       : reg_rd_data   <= nirs_dout_reg[0][1];
      `NIRS_DOUT0_2       : reg_rd_data   <= nirs_dout_reg[0][2];
      `NIRS_DOUT0_3       : reg_rd_data   <= nirs_dout_reg[0][3];
      `NIRS_DOUT1_0       : reg_rd_data   <= nirs_dout_reg[1][0];
      `NIRS_DOUT1_1       : reg_rd_data   <= nirs_dout_reg[1][1];
      `NIRS_DOUT1_2       : reg_rd_data   <= nirs_dout_reg[1][2];
      `NIRS_DOUT1_3       : reg_rd_data   <= nirs_dout_reg[1][3];
      `NIRS_DOUT2_0       : reg_rd_data   <= nirs_dout_reg[2][0];
      `NIRS_DOUT2_1       : reg_rd_data   <= nirs_dout_reg[2][1];
      `NIRS_DOUT2_2       : reg_rd_data   <= nirs_dout_reg[2][2];
      `NIRS_DOUT2_3       : reg_rd_data   <= nirs_dout_reg[2][3];
      `NIRS_DOUT3_0       : reg_rd_data   <= nirs_dout_reg[3][0];
      `NIRS_DOUT3_1       : reg_rd_data   <= nirs_dout_reg[3][1];
      `NIRS_DOUT3_2       : reg_rd_data   <= nirs_dout_reg[3][2];
      `NIRS_DOUT3_3       : reg_rd_data   <= nirs_dout_reg[3][3];
      `NIRS_DOUT4_0       : reg_rd_data   <= nirs_dout_reg[4][0];
      `NIRS_DOUT4_1       : reg_rd_data   <= nirs_dout_reg[4][1];
      `NIRS_DOUT4_2       : reg_rd_data   <= nirs_dout_reg[4][2];
      `NIRS_DOUT4_3       : reg_rd_data   <= nirs_dout_reg[4][3];
      `NIRS_DOUT5_0       : reg_rd_data   <= nirs_dout_reg[5][0];
      `NIRS_DOUT5_1       : reg_rd_data   <= nirs_dout_reg[5][1];
      `NIRS_DOUT5_2       : reg_rd_data   <= nirs_dout_reg[5][2];
      `NIRS_DOUT5_3       : reg_rd_data   <= nirs_dout_reg[5][3];
      `NIRS_DOUT6_0       : reg_rd_data   <= nirs_dout_reg[6][0];
      `NIRS_DOUT6_1       : reg_rd_data   <= nirs_dout_reg[6][1];
      `NIRS_DOUT6_2       : reg_rd_data   <= nirs_dout_reg[6][2];
      `NIRS_DOUT6_3       : reg_rd_data   <= nirs_dout_reg[6][3];
      `NIRS_DOUT7_0       : reg_rd_data   <= nirs_dout_reg[7][0];
      `NIRS_DOUT7_1       : reg_rd_data   <= nirs_dout_reg[7][1];
      `NIRS_DOUT7_2       : reg_rd_data   <= nirs_dout_reg[7][2];
      `NIRS_DOUT7_3       : reg_rd_data   <= nirs_dout_reg[7][3];

      `NIRS_CTRL_0        :  reg_rd_data  <= nirs_ctrl_tmp[0]; 
      `NIRS_CTRL_1        :  reg_rd_data  <= nirs_ctrl_tmp[1]; 
      `NIRS_CTRL_2        :  reg_rd_data  <= nirs_ctrl_tmp[2]; 
      `NIRS_CTRL_3        :  reg_rd_data  <= nirs_ctrl_tmp[3]; 
      `NIRS_CTRL_4        :  reg_rd_data  <= nirs_ctrl_tmp[4];
      `NIRS_CTRL_5        :  reg_rd_data  <= nirs_ctrl_tmp[5];
      `NIRS_CTRL_6        :  reg_rd_data  <= nirs_ctrl_tmp[6];
      `NIRS_CTRL_7        :  reg_rd_data  <= nirs_ctrl_tmp[7];
      `NIRS_CTRL_8        :  reg_rd_data  <= nirs_ctrl_tmp[8];

      `NIRS_DEBUG_SEL     :  reg_rd_data  <= {3'b0, nirs_debug_sel_reg};
      `NIRS_DEBUG_0       :  reg_rd_data  <= nirs_debug_tmp[0];
      `NIRS_DEBUG_1       :  reg_rd_data  <= nirs_debug_tmp[1];
      `NIRS_DEBUG_2       :  reg_rd_data  <= nirs_debug_tmp[2];
      `NIRS_DEBUG_3       :  reg_rd_data  <= nirs_debug_tmp[3];
      `NIRS_DEBUG_4       :  reg_rd_data  <= nirs_debug_tmp[4];
      default             :  reg_rd_data  <= 8'h00;
        endcase
     end
  end

  assign o_rd_data = reg_rd_data;

//NIRS
  assign spi_nirs_if.NIRS_CTRL_MODE = nirs_ctrl_mode_reg;
  assign spi_nirs_if.NIRS_CTRL      = nirs_ctrl_reg;
  assign spi_nirs_if.NIRS_CTRL_CMD  = nirs_ctrl_cmd_reg;
  assign spi_nirs_if.NIRS_CTRL_INT  = nirs_ctrl_int_reg;
  assign spi_nirs_if.NIRS_INT_CLR   = nirs_int_clr;
  assign spi_nirs_if.NIRS_CTRL_ADJ  = nirs_ctrl_adj_reg;
  assign nirs_int_sts_reg           = spi_nirs_if.NIRS_INT;
  assign nirs_debug_reg             = spi_nirs_if.NIRS_DEBUG;
  assign nirs_dout_reg              = spi_nirs_if.NIRS_DOUT;
  
endmodule