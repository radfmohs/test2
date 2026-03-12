/*--------------------------------------------------------------------------------------*/
/*--------------------------------------------------------------------------------------*/
/* File Name	: common_dbg_buf16.v                                                    */
/* Project	: Nanochap Glucose Chip                                                     */
/* Description	: debug signal group buffer out                                         */
/* Designer	: Daniel Wang                                                               */
/* Date		: 08/20/2019                                                                */
/* Revision	: R001 first draft                                                          */
/*--------------------------------------------------------------------------------------*/
/*--------------------------------------------------------------------------------------*/
module common_dbg_buf16 (
input  wire         dbg_signal_0,
input  wire         dbg_signal_1,
input  wire         dbg_signal_2,
input  wire         dbg_signal_3,
input  wire         dbg_signal_4,
input  wire         dbg_signal_5,
input  wire         dbg_signal_6,
input  wire         dbg_signal_7,
input  wire         dbg_signal_8,
input  wire         dbg_signal_9,
input  wire         dbg_signal_10,
input  wire         dbg_signal_11,
input  wire         dbg_signal_12,
input  wire         dbg_signal_13,
input  wire         dbg_signal_14,
input  wire         dbg_signal_15,
output wire [15:0]  dbg_signal_group
);
`ifdef FPGA
assign dbg_signal_group[0] = dbg_signal_0;
assign dbg_signal_group[1] = dbg_signal_1;
assign dbg_signal_group[2] = dbg_signal_2;
assign dbg_signal_group[3] = dbg_signal_3;
assign dbg_signal_group[4] = dbg_signal_4;
assign dbg_signal_group[5] = dbg_signal_5;
assign dbg_signal_group[6] = dbg_signal_6;
assign dbg_signal_group[7] = dbg_signal_7;
assign dbg_signal_group[8] = dbg_signal_8;
assign dbg_signal_group[9] = dbg_signal_9;
assign dbg_signal_group[10] = dbg_signal_10;
assign dbg_signal_group[11] = dbg_signal_11;
assign dbg_signal_group[12] = dbg_signal_12;
assign dbg_signal_group[13] = dbg_signal_13;
assign dbg_signal_group[14] = dbg_signal_14;
assign dbg_signal_group[15] = dbg_signal_15;
`else
BUF_X4_A7TULL DNT_DBG_BIT0  (.Y(dbg_signal_group[0]),  .A(dbg_signal_0));
BUF_X4_A7TULL DNT_DBG_BIT1  (.Y(dbg_signal_group[1]),  .A(dbg_signal_1));
BUF_X4_A7TULL DNT_DBG_BIT2  (.Y(dbg_signal_group[2]),  .A(dbg_signal_2));
BUF_X4_A7TULL DNT_DBG_BIT3  (.Y(dbg_signal_group[3]),  .A(dbg_signal_3));
BUF_X4_A7TULL DNT_DBG_BIT4  (.Y(dbg_signal_group[4]),  .A(dbg_signal_4));
BUF_X4_A7TULL DNT_DBG_BIT5  (.Y(dbg_signal_group[5]),  .A(dbg_signal_5));
BUF_X4_A7TULL DNT_DBG_BIT6  (.Y(dbg_signal_group[6]),  .A(dbg_signal_6));
BUF_X4_A7TULL DNT_DBG_BIT7  (.Y(dbg_signal_group[7]),  .A(dbg_signal_7));
BUF_X4_A7TULL DNT_DBG_BIT8  (.Y(dbg_signal_group[8]),  .A(dbg_signal_8));
BUF_X4_A7TULL DNT_DBG_BIT9  (.Y(dbg_signal_group[9]),  .A(dbg_signal_9));
BUF_X4_A7TULL DNT_DBG_BIT10 (.Y(dbg_signal_group[10]), .A(dbg_signal_10));
BUF_X4_A7TULL DNT_DBG_BIT11 (.Y(dbg_signal_group[11]), .A(dbg_signal_11));
BUF_X4_A7TULL DNT_DBG_BIT12 (.Y(dbg_signal_group[12]), .A(dbg_signal_12));
BUF_X4_A7TULL DNT_DBG_BIT13 (.Y(dbg_signal_group[13]), .A(dbg_signal_13));
BUF_X4_A7TULL DNT_DBG_BIT14 (.Y(dbg_signal_group[14]), .A(dbg_signal_14));
BUF_X4_A7TULL DNT_DBG_BIT15 (.Y(dbg_signal_group[15]), .A(dbg_signal_15));
`endif


endmodule 
