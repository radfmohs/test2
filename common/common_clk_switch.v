/*--------------------------------------------------------------------------------------*/
/*      Nanochap Confidential                                                           */
/*--------------------------------------------------------------------------------------*/
/* File Name	:   common_clk_switch.v                                                 */
/* Project	    :   ECG/PPG Chip                                                        */
/* Designer	    :   Daniel Wang                                                         */
/* Description	:   glitch free clock switch                                            */
/* Date		    :   21/07/2020                                                          */
/*--------------------------------------------------------------------------------------*/
/* Revision History:                                                                    */
/* Data         Rev.     By             Description                                     */
/*--------------------------------------------------------------------------------------*/
/*21/07/2020    0.1     Daniel Wang     First draft                                     */
/*22/07/2020    0.2     Daniel Wang     add test_mode, scan_enable input                */
/*--------------------------------------------------------------------------------------*/
module common_clk_switch (
input  wire     i_clk_a,
input  wire     i_clk_b,
input  wire     i_rst_n_a,
input  wire     i_rst_n_b, 
input  wire     i_sel_b,
input  wire     i_scan_mode,
input  wire     i_scan_enable,
output wire     o_clk_out,
output wire     o_ind_a,
output wire     o_ind_b
); 

// internal signals
reg  sync1_en_a;
reg  sync2_en_a;
reg  sync3_en_a;
reg  sync1_en_b;
reg  sync2_en_b;
reg  sync3_en_b;
wire gated_i_clk_a;
wire gated_i_clk_b;

assign o_ind_a = sync2_en_a;
assign o_ind_b = sync2_en_b;

wire en_a_async_in = ~i_sel_b & ~sync3_en_b;
wire en_b_async_in =  i_sel_b & ~sync3_en_a;

// synchronizer
always @ (posedge i_clk_a or negedge i_rst_n_a) begin
	if (~i_rst_n_a) begin
        sync1_en_a <= 1'b0;
        sync2_en_a <= 1'b0;
        sync3_en_a <= 1'b0;
    end else begin 
        sync1_en_a <= en_a_async_in;
        sync2_en_a <= sync1_en_a;
        sync3_en_a <= sync2_en_a;
    end
end

// synchronizer
always @ (posedge i_clk_b or negedge i_rst_n_b) begin
	if (~i_rst_n_b) begin
        sync1_en_b <= 1'b0;
        sync2_en_b <= 1'b0;
        sync3_en_b <= 1'b0;
    end else begin 
        sync1_en_b <= en_b_async_in;
        sync2_en_b <= sync1_en_b;
        sync3_en_b <= sync2_en_b;
    end
end

// The clock gate of i_clk_b must be gated in test mode
// This aviods that two test clocks (from i_clk_a and i_clk_b) rise at the same time
//wire gated_en_b = sync2_en_b & ~i_scan_mode;  //tri change

TLATNTSCA_X8_A7TULL u_icg_a (.CK(i_clk_a), .E(sync2_en_a), .SE(i_scan_enable), .ECK(gated_i_clk_a));
TLATNTSCA_X8_A7TULL u_icg_b (.CK(i_clk_b), .E(sync2_en_b), .SE(i_scan_enable), .ECK(gated_i_clk_b));  //tri change

// clk_out
cell_clkor2 u_clk_out (.A(gated_i_clk_a), .B(gated_i_clk_b), .Y(o_clk_out));

endmodule

