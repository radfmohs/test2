module cell_clkmx2 (
input  wire A,
input  wire B,
input  wire S0,
output wire Y
);

`ifndef SYNTHESIS
assign Y = S0 ? B : A;
`else
CLKMX2_X4_A7TULL DNT_CLKMX2 (.A(A), .B(B), .S0(S0), .Y(Y));
`endif

endmodule
