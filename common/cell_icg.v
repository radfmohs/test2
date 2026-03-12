module cell_icg (
input  wire CK,
input  wire E,
input  wire SE,
output wire ECK 
);

`ifdef FPGA
BUFGCE u_icg (
.O(ECK),
.CE(E),
.I(CK)
);
`elsif BEHAVIORAL
reg    CLKEN;
always @ (E or SE or CK) begin
    if (~CK) 
        CLKEN = E | SE;
end
assign ECK = CLKEN & CK;
`else
TLATNTSCA_X8_A7TULL u_icg (
.CK   (CK),
.E    (E),
.SE   (SE),
.ECK  (ECK)
);
`endif

endmodule
