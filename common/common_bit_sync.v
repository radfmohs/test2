/*--------------------------------------------------------------------------------------*/
/*      Nanochap Confidential                                                           */
/*--------------------------------------------------------------------------------------*/
/* File Name	:   common_bit_sync.v                                                   */
/* Project	    :   ECG/PPG Chip                                                        */
/* Designer	    :   Daniel Wang                                                         */
/* Description	:   single bit synchronizer                                             */
/* Date		    :   21/07/2020                                                          */
/*--------------------------------------------------------------------------------------*/
/* Revision History:                                                                    */    
/* Data         Rev.     By             Description                                     */
/*--------------------------------------------------------------------------------------*/
/*21/07/2020    0.1     Daniel Wang     First draft                                     */
/*--------------------------------------------------------------------------------------*/
`timescale 1ns / 1ps

module common_bit_sync (
input  wire  i_clk,
input  wire  i_rst_n,
input  wire  i_async_in,
output wire  o_sync_out
); 

parameter RST_VAL = 1'b0;

reg async_in_d1, async_in_d2;
always @ (posedge i_clk or negedge i_rst_n) begin
	if (~i_rst_n) begin
		async_in_d1 <= RST_VAL;
		async_in_d2 <= RST_VAL;
	end else begin 
		async_in_d1 <= i_async_in;		
		async_in_d2 <= async_in_d1;		
    end
end

assign o_sync_out = async_in_d2;

endmodule

