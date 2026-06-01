 # ------------------------------------------------------------------------------
 # Purpose : Synthesis Script - Clocks and Constraints
 #
 # ------------------------------------------------------------------------------
 
 # ------------------------------------------------------------------------------
 # Define the clocks in the $rm_project_top
 # ------------------------------------------------------------------------------
 
 # Declares the clocks present in the design with period, uncertainty and
 # latency information for synthesis:
 #
 #   Period      - Describes the frequency to be acheieved by synthesis.
 #
 #   Uncertainty - Describes all parameters that could influence the difference
 #                 in clock timing between two related flops. Since jitter is
 #                 explicitly mentioned this will include OCV, skew and margin.
 #
 #   Latency     - Describes the delay in the clock tree from the core clock pin
 #                 to the flop clock pin; at this point it is an estimate.
 
 #set hfosc_period       [expr {15.625}]      	; # 64 MHz     
 set hfosc_period       [expr {110}]      	; # 9 MHz 
 set extclk_period      [expr {110}] 	    	; # 9 MHz
 set spiclk_period      [expr {55}]       	; # 18 MHz SPI
 set mbistclk_period    [expr {120}]       	; # 10 Mhz BIST cannot be achieved in max corner. eprom is slow

 set cycle90    [expr {0.90 * ${hfosc_period}}]
 set cycle80    [expr {0.80 * ${hfosc_period}}]
 set cycle70    [expr {0.70 * ${hfosc_period}}]
 set cycle60    [expr {0.60 * ${hfosc_period}}]
 set cycle50    [expr {0.50 * ${hfosc_period}}]
 set cycle40    [expr {0.40 * ${hfosc_period}}]
 set cycle30    [expr {0.30 * ${hfosc_period}}]
 set cycle20    [expr {0.20 * ${hfosc_period}}]
 set cycle10    [expr {0.10 * ${hfosc_period}}]

#internal clock only for normal mode
if {[string match S11?_m?? $i]} {
  # ================================================================================================================================
  # ===== sys_clk  
  # ================================================================================================================================
  create_clock -name sys_clk {u_top_ana_wrapper/u_top_ana/A2D_CLK8MHZ} -period $hfosc_period  -add
  set_clock_uncertainty -setup   [expr {0.05 * ${hfosc_period}}]     [get_clocks sys_clk]
  set_clock_uncertainty -hold    0.4      [get_clocks sys_clk]
  #set_case_analysis 0 [get_pins u_top_ana/A2D_EXTERNAL_EN_I]
  #set_case_analysis 0 [get_pins u_top_dig_always_on/u_clk_ctrl_always_on/DNT_ADC_CLK_INV/S0];#No need to create another scenario for this
  
  create_generated_clock -name notch_clk -add -divide_by 2 -master_clock sys_clk \
			-source [get_attribute [get_clocks sys_clk] sources] \
			[get_pins u_top_dig/u_clk_ctrl/notch_clk]
  set_clock_uncertainty -setup [expr {0.05 * ${hfosc_period} * 2}] [get_clocks notch_clk]
  set_clock_uncertainty -hold    0.4      [get_clocks notch_clk]

  create_generated_clock -name lpf_clk -add -divide_by 1 -master_clock sys_clk \
			-source [get_attribute [get_clocks sys_clk] sources] \
			[get_pins u_top_dig/u_clk_ctrl/lpf_clk]
  set_clock_uncertainty -setup [expr {0.05 * ${hfosc_period}}] [get_clocks lpf_clk]
  set_clock_uncertainty -hold    0.4      [get_clocks lpf_clk]
  
  create_generated_clock -name hpf_clk -add -divide_by 1 -master_clock sys_clk \
			-source [get_attribute [get_clocks sys_clk] sources] \
			[get_pins u_top_dig/u_clk_ctrl/hpf_clk]
  set_clock_uncertainty -setup [expr {0.05 * ${hfosc_period}}] [get_clocks hpf_clk]
  set_clock_uncertainty -hold    0.4      [get_clocks hpf_clk]

  create_generated_clock -name imeas_clk -add -divide_by 1 -master_clock sys_clk \
			-source [get_attribute [get_clocks sys_clk] sources] \
			[get_pins u_top_dig/u_clk_ctrl/imeas_dig_adc_clk]
  set_clock_uncertainty -setup [expr {0.05 * ${hfosc_period}}] [get_clocks imeas_clk]
  set_clock_uncertainty -hold    0.4      [get_clocks imeas_clk]
}

#external clock can support either normal mode (S12) or cp test mode (S22)
if {[string match S?2*_m?? $i]} {
  # ================================================================================================================================
  # ===== ext_clk  
  # ================================================================================================================================
  create_clock -name ext_clk {IOBUF_PAD[0]} -period $extclk_period  -add
  set_clock_uncertainty -setup   [expr {0.05 * ${extclk_period}}]     [get_clocks ext_clk]
  set_clock_uncertainty -hold    0.4      [get_clocks ext_clk]
  #set_case_analysis 0 [get_pins u_top_ana/A2D_EXTERNAL_EN_I]
  #set_case_analysis 0 [get_pins u_top_dig_always_on/u_clk_ctrl_always_on/DNT_ADC_CLK_INV/S0];#No need to create another scenario for this
}
#normal mode; ext clk
if {[string match S12?_m?? $i]} {
 create_generated_clock -name notch_clk -add -divide_by 2 -master_clock ext_clk \
			-source [get_attribute [get_clocks ext_clk] sources] \
			[get_pins u_top_dig/u_clk_ctrl/notch_clk]
  set_clock_uncertainty -setup [expr {0.05 * ${hfosc_period} * 2}] [get_clocks notch_clk]
  set_clock_uncertainty -hold 0.4 [get_clocks notch_clk]
  
  create_generated_clock -name lpf_clk -add -divide_by 1 -master_clock ext_clk \
			-source [get_attribute [get_clocks ext_clk] sources] \
			[get_pins u_top_dig/u_clk_ctrl/lpf_clk]
  set_clock_uncertainty -setup [expr {0.05 * ${hfosc_period}}] [get_clocks lpf_clk]
  set_clock_uncertainty -hold    0.4      [get_clocks lpf_clk]
  
  create_generated_clock -name hpf_clk -add -divide_by 1 -master_clock ext_clk \
			-source [get_attribute [get_clocks ext_clk] sources] \
			[get_pins u_top_dig/u_clk_ctrl/hpf_clk]
  set_clock_uncertainty -setup [expr {0.05 * ${hfosc_period}}] [get_clocks hpf_clk]
  set_clock_uncertainty -hold    0.4      [get_clocks hpf_clk]

   create_generated_clock -name imeas_clk -add -divide_by 1 -master_clock ext_clk \
			-source [get_attribute [get_clocks ext_clk] sources] \
			[get_pins u_top_dig/u_clk_ctrl/imeas_dig_adc_clk]
  set_clock_uncertainty -setup [expr {0.05 * ${hfosc_period}}] [get_clocks imeas_clk]
  set_clock_uncertainty -hold    0.4      [get_clocks imeas_clk]
}

#bist clock scenario
if {[string match S3_m?? $i]} {
  # ================================================================================================================================
  # ===== mbist_clk   
  # ================================================================================================================================
  create_clock -name mbist_clk [get_ports IOBUF_PAD[0]] -period $mbistclk_period  -add
  set_clock_uncertainty -setup   [expr {0.05 * ${mbistclk_period}}]     [get_clocks mbist_clk]
  set_clock_uncertainty -hold    0.4      [get_clocks mbist_clk]
  
  # ================================================================================================================================
  # ===== Virtual clocks for MBIST
  # ================================================================================================================================
  create_clock -name mbist_vclk -period $mbistclk_period
  set_clock_uncertainty -setup   [expr {0.05 * ${mbistclk_period}}]     [get_clocks mbist_vclk]
  set_clock_uncertainty -hold    0.4      [get_clocks mbist_vclk]
}

#vclk needed for normal and cp test mode (all scenarios except bist. bist has its own virtual clock.
if {[string match S3_m?? $i] == 0} {
  # ================================================================================================================================
  # ===== Virtual clocks for sys clk
  # ================================================================================================================================
  create_clock -name vclk -period $hfosc_period 
  set_clock_uncertainty -setup   [expr {0.05 * ${hfosc_period}}]     [get_clocks vclk]
  set_clock_uncertainty -hold    0.4      [get_clocks vclk]
}

#spi needed only in normal mode (not bist or CP test mode)
if {[string match S1??_m?? $i]} {    
  # ================================================================================================================================
  # ===== spi_clk   
  # ================================================================================================================================
  create_clock -name spi_clk [get_ports IOBUF_PAD[4]] -period $spiclk_period  -add
  set_clock_uncertainty -setup   [expr {0.05 * ${spiclk_period}}]     [get_clocks spi_clk]
  set_clock_uncertainty -hold    0.4      [get_clocks spi_clk]
}

if {[string match S11?_m?? $i]} {
 set_clock_groups -asynchronous -name async_grp1 \
         -group [list sys_clk notch_clk lpf_clk hpf_clk imeas_clk vclk] \
         -group [list spi_clk] \
}

if {[string match S12?_m?? $i]} { 
 set_clock_groups -asynchronous -name async_grp2 \
         -group [list ext_clk notch_clk lpf_clk hpf_clk imeas_clk vclk] \
         -group [list spi_clk] \
}

if {[string match S3_m?? $i]} {
  set_clock_groups -asynchronous -name async_grp_bist \
    -group [list mbist_clk mbist_vclk]
}
  
#set_sense -type clock -stop_propagation -clocks spi_clk      [get_pins  u_top_dig/u_pinmux/u_gpio4_pinmux/u_altf1_y/DNT_MX2/Y]

 # ================================================================================================================================
 # ===== OTP pins input delay/output delay 
 # ================================================================================================================================
if {[string match S3_m?? $i]} {
  # ------------------------------------------------------------------------------
  # OTP Bist Ports 
  # ------------------------------------------------------------------------------
  set_input_delay  -clock mbist_vclk -max [expr {0.20 * ${mbistclk_period}}]    [get_ports IOBUF_PAD[1]] -add_delay -clock_fall
  set_input_delay  -clock mbist_vclk -min 0.0                                   [get_ports IOBUF_PAD[1]] -add_delay -clock_fall
  set_input_delay  -clock mbist_vclk -max [expr {0.20 * ${mbistclk_period}}]    [get_ports IOBUF_PAD[2]] -add_delay -clock_fall
  set_input_delay  -clock mbist_vclk -min 0.0                                   [get_ports IOBUF_PAD[2]] -add_delay -clock_fall
  set_output_delay -clock mbist_vclk -max [expr {0.20 * ${mbistclk_period}}]    [get_ports IOBUF_PAD[3]] -add_delay
  set_output_delay -clock mbist_vclk -min 0.0                                   [get_ports IOBUF_PAD[3]] -add_delay
  set_output_delay -clock mbist_vclk -max [expr {0.20 * ${mbistclk_period}}]    [get_ports IOBUF_PAD[4]] -add_delay
  set_output_delay -clock mbist_vclk -min 0.0                                   [get_ports IOBUF_PAD[4]] -add_delay
  set_output_delay -clock mbist_vclk -max [expr {0.20 * ${mbistclk_period}}]    [get_ports IOBUF_PAD[5]] -add_delay
  set_output_delay -clock mbist_vclk -min 0.0                                   [get_ports IOBUF_PAD[5]] -add_delay
  
  #set_false_path -from mbist_vclk -through IOBUF_PAD[1] -to mbist_vclk;#source and destination cannot be both virtual clock
} 
     
#if not bist mode    
if {[string match S3_m?? $i] == 0} {
  set_multicycle_path 2 -setup -from vclk -to vclk
  set_multicycle_path 1 -hold  -from vclk -to vclk

  # --------------------------------------------------------------------------------------------------------------------------------
  #
  # Constraints --Input/Output Delay
  #
  # --------------------------------------------------------------------------------------------------------------------------------
  set inout_ports    [list IOBUF_PAD[*]]
  set input_ports    [list u_iopad_testmode0 u_iopad_testmode1 u_iopad_exresetn]
  set input_clock_ports     [list IOBUF_PAD[0] IOBUF_PAD[4] RESETn]
  # set output_clock_ports    [list CLK IOBUF_PAD[18]];#IOBUF_PAD[18] : SDM CLK OUT via GPIO for testing
  set a2d_clock_pins [list u_top_ana_wrapper/u_top_ana/A2D_CLK8MHZ]
  set d2a_clock_pins [list ]

  # ================================================================================================================================
  # ===== GPIO Pads input delay/output delay
  # ================================================================================================================================
  set_input_delay    -clock vclk  -max $cycle10 [get_ports [remove_from_collection [all_inputs]  $input_clock_ports]]     -add_delay
  set_input_delay    -clock vclk  -min 0.0      [get_ports [remove_from_collection [all_inputs]  $input_clock_ports]]     -add_delay
  set_output_delay   -clock vclk  -max $cycle10 [all_outputs]   -add_delay
  set_output_delay   -clock vclk  -min 0.0      [all_outputs]   -add_delay

  # ================================================================================================================================
  # ===== Analog pins input delay/output delay
  # ================================================================================================================================
  set_input_delay    -clock vclk  -max $cycle20 [get_pins [remove_from_collection [get_pins u_top_ana_wrapper/u_top_ana/A2D_*] $a2d_clock_pins]]   -add_delay
  set_input_delay    -clock vclk  -min 0.0      [get_pins [remove_from_collection [get_pins u_top_ana_wrapper/u_top_ana/A2D_*] $a2d_clock_pins]]   -add_delay
  set_output_delay   -clock vclk  -max $cycle20 [get_pins [remove_from_collection [get_pins u_top_ana_wrapper/u_top_ana/D2A_*] $d2a_clock_pins]]   -add_delay
  set_output_delay   -clock vclk  -min 0.0      [get_pins [remove_from_collection [get_pins u_top_ana_wrapper/u_top_ana/D2A_*] $d2a_clock_pins]]   -add_delay
  
  set_false_path -hold -rise -through u_top_ana_wrapper/u_top_ana/A2D_POR -through u_top_dig/u_otp_ctrl_top/por_resetn 
  set_false_path -hold -from CLKSEL
}

#normal mode, internal or external clock, SPI CPHA is 1
if {[string match S1?1_m?? $i]} {   
  set_input_delay  -clock spi_clk -max [expr {${spiclk_period}*0.05}] [get_ports IOBUF_PAD[3]] -add_delay -clock_fall;#CS pin; slave captures on rise of SPI clk but this signal changes after fall edge of SPI clock
  set_input_delay  -clock spi_clk -min 0.0                            [get_ports IOBUF_PAD[3]] -add_delay -clock_fall

  set_input_delay  -clock spi_clk -max [expr {${spiclk_period}*0.05}] [get_ports IOBUF_PAD[5]] -add_delay -clock_fall;#MOSI pin; ALT = 0,3;  slave captures on rise of SPI clk but this signal changes after fall edge of SPI clock
  set_input_delay  -clock spi_clk -min 0.0                            [get_ports IOBUF_PAD[5]] -add_delay -clock_fall

  set_output_delay -clock spi_clk -max [expr {${spiclk_period}*0.05}] [get_ports IOBUF_PAD[6]] -add_delay;#MISO pin; ALT = 0; master captures on rise of SPI clk
  set_output_delay -clock spi_clk -min 0.0                            [get_ports IOBUF_PAD[6]] -add_delay
  
  set_case_analysis 0 u_top_dig/u_spi_top/iopad_cpol
  set_case_analysis 0 u_top_dig/u_spi_top/iopad_cpha
}

#normal mode, internal or external clock, SPI CPHA is 2
if {[string match S1?2_m?? $i]} {   
  set_input_delay  -clock spi_clk -max [expr {${spiclk_period}*0.05}] [get_ports IOBUF_PAD[3]] -add_delay;#CS pin; slave captures on fall of SPI clk but this signal changes after rise edge of SPI clock
  set_input_delay  -clock spi_clk -min 0.0                            [get_ports IOBUF_PAD[3]] -add_delay

  set_input_delay  -clock spi_clk -max [expr {${spiclk_period}*0.05}] [get_ports IOBUF_PAD[5]] -add_delay;#MOSI pin; ALT = 0,3;  slave captures on fall of SPI clk but this signal changes after rise edge of SPI clock
  set_input_delay  -clock spi_clk -min 0.0                            [get_ports IOBUF_PAD[5]] -add_delay

  set_output_delay -clock spi_clk -max [expr {${spiclk_period}*0.05}] [get_ports IOBUF_PAD[6]] -add_delay -clock_fall;#MISO pin; ALT = 0; master captures on fall of SPI clk
  set_output_delay -clock spi_clk -min 0.0                            [get_ports IOBUF_PAD[6]] -add_delay -clock_fall
  
  set_case_analysis 0 u_top_dig/u_spi_top/iopad_cpol
  set_case_analysis 1 u_top_dig/u_spi_top/iopad_cpha
}

#if normal mode
if {[string match S1??_m?? $i]} {  
  set_false_path -setup -from [get_clocks spi_clk] -through IOBUF_PAD[3] -through u_top_dig/u_pinmux/u_gpio3_pinmux/altf_y -through u_top_dig/u_pinmux/u_gpio6_pinmux/altf_oe -through IOBUF_PAD[6] -to [get_clocks spi_clk] ;#CS can affect MISO but not timing critical
  set_multicycle_path 2 -setup -from spi_clk -to spi_clk -through [get_pins -hierarchical *spi*/*filter_bypass*]
  set_multicycle_path 1 -hold  -from spi_clk -to spi_clk -through [get_pins -hierarchical *spi*/*filter_bypass*]
}

#if normal mode
if {[string match S1??_m?? $i]} {   
  set_case_analysis 0 iopad_testmode0
  set_case_analysis 0 iopad_testmode1
 
  set_false_path -from hpf_clk -to notch_clk
  set_false_path -from lpf_clk -to notch_clk
  set_false_path -from imeas_clk -to notch_clk
}
 
#if cp test mode
if {[string match S22_m?? $i]} {   
  set_case_analysis 1 iopad_testmode0
  set_case_analysis 1 iopad_testmode1
}
 
#if bist test mode
if {[string match S3_m?? $i]} {   
  set_case_analysis 0 iopad_testmode0
  set_case_analysis 1 iopad_testmode1
}

#this pad always fixed
set_false_path -from iopad_testmode*
set_false_path -from [get_ports RESETn]
 
 # --------------------------------------------------------------------------------------------------------------------------------
 #
 # Constraints --Set Case Analysis
 #
 # --------------------------------------------------------------------------------------------------------------------------------
if {[string match S4_m?? $i]==0} {
  set_case_analysis 0 [get_pins u_top_dig/u_pinmux/atpg_en]
  set_case_analysis 0 [get_pins u_top_dig/u_pinmux/scan_en]
}

 # ------------------------------------------------------------------------------
 # Exception 
 # ------------------------------------------------------------------------------
#normal mode; int clk
if {[string match S11?_m?? $i]} {
  set_false_path -hold -from [get_clocks vclk] -through [get_ports IOBUF_PAD[10]] -through [get_pins u_top_dig/u_clk_ctrl/int_clk_out_gpio] -to [get_clocks sys_clk]
  set_false_path -from sys_clk -through u_top_dig/u_otp_ctrl_top/u_eprom_bist_top/*

  set_multicycle_path -reset_path -setup 2 -from sys_clk -through u_top_dig/u_imeas_wrapper/genblk1_*__u_filter_wrapper/u_filter_ctrl_nf_fsm* -to  notch_clk
  set_multicycle_path -reset_path -hold  2 -from sys_clk -through u_top_dig/u_imeas_wrapper/genblk1_*__u_filter_wrapper/u_filter_ctrl_nf_fsm* -to  notch_clk
  set_multicycle_path -reset_path -setup 2 -from sys_clk -through u_top_dig/u_imeas_wrapper/genblk1_*__u_filter_wrapper/u_filter_ctrl_fsm_cnt_reg_* -to  notch_clk
  set_multicycle_path -reset_path -hold  2 -from sys_clk -through u_top_dig/u_imeas_wrapper/genblk1_*__u_filter_wrapper/u_filter_ctrl_fsm_cnt_reg_* -to  notch_clk
  set_multicycle_path -reset_path -setup 2 -from sys_clk -through u_top_dig/u_imeas_wrapper/genblk1_*__u_filter_wrapper/u_filter_ctrl_lpf_fsm_reg* -to  notch_clk
  set_multicycle_path -reset_path -hold  2 -from sys_clk -through u_top_dig/u_imeas_wrapper/genblk1_*__u_filter_wrapper/u_filter_ctrl_lpf_fsm_reg* -to  notch_clk
  set_multicycle_path -reset_path -setup 2 -from sys_clk -through u_top_dig/u_imeas_wrapper/genblk1_*__u_filter_wrapper/u_filter_ctrl_hpf_fsm_reg* -to  notch_clk
  set_multicycle_path -reset_path -hold  2 -from sys_clk -through u_top_dig/u_imeas_wrapper/genblk1_*__u_filter_wrapper/u_filter_ctrl_hpf_fsm_reg* -to  notch_clk
}
#normal mode; ext clk
if {[string match S12?_m?? $i]} {
  set_false_path -hold -from [get_clocks vclk] -through [get_ports IOBUF_PAD[10]] -through [get_pins u_top_dig/u_clk_ctrl/int_clk_out_gpio] -to [get_clocks ext_clk]
  set_false_path -from ext_clk -through u_top_dig/u_otp_ctrl_top/u_eprom_bist_top/*

  set_multicycle_path -reset_path -setup 2 -from ext_clk -through u_top_dig/u_imeas_wrapper/genblk1_*__u_filter_wrapper/u_filter_ctrl_nf_fsm* -to  notch_clk
  set_multicycle_path -reset_path -hold  2 -from ext_clk -through u_top_dig/u_imeas_wrapper/genblk1_*__u_filter_wrapper/u_filter_ctrl_nf_fsm* -to  notch_clk
  set_multicycle_path -reset_path -setup 2 -from ext_clk -through u_top_dig/u_imeas_wrapper/genblk1_*__u_filter_wrapper/u_filter_ctrl_fsm_cnt_reg_* -to  notch_clk
  set_multicycle_path -reset_path -hold  2 -from ext_clk -through u_top_dig/u_imeas_wrapper/genblk1_*__u_filter_wrapper/u_filter_ctrl_fsm_cnt_reg_* -to  notch_clk
  set_multicycle_path -reset_path -setup 2 -from ext_clk -through u_top_dig/u_imeas_wrapper/genblk1_*__u_filter_wrapper/u_filter_ctrl_lpf_fsm_reg* -to  notch_clk
  set_multicycle_path -reset_path -hold  2 -from ext_clk -through u_top_dig/u_imeas_wrapper/genblk1_*__u_filter_wrapper/u_filter_ctrl_lpf_fsm_reg* -to  notch_clk
  set_multicycle_path -reset_path -setup 2 -from ext_clk -through u_top_dig/u_imeas_wrapper/genblk1_*__u_filter_wrapper/u_filter_ctrl_hpf_fsm_reg* -to  notch_clk
  set_multicycle_path -reset_path -hold  2 -from ext_clk -through u_top_dig/u_imeas_wrapper/genblk1_*__u_filter_wrapper/u_filter_ctrl_hpf_fsm_reg* -to  notch_clk
 
}

if {[string match S22_m?? $i]} {
  set_false_path -from vclk -through u_top_dig/u_otp_ctrl_top/u_eprom_bist_top/* -to [get_clocks ext_clk]
  set_false_path -from ext_clk -through u_top_dig/u_imeas_wrapper/*/*/* -to ext_clk
}

#if not scan mode then no OTP 
if {[string match S4_m?? $i]==0} {
 set_false_path -to [get_pin u_top_dig/u_otp_ctrl_top/u_EO32X32GCT2Q_H3/PPROG] ; # OTP Program Enable Mode
 #set_false_path -to [get_pin u_top_dig/u_otp_ctrl_top/u_EO32X32GCT2Q_H3/POR] ; # OTP Program Enable Mode
 set_multicycle_path -reset_path -setup 2 -to [get_pins u_top_dig/u_otp_ctrl_top/u_EO32X32GCT2Q_H3/PA*]
 set_multicycle_path -reset_path -hold  2 -to [get_pins u_top_dig/u_otp_ctrl_top/u_EO32X32GCT2Q_H3/PA*]
 set_multicycle_path -reset_path -setup 2 -to [get_pins u_top_dig/u_otp_ctrl_top/u_EO32X32GCT2Q_H3/PDIN*]
 set_multicycle_path -reset_path -hold  2 -to [get_pins u_top_dig/u_otp_ctrl_top/u_EO32X32GCT2Q_H3/PDIN*]
 set_false_path -to [get_pin u_top_dig/u_otp_ctrl_top/WAVEGEN_COEFFS[0].u_EO32X32GCT2Q_H3_wavgen/PPROG] ; # OTP Program Enable Mode
 #set_false_path -to [get_pin u_top_dig/u_otp_ctrl_top/u_EO32X32GCT2Q_H3/POR] ; # OTP Program Enable Mode
 set_multicycle_path -reset_path -setup 2 -to [get_pins u_top_dig/u_otp_ctrl_top/WAVEGEN_COEFFS[0].u_EO32X32GCT2Q_H3_wavgen/PA*]
 set_multicycle_path -reset_path -hold  2 -to [get_pins u_top_dig/u_otp_ctrl_top/WAVEGEN_COEFFS[0].u_EO32X32GCT2Q_H3_wavgen/PA*]
 set_multicycle_path -reset_path -setup 2 -to [get_pins u_top_dig/u_otp_ctrl_top/WAVEGEN_COEFFS[0].u_EO32X32GCT2Q_H3_wavgen/PDIN*]
 set_multicycle_path -reset_path -hold  2 -to [get_pins u_top_dig/u_otp_ctrl_top/WAVEGEN_COEFFS[0].u_EO32X32GCT2Q_H3_wavgen/PDIN*]
}

