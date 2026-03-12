//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap ENS2  
// File name:    pinmux_rom.v
// Module Name : pinmux_rom
// Description : 
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author          Description      
//------------------------------------------------------------------------------
// 0.1                                      Initial Rev 
//------------------------------------------------------------------------------

module pinmux_rom (
  output wire [7:0] CONFIG_ROM0 [7:0],  
  output wire [7:0] CONFIG_ROM1 [7:0],  
  output wire [7:0] CONFIG_ROM2 [7:0],  
  output wire [7:0] CONFIG_ROM3 [7:0]   
);

`include "param_pinmux.vh"

wire  init_enable;
assign init_enable = 1'b1;

genvar i;
generate
  for (i = 0; i < 8; i = i + 1) begin
    assign CONFIG_ROM0[i] = init_enable ? CONFIG0[7+(8*i):8*i] : {8{1'bz}};
    assign CONFIG_ROM1[i] = init_enable ? CONFIG1[7+(8*i):8*i] : {8{1'bz}};
    assign CONFIG_ROM2[i] = init_enable ? CONFIG2[7+(8*i):8*i] : {8{1'bz}};
    assign CONFIG_ROM3[i] = init_enable ? CONFIG3[7+(8*i):8*i] : {8{1'bz}};
  end
endgenerate


// genvar i;
// generate
//   for (i = 0; i < 9; i = i + 1) begin
//     assign CONFIG_ROM0[i] = init_enable ? CONFIG0[i] : {8{1'bz}};
//     assign CONFIG_ROM1[i] = init_enable ? CONFIG1[i] : {8{1'bz}};
//     assign CONFIG_ROM2[i] = init_enable ? CONFIG2[i] : {8{1'bz}};
//     assign CONFIG_ROM3[i] = init_enable ? CONFIG3[i] : {8{1'bz}};
//   end
// endgenerate

endmodule
