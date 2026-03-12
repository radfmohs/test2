/////////////////////////////////////////////////////////
////----------------------------------------------------
////-- author: zhen cao
////
////-- module: common_pulse_async_clr.v
////
////-- discription:generate pulse when there is an async clear(the width of
////   the signal is short compared the target clock domian)
////
////-- data:17/9/2025
////
////-- version:0.1
////
////----------------------------------------------------
/////////////////////////////////////////////////////////

module common_pulse_async_clr #(
parameter RST_VAL = 1'b0
)(
input  wire  d_in,
input  wire  clk,
input  wire  rst_,
input  wire  int_sts,
input  wire  scan_mode,
output wire  d_out
); 

wire int_sts_clr_sync_tmp;
wire int_sts_clr_sync;
common_rst_sync u_int_sts_sync(
.RSTINn    (rst_),
.RSTREQ    (d_in),
.CLK       (clk),
.SE        (1'b0),
.RSTBYPASS (scan_mode),
.RSTOUTn   (int_sts_clr_sync_tmp)
);

assign int_sts_clr_sync = scan_mode ? int_sts : int_sts_clr_sync_tmp;

reg int_sts_clr_sync_d1,int_sts_clr_sync_d2,int_sts_clr_sync_d3;
always @ (posedge clk or negedge rst_) begin
  if (~rst_) begin
    int_sts_clr_sync_d1<=1'b0; 
    int_sts_clr_sync_d2<=1'b0; 
    int_sts_clr_sync_d3<=1'b0; 
  end
  else begin
   int_sts_clr_sync_d1 <= int_sts_clr_sync;
   int_sts_clr_sync_d2 <= int_sts_clr_sync_d1;
   int_sts_clr_sync_d3 <= int_sts_clr_sync_d2;
 end
end

assign d_out = int_sts_clr_sync_d2 & (~int_sts_clr_sync_d3);



endmodule

