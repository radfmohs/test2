module nirs_ppg_ctrl (
  input  wire   rst_n,
  input  wire   clk,


  input  wire   EN,
  input  wire   IREF_COARSE,
  input  wire   IREF_FINE,

// FLAGS
  output wire   IREF_COARSE_ON_NOT_OFF,
  output wire   IREF_COARSE_NOT_ON,
  output wire   IREF_FINE_ON_NOT_OFF,
  output wire   IREF_FINE_NOT_ON,

  output wire   EN_OFF, // Turn off NIRS
  output wire   IDAC_INCREASE,
  output wire   IDAC_UPDATE_EN,
  output wire   QC_COUNTER_EN,
  output wire   QF_COUNTER_EN,
  output wire   COUNTERS_CLEAR,
  output wire   DOUTC_LATCH_EN,
  output wire   DOUTF_LATCH_EN,
  output wire   DOUT_EN

);

  reg        [2:0]  cur, next;
  localparam        IDLE                  = 3'd0;
  localparam        WAIT                  = 3'd1;
  localparam        IREF_COARSE_LATCHING  = 3'd2;
  localparam        IREF_COARSE_LATCHED   = 3'd3;
  localparam        IREF_FINE_LATCHING    = 3'd4;
  localparam        DATA_UPDATE           = 3'd5;
  wire START, DONE;
  reg DATA_UPDATED;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) 
      cur <= IDLE;
    else
      cur <= next;
  end

  always @(*) begin
    case(cur) 

      IDLE: begin
        if (START)
          next = WAIT;
        else  
          next = cur;
      end

      WAIT: begin
        if (DONE) 
          next = DATA_UPDATE;
        else if (IREF_COARSE)
          next = IREF_COARSE_LATCHING;
        else
          next = cur;
      end

      IREF_COARSE_LATCHING: begin
        if (DONE) 
          next = DATA_UPDATE;
        else if (!IREF_COARSE)
          next = IREF_COARSE_LATCHED;
        else
          next = cur;
      end

      IREF_COARSE_LATCHED: begin
        if (DONE) 
          next = DATA_UPDATE;
        else if (IREF_FINE)
          next = IREF_FINE_LATCHING;
        else
          next = cur;
      end

      IREF_FINE_LATCHING: begin
        if (DONE) 
          next = DATA_UPDATE;
        else if (!IREF_FINE)
          next = DATA_UPDATE;
        else
          next = cur;
      end

      DATA_UPDATE: begin
        if (DATA_UPDATED)
          next = IDLE;
        else  
          next = cur;
      end

      default: begin
        next = IDLE;
      end 

    endcase
  end


  wire IREF_COARSE_L, IREF_FINE_L, IREF_COARSE_L_N, IREF_FINE_L_N;
  reg  IREF_COARSE_L_d, IREF_FINE_L_d;

  assign IREF_COARSE_L  = ((cur == IREF_COARSE_LATCHING) || (next == IREF_COARSE_LATCHING)) & IREF_COARSE;
  assign IREF_FINE_L    = ((cur == IREF_FINE_LATCHING)   || (next == IREF_FINE_LATCHING))   & IREF_FINE;

  assign IREF_FINE_L_N  = !IREF_FINE_L   & IREF_FINE_L_d;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      IREF_FINE_L_d   <= 1'b0;
    end else begin
      IREF_FINE_L_d   <= IREF_FINE_L;
    end
  end

  reg EN_d;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      EN_d <= 1'b0;
    end else begin
      EN_d <= EN;
    end
  end

  assign START = !EN_d &  EN; //RISING EDGE
  assign DONE  =  EN_d & !EN; //FALLING EDGE

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      DATA_UPDATED <= 1'b0;
    end else begin
      DATA_UPDATED <= (cur == DATA_UPDATE);
    end
  end

/*
  OUTPUTs
*/  
  assign EN_OFF           = IREF_FINE_L_N; //Falling edge of IREF_FINE
  assign QC_COUNTER_EN    = IREF_COARSE_L;
  assign QF_COUNTER_EN    = IREF_FINE_L;
  assign DOUTC_LATCH_EN   = (cur !== next) && (next == DATA_UPDATE);
  assign DOUTF_LATCH_EN   = (cur !== next) && (next == DATA_UPDATE);
  assign DOUT_EN          = (cur == DATA_UPDATE); 
  assign IDAC_INCREASE    = IREF_COARSE_ON_NOT_OFF || IREF_COARSE_NOT_ON || IREF_FINE_ON_NOT_OFF || IREF_FINE_NOT_ON;
  assign IDAC_UPDATE_EN   = (cur !== next) && (next == IDLE);
  assign COUNTERS_CLEAR   = (cur !== next) && (next == IDLE);



// FLAGS
  reg IREF_COARSE_ON_NOT_OFF_d;
  reg IREF_COARSE_NOT_ON_d;
  reg IREF_FINE_ON_NOT_OFF_d;
  reg IREF_FINE_NOT_ON_d;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      IREF_COARSE_NOT_ON_d <= 1'b0;
    else if ((cur == WAIT) && (DONE == 1'b1))
      IREF_COARSE_NOT_ON_d <= 1'b1;
    else if ((cur == IDLE))
      IREF_COARSE_NOT_ON_d <= 1'b0;
    else
      IREF_COARSE_NOT_ON_d <= IREF_COARSE_NOT_ON_d;
  end


  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      IREF_COARSE_ON_NOT_OFF_d <= 1'b0;
    else if ((cur == IREF_COARSE_LATCHING) && (DONE == 1'b1))
      IREF_COARSE_ON_NOT_OFF_d <= 1'b1;
    else if ((cur == IDLE))
      IREF_COARSE_ON_NOT_OFF_d <= 1'b0;
    else
      IREF_COARSE_ON_NOT_OFF_d <= IREF_COARSE_ON_NOT_OFF_d;
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      IREF_FINE_NOT_ON_d <= 1'b0;
    else if ((cur == IREF_COARSE_LATCHED) && (DONE == 1'b1))
      IREF_FINE_NOT_ON_d <= 1'b1;
    else if ((cur == IDLE))
      IREF_FINE_NOT_ON_d <= 1'b0;
    else
      IREF_FINE_NOT_ON_d <= IREF_FINE_NOT_ON_d;
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      IREF_FINE_ON_NOT_OFF_d <= 1'b0;
    else if ( (cur == IREF_FINE_LATCHING) && (DONE == 1'b1))
      IREF_FINE_ON_NOT_OFF_d <= 1'b1;
    else if ((cur == IDLE))
      IREF_FINE_ON_NOT_OFF_d <= 1'b0;
    else
      IREF_FINE_ON_NOT_OFF_d <= IREF_FINE_ON_NOT_OFF_d;
  end

  assign IREF_COARSE_ON_NOT_OFF = IREF_COARSE_ON_NOT_OFF_d;
  assign IREF_COARSE_NOT_ON     = IREF_COARSE_NOT_ON_d;
  assign IREF_FINE_ON_NOT_OFF   = IREF_FINE_ON_NOT_OFF_d;
  assign IREF_FINE_NOT_ON       = IREF_FINE_NOT_ON_d;

endmodule  
