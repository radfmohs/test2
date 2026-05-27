// Stub definitions for technology cell library primitives
// Used in simulation with iverilog

// BUF_X8_A7TULL  - large buffer, used e.g. scan_mode in pinmux.sv
module BUF_X8_A7TULL (input wire A, output wire Y);
  assign Y = A;
endmodule

// BUF_X2_A7TULL - buffer x2
module BUF_X2_A7TULL (input wire A, output wire Y);
  assign Y = A;
endmodule

// AND2_X1_A7TULL - 2-input AND
module AND2_X1_A7TULL (input wire A, input wire B, output wire Y);
  assign Y = A & B;
endmodule

// MX2_X8_A7TULL - 2:1 mux, S0=0 -> A, S0=1 -> B
module MX2_X8_A7TULL (input wire A, input wire B, input wire S0, output wire Y);
  assign Y = S0 ? B : A;
endmodule

// INV_X1_A7TULL - inverter
module INV_X1_A7TULL (input wire A, output wire Y);
  assign Y = ~A;
endmodule
