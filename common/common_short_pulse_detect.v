/////////////////////////////////////////////////////////
////----------------------------------------------------
////-- author: zhen cao
////
////-- module: common_short_pulse_detect.v
////
////-- discription:this module is used to regenerate a signal when there is
////               a short pulse by using the pulse as async
////
////-- data:21/5/2025
////
////-- version:0.1
////
////----------------------------------------------------
/////////////////////////////////////////////////////////

module common_short_pulse_detect (
input  wire RSTINn,     // Active LOW reset
input  wire RSTREQ,     // Active HIGH request
input  wire CLK,        // Clock
input  wire SE,         // Scan Enable (for DFT)
input  wire RSTBYPASS,  // Reset synchroniser bypass (for DFT)
output wire RSTOUTn
);   
  

  wire comb_rst_n = RSTBYPASS ? RSTINn : (RSTINn & ~RSTREQ);
  
  reg  rst_sync0_n, rst_sync1_n, rst_sync2_n;

  always @(posedge CLK or negedge comb_rst_n)
    if (~comb_rst_n) begin
      rst_sync0_n <= 1'b0;
      rst_sync1_n <= 1'b0;
      rst_sync2_n <= 1'b0;
    end else begin
      rst_sync0_n <= 1'b1;
      rst_sync1_n <= rst_sync0_n;
      rst_sync2_n <= rst_sync1_n;
    end
  
  assign RSTOUTn = RSTBYPASS ? RSTINn : rst_sync2_n;
  
endmodule

// ---------------------------------------------------------------
// EOF
// ---------------------------------------------------------------
