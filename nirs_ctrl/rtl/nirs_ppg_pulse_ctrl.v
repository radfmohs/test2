//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap ENS2  
// File name:    nirs_ppg_pulse_ctrl.v 
// Module Name : nirs_ppg_pulse_ctrl
// Description : 
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author          Description      
//------------------------------------------------------------------------------
// 0.1                                      Initial Rev 
//------------------------------------------------------------------------------
module nirs_ppg_pulse_ctrl (
  input  wire       rst_n,
  input  wire       clk,  // 2 MHz
  input  wire [3:0] PERIOD_ctrl,
  input  wire [3:0] OTS_ctrl,

  output wire       RESET,
  output wire       ILED_SW,
  output wire       IIN_SW
);

// parameter [15:0] [15:0] t_PERIOD_timing  = {
//   16'd22000, 
//   16'd20000, 
//   16'd18000,
//   16'd16000,
//   16'd14000,
//   16'd12000,
//   16'd10000,
//   16'd8000,
//   16'd6000,
//   16'd4000,
//   16'd2000,
//   16'd1000,
//   16'd750,
//   16'd500,
//   16'd250,
//   16'd125
// };

localparam t_PERIOD_22MS  = 16'd22000;
localparam t_PERIOD_20MS  = 16'd20000;
localparam t_PERIOD_18MS  = 16'd18000;
localparam t_PERIOD_16MS  = 16'd16000;
localparam t_PERIOD_14MS  = 16'd14000;
localparam t_PERIOD_12MS  = 16'd12000;
localparam t_PERIOD_10MS  = 16'd10000;
localparam t_PERIOD_8MS   = 16'd8000;
localparam t_PERIOD_6MS   = 16'd6000;
localparam t_PERIOD_4MS   = 16'd4000;
localparam t_PERIOD_2MS   = 16'd2000;
localparam t_PERIOD_1MS   = 16'd1000;
localparam t_PERIOD_750US = 16'd750;
localparam t_PERIOD_500US = 16'd500;
localparam t_PERIOD_250US = 16'd250;
localparam t_PERIOD_125US = 16'd125;

// parameter [15:0] [15:0] t_OTS_timing  = {
//   16'd30,
//   16'd25,
//   16'd20,
//   16'd18,
//   16'd16,
//   16'd14,
//   16'd12,
//   16'd10,
//   16'd9,
//   16'd8,
//   16'd6,
//   16'd5,
//   16'd4,
//   16'd3,
//   16'd2,
//   16'd1
// };

localparam t_OTS_30US = 16'd30;
localparam t_OTS_25US = 16'd25;
localparam t_OTS_20US = 16'd20;
localparam t_OTS_18US = 16'd18;
localparam t_OTS_16US = 16'd16;
localparam t_OTS_14US = 16'd14;
localparam t_OTS_12US = 16'd12;
localparam t_OTS_10US = 16'd10;
localparam t_OTS_9US  = 16'd9;
localparam t_OTS_8US  = 16'd8;
localparam t_OTS_6US  = 16'd6;
localparam t_OTS_5US  = 16'd5;
localparam t_OTS_4US  = 16'd4;
localparam t_OTS_3US  = 16'd3;
localparam t_OTS_2US  = 16'd2;
localparam t_OTS_1US  = 16'd1;

parameter [15:0] t_RESET_w_timing = 16'd5;

parameter [15:0] t_delay_timing   = 16'd5;

  reg RESET_d, ILED_SW_d, IIN_SW_d;
  reg  [15:0] counter;
  wire [15:0] t_period_sel, t_period, t_RESET_w, t_ILED_SW_w_sel, t_ILED_SW_w, t_delay;
  wire [15:0] RESET_h,   RESET_l;  
  wire [15:0] ILED_SW_h, ILED_SW_l;
  wire [15:0] IIN_SW_h,  IIN_SW_l;

  assign t_period_sel     = (PERIOD_ctrl == 4'hf) ? t_PERIOD_22MS   :
                            (PERIOD_ctrl == 4'he) ? t_PERIOD_20MS   :
                            (PERIOD_ctrl == 4'hd) ? t_PERIOD_18MS   :
                            (PERIOD_ctrl == 4'hc) ? t_PERIOD_16MS   :
                            (PERIOD_ctrl == 4'hb) ? t_PERIOD_14MS   :
                            (PERIOD_ctrl == 4'ha) ? t_PERIOD_12MS   :
                            (PERIOD_ctrl == 4'h9) ? t_PERIOD_10MS   :
                            (PERIOD_ctrl == 4'h8) ? t_PERIOD_8MS    :
                            (PERIOD_ctrl == 4'h7) ? t_PERIOD_6MS    :
                            (PERIOD_ctrl == 4'h6) ? t_PERIOD_4MS    :
                            (PERIOD_ctrl == 4'h5) ? t_PERIOD_2MS    :
                            (PERIOD_ctrl == 4'h4) ? t_PERIOD_1MS    :
                            (PERIOD_ctrl == 4'h3) ? t_PERIOD_750US  :
                            (PERIOD_ctrl == 4'h2) ? t_PERIOD_500US  :
                            (PERIOD_ctrl == 4'h1) ? t_PERIOD_250US  :
                            (PERIOD_ctrl == 4'h0) ? t_PERIOD_125US  : t_PERIOD_125US;

  assign t_ILED_SW_w_sel  = (OTS_ctrl    == 4'hf) ? t_OTS_30US  :
                            (OTS_ctrl    == 4'he) ? t_OTS_25US  :
                            (OTS_ctrl    == 4'hd) ? t_OTS_20US  :
                            (OTS_ctrl    == 4'hc) ? t_OTS_18US  :
                            (OTS_ctrl    == 4'hb) ? t_OTS_16US  :
                            (OTS_ctrl    == 4'ha) ? t_OTS_14US  :
                            (OTS_ctrl    == 4'h9) ? t_OTS_12US  :
                            (OTS_ctrl    == 4'h8) ? t_OTS_10US  :
                            (OTS_ctrl    == 4'h7) ? t_OTS_9US   :
                            (OTS_ctrl    == 4'h6) ? t_OTS_8US   :
                            (OTS_ctrl    == 4'h5) ? t_OTS_6US   :
                            (OTS_ctrl    == 4'h4) ? t_OTS_5US   :
                            (OTS_ctrl    == 4'h3) ? t_OTS_4US   :
                            (OTS_ctrl    == 4'h2) ? t_OTS_3US   :
                            (OTS_ctrl    == 4'h1) ? t_OTS_2US   :
                            (OTS_ctrl    == 4'h0) ? t_OTS_1US   : t_OTS_1US;


  assign t_period     = t_period_sel      * 16'd2 - 16'd1;
  assign t_RESET_w    = t_RESET_w_timing  * 16'd2;
  assign t_delay      = t_delay_timing    * 16'd2;
  assign t_ILED_SW_w  = t_ILED_SW_w_sel   * 16'd2;

  assign RESET_h      = 16'b0;
  assign RESET_l      = t_RESET_w;

  assign ILED_SW_h    = RESET_l + t_delay;
  assign ILED_SW_l    = ILED_SW_h + t_ILED_SW_w;

  assign IIN_SW_h     = RESET_h;
  assign IIN_SW_l     = ILED_SW_l;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      counter <= 16'b0;
    end else if (counter == t_period) begin
      counter <= 16'b0;
    end else begin
      counter <= counter + 16'd1;
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      RESET_d <= 1'b0;
    end else if (counter == RESET_l) begin
      RESET_d <= 1'b0;
    end else if (counter == RESET_h) begin
      RESET_d <= 1'b1;
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      ILED_SW_d <= 1'b0;
    end else if (counter == ILED_SW_l) begin
      ILED_SW_d <= 1'b0;
    end else if (counter == ILED_SW_h) begin
      ILED_SW_d <= 1'b1;
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      IIN_SW_d  <= 1'b0;
    end else if (counter == IIN_SW_l) begin
      IIN_SW_d  <= 1'b0;
    end else if (counter == IIN_SW_h) begin
      IIN_SW_d  <= 1'b1;
    end
  end


  assign RESET    = RESET_d;
  assign ILED_SW  = ILED_SW_d;
  assign IIN_SW   = IIN_SW_d;

endmodule
