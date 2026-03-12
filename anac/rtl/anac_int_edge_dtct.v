//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap Glucose Chip   
// File name:    anac_int_edge_dtct.v 
// Module Name : anac_int_edge_dtct
// Description : 
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author          Description      
//------------------------------------------------------------------------------
// 0.1                                      Initial Rev 
//------------------------------------------------------------------------------

module anac_int_edge_dtct(
input wire sysclk,	
input wire presetn,
input wire scan_mode,

input wire A2D_COMP,	

input wire ana_comp_ch_intr_en,
input wire ana_comp_ch_intr_trans_sel,
input wire ana_comp_ch_intr_sts_clr,
	
output wire o_ana_comp_ch_intr_sts,	
output wire o_ana_comp_ch_intr_pin
	
	
);

reg  A2D_COMP_d1;
wire A2D_COMP_sync;
wire A2D_COMP_falling_edge;
wire A2D_COMP_raising_edge;
wire ana_comp_ch_intr_sts_clr_sync;
wire ana_comp_ch_intr_trans_sel_sync;
wire ana_comp_ch_intr_en_sync;
reg  ana_comp_ch_intr_sts_clr_sync_d1;
reg  ana_comp_ch_intr_sts_clr_sync_d2;
reg  ana_comp_ch_intr_sts_clr_sync_d3;
wire ana_comp_ch_intr_sts_clr_sync_pulse;
reg  ana_comp_ch_intr_sts;

//sync the A2D_COMP1
common_sync_bit u_A2D_COMP_sync(
       .clk(sysclk),
       .rst_(presetn),
       .async_in(A2D_COMP),
       .sync_out(A2D_COMP_sync)
);

always @(posedge sysclk or negedge presetn) begin
  if (~presetn) 
    A2D_COMP_d1<=1'b0;
   else  
    A2D_COMP_d1 <= A2D_COMP_sync;
  end

assign A2D_COMP_raising_edge =   A2D_COMP_sync & !A2D_COMP_d1;
assign A2D_COMP_falling_edge =   !A2D_COMP_sync && A2D_COMP_d1;


///Interrupt


//sync the Ana_comp_ch_intr_sts  & intr_en (from spi)
wire ana_comp_ch_intr_sts_clr_sync_tmp;
common_rst_sync u_ana_comp_ch_intr_sts_sync(
.RSTINn    (presetn),
.RSTREQ    (ana_comp_ch_intr_sts_clr),
.CLK       (sysclk),
.SE        (1'b0),
.RSTBYPASS (scan_mode),  //tri change to fix dft issue
.RSTOUTn   (ana_comp_ch_intr_sts_clr_sync_tmp)
);

assign ana_comp_ch_intr_sts_clr_sync = scan_mode ? ana_comp_ch_intr_sts : ana_comp_ch_intr_sts_clr_sync_tmp;

common_sync_bit u_ana_comp_ch_intr_trans_sel_sync(
       .clk(sysclk),
       .rst_(presetn),
       .async_in(ana_comp_ch_intr_trans_sel),
       .sync_out(ana_comp_ch_intr_trans_sel_sync)
);

common_sync_bit u_ana_comp_ch_intr_en_sync(
       .clk(sysclk),
       .rst_(presetn),
       .async_in(ana_comp_ch_intr_en),
       .sync_out(ana_comp_ch_intr_en_sync)
);

//analog_comp_ch_interrupt_clear_sync_pulse generation
always @ (posedge sysclk or negedge presetn) begin
  if (~presetn) begin
    ana_comp_ch_intr_sts_clr_sync_d1<=1'b0; 
    ana_comp_ch_intr_sts_clr_sync_d2<=1'b0; 
    ana_comp_ch_intr_sts_clr_sync_d3<=1'b0; 
  end
  else begin
   ana_comp_ch_intr_sts_clr_sync_d1 <= ana_comp_ch_intr_sts_clr_sync;
   ana_comp_ch_intr_sts_clr_sync_d2 <= ana_comp_ch_intr_sts_clr_sync_d1;
   ana_comp_ch_intr_sts_clr_sync_d3 <= ana_comp_ch_intr_sts_clr_sync_d2;
 end
end


assign ana_comp_ch_intr_sts_clr_sync_pulse = ana_comp_ch_intr_sts_clr_sync_d2 & (~ana_comp_ch_intr_sts_clr_sync_d3);


always @ (posedge sysclk or negedge presetn) begin
  if (~presetn) begin
    ana_comp_ch_intr_sts <= 1'b0;
  end else if(ana_comp_ch_intr_sts_clr_sync_pulse) begin
     ana_comp_ch_intr_sts <= 1'b0;     
  end else if( (A2D_COMP_raising_edge && (!ana_comp_ch_intr_trans_sel_sync)) | (A2D_COMP_falling_edge && ana_comp_ch_intr_trans_sel_sync )) begin
     ana_comp_ch_intr_sts <= 1'b1;
  end else begin
     ana_comp_ch_intr_sts <= ana_comp_ch_intr_sts;
  end 
end

assign o_ana_comp_ch_intr_sts =  ana_comp_ch_intr_sts;  // goes to spi_reg
assign o_ana_comp_ch_intr_pin = ana_comp_ch_intr_en_sync & ana_comp_ch_intr_sts;  // goes to pinmux


endmodule

