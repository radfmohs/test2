module nirs_ppg_subtract_dout #(
  parameter IN_WDTH   = 13,
  parameter OUT_WIDTH = 19
) ( 
  input  wire                   rst_n,   // Active-low reset (optional)
  input  wire                   clk,     // Clock signal
  input  wire                   en,
  input  wire   [IN_WDTH-1:0]   DOUTF,   // 13-bit input
  input  wire   [IN_WDTH-1:0]   DOUTC,   // 13-bit input
  input  wire           [2:0]   RATIO_CTRL,
  input  wire           [7:0]   RATIO_MANUAL,
  output wire [OUT_WIDTH-1:0]   DOUT     // 20-bit registered output
);

// Calculate: (RATIO * DOUTC) - DOUTF
// Zero-extend DOUTF to 20 bits for correct subtraction
wire[18:0] sub_result;
reg [18:0] DOUT_reg;

wire [7:0] RATIO, RATIO_tmp;

assign RATIO_tmp =  (RATIO_CTRL[2:1] == 2'd0) ? 128 :
                    (RATIO_CTRL[2:1] == 2'd1) ?  64 :
                    (RATIO_CTRL[2:1] == 2'd2) ?  32 :
                    (RATIO_CTRL[2:1] == 2'd3) ?  16 : 128;

assign RATIO = RATIO_CTRL[0] ? RATIO_MANUAL : RATIO_tmp;

assign sub_result = (RATIO * DOUTC) - DOUTF;

// Update DOUT synchronously on rising clock edge
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        DOUT_reg <= {OUT_WIDTH{1'b0}};          // Reset to 0 (optional)
    end else if (en) begin
        DOUT_reg <= sub_result;     // Assign result to DOUT
    end
end

assign DOUT = DOUT_reg;

endmodule
