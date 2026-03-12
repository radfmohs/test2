module cell_clkbuf (
input  wire CK,
output wire CLK
);

`ifndef SYNTHESIS
assign CLK = CK;
`elsif ID16
CLKBUF_X16_A7TULL DNT_CLKBUF (.A(CK), .Y(CLK));
`else
CLKBUF_X4_A7TULL  DNT_CLKBUF (.A(CK), .Y(CLK));
`endif

endmodule
