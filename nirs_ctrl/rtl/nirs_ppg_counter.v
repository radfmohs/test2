module nirs_ppg_counter #(
  parameter COUNTER_WIDTH = 13
) (
  input   rst_n, // system reset
  input   clk,
  input   RESET,
  input   enable,
  output wire [COUNTER_WIDTH-1:0] out
);

  reg [COUNTER_WIDTH-1:0] counter_reg;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      counter_reg <= {COUNTER_WIDTH{1'b0}};
    end else if (RESET) begin
      counter_reg <= 0;
    end else if (enable) begin
      counter_reg <= counter_reg + 1;
    end else begin
      counter_reg <= counter_reg;
    end
  end

  assign out = counter_reg;


endmodule  
