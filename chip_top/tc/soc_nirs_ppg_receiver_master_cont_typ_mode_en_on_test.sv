/*======================================================================================
// Copyright 2021 Nanochap Electronics, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_nirs_ppg_receiver_master_cont_typ_mode_en_on_test.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: Testcase soc_nirs_ppg_receiver_master_cont_typ_mode_en_on_test                                             
// Designer	: supriya@nanochap.com                                                                 
// Date		: 15-01-2026                                                                     
// Revision	: 0.1 Initial version created by script                                 
// ====================================================================================*/

// =================================================
// Testcase name is defined
// -------------------------------------------------
`define TESTNAME soc_nirs_ppg_receiver_master_cont_typ_mode_en_on_test
`define TESTCFG soc_nirs_ppg_receiver_master_cont_typ_mode_en_on_test_cfg

class `TESTCFG extends soc_nirs_ppg_base_test_cfg;

  `nnc_object_utils(`TESTCFG)

  // ===============================================
  // Adding your new varialbles in config test
  // -----------------------------------------------

  rand logic [7:0] wr_data[256];
  rand int         no_of_bytes; 
  rand logic [7:0] reg_addr;
  rand logic [7:0] pads;
  rand logic [7:0] mask;
  rand logic [7:0] expected_data;
  logic [7:0]      rd_data[];
  logic [7:0]      ch;
  bit [1:0]        num_leds;
  bit              first_time_config=0;

  // -----------------------------------------------
  // End of decalration of new variables 
  // ===============================================

  function new (string name = "soc_nirs_ppg_receiver_master_cont_typ_mode_en_on_test_cfg");
    super.new(name);
    
  endfunction: new

  // ===============================================
  // Adding constraints of randomization
  // -----------------------------------------------

  // testmode_sel[1:0] : 00-Normal mode, 01: Scanmode, 10: BIST mode, 11 atm0/1/2/3/4
  constraint c_testmode_sel { soft testmode_sel == 2'b00; }

  // spimode_sel[1:0] :  
  constraint c_spimode_sel { spimode_sel == 2'b00; }

  // No of bytes in a burst
  constraint c_no_of_bytes { soft no_of_bytes == 2; }

  // pads values
  constraint c_pads        { soft pads == 8'h00; }

  // mask values
  constraint c_mask        { soft mask == 8'hff; }

  // -----------------------------------------------
  // End of adding constraints of randomization
  // ===============================================

endclass : `TESTCFG

// ===============================================
// Main Testcase is defined
// -----------------------------------------------
class `TESTNAME extends soc_nirs_ppg_base_test;
   
  `nnc_component_utils(`TESTNAME)

  `TESTCFG top_test_cfg;

  // -----------------------------------------
  // Declare the new function 
  // -----------------------------------------
  function new(string name, nnc_component parent);
    super.new(name, parent);
  endfunction

  // -----------------------------------------
  // Declare the build_phase function 
  // -----------------------------------------
  virtual function void build_phase(nnc_phase phase);
    super.build_phase(phase);
    `nnc_top.set_timeout(30ms/*2s*/);
    top_test_cfg = `TESTCFG::type_id::create("top_test_cfg", this);
  endfunction

  // -----------------------------------------
  // Declare the pre_reset_phase task 
  // -----------------------------------------
  virtual task pre_reset_phase(nnc_phase phase);
    phase.raise_objection(this);

    super.pre_reset_phase(phase);

    assert(top_test_cfg.randomize());

    `DUT_IF.testmode_sel = top_test_cfg.testmode_sel;

    `DUT_IF.spimode_sel = top_test_cfg.spimode_sel;

    // -------------------
    // Scoreboard enables
    // -------------------
    // `FLASH_SCOREBOARD_EN = 1;
    // `SPIM_SCOREBOARD_EN = 1;
    // `ANALOG_SCOREBOARD_EN = 1;
    // `IMEAS_SCOREBOARD_EN = 1;
    // `CLKRST_SCOREBOARD_EN = 1;

    phase.drop_objection(this);
  endtask : pre_reset_phase

  // -----------------------------------------
  // Declare the main_phase task of your test
  // -----------------------------------------
  virtual task main_phase(nnc_phase phase);
    phase.raise_objection(this);
    
    super.main_phase(phase);

    `nnc_info("SOC_TEST", "soc_nirs_ppg_receiver_master_cont_typ_mode_en_on_test start", NNC_LOW)

    // ==================================================================================
    // Please add your code of your test here
    // ---------------------------------------------------------------------------------- 
    
    // --------------------------------------------------------
    // This is an example RD_RESET_CHK_REG 
    // --------------------------------------------------------
    //assert(top_test_cfg.randomize() with {reg_addr == `SOC_ADDR_WG_DRV_CONFIG_REG0; expected_data == `INIT_SOC_ADDR_WG_DRV_CONFIG_REG0;});
    //`nnc_info("SOC_TEST", "Single Reading to a Register and doing a Check READ DATA with Initial values", NNC_LOW)
    //`RD_RESET_CHK_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.expected_data, top_test_cfg.pads);

    //// --------------------------------------------------------
    //// This is an example WR_REG - single write to registers
    //// --------------------------------------------------------
    //assert(top_test_cfg.randomize() with {reg_addr == `SOC_ADDR_WG_DRV_CONFIG_REG0;});
    //`nnc_info("SOC_TEST", "Single Writing to a Register", NNC_LOW)
    //`WR_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.wr_data[0], top_test_cfg.pads);

    //// --------------------------------------------------------
    //// This is an example RD_REG - single read to registers
    //// --------------------------------------------------------
    //assert(top_test_cfg.randomize() with {reg_addr == `SOC_ADDR_WG_DRV_CONFIG_REG0;});
    //`nnc_info("SOC_TEST", "Single Reading to a Register", NNC_LOW)
    //`RD_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.pads, top_test_cfg.rd_data[0]);

    //// --------------------------------------------------------
    //// This is an example WR_RD_CHK_REG
    //// --------------------------------------------------------
    //assert(top_test_cfg.randomize() with {reg_addr == `SOC_ADDR_WG_DRV_CONFIG_REG0;});
    //`nnc_info("SOC_TEST", "Single Writing/Reading to a Register and doing a Check of DATAs", NNC_LOW)
    //`WR_RD_CHK_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.data[0], top_test_cfg.pads, top_test_cfg.mask);

    //// --------------------------------------------------------
    //// This is an example WR_BURST_REG - burst write to registers
    //// --------------------------------------------------------
    //assert(top_test_cfg.randomize() with {reg_addr == `SOC_ADDR_WG_DRV_CONFIG_REG0; no_of_bytes == 4;});
    //`nnc_info("SOC_TEST", "Burst Writing to Registers", NNC_LOW)
    //`WR_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.pads, top_test_cfg.data);

    //// --------------------------------------------------------
    //// This is an example RD_BURST_REG - burst read to registers
    //// --------------------------------------------------------
    //assert(top_test_cfg.randomize() with {reg_addr == `SOC_ADDR_WG_DRV_CONFIG_REG0; no_of_bytes == 4;});
    //`nnc_info("SOC_TEST", "Burst Reading to Registers", NNC_LOW)
    //`RD_BURST_WAVEGEN_REG(top_test_cfg.reg_addr, top_test_cfg.no_of_bytes, top_test_cfg.rd_data);
 

    //// ########################################################
    //// ########################################################
    //// --------------------------------------------------------
    //// --------------------------------------------------------
    //// NIRS/PPG Configration begins from here:
    //// --------------------------------------------------------
    //// --------------------------------------------------------
    //// ########################################################
    //// ########################################################

    //assert(top_test_cfg.randomize() with {top_test_cfg.ch_en_mask != 0;});
   `nnc_info("PPG_TEST",$sformatf("top_test_cfg.ch_en_mask=%0h",`NIRS_PPG_IF.ch_en_mask),NNC_LOW); 
   `nnc_info("PPG_TEST",$sformatf("define num_of_leds in loop =%0h",top_test_cfg.num_of_leds_loop ),NNC_LOW); 
   `nnc_info("PPG_TEST",$sformatf("gen_reg_int_clr_typ =%0h",`NIRS_PPG_IF.gen_reg_int_clr_typ ),NNC_LOW);
   `nnc_info("PPG_TEST",$sformatf("gen_reg_int_length_sel =%0h",`NIRS_PPG_IF.gen_reg_int_length_sel ),NNC_LOW);
   `nnc_info("PPG_TEST",$sformatf("gen_reg_int_active_level =%0h",`NIRS_PPG_IF.gen_reg_int_active_level ),NNC_LOW);
    
    //Configure GENERAL INTRRUPT CTRL REG
    config_general_interrupt_ctrl_reg();

    //
    top_test_cfg.first_time_config = 1'b1; 
    `nnc_info("PPG_TEST",$sformatf("for common nirs reg configuration first_time_config=%0h",top_test_cfg.first_time_config),NNC_LOW); 

    for(top_test_cfg.num_leds =0; top_test_cfg.num_leds < top_test_cfg.num_of_leds_loop; top_test_cfg.num_leds++ )begin  //led0 led1
        top_test_cfg.temp_en_config_leds = (2**top_test_cfg.num_leds);
         `nnc_info("PPG_TEST",$sformatf("temp_en_config_leds[1:0]=%0h",top_test_cfg.temp_en_config_leds ),NNC_LOW);

        for (top_test_cfg.ch = 0; top_test_cfg.ch < 1; top_test_cfg.ch++) begin  //ch0 to ch7
           bit ch_en = `NIRS_PPG_IF.ch_en_mask[top_test_cfg.ch];
          
           `nnc_info("PPG_TEST",$sformatf("channel_number=%0d, ch_en=%0h",top_test_cfg.ch, ch_en),NNC_LOW);
   
          // // 1. Randomize a fresh configuration for this channel
          assert(`NIRS_PPG_CTRL_CFG.randomize() with{nirs_ppg_mode_sel == 'h4;
                                                     nirs_ppg_led_ambient_en == ((ctrl_ambient_mode == 1'b1) ? 1'b1 : 1'b0);
                                                     threshold_h_18_16 == 'h0;
                                                     threshold_h_15_8  == 'h0; 
                                                     threshold_h_7_0 inside {[0:10]};
                                                     threshold_l_7_0 inside {[0:10]};
                                                     en_config_led0 ==  top_test_cfg.temp_en_config_leds[0] ; //'h1; // led0 and led1 configuration one by one to have different random value
                                                     en_config_led1 ==  top_test_cfg.temp_en_config_leds[1]; //'h0; // led0 and led1 configuration one by one to have different random value
                                                     //nirs_ppg_led_signle_en == 'h0;
                                                     idac_min_int_en == 'h0;
                                                     idac_max_int_en == 'h0;
                                                     iref_fine_on_not_off_en == 'h0;
                                                     iref_fine_not_on_en == 'h0;
                                                     iref_coarse_on_not_off_en == 'h0;
                                                     iref_coarse_not_on_en == 'h0;
                                                     data_ready_en == 'h1;
                                                     //nirs_int_pin_en == 1'b0;  //testing
                                                     idac_en == 'h1;
                                                     //bypass_or_gateclk == 1'b1; //by default 1
                                                     //debug_channel == (top_test_cfg.ch +1'b1);
                                                     //debug_led     == top_test_cfg.num_leds;
                                                    });

       
          `nnc_info("PPG_TEST",$sformatf("nirs pgg base test top_test_cfg: h18_16=%0d h15_8=%0d h7_0=%0d l7_0=%0d",
                    `NIRS_PPG_CTRL_CFG.threshold_h_18_16,
                    `NIRS_PPG_CTRL_CFG.threshold_h_15_8,
                    `NIRS_PPG_CTRL_CFG.threshold_h_7_0,
                    `NIRS_PPG_CTRL_CFG.threshold_l_7_0),NNC_LOW);


          //2.Configure only once common regs after randomization
          if(top_test_cfg.first_time_config === 1'b1)begin
            //first time config drive to interface
            first_time_config_drive_to_nirs_if();

            //1.nirs_clk_reg
            config_nirs_clk_ctrl_reg;
            //2. configure control led register
            //config_nirs_ctrl_led_reg;
            //3.
            config_nirs_adj0_reg;
            drive_nirs_adj0_to_nirs_if();
    
            //4.configure channel enable register
            config_nirs_channel_en_reg(`NIRS_PPG_IF.ch_en_mask);
            //5.
            config_nirs_intr_en_reg;
            //6.
            config_nirs_ctrl_mode_reg;
           `nnc_info("PPG_TEST",$sformatf("nirs pgg base test CFG_ctrl_ambient_mode =%0h, nirs_ppg_led_ambient_en =%0h, nirs_ppg_led_signle_en =%0h, nirs_ppg_mode_sel=%0h", `NIRS_PPG_CTRL_CFG.ctrl_ambient_mode,  `NIRS_PPG_CTRL_CFG.nirs_ppg_led_ambient_en, `NIRS_PPG_CTRL_CFG.nirs_ppg_led_signle_en,`NIRS_PPG_CTRL_CFG.nirs_ppg_mode_sel),NNC_LOW); 
           `nnc_info("PPG_TEST","Disable common regs configuration for each loop",NNC_LOW);
            top_test_cfg.first_time_config =1'b0; 
            `nnc_info("PPG_TEST",$sformatf("for common nirs reg configuration first_time_config=%0h",top_test_cfg.first_time_config),NNC_LOW);
          end
      
          //2.aconfigure control led register
          config_nirs_ctrl_led_reg;
          
 
          ////3. Enable only this channel
          //`NIRS_PPG_CTRL_CFG.en_config_ch0 =  //(top_test_cfg.ch == 0) && ch_en;
          //`NIRS_PPG_CTRL_CFG.en_config_ch1 =  //(top_test_cfg.ch == 1) && ch_en;
          //`NIRS_PPG_CTRL_CFG.en_config_ch2 =  //(top_test_cfg.ch == 2) && ch_en;
          //`NIRS_PPG_CTRL_CFG.en_config_ch3 =  //(top_test_cfg.ch == 3) && ch_en;
          //`NIRS_PPG_CTRL_CFG.en_config_ch4 =  //(top_test_cfg.ch == 4) && ch_en;
          //`NIRS_PPG_CTRL_CFG.en_config_ch5 =  //(top_test_cfg.ch == 5) && ch_en;
          //`NIRS_PPG_CTRL_CFG.en_config_ch6 =  //(top_test_cfg.ch == 6) && ch_en;
          //`NIRS_PPG_CTRL_CFG.en_config_ch7 =  //(top_test_cfg.ch == 7) && ch_en;
  
          //`nnc_info("PPG_TEST",$sformatf("nirs pgg base test en_config_ch0=%0h, en_config_ch1=%0h, en_config_ch2=%0h, en_config_ch3=%0h, en_config_ch4=%0h, en_config_ch5=%0h, en_config_ch6=%0h, en_config_ch7=%0h ",
          // `NIRS_PPG_CTRL_CFG.en_config_ch0,
          // `NIRS_PPG_CTRL_CFG.en_config_ch1,
          // `NIRS_PPG_CTRL_CFG.en_config_ch2,
          // `NIRS_PPG_CTRL_CFG.en_config_ch3,
          // `NIRS_PPG_CTRL_CFG.en_config_ch4,
          // `NIRS_PPG_CTRL_CFG.en_config_ch5,
          // `NIRS_PPG_CTRL_CFG.en_config_ch6,
          // `NIRS_PPG_CTRL_CFG.en_config_ch7),NNC_LOW);
 
         //3. STORE RANDOMIZED VALUES INTO EXPECTED MODEL for scoreboard/checker
         //3.a (LED0)
          if(`NIRS_PPG_CTRL_CFG.en_config_led0 === 1'b1)begin
           `nnc_info("PPG_TEST",$sformatf("nirs pgg base test Enabled LED0 REGS CONFIGURATION, en_config_led0=%0h", `NIRS_PPG_CTRL_CFG.en_config_led0),NNC_LOW);
            `NIRS_PPG_CTRL_CFG.compute_expected(top_test_cfg.ch,top_test_cfg.num_leds); 
          end

         //3.b (LED1)
         if(`NIRS_PPG_CTRL_CFG.en_config_led1 === 1'b1)begin
           `nnc_info("PPG_TEST",$sformatf("nirs pgg base test Enabled LED1 REGS CONFIGURATION, en_config_led1=%0h", `NIRS_PPG_CTRL_CFG.en_config_led1),NNC_LOW);
            `NIRS_PPG_CTRL_CFG.compute_expected(top_test_cfg.ch,top_test_cfg.num_leds); 
         end
         
         //4. Drive DUT/NIRS interface with this channel's config, debug purpose\
         //LED0
          if(`NIRS_PPG_CTRL_CFG.en_config_led0 === 1'b1)begin
           drive_nirs_if_from_cfg_leds(top_test_cfg.ch,top_test_cfg.num_leds);
         end
         //LED1
           if(`NIRS_PPG_CTRL_CFG.en_config_led1 === 1'b1)begin
             drive_nirs_if_from_cfg_leds(top_test_cfg.ch,top_test_cfg.num_leds);
           end
         //`nnc_info("PPG_TEST",$sformatf("DUT_IF: h18_16=%0d h15_8=%0d h7_0=%0d l7_0=%0d",
         //           `DUT_IF.threshold_h_18_16,
         //           `DUT_IF.threshold_h_15_8,
         //           `DUT_IF.threshold_h_7_0,
         //           `DUT_IF.threshold_l_7_0),NNC_LOW);


         //5. Write registers for this channel
          if(`NIRS_PPG_CTRL_CFG.en_config_led0 === 1'b1)begin
             configure_nirs_ctrl_regs(top_test_cfg.ch, top_test_cfg.num_leds);
          end
          if(`NIRS_PPG_CTRL_CFG.en_config_led1 === 1'b1)begin
             configure_nirs_ctrl_regs(top_test_cfg.ch, top_test_cfg.num_leds);
          end 
         `nnc_info("PPG_TEST",$sformatf("Configured channel %0d with unique register values", top_test_cfg.ch),NNC_LOW);    
       end //8 channel configuration
    end //led0,led1 config 


    //Enable TB checker for D2A_ADJ0_REG
    `NIRS_PPG_IF.nirs_d2a_spi_adj0_regs_check_en = 1'b1;
    //`NIRS_PPG_IF.nirs_8ch_d2a_spi_adj_regs_check_en = 1'b1;

    receiver_master_cont_typ_mode_en_on_test_operation();

    #10ms;




//    //6.send command
//    nirs_start_cmd_mcu_master_single_mode(/*top_test_cfg.ch, top_test_cfg.num_leds*/);
//
//    //7. wait for Data ready interrupt
//    `nnc_info("PPG_TEST",$sformatf("nirs_int_pin_en %0h (==0 don't output to pin, ==1 output INT pin) ", `NIRS_PPG_CTRL_CFG.nirs_int_pin_en),NNC_LOW); 
//     //for( int ch_n =0 ; ch_n <8; ch_n++)begin
//        //automatic int local_ch = ch_n; 
//       
//         //`nnc_info("PPG_TEST",$sformatf("channel enable to detect interrupt channel_enable_reg = %0h, local_ch = %0d ", `NIRS_PPG_IF..ch_en_mask,local_ch),NNC_LOW);
//         //if(`NIRS_PPG_IF.ch_en_mask[ch_n])begin            
//            //fork 
//              //begin
//                //`nnc_info("PPG_TEST",$sformatf("channel enable to detect interrupt local_ch =%0d, ch_en_mask[%0d]= %0h) ", local_ch, local_ch, `NIRS_PPG_IF..ch_en_mask[local_ch]),NNC_LOW);
//                 //top_test_cfg.temp_num_ch_en++;
//                 //monitor_nirs_interrupt(8'h1, local_ch, top_test_cfg.temp_num_ch_en); 
//              //end
//            //join_none
//         //end
//     //end
//
//     fork
//       `nnc_info("PPG_TEST",$sformatf("channel enable to detect interrupt channel_enable_reg = %0h\n", `NIRS_PPG_IF.ch_en_mask),NNC_LOW);
//
//       begin
//         if(`NIRS_PPG_IF.ch_en_mask[0] === 1'b1) begin
//           `nnc_info("PPG_TEST",$sformatf("channel enable to detect interrupt  CH0= %0h \n", `NIRS_PPG_IF.ch_en_mask[0]),NNC_MEDIUM);
//            monitor_nirs_interrupt(top_test_cfg.temp_num_ch_en, `NIRS_PPG_IF.ch_en_mask, 0);  
//         end
//       end //CH0
//
//       begin
//         if(`NIRS_PPG_IF.ch_en_mask[1] === 1'b1) begin
//           `nnc_info("PPG_TEST",$sformatf("channel enable to detect interrupt  CH1= %0h \n", `NIRS_PPG_IF.ch_en_mask[1]),NNC_MEDIUM);
//            monitor_nirs_interrupt(top_test_cfg.temp_num_ch_en, `NIRS_PPG_IF.ch_en_mask,1);  
//         end
//       end  //CH1
//
//       begin
//         if(`NIRS_PPG_IF.ch_en_mask[2] === 1'b1) begin
//           `nnc_info("PPG_TEST",$sformatf("channel enable to detect interrupt  CH2= %0h \n", `NIRS_PPG_IF.ch_en_mask[2]),NNC_MEDIUM);
//            monitor_nirs_interrupt(top_test_cfg.temp_num_ch_en,`NIRS_PPG_IF.ch_en_mask,2);  
//         end
//       end  //CH2
//
//       begin
//         if(`NIRS_PPG_IF.ch_en_mask[3] === 1'b1) begin
//           `nnc_info("PPG_TEST",$sformatf("channel enable to detect interrupt  CH3= %0h \n", `NIRS_PPG_IF.ch_en_mask[3]),NNC_MEDIUM);
//            monitor_nirs_interrupt(top_test_cfg.temp_num_ch_en, `NIRS_PPG_IF.ch_en_mask,3);  
//         end
//       end  //CH3
//
//       begin
//         if(`NIRS_PPG_IF.ch_en_mask[4] === 1'b1) begin
//           `nnc_info("PPG_TEST",$sformatf("channel enable to detect interrupt  CH4= %0h \n", `NIRS_PPG_IF.ch_en_mask[4]),NNC_MEDIUM);
//            monitor_nirs_interrupt(top_test_cfg.temp_num_ch_en, `NIRS_PPG_IF.ch_en_mask,4); 
//         end
//       end  //CH4
//
//       begin
//         if(`NIRS_PPG_IF.ch_en_mask[5] === 1'b1) begin
//           `nnc_info("PPG_TEST",$sformatf("channel enable to detect interrupt  CH5= %0h \n", `NIRS_PPG_IF.ch_en_mask[5]),NNC_MEDIUM);
//            monitor_nirs_interrupt(top_test_cfg.temp_num_ch_en, `NIRS_PPG_IF.ch_en_mask,5);  
//         end
//       end  //CH5
//
//       begin
//         if(`NIRS_PPG_IF.ch_en_mask[6] === 1'b1) begin
//           `nnc_info("PPG_TEST",$sformatf("channel enable to detect interrupt  CH6= %0h \n", `NIRS_PPG_IF.ch_en_mask[6]),NNC_MEDIUM);
//            monitor_nirs_interrupt(top_test_cfg.temp_num_ch_en, `NIRS_PPG_IF.ch_en_mask,6);  
//         end
//       end  //CH7
//
//       begin
//         if(`NIRS_PPG_IF.ch_en_mask[7] === 1'b1) begin
//           `nnc_info("PPG_TEST",$sformatf("channel enable to detect interrupt  CH7= %0h \n", `NIRS_PPG_IF.ch_en_mask[7]),NNC_MEDIUM);
//            monitor_nirs_interrupt(top_test_cfg.temp_num_ch_en, `NIRS_PPG_IF.ch_en_mask,7);  
//         end
//       end  //CH8
//
//     join
//    
//    //8. read data all channels data
//    read_nirs_idac_data;
//
//
//    //9.clear interrupt status 
//    clear_interrupt_status(`NIRS_PPG_IF.gen_reg_int_clr_typ);

/*   `nnc_info("PPG_TEST",$sformatf("top_test_cfg.ch_en_mask=%0h",top_test_cfg.ch_en_mask),NNC_LOW); 
   `nnc_info("PPG_TEST",$sformatf("define num_of_leds in loop =%0h",top_test_cfg.num_of_leds_loop ),NNC_LOW); 
  
    //clear if any interrupts
    top_test_cfg.first_time_config = 1'b1; 
    `nnc_info("PPG_TEST",$sformatf("for common nirs reg configuration first_time_config=%0h",top_test_cfg.first_time_config),NNC_LOW); 

    for(top_test_cfg.num_leds =0; top_test_cfg.num_leds < top_test_cfg.num_of_leds_loop; top_test_cfg.num_leds++ )begin  //led0 led1
        top_test_cfg.temp_en_config_leds = (2**top_test_cfg.num_leds);
         `nnc_info("PPG_TEST",$sformatf("temp_en_config_leds[1:0]=%0h",top_test_cfg.temp_en_config_leds ),NNC_LOW);

        for (top_test_cfg.ch = 0; top_test_cfg.ch < 1; top_test_cfg.ch++) begin  //ch0 to ch7
           bit ch_en = top_test_cfg.ch_en_mask[top_test_cfg.ch];
          
           `nnc_info("PPG_TEST",$sformatf("channel_number=%0d, ch_en=%0h",top_test_cfg.ch, ch_en),NNC_LOW);
   
          // // 1. Randomize a fresh configuration for this channel
          assert(`NIRS_PPG_CTRL_CFG.randomize() with{nirs_ppg_mode_sel == 'h4;
                                                     threshold_h_18_16 == 'h0;
                                                     threshold_h_15_8  == 'h0; 
                                                     threshold_h_7_0 inside {[0:10]};
                                                     threshold_l_7_0 inside {[0:10]};
                                                     en_config_led0 ==  top_test_cfg.temp_en_config_leds[0] ; //'h1; // led0 and led1 configuration one by one to have different random value
                                                     en_config_led1 ==  top_test_cfg.temp_en_config_leds[1]; //'h0; // led0 and led1 configuration one by one to have different random value
                                                     nirs_ppg_led_signle_en == 'h0;
                                                     idac_min_int_en == 'h1;
                                                     idac_max_int_en == 'h1;
                                                     iref_fine_on_not_off_en == 'h1;
                                                     iref_fine_not_on_en == 'h1;
                                                     iref_coarse_en == 'h1;
                                                     data_ready_en == 'h1;
                                                     idac_en == 'h1;
                                                     //debug_channel == (top_test_cfg.ch +1'b1);
                                                     //debug_led     == top_test_cfg.num_leds;
                                                    });

       
          `nnc_info("PPG_TEST",$sformatf("nirs pgg base test top_test_cfg: h18_16=%0d h15_8=%0d h7_0=%0d l7_0=%0d",
                    `NIRS_PPG_CTRL_CFG.threshold_h_18_16,
                    `NIRS_PPG_CTRL_CFG.threshold_h_15_8,
                    `NIRS_PPG_CTRL_CFG.threshold_h_7_0,
                    `NIRS_PPG_CTRL_CFG.threshold_l_7_0),NNC_LOW);

          `nnc_info("PPG_TEST",$sformatf("nirs pgg base test nirs_ppg_led_signle_en =%0h, nirs_ppg_mode_sel=%0h", `NIRS_PPG_CTRL_CFG.nirs_ppg_led_signle_en,`NIRS_PPG_CTRL_CFG.nirs_ppg_mode_sel),NNC_LOW);

          //2.Configure only once common regs after randomization
          if(top_test_cfg.first_time_config === 1'b1)begin
            //1.nirs_clk_reg
            config_nirs_clk_ctrl_reg;
            //2. configure control led register
            //config_nirs_ctrl_led_reg;
            //3.
            config_nirs_adj0_reg;    
            //4.configure channel enable register
            config_nirs_channel_en_reg(top_test_cfg.ch_en_mask);
            //5.
            config_nirs_intr_en_reg;
            //6.
            config_nirs_ctrl_mode_reg; 
           `nnc_info("PPG_TEST","Disable common regs configuration for each loop",NNC_LOW);
            top_test_cfg.first_time_config =1'b0; 
            `nnc_info("PPG_TEST",$sformatf("for common nirs reg configuration first_time_config=%0h",top_test_cfg.first_time_config),NNC_LOW);
          end
      
          //2.aconfigure control led register
          config_nirs_ctrl_led_reg;

 
          ////3. Enable only this channel
          //`NIRS_PPG_CTRL_CFG.en_config_ch0 =  //(top_test_cfg.ch == 0) && ch_en;
          //`NIRS_PPG_CTRL_CFG.en_config_ch1 =  //(top_test_cfg.ch == 1) && ch_en;
          //`NIRS_PPG_CTRL_CFG.en_config_ch2 =  //(top_test_cfg.ch == 2) && ch_en;
          //`NIRS_PPG_CTRL_CFG.en_config_ch3 =  //(top_test_cfg.ch == 3) && ch_en;
          //`NIRS_PPG_CTRL_CFG.en_config_ch4 =  //(top_test_cfg.ch == 4) && ch_en;
          //`NIRS_PPG_CTRL_CFG.en_config_ch5 =  //(top_test_cfg.ch == 5) && ch_en;
          //`NIRS_PPG_CTRL_CFG.en_config_ch6 =  //(top_test_cfg.ch == 6) && ch_en;
          //`NIRS_PPG_CTRL_CFG.en_config_ch7 =  //(top_test_cfg.ch == 7) && ch_en;
  
          //`nnc_info("PPG_TEST",$sformatf("nirs pgg base test en_config_ch0=%0h, en_config_ch1=%0h, en_config_ch2=%0h, en_config_ch3=%0h, en_config_ch4=%0h, en_config_ch5=%0h, en_config_ch6=%0h, en_config_ch7=%0h ",
          // `NIRS_PPG_CTRL_CFG.en_config_ch0,
          // `NIRS_PPG_CTRL_CFG.en_config_ch1,
          // `NIRS_PPG_CTRL_CFG.en_config_ch2,
          // `NIRS_PPG_CTRL_CFG.en_config_ch3,
          // `NIRS_PPG_CTRL_CFG.en_config_ch4,
          // `NIRS_PPG_CTRL_CFG.en_config_ch5,
          // `NIRS_PPG_CTRL_CFG.en_config_ch6,
          // `NIRS_PPG_CTRL_CFG.en_config_ch7),NNC_LOW);
 
         //3. STORE RANDOMIZED VALUES INTO EXPECTED MODEL for scoreboard/checker
         //3.a (LED0)
          if(`NIRS_PPG_CTRL_CFG.en_config_led0 === 1'b1)begin
           `nnc_info("PPG_TEST",$sformatf("nirs pgg base test Enabled LED0 REGS CONFIGURATION, en_config_led0=%0h", `NIRS_PPG_CTRL_CFG.en_config_led0),NNC_LOW);
            `NIRS_PPG_CTRL_CFG.compute_expected(top_test_cfg.ch,top_test_cfg.num_leds); 
          end

         //3.b (LED1)
         if(`NIRS_PPG_CTRL_CFG.en_config_led1 === 1'b1)begin
           `nnc_info("PPG_TEST",$sformatf("nirs pgg base test Enabled LED1 REGS CONFIGURATION, en_config_led1=%0h", `NIRS_PPG_CTRL_CFG.en_config_led1),NNC_LOW);
            `NIRS_PPG_CTRL_CFG.compute_expected(top_test_cfg.ch,top_test_cfg.num_leds); 
         end
         
         //4. Drive DUT/NIRS interface with this channel's config, debug purpose\
         //LED0
          if(`NIRS_PPG_CTRL_CFG.en_config_led0 === 1'b1)begin
           drive_nirs_if_from_cfg_leds(top_test_cfg.ch,top_test_cfg.num_leds);
         end
         //LED1
           if(`NIRS_PPG_CTRL_CFG.en_config_led1 === 1'b1)begin
             drive_nirs_if_from_cfg_leds(top_test_cfg.ch,top_test_cfg.num_leds);
           end
         //`nnc_info("PPG_TEST",$sformatf("DUT_IF: h18_16=%0d h15_8=%0d h7_0=%0d l7_0=%0d",
         //           `DUT_IF.threshold_h_18_16,
         //           `DUT_IF.threshold_h_15_8,
         //           `DUT_IF.threshold_h_7_0,
         //           `DUT_IF.threshold_l_7_0),NNC_LOW);


         //5. Write registers for this channel
          if(`NIRS_PPG_CTRL_CFG.en_config_led0 === 1'b1)begin
             configure_nirs_ctrl_regs(top_test_cfg.ch, top_test_cfg.num_leds);
          end
          if(`NIRS_PPG_CTRL_CFG.en_config_led1 === 1'b1)begin
             configure_nirs_ctrl_regs(top_test_cfg.ch, top_test_cfg.num_leds);
          end 
         `nnc_info("PPG_TEST",$sformatf("Configured channel %0d with unique register values", top_test_cfg.ch),NNC_LOW);    
       end //8 channel configuration
    end //led0,led1 config 

    //6.send command
   nirs_start_cmd_receiver_single_cont_mode;*/
    

 
 
    // --------------------------------------------------------
    // End of test and add any needed delay time 
    // --------------------------------------------------------
    #10000ns;
    `nnc_info("SOC_TEST", "soc_nirs_ppg_receiver_master_cont_typ_mode_en_on_test end now", NNC_LOW)

    // ----------------------------------------------------------------------------------
    // End of adding test 
    // ==================================================================================

    phase.drop_objection(this);
  endtask: main_phase

  task receiver_master_cont_typ_mode_en_on_test_operation();
        //6.send command
    nirs_start_cmd_receiver_single_cont_mode();

    //7. wait for Data ready interrupt
    `nnc_info("PPG_TEST",$sformatf("nirs_int_pin_en %0h (==0 don't output to pin, ==1 output INT pin) ", `NIRS_PPG_IF.nirs_int_pin_en),NNC_LOW); 
     //for( int ch_n =0 ; ch_n <8; ch_n++)begin
        //automatic int local_ch = ch_n; 
       
         //`nnc_info("PPG_TEST",$sformatf("channel enable to detect interrupt channel_enable_reg = %0h, local_ch = %0d ", `NIRS_PPG_IF..ch_en_mask,local_ch),NNC_LOW);
         //if(`NIRS_PPG_IF.ch_en_mask[ch_n])begin            
            //fork 
              //begin
                //`nnc_info("PPG_TEST",$sformatf("channel enable to detect interrupt local_ch =%0d, ch_en_mask[%0d]= %0h) ", local_ch, local_ch, `NIRS_PPG_IF..ch_en_mask[local_ch]),NNC_LOW);
                 //top_test_cfg.temp_num_ch_en++;
                 //monitor_nirs_interrupt(8'h1, local_ch, top_test_cfg.temp_num_ch_en); 
              //end
            //join_none
         //end
     //end

     // wait for couple of interrupts
     //repeat (16)begin
       fork
         `nnc_info("PPG_TEST",$sformatf("channel enable to detect interrupt channel_enable_reg = %0h\n", `NIRS_PPG_IF.ch_en_mask),NNC_LOW);

         begin
           if(`NIRS_PPG_IF.ch_en_mask[0] === 1'b1) begin
             `nnc_info("PPG_TEST",$sformatf("channel enable to detect interrupt  CH0= %0h \n", `NIRS_PPG_IF.ch_en_mask[0]),NNC_MEDIUM);
              monitor_nirs_interrupt(top_test_cfg.temp_num_ch_en, `NIRS_PPG_IF.ch_en_mask, 0);  
           end
         end //CH0

         begin
           if(`NIRS_PPG_IF.ch_en_mask[1] === 1'b1) begin
             `nnc_info("PPG_TEST",$sformatf("channel enable to detect interrupt  CH1= %0h \n", `NIRS_PPG_IF.ch_en_mask[1]),NNC_MEDIUM);
              monitor_nirs_interrupt(top_test_cfg.temp_num_ch_en, `NIRS_PPG_IF.ch_en_mask,1);  
           end
         end  //CH1

         begin
           if(`NIRS_PPG_IF.ch_en_mask[2] === 1'b1) begin
             `nnc_info("PPG_TEST",$sformatf("channel enable to detect interrupt  CH2= %0h \n", `NIRS_PPG_IF.ch_en_mask[2]),NNC_MEDIUM);
              monitor_nirs_interrupt(top_test_cfg.temp_num_ch_en,`NIRS_PPG_IF.ch_en_mask,2);  
           end
         end  //CH2

         begin
           if(`NIRS_PPG_IF.ch_en_mask[3] === 1'b1) begin
             `nnc_info("PPG_TEST",$sformatf("channel enable to detect interrupt  CH3= %0h \n", `NIRS_PPG_IF.ch_en_mask[3]),NNC_MEDIUM);
              monitor_nirs_interrupt(top_test_cfg.temp_num_ch_en, `NIRS_PPG_IF.ch_en_mask,3);  
           end
         end  //CH3

         begin
           if(`NIRS_PPG_IF.ch_en_mask[4] === 1'b1) begin
             `nnc_info("PPG_TEST",$sformatf("channel enable to detect interrupt  CH4= %0h \n", `NIRS_PPG_IF.ch_en_mask[4]),NNC_MEDIUM);
              monitor_nirs_interrupt(top_test_cfg.temp_num_ch_en, `NIRS_PPG_IF.ch_en_mask,4); 
           end
         end  //CH4

         begin
           if(`NIRS_PPG_IF.ch_en_mask[5] === 1'b1) begin
             `nnc_info("PPG_TEST",$sformatf("channel enable to detect interrupt  CH5= %0h \n", `NIRS_PPG_IF.ch_en_mask[5]),NNC_MEDIUM);
              monitor_nirs_interrupt(top_test_cfg.temp_num_ch_en, `NIRS_PPG_IF.ch_en_mask,5);  
           end
         end  //CH5

         begin
           if(`NIRS_PPG_IF.ch_en_mask[6] === 1'b1) begin
             `nnc_info("PPG_TEST",$sformatf("channel enable to detect interrupt  CH6= %0h \n", `NIRS_PPG_IF.ch_en_mask[6]),NNC_MEDIUM);
              monitor_nirs_interrupt(top_test_cfg.temp_num_ch_en, `NIRS_PPG_IF.ch_en_mask,6);  
           end
         end  //CH7

         begin
           if(`NIRS_PPG_IF.ch_en_mask[7] === 1'b1) begin
             `nnc_info("PPG_TEST",$sformatf("channel enable to detect interrupt  CH7= %0h \n", `NIRS_PPG_IF.ch_en_mask[7]),NNC_MEDIUM);
              monitor_nirs_interrupt(top_test_cfg.temp_num_ch_en, `NIRS_PPG_IF.ch_en_mask,7);  
           end
         end  //CH8

       join
    
       //8. read data all channels data
       read_nirs_idac_data;


       //9.clear interrupt status 
       clear_interrupt_status(`NIRS_PPG_IF.gen_reg_int_clr_typ, `NIRS_PPG_IF.nirs_int_pin_en);

     //end //repeat loop of "N"interrupts
  endtask
  // ------------------------------
  // Declare the report_phase task
  // ------------------------------
  function void report_phase(nnc_phase phase) ;
  super.report_phase(phase);
  endfunction

endclass : `TESTNAME
