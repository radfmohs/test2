
//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2026
//------------------------------------------------------------------------------
// Project name: Nanochap ENS2  
// Module Name : NIRS/PPF WRAPPER
// Description : A wrapper to instatiate and connect signals for 8 channels  
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Design
//------------------------------------------------------------------------------
// 0.1          18/04/2026  Truong Pham
// Initial Rev
//------------------------------------------------------------------------------
module nirs_ppg_wrapper #(
  parameter NO_OF_NIRS = 8
) (
  input  wire scan_en,
  input  wire scan_mode, 
  input  wire rst_n,
  input  wire clk_ana,
  input  wire clk_ppg, // Max: 8Mhz
  input  wire clk_sys, // Max: 2MHz
  input  wire clk_gate_bypass,

  output wire  [NO_OF_NIRS-1:0] LED_ON_IO,
  input  wire                   int_length_slct,
  output wire                   INT_IO,

  ana_nirs_if.nirs        ana_nirs_if,
  spi_nirs_if.nirs        spi_nirs_if
);

  wire  [NO_OF_NIRS-1:0] clk_sys_gated;
  wire  [NO_OF_NIRS-1:0] clk_ppg_gated;
  wire  [NO_OF_NIRS-1:0] CLK_STOP;

  wire   [5:0]  NIRS_PPG_MODE_SEL [NO_OF_NIRS-1:0];

  wire  [NO_OF_NIRS-1:0] NIRS_PPG_EN, NIRS_PPG_MEAS;
  wire  [NO_OF_NIRS-1:0] NIRS_SINGLE;

  wire   [1:0]  AVG_SEL_0       [NO_OF_NIRS-1:0];
  wire   [1:0]  AVG_SEL_1       [NO_OF_NIRS-1:0];

  wire   [7:0]  RATIO_MANUAL_0  [NO_OF_NIRS-1:0];   // Value for manual mode
  wire   [2:0]  RATIO_CTRL_0    [NO_OF_NIRS-1:0];   // ratio[1:0], manual_en for Ratio
  wire   [7:0]  RATIO_MANUAL_1  [NO_OF_NIRS-1:0];   // Value for manual mode
  wire   [2:0]  RATIO_CTRL_1    [NO_OF_NIRS-1:0];   // ratio[1:0], manual_en for Ratio
  wire   [1:0]  RATIO_CTRL      [NO_OF_NIRS-1:0];   // ratio[1:0], manual_en for Ratio

  wire   [1:0]  IPDMIRROR_ADJ   [NO_OF_NIRS-1:0];
  wire   [1:0]  IREFC_ADJ       [NO_OF_NIRS-1:0];
  wire   [1:0]  IPDMIRROR_ADJ_0 [NO_OF_NIRS-1:0];
  wire   [1:0]  IREFC_ADJ_0     [NO_OF_NIRS-1:0];
  wire   [1:0]  IPDMIRROR_ADJ_1 [NO_OF_NIRS-1:0];
  wire   [1:0]  IREFC_ADJ_1     [NO_OF_NIRS-1:0];

  wire  [18:0]  THRESHOLD_H_0     [NO_OF_NIRS-1:0];   // High threhold
  wire   [7:0]  THRESHOLD_L_0     [NO_OF_NIRS-1:0];   // Low threshold
  wire          IDAC_MANUAL_EN_0  [NO_OF_NIRS-1:0];   // Enable IDAC manual mode
  wire   [8:0]  IDAC_MANUAL_0     [NO_OF_NIRS-1:0];   // Value for manual mode
  wire          IDAC_IDAC_EN_0    [NO_OF_NIRS-1:0];   // Value for manual mode

  wire   [2:0]  LED_STABLE_CTRL_0 [NO_OF_NIRS-1:0];
  wire   [1:0]  LED_OFF_CTRL_0    [NO_OF_NIRS-1:0];
  wire   [2:0]  REC_STABLE_CTRL_0 [NO_OF_NIRS-1:0];
  wire   [3:0]  PERIOD_CTRL_0     [NO_OF_NIRS-1:0];
  wire   [2:0]  RESET_CTRL_0      [NO_OF_NIRS-1:0];
  wire   [3:0]  OTS_CTRL_0        [NO_OF_NIRS-1:0];                  

  wire  [18:0]  THRESHOLD_H_1     [NO_OF_NIRS-1:0];   // High threhold
  wire   [7:0]  THRESHOLD_L_1     [NO_OF_NIRS-1:0];   // Low threshold
  wire          IDAC_MANUAL_EN_1  [NO_OF_NIRS-1:0];   // Enable IDAC manual mode
  wire   [8:0]  IDAC_MANUAL_1     [NO_OF_NIRS-1:0];   // Value for manual mode
  wire          IDAC_IDAC_EN_1    [NO_OF_NIRS-1:0];   // Value for manual mode

  wire   [2:0]  LED_STABLE_CTRL_1 [NO_OF_NIRS-1:0];
  wire   [1:0]  LED_OFF_CTRL_1    [NO_OF_NIRS-1:0];
  wire   [2:0]  REC_STABLE_CTRL_1 [NO_OF_NIRS-1:0];
  wire   [3:0]  PERIOD_CTRL_1     [NO_OF_NIRS-1:0];
  wire   [2:0]  RESET_CTRL_1      [NO_OF_NIRS-1:0];
  wire   [3:0]  OTS_CTRL_1        [NO_OF_NIRS-1:0];

  wire   [1:0]  CMD               [NO_OF_NIRS-1:0];

  wire    [NO_OF_NIRS-1:0]    IREF_COARSE_ON_NOT_OFF;  
  wire    [NO_OF_NIRS-1:0]    IREF_COARSE_NOT_ON;      
  wire    [NO_OF_NIRS-1:0]    IREF_FINE_ON_NOT_OFF;    
  wire    [NO_OF_NIRS-1:0]    IREF_FINE_NOT_ON;  
  wire    [NO_OF_NIRS-1:0]    IDAC_MAX;
  wire    [NO_OF_NIRS-1:0]    IDAC_MIN;

  wire    [NO_OF_NIRS-1:0]    EN;                      
  wire    [NO_OF_NIRS-1:0]    RESET;                   
  wire    [NO_OF_NIRS-1:0]    IPD_SW;                  
  wire    [NO_OF_NIRS-1:0]    IIN_SW;                  
  wire    [NO_OF_NIRS-1:0]    LED_ON;   

/* Interrupts */
  wire               [7:0]    NIRS_PPG_INT_SEL  [NO_OF_NIRS-1:0];
  wire    [NO_OF_NIRS-1:0]    INT_IO_tmp;
  wire    [NO_OF_NIRS-1:0]    INT; 
  wire    [NO_OF_NIRS-1:0]    INT_CLR;                  

  wire          IDAC_EN           [NO_OF_NIRS-1:0];
  wire    [8:0] IDAC              [NO_OF_NIRS-1:0];
  wire   [12:0] DOUTC             [NO_OF_NIRS-1:0];
  wire   [12:0] DOUTF             [NO_OF_NIRS-1:0];
  wire   [21:0] DOUT              [NO_OF_NIRS-1:0];

  wire          IREF_COARSE       [NO_OF_NIRS-1:0];
  wire          IREF_FINE         [NO_OF_NIRS-1:0];

genvar i, j;
generate
  for (i = 0; i < NO_OF_NIRS; i++) begin
    assign PERIOD_CTRL_0      [i]  =  spi_nirs_if.NIRS_CTRL[i][0][0][7:4];
    assign OTS_CTRL_0         [i]  =  spi_nirs_if.NIRS_CTRL[i][0][0][3:0];
    assign LED_OFF_CTRL_0     [i]  =  spi_nirs_if.NIRS_CTRL[i][0][1][7:6];
    assign RESET_CTRL_0       [i]  =  spi_nirs_if.NIRS_CTRL[i][0][1][5:3];
    assign LED_STABLE_CTRL_0  [i]  =  spi_nirs_if.NIRS_CTRL[i][0][1][2:0];
    assign AVG_SEL_0          [i]  =  spi_nirs_if.NIRS_CTRL[i][0][2][7:6];
    assign IDAC_MANUAL_0      [i]  = {spi_nirs_if.NIRS_CTRL[i][0][2][5:0], spi_nirs_if.NIRS_CTRL[i][0][3][7:5]};
    assign IDAC_MANUAL_EN_0   [i]  =  spi_nirs_if.NIRS_CTRL[i][0][3][4];
    assign IDAC_IDAC_EN_0     [i]  =  spi_nirs_if.NIRS_CTRL[i][0][3][3];
    assign THRESHOLD_H_0      [i]  = {spi_nirs_if.NIRS_CTRL[i][0][3][2:0], spi_nirs_if.NIRS_CTRL[i][0][4], spi_nirs_if.NIRS_CTRL[i][0][5]};
    assign THRESHOLD_L_0      [i]  =  spi_nirs_if.NIRS_CTRL[i][0][6];
    assign IPDMIRROR_ADJ_0    [i] =   spi_nirs_if.NIRS_CTRL[i][0][7][6:5];
    assign IREFC_ADJ_0        [i] =   spi_nirs_if.NIRS_CTRL[i][0][7][4:3];
    assign RATIO_CTRL_0       [i] =   spi_nirs_if.NIRS_CTRL[i][0][7][2:0];
    assign RATIO_MANUAL_0     [i] =   spi_nirs_if.NIRS_CTRL[i][0][8];


    assign PERIOD_CTRL_1      [i]  =  spi_nirs_if.NIRS_CTRL[i][1][0][7:4];
    assign OTS_CTRL_1         [i]  =  spi_nirs_if.NIRS_CTRL[i][1][0][3:0];
    assign LED_OFF_CTRL_1     [i]  =  spi_nirs_if.NIRS_CTRL[i][1][1][7:6];
    assign RESET_CTRL_1       [i]  =  spi_nirs_if.NIRS_CTRL[i][1][1][5:3];
    assign LED_STABLE_CTRL_1  [i]  =  spi_nirs_if.NIRS_CTRL[i][1][1][2:0];
    assign AVG_SEL_1          [i]  =  spi_nirs_if.NIRS_CTRL[i][1][2][7:6];
    assign IDAC_MANUAL_1      [i]  = {spi_nirs_if.NIRS_CTRL[i][1][2][5:0], spi_nirs_if.NIRS_CTRL[i][1][3][7:5]};
    assign IDAC_MANUAL_EN_1   [i]  =  spi_nirs_if.NIRS_CTRL[i][1][3][4];
    assign IDAC_IDAC_EN_1     [i]  =  spi_nirs_if.NIRS_CTRL[i][1][3][3];
    assign THRESHOLD_H_1      [i]  = {spi_nirs_if.NIRS_CTRL[i][1][3][2:0], spi_nirs_if.NIRS_CTRL[i][1][4], spi_nirs_if.NIRS_CTRL[i][1][5]};
    assign THRESHOLD_L_1      [i]  =  spi_nirs_if.NIRS_CTRL[i][1][6];
    assign IPDMIRROR_ADJ_1    [i] =   spi_nirs_if.NIRS_CTRL[i][1][7][6:5];
    assign IREFC_ADJ_1        [i] =   spi_nirs_if.NIRS_CTRL[i][1][7][4:3];
    assign RATIO_CTRL_1       [i] =   spi_nirs_if.NIRS_CTRL[i][1][7][2:0];
    assign RATIO_MANUAL_1     [i] =   spi_nirs_if.NIRS_CTRL[i][1][8];

    assign NIRS_PPG_MODE_SEL  [i]  =  spi_nirs_if.NIRS_CTRL_MODE[i][5:0];
    assign NIRS_SINGLE        [i]  = (NIRS_PPG_MODE_SEL[i][3] == 1'b1) || (NIRS_PPG_MODE_SEL[i][0] == 1'b1);
    assign NIRS_PPG_INT_SEL   [i]  =  spi_nirs_if.NIRS_CTRL_INT[i];
    assign INT_CLR            [i]  =  spi_nirs_if.NIRS_INT_CLR[i];
    assign spi_nirs_if.NIRS_INT[i] =  INT[i];

    assign CMD[i] = spi_nirs_if.NIRS_CTRL_CMD[i];

    assign spi_nirs_if.NIRS_DEBUG[i][0] = {3'b0, DOUTF[i][12:8]};
    assign spi_nirs_if.NIRS_DEBUG[i][1] = DOUTF[i][7:0];
    assign spi_nirs_if.NIRS_DEBUG[i][2] = {3'b0, DOUTC[i][12:8]};
    assign spi_nirs_if.NIRS_DEBUG[i][3] = {DOUTC[i][7:0]};
    assign spi_nirs_if.NIRS_DEBUG[i][4] = {2'b0, IDAC_MAX[i], IDAC_MIN[i], IREF_COARSE_ON_NOT_OFF[i], IREF_COARSE_NOT_ON[i], IREF_FINE_ON_NOT_OFF[i], IREF_FINE_NOT_ON[i]};

    assign ana_nirs_if.D2A_NIRS_EN        [i] = EN[i];
    assign ana_nirs_if.D2A_IDAC_EN        [i] = IDAC_EN[i];
    assign ana_nirs_if.D2A_NIRS_RESET_SW  [i] = RESET[i];
    assign ana_nirs_if.D2A_NIRS_IPD_SW    [i] = IPD_SW[i];
    assign ana_nirs_if.D2A_NIRS_IIN_SW    [i] = IIN_SW[i];
    assign ana_nirs_if.D2A_IPDMIRROR_ADJ  [i] = IPDMIRROR_ADJ[i];
    assign ana_nirs_if.D2A_IREFC_ADJ      [i] = IREFC_ADJ[i];
    assign ana_nirs_if.D2A_NIRS_IDAC      [i] = IDAC[i];
    assign ana_nirs_if.D2A_NIRS_RATIO     [i] = RATIO_CTRL[i];

    assign IREF_COARSE  [i] = ana_nirs_if.A2D_NIRS_IREFCOARSE[i];
    assign IREF_FINE    [i] = ana_nirs_if.A2D_NIRS_IREFFINE[i];


    assign spi_nirs_if.NIRS_DOUT[i][0]  = {INT[i], DOUT[i][21:15]};
    assign spi_nirs_if.NIRS_DOUT[i][1]  = {DOUT[i][14:7]};
    assign spi_nirs_if.NIRS_DOUT[i][2]  = {DOUT[i][6:0], IDAC[i][8]};
    assign spi_nirs_if.NIRS_DOUT[i][3]  = IDAC[i][7:0];

  end
endgenerate

assign ana_nirs_if.IDAC_MANUAL_ATM    = IDAC_MANUAL_1[4]; // For CP test only - No functional use
assign ana_nirs_if.D2A_NIRS_POWER_EN  = spi_nirs_if.NIRS_CTRL_ADJ[7];
assign ana_nirs_if.D2A_PDBIAS_EN      = spi_nirs_if.NIRS_CTRL_ADJ[6];
assign ana_nirs_if.D2A_PDBIAS_ADJ     = spi_nirs_if.NIRS_CTRL_ADJ[5:4];
assign ana_nirs_if.D2A_CLK_NIRS       = clk_ana;
assign ana_nirs_if.D2A_FCHOP_ADJ      = spi_nirs_if.NIRS_CTRL_ADJ[3:2];
assign ana_nirs_if.D2A_CHOPPER_EN     = spi_nirs_if.NIRS_CTRL_ADJ[1];
assign ana_nirs_if.D2A_TEST_EN        = spi_nirs_if.NIRS_CTRL_ADJ[0];

assign LED_ON_IO  = LED_ON; // Control external LED

nirs_ppg_cmd u_nirs_ppg_cmd  [NO_OF_NIRS-1:0] (
  .rst_n          (rst_n),
  .atpg_en        (scan_en),
  .clk_gate_bypass(clk_gate_bypass),
  .i_clk_sys      (clk_sys),
  .i_clk_ppg      (clk_ppg),
  .o_clk_sys_gated(clk_sys_gated),
  .o_clk_ppg_gated(clk_ppg_gated),
  .CMD            (CMD),
  .NIRS_SINGLE    (NIRS_SINGLE),
  .NIRS_PPG_EN    (NIRS_PPG_EN),
  .NIRS_PPG_MEAS  (NIRS_PPG_MEAS),
  .CLK_STOP       (CLK_STOP)

);

nirs_ppg_ctrl_top u_nirs_ctrl_top [NO_OF_NIRS-1:0] (
  .scan_mode              (scan_mode),
  .rst_n                  (rst_n),
  .clk_ppg                (clk_ppg_gated),
  .clk_sys                (clk_sys_gated),
  .COUNT_STOP             (CLK_STOP),

  .NIRS_PPG_MODE_SEL_spi  (NIRS_PPG_MODE_SEL),
  .NIRS_PPG_EN_spi        (NIRS_PPG_EN),
  .NIRS_PPG_MEAS_spi      (NIRS_PPG_MEAS),

// AVG SEL for DOUT 
  .AVG_SEL_spi_0          (AVG_SEL_0),
  .AVG_SEL_spi_1          (AVG_SEL_1),

// RATIO for DOUT - OPTIONAL for MANUAL MODE
  .RATIO_MANUAL_spi_0     (RATIO_MANUAL_0),
  .RATIO_CTRL_spi_0       (RATIO_CTRL_0),

  .RATIO_MANUAL_spi_1     (RATIO_MANUAL_1),
  .RATIO_CTRL_spi_1       (RATIO_CTRL_1),

  .D2A_RATIO_CTRL         (RATIO_CTRL),

// Thresholds and manual mode for IDAC - MUST have manual mode
  .THRESHOLD_H_spi_0      (THRESHOLD_H_0),  
  .THRESHOLD_L_spi_0      (THRESHOLD_L_0),  
  .IDAC_MANUAL_EN_spi_0   (IDAC_MANUAL_EN_0),
  .IDAC_MANUAL_spi_0      (IDAC_MANUAL_0),
  .IDAC_IDAC_EN_spi_0     (IDAC_IDAC_EN_0),
  .IPDMIRROR_ADJ_spi_0    (IPDMIRROR_ADJ_0),
  .IREFC_ADJ_spi_0        (IREFC_ADJ_0),

  .THRESHOLD_H_spi_1      (THRESHOLD_H_1),  
  .THRESHOLD_L_spi_1      (THRESHOLD_L_1),  
  .IDAC_MANUAL_EN_spi_1   (IDAC_MANUAL_EN_1),
  .IDAC_MANUAL_spi_1      (IDAC_MANUAL_1),
  .IDAC_IDAC_EN_spi_1     (IDAC_IDAC_EN_1),
  .IPDMIRROR_ADJ_spi_1    (IPDMIRROR_ADJ_1),
  .IREFC_ADJ_spi_1        (IREFC_ADJ_1),

  .IPDMIRROR_ADJ          (IPDMIRROR_ADJ),
  .IREFC_ADJ              (IREFC_ADJ),

// Pulse config signals - Users control
  .LED_STABLE_CTRL_spi_0  (LED_STABLE_CTRL_0),
  .LED_OFF_CTRL_spi_0     (LED_OFF_CTRL_0),
  .PERIOD_CTRL_spi_0      (PERIOD_CTRL_0),
  .RESET_CTRL_spi_0       (RESET_CTRL_0),
  .OTS_CTRL_spi_0         (OTS_CTRL_0),

  .LED_STABLE_CTRL_spi_1  (LED_STABLE_CTRL_1),
  .LED_OFF_CTRL_spi_1     (LED_OFF_CTRL_1),
  .PERIOD_CTRL_spi_1      (PERIOD_CTRL_1),
  .RESET_CTRL_spi_1       (RESET_CTRL_1),
  .OTS_CTRL_spi_1         (OTS_CTRL_1),


  

// FLAGs
  .IREF_COARSE_ON_NOT_OFF (IREF_COARSE_ON_NOT_OFF),
  .IREF_COARSE_NOT_ON     (IREF_COARSE_NOT_ON),
  .IREF_FINE_ON_NOT_OFF   (IREF_FINE_ON_NOT_OFF),
  .IREF_FINE_NOT_ON       (IREF_FINE_NOT_ON),
  .IDAC_MAX               (IDAC_MAX),
  .IDAC_MIN               (IDAC_MIN),

// Pulses to Analog
  .EN                     (EN),
  .RESET                  (RESET),
  .IPD_SW                 (IPD_SW),
  .IIN_SW                 (IIN_SW),
  .LED_ON                 (LED_ON),

// Interrupts
  .NIRS_PPG_INT_SEL_spi   (NIRS_PPG_INT_SEL),
  .int_length_slct_spi    (int_length_slct),
  .INT_CLR                (INT_CLR),
  .INT                    (INT),
  .INT_IO                 (INT_IO_tmp),


// Counters to Analog
  .IDAC_EN                (IDAC_EN),
  .IDAC                   (IDAC),
  .DOUTC                  (DOUTC),
  .DOUTF                  (DOUTF),
  .DOUT                   (DOUT),

// From Analog
  .IREF_COARSE            (IREF_COARSE),
  .IREF_FINE              (IREF_FINE)

);

assign INT_IO = |INT_IO_tmp;

endmodule