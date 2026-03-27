module nirs_ppg_wrapper #(
  parameter NO_OF_NIRS = 8
) (

  input  wire rst_n,
  input  wire scan_mode,
  input  wire clk_ppg, // Max: 8Mhz
  input  wire clk_sys, // Max: 2MHz

  output wire  [NO_OF_NIRS-1:0] LED_ON_IO,
  ana_nirs_if.nirs        ana_nirs_if,
  spi_nirs_if.nirs        spi_nirs_if
);

  wire   [3:0]  NIRS_PGG_MODE_SEL [NO_OF_NIRS-1:0];
  wire          NIRS_PPG_EN       [NO_OF_NIRS-1:0];   // NIRS/PPG enable
  wire          NIRS_PPG_MEAS     [NO_OF_NIRS-1:0];

  wire   [7:0]  RATIO_MANUAL      [NO_OF_NIRS-1:0];   // Value for manual mode
  wire   [2:0]  RATIO_CTRL        [NO_OF_NIRS-1:0];   // ratio[1:0], manual_en for Ratio

  wire  [18:0]  THRESHOLD_H       [NO_OF_NIRS-1:0];   // High threhold
  wire   [7:0]  THRESHOLD_L       [NO_OF_NIRS-1:0];   // Low threshold
  wire          IDAC_MANUAL_EN    [NO_OF_NIRS-1:0];   // Enable IDAC manual mode
  wire   [8:0]  IDAC_MANUAL       [NO_OF_NIRS-1:0];   // Value for manual mode

  wire   [2:0]  LED_STABLE_CTRL   [NO_OF_NIRS-1:0];
  wire   [1:0]  LED_OFF_CTRL      [NO_OF_NIRS-1:0];
  wire   [2:0]  REC_STABLE_CTRL   [NO_OF_NIRS-1:0];
  wire   [3:0]  PERIOD_CTRL       [NO_OF_NIRS-1:0];
  wire   [2:0]  RESET_CTRL        [NO_OF_NIRS-1:0];
  wire   [3:0]  OTS_CTRL          [NO_OF_NIRS-1:0];

  wire    [NO_OF_NIRS-1:0]    IREF_COARSE_ON_NOT_OFF;  
  wire    [NO_OF_NIRS-1:0]    IREF_COARSE_NOT_ON;      
  wire    [NO_OF_NIRS-1:0]    IREF_FINE_ON_NOT_OFF;    
  wire    [NO_OF_NIRS-1:0]    IREF_FINE_NOT_ON;        

  wire    [NO_OF_NIRS-1:0]    EN;                      
  wire    [NO_OF_NIRS-1:0]    RESET;                   
  wire    [NO_OF_NIRS-1:0]    IPD_SW;                  
  wire    [NO_OF_NIRS-1:0]    IIN_SW;                  
  wire    [NO_OF_NIRS-1:0]    LED_ON;                  

  wire    [8:0] IDAC              [NO_OF_NIRS-1:0];
  wire   [12:0] DOUTC             [NO_OF_NIRS-1:0];
  wire   [12:0] DOUTF             [NO_OF_NIRS-1:0];
  wire   [18:0] DOUT              [NO_OF_NIRS-1:0];

  wire          IREF_COARSE       [NO_OF_NIRS-1:0];
  wire          IREF_FINE         [NO_OF_NIRS-1:0];

genvar i;
generate
  for (i = 0; i < NO_OF_NIRS; i++) begin
    assign NIRS_PGG_MODE_SEL[i] = spi_nirs_if.NIRS_CTRL[i][0][3:0];
    assign RATIO_CTRL[i]        = spi_nirs_if.NIRS_CTRL[i][0][6:4];
    assign RATIO_MANUAL[i]      = spi_nirs_if.NIRS_CTRL[i][1];
    assign OTS_CTRL[i]          = spi_nirs_if.NIRS_CTRL[i][2][3:0];
    assign PERIOD_CTRL[i]       = spi_nirs_if.NIRS_CTRL[i][2][7:4];
    assign RESET_CTRL[i]        = spi_nirs_if.NIRS_CTRL[i][3][2:0];
    assign REC_STABLE_CTRL[i]   = spi_nirs_if.NIRS_CTRL[i][3][5:3];
    assign LED_OFF_CTRL[i]      = spi_nirs_if.NIRS_CTRL[i][3][7:6];
    assign LED_STABLE_CTRL[i]   = spi_nirs_if.NIRS_CTRL[i][4][2:0];
    assign IDAC_MANUAL_EN[i]    = spi_nirs_if.NIRS_CTRL[i][4][3];
    assign IDAC_MANUAL[i]       = {spi_nirs_if.NIRS_CTRL[i][4][4], spi_nirs_if.NIRS_CTRL[i][5]};
    assign THRESHOLD_H[i]       = {spi_nirs_if.NIRS_CTRL[i][6], spi_nirs_if.NIRS_CTRL[i][7], spi_nirs_if.NIRS_CTRL[i][8][7:5]};
    assign THRESHOLD_L[i]       = {spi_nirs_if.NIRS_CTRL[i][8][4:0], spi_nirs_if.NIRS_CTRL[i][9][7:5]};
    assign NIRS_PPG_EN[i]       = spi_nirs_if.NIRS_CTRL_EN[i];
    assign NIRS_PPG_MEAS[i]     = spi_nirs_if.NIRS_CTRL_MEAS[i];

    assign spi_nirs_if.NIRS_DEBUG[i][0] = {3'b0, DOUTF[i][12:8]};
    assign spi_nirs_if.NIRS_DEBUG[i][1] = DOUTF[i][7:0];
    assign spi_nirs_if.NIRS_DEBUG[i][2] = DOUTC[i][12:5];
    assign spi_nirs_if.NIRS_DEBUG[i][3] = {DOUTC[i][4:0], 2'b0, IDAC[i][8]};
    assign spi_nirs_if.NIRS_DEBUG[i][4] = IDAC[i][7:0];
    assign spi_nirs_if.NIRS_DEBUG[i][5] = {4'b0, IREF_COARSE_ON_NOT_OFF[i], IREF_COARSE_NOT_ON[i], IREF_FINE_ON_NOT_OFF[i], IREF_FINE_NOT_ON[i]};

    assign ana_nirs_if.D2A_NIRS_EN[i]       = EN[i];
    assign ana_nirs_if.D2A_NIRS_RESET_SW[i] = RESET[i];
    assign ana_nirs_if.D2A_NIRS_IPD_SW[i]   = IPD_SW[i];
    assign ana_nirs_if.D2A_NIRS_IIN_SW[i]   = IIN_SW[i];
    assign ana_nirs_if.D2A_NIRS_IDAC[i]     = IDAC[i];
    assign ana_nirs_if.D2A_NIRS_RATIO[i]    = spi_nirs_if.NIRS_CTRL[i][0][6:5];
    assign IREF_COARSE[i] = ana_nirs_if.A2D_NIRS_IREFCOARSE[i];
    assign IREF_FINE[i]   = ana_nirs_if.A2D_NIRS_IREFFINE[i];
     
  end
endgenerate


assign spi_nirs_if.NIRS_DOUT[0]   = DOUT[0][18:11];
assign spi_nirs_if.NIRS_DOUT[1]   = DOUT[0][10:3];
assign spi_nirs_if.NIRS_DOUT[2]   = {DOUT[0][2:0], DOUT[1][18:14]};
assign spi_nirs_if.NIRS_DOUT[3]   = DOUT[1][13:6];
assign spi_nirs_if.NIRS_DOUT[4]   = {DOUT[1][5:0], DOUT[2][18:17]};
assign spi_nirs_if.NIRS_DOUT[5]   = DOUT[2][16:9];
assign spi_nirs_if.NIRS_DOUT[6]   = DOUT[2][8:1];
assign spi_nirs_if.NIRS_DOUT[7]   = {DOUT[2][0], DOUT[3][18:12]};
assign spi_nirs_if.NIRS_DOUT[8]   = DOUT[3][11:4];
assign spi_nirs_if.NIRS_DOUT[9]   = {DOUT[3][3:0], DOUT[4][18:15]};
assign spi_nirs_if.NIRS_DOUT[10]  = DOUT[4][14:7];
assign spi_nirs_if.NIRS_DOUT[11]  = {DOUT[4][6:0], DOUT[5][18]};
assign spi_nirs_if.NIRS_DOUT[12]  = DOUT[5][17:10];
assign spi_nirs_if.NIRS_DOUT[13]  = DOUT[5][9:2];
assign spi_nirs_if.NIRS_DOUT[14]  = {DOUT[5][1:0], DOUT[6][18:13]};
assign spi_nirs_if.NIRS_DOUT[15]  = DOUT[6][12:5];
assign spi_nirs_if.NIRS_DOUT[16]  = {DOUT[6][4:0], DOUT[7][18:16]};
assign spi_nirs_if.NIRS_DOUT[17]  = DOUT[7][15:8];
assign spi_nirs_if.NIRS_DOUT[18]  = DOUT[7][7:0];

assign LED_ON_IO  = LED_ON; // Control external LED



nirs_ppg_ctrl_top u_nirs_ctrl_top [NO_OF_NIRS-1:0] (
  .rst_n                  (rst_n),
  .scan_mode              (scan_mode),
  .clk_ppg                (clk_ppg),
  .clk_sys                (clk_sys),

  .NIRS_PGG_MODE_SEL_spi  (NIRS_PGG_MODE_SEL),
  .NIRS_PPG_EN_spi        (NIRS_PPG_EN),
  .NIRS_PPG_MEAS_spi      (NIRS_PPG_MEAS),

// RATIO for DOUT - OPTIONAL for MANUAL MODE
  .RATIO_MANUAL_spi       (RATIO_MANUAL),
  .RATIO_CTRL_spi         (RATIO_CTRL),

// Thresholds and manual mode for IDAC - MUST have manual mode
  .THRESHOLD_H_spi        (THRESHOLD_H),  
  .THRESHOLD_L_spi        (THRESHOLD_L),  
  .IDAC_MANUAL_EN_spi     (IDAC_MANUAL_EN),
  .IDAC_MANUAL_spi        (IDAC_MANUAL),

// Pulse config signals - Users control
  .LED_STABLE_CTRL_spi    (LED_STABLE_CTRL),
  .LED_OFF_CTRL_spi       (LED_OFF_CTRL),
  .REC_STABLE_CTRL_spi    (REC_STABLE_CTRL),
  .PERIOD_CTRL_spi        (PERIOD_CTRL),
  .RESET_CTRL_spi         (RESET_CTRL),
  .OTS_CTRL_spi           (OTS_CTRL),

// FLAGs
  .IREF_COARSE_ON_NOT_OFF (IREF_COARSE_ON_NOT_OFF),
  .IREF_COARSE_NOT_ON     (IREF_COARSE_NOT_ON),
  .IREF_FINE_ON_NOT_OFF   (IREF_FINE_ON_NOT_OFF),
  .IREF_FINE_NOT_ON       (IREF_FINE_NOT_ON),

// Pulses to Analog
  .EN                     (EN),
  .RESET                  (RESET),
  .IPD_SW                 (IPD_SW),
  .IIN_SW                 (IIN_SW),
  .LED_ON                 (LED_ON),

// Counters to Analog
  .IDAC                   (IDAC),
  .DOUTC                  (DOUTC),
  .DOUTF                  (DOUTF),
  .DOUT                   (DOUT),

// From Analog
  .IREF_COARSE            (IREF_COARSE),
  .IREF_FINE              (IREF_FINE)

);

endmodule