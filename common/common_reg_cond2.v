/////////////////////////////////////////////////////////
////----------------------------------------------------
////-- author: zhen cao
////
////-- module: common_reg_cond2.v
////
////-- discription:there are two conditions for a register signal
////
////-- data:28/10/2024
////
////-- version:0.1
////
////----------------------------------------------------
/////////////////////////////////////////////////////////

module common_reg_cond2 #(
parameter RST_VAL    = 1'b0,
parameter [1:0] COND_VALUE = 2'b00
)(
input  wire [1:0]  cond_in,
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
end

assign d_out = data_reg;

endmodule

