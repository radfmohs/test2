module nirs_ppg_latch #(
  parameter LATCH_WIDTH = 13
) (
  input  wire                   rst_n,
  input  wire                   clk,
  input  wire                   en,
  input  wire [LATCH_WIDTH-1:0] in,
  output wire [LATCH_WIDTH-1:0] out
);

  reg [LATCH_WIDTH-1:0] latch_reg;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      latch_reg <= {LATCH_WIDTH{1'b0}};
    end else if (en) begin
      latch_reg <= in;
    end
  end

  assign out = latch_reg;

endmodule