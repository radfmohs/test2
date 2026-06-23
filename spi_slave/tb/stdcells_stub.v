//------------------------------------------------------------------------------
// Behavioral simulation stubs for technology standard cells used by the SPI RTL.
//
// These cells normally come from the foundry/standard-cell library and are not
// part of this repository. For simulation we model their function from the cell
// name. CLKINV is a clock inverter, so its output Y is the logical inversion of
// input A.
//------------------------------------------------------------------------------

`timescale 1ns/1ps

module CLKINV_X12_A7TULL (
  output Y,
  input  A
);
  assign Y = ~A;
endmodule
