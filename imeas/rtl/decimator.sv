// decimator filter design by sam 2023/11/29
// updated by Ophina 01/10/2025
// RST      power on reset
// M4CLK     1MEGhz CLK
// Din      from modulator data 
// CNR      down sample rate
// Dout     decimator output 
// 
`timescale	1ns/10ps
`define		DLY	1

`ifdef BPS1_PRODUCT
  `define         OSR_SIZE 3
  `define         CN_SIZE  `FILTER_DATA_WIDTH + 21 + 3
  `define         DN_SIZE  `CN_SIZE
  `define         COUNTER_SIZE 12
`elsif SINC_3_EN
  `define         OSR_SIZE 4
  `define         CN_SIZE  `FILTER_DATA_WIDTH + 24 + 2 
  `define         DN_SIZE  `CN_SIZE
  `define         COUNTER_SIZE 12
`else
  `define         OSR_SIZE 4
  `define         CN_SIZE  `FILTER_DATA_WIDTH + 33 + 3
  `define         DN_SIZE  `CN_SIZE
  `define         COUNTER_SIZE 16
`endif

module ADCDec1(RST, ADCEN, CLK4M, Din, OSR, FORMAT, TRIG, Dout);
  
  input	                    RST;
  input	                    ADCEN;
  input	                    CLK4M;
  input                     Din;
  input	 [`OSR_SIZE-1:0]    OSR;
  input	 [1:0]	            FORMAT;
  input                     TRIG;
  output [`FILTER_DATA_WIDTH-1:0] Dout;   // Often 24-bit or 32-bit

  reg    [`CN_SIZE-1:0] CN5;
  reg	 [`CN_SIZE-1:0]	DN0;
  reg	 [`CN_SIZE-1:0]	DN1;		
  reg	 [`CN_SIZE-1:0]	DN3;   
  reg	 [`CN_SIZE-1:0]	DN5;
  reg    [`CN_SIZE-1:0] DN6;	
  reg    [`CN_SIZE-1:0] CN0;
  reg	 [`CN_SIZE-1:0]	CN1;	
  reg	 [`CN_SIZE-1:0]	CN2;	
  reg	 [`CN_SIZE-1:0]	CN3;	
  reg	 [`CN_SIZE-1:0]	CN4;
  reg    [`CN_SIZE-1:0] CN6;
	
  reg	 [`CN_SIZE-1:0]	delta1;		
     
  wire   [`FILTER_DATA_WIDTH:0]	Dout_tmp;   //32:0

// Extracting the filter output data of required bits based on different OSR
//`ifndef BPS1_PRODUCT
`ifdef BPS1_PRODUCT
   assign       #`DLY Dout_tmp[`FILTER_DATA_WIDTH:0] =  (OSR === 4'h0) ? CN6[`FILTER_DATA_WIDTH:0]     ://32
                                                        (OSR === 4'h1) ? CN6[`FILTER_DATA_WIDTH+1:1]   ://64
                                                        (OSR === 4'h2) ? CN6[`FILTER_DATA_WIDTH+5:5]   ://128
                                                        (OSR === 4'h3) ? CN6[`FILTER_DATA_WIDTH+9:9]   ://256
                                                        (OSR === 4'h4) ? CN6[`FILTER_DATA_WIDTH+13:13] ://512
                                                        (OSR === 4'h5) ? CN6[`FILTER_DATA_WIDTH+17:17] ://1024
                                                        (OSR === 4'h6) ? CN6[`FILTER_DATA_WIDTH+21:21] ://2048
                                                                         CN6[`FILTER_DATA_WIDTH:0];     //16

`elsif SINC_3_EN
   assign       #`DLY Dout_tmp[`FILTER_DATA_WIDTH:0] =  (OSR === 4'h0) ? {CN5[`FILTER_DATA_WIDTH-14:0],14'b0} :   // 8
                                                        (OSR === 4'h1) ? {CN5[`FILTER_DATA_WIDTH-11:0],11'b0} :   // 16
                                                        (OSR === 4'h2) ? {CN5[`FILTER_DATA_WIDTH-8:0],8'b0}   :   // 32
                                                        (OSR === 4'h3) ? {CN5[`FILTER_DATA_WIDTH-5:0],5'b0}   :   // 64
                                                        (OSR === 4'h4) ? {CN5[`FILTER_DATA_WIDTH-2:0],2'b0}   :   // 128
                                                        (OSR === 4'h5) ? CN5[`FILTER_DATA_WIDTH+1:1]            :   // 256
                                                        (OSR === 4'h6) ? CN5[`FILTER_DATA_WIDTH+4:4]          :   // 512
                                                        (OSR === 4'h7) ? CN5[`FILTER_DATA_WIDTH+7:7]          :   // 1024
                                                        (OSR === 4'h8) ? CN5[`FILTER_DATA_WIDTH+10:10]          :   // 2048
                                                        (OSR === 4'h9) ? CN5[`FILTER_DATA_WIDTH+13:13]        :   // 4096
                                                        (OSR === 4'hA) ? CN5[`FILTER_DATA_WIDTH+16:16]        :   // 8192
                                                        (OSR === 4'hB) ? CN5[`FILTER_DATA_WIDTH+19:19]        :   // 16384
                                                        (OSR === 4'hC) ? CN5[`FILTER_DATA_WIDTH+22:22]        :   // 32768
                                                        (OSR === 4'hD) ? CN5[`FILTER_DATA_WIDTH+25:25]        :   // 65536
                                                                         CN5[`FILTER_DATA_WIDTH+25:25];  
`else
   assign	#`DLY Dout_tmp[`FILTER_DATA_WIDTH:0] =	(OSR === 4'h0) ? {CN6[`FILTER_DATA_WIDTH-19:0],19'b0} ://8
					                (OSR === 4'h1) ? {CN6[`FILTER_DATA_WIDTH-15:0],15'b0} ://16
					                (OSR === 4'h2) ? {CN6[`FILTER_DATA_WIDTH-11:0],11'b0} ://32
					                (OSR === 4'h3) ? {CN6[`FILTER_DATA_WIDTH-7:0],7'b0}   ://64
					                (OSR === 4'h4) ? {CN6[`FILTER_DATA_WIDTH-3:0],3'b0}   ://128
					                (OSR === 4'h5) ? CN6[`FILTER_DATA_WIDTH+1:1]          ://256
					                (OSR === 4'h6) ? CN6[`FILTER_DATA_WIDTH+5:5]          ://512
							(OSR === 4'h7) ? CN6[`FILTER_DATA_WIDTH+9:9]          ://1024
					                (OSR === 4'h8) ? CN6[`FILTER_DATA_WIDTH+13:13]        ://2048
					                (OSR === 4'h9) ? CN6[`FILTER_DATA_WIDTH+17:17]        ://4096
					                (OSR === 4'hA) ? CN6[`FILTER_DATA_WIDTH+21:21]        ://8192
					                (OSR === 4'hB) ? CN6[`FILTER_DATA_WIDTH+25:25]        ://16384
					                (OSR === 4'hC) ? CN6[`FILTER_DATA_WIDTH+29:29]        ://32768
					                (OSR === 4'hD) ? CN6[`FILTER_DATA_WIDTH+33:33]        ://65536
							                 CN6[`FILTER_DATA_WIDTH+33:33];
`endif

// Overflow management of filter output data
assign  #`DLY Dout[`FILTER_DATA_WIDTH-1:0] = (FORMAT == 2'b00) ? Dout_tmp[`FILTER_DATA_WIDTH-1:0] :
				                                (Dout_tmp[`FILTER_DATA_WIDTH:`FILTER_DATA_WIDTH-1] == 2'b10) ? (1 << (`FILTER_DATA_WIDTH-1)) :
				                                (Dout_tmp[`FILTER_DATA_WIDTH:`FILTER_DATA_WIDTH-1] == 2'b01) ? (1 << (`FILTER_DATA_WIDTH-1)) - 1 : Dout_tmp[`FILTER_DATA_WIDTH-1:0];

//************************************************* CIC filter Logic of integrators & combs *********************************************/
always @(negedge RST or posedge CLK4M )//change posedge RST
  begin
    if (~RST)
      delta1	<= #`DLY `CN_SIZE'b0;
    else begin	//delta1	<= #`DLY (ADCEN)? delta1 + Din: (`CN_SIZE)'b0;
      case(FORMAT)
	2'b00: delta1	<= #`DLY (ADCEN)? delta1 + Din: `CN_SIZE'b0;
	2'b01: delta1	<= #`DLY (ADCEN)? ((Din) ? (delta1 + {{(`CN_SIZE-1){1'b1}},1'b1}) : (delta1 + {{(`CN_SIZE-1){1'b0}},1'b1})) : delta1/*(`CN_SIZE)'b0*/;
	2'b10: delta1	<= #`DLY (ADCEN)? ((Din) ? (delta1 + {{(`CN_SIZE-1){1'b0}},1'b1}) : (delta1 + {{(`CN_SIZE-1){1'b1}},1'b1})) : delta1/*(`CN_SIZE)'b0*/;
	2'b11: delta1	<= #`DLY (ADCEN)? ((Din) ? (delta1 + {{(`CN_SIZE-1){1'b1}},1'b1}) : (delta1 + {{(`CN_SIZE-1){1'b0}},1'b0})) : delta1/*(`CN_SIZE)'b0*/;
      endcase
    end
  end

always @(negedge RST or posedge CLK4M)//change posedge RST
  begin
    if (~RST)
      begin
  	CN0	<= #`DLY `CN_SIZE'b0;   
	CN1	<= #`DLY `CN_SIZE'b0;
	//CN2	<= #`DLY `CN_SIZE'b0;
      end
    else 
      begin
  	CN0	<= #`DLY (ADCEN)? CN0 + delta1: CN0/*(`CN_SIZE)'b0*/;
	CN1	<= #`DLY (ADCEN)? CN1 + CN0: 	CN1/*(`CN_SIZE)'b0*/;
	//CN2	<= #`DLY (ADCEN)? CN2 + CN1:	CN2/*(`CN_SIZE)'b0*/;
      end
    end

always @(negedge RST or posedge CLK4M)//change posedge RST
  begin
    if (~RST)
      begin
	DN0	<= #`DLY `CN_SIZE'b0;
	DN1	<= #`DLY `CN_SIZE'b0;
	DN3	<= #`DLY `CN_SIZE'b0;
	DN5	<= #`DLY `CN_SIZE'b0;
`ifndef SINC_3_EN
        DN6	<= #`DLY `CN_SIZE'b0;
`endif
      end 		
    else if (TRIG)
      begin
	DN0	<= #`DLY (ADCEN)? CN1: DN0/*(`CN_SIZE)'b0*/;
	DN1	<= #`DLY (ADCEN)? DN0: DN1/*(`CN_SIZE)'b0*/;
	DN3	<= #`DLY (ADCEN)? CN3: DN3/*(`CN_SIZE)'b0*/;
	DN5	<= #`DLY (ADCEN)? CN4: DN5/*(`CN_SIZE)'b0*/;
`ifndef SINC_3_EN
	DN6	<= #`DLY (ADCEN)? CN5: DN6/*(`CN_SIZE)'b0*/;
`endif
      end
    end

`ifdef SINC_3_EN
always @(DN0 or DN1)
  CN3	<= #`DLY DN0 - DN1;

always @(CN3 or DN3)
  CN4	<= #`DLY CN3 - DN3;

always @(CN4 or DN5)
  CN5	<= #`DLY CN4 - DN5;		

`else
always @(DN0 or DN1)
  CN3	<= #`DLY DN0 - DN1;

always @(CN3 or DN3)
  CN4	<= #`DLY CN3 - DN3;

always @(CN4 or DN5)
  CN5	<= #`DLY CN4 - DN5;			

always @(CN5 or DN6)
  CN6	<= #`DLY CN5 - DN6;
`endif

//************************************************************************************************************************************/

endmodule


module ADCDec_3(IAin, RST, ADCEN, ADC_CLK, OSR, FORMAT, TRIG, IA);	  
  input		IAin;
  input		RST;
  input		ADCEN;
  input		ADC_CLK;	//4MEGHZ input
//input           offset;
  input	[`OSR_SIZE-1:0]	OSR;
  input   [1:0]   FORMAT;
  output		TRIG;
  output	[`FILTER_DATA_WIDTH-1:0]  IA;   // 31:0

  reg	[`COUNTER_SIZE-1:0]	count;
//reg	[1:0]	DSSEL_sync;
  wire		TRIG;
  wire	[`FILTER_DATA_WIDTH-1:0]  IA;
        
//assign	#`DLY	CLK = 	(ADC_CLK & offset);
//assign	#`DLY	TRIG = 	(count == 5'h1f);
 
`ifdef BPS1_PRODUCT
   assign  #`DLY TRIG =  (OSR<7) ? (count == (12'h20 * 2.0**OSR - 1)) : (count == 12'hf);
`elsif SINC_3_EN
   assign  #`DLY   TRIG =  (count == (12'h8 * 2.0**OSR - 1));
`else
   assign  #`DLY TRIG = (count == (16'h8 * 2.0**OSR - 1));
`endif

ADCDec1 decIA(	
  .RST(RST),
  .ADCEN(ADCEN),
  .CLK4M(ADC_CLK),
  .Din(IAin),
  .OSR(OSR),
  .FORMAT(FORMAT),
  .TRIG(TRIG),
  .Dout(IA)
);

//********************* Logic of counter to follow sample rate based on OSR setting *********************/
always @(negedge RST or posedge ADC_CLK)//change posedge RST
  begin
    if (~RST)
      //count	<= #`DLY 5'b0;
      count	<= #`DLY {(`COUNTER_SIZE){1'b1}};
    else begin	//count	<= #`DLY (ADCEN)? count + 1: 5'b0;
      if (ADCEN) begin
`ifdef BPS1_PRODUCT
        if (((OSR<7) & (count < (`COUNTER_SIZE'h20 * 2.0**OSR - 1))) | ((OSR===7) & (count < {(`COUNTER_SIZE){1'b1}})))
`elsif SINC_3_EN
        if(count < (12'h8 * 2.0**OSR - 1))
`else
	if (count < (`COUNTER_SIZE'h8 * 2.0**OSR - 1))
`endif
	  count	<= #`DLY (count + 1);
	else
	  count	<= #`DLY {(`COUNTER_SIZE){1'b0}};;
      end
      else begin
	count	<= #`DLY {(`COUNTER_SIZE){1'b1}};
      end
    end
  end

//*********************************************************************************************************/
endmodule


//`ifdef SINC_3_EN
//module test_SINC_3 #(
//`else
module test_SINC_4_24B #(
//`endif
  parameter    file_adc ="",
  parameter    string file_adc_out
)
// --------------------------------------------------------------------------
// Port Definitions
// --------------------------------------------------------------------------
(       
  input	        POR,
  input         ADC_RST,
  input         ADC_CLK,
  input         ADC_IN,
  input         CH_EN,
  input  [`OSR_SIZE-1:0]  OSR,
  input         OFFSET,
  input  [1:0]  FORMAT,
  output [`FILTER_DATA_WIDTH-1:0] IA,
  output        IA_valid
);	
  reg           offset;
  reg           trig;
  reg           IAin_same;
  reg           IAin_inv;
`ifdef SINC_3_EN
  reg           memory[0:1433599];
`else
  reg           memory[0:79999];
`endif
  wire          TRIG;
  reg           TRIG_valid;
  reg [2:0]     trig_cnt;
  wire          trig_cnt_en;

  wire          RST;
  wire          IAin;

assign RST = POR & ADC_RST;

//If sine-gen or noise-gen enabled, use the adc input data from sdm analog model, otherwise generate IAin by reading matlab raw data files
assign IAin = (dut_vif.imeas_sin_gen_en === 1) ? ADC_IN :
                                                (dut_vif.imeas_noise_gen_en === 1) ? ADC_IN :
                                               ((dut_vif.imeas_adc_inv === 1) ? IAin_inv : IAin_same);
// wire [31:0]   IA;

// integer  memory[0:25000];
integer  file;

integer J;
integer K;

// assign	#`DLY	CLK = 	(ADC_CLK & offset);
// assign	#`DLY	CLK = 	ADC_CLK;
// ADCDec_3  ADCDec(IAin, POR,  1'b1, CLK, TRIG, IA);
// ADCDec_3  ADCDec(IAin, POR,  offset, ADC_CLK, TRIG, IA);

ADCDec_3  ADCDec(IAin, RST,  offset, ADC_CLK, OSR, FORMAT, TRIG, IA);

initial
  begin
    $readmemb(file_adc,memory);
    file=$fopen(file_adc_out);   
        	       
    //POR = 1'b1;
    //ADC_CLK  = 1'b0;
    //CLKIN  = 1'b0;
    //offset = 1'b1;

    J=0;
    K=0;

   //#123 POR = 1'b0;
   #10 IAin_same=1'b0;
   IAin_inv=1'b0;
 end

always @(*)
  if(~POR) begin
    offset = 0;
    trig = 0;
  end else begin
    offset = OFFSET;
    trig = TRIG;
  end

always @(negedge trig)//change posedge
  begin
`ifdef BPS1_PRODUCT
    $fdisplay(file,"%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d  ", IA[23], IA[22], IA[21], IA[20], IA[19], IA[18]
      , IA[17], IA[16], IA[15], IA[14], IA[13], IA[12] ,IA[11], IA[10], IA[9], IA[8], IA[7], IA[6], IA[5], IA[4] ,IA[3], IA[2], IA[1], IA[0]);
`elsif SINC_3_EN
    $fdisplay(file,"%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d  ", IA[23], IA[22], IA[21], IA[20], IA[19], IA[18]
      , IA[17], IA[16], IA[15], IA[14], IA[13], IA[12] ,IA[11], IA[10], IA[9], IA[8], IA[7], IA[6], IA[5], IA[4] ,IA[3], IA[2], IA[1], IA[0]);
`else
    $fdisplay(file,"%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d  ", IA[31], IA[30], IA[29], IA[28], IA[27], IA[26], IA[25], IA[24], IA[23], IA[22], IA[21], IA[20], IA[19], IA[18]
      , IA[17], IA[16], IA[15], IA[14], IA[13], IA[12] ,IA[11], IA[10], IA[9], IA[8], IA[7], IA[6], IA[5], IA[4] ,IA[3], IA[2], IA[1], IA[0]); 
`endif
  end

//***** Logic to generate IA_valid. Every time when filter reset is released, the 1st 4 samples will be ignored, valid sample will be obtained from 5th sample onwards *****/
assign trig_cnt_en = (trig_cnt < 3'h4) & TRIG;
assign IA_valid = TRIG_valid;

always @(posedge ADC_CLK or negedge RST)
  begin
    if (!RST)
      trig_cnt <= 3'h0;
    else if(trig_cnt_en)
      trig_cnt <= trig_cnt + 1'b1;
  end

always @(posedge ADC_CLK or negedge RST)
  begin
    if (!RST)
      TRIG_valid <= 1'b0;
    else if(trig_cnt == 3'h4)
      TRIG_valid <= TRIG;
  end
//****************************************************************************************************************************************************************************/

//always #31 ADC_CLK  = ~ADC_CLK ;
//***************** Logic to generate IAin based on matlab raw data files, depending on adc inverted clk enable, IAin_same & IAin_inv are generated separately ***************/
always @(posedge ADC_CLK or negedge POR)
  begin
    if (~POR) begin
      IAin_same = 0;
    end
    else begin
      if(CH_EN) begin
//`ifdef SINC_3_EN
//        if (J<=1433600)
//`else
        if (J<65535)		
//`endif
        begin
          IAin_same = memory[J];
	  J = J+1;
	end
	else begin
	  IAin_same = memory[J];
	  J = 0;
	end
      end
      else begin
	IAin_same = 0;
      end
    end
  end

always @(negedge ADC_CLK or negedge POR)
  begin
    if (~POR) begin
      IAin_inv = 0;
    end
   else begin
     if (CH_EN) begin
//`ifdef SINC_3_EN
//       if (K<=1433600)
//`else
       if (K<65535)		
//`endif
       begin
         IAin_inv = memory[K];
	 K = K+1;
       end
       else begin
         IAin_inv = memory[K];
	 K = 0;
       end
     end
     else begin
       IAin_inv = 0;
     end
   end
 end
//****************************************************************************************************************************************************************************/

endmodule
