/*--------------------------------------------------------------------------------------*/
/*      Nanochap Confidential                                                           */
/*--------------------------------------------------------------------------------------*/
/* File Name	 : otp_clkcnt.v                                                         */
/* Project	 : ENS1P4 Chip                                                          */
/* Designer	 : zhen                                                                 */
/* Description	 : otp progarm and read timing                                          */
/* Date		 : 1/4/2024                                                             */
/*--------------------------------------------------------------------------------------*/
/* Revision History :                                                                   */    
/* Data         Rev.     By             Description                                     */
/*--------------------------------------------------------------------------------------*/
/* 9/1/2024     1       zhen           otp progarm and read timing                      */
/*--------------------------------------------------------------------------------------*/


module otp_clkcnt(

input wire [2:0] hosc_sel,

//read
output reg [12:0] otp_tRD,    //min: 600ns

//write
output reg [12:0] otp_tPGM,  //min : 1ms typ: 1.1ms max 1.2ms
output reg [12:0] otp_tVPP,
output reg [12:0] otp_tPGM_rec


);


always@(*) begin
	case(hosc_sel)    
		3'b000 : begin//8m
                      otp_tRD        = 13'd1;                                       
		      otp_tPGM       = 13'd2700;  
		      otp_tVPP       = 13'd200;		      
		      otp_tPGM_rec   = 13'd96;
			
		end
	   
		3'b001 : begin//4m
                      otp_tRD        = 13'd1;                                       
		      otp_tPGM       = 13'd1350;
		      otp_tVPP       = 13'd100;		      
		      otp_tPGM_rec   = 13'd48;
			
		end



		3'b010 : begin//2m
                      otp_tRD        = 13'd1;                                       
		      otp_tPGM       = 13'd665;  
		      otp_tVPP       = 13'd50;		      
		      otp_tPGM_rec   = 13'd24;
			
		end
	   
		3'b011 : begin//1m
                      otp_tRD        = 13'd1;                                       
		      otp_tPGM       = 13'd333;
		      otp_tVPP       = 13'd50;		      
		      otp_tPGM_rec   = 13'd12;
			
		end
	   
		3'b100 : begin//500k
                      otp_tRD        = 13'd1;                                       
		      otp_tPGM       = 13'd165;
		      otp_tVPP       = 13'd50;		      
		      otp_tPGM_rec   = 13'd6;
			
		end
	   
		3'b101 : begin//250k
                      otp_tRD        = 13'd1;                                       
		      otp_tPGM       = 13'd82; 
		      otp_tVPP       = 13'd50;		      
		      otp_tPGM_rec   = 13'd3;
			
		end
		3'b110 : begin//125k
                      otp_tRD        = 13'd1;                                       
		      otp_tPGM       = 13'd41; 
		      otp_tVPP       = 13'd50;		      
		      otp_tPGM_rec   = 13'd2;
			
		end
		3'b111 : begin//62.5k
                      otp_tRD        = 13'd1;                                       
		      otp_tPGM       = 13'd20; 
		      otp_tVPP       = 13'd25;		      
		      otp_tPGM_rec   = 13'd1;
			
		end
		default : begin
                      otp_tRD        = 13'd1;                                       
		      otp_tPGM       = 13'd665;  
		      otp_tVPP       = 13'd50;		      
		      otp_tPGM_rec   = 13'd24;			
		end
	   	 
        endcase
end
endmodule
