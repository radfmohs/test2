//------------------------------------------------------------------------------
// Nanochap Pty Ltd (c) 2021
//------------------------------------------------------------------------------
// Project name: Nanochap ENS2  
// File name:    pinmux_1bit.v
// Module Name : pinmux_1bit
// Description : 
//------------------------------------------------------------------------------
// Revision History
//------------------------------------------------------------------------------
// Revision     Date        Author          Description      
//------------------------------------------------------------------------------
// 0.1         16/04/2021  Daniel           Initial Rev 
//------------------------------------------------------------------------------

module pinmux_1bit (
// test and alternate select
// input  wire [1:0]   altf_sel,			
input  wire [4:0]   test_sel,			
input  wire         test_en,
input  wire         test0_en,
input  wire         test1_en,
input  wire         test2_en,
input  wire         test3_en,
input  wire         test4_en,
input  wire         test5_en,
input  wire         test6_en,
input  wire         test7_en,
input  wire         test8_en,
input  wire         test9_en,
// input  wire      test10_en,
input  wire	    test_ana,			//added by supriya
// alternate function
/*
// altf0
input  wire         altf0_ie,
input  wire         altf0_oe,
input  wire         altf0_a,
input  wire         altf0_def,
output wire         altf0_y,
// altf1
input  wire         altf1_ie,
input  wire         altf1_oe,
input  wire         altf1_a,
input  wire         altf1_def,
output wire         altf1_y,
// altf2
input  wire         altf2_ie,
input  wire         altf2_oe,
input  wire         altf2_a,
input  wire         altf2_def,
output wire         altf2_y,
// altf3
input  wire         altf3_ie,
input  wire         altf3_oe,
input  wire         altf3_a,
input  wire         altf3_def,
output wire         altf3_y,
*/
input  wire         altf_ie,
input  wire         altf_oe,
input  wire         altf_a,
input  wire         altf_def,
output wire         altf_y,

// test mode function
// test0
input  wire         test0_ie,
input  wire         test0_oe,
input  wire         test0_a,
input  wire         test0_def,
output wire         test0_y,
// test1
input  wire         test1_ie,
input  wire         test1_oe,
input  wire         test1_a,
input  wire         test1_def,
output wire         test1_y,
// test2
input  wire         test2_ie,
input  wire         test2_oe,
input  wire         test2_a,
input  wire         test2_def,
output wire         test2_y,
// test3
input  wire         test3_ie,   
input  wire         test3_oe,   
input  wire         test3_a,    
input  wire         test3_def, 
output wire         test3_y,    
/// test4
input  wire         test4_ie,   
input  wire         test4_oe,   
input  wire         test4_a,   
input  wire         test4_def,  
output wire         test4_y,    
/// test5
input  wire         test5_ie,   
input  wire         test5_oe,   
input  wire         test5_a,    
input  wire         test5_def,  
output wire         test5_y,    
/// test6
input  wire         test6_ie,   
input  wire         test6_oe,   
input  wire         test6_a,    
input  wire         test6_def,  
output wire         test6_y,   
/// test7
input  wire         test7_ie,   
input  wire         test7_oe,   
input  wire         test7_a,    
input  wire         test7_def,  
output wire         test7_y,  
/// test8
input  wire         test8_ie,   
input  wire         test8_oe,   
input  wire         test8_a,    
input  wire         test8_def,  
output wire         test8_y,    
/// test9
input  wire         test9_ie,   
input  wire         test9_oe,   
input  wire         test9_a,    
input  wire         test9_def, 
output wire         test9_y,    
/// test10
// input  wire      test10_ie,   
// input  wire      test10_oe,   
// input  wire      test10_a,    
// input  wire      test10_def,  
// output wire      test10_y,    
//end
// analog enable
//output wire       analog_en,
//output wire [1:0] analog_en,

// with pad interface
input  wire         iopad_gpio_y,
output wire         iopad_gpio_ie,
output wire         iopad_gpio_oe,
output wire         iopad_gpio_a
);

// parameter ALTF0_CLKIN = 0;
// parameter ALTF1_CLKIN = 0;
// parameter ALTF2_CLKIN = 0;
// parameter ALTF3_CLKIN = 0;
parameter ALTF_CLKIN  = 0;
parameter TEST0_CLKIN = 0;		
parameter TEST1_CLKIN = 0;	
parameter TEST2_CLKIN = 0;
parameter TEST3_CLKIN = 0; 
parameter TEST4_CLKIN = 0; 
parameter TEST5_CLKIN = 0; 
parameter TEST6_CLKIN = 0; 
parameter TEST7_CLKIN = 0; 
parameter TEST8_CLKIN = 0; 
parameter TEST9_CLKIN = 0; 
// parameter TEST10_CLKIN = 0;

// wire altf0_en;
// wire altf1_en;
// wire altf2_en;
// wire altf3_en;
wire altf_en;

wire test_mux_ie;
wire test_mux_oe;
wire test_mux_a;

wire altf_mux_ie;
wire altf_mux_oe;
wire altf_mux_a;

wire clk_bufin;
wire data_bufin;

// wire altf0_bufin;
// wire altf1_bufin;
// wire altf2_bufin;
// wire altf3_bufin;
wire altf_bufin;

wire test0_bufin;
wire test1_bufin;
wire test2_bufin;
wire test3_bufin;
wire test4_bufin;
wire test5_bufin;
wire test6_bufin;
wire test7_bufin;
wire test8_bufin;
wire test9_bufin;
// wire test10_bufin;

wire testmode_en;
wire testmode_ie;
wire testmode_oe;
wire testmode_a;

//modified by supriya
//0:  digital function considered
//1:  analog function considered
//assign altf0_en = test_en ? 1'b1 : altf_sel;
/*
assign altf0_en = (altf_sel ==2'b00) & ~test_en;
assign altf1_en = (altf_sel ==2'b01) & ~test_en;
assign altf2_en = (altf_sel ==2'b10) & ~test_en;
assign altf3_en = (altf_sel ==2'b11) & ~test_en;
*/
assign altf_en = ~test_en ? 1'b1 : 1'b0;

/*
assign altf0_bufin = ALTF0_CLKIN ? clk_bufin : data_bufin;
assign altf1_bufin = ALTF1_CLKIN ? clk_bufin : data_bufin;
assign altf2_bufin = ALTF2_CLKIN ? clk_bufin : data_bufin;
assign altf3_bufin = ALTF3_CLKIN ? clk_bufin : data_bufin;
*/
assign altf_bufin  = ALTF_CLKIN ? clk_bufin : data_bufin;

assign test0_bufin = TEST0_CLKIN ? clk_bufin : data_bufin;
assign test1_bufin = TEST1_CLKIN ? clk_bufin : data_bufin;
assign test2_bufin = TEST2_CLKIN ? clk_bufin : data_bufin;
assign test3_bufin = TEST3_CLKIN ? clk_bufin : data_bufin;
assign test4_bufin = TEST4_CLKIN ? clk_bufin : data_bufin;
assign test5_bufin = TEST5_CLKIN ? clk_bufin : data_bufin;
assign test6_bufin = TEST6_CLKIN ? clk_bufin : data_bufin;
assign test7_bufin = TEST7_CLKIN ? clk_bufin : data_bufin;
assign test8_bufin = TEST8_CLKIN ? clk_bufin : data_bufin;
assign test9_bufin = TEST9_CLKIN ? clk_bufin : data_bufin;
// assign test10_bufin = TEST10_CLKIN ? clk_bufin : data_bufin;

cell_mx16 u_test_ie (.Z(test_mux_ie), .A(test0_ie), .B(test1_ie), .C(test2_ie), .D(test3_ie), .E(test4_ie), .F(test5_ie),  .G(test6_ie),  .H(test7_ie),  .I(test8_ie),
     				     .J(test9_ie),  .K(1'b0),  .L(1'b0),  .M(1'b0),  .N(1'b0),  .O(1'b0),  .P(1'b0),
		   		     .S0(test_sel[0]), .S1(test_sel[1]), .S2(test_sel[2]), .S3(test_sel[3]));

cell_mx16 u_test_oe (.Z(test_mux_oe), .A(test0_oe), .B(test1_oe), .C(test2_oe), .D(test3_oe), .E(test4_oe), .F(test5_oe),  .G(test6_oe),  .H(test7_oe),  .I(test8_oe),    
 				     .J(test9_oe),  .K(1'b0), .L(1'b0),     .M(1'b0),      .N(1'b0),    .O(1'b0),      .P(1'b0),
				     .S0(test_sel[0]), .S1(test_sel[1]), .S2(test_sel[2]), .S3(test_sel[3]));

cell_mx16 u_test_a  (.Z(test_mux_a),  .A(test0_a),  .B(test1_a),  .C(test2_a),  .D(test3_a),  .E(test4_a),  .F(test5_a),   .G(test6_a),   .H(test7_a),   .I(test8_a),  
    				      .J(test9_a),  .K(1'b0), .L(1'b0),     .M(1'b0),      .N(1'b0),    .O(1'b0),      .P(1'b0),
				      .S0(test_sel[0]), .S1(test_sel[1]), .S2(test_sel[2]), .S3(test_sel[3]));

//cell_mx4 u_test_ie (.Z(test_mux_ie), .A(1'b0), .B(test0_ie), .C(test1_ie), .D(test2_ie), .S0(test_sel[0]), .S1(test_sel[1]));
//cell_mx4 u_test_oe (.Z(test_mux_oe), .A(1'b0), .B(test0_oe), .C(test1_oe), .D(test2_oe), .S0(test_sel[0]), .S1(test_sel[1]));
//cell_mx4 u_test_a  (.Z(test_mux_a),  .A(1'b0), .B(test0_a),  .C(test1_a),  .D(test2_a),  .S0(test_sel[0]), .S1(test_sel[1]));
//cell_mx2 u_test_ie (.Z(test_mux_ie), .A(1'b0), .B(testmode_ie), .S0(testmode_en));
//cell_mx2 u_test_oe (.Z(test_mux_oe), .A(1'b0), .B(testmode_oe), .S0(testmode_en));
//cell_mx2 u_test_a  (.Z(test_mux_a),  .A(1'b0), .B(testmode_a),  .S0(testmode_en));

//modified by supriya
//cell_mx2 u_altf_ie (.Z(altf_mux_ie), .A(altf0_ie), .B(1'b0), .S(altf0_en));
//cell_mx2 u_altf_oe (.Z(altf_mux_oe), .A(altf0_oe), .B(1'b0), .S(altf0_en));
//cell_mx2 u_altf_a  (.Z(altf_mux_a),  .A(altf0_a),  .B(1'b0), .S(altf0_en));
//cell_mx4 u_altf_ie (.Z(altf_mux_ie), .A(altf0_ie), .B(altf1_ie), .C(altf2_ie), .D(altf3_ie), .S0(altf_sel[0]), .S1(altf_sel[1]));
//cell_mx4 u_altf_oe (.Z(altf_mux_oe), .A(altf0_oe), .B(altf1_oe), .C(altf2_oe), .D(altf3_oe), .S0(altf_sel[0]), .S1(altf_sel[1]));
//cell_mx4 u_altf_a  (.Z(altf_mux_a),  .A(altf0_a),  .B(altf1_a),  .C(altf2_a),  .D(altf3_a),  .S0(altf_sel[0]), .S1(altf_sel[1]));

//cell_mx2 u_ie_out  (.Z(iopad_gpio_ie), .A(altf_mux_ie), .B(test_mux_ie), .S(test_en));
//cell_mx2 u_oe_out  (.Z(iopad_gpio_oe), .A(altf_mux_oe), .B(test_mux_oe), .S(test_en));
//cell_mx2 u_a_out   (.Z(iopad_gpio_a),  .A(altf_mux_a),  .B(test_mux_a),  .S(test_en));

//modified by Supriya
//Disable ie,oe when analog mode selected
//cell_mx4 u_ie_out  (.Z(iopad_gpio_ie), .A(altf_mux_ie), .B(altf_mux_ie), .C(test_mux_ie), .D(1'b0), .S0(test_ana), .S1(test_en));
//cell_mx4 u_oe_out  (.Z(iopad_gpio_oe), .A(altf_mux_oe), .B(altf_mux_oe), .C(test_mux_oe), .D(1'b0), .S0(test_ana), .S1(test_en));
//cell_mx4 u_a_out   (.Z(iopad_gpio_a),  .A(altf_mux_a),  .B(altf_mux_a),  .C(test_mux_a),  .D(1'b0), .S0(test_ana), .S1(test_en));
cell_mx4 u_ie_out  (.Z(iopad_gpio_ie), .A(altf_ie), .B(altf_ie), .C(test_mux_ie), .D(1'b0), .S0(test_ana), .S1(test_en));
cell_mx4 u_oe_out  (.Z(iopad_gpio_oe), .A(altf_oe), .B(altf_oe), .C(test_mux_oe), .D(1'b0), .S0(test_ana), .S1(test_en));
cell_mx4 u_a_out   (.Z(iopad_gpio_a),  .A(altf_a),  .B(altf_a),  .C(test_mux_a),  .D(1'b0), .S0(test_ana), .S1(test_en));

cell_clkbuf u_clk_bufin  (.CLK(clk_bufin), .CK(iopad_gpio_y));
cell_buf    u_data_bufin (.Y(data_bufin),  .A(iopad_gpio_y));

//cell_mx2 u_altf0_y (.Z(altf0_y), .A(altf0_def), .B(altf0_bufin), .S(altf0_en));
//cell_mx2 u_altf1_y (.Z(altf1_y), .A(altf1_def), .B(altf1_bufin), .S(altf1_en));
//cell_mx2 u_altf2_y (.Z(altf2_y), .A(altf2_def), .B(altf2_bufin), .S(altf2_en));
//cell_mx2 u_altf3_y (.Z(altf3_y), .A(altf3_def), .B(altf3_bufin), .S(altf3_en));
cell_mx2 u_altf0_y (.Z(altf_y), .A(altf_def), .B(altf_bufin), .S(altf_en));

cell_mx2 u_test0_y (.Z(test0_y), .A(test0_def), .B(test0_bufin), .S(test0_en));
cell_mx2 u_test1_y (.Z(test1_y), .A(test1_def), .B(test1_bufin), .S(test1_en));
cell_mx2 u_test2_y (.Z(test2_y), .A(test2_def), .B(test2_bufin), .S(test2_en));

cell_mx2 u_test3_y (.Z(test3_y), .A(test3_def), .B(test3_bufin), .S(test3_en));
cell_mx2 u_test4_y (.Z(test4_y), .A(test4_def), .B(test4_bufin), .S(test4_en));
cell_mx2 u_test5_y (.Z(test5_y), .A(test5_def), .B(test5_bufin), .S(test5_en));

cell_mx2 u_test6_y (.Z(test6_y), .A(test6_def), .B(test6_bufin), .S(test6_en));
cell_mx2 u_test7_y (.Z(test7_y), .A(test7_def), .B(test7_bufin), .S(test7_en));
cell_mx2 u_test8_y (.Z(test8_y), .A(test8_def), .B(test8_bufin), .S(test8_en));

cell_mx2 u_test9_y (.Z(test9_y), .A(test9_def), .B(test9_bufin), .S(test9_en));
//cell_mx2 u_test10_y (.Z(test10_y), .A(test10_def), .B(test10_bufin), .S(test10_en));

endmodule
