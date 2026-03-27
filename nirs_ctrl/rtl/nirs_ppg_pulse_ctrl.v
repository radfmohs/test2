module nirs_ppg_pulse_ctrl (
  input  wire       rst_n,
  input  wire       clk,  // 2 MHz

// CONTROL signals 
//input  wire [2:0] MODE_SEL, // xxx1: MCU MASTER (SINGLE) - 0000: RECEIVER MASTER (SINGLE) - 0010: RECEIVER MASTER (CON TYP) - 110: RECEIVER MASTER (CON FAST)

//  - 0000: RECEIVER MASTER (CON TYP) - 0010: RECEIVER MASTER (CON FAST) - 0110: RECEIVER MASTER (CON FAST)
/*
  xxx1: MCU MASTER (SINGLE)
  0000: RECEIVER MASTER (CON TYP) - EN follows IREF FINE
  0100: RECEIVER MASTER (CON TYP) - EN always on
  0x10: RECEIVER MASTER (CON FAST)
  1xx0: RECEIVER MASTER (SINGLE)
*/
  input  wire [3:0] MODE_SEL, 

  input  wire       NIRS_EN, 
  input  wire       NIRS_MEAS,

// CONFIG signals
  input  wire [2:0] LED_stable_ctrl,
  input  wire [1:0] LED_off_ctrl,
  input  wire [2:0] REC_stable_ctrl,
  input  wire [2:0] RESET_ctrl,
  input  wire [3:0] PERIOD_ctrl,
  input  wire [3:0] OTS_ctrl,

  output wire       EN_DIG,
  input  wire       EN_OFF,
  output wire       EN,
  output wire       RESET,
  output wire       IPD_SW,
  output wire       IIN_SW,
  output wire       LED_ON
);

localparam t_STABLE_1M4   = 16'd140;
localparam t_STABLE_1M2   = 16'd120;
localparam t_STABLE_1M    = 16'd100;
localparam t_STABLE_80US  = 16'd80;
localparam t_STABLE_60US  = 16'd60;
localparam t_STABLE_40US  = 16'd40;
localparam t_STABLE_20US  = 16'd20;
localparam t_STABLE_10US  = 16'd10;

localparam t_LED_OFF_3US  = 16'd3;
localparam t_LED_OFF_2US  = 16'd2;
localparam t_LED_OFF_1US  = 16'd1;
localparam t_LED_OFF_0US  = 16'd0;

localparam t_PERIOD_22MS  = 16'd22000;
localparam t_PERIOD_20MS  = 16'd20000;
localparam t_PERIOD_18MS  = 16'd18000;
localparam t_PERIOD_16MS  = 16'd16000;
localparam t_PERIOD_14MS  = 16'd14000;
localparam t_PERIOD_12MS  = 16'd12000;
localparam t_PERIOD_10MS  = 16'd10000;
localparam t_PERIOD_8MS   = 16'd8000;
localparam t_PERIOD_6MS   = 16'd6000;
localparam t_PERIOD_4MS   = 16'd4000;
localparam t_PERIOD_2MS   = 16'd2000;
localparam t_PERIOD_1MS   = 16'd1000;
localparam t_PERIOD_750US = 16'd750;
localparam t_PERIOD_500US = 16'd500;
localparam t_PERIOD_250US = 16'd250;
localparam t_PERIOD_125US = 16'd125;

localparam t_OTS_25US = 16'd25;
localparam t_OTS_20US = 16'd20;
localparam t_OTS_18US = 16'd18;
localparam t_OTS_16US = 16'd16;
localparam t_OTS_14US = 16'd14;
localparam t_OTS_12US = 16'd12;
localparam t_OTS_10US = 16'd10;
localparam t_OTS_9US  = 16'd9;
localparam t_OTS_8US  = 16'd8;
localparam t_OTS_7US  = 16'd7;
localparam t_OTS_6US  = 16'd6;
localparam t_OTS_5US  = 16'd5;
localparam t_OTS_4US  = 16'd4;
localparam t_OTS_3US  = 16'd3;
localparam t_OTS_2US  = 16'd2;
localparam t_OTS_1US  = 16'd1;

localparam t_RESET_1M   = 16'd100;
localparam t_RESET_90US = 16'd90;
localparam t_RESET_80US = 16'd80;
localparam t_RESET_70US = 16'd70;
localparam t_RESET_60US = 16'd60;
localparam t_RESET_50US = 16'd50;
localparam t_RESET_40US = 16'd40;
localparam t_RESET_30US = 16'd30;

parameter [15:0] t_delay_timing   = 16'd10;

  reg EN_d, RESET_d, IPD_SW_d, IIN_SW_d, LED_ON_d;
  reg  [15:0] counter;
  wire [15:0] t_period_sel, t_period, t_RESET_w, t_IPD_SW_w_sel, t_IPD_SW_w, t_delay, t_RESET_w_timing;
  wire [15:0] t_stable_led, t_stable_rec, t_stable_led_w, t_stable_rec_w, t_off_led, t_off_led_w;
  wire [15:0] EN_h, EN_l;
  wire [15:0] RESET_h, RESET_l;  
  wire [15:0] IPD_SW_h, IPD_SW_l;
  wire [15:0] IIN_SW_h, IIN_SW_l;
  wire [15:0] LED_ON_h, LED_ON_l;

  assign t_period_sel     = (PERIOD_ctrl == 4'hf) ? t_PERIOD_22MS   :
                            (PERIOD_ctrl == 4'he) ? t_PERIOD_20MS   :
                            (PERIOD_ctrl == 4'hd) ? t_PERIOD_18MS   :
                            (PERIOD_ctrl == 4'hc) ? t_PERIOD_16MS   :
                            (PERIOD_ctrl == 4'hb) ? t_PERIOD_14MS   :
                            (PERIOD_ctrl == 4'ha) ? t_PERIOD_12MS   :
                            (PERIOD_ctrl == 4'h9) ? t_PERIOD_10MS   :
                            (PERIOD_ctrl == 4'h8) ? t_PERIOD_8MS    :
                            (PERIOD_ctrl == 4'h7) ? t_PERIOD_6MS    :
                            (PERIOD_ctrl == 4'h6) ? t_PERIOD_4MS    :
                            (PERIOD_ctrl == 4'h5) ? t_PERIOD_2MS    :
                            (PERIOD_ctrl == 4'h4) ? t_PERIOD_1MS    :
                            (PERIOD_ctrl == 4'h3) ? t_PERIOD_750US  :
                            (PERIOD_ctrl == 4'h2) ? t_PERIOD_500US  :
                            (PERIOD_ctrl == 4'h1) ? t_PERIOD_250US  :
                            (PERIOD_ctrl == 4'h0) ? t_PERIOD_125US  : t_PERIOD_125US;

  assign t_stable_led   =   (LED_stable_ctrl == 3'd0) ? t_STABLE_10US :
                            (LED_stable_ctrl == 3'd1) ? t_STABLE_20US :
                            (LED_stable_ctrl == 3'd2) ? t_STABLE_40US :
                            (LED_stable_ctrl == 3'd3) ? t_STABLE_60US :
                            (LED_stable_ctrl == 3'd4) ? t_STABLE_80US :
                            (LED_stable_ctrl == 3'd5) ? t_STABLE_1M   :
                            (LED_stable_ctrl == 3'd6) ? t_STABLE_1M2  :
                            (LED_stable_ctrl == 3'd7) ? t_STABLE_1M4  : t_STABLE_10US;

  assign t_off_led      =   (LED_off_ctrl    == 2'd0) ? t_LED_OFF_0US :
                            (LED_off_ctrl    == 2'd1) ? t_LED_OFF_1US :
                            (LED_off_ctrl    == 2'd2) ? t_LED_OFF_2US :
                            (LED_off_ctrl    == 2'd3) ? t_LED_OFF_3US : t_LED_OFF_0US;

// Remove this - td0
  assign t_stable_rec   =   (REC_stable_ctrl == 3'd0) ? t_STABLE_10US :
                            (REC_stable_ctrl == 3'd1) ? t_STABLE_20US :
                            (REC_stable_ctrl == 3'd2) ? t_STABLE_40US :
                            (REC_stable_ctrl == 3'd3) ? t_STABLE_60US :
                            (REC_stable_ctrl == 3'd4) ? t_STABLE_80US :
                            (REC_stable_ctrl == 3'd5) ? t_STABLE_1M   :
                            (REC_stable_ctrl == 3'd6) ? t_STABLE_1M2  :
                            (REC_stable_ctrl == 3'd7) ? t_STABLE_1M4  : t_STABLE_10US;                            

  assign t_IPD_SW_w_sel  =  
                            (OTS_ctrl    == 4'hf) ? t_OTS_25US  :
                            (OTS_ctrl    == 4'he) ? t_OTS_20US  :
                            (OTS_ctrl    == 4'hd) ? t_OTS_18US  :
                            (OTS_ctrl    == 4'hc) ? t_OTS_16US  :
                            (OTS_ctrl    == 4'hb) ? t_OTS_14US  :
                            (OTS_ctrl    == 4'ha) ? t_OTS_12US  :
                            (OTS_ctrl    == 4'h9) ? t_OTS_10US  :
                            (OTS_ctrl    == 4'h8) ? t_OTS_9US   :
                            (OTS_ctrl    == 4'h7) ? t_OTS_8US   :
                            (OTS_ctrl    == 4'h6) ? t_OTS_7US   :
                            (OTS_ctrl    == 4'h5) ? t_OTS_6US   :
                            (OTS_ctrl    == 4'h4) ? t_OTS_5US   :
                            (OTS_ctrl    == 4'h3) ? t_OTS_4US   :
                            (OTS_ctrl    == 4'h2) ? t_OTS_3US   :
                            (OTS_ctrl    == 4'h1) ? t_OTS_2US   :
                            (OTS_ctrl    == 4'h0) ? t_OTS_1US   : t_OTS_1US;

  assign t_RESET_w_timing = (RESET_ctrl  == 3'h7) ? t_RESET_1M   :
                            (RESET_ctrl  == 3'h6) ? t_RESET_90US :
                            (RESET_ctrl  == 3'h5) ? t_RESET_80US :
                            (RESET_ctrl  == 3'h4) ? t_RESET_70US :
                            (RESET_ctrl  == 3'h3) ? t_RESET_60US :
                            (RESET_ctrl  == 3'h2) ? t_RESET_50US :
                            (RESET_ctrl  == 3'h1) ? t_RESET_40US :
                            (RESET_ctrl  == 3'h0) ? t_RESET_30US : t_RESET_30US;


  assign t_period       = t_period_sel      * 16'd2 - 16'd1;
  assign t_stable_led_w = t_stable_led      * 16'd2;
  assign t_stable_rec_w = t_stable_rec      * 16'd2;
  assign t_RESET_w      = t_RESET_w_timing  * 16'd2;
  assign t_delay        = t_delay_timing    * 16'd2;
  assign t_IPD_SW_w     = t_IPD_SW_w_sel    * 16'd2;

  assign EN_h         = 16'd10;
  assign EN_l         = 16'h0; 

  assign RESET_h      = EN_h;// + t_stable_rec_w;
  assign RESET_l      = RESET_h + t_RESET_w;

  assign IPD_SW_h     = RESET_l + t_delay;
  assign IPD_SW_l     = IPD_SW_h + t_IPD_SW_w;

  assign IIN_SW_h     = EN_h; //RESET_h;
  assign IIN_SW_l     = IPD_SW_l;

  assign LED_ON_h     = IPD_SW_h - t_stable_led_w;
  assign LED_ON_l     = IPD_SW_l + t_off_led;



/*
  Starts counting when NIRS_EN and stops counting only after the working period is completed
*/
  reg count_cur, count_next;
  localparam HOLD = 1'b0;
  localparam COUNTING = 1'b1;
  wire counter_en;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) 
      count_cur <= HOLD;
    else
      count_cur <= count_next;
  end

  wire SAMPLING_DONE =  ((MODE_SEL[3:0] == 4'b0010) || (MODE_SEL[3:0] == 4'b0110)) ? EN_OFF : (counter == t_period);

  always @(*) begin
    case(count_cur)
      HOLD: begin
            // START the NIRS                           // resume NIRS when MEAS from user detected
        if (((counter == 16'b0) && (NIRS_EN == 1'b1)) || ((counter != 16'b0) && (NIRS_MEAS)))
          count_next = COUNTING;
        else
          count_next = count_cur;
      end

      COUNTING: begin

        // MCU master mode
        if (MODE_SEL[0] == 1'b1) begin
              // after reset pulse - wait for user            // sampling done
              // to start the sampling                        // EN_l: off at the end of counter - EN_OFF: falling edge of IREFFINE detected
          if ((counter == RESET_l) || SAMPLING_DONE) begin
            count_next = HOLD;
          end else begin
            count_next = count_cur;
          end

        // REC master mode
        end else begin
          if (MODE_SEL[3] != 1'b1) begin // Continuous mode - Keep counting
            count_next = count_cur;
          end else begin // Single mode
            if (SAMPLING_DONE) begin
              count_next = HOLD;
            end else begin
              count_next = count_cur;
            end
          end
        end
      end
      default: count_next = HOLD;
    endcase
  end

  assign counter_en = (count_cur == COUNTING);// && (count_cur == count_next);

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      counter <= 16'b0;
    end else if (SAMPLING_DONE) begin
      counter <= 16'b0;
    end else if (counter_en) begin
      counter <= counter + 16'd1;
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      EN_d <= 1'b0;
    end else if ((counter == EN_l) || EN_OFF) begin //EN_l: off at the end of counter - EN_OFF: falling edge of IREFFINE detected
      EN_d <= 1'b0;
    end else if (counter == EN_h) begin
      EN_d <= 1'b1;
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      RESET_d <= 1'b0;
    end else if (counter == RESET_l) begin
      RESET_d <= 1'b0;
    end else if (counter == RESET_h) begin
      RESET_d <= 1'b1;
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      IPD_SW_d <= 1'b0;
    end else if (counter == IPD_SW_l) begin
      IPD_SW_d <= 1'b0;
    end else if (counter == IPD_SW_h) begin
      IPD_SW_d <= 1'b1;
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      IIN_SW_d  <= 1'b0;
    end else if (counter == IIN_SW_l) begin
      IIN_SW_d  <= 1'b0;
    end else if (counter == IIN_SW_h) begin
      IIN_SW_d  <= 1'b1;
    end
  end

    always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      LED_ON_d  <= 1'b0;
    end else if (counter == LED_ON_l) begin
      LED_ON_d  <= 1'b0;
    end else if ((counter == LED_ON_h) && (MODE_SEL[0] == 1'b0)) begin
      LED_ON_d  <= 1'b1;
    end
  end

  assign EN_DIG   = EN_d;
  assign EN       = ((MODE_SEL == 4'b0100) || (MODE_SEL == 4'b0010) || (MODE_SEL == 4'b0110)) ? NIRS_EN : EN_d;
//assign EN       = EN_d;
  assign RESET    = RESET_d;
  assign IPD_SW   = IPD_SW_d;
  assign IIN_SW   = IIN_SW_d;
  assign LED_ON   = LED_ON_d;

endmodule