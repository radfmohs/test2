module cell_mx2 (
input  wire A,
input  wire B,
input  wire S,
output wire Z
);

`ifndef SYNTHESIS
assign Z = S ? B : A;
`else
MX2_X4_A7TULL DNT_MX2 (.A(A), .B(B), .S0(S), .Y(Z));
`endif

endmodule
