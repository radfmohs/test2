//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap ENS2  
// File name:    eprom_timing.v 
// Module Name : eprom_timing
// Description : 
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author          Description      
//------------------------------------------------------------------------------
// 0.1                                      Initial Rev 
//------------------------------------------------------------------------------

module eprom_timing (
  input  wire [1:0]   i_EPROM_BIST_FREQ,

  output  reg [3:0]   o_t_tADs,           
  output  reg [3:0]   o_t_tADh, 
  output  reg [4:0]   o_t_tAC,                  
  output  reg [4:0]   o_t_tRD,
  output  reg [5:0]   o_t_tPGM,
  output  wire [9:0]  o_t_ser

);

assign o_t_ser   = 10'd16;

always @(i_EPROM_BIST_FREQ) begin: TIMING_signals

/* Default - 1MHz
.   ns -> us -> ms -> s

.   t_tCEs  - Min 200 ns
.   t_tADs  - Min 200 ns
.   t_tADh  - Min 200 ns
.   t_tCEh  - Min 200 ns

.   // READ 
.   t_tAC   - Min 200 ns
.   t_tRD   - Min 600 ns

.   // Program
.   // Use Mhz -> kHz counter
.   t_tPGM  - Min 1.0 ms

.   t_ser   - Min 31  us

*/
  case (i_EPROM_BIST_FREQ)

    2'd3  : begin

      // 31.25 ns * 7 = 218.75 ns
      o_t_tADs  = 4'd7;
      o_t_tADh  = 4'd7;

      // 31.25 ns * 18 = 562.5 ns
      o_t_tAC   =  5'd18;

      // 31.25 ns * 20 = 625 ns
      o_t_tRD    = 5'd20 - o_t_tAC;

      // 31.25 us * 32 = 1 [ms]
      o_t_tPGM  = 6'd32;

      // 31.25 ns * 512 = 16 [us]
//      o_t_ser = 10'd512;

    end

    2'd2  : begin
      // 50 ns * 4 = 200 ns
      o_t_tADs  = 4'd4;
      o_t_tADh  = 4'd4;

      // 50 ns * 11 = 550 ns ns
      o_t_tAC   =  5'd11;

      // 50 ns * 12 = 600 ns
      o_t_tRD    = 5'd12 - o_t_tAC;

      // 50 us * 20 = 1. [ms]
      o_t_tPGM  = 6'd20;

      // 50 ns * 320 = 16 [us]
//      o_t_ser = 10'd320;
    end

    2'd1  : begin
      // 100 ns * 2 = 200 ns 
      o_t_tADs  = 4'd2;
      o_t_tADh  = 4'd2;

      // 100 ns * 6 = 600 ns
      o_t_tAC   =  5'd6;

      // 100 ns * 6 = 600 ns
      o_t_tRD    = 5'd6 - o_t_tAC;

      // 100 us * 10 = 1 [ms]
      o_t_tPGM  = 6'd10;

      // 100 ns * 160 = 16 [us]
//      o_t_ser = 10'd160;
    end

    2'd0  : begin // 1Mhz
      // 1000 ns * 1 =  1000 ns
      o_t_tADs  = 4'd1;
      o_t_tADh  = 4'd1;

      // 1000 ns * 1 = 1000 ns
      o_t_tAC   =  5'd1;

      // 1000 ns * 1 = 1000 ns
      o_t_tRD    = 5'd1 - o_t_tAC;

      // 1000 us * 1 = 1 [ms]
      o_t_tPGM  = 6'd1;

      // 1000 ns * 16 = 16 us
      //o_t_ser   = 10'd16;
    end

    default   : begin // default
      o_t_tADs  = 4'd1;
      o_t_tADh  = 4'd1;
      o_t_tAC   = 5'd1;
      o_t_tRD   = 5'd1 - o_t_tAC;
      o_t_tPGM  = 6'd1; 
//      o_t_ser   = 10'd16;
    end
  endcase
end

endmodule
