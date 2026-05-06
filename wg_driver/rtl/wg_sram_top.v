//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2026
//
// Module Name : sram_top
// Description : sram top including controller and bist logic
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author  
//------------------------------------------------------------------------------
// 0.1       04/05/2026   Truong Pham
//------------------------------------------------------------------------------

module wg_sram_top #(
  parameter AW  = 7,
  parameter DW  = 8
) (
// DFT used
  input  wire             mbist_mode,
  input  wire             scan_mode,
  input  wire             scan_enable,

// Clock and Reset
  input  wire             clk,            // Clock
  input  wire             rst_n,          // Reset

  input  wire [AW-1:0]    waddr,          // Write Address
  input  wire [AW-1:0]    raddr,          // Read Address 
  input  wire             write,          // Write control
  input  wire [DW-1:0]    wdata,          // Write data

// Output
  output wire [DW-1:0]    rdata,          // Read data output

// bist interface
  input  wire             sram_bist_clk,  // bist clock
  input  wire             sram_bist_rstn, // bist reset, low active
  output wire             sram_bist_done, // bist done
  output wire             sram_bist_fail  // bist fail
);

  wire          func_clk;
  wire          func_cen;
  wire          func_wen;
  wire [DW-1:0] func_wdata;
  wire [AW-1:0] func_addr;
  wire          func_active;

  wire          bist_cen;
  wire          bist_wen;
  wire [DW-1:0] bist_wdata;
  wire [AW-1:0] bist_addr;
  wire          bist_rst_n;
  wire          bist_clk;

  wire          sram_clk;
  wire          sram_cen;
  wire          sram_wen;
  wire    [1:0] sram_ema;
  wire [DW-1:0] sram_wdata;
  wire [AW-1:0] sram_addr;
  wire [DW-1:0] sram_rdata;

  wire [DW-1:0] dft_data;
  reg  [DW-1:0] dft_data_r;
  wire [DW-1:0] sram_dout;

  wg_sram_ctrl #(
    .AW(AW),
    .DW(DW)) 
  u_wg_sram_ctrl (
// Inputs

`ifdef SRAM_DATA_DELAY
    .CLK        (clk),
    .RST_n      (rst_n),
`endif 

    .WRITE      (write),
    .WADDR      (waddr),
    .RADDR      (raddr),
    .WDATA      (wdata),

// Outputs
    .RDATA      (rdata),

// SRAM input
    .SRAMRDATA  (sram_dout),

// SRAM Outputs
    .SRAMADDR   (func_addr),
    .SRAMWDATA  (func_wdata),
    .SRAMWEN    (func_wen),
    .SRAMCEN    (func_cen),
    .SRAMACTIVE (func_active)
  );

// SRAM Clock dynamic gating
  cell_icg u_sramclk (
    .CK   (clk),
    .E    (func_active),
    .SE   (scan_enable),
    .ECK  (func_clk)
  );

// SRAM BIST
  sram_bist #(
    .WE_WIDTH   (1),
    .ADDR_WIDTH (AW),
    .DATA_WIDTH (DW))
  u_sram_bist (
    .bist_clk   (bist_clk),
    .bist_rst_n (bist_rst_n),
    .bist_en    (mbist_mode),
    .bist_rdata (sram_dout),
    .bist_wdata (bist_wdata),
    .bist_addr  (bist_addr),
    .bist_wen   (bist_wen),
    .bist_cen   (bist_cen),
    .bist_done  (sram_bist_done),
    .bist_fail  (sram_bist_fail)
  );


  cell_clkmx2 u_dftmux_sram_clk (.A(func_clk), .B(sram_bist_clk), .S0(mbist_mode), .Y(sram_clk));
  assign sram_cen     = mbist_mode ? bist_cen   : func_cen;
  assign sram_wen     = mbist_mode ? bist_wen   : func_wen;
  assign sram_wdata   = mbist_mode ? bist_wdata : func_wdata;
  assign sram_addr    = mbist_mode ? bist_addr  : func_addr;
  assign sram_ema     = 2'b00;

  cell_clkmx2 u_dftmux_bist_clk (.A(clk), .B(sram_bist_clk), .S0(mbist_mode), .Y(bist_clk));
  assign bist_rst_n   = mbist_mode ? sram_bist_rstn : rst_n;
//assign dft_data     = sram_wdata[DW-1:0] ^ {14'b0, sram_cen, sram_wen, sram_ema[1:0], sram_addr[AW-1:0]};
  assign dft_data     = sram_wdata[DW-1:0] ^ {{{DW-AW}{1'b0}}, sram_addr[AW-1:0]};

  always @ (posedge clk or negedge rst_n) begin
    if (~rst_n)
      dft_data_r <= {(DW){1'b0}};
    else if (scan_mode)
      dft_data_r <= dft_data;
  end

  assign sram_dout = scan_mode ? dft_data_r : sram_rdata;

  sram_sp_128x8 u_sram_sp_128x8 (
    .Q    (sram_rdata),
    .CLK  (sram_clk),
    .CEN  (sram_cen),
    .WEN  (sram_wen),
    .A    (sram_addr),
    .D    (sram_wdata),
    .EMA  (sram_ema)
  );

endmodule
