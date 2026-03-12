module cell_buf (
input  wire A,
output wire Y
);

`ifndef SYNTHESIS
assign Y = A;
`else
BUF_X4_A7TULL DNT_BUF (.A(A), .Y(Y));

`endif

endmodule
