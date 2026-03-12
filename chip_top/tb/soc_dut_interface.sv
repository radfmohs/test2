/*--------------------------------------------------------------------------------------
// Copyright 2021 Nanochap, Inc.
// All Rights Reserved Worldwide
//--------------------------------------------------------------------------------------
// File Name	: soc_dut_interface.sv                                                   
// Project	: Nanochap ENS2                                  		        
// Description	: SOC DUT Interface                                        
// Designer	: ddang@nanochap.com                                                                 
// Date		: 18-03-2024                                                                    
// Revision	: 0.1                                 
--------------------------------------------------------------------------------------*/
`ifndef SOC_DUT_INTERFACE
`define SOC_DUT_INTERFACE

interface dut_interface();

//////////////////////////////////////////////////////////////
// signals to be connected to DUT
//////////////////////////////////////////////////////////////

  // inputs of DUT
  wire  resetn;
  wire  soc_resetn; 
  wire  soc_resetn_chipA;
  wire  soc_resetn_chipB;

  // inout
  `ifndef FPGA
  `else
  `endif

//---------------------------------------
// GPIO
//---------------------------------------
  wire  alert;

  bit IOBUF_PAD_PULL_HIGH;
  bit assertion_on;

// bus signals
  bit [1:0]    testmode_sel;
  bit [1:0]    spimode_sel;
  bit [1:0]    altf_sel;
  bit [1:0]    altf_gpio_sel; 
  bit [10:0]   iopad_gpio;
  logic [1:0]  TCK_SEL;

  logic [2:0]  pclk_sel;
  logic [3:0]  iclk_sel;
  logic        int_clk_out;
  logic [15:0] otp_tPGM;     
  logic [15:0] otp_tVPP; 
  logic [15:0] high_clk;  
  logic [15:0] low_clk;  

  logic [15:0] spi_sclk_freq;         // unit is Khz (1Khz to 16.000Khz)
  logic [6:0]  spi_clk_jitter;        // unut is percentage (0-100)
  logic [6:0]  spi_sclk_jitter;       // unut is percentage (0-100)

  logic [15:0] tcssc;   
  logic [15:0] tsccs;                 // min is 17ns
  logic [15:0] tcsh;                  // min is 2 tcks (1/spi_clk)
  logic [6:0]  tdist;                 // min is 10ns
  logic [6:0]  tch;

  integer      err_cnt;
  logic        print_msg_disable;

  bit	       fault_stuck0_clk_en;   // 1: internal 32KHZ and 300KHZ will be LOW (can used when we set ext_clk_en)	

  bit 	       ext_clk_en;	      // 1: external driven to ENS2 from external clock
  logic [6:0]  hfosc_jitter;
  logic [6:0]  hfosc_variation;

  logic        hfosc_fixed_gnd_en;
  logic        ext_hfosc_fixed_gnd_en;

  logic [1:0]  bistm_freq_sel;
  logic [15:0] bistm_freq;
  integer      bistm_tPGM_RC;
  integer      bistm_tPGM;
   
  bit          config_in_base_test_en;


  bit   [2:0]  wg_drv_sel;	      //to select among 8 wavegen drivers
  logic [31:0] hlf_wave_per;          //half wave period setting of waveform

  bit          dont_check_conf_first_en;

  bit          sys_clk;
  bit          wait_reset_en;

  bit   [1:0]  A2D_comp_sel;	      //select the A2D_comp for lead_off_detection
  bit   [1:0]  A2D_stim_sel;	      //select the A2D_stim for short_detection
  bit          bist_vpp_pin_en;       //control vpp by bist_vpp_en or timing
  bit          pinmux_mode;           // pinmux mode

  //wavegen interface
  logic [7:0]  hex_data_a[128];       // data of points in hex files for driver A
  logic [7:0]  hex_data_b[128];       // data of points in hex files for driver B
  logic [7:0]  wave_data_a;      // data of points in real files for driver A
  logic [7:0]  wave_data_b;      // data of points in real files for driver B
  logic [7:0]  no_of_point_a;
  logic [7:0]  no_of_point_b;
  logic [7:0]  wave_addr[2];
  logic        pos_neg_from_same_addr;    
  logic        load_wave_data_till_points;    
  logic [2:0]  no_of_waveforms;    
  logic [1:0]  preload_sel; 
  logic [7:0]  point_cfg_val;
  logic [2:0]  points_sel;
  logic        neg_ena;    
  logic        pos_ena;
  logic        pos_neg;
  logic        daca_bit_len_sel; 
  logic        dacb_bit_len_sel; 
  logic        stop_check[`WAVEGEN_NUM_OF_DRIVERS];
  logic        manual_mode;
  logic [11:0] spi_reg1;
  logic [11:0] spi_reg2; 
  logic [11:0] ana_data1;
  logic [11:0] ana_data2; 
  logic [7:0]  neg_scale;
  logic [7:0]  pos_scale; 
  logic [7:0]  neg_offest;
  logic [7:0]  pos_offest;
  logic [7:0]  tmp_pos;
  logic [7:0]  tmp_neg;   
  logic [7:0]  pulse_data; 
  //logic        pulla;
  //logic        pullb;
  //logic        sourcea;
  //logic        sourceb;
  logic        scale_en = 0;
  logic        dac_bit_len_sel_drv0; 
  logic        dac_bit_len_sel_drv1; 
           
  logic        mult_chip_en;
  logic [1:0]  mult_chip_mode;
  logic        mult_chip_same_clk_en;
 
  logic        noperiod = 0;
  logic [1:0]  noperiod_pos_neg_sel;//00: set pos_period 0 or pos disabled; 01: set neg_period 0 or neg disabled; 1X: pos & neg both enabled
  logic [2:0]  bitsel;
  logic        A2D_comp0_in;
  logic        A2D_comp1_in;
  logic        A2D_comp_stim0_1_in;
  logic        A2D_comp_stim2_3_in;
  logic        D2A_comp_stim0_1_sel;
  logic        D2A_comp_stim2_3_sel;

  logic        swap_sdf_en;
  logic [7:0]  wavegen_no_of_chips = `WAVEGEN_NUM_OF_MULT_CHIPS;
  logic [7:0]  wavegen_no_of_drv = `WAVEGEN_NUM_OF_DRIVERS;

  logic [15:0] otp_tPGM;
  logic [15:0] otp_tVPP;
  logic        otp_program_en;
  logic [7:0]  otp_vpp_delay;

  logic [14:0] gpio_pu_en;      // 14: RESET, [13:12]: TESTMODE, 11: CLKSEL, [10:0]: GPI0 
  logic [14:0] gpio_pd_en;      // 14: RESET, [13:12]: TESTMODE, 11: CLKSEL, [10:0]: GPI0 

  logic        PULLAB_pos_en[`WAVEGEN_NUM_OF_DRIVERS];
  logic        PULLAB_neg_en[`WAVEGEN_NUM_OF_DRIVERS];
  logic [5:0]  PULLAB_lim[`WAVEGEN_NUM_OF_DRIVERS];
  logic [15:0] DELAY_lim[`WAVEGEN_NUM_OF_DRIVERS];

  logic        stop_wave1;
  logic        stop_wave2;
  logic        clk_per_point_short;//for wg scb
  logic        clk_per_point_short_dac0;//for drv0 py tb
  logic        clk_per_point_short_dac1;//for drv1 py tb

  //logic [31:0] ch1_addr_range;
  //logic [31:0] ch2_addr_range;

  logic [39:0] reg_normal[`NORMAL_REG_NUM];
  logic [39:0] reg_wavegen[`WAVEGEN_DRIVER_OFFSET*`WAVEGEN_DRIVER_NUM];
       
  logic        INTB;
  logic [8:0]  wavegen_sample_num_per_period;//for chip0
  logic [8:0]  wavegen_sample_num_per_period_chip1;//for chip1
  integer      python_length;//for chip0
  integer      python_length_chip1;//for chip1
  logic [31:0] python_data_dac0[16192];
  logic [31:0] python_data_dac1[16192];
  logic        python_check_en;
  logic        python_wavegen_en;
 
  logic [1:0]  waveshape_sel;

  logic [31:0] wg_hlf_wave0_lim[`WAVEGEN_NUM_OF_DRIVERS]; // number of clocks per point for positive half wave0
  logic [31:0] wg_neg_hlf_wave0_lim[`WAVEGEN_NUM_OF_DRIVERS]; // number of clocks per point for negative half wave0
  logic [31:0] wg_hlf_wave1_lim[`WAVEGEN_NUM_OF_DRIVERS]; // number of clocks per point for positive half wave1
  logic [31:0] wg_neg_hlf_wave1_lim[`WAVEGEN_NUM_OF_DRIVERS]; // number of clocks per point for negative half wave1
  logic [31:0] wg_hlf_wave2_lim[`WAVEGEN_NUM_OF_DRIVERS]; // number of clocks per point for positive half wave2
  logic [31:0] wg_neg_hlf_wave2_lim[`WAVEGEN_NUM_OF_DRIVERS]; // number of clocks per point for negative half wave2
  logic [15:0] wg_rest_wave0_lim[`WAVEGEN_NUM_OF_DRIVERS]; // number of clocks for each rest period wave0
  logic [31:0] wg_silent_wave0_lim[`WAVEGEN_NUM_OF_DRIVERS]; // number of clocks for each silent period wave0
  logic [15:0] wg_rest_wave1_lim[`WAVEGEN_NUM_OF_DRIVERS]; // number of clocks for each rest period wave1
  logic [31:0] wg_silent_wave1_lim[`WAVEGEN_NUM_OF_DRIVERS]; // number of clocks for each silent period wave1
  logic [15:0] wg_rest_wave2_lim[`WAVEGEN_NUM_OF_DRIVERS]; // number of clocks for each rest period wave2
  logic [31:0] wg_silent_wave2_lim[`WAVEGEN_NUM_OF_DRIVERS]; // number of clocks for each silent period wave2
  logic [7:0]  wg_drv_ctrl;
  logic [7:0]  wg_drv_cfg;
  logic [7:0]  wg_drv_pnt_cfg;
  logic [20:0] wg_drive;

  logic        io_model_check_off;
  bit          VPP;
  logic        spi_o_clk_sel;
  logic [1:0]  mult_chip_typ;
  logic        rest_en;
  logic        silent_en;
  logic        alt_en;

  logic [31:0]  lead_off_level_tgt; 
  logic         lead_off_stop_en_ch0;
  logic         lead_off_stop_en_ch1;
  logic         lead_off_ch0_comp_low_active;
  logic         lead_off_ch1_comp_low_active;
  logic         lead_off_pulse_int_en;
  logic         lead_off_level_int_en;
  logic [31:0]  lead_off_tgt_dly_dac0;
  logic [31:0]  lead_off_tgt_dly_dac1;
  logic [7:0]   lead_off_tgt;
  logic [1:0]   lead_off_dac_sel;
  logic [1:0]   lead_off_check_mode;
  logic         lead_off_comp_reverse = 0;
  logic         lead_off_dly_en;
  logic [31:0] lead_off_timer_cnt_dac0;
  logic [31:0] lead_off_timer_cnt_dac1;
  logic [31:0] lead_off_counter_th_dac0;
  logic [31:0] lead_off_counter_th_dac1;
  logic        lead_off_ch0_int_en;
  logic        lead_off_ch1_int_en;
  logic        short_detect_by_lead_off_en=0;
  logic        lead_off_detect_by_short_circuit_en=0;

  logic        anac_stim_CH1_intr_en;//short detect interrupt enable
  logic        anac_stim_CH2_intr_en;//short detect interrupt enable
  logic        anac_stim_CH1_pol;//anac stim input polarity level to detect short
  logic        anac_stim_CH2_pol;//anac stim input polarity level to detect short
  logic [31:0] anac_short_CH1_timer_TH;//anac timer threshold
  logic [31:0] anac_short_CH2_timer_TH;//anac timer threshold
  logic [31:0] anac_short_CH1_counter_TH;//anac counter threshold
  logic [31:0] anac_short_CH2_counter_TH;//anac counter threshold
  logic [7:0]  counter_percent_of_timer_TH1;
  logic [7:0]  counter_percent_of_timer_TH2;
  logic [31:0] no_of_cycles_CH1;
  logic [31:0] no_of_cycles_CH2;
  logic        ana_stimu_ch1_intr_sts_clr;
  logic        ana_stimu_ch2_intr_sts_clr;
  logic [31:0] expected_short_ch1_timer_th_cnt=32'h0;
  logic [31:0] expected_short_ch2_timer_th_cnt=32'h0;
  logic [31:0] expected_short_ch1_resp_th_cnt=32'h0;
  logic [31:0] expected_short_ch2_resp_th_cnt=32'h0;
  //logic [1:0]  wavegen_en; //14/07/2025 Pending to get from testcase
  logic [1:0]  wg_enable;
  logic        expected_anac_short_ch1_timer_th_cnt_flag = 1'b0;
  logic        expected_anac_short_ch2_timer_th_cnt_flag = 1'b0;
  logic        expected_short_ch1_resp_cnt_en;
  logic        expected_short_ch2_resp_cnt_en;

  logic [31:0] expected_leadoff_ch0_timer_th_cnt=32'h0;
  logic [31:0] expected_leadoff_ch1_timer_th_cnt=32'h0;
  logic [31:0] expected_leadoff_ch0_resp_th_cnt=32'h0;
  logic [31:0] expected_leadoff_ch1_resp_th_cnt=32'h0;
  logic        expected_leadoff_ch0_timer_th_cnt_flag = 1'b0;
  logic        expected_leadoff_ch1_timer_th_cnt_flag = 1'b0;
  logic        expected_ch0_leadoff_en;
  logic        expected_ch1_leadoff_en;
  logic        A2D_COMP_OUT_CH1;    
  logic        A2D_COMP_OUT_CH2;    
  logic        A2D_COMP_OUT_CH1_tmp; 
  logic        A2D_COMP_OUT_CH2_tmp;
  logic [31:0] dut_short_ch1_timer_th_cnt;  
  logic [31:0] dut_short_ch2_timer_th_cnt;  
  logic [31:0] dut_short_ch1_counter_th_cnt;
  logic [31:0] dut_short_ch2_counter_th_cnt;
  logic [31:0] dut_timer_cnt_cnt_dac0;	    
  logic [31:0] dut_timer_cnt_cnt_dac1;       
  logic [31:0] dut_lead_off_Counter_cnt_dac0;
  logic [31:0] dut_lead_off_Counter_cnt_dac1;
  logic        dut_ana_stimu_ch1_intr_sts;
  logic        dut_ana_stimu_ch2_intr_sts;
  logic        leadoff_pclk;
  logic        leadoff_presetn;
  logic        anac_pclk;
  logic        anac_presetn;
  logic        anac_short_ch1_wg_enable; //SB internally used signal
  logic        anac_short_ch1_wg_enable_d1;
  logic        anac_short_ch1_wg_enable_d2;
  logic        anac_short_ch2_wg_enable; //SB internally used signal
  logic        anac_short_ch2_wg_enable_d1;
  logic        anac_short_ch2_wg_enable_d2;
  logic        expected_anac_ch1_a2d_comp;
  logic        expected_anac_ch2_a2d_comp;
  logic        expected_short_ch1_resp_cnt_en_d1;
  logic        expected_short_ch1_resp_cnt_en_d2;
  logic        expected_short_ch2_resp_cnt_en_d1;
  logic        expected_short_ch2_resp_cnt_en_d2;
  logic [1:0]  lead_off_wg_enable;
  logic        flag_to_dtct_ch1_false_short=1'b0;
  logic        flag_to_dtct_ch2_false_short=1'b0;
  logic        flag_ch1_flase_short_en = 1'b0;
  logic        flag_ch2_flase_short_en = 1'b0;
  logic        flag_to_dtct_ch0_false_leadoff=1'b0;
  logic        flag_to_dtct_ch1_false_leadoff=1'b0;
  logic        flag_ch0_flase_leadoff_en = 1'b0;
  logic        flag_ch1_flase_leadoff_en = 1'b0;
  logic        A2D_COMP_OUT_CH1_d1;      
  logic        A2D_COMP_OUT_STIMU0_1_d1;
  logic        A2D_COMP_OUT_CH2_d1;      
  logic        A2D_COMP_OUT_STIMU2_3_d1;
  logic        A2D_COMP_OUT_CH1_d2;      
  logic        A2D_COMP_OUT_STIMU0_1_d2;
  logic        A2D_COMP_OUT_CH2_d2;      
  logic        A2D_COMP_OUT_STIMU2_3_d2;
  logic        lead_off_ch0_wg_enable_d1;
  logic        lead_off_ch0_wg_enable_d2;
  logic        lead_off_ch1_wg_enable_d1;
  logic        lead_off_ch1_wg_enable_d2;
  logic        lead_off_ch0_wg_enable;
  logic        lead_off_ch1_wg_enable;
  logic        dut_leadoff_ch0_intr_sts;
  logic        dut_leadoff_ch1_intr_sts;
  logic        pulla[`WAVEGEN_DRIVER_NUM];
  logic        pullb[`WAVEGEN_DRIVER_NUM];
  logic        sourcea[`WAVEGEN_DRIVER_NUM];
  logic        sourceb[`WAVEGEN_DRIVER_NUM];

  
  logic [7:0]  no_of_anac_interrupts;
  logic        lead_off_en;
  logic        short_en;
  logic [1:0]  register_val_ch1;
  logic [1:0]  register_val_ch2;
  logic [31:0] a2d_comp_delay_ch1;
  logic [31:0] a2d_comp_delay_ch2;

  logic [1:0]  pulse_after_source;
  logic [31:0] pulse_after_source_delay;

  logic        int_active_level_high_or_low; // 1: intr active high, 0 : intr active low
  logic        clear_intr_manual_or_auto; // 0: manually clear intr by w1c, 1 : auto clear intr by r1c
  logic        intr_length_slct_level_or_pulse; // 0: level INT, 1: pulse INT
  logic [2:0]  lvd_sel;
  logic [2:0]  lvd_en;

  logic [2:0]  vbat_level; 
  logic [7:0]  sensor_temperature;
  logic        leadoff_pos_neg_sel_CH1;
  logic        leadoff_pos_neg_sel_CH2;
  logic        tsc_comp_low_active_en;
  logic [1:0]  short_leadoff_counter_cnt_debug_sel;
  logic [31:0] dut_short_leadoff_counter_cnt_debug;
  logic [31:0] exp_short_leadoff_counter_cnt_debug;

  logic [31:0] short_ch0_counter_cnt_debug;
  logic [31:0] short_ch1_counter_cnt_debug;
  logic [31:0] leadoff_ch0_counter_cnt_debug;
  logic [31:0] leadoff_ch1_counter_cnt_debug;
  logic        short_leadoff_debug_counter_check_en = 1;
  logic        anac_short_CH1_en;
  logic        anac_short_CH2_en;
  logic        otp_ignore_check_en;

  // EEG filter related configs 
  logic [3:0] cic_rate;
  logic       imeas_en;
  logic       imeas_rst;
  logic       imeas_adc_inv;
  logic [1:0] input_format;
  logic [1:0] output_format;
  logic [2:0] cmd;
  logic [15:0]stable_time;
  logic [3:0] imeas_data_sel;
  logic       single_shot_en;

  logic [31:0] exp_chdata[`FILTER_NUM-1:0] ;
  logic [31:0] exp_chdata_dev2[`FILTER_NUM-1:0] ;

  logic [31:0] imeas_adc_freq;
  logic [15:0] imeas_osr;
  logic [31:0] imeas_samp_rate;
  logic        iclk_pmu_ctrl_en;
  logic        imeas_sin_gen_en;
  logic        imeas_noise_gen_en;
  logic [31:0] imeas_sin_freq_unit;
  logic [31:0] imeas_sin_expected_freq;
  logic [31:0] imeas_sin_no_clk_per_period;
  logic [11:0] imeas_sample_num_per_period;

  logic [31:0] python_imeas_length;
  logic [`ONE_IMEAS_SIZE-1:0]   imeas_data[`FILTER_NUM];

  logic [31:0] python_filter_length;
  logic [`ONE_IMEAS_SIZE-1:0]   filter_data[`FILTER_NUM];

  logic        python_imeas_en = 0;

  logic        adc_clk;
  logic        eeg_int_sts_en;
  logic        eeg_int_en;
  logic        daisy_en;
  logic [31:0] no_of_samples_rcvd; 
  logic [2:0]  no_of_adc_dev1; 
  logic [2:0]  no_of_adc_dev2; 
  logic [`FILTER_NUM-1:0]imeas_en_dis_ch;
  logic        rd_data_cmd_in_progress = 0;
  logic        imeas_pos_done;
  logic        imeas_overlap_en;
  logic        imeas_status_en;
  logic        imeas_24bitdata_en;
  logic [31:0] no_of_samples; 
  logic [31:0] filter_data_out[`FILTER_NUM-1:0] ;
  logic [31:0] filter_data_out_dev2[`FILTER_NUM-1:0] ;
  logic        filter_case;

  logic [4:0]  max_ch_dev1; 
  logic [4:0]  max_ch_dev2; 
  logic [1:0]  total_chip_num; 

  logic        filter_python_check_en = 0;
  logic [31:0] stopband_cut_off_freq = 32'h1000;
  logic [31:0] passband_cut_off_freq = 32'h2000;
  logic [31:0] hpf_fc = 1;

  // notch filter related
  logic [`FILTER_NUM-1:0] notch_filter_en_per_ch = 16'hFFFF;
  logic [`FILTER_NUM-1:0] notch_filter_data_gone ;
  logic [31:0]            notch_coeff_index_select;
  logic [`FILTER_NUM-1:0] notch_clk ;

  //lpf
  logic [`FILTER_NUM-1:0] lpf_filter_en_per_ch = 16'hFFFF ;
  logic [31:0]            lpf_coeff_index_0_select;
  logic [31:0]            lpf_coeff_index_1_select;
  logic [`FILTER_NUM-1:0] lpf_clk ;

  //hpf
  logic [`FILTER_NUM-1:0] hpf_filter_en_per_ch = 16'hFFFF ;
  logic [31:0]            hpf_coeff_index_0_select;
  logic [31:0]            hpf_coeff_index_1_select;
  logic [`FILTER_NUM-1:0] hpf_clk ;

  logic        notch_enable = 0;
  logic        lpf_enable = 0;
  logic        hpf_enable = 0;

  logic [31:0] nirs_irefcoarse_length;
  logic [31:0] nirs_irefcoarse_iref_delay;
  logic [31:0] nirs_ireffine_length; 

  logic [2:0]  dump_level; 
  logic [1:0]  OTP_SEL;

  

endinterface: dut_interface
`endif

