module cell_mx16 (
input  wire A,
input  wire B,
input  wire C,
input  wire D,
input  wire E,
input  wire F,
input  wire G,
input  wire H,
input  wire I,
input  wire J,
input  wire K,
input  wire L,
input  wire M,
input  wire N,
input  wire O,
input  wire P,
input  wire S0,
input  wire S1,
input  wire S2,
input  wire S3,
output wire Z
);

`ifndef SYNTHESIS
//assign Z = S1 ? (S0 ? D : C) : (S0 ? B : A);
assign Z =   (S3 ? (S2 ? (S1 ? (S0 ? P : O) : (S0 ? N : M))
                      :  (S1 ? (S0 ? L : K) : (S0 ? J : I))) :
             (S2 ? (S1 ? (S0 ? H : G) : (S0 ? F : E)) : (S1 ? (S0 ? D : C) : S0 ? B : A)));
`else
wire mux000_out;
wire mux001_out;
wire mux010_out;
wire mux011_out;

MX4_X4_A7TULL DNT_MX4_0 (.A(A), .B(B), .C(C), .D(D), .S0(S0), .S1(S1), .Y(mux000_out));

MX4_X4_A7TULL DNT_MX4_1 (.A(E), .B(F), .C(G), .D(H), .S0(S0), .S1(S1), .Y(mux001_out));

MX4_X4_A7TULL DNT_MX4_2 (.A(I), .B(J), .C(K), .D(L), .S0(S0), .S1(S1), .Y(mux010_out));

MX4_X4_A7TULL DNT_MX4_3 (.A(M), .B(N), .C(O), .D(P), .S0(S0), .S1(S1), .Y(mux011_out));

MX4_X4_A7TULL DNT_MX4_5 (.A(mux000_out), .B(mux001_out), .C(mux010_out), .D(mux011_out), .S0(S2), .S1(S3), .Y(Z));

`endif

endmodule
