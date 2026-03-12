/*--------------------------------------------------------------------------------------*/
/*      Nanochap Confidential                                                           */
/*--------------------------------------------------------------------------------------*/
/* File Name	:   eprom_bist_top.v                                                    */
/* Project	    :   ENS1P4 Chip                                                     */
/* Designer	    :   zhen                                                            */
/* Description	:   EPROM bist top                                                      */
/* Date		    :   1/4/2024                                                        */
/*--------------------------------------------------------------------------------------*/
/* Revision History:                                                                    */    
/* Data         Rev.     By             Description                                     */
/*--------------------------------------------------------------------------------------*/
/* 8/6/2021    0.2     Hai Wang    			second draft                    */
/* 10/8/200    1       Mohsen Radfar    convert to EEPROM from MTP                      */
/* 01/09/2024  2	   Truong Pham      convert to EPROM from EEPROM                */
/*--------------------------------------------------------------------------------------*/

module eprom_bist_top(
    // --------------------------------------------------------------------------
    // Port Definitions
    // --------------------------------------------------------------------------
    //JTAG Related Pins
    input             TCK       ,
    input             RESETb    ,
    input             TDI       ,
    input             TESTEN    ,
    input             STROBE    ,
    output            TDO       ,
    output            serout    ,
    output            OEN       ,  
    output            vpp_en    ,

    //Output Signals to EPROM IP
    output 	   o_BIST_EPROM_XENTER       ,   // Chip enable
    output         o_BIST_EPROM_XREAD     ,   // Read control
    output  [1:0]  o_BIST_EPROM_XTM	  ,   // Margin read mode control
    output         o_BIST_EPROM_PGM	 ,   // Program control
    output  [6:0]  o_BIST_EPROM_XA	   ,   // Program/read address                 
    output  [7:0]  o_BIST_EPROM_XDIN ,   // Data input to EPROM
    output  [2:0]  o_BIST_EPROM_OTP ,   // Data input to EPROM

    //Input Signals from EPROM IP
	input   [31:0]  i_BIST_EPROM_DQ           // Data output from ERPOM
);

// Always combi case output to BIST 
// Parallel to Serial Input
wire [         31:0] IP2ST;
  
// Serial to Parallel BIST OUTPUT to EPROM 
wire [20:0] ST2IP;
assign IP2ST             = TESTEN ? i_BIST_EPROM_DQ : {32{1'b0}};

// --------------------------------------------------------------------------
// OUTPUT TO EEPROM
// Assign Parallel Outputs to respective BIST Output Ports
// Bit loccations derived from constant file
// --------------------------------------------------------------------------
        assign o_BIST_EPROM_XENTER  =  ST2IP[`S_XENTER] ;
        assign o_BIST_EPROM_XREAD   =  ST2IP[`S_XREAD];
        assign o_BIST_EPROM_XTM     =  ST2IP[`S_XTM] ;
        assign o_BIST_EPROM_PGM     =  ST2IP[`S_PGM] ;
        assign o_BIST_EPROM_XA      =  ST2IP[`S_XA]  ;
        assign o_BIST_EPROM_XDIN    =  ~ST2IP[`S_XDIN];
	assign o_BIST_EPROM_OTP     =  {2'b00,ST2IP[`WIDTH-6]};//need to update according to S_OTP

eprom_bist u_eprom_bist 
(
    .i_TCK          (TCK   ),
    .i_RESETb       (RESETb),
    .i_TDI          (TDI   ),
    .i_STROBE       (STROBE),
    .i_TESTEN       (TESTEN),
    .i_IP2ST        (IP2ST ),
    .o_ST2IP        (ST2IP ), 
    .o_TDO          (TDO   ),
    .o_serout       (serout),
    .o_vpp_en       (vpp_en),
    .o_OEN          (OEN   )
);

endmodule
