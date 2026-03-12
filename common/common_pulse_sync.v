/*--------------------------------------------------------------------------------------*/
/*      Nanochap Confidential                                                           */
/*--------------------------------------------------------------------------------------*/
/* File Name	:   common_pulse_sync.v                                                 */
/* Project	    :   ECG/PPG Chip                                                        */
/* Designer	    :   Daniel Wang                                                         */
/* Description	:   pulse to pulse synchronizer                                         */
/* Date		    :   22/07/2020                                                          */
/*--------------------------------------------------------------------------------------*/
/* Revision History:                                                                    */
/* Data         Rev.     By             Description                                     */
/*--------------------------------------------------------------------------------------*/
/*22/07/2020    0.1     Daniel Wang     First draft                                     */
/*--------------------------------------------------------------------------------------*/
module common_pulse_sync (
input  wire  i_a_clk,     // a-domain clock
input  wire  i_b_clk,     // b-domain clock
input  wire  i_a_rst_n,   // a-domain reset
input  wire  i_b_rst_n,   // b-domain reset
input  wire  i_test_mode, // test mode input
input  wire  i_a_pulse,   // a-domain pulse
output wire  o_a_ready,   // a-domain ready indicator
output wire  o_b_pulse    // b-domain pulse
); 

reg a_pulse_start;
reg b_pulse_pre;
reg b_pulse_start;
reg b_pulse_done;
reg a_cycle_done_pre;
reg a_cycle_done;

wire a_pulse_rst_n = i_test_mode ? i_a_rst_n : (i_a_rst_n & ~a_cycle_done);

always @ (posedge i_a_clk or negedge a_pulse_rst_n) begin
	if (~a_pulse_rst_n)
		a_pulse_start	<= 1'b0;
	else if(i_a_pulse)
		a_pulse_start	<= 1'b1;
	else 
		a_pulse_start	<= a_pulse_start;		
end

always @ (posedge i_b_clk or negedge i_b_rst_n) begin
	if(~i_b_rst_n) begin
		b_pulse_pre     <= 1'b0;
		b_pulse_start	<= 1'b0;
		b_pulse_done	<= 1'b0;
	end else begin
		b_pulse_pre 	<= a_pulse_start;
		b_pulse_start	<= b_pulse_pre;
		b_pulse_done	<= b_pulse_start;
	end
end

assign o_b_pulse = b_pulse_start & ~b_pulse_done;

always @ (posedge i_a_clk or negedge i_a_rst_n) begin
	if(~i_a_rst_n) begin
		a_cycle_done_pre    <= 1'b0;
		a_cycle_done	    <= 1'b0;
	end else begin
		a_cycle_done_pre    <= b_pulse_start;
		a_cycle_done        <= a_cycle_done_pre;
	end
end

assign o_a_ready = ~(a_cycle_done | a_pulse_start);

endmodule
