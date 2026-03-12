`timescale 1ns/1ps
`default_nettype none

module hpf_dyadic_leak #(
  parameter int IN_WIDTH       = 32,   // Q1.31
  parameter int STATE_WIDTH    = 64,   // wide state
  parameter int M_BITS         = 8,    // bits for m control
  parameter bit UNITY_RESCALE  = 1     // 1: output <<= m (with sat)
)(
  input  wire                       clk,
  input  wire                       clk_enable,
  input  wire                       reset,

  input  wire [M_BITS-1:0]          m,
  input  wire [7:0]                 K,

  input  wire signed [IN_WIDTH-1:0] filter_in,
  output reg  signed [IN_WIDTH-1:0] filter_out
);

  // Clamp control ranges
  localparam int M_MAX = (STATE_WIDTH-2 < (1<<M_BITS)-1) ? (STATE_WIDTH-2) : ((1<<M_BITS)-1);
  wire [M_BITS-1:0] m_c = (m > M_MAX[M_BITS-1:0]) ? M_MAX[M_BITS-1:0] : m;

  wire [7:0] K_c =
      (K < 8'd1) ? 8'd1 :
      (K >= STATE_WIDTH[7:0]) ? (STATE_WIDTH[7:0] - 8'd1) :
      K;

  // State
  reg  signed [STATE_WIDTH-1:0] y_st;
  reg  signed [IN_WIDTH-1:0]    x_1;

  // Extend to state width
  function automatic [STATE_WIDTH-1:0] sx_in;
    input signed [IN_WIDTH-1:0] v;
    begin
      sx_in = {{(STATE_WIDTH-IN_WIDTH){v[IN_WIDTH-1]}}, v};
    end
  endfunction

  // Saturate wide -> Q1.31
  function automatic [IN_WIDTH-1:0] sat_q31;
    input signed [STATE_WIDTH-1:0] v;
    reg signed [STATE_WIDTH-1:0] hi, lo;
    reg signed [IN_WIDTH-1:0] Q31_MAX, Q31_MIN;
    begin
      Q31_MAX = 32'sh7FFF_FFFF;
      Q31_MIN = 32'sh8000_0000;
      hi = {{(STATE_WIDTH-IN_WIDTH){1'b0}}, Q31_MAX};
      lo = {{(STATE_WIDTH-IN_WIDTH){1'b1}}, Q31_MIN};
      if (v > hi)       sat_q31 = Q31_MAX;
      else if (v < lo)  sat_q31 = Q31_MIN;
      else              sat_q31 = v[IN_WIDTH-1:0];
    end
  endfunction

  // Left shift with saturation
  function automatic [STATE_WIDTH-1:0] shl_sat_state;
    input signed [STATE_WIDTH-1:0] v;
    input [M_BITS-1:0] sh;
    reg signed [STATE_WIDTH-1:0] vmax, vmin, tmp;
    begin
      vmax = (1 <<< (STATE_WIDTH-2)) - 1;
      vmin = -(1 <<< (STATE_WIDTH-2));
      if (sh == 0) begin
        shl_sat_state = v;
      end else begin
        if (v > (vmax >>> sh))      shl_sat_state = vmax;
        else if (v < (vmin >>> sh)) shl_sat_state = vmin;
        else begin
          tmp = v <<< sh;
          shl_sat_state = tmp;
        end
      end
    end
  endfunction

  // Clamp state
  localparam signed [STATE_WIDTH-1:0] Y_MAX = (1 <<< (STATE_WIDTH-2)) - 1;
  localparam signed [STATE_WIDTH-1:0] Y_MIN = -(1 <<< (STATE_WIDTH-2));

  function automatic [STATE_WIDTH-1:0] clamp_state;
    input signed [STATE_WIDTH-1:0] v;
    begin
      if (v > Y_MAX) clamp_state = Y_MAX;
      else if (v < Y_MIN) clamp_state = Y_MIN;
      else                clamp_state = v;
    end
  endfunction

  // Main sequential
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      x_1        <= 0;
      y_st       <= 0;
      filter_out <= 0;
    end
    else if (clk_enable) begin
      // Delta input
      reg signed [IN_WIDTH-1:0]    dx;
      reg signed [STATE_WIDTH-1:0] dx_ext, dx_scaled, leak, y_next;

      dx       = filter_in - x_1;
      dx_ext   = sx_in(dx);
      dx_scaled = (m_c == 0) ? dx_ext : (dx_ext >>> m_c);

      leak     = (y_st >>> K_c);
      y_next   = y_st - leak + dx_scaled;

      y_st <= clamp_state(y_next);

      if (UNITY_RESCALE) begin
        filter_out <= sat_q31(shl_sat_state(y_st, m_c));
      end else begin
        filter_out <= sat_q31(y_st);
      end

      x_1 <= filter_in;
    end
  end

endmodule

`default_nettype wire

