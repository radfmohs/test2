/*--------------------------------------------------------------------------------------*/
/*--------------------------------------------------------------------------------------*/
/* File Name	: common_pulse_cdc.v                                                    */
/* Project	: Nanochap Glucose Chip                                                 */
/* Description	: pulse to pulse convert from high freq clock to low freq clock         */
/* Designer	: Daniel Wang                                                           */
/* Date		: 05/17/2019                                                            */
/* Revision	: R001 first draft                                                      */
/*--------------------------------------------------------------------------------------*/
/*--------------------------------------------------------------------------------------*/
module common_pulse_cdc(
input wire  aclk,       //source clock
input wire  bclk,       //destination clock
input wire  arst_,      //source reset
input wire  brst_,      //destination reset
input wire  atpg_en,  //Reset by pass
input wire  a_pulse,    //source pulse
output wire b_pulse     //destination pulse after cdc
); 

reg apulse_start, bpulse_pre, bpulse_start, bpulse_done, acyc_done_pre, acyc_done;

wire apulse_rst_ = atpg_en ? arst_ : (arst_ & ~acyc_done);

always @ (posedge aclk or negedge apulse_rst_) begin
	if (~apulse_rst_)
		apulse_start	<= 1'b0;
	else if(a_pulse)
		apulse_start	<= 1'b1;
	else 
		apulse_start	<= apulse_start;		
end

always @ (posedge bclk or negedge brst_) begin
	if(~brst_) begin
		bpulse_pre	<= 1'b0;
		bpulse_start	<= 1'b0;
		bpulse_done	<= 1'b0;
	end else begin
		bpulse_pre 	<= apulse_start;
		bpulse_start	<= bpulse_pre;
		bpulse_done	<= bpulse_start;
	end
end

assign b_pulse = bpulse_start & ~bpulse_done;

always @ (posedge aclk or negedge arst_) begin
	if(~arst_) begin
		acyc_done_pre	<= 1'b0;
		acyc_done	<= 1'b0;
	end else begin
		acyc_done_pre	<= bpulse_start;
		acyc_done	<= acyc_done_pre;
	end
end

endmodule
