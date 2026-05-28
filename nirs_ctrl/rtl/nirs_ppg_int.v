module nirs_ppg_int (
  input  wire       scan_mode,
  input  wire       rst_n,
  input  wire       clk,
  input  wire [7:0] INT_CONFIG,
  input  wire       int_length_slct,

  input  wire       IREF_COARSE_ON_NOT_OFF,
  input  wire       IREF_COARSE_NOT_ON,
  input  wire       IREF_FINE_ON_NOT_OFF,
  input  wire       IREF_FINE_NOT_ON,
  input  wire       IDAC_MAX,
  input  wire       IDAC_MIN,
  input  wire       DATA_READY,

  input  wire       INT_CLR,
  output wire       INT,
  output wire       INT_IO
);

/*
  Clear logic
*/
  wire  INT_CLR_atpg;
  reg   INT_CLR_d, INT_CLR_dd;
  wire  INT_CLR_valid;
  wire  INT_CLR_sync;

  common_rst_sync u_int_clr_sync(
    .RSTINn    (rst_n),
    .RSTREQ    (INT_CLR),
    .CLK       (clk),
    .SE        (1'b0),
    .RSTBYPASS (scan_mode),  //tri change to fix dft issue
    .RSTOUTn   (INT_CLR_sync)
  );


  always @(posedge clk or negedge INT_CLR_sync) begin
    if (!INT_CLR_sync) begin
      INT_CLR_d   <= 1'b0;
      INT_CLR_dd  <= 1'b0;
    end else begin
      INT_CLR_d   <= 1'b1;
      INT_CLR_dd  <= INT_CLR_d;
    end
  end

  assign INT_CLR_atpg   = scan_mode ? 1'b0 : INT_CLR_d;
  assign INT_CLR_valid  = INT_CLR_atpg && ~INT_CLR_dd;

/*
  Interrupt logic
*/
  wire  IREF_COARSE_INT;
  wire  IDAC_MAX_INT;
  wire  IDAC_MIN_INT;
  wire  DATA_READY_INT;
  wire  INT_tmp;
  wire  INT_pulse;
  reg   INT_d;

  assign INT_tmp =  (DATA_READY              && INT_CONFIG[1]) ||
                    (IREF_COARSE_ON_NOT_OFF  && INT_CONFIG[2]) ||
                    (IREF_COARSE_NOT_ON      && INT_CONFIG[3]) ||
                    (IREF_FINE_NOT_ON        && INT_CONFIG[4]) ||
                    (IREF_FINE_ON_NOT_OFF    && INT_CONFIG[5]) ||
                    (IDAC_MAX                && INT_CONFIG[6]) ||
                    (IDAC_MIN                && INT_CONFIG[7]);

  



  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      INT_d <= 1'b0;
    end else if (INT_CLR_valid) begin
      INT_d <= 1'd0;
    end else if (INT_tmp) begin
      INT_d <= 1'b1;
    end
  end 

/*
  Generate a pulse of interrupt 
*/
  common_pulse_rising u_nirs_interrupt_rising (
  .d_in   (INT_d),
  .clk    (clk),
  .rst_   (rst_n),
  .d_out  (INT_pulse)
  );

  assign INT    = (INT_d && int_length_slct) || (INT_pulse && !int_length_slct);
  assign INT_IO = INT && INT_CONFIG[0];

endmodule