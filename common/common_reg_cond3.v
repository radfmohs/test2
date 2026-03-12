/////////////////////////////////////////////////////////
////----------------------------------------------------
////-- author: zhen cao
////
////-- module: common_reg_cond3.v
////
////-- discription:there are there conditions for a register signal
////
////-- data:28/10/2024
////
////-- version:0.1
////
////----------------------------------------------------
/////////////////////////////////////////////////////////

module common_reg_cond3 #(
parameter RST_VAL    = 1'b0,
parameter [2:0] COND_VALUE = 3'b000
)(
input  wire [2:0]  cond_in,
input  wire        clk,
input  wire        rst_,
output wire        d_out
); 

reg data_reg;
always @(posedge clk or negedge rst_) begin
	if(~rst_) begin
        data_reg <= RST_VAL;
        end
        else if (cond_in[0])begin
        data_reg <= COND_VALUE[0];
        end
        else if (cond_in[1])begin
        data_reg <= COND_VALUE[1];
        end      
        else if (cond_in[2])begin
        data_reg <= COND_VALUE[2];
        end
end

assign d_out = data_reg;

endmodule

