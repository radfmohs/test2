//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap ENS2  
// File name:    nirs_ppg_ctrl.v 
// Module Name : nirs_ppg_ctrl
// Description : 
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author          Description      
//------------------------------------------------------------------------------
// 0.1                                      Initial Rev 
//------------------------------------------------------------------------------
module nirs_ppg_ctrl (
  input  wire   rst_n,
  input  wire   clk,


  input  wire   RESET,
  input  wire   IREF_COARSE,
  input  wire   IREF_FINE,

  output wire   IDAC_UPDATE_EN,
  output wire   QC_COUNTER_EN,
  output wire   QF_COUNTER_EN,
  output wire   DOUTC_LATCH_EN,
  output wire   DOUTF_LATCH_EN,
  output wire   DOUT_EN

);

  reg [2:0] cur, next;
  localparam IDLE                  = 3'd0;
  localparam IDAC_UPDATE           = 3'd1;
  localparam LATCHING_IREF_COARSE  = 3'd2;
  localparam LATCHING_IREF_FINE    = 3'd3; 
  localparam HOLDING               = 3'd4; 

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) 
      cur <= IDLE;
    else
      cur <= next;
  end

  always @(*) begin
    case(cur) 

      IDLE: begin
        if (RESET)
          next = IDAC_UPDATE;
        else  
          next = cur;
      end

      IDAC_UPDATE: begin
        next = LATCHING_IREF_COARSE;
      end

      LATCHING_IREF_COARSE: begin
        if (IREF_COARSE)
          next = LATCHING_IREF_FINE;
        else
          next = cur;
      end

      LATCHING_IREF_FINE: begin
        if (IREF_FINE)
          next = HOLDING;
        else
          next = cur;
      end

      HOLDING: begin
        if (!IREF_FINE)
          next = IDLE;
        else
          next = cur;
      end

      default: begin
        next = IDLE;
      end 

    endcase
  end


  wire IREF_COARSE_L, IREF_FINE_L, IREF_COARSE_L_N, IREF_FINE_L_N;
  reg  IREF_COARSE_L_d, IREF_FINE_L_d, IREF_FINE_L_N_d;

  assign IREF_COARSE_L  = (cur != IDLE) & IREF_COARSE;
  assign IREF_FINE_L    = (cur != IDLE) & IREF_FINE;

  assign IREF_COARSE_L_N  = !IREF_COARSE_L & IREF_COARSE_L_d;
  assign IREF_FINE_L_N    = !IREF_FINE_L   & IREF_FINE_L_d;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      IREF_COARSE_L_d <= 1'b0;
      IREF_FINE_L_d   <= 1'b0;
      IREF_FINE_L_N_d <= 1'b0;
    end else begin
      IREF_COARSE_L_d <= IREF_COARSE_L;
      IREF_FINE_L_d   <= IREF_FINE_L;
      IREF_FINE_L_N_d <= IREF_FINE_L_d;
    end
  end


/*
  OUTPUTs
*/  
  assign IDAC_UPDATE_EN   = (cur == IDAC_UPDATE);
  assign QC_COUNTER_EN    = IREF_COARSE_L;
  assign QF_COUNTER_EN    = IREF_FINE_L;
  assign DOUTC_LATCH_EN   = IREF_COARSE_L_N;
  assign DOUTF_LATCH_EN   = IREF_FINE_L_N;
  assign DOUT_EN          = IREF_FINE_L_N_d;


endmodule  
