/////////////////////////////////////////////////////////
////----------------------------------------------------
////-- author: zhen cao
////
////-- module: common_pulse_edge.v
////
////-- discription:generate pulse when detect a rising/falling edge of input
////
////-- data:22/10/2024
////
////-- version:0.1
////
////----------------------------------------------------
/////////////////////////////////////////////////////////

module common_pulse_edge #(
parameter RST_VAL = 1'b0
)(
input  wire  d_in,
input  wire  clk,
input  wire  rst_,
output wire  d_out_r,
output wire  d_out_f

); 

reg d_in_d1;
always @ (posedge clk or negedge rst_) begin
	if (~rst_)
		d_in_d1 <= RST_VAL;
	else 
		d_in_d1 <= d_in;		
end

assign d_out_r = !d_in_d1 & d_in;
assign d_out_f = d_in_d1 & !d_in;

endmodule

