//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap ENS2  
// File name:    constants_EPROM_BIST.v 
// Module Name : constants_EPROM_BIST
// Description : Defines
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author          Description      
//------------------------------------------------------------------------------
// 0.1                                      Initial Rev 
//------------------------------------------------------------------------------

/* Mode select
S_MS = 3'd0     =>          STANDBY      
S_MS = 3'd1     =>          BY PASS
S_MS = 3'd2     => SINGLE   READ
S_MS = 3'd3     => MULTIPLE READ
S_MS = 3'd4     => SINGLE   MARGIN READ
S_MS = 3'd5     => MULTIPLE MARGIN READ
S_MS = 3'd6     =>          PROGRAM      
S_MS = 3'd7     => MULTIPLE PROGRAM         
*/

/* Frequency select
S_FREQ = 2'd0     => 01MHz  =>  1000.00 ns => 1.00  us
S_FREQ = 2'd1     => 10MHz  =>   100.00 ns
S_FREQ = 2'd2     => 20MHz  =>    50.00 ns
S_FREQ = 2'd3     => 32MHz  =>    31.25 ns 
*/


`define WIDTH               26

// for EPROM
`define S_XENTER                     0              // Chip select
`define S_XREAD                      1              // Read mode
`define S_PGM                        2              // Progame mode
`define S_XTM                    4 : 3            // Margin read mode
`define S_XA                    11 : 5              // Data address
`define S_XDIN                  19 : 12             // Data in
`define S_MS                    22 : 20  
`define S_FREQ                  24 : 23
`define S_OTP                        25


// Modes
`define OPM_STAND_BY                3'd0
`define OPM_BY_PASS                 3'd1
`define OPM_SINGLE_READ             3'd2
`define OPM_MULT_READ               3'd3
`define OPM_SINGLE_MARGIN_READ      3'd4
`define OPM_MULT_MARGIN_READ        3'd5
`define OPM_PROG                    3'd6
`define OPM_MULT_PROG               3'd7

/* FSM

*/
// idle state
`define FSM_IDLE        4'd0

// BY_PASS
`define FSM_BY_PASS     4'd1

// Read state 
`define FSM_READ        4'd2
`define FSM_RDATA       4'd9
// Done 
`define FSM_RDONE       4'd3

// Program state 
`define FSM_PROG        4'd4

// Sub state
`define FSM_PROG_ENTER     4'd5
`define FSM_PROG_ACCESS    4'd6
`define FSM_PROG_BYTE_DONE 4'd7
`define FSM_PROG_DONE      4'd8
`define FSM_PROG_EXIT      4'd10

