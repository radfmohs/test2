module nirs_ppg_clk (
  input  wire rst_n,
  input  wire atpg_en,
  input  wire bypass,
  input  wire i_clk_sys,
  input  wire i_clk_ppg,
  output wire o_clk_sys,
  output wire o_clk_ppg,
  input  wire CLK_START,
  input  wire CLK_STOP
);

  reg CLK_EN;

  always @(posedge i_clk_sys or negedge rst_n) begin
    if (!rst_n) begin
      CLK_EN <= 1'b0;
    end else if (CLK_STOP) begin
      CLK_EN <= 1'b0;
    end else if (CLK_START) begin
      CLK_EN <= 1'b1;
    end
  end


  common_clock_gate u_clk_sys_gate (
    .clk        (i_clk_sys),
    .enable     (CLK_EN),
    .bypass     (atpg_en || bypass),
    .gated_clk  (o_clk_sys)
  );

  common_clock_gate u_clk_ppg_gate (
    .clk        (i_clk_ppg),
    .enable     (CLK_EN),
    .bypass     (atpg_en || bypass),
    .gated_clk  (o_clk_ppg)
  );

endmodule

