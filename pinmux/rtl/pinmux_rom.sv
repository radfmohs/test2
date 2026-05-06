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
  output wire [7:0] CONFIG_ROM0 [28:0],  
  output wire [7:0] CONFIG_ROM1 [28:0],  
  output wire [7:0] CONFIG_ROM2 [28:0],
  output wire [7:0] CONFIG_ROM3 [28:0],
  output wire [7:0] CONFIG_ROM4 [28:0],
  output wire [7:0] CONFIG_ROM5 [28:0],
  output wire [7:0] CONFIG_ROM6 [28:0],
  output wire [7:0] CONFIG_ROM7 [28:0],
  output wire [7:0] CONFIG_ROM8 [28:0],
  output wire [7:0] CONFIG_ROM9 [28:0],
  output wire [7:0] CONFIG_ROM10 [28:0],
  output wire [7:0] CONFIG_ROM11 [28:0],
  output wire [7:0] CONFIG_ROM12 [28:0],
  output wire [7:0] CONFIG_ROM13 [28:0],
  output wire [7:0] CONFIG_ROM14 [28:0],
  output wire [7:0] CONFIG_ROM15 [28:0],
  output wire [7:0] CONFIG_ROM16 [28:0],
  output wire [7:0] CONFIG_ROM17 [28:0],
  output wire [7:0] CONFIG_ROM18 [28:0],
  output wire [7:0] CONFIG_ROM19 [28:0]
);

`include "param_pinmux.vh"

wire  init_enable;
assign init_enable = 1'b1;

genvar i;
generate
  for (i = 0; i < 29; i = i + 1) begin
    assign CONFIG_ROM0[i]  = init_enable ? CONFIG0[7+(8*i):8*i] : {8{1'bz}};
    assign CONFIG_ROM1[i]  = init_enable ? CONFIG1[7+(8*i):8*i] : {8{1'bz}};
    assign CONFIG_ROM2[i]  = init_enable ? CONFIG2[7+(8*i):8*i] : {8{1'bz}};
    assign CONFIG_ROM3[i]  = init_enable ? CONFIG3[7+(8*i):8*i] : {8{1'bz}};
    assign CONFIG_ROM4[i]  = init_enable ? CONFIG4[7+(8*i):8*i] : {8{1'bz}};
    assign CONFIG_ROM5[i]  = init_enable ? CONFIG5[7+(8*i):8*i] : {8{1'bz}};
    assign CONFIG_ROM6[i]  = init_enable ? CONFIG6[7+(8*i):8*i] : {8{1'bz}};
    assign CONFIG_ROM7[i]  = init_enable ? CONFIG7[7+(8*i):8*i] : {8{1'bz}};
    assign CONFIG_ROM8[i]  = init_enable ? CONFIG8[7+(8*i):8*i] : {8{1'bz}};
    assign CONFIG_ROM9[i]  = init_enable ? CONFIG9[7+(8*i):8*i] : {8{1'bz}};
    assign CONFIG_ROM10[i] = init_enable ? CONFIG10[7+(8*i):8*i] : {8{1'bz}};
    assign CONFIG_ROM11[i] = init_enable ? CONFIG11[7+(8*i):8*i] : {8{1'bz}};
    assign CONFIG_ROM12[i] = init_enable ? CONFIG12[7+(8*i):8*i] : {8{1'bz}};
    assign CONFIG_ROM13[i] = init_enable ? CONFIG13[7+(8*i):8*i] : {8{1'bz}};
    assign CONFIG_ROM14[i] = init_enable ? CONFIG14[7+(8*i):8*i] : {8{1'bz}};
    assign CONFIG_ROM15[i] = init_enable ? CONFIG15[7+(8*i):8*i] : {8{1'bz}};
    assign CONFIG_ROM16[i] = init_enable ? CONFIG16[7+(8*i):8*i] : {8{1'bz}};
    assign CONFIG_ROM17[i] = init_enable ? CONFIG17[7+(8*i):8*i] : {8{1'bz}};
    assign CONFIG_ROM18[i] = init_enable ? CONFIG18[7+(8*i):8*i] : {8{1'bz}};
    assign CONFIG_ROM19[i] = init_enable ? CONFIG19[7+(8*i):8*i] : {8{1'bz}};

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
