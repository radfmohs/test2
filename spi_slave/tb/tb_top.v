
`timescale 1 ns /  1 ps
module tb_top();

parameter SPI_CLK_PERIOD          = 62.5; //110khz=9090; // 16 MHZ=62.5     //for 256khz-3906.25 //4mhz=250
parameter SYS_CLK_PERIOD_2MHZ     = 500;   //2 MHZ

parameter mem_depth=8;
parameter mem_width=8;



parameter NO_OF_WAVEGEN=8;
 

`define  RESETN   spi_top_u.i_rst_n

reg clk_r;
reg rst_n_r;
reg cs_n_r;
reg sclk_g;
reg mosi_r;
reg miso_r;
wire miso_w;

reg  sts_wr_en_r;
reg [127:0] sts_wr_value_r;
reg wr;
reg rd;
reg stop_clk;
//wire clk_rr;
reg clk_enable;
reg wr_rd;
reg rd_wr;
reg sys_clk;
reg SCANMODE;
wire sclk_r;

wire clk_rrr;
wire cs_n_rr;
reg [1:0] spi_mode;



initial 
 begin
      clk_r          =1'b0; 
      clk_enable     =1'b0; 
     // sts_wr_en_r    =1'b0;
     // sts_wr_value_r =128'b0;
      SCANMODE       =1'B0;

        spi_mode        =2'b00;
      

      wr             =1'b0;
      rd             =1'b0;
      wr_rd          =1'b0;
      rd_wr          =1'b0;
  #30 rst_n_r        =1'b0;
  #20 rst_n_r        =1'b1;     //reset release
  #100100 rd         =1'b1;
end


//------------intialize  spi signals-------------------
initial
begin
     cs_n_r        = 1'b1;        // chip_select high(slave not selcted)
     mosi_r        = 1'bz;        // when no transction mosi_r is high impedence
     sclk_g        = 1'b0;
end
//// spi clk generation/////////////////
 
always 
 begin
  clk_r = #(SPI_CLK_PERIOD/2) ~clk_r; //clk for input MOSI data (data change on posedge of clk changes)
 end 

/*
always 
 begin
  clk_enable = #( 1*(SPI_CLK_PERIOD/2)) clk_en;
 end
*/


/*

//sclk generation 
wire clk_rr; //original
//assign clk_rr =  cs_n_r ? 1'b0 : clk_r; // ( cpol=0, cpha=0(general) (spi_contoller_new.v) 
//assign clk_rr = sclk_g  ? clk_r : 1'b0; //sclk_g ;// ( cpol=0, cpha=0(general) (spi_contoller_new.v)  //working for ens2

//assign clk_rr =  cs_n_r ? 1'b0 : ~clk_r;// ( cpol=0, cpha=1)
//assign clk_rr =  cs_n_r ? 1'b1 : clk_r; // ( cpol=1, cpha=1) 
//assign clk_rr =  cs_n_r ? 1'b1 : ~clk_r;// ( cpol=1, cpha=0) spi_controller.v

assign clk_rr = sclk_g  ? clk_r : 1'b0; //sclk_g ;// ( cpol=0, cpha=0(general) (spi_contolle
//assign clk_rr =  sclk_g ? ~clk_r:1'b0;// ( cpol=0, cpha=1)

//assign clk_rr =  sclk_g ? ~clk_r : 1'b1;// ( cpol=1, cpha=0) spi_controller.v
//assign clk_rr =  sclk_g ?  clk_r :1'b1; // ( cpol=1, cpha=1)
*/


assign clk_rr = (spi_mode === 2'b00) ? (sclk_g  ?  clk_r : 1'b0) :      // ( cpol=0, cpha=0(general) (spi_contoller_new.v)
                (spi_mode === 2'b01) ? (sclk_g  ?  clk_r : 1'b0) :      // ( cpol=0, cpha=1)
                (spi_mode === 2'b10) ? (sclk_g  ? !clk_r : 1'b1) :      // ( cpol=1, cpha=0)
                (spi_mode === 2'b11) ? (sclk_g  ? !clk_r : 1'b1) : 1'b0;// ( cpol=1, cpha=1)




assign #((spi_mode[0] === 1'b0) * (SPI_CLK_PERIOD/2)) clk_rrr = clk_rr;
assign #((spi_mode[0] === 1'b0) * (SPI_CLK_PERIOD/2)) cs_n_rr = cs_n_r;



assign sclk_r=clk_rr;  //old commented on ens2

//assign sclk_r=clk_r;

///-----sys clk generation ///////////
initial
 begin
  sys_clk=1'b0;
// drive_sts_reg_input =1'b0;
 end

always 
 begin
  sys_clk = #(SYS_CLK_PERIOD_2MHZ/2) ~sys_clk; //2mhz  //#(SYS_CLK_PERIOD_16MHZ/2) ~sys_clk;
 end

/////////////dut instance////////////////////

spi_top  #(.addr_width(8),
           .data_width(8))
 spi_top_u (

  //spi inputs
    .SCANMODE(SCANMODE),
    .i_rst_n(rst_n_r),
   // .i_sys_clk(sys_clk),                     // clk for the reg block  sys_clk 16MHZ

/*
    .i_sclk(clk_rr), //clk_rr            // sclk clock for the spi-slave controller and reg block 
    .i_cs_n(cs_n_r),
*/
  
    .i_sclk(clk_rrr), //clk_rr            // sclk clock for the spi-slave controller and reg block 
    .i_cs_n(cs_n_rr),


    .i_mosi(mosi_r),
    .iopad_cpol(spi_mode[1]),
    .iopad_cpha(spi_mode[0]),   

     //spi outputs
    .o_miso(miso_w),

    .rd_cmd_ind(),
    .first_neg_sclk(),

  //other inputs 
    .d2a_trim0_from_otp(), // trim value to analog,only read by spi bus
    .d2a_trim1_from_otp(), 
    .d2a_trim2_from_otp(),
    .d2a_trim3_from_otp(),
    .d2a_trim4_from_otp(),
    .d2a_trim5_from_otp(),
    .d2a_trim6_from_otp(),
    .d2a_alt_fun_from_otp(),
    .EEPROM_Reset_Done(),
    .DEBUG_otp(),
    .otp_BUSY(), 
    .analog_test_mode(),
    .atm_mode(),
    .atm_data(),
    .unlock_gpio(),
    .comp0_out(),
    .comp1_out(),
    .charger_ok(),
    .charger_end(),
    .lvd_out(),
    .temp_150c_trig(),
    .boost_oc(),
    .boost_ot(),
    .boost_ov(),

 //wavegen

    .i_wg_driver_in_wave_addr(),
    .i_wg_driver_source(),
    .i_wg_driver_int_sts(),

  //outputs
     .o_config_reg(),
     .o_wg_driver_rest_t(), 
     .o_wg_driver_silent_t(), 
     .o_wg_driver_hlf_wave_prd(), 
     .o_wg_driver_neg_hlf_wave_prd(), 
     .o_wg_driver_alter_lim(), 
     .o_wg_driver_alter_silent_lim(), 
    .o_wg_driver_delay_lim(), 
    .o_wg_driver_isel(), 
    .o_wg_driver_sw_config(), 
//  output wire   [7:0]                o_wg_driver_clk_freq[NO_OF_WAVEGEN-1:0],
    .o_mult_elec(),
    .o_wg_driver_in_wave(),
//  output wire   [7:0]                o_wg_driver_elec_no[NO_OF_WAVEGEN-1:0],

   .o_wg_driver_int_addr0(),
   .o_wg_driver_int_addr1(),
   .o_wg_driver_int_en(),   
   .o_addr0_int_clr(),      
    .o_addr1_int_clr(),
 
     
//other outputs
  
    .reset_cmd(),
    .fclk_dynen(),
    .pclk_div(),
    .wave_gen_dis(),
    .wave_gen_rst(),
    
  // .trim_tag_en(),
 //  .trim1_en(),
 //  .trim2_en(),
 //  .trim3_en(),
//   .trim4_en(),
 //  .trim5_en(),
 //  .trim6_en(),
   .trim_tag_reg(),
   .d2a_trim1_to_otp(),
   .d2a_trim2_to_otp(),
   .d2a_trim3_to_otp(),
   .d2a_trim4_to_otp(),
   .d2a_trim5_to_otp(),
   .d2a_trim6_to_otp(),
   .d2a_alt_fun_to_otp(),
   .otp_unlock(), 
  
   .pmuenable(),            // pmu enable
   .hresetreq(),            // system reset request
   .sleepdeep(),            // system enters deep-sleep state
   .otp_dpstb_en(),        // eeprom deep power down standby mode enable 
    //    output  wire   fclk_sleep_en,
    
       //gpio
  //  .gpio_0_ctrl_all() ,
  //  .gpio_1_ctrl_all() ,
  //  .gpio_2_ctrl_all() ,
  //  .gpio_3_ctrl_all() ,
 //   .gpio_4_ctrl_all() ,
  //  .gpio_5_ctrl_all() ,
  //  .gpio_6_ctrl_all() ,
  //  .gpio_7_ctrl_all() ,

     .o_BG_BUF_EN(),
     .o_DAC_BUF_EN(),
    //ana_tsc
     .o_TSC_EN(),
     .o_TSC_AMP_EN(),
     .o_TSC_BJT_SEL(),
     .o_TSC_GSEL(),
     . o_TSC_OUT_SEL(),




   //Peripheral
     .o_BIST_EN(),
     .o_BIST_ISEL(),
     .o_DDA_EN(),
     .o_DDA_GSEL(),
     .o_PGA_EN(),
     .o_PGA_VIN_SEL(),
     .o_PGA_GSEL(),
     .o_ELE_BUF_EN(),
     .o_ELE_BUF_ISEL(),



     .o_SDM_EN(),
     .o_SDM_CHOP_EN(),


 //anac
     .comp0_ctrl_reg(),     
     .comp1_ctrl_reg(),     
     .pga_ctrl0_reg(),      
     .pga_ctrl1_reg(),      
     .charge_ctrl0_reg(),   
     .charge_ctrl1_reg(),   
     .pmu_ctrl_reg(),       
     .boost_ctrl0_reg(),   
     .boost_ctrl1_reg(),    
     .boost_ctrl2_reg(),    
     .ana_bist0_reg(),      
     .ana_bist1_reg() 


   

   







  //other inputs
/*
 //  .DAISY_IN_Y(),
//   .RLD_STAT(),
 //  .IN8P_OFF(),
//   .IN7P_OFF(),
 //  .IN6P_OFF(),
//   .IN5P_OFF(),
//   .IN4P_OFF(),
////   .IN3P_OFF(),
//   .IN2P_OFF(),
//   .IN1P_OFF(),

//   .IN8N_OFF(),
//   .IN7N_OFF(),
 //  .IN6N_OFF(),
//   .IN5N_OFF(),
//   .IN4N_OFF(),
 //  .IN3N_OFF(),
  // .IN2N_OFF(),
 //  .IN1N_OFF(),

 
//other outputs
    .config1(),
    .resp(),
    .wakeup_cmd(),
    .standby_cmd(),
    .start_cmd(),
    .stop_cmd(),
    .reset_cmd(),

    .HR(),
  //  .DAISY_ENn(),
    .CLK_EN(),
    .DR(),

   .WCT_CHOP(),
   .INT_TEST(),
   .TEST_AMP(),
   .TEST_FREQ(),

    .PD_REFBUFn(),
    .VREF_4V(),
    .RLD_MEAS(),
    .RLDREF_INT(),
    .PD_RLDn(),
    .RLD_LOFF_SENS(),

    .COMP_TH(),
    .VLEAD_OFF_EN(),
    .ILEAD_OFF(),
    .FLEAD_OFF(),


    .PD1(),
    .GAIN1(),
    .MUX1(),

    .PD2(),
    .GAIN2(),
    .MUX2(),

    .PD3(),
    .GAIN3(),
    .MUX3(),

    .PD4(),
    .GAIN4(),
    .MUX4(),

    .PD5(),
    .GAIN5(),
    .MUX5(),

    .PD6(),
    .GAIN6(),
    .MUX6(),

    .PD7(),
    .GAIN7(),
    .MUX7(),

    .PD8(),
    .GAIN8(),
    .MUX8(),

    .RLD8P(),
    .RLD7P(),
    .RLD6P(),
    .RLD5P(),
    .RLD4P(),
    .RLD3P(),
    .RLD2P(),
    .RLD1P(),

    .RLD8N(),
    .RLD7N(),
    .RLD6N(),
    .RLD5N(),
    .RLD4N(),
    .RLD3N(),
    .RLD2N(),
    .RLD1N(),
    .LOFF8P(),
    .LOFF7P(),
    .LOFF6P(),
    .LOFF5P(),
    .LOFF4P(),
    .LOFF3P(),
    .LOFF2P(),
    .LOFF1P(),

    .LOFF8N(),
    .LOFF7N(),
    .LOFF6N(),
    .LOFF5N(),
    .LOFF4N(),
    .LOFF3N(),
    .LOFF2N(),
    .LOFF1N(),

    .LOFF_FLIP8(),
    .LOFF_FLIP7(),
    .LOFF_FLIP6(),
    .LOFF_FLIP5(),
    .LOFF_FLIP4(),
    .LOFF_FLIP3(),
    .LOFF_FLIP2(),
    .LOFF_FLIP1(),
    .GPIOD(),
    .GPIOC(),
    .GPIO_Y(),

    .PACEE(),
    .PACEO(),
    .PD_PACEn(),

     .RESP_DEMOD_EN1(),
     .RESP_MOD_EN1(),
     .RESP_PH(),
     .RESP_CTRL(),

     .RESP_FREQ(),
     .SINGLE_SHOT(),
     .WCT_TO_RLD(),
     .PD_LOFF_COMPn(),


     .aVF_CH6(),
     .aVL_CH5(),
     .aVR_CH7(),
     .aVR_CH4(),
     .PD_WCTAn(),
     .WCTA(),

     .PD_WCTCn(),
     .PD_WCTBn(),
     .WCTB(),
     .WCTC(),

     .imeas_ch0data(),     // Channel 0 data
  //   .imeas_int_sts(),
     .imeas_en(),
  //   .imeas_int_clr(),
     .imeas_reg_ctrl(),


     .fclk_dynen(),
     .pclk_div(),
     .iclk_div(),
     .imeas_adc_inv(),
     .flash_to_ana_trim0(), // trim value to analog(),only read by spi bus
     .flash_to_ana_trim1(), 
     .flash_to_ana_trim2(),
     .flash_to_ana_trim3(),
     .flash_to_ana_trim4(),
     .flash_to_ana_trim5(),
     .flash_to_ana_trim6(),
     .FLASH_Reset_Done(),
     .DEBUG_FLASH(),
     .dc_clk_div_flash(), 

     .pmuenable(),            // pmu enable
     .hresetreq(),            // system reset request
     .sleepdeep(),            // system enters deep-sleep state
     .flash_dpstb_en()   
       */
 
    );

`include "../tc/spi_op_cmd_wake_up.sv"
`include "../tc/spi_stimulus.sv"
  

initial 
begin
       $display("start dumping vcd file\n");
       $vcdplusfile("top_tb.vpd");    
       $vcdpluson (0);
       $vcdplusmemon(0);

end

initial
 begin
//#480000;

#1000000;
//$display($time, "\tERROR: Simulation is HANG!!!\n");
$finish;
end


endmodule



