/////////////////////////////////////////////////////////
////----------------------------------------------------
////-- author: zhen cao
////
////-- module: common_pulse_rising.v
////
////-- discription:generate pulse when detect a rising edge of input
////
////-- data:22/10/2024
////
////-- version:0.1
////
////----------------------------------------------------
/////////////////////////////////////////////////////////

module common_pulse_rising #(
parameter RST_VAL = 1'b0
)(
input  wire  d_in,
input  wire  clk,
input  wire  rst_,
output wire  d_out
); 

reg d_in_d1;
always @ (posedge clk or negedge rst_) begin
	if (~rst_)
		d_in_d1 <= RST_VAL;
	else 
		d_in_d1 <= d_in;		
end

assign d_out = !d_in_d1 & d_in;

endmodule

