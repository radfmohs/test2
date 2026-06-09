module nirs_ppg_subtract_dout #(
  parameter IN_WDTH   = 13,
  parameter OUT_WIDTH = 22
) ( 
  input  wire                   rst_n,   // Active-low reset (optional)
  input  wire                   clk,     // Clock signal
  input  wire                   en,
  input  wire   [IN_WDTH-1:0]   DOUTF,   // 13-bit input
  input  wire   [IN_WDTH-1:0]   DOUTC,   // 13-bit input
  input  wire           [1:0]   AVG_SEL,
  input  wire           [2:0]   RATIO_CTRL,
  input  wire           [7:0]   RATIO_MANUAL,
  output wire [OUT_WIDTH-1:0]   DOUT     // 20-bit registered output
);
wire  [2:0] SHIFT, RATIO_CTRL_sel;
wire  [7:0] RATIO_MANUAL_sel;

assign RATIO_CTRL_sel   = RATIO_CTRL;
assign RATIO_MANUAL_sel = RATIO_MANUAL;

assign SHIFT            = (AVG_SEL == 0) ? 0 :
                          (AVG_SEL == 1) ? 1 :
                          (AVG_SEL == 2) ? 2 :
                          (AVG_SEL == 3) ? 4 : 0;

// Calculate: (RATIO * DOUTC) - DOUTF
// Zero-extend DOUTF to 20 bits for correct subtraction
wire[OUT_WIDTH-1:0] sub_result;
wire[OUT_WIDTH-1:0] DOUT_tmp;
reg [OUT_WIDTH-1:0] DOUT_reg;

wire [7:0] RATIO, RATIO_tmp;

assign RATIO_tmp =  (RATIO_CTRL_sel[2:1] == 2'd0) ? 8'd128 :
                    (RATIO_CTRL_sel[2:1] == 2'd1) ?  8'd64 :
                    (RATIO_CTRL_sel[2:1] == 2'd2) ?  8'd32 :
                    (RATIO_CTRL_sel[2:1] == 2'd3) ?  8'd16 : 8'd128;

assign RATIO = RATIO_CTRL_sel[0] ? RATIO_MANUAL_sel : RATIO_tmp;

assign sub_result = (RATIO * DOUTC) - DOUTF;

/*
  SHIFT = 0 -> DOUT =                        sub_result
  SHIFT = 1 -> DOUT = (01/02) DOUT + (01/02) sub_result
  SHIFT = 2 -> DOUT = (03/04) DOUT + (01/04) sub_result
  SHIFT = 4 -> DOUT = (15/16) DOUT + (01/16) sub_result
*/

assign DOUT_tmp   = (sub_result < DOUT_reg) ? DOUT_reg - ((DOUT_reg - sub_result) >> SHIFT) : DOUT_reg + ((sub_result - DOUT_reg) >> SHIFT);

// Update DOUT synchronously on rising clock edge
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        DOUT_reg <= {OUT_WIDTH{1'b0}};  // Reset to 0 (optional)
    end else if (en) begin
        DOUT_reg <= DOUT_tmp;         // Assign result to DOUT
    end
end

assign DOUT = DOUT_reg;

endmodule
