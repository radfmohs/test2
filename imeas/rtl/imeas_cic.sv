//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap Glucose Chip   
// File name:    imeas_cic.v 
// Module Name : imeas_cic
// Description : 
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author          Description      
//------------------------------------------------------------------------------
// 0.1                                      Initial Rev 
//------------------------------------------------------------------------------
module imeas_cic (
  clk,
  resetn,
//imeas_en,
  imeas_input_format,
  filter_in,
  DR,
//cic_rate,
/*
  d2a_tsc_core_fch_reg,
  d2a_tsc_sdm_chop_reg,
  core_sel,
  chop_sel,
  wave_sel,
  d2a_tsc_core_fch,
  d2a_tsc_sdm_chop,
*/
  format_sel,
  filter_out,
  eoc_out
 );

  input            clk;
  input            resetn;
//input            imeas_en;
  input [1:0]	   imeas_input_format;
  input            filter_in;
  input  [3:0]     DR;
//input  [2:0]     cic_rate;
/*
  input wire       d2a_tsc_core_fch_reg;
  input wire       d2a_tsc_sdm_chop_reg;
  input wire       core_sel;
  input wire       chop_sel;
  input wire [1:0] wave_sel;
  output wire      d2a_tsc_core_fch;
  output wire      d2a_tsc_sdm_chop;
*/
  input            format_sel;
//output [15:0]    filter_out;
  output [31:0]    filter_out;
  output           eoc_out;

 //reg imeas_en_d1;
 //reg imeas_en_d2;
 
//Bmax=Bin+4*16+1;expand sign
 reg [16:0]count;
 reg [65:0]integ1;
 reg [65:0]integ2;
 reg [65:0]integ3;
 reg [65:0]integ4;
 reg [65:0]comb1_d1;
 reg [65:0]comb1_d2;
 reg [65:0]comb1;
 reg [65:0]comb2;
 reg [65:0]comb3;
 reg [65:0]comb4;
 wire [65:0]comb1_dec;
 wire [65:0]comb2_dec;
 wire [65:0]comb3_dec;
 wire [65:0]comb4_dec;
 wire [65:0]din_use;
 wire [65:0]din_use1;
 wire [16:0]down_rate;
 
//assign din_use =  {{45{1'b0}},1'b1} ;
//for 1 to -1 and 0 to 1
/*
 assign din_use = 
		  (filter_in) ? {{45{1'b1}},1'b1} : {{45{1'b0}},1'b1};
*/
//for verification
/*
 assign din_use = 
		  (filter_in) ? {{45{1'b0}},1'b1} : {{45{1'b0}},1'b0};
*/
wire  [3:0] cic_rate;
assign   cic_rate = DR;
/*
 assign din_use = (imeas_input_format == 2'b00) ? 
			((filter_in) ? {{65{1'b0}},1'b1} : {{65{1'b0}},1'b0}) :  		  
	          (imeas_input_format == 2'b01) ?
		        ((filter_in) ? {{65{1'b1}},1'b1} : {{65{1'b0}},1'b1}) :
		        ((filter_in) ? {{65{1'b0}},1'b1} : {{65{1'b1}},1'b1});
*/
assign din_use = (imeas_input_format == 2'b00) ? 
			((filter_in) ? {{65{1'b0}},1'b1} : {{65{1'b0}},1'b0}) :  		  
	          (imeas_input_format == 2'b01) ?
		        ((filter_in) ? {{65{1'b1}},1'b1} : {{65{1'b0}},1'b1}) :
		  (imeas_input_format == 2'b10) ?
		        ((filter_in) ? {{65{1'b0}},1'b1} : {{65{1'b1}},1'b1}) :
		        ((filter_in) ? {{65{1'b1}},1'b1} : {{65{1'b0}},1'b0}) ;;

assign down_rate = (cic_rate == 4'b000) ? 17'h7:
                    (cic_rate == 4'b001) ? 17'hf:
                    (cic_rate == 4'b010) ? 17'h1f:
                    (cic_rate == 4'b011) ? 17'h3f:
                    (cic_rate == 4'b100) ? 17'h7f:
                    (cic_rate == 4'b101) ? 17'hff:
                    (cic_rate == 4'b110) ? 17'h1ff:
                    (cic_rate == 4'b111) ? 17'h3ff:
		    (cic_rate == 4'b1000) ? 17'h7ff:
		    (cic_rate == 4'b1001) ? 17'hfff:
		    (cic_rate == 4'b1010) ? 17'h1fff:
		    (cic_rate == 4'b1011) ? 17'h3fff:
		    (cic_rate == 4'b1100) ? 17'h7fff:
		    (cic_rate == 4'b1101) ? 17'hffff:
                                            17'hffff;
/* 
 wire [11:0]down_rate_dividedby2;
 wire [11:0]down_rate_dividedby4;
 wire [11:0]down_rate_dividedby8;
 assign down_rate_dividedby2 = down_rate >> 1;
 assign down_rate_dividedby4 = down_rate >> 2;
 assign down_rate_dividedby8 = down_rate >> 3;

 wire wave_chg;
 wire phase_4;
 assign phase_4 = (count ==  down_rate_dividedby4) | 
		  (count ==  down_rate_dividedby2) | 
		  (count ==  down_rate_dividedby2 + down_rate_dividedby4 + 1) | 
		  (count ==  down_rate);
 wire phase_8;
 assign phase_8 = phase_4 | (count ==  down_rate_dividedby8) | 
			    (count ==  down_rate_dividedby4 + down_rate_dividedby8 + 1) |
		            (count ==  down_rate_dividedby2 + down_rate_dividedby8 + 1) |
			    (count ==  down_rate - down_rate_dividedby8 - 1); 
assign wave_chg = (wave_sel == 2'b00) ? ((count ==  down_rate_dividedby2) | (count ==  down_rate)) :
		  (wave_sel == 2'b01) ? phase_4 :
		  (wave_sel == 2'b10) ? phase_8 :
		  ((count ==  down_rate_dividedby2) | (count ==  down_rate));
*/
//assign din_use1 = din_use;
 //data expand,B(din_use) =1+Bmax,other add "0"
/*
 assign din_use1 =  (cic_rate == 3'b000) ? {din_use[16:0],18'b0}:
                    (cic_rate == 3'b001) ? {din_use[19:0],15'b0}:
                    (cic_rate == 3'b010) ? {din_use[22:0],12'b0}:
                    (cic_rate == 3'b011) ? {din_use[25:0],9'b0}:
                    (cic_rate == 3'b100) ? {din_use[28:0],6'b0}:
                    (cic_rate == 3'b101) ? {din_use[31:0],3'b0}:
                    (cic_rate == 3'b110) ?  din_use[45:0]:
                                            din_use;
*/
//because resolution is changed to 24 bits
 //assign din_use1 =  (cic_rate == 3'b000) ? {din_use[21:0],24'b0}:
 assign din_use1 =  (cic_rate == 4'b000) ? {din_use[13:0],52'b0}:
                    (cic_rate == 4'b001) ? {din_use[17:0],48'b0}:
                    (cic_rate == 4'b010) ? {din_use[21:0],44'b0}:
                    (cic_rate == 4'b011) ? {din_use[25:0],40'b0}:
                    (cic_rate == 4'b100) ? {din_use[29:0],36'b0}:
                    (cic_rate == 4'b101) ? {din_use[33:0],32'b0}:
                    (cic_rate == 4'b110) ? {din_use[37:0],28'b0}:
                    (cic_rate == 4'b111) ? {din_use[41:0],24'b0}:
                    (cic_rate == 4'b1000) ?  {din_use[45:0],20'b0}:
                    (cic_rate == 4'b1001) ?  {din_use[49:0],16'b0}:
                    (cic_rate == 4'b1010) ?  {din_use[53:0],12'b0}:
                    (cic_rate == 4'b1011) ?  {din_use[57:0],8'b0}:
                    (cic_rate == 4'b1100) ?  {din_use[61:0],4'b0}:
                    (cic_rate == 4'b1101) ?  din_use[65:0]:
                                             din_use;
/*
 always @(posedge clk or negedge resetn)
   if(!resetn) begin
 	imeas_en_d1 <= 1'b0;
 	imeas_en_d2 <= 1'b0;
   end else begin
 	imeas_en_d1 <= imeas_en;
 	imeas_en_d2 <= imeas_en_d1;
   end
*/

//wire imeas_en_d2 = 1'b1;
 
 //wire sample;
 //assign sample = (count >= down_rate);
 wire sample_tmp;
 assign sample_tmp = (count >= down_rate);
 
 reg sample_tmp_d1;
 always @(posedge clk or negedge resetn)
   if(!resetn)
 	sample_tmp_d1 <= 1'b0;
   else
 	sample_tmp_d1 <= sample_tmp;

 wire sample = sample_tmp & (~sample_tmp_d1);

 always @(posedge clk or negedge resetn)
   if(!resetn)
     count <= 17'hffff;
   else if(sample)
     count <= 17'h0;
   //else
   //else if(imeas_en_d2)
   else 
     count <= count + 17'b1;

 always @(posedge clk or negedge resetn)
   if(!resetn) 
   begin
     integ1 <= 66'h0;
     integ2 <= 66'h0;
     integ3 <= 66'h0;
     integ4 <= 66'h0;
   end
   //else if(imeas_en_d2) begin
   else  begin
     integ1 <= integ1 + din_use1;
     integ2 <= integ1 + integ2;
     integ3 <= integ2 + integ3;
     integ4 <= integ3 + integ4;
   end

  //assign comb1_dec = integ3 - comb1;
  assign comb1_dec = integ4 - comb1;
  assign comb2_dec = comb1_dec - comb2;
  assign comb3_dec = comb2_dec - comb3;
  assign comb4_dec = comb3_dec - comb4;

  //because resolution  is changed to 24 bits
  //reg [16:0]cic_out_0;
  reg [32:0]cic_out_0;
  //reg [45:0]cic_out_0;
  always @(posedge clk or negedge resetn)
    if(!resetn)
    begin
      comb1 <= 66'h0;
      comb2 <= 66'h0;
      comb3 <= 66'h0;
      comb4 <= 66'h0;
      //cic_out_0 <= 17'h0;
      cic_out_0 <= 33'h0;
      //cic_out_0 <= 35'h0;
    end
    //else if(sample & imeas_en_d2)
    else if(sample)
    begin
      //comb1 <= integ3;
      comb1 <= integ4;
      comb2 <= comb1_dec;
      comb3 <= comb2_dec;
      comb4 <= comb3_dec;
      cic_out_0 <= comb4_dec[65:33];
      //cic_out_0 <= comb4_dec[53:29];
      //cic_out_0 <= comb3_dec[45:21];
    end
  //check overflow
  //wire [45:0]cic_out_1;
  //wire [15:0]cic_out_1;
  //wire [23:0]cic_out_1;
  wire [31:0]cic_out_1;
/*
  assign cic_out_1 = (imeas_input_format == 2'b00) ? cic_out_0[15:0] : 
			(cic_out_0[16:15] == 2'b10) ? 16'h8000:
                     (cic_out_0[16:15] == 2'b01) ? 16'h7fff:
                     cic_out_0[15:0];
*/
  assign cic_out_1 = (imeas_input_format == 2'b00) ? cic_out_0[31:0] : 
		     (cic_out_0[32:31] == 2'b10) ? 32'h80000000:
                     (cic_out_0[32:31] == 2'b01) ? 32'h7fffffff:
                     cic_out_0[31:0];


  //assign cic_out_1 = cic_out_0[23:7];
  
  //check format
  //wire [15:0]cic_out_sel;
  //assign cic_out_sel = format_sel ? (cic_out_1+16'h8000) :cic_out_1;
/*
  wire[23:0] cic_out_1_tune;
  assign     cic_out_1_tune = 	(cic_rate == 3'b000) ?  {{3{cic_out_1[23]}},cic_out_1[23:3]}:
                        	(cic_rate == 3'b111) ?  {{7{cic_out_1[23]}},cic_out_1[23:7]}:
                        	cic_out_1;
*/
  wire[31:0] cic_out_1_tune;
  assign     cic_out_1_tune =   cic_out_1; 

  wire [31:0]cic_out_sel;
  //assign cic_out_sel = format_sel ? (cic_out_1+24'h800000) :cic_out_1;
  assign cic_out_sel = format_sel ? (cic_out_1_tune+32'h80000000) :cic_out_1_tune;


  //eco out ?
  reg [2:0]cont_dely;
  wire cont_dely_en;
  assign cont_dely_en = (cont_dely < 3'h5) & sample;

  always @(posedge clk or negedge resetn)
    if(!resetn)
      cont_dely <= 3'h0;
    else if(cont_dely_en)
      cont_dely <= cont_dely + 1'b1;
    else
      cont_dely <= cont_dely;

  reg eoc_out_reg;
  always @(posedge clk or negedge resetn)
    if(!resetn)
      eoc_out_reg <= 1'b0;
    else if(cont_dely == 3'h5)
      eoc_out_reg <= sample;
    else
      eoc_out_reg <= eoc_out_reg;

  reg eoc_out_reg_1t;
  always @(posedge clk or negedge resetn)
    if(!resetn) 
      eoc_out_reg_1t <= 1'b0;
    else
      eoc_out_reg_1t <= eoc_out_reg;
  
  assign filter_out = cic_out_sel;

  assign eoc_out = eoc_out_reg_1t;

//for test
/*
reg [2:0] cont_dely_d1;
  always @(posedge clk or negedge resetn)
    if(!resetn) 
	cont_dely_d1 <= 'b0;
    else
	cont_dely_d1 <= cont_dely;
wire[23:0] filter_out_neg_abs;
assign filter_out_neg_abs = (cont_dely_d1 == 3'h5) ?  (filter_out[23] ? 24'hffffff - filter_out : filter_out) : 'b0;
wire[23:0] filter_out_abs;
assign filter_out_abs = (cont_dely_d1 == 3'h5) ?   filter_out : 24'h800000;
*/
/*
  reg wave_generator;
  always @(posedge clk or negedge resetn)
    if(!resetn) 
      wave_generator <= 1'b0;
    else if(sample)
      wave_generator <= 1'b0;
    else if(wave_chg)
      wave_generator <= ~wave_generator;

assign d2a_tsc_core_fch = core_sel ? d2a_tsc_core_fch_reg : wave_generator;
assign d2a_tsc_sdm_chop = chop_sel ? d2a_tsc_sdm_chop_reg : wave_generator;
*/

endmodule
