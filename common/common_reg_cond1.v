/////////////////////////////////////////////////////////
////----------------------------------------------------
////-- author: zhen cao
////
////-- module: common_reg_cond1.v
////
////-- discription:there is one conditions for a register signal
////
////-- data:28/10/2024
////
////-- version:0.1
////
////----------------------------------------------------
/////////////////////////////////////////////////////////

module common_reg_cond1 #(
parameter RST_VAL    = 1'b0,
parameter COND_VALUE = 1'b0
)(
input  wire        cond_in,
input  wire        clk,
input  wire        rst_,
output wire        d_out
); 

reg data_reg;
always @(posedge clk or negedge rst_) begin
	if(~rst_) begin
        data_reg <= RST_VAL;
        end
        else if (cond_in)begin
        data_reg <= COND_VALUE[0];
        end
end

assign d_out = data_reg;

endmodule

