module cell_clkor2 (
input  wire A,
input  wire B,
output wire Y
);

`ifndef SYNTHESIS
assign Y = A | B ;
`else
//NBL_NR2D1 DNT_CLKOR2 (.A(A), .B(B), .Y(Y));
OR2_X4_A7TULL DNT_CLKOR2 (.A(A), .B(B), .Y(Y));
`endif


endmodule
