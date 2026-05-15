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
input  wire         test10_en,
input  wire         test11_en,
input  wire         test12_en,
input  wire         test13_en,
input  wire         test14_en,
input  wire         test15_en,
input  wire         test16_en,
input  wire         test17_en,
input  wire         test18_en,
input  wire         test19_en,
input  wire         test20_en,
input  wire         test21_en,
input  wire         test22_en,
input  wire         test23_en,
input  wire         test24_en,
input  wire         test25_en,
input  wire         test26_en,
input  wire         test27_en,
input  wire         test28_en,
input  wire         test29_en,
input  wire         test30_en,
input  wire         test31_en,
//input  wire	    test_ana,			//added by supriya
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
// test10
input  wire         test10_ie,   
input  wire         test10_oe,   
input  wire         test10_a,    
input  wire         test10_def,  
output wire         test10_y,    

// test11
input  wire	    test11_ie,
input  wire         test11_oe,
input  wire         test11_a ,
input  wire         test11_def,
output  wire        test11_y,
// test12
input  wire         test12_ie,
input  wire         test12_oe,
input  wire         test12_a ,
input  wire         test12_def,
output  wire        test12_y,
// test13
input  wire         test13_ie,
input  wire         test13_oe,
input  wire         test13_a ,
input  wire         test13_def,
output  wire        test13_y,
// test14
input  wire         test14_ie,
input  wire         test14_oe,
input  wire         test14_a ,
input  wire         test14_def,
output  wire        test14_y,
// test15
input  wire         test15_ie,
input  wire         test15_oe,
input  wire         test15_a ,
input  wire         test15_def,
output  wire        test15_y,
// test16
input  wire         test16_ie,
input  wire         test16_oe,
input  wire         test16_a ,
input  wire         test16_def,
output  wire        test16_y,
// test17
input  wire         test17_ie,
input  wire         test17_oe,
input  wire         test17_a ,
input  wire         test17_def,
output  wire        test17_y,
// test18
input  wire         test18_ie,
input  wire         test18_oe,
input  wire         test18_a ,
input  wire         test18_def,
output  wire        test18_y,
// test19
input  wire         test19_ie,
input  wire         test19_oe,
input  wire         test19_a ,
input  wire         test19_def,
output  wire        test19_y,
// test20
input  wire         test20_ie,
input  wire         test20_oe,
input  wire         test20_a ,
input  wire         test20_def,
output  wire        test20_y,
// test21
input  wire         test21_ie,
input  wire         test21_oe,
input  wire         test21_a ,
input  wire         test21_def,
output  wire        test21_y,
// test22
input  wire         test22_ie,
input  wire         test22_oe,
input  wire         test22_a ,
input  wire         test22_def,
output  wire        test22_y,
// test23
input  wire         test23_ie,
input  wire         test23_oe,
input  wire         test23_a ,
input  wire         test23_def,
output  wire        test23_y,
// test24
input  wire         test24_ie,
input  wire         test24_oe,
input  wire         test24_a ,
input  wire         test24_def,
output  wire        test24_y,
// test25
input  wire         test25_ie,
input  wire         test25_oe,
input  wire         test25_a ,
input  wire         test25_def,
output  wire        test25_y,
// test26
input  wire         test26_ie,
input  wire         test26_oe,
input  wire         test26_a ,
input  wire         test26_def,
output  wire        test26_y,
// test27
input  wire         test27_ie,
input  wire         test27_oe,
input  wire         test27_a ,
input  wire         test27_def,
output  wire        test27_y,
// test28
input  wire         test28_ie,
input  wire         test28_oe,
input  wire         test28_a ,
input  wire         test28_def,
output  wire        test28_y,
// test29
input  wire         test29_ie,
input  wire         test29_oe,
input  wire         test29_a ,
input  wire         test29_def,
output  wire        test29_y,
// test30
input  wire         test30_ie,
input  wire         test30_oe,
input  wire         test30_a ,
input  wire         test30_def,
output  wire        test30_y,
// test31
input  wire         test31_ie,
input  wire         test31_oe,
input  wire         test31_a ,
input  wire         test31_def,
output  wire        test31_y,

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
parameter TEST10_CLKIN = 0;
parameter TEST11_CLKIN = 0;
parameter TEST12_CLKIN = 0;
parameter TEST13_CLKIN = 0;
parameter TEST14_CLKIN = 0;
parameter TEST15_CLKIN = 0;
parameter TEST16_CLKIN = 0;
parameter TEST17_CLKIN = 0;
parameter TEST18_CLKIN = 0;
parameter TEST19_CLKIN = 0;
parameter TEST20_CLKIN = 0;
parameter TEST21_CLKIN = 0;
parameter TEST22_CLKIN = 0;
parameter TEST23_CLKIN = 0;
parameter TEST24_CLKIN = 0;
parameter TEST25_CLKIN = 0;
parameter TEST26_CLKIN = 0;
parameter TEST27_CLKIN = 0;
parameter TEST28_CLKIN = 0;
parameter TEST29_CLKIN = 0;
parameter TEST30_CLKIN = 0;
parameter TEST31_CLKIN = 0;

// wire altf0_en;
// wire altf1_en;
// wire altf2_en;
// wire altf3_en;
wire altf_en;

wire test_mux_ie;
wire test_mux_ie1;
wire test_mux_ie2;
wire test_mux_oe;
wire test_mux_oe1;
wire test_mux_oe2;
wire test_mux_a;
wire test_mux_a1;
wire test_mux_a2;

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
wire test10_bufin;
wire test11_bufin;
wire test12_bufin;
wire test13_bufin;
wire test14_bufin;
wire test15_bufin;
wire test16_bufin;
wire test17_bufin;
wire test18_bufin;
wire test19_bufin;
wire test20_bufin;
wire test21_bufin;
wire test22_bufin;
wire test23_bufin;
wire test24_bufin;
wire test25_bufin;
wire test26_bufin;
wire test27_bufin;
wire test28_bufin;
wire test29_bufin;
wire test30_bufin;
wire test31_bufin;

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
assign test10_bufin = TEST10_CLKIN ? clk_bufin : data_bufin;
assign test11_bufin = TEST11_CLKIN ? clk_bufin : data_bufin;
assign test12_bufin = TEST12_CLKIN ? clk_bufin : data_bufin;
assign test13_bufin = TEST13_CLKIN ? clk_bufin : data_bufin;
assign test14_bufin = TEST14_CLKIN ? clk_bufin : data_bufin;
assign test15_bufin = TEST15_CLKIN ? clk_bufin : data_bufin;
assign test16_bufin = TEST16_CLKIN ? clk_bufin : data_bufin;
assign test17_bufin = TEST17_CLKIN ? clk_bufin : data_bufin;
assign test18_bufin = TEST18_CLKIN ? clk_bufin : data_bufin;
assign test19_bufin = TEST19_CLKIN ? clk_bufin : data_bufin;
assign test20_bufin = TEST20_CLKIN ? clk_bufin : data_bufin;
assign test21_bufin = TEST21_CLKIN ? clk_bufin : data_bufin;
assign test22_bufin = TEST22_CLKIN ? clk_bufin : data_bufin;
assign test23_bufin = TEST23_CLKIN ? clk_bufin : data_bufin;
assign test24_bufin = TEST24_CLKIN ? clk_bufin : data_bufin;
assign test25_bufin = TEST25_CLKIN ? clk_bufin : data_bufin;
assign test26_bufin = TEST26_CLKIN ? clk_bufin : data_bufin;
assign test27_bufin = TEST27_CLKIN ? clk_bufin : data_bufin;
assign test28_bufin = TEST28_CLKIN ? clk_bufin : data_bufin;
assign test29_bufin = TEST29_CLKIN ? clk_bufin : data_bufin;
assign test30_bufin = TEST30_CLKIN ? clk_bufin : data_bufin;
assign test31_bufin = TEST31_CLKIN ? clk_bufin : data_bufin;



// (ATM0 - ATM13)
cell_mx16 u_test_ie1 (.Z(test_mux_ie1), .A(test0_ie), .B(test1_ie), .C(test2_ie), .D(test3_ie), .E(test4_ie), .F(test5_ie),  .G(test6_ie),  .H(test7_ie),  .I(test8_ie),
     				     .J(test9_ie),  .K(test10_ie),  .L(test11_ie),  .M(test12_ie),  .N(test13_ie),  .O(test14_ie),  .P(test15_ie),
		   		     .S0(test_sel[0]), .S1(test_sel[1]), .S2(test_sel[2]), .S3(test_sel[3]));
// (ATM14 - ATM29)
cell_mx16 u_test_ie2 (.Z(test_mux_ie2), .A(test16_ie), .B(test17_ie), .C(test18_ie), .D(test19_ie), .E(test20_ie), .F(test21_ie),  .G(test22_ie),  .H(test23_ie),  .I(test24_ie),
     				     .J(test25_ie),  .K(test26_ie),  .L(test27_ie),  .M(test28_ie),  .N(test29_ie),  .O(test30_ie),  .P(test31_ie),
		   		     .S0(test_sel[0]), .S1(test_sel[1]), .S2(test_sel[2]), .S3(test_sel[3]));

assign test_mux_ie = test_sel[4] ? test_mux_ie2 : test_mux_ie1;


// (ATM0 - ATM13)
cell_mx16 u_test_oe1 (.Z(test_mux_oe1), .A(test0_oe), .B(test1_oe), .C(test2_oe), .D(test3_oe), .E(test4_oe), .F(test5_oe),  .G(test6_oe),  .H(test7_oe),  .I(test8_oe),    
 				     .J(test9_oe),  .K(test10_oe), .L(test11_oe),     .M(test12_oe),      .N(test13_oe),    .O(test14_oe),      .P(test15_oe),
				     .S0(test_sel[0]), .S1(test_sel[1]), .S2(test_sel[2]), .S3(test_sel[3]));
// (ATM14 - ATM29)
cell_mx16 u_test_oe2 (.Z(test_mux_oe2), .A(test16_oe), .B(test17_oe), .C(test18_oe), .D(test19_oe), .E(test20_oe), .F(test21_oe),  .G(test22_oe),  .H(test23_oe),  .I(test24_oe),    
 				     .J(test25_oe),  .K(test26_oe), .L(test27_oe),     .M(test28_oe),      .N(test29_oe),    .O(test30_oe),      .P(test31_oe),
				     .S0(test_sel[0]), .S1(test_sel[1]), .S2(test_sel[2]), .S3(test_sel[3]));

assign test_mux_oe = test_sel[4] ? test_mux_oe2 : test_mux_oe1;

// (ATM0 - ATM13)
cell_mx16 u_test_a1 (.Z(test_mux_a1),  .A(test0_a),  .B(test1_a),  .C(test2_a),  .D(test3_a),  .E(test4_a),  .F(test5_a),   .G(test6_a),   .H(test7_a),   .I(test8_a),  
    				      .J(test9_a),  .K(test10_a), .L(test11_a),     .M(test12_a),      .N(test13_a),    .O(test14_a),      .P(test15_a),
				      .S0(test_sel[0]), .S1(test_sel[1]), .S2(test_sel[2]), .S3(test_sel[3]));
// (ATM14 - ATM29)
cell_mx16 u_test_a2  (.Z(test_mux_a2),  .A(test16_a),  .B(test17_a),  .C(test18_a),  .D(test19_a),  .E(test20_a),  .F(test21_a),   .G(test22_a),   .H(test23_a),   .I(test24_a),  
    				      .J(test25_a),  .K(test26_a), .L(test27_a),     .M(test28_a),      .N(test29_a),    .O(test30_a),      .P(test31_a),
				      .S0(test_sel[0]), .S1(test_sel[1]), .S2(test_sel[2]), .S3(test_sel[3]));

assign test_mux_a = test_sel[4] ? test_mux_a2 : test_mux_a1;

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


//cell_mx4 u_ie_out  (.Z(iopad_gpio_ie), .A(altf_ie), .B(altf_ie), .C(test_mux_ie), .D(1'b0), .S0(test_ana), .S1(test_en));
//cell_mx4 u_oe_out  (.Z(iopad_gpio_oe), .A(altf_oe), .B(altf_oe), .C(test_mux_oe), .D(1'b0), .S0(test_ana), .S1(test_en));
//cell_mx4 u_a_out   (.Z(iopad_gpio_a),  .A(altf_a),  .B(altf_a),  .C(test_mux_a),  .D(1'b0), .S0(test_ana), .S1(test_en));

cell_mx2 u_ie_out  (.Z(iopad_gpio_ie), .A(altf_ie), .B(test_mux_ie), .S(test_en));
cell_mx2 u_oe_out  (.Z(iopad_gpio_oe), .A(altf_oe), .B(test_mux_oe), .S(test_en)); 
cell_mx2 u_a_out   (.Z(iopad_gpio_a),  .A(altf_a),  .B(test_mux_a),  .S(test_en)); 

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
cell_mx2 u_test10_y (.Z(test10_y), .A(test10_def), .B(test10_bufin), .S(test10_en));
cell_mx2 u_test11_y (.Z(test11_y), .A(test11_def), .B(test11_bufin), .S(test11_en));
cell_mx2 u_test12_y (.Z(test12_y), .A(test12_def), .B(test12_bufin), .S(test12_en));
cell_mx2 u_test13_y (.Z(test13_y), .A(test13_def), .B(test13_bufin), .S(test13_en));
cell_mx2 u_test14_y (.Z(test14_y), .A(test14_def), .B(test14_bufin), .S(test14_en));
cell_mx2 u_test15_y (.Z(test15_y), .A(test15_def), .B(test15_bufin), .S(test15_en));
cell_mx2 u_test16_y (.Z(test16_y), .A(test16_def), .B(test16_bufin), .S(test16_en));
cell_mx2 u_test17_y (.Z(test17_y), .A(test17_def), .B(test17_bufin), .S(test17_en));
cell_mx2 u_test18_y (.Z(test18_y), .A(test18_def), .B(test18_bufin), .S(test18_en));
cell_mx2 u_test19_y (.Z(test19_y), .A(test19_def), .B(test19_bufin), .S(test19_en));
cell_mx2 u_test20_y (.Z(test20_y), .A(test20_def), .B(test20_bufin), .S(test20_en));
cell_mx2 u_test21_y (.Z(test21_y), .A(test21_def), .B(test21_bufin), .S(test21_en));
cell_mx2 u_test22_y (.Z(test22_y), .A(test22_def), .B(test22_bufin), .S(test22_en));
cell_mx2 u_test23_y (.Z(test23_y), .A(test23_def), .B(test23_bufin), .S(test23_en));
cell_mx2 u_test24_y (.Z(test24_y), .A(test24_def), .B(test24_bufin), .S(test24_en));
cell_mx2 u_test25_y (.Z(test25_y), .A(test25_def), .B(test25_bufin), .S(test25_en));
cell_mx2 u_test26_y (.Z(test26_y), .A(test26_def), .B(test26_bufin), .S(test26_en));
cell_mx2 u_test27_y (.Z(test27_y), .A(test27_def), .B(test27_bufin), .S(test27_en));
cell_mx2 u_test28_y (.Z(test28_y), .A(test28_def), .B(test28_bufin), .S(test28_en));
cell_mx2 u_test29_y (.Z(test29_y), .A(test29_def), .B(test29_bufin), .S(test29_en));
cell_mx2 u_test30_y (.Z(test30_y), .A(test30_def), .B(test30_bufin), .S(test30_en));
cell_mx2 u_test31_y (.Z(test31_y), .A(test31_def), .B(test31_bufin), .S(test31_en));


endmodule
