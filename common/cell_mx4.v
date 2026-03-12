module cell_mx4 (
input  wire A,
input  wire B,
input  wire C,
input  wire D,
input  wire S0,
input  wire S1,
output wire Z
);

`ifndef SYNTHESIS
assign Z = S1 ? (S0 ? D : C) : (S0 ? B : A);
`else
MX4_X4_A7TULL DNT_MX4 (.A(A), .B(B), .C(C), .D(D), .S0(S0), .S1(S1), .Y(Z));
`endif

endmodule
