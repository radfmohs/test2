/*--------------------------------------------------------------------------------------*/
/*      Nanochap Confidential                                                           */
/*--------------------------------------------------------------------------------------*/
/* File Name	 : otp_regs.v                                                           */
/* Project	 : ENS1P4 Chip                                                          */
/* Designer	 : zhen                                                                 */
/* Description	 : otp progarm and read controller                                      */
/* Date		 : 1/4/2024                                                             */
/*--------------------------------------------------------------------------------------*/
/* Revision History :                                                                   */    
/* Data         Rev.     By             Description                                     */
/*--------------------------------------------------------------------------------------*/
/* 9/1/2024     1       zhen           otp progarm and read controller                  */
/*--------------------------------------------------------------------------------------*/
module otp_regs 
#(parameter NO_SPI_REGS = 4,
parameter ATM_MDOE    = 5,
parameter ATM_DATA    = 12
)(
	input  wire                rst_n,
	input  wire                clk,
        input  wire                otp_inf_epm_blk_addr_set_en,
	input  wire                otp_inf_epm_blk_rd_set_en,
	input  wire                otp_inf_epm_blk_wd_set_en,
	input  wire                unlock,
        input  wire                spi_wr,
        input  wire                spi_wr_data,
        input  wire                spi_rd_data,
        input  wire [7:0]          spi_otp_addr,
        input  wire [7:0]          spi_otp_data,
        input  wire                atm_unlock,
        input  wire                analog_test_mode_sync,
        input  wire [ATM_MDOE-1:0] atm_mode_sync,
        input  wire [ATM_DATA-1:0] atm_data_sync,
	input  wire [31:0]         otp_dout,
	input  wire [7:0]          spi_regs [NO_SPI_REGS-1:0],
	input  wire [7:0]          def_regs [NO_SPI_REGS-1:0],
	output reg  [7:0]          shadow_regs [NO_SPI_REGS-1:0],
	output reg  [6:0]          otp_addr, //only 16 registers needed in this project
        output reg  [7:0]          spi_data_read,
        output reg  [7:0]          spi_data_to_otp,
        output wire                addr_valid,
        output wire  [6:0]         addr_trim,
	output reg                 otp_en,
	output reg                 otp_inf_epm_rw,
        output reg                 reload_done,
        output reg                 wr_working,
        output reg                 wr_time,
	output reg                 loading_shadows
);

//trim
reg reload_tag;
reg loading_shadows1;
wire loading_shadows_low_pulse;
reg  unlock_dalay1clk,spi_wr_dalay1clk,atm_unlock_dalay1clk;
reg otp_inf_epm_blk_wd_set_en_dalay1clk;
reg  reload_tag_flg_dly1;
wire unlock_neg,spi_wr_neg,atm_unlock_neg;
wire reload_tag_flg_neg;
wire addr_valid_temp;
reg [7:0] otp_data_00;

wire shadow_eq_spi; 
assign shadow_eq_spi  = (shadow_regs[addr_trim]== spi_regs[addr_trim]);
wire reload_tag_flg;
assign reload_tag_flg = (shadow_regs[0] != 8'h5a) && (otp_addr==7'h4) && loading_shadows;
assign loading_shadows_low_pulse = ~addr_valid & loading_shadows1 & ~spi_wr;
assign unlock_neg = ~unlock && unlock_dalay1clk;
assign spi_wr_neg = ~spi_wr && spi_wr_dalay1clk;
assign atm_unlock_neg = ~atm_unlock && atm_unlock_dalay1clk;
assign addr_valid_temp = ((otp_data_00 != 8'h5a) || (analog_test_mode_sync && atm_unlock) )? (otp_addr<=NO_SPI_REGS) : (otp_addr<=NO_SPI_REGS-1);
assign addr_valid = addr_valid_temp || spi_rd_data;
assign addr_trim  = (otp_addr<=NO_SPI_REGS-1)? otp_addr : 7'h00;
assign reload_tag_flg_neg = reload_tag_flg && ~reload_tag_flg_dly1;

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		otp_data_00 <= 8'h00;
	end
        else if (loading_shadows && ~reload_tag_flg && otp_inf_epm_blk_rd_set_en && !(|otp_addr)) begin
		otp_data_00 <= otp_dout[7:0];
        end
end

////
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		loading_shadows1 <= 1'b0;
	end
        else begin
		loading_shadows1 <= addr_valid;
        end
end

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		reload_tag_flg_dly1 <= 1'b0;
	end
        else begin
		reload_tag_flg_dly1 <=  reload_tag_flg;
        end
end


always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
	 unlock_dalay1clk     <= 1'b0;
         spi_wr_dalay1clk     <= 1'b0;
         atm_unlock_dalay1clk <= 1'b0;
         otp_inf_epm_blk_wd_set_en_dalay1clk  <= 1'b0;
	end
        else begin
         unlock_dalay1clk           <= unlock;
         spi_wr_dalay1clk           <= spi_wr;
         atm_unlock_dalay1clk       <= atm_unlock;
         otp_inf_epm_blk_wd_set_en_dalay1clk  <= otp_inf_epm_blk_wd_set_en;

        end
end
//

////random spi read write////
reg rd_time;
reg spi_rd_data_dly1,spi_wr_data_dly1;

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		spi_rd_data_dly1 <= 1'b0;
		spi_wr_data_dly1 <= 1'b0;
	end
        else begin
		spi_rd_data_dly1 <=  spi_rd_data;
		spi_wr_data_dly1 <=  spi_wr_data;
        end
end

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		rd_time <= 1'b0;
	end
        else if(spi_rd_data && !spi_rd_data_dly1) begin
		rd_time <= 1'b1;

        end
        else if(otp_inf_epm_blk_addr_set_en) begin
		rd_time <= 1'b0;
        end
end

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		wr_time <= 1'b0;
	end
        else if(otp_inf_epm_blk_wd_set_en) begin
		wr_time <= 1'b0;
        end
        else if(!spi_wr_data && spi_wr_data_dly1) begin
		wr_time <= 1'b0;
        end
        else if(spi_wr_data && !spi_wr_data_dly1) begin
		wr_time <= 1'b1;

        end
end

integer i;
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
                for(i=0;i<NO_SPI_REGS;i=i+1)begin
		shadow_regs[i] <= def_regs[i];
                end
		loading_shadows <= 1'b1;
		otp_addr <= 0;
		otp_en <= 0;
		otp_inf_epm_rw <= 0;
                reload_done <= 1'b0;
                wr_working  <= 1'b0;
                spi_data_read <= 8'h00;
                spi_data_to_otp <= 8'h00;

	end
	else begin		
                if (loading_shadows_low_pulse && (!spi_wr_data && !rd_time))begin
                        otp_addr <= 0;
		        otp_en <= 0;
		        loading_shadows <= 0;
                        reload_done <= 1'b1;					
                end
                else if (reload_tag_flg_neg)begin
                        otp_addr <= 0;
		        otp_en <= 0;
		        loading_shadows <= 0;
                        reload_done <= 1'b0;					
                end
		else if (loading_shadows) begin //Reading from OTP at reset time
			otp_en <= 1'b1;			
                        if (~reload_tag_flg)begin
		        	if(otp_inf_epm_blk_rd_set_en) begin
				      shadow_regs[otp_addr]   <= otp_dout[7:0];
				      shadow_regs[otp_addr+1] <= otp_dout[15:8];
				      shadow_regs[otp_addr+2] <= otp_dout[23:16];
				      shadow_regs[otp_addr+3] <= otp_dout[31:24];
                                end
                                else if (otp_inf_epm_blk_addr_set_en) begin
				         if (otp_addr<=NO_SPI_REGS-1) begin
					        otp_addr <= otp_addr + 4;
                                         end
                                end
                            
                         end		
		end
                else if(spi_rd_data) begin
                       if(rd_time) begin
                            if(otp_inf_epm_blk_addr_set_en)begin
                             otp_addr <= 7'b0;
		             otp_en   <= 1'b0;
                            end
                            else begin	
			     otp_en   <= 1'b1;
                             otp_addr <= spi_otp_addr[6:0];
                                 if      (spi_otp_addr[1:0]==2'b00)                                  
                                    spi_data_read <= otp_dout[7:0];
                                 else if (spi_otp_addr[1:0]==2'b01)
                                    spi_data_read <= otp_dout[15:8];
                                 else if (spi_otp_addr[1:0]==2'b10)
                                    spi_data_read <= otp_dout[23:16];
                                 else if (spi_otp_addr[1:0]==2'b11)
                                    spi_data_read <= otp_dout[31:24];
                            end
                      end
                end
                else if(spi_wr_data) begin	
                       if(wr_time) begin
                            if(otp_inf_epm_blk_wd_set_en)begin
		             otp_en   <= 1'b0;
		             otp_inf_epm_rw <= 1'b0;
                             wr_working  <= 1'b0;
                            end
                            else begin	
                             wr_working  <= 1'b1;
			     otp_en   <= 1'b1;
		             otp_inf_epm_rw <= 1'b1;
                             otp_addr <= spi_otp_addr[6:0];
                             spi_data_to_otp <= spi_otp_data;
                            end
                       end
                       else begin
		             otp_en   <= 1'b0;
		             otp_inf_epm_rw <= 1'b0;
                             wr_working  <= 1'b0;
                       end

                end
                else if(spi_wr) begin			            
				if (otp_addr<NO_SPI_REGS) begin
			                if (shadow_eq_spi) begin
					otp_addr <= otp_addr + 1;   
                                        end
                                        else begin
			         	shadow_regs[otp_addr]<=spi_regs[otp_addr];
                                        otp_addr <= otp_addr + 1;  
                                        end
                                end
                end
 		else if (analog_test_mode_sync) begin //ATM programming
                         if (atm_unlock) begin
		        	if (otp_addr<NO_SPI_REGS) begin
                                    if(otp_inf_epm_blk_wd_set_en_dalay1clk) begin
		    	              otp_addr <= otp_addr + 1'b1;
                                    end
		    	            else if (!otp_inf_epm_rw) begin
		    		      otp_en <= 1'b1;
		    		      otp_inf_epm_rw <= 1'b1;
                                      wr_working  <= 1'b1;
		                    end
		    	            else if (otp_inf_epm_blk_wd_set_en) begin
		    		      otp_inf_epm_rw <= 1'b0;
		    	              otp_addr <= otp_addr;
		    		      otp_en <= 0;
		    	            end
                               end
			       else begin
				otp_en <= 0;
                                wr_working  <= 1'b0;
		               end
                        end
                        else if(|atm_mode_sync) begin
                              shadow_regs[0] <= 8'h5a;
                             if(atm_mode_sync[0])
                              shadow_regs[4] <= atm_data_sync;
                             else if(atm_mode_sync[1])
                              shadow_regs[5] <= atm_data_sync;
                             else if(atm_mode_sync[2])
                              shadow_regs[6] <= atm_data_sync;
                             else if(atm_mode_sync[3])
                              shadow_regs[7] <= atm_data_sync;
                             else if(atm_mode_sync[4])
                              shadow_regs[8] <= atm_data_sync;
                             else if(atm_mode_sync[5])
                              shadow_regs[9] <= atm_data_sync;
                             else if(atm_mode_sync[6])
                              shadow_regs[10] <= atm_data_sync;
                             else if(atm_mode_sync[7])
                              shadow_regs[11] <= atm_data_sync;
                        end
		end               
		else if (unlock) begin //Programming OTP
                       if (otp_data_00 != 8'h5a) begin
		        	if (otp_addr<NO_SPI_REGS) begin
                                    if(otp_inf_epm_blk_wd_set_en_dalay1clk) begin
		    	              otp_addr <= otp_addr + 1'b1;
                                    end
		    	            else if (!otp_inf_epm_rw) begin
		    		      otp_en <= 1'b1;
		    		      otp_inf_epm_rw <= 1'b1;
                                      wr_working  <= 1'b1;
		                    end
		    	            else if (otp_inf_epm_blk_wd_set_en) begin
		    		      otp_inf_epm_rw <= 1'b0;
		    	              otp_addr <= otp_addr;
		    		      otp_en <= 0;
		    	            end
                               end
			       else begin
				otp_en <= 0;
                                wr_working  <= 1'b0;
		               end
                        end
			else begin
                           if (shadow_eq_spi)                         
				if (otp_addr<NO_SPI_REGS-1) begin
					otp_addr <= otp_addr + 1;
                                        wr_working  <= 1'b1;
                                end
				else begin
//					otp_addr <= 0;
					otp_en <= 0;
                                        wr_working  <= 1'b0;
				end

		           else if (!otp_inf_epm_rw & !shadow_eq_spi) begin
				otp_en <= 1'b1;
				otp_inf_epm_rw <= 1'b1;
                                wr_working  <= 1'b1;
			   end
			   else if (otp_inf_epm_blk_wd_set_en & !shadow_eq_spi) begin
				otp_inf_epm_rw <= 1'b0;
				shadow_regs[otp_addr]<=spi_regs[otp_addr];
				otp_addr <= otp_addr;
				otp_en <= 0;
			   end
                        end
		end
                else if (unlock_neg || spi_wr_neg || atm_unlock_neg || (!spi_wr_data && spi_wr_data_dly1)) begin
                         	otp_addr <= 0;   
		                otp_en   <= 1'b0;
		                otp_inf_epm_rw <= 1'b0;
                                wr_working  <= 1'b0;           
           
                end
	end
end

	
endmodule
