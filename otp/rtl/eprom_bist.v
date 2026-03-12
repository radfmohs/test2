//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap ENS2  
// File name:    eeprom_bist.v
// Module Name : eeprom_bist
// Description : ENS1P4 Chip
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author          Description      
//------------------------------------------------------------------------------
// 0.1         1/4/2021          Zhen Cao              Initial Rev 
//------------------------------------------------------------------------------

module eprom_bist
(
	input  wire         			i_TCK		,
	input  wire         			i_RESETb	,
	input  wire         			i_TDI		,
	input  wire         			i_STROBE	, // Active low
	input  wire         			i_TESTEN	,
	input  wire [		  31:0]   	i_IP2ST		,
	output wire [(`WIDTH-6):0]       	o_ST2IP		,
	output reg          			o_TDO		, // or reg?
	output reg          			o_serout	,
	output reg          			o_vpp_en	,
	output wire         			o_OEN		
);

// internal signals
reg [		  15:0]	t_cnt		;
reg [		  6:0] 	addr_cnt	;
reg [(`WIDTH-7):0]	dg_data		;//need to update according to S_OTP
reg [		  3:0] 	main_state	;

reg       		strobe_t0	;
reg       		strobe_t1	;
reg       		strobe_t2	;

reg [(`WIDTH-1):0] 	s2p_sreg	;
reg [		  5:0] 	s2p_cnt		;
reg [(`WIDTH-1):0] 	s2p_data	;

//==============================================================
// Serial to parallel conversion
//==============================================================
always @(posedge i_TCK or negedge i_RESETb) begin: strobe_t0_ff
	if (!i_RESETb) 
		strobe_t0  <= 1'b1;
  	else
		strobe_t0  <= i_STROBE;
end

always @(posedge i_TCK or negedge i_RESETb)
  	if (!i_RESETb) begin
		s2p_cnt  <= 6'b0;
		s2p_data <= {`WIDTH{1'b0}};
	  	s2p_sreg <= {`WIDTH{1'b0}};
  	end else if(~strobe_t0 & i_STROBE & (s2p_cnt == 6'd`WIDTH)) begin
		s2p_cnt  <= 6'b0;
		s2p_data <= s2p_sreg;
  	end else if ((s2p_cnt < 6'd`WIDTH) && (~i_STROBE)) begin
		s2p_sreg <= {i_TDI, s2p_sreg[(`WIDTH-1):1]};
		s2p_cnt  <= s2p_cnt + 1'b1;
	end


//==============================================================
// timing
//==============================================================
wire  [15:0]	 t_ser;
reg   [15:0]     t_tRD,t_tPGM,t_tPGM_rc,t_tRD_marge,t_pori;

assign t_ser= 16'd16;

always @(s2p_data[`S_FREQ])
    begin
     case(s2p_data[`S_FREQ])
		2'b00 : begin //1mhz
                      t_tRD        = 16'd1;   
                      t_tRD_marge  = 16'd5;	 	      
		      t_tPGM       = 16'd325;  
		      t_tPGM_rc    = 16'd12;
                      t_pori 	   = 16'h2;			      
		end

		2'b01 : begin //10mhz
                      t_tRD        = 16'd2;   
                      t_tRD_marge  = 16'd10;	 	      		      
		      t_tPGM       = 16'd3250;  
		      t_tPGM_rc    = 16'd120;
                      t_pori 	   = 16'h4;			      
		end

	     
		2'b10 : begin //20mhz
                      t_tRD        = 16'd2;  
                      t_tRD_marge  = 16'd10;	 	      		      
		      t_tPGM       = 16'd6500;  
		      t_tPGM_rc    = 16'd240;
                      t_pori 	   = 16'h8;	
		end

		2'b11 : begin //32mhz
                      t_tRD        = 16'd3; 
                      t_tRD_marge  = 16'd15;	 	      		      
		      t_tPGM       = 16'd10400;  
		      t_tPGM_rc    = 16'd384;
                      t_pori 	   = 16'h12;	      
		end

		default : begin //1mhz
                      t_tRD        = 16'd1; 
                      t_tRD_marge  = 16'd5;	 	      		      
		      t_tPGM       = 16'd325;  
		      t_tPGM_rc    = 16'd12;
                      t_pori 	   = 16'h2;			      
		end
	 

     endcase
end



//==============================================================
// addr decode
//==============================================================
wire [4:0] addr_y;
wire [1:0] addr_x;
assign addr_y = 5'd31; //word
assign addr_x = 2'd3;  //byte

//==============================================================
// vpp logic
//==============================================================
reg vpp_en;

always @(posedge i_TCK or negedge i_RESETb) begin: clock_divider_ff
	if (!i_RESETb)
		o_vpp_en	<= 1'b0;
	else if (vpp_en)
		o_vpp_en        <= 1'b1;
	else
		o_vpp_en        <= 1'b0;
end



////////////////////////////////
//reset FSM after data ready
////////////////////////////////
always @(posedge i_TCK or negedge i_RESETb) begin: strobe_ff
  	if (!i_RESETb) begin
		strobe_t1  <= 1'b1;
		strobe_t2  <= 1'b1;
	end else begin
		strobe_t1  <= strobe_t0;
		strobe_t2  <= strobe_t1;
	end
end


////////////////////////
//FSM
///////////////////////
wire [1:0] margin_read_en;
wire [6:0] addr_valid;
wire       signal_read;
wire [6:0] wr_addr;

assign margin_read_en = (((s2p_data[`S_MS] == `OPM_SINGLE_MARGIN_READ) || (s2p_data[`S_MS] == `OPM_MULT_MARGIN_READ)) && ((s2p_data[`S_XTM]==2'b10) || (s2p_data[`S_XTM]==2'b11) )) ?  s2p_data[`S_XTM] : 2'b00;
assign addr_valid = ((s2p_data[`S_MS] == `OPM_SINGLE_READ) || (s2p_data[`S_MS] == `OPM_SINGLE_MARGIN_READ)) ? s2p_data[`S_XA] : addr_cnt; 
assign signal_read = ((s2p_data[`S_MS] == `OPM_SINGLE_MARGIN_READ) || (s2p_data[`S_MS] == `OPM_SINGLE_READ));
assign wr_addr =    (s2p_data[`S_MS] == `OPM_PROG) ? s2p_data[`S_XA] : addr_cnt;



reg addr_latch,reading,by_pass_reading;

always @(posedge i_TCK or negedge i_RESETb) begin: FSM_ff
  	if (!i_RESETb) begin
		t_cnt                   <= {16{1'b0}};
	  	addr_cnt                <= {7{1'b0}};
	  	dg_data                 <= {(`WIDTH-5){1'b0}};
	  	o_serout                <= 1'b0;
	  	main_state              <= `FSM_IDLE;
		addr_latch              <= 1'b0;
	        vpp_en                  <= 1'b0;
		reading                 <= 1'b0;
		by_pass_reading         <= 1'b0;
		

  	end 
	else if (!strobe_t2 & strobe_t1) begin
		t_cnt                   <= {16{1'b0}};
		addr_cnt                <= {7{1'b0}};
		dg_data                 <= (main_state==`FSM_BY_PASS)? dg_data : {(`WIDTH-5){1'b0}};
		o_serout                <= 1'b0;
		by_pass_reading         <= 1'b0;
		case (s2p_data[`S_MS])
			`OPM_STAND_BY                                   : main_state <= `FSM_IDLE	;
			`OPM_PROG,`OPM_MULT_PROG			: main_state <= `FSM_PROG_ENTER	; 
			`OPM_SINGLE_READ,`OPM_MULT_READ, 
		  	`OPM_SINGLE_MARGIN_READ, `OPM_MULT_MARGIN_READ  : main_state <= `FSM_READ	; 
		  	`OPM_BY_PASS                                    : main_state <= `FSM_BY_PASS;

			default					        : main_state <= `FSM_IDLE	;
		endcase
  	end 
	else if (t_cnt > 16'd0) begin
		t_cnt                   <= t_cnt - 1'b1;
		addr_cnt                <= addr_cnt;
		dg_data                 <= dg_data;
                addr_latch              <= addr_latch;
		o_serout                <= 1'b0;
		main_state              <= main_state;
	end 
	else begin
		case (main_state)  
	  		// Idle
	  		`FSM_IDLE   : begin
		                t_cnt                   <= {16{1'b0}};
	  	                addr_cnt                <= {7{1'b0}};
	  	                dg_data                 <= {(`WIDTH-5){1'b0}};
	  	                o_serout                <= 1'b0;
	  	                main_state              <= `FSM_IDLE;
		                addr_latch              <= 1'b0;
	                        vpp_en                  <= 1'b0;
	                 	reading                 <= 1'b0;

			end
                        //directly
			`FSM_BY_PASS  : begin
				dg_data[`S_XENTER]            	<= s2p_data[`S_XENTER]; 
		  		dg_data[`S_XREAD]          	<= s2p_data[`S_XREAD]; 	
				dg_data[`S_XTM]            	<= s2p_data[`S_XTM]; 
				dg_data[`S_PGM]            	<= s2p_data[`S_PGM]; 
				dg_data[`S_XA]             	<= s2p_data[`S_XA];  						
				dg_data[`S_XDIN]         	<= s2p_data[`S_XDIN]; 
				 if(dg_data[`S_XREAD] && !by_pass_reading) 
					 if(!reading) begin
                                          t_cnt                 <= ((s2p_data[`S_XTM]==2'b10) || (s2p_data[`S_XTM]==2'b11))? t_tRD_marge : t_tRD ;
				          o_serout              <= 1'b0;
					  reading               <= 1'b1;
				         end
					 else begin
                                          t_cnt                 <= t_ser;
					  reading               <= 1'b0;					  
				          o_serout              <= 1'b1;
					  by_pass_reading       <= 1'b1;
				         end	  
			end

	  		// Read
			`FSM_READ   : begin                  
      		                dg_data[`S_XENTER]                      <= 1'b0;
                                reading                              <= 1'b1;
				dg_data[`S_XTM]                      <= margin_read_en; 				
      		                dg_data[`S_XREAD]                    <= reading;
    		                t_cnt                                <= reading? (|margin_read_en)? t_tRD_marge : t_tRD : 
					                                         (|margin_read_en)? t_pori      : {14'b0,2'b11};				
                                dg_data[`S_XA]                       <= addr_valid;                                   		       
      		                if(reading) main_state               <= `FSM_RDATA;

      		        end
		        `FSM_RDATA :begin     		                
      		                o_serout            <= 1'b1;
      		                t_cnt               <= t_ser; 
                                main_state          <= `FSM_RDONE;
			        
			end
      		        `FSM_RDONE :begin
      		                dg_data[`S_XREAD]    <= 1'b0;
      		                o_serout             <= 1'b0;      		               
                                reading              <= 1'b0;                               
                                addr_cnt             <= addr_cnt + 1'b1;	
                            if(signal_read || (addr_cnt >= {addr_y,addr_x})) main_state   <= `FSM_IDLE;
                            else main_state  <= `FSM_READ;
      		        end


	               `FSM_PROG_ENTER : begin
			       vpp_en                   <= 1'b1;			       
                               dg_data[`S_XENTER]          <= 1'b1;              
      		               t_cnt                    <= 16'd20; 
                               main_state               <= `FSM_PROG_ACCESS;
                        end
			`FSM_PROG_ACCESS : begin
			       dg_data[`S_XA]     	<= wr_addr;
			       dg_data[`S_XDIN]         <= s2p_data[`S_XDIN]; 
                               main_state               <= `FSM_PROG;
			end
			`FSM_PROG : begin
      		               t_cnt                    <= t_tPGM;
			       dg_data[`S_PGM]    	<= 1'b1;			                      
                               main_state               <= `FSM_PROG_BYTE_DONE;
			end
			`FSM_PROG_BYTE_DONE : begin
			       dg_data[`S_PGM]    	<= 1'b0;			                      
			       addr_cnt           	<= addr_cnt + 1'b1;  
                               if(s2p_data[`S_MS] == `OPM_PROG || (addr_cnt >= {addr_y,addr_x}))	
                               main_state               <= `FSM_PROG_DONE;
		               else
                               main_state               <= `FSM_PROG_ACCESS;		 		       
			 end
			 `FSM_PROG_DONE : begin                                         
      		               t_cnt                    <= 16'd20; 
			       vpp_en                   <= 1'b0;
                               main_state               <= `FSM_PROG_EXIT;			 
			 end

			 `FSM_PROG_EXIT : begin
                               dg_data[`S_XENTER]       <= 1'b0;              
      		               t_cnt                    <= t_tPGM_rc; 
                               main_state               <= `FSM_IDLE;			 
			 end
       default : begin
                               main_state               <= `FSM_IDLE;	
       end                         
	  	endcase
	end
end
//==============================================================
// Finite State Machine ends - NOT YET - Verify on states
//==============================================================

// Output logicsreg [6:0] din_tmp,din_sr;
//

reg [6:0] din_tmp,din_sr;
reg [7:0] IP2ST_reg;

always @(*) begin
     case(dg_data[6:5])
       2'b00: begin
         IP2ST_reg=i_IP2ST[7:0];
       end
       2'b01: begin
         IP2ST_reg=i_IP2ST[15:8];
       end
       2'b10: begin
         IP2ST_reg=i_IP2ST[23:16];
       end
       2'b11: begin
         IP2ST_reg=i_IP2ST[31:24];
       end
       default: begin
         IP2ST_reg=i_IP2ST[7:0];
       end
     endcase
  end

always @(posedge i_TCK or negedge i_RESETb)     //for serial output
  	if (!i_RESETb) 
		din_tmp <= {7{1'b1}};
  	else 
		din_tmp <= IP2ST_reg[7:1];

always @(posedge i_TCK or negedge i_RESETb)     //for serial output
  	if (!i_RESETb) begin
		din_sr  <= {7{1'b1}};
		o_TDO   <= 1'b1;
  	end else if (o_serout) begin
		din_sr  <= din_tmp;
		o_TDO   <= IP2ST_reg[0];
  	end else begin
		o_TDO   <= din_sr[0];
		din_sr  <= {1'b1, din_sr[6:1]};
  	end

assign o_ST2IP	= i_TESTEN ? {s2p_data[`S_OTP],dg_data} : {(`WIDTH-5){1'b0}};
assign o_OEN	= !i_STROBE; //Generate bidirectional pad control pin o_OEN

endmodule 
