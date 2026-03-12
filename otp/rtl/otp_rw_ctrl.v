/*--------------------------------------------------------------------------------------*/
/*      Nanochap Confidential                                                           */
/*--------------------------------------------------------------------------------------*/
/* File Name	 : otp_rw_ctrl.v                                                        */
/* Project	 : ENS1P4 Chip                                                          */
/* Designer	 : zhen                                                                 */
/* Description	 : otp progarm and read fsm                                             */
/* Date		 : 1/4/2024                                                             */
/*--------------------------------------------------------------------------------------*/
/* Revision History :                                                                   */    
/* Data         Rev.     By             Description                                     */
/*--------------------------------------------------------------------------------------*/
/* 9/1/2024     1       zhen           otp progarm and read fsm                         */
/*--------------------------------------------------------------------------------------*/

module otp_rw_ctrl (
   input wire clk,
   input wire reset_n,
//   input wire atpg_en,

   // Control bits from Regbank
   input wire addr_valid,
   input wire otp_en,
   input wire otp_inf_epm_rw,
   input wire wr_working,

 //  input wire        vpp_h_en,
 //  input wire        vpp_l_en,
   input wire [12:0] otp_tRD,
   input wire [12:0] otp_tPGM, 
   input wire [12:0] otp_tPGM_rec,
   input wire [12:0] otp_tVPP,

   // FSM state outputs to other blocks
   output wire wr_enter_h_en,
   output wire wr_enter_l_en,
   output wire wr_vpp_l_en,
   output wire read_h_en,
   output wire read_l_en,
   output wire wr_h_en,
   output wire wr_l_en,
   output wire otp_inf_epm_blk_addr_set_en,
   output wire otp_inf_epm_blk_rd_set_en, 
   output wire otp_inf_epm_blk_wd_set_en
);

//------------------------------------------------------------------------------
// MODULE LOGIC BEGIN
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// localparams
//------------------------------------------------------------------------------
   localparam  IDLE                    = 4'h0;

 // information/OTP block read
   localparam  READ_INF_EPM_TCSCTRLS   = 4'h1;
   localparam  READ_INF_EPM_TRPW       = 4'h2;
   localparam  READ_INF_EPM_DONE       = 4'h3;

 // information/OTP block write
   localparam  WRITE_INF_EPM_TCSCTRLS  = 4'h4;
   localparam  WRITE_INF_EPM_TWPW      = 4'h5;
   localparam  WRITE_INF_EPM_DEC_DONE  = 4'h6;
   localparam  WRITE_WAIT_VPP_READY    = 4'h7;
   localparam  WRITE_VPP_READY         = 4'h8;
   localparam  WRITE_BYTE_DONE         = 4'h9;
   localparam  WRITE_WORD_DONE         = 4'ha;
   

// OTP read/write FSM timing parameters
   localparam TIMER_BITS_L = 13;

//------------------------------------------------------------------------------
// Internal registers and wires
//------------------------------------------------------------------------------
   reg [TIMER_BITS_L-1 : 0] timer_l;
   reg [3 : 0] cur_state,next_state;
//------------------------------------------------------------------------------
// Internal signals
//------------------------------------------------------------------------------
	wire   otp_inf_epm_rd_en;
	assign otp_inf_epm_rd_en = (otp_en) & (~otp_inf_epm_rw) & addr_valid;
	wire otp_inf_epm_wr_en;
   	assign otp_inf_epm_wr_en = (otp_en) & otp_inf_epm_rw;

//------------------------------------------------------------------------------
// Timer - Resets to 0 everytime the state CHANGES
//------------------------------------------------------------------------------
 always @ (posedge clk or negedge reset_n) begin
         if (~reset_n) begin
           timer_l <= 13'h000;
         end
         else if (cur_state != next_state) begin
           timer_l <= 13'h000;;
         end
         else if (cur_state != 4'h0)begin
           timer_l <= timer_l + 1'b1;
         end
 end

 //-----------------------------------------------------------------
// current State register
// Updates next_state to cur_state
//-----------------------------------------------------------------
always @ (posedge clk or negedge reset_n) begin
         if (~reset_n) 
		 cur_state <= IDLE;
         else 
		 cur_state <= next_state;

 end
//-----------------------------------------------------------------
// Next state and output combi logic
// always (*) block
//-----------------------------------------------------------------
   always @ (*)
         case (cur_state)
		 IDLE : begin
			 if (otp_inf_epm_rd_en ) begin 
				 next_state = READ_INF_EPM_TCSCTRLS;
		         end
			 else if (otp_inf_epm_wr_en) begin
			         next_state = WRITE_INF_EPM_TCSCTRLS;
			 end
			 else begin
				 next_state = IDLE;
			 end
                 end
		 READ_INF_EPM_TCSCTRLS : begin			
			         next_state =  READ_INF_EPM_TRPW;
	         end		 
		 READ_INF_EPM_TRPW :begin
			 if(timer_l> otp_tRD-1) begin
		          next_state = READ_INF_EPM_DONE;
	                 end
			 else begin
	                  next_state = READ_INF_EPM_TRPW;
                         end
		 end
                READ_INF_EPM_DONE : begin			
			         next_state =  IDLE;                     
	 
		 end
		 //write fsm
		 WRITE_INF_EPM_TCSCTRLS : begin //wr access
			         next_state =  WRITE_WAIT_VPP_READY;
                 end

		 WRITE_WAIT_VPP_READY : begin //wait vpp to high voltage
		         if(timer_l>otp_tVPP-1) begin      
			         next_state =  WRITE_INF_EPM_TWPW;
			 end
			 else begin
                                 next_state =  WRITE_WAIT_VPP_READY;
			 end				 
                 end
		   		 
		 WRITE_INF_EPM_TWPW : begin//vpp to high voltage,start programming
			 if(timer_l > otp_tPGM-1) begin
			         next_state =  WRITE_BYTE_DONE;
                         end
			 else begin
                                 next_state =  WRITE_INF_EPM_TWPW;
			 end		 
		 end
		 WRITE_BYTE_DONE : begin//one byte finished
			 if(!wr_working) begin//word finished
			         next_state =  WRITE_WORD_DONE;
                         end
			 else if (otp_inf_epm_wr_en) begin
                                 next_state =  WRITE_INF_EPM_TWPW;
			 end	
		         else begin
			         next_state =  WRITE_BYTE_DONE;
		         end	 
		 end

		 WRITE_WORD_DONE : begin //wait vpp to vdd
			 if(timer_l>otp_tVPP-1) begin
			         next_state =  WRITE_INF_EPM_DEC_DONE;
                         end
			 else begin
                                 next_state =  WRITE_WORD_DONE;
			 end		 
		 end		 		 
		 WRITE_INF_EPM_DEC_DONE :  begin
			 if(timer_l > otp_tPGM_rec-1) begin
			         next_state =  IDLE;
                         end
			 else begin
                                 next_state =  WRITE_INF_EPM_DEC_DONE;
			 end		 
		 end
		    
		 default : begin
	                         next_state = IDLE;
		 end
         endcase

//------------------------------------------------------------------------------
//fsm output logic signals
//------------------------------------------------------------------------------
 //OTP VPP control
 assign wr_enter_h_en       = (cur_state == WRITE_INF_EPM_TCSCTRLS) ? 1'b1 : 1'b0;
 assign wr_enter_l_en       = ((cur_state == WRITE_WORD_DONE) & (next_state == WRITE_INF_EPM_DEC_DONE)) ? 1'b1 : 1'b0;
 assign wr_vpp_l_en         = ((cur_state == WRITE_BYTE_DONE) & (next_state == WRITE_WORD_DONE)) ? 1'b1 : 1'b0;

//OTP read control
 assign read_h_en     = ((cur_state != next_state) & ((cur_state == READ_INF_EPM_TCSCTRLS))) ? 1'b1 : 1'b0;
 assign read_l_en     = ((cur_state != next_state) & ((next_state == READ_INF_EPM_DONE))) ? 1'b1 : 1'b0;

//OTP write control
 assign wr_h_en = ((cur_state != next_state) & ((next_state == WRITE_INF_EPM_TWPW))) ? 1'b1 : 1'b0;
 assign wr_l_en = ((cur_state != next_state) & ((next_state == WRITE_BYTE_DONE))) ? 1'b1 : 1'b0;

//otp information/OTP block read/write operation done signal
assign otp_inf_epm_blk_rd_set_en = ((cur_state == READ_INF_EPM_TRPW) && (next_state == READ_INF_EPM_DONE)) ? 1'b1 : 1'b0;
assign otp_inf_epm_blk_wd_set_en = ((cur_state == WRITE_INF_EPM_TWPW) && (next_state == WRITE_BYTE_DONE)) ? 1'b1 : 1'b0;
assign otp_inf_epm_blk_addr_set_en = ((cur_state == READ_INF_EPM_DONE) && (next_state == IDLE)) ? 1'b1 : 1'b0;


endmodule
