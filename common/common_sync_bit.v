/*--------------------------------------------------------------------------------------*/
/*--------------------------------------------------------------------------------------*/
/* File Name	: common_sync_bit.v                                                     */
/* Project	: Nanochap Glucose Chip                                                     */
/* Description	: single bit cdc                                                        */
/* Designer	: Daniel Wang                                                               */
/* Date		: 05/17/2019                                                                */
/* Revision	: R001 first draft                                                          */
/*--------------------------------------------------------------------------------------*/
/*--------------------------------------------------------------------------------------*/
module common_sync_bit(
input  wire  async_in,
input  wire  clk,
input  wire  rst_,
output wire  sync_out
); 

parameter RST_VAL = 1'b0;

reg async_in_d1, async_in_d2;
always @ (posedge clk or negedge rst_) begin
	if (~rst_)
		async_in_d1 <= RST_VAL;
	else 
		async_in_d1 <= async_in;		
end

always @ (posedge clk or negedge rst_) begin
	if (~rst_)
		async_in_d2 <= RST_VAL;
	else 
		async_in_d2 <= async_in_d1;		
end

assign sync_out = async_in_d2;

endmodule

